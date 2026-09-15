# Aula 6 — Timeout, retry e cancelamento

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Definir **timeout** em toda requisição e explicar por que o padrão do sistema não serve.
- Implementar **retry com backoff exponencial** à mão, sem pacote.
- Decidir **quando repetir e quando não repetir** — com base em idempotência e no tipo de erro.
- Reutilizar um **`http.Client`** em vez de criar um por requisição, e fechá-lo no lugar certo.
- Cancelar requisições obsoletas e evitar o problema da **resposta fora de ordem**.
- Aplicar **debounce** numa busca, para não disparar uma requisição por tecla.
- Reconhecer e evitar o **efeito manada** (*thundering herd*) num retry mal-feito.

## ✅ Pré-requisitos

- [Aula 4 — Modelando respostas e erros](04-modelando-respostas-e-erros.md) — `ApiException`,
  `SocketException`, `TimeoutException` e o `sealed class Falha`.
- [Aula 5 — POST, PUT e DELETE](05-post-put-delete.md) — **essencial**: idempotência decide o que
  pode ser repetido.
- [Módulo 04, aula 2 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md).
- [Módulo 07, aula 8 — UX de formulários](../07-navegacao-e-formularios/08-ux-de-formularios.md) —
  o `Debounce` que você escreveu lá volta aqui.
- O projeto `foco_api` rodando.

---

## 📖 Conceito

### Por que o timeout padrão não serve

Sem timeout explícito, uma requisição HTTP em Dart pode ficar pendurada por **muito** tempo — o
padrão do sistema operacional costuma passar de um minuto, e em algumas redes móveis ela
simplesmente nunca resolve.

O que o usuário vê: um indicador girando para sempre. Ele conclui que o app travou e o fecha.

```dart
// ❌ pode ficar pendurada indefinidamente
final http.Response r = await cliente.get(url);

// ✅ falha em 15 segundos, com erro que você trata
final http.Response r = await cliente.get(url).timeout(
  const Duration(seconds: 15),
);
```

Quando o prazo estoura, o `Future` completa com **`TimeoutException`** — e o seu `catch` da
[aula 4](04-modelando-respostas-e-erros.md) já sabe traduzi-la.

**Quanto tempo escolher:**

| Operação | Timeout sugerido | Por quê |
|---|---|---|
| Busca enquanto digita | 5 s | Se demorar mais, o usuário já digitou outra coisa |
| Carregar uma lista | 15 s | O padrão para a maioria das telas |
| Enviar formulário | 30 s | Vale esperar mais: o usuário digitou aquilo |
| Upload de arquivo | 60 s+ | Depende do tamanho |
| Login | 20 s | Importante, mas o usuário está esperando |

> ⚠️ **Timeout curto demais é pior que timeout longo.** Em rede móvel ruim, 3 segundos falham
> constantemente em requisições que teriam funcionado em 6. O usuário passa a ver erro o tempo
> todo.

### Retry: repetir quando vale a pena

Nem toda falha merece nova tentativa. A regra é simples:

| Tipo de erro | Repetir? | Por quê |
|---|:---:|---|
| `SocketException` (sem rede) | ✅ | A rede pode voltar em um segundo |
| `TimeoutException` | ✅ | Pode ter sido um pico momentâneo |
| `500`, `502`, `503`, `504` | ✅ | Erro **do servidor**, provavelmente temporário |
| `429 Too Many Requests` | ✅ **respeitando `Retry-After`** | O servidor pediu para esperar |
| `400 Bad Request` | ❌ | O pedido está errado; repetir dá o mesmo erro |
| `401` / `403` | ❌ | Credencial inválida; repetir não resolve |
| `404` | ❌ | Não existe; não vai passar a existir |
| `422` (validação) | ❌ | Os dados estão errados |

E a segunda regra, mais importante:

> **Só repita operações idempotentes.** `GET`, `PUT` e `DELETE` podem ser repetidos. **`POST`
> não** — a primeira tentativa pode ter chegado ao servidor com a resposta perdida no caminho, e a
> repetição criaria um segundo registro.

### Backoff exponencial

Repetir imediatamente é a pior estratégia possível:

```text
❌ retry imediato
tentativa 1 → falha
tentativa 2 → falha (0 ms depois)
tentativa 3 → falha (0 ms depois)
```

Se o servidor está sobrecarregado, você acabou de mandar três vezes mais tráfego para ele.

**Backoff exponencial** dobra a espera a cada tentativa:

```text
✅ backoff exponencial
tentativa 1 → falha
espera 400 ms
tentativa 2 → falha
espera 800 ms
tentativa 3 → falha
espera 1600 ms
tentativa 4 → sucesso
```

E há um detalhe que separa o retry amador do profissional: o **jitter** (variação aleatória).

Sem jitter, mil aparelhos que falharam ao mesmo tempo (o servidor caiu) vão repetir **exatamente**
ao mesmo tempo — e derrubar o servidor de novo assim que ele voltar. Isso é o **efeito manada**.

```dart
// Espera: base × 2^tentativa, mais uma variação aleatória de até 30%.
final int baseMs = 400 * (1 << tentativa);          // 400, 800, 1600…
final int jitter = _random.nextInt(baseMs ~/ 3);    // dispersa os clientes
await Future<void>.delayed(Duration(milliseconds: baseMs + jitter));
```

> 📌 `1 << tentativa` é deslocamento de bits: `1 << 0 = 1`, `1 << 1 = 2`, `1 << 2 = 4`. É a forma
> mais rápida de calcular potência de 2.

E respeite o `Retry-After` quando o servidor mandar:

```dart
final String? esperar = resposta.headers['retry-after'];
if (esperar != null) {
  final int? segundos = int.tryParse(esperar);
  if (segundos != null) await Future<void>.delayed(Duration(seconds: segundos));
}
```

### `http.Client`: reutilizar, não recriar

```dart
// ❌ cada chamada abre uma conexão TCP + handshake TLS novo
await http.get(url1);
await http.get(url2);
await http.get(url3);
```

