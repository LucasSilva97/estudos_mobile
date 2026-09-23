# Aula 9 — Depurando Android e iOS

> **Módulo:** 12 - Testes e Debug · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Ler logs nativos com **`flutter logs`**, **`adb logcat`** e o **Console.app**.
- Interpretar um **stack trace do Gradle** e achar a linha que importa.
- Usar **`--stacktrace`**, **`--verbose`** e limpar o **cache do Gradle**.
- Resolver os erros de **JDK** e de versão do Android Gradle Plugin.
- 🍎 Depurar no **Xcode**, entender **CocoaPods × SPM** e erros de assinatura.
- 🪟 Saber **o que dá e o que não dá** para diagnosticar no Windows.
- Aplicar um **método de 6 passos** para qualquer erro de build.

## ✅ Pré-requisitos

- [Aula 1 — Lendo stack traces](01-lendo-stack-traces.md) — o método de 5 passos para erro de
  execução; aqui ele é estendido para erro de **build**.
- [Aula 2 — Logs e breakpoints](02-logs-e-breakpoints.md) — `debugPrint` e `log()`.
- [Módulo 05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md) — SDK, emulador e `flutter doctor`.
- [Módulo 11, aula 7 — Pastas android/ e ios/](../11-recursos-nativos/07-pastas-android-e-ios.md).

---

## 📖 Conceito

### Três camadas, três lugares para olhar

Quando algo dá errado num app Flutter, o erro pode estar em três camadas — e cada uma fala uma
língua:

```text
┌──────────────────────────────────────────┐
│  Dart / Flutter                          │  ← caixa vermelha, DevTools
│  "RenderFlex overflowed by 42 pixels"    │     (aulas 1 a 3)
├──────────────────────────────────────────┤
│  Ponte de plugin (platform channel)      │  ← MissingPluginException
│  "No implementation found for method"    │
├──────────────────────────────────────────┤
│  Nativo: Gradle/Kotlin · Xcode/Swift     │  ← ESTA AULA
│  "Execution failed for task ':app:...'"  │     logcat, Console.app
└──────────────────────────────────────────┘
```

> 📌 **O primeiro diagnóstico é: em que camada estou?** A resposta muda a ferramenta inteira.
> Procurar um erro de Gradle no DevTools é perder a tarde.

| Sinal | Camada | Ferramenta |
|---|---|---|
| Caixa vermelha na tela | Dart | DevTools (aula 3) |
| `Exception` no console do Flutter | Dart | Stack trace (aula 1) |
| `MissingPluginException` | Ponte | Reinstalar o app |
| `Execution failed for task` | Gradle | `--stacktrace` |
| App fecha **sem** mensagem | Nativo | `adb logcat` / Console.app |
| Erro só no build de release | Nativo | Esta aula |

### `flutter logs` × `adb logcat`

```powershell
# Só as mensagens do Flutter (Dart), filtradas e legíveis.
flutter logs

# TUDO que o Android registra — inclusive o que o Flutter não vê.
adb logcat
```

> ⚠️ **A distinção que resolve o caso mais frustrante:** quando o app **fecha sozinho sem nenhuma
> mensagem** no console do Flutter, é porque o processo morreu na camada nativa. O `flutter logs`
> não mostra nada porque não há mais Dart rodando. **O `adb logcat` mostra.**

O `logcat` cru é ilegível — milhares de linhas por segundo, de todos os apps. Filtre:

```powershell
# Só o seu app (descubra o PID primeiro)
adb shell pidof br.com.exemplo.foco_lab
adb logcat --pid=12345

# Só erros e fatais
adb logcat *:E

# Só as tags do Flutter
adb logcat -s flutter

# Limpar antes de reproduzir — ESSENCIAL
adb logcat -c

# Gravar num arquivo para ler com calma
adb logcat -d > erro.txt
```

> 💡 **O fluxo que funciona:** `adb logcat -c` (limpa) → reproduza o erro → `adb logcat -d > erro.txt`
> (despeja e sai) → abra o arquivo e procure por `FATAL EXCEPTION`. Sem o `-c`, você lê o log de
> ontem.

