# Aula 1 — Exceptions e tratamento de erros

> **Módulo:** 04 - Dart Avançado · **Tempo estimado:** 35 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar a diferença entre `Exception` e `Error` e decidir qual usar.
- Lançar um erro com `throw` e interceptá-lo com `try` / `on` / `catch` / `finally`.
- Capturar o *stack trace* e usar `rethrow` sem perder informação.
- Criar exceções customizadas com dados do seu domínio.
- Decidir, com critério, entre **lançar uma exceção** e **devolver o erro como valor**.
- Implementar o **Result pattern** com `sealed class` e consumi-lo com `switch`.

## ✅ Pré-requisitos

- [Módulo 03 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md),
  [Abstratas e interfaces](../03-dart-intermediario/05-abstratas-e-interfaces.md) e
  [Generics](../03-dart-intermediario/08-generics.md) — usaremos `Resultado<S, F>`.
- [Módulo 01 — Lendo mensagens de erro](../01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md).
- Um projeto Dart de terminal com pasta `bin/`.

---

## 📖 Conceito

### O que é uma exceção

Uma **exceção** (*exception*) é um objeto que representa "algo deu errado aqui e eu não consigo
continuar". Quando o código **lança** (`throw`) uma exceção, a execução daquela função para
imediatamente e o Dart começa a **subir a pilha de chamadas** (*call stack* — a lista de funções
que chamaram umas às outras até chegar ali) procurando alguém que saiba tratar aquilo.

Se ninguém tratar, o programa termina e o Dart imprime a exceção mais o **stack trace**
(*rastro de pilha*) — o caminho exato de funções que levou ao problema.

### `Exception` × `Error` — a distinção que quase todo iniciante erra

O Dart tem **dois** tipos-base para problemas, e eles significam coisas diferentes:

| | `Exception` | `Error` |
|---|---|---|
| Significa | Condição **esperada** que pode acontecer em produção | **Bug de programação** |
| Exemplos | `FormatException`, `TimeoutException`, `HttpException` | `StateError`, `ArgumentError`, `RangeError`, `TypeError` |
| Você deve capturar? | **Sim**, e tratar | **Não.** Corrija o código que causou |
| Analogia | O caixa eletrônico ficou sem dinheiro | Você digitou a senha no campo de saldo |

Regra prática do curso:

> Se o usuário, a rede ou o disco podem causar aquilo, é `Exception`.
> Se só um programador distraído causa aquilo, é `Error`.

Exemplo concreto: `int.parse('abc')` lança `FormatException` — é `Exception`, porque o texto pode
vir do usuário. Já `<int>[].first` lança `StateError` — é `Error`, porque você deveria ter checado
`isEmpty` antes.

> Detalhe importante: em Dart, `Exception` é apenas uma **interface** (um contrato) quase vazia —
> ela **não** obriga a ter mensagem nem stack trace. Quem dá utilidade a ela é você, escrevendo
> um `toString()` decente na sua exceção customizada.

### `throw` e `try` / `on` / `catch` / `finally`

Lançar é uma linha: `throw FormatException('CPF precisa ter 11 dígitos');`. Tecnicamente o Dart
permite lançar **qualquer** objeto não nulo (até `throw 'texto'`). **Não faça isso**: lançar
`String` impede quem captura de distinguir um erro do outro com `on`.

```dart
try {
  // código que pode falhar
} on FormatException catch (e) {
  // trata SÓ FormatException; 'e' é a exceção
} on Exception catch (e, s) {
  // trata qualquer outra Exception; 's' é o StackTrace
} catch (e, s) {
  // trata QUALQUER coisa lançada (inclusive Error)
} finally {
  // roda SEMPRE: deu certo, deu errado, ou houve return no meio
}
```

Regras:

- `on Tipo` filtra **pelo tipo**. Use sempre que souber o que pode acontecer.
- `catch (e)` pega tudo. `catch (e, s)` pega tudo **e** o stack trace.
- A ordem importa: o Dart testa os `on` de cima para baixo e usa o **primeiro** que casar — por
  isso o `on Exception` genérico vai por último.
- `finally` é para **liberar recurso** (fechar arquivo, conexão, cronômetro).

### `rethrow` — relançar sem apagar o rastro

