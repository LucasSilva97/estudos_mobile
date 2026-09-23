# Passo a passo — Projeto 02: Bloco de Notas de Estudo

> 📌 **Construa junto, não copie do [03-codigo-completo.md](03-codigo-completo.md).** Digite, rode,
> erre, leia a mensagem e conserte — é assim que fixa. O 03 serve para **conferir** quando algo não
> bater, nunca para colar 17 arquivos de uma vez.

> 🪟 Tudo roda no Windows 11: `flutter run -d chrome`, `-d windows` ou um emulador Android. Nada
> aqui exige Mac — o `.ipa` é o [módulo 16](../../modulos/16-build-ios/README.md).

São oito etapas e **ao fim de cada uma o app roda**. Se não roda, conserte antes de avançar.

| # | Etapa | Entrega | Tempo |
|---|---|---|---|
| 1 | Criar o projeto | `flutter create` + `shared_preferences` | 15 min |
| 2 | O domínio | `Etiqueta`, `Ordenacao`, `Nota` | 30 min |
| 3 | Tema e data | `TemaApp`, `formatarDataHora` | 20 min |
| 4 | Os widgets | `ChipEtiqueta`, `CartaoNota`, `EstadoVazio` | 30 min |
| 5 | A persistência | `NotasRepositorio` + `HomeScreen` com estado | 35 min |
| 6 | Rotas e formulário | `Rotas.gerar`, `Validadores`, `NotaFormScreen` | 55 min |
| 7 | O detalhe | `NotaDetalheScreen`, editar e excluir | 35 min |
| 8 | Filtro, ordem e desfazer | `FilterChip`, `PopupMenuButton`, `Dismissible` | 45 min |

---

## Etapa 1 — Criar o projeto e rodar (≈ 15 min)

**Objetivo:** um app vazio, com o nome de pacote certo e a única dependência do projeto instalada.

```powershell
flutter create bloco_notas
cd bloco_notas
flutter pub add shared_preferences
flutter run -d chrome
```

Confira o `pubspec.yaml`: `name: bloco_notas` — é o prefixo de **todo** `import` do projeto —,
`sdk: ^3.13.0` e apenas duas dependências, `cupertino_icons: ^1.0.8` e `shared_preferences: ^2.5.5`.
Apague `test/widget_test.dart`: ele testa o contador que você vai remover e falharia em todo
`flutter test`. Agora troque o `lib/main.dart` inteiro:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const BlocoNotasApp());

class BlocoNotasApp extends StatelessWidget {
  const BlocoNotasApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bloco de Notas',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text('Bloco de Notas')),
          body: const Center(child: Text('Em construção')),
        ),
      );
}
```

> ✅ **Como saber que funcionou:** abre a barra "Bloco de Notas" com "Em construção" no meio da
> tela. Nenhum contador, nenhum botão `+`.

---

## Etapa 2 — O domínio: Etiqueta, Ordenacao e Nota (≈ 30 min)

**Objetivo:** modelar a nota e garantir que ela vá e volte do JSON sem derrubar o app.

Crie `lib/features/notas/domain/`. Os dois enums têm o mesmo `porNome`, que **nunca** devolve null:
valor gravado desconhecido cai no padrão.

```dart
// etiqueta.dart
enum Etiqueta {
  aula('Aula'), resumo('Resumo'), duvida('Dúvida'), revisao('Revisão'), ideia('Ideia');

  const Etiqueta(this.rotulo);

  /// O que aparece na tela. O `name` (`duvida`) é o que vai para o disco.
  final String rotulo;

  static Etiqueta porNome(String? nome) => Etiqueta.values.firstWhere(
        (Etiqueta etiqueta) => etiqueta.name == nome,
        orElse: () => Etiqueta.resumo,
      );
}

