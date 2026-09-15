# Gabarito — Módulo 05: Introdução ao Flutter

> Compare depois de resolver os [exercícios](../exercicios/05-introducao-ao-flutter.md).

<a id="m05-e01"></a>
## M05-E01
- **Engine**: camada em C++ que desenha, mede texto e hospeda a máquina virtual do Dart. É a mesma em todas as plataformas.
- **Embedder**: o pedaço específico de cada sistema que cria a janela/superfície e entrega eventos de toque, teclado e ciclo de vida à engine.
- **Impeller**: o renderizador atual do Flutter; pré-compila os shaders e elimina os engasgos de primeira exibição.
- **Skia**: o renderizador anterior, ainda usado em alguns alvos; compila shader sob demanda.
- **JIT** (*Just-In-Time*): compila durante a execução e mantém na memória uma tabela de funções trocáveis — modo `debug`.
- **AOT** (*Ahead-Of-Time*): compila tudo para código de máquina antes de instalar — modos `profile` e `release`.
- **Widget**: descrição imutável e barata de um pedaço da interface; não é o objeto desenhado na tela.

Hot reload só existe em `debug` porque ele troca funções naquela tabela da VM JIT; em AOT existe apenas um binário, e reescrevê-lo em memória é justamente o que os sistemas móveis proíbem.

<a id="m05-e02"></a>
## M05-E02
| Caminho | Decisão | Motivo |
|---|---|---|
| `lib/` | Versionar | É o seu código-fonte. |
| `build/` | Nunca | Artefato gerado; muda a cada compilação. |
| `.dart_tool/` | Nunca | Cache do SDK, com caminhos absolutos da sua máquina. |
| `pubspec.lock` | Versionar | Trava as versões exatas — é o que torna o build do app reproduzível. |
| `.metadata` | Versionar | O `flutter upgrade` usa esse arquivo para migrar o projeto. |
| `android/local.properties` | Nunca | Aponta o SDK do Android na sua máquina. |
| `android/key.properties` | Nunca | Contém a senha da chave de assinatura. Segredo não entra no Git. |

O `.gitignore` gerado pelo `flutter create` já cobre os quatro "nunca"; por isso o `git status` não os lista.

<a id="m05-e03"></a>
## M05-E03
- `version: 1.0.0+1` — `1.0.0` é o nome visível (`versionName` / `CFBundleShortVersionString`) e `+1` é o número do build (`versionCode` / `CFBundleVersion`), que precisa subir a cada envio às lojas.
- `environment: sdk: ^3.13.0` — faixa de SDK Dart aceita: `>=3.13.0 <4.0.0`.
- `cupertino_icons` — pacote que traz apenas o conjunto de ícones no estilo iOS.
- `flutter_lints: ^6.0.0` — regras de análise importadas pelo `analysis_options.yaml`; é o que o `flutter analyze` cobra.
- `uses-material-design: true` — embute a fonte de ícones do Material; sem ela, `Icons.*` não aparece.

Nenhuma dessas mudanças o hot reload aplica: o `pubspec.yaml` é lido pela ferramenta de build, não pela VM. Qualquer edição ali exige parar o app e rodar `flutter run` de novo.

<a id="m05-e04"></a>
## M05-E04
```dart
// lib/telas/metas_tela.dart
import 'package:flutter/material.dart';

class MetasTela extends StatelessWidget {
  const MetasTela({super.key});

  static const List<String> _materias = <String>['Dart', 'Flutter', 'Git e terminal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas da semana')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final String materia in _materias) Text(materia),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {},
              child: const Text('Registrar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}
```
```text
MeuPrimeiroApp
└── MaterialApp
    └── MetasTela
        └── Scaffold
            ├── AppBar
            │   └── Text('Metas da semana')
            └── Padding
                └── Column
                    ├── Text('Dart')
                    ├── Text('Flutter')
                    ├── Text('Git e terminal')
                    ├── SizedBox
                    └── FilledButton
                        └── Text('Registrar sessão')
```
`runApp` recebe um único widget: a tela nova entra como `home` do `MaterialApp`, nunca direto no `main()`.

