# Aula 10 — Diagnóstico de build

> **Módulo:** 15 - Build e Distribuição Android · **Tempo estimado:** 50 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Aplicar um **método de 6 passos** para qualquer erro de build Android.
- Consultar uma **tabela sintoma → causa → correção** com os erros reais deste módulo.
- Resolver os cinco grandes grupos: **JDK**, **cache**, **versões**, **assinatura** e **R8**.
- Limpar **na ordem certa**, da correção mais barata para a mais cara.
- Isolar um problema num projeto novo para separar "meu código" de "o ambiente".
- Montar um relato de erro que outra pessoa consiga responder.

## ✅ Pré-requisitos

- As aulas 1 a 9 deste módulo — esta é a aula de **referência**, e aponta para todas elas.
- [Módulo 12, aula 9 — Depurando Android e iOS](../12-testes-e-debug/09-depurando-android-e-ios.md)
  — o método de 6 passos aparece lá em forma geral; aqui ele é aplicado só ao build Android.

---

## 📖 Conceito

### O método

1. **Leia o `What went wrong` inteiro**, incluindo cada linha `>`.
2. **Em que etapa falhou?** Gradle, compilação Dart, empacotamento, assinatura ou instalação.
3. **O que mudou?** `pub add`, update do Flutter, `git pull`, troca de máquina.
4. **Limpe na ordem**: `flutter clean` → `gradlew clean` → `--stop` → cache global.
5. **Aumente o detalhe**: `-v`, `--stacktrace`; procure **o seu pacote** na saída.
6. **Isole**: `flutter create teste`, acrescente só o suspeito, veja se falha lá também.

> 📌 **O passo 3 resolve mais casos que os outros cinco juntos.** Um build que funcionava e parou
> tem causa recente, e `git log --oneline -5` costuma mostrá-la em trinta segundos.

E o passo 6 é o mais subestimado: se o projeto novo **também** falha, o problema é do plugin ou do
ambiente — não do seu código. Isso corta o espaço de busca pela metade.

### Em que etapa falhou?

A mensagem diz, se você souber ler:

| A saída menciona | Etapa | Olhe |
|---|---|---|
| `Execution failed for task ':app:…'` | **Gradle** | A linha `>` mais específica |
| `Error: … .dart:42` | **Compilação Dart** | Seu código |
| `mergeDebugResources`, `processRelease…` | **Recursos** | `res/`, ícones, XML |
| `lStripDebugSymbols`, `:app:package…` | **Empacotamento** | ABIs, assets |
| `SigningConfig`, `Keystore` | **Assinatura** | Aula 7 |
| `INSTALL_FAILED_*` | **Instalação** | Aula 9 |
| `Version code … already been used` | **Upload** | `pubspec.yaml` |

### A limpeza, na ordem

```powershell
# Nível 1 — segundos. Resolve a maioria.
flutter clean
flutter pub get

# Nível 2 — ~1 min. O daemon guarda estado entre builds.
cd android
./gradlew clean
./gradlew --stop
cd ..

# Nível 3 — ~10 min de download. ÚLTIMO recurso.
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches"
flutter pub get
```

> ⚠️ **Não comece pelo nível 3.** Ele resolve quase tudo e custa dez minutos de download —
> geralmente para um problema que o nível 1 resolveria em cinco segundos.

---

## 🧯 A tabela

### Grupo 1 — JDK e Java

| Sintoma | Causa | Correção |
|---|---|---|
| `Unsupported class file major version 65` | JDK novo demais para o Gradle | Use o JDK 17: `flutter config --jdk-dir` |
| `Unsupported class file major version 61` | JDK 17 com Gradle velho | Atualize o Gradle wrapper |
| `Could not determine java version` | JDK não encontrado | `flutter doctor -v` mostra qual está em uso |
| Funciona no Android Studio, falha no terminal | **JDK diferente no `PATH`** | `flutter config --jdk-dir "<o do Studio>"` |
| `Android Gradle plugin requires Java 17` | JDK 11 ou 8 | Instale o 17 |

