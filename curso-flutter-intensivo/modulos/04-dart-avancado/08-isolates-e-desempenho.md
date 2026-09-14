# Aula 8 — Isolates e desempenho

> **Módulo:** 04 - Dart Avançado · **Tempo estimado:** 35 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o modelo de concorrência do Dart e por que `async` **não** cria paralelismo.
- Descrever o que é um **isolate** e o que significa "memória isolada".
- Mover um cálculo pesado para outro isolate com `Isolate.run`.
- Reconhecer o `compute()` do Flutter e quando usá-lo.
- Trocar mensagens com `Isolate.spawn`, `ReceivePort` e `SendPort`.
- **Medir** com `Stopwatch` antes de decidir otimizar.
- Julgar quando um isolate vale a pena — e quando só atrapalha.

## ✅ Pré-requisitos

- [Aula 2 — Futures e async/await](02-futures-e-async-await.md): event loop e filas.
- [Aula 3 — Streams](03-streams.md): usaremos uma stream para provar que a execução não travou.
- [Aula 1 — Exceptions](01-exceptions.md): erros também atravessam isolates.

---

## 📖 Conceito

### O modelo de concorrência do Dart

Todo código Dart roda dentro de um **isolate** (*isolado*). Um isolate é composto por:

- **uma** linha de execução (não há duas funções suas rodando ao mesmo tempo dentro dele);
- **sua própria memória**, que nenhum outro isolate enxerga;
- **seu próprio event loop**, com as filas de microtasks e de eventos da
  [aula 2](02-futures-e-async-await.md).

Quando o programa começa, existe **um** isolate, chamado *main isolate*. É nele que o Flutter
desenha a tela.

Dessa arquitetura vêm duas consequências que você precisa ter na ponta da língua:

1. **`async`/`await` não deixa nada mais rápido.** Eles apenas evitam ficar parado esperando algo
   **externo** (rede, disco). Um laço que calcula por 3 segundos vai bloquear o isolate por
   3 segundos, com ou sem `async`.
2. **Paralelismo de verdade exige outro isolate.** Aí sim dois trechos de código rodam ao mesmo
   tempo, cada um no seu núcleo de processador.

### Memória isolada — a regra que muda tudo

Isolates **não compartilham memória**. Não existe variável global vista pelos dois, nem objeto
alterado por um e lido pelo outro. A comunicação é por **mensagem**, e a mensagem é **copiada**.

Isso elimina de uma vez a classe de bugs mais difícil da programação concorrente (dois trechos
alterando o mesmo dado ao mesmo tempo). Em troca, você paga o custo de **copiar** os dados que
entram e saem.

Consequência prática: mandar um número para o isolate é barato; mandar uma lista com 500 mil itens
custa tempo e memória — às vezes mais do que o cálculo que você queria acelerar.

### `Isolate.run` — a forma moderna e curta

```dart
final resultado = await Isolate.run(() => calculoPesado(3000000));
```

`Isolate.run`:

1. cria um isolate novo,
2. executa a função lá dentro,
3. devolve o resultado para o isolate original,
4. encerra o isolate criado.

Tudo isso em uma linha, com `await`. Se a função lançar, a exceção é **repassada** e você a captura
com `try/catch` normalmente.

### `compute()` — o atalho do Flutter

O Flutter oferece `compute(funcao, argumento)`, de `package:flutter/foundation.dart`. É a mesma
ideia de `Isolate.run`, com duas diferenças:

- a função precisa ser **top-level** (declarada fora de qualquer classe) ou **estática**, e recebe
  **um único** argumento;
- em Flutter **web**, onde não existem isolates, a função é executada na mesma linha de execução.

`compute` existe desde antes de `Isolate.run` e ainda é o que você mais vê em código Flutter,
principalmente para decodificar JSON grande.

### `Isolate.spawn`, `ReceivePort` e `SendPort` — quando há conversa

`Isolate.run` serve para "vai, calcula e volta". Quando o isolate precisa **mandar vários
resultados** (progresso, por exemplo) ou receber novas tarefas, você usa o modelo completo:

