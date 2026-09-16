# Aula 1 — O que é programar

> **Módulo:** 01 - Lógica e Fundamentos · **Tempo estimado:** 35 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Explicar o que é **código-fonte** e por que ele é apenas texto.
- Definir **linguagem de programação** e por que ela existe.
- Diferenciar **compilador** e **interpretador**, com exemplos reais.
- Explicar **AOT** e **JIT** e dizer qual o Dart usa em cada momento.
- Explicar o que é **bytecode** e **código de máquina**.
- Definir **programa**, **processo** e **execução**.
- Identificar o papel de **SDK**, **IDE**, **terminal**, **emulador** e **simulador**.
- Escrever, executar e alterar o seu primeiro programa Dart de terminal.

## ✅ Pré-requisitos

- Ter feito o [Módulo 00 — Git e Terminal](../00-git-e-terminal/README.md), em especial
  [`01-o-terminal-sem-medo.md`](../00-git-e-terminal/01-o-terminal-sem-medo.md).
- Ter o Flutter 3.47.1 / Dart 3.13.1 instalados conforme
  [`02-configuracao-do-ambiente.md`](../../02-configuracao-do-ambiente.md).
- Ter criado o projeto de prática `C:\src\pratica_dart` descrito no
  [README do módulo](README.md).

---

## 📖 Conceito

### 1. Código-fonte é texto. Só isso.

**Código-fonte** é o texto que você escreve seguindo as regras de uma linguagem de programação.
Ele fica em um arquivo comum, que você poderia abrir no Bloco de Notas. Um arquivo Dart termina
em `.dart`; um arquivo Python termina em `.py`; um arquivo Java termina em `.java`.

O computador **não entende** esse texto. O processador (a peça física que executa contas dentro da
sua máquina) só entende **código de máquina**: sequências de números que representam instruções
elementares como "some estes dois valores" ou "guarde este número nesta posição de memória".

Programar, então, é: escrever texto que alguma ferramenta consiga traduzir para código de máquina.

### 2. Linguagem de programação

Uma **linguagem de programação** é um conjunto de regras de escrita (a *sintaxe*) e de significado
(a *semântica*) criado para que seres humanos consigam descrever instruções com precisão
suficiente para uma máquina executar.

Por que não escrever direto em português? Porque português é ambíguo. "Some os três primeiros
valores" — os três primeiros de qual lista, contando a partir de qual posição, e se a lista tiver
só dois? Linguagem de programação existe para eliminar toda ambiguidade: só há uma leitura
possível para cada linha.

### 3. Compilador × interpretador

Existem duas estratégias clássicas para transformar código-fonte em execução.

**Compilador** é um programa que lê **todo** o seu código-fonte antes de executar qualquer coisa e
produz, como saída, um arquivo executável em código de máquina. Depois disso, o programa roda
sozinho, sem precisar do compilador.

- Vantagem: execução rápida, porque a tradução já foi feita.
- Vantagem: erros de escrita são descobertos **antes** de o programa rodar.
- Desvantagem: cada alteração exige compilar de novo, o que leva tempo.

**Interpretador** é um programa que lê o seu código-fonte e executa instrução por instrução, na
hora, sem gerar um executável separado.

- Vantagem: alterar e testar é quase imediato.
- Desvantagem: execução mais lenta, porque a tradução acontece durante a execução.
- Desvantagem: muitos erros só aparecem quando aquela linha específica é alcançada.

> **Cuidado com uma confusão comum:** "compilada" e "interpretada" não são propriedades da
> linguagem, e sim do **modo de execução**. A mesma linguagem pode ter um compilador e um
> interpretador. É exatamente o caso do Dart.

### 4. JIT e AOT — as duas engrenagens do Dart

O Dart não escolhe um lado: ele usa os dois, em momentos diferentes.

