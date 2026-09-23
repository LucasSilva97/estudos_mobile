# Aula 8 — Gerando o build web

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Gerar o build de produção com **`flutter build web --release`** e conferir objetivamente o
  resultado.
- Dominar o **`--base-href`** — a causa nº 1 de PWA que compila, publica e abre em **tela branca**.
- Entender por que **`--no-web-resources-cdn`** é praticamente obrigatório num PWA que promete
  offline.
- Usar **`--dart-define-from-file`** para configuração por ambiente, sabendo exatamente o que isso
  **não** protege.
- Decidir sobre `--wasm` e `--source-maps` com critério.
- **Servir o build localmente** e validar antes de publicar.
- Escrever um script único de release web, com portões de qualidade e verificações.

## ✅ Pré-requisitos

- [Aula 7 — Instalabilidade](07-instalabilidade.md).
- [Aula 5 — Manifest e ícones](05-manifest-e-icones.md) — o `scope` precisa casar com o
  `--base-href`; esta aula fecha esse par.
- [Módulo 13, aula 6 — Segurança mobile](../13-desempenho-e-seguranca/06-seguranca-mobile.md) — a
  regra "segredo mora no servidor" vira restrição absoluta aqui.

---

## 📖 Conceito

### O comando

```powershell
flutter build web --release
```

```text
Compiling lib\main.dart for the Web...
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from
1645184 to 4324 bytes (99.7% reduction).
√ Built build\web
```

Não há assinatura, não há chave, não há `versionCode`. Comparado ao
[Módulo 15, aula 8](../15-build-android/08-gerando-apk-e-aab.md), o build web é trivial — e é
justamente por isso que as duas ou três coisas que dão errado dão muito errado.

### `--base-href`: a pegadinha nº 1

O `index.html` do Flutter tem esta linha:

```html
<base href="$FLUTTER_BASE_HREF">
```

O build substitui esse marcador. Tudo o mais na página — `main.dart.js`, `manifest.json`,
`canvaskit/`, `assets/` — é referenciado **relativo a esse valor**.

```text
App na RAIZ do domínio           App em uma SUBPASTA
https://foco.com.br/             https://usuario.github.io/foco/

  --base-href /                    --base-href /foco/
  <base href="/">                  <base href="/foco/">

  /main.dart.js         ✅         /foco/main.dart.js     ✅
```

E o que acontece se você esquecer:

```text
flutter build web --release        (sem --base-href)
    ↓ publicado em usuario.github.io/foco/
    ↓ <base href="/">
    ↓ o navegador busca https://usuario.github.io/main.dart.js
    ↓                                          ↑ sem /foco/
    ↓ 404
    ↓
  TELA BRANCA — sem mensagem de erro na página
```

| Sintoma | O que olhar |
|---|---|
| Página totalmente branca | Console (F12) → 404 em `main.dart.js` |
| Ícone e nome certos, conteúdo vazio | O `index.html` carregou; o resto não |
| Funciona local, quebra publicado | Local é raiz; publicado é subpasta |

```text
GET https://usuario.github.io/main.dart.js         404 (Not Found)
GET https://usuario.github.io/flutter_bootstrap.js 404 (Not Found)
GET https://usuario.github.io/manifest.json        404 (Not Found)
```

**As três regras:**

| Regra | Exemplo |
|---|---|
| Precisa **começar** com `/` | `/foco/` |
| Precisa **terminar** com `/` | `/foco/` |
| Precisa ser **igual** ao `scope` do manifest | `"scope": "/foco/"` |

> ⚠️ **`--base-href /foco` (sem a barra final) falha.** O Flutter recusa com uma mensagem clara — o
> que é uma sorte, porque publicar assim daria o mesmo 404 silencioso.

> 💡 **Nome do repositório = caminho.** No GitHub Pages de projeto, a URL é
> `usuario.github.io/NOME-DO-REPO/`. Se o repositório do Foco se chama `foco`, o valor é `/foco/`.
> Renomear o repositório muda a URL — e, pela [Aula 4](04-banco-de-dados-na-web.md), **apaga o banco
> de todos os usuários**.

### `--no-web-resources-cdn`: quase obrigatório

