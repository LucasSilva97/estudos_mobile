# Aula 8 — Testes de integração

> **Módulo:** 12 - Testes e Debug · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Configurar o pacote **`integration_test`** num projeto Flutter.
- Escrever um teste que percorre **um fluxo completo** do app real.
- Rodar em **emulador Android**, **simulador iOS** e **Windows**.
- Entender por que `pumpAndSettle` se comporta diferente aqui.
- Decidir **quantos** testes de integração ter — e quais.
- Diagnosticar os erros típicos: teste instável, timeout, permissão.

## ✅ Pré-requisitos

- [Aula 6 — Testes de widget](06-testes-de-widget.md) — a API é a mesma; muda o ambiente.
- [Aula 7 — Mocks e fakes](07-mocks-e-fakes.md) — o que dublar aqui é uma decisão diferente.
- [Módulo 11, aula 5 — Conectividade](../11-recursos-nativos/05-conectividade.md) — o app real
  precisa de rede, ou de um fake para ela.
- Um emulador Android ou simulador iOS funcionando (Módulo 04).

---

## 📖 Conceito

### O topo da pirâmide

```text
        ╱╲
       ╱  ╲      integração   ← poucos, lentos, realistas
      ╱────╲
     ╱      ╲    widget       ← alguns
    ╱────────╲
   ╱          ╲  unitário     ← muitos, rápidos
  ╱────────────╲
```

| | Widget (aula 6) | **Integração** |
|---|---|---|
| Onde roda | Em memória | **No aparelho/emulador** |
| App de verdade | ❌ (um pedaço) | ✅ (o app inteiro) |
| Plugins nativos | ❌ | ✅ funcionam |
| Banco de verdade | ❌ | ✅ |
| Rede de verdade | ❌ | ✅ (se você deixar) |
| Velocidade | ~50 ms | **~10–60 s** |
| Estabilidade | Alta | **Média** |
| Comando | `flutter test` | `flutter test integration_test` |

> 📌 **A diferença essencial:** o teste de widget monta *uma árvore de widgets*. O teste de
> integração **liga o app**. Tudo funciona: `sqflite` grava em disco, `flutter_secure_storage`
> conversa com o Keystore, o `http` sai pela rede de verdade.

### Configuração

`pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:      # ← vem com o SDK, sem versão
    sdk: flutter
```

```powershell
flutter pub get
```

A estrutura de pastas:

```text
foco_lab/
├── lib/
├── test/                       ← unitário e widget
│   ├── sessao_test.dart
│   └── form_materia_test.dart
└── integration_test/           ← integração (pasta na RAIZ, não em test/)
    ├── fluxo_completo_test.dart
    └── apoio/
        └── ajudantes.dart
```

> ⚠️ A pasta é **`integration_test/`**, na raiz do projeto — **não** `test/integration/`. O
> comando `flutter test integration_test` procura ali.

O esqueleto:

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  // ⚠️ Esta linha é obrigatória e vem ANTES de qualquer teste.
  // Sem ela, os testes rodam como teste de widget comum —
  // e os plugins nativos falham com MissingPluginException.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('…', (WidgetTester tester) async {
    app.main();                      // liga o app de verdade
    await tester.pumpAndSettle();    // espera a primeira tela
    // …
  });
}
```

### Como rodar

```powershell
# Android (emulador ligado ou aparelho conectado)
flutter test integration_test

# Um arquivo só
flutter test integration_test/fluxo_completo_test.dart

# Escolhendo o aparelho
flutter devices
flutter test integration_test -d emulator-5554

# iOS (só no macOS)
flutter test integration_test -d "iPhone 16"

