# Aula 3 — Assíncrono sem travar

> **Módulo:** 13 - Desempenho e Segurança · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que **`async` não torna nada paralelo** — e por que o app trava mesmo assim.
- Entender o orçamento de **16 ms por quadro** e o que é **jank**.
- Distinguir trabalho **de espera** (I/O) de trabalho **de CPU**.
- Usar **`compute()`** e **`Isolate.run()`** para tirar o cálculo da thread de UI.
- Saber o que **pode e não pode** atravessar a fronteira de um isolate.
- Reconhecer quando **não** usar isolate — o custo de criar um.
- Quebrar trabalho em pedaços com `Future.delayed(Duration.zero)` e `Stream`.

## ✅ Pré-requisitos

- [Aula 2 — Listas grandes e imagens](02-listas-grandes-e-imagens.md) — o projeto `foco_desempenho`.
- [Módulo 04, aula 2 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) —
  `Future`, `async`/`await`, `Stream`.
- [Módulo 12, aula 3 — DevTools](../12-testes-e-debug/03-devtools.md) — a aba Performance.
- [Módulo 09 — Consumo de API](../09-consumo-de-api/README.md) — o exemplo de I/O.

---

## 📖 Conceito

### Uma thread só

O Dart roda o seu código numa **única thread** — a *main isolate*. Tudo acontece nela: `build`,
`setState`, animação, resposta de rede, cálculo.

```text
┌───────────────────────────────────────────────┐
│  main isolate — UMA thread                    │
│                                               │
│  build → layout → paint → build → layout …    │
│                                               │
│  ⬆ se QUALQUER coisa demorar aqui,            │
│    nada mais acontece enquanto isso           │
└───────────────────────────────────────────────┘
```

> ⚠️ **`async` não cria thread.** Este é o mal-entendido mais caro do Flutter. `async`/`await`
> organiza **quando** o código roda, não **onde**. Um `while` de dois segundos dentro de um método
> `async` trava o app por dois segundos — exatamente como travaria sem o `async`.

```dart
// ❌ TRAVA por 3 segundos, apesar do async.
Future<int> somarTudo() async {
  int total = 0;
  for (int i = 0; i < 1000000000; i++) {
    total += i;      // CPU pura: nunca solta a thread
  }
  return total;
}
```

```dart
// ✅ NÃO trava: await de I/O devolve a thread enquanto espera.
Future<String> buscar() async {
  final http.Response r = await http.get(uri);   // ← a thread fica LIVRE aqui
  return r.body;
}
```

**A distinção que resolve tudo:**

| Tipo de trabalho | Exemplo | `async` resolve? |
|---|---|---|
| **Espera (I/O)** | Rede, disco, banco | ✅ **Sim** |
| **CPU** | Loop, JSON gigante, criptografia, imagem | ❌ **Não** |

> 📌 **Se o trabalho é *esperar*, `async` basta. Se o trabalho é *pensar*, precisa de isolate.**
> Esta frase é a aula inteira.

### 16 ms

Uma tela de 60 Hz desenha 60 quadros por segundo. Cada quadro tem:

```text
1000 ms ÷ 60 = 16,67 ms
```

Nesses 16 ms cabe **tudo**: seu `build`, o layout, a pintura. Estourou — o quadro é perdido, e o
usuário vê um tranco. Isso é **jank**.

| Tela | Orçamento |
|---|---|
| 60 Hz | 16,67 ms |
| 90 Hz | 11,11 ms |
| 120 Hz (iPhone Pro, Android topo) | **8,33 ms** |

| Duração do trabalho | Quadros perdidos | Sensação |
|---|---|---|
| 5 ms | 0 | ✅ Liso |
| 20 ms | 1 | ⚠️ Quase imperceptível |
| 100 ms | 6 | ❌ Tranco visível |
| 1 s | 60 | ❌ "Travou" |
| 5 s | 300 | ❌ Android oferece fechar o app |