// ordenacao.dart — mesmo molde, com orElse: () => Ordenacao.maisRecente
enum Ordenacao {
  maisRecente('Mais recentes'), maisAntiga('Mais antigas'), tituloAZ('Título A–Z');
  // ...
}
```

Em `nota.dart`, a classe é imutável: construtor `const` e seis campos `final` — `id`, `titulo`,
`conteudo`, `etiqueta`, `criadaEm`, `atualizadaEm`. O método que decide se o app sobrevive a um
arquivo estragado é a leitura:

```dart
/// Devolve **null** com campo obrigatório faltando: o repositório descarta só
/// o item ruim e continua lendo os outros (RF21).
static Nota? doMapa(Map<String, Object?> mapa) {
  final Object? id = mapa['id'];
  final Object? titulo = mapa['titulo'];
  final Object? conteudo = mapa['conteudo'];
  final Object? criadaBruta = mapa['criadaEm'];
  final Object? atualizadaBruta = mapa['atualizadaEm'];
  final Object? etiquetaBruta = mapa['etiqueta'];

  // `is String`, nunca `as String`: teste de tipo não derruba o app.
  if (id is! String || id.isEmpty) return null;
  if (titulo is! String || titulo.trim().isEmpty) return null;
  if (conteudo is! String) return null;
  if (criadaBruta is! String || atualizadaBruta is! String) return null;

  final DateTime? criadaEm = DateTime.tryParse(criadaBruta);
  final DateTime? atualizadaEm = DateTime.tryParse(atualizadaBruta);
  if (criadaEm == null || atualizadaEm == null) return null;

  return Nota(
    id: id, titulo: titulo, conteudo: conteudo,
    // Etiqueta ausente não invalida a nota: vira `resumo`.
    etiqueta: Etiqueta.porNome(etiquetaBruta is String ? etiquetaBruta : null),
    criadaEm: criadaEm, atualizadaEm: atualizadaEm,
  );
}
```

Faltam três blocos, todos no [03](03-codigo-completo.md): `paraMapa()`, que devolve só tipos que o
`jsonEncode` aceita (`DateTime` vira `toIso8601String()`, `Etiqueta` vira `.name`); `copyWith`, que
aceita **apenas** `titulo`, `conteudo`, `etiqueta` e `atualizadaEm` — deixar `id` e `criadaEm` de
fora é proposital (RF17); e o par `operator ==` / `hashCode` por valor, sem o qual os testes
comparariam endereços de memória e falhariam sempre.

Para ver isso rodando, deixe no `main.dart` uma lista **temporária**, que sai na etapa 5:

```dart
final DateTime _agora = DateTime.now();
final List<Nota> _exemplo = <Nota>[
  Nota(id: '1', titulo: 'Ciclo de vida do State', conteudo: 'initState roda uma vez.',
      etiqueta: Etiqueta.aula, criadaEm: _agora, atualizadaEm: _agora),
  Nota(id: '2', titulo: 'Dúvida sobre BuildContext', conteudo: 'Por que mounted?',
      etiqueta: Etiqueta.duvida, criadaEm: _agora, atualizadaEm: _agora),
];
// body: ListView(children: [for (final Nota n in _exemplo)
//   ListTile(title: Text(n.titulo), subtitle: Text(n.etiqueta.rotulo))]),
```

> ✅ **Como saber que funcionou:** a tela lista "Ciclo de vida do State / Aula" e "Dúvida sobre
> BuildContext / Dúvida", e o `flutter analyze` não reclama de nada.

---

## Etapa 3 — Tema e formatação de data (≈ 20 min)

**Objetivo:** uma cor semente comandando o app nos dois modos, e data legível sem `package:intl`.

`lib/core/formato/formato_data.dart` é uma função de nível superior, não uma classe: ela não guarda
estado nenhum.

```dart
/// Data e hora no formato brasileiro: `14/09/2026 às 22:43`.
String formatarDataHora(DateTime quando) {
  final String dia = _doisDigitos(quando.day);
  final String mes = _doisDigitos(quando.month);
  final String hora = _doisDigitos(quando.hour);
  final String minuto = _doisDigitos(quando.minute);
  return '$dia/$mes/${quando.year} às $hora:$minuto';
}

