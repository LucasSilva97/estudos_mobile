# Aula 4 — Bundle ID e o Xcode

> **Módulo:** 15 - Build e Distribuição iOS · **Tempo estimado:** 35 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Entender o que é o **Bundle Identifier**, por que ele é **imutável** depois de publicado e como
  escolher o seu em domínio invertido.
- Alterar o Bundle ID do projeto Foco para **`br.com.estudos.foco`** — **inclusive no Windows**,
  editando os arquivos de texto.
- Saber por que se abre o **`.xcworkspace`** e nunca o **`.xcodeproj`**.
- Navegar pelas quatro áreas do Xcode que importam: Navigator, Editor, Inspector e Report
  Navigator.
- Definir o **Deployment Target** (iOS 13) e entender o custo de subir ou descer esse número.
- Conhecer os **targets** de um projeto Flutter (`Runner`, `RunnerTests`) e os `.xcconfig` que o
  Flutter injeta.

## ✅ Pré-requisitos

- [Aula 3 — Simulador e iPhone físico](03-simulador-e-iphone-fisico.md) lida.
- [Módulo 14, aula 2 — Identidade do app](../14-build-android/02-identidade-do-app.md) — o
  `applicationId` do Android é o irmão gêmeo do Bundle ID.
- Projeto **Foco** com o `applicationId` já definido como `br.com.estudos.foco`.
- Git configurado — você vai comparar o antes e o depois com `git diff`.

---

## 🍎🪟 Antes de começar: onde você está

> # ⚠️ PARCIAL. Você está no Windows 11.
>
> **Esta é a aula mais executável do módulo sem um Mac.** O Bundle ID mora em arquivos de
> **texto**, versionados no Git — e texto se edita em qualquer sistema operacional.
>
> **O que você faz agora, no Windows:**
> 1. **Alterar o Bundle ID** em `ios/Runner.xcodeproj/project.pbxproj` e conferir com `git diff`.
> 2. Conferir o `Info.plist` e os `.xcconfig`.
> 3. Definir o **Deployment Target** no `project.pbxproj` e no `Podfile`.
> 4. Commitar tudo. No dia do Mac, o projeto já abre com a identidade certa.
>
> **O que fica para o Mac:** abrir o Xcode, ver as telas, e o `pod install` que aplica o
> Deployment Target aos pods.
>
> ⚠️ **Editar o `project.pbxproj` à mão exige cuidado** — é um formato com ids gerados e
> referências cruzadas. A seção "Código completo" traz um script que faz a substituição de forma
> segura, com backup, e o `git diff` é a sua rede de proteção.

---

## 📖 Conceito

### O Bundle Identifier

```text
br.com.estudos.foco
└┬┘ └┬┘ └──┬───┘ └┬─┘
 │   │     │      └── o app
 │   │     └───────── você / a organização
 │   └─────────────── o tipo de domínio
 └─────────────────── o país
```

É o **domínio invertido** — a mesma convenção do `applicationId` do Android, e por boa razão: um
domínio tem dono, então a chance de duas pessoas escolherem o mesmo identificador é quase nula.

| Regra | Detalhe |
|---|---|
| Caracteres | Letras, números, hífen e ponto |
| Maiúsculas | Tecnicamente permitidas, **evite** |
| Underscore | ❌ Não permitido |
| Único | Em **toda** a App Store |
| **Imutável** | ⚠️ Depois de publicado, **nunca** muda |

> ⚠️ **O Bundle ID é permanente.** Publicou com `br.com.estudos.foco`? É esse para sempre. Mudar
> significa **outro app**: nova ficha, nova URL, zero avaliações, zero instalações — e os usuários
> antigos nunca recebem a atualização. É a mesma regra do `applicationId` do Android (módulo 14,
> aula 2), e vale a pena decidir com calma **agora**.

E ele não vive sozinho: o Bundle ID amarra uma cadeia inteira.

```text
Bundle ID  →  App ID (portal da Apple)
           →  Provisioning Profile         (aula 7)
           →  Certificado de assinatura    (aula 7)
           →  Registro no App Store Connect (aula 9)
           →  Push notifications, iCloud, Sign in with Apple
```

> 📌 **Mudar o Bundle ID depois de configurar tudo isso obriga a refazer tudo isso.** Não é
> impossível antes de publicar — é só trabalhoso. Depois de publicar, é impossível.

### Onde ele fica

