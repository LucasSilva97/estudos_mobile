# Etapa 8 — Ícone, splash e versão — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 90 min · **Depende de:** [Etapa 7 — Testes](09-etapa-7-testes.md) ·
> **Aulas:** [14.2 Identidade do app](../../modulos/15-build-android/02-identidade-do-app.md) ·
> [14.3 Ícone](../../modulos/15-build-android/03-icone.md) ·
> [14.4 Splash screen](../../modulos/15-build-android/04-splash-screen.md) ·
> [14.5 Permissões Android](../../modulos/15-build-android/05-permissoes-android.md) ·
> [15.5 Ícone, splash, versão e Info.plist](../../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

---

## 🎯 O que existe ao fim desta etapa

| O que muda | Onde você vê |
|---|---|
| Ícone **F** branco sobre azul — adaptativo 🤖, opaco 🍎 | tela inicial e gaveta de apps |
| **Splash nativa** azul no tema claro, `#121212` no escuro | entre o toque no ícone e o Painel |
| Nome sob o ícone é **Foco**, não `foco` | tela inicial 🤖 e 🍎 |
| `version: 1.0.0+1` alimenta **as duas plataformas** | `versionName`/`versionCode` 🤖 · `CFBundleShortVersionString`/`CFBundleVersion` 🍎 |
| `Info.plist` em pt-BR, ATS ligado, criptografia declarada | revisão da App Store |
| `AndroidManifest.xml` com **uma** permissão: `INTERNET` | ficha da Play Store |

> 📌 **Esta etapa não acrescenta um arquivo sequer em `lib/`:** ela mexe em `pubspec.yaml`,
> `assets/`, `android/` e `ios/`. O app compila igual ao fim da etapa 7 — muda só a casca.

---

## 📦 Dependências

Os dois geradores entram em **`dev_dependencies`**: rodam na sua máquina e não vão no app.

| Pacote | Onde | Por que agora |
|---|---|---|
| `flutter_launcher_icons: ^0.14.4` | `dev_dependencies` | transforma **um** PNG 1024×1024 nas ~30 imagens que as duas lojas exigem |
| `flutter_native_splash: ^2.4.8` | `dev_dependencies` | escreve os temas e drawables da splash 🤖 e o `LaunchScreen.storyboard` 🍎 |
| `package_info_plus: ^9.0.1` | `dependencies` | alimenta a versão que a `ConfiguracoesScreen` (etapa 4) exibe — e ela vem daqui |

```powershell
flutter pub add package_info_plus dev:flutter_launcher_icons dev:flutter_native_splash
```

> ⚠️ O `dev:` não é detalhe. Um gerador em `dependencies` é peso morto no APK.

---

## 🧩 Os arquivos desta etapa

| Arquivo | Papel |
|---|---|
| `assets/icone/icone.png` · `splash.png` | a imagem de origem — tudo o mais é gerado a partir dela |
| `pubspec.yaml` | a versão `1.0.0+1` e os **dois blocos de primeiro nível** dos geradores |
| `android/app/build.gradle.kts` | `applicationId` definitivo e a versão vinda do `pubspec` |
| `android/app/src/main/AndroidManifest.xml` | nome exibido, ícone e a única permissão do Foco |
| `ios/Runner/Info.plist` | nome, versão **por variável**, ATS, pt-BR e os textos de permissão |

**Gerados por comando — não edite à mão:** tudo em `android/app/src/main/res/` (mipmap,
drawable, `colors.xml`, `styles.xml`), `ios/Runner/Assets.xcassets/AppIcon.appiconset/` e o
`LaunchScreen.storyboard`. Todos vão para o Git: o build de outra máquina precisa deles.

---

### assets/icone/icone.png e assets/icone/splash.png

> **Por que existem:** são a **única** arte do projeto — o `icone.png` é o arquivo-mestre de onde
> saem as ~30 imagens das duas plataformas.

| Arquivo | Tamanho | Fundo | Regra que não dá para quebrar |
|---|---|---|---|
| `assets/icone/icone.png` | 1024×1024 | opaco `#3F51B5` | **sem canal alfa** (a Apple rejeita) e desenho nos **66% centrais** (máscara adaptativa) |
| `assets/icone/splash.png` | 512×512 | transparente | a cor vem da config, não da imagem |

Desenhe no editor que preferir (passo a passo na
[aula 14.3](../../modulos/15-build-android/03-icone.md)) e confirme antes de gerar:

```powershell
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("$PWD\assets\icone\icone.png")
# ⚠️ Formato com "Alpha" no nome = PNG transparente = ITMS-90717 no upload do iOS.
"$($img.Width) x $($img.Height) - $($img.PixelFormat)"
$img.Dispose()
```

Saída esperada: `1024 x 1024 - Format24bppRgb`.

---

### pubspec.yaml

> **Por que ele existe:** define a versão do app para as duas plataformas e configura os dois
> geradores — e é onde a indentação errada custa meia hora.

```yaml
name: foco
description: "Foco — organizador de sessões de estudo."
publish_to: 'none'

# 🔴 A FONTE ÚNICA DA VERSÃO.
# Antes do "+"  = build name   -> versionName 🤖 / CFBundleShortVersionString 🍎
# Depois do "+" = build number -> versionCode 🤖 / CFBundleVersion 🍎
# O número depois do "+" precisa CRESCER a cada envio para as lojas.
version: 1.0.0+1

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^3.4.3
  http: ^1.6.0
  shared_preferences: ^2.5.5
  sqflite: ^2.4.4
  path: ^1.9.1
  intl: ^0.20.2
  uuid: ^4.6.0
  package_info_plus: ^9.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mocktail: ^1.0.5
  sqflite_common_ffi: ^2.4.3
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.8

flutter:
  uses-material-design: true
  assets:
    - assets/icone/

# ⬇️ PRIMEIRO NÍVEL — coluna 1, alinhado com "flutter:", NÃO dentro dele.
# ⚠️ Indentado dentro de flutter:, o gerador responde "Could not find a config file"
# mesmo com o bloco presente no arquivo.
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icone/icone.png"
  # ⚠️ IGUAL ao minSdk real (24 no Flutter 3.47). Diferente, o ícone sai sem a
  # variante adaptativa e você só descobre vendo o quadrado entre os redondos.
  min_sdk_android: 24
  remove_alpha_ios: true            # a Apple rejeita ícone com transparência
  # ⚠️ A cor precisa de ASPAS: sem elas o YAML lê "#" como início de comentário.
  adaptive_icon_background: "#3F51B5"
  adaptive_icon_foreground: "assets/icone/icone.png"

# ⬇️ PRIMEIRO NÍVEL — splash nativa.
flutter_native_splash:
  color: "#3F51B5"
  image: assets/icone/splash.png
  color_dark: "#121212"             # alimenta as pastas -night
  image_dark: assets/icone/splash.png

  # O Android 12 trocou o mecanismo: só cor de fundo + ícone centralizado.
  # Sem esta seção, do Android 12 para cima a splash sai BRANCA.
  android_12:
    color: "#3F51B5"
    image: assets/icone/splash.png
    icon_background_color: "#3F51B5"
    color_dark: "#121212"
    icon_background_color_dark: "#121212"

  android: true
  ios: true
  web: false
```

> 💡 `#3F51B5` é a cor semente do `TemaFoco` (etapa 1). Splash, ícone adaptativo e
> `colorScheme.primary` na mesma cor é o que faz a abertura não ter "pulo" de cor.

---

### android/app/build.gradle.kts

> **Por que ele existe:** é onde o `applicationId` vira definitivo e onde a versão do `pubspec`
> entra no APK — as duas coisas que você não muda mais depois de publicar.

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // O plugin Gradle do Flutter vem DEPOIS dos plugins do Android e do Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.estudos.foco"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // 🔴 IDENTIDADE DEFINITIVA. Publicou na Play com este id, é para sempre.
        applicationId = "br.com.estudos.foco"

        minSdk = flutter.minSdkVersion      // 24 — precisa bater com min_sdk_android
        targetSdk = flutter.targetSdkVersion

        // Vêm de `version: 1.0.0+1` no pubspec.yaml. ⚠️ Escrito à mão aqui, o
        // pubspec deixa de valer e as duas plataformas divergem em silêncio.
        versionCode = flutter.versionCode   // o "1" depois do +
        versionName = flutter.versionName   // o "1.0.0" antes do +
    }

    buildTypes {
        release {
            // TODO: a assinatura de release entra no módulo 15, aula 7.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
```

---

### android/app/src/main/AndroidManifest.xml

> **Por que ele existe:** é o que o usuário lê sob o ícone e o que a Play publica como "este app
> pede acesso a…" — e o Foco pede a uma coisa só.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- A ÚNICA permissão do Foco: buscar as trilhas na API.
         Matérias, sessões e metas são 100% locais (RNF13). -->
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="Foco"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- @style/LaunchTheme é a splash; NormalTheme é o tema depois do
                 primeiro frame. Quem escreve os dois é o flutter_native_splash. -->
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
</manifest>
```

> ⚠️ `android:label="foco"` minúsculo é o que o `flutter create` deixa. Passa despercebido até
> alguém instalar o app e ver o nome errado na tela inicial.

---

### ios/Runner/Info.plist

> **Por que ele existe:** é o único lugar em que o iOS lê o nome, a versão e o motivo de cada
> permissão — e é lido por uma **pessoa** na revisão da App Store.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- --- IDENTIDADE --- -->
    <key>CFBundleDisplayName</key>
    <string>Foco</string>

    <key>CFBundleName</key>
    <string>foco</string>

    <!-- Uma VARIÁVEL: o valor real (br.com.estudos.foco) está no project.pbxproj. -->
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>

    <!-- --- VERSÃO — vem de `version: 1.0.0+1` no pubspec.yaml --- -->
    <!-- ⚠️ Com o número LITERAL no lugar da variável, o pubspec deixa de valer
         para o iOS e as duas plataformas divergem sem nenhum aviso. -->
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>

    <!-- Precisa CRESCER a cada envio. Repetido = ITMS-4238 no upload. -->
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>

    <!-- --- APRESENTAÇÃO --- -->
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>

    <key>UIMainStoryboardFile</key>
    <string>Main</string>

    <!-- O Foco é responsivo de 320 a 1280 dp (RNF18). ⚠️ O iPad exige as QUATRO
         orientações, inclusive de cabeça para baixo, ou é rejeitado. -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <!-- A barra de status passa a ser do Flutter (SystemChrome), não do UIKit. -->
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>

    <!-- --- IDIOMA — a interface do Foco é pt-BR (RNF20) --- -->
    <key>CFBundleLocalizations</key>
    <array>
        <string>pt-BR</string>
    </array>

    <key>CFBundleDevelopmentRegion</key>
    <string>pt-BR</string>

    <!-- --- PERMISSÕES ---
         O Foco NÃO pede nenhuma: tudo é local, e rede não é permissão no iOS.
         ⚠️ Chave declarada e não usada faz o revisor perguntar por quê.
         Os textos abaixo ficam prontos para colar SE você fizer um desafio com
         câmera ou galeria. Genérico ("o app precisa da câmera") é rejeição
         documentada: diga PARA QUÊ.

         <key>NSCameraUsageDescription</key>
         <string>Para você tirar uma foto e usar como capa da matéria.</string>

         <key>NSPhotoLibraryUsageDescription</key>
         <string>Para você escolher uma imagem da sua galeria como capa da matéria.</string>

         Ler e salvar são permissões DIFERENTES no iOS:
         <key>NSPhotoLibraryAddUsageDescription</key>
         <string>Para salvar na sua galeria o gráfico de progresso dos seus estudos.</string>
    -->

    <!-- --- REDE --- -->
    <!-- ⚠️ NSAllowsArbitraryLoads = true desligaria o HTTPS obrigatório do app
         inteiro. A API do Foco é HTTPS (RNF12); manter false é gratuito. -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>

    <!-- --- CONFORMIDADE --- -->
    <!-- HTTPS é isento. Declarar false evita a pergunta sobre criptografia
         em TODO envio para o App Store Connect. -->
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>

    <!-- --- FLUTTER --- -->
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>

    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
</dict>
</plist>
```

---

## ▶️ Rodando

```powershell
.\ferramentas\gerar-imagens-base.ps1
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter clean
flutter run
```

O gerador de ícones termina com `✓ Successfully generated launcher icons`.

> ⚠️ **`No platform provided` não é erro:** você não passou flag de plataforma, então ele usou o
> `pubspec.yaml` — que é o que se quer. `No colors.xml file found` também é normal: ele cria.

Você vê, nesta ordem: o ícone **F** branco em azul na gaveta, com o nome **Foco**; ao tocar,
a splash azul; e então o Painel. Ligue o tema escuro do sistema e abra de novo: a splash sai
`#121212`. Em Configurações, a versão exibida é **1.0.0+1**.

> 🍎 Os dois geradores **escrevem os arquivos do iOS no Windows** — é só PNG, JSON e storyboard;
> commite tudo. Exige Mac apenas **ver** o resultado e gerar o `.ipa`
> ([15.8](../../modulos/16-build-ios/08-build-ipa-e-archive.md)).

---

## ✅ Conferência

- [ ] `assets/icone/icone.png` tem **1024×1024** e **nenhum canal alfa**.
- [ ] `flutter_launcher_icons:` e `flutter_native_splash:` começam na **coluna 1** do `pubspec.yaml`.
- [ ] O gerador terminou com `✓ Successfully generated launcher icons`.
- [ ] Existe `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (o ícone adaptativo).
- [ ] Existe `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`.
- [ ] A splash gerou `res/values-v31/styles.xml`, `res/values-night-v31/styles.xml` e o
  `ios/Runner/Base.lproj/LaunchScreen.storyboard`.
- [ ] O nome sob o ícone é **Foco** — não `foco`, não `Runner`.
- [ ] A splash abre azul no tema claro e `#121212` no escuro, sem pulo de cor para o Painel.
- [ ] No `Info.plist`, as duas chaves de versão usam **as variáveis**, não números.
- [ ] O `AndroidManifest.xml` declara **só** `INTERNET`.
- [ ] `flutter analyze` em `No issues found!` e `flutter test` em `All tests passed!`.

---

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| `✗ Could not find a config file. Create a flutter_launcher_icons.yaml…` | o bloco está indentado **dentro** de `flutter:` | mova `flutter_launcher_icons:` para a coluna 1 |
| O gerador reclama de cor de fundo ausente ou inválida | `adaptive_icon_background: #3F51B5` **sem aspas**: o YAML leu `#` como comentário | `adaptive_icon_background: "#3F51B5"` |
| Ícone quadrado no meio de ícones redondos no Android 8+ | `min_sdk_android` ≠ `minSdk` real: a variante adaptativa não foi gerada | `min_sdk_android: 24` e rode o gerador de novo |
| O ícone **antigo** continua na tela inicial | cache do Gradle e do launcher | `adb uninstall br.com.estudos.foco`, `flutter clean`, `flutter run` — alguns launchers só soltam ao reiniciar |
| Splash azul no Android 11 e **branca** no Android 12+ | faltou a seção `android_12:` | acrescente-a e rode `dart run flutter_native_splash:create` |
| `Unable to load asset: assets/icone/splash.png` | o arquivo não existe ou `assets/icone/` não está declarado | rode `.\ferramentas\gerar-imagens-base.ps1` e confira a barra final em `- assets/icone/` |
| `ERROR ITMS-90717: Invalid App Store Icon … can't be transparent` | o PNG do iOS saiu com canal alfa | `remove_alpha_ios: true` e regerar; o `icone.png` de origem tem de ser 24bpp |
| A versão do iOS não bate com a do Android | o `Info.plist` tem o número literal no lugar de `$(FLUTTER_BUILD_NAME)` | volte às variáveis: a fonte única é o `pubspec.yaml` |
| O `conferir-ios.ps1` (aula 15.5) acusa permissão declarada | ele casa a chave também **dentro do comentário** XML | falso positivo: as chaves do Foco estão comentadas de propósito |

---

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [09 — Etapa 7: Testes](09-etapa-7-testes.md) | [README do projeto](README.md) | [11 — Etapa 9: PWA e publicação](11-etapa-9-pwa-e-publicacao.md) |