/// `7` vira `07`. Sem isso a hora sai como `9:5`.
String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');
```

Em `lib/core/tema/tema_app.dart`, os dois temas saem da **mesma** função privada — é isso que impede
o escuro de divergir do claro:

```dart
abstract final class TemaApp {
  /// O algoritmo do Material 3 deriva a paleta inteira desta cor.
  static const Color semente = Color(0xFF4F46E5);

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get escuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final ColorScheme cores =
        ColorScheme.fromSeed(seedColor: semente, brightness: brilho);
    return ThemeData(colorScheme: cores, scaffoldBackgroundColor: cores.surface);
  }
}
```

Depois acrescente ao `ThemeData` o `appBarTheme` (com `scrolledUnderElevation: 2`, a sombra que só
aparece quando a lista passa por baixo da barra), o `cardTheme` de cantos de 16 e borda
`outlineVariant`, e os três ajustes menores — `filledButtonTheme`, `snackBarTheme`, `dividerTheme`.
Todos estão no [03](03-codigo-completo.md). No `MaterialApp`:

```dart
theme: TemaApp.claro,
darkTheme: TemaApp.escuro,
// Segue a configuração do aparelho — o que o usuário espera.
themeMode: ThemeMode.system,
```

Aproveite e mostre a data no `ListTile` temporário: `subtitle: Text(formatarDataHora(n.atualizadaEm))`.

> ✅ **Como saber que funcionou:** o app fica índigo, o `subtitle` mostra algo como
> `14/09/2026 às 22:43`, e virar o Windows para o modo escuro muda o app sem recompilar.

---

## Etapa 4 — Os widgets da lista (≈ 30 min)

**Objetivo:** ter o cartão, a pílula de etiqueta e o estado vazio prontos para qualquer tela usar.

Em `lib/features/notas/presentation/widgets/`, três arquivos. No `ChipEtiqueta`, cada etiqueta usa
um **papel** do `ColorScheme`, nunca um valor fixo — é por isso que o contraste continua correto no
tema escuro:

```dart
final (Color fundo, Color frente) = switch (etiqueta) {
  Etiqueta.aula => (cores.primaryContainer, cores.onPrimaryContainer),
  Etiqueta.resumo => (cores.secondaryContainer, cores.onSecondaryContainer),
  Etiqueta.duvida => (cores.errorContainer, cores.onErrorContainer),
  Etiqueta.revisao => (cores.tertiaryContainer, cores.onTertiaryContainer),
  Etiqueta.ideia => (cores.surfaceContainerHighest, cores.onSurfaceVariant),
};
```

Em volta disso, um `Container` com `borderRadius: BorderRadius.circular(999)` e o
`Text(etiqueta.rotulo)`.

O `CartaoNota` recebe `nota` e `aoTocar` e não sabe nada de navegação nem de repositório — quem
decide o que o toque faz é a `HomeScreen`. É um `Card` com `clipBehavior: Clip.antiAlias` (sem isso
a onda do `InkWell` vaza pelos cantos), `InkWell`, `Padding(16)` e uma `Column`: título com
`maxLines: 1`, a prévia, e uma `Row` com o `ChipEtiqueta` e a data em um `Expanded` à direita.

```dart
/// Só a primeira linha do conteúdo: é o que mantém todos os cartões com a
/// mesma altura, independente do tamanho da nota.
String get _previa {
  final String primeira = nota.conteudo.trim().split('\n').first.trim();
  return primeira.isEmpty ? 'Sem conteúdo' : primeira;
}
```

O `EstadoVazio` só existe pelos dois construtores nomeados: os dois vazios do app são casos
diferentes e precisam dizer coisas diferentes.

```dart
const EstadoVazio.inicial({required VoidCallback aoCriar, super.key})
    : titulo = 'Nenhuma nota ainda',
      mensagem = 'Anote uma aula, um resumo ou aquela dúvida que ficou. '
          'Tudo fica salvo no aparelho.',
      icone = Icons.note_add_outlined,
      rotuloAcao = 'Criar nota',
      onAcao = aoCriar;

// .semResultado: 'Nenhuma nota com essa etiqueta', Icons.search_off_outlined,
// 'Limpar filtro', onAcao = aoLimpar.
```

O `build` dele é um **`ListView`**, não uma `Column`: em tela baixa, ou com a fonte do sistema
aumentada, a `Column` estoura em overflow amarelo. Troque então o `body` do `main.dart` por um
`ListView.separated` com `padding: const EdgeInsets.fromLTRB(16, 8, 16, 96)`, `SizedBox(height: 12)`
de separador e `CartaoNota(nota: _exemplo[indice], aoTocar: () {})` no `itemBuilder`.

> ✅ **Como saber que funcionou:** dois cartões arredondados, com a pílula colorida e a data à
> direita. Esvazie `_exemplo` por um instante, troque o `body` por
> `EstadoVazio.inicial(aoCriar: () {})`, veja o vazio e desfaça.

---

## Etapa 5 — O repositório e o `main` de verdade (≈ 35 min)

**Objetivo:** gravar no disco e provar, fechando o app, que a nota continua lá.

Crie `lib/features/notas/data/notas_repositorio.dart`. Ele recebe o `SharedPreferences` **pronto**
pelo construtor — é isso que vai permitir testá-lo no Windows, sem emulador e sem plugin nativo.

```dart
class NotasRepositorio {
  const NotasRepositorio(this._prefs);
  final SharedPreferences _prefs;

  // Chave digitada à mão em dois lugares é como o dado some sem ninguém entender.
  static const String chaveNotas = 'bloco_notas.notas';
  static const String chaveOrdenacao = 'bloco_notas.ordenacao';
  static const int maxNotas = 200;

  /// Nunca lança: arquivo corrompido devolve lista vazia (RF20).
  List<Nota> lerNotas() {
    final String? texto = _prefs.getString(chaveNotas);
    if (texto == null || texto.isEmpty) return const <Nota>[];

    Object? decodificado;
    try {
      decodificado = jsonDecode(texto);
    } on FormatException {
      return const <Nota>[];
    }
    // Gravamos um array. Se veio outra coisa, o dado não é nosso.
    if (decodificado is! List<Object?>) return const <Nota>[];

    final List<Nota> notas = <Nota>[];
    for (final Object? item in decodificado) {
      if (item is! Map<String, Object?>) continue;
      final Nota? nota = Nota.doMapa(item);
      if (nota != null) notas.add(nota); // item ruim sai, os outros ficam (RF21)
    }
    return notas;
  }

