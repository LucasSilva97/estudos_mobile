# Aula 5 — StatefulWidget e setState

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Definir **estado** em uma frase e reconhecer, olhando uma tela, o que é estado e o que não é.
- Escrever um `StatefulWidget` completo com a sua classe `State` correspondente.
- Explicar o que `setState()` realmente faz — e o que ele **não** faz.
- Explicar por que o Flutter separa o widget da classe de estado, em vez de guardar tudo junto.
- Decidir com critério quando um widget precisa ser `Stateful` e quando `Stateless` basta.
- Construir o contador de sessões de estudo do `meu_primeiro_app`, funcionando de verdade.
- Reconhecer, reproduzir e corrigir o erro `setState() called after dispose()`.

## ✅ Pré-requisitos

- [Aula 4 — StatelessWidget](04-statelesswidget.md), com o `CartaoMateria` funcionando.
- [Aula 3 — main, runApp e a árvore de widgets](03-main-runapp-arvore-de-widgets.md) — a ideia de
  Widget × Element × RenderObject é usada o tempo todo aqui.
- [Módulo 03 — Aula 03: Encapsulamento](../03-dart-intermediario/03-encapsulamento.md) — campos
  privados com `_`.
- [Módulo 04 — Aula 02: Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) —
  usado na seção sobre `setState` depois do `dispose`.

---

## 📖 Conceito

### O que é estado

**Estado** é qualquer informação que:

1. pode **mudar** enquanto o app está aberto, **e**
2. quando muda, **a tela precisa mudar junto**.

Os dois itens são obrigatórios. Se algo muda mas a tela não se importa, não é estado da interface.
Se a tela se importa mas o valor nunca muda, também não é.

Passe esta lista pelos dois critérios:

| Informação | É estado de tela? | Por quê |
|---|---|---|
| Número de sessões de estudo concluídas hoje | ✅ Sim | Muda ao tocar no botão, e o número na tela muda |
| Se o cronômetro está rodando ou pausado | ✅ Sim | Muda, e o ícone do botão muda junto |
| Texto digitado em um campo de busca | ✅ Sim | Muda a cada tecla, e a lista filtrada muda |
| Se um painel está expandido ou recolhido | ✅ Sim | Puramente visual, mas muda a tela |
| O nome da matéria recebido por parâmetro | ❌ Não | Vem de fora; se mudar, quem manda é o pai |
| A cor primária definida no tema | ❌ Não | É configuração, não muda sozinha |
| A constante `minutosPorSessao = 25` | ❌ Não | Nunca muda |

> 📌 Regra prática: **se você precisa de uma variável que muda e que aparece na tela, você precisa
> de estado.** Enquanto tudo vier pelo construtor, `StatelessWidget` basta.

### `StatefulWidget` e `State` — duas classes, uma ideia

Um `StatefulWidget` sempre vem em par:

```dart
// Classe 1: o WIDGET. Imutável, descartável, igual ao StatelessWidget.
class Contador extends StatefulWidget {
  const Contador({super.key, required this.passo});

  final int passo;   // final, como em qualquer widget

  @override
  State<Contador> createState() => _ContadorState();
}

// Classe 2: o ESTADO. Mutável, persistente, vive enquanto o widget estiver na árvore.
class _ContadorState extends State<Contador> {
  int _valor = 0;   // NÃO é final: é isso que muda

  void _incrementar() {
    setState(() {
      _valor += widget.passo;   // widget.passo lê o parâmetro do widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('$_valor'),
        FilledButton(
          onPressed: _incrementar,
          child: const Text('Somar'),
        ),
      ],
    );
  }
}
```

Repare em três coisas:

- O **widget** continua imutável, com campo `final`. Nada mudou em relação à aula 4.
- O **estado** fica na segunda classe, em campos privados (`_valor`), e **não** é `final`.
- O `build` mudou de lugar: ele agora mora no `State`, não no widget.
- De dentro do `State`, você acessa os parâmetros do widget por `widget.<campo>` — no exemplo,
  `widget.passo`.

### Por que duas classes? (a pergunta certa)

Parece burocracia. Não é. A razão está na
[aula 3](03-main-runapp-arvore-de-widgets.md): **widgets são descartáveis e recriados o tempo todo.**

