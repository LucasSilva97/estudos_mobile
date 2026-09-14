# 🍎 Checklist — Ambiente iOS do zero ao app rodando

> ## 🍎 LEIA ANTES DE TUDO: este checklist exige **macOS**.
>
> **Você está no Windows 11.** Não existe caminho, truque, emulador, máquina virtual
> "oficialmente suportada" ou plugin que permita compilar um app iOS a partir do Windows.
> O motivo não é preguiça do Flutter: o compilador, o assinador e o empacotador de apps da
> Apple (**Xcode**, **`xcodebuild`**, **`codesign`**) só existem para macOS, e o contrato de
> licença da Apple restringe o uso deles a hardware Apple.
>
> **Este curso não vai prometer que você gera um `.ipa` no Windows. Você não gera.**
>
> O que este checklist faz por você **hoje, no Windows**:
> 1. deixa o **projeto pronto** para compilar em um Mac (a pasta `ios/`, o `Info.plist`, o
>    ícone, a splash, a versão, os textos de permissão — tudo isso você edita no Windows);
> 2. ensina o processo **inteiro**, para que no dia em que você tiver acesso a um Mac
>    (seu, de um amigo, da faculdade, do trabalho ou alugado na nuvem) você gaste 1 hora e não
>    1 semana;
> 3. marca com **Não** exatamente os passos que ficam bloqueados agora, para você não perder
>    tempo tentando.
>
> Entenda o porquê em
> [modulos/15-build-ios/01-por-que-exige-macos.md](../modulos/15-build-ios/01-por-que-exige-macos.md).

---

## Como usar este checklist

- Formato `- [ ]`; marque com `- [x]`.
- **Todo item traz a linha `🪟 Dá para fazer no Windows? Sim/Não`.** Os itens **Sim** você faz
  agora. Os itens **Não** você lê agora e executa quando tiver o Mac.
- Ao final há uma **tabela-resumo** com a mesma coluna, para bater o olho.
- Os comandos `bash` são do terminal do macOS (o app **Terminal**, ou o Terminal integrado do
  VS Code no Mac).

### Legenda

| Símbolo | Significa |
|---|---|
| 🍎 | Específico do iOS / Apple |
| 🖥️ | Precisa de macOS |
| 🪟 | Você consegue fazer no Windows |
| 🔴 | Item crítico |
| ⏱️ | Item demorado (download grande) |

### Termos explicados na primeira vez

- **Xcode** — a IDE oficial da Apple. Traz o compilador, os simuladores de iPhone/iPad, o
  gerenciador de certificados e o **Organizer** (a tela que envia o app para a App Store).
- **Command Line Tools** — o subconjunto do Xcode que funciona no terminal (`xcodebuild`,
  `git`, `clang`). O Flutter chama esses programas por baixo.
- **Simulador** — o iPhone simulado por software, equivalente iOS do emulador Android.
  Só roda no macOS.
- **Bundle ID** (*Bundle Identifier*) — o identificador único do seu app na Apple, no formato
  `br.com.estudos.foco`. É o equivalente do `applicationId` do Android.
- **Team** (time) — a conta Apple sob a qual o app é assinado. Aparece no Xcode como
  *Team*, e tem um identificador que este curso escreve sempre como `SEU_TEAM_ID`.
- **Assinatura de código** (*code signing*) — o carimbo criptográfico que prova que o app veio
  de você. Sem ele o iPhone recusa instalar.
- **Automatic signing** (assinatura automática) — a opção do Xcode em que ele cria e renova
  sozinho os certificados e perfis. É o modo recomendado para quem está começando.
- **SPM** (*Swift Package Manager*, gerenciador de pacotes Swift) — o gerenciador oficial da
  Apple para dependências nativas. **É o padrão do Flutter desde a versão 3.44.**
- **CocoaPods** — o gerenciador de dependências antigo do mundo iOS. Continua sendo usado como
  alternativa automática quando algum plugin ainda não suporta SPM.