```powershell
flutter doctor -v            # mostra o JDK que o Flutter usa
java -version                # mostra o do PATH — pode ser OUTRO
flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"
```

> 💡 **A divergência entre o JDK do `PATH` e o do Android Studio é a causa nº 1** de "funciona lá e
> não aqui". O Flutter usa o do Studio por padrão; o seu terminal usa o do `PATH`.

### Grupo 2 — Cache e daemon

| Sintoma | Causa | Correção |
|---|---|---|
| `Could not resolve all files for configuration` | Cache corrompido | Limpeza nível 1 → 2 → 3 |
| `Could not create task ':app:…'` | Daemon com estado velho | `./gradlew --stop` |
| Erro some ao recompilar | Build incremental | `flutter clean` |
| `Timeout waiting to lock artifact cache` | Dois Gradles ao mesmo tempo | Feche o Android Studio; `--stop` |
| `No such file: build/app/…` | Build anterior interrompido | `flutter clean` |

### Grupo 3 — Versões e dependências

| Sintoma | Causa | Correção |
|---|---|---|
| `minSdkVersion 21 cannot be smaller than 23` | Plugin exige mais | Suba o `minSdk` (aula 7) |
| `Duplicate class … found in modules` | Duas versões da mesma lib | `flutter pub deps`; alinhe versões |
| `compileSdkVersion 34 or higher` | SDK do projeto antigo | Suba o `compileSdk` |
| `Manifest merger failed` | Dois plugins declaram algo incompatível | `tools:replace` ou `tools:node` (aula 5) |
| `Namespace not specified` | Plugin antigo, AGP novo | Atualize o plugin |
| `Plugin requires newer AGP` | Gradle/AGP velhos | Atualize em `settings.gradle.kts` |

```powershell
flutter pub deps --style=compact     # a árvore inteira
flutter pub upgrade --major-versions # atualiza tudo, inclusive breaking
flutter pub outdated                 # o que está para trás
```

### Grupo 4 — Assinatura

| Sintoma | Causa | Correção |
|---|---|---|
| `Keystore file not found` | ⚠️ **Barra invertida no `storeFile`** | Barras normais (`/`) — aula 7 |
| `Cannot recover key` | Senha da **chave** errada | As duas senhas, corretas |
| `keystore password was incorrect` | Senha do **arquivo** errada | Confira o `key.properties` |
| `Failed to read key … from store` | Alias errado | `keytool -list` mostra o alias |
| `SigningConfig "release" is missing` | Faltou o bloco | Aula 7 |
| Play recusa: "assinado com chave de debug" | `getByName("debug")` no release | Troque para `"release"` |
| `You uploaded an APK signed with a key…` | Chave diferente da registrada | A chave de upload é **uma só** |