O que procurar num crash nativo:

```text
E/AndroidRuntime: FATAL EXCEPTION: main
    Process: br.com.exemplo.foco_lab, PID: 12345
    java.lang.SecurityException: Permission denied (missing INTERNET permission?)
        at com.android.internal…
        at br.com.exemplo.foco_lab.MainActivity…   ← SUA linha
```

A regra da aula 1 vale igual: **procure a primeira linha que menciona o seu pacote**.

### O stack trace do Gradle

O erro de Gradle vem em três partes, e só uma importa:

```text
FAILURE: Build failed with an exception.

* What went wrong:                                     ← ✅ LEIA ESTA
Execution failed for task ':app:mergeDebugResources'.
> Android resource linking failed
  error: resource mipmap/ic_launcher not found.

* Try:                                                 ← ⚠️ genérico, ignore
Run with --stacktrace option to get the stack trace.

* Get more help at https://help.gradle.org

BUILD FAILED in 43s
```

| Parte | Leia? |
|---|---|
| `What went wrong` | ✅ **Sempre.** A causa está aqui |
| A linha `>` indentada | ✅ A causa **real**, mais específica |
| `Try:` | ❌ Texto genérico |
| `BUILD FAILED in 43s` | ❌ Só o tempo |

> 📌 **Leia de baixo para cima dentro do `What went wrong`.** A primeira linha diz *qual tarefa*
> falhou; as linhas indentadas com `>` dizem *por quê*. A última `>` é a causa mais específica —
> e quase sempre a acionável.

Quando o `What went wrong` não basta:

```powershell
flutter build apk --debug -v          # verbose do Flutter
cd android
./gradlew assembleDebug --stacktrace  # stack trace do Gradle
./gradlew assembleDebug --info        # mais detalhe
./gradlew assembleDebug --scan        # relatório na web
```

> ⚠️ `--stacktrace` despeja **centenas** de linhas de Java interno. Não leia tudo: procure a
> primeira linha que menciona **o seu projeto** ou **um plugin**. O resto é encanamento do Gradle.

### Os cinco erros de build Android

**1. Versão do JDK**

```text
Unsupported class file major version 65
```

ou

```text
Dependency ':x' requires 'compileSdkVersion 34' or higher
```

```powershell
flutter doctor -v          # mostra o JDK que o Flutter está usando
java -version
flutter config --jdk-dir "C:\Program Files\Java\jdk-17"
```

> 💡 O Flutter usa o JDK **embutido no Android Studio** por padrão. O `java -version` do seu
> `PATH` pode ser outro — e essa divergência é a causa nº 1 de "funciona no Android Studio e falha
> no terminal".

**2. Cache corrompido**

```text
Could not resolve all files for configuration ':app:debugRuntimeClasspath'
```

A sequência de limpeza, **da mais leve para a mais pesada**:

```powershell
flutter clean
flutter pub get

cd android
./gradlew clean
./gradlew --stop           # mata o daemon do Gradle

# Último recurso: apaga o cache global (baixa tudo de novo, ~10 min)
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches"
```

> ⚠️ **Não comece pelo último.** Apagar `~/.gradle/caches` resolve muita coisa e custa dez minutos
> de download. Tente na ordem.

**3. Conflito de versão de plugin**

```text
Execution failed for task ':app:checkDebugDuplicateClasses'.
> Duplicate class kotlin.collections.jdk8.CollectionsJDK8Kt found
```

```powershell
flutter pub deps           # mostra a árvore de dependências
flutter pub upgrade --major-versions
```

**4. `minSdkVersion` baixo demais**

```text
uses-sdk:minSdkVersion 21 cannot be smaller than version 23
declared in library [:some_plugin]
```

`android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    minSdk = 23   // era flutter.minSdkVersion
}
```

**5. `MissingPluginException`**

```text
MissingPluginException(No implementation found for method
getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
```

