# Aula 2 — Estrutura do projeto

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Criar um projeto com `flutter create`, escolhendo plataformas e usando a flag `-e`.
- Explicar, pasta por pasta e arquivo por arquivo, o que o `flutter create` gera.
- Ler e editar o `pubspec.yaml` com segurança, entendendo `name`, `description`, `version`,
  `environment`, `dependencies`, `dev_dependencies` e a seção `flutter:`.
- Entender o `analysis_options.yaml` e ligar o que está nele ao que o `flutter analyze` reclama.
- Dizer, olhando qualquer arquivo do projeto, se ele **deve** ou **não deve** ir para o Git — e por quê.
- Saber onde cada arquivo do app final (`foco`) vai morar, antes mesmo de escrevê-lo.

## ✅ Pré-requisitos

- [Aula 1 — Como o Flutter funciona](01-como-o-flutter-funciona.md) e o projeto `meu_primeiro_app`
  já criado.
- [Módulo 00 — Aula 02: Arquivos e caminhos](../00-git-e-terminal/02-arquivos-e-caminhos.md).
- [Módulo 00 — Aula 04: Commits, branches e .gitignore](../00-git-e-terminal/04-commits-branches-gitignore.md)
  — você vai usar o conceito de `.gitignore` o tempo todo aqui.
- [Módulo 03 — Aula 10: Arquivos, bibliotecas e pacotes](../03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)
  — `import`, `package:` e a pasta `lib/`.

---

## 📖 Conceito

### `flutter create` — o gerador de andaimes

`flutter create` é um **scaffolder** (*gerador de andaimes* — um comando que cria uma estrutura de
pastas e arquivos inicial pronta para funcionar). Ele não é mágica: o que ele faz é copiar modelos
de arquivo que vêm dentro do SDK e substituir o nome do projeto neles.

A forma mais simples:

```powershell
flutter create meu_primeiro_app
```

Isso gera **todas** as plataformas que a sua máquina suporta: `android/`, `ios/`, `web/`,
`windows/`, `linux/`, `macos/`. Para um curso de mobile, isso é entulho. Use `--platforms`:

```powershell
flutter create --platforms=android,ios meu_primeiro_app
```

> 🪟 **Windows.** Mesmo pedindo só `android,ios`, você continua conseguindo rodar no Chrome? Não.
> `--platforms` define **quais pastas nativas existem**. Para rodar no navegador você precisa da
> pasta `web/`. Como neste módulo o Chrome é o seu aparelho de teste principal, use:
>
> ```powershell
> flutter create --platforms=android,ios,web meu_primeiro_app
> ```
>
> Se você já criou o projeto sem `web`, adicione a plataforma depois — o comando é o mesmo, rodado
> dentro da pasta do projeto:
>
> ```powershell
> flutter create --platforms=web .
> ```

### A flag `-e` — projeto vazio

Por padrão, o `flutter create` gera um app de **contador**: uma tela com um número e um botão `+`.
É um exemplo didático, mas são 120 linhas que você vai apagar em cinco minutos.

A flag `-e` (abreviação de `--empty`) gera o mesmo projeto **sem** o contador:

```powershell
flutter create -e --platforms=android,ios,web foco
```