> ⚠️ **`Keystore file not found` é quase sempre a barra invertida.** Em `.properties`, `\` é
> caractere de escape: `C:\Users\...` vira um caminho corrompido. A mensagem não menciona isso.

### Grupo 5 — R8 e ofuscação

| Sintoma | Causa | Correção |
|---|---|---|
| Funciona em debug, **quebra em release** | R8 removeu classe usada por reflexão | Regra `-keep` (aula 7) |
| `ClassNotFoundException` só em release | Idem | `-keep class <pacote>.** { *; }` |
| `NoSuchMethodError` só em release | Idem | Idem |
| Stack trace sem número de linha | Faltou `-keepattributes` | `SourceFile,LineNumberTable` |
| `isShrinkResources requires isMinifyEnabled` | Só um dos dois ligado | Ligue os dois |
| Stack trace ilegível | Ofuscado | `flutter symbolize` (módulo 13, aula 7) |
| `symbols file not found` | Símbolos perdidos | ⚠️ **Irreversível** para aquela versão |

### Grupo 6 — Recursos, manifest e assets

| Sintoma | Causa | Correção |
|---|---|---|
| `resource mipmap/ic_launcher not found` | Ícone faltando | Regere (aula 3) |
| `Android resource linking failed` | XML inválido em `res/` | Leia a linha indicada |
| `Duplicate resources` | Dois arquivos com o mesmo nome | Renomeie; ou `excludes` (aula 7) |
| Asset não aparece em release | Não declarado no `pubspec` | `assets:` no `pubspec.yaml` |
| `Unable to load asset` | Caminho errado, ou não versionado | Confira o caminho exato |
| App sem acesso à rede em release | `INTERNET` só no `debug/` manifest | Mova para `main/` (aula 5) |

### Grupo 7 — Instalação e loja

| Sintoma | Causa | Correção |
|---|---|---|
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Assinatura diferente | Desinstale (só em teste!) |
| `INSTALL_FAILED_NO_MATCHING_ABIS` | APK arm64 em emulador x86 | `--target-platform android-x64` |
| `INSTALL_FAILED_VERSION_DOWNGRADE` | Versão mais antiga | `adb install -d` |
| `Version code 15 has already been used` | `versionCode` repetido | Suba o `+N` no `pubspec` |
| `Your app targets API level 33` | `targetSdk` velho | Suba o `targetSdk` |
| `App Bundle contains native code…` | Falta `--split-debug-info` | Envie o `mapping.txt` |

---

## 💡 Analogia

Pense num **mecânico diante de um carro que não liga**.

- **O amador** troca a bateria. Não resolveu? Troca a vela. Não resolveu? Troca o motor de arranque.
  Ao fim da tarde, trocou quatro peças, gastou o dobro, e não sabe qual era o problema — nem se ele
  foi resolvido ou apenas encoberto.
- **O profissional** pergunta primeiro: **"quando parou de funcionar, e o que mudou?"** "Ontem
  passei na revisão." Pronto: o espaço de busca caiu de "o carro inteiro" para "o que o mecânico
  mexeu".
- **Ler o `What went wrong` inteiro** é ouvir o cliente até o fim, em vez de interromper na primeira
  frase. A informação decisiva costuma estar na última linha.
- **Limpar na ordem** é testar o fusível antes de desmontar o painel. `rm -rf ~/.gradle/caches` é
  desmontar o painel.
- **Isolar num projeto novo** é levar a peça ao balcão e testar noutro carro. Se lá também falha, a
  peça é ruim — e você não precisa mais mexer no carro.
- **E a tabela desta aula** é o manual de diagnóstico da oficina. Nenhum mecânico decora todos os
  códigos de erro; ele sabe **onde procurar**. É exatamente para isso que esta aula existe: não para
  ser memorizada, mas para ser consultada.

---

## 🧪 Exemplo mínimo

Três erros reais, resolvidos pelo método.

### Caso 1 — `Keystore file not found`

```text
* What went wrong:
Execution failed for task ':app:validateSigningRelease'.
> Keystore file 'C:\Users\Usu rio\chavesfoco-upload.jks' not found
```

**Passo 1 — ler a linha `>`.** Repare no caminho: `chavesfoco-upload.jks`, sem separador.

**Passo 2 — etapa:** assinatura.

**Passo 3 — o que mudou:** criei o `key.properties` hoje.

**A causa:** barra invertida em `.properties`. O `\c` foi consumido como escape.

```properties
# ❌
storeFile=C:\Users\Usuario\chaves\foco-upload.jks
# ✅
storeFile=C:/Users/Usuario/chaves/foco-upload.jks
```

### Caso 2 — funciona em debug, quebra em release

```text
E/AndroidRuntime: FATAL EXCEPTION: main
    java.lang.ClassNotFoundException: Didn't find class
    "br.com.estudos.foco.modelos.Materia"
```

**Passo 1:** classe não encontrada — mas ela existe.

**Passo 2 — etapa:** execução, só em release.

**Passo 3 — o que mudou:** liguei `isMinifyEnabled = true` ontem.

**A causa:** o R8 removeu a classe por não "vê-la" sendo usada — ela é acessada por reflexão.

```proguard
# android/app/proguard-rules.pro
-keep class br.com.estudos.foco.modelos.** { *; }
```

> 📌 **"Funciona em debug e quebra em release" tem uma lista curta de suspeitos**, e o R8 encabeça.
> Debug não roda o R8; release, sim.

### Caso 3 — `Could not resolve all files`

```text
* What went wrong:
Execution failed for task ':app:checkDebugAarMetadata'.
> Could not resolve all files for configuration ':app:debugRuntimeClasspath'.
   > Could not find androidx.core:core:1.13.0.
