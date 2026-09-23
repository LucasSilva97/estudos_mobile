# Etapa 9 — PWA e publicação — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 2 h · **Módulos exigidos:** [M14](../../modulos/14-build-web-pwa/README.md) ·
> **Entrega:** o Foco no ar, em URL pública, instalável e funcionando offline

Até a Etapa 8 o Foco era um app que roda na sua máquina e gera um artefato. Nesta etapa ele ganha
**um endereço** — e passa a existir para outras pessoas.

Esta é a etapa de **distribuição principal** do projeto. As etapas equivalentes de Android e iOS
vêm nos [módulos 15](../../modulos/15-build-android/README.md) e
[16](../../modulos/16-build-ios/README.md) e continuam obrigatórias, mas o canal que coloca o Foco
na mão de um colega hoje é este: sem loja, sem conta paga, sem Mac e sem revisão.

> 🪟 **Tudo nesta etapa roda no Windows 11**, do começo ao fim.

---

## 🎯 O que existe ao fim desta etapa

- O Foco rodando no Chrome com **banco funcionando** — matérias e sessões sobrevivendo a um F5.
- Um `web/manifest.json` com a identidade real do app e ícones **`maskable`**.
- Um **service worker** entendido, com aviso de "nova versão disponível".
- Um **workflow do GitHub Actions** publicando a cada push na `main`.
- O Foco **instalado na tela inicial de um celular**, abrindo sem barra de endereços.
- O Foco **funcionando em modo avião**: abrindo, listando matérias e gravando sessão nova.
- Um `docs/release-web-1.0.0.md` registrando o que foi publicado e como foi validado.

---

## 📦 Dependências

Acrescente ao que a Etapa 2 já instalou:

| Pacote | Onde | Para que serve |
|---|---|---|
| `sqflite_common: ^2.5.5` | `dependencies` | Os **tipos** (`Database`, `OpenDatabaseOptions`) comuns ao plugin nativo e à versão web |
| `sqflite_common_ffi_web: ^1.0.0` | `dependencies` | SQLite compilado para **WebAssembly**, persistido em IndexedDB |
| `web: ^1.1.1` | `dependencies` | Acesso tipado às APIs do navegador (`Blob`, service worker, storage) |

```powershell
Set-Location C:\src\cursos\foco
flutter pub add sqflite_common sqflite_common_ffi_web web
dart run sqflite_common_ffi_web:setup
```

O `setup` grava dois arquivos em `web/`:

```text
web/sqlite3.wasm     (~1,3 MB)  ← o motor SQLite
web/sqflite_sw.js    (~13 KB)   ← o worker que tira o SQL da thread da UI
```

> 🔴 **Commite os dois.** Diferente de `build/`, a pasta `web/` é versionada, e o deploy compila a
> partir do repositório. Sem eles no Git, o app publicado abre e **o banco não** — uma falha que
> funciona perfeitamente na sua máquina.

```powershell
git add web/sqlite3.wasm web/sqflite_sw.js
```

---

## 🧩 Os arquivos desta etapa

| Arquivo | Novo? | O que muda |
|---|---|---|
| `lib/core/banco/factory_banco.dart` | ✅ | As condições de importação |
| `lib/core/banco/factory_banco_stub.dart` | ✅ | Contrato, com falha legível |
| `lib/core/banco/factory_banco_io.dart` | ✅ | 🤖🍎 O plugin `sqflite` de sempre |
| `lib/core/banco/factory_banco_web.dart` | ✅ | 🌐 SQLite em WASM |
| `lib/core/banco/banco_foco.dart` | ⚠️ Alterado | Abre pela factory |
| `lib/features/*/data/*_dao.dart` | ⚠️ Uma linha cada | Só o `import` do tipo `Database` |
| `lib/core/atualizacao/*` | ✅ | Aviso de versão nova |
| `lib/main.dart` | ⚠️ Alterado | `usePathUrlStrategy()` e `AvisoDeAtualizacao` |
| `web/manifest.json` | ⚠️ Alterado | A identidade real |
| `web/index.html` | ⚠️ Alterado | Meta tags do iOS |
| `pubspec.yaml` | ⚠️ Alterado | Três pacotes e o bloco `web:` dos geradores |
| `.github/workflows/publicar-web.yml` | ✅ | O deploy |
| `domain/` e `presentation/` | ❌ **Nada** | É o teste da arquitetura |