As funções de conveniência (`http.get`, `http.post`) criam um cliente, usam e descartam. Para três
requisições ao mesmo servidor, são **três** handshakes TLS — cada um custa centenas de milissegundos
em rede móvel.

```dart
// ✅ uma conexão reaproveitada
final http.Client cliente = http.Client();
try {
  await cliente.get(url1);
  await cliente.get(url2);
  await cliente.get(url3);
} finally {
  cliente.close();
}
```

Um `http.Client` mantém a conexão aberta (*keep-alive*) e reaproveita o handshake. Em uma tela que
faz várias chamadas, a diferença é visível.

**Onde ele deve viver, num app Riverpod:**

```dart
final Provider<http.Client> clienteHttpProvider = Provider<http.Client>((Ref ref) {
  final http.Client cliente = http.Client();
  // Fechado quando o provider for descartado.
  ref.onDispose(cliente.close);
  return cliente;
});
```

> ⚠️ **`close()` é definitivo.** Um cliente fechado lança
> `ClientException: Client is already closed` em qualquer uso posterior. Por isso ele vive num
> provider **sem `autoDispose`**: o cliente do app é um só, do início ao fim.

### Cancelamento e respostas fora de ordem

Este é o bug mais sutil da aula. Numa busca:

```text
usuário digita "da"   → requisição A sai
usuário digita "dar"  → requisição B sai
B responde (rápido)   → tela mostra resultados de "dar"  ✅
A responde (lenta)    → tela mostra resultados de "da"   ❌ ERRADO
```

A resposta **antiga** chegou **depois** e sobrescreveu a nova. O usuário vê resultados que não
correspondem ao que ele digitou.

O pacote `http` não tem cancelamento nativo (o `dio` tem, via `CancelToken`). A solução com `http`
é **descartar respostas obsoletas** usando um contador de sequência:

```dart
int _sequencia = 0;

Future<void> buscar(String termo) async {
  final int minhaVez = ++_sequencia;

  final List<Trilha> resultado = await _api.buscar(termo);

  // Chegou tarde? Outra busca já começou. Descarte esta resposta.
  if (minhaVez != _sequencia) return;

  state = AsyncData<List<Trilha>>(resultado);
}
```

Simples, sem pacote, e resolve o problema por completo.

> 💡 **Descartar não é cancelar.** A requisição antiga continua consumindo dados até terminar — você
> só ignora o resultado. Para cancelar de verdade (e economizar dados), é preciso `dio` com
> `CancelToken` ou `HttpClient` do `dart:io` com `abort`.

### Debounce: não disparar uma requisição por tecla

Sem debounce, digitar "flutter" dispara **sete** requisições:

```text
f → requisição
fl → requisição
flu → requisição
… sete no total, e só a última interessa
```

Com debounce, uma só:

```dart
final Debounce _debounce = Debounce(const Duration(milliseconds: 400));

void aoDigitar(String termo) {
  _debounce.chamar(() => _controller.buscar(termo));
}
```

O `Debounce` que você escreveu no
[Módulo 07, aula 8](../07-navegacao-e-formularios/08-ux-de-formularios.md) serve exatamente para
isso.

| Espera | Efeito |
|---|---|
| 200 ms | Responsivo, mas ainda dispara bastante |
| **300–500 ms** | **O ponto certo** para busca |
| 800 ms+ | O usuário sente o atraso |

> 📌 Debounce e sequência resolvem problemas **diferentes** e são usados juntos. Debounce reduz o
> **número** de requisições; a sequência protege contra a que chega **fora de ordem**.

---

## 💡 Analogia

Pense em ligar para um call center.

- **Sem timeout** é ficar na linha ouvindo música de espera **para sempre**. Em algum momento você
  desliga achando que a empresa fechou — e essa é exatamente a conclusão do usuário sobre o seu app.
- **O timeout** é você decidir: "espero 15 minutos; depois desligo e tento outra hora". Uma decisão
  consciente, em vez de esperar indefinidamente.
- **Retry sem backoff** é redisca imediatamente, sem parar. Se a central está congestionada, mil
  pessoas fazendo isso a congestionam ainda mais.
- **Backoff exponencial** é esperar 1 minuto, depois 2, depois 4. Você dá tempo de a central se
  recuperar.
- **O jitter** é a parte esperta: se mil pessoas foram derrubadas **na mesma hora** e todas
  esperarem exatamente 1 minuto, elas vão ligar **todas juntas** de novo — e derrubar a central
  outra vez. Um pouquinho de aleatoriedade em cada espera dispersa a multidão.
- **Repetir um `POST`** é ligar de novo para fazer o mesmo pedido, sem saber se o primeiro foi
  registrado. Resultado provável: **dois pedidos**. É por isso que `POST` não entra em retry
  automático.
- **Reutilizar o `http.Client`** é não desligar e ligar de novo para cada pergunta. Você já está na
  linha com o atendente — aproveite.
- **Resposta fora de ordem** é você perguntar sobre o pedido A, depois sobre o B, e o atendente
  responder sobre o B primeiro e o A depois. Se você anotar a última resposta que chegou, anota a
  **do pedido errado**. O número de sequência é você conferir sobre qual pedido a resposta é.
- **Debounce** é não ligar para o call center a cada palavra que você pensa em perguntar. Você
  formula a pergunta inteira **e então** liga.

---

## 🧪 Exemplo mínimo

Este programa mostra timeout, retry com backoff e resposta fora de ordem, tudo visível no log.

