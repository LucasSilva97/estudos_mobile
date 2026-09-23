# 🧯 Erros comuns — o texto literal e a correção

> **Para que serve esta página.** Quando algo quebrar, **procure aqui pelo texto exato do erro**
> (Ctrl+F). Cada entrada traz a mensagem como ela aparece, a causa, a correção e a aula que trata
> o assunto por inteiro.
>
> **Como procurar bem.** Copie um pedaço **estável** da mensagem — o nome da exceção, não o número
> da linha nem o caminho do seu arquivo. `RenderFlex overflowed` encontra; `RenderFlex overflowed
> by 84 pixels on the bottom` talvez não.
>
> **Ambiente deste curso:** Flutter 3.47.1 · Dart 3.13.1 · Windows 11.

**Páginas irmãs:** [Glossário](glossario.md) · [Comandos úteis](comandos-uteis.md) ·
[Diferenças Android × iOS](diferencas-android-ios.md) · [Referências oficiais](referencias-oficiais.md)

---

## 🗺️ Índice

[🪟 Ambiente e instalação](#-ambiente-e-instalação) ·
[🎯 Dart](#-dart) ·
[🧩 Widgets e layout](#-widgets-e-layout) ·
[🧭 Navegação e formulários](#-navegação-e-formulários) ·
[🔄 Estado e Riverpod](#-estado-e-riverpod) ·
[🌐 Rede](#-rede) ·
[🗄️ Banco de dados](#-banco-de-dados) ·
[🧪 Testes](#-testes) ·
[🌐 Build Web / PWA](#-build-web--pwa) ·
[🤖 Build Android](#-build-android) ·
[🍎 Build iOS](#-build-ios) ·
[📢 Publicação](#-publicação)

---

## 🪟 Ambiente e instalação

### `[☠] Flutter (the doctor check crashed)`

```text
[☠] Flutter (the doctor check crashed)
    ✗ Exception: Flutter failed to create a directory at ...
```

**Causa:** acento ou espaço no caminho do Flutter SDK. É o **Problema 1** deste curso — aconteceu
nesta máquina, porque o usuário do Windows chama `Usuário`.

**Correção:** mova o SDK para um caminho sem acento e sem espaço, como `C:\src\flutter`, e
atualize o `Path`. Detalhe completo em
[02-configuracao-do-ambiente.md § 1.2](../02-configuracao-do-ambiente.md#12--problema-1--acento-no-caminho-do-flutter-sdk).

---

### `Building with plugins requires symlink support`

```text
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

**Causa:** o Modo de Desenvolvedor do Windows está desligado. É o **Problema 2** do curso.

**Correção:** `start ms-settings:developers` e ligue o Modo de Desenvolvedor. Depois,
`flutter clean` e rode de novo.
→ [§ 1.3](../02-configuracao-do-ambiente.md#13--problema-2--modo-de-desenvolvedor-do-windows-desligado)

---

### `[X] Android toolchain - develop for Android devices`

```text
[X] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
```

**Causa:** Android SDK ausente ou não encontrado. É o **Problema 3** do curso.

**Correção:** instale pelo Android Studio (SDK Manager) e aponte com
`flutter config --android-sdk "C:\Users\<você>\AppData\Local\Android\Sdk"`.
→ [§ 1.4](../02-configuracao-do-ambiente.md#14--problema-3--android-sdk-ausente)

---

### `Android license status unknown`

```text
[!] Android toolchain
    ! Some Android licenses not accepted.
```

**Correção:** depende da idade do seu Android SDK.

- **SDK recente** (existe `cmdline-tools\latest\bin\android.exe`): não há comando de licença.
  Reinstale o componente pelo SDK Manager ou com `android sdk install "platforms;android-36"` —
  o aceite vem junto.
- **SDK antigo:** `flutter doctor --android-licenses` e aceite tudo com `y`.

Confirme com `flutter doctor -v`, procurando `All Android licenses accepted.`

---

### `The --licenses option is no longer needed`

```text
WARNING: The SDK Manager CLI tool (sdkmanager) is deprecated. Android CLI will be used instead.
Warning: The --licenses option is no longer needed.
```

**Causa:** não é um erro. O Google aposentou o `sdkmanager` e o substituiu pelo **Android CLI**
(`android`), onde o aceite de licenças deixou de ser um passo separado — ele acontece junto com
o `android sdk install`.

**Correção:** nenhuma. Rode `flutter doctor -v` e confirme a linha
`All Android licenses accepted.` → [§ 2.7](../02-configuracao-do-ambiente.md#27-aceitação-de-licenças)

---

### `'flutter' não é reconhecido como um comando interno`

**Causa:** o `Path` não tem a pasta `bin` do Flutter, ou o terminal foi aberto antes de você
acrescentá-la.

**Correção:** confira com `$env:Path -split ';' | Select-String flutter`. Se aparecer, **feche e
reabra o terminal** — variável de ambiente só vale para processo novo.

---

## 🎯 Dart

### `The argument type 'X?' can't be assigned to the parameter type 'X'`

**Causa:** você está passando um valor que pode ser nulo onde só cabe não-nulo.

**Correção:** trate o nulo em vez de calar o erro com `!`.

```dart
// ❌ compila e explode em execução
final int n = int.tryParse(texto)!;

// ✅
final int? n = int.tryParse(texto);
if (n == null) return;
```

→ [Módulo 02, aula 5](../modulos/02-dart-basico/05-null-safety.md)

---

### `Null check operator used on a null value`

**Causa:** um `!` que você garantiu, e não era verdade. O `!` é uma **afirmação sua**, não uma
verificação.

**Correção:** substitua por `if (x == null)`, `??` ou padrão de tipo.

---

### `type 'Null' is not a subtype of type 'Future<...>'`

**Causa:** mock do mocktail sem `when` para o método chamado — ele devolve `null`.

**Correção:** um `when` para cada método que o código usar, com `thenAnswer` para assíncrono.
→ [Módulo 12, aula 7](../modulos/12-testes-e-debug/07-mocks-e-fakes.md)

---

### `The type 'X' is not exhaustively matched by the switch cases`

**Causa:** `switch` sobre `sealed class` ou enum sem cobrir todos os casos.

**Correção:** acrescente o caso faltante. **Não** ponha `default:` — é justamente a exaustividade
que faz o compilador cobrar quando você acrescentar um subtipo novo.
→ [Módulo 04, aula 6](../modulos/04-dart-avancado/06-sealed-classes.md)

---

## 🧩 Widgets e layout

### `A RenderFlex overflowed by NN pixels`

```text
A RenderFlex overflowed by 84 pixels on the bottom.
```

**Causa:** o conteúdo é maior que o espaço. Em `Row`/`Column` sem flexibilidade.

**Correção, conforme o caso:**

| Situação | Solução |
|---|---|
| Texto longo numa `Row` | Envolva em `Expanded` ou `Flexible` |
| Coluna que não cabe na tela | Troque por `ListView` ou envolva em `SingleChildScrollView` |
| Some só com fonte grande | Altura fixa em algum lugar — use `minHeight` |

→ [Módulo 06, aula 4](../modulos/06-widgets-e-layouts/04-row-column-expanded.md)

---

### `Vertical viewport was given unbounded height`

**Causa:** `ListView` dentro de `Column` sem altura definida.

**Correção:** envolva o `ListView` em `Expanded`, ou use `shrinkWrap: true` (só com poucos itens).

---

### `No Material widget found`

```text
No Material widget found.
TextField widgets require a Material widget ancestor.
```

**Causa:** widget do Material sem `MaterialApp`/`Scaffold` acima. Aparece muito **em teste**.

**Correção:** `MaterialApp(home: ...)` em volta.
→ [Módulo 12, aula 6](../modulos/12-testes-e-debug/06-testes-de-widget.md)

---

### `setState() called after dispose()`

**Causa:** um `await` terminou depois de o widget sair da árvore.

**Correção:** verifique `mounted` depois de **todo** `await`.

```dart
await repositorio.salvar(x);
if (!mounted) return;      // ← esta linha
setState(() => _salvando = false);
```

---

### `setState() or markNeedsBuild() called during build`

**Causa:** mudar estado **durante** a construção — normalmente um `setState` chamado direto no
`build`, ou um provider alterado ali.

**Correção:** mova para um callback (`onPressed`, `initState`) ou
`WidgetsBinding.instance.addPostFrameCallback`.

---

## 🧭 Navegação e formulários

### `Navigator operation requested with a context that does not include a Navigator`

**Causa:** o `context` usado é de um widget **acima** do `Navigator` — em geral o do `build` que
criou o `MaterialApp`.

**Correção:** use o `context` de um `Builder` ou de um widget filho.

---

### `Looking up a deactivated widget's ancestor is unsafe`

**Causa:** uso de `context` depois de o widget ser removido — variação do `setState` após `dispose`.

**Correção:** guarde o que precisa **antes** do `await`.

```dart
final NavigatorState nav = Navigator.of(context);   // antes
await algo();
nav.pop();                                          // depois
```

---

### O `TextEditingController` não libera / `A Timer is still pending`

**Causa:** controller, `FocusNode`, `AnimationController` ou `Timer` sem `dispose`.

**Correção:** todo objeto criado no `initState` é descartado no `dispose`.

---

## 🔄 Estado e Riverpod

### `ProviderNotFoundException` / `No ProviderScope found`

**Causa:** falta o `ProviderScope` acima do `MaterialApp`.

**Correção:** `runApp(const ProviderScope(child: MeuApp()));`

---

### `Bad state: Cannot use "ref" after the widget was disposed`

**Causa:** `ref.read` dentro de um callback assíncrono que terminou tarde demais.

**Correção:** leia o notifier **antes** do `await`, ou verifique `context.mounted`.

---

### O widget não reconstrói quando o estado muda

**Causa:** uso de `ref.read` onde deveria ser `ref.watch`. O `read` lê uma vez e não observa.

**Correção:** `watch` no `build`; `read` em callbacks.
→ [Módulo 08, aula 5](../modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md)

---

## 🌐 Rede

### `SocketException: Failed host lookup`

**Causa:** sem internet, DNS fora, ou — no **emulador** — uso de `localhost`.

**Correção:** no emulador Android, a máquina host é `10.0.2.2`, não `localhost`.

---

### `HandshakeException: Handshake error in client`

**Causa:** certificado inválido, ou tentativa de HTTP onde só HTTPS é permitido.

**Correção:** use HTTPS. **Não** desligue a verificação de certificado nem
`NSAllowsArbitraryLoads`.
→ [Módulo 13, aula 6](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md)

---

### `FormatException: Unexpected character`

**Causa:** `jsonDecode` recebeu algo que não é JSON — muitas vezes uma página de erro HTML.

**Correção:** confira o `statusCode` **antes** de decodificar.

```dart
if (resposta.statusCode != 200) throw Falha('HTTP ${resposta.statusCode}');
final Object? dados = jsonDecode(resposta.body);
```

---

### `TimeoutException after 0:00:15.000000`

**Causa:** o servidor não respondeu no prazo. **Isto é o esperado** — significa que o seu
`.timeout` funcionou.

**Correção:** trate o caso, não aumente o prazo indefinidamente.
→ [Módulo 09, aula 6](../modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md)

---

## 🗄️ Banco de dados

### `DatabaseException: no such table`

**Causa:** o `onCreate` não roda em banco que já existe. Você acrescentou uma tabela sem subir a
versão.

**Correção:** suba `version` e trate no `onUpgrade`. Em desenvolvimento, desinstalar o app também
resolve — em produção, **nunca**.
→ [Módulo 10, aula 6](../modulos/10-persistencia-de-dados/06-migracoes.md)

---

### `DatabaseException: UNIQUE constraint failed`

**Causa:** tentativa de inserir um `id` que já existe.

**Correção:** `conflictAlgorithm: ConflictAlgorithm.replace`, ou verifique antes.

---

### `databaseFactory not initialized`

**Causa:** uso de `sqflite` em **teste** ou no desktop, onde não há plataforma móvel.

**Correção:**

```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});
```

---

### A ordenação ignora acento — `Ética` vem depois de `Física`

**Causa:** o SQLite compara **bytes**, não letras. `ORDER BY nome` coloca todo acentuado no fim.

**Correção:** guarde uma coluna `nome_ordenacao` com o texto achatado (sem acento, minúsculo) e
ordene por ela.
→ [Módulo 10, aula 4](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md)

---

## 🧪 Testes

### `A Timer is still pending even after the widget tree was disposed`

**Causa:** três possibilidades — `Timer` sem `cancel`, `Future.delayed` pendente ao fim do teste,
ou animação infinita.

**Correção:** **suspeite do seu código primeiro.** Esse erro costuma denunciar um vazamento real.
Se for um `Future` do próprio teste, deixe-o completar com `await tester.pump(duration)`.
→ [Módulo 12, aula 6](../modulos/12-testes-e-debug/06-testes-de-widget.md)

---

### `pumpAndSettle timed out`

**Causa:** algo nunca para de animar — um `CircularProgressIndicator` visível, por exemplo.

**Correção:** use `pump(duration)` com um valor específico em vez de `pumpAndSettle`.

---

### `Bad state: Too many elements`

**Causa:** o `finder` encontrou mais de um widget e o método esperava um só.

**Correção:** `find.byKey(...)`, ou `.first`.

---

### O teste falha dizendo que nada mudou depois do `tap`

**Causa:** faltou o `pump`. Sem ele, a árvore ainda é a de antes da interação.

**Correção:** `await tester.pump()` depois de **toda** interação.

---

### `registerFallbackValue was not previously called`

**Causa:** uso de `any()` do mocktail com um tipo seu.

**Correção:** `setUpAll(() => registerFallbackValue(MinhaClasseFalsa()));`

---

## 🌐 Build Web / PWA

### Tela branca, com `404` em `main.dart.js`

```text
GET https://usuario.github.io/main.dart.js  404 (Not Found)
GET https://usuario.github.io/flutter_bootstrap.js  404 (Not Found)
```

**Causa:** o `--base-href` está errado ou ausente. O `index.html` carregou, mas manda o
navegador procurar todo o resto na **raiz** do domínio, e o app mora numa subpasta. Repare que
falta `/foco/` no caminho dos 404.

**Correção:** `flutter build web --release --base-href /foco/` — começando **e** terminando com
barra — e recarregue com **Ctrl+Shift+R**, não F5: o service worker antigo serve o cache
quebrado e faz parecer que a correção não funcionou.
→ [14.08 — Gerando o build web](../modulos/14-build-web-pwa/08-gerando-o-build-web.md)

---

### Tela branca, com o Console **vazio**

**Causa:** não é caminho nem código — é **cache**. O service worker registrado numa tentativa
anterior está servindo um build quebrado. Na aba Network, a coluna *Size* mostra
`(ServiceWorker)` em vez do tamanho.

**Correção:** Ctrl+Shift+R, ou `Application → Service workers → Unregister`. Para confirmar o
diagnóstico antes de mexer em qualquer coisa: abra em **janela anônima** — se funcionar lá, é
cache.
→ [14.10 — Diagnóstico web](../modulos/14-build-web-pwa/10-diagnostico-web.md)

---

### `Unsupported operation: Platform._operatingSystem`

```text
Unsupported operation: Platform._operatingSystem
    at Object.wrapException (main.dart.js:1234)
```

**Causa:** `Platform.isAndroid`/`isIOS` na web. O `dart2js` fornece uma casca de `dart:io` em
que as operações lançam — então o código **compila**, publica, e só quebra quando a linha
executa, no navegador do usuário.

**Correção:** use `Plataforma.ehApple(context)`, baseada em `Theme.of(context).platform`.
E ponha `flutter test --platform chrome` no CI: é o único portão que pega isso antes do deploy.
→ [14.03 — O que não funciona na web](../modulos/14-build-web-pwa/03-o-que-nao-funciona-na-web.md)

---

### `MissingPluginException` na web

```text
MissingPluginException(No implementation found for method
getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
```

**Causa:** o plugin não tem implementação web. O nome do canal identifica qual é.

**Correção:** isole a chamada num arquivo `_io.dart` com importação condicional, ou confira o
selo `Web` do pacote no pub.dev antes de adotá-lo.
→ [14.03 — O que não funciona na web](../modulos/14-build-web-pwa/03-o-que-nao-funciona-na-web.md)

---

### `ClientException: Failed to fetch` (só no navegador)

```text
Access to XMLHttpRequest at 'https://api.exemplo/dados' from origin
'https://usuario.github.io' has been blocked by CORS policy
```

**Causa:** **CORS**. Regra do navegador, que não existe no Android nem no iOS — por isso o
mesmo código funciona no celular e falha no Chrome. Um `200` na aba Network **não** descarta:
o servidor respondeu e o navegador descartou a resposta.

**Correção:** o servidor precisa mandar `Access-Control-Allow-Origin`, ou você usa um proxy na
mesma origem. **Não existe** flag no `package:http` que desative isso. Confirme no **Console**,
nunca na Network.
→ [14.03 — O que não funciona na web](../modulos/14-build-web-pwa/03-o-que-nao-funciona-na-web.md)

---

### `Failed to load sqlite3.wasm`

**Causa:** ou o `dart run sqflite_common_ffi_web:setup` nunca rodou, ou `web/sqlite3.wasm` e
`web/sqflite_sw.js` não foram commitados. O segundo caso é o cruel: funciona na sua máquina e
quebra só no deploy, porque o CI compila a partir do repositório.

**Correção:** rode o setup e `git add web/sqlite3.wasm web/sqflite_sw.js`. Acrescente
`test -f build/web/sqlite3.wasm` às conferências do workflow.
→ [14.04 — Banco de dados na web](../modulos/14-build-web-pwa/04-banco-de-dados-na-web.md)

---

### O app não abre em modo avião

**Causa:** o CanvasKit está vindo do CDN do Google. O service worker do Flutter só faz cache de
recursos da **mesma origem**, então o engine nunca entra no cache offline.

**Correção:** compile com `--no-web-resources-cdn`. Em um PWA que promete offline, essa flag
não é opcional.
→ [14.08 — Gerando o build web](../modulos/14-build-web-pwa/08-gerando-o-build-web.md)

---

### O botão de instalar não aparece

**Causa:** um dos 8 critérios de instalabilidade falhou. Os três mais comuns: aberto por
`http://192.168…` (IP de rede local **não** é origem segura), build feito com
`--pwa-strategy=none` (sem service worker), ou o app **já está instalado**.

**Correção:** `Application → Manifest → Installability` diz exatamente qual critério falhou.
Só o caso "já instalado" não aparece lá — o navegador simplesmente para de oferecer.
→ [14.07 — Instalabilidade](../modulos/14-build-web-pwa/07-instalabilidade.md)

---

### Barra de navegador aparecendo dentro do app instalado

**Causa:** o `scope` do `manifest.json` não corresponde ao `--base-href`. O navegador entende
que a navegação saiu do app.

**Correção:** os dois iguais, com barra final. Esse defeito não quebra o build nem o deploy —
só aparece para quem instala, que é justamente o que ninguém testa antes de publicar.
→ [14.05 — Manifest e ícones](../modulos/14-build-web-pwa/05-manifest-e-icones.md)

---

### 🍎 O ícone no iPhone é um print da página

**Causa:** o Safari ignora os `icons` do manifest e procura `apple-touch-icon`.

**Correção:** as quatro meta tags `apple-*` no `web/index.html`.
→ [14.05 — Manifest e ícones](../modulos/14-build-web-pwa/05-manifest-e-icones.md)

---

### O usuário continua vendo a versão antiga depois do deploy

**Causa:** não é bug. O service worker serve o cache para abrir instantâneo e baixa a versão
nova em paralelo — que passa a valer na **abertura seguinte**.

**Correção:** implemente o aviso de atualização com `controllerchange` (com guarda de primeira
visita, senão todo usuário novo recebe o aviso). Desligar o service worker "resolveria" e
custaria o offline e a instalabilidade.
→ [14.06 — Service worker e offline](../modulos/14-build-web-pwa/06-service-worker-e-offline.md)

---

### Link direto para uma tela interna dá 404

**Causa:** hospedagem estática não tem *rewrite*. Com `usePathUrlStrategy()`, abrir
`/foco/sessoes` faz o servidor procurar um arquivo com esse nome.

**Correção:** publique um `404.html` que é uma **cópia** do `index.html` — assim o Flutter
carrega e o `onGenerateRoute` resolve a rota.
→ [14.09 — Publicando no GitHub Pages](../modulos/14-build-web-pwa/09-publicando-no-github-pages.md)

---

### Os dados dos usuários sumiram depois de publicar

**Causa:** a **URL mudou**. O IndexedDB é por origem — renomear o repositório ou migrar para
domínio próprio cria um armazenamento novo e vazio, e o antigo fica inacessível.

**Correção:** não tem, depois do fato. Decida a URL definitiva **antes** de ter usuários; é o
equivalente web ao `applicationId` do Android.
→ [14.04 — Banco de dados na web](../modulos/14-build-web-pwa/04-banco-de-dados-na-web.md)

---

### A URL publicada mostra o `README.md`

**Causa:** em `Settings → Pages`, o *Source* está como "Deploy from a branch" — o GitHub está
servindo o repositório como está, não o build.

**Correção:** *Source* = **GitHub Actions**.
→ [14.09 — Publicando no GitHub Pages](../modulos/14-build-web-pwa/09-publicando-no-github-pages.md)

---

## 🤖 Build Android

### `Keystore file not found`

**Causa:** quase sempre **barra invertida** no `storeFile` do `key.properties`. Em arquivos
`.properties`, `\` é caractere de escape — e a mensagem não menciona isso.

**Correção:** use barras normais, mesmo no Windows: `C:/Users/.../chave.jks`.
→ [Módulo 15, aula 7](../modulos/15-build-android/07-assinatura-no-gradle.md)

---

### `Unsupported class file major version 65`

**Causa:** versão do JDK incompatível com o Gradle.

**Correção:** use o JDK 17. Compare `flutter doctor -v` com `java -version` — a divergência entre
o JDK do `Path` e o do Android Studio é a causa nº 1 de "funciona no Studio e falha no terminal".

```powershell
flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"
```

---

### `MissingPluginException(No implementation found for method ...)`

**Causa:** você acrescentou um plugin e fez **hot reload**. Código nativo só entra num build
completo.

**Correção:** pare o app e rode de novo. Hot reload e hot restart não recompilam a parte nativa.

---

### `INSTALL_FAILED_UPDATE_INCOMPATIBLE`

```text
Package br.com.exemplo.app signatures do not match previously installed version
```

**Causa:** assinatura diferente da versão instalada.

**Correção:** em teste, `adb uninstall`. **Em produção isso significaria que nenhum usuário
conseguiria atualizar** — investigue por que a chave mudou.

---

### `INSTALL_FAILED_NO_MATCHING_ABIS`

**Causa:** APK `arm64` num emulador `x86_64`.

**Correção:** `flutter build apk --target-platform android-x64`.

---

### Funciona em debug e quebra em release

**Causa:** o R8 removeu uma classe que só é usada por reflexão. Debug não roda o R8.

**Correção:** regra `-keep` em `proguard-rules.pro`.
→ [Módulo 15, aula 7](../modulos/15-build-android/07-assinatura-no-gradle.md)

---

### `Version code NN has already been used`

**Causa:** `versionCode` repetido. Nenhum número volta a ficar livre — nem de um build descartado.

**Correção:** suba o `+N` no `pubspec.yaml`.

---

## 🍎 Build iOS

> 🪟 Você está no Windows. Estes erros aparecem quando o build roda num Mac ou em CI com runner
> macOS. Conhecê-los antes economiza a primeira sessão no Mac.

### `module 'X' not found`

**Causa duas:** (a) você abriu o `.xcodeproj` em vez do `.xcworkspace`; (b) faltou `pod install`.
As duas produzem a **mesma** mensagem.

**Correção:** `open ios/Runner.xcworkspace` e `cd ios && pod install`.
→ [Módulo 16, aula 4](../modulos/16-build-ios/04-bundle-id-e-xcode.md)

---

### `Command PhaseScriptExecution failed with a nonzero exit code`

**Causa:** isto **não é o erro** — é o Xcode dizendo que *algum script* falhou.

**Correção:** o erro real está no **Report Navigator (⌘9)** → última build → etapa vermelha →
ícone de expandir transcrição. Procurar essa mensagem na internet devolve centenas de causas
diferentes, todas verdadeiras para alguém.
→ [Módulo 16, aula 10](../modulos/16-build-ios/10-diagnostico-cocoapods-e-assinatura.md)

---

### `Signing for "Runner" requires a development team`

**Correção:** Xcode → Runner → Signing & Capabilities → escolha o Team.

---

### `No profiles for 'br.com.exemplo.app' were found`

**Causa:** profile ausente, **vencido**, ou Bundle ID divergente.

**Correção:** profiles valem **1 ano**. "Funcionava semana passada" com erro de assinatura é quase
sempre vencimento.

---

### `Sandbox: rsync deny file-write-create`

**Causa:** o Xcode 15 passou a rodar scripts de build em sandbox.

**Correção:** Build Settings → `ENABLE_USER_SCRIPT_SANDBOXING = NO`.

---

### `ERROR ITMS-90717: Invalid App Store Icon`

```text
The app store icon can't be transparent nor contain an alpha channel.
```

**Causa:** ícone com canal alfa. Descoberto **no upload**, depois de todo o build.

**Correção:** `remove_alpha_ios: true` no `flutter_launcher_icons`.
→ [Módulo 16, aula 5](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

---

### O app trava ao usar câmera / galeria / microfone no iOS

**Causa:** falta a chave `NS*UsageDescription` no `Info.plist`. Diferente do Android, o iOS
**encerra o processo** em vez de negar a chamada.

**Correção:** declare a chave com um texto específico, em português.

---

## 📢 Publicação

### `ERROR ITMS-4238: Redundant Binary Upload`

**Causa:** `CFBundleVersion` já usado.

**Correção:** suba o `+N`. Nenhum número é reaproveitável.

---

### O build fica em "Processing" por horas

**Causa:** o processamento falhou.

**Correção:** **confira o e-mail do Apple ID** — o aviso vai só por lá; o painel apenas remove o
build da lista, sem explicar.

---

### `Missing Compliance` em todo envio

**Correção:** `ITSAppUsesNonExemptEncryption` como `false` no `Info.plist`. HTTPS e Keychain são
isentos.

---

### Teste externo do TestFlight reprovado

**Causa mais comum:** você não forneceu **conta de teste** na *Information for Review*, e o
revisor não conseguiu entrar no app.

---

## 🆘 Não achou o seu erro aqui

Siga o método de 5 passos de
[00-como-usar-o-curso.md](../00-como-usar-o-curso.md), e aplique o de 6 passos para erro de build:

1. Leia a mensagem **inteira** — a causa costuma estar na última linha, não na primeira.
2. Identifique a **camada**: Dart, ponte de plugin, ou nativo?
3. **O que mudou?** `git log --oneline -5`. Resolve mais casos que os outros cinco juntos.
4. Limpe **na ordem**: `flutter clean` → `gradlew clean` → cache global. Nunca comece pelo último.
5. Aumente o detalhe: `-v`, `--stacktrace` — e procure **o seu pacote** na saída.
6. Isole: `flutter create teste`, acrescente só o plugin suspeito, veja se falha lá também.

E quando pedir ajuda, leve: a mensagem **exata**, quando acontece, o que você já tentou, e o
código mínimo que reproduz. Montar esse exemplo mínimo resolve o problema sozinho com uma
frequência surpreendente.

---

[Glossário](glossario.md) · [Comandos úteis](comandos-uteis.md) · [Curso](../README.md)
