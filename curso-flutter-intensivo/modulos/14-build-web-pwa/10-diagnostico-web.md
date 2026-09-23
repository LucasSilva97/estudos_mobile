# Aula 10 — Diagnóstico web

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 50 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Aplicar um **roteiro fixo de diagnóstico** — quatro perguntas — em vez de tentar coisas ao acaso.
- Usar as quatro abas do DevTools que importam: **Console**, **Network**, **Application** e
  **Lighthouse**.
- Resolver, por tabela **sintoma → causa → correção**, os erros reais de build, deploy e execução web.
- Distinguir os **três tipos de tela branca**, que têm causas completamente diferentes.
- Decifrar um stack trace de produção com **source maps**.
- Ler o relatório do **Lighthouse** e saber o que nele é acionável.
- Montar um **checklist pós-deploy** que você roda em cinco minutos.

## ✅ Pré-requisitos

- Aulas [1](01-por-que-pwa.md) a [9](09-publicando-no-github-pages.md) do módulo.
- O Foco **publicado** em uma URL pública ([Aula 9](09-publicando-no-github-pages.md)).
- [Módulo 12, aula 3 — DevTools](../12-testes-e-debug/03-devtools.md) — o DevTools do Flutter; este
  aqui é o do **navegador**, e são ferramentas diferentes.

---

## 📖 Conceito

### O roteiro fixo

Quase todo problema web é resolvido respondendo estas quatro perguntas, **nesta ordem**:

```text
1. O Console (F12) mostra erro?          → é código ou é CORS
2. A Network mostra 404?                 → é --base-href ou arquivo faltando
3. O Application mostra service worker
   ativo com versão velha?               → é cache
4. Funciona em janela anônima?           → confirma que é cache/estado local
```

> 📌 **A pergunta 4 é a mais barata e a mais reveladora.** Janela anônima não tem service worker
> registrado, não tem IndexedDB, não tem `localStorage`. Se funciona lá e não na janela normal, o
> problema é estado local — e você acabou de eliminar metade das hipóteses em cinco segundos.

### As quatro abas

| Aba | Para quê | O erro típico |
|---|---|---|
| **Console** | Exceções, avisos, CORS | `Unsupported operation`, CORS bloqueado |
| **Network** | O que foi pedido e o que voltou | 404 em `main.dart.js` |
| **Application** | Manifest, service workers, armazenamento | Versão presa, banco, instalabilidade |
| **Lighthouse** | Auditoria automática | "Does not work offline" |

### Os três tipos de tela branca

Este é o sintoma mais frequente e o mais mal diagnosticado. São **três problemas diferentes** com a
mesma aparência.

```text
TELA BRANCA
    │
    ├─ Console mostra 404 em main.dart.js
    │     → tipo 1: CAMINHO  (--base-href)
    │
    ├─ Console mostra exceção do Dart
    │     → tipo 2: CÓDIGO   (erro no main, plugin sem web)
    │
    └─ Console limpo, Network limpa
          → tipo 3: CACHE    (service worker servindo build quebrado)
```

| Tipo | Causa | Correção | Aula |
|---|---|---|---|
| **1. Caminho** | `--base-href` errado ou ausente | Recompilar com o caminho certo | [8](08-gerando-o-build-web.md) |
| **2. Código** | Exceção antes do primeiro `runApp` | Ler o stack trace | [3](03-o-que-nao-funciona-na-web.md) |
| **3. Cache** | Service worker com versão quebrada | Ctrl+Shift+R, ou "Unregister" | [6](06-service-worker-e-offline.md) |

> ⚠️ **Não tente a correção do tipo 3 primeiro.** É o reflexo mais comum — limpar cache e recarregar
> — e ele **esconde** os tipos 1 e 2 por uma recarga, fazendo você concluir que "às vezes funciona".
> Olhe o Console **antes** de limpar qualquer coisa.

### Tabela sintoma → causa → correção

#### Build

| Sintoma | Causa | Correção |
|---|---|---|
| `Error: Dart library 'dart:io' is not available` | Import de `dart:io` em arquivo compilado para web | Importação condicional ([Aula 3](03-o-que-nao-funciona-na-web.md)) |
| `base-href should start and end with /` | `--base-href /foco` | `/foco/` |
| `Target dart2js failed` | Pacote sem suporte a web | Confira o selo `Web` no pub.dev |
| Build passa, `flutter test --platform chrome` falha | Código só-nativo em caminho testado | [Aula 3](03-o-que-nao-funciona-na-web.md) |
| `MaterialIcons` com 1,6 MB | Tree shaking desligado por ícone dinâmico | Use `IconData` constante ([Aula 2](02-como-o-flutter-compila-para-web.md)) |