> **Arquivo:** `foco_api/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const AppResiliencia());

class AppResiliencia extends StatelessWidget {
  const AppResiliencia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaResiliencia(),
    );
  }
}

class TelaResiliencia extends StatefulWidget {
  const TelaResiliencia({super.key});

  @override
  State<TelaResiliencia> createState() => _TelaResilienciaState();
}

class _TelaResilienciaState extends State<TelaResiliencia> {
  /// UM cliente para toda a tela. Cada http.get() avulso abriria
  /// uma conexão TCP + handshake TLS novo.
  final http.Client _cliente = http.Client();
  final math.Random _random = math.Random();

  final List<String> _log = <String>[];

  /// Contador de sequência: protege contra resposta fora de ordem.
  int _sequencia = 0;

  @override
  void dispose() {
    // close() é definitivo: o cliente não pode mais ser usado.
    // Por isso ele vive tanto quanto a tela que o criou.
    _cliente.close();
    super.dispose();
  }

  void _registrar(String linha) {
    debugPrint(linha);
    if (mounted) setState(() => _log.insert(0, linha));
  }

  // ── Timeout ──────────────────────────────────────────────────────────────
  Future<void> _comTimeout() async {
    _registrar('— timeout de 2 s numa resposta que demora 5 s —');
    try {
      // httpbin.org/delay/5 demora 5 segundos de propósito.
      await _cliente
          .get(Uri.parse('https://httpbin.org/delay/5'))
          .timeout(const Duration(seconds: 2));
      _registrar('✅ respondeu (não deveria)');
    } on TimeoutException {
      // O catch específico da aula 4. Sem o .timeout(), esta requisição
      // ficaria pendurada por mais de um minuto.
      _registrar('⏱️ TimeoutException — falhou em 2 s, como planejado');
    } on Object catch (e) {
      _registrar('💥 $e');
    }
  }

  // ── Retry com backoff exponencial ────────────────────────────────────────
  Future<void> _comRetry() async {
    _registrar('— retry: /status/503 falha sempre, 4 tentativas —');

    const int maximo = 4;
    for (int tentativa = 0; tentativa < maximo; tentativa++) {
      try {
        final http.Response r = await _cliente
            .get(Uri.parse('https://httpbin.org/status/503'))
            .timeout(const Duration(seconds: 10));

        // 5xx é erro DO SERVIDOR: provavelmente temporário, vale repetir.
        if (r.statusCode >= 500) {
          throw http.ClientException('HTTP ${r.statusCode}');
        }

        _registrar('✅ sucesso na tentativa ${tentativa + 1}');
        return;
      } on Object catch (erro) {
        final bool ultima = tentativa == maximo - 1;
        if (ultima) {
          _registrar('❌ desisti depois de $maximo tentativas: $erro');
          return;
        }

        // Backoff exponencial: 400, 800, 1600 ms.
        // 1 << n é a forma rápida de calcular 2^n.
        final int baseMs = 400 * (1 << tentativa);

        // Jitter: sem ele, mil clientes que falharam juntos repetiriam
        // EXATAMENTE juntos — e derrubariam o servidor de novo.
        final int jitter = _random.nextInt(baseMs ~/ 3);
        final int esperaMs = baseMs + jitter;

        _registrar('  tentativa ${tentativa + 1} falhou · '
            'esperando ${esperaMs}ms (base $baseMs + jitter $jitter)');
        await Future<void>.delayed(Duration(milliseconds: esperaMs));
      }
    }
  }

  // ── Resposta fora de ordem ───────────────────────────────────────────────
  Future<void> _foraDeOrdem({required bool protegido}) async {
    _registrar('— duas buscas: a LENTA sai primeiro, a RÁPIDA depois —');

    // Busca A: lenta (3 s).
    unawaited(_buscar('A (lenta, 3s)', 3, protegido: protegido));

    // Busca B: rápida (1 s), disparada logo depois.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _buscar('B (rápida, 1s)', 1, protegido: protegido);
  }

  Future<void> _buscar(
    String nome,
    int segundos, {
    required bool protegido,
  }) async {
    // Cada busca pega o próximo número da fila.
    final int minhaVez = ++_sequencia;

    try {
      await _cliente
          .get(Uri.parse('https://httpbin.org/delay/$segundos'))
          .timeout(const Duration(seconds: 15));

      if (protegido && minhaVez != _sequencia) {
        // Outra busca começou depois desta. O resultado desta
        // já não interessa: descarte em silêncio.
        _registrar('🚫 $nome respondeu, mas foi DESCARTADA (obsoleta)');
        return;
      }

      _registrar('📝 tela atualizada com: $nome');
    } on Object catch (e) {
      _registrar('💥 $nome: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeout · Retry · Ordem')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: _comTimeout,
                  child: const Text('Timeout'),
                ),
                FilledButton.tonal(
                  onPressed: _comRetry,
                  child: const Text('Retry + backoff'),
                ),
                OutlinedButton(
                  onPressed: () => _foraDeOrdem(protegido: false),
                  child: const Text('Fora de ordem ❌'),
                ),
                OutlinedButton(
                  onPressed: () => _foraDeOrdem(protegido: true),
                  child: const Text('Fora de ordem ✅'),
                ),
                TextButton(
                  onPressed: () => setState(_log.clear),
                  child: const Text('Limpar'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (BuildContext c, int i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Text(
                  _log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**O roteiro:**

1. **Timeout** → `TimeoutException` em 2 s, mesmo com o servidor demorando 5.
2. **Retry + backoff** → quatro tentativas, com esperas crescentes (≈400, 800, 1600 ms) e jitter
   diferente a cada vez.
3. **Fora de ordem ❌** → repare na **última** linha: a tela foi atualizada com **A (lenta)**,
   apesar de B ter sido pedida depois. É o bug.
4. **Fora de ordem ✅** → agora A é **descartada**, e a tela fica com B. É a correção.

O item 3 é o bug mais difícil de perceber em produção — e o item 4 custa três linhas.

---

## 📱 Aplicando no Flutter

O `foco_api` ganha uma camada de resiliência reutilizável:

- `core/http/cliente_http.dart` — o cliente único, com timeout padrão;
- `core/http/repetir.dart` — a função de retry com backoff e jitter;
- busca de trilhas com **debounce** e **proteção de sequência**;
- decisão explícita sobre o que pode e o que não pode ser repetido.

---

## 💻 Código completo

> **Arquivo:** `foco_api/lib/core/http/repetir.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import 'package:foco_api/core/erros/api_exception.dart';