  /// Grava a lista inteira de uma vez (RF19).
  Future<void> salvarNotas(List<Nota> notas) async {
    if (notas.length > maxNotas) {
      throw ArgumentError.value(notas.length, 'notas',
          'este armazenamento guarda no máximo $maxNotas notas');
    }
    final Set<String> idsVistos = <String>{};
    for (final Nota nota in notas) {
      // `add` devolve false quando o id já estava no conjunto.
      if (!idsVistos.add(nota.id)) {
        throw ArgumentError.value(nota.id, 'notas', 'id repetido na lista');
      }
    }
    await _prefs.setString(
        chaveNotas, jsonEncode(notas.map((Nota n) => n.paraMapa()).toList()));
  }

  Ordenacao lerOrdenacao() => Ordenacao.porNome(_prefs.getString(chaveOrdenacao));

  Future<void> salvarOrdenacao(Ordenacao ordenacao) =>
      _prefs.setString(chaveOrdenacao, ordenacao.name);
}
```

Agora o `main` de verdade — apague `_exemplo` e `_agora`:

```dart
Future<void> main() async {
  // `getInstance` fala com o nativo por um canal de plataforma. Sem o binding
  // iniciado, esse canal ainda não existe e a chamada falha.
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(BlocoNotasApp(repositorio: NotasRepositorio(prefs)));
}
```

`BlocoNotasApp` passa a receber `required this.repositorio` e usa `home: HomeScreen(repositorio:
repositorio)` — as rotas vêm na etapa 6. Crie `presentation/home_screen.dart` como `StatefulWidget`,
com `List<Nota> _notas = const <Nota>[]` e `bool _carregando = true`:

```dart
@override
void initState() {
  super.initState();
  _carregar();
}

/// A leitura é síncrona, mas esperar um ciclo do laço de eventos garante que o
/// primeiro quadro mostre o indicador em vez de "nenhuma nota" (RF02).
Future<void> _carregar() async {
  await Future<void>.delayed(Duration.zero);
  if (!mounted) return;
  setState(() {
    _notas = widget.repositorio.lerNotas();
    _carregando = false;
  });
}

/// Toda mudança na lista passa por aqui: atualiza a tela e grava o arquivo
/// inteiro (RF19).
Future<void> _aplicar(List<Nota> novas) async {
  setState(() => _notas = novas);
  await widget.repositorio.salvarNotas(novas);
}

Widget _corpo() {
  if (_carregando) return const Center(child: CircularProgressIndicator());
  if (_notas.isEmpty) return EstadoVazio.inicial(aoCriar: _criarNotaDeTeste);
  return ListView.separated(/* o mesmo da etapa 4, agora sobre _notas */);
}
```

Para provar a gravação antes de existir formulário, use um FAB **temporário** ligado a um
`_criarNotaDeTeste()`: ele monta uma `Nota` com `id: agora.microsecondsSinceEpoch.toString()`,
`Etiqueta.resumo` e as duas datas iguais, e chama `await _aplicar(<Nota>[nova, ..._notas])`. Some na
etapa 6.

> ✅ **Como saber que funcionou:** na primeira abertura aparece "Nenhuma nota ainda". Toque no FAB
> duas vezes, **feche o app e abra de novo**: as duas notas continuam lá, na mesma ordem.

---

## Etapa 6 — Rotas nomeadas e o formulário (≈ 55 min)

**Objetivo:** concentrar a navegação em um lugar só e criar a primeira nota de verdade.

Comece por `lib/core/rotas/rota_desconhecida_screen.dart`: ícone `Icons.explore_off_outlined`, o
texto `'Não encontramos a tela "${nome ?? 'sem nome'}".'` e um `FilledButton` que chama
`pushNamedAndRemoveUntil(Rotas.home, (_) => false)` — não faz sentido "voltar" para o erro. Depois,
`lib/core/rotas/rotas.dart`:

```dart
abstract final class Rotas {
  static const String home = '/';
  static const String notaDetalhe = '/nota/detalhe';
  static const String notaForm = '/nota/form';