> 💡 **Aparelhos de 120 Hz são mais exigentes**, não mais tolerantes: o orçamento cai pela metade.
> Um código que passa raspando num celular de 60 Hz faz jank visível num de 120.

### `compute()` e `Isolate.run()`

Um **isolate** é uma thread com memória própria. Ele não compartilha nada com a main isolate — daí
o nome.

```dart
// A forma moderna (Dart 2.19+). Prefira esta.
final Resumo r = await Isolate.run(() => calcularResumo(sessoes));

// A forma antiga, ainda comum. Exige função de TOPO ou static.
final Resumo r = await compute(calcularResumo, sessoes);
```

| | `compute()` | `Isolate.run()` |
|---|---|---|
| Vem de | `package:flutter/foundation.dart` | `dart:isolate` |
| Função | **Precisa** ser de topo ou `static` | Closure qualquer |
| Argumento | Exatamente um | Nenhum (capture pela closure) |
| Nome do isolate | `debugLabel` | — |
| Recomendado | Compatibilidade | ✅ **Código novo** |

```dart
// ❌ compute com método de instância: erro em tempo de EXECUÇÃO.
await compute(this._calcular, dados);
```

```text
Invalid argument(s): Illegal argument in isolate message:
object is unsendable - Library:'…' Class: _MinhaState
```

### O que atravessa a fronteira

Um isolate não compartilha memória: os dados são **copiados**. E nem tudo pode ser copiado.

| Pode | Não pode |
|---|---|
| `int`, `double`, `String`, `bool`, `null` | `BuildContext` |
| `List`, `Map`, `Set` desses | Widgets, `State` |
| Objetos seus **sem** referência a Flutter | `SendPort` de outro isolate ativo |
| `TransferableTypedData` | Closures que capturam coisas assim |
| Outros isolates via porta | Qualquer objeto nativo (`Database`, `File` aberto) |

```dart
// ❌ O erro clássico: a closure captura `context`.
await Isolate.run(() {
  final t = Theme.of(context);   // ← context não atravessa
  return calcular(t);
});

// ✅ Extraia o que precisa ANTES.
final Color cor = Theme.of(context).colorScheme.primary;
final int valor = cor.toARGB32();
await Isolate.run(() => calcular(valor));
```

> ⚠️ **O custo de copiar.** Mandar uma lista de 100 000 objetos para um isolate custa tempo — a
> cópia acontece na thread de UI. Se copiar demora mais que calcular, o isolate **piorou** as
> coisas.

### Quando **não** usar isolate

Criar um isolate custa entre **50 e 200 ms** (e mais no primeiro uso). Esse custo é pago na thread
de UI.

| Situação | Isolate? |
|---|---|
| Cálculo de 2 ms | ❌ Custa mais criar |
| JSON de 10 KB | ❌ `jsonDecode` leva <1 ms |
| JSON de 5 MB | ✅ |
| Rede, disco, banco | ❌ **Já é assíncrono**; `await` basta |
| Ordenar 100 itens | ❌ |
| Ordenar 500 000 itens | ✅ |
| Criptografia, hash de arquivo | ✅ |
| Processar imagem | ✅ |
| Estatística sobre 50 000 sessões | ✅ |

> 📌 **A regra de bolso:** menos de **16 ms**, deixe na thread de UI. Mais de **50 ms**, isolate.
> No meio, **meça** — e meça em modo profile, num aparelho fraco, não no seu PC.

E a regra que economiza mais tempo que todas: **antes de mandar para um isolate, veja se dá para
não fazer o trabalho.** Somar 50 000 sessões a cada `build` é um problema de arquitetura; calcular
uma vez e guardar o resultado resolve sem isolate nenhum.

### Quebrar em pedaços

Há um meio-termo entre "trava" e "isolate": devolver a thread de vez em quando.

```dart
Future<List<Resultado>> processarAosPoucos(List<Item> itens) async {
  final List<Resultado> saida = <Resultado>[];

  for (int i = 0; i < itens.length; i++) {
    saida.add(processar(itens[i]));

    // A cada 100, devolve a thread para o Flutter desenhar um quadro.
    if (i % 100 == 0) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  return saida;
}
```

