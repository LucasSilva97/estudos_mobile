# Aula 6 — Controle de fluxo

> **Módulo:** 02 - Dart Básico · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Escrever `if`, `else if` e `else` seguindo as convenções do Dart.
- Usar o `switch` **statement** do Dart 3, sem `break` obrigatório e com padrões lógicos (`||`).
- Usar o `switch` **expression**, que devolve um valor, com padrões relacionais (`< 25`) e guardas (`when`).
- Escolher entre laço com índice, `for-in` e `.indexed`.
- Usar `while`, `do-while`, `break`, `continue` e *labels* quando há laços aninhados.
- Aplicar `assert` para checar suposições durante o desenvolvimento.

## ✅ Pré-requisitos

- [Aula 4](04-tipos-strings-conversoes.md) e [Aula 5](05-null-safety.md).
- Condições e repetições no conceito — [Módulo 01, Aula 7](../01-logica-e-fundamentos/07-condicoes.md)
  e [Aula 8](../01-logica-e-fundamentos/08-repeticoes.md).

## 📖 Conceito

**Controle de fluxo** é o conjunto de estruturas que decidem **qual** código executa e **quantas
vezes**. Sem elas, um programa é apenas uma lista de instruções de cima para baixo.

### `if` / `else if` / `else`

```dart
if (minutos >= 90) {
  print('Sessão longa');
} else if (minutos >= 25) {
  print('Sessão normal');
} else {
  print('Sessão curta');
}
```

Três detalhes específicos do Dart:

1. A condição **precisa ser `bool`**. `if (1)` e `if ('texto')` não compilam, ao contrário de C
   ou JavaScript.
2. As chaves são obrigatórias pelo guia de estilo, salvo um `if` sem `else` que cabe em uma linha.
3. Só o **primeiro** ramo verdadeiro executa; os demais são ignorados. Por isso a ordem importa:
   se `>= 25` viesse antes de `>= 90`, a segunda condição nunca seria alcançada.

Os operadores lógicos:

| Operador | Nome | Curto-circuito |
|---|---|---|
| `&&` | e | se o lado esquerdo for `false`, o direito nem é avaliado |
| `\|\|` | ou | se o lado esquerdo for `true`, o direito nem é avaliado |
| `!` | não | inverte o `bool` |

> **Curto-circuito** — a avaliação para assim que o resultado já está decidido. É o que torna
> seguro escrever `if (valor != null && valor > 0)`: se `valor` for nulo, a comparação nem roda.

### O `switch` **statement** do Dart 3

```dart
switch (dia) {
  case 'sab' || 'dom':
    print('Fim de semana');
  case 'seg':
    print('Começo da semana');
  default:
    print('Dia útil');
}
```

Mudanças importantes em relação ao que você talvez conheça de Java ou C:

- **`break` não é mais obrigatório** ao fim de um `case` não vazio. Terminado o corpo, o Dart
  salta para o fim do `switch`. Você ainda pode escrever `break` (e vai ver muito código antigo
  com ele), mas ele é redundante.
- Um `case` **vazio** continua "caindo" para o próximo (*fall-through*) — é assim que se agrupa
  vários valores na forma antiga.
- `case 'sab' || 'dom':` é um **padrão lógico "ou"**, a forma moderna de agrupar.
- `default:` cobre o que sobrou. Sinônimo moderno: `case _:`.

### O `switch` **expression** — a novidade que muda tudo

Um `switch` *statement* **faz** coisas. Um `switch` *expression* **devolve um valor**:

```dart
final String nivel = switch (minutos) {
  < 0 => 'inválida',
  0 => 'sem estudo',
  < 25 => 'muito curta',
  < 90 => 'média',
  _ => 'longa',
};
```

Diferenças de sintaxe que você precisa memorizar:

| | `switch` statement | `switch` expression |
|---|---|---|
| Palavra `case` | obrigatória | **não se escreve** |
| Separador | `:` (dois-pontos) | `=>` (seta) |
| Fim de cada ramo | nada (ou `break`) | `,` (vírgula) |
| Caso restante | `default:` | `_ =>` |
| Fim da estrutura | `}` | `};` (com ponto e vírgula) |
| Devolve valor? | não | **sim** |

`< 25` é um **padrão relacional**: "qualquer valor menor que 25". Os operadores aceitos são
`<`, `<=`, `>`, `>=`, `==` e `!=`.

E você pode acrescentar uma **guarda** com `when`:

```dart
final String conselho = switch (minutos) {
  final int v when v >= 90 => 'faça uma pausa',
  0 => 'registre uma sessão',
  _ => 'siga assim',
};
```

`final int v` captura o valor em uma variável, e `when` é a condição extra. O ramo só é
escolhido se o padrão casar **e** a guarda for verdadeira.

### Exaustividade

Um `switch` expression precisa cobrir **todos** os casos possíveis. Se não cobrir, o compilador
recusa:

```text
Error: The type 'int' is not exhaustively matched by the switch cases since it doesn't match '_'.
```

Para `int` e `String` você sempre vai precisar do `_`. Para tipos com conjunto fechado de valores
(`enum` e `sealed class`), o compilador **sabe** quais são os casos e cobra cada um — e isso vira
uma rede de proteção poderosa. Assunto de
[04 — Sealed classes](../04-dart-avancado/06-sealed-classes.md) e
[04 — Patterns e switch](../04-dart-avancado/05-patterns-e-switch.md).

### Laços

```dart
// 1. Clássico, com índice: use quando você precisa do número da posição.
for (int i = 0; i < sessoes.length; i++) {
  print('Sessão ${i + 1}: ${sessoes[i]}');
}

// 2. for-in: use quando só interessa o valor. É o mais legível.
for (final int minutos in sessoes) {
  print(minutos);
}

// 3. .indexed (Dart 3): índice E valor, sem aritmética manual.
for (final (indice, minutos) in sessoes.indexed) {
  print('[$indice] $minutos');
}

// 4. while: repete enquanto a condição for verdadeira (pode não executar nenhuma vez).
while (restante >= 25) {
  restante -= 25;
}

// 5. do-while: executa pelo menos UMA vez, e só então testa.
do {
  tentativas++;
} while (tentativas < 3);
```

`sessoes.indexed` devolve uma sequência de **records** — pares `(índice, valor)`. Records são o
tema de [04 — Records](../04-dart-avancado/04-records.md); aqui basta saber que
`final (a, b)` separa o par em duas variáveis.

### `break`, `continue` e labels

- `break` — sai do laço imediatamente.
- `continue` — pula para a próxima repetição.
- **Label** — um nome antes do laço, que permite `break` ou `continue` mirando um laço **externo**:

```dart
busca:
for (final semana in semanas) {
  for (final dia in semana) {
    if (dia == 0) continue busca;   // vai para a próxima SEMANA
    if (dia >= 90) break busca;     // sai dos DOIS laços
  }
}
```

Sem label, `break` sairia só do laço interno. Use labels com parcimônia: mais de dois níveis
aninhados costuma indicar que aquele trecho deveria virar uma função.

### `assert`

```dart
assert(minutos > 0, 'Minutos deve ser maior que zero, recebi $minutos');
```

`assert` verifica uma suposição **durante o desenvolvimento**. Se a condição for falsa, lança
`AssertionError` com a mensagem. Em compilação de produção (`dart compile exe`,
`flutter build apk --release`) os `assert` são **removidos do binário** — custo zero.

No terminal, os `assert` só rodam se você pedir:

```powershell
dart run --enable-asserts bin/fluxo.dart
```

No Flutter, eles ficam **ligados automaticamente em modo debug** e desligados em release. É por
isso que o próprio framework Flutter usa `assert` largamente para avisar você de uso errado.