  static Route<dynamic> gerar(RouteSettings configuracoes, NotasRepositorio repositorio) {
    final Object? argumentos = configuracoes.arguments;

    switch (configuracoes.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => HomeScreen(repositorio: repositorio),
        );
      case notaForm:
        // `is!` em vez de `as`: argumento errado vira tela de erro, não crash.
        if (argumentos is! NotaFormArgs) return desconhecida(configuracoes);
        return MaterialPageRoute<Nota>(
          settings: configuracoes,
          fullscreenDialog: true, // sobe de baixo e ganha o X: é um modal
          builder: (_) => NotaFormScreen(args: argumentos),
        );
      // `notaDetalhe` entra na etapa 7.
      default:
        return desconhecida(configuracoes);
    }
  }

  static Route<dynamic> desconhecida(RouteSettings configuracoes) => MaterialPageRoute<void>(
        settings: configuracoes,
        builder: (_) => RotaDesconhecidaScreen(nome: configuracoes.name),
      );
}
```

No `MaterialApp`, troque o `home:` por `initialRoute: Rotas.home`, `onUnknownRoute:
Rotas.desconhecida` e `onGenerateRoute: (RouteSettings c) => Rotas.gerar(c, repositorio)` — essa
closure existe só para entregar o repositório ao gerador, já que este app não tem injeção de
dependência (isso é o `ProviderScope` do módulo 08).

Agora `lib/core/validadores/validadores.dart`: o `typedef Validador = String? Function(String?)` e o
`abstract final class Validadores`. `combinar` roda em ordem e para no **primeiro** erro — três
mensagens ao mesmo tempo é ruído. `obrigatorio`, `minimo` e `maximo` medem depois do `trim()`: três
espaços não contam como preenchido. E `minimo` devolve `null` com texto vazio, porque "vazio" é
assunto do `obrigatorio`.

Em `presentation/nota_form_screen.dart`, dois construtores nomeados deixam a intenção explícita em
quem chama:

```dart
class NotaFormArgs {
  const NotaFormArgs.criar() : original = null;
  const NotaFormArgs.editar(Nota nota) : original = nota;

