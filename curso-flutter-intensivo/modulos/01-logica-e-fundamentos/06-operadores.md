# Aula 6 — Operadores

> **Módulo:** 01 - Lógica e Fundamentos · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Usar os operadores **aritméticos**, inclusive `~/` (divisão inteira) e `%` (resto).
- Comparar valores com os **relacionais** e combinar condições com os **lógicos** `&&`, `||` e `!`,
  entendendo o *curto-circuito*.
- Escrever **atribuição composta** (`+=`, `-=`, `*=`, `~/=`, `%=`).
- Aplicar a **precedência** de operadores e saber quando usar parênteses.
- Tratar ausência de valor com os operadores de nulo `??`, `??=` e `?.`.
- Usar **incremento** e **decremento** (`++`, `--`) e distinguir a forma prefixa da sufixa.

## ✅ Pré-requisitos

- [Aula 4 — Variáveis e constantes](04-variaveis-e-constantes.md): atribuição.
- [Aula 5 — Tipos de dados](05-tipos-de-dados.md): `int`, `double`, `bool`, `int?`, `tryParse`.
- Projeto `C:\src\pratica_dart` funcionando.

---

## 📖 Conceito

**Operador** é um símbolo que executa uma operação sobre um ou mais valores, chamados
**operandos**: em `690 + 60`, o `+` é o operador e `690` e `60` são os operandos. Toda combinação
de operadores e operandos que produz um valor é uma **expressão** — `690 + 60` é uma expressão cujo
valor é `750`.

### 1. Operadores aritméticos

| Operador | Nome | Exemplo | Resultado |
|---|---|---|---|
| `+` | soma | `690 + 60` | `750` |
| `-` | subtração | `690 - 750` | `-60` |
| `*` | multiplicação | `690 * 2` | `1380` |
| `/` | divisão | `690 / 60` | `11.5` (**sempre `double`**) |
| `~/` | divisão inteira | `690 ~/ 60` | `11` |
| `%` | resto (módulo) | `690 % 60` | `30` |
| `-` (unário) | negação | `-690` | `-690` |

**`~/` (divisão inteira)** descarta a parte decimal do quociente e devolve `int`. É o operador que
responde "quantas vezes inteiras cabe?". `690 ~/ 60` = 11 horas completas.

**`%` (resto)** devolve o que sobra da divisão. `690 % 60` = 30 minutos que não fecharam uma hora.
Os dois juntos resolvem o problema clássico de formatar tempo:

```dart
final int horas = 690 ~/ 60;    // 11
final int minutos = 690 % 60;   // 30
print('$horas h e $minutos min');  // 11 h e 30 min
```

O `%` também é a forma padrão de testar paridade: `n % 2 == 0` significa "n é par".

> ℹ️ Em Dart, quando o divisor é positivo, `%` devolve sempre um resultado **não negativo**:
> `-7 % 3` é `2`. Isso é diferente de linguagens como C e Java, onde o resultado seria `-1`. Para
> obter o resto "com sinal do dividendo", existe `remainder()`.

Cuidado com a divisão por zero: `7 / 0` devolve `Infinity` e `0 / 0` devolve `NaN` (*Not a
Number*), porque IEEE 754 define esses valores; já `7 ~/ 0` e `7 % 0` com inteiros **lançam erro em
execução**, porque não existe inteiro infinito.

### 2. Operadores relacionais (comparação)

Todos devolvem `bool`.

| Operador | Significado | Exemplo com `690` e `750` | Resultado |
|---|---|---|---|
| `>` | maior que | `690 > 750` | `false` |
| `<` | menor que | `690 < 750` | `true` |
| `>=` | maior ou igual | `690 >= 750` | `false` |
| `<=` | menor ou igual | `690 <= 750` | `true` |
| `==` | igual a | `690 == 750` | `false` |
| `!=` | diferente de | `690 != 750` | `true` |

