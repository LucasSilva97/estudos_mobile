# Aula 1 — O terminal sem medo

> **Módulo:** 00 - Git e Terminal · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Explicar o que é um **terminal** e o que é um **shell**, e por que eles não são a mesma coisa.
- Abrir o terminal certo no Windows 11, no macOS e no Linux.
- Diferenciar **PowerShell**, **bash** e **zsh** e saber qual você está usando.
- Navegar pelo sistema de arquivos com comandos seguros: descobrir a pasta atual, entrar e sair de
  pastas, listar arquivos.
- Criar arquivos e pastas e apagar coisas **sem destruir trabalho por acidente**.
- Ler a saída de um comando separando o que é resultado do que é erro.
- Entender **código de saída** e consultá-lo depois de qualquer comando.
- Entender **variáveis de ambiente** e, em especial, a variável `PATH`.
- Escrever e executar um programa Dart de terminal que inspeciona o próprio ambiente.

## ✅ Pré-requisitos

- Ambiente configurado conforme [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md)
  (Git 2.46+, Flutter 3.47.1 com Dart 3.13.1).
- A pasta de laboratório `lab_modulo_00` criada conforme a seção "Preparação prática" do
  [README do módulo](README.md).
- Vontade de digitar. Esta aula não funciona só lendo.

---

## 📖 Conceito

### O que é terminal, o que é shell

Quando você usa o computador pelo mouse, está usando uma **GUI** (*Graphical User Interface* —
interface gráfica: janelas, ícones, botões). Existe uma segunda forma de operar a mesma máquina:
a **CLI** (*Command Line Interface* — interface de linha de comando), onde você **escreve** o que
quer e o computador responde com texto.

Duas palavras aparecem juntas o tempo todo e significam coisas diferentes:

- **Terminal** (ou *emulador de terminal*) é a **janela**. É o programa que desenha o retângulo
  preto, mostra o texto, aceita o teclado. Exemplos: *Windows Terminal*, *Terminal.app* do macOS,
  *GNOME Terminal* no Linux, o painel "Terminal" do VS Code.
- **Shell** é o **interpretador**. É o programa que roda *dentro* do terminal, lê o que você
  digitou, decide o que aquilo significa e executa. Exemplos: **PowerShell**, **bash**, **zsh**,
  **cmd.exe**.

A mesma janela de terminal pode rodar shells diferentes. Por isso, quando um tutorial diz "rode este
comando no terminal", o que realmente importa é **qual shell** está ativo, porque a sintaxe muda.

### Os três shells que você vai encontrar

| Shell | Onde é padrão | Como reconhecer | Observação para este curso |
|---|---|---|---|
| **PowerShell** | Windows 10/11 | Prompt no formato `PS C:\Users\Voce>` | É o shell **oficial deste curso** para Windows |
| **bash** (*Bourne Again SHell*) | Linux, e no Windows dentro do **Git Bash** | Prompt no formato `usuario@maquina:~$` | Usado nos blocos 🐧 Linux |
| **zsh** (*Z shell*) | macOS desde o Catalina | Prompt no formato `usuario@maquina ~ %` | Usado nos blocos 🖥️ macOS |

Existe ainda o **cmd.exe** (o "Prompt de Comando" clássico do Windows). Ele é muito mais limitado
que o PowerShell e **não** será usado no curso.

> 🪟 **Atenção, Windows.** Ao instalar o Git 2.46, você ganhou de brinde o **Git Bash**: uma janela
> que roda `bash` dentro do Windows. Ele é útil, mas **misturar** os dois shells no mesmo dia é a
> maior fonte de confusão de iniciante. Regra do curso: **use PowerShell**. Só entre no Git Bash
> quando uma aula mandar explicitamente.

### Anatomia de um comando

Todo comando tem a mesma forma:

```text
<programa> <subcomando> <argumentos> <opções>
```

Exemplo real, que você vai digitar centenas de vezes neste curso:

```powershell
flutter build apk --release
```

