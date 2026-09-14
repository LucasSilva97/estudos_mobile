# Aula 2 — Futures e async/await

> **Módulo:** 04 - Dart Avançado · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar a diferença entre código **síncrono** e **assíncrono** e por que Dart precisa disso.
- Descrever o **event loop** e a diferença entre a **fila de microtasks** e a **fila de eventos**.
- Criar e consumir `Future` com `then` / `catchError` e com `async` / `await`.
- Rodar operações **em paralelo** com `Future.wait` e medir o ganho.
- Aplicar `Future.delayed` e `.timeout()` e tratar `TimeoutException`.
- Tratar erros em código assíncrono sem deixar exceção "solta".
- Usar `unawaited` quando você **de propósito** não espera um `Future`.

## ✅ Pré-requisitos

- [Aula 1 — Exceptions](01-exceptions.md): `try/catch/on` e `rethrow` são usados o tempo todo aqui.
- [Módulo 02 — Funções em Dart](../02-dart-basico/07-funcoes-em-dart.md) e
  [Módulo 03 — Generics](../03-dart-intermediario/08-generics.md).
- Um projeto Dart de terminal com pasta `bin/`.

---

## 📖 Conceito

### Síncrono × assíncrono

Código **síncrono** executa uma linha, termina, e só então executa a próxima. Se uma linha demora
3 segundos (ler um arquivo grande, chamar um servidor), **tudo** para por 3 segundos. Código
**assíncrono** permite dizer: "comece isso, avise quando terminar, e enquanto isso continue fazendo
o resto". Nada roda em paralelo por mágica — o programa apenas **não fica parado esperando**.

Isso importa demais no celular: a interface do Flutter redesenha a tela cerca de 60 vezes por
segundo. Se você bloquear a linha de execução por 2 segundos esperando a internet, o app congela —
o usuário toca nos botões e nada acontece.

### O modelo de execução do Dart: uma linha só

O Dart roda o seu código em **uma única linha de execução** por isolate (você verá isolates na
[aula 8](08-isolates-e-desempenho.md)). Não existe "duas funções suas rodando ao mesmo tempo".

O que existe é o **event loop** (*laço de eventos*): um laço infinito que, repetidamente,

1. executa todo o código síncrono pendente;
2. esvazia **por completo** a **fila de microtasks**;
3. pega **um** item da **fila de eventos** e executa;
4. volta ao passo 2.

| Fila | O que entra | Prioridade |
|---|---|---|
| **Microtask** | `Future.microtask(...)`, continuação depois de um `await` já resolvido | Mais alta — esvazia inteira antes de qualquer evento |
| **Eventos** | `Future(...)`, `Future.delayed(...)`, entrada/saída, temporizadores, toques na tela | Um por vez |

Consequência prática: uma microtask que nunca termina **trava o app inteiro**, porque a fila de
eventos (onde estão os toques do usuário) nunca chega a ser atendida.

### `Future` — a promessa de um valor

`Future<T>` (*futuro*) é um objeto que representa "um valor do tipo `T` que **ainda não** existe,
mas vai existir — ou vai falhar".

Um `Future` tem três estados: **pendente** (ainda rodando), **completo com valor** (terminou bem,
tem um `T` dentro) e **completo com erro** (tem uma exceção + stack trace dentro).
`Future<void>` significa "vai terminar, mas não devolve valor" — típico de salvar em disco.

### Duas formas de consumir: `then` e `await`

```dart
// Forma antiga, com callbacks (funções de retorno)
buscarNome().then((nome) => print(nome)).catchError((Object e) => print('Erro: $e'));

// Forma moderna, que se lê de cima para baixo
final nome = await buscarNome();
print(nome);
```

As duas fazem a mesma coisa. **Use `await`**: ele deixa o código assíncrono com a aparência do
código síncrono e permite `try/catch` normal. `then` ainda aparece em código antigo.

### `async` e `await`

- `async` marca a função: ela **sempre** devolve um `Future` e pode usar `await` dentro.
- `await` pausa **apenas aquela função** até o `Future` completar, devolvendo o valor de dentro.
  O restante do programa continua rodando.

```dart
Future<int> somarDepois(int a, int b) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  return a + b;              // vira Future<int> automaticamente
}
```