  /// null = criando; preenchido = editando.
  final Nota? original;
  bool get ehEdicao => original != null;
}
```

No `State`: a `GlobalKey<FormState>`, dois `TextEditingController` iniciados com o texto do original,
`late Etiqueta _etiqueta = _original?.etiqueta ?? Etiqueta.resumo` (nunca nulo, RF15) e
`AutovalidateMode _autovalidar = AutovalidateMode.disabled` — o formulário abre limpo, sem vermelho
(RF16). No `initState` os controllers ganham `addListener(_aoDigitar)`; no `dispose` você remove o
listener **e** chama `dispose()` neles. `_aoDigitar` é só `setState(() {})`: é o que faz o
`PopScope` reavaliar `canPop` a cada tecla.

```dart
void _salvar() {
  FocusScope.of(context).unfocus(); // o teclado cobriria as mensagens de erro
  if (!_chaveDoFormulario.currentState!.validate()) {
    setState(() => _autovalidar = AutovalidateMode.onUserInteraction);
    return;
  }

  final DateTime agora = DateTime.now();
  final Nota? original = _original;

  final Nota nota = original == null
      ? Nota(
          // Sem o pacote uuid (Projeto 3): microssegundos não repetem no aparelho.
          id: agora.microsecondsSinceEpoch.toString(),
          titulo: _titulo.text.trim(), conteudo: _conteudo.text.trim(),
          etiqueta: _etiqueta, criadaEm: agora, atualizadaEm: agora,
        )
      // copyWith preserva id e criadaEm: só a atualização muda (RF17).
      : original.copyWith(
          titulo: _titulo.text.trim(), conteudo: _conteudo.text.trim(),
          etiqueta: _etiqueta, atualizadaEm: agora,
        );

  Navigator.of(context).pop(nota);
}
```

O `build` devolve um `PopScope<Nota>` — o mesmo tipo declarado na rota. `_temAlteracoes` compara os
campos com o original (na criação, com o vazio e com `Etiqueta.resumo`).

```dart
return PopScope<Nota>(
  canPop: !_temAlteracoes,
  onPopInvokedWithResult: (bool saiu, Nota? resultado) {
    if (saiu) return;        // o pop aconteceu; nada a fazer
    _perguntarSeDescarta();  // canPop era false: o pop foi BLOQUEADO
  },
  child: Scaffold(/* AppBar 'Nova nota' ou 'Editar nota' + o Form */),
);
```

Dentro do `Form(key: _chaveDoFormulario, autovalidateMode: _autovalidar)` vai um `ListView` com três
campos e o botão. As `Key` não são enfeite: são por onde o teste de widget do [04](04-testes.md)
encontra cada campo.

```dart
TextFormField(
  key: const Key('campo_titulo'),
  controller: _titulo,
  maxLength: 60,
  textInputAction: TextInputAction.next,
  decoration: const InputDecoration(labelText: 'Título'),
  validator: Validadores.combinar(<Validador>[
    Validadores.obrigatorio('Informe um título'),
    Validadores.minimo(3), Validadores.maximo(60),
  ]),
),
// campo_conteudo: maxLines: 8, maxLength: 2000, obrigatorio + maximo(2000).
DropdownButtonFormField<Etiqueta>(
  key: const Key('campo_etiqueta'),
  initialValue: _etiqueta, // no Flutter 3.47 o parâmetro é `initialValue`, não `value`
  decoration: const InputDecoration(labelText: 'Etiqueta'),
  items: <DropdownMenuItem<Etiqueta>>[
    for (final Etiqueta etiqueta in Etiqueta.values)
      DropdownMenuItem<Etiqueta>(value: etiqueta, child: Text(etiqueta.rotulo)),
  ],
  onChanged: (Etiqueta? nova) {
    if (nova == null) return;
    setState(() => _etiqueta = nova);
  },
),
// FilledButton.icon com key: const Key('botao_salvar') e onPressed: _salvar.
```

`_perguntarSeDescarta` guarda `final NavigatorState navegador = Navigator.of(context)` **antes** do
`await showDialog<bool>` — usar o `context` depois do `await` é o que o lint
`use_build_context_synchronously` aponta — e só chama `navegador.pop()` se o usuário confirmar.

Por fim, na home, apague `_criarNotaDeTeste` e troque o FAB por
`FloatingActionButton.extended(onPressed: _abrirNovaNota, ...)`:

```dart
Future<void> _abrirNovaNota() async {
  if (_notas.length >= NotasRepositorio.maxNotas) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Limite de 200 notas: este projeto guarda tudo em um único '
            'arquivo de preferências. Exclua uma nota para criar outra.'),
      ));
    return;
  }

  final Nota? nova = await Navigator.of(context)
      .pushNamed<Nota>(Rotas.notaForm, arguments: const NotaFormArgs.criar());

  if (nova == null) return; // fechou sem salvar: o caso mais comum, não é erro
  if (!mounted) return;
  await _aplicar(<Nota>[nova, ..._notas]);
}
```

> ✅ **Como saber que funcionou:** o FAB abre a tela subindo de baixo; salvar com título de duas
> letras mostra "Use pelo menos 3 caracteres"; salvar preenchido fecha e o cartão aparece no topo.
> Digite algo e toque no X: vem "Descartar alterações?". Troque `initialRoute` por `'/nao-existe'`
> e recarregue: aparece a tela "Tela não encontrada" — depois desfaça.

---

## Etapa 7 — O detalhe, editar e excluir (≈ 35 min)

**Objetivo:** o detalhe devolve **a intenção** do usuário; quem mexe na lista continua sendo a home.

Em `presentation/nota_detalhe_screen.dart` vão três coisas: `enum AcaoDaNota { editar, excluir }`, a
classe `NotaDetalheArgs` (convenção do curso: os argumentos moram no arquivo da tela que os recebe)
e a tela. O `body` é um `ListView` — o conteúdo pode ter 2000 caracteres e precisa rolar (RF09) —
com título, `ChipEtiqueta`, conteúdo e as duas datas. Na `AppBar`, **Editar** faz
`pop(AcaoDaNota.editar)` direto; **Excluir** pergunta antes, porque é destrutivo:

```dart
Future<void> _confirmarExclusao(BuildContext context) async {
  final bool? confirmado = await showDialog<bool>(/* Cancelar / Excluir */);
  if (confirmado != true) return;
  // O diálogo é assíncrono: a tela pode ter saído da árvore nesse meio-tempo.
  if (!context.mounted) return;
  Navigator.of(context).pop(AcaoDaNota.excluir);
}
```

Registre a rota em `Rotas.gerar`, acima do `default`, com o resultado tipado:

```dart
case notaDetalhe:
  if (argumentos is! NotaDetalheArgs) return desconhecida(configuracoes);
  return MaterialPageRoute<AcaoDaNota>(
    settings: configuracoes,
    builder: (_) => NotaDetalheScreen(args: argumentos),
  );
```

E na home o toque no cartão (`aoTocar: () => _abrirNota(nota)`) finalmente faz alguma coisa:

```dart
Future<void> _abrirNota(Nota nota) async {
  final AcaoDaNota? acao = await Navigator.of(context)
      .pushNamed<AcaoDaNota>(Rotas.notaDetalhe, arguments: NotaDetalheArgs(nota: nota));
  if (!mounted) return;

  switch (acao) {
    case null:
      return; // voltou sem fazer nada (RF11)
    case AcaoDaNota.editar:
      await _editar(nota);
    case AcaoDaNota.excluir:
      await _excluir(nota);
  }
}