`assert` não substitui validação: dado que vem do usuário se valida com `if`, porque a validação
precisa existir também em produção.

## 💡 Analogia

Controle de fluxo é o **painel de uma esteira de triagem**.

- `if/else` é o desvio simples: caixa grande vai para a esquerda, pequena para a direita.
- `switch` *statement* é a **mesa giratória**: a caixa cai em uma de várias calhas, conforme o
  código impresso nela. Depois de cair, o trabalho daquela calha acontece e a peça segue.
- `switch` *expression* é a mesma mesa, mas em vez de "fazer algo", ela **carimba um rótulo** na
  caixa e devolve a caixa rotulada.
- `for` é a linha que processa a esteira inteira; `while` é a bomba que só para quando o tanque
  esvazia; `do-while` é a bomba que dá pelo menos uma girada antes de checar o tanque.
- `assert` é o **sensor de conferência de linha**: instalado durante a montagem da fábrica, ele
  apita se algo impossível passar. Quando a fábrica entra em produção comercial, o sensor de
  conferência é retirado — porque o processo já foi validado.

## 🧪 Exemplo mínimo

```dart
void main() {
  const int minutos = 75;

  // switch expression: devolve um valor
  final String nivel = switch (minutos) {
    0 => 'sem estudo',
    < 25 => 'muito curta',
    < 90 => 'média',
    _ => 'longa',
  };

  print('$minutos min -> $nivel');

  // for-in simples
  for (final int m in <int>[20, 60, 120]) {
    print('$m -> ${m >= 90 ? 'longa' : 'ok'}');
  }
}
```

```text
75 min -> média
20 -> ok
60 -> ok
120 -> longa
```

## 📱 Aplicando no Flutter

O `switch` expression é a ferramenta que você vai usar para **transformar estado em tela**.

No módulo 06 você aprende que uma tela tem quatro estados possíveis: carregando, erro, vazia e
com dados. A maneira idiomática de escolher o widget certo é exatamente um `switch` expression:

```dart
// prévia do módulo 06 — o widget escolhido vira o conteúdo da tela
final Widget conteudo = switch (estado) {
  Carregando() => const CircularProgressIndicator(),
  ComErro(:final mensagem) => Text('Erro: $mensagem'),
  ComDados(:final lista) when lista.isEmpty => const Text('Nada por aqui'),
  ComDados(:final lista) => ListaDeMaterias(lista),
};
```

Você não precisa entender cada linha agora. Repare só em duas coisas: é o **mesmo** `switch`
expression desta aula, e não há `default` — porque o tipo é uma `sealed class` e o compilador
garante que nenhum estado ficou de fora. É o Dart impedindo que você esqueça de tratar "erro".

Outras aparições:

| Estrutura | Onde reaparece |
|---|---|
| `if` dentro da montagem da tela | [06 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) |
| `switch` expression | [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) |
| `for` para gerar widgets | [06 — Listas e rolagem](../06-widgets-e-layouts/09-listas-e-rolagem.md) |
| `assert` | usado pelo próprio Flutter para avisar erro de uso em modo debug |

## 💻 Código completo

> **Arquivo:** `dart_basico/bin/fluxo.dart`
> **Como executar:** `dart run --enable-asserts bin/fluxo.dart`

