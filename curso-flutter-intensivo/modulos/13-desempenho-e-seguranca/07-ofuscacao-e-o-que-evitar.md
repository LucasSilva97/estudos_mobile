# Aula 7 — Ofuscação e o que evitar

> **Módulo:** 13 - Desempenho e Segurança · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Usar **`--obfuscate`** e **`--split-debug-info`** corretamente — e entender o que cada um faz.
- Reverter um stack trace ilegível com **`flutter symbolize`**.
- Guardar os **símbolos** de cada release, e saber por que perdê-los é irreversível.
- Entender o que o **R8/ProGuard** faz no Android e quando escrever regras `-keep`.
- Reconhecer as **más práticas** que anulam tudo o que o módulo ensinou.
- Aplicar o **checklist final** antes de publicar.

## ✅ Pré-requisitos

- [Aula 6 — Segurança mobile](06-seguranca-mobile.md) — **essencial**: a regra nº 1 e a prova do
  APK extraído.
- [Aula 4 — Medindo desempenho](04-medindo-desempenho.md) — `--analyze-size`.
- [Módulo 12, aula 1 — Lendo stack traces](../12-testes-e-debug/01-lendo-stack-traces.md) — é o que
  a ofuscação torna ilegível.
- [Módulo 12, aula 9 — Depurando Android e iOS](../12-testes-e-debug/09-depurando-android-e-ios.md).

---

## 📖 Conceito

### O que a ofuscação faz — e o que não faz

```powershell
flutter build apk --release --obfuscate --split-debug-info=build/simbolos/1.2.0
```

| Faz | **Não** faz |
|---|---|
| Troca nomes de classes, métodos e campos por `a`, `b`, `c` | Esconder strings literais |
| Dificulta entender a lógica em engenharia reversa | Impedir a extração do APK |
| Reduz um pouco o tamanho | Tornar a URL da API secreta |
| Remove nomes do binário | Proteger chave de API |

```dart
// Antes
class CofreToken {
  Future<void> salvarTokenDeAcesso(String token) async { … }
}

// Depois da ofuscação, no binário:
class a {
  Future<void> b(String c) async { … }
}
```

```powershell
# Mas as STRINGS continuam intactas:
strings libapp.so | Select-String "sk_live"
# sk_live_ABC123        ← ⚠️ ofuscação não muda isto
```

> 📌 **A ofuscação é uma camada de atrito, não uma proteção.** Ela faz o trabalho de quem quer
> entender o seu código passar de uma hora para um dia. Não faz de zero para infinito. Toda a regra
> nº 1 da aula 6 continua valendo: **se a chave é secreta, ela mora no servidor**.

### O preço: o stack trace vira ruído

Este é o custo real, e quem não se prepara paga caro:

```text
#0      a.b (package:foco/a.dart:1:1)
#1      c.d (package:foco/b.dart:1:1)
#2      e.f.<anonymous closure> (package:foco/c.dart:1:1)
```

Um crash em produção fica assim. Sem os símbolos, **é impossível saber o que quebrou**.

```powershell
flutter symbolize -i crash.txt -d build/simbolos/1.2.0/app.android-arm64.symbols
```

```text
#0      CofreToken.salvarTokenDeAcesso (package:foco/core/seguranca/cofre_token.dart:47:5)
#1      LoginController.entrar (package:foco/features/auth/login_controller.dart:88:20)
#2      _LoginScreenState._aoTocarEntrar.<anonymous closure> (package:foco/…:132:7)
```

> ⚠️ **Os símbolos são gerados a cada build, e são únicos daquele build.** Os símbolos da versão
> 1.2.0 não decifram um crash da 1.2.1. Perdeu os símbolos de uma versão que já está na loja? Os
> crashes dela são **permanentemente ilegíveis**. Não há como regerar: recompilar produz um binário
> diferente.

### Guardar os símbolos

```text
simbolos/
├── 1.2.0+42/
│   ├── app.android-arm64.symbols
│   ├── app.android-arm.symbols
│   ├── app.android-x64.symbols
│   └── app.ios-arm64.symbols
├── 1.2.1+43/
└── …
```