Future<void> _editar(Nota nota) async {
  final Nota? salva = await Navigator.of(context)
      .pushNamed<Nota>(Rotas.notaForm, arguments: NotaFormArgs.editar(nota));
  if (salva == null) return;
  if (!mounted) return;

  await _aplicar(<Nota>[
    for (final Nota atual in _notas)
      if (atual.id == salva.id) salva else atual,
  ]);
}

Future<void> _excluir(Nota nota) async =>
    _aplicar(_notas.where((Nota atual) => atual.id != nota.id).toList());
```

> ✅ **Como saber que funcionou:** tocar no cartão abre a nota inteira com as duas datas. **Editar**
> abre o formulário preenchido e, ao salvar, o cartão muda **sem** criar um segundo. **Excluir**
> pergunta antes e some com o cartão. Voltar pela seta não muda nada na lista.

---

## Etapa 8 — Filtro, ordenação e desfazer (≈ 45 min)

**Objetivo:** derivar a lista visível do estado e fechar o app com o gesto destrutivo protegido.

Acrescente ao `State` `Etiqueta? _filtro` (null = sem filtro) e
`Ordenacao _ordenacao = Ordenacao.maisRecente`, e leia a ordem gravada no `_carregar`, com
`_ordenacao = widget.repositorio.lerOrdenacao();`.

```dart
/// Filtra e ordena SEM tocar em `_notas`: a lista salva é a verdade, isto é
/// uma projeção recalculada a cada build.
List<Nota> get _visiveis {
  final Etiqueta? filtro = _filtro;
  final List<Nota> lista = filtro == null
      ? List<Nota>.of(_notas)
      : _notas.where((Nota nota) => nota.etiqueta == filtro).toList();

  lista.sort((Nota a, Nota b) => switch (_ordenacao) {
        Ordenacao.maisRecente => b.atualizadaEm.compareTo(a.atualizadaEm),
        Ordenacao.maisAntiga => a.atualizadaEm.compareTo(b.atualizadaEm),
        Ordenacao.tituloAZ => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()),
      });
  return lista;
}

Future<void> _mudarOrdenacao(Ordenacao nova) async {
  setState(() => _ordenacao = nova);
  // Persistida na hora: a escolha sobrevive ao fechamento do app (RF06).
  await widget.repositorio.salvarOrdenacao(nova);
}

void _limparFiltro() => setState(() => _filtro = null);
```

No `_corpo()`, use a projeção e trate o terceiro estado:
`final List<Nota> visiveis = _visiveis; if (visiveis.isEmpty) return
EstadoVazio.semResultado(aoLimpar: _limparFiltro);` — e o `ListView.separated` passa a iterar
`visiveis`. Os chips ficam em um `_filtros()`, com um
`SingleChildScrollView(scrollDirection: Axis.horizontal)` e um `FilterChip` por etiqueta:

```dart
onSelected: (bool _) => setState(() {
  // Tocar no chip que já está ativo zera o filtro (RF05).
  _filtro = _filtro == etiqueta ? null : etiqueta;
}),
```

O `body` vira uma `Column` dentro de `SafeArea`, com
`if (!_carregando && _notas.isNotEmpty) _filtros()` e `Expanded(child: _corpo())` — os chips só
aparecem quando existe o que filtrar. Na `AppBar`, um `PopupMenuButton<Ordenacao>` com
`icon: const Icon(Icons.sort)`, `initialValue: _ordenacao` e `onSelected: _mudarOrdenacao`.

Agora o gesto. Envolva o cartão em um `Dismissible` cuja `key` seja única e **estável** — o índice
não serve, ele muda quando um item sai:

```dart
return Dismissible(
  key: ValueKey<String>(nota.id),
  direction: DismissDirection.endToStart,
  background: DecoratedBox(/* errorContainer + lixeira à direita */),
  // Sem diálogo de confirmação: quem protege o usuário aqui é o Desfazer.
  onDismissed: (DismissDirection direcao) => _excluir(nota),
  child: CartaoNota(nota: nota, aoTocar: () => _abrirNota(nota)),
);
```

E o `_excluir` da etapa 7 cresce, ganhando um par:

```dart
Future<void> _excluir(Nota nota) async {
  // Guardada ANTES da remoção: é o que devolve a nota ao lugar exato (RF07).
  final int posicao = _notas.indexWhere((Nota atual) => atual.id == nota.id);

  await _aplicar(_notas.where((Nota atual) => atual.id != nota.id).toList());
  if (!mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // evita fila quando o usuário exclui várias seguidas
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 5),
      content: Text('"${nota.titulo}" excluída'),
      action: SnackBarAction(label: 'Desfazer', onPressed: () => _restaurar(nota, posicao)),
    ));
}