/// Executa [acao] repetindo quando a falha é **transitória**.
///
/// Regras que esta função implementa:
/// 1. Só repete erros que podem passar sozinhos (rede, timeout, 5xx, 429).
/// 2. Nunca repete erro de cliente (4xx, exceto 429): repetir dá o mesmo erro.
/// 3. Espera crescente (backoff exponencial) para não sobrecarregar
///    um servidor que já está com problema.
/// 4. Variação aleatória (jitter) para mil clientes não repetirem
///    exatamente juntos — o "efeito manada".
///
/// ⚠️ Use APENAS com operações idempotentes: GET, PUT, DELETE.
/// Um POST repetido pode criar dois registros. Aula 5.
Future<T> repetir<T>(
  Future<T> Function() acao, {
  int maximoDeTentativas = 3,
  Duration esperaBase = const Duration(milliseconds: 400),
  Duration esperaMaxima = const Duration(seconds: 8),
}) async {
  assert(maximoDeTentativas >= 1, 'Pelo menos uma tentativa');

  final math.Random random = math.Random();
  Object? ultimoErro;
  StackTrace? ultimaPilha;

  for (int tentativa = 0; tentativa < maximoDeTentativas; tentativa++) {
    try {
      return await acao();
    } on Object catch (erro, pilha) {
      ultimoErro = erro;
      ultimaPilha = pilha;

      // Erro permanente: repetir não adianta. Falha imediatamente.
      if (!_ehTransitorio(erro)) rethrow;

      final bool ultima = tentativa == maximoDeTentativas - 1;
      if (ultima) break;

      await Future<void>.delayed(
        _esperaDe(
          tentativa: tentativa,
          base: esperaBase,
          maxima: esperaMaxima,
          random: random,
          erro: erro,
        ),
      );
    }
  }

  // Esgotou as tentativas: propaga o último erro com a pilha original.
  Error.throwWithStackTrace(ultimoErro!, ultimaPilha!);
}

/// A falha pode passar sozinha?
bool _ehTransitorio(Object erro) {
  // Sem rede, DNS falhou, conexão recusada.
  if (erro is SocketException) return true;

  // A conexão caiu no meio.
  if (erro is http.ClientException) return true;

  // Prazo estourado: pode ter sido um pico momentâneo.
  if (erro is TimeoutException) return true;

  if (erro is ApiException) {
    // 5xx é problema DO SERVIDOR: provavelmente temporário.
    if (erro.statusCode >= 500) return true;

    // 429: o servidor pediu explicitamente para esperar.
    if (erro.statusCode == 429) return true;

    // 408: o próprio servidor diz que o pedido demorou demais.
    if (erro.statusCode == 408) return true;

    // Qualquer outro 4xx é erro NOSSO: repetir dá o mesmo resultado.
    return false;
  }

  // Erro desconhecido: não repita. Melhor falhar rápido e visível.
  return false;
}

/// Calcula quanto esperar antes da próxima tentativa.
Duration _esperaDe({
  required int tentativa,
  required Duration base,
  required Duration maxima,
  required math.Random random,
  required Object erro,
}) {
  // Se o servidor mandou Retry-After, ele manda.
  if (erro is ApiException) {
    final Duration? pedida = erro.retryAfter;
    if (pedida != null) return pedida > maxima ? maxima : pedida;
  }

  // Backoff exponencial: base × 2^tentativa.
  // 1 << n é a forma rápida de calcular 2^n.
  final int baseMs = base.inMilliseconds * (1 << tentativa);
  final int limitado = math.min(baseMs, maxima.inMilliseconds);

  // Jitter de até 30%: dispersa clientes que falharam ao mesmo tempo.
  final int jitter = random.nextInt(math.max(1, limitado ~/ 3));

  return Duration(milliseconds: limitado + jitter);
}
```

> **Arquivo:** `foco_api/lib/core/erros/api_exception.dart` (acrescente `retryAfter`)

```dart
/// Erro devolvido pelo servidor, com o status HTTP.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.corpo, {this.cabecalhos});

  final int statusCode;
  final String corpo;
  final Map<String, String>? cabecalhos;

  /// Quanto o servidor pediu para esperar, quando ele pede (429, 503).
  ///
  /// O cabeçalho Retry-After pode vir em segundos ou como data HTTP.
  /// Tratamos só o formato em segundos, que é o comum em APIs.
  Duration? get retryAfter {
    final String? bruto = cabecalhos?['retry-after'];
    if (bruto == null) return null;
    final int? segundos = int.tryParse(bruto.trim());
    return segundos == null ? null : Duration(seconds: segundos);
  }

  bool get ehErroDoServidor => statusCode >= 500;
  bool get ehErroDoCliente => statusCode >= 400 && statusCode < 500;

  @override
  String toString() => 'ApiException($statusCode)';
}
```

> **Arquivo:** `foco_api/lib/core/http/cliente_http.dart` (novo)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// O cliente HTTP do app.
///
/// UM cliente para o app inteiro. Cada `http.get()` avulso abriria uma
/// conexão TCP e um handshake TLS novos — centenas de milissegundos
/// desperdiçados por requisição em rede móvel.
///
/// Note que NÃO tem autoDispose: o cliente vive do início ao fim do app.
/// close() é definitivo, e um cliente fechado lança
/// "Client is already closed" em qualquer uso posterior.
final Provider<http.Client> clienteHttpProvider = Provider<http.Client>(
  (Ref ref) {
    final http.Client cliente = http.Client();
    // Fechado quando o ProviderScope for descartado — ou seja,
    // quando o app terminar.
    ref.onDispose(cliente.close);
    return cliente;
  },
);

/// Prazos por tipo de operação.
///
/// Timeout curto demais é PIOR que longo demais: em rede móvel ruim,
/// 3 s falham em requisições que teriam funcionado em 6.
abstract final class Prazos {
  /// Busca enquanto digita: se demorar mais, o termo já mudou.
  static const Duration busca = Duration(seconds: 5);

  /// Carregar uma lista. O padrão da maioria das telas.
  static const Duration leitura = Duration(seconds: 15);

  /// Enviar formulário: vale esperar mais, o usuário digitou aquilo.
  static const Duration escrita = Duration(seconds: 30);

  /// Upload de arquivo.
  static const Duration upload = Duration(minutes: 2);
}
```

