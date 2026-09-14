# 02 — Configuração do Ambiente

> **Este é o arquivo mais importante do curso.** Nada do que vem depois funciona se o
> ambiente não estiver correto. Reserve o **Dia 1** inteiro para ele, conforme o
> [plano intensivo](01-plano-intensivo.md).

**Tempo estimado:** 3 h a 4 h (primeira instalação completa)
**Nível:** Fundamental — escrito para quem nunca instalou nada de desenvolvimento mobile.

---

## Índice

| Parte | Assunto |
|---|---|
| [Parte 0](#parte-0--conceitos-antes-de-instalar-qualquer-coisa) | Conceitos antes de instalar qualquer coisa |
| [Parte 1](#parte-1--o-seu-ambiente-diagnóstico-real-desta-máquina) | O SEU ambiente (diagnóstico real desta máquina) |
| [Parte 2](#parte-2--instalação-do-zero) | Instalação do zero (Windows · macOS · Linux) |
| [Parte 3](#parte-3--emulador-e-aparelho-físico-android) | Emulador e aparelho físico Android |
| [Parte 4](#parte-4--flutter-doctor-linha-por-linha) | `flutter doctor` linha por linha |
| [Parte 5](#parte-5--primeiro-projeto) | Primeiro projeto |
| [Parte 6](#parte-6--ambiente-ios--só-no-mac) | 🍎 Ambiente iOS (só no Mac) |
| [Parte 7](#parte-7--o-que-dá-para-fazer-no-windows--o-que-exige-mac) | Windows × Mac: o que dá e o que não dá |
| [Parte 8](#parte-8--checklist-de-saída) | Checklist de saída |

---

# PARTE 0 — Conceitos antes de instalar qualquer coisa

Antes de digitar um único comando, você precisa entender **o que** está instalando e **por quê**.
Instalar sem entender é a causa número um de travar no Dia 1 e desistir no Dia 3.

## 0.1 O que é programar, de verdade

**Programar** é escrever instruções precisas, em uma linguagem que a máquina consegue
interpretar, para que um computador execute uma tarefa.

Quatro palavras aparecem o tempo todo daqui para a frente:

| Termo | O que significa |
|---|---|
| **Código-fonte** | O texto que você escreve, legível por pessoas. Em Dart, são arquivos com extensão `.dart`. É isso que você versiona no Git e o que outra pessoa lê para entender o programa. |
| **Compilação** | O processo de traduzir o código-fonte para uma forma que a máquina executa. Quem faz isso é o **compilador**. Se houver erro de escrita ou de tipo, a compilação falha e nada roda. |
| **Execução** | O momento em que o programa já traduzido roda de fato — no seu computador, no emulador ou no celular. Erros que só aparecem aqui são chamados de *erros em tempo de execução* (*runtime*). |
| **Depuração** (*debug*) | Investigar por que o programa não faz o que você esperava: ler mensagens de erro, imprimir valores, pausar a execução em um ponto. |

> **Por que isso importa agora?** Porque a maior parte dos problemas de ambiente aparece
> justamente na etapa de **compilação** — e a mensagem de erro fala de coisas que só fazem
> sentido se você souber que essa etapa existe.

## 0.2 O que é Dart

**Dart** é a linguagem de programação criada pelo Google que você vai usar durante todo o curso.
Características que importam para você:

- É **tipada** — cada valor tem um tipo (`int`, `String`, `bool`, …) e o compilador confere isso
  para você antes de rodar. Isso pega muito erro cedo.
- Tem ***null safety*** (segurança contra nulo) — o compilador te obriga a dizer quais valores
  podem ser "nada" (`null`). Isso elimina uma classe inteira de falhas em produção.
- Compila para **código nativo** (ARM/x64, o que o celular entende diretamente) e também para
  **JavaScript/WebAssembly** (o que o navegador entende).
- Versão usada neste curso: **Dart 3.13.1**.

Você já viu Dart de terminal (`print`, `stdin`, variáveis, interpolação). O curso retoma isso do
zero nos módulos [01](modulos/01-logica-e-fundamentos/README.md) a
[04](modulos/04-dart-avancado/README.md).

## 0.3 O que é Flutter

**Flutter** é o *framework* (um conjunto pronto de bibliotecas e ferramentas que dá a estrutura
do seu aplicativo) do Google para construir interfaces gráficas usando Dart.

Diferença importante e frequentemente confundida:

- **Dart** é a linguagem. Existe sem o Flutter.
- **Flutter** é o framework de interface. Não existe sem o Dart.

O Flutter **desenha cada pixel da tela ele mesmo**, com seu próprio motor gráfico (chamado
*Impeller* nas versões atuais). Ele não pede botões emprestados ao Android ou ao iOS — ele
redesenha um botão que se parece com o do Android ou com o do iOS. Consequência prática:
**o mesmo código produz a mesma tela nos dois sistemas**, o que é exatamente o que você quer.

Versão usada neste curso: **Flutter 3.47.1**, canal `stable`.

## 0.4 SDK, IDE, terminal, emulador, simulador

Quatro palavras que vão aparecer em toda mensagem de erro:

### SDK
**SDK** (*Software Development Kit* — "kit de desenvolvimento de software") é o pacote de
ferramentas que você instala para conseguir programar em uma tecnologia. Ele traz o compilador,
as bibliotecas, e os programas de linha de comando.

Você vai instalar dois SDKs:
- **Flutter SDK** — traz junto o Dart SDK, o comando `flutter` e o comando `dart`.
- **Android SDK** — traz as bibliotecas do Android, o emulador e o `adb`.

E no Mac, um terceiro: o **iOS SDK**, que vem dentro do Xcode.

### IDE
**IDE** (*Integrated Development Environment* — "ambiente de desenvolvimento integrado") é o
programa onde você escreve o código. Ele junta editor de texto, sugestões de código, detecção de
erro enquanto você digita, depurador e integração com o Git.

Neste curso: **VS Code** com as extensões Dart e Flutter. **Android Studio** é a alternativa
oficial — e você vai instalá-lo de qualquer forma, porque é por ele que se instala o Android SDK
e o emulador.

### Terminal
**Terminal** (também chamado de *console*, *prompt* ou *linha de comando*) é a janela onde você
digita comandos em texto em vez de clicar em botões. Quase tudo em Flutter passa por ali.

- 🪟 No Windows: **PowerShell** (o que este curso usa) ou o Prompt de Comando (`cmd`).
- 🖥️ No macOS: **Terminal.app**, rodando `zsh`.
- 🐧 No Linux: **Terminal**, rodando `bash` ou `zsh`.

### Emulador × Simulador
Duas palavras que muita gente troca, e a diferença é real:

| | **Emulador** (🤖 Android) | **Simulador** (🍎 iOS) |
|---|---|---|
| O que é | Um Android completo rodando dentro de uma máquina virtual no seu computador | Um ambiente que **imita** o comportamento do iOS usando o próprio macOS por baixo |
| Fidelidade | Alta — é o sistema operacional Android de verdade | Boa para UI, mas não é o iOS de verdade; não usa código ARM do iPhone |
| Exige | Virtualização de hardware ligada (VT-x / AMD-V) | macOS + Xcode |
| Roda no Windows? | ✅ Sim | ❌ Não. Nunca. |

## 0.5 Aplicativo nativo × multiplataforma

**Aplicativo nativo** é aquele escrito na linguagem e com as ferramentas oficiais de um único
sistema: Kotlin/Java para Android, Swift/Objective-C para iOS. Dois apps, dois códigos, duas
equipes.

**Aplicativo multiplataforma** (*cross-platform*) é aquele em que um único código-fonte gera o
app para vários sistemas. É o caso do Flutter.

| Critério | Nativo | Flutter (multiplataforma) |
|---|---|---|
| Bases de código | 2 (Android + iOS) | 1 |
| Interface | Componentes do próprio sistema | Desenhada pelo motor do Flutter |
| Acesso a recursos do aparelho | Direto | Via *plugin* (pacote que faz a ponte com o código nativo) |
| Velocidade de entrega | Menor | Maior |
| Peso do app | Menor | Um pouco maior (o motor gráfico vai junto) |
| Recurso lançado hoje pela Apple/Google | Disponível de imediato | Depende de um plugin ou de você escrever a ponte |

> ⚠️ **Ponto honesto:** Flutter é multiplataforma para o **código**, não para o **build**.
> Gerar o instalador de iOS continua exigindo um Mac. Isso é detalhado na
> [Parte 6](#parte-6--ambiente-ios--só-no-mac) e na [Parte 7](#parte-7--o-que-dá-para-fazer-no-windows--o-que-exige-mac).

## 0.6 APK, AAB, build iOS e IPA

Esses quatro nomes são os **formatos de entrega** do seu app. Você vai gerá-los nos módulos
[14](modulos/14-build-android/README.md) e [15](modulos/15-build-ios/README.md), mas precisa
saber o que são desde já, porque eles aparecem em mensagens de erro.

### 🤖 APK — *Android Package*
- **O que é:** um único arquivo `.apk` que contém o app inteiro pronto para instalar em um
  aparelho Android.
- **Para que serve:** instalar direto no celular, sem loja. É o formato que você manda para um
  colega testar por WhatsApp ou Drive.
- **Onde é usado:** testes, distribuição interna, lojas alternativas.
- **Onde aparece no disco:** `build/app/outputs/flutter-apk/app-release.apk`.
- **Detalhe:** um APK "gordo" (*fat APK*) carrega o código para todas as arquiteturas de
  processador ao mesmo tempo, então fica grande. Por isso existe `flutter build apk --split-per-abi`,
  que gera um APK por arquitetura (`app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`,
  `app-x86_64-release.apk`).

### 🤖 AAB — *Android App Bundle*
- **O que é:** um arquivo `.aab`. **Não é instalável diretamente.** É um pacote de publicação
  que contém todos os pedaços do app (código por arquitetura, recursos por densidade de tela,
  por idioma).
- **Para que serve:** você envia o `.aab` para a Google Play, e a **própria loja** monta, na hora
  do download, um APK sob medida para o aparelho de cada pessoa. O usuário baixa menos MB.
- **Onde é usado:** **é obrigatório** para publicar apps novos na Google Play.
- **Onde aparece no disco:** `build/app/outputs/bundle/release/app-release.aab`.

> Regra prática: **APK para testar, AAB para publicar.**

### 🍎 Build iOS
- **O que é:** o resultado de compilar o app para iPhone/iPad. Em uma etapa intermediária ele
  vira um **arquivo de arquivamento** (*archive*), a pasta `Runner.xcarchive`.
- **Para que serve:** o *archive* guarda o app compilado + os símbolos de depuração. É a partir
  dele que se exporta o instalador final.
- **Onde aparece no disco:** `build/ios/archive/Runner.xcarchive`.
- **Exige:** macOS + Xcode. Sempre.

### 🍎 IPA — *iOS App Store Package*
- **O que é:** um arquivo `.ipa`, o equivalente iOS do APK — o app empacotado e **assinado**.
- **Para que serve:** enviar para a App Store Connect ou distribuir via TestFlight / distribuição
  ad hoc / empresarial.
- **Onde é usado:** publicação e testes externos no ecossistema Apple.
- **Onde aparece no disco:** `build/ios/ipa/<nome>.ipa`.
- **Comando:** `flutter build ipa`.
- ⚠️ **Não existe forma suportada de gerar IPA no Windows.** Qualquer tutorial que prometa isso
  está errado ou está falando de um serviço em nuvem que roda um Mac para você.

### Tabela comparativa

| | APK | AAB | Archive iOS | IPA |
|---|---|---|---|---|
| Sistema | 🤖 Android | 🤖 Android | 🍎 iOS | 🍎 iOS |
| Instala direto no aparelho | ✅ | ❌ | ❌ | ✅ (com assinatura válida) |
| Vai para a loja | ❌ (Play não aceita mais para apps novos) | ✅ | ❌ | ✅ |
| Gera no Windows | ✅ | ✅ | ❌ | ❌ |
| Comando | `flutter build apk` | `flutter build appbundle` | etapa do `flutter build ipa` | `flutter build ipa` |

## 0.7 Estrutura geral de um projeto Flutter

Quando você roda `flutter create primeiro_app`, o Flutter cria esta árvore. Leia com atenção —
você vai conviver com ela por 30 dias.

```text
primeiro_app/
├── .gitignore              # lista de arquivos que o Git deve IGNORAR (build, caches, segredos)
├── .metadata               # arquivo interno do Flutter: versão usada ao criar o projeto.
│                           # Não edite à mão. É versionado no Git.
├── analysis_options.yaml   # regras de análise estática (os "lints"). Define o que o editor
│                           # marca como aviso/erro. Neste curso: flutter_lints ^6.0.0
├── pubspec.yaml            # ⭐ O arquivo mais importante. Nome do projeto, versão,
│                           # dependências (pacotes externos) e assets (imagens, fontes).
├── pubspec.lock            # versões EXATAS que foram resolvidas. Gerado automaticamente.
│                           # Versione este arquivo em apps (garante build reproduzível).
├── README.md               # descrição do projeto (texto livre)
│
├── lib/                    # ⭐ Todo o seu código Dart mora aqui. É a pasta que você mais usa.
│   └── main.dart           # ponto de entrada do app: contém a função main()
│
├── test/                   # testes automatizados escritos em Dart
│   └── widget_test.dart    # teste de exemplo gerado pelo flutter create
│
├── android/                # 🤖 projeto Android nativo (Gradle/Kotlin) que "hospeda" seu app
│   ├── app/
│   │   ├── build.gradle.kts       # applicationId, versões de SDK, assinatura de release
│   │   └── src/main/AndroidManifest.xml  # nome do app, ícone, permissões, activity inicial
│   ├── build.gradle.kts
│   ├── gradle.properties
│   └── settings.gradle.kts
│
├── ios/                    # 🍎 projeto iOS nativo (Xcode) que "hospeda" seu app
│   ├── Runner.xcodeproj/          # projeto do Xcode
│   ├── Runner.xcworkspace/        # ⭐ é ESTE que se abre no Xcode (não o .xcodeproj)
│   ├── Runner/Info.plist          # nome do app, versão, permissões, orientações de tela
│   ├── Runner/Assets.xcassets/    # ícones do app
│   └── Podfile                    # dependências nativas gerenciadas pelo CocoaPods
│
├── web/                    # 🌐 arquivos para rodar o app no navegador (index.html, manifest)
├── windows/                # 🪟 projeto nativo para app de desktop Windows (C++/CMake)
├── linux/                  # 🐧 projeto nativo para app de desktop Linux
└── macos/                  # 🖥️ projeto nativo para app de desktop macOS
```

Regras de convivência com essa árvore:

1. **Você escreve quase 100% do tempo dentro de `lib/` e `test/`.**
2. As pastas `android/` e `ios/` você só toca quando for mexer em permissões, ícone, nome do app
   ou assinatura — módulos 14 e 15.
3. A pasta `build/` **não aparece acima porque ela só nasce depois do primeiro build**. Ela é
   descartável: `flutter clean` apaga tudo dela. Ela já vem no `.gitignore` e **nunca** deve ser
   versionada.
4. As pastas `web/`, `windows/`, `linux/` e `macos/` podem ser removidas do projeto se você não
   for usá-las — ou nem criadas, com `flutter create --platforms=android,ios nome_do_app`.

Essa estrutura é destrinchada aula por aula em
[modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md](modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md).

## 0.8 Como usar o terminal com segurança

O terminal executa exatamente o que você mandar, sem perguntar "tem certeza?". Adote estas sete
regras desde hoje:

1. **Saiba onde você está.** Antes de qualquer comando, confirme a pasta atual.

   **🪟 Windows (PowerShell)**
   ```powershell
   Get-Location
   ```

   **🖥️ macOS / 🐧 Linux (bash/zsh)**
   ```bash
   pwd
   ```

2. **Nunca cole um comando que você não entende.** Se não souber o que faz, pergunte, pesquise
   ou pule. Um comando copiado de um fórum pode apagar arquivos seus.

3. **Desconfie de comandos de remoção recursiva.** `Remove-Item -Recurse -Force` (Windows) e
   `rm -rf` (macOS/Linux) apagam pastas inteiras **sem lixeira**. Antes de rodar, confira o
   caminho caractere por caractere.

4. **`sudo` não existe no Windows.** Se um tutorial começa com `sudo`, ele é para macOS ou Linux.
   No macOS/Linux, `sudo` significa "execute como administrador" e vai pedir sua senha —
   use apenas quando o passo realmente exigir.

5. **Não rode o terminal como Administrador por padrão.** Só abra elevado quando o passo pedir
   explicitamente (por exemplo, instalar algo em `C:\Program Files`).

6. **Um comando por vez, lendo a saída.** Se o comando 1 falhou, o comando 2 vai falhar
   diferente e você perde o rastro.

7. **Depois de mudar variáveis de ambiente, feche e reabra o terminal.** O terminal lê essas
   variáveis quando abre; alterações feitas fora dele não valem na janela que já estava aberta.

Atalhos que economizam horas:

| Atalho | O que faz |
|---|---|
| <kbd>Tab</kbd> | Completa o nome do arquivo/pasta que você começou a digitar |
| <kbd>↑</kbd> / <kbd>↓</kbd> | Navega pelos comandos anteriores |
| <kbd>Ctrl</kbd>+<kbd>C</kbd> | Interrompe o comando que está rodando |
| <kbd>Ctrl</kbd>+<kbd>L</kbd> | Limpa a tela (no PowerShell também funciona `Clear-Host`) |

O módulo [00-git-e-terminal](modulos/00-git-e-terminal/README.md) aprofunda isso na aula
[01-o-terminal-sem-medo.md](modulos/00-git-e-terminal/01-o-terminal-sem-medo.md).

## 0.9 Como interpretar mensagens de erro

Mensagem de erro não é castigo: é o diagnóstico mais barato que existe. Aprenda a anatomia dela.

Um erro típico tem quatro partes:

```text
Error: The argument type 'String' can't be assigned to the parameter type 'int'.
   ↑ tipo do erro            ↑ o que exatamente está errado

lib/main.dart:12:18
   ↑ arquivo    ↑ linha
              ↑ coluna
```

Método de leitura, em ordem:

1. **Leia a PRIMEIRA linha de erro, não a última.** Ferramentas de build costumam despejar
   dezenas de linhas; a origem real quase sempre está no começo. Os erros seguintes são
   consequência.
2. **Localize o arquivo e a linha.** `lib/main.dart:12:18` significa: arquivo `lib/main.dart`,
   linha 12, coluna 18. No VS Code você pode clicar nesse trecho e ir direto.
3. **Traduza a frase, não decore.** "can't be assigned to the parameter type" quer dizer
   "você passou um tipo de valor onde se esperava outro".
4. **Distinga erro de compilação × erro de execução.** Erro de compilação impede o app de
   iniciar e cita arquivo/linha. Erro de execução aparece com o app já rodando, geralmente com
   uma ***stack trace*** (a "pilha de chamadas" — a lista de funções que estavam em andamento
   no momento da falha).
5. **Na stack trace, procure a primeira linha que cita um arquivo SEU** (algo com `lib/`).
   As linhas acima costumam ser de dentro do framework.
6. **Se a mensagem sugerir um comando, leia-o antes de rodar.** O Flutter frequentemente
   escreve a solução na própria mensagem — como no Problema 2 da Parte 1.

Erros recorrentes com texto real e correção estão catalogados em
[referencias/erros-comuns.md](referencias/erros-comuns.md). A aula
[modulos/01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md](modulos/01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md)
treina isso com exercícios.

---

# PARTE 1 — O SEU ambiente (diagnóstico real desta máquina)

Esta parte **não é hipotética**. Os dados abaixo foram medidos nesta máquina em **2026-09-14**,
e os três problemas listados foram **reproduzidos de fato** — o texto dos erros é literal.

## 1.1 Estado verificado

| Item | Estado verificado em 2026-09-14 |
|---|---|
| SO | Windows 11 Home Single Language 25H2 (build 10.0.26200) |
| Flutter | **3.47.1** stable · revision 6655482ec0 · 2026-08-19 |
| Dart | **3.13.1** (embutido no Flutter) |
| DevTools | 2.60.0 |
| Git | 2.46.0.windows.1 ✅ |
| JDK | Temurin OpenJDK 17.0.18 ✅ |
| VS Code | instalado em `%LOCALAPPDATA%\Programs\Microsoft VS Code` ✅ |
| Chrome | 152.x ✅ |
| Android Studio | ❌ **NÃO instalado** |
| Android SDK | ❌ **NÃO instalado** (`ANDROID_HOME` vazio) |
| macOS / Xcode | ❌ indisponível |
| Local do Flutter SDK | `C:\Users\Usuário\Documents\flutter` ⚠️ **PROBLEMÁTICO** |

Leitura do quadro: o **Flutter já está instalado e na versão certa**, o **Git e o JDK 17 já
estão prontos** e o **VS Code já existe**. Faltam três correções e uma instalação. É isso que
esta parte resolve.

---

## 1.2 ⚠️ Problema 1 — Acento no caminho do Flutter SDK

### O sintoma

O SDK está em `C:\Users\Usuário\Documents\flutter`. O acento em **Usuário** quebra ferramentas
internas do Flutter que não tratam UTF-8 corretamente no Windows.

Erro real reproduzido ao rodar `flutter doctor`:

```text
[☠] Flutter (the doctor check crashed)
    ✗ FileSystemException: Cannot resolve symbolic links,
      path = 'C:\Users\Usu rio\Documents\flutter\bin\flutter'
      (OS Error: O sistema não pode encontrar o caminho especificado, errno = 3)
```

Repare no detalhe revelador: o caminho aparece como `Usu rio` — a letra **á** virou um espaço.
A ferramenta leu os bytes do nome da pasta com a codificação errada e produziu um caminho que
não existe.

Erro real reproduzido ao compilar um app com Material 3:

```text
ShaderCompilerException: Shader compilation of
"C:\Users\Usuário\...\ink_sparkle.frag" failed with exit code 1.
'#include' : Included file not found. for header name: flutter/runtime_effect.glsl
```

(*Shader* é um pequeno programa que roda na placa de vídeo para desenhar efeitos visuais —
neste caso, o efeito de ondulação ao tocar um botão Material.)

E o **servidor de análise** (o processo que o VS Code usa para sublinhar erros enquanto você
digita, o mesmo que roda em `flutter analyze`) **encerra com código 255** — ou seja, morre.

### A causa

Três programas distintos dentro do Flutter — o `doctor`, o compilador de *shaders* e o
*analysis server* — resolvem caminhos usando APIs que assumem a página de código ANSI do Windows
em vez de UTF-8. Qualquer caractere fora do ASCII (acentos, cedilha, til) no caminho do SDK
dispara a falha. Espaços no caminho causam problemas parecidos em scripts Gradle.

### A correção: mover o SDK para `C:\src\flutter`

> A pasta de destino recomendada é `C:\src\flutter`: sem acento, sem espaço, curta (caminhos
> longos são outro limite histórico do Windows) e fora de `C:\Program Files` (que exige
> privilégio de administrador para escrita, e o Flutter escreve na própria pasta ao se atualizar).

**Passo 1 — feche tudo que esteja usando o SDK.** Feche o VS Code, o Android Studio e **todos**
os terminais abertos. Se um processo `dart.exe` estiver segurando um arquivo, a movimentação
falha no meio e deixa o SDK quebrado.

**Passo 2 — crie a pasta de destino.**

**🪟 Windows (PowerShell)**
```powershell
New-Item -ItemType Directory -Force -Path C:\src
```

**Passo 3 — mova o SDK inteiro.**

**🪟 Windows (PowerShell)**
```powershell
Move-Item -Path "$env:USERPROFILE\Documents\flutter" -Destination "C:\src\flutter"
```

`$env:USERPROFILE` é a variável de ambiente que guarda o caminho da sua pasta de usuário. Usá-la
em vez de digitar `C:\Users\Usuário` evita justamente o problema do acento **no comando**.

**Passo 4 — confirme que o conteúdo chegou.**

**🪟 Windows (PowerShell)**
```powershell
Test-Path C:\src\flutter\bin\flutter.bat
```

Saída esperada:
```text
True
```

Se vier `False`, a movimentação não terminou: verifique se a pasta antiga ainda existe em
`Documents` e repita o Passo 3 com todos os programas fechados.

**Passo 5 — corrija o PATH do usuário.**

O **PATH** é a variável de ambiente que lista as pastas onde o sistema procura por programas
executáveis quando você digita um nome no terminal. Quando você digita `flutter`, o Windows
percorre as pastas do PATH, em ordem, até encontrar um `flutter.bat`. Se o PATH ainda apontar
para `Documents\flutter`, você vai continuar rodando o SDK antigo (ou nenhum).

O comando abaixo lê o PATH **do usuário**, remove qualquer entrada que contenha
`Documents\flutter` e acrescenta `C:\src\flutter\bin`:

**🪟 Windows (PowerShell)**
```powershell
$antigo = [Environment]::GetEnvironmentVariable('Path', 'User')
$limpo  = ($antigo -split ';' | Where-Object { $_ -and $_ -notlike '*Documents\flutter*' }) -join ';'
$novo   = $limpo.TrimEnd(';') + ';C:\src\flutter\bin'
[Environment]::SetEnvironmentVariable('Path', $novo, 'User')
```

Linha por linha:
- `GetEnvironmentVariable('Path', 'User')` lê o PATH do **seu usuário** (não o do sistema
  inteiro, que exigiria administrador).
- `-split ';'` quebra o texto em uma lista de pastas, porque no Windows o separador é `;`.
- `Where-Object { $_ -and $_ -notlike '*Documents\flutter*' }` mantém só as entradas que **não
  são vazias** e que **não apontam** para o local antigo.
- `-join ';'` remonta o texto.
- `SetEnvironmentVariable(..., 'User')` grava de volta, de forma permanente.

**Passo 6 — feche o PowerShell e abra uma janela nova.** Sem isso, a janela atual continua com
o PATH velho em memória.

**Passo 7 — valide.**

**🪟 Windows (PowerShell)**
```powershell
Get-Command flutter | Select-Object -ExpandProperty Source
```

Saída esperada:
```text
C:\src\flutter\bin\flutter.bat
```

Se aparecer qualquer caminho contendo `Documents`, o PATH não foi atualizado ou a janela não foi
reaberta.

**Passo 8 — confirme a versão e rode o doctor.**

**🪟 Windows (PowerShell)**
```powershell
flutter --version
flutter doctor
```

Saída esperada da primeira linha de `flutter --version`:
```text
Flutter 3.47.1 • channel stable
```

E o `flutter doctor` **não deve mais mostrar** `[☠] Flutter (the doctor check crashed)`.

**Passo 9 — limpe projetos antigos.** Projetos criados enquanto o SDK estava no caminho velho
guardam referências ao caminho antigo em `.dart_tool/`. Dentro de cada projeto:

**🪟 Windows (PowerShell)**
```powershell
flutter clean
flutter pub get
```

### Teste objetivo de que o Problema 1 acabou

- [ ] `Get-Command flutter` retorna `C:\src\flutter\bin\flutter.bat`
- [ ] `flutter doctor` roda inteiro sem `the doctor check crashed`
- [ ] `flutter analyze` dentro de um projeto termina com `No issues found!` (ou lista problemas
      reais do seu código) — e **não** com código 255
- [ ] Um app com botões Material compila sem `ShaderCompilerException`

---

## 1.3 ⚠️ Problema 2 — Modo de Desenvolvedor do Windows desligado

### O sintoma

Erro real reproduzido ao rodar `flutter pub add` em um projeto que usa plugins:

```text
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings. Run
  start ms-settings:developers
to open settings.
```

### A causa

Um ***symlink*** (*symbolic link*, "link simbólico") é um atalho no nível do sistema de arquivos:
um caminho que aponta para outro caminho, e que os programas enxergam como se fosse o arquivo de
verdade. O Flutter cria symlinks dentro de `.dart_tool/` e das pastas nativas para ligar o seu
projeto ao código dos plugins, sem copiar tudo.

No Windows, criar symlink é uma operação privilegiada por padrão. O **Modo de Desenvolvedor**
libera essa permissão para o seu usuário sem precisar rodar tudo como administrador.

### A correção

**Passo 1 — abra a tela certa das Configurações.** O próprio Flutter já te deu o comando:

**🪟 Windows (PowerShell)**
```powershell
start ms-settings:developers
```

Isso abre **Configurações → Sistema → Para desenvolvedores** diretamente.

**Passo 2 — ligue a chave "Modo de desenvolvedor".** O Windows vai exibir um aviso dizendo que
o modo permite instalar apps de qualquer origem. Confirme em **Sim**.

**Passo 3 — feche e reabra o terminal.**

**Passo 4 — valide.** Em um projeto Flutter qualquer:

**🪟 Windows (PowerShell)**
```powershell
flutter pub get
```

### Teste objetivo de que o Problema 2 acabou

- [ ] Em **Configurações → Sistema → Para desenvolvedores**, "Modo de desenvolvedor" está
      **Ativado**
- [ ] `flutter pub get` em um projeto com plugins termina sem a mensagem
      `Building with plugins requires symlink support`
- [ ] `flutter doctor` não lista aviso de *Developer Mode* na seção do Windows

> 🖥️🐧 **macOS e Linux não têm esse problema.** Nesses sistemas, criar link simbólico é uma
> operação comum, sem permissão especial.

---

## 1.4 ⚠️ Problema 3 — Android SDK ausente

### O sintoma

Saída real do `flutter doctor` nesta máquina:

```text
[X] Android toolchain - develop for Android devices
    X Unable to locate Android SDK.
```

A variável de ambiente `ANDROID_HOME` está vazia e o Android Studio não está instalado.

### A causa

O **Android SDK** é o conjunto de bibliotecas, compiladores e utilitários do Android. Sem ele o
Flutter não tem como compilar o projeto `android/` do seu app, nem falar com um aparelho, nem
subir um emulador. O Flutter **não traz o Android SDK embutido** — ele é um download separado
do Google.

### A correção (resumo — o passo a passo completo está na Parte 2)

1. Instalar o **Android Studio** (é ele quem instala e gerencia o Android SDK).
2. Abrir o **SDK Manager** e instalar: *Android SDK Platform*, *Android SDK Command-line Tools*,
   *Android SDK Build-Tools*, *Android SDK Platform-Tools* e *Android Emulator*.
3. Aceitar as licenças:

   **🪟 Windows (PowerShell)**
   ```powershell
   flutter doctor --android-licenses
   ```

4. Conferir com `flutter doctor`.

### Teste objetivo de que o Problema 3 acabou

- [ ] `flutter doctor` mostra `[✓] Android toolchain - develop for Android devices`
- [ ] A linha `All Android licenses accepted.` aparece
- [ ] `adb devices` executa (mesmo que a lista venha vazia)

---

## 1.5 Sua ordem de execução nesta máquina

Faça exatamente nesta sequência. Cada passo depende do anterior.

| Ordem | O que fazer | Onde está |
|---|---|---|
| 1 | Mover o Flutter SDK para `C:\src\flutter` e corrigir o PATH | [1.2](#12--problema-1--acento-no-caminho-do-flutter-sdk) |
| 2 | Ativar o Modo de Desenvolvedor do Windows | [1.3](#13--problema-2--modo-de-desenvolvedor-do-windows-desligado) |
| 3 | Instalar as extensões Dart e Flutter no VS Code | [2.4](#24-vs-code--extensões-dart-e-flutter) |
| 4 | Instalar o Android Studio | [2.5](#25-android-studio) |
| 5 | Instalar componentes do Android SDK | [2.6](#26-android-sdk-platform-tools-build-tools-e-emulador) |
| 6 | Aceitar licenças do Android | [2.7](#27-aceitação-de-licenças) |
| 7 | Criar e testar um emulador | [Parte 3](#parte-3--emulador-e-aparelho-físico-android) |
| 8 | Rodar `flutter doctor` até ficar limpo | [Parte 4](#parte-4--flutter-doctor-linha-por-linha) |
| 9 | Criar e rodar o primeiro projeto | [Parte 5](#parte-5--primeiro-projeto) |

Git (2.46.0) e JDK 17 (Temurin 17.0.18) **já estão instalados** aqui — pule 2.1 e 2.8 e use-os
apenas como referência.

---

# PARTE 2 — Instalação do zero

> Esta parte assume que **nada** está instalado. Se você está seguindo a
> [Parte 1](#15-sua-ordem-de-execução-nesta-máquina), pule os itens já verdes na tabela 1.1.

Cada item traz: **comando**, **saída esperada** e **teste objetivo**.

---

## 2.1 Git

**Git** é o sistema de controle de versão: ele guarda o histórico do seu código, permite voltar
atrás e trabalhar em paralelo. O Flutter **depende** do Git — o próprio SDK é um repositório Git,
e é por ele que `flutter upgrade` funciona.

**🪟 Windows**
1. Baixe o instalador em <https://git-scm.com/downloads>.
2. Execute e aceite as opções padrão. Na tela *Adjusting your PATH environment*, mantenha a opção
   recomendada **"Git from the command line and also from 3rd-party software"** — é ela que
   coloca o `git` no PATH.

```powershell
git --version
```

**🖥️ macOS**
```bash
git --version
```
Se o Git não estiver presente, o macOS abre uma janela oferecendo instalar as *Command Line
Tools*. Aceite. (Você vai instalá-las de qualquer forma na [Parte 6](#63-command-line-tools).)

**🐧 Linux (Debian/Ubuntu)**
```bash
sudo apt update
sudo apt install -y git
git --version
```

**Saída esperada (qualquer sistema), no formato:**
```text
git version 2.46.0.windows.1
```

**Teste objetivo:** `git --version` imprime uma versão **2.46 ou superior**.

Depois de instalar, configure sua identidade (isso vai em todo commit que você fizer):

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

O uso de Git é ensinado no módulo [00-git-e-terminal](modulos/00-git-e-terminal/README.md).

---

## 2.2 Flutter SDK

### O que exatamente você está baixando

Um arquivo compactado com a pasta `flutter/` inteira: compilador Dart, framework, ferramentas de
linha de comando e um repositório Git. Não há "instalador" tradicional — você **descompacta e
coloca no PATH**.

### 🪟 Windows

**Passo 1 — baixe.** Vá a <https://docs.flutter.dev/get-started/install/windows> e baixe o
arquivo `.zip` do canal **stable**, versão **3.47.1**.

**Passo 2 — descompacte em um caminho sem acento e sem espaço.**

```powershell
New-Item -ItemType Directory -Force -Path C:\src
Expand-Archive -Path "$env:USERPROFILE\Downloads\<nome-do-arquivo-baixado>.zip" -DestinationPath C:\src
```

Substitua `<nome-do-arquivo-baixado>` pelo nome real do `.zip` que você baixou. O resultado deve
ser a pasta `C:\src\flutter`.

> ⚠️ **Não descompacte em `C:\Program Files`** (exige administrador para escrita, e o Flutter
> escreve na própria pasta ao atualizar) **nem em `Documents`, `Desktop` ou `OneDrive`**
> (acentos, espaços e sincronização em nuvem quebram o build — veja o
> [Problema 1](#12--problema-1--acento-no-caminho-do-flutter-sdk)).

**Passo 3 — acrescente ao PATH.**

```powershell
$antigo = [Environment]::GetEnvironmentVariable('Path', 'User')
[Environment]::SetEnvironmentVariable('Path', $antigo.TrimEnd(';') + ';C:\src\flutter\bin', 'User')
```

**Passo 4 — feche e reabra o PowerShell** e valide:

```powershell
flutter --version
```

### 🖥️ macOS

**Passo 1 — baixe** o `.zip` de <https://docs.flutter.dev/get-started/install/macos>, escolhendo
a arquitetura certa: **Apple Silicon** (chips M1/M2/M3/M4) ou **Intel**.

**Passo 2 — descompacte em uma pasta de desenvolvimento:**
```bash
mkdir -p ~/development
cd ~/development
unzip ~/Downloads/<nome-do-arquivo-baixado>.zip
```

**Passo 3 — acrescente ao PATH.** No macOS moderno o shell padrão é o `zsh`, e o arquivo de
configuração é `~/.zshrc`:
```bash
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Passo 4 — valide:**
```bash
which flutter
flutter --version
```

### 🐧 Linux

**Passo 1 — instale as dependências do sistema** (bibliotecas que o Flutter precisa para
compilar e rodar ferramentas):
```bash
sudo apt update
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa
```

**Passo 2 — baixe** o `.tar.xz` de <https://docs.flutter.dev/get-started/install/linux> e
descompacte:
```bash
mkdir -p ~/development
cd ~/development
tar -xf ~/Downloads/<nome-do-arquivo-baixado>.tar.xz
```

**Passo 3 — acrescente ao PATH** (no `bash`, o arquivo é `~/.bashrc`):
```bash
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Passo 4 — valide:**
```bash
which flutter
flutter --version
```

### Saída esperada (os três sistemas)

```text
Flutter 3.47.1 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 6655482ec0 (2026-08-19)
Engine • revision ...
Tools • Dart 3.13.1 • DevTools 2.60.0
```

**Teste objetivo:** `flutter --version` imprime `Flutter 3.47.1` e `Dart 3.13.1`.

---

## 2.3 PATH — entendendo de verdade

Esse conceito derruba mais gente do que qualquer código. Vale uma seção própria.

### O que é

**PATH** é uma variável de ambiente que contém uma **lista ordenada de pastas**. Quando você
digita `flutter` no terminal e pressiona <kbd>Enter</kbd>, o sistema operacional:

1. Verifica se `flutter` é um comando interno do próprio shell. Não é.
2. Percorre as pastas do PATH **na ordem em que aparecem**.
3. Na primeira pasta em que encontrar um executável chamado `flutter`
   (`flutter.bat` no Windows, `flutter` no macOS/Linux), **para** e executa aquele.
4. Se terminar a lista sem achar, devolve erro.

O erro do passo 4:

**🪟 Windows (PowerShell)**
```text
flutter : O termo 'flutter' não é reconhecido como nome de cmdlet, função,
arquivo de script ou programa operável.
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**
```text
bash: flutter: command not found
```

**Os dois erros significam a mesma coisa:** "a pasta que contém o executável não está no PATH".
Eles **não** significam que o Flutter não foi instalado.

### Detalhes que causam confusão

| Detalhe | 🪟 Windows | 🖥️🐧 macOS / Linux |
|---|---|---|
| Separador entre pastas | ponto e vírgula `;` | dois-pontos `:` |
| Escopos | PATH do **usuário** + PATH do **sistema** (concatenados) | um por shell, definido em `~/.zshrc` / `~/.bashrc` |
| Onde alterar permanentemente | `[Environment]::SetEnvironmentVariable(..., 'User')` ou "Editar as variáveis de ambiente do sistema" | linha `export PATH=...` no arquivo de configuração do shell |
| Vale na janela já aberta? | ❌ Não. Feche e reabra. | ❌ Não, a menos que você rode `source ~/.zshrc` |

### Como inspecionar

**🪟 Windows (PowerShell)** — mostra uma pasta por linha:
```powershell
$env:Path -split ';'
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**
```bash
echo $PATH | tr ':' '\n'
```

### Como descobrir QUAL flutter está sendo usado

Se você tem duas cópias do SDK no disco (acontece mais do que parece), é a ordem do PATH que
decide qual vence:

**🪟 Windows (PowerShell)**
```powershell
Get-Command flutter | Select-Object -ExpandProperty Source
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**
```bash
which flutter
```

**Teste objetivo do PATH:** o caminho devolvido acima é exatamente o SDK que você quer usar, e
`flutter --version` bate com a versão esperada.

---

## 2.4 VS Code + extensões Dart e Flutter

**VS Code** é o editor recomendado neste curso: leve, gratuito, com excelente suporte a Flutter.

**🪟 Windows** — baixe em <https://code.visualstudio.com/> e instale. Na tela de opções
adicionais, marque **"Adicionar em PATH"**.

**🖥️ macOS** — baixe o `.zip` no mesmo endereço, arraste `Visual Studio Code.app` para
`/Applications`, abra o VS Code, pressione <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> e execute
**Shell Command: Install 'code' command in PATH**.

**🐧 Linux** — baixe o `.deb` (Debian/Ubuntu) no mesmo endereço e instale:
```bash
sudo apt install -y ./<nome-do-arquivo-baixado>.deb
```

### Extensões obrigatórias

Abra o VS Code, clique no ícone de **Extensões** na barra lateral (ou pressione
<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd>, <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd> no
Mac) e instale, nesta ordem:

1. **Flutter** (publicada por *Dart Code*) — instala automaticamente a extensão **Dart** junto.
2. Confirme que **Dart** (publicada por *Dart Code*) aparece como instalada.

O que essas extensões te dão:
- Sublinhado de erro enquanto você digita (via *analysis server*).
- Autocompletar de widgets e parâmetros.
- Botão de **hot reload** e o depurador integrado (<kbd>F5</kbd>).
- Formatação automática com `dart format`.
- Lista de dispositivos no canto inferior direito da janela.

### Teste objetivo

1. Abra a paleta de comandos (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>).
2. Digite `Flutter: Run Flutter Doctor` e execute.
3. Saída esperada: a aba **OUTPUT** abre e mostra o relatório do doctor.

Se a extensão não encontrar o SDK, abra as configurações e defina `dart.flutterSdkPath` para
`C:\src\flutter` (🪟) ou `~/development/flutter` (🖥️🐧).

### Alternativa: Android Studio como IDE

O **Android Studio** também é uma IDE completa para Flutter. Instale por
**File → Settings → Plugins** (🪟🐧) ou **Android Studio → Settings → Plugins** (🖥️) e procure
por **Flutter** — o plugin **Dart** vem junto.

| | VS Code | Android Studio |
|---|---|---|
| Consumo de memória | Baixo | Alto |
| Velocidade para abrir | Rápido | Lento |
| Editor de layout visual | Não tem | Tem (*Flutter Inspector* embutido, também disponível no VS Code) |
| Gerenciar SDK/emuladores | Não | ✅ Sim — é a ferramenta oficial |
| Editar código Kotlin/Java nativo | Limitado | ✅ Excelente |

**Recomendação do curso:** escreva no **VS Code**, use o **Android Studio** para gerenciar SDK e
emuladores. Você vai instalar os dois de qualquer jeito.

---

## 2.5 Android Studio

O Android Studio é a IDE oficial do Google para Android. Mesmo que você não escreva uma linha
nele, é por ele que se instalam o **Android SDK** e o **emulador**.

**🪟 Windows**
1. Baixe em <https://developer.android.com/studio>.
2. Execute o instalador e siga o assistente com as opções padrão.
3. Na primeira abertura, escolha o tipo de instalação **Standard** e aceite as licenças
   apresentadas.

**🖥️ macOS**
1. Baixe o `.dmg` no mesmo endereço.
2. Arraste **Android Studio** para `/Applications` e abra.
3. Escolha **Standard** e aceite as licenças.

**🐧 Linux**
1. Baixe o `.tar.gz` no mesmo endereço e descompacte em `~/android-studio`.
2. Rode o script de inicialização:
```bash
~/android-studio/bin/studio.sh
```
3. Escolha **Standard** e aceite as licenças.

**Saída esperada:** a janela de boas-vindas (*Welcome to Android Studio*) abre e a barra de
progresso da primeira sincronização termina sem erro.

**Teste objetivo:** o Android Studio abre e o menu **More Actions → SDK Manager** existe.

Depois disso, informe ao Flutter onde o Android Studio está, se ele não detectar sozinho:

**🪟 Windows (PowerShell)**
```powershell
flutter doctor -v
```
A linha `Android Studio at ...` deve aparecer no relatório.

---

## 2.6 Android SDK, Platform-Tools, Build-Tools e emulador

Abra o Android Studio → na tela de boas-vindas, **More Actions → SDK Manager**
(ou, com um projeto aberto: **Tools → SDK Manager**).

### Aba "SDK Platforms"

Marque a caixa **Show Package Details** no canto inferior direito e selecione, da versão de
Android mais recente disponível:

| Componente | Para que serve |
|---|---|
| **Android SDK Platform** | As bibliotecas da versão do Android contra a qual seu app é compilado |
| **Google APIs Intel x86_64 System Image** ou **Google Play Intel x86_64 System Image** | A "imagem de sistema" — o Android que roda dentro do emulador. Escolha a que combina com o processador da sua máquina (x86_64 em PCs Intel/AMD; ARM em Macs Apple Silicon). A variante *Google Play* traz a Play Store dentro do emulador. |

### Aba "SDK Tools"

Marque **Show Package Details** e selecione:

| Componente | Para que serve |
|---|---|
| **Android SDK Build-Tools** | Compiladores e empacotadores que transformam seu código e recursos em APK/AAB (`aapt2`, `d8`, `zipalign`, `apksigner`) |
| **Android SDK Platform-Tools** | Os utilitários que conversam com o aparelho — principalmente o **`adb`** (*Android Debug Bridge*, a ponte de depuração do Android) |
| **Android SDK Command-line Tools (latest)** | Ferramentas de linha de comando, entre elas o `sdkmanager`. **O `flutter doctor --android-licenses` depende deste componente** — se faltar, ele falha |
| **Android Emulator** | O emulador em si |
| **Android Emulator hypervisor driver** (🪟 apenas em processadores Intel) | Aceleração por hardware do emulador. Em máquinas AMD ou com Hyper-V ativo, use o WHPX (veja [3.2](#32-virtualização-bios-hyper-v-e-whpx)) |

Clique em **Apply** → **OK** e aguarde o download. São alguns gigabytes.

### Onde o SDK fica instalado

| Sistema | Caminho padrão |
|---|---|
| 🪟 Windows | `%LOCALAPPDATA%\Android\Sdk` |
| 🖥️ macOS | `~/Library/Android/sdk` |
| 🐧 Linux | `~/Android/Sdk` |

O caminho exato aparece no topo do SDK Manager, no campo **Android SDK Location**. Anote-o.

### Configurar as variáveis de ambiente

**`ANDROID_HOME`** é a variável que aponta para a pasta do Android SDK. Várias ferramentas
(inclusive o Gradle) a consultam.

**🪟 Windows (PowerShell)**
```powershell
$sdk = "$env:LOCALAPPDATA\Android\Sdk"
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdk, 'User')
$antigo = [Environment]::GetEnvironmentVariable('Path', 'User')
[Environment]::SetEnvironmentVariable('Path', $antigo.TrimEnd(';') + ";$sdk\platform-tools", 'User')
```

**🖥️ macOS (zsh)**
```bash
echo 'export ANDROID_HOME="$HOME/Library/Android/sdk"' >> ~/.zshrc
echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**🐧 Linux (bash)**
```bash
echo 'export ANDROID_HOME="$HOME/Android/Sdk"' >> ~/.bashrc
echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Feche e reabra o terminal.

### Se o Flutter ainda não achar o SDK

O Flutter guarda uma configuração própria. Aponte o caminho explicitamente:

**🪟 Windows (PowerShell)**
```powershell
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**
```bash
flutter config --android-sdk "$ANDROID_HOME"
```

### Teste objetivo

```bash
adb --version
flutter doctor
```

Saída esperada de `adb --version`, no formato:
```text
Android Debug Bridge version 1.0.41
```

E o `flutter doctor` deve deixar de exibir `Unable to locate Android SDK.`

---

## 2.7 Aceitação de licenças

O Google exige que você aceite, uma vez por máquina, as licenças de cada componente do SDK.
Enquanto não aceitar, o `flutter doctor` mostra:

```text
[!] Android toolchain - develop for Android devices
    ! Some Android licenses not accepted. To resolve this, run:
      flutter doctor --android-licenses
```

**🪟 Windows (PowerShell)**
```powershell
flutter doctor --android-licenses
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**
```bash
flutter doctor --android-licenses
```

O comando apresenta os termos um a um e pergunta:

```text
Accept? (y/N):
```

Digite **`y`** e pressione <kbd>Enter</kbd> para cada um. Ao final:

```text
All SDK package licenses accepted.
```

**Teste objetivo:** rodar `flutter doctor` e ver a linha
`[✓] Android toolchain - develop for Android devices`.

> ⚠️ Se o comando falhar dizendo que não encontra o `sdkmanager`, você não instalou
> **Android SDK Command-line Tools (latest)** na aba *SDK Tools*. Volte a [2.6](#26-android-sdk-platform-tools-build-tools-e-emulador).

---

## 2.8 JDK 17 — e por que a versão importa

**JDK** (*Java Development Kit*) é o kit de desenvolvimento da linguagem Java. Você não vai
escrever Java neste curso — mas o **build do Android é feito pelo Gradle**, que roda sobre a
máquina virtual Java. Sem JDK, nenhum APK sai.

### Por que exatamente a versão 17

- O **AGP** (*Android Gradle Plugin*, o plugin que ensina o Gradle a compilar um projeto Android)
  usado pelo Flutter 3.47 exige **JDK 17** como mínimo.
- **JDK 8 e 11 são antigos demais** — o AGP moderno recusa e o build falha com mensagens sobre
  versão de *class file*.
- Versões **mais novas que a suportada** também quebram: o Gradle precisa conhecer o formato de
  bytecode da JDK, e uma JDK lançada depois da versão do Gradle causa erros como
  `Unsupported class file major version`.
- Resumo: **não é "quanto mais novo, melhor"**. É "a versão que a cadeia de ferramentas espera".
  Neste curso: **JDK 17 (Temurin)**.

### Instalação

**🪟 Windows** — baixe o instalador **Temurin 17 (LTS)** em <https://adoptium.net/> e execute.
Na tela de componentes, marque **"Set JAVA_HOME variable"**.

**🖥️ macOS** — baixe o `.pkg` do Temurin 17 no mesmo endereço e instale. Depois:
```bash
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
source ~/.zshrc
```

**🐧 Linux (Debian/Ubuntu)**
```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
```

### Teste objetivo

```bash
java -version
```

Saída esperada, no formato:
```text
openjdk version "17.0.18" 2026-...
OpenJDK Runtime Environment Temurin-17.0.18 (build 17.0.18+...)
```

E, no Windows, confira que o `JAVA_HOME` foi definido:

**🪟 Windows (PowerShell)**
```powershell
$env:JAVA_HOME
```

Saída esperada: um caminho terminado em algo como `\jdk-17...`.

> 💡 O Android Studio também traz uma JDK embutida (**JBR**, *JetBrains Runtime*). Ter a Temurin
> 17 instalada separadamente evita que os builds pela linha de comando e pela IDE usem JDKs
> diferentes — uma fonte clássica de "funciona no Android Studio mas não no terminal".

---

# PARTE 3 — Emulador e aparelho físico Android

## 3.1 Criando e configurando um AVD

**AVD** (*Android Virtual Device*, "dispositivo virtual Android") é a definição de um celular
virtual: modelo, versão do Android, memória, tamanho de tela. O emulador roda um AVD.

**Passo 1.** Abra o Android Studio → **More Actions → Virtual Device Manager**
(em versões com projeto aberto: **Tools → Device Manager**).

**Passo 2.** Clique em **Create Device** / no ícone **+**.

**Passo 3 — escolha o hardware.** Selecione um telefone da categoria **Phone**. Recomendação:
um modelo **Pixel** recente. Motivo: os Pixel usam a densidade de tela e as proporções mais
comuns, e recebem imagens de sistema oficiais bem testadas.

**Passo 4 — escolha a imagem de sistema.** É a versão do Android que vai rodar dentro.

| Decisão | Recomendação |
|---|---|
| Versão do Android | Uma versão recente e estável — a mesma que você marcou no SDK Manager |
| Arquitetura | **x86_64** em PCs Intel/AMD · **arm64-v8a** em Macs Apple Silicon. Usar a arquitetura do seu próprio processador é o que permite a aceleração por hardware; imagem ARM em PC roda por tradução e fica lentíssima |
| Variante | **Google APIs** (sem loja) para o dia a dia · **Google Play** se você precisar da Play Store dentro do emulador |

Clique em **Download** ao lado da imagem escolhida, se ela ainda não estiver baixada.

**Passo 5 — configure.** Clique em **Show Advanced Settings** e ajuste:

| Campo | Valor sugerido | Por quê |
|---|---|---|
| **AVD Name** | `Pixel_API_Curso` | Sem espaços e sem acento — o nome vira pasta no disco e é usado pelo comando `flutter emulators --launch` |
| **RAM** | 2048 MB (2 GB) | Menos que isso o Android fica lento; muito mais engasga a máquina hospedeira |
| **VM heap** | 256 MB | Memória que a máquina virtual Java do Android pode usar |
| **Internal Storage** | 2048 MB | Espaço para instalar seus apps de teste |
| **Graphics** | **Hardware - GLES 2.0** | Usa a sua placa de vídeo para desenhar. A opção *Software* funciona sem GPU, mas é várias vezes mais lenta |
| **Multi-Core CPU** | 2 a 4 núcleos | Nunca todos os núcleos da máquina |
| **Enable Device Frame** | opcional | Só cosmético (desenha a moldura do celular) |

Clique em **Finish**.

**Passo 6 — inicie.** No Device Manager, clique no botão ▶ ao lado do AVD.

**Teste objetivo:** a janela do emulador abre e chega até a tela inicial do Android.

Pela linha de comando:

```bash
flutter emulators
```

Saída esperada, no formato:
```text
1 available emulator:

Pixel_API_Curso • Pixel API Curso • Google • android
```

E para iniciar sem abrir o Android Studio:
```bash
flutter emulators --launch Pixel_API_Curso
```

---

## 3.2 Virtualização: BIOS, Hyper-V e WHPX

Se o emulador não abre, fica preto ou reclama de aceleração, o problema quase sempre é
**virtualização de hardware desligada**.

### O que é

Processadores modernos têm instruções especiais (**Intel VT-x** ou **AMD-V**, também chamada
**SVM**) que permitem rodar um sistema operacional inteiro dentro de outro com desempenho quase
nativo. Sem isso, o emulador precisa **traduzir** cada instrução do Android por software — e
fica inutilizável.

### 🪟 Passo 1 — verifique se está ligada

Abra o **Gerenciador de Tarefas** (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Esc</kbd>) →
aba **Desempenho** → **CPU**. Procure a linha **Virtualização**.

- `Virtualização: Habilitada` → está ligada, pule para o Passo 3.
- `Virtualização: Desabilitada` → siga o Passo 2.

Alternativa por comando:

**🪟 Windows (PowerShell)**
```powershell
systeminfo
```
Procure, no final da saída, a seção **Requisitos do Hyper-V**.

### 🪟 Passo 2 — ligue na BIOS/UEFI

1. Reinicie o computador.
2. Durante a inicialização, pressione a tecla de entrada na BIOS/UEFI — costuma ser
   <kbd>Del</kbd>, <kbd>F2</kbd>, <kbd>F10</kbd> ou <kbd>F12</kbd>, e a tela de inicialização
   informa qual é.
3. Procure, geralmente em **Advanced** ou **CPU Configuration**, uma destas opções:
   - Intel: **Intel Virtualization Technology** ou **Intel VT-x**
   - AMD: **SVM Mode** ou **AMD-V**
4. Mude para **Enabled**.
5. Salve e saia (normalmente <kbd>F10</kbd>).

> ⚠️ Cada fabricante de placa-mãe organiza a BIOS de um jeito. Se não achar a opção, procure o
> manual do seu modelo. **Não altere outras opções da BIOS por tentativa e erro.**

### 🪟 Passo 3 — escolha a camada de aceleração no Windows

O Windows oferece duas formas, e **elas competem entre si**:

| Camada | O que é | Quando usar |
|---|---|---|
| **Android Emulator hypervisor driver** | Driver próprio do Google, instalado pelo SDK Manager | Processadores **Intel**, com Hyper-V **desligado** |
| **WHPX** (*Windows Hypervisor Platform*) | Camada do próprio Windows sobre o Hyper-V | Processadores **AMD**, ou máquinas que já usam Hyper-V / WSL2 / Docker Desktop |

**Como ativar o WHPX:**
1. Pressione <kbd>Win</kbd>, digite **Ativar ou desativar recursos do Windows** e abra.
2. Marque **Plataforma do Hipervisor do Windows**.
3. Se você usa WSL2 ou Docker, marque também **Hyper-V** (quando disponível na sua edição do
   Windows) e **Plataforma de Máquina Virtual**.
4. Clique em **OK** e **reinicie o computador**.

> 🖥️ **macOS:** a aceleração usa o *Hypervisor.framework* do próprio sistema. Não há nada a
> ligar — funciona por padrão.
>
> 🐧 **Linux:** a aceleração usa o **KVM**. Verifique com:
> ```bash
> ls -l /dev/kvm
> ```
> Se o arquivo não existir, ative a virtualização na BIOS. Se existir mas der erro de permissão,
> adicione seu usuário ao grupo `kvm` e reinicie a sessão.

**Teste objetivo:** o emulador abre até a tela inicial do Android em menos de um minuto e a
interface responde ao mouse sem travamentos.

---

## 3.3 Aparelho físico Android: Opções do desenvolvedor e Depuração USB

Rodar no aparelho de verdade é sempre mais fiel que o emulador — e no seu caso, mais rápido.

### Passo 1 — ative as Opções do desenvolvedor

No celular Android:

1. Abra **Configurações**.
2. Vá em **Sobre o telefone** (em alguns aparelhos: **Sistema → Sobre o telefone**).
3. Encontre **Número da versão** (*Build number*). Em aparelhos Samsung/Xiaomi pode estar em
   **Informações de software**.
4. **Toque 7 vezes seguidas** nesse item.
5. Digite o PIN/senha do aparelho, se pedido.
6. Aparece a mensagem: **"Você agora é um desenvolvedor!"**

### Passo 2 — ative a Depuração USB

1. Volte para **Configurações → Sistema → Opções do desenvolvedor** (a localização varia;
   em alguns aparelhos fica direto em **Configurações → Opções do desenvolvedor**).
2. Ligue a chave **Opções do desenvolvedor** no topo.
3. Ligue **Depuração USB** (*USB debugging*).
4. Confirme no aviso que aparece.

> 💡 Em aparelhos **Xiaomi/Redmi/POCO**, ligue também **Instalação via USB**. Sem isso o
> `flutter run` falha ao instalar o APK.

### Passo 3 — conecte e autorize

1. Conecte o celular ao computador com um **cabo USB que transmita dados**. Muitos cabos baratos
   só carregam. Se o computador não reconhecer o aparelho, troque o cabo antes de qualquer outra
   coisa.
2. Na notificação de USB do celular, escolha o modo **Transferência de arquivos (MTP)**.
3. No celular vai aparecer um diálogo: **"Permitir depuração USB?"** com a impressão digital
   (*fingerprint*) da chave RSA do seu computador.
4. Marque **"Sempre permitir deste computador"** e toque em **Permitir**.

### Passo 4 — confirme com o adb

O **`adb`** (*Android Debug Bridge*) é o programa que conversa com o aparelho: instala apps,
lê logs, encaminha portas.

```bash
adb devices
```

Saída esperada quando **está autorizado**:
```text
List of devices attached
R58N70XXXXX     device
```

Saídas problemáticas e o que significam:

| Saída | Significado | Correção |
|---|---|---|
| `List of devices attached` (vazio) | O computador não vê o aparelho | Troque o cabo; troque de porta USB; confira o modo MTP; 🪟 instale o driver USB do fabricante |
| `R58N70XXXXX   unauthorized` | O aparelho vê o PC mas você não autorizou | Desbloqueie a tela do celular e aceite o diálogo "Permitir depuração USB?" |
| `R58N70XXXXX   offline` | Conexão travada | Rode `adb kill-server` e depois `adb start-server` |

Comandos de reinício da ponte:
```bash
adb kill-server
adb start-server
adb devices
```

Se o diálogo de autorização não aparece mais (porque você negou antes), vá em
**Opções do desenvolvedor → Revogar autorizações de depuração USB**, desconecte e reconecte.

### Passo 5 — confirme pelo Flutter

```bash
flutter devices
```

Saída esperada, no formato (os nomes variam conforme o que você tem conectado):
```text
Found 3 connected devices:
  SM A546E (mobile)  • R58N70XXXXX • android-arm64  • Android 15 (API 35)
  Windows (desktop)  • windows     • windows-x64    • Microsoft Windows
  Chrome (web)       • chrome      • web-javascript • Google Chrome 152.x
```

**Teste objetivo:** o seu aparelho aparece na lista de `flutter devices` com a palavra
`(mobile)`.

---

# PARTE 4 — `flutter doctor` linha por linha

O `flutter doctor` é o exame de sangue do seu ambiente. Rode-o sempre que algo estranho
acontecer — antes de pesquisar o erro no Google.

```bash
flutter doctor
```

## 4.1 Como ler cada categoria

Cada linha começa com um marcador:

| Marcador | Significado |
|---|---|
| `[✓]` | Categoria em ordem |
| `[!]` | Aviso — funciona, mas com ressalva ou com item opcional faltando |
| `[X]` | Erro — essa plataforma **não** vai compilar |
| `[☠]` | A própria verificação travou — foi o que aconteceu no [Problema 1](#12--problema-1--acento-no-caminho-do-flutter-sdk) |

E cada categoria significa:

| Categoria | O que verifica | É obrigatória para você? |
|---|---|---|
| `Flutter` | Versão, canal, revisão e se o SDK está íntegro | ✅ **Sim, sempre** |
| `Windows Version` | Se a sua versão do Windows é suportada | ✅ Sim |
| `Android toolchain` | Android SDK, Platform-Tools, JDK e licenças | ✅ **Sim**, para gerar APK/AAB |
| `Chrome - develop for the web` | Se o Chrome existe, para rodar `flutter run -d chrome` | ⚠️ Útil no curso (permite estudar sem emulador) |
| `Visual Studio - develop Windows apps` | Se o Visual Studio com o pacote **Desktop development with C++** existe | ⚠️ Só para `flutter run -d windows` |
| `Android Studio` | Se o Android Studio e os plugins Flutter/Dart estão instalados | ✅ Sim (é ele que gerencia SDK e emulador) |
| `VS Code` | Se o VS Code e a extensão Flutter estão instalados | ⚠️ Recomendado |
| `Connected device` | Aparelhos e emuladores visíveis agora | ⚠️ Pode aparecer vazio se nada estiver ligado |
| `Network resources` | Se o computador alcança os servidores de pacotes do Flutter/pub.dev | ✅ Sim |

## 4.2 O que é aceitável falhar no Windows

Esta é a parte que evita ansiedade desnecessária. **No Windows, é normal e aceitável** que:

| Linha | Por quê é aceitável |
|---|---|
| `[!] Xcode - develop for iOS and macOS` — ou a ausência total dessa linha | O Xcode só existe no macOS. **Nunca** será `[✓]` no Windows. Não há correção |
| `[!] Visual Studio - develop Windows apps` | Só é necessária se você quiser rodar o app como programa de **desktop Windows**. Se você só vai fazer Android, pode ignorar |
| `[!] Connected device` vazio | Significa apenas que nenhum emulador está aberto e nenhum celular está plugado **neste momento** |
| Avisos sobre `Android Studio (not installed)` quando você usa só o VS Code | Aceitável **desde que** o Android SDK esteja instalado e detectado pela própria categoria `Android toolchain` |

**Não é aceitável** e precisa ser corrigido antes de continuar:

- `[☠] Flutter (the doctor check crashed)` → [Problema 1](#12--problema-1--acento-no-caminho-do-flutter-sdk)
- `[X] Android toolchain` → [Problema 3](#14--problema-3--android-sdk-ausente)
- `Some Android licenses not accepted` → [2.7](#27-aceitação-de-licenças)
- `[X] Network resources` → rede/proxy/firewall bloqueando o acesso

## 4.3 `flutter doctor -v`

A opção `-v` (*verbose*, "detalhado") mostra, além do resultado, **os caminhos exatos** que o
Flutter encontrou:

```bash
flutter doctor -v
```

Use essa saída para responder perguntas como:

- Qual pasta o Flutter está usando como SDK? (procure `Flutter version ... at`)
- Qual Android SDK ele encontrou? (procure `Android SDK at`)
- Qual JDK está sendo usado? (procure `Java binary at` e `Java version`)
- Onde ele acha que o Android Studio está? (procure `Android Studio at`)

> 💡 Quando você pedir ajuda em um fórum ou para um colega, **cole a saída de `flutter doctor -v`**,
> não a de `flutter doctor`. Ela contém 90% do diagnóstico.

## 4.4 Tabela sintoma → causa → correção

| Sintoma (texto que aparece) | Causa | Correção |
|---|---|---|
| `flutter : O termo 'flutter' não é reconhecido...` / `flutter: command not found` | A pasta `bin` do SDK não está no PATH | [2.3](#23-path--entendendo-de-verdade) |
| `[☠] Flutter (the doctor check crashed)` + `Cannot resolve symbolic links` | Acento ou espaço no caminho do SDK | Mover para `C:\src\flutter` — [1.2](#12--problema-1--acento-no-caminho-do-flutter-sdk) |
| `ShaderCompilerException: ... ink_sparkle.frag` | Mesma causa acima (acento no caminho) | [1.2](#12--problema-1--acento-no-caminho-do-flutter-sdk) |
| `flutter analyze` encerra com código 255 | Mesma causa acima | [1.2](#12--problema-1--acento-no-caminho-do-flutter-sdk) |
| `Building with plugins requires symlink support` | Modo de Desenvolvedor do Windows desligado | `start ms-settings:developers` — [1.3](#13--problema-2--modo-de-desenvolvedor-do-windows-desligado) |
| `[X] Unable to locate Android SDK.` | Android SDK não instalado ou `ANDROID_HOME` errado | [2.6](#26-android-sdk-platform-tools-build-tools-e-emulador) |
| `Some Android licenses not accepted.` | Licenças pendentes | `flutter doctor --android-licenses` — [2.7](#27-aceitação-de-licenças) |
| `cmdline-tools component is missing` | Faltou *Android SDK Command-line Tools (latest)* | SDK Manager → aba **SDK Tools** — [2.6](#26-android-sdk-platform-tools-build-tools-e-emulador) |
| `Unsupported class file major version` no build Android | JDK incompatível com o Gradle/AGP | Usar **JDK 17** — [2.8](#28-jdk-17--e-por-que-a-versão-importa) |
| `adb devices` mostra `unauthorized` | Falta autorizar o computador no celular | Desbloquear a tela e aceitar o diálogo — [3.3](#33-aparelho-físico-android-opções-do-desenvolvedor-e-depuração-usb) |
| `adb devices` vazio com cabo plugado | Cabo só de carga, porta ruim, driver ausente ou modo MTP desligado | [3.3](#33-aparelho-físico-android-opções-do-desenvolvedor-e-depuração-usb) |
| Emulador abre preto ou muito lento | Virtualização desligada ou *Graphics* em **Software** | [3.2](#32-virtualização-bios-hyper-v-e-whpx) |
| `No devices found` no `flutter run` | Nada conectado e nenhum emulador aberto | Abrir o emulador ou plugar o celular — [Parte 3](#parte-3--emulador-e-aparelho-físico-android) |
| `[!] Visual Studio - develop Windows apps` | Falta o Visual Studio com C++ | Aceitável — só instale se quiser `flutter run -d windows` |
| Erro de rede em `Network resources` | Proxy, VPN ou firewall corporativo | Liberar acesso a `github.com`, `storage.googleapis.com` e `pub.dev` |

Mais casos, com o texto completo dos erros, em
[referencias/erros-comuns.md](referencias/erros-comuns.md).

---

# PARTE 5 — Primeiro projeto

## 5.1 Criando o projeto

Escolha uma pasta **sem acento e sem espaço** para seus projetos. Sugestão: `C:\src\projetos`.

**🪟 Windows (PowerShell)**
```powershell
New-Item -ItemType Directory -Force -Path C:\src\projetos
Set-Location C:\src\projetos
flutter create primeiro_app
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**
```bash
mkdir -p ~/projetos
cd ~/projetos
flutter create primeiro_app
```

Saída esperada, ao final:
```text
All done!
You can find general documentation for Flutter at: https://docs.flutter.dev/
...
In order to run your application, type:

  $ cd primeiro_app
  $ flutter run
```

> ⚠️ **Regra de nome de projeto:** só letras minúsculas, números e `_`. Nada de maiúsculas,
> hífen, acento ou espaço. `primeiro_app` ✅ · `PrimeiroApp` ❌ · `primeiro-app` ❌ ·
> `primeiro app` ❌. O nome vira o identificador do pacote Dart e precisa seguir essa regra.

Se você quiser **só Android e iOS**, sem as pastas de web e desktop:

```bash
flutter create --platforms=android,ios primeiro_app
```

## 5.2 A estrutura gerada, arquivo por arquivo

Entre na pasta e olhe o que foi criado:

**🪟 Windows (PowerShell)**
```powershell
Set-Location C:\src\projetos\primeiro_app
Get-ChildItem
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**
```bash
cd ~/projetos/primeiro_app
ls -a
```

| Arquivo / pasta | O que é | Você mexe? |
|---|---|---|
| `lib/main.dart` | Ponto de entrada. Contém `void main()`, que chama `runApp()` | ✅ O tempo todo |
| `pubspec.yaml` | Nome, versão, dependências e assets do projeto | ✅ Sempre que adicionar um pacote ou uma imagem |
| `pubspec.lock` | Versões exatas resolvidas. Gerado por `flutter pub get` | ❌ Não edite à mão (mas versione no Git) |
| `analysis_options.yaml` | Regras de lint. Já vem com `package:flutter_lints/flutter.yaml` | ⚠️ Só para ajustar regras |
| `test/widget_test.dart` | Teste de widget de exemplo | ✅ A partir do módulo 12 |
| `.metadata` | Versão do Flutter usada na criação. Uso interno | ❌ Nunca |
| `.gitignore` | O que o Git ignora (inclui `build/` e `.dart_tool/`) | ⚠️ Você acrescenta segredos aqui (módulo 14) |
| `android/` | Projeto Android nativo | ⚠️ Módulos 11 e 14 |
| `ios/` | Projeto iOS nativo | ⚠️ Módulos 11 e 15 |
| `web/`, `windows/`, `linux/`, `macos/` | Projetos nativos das demais plataformas | ❌ Raramente |
| `build/` | Saída de compilação. **Nasce depois do primeiro build** | ❌ Descartável — `flutter clean` apaga |
| `.dart_tool/` | Cache do gerenciador de pacotes. Nasce no `flutter pub get` | ❌ Descartável |

Abra `lib/main.dart` no VS Code:

**🪟 Windows (PowerShell) / 🖥️ macOS / 🐧 Linux**
```bash
code .
```

O arquivo gerado contém o app de contador padrão do Flutter. Ele é dissecado linha a linha na
aula [modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md](modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md).

## 5.3 Rodando no emulador

**Passo 1.** Abra o emulador (Android Studio → Device Manager → ▶, ou
`flutter emulators --launch Pixel_API_Curso`) e espere chegar à tela inicial.

**Passo 2.** Confirme que o Flutter o enxerga:
```bash
flutter devices
```

**Passo 3.** Rode:
```bash
flutter run
```

Se houver mais de um dispositivo, o Flutter pergunta qual usar. Para escolher direto, use `-d`
com o **id** que apareceu em `flutter devices`:
```bash
flutter run -d emulator-5554
```

Saída esperada, resumida:
```text
Launching lib/main.dart on sdk gphone64 x86 64 in debug mode...
Running Gradle task 'assembleDebug'...
√  Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...
Syncing files to device sdk gphone64 x86 64...

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

> 💡 **O primeiro build é lento** — o Gradle baixa dependências e compila tudo do zero. Cinco a
> quinze minutos é normal. Os builds seguintes levam segundos.

**Teste objetivo:** o app de contador aparece no emulador e o botão **+** incrementa o número.

## 5.4 Rodando no aparelho físico

**Passo 1.** Conclua a [seção 3.3](#33-aparelho-físico-android-opções-do-desenvolvedor-e-depuração-usb)
(Opções do desenvolvedor, Depuração USB, autorização).

**Passo 2.** Confirme:
```bash
adb devices
flutter devices
```

**Passo 3.** Rode apontando para o id do aparelho:
```bash
flutter run -d R58N70XXXXX
```

Troque `R58N70XXXXX` pelo id que apareceu na saída de `flutter devices` — ele é o número de
série do seu aparelho.

**Passo 4.** Se o celular perguntar **"Instalar este aplicativo?"**, aceite.

**Teste objetivo:** o app abre no seu celular e o contador funciona ao toque.

Para instalar sem ficar com o terminal preso ao processo:
```bash
flutter install
```

## 5.5 Hot reload × hot restart × full restart

Esta é a característica que mais economiza tempo em Flutter — e a mais confundida.

Com o `flutter run` em execução, o terminal aceita teclas:

| Tecla | Nome | O que faz | O que **preserva** | O que **perde** |
|---|---|---|---|---|
| `r` | **Hot reload** | Injeta o código Dart alterado na máquina virtual que já está rodando e manda o Flutter redesenhar a árvore de widgets | ✅ Todo o estado atual: valor do contador, texto digitado, posição da rolagem, tela em que você está | Nada do estado |
| `R` | **Hot restart** | Descarta o estado, recarrega o código e executa `main()` de novo | ✅ O app instalado (não reinstala) | ❌ Todo o estado: volta à tela inicial, contador zera |
| `q` e rodar `flutter run` de novo | **Full restart** (reinício completo) | Recompila o projeto inteiro, inclusive o código nativo, e reinstala o app | Nada | ❌ Estado **e** instalação — refaz tudo |

### Quando cada um é obrigatório

| Você mudou… | `r` resolve? | Precisa de `R`? | Precisa de full restart? |
|---|---|---|---|
| Um texto, uma cor, um padding, a árvore de widgets dentro de `build()` | ✅ Sim | — | — |
| O corpo de um método já existente | ✅ Sim | — | — |
| O código dentro de `main()` | ❌ Não | ✅ Sim | — |
| O código dentro de `initState()` | ❌ Não | ✅ Sim | — |
| O valor inicial de um campo de `State` | ❌ Não | ✅ Sim | — |
| Uma variável global ou um `static final` já inicializado | ❌ Não | ✅ Sim | — |
| Um `enum` virou classe (ou vice-versa) | ❌ Não | ✅ Sim | — |
| Adicionou/removeu um pacote no `pubspec.yaml` | ❌ Não | ❌ Não | ✅ Sim |
| Adicionou um plugin com código nativo | ❌ Não | ❌ Não | ✅ Sim |
| Mudou `AndroidManifest.xml` ou `Info.plist` | ❌ Não | ❌ Não | ✅ Sim |
| Mudou o ícone ou o nome do app | ❌ Não | ❌ Não | ✅ Sim |

### Detalhes importantes

- **Hot reload só existe em modo *debug*.** Nos modos *profile* e *release* o código é compilado
  de forma diferente e não aceita injeção. Isso é explicado em
  [modulos/14-build-android/01-debug-profile-release.md](modulos/14-build-android/01-debug-profile-release.md).
- **No VS Code** o hot reload dispara **automaticamente ao salvar** o arquivo
  (<kbd>Ctrl</kbd>+<kbd>S</kbd>). O hot restart tem o atalho
  <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>F5</kbd>.
- **Se algo ficar estranho depois de vários hot reloads**, faça um hot restart (`R`). Se ainda
  assim persistir, pare tudo e rode:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

Isso é aprofundado em
[modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md](modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md).

## 5.6 Estudando sem emulador: Chrome e Windows

Enquanto o Android SDK não está pronto — ou quando a máquina está pesada — você pode rodar o app
de outras formas.

### Navegador

```bash
flutter run -d chrome
```

- **Vantagem:** inicia em segundos, não exige emulador nem celular, e o hot reload funciona.
- **Limitação:** plugins que dependem de código nativo (câmera, `sqflite`,
  `flutter_secure_storage`) **não funcionam na web**. Layout, widgets, navegação, formulários,
  estado e chamadas HTTP funcionam normalmente.
- **Ótimo para:** módulos [06](modulos/06-widgets-e-layouts/README.md) e
  [07](modulos/07-navegacao-e-formularios/README.md).

### Desktop Windows

```bash
flutter run -d windows
```

- **Vantagem:** desempenho excelente, janela nativa, hot reload completo.
- **Requisito:** o **Visual Studio** (não o VS Code — são programas diferentes) com o pacote
  **"Desktop development with C++"**. Se ele não estiver instalado, o `flutter doctor` mostra
  `[!] Visual Studio - develop Windows apps` e este comando falha.
- **Limitação:** mesma das plataformas não-móveis — plugins só de celular não rodam.

### Comparação honesta

| Alvo | Inicia rápido | Plugins nativos móveis | Fiel ao celular | Serve para os módulos |
|---|---|---|---|---|
| Emulador Android | ❌ Lento | ✅ Sim | ✅ Alta | Todos |
| Celular Android | ⚠️ Médio | ✅ Sim | ✅ Máxima | Todos |
| `-d chrome` | ✅ Muito | ❌ Não | ⚠️ Média | 01 a 09 |
| `-d windows` | ✅ Muito | ❌ Não | ⚠️ Média | 01 a 09 |

> **Recomendação do curso:** use `-d chrome` para estudar widgets e layouts rapidinho, mas
> **valide sempre no Android** antes de considerar uma aula concluída. Comportamento de teclado,
> rolagem, gestos e áreas seguras da tela só são fiéis no aparelho.

---

# PARTE 6 — 🍎 Ambiente iOS (SÓ NO MAC)

> ## ⛔ LEIA ISTO ANTES DE COMEÇAR ESTA PARTE
>
> **🍎 NADA desta Parte 6 roda no Windows.** Nem com máquina virtual (é contra os termos de
> licença da Apple), nem com WSL, nem com "truques". Não existe forma suportada de compilar ou
> assinar um app iOS fora do macOS.
>
> **Você está no Windows 11.** Então, para você, esta parte é **leitura de compreensão**, não
> execução. E isso tem valor real: quando você precisar de um Mac emprestado, alugar um na
> nuvem, entrar em uma equipe que já tem um, ou configurar um pipeline de CI/CD, você vai
> **saber exatamente o que fazer** em vez de descobrir na hora.

## 6.0 O que VOCÊ deve fazer enquanto isso

Enquanto não tem um Mac, faça isto — em ordem:

1. **Leia esta Parte 6 inteira, sem pular.** Uma vez. Sem executar nada. O objetivo é reconhecer
   os nomes: Xcode, CocoaPods, *provisioning profile*, *signing*, *bundle identifier*.
2. **Escreva código que já é compatível com iOS.** Todos os pacotes escolhidos neste curso
   (`sqflite`, `shared_preferences`, `flutter_secure_storage`, `http`, `image_picker`,
   `connectivity_plus`) funcionam nos dois sistemas. Se você não usar nada fora dessa lista, seu
   app compila no Mac sem retrabalho.
3. **Mantenha a pasta `ios/` versionada no Git.** Nunca apague, nunca ignore no `.gitignore`.
   É ela que o Mac vai usar.
4. **Marque no `pubspec.yaml` apenas pacotes que declaram suporte a iOS.** Confira isso na página
   do pacote em <https://pub.dev> (seção *Platforms*). Isso é ensinado em
   [modulos/11-recursos-nativos/10-avaliando-pacotes.md](modulos/11-recursos-nativos/10-avaliando-pacotes.md).
5. **Teste tudo que puder no Android e no Chrome.** 95% da lógica é idêntica.
6. **Estude as diferenças de plataforma** em
   [referencias/diferencas-android-ios.md](referencias/diferencas-android-ios.md).
7. **Quando conseguir acesso a um Mac**, siga o módulo
   [15-build-ios](modulos/15-build-ios/README.md) do início ao fim, começando por
   [01-por-que-exige-macos.md](modulos/15-build-ios/01-por-que-exige-macos.md).

## 6.1 Por que a compilação iOS exige macOS

Não é capricho da Apple nem limitação do Flutter. São quatro razões técnicas e legais somadas:

### 1. A *toolchain* só existe no macOS
A **toolchain** (cadeia de ferramentas: compilador, ligador, empacotador) do iOS é o
**Xcode**, distribuído exclusivamente para macOS. O compilador `clang` configurado para iOS, o
`xcodebuild`, o `actool` (que compila catálogos de ícones) e o `ibtool` não têm versão Windows
ou Linux.

### 2. Os frameworks do iOS são binários fechados
Seu app precisa ser **ligado** (*linked*) contra os frameworks do sistema — `UIKit`,
`Foundation`, `CoreGraphics`, `Metal`. Esses arquivos vêm dentro do Xcode e são licenciados para
uso apenas em hardware Apple.

### 3. A assinatura de código é obrigatória e usa o chaveiro do macOS
Todo app iOS precisa ser **assinado digitalmente**. A assinatura combina:
- um **certificado** (que prova quem você é), guardado no **Keychain** (o chaveiro do macOS);
- um ***provisioning profile*** (perfil de provisionamento — um arquivo que diz *quais apps*,
  em *quais aparelhos*, com *quais permissões* podem rodar).

A ferramenta que faz essa combinação, `codesign`, é parte do macOS.

### 4. A licença da Apple proíbe rodar macOS em hardware não-Apple
O contrato de licença do macOS restringe a execução a hardware Apple. Montar um "Hackintosh"
para compilar apps comerciais é violação contratual. **Este curso não ensina isso.**

### Alternativas legítimas se você não tem Mac

| Alternativa | Como funciona | Consideração |
|---|---|---|
| Mac emprestado / de um colega | Você leva o projeto no Git e compila lá | Mais simples para fazer o primeiro build |
| Mac na nuvem (*Mac as a service*) | Você aluga por hora um Mac real e acessa remotamente | Custo por hora; funciona bem para builds pontuais |
| CI/CD com runner macOS | Um serviço de integração contínua roda o build em um Mac real a cada commit | É o caminho profissional. Introduzido em [modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md](modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md) |
| Comprar um Mac | Qualquer Mac com Apple Silicon dá conta | Investimento real |

> ❌ **Não existe** a alternativa "gerar IPA no Windows". Desconfie de qualquer conteúdo que
> prometa isso.

## 6.2 Instalar o Xcode

> 🍎 **SÓ NO MAC.** Este passo exige macOS. No Windows você pode ler e entender o processo, mas
> não executá-lo. Veja o que fazer enquanto isso em
> [modulos/15-build-ios/01-por-que-exige-macos.md](modulos/15-build-ios/01-por-que-exige-macos.md).

**O Xcode é a IDE oficial da Apple.** Ele traz o iOS SDK, o simulador, o compilador e as
ferramentas de assinatura.

**🖥️ macOS — instalação**
1. Abra a **App Store** no Mac.
2. Busque por **Xcode**.
3. Clique em **Obter / Instalar**. São dezenas de gigabytes — planeje o espaço em disco e o
   tempo de download.
4. Quando terminar, **abra o Xcode uma vez** manualmente. Na primeira abertura ele instala
   componentes adicionais e pede sua senha de administrador.

## 6.3 Command Line Tools

As ***Command Line Tools*** são a parte do Xcode que funciona pelo terminal — `git`, `clang`,
`xcodebuild`. Sem elas, o `flutter build` não consegue chamar o compilador.

**🖥️ macOS (bash/zsh)**
```bash
xcode-select --install
```

Uma janela gráfica se abre pedindo confirmação. Aceite e aguarde.

Se elas já estiverem instaladas, o comando responde:
```text
xcode-select: error: command line tools are already installed,
use "Software Update" to install updates
```
Isso **não é um problema** — é a confirmação de que já estão lá.

## 6.4 Apontar o Xcode correto

O macOS pode ter as Command Line Tools apontando para um local antigo ou para uma instalação
parcial. Este comando fixa o caminho para o Xcode completo:

**🖥️ macOS (bash/zsh)**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

`sudo` vai pedir a senha do seu usuário do Mac (ela não aparece enquanto você digita — isso é
normal).

Para conferir para onde está apontando:
```bash
xcode-select -p
```

Saída esperada:
```text
/Applications/Xcode.app/Contents/Developer
```

## 6.5 Primeira execução e licença

Duas etapas obrigatórias que o `flutter doctor` cobra:

**🖥️ macOS (bash/zsh)**
```bash
sudo xcodebuild -runFirstLaunch
```
Instala os componentes adicionais (simuladores, ferramentas de plataforma) sem abrir a interface
gráfica.

```bash
xcodebuild -license accept
```
Aceita o contrato de licença do Xcode. Dependendo da configuração da máquina, pode ser
necessário rodar com `sudo`.

**Teste objetivo:**
```bash
flutter doctor
```
A linha do Xcode deve ficar `[✓] Xcode - develop for iOS and macOS`.

## 6.6 CocoaPods

**CocoaPods** é o gerenciador de dependências nativas do ecossistema Apple — o equivalente iOS
do que o Gradle faz no Android. Quando o seu app Flutter usa um plugin (por exemplo
`shared_preferences`), a parte nativa desse plugin, escrita em Swift ou Objective-C, é instalada
pelo CocoaPods.

**Se o seu app não usa nenhum plugin, o CocoaPods não é necessário.** Como todo app real usa,
considere-o obrigatório.

### Instalação

**🖥️ macOS (bash/zsh)**
```bash
sudo gem install cocoapods
```

`gem` é o gerenciador de pacotes da linguagem Ruby, que já vem no macOS.

Confira:
```bash
pod --version
```

### Uso no dia a dia

Você raramente roda esses comandos à mão — o `flutter run` e o `flutter build ios` os chamam
sozinhos. Mas quando algo quebra, é aqui que se resolve. Rode-os **de dentro da pasta `ios/`**:

```bash
cd ios
pod install
```

| Comando | O que faz | Quando você precisa rodar à mão |
|---|---|---|
| `pod install` | Lê o `Podfile` e instala as dependências nativas na versão travada pelo `Podfile.lock` | Depois de clonar o projeto em outro Mac, ou quando o build reclama de pod ausente |
| `pod repo update` | Atualiza o **catálogo local** de pods disponíveis | Quando o `pod install` diz que não encontra uma versão que você sabe que existe |
| `pod install --repo-update` | Faz os dois de uma vez | Atalho para o caso acima |

### Quando o CocoaPods é necessário

- ✅ Ao adicionar ou remover qualquer plugin do `pubspec.yaml`.
- ✅ Ao clonar o projeto em um Mac novo.
- ✅ Ao mudar a versão mínima do iOS no `Podfile`.
- ❌ Não é necessário para mudanças só em código Dart.

## 6.7 Simulador de iPhone

O **simulador** roda uma versão do iOS sobre o próprio macOS. É rápido e ótimo para layout.

**Abrir:**
```bash
open -a Simulator
```

**Escolher o modelo:** com o Simulador aberto, menu **File → Open Simulator** e escolha o
aparelho (por exemplo, um iPhone recente).

**Conferir que o Flutter o enxerga:**
```bash
flutter devices
```

**Rodar o app:**
```bash
flutter run
```

Se houver mais de um dispositivo, especifique:
```bash
flutter run -d "iPhone 16"
```
(substitua pelo nome exato que apareceu em `flutter devices`.)

### Limitações do simulador — importantes

O simulador **não** tem: câmera real, GPS real, acelerômetro real, Bluetooth, notificações
*push* reais, nem a Apple Store. Ele também **não** usa o processador ARM do iPhone. Portanto:

> **Sempre valide em um iPhone físico antes de publicar.** O simulador serve para layout e fluxo,
> não para desempenho nem para recursos de hardware.

## 6.8 iPhone físico

### Passo 1 — conectar e confiar
1. Conecte o iPhone ao Mac com o cabo.
2. No iPhone, aparece **"Confiar neste computador?"**. Toque em **Confiar** e digite o código do
   aparelho.
3. No Mac, o Finder deve listar o iPhone na barra lateral.

### Passo 2 — Modo de Desenvolvedor (iOS 16 ou superior)
A partir do iOS 16, a Apple exige que você ligue explicitamente o Modo de Desenvolvedor no
próprio aparelho.

1. Conecte o iPhone ao Mac **e tente rodar o app uma vez** — é isso que faz a opção aparecer.
2. No iPhone: **Ajustes → Privacidade e Segurança → Modo de Desenvolvedor**.
3. Ligue a chave.
4. O iPhone pede para **reiniciar**. Reinicie.
5. Depois de reiniciar, ele pergunta **"Ativar o Modo de Desenvolvedor?"**. Confirme com o código
   do aparelho.

> Se a opção **Modo de Desenvolvedor** não aparecer em Ajustes, é porque o Mac ainda não tentou
> instalar nenhum app de desenvolvimento nesse aparelho. Rode `flutter run` uma vez e verifique
> de novo.

### Passo 3 — rodar
```bash
flutter devices
flutter run -d "iPhone de Fulano"
```

## 6.9 Assinatura inicial no Xcode

Antes do primeiro `flutter run` em um iPhone físico, você precisa configurar a assinatura uma vez.

**Passo 1 — abra o projeto no Xcode.** Da raiz do projeto Flutter:
```bash
open ios/Runner.xcworkspace
```

> ⚠️ Abra o **`.xcworkspace`**, nunca o `.xcodeproj`. O *workspace* é o que inclui os pods
> instalados pelo CocoaPods; abrir o `.xcodeproj` sozinho gera erros de símbolo não encontrado.

**Passo 2 — selecione o alvo.** Na barra lateral esquerda, clique no projeto **Runner** (o ícone
azul no topo). No painel central, em **TARGETS**, selecione **Runner**.

**Passo 3 — abra a aba "Signing & Capabilities".**

**Passo 4 — marque "Automatically manage signing".** Com essa opção ligada, o Xcode cria e
renova certificados e *provisioning profiles* sozinho.

**Passo 5 — escolha o Team.** No campo **Team**, selecione sua conta Apple. Se não houver
nenhuma, clique em **Add an Account...**, faça login com seu Apple ID e volte.

**Passo 6 — ajuste o Bundle Identifier.** O ***Bundle Identifier*** é o identificador único do
seu app no ecossistema Apple — equivalente ao `applicationId` do Android. Ele precisa ser único
no mundo inteiro. Neste curso o projeto final usa:

```text
br.com.estudos.foco
```

Se esse identificador já estiver registrado por outra pessoa, o Xcode acusa erro; nesse caso,
acrescente um sufixo seu (por exemplo, `br.com.estudos.foco.seusobrenome`).

**Passo 7 — confira que o erro sumiu.** A área de *Signing* deve mostrar um
**Provisioning Profile: Xcode Managed Profile** sem sinal de erro em vermelho.

**Passo 8 — confie no desenvolvedor, no iPhone.** Na primeira instalação com uma conta gratuita,
o app não abre e o iOS mostra "Desenvolvedor não confiável". Vá em
**Ajustes → Geral → VPN e Gerenciamento de Dispositivo**, toque no seu Apple ID e em
**Confiar**.

## 6.10 Conta Apple gratuita × Apple Developer Program

Esta é a diferença que mais frustra quem está começando. Entenda antes de investir.

| | **Apple ID gratuito** | **Apple Developer Program** |
|---|---|---|
| Custo | R$ 0 | **US$ 99 por ano**, renovação anual |
| Rodar no simulador | ✅ Sim | ✅ Sim |
| Instalar em iPhone físico seu | ✅ Sim | ✅ Sim |
| **Validade do perfil de provisionamento** | ⚠️ **7 dias.** Depois disso o app **para de abrir** no aparelho e você precisa reinstalar pelo Xcode | ✅ 1 ano |
| Limite de apps | ⚠️ **3 apps** instalados simultaneamente por aparelho, e **10 App IDs a cada 7 dias** | ✅ Sem esse limite |
| Aparelhos registrados | Apenas os que você conectar fisicamente | Até 100 por tipo de aparelho, por ano |
| Publicar na App Store | ❌ **Não** | ✅ Sim |
| **TestFlight** (distribuição de testes da Apple) | ❌ **Não** | ✅ Sim (até 10.000 testadores externos) |
| Distribuição ad hoc / empresarial | ❌ Não | ✅ Sim |
| Capacidades avançadas (Push Notifications, Sign in with Apple, iCloud, Apple Pay, HealthKit) | ❌ Não | ✅ Sim |
| Acesso ao App Store Connect | ❌ Não | ✅ Sim |
| Certificados de distribuição | ❌ Não | ✅ Sim |

### Como decidir

- **Para aprender e testar no seu próprio iPhone:** a conta gratuita **basta**. Conviva com a
  reinstalação a cada 7 dias.
- **Para mandar o app para outra pessoa testar:** precisa do programa pago (TestFlight).
- **Para publicar na App Store:** precisa do programa pago. Sem exceção.

> 💡 Comparação com o Android: a Google Play cobra uma **taxa única** de registro de
> desenvolvedor, enquanto a Apple cobra **anualmente**. E no Android você pode simplesmente
> mandar um APK por WhatsApp — no iOS, não existe equivalente disso.

Detalhado em
[modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md](modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md).

## 6.11 `flutter doctor` no macOS: como ler

No Mac, o relatório ganha categorias novas:

| Categoria | O que verifica |
|---|---|
| `[✓] Flutter` | Igual ao Windows |
| `[✓] Android toolchain` | Android SDK — sim, você pode fazer Android no Mac também |
| `[✓] Xcode - develop for iOS and macOS` | Xcode instalado, Command Line Tools apontadas, licença aceita e **CocoaPods** presente |
| `[✓] Chrome - develop for the web` | Chrome instalado |
| `[✓] Android Studio` | Android Studio instalado |
| `[✓] VS Code` | VS Code + extensão Flutter |
| `[✓] Connected device` | Simuladores e aparelhos conectados |
| `[✓] Network resources` | Acesso aos servidores do Flutter/pub.dev |

Avisos típicos do macOS e o que fazem você rodar:

| Mensagem | Correção |
|---|---|
| `Xcode installation is incomplete` | `sudo xcodebuild -runFirstLaunch` — [6.5](#65-primeira-execução-e-licença) |
| `Xcode end user license agreement not signed` | `xcodebuild -license accept` — [6.5](#65-primeira-execução-e-licença) |
| `CocoaPods not installed` | `sudo gem install cocoapods` — [6.6](#66-cocoapods) |
| `CocoaPods out of date` | `sudo gem install cocoapods` novamente |
| `Unable to get list of installed Simulator runtimes` | Abrir o Xcode uma vez e rodar `sudo xcodebuild -runFirstLaunch` |

## 6.12 Problemas comuns de CocoaPods e assinatura

| Sintoma | Causa | Correção |
|---|---|---|
| `CocoaPods not installed` no doctor | Gem ausente | `sudo gem install cocoapods` |
| `Error running pod install` | `Podfile.lock` desatualizado ou catálogo local velho | `cd ios` → `pod install --repo-update` |
| `Unable to find a specification for ...` | O catálogo local não conhece a versão pedida | `pod repo update` e repetir `pod install` |
| Erro de símbolo não encontrado ao compilar | Você abriu o `.xcodeproj` em vez do `.xcodeworkspace` | Fechar e abrir `ios/Runner.xcworkspace` |
| `Signing for "Runner" requires a development team` | Nenhum Team selecionado | Xcode → **Signing & Capabilities** → escolher o **Team** — [6.9](#69-assinatura-inicial-no-xcode) |
| `The bundle identifier ... is not available` | Alguém já registrou esse identificador | Trocar o Bundle Identifier por um sufixo único seu |
| `Untrusted Developer` ao abrir o app no iPhone | Conta gratuita ainda não confiada no aparelho | **Ajustes → Geral → VPN e Gerenciamento de Dispositivo** → **Confiar** |
| O app parou de abrir depois de uma semana | Perfil de conta gratuita expirou (7 dias) | Reinstalar via Xcode ou `flutter run`, ou assinar o Developer Program |
| `Could not launch ... Developer Mode disabled` | Modo de Desenvolvedor do iOS desligado | **Ajustes → Privacidade e Segurança → Modo de Desenvolvedor** — [6.8](#68-iphone-físico) |
| Pods quebrados depois de trocar plugins | Cache inconsistente | `flutter clean` → `cd ios` → `pod install` → `flutter run` |

Catálogo completo em
[modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md](modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md).

---

# PARTE 7 — O que dá para fazer no Windows × o que exige Mac

Esta é a tabela de referência do curso inteiro. Volte a ela sempre que tiver dúvida sobre o que
você consegue concluir sozinho.

| Atividade | 🪟 Windows | 🖥️ macOS | Observação |
|---|---|---|---|
| Escrever código Dart | ✅ | ✅ | Idêntico |
| Rodar programas Dart no terminal (`dart run`) | ✅ | ✅ | Módulos 01–04 completos |
| Criar projeto Flutter (`flutter create`) | ✅ | ✅ | Gera `android/` **e** `ios/` nos dois |
| Editar a pasta `ios/` (Info.plist, Podfile) | ✅ (é só texto) | ✅ | Editar sim; **compilar não** |
| Rodar no emulador Android | ✅ | ✅ | |
| Rodar em celular Android físico | ✅ | ✅ | |
| Rodar no simulador de iPhone | ❌ | ✅ | Simulador só existe no macOS |
| Rodar em iPhone físico | ❌ | ✅ | Exige Xcode para instalar |
| Rodar no Chrome (`-d chrome`) | ✅ | ✅ | |
| Rodar como app de desktop | ✅ (`-d windows`) | ✅ (`-d macos`) | Cada SO gera o seu |
| `flutter test` (testes unitários e de widget) | ✅ | ✅ | Não precisa de aparelho |
| `flutter analyze` / `dart format` | ✅ | ✅ | |
| Usar o DevTools | ✅ | ✅ | |
| Gerar **APK** (`flutter build apk`) | ✅ | ✅ | |
| Gerar **AAB** (`flutter build appbundle`) | ✅ | ✅ | |
| Assinar app Android (keystore) | ✅ | ✅ | Módulo 14 |
| Publicar na **Google Play** | ✅ | ✅ | É só enviar o AAB pelo navegador |
| Instalar Xcode | ❌ | ✅ | App Store, só macOS |
| Instalar CocoaPods | ❌ | ✅ | |
| `pod install` | ❌ | ✅ | |
| Gerar **archive** iOS | ❌ | ✅ | `build/ios/archive/Runner.xcarchive` |
| Gerar **IPA** (`flutter build ipa`) | ❌ | ✅ | **Não há alternativa no Windows** |
| Criar certificados e *provisioning profiles* | ❌ | ✅ | Exige Keychain do macOS |
| Enviar para **TestFlight** | ❌ | ✅ | Requer Developer Program |
| Publicar na **App Store** | ❌ | ✅ | |
| Estudar todo o processo iOS | ✅ | ✅ | É o que a [Parte 6](#parte-6--ambiente-ios--só-no-mac) e o módulo 15 fazem |

### Resumo em uma frase

> **No Windows você aprende 100% do curso, escreve 100% do código e entrega 100% do app Android.
> Só as duas últimas etapas do iOS — compilar e assinar — precisam de um Mac.**

---

# PARTE 8 — Checklist de saída

Marque cada item. **Só avance para o módulo 00 quando todos os itens obrigatórios estiverem
marcados.**

## 8.1 Fundamentos entendidos (Parte 0)

- [ ] Sei explicar, com minhas palavras, a diferença entre código-fonte, compilação e execução
- [ ] Sei a diferença entre **Dart** (linguagem) e **Flutter** (framework)
- [ ] Sei o que é **SDK**, **IDE**, **terminal**, **emulador** e **simulador**
- [ ] Sei a diferença entre app **nativo** e **multiplataforma**
- [ ] Sei para que serve cada um: **APK**, **AAB**, **archive iOS** e **IPA**
- [ ] Reconheço a função de `lib/`, `pubspec.yaml`, `android/`, `ios/`, `test/` e `build/`
- [ ] Sei checar em que pasta estou antes de rodar um comando
- [ ] Sei ler a **primeira** linha de um erro e localizar arquivo e linha

## 8.2 Correções desta máquina (Parte 1) — 🪟 obrigatório

- [ ] O Flutter SDK está em `C:\src\flutter` (sem acento, sem espaço)
- [ ] `Get-Command flutter` retorna `C:\src\flutter\bin\flutter.bat`
- [ ] `flutter --version` mostra **Flutter 3.47.1** e **Dart 3.13.1**
- [ ] `flutter doctor` roda inteiro, sem `[☠] the doctor check crashed`
- [ ] O **Modo de Desenvolvedor do Windows** está ativado
- [ ] `flutter pub get` roda sem `Building with plugins requires symlink support`
- [ ] O **Android SDK** está instalado e detectado

## 8.3 Ferramentas instaladas (Parte 2)

- [ ] `git --version` → 2.46 ou superior
- [ ] `flutter --version` → 3.47.1 · Dart 3.13.1
- [ ] `java -version` → OpenJDK **17**
- [ ] VS Code aberto com as extensões **Flutter** e **Dart** instaladas
- [ ] Android Studio abre e o **SDK Manager** existe
- [ ] `adb --version` responde
- [ ] `flutter doctor --android-licenses` terminou com `All SDK package licenses accepted.`

## 8.4 Dispositivos (Parte 3)

- [ ] Um AVD chamado sem acentos e sem espaços foi criado
- [ ] `flutter emulators` lista o AVD
- [ ] O emulador abre até a tela inicial do Android em tempo razoável
- [ ] (Se tiver celular) **Opções do desenvolvedor** e **Depuração USB** ativadas
- [ ] (Se tiver celular) `adb devices` mostra o aparelho como `device`, não `unauthorized`
- [ ] `flutter devices` lista pelo menos um dispositivo `(mobile)`

## 8.5 Diagnóstico (Parte 4)

- [ ] `flutter doctor` mostra `[✓]` em **Flutter**
- [ ] `flutter doctor` mostra `[✓]` em **Android toolchain**
- [ ] Sei quais linhas podem continuar `[!]` no Windows sem me preocupar
- [ ] Sei rodar `flutter doctor -v` e achar os caminhos do SDK, do JDK e do Android SDK

## 8.6 Primeiro app rodando (Parte 5)

- [ ] `flutter create primeiro_app` concluiu com `All done!`
- [ ] `flutter run` colocou o app de contador no emulador **ou** no celular
- [ ] O botão **+** incrementa o contador
- [ ] Mudei um texto no `lib/main.dart`, pressionei `r` e vi a mudança **sem perder o valor do
      contador** (hot reload)
- [ ] Pressionei `R` e vi o contador **voltar a zero** (hot restart)
- [ ] Sei quando `r` não basta e é preciso `R` ou reinício completo
- [ ] `flutter run -d chrome` abriu o app no navegador

## 8.7 Conhecimento de iOS (Parte 6) — leitura, não execução

- [ ] Sei **por que** a compilação iOS exige macOS (toolchain, frameworks, assinatura, licença)
- [ ] Sei o que são **Xcode**, **Command Line Tools** e **CocoaPods**
- [ ] Sei que se abre `ios/Runner.xcworkspace`, e não o `.xcodeproj`
- [ ] Sei o que é **Bundle Identifier** e qual é o do projeto final (`br.com.estudos.foco`)
- [ ] Sei a diferença entre **Apple ID gratuito** (7 dias, sem TestFlight, sem App Store) e
      **Apple Developer Program** (US$ 99/ano)
- [ ] Sei o que fazer enquanto não tenho um Mac (seção [6.0](#60-o-que-você-deve-fazer-enquanto-isso))

## 8.8 Checklists detalhados

Complete agora os dois checklists dedicados deste curso:

- 🤖 **[checklists/ambiente-android.md](checklists/ambiente-android.md)** — verificação item a item
  do ambiente Android. **Obrigatório antes do módulo 00.**
- 🍎 **[checklists/ambiente-ios.md](checklists/ambiente-ios.md)** — verificação do ambiente iOS.
  **Leitura obrigatória, execução opcional** (só faz sentido executar em um Mac).

## 8.9 Próximo passo

Ambiente pronto? Então siga, nesta ordem:

1. [00-como-usar-o-curso.md](00-como-usar-o-curso.md) — como o material está organizado e como
   estudar com ele.
2. [01-plano-intensivo.md](01-plano-intensivo.md) — o cronograma de 30 dias.
3. [modulos/00-git-e-terminal/README.md](modulos/00-git-e-terminal/README.md) — o primeiro módulo,
   ainda no Dia 1.
4. [03-trilha-de-progresso.md](03-trilha-de-progresso.md) — onde você marca o que já concluiu.

Materiais de apoio para consultar a qualquer momento:

- [referencias/glossario.md](referencias/glossario.md) — todo termo técnico do curso, definido.
- [referencias/comandos-uteis.md](referencias/comandos-uteis.md) — a lista de comandos que você
  vai usar todo dia.
- [referencias/erros-comuns.md](referencias/erros-comuns.md) — erros reais com texto literal e
  correção.
- [referencias/diferencas-android-ios.md](referencias/diferencas-android-ios.md) — o que muda
  entre as plataformas.
- [05-decisoes-tecnicas.md](05-decisoes-tecnicas.md) — por que o curso escolheu cada tecnologia.

---

## 📚 Referências oficiais

- [Flutter — Install](https://docs.flutter.dev/get-started/install)
- [Flutter — Install on Windows](https://docs.flutter.dev/get-started/install/windows)
- [Flutter — Install on macOS](https://docs.flutter.dev/get-started/install/macos)
- [Flutter — Install on Linux](https://docs.flutter.dev/get-started/install/linux)
- [Flutter — CLI reference](https://docs.flutter.dev/reference/flutter-cli)
- [Android Studio — download](https://developer.android.com/studio)
- [Android — adb (Android Debug Bridge)](https://developer.android.com/tools/adb)
- [Android — Android Emulator](https://developer.android.com/studio/run/emulator)
- [Android — Configure on-device developer options](https://developer.android.com/studio/debug/dev-options)
- [Eclipse Temurin (JDK 17)](https://adoptium.net/)
- [Git — Downloads](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Apple — Xcode](https://developer.apple.com/xcode/)
- [CocoaPods — Guides](https://guides.cocoapods.org/)
- [Apple Developer Program](https://developer.apple.com/programs/)
- [pub.dev — repositório oficial de pacotes Dart e Flutter](https://pub.dev)

---

| ⬅️ Anterior | 🏠 Início | ➡️ Próximo |
|---|---|---|
| [01 — Plano intensivo](01-plano-intensivo.md) | [README](README.md) | [03 — Trilha de progresso](03-trilha-de-progresso.md) |
