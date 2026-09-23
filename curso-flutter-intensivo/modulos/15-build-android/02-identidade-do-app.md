# Aula 2 — Identidade do app

> **Módulo:** 15 - Build e Distribuição Android · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Explicar o que é `applicationId` e o que é `namespace`, e dizer a **diferença real** entre os dois.
- Escrever um identificador no formato **domínio invertido** e justificar por que esse formato foi
  escolhido.
- Explicar por que o `applicationId` **não pode mudar** depois que o app é publicado.
- Alterar o `applicationId` e o `namespace` em `android/app/build.gradle.kts` (Kotlin DSL) e
  **renomear a pasta do `MainActivity.kt`** sem quebrar o build.
- Alterar o **nome exibido** do app em `android:label`.
- Explicar como `version: 1.0.0+1` do `pubspec.yaml` vira `versionName` e `versionCode` no Android —
  e `CFBundleShortVersionString` / `CFBundleVersion` no iOS.
- Usar `--build-name` e `--build-number` para sobrescrever a versão em um build específico.

## ✅ Pré-requisitos

- [Aula 1 — Debug, profile e release](01-debug-profile-release.md) concluída.
- Projeto Flutter que compila em debug.
- Noção de pacotes e pastas do Dart, vista em
  [Módulo 03, aula 10](../03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md).

---

## 📖 Conceito

### Um app tem três nomes diferentes — e eles não se misturam

Esta é a fonte número um de confusão. O seu app **Foco** tem, no Android:

| Nome | Onde vive | Quem vê | Pode mudar depois? |
|---|---|---|---|
| **Nome exibido** (`android:label`) | `AndroidManifest.xml` | o usuário, embaixo do ícone | **sim**, sempre |
| **`applicationId`** | `android/app/build.gradle.kts` | ninguém (é técnico) | **NÃO**, depois de publicar |
| **`namespace`** | `android/app/build.gradle.kts` | ninguém (é do compilador) | sim, com cuidado |

O nome do projeto Flutter (`foco`, a pasta e o `name:` do `pubspec.yaml`) é um **quarto** nome, que
só vale dentro do Dart. Nenhum deles precisa ser igual aos outros.

### `applicationId` — a identidade definitiva do app

**`applicationId`** é o identificador único do seu aplicativo **no mundo inteiro**. É por ele que:

- o Android decide se um APK que você está instalando é uma **atualização** de um app existente ou
  um **app novo**;
- a Google Play identifica a ficha da loja;
- o sistema separa a "caixa" de dados do seu app da dos outros (cada app tem uma pasta privada
  nomeada pelo `applicationId`);
- URLs da loja são formadas: `https://play.google.com/store/apps/details?id=br.com.estudos.foco`.

Dois apps com o mesmo `applicationId` **não podem** coexistir no mesmo aparelho. O segundo tenta
substituir o primeiro.

### `namespace` — o pacote do código compilado

**`namespace`** é o pacote Java/Kotlin usado para gerar a classe `R` — a classe que o Android gera
automaticamente contendo os identificadores de todos os recursos do app (`R.mipmap.ic_launcher`,
`R.string.app_name`, `R.drawable.launch_background`). Ele também é o pacote base do `BuildConfig`.

Em outras palavras: `namespace` é assunto **do compilador**; `applicationId` é assunto **do sistema
operacional e da loja**.

### A diferença real, em uma frase

> **`namespace` é como o código é organizado dentro do arquivo. `applicationId` é como o mundo
> chama o seu app.**

Historicamente eles eram a mesma coisa: o `package` declarado no `AndroidManifest.xml` servia para
os dois. Depois o Android separou os conceitos, porque existe um caso real em que eles **precisam**
ser diferentes: quando você publica **variantes** do mesmo código-base.

Exemplo concreto — a versão gratuita e a paga do Foco:

```text
namespace      = br.com.estudos.foco       (o código é o mesmo, a classe R é a mesma)
applicationId  = br.com.estudos.foco       (versão gratuita)
applicationId  = br.com.estudos.foco.pro   (versão paga, instalável lado a lado)
```

