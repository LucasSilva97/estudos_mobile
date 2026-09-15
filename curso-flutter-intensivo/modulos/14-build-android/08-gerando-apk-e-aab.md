# Aula 8 — Gerando APK e AAB

> **Módulo:** 14 - Build e Distribuição Android · **Tempo estimado:** 50 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar a diferença entre **APK** e **AAB** — e quando usar cada um.
- Entender **ABIs** (`arm64-v8a`, `armeabi-v7a`, `x86_64`) e por que isso dobra o tamanho.
- Usar **`--split-per-abi`** e saber o efeito no `versionCode`.
- Gerar um AAB assinado e ofuscado, com os símbolos arquivados.
- Medir o resultado com **`--analyze-size`** e agir sobre o que ele mostra.
- Saber **onde cada artefato é gravado** e o que enviar para quem.
- Montar um script único de release, do zero ao arquivo pronto.

## ✅ Pré-requisitos

- [Aula 7 — Assinatura no Gradle](07-assinatura-no-gradle.md) — **essencial**: sem assinatura
  configurada, o build de release falha (de propósito).
- [Aula 6 — Keystore](06-keystore.md) — a chave e as senhas.
- [Módulo 13, aula 7 — Ofuscação](../13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) —
  `--obfuscate` e `--split-debug-info`.
- [Módulo 13, aula 4 — Medindo desempenho](../13-desempenho-e-seguranca/04-medindo-desempenho.md) —
  `--analyze-size`.

---

## 📖 Conceito

### APK × AAB

```text
APK  = o app pronto, instalável        → você entrega ao USUÁRIO
AAB  = as peças do app, empacotadas    → você entrega à PLAY CONSOLE,
                                          que monta o APK de cada aparelho
```

| | APK | **AAB** |
|---|---|---|
| Instalável direto | ✅ | ❌ |
| Aceito pela Play Console | ⚠️ Só apps antigos | ✅ **Obrigatório para novos** |
| Tamanho do download | Grande (tudo dentro) | **30–40 % menor** |
| Contém todas as ABIs | ✅ | ✅, mas o usuário baixa **uma** |
| Contém todas as densidades | ✅ | ✅, mas o usuário baixa **uma** |
| Contém todos os idiomas | ✅ | ✅, mas o usuário baixa **um** |
| Testar em aparelho | ✅ Direto | ⚠️ Precisa do `bundletool` |
| Distribuir fora da loja | ✅ | ❌ |

> 📌 **A regra prática:** **AAB para a Play Console, APK para todo o resto** — teste em aparelho,
> distribuição direta, lojas alternativas, download do seu site.

O ganho do AAB vem da **entrega dividida**: a Play monta, para cada aparelho, um APK contendo só a
ABI, a densidade de tela e o idioma daquele aparelho.

```text
APK universal:   45 MB   ← todo mundo baixa tudo
AAB → aparelho:  28 MB   ← só o que aquele aparelho usa
```

### ABIs

ABI é a arquitetura do processador. O código Dart compilado (AOT) é **nativo** — e precisa existir
uma cópia por arquitetura:

| ABI | Aparelhos | Fatia do mercado |
|---|---|---|
| `arm64-v8a` | Praticamente todos desde 2017 | ~95 % |
| `armeabi-v7a` | Aparelhos antigos, 32 bits | ~5 % |
| `x86_64` | Emuladores, Chromebooks | <1 % |

```powershell
flutter build apk --release
# Um APK universal, com as três dentro. ~45 MB.

flutter build apk --release --split-per-abi
# Três APKs, um por ABI. ~16 MB cada.
```

```text
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk    (15 MB)
├── app-arm64-v8a-release.apk      (16 MB)   ← o que quase todo mundo usa
└── app-x86_64-release.apk         (16 MB)
```

> ⚠️ **Com `--split-per-abi`, o Flutter altera o `versionCode` de cada APK**, somando um prefixo por
> ABI (1000, 2000, 4000...). Isso é necessário para a Play Console distinguir os arquivos — e
> significa que o `versionCode` no APK **não é** o do seu `pubspec`. Só importa se você distribui
> APKs pela loja; com AAB, não é assunto.

