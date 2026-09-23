# Aula 3 — Versionamento e releases

> **Módulo:** 17 - Publicação e próximos passos · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Aplicar **SemVer** (`MAJOR.MINOR.PATCH`) com critério, e decidir qual número subir.
- Entender como `version: 1.0.0+1` vira `versionName`/`versionCode` e
  `CFBundleShortVersionString`/`CFBundleVersion`.
- Marcar releases com **tags Git** e manter um **CHANGELOG** que alguém leia.
- Fazer **rollout gradual** na Play Console e entender por que a Apple não tem o equivalente.
- Executar um **rollback** no Android — e saber que ele não existe no iOS.
- Planejar um **hotfix** e o fluxo de branches que o torna possível.

## ✅ Pré-requisitos

- [Aula 2 — App Store Connect](02-app-store-connect.md) — app registrado nas duas lojas.
- [Módulo 15, aula 8 — Gerando APK e AAB](../15-build-android/08-gerando-apk-e-aab.md) — o
  `versionCode` que precisa crescer.
- [Módulo 16, aula 9 — TestFlight](../16-build-ios/09-exportando-ipa-e-testflight.md) — o
  `CFBundleVersion` que também precisa.
- [Módulo 00 — Git e terminal](../00-git-e-terminal/README.md) — tags e branches.

---

## 📖 Conceito

### SemVer

```text
1.4.2
│ │ └── PATCH — correção de bug, sem mudança de comportamento
│ └──── MINOR — recurso novo, compatível
└────── MAJOR — mudança incompatível
```

| Mudança | Sobe |
|---|---|
| Corrigiu um travamento | **PATCH** (1.4.2 → 1.4.3) |
| Novo gráfico de progresso | **MINOR** (1.4.3 → 1.5.0) |
| Redesenho completo, banco incompatível | **MAJOR** (1.5.0 → 2.0.0) |
| Ajuste de texto, cor | PATCH |
| Nova tela inteira | MINOR |

> 💡 **Num app, "incompatível" quer dizer algo diferente de numa biblioteca.** Não há quem consuma a
> sua API. O MAJOR de um app costuma marcar uma **reformulação que o usuário percebe** — ou uma
> migração de dados sem volta.

E há uma pergunta prática antes da teoria:

> 📌 **O usuário vê o `versionName`.** "1.4.2" numa tela de Ajustes é informação; "2.0.0" é
> promessa. Suba o MAJOR quando o app **parecer** novo, não só quando o código mudar muito.

### `1.0.0+1`

```yaml
# pubspec.yaml — a fonte ÚNICA das duas plataformas
version: 1.4.2+37
#        ^^^^^ nome (o usuário vê)   ^^ build (o usuário NÃO vê)
```

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Nome | `versionName` = `1.4.2` | `CFBundleShortVersionString` |
| Build | `versionCode` = `37` | `CFBundleVersion` |
| Usuário vê | Só o nome | Só o nome |
| **Precisa crescer** | ✅ Sempre | ✅ Sempre |
| Reaproveitável | ❌ Nunca | ❌ Nunca |

> ⚠️ **O `+N` cresce sempre, independente da versão.** `1.0.0+1`, `1.0.1+2`, `1.1.0+3`, `2.0.0+4`.
> Nunca reinicie — nem ao subir o MAJOR. Nenhum número volta a ficar livre, nem de um build que
> você mesmo descartou.

```text
1.0.0+1   → primeira publicação
1.0.1+2   → correção
1.0.1+3   → a mesma correção, build novo (o anterior foi rejeitado)
1.1.0+4   → recurso novo
```

> 📌 **Repare no `1.0.1+3`:** o nome não mudou, porque para o usuário é a mesma versão. O build
> mudou, porque é outro binário. Essa é exatamente a distinção entre os dois números.

### Tags Git

```bash
# Anotada (com mensagem e autor), não leve.
git tag -a v1.4.2 -m "Gráfico de progresso semanal"
git push origin v1.4.2

git tag -l                 # listar
git show v1.4.2            # ver
git checkout v1.4.2        # voltar no tempo
```

