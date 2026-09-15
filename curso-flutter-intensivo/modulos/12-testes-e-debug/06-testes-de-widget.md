# Aula 6 — Testes de widget

> **Módulo:** 12 - Testes e Debug · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Escrever testes com **`testWidgets`** e o **`WidgetTester`**.
- Entender a diferença entre **`pump`**, **`pump(duration)`** e **`pumpAndSettle`**.
- Encontrar widgets com os **finders** certos — e por que `find.byType` é frágil.
- Simular interação: **`tap`**, **`enterText`**, **`drag`**, **`scrollUntilVisible`**.
- Testar **formulário** e **navegação** sem rodar o app.
- Diagnosticar **o erro do Timer pendente** — o mais confuso desta aula.
- Saber o que testar em widget e o que deixar para teste unitário.

## ✅ Pré-requisitos

- [Aula 5 — Testes unitários](05-testes-unitarios.md) — **essencial**: a pirâmide, os matchers e o
  `setUp` vêm de lá.
- [Módulo 08, aula 10 — Injeção de dependências](../08-estado-e-arquitetura/10-injecao-de-dependencias.md)
  — `ProviderScope(overrides:)` em teste de widget apareceu lá.
- [Módulo 05, aula 6 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md)
  — `Timer` e `dispose`, que explicam o erro do Timer pendente.
- O projeto `foco_lab` com os testes da aula 5 passando.

---

## 📖 Conceito

### O que um teste de widget faz

```dart
testWidgets('mostra o título', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: MinhaTela()));

  expect(find.text('Matérias'), findsOneWidget);
});
```

Ele monta a árvore de widgets **em memória**, num ambiente controlado — sem emulador, sem tela,
sem sistema operacional.

| | Teste unitário | Teste de **widget** | Teste de integração |
|---|---|---|---|
| Roda | Dart puro | Árvore de widgets em memória | App real, em aparelho |
| Velocidade | ~1 ms | ~50 ms | segundos |
| Precisa de emulador | ❌ | ❌ | ✅ |
| Tem tela de verdade | ❌ | ❌ (é simulada) | ✅ |
| Tamanho da tela | — | **800 × 600** por padrão | O do aparelho |

> ⚠️ **A tela padrão do teste é 800 × 600 px.** Isso importa: um layout que funciona no seu celular
> pode estourar no teste, e vice-versa. Para testar em outro tamanho, use
> `tester.view.physicalSize`.

### `pump`: o tempo não passa sozinho

Esta é a diferença central entre um teste de widget e o app rodando:

> **No teste, o tempo não passa.** Nada acontece até você mandar acontecer.

```dart
await tester.pumpWidget(widget);   // constrói o primeiro quadro
await tester.pump();               // constrói MAIS UM quadro
await tester.pump(const Duration(seconds: 1));   // avança 1 s e constrói
await tester.pumpAndSettle();      // constrói até NADA mais mudar
```

| Método | O que faz | Use quando |
|---|---|---|
| `pumpWidget(w)` | Monta a árvore e desenha o 1º quadro | Sempre, no início |
| `pump()` | Um quadro a mais | Depois de um `setState` |
| `pump(duration)` | Avança o relógio e desenha | Animação, `Future.delayed` |
| `pumpAndSettle()` | Repete até estabilizar | Navegação, animação que termina |

O caso que confunde todo mundo:

```dart
await tester.tap(find.byType(FilledButton));
// ❌ nada mudou ainda! O tap foi registrado, mas nenhum quadro foi construído.
expect(find.text('Salvo'), findsOneWidget);   // FALHA

await tester.pump();   // ← ESTA linha constrói o quadro com a mudança
expect(find.text('Salvo'), findsOneWidget);   // ✅
```

> 📌 **A regra:** depois de **toda** interação (`tap`, `enterText`, `drag`), chame `pump`. Sem ela,
> a árvore ainda é a de antes.

E o perigo do `pumpAndSettle`:

```dart
// ⚠️ Com uma animação INFINITA (um CircularProgressIndicator eterno,
// um Timer.periodic), isto NUNCA termina.
await tester.pumpAndSettle();
```

```text
pumpAndSettle timed out
```

Quando isso acontece, use `pump(duration)` com um valor específico.

### Finders: como encontrar o widget

```dart
find.text('Salvar')                    // por texto exato
find.textContaining('Sal')             // por texto parcial
find.byType(FilledButton)              // por tipo
find.byKey(const Key('botao_salvar'))  // por chave
find.byIcon(Icons.add)                 // por ícone
find.byTooltip('Adicionar')            // por tooltip
find.byWidgetPredicate((Widget w) => w is Text && w.style?.fontSize == 24)
find.descendant(of: find.byType(Card), matching: find.text('Dart'))
find.ancestor(of: find.text('Dart'), matching: find.byType(ListTile))
```

E os matchers que acompanham:

```dart
expect(find.text('Salvar'), findsOneWidget);     // exatamente 1
expect(find.text('Salvar'), findsNothing);       // nenhum
expect(find.byType(Card), findsNWidgets(3));     // exatamente 3
expect(find.byType(Card), findsWidgets);         // 1 ou mais
expect(find.byType(Card), findsAtLeastNWidgets(2));
```

**Qual finder usar** faz diferença na robustez do teste:

| Finder | Robustez | Problema |
|---|---|---|
| `find.byKey` | ✅ **Melhor** | Exige acrescentar a `Key` |
| `find.text` | ✅ Boa | Quebra se o texto mudar (e isso é ok) |
| `find.byTooltip` | ✅ Boa | Só funciona com `tooltip` |
| `find.byIcon` | ⚠️ Média | Dois botões com o mesmo ícone |
| `find.byType` | ❌ **Frágil** | Quebra ao trocar `FilledButton` por `ElevatedButton` |

> 💡 **Use `find.byKey` para os elementos que o teste realmente precisa encontrar**, e `find.text`
> para verificar o que o usuário vê. `find.byType` é útil em widgets únicos na tela (um `Scaffold`,
> um `ListView`) e frágil no resto.

E há um erro que gera uma mensagem confusa:

```text
Bad state: Too many elements
```

Significa que o finder encontrou **mais de um** widget e o método esperava um só. A correção é
tornar o finder mais específico:

```dart
// ❌ há 3 FilledButton na tela
await tester.tap(find.byType(FilledButton));

// ✅ o primeiro
await tester.tap(find.byType(FilledButton).first);

// ✅ melhor: por chave
await tester.tap(find.byKey(const Key('botao_salvar')));
```

### Interação

```dart
await tester.tap(find.byKey(const Key('botao')));
await tester.pump();

await tester.enterText(find.byType(TextField), 'Cálculo I');
await tester.pump();

await tester.longPress(find.text('Dart'));
await tester.drag(find.byType(ListView), const Offset(0, -300));
await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);

// Rola até o widget ficar visível, e só então interage.
await tester.scrollUntilVisible(
  find.text('Item 50'),
  100,   // pixels por passo
  scrollable: find.byType(Scrollable),
);

// Fecha o teclado / tira o foco.
await tester.testTextInput.receiveAction(TextInputAction.done);
```

> ⚠️ **`tap` num widget fora da tela falha:**
>
> ```text
> The finder "…" could not find any matching widgets
> ```
>
> Ou, pior, encontra o widget mas o toque não chega nele. **Role primeiro** com
> `scrollUntilVisible`, depois toque.

### O erro do Timer pendente

Este é o erro mais confuso dos testes de widget — e o mais comum:

```text
A Timer is still pending even after the widget tree was disposed.
'package:flutter_test/src/binding.dart':
Failed assertion: line 1435 pos 12: '!timersPending'
```

**O que significa:** o teste terminou, mas há um `Timer` ainda agendado. O ambiente de teste
considera isso um erro — e com razão: um `Timer` pendente significa que algo não foi descartado.

**As três causas:**

```dart
// 1. Timer sem cancel no dispose.
class _MeuState extends State<Meu> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { … });
  }

  // ❌ faltou:
  // @override
  // void dispose() { _timer?.cancel(); super.dispose(); }
}
```

```dart
// 2. Future.delayed pendente ao fim do teste.
testWidgets('…', (WidgetTester tester) async {
  await tester.pumpWidget(widget);
  await tester.tap(find.byType(Button));   // dispara um Future.delayed(3s)
  await tester.pump();
  // ❌ o teste acaba com o Future pendente
});
```

```dart
// 3. Animação infinita.
// Um CircularProgressIndicator visível ao fim do teste.
```

**As correções:**

| Causa | Correção |
|---|---|
| Timer sem `cancel` | Corrija o **código**, não o teste |
| `Future.delayed` pendente | `await tester.pump(const Duration(seconds: 3))` para deixá-lo completar |
| Animação infinita | `await tester.pumpAndSettle()` não resolve — use `pump(duration)` e verifique antes do fim |

> 📌 **Este erro é um recurso, não um obstáculo.** Ele encontra vazamentos que você nunca notaria
> rodando o app — os mesmos que a aba Memory do DevTools (aula 3) levaria vinte minutos para
> localizar. Quando ele aparecer, a primeira hipótese deve ser "meu código está vazando", não
> "meu teste está errado".

### `tester.runAsync`

Algumas coisas não funcionam no relógio falso do teste: carregar uma imagem real, ler um arquivo,
uma chamada nativa.

```dart
await tester.runAsync(() async {
  await precacheImage(const AssetImage('assets/logo.png'), context);
});
```

Dentro de `runAsync`, o tempo corre **de verdade**. Fora dele, o tempo só avança com `pump`.

> ⚠️ Use `runAsync` só quando necessário: dentro dele você **não pode** chamar `pump`, e o teste
> fica mais lento e menos determinístico.

### O que testar em widget

| Teste em widget | Deixe para unitário |
|---|---|
| O texto certo aparece | O cálculo que gerou o texto |
| O botão fica desabilitado | A regra que decide isso |
| O erro de validação aparece | O validador em si |
| A navegação acontece | — |
| Os quatro estados de UI | A lógica de carregar |
| A interação produz a mudança | A transformação de dados |

> 💡 **A regra:** teste de widget verifica **o que o usuário vê e faz**. Se você está verificando um
> número calculado, o teste deveria ser unitário — mais rápido e mais fácil de manter.

E o que **não** testar:

| Não teste | Por quê |
|---|---|
| `padding == 16` | Quebra a cada ajuste de design |
| Cores exatas | Idem |
| Posição em pixels | Idem |
| Ordem interna da árvore | Detalhe de implementação |