> 💡 Para distribuir um APK único fora da loja, **use o `arm64-v8a`**: ele cobre ~95 % dos
> aparelhos, com um terço do tamanho do universal. Só ofereça o `armeabi-v7a` se souber que o seu
> público tem aparelhos antigos.

### Os comandos

```powershell
# ── Para a Play Console ────────────────────────────────────────
flutter build appbundle --release

# ── Para instalar e testar ─────────────────────────────────────
flutter build apk --release
flutter build apk --release --split-per-abi
flutter build apk --release --target-platform android-arm64

# ── Completo (o que você vai usar de verdade) ──────────────────
flutter build appbundle --release `
  --obfuscate `
  --split-debug-info=simbolos/1.2.0 `
  --dart-define-from-file=config/prod.json
```

E onde cada coisa é gravada:

| Comando | Caminho |
|---|---|
| `build apk` | `build/app/outputs/flutter-apk/app-release.apk` |
| `build apk --split-per-abi` | `build/app/outputs/flutter-apk/app-<abi>-release.apk` |
| `build appbundle` | `build/app/outputs/bundle/release/app-release.aab` |
| Símbolos | onde o `--split-debug-info` apontar |
| Mapeamento do R8 | `build/app/outputs/mapping/release/mapping.txt` |

> ⚠️ **O `mapping.txt` do R8 também precisa ser guardado**, junto com os símbolos do Dart. Ele
> decifra os stack traces do código **Java/Kotlin** — os que vêm dos plugins. A Play Console aceita
> o upload dele, e aí os crashes nativos chegam legíveis no painel.

### Testar um AAB

O AAB não instala. Para testá-lo, o `bundletool` gera os APKs que a Play geraria:

```powershell
# Baixe de github.com/google/bundletool/releases
java -jar bundletool.jar build-apks `
  --bundle=build/app/outputs/bundle/release/app-release.aab `
  --output=foco.apks `
  --ks="$env:USERPROFILE\chaves\foco-upload.jks" `
  --ks-key-alias=foco

# Instala no aparelho conectado a versão adequada a ele
java -jar bundletool.jar install-apks --apks=foco.apks
```

> 💡 **Vale fazer isso pelo menos uma vez antes do primeiro lançamento.** É a única forma de ver
> exatamente o que o usuário vai receber — e de descobrir, antes da loja, que um asset não entrou na
> divisão. A aula 9 detalha o processo.

### O tamanho

```powershell
flutter build appbundle --analyze-size --target-platform android-arm64
```

```text
  libapp.so (Dart)                 4,2 MB
  libflutter.so (engine)           7,1 MB
  assets/imagens/                  8,9 MB   ← ⚠️
  assets/fonts/                    2,1 MB
  Total                           23,4 MB
