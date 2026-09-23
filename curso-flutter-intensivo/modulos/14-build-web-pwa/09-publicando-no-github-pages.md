# Aula 9 — Publicando no GitHub Pages

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 50 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Publicar o Foco em uma **URL pública com HTTPS**, de graça, a partir do Windows.
- Escrever um **workflow do GitHub Actions** que compila e publica a cada push na `main`.
- Entender as **permissões** que o deploy exige e por que elas são declaradas no YAML.
- Resolver o problema das **rotas profundas** em hospedagem estática — o `404.html` e as duas
  estratégias de URL do Flutter.
- Configurar um **domínio próprio** com HTTPS, sabendo o que isso custa em termos de dados dos
  usuários.
- Comparar GitHub Pages com **Firebase Hosting** e **Netlify**, e saber quando trocar.

## ✅ Pré-requisitos

- [Aula 8 — Gerando o build web](08-gerando-o-build-web.md) — o `--base-href` desta aula vem de lá.
- [Módulo 00 — Git e terminal](../00-git-e-terminal/README.md), especialmente
  [05 — Desfazendo erros e segredos](../00-git-e-terminal/05-desfazendo-erros-e-segredos.md).
- Uma **conta no GitHub** e o Foco em um repositório **público** (o Pages gratuito exige público).

---

## 📖 Conceito

### O que o GitHub Pages é

Um servidor de **arquivos estáticos** ligado ao seu repositório. Ele serve HTML, JS, WASM e imagens
por HTTPS, de graça, com CDN. Ele **não** executa código no servidor: não há PHP, não há Node, não
há rewrite de URL configurável.

Para um app Flutter web, isso é exatamente o suficiente — com uma exceção, que é a seção de rotas
mais adiante.

| | GitHub Pages |
|---|---|
| Custo | **R$ 0** |
| HTTPS | ✅ Automático, inclusive em domínio próprio |
| Limite de tamanho | 1 GB por site |
| Limite de banda | ~100 GB/mês |
| Repositório privado | ❌ Exige plano pago |
| Código no servidor | ❌ Nenhum |
| Cabeçalhos personalizados | ❌ Não configuráveis |

### As duas formas de URL

```text
Site de USUÁRIO                       Site de PROJETO
repositório: usuario.github.io        repositório: foco
URL: https://usuario.github.io/       URL: https://usuario.github.io/foco/
--base-href /                         --base-href /foco/     ⚠️
```

O segundo é o caso normal, e é o que exige o `--base-href` da
[Aula 8](08-gerando-o-build-web.md). **O nome do repositório vira o caminho.**

> ⚠️ **Escolha o nome do repositório com cuidado.** Ele entra na URL, a URL é a **origem**, e a
> origem é onde mora o banco IndexedDB do usuário ([Aula 4](04-banco-de-dados-na-web.md)). Renomear
> o repositório depois de ter usuários apaga os dados de todos eles. É a decisão irreversível deste
> módulo — o equivalente ao `applicationId` do Android.

### Rotas profundas: o problema do 404

O Flutter tem duas estratégias de URL:

| Estratégia | URL | Funciona em host estático? |
|---|---|---|
| **Hash** (padrão) | `usuario.github.io/foco/#/sessoes` | ✅ Sempre |
| **Caminho** (`usePathUrlStrategy`) | `usuario.github.io/foco/sessoes` | ⚠️ Precisa de truque |

Com a estratégia de caminho, a URL fica limpa — e quebra ao ser aberta diretamente:

```text
usuário cola https://usuario.github.io/foco/sessoes no navegador
        │
        ▼
GitHub Pages procura o ARQUIVO /foco/sessoes
        │
        ▼
não existe → 404
```

O Flutter nunca chega a rodar: quem deveria interpretar `/sessoes` é o `onGenerateRoute` do app, mas
o app não carregou.

**A solução em host estático** é um `404.html` que é **uma cópia do `index.html`**:

```text
usuário abre /foco/sessoes
        │
        ▼
arquivo não existe → Pages serve 404.html
        │
        ▼
404.html É o index.html → o Flutter carrega
        │
        ▼
o Flutter lê a URL atual e o onGenerateRoute abre a tela de sessões ✅
```

```powershell
Copy-Item build\web\index.html build\web\404.html
```

Uma linha no workflow. Sem ela, todo link compartilhado para uma tela interna dá 404 — e com ela, o
PWA ganha URLs que dá para colar em qualquer lugar.

