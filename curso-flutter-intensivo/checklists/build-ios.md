# 🍎 Checklist — Build iOS, IPA, TestFlight e App Store

> ## 🍎 LEIA ANTES DE TUDO: gerar o `.ipa` exige **macOS + Xcode**.
>
> **Você está no Windows 11.** O empacotador (`xcodebuild`), o assinador (`codesign`) e o
> Organizer da Apple só existem para macOS. **Este curso não vai prometer que você gera um IPA
> no Windows. Você não gera — e nenhuma página deste curso vai dizer o contrário.**
>
> **O que este checklist entrega para você hoje:**
> - **11 itens você executa AGORA, no Windows** — toda a preparação do projeto: Bundle ID,
>   versão, `Info.plist`, textos de permissão em português, ícone sem canal alfa, splash,
>   `.gitignore` de segredos, análise e testes.
> - **Os demais itens são a parte de máquina** — Xcode, assinatura, archive, IPA, upload. Você
>   **lê e entende agora**, executa no dia do Mac.
>
> Cada item traz a linha **🪟 Dá para fazer no Windows? Sim/Não**, e há uma tabela-resumo com
> essa coluna no fim da página.
>
> Por que é assim: [modulos/16-build-ios/01-por-que-exige-macos.md](../modulos/16-build-ios/01-por-que-exige-macos.md)
> Ambiente iOS passo a passo: [checklists/ambiente-ios.md](ambiente-ios.md)

---

## Como usar

- Marque `- [x]` só depois de rodar a verificação.
- Comandos `powershell` rodam no Windows; comandos `bash` rodam no Terminal do macOS.
- 🔴 **Nenhum valor real de Team ID, senha, API Key ou certificado aparece aqui.** Onde houver
  `SEU_TEAM_ID`, `SUA_API_KEY`, `SEU_ISSUER_ID` ou `<seu-usuario>`, use o seu valor — e nunca o
  escreva em arquivo versionado.

### Termos explicados na primeira vez

- **IPA** (*iOS App Store Package*) — o pacote instalável do iOS, equivalente ao APK do Android.
- **Archive** (arquivo morto) — o pacote intermediário `.xcarchive` que o Xcode produz antes de
  exportar o IPA. É dele que saem a validação e o envio.
- **Organizer** — a janela do Xcode (menu *Window → Organizer*) que lista os archives e oferece
  *Validate App* e *Distribute App*.
- **Certificado** — o documento digital que prova que você é você para a Apple.
- **Provisioning profile** (perfil de provisionamento) — o arquivo que amarra três coisas:
  o certificado, o Bundle ID e os aparelhos autorizados.
- **Build number** — o `CFBundleVersion`. É o número que **precisa crescer** a cada envio.
- **TestFlight** — o serviço da Apple para distribuir versões de teste a convidados, antes da
  loja.
- **Transporter** — o app gratuito da Apple, na Mac App Store, que envia o IPA para o App Store
  Connect com interface gráfica.
- **`altool`** — a alternativa por linha de comando ao Transporter.

---

## PARTE 1 — PRÉ-BUILD (a maior parte roda no Windows)

### 1.1 Identidade do app

- [ ] 🔴 **Bundle ID definitivo: `br.com.estudos.foco`.**
  O valor gerado pelo `flutter create` é `com.example.foco`. Depois de publicado, o Bundle ID
  **nunca** muda: mudar significa outro app, do zero.
  - 🪟 **Dá para fazer no Windows? Sim** (definir o valor no projeto).
  - Verificar:
    ```powershell
    Select-String -Path .\ios\Runner.xcodeproj\project.pbxproj -Pattern 'PRODUCT_BUNDLE_IDENTIFIER'
    ```
    Esperado: nenhuma ocorrência de `com.example`.
  - Aula: [modulos/16-build-ios/04-bundle-id-e-xcode.md](../modulos/16-build-ios/04-bundle-id-e-xcode.md)

