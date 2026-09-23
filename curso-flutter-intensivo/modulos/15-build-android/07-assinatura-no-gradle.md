# Aula 7 — Assinatura no Gradle

> **Módulo:** 15 - Build e Distribuição Android · **Tempo estimado:** 50 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Criar o **`key.properties`** e entender por que ele fica fora do Git.
- Configurar **`signingConfigs`** no `build.gradle.kts` (Kotlin DSL).
- Substituir a chave de debug pela sua no build de release.
- **Falhar o build** quando a configuração estiver ausente, em vez de gerar um artefato inútil.
- Ler o `build.gradle.kts` do Flutter: `compileSdk`, `minSdk`, `targetSdk`, `versionCode`.
- Configurar **R8/ProGuard** e `isShrinkResources` com segurança.
- Assinar também no **CI**, com variáveis de ambiente em vez de arquivo.

## ✅ Pré-requisitos

- [Aula 6 — Keystore](06-keystore.md) — **essencial**: você precisa do `.jks`, do alias e das duas
  senhas.
- [Aula 2 — Identidade do app](02-identidade-do-app.md) — `applicationId` e `version`.
- [Módulo 13, aula 7 — Ofuscação](../13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) —
  R8 e regras `-keep`.
- [Módulo 11, aula 7 — Pastas android/ e ios/](../11-recursos-nativos/07-pastas-android-e-ios.md).

---

## 📖 Conceito

### Onde tudo acontece

```text
android/
├── key.properties            ← ⚠️ SUAS SENHAS. Nunca no Git.
├── build.gradle.kts          ← configuração do PROJETO
├── gradle.properties         ← memória da JVM, flags
├── settings.gradle.kts       ← versões dos plugins
└── app/
    ├── build.gradle.kts      ← ✅ é AQUI que você mexe
    └── proguard-rules.pro    ← regras do R8
```

> ⚠️ **Há dois `build.gradle.kts`.** O de `android/` é do projeto inteiro; o de `android/app/` é do
> módulo do app. **A assinatura vai no segundo.** Editar o errado é o tropeço mais comum da aula —
> e o erro resultante não diz isso.

### `key.properties`

O arquivo com as senhas, **fora do Git**:

```properties
# android/key.properties
# ⚠️ ESTE ARQUIVO NUNCA VAI PARA O GIT.
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=foco
storeFile=C:/Users/SEU_USUARIO/chaves/foco-upload.jks
```

> ⚠️ **Use barras normais (`/`) no `storeFile`, mesmo no Windows.** A barra invertida é caractere de
> escape em arquivos `.properties`: `C:\Users\...` faz o Gradle procurar em um caminho corrompido, e
> o erro que ele dá (`Keystore file not found`) não menciona a barra.

E o exemplo **sem valores**, que vai para o Git:

```properties
# android/key.properties.example
storePassword=
keyPassword=
keyAlias=
storeFile=
```

### `signingConfigs`

O bloco que liga a chave ao build de release:

```kotlin
// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream

// Lê o key.properties, se existir.
val chaveProps = Properties()
val chaveArquivo = rootProject.file("key.properties")
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

> 📌 `rootProject.file("key.properties")` resolve para `android/key.properties` — porque, no projeto
> Android, a raiz é a pasta `android/`, não a do Flutter.

### O padrão perigoso que o Flutter deixa

Num projeto Flutter novo, o `build.gradle.kts` vem assim:

```kotlin
buildTypes {
    release {
        // ⚠️ TODO: Add your own signing config for the release build.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

**Isso gera um APK de release assinado com a chave de debug.** Ele instala, funciona, parece
perfeito — e a Play Console recusa o upload.

> ⚠️ **O sintoma é tardio e caro.** Você compila, testa, distribui para amigos, faz o beta... e só
> descobre no momento do upload, com uma mensagem genérica sobre a assinatura. Substitua essa linha
> **antes** de qualquer outra coisa.

### Falhar cedo

Melhor que substituir: **falhar** se a configuração não existir.

```kotlin
buildTypes {
    release {
        signingConfig = if (chaveArquivo.exists()) {
            signingConfigs.getByName("release")
        } else {
            // Em CI sem as variáveis, ou num clone novo, o build
            // PARA aqui em vez de gerar um artefato inútil.
            throw GradleException(
                "key.properties não encontrado. " +
                "Copie de key.properties.example e preencha (Aula 7)."
            )
        }
    }
}
```

> 💡 **Um build que falha com mensagem clara vale mais que um build que passa gerando lixo.** Este é
> o mesmo princípio do `ConfigApp.validar()` do módulo 13: erre no primeiro segundo, não no último.

### Os SDKs

```kotlin
android {
    namespace = "br.com.estudos.foco"
    compileSdk = flutter.compileSdkVersion    // com o que COMPILA
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "br.com.estudos.foco"  // ⚠️ imutável após publicar
        minSdk = flutter.minSdkVersion          // o MAIS ANTIGO que roda
        targetSdk = flutter.targetSdkVersion    // o que você TESTOU
        versionCode = flutter.versionCode       // vem do pubspec (+N)
        versionName = flutter.versionName       // vem do pubspec (x.y.z)
    }
}
```

| Campo | Significa | Se estiver errado |
|---|---|---|
| `compileSdk` | API com que compila | Erro de compilação |
| `minSdk` | Aparelho mais antigo suportado | Baixo: quebra; alto: perde usuários |
| `targetSdk` | API que você testou | ⚠️ **Play exige valor recente** |
| `versionCode` | Número inteiro, sempre crescente | Repetido: **upload recusado** |
| `versionName` | O que o usuário vê | — |

```yaml
# pubspec.yaml — a fonte dos dois últimos
version: 1.2.0+15
#        ^^^^^ versionName    ^^ versionCode
```

> ⚠️ **O `versionCode` precisa ser maior a cada envio.** Não há como reaproveitar um número, nem
> mesmo se o envio anterior foi descartado. Esquecer de incrementar o `+15` é o erro mais frequente
> de quem publica atualizações — e a Play Console só avisa depois do upload inteiro.

> 💡 O Play exige que o `targetSdk` esteja dentro de um ano da API mais recente. Apps com
> `targetSdk` velho param de receber atualizações — e depois somem da busca para aparelhos novos.

### R8 e a minificação

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro",
        )
    }
}
```

> ⚠️ **`isShrinkResources = true` exige `isMinifyEnabled = true`.** Sozinho, dá erro de
> configuração do Gradle — que é, pelo menos, um erro honesto e imediato.

E o sintoma clássico do R8, já visto no módulo 13: funciona em debug, **quebra em release**. A
correção é uma regra `-keep` para as classes acessadas por reflexão.

### Assinar no CI

No CI não há `key.properties` — e não pode haver, porque o repositório é clonado.

```kotlin
// Prioridade: variável de ambiente > arquivo local.
// Assim a mesma configuração serve para a sua máquina e para o CI.
val storePassEnv: String? = System.getenv("ANDROID_STORE_PASSWORD")

signingConfigs {
    create("release") {
        if (storePassEnv != null) {
            // CI: os valores vêm do ambiente, e o keystore foi
            // decodificado de um secret em base64.
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH"))
            storePassword = storePassEnv
        } else if (chaveArquivo.exists()) {
            keyAlias = chaveProps["keyAlias"] as String?
            keyPassword = chaveProps["keyPassword"] as String?
            storeFile = chaveProps["storeFile"]?.let { file(it) }
            storePassword = chaveProps["storePassword"] as String?
        }
    }
}
```

```yaml
# .github/workflows/release.yml
- name: Restaurar o keystore
  run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > "$RUNNER_TEMP/upload.jks"