#### Carregamento

| Sintoma | Causa | Correção |
|---|---|---|
| Tela branca + `404 main.dart.js` | `--base-href` | Recompile com `/nome-do-repo/` |
| Tela branca + exceção no Console | Erro antes do `runApp` | Leia o stack trace com source maps |
| Tela branca + Console limpo | Service worker com build quebrado | Ctrl+Shift+R ou Unregister |
| Funciona local, quebra publicado | Raiz × subpasta | `--base-href` |
| README aparece em vez do app | Pages em "Deploy from a branch" | Source = GitHub Actions ([Aula 9](09-publicando-no-github-pages.md)) |
| App carrega, fica no spinner | Erro assíncrono no `main()` | `try/catch` no bootstrap |
| Demora enorme na 1ª visita | CanvasKit + `main.dart.js` em rede ruim | Meça ([Aula 2](02-como-o-flutter-compila-para-web.md)) |

#### Execução

| Sintoma | Causa | Correção |
|---|---|---|
| `Unsupported operation: Platform._operatingSystem` | `Platform.isX` na web | `Plataforma.ehApple(context)` |
| `MissingPluginException(... path_provider)` | Plugin sem web | Importação condicional |
| `ClientException: Failed to fetch` | **CORS** | Cabeçalho no servidor, ou proxy |
| `Failed to load sqlite3.wasm` | Setup não rodado, ou arquivo não commitado | `dart run sqflite_common_ffi_web:setup` + `git add` |
| `QuotaExceededError` | Cota de armazenamento estourada | `persist()` + limpeza ([Aula 4](04-banco-de-dados-na-web.md)) |
| Dados somem entre sessões | Aba anônima, ou despejo | Janela normal; `persist()` |
| Dados somem depois de publicar | **A URL mudou** | A origem é a identidade ([Aula 4](04-banco-de-dados-na-web.md)) |
| `Mixed Content ... blocked` | Página HTTPS pedindo recurso HTTP | Use HTTPS em tudo |
| Animação travando em consulta grande | `databaseFactoryFfiWebNoWebWorker` | Volte para `databaseFactoryFfiWeb` |

#### PWA

| Sintoma | Causa | Correção |
|---|---|---|
| Botão de instalar não aparece | Um dos 8 critérios falhou | Application → Manifest → Installability |
| Não aparece, e tudo está verde | Já instalado | Desinstale para testar |
| Não aparece ao abrir pelo IP da rede | `http://192.168…` não é origem segura | `localhost` ou publicado |
| Ícone no iPhone é um print da página | Falta `apple-touch-icon` | [Aula 5](05-manifest-e-icones.md) |
| Ícone com moldura branca no Android | Falta `maskable` | [Aula 5](05-manifest-e-icones.md) |
| Barra de navegador dentro do app | `scope` ≠ `--base-href` | Alinhe os dois |
| Nome cortado embaixo do ícone | `short_name` longo | Até ~12 caracteres |
| Usuário preso na versão antiga | Ciclo do service worker | Aviso de atualização ([Aula 6](06-service-worker-e-offline.md)) |
| Não abre offline | CanvasKit vindo de CDN | `--no-web-resources-cdn` ([Aula 8](08-gerando-o-build-web.md)) |
| Link direto para rota interna dá 404 | Host estático sem rewrite | `404.html` ([Aula 9](09-publicando-no-github-pages.md)) |

### Source maps: decifrando produção

Em release, o `dart2js` minifica tudo. Um erro real chega assim:

```text
TypeError: Cannot read properties of null (reading 'a')
    at aQ.$1 (main.dart.js:24891:15)
    at bk.gS (main.dart.js:18332:7)
```

Inútil. Com o `.map` correspondente — o que o workflow da
[Aula 9](09-publicando-no-github-pages.md) arquiva — o DevTools reconstrói:

```text
TypeError: Cannot read properties of null
    at SessaoDao.somarMinutos (package:foco/features/sessoes/data/sessao_dao.dart:84:22)
    at EstatisticasController.build (package:foco/features/estatisticas/…:31:9)
```