O total **demora mais**, mas o app continua respondendo — e dá para mostrar progresso. Bom quando o
trabalho não pode ir para um isolate (porque usa algo não copiável) ou quando o progresso importa
mais que a velocidade.

Com `Stream`, fica melhor ainda:

```dart
Stream<double> processarComProgresso(List<Item> itens) async* {
  for (int i = 0; i < itens.length; i++) {
    processar(itens[i]);
    if (i % 100 == 0) yield i / itens.length;   // ← progresso
  }
  yield 1.0;
}
```

---

## 💡 Analogia

Pense num **caixa de supermercado** — um só.

- **A thread de UI é o caixa.** Ele atende um cliente por vez, e a fila é todo o resto do app.
- **`await` de I/O** é o cliente que diz "esqueci o pão, já volto". O caixa **não fica parado**:
  chama o próximo. Quando o cliente volta, entra de novo na vez. É por isso que rede e disco não
  travam nada.
- **Trabalho de CPU** é o cliente com trezentos itens, conferindo cupom por cupom. O caixa está
  **ocupado**: ninguém mais é atendido. Dizer "esse cliente é `async`" não muda nada — ele continua
  ali, no balcão.
- **Um isolate** é abrir **outro caixa**, numa sala separada. Atende em paralelo de verdade. Mas
  abrir o caixa leva tempo, e a sala é **fechada**: nada passa de um caixa para o outro a não ser
  por fotocópia — que é a cópia dos dados. Por isso `BuildContext` não atravessa: ele não é uma
  informação, é um lugar dentro da loja.
- **Abrir um caixa para um cliente com dois itens** é perder mais tempo do que se ganha. Daí o
  limite dos 16 ms.
- **Quebrar em pedaços** é o caixa combinar: "passo cem itens, atendo alguém da fila, volto". O
  cliente grande demora mais, mas a fila anda — e dá para anunciar "faltam 40%".
- **E antes de tudo:** se o cliente traz a mesma lista todo dia, o caixa pode **guardar o total de
  ontem**. Não abrir caixa nenhum é sempre melhor que abrir.

---

## 🧪 Exemplo mínimo

O travamento, visível.

> **Arquivo:** `foco_desempenho/lib/features/estatisticas/domain/calculo_pesado.dart` (novo)

```dart
import 'dart:math';

/// Resultado do cálculo de estatísticas.
///
/// Só tipos simples: é o que atravessa a fronteira do isolate.
class ResumoEstatistico {
  const ResumoEstatistico({
    required this.total,
    required this.media,
    required this.desvioPadrao,
    required this.maiorSequencia,
    required this.duracaoMs,
  });

  final int total;
  final double media;
  final double desvioPadrao;
  final int maiorSequencia;
  final int duracaoMs;
}

/// ⚠️ Função de TOPO — não é método de classe.
///
/// `compute()` exige isto; `Isolate.run()` não, mas manter a função
/// de topo deixa as duas formas possíveis e facilita o teste.
///
/// O cálculo é de propósito pesado: percorre a lista quatro vezes.
ResumoEstatistico calcularResumo(List<int> minutos) {
  final Stopwatch relogio = Stopwatch()..start();

  if (minutos.isEmpty) {
    return const ResumoEstatistico(
      total: 0,
      media: 0,
      desvioPadrao: 0,
      maiorSequencia: 0,
      duracaoMs: 0,
    );
  }

  int total = 0;
  for (final int m in minutos) {
    total += m;
  }

  final double media = total / minutos.length;

  double soma = 0;
  for (final int m in minutos) {
    soma += pow(m - media, 2).toDouble();
  }
  final double desvio = sqrt(soma / minutos.length);

  int atual = 0;
  int maior = 0;
  for (final int m in minutos) {
    if (m > 0) {
      atual++;
      if (atual > maior) maior = atual;
    } else {
      atual = 0;
    }
  }

  relogio.stop();

  return ResumoEstatistico(
    total: total,
    media: media,
    desvioPadrao: desvio,
    maiorSequencia: maior,
    duracaoMs: relogio.elapsedMilliseconds,
  );
}

/// Gera dados de teste.
List<int> gerarMinutos(int quantidade) {
  final Random r = Random(42);   // semente fixa: resultado reproduzível
  return List<int>.generate(quantidade, (_) => r.nextInt(180));
}
```

