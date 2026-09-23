# 🌐 Checklist — Build Web de release (PWA)

> **O que é:** a lista completa para transformar o app **Foco** em um PWA publicado, instalável e
> capaz de funcionar offline — o **canal principal de distribuição** deste curso.
> **Quando usar:** no Dia 28 do plano intensivo, depois que o
> [checklist do projeto final](projeto-final.md) estiver todo marcado.
> **Módulo que ensina tudo isto:** [modulos/14-build-web-pwa/README.md](../modulos/14-build-web-pwa/README.md)
> **Onde você está:** 🪟 Windows 11. **Tudo nesta página roda no Windows, do começo ao fim, sem
> emulador, sem SDK nativo e sem cabo USB.** É o único checklist de build do curso do qual isso é
> verdade. (Os equivalentes nativos: [build-android.md](build-android.md) e
> [build-ios.md](build-ios.md).)

---

## Como usar

- Marque `- [x]` só depois de rodar a verificação.
- Faça na ordem: pré-build → build → deploy → pós-deploy. A ordem existe porque decidir a URL
  depois de ter usuários **apaga os dados de todos eles**, e publicar antes de conferir o
  `--base-href` produz uma tela branca sem mensagem de erro.
- Comandos em `powershell` → terminal do Windows, na raiz do projeto.

### Legenda

| Símbolo | Significa |
|---|---|
| 🔴 | Item crítico — errar aqui custa caro (ou é irreversível) |
| 🌐 | Específico da web |
| 🍎 | Específico do Safari/iOS |
| 🤫 | Falha **silenciosa** — nada avisa; só o usuário descobre |

### Termos explicados na primeira vez

- **PWA** (*Progressive Web App*) — um site que cumpre três requisitos (HTTPS, `manifest.json`
  válido e service worker com handler de `fetch`) e por isso ganha do navegador o direito de ser
  instalado na tela inicial, abrir sem barra de endereços e funcionar offline.
- **Service worker** — um script que roda **fora da página**, sobrevive ao fechamento da aba e
  intercepta **toda requisição** antes da rede. É ele que serve o app a partir do cache.
- **`manifest.json`** — a identidade do app na web: nome, ícones, cores, modo de exibição. Faz o
  papel do `applicationId` + `android:label` + `mipmap-*` juntos.
- **`--base-href`** — o caminho a partir do qual o `index.html` procura todos os outros arquivos.
  Errado, tudo dá 404 e a página fica **branca**.
- **`scope`** — até onde o app se considera "ele mesmo". Fora do escopo, o app instalado exibe uma
  barra de navegador.
- **IndexedDB** — o armazenamento do navegador onde o SQLite em WebAssembly grava o banco. É
  **por origem**: protocolo + domínio + caminho.
- **`maskable`** — ícone desenhado para ser recortado pela máscara do sistema sem perder conteúdo.
  Sem ele, o Android desenha uma moldura branca em volta.
- **CORS** (*Cross-Origin Resource Sharing*) — regra do navegador que esconde de você a resposta de
  uma API de outra origem, a menos que ela autorize por cabeçalho. **Não existe no mobile.**

---

## PARTE 1 — PRÉ-BUILD

### 1.1 🔴 A URL (irreversível depois de ter usuários)

A URL é a **identidade** do app na web e é onde mora o banco do usuário. Mudá-la equivale a trocar
o `applicationId` no Android — mas com um agravante: o banco local **não vai junto**.

- [ ] 🔴 Decidi o nome do repositório, sabendo que ele vira o caminho da URL
      (`usuario.github.io/NOME-DO-REPO/`).
- [ ] 🔴 Decidi se vou usar domínio próprio **agora** ou nunca. Migrar depois apaga os dados de
      todos os usuários.
- [ ] Anotei o `--base-href` definitivo: `/NOME-DO-REPO/` (ou `/` com domínio próprio).

```powershell
# O valor que você vai repetir em três lugares: build, manifest e workflow
$BaseHref = "/foco/"
```

### 1.2 🔴 Compatibilidade web do código

Estes erros **compilam, publicam e só quebram no usuário**.

- [ ] Nenhum `Platform.isX` fora da classe `Plataforma`.
- [ ] Nenhum `import 'dart:io'` em arquivo compilado para web.
- [ ] Nenhuma chamada a `path_provider` sem importação condicional.
- [ ] `flutter test --platform chrome` passando.