> ⚠️ **`=` não é `==`.** Um sinal **atribui**; dois sinais **comparam**. Em Dart, escrever
> `if (x = 5)` não compila (porque `x = 5` produz um `int`, não um `bool`), o que evita um bug
> clássico de C e Java.

Para números e `String`, `==` compara **valor** (`'Dart' == 'Dart'` é `true`); para objetos que
você cria, o padrão é comparar **identidade** — veja
[`03-dart-intermediario/01-classes-e-objetos.md`](../03-dart-intermediario/01-classes-e-objetos.md).

### 3. Operadores lógicos

Operam sobre `bool` e devolvem `bool`.

| Operador | Nome | Devolve `true` quando |
|---|---|---|
| `&&` | E (conjunção) | **ambos** os lados são `true` |
| `\|\|` | OU (disjunção) | **pelo menos um** lado é `true` |
| `!` | NÃO (negação) | inverte o valor |

Tabela-verdade completa:

| `a` | `b` | `a && b` | `a \|\| b` | `!a` |
|---|---|---|---|---|
| `true` | `true` | `true` | `true` | `false` |
| `true` | `false` | `false` | `true` | `false` |
| `false` | `true` | `false` | `true` | `true` |
| `false` | `false` | `false` | `false` | `true` |

**Curto-circuito**: o Dart avalia o mínimo necessário.

- Em `a && b`, se `a` for `false`, `b` **nem é avaliado** — o resultado já é `false`.
- Em `a || b`, se `a` for `true`, `b` **nem é avaliado**.

Isso não é detalhe: é a técnica que protege o código. Em `if (temItens && primeiroItemEhValido)`,
quando não há itens o segundo lado nunca executa — e o erro de índice nunca acontece.

### 4. Atribuição composta

Escrevem em forma curta o padrão "leia, opere, guarde de volta":

| Forma curta | Equivalente |
|---|---|
| `total += 45;` | `total = total + 45;` |
| `total -= 15;` | `total = total - 15;` |
| `total *= 2;` | `total = total * 2;` |
| `total /= 2;` | `total = total / 2;` (exige `double`) |
| `total ~/= 3;` | `total = total ~/ 3;` |
| `total %= 7;` | `total = total % 7;` |

Repare que `total /= 2` só funciona se `total` for `double`, porque `/` devolve `double`.

### 5. Incremento e decremento

```dart
contador++;   // soma 1
contador--;   // subtrai 1
```

A diferença aparece quando você **usa o valor da expressão**: na forma **sufixa** (`contador++`) a
expressão vale o valor **antes** de somar; na **prefixa** (`++contador`), o valor **depois**.

```dart
int c = 0;
print(c++);   // imprime 0 — e c passa a valer 1
print(c);     // imprime 1
print(++c);   // imprime 2 — c já valia 1, virou 2 antes de imprimir
```

> ✅ **Recomendação do curso:** quando você só quer somar 1 e não usa o valor da expressão, use
> `contador++` em linha própria — é o que aparece em qualquer laço `for`. Misturar incremento com
> leitura na mesma linha deixa o código difícil de revisar.

### 6. Operadores de nulo

São a resposta do Dart ao `null` que você conheceu com `tryParse` na [Aula 5](05-tipos-de-dados.md).

**`??` — valor padrão ("se for nulo, use este")**: com `final int? lido = int.tryParse('abc');`
(que é `null`), a expressão `lido ?? 0` vale `0`.

**`??=` — atribua só se estiver nulo**

```dart
int? cache;
cache ??= 120;   // cache era null -> vira 120
cache ??= 999;   // cache já tem valor -> nada acontece
```

**`?.` — acesso seguro ("se for nulo, pare e devolva nulo")**

```dart
String? nome;          // ainda sem valor
print(nome?.length);   // null, e NÃO quebra o programa
```