Com `-e`, o `lib/main.dart` sai assim — 20 linhas em vez de 120:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
```

**Quando usar cada um:**

| Situação | Comando |
|---|---|
| Você está aprendendo e quer ver um app completo funcionando | sem `-e` |
| Você vai apagar tudo e escrever do zero | com `-e` |
| Projeto de verdade, como o `foco` do módulo final | com `-e` |

Neste módulo você vai manter o `meu_primeiro_app` **sem** `-e`, porque na [aula 8](08-hot-reload-e-hot-restart.md)
o contador gerado é justamente o melhor exemplo para entender o que o hot reload preserva.

> 📌 O nome do projeto precisa ser um **identificador Dart válido**: letras minúsculas, números e
> sublinhado (`_`), começando por letra. `meu_primeiro_app` ✅. `MeuApp` ❌. `meu-app` ❌.
> O comando recusa nomes inválidos com a mensagem
> `"xxx" is not a valid Dart package name.`

### A árvore completa, comentada

Esta é a árvore real gerada pelo Flutter 3.47.1. Abra a sua pasta ao lado e vá conferindo.

```text
meu_primeiro_app/
├── lib/                          ← 99 % do seu trabalho acontece aqui
│   └── main.dart                 ← ponto de entrada do app
├── test/                         ← testes automatizados em Dart
│   └── widget_test.dart
├── android/                      ← 🤖 projeto Android nativo (Gradle + Kotlin)
├── ios/                          ← 🍎 projeto iOS nativo (Xcode + Swift)
├── web/                          ← 🌐 casca do app no navegador
├── build/                        ← saída de compilação (NÃO versionar, NÃO editar)
├── .dart_tool/                   ← cache da ferramenta Dart (NÃO versionar)
├── .idea/                        ← configurações do Android Studio (NÃO versionar)
├── .gitignore                    ← o que o Git deve ignorar
├── .metadata                     ← controle interno do Flutter (versionar)
├── analysis_options.yaml         ← regras de lint e análise estática
├── pubspec.yaml                  ← identidade e dependências do projeto (versionar)
├── pubspec.lock                  ← versões exatas resolvidas (versionar)
└── README.md                     ← documentação do projeto
```

#### `lib/` — a pasta do seu código

É a **única** pasta cujo conteúdo o Dart expõe como pacote. Tudo que estiver em `lib/` pode ser
importado por outro arquivo do projeto com `package:`:

```dart
import 'package:meu_primeiro_app/widgets/cartao_materia.dart';
```

Repare que o nome depois de `package:` é exatamente o `name:` do `pubspec.yaml`. Se você renomear o
projeto no pubspec, todos esses imports quebram de uma vez.

Dentro de `lib/`, a organização é **totalmente sua**. O Flutter não exige nenhuma estrutura. O que
este curso adota está em
[08 — Arquitetura feature-first](../08-estado-e-arquitetura/09-arquitetura-feature-first.md).
Neste módulo você vai construir, aos poucos:

```text
lib/
├── main.dart                     ← aula 3: main() e runApp()
├── app.dart                      ← aula 9: o MaterialApp isolado
├── tema/
│   └── tema_app.dart             ← aula 9: ColorScheme.fromSeed
├── telas/
│   └── home_tela.dart            ← aula 5: a tela principal
└── widgets/
    ├── cartao_materia.dart       ← aula 4: primeiro widget reutilizável
    ├── contador_sessoes.dart     ← aula 5: StatefulWidget com setState
    └── cronometro_sessao.dart    ← aula 6: Timer + dispose