```powershell
Select-String -Path .\lib\*.dart -Pattern "dart:io|Platform\.is|getDatabasesPath" -Recurse
flutter test --platform chrome
```

> 🤫 `flutter test` sozinho roda na Dart VM e **dá falso verde** para toda esta seção.

### 1.3 🔴 Banco de dados na web

- [ ] `sqflite_common` e `sqflite_common_ffi_web` no `pubspec.yaml`.
- [ ] `dart run sqflite_common_ffi_web:setup` executado.
- [ ] 🤫 `web/sqlite3.wasm` e `web/sqflite_sw.js` **commitados** — sem isso funciona na sua máquina
      e quebra no deploy.
- [ ] DAOs importando `package:sqflite_common/sqlite_api.dart`, não `package:sqflite/sqflite.dart`.
- [ ] `BancoFoco.abrir()` usando `fabricaDoBanco.openDatabase(...)`.
- [ ] `git diff --stat` **não** lista arquivos de `domain/` nem de `presentation/`.

```powershell
dart run sqflite_common_ffi_web:setup
git add web/sqlite3.wasm web/sqflite_sw.js
git status --short web/
```

### 1.4 Identidade visual e manifest

- [ ] Bloco `web:` no `flutter_launcher_icons` e `web: true` no `flutter_native_splash`.
- [ ] Geradores rodados **antes** de editar o manifest (eles sobrescrevem parte dele).
- [ ] `name` preenchido (aparece no diálogo de instalação).
- [ ] `short_name` com até ~12 caracteres (aparece **embaixo do ícone**).
- [ ] `description` diferente de `"A new Flutter project."`.
- [ ] `id` declarado explicitamente.
- [ ] 🔴 `scope` e `start_url` **iguais** ao `--base-href`, com barra final.
- [ ] `display: "standalone"`.
- [ ] `background_color` igual à cor da splash (evita flash branco).
- [ ] `lang: "pt-BR"`.
- [ ] 🤫 Quatro ícones: `any` 192 e 512, **`maskable`** 192 e 512 — sem `maskable`, moldura branca
      no Android e ninguém percebe no desktop.
- [ ] Conteúdo do ícone dentro dos **80 % centrais**.

```powershell
dart run flutter_launcher_icons
dart run flutter_native_splash:create
# só agora editar web/manifest.json
```

### 1.5 🍎 O `index.html` para iOS

O Safari ignora boa parte do manifest. Sem estas linhas, o app instalado no iPhone fica com um
**print da página** como ícone.

- [ ] `<meta name="apple-mobile-web-app-capable" content="yes">`
- [ ] `<meta name="apple-mobile-web-app-status-bar-style" ...>`
- [ ] `<meta name="apple-mobile-web-app-title" content="Foco">`
- [ ] `<link rel="apple-touch-icon" href="icons/Icon-192.png">`
- [ ] `<title>` preenchido (não `foco`).
- [ ] `viewport-fit=cover` no viewport.
- [ ] 🔴 `<base href="$FLUTTER_BASE_HREF">` **literal** — substituir na mão quebra o `--base-href`.

### 1.6 Qualidade antes de compilar

- [ ] `flutter analyze` sem erros.
- [ ] `flutter test` passando.
- [ ] `flutter test --platform chrome` passando.
- [ ] `version:` do `pubspec.yaml` incrementado.

---

## PARTE 2 — BUILD

- [ ] `flutter clean` antes do build final.
- [ ] 🔴 `--base-href` com o valor da seção 1.1.
- [ ] 🔴 `--no-web-resources-cdn` — sem ele o CanvasKit vem de CDN, o service worker **não** o
      guarda, e o app instalado pode não abrir offline.
- [ ] `--source-maps` ligado.
- [ ] `--dart-define-from-file` sem **nenhum** segredo (tudo vai legível para o `main.dart.js`).

```powershell
flutter clean
flutter pub get
flutter build web --release `
  --base-href /foco/ `
  --no-web-resources-cdn `
  --source-maps