<a id="m05-e05"></a>
## M05-E05
```dart
// lib/widgets/etiqueta_nivel.dart
import 'package:flutter/material.dart';

class EtiquetaNivel extends StatelessWidget {
  const EtiquetaNivel({super.key, required this.minutos, this.compacta = false});

  final int minutos;
  final bool compacta;

  String get nivel {
    if (minutos <= 60) return 'Iniciante';
    if (minutos <= 180) return 'Praticando';
    if (minutos <= 600) return 'Consistente';
    return 'Veterano';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;
    final (Color fundo, Color frente) = switch (nivel) {
      'Iniciante' => (cores.surfaceContainerHighest, cores.onSurfaceVariant),
      'Praticando' => (cores.secondaryContainer, cores.onSecondaryContainer),
      'Consistente' => (cores.tertiaryContainer, cores.onTertiaryContainer),
      _ => (cores.primaryContainer, cores.onPrimaryContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        compacta ? nivel.substring(0, 1) : nivel,
        style: tema.textTheme.labelSmall?.copyWith(color: frente),
      ),
    );
  }
}
```
No `CartaoMateria`, use `EtiquetaNivel(minutos: minutosEstudados)` dentro da `Row` do nome — nenhum campo novo, porque o dado já está lá.

<a id="m05-e06"></a>
## M05-E06
```dart
class CartaoMeta extends StatefulWidget {
  const CartaoMeta({super.key, required this.materia, this.minutosIniciais = 0});

  final String materia;      // volta a ser final: widget é imutável
  final int minutosIniciais;

  @override
  State<CartaoMeta> createState() => _CartaoMetaState();
}

class _CartaoMetaState extends State<CartaoMeta> {
  late int _minutos;

  @override
  void initState() {
    super.initState();
    _minutos = widget.minutosIniciais;
  }

  void _registrar() => setState(() => _minutos += 25);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.materia),
        subtitle: Text('$_minutos min'),
        trailing: FilledButton(
          onPressed: _registrar,
          child: const Text('Registrar'),
        ),
      ),
    );
  }
}
```
O defeito era guardar estado no widget: o framework descarta e recria o widget a cada build, então a soma se perdia — só o `State` sobrevive.

<a id="m05-e07"></a>
## M05-E07
```dart
class ContadorSessoes extends StatefulWidget {
  const ContadorSessoes({
    super.key,
    this.minutosPorSessao = 25,
    this.sessoesIniciais = 0,
    this.limiteDiario = 12,
    this.onMudou,
  });

  final int minutosPorSessao;
  final int sessoesIniciais;
  final int limiteDiario;
  final void Function(int sessoes, int minutos)? onMudou;

  @override
  State<ContadorSessoes> createState() => _ContadorSessoesState();
}

class _ContadorSessoesState extends State<ContadorSessoes> {
  late int _sessoes;

  @override
  void initState() {
    super.initState();
    _sessoes = widget.sessoesIniciais; // `widget` só existe a partir daqui
  }

  bool get _noLimite => _sessoes >= widget.limiteDiario;

  void _concluir() {
    if (_noLimite) return;
    setState(() => _sessoes++);
    widget.onMudou?.call(_sessoes, _sessoes * widget.minutosPorSessao);
    if (_noLimite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Limite de ${widget.limiteDiario} sessões atingido hoje.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$_sessoes', style: Theme.of(context).textTheme.displayLarge),
        FilledButton.icon(
          onPressed: _noLimite ? null : _concluir,
          icon: const Icon(Icons.add),
          label: const Text('Concluir sessão'),
        ),
      ],
    );
  }
}
```
`onPressed: null` já desabilita o botão e o Material 3 o pinta de cinza; não invente um campo `enabled`.

