# ✅ Checklist — Ambiente Android do zero ao app rodando

> **Para quem:** você, no **Windows 11**, que ainda não tem nada instalado (ou tem só parte).
> **Objetivo:** sair do zero e chegar em **um app Flutter rodando no emulador E em um aparelho
> Android físico**, com *hot reload* funcionando.
> **Tempo realista:** 2 h a 4 h, dependendo da sua internet (o Android Studio baixa vários GB).
> **Aula-base:** [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

---

## Como usar este checklist

- Cada linha começa com `- [ ]`. Marque trocando por `- [x]` quando concluir.
- Onde existe **como verificar**, rode o comando **e confira a saída esperada**. Marcar sem
  verificar é enganar você mesmo — o erro só vai aparecer depois, no meio de um build.
- Os comandos com `powershell` devem ser digitados no **PowerShell** (o terminal padrão do
  Windows 11: tecle `Win`, digite `PowerShell`, abra).
- Faça na ordem. Cada bloco depende do anterior.

### Legenda

| Símbolo | Significa |
|---|---|
| 🔴 | Item **crítico**. Se falhar, várias coisas quebram depois, com erros confusos. |
| 🪟 | Específico do Windows |
| 🤖 | Específico do Android |
| ⏱️ | Item demorado (download grande) |

### Termos que aparecem aqui (explicados na primeira vez)

- **SDK** (*Software Development Kit*, kit de desenvolvimento de software) — o pacote de
  ferramentas, bibliotecas e comandos que você instala para conseguir programar para uma
  tecnologia. "Flutter SDK" é o Flutter inteiro; "Android SDK" é o kit da Google para Android.
- **PATH** — uma lista de pastas que o Windows consulta quando você digita um comando. Se a
  pasta do Flutter não estiver no PATH, digitar `flutter` devolve "comando não reconhecido".
- **IDE** (*Integrated Development Environment*, ambiente integrado de desenvolvimento) — o
  programa onde você escreve código (aqui: VS Code e/ou Android Studio).
- **Emulador** — um telefone Android **simulado por software** que roda dentro do seu PC.
- **AVD** (*Android Virtual Device*, dispositivo virtual Android) — a "definição" de um
  emulador: qual modelo de telefone, qual versão do Android, quanta memória.
- **ADB** (*Android Debug Bridge*, ponte de depuração do Android) — o programa que conversa com
  o aparelho/emulador: instala apps, lê logs, lista dispositivos.
- **JDK** (*Java Development Kit*) — o kit de desenvolvimento Java. O sistema de build do
  Android (Gradle) é escrito em Java/Kotlin e precisa dele.
- **Hot reload** (recarga quente) — recurso do Flutter que injeta o código alterado no app que
  já está rodando, preservando o estado da tela, em menos de um segundo.

---

## 1. 🪟 Pré-requisitos do Windows

- [ ] **Windows 10 (64 bits) versão 1809 ou mais recente, ou Windows 11.**
  O curso foi validado no Windows 11 Home Single Language 25H2.
  - Como verificar:
    ```powershell
    [System.Environment]::OSVersion.Version
    ```
    Esperado: número de build **≥ 17763** (no ambiente do curso: `10.0.26200`).
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Pelo menos 30 GB livres no disco C:.** ⏱️
  Flutter (~3 GB) + Android Studio e Android SDK (~12 GB) + emulador (~8 GB) + projetos.
  - Como verificar:
    ```powershell
    Get-PSDrive C | Select-Object Used, Free
    ```
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Você consegue abrir o PowerShell e sabe navegar entre pastas** (`cd`, `dir`, `pwd`).
  - Como verificar:
    ```powershell
    pwd
    dir
    ```
  - Aula: [modulos/00-git-e-terminal/01-o-terminal-sem-medo.md](../modulos/00-git-e-terminal/01-o-terminal-sem-medo.md)

- [ ] **Você entende a diferença entre caminho absoluto e relativo.**
  - Aula: [modulos/00-git-e-terminal/02-arquivos-e-caminhos.md](../modulos/00-git-e-terminal/02-arquivos-e-caminhos.md)

---

## 2. Git instalado

O **Git** é o sistema de controle de versão (o programa que guarda o histórico do seu código).
O Flutter **depende** dele: o próprio SDK é um repositório Git, e `flutter upgrade` usa Git por
baixo.

- [ ] **Git instalado e reconhecido no terminal.**
  - Como verificar:
    ```powershell
    git --version
    ```
    Esperado: `git version 2.46.0.windows.1` ou superior.
  - Se faltar: baixe em <https://git-scm.com/download/win> e instale com as opções padrão.
  - Aula: [modulos/00-git-e-terminal/03-git-o-que-e.md](../modulos/00-git-e-terminal/03-git-o-que-e.md)

- [ ] **Nome e e-mail configurados no Git** (aparecem em cada commit).
  - Como verificar:
    ```powershell
    git config --global user.name
    git config --global user.email
    ```
    Esperado: as duas linhas devolvem um valor, nenhuma vazia.
  - Se faltar:
    ```powershell
    git config --global user.name "Seu Nome"
    git config --global user.email "seu-email@exemplo.com"
    ```
  - Aula: [modulos/00-git-e-terminal/04-commits-branches-gitignore.md](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

---

## 3. 🔴 Flutter SDK em um caminho SEM ACENTO e SEM ESPAÇO

> ### 🔴 ESTE É O ITEM MAIS IMPORTANTE DA PÁGINA. LEIA ANTES DE MARCAR QUALQUER COISA.
>
> No ambiente medido para este curso, o SDK estava em
> `C:\Users\Usuário\Documents\flutter`.
> **Esse caminho quebra o Flutter.** O acento em "Usuário" e o espaço em nomes de pasta
> derrubam ferramentas internas que não tratam UTF-8. Os erros abaixo foram **reproduzidos de
> verdade** nessa máquina:
>
> ```text
> [☠] Flutter (the doctor check crashed)
>     ✗ FileSystemException: Cannot resolve symbolic links,
>       path = 'C:\Users\Usu rio\Documents\flutter\bin\flutter'
>       (OS Error: O sistema não pode encontrar o caminho especificado, errno = 3)
> ```
>
> ```text
> Asset 'shaders/ink_sparkle.frag' not found
> ShaderCompilerException: Shader compilation of ".../ink_sparkle.frag" failed with exit code 1.
> '#include' : Included file not found. for header name: flutter/runtime_effect.glsl
> ```
>
> E o servidor de análise (`flutter analyze`) encerra com **código 255**.
> Depois de mover o SDK para um caminho sem acento e rodar `flutter clean`, os mesmos testes
> que falhavam **passaram**.
>
> **Caminho recomendado pelo curso: `C:\src\flutter`.**
> Regras: sem acento (á é í ó ú ã õ ç), sem espaço, sem parênteses, fora de `Documents`,
> fora do `OneDrive` e fora de `C:\Program Files`.

- [ ] **Flutter SDK 3.47.1 (canal `stable`) baixado.** ⏱️
  Baixe o `.zip` em <https://docs.flutter.dev/get-started/install/windows> **ou** clone:
  ```powershell
  git clone https://github.com/flutter/flutter.git -b stable C:\src\flutter
  ```
  - Como verificar:
    ```powershell
    Test-Path C:\src\flutter\bin\flutter.bat
    ```
    Esperado: `True`.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] 🔴 **O caminho do SDK não tem acento.**
  - Como verificar (o comando devolve `OK` ou `PROBLEMA`):
    ```powershell
    $p = "C:\src\flutter"
    if ($p -match '[^\x20-\x7E]') { "PROBLEMA: caminho com caractere fora do ASCII" } else { "OK" }
    ```
  - Aula: [referencias/erros-comuns.md](../referencias/erros-comuns.md)

- [ ] 🔴 **O caminho do SDK não tem espaço.**
  - Como verificar:
    ```powershell
    $p = "C:\src\flutter"
    if ($p -match '\s') { "PROBLEMA: caminho com espaco" } else { "OK" }
    ```
  - Aula: [referencias/erros-comuns.md](../referencias/erros-comuns.md)

- [ ] 🔴 **Se você já usou o SDK no caminho errado, o cache foi limpo.**
  O cache corrompido continua quebrando o build mesmo depois de mover a pasta.
  - Como verificar/corrigir, dentro de qualquer projeto Flutter:
    ```powershell
    flutter clean
    flutter pub get
    ```
  - Aula: [referencias/erros-comuns.md](../referencias/erros-comuns.md)

---

## 4. PATH configurado

- [ ] **`C:\src\flutter\bin` está no PATH do seu usuário.**
  Configure em: `Win` → digite "variáveis de ambiente" → *Editar as variáveis de ambiente do
  seu usuário* → selecione `Path` → *Editar* → *Novo* → `C:\src\flutter\bin` → OK em tudo.
  **Feche e reabra o PowerShell depois** (janela antiga não enxerga PATH novo).
  - Como verificar:
    ```powershell
    $env:Path -split ';' | Select-String 'flutter'
    ```
    Esperado: uma linha com `C:\src\flutter\bin`.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **O comando `flutter` responde e vem do caminho certo.**
  - Como verificar:
    ```powershell
    (Get-Command flutter).Source
    flutter --version
    ```
    Esperado: `C:\src\flutter\bin\flutter.bat` e
    `Flutter 3.47.1 • channel stable` com `Dart 3.13.1`.
  - Aula: [referencias/comandos-uteis.md](../referencias/comandos-uteis.md)

- [ ] **Não existe um segundo Flutter antigo no PATH.** Dois SDKs no PATH fazem você editar um
  e rodar o outro.
  - Como verificar (deve listar **uma** linha só):
    ```powershell
    Get-Command flutter -All | Select-Object Source
    ```
  - Aula: [referencias/erros-comuns.md](../referencias/erros-comuns.md)

---

## 5. 🔴 Modo de Desenvolvedor do Windows ativado

Sem ele, qualquer projeto com **plugin** (pacote que tem código nativo, como `sqflite`,
`shared_preferences`, `path_provider`) falha, porque o Flutter precisa criar *symlinks*
(atalhos de sistema de arquivos) e o Windows só permite isso no Modo de Desenvolvedor.
Erro real reproduzido:

```text
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings. Run
  start ms-settings:developers
to open settings.
```

- [ ] 🔴 **Modo de Desenvolvedor ligado.**
  - Como abrir a tela:
    ```powershell
    start ms-settings:developers
    ```
    Ligue a chave **Modo de desenvolvedor** e confirme.
  - Como verificar (deve devolver `1`):
    ```powershell
    (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock').AllowDevelopmentWithoutDevLicense
    ```
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md) ·
    [referencias/erros-comuns.md](../referencias/erros-comuns.md)

