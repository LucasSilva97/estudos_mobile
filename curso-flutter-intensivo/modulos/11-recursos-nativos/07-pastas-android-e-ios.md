# Aula 7 — Pastas android/ e ios/

> **Módulo:** 11 - Recursos Nativos · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Navegar pela pasta **`android/`** sem medo: `build.gradle.kts`, `settings.gradle.kts`,
  `local.properties`, `res/`, `MainActivity`.
- Navegar pela pasta **`ios/`**: `Runner.xcworkspace` × `.xcodeproj`, `Info.plist`, `AppDelegate`,
  `.xcconfig`, `Podfile`.
- Saber **o que versionar** e o que nunca entra no Git.
- Entender a diferença entre **`applicationId`** e **`bundle identifier`**.
- Reconhecer **onde cada configuração mora** — e por que um plugin manda editar aquele arquivo.
- Diagnosticar os erros de build mais comuns, lendo a mensagem certa.
- Decidir quando **regenerar** as pastas nativas é a saída.

## ✅ Pré-requisitos

- [Módulo 05, aula 2 — Estrutura do projeto](../05-introducao-ao-flutter/02-estrutura-do-projeto.md)
  — a visão geral das pastas.
- [Aula 1 — Permissões](01-permissoes.md) e [Aula 4 — Notificações](04-notificacoes.md) — elas
  mandaram você editar esses arquivos; aqui você entende o que estava fazendo.
- [Módulo 00, aula 4 — Commits, branches e .gitignore](../00-git-e-terminal/04-commits-branches-gitignore.md).

---

## 📖 Conceito

### Por que essas pastas existem

Um projeto Flutter tem, na raiz:

```text
meu_app/
├── lib/            ← o SEU código Dart
├── android/        ← um projeto Android completo
├── ios/            ← um projeto iOS completo
├── test/
└── pubspec.yaml
```

`android/` e `ios/` **não são detalhes do Flutter**. São projetos nativos de verdade: você poderia
abrir `android/` no Android Studio e `ios/` no Xcode, e eles compilariam.

O que o Flutter faz é **embutir o motor** dentro deles. O `MainActivity` do Android e o
`AppDelegate` do iOS são o ponto onde o app nativo entrega a tela para o Flutter desenhar.

> 📌 **A consequência prática:** tudo que é **do sistema operacional** — nome do app, ícone,
> permissões, versão mínima, assinatura — mora nessas pastas. Nada disso está no Dart, porque nada
> disso é assunto do Flutter.

### A pasta `android/`

```text
android/
├── app/
│   ├── build.gradle.kts          ← CONFIGURAÇÃO DO SEU APP
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml    ← permissões, nome, atividade
│       │   ├── kotlin/.../MainActivity.kt
│       │   └── res/                   ← ícones, cores, strings, XML
│       ├── debug/AndroidManifest.xml  ← só no modo debug
│       └── profile/AndroidManifest.xml
├── build.gradle.kts              ← configuração do PROJETO (raro mexer)
├── settings.gradle.kts           ← versões dos plugins do Gradle
├── gradle.properties             ← memória da JVM, flags
├── gradle/wrapper/               ← qual versão do Gradle usar
└── local.properties              ← ⚠️ CAMINHOS DA SUA MÁQUINA
```

Os arquivos que você realmente vai editar:

| Arquivo | Para quê |
|---|---|
| `app/build.gradle.kts` | `applicationId`, versões do SDK, assinatura, `minSdk` |
| `app/src/main/AndroidManifest.xml` | Permissões, nome do app, atividades, receivers |
| `app/src/main/res/` | Ícone, cores, strings, XMLs de configuração |
| `settings.gradle.kts` | Versão do plugin do Android Gradle |
| `local.properties` | **Nunca.** É gerado, e nunca vai para o Git |

> ⚠️ **Desde o Flutter 3.29, os arquivos Gradle usam Kotlin DSL (`.kts`).** Projetos antigos têm
> `.gradle` (Groovy). A sintaxe muda: `applicationId "com.x"` (Groovy) vira
> `applicationId = "com.x"` (Kotlin). Tutoriais antigos usam Groovy — traduza.

### `app/build.gradle.kts`, por dentro