- [ ] **Bundle ID registrado no portal da Apple** (*Certificates, Identifiers & Profiles* →
  *Identifiers*), ou criado automaticamente pelo Xcode com *automatic signing*.
  - 🪟 **Dá para fazer no Windows? Parcialmente** — o registro manual é pelo navegador, e isso
    funciona no Windows; a criação automática acontece dentro do Xcode, que não.
  - Verificar: o identificador aparece na lista do portal.
  - Aula: [modulos/16-build-ios/07-certificados-e-provisioning.md](../modulos/16-build-ios/07-certificados-e-provisioning.md)

- [ ] **`version: 1.0.0+1` no `pubspec.yaml`.**
  No iOS, `1.0.0` alimenta `CFBundleShortVersionString` e `1` alimenta `CFBundleVersion`. É o
  mesmo campo que no Android vira `versionName` e `versionCode`.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Verificar:
    ```powershell
    Select-String -Path .\pubspec.yaml -Pattern '^version:'
    ```
  - Aula: [modulos/16-build-ios/05-icone-splash-versao-infoplist.md](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] **`Info.plist` usa as variáveis do Flutter para versão** (não valores fixos).
  Esperado: `CFBundleShortVersionString` = `$(FLUTTER_BUILD_NAME)` e `CFBundleVersion` =
  `$(FLUTTER_BUILD_NUMBER)`. Se alguém trocou por números fixos, o `pubspec.yaml` deixa de
  controlar a versão e você vai enviar builds repetidos sem perceber.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Verificar:
    ```powershell
    Select-String -Path .\ios\Runner\Info.plist -Pattern 'FLUTTER_BUILD_NAME|FLUTTER_BUILD_NUMBER'
    ```
  - Aula: [modulos/16-build-ios/05-icone-splash-versao-infoplist.md](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] **`CFBundleDisplayName` = `Foco`** (o nome sob o ícone na tela inicial do iPhone).
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Verificar:
    ```powershell
    Select-String -Path .\ios\Runner\Info.plist -Pattern 'CFBundleDisplayName' -Context 0,1
    ```
  - Aula: [modulos/16-build-ios/05-icone-splash-versao-infoplist.md](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] **`SceneDelegate.swift` e `UIApplicationSceneManifest` intactos.**
  O `flutter create` do 3.47 gera `ios/Runner/SceneDelegate.swift` e o bloco
  `UIApplicationSceneManifest` no `Info.plist`. **Não remova** — tutoriais que mandam apagar
  são anteriores a essa mudança.
  - 🪟 **Dá para fazer no Windows? Sim** (conferir).
  - Verificar:
    ```powershell
    Test-Path .\ios\Runner\SceneDelegate.swift
    Select-String -Path .\ios\Runner\Info.plist -Pattern 'UIApplicationSceneManifest'
    ```
  - Aula: [modulos/16-build-ios/05-icone-splash-versao-infoplist.md](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] **Deployment Target definido (mínimo iOS 13 no Flutter 3.47).**
  - 🪟 **Dá para fazer no Windows? Não** (o campo fica no Xcode, em *General → Minimum
    Deployments*).
  - Aula: [modulos/16-build-ios/05-icone-splash-versao-infoplist.md](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

### 1.2 🔴 Ícone e splash

- [ ] 🔴 **Ícone gerado SEM canal alfa.**
  A Apple **rejeita** ícone com transparência. A configuração do curso já traz
  `remove_alpha_ios: true`:
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
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Executar e verificar:
    ```powershell
    Select-String -Path .\pubspec.yaml -Pattern 'remove_alpha_ios'
    flutter pub get
    dart run flutter_launcher_icons
    Get-ChildItem .\ios\Runner\Assets.xcassets\AppIcon.appiconset
    ```
    Esperado: `Contents.json` + `Icon-App-1024x1024@1x.png` e os tamanhos `20x20`, `29x29`,
    `40x40`, `50x50`… em `@1x`, `@2x` e `@3x`.
    (`@1x`, `@2x`, `@3x` são as escalas de tela da Apple: tamanho em pontos × escala = pixels.
    iPhone moderno usa `@3x`.)
  - Aula: [modulos/15-build-android/03-icone.md](../modulos/15-build-android/03-icone.md) ·
    [modulos/16-build-ios/05-icone-splash-versao-infoplist.md](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

- [ ] **Imagem de origem correta:** PNG quadrado **1024×1024**, sem transparência.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Verificar:
    ```powershell
    Get-ChildItem .\assets\icone\icone.png | Select-Object Name, Length
    ```
  - Aula: [modulos/15-build-android/03-icone.md](../modulos/15-build-android/03-icone.md)

- [ ] **Splash gerada** (no iOS ela é a `LaunchScreen.storyboard`; o gerador também ajusta a
  barra de status no `Info.plist`).
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Executar e verificar:
    ```powershell
    dart run flutter_native_splash:create
    Test-Path .\ios\Runner\Base.lproj\LaunchScreen.storyboard
    ```
  - Aula: [modulos/15-build-android/04-splash-screen.md](../modulos/15-build-android/04-splash-screen.md)

### 1.3 🔴 Textos de permissão no `Info.plist`

- [ ] 🔴 **Toda permissão usada tem um texto ESPECÍFICO, em português.**
  A Apple **rejeita** o app quando o texto é genérico ("precisamos de acesso"). Escreva o
  motivo real, voltado ao usuário final:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Precisamos da câmera para você anexar uma foto ao seu material de estudo.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Precisamos da galeria para você escolher a imagem de capa da matéria.</string>
  ```
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Verificar:
    ```powershell
    Select-String -Path .\ios\Runner\Info.plist -Pattern 'UsageDescription' -Context 0,1
    ```
  - Aula: [modulos/11-recursos-nativos/01-permissoes.md](../modulos/11-recursos-nativos/01-permissoes.md)

- [ ] **Nenhuma chave `UsageDescription` sobrando** para permissão que o app não usa. Declarar
  permissão sem usar é motivo de recusa.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Aula: [modulos/11-recursos-nativos/01-permissoes.md](../modulos/11-recursos-nativos/01-permissoes.md)

### 1.4 🔴 Segredos fora do Git

Certificado e perfil são a **sua identidade de desenvolvedor**. Quem os tem assina apps no seu
nome.

- [ ] 🔴 **`.gitignore` cobre `*.p12`, `*.cer`, `*.mobileprovision`, `*.p8`, `.env`.**
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Verificar:
    ```powershell
    Select-String -Path .\.gitignore -Pattern '\*\.p12|\*\.cer|\*\.mobileprovision|\*\.p8'
    ```
  - Aula: [modulos/00-git-e-terminal/04-commits-branches-gitignore.md](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

- [ ] 🔴 **`git check-ignore` CONFIRMA a exclusão.**
  O `.gitignore` só vale para arquivos que o Git ainda não rastreia; o comando abaixo é a prova.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Executar:
    ```powershell
    git check-ignore -v ios/Runner/exemplo.mobileprovision
    git check-ignore -v certificado.p12
    git check-ignore -v certificado.cer
    ```
    **Esperado:** cada comando devolve uma linha citando o `.gitignore`, a linha e o padrão.
    **Se não devolver nada, o arquivo NÃO está ignorado.** Corrija antes de continuar.
  - Aula: [modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md)

- [ ] 🔴 **Nenhum certificado já rastreado pelo Git.**
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Executar (**não pode devolver nada**):
    ```powershell
    git ls-files | Select-String -Pattern '\.(p12|cer|mobileprovision|p8)$'
    ```
    Se devolver algo, o arquivo está no histórico: remova com `git rm --cached <arquivo>`, faça
    commit, **revogue o certificado no portal da Apple** e gere um novo.
  - Aula: [modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md)

- [ ] **Nenhum Team ID, API Key ou Issuer ID real em arquivo versionado.**
  Use sempre `SEU_TEAM_ID`, `SUA_API_KEY`, `SEU_ISSUER_ID`.
  - 🪟 **Dá para fazer no Windows? Sim.**
  - Executar (**não pode devolver nada com valor real**):
    ```powershell
    git ls-files | ForEach-Object { Select-String -Path $_ -Pattern 'DEVELOPMENT_TEAM|apiKey|apiIssuer' }
    ```
  - Aula: [modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md)

### 1.5 Qualidade

- [ ] **Análise, formatação e testes passando.**
  - 🪟 **Dá para fazer no Windows? Sim** — é Dart puro, não depende de nada da Apple.
  - Executar:
    ```powershell
    flutter analyze
    dart format --output=none --set-exit-if-changed .
    flutter test
    ```
    Esperado: `No issues found!` e `All tests passed!`
  - Aula: [checklists/projeto-final.md](projeto-final.md)

---

## PARTE 2 — ASSINATURA (🖥️ só no Mac)

> 🍎 **SÓ NO MAC.** Esta parte inteira exige macOS + Xcode. No Windows você pode ler e entender
> o processo, mas não executá-lo. Veja o que fazer enquanto isso em
> [modulos/16-build-ios/01-por-que-exige-macos.md](../modulos/16-build-ios/01-por-que-exige-macos.md).

- [ ] **Apple Developer Program ativo** (o programa **pago**).
  A conta gratuita instala o app no seu próprio iPhone, mas **expira em poucos dias** e não
  serve para TestFlight nem App Store.
  - 🪟 **Dá para fazer no Windows? Sim** (a assinatura do programa é pelo navegador).
  - Aula: [modulos/16-build-ios/06-conta-apple-gratuita-x-paga.md](../modulos/16-build-ios/06-conta-apple-gratuita-x-paga.md)

- [ ] **Team selecionado no alvo `Runner`.**
  Xcode → projeto `Runner` → alvo `Runner` → **Signing & Capabilities** → campo **Team**
  (o seu; este curso escreve `SEU_TEAM_ID`).
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/16-build-ios/04-bundle-id-e-xcode.md](../modulos/16-build-ios/04-bundle-id-e-xcode.md)

- [ ] **`Automatically manage signing` marcado.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Verificar: nenhum triângulo amarelo nem texto vermelho na aba *Signing & Capabilities*.
  - Aula: [modulos/16-build-ios/07-certificados-e-provisioning.md](../modulos/16-build-ios/07-certificados-e-provisioning.md)

- [ ] **Certificado de distribuição válido e não expirado.**
  - 🪟 **Dá para fazer no Windows? Não** (a criação/instalação é no Chaveiro do macOS; a
    consulta do status no portal é pelo navegador).
  - Verificar (no Mac): Xcode → *Settings… → Accounts → Manage Certificates*.
  - Aula: [modulos/16-build-ios/07-certificados-e-provisioning.md](../modulos/16-build-ios/07-certificados-e-provisioning.md)

- [ ] **Provisioning profile válido, casando com o Bundle ID `br.com.estudos.foco`.**
  Erro típico quando não casa: `No profiles for 'br.com.estudos.foco' were found`.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/16-build-ios/10-diagnostico-cocoapods-e-assinatura.md](../modulos/16-build-ios/10-diagnostico-cocoapods-e-assinatura.md)

- [ ] **Dependências nativas resolvidas.**
  Desde o **Flutter 3.44** o **Swift Package Manager é o padrão** e resolve sozinho; o Flutter
  cai automaticamente para **CocoaPods** se algum plugin ainda não suportar SPM. Se o projeto
  usar CocoaPods, rode:
  ```bash
  cd ios
  pod install
  # se reclamar de repositório desatualizado:
  pod repo update
  ```
  - 🪟 **Dá para fazer no Windows? Não** (`pod` só existe no Mac). Mas **conferir a
    configuração do SPM você faz agora**:
    ```powershell
    flutter config --list
    ```
  - Lembre: o **registro do CocoaPods se torna somente-leitura em 2 de dezembro de 2026** e o
    projeto está em modo de manutenção — por isso SPM é o caminho principal, e CocoaPods é
    conhecimento para projetos existentes e mensagens de erro.
  - Aula: [modulos/16-build-ios/02-xcode-e-cocoapods.md](../modulos/16-build-ios/02-xcode-e-cocoapods.md)

---

## PARTE 3 — BUILD (🖥️ só no Mac)

- [ ] **`flutter clean` executado antes do build.**
  Os geradores de ícone e splash mexem em recursos nativos, e o Xcode pode usar cache antigo.
  - 🪟 **Dá para fazer no Windows? Sim** (o comando roda; mas o build seguinte, não).
  - Executar:
    ```bash
    flutter clean
    flutter pub get
    ```
  - Aula: [modulos/16-build-ios/08-build-ipa-e-archive.md](../modulos/16-build-ios/08-build-ipa-e-archive.md)

- [ ] **`flutter build ipa` concluído.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Executar (no Mac):
    ```bash
    flutter build ipa
    ```
    Variações oficiais:
    ```bash
    flutter build ipa --export-method app-store-connect
    flutter build ipa --export-options-plist=caminho/ExportOptions.plist
    flutter build ipa --build-name=1.0.0 --build-number=1
    ```
  - Aula: [modulos/16-build-ios/08-build-ipa-e-archive.md](../modulos/16-build-ios/08-build-ipa-e-archive.md)

- [ ] **Archive criado em `build/ios/archive/Runner.xcarchive`.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Verificar (no Mac):
    ```bash
    ls -d build/ios/archive/Runner.xcarchive
    ```
  - Aula: [modulos/16-build-ios/08-build-ipa-e-archive.md](../modulos/16-build-ios/08-build-ipa-e-archive.md)

- [ ] **IPA gerado em `build/ios/ipa/`.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Verificar (no Mac):
    ```bash
    ls -lh build/ios/ipa/
    ```
    Esperado: um arquivo `<nome>.ipa`.
  - Aula: [modulos/16-build-ios/09-exportando-ipa-e-testflight.md](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md)

- [ ] **Tamanho do IPA conferido e anotado.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md](../modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md)

---

## PARTE 4 — VALIDAÇÃO E EXPORTAÇÃO (🖥️ só no Mac)

- [ ] **Archive aberto no Organizer.**
  Xcode → menu *Window* → **Organizer** → aba *Archives*. Se você quiser abrir o projeto:
  ```bash
  open ios/Runner.xcworkspace
  ```
  (sempre o `.xcworkspace`, **nunca** o `.xcodeproj`)
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/16-build-ios/08-build-ipa-e-archive.md](../modulos/16-build-ios/08-build-ipa-e-archive.md)

- [ ] 🔴 **`Validate App` executado no Organizer, SEM erros.**
  A validação roda as mesmas checagens do envio, mas em segundos. É aqui que aparecem: ícone
  com canal alfa, texto de permissão genérico, build number repetido, perfil errado.
  **Sempre valide antes de enviar.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/16-build-ios/09-exportando-ipa-e-testflight.md](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md)

- [ ] **IPA exportado pelo Organizer** (*Distribute App*), ou já obtido pelo
  `flutter build ipa`.
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/16-build-ios/09-exportando-ipa-e-testflight.md](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md)

- [ ] 🔴 **Build number NOVO e MAIOR que o do envio anterior.**
  O App Store Connect **recusa** um `CFBundleVersion` já usado. Cada envio, mesmo corrigindo
  uma vírgula, precisa de um número maior. Incremente o `+N` do `version:` no `pubspec.yaml`
  (`1.0.0+1` → `1.0.0+2`) ou passe na linha de comando:
  ```bash
  flutter build ipa --build-name=1.0.0 --build-number=2
  ```
  - 🪟 **Dá para fazer no Windows? Sim** — incrementar o número no `pubspec.yaml` é edição de
    texto. Enviar, não.
  - Verificar:
    ```powershell
    Select-String -Path .\pubspec.yaml -Pattern '^version:'
    ```
  - Aula: [modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md](../modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md)

---

## PARTE 5 — ENVIO E TESTFLIGHT (🖥️ só no Mac)

- [ ] **App criado no App Store Connect** com o mesmo Bundle ID.
  - 🪟 **Dá para fazer no Windows? Sim** — o App Store Connect é um site, e abre no navegador do
    Windows. O que não abre é o Xcode.
  - Aula: [modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md)

- [ ] **IPA enviado por Transporter OU por `altool`.**
  **Transporter:** app gratuito na Mac App Store — arraste o `.ipa`, clique em *Deliver*.
  **Linha de comando:**
  ```bash
  xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa \
    --apiKey SUA_API_KEY --apiIssuer SEU_ISSUER_ID
  ```
  🔴 `SUA_API_KEY` e `SEU_ISSUER_ID` são marcadores. Os valores reais ficam na sua conta e
  **nunca** entram em arquivo versionado.
  - 🪟 **Dá para fazer no Windows? Não** (Transporter e `xcrun` são macOS).
  - Aula: [modulos/16-build-ios/09-exportando-ipa-e-testflight.md](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md)

- [ ] **Build processado no App Store Connect** (leva de minutos a algumas horas; o status sai
  de *Processing*).
  - 🪟 **Dá para fazer no Windows? Sim** (acompanhar pelo site).
  - Aula: [modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md)

- [ ] **Informações de conformidade de exportação respondidas** (a pergunta sobre uso de
  criptografia). Sem responder, o build não fica disponível no TestFlight.
  - 🪟 **Dá para fazer no Windows? Sim** (pelo site).
  - Aula: [modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md)

- [ ] **TestFlight configurado** com "O que testar" preenchido em português.
  - 🪟 **Dá para fazer no Windows? Sim** (pelo site).
  - Aula: [modulos/16-build-ios/09-exportando-ipa-e-testflight.md](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md)

- [ ] **Pelo menos 1 testador convidado, e o convite aceito.**
  - 🪟 **Dá para fazer no Windows? Sim** (convidar pelo site). Instalar o app, só em iPhone.
  - Verificar: o testador instalou pelo app TestFlight e abriu o Foco.
  - Aula: [modulos/16-build-ios/09-exportando-ipa-e-testflight.md](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md)

- [ ] **App testado no iPhone do testador: offline, modo escuro, fonte grande.**
  - 🪟 **Dá para fazer no Windows? Não.**
  - Aula: [modulos/13-desempenho-e-seguranca/05-acessibilidade.md](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

---

## PARTE 6 — Checklist pré-App Store

- [ ] **Apple Developer Program ativo e pago.** — 🪟 **Sim** (site)
- [ ] **Bundle ID definitivo e registrado.** — 🪟 **Sim** (definir/registrar pelo site)
- [ ] **Build validado sem erros no Organizer.** — 🪟 **Não**
- [ ] **Build number maior que o anterior.** — 🪟 **Sim** (editar o `pubspec.yaml`)
- [ ] **Ícone 1024×1024 sem canal alfa.** — 🪟 **Sim**
- [ ] **Capturas de tela nos tamanhos exigidos pela Apple** (pelo menos um tamanho de iPhone).
  — 🪟 **Não** (precisam vir de simulador ou aparelho iOS)
- [ ] **Nome, subtítulo, descrição e palavras-chave em português.** — 🪟 **Sim**
- [ ] **Política de privacidade publicada em uma URL acessível.** — 🪟 **Sim**
- [ ] **Ficha "Privacidade do app" preenchida** (o Foco guarda dados só no aparelho; declare
  exatamente isso). — 🪟 **Sim**
- [ ] **Classificação etária respondida.** — 🪟 **Sim**
- [ ] **Textos de permissão específicos e em português** (motivo nº 1 de recusa). — 🪟 **Sim**
- [ ] **Informações de contato para a revisão preenchidas.** — 🪟 **Sim**
- [ ] **Nenhum recurso pela metade, nenhuma tela com texto de teste.** — 🪟 **Sim**
- [ ] **Testado em TestFlight antes de enviar para revisão.** — 🪟 **Não**
- [ ] **Nada sensível no Git** (conferido na Parte 1.4). — 🪟 **Sim**

Detalhes: [modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md)

---

## 📊 Tabela-resumo — "dá para fazer no Windows?"

| # | Item | Dá para fazer no Windows? | Verificação | Aula |
|---|---|---|---|---|
| 1 | Bundle ID definitivo no projeto | **Sim** | `Select-String ... PRODUCT_BUNDLE_IDENTIFIER` | [16/04](../modulos/16-build-ios/04-bundle-id-e-xcode.md) |
| 2 | Bundle ID registrado no portal | **Sim** (navegador) | consta em *Identifiers* | [16/07](../modulos/16-build-ios/07-certificados-e-provisioning.md) |
| 3 | `version: 1.0.0+1` | **Sim** | `Select-String -Path .\pubspec.yaml -Pattern '^version:'` | [16/05](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md) |
| 4 | `Info.plist` com variáveis do Flutter | **Sim** | `Select-String ... FLUTTER_BUILD_NAME` | [16/05](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md) |
| 5 | `CFBundleDisplayName` = Foco | **Sim** | `Select-String ... CFBundleDisplayName` | [16/05](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md) |
| 6 | `SceneDelegate.swift` preservado | **Sim** | `Test-Path .\ios\Runner\SceneDelegate.swift` | [16/05](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md) |
| 7 | Deployment Target ≥ iOS 13 | **Não** | campo no Xcode | [16/05](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md) |
| 8 | Ícone sem canal alfa | **Sim** | `dart run flutter_launcher_icons` | [15/03](../modulos/15-build-android/03-icone.md) |
| 9 | Splash gerada | **Sim** | `Test-Path ...LaunchScreen.storyboard` | [15/04](../modulos/15-build-android/04-splash-screen.md) |
| 10 | Textos de permissão em português | **Sim** | `Select-String ... UsageDescription` | [11/01](../modulos/11-recursos-nativos/01-permissoes.md) |
| 11 | Segredos fora do Git | **Sim** | `git check-ignore -v ...` | [00/05](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md) |
| 12 | `flutter analyze` + `flutter test` | **Sim** | os dois comandos | [12/05](../modulos/12-testes-e-debug/05-testes-unitarios.md) |
| 13 | Apple Developer Program pago | **Sim** (site) | conta ativa | [16/06](../modulos/16-build-ios/06-conta-apple-gratuita-x-paga.md) |
| 14 | Team selecionado | **Não** | Signing & Capabilities | [16/04](../modulos/16-build-ios/04-bundle-id-e-xcode.md) |
| 16 | Automatic signing | **Não** | sem aviso no Xcode | [16/07](../modulos/16-build-ios/07-certificados-e-provisioning.md) |
| 16 | Certificado válido | **Não** | Manage Certificates | [16/07](../modulos/16-build-ios/07-certificados-e-provisioning.md) |
| 17 | Provisioning profile válido | **Não** | sem erro `No profiles for ...` | [16/10](../modulos/16-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |
| 18 | SPM conferido | **Sim** | `flutter config --list` | [16/02](../modulos/16-build-ios/02-xcode-e-cocoapods.md) |
| 19 | `pod install` (quando necessário) | **Não** | existe `ios/Podfile.lock` | [16/02](../modulos/16-build-ios/02-xcode-e-cocoapods.md) |
| 20 | `flutter clean` | **Sim** | comando conclui | [16/08](../modulos/16-build-ios/08-build-ipa-e-archive.md) |
| 21 | `flutter build ipa` | **Não** | build conclui no Mac | [16/08](../modulos/16-build-ios/08-build-ipa-e-archive.md) |
| 22 | Archive em `build/ios/archive/` | **Não** | `ls -d build/ios/archive/Runner.xcarchive` | [16/08](../modulos/16-build-ios/08-build-ipa-e-archive.md) |
| 23 | IPA em `build/ios/ipa/` | **Não** | `ls -lh build/ios/ipa/` | [16/09](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md) |
| 24 | `Validate App` no Organizer | **Não** | validação sem erros | [16/09](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md) |
| 25 | Exportar IPA | **Não** | *Distribute App* | [16/09](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md) |
| 26 | Build number novo e maior | **Sim** (editar) / **Não** (enviar) | `Select-String ... '^version:'` | [17/03](../modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md) |
| 27 | Upload por Transporter ou `altool` | **Não** | build aparece no ASC | [16/09](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md) |
| 28 | App criado no App Store Connect | **Sim** (site) | app listado | [17/02](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md) |
| 29 | TestFlight configurado | **Sim** (site) | build disponível para teste | [16/09](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md) |
| 30 | Testador convidado | **Sim** (convite) / **Não** (instalar) | convite aceito | [16/09](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md) |
| 31 | Capturas de tela para a loja | **Não** | imagens nos tamanhos da Apple | [17/02](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md) |
| 32 | Ficha da loja (textos, privacidade) | **Sim** (site) | campos preenchidos | [17/02](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md) |

**Placar:** **17 de 32 itens você faz no Windows.** Os outros 15 são a parte de máquina Apple.

---

## 🧪 Como provar o que dá para provar hoje (no Windows)

```powershell
# Identidade
Select-String -Path .\ios\Runner.xcodeproj\project.pbxproj -Pattern 'PRODUCT_BUNDLE_IDENTIFIER'
Select-String -Path .\pubspec.yaml -Pattern '^version:'
Select-String -Path .\ios\Runner\Info.plist -Pattern 'FLUTTER_BUILD_NAME|FLUTTER_BUILD_NUMBER'
Select-String -Path .\ios\Runner\Info.plist -Pattern 'CFBundleDisplayName' -Context 0,1
Test-Path .\ios\Runner\SceneDelegate.swift

# Permissões
Select-String -Path .\ios\Runner\Info.plist -Pattern 'UsageDescription' -Context 0,1

# Ícone e splash
Select-String -Path .\pubspec.yaml -Pattern 'remove_alpha_ios'
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
Get-ChildItem .\ios\Runner\Assets.xcassets\AppIcon.appiconset
Test-Path .\ios\Runner\Base.lproj\LaunchScreen.storyboard

# Segredos (os check-ignore PRECISAM responder; o ls-files NÃO pode devolver nada)
git check-ignore -v certificado.p12
git check-ignore -v ios/Runner/exemplo.mobileprovision
git ls-files | Select-String -Pattern '\.(p12|cer|mobileprovision|p8)$'

# Qualidade
flutter analyze
flutter test
```

## 🖥️ E a sequência do dia do Mac

```bash
xcode-select -p                 # /Applications/Xcode.app/Contents/Developer
flutter doctor -v
flutter clean
flutter pub get
cd ios && pod install && cd ..  # só se o projeto usar CocoaPods
flutter build ipa
ls -d build/ios/archive/Runner.xcarchive
ls -lh build/ios/ipa/
open ios/Runner.xcworkspace     # Window -> Organizer -> Validate App -> Distribute App
```

---

## Se falhar

| Mensagem / sintoma | Causa provável | Onde resolver |
|---|---|---|
| `No profiles for 'br.com.estudos.foco' were found` | Bundle ID não registrado ou Team errado | Parte 2 · [16/10](../modulos/16-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |
| Validação reclama de canal alfa no ícone | faltou `remove_alpha_ios: true` | Item 1.2 |
| Recusa por texto de permissão genérico | `UsageDescription` vago | Item 1.3 |
| `The bundle version must be higher than...` | build number repetido | Parte 4 |
| `xcodebuild` não encontrado / Xcode não detectado | `xcode-select` apontando para as Command Line Tools | [checklists/ambiente-ios.md](ambiente-ios.md), item 2 |
| Erro de CocoaPods ao resolver dependências | repositório desatualizado | `pod repo update` · [16/10](../modulos/16-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |
| Ícone antigo no IPA | faltou `flutter clean` | Parte 3 |
| Build sumiu do TestFlight | conformidade de exportação não respondida | Parte 5 |

Catálogo completo: [referencias/erros-comuns.md](../referencias/erros-comuns.md) ·
Diferenças entre as plataformas: [referencias/diferencas-android-ios.md](../referencias/diferencas-android-ios.md)

---

## Enquanto o Mac não vem

Você **não** fica parado. O caminho honesto e produtivo:

1. **Publique o Android primeiro** — é 100% viável no seu Windows hoje:
   [checklists/build-android.md](build-android.md).
2. **Deixe o projeto iOS pronto** — os 17 itens marcados acima significam que, no Mac, o
   trabalho restante é de horas, não de dias.
3. **Estude a automação** — um serviço de integração contínua com runner macOS faz o build iOS
   sem você ter um Mac na mesa:
   [modulos/17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md](../modulos/17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md).
4. **Continue testando tudo o que é independente de plataforma** — lógica, banco (com
   `sqflite_common_ffi`, no Windows), widgets e integração rodam sem iPhone nenhum:
   [modulos/12-testes-e-debug/08-testes-de-integracao.md](../modulos/12-testes-e-debug/08-testes-de-integracao.md).

O código Flutter do Foco é o mesmo nas duas plataformas. O que falta é exclusivamente a etapa
de compilação e assinatura — e ela é curta quando o projeto já está arrumado.

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [Checklist — Build Android](build-android.md) | [Índice geral](../README.md) | [Checklist — Ambiente Android](ambiente-android.md) |