---

## 6. JDK 17

O Gradle (sistema de build do Android) usado pelo Flutter 3.47 compila com **Java 17**
(`VERSION_17` / `jvmTarget = JVM_17`). Versões mais novas do Java costumam quebrar o build com
mensagens sobre "Unsupported class file major version".

- [ ] **JDK 17 instalado** (Temurin/Adoptium é a distribuição usada no curso; o JDK que vem
  embutido no Android Studio também serve). ⏱️
  - Como verificar:
    ```powershell
    java -version
    ```
    Esperado: uma linha com `17.0.x` (no ambiente do curso: Temurin OpenJDK 17.0.18).
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **O Flutter enxerga o Java 17.**
  - Como verificar:
    ```powershell
    flutter doctor -v
    ```
    Procure a linha `• Java version` dentro de *Android toolchain*. Deve citar 17.
  - Se o Flutter apontar para um Java errado, indique a pasta manualmente:
    ```powershell
    flutter config --jdk-dir "C:\Program Files\Eclipse Adoptium\jdk-17"
    ```
    (troque pelo caminho real da sua instalação)
  - Aula: [modulos/15-build-android/10-diagnostico-de-build.md](../modulos/15-build-android/10-diagnostico-de-build.md)

---

## 7. 🤖 Android Studio, Android SDK e ferramentas