Por padrão, o Flutter carrega o **CanvasKit de um CDN** (`gstatic.com`), e não do seu servidor.

```text
padrão                                      --no-web-resources-cdn
┌──────────────┐                            ┌──────────────┐
│ seu servidor │ → index, main.dart.js      │ seu servidor │ → TUDO
└──────────────┘                            └──────────────┘
┌──────────────┐
│ gstatic.com  │ → canvaskit.wasm  ⚠️
└──────────────┘
```

E aqui está o problema: **o service worker do Flutter só faz cache do que é da sua origem.** O
`canvaskit.wasm` vindo do CDN **não entra no cache**.

| Cenário | Padrão (CDN) | `--no-web-resources-cdn` |
|---|---|---|
| Primeira visita online | ✅ | ✅ |
| Segunda visita online | ✅ | ✅ |
| **Offline, app instalado** | ⚠️ **Pode não abrir** | ✅ **Abre** |
| Rede bloqueando o gstatic | ❌ | ✅ |
| Peso do seu servidor | Menor | +1,5 MB |

> ⚠️ **Um PWA que promete offline e carrega o engine de um CDN não cumpre a promessa.** Esta é a
> flag mais importante desta aula depois do `--base-href`, e a que menos gente usa. Toda a
> [Aula 6](06-service-worker-e-offline.md) depende dela.

### `--dart-define-from-file`: configuração, não segredo

```json
{
  "AMBIENTE": "producao",
  "API_BASE_URL": "https://jsonplaceholder.typicode.com",
  "HABILITAR_TRILHAS": true
}
```

```powershell
flutter build web --release --dart-define-from-file=config/prod.json
```

```dart
const String ambiente = String.fromEnvironment('AMBIENTE', defaultValue: 'dev');
const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
```

> ⚠️ **Isso não esconde nada. Na web, nada esconde nada.** O valor vai **literalmente** para dentro
> do `main.dart.js`, e qualquer pessoa abre o arquivo e lê. Não é "menos seguro que no Android" —
> é **zero**: no Android alguém precisa extrair e desmontar o APK; na web basta apertar F12.

```text
O que PODE ir num --dart-define na web:
  ✅ URL base da API (é pública de qualquer jeito)
  ✅ nome do ambiente
  ✅ flags de funcionalidade
  ✅ chaves PÚBLICAS restritas por domínio (ex.: chave de mapa com referrer travado)

O que NUNCA pode:
  ❌ senha
  ❌ token de API com permissão de escrita
  ❌ chave privada, de qualquer tipo
  ❌ string de conexão de banco
```

> 📌 **A regra do [Módulo 13, aula 6](../13-desempenho-e-seguranca/06-seguranca-mobile.md) — "segredo
> mora no servidor" — deixa de ser boa prática e vira lei física.** Se um serviço exige uma chave no
> cliente, ela precisa ser pública e **restrita por domínio**, e a restrição é o que protege, não o
> sigilo.

### As outras flags

| Flag | Efeito | Recomendação |
|---|---|---|
| `--wasm` | Compila com `dart2wasm` | Meça antes ([Aula 2](02-como-o-flutter-compila-para-web.md)) |
| `--source-maps` | Gera `.map` para decifrar stack traces | ✅ Sim, e **não publique os `.map`** em repositório público |
| `--pwa-strategy=none` | Sem service worker | ❌ Perde offline e instalabilidade |
| `--no-tree-shake-icons` | Fonte de ícones inteira | ❌ +1,6 MB à toa |
| `--csp` | Modo *Content Security Policy* | Só se a sua política exigir |
| `--base-href` | Caminho base | ✅ **Sempre**, quando não está na raiz |

---

## 💡 Analogia

Pense em mudar de casa com caixas etiquetadas.

- **O `--base-href` é o endereço escrito nas caixas.** Você embala tudo com "Rua A, 100" e a mudança
  vai para "Rua A, 100, **apartamento 42**". As caixas chegam ao prédio, o porteiro procura a Rua A,
  100 — que existe — e não acha nada, porque tudo mora no 42. **Nada chega, e ninguém avisa**: é a
  tela branca.