Para usar: DevTools → **Sources** → clique com o botão direito no arquivo → **Add source map**, e
aponte para o `.map` que você baixou do artefato daquela versão.

> ⚠️ **O `.map` precisa ser o daquela build exata.** Um mapa de outra versão devolve linhas erradas
> com confiança total — o que é pior do que não ter mapa. É por isso que o workflow os nomeia com o
> `github.sha`, como os símbolos por versão do
> [Módulo 15, aula 8](../15-build-android/08-gerando-apk-e-aab.md).

### Lighthouse: o que é acionável

```powershell
# Ou: DevTools → Lighthouse → Analyze page load
```

| Seção | Vale para um app Flutter? |
|---|---|
| **PWA / instalabilidade** | ✅ **Sim** — é o mais útil |
| **Performance** | ⚠️ Parcial — ele pune o peso do CanvasKit, que é o piso |
| **Accessibility** | ⚠️ Parcial — ele vê um `<canvas>` |
| **Best practices** | ✅ Sim — HTTPS, conteúdo misto, erros de console |
| **SEO** | ❌ Ignore — Flutter web não é para SEO ([Aula 2](02-como-o-flutter-compila-para-web.md)) |

> 💡 **Não persiga 100 no Performance.** Uma nota baixa ali costuma refletir os ~1,5 MB do CanvasKit,
> que você não pode remover. O que é acionável é a seção de instalabilidade e a de boas práticas — e
> a métrica que realmente importa você já mede à mão ([Aula 2](02-como-o-flutter-compila-para-web.md)).

---

## 💡 Analogia

Pense num **carro que não liga**.

- **O mecânico ruim** troca a bateria. Se não resolveu, troca a vela. Se não resolveu, troca o
  alternador. Ele acerta em algum momento, e leva um dia — porque nunca soube qual era o problema,
  só o que sobrou.
- **O mecânico bom faz quatro perguntas**, na ordem: o painel acende? (Console) O motor de arranque
  gira? (Network) Chega combustível? (Application) E, o mais barato de todos: **funciona com a
  bateria de outro carro?** (janela anônima).
- **Os três tipos de tela branca** são três carros parados na mesma vaga: um sem combustível, um com
  a chave errada, um com o alarme travado. De fora, todos idênticos. **Limpar o cache é trocar a
  bateria por reflexo** — às vezes o carro anda, e você não aprendeu nada.
- **O source map é o manual do fabricante.** Sem ele, o código de erro do painel é `P0AF1`. Com ele,
  é "sensor de oxigênio do cilindro 3". E o manual precisa ser o do **ano certo** — o do ano errado
  aponta um sensor que nem existe nesse motor.
- **E o Lighthouse é a inspeção anual:** ótima para itens objetivos (farol, freio, HTTPS), e sem
  sentido quando reclama que o carro é pesado — ele é uma van, e você sabia disso ao comprar.

---

## 🧪 Exemplo mínimo

Provoque os três tipos de tela branca, na ordem, para aprender a distingui-los em segundos.

**Tipo 1 — caminho:**

```powershell
flutter build web --release        # sem --base-href
# servir de uma subpasta
```

```text
Console: GET /main.dart.js 404 (Not Found)
```

**Tipo 2 — código:**

```dart
// lib/main.dart — só para o experimento
import 'dart:io';

Future<void> main() async {
  print(Platform.operatingSystem);   // 💥
  // …
}
```

```text
Console: Unsupported operation: Platform._operatingSystem
```

**Tipo 3 — cache:**

```powershell
# 1. publique uma versão quebrada, abra e deixe o SW registrar
# 2. conserte e publique de novo
# 3. recarregue com F5 (não Ctrl+Shift+R)
```

```text
Console: (vazio)
Network: (tudo 200, servido pelo service worker)
Tela:    branca mesmo assim
```

**A tabela de decisão, agora que você viu os três:**

| Console | Network | É |
|---|---|---|
| 404 | 404 | Tipo 1 — caminho |
| Exceção Dart | 200 | Tipo 2 — código |
| Vazio | 200 (from ServiceWorker) | Tipo 3 — cache |

> 💡 **Na coluna "Size" da Network, o service worker se identifica:** em vez do tamanho, aparece
> `(ServiceWorker)`. É o jeito mais rápido de saber se você está vendo a rede ou o cache.