Você **não precisa programar** no Android Studio — vai usar o VS Code. Mas ele é a forma
oficial e mais confiável de instalar o **Android SDK**, o **gerenciador de emuladores** e as
ferramentas de linha de comando.

- [ ] **Android Studio instalado.** ⏱️ (download de alguns GB)
  Baixe em <https://developer.android.com/studio> e siga o assistente com as opções padrão.
  - Como verificar:
    ```powershell
    flutter doctor -v
    ```
    Deve aparecer um bloco `[✓] Android Studio (version ...)`.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Android SDK Platform da API 36 instalado.**
  O Flutter 3.47 gera projetos com `compileSdk = 36` e `targetSdk = 36`.
  Instale em: Android Studio → *More Actions* → **SDK Manager** → aba *SDK Platforms* →
  marque **Android API 36** → *Apply*.
  - Como verificar:
    ```powershell
    Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\platforms"
    ```
    Esperado: uma pasta `android-36`.
  - Aula: [modulos/15-build-android/01-debug-profile-release.md](../modulos/15-build-android/01-debug-profile-release.md)

- [ ] **Android SDK Command-line Tools instalado.**
  É onde moram as ferramentas de linha de comando do SDK: o `android` (**Android CLI**) nas
  versões recentes e o `sdkmanager` nas antigas. Sem ele, os comandos de licença e de
  gerenciamento de pacotes não rodam.
  SDK Manager → aba *SDK Tools* → marque **Android SDK Command-line Tools (latest)** → *Apply*.
  - Como verificar:
    ```powershell
    Test-Path "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\android.exe"
    ```
    Esperado: `True`. Em SDKs mais antigos o binário é `sdkmanager.bat` — qualquer um dos dois
    presente significa que o componente está instalado.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Android SDK Platform-Tools instalado** (é onde mora o `adb`).
  SDK Manager → *SDK Tools* → **Android SDK Platform-Tools**.
  - Como verificar:
    ```powershell
    Test-Path "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    ```
    Esperado: `True`.
  - Aula: [modulos/12-testes-e-debug/09-depurando-android-e-ios.md](../modulos/12-testes-e-debug/09-depurando-android-e-ios.md)