- **`ReceivePort`** é a caixa de entrada de quem espera. Ela é uma `Stream`.
- **`SendPort`** é o endereço dessa caixa, que você entrega ao outro isolate.
- **`Isolate.spawn(funcao, mensagem)`** cria o isolate e passa a mensagem inicial.

A função de entrada precisa ser top-level ou estática — ela é executada em outro isolate, que não
tem acesso ao seu contexto.

### Quando vale a pena

| Situação | Isolate ajuda? |
|---|---|
| Chamada HTTP, leitura de arquivo, consulta ao banco | **Não** — já é assíncrono, não bloqueia |
| Decodificar um JSON de poucos KB | Não — o custo de criar o isolate é maior |
| Decodificar um JSON de vários MB | **Sim** |
| Processar/redimensionar imagem | **Sim** |
| Ordenar/filtrar dezenas de milhares de itens | Talvez — **meça** |
| Criptografia, compressão, cálculo científico | **Sim** |
| Atualizar a interface | **Não** — só o main isolate desenha |

A régua prática do Flutter: a tela precisa desenhar um quadro a cada ~16 ms (60 quadros por
segundo). **Trabalho de CPU que passe disso, repetidamente, no main isolate, o usuário sente como
travamento.**

### Medir antes de otimizar

Otimizar sem medir é adivinhação — e costuma piorar. A medida mais simples é o `Stopwatch`:

```dart
final relogio = Stopwatch()..start();
final resultado = calculoPesado(1000000);
relogio.stop();
print('levou ${relogio.elapsedMilliseconds} ms');
```

Regras de medição honesta:

1. Meça **antes** e **depois** da mudança, na mesma máquina.
2. Rode mais de uma vez: a primeira execução costuma ser mais lenta (a máquina virtual do Dart
   ainda está "aquecendo").
3. Meça o tempo **e** o efeito colateral que importa (a tela travou? quantos quadros caíram?).
4. Se a diferença for pequena, mantenha o código mais simples.

## 💡 Analogia

Um isolate é uma **sala de estudos individual**: mesa, material e quadro próprios. Ninguém entra
para mexer no seu caderno.

Pedir ajuda a um colega é abrir outra sala (`Isolate.run`) e passar uma **fotocópia** do enunciado
por baixo da porta — nunca o caderno original. Ele resolve e devolve outra fotocópia com a
resposta. Por isso enunciado curto é barato e apostila inteira é cara.

Enquanto o colega calcula, você continua atendendo quem bate na sua porta: é exatamente isso que
mantém a tela do app respondendo.

---

## 🧪 Exemplo mínimo

```dart
import 'dart:isolate';

int somaAte(int limite) {
  var total = 0;
  for (var i = 1; i <= limite; i++) {
    total += i;
  }
  return total;
}

Future<void> main() async {
  final resultado = await Isolate.run(() => somaAte(100000000));
  print('soma = $resultado');
}
```

Saída:

```text
soma = 5000000050000000
```

O cálculo aconteceu em **outro** isolate; o `main` só esperou o resultado.

---

## 📱 Aplicando no Flutter

- **JSON grande.** Ao baixar uma lista longa da API, `jsonDecode` pode levar dezenas ou centenas de
  milissegundos — tempo suficiente para a rolagem engasgar. A solução padrão é
  `await compute(decodificarTrilhas, corpoDaResposta)`. Você faz isso em
  [09 — JSON](../09-consumo-de-api/02-json.md) e no
  [projeto final — etapa 5](../../projetos/03-projeto-final-multiplataforma/07-etapa-5-api-e-trilhas.md).
- **Diagnóstico de travamento.** Quando a animação "pula", o culpado quase sempre é trabalho de CPU
  no main isolate. Em [13 — Medindo desempenho](../13-desempenho-e-seguranca/04-medindo-desempenho.md)
  você aprende a enxergar isso no gráfico de quadros, e em
  [13 — Assíncrono sem travar](../13-desempenho-e-seguranca/03-assincrono-sem-travar.md) a corrigir.