Às vezes você quer **reagir** ao erro (registrar em log, fechar algo) mas **não** quer resolvê-lo:
quem chamou precisa saber que falhou.

```dart
try {
  fazerAlgo();
} catch (e) {
  print('Falhou, vou avisar quem me chamou');
  rethrow; // relança a MESMA exceção com o MESMO stack trace
}
```

Nunca escreva `catch (e) { throw e; }` no lugar de `rethrow`: `throw e` **reinicia** o stack trace
a partir dali, e você perde a informação de onde o problema realmente nasceu.

### Quando lançar e quando devolver o erro como valor

Lançar exceção é ótimo para o que é **excepcional**. Mas a assinatura `Usuario buscar(int id)`
**não conta** que ela pode falhar — quem chama descobre em produção. Por isso, para erros
previsíveis e frequentes (rede caiu, CPF inválido, item não encontrado), existe a alternativa de
devolver um valor que já representa "deu certo" ou "deu errado".

| Situação | Escolha |
|---|---|
| Argumento inválido que é bug do programador | `throw ArgumentError` |
| Estado impossível no seu código | `throw StateError` |
| Erro raro, e quem chama não tem o que fazer além de mostrar mensagem | `throw` exceção customizada |
| Erro **esperado**, que a camada acima precisa tratar caso a caso | devolver `Resultado<S, F>` |

### Result pattern

O **Result pattern** é um tipo que carrega **ou** o valor de sucesso **ou** a falha:

```dart
sealed class Resultado<S, F> { const Resultado(); }
final class Sucesso<S, F> extends Resultado<S, F> { const Sucesso(this.valor); final S valor; }
final class Falha<S, F> extends Resultado<S, F> { const Falha(this.erro); final F erro; }
```

`sealed` (*selada*) significa que **só** as subclasses escritas neste mesmo arquivo existem (aula
[6](06-sealed-classes.md)). A consequência prática é que o `switch` sobre um `Resultado` fica
**exaustivo**: esqueceu de tratar `Falha`, o compilador reclama **antes** de rodar.

## 💡 Analogia

Pense em uma cozinha de restaurante.

- **`Error`** é ter esquecido de comprar o fogão. Não adianta "tratar": o projeto está errado.
- **`Exception`** é acabar o tomate no meio do serviço — previsível, e a cozinha precisa de plano.
- **`finally`** é desligar o fogo: deu certo ou deu errado, o fogo é desligado.
- **`rethrow`** é anotar "acabou o tomate" e mandar o problema ao gerente sem apagar a anotação.
- **Result pattern** é o garçom sempre voltar com uma bandeja: ou tem o prato, ou tem um bilhete
  explicando por que não tem. Ele nunca some no caminho.

---

## 🧪 Exemplo mínimo

```dart
void main() {
  try {
    final idade = int.parse('vinte'); // lança FormatException
    print('Idade: $idade');
  } on FormatException catch (e) {
    print('Texto não é um número: ${e.message}');
  } finally {
    print('Terminei a checagem.');
  }
}
```

Saída:

```text
Texto não é um número: vinte
Terminei a checagem.
```

---

## 📱 Aplicando no Flutter

No Flutter, **toda** tela que busca dados pode falhar, e o usuário precisa ver uma mensagem em vez
de uma tela branca. É exatamente este conteúdo que faz isso funcionar:

- **Chamadas de API.** Em [09 — Modelando respostas e erros](../09-consumo-de-api/04-modelando-respostas-e-erros.md)
  você vai capturar `SocketException` (sem internet), `TimeoutException` (servidor demorou) e
  `FormatException` (JSON veio quebrado) — os três com `on ... catch`, exatamente como aqui.
- **Exceções de domínio.** O projeto final tem o arquivo `lib/core/erros/falhas.dart`, que é
  literalmente um conjunto de exceções customizadas como as desta aula
  ([projeto final — etapa 2](../../projetos/03-projeto-final-multiplataforma/04-etapa-2-dominio-e-dados.md)).
- **Estado de erro na tela.** O Riverpod 3.4.3 tem o tipo `AsyncValue`, que representa
  "carregando / dados / erro" — a mesma ideia do `Resultado<S, F>` desta aula, só que pronta.
  Você vê isso em [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).