```

| Item | Normal? | Se estiver grande |
|---|---|---|
| `libflutter.so` | ~7 MB, fixo | Não dá para reduzir |
| `libapp.so` | 3–6 MB | Muito código ou muitos pacotes |
| `assets/` | Varia | ⚠️ **É quase sempre aqui** |
| Fontes | 1–3 MB | Só os pesos usados |

> 📌 **O engine do Flutter (~7 MB) é o piso.** Nenhum app Flutter fica abaixo disso, e não há nada a
> fazer a respeito. Tudo acima disso é seu — e, em quase todo app que passa dos 30 MB, a causa está
> em `assets/`.

| Técnica | Redução |
|---|---|
| **AAB** | **30–40 %** |
| PNG → WebP | 25–35 % das imagens |
| Redimensionar imagens para o uso real | Muito |
| Só os pesos de fonte usados | 1–3 MB |
| `isShrinkResources` (aula 7) | 5–15 % |
| `--obfuscate` | 1–3 % |

### A ordem do release

```text
1. versão incrementada no pubspec        ← +N precisa CRESCER
2. flutter clean
3. flutter analyze  +  flutter test      ← portões
4. build appbundle --release --obfuscate --split-debug-info
5. símbolos arquivados                   ← irreversível se esquecer
6. mapping.txt arquivado
7. tamanho conferido
8. assinatura conferida
9. AAB testado com bundletool            ← no primeiro lançamento
10. upload
```

---

## 💡 Analogia

Pense numa **loja de móveis**.

- **O APK** é o armário **montado**, entregue pronto. Cabe no caminhão, o cliente recebe e usa. Mas
  o armário montado ocupa o caminhão inteiro — e vai com **todas** as peças opcionais parafusadas:
  as prateleiras de todos os tamanhos, os puxadores de todos os modelos, o manual em seis idiomas.
- **O AAB** é o armário **em peças**, com a lista de montagem. Você não entrega isso ao cliente — ele
  não saberia o que fazer. Você entrega à **central de distribuição** (a Play Console), que olha o
  pedido de cada cliente e monta só o que aquele cliente precisa: a prateleira do tamanho dele, o
  puxador do modelo dele, o manual no idioma dele. Chega **um terço menor**.
- **As ABIs** são os tipos de parafuso: métrico, imperial, madeira. O armário montado leva os três
  jogos, porque não se sabe qual a casa do cliente usa. A central sabe — e manda só um.
- **`--split-per-abi`** é montar três armários, um para cada tipo de casa, e deixar o cliente
  escolher. Funciona, e dá trabalho a mais.
- **O `bundletool`** é montar uma unidade de amostra no depósito, antes de abrir a loja, para ver se
  as peças realmente encaixam. Ninguém abre uma loja de móveis sem montar um.
- **E os símbolos e o `mapping.txt`** são a planta da montagem. Quando um cliente ligar dizendo "a
  porta está solta", sem a planta você não sabe nem qual porta é.

---

## 🧪 Exemplo mínimo

Os três builds, comparados.

**1. APK universal:**

```powershell
flutter build apk --release
```

```text
√ Built build/app/outputs/flutter-apk/app-release.apk (45.2MB)
```

**2. Dividido por ABI:**

```powershell
flutter build apk --release --split-per-abi
```

```text
√ Built build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (15.1MB)
√ Built build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (16.3MB)
√ Built build/app/outputs/flutter-apk/app-x86_64-release.apk (16.4MB)
```

**3. App Bundle:**

```powershell
flutter build appbundle --release
```

```text
√ Built build/app/outputs/bundle/release/app-release.aab (28.7MB)
```

**A comparação que importa** — não o tamanho do arquivo, mas o do **download**:

| | Arquivo | O usuário baixa |
|---|---|---|
| APK universal | 45,2 MB | **45,2 MB** |
| APK arm64 | 16,3 MB | 16,3 MB |
| **AAB** | 28,7 MB | **~17 MB** |

> 📌 **O AAB é maior no disco e menor na entrega**, porque contém todas as variantes e a Play envia
> uma só. Comparar o tamanho do `.aab` com o do `.apk` leva à conclusão errada: o número que importa
> é o que a Play Console mostra como "tamanho do download" depois do upload.

---

## 📱 Aplicando no Flutter

O script de release completo — o que você vai rodar toda vez que publicar.

---

## 💻 Código completo

> **Arquivo:** `tool/release.ps1` (novo)
> **Como executar:** `powershell -ExecutionPolicy Bypass -File tool/release.ps1`

```powershell
# Release completo: do código ao arquivo pronto para upload.
#
# Faz, na ordem certa, tudo o que dá para esquecer:
# portões de qualidade, ofuscação, arquivamento dos símbolos,
# conferência da assinatura e do tamanho.

param(
    [ValidateSet('aab', 'apk', 'ambos')]
    [string]$Formato = 'aab',

    # Pula analyze e test. Use só para experimentar; nunca
    # para gerar o artefato que vai para a loja.
    [switch]$Rapido
)

$ErrorActionPreference = 'Stop'
$inicio = Get-Date

function Etapa($n, $texto) {
    Write-Host "`n[$n] $texto" -ForegroundColor Cyan
}

# ══════════════════════════════════════════════════════════════
Etapa 1 'Versão'

$linha = Select-String -Path pubspec.yaml -Pattern '^version:\s*(.+)$'
if (-not $linha) { throw 'Não achei version: no pubspec.yaml' }

$versaoCompleta = $linha.Matches[0].Groups[1].Value.Trim()
if ($versaoCompleta -notmatch '^(\d+\.\d+\.\d+)\+(\d+)$') {
    throw "Versão em formato inesperado: '$versaoCompleta'. Use x.y.z+N."
}
$versaoNome = $Matches[1]
$versaoCodigo = [int]$Matches[2]

Write-Host "  $versaoNome (build $versaoCodigo)"