# Windows desktop — rápido, e pega muita coisa
flutter test integration_test -d windows
```

> 💡 **Rodar em Windows desktop é o atalho mais subestimado.** Não pega comportamento específico de
> Android ou iOS, mas roda **muito** mais rápido e pega a maioria dos erros de fluxo — ótimo para o
> ciclo de desenvolvimento, com o emulador reservado para antes do commit.

### `pumpAndSettle` aqui é diferente

No teste de widget, o tempo é falso e você controla. No teste de integração, **o tempo é real**:

```dart
// Widget test: pumpAndSettle avança o relógio FALSO.
// Integração: pumpAndSettle espera de VERDADE, e tem timeout.
await tester.pumpAndSettle(
  const Duration(milliseconds: 100),   // intervalo entre quadros
  EnginePhase.sendSemanticsUpdate,
  const Duration(seconds: 30),         // ← timeout, importante aqui
);
```

E aparece um problema novo: **a resposta pode ainda não ter chegado**.

```dart
// ❌ Instável: se a rede demorar 2 s, pumpAndSettle já terminou
//    (a tela ficou parada no estado de carregando) e o find falha.
await tester.tap(find.byKey(const Key('entrar')));
await tester.pumpAndSettle();
expect(find.text('Bem-vindo'), findsOneWidget);
```

A correção é esperar pela **condição**, não por um tempo:

```dart
/// Espera até o widget aparecer, ou falha com uma mensagem útil.
Future<void> esperarPor(
  WidgetTester tester,
  Finder alvo, {
  Duration limite = const Duration(seconds: 15),
}) async {
  final DateTime fim = DateTime.now().add(limite);

  while (DateTime.now().isBefore(fim)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (alvo.evaluate().isNotEmpty) return;
  }

  fail('Não apareceu em ${limite.inSeconds}s: ${alvo.description}');
}
```

> 📌 **Esta função de ~12 linhas é o que separa uma suíte de integração confiável de uma que falha
> uma vez a cada cinco execuções.** Escreva-a no primeiro dia.

### Rede de verdade ou falsa?

A decisão mais importante desta aula.

| | Rede real | Rede falsa |
|---|---|---|
| Realismo | ✅ Total | ⚠️ Parcial |
| Estabilidade | ❌ Falha sem internet | ✅ |
| Velocidade | ⚠️ Lenta | ✅ |
| Testa cenário de erro | ❌ Difícil | ✅ Fácil |
| Polui dados reais | ⚠️ Sim | ❌ |

> 💡 **A recomendação:** **falsifique a rede** na maioria dos testes de integração, com um
> `ProviderScope(overrides:)` no `main` de teste. O que você está testando é **o fluxo do app** —
> telas, navegação, banco, persistência —, não se o servidor está no ar. Guarde um ou dois testes
> com rede real, rodados separadamente, como "smoke test".

Isso exige que o `main` do app aceite overrides:

```dart
// lib/main.dart
void main() => rodarApp();

