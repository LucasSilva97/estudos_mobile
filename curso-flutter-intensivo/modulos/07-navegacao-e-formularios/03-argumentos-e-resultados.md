# Aula 3 — Argumentos e resultados

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Enviar dados **para** uma tela empilhada por meio de `RouteSettings.arguments`.
- Criar uma **classe de argumentos** por rota, em vez de mandar `Map` ou `String` solta.
- Validar o argumento recebido com `args is! DetalheArgs` e **nunca** confiar em um cast cego.
- Receber **resultado** de uma tela com `await Navigator.pushNamed<T>(...)` e
  `Navigator.pop(resultado)`.
- Tipar o retorno corretamente e tratar o caso `null` — que acontece sempre que o usuário aperta
  "voltar".
- Usar `context.mounted` depois do `await` da navegação, e explicar por que **aqui** ele é
  obrigatório.
- Decidir quando passar o **objeto inteiro** e quando passar apenas o **id**.

## ✅ Pré-requisitos

- [Aula 1 — Navigator: a pilha](01-navigator-a-pilha.md) — `push`, `pop`, `MaterialPageRoute`.
- [Aula 2 — Rotas nomeadas](02-rotas-nomeadas.md) — a classe `Rotas` e o `onGenerateRoute`. Esta
  aula continua **exatamente** de onde ela parou.
- [Módulo 05, aula 7 — BuildContext](../05-introducao-ao-flutter/07-buildcontext.md) — `mounted`
  depois do `await`. Esta aula é o lugar onde isso mais dá problema.
- [Módulo 04 — Patterns e switch](../04-dart-avancado/05-patterns-e-switch.md) — o `switch` de
  `Rotas.gerar` vai crescer.
- O projeto `foco_navegacao` rodando.

---

## 📖 Conceito

### O problema

Na aula 2 você centralizou as rotas. Mas repare no que ainda não dá para fazer:

```dart
Navigator.of(context).pushNamed(Rotas.materiaDetalhe);
// … e a tela de detalhe mostra o quê? A matéria de quem?
```

A rota sabe **qual tela** abrir. Ela ainda não sabe **com qual dado**.

E o caminho de volta tem o mesmo buraco:

```dart
Navigator.of(context).pushNamed(Rotas.materiaForm);
// … o usuário salvou? cancelou? o que ele digitou?
```

Esta aula resolve os dois sentidos: **ida** (argumentos) e **volta** (resultado).

### Ida: `arguments`

O `Navigator` aceita um segundo parâmetro:

```dart
Navigator.of(context).pushNamed(
  Rotas.materiaDetalhe,
  arguments: MateriaDetalheArgs(id: materia.id, nome: materia.nome),
);
```

Esse valor viaja dentro do `RouteSettings` e chega ao `onGenerateRoute`:

```dart
static Route<dynamic> gerar(RouteSettings configuracoes) {
  final Object? args = configuracoes.arguments;   // <- aqui
  ...
}
```

O tipo é **`Object?`**. O Flutter não sabe — nem tem como saber — o que você mandou. Tratar esse
`Object?` com cuidado é o assunto central da aula.

### Por que uma classe de argumentos, e não um `Map`

A tentação:

```dart
arguments: <String, dynamic>{'id': materia.id, 'nome': materia.nome}   // ❌
```

E do outro lado:

```dart
final Map<String, dynamic> m = configuracoes.arguments! as Map<String, dynamic>;
final String id = m['id'] as String;     // erra se a chave for 'ID', 'materiaId'…
```

Problemas: o compilador não verifica **nenhum** nome de chave, nenhum tipo, e nada avisa se você
esquecer um campo. Tudo explode só em tempo de execução.

A forma certa — uma classe por rota:

```dart
/// Argumentos da rota de detalhe de matéria.
class MateriaDetalheArgs {
  const MateriaDetalheArgs({required this.id, required this.nome});

  final String id;
  final String nome;
}
```

Agora esquecer um campo **não compila**. Errar o nome **não compila**. Trocar `String` por `int`
**não compila**. O compilador virou seu revisor.

> 📌 **Convenção do curso:** a classe de argumentos mora **no mesmo arquivo da tela** que a recebe,
> com o sufixo `Args`. Quem abre a tela importa a tela e já enxerga os argumentos dela.

### Recebendo o argumento com segurança

O `onGenerateRoute` recebe `Object?`. Há duas formas de ler — uma perigosa e uma segura.

```dart
// ❌ cast cego: se vier o tipo errado, o app quebra em produção
final MateriaDetalheArgs args = configuracoes.arguments! as MateriaDetalheArgs;
```

```dart
// ✅ verifica ANTES e trata o caso errado
case materiaDetalhe:
  final Object? args = configuracoes.arguments;
  if (args is! MateriaDetalheArgs) {
    return desconhecida(configuracoes);   // cai na tela de erro amigável
  }
  return MaterialPageRoute<void>(
    settings: configuracoes,
    builder: (_) => DetalheMateriaScreen(args: args),  // aqui args JÁ é do tipo certo
  );
```

