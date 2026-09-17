# Aula 4 — Variáveis e constantes

> **Módulo:** 01 - Lógica e Fundamentos · **Tempo estimado:** 35 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Explicar o que é **memória** e o que significa "guardar um valor".
- Declarar **variáveis** em Dart e entender o que é **atribuição**.
- Aplicar as regras e as convenções de **nomes** de variáveis em Dart.
- Diferenciar `var`, `final` e `const` e escolher conscientemente entre eles.
- Explicar por que `const` exige um valor conhecido em tempo de compilação.
- Reconhecer quando usar constante e quando usar variável em um problema real.

## ✅ Pré-requisitos

- [Aula 1 — O que é programar](01-o-que-e-programar.md).
- [Aula 3 — Algoritmos e decomposição](03-algoritmos-e-decomposicao.md): EPS e teste de mesa.
- Projeto `C:\src\pratica_dart` funcionando.

---

## 📖 Conceito

### 1. Memória: onde os valores ficam

A **memória RAM** (*Random Access Memory* — memória de acesso aleatório) é o espaço de trabalho do
computador: rápida, temporária e limitada. Tudo o que um programa está usando **agora** está lá.
Quando o processo termina, o sistema recupera esse espaço e os valores somem.

Imagine a memória como uma rua com milhões de armários numerados. Cada armário tem:

- um **endereço** (o número do armário) — que você quase nunca vai ver em Dart;
- um **conteúdo** (o valor guardado);
- um **tamanho**, que depende do tipo do valor.

Programar sem variáveis significaria dizer "vá ao armário 0x7FFE3A e some 1 ao conteúdo". Nomear
armários é exatamente o serviço que a variável presta.

### 2. Variável

**Variável** é um nome que você dá a um espaço de memória para guardar um valor que **pode mudar**
durante a execução do programa.

Em Dart, declarar uma variável tem três partes:

```dart
int minutosEstudados = 0;
```

| Parte | Nome | Papel |
|---|---|---|
| `int` | **tipo** | diz que espécie de valor cabe ali (aqui, número inteiro) |
| `minutosEstudados` | **identificador** | o nome pelo qual você acessa o valor |
| `= 0` | **inicialização** | o primeiro valor guardado |

### 3. Atribuição

**Atribuição** é o ato de colocar um valor dentro de uma variável. O operador é o `=`.

```dart
minutosEstudados = 45;
```

Leia assim: "**minutosEstudados recebe 45**". Nunca leia "é igual a" — essa leitura vai te
confundir na primeira vez que encontrar:

```dart
minutosEstudados = minutosEstudados + 30;
```

Matematicamente isso seria falso (nenhum número é igual a ele mesmo mais 30). Como atribuição, é
perfeitamente claro e acontece em duas etapas:

1. O Dart **calcula o lado direito** usando o valor atual: `45 + 30` = `75`.
2. O Dart **guarda o resultado** no lado esquerdo: `minutosEstudados` passa a valer `75`.

Comparação de igualdade é `==`, com dois sinais, e você a usa na [Aula 6](06-operadores.md).

### 4. Nomes de variáveis

**Regras obrigatórias** (o Dart recusa compilar se você violar):

- Comece com letra ou `_` (sublinhado). Nunca com número.
- Depois disso, use letras, números e `_`.
- Sem espaços, sem acentos, sem `-`, sem `@`, sem `$`.
- Não use **palavras reservadas** da linguagem (`class`, `if`, `for`, `final`, `true`, `void`…).
- Maiúsculas e minúsculas são diferentes: `total` e `Total` são duas variáveis distintas.

**Convenções do Dart** (não impedem a compilação, mas o analisador avisa e todo código
profissional segue):

| Elemento | Convenção | Exemplo |
|---|---|---|
| Variável e função | `lowerCamelCase` | `minutosEstudados`, `calcularMedia` |
| Classe e tipo | `UpperCamelCase` | `Materia`, `SessaoDeEstudo` |
| Arquivo e pasta | `snake_case` | `materia_repositorio.dart` |
| Constante | `lowerCamelCase` (**não** use `MAIUSCULAS_COM_UNDERLINE`) | `metaDiariaMinutos` |