```

#### `test/` — testes automatizados

Espelha a estrutura de `lib/`. Um arquivo de teste precisa terminar em `_test.dart` para que o
comando `flutter test` o encontre.

O `flutter create` já deixa um `test/widget_test.dart` que testa o contador gerado. Se você apagar o
contador do `main.dart` sem mexer no teste, `flutter test` vai falhar — e isso confunde muita gente.
Você resolve isso na [aula 3](03-main-runapp-arvore-de-widgets.md).

Testes são o módulo [12 — Testes e debug](../12-testes-e-debug/README.md).

#### `android/` — 🤖 o projeto nativo do Android

```text
android/
├── app/
│   ├── build.gradle.kts              ← configuração do app: applicationId, versões, assinatura
│   └── src/
│       ├── debug/AndroidManifest.xml   ← permissões só do modo debug (INTERNET entra aqui)
│       ├── profile/AndroidManifest.xml ← permissões do modo profile
│       └── main/
│           ├── AndroidManifest.xml     ← nome, ícone, MainActivity, permissões do release
│           ├── kotlin/com/example/meu_primeiro_app/MainActivity.kt
│           └── res/
│               ├── mipmap-hdpi/ ... mipmap-xxxhdpi/   ← ícones do app, por densidade
│               ├── drawable/launch_background.xml     ← splash screen do Android
│               └── values/styles.xml                  ← estilos do lançamento
├── build.gradle.kts                  ← configuração do projeto inteiro
├── settings.gradle.kts               ← quais plugins Gradle usar e suas versões
├── gradle.properties                 ← memória da JVM, AndroidX
├── gradle/wrapper/gradle-wrapper.properties  ← versão do Gradle
├── gradlew / gradlew.bat             ← script que baixa e roda o Gradle certo
└── local.properties                  ← caminho do SDK na SUA máquina (NÃO versionar)
```

> ⚠️ **Aviso que economiza horas.** No Flutter 3.47 esses arquivos são **Kotlin DSL** (`.kts`).
> A maior parte dos tutoriais na internet ainda manda editar `android/app/build.gradle`
> (**sem** `.kts`) e usar sintaxe Groovy (`applicationId "com.exemplo"`). Esse arquivo
> **não existe** no seu projeto. A sintaxe correta agora é Kotlin: `applicationId = "com.exemplo"`,
> com sinal de igual e aspas duplas. Detalhes no módulo
> [14 — Build Android](../14-build-android/README.md).

Valores reais gerados pelo Flutter 3.47.1 nesta máquina:

| Item | Valor |
|---|---|
| Android Gradle Plugin (AGP) | 9.1.0 |
| Kotlin Gradle Plugin | 2.4.0 |
| Gradle (wrapper) | 9.3.1 |
| `compileSdk` / `targetSdk` | 36 |
| `minSdk` | 24 (Android 7.0) |
| `ndkVersion` | 28.2.13676358 |
| Java | 17 |
| `applicationId` padrão | `com.example.meu_primeiro_app` |

E, dentro de `android/app/build.gradle.kts`, este trecho vem assim de fábrica:

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        // Signing with the debug keys for now, so `flutter run --release` works.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

Leia esse comentário com atenção: **enquanto ele estiver ali, o seu build "release" está assinado
com a chave de depuração** e a Google Play vai recusar o envio. Esse `TODO` é um aviso, não
decoração. Você o substitui no módulo
[14 — Assinatura no Gradle](../14-build-android/07-assinatura-no-gradle.md).

#### `ios/` — 🍎 o projeto nativo do iPhone

```text
ios/
├── Runner.xcworkspace                          ← SEMPRE abra este no Xcode, nunca o .xcodeproj
├── Runner.xcodeproj/project.pbxproj            ← configuração do projeto Xcode
├── Runner/
│   ├── Info.plist                              ← nome, versão, permissões, orientação
│   ├── AppDelegate.swift                       ← entrada do app iOS
│   ├── SceneDelegate.swift                     ← gerenciamento de janela (novo no 3.47)
│   ├── Base.lproj/LaunchScreen.storyboard      ← splash screen do iOS
│   ├── Base.lproj/Main.storyboard
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset                  ← ícone do app
│       └── LaunchImage.imageset
├── RunnerTests/                                ← testes nativos (raramente usados)
└── Flutter/
    ├── Debug.xcconfig                          ← você pode editar
    ├── Release.xcconfig                        ← você pode editar
    └── Generated.xcconfig                      ← GERADO pelo Flutter, não edite
```

Duas novidades do Flutter 3.47 que os tutoriais antigos não mencionam:

1. **`SceneDelegate.swift` existe agora.** O `Info.plist` gerado traz um bloco
   `UIApplicationSceneManifest` apontando para ele. Não apague nem "limpe" isso: é o modelo de
   janelas atual do iOS.
2. **Swift Package Manager é o padrão** desde o Flutter 3.44. O `flutter create` já gera
   `ios/Flutter/ephemeral/Packages`. O CocoaPods continua existindo e o Flutter volta para ele
   automaticamente se algum plugin do projeto ainda não suportar SPM. Os dois convivem.

> 🍎 **SÓ NO MAC.** Abrir `Runner.xcworkspace`, rodar no simulador e gerar `.ipa` exige macOS +
> Xcode. 🪟 No Windows a pasta `ios/` **é criada e versionada normalmente** — você pode editar o
> `Info.plist` em um editor de texto, revisar o `Podfile` e entender tudo. O que você não consegue é
> **compilar**. O caminho completo, incluindo alternativas de nuvem, está em
> [15-build-ios/01-por-que-exige-macos.md](../15-build-ios/01-por-que-exige-macos.md).

#### `web/` — 🌐 a casca do navegador

```text
web/
├── index.html         ← página que carrega o app; você pode editar título e cor de fundo
├── manifest.json      ← nome e ícones do app quando instalado como PWA
├── favicon.png
└── icons/
    ├── Icon-192.png   Icon-512.png
    └── Icon-maskable-192.png   Icon-maskable-512.png
```

É a plataforma que você mais vai usar **neste módulo**, porque roda sem emulador e sem Mac.

#### `pubspec.yaml` — a identidade do projeto

*Pubspec* = "pub" (o gerenciador de pacotes do Dart) + "spec" (especificação). É o arquivo mais
importante do projeto depois do `main.dart`. YAML é sensível a **indentação por espaços** — nunca
use Tab aqui.

```yaml
name: meu_primeiro_app
description: "Contador de sessões de estudo — projeto do módulo 05."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