| | Tag leve (`git tag v1`) | **Tag anotada** (`-a`) |
|---|---|---|
| Guarda autor e data | ❌ | ✅ |
| Guarda mensagem | ❌ | ✅ |
| Dispara CI por `tags: ['v*']` | ✅ | ✅ |
| Recomendada | ❌ | ✅ |

> 💡 **A tag é o que liga o app publicado ao código exato que o gerou.** Seis meses depois, com um
> crash vindo da versão 1.4.2, é `git checkout v1.4.2` que mostra o código de verdade — e é ela que
> casa com os símbolos arquivados naquela versão (módulo 13, aula 7).

### CHANGELOG

```markdown
# Changelog

## [1.4.2] — 2026-09-14

### Corrigido
- O app travava ao excluir a última matéria
- O resumo semanal não somava sessões de domingo

## [1.4.0] — 2026-08-30

### Adicionado
- Gráfico de progresso semanal
- Exportar sessões em CSV

### Alterado
- A lista de matérias agora ordena por nome, não por data
```

| Categoria | Para quê |
|---|---|
| `Adicionado` | Recursos novos |
| `Alterado` | Comportamento que mudou |
| `Corrigido` | Bugs |
| `Removido` | O que saiu |
| `Segurança` | Correções de segurança |

> 📌 **O CHANGELOG serve a duas audiências, e por isso costuma render dois textos:** o técnico, no
> repositório, e o **"Novidades"** da loja, escrito para o usuário. "Corrigido: race condition no
> `SessaoRepository`" vira "Corrigimos um erro que apagava sessões ao sincronizar".

### Rollout gradual

Na Play Console, você pode liberar a versão para uma **fração** dos usuários:

```text
Produção → Criar versão → Rollout: 5%
  ↓ 24 h, olhando crashes e avaliações
  20%
  ↓ 24 h
  50%
  ↓
  100%
```

| % | Quando avançar |
|---|---|
| 5 % | Taxa de crash estável por 24 h |
| 20 % | Idem |
| 50 % | Idem |
| 100 % | Sem surpresas |

> ⚠️ **O rollout gradual não existe na App Store da mesma forma.** A Apple tem "Phased Release", que
> distribui automaticamente ao longo de **7 dias** — mas em ritmo fixo, e você só pode **pausar**,
> não escolher a fração. Em compensação, a revisão humana filtra antes.

### Rollback

Aqui está uma das maiores diferenças entre as lojas:

| | 🤖 Google Play | 🍎 App Store |
|---|---|---|
| Interromper o rollout | ✅ Imediato | ⚠️ Pausar o phased release |
| **Voltar à versão anterior** | ✅ **Sim** | ❌ **Não** |
| Como | Reativar a versão antiga | Publicar uma nova |
| Quem já atualizou | Fica na versão nova | Fica na versão nova |

> ⚠️ **No iOS não existe rollback.** Se a 1.4.2 tem um bug grave, a única saída é publicar a
> **1.4.3** — e esperar a revisão da Apple, que leva de horas a dias. É por isso que o TestFlight
> interno (módulo 16, aula 9) importa tanto: **no iOS, o erro que escapa custa dias.**

> 📌 **E nas duas lojas, quem já atualizou continua na versão nova.** O rollback do Android impede
> que **mais** pessoas recebam a versão ruim; ele não desfaz as instalações já feitas. Não é um
> desfazer — é um "parem de espalhar".

### Hotfix

```text
main ────●────────────●───────  (1.4.2 publicada)
          \          /
           ●────────●            hotfix/1.4.3
           corrige   merge
```

```bash
git checkout -b hotfix/1.4.3 v1.4.2   # ⭐ a partir da TAG, não da main
# corrige só o necessário
# sobe a versão para 1.4.3+38
git commit -am "Corrige travamento ao excluir a última matéria"
git tag -a v1.4.3 -m "Hotfix: travamento na exclusão"
git checkout main && git merge hotfix/1.4.3
git push origin main v1.4.3
```