| Arquivo | O que tem | Editável no Windows |
|---|---|---|
| `ios/Runner.xcodeproj/project.pbxproj` | **`PRODUCT_BUNDLE_IDENTIFIER`** | ✅ (com cuidado) |
| `ios/Runner/Info.plist` | `$(PRODUCT_BUNDLE_IDENTIFIER)` — uma variável | ✅ |
| `ios/Flutter/*.xcconfig` | Configurações injetadas pelo Flutter | ✅ |
| `ios/Podfile` | Plataforma mínima dos pods | ✅ |

```xml
<!-- ios/Runner/Info.plist — repare: é uma VARIÁVEL -->
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

> 💡 **O `Info.plist` não contém o Bundle ID literal** — ele referencia a variável definida no
> `project.pbxproj`. Trocar o valor no `Info.plist` seria o lugar errado: é no `project.pbxproj`
> que ele existe de fato, e em **três** lugares (Debug, Release e Profile).

### `.xcworkspace` × `.xcodeproj`

```text
ios/
├── Runner.xcodeproj      ← ❌ NÃO abra este
├── Runner.xcworkspace    ← ✅ ABRA ESTE
├── Podfile
└── Pods/                 (criado pelo pod install)
```

```bash
open ios/Runner.xcworkspace     # ✅
open ios/Runner.xcodeproj       # ❌
```

| | `.xcodeproj` | `.xcworkspace` |
|---|---|---|
| Contém | Só o app | O app **+ os Pods** |
| Compila | ❌ Falta tudo | ✅ |
| Erro típico | `module 'X' not found` | — |

> ⚠️ **Abrir o `.xcodeproj` é o erro nº 1 de quem abre o Xcode pela primeira vez.** O projeto abre
> normalmente, parece certo, e o build falha com dezenas de "module not found" — porque os pods,
> que trazem o código nativo de todos os plugins, não estão ali. Se o Podfile existe, **abra o
> workspace**.

### O Xcode em quatro áreas

```text
┌────────────┬──────────────────────────┬──────────────┐
│ Navigator  │  Editor                  │  Inspector   │
│ (⌘1)       │                          │  (⌥⌘1)       │
│            │  o arquivo aberto        │              │
│ arquivos,  │                          │ propriedades │
│ erros,     │                          │ do que está  │
│ RELATÓRIOS │                          │ selecionado  │
└────────────┴──────────────────────────┴──────────────┘
```

| Área | Atalho | Para quê |
|---|---|---|
| **Project Navigator** | ⌘1 | Os arquivos |
| **Issue Navigator** | ⌘5 | Erros e avisos |
| **Report Navigator** | ⌘9 | ⭐ **O log completo do build** |
| Signing & Capabilities | — | Assinatura (aula 7) |
| Build Settings | — | As centenas de opções |

> 📌 **O Report Navigator (⌘9) é o que salva você no módulo inteiro.** O Xcode frequentemente falha
> com uma mensagem genérica na tela; o detalhe real está lá, no log da etapa que falhou. Quando a
> mensagem não fizer sentido, abra o ⌘9, clique na última build e expanda o passo vermelho.

### Deployment Target

É a versão **mínima** do iOS em que o app roda.

| Versão | Cobertura aproximada | Aparelhos |
|---|---|---|
| iOS 12 | ~99,9 % | iPhone 5s e posteriores |
| **iOS 13** | ~99 % | ✅ **O padrão do Flutter** |
| iOS 15 | ~95 % | iPhone 6s e posteriores |
| iOS 17 | ~80 % | Perde usuários sem ganho claro |

```ruby
# ios/Podfile
platform :ios, '13.0'
```

```text
IPHONEOS_DEPLOYMENT_TARGET = 13.0;   # em project.pbxproj (3 lugares)
```

> ⚠️ **O número precisa bater nos dois lugares.** Divergência entre o `Podfile` e o
> `project.pbxproj` produz avisos em massa durante o `pod install` e, às vezes, falha de build —
> com uma mensagem que não menciona a divergência.

E às vezes um plugin obriga a subir:

```text
Specs satisfying the `flutter_local_notifications` dependency were found,
but they required a higher minimum deployment target.
```

**Correção:** suba o `platform :ios` no Podfile **e** o `IPHONEOS_DEPLOYMENT_TARGET`, e rode
`pod install` de novo.

### Targets e `.xcconfig`

Um projeto Flutter tem dois targets:

| Target | O que é |
|---|---|
| **Runner** | O app. É onde tudo acontece. |
| **RunnerTests** | Testes nativos (o Flutter não os usa) |

E três arquivos de configuração que o Flutter injeta:

```text
ios/Flutter/
├── Debug.xcconfig         ← inclui Generated.xcconfig
├── Release.xcconfig       ← idem
└── Generated.xcconfig     ← ⚠️ GERADO. Não edite; não versione.
```

```text
# ios/Flutter/Generated.xcconfig — escrito pelo `flutter build`
FLUTTER_ROOT=/Users/voce/flutter
FLUTTER_APPLICATION_PATH=/Users/voce/projetos/foco
FLUTTER_BUILD_NAME=1.0.0
FLUTTER_BUILD_NUMBER=1
```

> 💡 `FLUTTER_BUILD_NAME` e `FLUTTER_BUILD_NUMBER` vêm do **`pubspec.yaml`** (`version: 1.0.0+1`).
> É por isso que a versão do app iOS se define no `pubspec`, e não no Xcode — a aula 5 detalha.

---

## 💡 Analogia

Pense no **CNPJ de uma empresa**.

- **O Bundle ID é o CNPJ.** Único no país inteiro, e **não se troca**. A empresa pode mudar de nome
  fantasia, de endereço, de ramo — o CNPJ é o mesmo do primeiro ao último dia. Querer outro CNPJ é
  abrir **outra empresa**: novo cadastro, e o histórico da antiga não vem junto.
- **O domínio invertido** é o que garante a unicidade sem um cartório central: quem tem o domínio
  `estudos.com.br` é o único que pode usar `br.com.estudos.*`.
- **A cadeia que depende dele** — certificado, provisioning, App Store Connect, push — é o conjunto
  de licenças, contas bancárias e contratos emitidos **em cima** do CNPJ. Trocar o número significa
  reemitir todos.
- **O `.xcworkspace` × `.xcodeproj`** é a diferença entre o **grupo empresarial** e a **matriz
  sozinha**. Você quer ver o balanço consolidado, com todas as filiais (os pods). Abrir só a matriz
  mostra números que não fecham — e o contador reclama de contas que "não existem".
- **O Deployment Target** é decidir a partir de que idade o produto é vendido. Baixar demais obriga
  a fazer versões que ninguém compra; subir demais fecha a porta para clientes que estavam
  dispostos.
- **E o Report Navigator** é o livro-razão. O balancete na parede diz "erro"; o razão diz **qual
  lançamento** deu errado, em que dia, e de quanto.

---

## 🧪 Exemplo mínimo

Alterar o Bundle ID, **no Windows**, e conferir.

**Passo 1 — ver o valor atual:**

```powershell
Select-String -Path ios/Runner.xcodeproj/project.pbxproj -Pattern 'PRODUCT_BUNDLE_IDENTIFIER'
```

```text
ios/Runner.xcodeproj/project.pbxproj:376: PRODUCT_BUNDLE_IDENTIFIER = com.example.foco;
ios/Runner.xcodeproj/project.pbxproj:504: PRODUCT_BUNDLE_IDENTIFIER = com.example.foco;
ios/Runner.xcodeproj/project.pbxproj:527: PRODUCT_BUNDLE_IDENTIFIER = com.example.foco;
```

> 📌 **Três ocorrências: Debug, Release e Profile.** Trocar só uma é um erro silencioso — o build
> de debug usa um identificador e o de release usa outro, e o problema só aparece na assinatura.
> Há também três de `RunnerTests`, com o sufixo `.RunnerTests`.

**Passo 2 — trocar:**

```powershell
(Get-Content ios/Runner.xcodeproj/project.pbxproj) `
    -replace 'com\.example\.foco', 'br.com.estudos.foco' |
    Set-Content ios/Runner.xcodeproj/project.pbxproj -Encoding utf8
```