---

## 📱 Aplicando no Flutter

### Botão de pânico do service worker

Quando precisar garantir que está vendo o build novo:

```text
DevTools → Application → Service workers
  ☐ Offline
  ☑ Update on reload          ← durante o desenvolvimento
  [Unregister]                ← o botão de pânico
```

E, para limpar tudo — **inclusive o banco**:

```text
DevTools → Application → Storage → [Clear site data]
```

> ⚠️ **"Clear site data" apaga o IndexedDB.** Ou seja, apaga as matérias e sessões do Foco. Durante
> o desenvolvimento, tudo bem. Se você estiver depurando com dados que não quer perder, use
> **Unregister** no service worker, que não toca no armazenamento.

### O teste que move a descoberta para antes do deploy

```powershell
flutter test --platform chrome
```

Este comando roda a sua suíte **dentro de um navegador headless**. É o único portão automatizado que
pega os erros da [Aula 3](03-o-que-nao-funciona-na-web.md) — os que compilam, passam no `flutter
test` normal e explodem no usuário.

| Comando | Roda onde | Pega erro só-web? |
|---|---|---|
| `flutter test` | Dart VM | ❌ **Não** |
| `flutter test --platform chrome` | Chrome headless | ✅ Sim |
| `flutter analyze` | Estático | ⚠️ Alguns |

---

## 💻 Código completo

Um script de verificação pós-deploy: roda contra a URL publicada e confere o que dá para conferir
sem abrir o navegador.

> **Arquivo:** `scripts/verificar-deploy.ps1`
> **Como executar:** `.\scripts\verificar-deploy.ps1 -Url https://SEU_USUARIO.github.io/foco/`

```powershell
# Verificação pós-deploy. Roda contra a URL publicada e responde, em
# ~10 segundos, se o deploy saiu inteiro.
#
# NÃO substitui abrir no celular e testar offline — substitui as
# checagens mecânicas que ninguém lembra de fazer toda vez.

param(
    [Parameter(Mandatory = $true)]
    [string]$Url
)

$ErrorActionPreference = "Stop"
if (-not $Url.EndsWith("/")) { $Url = "$Url/" }

$falhas = @()

function Testar($nome, $bloco) {
    try {
        $resultado = & $bloco
        if ($resultado) {
            Write-Host "  [OK]    $nome" -ForegroundColor Green
        } else {
            Write-Host "  [FALHA] $nome" -ForegroundColor Red
            $script:falhas += $nome
        }
    } catch {
        Write-Host "  [ERRO]  $nome — $($_.Exception.Message)" -ForegroundColor Red
        $script:falhas += $nome
    }
}

Write-Host "`nVerificando $Url`n" -ForegroundColor Cyan

# ══════════════════════════════════════════════════════════════
# 1. A página responde, e por HTTPS
# ══════════════════════════════════════════════════════════════
$indice = $null
Testar "index.html responde 200" {
    $script:indice = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $script:indice.StatusCode -eq 200
}
Testar "servido por HTTPS (exigido para PWA)" { $Url.StartsWith("https://") }

# ══════════════════════════════════════════════════════════════
# 2. O <base href> bate com a URL — a causa nº 1 de tela branca
# ══════════════════════════════════════════════════════════════
# Comparamos o caminho da URL com o que o build gravou. Divergência
# aqui significa 404 em main.dart.js e tela branca (Aula 8).
Testar "<base href> corresponde ao caminho da URL" {
    $caminho = ([uri]$Url).AbsolutePath
    $indice.Content -match [regex]::Escape("<base href=`"$caminho`"")
}

# ══════════════════════════════════════════════════════════════
# 3. Os arquivos que precisam existir
# ══════════════════════════════════════════════════════════════
# Cada um destes, faltando, produz uma falha SILENCIOSA diferente:
#   main.dart.js              → tela branca
#   flutter_service_worker.js → sem offline, sem instalação
#   manifest.json             → sem instalação
#   canvaskit/canvaskit.wasm  → não abre offline (veio de CDN)
#   sqlite3.wasm              → o app abre e o BANCO não
#   404.html                  → rota profunda dá 404
foreach ($arquivo in @(
    "main.dart.js",
    "flutter_service_worker.js",
    "manifest.json",
    "canvaskit/canvaskit.wasm",
    "sqlite3.wasm",
    "sqflite_sw.js",
    "404.html",
    "icons/Icon-512.png"
)) {
    Testar "existe $arquivo" {
        (Invoke-WebRequest -Uri "$Url$arquivo" -UseBasicParsing -Method Head).StatusCode -eq 200
    }
}