# ⭐ O erro mais frequente de quem publica atualizações: esquecer
# de subir o +N. A Play Console só avisa DEPOIS do upload inteiro.
$simbolosBase = 'simbolos'
if (Test-Path $simbolosBase) {
    $anteriores = Get-ChildItem $simbolosBase -Directory |
        Where-Object { $_.Name -match '\+(\d+)$' } |
        ForEach-Object { [int]($_.Name -replace '.*\+', '') }

    if ($anteriores -and ($anteriores | Measure-Object -Maximum).Maximum -ge $versaoCodigo) {
        $maior = ($anteriores | Measure-Object -Maximum).Maximum
        throw "versionCode $versaoCodigo já foi usado (maior anterior: $maior). Suba o +N no pubspec.yaml."
    }
}

# ══════════════════════════════════════════════════════════════
Etapa 2 'Assinatura configurada?'

if (-not (Test-Path 'android/key.properties')) {
    throw 'Falta android/key.properties. Aula 7.'
}

$props = Get-Content 'android/key.properties' -Raw
$caminhoChave = ([regex]'storeFile=(.+)').Match($props).Groups[1].Value.Trim()

if (-not (Test-Path $caminhoChave)) {
    throw "O keystore não existe: $caminhoChave`nConfira o storeFile (barras normais!)."
}
Write-Host "  keystore: $caminhoChave"

# ══════════════════════════════════════════════════════════════
Etapa 3 'Limpando'
flutter clean
flutter pub get

# ══════════════════════════════════════════════════════════════
if (-not $Rapido) {
    Etapa 4 'Portões de qualidade'

    # Antes do build: descobrir um teste quebrado DEPOIS de
    # publicar é tarde demais.
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw 'flutter analyze falhou' }

    flutter test
    if ($LASTEXITCODE -ne 0) { throw 'Testes falharam' }
} else {
    Write-Host "`n[4] ⚠️  PULANDO analyze e test (-Rapido)" -ForegroundColor Yellow
}

# ══════════════════════════════════════════════════════════════
Etapa 5 'Compilando'

# Símbolos por versão COMPLETA (com o +N): dois builds da mesma
# versão de nome geram símbolos diferentes.
$simbolos = "simbolos/$versaoCompleta"
New-Item -ItemType Directory -Force -Path $simbolos | Out-Null

$config = 'config/prod.json'
$comuns = @('--release', '--obfuscate', "--split-debug-info=$simbolos")
if (Test-Path $config) {
    $comuns += "--dart-define-from-file=$config"
    Write-Host "  configuração: $config"
}

$artefatos = @()

if ($Formato -in @('aab', 'ambos')) {
    Write-Host '  → appbundle (para a Play Console)'
    & flutter build appbundle @comuns
    if ($LASTEXITCODE -ne 0) { throw 'Build do AAB falhou' }
    $artefatos += 'build/app/outputs/bundle/release/app-release.aab'
}

if ($Formato -in @('apk', 'ambos')) {
    Write-Host '  → apk arm64 (para instalar e testar)'
    & flutter build apk @comuns --target-platform android-arm64
    if ($LASTEXITCODE -ne 0) { throw 'Build do APK falhou' }
    $artefatos += 'build/app/outputs/flutter-apk/app-release.apk'
}

# ══════════════════════════════════════════════════════════════
Etapa 6 'Arquivando os símbolos'

$gerados = Get-ChildItem $simbolos -Filter '*.symbols' -ErrorAction SilentlyContinue
if (-not $gerados) {
    # ⭐ Sem esta verificação, um build sem símbolos passaria
    # despercebido — e os crashes desta versão seriam ilegíveis
    # PARA SEMPRE. Módulo 13, aula 7.
    throw 'NENHUM símbolo gerado! Crashes desta versão seriam ilegíveis.'
}
$gerados | ForEach-Object {
    Write-Host "  $($_.Name)  ($([math]::Round($_.Length/1MB,1)) MB)"
}

# O mapping.txt do R8 decifra os stack traces JAVA/KOTLIN —
# os que vêm dos plugins. Precisa ser guardado junto.
$mapping = 'build/app/outputs/mapping/release/mapping.txt'
if (Test-Path $mapping) {
    Copy-Item $mapping "$simbolos/mapping.txt"
    Write-Host '  mapping.txt (R8) arquivado'
}