> 💡 **Vale a pena?** Para o Foco, sim: os `shortcuts` do manifest
> ([Aula 5](05-manifest-e-icones.md)) apontam para rotas internas, e URL limpa é o que torna o link
> compartilhável. Se você preferir não mexer, a estratégia hash funciona sem nenhum truque — só
> ajuste os `shortcuts` para a forma `/foco/#/sessoes/nova`.

```dart
// lib/main.dart — para adotar a estratégia de caminho
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();   // no mobile, é um no-op
  // …
}
```

### O workflow, em três atos

```text
┌─ push na main
│
├─ ATO 1 — construir (ubuntu-latest)
│    checkout → instalar Flutter → pub get
│    → analyze → test → test --platform chrome
│    → build web --release --base-href /foco/ --no-web-resources-cdn
│    → cp index.html 404.html
│    → upload-pages-artifact
│
├─ ATO 2 — publicar
│    deploy-pages  →  https://usuario.github.io/foco/
│
└─ ~2 minutos no total
```

### As permissões

```yaml
permissions:
  contents: read      # ler o código
  pages: write        # publicar no Pages
  id-token: write     # provar ao Pages que este workflow é quem diz ser
```

> 📌 **`id-token: write` é o que mais gera dúvida.** O `deploy-pages` usa OIDC: em vez de você
> guardar um token de deploy como segredo, o GitHub emite um token de curta duração para **aquela
> execução**. É mais seguro do que qualquer segredo que você pudesse configurar — e é por isso que
> este deploy, ao contrário do da Play Store
> ([Módulo 17, aula 4](../17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md)), **não precisa
> de nenhum `secrets.`**.

---

## 💡 Analogia

Pense em **alugar uma vitrine numa galeria**.

- **O GitHub Pages é a galeria**: ela te dá o espaço, a energia e a segurança (o HTTPS), de graça. O
  que ela **não** faz é atender cliente — não há vendedor, não há estoque nos fundos, não há
  computador rodando lá dentro. Você deixa as peças prontas e elas ficam expostas. Para um app
  Flutter, que roda inteiro no navegador do visitante, isso basta.
- **O número da vitrine é o nome do repositório**, e ele está impresso no cartão de todo mundo que
  já visitou. Trocar de vitrine significa que ninguém mais acha você — e, pior, que o guarda-volumes
  da Aula 4 ficou na vitrine antiga.
- **O `404.html` é a plaquinha "entre por aqui"** em cada porta lateral. Sem ela, quem chega direto
  pela porta de trás encontra um corredor fechado, mesmo a loja estando aberta.
- **E o GitHub Actions é o montador** que, toda vez que você manda um projeto novo, monta a vitrine
  inteira sozinho, à noite, em dois minutos. Você nunca mais toca nas peças com a mão — e é isso que
  faz o deploy deixar de ser um evento e virar rotina.

---

## 🧪 Exemplo mínimo

Publicar pela primeira vez, do zero.

**1.** Suba o Foco para um repositório **público** chamado `foco`:

```powershell
git remote add origin https://github.com/SEU_USUARIO/foco.git
git push -u origin main
```

**2.** No GitHub: **Settings** → **Pages** → **Build and deployment** → **Source**:

```text
Source:  [ GitHub Actions ▾ ]      ← NÃO "Deploy from a branch"
```

> ⚠️ **Escolher "Deploy from a branch" é o erro de configuração mais comum.** Ele publica os
> arquivos do repositório como estão — ou seja, o seu código-fonte Dart, não o build. A pessoa abre
> a URL e vê o `README.md` renderizado.

**3.** Crie `.github/workflows/publicar-web.yml` (o conteúdo completo está adiante) e faça push.

**4.** Aba **Actions** do repositório:

```text
● Publicar PWA   #1   main   ✓ 1m 52s
  ├─ construir   ✓ 1m 38s
  └─ publicar    ✓ 14s
```

**5.** A URL aparece no resumo da execução e em Settings → Pages:

```text
🌐 Your site is live at https://SEU_USUARIO.github.io/foco/
```

**6.** Abra no celular. Instale. Coloque em modo avião. Abra pelo ícone.

Esse é o momento em que o curso entrega o que prometeu na
[Aula 1](01-por-que-pwa.md): o Foco na mão de alguém, sem loja, sem conta paga e sem Mac.