> 📌 **A última linha é o critério de aceite mais importante desta etapa.** A
> [ADR-05](02-arquitetura.md) prometeu que trocar `sqflite` mexeria em uma pasta. Se o seu
> `git diff --stat` tocar em `domain/` ou `presentation/`, a camada de dados estava vazando — e o
> problema é anterior a esta etapa.

---

### lib/core/banco/factory_banco.dart

> **Por que ele existe:** `sqflite` importa plugin nativo que não existe na web;
> `sqflite_common_ffi_web` importa bibliotecas que não existem no mobile. Os dois no mesmo arquivo
> quebrariam os dois builds. A escolha precisa acontecer em tempo de **compilação**.

```dart
export 'factory_banco_stub.dart'
    if (dart.library.io) 'factory_banco_io.dart'
    if (dart.library.js_interop) 'factory_banco_web.dart';
```

### lib/core/banco/factory_banco_web.dart

```dart
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// 🌐 SQLite em WebAssembly, persistido em IndexedDB, por origem.
///
/// databaseFactoryFfiWeb usa o worker de sqflite_sw.js. Existe
/// databaseFactoryFfiWebNoWebWorker para depurar — nunca em produção:
/// sem o worker, uma consulta pesada trava a animação.
DatabaseFactory get fabricaDoBanco => databaseFactoryFfiWeb;

/// Na web não existe pasta. O "caminho" é uma chave no IndexedDB.
Future<String> caminhoDoBanco(String nomeDoArquivo) async => nomeDoArquivo;
```

### lib/core/banco/banco_foco.dart

```dart
import 'package:sqflite_common/sqlite_api.dart';

import 'factory_banco.dart';

class BancoFoco {
  const BancoFoco._();

  /// Inalterado. As três migrações da Etapa 2 valem igual na web:
  /// o SQLite é o mesmo, só o meio de gravação mudou.
  static const int versaoAtual = 3;
  static const String nomeDoArquivo = 'foco.db';

  static Future<Database> abrir() async {
    final String caminho = await caminhoDoBanco(nomeDoArquivo);

    // ⭐ A única mudança real da Etapa 2 para cá: em vez do
    // openDatabase() de nível superior (que fala com o plugin nativo
    // e não existe na web), pedimos à FACTORY. As opções são as
    // mesmas, só mudaram de lugar.
    return fabricaDoBanco.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versaoAtual,
        onConfigure: configurar,
        onCreate: criar,
        onUpgrade: atualizar,
      ),
    );
  }

  /// ⚠️ Continua obrigatório: o SQLite nasce com chave estrangeira
  /// DESLIGADA em qualquer plataforma. Sem isto, o ON DELETE CASCADE
  /// não acontece e sobram sessões órfãs, sem erro nenhum.
  static Future<void> configurar(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // criar() e atualizar() ficam EXATAMENTE como estavam.
}
```

### lib/features/materias/data/materia_dao.dart (e `sessao_dao.dart`)

```dart
// ANTES: import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

// Nada mais muda. `Database`, `Transaction` e `ConflictAlgorithm`
// sempre moraram em sqflite_common — o pacote sqflite só os reexportava.
```

### pubspec.yaml

```yaml
dependencies:
  # …o que já existia…
  sqflite: ^2.4.4
  sqflite_common: ^2.5.5
  sqflite_common_ffi_web: ^1.0.0
  web: ^1.1.1

flutter_launcher_icons:
  # …o que a Etapa 8 configurou…
  web:
    generate: true
    image_path: "assets/icone/icone.png"
    background_color: "#3F51B5"
    theme_color: "#3F51B5"

flutter_native_splash:
  # …o que a Etapa 8 configurou…
  android: true
  ios: true
  web: true          # ⬅️ era false
```

