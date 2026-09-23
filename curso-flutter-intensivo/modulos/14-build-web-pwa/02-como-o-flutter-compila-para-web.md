# Aula 2 — Como o Flutter compila para web

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar os **dois caminhos de compilação** do Flutter web — `dart2js` e `dart2wasm` — e o que
  cada um produz.
- Entender o que é o **CanvasKit** e por que o Flutter desenha a tela em um `<canvas>` em vez de
  usar elementos HTML.
- Listar o conteúdo de **`build/web/`** e dizer para que serve cada arquivo.
- Explicar por que o **primeiro carregamento** é, na web, a métrica que substitui "tamanho do app"
  — e por que ela é a única que o usuário sente.
- Entender o **tree shaking** de ícones e por que ele derruba o `MaterialIcons` de 1,6 MB para
  poucos KB.
- Relacionar tudo isso com o que você já sabe de **JIT × AOT** do
  [Módulo 15, aula 1](../15-build-android/01-debug-profile-release.md).

## ✅ Pré-requisitos

- [Aula 1 — Por que PWA é o canal principal](01-por-que-pwa.md).
- [Módulo 05, aula 1 — Como o Flutter funciona](../05-introducao-ao-flutter/01-como-o-flutter-funciona.md) —
  a árvore de widgets e o engine.
- [Módulo 13, aula 4 — Medindo desempenho](../13-desempenho-e-seguranca/04-medindo-desempenho.md) —
  medir antes de otimizar.

---

## 📖 Conceito

### O problema: o navegador não executa Dart

Nenhum navegador tem uma VM de Dart. Para o Foco rodar no Chrome, o Dart precisa virar algo que o
navegador entenda — e existem exatamente duas coisas que ele entende:

```text
                  ┌─────────────────┐
   seu código     │   JavaScript    │   ← dart2js       (padrão)
   em Dart   ───► ├─────────────────┤
                  │   WebAssembly   │   ← dart2wasm     (--wasm)
                  └─────────────────┘
```

E não é só o **seu** código: o **engine do Flutter** — que no Android é o `libflutter.so`, um
binário nativo de ~7 MB — também precisa atravessar. É aí que entra o CanvasKit.

### Os dois caminhos

| | `dart2js` (padrão) | `dart2wasm` (`--wasm`) |
|---|---|---|
| Comando | `flutter build web` | `flutter build web --wasm` |
| Saída principal | `main.dart.js` | `main.dart.wasm` + `main.dart.mjs` |
| Renderizador | **CanvasKit** | **skwasm** |
| Compatibilidade | Todos os navegadores atuais | Precisa de **WasmGC** (Chrome/Edge 119+, Firefox 120+) |
| Velocidade de execução | Boa | **Melhor**, especialmente em animação |
| Tamanho | Menor no total | Maior, mas carrega em paralelo |
| Navegador sem suporte | — | O Flutter emite um **fallback em JS** e serve ele |

> 📌 **Comece pelo padrão.** `flutter build web --release` sem `--wasm` funciona em todo lugar e é o
> que a [Aula 9](09-publicando-no-github-pages.md) publica. O `--wasm` é uma otimização que você
> mede depois ([Aula 8](08-gerando-o-build-web.md)) — não uma decisão inicial.

### O que é o CanvasKit

Aqui está a parte que costuma surpreender: **o Flutter web não gera HTML para a sua interface**.

Um `ElevatedButton` do Foco **não** vira um `<button>`. Não existe `<div>` para o `Card`, nem `<p>`
para o `Text`. O Flutter pega um único `<canvas>` na página e **desenha tudo dentro dele**, pixel a
pixel, exatamente como faria na tela de um Android.

```text
O que um site comum faz          O que o Flutter web faz
┌──────────────────────┐         ┌──────────────────────┐
│ <header>             │         │ <canvas>             │
│   <h1>Foco</h1>      │         │                      │
│ </header>            │         │   (tudo desenhado    │
│ <main>               │         │    aqui dentro)      │
│   <button>Nova</...> │         │                      │
│ </main>              │         │ </canvas>            │
└──────────────────────┘         └──────────────────────┘
  o navegador desenha              o Flutter desenha
```

Quem desenha é o **Skia** — a mesma biblioteca gráfica que o Flutter usa no Android e no iOS —
compilada para WebAssembly. Esse Skia-em-WASM é o **CanvasKit**, e é o arquivo mais pesado do seu
build: cerca de **1,5 MB** de `canvaskit.wasm`.