Quase sempre o mesmo motivo: você **acrescentou um plugin e fez hot reload**. Plugins têm código
nativo, e código nativo só entra no app num build completo.

```powershell
# Pare o app e rode de novo — NÃO é hot reload
flutter run
```

> 📌 **A regra:** todo `flutter pub add` de um pacote com código nativo exige **parar e rodar de
> novo**. Hot reload e hot restart não recompilam a parte nativa (Módulo 05, aula 8).

### 🍎 iOS: Xcode, CocoaPods e assinatura

> ⚠️ Esta seção **exige macOS**. No Windows não há como compilar nem depurar iOS — veja a seção 🪟
> adiante para o que fazer enquanto isso.

**Abrir no Xcode** — obrigatório quando o erro é de assinatura ou de configuração:

```bash
open ios/Runner.xcworkspace   # .xcworkspace, NÃO .xcodeproj
```

> ⚠️ Abrir o `.xcodeproj` em vez do `.xcworkspace` faz o Xcode ignorar os pods — e o build falha
> com dezenas de "module not found". É o erro nº 1 de quem abre o Xcode pela primeira vez.

**CocoaPods:**

```bash
cd ios
pod install                  # depois de todo pub add
pod repo update              # o índice local está velho
pod deintegrate && pod install   # reinstala do zero
rm Podfile.lock && pod install   # ⚠️ só se souber o que está fazendo
```

| Erro | Causa | Correção |
|---|---|---|
| `CocoaPods not installed` | Falta o CocoaPods | `sudo gem install cocoapods` |
| `Podfile.lock` divergente | Alguém atualizou | `pod install` |
| `Unable to find a specification` | Índice velho | `pod repo update` |
| `platform :ios, '12.0' too low` | Plugin exige mais | Suba no `Podfile` |
| `module 'X' not found` | Abriu o `.xcodeproj` | Abra o `.xcworkspace` |

**Assinatura** — o assunto do Módulo 16:

```text
Signing for "Runner" requires a development team.
```

Xcode → **Runner** → **Signing & Capabilities** → marque *Automatically manage signing* e escolha
o Team. Com conta Apple gratuita, funciona em **aparelho físico por 7 dias** (Módulo 16, aula 6).

**Logs do iOS:**

| Ferramenta | Para quê |
|---|---|
| Xcode → **View → Debug Area** | Log do app rodando pelo Xcode |
| **Window → Devices and Simulators** | Log de um aparelho conectado |
| **Console.app** | Log do sistema; filtre pelo processo |
| `flutter logs` | Só o Dart |
| Xcode → **Report Navigator** | Log completo do último build |

### 🪟 O que dá e o que não dá no Windows

| Tarefa | Windows |
|---|---|
| Build e debug Android | ✅ Completo |
| `adb logcat` | ✅ |
| DevTools | ✅ |
| Testes unitário e widget | ✅ |
| Integração em `-d windows` | ✅ |
| Build iOS | ❌ **Impossível** |
| Xcode | ❌ |
| `pod install` | ❌ |
| Assinar IPA | ❌ |

O que **dá** para fazer pelo iOS a partir do Windows:

1. **Escrever e revisar** o código Dart — ele é o mesmo nas duas plataformas.
2. **Editar `Info.plist`, `Podfile`, `project.pbxproj`** — são arquivos de texto, versionados.
3. **Rodar testes** — unitário, widget e integração em `-d windows`.
4. **Usar CI com runner macOS** — GitHub Actions oferece `macos-latest`; é assim que times sem Mac
   geram IPA (Módulo 17, aula 4).
5. **Codemagic / Bitrise** — serviços com Mac na nuvem, com plano gratuito limitado.

> 💡 **A recomendação prática do curso:** desenvolva em Windows, valide em Android, e use **CI com
> runner macOS** para gerar e validar o build iOS. Não é o mesmo que ter um Mac, mas cobre o
> essencial — e é exatamente o que o Módulo 16 vai detalhar.

### O método de 6 passos para erro de build