- **DevTools.** O medidor de verdade do Flutter é o DevTools 2.60.0, com aba de CPU e de memória —
  assunto de [12 — DevTools](../12-testes-e-debug/03-devtools.md). O `Stopwatch` desta aula é o
  primeiro passo do mesmo hábito.
- **Cuidado com o custo.** Mandar uma lista enorme de objetos para o isolate e receber outra de
  volta pode custar mais que o cálculo. Meça sempre as **duas** versões.

---

## 🤖🍎 Android × iOS

Isolates funcionam nas duas plataformas, mas o contexto difere:

- 🤖 **Android** roda em aparelhos com capacidades muito diferentes — de 4 a 8 núcleos, ou menos em
  modelos de entrada. Um ganho medido no seu aparelho pode não se repetir em um aparelho simples;
  quando possível, meça também em um dispositivo modesto.
- 🍎 **iOS** é mais rígido com consumo de memória: o sistema encerra o app que ultrapassa o limite,
  sem aviso. Como cada isolate **copia** os dados recebidos, mandar coleções grandes aumenta o pico
  de memória e pode derrubar o app no iPhone antes de dar problema no Android.
- Em **ambos**, trabalho pesado no main isolate aparece como travamento na rolagem. A diferença é
  só quanto o usuário tolera antes de reclamar.

> Na **web**, o Flutter não tem isolates; `compute` executa a função na mesma linha de execução.
> O código continua compilando, mas o ganho não existe lá.

---

## 💻 Código completo

> **Arquivo:** `bin/aula08_isolates.dart`
> **Como executar:** `dart run bin/aula08_isolates.dart`