Regras que evitam 90% dos bugs:

1. Se a função tem `await`, ela **precisa** de `async`.
2. Se a função é `async`, o retorno **é** `Future<algo>`; declare `Future<int>`, não `int`.
3. Esquecer o `await` não dá erro de sintaxe — dá bug silencioso. O código segue sem esperar.
4. `main` pode ser `Future<void> main() async`.

### Em sequência × em paralelo

```dart
// Sequencial: 3 chamadas de 1s cada = ~3s
final a = await buscar(1);
final b = await buscar(2);
final c = await buscar(3);

// Paralelo: as 3 começam juntas = ~1s
final lista = await Future.wait([buscar(1), buscar(2), buscar(3)]);
```

`Future.wait` recebe uma lista de futures **já iniciados** e devolve um `Future<List<T>>` com os
resultados **na mesma ordem** da entrada. Se **qualquer** um falhar, o `Future.wait` falha.

> Dart 3 também aceita `final (a, b) = await (buscar(1), buscar(2)).wait;`, usando um **record**
> ([aula 4](04-records.md)) para esperar futures de **tipos diferentes** mantendo o tipo de cada um.

Use paralelo só quando as chamadas forem **independentes**. Se a segunda precisa do resultado da
primeira, sequencial é o certo.

### `timeout` — nunca espere para sempre

```dart
final dados = await buscar(1).timeout(const Duration(seconds: 15));
```

Se o `Future` não completar no prazo, `.timeout()` lança `TimeoutException` (do `dart:async`).
Você também pode fornecer um valor de reserva com `onTimeout:`.

> No curso, **toda** chamada HTTP leva `.timeout(Duration(seconds: 15))` — é a regra que você vai
> aplicar no [módulo 09](../09-consumo-de-api/06-timeout-retry-cancelamento.md).

### Erros em código assíncrono

Dentro de uma função `async`, `try` / `on` / `catch` funciona exatamente como no código síncrono —
inclusive para exceções lançadas antes do primeiro `await`. O perigo é o `Future` que ninguém
espera: se ele falhar, ninguém captura e o erro aparece como `Unhandled exception`, às vezes muito
depois, em outro ponto do programa.

### `unawaited` — "eu sei que não estou esperando"

Às vezes você **quer** disparar algo sem esperar (registrar uma métrica, por exemplo). Aí use
`unawaited()` do `dart:async`: ele documenta a intenção e silencia o lint `unawaited_futures`
([aula 7](07-analise-estatica-e-lints.md)).

```dart
unawaited(registrarMetrica('abriu_tela'));
```

Atenção: `unawaited` **não** trata o erro. Se aquela operação puder falhar, trate dentro dela.

## 💡 Analogia

Você está estudando e coloca um bolo no forno.

- **Síncrono** é ficar olhando o forno por 40 minutos sem fazer nada. **Assíncrono** é ligar o
  timer e voltar a estudar — o `Future` é o **timer**: a promessa de que daqui a pouco haverá bolo
  (ou cheiro de queimado, que é o erro).
- **`await`** é "não abro o caderno da próxima matéria antes de tirar o bolo": só **você** para,
  a casa continua funcionando.
- **Microtask** é o telefone tocando: você atende **antes** de responder à campainha da rua, e só
  volta para a campainha quando não houver mais telefone tocando.
- **`Future.wait`** é assar bolo, pão e torta ao mesmo tempo, em vez de um após o outro.
- **`timeout`** é a regra "se em 50 minutos não assar, eu desligo e peço pizza".

---

## 🧪 Exemplo mínimo

```dart
Future<void> main() async {
  print('1 - começou');
  final mensagem = await buscarMensagem();
  print('3 - $mensagem');
}

Future<String> buscarMensagem() async {
  print('2 - buscando...');
  await Future<void>.delayed(const Duration(seconds: 1));
  return 'chegou depois de 1 segundo';
}
```

Saída:

```text
1 - começou
2 - buscando...
3 - chegou depois de 1 segundo
```

---

## 📱 Aplicando no Flutter

Assíncrono **é** o dia a dia do Flutter. Tudo que sai do app (rede, disco, banco) devolve `Future`:

- **Chamar a API.** `http.get(...)` devolve `Future<Response>`. Em
  [09 — Primeiro GET](../09-consumo-de-api/03-primeiro-get.md) você escreve exatamente
  `final resposta = await http.get(url).timeout(const Duration(seconds: 15));` — o mesmo `await` e
  o mesmo `.timeout()` desta aula.
- **Banco local.** Em [10 — sqflite CRUD](../10-persistencia-de-dados/05-sqflite-crud.md), toda
  leitura e escrita é `await`.
- **Estado assíncrono na tela.** O Riverpod 3.4.3 tem `AsyncNotifier`, cujo método `build()` é
  `Future<T> build()`. O `AsyncValue` que ele produz nada mais é do que "o estado atual daquele
  `Future`": carregando, dados ou erro. Veja
  [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).
- **Não travar a tela.** O motivo pelo qual o Flutter exige tudo isso está em
  [13 — Assíncrono sem travar](../13-desempenho-e-seguranca/03-assincrono-sem-travar.md): se você
  bloquear a linha de execução, o app perde quadros e o usuário sente "travadinhas".

Uma regra que vale desde já: **carregar dados em paralelo com `Future.wait` é a diferença entre uma
tela que abre em 1 s e uma que abre em 3 s.**

---

## 💻 Código completo

> **Arquivo:** `bin/aula02_async.dart`
> **Como executar:** `dart run bin/aula02_async.dart`

```dart
// Aula 2 — Futures, async/await, event loop, Future.wait, timeout e unawaited.
import 'dart:async';

/// Simula uma chamada de rede que devolve o nome de uma matéria.
Future<String> buscarMateria(int id) async {
  if (id <= 0) {
    // Erro de programação: estoura mesmo dentro de código assíncrono.
    throw ArgumentError.value(id, 'id', 'deve ser maior que zero');
  }
  await Future<void>.delayed(const Duration(milliseconds: 400));
  if (id == 99) {
    throw const FormatException('Resposta do servidor veio corrompida');
  }
  return 'Matéria #$id';
}

/// Simula um servidor lento de propósito.
Future<String> buscarRelatorioLento() async {
  await Future<void>.delayed(const Duration(seconds: 3));
  return 'relatório completo';
}

/// Registra algo sem que ninguém precise esperar o resultado.
Future<void> registrarMetrica(String evento) async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
  print('   [metrica] $evento');
}

/// 1) Ordem de execução: síncrono, microtask e fila de eventos.
void demonstrarEventLoop() {
  print('--- 1) event loop ---');
  print('A - síncrono (roda já)');

  Future<void>(() => print('D - fila de eventos'));
  Future.microtask(() => print('C - fila de microtasks'));

  print('B - síncrono (roda já)');
}

/// 2) then/catchError (estilo antigo) x async/await (estilo atual).
Future<void> demonstrarThenEAwait() async {
  print('\n--- 2) then x await ---');

  // Estilo antigo: encadeamento de callbacks.
  await buscarMateria(1)
      .then((nome) => print('then: $nome'))
      .catchError((Object e) => print('then/catchError: $e'));

  // Estilo atual: lê-se de cima para baixo.
  try {
    final nome = await buscarMateria(2);
    print('await: $nome');
  } catch (e) {
    print('await/catch: $e');
  }
}

/// 3) Sequencial x paralelo, com medição real de tempo.
Future<void> compararSequencialEParalelo() async {
  print('\n--- 3) sequencial x paralelo ---');

  final relogioSequencial = Stopwatch()..start();
  final a = await buscarMateria(1);
  final b = await buscarMateria(2);
  final c = await buscarMateria(3);
  relogioSequencial.stop();
  print('sequencial: [$a, $b, $c] em ${relogioSequencial.elapsedMilliseconds} ms');

  final relogioParalelo = Stopwatch()..start();
  final lista = await Future.wait<String>([
    buscarMateria(1),
    buscarMateria(2),
    buscarMateria(3),
  ]);
  relogioParalelo.stop();
  print('paralelo:   $lista em ${relogioParalelo.elapsedMilliseconds} ms');
}

/// 4) Erros em código assíncrono.
Future<void> demonstrarErros() async {
  print('\n--- 4) erros assíncronos ---');

  try {
    await buscarMateria(99); // FormatException lá dentro
  } on FormatException catch (e) {
    print('tratei FormatException: ${e.message}');
  }

  // Um erro dentro de Future.wait derruba o conjunto inteiro.
  try {
    await Future.wait<String>([buscarMateria(1), buscarMateria(99)]);
  } on FormatException catch (e) {
    print('Future.wait falhou porque um item falhou: ${e.message}');
  }

  // Erro síncrono lançado dentro de função async também vira erro do Future.
  try {
    await buscarMateria(0);
  } on ArgumentError catch (e) {
    print('ArgumentError capturado com await: ${e.message}');
  }
}

/// 5) timeout: não espere para sempre.
Future<void> demonstrarTimeout() async {
  print('\n--- 5) timeout ---');

  try {
    final r = await buscarRelatorioLento()
        .timeout(const Duration(milliseconds: 500));
    print('não deve chegar aqui: $r');
  } on TimeoutException catch (e) {
    print('estourou o prazo: ${e.duration}');
  }

  // Versão com valor de reserva em vez de exceção.
  final comReserva = await buscarRelatorioLento().timeout(
    const Duration(milliseconds: 500),
    onTimeout: () => 'relatório indisponível (usando cache)',
  );
  print('com onTimeout: $comReserva');
}

/// 6) unawaited: disparar e seguir em frente, de propósito.
Future<void> demonstrarUnawaited() async {
  print('\n--- 6) unawaited ---');
  unawaited(registrarMetrica('abriu_relatorio'));
  print('   segui em frente sem esperar a métrica');
  // Espera curta só para a métrica aparecer antes do fim do programa.
  await Future<void>.delayed(const Duration(milliseconds: 100));
}

Future<void> main() async {
  demonstrarEventLoop();
  // Dá uma volta no event loop para C e D aparecerem antes do bloco 2.
  await Future<void>.delayed(Duration.zero);

  await demonstrarThenEAwait();
  await compararSequencialEParalelo();
  await demonstrarErros();
  await demonstrarTimeout();
  await demonstrarUnawaited();

  print('\nFim.');
}
```

