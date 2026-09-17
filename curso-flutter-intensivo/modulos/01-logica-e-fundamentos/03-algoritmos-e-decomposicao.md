# Aula 3 — Algoritmos e decomposição

> **Módulo:** 01 - Lógica e Fundamentos · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Definir **algoritmo** e reconhecer algoritmos fora da programação.
- Separar qualquer problema em **entrada**, **processamento** e **saída**.
- Escrever **pseudocódigo** curto antes de escrever Dart.
- **Decompor** um problema grande em subproblemas pequenos e resolvíveis.
- Executar um **teste de mesa** em papel e prever a saída antes de rodar o programa.
- Traduzir um algoritmo escrito em português para um programa Dart que roda.

## ✅ Pré-requisitos

- [Aula 1 — O que é programar](01-o-que-e-programar.md): `main`, `print`, interpolação.
- [Aula 2 — Dart e Flutter](02-dart-e-flutter.md): noção de onde tudo isso vai parar.
- Projeto `C:\src\pratica_dart` funcionando.

---

## 📖 Conceito

### 1. O que é um algoritmo

**Algoritmo** é uma sequência **finita**, **ordenada** e **não ambígua** de passos que, a partir de
dados de entrada, produz um resultado.

Quebrando a definição, porque cada palavra tem peso:

- **Finita**: tem fim. Um conjunto de passos que nunca termina não é algoritmo — é um travamento
  (você vai ver isso como *laço infinito* na [Aula 8](08-repeticoes.md)).
- **Ordenada**: a ordem dos passos altera o resultado. "Coloque o bolo no forno" antes de "misture
  os ingredientes" produz outra coisa.
- **Não ambígua**: cada passo tem um único entendimento possível. "Adicione sal a gosto" não serve
  para uma máquina.

Algoritmo **não é código**. Código é uma das formas de escrever um algoritmo. A receita de bolo da
sua avó é um algoritmo. O manual de troca de pneu é um algoritmo. O caminho que você decora até o
trabalho é um algoritmo.

### 2. Entrada, processamento e saída (EPS)

Todo programa cabe nesse trio. Fixe-o: ele vai te salvar sempre que você não souber por onde
começar.

| Etapa | Pergunta que ela responde | Exemplo na receita | Exemplo no app `Foco` |
|---|---|---|---|
| **Entrada** | De que dados eu preciso? | farinha, ovos, açúcar, forno | minutos estudados por dia |
| **Processamento** | Que transformação eu aplico? | misturar, bater, assar 40 min | somar, dividir, comparar com a meta |
| **Saída** | O que eu entrego? | um bolo | "Você cumpriu 92% da meta desta semana" |

Quando você travar em um problema, escreva essas três linhas antes de qualquer outra coisa:

```text
ENTRADA: ...
PROCESSAMENTO: ...
SAÍDA: ...
```

Na enorme maioria das vezes, o simples ato de preencher as três linhas já revela o caminho.

### 3. Pseudocódigo

**Pseudocódigo** é o algoritmo escrito em português estruturado: tem a precisão de um programa, mas
não obedece à sintaxe de nenhuma linguagem. Serve para você pensar sem brigar com ponto e vírgula.

Receita, em pseudocódigo:

```text
INÍCIO
  RECEBER farinha, ovos, acucar
  misturar farinha, ovos e acucar ate ficar homogeneo
  aquecer o forno a 180 graus
  despejar a massa na forma
  assar por 40 minutos
  ESCREVER "bolo pronto"
FIM
```

Média de estudo da semana, em pseudocódigo:

```text
INÍCIO
  RECEBER minutosSeg, minutosTer, minutosQua, minutosQui, minutosSex
  totalMinutos <- minutosSeg + minutosTer + minutosQua + minutosQui + minutosSex
  mediaMinutos <- totalMinutos / 5
  ESCREVER "Total: ", totalMinutos
  ESCREVER "Média por dia: ", mediaMinutos
FIM
```

Convenções úteis (e usadas o curso inteiro):