**Passo 3 — conferir com o Git:**

```powershell
git diff ios/Runner.xcodeproj/project.pbxproj
```

```diff
-				PRODUCT_BUNDLE_IDENTIFIER = com.example.foco;
+				PRODUCT_BUNDLE_IDENTIFIER = br.com.estudos.foco;
```

> 💡 **O `git diff` é a rede de proteção.** Se aparecerem mudanças além das linhas de
> `PRODUCT_BUNDLE_IDENTIFIER` — indentação alterada, quebras de linha diferentes, arquivo inteiro
> reescrito —, desfaça com `git checkout` e refaça com o script da próxima seção. O `project.pbxproj`
> é sensível a mudanças de codificação e de fim de linha.

**Passo 4 — o Deployment Target:**

```powershell
Select-String -Path ios/Podfile -Pattern 'platform :ios'
Select-String -Path ios/Runner.xcodeproj/project.pbxproj -Pattern 'IPHONEOS_DEPLOYMENT_TARGET'
```

**Passo 5 — commitar:**

```powershell
git add ios/
git commit -m "Bundle ID: br.com.estudos.foco"
```

---

## 📱 Aplicando no Flutter

Um script que faz a troca com segurança, e um verificador de identidade multiplataforma.

---

## 💻 Código completo

> **Arquivo:** `ferramentas/trocar-bundle-id.ps1` (novo)
> **Como executar:** `powershell -ExecutionPolicy Bypass -File ferramentas/trocar-bundle-id.ps1 -Novo br.com.estudos.foco`