```

**Passo 3 — o que mudou:** troquei de rede (o Wi-Fi do escritório bloqueia o repositório).

**Passo 4 — limpeza, na ordem:**

```powershell
flutter clean; flutter pub get           # nível 1 — não resolveu
cd android; ./gradlew --stop; cd ..      # nível 2 — não resolveu
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches"   # nível 3 — resolveu
```

> 💡 Repare que, mesmo tendo a hipótese certa no passo 3, subir os níveis **na ordem** custou dois
> minutos. Começar pelo nível 3 teria custado dez — e nos casos em que a hipótese está errada, a
> ordem economiza muito mais.

---

## 📱 Aplicando no Flutter

Um diagnosticador que aplica o método sozinho e sugere a causa.

---

## 💻 Código completo

> **Arquivo:** `tool/diagnosticar-build.ps1` (novo)
> **Como executar:** `powershell -ExecutionPolicy Bypass -File tool/diagnosticar-build.ps1`

```powershell
# Roda o build, captura a saída e sugere a causa.
#
# Não substitui o método — automatiza os passos 1, 2 e 5, e
# lembra você do passo 3, que é o que mais resolve.

param(
    [ValidateSet('apk', 'appbundle')]
    [string]$Alvo = 'apk',
    [ValidateSet('debug', 'release')]
    [string]$Modo = 'release',
    # Nível de limpeza ANTES de tentar (0 = nenhuma).
    [int]$Limpar = 0
)

$ErrorActionPreference = 'Continue'
$log = 'diagnostico-build.txt'

# ══════════════════════════════════════════════════════════════
# PASSO 3 do método — perguntado ANTES de qualquer coisa,
# porque é o que resolve mais casos.
Write-Host '═══ O QUE MUDOU? ═══' -ForegroundColor Magenta
Write-Host 'Últimos commits:' -ForegroundColor Gray
git log --oneline -5 2>&1 | ForEach-Object { Write-Host "  $_" }

$alterados = git status --short 2>&1
if ($alterados) {
    Write-Host "`nArquivos alterados e não commitados:" -ForegroundColor Gray
    $alterados | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
}
Write-Host ''

# ══════════════════════════════════════════════════════════════
# PASSO 4 — limpeza, na ordem pedida.
if ($Limpar -ge 1) {
    Write-Host 'Limpeza nível 1…' -ForegroundColor Yellow
    flutter clean; flutter pub get
}
if ($Limpar -ge 2) {
    Write-Host 'Limpeza nível 2 (daemon do Gradle)…' -ForegroundColor Yellow
    Push-Location android
    ./gradlew clean 2>&1 | Out-Null
    ./gradlew --stop 2>&1 | Out-Null
    Pop-Location
}
if ($Limpar -ge 3) {
    Write-Host 'Limpeza nível 3 — cache GLOBAL (~10 min de download)' -ForegroundColor Red
    if ((Read-Host 'Tem certeza? (s/N)') -eq 's') {
        Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches" -ErrorAction SilentlyContinue
        flutter pub get
    }
}

# ══════════════════════════════════════════════════════════════
# PASSO 5 — build com detalhe.
Write-Host "`nCompilando ($Alvo, $Modo)…" -ForegroundColor Cyan

$saida = & flutter build $Alvo "--$Modo" -v 2>&1 | Out-String
$saida | Out-File $log -Encoding utf8

if ($LASTEXITCODE -eq 0) {
    Write-Host '✅ Build OK.' -ForegroundColor Green
    exit 0
}

# ══════════════════════════════════════════════════════════════
# PASSOS 1 e 2 — a parte que importa da saída.
Write-Host "`n═══ O QUE DEU ERRADO ═══" -ForegroundColor Red