> 📌 **Partir da tag, não da `main`.** A `main` pode já ter recursos pela metade; o hotfix precisa
> ser **a versão publicada mais a correção**, e nada além. É justamente por isso que a tag existe.

E a regra do hotfix:

> ⚠️ **Um hotfix corrige uma coisa.** A tentação de "já que estou aqui" é como o hotfix vira um
> release mal testado. Se algo mais precisa entrar, é outro release.

---

## 💡 Analogia

Pense nas **edições de um livro**.

- **MAJOR** é a **nova edição**: capítulos reescritos, numeração de páginas diferente. Quem cita a
  edição anterior precisa refazer as referências.
- **MINOR** é uma **reimpressão ampliada**: um capítulo novo no fim, o resto igual.
- **PATCH** é a **correção de erratas**: três vírgulas e um nome próprio.
- **O `versionName` é o que está na capa** — o leitor lê "3ª edição". **O `versionCode` é o número
  da tiragem**, que só a gráfica controla, e que **nunca se repete**, nem o de uma tiragem
  descartada por defeito.
- **A tag Git** é o exemplar arquivado da editora: quando alguém reclamar de um erro na 3ª edição,
  é esse exemplar que se consulta — não o manuscrito atual, que já tem o quarto capítulo pela
  metade.
- **O rollout gradual** é distribuir primeiro para cinco livrarias. Se voltarem reclamações, você
  para antes de espalhar pelo país.
- **E o rollback do Android** é recolher a remessa **que ainda não saiu do depósito**. Os exemplares
  já vendidos continuam nas casas das pessoas — e é por isso que ele não é um "desfazer", mas um
  "parem de distribuir".
- **No iOS não há recolhimento.** Com a remessa na rua, a única saída é imprimir a errata — e
  esperar o revisor da editora aprová-la. Daí a importância de ler as provas antes.
- **E o hotfix parte do exemplar arquivado**, não do manuscrito atual. Corrigir uma vírgula não é
  desculpa para publicar o capítulo inacabado.

---

## 🧪 Exemplo mínimo

Um ciclo de release completo.

**Passo 1 — decidir a versão:**

```text
O que mudou: corrigiu um travamento
→ PATCH: 1.4.1 → 1.4.2
→ O build sempre cresce: +36 → +37
```

**Passo 2 — `pubspec.yaml`:**

```yaml
version: 1.4.2+37
```

**Passo 3 — CHANGELOG:**

```markdown
## [1.4.2] — 2026-09-14

### Corrigido
- O app travava ao excluir a última matéria
```

**Passo 4 — commit e tag:**

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: versão 1.4.2+37"
git tag -a v1.4.2 -m "Corrige travamento ao excluir a última matéria"
git push origin main v1.4.2
```

**Passo 5 — build das duas plataformas:**

```powershell
.\tool\release.ps1 -Formato aab          # módulo 15, aula 8
```

```bash
./ferramentas/build-ios.sh               # módulo 16, aula 8
```

**Passo 6 — publicar:**

```text
🤖 Play Console → Produção → rollout 5%
🍎 App Store Connect → enviar para revisão
```

**Passo 7 — acompanhar 24 h**, e então subir o rollout.

> 📌 **Repare na ordem: a tag vem ANTES do build.** É ela que garante que o binário publicado
> corresponde exatamente àquele commit — e é o que permite, meses depois, `git checkout v1.4.2` e
> ver o código real.

---

## 📱 Aplicando no Flutter

O roteiro que conduz o release inteiro, com as validações que evitam os erros desta aula.

---

## 💻 Código completo

> **Arquivo:** `tool/nova-versao.ps1` (novo)
> **Como executar:** `powershell -ExecutionPolicy Bypass -File tool/nova-versao.ps1 -Tipo patch`

```powershell
# Prepara uma nova versão: sobe os números, atualiza o CHANGELOG,
# commita e cria a tag.
#
# Não faz o build — isso é tool/release.ps1 (módulo 15, aula 8).
# Aqui se cuida da PARTE QUE SE ESQUECE: numeração, changelog e tag.