Se o contador guardasse `_valor` dentro do próprio widget, o valor seria perdido no primeiro
`build` do pai — porque um widget novo nasceria com `_valor = 0`.

O `State` é diferente: ele é criado **uma vez**, fica pendurado no **Element** (que persiste) e
sobrevive a todas as recriações do widget.

```text
       ÁRVORE DE WIDGETS                 ÁRVORE DE ELEMENTS
       (recriada a cada build)           (persiste)

 build 1:  Contador(passo: 1)  ─────▶  StatefulElement ──┐
                                                          ├─▶ _ContadorState
 build 2:  Contador(passo: 1)  ─────▶  MESMO Element    ──┤    _valor = 7  ← sobrevive!
                                                          │
 build 3:  Contador(passo: 5)  ─────▶  MESMO Element    ──┘    _valor = 7  ← ainda lá
```

No build 3 o parâmetro `passo` mudou de 1 para 5. O `State` não foi recriado: ele apenas passa a ler
`widget.passo == 5` daí em diante. Isso é o que o método `didUpdateWidget` permite observar —
assunto da [aula 6](06-ciclo-de-vida-do-state.md).

O `State` só é destruído quando o Element sai da árvore de verdade: quando a tela é fechada, quando
o item sai de uma lista, ou quando o **tipo** do widget naquela posição muda.

### `setState()` — o que ele faz e o que não faz

```dart
setState(() {
  _valor += 1;
});
```

**O que `setState` faz:**

1. Executa a função que você passou, **imediatamente e de forma síncrona**.
2. Marca este `Element` como "sujo" (*dirty*).
3. Avisa o framework: "no próximo quadro, chame o `build` deste Element de novo".

**O que `setState` NÃO faz:**

- ❌ Não redesenha na hora. A tela só muda no próximo quadro.
- ❌ Não descobre sozinho o que mudou. Ele reconstrói o `build` **inteiro** daquele `State`.
- ❌ Não é ele que muda o valor. **Você** muda o valor dentro da função; `setState` só avisa.

Esses dois trechos mudam a variável do mesmo jeito, mas só um atualiza a tela:

```dart
// ❌ A variável muda, a tela NÃO muda. Erro clássico de iniciante.
void _incrementarErrado() {
  _valor += 1;
}

// ✅ A variável muda E o framework é avisado.
void _incrementarCerto() {
  setState(() {
    _valor += 1;
  });
}
```

**Como escrever bem:**

```dart
// ✅ Bom: só a mudança de estado dentro do setState.
Future<void> _carregar() async {
  final List<String> dados = await _repositorio.buscar();   // trabalho fora
  if (!mounted) return;                                     // checagem obrigatória
  setState(() {
    _itens = dados;                                         // só a atribuição dentro
  });
}

// ❌ Ruim: trabalho pesado ou assíncrono dentro do setState.
setState(() async {          // o callback de setState não pode ser async
  _itens = await _repositorio.buscar();
});
```

O callback de `setState` é síncrono por definição. Passar uma função `async` para ele faz a função
retornar um `Future` que ninguém espera: o `setState` termina antes de o valor chegar, e a tela
reconstrói com o valor antigo.

### Quando usar `StatefulWidget`

| Situação | Widget |
|---|---|
| Tudo vem pelo construtor | `StatelessWidget` |
| Um contador, um interruptor, um item selecionado | `StatefulWidget` |
| Um campo de texto com `TextEditingController` | `StatefulWidget` |
| Uma animação com `AnimationController` | `StatefulWidget` |
| Um `Timer`, um `StreamSubscription` | `StatefulWidget` |
| Carregar dados quando a tela abre | `StatefulWidget` (no `initState`) |
| O mesmo dado precisa aparecer em **várias telas** | nenhum dos dois: use Riverpod, [módulo 08](../08-estado-e-arquitetura/README.md) |

Esse último caso merece atenção. `setState` resolve estado **local**: aquele que nasce, vive e morre
dentro de um widget. Quando o mesmo dado precisa ser lido e alterado em telas distantes, `setState`
começa a exigir que você passe callbacks por cinco níveis de árvore — e isso é o problema que o
módulo [08 — O problema do estado](../08-estado-e-arquitetura/01-o-problema-do-estado.md) resolve.