# O bloco `What went wrong` é a única parte que interessa;
# o resto do -v é encanamento do Gradle.
$bloco = [regex]::Match($saida, '(?s)\* What went wrong:(.+?)(\* Try:|\* Get more help|$)')
if ($bloco.Success) {
    Write-Host $bloco.Groups[1].Value.Trim() -ForegroundColor Yellow
} else {
    $saida -split "`n" | Select-String -Pattern 'error|Error|ERROR|FAILURE' |
        Select-Object -First 15 | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
}

# ══════════════════════════════════════════════════════════════
# A tabela desta aula, em código.
Write-Host "`n═══ CAUSA PROVÁVEL ═══" -ForegroundColor Cyan

$regras = @(
    @{ P = 'Keystore file .* not found'
       C = 'Caminho do keystore inválido'
       S = 'Barra INVERTIDA no storeFile? Em .properties, \ é escape. Use / (Aula 7).' }

    @{ P = 'Cannot recover key'
       C = 'Senha da CHAVE (keyPassword) errada'
       S = 'São duas senhas: store e key. Confira as duas (Aula 6).' }

    @{ P = 'keystore password was incorrect|password.*incorrect'
       C = 'Senha do ARQUIVO (storePassword) errada'
       S = 'Confira o key.properties.' }

    @{ P = 'SigningConfig.*missing|signingConfig.*not'
       C = 'Assinatura não configurada'
       S = 'Crie android/key.properties e o bloco signingConfigs (Aula 7).' }

    @{ P = 'Unsupported class file major version'
       C = 'Versão do JDK incompatível'
       S = 'flutter config --jdk-dir "<JDK 17>". Compare flutter doctor -v com java -version.' }

    @{ P = 'requires Java 17|Java version.*required'
       C = 'JDK antigo'
       S = 'Instale e configure o JDK 17.' }

    @{ P = 'Could not resolve all files|Could not find .*:.*:'
       C = 'Dependência não baixada ou cache corrompido'
       S = 'Limpeza NA ORDEM: -Limpar 1, depois 2, depois 3. E confira a rede.' }

    @{ P = 'Timeout waiting to lock'
       C = 'Dois Gradles ao mesmo tempo'
       S = 'Feche o Android Studio e rode: cd android; ./gradlew --stop' }

    @{ P = 'minSdkVersion.*cannot be smaller'
       C = 'Um plugin exige minSdk maior'
       S = 'Suba o minSdk em android/app/build.gradle.kts (Aula 7).' }

    @{ P = 'Duplicate class'
       C = 'Duas versões da mesma biblioteca'
       S = 'flutter pub deps --style=compact para achar o conflito.' }

    @{ P = 'Manifest merger failed'
       C = 'Conflito entre manifests de plugins'
       S = 'Use tools:replace ou tools:node="remove" (Aula 5).' }

    @{ P = 'Namespace not specified'
       C = 'Plugin antigo com AGP novo'
       S = 'flutter pub upgrade --major-versions.' }

    @{ P = 'resource .* not found|resource linking failed'
       C = 'Recurso faltando ou XML inválido'
       S = 'Ícone: regere (Aula 3). XML: leia a linha indicada.' }

    @{ P = 'Duplicate resources'
       C = 'Arquivos com o mesmo nome'
       S = 'Renomeie, ou use packaging { excludes } (Aula 7).' }

    @{ P = 'shrinkResources.*minifyEnabled|isShrinkResources requires'
       C = 'isShrinkResources sem isMinifyEnabled'
       S = 'Ligue os dois, ou nenhum (Aula 7).' }

    @{ P = 'Execution failed for task .:app:lint'
       C = 'Lint do Android barrou'
       S = 'Leia o relatório em build/app/reports/lint-results-*.html' }

    @{ P = 'OutOfMemoryError|Java heap space'
       C = 'Memória da JVM insuficiente'
       S = 'Em android/gradle.properties: org.gradle.jvmargs=-Xmx4G' }

    @{ P = 'Gradle task assemble.* failed with exit code 1'
       C = 'Falha genérica do Gradle'
       S = 'Rode: cd android; ./gradlew assembleRelease --stacktrace  e procure o SEU pacote.' }
)

