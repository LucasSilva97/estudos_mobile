# Aula 5 — Ícone, splash, versão e Info.plist

> **Módulo:** 15 - Build e Distribuição iOS · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Gerar o **`AppIcon.appiconset`** completo com `flutter_launcher_icons`, **no Windows**.
- Entender por que o iOS **rejeita ícone com transparência** e o que faz o `remove_alpha_ios`.
- Gerar a splash com `flutter_native_splash` e conhecer o **`LaunchScreen.storyboard`**.
- Definir a versão uma única vez no `pubspec.yaml` e deixá-la fluir via
  **`$(FLUTTER_BUILD_NAME)`**.
- Escrever as **chaves de permissão** do `Info.plist` em português, sem receber rejeição.
- Configurar nome exibido, orientações e demais chaves obrigatórias.

## ✅ Pré-requisitos

- [Aula 4 — Bundle ID e o Xcode](04-bundle-id-e-xcode.md) — `br.com.estudos.foco` já definido.
- [Módulo 14, aula 3 — Ícone](../14-build-android/03-icone.md) e
  [aula 4 — Splash screen](../14-build-android/04-splash-screen.md) — o mesmo PNG 1024×1024 serve
  para as duas plataformas.
- [Módulo 14, aula 5 — Permissões Android](../14-build-android/05-permissoes-android.md) — o
  `Info.plist` é o equivalente do `AndroidManifest.xml`.
- Um PNG de **1024 × 1024**, sem transparência, em `assets/icone/`.

---

## 🍎🪟 Antes de começar: onde você está

> # ✅ EXECUTÁVEL. Você está no Windows 11.
>
> **Esta é a aula que mais rende sem um Mac.** O `flutter_launcher_icons` e o
> `flutter_native_splash` são pacotes **Dart puro**: eles leem o seu PNG e **escrevem os arquivos
> iOS** — `Assets.xcassets`, `LaunchScreen.storyboard`, imagens em todas as densidades. Nenhum deles
> precisa do Xcode.
>
> **O que você faz agora, no Windows:**
> 1. Gerar o `AppIcon.appiconset` inteiro, com as ~15 dimensões que o iOS exige.
> 2. Gerar a splash do iOS, clara e escura.
> 3. Escrever todo o `Info.plist`: nome, permissões, orientações.
> 4. Definir a versão no `pubspec.yaml` — vale para iOS **e** Android.
> 5. **Commitar tudo.** No dia do Mac, abre pronto.
>
> **O que fica para o Mac:** ver o ícone no simulador e conferir a splash com os próprios olhos.
>
> 💡 **Guarde este ponto:** ao chegar ao Mac com esta aula feita, você economiza uma hora de
> trabalho e, principalmente, evita a pior categoria de erro — a rejeição da App Store por um texto
> de permissão genérico, descoberta dias depois do envio.

---

## 📖 Conceito

### O ícone do iOS

O iOS precisa do ícone em **muitas dimensões**: iPhone, iPad, Spotlight, Ajustes, notificação, App
Store — cada uma em 1×, 2× e 3×.

```text
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Contents.json               ← o índice
├── Icon-App-20x20@1x.png
├── Icon-App-20x20@2x.png
├── Icon-App-20x20@3x.png
├── Icon-App-29x29@1x.png
…                               ~15 arquivos
└── Icon-App-1024x1024@1x.png   ← o da App Store
```

Gerar isso à mão é impensável. O `flutter_launcher_icons` faz a partir de um PNG de 1024 × 1024.

**E a regra que derruba o envio:**

> ⚠️ **O iOS rejeita ícone com canal alfa (transparência).** O envio falha com:
>
> ```text
> ERROR ITMS-90717: "Invalid App Store Icon. The app store icon in the
> asset catalog can't be transparent nor contain an alpha channel."
> ```
>
> E isso acontece **no upload**, depois de todo o build e do archive — nunca antes.

```yaml
flutter_launcher_icons:
  image_path: "assets/icone/icone.png"
  remove_alpha_ios: true      # ⭐ remove a transparência do ícone iOS
```

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Transparência | ✅ Permitida (e usada no adaptativo) | ❌ **Rejeitada** |
| Cantos arredondados | Você ou o sistema | **O sistema** — não desenhe |
| Formato | PNG com alfa | PNG **sem** alfa |