<a id="m05-e08"></a>
## M05-E08
```dart
import 'dart:async';

import 'package:flutter/material.dart';

class CronometroSessao extends StatefulWidget {
  const CronometroSessao({super.key, required this.duracaoMinutos});

  final int duracaoMinutos;

  @override
  State<CronometroSessao> createState() => _CronometroSessaoState();
}

class _CronometroSessaoState extends State<CronometroSessao> {
  Timer? _cronometro;
  late final TextEditingController _controladorAnotacao; // 1 — nunca no build
  late int _segundosRestantes;

  @override
  void initState() {
    super.initState();
    _segundosRestantes = widget.duracaoMinutos * 60;
    _controladorAnotacao = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant CronometroSessao widgetAntigo) {
    super.didUpdateWidget(widgetAntigo);
    // 3 — só reinicia quando a duração realmente mudou.
    if (widget.duracaoMinutos != widgetAntigo.duracaoMinutos) {
      _cronometro?.cancel();
      setState(() => _segundosRestantes = widget.duracaoMinutos * 60);
    }
  }

  @override
  void dispose() {
    _cronometro?.cancel(); // 2 — sem isto, setState em um State morto
    _controladorAnotacao.dispose();
    super.dispose();
  }

  void _iniciar() {
    _cronometro?.cancel(); // nunca deixe dois timers vivos
    _cronometro = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_segundosRestantes <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _segundosRestantes--);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$_segundosRestantes s'),
        TextField(controller: _controladorAnotacao),
        FilledButton(onPressed: _iniciar, child: const Text('Iniciar')),
      ],
    );
  }
}
```
Controller criado dentro do `build` nasce vazio a cada rebuild do pai — era por isso que a anotação digitada sumia.

<a id="m05-e09"></a>
## M05-E09
- **Primeira montagem:** `createState` → `initState` → `didChangeDependencies` → `build`.
- **Redimensionar o Chrome:** `didUpdateWidget` (se o pai reconstruiu) → `didChangeDependencies` → `build`. O `initState` **não** roda de novo.
- **Sair da tela:** `deactivate` → `dispose`.

`didChangeDependencies` vem depois porque só nesse momento o `Element` já está ligado à árvore e conhece seus ancestrais; no `initState` essa ligação ainda não existe, e por isso `Theme.of(context)` estoura ali.

<a id="m05-e10"></a>
## M05-E10
`Theme.of(context)` sobe a árvore a partir daquele `context` procurando o `InheritedWidget` `Theme` mais próximo, registra o widget como dependente — para ser reconstruído quando o tema mudar — e devolve o `ThemeData`. Dois widgets declarados no mesmo arquivo têm `context` diferentes porque `context` é o `Element` de cada um: quem define os ancestrais é a **posição na árvore**, não o arquivo. `Builder` não desenha nada; ele cria um `Element` novo e entrega um `context` um nível abaixo, que enxerga o que foi criado no mesmo `build` (um `Scaffold`, por exemplo). A prova de que a busca é por ancestral é o erro `No MediaQuery ancestor could be found`, que aparece quando você chama `MediaQuery.of` acima do `MaterialApp`.

<a id="m05-e11"></a>
## M05-E11
```dart
class _HomeTelaState extends State<HomeTela> {
  Future<void> _salvar() async {
    // 2 — capture o mensageiro ANTES do await e cheque mounted depois.
    final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    mensageiro.showSnackBar(const SnackBar(content: Text('Progresso salvo.')));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        title: const Text('Foco'),
        // 1 — Builder cria um context ABAIXO deste Scaffold.
        leading: Builder(
          builder: (BuildContext contextAbaixo) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(contextAbaixo).openDrawer(),
          ),
        ),
      ),
      body: Container(
        color: cores.surfaceContainerHighest, // 3 — cor do tema, não Colors.white
        child: FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ),
    );
  }
}
```
Extrair a `AppBar` para um widget próprio resolve o item 1 do mesmo jeito: o que importa é o `context` nascer abaixo do `Scaffold`.