> **Arquivo:** `foco_api/lib/features/trilhas/data/trilha_api.dart` (com resiliência)

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:foco_api/core/config/ambiente.dart';
import 'package:foco_api/core/erros/api_exception.dart';
import 'package:foco_api/core/http/cliente_http.dart';
import 'package:foco_api/core/http/repetir.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';

class TrilhaApi {
  TrilhaApi({required http.Client cliente, String? base})
      : _cliente = cliente,
        _base = base ?? Ambiente.urlBase;

  final http.Client _cliente;
  final String _base;

  static const Map<String, String> _comCorpo = <String, String>{
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };
  static const Map<String, String> _semCorpo = <String, String>{
    'Accept': 'application/json',
  };

  // ── Leitura: GET é idempotente, então PODE repetir ───────────────────────

  Future<List<Trilha>> listar() {
    return repetir<List<Trilha>>(() async {
      final http.Response r = await _cliente
          .get(Uri.parse('$_base/posts?_limit=10'), headers: _semCorpo)
          .timeout(Prazos.leitura);

      _exigir(r, const <int>[200]);

      final List<Object?> bruto = jsonDecode(r.body) as List<Object?>;
      return bruto
          .map((Object? e) => Trilha.fromJson(e! as Map<String, Object?>))
          .toList();
    });
  }

  /// Busca com prazo CURTO: se demorar mais que isso, o usuário já
  /// digitou outra coisa e o resultado não interessa mais.
  Future<List<Trilha>> buscar(String termo) {
    // Sem retry aqui de propósito: numa busca, repetir atrasa a resposta
    // do termo ATUAL. É melhor falhar rápido e deixar o usuário digitar
    // de novo.
    return _buscarUmaVez(termo);
  }

  Future<List<Trilha>> _buscarUmaVez(String termo) async {
    final Uri url = Uri.parse('$_base/posts').replace(
      queryParameters: <String, String>{'q': termo, '_limit': '20'},
    );

    final http.Response r =
        await _cliente.get(url, headers: _semCorpo).timeout(Prazos.busca);

    _exigir(r, const <int>[200]);

    final List<Object?> bruto = jsonDecode(r.body) as List<Object?>;
    return bruto
        .map((Object? e) => Trilha.fromJson(e! as Map<String, Object?>))
        .toList();
  }

  // ── Escrita ──────────────────────────────────────────────────────────────

  /// POST **não entra em retry**.
  ///
  /// Se a requisição chegou ao servidor e só a resposta se perdeu,
  /// a repetição criaria uma SEGUNDA trilha. Aula 5.
  Future<Trilha> criar(Trilha nova) async {
    final http.Response r = await _cliente
        .post(
          Uri.parse('$_base/posts'),
          headers: _comCorpo,
          body: jsonEncode(nova.toJsonParaCriar()),
        )
        .timeout(Prazos.escrita);

    _exigir(r, const <int>[201, 200]);
    return Trilha.fromJson(jsonDecode(r.body) as Map<String, Object?>);
  }

  /// PUT é idempotente: repetir é seguro.
  Future<Trilha> substituir(Trilha trilha) {
    return repetir<Trilha>(() async {
      final http.Response r = await _cliente
          .put(
            Uri.parse('$_base/posts/${trilha.id}'),
            headers: _comCorpo,
            body: jsonEncode(trilha.toJson()),
          )
          .timeout(Prazos.escrita);

      _exigir(r, const <int>[200]);
      return Trilha.fromJson(jsonDecode(r.body) as Map<String, Object?>);
    });
  }

  /// DELETE é idempotente: repetir é seguro, e 404 é sucesso.
  Future<void> excluir(String id) {
    return repetir<void>(() async {
      final http.Response r = await _cliente
          .delete(Uri.parse('$_base/posts/$id'), headers: _semCorpo)
          .timeout(Prazos.escrita);

      _exigir(r, const <int>[200, 204, 404]);
    });
  }

  void _exigir(http.Response r, List<int> esperados) {
    if (!esperados.contains(r.statusCode)) {
      // Passa os cabeçalhos: é deles que sai o Retry-After.
      throw ApiException(r.statusCode, r.body, cabecalhos: r.headers);
    }
  }
}
```

> **Arquivo:** `foco_api/lib/features/trilhas/presentation/busca_controller.dart` (novo)

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_api/features/trilhas/data/trilha_repositorio.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';

/// Busca de trilhas, com debounce e proteção contra resposta fora de ordem.
final AutoDisposeNotifierProvider<BuscaController, AsyncValue<List<Trilha>>>
    buscaProvider =
    NotifierProvider.autoDispose<BuscaController, AsyncValue<List<Trilha>>>(
        BuscaController.new);

class BuscaController extends AutoDisposeNotifier<AsyncValue<List<Trilha>>> {
  Timer? _debounce;

  /// Número de sequência.
  ///
  /// Cada busca pega o próximo número. Quando a resposta chega, se o
  /// número dela não for mais o atual, outra busca já começou — e o
  /// resultado desta é descartado.
  ///
  /// Sem isto: o usuário digita "da", depois "dar"; a resposta de "dar"
  /// chega primeiro, a de "da" chega depois e SOBRESCREVE a tela com
  /// resultados errados.
  int _sequencia = 0;

  String _termoAtual = '';

  @override
  AsyncValue<List<Trilha>> build() {
    // Um Timer pendente dispararia depois de o provider morrer.
    ref.onDispose(() => _debounce?.cancel());
    return const AsyncData<List<Trilha>>(<Trilha>[]);
  }

  /// Chamado a cada tecla digitada.
  ///
  /// O debounce faz "flutter" (7 teclas) virar UMA requisição em vez de
  /// sete. 400 ms é o ponto certo: abaixo dispara demais, acima o
  /// usuário sente o atraso.
  void aoDigitar(String termo) {
    _termoAtual = termo.trim();
    _debounce?.cancel();

    if (_termoAtual.isEmpty) {
      _sequencia++; // invalida qualquer busca em voo
      state = const AsyncData<List<Trilha>>(<Trilha>[]);
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _buscar(_termoAtual),
    );
  }

  Future<void> _buscar(String termo) async {
    final int minhaVez = ++_sequencia;

    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);

    try {
      final List<Trilha> resultado =
          await ref.read(trilhaRepositorioProvider).buscar(termo);

      // Chegou tarde? Descarte em silêncio: outra busca já está em voo,
      // e o resultado dela é o que o usuário quer ver.
      if (minhaVez != _sequencia) return;

      state = AsyncData<List<Trilha>>(resultado);
    } on Object catch (erro, pilha) {
      // A mesma proteção vale para o erro: um erro de busca obsoleta
      // não deve aparecer na tela.
      if (minhaVez != _sequencia) return;
      state = AsyncError<List<Trilha>>(erro, pilha).copyWithPrevious(state);
    }
  }

  /// Força a busca imediatamente, sem esperar o debounce.
  /// Usado quando o usuário aperta Enter.
  void buscarAgora() {
    _debounce?.cancel();
    if (_termoAtual.isNotEmpty) _buscar(_termoAtual);
  }
}
```