1. **Leia o `What went wrong` inteiro**, incluindo as linhas `>`.
2. **Identifique a camada**: Dart, ponte ou nativo?
3. **Pergunte: o que mudou?** Um `pub add`, um update do Flutter, um `git pull`?
4. **Limpe na ordem**: `flutter clean` → `gradlew clean` → `--stop` → cache global.
5. **Aumente o detalhe**: `-v`, `--stacktrace`, e procure **o seu pacote** na saída.
6. **Reproduza isolado**: `flutter create teste_x`, acrescente só o plugin suspeito, e veja se
   falha lá também.

> 📌 **O passo 3 resolve mais casos que os outros cinco juntos.** Build que funcionava e parou de
> funcionar quase sempre tem uma causa recente e identificável — e `git diff` costuma mostrá-la em
> trinta segundos.

O passo 6 é o mais subestimado: se o projeto novo **também** falha, o problema é do plugin ou do
ambiente, não do seu código — e isso corta o espaço de busca pela metade.

---

## 💡 Analogia

Pense num prédio com problema elétrico.

- **A camada Dart** é a lâmpada do seu apartamento. Você vê o defeito: piscou, queimou. A caixa
  vermelha é a lâmpada avisando.
- **A ponte de plugin** é o disjuntor do andar. Nada aparece no apartamento — a luz simplesmente
  não chega. `MissingPluginException` é o disjuntor desarmado.
- **A camada nativa** é a subestação. O apartamento apagou **sem nenhum aviso**, e não há nada
  para ver lá dentro. É preciso descer até o quadro geral — o `logcat`, o Console.app.

E daí saem as lições:

- **"O app fechou sem mensagem"** é o apartamento apagado. Ficar olhando a lâmpada não adianta; o
  problema está dois andares abaixo.
- **O stack trace do Gradle** é o relatório do eletricista: dez páginas de norma técnica e uma
  frase que interessa — "o cabo do apartamento 42 está rompido". O `What went wrong` é essa frase.
- **Limpar na ordem** é o que um eletricista faz: testa a lâmpada, depois o disjuntor, depois o
  quadro — e só então desliga o prédio inteiro. Apagar `~/.gradle/caches` de cara é desligar o
  prédio para trocar uma lâmpada: funciona, e custa o dia de todo mundo.
- **"O que mudou?"** é a primeira pergunta de qualquer diagnóstico. O prédio funcionava ontem.
  Alguém mexeu em alguma coisa.
- **Reproduzir num projeto novo** é levar o aparelho para testar na casa do vizinho. Se lá também
  não liga, o problema é o aparelho, não a fiação.

---

## 🧪 Exemplo mínimo

Um erro real, do começo ao fim.

**O sintoma:** o app abre e fecha imediatamente no emulador. O console do Flutter mostra:

```text
Lost connection to device.
```

Nada mais. Nenhum stack trace, nenhuma caixa vermelha.

**Passo 1 — identificar a camada.** Sem mensagem de Dart = a camada nativa morreu. `flutter logs`
não vai mostrar nada.

**Passo 2 — logcat, do jeito certo:**

```powershell
adb logcat -c                    # limpa
flutter run                      # reproduz
# (o app fecha)
adb logcat -d > erro.txt         # despeja e sai
```

**Passo 3 — procurar o que importa:**

```powershell
Select-String -Path erro.txt -Pattern "FATAL|foco_lab" -Context 2,6
```

```text
E/AndroidRuntime: FATAL EXCEPTION: main
    Process: br.com.exemplo.foco_lab, PID: 9184
    java.lang.RuntimeException: Unable to get provider
      androidx.startup.InitializationProvider:
      java.lang.IllegalStateException: Default FirebaseApp is not initialized
        at android.app.ActivityThread.installProvider(ActivityThread.java:7654)
        at br.com.exemplo.foco_lab.MainActivity.onCreate(MainActivity.kt:12)
```

**Passo 4 — ler a causa**, não o primeiro `RuntimeException`:

> `Default FirebaseApp is not initialized`