Duas coisas acontecem em `if (args is! MateriaDetalheArgs) { return ...; }`:

1. Se o argumento estiver errado (ou ausente), o app mostra a tela de rota desconhecida em vez de
   quebrar.
2. Depois do `if`, o Dart faz **promoção de tipo** (*type promotion*): dentro do resto do `case`,
   `args` **é** `MateriaDetalheArgs`, sem cast, sem `!`.

> 💡 Essa é a mesma promoção de tipo que você viu no
> [Módulo 02, null safety](../02-dart-basico/05-null-safety.md). O `is!` com `return` é o padrão
> mais limpo de todo o Dart para "valide e siga".

### A alternativa: `ModalRoute.of`

Existe outra forma de ler argumentos, **de dentro da tela**:

```dart
class DetalheMateriaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;  // ⚠️
    ...
  }
}
```

| | Ler no `onGenerateRoute` | Ler com `ModalRoute.of` |
|---|---|---|
| Validação em **um** lugar | ✅ | ❌ espalhada por cada tela |
| A tela recebe dado **tipado** no construtor | ✅ | ❌ recebe `Object?` |
| A tela é testável isoladamente | ✅ (basta construir com os args) | ❌ precisa de um `Navigator` de mentira |
| A tela funciona sem rota (ex.: painel lateral) | ✅ | ❌ |

**Decisão do curso:** validar no `onGenerateRoute` e passar pelo **construtor**. A tela nunca fica
sabendo que existe rota — o que a torna reutilizável no layout de dois painéis da
[aula 11 do Módulo 06](../06-widgets-e-layouts/11-responsividade.md).

### Volta: o resultado

`push` e `pushNamed` devolvem um `Future`. Ele completa quando a tela empilhada faz `pop`.

```dart
final bool? salvou = await Navigator.of(context).pushNamed<bool>(
  Rotas.materiaForm,
  arguments: const MateriaFormArgs.criar(),
);
```

E, do outro lado:

```dart
Navigator.of(context).pop(true);    // salvou
Navigator.of(context).pop(false);   // cancelou explicitamente
Navigator.of(context).pop();        // devolve null
```

Três pontos que **sempre** dão problema:

**1. O tipo genérico precisa combinar nos dois lados.**

```dart
// quem chama
await Navigator.of(context).pushNamed<bool>(Rotas.materiaForm);

// a rota, no onGenerateRoute
return MaterialPageRoute<bool>(...);   // <- bool, não void

// quem devolve
Navigator.of(context).pop(true);
```

Se a rota for `MaterialPageRoute<void>` e você der `pop(true)`, o valor **se perde silenciosamente**
e o `await` recebe `null`. Não há erro, não há aviso — só um bug difícil de achar.

**2. O retorno é sempre anulável.**

`pushNamed<bool>` devolve `Future<bool?>`, não `Future<bool>`. Ele é `null` quando:

- o usuário aperta **voltar** (Android) ou faz o **gesto de borda** (iOS);
- o código chama `pop()` sem argumento;
- a rota é descartada por `popUntil`.

**Sempre trate:** `if (salvou ?? false)`.

**3. Depois do `await`, o `context` pode estar morto.**

```dart
final bool? salvou = await Navigator.of(context).pushNamed<bool>(Rotas.materiaForm);

// ⚠️ entre o push e esta linha, minutos podem ter passado.
// A tela que chamou pode não existir mais.
if (!context.mounted) return;

if (salvou ?? false) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Matéria salva')),
  );
}
```

> ⚠️ **Aqui é o lugar mais importante do curso inteiro para o `mounted`.** Um `await` de rede dura
> 2 segundos; um `await` de navegação dura **o tempo que o usuário quiser**. Se ele abrir o
> formulário, deixar o celular na mesa, voltar 10 minutos depois e salvar, a tela de trás pode ter
> sido descartada pelo sistema.

### Objeto inteiro ou só o id?

Duas formas de passar a matéria para a tela de detalhe:

```dart
arguments: MateriaDetalheArgs(materia: materia)      // o objeto inteiro
arguments: MateriaDetalheArgs(id: materia.id)        // só o identificador
```

| | Objeto inteiro | Só o id |
|---|---|---|
| A tela abre instantaneamente | ✅ | ❌ precisa buscar |
| Precisa de estado de carregamento | ❌ | ✅ |
| Os dados podem ficar **desatualizados** | ⚠️ sim, se mudarem enquanto a tela está aberta | ❌ sempre frescos |
| Funciona com link externo / *deep link* | ❌ | ✅ |
| Ideal para | Listas locais, dados pequenos, protótipos | Dados de API ou banco, telas que podem ser abertas por link |

