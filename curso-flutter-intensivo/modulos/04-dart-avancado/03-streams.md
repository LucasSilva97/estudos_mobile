# Aula 3 — Streams

> **Módulo:** 04 - Dart Avançado · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é uma `Stream` e como ela difere de um `Future`.
- Diferenciar stream *single-subscription* de *broadcast* e escolher a certa.
- Consumir uma stream com `listen` e com `await for`.
- Criar streams com `async*` / `yield` e com `StreamController`.
- Guardar a `StreamSubscription` e **cancelar** para não vazar recurso.
- Transformar streams com `map`, `where` e `take`.
- Decidir, diante de um problema, se a resposta é `Future` ou `Stream`.

## ✅ Pré-requisitos

- [Aula 2 — Futures e async/await](02-futures-e-async-await.md): event loop, `Future`, `await`.
- [Aula 1 — Exceptions](01-exceptions.md): streams também emitem erros.
- [Módulo 02 — Listas](../02-dart-basico/08-listas.md): `map` e `where` já apareceram lá.

---

## 📖 Conceito

### `Future` entrega **um** valor. `Stream` entrega **vários**, ao longo do tempo

| | `Future<T>` | `Stream<T>` |
|---|---|---|
| Quantos valores | Exatamente 1 (ou 1 erro) | 0, 1, muitos, infinitos |
| Quando termina | Ao completar | Quando fecha (`done`) — ou nunca |
| Como consome | `await` | `listen(...)` ou `await for` |
| Exemplo do mundo real | Baixar o perfil do usuário | Cronômetro, digitação, mudança de conectividade |

`Stream<T>` (*fluxo*) é uma sequência de eventos. Cada evento é **um valor** `T` ou **um erro**,
e a stream pode, no fim, emitir o evento **done** ("acabou, não vem mais nada").

### Duas naturezas: single-subscription × broadcast

| | *Single-subscription* (padrão) | *Broadcast* (difusão) |
|---|---|---|
| Quantos ouvintes | **Um só**, para sempre | Quantos quiser, ao mesmo tempo |
| Se ninguém escuta | Os eventos **esperam** | Os eventos são **perdidos** |
| Criada por | `async*`, `StreamController()` | `StreamController.broadcast()` |
| Serve para | Ler um arquivo, uma resposta HTTP em pedaços | Eventos do sistema: conectividade, teclado |

Tentar escutar duas vezes uma stream single-subscription lança o erro:

```text
Bad state: Stream has already been listened to.
```

### Consumindo: `listen` e `await for`

```dart
final assinatura = minhaStream.listen(
  (valor) { print('chegou: $valor'); },        // onData — obrigatório na prática
  onError: (Object e) { print('erro: $e'); },  // erro NÃO encerra a stream por padrão
  onDone: () { print('acabou'); },
  cancelOnError: false,
);
```

`listen` devolve uma **`StreamSubscription`** (*assinatura*) — o seu controle remoto:
`cancel()`, `pause()` e `resume()`. **Guardar e cancelar a assinatura é obrigação sua.**

A outra forma é o `await for`, que só existe dentro de função `async`:

```dart
await for (final valor in minhaStream) {
  print(valor);
  if (valor == 3) break; // break cancela a assinatura automaticamente
}
```

`await for` é mais legível, mas **pausa a função** enquanto a stream não terminar. Para uma stream
infinita, só saia dela com `break` — ou use `listen`.

### Criando streams: `async*` e `yield`

Uma função marcada com `async*` (*async star*) devolve uma `Stream`. Dentro dela, `yield` emite um
valor e **continua** de onde parou na próxima vez.

```dart
Stream<int> contarAte(int limite) async* {
  for (var i = 1; i <= limite; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    yield i;              // emite um evento
  }
}                         // ao terminar a função, a stream emite "done"
```

Existe também `yield*` (*yield star*), que emite **todos** os eventos de outra stream:

```dart
Stream<int> contarDuasVezes(int limite) async* {
  yield* contarAte(limite);
  yield* contarAte(limite);
}
```

Compare com `async`: `async` + `return` = um valor no fim. `async*` + `yield` = vários valores ao
longo do caminho.

### Criando streams: `StreamController`

Quando os eventos **não** vêm de um laço seu, e sim de fora (um botão, um sensor, outra classe),
use `StreamController<T>`:

```dart
final controlador = StreamController<String>();

controlador.stream.listen(print);  // quem consome
controlador.add('evento 1');       // quem produz
controlador.addError(Exception('deu ruim'));
await controlador.close();         // encerra: dispara onDone
```

Regras de ouro:

1. Quem cria o controller é **responsável por fechá-lo** (`close()`).
2. `add` depois de `close` lança `StateError`.
3. Exponha apenas `controlador.stream` para fora; mantenha o `add` privado à sua classe.

### Transformando

Stream tem quase os mesmos métodos de `Iterable`, e cada um devolve uma **nova** stream:

| Método | O que faz |
|---|---|
| `map((v) => ...)` | transforma cada valor |
| `where((v) => ...)` | deixa passar só quem satisfaz a condição |
| `take(n)` / `skip(n)` | pega/pula os n primeiros |
| `distinct()` | ignora valores repetidos em sequência |
| `asyncMap((v) async => ...)` | transforma com uma operação assíncrona |
| `toList()` | junta tudo em um `Future<List<T>>` (só para streams finitas) |

### Cancelamento — o vazamento clássico

Uma stream que continua emitindo depois que a tela fechou mantém objetos vivos na memória e pode
até tentar atualizar uma tela que não existe mais. **Todo `listen` precisa de um `cancel()`
correspondente.**

### `Future` ou `Stream`? A decisão

| Pergunta | Se a resposta é... | Use |
|---|---|---|
| Quantas respostas eu preciso? | uma só | `Future` |
| O valor muda com o tempo e eu quero acompanhar? | sim | `Stream` |
| Isto é um "buscar e pronto"? | sim | `Future` |
| Isto é "me avise sempre que mudar"? | sim | `Stream` |

Exemplos: buscar as matérias do banco = `Future`. Cronômetro da sessão de estudo = `Stream`.
Estado da conexão de internet = `Stream`. Salvar uma meta = `Future`.

## 💡 Analogia

- Um **`Future`** é encomendar uma pizza: chega **uma** vez, ou o entregador liga dizendo que não
  vai dar (o erro).
- Uma **`Stream`** é assinar uma revista: vem um número por mês, por tempo indeterminado. Você
  **assina** (`listen`), pode **cancelar** (`cancel`) e a editora pode **encerrar** a publicação
  (`done`).
- Stream **single-subscription** é uma carta registrada: um destinatário só.
  Stream **broadcast** é o rádio: quem ligar ouve; quem não ligou perdeu o que já tocou.
- `map` e `where` são filtros que você coloca na caixa de correio antes de ler.

---

## 🧪 Exemplo mínimo

```dart
Stream<int> contarAte(int limite) async* {
  for (var i = 1; i <= limite; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    yield i;
  }
}

Future<void> main() async {
  await for (final numero in contarAte(3)) {
    print('recebi $numero');
  }
  print('stream terminou');
}
```

Saída (uma linha a cada 300 ms):

```text
recebi 1
recebi 2
recebi 3
stream terminou
```

---

## 📱 Aplicando no Flutter

No Flutter, `Stream` é o que faz a tela **reagir sozinha** a algo que muda:

- **`StreamBuilder`** é o widget que escuta uma stream e reconstrói a parte da tela a cada novo
  valor — sem você escrever `listen` nem `cancel` (ele cuida disso). Você o usa quando a fonte já é
  uma stream, por exemplo o cronômetro da sessão de estudo do projeto final
  ([projeto final — etapa 4](../../projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md)).
- **`StreamProvider` do Riverpod 3.4.3** faz o mesmo em nível de estado: você entrega uma `Stream`,
  ele entrega à tela um `AsyncValue` com carregando / dados / erro, já cancelando a assinatura
  quando ninguém mais escuta. Isso é o assunto de
  [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).
- **Conectividade.** O pacote `connectivity_plus` ^7.3.1 expõe as mudanças de rede como uma
  **stream broadcast**: cada vez que o celular troca de Wi-Fi para dados móveis, chega um evento.
  Veja [11 — Conectividade](../11-recursos-nativos/05-conectividade.md).
- **Vazamento de memória.** Quando você usa `listen` "na mão" dentro de um widget, precisa cancelar
  no `dispose()`. O ciclo de vida que torna isso obrigatório está em
  [05 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md).

Em resumo: **`Future` é para "carregue a tela"; `Stream` é para "mantenha a tela em dia".**

---

## 💻 Código completo

> **Arquivo:** `bin/aula03_streams.dart`
> **Como executar:** `dart run bin/aula03_streams.dart`