**Passo 5 — "o que mudou?"** `git log --oneline -5` mostra um `pub add` de um pacote de analytics
ontem. Ele depende de Firebase e exige o `google-services.json`, que não foi acrescentado.

**Passo 6 — corrigir e validar:**

```powershell
# acrescenta android/app/google-services.json
flutter clean
flutter run
```

> 📌 O passo que economizou a tarde foi o **`-c` antes de reproduzir**. Sem ele, o `erro.txt` teria
> 40 000 linhas de dois dias, e o `FATAL` do dia anterior levaria a investigar o bug errado.

---

## 📱 Aplicando no Flutter

Um script de diagnóstico que reúne tudo o que se pergunta ao abrir um chamado.

---

## 💻 Código completo

> **Arquivo:** `foco_lab/tool/diagnostico.ps1` (novo)
> **Como executar:** `powershell -ExecutionPolicy Bypass -File tool/diagnostico.ps1`

```powershell
# Reúne as informações que TODO relato de erro precisa ter.
# Rode antes de pedir ajuda: as três primeiras perguntas que
# alguém vai fazer já estarão respondidas.

$saida = "diagnostico.txt"
"=== DIAGNÓSTICO — $(Get-Date -Format 'yyyy-MM-dd HH:mm') ===" | Out-File $saida -Encoding utf8

function Secao($titulo, $comando) {
    "`n========== $titulo ==========" | Out-File $saida -Append -Encoding utf8
    try {
        Invoke-Expression $comando 2>&1 | Out-File $saida -Append -Encoding utf8
    } catch {
        "FALHOU: $_" | Out-File $saida -Append -Encoding utf8
    }
}

# 1. Ambiente — resolve metade dos casos sozinho.
Secao "flutter doctor -v" "flutter doctor -v"
Secao "flutter --version" "flutter --version"
Secao "java -version"     "java -version"

# 2. Aparelhos disponíveis.
Secao "flutter devices" "flutter devices"
Secao "adb devices"     "adb devices"

# 3. Dependências — conflito de versão aparece aqui.
Secao "flutter pub deps --style=compact" "flutter pub deps --style=compact"
Secao "pubspec.lock (flutter)" "Select-String -Path pubspec.lock -Pattern 'flutter:' -Context 0,3"

# 4. Configuração Android.
Secao "build.gradle.kts" "Get-Content android/app/build.gradle.kts -ErrorAction SilentlyContinue"
Secao "gradle-wrapper"   "Get-Content android/gradle/wrapper/gradle-wrapper.properties -ErrorAction SilentlyContinue"

# 5. O que mudou recentemente — o passo 3 do método.
Secao "git log -10"   "git log --oneline -10"
Secao "git status"    "git status --short"

# 6. Análise estática.
Secao "flutter analyze" "flutter analyze --no-fatal-infos"

Write-Host ""
Write-Host "Pronto: $saida" -ForegroundColor Green
Write-Host "Anexe este arquivo ao pedir ajuda." -ForegroundColor Green
```

E o roteiro de limpeza, na ordem certa:

> **Arquivo:** `foco_lab/tool/limpar.ps1` (novo)

```powershell
# Limpeza progressiva: da mais leve para a mais pesada.
# Use -Nivel 1 primeiro. Só suba se não resolver.
param([int]$Nivel = 1)

Write-Host "Limpeza nível $Nivel" -ForegroundColor Cyan

# Nível 1 — segundos. Resolve a maioria.
flutter clean
flutter pub get

if ($Nivel -ge 2) {
    # Nível 2 — ~1 min. Cache do Gradle do projeto.
    Write-Host "Nível 2: Gradle do projeto" -ForegroundColor Yellow
    Push-Location android
    ./gradlew clean
    ./gradlew --stop      # mata o daemon, que guarda estado
    Pop-Location
}

if ($Nivel -ge 3) {
    # Nível 3 — ~10 min de download. ÚLTIMO recurso.
    Write-Host "Nível 3: cache GLOBAL (vai baixar tudo de novo)" -ForegroundColor Red
    $r = Read-Host "Tem certeza? (s/N)"
    if ($r -eq 's') {
        Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches" -ErrorAction SilentlyContinue
        Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Pub\Cache" -ErrorAction SilentlyContinue
        flutter pub get
    }
}