# ══════════════════════════════════════════════════════════════
Etapa 7 'Conferindo'

foreach ($a in $artefatos) {
    if (-not (Test-Path $a)) { continue }

    $mb = [math]::Round((Get-Item $a).Length / 1MB, 2)
    $cor = if ($mb -gt 50) { 'Red' } elseif ($mb -gt 30) { 'Yellow' } else { 'Green' }
    Write-Host "  $a  ($mb MB)" -ForegroundColor $cor

    if ($mb -gt 30) {
        Write-Host '    Acima de 30 MB: rode --analyze-size e revise assets/.' -ForegroundColor Yellow
    }

    # A assinatura, só para APK (o AAB usa outro verificador).
    if ($a.EndsWith('.apk') -and (Test-Path 'tool/conferir-assinatura.ps1')) {
        & powershell -ExecutionPolicy Bypass -File tool/conferir-assinatura.ps1 -Artefato $a
    }
}

# ══════════════════════════════════════════════════════════════
$duracao = [math]::Round(((Get-Date) - $inicio).TotalMinutes, 1)

Write-Host "`n════════════════════════════════════════" -ForegroundColor Green
Write-Host " $versaoCompleta pronto em $duracao min" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host ''
Write-Host 'Antes de enviar:' -ForegroundColor Cyan
Write-Host "  1. Copie simbolos/$versaoCompleta para fora desta máquina"
Write-Host '  2. Instale e teste o APK num aparelho real'
Write-Host '  3. Play Console → Produção → Criar versão'
Write-Host '  4. Envie o mapping.txt junto, para crashes legíveis'
```

E o analisador de tamanho:

> **Arquivo:** `tool/analisar-tamanho.ps1` (novo)

```powershell
# Mostra o que ocupa espaço no app.
#
# Rode quando o artefato passar de 30 MB — em quase todo caso,
# a resposta está em assets/.

$ErrorActionPreference = 'Stop'

Write-Host 'Analisando (pode levar alguns minutos)…' -ForegroundColor Cyan
flutter build appbundle --analyze-size --target-platform android-arm64

Write-Host "`n─── Assets do projeto ───" -ForegroundColor Cyan

if (Test-Path assets) {
    Get-ChildItem assets -Recurse -File |
        Sort-Object Length -Descending |
        Select-Object -First 15 |
        ForEach-Object {
            $kb = [math]::Round($_.Length / 1KB, 1)
            $cor = if ($kb -gt 500) { 'Red' } elseif ($kb -gt 100) { 'Yellow' } else { 'Gray' }
            Write-Host ("  {0,8} KB  {1}" -f $kb, ($_.FullName -replace [regex]::Escape($PWD), '.')) -ForegroundColor $cor
        }

    $total = (Get-ChildItem assets -Recurse -File | Measure-Object Length -Sum).Sum / 1MB
    Write-Host ("`n  Total em assets/: {0:N1} MB" -f $total)

    # PNG grande é o suspeito nº 1: WebP costuma cortar 25–35 %.
    $pngs = Get-ChildItem assets -Recurse -Filter '*.png' |
        Where-Object { $_.Length -gt 100KB }
    if ($pngs) {
        Write-Host "`n  ⚠️  PNGs acima de 100 KB (converta para WebP):" -ForegroundColor Yellow
        $pngs | ForEach-Object {
            Write-Host "     $($_.Name)  ($([math]::Round($_.Length/1KB)) KB)"
        }
    }
} else {
    Write-Host '  (sem pasta assets/)'
}