---

## 💡 Analogia

Pense em testar um carro.

- **O teste unitário** testa **a peça na bancada**: o pistão aguenta a pressão?
- **O teste de widget** é o **simulador**: o painel inteiro montado numa bancada, com fiação, mas
  sem motor e sem rua. Você aperta o botão do pisca e verifica se a luz acende. Realista o
  suficiente, e roda em segundos.
- **O teste de integração** é dirigir o carro na pista.
- **O `pump`** é o detalhe que define o simulador: **o tempo não passa sozinho**. Na bancada, o
  relógio está parado. Você aperta o botão e **nada acontece** — até girar a manivela que avança um
  quadro. `pumpAndSettle` é girar a manivela até tudo parar de se mexer.
- **`pumpAndSettle` numa animação infinita** é girar a manivela esperando o pisca-alerta parar. Ele
  não para. Você gira para sempre.
- **Os finders** são como você aponta o componente: pelo **número de série** (`byKey`) é exato;
  pelo **rótulo** (`text`) é bom; pelo **tipo de peça** (`byType`) é frágil — troque o fornecedor
  do botão e o teste não acha mais.
- **O Timer pendente** é o alarme da bancada apitando: "você desligou o simulador e tem um relé
  ainda energizado". Irritante — e é justamente isso que encontra o curto-circuito que apareceria
  só depois de mil quilômetros.

---

## 🧪 Exemplo mínimo

Um formulário completo, testado do jeito certo — incluindo o Timer pendente.

> **Arquivo:** `foco_lab/lib/telas/form_materia.dart` (novo)

```dart
import 'dart:async';

import 'package:flutter/material.dart';

/// Formulário de matéria.
///
/// Repare nas `Key`: elas existem para os TESTES encontrarem os
/// elementos de forma estável. `find.byType(TextFormField)` quebraria
/// ao acrescentar um campo; `find.byKey` não.
class FormMateria extends StatefulWidget {
  const FormMateria({super.key, required this.aoSalvar});

  /// Injetado: o teste passa uma função que registra a chamada,
  /// em vez de um repositório de verdade.
  final Future<String?> Function(String nome, int meta) aoSalvar;

  @override
  State<FormMateria> createState() => _FormMateriaState();
}

class _FormMateriaState extends State<FormMateria> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _meta = TextEditingController(text: '60');

  bool _enviando = false;
  AutovalidateMode _autovalidar = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    // Cada tecla atualiza o estado do botão.
    _nome.addListener(_aoMudar);
  }

  @override
  void dispose() {
    // ⚠️ Sem estas linhas, o teste falha com
    // "A Timer is still pending" — porque os listeners e
    // controllers continuam vivos.
    _nome.removeListener(_aoMudar);
    _nome.dispose();
    _meta.dispose();
    super.dispose();
  }

  void _aoMudar() => setState(() {});

  bool get _podeSalvar => _nome.text.trim().isNotEmpty && !_enviando;

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();

    if (!_chave.currentState!.validate()) {
      setState(() => _autovalidar = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _enviando = true);

    final String? erro = await widget.aoSalvar(
      _nome.text.trim(),
      int.parse(_meta.text),
    );

    if (!mounted) return;
    setState(() => _enviando = false);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova matéria')),
      body: Form(
        key: _chave,
        autovalidateMode: _autovalidar,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            TextFormField(
              key: const Key('campo_nome'),
              controller: _nome,
              enabled: !_enviando,
              decoration: const InputDecoration(labelText: 'Nome da matéria'),
              validator: (String? v) {
                final String t = (v ?? '').trim();
                if (t.isEmpty) return 'Informe o nome da matéria';
                if (t.length < 2) return 'Use pelo menos 2 letras';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('campo_meta'),
              controller: _meta,
              enabled: !_enviando,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Meta (minutos)'),
              validator: (String? v) {
                final int? n = int.tryParse(v ?? '');
                if (n == null) return 'Informe um número';
                if (n < 5 || n > 480) return 'Entre 5 e 480 minutos';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('botao_salvar'),
              onPressed: _podeSalvar ? _salvar : null,
              child: _enviando
                  ? const SizedBox(
                      key: Key('indicador'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar matéria'),
            ),
          ],
        ),
      ),
    );
  }
}
```