**Padrão híbrido — o melhor dos dois** e o que este curso adota:

```dart
class MateriaDetalheArgs {
  const MateriaDetalheArgs({required this.id, this.previa});

  /// Sempre presente: é a fonte da verdade para buscar o dado atualizado.
  final String id;

  /// Opcional: o que já sabemos, para desenhar a tela SEM piscar
  /// enquanto o dado completo carrega.
  final Materia? previa;
}
```

A tela desenha imediatamente com a `previa` (nome, ícone, progresso — o que a lista já tinha) e,
quando o dado completo chega, atualiza. O usuário nunca vê tela em branco, e o dado nunca fica
velho. Esse padrão volta no [Módulo 09](../09-consumo-de-api/09-api-com-riverpod.md).

---

## 💡 Analogia

Pense em mandar alguém ao cartório.

- **`pushNamed(Rotas.cartorio)`** sem argumentos é dizer só "vá ao cartório". A pessoa chega lá e
  o atendente pergunta: "certidão de quem?". Ninguém sabe.
- **`arguments: <String, dynamic>{...}`** é mandar um bilhete escrito à mão. Se você escreveu
  "nome" e o atendente procura por "nome_completo", ele devolve de mãos vazias — e **só descobre no
  balcão**, depois da viagem inteira.
- **Uma classe de argumentos** é um formulário oficial com campos impressos. Faltou preencher um
  campo obrigatório? **O formulário não é aceito na saída**, não no balcão. É o compilador
  recusando o envio.
- **`args is! MateriaDetalheArgs`** é o atendente conferindo se o documento entregue é mesmo o
  formulário certo antes de agir. Se vier um papel qualquer, ele diz educadamente "documento
  inválido" (a tela de rota desconhecida) em vez de arquivar errado.
- **O resultado do `pop`** é a pessoa voltando com a certidão. Se ela voltar de mãos vazias
  (`null`), foi porque **desistiu no meio do caminho** — o que acontece o tempo todo, e é por isso
  que você sempre trata esse caso.
- **`context.mounted`** é conferir se o seu escritório ainda está aberto quando a pessoa volta. Se
  você mandou alguém ao cartório e fechou a empresa nesse meio-tempo, não adianta ela entregar a
  certidão na porta trancada.

---

## 🧪 Exemplo mínimo

Ida e volta completas, em um arquivo só.

> **Arquivo:** `foco_navegacao/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppArgs());

/// Argumentos da tela de confirmação. Uma classe por rota.
class ConfirmacaoArgs {
  const ConfirmacaoArgs({required this.titulo, required this.pergunta});

  final String titulo;
  final String pergunta;
}

class AppArgs extends StatelessWidget {
  const AppArgs({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings configuracoes) {
        switch (configuracoes.name) {
          case '/':
            return MaterialPageRoute<void>(
              settings: configuracoes,
              builder: (_) => const TelaInicial(),
            );

          case '/confirmar':
            final Object? args = configuracoes.arguments;

            // Valide ANTES de usar. Nunca faça cast cego.
            if (args is! ConfirmacaoArgs) {
              return MaterialPageRoute<bool>(
                settings: configuracoes,
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Argumentos inválidos')),
                ),
              );
            }

            // O tipo do Route (<bool>) precisa bater com o do pushNamed<bool>.
            return MaterialPageRoute<bool>(
              settings: configuracoes,
              builder: (_) => TelaConfirmacao(args: args), // args já é tipado
            );

          default:
            return MaterialPageRoute<void>(
              settings: configuracoes,
              builder: (_) => const Scaffold(
                body: Center(child: Text('Rota desconhecida')),
              ),
            );
        }
      },
    );
  }
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  String _ultimaResposta = '—';

  Future<void> _perguntar() async {
    // pushNamed<bool> => o Future é Future<bool?>
    final bool? resposta = await Navigator.of(context).pushNamed<bool>(
      '/confirmar',
      arguments: const ConfirmacaoArgs(
        titulo: 'Excluir matéria',
        pergunta: 'Isso apaga o progresso registrado. Confirma?',
      ),
    );

    // O usuário pode ter demorado MUITO. Esta linha não é opcional.
    if (!context.mounted) return;

    setState(() {
      _ultimaResposta = switch (resposta) {
        true => 'Confirmou',
        false => 'Cancelou',
        null => 'Voltou sem responder (null)',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ida e volta')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Última resposta: $_ultimaResposta'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _perguntar,
              child: const Text('Abrir confirmação'),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaConfirmacao extends StatelessWidget {
  const TelaConfirmacao({super.key, required this.args});

  /// A tela recebe o dado TIPADO pelo construtor.
  /// Ela não sabe que existe rota — e por isso é testável sozinha.
  final ConfirmacaoArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(args.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(args.pergunta, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Aperte o botão voltar do navegador/sistema\n'
              'para ver o resultado null.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Faça os três testes:**

1. Confirmar → `Confirmou`.
2. Cancelar → `Cancelou`.
3. **Voltar pelo sistema** → `Voltou sem responder (null)`.

O terceiro é o que a maioria dos apps esquece — e é o mais comum dos três na vida real.

---

## 📱 Aplicando no Flutter

Agora o `foco_navegacao`. Até a aula 2 ele tinha três rotas sem dados. Nesta aula ele ganha:

1. Uma **tela de detalhe** que recebe a matéria pelo id, com prévia para não piscar.
2. Um **formulário** que abre em modo *criar* ou *editar* — a mesma tela, dois argumentos
   diferentes.
3. O formulário **devolve a matéria salva**, e a lista se atualiza com o resultado.
4. Tudo validado no `onGenerateRoute`, com tela de erro amigável quando o argumento vier errado.

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/features/materias/domain/materia.dart` (novo ou atualizado)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Uma matéria de estudo.
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.minutosEstudados,
    required this.metaMinutos,
    this.icone = Icons.menu_book_outlined,
  });

  final String id;
  final String nome;
  final int minutosEstudados;
  final int metaMinutos;
  final IconData icone;

  double get progresso =>
      metaMinutos == 0 ? 0 : (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  Materia copyWith({
    String? id,
    String? nome,
    int? minutosEstudados,
    int? metaMinutos,
    IconData? icone,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaMinutos: metaMinutos ?? this.metaMinutos,
      icone: icone ?? this.icone,
    );
  }
}
```

> **Arquivo:** `foco_navegacao/lib/features/materias/presentation/detalhe_materia_screen.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'package:foco_navegacao/core/rotas/rotas.dart';
import 'package:foco_navegacao/features/materias/domain/materia.dart';

