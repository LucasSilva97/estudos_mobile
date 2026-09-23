# Aula 5 — Manifest e ícones

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Preencher o **`web/manifest.json`** campo a campo, sabendo o efeito visível de cada um.
- Explicar a diferença entre **`start_url`** e **`scope`**, e o que quebra quando o `scope` está
  errado.
- Escolher o **`display`** certo e entender `standalone`, `fullscreen`, `minimal-ui` e `browser`.
- Gerar ícones **`any`** e **`maskable`**, entender a **zona segura de 80 %** e por que sem
  `maskable` o ícone sai com moldura branca no Android.
- Ajustar o **`web/index.html`** para o iOS, que ignora parte do manifest.
- Usar o `flutter_launcher_icons` para gerar tudo a partir do **mesmo PNG 1024×1024** que já gerou o
  ícone Android na Etapa 8.
- Declarar **`shortcuts`** e **`screenshots`** para uma instalação mais rica.

## ✅ Pré-requisitos

- [Aula 4 — Banco de dados na web](04-banco-de-dados-na-web.md).
- [Etapa 8 do projeto final](../../projetos/03-projeto-final-multiplataforma/10-etapa-8-icone-splash-e-versao.md) —
  o `assets/icone/icone.png` de 1024×1024 e o bloco `flutter_launcher_icons:` já existem lá.
- [Módulo 15, aula 3 — Ícone](../15-build-android/03-icone.md) — a ideia de máscara adaptativa é a
  mesma do `maskable` da web.

---

## 📖 Conceito

### O `manifest.json` é a identidade do app

No Android, a identidade mora em três lugares: `applicationId` no Gradle, `android:label` no
manifest e o ícone em `res/mipmap-*`. Na web, mora em **um arquivo só**.

```text
web/manifest.json  ──►  o navegador lê  ──►  "este site pode ser instalado,
                                              e quando for, vai se chamar X,
                                              ter o ícone Y, abrir em Z"
```

Se esse arquivo estiver com os valores que o `flutter create` gerou, o seu app se instala com o nome
`foco` em minúsculo, ícone do Flutter e a cor azul do Flutter. Funciona — e parece um projeto de
exemplo.

### Campo a campo

```json
{
  "id": "/foco/",
  "name": "Foco — Organizador de Estudos",
  "short_name": "Foco",
  "description": "Organize matérias, registre sessões de estudo e acompanhe sua meta semanal.",
  "start_url": "/foco/",
  "scope": "/foco/",
  "display": "standalone",
  "display_override": ["window-controls-overlay", "standalone", "minimal-ui"],
  "orientation": "portrait-primary",
  "background_color": "#3F51B5",
  "theme_color": "#3F51B5",
  "lang": "pt-BR",
  "dir": "ltr",
  "categories": ["education", "productivity"],
  "prefer_related_applications": false,
  "icons": [ ... ],
  "shortcuts": [ ... ],
  "screenshots": [ ... ]
}
```

| Campo | Onde aparece para o usuário | Se estiver errado |
|---|---|---|
| **`id`** | Em lugar nenhum | O navegador usa `start_url` como identidade. Mudar `start_url` depois cria um **app novo** |
| **`name`** | Diálogo de instalação, lista de apps | Nome feio na instalação |
| **`short_name`** | **Embaixo do ícone**, na tela inicial | Texto cortado com reticências |
| **`description`** | Diálogo de instalação em alguns navegadores | "A new Flutter project." |
| **`start_url`** | A página que abre ao tocar no ícone | Abre a rota errada |
| **`scope`** | Invisível | Sair do escopo abre uma **barra de navegador** dentro do app |
| **`display`** | O "chrome" da janela | App com barra de endereços |
| **`background_color`** | A tela **antes** do app carregar | Flash branco na abertura |
| **`theme_color`** | Barra de status (Android), barra de título | Barra destoando do app |
| **`lang`** | Leitores de tela, formatação | Leitor de tela lendo em inglês |
| **`icons`** | Tudo | Ícone do Flutter, ou com moldura branca |