> **Arquivo:** `foco_lab/test/form_materia_test.dart` (novo)
> **Como executar:** `flutter test test/form_materia_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_lab/telas/form_materia.dart';

void main() {
  /// Registra as chamadas, para o teste verificar.
  late List<({String nome, int meta})> salvos;

  /// Erro que a função de salvar devolve. Null = sucesso.
  late String? erroConfigurado;

  /// Atraso artificial, para observar o estado "enviando".
  late Duration atraso;

  setUp(() {
    salvos = <({String nome, int meta})>[];
    erroConfigurado = null;
    atraso = Duration.zero;
  });

  /// Monta a tela com a dependência injetada.
  ///
  /// Sem o MaterialApp em volta, widgets Material lançam
  /// "No Material widget found".
  Future<void> montar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormMateria(
          aoSalvar: (String nome, int meta) async {
            if (atraso > Duration.zero) {
              await Future<void>.delayed(atraso);
            }
            salvos.add((nome: nome, meta: meta));
            return erroConfigurado;
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  group('estado inicial', () {
    testWidgets('mostra os dois campos e o botão', (WidgetTester t) async {
      await montar(t);

      expect(find.byKey(const Key('campo_nome')), findsOneWidget);
      expect(find.byKey(const Key('campo_meta')), findsOneWidget);
      expect(find.text('Criar matéria'), findsOneWidget);
    });

    testWidgets('o botão começa DESABILITADO', (WidgetTester t) async {
      await montar(t);

      // `widget<T>(finder)` devolve a instância do widget, para
      // inspecionar as propriedades dele.
      final FilledButton botao =
          t.widget<FilledButton>(find.byKey(const Key('botao_salvar')));

      // onPressed null = desabilitado.
      expect(botao.onPressed, isNull);
    });

    testWidgets('a meta começa com 60', (WidgetTester t) async {
      await montar(t);

      // find.text encontra o texto DENTRO do campo.
      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('não mostra erro antes de o usuário interagir',
        (WidgetTester t) async {
      await montar(t);

      // autovalidateMode começa disabled: a tela abre LIMPA.
      expect(find.text('Informe o nome da matéria'), findsNothing);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('digitação', () {
    testWidgets('digitar o nome HABILITA o botão', (WidgetTester t) async {
      await montar(t);

      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      // ⚠️ Sem este pump, a árvore ainda é a de ANTES da digitação —
      // e o teste falharia dizendo que o botão continua desabilitado.
      await t.pump();

      final FilledButton botao =
          t.widget<FilledButton>(find.byKey(const Key('botao_salvar')));
      expect(botao.onPressed, isNotNull);
    });

    testWidgets('só espaços NÃO habilitam o botão', (WidgetTester t) async {
      await montar(t);

      await t.enterText(find.byKey(const Key('campo_nome')), '   ');
      await t.pump();

      final FilledButton botao =
          t.widget<FilledButton>(find.byKey(const Key('botao_salvar')));
      expect(botao.onPressed, isNull, reason: 'trim() deve pegar isto');
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('validação', () {
    testWidgets('nome de 1 letra mostra erro ao salvar',
        (WidgetTester t) async {
      await montar(t);

      await t.enterText(find.byKey(const Key('campo_nome')), 'A');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pump();

      expect(find.text('Use pelo menos 2 letras'), findsOneWidget);
      // E NÃO chamou a função de salvar.
      expect(salvos, isEmpty);
    });

    testWidgets('meta fora da faixa mostra erro', (WidgetTester t) async {
      await montar(t);

      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      await t.enterText(find.byKey(const Key('campo_meta')), '999');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pump();

      expect(find.text('Entre 5 e 480 minutos'), findsOneWidget);
      expect(salvos, isEmpty);
    });

    testWidgets('o erro SOME quando o usuário corrige', (WidgetTester t) async {
      await montar(t);

      // Primeira tentativa: falha e liga a autovalidação.
      await t.enterText(find.byKey(const Key('campo_nome')), 'A');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pump();
      expect(find.text('Use pelo menos 2 letras'), findsOneWidget);

      // Corrige: o erro some SEM apertar salvar de novo.
      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      await t.pump();

      expect(find.text('Use pelo menos 2 letras'), findsNothing);
    });

    testWidgets('meta vazia mostra erro', (WidgetTester t) async {
      await montar(t);

      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      await t.enterText(find.byKey(const Key('campo_meta')), '');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pump();

      expect(find.text('Informe um número'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('envio', () {
    testWidgets('salva com os valores digitados', (WidgetTester t) async {
      await montar(t);

      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo I');
      await t.enterText(find.byKey(const Key('campo_meta')), '90');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pumpAndSettle();

      expect(salvos, hasLength(1));
      expect(salvos.single.nome, 'Cálculo I');
      expect(salvos.single.meta, 90);
    });

    testWidgets('remove espaços do nome antes de salvar',
        (WidgetTester t) async {
      await montar(t);

      await t.enterText(find.byKey(const Key('campo_nome')), '  Cálculo  ');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pumpAndSettle();

      expect(salvos.single.nome, 'Cálculo');
    });

    testWidgets('mostra o indicador DURANTE o envio', (WidgetTester t) async {
      // Atraso artificial: sem ele, o envio termina no mesmo quadro
      // e não há como observar o estado intermediário.
      atraso = const Duration(seconds: 2);

      await montar(t);
      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));

      // Um pump: o quadro com _enviando = true.
      await t.pump();

      expect(find.byKey(const Key('indicador')), findsOneWidget);
      expect(find.text('Criar matéria'), findsNothing);

      // ⚠️ Se o teste terminasse AQUI, o Future.delayed de 2 s ficaria
      // pendente e o teste falharia com:
      //   "A Timer is still pending after the widget tree was disposed"
      //
      // Deixar o Future completar resolve.
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
    });

    testWidgets('o botão fica DESABILITADO durante o envio',
        (WidgetTester t) async {
      atraso = const Duration(seconds: 2);

      await montar(t);
      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pump();

      final FilledButton botao =
          t.widget<FilledButton>(find.byKey(const Key('botao_salvar')));
      expect(botao.onPressed, isNull, reason: 'impede envio duplicado');

      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
    });

    testWidgets('toque duplo NÃO salva duas vezes', (WidgetTester t) async {
      atraso = const Duration(seconds: 1);

      await montar(t);
      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      await t.pump();

      // Dois toques rápidos.
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')), warnIfMissed: false);
      await t.pump();

      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();

      // Só UMA chamada: o botão desabilitado protegeu.
      expect(salvos, hasLength(1));
    });

    testWidgets('erro do servidor aparece em SnackBar',
        (WidgetTester t) async {
      erroConfigurado = 'Já existe uma matéria com esse nome';

      await montar(t);
      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pumpAndSettle();

      expect(
        find.text('Já existe uma matéria com esse nome'),
        findsOneWidget,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('navegação', () {
    testWidgets('fecha a tela devolvendo true ao salvar',
        (WidgetTester t) async {
      bool? resultado;

      // Monta uma tela ANTERIOR, para ter para onde voltar.
      await t.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    resultado = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => FormMateria(
                          aoSalvar: (String n, int m) async {
                            salvos.add((nome: n, meta: m));
                            return null;
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      );

      await t.tap(find.text('Abrir'));
      // pumpAndSettle: a transição de tela é uma ANIMAÇÃO.
      // Um pump só mostraria a tela no meio do caminho.
      await t.pumpAndSettle();

      expect(find.text('Nova matéria'), findsOneWidget);

      await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
      await t.pump();
      await t.tap(find.byKey(const Key('botao_salvar')));
      await t.pumpAndSettle();

      // Voltou para a tela anterior…
      expect(find.text('Abrir'), findsOneWidget);
      expect(find.text('Nova matéria'), findsNothing);
      // …com o resultado.
      expect(resultado, isTrue);
    });
  });
}
```