> **Arquivo:** `foco_desempenho/lib/features/estatisticas/presentation/relatorio_screen.dart` (novo)
> **Como executar:** `flutter run -d windows`

```dart
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/calculo_pesado.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  ResumoEstatistico? _resumo;
  bool _calculando = false;
  String _modo = '';
  double _progresso = 0;

  late final List<int> _dados = gerarMinutos(8000000);

  // ── ❌ Na thread de UI ──────────────────────────────────────────
  Future<void> _naThreadDeUi() async {
    setState(() {
      _calculando = true;
      _modo = 'thread de UI';
    });

    // Um quadro para o indicador aparecer ANTES do travamento.
    await Future<void>.delayed(const Duration(milliseconds: 16));

    // ⚠️ Apesar do async, isto TRAVA: é CPU, não espera.
    // O indicador congela, os botões não respondem.
    final ResumoEstatistico r = calcularResumo(_dados);

    setState(() {
      _resumo = r;
      _calculando = false;
    });
  }

  // ── ✅ Isolate.run (forma moderna) ──────────────────────────────
  Future<void> _comIsolateRun() async {
    setState(() {
      _calculando = true;
      _modo = 'Isolate.run';
    });

    // A closure captura `_dados` — uma List<int>, que é copiável.
    // Se capturasse `context` ou `this`, daria erro de execução.
    final ResumoEstatistico r =
        await Isolate.run(() => calcularResumo(_dados));

    if (!mounted) return;
    setState(() {
      _resumo = r;
      _calculando = false;
    });
  }

  // ── ✅ compute (forma clássica) ─────────────────────────────────
  Future<void> _comCompute() async {
    setState(() {
      _calculando = true;
      _modo = 'compute';
    });

    // `calcularResumo` PRECISA ser função de topo ou static.
    final ResumoEstatistico r = await compute(
      calcularResumo,
      _dados,
      debugLabel: 'resumo de estudos',   // aparece no DevTools
    );

    if (!mounted) return;
    setState(() {
      _resumo = r;
      _calculando = false;
    });
  }

  // ── ⚖️ Em pedaços, com progresso ────────────────────────────────
  Future<void> _emPedacos() async {
    setState(() {
      _calculando = true;
      _modo = 'em pedaços';
      _progresso = 0;
    });

    int total = 0;
    const int lote = 100000;

    for (int i = 0; i < _dados.length; i++) {
      total += _dados[i];

      // A cada lote, devolve a thread: o Flutter desenha um quadro
      // e a barra de progresso anda.
      if (i % lote == 0) {
        await Future<void>.delayed(Duration.zero);
        if (!mounted) return;
        setState(() => _progresso = i / _dados.length);
      }
    }

    if (!mounted) return;
    setState(() {
      _resumo = ResumoEstatistico(
        total: total,
        media: total / _dados.length,
        desvioPadrao: 0,
        maiorSequencia: 0,
        duracaoMs: 0,
      );
      _calculando = false;
      _progresso = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatório')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '${_dados.length} sessões',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // ⭐ A ANIMAÇÃO É O MEDIDOR. Se ela para, a thread
            // de UI está bloqueada. Nenhuma ferramenta necessária.
            const _Girando(),
            const SizedBox(height: 8),
            const Text(
              'Se este quadrado parar de girar, a thread travou.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _calculando ? null : _naThreadDeUi,
              child: const Text('❌ Na thread de UI'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _calculando ? null : _comIsolateRun,
              child: const Text('✅ Isolate.run'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _calculando ? null : _comCompute,
              child: const Text('✅ compute'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _calculando ? null : _emPedacos,
              child: const Text('⚖️ Em pedaços (com progresso)'),
            ),
            const SizedBox(height: 24),

            if (_calculando && _modo == 'em pedaços')
              LinearProgressIndicator(value: _progresso),

            if (_resumo != null) ...<Widget>[
              const Divider(height: 32),
              Text('Modo: $_modo'),
              Text('Total: ${_resumo!.total} min'),
              Text('Média: ${_resumo!.media.toStringAsFixed(1)} min'),
              Text('Cálculo levou ${_resumo!.duracaoMs} ms'),
            ],
          ],
        ),
      ),
    );
  }
}

/// Quadrado girando eternamente.
///
/// É o medidor de jank mais barato que existe: se ele trava,
/// a thread de UI está bloqueada.
class _Girando extends StatefulWidget {
  const _Girando();

  @override
  State<_Girando> createState() => _GirandoState();
}

class _GirandoState extends State<_Girando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _c,
        child: Container(
          width: 48,
          height: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
```