- `<-` significa "recebe o valor de" (atribuição).
- `RECEBER` marca entrada, `ESCREVER` marca saída.
- Maiúsculas para as palavras estruturais, minúsculas para os dados.

> ⚠️ Pseudocódigo é **rascunho**, não entrega. Neste curso ele aparece só para organizar o
> pensamento; o produto final é sempre Dart que executa de verdade.

### 4. Decomposição: quebrar o problema grande

**Decompor** é dividir um problema que você não sabe resolver em problemas menores que você sabe.

Problema grande: *"fazer um app que acompanha meus estudos"*. Impossível de atacar de uma vez.
Decomposto:

```text
App Foco
├── 1. Guardar matérias
│   ├── 1.1 cadastrar matéria
│   ├── 1.2 listar matérias
│   ├── 1.3 editar matéria
│   └── 1.4 excluir matéria
├── 2. Registrar sessões de estudo
│   ├── 2.1 marcar o tempo (cronômetro)
│   └── 2.2 somar os minutos na matéria certa
├── 3. Definir meta semanal
│   ├── 3.1 guardar a meta em minutos
│   └── 3.2 comparar o estudado com a meta
└── 4. Mostrar estatísticas
    ├── 4.1 total por matéria
    └── 4.2 progresso da meta
```

Repare: **4.2** ("progresso da meta") é pequeno o suficiente para virar um algoritmo de quatro
linhas — e é exatamente o que você vai programar hoje. O app inteiro é a soma de dezenas de
pedaços desse tamanho.

Três sinais de que um subproblema já está pequeno o bastante:

1. Você consegue descrevê-lo em **uma frase** com um verbo só.
2. Você consegue dizer a **entrada** e a **saída** dele sem hesitar.
3. Você consegue imaginar como testar se ele está certo.

### 5. Teste de mesa

**Teste de mesa** é executar o algoritmo **você mesmo**, com papel e caneta, anotando o valor de
cada variável a cada passo. É a ferramenta mais subestimada da programação: ela encontra erros de
raciocínio que nenhum computador aponta, porque um programa errado que roda continua rodando.

Como se faz: monte uma tabela com uma coluna por variável e uma linha por passo.

Algoritmo:

```text
total <- 0
total <- total + 120
total <- total + 180
total <- total + 90
media <- total / 3
ESCREVER media
```

Teste de mesa:

| Passo | Instrução | `total` | `media` | Saída |
|---|---|---|---|---|
| 1 | `total <- 0` | 0 | — | |
| 2 | `total <- total + 120` | 120 | — | |
| 3 | `total <- total + 180` | 300 | — | |
| 4 | `total <- total + 90` | 390 | — | |
| 5 | `media <- total / 3` | 390 | 130.0 | |
| 6 | `ESCREVER media` | 390 | 130.0 | `130.0` |

Se a sua tabela dá `130.0` e o programa imprime outra coisa, o problema está no **código**. Se a
tabela dá um valor que você sabe estar errado, o problema está no **algoritmo**. Saber de qual dos
dois lados está o defeito economiza horas.

---

## 💡 Analogia

Um algoritmo é uma **receita**; um programa é essa receita escrita em um idioma que a cozinha
entende.

- **Entrada** são os ingredientes sobre a bancada.
- **Processamento** é o modo de preparo.
- **Saída** é o prato servido.
- **Decompor** é o que todo cozinheiro faz ao preparar um jantar de quatro pratos: não existe
  "fazer o jantar", existem quatro receitas independentes e uma ordem de execução.
- **Teste de mesa** é ler a receita em voz alta antes de acender o fogo, imaginando cada etapa. É
  quando você descobre que a receita manda usar o forno pré-aquecido, mas nunca mandou ligar o
  forno.

Um detalhe honesto da analogia: a cozinheira improvisa quando falta um ingrediente; o computador
não improvisa nunca. Toda decisão precisa estar escrita.

---

## 🧪 Exemplo mínimo

O trio EPS em nove linhas de Dart.

> Arquivo: `C:\src\pratica_dart\bin\aula03_minimo.dart`