Write-Host "Feito. Rode: flutter run" -ForegroundColor Green
```

E um coletor de log Android:

> **Arquivo:** `foco_lab/tool/coletar-log.ps1` (novo)

```powershell
# Coleta o log do crash do jeito certo: limpa ANTES de reproduzir.
param([string]$Pacote = "br.com.exemplo.foco_lab")

Write-Host "1. Limpando o log..." -ForegroundColor Cyan
adb logcat -c

Write-Host "2. Reproduza o erro agora no aparelho." -ForegroundColor Yellow
Write-Host "   Quando o app fechar, aperte ENTER aqui." -ForegroundColor Yellow
Read-Host

Write-Host "3. Coletando..." -ForegroundColor Cyan
adb logcat -d > crash-completo.txt

# Extrai só o que importa — o resto é ruído de outros apps.
Select-String -Path crash-completo.txt `
    -Pattern "FATAL EXCEPTION|$Pacote|AndroidRuntime|flutter" `
    -Context 2,10 | Out-File crash-filtrado.txt -Encoding utf8

Write-Host ""
Write-Host "crash-completo.txt  — tudo" -ForegroundColor Green
Write-Host "crash-filtrado.txt  — leia ESTE primeiro" -ForegroundColor Green
Write-Host ""
Write-Host "Procure por 'FATAL EXCEPTION' e depois pela primeira" -ForegroundColor Gray
Write-Host "linha que mencione $Pacote." -ForegroundColor Gray
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `diagnostico.ps1` | Responde de antemão as três perguntas que alguém faria ao ver seu erro. |
| `flutter doctor -v` primeiro | Resolve metade dos casos sozinho: SDK, JDK, licenças. |
| `java -version` junto | Divergência entre o JDK do `PATH` e o do Android Studio é a causa nº 1 de "funciona no Studio e falha no terminal". |
| `git log --oneline -10` | **O passo 3 do método**: o que mudou? Resolve mais casos que os outros cinco. |
| `flutter pub deps --style=compact` | Conflito de versão de plugin aparece aqui. |
| `limpar.ps1` com `-Nivel` | Impõe a ordem: leve → pesado. Apagar o cache global de cara custa 10 min à toa. |
| `./gradlew --stop` no nível 2 | O daemon guarda estado entre builds; `clean` sozinho não o mata. |
| `Read-Host` de confirmação no nível 3 | Ação cara e irreversível merece uma pergunta. |
| `adb logcat -c` **antes** de reproduzir | Sem isso, você lê o log de ontem e investiga o bug errado. |
| `adb logcat -d` | `-d` despeja e **sai**; sem ele, o comando fica preso mostrando log ao vivo. |
| `Select-String -Context 2,10` | Mostra 2 linhas antes e 10 depois — o stack trace inteiro do crash. |
| Dois arquivos, completo e filtrado | O filtrado para ler; o completo para quando o filtro escondeu algo. |

---

## 🤖🍎 Android × iOS

| Situação | 🤖 Android | 🍎 iOS |
|---|---|---|
| Log do sistema | `adb logcat` | Console.app / Xcode |
| Log só do Flutter | `flutter logs` | `flutter logs` |
| Limpar o log | `adb logcat -c` | Console.app → Clear |
| Build verboso | `./gradlew --stacktrace` | Xcode → Report Navigator |
| Limpar cache | `./gradlew clean` | `pod deintegrate && pod install` |
| Gerenciador nativo | Gradle | CocoaPods / SPM |
| Arquivo de config | `build.gradle.kts` | `project.pbxproj`, `Podfile` |
| Crash nativo | `FATAL EXCEPTION` | Crash report em Devices |
| Assinatura | Keystore (Módulo 15) | Certificado + provisioning (Módulo 16) |
| Dá para fazer no Windows | ✅ Tudo | ❌ Nada |