> 📌 **Não subestime o `setState`.** Ele é a ferramenta certa para a maioria dos widgets de uma tela.
> Riverpod não substitui `setState`: ele resolve outro problema.

### O erro `setState() called after dispose()`

Este é o erro de Flutter mais reportado por iniciantes, e vale entendê-lo já.

```text
FlutterError: setState() called after dispose(): _ContadorState#a1b2c(lifecycle state: defunct,
not mounted)

This error happens if you call setState() on a State object for a widget that no longer appears
in the widget tree (e.g., whose parent widget no longer includes the widget in its build).
```

**O que aconteceu:** você iniciou algo demorado (uma requisição, um `Future.delayed`, um `Timer`), o
usuário saiu da tela antes de terminar, o `State` foi destruído — e, quando a operação finalmente
terminou, ela chamou `setState` em um objeto que não está mais na árvore.

**Como reproduzir de propósito:**

```dart
Future<void> _demorado() async {
  await Future<void>.delayed(const Duration(seconds: 5));
  setState(() {       // ❌ se o usuário sair da tela antes dos 5 s, estoura aqui
    _valor += 1;
  });
}
```

**A correção — sempre a mesma:**

```dart
Future<void> _demorado() async {
  await Future<void>.delayed(const Duration(seconds: 5));
  if (!mounted) return;   // ✅ o State ainda está na árvore?
  setState(() {
    _valor += 1;
  });
}
```

`mounted` é uma propriedade booleana que todo `State` tem. Ela vale `true` entre o `initState` e o
`dispose`, e `false` depois. A regra é simples e não tem exceção:

> **Depois de todo `await` dentro de um `State`, cheque `mounted` antes de usar `setState` ou
> `context`.**

O lint `use_build_context_synchronously`, ligado no seu `analysis_options.yaml`, já avisa parte
desses casos:

```text
info • Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check •
       use_build_context_synchronously
```

O `dispose` e o ciclo de vida completo são a [aula 6](06-ciclo-de-vida-do-state.md).

---

## 💡 Analogia

Pense em um **quadro branco em uma sala de reunião**.

- O **widget** é a **folha de instruções** que você imprime e cola na parede: "escreva o total de
  sessões no canto superior". A folha é jogada fora e reimpressa a cada reunião.
- O **`State`** é o **próprio quadro branco**: ele fica na sala, com o número escrito nele, mesmo
  que a folha de instruções seja trocada dez vezes.
- **`setState`** é **avisar o secretário** que o número mudou. Se você apagar e reescrever o número
  sem avisar ninguém, o slide projetado continua mostrando o valor antigo — foi exatamente isso que
  aconteceu no `_incrementarErrado`.
- O erro **`setState() called after dispose()`** é mandar o secretário atualizar o slide **depois de
  a sala ter sido desmontada**. A checagem `if (!mounted) return;` é perguntar "a sala ainda existe?"
  antes de falar.

---

## 🧪 Exemplo mínimo

Um interruptor de 30 linhas, com estado local:

```dart
import 'package:flutter/material.dart';

class ModoFoco extends StatefulWidget {
  const ModoFoco({super.key});

  @override
  State<ModoFoco> createState() => _ModoFocoState();
}

class _ModoFocoState extends State<ModoFoco> {
  bool _ligado = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Modo foco'),
      subtitle: Text(_ligado ? 'Notificações silenciadas' : 'Notificações ativas'),
      value: _ligado,
      onChanged: (bool novoValor) {
        setState(() {
          _ligado = novoValor;
        });
      },
    );
  }
}
```

Três detalhes que se repetem em todo `StatefulWidget`:

1. `createState()` devolve a classe de estado. Ela é sempre privada (`_`).
2. O campo `_ligado` **não** é `final`.
3. O `onChanged` recebe o valor novo pronto — você só guarda dentro de `setState`.

---

## 📱 Aplicando no Flutter

Hora de o `meu_primeiro_app` deixar de mostrar números fixos.

Você vai criar **dois** arquivos novos e reorganizar o `main.dart`:

| Arquivo | Papel |
|---|---|
| `lib/widgets/contador_sessoes.dart` | `StatefulWidget` com o contador de sessões. Guarda o próprio número e avisa quem usa através de um callback. |
| `lib/telas/home_tela.dart` | A tela, agora `StatefulWidget`, que guarda os minutos de cada matéria e reage ao contador. |
| `lib/main.dart` | Fica com **10 linhas**: só `main()` e `MaterialApp`. |

Esse desenho já ensina um padrão importante: **o widget filho guarda o estado que só interessa a
ele, e avisa o pai por callback**. É a versão simples de "elevação de estado", que você aprofunda em
[08 — Elevação de estado](../08-estado-e-arquitetura/02-elevacao-de-estado.md).

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/lib/widgets/contador_sessoes.dart`
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Contador de sessões de estudo concluídas.
///
/// Guarda o próprio número (estado local) e avisa quem o usa através do
/// callback [onMudou]. Quem usa não precisa saber como o número é controlado.
class ContadorSessoes extends StatefulWidget {
  const ContadorSessoes({
    super.key,
    this.minutosPorSessao = 25,
    this.onMudou,
  });

  /// Duração de uma sessão, em minutos. É configuração, não estado: chega
  /// pronta pelo construtor e nunca muda por conta própria.
  final int minutosPorSessao;

  /// Chamado sempre que a quantidade de sessões muda.
  /// Recebe (sessões, minutos totais).
  final void Function(int sessoes, int minutos)? onMudou;

  @override
  State<ContadorSessoes> createState() => _ContadorSessoesState();
}

class _ContadorSessoesState extends State<ContadorSessoes> {
  /// O estado. Não é final: é exatamente isto que muda.
  int _sessoes = 0;

  /// Valor derivado. Getter, para nunca ficar dessincronizado.
  int get _minutosTotais => _sessoes * widget.minutosPorSessao;

  void _alterar(int delta) {
    final int novo = _sessoes + delta;
    if (novo < 0) {
      return; // não deixa ficar negativo
    }

    setState(() {
      _sessoes = novo;
    });

    // O aviso ao pai fica FORA do setState: setState é só para mudar estado.
    widget.onMudou?.call(_sessoes, _minutosTotais);
  }

  void _zerar() {
    if (_sessoes == 0) {
      return;
    }
    setState(() {
      _sessoes = 0;
    });
    widget.onMudou?.call(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;

    return Card(
      color: cores.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: <Widget>[
            Text(
              'Sessões de hoje',
              style: tema.textTheme.titleMedium?.copyWith(
                color: cores.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_sessoes',
              style: tema.textTheme.displayLarge?.copyWith(
                color: cores.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$_minutosTotais minutos · ${widget.minutosPorSessao} min por sessão',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: cores.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton.filledTonal(
                  // onPressed nulo desabilita o botão automaticamente.
                  onPressed: _sessoes == 0 ? null : () => _alterar(-1),
                  icon: const Icon(Icons.remove),
                  tooltip: 'Remover uma sessão',
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => _alterar(1),
                  icon: const Icon(Icons.add),
                  label: const Text('Concluir sessão'),
                ),
                const SizedBox(width: 16),
                IconButton.filledTonal(
                  onPressed: _sessoes == 0 ? null : _zerar,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Zerar o dia',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

> **Arquivo:** `meu_primeiro_app/lib/telas/home_tela.dart`
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/widgets/cartao_materia.dart';
import 'package:meu_primeiro_app/widgets/contador_sessoes.dart';

/// Tela inicial do aplicativo.
///
/// Agora é StatefulWidget porque guarda dois estados que mudam com o uso:
/// os minutos acumulados por matéria e a matéria selecionada.
class HomeTela extends StatefulWidget {
  const HomeTela({super.key});

  @override
  State<HomeTela> createState() => _HomeTelaState();
}

class _HomeTelaState extends State<HomeTela> {
  /// Minutos já estudados em cada matéria. Muda quando uma sessão termina.
  final Map<String, int> _minutosPorMateria = <String, int>{
    'Dart': 95,
    'Flutter': 40,
    'Git e terminal': 20,
  };

  /// Metas fixas por matéria. Configuração, não estado — por isso é final e
  /// nunca entra em um setState.
  static const Map<String, int> _metas = <String, int>{
    'Dart': 120,
    'Flutter': 120,
    'Git e terminal': 90,
  };

  static const Map<String, IconData> _icones = <String, IconData>{
    'Dart': Icons.code,
    'Flutter': Icons.phone_android,
    'Git e terminal': Icons.terminal,
  };

  /// Matéria que vai receber os minutos da próxima sessão.
  String _materiaSelecionada = 'Dart';

  /// Total de minutos já creditados pelo contador, para não creditar duas vezes.
  int _minutosJaCreditados = 0;

  void _aoMudarContador(int sessoes, int minutosTotais) {
    final int diferenca = minutosTotais - _minutosJaCreditados;

    setState(() {
      _minutosJaCreditados = minutosTotais;
      final int atual = _minutosPorMateria[_materiaSelecionada] ?? 0;
      // clamp evita minutos negativos quando o usuário remove uma sessão.
      _minutosPorMateria[_materiaSelecionada] =
          (atual + diferenca).clamp(0, 100000);
    });
  }

  void _selecionar(String materia) {
    setState(() {
      _materiaSelecionada = materia;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('As próximas sessões contam para $materia.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final List<String> materias = _minutosPorMateria.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Primeiro App')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ContadorSessoes(onMudou: _aoMudarContador),
          const SizedBox(height: 24),
          Text('Matérias', style: tema.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Toque em uma matéria para escolher onde os minutos entram.',
            style: tema.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),

          // Um cartão para cada matéria, gerado a partir do estado.
          for (final String materia in materias) ...<Widget>[
            CartaoMateria(
              nome: materia,
              minutosEstudados: _minutosPorMateria[materia] ?? 0,
              metaMinutos: _metas[materia] ?? 60,
              icone: _icones[materia] ?? Icons.menu_book_outlined,
              onTap: () => _selecionar(materia),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 8),
          Center(
            child: Text(
              'Recebendo minutos: $_materiaSelecionada',
              style: tema.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
```