Future<void> _restaurar(Nota nota, int posicao) async {
  // O SnackBar vive no ScaffoldMessenger, acima desta tela: pode ser tocado
  // depois que a tela sair da árvore.
  if (!mounted) return;
  final List<Nota> novas = List<Nota>.of(_notas);
  // clamp protege contra a lista ter encolhido enquanto o aviso estava aberto.
  novas.insert(posicao.clamp(0, novas.length), nota);
  await _aplicar(novas);
}
```

Feche com `flutter analyze` — zero avisos é o alvo. Depois escreva os três arquivos de
[04-testes.md](04-testes.md), rode `flutter test` e percorra o [06-checklist.md](06-checklist.md)
requisito por requisito.

> ✅ **Como saber que funcionou:** o chip "Dúvida" deixa só as dúvidas e, tocado de novo, mostra
> tudo; "Título A–Z" continua valendo depois de fechar e reabrir; arrastar o cartão para a esquerda
> revela o fundo vermelho e o "Desfazer" devolve a nota **na mesma posição**.

---

## ⚠️ Se algo der errado

| Sintoma | Causa provável | Correção |
|---|---|---|
| `Target of URI doesn't exist: 'package:bloco_notas/...'` | O `name:` do `pubspec.yaml` não é `bloco_notas`, ou faltou `flutter pub get` | Corrija o `name`, rode `flutter pub get` e **reinicie** o app — hot reload não resolve |
| `Binding has not yet been initialized` ou `MissingPluginException` ao abrir | `getInstance()` antes do binding, ou app não reiniciado depois de instalar o plugin | `WidgetsFlutterBinding.ensureInitialized();` na 1ª linha do `main` e pare/rode de novo |
| `The named parameter 'value' isn't defined` no `DropdownButtonFormField` | No Flutter 3.47 o parâmetro passou a ser `initialValue` | Troque `value: _etiqueta` por `initialValue: _etiqueta` |
| Tela vermelha: `A dismissed Dismissible widget is still part of the tree` | O `onDismissed` não removeu a nota do estado, ou a `key` usa o índice | `key: ValueKey<String>(nota.id)` e `_excluir(nota)` dentro do `onDismissed` |
| `ArgumentError: id repetido na lista` ao tocar em Desfazer | A nota foi reinserida sem ter saído, ou o Desfazer foi tocado duas vezes | Remova por `id` antes de inserir e chame `hideCurrentSnackBar()` antes de cada aviso |
| Aviso `use_build_context_synchronously` no analyze | Uso do `context` depois de um `await` | `if (!mounted) return;` antes, ou guarde `Navigator.of(context)` **antes** do `await` |
| O X do formulário fecha sem avisar, ou não fecha nunca | `canPop` invertido, ou faltou o listener nos controllers | `canPop: !_temAlteracoes` e `addListener(_aoDigitar)` no `initState` |
| A nota some quando o app é fechado | `salvarNotas` não foi chamado, ou sem `await`: o `setState` só mexeu na memória | Toda mudança de lista passa por `_aplicar`: `setState` **e** `await salvarNotas` |
| Abre em "Tela não encontrada" ao tocar no cartão | O `arguments` não é do tipo esperado — passou a `Nota` em vez de `NotaDetalheArgs` | `arguments: NotaDetalheArgs(nota: nota)`; o `is!` do `gerar` está funcionando, não é bug |
| `setState() called after dispose` | `_restaurar` rodou depois que a tela saiu da árvore | `if (!mounted) return;` na primeira linha de `_restaurar` |
| A lista pisca "Nenhuma nota ainda" e só depois mostra as notas | `_carregando` começa `false` | `bool _carregando = true;` e vire para `false` só dentro do `setState` do `_carregar` |
| Editar cria uma segunda nota em vez de atualizar | O `_salvar` montou uma `Nota` nova na edição, gerando outro `id` | Na edição use `original.copyWith(...)`, que preserva `id` e `criadaEm` |

---

| # | Arquivo | Conteúdo |
|---|---|---|
| — | [README.md](README.md) | Visão geral do projeto |
| 01 | [01-especificacao.md](01-especificacao.md) | Requisitos e modelo de dados |
| 02 | **02-passo-a-passo.md** | 📍 Você está aqui |
| 03 | [03-codigo-completo.md](03-codigo-completo.md) | Todos os arquivos finais de `lib/` |
| 04 | [04-testes.md](04-testes.md) | Os três arquivos de `test/`, comentados |
| 05 | [05-desafios.md](05-desafios.md) | Extensões · [🔑 gabarito](../../gabaritos/projeto-02-desafios.md) |
| 06 | [06-checklist.md](06-checklist.md) | Critérios de "pronto" |