- **Ler o erro.** Quando o app quebrar, o Flutter imprime um stack trace no terminal. Ler aquilo é
  o assunto de [12 — Lendo stack traces](../12-testes-e-debug/01-lendo-stack-traces.md), e a
  habilidade começa aqui.

Em uma frase: **hoje você aprende a falhar de forma organizada; no Flutter isso vira a tela de erro
com botão "Tentar de novo".**

---

## 💻 Código completo

> **Arquivo:** `bin/aula01_exceptions.dart`
> **Como executar:** `dart run bin/aula01_exceptions.dart`

```dart
// Aula 1 — Exceptions, rethrow e Result pattern.
// Simula um pequeno serviço de conta de estudos: o aluno "gasta" minutos de foco.

/// Exceção de domínio: não há saldo de minutos suficiente.
///
/// `implements Exception` marca a classe como um erro ESPERADO de negócio.
class SaldoInsuficienteException implements Exception {
  const SaldoInsuficienteException({
    required this.saldoAtual,
    required this.valorPedido,
  });

  final int saldoAtual;
  final int valorPedido;

  int get faltam => valorPedido - saldoAtual;

  @override
  String toString() =>
      'SaldoInsuficienteException: saldo de $saldoAtual min, '
      'pedido de $valorPedido min (faltam $faltam min)';
}

/// Exceção de domínio: a matéria informada não existe.
class MateriaNaoEncontradaException implements Exception {
  const MateriaNaoEncontradaException(this.nome);

  final String nome;

  @override
  String toString() => 'MateriaNaoEncontradaException: "$nome" não existe';
}

/// ---------------------------------------------------------------------------
/// Result pattern
/// ---------------------------------------------------------------------------

/// Tipo que carrega OU um sucesso OU uma falha. Nunca os dois, nunca nenhum.
///
/// `sealed` fecha a hierarquia: só Sucesso e Falha existem, e só neste arquivo.
sealed class Resultado<S, F> {
  const Resultado();
}

final class Sucesso<S, F> extends Resultado<S, F> {
  const Sucesso(this.valor);
  final S valor;
}

final class Falha<S, F> extends Resultado<S, F> {
  const Falha(this.erro);
  final F erro;
}

/// ---------------------------------------------------------------------------
/// Regra de negócio
/// ---------------------------------------------------------------------------

class BancoDeMinutos {
  BancoDeMinutos(this._saldoPorMateria);

  final Map<String, int> _saldoPorMateria;

  /// Versão que LANÇA. Use quando a falha for excepcional.
  int gastar(String materia, int minutos) {
    if (minutos <= 0) {
      // ArgumentError é um Error: quem chamou escreveu código errado.
      throw ArgumentError.value(minutos, 'minutos', 'Deve ser maior que zero');
    }

    final saldo = _saldoPorMateria[materia];
    if (saldo == null) {
      throw MateriaNaoEncontradaException(materia);
    }
    if (saldo < minutos) {
      throw SaldoInsuficienteException(saldoAtual: saldo, valorPedido: minutos);
    }

    final novoSaldo = saldo - minutos;
    _saldoPorMateria[materia] = novoSaldo;
    return novoSaldo;
  }

  /// Versão que DEVOLVE o erro como valor. Use quando a falha for rotina.
  Resultado<int, String> gastarComResultado(String materia, int minutos) {
    try {
      return Sucesso(gastar(materia, minutos));
    } on MateriaNaoEncontradaException catch (e) {
      return Falha('Matéria inválida: ${e.nome}');
    } on SaldoInsuficienteException catch (e) {
      return Falha('Faltam ${e.faltam} minutos em $materia');
    }
    // ArgumentError NÃO é capturado de propósito: é bug, tem que estourar.
  }
}

/// ---------------------------------------------------------------------------
/// Demonstrações
/// ---------------------------------------------------------------------------

void demonstrarTryCatch(BancoDeMinutos banco) {
  print('--- 1) try / on / catch / finally ---');
  try {
    final restante = banco.gastar('Dart', 30);
    print('Gastei 30 min de Dart. Restam $restante min.');

    banco.gastar('Flutter', 500); // vai falhar: saldo insuficiente
    print('Esta linha NUNCA roda.');
  } on SaldoInsuficienteException catch (e) {
    print('Tratado: $e');
  } on MateriaNaoEncontradaException catch (e) {
    print('Tratado: $e');
  } finally {
    print('finally: fecho o relatório do dia, dando certo ou não.');
  }
}

void demonstrarStackTrace(BancoDeMinutos banco) {
  print('\n--- 2) stack trace ---');
  try {
    banco.gastar('Kotlin', 10); // matéria inexistente
  } catch (e, s) {
    print('Erro: $e');
    // O stack trace pode ser longo; imprimimos só as 3 primeiras linhas.
    print('Início do stack trace:\n${s.toString().split('\n').take(3).join('\n')}');
  }
}

/// Registra o erro e devolve a bola para quem chamou, sem perder o rastro.
int gastarComLog(BancoDeMinutos banco, String materia, int minutos) {
  try {
    return banco.gastar(materia, minutos);
  } catch (e) {
    print('[log] falha ao gastar $minutos min em $materia -> $e');
    rethrow; // mantém a exceção e o stack trace originais
  }
}

void demonstrarRethrow(BancoDeMinutos banco) {
  print('\n--- 3) rethrow ---');
  try {
    gastarComLog(banco, 'Dart', 9999);
  } on SaldoInsuficienteException catch (e) {
    print('main tratou depois do rethrow: faltam ${e.faltam} min.');
  }
}

void demonstrarResultado(BancoDeMinutos banco) {
  print('\n--- 4) Result pattern ---');
  final pedidos = <(String, int)>[
    ('Dart', 20),
    ('Dart', 9999),
    ('Kotlin', 10),
  ];

  for (final (materia, minutos) in pedidos) {
    final resultado = banco.gastarComResultado(materia, minutos);
    // switch exaustivo: o compilador exige Sucesso E Falha.
    final mensagem = switch (resultado) {
      Sucesso(:final valor) => 'OK — restam $valor min em $materia',
      Falha(:final erro) => 'ERRO — $erro',
    };
    print(mensagem);
  }
}

void main() {
  final banco = BancoDeMinutos({'Dart': 120, 'Flutter': 60});

  demonstrarTryCatch(banco);
  demonstrarStackTrace(banco);
  demonstrarRethrow(banco);
  demonstrarResultado(banco);

  print('\n--- 5) Error NÃO se captura, se corrige ---');
  try {
    banco.gastar('Dart', -5); // ArgumentError
  } on ArgumentError catch (e) {
    print('Capturei só para demonstrar: $e');
    print('Em código real, a correção é NUNCA chamar com valor negativo.');
  }
}
```