**JIT** (*Just In Time* — "bem na hora") compila o código durante a execução, enquanto o programa
já está rodando. Isso permite **trocar pedaços do programa sem reiniciá-lo**. É o que sustenta o
*hot reload* do Flutter: você altera uma cor, salva, e a tela muda em menos de um segundo, sem
perder o estado do aplicativo.

**AOT** (*Ahead Of Time* — "antes da hora") compila tudo antes, gerando código de máquina nativo
da plataforma-alvo (ARM no celular, x64 no computador). É o modo usado quando você gera o app
final que vai para a loja: sem compilador embarcado, sem tradução durante a execução, partida
mais rápida e desempenho previsível.

| Situação | Modo | Consequência prática |
|---|---|---|
| `flutter run` no celular/emulador durante o desenvolvimento | JIT | *hot reload*, ciclo de segundos |
| `flutter build apk --release` / `flutter build ipa` | AOT | app rápido, sem *hot reload* |
| `dart run bin/arquivo.dart` no terminal | JIT | roda direto do fonte |
| `dart compile exe` | AOT | gera um executável independente |

Esse desenho é uma das razões técnicas de o Flutter existir: JIT para o desenvolvedor produzir
rápido, AOT para o usuário final receber um app rápido.

### 5. Bytecode

**Bytecode** é um formato intermediário: não é o seu texto, mas também não é código de máquina do
processador. É um conjunto de instruções compactas feito para ser executado por uma **máquina
virtual** (um programa que finge ser um computador).

O exemplo mais conhecido é o Java: o compilador `javac` gera bytecode `.class`, e a JVM (*Java
Virtual Machine*) executa esse bytecode. É por isso que o mesmo `.jar` roda em Windows, Linux e
macOS — cada sistema tem a sua JVM.

E o Dart? O Dart tem uma **VM** (*Virtual Machine*, máquina virtual) própria que executa seu código
com JIT durante o desenvolvimento, e tem o compilador AOT que **elimina** a etapa intermediária na
hora de publicar, gerando código de máquina nativo. É por isso que um app Flutter em release não
carrega uma máquina virtual pesada junto.

### 6. Programa, processo e execução

- **Programa**: o conjunto de instruções, parado, gravado no disco. Um substantivo.
- **Execução**: o ato de a máquina percorrer essas instruções.
- **Processo**: o programa **em execução**, com memória própria, ocupando espaço na RAM. Se você
  abre a mesma calculadora duas vezes, há um programa e dois processos.

Quando você digita `dart run bin/aula01_ola.dart`, o sistema cria um processo, o Dart lê seu
arquivo, compila com JIT e executa. Ao terminar, o processo morre e a memória é devolvida.

### 7. As ferramentas que você vai usar todos os dias

**SDK** (*Software Development Kit* — kit de desenvolvimento de software) é o pacote de
ferramentas que você instala para poder programar em uma tecnologia. O **Flutter SDK 3.47.1** que
você instalou já traz dentro dele o **Dart SDK 3.13.1** — por isso o comando `dart` funciona no
seu terminal mesmo você nunca tendo instalado o Dart separadamente.

**IDE** (*Integrated Development Environment* — ambiente de desenvolvimento integrado) é o
programa onde você escreve código com ajuda: destaque de cores, autocompletar, sublinhado vermelho
no erro, atalho para rodar. Neste curso usamos o **VS Code**. IDE não é obrigatória — você poderia
usar o Bloco de Notas — mas ela reduz drasticamente o tempo perdido com erros de digitação.

**Terminal** é a janela onde você digita comandos em texto, um por linha, e o sistema responde em
texto. No Windows 11 o padrão é o **PowerShell**. Todo comando deste curso marcado com 🪟 é
PowerShell.

**Emulador** é um programa que **imita um aparelho Android inteiro** dentro do seu computador,
inclusive o processador ARM. Como ele traduz instruções de um processador para outro, é mais
pesado. É o que você usará no módulo 14 para testar o app Android.

**Simulador** é o termo da Apple para o programa que **roda o iOS no próprio processador do Mac**,
sem imitar o hardware do iPhone. É mais leve, mas só existe no macOS.

