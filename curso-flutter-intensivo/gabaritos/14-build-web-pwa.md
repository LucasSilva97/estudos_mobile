# Gabarito — Módulo 14: Build e distribuição Web (PWA)

> Compare depois de resolver os [exercícios](../exercicios/14-build-web-pwa.md).

<a id="m14-e01"></a>
## M14-E01
Os três requisitos, e de onde cada um vem:

| Requisito | Quem entrega | Você faz algo? |
|---|---|---|
| **HTTPS** | A hospedagem (GitHub Pages) | ❌ Nada |
| **`manifest.json` válido** | `flutter create` cria o arquivo | ✅ **Preencher** |
| **Service worker com handler de `fetch`** | `flutter build web` gera | ❌ Nada (mas entender, sim) |

Painel `Application → Manifest → Installability` no Foco recém-criado:

```text
✅ Page has a manifest <link> URL
✅ Manifest has a name or short_name          ← "foco", tecnicamente válido
✅ Manifest has a display value of standalone
✅ Manifest contains suitable icons           ← os do Flutter
✅ Page is served from a secure origin        ← localhost conta
✅ Page has a service worker with a fetch handler
```

O critério: **tudo passa e o app fica feio**. Instalabilidade é um piso técnico, não um atestado de qualidade. O trabalho real da Aula 5 é a diferença entre "instalável" e "parece um app de verdade" — nome, descrição, cores e ícones maskable não afetam nenhum dos 8 critérios.

<a id="m14-e02"></a>
## M14-E02
```powershell
flutter build web --release
Get-ChildItem -Recurse .\build\web\ -File |
  Sort-Object Length -Descending |
  Select-Object -First 8 Name, @{n='MB';e={[math]::Round($_.Length/1MB,2)}}
```
| Arquivo | MB | Papel | Caminho crítico? |
|---|---:|---|---|
| `main.dart.js` | 1,83 | Seu código + framework, compilados | ✅ |
| `canvaskit.wasm` | 1,51 | Skia em WASM: o engine gráfico | ✅ |
| `canvaskit.js` | 0,08 | Carregador do CanvasKit | ✅ |
| `flutter_service_worker.js` | 0,01 | Cache e offline | ✅ |
| `index.html` | ~0 | A página | ✅ |
| `manifest.json` | ~0 | Identidade do PWA | ✅ |
| `MaterialIcons-Regular.otf` | ~0 | Fonte após tree shaking (4 KB) | ✅ |
| `Icon-512.png` | ~0 | Ícone de instalação | ❌ Sob demanda |

**Caminho crítico: ~3,4 MB** sem compressão, ~1,2 MB na rede com gzip. Assets de imagem e os `.map` ficam de fora: só descem quando a tela que os usa aparece, ou quando o DevTools é aberto.

Medir a pasta inteira infla o número porque soma o que o usuário **nunca** baixa numa sessão típica — e leva à conclusão errada de que é preciso otimizar imagens, quando 99 % do peso sentido está em dois arquivos que você não pode reduzir. É o mesmo erro de comparar o tamanho do `.aab` com o do `.apk` ([Módulo 15, aula 8](../modulos/15-build-android/08-gerando-apk-e-aab.md)).

<a id="m14-e03"></a>
## M14-E03
```dart
// ANTES — quebra na web, em tempo de execução
import 'dart:io';

IconData get _icone => Platform.isIOS ? Icons.chevron_right : Icons.arrow_forward;
```
```dart
// DEPOIS — funciona nos três alvos
import '../../../core/plataforma/plataforma.dart';

IconData _icone(BuildContext context) =>
    Plataforma.ehApple(context) ? Icons.chevron_right : Icons.arrow_forward;
```

**Por que o compilador não avisou:** o `dart2js` fornece uma versão de `dart:io` para a web em que as classes existem mas as operações lançam. O `import` resolve, a análise estática passa, o build termina em `√ Built build\web`. A falha só acontece quando a linha **executa** — ou seja, quando alguém abre aquela tela específica no navegador.

O critério: esse é o modelo de falha de todo o módulo. No Android, o que não funciona quebra o build; na web, quebra o usuário. `flutter test --platform chrome` é o único portão automatizado que move a descoberta de volta para antes do deploy.