O mesmo código compila duas vezes, gerando dois apps que o Android trata como completamente
distintos — e que o usuário pode instalar ao mesmo tempo. Se os dois valores fossem um só, isso
seria impossível.

No **Foco** do curso os dois vão ser iguais (`br.com.estudos.foco`). Mas você precisa saber que são
campos diferentes, porque quando algo der errado a mensagem de erro vai citar um dos dois, e você
precisa saber em qual mexer.

### Formato: domínio invertido

O formato universal de identificadores de app (Android **e** iOS) é o **domínio invertido**
(*reverse domain name notation*): você pega um domínio de internet e escreve ao contrário.

```text
estudos.com.br        ->   br.com.estudos
estudos.com.br/foco   ->   br.com.estudos.foco
```

Por que ao contrário? Porque assim os identificadores ficam **ordenados do mais geral para o mais
específico**, e a unicidade fica garantida por quem já é dono do domínio. Ninguém que não controle
`estudos.com.br` vai reivindicar `br.com.estudos.*`.

**Regras do formato** (o Gradle recusa o build se você violar):

- Pelo menos **dois** segmentos separados por ponto (`br.com.estudos.foco` tem quatro).
- Cada segmento começa com **letra**.
- Só letras, números e `_`. **Sem hífen, sem acento, sem espaço, sem maiúscula** (maiúscula é
  tecnicamente aceita, mas todo mundo usa minúsculas — siga a convenção).
- Nenhum segmento pode ser uma palavra reservada do Java (`class`, `int`, `new`, `package`...).

**Nunca publique com `com.example.`** — esse é o prefixo de exemplo que o `flutter create` coloca, e
a Google Play **recusa** o upload de qualquer app cujo `applicationId` comece com `com.example.`.

Se você não tem domínio próprio, use algo que seja verificavelmente seu, por exemplo o seu usuário
do GitHub: `io.github.<seu-usuario>.foco`.

### 🔴 Por que o `applicationId` NÃO PODE mudar depois de publicar

Porque o `applicationId` **é** a chave primária do app na Play e no aparelho. Se você mudar:

1. A Google Play trata a nova versão como **um app totalmente novo**. Você não consegue publicar uma
   atualização: teria que criar uma ficha nova, do zero.
2. Você **perde tudo** que estava ligado à ficha antiga: avaliações, número de instalações, posição
   nas buscas, histórico de estatísticas, compras dentro do app.
3. Nos aparelhos dos usuários, o app antigo **continua instalado** e nunca mais recebe atualização.
   Se a pessoa instalar o novo, fica com dois ícones iguais e dois bancos de dados separados.
4. Links profundos, notificações e integrações que usavam o identificador antigo param de funcionar.

Não existe um botão de "renomear" na Play. Não existe suporte que resolva. É definitivo.

> 🔴 **Consequência prática:** decida o `applicationId` **antes** do primeiro upload. É por isso que
> esta é a Aula 2 do módulo, e não a Aula 9. Todas as etapas seguintes (ícone, splash, assinatura)
> assumem que a identidade já está fechada.

### Versão: um campo do Dart que vira quatro campos nativos