---

## 1. 🖥️ O Mac em si

- [ ] **Você tem acesso a um Mac** (próprio, emprestado, institucional ou alugado na nuvem).
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como verificar (no Mac):
    ```bash
    sw_vers
    ```
    Esperado: `ProductName: macOS` e um `ProductVersion`.
  - Aula: [modulos/15-build-ios/01-por-que-exige-macos.md](../modulos/15-build-ios/01-por-que-exige-macos.md)

- [ ] **A versão do macOS é compatível com a versão do Xcode que você vai instalar.**
  Cada Xcode exige um macOS mínimo; a App Store simplesmente não deixa instalar se não bater.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como verificar (no Mac):
    ```bash
    sw_vers -productVersion
    ```
  - Aula: [modulos/15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md)

- [ ] **Espaço em disco suficiente: reserve ~40 GB.** ⏱️
  Xcode ocupa por volta de 15 GB depois de instalado, e cada *runtime* de simulador extra pesa
  vários GB. Builds e *DerivedData* (a pasta de arquivos intermediários do Xcode) crescem
  rápido.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como verificar (no Mac):
    ```bash
    df -h /
    ```
  - Aula: [modulos/15-build-ios/01-por-que-exige-macos.md](../modulos/15-build-ios/01-por-que-exige-macos.md)

---

## 2. 🍎 Xcode e ferramentas de linha de comando

- [ ] **Xcode instalado pela Mac App Store.** ⏱️
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como verificar (no Mac):
    ```bash
    xcodebuild -version
    ```
    Esperado: `Xcode <versão>` + `Build version ...`
  - Aula: [modulos/15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md)

- [ ] **Xcode aberto pelo menos uma vez** (a primeira abertura instala componentes adicionais).
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como verificar: o Xcode chega na tela de boas-vindas sem pedir instalação.
  - Aula: [modulos/15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md)

- [ ] **Command Line Tools instaladas.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac):
    ```bash
    xcode-select --install
    ```
  - Como verificar:
    ```bash
    xcode-select -p
    ```
  - Aula: [modulos/15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md)

- [ ] 🔴 **`xcode-select` apontando para o Xcode completo, não só para as Command Line Tools.**
  Este é o erro nº 1 de quem instalou as ferramentas antes do Xcode: o `flutter doctor`
  reclama que não encontra o Xcode mesmo com o Xcode instalado.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como corrigir (no Mac):
    ```bash
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    ```
  - Como verificar:
    ```bash
    xcode-select -p
    ```
    Esperado: `/Applications/Xcode.app/Contents/Developer`
    (e **não** `/Library/Developer/CommandLineTools`).
  - Aula: [modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md](../modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md)

- [ ] **Primeira execução do Xcode concluída pela linha de comando.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac):
    ```bash
    sudo xcodebuild -runFirstLaunch
    ```
  - Como verificar: o comando termina sem erro; repetir não pede mais nada.
  - Aula: [modulos/15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md)

- [ ] **Licença do Xcode aceita.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac):
    ```bash
    sudo xcodebuild -license accept
    ```
  - Como verificar: `xcodebuild -version` roda sem exibir o texto da licença.
  - Aula: [modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md](../modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md)

---

## 3. 🍎 Flutter no Mac

- [ ] **Flutter 3.47.1 instalado no Mac, em um caminho sem acento e sem espaço.**
  A mesma regra do Windows vale: caminho com acento ou espaço quebra ferramentas internas.
  - 🪟 **Dá para fazer no Windows? Não** (é a instalação no Mac). Mas a **regra do caminho** é a
    mesma que você já aplicou no Windows — veja
    [checklists/ambiente-android.md](ambiente-android.md), item 3.
  - Como verificar (no Mac):
    ```bash
    which flutter
    flutter --version
    ```
    Esperado: `Flutter 3.47.1 • channel stable` + `Dart 3.13.1`.
  - Aula: [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md)