**Por que fazer isso?** Porque é o que garante que o Foco fique **idêntico** nos três alvos. Um
`Card` com `elevation: 2` tem exatamente a mesma sombra no Android, no iPhone e no Chrome, porque é
o mesmo código de desenho rodando nos três. Se o Flutter traduzisse widgets para HTML, cada
navegador renderizaria um pouco diferente — e o curso inteiro sobre `Theme`, `TextStyle` e
`BoxDecoration` passaria a ter exceções.

| Consequência | Efeito |
|---|---|
| ✅ Fidelidade visual total | O mesmo pixel nos três alvos |
| ✅ Nenhuma surpresa de CSS | Você nunca escreve CSS |
| ⚠️ Peso inicial maior | O CanvasKit precisa ser baixado antes do primeiro quadro |
| ⚠️ Texto não é selecionável por padrão | É desenho, não texto do DOM |
| ⚠️ SEO limitado | O robô do Google vê um `<canvas>`, não o seu conteúdo |
| ⚠️ Acessibilidade exige ponte | O Flutter constrói uma árvore semântica paralela |

> ⚠️ **SEO.** Se o seu objetivo é ranquear conteúdo no Google, Flutter web é a ferramenta errada —
> use um site de verdade. Se o seu objetivo é **distribuir um aplicativo**, como é o caso do Foco,
> o `<canvas>` não é problema: ninguém procura "tela de sessões do Foco" no Google.

> 💡 **Acessibilidade continua funcionando.** O Flutter mantém uma árvore de semântica que ele
> espelha em elementos HTML invisíveis, e é por isso que o `Semantics` que você aprendeu no
> [Módulo 13, aula 5](../13-desempenho-e-seguranca/05-acessibilidade.md) vale também na web. Sem ele,
> o leitor de tela encontra um `<canvas>` mudo.

### O que tem dentro de `build/web/`

```text
build/web/
├── index.html                  ← a página. Carrega o flutter_bootstrap.js
├── flutter_bootstrap.js        ← decide QUAL build carregar e inicializa
├── main.dart.js                ← SEU código + framework Flutter, compilados  (~1,5–2,5 MB)
├── flutter_service_worker.js   ← o service worker (Aula 6)
├── manifest.json               ← identidade do PWA (Aula 5)
├── version.json                ← nome e versão do app, lidos em runtime
├── favicon.png                 ← ícone da aba
├── icons/                      ← ícones do PWA, 192 e 512 px (Aula 5)
├── canvaskit/                  ← o engine gráfico em WASM             (~1,5 MB)
│   ├── canvaskit.js
│   ├── canvaskit.wasm
│   └── chromium/…              ← variante menor, usada quando dá
└── assets/
    ├── AssetManifest.bin.json  ← índice binário dos assets
    ├── FontManifest.json       ← índice das fontes
    ├── NOTICES                 ← licenças de tudo que você usa (obrigatório distribuir)
    ├── fonts/
    │   └── MaterialIcons-Regular.otf   ← já com tree shaking aplicado
    └── …seus assets de imagem
```

| Arquivo | Papel | Dá para mexer? |
|---|---|---|
| `index.html` | Vem de `web/index.html` | ✅ Edite o de `web/`, nunca o de `build/` |
| `manifest.json` | Vem de `web/manifest.json` | ✅ Mesma regra |
| `flutter_bootstrap.js` | Gerado a cada build | ❌ Nunca |
| `main.dart.js` | Gerado a cada build | ❌ Nunca |
| `flutter_service_worker.js` | Gerado a cada build | ❌ Nunca (mas dá para **desligar**) |
| `version.json` | Gerado a partir do `pubspec.yaml` | ❌ Mude o `pubspec` |

> ⚠️ **Tudo em `build/web/` é descartável.** Ele é recriado do zero a cada `flutter build web`, e
> `build/` está no `.gitignore` desde o [Módulo 00](../00-git-e-terminal/04-commits-branches-gitignore.md).
> Editar um arquivo lá é trabalho que some no próximo build. O que você edita é `web/`.

### Tree shaking: o Flutter joga fora o que você não usa

Repare no `MaterialIcons-Regular.otf`. O arquivo original tem cerca de **1,6 MB** e contém mais de
duas mil formas. O Foco usa talvez trinta. O build imprime isso:

```text
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it
from 1645184 to 4324 bytes (99.7% reduction).
```

De 1,6 MB para 4 KB. Esse mecanismo — *tree shaking* — vale para código também: classes e funções
que ninguém referencia não entram no `main.dart.js`.

> ⚠️ **O tree shaking de ícones quebra com ícones dinâmicos.** Se você montar um ícone a partir de
> um código de ponto em runtime (`IconData(codigo, fontFamily: 'MaterialIcons')`), o compilador não
> tem como saber quais você usa e desliga a otimização — o `.otf` volta a 1,6 MB. Se o build
> imprimir um aviso sobre ícones não constantes, é isso. Use constantes (`Icons.timer`) sempre que
> possível.

### Primeiro carregamento: a métrica que substitui "tamanho do app"

No Android você mede o `.aab` e se preocupa acima de 30 MB
([Módulo 15, aula 8](../15-build-android/08-gerando-apk-e-aab.md)). Na web, esse número **não
importa**, porque o usuário nunca baixa a pasta inteira de uma vez. O que importa é:

```text
Quantos bytes o navegador precisa baixar ANTES de o primeiro quadro aparecer?
```

E a resposta, num Foco típico:

| Recurso | Tamanho aproximado | Quando é baixado |
|---|---|---|
| `index.html` + `flutter_bootstrap.js` | ~10 KB | Imediatamente |
| `main.dart.js` | ~1,8 MB | Imediatamente |
| `canvaskit.wasm` | ~1,5 MB | Imediatamente |
| Fontes (com tree shaking) | ~10 KB | Imediatamente |
| Seus assets de imagem | Varia | **Sob demanda** |
| **Total antes do 1º quadro** | **~3,3 MB** | — |

Comprimido com gzip/brotli — o que todo servidor HTTPS decente faz, inclusive o GitHub Pages —
isso vira **~1,2 MB reais na rede**.

| Conexão | Tempo até o 1º quadro (1ª visita) |
|---|---|
| Wi-Fi / fibra | < 1 s |
| 4G bom | 1–2 s |
| 4G ruim / 3G | 4–10 s ⚠️ |
| **2ª visita (cache do service worker)** | **~0,2 s** ✅ |

> 📌 **A segunda visita é praticamente instantânea** — é exatamente para isso que o service worker
> existe. O custo do PWA é concentrado na primeira visita de cada pessoa, e só nela.

---

## 💡 Analogia

Pense em levar uma peça de teatro para uma cidade nova.

- **No Android e no iOS**, você manda o caminhão com o cenário, o figurino e os refletores. O teatro
  de lá já tem palco e tomada. O caminhão é grande (o `.aab` de 28 MB), mas vai uma vez só e fica.
- **Na web, o teatro de lá não tem palco nem refletor** — tem um terreno vazio. Então você manda o
  cenário **e o palco desmontado e os refletores junto**. Esse "palco portátil" é o **CanvasKit**:
  1,5 MB que existem só porque o navegador não sabe desenhar como o Flutter precisa.
- **O `main.dart.js` é o roteiro e os atores**: o seu código e o framework.
- **O tree shaking é o figurinista** que, antes de fechar o baú, tira as duas mil fantasias que a
  peça não usa e deixa as trinta que entram em cena.
- **O service worker é o depósito que você aluga na cidade.** Na primeira apresentação, tudo vem de
  caminhão. Da segunda em diante, está tudo a duas quadras do teatro — e a peça começa em segundos.
- **E o `--wasm`** é trocar o caminhão por um caminhão mais rápido: chega antes, mas só passa nas
  estradas novas.

A pergunta que o público faz nunca é "quantos quilos pesa o cenário". É **"quanto tempo até as
luzes acenderem"**. É por isso que a métrica da web é o primeiro carregamento.

---

## 🧪 Exemplo mínimo

Compile o Foco e leia o que o build diz.

```powershell
Set-Location C:\src\cursos\foco
flutter build web --release
```

```text
Compiling lib\main.dart for the Web...
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184
to 4324 bytes (99.7% reduction). Tree-shaking can be disabled by providing the
--no-tree-shake-icons flag when building your app.
√ Built build\web
```

Agora meça o que foi gerado:

```powershell
Get-ChildItem -Recurse .\build\web\ -File |
  Sort-Object Length -Descending |
  Select-Object -First 8 Name, @{n='MB';e={[math]::Round($_.Length/1MB,2)}}
```