No `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

Esse campo tem duas partes separadas por `+`:

| Parte | Nome | Exemplo | Para quem serve |
|---|---|---|---|
| Antes do `+` | **build name** (nome da versão) | `1.0.0` | **humanos** — é o que aparece na loja |
| Depois do `+` | **build number** (número do build) | `1` | **máquinas** — é o que a loja compara |

O Flutter traduz isso para cada plataforma automaticamente:

| `pubspec.yaml` | 🤖 Android | 🍎 iOS |
|---|---|---|
| `1.0.0` (build name) | `versionName` | `CFBundleShortVersionString` |
| `1` (build number) | `versionCode` | `CFBundleVersion` |

> Essa ligação está confirmada nos arquivos que o `flutter create` do Flutter 3.47 gera: o
> `ios/Runner/Info.plist` traz `CFBundleShortVersionString = $(FLUTTER_BUILD_NAME)` e
> `CFBundleVersion = $(FLUTTER_BUILD_NUMBER)`, e o `android/app/build.gradle.kts` traz
> `versionName = flutter.versionName` e `versionCode = flutter.versionCode`. Ou seja: **um campo só,
> no `pubspec.yaml`, controla a versão nas duas plataformas.** O Módulo 16 volta a esse ponto pelo
> lado do iOS, em
> [05 — Ícone, splash, versão e Info.plist](../16-build-ios/05-icone-splash-versao-infoplist.md).

**A regra de ouro do `versionCode`:** ele precisa ser um número inteiro **estritamente maior** que o
da versão anterior publicada. A Google Play recusa um upload cujo `versionCode` seja igual ou menor
que o de algo já enviado, com a mensagem:

```text
You need to use a different version code for your APK or Android App Bundle because you already
have one with version code 1.
```

O `versionName` (`1.0.0`), ao contrário, é texto livre. A Play não compara — só exibe.

**Versionamento semântico** (*semantic versioning*) é a convenção mais usada para o build name:
`MAIOR.MENOR.CORREÇÃO`. Sobe `CORREÇÃO` em conserto de bug, `MENOR` em funcionalidade nova,
`MAIOR` em mudança que quebra compatibilidade. O módulo 17 detalha isso em
[03 — Versionamento e releases](../17-publicacao-e-proximos-passos/03-versionamento-e-releases.md).

---

## 💡 Analogia

Pense em uma pessoa com documentos.

- O **`applicationId`** é o **CPF**: identifica de forma única, ninguém mais tem, e você não troca.
  Se trocasse, todo o histórico de crédito, emprego e escola ficaria órfão — exatamente o que
  acontece com as avaliações da Play.
- O **nome exibido** (`android:label`) é o **apelido**: dá para mudar quando quiser, e mudar não
  desliga você de nada.
- O **`namespace`** é o **número de matrícula interno da empresa**: só o RH usa, ninguém de fora
  precisa saber, e trocar dá trabalho mas não é catastrófico.
- O **`versionCode`** é o **número sequencial do protocolo**: tem que ser sempre maior que o
  anterior, senão o cartório recusa.

---

## 🧪 Exemplo mínimo

O jeito mais rápido de acertar a identidade é **nascer com ela certa**. Ao criar um projeto do zero:

```powershell
flutter create --org br.com.estudos --platforms=android,ios foco
```

A flag `--org` define o prefixo da organização. O `flutter create` concatena com o nome do projeto e
usa `br.com.estudos.foco` como `applicationId`, como `namespace`, como Bundle ID do iOS **e** como
nome da pasta do `MainActivity.kt`. Zero trabalho manual.

Sem `--org`, o padrão é `com.example.<nome_do_projeto>` — e aí você cai no procedimento manual desta
aula.

> Se o seu projeto **Foco** ainda não existe e você está começando agora, use o comando acima e pule
> direto para a seção "Nome exibido". Se ele já existe com `com.example.foco`, siga o procedimento
> completo.

---

## 📱 Aplicando no Flutter

### Passo 1 — Ver o que você tem hoje

Abra `android/app/build.gradle.kts`. Este é o arquivo real que o Flutter 3.47 gera — **Kotlin DSL**,
com extensão `.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // O plugin Gradle do Flutter precisa vir DEPOIS dos plugins do Android e do Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.foco"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID.
        applicationId = "com.example.foco"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