```powershell
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

> ⚠️ **Rode os geradores ANTES de editar o `manifest.json`.** Eles reescrevem `icons`,
> `background_color` e `theme_color`; editar antes perde o trabalho.

### web/manifest.json

```json
{
  "id": "/foco/",
  "name": "Foco — Organizador de Estudos",
  "short_name": "Foco",
  "description": "Organize matérias, registre sessões de estudo e acompanhe sua meta semanal. Funciona offline.",

  "start_url": "/foco/",
  "scope": "/foco/",

  "display": "standalone",
  "orientation": "portrait-primary",

  "background_color": "#3F51B5",
  "theme_color": "#3F51B5",
  "lang": "pt-BR",
  "categories": ["education", "productivity"],
  "prefer_related_applications": false,

  "icons": [
    { "src": "icons/Icon-192.png",          "sizes": "192x192", "type": "image/png", "purpose": "any" },
    { "src": "icons/Icon-512.png",          "sizes": "512x512", "type": "image/png", "purpose": "any" },
    { "src": "icons/Icon-maskable-192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable" },
    { "src": "icons/Icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```

> 🔴 **`scope` e `start_url` precisam ser idênticos ao `--base-href` do build**, com barra no fim.
> Divergir não quebra o build nem o deploy — só faz aparecer uma **barra de navegador dentro do app
> instalado**, que é a coisa que ninguém testa antes de publicar.

### web/index.html — as quatro linhas do iOS

```html
<!-- 🍎 O Safari IGNORA boa parte do manifest. Sem estas linhas, o app
     instalado no iPhone fica com um PRINT DA PÁGINA como ícone. -->
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Foco">
<link rel="apple-touch-icon" href="icons/Icon-192.png">

<title>Foco — Organizador de Estudos</title>
```

> 🔴 **Não toque em `<base href="$FLUTTER_BASE_HREF">`.** O build procura essa string literal para
> substituir; trocá-la por `/` na mão faz o `--base-href` parar de funcionar.

### lib/main.dart

```dart
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // URL limpa: /foco/sessoes em vez de /foco/#/sessoes.
  // No Android e no iOS é um no-op.
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
      // Precisa de um ScaffoldMessenger acima; AppFoco o fornece.
      child: const AvisoDeAtualizacao(child: AppFoco()),
    ),
  );
}
```

### .github/workflows/publicar-web.yml

```yaml
name: Publicar PWA

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write        # OIDC — dispensa guardar qualquer segredo

concurrency:
  group: pages
  cancel-in-progress: false

env:
  # 🔴 Igual ao "scope" de web/manifest.json e ao nome do repositório.
  BASE_HREF: /foco/

jobs:
  construir:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
          channel: stable
          cache: true

      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

      # ⭐ O portão que só existe por causa da web: dart:io,
      # Platform.isX e plugins sem implementação web passam no
      # flutter test normal e falham aqui.
      - run: flutter test --platform chrome

      - run: >
          flutter build web --release
          --base-href "$BASE_HREF"
          --no-web-resources-cdn
          --source-maps

      # Sem isto, abrir /foco/sessoes direto devolve 404: o Pages
      # não tem rewrite. O 404.html é uma cópia do index.html.
      - run: cp build/web/index.html build/web/404.html

      - run: |
          set -e
          grep -q "<base href=\"$BASE_HREF\"" build/web/index.html
          test -f build/web/flutter_service_worker.js
          test -f build/web/canvaskit/canvaskit.wasm
          test -f build/web/sqlite3.wasm
          test -f build/web/sqflite_sw.js
          echo "Artefato completo."

      # Os .map reconstroem o código Dart original: ficam guardados
      # para decifrar stack traces, e FORA do site publicado.
      - run: |
          mkdir -p mapas
          find build/web -name '*.map' -exec mv {} mapas/ \;

      - uses: actions/upload-artifact@v4
        with:
          name: source-maps-${{ github.sha }}
          path: mapas/
          retention-days: 90

      - uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

  publicar:
    needs: construir
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deploy.outputs.page_url }}
    steps:
      - id: deploy
        uses: actions/deploy-pages@v4
```

---

## ▶️ Rodando

**1. Local, antes de qualquer coisa:**

```powershell
flutter pub get
flutter analyze
flutter test
flutter test --platform chrome
flutter run -d chrome
```

Crie uma matéria e uma sessão. Aperte **F5**. Elas continuam lá? Então o banco web está funcionando.

**2. Validando o build como um servidor real** — em **subpasta**, imitando o GitHub Pages:

```powershell
flutter build web --release --base-href /foco/ --no-web-resources-cdn
New-Item -ItemType Directory -Force -Path .\publicado\foco | Out-Null
Copy-Item -Recurse -Force .\build\web\* .\publicado\foco\
dart pub global activate dhttpd
dart pub global run dhttpd --path publicado --port 8080
```

Abra `http://localhost:8080/foco/` e recarregue com **Ctrl+Shift+R**.

> ⚠️ `flutter run -d chrome` serve o app na **raiz** e por isso **não reproduz** o problema de
> subpasta. Validar o deploy exige servir os arquivos como um servidor comum.

**3. Publicando:**

```powershell
git add .
git commit -m "Etapa 9: Foco como PWA"
git push
```

No GitHub: **Settings → Pages → Source = GitHub Actions**. Acompanhe em **Actions**.

```text
🌐 Your site is live at https://SEU_USUARIO.github.io/foco/
```

---

## ✅ Conferência

Marque cada item só depois de verificar.

### Banco

- [ ] `web/sqlite3.wasm` e `web/sqflite_sw.js` **commitados**.
- [ ] Matérias e sessões sobrevivem a um F5 no Chrome.
- [ ] `Application → IndexedDB` mostra `sqflite_databases`.
- [ ] 🔴 `git diff --stat` **não** lista `domain/` nem `presentation/`.

### Identidade

- [ ] `Application → Manifest` mostra "Foco — Organizador de Estudos", não `foco`.
- [ ] Ao menos um ícone marcado como **maskable**.
- [ ] `scope` idêntico ao `--base-href`.
- [ ] 🍎 As quatro meta tags `apple-*` no `index.html`.

### Publicação

- [ ] Execução verde na aba Actions, com `flutter test --platform chrome` entre os passos.
- [ ] A URL pública abre o Foco em outro aparelho.
- [ ] `https://…/foco/sessoes` direto funciona (404.html + `usePathUrlStrategy`).

### 🔴 O teste que fecha a etapa

- [ ] Abri a URL num celular que **nunca viu o app**.
- [ ] Instalei pelo navegador.
- [ ] O ícone é a arte do Foco e o nome embaixo dele é "Foco".
- [ ] Abre **sem barra de endereços**.
- [ ] Fechei o navegador por completo e ativei o **modo avião**.
- [ ] Abri **pelo ícone**: o Foco carregou.
- [ ] As matérias apareceram.
- [ ] Criei uma sessão nova, offline.
- [ ] Fechei e reabri, ainda offline: a sessão continua lá.

Checklist operacional completo: [checklists/build-web.md](../../checklists/build-web.md).

---

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| Tela branca, `404 main.dart.js` no Console | `--base-href` ausente ou errado | Rebuild com `/foco/`, e recarregue com **Ctrl+Shift+R** |
| Tela branca, exceção Dart no Console | `dart:io` ou `Platform.isX` em `lib/` | Troque por `Plataforma` ([M11](../../modulos/11-recursos-nativos/09-material-x-cupertino.md)) |
| Tela branca, Console **vazio** | Service worker com build quebrado | Ctrl+Shift+R, ou Unregister no DevTools |
| `Failed to load sqlite3.wasm` | `setup` não rodado, ou arquivos não commitados | `dart run sqflite_common_ffi_web:setup` + `git add` |
| O app abre e as matérias não | `sqlite3.wasm` faltou no artefato | Conferências do workflow |
| A URL mostra o `README.md` | Pages em "Deploy from a branch" | Source = **GitHub Actions** |
| Barra de navegador dentro do app instalado | `scope` ≠ `--base-href` | Alinhe os dois no manifest |
| Ícone com moldura branca no Android | Falta `maskable` | Quatro entradas em `icons` |
| 🍎 Ícone do iPhone é um print da página | Falta `apple-touch-icon` | As quatro meta tags |
| Não abre em modo avião | CanvasKit vindo de CDN | `--no-web-resources-cdn` |
| `https://…/foco/sessoes` dá 404 | Falta o `404.html` | `cp index.html 404.html` no workflow |
| A correção não aparece depois do push | Ciclo do service worker | Abra uma **segunda** vez |
| `Ensure GITHUB_TOKEN has permission "id-token: write"` | Permissões do workflow | As três de `permissions:` |
| Dados sumiram depois de publicar | **A URL mudou** | A origem é a identidade do banco |

Catálogo completo: [modulos/14-build-web-pwa/10-diagnostico-web.md](../../modulos/14-build-web-pwa/10-diagnostico-web.md)

---

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [10 — Etapa 8: Ícone, splash e versão](10-etapa-8-icone-splash-e-versao.md) | [README do projeto](README.md) | [12 — Critérios de aceite](12-criterios-de-aceite.md) |