```dart
// bin/fluxo.dart
// Demonstra: if/else, switch statement, switch expression,
// laços, break/continue com labels e assert.

/// Classifica a duração de uma sessão usando padrões relacionais.
String classificar(int minutos) => switch (minutos) {
      < 0 => 'inválida',
      0 => 'sem estudo',
      < 25 => 'muito curta',
      < 50 => 'curta',
      < 90 => 'média',
      _ => 'longa',
    };

/// Devolve a orientação do dia usando um switch statement.
String mensagemDoDia(String dia) {
  switch (dia) {
    case 'sab' || 'dom':
      return 'Fim de semana: revisão leve.';
    case 'seg':
      return 'Começo de semana: conteúdo novo.';
    case 'sex':
      return 'Sexta: feche o ciclo com exercícios.';
    default:
      return 'Dia útil: siga o plano.';
  }
}

/// Registra uma sessão. Usa assert para checar suposições do desenvolvimento.
void registrarSessao(String materia, int minutos) {
  assert(materia.isNotEmpty, 'A matéria não pode ser vazia');
  assert(minutos > 0, 'Minutos deve ser maior que zero, recebi $minutos');
  print('Registrado: $materia por $minutos min');
}

void main() {
  const List<int> sessoes = <int>[45, 0, 120, -10, 30, 75];
  const List<String> dias = <String>['seg', 'ter', 'sex', 'sab', 'dom'];
  const int meta = 300;

  print('=== 1. if / else if / else ===');
  int total = 0;
  for (final int m in sessoes) {
    if (m > 0) total += m;
  }
  if (total >= meta) {
    print('Total $total min: meta de $meta atingida.');
  } else if (total >= meta * 0.7) {
    print('Total $total min: perto da meta de $meta.');
  } else {
    print('Total $total min: ainda longe da meta de $meta.');
  }

  print('');
  print('=== 2. switch statement ===');
  for (final String dia in dias) {
    print('${dia.padRight(4)}-> ${mensagemDoDia(dia)}');
  }

  print('');
  print('=== 3. switch expression com padrões relacionais ===');
  for (final int m in sessoes) {
    print('${m.toString().padLeft(4)} min -> ${classificar(m)}');
  }

  print('');
  print('=== 4. switch expression com guarda (when) ===');
  for (final int m in sessoes) {
    final String conselho = switch (m) {
      final int v when v < 0 => 'corrija o registro',
      0 => 'registre ao menos uma sessão',
      final int v when v >= 90 => 'faça uma pausa de 10 min',
      _ => 'siga assim',
    };
    print('${m.toString().padLeft(4)} min -> $conselho');
  }

  print('');
  print('=== 5. for clássico com índice ===');
  for (int i = 0; i < sessoes.length; i++) {
    print('Sessão ${i + 1} de ${sessoes.length}: ${sessoes[i]} min');
  }

  print('');
  print('=== 6. for-in com continue ===');
  int validas = 0;
  for (final int m in sessoes) {
    if (m <= 0) continue;
    validas++;
  }
  print('Sessões válidas: $validas de ${sessoes.length}');

  print('');
  print('=== 7. indexed: índice e valor juntos ===');
  for (final (indice, minutos) in sessoes.indexed) {
    print('[$indice] $minutos min (${classificar(minutos)})');
  }

  print('');
  print('=== 8. while e do-while ===');
  int restante = 300;
  int blocos = 0;
  while (restante >= 25) {
    restante -= 25;
    blocos++;
  }
  print('300 min cabem em $blocos blocos de 25 min, sobrando $restante min');

  int tentativa = 0;
  do {
    tentativa++;
  } while (tentativa < 3);
  print('do-while executou $tentativa vezes');

  print('');
  print('=== 9. break, continue e labels ===');
  const List<List<int>> semanas = <List<int>>[
    <int>[30, 45, 60],
    <int>[0, 20, 40],
    <int>[15, 120, 35],
  ];
  busca:
  for (final (semana, minutosDaSemana) in semanas.indexed) {
    for (final (dia, minutos) in minutosDaSemana.indexed) {
      if (minutos == 0) {
        print('Semana ${semana + 1}, dia ${dia + 1}: sem estudo, pulando a semana');
        continue busca;
      }
      if (minutos >= 90) {
        print('Semana ${semana + 1}, dia ${dia + 1}: $minutos min, maratona encontrada');
        break busca;
      }
    }
  }

  print('');
  print('=== 10. assert ===');
  try {
    registrarSessao('Dart', 45);
    registrarSessao('Flutter', -5);
  } on AssertionError catch (erro) {
    print('AssertionError capturado: ${erro.message}');
  }
}
```