**O que observar** — rode e aperte os botões em ordem:

| Botão | O quadrado gira? | Os botões respondem? |
|---|---|---|
| ❌ Na thread de UI | **Para** por ~2 s | Não |
| ✅ Isolate.run | Gira liso | Sim |
| ✅ compute | Gira liso | Sim |
| ⚖️ Em pedaços | Gira com trancos | Sim, e mostra progresso |

---

## 📱 Aplicando no Flutter

O caso mais comum de todos: JSON grande vindo da API.

---

## 💻 Código completo

> **Arquivo:** `foco_desempenho/lib/features/estatisticas/data/importador.dart` (novo)

```dart
import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import '../domain/calculo_pesado.dart';

/// Importa o histórico de estudos de uma API.
///
/// Mostra as TRÊS decisões desta aula num caso real:
///   1. a busca em rede NÃO precisa de isolate (é espera);
///   2. o jsonDecode de um payload grande PRECISA (é CPU);
///   3. abaixo de um limite, isolate custa mais do que economiza.
class ImportadorHistorico {
  ImportadorHistorico({http.Client? cliente})
      : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  /// Abaixo deste tamanho, decodificar na thread de UI é mais
  /// rápido que criar um isolate.
  ///
  /// 50 KB ≈ 1 ms de jsonDecode; criar isolate custa 50–200 ms.
  /// O número exato depende do aparelho — MEÇA no seu caso.
  static const int _limiteParaIsolate = 50 * 1024;

  Future<List<int>> importar(Uri url) async {
    // ── 1. Rede: ESPERA. Nenhum isolate aqui. ────────────────────
    // A thread de UI fica livre durante todo o download.
    final http.Response resposta = await _cliente.get(url);

    if (resposta.statusCode != 200) {
      throw ImportacaoFalhou('HTTP ${resposta.statusCode}');
    }

    // ⚠️ bodyBytes, não body: `body` já decodifica UTF-8 —
    // e essa decodificação também é CPU, na thread de UI.
    final List<int> bytes = resposta.bodyBytes;

    // ── 2. Decisão pelo TAMANHO ──────────────────────────────────
    if (bytes.length < _limiteParaIsolate) {
      // Pequeno: direto. Criar isolate seria mais lento.
      return _extrairMinutos(bytes);
    }

    // ── 3. Grande: isolate ───────────────────────────────────────
    // A closure captura só `bytes` — uma List<int>, copiável.
    return Isolate.run(() => _extrairMinutos(bytes));
  }

  /// Calcula o resumo — sempre em isolate, porque é CPU pura
  /// sobre uma lista que pode ter centenas de milhares de itens.
  Future<ResumoEstatistico> resumir(List<int> minutos) async {
    if (minutos.length < 10000) {
      // Poucos: o cálculo leva <16 ms, cabe no orçamento do quadro.
      return calcularResumo(minutos);
    }
    return Isolate.run(() => calcularResumo(minutos));
  }

  void fechar() => _cliente.close();
}

/// ⚠️ Função de TOPO: roda dentro do isolate.
///
/// Não pode tocar em nada do Flutter — nem context, nem widget,
/// nem provider. Só dados.
List<int> _extrairMinutos(List<int> bytes) {
  final String texto = utf8.decode(bytes);
  final Object? cru = jsonDecode(texto);

  if (cru is! List) {
    throw ImportacaoFalhou('Esperava uma lista no topo do JSON');
  }

  final List<int> saida = <int>[];
  for (final Object? item in cru) {
    if (item is Map<String, Object?>) {
      final Object? m = item['minutos'];
      if (m is int) saida.add(m);
      if (m is num) saida.add(m.toInt());
    }
  }
  return saida;
}

class ImportacaoFalhou implements Exception {
  ImportacaoFalhou(this.mensagem);
  final String mensagem;

  @override
  String toString() => 'ImportacaoFalhou: $mensagem';
}
```