```powershell
flutter test test/form_materia_test.dart
```

**Os três testes que mais ensinam:**

1. **"digitar o nome HABILITA o botão"** — remova o `await t.pump()` e veja o teste falhar. É a
   lição central da aula.
2. **"mostra o indicador DURANTE o envio"** — remova as duas últimas linhas e veja o erro do Timer
   pendente aparecer.
3. **"toque duplo NÃO salva duas vezes"** — verifica uma proteção real, que só aparece com atraso.

---

## 📱 Aplicando no Flutter

Agora um teste de tela completa, com os quatro estados de UI e Riverpod injetado.

---

## 💻 Código completo

> **Arquivo:** `foco_lab/test/materias_tab_test.dart` (novo)
> **Como executar:** `flutter test test/materias_tab_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_lab/dominio/materia.dart';
import 'package:foco_lab/features/materias/data/materia_repositorio.dart'
    show materiaRepositorioProvider;
import 'package:foco_lab/features/materias/domain/materia_repositorio_contrato.dart';
import 'package:foco_lab/features/materias/presentation/materias_tab.dart';

/// Repositório falso, com controle de atraso e falha.
///
/// Os três campos de controle (`atraso`, `falha`, contadores) são o
/// que permite testar TODOS os estados da tela — inclusive os que
/// nunca aconteceriam num teste manual.
class RepositorioFalso implements MateriaRepositorioContrato {
  RepositorioFalso([List<Materia>? iniciais])
      : _materias = <Materia>[...?iniciais];

  final List<Materia> _materias;

  /// Atraso artificial: sem ele, a carga termina no mesmo quadro
  /// e não há como observar o estado de carregamento.
  Duration atraso = Duration.zero;

  /// Quando não é null, toda chamada lança.
  Object? falha;

  int chamadasDeListar = 0;
  final List<String> excluidas = <String>[];

  Future<void> _preparar() async {
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);
    final Object? f = falha;
    if (f != null) throw f;
  }

  @override
  Future<List<Materia>> listar() async {
    chamadasDeListar++;
    await _preparar();
    return List<Materia>.unmodifiable(_materias);
  }

  @override
  Future<void> excluir(String id) async {
    await _preparar();
    excluidas.add(id);
    _materias.removeWhere((Materia m) => m.id == id);
  }

  @override
  Future<Materia> salvar(Materia m) async {
    await _preparar();
    _materias.add(m);
    return m;
  }
}

void main() {
  late RepositorioFalso repo;

  Materia materia(String id, String nome, {int minutos = 0}) => Materia(
        id: id,
        nome: nome,
        minutos: minutos,
        metaMinutos: 60,
        criadaEm: DateTime(2026, 3, 10),
      );

  setUp(() {
    repo = RepositorioFalso(<Materia>[
      materia('dart', 'Dart', minutos: 45),
      materia('flutter', 'Flutter', minutos: 30),
    ]);
  });

  /// Monta a tela com UM override.
  ///
  /// Este único override substitui a cadeia inteira acima do
  /// repositório — controller, providers derivados e tela.
  /// Módulo 08, aula 10.
  Future<void> montar(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          materiaRepositorioProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: MateriasTab()),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  group('os quatro estados', () {
    testWidgets('1. CARREGANDO: mostra o indicador', (WidgetTester t) async {
      repo.atraso = const Duration(seconds: 1);

      await montar(t);
      // Um pump só: o primeiro quadro, ainda carregando.
      await t.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('Dart'), findsNothing);

      // Deixa a carga terminar — senão, Timer pendente.
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
    });

    testWidgets('2. SUCESSO: mostra as matérias', (WidgetTester t) async {
      await montar(t);
      await t.pumpAndSettle();

      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('3. VAZIO: mostra a mensagem e o botão de criar',
        (WidgetTester t) async {
      repo = RepositorioFalso(<Materia>[]);

      await montar(t);
      await t.pumpAndSettle();

      expect(find.textContaining('Nenhuma'), findsOneWidget);
      // Estado vazio precisa de SAÍDA. Módulo 06, aula 12.
      expect(find.textContaining('Adicionar'), findsOneWidget);
    });

    testWidgets('4. ERRO: mostra a mensagem e "Tentar de novo"',
        (WidgetTester t) async {
      repo.falha = Exception('sem conexão');

      await montar(t);
      await t.pumpAndSettle();

      expect(find.textContaining('Tentar de novo'), findsOneWidget);
      expect(find.text('Dart'), findsNothing);
    });

    testWidgets('"Tentar de novo" REFAZ a busca', (WidgetTester t) async {
      repo.falha = Exception('sem conexão');

      await montar(t);
      await t.pumpAndSettle();

      final int antes = repo.chamadasDeListar;

      // A rede voltou.
      repo.falha = null;
      await t.tap(find.textContaining('Tentar de novo'));
      await t.pumpAndSettle();

      expect(repo.chamadasDeListar, greaterThan(antes));
      expect(find.text('Dart'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('interação', () {
    testWidgets('puxar para atualizar refaz a busca', (WidgetTester t) async {
      await montar(t);
      await t.pumpAndSettle();

      final int antes = repo.chamadasDeListar;

      // fling simula o gesto de puxar para baixo.
      // Offset positivo no Y = para baixo.
      await t.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      await t.pumpAndSettle();

      expect(repo.chamadasDeListar, greaterThan(antes));
    });

    testWidgets('arrastar exclui a matéria', (WidgetTester t) async {
      await montar(t);
      await t.pumpAndSettle();

      // Arrasta da direita para a esquerda (Offset negativo no X).
      await t.drag(find.text('Dart'), const Offset(-500, 0));
      await t.pumpAndSettle();

      // Confirma no diálogo.
      if (find.text('Excluir').evaluate().isNotEmpty) {
        await t.tap(find.text('Excluir').last);
        await t.pumpAndSettle();
      }

      expect(repo.excluidas, contains('dart'));
      expect(find.text('Dart'), findsNothing);
    });

    testWidgets('desfazer traz a matéria de volta', (WidgetTester t) async {
      await montar(t);
      await t.pumpAndSettle();

      await t.drag(find.text('Dart'), const Offset(-500, 0));
      await t.pumpAndSettle();

      if (find.text('Excluir').evaluate().isNotEmpty) {
        await t.tap(find.text('Excluir').last);
        await t.pumpAndSettle();
      }

      // O SnackBar com Desfazer.
      expect(find.text('Desfazer'), findsOneWidget);
      await t.tap(find.text('Desfazer'));
      await t.pumpAndSettle();

      expect(find.text('Dart'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('rolagem', () {
    testWidgets('encontra um item que está fora da tela',
        (WidgetTester t) async {
      repo = RepositorioFalso(<Materia>[
        for (int i = 0; i < 50; i++) materia('m$i', 'Matéria $i'),
      ]);

      await montar(t);
      await t.pumpAndSettle();

      // A tela do teste tem 800 × 600: o item 40 está muito
      // abaixo do visível.
      expect(find.text('Matéria 40'), findsNothing);

      // scrollUntilVisible rola até ele aparecer.
      await t.scrollUntilVisible(
        find.text('Matéria 40'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Matéria 40'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('tamanhos de tela', () {
    testWidgets('em tela estreita, mostra uma coluna',
        (WidgetTester t) async {
      // A tela do teste é 800 × 600 por padrão — larga o suficiente
      // para o layout de tablet. Para testar o de celular, é preciso
      // mudar o tamanho.
      t.view.physicalSize = const Size(400, 800);
      t.view.devicePixelRatio = 1.0;
      // ⚠️ addTearDown junto da mudança: sem isto, o tamanho vaza
      // para os testes seguintes.
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);

      await montar(t);
      await t.pumpAndSettle();

      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('em tela larga, mostra o trilho lateral',
        (WidgetTester t) async {
      t.view.physicalSize = const Size(1200, 800);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);

      await montar(t);
      await t.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('acessibilidade', () {
    testWidgets('todo IconButton tem tooltip', (WidgetTester t) async {
      await montar(t);
      await t.pumpAndSettle();

      // Um IconButton sem tooltip é inacessível ao leitor de tela:
      // o usuário cego ouve apenas "botão". Módulo 06, aula 10.
      final Iterable<IconButton> botoes =
          t.widgetList<IconButton>(find.byType(IconButton));

      for (final IconButton b in botoes) {
        expect(
          b.tooltip,
          isNotNull,
          reason: 'IconButton sem tooltip é inacessível',
        );
      }
    });

    testWidgets('a tela passa nas diretrizes de acessibilidade',
        (WidgetTester t) async {
      // Verificação automática do Flutter: alvo de toque mínimo,
      // contraste de cor e rótulos semânticos.
      final SemanticsHandle handle = t.ensureSemantics();

      await montar(t);
      await t.pumpAndSettle();

      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });
}
```