> 📌 **Não desenhe cantos arredondados no seu PNG.** O iOS aplica a máscara (o "squircle") por
> conta própria. Um ícone com cantos já arredondados fica com **cantos duplos** — e é o erro visual
> mais comum de app iniciante.

### A splash

No iOS, a tela de abertura não é uma imagem solta: é um **storyboard**, um arquivo de layout do
UIKit.

```text
ios/Runner/Base.lproj/LaunchScreen.storyboard
ios/Runner/Assets.xcassets/LaunchImage.imageset/
```

O `flutter_native_splash` escreve os dois.

```yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: assets/splash/logo.png
  color_dark: "#121212"
  image_dark: assets/splash/logo_dark.png
  ios: true
  ios_content_mode: center
```

> 💡 **A splash existe porque o Flutter demora alguns instantes para iniciar.** Ela cobre esse
> intervalo. Quanto mais simples, melhor: ela precisa aparecer **instantaneamente**, antes de
> qualquer código seu rodar.

> ⚠️ **A splash do iOS é agressivamente cacheada pelo sistema.** Se você mudou a imagem e o
> simulador continua mostrando a antiga, não é bug do pacote: apague o app do simulador e instale
> de novo. Em aparelho físico, o mesmo.

### A versão

```yaml
# pubspec.yaml — A FONTE ÚNICA, para as duas plataformas
version: 1.2.0+15
#        ^^^^^ CFBundleShortVersionString    ^^ CFBundleVersion
```

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>     <!-- 1.2.0 -->

<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>   <!-- 15 -->
```

| Chave | iOS | Android | O usuário vê |
|---|---|---|---|
| `CFBundleShortVersionString` | `1.2.0` | `versionName` | ✅ Sim |
| `CFBundleVersion` | `15` | `versionCode` | ❌ Não |

> ⚠️ **O `CFBundleVersion` precisa crescer a cada envio ao App Store Connect** — a mesma regra do
> `versionCode` do Android. Repetido, o upload é recusado:
>
> ```text
> ERROR ITMS-4238: "Redundant Binary Upload. There already exists a
> binary upload with build version '15'"
> ```

> 📌 **Se o `Info.plist` tiver a versão escrita literalmente** (`<string>1.0.0</string>` em vez da
> variável), o `pubspec.yaml` deixa de valer para o iOS — e você passa a ter duas versões que
> divergem em silêncio. Confira isso agora: é um detalhe que custa uma rejeição.

### O `Info.plist`

É o equivalente do `AndroidManifest.xml`. As chaves que importam:

| Chave | Para quê |
|---|---|
| `CFBundleDisplayName` | **Nome sob o ícone** |
| `CFBundleName` | Nome curto interno |
| `CFBundleIdentifier` | `$(PRODUCT_BUNDLE_IDENTIFIER)` |
| `CFBundleShortVersionString` | Versão visível |
| `CFBundleVersion` | Build |
| `UISupportedInterfaceOrientations` | Orientações |
| `UILaunchStoryboardName` | A splash |
| `NS*UsageDescription` | **Permissões** |
| `ITSAppUsesNonExemptEncryption` | Declaração de criptografia |

### As permissões: a diferença que importa

Esta é **a** diferença cultural entre as plataformas:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Declarar | `<uses-permission>` | `NS*UsageDescription` |
| Texto do motivo | ❌ Não existe | ✅ **Obrigatório** |
| Quem lê o texto | — | **O usuário e o revisor da Apple** |
| Sem o texto | — | ⚠️ **O app trava** ao usar o recurso |
| Texto genérico | — | ⚠️ **Rejeição** |

```xml
<!-- ❌ Genérico: motivo de rejeição -->
<key>NSCameraUsageDescription</key>
<string>Este app precisa da câmera.</string>