---

## 📱 Aplicando no Flutter

### Domínio próprio

```text
Settings → Pages → Custom domain → foco.com.br
                 → ✅ Enforce HTTPS
```

E no seu provedor de DNS:

| Tipo | Nome | Valor |
|---|---|---|
| `CNAME` | `www` | `SEU_USUARIO.github.io` |
| `A` (apex) | `@` | Os quatro IPs do GitHub Pages |

Com domínio próprio, o app passa a ficar na **raiz** — então o `--base-href` vira `/`, e o `scope` do
manifest também.

> ⚠️ **Migrar para domínio próprio troca a origem e apaga o banco de todos os usuários.**
> `usuario.github.io` e `foco.com.br` são origens diferentes ([Aula 4](04-banco-de-dados-na-web.md)).
> Se você pretende ter domínio próprio um dia, **comece com ele** — ou aceite que a migração exige
> exportar e reimportar dados, com aviso antecipado aos usuários. Não existe caminho indolor.

### Cache dos arquivos

O GitHub Pages define os cabeçalhos de cache sozinho e você não pode alterá-los. Na prática isso não
atrapalha, porque **o service worker está na frente** ([Aula 6](06-service-worker-e-offline.md)) e é
ele quem decide o que serve.

O que você precisa garantir é que o `flutter_service_worker.js` e o `index.html` não fiquem presos.
O Pages usa cache curto para HTML, e o Flutter versiona tudo por hash — a combinação funciona.

### Alternativas

| | GitHub Pages | Firebase Hosting | Netlify |
|---|---|---|---|
| Custo inicial | R$ 0 | R$ 0 (plano Spark) | R$ 0 |
| Raiz do domínio | ⚠️ Só com domínio próprio | ✅ Sempre | ✅ Sempre |
| `--base-href` necessário | ⚠️ Sim, em projeto | ❌ Não | ❌ Não |
| Rewrite de SPA | ⚠️ `404.html` | ✅ Configurável | ✅ Configurável |
| Cabeçalhos personalizados | ❌ | ✅ | ✅ |
| Rollback de versão | Republicar | ✅ **Um clique** | ✅ Um clique |
| Repositório privado | ❌ (gratuito) | ✅ | ✅ |
| Previews por PR | ❌ | ✅ | ✅ |
| Cartão de crédito | ❌ Nunca | ⚠️ Pode pedir | ⚠️ Pode pedir |

> 💡 **Quando trocar:** se você precisar de **rollback de um clique**, **preview por pull request**
> ou **repositório privado**, o Firebase Hosting é o próximo passo natural — e o `firebase deploy`
> cabe no mesmo workflow. Enquanto isso não for verdade, trocar é complicar de graça. O GitHub Pages
> serve o Foco inteiro sem custo e sem cartão.

---

## 💻 Código completo

> **Arquivo:** `.github/workflows/publicar-web.yml` (novo)
> **Como executar:** commite, faça push na `main` e acompanhe em Actions