> **Arquivo:** `foco_api/lib/features/trilhas/presentation/busca_trilhas.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_api/features/trilhas/domain/trilha.dart';
import 'package:foco_api/features/trilhas/presentation/busca_controller.dart';

class BuscaTrilhas extends ConsumerStatefulWidget {
  const BuscaTrilhas({super.key});

  @override
  ConsumerState<BuscaTrilhas> createState() => _BuscaTrilhasState();
}

class _BuscaTrilhasState extends ConsumerState<BuscaTrilhas> {
  final TextEditingController _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Trilha>> resultado = ref.watch(buscaProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _campo,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar trilhas',
            border: InputBorder.none,
            suffixIcon: _campo.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Limpar busca',
                    onPressed: () {
                      _campo.clear();
                      ref.read(buscaProvider.notifier).aoDigitar('');
                      setState(() {});
                    },
                  ),
          ),
          // Cada tecla passa pelo debounce do controller.
          onChanged: (String t) {
            ref.read(buscaProvider.notifier).aoDigitar(t);
            setState(() {}); // só para o botão de limpar aparecer
          },
          // Enter dispara a busca imediatamente, sem esperar os 400 ms.
          onSubmitted: (_) => ref.read(buscaProvider.notifier).buscarAgora(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: SizedBox(
            height: 4,
            // Barra fina durante a busca: a lista anterior continua visível.
            child: resultado.isLoading
                ? const LinearProgressIndicator()
                : null,
          ),
        ),
      ),
      body: switch (resultado) {
        AsyncError<List<Trilha>>(hasValue: false) => const Center(
            child: Text('Não conseguimos buscar agora. Tente de novo.'),
          ),
        AsyncValue<List<Trilha>>(value: final List<Trilha>? lista)
            when lista != null && lista.isEmpty =>
          Center(
            child: Text(
              _campo.text.isEmpty
                  ? 'Digite para buscar'
                  : 'Nenhuma trilha encontrada',
            ),
          ),
        AsyncValue<List<Trilha>>(value: final List<Trilha>? lista)
            when lista != null =>
          ListView.builder(
            itemCount: lista.length,
            itemBuilder: (BuildContext c, int i) => ListTile(
              leading: const Icon(Icons.route_outlined),
              title: Text(lista[i].titulo),
            ),
          ),
        _ => const Center(child: CircularProgressIndicator.adaptive()),
      },
    );
  }
}
```

Rode e teste:

```powershell
flutter analyze
flutter run -d chrome
```

1. Digite "flutter" na busca **rapidamente**. Olhe o painel Network do navegador (`F12`): **uma**
   requisição, não sete.
2. Digite e apague rápido várias vezes: nenhuma resposta obsoleta aparece na tela.
3. Desligue a internet e recarregue a lista: o retry tenta três vezes, com espera crescente, antes
   de mostrar o erro.
4. Compare os tempos entre as tentativas no console: ≈400 ms, ≈800 ms — sempre um pouco diferentes,
   por causa do jitter.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `.timeout(Prazos.leitura)` em toda requisição | Sem isso, a requisição pode ficar pendurada por mais de um minuto e o usuário conclui que travou. |