$achou = $false
foreach ($r in $regras) {
    if ($saida -match $r.P) {
        Write-Host "  ❌ $($r.C)" -ForegroundColor Red
        Write-Host "     → $($r.S)" -ForegroundColor Yellow
        Write-Host ''
        $achou = $true
    }
}

if (-not $achou) {
    Write-Host '  Nenhum padrão conhecido reconhecido.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  Siga o método (Aula 10):' -ForegroundColor Cyan
    Write-Host "    1. Leia $log inteiro — o bloco What went wrong"
    Write-Host '    2. Identifique a ETAPA (Gradle? Dart? assinatura?)'
    Write-Host '    3. O que mudou? (veja os commits no topo desta saída)'
    Write-Host '    4. Limpe: -Limpar 1 → 2 → 3'
    Write-Host '    5. cd android; ./gradlew assembleRelease --stacktrace'
    Write-Host '    6. flutter create teste_isolado, acrescente só o plugin suspeito'
}

Write-Host "Log completo: $log" -ForegroundColor Cyan
exit 1
```

E o gerador de relato, para quando você precisar pedir ajuda:

> **Arquivo:** `tool/relatar-erro.ps1` (novo)

```powershell
# Gera um relato de erro que outra pessoa consiga responder.
#
# Um pedido de ajuda sem estas informações recebe, invariavelmente,
# as mesmas três perguntas de volta — e você perde um dia.

$saida = 'relato-de-erro.md'

function Bloco($titulo, $comando) {
    "`n## $titulo`n`n``````" | Out-File $saida -Append -Encoding utf8
    try {
        Invoke-Expression $comando 2>&1 | Out-File $saida -Append -Encoding utf8
    } catch {
        "(falhou: $_)" | Out-File $saida -Append -Encoding utf8
    }
    '```' | Out-File $saida -Append -Encoding utf8
}

@"
# Relato de erro de build

**Data:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')

## O que eu estava fazendo

<!-- Ex.: rodando `flutter build appbundle --release` pela primeira vez -->

## O que eu esperava

<!-- -->

## O que aconteceu

<!-- Cole aqui o bloco `* What went wrong:` -->

## O que mudou desde a última vez que funcionou

<!-- ⭐ A pergunta mais importante. Um pub add? Update do Flutter?
     git pull? Troca de máquina? Rede diferente? -->

## O que eu já tentei

- [ ] flutter clean + pub get
- [ ] ./gradlew clean + --stop
- [ ] Apagar ~/.gradle/caches
- [ ] Projeto novo com o mesmo plugin
"@ | Out-File $saida -Encoding utf8

Bloco 'flutter doctor -v' 'flutter doctor -v'
Bloco 'flutter --version' 'flutter --version'
Bloco 'java -version' 'java -version'
Bloco 'Dependências' 'flutter pub deps --style=compact'
Bloco 'build.gradle.kts (app)' 'Get-Content android/app/build.gradle.kts -ErrorAction SilentlyContinue'
Bloco 'gradle-wrapper' 'Get-Content android/gradle/wrapper/gradle-wrapper.properties -ErrorAction SilentlyContinue'
Bloco 'Últimos commits' 'git log --oneline -10'
Bloco 'Arquivos alterados' 'git status --short'