```

### 2.1 Conferência objetiva do artefato

Cada ausência aqui produz uma falha **diferente e silenciosa**.

- [ ] `<base href="/foco/">` no `build/web/index.html` → senão, **tela branca**
- [ ] `build/web/flutter_service_worker.js` → senão, **sem offline e sem instalação**
- [ ] `build/web/canvaskit/canvaskit.wasm` → senão, **não abre offline**
- [ ] `build/web/manifest.json` → senão, **sem instalação**
- [ ] 🤫 `build/web/sqlite3.wasm` → senão, **o app abre e o banco não**
- [ ] 🤫 `build/web/sqflite_sw.js` → idem
- [ ] `build/web/icons/Icon-512.png`

```powershell
Select-String -Path .\build\web\index.html -Pattern "<base href"
Test-Path .\build\web\flutter_service_worker.js, .\build\web\canvaskit\canvaskit.wasm, `
          .\build\web\manifest.json, .\build\web\sqlite3.wasm, .\build\web\sqflite_sw.js
```

### 2.2 Source maps fora do site

- [ ] 🔴 Os `.map` movidos para fora de `build/web/` e arquivados **por versão**.
- [ ] A pasta de mapas no `.gitignore`.

### 2.3 Peso do primeiro carregamento

- [ ] Caminho crítico medido (não a pasta inteira).
- [ ] Abaixo de 5 MB sem compressão, ou você sabe justificar.

---

## PARTE 3 — VALIDAÇÃO LOCAL (antes de publicar)

> Publicar para descobrir que quebrou é o pior ciclo de feedback possível.

- [ ] 🔴 Servi o build **de uma subpasta**, imitando o GitHub Pages — `flutter run -d chrome`
      serve na raiz e **não reproduz** o problema de `--base-href`.
- [ ] O app carrega, com Console limpo.
- [ ] `Application → Manifest → Installability` tudo verde.
- [ ] O ícone de instalar aparece na barra de endereços.
- [ ] Criei uma matéria, apertei F5, e ela continua lá.
- [ ] `Application → IndexedDB` mostra `sqflite_databases`.

```powershell
New-Item -ItemType Directory -Force -Path .\publicado\foco | Out-Null
Copy-Item -Recurse -Force .\build\web\* .\publicado\foco\
dart pub global run dhttpd --path publicado --port 8080
# abra http://localhost:8080/foco/ e recarregue com Ctrl+Shift+R
```

> ⚠️ **Ctrl+Shift+R, não F5.** O service worker de uma tentativa anterior serve o cache quebrado, e
> você conclui que a correção não funcionou.

---

## PARTE 4 — DEPLOY

- [ ] Repositório **público** (Pages gratuito exige).
- [ ] 🔴 `Settings → Pages → Source` = **GitHub Actions**, não "Deploy from a branch" — senão a URL
      mostra o `README.md` renderizado.
- [ ] Workflow com as três permissões: `contents: read`, `pages: write`, `id-token: write`.
- [ ] Os três portões no CI, incluindo `flutter test --platform chrome`.
- [ ] `cp build/web/index.html build/web/404.html` (rotas profundas).
- [ ] Conferências do artefato dentro do workflow, falhando o job se algo faltar.
- [ ] Source maps enviados como **artefato**, não publicados.
- [ ] Execução verde na aba Actions.
- [ ] Tag do Git marcando a versão publicada.

---

## PARTE 5 — PÓS-DEPLOY (validação no mundo real)

### 5.1 Verificação automática

- [ ] `.\scripts\verificar-deploy.ps1 -Url https://SEU_USUARIO.github.io/foco/` passando.
- [ ] Nenhum `.map` acessível na URL pública.

### 5.2 🔴 No celular — o teste que nada substitui

- [ ] Abri a URL num celular que **nunca viu o app**.
- [ ] Instalei pelo navegador.
- [ ] O ícone na tela inicial é a arte do Foco (🍎 não um print da página).
- [ ] O nome embaixo do ícone é o `short_name`, sem reticências.
- [ ] 🤫 Abre **sem barra de endereços** → senão, `scope` ≠ `--base-href`.
- [ ] Fechei o navegador por completo.
- [ ] **Modo avião.**
- [ ] Abri **pelo ícone**: o app carrega.
- [ ] As matérias aparecem.
- [ ] Criei uma sessão nova, offline.
- [ ] Fechei e reabri, ainda offline: a sessão continua lá.
- [ ] Nenhuma tela ficou sem saída (instalado **não há** botão voltar do navegador).
- [ ] Nada sob o *notch* (`SafeArea`).

### 5.3 Atualização

- [ ] Publiquei uma mudança visível e confirmei que ela aparece na **segunda** abertura.
- [ ] O aviso "nova versão disponível" aparece para quem já usava.
- [ ] O aviso **não** aparece em janela anônima na primeira visita.

### 5.4 Auditoria