```text
Name                       MB
----                       --
canvaskit.wasm           1,51
main.dart.js             1,83
canvaskit.js             0,08
flutter_service_worker.js 0,01
index.html               0,00
manifest.json            0,00
version.json             0,00
favicon.png              0,00
```

**Os dois primeiros são 99 % do peso.** Tudo o mais é irrelevante — e é por isso que otimizar um
PWA Flutter quase nunca passa por "minificar o HTML".

Compare com o mesmo app compilado com `--wasm`:

```powershell
flutter build web --release --wasm
```

```text
Name                       MB
----                       --
main.dart.wasm           2,64
skwasm.wasm              1,32
main.dart.mjs            0,12
```

> 📌 **Mais bytes, menos tempo de CPU.** O `.wasm` é maior no disco e mais rápido para o navegador
> executar, porque não precisa ser interpretado nem otimizado em runtime como o JavaScript. Qual
> vence depende da conexão e do aparelho do seu usuário — por isso se **mede**, não se adivinha.
> A [Aula 8](08-gerando-o-build-web.md) mostra como.

---

## 📱 Aplicando no Flutter

### Rodando nos modos

Os três modos de build do [Módulo 15, aula 1](../15-build-android/01-debug-profile-release.md)
existem na web, com uma diferença importante:

```powershell
flutter run -d chrome              # debug   — hot restart, DevTools, LENTO
flutter run -d chrome --profile    # profile — medição realista
flutter run -d chrome --release    # release — o que o usuário recebe
```

| | Debug (web) | Profile (web) | Release (web) |
|---|---|---|---|
| Compilador | `dartdevc` (incremental) | `dart2js` | `dart2js` |
| Hot reload | ⚠️ **Só hot restart** | ❌ | ❌ |
| Asserts | ✅ | ❌ | ❌ |
| Minificado | ❌ | ❌ | ✅ |
| Tamanho | Enorme | Grande | Otimizado |
| Serve para medir | ❌ **Nunca** | ✅ | ✅ |

> ⚠️ **Na web não existe hot reload, só hot restart.** Salvar um arquivo reinicia o app e o estado
> se perde. É a maior diferença de fluxo de trabalho em relação ao que você viveu do
> [Módulo 05, aula 8](../05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md) até aqui — e
> costuma ser a razão de as pessoas desenvolverem no emulador e só **validarem** no Chrome.

### O que o build aceita

```powershell
flutter build web --release `
  --base-href /foco/ `
  --dart-define-from-file=config/prod.json `
  --source-maps
```

| Flag | Para que serve | Aula |
|---|---|---|
| `--base-href` | Diz de onde carregar os arquivos quando o app não está na raiz | [8](08-gerando-o-build-web.md) |
| `--wasm` | Compila para WebAssembly | [8](08-gerando-o-build-web.md) |
| `--dart-define-from-file` | Configuração por ambiente, sem segredo | [8](08-gerando-o-build-web.md) |
| `--source-maps` | Permite decifrar stack traces de produção | [10](10-diagnostico-web.md) |
| `--no-tree-shake-icons` | Desliga a otimização de fontes | ⚠️ Raramente |
| `--pwa-strategy=none` | **Não** gera service worker | [6](06-service-worker-e-offline.md) |

> ⚠️ **`--obfuscate` e `--split-debug-info` não existem na web.** Eles são flags de compilação AOT
> nativa. Na web, o equivalente é a **minificação**, que o `dart2js` já faz em release — e que
> **não é segurança**: qualquer pessoa abre o DevTools e lê. A
> [Aula 8](08-gerando-o-build-web.md) trata do que isso significa para chaves e segredos.

---

## 💻 Código completo

Um script que compila e produz o relatório de peso que interessa — o do primeiro carregamento, não
o da pasta.

> **Arquivo:** `scripts/medir-web.ps1`
> **Como executar:** `.\scripts\medir-web.ps1` na raiz do projeto

```powershell
# Compila o app para a web e mede o que o usuário realmente baixa
# antes de ver o primeiro quadro.
#
# A pasta build/web inteira NÃO é a métrica: assets de imagem são
# baixados sob demanda. O que conta é o "caminho crítico".

param(
    [switch]$Wasm,          # compila com dart2wasm em vez de dart2js
    [string]$BaseHref = "/" # precisa terminar em barra
)