Write-Host "Relato em $saida" -ForegroundColor Green
Write-Host 'Preencha as seções com <!-- --> antes de enviar.' -ForegroundColor Yellow
Write-Host '⚠️ Confira se não há senha ou caminho pessoal no arquivo.' -ForegroundColor Yellow
```

```powershell
.\tool\diagnosticar-build.ps1 -Alvo appbundle -Limpar 1
.\tool\relatar-erro.ps1
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| **`git log` antes do build** | Automatiza o passo 3 — o que mais resolve — e lembra você dele. |
| `-Limpar` com níveis 1, 2, 3 | Impõe a ordem: barato → caro. |
| Confirmação no nível 3 | Dez minutos de download merecem uma pergunta. |
| Extrair só o `What went wrong` | O `-v` despeja centenas de linhas; só esse bloco interessa. |
| Tabela de regras em código | A tabela da aula, executável. |
| Cada regra com **causa** e **sugestão** | "Erro X" sem "faça Y" não ajuda. |
| Referência à aula em cada sugestão | Leva ao contexto completo, não só ao remendo. |
| Fallback com o método escrito | Quando nenhum padrão bate, o método continua valendo. |
| `relatar-erro.ps1` | Responde de antemão as três perguntas que alguém faria. |
| Seção "o que mudou" em destaque | É a que quem responde vai procurar primeiro. |
| Aviso sobre senhas no relato | O `key.properties` não entra, mas caminhos pessoais sim. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Ferramenta de build | Gradle | Xcode + CocoaPods |
| Onde está o detalhe | `--stacktrace`, `--info` | **Report Navigator** |
| Limpeza | `gradlew clean`, `--stop` | `pod deintegrate`, Clean Build Folder |
| Cache | `~/.gradle/caches` | `~/Library/Developer/Xcode/DerivedData` |
| Mensagens | Longas, mas **dizem o quê** | Frequentemente genéricas |
| Diagnosticar no Windows | ✅ | ❌ |

> 💡 **A diferença cultural entre as duas:** o Gradle **diz** o que deu errado, ainda que sob dez
> páginas de log — e é por isso que a tabela desta aula funciona. O Xcode muitas vezes falha com uma
> mensagem genérica, e o detalhe fica escondido no Report Navigator. No iOS, quando a mensagem não
> fizer sentido, o reflexo certo é abrir o Report Navigator e expandir a etapa que falhou. Módulo
> 15, aula 10, traz a tabela equivalente.

🪟 **No Windows**, todo o diagnóstico Android funciona. Para iOS, só via CI com runner macOS — e sem
acesso interativo ao Xcode, o que torna o log do CI a única fonte.

---

## ⚠️ Erros comuns

### 1. Ler só a primeira linha do erro

A causa real está na última linha `>`.

**Correção:** leia o `What went wrong` inteiro.

### 2. Começar pelo nível 3 de limpeza

Dez minutos para um problema de cinco segundos.

**Correção:** na ordem.

### 3. Não perguntar "o que mudou?"

Horas investigando o que `git diff` mostraria.

**Correção:** passo 3, sempre.

### 4. Ler o `--stacktrace` inteiro

Centenas de linhas de Java interno.

**Correção:** procure **o seu pacote**.

### 5. Mudar várias coisas de uma vez

Você não sabe qual funcionou.

**Correção:** uma por vez.

### 6. Não isolar num projeto novo

**Correção:** passo 6 — corta o espaço de busca pela metade.

### 7. Copiar solução da internet sem entender

Resolve hoje, quebra amanhã.

**Correção:** entenda a causa; a tabela aponta a aula.

### 8. Pedir ajuda sem contexto

Recebe as mesmas três perguntas de volta.

**Correção:** `relatar-erro.ps1`.

### 9. Achar que "funciona em debug" significa que está certo

Debug não roda R8, não ofusca, não assina.

**Correção:** valide o release (aula 9).

### 10. Ignorar avisos do Gradle

Viram erros na próxima versão do AGP.

**Correção:** trate os avisos.

### 11. Não anotar a solução

O mesmo erro volta em três meses.

**Correção:** um `DEBUG.md` no projeto.

### 12. Insistir sozinho por horas

**Correção:** trinta minutos sem progresso = peça ajuda, com relato.

---

## 🛠️ Exercício guiado

**Passo 1.** Provoque o caso 1: ponha uma barra invertida no `storeFile` e compile.

**Passo 2.** Rode `diagnosticar-build.ps1`. Ele identificou?

**Passo 3.** Provoque o caso 3: apague uma linha de dependência do `pubspec.yaml`.

**Passo 4.** Renomeie `android/app/src/main/AndroidManifest.xml` e compile. Qual etapa falha?

**Passo 5.** Ponha `minSdk = 19` e compile. Leia a mensagem inteira.

**Passo 6.** Ligue `isShrinkResources` sem `isMinifyEnabled`. Que erro?

**Passo 7.** Rode `./gradlew assembleRelease --stacktrace`. Quantas linhas? Quantas são suas?