Campo por campo:

| Campo | Significado |
|---|---|
| `name` | Nome do pacote. Vira o prefixo dos seus imports (`package:meu_primeiro_app/...`). Minúsculas e `_`. |
| `description` | Texto livre. Aparece no pub.dev se você publicar. |
| `publish_to: 'none'` | Trava de segurança: impede publicação acidental no pub.dev. Todo app tem isso. |
| `version: 1.0.0+1` | **Antes do `+`** é a versão visível (1.0.0); **depois do `+`** é o número do build (1). 🤖 Viram `versionName` e `versionCode`. 🍎 Viram `CFBundleShortVersionString` e `CFBundleVersion`. Um único campo alimenta as duas lojas. |
| `environment: sdk: ^3.13.0` | Faixa de versões do Dart aceita. `^3.13.0` significa "≥ 3.13.0 e < 4.0.0". |
| `dependencies` | Pacotes que o **app** precisa para rodar. Vão dentro do APK/IPA. |
| `dev_dependencies` | Pacotes que só o **desenvolvedor** precisa: testes, lints, geradores. **Não** vão para o app final. |
| `flutter: uses-material-design: true` | Inclui a fonte de ícones do Material (`Icons.home`, `Icons.timer`, ...). |

Para adicionar um pacote, **não edite o arquivo à mão** — use o comando, que já resolve a versão:

```powershell
flutter pub add http
flutter pub add dev:mocktail
```

O prefixo `dev:` manda o pacote para `dev_dependencies`.

#### `pubspec.lock` — a fotografia das versões

O `pubspec.yaml` diz `^1.6.0` ("qualquer 1.x a partir de 1.6.0"). O `pubspec.lock` diz
`1.6.2` — a versão **exata** que foi baixada. Ele garante que você e um colega compilem com
exatamente os mesmos bytes.

**Para um app: versione o `pubspec.lock`.** (Para uma biblioteca publicada no pub.dev, não.)

#### `analysis_options.yaml` — as regras do jogo

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # avoid_print: false
    # prefer_single_quotes: true
```

A linha `include:` importa o conjunto oficial de regras do pacote `flutter_lints ^6.0.0`. É ele
quem faz o `flutter analyze` e o VS Code reclamarem de coisas como:

- `avoid_print` — use `debugPrint()` em vez de `print()` em código Flutter.
- `prefer_const_constructors` — coloque `const` onde der.
- `use_build_context_synchronously` — não use `context` depois de um `await` sem checar `mounted`.
- `unnecessary_underscores` — escreva `(_, _)` e não `(_, __)`.

Rode a qualquer momento:

```powershell
flutter analyze
```

Você já viu esse arquivo em
[04 — Análise estática e lints](../04-dart-avancado/07-analise-estatica-e-lints.md); a diferença é
que agora as regras valem para widgets também.

#### `.metadata` — o histórico do gerador

```yaml
version:
  revision: "6655482ec0"
  channel: "stable"

project_type: app

migration:
  platforms:
    - platform: root
      create_revision: 6655482ec0
      base_revision: 6655482ec0
```

Guarda com qual versão do Flutter o projeto foi criado. O comando `flutter create .` usa isso para
saber o que precisa ser atualizado quando você migra de versão. **Versione**, mas nunca edite à mão.

#### `.gitignore` — o que fica de fora

O arquivo gerado inclui, entre outros:

```text
# Miscellaneous
*.log
.DS_Store

# IntelliJ related
*.iml
.idea/

# Flutter/Dart/Pub related
/build/
.dart_tool/
.flutter-plugins-dependencies
**/doc/api/