| Onde guardar | Veredito |
|---|---|
| No Git do projeto | ❌ Arquivos grandes, e o repo incha |
| Artefato do CI | ✅ **O melhor** — automático, versionado |
| Armazenamento em nuvem da equipe | ✅ Bom, se houver disciplina |
| Só na sua máquina | ❌ Um HD queimado = crashes ilegíveis |
| Em lugar nenhum | ❌ Você vai se arrepender |

> 💡 **Automatize.** Símbolos que dependem de alguém lembrar de copiar vão se perder — não é
> questão de se, é de quando. Um passo no CI que arquiva a pasta após cada build de release
> resolve para sempre.

E o Crashlytics (ou similar) faz isso por você:

```powershell
# Envia os símbolos junto, e os crashes já chegam legíveis no painel.
firebase crashlytics:symbols:upload --app=<APP_ID> build/simbolos/1.2.0
```

### R8 e ProGuard no Android

Além da ofuscação do Dart, o Android tem a sua própria, para o código **Java/Kotlin** (o seu e o
dos plugins):

```kotlin
// android/app/build.gradle.kts
android {
    buildTypes {
        release {
            isMinifyEnabled = true        // R8: remove código não usado e ofusca
            isShrinkResources = true      // remove recursos não usados
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}
```

| Flag | O que faz |
|---|---|
| `isMinifyEnabled` | Remove código morto e ofusca nomes Java/Kotlin |
| `isShrinkResources` | Remove imagens e layouts não referenciados |
| `proguardFiles` | Onde ficam as regras `-keep` |

O R8 remove o que **acha** que não é usado — e ele erra quando o código é chamado por **reflexão**:

```proguard
# android/app/proguard-rules.pro

# O Flutter precisa destas.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ⚠️ Classes acessadas por reflexão: o R8 não as "vê" sendo
# usadas e as remove. O app compila e quebra em EXECUÇÃO,
# só em release.
-keep class com.exemplo.foco.modelos.** { *; }

# Mantém os nomes de linha nos stack traces nativos.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
```

> ⚠️ **O sintoma clássico do R8**: o app funciona em debug, funciona em profile, e **quebra em
> release** com `ClassNotFoundException` ou `NoSuchMethodError`. Quase sempre é uma classe removida
> por não parecer usada. A correção é uma regra `-keep`.

> 💡 A maioria dos plugins publica as regras necessárias no próprio pacote — você não precisa
> escrever nada. Só entre nesse arquivo quando um erro de release apontar para lá.

### O que evitar — as más práticas

Estas anulam o que o módulo inteiro ensinou:

| Prática | Por quê é ruim | Em vez disso |
|---|---|---|
| **Otimizar sem medir** | Complexidade sem ganho | Meça (aula 4) |
| `const` em tudo, por reflexo | Ruído; o ganho é pontual | Onde o rebuild dói (aula 1) |
| **`Opacity` para esconder** | Força `saveLayer` | `Visibility`, ou não construir |
| `ListView(children:)` com dados | Congela | `.builder` (aula 2) |
| Imagem sem `cacheWidth` | Mata o app | Dimensione (aula 2) |
| **Isolate para tudo** | Custa 50–200 ms criar | Só acima de ~50 ms (aula 3) |
| Cálculo dentro do `build` | Roda a cada quadro | Calcule uma vez |
| `setState` na raiz | Reconstrói a árvore inteira | Estado no menor escopo |
| **Chave secreta no app** | Pública | No servidor (aula 6) |
| `rawQuery` interpolado | Injeção | `whereArgs` (aula 6) |
| Token em `SharedPreferences` | Vai para o backup | Cofre do sistema |
| **`print` de dado sensível** | Logcat é público | Registre o evento |
| `NSAllowsArbitraryLoads: true` | Desliga a proteção | Libere só o host local |
| **Ignorar acessibilidade** | Exclui pessoas, e é lei | `tooltip` desde o início (aula 5) |
| Medir em debug | Números inválidos | `--profile` (aula 4) |
| Publicar sem `--obfuscate` | Código legível | Ofusque **e guarde os símbolos** |
| **Ofuscar sem guardar símbolos** | Crashes ilegíveis para sempre | Arquive no CI |

> 📌 **A pior das dezessete é a última**, porque ela se disfarça de boa prática. Você fez a coisa
> certa (ofuscar), sente que o app está mais seguro — e descobre o problema seis meses depois,
> quando um crash chega do campo e não há como lê-lo.

### O tamanho final

