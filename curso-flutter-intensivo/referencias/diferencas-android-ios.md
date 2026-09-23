# Referência — Diferenças entre Android e iOS

> **O que é este arquivo.** Um comparativo prático, tema por tema, entre as duas plataformas
> que o seu app Flutter vai rodar. Use como consulta rápida enquanto estuda os módulos
> [15 — Build Android](../modulos/15-build-android/README.md) e
> [16 — Build iOS](../modulos/16-build-ios/README.md), e sempre que uma aula disser
> "isso muda entre Android e iOS".

---

## 🪟 Leia isto antes de qualquer tabela

Você está no **Windows 11**. Isso define, de forma dura e sem contorno, o que você consegue
executar agora:

| Você consegue AGORA, no Windows | Você só consegue COM UM MAC |
|---|---|
| Escrever 100% do código Dart/Flutter do app | Compilar o app para iOS |
| Rodar no Chrome, no Windows desktop e no emulador Android | Abrir o simulador de iPhone |
| Gerar **APK** e **AAB** de release, assinados | Gerar `.app`, `.xcarchive` e **IPA** |
| Editar `ios/Runner/Info.plist` como texto | Abrir `ios/Runner.xcworkspace` no Xcode |
| Entender todo o processo iOS (é o que o módulo 16 faz) | Enviar para TestFlight / App Store |

> 🍎 **Nunca** existirá um caminho oficial para gerar um IPA (o instalador do iOS) no Windows.
> O compilador e o assinador de código da Apple rodam **apenas no macOS**. Este curso ensina
> o processo iOS inteiro para que, no dia em que você tiver acesso a um Mac (seu, de um
> colega, de um laboratório ou de um serviço de build na nuvem), você só precise **executar**,
> não **aprender**.

**Legenda de emojis usada em todo o curso:**

| Emoji | Significa |
|---|---|
| 🤖 | específico do Android |
| 🍎 | específico do iOS |
| 🪟 | específico do Windows |
| 🖥️ | específico do macOS |
| 🐧 | específico do Linux |

---

## 1. Ambiente e ferramentas

**SDK** (*Software Development Kit* — o pacote de ferramentas, compiladores e bibliotecas que
você instala para conseguir programar para uma plataforma).

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| SDK da plataforma | Android SDK (instalado pelo Android Studio, via **SDK Manager**) | iOS SDK (vem **dentro** do Xcode) |
| Sistema operacional exigido | Windows, macOS ou Linux | **Somente macOS** |
| IDE oficial | Android Studio (baseado no IntelliJ) | Xcode |
| IDE que você vai usar no dia a dia | VS Code (com as extensões Flutter e Dart) | VS Code para o código Dart; Xcode só para o que é nativo |
| Linguagem nativa | Kotlin (e Java em projetos antigos) | Swift (e Objective-C em projetos antigos) |
| Máquina virtual / runtime nativo | ART (*Android Runtime*) | Runtime da Apple, com código compilado para ARM |
| Testar sem aparelho físico | **Emulador** — simula um aparelho Android inteiro, incluindo o sistema operacional, em uma máquina virtual | **Simulador** — roda uma versão do iOS compilada para o processador do Mac; não é uma máquina virtual completa |
| Testar em aparelho físico | Cabo USB + **Depuração USB** ligada nas Opções do Desenvolvedor | Cabo USB + o Mac precisa "confiar" no aparelho; exige conta Apple |
| Ferramenta de linha de comando para falar com o aparelho | `adb` (*Android Debug Bridge*) | `xcrun`, `xcodebuild`, `simctl` |
| Licenças a aceitar | Normalmente já aceitas na instalação do SDK; confira com `flutter doctor -v` | Licença do Xcode: `xcodebuild -license accept` |

### Emulador × Simulador — a diferença que importa na prática

| | 🤖 Emulador Android | 🍎 Simulador iOS |
|---|---|---|
| O que roda de verdade | Uma imagem completa do Android, virtualizada | O iOS recompilado para o processador do Mac |
| Velocidade | Mais lento; precisa de aceleração por hardware (HAXM/WHPX/Hypervisor) | Muito rápido |
| Fidelidade de desempenho | Baixa — nunca meça desempenho no emulador | Baixa — nunca meça desempenho no simulador |
| Câmera | Simulada (imagem sintética) ou webcam do PC | Não existe câmera no simulador |
| Disponível para você hoje | ✅ Sim (depois de instalar o Android Studio) | ❌ Não (exige Mac) |

> ⚠️ Regra que vale para as duas plataformas: **desempenho, memória e consumo de bateria só
> fazem sentido medidos em aparelho físico, em modo `--profile`**. Isso é o assunto do módulo
> [13 — Desempenho e segurança](../modulos/13-desempenho-e-seguranca/README.md).

---

## 2. Artefatos de build

**Artefato** = o arquivo final que sai do processo de compilação e que pode ser instalado ou
enviado para a loja.

| Artefato | Plataforma | O que é | Onde o Flutter grava | Serve para |
|---|---|---|---|---|
| `.apk` | 🤖 | *Android Package* — instalador direto | `build/app/outputs/flutter-apk/app-release.apk` | Instalar no seu aparelho, mandar para um testador por link/WhatsApp |
| `.apk` por ABI | 🤖 | Um APK por arquitetura de processador | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (+ `armeabi-v7a`, `x86_64`) | Reduzir o tamanho quando você distribui fora da loja |
| `.aab` | 🤖 | *Android App Bundle* — pacote que a **Google Play** usa para montar um APK sob medida para cada aparelho | `build/app/outputs/bundle/release/app-release.aab` | **Obrigatório** para publicar apps novos na Google Play |
| `.app` | 🍎 | O "pacote de aplicativo" do iOS — na verdade uma **pasta** que o macOS mostra como um arquivo único | dentro de `build/ios/` | Rodar no simulador |
| `.xcarchive` | 🍎 | Um arquivo de **arquivamento**: o app compilado + símbolos de depuração + metadados | `build/ios/archive/Runner.xcarchive` | Passo intermediário obrigatório antes de exportar o IPA |
| `.ipa` | 🍎 | *iOS App Store Package* — o instalador do iOS, assinado | `build/ios/ipa/<nome>.ipa` | Enviar para TestFlight / App Store Connect |