- **O `--no-web-resources-cdn` é a decisão sobre a geladeira.** O padrão é "a geladeira fica na loja,
  a gente pega quando precisar". Funciona enquanto a loja está aberta. No dia em que você promete
  jantar sem sair de casa — o offline —, descobre que a geladeira nunca esteve lá.
- **O `--dart-define-from-file` é a etiqueta do lado de fora da caixa.** Serve para organizar
  ("cozinha", "quarto"). Escrever a senha do cofre na etiqueta não a protege: está do lado de fora,
  em letra grande, no corredor do prédio.
- **E servir o build localmente antes de publicar** é montar a mudança inteira num galpão antes de
  levar. Custa vinte minutos e evita descobrir no apartamento que faltou a chave.

---

## 🧪 Exemplo mínimo

Reproduza a tela branca de propósito, para reconhecê-la depois em dois segundos.

**1.** Compile **sem** `--base-href`:

```powershell
flutter build web --release
```

**2.** Sirva a partir de uma **subpasta**, imitando o GitHub Pages:

```powershell
New-Item -ItemType Directory -Force -Path .\publicado\foco | Out-Null
Copy-Item -Recurse -Force .\build\web\* .\publicado\foco\
dart pub global run dhttpd --path publicado --port 8080
```

**3.** Abra `http://localhost:8080/foco/`:

```text
┌──────────────────────────────┐
│                              │
│                              │   ← branco
│                              │
└──────────────────────────────┘
```

**4.** F12 → Console:

```text
GET http://localhost:8080/flutter_bootstrap.js  404 (Not Found)
GET http://localhost:8080/main.dart.js          404 (Not Found)
```

Repare no que **não** tem `/foco/`. Esse é o diagnóstico inteiro.

**5.** Recompile com o caminho certo:

```powershell
flutter build web --release --base-href /foco/
Copy-Item -Recurse -Force .\build\web\* .\publicado\foco\
```

**6.** Recarregue com **Ctrl+Shift+R**:

```text
✅ O Foco abre.
```

> ⚠️ **Ctrl+Shift+R, não F5.** O service worker da tentativa anterior já está registrado e vai
> servir o cache quebrado. Recarga forçada ignora o cache — e essa confusão custa muita gente
> concluindo que "o `--base-href` não resolveu".

---

## 📱 Aplicando no Flutter

### Servir o build localmente

Publicar para descobrir que quebrou é o pior ciclo de feedback possível. Sirva antes:

| Ferramenta | Comando | Observação |
|---|---|---|
| `dhttpd` | `dart pub global run dhttpd --path build/web` | Dart puro, nada a instalar além do pacote |
| `python` | `python -m http.server 8080 -d build/web` | Se já tem Python |
| `npx serve` | `npx serve build/web` | Se já tem Node |

> 💡 **`flutter run -d chrome --release` não é a mesma coisa.** Ele usa um servidor próprio, na raiz,
> com configuração própria — e portanto **não** reproduz o problema de subpasta. Para validar um
> deploy, sirva os arquivos como um servidor comum.

### Conferindo o build

```powershell
# O base href foi aplicado?
Select-String -Path .\build\web\index.html -Pattern "<base href"
```

```text
build\web\index.html:5:  <base href="/foco/">
```

```powershell
# O CanvasKit é local?
Test-Path .\build\web\canvaskit\canvaskit.wasm
```

```powershell
# Os arquivos do banco (Aula 4) entraram?
Get-ChildItem .\build\web\ -Filter "sq*"
```

```powershell
# O service worker foi gerado?
Test-Path .\build\web\flutter_service_worker.js
```

Quatro comandos, quatro respostas objetivas. É o equivalente web do
`conferir-assinatura.ps1` do Módulo 15.

---

## 💻 Código completo

> **Arquivo:** `scripts/release-web.ps1`
> **Como executar:** `.\scripts\release-web.ps1 -BaseHref /foco/`