<a id="m14-e04"></a>
## M14-E04
```yaml
dependencies:
  sqflite: ^2.4.4
  sqflite_common: ^2.5.5
  sqflite_common_ffi_web: ^1.0.0
```
```powershell
flutter pub get
dart run sqflite_common_ffi_web:setup     # grava web/sqlite3.wasm e web/sqflite_sw.js
git add web/sqlite3.wasm web/sqflite_sw.js
```
```dart
// lib/core/banco/factory_banco.dart
export 'factory_banco_stub.dart'
    if (dart.library.io) 'factory_banco_io.dart'
    if (dart.library.js_interop) 'factory_banco_web.dart';
```
```dart
// lib/core/banco/factory_banco_web.dart
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

DatabaseFactory get fabricaDoBanco => databaseFactoryFfiWeb;
Future<String> caminhoDoBanco(String nome) async => nome;   // não há pasta na web
```
```dart
// lib/core/banco/banco_foco.dart
static Future<Database> abrir() async {
  final String caminho = await caminhoDoBanco(nomeDoArquivo);
  return fabricaDoBanco.openDatabase(
    caminho,
    options: OpenDatabaseOptions(
      version: versaoAtual,
      onConfigure: configurar,   // PRAGMA foreign_keys = ON continua obrigatório
      onCreate: criar,
      onUpgrade: atualizar,
    ),
  );
}
```
E nos DAOs, só a linha do import:
```dart
// ANTES: import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
```

```powershell
git diff --stat
```
```text
 lib/core/banco/banco_foco.dart                    | 12 ++++-----
 lib/core/banco/factory_banco.dart                 |  4 +++
 lib/core/banco/factory_banco_io.dart              | 12 ++++++++
 lib/core/banco/factory_banco_stub.dart            | 10 +++++++
 lib/core/banco/factory_banco_web.dart             |  7 ++++++
 lib/features/materias/data/materia_dao.dart       |  2 +-
 lib/features/sessoes/data/sessao_dao.dart         |  2 +-
 pubspec.yaml                                      |  2 ++
```

O critério: **`domain/` e `presentation/` não aparecem no diff.** Isso é a [ADR-05](../projetos/03-projeto-final-multiplataforma/02-arquitetura.md) sendo cobrada e paga — "trocar `sqflite` mexe em uma pasta". Se o seu diff tocar em `domain/`, a camada de dados estava vazando para dentro do domínio, e o problema é anterior a este exercício.

Se `Failed to load sqlite3.wasm` aparecer, o `setup` não rodou ou os dois arquivos não foram commitados — este último funciona na sua máquina e quebra no deploy.

<a id="m14-e05"></a>
## M14-E05
```yaml
flutter_launcher_icons:
  # …o que já existia da Etapa 8…
  web:
    generate: true
    image_path: "assets/icone/icone.png"
    background_color: "#3F51B5"
    theme_color: "#3F51B5"

flutter_native_splash:
  # …
  web: true          # era false
```
```powershell
dart run flutter_launcher_icons
dart run flutter_native_splash:create
# só AGORA editar o manifest — os geradores sobrescrevem parte dele
```
```json
{
  "id": "/foco/",
  "name": "Foco — Organizador de Estudos",
  "short_name": "Foco",
  "description": "Organize matérias, registre sessões de estudo e acompanhe sua meta semanal.",
  "start_url": "/foco/",
  "scope": "/foco/",
  "display": "standalone",
  "background_color": "#3F51B5",
  "theme_color": "#3F51B5",
  "lang": "pt-BR",
  "icons": [
    { "src": "icons/Icon-192.png",          "sizes": "192x192", "type": "image/png", "purpose": "any" },
    { "src": "icons/Icon-512.png",          "sizes": "512x512", "type": "image/png", "purpose": "any" },
    { "src": "icons/Icon-maskable-192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable" },
    { "src": "icons/Icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```

A ordem importa: **gerar primeiro, editar depois**. O `flutter_launcher_icons` reescreve `icons`, `background_color` e `theme_color` do manifest; editar antes perde o trabalho.

O critério: `short_name` com 4 caracteres cabe embaixo do ícone; `name` completo aparece no diálogo de instalação. E o ícone do Foco passa na zona segura sem redesenho porque a [Etapa 8](../projetos/03-projeto-final-multiplataforma/10-etapa-8-icone-splash-e-versao.md) já pediu o desenho nos 66 % centrais — mais conservador que os 80 % exigidos aqui.