- `flutter` é o **programa**.
- `build` é o **subcomando** (o que você quer que o programa faça).
- `apk` é um **argumento** (o alvo da ação).
- `--release` é uma **opção** (também chamada de *flag*): modifica o comportamento. Opções longas
  começam com dois hifens (`--release`); opções curtas, com um hifen (`-v`).

### As três saídas de um comando

Quando um comando termina, ele te devolve **três coisas diferentes**. Confundi-las é a causa de
muita frustração:

1. **stdout** (*standard output* — saída padrão): o texto de resultado normal. É o que você lê.
2. **stderr** (*standard error* — saída de erro): o texto de aviso e de erro. No terminal ele
   aparece misturado ao stdout, mas é um canal separado — por isso às vezes você redireciona a saída
   para um arquivo e os erros continuam aparecendo na tela.
3. **Código de saída** (*exit code*): um **número inteiro**, invisível, de 0 a 255.
   - `0` significa **sucesso**.
   - Qualquer número **diferente de 0** significa **falha**. O significado de cada número é decidido
     por quem escreveu o programa.

Esse número é o que ferramentas automáticas (scripts, integração contínua, o próprio VS Code) usam
para saber se deu certo. Você vai ver, mais à frente no curso, `flutter analyze` encerrando com
código `255` nesta máquina por causa de um problema de caminho — e o número é exatamente o sinal de
que algo falhou.

### Variáveis de ambiente e o `PATH`

Uma **variável de ambiente** é um par nome/valor que o sistema operacional entrega a todo programa
que inicia. Pense nelas como bilhetes de configuração que o sistema coloca no bolso de cada programa
ao nascer.

A mais importante de todas se chama **`PATH`**. Ela contém uma **lista de pastas**, separadas por
`;` no Windows e por `:` no macOS/Linux. Quando você digita `flutter`, o shell **não** procura esse
programa no computador inteiro — ele procura apenas, e em ordem, dentro das pastas listadas no
`PATH`. A primeira que tiver um executável chamado `flutter` vence.

Consequências práticas que valem para o curso inteiro:

- Se `flutter` não está no `PATH`, o shell responde que o comando não foi reconhecido — **mesmo que
  o Flutter esteja instalado**.
- Se houver **duas** instalações, vence a que aparece **primeiro** no `PATH`. É assim que se acaba
  rodando uma versão antiga sem perceber.
- Mudou o `PATH`? **Feche e abra o terminal.** Uma janela já aberta continua com a cópia antiga das
  variáveis.

---

## 💡 Analogia

O `PATH` é a **lista de gavetas que a secretária abre, em ordem, quando você pede um documento pelo
nome**. Você diz "me traz o `flutter`". Ela não revira o prédio inteiro: abre a gaveta 1, depois a 2,
depois a 3 — e entrega o **primeiro** `flutter` que encontrar. Se o documento estiver numa gaveta que
não está na lista dela, a resposta é "não existe", ainda que o documento esteja no prédio. E se houver
um `flutter` velho na gaveta 1 e o novo na gaveta 5, você recebe o velho.

Essa analogia é fiel: a busca é **sequencial**, **para na primeira ocorrência** e **ignora tudo que
não está na lista**.

---

## 🧪 Exemplo mínimo

Abra o terminal e rode estes três comandos, nesta ordem. Eles são **somente de leitura** — não
alteram nada.

**🪟 Windows (PowerShell)**

```powershell
Get-Location
Get-ChildItem
$LASTEXITCODE
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
pwd
ls -la
echo $?
```

- `Get-Location` / `pwd` mostram a **pasta atual** (*working directory* — a pasta onde o shell está
  "parado" naquele momento).
- `Get-ChildItem` / `ls -la` **listam** o conteúdo dessa pasta.
- `$LASTEXITCODE` / `echo $?` mostram o **código de saída** do comando anterior.

