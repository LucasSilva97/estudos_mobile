# Aula 9 — Instalando e validando

> **Módulo:** 15 - Build e Distribuição Android · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Instalar um build de release com **`flutter install`** e **`adb install -r`**.
- Interpretar os erros de instalação: `UPDATE_INCOMPATIBLE`, `VERSION_DOWNGRADE`, `ALREADY_EXISTS`.
- Gerar e instalar os APKs de um AAB com o **`bundletool`**.
- Executar um **checklist de validação pós-build** que pega o que os testes não pegam.
- Validar em **aparelho limpo** e entender por que isso é diferente de atualizar.
- Testar a **atualização** a partir da versão publicada, não só a instalação.
- Verificar tamanho, permissões, assinatura e ofuscação do artefato final.

## ✅ Pré-requisitos

- [Aula 8 — Gerando APK e AAB](08-gerando-apk-e-aab.md) — o `.aab` e o `.apk` já gerados.
- [Aula 7 — Assinatura no Gradle](07-assinatura-no-gradle.md) — assinatura configurada.
- [Módulo 12, aula 9 — Depurando Android e iOS](../12-testes-e-debug/09-depurando-android-e-ios.md)
  — `adb logcat`.
- Um aparelho Android com **depuração USB** ligada, ou um emulador.

---

## 📖 Conceito

### Por que validar o build

Você rodou `flutter test`. Tudo passou. E mesmo assim há uma classe inteira de problemas que **só
aparece no artefato de release**:

| Problema | Aparece em | Teste pega? |
|---|---|---|
| R8 removeu uma classe | Release | ❌ |
| Permissão faltando no manifest | Release | ❌ |
| Asset que não entrou no bundle | Release | ❌ |
| Chave de assinatura errada | Upload | ❌ |
| Ofuscação quebrou reflexão | Release | ❌ |
| App grande demais | Loja | ❌ |
| Ícone ou splash errados | Instalação | ❌ |
| Não atualiza a versão anterior | Atualização | ❌ |

> 📌 **Nenhum desses aparece em `flutter run`.** O modo debug não roda o R8, não ofusca, não usa a
> sua chave e não passa pela divisão do bundle. Validar o artefato é uma etapa **separada** — e é a
> última antes de milhares de pessoas receberem o app.

### Instalar

```powershell
# O jeito mais simples: compila (se preciso) e instala.
flutter install --release

# Direto, com o adb.
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Escolhendo o aparelho, quando há mais de um.
adb devices
adb -s R58M12345 install -r app-release.apk
```

As flags do `adb install` que importam:

| Flag | O que faz |
|---|---|
| `-r` | **Reinstala**, mantendo os dados |
| `-d` | Permite instalar uma versão **mais antiga** |
| `-t` | Permite APK marcado como *test only* |
| `-g` | Concede **todas** as permissões automaticamente |

> 💡 **`adb install -g`** é útil para pular os diálogos de permissão durante um teste automatizado
> (módulo 12, aula 8) — e é exatamente por isso que você **não** deve usá-lo ao validar
> manualmente: ele esconde justamente o fluxo que você quer conferir.

### Os erros de instalação

**1. Assinatura diferente:**

```text
INSTALL_FAILED_UPDATE_INCOMPATIBLE:
Package br.com.estudos.foco signatures do not match previously
installed version
```

A versão instalada foi assinada com outra chave — quase sempre, a de debug.

```powershell
adb uninstall br.com.estudos.foco
adb install build/app/outputs/flutter-apk/app-release.apk
```

> ⚠️ **Desinstalar apaga os dados.** Em teste, tudo bem. Se isso acontecesse com um usuário real,
> seria o fim do app — e é precisamente o que a aula 6 evita.

**2. Versão mais antiga:**

```text
INSTALL_FAILED_VERSION_DOWNGRADE
```

```powershell
adb install -d app-release.apk   # -d permite downgrade
```

**3. Já instalado:**

```text
INSTALL_FAILED_ALREADY_EXISTS
```

**Correção:** `-r`.

**4. Sem espaço:**

```text
INSTALL_FAILED_INSUFFICIENT_STORAGE
```

**5. ABI incompatível:**

```text
INSTALL_FAILED_NO_MATCHING_ABIS
```

Você gerou `arm64-v8a` e o emulador é `x86_64`.

```powershell
flutter build apk --release --target-platform android-x64
```