/// Ponto de entrada parametrizável — o teste passa os overrides.
void rodarApp({List<Override> overrides = const <Override>[]}) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(overrides: overrides, child: const FocoApp()));
}
```

### Quantos ter?

| Quantidade | Veredito |
|---|---|
| 0 | ⚠️ Nenhuma garantia de que o app **liga** |
| **3 a 8** | ✅ O ponto certo para um app pequeno |
| 30+ | ❌ A suíte demora 20 min e ninguém roda |

Os que valem a pena:

1. **O app abre** — parece bobo; pega erro de inicialização de plugin, que nenhum outro teste pega.
2. **O caminho feliz principal** — criar matéria → registrar sessão → ver no resumo.
3. **Persistência entre sessões** — criou, fechou, abriu, ainda está lá.
4. **Login/logout** — se houver.
5. **Offline** — o app funciona sem rede?

O que **não** vale:

| Não faça em integração | Faça em |
|---|---|
| Cada validação de formulário | Widget |
| Cada regra de negócio | Unitário |
| Cada estado de erro | Widget |
| Cada tela isoladamente | Widget |

### Testes instáveis (*flaky*)

Um teste que passa às vezes é **pior que nenhum teste**: ele treina a equipe a ignorar falhas.

| Causa | Correção |
|---|---|
| `pumpAndSettle` com rede real | `esperarPor(condição)` |
| Animação ainda rodando | `esperarPor`, não `pump` fixo |
| Estado do teste anterior | Limpar banco no `setUp` |
| Ordem dos testes | Cada teste independente |
| Teclado cobrindo o botão | `tester.testTextInput.receiveAction(...)` |
| Emulador lento | Aumentar o limite; não remover a espera |

> ⚠️ **Nunca "conserte" um teste instável com `await Future.delayed(Duration(seconds: 5))`.** Isso
> deixa a suíte lenta e o teste continua instável — só que menos vezes. Espere pela **condição**.

### Capturar tela

```dart
// Requer o driver; veja a documentação para a configuração completa.
await binding.takeScreenshot('apos-login');
```

Útil para ver **o que estava na tela** quando o teste falhou no CI, onde você não tem como olhar.

---

## 💡 Analogia

Voltando ao carro do módulo:

- **Unitário** testa a peça na bancada.
- **Widget** é o simulador: painel montado, sem motor, sem rua.
- **Integração** é **dirigir o carro na pista de testes**. Motor de verdade, combustível de
  verdade, asfalto de verdade. Você descobre coisas que nenhuma bancada mostra — o barulho no
  câmbio, o cheiro de queimado.

E daí saem as três lições:

- **Você não dirige mil voltas.** Faz três ou quatro percursos completos que cobrem o essencial:
  arrancada, curva, freio, marcha à ré. Testar cada parafuso na pista seria absurdo — para isso
  existe a bancada.
- **Chuva na pista** é a rede real: realista, e faz o teste falhar por motivo que não é o carro.
  Por isso a maioria dos percursos é feita em pista coberta — e um ou dois, ao ar livre, de
  propósito.
- **"Espere pela condição, não pelo relógio"** é a diferença entre "acelere por 10 segundos" e
  "acelere até 100 km/h". No dia frio, os 10 segundos não chegam aos 100 — e o teste falha sem que
  nada esteja errado com o carro.

---

## 🧪 Exemplo mínimo

> **Arquivo:** `foco_lab/integration_test/abre_o_app_test.dart` (novo)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:foco_lab/main.dart' as app;

void main() {
  // Obrigatório, e ANTES de qualquer teste.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('o app abre sem erro', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Parece bobo — e é o teste que mais pega erro de verdade:
    // plugin mal configurado, banco que não abre, permissão faltando.
    // Nada disso aparece num teste de widget.
    expect(find.text('Foco'), findsOneWidget);
  });
}
```

```powershell
flutter test integration_test/abre_o_app_test.dart -d windows
```

---

## 📱 Aplicando no Flutter

Agora o fluxo completo: criar matéria → registrar sessão → conferir o resumo → fechar e reabrir.

---

## 💻 Código completo

> **Arquivo:** `foco_lab/integration_test/apoio/ajudantes.dart` (novo)

```dart
import 'package:flutter_test/flutter_test.dart';

/// Espera até o widget aparecer — em vez de esperar um tempo fixo.
///
/// É a função mais importante de uma suíte de integração. Sem ela,
/// os testes ficam instáveis: passam na sua máquina e falham no CI,
/// onde o emulador é mais lento.
Future<void> esperarPor(
  WidgetTester tester,
  Finder alvo, {
  Duration limite = const Duration(seconds: 15),
  Duration intervalo = const Duration(milliseconds: 100),
}) async {
  final DateTime fim = DateTime.now().add(limite);

  while (DateTime.now().isBefore(fim)) {
    await tester.pump(intervalo);
    if (alvo.evaluate().isNotEmpty) return;
  }

  // `fail` com mensagem útil: sem isto, o erro seria só
  // "could not find any matching widgets", sem dizer o que faltou.
  fail(
    'Não apareceu em ${limite.inSeconds}s: ${alvo.description}\n'
    'Dica: a tela pode ter ficado em carregando ou em erro.',
  );
}

/// Espera o widget SUMIR — para indicadores de carregamento.
Future<void> esperarSumir(
  WidgetTester tester,
  Finder alvo, {
  Duration limite = const Duration(seconds: 15),
}) async {
  final DateTime fim = DateTime.now().add(limite);

  while (DateTime.now().isBefore(fim)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (alvo.evaluate().isEmpty) return;
  }

  fail('Não sumiu em ${limite.inSeconds}s: ${alvo.description}');
}

/// Toca rolando até o alvo, se preciso.
///
/// Num emulador de tela pequena, o botão pode estar fora da área
/// visível — e `tap` falharia.
Future<void> tocarComRolagem(WidgetTester tester, Finder alvo) async {
  if (alvo.evaluate().isEmpty) {
    await tester.scrollUntilVisible(alvo, 150);
  }
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

/// Digita e fecha o teclado.
///
/// O teclado aberto cobre a parte de baixo da tela — e é a causa
/// nº 1 de "o tap não acertou nada" em teste de integração.
Future<void> digitar(
  WidgetTester tester,
  Finder campo,
  String texto,
) async {
  await tester.ensureVisible(campo);
  await tester.tap(campo);
  await tester.pumpAndSettle();
  await tester.enterText(campo, texto);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
```