> 🪟 **Atenção, Windows.** Emulador Android: sim, você vai usar. Simulador iOS: **não existe para
> Windows**. Isso é limitação da Apple, não do Flutter, e está explicado em
> [`15-build-ios/01-por-que-exige-macos.md`](../15-build-ios/01-por-que-exige-macos.md).

---

## 💡 Analogia

Pense em uma receita de bolo escrita em francês, e um cozinheiro que só fala português.

- O **compilador** é o tradutor que pega a receita inteira, traduz para o português num caderno
  novo e entrega o caderno. O cozinheiro cozinha sozinho, rápido, sem o tradutor por perto. Se a
  receita tiver um erro de francês, o tradutor descobre antes de alguém acender o fogão.
- O **interpretador** é o tradutor que fica ao lado do fogão traduzindo frase por frase. Começa na
  hora, mas é mais lento — e um erro na última frase só aparece quando o bolo já está no forno.
- O **JIT** é o tradutor ao lado do fogão que, ao perceber que você faz a mesma receita toda
  semana, guarda a tradução pronta para a próxima vez.
- O **AOT** é o caderno traduzido, revisado e impresso que você manda para mil cozinhas.

A analogia para quando você imaginar o processador "lendo" a receita: ele não lê. Ele executa
mecanicamente um passo por vez, sem entender o bolo.

---

## 🧪 Exemplo mínimo

Crie o arquivo `C:\src\pratica_dart\bin\aula01_minimo.dart` com exatamente isto:

```dart
void main() {
  print('Meu primeiro programa do curso.');
}
```

E execute a partir de `C:\src\pratica_dart`:

```powershell
dart run bin/aula01_minimo.dart
```

Saída:

```text
Meu primeiro programa do curso.
```

Três coisas aconteceram: o Dart leu o texto, compilou com JIT, executou. `main` é o ponto de
entrada — a função por onde todo programa Dart começa. `void` significa que ela não devolve valor
nenhum. `print` escreve uma linha no terminal.

> ℹ️ Em código **Flutter** o `print()` dispara o aviso de análise `avoid_print` e o correto é
> `debugPrint()`. Nos módulos 01 a 04, que são Dart puro de terminal, `print()` é a ferramenta
> adequada — a saída do terminal é justamente o objetivo do programa.

---

## 📱 Aplicando no Flutter

Nada do que você leu aqui é teoria descartável — cada item volta em forma concreta:

- **JIT × AOT** é literalmente o botão que você mais vai usar. Em
  [`05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md`](../05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md)
  você vai ver que *hot reload* só existe porque o app em desenvolvimento roda em JIT, e que ele
  **desaparece** no build de release, que é AOT.
- **Compilação AOT** é o que produz o arquivo que vai para a loja, em
  [`14-build-android/08-gerando-apk-e-aab.md`](../14-build-android/08-gerando-apk-e-aab.md) e em
  [`15-build-ios/08-build-ipa-e-archive.md`](../15-build-ios/08-build-ipa-e-archive.md).
- **`void main()`** não muda: o `main` de um app Flutter é a mesma função, só que em vez de
  `print` ela chama `runApp()`. Você verá isso em
  [`05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md`](../05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md).
- **Emulador e simulador** aparecem no fluxo de teste em
  [`12-testes-e-debug/09-depurando-android-e-ios.md`](../12-testes-e-debug/09-depurando-android-e-ios.md).
- **Erros de compilação** (encontrados antes de rodar) são a base da análise estática que você vai
  configurar em [`04-dart-avancado/07-analise-estatica-e-lints.md`](../04-dart-avancado/07-analise-estatica-e-lints.md).

Em uma frase: o Flutter é agradável de usar no dia a dia porque o Dart aceita ser interpretado
rapidinho enquanto você trabalha, e compilado a sério quando o usuário baixa o app.

---

## 💻 Código completo