> 📌 **`NO_MATCHING_ABIS` é o erro típico de quem usa emulador.** A maioria dos emuladores é x86_64;
> a maioria dos aparelhos reais é arm64. Um APK arm64 simplesmente não instala no emulador — e a
> mensagem, apesar de correta, não sugere a causa.

### Testar um AAB com o `bundletool`

O AAB não instala. Para ver **o que o usuário vai receber**:

```powershell
# 1. Baixe de github.com/google/bundletool/releases

# 2. Gere o conjunto de APKs
java -jar bundletool.jar build-apks `
  --bundle=build/app/outputs/bundle/release/app-release.aab `
  --output=foco.apks `
  --ks="$env:USERPROFILE\chaves\foco-upload.jks" `
  --ks-key-alias=foco

# 3. Instala no aparelho conectado a variante adequada a ele
java -jar bundletool.jar install-apks --apks=foco.apks

# 4. Quanto o usuário vai baixar, de fato
java -jar bundletool.jar get-size total --apks=foco.apks
```

```text
MIN,MAX
16234567,19876543     ← entre 16 e 20 MB, conforme o aparelho
```

> 💡 **`get-size total` é o número honesto.** Nem o tamanho do `.aab` nem o do APK universal
> representam o que o usuário baixa; este representa. É o mesmo número que a Play Console mostrará
> depois do upload.

O `.apks` é um ZIP — dá para abrir e ver a divisão:

```powershell
Expand-Archive foco.apks -DestinationPath apks-extraidos -Force
Get-ChildItem apks-extraidos/splits
```

```text
base-master.apk           ← o código comum
base-arm64_v8a.apk        ← a ABI
base-xxhdpi.apk           ← a densidade de tela
base-pt.apk               ← o idioma
```

### Aparelho limpo × atualização

São dois testes diferentes, e o segundo é o mais esquecido:

| | Instalação limpa | **Atualização** |
|---|---|---|
| Testa | Primeiro uso, onboarding, permissões | **Migração de banco**, dados preservados |
| Como | `adb uninstall` antes | Instalar a versão da loja, depois a nova |
| Esquecido | Raramente | ⚠️ **Quase sempre** |
| Se der errado | Ninguém instala | **Todo mundo perde os dados** |

```powershell
# ── Teste de INSTALAÇÃO LIMPA ──
adb uninstall br.com.estudos.foco
adb install app-release.apk

# ── Teste de ATUALIZAÇÃO ──
# 1. Instale a versão que está na loja (baixe o APK anterior)
adb install -r versao-anterior.apk
# 2. Use o app: crie matérias, registre sessões
# 3. Instale a nova POR CIMA
adb install -r app-release.apk
# 4. ⭐ Os dados continuam lá?
```

> ⚠️ **O teste de atualização é o que pega migração de banco quebrada** (módulo 10, aula 6) — e é o
> tipo de falha que apaga os dados de **todos** os usuários existentes, de uma vez, com o app já na
> loja. Guardar o APK de cada versão publicada é o que torna esse teste possível.

### Inspecionar o artefato

```powershell
# Identidade, versão e permissões
aapt dump badging app-release.apk

# Só as permissões
aapt dump permissions app-release.apk

# A assinatura
apksigner verify --print-certs app-release.apk

# Ofuscado mesmo?
# Se aparecerem nomes das suas classes, o --obfuscate não pegou.
unzip -p app-release.apk lib/arm64-v8a/libapp.so | strings | Select-String "CofreToken"
```

```text
package: name='br.com.estudos.foco' versionCode='15' versionName='1.2.0'
sdkVersion:'23'
targetSdkVersion:'35'
uses-permission: name='android.permission.INTERNET'
uses-permission: name='android.permission.POST_NOTIFICATIONS'
application-label:'Foco'
```

> 📌 **Leia a lista de permissões aqui, no artefato final.** É a mesma que aparecerá na ficha da
> loja — e é a última chance de descobrir que um plugin acrescentou algo (aula 5).

### O checklist de validação

| # | Verificação | Como |
|---|---|---|
| 1 | Instala em aparelho limpo | `adb uninstall` + `install` |
| 2 | **Atualiza sem perder dados** | Instalar a anterior, depois a nova |
| 3 | Ícone e nome corretos | Olhe a gaveta de apps |
| 4 | Splash aparece | Abra o app |
| 5 | Permissões pedidas na hora certa | Use os recursos |
| 6 | Nenhuma permissão a mais | `aapt dump permissions` |
| 7 | Assinado com a chave certa | `apksigner verify` |
| 8 | Está ofuscado | `strings` no `libapp.so` |
| 9 | Tamanho aceitável | `get-size total` |
| 10 | Funciona **sem rede** | Modo avião |
| 11 | Nenhum erro no logcat | `adb logcat -c` e usar o app |
| 12 | Fecha e reabre mantendo dados | Feche pelo gerenciador |