Rode:

```powershell
flutter test test/materias_tab_test.dart
flutter test   # a suíte inteira
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `Key('campo_nome')` nos widgets | `find.byType(TextFormField)` quebraria ao acrescentar um campo; `find.byKey` não. |
| `MaterialApp` em volta no `pumpWidget` | Sem ele, widgets Material lançam "No Material widget found". |
| `await t.pump()` depois de `enterText` | **A lição central.** Sem ele, a árvore ainda é a de antes — o teste falha dizendo que nada mudou. |
| `t.widget<FilledButton>(finder)` | Devolve a instância, para inspecionar `onPressed` e detectar o botão desabilitado. |
| `atraso` configurável no falso | Sem ele, o envio termina no mesmo quadro e não há como observar o estado intermediário. |
| `await t.pump(const Duration(seconds: 2))` no fim | Deixa o `Future.delayed` completar. Sem isso: **"A Timer is still pending"**. |
| `warnIfMissed: false` no segundo tap | O botão está desabilitado; o `tap` não acerta nada, e o aviso seria ruído. |
| Teste de toque duplo | Verifica uma proteção real contra envio duplicado, que só aparece com atraso. |
| `pumpAndSettle` na navegação | A transição de tela é **animação**. Um `pump` só mostraria a tela no meio do caminho. |
| `ProviderScope(overrides:)` com **um** override | Substitui a cadeia inteira acima do repositório. |
| `falha` configurável | Permite testar o estado de erro — o caminho que ninguém testa à mão. |
| `find.byType(Scrollable).first` no `scrollUntilVisible` | Pode haver mais de um `Scrollable`; sem o `.first`, dá "Too many elements". |
| `t.view.physicalSize` + `addTearDown(reset)` | A tela padrão é 800 × 600. **Sem o reset, o tamanho vaza** para os testes seguintes. |
| `meetsGuideline(androidTapTargetGuideline)` | Verificação automática de alvo de toque, contraste e rótulos. |
| `t.ensureSemantics()` + `handle.dispose()` | A árvore de semântica não é construída por padrão nos testes. |
| Teste "todo IconButton tem tooltip" | Uma regra do projeto virando teste: melhor que confiar na revisão de código. |

---

## ⚠️ Erros comuns

### 1. Esquecer o `pump` depois da interação

```dart
await tester.tap(find.byType(Button));
expect(find.text('Salvo'), findsOneWidget);   // ❌ a árvore é a de antes
```

**Correção:** `await tester.pump();` entre os dois.

### 2. `pumpAndSettle` com animação infinita

```text
pumpAndSettle timed out
```

Um `CircularProgressIndicator` visível nunca para.

**Correção:** `pump(duration)` com um valor específico.

### 3. Esquecer o `MaterialApp`

```text
No Material widget found. TextField widgets require a Material ancestor.
```

**Correção:** envolva em `MaterialApp(home: ...)`.

### 4. "A Timer is still pending"

O erro mais confuso da aula. Três causas: `Timer` sem `cancel`, `Future.delayed` pendente, animação
infinita.

**Correção:** primeiro suspeite do **seu código**. Depois, deixe o `Future` completar com
`pump(duration)`.

### 5. `find.byType` em widget comum

```dart
await tester.tap(find.byType(FilledButton));   // ❌ há 3 na tela
```

```text
Bad state: Too many elements
```

**Correção:** `find.byKey`, ou `.first`.

### 6. Testar `padding` e cores

```dart
expect(padding.padding, const EdgeInsets.all(16));   // ⚠️
```

Quebra a cada ajuste de design.

**Correção:** teste comportamento, não aparência exata.

### 7. `tap` em widget fora da tela

```text
The finder "…" could not find any matching widgets
```

**Correção:** `scrollUntilVisible` antes.

### 8. Não resetar `physicalSize`

O tamanho vaza para os testes seguintes, e eles falham **em ordem aleatória**.

**Correção:** `addTearDown(t.view.resetPhysicalSize)`.

### 9. Esquecer o `await` no `pump`

```dart
tester.pump();   // ❌ sem await
```

O quadro não é construído antes da verificação.

**Correção:** `await` sempre.

### 10. Testar lógica de negócio em widget

```dart
testWidgets('calcula a média corretamente', ...);   // ⚠️ 50 ms em vez de 1 ms
```

**Correção:** teste unitário.

### 11. Não injetar dependência

A tela chama o repositório real, que tenta rede.

**Correção:** `ProviderScope(overrides:)` ou parâmetro no construtor.

### 12. Um `pump` quando precisa de vários

```dart
await tester.pump();   // ⚠️ e a animação tem 3 quadros
```

**Correção:** `pumpAndSettle`, ou vários `pump(duration)`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test test/form_materia_test.dart`. Quantos passaram? Quanto tempo?