<a id="m05-e12"></a>
## M05-E12
```dart
// lib/tema/tema_app.dart
import 'package:flutter/material.dart';

abstract final class TemaApp {
  static const Color _semente = Color(0xFF3F51B5);

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get escuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _semente, brightness: brilho),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      );
}
```
```dart
MaterialApp(
  theme: TemaApp.claro,
  darkTheme: TemaApp.escuro,
  themeMode: ThemeMode.system,
  home: const HomeTela(),
)
```
```dart
class PainelSemana extends StatelessWidget {
  const PainelSemana({super.key, required this.metricas});

  final List<(String rotulo, String valor)> metricas;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final bool estreito = MediaQuery.sizeOf(context).width < 600;
    final List<Widget> cartoes = <Widget>[
      for (final (String rotulo, String valor) in metricas)
        _Metrica(rotulo: rotulo, valor: valor),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: cores.surfaceContainerHighest,
      child: estreito
          ? Column(children: cartoes)
          : Row(
              children: <Widget>[
                for (final Widget cartao in cartoes) Expanded(child: cartao),
              ],
            ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Text(valor, style: tema.textTheme.headlineSmall),
          Text(
            rotulo,
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
```
`MediaQuery.sizeOf` só reconstrói quando o tamanho muda; `MediaQuery.of` reconstruiria também a cada mudança de teclado, fonte ou brilho.

<a id="m05-e13"></a>
## M05-E13
| Mudança | Tecla | Por quê |
|---|---|---|
| Texto de um `Text` | `r` | Está dentro do `build`, que roda de novo na hora. |
| Corpo do `initState` | `R` | O código novo entra, mas o `initState` já rodou e não roda outra vez. |
| `int _sessoes = 0` → `5` | `R` | É inicializador de campo do `State`, executado só na criação do objeto. |
| `StatelessWidget` → `StatefulWidget` | `R` | Muda a hierarquia da classe; o hot reload é rejeitado. |
| Dependência nova no `pubspec.yaml` | Parar e `flutter run` | O pacote precisa ser resolvido e o app recompilado. |

Trocando `0` por `5` e apertando `r`, a tela ignora a mudança porque o `State` já existe com `_sessoes = 0`: o `r` preserva o estado vivo e só reexecuta `build`. Só o `R` joga fora todos os `State` e recria tudo do zero.

<a id="m05-e14"></a>
## M05-E14
O **Foco** (`br.com.estudos.foco`) adota Material 3 nas duas plataformas, com adaptações pontuais. Com uma pessoa mantendo o app, manter duas árvores de widgets — Material e Cupertino — dobra o custo de cada tela nova e de cada correção, sem ganho proporcional: usuários de iOS já convivem com apps de identidade própria, e o Flutter já ajusta sozinho a transição de rotas e o comportamento de rolagem pelo `Theme.of(context).platform`.

O que **não** vou adaptar é a navegação e a `AppBar`: uma barra só, Material, com o mesmo título e as mesmas ações nos dois sistemas — duplicar isso é manutenção permanente em troca de um detalhe estético. O que vale o `.adaptive` é o `Switch.adaptive` nas preferências de lembrete e o `CircularProgressIndicator.adaptive` enquanto as sessões carregam: uma palavra no código, zero manutenção extra.

Para detectar plataforma uso `Theme.of(context).platform == TargetPlatform.iOS`, nunca `Platform.isIOS`: `dart:io` não existe no Flutter Web e quebra a compilação, além de impedir alternar as duas aparências pelo `o` do terminal durante o desenvolvimento.

[Exercícios](../exercicios/05-introducao-ao-flutter.md) · [Módulo](../modulos/05-introducao-ao-flutter/README.md)