E o provider que liga isso à tela:

> **Arquivo:** `foco_desempenho/lib/features/estatisticas/presentation/resumo_provider.dart` (novo)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/importador.dart';
import '../domain/calculo_pesado.dart';

final Provider<ImportadorHistorico> importadorProvider =
    Provider<ImportadorHistorico>((Ref ref) {
  final ImportadorHistorico i = ImportadorHistorico();
  // Fecha o cliente HTTP quando o provider morrer.
  ref.onDispose(i.fechar);
  return i;
});

/// O resumo, calculado fora da thread de UI.
///
/// A tela só vê um AsyncValue: carregando, dado ou erro.
/// Toda a decisão de isolate fica escondida aqui — a UI não
/// precisa saber.
class ResumoNotifier extends AsyncNotifier<ResumoEstatistico> {
  @override
  Future<ResumoEstatistico> build() async {
    final ImportadorHistorico importador = ref.watch(importadorProvider);

    final List<int> minutos = await importador.importar(
      Uri.parse('https://exemplo.com/api/historico'),
    );

    return importador.resumir(minutos);
  }

  Future<void> recarregar() async {
    state = const AsyncLoading<ResumoEstatistico>();
    state = await AsyncValue.guard(() async {
      ref.invalidateSelf();
      return future;
    });
  }
}

final AsyncNotifierProvider<ResumoNotifier, ResumoEstatistico>
    resumoProvider =
    AsyncNotifierProvider<ResumoNotifier, ResumoEstatistico>(
  ResumoNotifier.new,
);
```

```powershell
flutter run -d windows
# e, para medir de verdade:
flutter run --profile -d <seu-android>
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `_Girando` | **O medidor de jank mais barato que existe.** Se o quadrado para, a thread travou. |
| `await Future.delayed(16ms)` antes do cálculo ruim | Deixa o indicador aparecer **antes** do travamento — senão nem isso se vê. |
| `calcularResumo` como função de **topo** | `compute` exige; manter assim permite as duas formas e facilita testar. |
| `Isolate.run(() => calcularResumo(_dados))` | A closure captura `_dados` (`List<int>`, copiável). Capturar `context` daria erro. |
| `debugLabel: 'resumo de estudos'` | Nomeia o isolate no DevTools — some na aba Performance sem isso. |
| `if (!mounted) return;` depois do `await` | O usuário pode ter saído da tela durante o cálculo. |
| `i % lote == 0` + `Future.delayed(Duration.zero)` | Devolve a thread: o Flutter desenha um quadro e a barra anda. |
| `resposta.bodyBytes`, não `body` | `body` decodifica UTF-8 **na thread de UI** — CPU escondida. |
| `_limiteParaIsolate = 50 KB` | Abaixo disso, criar isolate custa mais que decodificar. |
| `if (minutos.length < 10000) return calcularResumo(...)` | Poucos itens cabem no orçamento de 16 ms. |
| Decisão de isolate **dentro** do importador | A UI não precisa saber; ela só vê um `AsyncValue`. |
| `_extrairMinutos` sem nada de Flutter | Roda dentro do isolate: só dados atravessam. |
| `ref.onDispose(i.fechar)` | Fecha o cliente HTTP quando o provider morre. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Taxa de quadros | 60, 90 ou 120 Hz | 60 Hz; **120 Hz** nos Pro |
| Travar 5 s | Diálogo **ANR** ("o app não responde") | Sem diálogo; o usuário só fecha |
| Isolate | Thread nativa | Thread nativa |
| Custo de criar | ~50–150 ms | ~50–150 ms |
| Muitos isolates | Pressão de memória | O sistema **mata** o app |