> ⚠️ Vindo de Java ou Python, a tentação de escrever `META_DIARIA = 240` é grande. Em Dart isso
> contraria o guia oficial de estilo e o pacote `flutter_lints ^6.0.0` que este curso usa. Escreva
> `metaDiariaMinutos`.

**Nomes bons contam uma história.** Compare:

```dart
int x = 690;        // x de quê?
int t = 690;        // total de quê?
int totalMinutosSemana = 690;  // sem dúvida nenhuma
```

O nome longo não custa desempenho: ele desaparece na compilação. Custa apenas digitação — e o
autocompletar do VS Code resolve isso.

### 5. Constante: o valor que não muda

**Constante** é um nome ligado a um valor que **não pode ser trocado** depois de definido. Dart tem
duas palavras para isso, e a diferença entre elas é importante:

#### `final` — atribuído uma vez, em tempo de execução

```dart
final int totalMinutos = segunda + terca + quarta;
final DateTime agora = DateTime.now();
```

O valor pode ser calculado durante a execução; o que `final` garante é que ele só será atribuído
**uma vez**. Tentar reatribuir não compila.

#### `const` — conhecido já em tempo de compilação

```dart
const int metaDiariaMinutos = 240;
const String nomeDoApp = 'Foco';
const double taxaDeConversao = 1.5;
```

`const` é mais forte: o valor precisa ser calculável **antes** de o programa rodar. Por isso
`const DateTime agora = DateTime.now();` **não compila** — ninguém sabe que horas serão quando o
programa executar.

Em troca, o compilador pode embutir o valor direto no código gerado e reaproveitar a mesma
instância em todo o programa. No Flutter isso vira desempenho de verdade, como você verá em
[`13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md`](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md).

#### `var` — o tipo é deduzido, o valor pode mudar

```dart
var minutos = 45;      // o Dart deduz: int
minutos = 60;          // permitido
minutos = 'sessenta';  // ERRO: o tipo já foi fixado como int
```

`var` **não** significa "sem tipo". Significa "deduza o tipo a partir do valor inicial". Uma vez
deduzido, o tipo é definitivo. Isso é **inferência de tipo**, e é diferente de tipagem dinâmica —
assunto da [Aula 5](05-tipos-de-dados.md).

### 6. A regra de decisão do curso

```text
O valor muda durante a execução?
├── NÃO → é conhecido antes de rodar?
│         ├── SIM → const
│         └── NÃO → final
└── SIM → var (ou o tipo explícito: int, double, String...)
```

Dito em uma frase: **comece por `const`; se não der, `final`; só use variável quando o valor
realmente precisar mudar.**

Por que essa ordem? Porque cada valor que **não pode** mudar é um valor que você não precisa
rastrear mentalmente ao ler o código. Variável demais é o que transforma um arquivo de 200 linhas
em um quebra-cabeça.

| Palavra | Pode reatribuir? | Quando o valor é definido | Uso típico |
|---|---|---|---|
| `const` | ❌ não | em tempo de compilação | meta fixa, nome do app, número de dias úteis |
| `final` | ❌ não | em tempo de execução, uma vez | resultado de uma conta, data/hora atual, dado lido |
| `var` | ✅ sim | em tempo de execução | contador, acumulador, estado que evolui |

---

## 💡 Analogia

Pense em uma **etiqueta colada em um pote** dentro de um armário de cozinha.

O **pote** é o espaço de memória, a **etiqueta** é o nome da variável, o **conteúdo** é o valor e
**atribuir** é trocar o conteúdo mantendo a etiqueta. As três palavras do Dart:

- `var` é um pote comum: você troca o conteúdo quando quiser.
- `final` é um pote que você enche **uma vez** e lacra — pode enchê-lo com o que preparou na hora,
  mas depois não troca mais.
- `const` é um pote lacrado **na fábrica**, com o conteúdo impresso no rótulo antes de a cozinha
  existir. Se você precisa cozinhar para saber o que vai dentro, não pode ser `const`.

Limite honesto da analogia: em Dart, `final` impede trocar **o pote**, não necessariamente mexer no
conteúdo quando o conteúdo é uma coleção. Uma `final List` não pode virar outra lista, mas pode
receber itens. Isso é tratado em
[`02-dart-basico/03-var-final-const.md`](../02-dart-basico/03-var-final-const.md).