```yaml
name: Publicar PWA

on:
  push:
    branches: [main]
  # Permite publicar manualmente pelo botão "Run workflow",
  # útil para republicar sem um commit novo.
  workflow_dispatch:

# Mínimo necessário. contents:read para ler o código; pages:write para
# publicar; id-token:write para o OIDC do deploy-pages — que dispensa
# guardar qualquer token como segredo.
permissions:
  contents: read
  pages: write
  id-token: write

# Uma publicação por vez. cancel-in-progress: false porque cancelar um
# deploy pela metade pode deixar o site em estado inconsistente — ao
# contrário de um build, que pode ser cancelado sem dano.
concurrency:
  group: pages
  cancel-in-progress: false

env:
  # ⚠️ Precisa ser igual ao "scope" de web/manifest.json e ao nome do
  # repositório. Mudar isto muda a ORIGEM e apaga o banco dos usuários.
  BASE_HREF: /foco/
  VERSAO_FLUTTER: '3.47.1'

jobs:
  construir:
    name: Construir
    runs-on: ubuntu-latest
    steps:
      - name: Baixar o código
        uses: actions/checkout@v4

      - name: Instalar o Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.VERSAO_FLUTTER }}
          channel: stable
          cache: true          # guarda o SDK entre execuções: ~2 min a menos

      - name: Baixar dependências
        run: flutter pub get

      # ── Portões de qualidade ──────────────────────────────────
      - name: Analisar
        run: flutter analyze

      - name: Testar (Dart VM)
        run: flutter test

      # ⭐ O portão que só existe por causa da web. Testes que passam
      # na Dart VM e falham aqui são exatamente os erros da Aula 3:
      # dart:io, Platform.isX, plugin sem implementação web.
      - name: Testar (Chrome)
        run: flutter test --platform chrome

      # ── Build ─────────────────────────────────────────────────
      - name: Compilar para web
        run: |
          flutter build web --release \
            --base-href "$BASE_HREF" \
            --no-web-resources-cdn \
            --source-maps

      # Sem isto, abrir /foco/sessoes direto devolve 404: o Pages não
      # tem rewrite. O 404.html é uma CÓPIA do index.html, então o
      # Flutter carrega e o onGenerateRoute resolve a rota.
      - name: Preparar rotas profundas
        run: cp build/web/index.html build/web/404.html

      # Os .map reconstroem o código Dart original. Ficam disponíveis
      # para você decifrar stack traces (Aula 10), e FORA do site.
      - name: Separar os source maps
        run: |
          mkdir -p mapas
          find build/web -name '*.map' -exec mv {} mapas/ \;

      - name: Guardar os source maps
        uses: actions/upload-artifact@v4
        with:
          name: source-maps-${{ github.sha }}
          path: mapas/
          retention-days: 90

      # ── Conferências que impedem publicar artefato quebrado ───
      - name: Conferir o artefato
        run: |
          set -e
          grep -q "<base href=\"$BASE_HREF\"" build/web/index.html
          test -f build/web/flutter_service_worker.js
          test -f build/web/canvaskit/canvaskit.wasm
          test -f build/web/manifest.json
          test -f build/web/404.html
          # Sem estes dois, o app abre e o banco não (Aula 4).
          test -f build/web/sqlite3.wasm
          test -f build/web/sqflite_sw.js
          echo "Artefato completo."

      - name: Enviar o artefato
        uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

  publicar:
    name: Publicar
    needs: construir
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deploy.outputs.page_url }}
    steps:
      - name: Publicar no GitHub Pages
        id: deploy
        uses: actions/deploy-pages@v4
```

E a adoção da estratégia de caminho:

> **Arquivo:** `lib/main.dart` (alterado)