```powershell
flutter build appbundle --release --obfuscate --split-debug-info=build/simbolos/1.2.0
flutter build appbundle --analyze-size
```

| Técnica | Redução típica |
|---|---|
| **AAB em vez de APK universal** | **30–40 %** |
| `--split-per-abi` (se for APK) | ~30 % |
| `isShrinkResources` | 5–15 % |
| Imagens em WebP | 25–35 % das imagens |
| Só os pesos de fonte usados | 1–3 MB |
| `--obfuscate` | 1–3 % |

> 💡 **O AAB sozinho rende mais que todo o resto junto.** É uma mudança de comando, sem alteração
> no código. Módulo 15, aula 8.

---

## 💡 Analogia

Pense num **cofre e na planta do prédio**.

- **A ofuscação** é rasurar os nomes das salas na planta. "Tesouraria" vira "Sala A", "Arquivo
  morto" vira "Sala B". Quem invadir ainda entra em todas as salas — só leva mais tempo para achar
  a que interessa. **Não é uma tranca; é neblina.**
- **E a neblina não esconde o que está escrito nas paredes.** As strings continuam legíveis: a
  chave pintada no muro segue lá, em letras garrafais, na Sala A.
- **Os símbolos são a planta original**, a única cópia que relaciona "Sala A" com "Tesouraria".
  Perdeu essa cópia? Quando o alarme disparar na Sala A, ninguém sabe onde é a Sala A. E **a planta
  de cada prédio é diferente** — a de 2024 não serve para o prédio de 2025.
- **O R8** é o zelador que remove o que parece não ser usado. Eficiente, e ocasionalmente joga fora
  o gerador de emergência porque nunca viu ninguém ligá-lo. As regras `-keep` são o bilhete: "não
  mexa nisto".
- **E a lista de más práticas** é a diferença entre um prédio bem construído e um cheio de puxadinho.
  Nenhum puxadinho derruba o prédio sozinho. Quinze deles, sim.

---

## 🧪 Exemplo mínimo

O ciclo completo: ofuscar, quebrar, decifrar.

**Passo 1 — um erro de propósito:**

```dart
// lib/main.dart
void _provocarErro() {
  final List<int> lista = <int>[1, 2, 3];
  debugPrint('${lista[10]}');   // RangeError
}
```

**Passo 2 — build ofuscado:**

```powershell
flutter build apk --release `
  --obfuscate `
  --split-debug-info=build/simbolos/1.0.0
```

```text
build/simbolos/1.0.0/
├── app.android-arm64.symbols
├── app.android-arm.symbols
└── app.android-x64.symbols
```

**Passo 3 — instale e provoque o erro:**

```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb logcat -c
# (toque no botão que provoca o erro)
adb logcat -d > crash.txt
```

```text
E/flutter: RangeError (index): Invalid value: Not in inclusive range 0..2: 10
E/flutter: #0      a.c (package:foco_desempenho/b.dart:1:1)
E/flutter: #1      d.e.<anonymous closure> (package:foco_desempenho/f.dart:1:1)
```

**Passo 4 — decifre:**

```powershell
flutter symbolize -i crash.txt -d build/simbolos/1.0.0/app.android-arm64.symbols
```

```text
#0      _provocarErro (package:foco_desempenho/main.dart:42:24)
#1      _InicioState.build.<anonymous closure> (package:foco_desempenho/main.dart:78:31)
```

**Passo 5 — a lição:**

```powershell
# Apague os símbolos e tente de novo:
Remove-Item -Recurse build/simbolos/1.0.0
flutter symbolize -i crash.txt -d build/simbolos/1.0.0/app.android-arm64.symbols
```

```text
Error: symbols file not found
```

> 📌 **Faça o passo 5.** Ver o "não há como decifrar" com os próprios olhos fixa a lição melhor que
> qualquer aviso: os símbolos **não são regeráveis**. Recompilar produz outro binário, com outro
> mapeamento.

---

## 📱 Aplicando no Flutter

Um script que faz o build de release inteiro, com os símbolos arquivados automaticamente.

---

## 💻 Código completo

> **Arquivo:** `foco_desempenho/tool/build-release.ps1` (novo)
> **Como executar:** `powershell -ExecutionPolicy Bypass -File tool/build-release.ps1 -Ambiente prod`