**Passo 8.** Crie `flutter create teste_isolado` e acrescente um plugin. Compila?

**Passo 9.** Rode `relatar-erro.ps1` e leia o resultado. Falta alguma informação?

**Passo 10.** Crie um `DEBUG.md` com os erros que você enfrentou neste módulo, com causa e correção.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-android.md](../../exercicios/15-build-android.md)

Faça todos os de **Diagnóstico** — esta aula existe para eles — e o de **Reflexão** sobre quando
escalar um problema.

---

## 🏆 Desafio opcional

Monte o **playbook de build** do seu projeto: um `DEBUG-ANDROID.md` versionado.

Requisitos:

- A tabela sintoma → causa → correção, com **os erros que você realmente enfrentou**.
- Para cada um: a mensagem exata, a causa, a correção e **quanto tempo levou** para resolver.
- Os scripts de `tool/`, documentados.
- Uma seção "ambiente": versões de Flutter, JDK, Gradle e AGP que funcionam juntas no seu projeto.
- Uma seção "o que já tentei e NÃO funcionou" — igualmente valiosa.
- Um procedimento de escalonamento: quando parar de tentar sozinho.

Depois responda: qual erro levou mais tempo, e por quê? A demora foi por falta de informação, por
ter seguido uma pista errada, ou por ter pulado um passo do método?

---

## 📌 Resumo

- **Método de 6 passos**: ler → etapa → **o que mudou?** → limpar → detalhar → isolar.
- O **passo 3** resolve mais casos que os outros cinco juntos.
- Leia o **`What went wrong` inteiro**; a última linha `>` é a causa acionável.
- **Limpe na ordem**: `flutter clean` → `gradlew clean` → `--stop` → cache global.
- **JDK divergente** entre `PATH` e Android Studio é a causa nº 1 de "funciona lá".
- **`Keystore file not found`** é quase sempre a **barra invertida** no `storeFile`.
- **"Funciona em debug, quebra em release"** = R8. Regra `-keep`.
- `isShrinkResources` **exige** `isMinifyEnabled`.
- `INSTALL_FAILED_*` e `Version code already used` têm correções diretas — consulte a tabela.
- **Isole num projeto novo**: separa "meu código" de "o ambiente".
- **Mude uma coisa por vez.**
- Peça ajuda com **relato completo** — sem ele, você recebe perguntas em vez de respostas.
- **Anote a solução**: o mesmo erro volta em três meses.
- 🍎 O Gradle diz o que deu errado; o Xcode esconde no **Report Navigator**.

---

## ☑️ Checklist de domínio

- [ ] Sigo o método de 6 passos.
- [ ] Leio o `What went wrong` inteiro.
- [ ] Identifico a etapa que falhou.
- [ ] Pergunto "o que mudou?" antes de investigar.
- [ ] Limpo na ordem, do barato para o caro.
- [ ] Sei checar e ajustar o JDK.
- [ ] Reconheço os erros de assinatura pela mensagem.
- [ ] Sei que release quebrado com debug funcionando é R8.
- [ ] Isolo num projeto novo quando o erro não cede.
- [ ] Mudo uma coisa por vez.
- [ ] Sei montar um relato de erro completo.
- [ ] Anoto as soluções num `DEBUG.md`.

---

## 📚 Referências oficiais

- [Troubleshooting Gradle builds — developer.android.com](https://developer.android.com/build/troubleshoot)
- [Gradle command-line interface](https://docs.gradle.org/current/userguide/command_line_interface.html)
- [Build and release an Android app — docs.flutter.dev](https://docs.flutter.dev/deployment/android)
- [Flutter — Common Flutter errors](https://docs.flutter.dev/testing/common-errors)
- [Android Gradle plugin release notes](https://developer.android.com/build/releases/gradle-plugin)
- [Shrink, obfuscate, and optimize — developer.android.com](https://developer.android.com/build/shrink-code)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo módulo |
|---|---|---|
| [Instalando e validando](09-instalando-e-validando.md) | [README](README.md) | [Módulo 16 — Build iOS](../16-build-ios/README.md) |