Saída esperada (os milissegundos variam alguns pontos para cima ou para baixo):

```text
--- 1) event loop ---
A - síncrono (roda já)
B - síncrono (roda já)
C - fila de microtasks
D - fila de eventos

--- 2) then x await ---
then: Matéria #1
await: Matéria #2

--- 3) sequencial x paralelo ---
sequencial: [Matéria #1, Matéria #2, Matéria #3] em 1210 ms
paralelo:   [Matéria #1, Matéria #2, Matéria #3] em 404 ms

--- 4) erros assíncronos ---
tratei FormatException: Resposta do servidor veio corrompida
Future.wait falhou porque um item falhou: Resposta do servidor veio corrompida
ArgumentError capturado com await: deve ser maior que zero

--- 5) timeout ---
estourou o prazo: 0:00:00.500000
com onTimeout: relatório indisponível (usando cache)

--- 6) unawaited ---
   segui em frente sem esperar a métrica
   [metrica] abriu_relatorio

Fim.
```

Olhe os números do bloco 3: **1210 ms contra 404 ms** para o mesmo trabalho. Esse é o valor prático
do `Future.wait`.

---

## 🔍 Explicando o código

**`import 'dart:async';`**
Traz `TimeoutException` e `unawaited` (`Future` em si já vem no `dart:core`).

**`Future<void>.delayed(const Duration(milliseconds: 400))`**
Agenda uma continuação na **fila de eventos** para daqui a 400 ms — a forma honesta de simular
demora sem travar nada. Note o `<void>`: sem ele o Dart infere `Future<dynamic>`, e `dynamic`
desliga a checagem de tipos.

**`throw ArgumentError...` antes de qualquer `await`**
Mesmo lançando "antes de esperar", a função é `async` — então o erro **não** estoura na hora da
chamada: ele vira um `Future` completado com erro. É por isso que `await buscarMateria(0)` dentro
de `try` consegue capturar.

**`Future<void>(() => print('D - fila de eventos'))`**
O construtor `Future(...)` agenda o callback na **fila de eventos**. `Future.microtask(...)` agenda
na **fila de microtasks**, que tem prioridade. Por isso a saída é A, B, C, D — e **nunca** A, B, D, C.