```

> ⚠️ **Muito tutorial na internet manda editar `android/app/build.gradle`, sem o `.kts`.** Isso está
> **desatualizado**. Desde o Flutter 3.29 o `flutter create` gera **Kotlin DSL** (`.kts`), e no
> Flutter 3.47 é o padrão consolidado. Se você abrir um tutorial e ele usar `def` e `apply plugin:`,
> é Groovy — a sintaxe antiga. Traduza para Kotlin DSL ou procure material atualizado.

Os valores desta máquina, medidos no projeto gerado pelo Flutter 3.47.1:

| Item | Valor |
|---|---|
| Android Gradle Plugin (AGP) | 9.1.0 |
| Kotlin Gradle Plugin | 2.4.0 |
| Gradle (wrapper) | 9.3.1 |
| `compileSdk` | 36 |
| `minSdk` | 24 (Android 7.0) |
| `targetSdk` | 36 |
| `ndkVersion` | 28.2.13676358 |
| Java | 17 |

Os valores `flutter.compileSdkVersion`, `flutter.minSdkVersion` etc. não são mágica: são
propriedades que o plugin Gradle do Flutter injeta, lendo a configuração do SDK do Flutter. Isso
mantém o projeto sincronizado com a versão do SDK sem você precisar atualizar números na mão.

> Guarde o bloco `buildTypes { release { ... } }` com o `TODO` na memória. Ele é o assunto inteiro da
> [Aula 7](07-assinatura-no-gradle.md): enquanto ele estiver assim, o seu "release" está assinado com
> a **chave de depuração** e não pode ser publicado.

### Passo 2 — Trocar `applicationId` e `namespace`

Edite as duas linhas:

```kotlin
android {
    namespace = "br.com.estudos.foco"

    defaultConfig {
        applicationId = "br.com.estudos.foco"
        // ... o resto continua igual
    }
}
```

Apague também o comentário `// TODO: Specify your own unique Application ID.` — ele existia só para
lembrar você de fazer exatamente isso.

### Passo 3 — Renomear a pasta do `MainActivity.kt`

Este é o passo que a maioria esquece, e sem ele o build falha.

O `flutter create` gerou:

```text
android/app/src/main/kotlin/com/example/foco/MainActivity.kt
```

com o conteúdo:

```kotlin
package com.example.foco

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

A pasta **precisa** espelhar o `package` declarado no arquivo, e o `package` precisa bater com o
`namespace`. Então são três mudanças coordenadas: a pasta, o `package` e o `namespace`.

**🪟 Windows (PowerShell)** — a partir da raiz do projeto:

```powershell
New-Item -ItemType Directory -Force android\app\src\main\kotlin\br\com\estudos\foco
Move-Item android\app\src\main\kotlin\com\example\foco\MainActivity.kt `
          android\app\src\main\kotlin\br\com\estudos\foco\MainActivity.kt
Remove-Item -Recurse android\app\src\main\kotlin\com
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
mkdir -p android/app/src/main/kotlin/br/com/estudos/foco
mv android/app/src/main/kotlin/com/example/foco/MainActivity.kt \
   android/app/src/main/kotlin/br/com/estudos/foco/MainActivity.kt
rm -rf android/app/src/main/kotlin/com
```

Agora edite a **primeira linha** do arquivo movido:

```kotlin
package br.com.estudos.foco

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

Confira que a estrutura ficou assim:

**🪟 Windows (PowerShell)**

```powershell
Get-ChildItem -Recurse android\app\src\main\kotlin -Filter *.kt | Select-Object FullName
```

Saída esperada (um único arquivo):

```text
...\android\app\src\main\kotlin\br\com\estudos\foco\MainActivity.kt
```

### Passo 4 — Nome exibido

Abra `android/app/src/main/AndroidManifest.xml` e procure `android:label`:

```xml
<application
    android:label="foco"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

Troque para o nome que o usuário deve ver:

```xml
<application
    android:label="Foco"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

Regras práticas para o nome exibido:

- **Curto.** A tela inicial do Android corta nomes longos com reticências. Até ~12 caracteres é
  seguro; "Foco" tem 4.
- Pode ter **acento, espaço e maiúscula** — é texto para humano, não identificador.
- Pode ser **diferente** do nome na Play Store (a Play tem um campo próprio de título).
- `android:name="${applicationName}"` é um espaço reservado que o plugin Gradle do Flutter
  substitui pela classe de aplicação correta. **Não mexa nessa linha.**

### Passo 5 — Versão

No `pubspec.yaml`, logo abaixo de `description:`:

```yaml
name: foco
description: "Foco — organizador de sessões de estudo."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.13.0
```

Para o primeiro release, `1.0.0+1` está correto. A cada envio novo para a loja, **sempre** suba o
número depois do `+`:

```yaml
version: 1.0.1+2     # correção de bug
version: 1.1.0+3     # funcionalidade nova
version: 2.0.0+4     # mudança grande
```

Note que o build number sobe **sempre**, mesmo quando o build name não muda.

### Passo 6 — Sobrescrever a versão no comando de build

Às vezes você precisa gerar um artefato com outra versão sem alterar o `pubspec.yaml` — típico em
integração contínua, onde o número do build vem do servidor:

```powershell
flutter build appbundle --build-name=1.0.0 --build-number=7
```

- `--build-name=1.0.0` sobrescreve o `versionName` / `CFBundleShortVersionString`.
- `--build-number=7` sobrescreve o `versionCode` / `CFBundleVersion`.

As duas flags valem para `apk`, `appbundle` e `ipa`. Elas **não alteram** o `pubspec.yaml`; valem só
para aquele build.

### Passo 7 — Confirmar que funcionou

```powershell
flutter clean
flutter pub get
flutter run
```

Se compilar e abrir, os três arquivos estão coerentes. Confirmação objetiva: com o app rodando,
liste os pacotes instalados no aparelho:

```powershell
adb shell pm list packages | Select-String estudos
```

Saída esperada:

```text
package:br.com.estudos.foco
```

`adb` (*Android Debug Bridge*) é a ferramenta de linha de comando do Android SDK que conversa com o
aparelho. Ela aparece em detalhe na [Aula 9](09-instalando-e-validando.md).

---

## 💻 Código completo

O arquivo `android/app/build.gradle.kts` do **Foco**, já com a identidade ajustada e ainda **sem** a
assinatura de release (que entra na [Aula 7](07-assinatura-no-gradle.md)).

> **Arquivo:** `android/app/build.gradle.kts`
> **Como executar:** `flutter clean` e depois `flutter run`

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // O plugin Gradle do Flutter precisa vir DEPOIS dos plugins do Android e do Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Pacote base usado pelo compilador para gerar as classes R e BuildConfig.
    namespace = "br.com.estudos.foco"

    // Versão da API do Android usada para COMPILAR (36 no Flutter 3.47).
    compileSdk = flutter.compileSdkVersion

    // Versão do NDK (kit de desenvolvimento nativo) usada pelos plugins com código C/C++.
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // O Gradle 9.x com AGP 9.1.0 exige Java 17 neste projeto.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // IDENTIDADE DEFINITIVA DO APP. Não muda depois de publicar na Play.
        applicationId = "br.com.estudos.foco"

        // Versão mínima do Android em que o app instala: 24 = Android 7.0.
        minSdk = flutter.minSdkVersion

        // Versão do Android para a qual o app declara estar preparado: 36.
        targetSdk = flutter.targetSdkVersion

        // Vêm do campo `version: 1.0.0+1` do pubspec.yaml.
        versionCode = flutter.versionCode   // o "1" depois do +
        versionName = flutter.versionName   // o "1.0.0" antes do +
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    // Onde está a raiz do projeto Flutter, relativa a android/app/.
    source = "../.."
}
```

E o `MainActivity.kt`, já na pasta correta:

> **Arquivo:** `android/app/src/main/kotlin/br/com/estudos/foco/MainActivity.kt`
> **Como executar:** é compilado automaticamente por `flutter run`