```powershell
# Troca o Bundle ID do projeto iOS, com backup e validação.
#
# 🪟 Roda no Windows: o project.pbxproj é um arquivo de TEXTO.
#
# ⚠️ Depois de publicado na App Store, o Bundle ID é IMUTÁVEL.
# Este script serve para ANTES da primeira publicação.

param(
    [Parameter(Mandatory)][string]$Novo,
    [switch]$Simular
)

$ErrorActionPreference = 'Stop'
$pbxproj = 'ios/Runner.xcodeproj/project.pbxproj'

# ── 1. Validar o formato ────────────────────────────────────────
# Underscore não é permitido, e maiúscula é permitida mas causa
# confusão com serviços que normalizam o identificador.
if ($Novo -notmatch '^[a-z][a-z0-9]*(\.[a-z][a-z0-9-]*)+$') {
    Write-Host "❌ Bundle ID inválido: $Novo" -ForegroundColor Red
    Write-Host ''
    Write-Host 'Regras:' -ForegroundColor Yellow
    Write-Host '  · domínio invertido: br.com.suaempresa.seuapp'
    Write-Host '  · minúsculas, números e hífen'
    Write-Host '  · SEM underscore, SEM acento, SEM espaço'
    Write-Host '  · cada parte começa com letra'
    exit 1
}

if (-not (Test-Path $pbxproj)) {
    throw "Não achei $pbxproj. Você está na raiz do projeto Flutter?"
}

# ── 2. O que existe hoje ────────────────────────────────────────
$conteudo = Get-Content $pbxproj -Raw

$atuais = [regex]::Matches($conteudo, 'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);') |
    ForEach-Object { $_.Groups[1].Value.Trim() } |
    Sort-Object -Unique

Write-Host 'Bundle IDs no projeto:' -ForegroundColor Cyan
$atuais | ForEach-Object { Write-Host "  $_" }

# O target de testes tem o sufixo .RunnerTests e precisa
# acompanhar o principal.
$principal = $atuais | Where-Object { $_ -notmatch '\.RunnerTests$' } | Select-Object -First 1

if (-not $principal) { throw 'Não achei o Bundle ID principal.' }
if ($principal -eq $Novo) {
    Write-Host "`nJá é $Novo. Nada a fazer." -ForegroundColor Green
    exit 0
}

Write-Host "`n  $principal  →  $Novo" -ForegroundColor Yellow

if ($Simular) {
    Write-Host '(simulação: nada foi alterado)' -ForegroundColor Cyan
    exit 0
}

# ── 3. Backup ───────────────────────────────────────────────────
# O project.pbxproj é sensível: ids gerados, referências cruzadas.
# Um backup custa nada e evita reconstruir o projeto do zero.
$backup = "$pbxproj.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $pbxproj $backup
Write-Host "  backup: $backup" -ForegroundColor Gray

# ── 4. Substituir ───────────────────────────────────────────────
# Substitui o principal E o de testes, preservando o sufixo.
$novoConteudo = $conteudo `
    -replace [regex]::Escape("$principal.RunnerTests"), "$Novo.RunnerTests" `
    -replace [regex]::Escape($principal), $Novo

# -NoNewline: o Set-Content acrescentaria uma linha em branco no
# fim, e o Xcode reclama de arquivos de projeto alterados assim.
Set-Content $pbxproj -Value $novoConteudo -NoNewline -Encoding utf8

# ── 5. Conferir ─────────────────────────────────────────────────
$depois = [regex]::Matches((Get-Content $pbxproj -Raw), 'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);') |
    ForEach-Object { $_.Groups[1].Value.Trim() } | Sort-Object -Unique

Write-Host "`nDepois:" -ForegroundColor Cyan
$depois | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }

$sobrou = $depois | Where-Object { $_ -notmatch [regex]::Escape($Novo) }
if ($sobrou) {
    Write-Host "`n⚠️  Sobrou: $($sobrou -join ', ')" -ForegroundColor Yellow
    Write-Host "   Restaure com: Copy-Item '$backup' '$pbxproj'" -ForegroundColor Yellow
}