```dart
// Aula 8 — isolates: Isolate.run, Isolate.spawn com portas, e medição com Stopwatch.
import 'dart:async';
import 'dart:isolate';

const int limite = 300000;

/// Trabalho de CPU de verdade: soma todos os números primos até [ate].
int somaDosPrimos(int ate) {
  var soma = 0;
  for (var n = 2; n <= ate; n++) {
    if (_ehPrimo(n)) {
      soma += n;
    }
  }
  return soma;
}

bool _ehPrimo(int n) {
  if (n < 2) return false;
  if (n.isEven) return n == 2;
  for (var d = 3; d * d <= n; d += 2) {
    if (n % d == 0) return false;
  }
  return true;
}

/// Conta quantos "tiques" o isolate principal conseguiu processar
/// enquanto o trabalho pesado acontecia. É a nossa medida de "travou ou não".
class ContadorDeTiques {
  ContadorDeTiques() {
    _assinatura = Stream<int>.periodic(
      const Duration(milliseconds: 20),
      (i) => i,
    ).listen((_) => _tiques++);
  }

  late final StreamSubscription<int> _assinatura;
  int _tiques = 0;

  Future<int> parar() async {
    await _assinatura.cancel();
    return _tiques;
  }
}

/// 1) Trabalho pesado NO isolate principal: bloqueia tudo.
Future<void> bloqueando() async {
  print('--- 1) direto no isolate principal ---');
  final contador = ContadorDeTiques();
  final relogio = Stopwatch()..start();

  final soma = somaDosPrimos(limite); // nada mais roda enquanto isto executa

  relogio.stop();
  final tiques = await contador.parar();
  print('   soma = $soma');
  print('   tempo = ${relogio.elapsedMilliseconds} ms');
  print('   tiques processados durante o cálculo: $tiques');
}

/// 2) Mesmo trabalho em OUTRO isolate: o principal continua livre.
Future<void> comIsolateRun() async {
  print('\n--- 2) com Isolate.run ---');
  final contador = ContadorDeTiques();
  final relogio = Stopwatch()..start();

  final soma = await Isolate.run(() => somaDosPrimos(limite));

  relogio.stop();
  final tiques = await contador.parar();
  print('   soma = $soma');
  print('   tempo = ${relogio.elapsedMilliseconds} ms');
  print('   tiques processados durante o cálculo: $tiques');
}

/// 3) Erro dentro do isolate atravessa de volta como exceção normal.
Future<void> erroNoIsolate() async {
  print('\n--- 3) erro dentro do isolate ---');
  try {
    await Isolate.run(() {
      throw const FormatException('falhei lá dentro');
    });
  } on FormatException catch (e) {
    print('   capturei no isolate principal: ${e.message}');
  }
}

/// Função de entrada do isolate criado por spawn.
/// Precisa ser top-level (ou estática) e receber UMA mensagem.
void _trabalhador(List<Object> mensagem) {
  final envio = mensagem[0] as SendPort;
  final ate = mensagem[1] as int;

  // Envia progresso em três etapas e depois o resultado final.
  var soma = 0;
  final passo = ate ~/ 3;
  for (var bloco = 1; bloco <= 3; bloco++) {
    final fim = bloco == 3 ? ate : passo * bloco;
    final inicio = passo * (bloco - 1) + 1;
    for (var n = inicio; n <= fim; n++) {
      if (_ehPrimo(n)) soma += n;
    }
    envio.send('progresso: ${bloco * 33}%');
  }
  envio.send(soma);
}

/// 4) Isolate.spawn com ReceivePort/SendPort: várias mensagens de volta.
Future<void> comSpawn() async {
  print('\n--- 4) Isolate.spawn com portas ---');
  final caixaDeEntrada = ReceivePort();

  await Isolate.spawn(_trabalhador, <Object>[caixaDeEntrada.sendPort, limite]);

  // ReceivePort é uma Stream: dá para escutar com await for.
  await for (final mensagem in caixaDeEntrada) {
    if (mensagem is String) {
      print('   $mensagem');
    } else if (mensagem is int) {
      print('   resultado final = $mensagem');
      break; // sair do laço cancela a escuta
    }
  }
  caixaDeEntrada.close();
}

/// 5) Medir antes de otimizar: isolate para trabalho MINÚSCULO piora.
Future<void> quandoNaoVale() async {
  print('\n--- 5) quando o isolate NÃO vale a pena ---');

  final direto = Stopwatch()..start();
  final a = somaDosPrimos(2000);
  direto.stop();

  final isolado = Stopwatch()..start();
  final b = await Isolate.run(() => somaDosPrimos(2000));
  isolado.stop();

  print('   direto:  $a em ${direto.elapsedMicroseconds} µs');
  print('   isolate: $b em ${isolado.elapsedMicroseconds} µs');
  print('   criar o isolate custou mais que o próprio cálculo.');
}

Future<void> main() async {
  await bloqueando();
  await comIsolateRun();
  await erroNoIsolate();
  await comSpawn();
  await quandoNaoVale();
  print('\nFim.');
}
```

Saída esperada — **os tempos mudam de máquina para máquina**; o que importa é a **relação** entre
os números, principalmente a linha de tiques:

```text
--- 1) direto no isolate principal ---
   soma = 3709507114
   tempo = 420 ms
   tiques processados durante o cálculo: 0

--- 2) com Isolate.run ---
   soma = 3709507114
   tempo = 470 ms
   tiques processados durante o cálculo: 21

--- 3) erro dentro do isolate ---
   capturei no isolate principal: falhei lá dentro

--- 4) Isolate.spawn com portas ---
   progresso: 33%
   progresso: 66%
   progresso: 99%
   resultado final = 3709507114

--- 5) quando o isolate NÃO vale a pena ---
   direto:  277050 em 61 µs
   isolate: 277050 em 7412 µs
   criar o isolate custou mais que o próprio cálculo.
```

Leia o bloco 1 contra o bloco 2: o **tempo total é parecido** (o isolate até demora um pouco mais,
por causa da criação e da cópia), mas os **tiques** saltaram de zero para mais de vinte. É esse o
ganho: não é velocidade, é **responsividade**.

---

## 🔍 Explicando o código