- [ ] **O projeto tem a pasta `ios/` gerada.**
  Se você criou o projeto com `flutter create --platforms=android,ios <nome>`, ela já existe —
  **e você pode conferir isso agora, no Windows**.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Como verificar:

    **🪟 Windows (PowerShell)**
    ```powershell
    Test-Path .\ios\Runner.xcworkspace
    ```
    Esperado: `True`.

    **🖥️ macOS / 🐧 Linux (bash/zsh)**
    ```bash
    ls ios/Runner.xcworkspace
    ```
  - Aula: [modulos/11-recursos-nativos/07-pastas-android-e-ios.md](../modulos/11-recursos-nativos/07-pastas-android-e-ios.md)

- [ ] **Você sabe que se abre o `Runner.xcworkspace`, nunca o `Runner.xcodeproj`.**
  O `.xcworkspace` é o espaço de trabalho que junta o app às dependências nativas. Abrir o
  `.xcodeproj` direto resulta em erros de símbolo não encontrado.
  - 🪟 **Dá para fazer no Windows? Sim** (aprender e conferir o nome do arquivo; abrir, não).
  - Como fazer (no Mac):
    ```bash
    open ios/Runner.xcworkspace
    ```
  - Aula: [modulos/15-build-ios/04-bundle-id-e-xcode.md](../modulos/15-build-ios/04-bundle-id-e-xcode.md)

---

## 4. 🍎 Dependências nativas: SPM (padrão) e CocoaPods (quando precisar)

> **O que mudou:** desde o **Flutter 3.44**, o **Swift Package Manager está ligado por
> padrão**. O `flutter create` já gera `ios/Flutter/ephemeral/Packages` e
> `ios/Flutter/ephemeral/.swift_pm.lock`. Quando algum plugin do projeto ainda **não** suporta
> SPM, o Flutter **volta automaticamente para o CocoaPods** — os dois convivem.
>
> **E por que você ainda precisa aprender CocoaPods?** Porque o **registro do CocoaPods se
> torna somente-leitura em 2 de dezembro de 2026** e o projeto está em modo de manutenção —
> mas a maioria dos tutoriais, dos projetos existentes e das **mensagens de erro** que você vai
> encontrar na internet ainda fala em `pod install`. Saber ler esses erros continua sendo
> necessário.

- [ ] **Você conferiu se o SPM está habilitado.**
  - 🪟 **Dá para fazer no Windows? Sim** (a configuração é do Flutter, não do Xcode).
  - Como verificar:

    **🪟 Windows (PowerShell)**
    ```powershell
    flutter config --list
    ```

    **🖥️ macOS / 🐧 Linux (bash/zsh)**
    ```bash
    flutter config --list
    ```
    Procure `enable-swift-package-manager`.
  - Como ligar/desligar globalmente:
    ```bash
    flutter config --enable-swift-package-manager
    flutter config --no-enable-swift-package-manager
    ```
  - Como desligar **só neste projeto**, no `pubspec.yaml`:
    ```yaml
    flutter:
      config:
        enable-swift-package-manager: false
    ```
  - Aula: [modulos/15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md)

- [ ] **CocoaPods instalado no Mac** (necessário se qualquer plugin do projeto ainda não
  suportar SPM).
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac):
    ```bash
    sudo gem install cocoapods
    ```
  - Como verificar:
    ```bash
    pod --version
    ```
  - Aula: [modulos/15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md)

- [ ] **Dependências nativas resolvidas** (só quando o projeto usar CocoaPods).
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac, dentro da pasta `ios/`):
    ```bash
    pod install
    ```
  - Se der erro de repositório desatualizado:
    ```bash
    pod repo update
    ```
  - Como verificar: existe `ios/Podfile.lock` e a pasta `ios/Pods/`.
  - Aula: [modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md](../modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md)