# ── 6. Android também? ──────────────────────────────────────────
# Manter os dois iguais evita confusão eterna: mesmo app, mesmo
# identificador nas duas lojas.
$gradle = 'android/app/build.gradle.kts'
if (Test-Path $gradle) {
    $appId = ([regex]'applicationId = "([^"]+)"').Match((Get-Content $gradle -Raw)).Groups[1].Value
    if ($appId -and $appId -ne $Novo) {
        Write-Host "`n⚠️  O Android usa outro: $appId" -ForegroundColor Yellow
        Write-Host '   Não é erro, mas manter os dois iguais evita confusão.' -ForegroundColor Yellow
        Write-Host '   Módulo 14, aula 2.' -ForegroundColor Gray
    } else {
        Write-Host "`n✅ Android e iOS com o mesmo identificador." -ForegroundColor Green
    }
}

Write-Host ''
Write-Host '⭐ Confira o diff ANTES de commitar:' -ForegroundColor Cyan
Write-Host "   git diff $pbxproj" -ForegroundColor Cyan
Write-Host '   Só devem aparecer linhas de PRODUCT_BUNDLE_IDENTIFIER.' -ForegroundColor Gray
```

E o verificador de identidade, que roda nas duas plataformas:

> **Arquivo:** `ferramentas/conferir-identidade.ps1` (novo)

```powershell
# Confere a identidade do app nas DUAS plataformas.
#
# 🪟 Roda no Windows — tudo que ele lê é arquivo de texto.
#
# Rode antes de levar o projeto para o Mac: corrigir divergência
# aqui custa um minuto; descobrir no Xcode custa uma sessão.

$problemas = @()
$avisos = @()

function Ler($arquivo, $padrao) {
    if (-not (Test-Path $arquivo)) { return $null }
    $m = [regex]::Match((Get-Content $arquivo -Raw), $padrao)
    if ($m.Success) { return $m.Groups[1].Value.Trim() }
    return $null
}

Write-Host '═══ IDENTIDADE DO APP ═══' -ForegroundColor Cyan

# ── Versão: a fonte única, para as duas plataformas ─────────────
$versao = Ler 'pubspec.yaml' '(?m)^version:\s*(.+)$'
Write-Host "`npubspec.yaml"
Write-Host "  version: $versao"

if ($versao -notmatch '^\d+\.\d+\.\d+\+\d+$') {
    $problemas += "version malformada: '$versao'. Use x.y.z+N."
}

# ── iOS ─────────────────────────────────────────────────────────
Write-Host "`n🍎 iOS"

$pbx = 'ios/Runner.xcodeproj/project.pbxproj'
if (Test-Path $pbx) {
    $bundleIds = [regex]::Matches((Get-Content $pbx -Raw), 'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);') |
        ForEach-Object { $_.Groups[1].Value.Trim() } |
        Where-Object { $_ -notmatch '\.RunnerTests$' } |
        Sort-Object -Unique

    Write-Host "  Bundle ID: $($bundleIds -join ', ')"

    # ⚠️ São três ocorrências (Debug, Release, Profile). Valores
    # diferentes = erro silencioso, que só aparece na assinatura.
    if ($bundleIds.Count -gt 1) {
        $problemas += "Bundle IDs DIFERENTES entre configurações: $($bundleIds -join ', ')"
    }

    $bundleId = $bundleIds | Select-Object -First 1

    if ($bundleId -like 'com.example.*') {
        $problemas += "Bundle ID ainda é o de exemplo: $bundleId"
    }
    if ($bundleId -match '_') {
        $problemas += 'Bundle ID com underscore — não é permitido'
    }
    if ($bundleId -cmatch '[A-Z]') {
        $avisos += 'Bundle ID com maiúscula — permitido, mas evite'
    }

    # ── Deployment Target: precisa bater em DOIS lugares ─────────
    $targets = [regex]::Matches((Get-Content $pbx -Raw), 'IPHONEOS_DEPLOYMENT_TARGET = ([^;]+);') |
        ForEach-Object { $_.Groups[1].Value.Trim() } | Sort-Object -Unique

    Write-Host "  Deployment Target (pbxproj): $($targets -join ', ')"

    $podTarget = Ler 'ios/Podfile' "platform :ios, '([^']+)'"
    Write-Host "  Deployment Target (Podfile): $podTarget"

    if ($podTarget -and $targets -and ($targets -notcontains $podTarget)) {
        # Divergência gera avisos em massa no pod install e, às
        # vezes, falha de build — com mensagem que não diz isso.
        $problemas += "Deployment Target divergente: Podfile=$podTarget, pbxproj=$($targets -join ',')"
    }
} else {
    $avisos += 'Pasta ios/ não encontrada'
}