```kotlin
android {
    namespace = "com.exemplo.foco"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        // O IDENTIFICADOR ÚNICO do app na Play Store.
        // NUNCA muda depois de publicado.
        applicationId = "com.exemplo.foco"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

Os quatro números que confundem todo mundo:

| Campo | O que é | Consequência de mudar |
|---|---|---|
| **`minSdk`** | Versão **mínima** do Android suportada | Subir exclui aparelhos antigos |
| **`targetSdk`** | Versão para a qual o app foi **testado** | Define quais regras novas se aplicam |
| **`compileSdk`** | Versão do SDK usada para **compilar** | Permite usar APIs novas |
| **`versionCode`** | Número **inteiro** da build | A Play Store exige que **sempre suba** |

> ⚠️ **`targetSdk` é o que mais gera confusão.** Ele não limita onde o app roda — ele diz ao Android
> "eu fui testado com as regras da versão X". Se você declara `targetSdk = 33`, o sistema aplica as
> regras do Android 13 ao seu app, **mesmo rodando no Android 15**. A Play Store **exige** um
> `targetSdk` recente para aceitar atualizações.

### `AndroidManifest.xml`, por dentro

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Permissões: TUDO que o app precisa pedir. -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:label="Foco"                    <!-- nome sob o ícone -->
        android:name="${applicationName}"       <!-- o Flutter preenche -->
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize">

            <!-- Diz ao Android: esta é a tela que abre ao tocar no ícone. -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

Três atributos que importam e que você não deve remover:

| Atributo | O que faz se remover |
|---|---|
| `android:name="${applicationName}"` | O Flutter não inicializa — tela preta |
| `android:windowSoftInputMode="adjustResize"` | O teclado **cobre** os campos |
| `android:exported="true"` na MainActivity | O app não abre no Android 12+ |

> 📌 **Há três manifests:** `main/`, `debug/` e `profile/`. Eles são **mesclados** na build. O de
> debug tem `INTERNET` (para o hot reload) — que é por isso que o app funciona em debug e falha em
> release quando você esquece de declarar `INTERNET` no `main`.

### `local.properties`: nunca versione

```properties
sdk.dir=C\:\\Users\\Usuario\\AppData\\Local\\Android\\sdk
flutter.sdk=C\:\\src\\flutter
```

São **caminhos da sua máquina**. Na máquina de outra pessoa, eles não existem — e o build quebra
com uma mensagem confusa.

O `.gitignore` do Flutter já o exclui. Se você o vir no `git status`, algo está errado.

### A pasta `ios/`

```text
ios/
├── Runner.xcworkspace          ← ⚠️ ABRA ESTE no Xcode
├── Runner.xcodeproj            ← NÃO abra este diretamente
├── Runner/
│   ├── Info.plist              ← permissões, nome, versão
│   ├── AppDelegate.swift       ← ponto de entrada nativo
│   ├── Assets.xcassets/        ← ícones e imagens
│   └── Base.lproj/             ← storyboards (launch screen)
├── Flutter/
│   ├── Debug.xcconfig          ← configuração de build
│   ├── Release.xcconfig
│   └── Generated.xcconfig      ← ⚠️ GERADO, não versionado
├── Podfile                     ← dependências CocoaPods
├── Podfile.lock                ← versões travadas (VERSIONE)
└── Pods/                       ← ⚠️ baixado, NÃO versionado
```

> ⚠️ **`.xcworkspace` × `.xcodeproj` é o erro número 1 de quem abre um projeto Flutter no Xcode.**
>
> O CocoaPods cria o **workspace** para juntar o seu projeto com as dependências. Abrir o
> `.xcodeproj` direto ignora os Pods — e o build falha com erros de "módulo não encontrado" que não
> fazem sentido nenhum.
>
> **Sempre `Runner.xcworkspace`.**

### `Info.plist`, por dentro

É um XML de pares chave-valor:

```xml
<key>CFBundleDisplayName</key>
<string>Foco</string>                    <!-- nome sob o ícone -->

<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>   <!-- versão visível: 1.2.0 -->

<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string> <!-- build: 42 -->

<!-- TODA permissão do iOS precisa de uma justificativa em texto. -->
<key>NSCameraUsageDescription</key>
<string>O Foco usa a câmera para você anexar fotos das suas anotações.</string>
```

| Chave | O que controla |
|---|---|
| `CFBundleDisplayName` | Nome sob o ícone |
| `CFBundleName` | Nome interno (curto) |
| `CFBundleShortVersionString` | Versão visível na App Store |
| `CFBundleVersion` | Número da build |
| `NSxxxUsageDescription` | **Justificativa** de cada permissão |
| `UISupportedInterfaceOrientations` | Rotações permitidas |
| `UIFileSharingEnabled` | Pasta visível no app Arquivos |

> ⚠️ **Toda permissão do iOS exige uma `UsageDescription`** — e ela precisa **explicar o motivo**,
> não repetir o nome da permissão. "Este app usa a câmera" é rejeitado pela Apple. "O Foco usa a
> câmera para você anexar fotos das suas anotações" passa.
>
> Sem a chave, o app **trava** ao pedir a permissão — não dá erro, trava.

### `.xcconfig` e o `Generated.xcconfig`

O Flutter injeta configuração no Xcode por meio de arquivos `.xcconfig`:

```text
Flutter/Debug.xcconfig      → inclui Generated.xcconfig
Flutter/Release.xcconfig    → inclui Generated.xcconfig
Flutter/Generated.xcconfig  → GERADO pelo `flutter build`
```

O `Generated.xcconfig` contém o caminho do SDK do Flutter, o `FLUTTER_BUILD_NAME`, o
`FLUTTER_BUILD_NUMBER` — tudo derivado do `pubspec.yaml`.

Ele é **gerado** e **não vai para o Git**. É o equivalente iOS do `local.properties`.

### O que versionar

| Arquivo | Versionar? | Por quê |
|---|---|---|
| `android/app/build.gradle.kts` | ✅ | Configuração do app |
| `android/app/src/main/AndroidManifest.xml` | ✅ | Permissões |
| `android/app/src/main/res/` | ✅ | Ícones, cores |
| `android/local.properties` | ❌ | Caminhos da sua máquina |
| `android/.gradle/`, `android/build/` | ❌ | Gerados |
| `ios/Runner/Info.plist` | ✅ | Configuração |
| `ios/Runner/Assets.xcassets/` | ✅ | Ícones |
| `ios/Podfile` | ✅ | Declaração de dependências |
| `ios/Podfile.lock` | ✅ | **Versões exatas** — todos compilam igual |
| `ios/Pods/` | ❌ | Baixado pelo `pod install` |
| `ios/Flutter/Generated.xcconfig` | ❌ | Gerado |
| `*.jks`, `*.keystore`, `key.properties` | ❌ | **Chaves de assinatura** |
| `google-services.json`, `GoogleService-Info.plist` | ⚠️ | Contêm ids do projeto — decida |

> 📌 **`Podfile.lock` gera dúvida.** Versione: ele trava as versões exatas dos Pods, e sem ele duas
> pessoas podem compilar com versões diferentes da mesma dependência — e só uma tem o bug.

### Quando regenerar

Às vezes as pastas nativas ficam em um estado ruim: um plugin removido deixou lixo, uma
atualização do Flutter mudou a estrutura, o projeto veio de uma versão muito antiga.

```powershell
# 1. Guarde o que você editou à mão (manifest, Info.plist, res/).
# 2. Apague e regenere:
Remove-Item -Recurse -Force android, ios
flutter create --platforms=android,ios .
# 3. Reaplique as suas edições.
```

> ⚠️ **Isto apaga tudo que você editou nessas pastas.** Ícone, permissões, configuração de
> assinatura, `Info.plist` — tudo volta ao padrão. Por isso o passo 1 não é opcional: sem Git ou
> uma cópia, o trabalho se perde.
>
> Só faça isso depois de tentar `flutter clean` e `flutter pub get`.

---

## 💡 Analogia

Pense num restaurante dentro de um shopping.

- **`lib/`** é a **cozinha**: onde você cria os pratos. É onde você passa 95% do tempo.
- **`android/` e `ios/`** são as **exigências do shopping e da prefeitura**: alvará, placa na
  fachada, saída de emergência, extintor. Nada disso tem a ver com a comida — e sem isso o
  restaurante não abre.
- **Dois shoppings, duas burocracias.** O que o shopping A chama de "alvará sanitário", o B chama de
  "licença de operação". É por isso que existem **duas** pastas: `applicationId` no Android,
  `bundle identifier` no iOS — a mesma ideia, dois formulários diferentes.
- **`local.properties`** é o **crachá de estacionamento** com a sua placa. É seu, é da sua máquina,
  e entregá-lo a outra pessoa não serve para nada. Por isso não vai para o Git.
- **`.xcworkspace` × `.xcodeproj`** é a diferença entre a **planta do prédio inteiro** e a planta
  **só da sua loja**. Você precisa da primeira para entender onde ficam as paredes compartilhadas
  (as dependências). Abrir só a sua planta e mandar reformar é como o build falha.
- **`Podfile.lock`** é a lista com as **marcas e modelos exatos** dos equipamentos instalados. Sem
  ela, o técnico da manutenção troca por "um equivalente" — e aí uma loja tem um problema que a
  outra não tem.
- **Regenerar as pastas** é pedir a **planta padrão** do shopping de novo. Vem limpa — e sem
  nenhuma das adaptações que você fez ao longo do tempo.

---

## 🧪 Exemplo mínimo

Um mapa navegável das duas pastas, gerado a partir do projeto real.

> **Arquivo:** `foco_nativo/tool/mapear_nativo.dart` (novo — ferramenta de estudo)
> **Como executar:** `dart run tool/mapear_nativo.dart`

```dart
import 'dart:io';