---

## 🧪 Exemplo mínimo

> Arquivo: `C:\src\pratica_dart\bin\aula04_minimo.dart`

```dart
void main() {
  const int metaDiaria = 240;  // nunca muda
  int estudadoHoje = 0;        // vai mudar

  print('Meta: $metaDiaria min | Estudado: $estudadoHoje min');

  estudadoHoje = estudadoHoje + 90;
  print('Depois da 1ª sessão: $estudadoHoje min');

  estudadoHoje = estudadoHoje + 60;
  print('Depois da 2ª sessão: $estudadoHoje min');
}
```

```powershell
dart run bin/aula04_minimo.dart
```

```text
Meta: 240 min | Estudado: 0 min
Depois da 1ª sessão: 90 min
Depois da 2ª sessão: 150 min
```

Faça o teste de mesa antes: `estudadoHoje` vale 0, depois 90, depois 150. `metaDiaria` nunca sai
de 240 — e se você tentar mudá-la, o Dart nem compila.

---

## 📱 Aplicando no Flutter

- **`const` em widgets** é uma técnica central de desempenho. Um widget marcado como `const` é
  construído **uma única vez** e reaproveitado em todas as reconstruções da tela, em vez de ser
  criado do zero a cada quadro. Você verá `const Text('Foco')` centenas de vezes a partir de
  [`05-introducao-ao-flutter/04-statelesswidget.md`](../05-introducao-ao-flutter/04-statelesswidget.md),
  e entenderá o ganho em
  [`13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md`](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md).
- **`final` em campos de classe** é o padrão de todo widget imutável: um `StatelessWidget` guarda
  seus dados em campos `final` porque eles não mudam depois de o widget ser criado.
- **Variável que muda** é o que caracteriza o *estado*: o contador que você incrementa hoje vira um
  valor guardado em um `StatefulWidget` (em
  [`05-introducao-ao-flutter/05-statefulwidget-e-setstate.md`](../05-introducao-ao-flutter/05-statefulwidget-e-setstate.md))
  e depois em um `Notifier` do Riverpod (em
  [`08-estado-e-arquitetura/06-notifier-e-notifierprovider.md`](../08-estado-e-arquitetura/06-notifier-e-notifierprovider.md)).
- **Constantes centralizadas**: o projeto final guarda valores fixos em
  `lib/core/constants/app_constants.dart`, conforme
  [`projetos/03-projeto-final-multiplataforma/02-arquitetura.md`](../../projetos/03-projeto-final-multiplataforma/02-arquitetura.md).

Uma frase para guardar: no Flutter, **estado é a variável que muda; todo o resto deveria ser
`final` ou `const`**.

---

## 💻 Código completo

> **Arquivo:** `C:\src\pratica_dart\bin\aula04_variaveis.dart`
> **Como executar:** `dart run bin/aula04_variaveis.dart` (a partir de `C:\src\pratica_dart`)