# ── Info.plist ──────────────────────────────────────────────────
$plist = 'ios/Runner/Info.plist'
if (Test-Path $plist) {
    $conteudo = Get-Content $plist -Raw

    # O Info.plist deve REFERENCIAR a variável, não repetir o valor.
    if ($conteudo -match '<key>CFBundleIdentifier</key>\s*<string>\$\(PRODUCT_BUNDLE_IDENTIFIER\)</string>') {
        Write-Host '  Info.plist: usa $(PRODUCT_BUNDLE_IDENTIFIER) ✅' -ForegroundColor Gray
    } else {
        $avisos += 'Info.plist não usa $(PRODUCT_BUNDLE_IDENTIFIER) — confira'
    }

    # A versão também deve vir do pubspec, via variável.
    if ($conteudo -notmatch 'FLUTTER_BUILD_NAME') {
        $avisos += 'Info.plist não usa $(FLUTTER_BUILD_NAME) — a versão pode estar fixa'
    }

    $nome = Ler $plist '(?s)<key>CFBundleDisplayName</key>\s*<string>([^<]+)</string>'
    if ($nome) { Write-Host "  Nome exibido: $nome" }
}

# ── Android, para comparar ──────────────────────────────────────
Write-Host "`n🤖 Android"

$gradle = 'android/app/build.gradle.kts'
$appId = Ler $gradle 'applicationId = "([^"]+)"'
Write-Host "  applicationId: $appId"

if ($appId -and $bundleId -and $appId -ne $bundleId) {
    $avisos += "Identificadores diferentes: iOS=$bundleId, Android=$appId"
}

# ── Generated.xcconfig não deve estar no Git ────────────────────
if (Test-Path '.gitignore') {
    $gi = Get-Content '.gitignore' -Raw
    if ($gi -notmatch 'Generated\.xcconfig') {
        # Ele contém caminhos absolutos da SUA máquina — versioná-lo
        # quebra o projeto para qualquer outra pessoa.
        $avisos += 'ios/Flutter/Generated.xcconfig não está no .gitignore (ele tem caminhos locais)'
    }
}

# ── Resultado ───────────────────────────────────────────────────
Write-Host "`n═══ RESULTADO ═══" -ForegroundColor Cyan

if ($problemas.Count -eq 0 -and $avisos.Count -eq 0) {
    Write-Host '  ✅ Identidade consistente.' -ForegroundColor Green
}
foreach ($a in $avisos)    { Write-Host "  ⚠️  $a" -ForegroundColor Yellow }
foreach ($p in $problemas) { Write-Host "  ❌ $p" -ForegroundColor Red }

Write-Host ''
if ($problemas.Count -gt 0) {
    Write-Host 'Corrija ANTES de levar o projeto para o Mac.' -ForegroundColor Red
    exit 1
}
```

E o roteiro que roda no Mac, para conferir lá:

> **Arquivo:** `ferramentas/abrir-xcode.sh` (novo — roda **no Mac**)

```bash
#!/usr/bin/env bash
# Abre o projeto iOS no Xcode, do jeito certo.
#
# 🍎 SÓ NO MAC.
set -euo pipefail

cd "$(dirname "$0")/.."

# ⚠️ Se o Podfile existe, os pods precisam estar instalados —
# senão o workspace abre sem eles e o build falha com
# "module not found".
if [ -f ios/Podfile ] && [ ! -d ios/Pods ]; then
  echo "Pods não instalados. Rodando pod install…"
  (cd ios && pod install)
fi

# O Generated.xcconfig é escrito pelo Flutter. Sem ele, o Xcode
# não sabe onde está o Flutter nem qual é a versão do app.
if [ ! -f ios/Flutter/Generated.xcconfig ]; then
  echo "Generated.xcconfig ausente. Rodando flutter build…"
  flutter build ios --config-only
fi

echo ""
echo "Bundle ID configurado:"
grep 'PRODUCT_BUNDLE_IDENTIFIER' ios/Runner.xcodeproj/project.pbxproj |
  grep -v RunnerTests | sort -u | sed 's/^[[:space:]]*/  /'