Erro comum: usar `"purpose": "any maskable"` numa arte só. É válido pelo padrão e produz um dos dois papéis errado — a arte `any` usa a borda toda e perde conteúdo ao ser recortada.

<a id="m14-e06"></a>
## M14-E06
A sequência observada:

```text
1ª recarga → texto ANTIGO
2ª recarga → texto NOVO
```

O que aconteceu, na ordem:

| Etapa | O que o service worker fez |
|---|---|
| `fetch` (1ª recarga) | Serviu `index.html` e `main.dart.js` **do cache** — por isso o texto antigo |
| Em paralelo | O navegador buscou `flutter_service_worker.js`, viu hashes diferentes no `RESOURCES` |
| `install` | Baixou o `CORE` novo para o cache temporário e chamou `skipWaiting()` |
| `activate` | Comparou os manifests, baixou o que mudou, apagou o obsoleto, chamou `clients.claim()` |
| `fetch` (2ª recarga) | Agora o cache tem a versão nova |

**Não é bug:** é a consequência direta de servir do cache para abrir instantâneo. O service worker entrega o que tem em mãos e atualiza depois. A alternativa — esperar a rede antes de renderizar — devolveria a lentidão que o cache existe para resolver.

`Update on reload` força a atualização a cada recarga. Ele é útil durante o desenvolvimento e **mascara** o comportamento real: com a caixa marcada, você nunca reproduz a reclamação do usuário. Desmarque antes de validar.

O critério: entender isso é pré-requisito do E10. Quem não reproduziu o problema não sabe o que o aviso de atualização está resolvendo.

<a id="m14-e07"></a>
## M14-E07
```text
GET https://usuario.github.io/main.dart.js  404 (Not Found)
                              ↑ falta /foco/
```

O `index.html` carregou (ele está na raiz da subpasta e foi encontrado), mas o `<base href="/">` fez o navegador procurar todo o resto a partir da raiz do domínio.

```powershell
flutter build web --release --base-href /foco/
```
```powershell
Select-String -Path .\build\web\index.html -Pattern "<base href"
# build\web\index.html:5:  <base href="/foco/">
```

**Por que não aparecia localmente:** `flutter run -d chrome` e um servidor apontado direto para `build/web` servem o app na **raiz** (`localhost:8080/`). Com `<base href="/">`, a raiz é o caminho certo — e o erro fica invisível. Ele só aparece quando o app passa a morar numa subpasta, que é exatamente o que o GitHub Pages de projeto faz.

**Por que Ctrl+Shift+R:** o service worker registrado na tentativa anterior cacheou o build quebrado. Um F5 passa pelo service worker e recebe o cache antigo — você conclui que a correção não funcionou. Ctrl+Shift+R ignora o service worker e busca da rede.

O critério: as três regras do `--base-href` — começa com `/`, termina com `/`, e é **igual ao `scope`** do manifest. A terceira não quebra o build nem o deploy: ela só se manifesta como uma barra de navegador aparecendo dentro do app instalado.

<a id="m14-e08"></a>
## M14-E08
`Settings → Pages → Source` precisa ser **GitHub Actions**. "Deploy from a branch" publica o repositório como está — a URL mostra o `README.md` renderizado, não o app.

```yaml
# .github/workflows/publicar-web.yml
name: Publicar PWA
on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write        # OIDC — é o que dispensa guardar qualquer segredo

concurrency:
  group: pages
  cancel-in-progress: false

env:
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
      - run: flutter test --platform chrome      # o portão que pega os erros da Aula 3
      - run: |
          flutter build web --release \
            --base-href "$BASE_HREF" \
            --no-web-resources-cdn \
            --source-maps
      - run: cp build/web/index.html build/web/404.html
      - run: |
          set -e
          grep -q "<base href=\"$BASE_HREF\"" build/web/index.html
          test -f build/web/flutter_service_worker.js
          test -f build/web/canvaskit/canvaskit.wasm
          test -f build/web/sqlite3.wasm
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

Sem `id-token: write`, o deploy falha com `Error: Ensure GITHUB_TOKEN has permission "id-token: write"`.

O critério: **o `--no-web-resources-cdn` não é opcional.** Sem ele o CanvasKit vem de `gstatic.com`, o service worker não cacheia recursos de outra origem, e o app instalado pode não abrir offline — quebrando justamente a promessa do módulo.

Tempo típico: ~2 min na primeira execução, ~1 min nas seguintes (cache do SDK).

<a id="m14-e09"></a>
## M14-E09
```dart
// exportador.dart
export 'exportador_stub.dart'
    if (dart.library.io) 'exportador_io.dart'
    if (dart.library.js_interop) 'exportador_web.dart';