---

## 💡 Analogia

Pense num **carro saindo da fábrica**.

- **Os testes automatizados (módulo 12)** são a inspeção de cada peça na linha de montagem: o
  parafuso tem a rosca certa? O freio aguenta a pressão?
- **A validação do build** é o **teste de pista do carro montado**. E há coisas que só ela pega: o
  para-choque encosta na roda em curva fechada; a porta do motorista range; o rádio não pega estação
  nenhuma porque a antena não foi conectada.
- **O R8** é o inspetor que remove peças que "ninguém usa". Eficiente — e um dia ele tira o macaco
  do porta-malas, e você só descobre no pneu furado, na estrada.
- **Instalação limpa** é entregar o carro a um cliente novo. **Atualização** é o cliente trazendo o
  carro antigo para a revisão e recebendo-o de volta. **O segundo teste é o que quase ninguém faz —
  e é onde se descobre que o mecânico esvaziou o porta-luvas.**
- **O `bundletool`** é montar uma unidade de amostra com as peças que vão para cada região: a versão
  para país frio, para país quente. Se você só testou a de laboratório, não sabe se as outras
  fecham.
- **`get-size total`** é o peso real do carro com tanque cheio — não o peso do chassi no catálogo.
- **E ler as permissões no artefato final** é conferir a lista de itens do carro antes de entregar a
  nota fiscal. "Rastreador veicular" apareceu na lista e ninguém pediu? Melhor descobrir agora que
  na reclamação do cliente.

---

## 🧪 Exemplo mínimo

A validação completa, em oito comandos.

```powershell
# ── 1. Instalação LIMPA ──
adb uninstall br.com.estudos.foco
adb install build/app/outputs/flutter-apk/app-release.apk

# ── 2. Identidade e permissões ──
aapt dump badging build/app/outputs/flutter-apk/app-release.apk |
    Select-String "package:|application-label:|sdkVersion"

aapt dump permissions build/app/outputs/flutter-apk/app-release.apk

# ── 3. Assinatura ──
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk

# ── 4. Está ofuscado? ──
# Nenhuma linha na saída = ofuscado. Se aparecer, o --obfuscate não pegou.
unzip -p build/app/outputs/flutter-apk/app-release.apk lib/arm64-v8a/libapp.so |
    strings | Select-String "CofreToken|MateriaRepositorio"

# ── 5. Log limpo? ──
adb logcat -c
# (use o app por dois minutos)
adb logcat -d | Select-String "E/flutter|FATAL|Exception"
```

**O que esperar:**

| Comando | Saída boa |
|---|---|
| `install` | `Success` |
| `badging` | O seu pacote, versão e rótulo corretos |
| `permissions` | **Só** as que você declarou |
| `verify` | Um certificado que **não** é `CN=Android Debug` |
| `strings` | **Nada** |
| `logcat` | **Nada** |

> 📌 Os dois últimos são os que mais surpreendem. Um `E/flutter` no log de um app que "está
> funcionando" costuma ser uma exceção sendo engolida em algum lugar — e ela vai aparecer para
> alguém, em algum aparelho.

---

## 📱 Aplicando no Flutter

O script que executa o checklist inteiro e diz o que falta.

---

## 💻 Código completo

> **Arquivo:** `tool/validar-build.ps1` (novo)
> **Como executar:** `powershell -ExecutionPolicy Bypass -File tool/validar-build.ps1`

```powershell
# Executa o checklist de validação do artefato de release.
#
# Verifica o que dá para verificar sozinho e LISTA o que só
# você pode conferir no aparelho. Nenhum script substitui
# abrir o app e usar.

param(
    [string]$Apk = 'build/app/outputs/flutter-apk/app-release.apk',
    [string]$Pacote = 'br.com.estudos.foco',

    # Desinstala antes: testa INSTALAÇÃO LIMPA (apaga os dados).
    [switch]$Limpo
)

$ErrorActionPreference = 'Continue'

$problemas = @()
$avisos = @()
$ok = @()

function Ferramenta($nome) {
    $sdk = "$env:LOCALAPPDATA\Android\Sdk\build-tools"
    $f = Get-ChildItem $sdk -Filter "$nome.bat" -Recurse -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending | Select-Object -First 1
    if ($f) { return $f.FullName }
    return $null
}

Write-Host '═══ VALIDAÇÃO DO BUILD ═══' -ForegroundColor Cyan

# ══════════════════════════════════════════════════════════════
Write-Host "`n[1] O artefato existe?" -ForegroundColor Cyan