echo ""
# ⭐ .xcworkspace, NUNCA .xcodeproj: o workspace inclui os Pods.
echo "Abrindo Runner.xcworkspace (nunca o .xcodeproj)…"
open ios/Runner.xcworkspace
```

```powershell
.\ferramentas\trocar-bundle-id.ps1 -Novo br.com.estudos.foco -Simular
.\ferramentas\trocar-bundle-id.ps1 -Novo br.com.estudos.foco
.\ferramentas\conferir-identidade.ps1
git diff ios/
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Validar o formato com regex | Underscore não é permitido; maiúscula confunde serviços que normalizam. |
| `-Simular` | Ver o que mudaria antes de mudar. |
| **Backup com carimbo de hora** | O `project.pbxproj` é sensível; restaurar custa um comando. |
| Substituir `.RunnerTests` **primeiro** | Senão a primeira substituição quebraria o sufixo. |
| `-NoNewline` no `Set-Content` | Sem isso, sobra uma linha em branco e o Xcode reclama. |
| Conferir se sobrou algo | Uma das três ocorrências pode ter escapado. |
| Comparar com o `applicationId` | Manter os dois iguais evita confusão eterna. |
| Instrução final do `git diff` | **A rede de proteção**: só linhas de `PRODUCT_BUNDLE_IDENTIFIER` devem mudar. |
| Detectar Bundle IDs **diferentes** entre configurações | Erro silencioso que só aparece na assinatura. |
| Comparar Deployment Target Podfile × pbxproj | Divergência gera avisos em massa e falhas obscuras. |
| Conferir `$(PRODUCT_BUNDLE_IDENTIFIER)` no `Info.plist` | Ele deve **referenciar**, não repetir o valor. |
| Conferir `FLUTTER_BUILD_NAME` | Se não estiver lá, a versão pode estar fixa no `Info.plist`. |
| `Generated.xcconfig` no `.gitignore` | Ele tem **caminhos absolutos** da sua máquina. |
| `abrir-xcode.sh` com `pod install` antes | Workspace sem pods = "module not found". |
| `open ios/Runner.xcworkspace` | **Nunca** o `.xcodeproj`. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Identificador | `applicationId` | **Bundle Identifier** |
| Onde | `build.gradle.kts` | `project.pbxproj` (3×) |
| Formato | Domínio invertido | Domínio invertido |
| Imutável após publicar | ✅ | ✅ |
| Versão mínima | `minSdk = 23` | `IPHONEOS_DEPLOYMENT_TARGET = 13.0` |
| Onde mais | — | ⚠️ Também no `Podfile` |
| Editar à mão | ✅ Tranquilo | ⚠️ Com backup e `git diff` |
| Editável no Windows | ✅ | ✅ **Também** |

> 💡 **O `build.gradle.kts` é código legível; o `project.pbxproj` é um formato de serialização com
> ids gerados.** Essa é a diferença prática: no Android você edita com confiança, no iOS você edita
> com backup. O resultado é o mesmo — e, nas duas plataformas, dá para fazer no Windows.

---

## ⚠️ Erros comuns

### 1. Abrir o `.xcodeproj`

```text
module 'path_provider' not found
```

**Correção:** `open ios/Runner.xcworkspace`.

### 2. Trocar só uma das três ocorrências

Debug e release com identificadores diferentes; falha na assinatura.

**Correção:** as três, e as de `RunnerTests`.

### 3. Publicar com `com.example.*`

A Apple recusa, e seria imutável.

**Correção:** domínio invertido seu.

### 4. Underscore no Bundle ID

Não é permitido.

**Correção:** hífen ou nada.

### 5. Trocar depois de publicar

Vira outro app: sem avaliações, sem usuários.

**Correção:** decida antes.

### 6. Deployment Target divergente

Avisos em massa no `pod install`.

**Correção:** o mesmo número nos dois lugares.

### 7. Editar o Bundle ID no `Info.plist`

Lá é uma variável; o valor está no `project.pbxproj`.

**Correção:** no lugar certo.

### 8. Versionar `Generated.xcconfig`

Ele tem caminhos absolutos da sua máquina.

**Correção:** `.gitignore`.

### 9. Editar o `project.pbxproj` sem backup

Um erro corrompe o projeto.

**Correção:** backup e `git diff`.

### 10. Subir o Deployment Target sem necessidade

Perde usuários sem ganho.

**Correção:** 13.0, salvo exigência de plugin.

### 11. Esquecer `pod install` após mudar o Podfile

Os pods continuam com o alvo antigo.

**Correção:** rode depois de toda alteração.

### 12. Não procurar o detalhe no Report Navigator

A tela mostra uma mensagem genérica.

**Correção:** ⌘9.

---

## 🛠️ Exercício guiado

> 🪟 **Os passos 1 a 7 rodam no Windows.** Os 8 a 10 são para o dia do Mac.

**Passo 1.** Rode `Select-String` no `project.pbxproj`. Quantas ocorrências de
`PRODUCT_BUNDLE_IDENTIFIER`?

**Passo 2.** Quantas são de `RunnerTests`? Por que elas existem?

**Passo 3.** Rode `trocar-bundle-id.ps1 -Simular`. O que ele diria?