```dart
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // URL limpa: /foco/sessoes em vez de /foco/#/sessoes.
  // No Android e no iOS é um no-op — pode ficar sem condicional.
  // ⚠️ Exige o 404.html do workflow; sem ele, link direto dá 404.
  usePathUrlStrategy();

  final Database banco = await BancoFoco.abrir();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        bancoProvider.overrideWithValue(banco),
        preferenciasProvider.overrideWithValue(prefs),
      ],
      child: const AvisoDeAtualizacao(child: AppFoco()),
    ),
  );
}
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `workflow_dispatch` | Botão "Run workflow": republica sem precisar de commit novo. |
| `permissions` explícitas | Princípio do mínimo privilégio; o padrão do GitHub é mais amplo. |
| `id-token: write` | OIDC — token de curta duração por execução, em vez de segredo guardado. |
| `concurrency` com `cancel-in-progress: false` | Cancelar um deploy pela metade pode deixar o site inconsistente; um build, não. |
| `BASE_HREF` em `env` | Um lugar só. Ele aparece no build **e** na conferência. |
| `cache: true` no `flutter-action` | Economiza ~2 min por execução baixando o SDK. |
| `flutter test --platform chrome` | O portão que pega os erros da Aula 3. Sem ele, o CI dá falso verde. |
| `--no-web-resources-cdn` | O offline da Aula 6 depende disso. |
| `cp index.html 404.html` | O rewrite de SPA que o Pages não oferece. |
| `find … -name '*.map' -exec mv` | Tira os mapas do site e os guarda como artefato de 90 dias. |
| `grep -q "<base href=…"` | Falha o job se o `--base-href` não tiver sido aplicado — antes de publicar. |
| `test -f sqlite3.wasm` | Pega o caso em que os arquivos da Aula 4 não foram commitados. |
| `environment: github-pages` | Faz a URL publicada aparecer no resumo da execução e no repositório. |
| `usePathUrlStrategy()` sem `kIsWeb` | É um no-op no mobile; condicional aqui seria ruído. |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web (Pages) | 🤖 Google Play | 🍎 App Store |
|---|---|---|---|
| Tempo até o usuário | **~2 min** | Horas a dias | Dias |
| Revisão | ❌ | ⚠️ Automatizada | ⚠️ Humana |
| Segredos no CI | ❌ **Nenhum** | Keystore em base64 | Certificado + perfil |
| Runner | `ubuntu-latest` | `ubuntu-latest` | ⚠️ `macos-latest` (10× o custo) |
| Rollback | Republicar | Interromper rollout | Nova submissão |
| Custo do CI | Gratuito (público) | Gratuito | ⚠️ Minutos de macOS |

> 💡 **Compare a linha "segredos no CI" com o
> [Módulo 17, aula 4](../17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md).** Lá você vai
> guardar uma keystore em base64 num GitHub Secret e conviver com o risco de vazá-la. Aqui não há o
> que vazar: sem chave de assinatura, o pipeline de deploy não tem segredo nenhum. É uma vantagem
> real de segurança operacional do canal web, e ela raramente é mencionada.

🪟 **No Windows**, esta aula funciona por completo — o build roda no runner Linux do GitHub, e você
não precisa de nada além do `git push`.

---

## ⚠️ Erros comuns

### 1. Source em "Deploy from a branch"

Publica o código-fonte; a URL mostra o README.

**Correção:** Source = **GitHub Actions**.

### 2. Repositório privado no plano gratuito

O Pages não publica.

**Correção:** torne público, ou pague.

### 3. `--base-href` diferente do nome do repositório

Tela branca ([Aula 8](08-gerando-o-build-web.md)).

**Correção:** `/nome-do-repo/`.

### 4. Faltar `id-token: write`

```text
Error: Ensure GITHUB_TOKEN has permission "id-token: write"
```

**Correção:** as três permissões.

### 5. Sem `404.html` usando estratégia de caminho

Todo link direto para tela interna dá 404.

**Correção:** copie o `index.html`.

### 6. Adotar `usePathUrlStrategy` sem o `404.html`

Funciona navegando, quebra ao colar a URL.

**Correção:** os dois juntos, sempre.

### 7. Publicar os `.map`

Reconstroem o código Dart, em repositório público.

**Correção:** mova para artefato.

### 8. Renomear o repositório depois de ter usuários

Origem nova: banco vazio para todo mundo.

**Correção:** decida o nome antes.

### 9. Migrar para domínio próprio sem avisar

Mesmo efeito.

**Correção:** comece com o domínio, ou exporte/reimporte com aviso.

### 10. Esquecer `flutter test --platform chrome`

CI verde, app quebrado na web.

**Correção:** o terceiro portão.

### 11. Não conferir o artefato no CI

Publica sem `sqlite3.wasm`; o app abre e o banco não.

**Correção:** os `test -f` do workflow.

### 12. Achar que o deploy falhou porque a URL ainda mostra o antigo

É o service worker ([Aula 6](06-service-worker-e-offline.md)).

**Correção:** segunda abertura, ou Ctrl+Shift+R.

---

## 🛠️ Exercício guiado

**Passo 1.** Crie o repositório público `foco` e faça push da `main`.

**Passo 2.** Em Settings → Pages, marque Source = **GitHub Actions**.

**Passo 3.** Crie o workflow e faça push. Acompanhe em Actions.

**Passo 4.** Quanto tempo levou a primeira execução? E a segunda (com cache do SDK)?

**Passo 5.** Abra a URL publicada. O Foco carregou?

**Passo 6.** Abra `https://SEU_USUARIO.github.io/foco/sessoes` direto. Funciona? Se não, falta o
`404.html` ou o `usePathUrlStrategy`.

**Passo 7.** Abra a URL no **celular**. Instale pelo navegador.

**Passo 8.** Modo avião. Abra pelo ícone. O Foco abre e mostra as matérias?

**Passo 9.** Mude um texto, faça push, espere o deploy e recarregue **duas vezes** no celular. A
mudança apareceu na primeira ou na segunda?

**Passo 10.** Quebre de propósito: mude `BASE_HREF` para `/errado/` e faça push. O job falha na
conferência ou publica quebrado?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Aplicação** (o workflow), **Correção de bugs** (permissões faltando) e **Diagnóstico**
(404 em rota profunda).

---

## 🏆 Desafio opcional

Monte o **pipeline de publicação completo** do Foco, com qualidade e rastreabilidade.