- [ ] **(Opcional, quando todos os plugins já suportarem SPM) CocoaPods removido do projeto.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac, dentro de `ios/`):
    ```bash
    pod deintegrate
    ```
  - Aula: [modulos/15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md)

---

## 5. 🍎 Identidade do app e Info.plist (dá para adiantar TUDO no Windows)

Esta seção inteira é **editável no Windows**. É o maior ganho que você tem agora: chegar no Mac
com o projeto já configurado.

- [ ] **Bundle ID definido como `br.com.estudos.foco`** (o mesmo valor do `applicationId`
  Android, por coerência).
  - 🪟 **Dá para fazer no Windows? Sim** (definir e revisar o valor no projeto; **registrar** o
    ID no portal da Apple exige conta Apple, mas é pelo navegador — veja a seção 7).
  - Aula: [modulos/15-build-ios/04-bundle-id-e-xcode.md](../modulos/15-build-ios/04-bundle-id-e-xcode.md)

- [ ] **`version: 1.0.0+1` definido no `pubspec.yaml`.**
  O Flutter usa esse único campo para as duas plataformas:
  `1.0.0` → `CFBundleShortVersionString` (iOS) e `versionName` (Android);
  `1` → `CFBundleVersion` (iOS) e `versionCode` (Android).
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Como verificar:
    ```powershell
    Select-String -Path .\pubspec.yaml -Pattern '^version:'
    ```
  - Aula: [modulos/14-build-android/02-identidade-do-app.md](../modulos/14-build-android/02-identidade-do-app.md) ·
    [modulos/15-build-ios/05-icone-splash-versao-infoplist.md](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] **`CFBundleDisplayName` conferido no `ios/Runner/Info.plist`** (é o nome que aparece sob o
  ícone na tela inicial do iPhone).
  - 🪟 **Dá para fazer no Windows? Sim** (o `Info.plist` é um arquivo de texto XML).
  - Como verificar:
    ```powershell
    Select-String -Path .\ios\Runner\Info.plist -Pattern 'CFBundleDisplayName' -Context 0,1
    ```
  - Aula: [modulos/15-build-ios/05-icone-splash-versao-infoplist.md](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] 🔴 **Textos de permissão escritos em português e ESPECÍFICOS.**
  A Apple **rejeita** o app quando o texto é genérico ("precisamos de acesso"). Escreva o
  motivo real, voltado ao usuário final:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Precisamos da câmera para você anexar uma foto ao seu material de estudo.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Precisamos da galeria para você escolher a imagem de capa da matéria.</string>
  ```
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Como verificar:
    ```powershell
    Select-String -Path .\ios\Runner\Info.plist -Pattern 'UsageDescription'
    ```
  - Aula: [modulos/11-recursos-nativos/01-permissoes.md](../modulos/11-recursos-nativos/01-permissoes.md)

- [ ] **`SceneDelegate.swift` e o bloco `UIApplicationSceneManifest` preservados.**
  O `flutter create` do 3.47 gera `ios/Runner/SceneDelegate.swift` e o bloco
  `UIApplicationSceneManifest` no `Info.plist` (com `UISceneDelegateClassName` =
  `$(PRODUCT_MODULE_NAME).SceneDelegate` e `UISceneStoryboardFile` = `Main`).
  **Não remova.** Tutoriais antigos mandam apagar — eles são anteriores a essa mudança.
  - 🪟 **Dá para fazer no Windows? Sim** (conferir que os arquivos existem e não foram
    apagados).
  - Como verificar:
    ```powershell
    Test-Path .\ios\Runner\SceneDelegate.swift
    Select-String -Path .\ios\Runner\Info.plist -Pattern 'UIApplicationSceneManifest'
    ```
  - Aula: [modulos/15-build-ios/05-icone-splash-versao-infoplist.md](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] 🔴 **Ícone gerado sem canal alfa** (a Apple rejeita ícone com transparência).
  No `pubspec.yaml`, o bloco do gerador precisa de `remove_alpha_ios: true`:
  ```yaml
  flutter_launcher_icons:
    android: "ic_launcher"
    ios: true
    image_path: "assets/icone/icone.png"
    min_sdk_android: 24
    remove_alpha_ios: true
    adaptive_icon_background: "#3F51B5"
    adaptive_icon_foreground: "assets/icone/icone.png"
  ```
  - 🪟 **Dá para fazer no Windows? Sim** — o gerador roda no Windows e cria os PNGs de iOS.
  - Como fazer:
    ```powershell
    flutter pub get
    dart run flutter_launcher_icons
    ```
  - Como verificar:
    ```powershell
    Get-ChildItem .\ios\Runner\Assets.xcassets\AppIcon.appiconset
    ```
    Esperado: `Contents.json` + `Icon-App-1024x1024@1x.png` e os demais tamanhos
    (`20x20`, `29x29`, `40x40`, `50x50`… em `@1x`, `@2x`, `@3x`).
  - Aula: [modulos/14-build-android/03-icone.md](../modulos/14-build-android/03-icone.md) ·
    [modulos/15-build-ios/05-icone-splash-versao-infoplist.md](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] **Splash gerada** (a tela de abertura; no iOS ela é a
  `ios/Runner/Base.lproj/LaunchScreen.storyboard`).
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Como fazer:
    ```powershell
    dart run flutter_native_splash:create
    ```
  - Como verificar:
    ```powershell
    Test-Path .\ios\Runner\Base.lproj\LaunchScreen.storyboard
    ```
  - Aula: [modulos/14-build-android/04-splash-screen.md](../modulos/14-build-android/04-splash-screen.md)

---

## 6. 🍎 Simulador de iPhone

- [ ] **Simulador aberto.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac):
    ```bash
    open -a Simulator
    ```
  - Como verificar:
    ```bash
    flutter devices
    ```
    Esperado: uma linha com `iPhone ... (mobile) • ... • ios`.
  - Aula: [modulos/15-build-ios/03-simulador-e-iphone-fisico.md](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md)

- [ ] **App rodando no simulador.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac):
    ```bash
    flutter run -d <id-do-simulador>
    ```
  - Como verificar: o app abre na janela do Simulator e o *hot reload* (`r`) funciona.
  - Aula: [modulos/15-build-ios/03-simulador-e-iphone-fisico.md](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md)

> **Limite importante do simulador:** ele **não** testa câmera real, sensores, desempenho real
> nem assinatura de código. Recursos nativos precisam de aparelho físico.
> Veja [referencias/diferencas-android-ios.md](../referencias/diferencas-android-ios.md).

---

## 7. 🍎 Conta Apple, Team e assinatura

- [ ] **Apple ID criado.**
  - 🪟 **Dá para fazer no Windows? Sim** — a criação da conta é pelo navegador
    (<https://appleid.apple.com>).
  - Aula: [modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md](../modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md)

- [ ] **Você entendeu a diferença entre a conta gratuita e o Apple Developer Program (pago).**
  Resumo: com a conta **gratuita** você instala o app no **seu próprio** iPhone, e o app
  **expira em poucos dias**. Para TestFlight e App Store é obrigatório o programa **pago**.
  - 🪟 **Dá para fazer no Windows? Sim** (estudar e decidir).
  - Aula: [modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md](../modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md)

- [ ] **Apple ID adicionado ao Xcode.**
  Xcode → *Settings…* → aba **Accounts** → `+` → *Apple ID* → entre com o seu login.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como verificar: a conta aparece na lista com o Team associado.
  - Aula: [modulos/15-build-ios/07-certificados-e-provisioning.md](../modulos/15-build-ios/07-certificados-e-provisioning.md)

- [ ] **Team selecionado no alvo `Runner`.**
  Xcode → selecione o projeto `Runner` → alvo `Runner` → aba **Signing & Capabilities** →
  campo **Team** → escolha o seu (o curso escreve esse identificador sempre como `SEU_TEAM_ID`,
  nunca um valor real).
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/15-build-ios/04-bundle-id-e-xcode.md](../modulos/15-build-ios/04-bundle-id-e-xcode.md)

- [ ] **`Automatically manage signing` marcado.**
  Com isso o Xcode cria e renova sozinho o certificado e o *provisioning profile*.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como verificar: na aba *Signing & Capabilities* não há nenhum triângulo amarelo nem texto
    em vermelho.
  - Aula: [modulos/15-build-ios/07-certificados-e-provisioning.md](../modulos/15-build-ios/07-certificados-e-provisioning.md)

- [ ] **Bundle ID do Xcode igual ao definido no projeto** (`br.com.estudos.foco`).
  - 🪟 **Dá para fazer no Windows? Não** (a edição no Xcode).
  - Aula: [modulos/15-build-ios/04-bundle-id-e-xcode.md](../modulos/15-build-ios/04-bundle-id-e-xcode.md)

- [ ] **Deployment Target conferido: mínimo iOS 13 no Flutter 3.47.**
  - 🪟 **Dá para fazer no Windows? Não** (o campo fica no Xcode).
  - Aula: [modulos/15-build-ios/05-icone-splash-versao-infoplist.md](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md)

---

## 8. 🍎 iPhone físico

- [ ] **iPhone conectado por cabo e desbloqueado.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/15-build-ios/03-simulador-e-iphone-fisico.md](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md)

- [ ] **Computador "confiado" pelo iPhone.**
  Ao conectar, o iPhone pergunta *Confiar neste computador?* → toque em **Confiar** e digite a
  senha do aparelho.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como verificar (no Mac): o aparelho aparece na barra de dispositivos do Xcode sem aviso.
  - Aula: [modulos/15-build-ios/03-simulador-e-iphone-fisico.md](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md)

- [ ] 🔴 **Modo de Desenvolvedor do iOS ativado no aparelho** (iOS 16 ou mais recente).
  No iPhone: *Ajustes* → *Privacidade e Segurança* → **Modo de Desenvolvedor** → ligue →
  reinicie o aparelho → confirme depois do reinício.
  Sem isso o app instalado pelo Xcode **não abre**.
  - 🪟 **Dá para fazer no Windows? Não** (a opção só aparece depois que um Mac com Xcode
    conecta no aparelho pela primeira vez).
  - Aula: [modulos/15-build-ios/03-simulador-e-iphone-fisico.md](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md)

- [ ] **Perfil do desenvolvedor confiado no aparelho** (necessário com conta gratuita).
  iPhone → *Ajustes* → *Geral* → *VPN e Gerenciamento de Dispositivo* → toque no seu perfil →
  **Confiar**.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/15-build-ios/07-certificados-e-provisioning.md](../modulos/15-build-ios/07-certificados-e-provisioning.md)

- [ ] **App rodando no iPhone físico.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Como fazer (no Mac):
    ```bash
    flutter devices
    flutter run -d <id-do-iphone>
    ```
  - Aula: [modulos/15-build-ios/03-simulador-e-iphone-fisico.md](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md)

---

## 9. 🍎 Diagnóstico final

- [ ] **`flutter doctor` limpo nas categorias de iOS (no Mac).**
  Precisam estar `[✓]`: `Flutter`, `Xcode - develop for iOS and macOS`, `Connected device`.
  - 🪟 **Dá para fazer no Windows? Não** — no Windows o bloco `Xcode` **nem aparece**, e isso
    é o comportamento correto, não um defeito da sua instalação.
  - Como verificar (no Mac):
    ```bash
    flutter doctor -v
    ```
  - Aula: [modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md](../modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md)

- [ ] **`flutter analyze` e `flutter test` passam** — e isso **você faz no Windows**, porque
  são Dart puro, sem nada de nativo.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Como verificar:
    ```powershell
    flutter analyze
    flutter test
    ```
    Esperado: `No issues found!` e `All tests passed!`
  - Aula: [modulos/12-testes-e-debug/05-testes-unitarios.md](../modulos/12-testes-e-debug/05-testes-unitarios.md)

---

## 10. 🧪 Como provar que está tudo certo

### 🪟 O que você prova AGORA, no Windows

```powershell
flutter --version
flutter config --list
Test-Path .\ios\Runner.xcworkspace
Test-Path .\ios\Runner\SceneDelegate.swift
Select-String -Path .\ios\Runner\Info.plist -Pattern 'UsageDescription'
Select-String -Path .\pubspec.yaml -Pattern '^version:'
dart run flutter_launcher_icons
dart run flutter_native_splash:create
Get-ChildItem .\ios\Runner\Assets.xcassets\AppIcon.appiconset
flutter analyze
flutter test
```

Se tudo isso passar, o **projeto** está pronto para iOS. Falta só a **máquina**.

### 🖥️ O que você prova DEPOIS, no Mac

```bash
sw_vers
xcodebuild -version
xcode-select -p                 # /Applications/Xcode.app/Contents/Developer
flutter doctor -v
open -a Simulator
flutter devices
flutter run -d <id-do-simulador>
flutter run -d <id-do-iphone>
```

---

## 11. 📊 Tabela-resumo — "dá para fazer no Windows?"

| # | Item | Dá para fazer no Windows? | Verificação | Aula |
|---|---|---|---|---|
| 1 | Acesso a um Mac | **Não** | `sw_vers` | [15/01](../modulos/15-build-ios/01-por-que-exige-macos.md) |
| 2 | macOS compatível | **Não** | `sw_vers -productVersion` | [15/02](../modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| 3 | ~40 GB livres | **Não** | `df -h /` | [15/01](../modulos/15-build-ios/01-por-que-exige-macos.md) |
| 4 | Xcode instalado | **Não** | `xcodebuild -version` | [15/02](../modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| 5 | Command Line Tools | **Não** | `xcode-select -p` | [15/02](../modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| 6 | `xcode-select --switch` | **Não** | `xcode-select -p` | [15/10](../modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |
| 7 | `xcodebuild -runFirstLaunch` | **Não** | comando sem erro | [15/02](../modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| 8 | Licença aceita | **Não** | `xcodebuild -license accept` | [15/10](../modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |
| 9 | Pasta `ios/` presente | **Sim** | `Test-Path .\ios\Runner.xcworkspace` | [11/07](../modulos/11-recursos-nativos/07-pastas-android-e-ios.md) |
| 10 | SPM habilitado (padrão desde 3.44) | **Sim** | `flutter config --list` | [15/02](../modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| 11 | CocoaPods instalado | **Não** | `pod --version` | [15/02](../modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| 12 | `pod install` executado | **Não** | existe `ios/Podfile.lock` | [15/10](../modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |
| 13 | Bundle ID definido | **Sim** (definir) / **Não** (no Xcode) | revisão do projeto | [15/04](../modulos/15-build-ios/04-bundle-id-e-xcode.md) |
| 14 | `version: 1.0.0+1` | **Sim** | `Select-String -Path .\pubspec.yaml -Pattern '^version:'` | [15/05](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md) |
| 15 | Textos de permissão em português | **Sim** | `Select-String ... 'UsageDescription'` | [11/01](../modulos/11-recursos-nativos/01-permissoes.md) |
| 16 | `SceneDelegate.swift` preservado | **Sim** | `Test-Path .\ios\Runner\SceneDelegate.swift` | [15/05](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md) |
| 17 | Ícone sem canal alfa | **Sim** | `dart run flutter_launcher_icons` | [14/03](../modulos/14-build-android/03-icone.md) |
| 18 | Splash gerada | **Sim** | `dart run flutter_native_splash:create` | [14/04](../modulos/14-build-android/04-splash-screen.md) |
| 19 | Simulador aberto | **Não** | `open -a Simulator` | [15/03](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md) |
| 20 | App no simulador | **Não** | `flutter run -d <id>` | [15/03](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md) |
| 21 | Apple ID criado | **Sim** (navegador) | login em appleid.apple.com | [15/06](../modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md) |
| 22 | Apple ID no Xcode | **Não** | Xcode → Settings → Accounts | [15/07](../modulos/15-build-ios/07-certificados-e-provisioning.md) |
| 23 | Team selecionado | **Não** | Signing & Capabilities | [15/04](../modulos/15-build-ios/04-bundle-id-e-xcode.md) |
| 24 | Automatic signing | **Não** | sem aviso amarelo no Xcode | [15/07](../modulos/15-build-ios/07-certificados-e-provisioning.md) |
| 25 | Deployment Target ≥ iOS 13 | **Não** | campo no Xcode | [15/05](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md) |
| 26 | iPhone confiado | **Não** | diálogo no aparelho | [15/03](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md) |
| 27 | Modo de Desenvolvedor do iOS | **Não** | Ajustes → Privacidade e Segurança | [15/03](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md) |
| 28 | App no iPhone físico | **Não** | `flutter run -d <id>` | [15/03](../modulos/15-build-ios/03-simulador-e-iphone-fisico.md) |
| 29 | `flutter doctor` limpo (iOS) | **Não** | `flutter doctor -v` | [15/10](../modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |
| 30 | `flutter analyze` + `flutter test` | **Sim** | os dois comandos | [12/05](../modulos/12-testes-e-debug/05-testes-unitarios.md) |

**Contagem:** 11 itens você faz **hoje, no Windows**. 19 ficam para o dia do Mac.
Isso é mais de um terço do trabalho adiantado — e é exatamente o terço que costuma dar erro
chato (ícone com alfa, texto de permissão genérico, versão errada).

---

## 12. 🔴 Regras de segurança que valem desde já

- [ ] **Nenhum `.p12`, `.cer`, `.mobileprovision`, `.p8` ou senha no Git.**
  Esses arquivos são a sua identidade de desenvolvedor: quem os tem publica app no seu nome.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Como verificar:
    ```powershell
    git check-ignore -v ios\Runner\exemplo.mobileprovision
    git ls-files | Select-String '\.(p12|cer|mobileprovision|p8)$'
    ```
    Esperado: o primeiro comando confirma que o padrão está no `.gitignore`; o segundo **não
    devolve nada**.
  - Aula: [modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md) ·
    [modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md)

- [ ] **Nada de Team ID, API Key ou Issuer ID reais escritos em arquivo versionado.**
  Use sempre marcadores: `SEU_TEAM_ID`, `SUA_API_KEY`, `SEU_ISSUER_ID`, `<seu-usuario>`.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Aula: [modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md)

---

## 13. E se eu nunca tiver um Mac?

Opções honestas, com as respectivas limitações:

| Opção | O que resolve | Limitação real |
|---|---|---|
| Mac emprestado por algumas horas | build, assinatura, upload | você precisa da conta Apple no Mac |
| Mac alugado na nuvem (serviços de "Mac em nuvem") | tudo, remotamente | custo por hora/mês |
| CI/CD com runner macOS | build e upload automatizados | exige configuração prévia; veja [modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md](../modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md) |
| Publicar só na Google Play por enquanto | entrega real, hoje | nenhum usuário iPhone |

O código Flutter que você escreve neste curso é **o mesmo** nas duas plataformas. Nenhuma linha
do projeto Foco precisa ser reescrita para iOS. O que falta é exclusivamente a **etapa de
compilação e assinatura** — e ela é curta quando o projeto já está arrumado.

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [Checklist — Ambiente Android](ambiente-android.md) | [Índice geral](../README.md) | [Checklist — Projeto final](projeto-final.md) |