```dart
// Aula 3 — Streams: async*, StreamController, broadcast, transformações e cancelamento.
import 'dart:async';

/// Emite os minutos de uma sessão de estudo, um por "tique".
Stream<int> minutosDaSessao(int total) async* {
  for (var minuto = 1; minuto <= total; minuto++) {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    yield minuto;
  }
}

/// 1) Consumo com await for.
Future<void> demonstrarAwaitFor() async {
  print('--- 1) async* + await for ---');
  await for (final minuto in minutosDaSessao(3)) {
    print('   minuto $minuto');
  }
  print('   sessão encerrada (done)');
}

/// 2) Transformações: map, where e take.
Future<void> demonstrarTransformacoes() async {
  print('\n--- 2) map / where / take ---');

  final marcos = minutosDaSessao(6)
      .where((minuto) => minuto.isEven)
      .map((minuto) => 'marco de $minuto min')
      .take(2);

  await for (final marco in marcos) {
    print('   $marco');
  }

  // toList junta uma stream FINITA em uma lista só.
  final todos = await minutosDaSessao(3).toList();
  print('   toList: $todos');
}

/// 3) StreamController single-subscription, com erro no meio.
Future<void> demonstrarController() async {
  print('\n--- 3) StreamController ---');
  final controlador = StreamController<String>();

  final assinatura = controlador.stream.listen(
    (evento) => print('   recebi: $evento'),
    onError: (Object erro) => print('   erro: $erro'),
    onDone: () => print('   done: ninguém mais vai emitir'),
  );

  controlador.add('sessão iniciada');
  controlador.add('pausa');
  controlador.addError(const FormatException('evento sem formato'));
  controlador.add('retomada'); // continua: erro não encerra a stream
  await controlador.close();   // dispara onDone
  await assinatura.cancel();   // libera a assinatura
}

/// 4) Single-subscription NÃO aceita dois ouvintes.
Future<void> demonstrarDoisOuvintes() async {
  print('\n--- 4) single-subscription x broadcast ---');
  final unica = StreamController<int>();
  unica.stream.listen((v) => print('   ouvinte 1: $v'));
  try {
    unica.stream.listen((v) => print('   ouvinte 2: $v'));
  } on StateError catch (e) {
    print('   tentar ouvir 2 vezes falhou: ${e.message}');
  }
  unica.add(10);
  await unica.close();

  final radio = StreamController<int>.broadcast();
  final a = radio.stream.listen((v) => print('   A recebeu: $v'));
  final b = radio.stream
      .where((v) => v.isEven)
      .listen((v) => print('   B (só pares) recebeu: $v'));
  radio.add(1);
  radio.add(2);
  await radio.close();
  await a.cancel();
  await b.cancel();
}

/// 5) StreamSubscription: pausar, retomar e cancelar.
Future<void> demonstrarCancelamento() async {
  print('\n--- 5) cancelamento ---');

  // Stream.periodic é INFINITA: sem cancelar, roda para sempre.
  final relogio = Stream<int>.periodic(
    const Duration(milliseconds: 150),
    (indice) => indice + 1,
  );

  final assinatura = relogio.listen((tique) => print('   tique $tique'));

  await Future<void>.delayed(const Duration(milliseconds: 250));
  assinatura.pause();
  print('   pausei');

  await Future<void>.delayed(const Duration(milliseconds: 300));
  assinatura.resume();
  print('   retomei');

  await Future<void>.delayed(const Duration(milliseconds: 250));
  await assinatura.cancel();
  print('   cancelei — o relógio continuaria para sempre sem isto');
}

/// 6) break dentro de await for também cancela.
Future<void> demonstrarBreak() async {
  print('\n--- 6) break cancela a assinatura ---');
  await for (final minuto in minutosDaSessao(100)) {
    print('   minuto $minuto');
    if (minuto == 2) {
      break; // encerra a escuta sem esperar os outros 98
    }
  }
  print('   saí do laço com break');
}

Future<void> main() async {
  await demonstrarAwaitFor();
  await demonstrarTransformacoes();
  await demonstrarController();
  await demonstrarDoisOuvintes();
  await demonstrarCancelamento();
  await demonstrarBreak();
  print('\nFim.');
}
```

Saída esperada (no bloco 4, a ordem entre os ouvintes `A` e `B` pode variar, porque o `where` cria
mais uma etapa assíncrona; no bloco 5, a quantidade de tiques pode variar em uma unidade):

```text
--- 1) async* + await for ---
   minuto 1
   minuto 2
   minuto 3
   sessão encerrada (done)

--- 2) map / where / take ---
   marco de 2 min
   marco de 4 min
   toList: [1, 2, 3]

--- 3) StreamController ---
   recebi: sessão iniciada
   recebi: pausa
   erro: FormatException: evento sem formato
   recebi: retomada
   done: ninguém mais vai emitir

--- 4) single-subscription x broadcast ---
   tentar ouvir 2 vezes falhou: Stream has already been listened to.
   ouvinte 1: 10
   A recebeu: 1
   A recebeu: 2
   B (só pares) recebeu: 2

--- 5) cancelamento ---
   tique 1
   pausei
   retomei
   tique 2
   tique 3
   cancelei — o relógio continuaria para sempre sem isto

--- 6) break cancela a assinatura ---
   minuto 1
   minuto 2
   saí do laço com break

Fim.
```