**ABI** (*Application Binary Interface*) = a arquitetura do processador. `arm64-v8a` é a de
praticamente todo celular Android atual; `armeabi-v7a` é de aparelhos antigos de 32 bits;
`x86_64` é usada pelo emulador rodando num PC.

**Comandos** (só o lado Android roda no seu Windows):

```powershell
flutter build apk --release
flutter build apk --split-per-abi
flutter build appbundle
```

```bash
# 🍎 SÓ NO MAC
flutter build ipa
flutter build ipa --export-method app-store-connect
```

> 🍎 **SÓ NO MAC.** `flutter build ipa` falha no Windows porque depende do `xcodebuild`.
> Veja o porquê em
> [16-build-ios/01-por-que-exige-macos.md](../modulos/16-build-ios/01-por-que-exige-macos.md).

---

## 3. Identidade do app

**Identidade** = o nome técnico, único no mundo, que diz para a loja e para o sistema
operacional "este app é este app". Depois de publicado, **não pode ser trocado**.

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Nome do conceito | `applicationId` | *Bundle Identifier* (Bundle ID) |
| Onde fica | `android/app/build.gradle.kts`, dentro de `defaultConfig` | No Xcode, em **Runner → Signing & Capabilities → Bundle Identifier** (guardado no `project.pbxproj`) |
| Como aparece no `Info.plist` | — | `CFBundleIdentifier` = `$(PRODUCT_BUNDLE_IDENTIFIER)` (uma **variável**, não o valor literal) |
| Valor gerado pelo `flutter create` | `com.example.<nome_do_projeto>` | `com.example.<nomeDoProjeto>` |
| Valor no projeto final do curso | `br.com.estudos.foco` | `br.com.estudos.foco` |
| Existe um segundo campo? | Sim: `namespace` — o pacote usado para gerar a classe `R` e o código Kotlin | Não |
| Nome exibido sob o ícone | `android:label` no `AndroidManifest.xml` | `CFBundleDisplayName` no `Info.plist` |
| Pode ser trocado depois de publicar? | ❌ Não. Trocar cria um app novo na loja | ❌ Não |

### 🤖 Trecho real do `android/app/build.gradle.kts`

```kotlin
android {
    namespace = "br.com.estudos.foco"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion   // 28.2.13676358 no Flutter 3.47

    defaultConfig {
        applicationId = "br.com.estudos.foco"
        minSdk = flutter.minSdkVersion        // 24
        targetSdk = flutter.targetSdkVersion  // 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

> ⚠️ `namespace` e `applicationId` **começam iguais**, mas são coisas diferentes.
> `namespace` é onde o código Kotlin/Java do módulo vive. `applicationId` é a identidade na
> loja. É legítimo (em projetos grandes) que sejam diferentes; no seu caso, mantenha iguais.

### 🍎 Trecho real do `ios/Runner/Info.plist`

```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>CFBundleDisplayName</key>
<string>Foco</string>
<key>CFBundleName</key>
<string>foco</string>
```

> 🍎 Note que o `Info.plist` **não** guarda o Bundle ID literal: ele guarda a variável
> `$(PRODUCT_BUNDLE_IDENTIFIER)`, que o Xcode substitui no momento do build. Por isso o lugar
> certo de trocar o Bundle ID é o Xcode, não o `Info.plist`.

---

## 4. Versão e numeração — **as duas saem do mesmo lugar**

No `pubspec.yaml` existe uma linha só:

```yaml
version: 1.0.0+1
```

Ela se divide em duas partes, separadas pelo `+`:

- **`1.0.0`** → o *build name*: a versão que o ser humano lê.
- **`1`** → o *build number*: o contador que a loja usa para saber qual envio é mais novo.

| Parte | 🤖 Android vira | 🍎 iOS vira |
|---|---|---|
| `1.0.0` (build name) | `versionName` | `CFBundleShortVersionString` |
| `1` (build number) | `versionCode` | `CFBundleVersion` |
| Quem vê | O usuário, na ficha da loja e na tela "Sobre" | O usuário, na App Store |
| Quem usa para comparar envios | A Google Play: o `versionCode` **precisa aumentar** a cada envio | A App Store: o `CFBundleVersion` precisa aumentar dentro da mesma versão |
| Tipo | Texto livre (`versionName`) / inteiro (`versionCode`) | Texto no formato `x.y.z` / texto numérico |

### 🍎 Como o `Info.plist` recebe isso

```xml
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
```

O Flutter injeta `FLUTTER_BUILD_NAME` e `FLUTTER_BUILD_NUMBER` no build do Xcode a partir do
`pubspec.yaml`. Ou seja: **você edita uma linha e as duas plataformas obedecem.**

### Sobrescrevendo na linha de comando

```powershell
flutter build appbundle --build-name=1.1.0 --build-number=7
```

```bash
# 🍎 SÓ NO MAC
flutter build ipa --build-name=1.0.0 --build-number=1
```

> ⚠️ Erro clássico: subir um AAB com o mesmo `versionCode` de um envio anterior. A Google Play
> recusa com uma mensagem do tipo "Version code 1 has already been used". A correção é sempre
> aumentar o número **depois** do `+`.

---

## 5. Assinatura de código

**Assinar** um app é usar uma chave criptográfica para provar "fui eu que publiquei isto".
Sem assinatura válida, nenhuma das duas plataformas instala ou aceita o app.

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| O que você cria | Um **keystore** (`.jks`): um cofre de arquivo que guarda uma ou mais chaves | Um **certificado** emitido pela Apple + um **provisioning profile** |
| Nome da chave dentro do cofre | **alias** | — |
| Quem emite | **Você mesmo** (chave autoassinada) | **A Apple**, a partir de um pedido (CSR) que você gera no Mac |
| Onde ficam as senhas | `android/key.properties` (arquivo que **nunca** entra no Git) | No **Keychain** (chaveiro) do macOS |
| Ferramenta | `keytool` (vem no JDK) | Xcode + portal do Apple Developer |
| Custo | Zero | Exige o Apple Developer Program para distribuição (US$ 99/ano) |
| Validade | Você escolhe (o curso usa 10.000 dias) | Certificado ~1 ano; provisioning profile ~1 ano (7 dias na conta gratuita) |
| Perder a chave significa | ❌ Você **não consegue mais atualizar** o app publicado (salvo com Play App Signing) | Você gera outro certificado; não é fatal |

### 🤖 Criando o keystore (Windows, PowerShell)

```powershell
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks `
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
        -alias upload
```