- name: Build
  env:
    ANDROID_KEYSTORE_PATH: ${{ runner.temp }}/upload.jks
    ANDROID_STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
    ANDROID_KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
    ANDROID_KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
  run: flutter build appbundle --release
```

> ⚠️ **Nunca imprima as variáveis de senha no log do CI.** O log costuma ser público em repositórios
> abertos, e fica arquivado. O GitHub mascara os `secrets` automaticamente, mas um `echo` de uma
> variável derivada escapa do mascaramento.

---

## 💡 Analogia

Pense num **cartório com um funcionário novo**.

- **O keystore (aula 6)** é o carimbo, guardado no cofre de casa.
- **O `key.properties`** é o bilhete com o endereço do cofre e a combinação. Ele fica na sua
  carteira, **nunca no arquivo público** do cartório.
- **O `signingConfigs`** é a instrução de trabalho: *"para documentos oficiais, use o carimbo cujo
  endereço e combinação estão no bilhete"*.
- **O `signingConfig = signingConfigs.getByName("debug")` que vem no projeto novo** é a instrução de
  fábrica: *"use o carimbo de brinquedo"*. O funcionário obedece sem reclamar, os documentos saem
  bonitos, com aparência oficial — e são **recusados no protocolo**. Meses de trabalho descobertos
  no balcão.
- **Falhar o build sem o `key.properties`** é o funcionário que **se recusa a trabalhar** sem o
  bilhete, em vez de improvisar com o carimbo errado. Incômodo no momento, e a coisa mais barata
  que ele pode fazer por você.
- **O `versionCode`** é o número de protocolo: sempre crescente, nunca repetido. Chegar ao balcão
  com um número já usado é voltar para casa.
- **E o CI** é a filial que não tem cofre. Você não manda o carimbo pelo correio: manda por malote
  lacrado, que só aquela filial abre — e o malote não fica lá depois do expediente.

---

## 🧪 Exemplo mínimo

```properties
# android/key.properties
storePassword=MinhaSenhaForte123
keyPassword=MinhaSenhaForte123
keyAlias=foco
storeFile=C:/Users/SeuUsuario/chaves/foco-upload.jks
```

```kotlin
// android/app/build.gradle.kts — o mínimo que funciona
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val chaveProps = Properties()
val chaveArquivo = rootProject.file("key.properties")
if (chaveArquivo.exists()) {
    chaveProps.load(FileInputStream(chaveArquivo))
}

android {
    namespace = "br.com.estudos.foco"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "br.com.estudos.foco"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

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
            // ⭐ A linha que substitui o padrão perigoso do Flutter.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
```

```powershell
flutter build apk --release
.\tool\conferir-assinatura.ps1
```

```text
✅ Assinado com uma chave de release.
```

---

## 📱 Aplicando no Flutter

O arquivo completo, com falha explícita, R8 e suporte a CI.

---

## 💻 Código completo

> **Arquivo:** `android/app/build.gradle.kts`

```kotlin
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // ⚠️ O plugin do Flutter vem DEPOIS dos de Android e Kotlin.
    // Fora de ordem, o build falha com uma mensagem obscura
    // sobre propriedades não encontradas.
    id("dev.flutter.flutter-gradle-plugin")
}

// ══════════════════════════════════════════════════════════════
// Assinatura: ambiente (CI) tem prioridade sobre arquivo (local)
// ══════════════════════════════════════════════════════════════

val chaveProps = Properties()
// rootProject aqui é a pasta `android/`, não a raiz do Flutter.
val chaveArquivo = rootProject.file("key.properties")
val temArquivo = chaveArquivo.exists()

if (temArquivo) {
    chaveProps.load(FileInputStream(chaveArquivo))
}

// No CI não existe key.properties — o repositório é clonado, e o
// arquivo está (corretamente) no .gitignore. Os valores vêm do
// ambiente, restaurados de secrets.
val senhaDoAmbiente: String? = System.getenv("ANDROID_STORE_PASSWORD")
val temAmbiente = senhaDoAmbiente != null