> **Arquivo:** `C:\src\pratica_dart\bin\aula01_ola.dart`
> **Como executar:** `dart run bin/aula01_ola.dart` (a partir da pasta `C:\src\pratica_dart`)

```dart
// bin/aula01_ola.dart
// Aula 1 — O que é programar.
// Objetivo: ver um programa inteiro, do início ao fim, e entender cada linha.

void main() {
  // 1) ENTRADA: dados fixos do seu plano de estudo.
  const String nomeDoCurso = 'Curso Flutter Intensivo';
  const int minutosPorDia = 240;
  const int diasDoPlano = 30;

  // 2) PROCESSAMENTO: contas feitas a partir dos dados de entrada.
  final int minutosTotais = minutosPorDia * diasDoPlano;
  final double horasTotais = minutosTotais / 60;

  // 3) SAÍDA: o que o programa mostra no terminal.
  print('=============================================');
  print('Bem-vindo ao $nomeDoCurso!');
  print('=============================================');
  print('Plano: $diasDoPlano dias de estudo.');
  print('Carga diária: $minutosPorDia minutos.');
  print('Total em minutos: $minutosTotais');
  print('Total em horas: ${horasTotais.toStringAsFixed(1)}');
  print('---------------------------------------------');
  print('Este texto foi escrito por você, traduzido');
  print('pelo Dart e executado pelo seu processador.');
}
```

Saída esperada:

```text
=============================================
Bem-vindo ao Curso Flutter Intensivo!
=============================================
Plano: 30 dias de estudo.
Carga diária: 240 minutos.
Total em minutos: 7200
Total em horas: 120.0
---------------------------------------------
Este texto foi escrito por você, traduzido
pelo Dart e executado pelo seu processador.
```

---

## 🔍 Explicando o código

| Trecho | O que é | Por que está aí |
|---|---|---|
| `// bin/aula01_ola.dart` | **Comentário**: texto ignorado pelo Dart, escrito para humanos. Começa com `//` e vale até o fim da linha. | Identificar o arquivo dentro do próprio arquivo |
| `void main() { ... }` | A função de entrada. `void` = não devolve nada. `()` = não recebe nada. `{ }` delimitam o corpo. | Todo programa Dart começa por `main` |
| `const String nomeDoCurso = '...'` | **Constante**: valor que nunca muda, conhecido já na compilação. `String` é o tipo "texto". | O nome do curso não muda durante a execução |
| `const int minutosPorDia = 240` | `int` é o tipo "número inteiro" (sem casas decimais). | 240 minutos = 4 horas por dia |
| `final int minutosTotais = ...` | **`final`**: recebe valor uma única vez, mas o valor é calculado durante a execução. | O resultado depende de uma conta, então não é `const` |
| `minutosPorDia * diasDoPlano` | Multiplicação. `240 * 30 = 7200`. | Processamento |
| `minutosTotais / 60` | Divisão com `/`. Em Dart, `/` **sempre** produz `double` (número com casas decimais), por isso a variável é `double`. | 7200 / 60 = 120.0 |
| `'... $nomeDoCurso ...'` | **Interpolação de string**: o `$` seguido do nome de uma variável insere o valor dela dentro do texto. | Evita concatenar com `+` |
| `${horasTotais.toStringAsFixed(1)}` | Quando você precisa de uma **expressão** (não só um nome), use `${...}`. `toStringAsFixed(1)` transforma o número em texto com 1 casa decimal. | Mostrar `120.0` em vez de um número longo |
| `print(...)` | Escreve uma linha no terminal e pula para a próxima. | Saída |
| `;` no fim de cada instrução | O ponto e vírgula marca o fim de uma instrução. | Sem ele, o Dart não compila |

### A ordem importa

O Dart executa `main` de cima para baixo, uma instrução por vez. Se você mover a linha do `print`
do total para **antes** do cálculo de `minutosTotais`, o programa nem compila: você estaria usando
uma variável que ainda não existe naquele ponto. Essa ideia de "linha por linha, de cima para
baixo" é a base de tudo até a Aula 8.