<!-- ✅ Específico: diz PARA QUÊ -->
<key>NSCameraUsageDescription</key>
<string>Para você tirar uma foto da capa da matéria.</string>
```

> ⚠️ **Sem a chave, o app não pede a permissão — ele trava.** O iOS encerra o processo na hora em
> que o recurso é acessado, com uma mensagem no console que menciona a chave faltante. É diferente
> do Android, em que a chamada falha com exceção e o app continua de pé.

> 📌 **Escreva os textos em português e seja específico.** O revisor da Apple lê cada um deles. "O
> app precisa do seu microfone" é motivo documentado de rejeição; "Para você gravar um áudio de
> revisão da aula" não é.

As chaves mais comuns:

| Chave | Quando |
|---|---|
| `NSCameraUsageDescription` | Câmera |
| `NSPhotoLibraryUsageDescription` | Ler a galeria |
| `NSPhotoLibraryAddUsageDescription` | **Salvar** na galeria |
| `NSMicrophoneUsageDescription` | Microfone |
| `NSLocationWhenInUseUsageDescription` | Localização em uso |
| `NSFaceIDUsageDescription` | Face ID |
| `NSUserTrackingUsageDescription` | ⚠️ Rastreamento entre apps |

> ⚠️ **Declare só o que você usa.** Uma chave sobrando faz o revisor perguntar por que o app de
> estudos precisa do microfone — e a resposta "um plugin trouxe" não é aceita.

### `ITSAppUsesNonExemptEncryption`

Toda vez que você envia um build, o App Store Connect pergunta sobre criptografia. Para evitar a
pergunta:

```xml
<!-- O app não usa criptografia própria além de HTTPS. -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

> 💡 HTTPS e o Keychain são **isentos**. Se o seu app só faz requisições HTTPS e guarda token no
> Keychain — o caso do Foco —, `false` é a resposta correta, e a pergunta some de todos os envios
> futuros.

---

## 💡 Analogia

Pense na **fachada e na papelada de uma loja**.

- **O ícone** é a placa. E o iOS tem uma regra de condomínio rígida: **a placa não pode ser
  vazada** — nada de fundo transparente. Quem manda uma placa vazada recebe ela de volta, e só
  descobre **no dia da instalação**, depois de todo o transporte.
- **Os cantos arredondados** já vêm do próprio suporte da fachada. Quem manda a placa já
  arredondada fica com **canto duplo** — o erro visual que denuncia o iniciante.
- **A splash** é a cortina que fica na vitrine enquanto as luzes acendem. Precisa subir na hora;
  uma cortina elaborada, que demora a montar, é pior que nenhuma.
- **A versão** é a numeração das notas fiscais: o cliente vê "pedido 1.2.0", e a contabilidade
  controla o sequencial 15, que **nunca se repete**.
- **As chaves de permissão** são a diferença cultural mais visível. No Android, você **avisa** que
  vai usar a câmera. No iOS, você **explica por escrito para quê** — e um fiscal lê a explicação.
  "Preciso da câmera" é como escrever "atividade comercial" no campo de ramo de atividade: o
  processo volta.
- **E a chave faltando não gera multa: fecha a loja na hora.** O iOS encerra o app no instante em
  que o recurso é acessado.

---

## 🧪 Exemplo mínimo

Ícone e splash, gerados **no Windows**.

**Passo 1 — o PNG:**

```text
assets/icone/icone.png     1024 × 1024, SEM transparência
assets/splash/logo.png     ~512 × 512, PODE ter transparência
```

**Passo 2 — `pubspec.yaml`:**

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.6

flutter_launcher_icons:
  ios: true
  android: true
  image_path: "assets/icone/icone.png"
  # ⭐ Sem isto: ERROR ITMS-90717 no upload, depois de todo o build.
  remove_alpha_ios: true
  background_color_ios: "#FFFFFF"

flutter_native_splash:
  color: "#FFFFFF"
  color_dark: "#121212"
  image: assets/splash/logo.png
  ios: true
  android: true
  ios_content_mode: center
```

**Passo 3 — gerar:**

```powershell
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

**Passo 4 — conferir o que foi escrito:**

```powershell
Get-ChildItem ios/Runner/Assets.xcassets/AppIcon.appiconset/ | Measure-Object
Get-ChildItem ios/Runner/Assets.xcassets/LaunchImage.imageset/
git status --short ios/
```

```text
Count : 16
 M ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
 M ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
 …
 M ios/Runner/Base.lproj/LaunchScreen.storyboard
```

> 📌 **Dezesseis arquivos iOS gerados num PC Windows, sem Xcode.** Eles vão versionados para o Git,
> e no Mac o projeto já abre com o ícone certo.

**Passo 5 — confirmar que não há alfa:**

```powershell
# O byte 25 do cabeçalho PNG é o tipo de cor: 6 = RGBA (tem alfa), 2 = RGB.
$b = [System.IO.File]::ReadAllBytes('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png')
if ($b[25] -eq 6) { 'TEM ALFA — vai ser rejeitado' } else { 'sem alfa ✅' }
```