> **Arquivo:** `foco_lab/integration_test/fluxo_completo_test.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:foco_lab/core/banco/banco_foco.dart';
import 'package:foco_lab/main.dart' as app;

import 'apoio/ajudantes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // ⚠️ O banco é REAL e persiste entre execuções. Sem limpar,
    // o segundo teste encontra os dados do primeiro — e a suíte
    // passa na primeira rodada e falha na segunda.
    await BancoFoco.instancia.apagarTudo();
  });

  // ══════════════════════════════════════════════════════════════════
  testWidgets('fluxo completo: criar matéria, estudar e ver o resumo',
      (WidgetTester tester) async {
    // A rede é falsificada: o que se testa aqui é o FLUXO do app,
    // não se o servidor está no ar.
    app.rodarApp(overrides: <Override>[
      // (Os overrides do projeto; veja Módulo 08, aula 10.)
    ]);
    await tester.pumpAndSettle();

    // ── 1. A lista começa vazia ──────────────────────────────────
    await esperarPor(tester, find.textContaining('Nenhuma'));

    // ── 2. Criar uma matéria ─────────────────────────────────────
    await tocarComRolagem(tester, find.byKey(const Key('fab_nova_materia')));
    await esperarPor(tester, find.text('Nova matéria'));

    await digitar(tester, find.byKey(const Key('campo_nome')), 'Cálculo I');
    await digitar(tester, find.byKey(const Key('campo_meta')), '90');
    await tocarComRolagem(tester, find.byKey(const Key('botao_salvar')));

    // Voltou para a lista, com a matéria nova.
    await esperarPor(tester, find.text('Cálculo I'));
    expect(find.textContaining('Nenhuma'), findsNothing);

    // ── 3. Registrar uma sessão ──────────────────────────────────
    await tocarComRolagem(tester, find.text('Cálculo I'));
    await esperarPor(tester, find.byKey(const Key('detalhe_materia')));

    await tocarComRolagem(tester, find.byKey(const Key('botao_nova_sessao')));
    await digitar(tester, find.byKey(const Key('campo_minutos')), '45');
    await tocarComRolagem(tester, find.byKey(const Key('botao_registrar')));

    // ── 4. O total foi atualizado ────────────────────────────────
    await esperarPor(tester, find.textContaining('45'));

    // ── 5. O resumo reflete a sessão ─────────────────────────────
    await tocarComRolagem(tester, find.byIcon(Icons.arrow_back));
    await tocarComRolagem(tester, find.byKey(const Key('aba_resumo')));

    await esperarPor(tester, find.textContaining('45 min'));
    // 45 de 90: metade da meta.
    expect(find.textContaining('50%'), findsOneWidget);
  });

  // ══════════════════════════════════════════════════════════════════
  testWidgets('os dados sobrevivem a fechar e reabrir o app',
      (WidgetTester tester) async {
    // ── Primeira "execução" ──────────────────────────────────────
    app.rodarApp();
    await tester.pumpAndSettle();

    await tocarComRolagem(tester, find.byKey(const Key('fab_nova_materia')));
    await digitar(tester, find.byKey(const Key('campo_nome')), 'Física II');
    await tocarComRolagem(tester, find.byKey(const Key('botao_salvar')));
    await esperarPor(tester, find.text('Física II'));

    // ── Simula fechar e reabrir ──────────────────────────────────
    // pumpWidget com outro widget descarta a árvore inteira,
    // como se o app tivesse sido fechado. O BANCO continua lá.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    app.rodarApp();
    await tester.pumpAndSettle();

    // Este teste é a razão de existir da suíte de integração:
    // nenhum teste de widget consegue verificar isto, porque
    // nenhum teste de widget tem banco de verdade.
    await esperarPor(tester, find.text('Física II'));
  });

  // ══════════════════════════════════════════════════════════════════
  testWidgets('excluir remove de verdade — inclusive depois de reabrir',
      (WidgetTester tester) async {
    app.rodarApp();
    await tester.pumpAndSettle();

    await tocarComRolagem(tester, find.byKey(const Key('fab_nova_materia')));
    await digitar(tester, find.byKey(const Key('campo_nome')), 'Química');
    await tocarComRolagem(tester, find.byKey(const Key('botao_salvar')));
    await esperarPor(tester, find.text('Química'));

    // Arrasta para excluir.
    await tester.drag(find.text('Química'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    if (find.text('Excluir').evaluate().isNotEmpty) {
      await tocarComRolagem(tester, find.text('Excluir').last);
    }

    await esperarSumir(tester, find.text('Química'));

    // Reabre: continua excluída.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    app.rodarApp();
    await tester.pumpAndSettle();

    await esperarPor(tester, find.textContaining('Nenhuma'));
    expect(find.text('Química'), findsNothing);
  });

  // ══════════════════════════════════════════════════════════════════
  testWidgets('o app funciona sem rede', (WidgetTester tester) async {
    app.rodarApp(overrides: <Override>[
      // Override que simula "sem conexão".
      // (O provider de conectividade do Módulo 11, aula 5.)
    ]);
    await tester.pumpAndSettle();

    // O aviso de offline aparece…
    await esperarPor(tester, find.textContaining('offline'));

    // …mas o app continua USÁVEL: criar matéria funciona local.
    await tocarComRolagem(tester, find.byKey(const Key('fab_nova_materia')));
    await digitar(tester, find.byKey(const Key('campo_nome')), 'Offline');
    await tocarComRolagem(tester, find.byKey(const Key('botao_salvar')));

    await esperarPor(tester, find.text('Offline'));
  });

  // ══════════════════════════════════════════════════════════════════
  testWidgets('o botão voltar do Android não fecha o app na aba 2',
      (WidgetTester tester) async {
    // Comportamento que SÓ dá para testar com o app real.
    // Módulo 11, aula 8.
    app.rodarApp();
    await tester.pumpAndSettle();

    await tocarComRolagem(tester, find.byKey(const Key('aba_resumo')));
    await tester.pumpAndSettle();

    // Simula o botão voltar do sistema.
    final ByteData mensagem =
        const JSONMethodCodec().encodeMethodCall(
      const MethodCall('popRoute'),
    );
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      mensagem,
      (_) {},
    );
    await tester.pumpAndSettle();

    // Voltou para a aba 1, não fechou o app.
    expect(find.byKey(const Key('aba_materias_ativa')), findsOneWidget);
  });
}
```