Sem o `?.`, o Dart nem deixaria você escrever `nome.length` em uma variável anulável — é o *null
safety* impedindo o erro antes de ele existir. E os três combinam bem:

```dart
final int tamanho = nome?.length ?? 0;   // 0 quando nome é null
```

### 7. Precedência

**Precedência** é a ordem em que os operadores são avaliados na mesma expressão, da mais alta para
a mais baixa:

| Nível | Operadores |
|---|---|
| 1 | `()` — parênteses · `++` `--` sufixos · `?.` |
| 2 | `!` · `-` unário · `++` `--` prefixos |
| 3 | `*` `/` `~/` `%` |
| 4 | `+` `-` |
| 5 | `<` `>` `<=` `>=` `is` |
| 6 | `==` `!=` |
| 7 | `&&` · depois `\|\|` · depois `??` |
| 8 | `=` `+=` `-=` `??=` |

Na prática: `2 + 3 * 4` é `14` (o `*` vem antes), `(2 + 3) * 4` é `20`, e
`690 >= 600 && 690 <= 750` é `true` porque as comparações acontecem antes do `&&`.

> ✅ **Regra do curso:** memorize apenas que `*`, `/`, `~/` e `%` vêm antes de `+` e `-`, e que os
> lógicos vêm por último. Em qualquer outro caso, **escreva parênteses**.

---

## 💡 Analogia

Pense em uma **calculadora de cozinha com botões especiais**: `/` divide e mostra casas decimais
("11,5 horas"), `~/` responde "quantas horas cheias?" (`11`) e `%` responde "e o que sobrou?"
(`30`).