**Passo 4.** Rode de verdade e confira com `git diff`. Só mudaram as linhas esperadas?

**Passo 5.** Tente um Bundle ID com underscore. O script recusa?

**Passo 6.** Rode `conferir-identidade.ps1`. Algum problema?

**Passo 7.** Mude o `platform :ios` do Podfile para `'12.0'` e rode o verificador de novo.

**Passo 8.** 🍎 No Mac, abra o `.xcodeproj` e tente compilar. Que erro?

**Passo 9.** 🍎 Abra o `.xcworkspace`. Compila?

**Passo 10.** 🍎 Abra o Report Navigator (⌘9) e leia o log da última build.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-ios.md](../../exercicios/15-build-ios.md)

Faça os de **Aplicação** (definir o Bundle ID) e o de **Reflexão** (escolher o identificador do seu
app, justificando).

---

## 🏆 Desafio opcional

Escreva um **verificador de identidade multiplataforma** que rode no CI.

Requisitos:

- Lê `pubspec.yaml`, `build.gradle.kts`, `project.pbxproj`, `Info.plist` e `Podfile`.
- Falha se: os identificadores divergirem entre as plataformas; alguma configuração tiver Bundle ID
  diferente; a versão estiver malformada; sobrar `com.example`.
- Avisa se o Deployment Target divergir entre `Podfile` e `pbxproj`.
- Roda em Windows, macOS e Linux (escreva em **Dart**, não em PowerShell).
- Um teste para cada regra.

Depois responda: por que escrever isso em Dart é melhor que em PowerShell ou Bash, num projeto
Flutter? (Dica: pense em quem vai manter o script e no que já está instalado na máquina de quem
clona o repositório.)

---

## 📌 Resumo

- O **Bundle Identifier** é o domínio invertido do app, **único na App Store** e **imutável** depois
  de publicado.
- Ele amarra **App ID, provisioning, certificado, App Store Connect e push** — mudar obriga a
  refazer tudo.
- Ele mora em `project.pbxproj`, em **três ocorrências** (Debug, Release, Profile) — mais as de
  `RunnerTests`.
- O `Info.plist` **referencia** `$(PRODUCT_BUNDLE_IDENTIFIER)`; não repita o valor lá.
- 🪟 **Tudo isso é texto e se edita no Windows** — com backup e `git diff` como rede.
- **Abra o `.xcworkspace`, nunca o `.xcodeproj`**: sem os pods, "module not found".
- **Report Navigator (⌘9)** é onde está o log real do build — a tela mostra o genérico.
- **Deployment Target iOS 13** é o padrão; precisa bater no `Podfile` **e** no `project.pbxproj`.
- Um plugin pode exigir um alvo maior — suba nos dois lugares e rode `pod install`.
- `Generated.xcconfig` é **gerado**: não edite, não versione (tem caminhos absolutos).
- `FLUTTER_BUILD_NAME` e `FLUTTER_BUILD_NUMBER` vêm do **`pubspec.yaml`**.
- Manter o Bundle ID **igual** ao `applicationId` do Android evita confusão.

---

## ☑️ Checklist de domínio

- [ ] Explico o que é o Bundle ID e por que é imutável.
- [ ] Escolhi o meu em domínio invertido.
- [ ] Sei que ele aparece três vezes no `project.pbxproj`.
- [ ] Troquei o do projeto e conferi com `git diff`.
- [ ] Sei por que se abre o `.xcworkspace`.
- [ ] Sei onde fica o Report Navigator.
- [ ] Entendo o Deployment Target e onde ele precisa bater.
- [ ] Sei que `Generated.xcconfig` não se versiona.
- [ ] Sei de onde vem a versão do app iOS.
- [ ] Meus identificadores Android e iOS são consistentes.
- [ ] Rodei o verificador de identidade sem problemas.

---

## 📚 Referências oficiais

- [Build and release an iOS app — docs.flutter.dev](https://docs.flutter.dev/deployment/ios)
- [Bundle ID — developer.apple.com](https://developer.apple.com/documentation/appstoreconnectapi/bundle_ids)
- [Configuring a new target — developer.apple.com](https://developer.apple.com/documentation/xcode/configuring-a-new-target-in-your-project)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Information Property List — developer.apple.com](https://developer.apple.com/documentation/bundleresources/information_property_list)
- [CocoaPods — Podfile syntax](https://guides.cocoapods.org/syntax/podfile.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Simulador e iPhone físico](03-simulador-e-iphone-fisico.md) | [README](README.md) | [Aula 5 — Ícone, splash, versão e Info.plist](05-icone-splash-versao-infoplist.md) |