Write-Host "`nO relatório completo abre no DevTools — veja o link acima." -ForegroundColor Cyan
```

```powershell
.\tool\release.ps1 -Formato ambos
.\tool\analisar-tamanho.ps1
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Validar o formato `x.y.z+N` | Uma versão malformada gera `versionCode` errado silenciosamente. |
| **Recusar `versionCode` repetido** | O erro mais frequente ao publicar atualizações; a Play só avisa após o upload. |
| Conferir que o keystore existe | O erro do Gradle (`Keystore file not found`) não diz que a barra está errada. |
| `flutter clean` antes | Build de release nunca reaproveita cache. |
| `analyze` + `test` **antes** do build | Teste quebrado descoberto depois de publicar é tarde demais. |
| `-Rapido` com aviso amarelo | Útil para experimentar, perigoso para publicar — por isso avisa. |
| Símbolos por versão **completa** (`+N`) | Dois builds da mesma versão de nome geram símbolos diferentes. |
| **Falhar se nenhum símbolo saiu** | Sem isso, crashes da versão seriam ilegíveis para sempre. |
| Arquivar o `mapping.txt` | Decifra os stack traces **Java/Kotlin** dos plugins. |
| AAB para a loja, APK arm64 para testar | Cada formato no seu papel. |
| Alerta acima de 30 MB | Tamanho afasta usuário; o alerta força a decisão. |
| `conferir-assinatura.ps1` no fim | APK de debug é recusado; melhor descobrir agora. |
| Instruções finais | O passo mais esquecido (copiar os símbolos) fica por último, em destaque. |
| `analisar-tamanho.ps1` listando PNGs | Em quase todo app acima de 30 MB, a causa está em `assets/`. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Para a loja | **AAB** | **IPA** (via archive) |
| Para testar | APK | IPA ad-hoc, ou TestFlight |
| Comando | `flutter build appbundle` | `flutter build ipa` |
| Divisão por aparelho | AAB (a Play monta) | **App Thinning** (automático) |
| Instalar fora da loja | ✅ APK, livremente | ⚠️ TestFlight ou provisioning |
| Gerar no Windows | ✅ | ❌ |

> 💡 **O iOS faz o equivalente ao AAB desde sempre, e sem você configurar nada.** O *App Thinning* é
> automático: a App Store entrega a cada aparelho só o que ele usa. O Android levou anos para chegar
> ao mesmo resultado, e por isso o AAB parece uma novidade complicada — é só a Apple tendo começado
> antes.

> ⚠️ **No iOS não existe "APK para mandar por WhatsApp".** Instalar fora da loja exige TestFlight ou
> um provisioning profile que lista o aparelho pelo identificador. Essa diferença cultural surpreende
> quem vem do Android: no iOS, não há distribuição informal. Módulo 15, aula 9.

🪟 **No Windows**, esta aula funciona por completo para Android. Para iOS, o build é no Mac ou em CI.

---

## ⚠️ Erros comuns

### 1. Enviar APK para a Play Console

Recusado em apps novos.

**Correção:** `flutter build appbundle`.

### 2. Tentar instalar um AAB

```text
adb: failed to install app-release.aab
```

**Correção:** AAB não instala. Use APK ou `bundletool`.

### 3. Comparar o tamanho do `.aab` com o do `.apk`

Conclusão errada.

**Correção:** o que importa é o **download**, na Play Console.

### 4. `versionCode` repetido

Recusado depois do upload inteiro.

**Correção:** suba o `+N`.

### 5. Esquecer `--obfuscate`

Código legível no binário.

**Correção:** ofusque — **e guarde os símbolos**.

### 6. Ofuscar sem `--split-debug-info`

Crashes ilegíveis para sempre.

**Correção:** sempre juntos.

### 7. Não arquivar o `mapping.txt`

Crashes de plugin ilegíveis.

**Correção:** guarde junto com os símbolos.

### 8. Publicar sem testar o AAB

Um asset pode não ter entrado na divisão.

**Correção:** `bundletool` no primeiro lançamento.

### 9. Não rodar os testes antes

Bug descoberto pelos usuários.

**Correção:** portões antes do build.

### 10. Ignorar o tamanho

40 MB afastam usuário.

**Correção:** `--analyze-size`.

### 11. Distribuir o APK universal fora da loja

Três vezes maior que o necessário.

**Correção:** `arm64-v8a`.

### 12. Achar que `--split-per-abi` serve para a loja

O AAB já faz isso, melhor.