/// Argumentos da rota de detalhe.
///
/// Convenção do curso: a classe de argumentos mora no arquivo da tela que a
/// recebe, com o sufixo Args.
class MateriaDetalheArgs {
  const MateriaDetalheArgs({required this.id, this.previa});

  /// Fonte da verdade. Com o id dá para buscar o dado atualizado —
  /// e um link externo consegue abrir esta tela.
  final String id;

  /// O que a lista já sabia, para a tela desenhar SEM piscar
  /// enquanto o dado completo carrega.
  final Materia? previa;
}

class DetalheMateriaScreen extends StatefulWidget {
  const DetalheMateriaScreen({super.key, required this.args});

  final MateriaDetalheArgs args;

  @override
  State<DetalheMateriaScreen> createState() => _DetalheMateriaScreenState();
}

class _DetalheMateriaScreenState extends State<DetalheMateriaScreen> {
  late Materia? _materia = widget.args.previa;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarCompleto();
  }

  /// Busca o dado atualizado pelo id. No Módulo 10 isso vira consulta ao banco.
  Future<void> _buscarCompleto() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _materia = (_materia ??
              Materia(
                id: widget.args.id,
                nome: 'Matéria ${widget.args.id}',
                minutosEstudados: 0,
                metaMinutos: 60,
              ))
          .copyWith(minutosEstudados: 95, metaMinutos: 120);
      _carregando = false;
    });
  }

  /// Abre o formulário em modo editar e usa o que ele devolver.
  Future<void> _editar() async {
    final Materia? atual = _materia;
    if (atual == null) return;

    final Materia? salva = await Navigator.of(context).pushNamed<Materia>(
      Rotas.materiaForm,
      arguments: MateriaFormArgs.editar(atual),
    );

    // O formulário pode ter ficado aberto por muito tempo.
    if (!context.mounted) return;

    // null = o usuário voltou sem salvar. Não é erro; é o caso mais comum.
    if (salva == null) return;

    setState(() => _materia = salva);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${salva.nome}" atualizada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Materia? materia = _materia;
    final TextTheme tipografia = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // Usa a prévia para o título aparecer NA HORA, sem piscar.
        title: Text(materia?.nome ?? 'Carregando…'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar matéria',
            onPressed: materia == null ? null : _editar,
          ),
        ],
      ),
      body: materia == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(materia.icone, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(materia.nome, style: tipografia.headlineSmall),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(value: materia.progresso),
                const SizedBox(height: 8),
                Text(
                  '${materia.minutosEstudados} de ${materia.metaMinutos} min '
                  '(${(materia.progresso * 100).round()}%)',
                  style: tipografia.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Enquanto o dado completo não chega, avisa sem esconder a prévia.
                if (_carregando)
                  Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text('Atualizando…', style: tipografia.bodySmall),
                    ],
                  ),
              ],
            ),
    );
  }
}
```

> **Arquivo:** `foco_navegacao/lib/features/materias/presentation/materia_form_screen.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'package:foco_navegacao/features/materias/domain/materia.dart';