---

## 🤖🍎 Android × iOS

Nesta aula você roda tudo no seu computador, então as plataformas móveis ainda não entram. Mas
vale registrar desde já a diferença que mais afeta você:

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onde você testa | **Emulador** Android (roda no Windows) ou celular físico via cabo | **Simulador** iOS (só no macOS) ou iPhone físico pareado a um Mac |
| Compilação AOT gera | código de máquina ARM dentro de um `.apk`/`.aab` | código de máquina ARM dentro de um `.ipa` |
| Dá para fazer no seu Windows 11? | Sim, do começo ao fim | Não: a Apple exige macOS + Xcode |

> 🍎 **SÓ NO MAC.** Gerar um app iOS instalável exige macOS + Xcode. No Windows você pode ler e
> entender o processo inteiro, mas não executá-lo. O curso trata disso com honestidade em
> [`15-build-ios/01-por-que-exige-macos.md`](../15-build-ios/01-por-que-exige-macos.md).

---

## ⚠️ Erros comuns

**1. Esquecer o ponto e vírgula**

```dart
print('Olá')
print('Mundo');
```

Mensagem do Dart (erro de **compilação** — o programa nem chega a rodar):

```text
Error: Expected ';' after this.
```

Correção: termine toda instrução com `;`.

**2. Aspas trocadas ou não fechadas**

```dart
print('Olá");
```

O Dart reclama de string não terminada. Em Dart, `'texto'` e `"texto"` são equivalentes, mas você
precisa **fechar com a mesma aspa que abriu**. Convenção do curso e do `flutter_lints`: use aspas
simples.

**3. `Main` com M maiúsculo**

```dart
void Main() {
  print('nada acontece');
}
```

O Dart diferencia maiúsculas de minúsculas. `Main` não é `main`, então não existe ponto de entrada
e a execução falha com uma mensagem sobre não encontrar a função `main`.

**4. Rodar o comando na pasta errada**

```powershell
dart run bin/aula01_ola.dart
```

Se você estiver em `C:\src` e não em `C:\src\pratica_dart`, o Dart não encontra o arquivo. Confira
onde você está com `pwd` e entre na pasta certa com `cd C:\src\pratica_dart`.

**5. Confundir `/` com `~/`**

`7200 / 60` resulta em `120.0` (um `double`). Se você declarar `final int horas = minutosTotais / 60;`
o Dart recusa, porque `/` não devolve `int`. A divisão inteira tem operador próprio, `~/`, e você
a estuda na [Aula 6](06-operadores.md).

**6. Achar que o `//` some do programa**

Comentários existem apenas no arquivo-fonte. Eles não vão para o código compilado e não custam
desempenho nenhum. Comente tudo o que você precisar para entender.

---

## 🛠️ Exercício guiado

Vamos alterar o programa juntos, passo a passo, para você sentir o ciclo escrever → executar → ler.

**Passo 1.** Abra o VS Code na pasta do projeto:

```powershell
cd C:\src\pratica_dart
code .
```

**Passo 2.** Abra `bin/aula01_ola.dart`.

**Passo 3.** Troque a carga diária de 240 para 180 minutos:

```dart
const int minutosPorDia = 180;
```

**Passo 4.** Salve (Ctrl+S) e execute:

```powershell
dart run bin/aula01_ola.dart
```

Agora a saída mostra `Total em minutos: 5400` e `Total em horas: 90.0`. Você mudou **uma**
constante e as duas linhas seguintes mudaram sozinhas — isso é processamento a partir da entrada,
e não texto fixo.

**Passo 5.** Acrescente, antes do último `print`, uma linha que mostre quantas horas você estuda
por semana considerando 5 dias úteis:

```dart
final double horasPorSemana = (minutosPorDia * 5) / 60;
print('Horas por semana (5 dias): ${horasPorSemana.toStringAsFixed(1)}');
```