**`.then((nome) => ...).catchError((Object e) => ...)`**
`then` recebe o valor quando o `Future` completa; `catchError` recebe o erro, declarado como
`Object` porque o Dart não sabe o tipo do que foi lançado. Repare como fica menos legível que o
`try`/`await` logo abaixo — por isso preferimos `await`.

**`Stopwatch()..start()`**
`Stopwatch` é o cronômetro do `dart:core`. O `..` é o *cascade* (*cascata*) do
[módulo 03](../03-dart-intermediario/01-classes-e-objetos.md): devolve o próprio `Stopwatch`, e
não o retorno de `start()`.

**`await Future.wait<String>([...])`**
As três chamadas são feitas **antes** do `await` — quando a lista é construída, os três futures já
estão rodando. Por isso o tempo total é o da mais lenta, e não a soma. O `<String>` explícito deixa
o tipo do resultado como `List<String>`.

**Bloco 4, `Future.wait` com um item que falha**
O `Future.wait` completa com erro assim que **um** item falha; os demais continuam rodando e seus
resultados são descartados. Se você precisa de todos os erros, trate cada `Future` individualmente
antes de juntá-los.

**`.timeout(const Duration(milliseconds: 500))`**
Cria um novo `Future` que completa com o valor original **ou** com `TimeoutException`, o que vier
primeiro; `e.duration` devolve o prazo configurado. Importante: `timeout` **não cancela** o
trabalho original — apenas para de esperar.

**`unawaited(registrarMetrica('abriu_relatorio'))`**
Sem ele, o analisador marcaria "future não aguardado" com a regra `unawaited_futures` ligada. Com
ele, você registra no código que a omissão é **intencional**.

**`await Future<void>.delayed(Duration.zero)` no `main`**
`Duration.zero` significa "agende para a próxima volta do event loop": um truque de demonstração
para as filas esvaziarem antes do próximo bloco. Em produção, evite depender dessa ordenação.

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | Esquecer o `await` | O valor impresso é `Instance of 'Future<String>'` ou a ordem sai errada | Coloque `await` (ou `unawaited`, se for proposital) |
| 2 | `await` em função sem `async` | `Error: 'await' can only be used in 'async' ... functions` | Marque a função com `async` |
| 3 | Declarar `String` em função `async` | `A value of type 'Future<String>' can't be returned...` | Declare `Future<String>` |
| 4 | `await` dentro de `for` para chamadas independentes | A tela demora N vezes mais | Monte a lista e use `Future.wait` |
| 5 | Chamada sem `timeout` | O app fica "carregando" para sempre quando a rede cai | `.timeout(const Duration(seconds: 15))` |
| 6 | `Future` que falha e ninguém espera | `Unhandled exception` aparece do nada | `await` com `try/catch`, ou trate dentro da própria função |
| 7 | `catchError` sem devolver valor | `Future<String>` recebe `null` e explode depois | Devolva um valor do mesmo tipo, ou use `try/catch` |
| 8 | Loop pesado dentro de `async` achando que "não trava" | A tela congela mesmo assim | `async` não cria thread; trabalho de CPU vai para isolate ([aula 8](08-isolates-e-desempenho.md)) |

O erro nº 8 é o mais mal compreendido: **`async` não deixa nada mais rápido nem cria paralelismo**.
Ele só organiza a espera por algo externo.

---

## 🛠️ Exercício guiado

Vamos construir um "carregador de tela inicial" que busca três coisas ao mesmo tempo, com prazo.

**Passo 1.** Crie `bin/guiado02_carregamento.dart` e comece com `import 'dart:async';`.

**Passo 2.** Escreva três funções simuladas, com tempos diferentes:

```dart
Future<int> carregarMinutosDaSemana() async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  return 320;
}

Future<List<String>> carregarMaterias() async {
  await Future<void>.delayed(const Duration(milliseconds: 900));
  return <String>['Dart', 'Flutter', 'SQL'];
}

Future<String> carregarFraseDoDia() async {
  await Future<void>.delayed(const Duration(seconds: 4)); // lenta de propósito
  return 'Constância vence intensidade.';
}
```