> 📌 **`short_name` é o campo mais visível e o mais esquecido.** É o que fica embaixo do ícone na
> tela inicial, e o espaço lá é de aproximadamente **12 caracteres**. "Foco" cabe.
> "Foco — Organizador" não.

> ⚠️ **`id` fixa a identidade.** Sem `id`, o navegador identifica o app pela `start_url`. Se você um
> dia mudar `start_url` de `/foco/` para `/foco/inicio`, os navegadores tratam como **outro app**:
> quem tinha instalado fica com o atalho antigo e uma segunda instalação aparece. Declarar `id`
> explicitamente congela isso.

### `start_url` × `scope`

Os dois mais confundidos.

```text
start_url  = ONDE abrir quando o usuário toca no ícone
scope      = ATÉ ONDE o app se considera "ele mesmo"
```

```text
scope: "/foco/"

https://usuario.github.io/foco/            ✅ dentro — sem barra de navegador
https://usuario.github.io/foco/sessoes     ✅ dentro
https://usuario.github.io/outro/           ❌ FORA — abre barra de navegador
https://docs.flutter.dev                   ❌ FORA — abre o navegador de verdade
```

Quando o usuário navega para fora do `scope`, o navegador entende que ele saiu do app e mostra uma
barra com a URL — a experiência "instalada" se desfaz. É o comportamento correto (você precisa ver
para onde foi), mas é péssimo se acontecer por engano dentro do seu próprio app.

> ⚠️ **No GitHub Pages de projeto, o app não fica na raiz.** A URL é
> `usuario.github.io/NOME-DO-REPO/`, então `scope` e `start_url` precisam apontar para
> `/NOME-DO-REPO/` — **com a barra no fim**. Esse é o mesmo assunto do `--base-href` da
> [Aula 8](08-gerando-o-build-web.md), e é a causa nº 1 de PWA que "quase" funciona.

### `display` — o quanto de navegador sobra

| Valor | O que o usuário vê | Quando usar |
|---|---|---|
| **`standalone`** | Sem barra de endereços, com barra de status do sistema | ✅ **O padrão certo para o Foco** |
| `fullscreen` | Nada além do app; some até a barra de status | Jogos, apresentações |
| `minimal-ui` | Barra mínima com voltar/recarregar | Quando navegar para fora é comum |
| `browser` | Aba normal | Desiste da experiência instalada |

```text
fullscreen        standalone         minimal-ui          browser
┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
│          │      │ 12:45 📶🔋│      │ ‹ › ↻    │      │🔒 site.com│
│          │      ├──────────┤      ├──────────┤      ├──────────┤
│   app    │      │   app    │      │   app    │      │   app    │
└──────────┘      └──────────┘      └──────────┘      └──────────┘
```

`display_override` é uma lista com prioridade, tentada antes do `display`. Ela existe para valores
mais novos que nem todo navegador entende — o `display` continua como rede de segurança.

### Ícones: `any` e `maskable`

Aqui está a parte com efeito visual mais dramático.

O Android **recorta** o ícone em uma forma que varia por fabricante: círculo, *squircle*, gota.
Um ícone marcado como `any` não pode ser recortado com segurança — então o sistema desenha um
**quadrado branco** atrás dele e encolhe o seu desenho dentro.

```text
purpose: "any"                    purpose: "maskable"
┌─────────────┐                   ┌─────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓ │                   │█████████████│
│ ▓┌───────┐▓ │  ← moldura        │███  FOCO  ██│  ← o fundo sangra
│ ▓│ FOCO  │▓ │     branca        │█████████████│     até a borda
│ ▓└───────┘▓ │                   │█████████████│
└─────────────┘                   └─────────────┘
   feio                              correto
```

Um ícone `maskable` precisa de **zona segura**: todo o conteúdo importante dentro de um círculo
central com **80 % do diâmetro**. O resto é fundo sacrificável.

```text
       512 px
  ┌───────────────┐
  │   ░░░░░░░░░   │  ← os 20% externos podem
  │ ░░┌───────┐░░ │     ser cortados
  │ ░░│ zona  │░░ │
  │ ░░│ segura│░░ │  ← 80% = 410 px
  │ ░░└───────┘░░ │
  │   ░░░░░░░░░   │
  └───────────────┘
```