```powershell
# Release web completo: do código à pasta pronta para publicar.
#
# Faz, na ordem certa, tudo o que dá para esquecer — e recusa o build
# quando algo que só quebraria EM PRODUÇÃO estiver errado.

param(
    # ⚠️ O erro nº 1 de PWA. Precisa começar e terminar com barra, e
    # ser IGUAL ao "scope" do web/manifest.json.
    [Parameter(Mandatory = $true)]
    [string]$BaseHref,

    [switch]$Wasm,
    [string]$Config = "config/prod.json"
)

$ErrorActionPreference = "Stop"

# ══════════════════════════════════════════════════════════════
# 1. Validar o --base-href ANTES de gastar 2 minutos compilando
# ══════════════════════════════════════════════════════════════
if ($BaseHref -notmatch '^/.*/$') {
    throw "BaseHref precisa começar e terminar com '/'. Recebido: '$BaseHref'"
}

# ⭐ A conferência que evita a "barra de navegador dentro do app":
# base-href e scope precisam ser o mesmo caminho. Divergir não quebra
# o build nem o deploy — só a experiência instalada, que é o que
# ninguém testa antes de publicar.
$manifesto = Get-Content .\web\manifest.json -Raw | ConvertFrom-Json
if ($manifesto.scope -ne $BaseHref) {
    throw "web/manifest.json tem scope '$($manifesto.scope)' e o build usa '$BaseHref'. Alinhe os dois."
}
if ($manifesto.start_url -ne $BaseHref) {
    Write-Warning "start_url ('$($manifesto.start_url)') difere do base-href. Confira se é intencional."
}

# ══════════════════════════════════════════════════════════════
# 2. Portões de qualidade
# ══════════════════════════════════════════════════════════════
Write-Host "`n[1/5] Analisando e testando..." -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) { throw "flutter analyze falhou." }

flutter test
if ($LASTEXITCODE -ne 0) { throw "flutter test falhou." }

# Roda a suíte NO NAVEGADOR. É o único portão que pega o que a Aula 3
# descreve: dart:io, Platform.isX e plugins sem web só quebram aqui.
Write-Host "      ...e agora no Chrome (pega os erros só-web):" -ForegroundColor Cyan
flutter test --platform chrome
if ($LASTEXITCODE -ne 0) { throw "Os testes passam no Dart VM e falham no Chrome. Veja a Aula 3." }

# ══════════════════════════════════════════════════════════════
# 3. Build
# ══════════════════════════════════════════════════════════════
Write-Host "`n[2/5] Compilando..." -ForegroundColor Cyan
flutter clean | Out-Null
flutter pub get | Out-Null

$argumentos = @(
    "build", "web", "--release",
    "--base-href", $BaseHref,
    # ⭐ Sem isto o CanvasKit vem de CDN e o service worker NÃO o
    # guarda: o app instalado pode não abrir offline. Aula 8.
    "--no-web-resources-cdn",
    "--source-maps"
)
if ($Wasm) { $argumentos += "--wasm" }
if (Test-Path $Config) { $argumentos += @("--dart-define-from-file", $Config) }

& flutter @argumentos
if ($LASTEXITCODE -ne 0) { throw "O build falhou." }

# ══════════════════════════════════════════════════════════════
# 4. Verificações objetivas do artefato
# ══════════════════════════════════════════════════════════════
Write-Host "`n[3/5] Conferindo o artefato..." -ForegroundColor Cyan