/// Argumentos do formulário.
///
/// Dois construtores nomeados deixam a INTENÇÃO explícita em quem chama:
/// `MateriaFormArgs.criar()` ou `MateriaFormArgs.editar(materia)`.
class MateriaFormArgs {
  const MateriaFormArgs.criar() : original = null;

  const MateriaFormArgs.editar(Materia materia) : original = materia;

  /// null = criando; preenchido = editando.
  final Materia? original;

  bool get ehEdicao => original != null;
}

class MateriaFormScreen extends StatefulWidget {
  const MateriaFormScreen({super.key, required this.args});

  final MateriaFormArgs args;

  @override
  State<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends State<MateriaFormScreen> {
  late final TextEditingController _nome =
      TextEditingController(text: widget.args.original?.nome ?? '');

  late int _meta = widget.args.original?.metaMinutos ?? 60;

  @override
  void dispose() {
    // Todo controller criado precisa ser liberado. Módulo 05, aula 6.
    _nome.dispose();
    super.dispose();
  }

  void _salvar() {
    final String nome = _nome.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da matéria')),
      );
      return;
    }

    final Materia resultado = widget.args.original?.copyWith(
          nome: nome,
          metaMinutos: _meta,
        ) ??
        Materia(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          nome: nome,
          minutosEstudados: 0,
          metaMinutos: _meta,
        );

    // DEVOLVE o objeto. Quem chamou recebe isso no await.
    Navigator.of(context).pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args.ehEdicao ? 'Editar matéria' : 'Nova matéria'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          TextField(
            controller: _nome,
            autofocus: !widget.args.ehEdicao,
            decoration: const InputDecoration(labelText: 'Nome da matéria'),
          ),
          const SizedBox(height: 24),
          Text('Meta: $_meta minutos'),
          Slider(
            value: _meta.toDouble(),
            min: 15,
            max: 240,
            divisions: 15,
            label: '$_meta min',
            onChanged: (double v) => setState(() => _meta = v.round()),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _salvar,
            child: Text(widget.args.ehEdicao ? 'Salvar' : 'Criar'),
          ),
          const SizedBox(height: 8),
          TextButton(
            // pop() sem argumento => quem chamou recebe null.
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
```

Agora as rotas. Repare que cada `case` **valida** o argumento antes de construir a tela:

> **Arquivo:** `foco_navegacao/lib/core/rotas/rotas.dart` (atualizado)

```dart
import 'package:flutter/material.dart';

import 'package:foco_navegacao/core/rotas/rota_desconhecida_screen.dart';
import 'package:foco_navegacao/features/estatisticas/presentation/estatisticas_screen.dart';
import 'package:foco_navegacao/features/materias/domain/materia.dart';
import 'package:foco_navegacao/features/materias/presentation/detalhe_materia_screen.dart';
import 'package:foco_navegacao/features/materias/presentation/lista_materias_screen.dart';
import 'package:foco_navegacao/features/materias/presentation/materia_form_screen.dart';

abstract final class Rotas {
  static const String home = '/';
  static const String materiaDetalhe = '/materia';
  static const String materiaForm = '/materia/form';
  static const String estatisticas = '/estatisticas';

  static Route<dynamic> gerar(RouteSettings configuracoes) {
    // Lido UMA vez; cada case valida o tipo que espera.
    final Object? args = configuracoes.arguments;

    switch (configuracoes.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => const ListaMateriasScreen(),
        );

      case materiaDetalhe:
        // is! + return: valida e, depois desta linha, `args` JÁ é tipado.
        if (args is! MateriaDetalheArgs) return desconhecida(configuracoes);
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => DetalheMateriaScreen(args: args),
        );

      case materiaForm:
        if (args is! MateriaFormArgs) return desconhecida(configuracoes);
        // <Materia> porque esta rota DEVOLVE uma Materia.
        // Se fosse <void>, o pop(resultado) perderia o valor em silêncio.
        return MaterialPageRoute<Materia>(
          settings: configuracoes,
          fullscreenDialog: true,
          builder: (_) => MateriaFormScreen(args: args),
        );

      case estatisticas:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => const EstatisticasScreen(),
        );

      default:
        return desconhecida(configuracoes);
    }
  }

  static Route<dynamic> desconhecida(RouteSettings configuracoes) {
    return MaterialPageRoute<void>(
      settings: configuracoes,
      builder: (_) => RotaDesconhecidaScreen(nome: configuracoes.name),
    );
  }
}
```

E a lista, que agora abre o detalhe e recebe o resultado do formulário:

> **Arquivo:** `foco_navegacao/lib/features/materias/presentation/lista_materias_screen.dart`
> (trechos que mudam)

```dart
  /// Abre o detalhe mandando id + prévia.
  void _abrirDetalhe(Materia materia) {
    Navigator.of(context).pushNamed(
      Rotas.materiaDetalhe,
      arguments: MateriaDetalheArgs(id: materia.id, previa: materia),
    );
  }

  /// Abre o formulário em modo criar e usa o que ele devolver.
  Future<void> _criarMateria() async {
    final Materia? nova = await Navigator.of(context).pushNamed<Materia>(
      Rotas.materiaForm,
      arguments: const MateriaFormArgs.criar(),
    );

    // Obrigatório: o formulário pode ter ficado aberto por muito tempo.
    if (!context.mounted) return;

    // null = voltou sem salvar. Silêncio é a resposta certa.
    if (nova == null) return;

    setState(() => _materias = <Materia>[..._materias, nova]);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${nova.nome}" criada')),
    );
  }