---

## 🔍 Explicando o código

**`Stream<int> minutosDaSessao(int total) async*`**
O `*` depois de `async` é o que muda tudo: a função passa a devolver `Stream<int>` em vez de
`Future<int>`, e `yield` passa a ser permitido. Nada roda enquanto ninguém escutar — streams
criadas com `async*` são **preguiçosas** (*lazy*).

**`await for (final minuto in minutosDaSessao(3))`**
Escuta a stream evento a evento. A função que contém o `await for` fica pausada entre um evento e
outro, mas o resto do programa continua. Quando a stream emite *done*, o laço termina sozinho.

**`.where(...).map(...).take(2)`**
Cada método devolve uma **nova stream**; nada é executado até o `await for` começar a escutar.
A ordem importa: aqui filtramos os pares **antes** de formatar o texto, então `map` roda 3 vezes,
não 6 — e `take(2)` faz a stream encerrar assim que os dois primeiros marcos passarem.

**`await minutosDaSessao(3).toList()`**
Junta todos os eventos em um `Future<List<int>>`. Use **somente** em stream finita: em stream
infinita, esse `await` nunca retorna.

**`controlador.stream.listen(..., onError: ..., onDone: ...)`**
`onError` recebe `Object` porque qualquer objeto pode ter sido lançado. Por padrão
(`cancelOnError: false`) a stream **continua** depois de um erro — foi por isso que `retomada`
apareceu depois da `FormatException`.

**`await controlador.close();`**
Fecha a stream: dispara `onDone` e faz o `Future` de `close()` completar depois que todos os
eventos pendentes foram entregues. Esquecer o `close()` é o vazamento mais comum com
`StreamController`.

**`on StateError catch (e)` no bloco 4**
Um segundo `listen` em stream single-subscription lança `StateError` — que é `Error`, não
`Exception`: o Dart está dizendo "isto é um erro de projeto". Capturamos apenas para você ver a
mensagem exata; em código real, a correção é usar `.broadcast()`.

**`StreamController<int>.broadcast()`**
Aceita vários ouvintes. Repare que `B` recebeu apenas o `2`: a transformação `where` é aplicada
**por assinatura**, não na origem.

**`Stream<int>.periodic(...)`**
Emite um valor a cada intervalo, **para sempre**. O segundo argumento é uma função que recebe o
índice (0, 1, 2, ...) e devolve o valor emitido.

**`assinatura.pause()` / `resume()` / `cancel()`**
`pause` segura os eventos (a origem pode continuar produzindo e enfileirando), `resume` volta a
entregar e `cancel` encerra de vez. Depois de `cancel`, aquela assinatura não serve mais.

**`break` dentro do `await for`**
Sair do laço cancela a assinatura automaticamente. É o jeito mais limpo de consumir parte de uma
stream longa.

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | Escutar duas vezes uma stream single-subscription | `Bad state: Stream has already been listened to.` | Use `.broadcast()` ou reorganize para um ouvinte só |
| 2 | Esquecer `cancel()` | Memória cresce; código roda depois da tela fechar | Guarde a `StreamSubscription` e cancele |
| 3 | Esquecer `close()` no `StreamController` | `onDone` nunca chega; recursos presos | `await controlador.close()` no fim |
| 4 | `add` depois de `close` | `Bad state: Cannot add event after closing` | Verifique o ciclo de vida antes de emitir |
| 5 | `toList()` em stream infinita | O programa "trava" sem erro | Use `take(n)` antes, ou `listen` |
| 6 | Usar `Stream` para um valor único | Código mais complicado sem ganho | `Future` resolve |
| 7 | Esperar que broadcast guarde o passado | O ouvinte que chegou depois não recebe nada | Broadcast **não** tem memória; guarde o último valor você |
| 8 | Achar que `map` roda sem ouvinte | Nada acontece e você acha que travou | Stream só executa quando alguém escuta |

---

## 🛠️ Exercício guiado

Vamos criar um cronômetro de sessão de estudo com aviso de meta.

**Passo 1.** Crie `bin/guiado03_cronometro.dart` com `import 'dart:async';`.

**Passo 2.** Escreva a stream de segundos, que para sozinha ao chegar ao total:

```dart
Stream<int> cronometro(int totalSegundos) async* {
  for (var s = 1; s <= totalSegundos; s++) {
    await Future<void>.delayed(const Duration(milliseconds: 100)); // 100 ms = "1 segundo"
    yield s;
  }
}
```

**Passo 3.** Crie um `StreamController<String>` privado para os **avisos** e exponha só a stream:

```dart
class Sessao {
  final _avisos = StreamController<String>.broadcast();
  Stream<String> get avisos => _avisos.stream;

  Future<void> iniciar(int totalSegundos, {required int meta}) async {
    await for (final s in cronometro(totalSegundos)) {
      if (s == meta) {
        _avisos.add('Meta de $meta segundos alcançada!');
      }
      if (s == totalSegundos) {
        _avisos.add('Sessão concluída com $s segundos.');
      }
    }
    await _avisos.close();
  }
}
```

**Passo 4.** No `main`, assine os avisos, rode a sessão e cancele no fim:

```dart
Future<void> main() async {
  final sessao = Sessao();
  final assinatura = sessao.avisos.listen(
    (aviso) => print('AVISO: $aviso'),
    onDone: () => print('canal de avisos fechado'),
  );
  await sessao.iniciar(5, meta: 3);
  await assinatura.cancel();
}
```

**Passo 5.** Rode com `dart run bin/guiado03_cronometro.dart`.

**Passo 6.** Agora modifique: use `.where((a) => a.contains('Meta'))` em uma segunda assinatura e
comprove que broadcast aceita dois ouvintes com filtros diferentes.

**Resultado esperado:** dois avisos impressos (meta e conclusão) e a mensagem de canal fechado.
Com o passo 6, o segundo ouvinte imprime apenas o aviso de meta.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md)

Foque nos exercícios de **Implementação** que pedem `async*` e cancelamento.

---

## 🏆 Desafio opcional

Implemente `Stream<T> comAtraso<T>(Stream<T> origem, Duration espera)`, que reemite cada evento da
origem só depois de esperar `espera` — preservando **erros** e o evento *done*.

Dicas: use `async*` com `await for`, e envolva o corpo em `try` / `catch` para poder emitir o erro
adiante. Em seguida, escreva `Stream<int> apenasNovos(Stream<int> origem)` usando `distinct()` e
compare as duas abordagens: transformar "na mão" com `async*` × usar o método pronto.

---

## 📌 Resumo

- `Future` = um valor. `Stream` = vários valores ao longo do tempo, mais erros e um *done*.
- *Single-subscription* aceita **um** ouvinte; *broadcast* aceita vários e **não** guarda o passado.
- `listen` devolve uma `StreamSubscription`: `pause`, `resume` e, obrigatoriamente, `cancel`.
- `await for` é o consumo mais legível; `break` dentro dele cancela a assinatura.
- `async*` + `yield` cria stream a partir de um laço; `yield*` repassa outra stream inteira.
- `StreamController` é para eventos vindos de fora: exponha `.stream`, mantenha `add` privado,
  e **sempre** `close()`.
- `map`, `where`, `take`, `distinct` e `asyncMap` criam novas streams, preguiçosas.
- Nada acontece em uma stream enquanto ninguém escutar.

---

## ☑️ Checklist de domínio

- [ ] Explico, com um exemplo de app, quando usar `Future` e quando usar `Stream`.
- [ ] Escrevo uma função `async*` que emite valores com `yield`.
- [ ] Consumo a mesma stream de duas formas: `listen` e `await for`.
- [ ] Guardo a `StreamSubscription` e a cancelo.
- [ ] Crio um `StreamController`, exponho só `.stream` e fecho no fim.
- [ ] Sei o que acontece ao escutar duas vezes uma stream single-subscription.
- [ ] Encadeio `where` + `map` + `take` e explico a ordem de execução.
- [ ] Rodei `bin/aula03_streams.dart` e entendi cada bloco da saída.

---

## 📚 Referências oficiais

- [Asynchronous programming: Streams — dart.dev](https://dart.dev/libraries/async/using-streams)
- [Creating streams in Dart — dart.dev](https://dart.dev/libraries/async/creating-streams)
- [Stream class — api.dart.dev](https://api.dart.dev/stable/dart-async/Stream-class.html)
- [StreamController class — api.dart.dev](https://api.dart.dev/stable/dart-async/StreamController-class.html)
- [StreamSubscription class — api.dart.dev](https://api.dart.dev/stable/dart-async/StreamSubscription-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Futures e async/await](02-futures-e-async-await.md) | [README](README.md) | [Aula 4 — Records](04-records.md) |