$ErrorActionPreference = "Stop"

# ══════════════════════════════════════════════════════════════
# 1. Portões de qualidade — antes de compilar, como sempre
# ══════════════════════════════════════════════════════════════
Write-Host "`n[1/4] Analisando..." -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) { throw "flutter analyze falhou. Corrija antes de medir." }

Write-Host "`n[2/4] Testando..." -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) { throw "flutter test falhou. Corrija antes de medir." }

# ══════════════════════════════════════════════════════════════
# 2. Build limpo
# ══════════════════════════════════════════════════════════════
Write-Host "`n[3/4] Compilando (base-href=$BaseHref, wasm=$Wasm)..." -ForegroundColor Cyan
flutter clean | Out-Null
flutter pub get | Out-Null

$argumentos = @("build", "web", "--release", "--base-href", $BaseHref)
if ($Wasm) { $argumentos += "--wasm" }

& flutter @argumentos
if ($LASTEXITCODE -ne 0) { throw "O build falhou." }

# ══════════════════════════════════════════════════════════════
# 3. O caminho crítico: o que é baixado antes do 1º quadro
# ══════════════════════════════════════════════════════════════
# Tudo que NÃO é asset sob demanda entra na conta. Imagens em
# assets/ ficam de fora porque só descem quando a tela que as
# usa aparece.
$raiz = ".\build\web"
$critico = Get-ChildItem -Recurse $raiz -File | Where-Object {
    $_.FullName -notmatch '\\assets\\(?!AssetManifest|FontManifest)' -and
    $_.Extension -notin @('.png', '.jpg', '.jpeg', '.webp', '.map')
}

$totalBytes = ($critico | Measure-Object -Property Length -Sum).Sum
$totalMB    = [math]::Round($totalBytes / 1MB, 2)

Write-Host "`n[4/4] Caminho crítico do primeiro carregamento:" -ForegroundColor Cyan
$critico |
    Sort-Object Length -Descending |
    Select-Object -First 10 `
        Name,
        @{n = 'MB'; e = { [math]::Round($_.Length / 1MB, 2) } },
        @{n = '% do total'; e = { [math]::Round(100 * $_.Length / $totalBytes, 1) } } |
    Format-Table -AutoSize

# ══════════════════════════════════════════════════════════════
# 4. O número que importa — e o alerta
# ══════════════════════════════════════════════════════════════
# A rede entrega comprimido. A regra prática do gzip para JS/WASM
# é ~35% do tamanho original; use como estimativa, não como medida.
$estimadoRede = [math]::Round($totalMB * 0.35, 2)

Write-Host "Sem compressão : $totalMB MB"
Write-Host "Estimado na rede (gzip ~35%): $estimadoRede MB" -ForegroundColor Green

if ($totalMB -gt 5) {
    Write-Warning "Acima de 5 MB sem compressão. Em 4G ruim isso passa de 10 s."
    Write-Warning "Confira: fontes extras no pubspec, ícones dinâmicos (tree shaking desligado),"
    Write-Warning "e pacotes grandes que entraram só por uma função."
}

# A medida de verdade é no navegador, com o cache desligado:
Write-Host "`nPara medir de VERDADE (não estimado):" -ForegroundColor Yellow
Write-Host "  1. flutter build web --release; depois sirva build/web"
Write-Host "  2. Chrome > F12 > Network > marque 'Disable cache'"
Write-Host "  3. Recarregue e leia 'transferred' na barra de baixo"
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `analyze` + `test` antes do build | Mesmo portão dos outros módulos: build de release nunca serve para descobrir bug. |
| `flutter clean` antes | O `build/web` antigo pode manter arquivos que não existem mais no novo. |
| Filtro do `$critico` | Separa o que desce **sempre** do que desce **sob demanda**; medir a pasta inteira infla o número. |
| Exclusão de `.map` | Source maps não são baixados pelo usuário — só pelo DevTools quando aberto. |
| `% do total` por arquivo | Mostra na hora que `main.dart.js` + `canvaskit.wasm` são ~99 %, encerrando a discussão sobre minificar HTML. |
| Estimativa de gzip em 35 % | Uma régua, não uma medida — por isso o script termina mandando medir no navegador. |
| Alerta acima de 5 MB | O ponto em que o primeiro carregamento passa a ser sentido em 4G ruim. |
| As três pistas do alerta | São as três causas reais de um bundle inchado, em ordem de frequência. |
| `-BaseHref` como parâmetro | Obriga a pensar no assunto **antes** do deploy, em vez de descobrir com a tela branca. |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| Compilação do seu código | `dart2js` ou `dart2wasm` | **AOT** para ARM nativo | **AOT** para ARM nativo |
| Engine gráfico | CanvasKit/skwasm (baixado) | `libflutter.so` (embutido) | `Flutter.framework` (embutido) |
| Métrica de tamanho | **1º carregamento** | Tamanho do download na Play | Tamanho na App Store |
| Piso do engine | ~1,5 MB (CanvasKit) | ~7 MB | ~8 MB |
| Hot reload | ❌ Só hot restart | ✅ | ✅ |
| Ofuscação | ❌ Não existe (só minificação) | ✅ `--obfuscate` | ✅ `--obfuscate` |
| Código legível por terceiros | ⚠️ **Sim**, com DevTools | ⚠️ Com esforço | ⚠️ Com esforço |
| Segunda abertura | **Instantânea** (service worker) | Instantânea | Instantânea |