param(
    [ValidateSet('major', 'minor', 'patch', 'build')]
    [string]$Tipo = 'patch',

    [switch]$Simular
)

$ErrorActionPreference = 'Stop'

# ══════════════════════════════════════════════════════════════
# 1. Repositório limpo?
# ══════════════════════════════════════════════════════════════
$sujo = git status --porcelain
if ($sujo) {
    Write-Host '❌ Há alterações não commitadas:' -ForegroundColor Red
    $sujo | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
    Write-Host ''
    Write-Host 'Uma tag precisa apontar para um estado CONHECIDO.' -ForegroundColor Yellow
    Write-Host 'Commite ou descarte antes.' -ForegroundColor Yellow
    exit 1
}

# ══════════════════════════════════════════════════════════════
# 2. Versão atual
# ══════════════════════════════════════════════════════════════
$conteudo = Get-Content pubspec.yaml -Raw
$m = [regex]::Match($conteudo, '(?m)^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$')

if (-not $m.Success) {
    throw 'Não achei uma versão no formato x.y.z+N no pubspec.yaml'
}

$major = [int]$m.Groups[1].Value
$minor = [int]$m.Groups[2].Value
$patch = [int]$m.Groups[3].Value
$build = [int]$m.Groups[4].Value

$atual = "$major.$minor.$patch+$build"
Write-Host "Versão atual: $atual" -ForegroundColor Cyan

# ══════════════════════════════════════════════════════════════
# 3. Nova versão
# ══════════════════════════════════════════════════════════════
switch ($Tipo) {
    'major' { $major++; $minor = 0; $patch = 0 }
    'minor' { $minor++; $patch = 0 }
    'patch' { $patch++ }
    'build' { }   # só o build: mesmo nome, binário novo
}

# ⭐ O build SEMPRE cresce, em qualquer tipo — inclusive no major.
# Nenhum número volta a ficar livre, nem de build descartado.
$build++

$nova = "$major.$minor.$patch+$build"
$novoNome = "$major.$minor.$patch"

Write-Host "Nova versão:  $nova" -ForegroundColor Green