Saída esperada (as linhas do stack trace variam de máquina para máquina):

```text
--- 1) try / on / catch / finally ---
Gastei 30 min de Dart. Restam 90 min.
Tratado: SaldoInsuficienteException: saldo de 60 min, pedido de 500 min (faltam 440 min)
finally: fecho o relatório do dia, dando certo ou não.

--- 2) stack trace ---
Erro: MateriaNaoEncontradaException: "Kotlin" não existe
Início do stack trace:
...

--- 3) rethrow ---
[log] falha ao gastar 9999 min em Dart -> SaldoInsuficienteException: saldo de 90 min, pedido de 9999 min (faltam 9909 min)
main tratou depois do rethrow: faltam 9909 min.

--- 4) Result pattern ---
OK — restam 70 min em Dart
ERRO — Faltam 9929 minutos em Dart
ERRO — Matéria inválida: Kotlin

--- 5) Error NÃO se captura, se corrige ---
Capturei só para demonstrar: Invalid argument (minutos): Deve ser maior que zero: -5
Em código real, a correção é NUNCA chamar com valor negativo.
```

> Nota sobre `print()`: em projetos Flutter o lint `avoid_print` o marca como problema e você usa
> `debugPrint()`. Em Dart puro de terminal (módulos 00 a 04) `print()` é a saída correta do
> programa — detalhes na [aula 7](07-analise-estatica-e-lints.md).

---

## 🔍 Explicando o código

**`class SaldoInsuficienteException implements Exception`**
`implements` aqui serve para **declarar intenção**: "isto é um erro esperado de negócio". Como
`Exception` não tem membros obrigatórios, você não precisa implementar nada — mas ganha a
possibilidade de escrever `on SaldoInsuficienteException catch (e)` e tratar **só** esse caso. Os
campos `saldoAtual` e `valorPedido` existem porque uma exceção boa carrega **dados**, não só texto:
com `e.faltam` a camada de cima monta a mensagem que quiser sem precisar fatiar string.