android {
    namespace = "br.com.estudos.foco"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // ⚠️ IMPOSSÍVEL mudar depois de publicar. Aula 2.
        applicationId = "br.com.estudos.foco"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Vêm do pubspec.yaml: `version: 1.2.0+15`
        //   1.2.0 → versionName    15 → versionCode
        // ⚠️ O versionCode precisa CRESCER a cada envio. Repetido,
        // a Play Console recusa — depois do upload inteiro.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ══════════════════════════════════════════════════════════
    signingConfigs {
        create("release") {
            when {
                // 1. CI: valores do ambiente.
                temAmbiente -> {
                    keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                    keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
                    storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH"))
                    storePassword = senhaDoAmbiente
                }
                // 2. Local: key.properties.
                temArquivo -> {
                    keyAlias = chaveProps["keyAlias"] as String?
                    keyPassword = chaveProps["keyPassword"] as String?
                    storeFile = chaveProps["storeFile"]?.let { file(it) }
                    storePassword = chaveProps["storePassword"] as String?
                }
                // 3. Nenhum dos dois: não configura nada.
                // O build de release falha adiante, com mensagem clara.
            }
        }
    }

    buildTypes {
        debug {
            // Sufixo no applicationId: permite ter o app de debug
            // e o de release INSTALADOS AO MESMO TEMPO. Sem isto,
            // instalar um desinstala o outro.
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            isMinifyEnabled = false
        }

        release {
            // ⭐ O CORAÇÃO DESTA AULA.
            //
            // O projeto novo do Flutter vem com:
            //     signingConfig = signingConfigs.getByName("debug")
            //
            // Isso gera um release assinado com a chave de debug:
            // instala, funciona, parece perfeito — e a Play Console
            // RECUSA o upload. O erro aparece no fim de tudo.
            signingConfig = if (temAmbiente || temArquivo) {
                signingConfigs.getByName("release")
            } else {
                // Falhar aqui, com mensagem clara, é melhor que
                // gerar um artefato que só falha no balcão da loja.
                throw GradleException(
                    """
                    |
                    |❌ Assinatura de release não configurada.
                    |
                    |Local:  crie android/key.properties a partir de
                    |        android/key.properties.example  (Aula 7)
                    |
                    |CI:     defina ANDROID_STORE_PASSWORD,
                    |        ANDROID_KEY_PASSWORD, ANDROID_KEY_ALIAS
                    |        e ANDROID_KEYSTORE_PATH
                    |
                    """.trimMargin()
                )
            }

            // R8: remove código morto e ofusca Java/Kotlin.
            // Módulo 13, aula 7.
            isMinifyEnabled = true
            // ⚠️ Exige isMinifyEnabled = true; sozinho, dá erro.
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )

            // Um crash em release precisa do número da linha.
            isDebuggable = false
        }
    }

    // Reduz o tamanho excluindo idiomas não usados dos pacotes
    // do AndroidX — que trazem dezenas.
    androidResources {
        localeFilters += listOf("pt-rBR", "en")
    }

    packaging {
        resources {
            // Vários pacotes trazem as mesmas licenças; sem isto,
            // o build falha com "Duplicate resources".
            excludes += setOf(
                "META-INF/LICENSE*",
                "META-INF/NOTICE*",
                "META-INF/DEPENDENCIES",
            )
        }
    }
}

flutter {
    source = "../.."
}

// ══════════════════════════════════════════════════════════════
// Aviso ao fim do build de release
// ══════════════════════════════════════════════════════════════
tasks.register("avisarAssinatura") {
    doLast {
        val origem = when {
            temAmbiente -> "variáveis de ambiente (CI)"
            temArquivo -> "android/key.properties"
            else -> "NENHUMA"
        }
        println("🔐 Assinatura de release: $origem")
    }
}