### 🤖 `android/key.properties` — **jamais** versione este arquivo

```properties
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=SEU_ALIAS
storeFile=C:\\Users\\SEU_USUARIO\\upload-keystore.jks
```

### 🔴 O que o `flutter create` do Flutter 3.47 REALMENTE gera

Abra `android/app/build.gradle.kts` de qualquer projeto recém-criado e você encontra isto:

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        // Signing with the debug keys for now, so `flutter run --release` works.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

> ⚠️ **Entenda o que isso significa.** Enquanto esse `TODO` estiver ali, o seu build "release"
> está assinado com a **chave de depuração** — uma chave genérica, igual na máquina de todo
> mundo. Esse APK **roda no seu celular**, mas a Google Play **recusa**. Esse comentário é um
> aviso, não decoração. O módulo 15 manda você substituir esse bloco pelo código abaixo.

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }
    buildTypes {
        release { signingConfig = signingConfigs.getByName("release") }
    }
}
```

### Linhas obrigatórias no `.gitignore` (das duas plataformas)

```text
android/key.properties
*.jks
*.keystore
ios/Runner/*.mobileprovision
*.p12
*.cer
*.certSigningRequest
.env
```

> 🔴 **Nunca** escreva no repositório uma senha, um alias real, o caminho do seu keystore, um
> certificado, uma API key ou o seu Team ID. Use sempre marcadores:
> `SUA_SENHA_AQUI`, `SEU_ALIAS`, `SEU_TEAM_ID`, `<seu-usuario>`.

---

## 6. Permissões

**Permissão** = autorização que o usuário dá para o app usar um recurso sensível (câmera,
localização, microfone, contatos, fotos).

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onde se declara | `android/app/src/main/AndroidManifest.xml` | `ios/Runner/Info.plist` |
| Formato | Tag `<uses-permission android:name="..."/>` | Par chave/valor: chave `NS...UsageDescription` + **texto em português** |
| Quando o usuário é perguntado | Na primeira vez que o app pede (permissões "perigosas", desde o Android 6 / API 23) | Na primeira vez que o recurso é usado |
| Texto exibido no diálogo | Escrito **pelo sistema**, você não controla | Escrito **por você**, na `<string>` do `Info.plist` |
| Se o usuário negar duas vezes | Vira "não perguntar novamente"; só volta pelas Configurações | Só volta pelas Configurações do iPhone |
| Permissão de internet | `android.permission.INTERNET` precisa estar declarada para o **release** | Não existe; a rede é liberada, mas o **ATS** exige HTTPS |
| Consequência de esquecer | O app trava ou a função simplesmente não funciona | A Apple **rejeita** o app na revisão |

### 🤖 Exemplo real — `AndroidManifest.xml`

As permissões são filhas diretas de `<manifest>` e vêm **antes** de `<application>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

    <application
        android:label="Foco"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop">
            <!-- ... -->
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

> 🤖 `android.permission.INTERNET` é adicionada **automaticamente** pelo Flutter nos builds de
> **debug**. Em **release** ela precisa estar no manifesto principal, senão o app instalado
> não consegue chamar a API e você só descobre depois de publicar.
>
> 🤖 `READ_MEDIA_IMAGES` substituiu `READ_EXTERNAL_STORAGE` para fotos a partir do Android 13
> (API 33). Aparelhos mais antigos continuam usando a permissão antiga — por isso pacotes como
> `image_picker` e `permission_handler` declaram as duas.

### 🍎 Exemplo real — `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da câmera para você anexar uma foto ao seu material de estudo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos da galeria para você escolher a imagem de capa da matéria.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Precisamos do microfone para você gravar um resumo em áudio da sua sessão de estudo.</string>
```

> 🍎 ⚠️ **A Apple rejeita o app se o texto for genérico.** "Precisamos de acesso" ou
> "Este app usa a câmera" costumam voltar da revisão. Escreva o motivo **real e específico**,
> em português, voltado ao usuário final: *o que* você vai fazer e *por quê*.

**ATS** (*App Transport Security*) é a política da Apple que bloqueia conexões HTTP sem
criptografia. O curso usa `https://jsonplaceholder.typicode.com`, que é HTTPS, então você não
precisa de nenhuma exceção — e é assim que deve ficar.

---

## 7. Navegação — voltar

Este é o ponto onde o usuário **sente** a plataforma mais rápido.

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Como se volta | Botão/gesto **Voltar** do sistema, que existe em qualquer tela | **Gesto de arrastar a partir da borda esquerda** da tela |
| Existe botão do sistema? | Sim (botão físico, barra de navegação ou gesto de borda, conforme o aparelho) | Não. Só o botão "voltar" desenhado na `AppBar` e o gesto de borda |
| Quem controla | O sistema envia o evento para o app | O `Navigator` do Flutter reproduz o gesto nativo |
| O app pode bloquear? | Sim, com `PopScope` | Sim, com `PopScope` — e isso **também desliga o gesto de borda** |
| Sair do app na primeira tela | Voltar na raiz fecha o app | Não existe "fechar o app" pelo gesto; o usuário usa o gesto de início |
| Transição padrão no Flutter | `ZoomPageTransitionsBuilder` (o conteúdo cresce e aparece) | Deslizamento horizontal com efeito de parallax |

### Interceptando o "voltar" — a API atual

`WillPopScope` está **obsoleto**. Use `PopScope<T>`:

```dart
PopScope<void>(
  canPop: !temAlteracoesNaoSalvas,
  onPopInvokedWithResult: (bool didPop, void resultado) {
    if (didPop) return; // já saiu; nada a fazer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salve ou descarte antes de sair.')),
    );
  },
  child: Scaffold(
    appBar: AppBar(title: const Text('Editar matéria')),
    body: const SizedBox.shrink(),
  ),
);
```

- `canPop: false` impede a saída **e** desabilita o gesto de borda do iOS.
- `onPopInvokedWithResult` recebe `didPop` = `true` quando a saída realmente aconteceu.

> ⚠️ Não use `canPop: false` "por precaução". No iOS, travar o gesto de borda é percebido como
> app quebrado. Trave só quando houver de fato algo a perder (formulário sujo, upload em curso).

O assunto completo está em
[11-recursos-nativos/08-botao-voltar-e-gestos.md](../modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md)
e em
[07-navegacao-e-formularios/05-navegacao-android-x-ios.md](../modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md).

---

## 8. Design: Material 3 × Cupertino / HIG

**Material 3** é o sistema de design do Google (também chamado de "Material You").
**HIG** (*Human Interface Guidelines*) é o conjunto de diretrizes de design da Apple.
No Flutter, o pacote `cupertino` implementa a aparência iOS.

| Tema | 🤖 Material 3 | 🍎 Cupertino / HIG |
|---|---|---|
| Widget raiz | `MaterialApp` | `CupertinoApp` |
| Estrutura de tela | `Scaffold` + `AppBar` | `CupertinoPageScaffold` + `CupertinoNavigationBar` |
| Título da barra | Alinhado à esquerda (padrão do M3) | **Centralizado** |
| Botão principal | `FilledButton` | `CupertinoButton.filled` |
| Alerta | `AlertDialog` (cantos arredondados, botões à direita) | `CupertinoAlertDialog` (botões empilhados, largura total) |
| Menu de ações | `showModalBottomSheet` | `CupertinoActionSheet` |
| Chave liga/desliga | `Switch` do Material | `CupertinoSwitch` (mais alto, animação diferente) |
| Indicador de carregamento | Círculo que gira | Roda de tracinhos (*spinner*) |
| Seletor de data | `showDatePicker` (calendário) | `CupertinoDatePicker` (rolagem tipo roleta) |
| Rolagem no fim da lista | Brilho/esticada (*stretch overscroll*) | Efeito elástico (*rubber band*) |
| Física de rolagem no Flutter | `ClampingScrollPhysics` | `BouncingScrollPhysics` |

### Densidade, tipografia e ícones

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Unidade de medida do sistema | **dp** (*density-independent pixel*), base 160 dpi | **pt** (*point*), base 163 ppi |
| Unidade no Flutter | *logical pixel* — o Flutter converte para as duas | *logical pixel* — o mesmo |
| Escalas de recurso | `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi` (pastas `res/mipmap-*`) | `@1x`, `@2x`, `@3x` (dentro do `Assets.xcassets`) |
| Fonte do sistema | Roboto | San Francisco (SF Pro) |
| Fonte usada pelo Flutter | Roboto (embutida no Material) | O Flutter usa a fonte do sistema quando disponível |
| Biblioteca de ícones | `Icons` (Material Symbols) | `CupertinoIcons` (pacote `cupertino_icons: ^1.0.8`) |
| Formato do ícone do app | Ícone adaptativo: duas camadas (fundo + frente), recortado pelo fabricante em círculo, quadrado arredondado ou gota | Quadrado único; o sistema arredonda. **Sem canal alfa** (transparência) |

O ícone e a splash são gerados pelos mesmos dois pacotes, para as duas plataformas:

```powershell
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

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

> ⚠️ `remove_alpha_ios: true` é **obrigatório**: a Apple rejeita ícone com transparência.
> `min_sdk_android: 24` precisa bater com o `minSdk` do projeto (24 no Flutter 3.47).
> E os blocos `flutter_launcher_icons:` / `flutter_native_splash:` são de **primeiro nível** no
> `pubspec.yaml` — alinhados com `dependencies:`, **não dentro** de `flutter:`.

### Splash screen (tela de abertura)

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Mecanismo | XML de *drawable* + `styles.xml` | Storyboard: `ios/Runner/Base.lproj/LaunchScreen.storyboard` |
| Arquivos gerados | `res/drawable/launch_background.xml`, `res/drawable-night/...`, `res/values/styles.xml`, `res/values-night/styles.xml` | Imagens em `Assets.xcassets/LaunchImage.imageset` + ajuste no `Info.plist` |
| Modo escuro | `-night` no nome da pasta | Variantes no `Assets.xcassets` |
| Regra especial | **Android 12+** (`res/values-v31/styles.xml`) mostra só o ícone centralizado, não a imagem inteira — por isso existe a seção `android_12:` | `UILaunchStoryboardName` = `LaunchScreen` |

### Escrevendo código que se adapta sozinho

```dart
// Widgets que já trocam de visual conforme a plataforma:
const CircularProgressIndicator.adaptive();
Switch.adaptive(value: ativo, onChanged: (v) {});
showAdaptiveDialog<void>(context: context, builder: (_) => const AlertDialog.adaptive(
  title: Text('Apagar matéria?'),
  content: Text('Esta ação não pode ser desfeita.'),
));

// Decidindo na mão, quando precisar:
final ehIOS = Theme.of(context).platform == TargetPlatform.iOS;
```

> ⚠️ Use `Theme.of(context).platform`, **não** `Platform.isIOS` do `dart:io`, dentro de
> widgets. O primeiro respeita a sobrescrita de plataforma do `ThemeData` (útil em testes e no
> DevTools); o segundo quebra no Flutter web.

Decisão do curso: o app **Foco** é Material 3 nas duas plataformas, usando os widgets
`.adaptive()` nos pontos onde a diferença incomoda (diálogos, chaves, indicador de progresso).
Isso é padrão de mercado e mantém um código só. O assunto está em
[11-recursos-nativos/09-material-x-cupertino.md](../modulos/11-recursos-nativos/09-material-x-cupertino.md).

---

## 9. Armazenamento — onde cada coisa é gravada

Toda plataforma móvel coloca o app dentro de um ***sandbox*** (caixa de areia): uma pasta
isolada que só aquele app enxerga. Nenhum outro app lê os seus arquivos.

| Solução do curso | 🤖 Onde grava no Android | 🍎 Onde grava no iOS | Some ao desinstalar? |
|---|---|---|---|
| `shared_preferences` | XML em `shared_prefs/`, dentro da pasta privada do app | `NSUserDefaults` (arquivo `.plist` na pasta de preferências do app) | 🤖 Sim · 🍎 Sim |
| `path_provider` → `getTemporaryDirectory()` | Pasta de cache do app | Pasta `Caches`/`tmp` do app | Sim (e o sistema pode limpar sozinho a qualquer momento) |
| `path_provider` → `getApplicationSupportDirectory()` | Pasta interna de arquivos do app | Pasta `Application Support` do app | Sim |
| `path_provider` → `getApplicationDocumentsDirectory()` | Pasta privada de dados do app | Pasta `Documents` do app | Sim |
| `path_provider` → `getExternalStorageDirectory()` | Pasta do app no armazenamento "externo" | ❌ **Não existe no iOS** — lança erro | Sim |
| `sqflite` | Pasta `databases/` do app, obtida por `getDatabasesPath()` | Pasta do sandbox devolvida por `getDatabasesPath()` | Sim |
| `flutter_secure_storage` | **Android Keystore** + armazenamento cifrado | **Keychain** (chaveiro do iOS) | 🤖 Sim · 🍎 ⚠️ **Pode sobreviver** |

```dart
// Sempre monte o caminho do banco assim — nunca escreva o caminho na mão:
final caminho = p.join(await getDatabasesPath(), 'foco.db');
```

### 🔴 A pegadinha do Keychain no iOS

No iOS, itens gravados no **Keychain** podem **continuar existindo depois que o usuário
desinstala o app**. Se ele reinstalar, o token antigo reaparece. No Android isso não acontece:
desinstalar apaga tudo do app.

**Como tratar:** na primeira execução, grave uma marca em `shared_preferences` (que *some* na
desinstalação). Se a marca não existir, limpe o `flutter_secure_storage` antes de qualquer
coisa. Isso é ensinado em
[10-persistencia-de-dados/07-dados-sensiveis.md](../modulos/10-persistencia-de-dados/07-dados-sensiveis.md).

### Backup automático

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Mecanismo | *Auto Backup for Apps* — a partir do Android 6, ligado por padrão | Backup do iCloud e do iTunes/Finder |
| Controlado por | `android:allowBackup` e regras de backup no `AndroidManifest.xml` | Pasta em que o arquivo está + a marca `isExcludedFromBackup` |
| O que costuma entrar | Preferências e arquivos internos do app | Tudo em `Documents` e `Application Support` |
| O que nunca entra | O que você excluir pelas regras | `Caches` e `tmp` |
| Risco real | Um token cifrado ir para o backup e ser restaurado em outro aparelho, onde a chave do Keystore não existe mais → falha ao descriptografar | Um banco de dados grande em `Documents` inflar o backup do usuário |

> ⚠️ Regra prática: **dado sensível não vai para backup**; **cache não vai para `Documents`**.
> Se o arquivo pode ser baixado de novo, ele pertence à pasta temporária.

---

## 10. O processo de build

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Sistema de build | **Gradle** | **Xcode build system** (`xcodebuild`) |
| Linguagem dos scripts | **Kotlin DSL** (`.kts`) — padrão no Flutter 3.47 | Configuração do projeto + arquivos `.xcconfig` |
| Arquivo principal do app | `android/app/build.gradle.kts` | `ios/Runner.xcodeproj/project.pbxproj` (editado pelo Xcode) |
| Arquivo de configuração do projeto | `android/settings.gradle.kts` | `ios/Flutter/Debug.xcconfig`, `ios/Flutter/Release.xcconfig` |
| Arquivo gerado (não edite) | `android/local.properties` | `ios/Flutter/Generated.xcconfig` |
| Versão do Gradle (wrapper) | **9.3.1** | — |
| Android Gradle Plugin (AGP) | **9.1.0** | — |
| Kotlin Gradle Plugin | **2.4.0** | — |
| Java exigido | **17** (`JavaVersion.VERSION_17` + `jvmTarget = JVM_17`) | — |
| `compileSdk` / `targetSdk` | **36** | — |
| `minSdk` | **24** (Android 7.0) | — |
| `ndkVersion` | **28.2.13676358** | — |
| Versão mínima do sistema | Android 7.0 (API 24) | **iOS 13** |
| Gerenciador de dependências nativas | Gradle (Maven Central / Google Maven) | **Swift Package Manager (SPM)** — padrão desde o Flutter 3.44; **CocoaPods** como alternativa |
| Arquivo que você abre para trabalhar | Nenhum — o `flutter build` chama o Gradle | `ios/Runner.xcworkspace` — **sempre o `.xcworkspace`, nunca o `.xcodeproj`** |

> 🔴 **Atenção com tutoriais antigos.** Muitos mandam editar `android/app/build.gradle`
> **sem** o `.kts`, com sintaxe Groovy (`def`, aspas simples, sem `=`). Isso está
> **desatualizado**. No Flutter 3.47 o arquivo é `build.gradle.kts`, em Kotlin, com `=` nas
> atribuições e aspas duplas nas strings. Se você colar código Groovy num arquivo `.kts`, o
> Gradle falha com erro de compilação do script.

### 🍎 SPM × CocoaPods — o estado atual

- **Swift Package Manager (SPM)** é o gerenciador de pacotes oficial da Apple e está **ligado
  por padrão** no Flutter desde a versão 3.44. O `flutter create` já gera
  `ios/Flutter/ephemeral/Packages` e `ios/Flutter/ephemeral/.swift_pm.lock`.
- O Flutter **volta automaticamente para o CocoaPods** se algum plugin do projeto ainda não
  suportar SPM. Os dois convivem no mesmo projeto.
- O **registro do CocoaPods se torna somente-leitura em 2 de dezembro de 2026**. O CocoaPods
  está em modo de manutenção. Continua funcionando para o que já existe, mas não é o futuro.
- Mesmo assim, **aprenda os dois**: quase toda mensagem de erro de iOS que você vai encontrar
  em fóruns fala de CocoaPods, e projetos existentes ainda usam `Podfile`.

```bash
# Ligar/desligar o SPM globalmente
flutter config --enable-swift-package-manager
flutter config --no-enable-swift-package-manager
```

```yaml
# Desligar apenas neste projeto, no pubspec.yaml
flutter:
  config:
    enable-swift-package-manager: false
```

```bash
# 🍎 SÓ NO MAC — CocoaPods
sudo gem install cocoapods
pod install
pod repo update
pod deintegrate   # remove o CocoaPods de um projeto cujos plugins já suportam SPM
```

> 🍎 **SÓ NO MAC.** `pod` é um programa Ruby distribuído pela Apple/comunidade que só roda em
> macOS neste contexto. No Windows você lê, entende e anota — não executa.

### 🍎 `SceneDelegate` — não apague

O `flutter create` do 3.47 gera `ios/Runner/SceneDelegate.swift` e um bloco
`UIApplicationSceneManifest` no `Info.plist`, com `UISceneDelegateClassName` =
`$(PRODUCT_MODULE_NAME).SceneDelegate` e `UISceneStoryboardFile` = `Main`. É o mecanismo
moderno da Apple para gerenciar janelas/cenas. Projetos antigos migram com a flag
`enable-uiscene-migration`. **Não ensine, nem tente, remover isso.**

### 🍎 Mapa dos arquivos iOS

```text
ios/Runner.xcworkspace                          <- SEMPRE abra este, NUNCA o .xcodeproj
ios/Runner.xcodeproj/project.pbxproj
ios/Runner/Info.plist
ios/Runner/AppDelegate.swift
ios/Runner/SceneDelegate.swift
ios/Runner/Base.lproj/LaunchScreen.storyboard   <- splash screen do iOS
ios/Runner/Base.lproj/Main.storyboard
ios/Runner/Assets.xcassets/AppIcon.appiconset   <- ícone do app
ios/Runner/Assets.xcassets/LaunchImage.imageset
ios/Flutter/Debug.xcconfig
ios/Flutter/Release.xcconfig
ios/Flutter/Generated.xcconfig                  <- gerado, não edite
ios/RunnerTests/
```

---

## 11. Distribuição

| Tema | 🤖 Google Play | 🍎 App Store |
|---|---|---|
| Painel de controle | **Google Play Console** | **App Store Connect** |
| Formato aceito | `.aab` (App Bundle) para apps novos | `.ipa` enviado pelo Xcode ou por linha de comando |
| Teste com pessoas | Faixas: **teste interno**, **teste fechado**, **teste aberto**, **produção** | **TestFlight**: testadores internos (time) e externos (convidados) |
| Convite de testador | Por e-mail, lista ou link | Por e-mail ou link público do TestFlight |
| Revisão | Majoritariamente **automatizada**, com revisão humana em casos específicos | **Revisão humana** em praticamente todo envio |
| Tempo típico até publicar | Horas a alguns dias | Normalmente de horas a poucos dias |
| Motivo comum de recusa | Política de dados, permissões sem justificativa, conteúdo | Texto de permissão genérico, app sem funcionalidade suficiente, links de pagamento externo |
| Atualizar sem revisão | Não | Não |
| Distribuir fora da loja | ✅ Sim — mandar o APK direto (*sideload*) | ❌ Não, para o público geral |

Fora da loja, no Android, você manda o APK e a pessoa instala habilitando "fontes
desconhecidas". No iOS não existe equivalente prático: mesmo para testar no seu próprio
iPhone, o app precisa ser assinado com um perfil ligado àquele aparelho.

> 🍎 **Conta Apple gratuita × paga.** Com uma conta gratuita (Apple ID comum) você consegue,
> **num Mac**, instalar o app no **seu próprio** iPhone, e o perfil expira em **7 dias** —
> depois disso o app para de abrir e você precisa reinstalar. Não há TestFlight nem App Store.
> Para qualquer distribuição real, é o **Apple Developer Program** pago.

As faixas de teste, o preenchimento da ficha da loja e o processo de envio estão em
[17-publicacao-e-proximos-passos/01-google-play.md](../modulos/17-publicacao-e-proximos-passos/01-google-play.md)
e
[17-publicacao-e-proximos-passos/02-app-store-connect.md](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md).

---

## 12. Custo

| Item | 🤖 Android | 🍎 iOS |
|---|---|---|
| Conta de desenvolvedor | **US$ 25, pagamento único** (Google Play Console) | **US$ 99 por ano** (Apple Developer Program) |
| Renovação | Não existe | Anual. Se você não renovar, os apps **saem da loja** |
| Hardware exigido | Qualquer PC (Windows, macOS, Linux) | **Um Mac.** Não há caminho oficial sem isso |
| Ferramentas | Gratuitas (Android Studio, SDK) | Xcode é gratuito, mas roda só em macOS |
| Testar no próprio aparelho | Grátis, sem conta nenhuma | Grátis com Apple ID, **num Mac**, com perfil de 7 dias |
| Publicar em loja | Exige a conta de US$ 25 | Exige a conta de US$ 99/ano |
| Distribuir sem loja | Grátis (APK direto) | Inviável na prática |

> 💡 Consequência prática para você, hoje: **comece pelo Android.** Você paga uma vez, publica,
> recebe feedback real e só depois decide se o iOS compensa. Este curso é montado nessa ordem
> justamente por isso — o módulo 15 (Android) vem antes do 15 (iOS).

Valores de US$ 25 e US$ 99 são os praticados publicamente pelas duas empresas; confirme na
página oficial antes de pagar, porque políticas e impostos mudam.

---

## 13. O que você faz no Windows × o que exige Mac

| Tarefa | 🪟 Windows | 🖥️ Mac |
|---|---|---|
| Escrever código Dart/Flutter | ✅ | ✅ |
| `flutter analyze`, `dart format`, `flutter test` | ✅ | ✅ |
| Testar a camada de dados com `sqflite_common_ffi` | ✅ | ✅ |
| Rodar no Chrome (`flutter run -d chrome`) | ✅ | ✅ |
| Rodar no desktop (`flutter run -d windows`) | ✅ | (roda no macOS) |
| Emulador Android / aparelho Android por USB | ✅ | ✅ |
| `flutter build apk` / `flutter build appbundle` | ✅ | ✅ |
| Criar keystore com `keytool` e assinar o release Android | ✅ | ✅ |
| Publicar na Google Play | ✅ | ✅ |
| Ler e editar `ios/Runner/Info.plist` (é só XML) | ✅ | ✅ |
| Gerar ícones e splash iOS com os pacotes do curso | ✅ (os arquivos são criados na pasta `ios/`) | ✅ |
| Abrir `ios/Runner.xcworkspace` | ❌ | ✅ |
| Rodar o simulador de iPhone | ❌ | ✅ |
| `pod install` / SPM resolvendo pacotes Swift | ❌ | ✅ |
| `flutter build ipa` | ❌ | ✅ |
| Assinar com certificado + provisioning profile | ❌ | ✅ |
| Enviar para TestFlight / App Store | ❌ | ✅ |

> 🍎 **SÓ NO MAC.** Os itens marcados com ❌ na coluna Windows não têm alternativa oficial.
> Existem serviços de integração contínua que alugam máquinas macOS na nuvem para rodar o
> build — isso é apresentado, como caminho possível, em
> [17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md](../modulos/17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md).
> Mas o build continua acontecendo **num macOS**; o que muda é quem é dono da máquina.

### O que fazer hoje para não travar quando o Mac aparecer

1. Deixe `applicationId` e Bundle ID já definidos como `br.com.estudos.foco`.
2. Deixe `version: 1.0.0+1` no `pubspec.yaml` — vale para as duas plataformas.
3. Escreva **agora** os textos das chaves `NS...UsageDescription` no `Info.plist`.
4. Rode os geradores de ícone e splash: eles já criam os arquivos iOS.
5. Garanta que nenhum pacote do `pubspec.yaml` seja "Android only" — todos os do curso
   (`sqflite`, `shared_preferences`, `flutter_secure_storage`, `path_provider`,
   `connectivity_plus`) suportam iOS.
6. Deixe o `.gitignore` já preparado para `*.mobileprovision`, `*.p12` e `*.cer`.

Com isso, no Mac sobra: instalar o Xcode, abrir o `.xcworkspace`, escolher o time de
assinatura e rodar `flutter build ipa`.

---

## 14. Erros comuns de quem só conhece um lado

| Sintoma | Plataforma | Causa | Correção |
|---|---|---|---|
| "Version code 1 has already been used" | 🤖 | `versionCode` repetido | Aumentar o número depois do `+` no `pubspec.yaml` |
| Play recusa o upload do release | 🤖 | O `buildTypes.release` ainda usa `signingConfigs.getByName("debug")` | Trocar pelo `signingConfig` de release (seção 5) |
| App funciona em debug e não acessa a internet em release | 🤖 | Falta `<uses-permission android:name="android.permission.INTERNET"/>` no manifesto | Declarar a permissão |
| Erro de sintaxe no Gradle depois de colar código de um tutorial | 🤖 | Código Groovy num arquivo `.kts` | Converter para Kotlin DSL: `=` nas atribuições, aspas duplas |
| Ícone rejeitado pela App Store | 🍎 | Ícone com canal alfa | `remove_alpha_ios: true` no `flutter_launcher_icons` |
| App rejeitado por texto de permissão | 🍎 | `NS...UsageDescription` genérico | Escrever o motivo real e específico |
| Gesto de voltar não funciona no iPhone | 🍎 | `PopScope` com `canPop: false` | Travar só quando houver dado a perder |
| `getExternalStorageDirectory()` lança erro | 🍎 | Essa pasta não existe no iOS | Usar `getApplicationDocumentsDirectory()` |
| Token reaparece depois de reinstalar | 🍎 | Keychain sobrevive à desinstalação | Limpar o *secure storage* na primeira execução |
| Mudanças de ícone/splash não aparecem | 🤖🍎 | Cache do Gradle/Xcode | `flutter clean` e rebuildar |

A lista completa, com o texto literal dos erros reproduzidos nesta máquina, está em
[erros-comuns.md](erros-comuns.md).

---

## 15. 📋 Tabela-resumo — uma página

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| **SO para desenvolver** | Windows / macOS / Linux | **Somente macOS** |
| **IDE nativa** | Android Studio | Xcode |
| **Linguagem nativa** | Kotlin | Swift |
| **Teste sem aparelho** | Emulador | Simulador (só no Mac) |
| **Arquivo de build** | `android/app/build.gradle.kts` (Kotlin DSL) | `ios/Runner.xcworkspace` (abra este) |
| **Ferramenta de build** | Gradle 9.3.1 + AGP 9.1.0 + Kotlin 2.4.0 | `xcodebuild` |
| **Java** | 17 | — |
| **SDK alvo** | `compileSdk` 36 / `targetSdk` 36 | SDK do Xcode |
| **Mínimo suportado** | `minSdk` 24 (Android 7.0) | iOS 13 |
| **Dependências nativas** | Gradle | SPM (padrão) · CocoaPods (alternativa, somente-leitura em 2/dez/2026) |
| **Identidade** | `applicationId` (+ `namespace`) | Bundle Identifier (`CFBundleIdentifier`) |
| **Nome exibido** | `android:label` | `CFBundleDisplayName` |
| **Versão visível** | `versionName` | `CFBundleShortVersionString` |
| **Número do build** | `versionCode` | `CFBundleVersion` |
| **Origem dos dois** | `version: 1.0.0+1` do `pubspec.yaml` | `version: 1.0.0+1` do `pubspec.yaml` |
| **Assinatura** | Keystore `.jks` + alias, autoassinado | Certificado da Apple + provisioning profile |
| **Senhas ficam em** | `android/key.properties` (fora do Git) | Keychain do macOS |
| **Permissões** | `<uses-permission>` no `AndroidManifest.xml` | `NS...UsageDescription` no `Info.plist` |
| **Texto do diálogo de permissão** | Escrito pelo sistema | Escrito por você |
| **Voltar** | Botão/gesto do sistema, em qualquer tela | Gesto a partir da borda esquerda |
| **Bloquear o voltar** | `PopScope` | `PopScope` (desliga também o gesto de borda) |
| **Design** | Material 3 | HIG / Cupertino |
| **Fonte do sistema** | Roboto | San Francisco |
| **Ícones** | `Icons` (Material Symbols) | `CupertinoIcons` |
| **Escalas de imagem** | `mdpi` → `xxxhdpi` | `@1x` / `@2x` / `@3x` |
| **Ícone do app** | Adaptativo, duas camadas | Quadrado único, **sem transparência** |
| **Splash** | `launch_background.xml` + `styles.xml` (+ `values-v31` no Android 12+) | `LaunchScreen.storyboard` |
| **Rolagem no limite** | Brilho / esticada | Elástica |
| **Chave-valor** | SharedPreferences (XML) | NSUserDefaults (plist) |
| **Sensível** | Android Keystore | Keychain (⚠️ sobrevive à desinstalação) |
| **Backup** | Auto Backup (ligado por padrão) | iCloud (`Documents` e `Application Support`) |
| **Artefatos** | `.apk`, `.aab` | `.app`, `.xcarchive`, `.ipa` |
| **Saída do release** | `build/app/outputs/bundle/release/app-release.aab` | `build/ios/ipa/<nome>.ipa` |
| **Loja** | Google Play Console | App Store Connect |
| **Teste com pessoas** | Faixas interna/fechada/aberta | TestFlight |
| **Revisão** | Muito automatizada | Humana, quase sempre |
| **Custo** | **US$ 25, uma vez** | **US$ 99, por ano** |
| **Fora da loja** | APK direto ✅ | Inviável ❌ |
| **Você consegue hoje, no Windows?** | ✅ Tudo, até publicar | ❌ Só ler, entender e preparar |

---

## 16. Onde estudar cada tema neste curso

| Tema | Aula |
|---|---|
| Por que o iOS exige Mac | [16-build-ios/01-por-que-exige-macos.md](../modulos/16-build-ios/01-por-que-exige-macos.md) |
| Xcode e CocoaPods | [16-build-ios/02-xcode-e-cocoapods.md](../modulos/16-build-ios/02-xcode-e-cocoapods.md) |
| Bundle ID no Xcode | [16-build-ios/04-bundle-id-e-xcode.md](../modulos/16-build-ios/04-bundle-id-e-xcode.md) |
| Ícone, splash e versão no `Info.plist` | [16-build-ios/05-icone-splash-versao-infoplist.md](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md) |
| Conta Apple gratuita × paga | [16-build-ios/06-conta-apple-gratuita-x-paga.md](../modulos/16-build-ios/06-conta-apple-gratuita-x-paga.md) |
| Certificados e provisioning | [16-build-ios/07-certificados-e-provisioning.md](../modulos/16-build-ios/07-certificados-e-provisioning.md) |
| Identidade do app (Android) | [15-build-android/02-identidade-do-app.md](../modulos/15-build-android/02-identidade-do-app.md) |
| Keystore | [15-build-android/06-keystore.md](../modulos/15-build-android/06-keystore.md) |
| Assinatura no Gradle | [15-build-android/07-assinatura-no-gradle.md](../modulos/15-build-android/07-assinatura-no-gradle.md) |
| APK e AAB | [15-build-android/08-gerando-apk-e-aab.md](../modulos/15-build-android/08-gerando-apk-e-aab.md) |
| Permissões (as duas plataformas) | [11-recursos-nativos/01-permissoes.md](../modulos/11-recursos-nativos/01-permissoes.md) |
| Pastas `android/` e `ios/` | [11-recursos-nativos/07-pastas-android-e-ios.md](../modulos/11-recursos-nativos/07-pastas-android-e-ios.md) |
| Botão voltar e gestos | [11-recursos-nativos/08-botao-voltar-e-gestos.md](../modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md) |
| Material × Cupertino | [11-recursos-nativos/09-material-x-cupertino.md](../modulos/11-recursos-nativos/09-material-x-cupertino.md) |
| Navegação Android × iOS | [07-navegacao-e-formularios/05-navegacao-android-x-ios.md](../modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md) |
| Qual armazenamento usar | [10-persistencia-de-dados/01-qual-armazenamento-usar.md](../modulos/10-persistencia-de-dados/01-qual-armazenamento-usar.md) |
| Depurando Android e iOS | [12-testes-e-debug/09-depurando-android-e-ios.md](../modulos/12-testes-e-debug/09-depurando-android-e-ios.md) |
| Versionamento e releases | [17-publicacao-e-proximos-passos/03-versionamento-e-releases.md](../modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md) |

Checklists prontas para imprimir:
[checklists/build-android.md](../checklists/build-android.md) ·
[checklists/build-ios.md](../checklists/build-ios.md) ·
[checklists/ambiente-android.md](../checklists/ambiente-android.md) ·
[checklists/ambiente-ios.md](../checklists/ambiente-ios.md)

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre APK, AAB, `.app`, `.xcarchive` e IPA sem consultar a tabela.
- [ ] Sei que `applicationId` e Bundle ID não podem mudar depois de publicar.
- [ ] Sei que `version: 1.0.0+1` vira `versionName`/`versionCode` **e** `CFBundleShortVersionString`/`CFBundleVersion`.
- [ ] Sei onde declarar uma permissão em cada plataforma, e quem escreve o texto do diálogo.
- [ ] Sei que o `buildTypes.release` gerado pelo `flutter create` está assinado com a chave de **debug**.
- [ ] Sei que o SPM é o padrão desde o Flutter 3.44 e que o CocoaPods vira somente-leitura em 2/dez/2026.
- [ ] Sei que o Keychain do iOS pode sobreviver à desinstalação e como contornar.
- [ ] Sei exatamente o que consigo fazer hoje no Windows e o que fica esperando um Mac.
- [ ] Nunca escrevi senha, alias, caminho de keystore, certificado, API key ou Team ID reais em um arquivo versionado.

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [Erros comuns](erros-comuns.md) | [README do curso](../README.md) | [Referências oficiais](referencias-oficiais.md) |