**`@override String toString()`**
É o que aparece quando a exceção não é tratada e quando você faz `print(e)`. Sem isso, o Dart
imprimiria algo como `Instance of 'SaldoInsuficienteException'`, que não ajuda ninguém.

**`throw ArgumentError.value(minutos, 'minutos', 'Deve ser maior que zero')`**
`ArgumentError.value` recebe o valor recebido, o nome do parâmetro e a explicação. É um `Error`,
não uma `Exception`: passar minutos negativos é bug de quem chamou, e o programa **deve** quebrar
alto e cedo para o bug ser corrigido.

**`final saldo = _saldoPorMateria[materia];`** seguido de **`if (saldo == null)`**
Ler um `Map` com chave inexistente devolve `null` (null safety do
[módulo 02](../02-dart-basico/05-null-safety.md)). Depois desse `if`, o Dart faz *promotion*
(*promoção de tipo*): `saldo` passa a ser tratado como `int` não nulo no resto do método.

**`catch (e, s)`**
O segundo parâmetro é o `StackTrace`. Ele responde "por onde o programa passou até aqui".
Imprimimos só as 3 primeiras linhas porque são elas que apontam o ponto da falha; o resto é o
caminho interno do Dart.

**`rethrow`**
Dentro de `gastarComLog`, o `catch` registra o log e devolve a exceção original para cima.
Note que `main` consegue capturar `SaldoInsuficienteException` **com o tipo certo** — prova de que
a exceção não foi trocada por outra coisa no caminho.

**`switch (resultado) { Sucesso(:final valor) => ..., Falha(:final erro) => ... }`**
Antes dele, `<(String, int)>[...]` e `for (final (materia, minutos) in pedidos)` são **records** e
**patterns** — aperitivo das aulas [4](04-records.md) e [5](05-patterns-e-switch.md).
Aqui o `switch` é usado como **expressão**: ele **devolve** um valor, guardado em `mensagem`.
`Sucesso(:final valor)` é um *object pattern* que, ao casar, já cria a variável `valor`.
Como `Resultado` é `sealed`, o compilador sabe que só há dois casos — se você apagar a linha de
`Falha`, o `dart analyze` acusa erro de exaustividade.

---

## ⚠️ Erros comuns

| # | Erro | Por que dói | Correção |
|---|---|---|---|
| 1 | `catch (e) { throw e; }` | Reinicia o stack trace; você perde a origem real do problema | Use `rethrow` |
| 2 | `try { ... } catch (e) {}` — catch vazio | O erro some silenciosamente e o bug aparece três telas depois | Trate, logue ou relance. Nunca engula |
| 3 | `throw 'algo deu errado'` | Não dá para filtrar com `on`, e o tipo é `String` | Lance uma classe que `implements Exception` |
| 4 | Capturar `Error` genérico para "deixar o app estável" | Esconde bug de programação; o app segue em estado inválido | Capture `Exception`; deixe `Error` estourar |
| 5 | `on Exception` antes de `on FormatException` | O primeiro `on` que casa vence; o específico nunca roda | Do mais específico para o mais genérico |
| 6 | Colocar `return` dentro de `finally` | Esse `return` **descarta** a exceção em andamento | `finally` só libera recursos |
| 7 | Exceção customizada só com `String mensagem` | Quem trata precisa fatiar texto para saber o que aconteceu | Carregue os dados (`saldoAtual`, `faltam`, ...) |
| 8 | Usar exceção para fluxo normal (ex.: "usuário não achou") | Fica lento e ilegível; erro esperado vira surpresa | Devolva `Resultado<S, F>` |

Sem tratamento nenhum, a saída é assim — e a linha `#0` é a mais importante: arquivo, **linha** e
**coluna** onde a exceção nasceu.

```text
Unhandled exception:
SaldoInsuficienteException: saldo de 60 min, pedido de 500 min (faltam 440 min)
#0      BancoDeMinutos.gastar (file:///.../bin/aula01_exceptions.dart:70:7)
```

---

## 🛠️ Exercício guiado

Vamos criar um conversor de nota que nunca quebra o programa.

**Passo 1.** Crie `bin/guiado01_notas.dart`.

**Passo 2.** Declare a exceção de domínio:

```dart
class NotaInvalidaException implements Exception {
  const NotaInvalidaException(this.entrada, this.motivo);
  final String entrada;
  final String motivo;

  @override
  String toString() => 'NotaInvalidaException: "$entrada" — $motivo';
}
```

**Passo 3.** Escreva a função que lança:

```dart
double lerNota(String entrada) {
  final valor = double.tryParse(entrada.replaceAll(',', '.'));
  if (valor == null) {
    throw NotaInvalidaException(entrada, 'não é um número');
  }
  if (valor < 0 || valor > 10) {
    throw NotaInvalidaException(entrada, 'fora do intervalo 0..10');
  }
  return valor;
}
```

`double.tryParse` devolve `null` em vez de lançar — por isso conseguimos criar uma mensagem
melhor que a `FormatException` padrão.

**Passo 4.** Escreva a versão com Result, reaproveitando o `Resultado<S, F>` da aula
(copie as três classes `sealed`/`final` para este arquivo):

```dart
Resultado<double, String> lerNotaSegura(String entrada) {
  try {
    return Sucesso(lerNota(entrada));
  } on NotaInvalidaException catch (e) {
    return Falha(e.motivo);
  }
}
```

**Passo 5.** No `main`, rode a lista `['8,5', '11', 'dez', '7']` pelas duas versões e imprima o
resultado de cada uma. Execute com `dart run bin/guiado01_notas.dart`.

**Resultado esperado:** a versão com `throw` interrompe no primeiro problema se você não usar
`try`; a versão com `Resultado` processa as quatro entradas e reporta cada uma. Escreva, em um
comentário no topo do arquivo, qual você usaria em um formulário de app e por quê.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md)

Nesta aula, foque nos exercícios de **Fixação** e **Correção de bugs** que citam exceções.

---

## 🏆 Desafio opcional

Implemente no `Resultado<S, F>` os utilitários `bool get deuCerto`, `S? get valorOuNulo`,
`Resultado<T, F> mapear<T>(T Function(S) f)` (transforma o sucesso e mantém a falha) e
`S ouEntao(S padrao)`. Implemente cada um com `switch` sobre `this`, mantendo o `switch` exaustivo.
Teste encadeando: leia uma nota, mapeie para conceito (`A`, `B`, `C`) e imprima com
`ouEntao('sem nota')`.

---

## 📌 Resumo

- `Exception` = problema **esperado** (trate). `Error` = **bug** (corrija o código).
- `throw` interrompe a função e sobe a pilha até alguém capturar.
- `on Tipo catch (e, s)` filtra por tipo e dá o **stack trace**; ordene do específico ao genérico.
- `finally` sempre roda — use para liberar recursos, nunca para `return`.
- `rethrow` preserva exceção **e** stack trace; `throw e` não.
- Exceção customizada boa carrega **dados** e tem `toString()` útil.
- Erro esperado e frequente vira **valor**: `Resultado<S, F>` com `sealed class` + `switch`
  exaustivo, checado pelo compilador.

---

## ☑️ Checklist de domínio

- [ ] Digo, sem consultar, três exemplos de `Exception` e três de `Error`.
- [ ] Escrevo um `try` com dois `on` na ordem correta e um `finally`.
- [ ] Explico por que `rethrow` é melhor que `throw e`.
- [ ] Crio uma exceção customizada com campos e `toString()`.
- [ ] Leio um stack trace e aponto o arquivo e a linha da origem.
- [ ] Justifico, para um caso dado, se lanço exceção ou devolvo `Resultado`.
- [ ] Consumo um `Resultado<S, F>` com `switch` exaustivo.
- [ ] Rodei `bin/aula01_exceptions.dart` e entendi cada bloco da saída.

---

## 📚 Referências oficiais

- [Error handling — dart.dev](https://dart.dev/language/error-handling)
- [Exception class — api.dart.dev](https://api.dart.dev/stable/dart-core/Exception-class.html)
- [Error class — api.dart.dev](https://api.dart.dev/stable/dart-core/Error-class.html)
- [StackTrace class — api.dart.dev](https://api.dart.dev/stable/dart-core/StackTrace-class.html)
- [Effective Dart: Usage — Error handling](https://dart.dev/effective-dart/usage)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — Futures e async/await](02-futures-e-async-await.md) |