# Symbolication / obfuscation
app.*.symbols
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release
```

### O que versionar e o que não versionar

| Caminho | Versionar? | Por quê |
|---|---|---|
| `lib/`, `test/` | ✅ Sim | É o seu código. |
| `pubspec.yaml` | ✅ Sim | Define o projeto. |
| `pubspec.lock` | ✅ Sim (é app) | Garante builds idênticos. |
| `analysis_options.yaml` | ✅ Sim | As regras precisam valer para todos. |
| `.metadata` | ✅ Sim | Controle de migração do Flutter. |
| `android/` e `ios/` (fontes) | ✅ Sim | Manifest, ícones, configuração de build. |
| `web/` | ✅ Sim | `index.html` e ícones costumam ser editados. |
| `.gitignore` | ✅ Sim | Obviamente. |
| `build/` | ❌ Não | Gerado a cada compilação, pesa centenas de MB. |
| `.dart_tool/` | ❌ Não | Cache local da ferramenta. |
| `.idea/`, `*.iml` | ❌ Não | Configuração da IDE de uma pessoa só. |
| `android/local.properties` | ❌ Não | Contém o caminho do SDK **na sua máquina**. |
| `ios/Flutter/Generated.xcconfig` | ❌ Não | Regerado pelo Flutter. |
| `ios/Pods/` | ❌ Não | Dependências baixadas. |
| `android/key.properties` | ❌ **NUNCA** | Contém **senhas** da sua chave de assinatura. |
| `*.jks`, `*.keystore` | ❌ **NUNCA** | É a sua chave privada. Vazou, acabou. |
| `*.p12`, `*.cer`, `*.mobileprovision` | ❌ **NUNCA** | Certificados 🍎 iOS. |
| `.env` | ❌ **NUNCA** | Segredos de ambiente. |

> 🔐 Os cinco últimos **não** estão no `.gitignore` gerado pelo `flutter create`. Você precisa
> adicioná-los à mão antes do primeiro commit do projeto de verdade. Isso é feito no módulo
> [14 — Keystore](../14-build-android/06-keystore.md), e o raciocínio por trás está em
> [00 — Desfazendo erros e segredos](../00-git-e-terminal/05-desfazendo-erros-e-segredos.md).

---

## 💡 Analogia

Pense em uma casa pré-fabricada entregue pela construtora.

- `lib/` é a **área habitável**: é onde você põe os móveis, e é só aí que você mexe todo dia.
- `android/` e `ios/` são a **fundação e a instalação elétrica** de cada terreno. Existem, são
  indispensáveis, mas você só desce lá em ocasiões específicas (trocar o nome na fachada, adicionar
  uma tomada nova = uma permissão).
- `pubspec.yaml` é a **planta aprovada**: nome da casa, número, lista de materiais.
- `pubspec.lock` é a **nota fiscal**: os lotes exatos de cada material comprado, para que a reforma
  use o mesmo cimento.
- `build/` é o **entulho da obra**: aparece sozinho, você joga fora sem dó (`flutter clean`) e
  jamais leva para o arquivo da prefeitura (o Git).

---

## 🧪 Exemplo mínimo

Crie um projeto vazio, inspecione a árvore e apague-o em seguida. O objetivo é ver a diferença
entre `-e` e o padrão.

```powershell
Set-Location C:\src\projetos
flutter create -e --platforms=android,ios,web experimento_vazio
Get-ChildItem experimento_vazio
Get-Content experimento_vazio\lib\main.dart
```

Compare o tamanho do `lib/main.dart` com o do `meu_primeiro_app`:

```powershell
(Get-Content experimento_vazio\lib\main.dart   | Measure-Object -Line).Lines
(Get-Content meu_primeiro_app\lib\main.dart    | Measure-Object -Line).Lines
```

Depois apague o experimento:

```powershell
Remove-Item -Recurse -Force experimento_vazio
```

---

## 📱 Aplicando no Flutter

Agora ajuste o `meu_primeiro_app` para ser o projeto oficial do módulo. Duas mudanças no
`pubspec.yaml`: uma descrição de verdade e as pastas onde você vai organizar o código.

Crie a estrutura de pastas de uma vez:

```powershell
Set-Location C:\src\projetos\meu_primeiro_app
New-Item -ItemType Directory -Force lib\telas, lib\widgets, lib\tema
```

As pastas ficam vazias por enquanto — o Git não versiona pasta vazia, e isso é normal. Elas se
enchem a partir da [aula 4](04-statelesswidget.md).

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/pubspec.yaml`
> **Como executar:** `flutter pub get` seguido de `flutter analyze`

```yaml
name: meu_primeiro_app
description: "Contador de sessões de estudo — projeto do módulo 05 do curso intensivo."
publish_to: 'none'

# 1.0.0 = versão visível para o usuário (versionName 🤖 / CFBundleShortVersionString 🍎)
# +1     = número do build (versionCode 🤖 / CFBundleVersion 🍎)
version: 1.0.0+1

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  # Fonte de ícones no estilo iOS. Vem por padrão e é usada na aula 9.
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  # Conjunto oficial de regras de lint. É o que o analysis_options.yaml importa.
  flutter_lints: ^6.0.0

flutter:
  # Habilita a fonte de ícones do Material (Icons.timer, Icons.school, ...).
  uses-material-design: true
```