Saída esperada com `dart run --enable-asserts bin/fluxo.dart`:

```text
=== 1. if / else if / else ===
Total 270 min: perto da meta de 300.

=== 2. switch statement ===
seg -> Começo de semana: conteúdo novo.
ter -> Dia útil: siga o plano.
sex -> Sexta: feche o ciclo com exercícios.
sab -> Fim de semana: revisão leve.
dom -> Fim de semana: revisão leve.

=== 3. switch expression com padrões relacionais ===
  45 min -> curta
   0 min -> sem estudo
 120 min -> longa
 -10 min -> inválida
  30 min -> curta
  75 min -> média

=== 4. switch expression com guarda (when) ===
  45 min -> siga assim
   0 min -> registre ao menos uma sessão
 120 min -> faça uma pausa de 10 min
 -10 min -> corrija o registro
  30 min -> siga assim
  75 min -> siga assim

=== 5. for clássico com índice ===
Sessão 1 de 6: 45 min
Sessão 2 de 6: 0 min
Sessão 3 de 6: 120 min
Sessão 4 de 6: -10 min
Sessão 5 de 6: 30 min
Sessão 6 de 6: 75 min

=== 6. for-in com continue ===
Sessões válidas: 4 de 6

=== 7. indexed: índice e valor juntos ===
[0] 45 min (curta)
[1] 0 min (sem estudo)
[2] 120 min (longa)
[3] -10 min (inválida)
[4] 30 min (curta)
[5] 75 min (média)

=== 8. while e do-while ===
300 min cabem em 12 blocos de 25 min, sobrando 0 min
do-while executou 3 vezes

=== 9. break, continue e labels ===
Semana 2, dia 1: sem estudo, pulando a semana
Semana 3, dia 2: 120 min, maratona encontrada

=== 10. assert ===
Registrado: Dart por 45 min
AssertionError capturado: Minutos deve ser maior que zero, recebi -5
```

> Se você rodar **sem** `--enable-asserts`, a seção 10 muda: os dois registros passam e você vê
> `Registrado: Flutter por -5 min`. Rode das duas formas para sentir a diferença.

## 🔍 Explicando o código

**`String classificar(int minutos) => switch (minutos) { ... };`**
Função de uma expressão só (*arrow function*, tema da [Aula 7](07-funcoes-em-dart.md)) devolvendo
um `switch` expression. Repare: sem `case`, com `=>` e com vírgula ao fim de cada ramo, e `};`
fechando.

**A ordem dos ramos em `classificar`**
Os padrões são testados **de cima para baixo**, e o primeiro que casar vence. Por isso `< 25`
precisa vir antes de `< 50`, que precisa vir antes de `< 90`. Se você inverter, tudo abaixo de 90
vira "média".

**`case 'sab' || 'dom':`**
Padrão lógico "ou". Equivale à forma antiga com dois `case` vazios em sequência, mas é mais
direto. Note que aqui os `case` terminam com `return`, então nem a questão do `break` se coloca.

**`final int v when v < 0 => ...`**
`final int v` é um **padrão de variável**: casa com qualquer `int` e guarda o valor em `v`.
`when v < 0` é a guarda. Sem a guarda, esse ramo casaria com tudo e os seguintes ficariam
inacessíveis.

**`total >= meta * 0.7`**
`300 * 0.7` é `210.0`, um `double`. Comparar `int` com `double` é permitido porque ambos são
`num`. `270 >= 210.0` é verdadeiro, daí a mensagem "perto da meta".

**`if (m > 0) total += m;`**
`if` de uma linha, sem `else`: a única forma sem chaves aceita pelo guia de estilo.

**`for (final (indice, minutos) in sessoes.indexed)`**
`sessoes.indexed` produz pares. O padrão `final (indice, minutos)` **desmonta** cada par em duas
variáveis. Compare com a seção 5, onde foi preciso escrever `i + 1` e `sessoes[i]` na mão.