```dart
void main() {
  // ENTRADA
  const int minutosSegunda = 120;
  const int minutosTerca = 180;

  // PROCESSAMENTO
  final int total = minutosSegunda + minutosTerca;
  final double media = total / 2;

  // SAÍDA
  print('Total: $total minutos');
  print('Média: $media minutos por dia');
}
```

```powershell
dart run bin/aula03_minimo.dart
```

```text
Total: 300 minutos
Média: 150.0 minutos por dia
```

Antes de rodar, faça o teste de mesa: `total` = 300, `media` = 150.0. Se você previu certo, você
entendeu o programa — e não apenas o executou.

---

## 📱 Aplicando no Flutter

Decomposição não é um exercício escolar: é literalmente a arquitetura do curso.

- A **arquitetura feature-first** que você vai usar no projeto final, em
  [`08-estado-e-arquitetura/09-arquitetura-feature-first.md`](../08-estado-e-arquitetura/09-arquitetura-feature-first.md),
  é decomposição aplicada a pastas: cada funcionalidade (matérias, sessões, metas, trilhas,
  estatísticas) vira uma pasta com suas próprias camadas.
- O trio **entrada → processamento → saída** reaparece como **estado da tela**: os dados que chegam,
  a regra que os transforma e o que o usuário vê. É o assunto de
  [`08-estado-e-arquitetura/01-o-problema-do-estado.md`](../08-estado-e-arquitetura/01-o-problema-do-estado.md).
- O **teste de mesa** vira código executável em
  [`12-testes-e-debug/05-testes-unitarios.md`](../12-testes-e-debug/05-testes-unitarios.md): um
  teste unitário é um teste de mesa automatizado, com entrada conhecida e saída esperada.
- O cálculo de progresso da meta que você programa hoje é **a mesma regra** da tela de estatísticas
  do app `Foco`, especificada em
  [`projetos/03-projeto-final-multiplataforma/01-especificacao.md`](../../projetos/03-projeto-final-multiplataforma/01-especificacao.md).

Ou seja: a lógica que você escreve aqui em `print` vai, mais à frente, alimentar uma barra de
progresso na tela. A regra não muda; muda quem a exibe.

---

## 💻 Código completo

> **Arquivo:** `C:\src\pratica_dart\bin\aula03_media_estudo.dart`
> **Como executar:** `dart run bin/aula03_media_estudo.dart` (a partir de `C:\src\pratica_dart`)

```dart
// bin/aula03_media_estudo.dart
// Aula 3 — Algoritmos e decomposição.
//
// ALGORITMO (pseudocódigo):
// INÍCIO
//   RECEBER minutos de segunda a sexta e a meta diária
//   totalMinutos  <- soma dos cinco dias
//   mediaMinutos  <- totalMinutos / 5
//   totalHoras    <- totalMinutos / 60
//   metaSemanal   <- metaDiaria * 5
//   faltamMinutos <- metaSemanal - totalMinutos
//   percentual    <- (totalMinutos / metaSemanal) * 100
//   ESCREVER total, média, horas, meta, faltam e percentual
// FIM

void main() {
  // ---------- 1) ENTRADA ----------
  // Minutos estudados em cada dia útil da semana.
  const int segunda = 120;
  const int terca = 180;
  const int quarta = 90;
  const int quinta = 240;
  const int sexta = 60;

  // Meta que você se comprometeu a cumprir por dia útil.
  const int metaDiariaMinutos = 150;
  const int diasUteis = 5;

  // ---------- 2) PROCESSAMENTO ----------
  // Subproblema 2.1 — quanto eu estudei no total?
  final int totalMinutos = segunda + terca + quarta + quinta + sexta;

  // Subproblema 2.2 — qual foi a média por dia?
  final double mediaMinutos = totalMinutos / diasUteis;

  // Subproblema 2.3 — quanto isso dá em horas?
  final double totalHoras = totalMinutos / 60;

  // Subproblema 2.4 — qual era a meta da semana inteira?
  final int metaSemanalMinutos = metaDiariaMinutos * diasUteis;

  // Subproblema 2.5 — quanto falta para bater a meta?
  final int faltamMinutos = metaSemanalMinutos - totalMinutos;

  // Subproblema 2.6 — que percentual da meta eu cumpri?
  final double percentualDaMeta = (totalMinutos / metaSemanalMinutos) * 100;

  // ---------- 3) SAÍDA ----------
  print('===== RELATÓRIO DA SEMANA =====');
  print('Segunda: $segunda min');
  print('Terça:   $terca min');
  print('Quarta:  $quarta min');
  print('Quinta:  $quinta min');
  print('Sexta:   $sexta min');
  print('-------------------------------');
  print('Total estudado : $totalMinutos min');
  print('Média por dia  : ${mediaMinutos.toStringAsFixed(1)} min');
  print('Em horas       : ${totalHoras.toStringAsFixed(1)} h');
  print('-------------------------------');
  print('Meta semanal   : $metaSemanalMinutos min');
  print('Faltam         : $faltamMinutos min');
  print('Cumprido       : ${percentualDaMeta.toStringAsFixed(1)}%');
  print('===============================');
}
```