if ($Tipo -eq 'build') {
    Write-Host '  (mesmo nome, binário novo — para reenvio após rejeição)' -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
# 4. A tag já existe?
# ══════════════════════════════════════════════════════════════
$tag = "v$novoNome"
$existente = git tag -l $tag

if ($existente -and $Tipo -ne 'build') {
    Write-Host ''
    Write-Host "❌ A tag $tag já existe." -ForegroundColor Red
    Write-Host '   Se esta versão já foi publicada, use um número maior.' -ForegroundColor Yellow
    exit 1
}

# ══════════════════════════════════════════════════════════════
# 5. O que mudou desde a última tag
# ══════════════════════════════════════════════════════════════
$ultimaTag = git describe --tags --abbrev=0 2>$null

Write-Host ''
if ($ultimaTag) {
    Write-Host "Commits desde $ultimaTag :" -ForegroundColor Cyan
    git log "$ultimaTag..HEAD" --oneline | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host 'Primeira tag do repositório.' -ForegroundColor Cyan
}

if ($Simular) {
    Write-Host ''
    Write-Host '(simulação: nada foi alterado)' -ForegroundColor Cyan
    exit 0
}

# ══════════════════════════════════════════════════════════════
# 6. CHANGELOG
# ══════════════════════════════════════════════════════════════
Write-Host ''
Write-Host 'Descreva a mudança para o CHANGELOG.' -ForegroundColor Cyan
Write-Host 'Escreva para quem VAI LER, não para você.' -ForegroundColor Gray
Write-Host 'Uma linha por item; linha vazia encerra.' -ForegroundColor Gray
Write-Host ''

$categoria = switch ($Tipo) {
    'major' { 'Alterado' }
    'minor' { 'Adicionado' }
    default { 'Corrigido' }
}
Write-Host "### $categoria" -ForegroundColor Yellow

$itens = @()
while ($true) {
    $linha = Read-Host '  -'
    if ([string]::IsNullOrWhiteSpace($linha)) { break }
    $itens += $linha
}

if ($itens.Count -eq 0) {
    Write-Host '⚠️  CHANGELOG vazio. Uma versão sem descrição é uma versão que ninguém entende.' -ForegroundColor Yellow
    if ((Read-Host 'Continuar assim? (s/N)') -ne 's') { exit 1 }
}

$entrada = @"
## [$novoNome] — $(Get-Date -Format 'yyyy-MM-dd')

### $categoria
$($itens | ForEach-Object { "- $_" } | Out-String)
"@

if (Test-Path CHANGELOG.md) {
    $changelog = Get-Content CHANGELOG.md -Raw
    # Insere depois do cabeçalho, mantendo o mais recente no topo.
    if ($changelog -match '(?m)^# Changelog\s*$') {
        $changelog = $changelog -replace '(?m)^(# Changelog\s*)$', "`$1`n`n$entrada"
    } else {
        $changelog = "$entrada`n$changelog"
    }
    Set-Content CHANGELOG.md -Value $changelog -Encoding utf8
} else {
    Set-Content CHANGELOG.md -Value "# Changelog`n`n$entrada" -Encoding utf8
}

# ══════════════════════════════════════════════════════════════
# 7. pubspec.yaml
# ══════════════════════════════════════════════════════════════
$conteudo = $conteudo -replace '(?m)^version:\s*.+$', "version: $nova"
Set-Content pubspec.yaml -Value $conteudo -NoNewline -Encoding utf8

# ══════════════════════════════════════════════════════════════
# 8. Commit e tag
# ══════════════════════════════════════════════════════════════
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: versão $nova"

$mensagemTag = if ($itens.Count -gt 0) { $itens[0] } else { "Versão $novoNome" }

# ⭐ Tag ANOTADA (-a): guarda autor, data e mensagem.
# A leve não guarda nada, e some do `git describe`.
git tag -a $tag -m $mensagemTag

Write-Host ''
Write-Host '════════════════════════════════════════' -ForegroundColor Green
Write-Host " $nova preparada" -ForegroundColor Green
Write-Host '════════════════════════════════════════' -ForegroundColor Green
Write-Host ''
Write-Host 'Agora:' -ForegroundColor Cyan
Write-Host "  1. git push origin main $tag"
Write-Host '  2. .\tool\release.ps1             (Android — módulo 15, aula 8)'
Write-Host '  3. ./ferramentas/build-ios.sh     (iOS — módulo 16, aula 8)'
Write-Host '  4. 🤖 Play Console → rollout 5%'
Write-Host '  5. 🍎 App Store Connect → revisão'
Write-Host ''
Write-Host '  ⚠️ No iOS não há rollback: se der errado, só publicando' -ForegroundColor Yellow
Write-Host '     outra versão e esperando a revisão.' -ForegroundColor Yellow
```

E o roteiro de hotfix:

> **Arquivo:** `tool/hotfix.ps1` (novo)

```powershell
# Cria um branch de hotfix a partir da versão PUBLICADA.
#
# ⭐ O ponto de partida é a TAG, não a main: a main pode ter
# recursos pela metade, e o hotfix precisa ser a versão
# publicada MAIS a correção, e nada além.

param(
    # A tag da versão que está em produção. Vazio = a última.
    [string]$DeTag
)

$ErrorActionPreference = 'Stop'

if (-not $DeTag) {
    $DeTag = git describe --tags --abbrev=0
    Write-Host "Usando a última tag: $DeTag" -ForegroundColor Cyan
}

if (-not (git tag -l $DeTag)) {
    Write-Host "❌ Tag não encontrada: $DeTag" -ForegroundColor Red
    Write-Host ''
    Write-Host 'Tags disponíveis:' -ForegroundColor Yellow
    git tag -l --sort=-v:refname | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
    exit 1
}

$sujo = git status --porcelain
if ($sujo) {
    Write-Host '❌ Commite ou descarte as alterações antes.' -ForegroundColor Red
    exit 1
}

# Calcula a versão do hotfix: PATCH +1.
$versaoTag = $DeTag -replace '^v', ''
if ($versaoTag -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
    throw "Tag em formato inesperado: $DeTag"
}
$novoPatch = [int]$Matches[3] + 1
$novaVersao = "$($Matches[1]).$($Matches[2]).$novoPatch"
$branch = "hotfix/$novaVersao"

Write-Host ''
Write-Host "  base:   $DeTag (o que está em produção)" -ForegroundColor Gray
Write-Host "  hotfix: $novaVersao" -ForegroundColor Green
Write-Host "  branch: $branch" -ForegroundColor Green
Write-Host ''

git checkout -b $branch $DeTag

Write-Host ''
Write-Host "✅ Branch $branch criado a partir de $DeTag" -ForegroundColor Green
Write-Host ''
Write-Host '⚠️  REGRA DO HOTFIX: corrija UMA coisa.' -ForegroundColor Yellow
Write-Host '   "Já que estou aqui" é como hotfix vira release' -ForegroundColor Yellow
Write-Host '   mal testado. Se algo mais precisa entrar, é outro release.' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Depois de corrigir:' -ForegroundColor Cyan
Write-Host "  1. .\tool\nova-versao.ps1 -Tipo patch"
Write-Host "  2. git checkout main; git merge $branch"
Write-Host "  3. git push origin main v$novaVersao"
Write-Host '  4. Build e publique'
```

E o modelo de CHANGELOG:

> **Arquivo:** `CHANGELOG.md`

```markdown
# Changelog

Todas as mudanças relevantes deste projeto.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Adicionado
-

## [1.0.0] — 2026-09-14

### Adicionado
- Primeira versão
- Cadastro de matérias e registro de sessões de estudo
- Resumo semanal com total de minutos
- Funciona offline

<!--
Categorias:
  Adicionado · recursos novos
  Alterado   · comportamento que mudou
  Corrigido  · bugs
  Removido   · o que saiu
  Segurança  · correções de segurança

⚠️ Este arquivo é técnico. O texto de "Novidades" da loja é OUTRO,
   escrito para o usuário:

   Técnico: "Corrigido: race condition no SessaoRepository"
   Loja:    "Corrigimos um erro que apagava sessões ao sincronizar"
-->
```

```powershell
.\tool\nova-versao.ps1 -Tipo patch -Simular
.\tool\nova-versao.ps1 -Tipo patch
git push origin main v1.4.2
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Recusar repositório sujo | Uma tag precisa apontar para um estado **conhecido**. |
| `$build++` em **todos** os tipos | Nenhum número é reaproveitável, nem no MAJOR. |
| Tipo `build` | Mesmo nome, binário novo — para reenviar após rejeição. |
| Recusar tag existente | Evita sobrescrever a marca de uma versão publicada. |
| Listar commits desde a última tag | Mostra o que entrou, para você escrever o CHANGELOG. |
| Categoria sugerida pelo tipo | `patch` → Corrigido, `minor` → Adicionado. |
| Avisar CHANGELOG vazio | "Uma versão sem descrição é uma versão que ninguém entende." |
| **`git tag -a`** | Tag anotada guarda autor, data e mensagem; a leve não guarda nada. |
| Tag **antes** do build | Garante que o binário corresponde àquele commit. |
| `hotfix.ps1` partindo da **tag** | A `main` pode ter recursos pela metade. |
| Aviso "corrija uma coisa" | "Já que estou aqui" é como hotfix vira release mal testado. |
| Lembrete de que o iOS não tem rollback | Muda o cuidado que se toma antes de publicar. |
| Comentário no CHANGELOG sobre os dois textos | Técnico e loja têm audiências diferentes. |

---

## 🤖🍎 Android × iOS

| | 🤖 Google Play | 🍎 App Store |
|---|---|---|
| Nome da versão | `versionName` | `CFBundleShortVersionString` |
| Build | `versionCode` | `CFBundleVersion` |
| Revisão | Automática, horas | **Humana, 1–3 dias** |
| Rollout gradual | ✅ Você escolhe a % | ⚠️ Phased release, 7 dias fixos |
| Pausar o rollout | ✅ | ✅ |
| **Rollback** | ✅ **Sim** | ❌ **Não** |
| Correção urgente | Horas | ⚠️ Dias (ou revisão expedita) |
| Revisão expedita | — | ✅ Pedido justificado |

> ⚠️ **A ausência de rollback no iOS muda o processo, não só a ferramenta.** No Android, você pode
> publicar com 5 % e recuar se algo aparecer. No iOS, o que saiu, saiu — e a correção passa pela
> revisão. Por isso o TestFlight interno deixa de ser opcional: **é o único lugar em que um erro
> ainda custa barato.**

> 💡 A Apple aceita **pedidos de revisão expedita** para casos críticos — um app que trava na
> abertura, uma falha de segurança. É um formulário, não um botão, e usar sem necessidade queima o
> recurso para quando você realmente precisar.

---

## ⚠️ Erros comuns

### 1. Reiniciar o `+N` em versão nova

Colide com um número já usado.

**Correção:** o build cresce sempre.

### 2. Esquecer de subir o build

`ITMS-4238` no iOS, upload recusado no Android.

**Correção:** automatize com `nova-versao.ps1`.

### 3. Tag depois do build

O binário pode não corresponder ao commit.

**Correção:** tag antes.

### 4. Tag leve

Sem autor, data nem mensagem.

**Correção:** `git tag -a`.

### 5. Hotfix a partir da `main`

Leva recursos pela metade para produção.

**Correção:** parte da **tag**.

### 6. Hotfix com "já que estou aqui"

Vira release mal testado.

**Correção:** uma coisa por hotfix.

### 7. CHANGELOG técnico na loja

O usuário não sabe o que é race condition.

**Correção:** dois textos.

### 8. Rollout de 100 % direto

Todo mundo recebe o bug ao mesmo tempo.

**Correção:** comece com 5 %.

### 9. Contar com rollback no iOS

Ele não existe.

**Correção:** teste mais antes.

### 10. MAJOR por volume de código

O usuário vê o número.

**Correção:** MAJOR quando o app **parece** novo.

### 11. Publicar sem tag

Impossível saber que código gerou o binário.

**Correção:** sempre marque.

### 12. Não versionar o CHANGELOG

Some junto com a memória.

**Correção:** no repositório.

---

## 🛠️ Exercício guiado

**Passo 1.** Veja a versão atual no `pubspec.yaml`. Qual o nome e qual o build?

**Passo 2.** Rode `nova-versao.ps1 -Tipo patch -Simular`. Que números ele propôs?

**Passo 3.** Rode `-Tipo major -Simular`. O build reiniciou ou continuou?

**Passo 4.** Rode de verdade com `-Tipo patch` e escreva o CHANGELOG.

**Passo 5.** Veja a tag criada: `git show v<versão>`. Ela tem autor e mensagem?

**Passo 6.** Faça uma alteração sem commitar e rode o script. Ele recusa?

**Passo 7.** Rode `hotfix.ps1`. De qual tag ele partiu?

**Passo 8.** Compare `git log main -3` com `git log hotfix/... -3`. Qual a diferença?

**Passo 9.** Escreva o texto de "Novidades" da loja para a sua última versão. Ele é diferente do
CHANGELOG?

**Passo 10.** Descreva, por escrito, o que você faria se a sua versão atual tivesse um bug grave —
no Android e no iOS. As respostas são iguais?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/17-publicacao-e-proximos-passos.md](../../exercicios/17-publicacao-e-proximos-passos.md)