Os lógicos são fechaduras: `&&` é o cofre de chave dupla, que só abre com **as duas** chaves
giradas; `||` é a porta de duas maçanetas, que abre com **qualquer uma**; `!` é o interruptor que
inverte a luz. E os de nulo são precaução: `??` é o plano B do bilhete ("se não houver leite, use
água"); `?.` é olhar dentro da caixa antes de enfiar a mão — se a caixa não existir, você não se
machuca, apenas não encontra nada.

---

## 🧪 Exemplo mínimo

O par `~/` e `%` resolvendo o problema mais comum de um app de estudo: mostrar tempo em horas e
minutos. Arquivo: `C:\src\pratica_dart\bin\aula06_minimo.dart`.

```dart
void main() {
  const int totalMinutos = 690;

  final int horas = totalMinutos ~/ 60;
  final int minutos = totalMinutos % 60;

  print('$totalMinutos minutos = $horas h e $minutos min');
}
```

```powershell
dart run bin/aula06_minimo.dart
```

```text
690 minutos = 11 h e 30 min
```

Sem `~/` e `%`, essa conversão exigiria arredondamentos manuais e erraria em algum caso.

---

## 📱 Aplicando no Flutter

- **`~/` e `%`** aparecem sempre que há tempo na tela: o cronômetro de `sessao_screen.dart` no app
  `Foco` converte segundos em `mm:ss` assim, em
  [`projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md`](../../projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md),
  e `indice % 2 == 0` alterna a cor das linhas de uma lista em
  [`06-widgets-e-layouts/09-listas-e-rolagem.md`](../06-widgets-e-layouts/09-listas-e-rolagem.md).
- **`&&` e `||`** decidem o que desenhar ("mostrar o botão salvar **se** o formulário é válido
  **e** não está enviando"), em
  [`07-navegacao-e-formularios/07-validacao-foco-teclado.md`](../07-navegacao-e-formularios/07-validacao-foco-teclado.md).
- **`??` e `?.`** são onipresentes: no Riverpod 3 você escreverá `state.value ?? <String>[]` para
  lidar com estado ainda carregando, em
  [`08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md`](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md),
  e protegerá campos ausentes no JSON em
  [`09-consumo-de-api/04-modelando-respostas-e-erros.md`](../09-consumo-de-api/04-modelando-respostas-e-erros.md).
- **`++`** é o corpo de todo `for` e o que o Projeto 1 faz a cada toque:
  [`projetos/01-projeto-iniciante/01-especificacao.md`](../../projetos/01-projeto-iniciante/01-especificacao.md).

---

## 💻 Código completo

> **Arquivo:** `C:\src\pratica_dart\bin\aula06_operadores.dart`
> **Como executar:** `dart run bin/aula06_operadores.dart` (a partir de `C:\src\pratica_dart`)

```dart
// bin/aula06_operadores.dart
// Aula 6 — Operadores: aritméticos, relacionais, lógicos, compostos e de nulo.

void main() {
  const int minutosEstudados = 690;
  const int metaSemanal = 750;

  // ---------- 1) ARITMÉTICOS ----------
  print('=== 1) ARITMÉTICOS ===');
  print('$minutosEstudados + 60  = ${minutosEstudados + 60}');
  print('$minutosEstudados - $metaSemanal = ${minutosEstudados - metaSemanal}');
  print('$minutosEstudados * 2   = ${minutosEstudados * 2}');
  print('$minutosEstudados / 60  = ${minutosEstudados / 60}   (double)');
  print('$minutosEstudados ~/ 60 = ${minutosEstudados ~/ 60}   (int: horas cheias)');
  print('$minutosEstudados % 60  = ${minutosEstudados % 60}   (int: sobra)');
  print('690 é par? ${minutosEstudados % 2 == 0}');

  // ---------- 2) RELACIONAIS ----------
  print('=== 2) RELACIONAIS ===');
  print('estudado <  meta  -> ${minutosEstudados < metaSemanal}');
  print('estudado >= meta  -> ${minutosEstudados >= metaSemanal}');
  print('estudado != meta  -> ${minutosEstudados != metaSemanal}');

  // ---------- 3) LÓGICOS ----------
  print('=== 3) LÓGICOS ===');
  const bool estudouSegunda = true;
  const bool estudouTerca = false;
  print('segunda && terca -> ${estudouSegunda && estudouTerca}');
  print('segunda || terca -> ${estudouSegunda || estudouTerca}');
  print('!terca           -> ${!estudouTerca}');
  // Condição composta: está entre 600 e 750 minutos?
  final bool dentroDaFaixa = minutosEstudados >= 600 && minutosEstudados <= 750;
  print('entre 600 e 750  -> $dentroDaFaixa');

  // ---------- 4) ATRIBUIÇÃO COMPOSTA ----------
  print('=== 4) ATRIBUIÇÃO COMPOSTA ===');
  int total = 0;
  total += 45;
  print('depois de += 45  -> $total');
  total += 45;
  print('depois de += 45  -> $total');
  total -= 15;
  print('depois de -= 15  -> $total');
  total *= 2;
  print('depois de *= 2   -> $total');
  total ~/= 3;
  print('depois de ~/= 3  -> $total');
  total %= 7;
  print('depois de %= 7   -> $total');

  // ---------- 5) INCREMENTO ----------
  print('=== 5) INCREMENTO ===');
  int contador = 0;
  print('contador++ vale ${contador++}  (usa antes de somar)');
  print('agora contador  = $contador');
  print('++contador vale ${++contador}  (soma antes de usar)');
  print('agora contador  = $contador');

  // ---------- 6) OPERADORES DE NULO ----------
  print('=== 6) OPERADORES DE NULO ===');
  final int? lidoInvalido = int.tryParse('abc');
  final int minutosSeguros = lidoInvalido ?? 0;
  print('int.tryParse("abc")       -> $lidoInvalido');
  print('lidoInvalido ?? 0         -> $minutosSeguros');

  int? cache;
  cache ??= 120;
  print('cache ??= 120 (era null)  -> $cache');
  cache ??= 999;
  print('cache ??= 999 (já tinha)  -> $cache');

  final int? lidoValido = int.tryParse('4');
  print('lidoInvalido?.isEven      -> ${lidoInvalido?.isEven}');
  print('lidoValido?.isEven        -> ${lidoValido?.isEven}');
  print('lidoInvalido?.isEven ?? false -> ${lidoInvalido?.isEven ?? false}');

  // ---------- 7) PRECEDÊNCIA ----------
  print('=== 7) PRECEDÊNCIA ===');
  print('2 + 3 * 4    = ${2 + 3 * 4}   (* antes de +)');
  print('(2 + 3) * 4  = ${(2 + 3) * 4}   (parênteses primeiro)');
  final double percentual = minutosEstudados / metaSemanal * 100;
  print('percentual   = ${percentual.toStringAsFixed(1)}%');
}
```

Saída esperada:

```text
=== 1) ARITMÉTICOS ===
690 + 60  = 750
690 - 750 = -60
690 * 2   = 1380
690 / 60  = 11.5   (double)
690 ~/ 60 = 11   (int: horas cheias)
690 % 60  = 30   (int: sobra)
690 é par? true
=== 2) RELACIONAIS ===
estudado <  meta  -> true
estudado >= meta  -> false
estudado != meta  -> true
=== 3) LÓGICOS ===
segunda && terca -> false
segunda || terca -> true
!terca           -> true
entre 600 e 750  -> true
=== 4) ATRIBUIÇÃO COMPOSTA ===
depois de += 45  -> 45
depois de += 45  -> 90
depois de -= 15  -> 75
depois de *= 2   -> 150
depois de ~/= 3  -> 50
depois de %= 7   -> 1
=== 5) INCREMENTO ===
contador++ vale 0  (usa antes de somar)
agora contador  = 1
++contador vale 2  (soma antes de usar)
agora contador  = 2
=== 6) OPERADORES DE NULO ===
int.tryParse("abc")       -> null
lidoInvalido ?? 0         -> 0
cache ??= 120 (era null)  -> 120
cache ??= 999 (já tinha)  -> 120
lidoInvalido?.isEven      -> null
lidoValido?.isEven        -> true
lidoInvalido?.isEven ?? false -> false
=== 7) PRECEDÊNCIA ===
2 + 3 * 4    = 14   (* antes de +)
(2 + 3) * 4  = 20   (parênteses primeiro)
percentual   = 92.0%
```

---

## 🔍 Explicando o código

### O teste de mesa da seção 4

Esta é a parte que mais derruba iniciante. Acompanhe `total` passo a passo:

| Instrução | Conta | `total` |
|---|---|---|
| `int total = 0;` | — | `0` |
| `total += 45;` | `0 + 45` | `45` |
| `total += 45;` | `45 + 45` | `90` |
| `total -= 15;` | `90 - 15` | `75` |
| `total *= 2;` | `75 * 2` | `150` |
| `total ~/= 3;` | `150 ~/ 3` | `50` |
| `total %= 7;` | `50 % 7` | `1` |

`50 % 7` é `1` porque `7 * 7 = 49` e sobra `1`.

### A seção 5, linha por linha

A primeira linha **usa** o valor `0` e só depois soma — por isso a segunda mostra `1`. A terceira
soma primeiro (1 → 2) e depois usa. Se você previu essa sequência antes de rodar, entendeu a
diferença entre prefixo e sufixo.

### `lidoInvalido?.isEven`

`isEven` é uma propriedade de `int` que devolve `true` para pares. Como `lidoInvalido` é `int?`, o
Dart **não permite** escrever `lidoInvalido.isEven` sem proteção: com `?.` a expressão vale `null`
quando o valor não existe e, com `?? false`, sempre entrega um `bool` utilizável. Esse encadeamento
`?.` + `??` é um dos padrões mais frequentes em Dart profissional.

### `minutosEstudados / metaSemanal * 100` e `% 2 == 0`

Sem parênteses, o Dart avalia da esquerda para a direita, porque `/` e `*` têm a mesma precedência:
`(690 / 750)` = `0.92`, depois `* 100` = `92.0`. O resultado está certo — mas escrever
`(minutosEstudados / metaSemanal) * 100` deixa isso explícito para quem for ler o código depois.

Na outra expressão, `%` (nível 3 da tabela) acontece antes de `==` (nível 6), então
`minutosEstudados % 2 == 0` é lido como `(minutosEstudados % 2) == 0` — e o resto da divisão por 2
só pode ser `0` (par) ou `1` (ímpar).

---

## ⚠️ Erros comuns

**1. Usar `/` quando queria `~/`** — `final int horas = 690 / 60;` produz
`Error: A value of type 'double' can't be assigned to a variable of type 'int'.`
Correção: `final int horas = 690 ~/ 60;`.

**2. Confundir `=` com `==`** — `=` atribui, `==` compara. Em Dart, `if (x = 5)` não compila,
porque o resultado de uma atribuição não é `bool`.

**3. Achar que `!=` é `=!`** — a ordem é "exclamação primeiro": `a != b`.

**4. Esperar que `&&` avalie os dois lados sempre** — por causa do curto-circuito, o lado direito
pode nunca executar. Se você colocou um efeito importante nele, esse efeito pode não acontecer.

**5. Escrever condição sem operador lógico** — `if (600 <= minutos <= 750)` não compila, porque
`600 <= minutos` produz `bool` e comparar `bool <= 750` não faz sentido. Correção:
`if (minutos >= 600 && minutos <= 750)`.

**6. Misturar incremento com leitura** — `total = total++ + 1;` compila, mas confunde quem lê.
Escreva `total = total + 2;` ou duas linhas.

**7. Esquecer o `??` em valor anulável** — `final int minutos = int.tryParse(entrada);` produz
`Error: A value of type 'int?' can't be assigned to a variable of type 'int'.`
Correção: `int.tryParse(entrada) ?? 0`.

**8. Dividir inteiro por zero** — `7 ~/ 0` e `7 % 0` lançam erro em execução. Verifique o divisor
antes, com um `if` (Aula 7).

---

## 🛠️ Exercício guiado

Vamos escrever um **formatador de tempo de estudo** usando `~/`, `%`, `??` e operadores lógicos
juntos.

**Passo 1.** Crie `bin/aula06_guiado.dart` com a entrada chegando como texto e já protegida:

```dart
void main() {
  const String digitado = '455';
  final int totalMinutos = int.tryParse(digitado) ?? 0;

  final int horas = totalMinutos ~/ 60;
  final int minutos = totalMinutos % 60;
  print('$totalMinutos min = $horas h $minutos min');
```

Teste de mesa: `455 ~/ 60` = 7 (porque `7 * 60 = 420`) e `455 % 60` = 35.

**Passo 2.** Acrescente a comparação com a meta e uma condição composta:

```dart
  const int metaMinutos = 480;
  final int falta = metaMinutos - totalMinutos;
  final bool bateuMeta = totalMinutos >= metaMinutos;
  final bool quaseLa = !bateuMeta && falta <= 60;

  print('Bateu a meta? $bateuMeta');
  print('Está quase lá? $quaseLa  (faltam $falta min)');
}
```

Preveja antes de rodar: `bateuMeta` é `false`; `falta` é `25`; `quaseLa` é `true`, porque
`!false && 25 <= 60`.

**Passo 3.** Execute e confira:

```powershell
dart run bin/aula06_guiado.dart
```

```text
455 min = 7 h 35 min
Bateu a meta? false
Está quase lá? true  (faltam 25 min)
```

**Passo 4.** Troque `digitado` para `'quinhentos'` e rode. Graças ao `?? 0` o programa **não
quebra**: mostra `0 min = 0 h 0 min` e `faltam 480 min`. Repare que ele não avisa que a entrada era
inválida — avisar exige decisão, e decisão é a [Aula 7](07-condicoes.md).

**Passo 5.** Troque para `'480'` e confirme que `bateuMeta` vira `true` e `quaseLa` vira `false`
(porque `!true` é `false`, e o `&&` nem chega a olhar o outro lado). Depois salve:

```powershell
git add .
git commit -m "aula 06: operadores aplicados ao formatador de tempo"
```

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/01-logica-e-fundamentos.md](../../exercicios/01-logica-e-fundamentos.md)

Faça em especial os de **Leitura de código** (prever o valor de expressões com precedência) e os de
**Correção de bugs** (`/` no lugar de `~/`, `=` no lugar de `==`, falta de `??`).

---

## 🏆 Desafio opcional

Escreva `bin/aula06_desafio.dart`, uma **calculadora de plano de estudo** que, a partir de um total
de minutos disponíveis na semana, calcule e imprima: quantas **sessões completas** de 45 minutos
cabem (`~/`); quantos minutos **sobram** (`%`); quantas **pausas** de 15 minutos serão necessárias
(uma entre cada par de sessões — cuidado com o caso de zero sessões); o **tempo total na mesa**; e
um `bool` dizendo se o plano cabe em 5 dias de 4 horas.

Restrições: use `??` para proteger a leitura da entrada, use pelo menos uma atribuição composta,
não use `if` (você ainda não viu — expresse tudo como expressões e `bool`) e faça o teste de mesa
para `600` minutos **antes** de executar.

Depois da [Aula 7](07-condicoes.md), volte e acrescente mensagens diferentes conforme o plano caiba
ou não — e note como o programa fica mais útil quando sabe decidir.

---

## 📌 Resumo

- **Operador** age sobre **operandos** e produz uma **expressão** com valor.
- Aritméticos: `+ - * /`, mais `~/` (divisão inteira, devolve `int`) e `%` (resto); `/` sempre
  devolve `double`. Juntos, `~/` e `%` convertem minutos em "h e min" e testam paridade.
- Relacionais (`> < >= <= == !=`) devolvem `bool`. `=` atribui, `==` compara.
- Lógicos: `&&` (ambos), `||` (ao menos um), `!` (inverte), com **curto-circuito**.
- Atribuição composta (`+= -= *= ~/= %=`) encurta "leia, opere, guarde"; `contador++` usa o valor
  antes de somar e `++contador` soma antes de usar.
- Nulo: `??` dá valor padrão, `??=` atribui só se for nulo, `?.` acessa com segurança.
- Precedência: `* / ~/ %` antes de `+ -`; comparações antes dos lógicos. Na dúvida, **parênteses**.

---

## ☑️ Checklist de domínio

- [x] Converto minutos em horas e minutos com `~/` e `%` sem consultar, e testo paridade com `%`.
- [x] Explico por que `690 / 60` não cabe em um `int`.
- [x] Monto a tabela-verdade de `&&`, `||` e `!` de memória.
- [x] Explico o que é curto-circuito e dou um exemplo em que ele protege o código.
- [x] Uso atribuição composta e sei o equivalente longo de cada forma.
- [x] Digo a diferença entre `c++` e `++c` mostrando a saída de cada um.
- [x] Uso `??`, `??=` e `?.` no lugar certo.
- [x] Sei que `* / ~/ %` vêm antes de `+ -` e uso parênteses no resto.
- [x] Executei `bin/aula06_operadores.dart` e a saída bateu com a esperada.

---

## 📚 Referências oficiais

- [Dart — Operadores](https://dart.dev/language/operators)
- [Dart — Entendendo null safety](https://dart.dev/null-safety/understanding-null-safety)
- [Dart — `num.remainder`](https://api.dart.dev/stable/dart-core/num/remainder.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Tipos de dados](05-tipos-de-dados.md) | [README](README.md) | [Aula 7 — Condições](07-condicoes.md) |