- [ ] **Android SDK Build-Tools instalado.**
  SDK Manager → *SDK Tools* → **Android SDK Build-Tools**.
  - Como verificar (deve listar ao menos uma pasta de versão):
    ```powershell
    Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\build-tools"
    ```
  - Aula: [modulos/15-build-android/08-gerando-apk-e-aab.md](../modulos/15-build-android/08-gerando-apk-e-aab.md)

- [ ] **`platform-tools` adicionado ao PATH** (para digitar `adb` de qualquer pasta).
  Acrescente `%LOCALAPPDATA%\Android\Sdk\platform-tools` ao `Path` do usuário, feche e reabra o
  PowerShell.
  - Como verificar:
    ```powershell
    adb --version
    ```
    Esperado: `Android Debug Bridge version 1.0.xx`.
  - Aula: [referencias/comandos-uteis.md](../referencias/comandos-uteis.md)

- [ ] **O Flutter encontrou o Android SDK.**
  No ambiente medido para o curso, `ANDROID_HOME` estava vazio e o resultado era:
  ```text
  [X] Android toolchain - develop for Android devices
      X Unable to locate Android SDK.
  ```
  - Como verificar:
    ```powershell
    flutter doctor -v
    ```
    A linha `• Android SDK at ...` deve aparecer.
  - Se não aparecer, aponte manualmente:
    ```powershell
    flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
    ```
  - Aula: [referencias/erros-comuns.md](../referencias/erros-comuns.md)