---

## 📱 Aplicando no Flutter

O `Info.plist` completo e um verificador que evita a rejeição.

---

## 💻 Código completo

> **Arquivo:** `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ══════════════════════════════════════════════════════
         IDENTIDADE
         ══════════════════════════════════════════════════════ -->

    <!-- O nome sob o ícone. Até ~12 caracteres, ou é truncado. -->
    <key>CFBundleDisplayName</key>
    <string>Foco</string>

    <key>CFBundleName</key>
    <string>foco</string>

    <!-- ⚠️ Uma VARIÁVEL. O valor real está no project.pbxproj.
         Aula 4. -->
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>

    <!-- ══════════════════════════════════════════════════════
         VERSÃO — vem do pubspec.yaml: version: 1.2.0+15
         ══════════════════════════════════════════════════════ -->

    <!-- ⚠️ Se estas duas linhas tiverem o valor LITERAL em vez
         da variável, o pubspec.yaml deixa de valer para o iOS —
         e as versões divergem em silêncio. -->
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>

    <!-- Precisa CRESCER a cada envio. Repetido: ITMS-4238. -->
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>

    <!-- ══════════════════════════════════════════════════════
         APRESENTAÇÃO
         ══════════════════════════════════════════════════════ -->

    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>

    <key>UIMainStoryboardFile</key>
    <string>Main</string>

    <!-- iPhone: retrato e os dois paisagens.
         ⚠️ Se o app só funciona em retrato, declare só retrato:
         o revisor gira o aparelho. -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <!-- iPad exige as QUATRO, inclusive de cabeça para baixo,
         ou o app é rejeitado na revisão. -->
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <!-- A barra de status é controlada pelo Flutter
         (SystemChrome), não pelo UIKit. -->
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>

    <key>CFBundleLocalizations</key>
    <array>
        <string>pt-BR</string>
        <string>en</string>
    </array>

    <key>CFBundleDevelopmentRegion</key>
    <string>pt-BR</string>

    <!-- ══════════════════════════════════════════════════════
         PERMISSÕES
         ⚠️ Cada texto é lido pelo USUÁRIO e pelo REVISOR.
         Genérico = rejeição. Ausente = o app TRAVA.
         Declare SÓ o que você usa.
         ══════════════════════════════════════════════════════ -->

    <!-- Capa da matéria, tirada na hora. -->
    <key>NSCameraUsageDescription</key>
    <string>Para você tirar uma foto e usar como capa da matéria.</string>

    <!-- Capa escolhida da galeria. -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Para você escolher uma imagem da sua galeria como capa da matéria.</string>

    <!-- ⚠️ Chave DIFERENTE: esta é para SALVAR na galeria.
         Ler e salvar são permissões distintas no iOS. -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Para salvar na sua galeria o gráfico de progresso dos estudos.</string>

    <!-- Face ID / Touch ID para proteger as anotações. -->
    <key>NSFaceIDUsageDescription</key>
    <string>Para proteger suas anotações de estudo com o desbloqueio do aparelho.</string>

    <!-- ══════════════════════════════════════════════════════
         REDE
         ══════════════════════════════════════════════════════ -->

    <!-- ⚠️ NUNCA ponha NSAllowsArbitraryLoads como true aqui.
         Desliga o HTTPS obrigatório do app inteiro, e a Apple
         pergunta o porquê na revisão.
         Módulo 13, aula 6. -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>

    <!-- ══════════════════════════════════════════════════════
         CONFORMIDADE
         ══════════════════════════════════════════════════════ -->

    <!-- HTTPS e Keychain são ISENTOS. Declarar false aqui evita
         a pergunta sobre criptografia em TODO envio. -->
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>

    <!-- ══════════════════════════════════════════════════════
         FLUTTER
         ══════════════════════════════════════════════════════ -->

    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>

    <!-- Permite o modo imersivo (SystemUiMode.immersive). -->
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
</dict>
</plist>
```

E o verificador, que evita a rejeição:

> **Arquivo:** `ferramentas/conferir-ios.ps1` (novo)