tasks.whenTaskAdded {
    if (name == "assembleRelease" || name == "bundleRelease") {
        dependsOn("avisarAssinatura")
    }
}
```

> **Arquivo:** `android/app/proguard-rules.pro`

```proguard
# ══════════════════════════════════════════════════════════════
# Flutter — o engine e os plugins usam reflexão.
# ══════════════════════════════════════════════════════════════
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ══════════════════════════════════════════════════════════════
# Stack traces legíveis no crash nativo.
# Sem estas linhas, o R8 remove o número da linha — e o relatório
# de crash aponta só a classe. Módulo 12, aula 9.
# ══════════════════════════════════════════════════════════════
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Anotações usadas em tempo de execução.
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# ══════════════════════════════════════════════════════════════
# ⚠️ Suas classes acessadas por REFLEXÃO.
#
# O R8 não as "vê" sendo usadas e as remove. O app compila
# normalmente e quebra em EXECUÇÃO, só em release, com
# ClassNotFoundException ou NoSuchMethodError.
#
# Descomente conforme a necessidade aparecer:
# ══════════════════════════════════════════════════════════════
# -keep class br.com.estudos.foco.modelos.** { *; }

# ══════════════════════════════════════════════════════════════
# Avisos de classes opcionais que alguns pacotes referenciam
# sem incluir. Não são erros — mas sujam o log.
# ══════════════════════════════════════════════════════════════
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
```

> **Arquivo:** `android/key.properties.example` (vai para o Git)

```properties
# Copie para android/key.properties e preencha.
#
# ⚠️ key.properties NUNCA vai para o Git — ele está no .gitignore.
# Este arquivo (.example) documenta a FORMA, nunca os valores.
#
# ⚠️ No storeFile, use barras NORMAIS (/) mesmo no Windows:
#    a barra invertida é caractere de escape em .properties, e
#    o erro resultante ("Keystore file not found") não diz isso.

storePassword=
keyPassword=
keyAlias=
storeFile=C:/Users/SEU_USUARIO/chaves/foco-upload.jks
```

> **Arquivo:** `.gitignore` (confirmar)

```gitignore
android/key.properties
!android/key.properties.example
*.jks
*.keystore
```

```powershell
Copy-Item android/key.properties.example android/key.properties
# preencha os valores
flutter build apk --release
.\tool\conferir-assinatura.ps1
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Plugin do Flutter **depois** dos de Android/Kotlin | Fora de ordem, erro obscuro sobre propriedades não encontradas. |
| `rootProject.file("key.properties")` | No projeto Android, `rootProject` é a pasta `android/`. |
| Ambiente **antes** de arquivo | A mesma configuração serve para a sua máquina e para o CI. |
| `when { temAmbiente -> … temArquivo -> … }` | Três cenários explícitos; o terceiro não configura nada. |
| **`signingConfig = if (…) … else throw`** | **O coração da aula.** Falhar é melhor que gerar artefato recusado no balcão. |
| Mensagem com `trimMargin()` | Instrução acionável em vez de "signing config not found". |
| `applicationIdSuffix = ".debug"` | Permite ter debug e release **instalados ao mesmo tempo**. |
| `isMinifyEnabled` + `isShrinkResources` | R8; o segundo **exige** o primeiro. |
| `-keepattributes SourceFile,LineNumberTable` | Sem isso, o crash nativo aponta só a classe, sem a linha. |
| `localeFilters` | Pacotes AndroidX trazem dezenas de idiomas; filtrar reduz o tamanho. |
| `excludes` em `packaging` | Vários pacotes trazem as mesmas licenças: "Duplicate resources". |
| `versionCode = flutter.versionCode` | Vem do `+N` do `pubspec`; precisa **crescer** a cada envio. |
| `avisarAssinatura` | Imprime a origem da assinatura ao fim do build — diagnóstico grátis. |
| `key.properties.example` versionado | Documenta a **forma**, nunca os valores. |
| Aviso das barras `/` no `storeFile` | A barra invertida é escape em `.properties`, e o erro não diz isso. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onde configurar | `build.gradle.kts` | Xcode → Signing & Capabilities |
| Formato | Texto, versionável | `project.pbxproj` (texto ilegível) |
| Senhas | `key.properties`, fora do Git | Keychain do Mac |
| Automático | ❌ Você configura | ✅ *Automatically manage signing* |
| No CI | Variáveis + keystore em base64 | `fastlane match` ou App Store Connect API |
| Editar sem a IDE | ✅ Tranquilo | ⚠️ Arriscado |