> ⚠️ No PowerShell, `$LASTEXITCODE` guarda o código de saída do **último programa externo** (como
> `git` ou `flutter`). Para cmdlets nativos do PowerShell (como `Get-ChildItem`) use `$?`, que vale
> `True` para sucesso e `False` para falha.

Teste a diferença entre sucesso e falha com um programa externo que você já tem:

```powershell
git --version
$LASTEXITCODE      # deve mostrar 0
git comando-que-nao-existe
$LASTEXITCODE      # deve mostrar um número diferente de 0
```

---

## 📱 Aplicando no Flutter

Você ainda não sabe Flutter, e tudo bem. Mesmo assim, vale saber **onde** isto reaparece:

- **O Flutter é uma ferramenta de terminal.** Criar um app, rodar, testar e gerar o instalador são
  comandos: `flutter create`, `flutter run`, `flutter test`, `flutter build apk`. Você verá o
  primeiro deles em [Módulo 05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md),
  na aula [02-estrutura-do-projeto.md](../05-introducao-ao-flutter/02-estrutura-do-projeto.md).
- **`PATH` é o motivo número 1 de "flutter não é reconhecido".** Quando isso acontecer, você vai
  saber que a causa não é o Flutter estar quebrado, e sim a pasta `bin` dele não estar na lista de
  gavetas. O diagnóstico completo está em
  [referencias/erros-comuns.md](../../referencias/erros-comuns.md).
- **Código de saída é o que faz a automação funcionar.** Quando você montar uma esteira de build em
  [Módulo 17 — Publicação](../17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md), o servidor
  decide "passou / não passou" olhando **só** esse número: `flutter test` devolve `0` se todos os
  testes passam e um valor diferente de `0` se algum falha.
- **stdout × stderr aparecem no console do Flutter.** Em
  [Módulo 12 — Testes e Debug](../12-testes-e-debug/02-logs-e-breakpoints.md) você vai aprender que
  `debugPrint()` escreve na saída normal, enquanto exceções não tratadas vão para a saída de erro —
  e é por isso que elas aparecem em vermelho.
- **Variáveis de ambiente viram configuração de app.** Em
  [Módulo 13 — Desempenho e Segurança](../13-desempenho-e-seguranca/06-seguranca-mobile.md) você vai
  ver que chaves de API não ficam no código: ficam fora dele, e o mecanismo mental é o mesmo que você
  está aprendendo agora.

---

## 💻 Código completo

Vamos escrever um programa Dart que faz o diagnóstico do próprio terminal: mostra o sistema, a pasta
atual, quebra o `PATH` em pedaços, procura o Flutter dentro dele e **encerra com código de saída
diferente conforme o resultado**.

> **Arquivo:** `lab_modulo_00/bin/diagnostico_terminal.dart`
> **Como executar:** de dentro da pasta `lab_modulo_00`, rode `dart run bin/diagnostico_terminal.dart`

