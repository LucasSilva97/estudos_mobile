# Aula 1 — Anatomia de um programa Dart

> **Módulo:** 02 - Dart Básico · **Tempo estimado:** 35 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Criar um projeto Dart do zero com o comando `dart create`.
- Nomear e localizar cada pasta e cada arquivo gerados: `bin/`, `lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml`.
- Explicar o que é a função `main` e por que ela é o **ponto de entrada** do programa.
- Receber argumentos da linha de comando dentro de `main`.
- Executar um programa com `dart run` e gerar um executável com `dart compile exe`.
- Diferenciar **interpretar/JIT** de **compilar/AOT** e saber quando cada um é usado.

## ✅ Pré-requisitos

- Dart 3.13.1 disponível no terminal (`dart --version` responde).
- Saber navegar entre pastas no terminal com `cd` e listar com `dir` — [Módulo 00](../00-git-e-terminal/README.md).
- Entender o conceito de função — [Módulo 01, Aula 9](../01-logica-e-fundamentos/09-funcoes.md).

## 📖 Conceito

Todo programa Dart, do menor script de terminal ao aplicativo Flutter mais complexo, tem
**exatamente um ponto de partida**: uma função chamada `main`.

> **Função** — um bloco de código com nome, que você pode executar quando quiser.
> **Ponto de entrada** (*entry point*) — a primeira linha que o computador executa quando o
> programa começa. Em Dart, sempre `main`.

Quando você digita `dart run bin/algo.dart`, o Dart faz três coisas, nesta ordem:

1. Lê o arquivo e verifica se ele é Dart válido (**análise**).
2. Procura uma função chamada `main` nele. Se não encontrar, recusa a rodar.
3. Executa `main` de cima para baixo. Quando `main` termina, o programa termina.

### O que é um "projeto Dart"

Você *pode* rodar um arquivo `.dart` solto. Mas assim que o programa passa de algumas dezenas
de linhas, ou precisa de um pacote externo, você quer um **projeto**: uma pasta com uma
estrutura padrão que as ferramentas do Dart reconhecem.