```dart
// bin/aula04_variaveis.dart
// Aula 4 — Variáveis e constantes.
// Simula um dia de estudo: o que é fixo fica em const/final,
// o que evolui fica em variável.

void main() {
  // ---------- CONSTANTES (const): conhecidas antes de rodar ----------
  const String nomeDoAluno = 'Estudante Foco';
  const String nomeDoCurso = 'Curso Flutter Intensivo';
  const int metaDiariaMinutos = 240;
  const int duracaoSessaoMinutos = 45;
  const int duracaoPausaMinutos = 15;

  // ---------- FINAL: valor definido uma vez, durante a execução ----------
  // DateTime é o tipo do Dart para um instante no tempo.
  // DateTime.now() devolve o momento exato em que a linha executa,
  // por isso NÃO pode ser const: ninguém sabe isso antes de rodar.
  final DateTime inicioDoDia = DateTime.now();
  final int anoAtual = inicioDoDia.year;

  // ---------- VARIÁVEIS: mudam ao longo do programa ----------
  int minutosEstudados = 0;
  int sessoesConcluidas = 0;
  int minutosEmPausa = 0;

  print('=== $nomeDoCurso ===');
  print('Aluno: $nomeDoAluno');
  print('Ano: $anoAtual');
  print('Meta de hoje: $metaDiariaMinutos min');
  print('Sessão padrão: $duracaoSessaoMinutos min | Pausa: $duracaoPausaMinutos min');
  print('');

  // ----- Sessão 1 -----
  minutosEstudados = minutosEstudados + duracaoSessaoMinutos;
  sessoesConcluidas = sessoesConcluidas + 1;
  minutosEmPausa = minutosEmPausa + duracaoPausaMinutos;
  print('Sessão $sessoesConcluidas concluída -> estudado: $minutosEstudados min');

  // ----- Sessão 2 -----
  minutosEstudados = minutosEstudados + duracaoSessaoMinutos;
  sessoesConcluidas = sessoesConcluidas + 1;
  minutosEmPausa = minutosEmPausa + duracaoPausaMinutos;
  print('Sessão $sessoesConcluidas concluída -> estudado: $minutosEstudados min');

  // ----- Sessão 3 (mais longa que o padrão) -----
  const int sessaoLongaMinutos = 90;
  minutosEstudados = minutosEstudados + sessaoLongaMinutos;
  sessoesConcluidas = sessoesConcluidas + 1;
  print('Sessão $sessoesConcluidas concluída -> estudado: $minutosEstudados min');

  print('');

  // ---------- FECHAMENTO: valores derivados ----------
  final int faltaParaMeta = metaDiariaMinutos - minutosEstudados;
  final double percentualDaMeta = (minutosEstudados / metaDiariaMinutos) * 100;
  final int tempoTotalNaMesa = minutosEstudados + minutosEmPausa;

  print('=== FECHAMENTO DO DIA ===');
  print('Sessões concluídas : $sessoesConcluidas');
  print('Minutos estudados  : $minutosEstudados');
  print('Minutos em pausa   : $minutosEmPausa');
  print('Tempo na mesa      : $tempoTotalNaMesa min');
  print('Falta para a meta  : $faltaParaMeta min');
  print('Percentual da meta : ${percentualDaMeta.toStringAsFixed(1)}%');

  // ---------- O QUE NÃO COMPILA (deixe comentado e leia) ----------
  // metaDiariaMinutos = 300;
  //   -> erro: não é possível atribuir a uma constante.
  // inicioDoDia = DateTime.now();
  //   -> erro: 'final' só aceita uma atribuição.
  // const DateTime agora = DateTime.now();
  //   -> erro: 'const' exige valor conhecido em tempo de compilação.
}
```

Saída esperada (o ano depende do relógio da sua máquina):

```text
=== Curso Flutter Intensivo ===
Aluno: Estudante Foco
Ano: 2026
Meta de hoje: 240 min
Sessão padrão: 45 min | Pausa: 15 min

Sessão 1 concluída -> estudado: 45 min
Sessão 2 concluída -> estudado: 90 min
Sessão 3 concluída -> estudado: 180 min

=== FECHAMENTO DO DIA ===
Sessões concluídas : 3
Minutos estudados  : 180
Minutos em pausa   : 30
Tempo na mesa      : 210 min
Falta para a meta  : 60 min
Percentual da meta : 75.0%
```

---

## 🔍 Explicando o código

### As três categorias, lado a lado

| Declaração | Categoria | Por que essa escolha |
|---|---|---|
| `const String nomeDoAluno = 'Estudante Foco';` | `const` | texto fixo, escrito por você no arquivo |
| `const int metaDiariaMinutos = 240;` | `const` | regra do plano de estudo, não muda no dia |
| `final DateTime inicioDoDia = DateTime.now();` | `final` | só existe quando o programa roda |
| `final int anoAtual = inicioDoDia.year;` | `final` | derivado de algo que só existe em execução |
| `int minutosEstudados = 0;` | variável | é o número que o dia inteiro modifica |
| `int sessoesConcluidas = 0;` | variável | contador |
| `final int faltaParaMeta = ...;` | `final` | calculado uma vez, no fim, e não muda mais |

### O acumulador

```dart
minutosEstudados = minutosEstudados + duracaoSessaoMinutos;
```