> **Arquivo:** `meu_primeiro_app/lib/main.dart`
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/telas/home_tela.dart';

void main() {
  runApp(const MeuPrimeiroApp());
}

class MeuPrimeiroApp extends StatelessWidget {
  const MeuPrimeiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Primeiro App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      home: const HomeTela(),
    );
  }
}
```

Atualize também o teste, que ainda procura textos da aula 3:

> **Arquivo:** `meu_primeiro_app/test/widget_test.dart`
> **Como executar:** `flutter test`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meu_primeiro_app/main.dart';

void main() {
  testWidgets('O contador começa em zero', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuPrimeiroApp());

    expect(find.text('Sessões de hoje'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Concluir uma sessão soma 25 minutos',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MeuPrimeiroApp());

    await tester.tap(find.text('Concluir sessão'));
    await tester.pump(); // avança um quadro: o setState é aplicado

    expect(find.text('1'), findsOneWidget);
    expect(find.textContaining('25 minutos'), findsOneWidget);
  });
}
```

Rode a sequência completa:

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `class ContadorSessoes extends StatefulWidget` | O widget continua imutável e com campos `final`. Só o `State` é mutável. |
| `State<ContadorSessoes> createState() => _ContadorSessoesState();` | O framework chama isso **uma vez**, quando o Element é criado. O tipo genérico `<ContadorSessoes>` é o que permite usar `widget.minutosPorSessao` com tipo correto. |
| `class _ContadorSessoesState extends State<ContadorSessoes>` | Classe privada: ninguém fora do arquivo precisa conhecê-la. |
| `int _sessoes = 0;` | O estado. Privado e **não** `final`. |
| `int get _minutosTotais => _sessoes * widget.minutosPorSessao;` | Valor derivado por getter. Se fosse um campo, você teria que lembrar de atualizá-lo em todo `setState` — e um dia esqueceria. |
| `widget.minutosPorSessao` | De dentro do `State`, `widget` é o objeto widget atual. Ele é **substituído** quando o pai reconstrói, e `widget.` sempre devolve o mais recente. |
| `setState(() { _sessoes = novo; });` | Só a atribuição entra aqui. Nada de rede, nada de `await`, nada de chamar callbacks. |
| `widget.onMudou?.call(...)` fora do `setState` | O callback pode fazer qualquer coisa, inclusive chamar `setState` do pai. Deixá-lo fora evita reentrância. `?.call(...)` é a forma segura de chamar uma função que pode ser nula. |
| `onPressed: _sessoes == 0 ? null : () => _alterar(-1)` | Passar `null` para `onPressed` **desabilita o botão** e o Material 3 já o pinta em cinza. Não é preciso nenhuma propriedade `enabled`. |
| `IconButton.filledTonal` | Variante do Material 3. |
| `tooltip: 'Remover uma sessão'` | Dica ao passar o mouse e, mais importante, rótulo lido por leitores de tela. Ver [13 — Acessibilidade](../13-desempenho-e-seguranca/05-acessibilidade.md). |
| `final Map<String, int> _minutosPorMateria = {...}` | O `Map` é `final` (a referência não muda), mas o **conteúdo** muda. Por isso a alteração precisa acontecer dentro de `setState`. |
| `static const Map<String, int> _metas` | `static const`: existe uma vez só para a classe inteira e nunca muda. É configuração, não estado. |
| `for (final String materia in materias) ...<Widget>[ ... ]` | **`for` dentro de uma lista de children** (*collection for*) combinado com o **operador spread** `...`, que despeja os elementos de uma lista dentro de outra. Vindo do [módulo 02, aula 08](../02-dart-basico/08-listas.md). Gera dois widgets por matéria: o cartão e o espaçador. |
| `(atual + diferenca).clamp(0, 100000)` | Impede minutos negativos ao remover sessões. |
| `_minutosJaCreditados` | Guarda quanto já foi creditado para calcular só a **diferença**. Sem isso, cada notificação somaria o total de novo. |
| `ScaffoldMessenger.of(context)` dentro de `_selecionar` | Aqui o `context` é o do `State`, que fica **abaixo** do `MaterialApp` — então funciona. A [aula 7](07-buildcontext.md) explica quando isso falha. |