**Passo 2.** Remova o `await t.pump()` do teste "digitar o nome HABILITA o botão". Rode e leia a
falha.

**Passo 3.** No teste "mostra o indicador DURANTE o envio", remova as duas últimas linhas. Rode e
leia o erro do Timer pendente **inteiro**.

**Passo 4.** Remova o `dispose` do `_FormMateriaState`. Quais testes falham? Com qual mensagem?

**Passo 5.** Troque `find.byKey(const Key('botao_salvar'))` por `find.byType(FilledButton)`.
Acrescente um segundo botão à tela e rode.

**Passo 6.** Troque `pumpAndSettle` por `pump` no teste de navegação. O que acontece?

**Passo 7.** No teste de tela estreita, remova o `addTearDown(t.view.resetPhysicalSize)`. Rode a
suíte inteira duas vezes e observe.

**Passo 8.** Acrescente um `Timer.periodic` ao `_FormMateriaState`, sem `cancel`. Rode qualquer
teste.

**Passo 9.** Escreva um teste que verifique que a tecla Enter no campo de meta dispara o envio.
(Dica: `tester.testTextInput.receiveAction(TextInputAction.done)`.)

**Passo 10.** Rode `flutter test` com `meetsGuideline(textContrastGuideline)` numa tela com cor de
texto clara sobre fundo claro. Ele pega?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