> ⚠️ **O ANR do Android** aparece depois de ~5 s de thread bloqueada e conta como falha na Play
> Console — afeta a nota do app. No iOS não há diálogo, mas o `watchdog` pode encerrar o app na
> inicialização se ela demorar demais. Nos dois casos, **bloquear a thread de UI tem consequência
> além da má impressão**.

> 💡 **Teste no aparelho mais fraco que você tiver.** Um cálculo de 30 ms no seu PC pode levar
> 300 ms num Android de entrada. O PC é o pior lugar para decidir se algo precisa de isolate.

---

## ⚠️ Erros comuns

### 1. Achar que `async` cria thread

```dart
Future<void> pesado() async { for (…) {…} }   // ⚠️ trava igual
```

**Correção:** `async` é para **espera**; CPU precisa de isolate.

### 2. Isolate para operação de I/O

```dart
await Isolate.run(() => http.get(url));   // ⚠️ inútil
```

**Correção:** rede já é assíncrona; `await` basta.

### 3. `compute` com método de instância

```text
object is unsendable
```

**Correção:** função de topo, `static`, ou `Isolate.run`.

### 4. Capturar `context` na closure do isolate

**Correção:** extraia os valores **antes**.

### 5. Isolate para trabalho pequeno

Criar custa 50–200 ms; o cálculo levava 2 ms.

**Correção:** limite pelo tamanho.

### 6. Copiar uma lista gigante para o isolate

A cópia acontece **na thread de UI**.

**Correção:** mande o mínimo; considere `TransferableTypedData`.

### 7. Criar isolate dentro de um loop

Dez isolates, dez vezes o custo.

**Correção:** um isolate processando tudo.

### 8. Esquecer `if (!mounted)` depois do `await`

```text
setState() called after dispose()
```

**Correção:** verifique `mounted`.

### 9. `resposta.body` em payload grande

Decodifica UTF-8 na thread de UI.

**Correção:** `bodyBytes` e decodifique no isolate.

### 10. Medir no PC

O PC é 10× mais rápido que um Android de entrada.

**Correção:** meça em modo profile, no aparelho.

### 11. Medir em modo debug

O debug é várias vezes mais lento.

**Correção:** `flutter run --profile` (aula 4).

### 12. Usar isolate em vez de não fazer o trabalho

Recalcular tudo a cada `build` é problema de arquitetura.

**Correção:** calcule uma vez e guarde o resultado.

---

## 🛠️ Exercício guiado

**Passo 1.** Crie `calculo_pesado.dart` e `relatorio_screen.dart`. Rode.

**Passo 2.** Aperte **❌ Na thread de UI**. O quadrado para? Por quantos segundos?

**Passo 3.** Aperte **✅ Isolate.run**. Ele para?

**Passo 4.** Tente arrastar a tela durante os dois. Sente a diferença?

**Passo 5.** Troque `Isolate.run` por `compute` e confirme que o resultado é o mesmo.

**Passo 6.** Dentro do `Isolate.run`, tente usar `Theme.of(context)`. Leia o erro.

**Passo 7.** Reduza os dados para 1 000 itens. Vale a pena o isolate agora? Meça os dois.

**Passo 8.** Aperte **⚖️ Em pedaços** e observe: gira com trancos, mas mostra progresso.

**Passo 9.** Mude o lote de 100 000 para 1 000. O que acontece com a suavidade e com o tempo total?

**Passo 10.** Rode em modo profile num Android e compare os tempos com os do PC.

---

## 📝 Exercícios independentes

→ Exercícios completos em
[exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md)