Faça os de **Aplicação** (ciclo de release completo) e o de **Reflexão** (plano de resposta a um bug
em produção).

---

## 🏆 Desafio opcional

Monte a **política de release** do seu projeto — o documento que responde "como publicamos".

Requisitos:

- Quando sobe MAJOR, MINOR e PATCH, com exemplos do **seu** app.
- O fluxo de branches: onde nasce um recurso, onde nasce um hotfix.
- O checklist pré-release, unindo os módulos 15 e 16.
- A política de rollout: de quantos em quantos por cento, quanto tempo entre eles, e **qual métrica
  faz você parar**.
- O procedimento de emergência para Android **e** para iOS — eles são diferentes.
- Quem decide publicar, e quem decide reverter.

Depois responda: quanto tempo se passa, no seu processo, entre "descobrimos o bug" e "a correção
está nas mãos do usuário"? Faça a conta para as duas plataformas — e veja se o número muda alguma
decisão sua sobre o quanto testar antes.

---

## 📌 Resumo

- **SemVer**: MAJOR incompatível, MINOR recurso, PATCH correção.
- Num app, **MAJOR é quando o app parece novo** para o usuário, não quando o código mudou muito.
- `version: 1.4.2+37` no `pubspec` alimenta **as duas plataformas**.
- **O `+N` cresce sempre**, em qualquer tipo de versão. **Nunca reinicie.**
- Nenhum número de build é reaproveitável — nem de build descartado.
- **Tag anotada (`-a`)**, e **antes do build**: é o que liga o binário ao código.
- O **CHANGELOG** tem duas audiências: o técnico, no repo, e o "Novidades", para o usuário.
- **Rollout gradual**: 5 % → 20 % → 50 % → 100 %, com 24 h de observação.
- 🍎 A Apple tem **phased release** de 7 dias, em ritmo fixo — você só pode pausar.
- **🤖 O Android tem rollback; 🍎 o iOS não.** No iOS, a correção passa pela revisão.
- Rollback impede que **mais** pessoas recebam — não desfaz as instalações feitas.
- **Hotfix parte da tag**, não da `main`, e corrige **uma** coisa.
- A ausência de rollback no iOS é o que torna o **TestFlight interno** indispensável.