- [ ] Lighthouse rodado; seção **PWA** e **Best practices** sem pendência acionável.
- [ ] Nota de Performance registrada (e **não** perseguida: ela pune o peso do CanvasKit).

---

## 🧪 Sequência completa de verificação (copie e rode)

```powershell
# 1. Compatibilidade
Select-String -Path .\lib\*.dart -Pattern "dart:io|Platform\.is" -Recurse
flutter analyze
flutter test
flutter test --platform chrome

# 2. Build
flutter clean; flutter pub get
flutter build web --release --base-href /foco/ --no-web-resources-cdn --source-maps

# 3. Artefato
Select-String -Path .\build\web\index.html -Pattern "<base href"
Test-Path .\build\web\sqlite3.wasm, .\build\web\flutter_service_worker.js

# 4. Local, em subpasta
New-Item -ItemType Directory -Force -Path .\publicado\foco | Out-Null
Copy-Item -Recurse -Force .\build\web\* .\publicado\foco\
dart pub global run dhttpd --path publicado --port 8080

# 5. Deploy
git add .; git commit -m "Release web 1.0.0"; git push

# 6. Pós-deploy
.\scripts\verificar-deploy.ps1 -Url https://SEU_USUARIO.github.io/foco/
```

### Tabela de saídas esperadas

| Comando | Saída que confirma |
|---|---|
| `Select-String "dart:io"` | **Nenhuma linha** em `lib/` |
| `flutter test --platform chrome` | `All tests passed!` |
| `Select-String "<base href"` | `<base href="/foco/">` |
| `Test-Path sqlite3.wasm` | `True` |
| Aba Actions | `✓` nos dois jobs |
| `verificar-deploy.ps1` | `Deploy íntegro.` |
| Modo avião, app instalado | O Foco abre e lista as matérias |

---

## Se algo falhar

| Mensagem / sintoma | Causa provável | Onde resolver |
|---|---|---|
| Tela branca + `404 main.dart.js` | `--base-href` ausente ou errado | Parte 2 · [Aula 08](../modulos/14-build-web-pwa/08-gerando-o-build-web.md) |
| Tela branca + exceção Dart no Console | `dart:io` / `Platform.isX` | Item 1.2 · [Aula 03](../modulos/14-build-web-pwa/03-o-que-nao-funciona-na-web.md) |
| Tela branca + Console **vazio** | Service worker com build quebrado | Ctrl+Shift+R · [Aula 06](../modulos/14-build-web-pwa/06-service-worker-e-offline.md) |
| A URL mostra o `README.md` | Pages em "Deploy from a branch" | Parte 4 |
| `Failed to load sqlite3.wasm` | `setup` não rodado ou arquivos não commitados | Item 1.3 |
| `MissingPluginException(... path_provider)` | Plugin sem web | Item 1.2 |
| `ClientException: Failed to fetch` | **CORS** | [Aula 03](../modulos/14-build-web-pwa/03-o-que-nao-funciona-na-web.md) |
| Barra de navegador dentro do app instalado | `scope` ≠ `--base-href` | Item 1.4 |
| Ícone com moldura branca no Android | Falta `maskable` | Item 1.4 |
| 🍎 Ícone do iPhone é um print da página | Falta `apple-touch-icon` | Item 1.5 |
| Botão de instalar não aparece | Um dos 8 critérios falhou | `Application → Manifest` · [Aula 07](../modulos/14-build-web-pwa/07-instalabilidade.md) |
| Não aparece ao abrir pelo IP da rede | `http://192.168…` não é origem segura | [Aula 07](../modulos/14-build-web-pwa/07-instalabilidade.md) |
| Não abre em modo avião | Falta `--no-web-resources-cdn` | Parte 2 |
| Link direto para tela interna dá 404 | Falta `404.html` | Parte 4 |
| Usuário preso na versão antiga | Ciclo do service worker | [Aula 06](../modulos/14-build-web-pwa/06-service-worker-e-offline.md) |
| `Error: Ensure GITHUB_TOKEN has permission "id-token: write"` | Permissões do workflow | Parte 4 |
| Dados sumiram depois de publicar | **A URL mudou** | Item 1.1 · [Aula 04](../modulos/14-build-web-pwa/04-banco-de-dados-na-web.md) |

Catálogo completo de erros: [referencias/erros-comuns.md](../referencias/erros-comuns.md)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [Checklist — Projeto final](projeto-final.md) | [Índice geral](../README.md) | [Checklist — Build Android](build-android.md) |