Rode:

```powershell
# rápido, durante o desenvolvimento
flutter test integration_test -d windows

# antes do commit
flutter test integration_test -d emulator-5554
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` | **Obrigatório**, antes de tudo. Sem ele, plugins nativos dão `MissingPluginException`. |
| `app.main()` / `app.rodarApp()` | Liga o app **de verdade** — não uma árvore montada à mão. |
| `esperarPor` | Espera pela **condição**, não pelo relógio. A função mais importante da suíte. |
| `fail('Não apareceu em …')` | Sem isso, o erro seria "could not find any matching widgets", sem dizer o que faltou. |
| `esperarSumir` | Para indicadores de carregamento. |
| `tocarComRolagem` | Em emulador de tela pequena, o botão pode estar fora da área visível. |
| `receiveAction(TextInputAction.done)` em `digitar` | Fecha o teclado. Teclado aberto cobre o botão — causa nº 1 de "o tap não acertou". |
| `BancoFoco.instancia.apagarTudo()` no `setUp` | **O banco é real e persiste.** Sem limpar, a suíte passa na 1ª rodada e falha na 2ª. |
| Overrides no `rodarApp` | Falsifica a rede: testa o **fluxo**, não se o servidor está no ar. |
| `pumpWidget(const SizedBox.shrink())` | Descarta a árvore, como se o app fechasse — o banco continua. |
| Teste "sobrevive a fechar e reabrir" | A **razão de existir** da suíte: nenhum teste de widget tem banco de verdade. |
| Teste "funciona sem rede" | Verifica que offline não é tela de erro — é o app funcionando local. |
| `handlePlatformMessage('flutter/navigation', popRoute)` | Simula o botão voltar do Android. Só dá para testar com o app real. |
| Teste "o app abre" | Parece bobo; pega plugin mal configurado, que nenhum outro teste pega. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Comando | `flutter test integration_test` | idem, **só no macOS** |
| Aparelho | Emulador ou USB | Simulador ou aparelho assinado |
| Primeira execução | ~1 min (Gradle) | ~2 min (CocoaPods) |
| Botão voltar | ✅ testável | ❌ não existe |
| Permissão em diálogo | ⚠️ trava o teste | ⚠️ trava o teste |
| Teclado | Pode cobrir o botão | Idem, e é mais alto |
| CI | GitHub Actions com emulador | Só em runner macOS (pago) |