Requisitos:

- O workflow desta aula, funcionando.
- Um job extra que rode **só em pull request**: analyze, test, test Chrome e build — **sem
  publicar**. Assim um PR quebrado nunca chega na `main`.
- Publicação apenas quando o commit tiver uma **tag** `v*`, além do push na `main` — e o número da
  versão do `pubspec.yaml` conferido contra a tag, falhando se divergirem.
- Uma tela "Sobre" no app mostrando versão, hash do commit e data do build, injetados por
  `--dart-define` no workflow.
- Um `CHANGELOG.md` atualizado a cada release, conforme o
  [Módulo 17, aula 3](../17-publicacao-e-proximos-passos/03-versionamento-e-releases.md).
- Um *badge* do status do workflow no `README.md` do repositório.
- Uma verificação automática do peso do caminho crítico, falhando acima de um limite que você
  definir.

Depois responda: o seu pipeline consegue responder, em 30 segundos, **qual commit está no ar agora**?
Se não consegue, o que falta — e por que isso importa mais na web, onde não existe `versionCode` nem
histórico de builds na loja?

---

## 📌 Resumo

- GitHub Pages serve **arquivos estáticos por HTTPS, de graça**, sem executar código no servidor.
  É o suficiente para Flutter web.
- Source precisa ser **GitHub Actions**, não "Deploy from a branch" — senão a URL mostra o código.
- Em site de projeto, **o nome do repositório vira o caminho** e exige `--base-href /nome/`.
- **O nome do repositório é a origem, e a origem é onde mora o banco.** Renomear depois apaga os
  dados de todos os usuários.
- Estratégia **hash** (padrão) funciona em qualquer host. Estratégia **de caminho** dá URL limpa e
  exige **`404.html` = cópia do `index.html`**.
- O workflow tem três portões: `analyze`, `test` e **`test --platform chrome`** — este último é o
  único que pega os erros da [Aula 3](03-o-que-nao-funciona-na-web.md).
- Permissões: `contents: read`, `pages: write`, **`id-token: write`** (OIDC). **Nenhum segredo** é
  necessário.
- Confira o artefato **no CI**: `base href`, service worker, CanvasKit, manifest, `404.html`,
  `sqlite3.wasm`, `sqflite_sw.js`.
- Guarde os `.map` como **artefato**, fora do site publicado.
- **Domínio próprio troca a origem** e apaga o banco. Comece com ele, ou planeje a migração.
- Alternativas valem quando você precisar de **rollback de um clique**, **preview por PR** ou
  **repositório privado** — aí, Firebase Hosting.
- Deploy inteiro: **~2 minutos**, sem revisão, sem conta paga, sem Mac.

---

## ☑️ Checklist de domínio

- [ ] Publiquei o Foco em uma URL pública com HTTPS.
- [ ] Sei por que Source precisa ser GitHub Actions.
- [ ] Relaciono nome do repositório, `--base-href`, `scope` e origem do banco.
- [ ] Explico as duas estratégias de URL e o truque do `404.html`.
- [ ] Sei o que cada uma das três permissões faz.
- [ ] Explico por que este deploy não precisa de segredos.
- [ ] Meu workflow roda os três portões, inclusive o de Chrome.
- [ ] Meu workflow confere o artefato antes de publicar.
- [ ] Arquivo os source maps fora do site.
- [ ] Sei o custo de migrar para domínio próprio.
- [ ] Instalei e usei o app publicado, offline, em um celular.
- [ ] Sei quando o GitHub Pages deixa de servir e o que usar depois.

---

## 📚 Referências oficiais

- [Deploying to GitHub Pages — docs.flutter.dev](https://docs.flutter.dev/deployment/web#deploying-to-the-web)
- [GitHub Pages documentation](https://docs.github.com/en/pages)
- [Publishing with a custom GitHub Actions workflow — docs.github.com](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
- [actions/deploy-pages — github.com](https://github.com/actions/deploy-pages)
- [subosito/flutter-action — github.com](https://github.com/subosito/flutter-action)
- [Configuring URL strategies — docs.flutter.dev](https://docs.flutter.dev/ui/navigation/url-strategies)
- [Firebase Hosting — firebase.google.com](https://firebase.google.com/docs/hosting)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Gerando o build web](08-gerando-o-build-web.md) | [README](README.md) | [Diagnóstico web](10-diagnostico-web.md) |