```powershell
# Build de release completo, com os símbolos arquivados.
#
# O ponto deste script é UM: tornar impossível esquecer de
# guardar os símbolos. Símbolos que dependem de alguém lembrar
# de copiar vão se perder.

param(
    [ValidateSet('dev', 'prod')]
    [string]$Ambiente = 'prod',

    [ValidateSet('apk', 'aab')]
    [string]$Formato = 'aab'
)

$ErrorActionPreference = 'Stop'

# ── 1. Versão: vem do pubspec, é a identidade do build ──────────
$linha = Select-String -Path pubspec.yaml -Pattern '^version:\s*(.+)$'
if (-not $linha) { throw 'Não achei a versão no pubspec.yaml' }
$versao = $linha.Matches[0].Groups[1].Value.Trim()

Write-Host "Versão: $versao  ·  Ambiente: $Ambiente  ·  Formato: $Formato" -ForegroundColor Cyan

# ── 2. A configuração do ambiente precisa existir ───────────────
$config = "config/$Ambiente.json"
if (-not (Test-Path $config)) {
    throw "Falta $config. Copie de config/exemplo.json e preencha."
}

# ── 3. Limpeza: build de release nunca reaproveita cache ────────
Write-Host "`nLimpando..." -ForegroundColor Yellow
flutter clean
flutter pub get

# ── 4. Portões de qualidade — ANTES de gerar o artefato ─────────
# Descobrir um teste quebrado depois de publicar é tarde demais.
Write-Host "`nAnalisando..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze falhou' }

Write-Host "`nTestando..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) { throw 'Testes falharam' }

# ── 5. A pasta de símbolos, por versão ──────────────────────────
# Os símbolos são ÚNICOS deste build: os da 1.2.0 não decifram
# um crash da 1.2.1.
$simbolos = "simbolos/$versao"
New-Item -ItemType Directory -Force -Path $simbolos | Out-Null

# ── 6. O build ──────────────────────────────────────────────────
Write-Host "`nCompilando $Formato..." -ForegroundColor Yellow

$argumentos = @(
    'build', $Formato,
    '--release',
    "--dart-define-from-file=$config",
    '--obfuscate',
    "--split-debug-info=$simbolos"
)

& flutter @argumentos
if ($LASTEXITCODE -ne 0) { throw 'Build falhou' }

# ── 7. Confirma que os símbolos saíram ──────────────────────────
# Sem esta verificação, um build sem símbolos passaria despercebido —
# e os crashes dessa versão seriam ilegíveis PARA SEMPRE.
$gerados = Get-ChildItem $simbolos -Filter '*.symbols' -ErrorAction SilentlyContinue
if (-not $gerados) {
    throw "NENHUM símbolo foi gerado! Os crashes desta versão seriam ilegíveis."
}

Write-Host "`nSímbolos em $simbolos :" -ForegroundColor Green
$gerados | ForEach-Object {
    $mb = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  $($_.Name)  ($mb MB)"
}

# ── 8. Tamanho do artefato ──────────────────────────────────────
$artefato = if ($Formato -eq 'aab') {
    'build/app/outputs/bundle/release/app-release.aab'
} else {
    'build/app/outputs/flutter-apk/app-release.apk'
}

if (Test-Path $artefato) {
    $mb = [math]::Round((Get-Item $artefato).Length / 1MB, 2)
    $cor = if ($mb -gt 50) { 'Red' } elseif ($mb -gt 30) { 'Yellow' } else { 'Green' }
    Write-Host "`nArtefato: $artefato  ($mb MB)" -ForegroundColor $cor
    if ($mb -gt 30) {
        Write-Host "  Acima de 30 MB: rode --analyze-size e revise os assets." -ForegroundColor Yellow
    }
}

# ── 9. Lembrete final ───────────────────────────────────────────
Write-Host "`n─────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "GUARDE a pasta $simbolos fora desta máquina." -ForegroundColor Cyan
Write-Host "Sem ela, nenhum crash desta versão será legível." -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────" -ForegroundColor Cyan
```

E o decifrador:

> **Arquivo:** `foco_desempenho/tool/decifrar.ps1` (novo)

```powershell
# Decifra um stack trace ofuscado.
#
# Uso:
#   .\tool\decifrar.ps1 -Arquivo crash.txt -Versao 1.2.0