# ══════════════════════════════════════════════════════════════
# 4. O manifest está preenchido de verdade
# ══════════════════════════════════════════════════════════════
Testar "manifest com os campos essenciais" {
    $m = (Invoke-WebRequest -Uri "${Url}manifest.json" -UseBasicParsing).Content | ConvertFrom-Json
    $caminho = ([uri]$Url).AbsolutePath

    # scope divergente do caminho = barra de navegador dentro do app
    $temEscopo    = $m.scope -eq $caminho
    $temNome      = -not [string]::IsNullOrWhiteSpace($m.name)
    $temCurto     = $m.short_name.Length -le 12 -and $m.short_name.Length -gt 0
    # o texto que o flutter create deixa e quase ninguém troca
    $semGenerico  = $m.description -ne "A new Flutter project."
    $temMaskable  = ($m.icons | Where-Object { $_.purpose -match "maskable" }).Count -ge 1

    if (-not $temEscopo)   { Write-Host "          scope='$($m.scope)' ≠ '$caminho'" -ForegroundColor Yellow }
    if (-not $temCurto)    { Write-Host "          short_name com $($m.short_name.Length) caracteres" -ForegroundColor Yellow }
    if (-not $semGenerico) { Write-Host "          description ainda é a do flutter create" -ForegroundColor Yellow }
    if (-not $temMaskable) { Write-Host "          nenhum ícone maskable (moldura branca no Android)" -ForegroundColor Yellow }

    $temEscopo -and $temNome -and $temCurto -and $semGenerico -and $temMaskable
}

# ══════════════════════════════════════════════════════════════
# 5. Nenhum source map publicado
# ══════════════════════════════════════════════════════════════
# Eles reconstroem o seu código Dart original (Aula 8). O resultado
# esperado aqui é 404 — por isso a lógica está invertida.
Testar "source maps NÃO estão publicados" {
    try {
        Invoke-WebRequest -Uri "${Url}main.dart.js.map" -UseBasicParsing -Method Head | Out-Null
        $false   # respondeu 200 = está publicado = falha
    } catch {
        $true    # 404 = correto
    }
}