**`busca:` antes do `for`**
O rótulo nomeia o laço externo. `continue busca` abandona a semana atual e vai para a próxima;
`break busca` sai dos dois laços de uma vez. Sem o rótulo, `continue` só pularia para o próximo
**dia**, e a semana 2 continuaria sendo processada.

**`assert(minutos > 0, 'Minutos deve ser maior que zero, recebi $minutos');`**
O segundo argumento é a mensagem. Sem ela, você veria só `Failed assertion`, sem saber o valor
recebido — sempre escreva a mensagem, e sempre inclua o valor.

**`on AssertionError catch (erro)`**
Capturado aqui apenas para a demonstração não derrubar o programa. Em código real, um `assert`
que falha significa **bug seu**: conserte a causa, não capture o erro.

## ⚠️ Erros comuns

**1. Misturar as sintaxes dos dois `switch`**

```dart
final nivel = switch (m) {
  case < 25: 'curta';    // ERRO: isto é statement dentro de expression
};
```

```text
Error: Expected an identifier, but got 'case'.
```

Em `switch` expression não existe `case`, usa-se `=>` e vírgula.

**2. Esquecer o `_` e quebrar a exaustividade**

```text
Error: The type 'int' is not exhaustively matched by the switch cases since it doesn't match '_'.
```

**3. Ordem errada de padrões relacionais**
`< 90` antes de `< 25` faz o ramo de 25 nunca ser alcançado. Vá do mais específico ao mais geral.

**4. Condição que não é `bool`**

```text
Error: A value of type 'int' can't be assigned to a variable of type 'bool'.
```

Dart exige `if (minutos > 0)`, nunca `if (minutos)`.

**5. Modificar a lista enquanto percorre com `for-in`**

```text
Unhandled exception:
ConcurrentModificationError: Concurrent modification during iteration: Instance(length:3) of '_GrowableList'.
```

Percorra uma cópia (`for (final x in lista.toList())`) ou monte uma lista nova.

**6. Laço infinito no `while`**

```dart
while (restante >= 25) {
  blocos++;      // esqueceu de diminuir restante
}
```

O programa trava. Interrompa com `Ctrl+C` no terminal. Todo `while` precisa de uma linha que
**aproxime** a condição do fim.

**7. `break` sem label achando que sai de tudo**
Ele sai apenas do laço mais interno. Use label quando precisar sair de todos.

**8. Confiar em `assert` para validar dado do usuário**
Em release, o `assert` some. A validação da entrada precisa ser `if` de verdade, como na
[Aula 10](10-entrada-e-saida.md).

## 🛠️ Exercício guiado

**Passo 1.** Crie `bin/fluxo.dart` e digite o código completo.

**Passo 2.** Rode das duas maneiras e compare a seção 10:

```powershell
dart run bin/fluxo.dart
dart run --enable-asserts bin/fluxo.dart
```

**Passo 3 — quebre a ordem dos padrões.** Em `classificar`, mova a linha `< 90 => 'média',` para
logo depois de `0 => 'sem estudo',`. Rode. Agora `45` e `30` viram `média`. Entenda por quê e
desfaça.

**Passo 4 — remova o `_`.** Apague a linha `_ => 'longa',` de `classificar` e rode:

```text
Error: The type 'int' is not exhaustively matched by the switch cases since it doesn't match '_'.
```

Recoloque.

**Passo 5 — converta `mensagemDoDia` em `switch` expression.** Reescreva:

```dart
String mensagemDoDia(String dia) => switch (dia) {
      'sab' || 'dom' => 'Fim de semana: revisão leve.',
      'seg' => 'Começo de semana: conteúdo novo.',
      'sex' => 'Sexta: feche o ciclo com exercícios.',
      _ => 'Dia útil: siga o plano.',
    };
```

Rode e confirme que a saída da seção 2 é idêntica.