```powershell
# Confere o que a App Store recusaria — ANTES do envio.
#
# 🪟 Roda no Windows. Cada item aqui é uma rejeição real e
# documentada, descoberta normalmente DEPOIS de todo o build,
# do archive e do upload.

$problemas = @()
$avisos = @()

Write-Host '═══ CONFERÊNCIA iOS ═══' -ForegroundColor Cyan

$plistPath = 'ios/Runner/Info.plist'
if (-not (Test-Path $plistPath)) { throw "Não achei $plistPath" }
$plist = Get-Content $plistPath -Raw

# ══════════════════════════════════════════════════════════════
Write-Host "`n[1] Ícone" -ForegroundColor Cyan

$iconeDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
$icone1024 = "$iconeDir/Icon-App-1024x1024@1x.png"

if (-not (Test-Path $iconeDir)) {
    $problemas += 'AppIcon.appiconset não existe. Rode: dart run flutter_launcher_icons'
} else {
    $n = (Get-ChildItem $iconeDir -Filter '*.png').Count
    Write-Host "  $n imagens"
    if ($n -lt 10) {
        $avisos += "Só $n imagens de ícone — regere com flutter_launcher_icons"
    }

    if (Test-Path $icone1024) {
        $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $icone1024))

        # Cabeçalho PNG (IHDR): largura nos bytes 16-19, altura 20-23,
        # profundidade em 24, TIPO DE COR em 25.
        $largura = [BitConverter]::ToInt32($bytes[19..16], 0)
        $altura  = [BitConverter]::ToInt32($bytes[23..20], 0)
        $tipoCor = $bytes[25]

        Write-Host "  1024x1024: ${largura}x${altura}, tipo de cor $tipoCor"

        if ($largura -ne 1024 -or $altura -ne 1024) {
            $problemas += "Ícone da App Store deve ser 1024x1024 (é ${largura}x${altura})"
        }

        # ⭐ Tipo 6 = RGBA, tipo 4 = escala de cinza + alfa.
        # É a causa do ERROR ITMS-90717, descoberto no UPLOAD.
        if ($tipoCor -eq 6 -or $tipoCor -eq 4) {
            $problemas += 'Ícone COM TRANSPARÊNCIA — ITMS-90717 no upload. Use remove_alpha_ios: true'
        } else {
            Write-Host '  ✅ sem canal alfa' -ForegroundColor Green
        }
    } else {
        $problemas += 'Falta o ícone 1024x1024 (o da App Store)'
    }
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[2] Versão" -ForegroundColor Cyan

$versao = ([regex]'(?m)^version:\s*(.+)$').Match((Get-Content pubspec.yaml -Raw)).Groups[1].Value.Trim()
Write-Host "  pubspec: $versao"

if ($versao -notmatch '^\d+\.\d+\.\d+\+\d+$') {
    $problemas += "version malformada: '$versao'. Use x.y.z+N."
}

# ⭐ Se o Info.plist tiver o valor literal, o pubspec deixa de
# valer para o iOS — e as versões divergem SEM aviso.
if ($plist -match '<key>CFBundleShortVersionString</key>\s*<string>\$\(FLUTTER_BUILD_NAME\)</string>') {
    Write-Host '  ✅ CFBundleShortVersionString usa $(FLUTTER_BUILD_NAME)' -ForegroundColor Green
} else {
    $problemas += 'CFBundleShortVersionString não usa $(FLUTTER_BUILD_NAME) — a versão do pubspec não vale para iOS'
}