**Passo 3.** Faça a versão **sequencial** com `Stopwatch` e imprima o tempo total.

**Passo 4.** Faça a versão **paralela**, dando a cada chamada um prazo individual e um valor de
reserva para a frase:

```dart
final relogio = Stopwatch()..start();
final resultados = await Future.wait<Object>([
  carregarMinutosDaSemana(),
  carregarMaterias(),
  carregarFraseDoDia().timeout(
    const Duration(seconds: 1),
    onTimeout: () => 'Bons estudos!',
  ),
]);
relogio.stop();
print('paralelo em ${relogio.elapsedMilliseconds} ms -> $resultados');
```

**Passo 5.** Troque o `onTimeout:` por um `try` / `on TimeoutException` e observe a diferença: com
`onTimeout` a tela ainda abre; com exceção, o carregamento inteiro falha. Rode com
`dart run bin/guiado02_carregamento.dart`.

**Resultado esperado:** a versão sequencial leva por volta de 5,5 s; a paralela, por volta de 1 s,
usando a frase de reserva. Escreva em um comentário por que a diferença não é apenas "mais rápido",
mas também "mais confiável".

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md)

Priorize os exercícios de **Aplicação** e **Leitura de código** que envolvem ordem de execução.

---

## 🏆 Desafio opcional

Implemente `Future<T> tentarNovamente<T>(Future<T> Function() acao, {int tentativas = 3})`:

- executa `acao()`;
- se lançar, espera um tempo crescente (200 ms, 400 ms, 800 ms — *backoff exponencial*) e tenta
  de novo;
- depois de esgotar as tentativas, relança a última exceção com `rethrow`;
- nunca tenta de novo quando o erro for `ArgumentError` (bug não melhora com repetição).

Teste com uma função que falha nas duas primeiras chamadas e dá certo na terceira. Essa função é
praticamente a mesma que você vai reusar em
[09 — Timeout, retry e cancelamento](../09-consumo-de-api/06-timeout-retry-cancelamento.md).

---

## 📌 Resumo

- Dart executa **uma coisa por vez** por isolate; assíncrono é "não ficar parado esperando".
- O **event loop** esvazia toda a fila de **microtasks** antes de pegar o próximo item da fila de
  **eventos**.
- `Future<T>` é um valor que ainda não chegou: fica pendente, completa com valor ou com erro.
- `async` faz a função devolver `Future`; `await` pausa **só aquela função**.
- Chamadas independentes vão em `Future.wait` — o tempo passa a ser o da mais lenta.
- `.timeout()` impede espera infinita e lança `TimeoutException`; `onTimeout:` dá valor de reserva.
- `try/catch` funciona normalmente em `async`; `Future` sem dono que falha vira erro não tratado.
- `unawaited()` documenta que você **escolheu** não esperar.
- `async` **não** cria paralelismo de CPU — isso é assunto de isolates.

---

## ☑️ Checklist de domínio

- [ ] Explico por que `async` não deixa o cálculo mais rápido.
- [ ] Prevejo a ordem de saída de um trecho com `print`, `Future.microtask` e `Future(...)`.
- [ ] Converto um encadeamento `then/catchError` em `async/await` equivalente.
- [ ] Transformo três `await` sequenciais em um `Future.wait` e meço o ganho.
- [ ] Aplico `.timeout()` e trato `TimeoutException`.
- [ ] Sei dizer o que acontece quando um item do `Future.wait` falha.
- [ ] Uso `unawaited` no lugar certo e sei que ele não trata erro.
- [ ] Rodei `bin/aula02_async.dart` e conferi os tempos do bloco 3.

---

## 📚 Referências oficiais

- [Asynchronous programming: futures, async, await — dart.dev](https://dart.dev/libraries/async/async-await)
- [Asynchrony support — dart.dev](https://dart.dev/language/async)
- [Future class — api.dart.dev](https://api.dart.dev/stable/dart-async/Future-class.html)
- [TimeoutException class — api.dart.dev](https://api.dart.dev/stable/dart-async/TimeoutException-class.html)
- [Concurrency in Dart — dart.dev](https://dart.dev/language/concurrency)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Exceptions](01-exceptions.md) | [README](README.md) | [Aula 3 — Streams](03-streams.md) |