```kotlin
package br.com.estudos.foco

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

---

## 🔍 Explicando o código

- `plugins { ... }` declara os plugins do Gradle. A ordem importa: o
  `dev.flutter.flutter-gradle-plugin` precisa vir por último porque ele **lê** a configuração que os
  outros dois montaram.
- `namespace = "br.com.estudos.foco"` define o pacote das classes geradas. Se ele não bater com o
  `package` do `MainActivity.kt`, o Kotlin reclama que a classe não está onde deveria.
- `compileSdk = flutter.compileSdkVersion` — `flutter` aqui é um objeto injetado pelo plugin do
  Flutter no Gradle. Escrever `36` na mão funcionaria, mas quebra a sincronia com o SDK a cada
  atualização do Flutter. **Deixe como está.**
- `ndkVersion` — **NDK** (*Native Development Kit*) é o kit para código C/C++ dentro do Android.
  Plugins como `sqflite` trazem bibliotecas nativas; o NDK é o que as compila e empacota.
- `compileOptions` com `VERSION_17` — Java 17 é o exigido pelo AGP 9.1.0 nesta configuração. O curso
  usa Temurin OpenJDK 17.0.18. Se você tiver outro JDK como padrão, o build falha; a
  [Aula 10](10-diagnostico-de-build.md) mostra a mensagem exata e a correção.
- `minSdk = flutter.minSdkVersion` → 24. Isso significa que aparelhos com Android 6 ou anterior
  **não conseguem instalar** o app. É uma decisão de alcance × capacidade: o Flutter 3.47 fixou 24
  como piso.
- `targetSdk` → 36. Declara "eu fui testado e me comporto bem nas regras do Android 16". O Android
  aplica regras de compatibilidade diferentes conforme esse número, e a Play exige um `targetSdk`
  recente para aceitar uploads.
- `versionCode` / `versionName` lidos de `flutter.*`: é o elo entre o `pubspec.yaml` e o Android.
- `flutter { source = "../.." }` diz ao plugin onde está a raiz do projeto Flutter, subindo duas
  pastas a partir de `android/app/`.

---

## 🤖🍎 Android × iOS

O conceito é o mesmo; os nomes e os lugares mudam.

| Conceito | 🤖 Android | 🍎 iOS |
|---|---|---|
| Identificador definitivo | `applicationId` em `android/app/build.gradle.kts` | **Bundle Identifier** (`PRODUCT_BUNDLE_IDENTIFIER`), definido no Xcode |
| Pacote do código | `namespace` | não existe equivalente direto |
| Nome exibido | `android:label` no `AndroidManifest.xml` | `CFBundleDisplayName` no `ios/Runner/Info.plist` |
| Nome curto interno | — | `CFBundleName` |
| Versão visível | `versionName` | `CFBundleShortVersionString` |
| Número do build | `versionCode` | `CFBundleVersion` |
| Origem dos dois últimos | `version: 1.0.0+1` do `pubspec.yaml` | `version: 1.0.0+1` do `pubspec.yaml` |

No `ios/Runner/Info.plist` que o Flutter 3.47 gera, os valores aparecem como variáveis:

```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
```

`$(FLUTTER_BUILD_NAME)` e `$(FLUTTER_BUILD_NUMBER)` são preenchidas pelo Flutter a partir do
`pubspec.yaml` — exatamente as mesmas que `--build-name` e `--build-number` sobrescrevem.

> 🍎 **SÓ NO MAC.** Trocar o Bundle Identifier exige abrir `ios/Runner.xcworkspace` no Xcode. No
> Windows você não consegue executar esse passo. O processo completo está em
> [16-build-ios/04-bundle-id-e-xcode.md](../16-build-ios/04-bundle-id-e-xcode.md). Use o **mesmo**
> identificador nas duas plataformas (`br.com.estudos.foco`) — não é obrigatório pelo sistema, mas
> facilita a sua vida em notificações, links e integrações.

---

## ⚠️ Erros comuns

**1. Trocar o `applicationId` e esquecer de mover a pasta do `MainActivity.kt`.**

```text
e: file:///.../MainActivity.kt:1:1 Package directive doesn't match file location
```

ou, em tempo de execução:

```text
java.lang.ClassNotFoundException: Didn't find class "br.com.estudos.foco.MainActivity"
```

Correção: mover a pasta e ajustar o `package` da primeira linha, como no Passo 3.

**2. Editar `android/app/build.gradle` (sem `.kts`).**
Esse arquivo **não existe** no Flutter 3.47. Se você criou um à mão seguindo um tutorial velho,
apague-o: dois arquivos de build na mesma pasta confundem o Gradle. O correto é
`android/app/build.gradle.kts`.

**3. Usar sintaxe Groovy dentro do `.kts`.**

```text
e: Unresolved reference: applicationId
```

Groovy escreve `applicationId "br.com.estudos.foco"` (sem `=`). Kotlin DSL exige
`applicationId = "br.com.estudos.foco"` (com `=` e aspas duplas).

**4. Hífen ou acento no `applicationId`.**

```text
The application ID 'br.com.estudos.meu-app' is not a valid Java package name
```

Use `_` ou junte as palavras: `br.com.estudos.meuapp`.

**5. Publicar com `com.example.`.**
A Google Play recusa. Troque **antes** do primeiro upload.

**6. Esquecer de subir o `versionCode`.**
A Play recusa o upload com a mensagem sobre "version code". Suba o número depois do `+` no
`pubspec.yaml`, ou passe `--build-number`.

**7. Achar que mudar o nome da pasta do projeto muda o `applicationId`.**
Não muda nada. O nome da pasta é só do seu disco; `applicationId` está no `build.gradle.kts`.

**8. Mudar o `applicationId` de um app já instalado e estranhar duas instalações.**
São dois apps para o Android. Desinstale o antigo no aparelho: `adb uninstall com.example.foco`.

---

## 🛠️ Exercício guiado

Objetivo: transformar a identidade do seu projeto de `com.example.*` em `br.com.estudos.foco` e
comprovar cada etapa.

**Passo 1 — Registre o ponto de partida.**

```powershell
git status
git add .
git commit -m "Antes de trocar a identidade do app"
```

**Passo 2 — Descubra o estado atual.**

```powershell
Select-String -Path android\app\build.gradle.kts -Pattern "namespace|applicationId"
```

Saída esperada (antes da mudança):

```text
android\app\build.gradle.kts:10:    namespace = "com.example.foco"
android\app\build.gradle.kts:24:        applicationId = "com.example.foco"
```

**Passo 3 — Edite as duas linhas** para `br.com.estudos.foco` e apague o comentário `TODO` do
`applicationId`.

**Passo 4 — Mova a pasta do `MainActivity.kt`** com os comandos do Passo 3 da seção anterior e
ajuste a linha `package`.

**Passo 5 — Troque o nome exibido** em `android/app/src/main/AndroidManifest.xml` para `Foco`.

**Passo 6 — Confirme a versão** no `pubspec.yaml`: `version: 1.0.0+1`.

**Passo 7 — Compile e instale.**

```powershell
flutter clean
flutter pub get
flutter run
```

**Passo 8 — Prove no aparelho.**

```powershell
adb shell pm list packages | Select-String estudos
```

Saída esperada:

```text
package:br.com.estudos.foco
```

E no aparelho, o ícone agora está legendado **Foco**.

**Passo 9 — Prove a versão.**

```powershell
adb shell dumpsys package br.com.estudos.foco | Select-String "versionName|versionCode"
```

Saída esperada:

```text
    versionCode=1 minSdk=24 targetSdk=36
    versionName=1.0.0