**`class ContadorDeTiques`**
É o nosso "medidor de travamento". Uma `Stream.periodic` de 20 ms tenta incrementar um contador.
Se o isolate principal estiver ocupado em um laço, o event loop não roda e **nenhum** tique é
processado. O contador é, portanto, uma medida direta de quanto o programa ficou surdo.

**`final soma = somaDosPrimos(limite);` no bloco 1**
Repare que não há `await` — e não adiantaria colocar. Como explicamos na
[aula 2](02-futures-e-async-await.md), `async` só organiza espera por algo externo; um laço de CPU
bloqueia o isolate de qualquer jeito.

**`await Isolate.run(() => somaDosPrimos(limite))`**
A função anônima é executada em um isolate novo. Ela **captura** a constante `limite`, que é
copiada para lá. O valor de retorno volta copiado, e o isolate é encerrado automaticamente.

**`throw const FormatException(...)` dentro de `Isolate.run`**
A exceção atravessa a fronteira entre isolates e é relançada no chamador, com `on ... catch`
funcionando normalmente. Você não precisa de tratamento especial.

**`void _trabalhador(List<Object> mensagem)`**
Precisa ser uma função **top-level** porque o isolate novo não tem acesso ao contexto do isolate
que o criou — não dá para passar um método de instância que dependa de campos. A mensagem é uma
lista com dois itens porque `Isolate.spawn` aceita **um** argumento; o `as SendPort` e o `as int`
recuperam os tipos.

**`envio.send('progresso: ...')` e `envio.send(soma)`**
`SendPort.send` empacota o valor e o coloca na caixa de entrada do outro isolate. Números, textos,
listas e mapas desses tipos são seguros de enviar.

**`await for (final mensagem in caixaDeEntrada)`**
`ReceivePort` é uma `Stream`, então vale tudo da [aula 3](03-streams.md). Usamos `is String` e
`is int` para separar progresso de resultado; o `break` encerra a escuta, e `close()` libera a
porta — **esquecer o `close()` deixa o programa rodando para sempre**.

**Bloco 5, `elapsedMicroseconds`**
Para trabalho pequeno, milissegundos não têm resolução suficiente. O resultado mostra o custo fixo
de criar um isolate e copiar dados: para 2000 números, esse custo é dezenas de vezes maior que o
cálculo. É a prova prática de "meça antes de otimizar".

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | Achar que `async` cria paralelismo | A tela trava mesmo com `await` | Trabalho de CPU vai para isolate |
| 2 | Usar isolate para chamada HTTP | Código mais complexo, zero ganho | I/O já é assíncrono |
| 3 | Passar função de instância para `Isolate.spawn` | Erro ao criar o isolate | Use função top-level ou estática |
| 4 | Esperar que o isolate veja suas variáveis globais | O valor chega diferente do esperado | Memória é isolada; envie por mensagem |
| 5 | Mandar coleção gigante para o isolate | Fica mais lento e o app consome mais memória | Envie o mínimo; meça as duas versões |
| 6 | Esquecer `ReceivePort.close()` | O programa não termina | Feche a porta ao concluir |
| 7 | Criar um isolate por item de uma lista | Enxurrada de isolates e memória estourada | Um isolate processa o lote inteiro |
| 8 | Otimizar sem medir | Código mais complicado e igualmente lento | `Stopwatch` antes e depois |

---

## 🛠️ Exercício guiado

Vamos medir e depois corrigir um "app de terminal que trava".

**Passo 1.** Crie `bin/guiado08_relatorio.dart` com uma função pesada de verdade:

```dart
int contarPalavras(int repeticoes) {
  final texto = 'estudar dart flutter todos os dias ' * 200;
  var total = 0;
  for (var i = 0; i < repeticoes; i++) {
    total += texto.split(' ').where((p) => p.isNotEmpty).length;
  }
  return total;
}
```

**Passo 2.** Escreva um contador de tiques como o da aula (stream de 20 ms incrementando um
contador) e meça a versão **direta**: tempo e tiques.