param(
    [Parameter(Mandatory)][string]$Arquivo,
    [Parameter(Mandatory)][string]$Versao,
    [ValidateSet('android-arm64', 'android-arm', 'android-x64', 'ios-arm64')]
    [string]$Arquitetura = 'android-arm64'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Arquivo)) { throw "Não achei $Arquivo" }

$simbolo = "simbolos/$Versao/app.$Arquitetura.symbols"

if (-not (Test-Path $simbolo)) {
    Write-Host "Não achei $simbolo" -ForegroundColor Red
    Write-Host "`nVersões disponíveis:" -ForegroundColor Yellow
    Get-ChildItem simbolos -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Write-Host "  $($_.Name)" }
    Write-Host "`n⚠️ A versão do símbolo precisa ser EXATAMENTE a que" -ForegroundColor Yellow
    Write-Host "   gerou o crash. Símbolos de outra versão não servem." -ForegroundColor Yellow
    throw 'Símbolo não encontrado'
}

Write-Host "Decifrando com $simbolo`n" -ForegroundColor Cyan
flutter symbolize -i $Arquivo -d $simbolo
```

E o checklist executável, para rodar antes de publicar:

> **Arquivo:** `foco_desempenho/tool/checklist-release.ps1` (novo)

```powershell
# Verifica as más práticas do módulo 13, automaticamente.
# Não substitui revisão humana — pega o que dá para pegar sozinho.

$problemas = @()
$avisos = @()

function Procurar($padrao, $mensagem, [switch]$Aviso) {
    $achados = Get-ChildItem lib -Recurse -Filter '*.dart' |
        Select-String -Pattern $padrao
    if ($achados) {
        $texto = "$mensagem ($($achados.Count) ocorrência(s))"
        $achados | Select-Object -First 3 | ForEach-Object {
            $texto += "`n      $($_.Path -replace [regex]::Escape($PWD), '.'):$($_.LineNumber)"
        }
        if ($Aviso) { $script:avisos += $texto } else { $script:problemas += $texto }
    }
}

Write-Host 'Verificando…' -ForegroundColor Cyan

# ── Segurança (aula 6) ──────────────────────────────────────────
Procurar 'sk_live|sk_test|AKIA[0-9A-Z]{16}' 'Possível chave secreta no código'
Procurar 'rawQuery\(.*\$' 'rawQuery com interpolação: injeção de SQL'
Procurar 'print\(.*[Tt]oken|print\(.*senha' 'Dado sensível em print'
Procurar "setString\('token'" 'Token em SharedPreferences'

# ── Desempenho (aulas 1 a 4) ────────────────────────────────────
Procurar 'ListView\(\s*$' 'ListView(children:) — confira se a lista é fixa' -Aviso
Procurar 'Opacity\(' 'Opacity força saveLayer — confira se é necessário' -Aviso
Procurar 'Image\.(asset|network)\((?!.*cacheWidth)' 'Imagem sem cacheWidth' -Aviso

# ── Configuração ────────────────────────────────────────────────
if (Select-String -Path 'ios/Runner/Info.plist' -Pattern 'NSAllowsArbitraryLoads' -Quiet -ErrorAction SilentlyContinue) {
    $problemas += 'NSAllowsArbitraryLoads presente no Info.plist'
}
if (-not (Select-String -Path '.gitignore' -Pattern 'key.properties' -Quiet -ErrorAction SilentlyContinue)) {
    $problemas += '.gitignore não cobre android/key.properties'
}
if (-not (Test-Path 'simbolos')) {
    $avisos += 'Pasta simbolos/ não existe — você vai ofuscar sem guardar?'
}

# ── Relatório ───────────────────────────────────────────────────
Write-Host ''
if ($problemas.Count -eq 0 -and $avisos.Count -eq 0) {
    Write-Host '✅ Nada encontrado.' -ForegroundColor Green
}

foreach ($p in $problemas) { Write-Host "❌ $p" -ForegroundColor Red }
foreach ($a in $avisos)    { Write-Host "⚠️  $a" -ForegroundColor Yellow }