if ($plist -match '<key>CFBundleVersion</key>\s*<string>\$\(FLUTTER_BUILD_NUMBER\)</string>') {
    Write-Host '  ✅ CFBundleVersion usa $(FLUTTER_BUILD_NUMBER)' -ForegroundColor Green
} else {
    $problemas += 'CFBundleVersion não usa $(FLUTTER_BUILD_NUMBER)'
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[3] Permissões" -ForegroundColor Cyan

$chaves = [regex]::Matches($plist, '<key>(NS\w*UsageDescription)</key>\s*<string>([^<]*)</string>')

if ($chaves.Count -eq 0) {
    Write-Host '  (nenhuma declarada)'
} 

# Textos que o revisor da Apple recusa por serem genéricos.
$genericos = @(
    'precisa', 'necessário', 'necessita', 'requer',
    'para funcionar', 'permission', 'access', 'usa a', 'usa o'
)

foreach ($m in $chaves) {
    $chave = $m.Groups[1].Value
    $texto = $m.Groups[2].Value.Trim()

    Write-Host "  $chave"
    Write-Host "    `"$texto`"" -ForegroundColor Gray

    if ($texto.Length -lt 20) {
        $problemas += "$chave : texto curto demais ($($texto.Length) chars) — rejeição provável"
        continue
    }

    # Um texto que só diz "o app precisa de X" não diz PARA QUÊ.
    $ehGenerico = $genericos | Where-Object { $texto.ToLower().Contains($_) }
    if ($ehGenerico -and $texto.Length -lt 50) {
        $avisos += "$chave : texto possivelmente genérico. Diga PARA QUÊ o usuário ganha com isso."
    }

    if ($texto -match '^[A-Za-z\s.]+$' -and $texto -notmatch '[áéíóúâêôãõçà]') {
        $avisos += "$chave : parece estar em inglês. Escreva em português."
    }
}

# ⚠️ Permissão declarada e não usada faz o revisor perguntar.
$suspeitas = @('NSMicrophoneUsageDescription', 'NSLocationAlwaysUsageDescription',
               'NSContactsUsageDescription', 'NSUserTrackingUsageDescription')
foreach ($s in $suspeitas) {
    if ($plist -match "<key>$s</key>") {
        $avisos += "$s declarada — você usa mesmo? Sobrando, o revisor pergunta."
    }
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[4] Rede e conformidade" -ForegroundColor Cyan

if ($plist -match '<key>NSAllowsArbitraryLoads</key>\s*<true/>') {
    # Desliga o HTTPS obrigatório do app inteiro.
    $problemas += 'NSAllowsArbitraryLoads = true — desliga o HTTPS obrigatório. Módulo 13, aula 6.'
} else {
    Write-Host '  ✅ HTTPS obrigatório' -ForegroundColor Green
}

if ($plist -match '<key>ITSAppUsesNonExemptEncryption</key>') {
    Write-Host '  ✅ declaração de criptografia presente' -ForegroundColor Green
} else {
    $avisos += 'Sem ITSAppUsesNonExemptEncryption — o App Store Connect vai perguntar a cada envio'
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[5] Nome exibido" -ForegroundColor Cyan

$nome = ([regex]'(?s)<key>CFBundleDisplayName</key>\s*<string>([^<]+)</string>').Match($plist).Groups[1].Value
Write-Host "  `"$nome`""

if ($nome -match 'Runner|Example|flutter_app') {
    $problemas += "Nome exibido ainda é o padrão: $nome"
}
if ($nome.Length -gt 12) {
    # O iOS trunca com reticências sob o ícone.
    $avisos += "Nome com $($nome.Length) caracteres — o iOS trunca acima de ~12"
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[6] Splash" -ForegroundColor Cyan

if (Test-Path 'ios/Runner/Base.lproj/LaunchScreen.storyboard') {
    Write-Host '  ✅ LaunchScreen.storyboard existe' -ForegroundColor Green
} else {
    $problemas += 'LaunchScreen.storyboard ausente'
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n═══ RESULTADO ═══" -ForegroundColor Cyan

if ($problemas.Count -eq 0 -and $avisos.Count -eq 0) {
    Write-Host '  ✅ Nada a corrigir.' -ForegroundColor Green
}
foreach ($a in $avisos)    { Write-Host "  ⚠️  $a" -ForegroundColor Yellow }
foreach ($p in $problemas) { Write-Host "  ❌ $p" -ForegroundColor Red }

Write-Host ''
Write-Host 'Cada item acima é uma rejeição real da App Store —' -ForegroundColor Gray
Write-Host 'normalmente descoberta DEPOIS do build, do archive e do upload.' -ForegroundColor Gray

if ($problemas.Count -gt 0) { exit 1 }
```

```powershell
dart run flutter_launcher_icons
dart run flutter_native_splash:create
.\ferramentas\conferir-ios.ps1
git add ios/ pubspec.yaml
git commit -m "iOS: icone, splash, versao e Info.plist"
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `remove_alpha_ios: true` | **Evita o `ITMS-90717`**, descoberto só no upload. |
| `$(PRODUCT_BUNDLE_IDENTIFIER)` no plist | Uma variável: o valor real está no `project.pbxproj`. |
| `$(FLUTTER_BUILD_NAME)` / `_NUMBER` | Sem elas, o `pubspec` deixa de valer para o iOS. |
| `UISupportedInterfaceOrientations~ipad` com **quatro** | O iPad exige as quatro, ou é rejeitado. |
| `UIViewControllerBasedStatusBarAppearance = false` | A barra de status passa a ser do Flutter. |
| Textos de permissão **específicos** | Genérico é rejeição documentada; o revisor lê cada um. |
| `NSPhotoLibraryAddUsageDescription` separada | **Ler e salvar são permissões distintas** no iOS. |
| `NSAllowsArbitraryLoads = false` | Mantém o HTTPS obrigatório. |
| `ITSAppUsesNonExemptEncryption = false` | Evita a pergunta sobre criptografia a cada envio. |
| Ler o byte 25 do PNG | É o tipo de cor do IHDR: 6 e 4 têm alfa. |
| Ler largura e altura do cabeçalho | Confere 1024×1024 sem depender de biblioteca de imagem. |
| Lista de palavras genéricas | Aproxima o critério do revisor da Apple. |
| Detectar texto em inglês | O app é em português; o texto deve ser também. |
| Avisar permissão **sobrando** | O revisor pergunta por que o app precisa dela. |
| Avisar nome acima de 12 caracteres | O iOS trunca sob o ícone. |
| Mensagem final | Cada item é uma rejeição real, descoberta depois de todo o trabalho. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Ícone | `mipmap/` por densidade | `Assets.xcassets` |
| Transparência no ícone | ✅ | ❌ **Rejeitada** |
| Cantos arredondados | Você ou o sistema | **O sistema** |
| Splash | XML + tema | `LaunchScreen.storyboard` |
| Versão | `versionName`/`versionCode` | `CFBundleShortVersionString`/`CFBundleVersion` |
| Permissões | `<uses-permission>` | `NS*UsageDescription` |
| **Texto do motivo** | ❌ Não existe | ✅ **Obrigatório** |
| Sem a declaração | Chamada falha | ⚠️ **O app trava** |
| Gerar no Windows | ✅ | ✅ **Também** |

> 💡 **A grande diferença é o texto.** No Android, a permissão é uma declaração técnica. No iOS, é
> um **compromisso com o usuário**, revisado por uma pessoa. Isso torna o `Info.plist` um arquivo de
> **produto**, não só de configuração — e é por isso que ele merece a mesma atenção que uma tela.

---

## ⚠️ Erros comuns

### 1. Ícone com transparência

```text
ERROR ITMS-90717
```

Descoberto no upload, depois de tudo.

**Correção:** `remove_alpha_ios: true`.

### 2. Cantos já arredondados no PNG

Cantos duplos.

**Correção:** quadrado; o iOS aplica a máscara.

### 3. Versão literal no `Info.plist`

O `pubspec` deixa de valer para o iOS.

**Correção:** `$(FLUTTER_BUILD_NAME)`.

### 4. `CFBundleVersion` repetido

```text
ERROR ITMS-4238
```

**Correção:** suba o `+N`.

### 5. Texto de permissão genérico

Rejeição.

**Correção:** diga **para quê**.

### 6. Chave de permissão ausente

**O app trava**, não falha.

**Correção:** declare antes de usar.

### 7. Confundir ler e salvar na galeria

São chaves diferentes.

**Correção:** `NSPhotoLibraryAddUsageDescription` para salvar.

### 8. Permissão declarada e não usada

O revisor pergunta.

**Correção:** só o que você usa.

### 9. iPad sem as quatro orientações

Rejeição.

**Correção:** as quatro em `~ipad`.

### 10. `NSAllowsArbitraryLoads = true`

Desliga o HTTPS do app inteiro.

**Correção:** `false`.

### 11. Nome exibido longo demais

Truncado sob o ícone.

**Correção:** até ~12 caracteres.

### 12. Splash antiga no simulador

Cache agressivo do iOS.

**Correção:** apague o app e reinstale.

---

## 🛠️ Exercício guiado

> 🪟 **Todos os passos rodam no Windows**, exceto os 9 e 10.

**Passo 1.** Ponha um PNG 1024×1024 em `assets/icone/` e configure o `pubspec.yaml`.

**Passo 2.** Rode `dart run flutter_launcher_icons`. Quantos arquivos apareceram em
`AppIcon.appiconset`?

**Passo 3.** Rode `conferir-ios.ps1`. O ícone tem alfa?

**Passo 4.** Remova `remove_alpha_ios: true`, regere e rode o verificador. Ele acusa?

**Passo 5.** Rode `dart run flutter_native_splash:create` e veja o `git status`.

**Passo 6.** Escreva `NSCameraUsageDescription` como "Este app precisa da câmera". O verificador
avisa?

**Passo 7.** Reescreva dizendo para quê. Melhorou?

**Passo 8.** Troque `$(FLUTTER_BUILD_NAME)` por `1.0.0` literal. O verificador acusa?

**Passo 9.** 🍎 No Mac, rode no simulador e veja o ícone e a splash.

**Passo 10.** 🍎 Mude a splash, regere, e reinstale **sem apagar** o app. Ela mudou?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-ios.md](../../exercicios/15-build-ios.md)

Faça os de **Aplicação** (gerar ícone e splash) e o de **Reflexão** (escrever os textos de permissão
do seu app).

---

## 🏆 Desafio opcional

Escreva os **textos de permissão de um app real** — o seu projeto final — e submeta-os a uma
revisão.

Requisitos:

- Um texto para cada permissão que o app usa de fato.
- Cada um responde: **o que** o app acessa, **para quê**, e **o que o usuário ganha**.
- Máximo de duas linhas; escrito para uma pessoa, não para um revisor.
- Uma versão em inglês, para o mercado internacional.
- Peça a alguém que **não conhece o app** para ler cada texto e dizer se autorizaria. Anote as
  reações.
- Uma tabela: permissão × texto × onde exatamente no app ela é usada.

Depois responda: algum texto ficou difícil de escrever? Se sim, isso sugere que a permissão talvez
**não seja necessária** — um texto que não se consegue justificar costuma indicar um recurso que não
se consegue justificar.

---

## 📌 Resumo

- 🪟 **Ícone, splash e `Info.plist` se fazem no Windows** — os pacotes são Dart puro.
- O iOS exige ~15 dimensões de ícone; `flutter_launcher_icons` gera todas de um PNG 1024×1024.
- **O iOS rejeita ícone com transparência** (`ITMS-90717`) — use `remove_alpha_ios: true`.
- **Não desenhe cantos arredondados**: o sistema aplica a máscara, e o seu vira canto duplo.
- A splash é um **storyboard**, cacheado agressivamente — apague o app para ver a nova.
- A versão vem do **`pubspec.yaml`**, via `$(FLUTTER_BUILD_NAME)` e `$(FLUTTER_BUILD_NUMBER)`.
- Valor literal no `Info.plist` faz as versões divergirem **em silêncio**.
- `CFBundleVersion` precisa **crescer** a cada envio (`ITMS-4238`).
- **Toda permissão iOS exige um texto**, lido pelo usuário **e pelo revisor**.
- **Genérico = rejeição. Ausente = o app trava.**
- Ler e salvar na galeria são **chaves diferentes**.
- iPad exige as **quatro** orientações.
- `NSAllowsArbitraryLoads` sempre `false`; `ITSAppUsesNonExemptEncryption` `false` evita a pergunta.
- Nome exibido até **~12 caracteres**.

---

## ☑️ Checklist de domínio

- [ ] Gerei o `AppIcon.appiconset` completo.
- [ ] Meu ícone não tem canal alfa.
- [ ] Meu PNG é quadrado, sem cantos arredondados.
- [ ] Gerei a splash clara e escura.
- [ ] A versão vem do `pubspec.yaml` via variáveis.
- [ ] Sei que o `CFBundleVersion` precisa crescer.
- [ ] Escrevi um texto específico para cada permissão.
- [ ] Declarei só as permissões que uso.
- [ ] Sei a diferença entre ler e salvar na galeria.
- [ ] Declarei as quatro orientações do iPad.
- [ ] HTTPS obrigatório e criptografia declarada.
- [ ] Rodei `conferir-ios.ps1` sem problemas.
- [ ] Commitei tudo, pronto para o Mac.

---

## 📚 Referências oficiais

- [Information Property List — developer.apple.com](https://developer.apple.com/documentation/bundleresources/information_property_list)
- [App icons — Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Launch screens — Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/launching)
- [Requesting authorization — developer.apple.com](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [flutter_launcher_icons — pub.dev](https://pub.dev/packages/flutter_launcher_icons)
- [flutter_native_splash — pub.dev](https://pub.dev/packages/flutter_native_splash)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Bundle ID e o Xcode](04-bundle-id-e-xcode.md) | [README](README.md) | [Aula 6 — Conta Apple gratuita × paga](06-conta-apple-gratuita-x-paga.md) |