```
```dart
// exportador_stub.dart — LANÇA, não é no-op
Future<void> exportarCsv(String nomeArquivo, String conteudo) {
  throw UnsupportedError(
    'exportarCsv não tem implementação para esta plataforma. '
    'Adicione um arquivo e a condição correspondente em exportador.dart.',
  );
}
```
```dart
// exportador_web.dart
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<void> exportarCsv(String nomeArquivo, String conteudo) async {
  final web.Blob blob = web.Blob(
    <JSAny>[conteudo.toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final String url = web.URL.createObjectURL(blob);
  final web.HTMLAnchorElement link =
      web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = nomeArquivo;
  link.click();
  web.URL.revokeObjectURL(url);   // sem isto, o Blob vaza até a aba fechar
}
```

Removendo a condição `if (dart.library.io)` e compilando para Android, o stub entra e o app lança `UnsupportedError` com a mensagem que **diz qual arquivo criar**. Um stub que fosse `Future.value()` silenciaria: o botão não faria nada, ninguém saberia por quê, e o bug chegaria ao usuário.

O critério: **nenhum `kIsWeb` no widget.** Quando a importação condicional resolve a escolha em tempo de compilação, a camada de UI não precisa saber onde está rodando. `kIsWeb` na UI é sinal de que a abstração ficou no nível errado.

<a id="m14-e10"></a>
## M14-E10
```dart
Stream<void> observarAtualizacao() {
  final StreamController<void> controlador = StreamController<void>.broadcast();
  final web.ServiceWorkerContainer? container = web.window.navigator.serviceWorker;
  if (container == null) return controlador.stream;

  // ⚠️ capturado ANTES de assinar
  final bool jaTinhaControlador = container.controller != null;

  container.addEventListener(
    'controllerchange',
    ((web.Event _) { if (jaTinhaControlador) controlador.add(null); }).toJS,
  );
  return controlador.stream;
}
```

**Por que `controllerchange` e não `updatefound`:** `updatefound` dispara quando o service worker novo **começa** a instalar. Avisar ali é cedo — se o usuário aceitar recarregar nesse instante, ele ainda recebe a versão antiga e precisa recarregar de novo. `controllerchange` dispara quando o novo **terminou e assumiu**; só a partir daí um reload entrega conteúdo novo.

**Por que a guarda:** na primeira visita, `controller` é `null` e o registro inicial do service worker dispara `controllerchange`. Sem a guarda, **todo usuário novo** vê "nova versão disponível" segundos depois de abrir o app pela primeira vez — o que é confuso e destrói a credibilidade do aviso.

E o SnackBar não recarrega sozinho: uma recarga automática descarta um formulário de sessão pela metade. A decisão é do usuário, e por isso a duração é longa e a ação é explícita.

<a id="m14-e11"></a>
## M14-E11
| Situação | Critério violado | Como confirmar | Correção |
|---|---|---|---|
| (a) `http://192.168.0.10:8080` | **Origem segura** | `Application → Manifest → Installability` acusa a origem | `localhost`, encaminhamento de porta do `chrome://inspect`, ou publicado |
| (b) `--pwa-strategy=none` | **Service worker com `fetch`** | `Application → Service workers` está vazio; o painel diz `Page does not work offline` | Rebuild sem a flag |
| (c) Tudo verde, nada aparece | **Não estar já instalado** | `matchMedia('(display-mode: standalone)').matches`, ou a lista de apps do sistema | Desinstale para testar de novo |

`localhost` é tratado como origem segura por definição, mas o IP da rede local **não** — e é justamente o jeito natural de abrir no celular, o que torna esse o diagnóstico mais frequente de todos.

O critério: o painel `Installability` responde (a) e (b) em um olhar. Só (c) exige olhar fora dele, porque o navegador não lista "já instalado" como falha — ele simplesmente para de oferecer.

<a id="m14-e12"></a>
## M14-E12
**(a)** No Android, o valor de um `--dart-define` vai para dentro do `libapp.so` compilado em AOT: extrair exige desempacotar o APK e vasculhar um binário — trabalhoso, mas possível. Na web, ele vai **literalmente** para dentro do `main.dart.js`, que é texto. Abrir o DevTools e usar Ctrl+F basta. Não é "menos seguro que no Android": é **zero**. A diferença prática é o custo do ataque, e na web esse custo é uma tecla.

**(b)**

| Valor | Pode? | Por quê |
|---|---|---|
| URL base de API pública | ✅ | Ela aparece em toda requisição na aba Network de qualquer jeito |
| Token de escrita | ❌ | Quem ler o `main.dart.js` escreve na sua API como você |
| Chave de mapa restrita por domínio | ✅ | É **projetada** para ser pública; o que protege é a restrição de referrer, não o sigilo |
| Senha de banco | ❌ | Nunca, em nenhuma plataforma — e na web o banco estaria exposto à internet |

**(c)** Nada muda no cliente: a chave vai para um **servidor intermediário** que eu controlo, e o Foco chama esse servidor. Ele guarda o segredo, chama o serviço, devolve só o que o app precisa — e de quebra resolve CORS, já que passa a ser mesma origem. Se eu não puder manter um servidor, a única alternativa honesta é não usar aquele serviço no cliente.

O critério: a regra "segredo mora no servidor" do [Módulo 13, aula 6](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md) deixa de ser boa prática e vira restrição absoluta. A resposta errada frequente é "uso ofuscação" — na web ela não existe, só minificação, e minificação não é segurança.

<a id="m14-e13"></a>
## M14-E13
| Tipo | Console | Network | Janela anônima |
|---|---|---|---|
| **1. Caminho** | `404 main.dart.js` | 404 nos arquivos | ❌ Quebra igual |
| **2. Código** | Exceção Dart (`Unsupported operation…`) | 200 em tudo | ❌ Quebra igual |
| **3. Cache** | **Vazio** | 200, com `(ServiceWorker)` na coluna Size | ✅ **Funciona** |

A janela anônima é o que separa o tipo 3 dos outros dois: sem service worker registrado, o cache quebrado não existe.

**Por que limpar o cache primeiro é o reflexo errado:** ele "resolve" temporariamente qualquer um dos três — a recarga forçada busca tudo da rede, então uma tela branca de caminho ou de código pode até aparecer corrigida se você tiver recompilado no meio. Você conclui que era cache, não aprende a causa, e o problema volta no próximo deploy. O Console custa dois segundos e responde antes.

O critério: o roteiro de quatro perguntas na ordem — Console, Network, service worker, anônima — elimina hipóteses em vez de testar correções. Trocar peça por peça acerta em algum momento e não ensina nada.

<a id="m14-e14"></a>
## M14-E14
A ordem de execução, que é a do README do módulo:

```text
1. kIsWeb e importações condicionais        (E03, E09)
2. banco web configurado e commitado         (E04)
3. manifest preenchido + ícones maskable     (E05)
4. service worker entendido + aviso          (E06, E10)
5. instalabilidade conferida                 (E11)
6. build com --base-href e --no-web-resources-cdn  (E07)
7. deploy por Actions                        (E08)
8. verificação pós-deploy                    (Aula 10)
```

O teste que fecha o módulo, e que nenhuma verificação automática substitui:

```text
□ Abrir a URL pública em um celular que nunca viu o app
□ Instalar pelo navegador
□ Fechar o navegador por completo
□ Ativar o modo avião
□ Abrir o Foco PELO ÍCONE
□ Confirmar: abre sem barra de endereços
□ Confirmar: as matérias aparecem
□ Criar uma sessão nova, offline
□ Fechar o app e reabrir, ainda offline
□ Confirmar: a sessão criada offline continua lá
```

Se o passo "abre sem barra de endereços" falhar, o `scope` não bate com o `--base-href`. Se "as matérias aparecem" falhar, faltou `sqlite3.wasm` no artefato. Se o app não abrir de jeito nenhum, faltou `--no-web-resources-cdn` e o CanvasKit está sendo procurado no `gstatic.com` — que o modo avião não alcança.

O critério: este é o momento em que o curso entrega o que prometeu na [Aula 1](../modulos/14-build-web-pwa/01-por-que-pwa.md). Não houve loja, não houve conta paga, não houve Mac, não houve revisão — e existe um app instalado, funcionando offline, na mão de alguém.

[Exercícios](../exercicios/14-build-web-pwa.md) · [Módulo](../modulos/14-build-web-pwa/README.md)