**Passo 6 — remova o label.** Na seção 9, troque `continue busca;` por `continue;` e
`break busca;` por `break;`. Rode e observe que a semana 2 continua sendo percorrida e o
programa não para na maratona. Desfaça.

**Passo 7 — provoque o laço infinito (com cuidado).** Comente a linha `restante -= 25;` e rode.
Quando o terminal travar, aperte `Ctrl+C`. Descomente.

**Passo 8.** Rode `dart format .` e `dart analyze`.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md)

Faça os de **Leitura de código** desta seção: eles pedem que você preveja a saída antes de rodar.

## 🏆 Desafio opcional

Escreva `bin/plano_semana.dart` que receba pela linha de comando sete números (os minutos
estudados de segunda a domingo) e imprima:

1. Uma linha por dia no formato `Seg | 45 min | curta`, usando um `switch` expression para o
   rótulo e um `switch` expression para o nome abreviado do dia a partir do índice (0 a 6).
2. O total e a média da semana, com uma casa decimal.
3. Uma avaliação final com `switch` expression sobre o total:
   `< 120` → `precisa acelerar`; `< 300` → `bom ritmo`; `< 600` → `ótimo`; senão → `cuidado com o excesso`.
4. O **primeiro** dia com 0 minutos, usando um laço com `break` — e a mensagem
   `Nenhum dia vazio` se não houver.
5. Um `assert` garantindo que exatamente sete argumentos foram passados, com mensagem clara.

Valide com:

```powershell
dart run --enable-asserts bin/plano_semana.dart 45 0 90 120 30 60 25
```

Use `int.tryParse` com `??` para tratar argumento inválido como 0.

## 📌 Resumo

- A condição de `if` precisa ser `bool`; `&&` e `||` avaliam em curto-circuito.
- No `switch` statement do Dart 3, `break` não é mais obrigatório; `case a || b:` agrupa valores.
- O `switch` expression **devolve valor**: sem `case`, com `=>`, vírgula entre ramos e `};` no fim.
- Padrões relacionais (`< 25`) e guardas (`when`) tornam o `switch` expression muito expressivo.
- `switch` expression precisa ser exaustivo; para `int` e `String` isso significa terminar com `_`.
- Use `for` com índice quando precisar da posição, `for-in` quando só interessa o valor, e
  `.indexed` quando precisar dos dois.
- `while` pode não executar nunca; `do-while` executa pelo menos uma vez.
- Labels permitem `break`/`continue` mirando laços externos.
- `assert` checa suposições em desenvolvimento (`dart run --enable-asserts`) e some em release —
  nunca use para validar entrada de usuário.

## ☑️ Checklist de domínio

- [ ] Escrevo um `switch` expression correto sem consultar a sintaxe.
- [ ] Sei dizer a diferença entre `case < 25:` e `< 25 =>`.
- [ ] Já vi o erro de exaustividade no meu terminal.
- [ ] Sei por que a ordem dos padrões relacionais importa.
- [ ] Uso `.indexed` em vez de `for (int i = 0; ...)` quando faz sentido.
- [ ] Sei usar `continue` e `break` com label em laços aninhados.
- [ ] Rodei o programa com e sem `--enable-asserts` e entendi a diferença.
- [ ] Sei por que `assert` não substitui validação de entrada.

## 📚 Referências oficiais

- [Dart — Branches (`if`, `switch`)](https://dart.dev/language/branches)
- [Dart — Loops](https://dart.dev/language/loops)
- [Dart — Patterns](https://dart.dev/language/patterns)
- [Dart — Pattern types](https://dart.dev/language/pattern-types)
- [Dart — Error handling (`assert`)](https://dart.dev/language/error-handling)
- [Dart — The `dart run` command](https://dart.dev/tools/dart-run)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Null safety](05-null-safety.md) | [README](README.md) | [Funções em Dart](07-funcoes-em-dart.md) |