> 💡 **O piso do engine na web é menor que no mobile** — 1,5 MB contra 7 MB — mas ele é baixado
> pela rede em vez de já estar no aparelho. Comparar os dois números diretamente leva à conclusão
> errada, do mesmo jeito que comparar `.aab` com `.apk`
> ([Módulo 15, aula 8](../15-build-android/08-gerando-apk-e-aab.md)).

🪟 **No Windows**, esta aula funciona por completo.

---

## ⚠️ Erros comuns

### 1. Medir o tamanho da pasta `build/web` inteira

Inclui assets sob demanda e source maps.

**Correção:** meça o caminho crítico, ou o "transferred" do DevTools.

### 2. Medir desempenho web em modo debug

O `dartdevc` gera código não otimizado; os números não significam nada.

**Correção:** `--profile` ou `--release`.

### 3. Esperar hot reload

Na web só existe hot restart.

**Correção:** desenvolva no emulador, valide no Chrome.

### 4. Editar arquivos em `build/web/`

São apagados no próximo build.

**Correção:** edite `web/`.

### 5. Achar que minificação é segurança

O `dart2js` minifica; o DevTools desminifica o suficiente.

**Correção:** nenhum segredo no cliente. [Aula 8](08-gerando-o-build-web.md).

### 6. Usar `--obfuscate` na web

A flag é de AOT nativo; não faz o que você espera.

**Correção:** não existe equivalente. Aceite e projete para isso.

### 7. Ícones dinâmicos desligando o tree shaking

`IconData(codigo, ...)` em runtime devolve 1,6 MB ao bundle.

**Correção:** use `Icons.algo` constante; se precisar de dinâmico, mapeie um `Map<String, IconData>`
com constantes.

### 8. Adotar `--wasm` sem medir

Mais bytes; o ganho depende do aparelho e da conexão.

**Correção:** meça as duas versões no público real.

### 9. Esperar que o Google indexe o conteúdo

O robô vê um `<canvas>`.

**Correção:** se SEO importa, o alvo não é Flutter web.

### 10. Ignorar `Semantics` na web

O leitor de tela encontra um canvas mudo.