/// Mapeia as pastas android/ e ios/, explicando cada arquivo.
///
/// Rode dentro de um projeto Flutter. A ideia é substituir "essa pasta
/// me assusta" por "eu sei o que tem aqui".
void main() {
  print('═══ MAPA DAS PASTAS NATIVAS ═══\n');

  _mapearAndroid();
  print('');
  _mapearIos();
  print('');
  _verificarGitignore();
}

/// O que cada arquivo faz. A chave é o final do caminho.
const Map<String, String> _explicacoes = <String, String>{
  // ── Android ──
  'android/app/build.gradle.kts':
      'CONFIGURAÇÃO DO APP: applicationId, minSdk, targetSdk, assinatura',
  'android/app/build.gradle':
      'Idem, em Groovy (projetos anteriores ao Flutter 3.29)',
  'android/build.gradle.kts': 'Configuração do PROJETO — raro mexer',
  'android/settings.gradle.kts': 'Versões dos plugins do Gradle',
  'android/gradle.properties': 'Memória da JVM, flags do AndroidX',
  'android/local.properties':
      '⚠️ CAMINHOS DA SUA MÁQUINA — nunca versione',
  'android/app/src/main/AndroidManifest.xml':
      'PERMISSÕES, nome do app, atividades, receivers',
  'android/app/src/debug/AndroidManifest.xml':
      'Só no modo debug — traz INTERNET para o hot reload',
  'android/app/src/profile/AndroidManifest.xml': 'Só no modo profile',
  'android/app/src/main/res': 'Ícones, cores, strings, XMLs de configuração',
  'android/gradle/wrapper/gradle-wrapper.properties':
      'Qual versão do Gradle usar',

  // ── iOS ──
  'ios/Runner.xcworkspace':
      '⚠️ ABRA ESTE no Xcode — junta o projeto com os Pods',
  'ios/Runner.xcodeproj':
      '⚠️ NÃO abra direto: ignora os Pods e o build falha',
  'ios/Runner/Info.plist':
      'PERMISSÕES (UsageDescription), nome, versão, orientações',
  'ios/Runner/AppDelegate.swift':
      'Ponto de entrada nativo — plugins registram aqui',
  'ios/Runner/Assets.xcassets': 'Ícones e imagens do app',
  'ios/Runner/Base.lproj/LaunchScreen.storyboard': 'Tela de abertura',
  'ios/Podfile': 'Dependências CocoaPods e versão mínima do iOS',
  'ios/Podfile.lock': 'VERSÕES TRAVADAS — versione, para todos compilarem igual',
  'ios/Pods': '⚠️ Baixado pelo pod install — não versione',
  'ios/Flutter/Debug.xcconfig': 'Configuração de build (debug)',
  'ios/Flutter/Release.xcconfig': 'Configuração de build (release)',
  'ios/Flutter/Generated.xcconfig':
      '⚠️ GERADO pelo Flutter — não versione',
};

void _mapearAndroid() {
  print('📁 android/');
  _listar('android', profundidadeMaxima: 4);
}

void _mapearIos() {
  print('📁 ios/');
  _listar('ios', profundidadeMaxima: 3);
}