> **Arquivo:** `meu_primeiro_app/analysis_options.yaml`
> **Como executar:** `flutter analyze`

```yaml
# Importa o conjunto oficial de lints do Flutter (pacote flutter_lints ^6.0.0).
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Regras ligadas explicitamente para reforçar os padrões deste curso.
    # Cada uma delas evita um erro real que aparece nos módulos seguintes.

    # Exige const em construtores que podem ser const (ganho de desempenho).
    prefer_const_constructors: true

    # Exige const em listas/mapas literais imutáveis.
    prefer_const_literals_to_create_immutables: true

    # Proíbe usar BuildContext depois de um await sem checar mounted.
    use_build_context_synchronously: true

    # Proíbe print(); em Flutter o correto é debugPrint().
    avoid_print: true

    # Todo widget público deve declarar o parâmetro key.
    use_key_in_widget_constructors: true
```

Aplique e confirme:

```powershell
flutter pub get
flutter analyze
```

Saída esperada:

```text
Resolving dependencies...
Got dependencies!

Analyzing meu_primeiro_app...
No issues found! (ran in 3.2s)
```

Se aparecerem avisos, eles vêm do `lib/main.dart` da aula 1 ou do `test/widget_test.dart` gerado.
Guarde-os: a [aula 3](03-main-runapp-arvore-de-widgets.md) resolve os dois.

---

## 🔍 Explicando o código

| Linha | Por que ela está aí |
|---|---|
| `publish_to: 'none'` | Se você rodar `dart pub publish` por engano, o comando recusa. Sem essa linha, um app privado poderia ir para o pub.dev público. |
| `version: 1.0.0+1` | Um único lugar controla a versão nas duas lojas. Ao enviar uma atualização, **o número depois do `+` precisa aumentar** — as lojas recusam builds com o mesmo número. |
| `environment: sdk: ^3.13.0` | Trava a faixa do Dart. Se um colega tiver Dart 3.12, o `flutter pub get` avisa antes de o build quebrar de forma confusa. |
| `cupertino_icons: ^1.0.8` | Ícones no estilo iOS (`CupertinoIcons.back`). Você usa na [aula 9](09-material-e-cupertino.md). |
| `flutter_lints: ^6.0.0` em `dev_dependencies` | Está em `dev_` porque lint é ferramenta de desenvolvimento: não vai dentro do APK. |
| `uses-material-design: true` | Sem isso, `Icon(Icons.timer)` aparece como um quadrado vazio. |
| `prefer_const_constructors: true` | Transforma "você poderia usar const" em aviso visível. É a forma mais barata de melhorar desempenho — veja [aula 4](04-statelesswidget.md). |
| `use_build_context_synchronously: true` | Pega o bug mais comum de Flutter assíncrono: usar `context` depois de um `await` quando o widget já saiu da tela. [Aula 7](07-buildcontext.md). |
| `avoid_print: true` | `print()` em Flutter pode perder linhas em logs grandes e não é filtrado no release. Use `debugPrint()`. |
| `use_key_in_widget_constructors: true` | Garante que todo widget seu tenha `{super.key}`. |

---

## 🤖🍎 Android × iOS

| Assunto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Arquivo de configuração de build | `android/app/build.gradle.kts` (Kotlin DSL) | `ios/Runner.xcodeproj/project.pbxproj` (editado pelo Xcode) |
| Identificador do app | `applicationId = "br.com.estudos.foco"` | Bundle Identifier, definido no Xcode |
| Nome exibido | `android:label` no `AndroidManifest.xml` | `CFBundleDisplayName` no `Info.plist` |
| Ícone | `android/app/src/main/res/mipmap-*/ic_launcher.png` | `ios/Runner/Assets.xcassets/AppIcon.appiconset` |
| Splash screen | `res/drawable/launch_background.xml` | `Base.lproj/LaunchScreen.storyboard` |
| Permissões | `<uses-permission>` no `AndroidManifest.xml` | chaves de **texto** no `Info.plist`, ex.: `NSCameraUsageDescription` |
| Gerenciador de dependências nativas | Gradle | Swift Package Manager (padrão) com CocoaPods como alternativa |
| Você consegue compilar no 🪟 Windows? | ✅ Sim (com Android Studio instalado) | ❌ Não |