Write-Host "`n$($problemas.Count) problema(s), $($avisos.Count) aviso(s)"
if ($problemas.Count -gt 0) { exit 1 }
```

```powershell
.\tool\checklist-release.ps1
.\tool\build-release.ps1 -Ambiente prod -Formato aab
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Versão lida do `pubspec.yaml` | A versão é a **identidade** do build e dos símbolos. |
| Falhar se falta `config/$Ambiente.json` | Melhor quebrar aqui do que publicar apontando para o servidor errado. |
| `flutter analyze` + `flutter test` **antes** do build | Descobrir teste quebrado depois de publicar é tarde demais. |
| `simbolos/$versao/` | Símbolos são **únicos** daquele build: os da 1.2.0 não servem para a 1.2.1. |
| **Verificar que os símbolos saíram** | Sem isso, um build sem símbolos passaria despercebido — e seria irreversível. |
| Aviso de tamanho acima de 30 MB | Tamanho afasta usuário; o alerta força a decisão. |
| Lembrete final em destaque | O passo mais esquecido merece a última palavra do script. |
| `decifrar.ps1` listando as versões disponíveis | O erro mais comum é usar o símbolo da versão errada. |
| `checklist-release.ps1` | Automatiza o que dá para automatizar da lista de más práticas. |
| Separação **problema** × **aviso** | Chave secreta bloqueia; `Opacity` pede revisão humana. |
| `exit 1` com problemas | Permite usar o script como portão no CI. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Ofuscar Dart | `--obfuscate` | idem |
| Ofuscar nativo | R8/ProGuard | ⚠️ Não há equivalente |
| Símbolos | `app.android-*.symbols` | `app.ios-arm64.symbols` + dSYM |
| Formato de publicação | **AAB** | IPA |
| Extrair o app | Trivial (ZIP) | Exige jailbreak |
| Redução de tamanho | AAB: 30–40 % | App Thinning, automático |

> 🍎 **O iOS tem dois conjuntos de símbolos**: os do Dart (`--split-debug-info`) e os **dSYM** do
> Xcode, para o código nativo. Os dois precisam ser guardados. O Xcode Organizer arquiva os dSYM
> automaticamente a cada *archive*, e é de lá que você os envia para o Crashlytics. Módulo 16.

🪟 **No Windows**, você faz todo o ciclo Android: ofuscar, arquivar, decifrar. Para iOS, o build é
no CI com runner macOS — e o passo de arquivar os símbolos precisa estar **no script do CI**, senão
eles somem junto com a máquina temporária ao fim da execução.

---

## ⚠️ Erros comuns

### 1. Ofuscar sem `--split-debug-info`

```powershell
flutter build apk --release --obfuscate   # ❌ os símbolos se perdem
```

**Correção:** os dois sempre juntos.

### 2. Não guardar os símbolos

Crashes ilegíveis para sempre.

**Correção:** arquive no CI, por versão.

### 3. Usar o símbolo da versão errada

Sai lixo, ou nada.

**Correção:** símbolo da **mesma** versão.

### 4. Achar que ofuscação esconde strings

**Correção:** não esconde. Aula 6.

### 5. Achar que ofuscação é segurança

**Correção:** é atrito, não proteção.

### 6. `isMinifyEnabled` sem regras `-keep`

Funciona em debug, quebra em release.

**Correção:** `-keep` para classes usadas por reflexão.

### 7. Publicar APK universal

30–40 % maior.

**Correção:** AAB.

### 8. Testar só em debug antes de publicar

O R8 só age em release.

**Correção:** instale e teste o build de release.

### 9. Versionar os símbolos no Git

Repositório incha.

**Correção:** artefato do CI.

### 10. `--obfuscate` no build de debug

Não faz nada; só atrapalha.

**Correção:** só em release.

### 11. Esquecer os dSYM no iOS

Crashes nativos ilegíveis.

**Correção:** guarde os dois conjuntos.

### 12. Achar que o checklist automático basta

Ele pega padrões, não decisões.

**Correção:** revisão humana também.

---

## 🛠️ Exercício guiado

**Passo 1.** Provoque um `RangeError` e compile com `--obfuscate --split-debug-info`.

**Passo 2.** Instale, provoque o erro, e colete com `adb logcat -d > crash.txt`.

**Passo 3.** Leia o stack trace. Dá para entender alguma coisa?

**Passo 4.** Rode `flutter symbolize`. Agora dá?

**Passo 5.** Apague os símbolos e tente decifrar de novo. Leia o erro.

**Passo 6.** Recompile (gerando símbolos novos) e tente decifrar o crash **antigo** com eles.

**Passo 7.** Compare o tamanho do APK com e sem `--obfuscate`.