$conferencias = @(
    @{ Nome = "base href aplicado";  Ok = (Select-String -Path .\build\web\index.html -Pattern ([regex]::Escape("<base href=`"$BaseHref`""))) -ne $null }
    @{ Nome = "service worker";      Ok = Test-Path .\build\web\flutter_service_worker.js }
    @{ Nome = "CanvasKit local";     Ok = Test-Path .\build\web\canvaskit\canvaskit.wasm }
    @{ Nome = "manifest";            Ok = Test-Path .\build\web\manifest.json }
    @{ Nome = "sqlite3.wasm";        Ok = Test-Path .\build\web\sqlite3.wasm }
    @{ Nome = "sqflite_sw.js";       Ok = Test-Path .\build\web\sqflite_sw.js }
    @{ Nome = "ícone 512";           Ok = Test-Path .\build\web\icons\Icon-512.png }
)

$falhou = $false
foreach ($c in $conferencias) {
    if ($c.Ok) {
        Write-Host ("  [OK]    " + $c.Nome) -ForegroundColor Green
    } else {
        Write-Host ("  [FALHA] " + $c.Nome) -ForegroundColor Red
        $falhou = $true
    }
}
if ($falhou) { throw "Artefato incompleto. Não publique." }

# ══════════════════════════════════════════════════════════════
# 5. Os source maps NÃO vão para o ar em repositório público
# ══════════════════════════════════════════════════════════════
# Eles reconstroem o seu código Dart original. Úteis para você
# decifrar um stack trace (Aula 10); guarde-os junto da release,
# como os símbolos do Android — e tire da pasta publicada.
Write-Host "`n[4/5] Arquivando source maps..." -ForegroundColor Cyan
$versao = (Select-String -Path .\pubspec.yaml -Pattern '^version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
$destino = ".\simbolos-web\$versao"
New-Item -ItemType Directory -Force -Path $destino | Out-Null

$mapas = Get-ChildItem .\build\web\ -Filter "*.map" -Recurse
if ($mapas.Count -eq 0) {
    Write-Warning "Nenhum .map gerado — stack traces de produção virão ilegíveis."
} else {
    $mapas | Move-Item -Destination $destino -Force
    Write-Host "  $($mapas.Count) mapa(s) em $destino (fora de build/web)" -ForegroundColor Green
}

# ══════════════════════════════════════════════════════════════
# 6. Peso do primeiro carregamento
# ══════════════════════════════════════════════════════════════
Write-Host "`n[5/5] Peso do caminho crítico:" -ForegroundColor Cyan
$critico = Get-ChildItem -Recurse .\build\web -File |
    Where-Object { $_.Extension -notin @('.png', '.jpg', '.webp', '.map') }
$mb = [math]::Round((($critico | Measure-Object Length -Sum).Sum) / 1MB, 2)
Write-Host "  $mb MB sem compressão (~$([math]::Round($mb * 0.35, 2)) MB na rede)"
if ($mb -gt 5) { Write-Warning "Acima de 5 MB. Em 4G ruim, isso passa de 10 s." }

Write-Host "`nPronto: build\web (base-href $BaseHref)" -ForegroundColor Green
Write-Host "Valide localmente ANTES de publicar:" -ForegroundColor Yellow
Write-Host "  New-Item -ItemType Directory -Force -Path .\publicado$BaseHref"
Write-Host "  Copy-Item -Recurse -Force .\build\web\* .\publicado$BaseHref"
Write-Host "  dart pub global run dhttpd --path publicado --port 8080"
Write-Host "  Abra http://localhost:8080$BaseHref e recarregue com Ctrl+Shift+R"
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Validar `-BaseHref` **antes** do build | Falhar em 0,1 s em vez de depois de 2 minutos compilando. |
| **Comparar `scope` com `BaseHref`** | Divergir não quebra build nem deploy — só a experiência instalada, que ninguém testa antes de publicar. |
| `flutter test --platform chrome` | O **único** portão que pega os erros da Aula 3. Passar no Dart VM não prova nada sobre a web. |
| `--no-web-resources-cdn` fixo | Sem ele, o offline prometido na Aula 6 não se cumpre. Não é opção. |
| `--source-maps` ligado | Stack trace de produção legível ([Aula 10](10-diagnostico-web.md)). |
| Mover os `.map` para fora de `build/web` | Eles reconstroem seu código Dart. Ficam arquivados, como os símbolos do Android. |
| A lista de conferências | Cada item é uma falha real e silenciosa: sem `sqlite3.wasm`, o app abre e o banco não. |
| `throw` se algo falhar | Publicar artefato incompleto é pior que não publicar. |
| Aviso se nenhum `.map` saiu | Silêncio aqui significa crashes ilegíveis depois. |
| Instruções finais de validação local | O passo mais pulado, e o que mais evita retrabalho. |
| `Ctrl+Shift+R` na instrução | Sem recarga forçada, o service worker antigo serve cache quebrado. |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| Comando | `flutter build web` | `flutter build appbundle` | `flutter build ipa` |
| Saída | Pasta `build/web/` | `app-release.aab` | `Runner.ipa` |
| Assinatura | ❌ Não existe | Keystore | Certificado |
| Versão obrigatória | ❌ | `versionCode` deve subir | `CFBundleVersion` deve subir |
| Caminho base | ⚠️ **`--base-href`** | — | — |
| Ofuscação | ❌ Só minificação | `--obfuscate` | `--obfuscate` |
| Símbolos | `--source-maps` → `.map` | `--split-debug-info` | `--split-debug-info` |
| Segredo no artefato | ⚠️ **Legível com F12** | Extraível com esforço | Extraível com esforço |
| Gerar no Windows | ✅ | ✅ | ❌ |
| Tempo do build | ~1–2 min | ~3–6 min | ~5–10 min |

> 💡 **A web não tem `versionCode`.** Não existe "recusado por versão repetida": você publica por
> cima, e pronto. Isso é liberdade e é risco — o controle de versão passa a ser inteiramente seu, via
> tags do Git e `CHANGELOG`
> ([Módulo 17, aula 3](../17-publicacao-e-proximos-passos/03-versionamento-e-releases.md)). Sem essa
> disciplina, ninguém sabe o que está no ar.

🪟 **No Windows**, esta aula funciona por completo.

---

## ⚠️ Erros comuns

### 1. Esquecer `--base-href` em subpasta

Tela branca, 404 em `main.dart.js`.

**Correção:** `--base-href /nome-do-repo/`.

### 2. `--base-href` sem barra final

O build recusa.

**Correção:** `/foco/`.

### 3. `base-href` diferente do `scope`

Barra de navegador dentro do app instalado.

**Correção:** os dois iguais; o script confere.

### 4. Substituir `$FLUTTER_BASE_HREF` na mão

`--base-href` para de funcionar.

**Correção:** deixe o marcador literal ([Aula 5](05-manifest-e-icones.md)).

### 5. Testar com F5 depois de corrigir

O service worker antigo serve o cache quebrado.

**Correção:** Ctrl+Shift+R.

### 6. Validar com `flutter run -d chrome --release`

Serve na raiz; não reproduz subpasta.

**Correção:** sirva os arquivos como um servidor comum.

### 7. Não usar `--no-web-resources-cdn`

O app instalado pode não abrir offline.

**Correção:** sempre, em PWA.

### 8. Segredo no `--dart-define`

Vai literal para o `main.dart.js`.

**Correção:** nada sensível no cliente.

### 9. Publicar os `.map` em repositório público

Reconstroem o seu código Dart.

**Correção:** arquive fora de `build/web`.

### 10. Não gerar source maps

Stack trace de produção ilegível.

**Correção:** `--source-maps` + arquivar.

### 11. Esquecer `sqlite3.wasm` no artefato

App abre, banco não.

**Correção:** conferência no script.

### 12. Não versionar

Ninguém sabe o que está no ar.

**Correção:** tag do Git a cada publicação.

---

## 🛠️ Exercício guiado

**Passo 1.** Compile sem `--base-href`, sirva de uma subpasta e provoque a tela branca.

**Passo 2.** Leia o Console. Quais arquivos deram 404, e o que falta no caminho deles?

**Passo 3.** Recompile com `--base-href /foco/` e recarregue com **F5**. Funcionou? Por que não?

**Passo 4.** Recarregue com **Ctrl+Shift+R**. Agora sim?

**Passo 5.** Abra `build/web/index.html` e confirme a linha `<base href>`.

**Passo 6.** Compile **sem** `--no-web-resources-cdn`. Na aba Network, de onde vem o
`canvaskit.wasm`?

**Passo 7.** Ainda sem a flag, marque **Offline** e recarregue. O app abre?

**Passo 8.** Recompile **com** a flag e repita o passo 7. Mudou?

**Passo 9.** Crie `config/prod.json` com `API_BASE_URL`, compile com `--dart-define-from-file` e
**procure a URL dentro do `main.dart.js`**. Ela está em texto puro?

**Passo 10.** Rode o `release-web.ps1` com um `scope` propositalmente diferente no manifest. Ele
recusa?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Diagnóstico** (tela branca), **Aplicação** (script de release) e **Reflexão**
(o que pode e o que não pode ir num `--dart-define` na web).

---

## 🏆 Desafio opcional

Monte um **pipeline de release web com dois ambientes**, homologação e produção.

Requisitos:

- `config/homolog.json` e `config/prod.json`, com `API_BASE_URL` e `AMBIENTE` diferentes.
- Duas subpastas publicadas: `/foco-homolog/` e `/foco/`, cada uma com seu `--base-href` — e um
  `manifest.json` por ambiente, com `scope`, `name` e `id` próprios.
- Uma faixa visual no app quando `AMBIENTE != producao`, para ninguém confundir as duas.
- O script recusando o build se o `scope` não casar com o `--base-href`.
- Source maps arquivados por versão, fora da pasta publicada, com o `.gitignore` cobrindo a pasta.
- Uma tabela em `docs/release-web.md`: ambiente × URL × config × quem pode publicar.

Depois responda: por que os dois ambientes precisam de **`id` diferente** no manifest? O que
aconteceria com o banco IndexedDB de quem instalasse os dois — e como isso se relaciona com a
[Aula 4](04-banco-de-dados-na-web.md)?

---

## 📌 Resumo

- `flutter build web --release` gera a pasta `build/web/`. Não há assinatura nem `versionCode`.
- **`--base-href` é a pegadinha nº 1.** Precisa começar e terminar com `/`, e ser **igual ao `scope`**
  do manifest. Errado → **tela branca** com 404 em `main.dart.js`.
- Funciona local e quebra publicado? É `--base-href`: local é raiz, publicado é subpasta.
- Depois de corrigir, recarregue com **Ctrl+Shift+R** — o service worker antigo serve cache quebrado.
- **`--no-web-resources-cdn` é quase obrigatório:** por padrão o CanvasKit vem de CDN e **o service
  worker não o guarda**, então o app instalado pode não abrir offline.
- **`--dart-define-from-file` é configuração, não segredo.** O valor vai literal para o
  `main.dart.js`. Na web, nada no cliente é secreto.
- Chave no cliente só se for **pública e restrita por domínio** — a restrição protege, não o sigilo.
- `--source-maps` **sim**; e **arquive os `.map` fora** da pasta publicada, como os símbolos do
  Android.
- **Valide servindo localmente**, imitando a subpasta. `flutter run -d chrome --release` serve na
  raiz e não reproduz o problema.
- Confira objetivamente: `base href`, service worker, CanvasKit local, manifest, `sqlite3.wasm`,
  `sqflite_sw.js`, ícones.
- Rode `flutter test --platform chrome`: é o **único** portão que pega os erros da Aula 3.
- Sem `versionCode`, a disciplina de versão é **inteiramente sua**: tags e `CHANGELOG`.

---

## ☑️ Checklist de domínio

- [ ] Gero o build de produção e sei ler a saída.
- [ ] Explico o que o `--base-href` faz e as três regras dele.
- [ ] Reconheço a tela branca por 404 no console em dois segundos.
- [ ] Mantenho `base-href` e `scope` alinhados.
- [ ] Recarrego com Ctrl+Shift+R ao validar correção.
- [ ] Uso `--no-web-resources-cdn` e explico por quê.
- [ ] Sei exatamente o que pode e o que não pode ir num `--dart-define` na web.
- [ ] Gero e **arquivo** os source maps fora da pasta publicada.
- [ ] Sirvo o build localmente, em subpasta, antes de publicar.
- [ ] Confiro os sete itens do artefato.
- [ ] Rodo a suíte com `--platform chrome`.
- [ ] Marco uma tag do Git a cada publicação.

---

## 📚 Referências oficiais

- [Build and release a web app — docs.flutter.dev](https://docs.flutter.dev/deployment/web)
- [flutter build web — docs.flutter.dev](https://docs.flutter.dev/reference/flutter-cli)
- [Customizing web app initialization — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/initialization)
- [Compiling to WebAssembly — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/wasm)
- [The base element — MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base)
- [Source maps — MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/SourceMap)
- [dhttpd — pub.dev](https://pub.dev/packages/dhttpd)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Instalabilidade](07-instalabilidade.md) | [README](README.md) | [Publicando no GitHub Pages](09-publicando-no-github-pages.md) |