> ⚠️ **A diferença cultural entre as duas:** o Gradle **diz** o que deu errado, ainda que sob dez
> páginas de log. O Xcode muitas vezes falha com uma mensagem genérica, e o detalhe está escondido
> no **Report Navigator** — a aba com o ícone de seta, canto superior direito do painel esquerdo.
> No iOS, quando a mensagem não fizer sentido, o reflexo certo é abrir o Report Navigator e
> expandir a etapa que falhou.

---

## ⚠️ Erros comuns

### 1. Procurar erro nativo no DevTools

O DevTools só enxerga Dart.

**Correção:** identifique a camada primeiro.

### 2. `adb logcat` sem `-c` antes

Você lê o log de ontem e investiga o bug errado.

**Correção:** `adb logcat -c` → reproduza → `adb logcat -d`.

### 3. Ler o `--stacktrace` inteiro

Centenas de linhas de Java interno.

**Correção:** procure o **seu pacote** ou um plugin.

### 4. Apagar `~/.gradle/caches` de cara

Dez minutos de download para um problema que `flutter clean` resolveria.

**Correção:** limpe na ordem.

### 5. Hot reload depois de `pub add` de plugin nativo

```text
MissingPluginException(No implementation found for method …)
```

**Correção:** pare o app e rode de novo.

### 6. Abrir `.xcodeproj` em vez de `.xcworkspace`

Dezenas de "module not found".

**Correção:** `open ios/Runner.xcworkspace`.

### 7. JDK divergente

Funciona no Android Studio, falha no terminal.

**Correção:** `flutter config --jdk-dir`.

### 8. Ignorar a pergunta "o que mudou?"

Horas investigando algo que `git diff` mostraria em trinta segundos.

**Correção:** passo 3, sempre.

### 9. Ler só a primeira linha do erro do Gradle

A causa real está na última linha `>`.

**Correção:** leia o `What went wrong` inteiro.

### 10. Esquecer `pod install` depois de `pub add`

**Correção:** `cd ios && pod install`.

### 11. Tentar compilar iOS no Windows

Não é limitação do Flutter: a Apple exige macOS.

**Correção:** CI com runner macOS (Módulo 17, aula 4).

### 12. Não isolar num projeto novo

**Correção:** passo 6. Corta o espaço de busca pela metade.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `tool/diagnostico.ps1` e leia o `diagnostico.txt` inteiro. Você entende cada
seção?

**Passo 2.** Compare o JDK do `flutter doctor -v` com o do `java -version`. São o mesmo?

**Passo 3.** Rode `adb logcat -c`, abra o app, feche, e `adb logcat -d > log.txt`. Quantas linhas?

**Passo 4.** Rode o app **sem** `-c` antes. Quantas linhas agora? Dá para achar o que interessa?

**Passo 5.** Provoque um erro: renomeie `android/app/src/main/AndroidManifest.xml`. Rode
`flutter build apk` e leia o `What went wrong`.

**Passo 6.** Rode o mesmo build com `--stacktrace`. Conte as linhas. Quantas são suas?

**Passo 7.** Provoque um `MissingPluginException`: dê `pub add path_provider`, use-o e faça **hot
reload**.

**Passo 8.** Rode `tool/limpar.ps1 -Nivel 1` e cronometre. Depois `-Nivel 2`. Compare.

**Passo 9.** Crie `flutter create teste_isolado`, acrescente um plugin e veja se ele compila. Esse
é o passo 6 do método.

**Passo 10.** Pegue o último erro de build que você teve e aplique os 6 passos por escrito. Em qual
deles você teria achado a causa?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

Faça os de **Diagnóstico** (ler um log de crash) e o de **Reflexão** (quando escalar um problema em
vez de insistir).

---

## 🏆 Desafio opcional

Monte um **playbook de diagnóstico** do seu projeto — um `DEBUG.md` versionado no repositório.

Requisitos:

- Uma tabela: **sintoma → camada provável → primeiro comando**.
- Os cinco erros de build Android desta aula, com a correção testada por você.
- Uma seção 🍎 iOS, mesmo que você não tenha Mac — escrita a partir da documentação, para o dia em
  que precisar.