**Passo 6.** Execute de novo. Com 180 minutos por dia, a saída deve ser `15.0`.

**Passo 7.** Agora **provoque um erro de propósito**: apague o `;` do fim dessa nova linha e
execute. Leia a mensagem inteira, identifique o número da linha e conserte. Ser capaz de ler esse
texto é metade do trabalho de programar — e é o tema completo da
[Aula 10](10-lendo-mensagens-de-erro.md).

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/01-logica-e-fundamentos.md](../../exercicios/01-logica-e-fundamentos.md)

Comece pelos exercícios da seção **1. Fixação**, que cobrem exatamente os conceitos desta aula:
vocabulário (compilador, interpretador, JIT, AOT, SDK, IDE) e o ciclo escrever → executar → ler.

---

## 🏆 Desafio opcional

Escreva `C:\src\pratica_dart\bin\aula01_desafio.dart` que mostre um "cartão de identidade" do seu
ambiente de desenvolvimento, com estas informações em constantes:

- versão do Flutter (`3.47.1`);
- versão do Dart (`3.13.1`);
- seu sistema operacional;
- a pasta onde você guarda os projetos.

E, no fim, uma linha calculada: quantos **dias** faltam para o fim do plano de 30 dias, supondo que
você está no dia 2. Use uma constante `diaAtual` e uma subtração.

Depois execute `dart --version` no terminal e compare com o que você escreveu. Se não bater,
corrija o arquivo — nunca o contrário.

---

## 📌 Resumo

- **Código-fonte** é texto; o processador só entende **código de máquina**. Programar é escrever
  texto traduzível.
- **Compilador** traduz tudo antes e gera executável; **interpretador** traduz e executa na hora.
- O Dart usa **JIT** durante o desenvolvimento (permitindo *hot reload*) e **AOT** no app final
  (dando desempenho e partida rápida).
- **Bytecode** é um formato intermediário executado por uma máquina virtual; o AOT do Dart dispensa
  essa camada no app publicado.
- **Programa** é o arquivo parado; **processo** é o programa em execução.
- **SDK** é o kit de ferramentas (o Flutter SDK traz o Dart SDK dentro); **IDE** é o editor
  inteligente (VS Code); **terminal** é onde você digita comandos (PowerShell no Windows).
- **Emulador** imita um aparelho Android inteiro; **simulador** roda o iOS no processador do Mac —
  e só existe no macOS.
- Todo programa Dart começa em `void main()`, executa de cima para baixo e termina toda instrução
  com `;`.

---

## ☑️ Checklist de domínio

- [x] Explico o que é código-fonte sem usar a palavra "código".
- [x] Digo em uma frase a diferença entre compilador e interpretador.
- [x] Digo qual modo (JIT ou AOT) o Flutter usa em `flutter run` e qual usa em
      `flutter build apk --release`, e por quê.
- [x] Explico o que é bytecode e dou um exemplo de tecnologia que o usa.
- [x] Diferencio programa, execução e processo.
- [x] Digo o que é SDK, IDE e terminal, e aponto qual eu uso para cada coisa.
- [x] Explico por que não existe simulador de iPhone no Windows.
- [x] Criei, executei e alterei `bin/aula01_ola.dart` com sucesso.
- [x] Provoquei um erro de propósito, li a mensagem e corrigi sozinho.

---

## 📚 Referências oficiais

- [Dart — Visão geral da linguagem](https://dart.dev/language)
- [Dart — Overview do SDK e ferramentas](https://dart.dev/tools)
- [Dart — Comando `dart run`](https://dart.dev/tools/dart-run)
- [Dart — Comando `dart compile` (AOT)](https://dart.dev/tools/dart-compile)
- [Flutter — Arquitetura geral (JIT, AOT e engine)](https://docs.flutter.dev/resources/architectural-overview)
- [Flutter — Hot reload](https://docs.flutter.dev/tools/hot-reload)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — Dart e Flutter](02-dart-e-flutter.md) |
