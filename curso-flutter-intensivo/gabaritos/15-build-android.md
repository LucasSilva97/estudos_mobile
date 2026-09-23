# Gabarito — Módulo 15: Build e distribuição Android

> Compare depois de resolver os [exercícios](../exercicios/15-build-android.md).

<a id="m15-e01"></a>
## M15-E01
```powershell
flutter clean; flutter pub get
Measure-Command { flutter build apk --debug }
Measure-Command { flutter build apk --profile }
Measure-Command { flutter build apk --release }
```
| Modo | Arquivo | Tamanho | Build |
|---|---|---:|---:|
| debug | `app-debug.apk` | ~62 MB | ~45 s |
| profile | `app-profile.apk` | ~48 MB | ~110 s |
| release | `app-release.apk` | ~45 MB | ~120 s |

O debug é o maior porque carrega a máquina de JIT inteira, mantém os `assert` e embute o serviço de observação do DevTools — tudo isso desaparece no AOT do release.

<a id="m15-e02"></a>
## M15-E02
`kDebugMode`, `kProfileMode` e `kReleaseMode` são `const`: o compilador conhece o valor **durante o build**, então o `switch` de `CartaoDoModo` já sai resolvido no ramo vencedor e em release não sobra comparação nenhuma para executar. Pelo mesmo motivo, `if (kDebugMode) { debugPrint(...); }` tem a condição avaliada como `false` em tempo de compilação e o corpo inteiro é descartado pelo tree shaking — a chamada não existe no binário instalado.

O critério: isso só vale para constante de compilação. Um `bool` lido de configuração em tempo de execução mantém o código no binário.

<a id="m15-e03"></a>
## M15-E03
```kotlin
// android/app/build.gradle.kts
android {
    namespace = "br.com.estudos.foco"

    defaultConfig {
        applicationId = "br.com.estudos.foco"
        versionCode = flutter.versionCode   // já vem do pubspec
        versionName = flutter.versionName
    }
}
```
```powershell
New-Item -ItemType Directory -Force android\app\src\main\kotlin\br\com\estudos\foco
Move-Item android\app\src\main\kotlin\com\example\foco\MainActivity.kt `
          android\app\src\main\kotlin\br\com\estudos\foco\MainActivity.kt
Remove-Item -Recurse android\app\src\main\kotlin\com
```
```kotlin
// android/app/src/main/kotlin/br/com/estudos/foco/MainActivity.kt
package br.com.estudos.foco

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```
```xml
<application android:label="Foco" android:name="${applicationName}" android:icon="@mipmap/ic_launcher">
```
`versionName` e `versionCode` não se editam no Gradle: as linhas `flutter.versionName`/`flutter.versionCode` já leem o `version: 1.0.0+1` do `pubspec.yaml`.

<a id="m15-e04"></a>
## M15-E04
Mova o arquivo com os mesmos três comandos de E03 e troque a **primeira linha** do arquivo movido:
```kotlin
// android/app/src/main/kotlin/br/com/estudos/foco/MainActivity.kt
package br.com.estudos.foco

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```
O defeito era a dessincronia entre três coisas que precisam concordar — pasta, linha `package` e `namespace`; mover só a pasta troca o erro de compilação por um `ClassNotFoundException` na abertura.

<a id="m15-e05"></a>
## M15-E05
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icone/icone.png"
  min_sdk_android: 24
  remove_alpha_ios: true
  adaptive_icon_background: "#3F51B5"
  adaptive_icon_foreground: "assets/icone/icone.png"
```
```powershell
flutter pub get
dart run flutter_launcher_icons
```
`min_sdk_android: 24` precisa bater com o `minSdk` real do projeto, senão o gerador pula o ícone adaptativo em silêncio e o `mipmap-anydpi-v26/ic_launcher.xml` não aparece; a cor hexadecimal exige aspas, ou o YAML lê `#3F51B5` como comentário.

<a id="m15-e06"></a>
## M15-E06
```yaml
flutter:
  uses-material-design: true

flutter_launcher_icons:          # coluna 1, irmão de flutter:, nunca filho
  image_path: "assets/icone/icone.png"
  min_sdk_android: 24
```
A mensagem engana porque o gerador procura uma chave de **primeiro nível** chamada `flutter_launcher_icons`; indentada, ela vira um campo qualquer dentro de `flutter:` e, para o leitor de YAML, a configuração realmente não existe.