Saída esperada:

```text
===== RELATÓRIO DA SEMANA =====
Segunda: 120 min
Terça:   180 min
Quarta:  90 min
Quinta:  240 min
Sexta:   60 min
-------------------------------
Total estudado : 690 min
Média por dia  : 138.0 min
Em horas       : 11.5 h
-------------------------------
Meta semanal   : 750 min
Faltam         : 60 min
Cumprido       : 92.0%
===============================
```

---

## 🔍 Explicando o código

### O algoritmo aparece antes do código

Os comentários do topo não são enfeite: eles são **o algoritmo**, escrito antes. Escrever o
pseudocódigo primeiro e depois traduzi-lo linha a linha é o hábito que separa quem programa de
quem tenta adivinhar. Cada subproblema numerado vira **uma** linha de Dart.

### Linha a linha

| Linha | O que faz | Resultado com os dados da aula |
|---|---|---|
| `final int totalMinutos = segunda + ... + sexta;` | Soma os cinco dias. | `120+180+90+240+60 = 690` |
| `final double mediaMinutos = totalMinutos / diasUteis;` | Divide com `/`, que em Dart sempre devolve `double`. | `690 / 5 = 138.0` |
| `final double totalHoras = totalMinutos / 60;` | Converte minutos em horas. | `690 / 60 = 11.5` |
| `final int metaSemanalMinutos = metaDiariaMinutos * diasUteis;` | `int * int` devolve `int`. | `150 * 5 = 750` |
| `final int faltamMinutos = metaSemanalMinutos - totalMinutos;` | Subtração entre inteiros. | `750 - 690 = 60` |
| `final double percentualDaMeta = (totalMinutos / metaSemanalMinutos) * 100;` | Os parênteses garantem que a divisão ocorra **antes** da multiplicação. | `0.92 * 100 = 92.0` |
| `${mediaMinutos.toStringAsFixed(1)}` | Formata com 1 casa decimal. Sem isso, números com dízima apareceriam enormes. | `138.0` |

### Por que os parênteses em `(totalMinutos / metaSemanalMinutos) * 100`?

Porque `/` e `*` têm a **mesma precedência** e são avaliados da esquerda para a direita. Sem
parênteses, `totalMinutos / metaSemanalMinutos * 100` daria o mesmo resultado neste caso — mas
escrever os parênteses deixa a intenção explícita e evita que uma edição futura quebre a conta.
Precedência de operadores é o assunto da [Aula 6](06-operadores.md).

### Teste de mesa deste programa

Faça antes de rodar. A tabela completa:

| Passo | Variável | Cálculo | Valor |
|---|---|---|---|
| 1 | `totalMinutos` | `120+180+90+240+60` | `690` |
| 2 | `mediaMinutos` | `690 / 5` | `138.0` |
| 3 | `totalHoras` | `690 / 60` | `11.5` |
| 4 | `metaSemanalMinutos` | `150 * 5` | `750` |
| 5 | `faltamMinutos` | `750 - 690` | `60` |
| 6 | `percentualDaMeta` | `(690 / 750) * 100` | `92.0` |