**Correção:** [Módulo 13, aula 5](../13-desempenho-e-seguranca/05-acessibilidade.md) vale aqui igual.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter build web --release` no Foco. Leia a linha do tree shaking. Qual foi a
redução em porcentagem?

**Passo 2.** Liste os 8 maiores arquivos de `build/web/`. Quais dois somam a maior parte?

**Passo 3.** Abra `build/web/index.html`. Ele referencia `flutter_bootstrap.js`?

**Passo 4.** Abra `build/web/main.dart.js` e leia as primeiras linhas. Dá para entender alguma
coisa? É essa a "proteção" que a minificação oferece.

**Passo 5.** Procure no `main.dart.js` por uma string de texto do Foco (por exemplo o título de uma
tela). Ela está lá em texto puro?

**Passo 6.** Compile com `--wasm`. Compare os tamanhos com o build anterior.

**Passo 7.** Sirva `build/web` localmente e meça no DevTools (Network, "Disable cache") quantos
bytes descem antes do primeiro quadro. Compare com a estimativa do script.

**Passo 8.** Recarregue **sem** "Disable cache". Quantos bytes agora?

**Passo 9.** Rode `flutter build web --release --no-tree-shake-icons` e compare o tamanho do
`MaterialIcons-Regular.otf` nas duas versões.

**Passo 10.** Rode `flutter run -d chrome` (debug) e compare o tempo de carregamento com o release.
Por que a diferença é tão grande?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Fixação** (o que é CanvasKit), **Leitura de código** (o que o build imprime) e
**Aplicação** (script de medição).

---

## 🏆 Desafio opcional

Produza um **relatório de peso do Foco na web**, com decisão fundamentada sobre `--wasm`.

Requisitos:

- Compile as duas versões (`dart2js` e `--wasm`) e registre o caminho crítico de cada uma.
- Meça o "transferred" real no DevTools nas duas, com cache desligado.
- Meça o **tempo até o primeiro quadro** nas duas, usando a aba Performance, três execuções cada, e
  use a **mediana** (não a média — um outlier estraga a média).
- Repita a medição com *throttling* de rede em "Fast 4G" e em "Slow 4G".
- Monte uma tabela: versão × bytes × tempo mediano × conexão.
- Decida: qual você publicaria, e a partir de que condição trocaria.

Depois responda: em qual cenário de conexão a escolha se inverte? E o que isso diz sobre otimizar
com base no seu próprio Wi-Fi?

---

## 📌 Resumo

- O navegador não executa Dart: o Flutter compila para **JavaScript** (`dart2js`, padrão) ou
  **WebAssembly** (`dart2wasm`, com `--wasm`).
- O Flutter web **não gera HTML para a sua UI** — desenha tudo em um `<canvas>` com o **CanvasKit**,
  que é o Skia compilado para WASM.
- Isso dá **fidelidade visual total** entre os três alvos, e cobra: ~1,5 MB de engine baixado,
  SEO limitado e acessibilidade via árvore semântica.
- `build/web/` é **descartável** e recriado a cada build. Você edita `web/`.
- O **tree shaking** derruba o `MaterialIcons` de 1,6 MB para ~4 KB — e **ícones dinâmicos
  desligam essa otimização**.
- A métrica da web é o **primeiro carregamento**, não o tamanho da pasta. Num Foco típico:
  ~3,3 MB brutos, ~1,2 MB na rede, **~0,2 s na segunda visita**.
- `main.dart.js` + `canvaskit.wasm` são **~99 %** do peso crítico. Otimizar qualquer outra coisa é
  perda de tempo.
- Na web **não existe hot reload**, só hot restart — e **não existe `--obfuscate`**, só minificação,
  que **não é segurança**.
- Meça em `--profile` ou `--release`; **nunca** em debug.
- `--wasm` é mais bytes e menos CPU. Decida **medindo**, no aparelho e na conexão do seu público.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre `dart2js` e `dart2wasm` e o que cada um gera.
- [ ] Explico o que é o CanvasKit e por que ele existe.
- [ ] Digo três consequências de o Flutter desenhar em `<canvas>`.
- [ ] Listo o conteúdo de `build/web/` e o papel de cada arquivo.
- [ ] Sei quais arquivos eu edito e quais são gerados.
- [ ] Explico o tree shaking de ícones e o que o desliga.
- [ ] Meço o caminho crítico do primeiro carregamento, e não a pasta inteira.
- [ ] Sei por que a segunda visita é instantânea.
- [ ] Explico por que não existe `--obfuscate` na web e o que isso implica.
- [ ] Sei que na web não há hot reload e ajustei meu fluxo de trabalho a isso.
- [ ] Decido sobre `--wasm` com medição, não com preferência.

---

## 📚 Referências oficiais

- [Web renderers — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/renderers)
- [Compiling to WebAssembly — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/wasm)
- [Web app initialization — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/initialization)
- [Build and release a web app — docs.flutter.dev](https://docs.flutter.dev/deployment/web)
- [Measuring your app's size — docs.flutter.dev](https://docs.flutter.dev/perf/app-size)
- [CanvasKit — skia.org](https://skia.org/docs/user/modules/canvaskit/)
- [WebAssembly garbage collection — web.dev](https://web.dev/articles/wasmgc)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Por que PWA é o canal principal](01-por-que-pwa.md) | [README](README.md) | [O que não funciona na web](03-o-que-nao-funciona-na-web.md) |