> 💡 **O ícone do Foco já está pronto para isso.** A [Etapa 8](../../projetos/03-projeto-final-multiplataforma/10-etapa-8-icone-splash-e-versao.md)
> pediu o desenho nos **66 % centrais**, por causa da máscara adaptativa do Android. 66 % é mais
> conservador que os 80 % exigidos aqui — então o mesmo PNG serve, sem redesenhar.

Os tamanhos obrigatórios:

| Tamanho | `purpose` | Para quê |
|---|---|---|
| 192×192 | `any` | Mínimo para instalabilidade |
| 512×512 | `any` | Ícone grande, telas de abertura |
| 192×192 | `maskable` | Android, sem moldura branca |
| 512×512 | `maskable` | Android, alta densidade |

```json
"icons": [
  { "src": "icons/Icon-192.png",          "sizes": "192x192", "type": "image/png", "purpose": "any" },
  { "src": "icons/Icon-512.png",          "sizes": "512x512", "type": "image/png", "purpose": "any" },
  { "src": "icons/Icon-maskable-192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable" },
  { "src": "icons/Icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
]
```

> ⚠️ **Não use `"purpose": "any maskable"` no mesmo ícone.** É válido pelo padrão e quase sempre
> errado na prática: o navegador passa a usar a mesma imagem nos dois papéis, e uma arte pensada
> para `any` (que usa a borda toda) perde conteúdo ao ser recortada. Duas entradas, duas artes.

### O `index.html` e o iOS

O Safari no iPhone ignora boa parte do manifest e continua olhando **meta tags** antigas.

| Recurso | Android/Chrome | iOS/Safari |
|---|---|---|
| Ícone da tela inicial | `icons` do manifest | **`<link rel="apple-touch-icon">`** |
| Nome embaixo do ícone | `short_name` | `<meta name="apple-mobile-web-app-title">` |
| Abrir sem barra | `display: standalone` | `<meta name="apple-mobile-web-app-capable">` |
| Cor da barra de status | `theme_color` | `<meta name="apple-mobile-web-app-status-bar-style">` |

Ou seja: **sem as meta tags, o app instalado no iPhone sai com um print da página como ícone.**

---

## 💡 Analogia

Pense na fachada de uma loja.

- **O `name`** é o nome na nota fiscal: completo, formal, ninguém lê em voz alta.
- **O `short_name`** é o nome no toldo: precisa caber, precisa ser lido de longe. "Foco".
- **O `start_url`** é a porta pela qual o cliente entra. Você pode ter cinco portas; essa é a que o
  endereço do cartão indica.
- **O `scope`** é o terreno da loja. Enquanto o cliente anda dentro dele, está na sua loja. Um passo
  fora e ele está na rua — e a rua tem placa, poste e barulho. É exatamente o que a barra de
  navegador faz aparecer.
- **O `background_color`** é a cor da parede atrás da vitrine, enquanto os produtos ainda estão
  sendo arrumados. Se ela for branca e a loja for azul, o cliente vê um **flash** branco toda vez
  que abre a porta.
- **O ícone `any` é um quadro com moldura**; o **`maskable` é uma pintura em tela esticada**, que o
  moldureiro pode cortar no formato que quiser sem estragar o desenho. O Android é um moldureiro que
  nunca pergunta o formato antes de cortar.
- **E o iOS é o cliente que não lê o toldo**: ele olha só o cartão de visitas antigo que você
  deixou no balcão — as meta tags.

---

## 🧪 Exemplo mínimo

O antes e o depois, no mesmo diálogo de instalação.

**Antes** (o que o `flutter create` gerou):

```text
┌────────────────────────────────┐
│  Instalar aplicativo?          │
│                                │
│   [🦋]  foco                   │  ← minúsculo, ícone do Flutter
│         usuario.github.io      │
│                                │
│   A new Flutter project.       │  ← 😬
│                                │
│       [Cancelar]  [Instalar]   │
└────────────────────────────────┘
```

**Depois:**