**Passo 8.** Gere um AAB e compare com o APK universal.

**Passo 9.** Rode `tool/checklist-release.ps1`. O que ele achou?

**Passo 10.** Ponha `const String k = 'sk_live_X';` no código e rode o checklist. Ele pega?

---

## 📝 Exercícios independentes

→ Exercícios completos em
[exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md)

Faça o de **Aplicação** (script de build), o de **Diagnóstico** (decifrar um crash) e o de
**Reflexão** (revisar o seu projeto contra a lista de más práticas).

---

## 🏆 Desafio opcional

Monte o **pipeline de release completo** no GitHub Actions.

Requisitos:

- Dispara ao criar uma tag `v*`.
- Roda `analyze`, `test` e o `checklist-release`; falha o build se houver problema.
- Gera o AAB com `--obfuscate --split-debug-info`.
- **Arquiva os símbolos** como artefato, nomeados pela versão, com retenção de 90 dias ou mais.
- Publica o AAB como artefato (ou envia para a faixa interna da Play Console).
- Comenta no release do GitHub o tamanho do artefato e o diff em relação ao release anterior.

Depois responda: por que a retenção dos símbolos precisa ser **maior** que o tempo em que a versão
fica na loja? E o que acontece se um usuário com a versão 1.0.0 relatar um crash dois anos depois?

---

## 📌 Resumo

- **`--obfuscate` e `--split-debug-info` andam sempre juntos.** Um sem o outro é armadilha.
- A ofuscação troca **nomes** por `a`, `b`, `c`. **Não esconde strings, URLs nem chaves.**
- É **atrito, não proteção**: aumenta o custo de entender o código, não o torna impossível.
- O preço é o **stack trace ilegível**; `flutter symbolize` reverte.
- **Os símbolos são únicos de cada build.** Os da 1.2.0 não decifram um crash da 1.2.1.
- **Perdeu os símbolos = crashes daquela versão ilegíveis para sempre.** Não há como regerar.
- Guarde-os como **artefato do CI**, por versão — nunca só na sua máquina.
- **R8/ProGuard** ofusca o Java/Kotlin e remove código morto; classes usadas por **reflexão** exigem
  `-keep`.
- Sintoma do R8: funciona em debug, **quebra em release**.
- **AAB rende mais que todo o resto junto**: 30–40 % de redução, só trocando o comando.
- A pior má prática é **ofuscar sem guardar os símbolos** — porque se disfarça de boa prática.
- 🍎 O iOS tem **dois** conjuntos de símbolos: os do Dart e os **dSYM** do Xcode.
- Teste o build de **release** antes de publicar: o R8 só age nele.

---

## ☑️ Checklist de domínio

- [ ] Uso `--obfuscate` com `--split-debug-info`, sempre juntos.
- [ ] Guardo os símbolos por versão, fora da minha máquina.
- [ ] Sei decifrar um crash com `flutter symbolize`.
- [ ] Sei que símbolo de outra versão não serve.
- [ ] Entendo que ofuscação não esconde strings.
- [ ] Sei o que R8 faz e quando escrever `-keep`.
- [ ] Testo o build de release antes de publicar.
- [ ] Publico AAB, não APK universal.
- [ ] Meu script de build arquiva os símbolos automaticamente.
- [ ] Revisei o projeto contra a lista de más práticas.
- [ ] 🍎 Sei que preciso guardar também os dSYM.

---

## 📚 Referências oficiais

- [Obfuscating Dart code — docs.flutter.dev](https://docs.flutter.dev/deployment/obfuscate)
- [flutter symbolize — docs.flutter.dev](https://docs.flutter.dev/deployment/obfuscate#read-an-obfuscated-stack-trace)
- [Shrink, obfuscate, and optimize — developer.android.com](https://developer.android.com/build/shrink-code)
- [Android App Bundle — developer.android.com](https://developer.android.com/guide/app-bundle)
- [Measuring your app's size — docs.flutter.dev](https://docs.flutter.dev/perf/app-size)
- [Performance best practices — docs.flutter.dev](https://docs.flutter.dev/perf/best-practices)
- [Crashlytics — Get deobfuscated crash reports](https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo módulo |
|---|---|---|
| [Aula 6 — Segurança mobile](06-seguranca-mobile.md) | [README](README.md) | [Módulo 15 — Build Android](../15-build-android/README.md) |