Faça os exercícios de **Aplicação** com formulário, o de **Correção de bugs** com `pump` esquecido,
e o de **Diagnóstico** do Timer pendente.

---

## 🏆 Desafio opcional

Escreva **golden tests** (testes de captura de tela) para os quatro estados da `MateriasTab`.

Um golden test compara a renderização atual com uma imagem de referência gravada. Ele pega
regressões visuais que nenhum outro teste pega: uma cor que mudou, um espaçamento que sumiu, um
texto que passou a quebrar linha.

Requisitos:

- Um golden para cada estado: carregando, sucesso, vazio, erro.
- Um golden para tela estreita (400 px) e outro para larga (1200 px).
- Um golden em tema claro e outro em escuro.
- Gere com `flutter test --update-goldens` e **versione** as imagens.
- Um teste que falha se a fonte do sistema mudar o resultado.

Dica: `await expectLater(find.byType(MateriasTab), matchesGoldenFile('goldens/sucesso.png'))`.
Carregue uma fonte real com `loadAppFonts()` do pacote `golden_toolkit` — sem isso, o texto
aparece como retângulos.

Depois responda: por que goldens são úteis **e** frágeis ao mesmo tempo? Em que situação eles
falhariam sem que nada estivesse errado? (Dica: pense em rodar o mesmo teste no Windows e no Linux.)

---

## 📌 Resumo

- O teste de widget monta a árvore **em memória** — sem emulador, sem tela, em ~50 ms.
- A tela padrão do teste é **800 × 600 px**. Mude com `t.view.physicalSize`, e **sempre resete**.
- **No teste, o tempo não passa sozinho.** Nada acontece até você chamar `pump`.
- **Depois de toda interação, chame `pump`.** É a causa nº 1 de teste que falha sem motivo aparente.
- `pump()` = um quadro; `pump(duration)` = avança o relógio; `pumpAndSettle()` = até estabilizar.
- **`pumpAndSettle` trava com animação infinita** — use `pump(duration)`.
- Finders, do mais robusto ao mais frágil: **`byKey`** > `text` > `byTooltip` > `byIcon` >
  **`byType`**.
- `Bad state: Too many elements` = o finder achou vários. Use `byKey` ou `.first`.
- **"A Timer is still pending"** é um **recurso**: ele encontra vazamentos. Suspeite do seu código
  antes do teste.
- Injete dependências: `ProviderScope(overrides:)` ou parâmetro no construtor.
- Um falso com **`atraso` e `falha` configuráveis** permite testar todos os estados.
- Teste **o que o usuário vê e faz**; deixe cálculo e regra de negócio para o teste unitário.
- **Não teste** padding, cores, posição em pixels nem ordem interna da árvore.
- `meetsGuideline(...)` verifica **alvo de toque, contraste e rótulos** automaticamente.

---

## ☑️ Checklist de domínio

- [ ] Escrevo `testWidgets` com `pumpWidget` e `MaterialApp`.
- [ ] Chamo `pump` depois de toda interação.
- [ ] Sei a diferença entre `pump`, `pump(duration)` e `pumpAndSettle`.
- [ ] Sei por que `pumpAndSettle` trava com animação infinita.
- [ ] Uso `find.byKey` nos elementos que o teste precisa encontrar.
- [ ] Sei corrigir "Too many elements".
- [ ] Diagnostico o Timer pendente e suspeito do meu código primeiro.
- [ ] Injeto dependências nos testes de tela.
- [ ] Meus falsos têm atraso e falha configuráveis.
- [ ] Testo os quatro estados de UI.
- [ ] Reseto `physicalSize` com `addTearDown`.
- [ ] Verifico acessibilidade com `meetsGuideline`.
- [ ] Deixo cálculo e regra de negócio para o teste unitário.

---

## 📚 Referências oficiais

- [An introduction to widget testing — docs.flutter.dev](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Find widgets — docs.flutter.dev](https://docs.flutter.dev/cookbook/testing/widget/finders)
- [Tap, drag, and enter text — docs.flutter.dev](https://docs.flutter.dev/cookbook/testing/widget/tap-drag)
- [WidgetTester — api.flutter.dev](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)
- [CommonFinders — api.flutter.dev](https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html)
- [Accessibility guidelines — api.flutter.dev](https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html)
- [matchesGoldenFile — api.flutter.dev](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Testes unitários](05-testes-unitarios.md) | [README](README.md) | [Aula 7 — Mocks e fakes](07-mocks-e-fakes.md) |