/// Pastas cujo conteúdo não interessa (geradas ou enormes).
const Set<String> _ignorar = <String>{
  'build', '.gradle', '.dart_tool', 'Pods', '.symlinks', 'Flutter/ephemeral',
};

void _listar(String raiz, {required int profundidadeMaxima, int nivel = 1}) {
  final Directory pasta = Directory(raiz);
  if (!pasta.existsSync()) {
    print('   (não existe — o projeto não tem esta plataforma)');
    return;
  }

  final List<FileSystemEntity> filhos = pasta.listSync()
    ..sort((FileSystemEntity a, FileSystemEntity b) {
      // Pastas primeiro, depois alfabético.
      final bool aPasta = a is Directory;
      final bool bPasta = b is Directory;
      if (aPasta != bPasta) return aPasta ? -1 : 1;
      return a.path.compareTo(b.path);
    });

  for (final FileSystemEntity filho in filhos) {
    final String nome = filho.path.split(Platform.pathSeparator).last;
    if (nome.startsWith('.') && nome != '.gitignore') continue;

    final String recuo = '   ' * nivel;
    // Normaliza para casar com as chaves do mapa.
    final String caminho = filho.path.replaceAll(r'\', '/');
    final String? explicacao = _explicacaoDe(caminho);

    if (filho is Directory) {
      final bool ignorada = _ignorar.any((String i) => nome == i);
      print('$recuo📂 $nome${explicacao == null ? "" : "   ← $explicacao"}'
          '${ignorada ? "   (gerada)" : ""}');

      if (!ignorada && nivel < profundidadeMaxima) {
        _listar(filho.path,
            profundidadeMaxima: profundidadeMaxima, nivel: nivel + 1);
      }
    } else {
      final int bytes = (filho as File).lengthSync();
      print('$recuo📄 $nome (${_tamanho(bytes)})'
          '${explicacao == null ? "" : "   ← $explicacao"}');
    }
  }
}

String? _explicacaoDe(String caminho) {
  for (final MapEntry<String, String> e in _explicacoes.entries) {
    if (caminho.endsWith(e.key)) return e.value;
  }
  return null;
}

String _tamanho(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

/// Confere se os arquivos que NUNCA devem ser versionados estão ignorados.
void _verificarGitignore() {
  print('═══ VERIFICAÇÃO DO .gitignore ═══\n');

  const List<String> naoVersionar = <String>[
    'android/local.properties',
    'ios/Flutter/Generated.xcconfig',
    'ios/Pods',
    'android/app/key.properties',
  ];

  final File gitignore = File('.gitignore');
  if (!gitignore.existsSync()) {
    print('⚠️ .gitignore não encontrado');
    return;
  }

  final String conteudo = gitignore.readAsStringSync();

  for (final String alvo in naoVersionar) {
    final String nome = alvo.split('/').last;
    final bool coberto =
        conteudo.contains(nome) || conteudo.contains(alvo);
    print('${coberto ? "✅" : "⚠️"} $alvo');
  }

  print('\n💡 Rode `git status` e confirme que nenhum destes aparece.');
  print('   Se aparecer, ele já pode ter sido commitado antes.');
}
```

```powershell
dart run tool/mapear_nativo.dart
```

**Faça isto:** rode e leia a saída inteira, arquivo por arquivo. Ao terminar, você deve conseguir
responder, para cada um: *o que é isso e por que está aqui?*

---

## 📱 Aplicando no Flutter

Agora você vai configurar o `foco_nativo` de ponta a ponta nas duas plataformas: identificador,
nome, versão mínima, permissões e orientação.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/android/app/build.gradle.kts`
> **Como executar:** `flutter build apk --debug`

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // O plugin do Flutter precisa vir DEPOIS dos dois acima.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // namespace: o pacote Java/Kotlin do código nativo.
    // Desde o AGP 8, ele é obrigatório AQUI (antes ficava no manifest).
    namespace = "com.exemplo.foconativo"

    // Versão do SDK usada para COMPILAR. Permite usar APIs novas.
    // `flutter.compileSdkVersion` acompanha o SDK do Flutter —
    // fixe um número só se algum plugin exigir.
    compileSdk = flutter.compileSdkVersion

    // NDK: só importa se algum plugin usa código C/C++.
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // ⚠️ O IDENTIFICADOR ÚNICO do app na Play Store.
        //
        // NUNCA muda depois de publicado: mudar cria um app DIFERENTE,
        // e os usuários do antigo não recebem a atualização.
        //
        // Convenção: domínio invertido. Se você tem exemplo.com.br,
        // use br.com.exemplo.foco.
        applicationId = "com.exemplo.foconativo"

        // Versão MÍNIMA do Android. Subir exclui aparelhos antigos.
        //
        // 23 (Android 6) é o mínimo do flutter_secure_storage.
        // 21 cobriria mais aparelhos, mas hoje representa <1% do mercado.
        minSdk = 23

        // Versão para a qual o app foi TESTADO.
        //
        // Não limita onde o app roda: diz ao Android "aplique as regras
        // da versão X ao meu app". A Play Store EXIGE um valor recente
        // para aceitar atualizações.
        targetSdk = flutter.targetSdkVersion

        // Vêm do pubspec.yaml: `version: 1.0.0+1`
        //   1.0.0 → versionName (visível ao usuário)
        //   1     → versionCode (inteiro; a Play Store exige que SEMPRE suba)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ⚠️ Assinado com a chave de DEBUG por enquanto.
            // Isto permite `flutter run --release` no seu aparelho,
            // e NÃO serve para publicar.
            // O Módulo 14 substitui isto pela assinatura de verdade.
            signingConfig = signingConfigs.getByName("debug")

            // isMinifyEnabled / isShrinkResources: reduzem o APK.
            // Desligados aqui porque exigem regras de ProGuard —
            // assunto do Módulo 13.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
```

> **Arquivo:** `foco_nativo/android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- ══ PERMISSÕES ══
         Toda permissão que o app usa precisa estar declarada aqui.
         Declarar não é pedir: as "perigosas" (câmera, local) ainda
         precisam de request() em tempo de execução. Aula 1. -->

    <!-- Normal: concedida automaticamente, sem diálogo. -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Perigosa: exige request() em tempo de execução. -->
    <uses-permission android:name="android.permission.CAMERA" />

    <!-- Android 13+: notificar virou permissão de tempo de execução. -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- Reagenda notificações depois de o aparelho reiniciar.
         Sem isto, todos os lembretes somem no reboot. Aula 4. -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <!-- ══ RECURSOS OPCIONAIS ══
         required="false" permite instalar em aparelhos SEM câmera
         (tablets, emuladores). Sem esta linha, a Play Store esconde
         o app desses aparelhos. -->
    <uses-feature
        android:name="android.hardware.camera"
        android:required="false" />

    <application
        <!-- Nome sob o ícone. Em app com vários idiomas,
             use @string/app_name. -->
        android:label="Foco"

        <!-- ⚠️ ${applicationName} é substituído pelo Flutter.
             REMOVER isto faz o app abrir com tela preta. -->
        android:name="${applicationName}"

        android:icon="@mipmap/ic_launcher"

        <!-- Exclui o cofre e o banco do backup automático. Módulo 10. -->
        android:fullBackupContent="@xml/backup_rules"
        android:dataExtractionRules="@xml/data_extraction_rules"

        <!-- Android 14+: predictive back. Módulo 07, aula 5. -->
        android:enableOnBackInvokedCallback="true">

        <activity
            android:name=".MainActivity"

            <!-- ⚠️ Obrigatório no Android 12+.
                 Sem isto, o app NÃO ABRE. -->
            android:exported="true"

            <!-- singleTop: tocar na notificação reaproveita a activity
                 em vez de abrir outra por cima. -->
            android:launchMode="singleTop"

            <!-- ⚠️ adjustResize: o teclado ENCOLHE a tela em vez de
                 cobri-la. Sem isto, os campos de baixo ficam
                 inacessíveis. Módulo 06, aula 11. -->
            android:windowSoftInputMode="adjustResize"

            <!-- Evita o app reiniciar ao girar a tela ou mudar o tema.
                 O Flutter trata essas mudanças sozinho. -->
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"

            android:hardwareAccelerated="true">

            <!-- Tema da tela de abertura, antes de o Flutter carregar.
                 Sem ele, há um flash branco. Módulo 14, aula 4. -->
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <!-- Diz ao Android: esta é a tela que abre ao tocar no ícone. -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Receivers do flutter_local_notifications. Aula 4. -->
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
            </intent-filter>
        </receiver>

        <!-- Exigido pelo Flutter. Não remova. -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <!-- ══ QUERIES ══
         Android 11+: o app só "enxerga" outros apps declarados aqui.
         Sem isto, abrir o navegador ou o cliente de e-mail falha
         silenciosamente. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.SENDTO" />
            <data android:scheme="mailto" />
        </intent>
    </queries>
</manifest>
```

> **Arquivo:** `foco_nativo/android/app/src/main/kotlin/com/exemplo/foconativo/MainActivity.kt`

```kotlin
package com.exemplo.foconativo

import io.flutter.embedding.android.FlutterActivity

/**
 * Ponto de entrada nativo no Android.
 *
 * Num app Flutter típico, este arquivo fica VAZIO assim mesmo — toda a
 * interface é desenhada pelo Flutter.
 *
 * Você só mexe aqui quando precisa de:
 *  - MethodChannel para código nativo específico;
 *  - inicializar um SDK nativo antes do Flutter;
 *  - tratar um Intent de deep link com lógica própria.
 *
 * O `package` acima PRECISA bater com o caminho da pasta e com o
 * `namespace` do build.gradle.kts. Se você renomear o applicationId,
 * lembre-se de mover este arquivo também.
 */
class MainActivity : FlutterActivity()
```

> **Arquivo:** `foco_nativo/ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ══ IDENTIDADE ══ -->

    <!-- Nome sob o ícone. Até ~12 caracteres, ou é cortado. -->
    <key>CFBundleDisplayName</key>
    <string>Foco</string>

    <!-- Nome interno, curto, sem espaços. -->
    <key>CFBundleName</key>
    <string>foco_nativo</string>

    <!-- ⚠️ NÃO fica aqui: o bundle identifier está no .xcodeproj,
         em PRODUCT_BUNDLE_IDENTIFIER. Edite no Xcode, em
         Runner > Signing & Capabilities. -->

    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <!-- ══ VERSÃO ══
         As duas variáveis vêm do pubspec.yaml: `version: 1.0.0+1`
           1.0.0 → CFBundleShortVersionString (visível na App Store)
           1     → CFBundleVersion (build; precisa SEMPRE subir) -->
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>

    <!-- ══ PERMISSÕES ══
         ⚠️ TODA permissão do iOS exige uma UsageDescription.

         Sem a chave, o app TRAVA ao pedir a permissão — não dá erro,
         trava. E o texto precisa EXPLICAR O MOTIVO: "Este app usa a
         câmera" é rejeitado pela Apple na revisão. -->

    <key>NSCameraUsageDescription</key>
    <string>O Foco usa a câmera para você fotografar suas anotações de estudo.</string>

    <key>NSPhotoLibraryUsageDescription</key>
    <string>O Foco acessa suas fotos para você anexar imagens às suas matérias.</string>

    <!-- Só se o app SALVAR fotos na galeria. -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>O Foco salva na sua galeria os gráficos de progresso que você exportar.</string>

    <!-- ══ INTERFACE ══ -->

    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>

    <!-- Orientações permitidas no iPhone. -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <!-- iPad: a Apple EXIGE as quatro orientações em apps universais. -->
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <!-- Esconde a barra de status durante a tela de abertura. -->
    <key>UIStatusBarHidden</key>
    <false/>

    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>

    <!-- ══ FLUTTER ══ -->

    <!-- Exigido pelo Flutter. Não remova. -->
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>

    <!-- Permite o uso de View controllers baseados em UIScene. -->
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>

    <!-- ══ ARQUIVOS ══
         Descomente APENAS se o app produz documentos que o usuário
         deve manipular. Com isto ligado, a pasta Documents do app
         aparece no app "Arquivos" — e o usuário pode apagar o banco
         que estiver ali. Aula 3.

    <key>UIFileSharingEnabled</key>
    <true/>
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
    -->
</dict>
</plist>
```

> **Arquivo:** `foco_nativo/ios/Podfile` (o cabeçalho que importa)

```ruby
# Versão MÍNIMA do iOS.
#
# 13.0 é o mínimo do Flutter atual. Subir exclui aparelhos antigos;
# alguns plugins exigem 14 ou 15 — o erro do `pod install` diz qual.
platform :ios, '13.0'

# Silencia avisos de analytics do CocoaPods.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  # ⚠️ Lê o Generated.xcconfig — o arquivo GERADO pelo Flutter.
  # Se este erro aparecer, rode `flutter pub get` antes do `pod install`.
  generated_xcode_build_settings_path =
    File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)

  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. " \
          "If you're running pod install manually, make sure " \
          "flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}."
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin',
                                   'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      # Alguns plugins (permission_handler, entre outros) exigem que
      # você DECLARE quais permissões o app usa. As não declaradas são
      # compiladas fora do binário — o que evita a Apple perguntar
      # "por que o app pede acesso ao Bluetooth?".
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

> **Arquivo:** `foco_nativo/.gitignore` (a parte nativa)

```text
# ══ ANDROID ══
# Caminhos da SUA máquina. Na máquina de outra pessoa não existem.
android/local.properties

# Gerados na build.
android/.gradle/
android/app/debug/
android/app/profile/
android/app/release/
android/build/
android/captures/
android/.cxx/

# ⚠️ CHAVES DE ASSINATURA. Perder é ruim; vazar é pior:
# qualquer um pode publicar uma atualização falsa do seu app.
# Módulo 14.
android/key.properties
**/*.jks
**/*.keystore

# ══ iOS ══
# Gerado pelo Flutter, com caminhos locais.
ios/Flutter/Generated.xcconfig
ios/Flutter/flutter_export_environment.sh
ios/Flutter/ephemeral/
ios/Flutter/App.framework
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec

# Baixado pelo `pod install`. Pesado e reconstruível.
ios/Pods/
ios/.symlinks/

# ⚠️ Podfile.lock NÃO entra aqui: ele deve ser VERSIONADO.
# Sem ele, duas pessoas compilam com versões diferentes da
# mesma dependência — e só uma tem o bug.

# Configuração pessoal do Xcode.
ios/Runner.xcworkspace/xcuserdata/
ios/Runner.xcodeproj/xcuserdata/
ios/Runner.xcodeproj/project.xcworkspace/xcuserdata/

# Certificados e perfis. Módulo 15.
**/*.mobileprovision
**/*.p12
**/*.cer
```

Confira que tudo compila:

```powershell
flutter clean
flutter pub get
flutter build apk --debug
```

E confira que nada indevido está versionado:

```powershell
git status
git ls-files | Select-String "local.properties|Generated.xcconfig|\.jks$|Pods/"
```

O segundo comando deve voltar **vazio**. Se voltar algo, o arquivo já foi commitado antes — e
precisa ser removido do índice com `git rm --cached`.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `namespace` no `build.gradle.kts` | Desde o AGP 8, obrigatório aqui (antes ficava no manifest). |
| `applicationId` | Identificador único na Play Store. **Nunca muda** depois de publicado. |
| `minSdk = 23` | Mínimo do `flutter_secure_storage`. Subir exclui aparelhos; descer pode quebrar plugins. |
| `targetSdk` | Diz "fui testado com as regras da versão X". **Não** limita onde roda. A Play Store exige valor recente. |
| `signingConfig = signingConfigs.getByName("debug")` no release | Permite `--release` no seu aparelho. **Não serve para publicar** — Módulo 14. |
| `android:name="${applicationName}"` | O Flutter substitui. Remover produz **tela preta**. |
| `android:exported="true"` | **Obrigatório** no Android 12+. Sem isso o app não abre. |
| `android:windowSoftInputMode="adjustResize"` | O teclado **encolhe** a tela. Sem isso, cobre os campos. |
| `android:configChanges="..."` | Evita o app reiniciar ao girar ou trocar o tema. |
| `<uses-feature required="false" />` | Sem isso, a Play Store **esconde** o app de aparelhos sem câmera. |
| `<queries>` | Android 11+: sem isso, abrir o navegador falha **em silêncio**. |
| `MainActivity` vazia | Normal. Só se mexe nela para `MethodChannel` ou SDK nativo. |
| `CFBundleDisplayName` × `CFBundleName` | O primeiro é o nome sob o ícone; o segundo é interno. |
| `$(FLUTTER_BUILD_NAME)` | Vem do `pubspec.yaml`. Não escreva a versão à mão em dois lugares. |
| `NSCameraUsageDescription` explicando o motivo | Sem a chave, o app **trava**. Com texto genérico, a Apple **rejeita**. |
| `UISupportedInterfaceOrientations~ipad` com as quatro | A Apple **exige** em apps universais. |
| `platform :ios, '13.0'` no Podfile | Mínimo do Flutter atual. Plugins podem exigir mais — o erro do `pod install` diz qual. |
| `PERMISSION_CAMERA=1` no `post_install` | Permissões não declaradas ficam fora do binário — evita a Apple perguntar por acessos que o app não usa. |
| `Podfile.lock` **fora** do `.gitignore` | Trava as versões. Sem ele, duas pessoas compilam diferente. |
| `*.jks` e `key.properties` no `.gitignore` | Vazar a chave permite a qualquer um publicar uma atualização falsa do seu app. |

---

## 🤖🍎 Android × iOS

| Conceito | 🤖 Android | 🍎 iOS |
|---|---|---|
| Identificador único | `applicationId` (`build.gradle.kts`) | `PRODUCT_BUNDLE_IDENTIFIER` (`.xcodeproj`) |
| Nome do app | `android:label` (manifest) | `CFBundleDisplayName` (`Info.plist`) |
| Permissões | `<uses-permission>` | `NSxxxUsageDescription` |
| Justificativa obrigatória | ❌ | ✅ **sem ela o app trava** |
| Versão mínima | `minSdk` | `platform :ios` (Podfile) |
| Dependências nativas | Gradle | CocoaPods (ou SPM) |
| Ponto de entrada | `MainActivity.kt` | `AppDelegate.swift` |
| Ícone | `res/mipmap-*/` | `Assets.xcassets/AppIcon` |
| Onde abrir o projeto | Android Studio (pasta `android/`) | Xcode (**`.xcworkspace`**) |
| Build sem a outra plataforma | ✅ no Windows | ❌ **exige macOS** |

> ⚠️ **A última linha é a restrição prática do curso.** Você não consegue compilar para iOS no
> Windows — nem com máquina virtual, legalmente. O Módulo 15 explica o processo inteiro para quando
> você tiver acesso a um Mac; até lá, `ios/` é uma pasta que você **entende** e configura, mas não
> compila.

> 📌 **SPM está substituindo o CocoaPods.** O Flutter tem suporte experimental ao Swift Package
> Manager, e a migração está em andamento. Por enquanto, CocoaPods continua sendo o padrão — e é o
> que o curso usa.

---

## ⚠️ Erros comuns

### 1. Abrir `Runner.xcodeproj` no Xcode

```text
Module 'path_provider_foundation' not found
```

O `.xcodeproj` ignora os Pods.

**Correção:** abra sempre `Runner.xcworkspace`.

### 2. Versionar `local.properties`

O build quebra na máquina de outra pessoa, com mensagem confusa sobre SDK não encontrado.

**Correção:** `.gitignore`. Se já foi commitado: `git rm --cached android/local.properties`.

### 3. Esquecer a `UsageDescription` no iOS

```text
This app has crashed because it attempted to access privacy-sensitive
data without a usage description.
```

O app **trava**, não dá erro tratável.

**Correção:** acrescente a chave ao `Info.plist`.

### 4. `UsageDescription` genérica

"Este app precisa da câmera" → **rejeitado** na revisão da App Store.

**Correção:** explique o **motivo**, do ponto de vista do usuário.

### 5. Mudar o `applicationId` depois de publicar

Cria um app **diferente** na loja. Os usuários do antigo não recebem a atualização.

**Correção:** escolha bem antes da primeira publicação.

### 6. Remover `android:name="${applicationName}"`

O app abre com **tela preta** e nenhum erro.

**Correção:** não remova.

### 7. Esquecer `android:exported="true"`

```text
Apps targeting Android 12 and higher are required to specify an explicit
value for android:exported
```

O app **não abre**.

### 8. `minSdk` baixo demais

```text
uses-sdk:minSdkVersion 19 cannot be smaller than version 23 declared
in library [:flutter_secure_storage]
```

**Correção:** suba para o exigido pelo plugin.

### 9. `pod install` sem `flutter pub get`

```text
Generated.xcconfig must exist. If you're running pod install manually,
make sure flutter pub get is executed first
```

**Correção:** `flutter pub get` antes.

### 10. Versionar `ios/Pods/`

Centenas de MB no repositório, conflitos constantes.

**Correção:** `.gitignore`. Versione o `Podfile.lock`, não os Pods.

### 11. **Não** versionar `Podfile.lock`

Duas pessoas compilam com versões diferentes da mesma dependência.

**Correção:** versione.

### 12. Versionar o keystore

Qualquer um com acesso ao repositório pode publicar uma atualização falsa do seu app.

**Correção:** `.gitignore` — e, se já vazou, **gere uma chave nova** (o que, no Android, exige
migração de assinatura pelo Play Console).

### 13. Esquecer `<queries>` no Android 11+

Abrir o navegador ou o cliente de e-mail falha **em silêncio**.

**Correção:** declare os intents em `<queries>`.

### 14. Editar `Generated.xcconfig`

Ele é reescrito a cada build. Suas mudanças somem.

**Correção:** edite `Debug.xcconfig` ou `Release.xcconfig`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `dart run tool/mapear_nativo.dart` e leia a saída inteira. Anote três arquivos que
você não conhecia.

**Passo 2.** Abra `android/app/build.gradle.kts` e localize `applicationId`, `minSdk` e
`targetSdk`. Anote os valores.

**Passo 3.** Mude `minSdk` para `19` e rode `flutter build apk --debug`. Leia o erro e identifique
**qual plugin** exige mais.

**Passo 4.** Remova `android:exported="true"` da `MainActivity` e rode. Leia a mensagem.

**Passo 5.** Remova `android:windowSoftInputMode="adjustResize"`, rode num emulador e toque num
campo de texto no fim de um formulário longo. Descreva o problema.

**Passo 6.** Abra `ios/Runner/Info.plist` e localize as três `UsageDescription`. Reescreva uma delas
como a Apple rejeitaria, e outra como ela aceitaria.

**Passo 7.** Rode `git status` e confirme que `local.properties` e `Generated.xcconfig` **não**
aparecem. Depois rode
`git ls-files | Select-String "local.properties"` e confirme que está vazio.

**Passo 8.** Abra `ios/Podfile` e localize a versão mínima do iOS. Mude para `11.0` e observe o que
o Flutter avisa.

**Passo 9.** Compare `android/app/src/main/AndroidManifest.xml` com
`android/app/src/debug/AndroidManifest.xml`. Qual permissão existe só no debug? Por quê?

**Passo 10.** Responda por escrito: você quer mudar o nome do app de "Foco" para "Foco Estudos".
Quais arquivos você edita, em cada plataforma?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os exercícios de **Localização** (onde fica cada configuração), o de **Correção de bugs** com
arquivo versionado indevidamente, e o de **Compreensão** sobre `minSdk` × `targetSdk`.

---

## 🏆 Desafio opcional

Crie um script `tool/verificar_nativo.dart` que **audita** a configuração das duas plataformas e
falha se algo estiver errado.

Requisitos — o script verifica e reporta:

- `applicationId` e `PRODUCT_BUNDLE_IDENTIFIER` seguem a convenção de domínio invertido;
- toda `<uses-permission>` perigosa do Android tem a `UsageDescription` correspondente no iOS;
- toda `NSxxxUsageDescription` tem mais de 30 caracteres e **não** contém "este app usa";
- `local.properties`, `Generated.xcconfig`, `Pods/` e `*.jks` **não** estão no
  `git ls-files`;
- `Podfile.lock` **está** versionado;
- `android:exported`, `android:name="${applicationName}"` e `adjustResize` estão presentes;
- `minSdk` é compatível com todos os plugins do `pubspec.yaml`.

Saída: uma lista de ✅ e ❌, com o **motivo** de cada falha, e código de saída 1 se houver erro —
para rodar em CI (Módulo 16).

Dica: `Process.runSync('git', ['ls-files'])` lista os arquivos versionados. Para o `Info.plist`, uma
`RegExp` sobre o texto basta; não é preciso um parser de plist.

Depois responda: qual dessas verificações teria evitado mais tempo perdido para você até agora?

---

## 📌 Resumo

- `android/` e `ios/` são **projetos nativos completos**. Tudo que é do sistema operacional mora
  neles.
- **Android:** `app/build.gradle.kts` (identificador, SDKs, assinatura),
  `AndroidManifest.xml` (permissões, atividades), `res/` (ícones, XMLs).
- **iOS:** `Info.plist` (permissões, nome, versão), `AppDelegate.swift`, `Podfile`,
  `Assets.xcassets`.
- **Abra sempre `Runner.xcworkspace`**, nunca `.xcodeproj` — o segundo ignora os Pods.
- **`applicationId` e o bundle identifier nunca mudam** depois de publicados.
- `minSdk` = onde roda; `targetSdk` = com quais regras; `compileSdk` = com qual SDK compila.
- **Toda permissão do iOS exige `UsageDescription`** que explique o motivo. Sem a chave, o app
  **trava**; com texto genérico, a Apple **rejeita**.
- Três atributos que não se removem: `android:name="${applicationName}"`, `android:exported="true"`,
  `windowSoftInputMode="adjustResize"`.
- Android 11+ exige **`<queries>`** para o app enxergar outros apps.
- **Nunca versione:** `local.properties`, `Generated.xcconfig`, `Pods/`, `*.jks`, `key.properties`.
- **Sempre versione:** `Podfile.lock`, manifests, `Info.plist`, `res/`, `Assets.xcassets`.
- Regenerar as pastas nativas **apaga todas as suas edições**. Só depois de `flutter clean`.
- **Não dá para compilar iOS no Windows.** A pasta você entende e configura; compilar exige macOS.

---

## ☑️ Checklist de domínio

- [ ] Sei o que há em `android/` e em `ios/`, arquivo por arquivo.
- [ ] Abro `.xcworkspace`, nunca `.xcodeproj`.
- [ ] Sei onde ficam o identificador, o nome e a versão em cada plataforma.
- [ ] Explico a diferença entre `minSdk`, `targetSdk` e `compileSdk`.
- [ ] Escrevo `UsageDescription` que a Apple aceita.
- [ ] Sei o que acontece ao remover cada um dos três atributos críticos do manifest.
- [ ] Declaro `<queries>` quando o app abre outros apps.
- [ ] Meu `.gitignore` cobre todos os arquivos gerados e as chaves.
- [ ] Versiono o `Podfile.lock`.
- [ ] Sei quando regenerar as pastas nativas — e o que isso custa.
- [ ] Sei ler as mensagens de erro de build e identificar o arquivo culpado.

---

## 📚 Referências oficiais

- [Flutter project structure — docs.flutter.dev](https://docs.flutter.dev/tools/pubspec)
- [Android build configuration — docs.flutter.dev](https://docs.flutter.dev/deployment/android)
- [iOS build configuration — docs.flutter.dev](https://docs.flutter.dev/deployment/ios)
- [Configure the app manifest — developer.android.com](https://developer.android.com/guide/topics/manifest/manifest-intro)
- [Configure the app module — developer.android.com](https://developer.android.com/build/configure-app-module)
- [Package visibility — developer.android.com](https://developer.android.com/training/package-visibility)
- [Information Property List — developer.apple.com](https://developer.apple.com/documentation/bundleresources/information_property_list)
- [CocoaPods — cocoapods.org](https://cocoapods.org/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Ciclo de vida do app](06-ciclo-de-vida-do-app.md) | [README](README.md) | [Aula 8 — Botão voltar e gestos](08-botao-voltar-e-gestos.md) |