```text
┌────────────────────────────────┐
│  Instalar aplicativo?          │
│                                │
│   [🎯]  Foco — Organizador     │
│         de Estudos             │
│         usuario.github.io      │
│                                │
│   Organize matérias, registre  │
│   sessões de estudo e acompa-  │
│   nhe sua meta semanal.        │
│                                │
│       [Cancelar]  [Instalar]   │
└────────────────────────────────┘
```

Os dois diálogos custam o mesmo esforço de build. O segundo custa **dez minutos de preenchimento de
JSON** — e é a primeira impressão que o usuário tem do seu app.

---

## 📱 Aplicando no Flutter

### Gerando os ícones com o que já existe

O `flutter_launcher_icons` da Etapa 8 já sabe gerar ícones de web. Basta acrescentar o bloco:

```yaml
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icone/icone.png"
  min_sdk_android: 24
  remove_alpha_ios: true
  adaptive_icon_background: "#3F51B5"
  adaptive_icon_foreground: "assets/icone/icone.png"

  # ⬇️ NOVO — a parte da web
  web:
    generate: true
    image_path: "assets/icone/icone.png"
    background_color: "#3F51B5"
    theme_color: "#3F51B5"
```

```powershell
dart run flutter_launcher_icons
```

```text
✓ Creating web icons Web
✓ Updating web/manifest.json
```

E a splash, que na Etapa 8 estava com `web: false`:

```yaml
flutter_native_splash:
  color: "#3F51B5"
  image: assets/icone/splash.png
  color_dark: "#121212"
  image_dark: assets/icone/splash.png
  android_12:
    color: "#3F51B5"
    image: assets/icone/splash.png
    icon_background_color: "#3F51B5"
    color_dark: "#121212"
    icon_background_color_dark: "#121212"
  android: true
  ios: true
  web: true        # ⬅️ era false
```

```powershell
dart run flutter_native_splash:create
```

> 💡 **A splash da web resolve um problema real:** entre o clique no ícone e o primeiro quadro do
> Flutter, existem os ~1,2 MB da [Aula 2](02-como-o-flutter-compila-para-web.md) sendo baixados. Sem
> splash, esse intervalo é uma **tela em branco**. Com ela, é a cor e o ícone do app.

> ⚠️ **O gerador reescreve o `manifest.json`.** Ele preenche ícones, `background_color` e
> `theme_color` — e deixa `name`, `short_name`, `description`, `scope`, `id` e `shortcuts` como
> estavam. Rode o gerador **primeiro** e edite o manifest **depois**, ou você perde as edições.

---

## 💻 Código completo

> **Arquivo:** `web/manifest.json` (substitui o gerado)
> **Como executar:** `flutter build web --release --base-href /foco/` e abrir no Chrome

```json
{
  "id": "/foco/",
  "name": "Foco — Organizador de Estudos",
  "short_name": "Foco",
  "description": "Organize matérias, registre sessões de estudo e acompanhe sua meta semanal. Funciona offline.",

  "start_url": "/foco/",
  "scope": "/foco/",

  "display": "standalone",
  "display_override": ["standalone", "minimal-ui"],
  "orientation": "portrait-primary",

  "background_color": "#3F51B5",
  "theme_color": "#3F51B5",

  "lang": "pt-BR",
  "dir": "ltr",
  "categories": ["education", "productivity"],
  "prefer_related_applications": false,

  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ],

  "shortcuts": [
    {
      "name": "Nova sessão de estudo",
      "short_name": "Nova sessão",
      "description": "Registra uma sessão agora",
      "url": "/foco/sessoes/nova",
      "icons": [{ "src": "icons/Icon-192.png", "sizes": "192x192" }]
    },
    {
      "name": "Minhas matérias",
      "short_name": "Matérias",
      "description": "Lista de matérias cadastradas",
      "url": "/foco/materias",
      "icons": [{ "src": "icons/Icon-192.png", "sizes": "192x192" }]
    }
  ],

  "screenshots": [
    {
      "src": "screenshots/inicio-mobile.png",
      "sizes": "1080x1920",
      "type": "image/png",
      "form_factor": "narrow",
      "label": "Tela inicial com a meta da semana"
    },
    {
      "src": "screenshots/inicio-desktop.png",
      "sizes": "1920x1080",
      "type": "image/png",
      "form_factor": "wide",
      "label": "Painel de estatísticas em tela larga"
    }
  ]
}
```