Esse padrão tem nome: **acumulador**. Ele lê o valor atual, soma algo e guarda o resultado de
volta no mesmo lugar. Aparece em praticamente todo programa que conta, soma ou totaliza — e é a
espinha dorsal dos laços da [Aula 8](08-repeticoes.md).

Existe uma forma abreviada, `minutosEstudados += duracaoSessaoMinutos;`, que você aprende na
[Aula 6](06-operadores.md). Aqui a forma longa foi mantida de propósito, para você enxergar as duas
etapas da atribuição.

### `const` declarada no meio do código

`const int sessaoLongaMinutos = 90;` mostra que constantes não precisam ficar todas no topo:
declarar perto do uso costuma ser melhor. O critério é o **escopo** (a região do programa em que o
nome existe), estudado na [Aula 9](09-funcoes.md).

### Por que `inicioDoDia.year` e não `inicioDoDia`?

`DateTime.now()` devolve um instante completo, até o milissegundo: imprimi-lo inteiro faria a saída
mudar a cada execução. Pegando só `.year`, a saída fica previsível — e **tornar a saída previsível**
é o que permite escrever testes automatizados no
[Módulo 12](../12-testes-e-debug/README.md).

### O bloco comentado no fim é conteúdo, não sobra

As três linhas comentadas registram os três erros que você **vai** cometer. Descomente uma de cada
vez, rode e leia a mensagem — é um excelente aquecimento para a
[Aula 10](10-lendo-mensagens-de-erro.md).

---

## ⚠️ Erros comuns

**1. Tentar reatribuir uma constante**

```dart
const int meta = 240;
meta = 300;
```

```text
Error: Can't assign to the const variable 'meta'.
```

Correção: se o valor precisa mudar, ele não é constante. Declare como `int meta = 240;`.

**2. Usar `const` com valor calculado em execução**

```dart
const DateTime agora = DateTime.now();
```

```text
Error: Const variables must be initialized with a constant value.
```

Correção: troque para `final`.

**3. Nome com acento ou espaço** — `int minutos estudados = 0;` e `int çodigo = 1;` não compilam.
Correção: `minutosEstudados`, `codigo`.

**4. `MAIUSCULAS_COM_UNDERLINE` para constantes**

Compila, mas contraria o guia oficial e o `flutter_lints`. Em Dart, constantes usam
`lowerCamelCase`.

**5. Achar que `var` é "sem tipo"**

```dart
var minutos = 45;
minutos = 'quarenta e cinco';
```

```text
Error: A value of type 'String' can't be assigned to a variable of type 'int'.
```

`var` deduz o tipo do valor inicial e o fixa para sempre.

**6. Esquecer de inicializar uma variável não anulável**

```dart
int contador;
print(contador);
```

O Dart recusa, porque `int` (sem `?`) nunca pode ser nulo e a variável não recebeu valor. Correção:
`int contador = 0;`. Esse assunto tem aula inteira em
[`02-dart-basico/05-null-safety.md`](../02-dart-basico/05-null-safety.md).

**7. Nomes que não dizem nada** — `a`, `b`, `x1`, `temp`, `dados2` custam a mesma digitação de
`totalMinutos` e custam muito mais leitura depois.

---

## 🛠️ Exercício guiado

Você vai transformar o programa da aula em um **registro de duas matérias**.

**Passo 1.** Copie `bin/aula04_variaveis.dart` para `bin/aula04_guiado.dart`.

**Passo 2.** Acrescente duas constantes com os nomes das matérias:

```dart
const String materiaA = 'Dart';
const String materiaB = 'Flutter';
```

**Passo 3.** Crie duas variáveis acumuladoras, uma por matéria:

```dart
int minutosDart = 0;
int minutosFlutter = 0;
```

**Passo 4.** Distribua as sessões: a sessão 1 e a 3 vão para Dart, a sessão 2 vai para Flutter.
Depois de cada sessão, some no acumulador certo **e** em `minutosEstudados`:

```dart
minutosDart = minutosDart + duracaoSessaoMinutos;
minutosEstudados = minutosEstudados + duracaoSessaoMinutos;
```

**Passo 5.** Antes de rodar, faça o teste de mesa:

| Depois de | `minutosDart` | `minutosFlutter` | `minutosEstudados` |
|---|---|---|---|
| Sessão 1 (45, Dart) | 45 | 0 | 45 |
| Sessão 2 (45, Flutter) | 45 | 45 | 90 |
| Sessão 3 (90, Dart) | 135 | 45 | 180 |

**Passo 6.** Imprima o fechamento por matéria:

```dart
print('$materiaA: $minutosDart min');
print('$materiaB: $minutosFlutter min');
```

**Passo 7.** Execute e compare com a sua tabela:

```powershell
dart run bin/aula04_guiado.dart
```

**Passo 8.** Tente, **de propósito**, escrever `materiaA = 'Dart avançado';` e rode. Leia a
mensagem inteira e depois apague a linha: você acabou de comprovar o que `const` garante.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/01-logica-e-fundamentos.md](../../exercicios/01-logica-e-fundamentos.md)

Priorize os de **Fixação** sobre `var`/`final`/`const` e os de **Correção de bugs**, com
reatribuição indevida e nomes fora da convenção.

---

## 🏆 Desafio opcional

Escreva `bin/aula04_desafio.dart` que simule o **orçamento de tempo de uma semana**:

1. Constantes: horas totais disponíveis na semana (`const int horasDisponiveis = 28;`), nome das
   quatro áreas de estudo.
2. Variáveis: horas alocadas em cada área, começando em zero.
3. Aloque horas, área por área, usando o padrão acumulador.
4. No fim, imprima: horas alocadas no total, horas ainda livres e o percentual comprometido.
5. Faça o teste de mesa em papel **antes** de executar.

Restrição: **não** deixe nenhuma variável que pudesse ser `final` ou `const`. O objetivo é treinar
o reflexo de usar sempre a declaração mais restritiva possível.

---

## 📌 Resumo

- **Memória** é o espaço temporário onde os valores vivem; **variável** é o nome de um desses
  espaços. **Atribuição** (`=`) significa "recebe": calcula o lado direito e guarda no esquerdo.
  Comparação é `==`.
- Nomes: letra ou `_` no início, sem acento nem espaço. Convenção Dart: `lowerCamelCase` para
  variáveis e constantes, `UpperCamelCase` para tipos, `snake_case` para arquivos.
- `const` = valor conhecido em tempo de **compilação**, não reatribuível.
- `final` = valor definido **uma vez** em tempo de execução, não reatribuível.
- `var` = tipo **deduzido** do valor inicial; o valor pode mudar, o tipo não.
- Regra do curso: **`const` → `final` → variável**, nessa ordem de preferência.
- O padrão **acumulador** (`x = x + algo`) é a base de todo cálculo que totaliza.

---

## ☑️ Checklist de domínio

- [x] Explico o que é memória e o que acontece quando o programa termina.
- [x] Leio `x = x + 1` corretamente ("x recebe x mais 1") e sei em que ordem o Dart avalia.
- [x] Digo três regras obrigatórias de nomes de variáveis em Dart.
- [x] Escrevo variáveis e constantes em `lowerCamelCase` sem hesitar.
- [x] Explico a diferença entre `final` e `const` com um exemplo de cada.
- [x] Digo por que `const DateTime agora = DateTime.now();` não compila.
- [x] Aplico a ordem `const → final → var` ao escrever código novo.
- [x] Executei `bin/aula04_variaveis.dart` e previ a saída antes de rodar.
- [x] Provoquei os três erros comentados no fim do arquivo e li cada mensagem.

---

## 📚 Referências oficiais

- [Dart — Variáveis](https://dart.dev/language/variables)
- [Dart — `final` e `const`](https://dart.dev/language/variables#final-and-const)
- [Dart — Guia de estilo: identificadores](https://dart.dev/effective-dart/style#identifiers)
- [Dart — Palavras reservadas](https://dart.dev/language/keywords)
- [Dart — API de `DateTime`](https://api.dart.dev/stable/dart-core/DateTime-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Algoritmos e decomposição](03-algoritmos-e-decomposicao.md) | [README](README.md) | [Aula 5 — Tipos de dados](05-tipos-de-dados.md) |