```dart
import 'dart:io';

/// Diagnóstico do terminal e das variáveis de ambiente.
///
/// Códigos de saída usados por este programa:
///   0 -> tudo certo: PATH existe e contém uma pasta do Flutter
///   1 -> PATH existe, mas nenhuma pasta do Flutter foi encontrada
///   2 -> PATH não existe ou está vazio (situação grave)
void main(List<String> argumentos) {
  final Map<String, String> ambiente = Platform.environment;

  stdout.writeln('=== Diagnóstico do terminal ===');
  stdout.writeln('Sistema operacional : ${Platform.operatingSystem}');
  stdout.writeln('Versão do sistema   : ${Platform.operatingSystemVersion}');
  stdout.writeln('Versão do Dart      : ${Platform.version}');
  stdout.writeln('Pasta atual         : ${Directory.current.path}');
  stdout.writeln('Separador de pastas : "${Platform.pathSeparator}"');
  stdout.writeln('Argumentos recebidos: $argumentos');
  stdout.writeln('');

  final String separadorDoPath = Platform.isWindows ? ';' : ':';
  final String? valorDoPath = ambiente['PATH'];

  if (valorDoPath == null || valorDoPath.trim().isEmpty) {
    stderr.writeln('ERRO: a variável PATH está vazia ou não existe.');
    exit(2);
  }

  final List<String> pastas = valorDoPath
      .split(separadorDoPath)
      .map((String pasta) => pasta.trim())
      .where((String pasta) => pasta.isNotEmpty)
      .toList();

  stdout.writeln('O PATH tem ${pastas.length} pasta(s). Primeiras cinco:');
  for (final String pasta in pastas.take(5)) {
    stdout.writeln('  - $pasta');
  }
  stdout.writeln('');

  final bool temFlutter =
      pastas.any((String pasta) => pasta.toLowerCase().contains('flutter'));
  stdout.writeln(temFlutter
      ? 'OK    : existe pelo menos uma pasta com "flutter" no PATH.'
      : 'AVISO : nenhuma pasta com "flutter" no PATH.');

  final List<String> suspeitas = pastas
      .where((String pasta) => pasta.contains(' ') || temCaractereNaoAscii(pasta))
      .toList();

  if (suspeitas.isEmpty) {
    stdout.writeln('OK    : nenhuma pasta do PATH tem espaço ou acento.');
  } else {
    stdout.writeln('AVISO : ${suspeitas.length} pasta(s) do PATH com espaço ou acento:');
    for (final String pasta in suspeitas) {
      stdout.writeln('  ! $pasta');
    }
  }

  stdout.writeln('');
  stdout.writeln('Encerrando com código ${temFlutter ? 0 : 1}.');
  exitCode = temFlutter ? 0 : 1;
}

/// Diz se o texto tem algum caractere fora da tabela ASCII (acentos, ç, emojis).
bool temCaractereNaoAscii(String texto) {
  return RegExp(r'[^\x00-\x7F]').hasMatch(texto);
}
```

Depois de rodar, confira o código de saída:

**🪟 Windows (PowerShell)**

```powershell
dart run bin/diagnostico_terminal.dart
$LASTEXITCODE
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
dart run bin/diagnostico_terminal.dart
echo $?
```

---

## 🔍 Explicando o código

- `import 'dart:io';` — traz a biblioteca de entrada e saída do Dart. É ela que dá acesso a
  `Platform`, `Directory`, `stdout`, `stderr`, `exit` e `exitCode`. Programas que rodam no terminal
  quase sempre importam `dart:io`. (Note para o futuro: essa biblioteca **não** existe no Flutter
  Web, porque o navegador não deixa um site ler seus arquivos.)
- `void main(List<String> argumentos)` — `main` é o ponto de entrada: a função que o Dart executa
  primeiro. A lista `argumentos` recebe o que você digitou **depois** do nome do programa.
  Experimente `dart run bin/diagnostico_terminal.dart alfa beta` e veja a diferença na saída.
- `Platform.environment` — um `Map<String, String>` (*mapa*: uma coleção de pares chave → valor) com
  todas as variáveis de ambiente. No Windows, a busca por chave nesse mapa **ignora maiúsculas e
  minúsculas**; no macOS/Linux, não.
- `stdout.writeln(...)` versus `print(...)` — os dois escrevem na saída padrão. Preferimos
  `stdout.writeln` aqui porque deixa explícito **em qual canal** estamos escrevendo, e porque
  `stderr.writeln` (o canal de erro) tem a mesma forma. Além disso, `print()` dispara o aviso do
  analisador chamado `avoid_print`, que você vai conhecer em
  [Módulo 04 — Análise estática e lints](../04-dart-avancado/07-analise-estatica-e-lints.md). Em
  módulos de Dart puro no terminal, `print()` é aceitável; em código Flutter, use `debugPrint()`.
- `final String? valorDoPath = ambiente['PATH'];` — o `?` depois de `String` marca um tipo
  **anulável** (pode conter `null`, que significa "nenhum valor"). Buscar uma chave que não existe
  em um `Map` devolve `null`, então o tipo tem de permitir isso. Esse mecanismo se chama
  *null safety* e ganha uma aula inteira em
  [Módulo 02 — Null safety](../02-dart-basico/05-null-safety.md).