> **Arquivo:** `web/index.html` (alterado)

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <!-- ⚠️ base href é REESCRITO pelo --base-href do build. Deixe o marcador
       exatamente assim: o Flutter procura esta string literal para substituir. -->
  <base href="$FLUTTER_BASE_HREF">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">

  <!-- Aparece no resultado de busca e no compartilhamento do link. -->
  <meta name="description"
        content="Organize matérias, registre sessões de estudo e acompanhe sua meta semanal.">

  <!-- Pinta a barra de status no Android e a barra de título no desktop.
       DUAS entradas: o navegador escolhe pela media query. -->
  <meta name="theme-color" media="(prefers-color-scheme: light)" content="#3F51B5">
  <meta name="theme-color" media="(prefers-color-scheme: dark)"  content="#121212">

  <!-- ══════════════════════════════════════════════════════════
       🍎 iOS — o Safari IGNORA boa parte do manifest.
       Sem estas quatro linhas, o app instalado no iPhone fica com
       um PRINT DA PÁGINA como ícone e abre com barra de navegador.
       ══════════════════════════════════════════════════════════ -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
  <meta name="apple-mobile-web-app-title" content="Foco">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <link rel="icon" type="image/png" href="favicon.png"/>
  <link rel="manifest" href="manifest.json">

  <!-- ⚠️ O <title> é o nome da ABA e o padrão do atalho em alguns
       navegadores. Deixar "foco" aqui estraga o que o manifest arrumou. -->
  <title>Foco — Organizador de Estudos</title>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `"id": "/foco/"` | Congela a identidade. Sem ele, mudar `start_url` cria um app novo para o navegador. |
| `scope` e `start_url` com **barra final** | Sem a barra, `/foco` pode ser interpretado como arquivo, não pasta. |
| `display_override` antes de `display` | Lista com prioridade; `display` continua como rede de segurança. |
| `background_color` = cor da splash | É o que evita o flash branco antes do primeiro quadro. |
| `lang: pt-BR` | Leitores de tela usam para escolher a voz. Sem ele, lê português com fonética inglesa. |
| Quatro entradas de `icons` | Dois papéis (`any`, `maskable`) × dois tamanhos. Separados de propósito. |
| `shortcuts` | Menu ao pressionar e segurar o ícone. Barato de fazer, raro de ver. |
| As URLs dos `shortcuts` | Assumem a **estratégia de caminho**, adotada na [Aula 9](09-publicando-no-github-pages.md). Com a estratégia padrão (hash), seriam `/foco/#/sessoes/nova`. |
| `screenshots` com `form_factor` | Deixa o diálogo de instalação mais rico no Android; `narrow` e `wide` são atendidos conforme a tela. |
| `$FLUTTER_BASE_HREF` literal | O build procura **essa string exata** para substituir. Trocar por `/` manualmente quebra o `--base-href`. |
| `viewport-fit=cover` | Faz o app ocupar a área do *notch*; sem isso sobram faixas pretas no iPhone. |
| Dois `theme-color` com media query | Barra de status acompanhando o tema claro/escuro. |
| As quatro linhas `apple-*` | O Safari não lê o manifest para isso. Sem elas, ícone = print da página. |
| `<title>` preenchido | É o nome da aba e, em parte dos navegadores, o padrão do atalho. |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| Identidade | `id` / `start_url` | `applicationId` | *Bundle ID* |
| Nome exibido | `short_name` | `android:label` | `CFBundleDisplayName` |
| Ícone | `icons` do manifest | `res/mipmap-*` | `Assets.xcassets` |
| Máscara do sistema | `purpose: maskable` | Ícone adaptativo | ❌ Ícone quadrado, cantos pelo sistema |
| Splash | `background_color` + splash gerada | `flutter_native_splash` | `LaunchScreen.storyboard` |
| Cor da barra | `theme_color` | `statusBarColor` | `Info.plist` |
| Transparência no ícone | ✅ Permitida | ✅ | ❌ **Rejeitada pela Apple** |
| Fonte da verdade | **Um arquivo JSON** | Gradle + manifest + recursos | `Info.plist` + asset catalog |