---

## 8. 🤖 Licenças do Android aceitas

O Google exige aceite explícito das licenças dos componentes do SDK. Sem isso o Gradle recusa
compilar, com uma mensagem sobre "licenses not accepted".

- [ ] **Todas as licenças aceitas.**
  - Como verificar (faça isto **primeiro** — muitas vezes já está resolvido):
    ```powershell
    flutter doctor -v
    ```
    Esperado: a linha `• All Android licenses accepted.` dentro do bloco do Android toolchain,
    e nenhum aviso `Some Android licenses not accepted`.
  - Se já estiver aceito, **não há nada a fazer aqui**. Instalar os componentes pelo SDK Manager
    do Android Studio costuma aceitar as licenças junto com o download.
  - Se estiver pendente, o comando depende da idade do seu Android SDK — os dois casos estão em
    [02-configuracao-do-ambiente.md § 2.7](../02-configuracao-do-ambiente.md#27-aceitação-de-licenças).
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

---

## 9. VS Code e extensões

- [ ] **VS Code instalado.**
  - Como verificar:
    ```powershell
    code --version
    ```
    Se `code` não for reconhecido, abra o VS Code e use
    `Ctrl+Shift+P` → *Shell Command: Install 'code' command in PATH*.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Extensão Dart instalada.**
  - Como instalar e verificar:
    ```powershell
    code --install-extension Dart-Code.dart-code
    code --list-extensions | Select-String 'dart-code'
    ```
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Extensão Flutter instalada** (ela traz os atalhos de *hot reload*, o seletor de
  dispositivo na barra inferior e os *code actions* de widget).
  - Como instalar e verificar:
    ```powershell
    code --install-extension Dart-Code.flutter
    code --list-extensions | Select-String 'flutter'
    ```
  - Aula: [modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md](../modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md)

- [ ] **Formatação automática ao salvar ligada** (evita brigar com o `dart format` depois).
  VS Code → `Ctrl+,` → busque `Format On Save` → marque.
  - Como verificar: altere a indentação de um arquivo `.dart`, salve, veja o arquivo se
    reorganizar sozinho.
  - Aula: [modulos/12-testes-e-debug/04-analise-lint-formatacao.md](../modulos/12-testes-e-debug/04-analise-lint-formatacao.md)

---

## 10. 🤖 Emulador Android funcionando

- [ ] **Virtualização ativada na BIOS/UEFI.**
  O emulador só roda rápido com a virtualização do processador ligada (Intel VT-x / AMD-V).
  Se estiver desligada, ou o emulador não abre, ou abre absurdamente lento.
  - Como verificar pelo Windows: `Ctrl+Shift+Esc` → aba **Desempenho** → **CPU** → procure
    **Virtualização: Habilitado**.
  - Como verificar pelo terminal:
    ```powershell
    Get-ComputerInfo -Property HyperVRequirementVirtualizationFirmwareEnabled
    ```
    Esperado: `True`.
  - Se estiver `False`: reinicie, entre na BIOS/UEFI (geralmente `Del`, `F2` ou `F10` ao ligar),
    procure **Intel Virtualization Technology (VT-x)** ou **SVM Mode** (AMD) e ative.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Um AVD criado.**
  Android Studio → *More Actions* → **Device Manager** → *Create Virtual Device* → escolha um
  Pixel → escolha uma imagem de sistema da **API 36** (baixe se necessário ⏱️) → *Finish*.
  - Como verificar:
    ```powershell
    flutter emulators
    ```
    Esperado: pelo menos uma linha com o `id` do emulador criado.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **O emulador abre e chega na tela inicial do Android.**
  - Como fazer (troque `<id>` pelo id listado acima):
    ```powershell
    flutter emulators --launch <id>
    ```
  - Como verificar:
    ```powershell
    adb devices
    ```
    Esperado: uma linha como `emulator-5554   device`. Se aparecer `offline`, espere o boot
    terminar e repita.
  - Aula: [modulos/12-testes-e-debug/09-depurando-android-e-ios.md](../modulos/12-testes-e-debug/09-depurando-android-e-ios.md)

---

## 11. 🤖 Aparelho Android físico

Rodar no aparelho real é obrigatório neste curso: o emulador não reproduz gestos, desempenho,
câmera nem comportamento de bateria do mundo real.

- [ ] **Opções do desenvolvedor liberadas no telefone.**
  Ajustes → *Sobre o telefone* → toque **7 vezes** em *Número da versão* (ou *Número da
  compilação*) até aparecer "Você agora é um desenvolvedor".
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Depuração USB ativada.**
  Ajustes → *Sistema* → *Opções do desenvolvedor* → ligue **Depuração USB**.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **Cabo USB de dados** (não só de carga) conectado, e o aparelho **desbloqueado**.
  - Como verificar:
    ```powershell
    adb devices
    ```
    Se aparecer `unauthorized`, olhe a tela do telefone: existe um diálogo *Permitir depuração
    USB?*. Marque *Sempre permitir* e toque em **Permitir**.
  - Aula: [referencias/erros-comuns.md](../referencias/erros-comuns.md)

- [ ] **O aparelho aparece como `device` (e não `unauthorized` nem `offline`).**
  - Como verificar:
    ```powershell
    adb devices -l
    ```
    Esperado: `<serial>   device product:... model:...`
  - Se não aparecer nada: troque a porta USB, troque o cabo, e no telefone mude o modo de
    conexão USB de *Somente carregar* para *Transferência de arquivos (MTP)*.
  - Aula: [modulos/12-testes-e-debug/09-depurando-android-e-ios.md](../modulos/12-testes-e-debug/09-depurando-android-e-ios.md)

---

## 12. Diagnóstico final do ambiente

- [ ] **`flutter doctor` sem `[X]` nas categorias que importam.**
  As categorias que **precisam** estar `[✓]` no seu caso:
  - `Flutter` (SDK e canal)
  - `Windows Version`
  - `Android toolchain - develop for Android devices`
  - `Android Studio`
  - `VS Code`
  - `Connected device`
  - `Network resources`

  As que **podem** ficar com aviso sem problema nenhum agora:
  - `Chrome - develop for the web` (só se você não for testar na web)
  - `Visual Studio - develop Windows apps` (só se você não for compilar app de Windows)
  - Qualquer linha de macOS/Xcode — você está no Windows e isso é esperado.
    Veja [checklists/ambiente-ios.md](ambiente-ios.md).

  - Como verificar:
    ```powershell
    flutter doctor -v
    ```
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **`flutter devices` lista o alvo que você quer usar.**
  - Como verificar:
    ```powershell
    flutter devices
    ```
    Esperado: pelo menos o emulador **ou** o aparelho físico, cada um com um `id`. Guarde esse
    `id`: é ele que vai depois do `-d` no `flutter run`.
  - Aula: [referencias/comandos-uteis.md](../referencias/comandos-uteis.md)

---

## 13. Primeiro app rodando

- [ ] **Projeto criado em um caminho sem acento e sem espaço** (a mesma regra do SDK vale para
  os seus projetos).
  - Como fazer:
    ```powershell
    mkdir C:\src\projetos
    cd C:\src\projetos
    flutter create verifica_ambiente
    cd verifica_ambiente
    ```
  - Aula: [modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md](../modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md)

- [ ] **Dependências baixadas sem erro.**
  - Como verificar:
    ```powershell
    flutter pub get
    ```
    Esperado: termina com `Got dependencies!` e **sem** a mensagem sobre symlink/Developer Mode.
  - Aula: [modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md](../modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)

- [ ] **Análise estática limpa** (o analisador é o que trava com código 255 quando o caminho tem
  acento — por isso ele é um bom teste do item 3).
  - Como verificar:
    ```powershell
    flutter analyze
    ```
    Esperado: `No issues found!`
  - Aula: [modulos/04-dart-avancado/07-analise-estatica-e-lints.md](../modulos/04-dart-avancado/07-analise-estatica-e-lints.md)

- [ ] **Testes do projeto recém-criado passam.**
  - Como verificar:
    ```powershell
    flutter test
    ```
    Esperado: `All tests passed!`
  - Aula: [modulos/12-testes-e-debug/05-testes-unitarios.md](../modulos/12-testes-e-debug/05-testes-unitarios.md)

- [ ] **App rodando no EMULADOR.**
  - Como fazer:
    ```powershell
    flutter run -d emulator-5554
    ```
    (ou o `id` que o `flutter devices` mostrou)
    Esperado: o app do contador aparece no emulador e o terminal mostra
    `Flutter run key commands.`
  - Aula: [modulos/05-introducao-ao-flutter/01-como-o-flutter-funciona.md](../modulos/05-introducao-ao-flutter/01-como-o-flutter-funciona.md)

- [ ] **App rodando no APARELHO FÍSICO.**
  - Como fazer:
    ```powershell
    flutter run -d <id-do-aparelho>
    ```
  - Como verificar: o app abre na tela do telefone e o botão `+` incrementa o número.
  - Aula: [modulos/12-testes-e-debug/09-depurando-android-e-ios.md](../modulos/12-testes-e-debug/09-depurando-android-e-ios.md)

- [ ] **Hot reload funcionando.**
  Com o `flutter run` ativo, abra `lib/main.dart`, troque o texto
  `'You have pushed the button this many times:'` por `'Sessões de estudo concluídas:'`, salve
  e pressione `r` no terminal.
  - Como verificar: o texto muda na tela **em menos de 1 segundo** e o contador **não volta
    para zero** (o estado foi preservado — essa é a diferença entre `r` e `R`).
  - Teclas úteis: `r` = hot reload · `R` = hot restart (reinicia o app e zera o estado) ·
    `q` = sair.
  - Aula: [modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md](../modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md)

- [ ] **Build de debug de APK conclui** (prova que o Gradle, o JDK 17 e o Android SDK estão
  todos conversando).
  - Como verificar:
    ```powershell
    flutter build apk --debug
    ```
    Esperado: `✓ Built build\app\outputs\flutter-apk\app-debug.apk`.
    A **primeira** execução baixa o Gradle e demora vários minutos. ⏱️
  - Aula: [modulos/15-build-android/01-debug-profile-release.md](../modulos/15-build-android/01-debug-profile-release.md)

---

## 14. 🧪 Como provar que está tudo certo (sequência exata)

Abra um PowerShell **novo** e rode os comandos **nesta ordem**. Se qualquer um falhar, volte ao
item correspondente acima antes de seguir.

```powershell
# 1. Ferramentas básicas
git --version
java -version
adb --version

# 2. O Flutter certo, no caminho certo
(Get-Command flutter).Source          # esperado: C:\src\flutter\bin\flutter.bat
flutter --version                     # esperado: Flutter 3.47.1 • Dart 3.13.1

# 3. Diagnóstico completo
flutter doctor -v

# 4. O alvo existe
flutter devices

# 5. Projeto de prova, em caminho sem acento
cd C:\src\projetos
flutter create verifica_ambiente
cd verifica_ambiente

# 6. O ciclo completo de qualidade
flutter pub get
flutter analyze
dart format --output=none --set-exit-if-changed .
flutter test

# 7. Rodar de verdade (troque <id> pelo id do passo 4)
flutter run -d <id>
#    dentro da sessão: edite lib/main.dart, salve, pressione r  -> hot reload
#                      pressione R                              -> hot restart
#                      pressione q                              -> sair

# 8. O build nativo fecha o ciclo
flutter build apk --debug
```

### Saídas esperadas, item a item

| Comando | Saída que prova sucesso |
|---|---|
| `git --version` | `git version 2.46.0.windows.1` ou superior |
| `java -version` | contém `17.0.` |
| `adb --version` | `Android Debug Bridge version 1.0.xx` |
| `(Get-Command flutter).Source` | `C:\src\flutter\bin\flutter.bat` — sem acento, sem espaço |
| `flutter --version` | `Flutter 3.47.1 • channel stable` + `Dart 3.13.1` |
| `flutter doctor -v` | `[✓]` em Flutter, Android toolchain, Android Studio, VS Code, Connected device |
| `flutter devices` | ao menos 1 dispositivo Android com `id` |
| `flutter pub get` | `Got dependencies!` sem aviso de symlink |
| `flutter analyze` | `No issues found!` |
| `dart format --output=none --set-exit-if-changed .` | termina sem listar arquivo alterado |
| `flutter test` | `All tests passed!` |
| `flutter run -d <id>` | app na tela + `Flutter run key commands.` |
| pressionar `r` | texto muda e o contador **não** zera |
| `flutter build apk --debug` | `✓ Built build\app\outputs\flutter-apk\app-debug.apk` |

- [ ] **Marquei todos os 14 comandos acima com a saída esperada.**
  Se sim: seu ambiente Android está pronto. Vá para
  [01-plano-intensivo.md](../01-plano-intensivo.md) e comece o Dia 1.

---

## 15. Se algo falhou

| Sintoma | Causa mais provável | Onde resolver |
|---|---|---|
| `flutter` não é reconhecido | PATH não configurado, ou terminal não foi reaberto | Item 4 · [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md) |
| `the doctor check crashed` / `Cannot resolve symbolic links` | 🔴 acento no caminho do SDK | Item 3 · [referencias/erros-comuns.md](../referencias/erros-comuns.md) |
| `ShaderCompilerException` / `ink_sparkle.frag` | 🔴 acento no caminho + cache sujo | Item 3 (`flutter clean`) · [referencias/erros-comuns.md](../referencias/erros-comuns.md) |
| `flutter analyze` encerra com código 255 | 🔴 acento no caminho do SDK | Item 3 |
| `Building with plugins requires symlink support` | Modo de Desenvolvedor desligado | Item 5 |
| `Unable to locate Android SDK` | Android SDK ausente ou não apontado | Item 7 |
| `Some Android licenses not accepted` | licenças não aceitas | Item 8 |
| Emulador não abre / lentidão extrema | virtualização desligada na BIOS | Item 10 |
| `adb devices` mostra `unauthorized` | diálogo de autorização não confirmado no telefone | Item 11 |
| `Unsupported class file major version` | Java diferente do 17 | Item 6 · [modulos/15-build-android/10-diagnostico-de-build.md](../modulos/15-build-android/10-diagnostico-de-build.md) |
| Build Gradle falha sem mensagem clara | cache do Gradle sujo | `flutter clean` · [modulos/15-build-android/10-diagnostico-de-build.md](../modulos/15-build-android/10-diagnostico-de-build.md) |

---

## 16. O que NÃO está neste checklist (de propósito)

- **Build iOS.** Você está no Windows. Nada de iOS é executável aqui.
  O processo completo, e o que dá para adiantar no Windows, está em
  [checklists/ambiente-ios.md](ambiente-ios.md) e no
  [módulo 16](../modulos/16-build-ios/README.md).
- **Assinatura de release, keystore e publicação.** Isso vem depois, no
  [checklists/build-android.md](build-android.md) e no
  [módulo 15](../modulos/15-build-android/README.md).

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [README do curso](../README.md) | [Índice geral](../README.md) | [Checklist — Ambiente iOS](ambiente-ios.md) |