- `if (valorDoPath == null || valorDoPath.trim().isEmpty) { ... exit(2); }` — `exit(2)` **encerra o
  programa imediatamente** com o código 2. Use `exit` quando não faz sentido continuar.
- `valorDoPath.split(separadorDoPath)` — quebra a string gigante do `PATH` em uma lista, usando
  `;` ou `:` como ponto de corte. Depois, `.map(...)` remove espaços das pontas de cada item e
  `.where(...)` descarta itens vazios (o `PATH` costuma ter um separador sobrando no fim).
- `pastas.take(5)` — pega no máximo os cinco primeiros itens. Um `PATH` real tem dezenas de pastas;
  imprimir tudo polui a tela.
- `pastas.any(...)` — devolve `true` se **pelo menos um** item satisfaz a condição.
- `RegExp(r'[^\x00-\x7F]')` — uma **expressão regular** (um padrão de busca em texto). Aqui ela
  significa "qualquer caractere que **não** esteja entre os códigos 0 e 127", ou seja, fora do ASCII
  básico — acentos, `ç`, emojis. O `r` antes das aspas cria uma *raw string*, na qual a barra
  invertida é literal e não precisa ser duplicada.
- `exitCode = temFlutter ? 0 : 1;` — diferente de `exit()`, atribuir a `exitCode` **não interrompe**
  o programa: apenas registra qual número será devolvido quando `main` terminar normalmente.
  `condição ? valorSeVerdadeiro : valorSeFalso` é o **operador ternário**, uma forma curta de `if`.

---

## 🤖🍎 Android × iOS

Ainda não estamos programando para celular, mas o terminal já muda conforme a plataforma-alvo:

| Assunto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onde o build pode ser feito | Windows, macOS ou Linux | **Somente macOS** |
| Shell típico do fluxo | PowerShell (🪟) ou bash (🐧) | zsh (🖥️) |
| Ferramenta de linha de comando do fabricante | `adb` (*Android Debug Bridge*), instalada com o Android SDK | `xcrun`, instalada com o Xcode |
| Variável de ambiente crítica | `ANDROID_HOME`, apontando para o Android SDK | `DEVELOPER_DIR`, gerenciada pelo `xcode-select` |

> 🍎 **SÓ NO MAC.** Tudo que envolve compilar, assinar ou publicar para iPhone exige macOS + Xcode.
> No Windows você consegue **ler, entender e planejar** o processo, mas não executá-lo. O porquê
> técnico completo está em
> [16-build-ios/01-por-que-exige-macos.md](../16-build-ios/01-por-que-exige-macos.md).

> 🪟 **Nesta máquina, hoje:** `ANDROID_HOME` está **vazio** porque o Android Studio ainda não foi
> instalado. Isso é esperado neste ponto do curso e será resolvido em
> [Módulo 15 — Build Android](../15-build-android/README.md).

---

## ⚠️ Erros comuns

**1. "O termo 'flutter' não é reconhecido como nome de cmdlet"**

```text
flutter : O termo 'flutter' não é reconhecido como nome de cmdlet, função,
arquivo de script ou programa operável.
```