> 💡 **O `project.pbxproj` do iOS é um arquivo de texto — e editá-lo à mão costuma dar errado.** Ele
> usa ids gerados e referências cruzadas; um erro de digitação corrompe o projeto de um jeito que o
> Xcode reporta mal. No Android, o `build.gradle.kts` é código de verdade, legível e diffável — uma
> das poucas áreas em que o Android é claramente mais amigável. Módulo 16, aula 4.

🪟 **No Windows**, esta aula funciona por completo. O equivalente iOS depende de um Mac ou de CI com
runner macOS.

---

## ⚠️ Erros comuns

### 1. Editar o `build.gradle.kts` errado

O de `android/` em vez de `android/app/`.

**Correção:** a assinatura vai no do **app**.

### 2. Deixar `signingConfigs.getByName("debug")` no release

A Play Console recusa, e você só descobre no upload.

**Correção:** troque para `"release"`.

### 3. Barra invertida no `storeFile`

```text
Keystore file not found
```

**Correção:** barras normais (`/`), mesmo no Windows.

### 4. `key.properties` no Git

Senhas vazadas.

**Correção:** `.gitignore`; se commitou, rotacione a chave.

### 5. `isShrinkResources` sem `isMinifyEnabled`

Erro de configuração do Gradle.

**Correção:** os dois juntos.

### 6. R8 sem regras `-keep`

Funciona em debug, quebra em release.

**Correção:** `-keep` para classes usadas por reflexão.

### 7. Esquecer de incrementar o `versionCode`

```text
Version code 15 has already been used
```

**Correção:** suba o `+N` no `pubspec.yaml`.

### 8. Plugin do Flutter fora de ordem

Erro obscuro sobre propriedades.

**Correção:** por último.

### 9. Senha da chave diferente da do store, e só uma no arquivo

```text
Cannot recover key
```

**Correção:** as duas, corretas.

### 10. Imprimir senha no log do CI

Fica arquivado.

**Correção:** nunca ecoe variáveis derivadas de secret.

### 11. Não conferir a assinatura antes do upload

**Correção:** `conferir-assinatura.ps1`.

### 12. Sem `applicationIdSuffix` no debug

Instalar um desinstala o outro.

**Correção:** `.debug`.

---

## 🛠️ Exercício guiado

**Passo 1.** Abra `android/app/build.gradle.kts` e ache a linha do `signingConfig` do release.

**Passo 2.** Ela aponta para `"debug"`? Compile e rode `conferir-assinatura.ps1`.

**Passo 3.** Crie `key.properties` a partir do `.example`, com barras normais.

**Passo 4.** Configure o `signingConfigs` e troque o `signingConfig` do release.

**Passo 5.** Compile e confira de novo. Mudou?

**Passo 6.** Renomeie `key.properties` e compile. A mensagem de erro é útil?