<a id="m15-e07"></a>
## M15-E07
```yaml
flutter_native_splash:
  color: "#3F51B5"
  image: assets/icone/splash.png
  color_dark: "#121212"
  image_dark: assets/icone/splash.png
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
```powershell
dart run flutter_native_splash:create
adb shell am force-stop br.com.estudos.foco
adb shell am start -n br.com.estudos.foco/.MainActivity
```
A splash é um **tema de janela do Android** (`values/`, `values-night/`, `values-v31/`, `values-night-v31/`), desenhado pelo sistema assim que a `Activity` é criada. Nesse instante o engine do Flutter ainda está carregando e nenhum widget existe — por isso ela não pode ser um `Widget`, e por isso ela é o que impede o flash branco.

<a id="m15-e08"></a>
## M15-E08
```powershell
keytool -genkey -v `
  -keystore "$env:USERPROFILE\chaves\foco-upload.jks" `
  -keyalg RSA -keysize 2048 -validity 10000 -alias foco
```
```properties
# android/key.properties — NUNCA no Git
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=foco
storeFile=C:/Users/SEU_USUARIO/chaves/foco-upload.jks
```
```kotlin
// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream

val chaveProps = Properties()
val chaveArquivo = rootProject.file("key.properties")   // resolve para android/key.properties
if (chaveArquivo.exists()) {
    chaveProps.load(FileInputStream(chaveArquivo))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = chaveProps["keyAlias"] as String?
            keyPassword = chaveProps["keyPassword"] as String?
            storeFile = chaveProps["storeFile"]?.let { file(it) }
            storePassword = chaveProps["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```
```gitignore
*.jks
*.keystore
android/key.properties
```
Barras normais no `storeFile` porque `\` é caractere de escape em `.properties` — e o erro resultante (`Keystore file not found`) nunca menciona a barra.

<a id="m15-e09"></a>
## M15-E09
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />

    <application android:label="Foco" android:name="${applicationName}">
```
O debug funcionava porque o `src/debug/AndroidManifest.xml` só entra na fusão do build de debug — onde o Flutter já declara `INTERNET` para o hot reload; o build de release funde apenas `main/`, e a permissão simplesmente não chega ao APK. Confira no manifest fundido: `build/app/intermediates/merged_manifests/release/AndroidManifest.xml`.

<a id="m15-e10"></a>
## M15-E10
| # | Hipótese | Como confirmar |
|---|---|---|
| 1 | `POST_NOTIFICATIONS` não declarada | `aapt dump permissions app-release.apk` — se não listar, falta a linha no manifest de `main/` |
| 2 | Declarada, mas nunca pedida | `await Permission.notification.status` devolve `denied` e nenhum diálogo apareceu no uso |
| 3 | Já em `negadaParaSempre` | `status.isPermanentlyDenied == true`, ou `adb shell dumpsys package br.com.estudos.foco` na seção de permissões |

O Android 11 funciona porque ali notificação não é permissão de runtime: o `permission_handler` devolve `granted` sem diálogo. Correção: (1) é uma linha no manifest; (2) é chamar `GerenciadorPermissoes.pedirNotificacoes()` no momento certo; (3) só sai com `abrirConfiguracoes()`, porque nesse estado `request()` retorna negado na hora, sem mostrar nada — e o usuário acha que o botão quebrou.

<a id="m15-e11"></a>
## M15-E11
```powershell
flutter build apk --release
flutter build apk --release --split-per-abi
flutter build appbundle --release --obfuscate --split-debug-info=simbolos/1.0.0
```
| Artefato | Caminho | Tamanho |
|---|---|---:|
| APK universal | `build/app/outputs/flutter-apk/app-release.apk` | ~45 MB |
| APK arm64-v8a | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` | ~16 MB |
| APK armeabi-v7a | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` | ~15 MB |
| APK x86_64 | `build/app/outputs/flutter-apk/app-x86_64-release.apk` | ~17 MB |
| AAB | `build/app/outputs/bundle/release/app-release.aab` | ~29 MB |
| Mapeamento do R8 | `build/app/outputs/mapping/release/mapping.txt` | — |

Atenção ao teste: com `--split-per-abi` o Flutter **soma um prefixo por ABI** ao `versionCode`, então o `aapt dump badging` mostra números diferentes em cada APK — o que continua igual é o `versionName`. Comparar o `.aab` com o APK universal não faz sentido porque o `.aab` guarda todas as variantes e a Play entrega só uma: 29 MB no disco viram ~17 MB de download.

<a id="m15-e12"></a>
## M15-E12
**1. `Keystore file not found`** — sintoma: falha só no `assembleRelease`, logo depois de editar o `key.properties`. Causa: barra invertida no `storeFile`, lida como escape. Correção: trocar por `/`; `cd android; ./gradlew assembleRelease --stacktrace` mostra o caminho corrompido na exceção.

**2. Roda em debug, `ClassNotFoundException` em release** — sintoma: só o binário AOT quebra. Causa: o R8 removeu ou renomeou uma classe alcançada por reflexão. Correção: `-keep class br.com.estudos.foco.modelos.** { *; }` em `android/app/proguard-rules.pro`, usando o nome de classe que aparece no `--stacktrace`.

**3. `INSTALL_FAILED_NO_MATCHING_ABIS`** — sintoma: o APK existe e o `adb install` recusa no emulador. Causa: APK arm64 num emulador x86_64. Correção: `flutter build apk --release --target-platform android-x64`, ou instalar o `app-x86_64-release.apk` do `--split-per-abi`.

<a id="m15-e13"></a>
## M15-E13
**(a)** Play Console: **AAB**, único formato aceito para app novo e o que permite a entrega por dispositivo. Beta por link direto: **APK universal**, porque o testador instala um arquivo só, sem loja no meio e sem saber a ABI do aparelho dele. Emulador x86_64: o **APK da ABI x86_64**; o universal também instala, mas leva o triplo do peso sem motivo.

**(b)** Sem Play App Signing, perder o `.jks` significa que nenhuma atualização de `br.com.estudos.foco` pode mais ser assinada: resta republicar com outro `applicationId`, perdendo instalações e avaliações. Com Play App Signing, o que se perdeu foi só a chave de **upload** — você pede a redefinição à Google e continua publicando. Os três backups: gerenciador de senhas (arquivo mais as duas senhas), pen drive fora do computador e nuvem pessoal cifrada — três lugares, dois tipos de mídia, um fora de casa.

**(c)** Paro quando já li o `--stacktrace` inteiro procurando o **meu** pacote, já rodei `flutter clean` e já tentei reproduzir num projeto novo; se depois disso não sei nomear a causa, insistir só queima tempo. O pedido precisa trazer `flutter doctor -v`, o comando exato, a mensagem completa (não o print cortado), o que já foi tentado e o que mudou desde o último build que funcionava.

<a id="m15-e14"></a>
## M15-E14
```powershell
# Ordem: identidade (E03) -> ícone (E05) -> splash (E07) -> permissões em main/ (E09)
#        -> keystore e assinatura no Gradle (E08) -> só então o build.
flutter clean; flutter pub get
flutter build apk       --release --obfuscate --split-debug-info=simbolos/1.0.0
flutter build appbundle --release --obfuscate --split-debug-info=simbolos/1.0.0

# 1. instalação limpa
adb uninstall br.com.estudos.foco
adb install build/app/outputs/flutter-apk/app-release.apk

# 2. atualização: instale a versão ANTERIOR e depois a nova POR CIMA, sem uninstall
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 3-9. identidade, permissões, assinatura, tamanho
aapt dump badging     build/app/outputs/flutter-apk/app-release.apk
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk

# 10-12. modo avião, logcat limpo, fechar e reabrir
adb logcat -c    # use o app inteiro e então:
adb logcat -d | Select-String "E/flutter"
```
O item 2 é o que este desafio realmente cobra: só o `adb install -r` (sem `uninstall`) prova que o banco sqflite sobrevive à atualização — `adb uninstall` apaga os dados do app e esconde exatamente o bug que você está procurando.