**Observação de arquitetura.** Repare que `_minutosPorMateria` está no `_HomeTelaState`, e não no
contador: quem precisa do dado é a tela. E o contador não sabe o que a tela faz com o aviso. Essa
separação — estado no nível de quem precisa dele, comunicação por callback — é a base de tudo que
vem no módulo [08](../08-estado-e-arquitetura/README.md).

---

## 🤖🍎 Android × iOS

O contador expõe uma diferença concreta de **feedback ao tocar no botão**:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Botão desabilitado | fica cinza, sem ripple | fica esmaecido (opacidade reduzida) |
| Retorno tátil ao tocar | vibração curta se o usuário ativou o retorno tátil do sistema | *haptic feedback* mais discreto, controlado pelo sistema |
| `SnackBar` | é o padrão da plataforma (aparece na base da tela) | **não existe** no design da Apple; o equivalente é um alerta ou nada |

Sobre a `SnackBar`: o Flutter a desenha igualmente bem nos dois sistemas, mas ela é um elemento
**Material**. Em um app que quer parecer nativo no iPhone, o caminho é
`showCupertinoDialog` ou um aviso embutido na tela. A decisão deste curso — Material 3 como base,
adaptação pontual — está na [aula 9](09-material-e-cupertino.md).

> 🍎 **SÓ NO MAC.** Sentir o retorno tátil real exige um iPhone físico. 🪟 No Windows você pode
> escrever e testar toda a lógica de estado no Chrome; o comportamento do `setState` é **idêntico**
> em todas as plataformas, porque quem executa é a mesma VM do Dart.

---

## ⚠️ Erros comuns

**1. Mudar a variável sem `setState`.**
```dart
void _incrementar() {
  _sessoes += 1;   // ❌ a tela não muda
}
```
O valor muda na memória, o `build` nunca é chamado de novo. É o erro número 1 da categoria.

**2. Chamar `setState` dentro do `build`.**
```text
setState() or markNeedsBuild() called during build.
```
Isso cria um laço infinito: build → setState → build → setState. Se você precisa reagir a algo
quando a tela abre, use `initState` ([aula 6](06-ciclo-de-vida-do-state.md)).

**3. `setState` com callback `async`.**
```dart
setState(() async { ... });   // ❌ não faz o que você espera
```
Faça o trabalho assíncrono **antes**, cheque `mounted`, e chame `setState` só com a atribuição.