| `abstract final class Prazos` | Os prazos ficam em **um** lugar. Mudar a política do app é mudar um arquivo. |
| `repetir<T>(() async {...})` envolvendo `GET`, `PUT`, `DELETE` | Só operações **idempotentes** entram em retry. |
| `criar` **sem** `repetir` | `POST` repetido pode criar dois registros. A ausência aqui é deliberada e documentada. |
| `if (!_ehTransitorio(erro)) rethrow;` | Erro permanente falha **imediatamente**. Repetir um `400` só gasta tempo e bateria. |
| `erro.statusCode >= 500` → transitório | Problema do servidor: provavelmente passa. `4xx` é problema **nosso**. |
| `429` e `408` como transitórios | O servidor pediu para esperar, ou disse que o pedido demorou. Ambos merecem nova tentativa. |
| `base.inMilliseconds * (1 << tentativa)` | Backoff exponencial. `1 << n` é a forma rápida de `2^n`. |
| `random.nextInt(limitado ~/ 3)` | **Jitter**. Sem ele, mil clientes que falharam juntos repetiriam juntos — o efeito manada. |
| `erro.retryAfter` tendo prioridade | Se o servidor disse quanto esperar, ele manda. |
| `math.min(baseMs, maxima.inMilliseconds)` | Teto na espera: sem isso, a sexta tentativa esperaria minutos. |
| `Error.throwWithStackTrace(ultimoErro!, ultimaPilha!)` | Propaga o erro **com a pilha original**, não com a do `catch`. |
| `Provider<http.Client>` **sem** `autoDispose` | `close()` é definitivo; o cliente do app vive do início ao fim. |
| `ref.onDispose(cliente.close)` | Fecha quando o `ProviderScope` morre. |
| `int _sequencia = 0;` + `final int minhaVez = ++_sequencia;` | Protege contra resposta fora de ordem. Três linhas que resolvem um bug quase invisível. |
| `if (minhaVez != _sequencia) return;` **também no `catch`** | Um erro de busca obsoleta não deve aparecer na tela. |
| `_debounce?.cancel()` em `aoDigitar` | Cada tecla cancela o timer anterior: só a última vale. |
| `ref.onDispose(() => _debounce?.cancel())` | Um `Timer` pendente dispararia depois de o provider morrer. Módulo 08, aula 8. |
| `buscarAgora()` no `onSubmitted` | Enter não deve esperar 400 ms. |
| `_sequencia++` ao limpar o campo | Invalida buscas em voo: nada deve chegar depois de o usuário limpar. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Timeout padrão do sistema | ~1 min (varia por fabricante) | ~60 s |
| App em segundo plano | Doze suspende requisições | Suspende mais agressivamente |
| Troca Wi-Fi → dados móveis | A conexão cai; `SocketException` | Idem, e mais rápido |
| Requisição durante troca de rede | Falha e **merece retry** | Idem |
| Economia de dados ativada | Pode bloquear em segundo plano | *Low Data Mode* limita |
| Conexões simultâneas | Sem limite rígido | Sem limite rígido |

> 📌 A terceira e a quarta linhas são a razão mais comum de retry valer a pena em mobile: o usuário
> sai de casa, o Wi-Fi cai, os dados móveis assumem — e a requisição que estava em voo falha. Uma
> nova tentativa 400 ms depois **funciona**. Sem retry, o usuário vê "sem conexão" enquanto a
> internet está perfeitamente disponível.

> ⚠️ Quando o app volta do segundo plano, requisições que ficaram "penduradas" podem completar com
> erro. Trate `SocketException` ao retomar como um caso normal, não como falha do usuário — assunto
> do [Módulo 11, aula 6](../11-recursos-nativos/06-ciclo-de-vida-do-app.md).

---

## ⚠️ Erros comuns

### 1. Requisição sem timeout

```dart
final http.Response r = await cliente.get(url);   // ❌
```

Indicador girando para sempre.

**Correção:** `.timeout(const Duration(seconds: 15))`.

### 2. Retry de `POST`

```dart
await repetir(() => api.criar(nova));   // ❌ pode criar vários
```

**Correção:** `POST` fora do retry. Se precisar, use chave de idempotência (desafio da aula 5).

### 3. Retry sem backoff

```dart
for (int i = 0; i < 5; i++) {
  try { return await acao(); } catch (_) { }   // ❌ cinco tentativas instantâneas
}
```

Sobrecarrega um servidor que já está com problema.

**Correção:** espera exponencial entre as tentativas.

### 4. Backoff sem jitter

```dart
await Future.delayed(Duration(milliseconds: 400 * (1 << tentativa)));   // ⚠️
```

Mil clientes que falharam juntos repetem **exatamente** juntos.

**Correção:** acrescente variação aleatória.

### 5. Repetir erro `4xx`

```dart
if (r.statusCode != 200) throw ApiException(...);   // e o retry tenta de novo ⚠️
```

Um `400` repetido três vezes dá `400` três vezes — só gastou tempo e bateria.

**Correção:** `_ehTransitorio` filtrando por status.

### 6. `http.get` avulso em vez de cliente reutilizado

```dart
await http.get(url1);
await http.get(url2);   // ⚠️ dois handshakes TLS
```

**Correção:** um `http.Client` no provider, reutilizado.

### 7. Fechar o cliente cedo demais

```dart
final cliente = http.Client();
await cliente.get(url);
cliente.close();
// … mais tarde, outra tela:
await cliente.get(outraUrl);   // 💥
```

```text
ClientException: Client is already closed
```

**Correção:** o cliente do app vive num provider sem `autoDispose`.

### 8. Sem proteção de sequência numa busca

O usuário digita "dar", a resposta de "da" chega depois e sobrescreve a tela.

**Correção:** contador de sequência.

### 9. Sem debounce numa busca

Sete teclas, sete requisições. Em API com cobrança por chamada, isso é dinheiro.

**Correção:** `Debounce` de 300–500 ms.

### 10. Esquecer `Timer.cancel()` no `dispose`

```dart
_debounce = Timer(const Duration(milliseconds: 400), _buscar);
// … sem cancel ❌
```

O timer dispara depois de o provider morrer.

**Correção:** `ref.onDispose(() => _debounce?.cancel());`

### 11. Timeout curto demais

```dart
.timeout(const Duration(seconds: 3))   // ⚠️ em 4G ruim, falha sempre
```

**Correção:** 15 s para leitura; 5 s só onde a resposta perde valor rápido (busca).

### 12. Retry infinito

```dart
while (true) {
  try { return await acao(); } catch (_) { await Future.delayed(...); }   // ❌
}
```

O app fica preso, gastando bateria e dados sem nunca desistir.

**Correção:** limite de tentativas, e depois mostre o erro com "Tentar de novo".

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e execute os quatro botões. Anote as diferenças entre "Fora de
ordem ❌" e "Fora de ordem ✅".

**Passo 2.** No `_comRetry`, remova o jitter (use só `baseMs`). Rode três vezes e compare os tempos
de espera. Explique por que a aleatoriedade importa quando há mil clientes.

**Passo 3.** No `_comTimeout`, aumente o prazo para 8 segundos. A requisição passa a funcionar?
Quanto tempo o usuário esperou?