```

Rode e teste os quatro caminhos:

```powershell
flutter analyze
flutter run -d chrome
```

1. Toque numa matéria → o detalhe abre **com o nome já na barra** (prévia) e atualiza depois.
2. No detalhe, toque no lápis → o formulário abre **preenchido** → salve → o detalhe atualiza.
3. Toque em "+" na lista → o formulário abre **vazio** → crie → a matéria aparece na lista.
4. Abra o formulário e aperte **voltar** → nada acontece, sem erro. `null` tratado.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `class MateriaDetalheArgs` no arquivo da tela | Convenção do curso: quem importa a tela já enxerga os argumentos dela. |
| `final String id;` + `final Materia? previa;` | Padrão híbrido: o `id` garante dado fresco e *deep link*; a `previa` evita a tela piscar. |
| `const MateriaFormArgs.criar()` / `.editar(materia)` | Construtores nomeados deixam a **intenção** explícita em quem chama. Melhor que `MateriaFormArgs(original: null)`. |
| `bool get ehEdicao => original != null;` | O resto do código pergunta pela **intenção**, não pelo `null`. |
| `if (args is! MateriaDetalheArgs) return desconhecida(...)` | Valida **e** promove o tipo. Depois desta linha, `args` é `MateriaDetalheArgs` sem cast. |
| `MaterialPageRoute<Materia>` no `case materiaForm` | O tipo da rota precisa bater com o `pushNamed<Materia>`. Com `<void>`, o `pop(resultado)` perderia o valor **em silêncio**. |
| `await Navigator.of(context).pushNamed<Materia>(...)` | Devolve `Future<Materia?>`. O `?` não é opcional: voltar pelo sistema dá `null`. |
| `if (!context.mounted) return;` logo após o `await` | O `await` de navegação dura o tempo que o usuário quiser. Sem isso, `setState` e `ScaffoldMessenger` podem explodir. |
| `if (nova == null) return;` | Tratar "voltou sem salvar" como caso normal — não como erro, não com mensagem. |
| `Navigator.of(context).pop(resultado)` | Devolve o objeto. Quem deu `await` recebe **este** valor. |
| `Navigator.of(context).pop()` no Cancelar | Sem argumento = `null`. Mesma coisa que o botão voltar do sistema — coerência é boa. |
| `late Materia? _materia = widget.args.previa;` | Inicializa com o que já se sabe. A tela nunca começa em branco. |
| `_materia == null ? CircularProgressIndicator : conteúdo` | Só mostra carregamento quando **não há prévia** — ou seja, quando a tela foi aberta por link. |
| `if (_carregando)` com indicador pequeno | Atualização em andamento **com** dados na tela: indicador discreto, nunca substituir o conteúdo. [Módulo 06, aula 12](../06-widgets-e-layouts/12-estados-de-ui.md). |
| `_nome.dispose()` | `TextEditingController` sempre precisa de `dispose`. |
| `onPressed: materia == null ? null : _editar` | Desabilita o lápis enquanto não há dado. Melhor que esconder. |

---

## 🤖🍎 Android × iOS

| Situação | 🤖 Android | 🍎 iOS |
|---|---|---|
| Como o usuário "volta sem responder" | Botão/gesto de voltar do sistema | Gesto de arrastar da borda esquerda |
| Frequência do resultado `null` | Alta | **Muito alta** — o gesto de borda é usado o tempo todo |
| Tela `fullscreenDialog: true` | Sobe de baixo, com `X` no lugar da seta | Sobe de baixo, com `Cancelar` no lugar da seta |
| Gesto de borda em `fullscreenDialog` | N/A | **Desativado** — o iOS não deixa arrastar um modal para o lado |

> 📌 A linha que mais importa: no iOS o gesto de borda torna o `null` **o caminho mais comum de
> volta**, não a exceção. Um app que só trata `true` e `false` e ignora `null` quebra
> constantemente em iPhone. É por isso que o curso insiste em `if (resultado == null) return;`.

E há uma consequência de design: como o `fullscreenDialog` **bloqueia** o gesto de borda no iOS,
formulários que o usuário não deveria abandonar por acidente devem usá-lo. Foi por isso que a
[aula 2](02-rotas-nomeadas.md) marcou `materiaForm` como `fullscreenDialog: true`.

---

## ⚠️ Erros comuns

### 1. Cast cego no argumento

```dart
final MateriaDetalheArgs args = configuracoes.arguments! as MateriaDetalheArgs; // ❌
```

```text
type 'Null' is not a subtype of type 'MateriaDetalheArgs' in type cast
```

Acontece sempre que alguém chamar a rota sem argumentos — e alguém vai.

**Correção:** `if (args is! MateriaDetalheArgs) return desconhecida(configuracoes);`

### 2. Tipo da rota diferente do tipo do `pushNamed`

```dart
// rota
return MaterialPageRoute<void>(builder: (_) => const MateriaFormScreen(...)); // ❌
// quem chama
final Materia? m = await Navigator.of(context).pushNamed<Materia>(Rotas.materiaForm);
```

Não dá erro. O `pop(materia)` simplesmente **descarta** o valor e o `await` recebe `null`. É um
dos bugs mais difíceis de achar do Flutter, porque **nada** avisa.

**Correção:** `MaterialPageRoute<Materia>`.

### 3. Esquecer que o resultado é anulável

```dart
final Materia nova = await Navigator.of(context).pushNamed<Materia>(...); // ❌ não compila
```

```text
A value of type 'Materia?' can't be assigned to a variable of type 'Materia'.
```

**Correção:** declare `Materia?` e trate o `null` com `return` cedo.

### 4. Usar `!` no resultado

```dart
final Materia nova = (await Navigator.of(context).pushNamed<Materia>(...))!; // ❌
```

Compila e quebra na primeira vez que o usuário apertar voltar.

**Correção:** `if (nova == null) return;`

### 5. Esquecer o `context.mounted` depois do `await` de navegação

```dart
final Materia? nova = await Navigator.of(context).pushNamed<Materia>(...);
setState(() => _materias.add(nova!));   // ❌ dois erros na mesma linha
```

```text
Looking up a deactivated widget's ancestor is unsafe.
```

**Correção:** `if (!context.mounted) return;` **antes** de qualquer uso do `context` ou `setState`.

> Em um `State`, `mounted` e `context.mounted` são equivalentes na prática. Use `mounted` dentro de
> um `State` e `context.mounted` em funções que só recebem o `context`.

### 6. Passar o objeto inteiro e depois estranhar que está desatualizado

```dart
arguments: MateriaDetalheArgs(materia: materia) // só o objeto, sem id
```

O usuário edita a matéria em outra tela, volta, e o detalhe continua mostrando o valor antigo —
porque ele guardou uma **cópia** do momento em que a rota foi aberta.

**Correção:** passe o `id` e busque; use a prévia só para a primeira pintura.

### 7. Ler argumentos com `ModalRoute.of` dentro do `build`

```dart
Widget build(BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as MateriaDetalheArgs; // ⚠️
```

Funciona, mas: espalha a validação por todas as telas, torna a tela **intestável** sem
`Navigator`, e quebra se a mesma tela for usada em um painel lateral (sem rota própria).

**Correção:** valide no `onGenerateRoute` e passe pelo construtor.

### 8. `Map` como argumento

```dart
arguments: <String, dynamic>{'materiaId': id} // ❌
```

Um dia alguém escreve `'materia_id'` e o bug aparece em produção.

**Correção:** classe de argumentos.

### 9. Devolver `true` de um formulário e recarregar a lista inteira

```dart
Navigator.of(context).pop(true);   // "salvou"
// e a lista faz: if (salvou) _recarregarTudoDaApi();
```

Funciona, mas gasta uma chamada de rede para saber algo que a tela **já tinha em mãos**.

**Correção:** devolva **o objeto salvo**. A lista se atualiza localmente, sem ida ao servidor.

---

## 🛠️ Exercício guiado

**Passo 1.** Acrescente uma rota `Rotas.materiaExcluir` que recebe `MateriaDetalheArgs` e mostra
uma tela de confirmação, devolvendo `bool`.

**Passo 2.** Chame-a da lista com `pushNamed<bool>` e trate os três retornos possíveis
(`true`, `false`, `null`) com um `switch`, como no exemplo mínimo.

**Passo 3.** Agora **quebre de propósito**: na rota nova, troque `MaterialPageRoute<bool>` por
`MaterialPageRoute<void>`. Rode, confirme a exclusão e observe o resultado que chega. Explique por
escrito por que o compilador **não** avisou.

**Passo 4.** Desfaça e, no lugar, troque a validação `if (args is! MateriaDetalheArgs)` por um cast
`as MateriaDetalheArgs`. Chame a rota **sem** `arguments:`. Leia o erro inteiro. Depois restaure.

**Passo 5.** No `_criarMateria`, comente a linha `if (!context.mounted) return;` e rode
`flutter analyze`. Leia o aviso do lint `use_build_context_synchronously` e anote-o.

**Passo 6.** No detalhe, remova a `previa` do argumento (mande só o `id`). Rode e observe a
diferença ao abrir a tela. Descreva em uma frase o que a prévia comprou.

**Passo 7.** Faça o formulário devolver `true` em vez do objeto, e faça a lista recarregar tudo ao
receber `true`. Compare com a versão que devolve o objeto. Qual faz menos trabalho? Qual é mais
simples de ler?

**Passo 8.** Responda por escrito: por que a `DetalheMateriaScreen` recebe `MateriaDetalheArgs` no
construtor em vez de ler `ModalRoute.of(context)`? Cite duas consequências práticas.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Faça os exercícios de **Aplicação** com classe de argumentos, o de **Correção de bugs** com o tipo
de rota trocado, e o de **Compreensão** sobre quando o resultado é `null`.

---

## 🏆 Desafio opcional

Crie um **fluxo de duas etapas**: a tela A abre a tela B, que abre a tela C, e **o resultado de C
precisa chegar até A**.

Exemplo concreto: "Nova matéria" → "Escolher ícone" → "Buscar ícone". O ícone escolhido em C deve
aparecer em A.

Requisitos:

- Nenhuma variável global e nenhum `static`.
- C devolve para B, B devolve para A — **ou** você usa `popUntil` com um resultado. Escolha uma
  estratégia e justifique.
- Se o usuário voltar de C sem escolher, B **continua aberta** com o valor anterior.
- Se o usuário voltar de B sem salvar, A não muda nada.

Depois responda: quantos `null` diferentes existem nesse fluxo, e o que cada um significa? Essa
pergunta é a razão de a aula insistir tanto neles.

---

## 📌 Resumo

- `pushNamed(rota, arguments: x)` manda dados **para** a tela; `pop(resultado)` devolve dados
  **de volta**.
- `RouteSettings.arguments` é **`Object?`**. O Flutter não valida nada — quem valida é você.
- Use uma **classe de argumentos por rota**, com sufixo `Args`, no arquivo da tela que a recebe.
  Nunca `Map`, nunca `String` solta.
- Valide com **`if (args is! TipoArgs) return desconhecida(configuracoes);`** — isso protege **e**
  promove o tipo.
- **Nunca** faça cast cego (`as TipoArgs`).
- Valide no `onGenerateRoute` e passe pelo **construtor**; não use `ModalRoute.of` dentro da tela.
- O **tipo genérico da rota** (`MaterialPageRoute<Materia>`) precisa bater com o do
  `pushNamed<Materia>`. Se não bater, o valor se perde **em silêncio**.
- O resultado é **sempre anulável**: `null` quando o usuário volta pelo sistema, faz o gesto de
  borda, ou o código chama `pop()` sem argumento.
- **Sempre** `if (!context.mounted) return;` depois de um `await` de navegação — esse `await` dura
  o tempo que o usuário quiser.
- Prefira devolver **o objeto salvo** a devolver `true`: evita uma recarga inteira.
- Passe **id + prévia opcional**: o id garante dado fresco e *deep link*; a prévia evita a tela
  piscar.
- Construtores nomeados (`.criar()`, `.editar(x)`) deixam a intenção explícita em quem chama.

---

## ☑️ Checklist de domínio

- [ ] Crio uma classe `Args` por rota e digo por que não uso `Map`.
- [ ] Valido com `is!` + `return` e explico a promoção de tipo que isso causa.
- [ ] Nunca escrevo `as TipoArgs` num argumento de rota.
- [ ] Passo os argumentos pelo **construtor** da tela, não por `ModalRoute.of`.
- [ ] Faço o tipo do `MaterialPageRoute<T>` bater com o do `pushNamed<T>`.
- [ ] Sei descrever o bug que acontece quando esses dois tipos não batem.
- [ ] Declaro o resultado como anulável e trato `null` com `return` cedo.
- [ ] Coloco `if (!context.mounted) return;` depois de **todo** `await` de navegação.
- [ ] Devolvo o objeto salvo em vez de `true`, quando isso evita uma recarga.
- [ ] Uso o padrão id + prévia e explico o que cada parte resolve.
- [ ] Meu app não quebra quando a rota é chamada sem argumentos.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Pass arguments to a named route — docs.flutter.dev](https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments)
- [Return data from a screen — docs.flutter.dev](https://docs.flutter.dev/cookbook/navigation/returning-data)
- [RouteSettings class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/RouteSettings-class.html)
- [Navigator.pushNamed — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Navigator/pushNamed.html)
- [Type promotion — dart.dev](https://dart.dev/null-safety/understanding-null-safety#type-promotion-on-null-checks)
- [use_build_context_synchronously — dart.dev](https://dart.dev/tools/linter-rules/use_build_context_synchronously)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Rotas nomeadas](02-rotas-nomeadas.md) | [README](README.md) | [Aula 4 — Abas e organização](04-abas-e-organizacao.md) |