**Passo 3.** Troque por `await Isolate.run(() => contarPalavras(2000));` e meça de novo. Compare as
duas linhas de tiques.

**Passo 4.** Reduza `repeticoes` para `5` e repita as duas medições. Anote em comentário a partir
de qual tamanho o isolate passou a compensar **na sua máquina**.

**Passo 5.** Troque `Isolate.run` por `Isolate.spawn` com `ReceivePort`, enviando o progresso a
cada 500 repetições. Rode com `dart run bin/guiado08_relatorio.dart`.

**Resultado esperado:** na versão direta, os tiques ficam em zero ou perto disso; com isolate, eles
sobem. O tempo total do isolate é igual ou levemente maior — e essa é a conclusão a escrever:
isolate compra **responsividade**, não velocidade bruta.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md)

Foque nos exercícios de **Desafio prático** e nos de **Revisão cumulativa** do módulo.

---

## 🏆 Desafio opcional

Implemente um "pool de trabalho": uma função
`Future<List<int>> processarEmLotes(List<int> entradas, {int lotes = 4})` que divide a lista em
`lotes` pedaços, envia **cada pedaço** para um `Isolate.run` diferente, espera todos com
`Future.wait` ([aula 2](02-futures-e-async-await.md)) e junta os resultados na ordem original.

Depois meça, com `Stopwatch`, três versões: sequencial no isolate principal, um isolate só, e o
pool com 2, 4 e 8 lotes. Anote em que ponto parar de dividir deixa de ajudar — e relacione isso com
o número de núcleos da sua máquina.

---

## 📌 Resumo

- Todo Dart roda em um **isolate**: uma linha de execução, uma memória, um event loop.
- `async`/`await` **não** cria paralelismo; só evita espera ociosa por I/O.
- Isolates **não compartilham memória**: trocam mensagens **copiadas**.
- `Isolate.run(() => ...)` é a forma curta: cria, executa, devolve e encerra.
- `compute(funcao, argumento)` é o atalho do Flutter (função top-level ou estática, um argumento);
  na web, roda na mesma linha de execução.
- `Isolate.spawn` + `ReceivePort`/`SendPort` serve quando há conversa ou progresso.
- Isolate vale para **CPU pesada**; não vale para I/O nem para trabalho pequeno.
- **Meça** com `Stopwatch` antes e depois: se o ganho for pequeno, fique com o código simples.

---

## ☑️ Checklist de domínio

- [ ] Explico por que `async` não resolve travamento por cálculo.
- [ ] Descrevo o que significa "isolates não compartilham memória".
- [ ] Movo uma função pesada para `Isolate.run` e capturo o erro que ela lança.
- [ ] Sei por que `compute()` exige função top-level ou estática.
- [ ] Monto `Isolate.spawn` com `ReceivePort` e fecho a porta no fim.
- [ ] Meço com `Stopwatch` e explico a diferença entre tempo total e responsividade.
- [ ] Digo três casos em que isolate **não** ajuda.
- [ ] Rodei `bin/aula08_isolates.dart` e comparei os tiques dos blocos 1 e 2.

---

## 📚 Referências oficiais

- [Concurrency in Dart — dart.dev](https://dart.dev/language/concurrency)
- [Isolates — dart.dev](https://dart.dev/language/isolates)
- [Isolate class — api.dart.dev](https://api.dart.dev/stable/dart-isolate/Isolate-class.html)
- [ReceivePort class — api.dart.dev](https://api.dart.dev/stable/dart-isolate/ReceivePort-class.html)
- [Stopwatch class — api.dart.dev](https://api.dart.dev/stable/dart-core/Stopwatch-class.html)
- [Improving rendering performance — docs.flutter.dev](https://docs.flutter.dev/perf/rendering-performance)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — Análise estática e lints](07-analise-estatica-e-lints.md) | [README](README.md) | [Avaliação do módulo 04](../../avaliacoes/modulo-04-dart-avancado.md) |