Causa: a pasta `bin` do Flutter não está no `PATH`, ou você mudou o `PATH` e não reabriu o terminal.
Correção: confira com `Get-Command flutter` (PowerShell) ou `which flutter` (bash/zsh); se não achar,
volte a [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

**2. Copiar comando de tutorial de Linux para o PowerShell**

`ls -la`, `rm -rf`, `export VAR=valor` e `touch arquivo.txt` são sintaxe de bash. No PowerShell os
equivalentes são `Get-ChildItem -Force`, `Remove-Item -Recurse -Force`, `$env:VAR = 'valor'` e
`New-Item -ItemType File arquivo.txt`. Sintaxe errada gera erro de análise, não de permissão.

**3. Apagar a pasta errada**

`Remove-Item -Recurse -Force` e `rm -rf` **não mandam nada para a lixeira**. O que some, some.
Regras de sobrevivência deste curso:

- Antes de apagar, rode `Get-Location` e confirme onde você está.
- Antes de apagar em massa, **liste** primeiro: `Get-ChildItem <alvo>` mostra exatamente o que será
  atingido.
- Nunca rode um comando de remoção com caminho que comece na raiz (`C:\`, `/`).
- Se o alvo é uma pasta de build, prefira o comando da própria ferramenta: `flutter clean` apaga
  `build/` e `.dart_tool/` com segurança, sem você precisar mirar à mão.

**4. Confundir sucesso de tela com sucesso de código**

Um comando pode imprimir muita coisa e ainda assim ter falhado. Se você automatiza algo, olhe o
código de saída, não o texto.

**5. Achar que `$LASTEXITCODE` vale para tudo no PowerShell**

Ele só é atualizado por **programas externos** (`git`, `flutter`, `dart`). Depois de um cmdlet do
PowerShell, use `$?`.

**6. Espaço no caminho sem aspas**

```powershell
Set-Location C:\Users\Meu Usuario\Projetos    # falha
Set-Location "C:\Users\Meu Usuario\Projetos"  # correto
```

O shell corta o comando nos espaços. Aspas duplas mantêm tudo junto. A Aula 2 mostra por que a
melhor solução não é usar aspas, e sim **não ter espaço no caminho**.

---

## 🛠️ Exercício guiado

Vamos criar uma pasta de teste, colocar um arquivo dentro, ler o arquivo e apagar tudo — com
segurança. Faça passo a passo, lendo cada saída.

**Passo 1 — Vá para a pasta de laboratório e confirme onde você está**

```powershell
Set-Location C:\src\cursos\lab_modulo_00
Get-Location
```

A saída deve terminar em `lab_modulo_00`. Se não terminar, **não siga adiante**: corrija o caminho.

**Passo 2 — Crie uma pasta descartável e entre nela**

```powershell
New-Item -ItemType Directory -Force teste_terminal
Set-Location teste_terminal
Get-Location
```

`teste_terminal` é um **caminho relativo**: começa a contar a partir da pasta atual. A Aula 2 explora
isso a fundo.

**Passo 3 — Crie um arquivo e escreva nele**

```powershell
"primeira linha" | Out-File -Encoding utf8 anotacoes.txt
"segunda linha" | Add-Content -Encoding utf8 anotacoes.txt
```

`Out-File` cria (ou substitui). `Add-Content` acrescenta ao final. `-Encoding utf8` garante que
acentos sejam gravados corretamente — assunto da próxima aula.

**Passo 4 — Leia o arquivo e conte as linhas**

```powershell
Get-Content anotacoes.txt
(Get-Content anotacoes.txt | Measure-Object -Line).Lines
```

Esperado: as duas linhas e, depois, o número `2`.

**Passo 5 — Verifique o código de saída de um programa externo**

```powershell
dart --version
$LASTEXITCODE
```

Esperado: a versão `3.13.1` e o código `0`.

**Passo 6 — Volte e apague com segurança**

```powershell
Set-Location C:\src\cursos\lab_modulo_00
Get-ChildItem teste_terminal
Remove-Item -Recurse -Force teste_terminal
Test-Path teste_terminal
```

Repare na ordem: **listar antes, apagar depois**. `Test-Path` deve responder `False`, confirmando que
a pasta sumiu.

**Passo 7 — Rode o programa da aula**

Salve o código da seção "Código completo" em `bin/diagnostico_terminal.dart` e execute:

```powershell
dart run bin/diagnostico_terminal.dart
$LASTEXITCODE
```

Nesta máquina, o programa provavelmente vai avisar que existe uma pasta do `PATH` **com acento** —
justamente `C:\Users\Usuário\Documents\flutter\bin`. Guarde essa informação: ela é o tema da Aula 2.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/00-git-e-terminal.md](../../exercicios/00-git-e-terminal.md)

Foque nos exercícios das seções **Fixação** e **Aplicação**, que cobrem navegação, leitura de saída,
código de saída e `PATH`.

---

## 🏆 Desafio opcional

Estenda `bin/diagnostico_terminal.dart` para que ele:

1. Aceite um argumento opcional na linha de comando com o nome de um programa
   (ex.: `dart run bin/diagnostico_terminal.dart git`).
2. Percorra as pastas do `PATH` e verifique, com `File(...).existsSync()`, se existe ali um arquivo
   com aquele nome — testando as terminações `.exe`, `.bat` e `.cmd` no Windows, e sem terminação no
   macOS/Linux.
3. Imprima o **caminho completo do primeiro encontrado** (que é exatamente o que o shell executaria)
   e encerre com código `0`; se não encontrar nenhum, imprima uma mensagem em `stderr` e encerre com
   código `3`.

Dica: monte o caminho candidato com
`'$pasta${Platform.pathSeparator}$nome$terminacao'` e use `File(caminho).existsSync()`.

---

## 📌 Resumo

- **Terminal** é a janela; **shell** é o interpretador que roda dentro dela. No Windows deste curso,
  o shell é o **PowerShell**.
- Um comando é `programa + subcomando + argumentos + opções`.
- Todo comando devolve **stdout**, **stderr** e um **código de saída**: `0` é sucesso, qualquer outro
  número é falha.
- No PowerShell, `$LASTEXITCODE` traz o código do último **programa externo**; `$?` traz sucesso ou
  falha do último cmdlet. Em bash/zsh, `echo $?` cobre os dois casos.
- **Variáveis de ambiente** configuram programas por fora. O **`PATH`** é a lista ordenada de pastas
  onde o shell procura executáveis — e a primeira ocorrência vence.
- Mudou variável de ambiente? **Reabra o terminal.**
- Comandos de remoção não usam lixeira. **Liste antes de apagar** e confirme a pasta atual.
- Em Dart, `dart:io` dá acesso a `Platform.environment`, `Directory.current`, `stdout`, `stderr`,
  `exit()` (encerra na hora) e `exitCode` (define o código para o fim normal).

---

## ☑️ Checklist de domínio

- [ ] Sei explicar, com minhas palavras, a diferença entre terminal e shell.
- [ ] Identifico, olhando o prompt, se estou em PowerShell, bash ou zsh.
- [ ] Descubro a pasta atual e navego para outra pasta sem errar.
- [ ] Listo o conteúdo de uma pasta, inclusive arquivos ocultos.
- [ ] Crio um arquivo de texto pelo terminal e leio seu conteúdo.
- [ ] Apago uma pasta seguindo o procedimento seguro (conferir a pasta atual → listar → apagar →
      verificar com `Test-Path`).
- [ ] Verifico o código de saída do último comando e sei o que `0` significa.
- [ ] Mostro o conteúdo do `PATH` e explico por que a ordem das pastas importa.
- [ ] Rodo `bin/diagnostico_terminal.dart` e explico o que cada bloco do programa faz.
- [ ] Sei o que fazer quando aparece "não é reconhecido como nome de cmdlet".

---

## 📚 Referências oficiais

- [Documentação do PowerShell (Microsoft Learn)](https://learn.microsoft.com/pt-br/powershell/)
- [Windows Terminal — documentação](https://learn.microsoft.com/pt-br/windows/terminal/)
- [Dart — biblioteca `dart:io`](https://api.dart.dev/stable/dart-io/dart-io-library.html)
- [Dart — classe `Platform`](https://api.dart.dev/stable/dart-io/Platform-class.html)
- [Dart — `dart run`](https://dart.dev/tools/dart-run)
- [Flutter — instalação e configuração do PATH](https://docs.flutter.dev/get-started/install/windows)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Arquivos e caminhos](02-arquivos-e-caminhos.md) |