# ══════════════════════════════════════════════════════════════
# Resultado
# ══════════════════════════════════════════════════════════════
Write-Host ""
if ($falhas.Count -eq 0) {
    Write-Host "Deploy íntegro." -ForegroundColor Green
    Write-Host "`nFalta o que só o aparelho responde:" -ForegroundColor Yellow
    Write-Host "  1. Abrir no celular e instalar"
    Write-Host "  2. Modo avião e abrir pelo ícone"
    Write-Host "  3. Criar uma sessão offline e conferir que ela sobrevive ao F5"
    exit 0
} else {
    Write-Host "$($falhas.Count) verificação(ões) falharam:" -ForegroundColor Red
    $falhas | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Normalizar a URL com barra final | Sem isso, `$Url$arquivo` gera `foco main.dart.js` grudado errado. |
| Comparar `<base href>` com o caminho da URL | Detecta, sem abrir o navegador, a causa nº 1 de tela branca. |
| `-Method Head` nos arquivos | Só os cabeçalhos: verifica existência sem baixar 1,5 MB. |
| A lista de arquivos comentada | Cada ausência tem um sintoma **diferente e silencioso** — o comentário é o que torna a falha legível. |
| `scope` × caminho da URL | Divergência não quebra nada visível até alguém **instalar** o app. |
| `short_name.Length -le 12` | O limite prático embaixo do ícone ([Aula 5](05-manifest-e-icones.md)). |
| Checar a `description` genérica | O campo que sobrevive mais tempo sem ser trocado. |
| Exigir ao menos um `maskable` | Sem ele, moldura branca no Android — e ninguém percebe no desktop. |
| Teste de source map **invertido** | Aqui o sucesso é o 404. O comentário evita que alguém "conserte" a lógica. |
| Avisos amarelos por campo | Diz **qual** campo falhou, não só que o manifest falhou. |
| `exit 1` em falha | Permite usar o script como portão em CI. |
| A lista final do que o script não cobre | Marca o limite da automação: offline real só o aparelho responde. |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| Ferramenta principal | DevTools do navegador | `flutter doctor`, Logcat | Xcode, Console.app |
| Onde o erro aparece | ⚠️ **Em runtime, no usuário** | Em build | Em build |
| Stack trace legível | `--source-maps` + `.map` | `--split-debug-info` | `--split-debug-info` |
| Símbolos por versão | `.map` por commit | Símbolos por `versão+N` | Idem |
| Erro mais comum | `--base-href` / cache | Assinatura / Gradle | CocoaPods / provisioning |
| Auditoria automática | **Lighthouse** | Play Console pre-launch | App Store Connect |
| Tempo do ciclo corrigir→ver | **~2 min** | ~10 min | ~30 min |

> 💡 **O ciclo curto é a compensação.** A web descobre os erros tarde (no usuário), e por isso exige
> mais disciplina de teste. Em troca, corrigir e republicar leva dois minutos — contra uma nova
> submissão na App Store. Na prática, é um ótimo negócio, **desde que** você tenha o
> `flutter test --platform chrome` no CI para compensar o que o compilador não avisa.

🪟 **No Windows**, esta aula funciona por completo.

---

## ⚠️ Erros comuns

### 1. Limpar cache antes de olhar o Console

Esconde os tipos 1 e 2 por uma recarga.

**Correção:** Console primeiro, sempre.

### 2. Tratar as três telas brancas como o mesmo problema

Três causas, três correções.

**Correção:** a tabela de decisão.

### 3. Não testar em janela anônima

É a eliminação mais barata que existe.

**Correção:** pergunta 4 do roteiro.

### 4. Validar com `flutter run -d chrome`

Não reproduz subpasta nem service worker de produção.

**Correção:** sirva o build como um servidor comum.

### 5. Usar um `.map` de outra versão

Linhas erradas com confiança total.

**Correção:** `.map` do commit exato.

### 6. Perseguir 100 no Lighthouse Performance

Ele pune o CanvasKit, que é o piso.

**Correção:** foque em PWA e Best practices.

### 7. Levar o SEO do Lighthouse a sério

Flutter web não é para SEO.

**Correção:** ignore essa seção.

### 8. "Clear site data" ao depurar dados reais

Apaga o IndexedDB junto.

**Correção:** use Unregister.

### 9. Achar que `flutter test` cobre a web

Roda na Dart VM.

**Correção:** `--platform chrome`.

### 10. Deixar "Update on reload" marcado ao validar

Só a sua máquina se comporta assim.

**Correção:** desmarque para validar.

### 11. Concluir que o deploy falhou porque a URL mostra o antigo

É o ciclo do service worker.

**Correção:** segunda abertura.

### 12. Depurar o service worker errado

`sqflite_sw.js` é banco, `flutter_service_worker.js` é cache.

**Correção:** leia o nome e o *scope*.

---

## 🛠️ Exercício guiado

**Passo 1.** Provoque a tela branca tipo 1 e registre o que aparece no Console e na Network.

**Passo 2.** Provoque a tipo 2 (um `Platform.operatingSystem` no `main`). Compare.

**Passo 3.** Provoque a tipo 3 (publique quebrado, conserte, recarregue com F5). Compare.

**Passo 4.** Em cada caso, teste em janela anônima. Qual dos três muda de comportamento?

**Passo 5.** Rode `.\scripts\verificar-deploy.ps1` contra a sua URL. Passou tudo?

**Passo 6.** Remova o `maskable` do manifest, republique e rode o script. Ele acusa?

**Passo 7.** Rode o Lighthouse. Qual a nota de Performance? E a seção PWA?

**Passo 8.** Baixe o artefato de source maps da execução do workflow e decifre um stack trace de
produção provocado de propósito.

**Passo 9.** Na aba Network, ache uma requisição servida pelo service worker. O que aparece na
coluna Size?

**Passo 10.** Rode `flutter test --platform chrome` depois de reintroduzir um `Platform.isIOS` numa
tela. O teste falha?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Diagnóstico** (os três tipos de tela branca), **Aplicação** (script de verificação) e
o **Desafio prático** que fecha o módulo.

---

## 🏆 Desafio opcional

Monte o **kit de diagnóstico do Foco na web** e prove que ele funciona.

Requisitos:

- `docs/diagnostico-web.md` com a tabela sintoma → causa → correção **da sua experiência**, não a
  copiada daqui: só entram problemas que você viveu, com a mensagem exata que apareceu.
- O `verificar-deploy.ps1` rodando como **último passo do workflow**, contra a URL recém-publicada,
  falhando a execução se algo estiver errado.
- Um relatório do Lighthouse arquivado por release, com as notas de PWA e Best practices.
- Uma tela de diagnóstico dentro do app (só em debug) mostrando: versão, hash do commit, estado do
  service worker, uso e cota de armazenamento e se o modo persistente foi concedido.
- Um teste em Chrome que **falhe** se alguém reintroduzir `Platform.isX`, `dart:io` ou
  `getDatabasesPath` em `lib/`.
- Um registro de **três problemas que você provocou de propósito** e o tempo que levou para
  diagnosticar cada um usando o roteiro de quatro perguntas.

Depois responda: dos três problemas que você provocou, qual você teria demorado mais para achar
**sem** o roteiro? E qual das quatro perguntas eliminou mais hipóteses de uma vez?

---

## 📌 Resumo

- O roteiro é fixo e tem **quatro perguntas**: Console? Network 404? Service worker com versão
  velha? Funciona em anônima?
- **Janela anônima é a eliminação mais barata**: sem service worker, sem IndexedDB, sem
  `localStorage`.
- **Três telas brancas, três causas:** caminho (`--base-href`), código (exceção antes do `runApp`) e
  cache (service worker). O Console distingue as três em segundos.
- **Nunca limpe o cache antes de olhar o Console** — isso esconde os outros dois tipos.
- Quatro abas: **Console** (exceções, CORS), **Network** (404, `(ServiceWorker)` na coluna Size),
  **Application** (manifest, SW, armazenamento), **Lighthouse** (auditoria).
- Stack trace de produção exige **source maps**, e o `.map` precisa ser **daquela build exata**.
- No Lighthouse, o acionável é **PWA** e **Best practices**. Performance pune o CanvasKit;
  **SEO é irrelevante** para Flutter web.
- **`flutter test --platform chrome`** é o único portão automatizado que pega os erros da
  [Aula 3](03-o-que-nao-funciona-na-web.md). `flutter test` roda na Dart VM e dá falso verde.
- "Unregister" mexe só no service worker; **"Clear site data" apaga o banco**.
- A web descobre erro tarde e corrige em **2 minutos** — o ciclo curto compensa, desde que haja
  teste no CI.

---

## ☑️ Checklist de domínio

- [ ] Aplico o roteiro de quatro perguntas antes de tentar qualquer coisa.
- [ ] Distingo os três tipos de tela branca pelo Console e pela Network.
- [ ] Sei por que não se limpa o cache antes de diagnosticar.
- [ ] Uso as quatro abas do DevTools com propósito definido.
- [ ] Reconheço `(ServiceWorker)` na coluna Size.
- [ ] Decifro um stack trace de produção com o `.map` correto da versão.
- [ ] Sei o que é acionável no Lighthouse e o que ignorar.
- [ ] Rodo `flutter test --platform chrome` e entendo o que ele pega a mais.
- [ ] Diferencio "Unregister" de "Clear site data".
- [ ] Tenho um script de verificação pós-deploy e o rodo a cada publicação.
- [ ] Sei o que o script **não** cobre e testo isso no aparelho.
- [ ] Consigo diagnosticar os erros das dez aulas pela tabela.

---

## 📚 Referências oficiais

- [Debugging web apps — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/debugging)
- [Web FAQ — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/faq)
- [Chrome DevTools — developer.chrome.com](https://developer.chrome.com/docs/devtools)
- [Application panel — developer.chrome.com](https://developer.chrome.com/docs/devtools/application)
- [Lighthouse — developer.chrome.com](https://developer.chrome.com/docs/lighthouse/overview)
- [Use source maps — developer.chrome.com](https://developer.chrome.com/docs/devtools/javascript/source-maps)
- [Testing on the web — docs.flutter.dev](https://docs.flutter.dev/testing/overview)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo módulo |
|---|---|---|
| [Publicando no GitHub Pages](09-publicando-no-github-pages.md) | [README](README.md) | [Módulo 15 — Build Android](../15-build-android/README.md) |