**4. `setState() called after dispose()`.**
```text
FlutterError: setState() called after dispose(): _ContadorSessoesState#4f2a1
(lifecycle state: defunct, not mounted)
```
Falta `if (!mounted) return;` depois do `await`. Esse é o erro que a [aula 6](06-ciclo-de-vida-do-state.md)
disseca por inteiro.

**5. Guardar estado no widget em vez do `State`.**
```dart
class Contador extends StatefulWidget {
  int valor = 0;   // ❌ must_be_immutable, e o valor se perde no próximo build
```

**6. Usar `StatefulWidget` por precaução.**
Se nada muda, `StatelessWidget` é mais simples, mais rápido e pode ser `const`. Trocar depois custa
dois minutos — no VS Code, o atalho `Ctrl` + `.` sobre o nome da classe oferece
"Convert to StatefulWidget".

**7. Esquecer que `setState` reconstrói o `build` inteiro.**
Se a sua tela tem 400 linhas em um `State` só, cada toque em um interruptor reconstrói tudo.
A solução é **extrair widgets** (aula 4) para que cada `setState` afete a menor subárvore possível.

**8. Confundir `widget.campo` com `_campo`.**
`widget.campo` é parâmetro vindo de fora (imutável). `_campo` é estado interno (mutável). Escrever
`minutosPorSessao` sem o `widget.` dentro do `State` dá
`Undefined name 'minutosPorSessao'`.

---

## 🛠️ Exercício guiado

**Objetivo:** provocar o erro `setState() called after dispose()` de propósito, vê-lo no console e
corrigi-lo.

**Passo 1.** Em `lib/widgets/contador_sessoes.dart`, adicione este método ao `_ContadorSessoesState`
(versão com bug, de propósito):

```dart
/// Simula uma sessão longa que termina depois de 5 segundos.
Future<void> _sessaoLenta() async {
  await Future<void>.delayed(const Duration(seconds: 5));
  setState(() {          // ⚠️ SEM checagem de mounted — é o bug
    _sessoes += 1;
  });
  widget.onMudou?.call(_sessoes, _minutosTotais);
}
```

E um botão para chamá-lo, dentro da `Row` de botões:

```dart
const SizedBox(width: 16),
IconButton.filledTonal(
  onPressed: _sessaoLenta,
  icon: const Icon(Icons.hourglass_bottom),
  tooltip: 'Sessão lenta (5 s)',
),
```

**Passo 2.** Rode `flutter run -d chrome`. Toque no botão da ampulheta e espere 5 segundos: o
contador sobe. Até aqui, tudo bem.

**Passo 3.** Agora provoque o erro. Envolva o contador em um interruptor que o remove da árvore.
Em `lib/telas/home_tela.dart`, adicione ao `_HomeTelaState`:

```dart
bool _mostrarContador = true;
```

e, no `body` do `ListView`, troque a linha do contador por:

```dart
SwitchListTile(
  title: const Text('Mostrar contador'),
  value: _mostrarContador,
  onChanged: (bool valor) => setState(() => _mostrarContador = valor),
),
if (_mostrarContador) ContadorSessoes(onMudou: _aoMudarContador),
```

**Passo 4.** Toque na ampulheta e, **antes dos 5 segundos**, desligue o interruptor. Espere. No
terminal aparece:

```text
════════ Exception caught by widgets library ═══════════════════════════════════
The following assertion was thrown while finalizing the widget tree:
setState() called after dispose(): _ContadorSessoesState#... (lifecycle state: defunct,
not mounted)
```

**Passo 5.** Corrija. Adicione a linha que faltava:

```dart
Future<void> _sessaoLenta() async {
  await Future<void>.delayed(const Duration(seconds: 5));
  if (!mounted) return;      // ✅ correção
  setState(() {
    _sessoes += 1;
  });
  widget.onMudou?.call(_sessoes, _minutosTotais);
}
```

**Passo 6.** Repita o passo 4. Nenhum erro aparece — a operação simplesmente é descartada.

**Passo 7.** Escreva em `anotacoes.md`: por que descartar o resultado é a decisão correta aqui, e em
que situação descartar seria **errado**?