Faça os de **Aplicação** (mover cálculo para isolate), **Correção de bugs** (`compute` com método
de instância) e **Reflexão** (quando não usar isolate).

---

## 🏆 Desafio opcional

Implemente um **isolate de longa duração** com `ReceivePort`/`SendPort` — um que fica vivo e
atende várias requisições, em vez de nascer e morrer a cada cálculo.

Requisitos:

- Uma classe `TrabalhadorEstatisticas` que cria o isolate **uma vez** e o mantém.
- Comunicação nos dois sentidos, com um id por requisição, para casar pedido e resposta.
- `encerrar()` que mata o isolate e libera as portas.
- Compare o tempo de 100 cálculos: `Isolate.run` a cada vez × isolate persistente.
- Trate a falha: o que acontece se o isolate morrer no meio?

Depois responda: em que situação o isolate persistente **não** compensa a complexidade? E qual é o
risco de memória de manter um isolate vivo? (Dica: a memória dele não é compartilhada — é
adicional.)

---

## 📌 Resumo

- O Dart roda numa **thread só**. `async` organiza **quando**, não **onde**.
- **Espera (I/O) → `async` basta. CPU → precisa de isolate.** Esta é a aula inteira.
- Orçamento de **16,67 ms** por quadro a 60 Hz; **8,33 ms** a 120 Hz.
- Estourar o orçamento = **jank**. Cinco segundos travado = **ANR** no Android.
- **`Isolate.run`** para código novo; **`compute`** exige função de topo ou `static`.
- Um isolate **não compartilha memória**: os dados são **copiados**.
- **`BuildContext`, widgets e `State` não atravessam** — extraia os valores antes.
- Criar isolate custa **50–200 ms**, pagos na thread de UI.
- Regra: **<16 ms** deixe onde está; **>50 ms** isolate; no meio, **meça**.
- **Nunca** isolate para rede, disco ou banco — já são assíncronos.
- Copiar lista gigante custa caro, e a cópia acontece **na thread de UI**.
- **Quebrar em pedaços** com `Future.delayed(Duration.zero)` mantém o app respondendo e permite
  progresso.
- `bodyBytes` em vez de `body`: `body` decodifica UTF-8 na thread de UI.
- **Antes de mandar para um isolate, veja se dá para não fazer o trabalho.**
- Meça **em modo profile, no aparelho mais fraco** — nunca no PC em debug.

---

## ☑️ Checklist de domínio

- [ ] Explico por que `async` não impede travamento.
- [ ] Distingo trabalho de espera de trabalho de CPU.
- [ ] Sei o orçamento de 16 ms e o que é jank.
- [ ] Uso `Isolate.run` em código novo.
- [ ] Sei por que `compute` exige função de topo.
- [ ] Sei o que pode e o que não pode atravessar a fronteira.
- [ ] Extraio valores do `context` antes de entrar no isolate.
- [ ] Não uso isolate para I/O.
- [ ] Decido pelo tamanho, não por hábito.
- [ ] Sei quebrar trabalho em pedaços com progresso.
- [ ] Verifico `mounted` depois de todo `await`.
- [ ] Meço em modo profile, no aparelho.
- [ ] Pergunto primeiro se o trabalho pode ser evitado.

---

## 📚 Referências oficiais

- [Concurrency in Dart — dart.dev](https://dart.dev/language/concurrency)
- [Isolate.run — api.dart.dev](https://api.dart.dev/stable/dart-isolate/Isolate/run.html)
- [compute — api.flutter.dev](https://api.flutter.dev/flutter/foundation/compute.html)
- [Asynchronous programming: futures — dart.dev](https://dart.dev/libraries/async/async-await)
- [Performance best practices — docs.flutter.dev](https://docs.flutter.dev/perf/best-practices)
- [ANRs — developer.android.com](https://developer.android.com/topic/performance/vitals/anr)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Listas grandes e imagens](02-listas-grandes-e-imagens.md) | [README](README.md) | [Aula 4 — Medindo desempenho](04-medindo-desempenho.md) |