Se o seu papel bate com o terminal, você não "rodou um exemplo": você **previu o comportamento de
um programa**. É essa a habilidade que o módulo inteiro treina.

### Um defeito proposital para você notar

Se você estudar **mais** que a meta, `faltamMinutos` fica negativo e a saída vira
`Faltam: -50 min`, que não faz sentido em português. O programa não tem como decidir entre "faltam"
e "excedeu" porque **ainda não sabe decidir** — isso chega na [Aula 7](07-condicoes.md). Deixe o
defeito anotado; vamos consertá-lo lá.

---

## ⚠️ Erros comuns

**1. Começar a escrever código sem o algoritmo.**
Sintoma: você digita, apaga, digita de novo e a cada tentativa o arquivo fica mais confuso.
Correção: pare, abra um bloco de notas, escreva ENTRADA / PROCESSAMENTO / SAÍDA.

**2. Pular o teste de mesa por achar que "é rápido só rodar".**
Rodar mostra **o que** saiu; o teste de mesa mostra **por que**. Programas errados executam sem
reclamar nada; só o seu raciocínio pega esse tipo de erro.

**3. Achar que `690 / 5` é `int`.**
Em Dart, `/` **sempre** produz `double`. Escrever `final int media = 690 / 5;` não compila:

```text
Error: A value of type 'double' can't be assigned to a variable of type 'int'.
```

Para divisão inteira existe `~/`, na [Aula 6](06-operadores.md).

**4. Decompor demais ou de menos.**
De menos: um único passo gigante que você não sabe começar. Demais: vinte passos triviais que
escondem a lógica. Use o critério das três perguntas da seção 4.

**5. Ordem trocada no algoritmo.**
Calcular o percentual antes de somar o total produz um resultado sem sentido. Em Dart, usar uma
variável antes de declará-la nem compila — o que, nesse caso, é uma boa notícia.

**6. Pseudocódigo virar entrega.**
Pseudocódigo não roda, não é testável e não vai para o repositório como solução. É rascunho de
pensamento, e só.

**7. Confundir média com total.**
"Estudei 690 minutos" e "estudei em média 138 minutos por dia" descrevem a mesma semana e
respondem a perguntas diferentes. Nomeie as variáveis de forma que a confusão seja impossível.

---

## 🛠️ Exercício guiado

Vamos decompor e resolver um problema novo: **quanto tempo falta para terminar o curso?**

**Passo 1 — Escreva o EPS** (antes de qualquer código):

```text
ENTRADA: total de horas do curso (120), horas já estudadas, horas por dia
PROCESSAMENTO: horas restantes; dias restantes; percentual concluído
SAÍDA: três linhas de relatório
```

**Passo 2 — Escreva o pseudocódigo:**

```text
INÍCIO
  RECEBER horasTotais, horasFeitas, horasPorDia
  horasRestantes  <- horasTotais - horasFeitas
  diasRestantes   <- horasRestantes / horasPorDia
  percentual      <- (horasFeitas / horasTotais) * 100
  ESCREVER horasRestantes, diasRestantes, percentual
FIM
```

**Passo 3 — Faça o teste de mesa** com `horasTotais = 120`, `horasFeitas = 18`,
`horasPorDia = 4`:

| Variável | Cálculo | Valor |
|---|---|---|
| `horasRestantes` | `120 - 18` | `102` |
| `diasRestantes` | `102 / 4` | `25.5` |
| `percentual` | `(18 / 120) * 100` | `15.0` |

**Passo 4 — Traduza para Dart** em `bin/aula03_guiado.dart`:

```dart
void main() {
  const int horasTotais = 120;
  const int horasFeitas = 18;
  const int horasPorDia = 4;

  final int horasRestantes = horasTotais - horasFeitas;
  final double diasRestantes = horasRestantes / horasPorDia;
  final double percentual = (horasFeitas / horasTotais) * 100;

  print('Faltam $horasRestantes h de curso.');
  print('No seu ritmo: ${diasRestantes.toStringAsFixed(1)} dias.');
  print('Você concluiu ${percentual.toStringAsFixed(1)}% do curso.');
}
```