- Os três scripts de `tool/`, documentados.
- Um "log de incidentes": cada erro real que você enfrentou, com sintoma, causa e correção.

Depois responda: qual dos seus erros teria sido evitado por um **teste** (aulas 5 a 8), e qual só
poderia aparecer em build? Essa divisão diz onde vale investir tempo.

---

## 📌 Resumo

- **Três camadas**: Dart, ponte de plugin, nativo. Cada uma tem sua ferramenta.
- **O primeiro diagnóstico é a camada.** Procurar erro de Gradle no DevTools é perder a tarde.
- App fecha **sem mensagem** = camada nativa morreu. `flutter logs` não mostra; **`adb logcat`** sim.
- **`adb logcat -c` antes de reproduzir**, `-d` para despejar e sair. Sem o `-c`, lê-se o log de
  ontem.
- Num crash nativo, procure **`FATAL EXCEPTION`** e depois a primeira linha com o **seu pacote**.
- No Gradle, leia o **`What went wrong` inteiro**; a última linha `>` é a causa acionável.
- `--stacktrace` despeja centenas de linhas: procure **o seu pacote**, ignore o encanamento.
- **Limpe na ordem**: `flutter clean` → `gradlew clean` → `--stop` → cache global.
- O **JDK do Flutter** pode ser diferente do `PATH` — causa nº 1 de "funciona no Studio".
- **`MissingPluginException`** = plugin nativo com hot reload. Pare e rode de novo.
- 🍎 Abra o **`.xcworkspace`**, nunca o `.xcodeproj`. `pod install` depois de todo `pub add`.
- 🍎 O detalhe do erro do Xcode está no **Report Navigator**.
- 🪟 No Windows: Android completo, iOS **nada**. Use **CI com runner macOS**.
- **Método de 6 passos**: ler → camada → **o que mudou?** → limpar → detalhar → isolar.
- O **passo 3 ("o que mudou?")** resolve mais casos que os outros cinco juntos.

---

## ☑️ Checklist de domínio

- [ ] Identifico a camada antes de escolher a ferramenta.
- [ ] Uso `adb logcat -c` antes de reproduzir.
- [ ] Acho o `FATAL EXCEPTION` e a linha do meu pacote.
- [ ] Leio o `What went wrong` inteiro, até a última linha `>`.
- [ ] Limpo na ordem, do leve para o pesado.
- [ ] Sei checar e ajustar o JDK do Flutter.
- [ ] Reconheço `MissingPluginException` e sei que é hot reload.
- [ ] 🍎 Sei que se abre o `.xcworkspace` e quando rodar `pod install`.
- [ ] 🪟 Sei o que não dá para fazer no Windows e qual é a saída.
- [ ] Pergunto "o que mudou?" antes de investigar.
- [ ] Isolo num projeto novo quando o erro não cede.
- [ ] Tenho scripts de diagnóstico e limpeza no projeto.

---

## 📚 Referências oficiais

- [Debugging Flutter apps — docs.flutter.dev](https://docs.flutter.dev/testing/debugging)
- [Android Studio and IntelliJ — docs.flutter.dev](https://docs.flutter.dev/tools/android-studio)
- [Logcat command-line tool — developer.android.com](https://developer.android.com/tools/logcat)
- [Troubleshooting Gradle builds — developer.android.com](https://developer.android.com/build/troubleshoot)
- [Gradle command-line interface](https://docs.gradle.org/current/userguide/command_line_interface.html)
- [Flutter and iOS — docs.flutter.dev](https://docs.flutter.dev/platform-integration/ios/ios-debugging)
- [CocoaPods Guides](https://guides.cocoapods.org/using/troubleshooting.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo módulo |
|---|---|---|
| [Aula 8 — Testes de integração](08-testes-de-integracao.md) | [README](README.md) | [Módulo 13 — Desempenho e Segurança](../13-desempenho-e-seguranca/README.md) |