---

## ☑️ Checklist de domínio

- [ ] Sei decidir entre MAJOR, MINOR e PATCH.
- [ ] Entendo como `x.y.z+N` vira versão nas duas plataformas.
- [ ] Nunca reinicio o build number.
- [ ] Crio tags anotadas, antes do build.
- [ ] Mantenho um CHANGELOG.
- [ ] Escrevo um texto diferente para a loja.
- [ ] Uso rollout gradual no Android.
- [ ] Sei que o iOS não tem rollback.
- [ ] Sei fazer um hotfix a partir da tag.
- [ ] Limito o hotfix a uma correção.
- [ ] Tenho um plano de emergência para cada plataforma.

---

## 📚 Referências oficiais

- [Semantic Versioning 2.0.0](https://semver.org/lang/pt-BR/)
- [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
- [Version your app — developer.android.com](https://developer.android.com/studio/publish/versioning)
- [Release an app — Play Console Help](https://support.google.com/googleplay/android-developer/answer/9859348)
- [Staged rollouts — Play Console Help](https://support.google.com/googleplay/android-developer/answer/6346149)
- [Phased release — App Store Connect Help](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases)
- [Expedited review — developer.apple.com](https://developer.apple.com/contact/app-store/?topic=expedite)
- [Git tagging — git-scm.com](https://git-scm.com/book/pt-br/v2/Fundamentos-de-Git-Tagging)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [App Store Connect](02-app-store-connect.md) | [README](README.md) | [CI/CD introdutório](04-ci-cd-introdutorio.md) |