**Passo 5 — Execute:**

```powershell
dart run bin/aula03_guiado.dart
```

```text
Faltam 102 h de curso.
No seu ritmo: 25.5 dias.
Você concluiu 15.0% do curso.
```

**Passo 6 — Confira:** o terminal bateu com o seu papel? Se sim, repita o processo mudando
`horasFeitas` para `60` e **preveja** a saída antes de rodar (deve dar `60 h`, `15.0 dias`,
`50.0%`).

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/01-logica-e-fundamentos.md](../../exercicios/01-logica-e-fundamentos.md)

Concentre-se nos exercícios de **Aplicação** (escrever o algoritmo antes do código) e de **Leitura
de código** (prever a saída sem executar) — os dois treinam exatamente o que esta aula ensinou.

---

## 🏆 Desafio opcional

Em `bin/aula03_desafio.dart`, escreva o algoritmo e o programa de um **conversor de tempo de
estudo** que, a partir de um total em minutos, mostre:

1. quantas horas inteiras e quantos minutos sobram (ex.: `690 min = 11 h e 30 min`);
2. quantas sessões de 25 minutos cabem nesse total;
3. quantos minutos sobram fora das sessões de 25 minutos.

Regras:

- Escreva o pseudocódigo em comentários **antes** do código.
- Faça o teste de mesa em papel para `690` e para `100`.
- Você ainda não viu os operadores `~/` (divisão inteira) e `%` (resto). Resolva **por enquanto**
  com as constantes que quiser e comentários explicando o raciocínio; depois da
  [Aula 6](06-operadores.md), volte e reescreva o programa usando `~/` e `%`. Compare as duas
  versões: essa comparação é o desafio de verdade.

---

## 📌 Resumo

- **Algoritmo** é uma sequência finita, ordenada e não ambígua de passos que transforma entrada em
  saída. Existe fora da programação.
- Todo problema se organiza em **entrada → processamento → saída**. Escreva esse trio antes de
  qualquer linha de código.
- **Pseudocódigo** é o algoritmo em português estruturado; serve para pensar sem brigar com
  sintaxe, e nunca é a entrega final.
- **Decompor** é quebrar o problema grande em subproblemas que cabem em uma frase, com entrada e
  saída claras e forma óbvia de testar.
- **Teste de mesa** é executar o algoritmo em papel, anotando cada variável. É o que distingue um
  erro de código de um erro de raciocínio.
- Em Dart, `/` sempre devolve `double`; `toStringAsFixed(n)` formata a saída com `n` casas.
- Um programa sem decisão não consegue dizer "faltam" ou "excedeu" — e é por isso que existe a
  próxima metade do módulo.

---

## ☑️ Checklist de domínio

- [x] Defino algoritmo usando as três palavras: finito, ordenado, não ambíguo.
- [x] Dou um exemplo de algoritmo que não é programa de computador.
- [x] Escrevo ENTRADA / PROCESSAMENTO / SAÍDA para um problema novo em menos de 2 minutos.
- [x] Escrevo pseudocódigo com `<-`, `RECEBER` e `ESCREVER`.
- [x] Decomponho um problema grande em subproblemas e sei dizer quando parar de decompor.
- [x] Faço teste de mesa em tabela e acerto a saída antes de executar.
- [x] Explico por que `690 / 5` não pode ser guardado em uma variável `int`.
- [x] Executei `bin/aula03_media_estudo.dart` e o resultado bateu com o meu papel.

---

## 📚 Referências oficiais

- [Dart — Visão geral da linguagem](https://dart.dev/language)
- [Dart — Variáveis](https://dart.dev/language/variables)
- [Dart — Operadores aritméticos](https://dart.dev/language/operators)
- [Dart — `num.toStringAsFixed`](https://api.dart.dev/stable/dart-core/num/toStringAsFixed.html)
- [Flutter — Documentação oficial](https://docs.flutter.dev/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Dart e Flutter](02-dart-e-flutter.md) | [README](README.md) | [Aula 4 — Variáveis e constantes](04-variaveis-e-constantes.md) |