Uma diferença que surpreende: 🍎 no iOS, o texto da permissão é **lido pelo usuário** na hora do
pedido. A Apple **rejeita** apps cujo texto seja genérico. Escreva algo específico, em português:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da câmera para você anexar uma foto ao seu material de estudo.</string>
```

🤖 No Android, a permissão é só um nome técnico; o texto mostrado é o padrão do sistema.

---

## ⚠️ Erros comuns

**1. Editar `android/app/build.gradle` (sem `.kts`).**
```text
O sistema não pode encontrar o arquivo especificado.
```
Esse arquivo não existe mais. O correto é `android/app/build.gradle.kts`, com sintaxe Kotlin.

**2. Usar Tab no `pubspec.yaml`.**
```text
Error on line 8, column 3: Mapping values are not allowed here.
```
YAML só aceita **espaços**. No VS Code, `Ctrl` + `Shift` + `P` → "Convert Indentation to Spaces".

**3. Versionar a pasta `build/`.**
O repositório passa de alguns KB para centenas de MB e todo `git status` fica poluído. Se acontecer:
```powershell
git rm -r --cached build
```
e confirme que `/build/` está no `.gitignore`.

**4. Esquecer de rodar `flutter pub get` depois de editar o `pubspec.yaml`.**
```text
Target of URI doesn't exist: 'package:http/http.dart'
```
O VS Code costuma rodar sozinho ao salvar, mas nem sempre. Rode à mão.

**5. Nome de projeto inválido.**
```text
"MeuApp" is not a valid Dart package name.
```
Use `meu_app`.

**6. Projeto criado dentro de pasta com acento.**
```text
FileSystemException: Cannot resolve symbolic links,
path = 'C:\Users\Usu rio\Documents\flutter\bin\flutter'
```
Esse erro foi reproduzido nesta máquina. Mova tudo para `C:\src\` e rode `flutter clean`.
Registrado em [referencias/erros-comuns.md](../../referencias/erros-comuns.md).

**7. Apagar `ios/` "porque não tenho Mac".**
Não apague. A pasta é versionada e, no dia em que um colega com Mac clonar o projeto, ela precisa
estar lá. Regerar depois com `flutter create --platforms=ios .` perde qualquer ajuste manual.

---

## 🛠️ Exercício guiado

**Objetivo:** transformar `meu_primeiro_app` em um repositório Git limpo e conferir, na prática, o
que entra e o que fica de fora.

**Passo 1.** Dentro de `C:\src\projetos\meu_primeiro_app`, inicialize o repositório:

```powershell
git init
git add .
git status --short
```

**Passo 2.** Confirme que **nenhuma** das linhas listadas começa com `build/` ou `.dart_tool/`.
Se começar, o `.gitignore` não está sendo lido — confirme que ele está na raiz do projeto.

**Passo 3.** Adicione as linhas de segurança que o `flutter create` não coloca:

```powershell
Add-Content -Path .gitignore -Encoding utf8 -Value @"