**Correção:** AAB.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter build apk --release`. Anote o tamanho.

**Passo 2.** Rode com `--split-per-abi`. Quantos arquivos? Que tamanhos?

**Passo 3.** Rode `flutter build appbundle --release`. Compare com o universal.

**Passo 4.** Tente `adb install` no `.aab`. Leia o erro.

**Passo 5.** Extraia o `versionCode` de cada APK dividido
(`aapt dump badging <apk> | Select-String versionCode`). São iguais?

**Passo 6.** Compile com `--obfuscate --split-debug-info` e confirme os símbolos.

**Passo 7.** Ache o `mapping.txt` e veja o tamanho dele.

**Passo 8.** Rode `analisar-tamanho.ps1`. O que ocupa mais?

**Passo 9.** Converta o maior PNG para WebP e recompile. Quanto caiu?

**Passo 10.** Rode `release.ps1` duas vezes **sem** subir o `versionCode`. Ele recusa?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-android.md](../../exercicios/14-build-android.md)

Faça os de **Aplicação** (script de release), **Diagnóstico** (app grande demais) e **Reflexão**
(qual formato para qual canal).

---

## 🏆 Desafio opcional

Reduza o tamanho do app em **pelo menos 30 %**, medindo cada passo.

Requisitos:

- Meça o ponto de partida com `--analyze-size` e anote.
- Converta todos os PNG acima de 50 KB para WebP.
- Redimensione cada imagem para o tamanho máximo em que ela aparece (módulo 13, aula 2).
- Remova assets não referenciados (procure cada nome de arquivo no código).
- Mantenha só os pesos de fonte realmente usados.
- Ligue `isShrinkResources` e `localeFilters`.
- **Meça depois de cada mudança**, uma por vez.
- Uma tabela final: técnica × redução × esforço.

Depois responda: qual técnica teve a melhor relação **ganho/esforço**? E qual você esperava que
rendesse mais do que rendeu?

---

## 📌 Resumo

- **APK** instala direto; **AAB** é o que a Play Console recebe e usa para montar o APK de cada
  aparelho.
- **AAB é obrigatório para apps novos** e reduz o download em **30–40 %**.
- **AAB para a loja, APK para todo o resto.**
- O `.aab` é **maior no disco** e **menor na entrega** — comparar arquivos leva à conclusão errada.
- **ABIs**: `arm64-v8a` cobre ~95 % dos aparelhos; é o APK único certo para distribuir.
- `--split-per-abi` gera três APKs e **altera o `versionCode`** de cada um.
- Artefatos: APK em `flutter-apk/`, AAB em `bundle/release/`, mapeamento em `mapping/release/`.
- **Guarde o `mapping.txt`** junto com os símbolos: ele decifra os crashes **Java/Kotlin**.
- Ofusque **sempre com `--split-debug-info`**, e arquive os símbolos por versão completa.
- **`versionCode` precisa crescer a cada envio** — a Play só avisa depois do upload.
- Teste o AAB com **`bundletool`** antes do primeiro lançamento.
- O engine (~7 MB) é o **piso**; acima de 30 MB, a causa quase sempre está em **`assets/`**.
- 🍎 O iOS faz o equivalente ao AAB automaticamente (**App Thinning**) — e não permite distribuição
  informal.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre APK e AAB.
- [ ] Sei qual formato usar para cada canal.
- [ ] Entendo ABIs e sei qual APK único distribuir.
- [ ] Sei onde cada artefato é gravado.
- [ ] Gero AAB assinado e ofuscado.
- [ ] Arquivo os símbolos e o `mapping.txt` por versão.
- [ ] Incremento o `versionCode` a cada envio.
- [ ] Sei testar um AAB com `bundletool`.
- [ ] Uso `--analyze-size` e sei ler o resultado.
- [ ] Rodo analyze e test antes de compilar.
- [ ] Confiro a assinatura antes de enviar.
- [ ] Tenho um script que faz tudo isso na ordem.

---

## 📚 Referências oficiais

- [Build and release an Android app — docs.flutter.dev](https://docs.flutter.dev/deployment/android)
- [About Android App Bundles — developer.android.com](https://developer.android.com/guide/app-bundle)
- [bundletool — developer.android.com](https://developer.android.com/tools/bundletool)
- [Support different platforms (ABIs) — developer.android.com](https://developer.android.com/ndk/guides/abis)
- [Measuring your app's size — docs.flutter.dev](https://docs.flutter.dev/perf/app-size)
- [Deobfuscate crash stack traces — developer.android.com](https://developer.android.com/studio/build/shrink-code#decode-stack-trace)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Assinatura no Gradle](07-assinatura-no-gradle.md) | [README](README.md) | [Instalando e validando](09-instalando-e-validando.md) |