> ⚠️ **Diálogos de permissão do sistema travam o teste** nas duas plataformas: eles são janelas do
> sistema operacional, fora do alcance do `WidgetTester`. As saídas: conceder a permissão
> previamente via `adb shell pm grant`, ou dublar o plugin de permissão nos testes.

```powershell
# Android: concede a permissão antes, para o diálogo não aparecer
adb shell pm grant br.com.exemplo.foco_lab android.permission.POST_NOTIFICATIONS
```

🪟 **No Windows**, `-d windows` roda em segundos e pega quase todo erro de fluxo. Não substitui o
emulador antes do commit, mas é o que você usa o dia inteiro.

---

## ⚠️ Erros comuns

### 1. Esquecer `ensureInitialized()`

```text
MissingPluginException(No implementation found for method …)
```

**Correção:** primeira linha do `main`.

### 2. Pasta errada

`test/integration/` não é encontrada.

**Correção:** `integration_test/`, na raiz.

### 3. `pumpAndSettle` com operação real

O teste passa na sua máquina e falha no CI.

**Correção:** `esperarPor(condição)`.

### 4. "Consertar" com `Future.delayed`

Deixa a suíte lenta e o teste continua instável.

**Correção:** espere pela condição.

### 5. Não limpar o banco

Passa na 1ª rodada, falha na 2ª.

**Correção:** `apagarTudo()` no `setUp`.

### 6. Testes que dependem da ordem

Falham quando rodam sozinhos.

**Correção:** cada teste monta o próprio cenário.

### 7. Teclado cobrindo o botão

```text
Warning: A call to tap() … finder is outside the bounds
```

**Correção:** `receiveAction(TextInputAction.done)` depois de digitar.

### 8. Diálogo de permissão do sistema

O teste trava até o timeout.

**Correção:** conceda antes, ou duble o plugin.

### 9. Trinta testes de integração

A suíte demora 20 min e ninguém roda.

**Correção:** 3 a 8. O resto é widget e unitário.

### 10. Rede real em todos os testes

Falha sem internet, e polui dados de verdade.

**Correção:** falsifique; guarde um smoke test à parte.

### 11. `flutter test` sem aparelho

```text
No devices found
```

**Correção:** `flutter devices`, ou `-d windows`.

### 12. `app.main()` sem `pumpAndSettle` depois

O teste procura widgets antes de a primeira tela existir.

**Correção:** `await tester.pumpAndSettle()` logo em seguida.

---

## 🛠️ Exercício guiado

**Passo 1.** Acrescente `integration_test` ao `pubspec.yaml` e rode `flutter pub get`.

**Passo 2.** Crie `integration_test/abre_o_app_test.dart` e rode com `-d windows`. Cronometre.

**Passo 3.** Rode o mesmo teste no emulador Android. Compare os tempos.

**Passo 4.** Remova a linha `ensureInitialized()`. Rode e leia o erro.

**Passo 5.** Crie `apoio/ajudantes.dart` e escreva o fluxo completo.

**Passo 6.** Troque um `esperarPor` por `pumpAndSettle()`. Rode cinco vezes no emulador. Passou
todas?

**Passo 7.** Remova o `apagarTudo()` do `setUp`. Rode duas vezes seguidas.

**Passo 8.** Escreva o teste de "fechar e reabrir". Ele passaria como teste de widget? Por quê?