# Segredos — NUNCA versionar
android/key.properties
*.jks
*.keystore
*.p12
*.cer
ios/Runner/*.mobileprovision
.env
"@
```

**Passo 4.** Faça o primeiro commit:

```powershell
git add .
git commit -m "Projeto do modulo 05 criado com flutter create"
```

**Passo 5.** Conte quantos arquivos foram versionados:

```powershell
(git ls-files | Measure-Object -Line).Lines
```

**Resultado esperado:** algumas dezenas de arquivos (a ordem de grandeza é dezenas, não milhares).
Se der milhares, a pasta `build/` entrou — volte ao passo 2.

**Passo 6.** Responda por escrito, em `anotacoes.md`:
1. Por que `pubspec.lock` foi versionado e `.dart_tool/` não?
2. O que aconteceria se você versionasse `android/local.properties` e um colega em outro computador
   clonasse o projeto?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Priorize os de **Fixação** (identificar a função de cada pasta) e o de **Leitura de código** sobre
`pubspec.yaml`.

---

## 🏆 Desafio opcional

Crie o projeto do app final do curso, só para conhecer o terreno:

```powershell
Set-Location C:\src\projetos
flutter create -e --platforms=android,ios,web --org br.com.estudos foco
```

A flag `--org` define o prefixo do identificador. Abra `foco/android/app/build.gradle.kts` e
confirme que o `applicationId` ficou `br.com.estudos.foco` — exatamente o identificador oficial do
projeto final, definido em [05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md).

Depois, monte à mão a estrutura de pastas planejada e confirme que o `flutter analyze` continua
limpo:

```powershell
Set-Location foco
New-Item -ItemType Directory -Force `
  lib\core\constants, lib\core\erros, lib\core\rotas, lib\core\tema, lib\core\widgets, `
  lib\features\materias, lib\features\sessoes, lib\features\metas, `
  lib\features\trilhas, lib\features\estatisticas
flutter analyze
```

Guarde esse projeto: ele é retomado em
[projetos/03-projeto-final-multiplataforma/03-etapa-1-fundacao.md](../../projetos/03-projeto-final-multiplataforma/03-etapa-1-fundacao.md).

---

## 📌 Resumo

- `flutter create` gera andaimes. `--platforms=android,ios,web` controla quais pastas nativas
  existem; `-e` (`--empty`) gera o projeto **sem** o app de contador; `--org` define o prefixo do
  identificador.
- O nome do projeto precisa ser um identificador Dart válido: minúsculas, números e `_`.
- `lib/` é onde 99 % do seu trabalho acontece e é a única pasta exposta como `package:`.
- `android/` usa **Kotlin DSL** (`build.gradle.kts`) no Flutter 3.47 — tutoriais com `build.gradle`
  em Groovy estão desatualizados. O `TODO` do `signingConfig` significa que o release ainda está
  assinado com a chave de debug.
- `ios/` tem `SceneDelegate.swift` e usa **Swift Package Manager** por padrão, com CocoaPods como
  alternativa automática. 🪟 No Windows você lê e edita, mas não compila.
- `pubspec.yaml` é a identidade: `name` vira o prefixo dos imports e `version: 1.0.0+1` alimenta as
  duas lojas.
- Versione `lib/`, `test/`, `pubspec.yaml`, `pubspec.lock`, `.metadata`, `android/`, `ios/`, `web/`.
  **Não** versione `build/`, `.dart_tool/`, `.idea/`, `local.properties`.
  **Nunca** versione `key.properties`, `*.jks`, `*.p12`, `.env`.
- `analysis_options.yaml` + `flutter_lints ^6.0.0` transformam boas práticas em avisos visíveis.

---

## ☑️ Checklist de domínio

- [ ] Crio um projeto escolhendo plataformas e sei o que a flag `-e` muda.
- [ ] Explico por que o nome do projeto não pode ter maiúsculas nem hífen.
- [ ] Digo o que cada pasta da raiz faz, sem olhar a aula.
- [ ] Sei que o arquivo de build do Android é `build.gradle.kts` e que a sintaxe é Kotlin.
- [ ] Reconheço o `TODO` do `signingConfig` e explico o risco dele.
- [ ] Sei que `ios/Runner.xcworkspace` é o arquivo a abrir no Xcode, nunca o `.xcodeproj`.
- [ ] Explico cada campo do `pubspec.yaml`, incluindo o significado do `+1` na versão.
- [ ] Sei a diferença entre `dependencies` e `dev_dependencies` e dou um exemplo de cada.
- [ ] Adiciono um pacote com `flutter pub add` em vez de editar o YAML à mão.
- [ ] Classifico corretamente 10 caminhos do projeto entre "versionar" e "não versionar".
- [ ] Listo os arquivos de segredo que **nunca** podem ir para o Git.
- [ ] `flutter analyze` termina com `No issues found!` no meu projeto.

---

## 📚 Referências oficiais

- [flutter create — Flutter CLI reference](https://docs.flutter.dev/reference/flutter-cli)
- [The pubspec file — dart.dev](https://dart.dev/tools/pub/pubspec)
- [Package dependencies — dart.dev](https://dart.dev/tools/pub/dependencies)
- [Customizing static analysis — dart.dev](https://dart.dev/tools/analysis)
- [Adding assets and images](https://docs.flutter.dev/ui/assets/assets-and-images)
- [Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Swift Package Manager for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Como o Flutter funciona](01-como-o-flutter-funciona.md) | [README](README.md) | [Aula 3 — main, runApp e a árvore de widgets](03-main-runapp-arvore-de-widgets.md) |