> 💡 **A web é o alvo mais simples dos três para identidade** — um JSON e quatro meta tags, contra
> três lugares no Android e um catálogo de assets no iOS. E é o único em que você pode corrigir um
> nome errado em dois minutos, sem reenviar nada para loja nenhuma.

🪟 **No Windows**, esta aula funciona por completo.

---

## ⚠️ Erros comuns

### 1. Deixar o manifest gerado pelo `flutter create`

Nome minúsculo, ícone do Flutter, "A new Flutter project.".

**Correção:** preencha os campos.

### 2. `short_name` longo

Corta com reticências embaixo do ícone.

**Correção:** até ~12 caracteres.

### 3. `scope` sem a barra final

Comportamento ambíguo em subpasta.

**Correção:** `"/foco/"`.

### 4. `scope` na raiz com o app em subpasta

Barra de navegador aparecendo dentro do app.

**Correção:** `scope` = mesmo caminho do `--base-href`.

### 5. Sem ícone `maskable`

Moldura branca no Android.

**Correção:** duas entradas `maskable`, 192 e 512.

### 6. `"purpose": "any maskable"` na mesma arte

Uma das duas fica errada.

**Correção:** artes separadas.

### 7. Conteúdo do ícone fora da zona segura

Cortado pela máscara.

**Correção:** 80 % centrais; o Foco já usa 66 %.

### 8. `background_color` diferente da splash

Flash de cor na abertura.

**Correção:** mesma cor nos dois.

### 9. Esquecer as meta tags `apple-*`

Ícone do iPhone vira um print da página.

**Correção:** as quatro linhas do `index.html`.

### 10. Substituir `$FLUTTER_BASE_HREF` na mão

`--base-href` para de funcionar.

**Correção:** deixe o marcador literal.

### 11. Editar o manifest antes de rodar o gerador

O gerador sobrescreve parte do arquivo.

**Correção:** gere primeiro, edite depois.

### 12. Editar `build/web/manifest.json`

Some no próximo build.

**Correção:** edite `web/manifest.json`.

---

## 🛠️ Exercício guiado

**Passo 1.** Abra `web/manifest.json`. Quantos campos ainda têm valor genérico?

**Passo 2.** Acrescente o bloco `web:` ao `flutter_launcher_icons` e rode
`dart run flutter_launcher_icons`. Que arquivos apareceram em `web/icons/`?

**Passo 3.** Mude `web: false` para `web: true` no `flutter_native_splash` e rode o gerador.

**Passo 4.** Preencha `name`, `short_name`, `description`, `id`, `scope`, `start_url` e `lang`.

**Passo 5.** Compile e sirva `build/web`. Abra F12 → Application → **Manifest**. O painel mostra os
seus valores?

**Passo 6.** Nesse painel, procure a seção de ícones. O Chrome marca algum como `maskable`?

**Passo 7.** No mesmo painel, ative "Show only the minimum safe area for maskable icons". O desenho
do Foco cabe?

**Passo 8.** Instale o app. O nome embaixo do ícone é o `short_name`?

**Passo 9.** Pressione e segure o ícone instalado. Os `shortcuts` aparecem? Se abrirem em
branco, a estratégia de URL ainda é a de hash — a [Aula 9](09-publicando-no-github-pages.md)
resolve.

**Passo 10.** Remova `scope` do manifest, recompile e navegue para uma URL externa dentro do app.
O que muda? Depois recoloque.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Aplicação** (manifest completo), **Correção de bugs** (`scope` errado) e **Fixação**
(`any` × `maskable`).

---

## 🏆 Desafio opcional

Monte a **identidade completa do Foco na web**, no nível de um app publicado de verdade.

Requisitos:

- Manifest com **todos** os campos desta aula preenchidos, incluindo `categories` e `dir`.
- Quatro ícones (`any` e `maskable`, 192 e 512), com a arte `maskable` **redesenhada** para sangrar
  até a borda — não apenas a mesma imagem duplicada.
- Verifique a zona segura no painel do DevTools e anexe a captura.
- Três `shortcuts`, cada um apontando para uma rota que **existe** no `onGenerateRoute` do Foco.
  Teste cada uma abrindo a URL direto.
- Capturas de tela reais para `screenshots`, uma `narrow` e uma `wide`, nos tamanhos declarados.
- `index.html` com as quatro meta tags da Apple, dois `theme-color` e `viewport-fit=cover`.
- Instale no Android e no iPhone. Registre as duas telas iniciais lado a lado.

Depois responda: qual campo do manifest teve o **maior efeito visível** pelo menor esforço? E qual
deu mais trabalho para um ganho que só você percebe?

---

## 📌 Resumo

- O **`manifest.json`** é a identidade inteira do app na web — o equivalente a `applicationId`,
  `android:label` e `mipmap-*` juntos.
- **`short_name`** é o que aparece embaixo do ícone: até ~12 caracteres.
- **`id`** congela a identidade; sem ele, mudar `start_url` cria um app novo para o navegador.
- **`start_url`** é onde abrir; **`scope`** é até onde o app se considera ele mesmo. Fora do escopo,
  aparece **barra de navegador**.
- Em GitHub Pages de projeto, `scope` e `start_url` apontam para `/NOME-DO-REPO/`, **com barra
  final** — o mesmo valor do `--base-href`.
- **`display: standalone`** é o certo para o Foco.
- **`background_color`** igual à splash evita o **flash branco** na abertura.
- Ícone **`any`** ganha moldura branca no Android; **`maskable`** sangra até a borda. Use **artes
  separadas**, com o conteúdo nos **80 % centrais**.
- O **iOS ignora** parte do manifest: sem as quatro meta tags `apple-*`, o ícone da tela inicial
  vira um **print da página**.
- Mantenha `$FLUTTER_BASE_HREF` **literal** no `index.html`.
- Rode o **gerador primeiro**, edite o manifest **depois** — ele sobrescreve parte do arquivo.
- `shortcuts` e `screenshots` são baratos e quase ninguém faz.

---

## ☑️ Checklist de domínio

- [ ] Explico o efeito visível de cada campo do manifest.
- [ ] Diferencio `start_url` de `scope` e digo o que quebra em cada erro.
- [ ] Sei por que o `scope` precisa casar com o `--base-href`.
- [ ] Escolho o `display` certo e explico os quatro valores.
- [ ] Explico por que `any` ganha moldura branca e `maskable` não.
- [ ] Sei a regra da zona segura de 80 % e confiro no DevTools.
- [ ] Gero os ícones web com `flutter_launcher_icons` a partir do mesmo PNG.
- [ ] Ligo a splash web e sei que problema ela resolve.
- [ ] Sei as quatro meta tags que o iOS exige e o que acontece sem elas.
- [ ] Nunca substituo `$FLUTTER_BASE_HREF` manualmente.
- [ ] Declaro `shortcuts` que apontam para rotas reais.
- [ ] Confiro tudo em DevTools → Application → Manifest antes de publicar.

---

## 📚 Referências oficiais

- [Web app manifest — MDN](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Manifest)
- [Add a web app manifest — web.dev](https://web.dev/articles/add-manifest)
- [Adaptive icon support in PWAs with maskable icons — web.dev](https://web.dev/articles/maskable-icon)
- [App shortcuts — web.dev](https://web.dev/articles/app-shortcuts)
- [Richer install UI — web.dev](https://web.dev/articles/richer-install-ui)
- [Customizing web app initialization — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/initialization)
- [flutter_launcher_icons — pub.dev](https://pub.dev/packages/flutter_launcher_icons)
- [Configuring web apps — Safari HIG](https://developer.apple.com/documentation/webkit/configuring-your-web-application)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Banco de dados na web](04-banco-de-dados-na-web.md) | [README](README.md) | [Service worker e offline](06-service-worker-e-offline.md) |