> **Pacote** (*package*) — um conjunto de código pronto que outra pessoa escreveu e publicou,
> e que você pode usar no seu projeto. O repositório oficial de pacotes Dart e Flutter é o
> [pub.dev](https://pub.dev).

O comando que cria esse projeto é:

```powershell
dart create dart_basico
```

Ele gera esta estrutura:

```text
dart_basico/
├── .gitignore              → o que o Git deve ignorar
├── CHANGELOG.md            → histórico de versões do seu projeto
├── README.md               → descrição do projeto
├── analysis_options.yaml   → regras de análise e estilo do código
├── pubspec.yaml            → identidade e dependências do projeto
├── bin/
│   └── dart_basico.dart    → programas executáveis (aqui mora o main)
├── lib/
│   └── dart_basico.dart    → código reaproveitável (a "biblioteca")
└── test/
    └── dart_basico_test.dart → testes automatizados
```

### Para que serve cada pasta

| Caminho | O que é | Você mexe? |
|---|---|---|
| `bin/` | Programas que **rodam**. Cada arquivo aqui pode ter seu próprio `main`. | Sim, o tempo todo neste módulo |
| `lib/` | Código que é **usado por outros arquivos** (funções, classes). Não roda sozinho. | A partir do módulo 03 |
| `test/` | Testes automatizados, executados com `dart test`. | A partir do módulo 12 |
| `pubspec.yaml` | O "RG" do projeto: nome, descrição, versão do Dart exigida, dependências. | Sim, para adicionar pacotes |
| `analysis_options.yaml` | Liga e desliga regras de análise estática (*lints*). | Raramente |
| `.gitignore` | Lista de arquivos que o Git não deve versionar. | Sim, para segredos |

> **Análise estática** — a ferramenta lê seu código **sem executá-lo** e aponta problemas.
> É o sublinhado vermelho ou amarelo que aparece no VS Code enquanto você digita.
> **Lint** — cada regra individual dessa análise (ex.: "não use `print` em código de produção").

### O conteúdo do `pubspec.yaml`

```yaml
name: dart_basico
description: Projeto de linha de comando para praticar Dart.
version: 1.0.0

environment:
  sdk: ^3.13.0
```

- `name` — precisa estar em `snake_case` (minúsculas com sublinhado). É o nome do pacote.
- `description` — texto livre.
- `version` — versão do **seu** projeto, não do Dart.
- `environment: sdk: ^3.13.0` — a faixa de versões do Dart que este projeto aceita.
  O acento circunflexo `^` significa "3.13.0 ou qualquer versão maior **dentro da major 3**".
  Como o seu Dart é o 3.13.1, ele está dentro da faixa.

Logo abaixo, o `dart create` também escreveu um bloco `dev_dependencies` com os pacotes `lints`
(regras de estilo) e `test` (ferramenta de testes). As versões ali foram resolvidas pelo próprio
comando, na sua máquina, no dia em que você rodou. **Abra o seu arquivo para ver os números
exatos e não copie versões de material de estudo** — elas envelhecem. Neste módulo você não
precisa alterar esse bloco.

### O `analysis_options.yaml`

```yaml
include: package:lints/recommended.yaml
```

Uma linha só: "aplique o conjunto de regras `recommended` do pacote `lints`". É por causa
dessa linha que o VS Code vai reclamar de coisas como variável declarada e não usada.

> ℹ️ Em projetos **Flutter** essa linha é diferente: `include: package:flutter_lints/flutter.yaml`.
> Você vai ver isso no [Módulo 05, Aula 2](../05-introducao-ao-flutter/02-estrutura-do-projeto.md).

### A assinatura da função `main`

Existem duas formas válidas e você vai usar as duas neste curso:

```dart
void main() { }                       // sem argumentos
void main(List<String> argumentos) { } // recebendo argumentos do terminal
```

- `void` — o **tipo de retorno**: "esta função não devolve valor nenhum".
- `main` — o nome obrigatório.
- `List<String>` — uma lista de textos. É onde chegam as palavras que você digitou no terminal
  depois do nome do arquivo.

Existe também `Future<void> main() async { }`, para programas que esperam operações demoradas.
Isso é assunto do [Módulo 04, Aula 2](../04-dart-avancado/02-futures-e-async-await.md).

## 💡 Analogia

Pense no projeto Dart como uma **cozinha profissional**:

- `bin/` é o **balcão de saída**: o que sai daqui é um prato pronto para o cliente (um programa que roda).
- `lib/` é a **despensa e a bancada de preparo**: ingredientes e receitas usados pelos pratos, mas
  que ninguém serve sozinhos.
- `test/` é a **degustação**: prova cada preparo antes de ir ao salão.
- `pubspec.yaml` é a **ficha técnica**: nome do restaurante e a lista de fornecedores (dependências).
- `main` é o **comando "iniciar o serviço"**. Sem ele, a cozinha está montada mas nada acontece.

## 🧪 Exemplo mínimo

```dart
void main() {
  print('Olá, Dart!');
}
```

Três elementos, e todos importam:

- `void main()` — a função de entrada.
- `{ ... }` — as **chaves** delimitam o corpo da função.
- `print('Olá, Dart!');` — chama a função `print`, que escreve no terminal, e termina com
  **ponto e vírgula**, obrigatório no fim de cada instrução.

Saída:

```text
Olá, Dart!
```

## 📱 Aplicando no Flutter

Um aplicativo Flutter é um programa Dart — com exatamente o mesmo `main` que você acabou de ver.
Abra qualquer app Flutter e o arquivo `lib/main.dart` começa assim:

```dart
void main() {
  runApp(const MeuApp());
}
```

A única diferença é o que está **dentro** do `main`: em vez de `print`, você chama `runApp`,
a função que entrega a árvore de telas para o Flutter desenhar.

Duas equivalências que valem guardar desde já:

| No projeto de terminal (aqui) | No projeto Flutter (módulo 05) |
|---|---|
| `bin/algo.dart` com `main` | `lib/main.dart` com `main` |
| `dart run bin/algo.dart` | `flutter run` |
| `analysis_options.yaml` com `package:lints` | `analysis_options.yaml` com `package:flutter_lints` |
| `dart compile exe` gera `.exe` | `flutter build apk` gera `.apk` |

A estrutura de pastas do Flutter é destrinchada em
[05 — Estrutura do projeto](../05-introducao-ao-flutter/02-estrutura-do-projeto.md), e o papel do
`main` + `runApp` em
[05 — main, runApp e a árvore de widgets](../05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md).
Quando chegar lá, você já não vai precisar aprender "o que é main" — só o que muda.

## 💻 Código completo

Um programa que se apresenta e usa o que foi digitado no terminal.

> **Arquivo:** `dart_basico/bin/saudacao.dart`
> **Como executar:** `dart run bin/saudacao.dart Lucas noite`

```dart
// bin/saudacao.dart
// Demonstra: função main, argumentos de linha de comando e saída no terminal.

void main(List<String> argumentos) {
  print('=== Saudação configurável ===');
  print('Quantidade de argumentos recebidos: ${argumentos.length}');

  if (argumentos.isEmpty) {
    print('');
    print('Você não passou nenhum argumento.');
    print('Uso: dart run bin/saudacao.dart <nome> [manha|tarde|noite]');
    return;
  }

  final String nome = argumentos[0];

  // Se o segundo argumento não veio, usamos 'dia' como valor padrão.
  final String periodo = argumentos.length >= 2 ? argumentos[1] : 'dia';

  final String cumprimento;
  if (periodo == 'manha') {
    cumprimento = 'Bom dia';
  } else if (periodo == 'tarde') {
    cumprimento = 'Boa tarde';
  } else if (periodo == 'noite') {
    cumprimento = 'Boa noite';
  } else {
    cumprimento = 'Olá';
  }

  print('');
  print('$cumprimento, $nome!');
  print('Este programa rodou a partir da função main de bin/saudacao.dart.');

  // Mostra todos os argumentos numerados, um por linha.
  print('');
  print('Argumentos, um a um:');
  for (int i = 0; i < argumentos.length; i++) {
    print('  [$i] ${argumentos[i]}');
  }
}
```

Saída esperada para `dart run bin/saudacao.dart Lucas noite`:

```text
=== Saudação configurável ===
Quantidade de argumentos recebidos: 2

Boa noite, Lucas!
Este programa rodou a partir da função main de bin/saudacao.dart.

Argumentos, um a um:
  [0] Lucas
  [1] noite
```

Saída esperada para `dart run bin/saudacao.dart` (sem argumentos):

```text
=== Saudação configurável ===
Quantidade de argumentos recebidos: 0

Você não passou nenhum argumento.
Uso: dart run bin/saudacao.dart <nome> [manha|tarde|noite]
```

## 🔍 Explicando o código

**`void main(List<String> argumentos)`**
Declara o ponto de entrada recebendo a lista de argumentos. O nome do parâmetro é livre — a
convenção em inglês é `args`; aqui usamos `argumentos` porque o curso escreve identificadores em
português. O **tipo** é que importa: `List<String>`.

**`argumentos.length`**
`length` é uma propriedade de toda lista: quantos elementos ela tem. Se você rodar sem
argumentos, vale `0`.

**`'... ${argumentos.length}'`**
Isso é **interpolação de string**: dentro de um texto, `${...}` é substituído pelo resultado da
expressão. Quando é só o nome de uma variável, você pode escrever a forma curta `$nome`.
Detalhado na [Aula 4](04-tipos-strings-conversoes.md).

**`if (argumentos.isEmpty) { ... return; }`**
`isEmpty` devolve `true` quando a lista não tem elementos. O `return` dentro de uma função
`void` significa "pare aqui": nada depois dele executa. Esse padrão — verificar o caso
inválido e sair cedo — chama-se *early return* e deixa o código mais plano, sem `else` aninhado.

**`final String nome = argumentos[0];`**
`final` significa "depois de atribuído, não muda mais". `argumentos[0]` acessa o **primeiro**
elemento: em Dart, como em Java e Python, listas começam no índice **0**.
`final` × `var` × `const` é o tema inteiro da [Aula 3](03-var-final-const.md).

**`argumentos.length >= 2 ? argumentos[1] : 'dia'`**
Este é o **operador condicional ternário**: `condição ? valorSeVerdadeiro : valorSeFalso`.
Ele é uma *expressão* (produz um valor), diferente de um `if`, que é uma *instrução*.
Sem a verificação `>= 2`, acessar `argumentos[1]` com um argumento só lançaria
`RangeError` em tempo de execução.

**`final String cumprimento;` seguido de atribuição nos `if`**
Você pode declarar uma variável `final` **sem valor** e atribuir depois, desde que o
compilador consiga provar que ela recebe valor **exatamente uma vez** em todos os caminhos.
Como há um `else` final, todos os caminhos atribuem. Se você apagasse o `else`, o Dart
recusaria a compilar — e essa recusa é uma proteção, não um obstáculo.

**`for (int i = 0; i < argumentos.length; i++)`**
Laço clássico com índice. `i++` soma 1 a `i`. Formas melhores de percorrer listas
(`for-in`, `map`, `asMap`) aparecem nas aulas [6](06-controle-de-fluxo.md) e [8](08-listas.md).

### Rodando e compilando

**Rodar (modo de desenvolvimento):**

```powershell
cd dart_basico
dart run bin/saudacao.dart Lucas noite
```

`dart run` usa **JIT** (*Just-In-Time* — compilação no momento da execução). É rápido para
iniciar e permite ferramentas de depuração, mas depende do SDK do Dart instalado na máquina.

**Compilar para um executável nativo:**

```powershell
dart compile exe bin/saudacao.dart -o saudacao.exe
```

```text
Generated: C:\...\dart_basico\saudacao.exe
```

Agora:

```powershell
.\saudacao.exe Lucas noite
```

`dart compile exe` usa **AOT** (*Ahead-Of-Time* — compilação antes da execução). O `.exe`
gerado roda em máquinas **sem Dart instalado**, inicia mais rápido, mas é grande (dezenas de MB,
porque carrega o runtime junto) e só serve para o sistema operacional em que foi gerado: um
`.exe` compilado no Windows não roda no macOS.

> 🪟 No Windows o arquivo precisa da extensão `.exe` e é chamado com `.\` na frente, porque o
> PowerShell não procura executáveis na pasta atual por padrão.

Essa dupla JIT/AOT é exatamente a razão de existir o **Hot Reload** do Flutter: em
desenvolvimento o Flutter usa JIT (e por isso consegue trocar o código com o app rodando); na
versão que vai para a loja usa AOT. Tema de
[05 — Hot Reload e Hot Restart](../05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md).

## ⚠️ Erros comuns

**1. Rodar o comando na pasta errada**

```text
Error when reading 'bin/saudacao.dart': O sistema não pode encontrar o arquivo especificado.
```

Você está fora da pasta do projeto. Rode `dir` e confirme que vê `pubspec.yaml` e `bin`.
Se não vir, use `cd dart_basico`.

**2. Esquecer o ponto e vírgula**

```text
Error: Expected ';' after this.
```

Toda instrução Dart termina com `;`. A mensagem aponta a linha **anterior** ao problema.

**3. Escrever `Main` ou `main()` fora de qualquer arquivo de `bin/`**

```text
Error: Can't find '@main'. Make sure the file declares 'main'.
```

O nome é `main`, todo em minúsculo. E arquivos em `lib/` não são feitos para rodar direto.

**4. Nome de projeto inválido**

```text
"Dart-Basico" is not a valid Dart package name.
```

O nome no `dart create` precisa ser `snake_case`: minúsculas, dígitos e sublinhado. Use
`dart_basico`, nunca `Dart-Basico` nem `dartBasico`.

**5. Criar o projeto dentro de um caminho com acento**
Neste computador o caminho do usuário tem acento (`C:\Users\Usuário\...`). Para o Dart puro
isso costuma funcionar, mas o SDK do Flutter em caminho com acento **já quebrou nesta máquina**.
A recomendação do curso vale aqui também: mantenha seus projetos em um caminho simples, por
exemplo `C:\src\`. O passo a passo está em
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

**6. Esperar que `dart run` aceite argumentos antes do arquivo**

```powershell
dart run Lucas bin/saudacao.dart
```

Não funciona. A ordem é sempre `dart run <arquivo> <argumentos...>`.

## 🛠️ Exercício guiado

Vamos criar o projeto do módulo e o primeiro programa, passo a passo.

**Passo 1 — escolha a pasta.** No terminal, vá para onde você guarda seus estudos:

```powershell
cd C:\src
```

Se a pasta não existir, crie com `mkdir C:\src` e entre nela.

**Passo 2 — crie o projeto:**

```powershell
dart create dart_basico
```

Saída aproximada:

```text
Creating dart_basico using template console...
...
Created project dart_basico in dart_basico!
```

**Passo 3 — entre e explore:**

```powershell
cd dart_basico
dir
```

Confirme que você vê `bin`, `lib`, `test`, `pubspec.yaml` e `analysis_options.yaml`.

**Passo 4 — rode o programa que já veio pronto:**

```powershell
dart run bin/dart_basico.dart
```

```text
Hello world: 42!
```

**Passo 5 — abra o projeto no VS Code:**

```powershell
code .
```

**Passo 6 — crie `bin/saudacao.dart`** e digite o código completo desta aula. Digite,
não copie: os erros que você cometer digitando são parte do treino.

**Passo 7 — rode com e sem argumentos:**

```powershell
dart run bin/saudacao.dart
dart run bin/saudacao.dart Lucas
dart run bin/saudacao.dart Lucas manha
```

**Passo 8 — compile e rode o executável:**

```powershell
dart compile exe bin/saudacao.dart -o saudacao.exe
.\saudacao.exe Lucas tarde
```

**Passo 9 — não versione o executável.** Abra `.gitignore` e acrescente a linha `*.exe`.
Binários gerados não entram no Git.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md)

Comece pelos exercícios de **Fixação** que mencionam estrutura de projeto, `main` e argumentos.

## 🏆 Desafio opcional

Escreva `bin/info_projeto.dart` que:

1. Aceite de 1 a 3 argumentos representando **minutos estudados** em dias diferentes
   (ex.: `dart run bin/info_projeto.dart 90 45 120`).
2. Imprima quantos dias foram informados.
3. Imprima a soma total dos minutos e a média, com o total convertido em horas e minutos
   (ex.: `255 minutos = 4h15`).
4. Se **nenhum** argumento for passado, imprima o modo de uso e encerre com `return`.

Dica: os argumentos chegam como **texto**, não como número. Você vai precisar de
`int.parse(argumentos[i])`. A forma segura de fazer isso — `int.tryParse` — é o assunto da
[Aula 4](04-tipos-strings-conversoes.md); por enquanto, use `int.parse` e passe só números.

## 📌 Resumo

- Todo programa Dart começa em `main`; sem `main`, o Dart recusa a rodar o arquivo.
- `dart create <nome>` cria o projeto padrão com `bin/`, `lib/`, `test/`, `pubspec.yaml` e
  `analysis_options.yaml`.
- `bin/` guarda o que roda; `lib/` guarda o que é reaproveitado; `test/` guarda os testes.
- `pubspec.yaml` declara nome, versão e a faixa de SDK (`sdk: ^3.13.0`).
- `main` pode receber `List<String>` com os argumentos da linha de comando.
- `dart run arquivo.dart` executa em JIT; `dart compile exe arquivo.dart -o saida.exe` gera um
  binário nativo AOT.
- Essa mesma anatomia se repete no Flutter — muda o conteúdo de `main`, não a ideia.

## ☑️ Checklist de domínio

- [ ] Criei o projeto `dart_basico` com `dart create` e ele roda.
- [ ] Sei dizer, sem consultar, o que vai em `bin/`, em `lib/` e em `test/`.
- [ ] Sei abrir o `pubspec.yaml` e apontar a linha que define a versão do Dart exigida.
- [ ] Escrevi um `main` que lê argumentos e trata o caso de lista vazia.
- [ ] Rodei o programa com `dart run` passando argumentos.
- [ ] Gerei um `.exe` com `dart compile exe` e executei.
- [ ] Consigo explicar a diferença entre JIT e AOT em uma frase.
- [ ] Adicionei `*.exe` ao `.gitignore`.

## 📚 Referências oficiais

- [Dart — Introduction to Dart](https://dart.dev/language)
- [Dart — The `dart create` command](https://dart.dev/tools/dart-create)
- [Dart — The `dart run` command](https://dart.dev/tools/dart-run)
- [Dart — The `dart compile` command](https://dart.dev/tools/dart-compile)
- [Dart — Package layout conventions](https://dart.dev/tools/pub/package-layout)
- [Dart — The pubspec file](https://dart.dev/tools/pub/pubspec)
- [Dart — Customizing static analysis](https://dart.dev/tools/analysis)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Sintaxe, convenções e comentários](02-sintaxe-convencoes-comentarios.md) |