```

**Como confirmar que funcionou:** os três números batem — `versionCode=1` e `versionName=1.0.0`
vieram do `version: 1.0.0+1`, e `minSdk=24` veio do Flutter 3.47.

**Passo 10 — Teste `--build-number`.** Sem tocar no `pubspec.yaml`:

```powershell
flutter build apk --release --build-name=1.0.1 --build-number=5
```

O APK gerado tem `versionName=1.0.1` e `versionCode=5`, mas o `pubspec.yaml` continua `1.0.0+1`.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-android.md](../../exercicios/15-build-android.md)

Faça os exercícios de aplicação sobre domínio invertido e o de correção de bugs com o
`MainActivity.kt` fora do lugar.

---

## 🏆 Desafio opcional

Configure o projeto **Foco** para gerar **duas variantes instaláveis lado a lado**: a versão de
desenvolvimento e a de produção, sem duplicar código.

Pistas:

1. No `defaultConfig`, mantenha `applicationId = "br.com.estudos.foco"`.
2. Dentro de `buildTypes`, no bloco `debug`, acrescente:

   ```kotlin
   buildTypes {
       debug {
           applicationIdSuffix = ".dev"
           versionNameSuffix = "-dev"
       }
       release {
           signingConfig = signingConfigs.getByName("debug")
       }
   }
   ```

3. `applicationIdSuffix` acrescenta um sufixo **só** ao `applicationId` daquele tipo de build. O
   `namespace` continua um só, então a classe `R` não duplica.
4. Ajuste o `android:label` por tipo de build usando um recurso de string — pesquise
   `resValue("string", "app_name", "Foco Dev")` no `buildTypes`.

Critério de sucesso: `adb shell pm list packages | Select-String estudos` lista **dois** pacotes
(`br.com.estudos.foco` e `br.com.estudos.foco.dev`) e os dois ícones aparecem na tela inicial.

---

## 📌 Resumo

- Um app Android tem **três nomes**: nome exibido (`android:label`), `applicationId` e `namespace` —
  além do nome do projeto Flutter.
- **`applicationId`** é a identidade do app para o sistema e para a loja. **`namespace`** é o pacote
  usado pelo compilador para gerar `R` e `BuildConfig`.
- Eles podem ser diferentes — é assim que se publicam variantes (`.pro`, `.dev`) do mesmo código.
- O formato é **domínio invertido**: `estudos.com.br` → `br.com.estudos.foco`. Sem hífen, sem acento,
  sem maiúscula. Nunca `com.example.`.
- 🔴 O `applicationId` **não pode mudar** depois de publicar: perde avaliações, instalações e o
  caminho de atualização.
- Trocar o `applicationId` e o `namespace` exige **mover a pasta** do `MainActivity.kt` e ajustar a
  linha `package`.
- `version: 1.0.0+1` do `pubspec.yaml` vira `versionName`/`versionCode` no Android e
  `CFBundleShortVersionString`/`CFBundleVersion` no iOS.
- O `versionCode` precisa crescer a cada envio para a loja. O `versionName` é texto livre.
- `--build-name` e `--build-number` sobrescrevem a versão só naquele build.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre `applicationId` e `namespace` com um exemplo concreto.
- [ ] Escrevo um `applicationId` válido em domínio invertido a partir de um domínio qualquer.
- [ ] Listo quatro consequências de mudar o `applicationId` depois de publicar.
- [ ] Troco `applicationId` e `namespace` em `android/app/build.gradle.kts` sem errar a sintaxe do
      Kotlin DSL.
- [ ] Movo a pasta do `MainActivity.kt` e ajusto o `package` sem quebrar o build.
- [ ] Mudo o nome exibido do app e vejo o novo nome no aparelho.
- [ ] Digo de cor em que vira `1.0.0` e em que vira `1` no Android e no iOS.
- [ ] Sei que o `versionCode` precisa crescer a cada envio.
- [ ] Uso `--build-name` e `--build-number` sem mexer no `pubspec.yaml`.
- [ ] Sei que `flutter create --org br.com.estudos foco` evita todo o trabalho manual.

---

## 📚 Referências oficiais

- [Flutter — Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Android Developers — Configure the app module](https://developer.android.com/build/configure-app-module)
- [Android Developers — Set the application ID](https://developer.android.com/build/configure-app-module#set-application-id)
- [Android Developers — Version your app](https://developer.android.com/studio/publish/versioning)
- [Android Developers — App manifest `<application>`](https://developer.android.com/guide/topics/manifest/application-element)
- [Dart — Package versioning (`pubspec.yaml`)](https://dart.dev/tools/pub/pubspec)
- [Semantic Versioning 2.0.0](https://semver.org/lang/pt-BR/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Debug, profile e release](01-debug-profile-release.md) | [README](README.md) | [Ícone](03-icone.md) |