if (-not (Test-Path $Apk)) {
    Write-Host "  ❌ Não achei $Apk" -ForegroundColor Red
    Write-Host '     Rode: flutter build apk --release' -ForegroundColor Yellow
    exit 1
}

$mb = [math]::Round((Get-Item $Apk).Length / 1MB, 2)
Write-Host "  $Apk ($mb MB)"

if ($mb -gt 50) {
    $problemas += "Artefato muito grande: $mb MB"
} elseif ($mb -gt 30) {
    $avisos += "Artefato grande: $mb MB — rode analisar-tamanho.ps1"
} else {
    $ok += "Tamanho: $mb MB"
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[2] Identidade" -ForegroundColor Cyan

$aapt = Ferramenta 'aapt2'
if (-not $aapt) { $aapt = Ferramenta 'aapt' }

if ($aapt) {
    $badging = & $aapt dump badging $Apk 2>&1 | Out-String

    $pkg = ([regex]"package: name='([^']+)'").Match($badging).Groups[1].Value
    $vCode = ([regex]"versionCode='([^']+)'").Match($badging).Groups[1].Value
    $vName = ([regex]"versionName='([^']+)'").Match($badging).Groups[1].Value
    $label = ([regex]"application-label:'([^']+)'").Match($badging).Groups[1].Value
    $target = ([regex]"targetSdkVersion:'([^']+)'").Match($badging).Groups[1].Value

    Write-Host "  pacote:   $pkg"
    Write-Host "  versão:   $vName ($vCode)"
    Write-Host "  rótulo:   $label"
    Write-Host "  targetSdk: $target"

    if ($pkg -ne $Pacote) {
        $problemas += "applicationId inesperado: $pkg (esperava $Pacote)"
    } else { $ok += 'applicationId correto' }

    # ⚠️ O sufixo .debug sai do applicationIdSuffix da aula 7.
    # Um release com ele significa que o build type está errado.
    if ($pkg -match '\.debug$') {
        $problemas += 'Este é o build de DEBUG (sufixo .debug)'
    }

    # O Play exige targetSdk dentro de ~1 ano da API mais recente.
    if ([int]$target -lt 34) {
        $avisos += "targetSdk $target pode ser recusado pelo Play"
    }

    # ── Permissões ──
    Write-Host "`n[3] Permissões" -ForegroundColor Cyan
    $perms = ([regex]"uses-permission: name='([^']+)'").Matches($badging) |
        ForEach-Object { $_.Groups[1].Value }

    # Permissões que quase nunca fazem sentido num app de estudos —
    # e que aparecem na ficha da loja assustando o usuário.
    $suspeitas = @(
        'ACCESS_FINE_LOCATION', 'ACCESS_COARSE_LOCATION',
        'RECORD_AUDIO', 'READ_CONTACTS', 'READ_SMS',
        'CAMERA', 'MANAGE_EXTERNAL_STORAGE', 'QUERY_ALL_PACKAGES'
    )

    foreach ($p in $perms) {
        $curta = $p -replace '^android\.permission\.', ''
        $ehSuspeita = $suspeitas | Where-Object { $curta -eq $_ }

        if ($ehSuspeita) {
            Write-Host "  ⚠️  $curta" -ForegroundColor Yellow
            $avisos += "Permissão a conferir: $curta (algum plugin trouxe?)"
        } else {
            Write-Host "  ✅ $curta" -ForegroundColor Gray
        }
    }
} else {
    $avisos += 'aapt não encontrado — não dá para inspecionar o manifest'
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[4] Assinatura" -ForegroundColor Cyan

$apksigner = Ferramenta 'apksigner'
if ($apksigner) {
    $cert = & $apksigner verify --print-certs $Apk 2>&1 | Out-String

    if ($cert -match 'CN=Android Debug') {
        # A chave de debug é pública e igual no mundo todo.
        # A Play Console recusa qualquer artefato assinado com ela.
        $problemas += 'ASSINADO COM A CHAVE DE DEBUG — a loja vai recusar'
        Write-Host '  ❌ chave de debug' -ForegroundColor Red
    } elseif ($cert -match 'DOES NOT VERIFY') {
        $problemas += 'Assinatura inválida'
    } else {
        $sha = ([regex]'SHA-1 digest: ([a-f0-9]+)').Match($cert).Groups[1].Value
        Write-Host "  ✅ chave de release (SHA-1 $($sha.Substring(0,16))…)" -ForegroundColor Green
        $ok += 'Assinado com chave de release'
    }
} else {
    $avisos += 'apksigner não encontrado'
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[5] Ofuscação" -ForegroundColor Cyan

# Se os nomes das SUAS classes aparecem no binário, o --obfuscate
# não foi aplicado. Módulo 13, aula 7.
$temp = Join-Path $env:TEMP 'libapp.so'
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $Apk))
    $entrada = $zip.Entries | Where-Object { $_.FullName -like '*arm64-v8a/libapp.so' } |
        Select-Object -First 1

    if ($entrada) {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entrada, $temp, $true)
        $conteudo = [System.IO.File]::ReadAllBytes($temp)
        $texto = [System.Text.Encoding]::ASCII.GetString($conteudo)

        $vazados = @('CofreToken', 'MateriaRepositorio', 'GerenciadorPermissoes') |
            Where-Object { $texto.Contains($_) }

        if ($vazados) {
            $avisos += "Nomes de classe no binário: $($vazados -join ', ') — faltou --obfuscate?"
            Write-Host "  ⚠️  encontrei: $($vazados -join ', ')" -ForegroundColor Yellow
        } else {
            Write-Host '  ✅ nenhum nome de classe encontrado' -ForegroundColor Green
            $ok += 'Ofuscado'
        }
    }
    $zip.Dispose()
} catch {
    $avisos += "Não consegui inspecionar o binário: $_"
} finally {
    Remove-Item $temp -ErrorAction SilentlyContinue
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[6] Símbolos arquivados" -ForegroundColor Cyan

if ($vName -and $vCode) {
    $pasta = "simbolos/$vName+$vCode"
    if (Test-Path $pasta) {
        $n = (Get-ChildItem $pasta -Filter '*.symbols').Count
        Write-Host "  ✅ $pasta ($n arquivo(s))" -ForegroundColor Green
        $ok += 'Símbolos arquivados'
    } else {
        # Sem os símbolos desta versão, os crashes dela serão
        # ilegíveis para sempre. Não há como regerar.
        $problemas += "Símbolos NÃO arquivados em $pasta — crashes seriam ilegíveis"
    }
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n[7] Aparelho" -ForegroundColor Cyan

$devices = adb devices 2>&1 | Select-String -Pattern '\tdevice$'

if (-not $devices) {
    $avisos += 'Nenhum aparelho conectado — instalação não testada'
    Write-Host '  ⚠️  nenhum aparelho' -ForegroundColor Yellow
} else {
    if ($Limpo) {
        Write-Host '  Desinstalando (teste de instalação limpa)…'
        adb uninstall $Pacote 2>&1 | Out-Null
    }

    Write-Host '  Instalando…'
    $r = adb install -r $Apk 2>&1 | Out-String

    if ($r -match 'Success') {
        Write-Host '  ✅ instalado' -ForegroundColor Green
        $ok += 'Instala no aparelho'
    } elseif ($r -match 'INSTALL_FAILED_UPDATE_INCOMPATIBLE') {
        $problemas += 'Assinatura diferente da versão instalada. Desinstale antes (-Limpo).'
    } elseif ($r -match 'INSTALL_FAILED_NO_MATCHING_ABIS') {
        $problemas += 'ABI incompatível (emulador x86 com APK arm64?)'
    } else {
        $problemas += "Instalação falhou: $($r.Trim())"
    }
}

# ══════════════════════════════════════════════════════════════
Write-Host "`n═══ RESULTADO ═══" -ForegroundColor Cyan

foreach ($o in $ok)        { Write-Host "  ✅ $o" -ForegroundColor Green }
foreach ($a in $avisos)    { Write-Host "  ⚠️  $a" -ForegroundColor Yellow }
foreach ($p in $problemas) { Write-Host "  ❌ $p" -ForegroundColor Red }

# ══════════════════════════════════════════════════════════════
# ⭐ O que NENHUM script verifica. Esta lista é a parte mais
# importante da saída — ela existe justamente porque a automação
# não alcança.
Write-Host "`n═══ SÓ VOCÊ PODE CONFERIR ═══" -ForegroundColor Magenta
@(
    'Ícone e nome corretos na gaveta de apps',
    'Splash aparece e some na hora certa',
    'Permissões são pedidas no momento do USO',
    'O app funciona em modo avião',
    'ATUALIZAÇÃO a partir da versão publicada preserva os dados',
    'Fechar pelo gerenciador e reabrir mantém os dados',
    'adb logcat -c, usar 2 min, e conferir se há E/flutter'
) | ForEach-Object { Write-Host "  ☐ $_" }

Write-Host ''
if ($problemas.Count -gt 0) {
    Write-Host "$($problemas.Count) problema(s). NÃO envie ainda." -ForegroundColor Red
    exit 1
}
Write-Host 'Verificações automáticas: OK. Agora confira a lista acima.' -ForegroundColor Green
```

E o teste de atualização:

> **Arquivo:** `tool/testar-atualizacao.ps1` (novo)

```powershell
# Testa a ATUALIZAÇÃO — o teste mais esquecido, e o que pega
# migração de banco quebrada.
#
# Uso:
#   .\tool\testar-atualizacao.ps1 -Anterior releases/1.1.0.apk

param(
    [Parameter(Mandatory)][string]$Anterior,
    [string]$Novo = 'build/app/outputs/flutter-apk/app-release.apk',
    [string]$Pacote = 'br.com.estudos.foco'
)

$ErrorActionPreference = 'Stop'

foreach ($a in @($Anterior, $Novo)) {
    if (-not (Test-Path $a)) { throw "Não achei $a" }
}

Write-Host '═══ TESTE DE ATUALIZAÇÃO ═══' -ForegroundColor Cyan
Write-Host "  de:   $Anterior"
Write-Host "  para: $Novo`n"

Write-Host '[1] Desinstalando tudo…' -ForegroundColor Cyan
adb uninstall $Pacote 2>&1 | Out-Null

Write-Host '[2] Instalando a versão ANTERIOR…' -ForegroundColor Cyan
$r = adb install $Anterior 2>&1 | Out-String
if ($r -notmatch 'Success') { throw "Falhou: $r" }

Write-Host ''
Write-Host '  ⭐ AGORA, NO APARELHO:' -ForegroundColor Yellow
Write-Host '     1. Abra o app'
Write-Host '     2. Crie 2 ou 3 matérias'
Write-Host '     3. Registre algumas sessões'
Write-Host '     4. Mude alguma configuração'
Write-Host '     5. FECHE o app'
Write-Host ''
Read-Host '  Aperte ENTER quando terminar'

Write-Host "`n[3] Instalando a versão NOVA por cima…" -ForegroundColor Cyan
$r = adb install -r $Novo 2>&1 | Out-String

if ($r -match 'INSTALL_FAILED_UPDATE_INCOMPATIBLE') {
    Write-Host '  ❌ ASSINATURA DIFERENTE.' -ForegroundColor Red
    Write-Host '     Em produção, isto significaria que NENHUM usuário' -ForegroundColor Red
    Write-Host '     conseguiria atualizar. Confira a chave (Aula 6).' -ForegroundColor Red
    exit 1
}
if ($r -notmatch 'Success') { throw "Falhou: $r" }

Write-Host '  ✅ atualizado' -ForegroundColor Green
Write-Host ''
Write-Host '  ⭐ AGORA CONFIRA, NO APARELHO:' -ForegroundColor Yellow
Write-Host '     ☐ As matérias continuam lá?'
Write-Host '     ☐ As sessões continuam lá?'
Write-Host '     ☐ A configuração foi preservada?'
Write-Host '     ☐ O app abre sem erro?'
Write-Host ''
Write-Host '  Se QUALQUER item falhar, a migração está quebrada —' -ForegroundColor Yellow
Write-Host '  e todos os seus usuários perderiam os dados.' -ForegroundColor Yellow
Write-Host '  Módulo 10, aula 6.' -ForegroundColor Yellow

Write-Host "`n[4] Log dos últimos segundos:" -ForegroundColor Cyan
adb logcat -d -t 100 | Select-String "E/flutter|FATAL|sqlite|migration"
```

```powershell
.\tool\validar-build.ps1 -Limpo
.\tool\testar-atualizacao.ps1 -Anterior releases/1.1.0.apk
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Buscar `aapt`/`apksigner` no SDK | A versão do build-tools varia; buscar evita caminho fixo. |
| Detectar sufixo `.debug` | Um release com ele significa build type errado (aula 7). |
| Alertar `targetSdk < 34` | O Play exige valor recente, senão para de aceitar atualizações. |
| Lista de permissões **suspeitas** | Pega o que um plugin trouxe e vai aparecer na ficha da loja. |
| Detectar `CN=Android Debug` | A chave de debug é pública; a loja recusa o artefato. |
| Procurar nomes de classe no `libapp.so` | Se aparecem, o `--obfuscate` não foi aplicado. |
| Conferir a pasta de símbolos da versão | Sem eles, os crashes desta versão são ilegíveis **para sempre**. |
| Traduzir `INSTALL_FAILED_*` | As mensagens do `adb` são corretas e não sugerem a causa. |
| **"Só você pode conferir"** | A parte mais importante da saída: existe porque a automação não alcança. |
| `exit 1` com problemas | Serve como portão no CI. |
| `testar-atualizacao.ps1` | O teste mais esquecido — e o que pega migração quebrada. |
| Pausa com `Read-Host` | Os dados precisam ser criados **por uma pessoa**, no app real. |
| Mensagem sobre assinatura diferente | Em produção, significaria que **nenhum** usuário conseguiria atualizar. |
| `logcat` filtrando `sqlite|migration` | O erro de migração aparece aí, e não na tela. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Instalar build local | `adb install` | Xcode, ou `ios-deploy` |
| Instalar para outra pessoa | ✅ Manda o APK | ⚠️ **TestFlight** |
| Inspecionar o artefato | `aapt`, `apksigner` | `codesign -d`, descompactar o IPA |
| Testar a versão da loja | Guardar o APK anterior | TestFlight guarda as builds |
| Downgrade | `adb install -d` | ❌ Não é possível |
| Ver o log | `adb logcat` | Console.app / Xcode |

> 💡 **O TestFlight resolve, no iOS, um problema que no Android você resolve na unha.** Ele guarda
> todas as builds enviadas, distribui para até 10 000 testadores e coleta feedback e crashes
> automaticamente. No Android, o equivalente é a **faixa de teste interno** da Play Console — menos
> conhecida, e igualmente útil. Módulo 17.

> ⚠️ **Guarde o APK de cada versão publicada**, numa pasta `releases/`. Sem ele, não há como testar a
> atualização a partir da versão que está nas mãos dos usuários — e esse é justamente o teste que
> pega a falha mais cara.

---

## ⚠️ Erros comuns

### 1. Só testar em `flutter run`

R8, ofuscação e assinatura não agem em debug.

**Correção:** valide o artefato de release.

### 2. Não testar a atualização

Migração quebrada apaga os dados de todos.

**Correção:** instale a anterior, depois a nova.

### 3. Não guardar o APK das versões publicadas

Sem ele, o teste acima é impossível.

**Correção:** pasta `releases/`.

### 4. `INSTALL_FAILED_UPDATE_INCOMPATIBLE` e desinstalar sem pensar

Funciona em teste; em produção seria fatal.

**Correção:** entenda **por que** a assinatura diferiu.

### 5. `NO_MATCHING_ABIS` no emulador

**Correção:** `--target-platform android-x64`.

### 6. Usar `adb install -g` ao validar

Esconde o fluxo de permissões que você quer conferir.

**Correção:** só em teste automatizado.

### 7. Não ler as permissões do artefato

Plugin acrescentou algo e aparece na loja.

**Correção:** `aapt dump permissions`.

### 8. Não conferir a assinatura

APK de debug é recusado no upload.

**Correção:** `apksigner verify`.

### 9. Não testar o AAB

Um asset pode não ter entrado na divisão.

**Correção:** `bundletool`.

### 10. Ignorar `E/flutter` no log

Exceção engolida que vai aparecer para alguém.

**Correção:** `logcat` limpo.

### 11. Não testar sem rede

Tela de erro em vez de app funcionando.

**Correção:** modo avião.

### 12. Achar que o script basta

**Correção:** abra o app e use.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `validar-build.ps1`. Quantos problemas e avisos?

**Passo 2.** Rode `aapt dump permissions` e confira item por item. Reconhece todos?

**Passo 3.** Rode `apksigner verify --print-certs`. É a sua chave?

**Passo 4.** Procure nomes das suas classes no `libapp.so`. Achou algum?

**Passo 5.** Compile **sem** `--obfuscate` e repita o passo 4.

**Passo 6.** Instale o APK de debug e depois o de release, sem desinstalar. Qual erro?

**Passo 7.** Guarde o APK atual em `releases/1.0.0.apk`.

**Passo 8.** Suba a versão, compile, e rode `testar-atualizacao.ps1`. Os dados sobreviveram?

**Passo 9.** Gere o AAB, rode `bundletool get-size total` e compare com o tamanho do APK.

**Passo 10.** Instale via `bundletool install-apks` e confira se é igual ao APK direto.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-android.md](../../exercicios/15-build-android.md)

Faça os de **Aplicação** (checklist completo), **Diagnóstico** (`INSTALL_FAILED_*`) e **Reflexão**
(o que a automação não pega).

---

## 🏆 Desafio opcional

Monte uma **matriz de validação** e execute-a antes de cada release.

Requisitos:

- Pelo menos três aparelhos: um antigo (API 23–26), um médio, um recente (API 34+).
- Para cada um: instalação limpa **e** atualização a partir da versão publicada.
- Um teste em cada estado de rede: online, offline, rede lenta (use o *network throttling* do
  emulador).
- Um teste com fonte a 200 % e outro com o TalkBack ligado (módulo 13, aula 5).
- Um teste em tema claro e outro em escuro.
- Uma planilha versionada: aparelho × cenário × resultado × data.
- Uma regra explícita de quando **não** publicar.

Depois responda: quantas combinações a matriz completa tem? Quais você executa **sempre** e quais só
em releases grandes — e como decidiu esse corte?

---

## 📌 Resumo

- **Há falhas que só aparecem no release**: R8, ofuscação, assinatura, divisão do bundle.
- `flutter install --release` ou `adb install -r` para instalar.
- **`UPDATE_INCOMPATIBLE`** = assinatura diferente. Em produção, ninguém atualizaria.
- **`NO_MATCHING_ABIS`** = APK arm64 em emulador x86.
- `-d` permite downgrade; `-g` concede permissões — **não use `-g` ao validar à mão**.
- O AAB não instala: use **`bundletool build-apks`** + `install-apks`.
- **`bundletool get-size total`** é o número honesto do download.
- **Instalação limpa e atualização são testes diferentes** — o segundo é o esquecido.
- **O teste de atualização pega migração de banco quebrada**, que apagaria os dados de todos.
- **Guarde o APK de cada versão publicada** para poder fazer esse teste.
- Inspecione o artefato: `aapt dump badging`, `dump permissions`, `apksigner verify`, `strings`.
- **Leia as permissões no artefato final** — é o que aparecerá na ficha da loja.
- Um `E/flutter` no log é uma exceção engolida que vai aparecer para alguém.
- **Nenhum script substitui abrir o app e usar.**

---

## ☑️ Checklist de domínio

- [ ] Instalo builds de release com `adb`.
- [ ] Sei traduzir os erros `INSTALL_FAILED_*`.
- [ ] Sei gerar e instalar APKs a partir de um AAB.
- [ ] Sei medir o download real com `get-size total`.
- [ ] Testo instalação limpa **e** atualização.
- [ ] Guardo o APK de cada versão publicada.
- [ ] Inspeciono permissões, assinatura e ofuscação do artefato.
- [ ] Confiro que os símbolos foram arquivados.
- [ ] Testo sem rede.
- [ ] Confiro o logcat depois de usar o app.
- [ ] Sei o que a automação não pega.
- [ ] Tenho um checklist escrito e o sigo.

---

## 📚 Referências oficiais

- [adb — developer.android.com](https://developer.android.com/tools/adb)
- [bundletool — developer.android.com](https://developer.android.com/tools/bundletool)
- [aapt2 — developer.android.com](https://developer.android.com/tools/aapt2)
- [apksigner — developer.android.com](https://developer.android.com/tools/apksigner)
- [Test your app bundle — developer.android.com](https://developer.android.com/guide/app-bundle/test)
- [Prepare and roll out a release — Play Console Help](https://support.google.com/googleplay/android-developer/answer/9859348)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Gerando APK e AAB](08-gerando-apk-e-aab.md) | [README](README.md) | [Diagnóstico de build](10-diagnostico-de-build.md) |