**Passo 4.** Em `repetir`, remova o `if (!_ehTransitorio(erro)) rethrow;`. Force um `404` e conte
quantas tentativas acontecem. Quanto tempo foi desperdiçado?

**Passo 5.** Coloque `criar` dentro de `repetir`. Simule uma falha de rede **depois** de o servidor
receber a requisição (use `httpbin.org/delay/10` com timeout de 2 s). Quantas trilhas seriam
criadas numa API real?

**Passo 6.** Abra o painel Network (`F12`) e digite "flutter" na busca rapidamente. Conte as
requisições. Depois remova o debounce e repita.

**Passo 7.** No `BuscaController`, remova `if (minhaVez != _sequencia) return;`. Digite "da", apague
tudo rápido e digite "git". Observe o resultado. Pode ser preciso repetir algumas vezes para o bug
aparecer — e é justamente essa intermitência que o torna difícil de achar em produção.

**Passo 8.** Troque `Provider<http.Client>` por `Provider.autoDispose<http.Client>`. Navegue para
outra tela e volte. Leia o erro.

**Passo 9.** Mude `Prazos.busca` para 500 ms. Faça buscas em rede lenta (o Chrome permite simular
em Network → Throttling). Descreva a experiência.

**Passo 10.** Responda por escrito: quais operações do `TrilhaApi` estão dentro de `repetir` e
quais não estão? Justifique cada uma com base em idempotência.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Faça os exercícios de **Aplicação** com backoff exponencial, o de **Correção de bugs** com resposta
fora de ordem, e o de **Decisão** sobre o que pode ser repetido.

---

## 🏆 Desafio opcional

Implemente um **circuit breaker** (disjuntor) no `foco_api`.

A ideia: se o servidor falhou 5 vezes seguidas, pare de tentar por 30 segundos. Assim o app não
gasta bateria e dados batendo numa porta fechada — e o servidor tem espaço para se recuperar.

Requisitos:

- Três estados: **fechado** (tudo normal), **aberto** (falha imediata, sem tentar) e
  **meio-aberto** (deixa **uma** requisição passar para testar).
- No estado aberto, a falha é imediata e a mensagem é específica: "Serviço indisponível. Tentando
  de novo em 12 s."
- Um sucesso no estado meio-aberto volta o disjuntor para fechado e zera o contador.
- Uma falha no meio-aberto volta para aberto, com o prazo dobrado.
- Um provider `estadoDoCircuitoProvider` expõe o estado para a tela mostrar.

Dica: um `sealed class EstadoCircuito` com os três casos, e um `Notifier` que o gerencia. O
`repetir` consulta o disjuntor antes de tentar.

Depois responda: em que situação o circuit breaker **atrapalha** o usuário? (Dica: pense em alguém
que trocou de rede e agora tem internet perfeita, mas o disjuntor ainda está aberto.) Como você
resolveria isso?

---

## 📌 Resumo

- **Toda requisição precisa de `.timeout()`.** Sem ele, ela pode ficar pendurada por mais de um
  minuto e o usuário conclui que o app travou.
- Prazos por operação: ~5 s para busca, ~15 s para leitura, ~30 s para escrita. **Timeout curto
  demais é pior que longo demais.**
- **Repita apenas falhas transitórias:** rede, timeout, `5xx`, `429`, `408`. **Nunca** `4xx` de
  cliente — repetir dá o mesmo erro.
- **Repita apenas operações idempotentes:** `GET`, `PUT`, `DELETE`. **`POST` nunca**, sem chave de
  idempotência.
- **Backoff exponencial** (dobrar a espera) evita sobrecarregar um servidor já com problema.
- **Jitter** (variação aleatória) evita o efeito manada: mil clientes repetindo no mesmo instante.
- Respeite o cabeçalho **`Retry-After`** quando o servidor o enviar.
- Limite as tentativas e ponha um **teto** na espera. Retry infinito é bug.
- **Reutilize um `http.Client`**: cada `http.get` avulso custa um handshake TLS novo.
- `close()` é **definitivo** — o cliente do app vive num provider **sem `autoDispose`**.
- **Resposta fora de ordem** é um bug real: use um **contador de sequência** e descarte respostas
  obsoletas (inclusive erros).
- **Debounce de 300–500 ms** numa busca transforma sete requisições em uma.
- Debounce e sequência resolvem problemas **diferentes** — use os dois juntos.
- `Timer` do debounce precisa ser cancelado no `onDispose`.

---

## ☑️ Checklist de domínio

- [ ] Toda requisição do meu app tem `.timeout()`.
- [ ] Escolho o prazo conforme o tipo de operação.
- [ ] Sei dizer quais erros merecem retry e quais não.
- [ ] Nunca coloco `POST` em retry automático, e sei explicar por quê.
- [ ] Implemento backoff exponencial com jitter.
- [ ] Respeito `Retry-After`.
- [ ] Ponho limite de tentativas e teto na espera.
- [ ] Reutilizo um `http.Client` em vez de `http.get` avulso.
- [ ] Meu cliente vive num provider sem `autoDispose` e fecha no `onDispose`.
- [ ] Protejo buscas com contador de sequência.
- [ ] Aplico debounce de 300–500 ms em campos de busca.
- [ ] Cancelo o `Timer` do debounce ao descartar.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Fetch data from the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [http package — pub.dev](https://pub.dev/packages/http)
- [Future.timeout — api.dart.dev](https://api.dart.dev/stable/dart-async/Future/timeout.html)
- [TimeoutException — api.dart.dev](https://api.dart.dev/stable/dart-async/TimeoutException-class.html)
- [Retry-After — MDN](https://developer.mozilla.org/docs/Web/HTTP/Headers/Retry-After)
- [429 Too Many Requests — MDN](https://developer.mozilla.org/docs/Web/HTTP/Status/429)
- [Exponential backoff and jitter — AWS Architecture Blog](https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — POST, PUT e DELETE](05-post-put-delete.md) | [README](README.md) | [Aula 7 — Camada de dados testável](07-camada-de-dados-testavel.md) |