**Passo 7.** Restaure e troque uma barra `/` por `\` no `storeFile`. Leia o erro.

**Passo 8.** Ligue `isMinifyEnabled` e compare o tamanho do APK.

**Passo 9.** Instale o APK de release e o de debug ao mesmo tempo. Funciona?

**Passo 10.** Suba o `versionCode` no `pubspec` e confirme no APK
(`aapt dump badging app-release.apk | Select-String version`).

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-android.md](../../exercicios/15-build-android.md)

Faça os de **Aplicação** (configurar a assinatura), **Correção de bugs** (barra invertida no
caminho) e **Diagnóstico** (APK recusado pela loja).

---

## 🏆 Desafio opcional

Configure **três variantes** (*flavors*) do app: `dev`, `staging` e `prod`, instaláveis lado a lado.

Requisitos:

- `applicationId` diferente por variante (`.dev`, `.staging`, sem sufixo em prod).
- Nome exibido diferente: "Foco Dev", "Foco Staging", "Foco".
- Ícone diferente por variante, para distinguir na gaveta de apps.
- Cada uma com o seu `--dart-define-from-file` (módulo 13, aula 6).
- Só `prod` é assinada com a chave de upload; as outras, com a de debug.
- `flutter run --flavor dev` e `flutter build appbundle --flavor prod`.

Depois responda: por que a chave de **debug** é a escolha certa para `dev` e `staging`? E o que
mudaria se `staging` precisasse ir para a faixa de teste interno da Play Console?

---

## 📌 Resumo

- **A assinatura vai em `android/app/build.gradle.kts`**, não no de `android/`.
- `key.properties` guarda as senhas, **fora do Git**; versione só o `.example`.
- ⚠️ **Barras normais (`/`) no `storeFile`**, mesmo no Windows — `\` é escape em `.properties`.
- **O projeto novo do Flutter vem apontando para a chave de debug.** Trocar isso é a tarefa central
  da aula.
- Release assinado com chave de debug **instala e funciona** — e é recusado no upload.
- **Falhe o build** quando a assinatura não estiver configurada, com mensagem acionável.
- `versionCode` vem do `+N` do `pubspec` e precisa **crescer a cada envio**.
- `targetSdk` precisa ser recente, ou o Play para de aceitar atualizações.
- `isShrinkResources` **exige** `isMinifyEnabled`.
- R8 quebra o que é usado por **reflexão**: regras `-keep`.
- `-keepattributes SourceFile,LineNumberTable` mantém o número da linha nos crashes.
- **`applicationIdSuffix = ".debug"`** permite ter os dois apps instalados.
- No **CI**, os valores vêm de variáveis de ambiente; o keystore, de um secret em base64.
- **Nunca imprima senha no log do CI.**
- **Confira a assinatura antes de enviar.**

---

## ☑️ Checklist de domínio

- [ ] Sei qual dos dois `build.gradle.kts` editar.
- [ ] Criei `key.properties` e o `.example`.
- [ ] Usei barras normais no `storeFile`.
- [ ] Substituí o `signingConfig` de debug pelo de release.
- [ ] Meu build **falha** com mensagem clara se faltar a configuração.
- [ ] Entendo `compileSdk`, `minSdk`, `targetSdk` e `versionCode`.
- [ ] Incremento o `versionCode` a cada envio.
- [ ] Configurei R8 com as regras `-keep` do Flutter.
- [ ] Mantenho os atributos de linha para crashes legíveis.
- [ ] Uso `applicationIdSuffix` no debug.
- [ ] Sei configurar a assinatura no CI.
- [ ] Confiro a assinatura antes de enviar à loja.

---

## 📚 Referências oficiais

- [Build and release an Android app — docs.flutter.dev](https://docs.flutter.dev/deployment/android)
- [Configure the app module — developer.android.com](https://developer.android.com/build/configure-app-module)
- [Sign your app — developer.android.com](https://developer.android.com/studio/publish/app-signing)
- [Shrink, obfuscate, and optimize — developer.android.com](https://developer.android.com/build/shrink-code)
- [Gradle Kotlin DSL — docs.gradle.org](https://docs.gradle.org/current/userguide/kotlin_dsl.html)
- [Version your app — developer.android.com](https://developer.android.com/studio/publish/versioning)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Keystore](06-keystore.md) | [README](README.md) | [Gerando APK e AAB](08-gerando-apk-e-aab.md) |