**Passo 9.** Meça: quanto tempo demora a suíte de integração? E a de widget?

**Passo 10.** Escolha os **cinco** testes de integração que você manteria se pudesse ter só cinco.
Justifique cada um.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

Faça o de **Aplicação** (fluxo completo), o de **Correção de bugs** (teste instável) e o de
**Reflexão** (quais testes manter).

---

## 🏆 Desafio opcional

Coloque a suíte inteira num **GitHub Actions** que roda a cada push.

Requisitos:

- Job 1: `flutter analyze` + `dart format --set-exit-if-changed` + `flutter test` (unitário e
  widget). Deve terminar em menos de 3 minutos.
- Job 2: `flutter test integration_test` em emulador Android
  (`reactivecircus/android-emulator-runner`), só na branch `main`.
- Cache de `~/.pub-cache` e do Gradle.
- Publicar o relatório de cobertura (`--coverage`).
- Capturar tela quando um teste de integração falhar, e anexar como artefato.

Depois responda: por que separar em **dois jobs** em vez de um? E por que o job 2 **não** roda em
todo push? (Dica: some o tempo de espera de um desenvolvedor por dia.)

---

## 📌 Resumo

- O teste de integração **liga o app de verdade**, no aparelho: plugins, banco e rede funcionam.
- A pasta é **`integration_test/`, na raiz** — não `test/integration/`.
- **`IntegrationTestWidgetsFlutterBinding.ensureInitialized()`** é obrigatório, antes de tudo.
- `flutter test integration_test`; com **`-d windows`** roda em segundos, durante o dia.
- **Aqui o tempo é real.** `pumpAndSettle` pode terminar antes de a resposta chegar.
- **Espere pela condição, não pelo relógio.** `esperarPor(...)` é a função mais importante da suíte.
- **Nunca** conserte teste instável com `Future.delayed` — só o torna instável com menos frequência.
- **Limpe o banco no `setUp`**: ele é real e persiste entre execuções.
- **Falsifique a rede** na maioria dos testes; guarde um smoke test à parte.
- Tenha **3 a 8** testes de integração. Validação, regra e estados de erro ficam nos níveis abaixo.
- Os que valem: **o app abre**, o **caminho feliz**, **persistência entre sessões**, **offline**.
- **Diálogos de permissão travam o teste** — conceda antes ou duble o plugin.
- O teclado cobre o botão: feche-o com `receiveAction(TextInputAction.done)`.
- Um teste instável é **pior que nenhum**: ele treina a equipe a ignorar falhas.

---

## ☑️ Checklist de domínio

- [ ] Configurei `integration_test` no `pubspec.yaml`.
- [ ] Sei que a pasta fica na raiz.
- [ ] Chamo `ensureInitialized()` antes de tudo.
- [ ] Rodo em Windows para o ciclo rápido e no emulador antes do commit.
- [ ] Uso `esperarPor` em vez de `pumpAndSettle` com operação real.
- [ ] Nunca uso `Future.delayed` para estabilizar teste.
- [ ] Limpo o banco no `setUp`.
- [ ] Cada teste monta o próprio cenário.
- [ ] Falsifico a rede na maioria dos testes.
- [ ] Tenho entre 3 e 8 testes de integração.
- [ ] Testo persistência entre fechar e reabrir.
- [ ] Sei lidar com diálogo de permissão e com o teclado.

---

## 📚 Referências oficiais

- [Integration testing — docs.flutter.dev](https://docs.flutter.dev/testing/integration-tests)
- [package:integration_test — pub.dev](https://pub.dev/packages/integration_test)
- [IntegrationTestWidgetsFlutterBinding — api.flutter.dev](https://api.flutter.dev/flutter/integration_test/IntegrationTestWidgetsFlutterBinding-class.html)
- [Testing Flutter apps — docs.flutter.dev](https://docs.flutter.dev/testing/overview)
- [android-emulator-runner — GitHub](https://github.com/ReactiveCircus/android-emulator-runner)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — Mocks e fakes](07-mocks-e-fakes.md) | [README](README.md) | [Aula 9 — Depurando Android e iOS](09-depurando-android-e-ios.md) |