**Resposta esperada:** descartar é correto porque a tela não existe mais e o resultado era apenas
visual. Seria errado se a operação precisasse **persistir** algo (gravar no banco, enviar ao
servidor): nesse caso a gravação deve acontecer de qualquer jeito, e só a atualização visual é que
deve ser condicionada ao `mounted`.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Priorize os de **Implementação** (transformar um `StatelessWidget` em `StatefulWidget`) e o de
**Correção de bugs** com `setState` esquecido.

---

## 🏆 Desafio opcional

Faça o `ContadorSessoes` aceitar um valor inicial e um limite máximo:

1. Adicione `this.sessoesIniciais = 0` e `this.limiteDiario = 12` ao construtor.
2. Inicialize `_sessoes` com `widget.sessoesIniciais`. **Atenção:** você **não pode** escrever
   `int _sessoes = widget.sessoesIniciais;` como inicializador de campo — `widget` ainda não existe
   nesse momento. Descubra onde essa inicialização deve ficar (a resposta é o primeiro método da
   [aula 6](06-ciclo-de-vida-do-state.md)).
3. Desabilite o botão "Concluir sessão" quando o limite for atingido e mostre uma `SnackBar`
   explicando.
4. Mostre uma barra de progresso do dia usando `LinearProgressIndicator`.
5. Escreva um teste de widget que toque no botão 13 vezes e verifique que o contador parou em 12.

---

## 📌 Resumo

- **Estado** é informação que muda **e** que a tela precisa refletir. Os dois critérios juntos.
- `StatefulWidget` vem sempre em par: o **widget** (imutável, `final`, descartável) e o **`State`**
  (mutável, persistente, com o `build`).
- São duas classes porque widgets são recriados o tempo todo; o `State` fica pendurado no **Element**
  e sobrevive às recriações.
- De dentro do `State`, os parâmetros do widget são lidos com `widget.<campo>`.
- `setState()` executa o callback na hora, marca o Element como sujo e agenda um `build` novo. Ele
  **não** redesenha imediatamente e **não** descobre sozinho o que mudou.
- Mudar a variável fora do `setState` altera a memória e **não** atualiza a tela.
- Faça o trabalho assíncrono **fora** do `setState`; dentro dele, só a atribuição.
- Depois de todo `await` em um `State`: **`if (!mounted) return;`** — é o que evita
  `setState() called after dispose()`.
- `setState` resolve estado **local**. Estado compartilhado entre telas é problema do
  [módulo 08](../08-estado-e-arquitetura/README.md), com Riverpod.
- Padrão do curso: o filho guarda o estado que é dele e avisa o pai por callback
  (`void Function(...)? onMudou`).

---

## ☑️ Checklist de domínio

- [ ] Defino estado em uma frase, com os dois critérios.
- [ ] Classifico corretamente cinco informações de uma tela entre "estado" e "não estado".
- [ ] Escrevo um `StatefulWidget` + `State` de memória, com `createState`.
- [ ] Explico por que o Flutter separa widget e `State`, citando a árvore de Elements.
- [ ] Sei usar `widget.campo` e digo por que não posso escrever só `campo`.
- [ ] Explico as três coisas que `setState` faz e as três que ele não faz.
- [ ] Sei por que o callback do `setState` não pode ser `async`.
- [ ] Escrevo `if (!mounted) return;` depois de todo `await` sem precisar lembrar.
- [ ] Reproduzi e corrigi o erro `setState() called after dispose()`.
- [ ] Digo três casos em que `StatefulWidget` é necessário e três em que não é.
- [ ] O contador de sessões do `meu_primeiro_app` funciona e `flutter test` passa.

---

## 📚 Referências oficiais

- [StatefulWidget class — API docs](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)
- [State class — API docs](https://api.flutter.dev/flutter/widgets/State-class.html)
- [State.setState — API docs](https://api.flutter.dev/flutter/widgets/State/setState.html)
- [Adding interactivity to your Flutter app](https://docs.flutter.dev/ui/interactivity)
- [State management — Flutter docs](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)
- [Linter rule: use_build_context_synchronously](https://dart.dev/tools/linter-rules/use_build_context_synchronously)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — StatelessWidget](04-statelesswidget.md) | [README](README.md) | [Aula 6 — Ciclo de vida do State](06-ciclo-de-vida-do-state.md) |
