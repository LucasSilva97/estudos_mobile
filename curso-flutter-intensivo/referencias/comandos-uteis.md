# ⌨️ Comandos úteis — referência completa

> **Para que serve esta página.** É a sua cola permanente. Cada comando aparece com: o texto
> exato para digitar, o que ele faz, quando usar, a saída que você deve esperar e as
> observações que evitam dor de cabeça.
>
> **Ambiente do curso:** Flutter 3.47.1 · Dart 3.13.1 · JDK 17 (Temurin) · Git 2.46 ·
> Windows 11 (PowerShell).

## 🔖 Como ler esta página

| Marca | Significado |
|---|---|
| ✅ | Comando **executado de verdade** na máquina do curso durante a validação |
| 📘 | Comando da **documentação oficial** da ferramenta (Flutter, Git, Android, Apple) |
| 🪟 | Só no Windows (PowerShell) |
| 🖥️ | Só no macOS |
| 🐧 | Só no Linux |
| 🤖 | Relacionado ao Android |
| 🍎 | Relacionado ao iOS — **exige macOS + Xcode** |

> ⚠️ **Convenção de segredos.** Em todo exemplo desta página, senhas, apelidos de chave,
> identificadores de time e caminhos pessoais aparecem como **marcadores**:
> `SUA_SENHA_AQUI`, `SEU_ALIAS`, `SEU_TEAM_ID`, `SUA_API_KEY`, `SEU_ISSUER_ID`,
> `<seu-usuario>`. Troque pelos seus valores **na sua máquina** e nunca os escreva em um
> arquivo versionado.

**Páginas irmãs:** [Glossário](glossario.md) · [Erros comuns](erros-comuns.md) ·
[Diferenças Android × iOS](diferencas-android-ios.md) · [Referências oficiais](referencias-oficiais.md)

---

## 📋 Índice

1. [Cola rápida — os 15 do dia a dia](#-cola-rápida--os-15-do-dia-a-dia)
2. [Flutter — diagnóstico e projeto](#1-flutter--diagnóstico-e-projeto)
3. [Flutter — rodar e recarregar](#2-flutter--rodar-e-recarregar)
4. [Dart — analisar e formatar](#3-dart--analisar-e-formatar)
5. [pub — pacotes e dependências](#4-pub--pacotes-e-dependências)
6. [Emulador e dispositivos](#5-emulador-e-dispositivos)
7. [Ícone e splash](#6-ícone-e-splash)
8. [Testes](#7-testes)
9. [Build Web 🌐 (PWA)](#8-build-web--pwa)
10. [Build Android 🤖](#9-build-android-)
11. [keytool — chaves e keystore 🤖](#10-keytool--chaves-e-keystore-)
12. [Gradle 🤖](#11-gradle-)
13. [adb — falando com o aparelho 🤖](#12-adb--falando-com-o-aparelho-)
14. [Build iOS 🍎](#13-build-ios-)
15. [Xcode e CocoaPods 🍎](#14-xcode-e-cocoapods-)
16. [Git](#15-git)
17. [Windows — comandos do sistema 🪟](#16-windows--comandos-do-sistema-)

---

## 🚀 Cola rápida — os 15 do dia a dia

Se você só puder decorar quinze comandos, que sejam estes.

| # | Comando | Para quê |
|---|---|---|
| 1 | `flutter doctor -v` | Conferir se o ambiente está inteiro |
| 2 | `flutter create --platforms=android,ios nome_do_app` | Criar um projeto novo |
| 3 | `flutter pub get` | Baixar as dependências do `pubspec.yaml` |
| 4 | `flutter pub add <pacote>` | Adicionar uma dependência |
| 5 | `flutter run` | Rodar o app no aparelho/emulador conectado |
| 6 | `r` (dentro do `flutter run`) | Hot reload — aplica a mudança sem perder o estado |
| 7 | `R` (dentro do `flutter run`) | Hot restart — reinicia o app do zero |
| 8 | `flutter analyze` | Achar erros e avisos sem rodar o app |
| 9 | `dart format .` | Formatar todo o código no padrão oficial |
| 10 | `flutter test` | Rodar a suíte de testes |
| 11 | `flutter devices` | Ver o que está conectado |
| 12 | `flutter clean` | Apagar o cache de build quando algo estranho acontece |
| 13 | `flutter build apk --release` | Gerar o APK de release 🤖 |
| 14 | `flutter build appbundle` | Gerar o AAB para a Google Play 🤖 |
| 15 | `git status` | Ver o que mudou antes de commitar |

> 💡 **Dica de ouro.** Quando algo der errado sem explicação, a sequência
> `flutter clean` → `flutter pub get` → `flutter run` resolve uma boa parte dos casos.
> Ela não é mágica: ela apaga o cache de build, que é onde os problemas se escondem.

---

## 1. Flutter — diagnóstico e projeto

#### ✅ `flutter --version`
```powershell
flutter --version
```
- **O que faz:** mostra a versão do Flutter, do Dart, o canal, a revisão do Git e a data do build.
- **Quando usar:** é o primeiro comando a rodar quando alguém pergunta "qual sua versão?" e sempre que um tutorial não bater com o que você vê na tela.
- **Saída esperada:** algo começando com `Flutter 3.47.1 • channel stable` e, mais abaixo, `Tools • Dart 3.13.1 • DevTools 2.60.0`.
- **Observação:** se a versão for diferente da do curso, o código pode se comportar de outro jeito. O curso inteiro assume 3.47.1.

#### ✅ `flutter doctor -v`
```powershell
flutter doctor -v
```
- **O que faz:** faz um exame completo do ambiente: Flutter, Android toolchain, Visual Studio, Android Studio, VS Code, Chrome e dispositivos conectados. O `-v` (de *verbose*, "detalhado") mostra os caminhos de cada coisa.
- **Quando usar:** ao montar o ambiente, e toda vez que um build falhar por motivo desconhecido.
- **Saída esperada:** uma lista com `[✓]` (tudo certo), `[!]` (aviso, dá para seguir) e `[X]` (bloqueio).
- **Observação:** 🪟 Se o SDK estiver num caminho com acento, este comando **quebra** com `FileSystemException: Cannot resolve symbolic links`. A correção é mover o SDK para `C:\src\flutter`. Veja [Erros comuns](erros-comuns.md).

#### ⚠️ `flutter doctor --android-licenses` 🤖
```powershell
flutter doctor --android-licenses
```
- **O que faz:** exibe uma a uma as licenças do Android SDK para você aceitar. **Em SDKs recentes não faz mais nada** — veja a observação.
- **Quando usar:** apenas em Android SDKs antigos, quando o `flutter doctor` acusar `Some Android licenses not accepted`.
- **Saída esperada (SDK antigo):** vários textos de licença, cada um perguntando `Accept? (y/N):` — responda `y` e tecle Enter. No fim: `All SDK package licenses accepted.`
- **Saída esperada (SDK recente):** um aviso de depreciação, `The --licenses option is no longer needed`. Isso **não é erro**: o Google trocou o `sdkmanager` pelo **Android CLI** (`android`) e o aceite de licenças passou a acontecer junto com o `android sdk install`.
- **Observação:** para saber se as licenças estão de fato aceitas, o comando certo hoje é `flutter doctor -v` — procure a linha `All Android licenses accepted.` Se aparecer `Unable to locate Android SDK`, instale o SDK antes.

#### ✅ `android sdk list` / `android sdk install` 🤖
```powershell
android sdk list
android sdk install "platforms;android-36"
```
- **O que faz:** lista e instala pacotes do Android SDK. É o substituto oficial do `sdkmanager`, aposentado pelo Google.
- **Quando usar:** para instalar uma *platform*, *build-tools* ou imagem de emulador sem abrir o Android Studio. A instalação já aceita as licenças dos pacotes baixados.
- **Saída esperada:** a lista de pacotes instalados e disponíveis; no `install`, o progresso do download.
- **Observação:** o binário `android.exe` fica em `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin`. Adicione essa pasta ao `Path` para chamá-lo de qualquer lugar.

#### ✅ `flutter create meu_app`
```powershell
flutter create meu_app
```
- **O que faz:** cria uma pasta `meu_app` com um projeto Flutter completo para todas as plataformas disponíveis, já com o app de exemplo do contador.
- **Quando usar:** para experimentar rápido.
- **Saída esperada:** uma lista de arquivos criados e, no fim, `All done!` com a instrução `cd meu_app` / `flutter run`.
- **Observação:** o nome do projeto precisa ser em minúsculas com sublinhado (`meu_app`), nunca com hífen nem com acento.

#### ✅ `flutter create --platforms=android,ios nome_do_app`
```powershell
flutter create --platforms=android,ios nome_do_app
```
- **O que faz:** cria o projeto **só** com as pastas `android/` e `ios/`, sem web, Windows, Linux nem macOS.
- **Quando usar:** é a forma recomendada neste curso. Menos pastas, menos confusão, build mais rápido.
- **Saída esperada:** igual ao anterior, mas sem as pastas das outras plataformas.
- **Observação:** 🍎 A pasta `ios/` é gerada normalmente no Windows — você pode **ler** e **editar** os arquivos. O que não dá para fazer no Windows é **compilar** o iOS.

#### ✅ `flutter create --platforms=android,ios -e nome_do_app`
```powershell
flutter create --platforms=android,ios -e nome_do_app
```
- **O que faz:** o `-e` (de *empty*, "vazio") cria o projeto **sem** o app de exemplo do contador: um `main.dart` mínimo.
- **Quando usar:** quando você vai escrever o app do zero e não quer apagar o exemplo antes.
- **Saída esperada:** `All done!`, e um `lib/main.dart` com poucas linhas.
- **Observação:** ótimo para os projetos 2 e 3 do curso, em que você constrói a estrutura à mão.

#### ✅ `flutter clean`
```powershell
flutter clean
```
- **O que faz:** apaga as pastas de build e o cache do projeto (`build/`, `.dart_tool/`).
- **Quando usar:** depois de gerar ícone e splash, depois de trocar de versão do Flutter, e sempre que o erro não fizer sentido nenhum.
- **Saída esperada:** linhas `Deleting build...`, `Deleting .dart_tool...`.
- **Observação:** depois dele você **precisa** rodar `flutter pub get` de novo. E o primeiro build seguinte será lento — é normal, ele está reconstruindo tudo.

#### ✅ `flutter config --list`
```powershell
flutter config --list
```
- **O que faz:** mostra as configurações globais da sua instalação do Flutter: plataformas habilitadas, caminho do Android SDK, estado do Swift Package Manager.
- **Quando usar:** quando quiser saber por que uma plataforma não aparece em `flutter create`.
- **Saída esperada:** uma lista de chaves e valores; opções não definidas aparecem como `(Not set)`.
- **Observação:** é só leitura — não muda nada.

#### 📘 `flutter config --enable-swift-package-manager` 🍎
```powershell
flutter config --enable-swift-package-manager
```
- **O que faz:** liga o suporte ao Swift Package Manager (SPM), o gerenciador de dependências nativas da Apple.
- **Quando usar:** praticamente nunca — **desde o Flutter 3.44 o SPM já vem ligado por padrão**. Use só se alguém tiver desligado antes.
- **Saída esperada:** uma confirmação de que a configuração foi gravada.
- **Observação:** se algum plugin do projeto ainda não suportar SPM, o Flutter volta sozinho para o CocoaPods. Os dois convivem.

#### 📘 `flutter config --no-enable-swift-package-manager` 🍎
```powershell
flutter config --no-enable-swift-package-manager
```
- **O que faz:** desliga o SPM globalmente, forçando o CocoaPods.
- **Quando usar:** ao depurar um problema específico de dependência nativa no iOS.
- **Saída esperada:** confirmação da gravação.
- **Observação:** para desligar **só em um projeto**, prefira o `pubspec.yaml`:
  ```yaml
  flutter:
    config:
      enable-swift-package-manager: false
  ```

---

## 2. Flutter — rodar e recarregar

#### ✅ `flutter run`
```powershell
flutter run
```
- **O que faz:** compila em modo debug e instala no dispositivo conectado, deixando o terminal ligado ao app.
- **Quando usar:** o tempo todo, durante o desenvolvimento.
- **Saída esperada:** `Launching lib\main.dart on ... in debug mode...`, depois o endereço do Dart DevTools e a linha `Flutter run key commands.`
- **Observação:** se houver mais de um dispositivo, ele pergunta qual usar. Para escolher direto, use `-d`.

#### ✅ `flutter run -d windows` 🪟
```powershell
flutter run -d windows
```
- **O que faz:** roda o app como um programa de desktop do Windows.
- **Quando usar:** para testar lógica, layout e navegação **sem emulador**. É o jeito mais rápido de ver algo na tela enquanto o Android SDK ainda não está instalado.
- **Saída esperada:** uma janela do Windows abre com o app.
- **Observação:** exige as ferramentas de desktop do Visual Studio (carga de trabalho "Desenvolvimento para desktop com C++"). Plugins que dependem de Android/iOS (câmera, por exemplo) **não funcionam** aqui.

#### ✅ Teclas dentro do `flutter run`
```text
r   hot reload   -> aplica a mudança e mantém o estado da tela
R   hot restart  -> reinicia o app do zero (perde o estado)
h   ajuda        -> lista todas as teclas disponíveis
q   sair         -> encerra a sessão
```
- **O que faz:** são atalhos do terminal enquanto o `flutter run` está ativo.
- **Quando usar:** `r` na maioria das mudanças de interface; `R` quando mexer em `main()`, em variáveis globais, em campos `static` ou em `initState` que já rodou.
- **Saída esperada:** `Reloaded 1 of 512 libraries in 431ms.` ou `Restarted application in 1.234ms.`
- **Observação:** salvar o arquivo no VS Code já dispara o hot reload automaticamente.

---

## 3. Dart — analisar e formatar

#### ✅ `flutter analyze`
```powershell
flutter analyze
```
- **O que faz:** roda a análise estática sobre o projeto inteiro: erros de tipo, `await` esquecido, código morto, violações dos lints de `analysis_options.yaml`.
- **Quando usar:** antes de cada commit. Sem exceção.
- **Saída esperada:** `Analyzing foco...` e então `No issues found!` ou uma lista de `info`, `warning` e `error` com arquivo e linha.
- **Observação:** 🪟 Com o SDK num caminho com acento, o servidor de análise pode encerrar com código 255. Mover o SDK para `C:\src\flutter` resolve.

#### ✅ `dart analyze lib test`
```powershell
dart analyze lib test
```
- **O que faz:** mesma análise, mas restrita às pastas que você listar.
- **Quando usar:** em projeto grande, para olhar só o que interessa e ter uma saída curta.
- **Saída esperada:** `No issues found!` ou a lista de problemas daquelas pastas.
- **Observação:** `dart analyze` não conhece as regras específicas de Flutter em alguns casos de borda; para o veredito final, prefira `flutter analyze`.

#### ✅ `dart format .`
```powershell
dart format .
```
- **O que faz:** reescreve todos os arquivos `.dart` a partir da pasta atual no formato oficial: indentação, quebras de linha, vírgulas finais.
- **Quando usar:** antes de commitar. Formatação uniforme torna o `git diff` legível.
- **Saída esperada:** `Formatted 42 files (7 changed) in 0.83 seconds.`
- **Observação:** o ponto final é a pasta atual — ele **altera os arquivos**. Para só conferir sem alterar, existe o modo de verificação do próprio `dart format` (📘 `dart format --output=none --set-exit-if-changed .`), útil em CI.

---

## 4. pub — pacotes e dependências

#### ✅ `flutter pub get`
```powershell
flutter pub get
```
- **O que faz:** lê o `pubspec.yaml`, baixa cada dependência e grava as versões exatas em `pubspec.lock`.
- **Quando usar:** depois de clonar um projeto, depois de editar o `pubspec.yaml` à mão e depois de `flutter clean`.
- **Saída esperada:** `Resolving dependencies...`, a lista de pacotes e `Got dependencies!`.
- **Observação:** 🪟 Em projeto com plugins, se o Modo de Desenvolvedor do Windows estiver desligado, aparece `Building with plugins requires symlink support`. Rode `start ms-settings:developers` e ligue.

#### ✅ `flutter pub add flutter_riverpod`
```powershell
flutter pub add flutter_riverpod
```
- **O que faz:** adiciona o pacote em `dependencies:` do `pubspec.yaml`, já com a restrição de versão, e roda o `pub get`.
- **Quando usar:** sempre que precisar de um pacote novo. É melhor do que editar o YAML à mão, porque ele acerta a versão e a indentação.
- **Saída esperada:** `+ flutter_riverpod 3.4.3` e, no fim, `Changed 1 dependency!`.
- **Observação:** as versões oficiais do curso estão em [05-decisoes-tecnicas.md](../05-decisoes-tecnicas.md). Se o `pub` trouxer uma versão maior, fixe a do curso no `pubspec.yaml` para o código das aulas continuar batendo.

#### ✅ `flutter pub add dev:mocktail`
```powershell
flutter pub add dev:mocktail
```
- **O que faz:** o prefixo `dev:` coloca o pacote em `dev_dependencies:` — dependência usada **só no desenvolvimento e nos testes**, que não vai dentro do app publicado.
- **Quando usar:** para tudo que é ferramenta: `mocktail`, `flutter_lints`, `flutter_launcher_icons`, `flutter_native_splash`, `sqflite_common_ffi`.
- **Saída esperada:** `+ mocktail 1.0.5` e `Changed 1 dependency!`.
- **Observação:** colocar ferramenta em `dependencies` engorda o app à toa. Vale conferir onde cada pacote caiu.

#### ✅ `flutter pub outdated`
```powershell
flutter pub outdated
```
- **O que faz:** compara, para cada dependência, a versão instalada, a maior compatível com suas restrições e a última publicada no pub.dev.
- **Quando usar:** ao revisar a saúde do projeto, tipicamente uma vez por mês.
- **Saída esperada:** uma tabela com as colunas `Current`, `Upgradable`, `Resolvable`, `Latest`.
- **Observação:** durante o curso, **não atualize** por atualizar. O material foi validado nas versões da seção 3 da especificação.

---

## 5. Emulador e dispositivos

#### ✅ `flutter devices`
```powershell
flutter devices
```
- **O que faz:** lista tudo em que o Flutter consegue rodar agora: celulares conectados por cabo, emuladores ligados, Windows desktop e Chrome.
- **Quando usar:** antes de `flutter run`, para confirmar que o aparelho foi reconhecido.
- **Saída esperada:** uma linha por dispositivo, com nome, identificador, plataforma e versão. Se não houver nada: `No devices detected.`
- **Observação:** 🤖 Se o celular físico não aparecer, confira se a **Depuração USB** está ligada nas opções de desenvolvedor e se você aceitou o aviso de autorização na tela do aparelho.

#### ✅ `flutter emulators`
```powershell
flutter emulators
```
- **O que faz:** lista os emuladores Android **já criados** na sua máquina.
- **Quando usar:** para descobrir o identificador do emulador que você quer abrir.
- **Saída esperada:** linhas no formato `Pixel_7_API_36 • Pixel 7 • Google • android`.
- **Observação:** se a lista vier vazia, você ainda não criou nenhum — isso se faz no Device Manager do Android Studio. Sem Android SDK instalado, o comando avisa que não encontrou emuladores.

#### 📘 `flutter emulators --launch <id>` 🤖
```powershell
flutter emulators --launch Pixel_7_API_36
```
- **O que faz:** abre o emulador cujo identificador você passar, sem precisar do Android Studio.
- **Quando usar:** para começar a trabalhar direto do terminal.
- **Saída esperada:** nenhuma mensagem longa; a janela do emulador abre em alguns segundos.
- **Observação:** troque `Pixel_7_API_36` pelo identificador que apareceu em `flutter emulators` — ele varia conforme o aparelho virtual que você criou.

#### ✅ `flutter install`
```powershell
flutter install
```
- **O que faz:** instala no dispositivo conectado o app já construído, sem abrir a sessão de depuração.
- **Quando usar:** para deixar o app instalado no celular e usá-lo como um app normal, desconectado do computador.
- **Saída esperada:** `Installing build\app\outputs\flutter-apk\app.apk...` seguido de `Done.`
- **Observação:** por padrão instala a variante de debug. Para colocar a de release no aparelho, gere o APK de release e instale com o `adb`.

---

## 6. Ícone e splash

#### ✅ `dart run flutter_launcher_icons`
```powershell
dart run flutter_launcher_icons
```
- **O que faz:** lê o bloco `flutter_launcher_icons:` do `pubspec.yaml` e gera, a partir de **uma** imagem de 1024×1024, todos os ícones do Android (cada densidade + o ícone adaptativo) e do iOS (todas as escalas).
- **Quando usar:** no passo 4 da sequência de identidade visual, depois de definir `applicationId`, nome exibido e versão.
- **Saída esperada:**
  ```text
  ════════════════════════════════════════════
     FLUTTER LAUNCHER ICONS (v0.14.4)
  ════════════════════════════════════════════

  • Creating default icons Android
  • Creating adaptive icons Android
  • Adding a new Android launcher icon
  • No colors.xml file found in your Android project
  • Creating colors.xml file and adding it to your Android project
  • Creating mipmap xml file Android
  • Overwriting default iOS launcher icon with new icon
  No platform provided

  ✓ Successfully generated launcher icons
  ```
- **Observação:** a linha `No platform provided` é **normal**, não é erro. O bloco `flutter_launcher_icons:` é de **primeiro nível** no `pubspec.yaml` — alinhado com `dependencies:`, nunca dentro de `flutter:`. E `remove_alpha_ios: true` é obrigatório: a Apple rejeita ícone com transparência.

#### ✅ `dart run flutter_native_splash:create`
```powershell
dart run flutter_native_splash:create
```
- **O que faz:** lê o bloco `flutter_native_splash:` do `pubspec.yaml` e gera a tela de abertura nas duas plataformas, incluindo as variantes de modo escuro e a versão específica do Android 12+.
- **Quando usar:** no passo 5, logo depois do ícone.
- **Saída esperada:** mensagens de criação dos arquivos e uma confirmação ao final.
- **Observação:** ele **altera** arquivos nativos, entre eles `android/app/src/main/res/drawable/launch_background.xml`, `values-v31/styles.xml` (Android 12+) e o `ios/Runner/Info.plist`. Rode `flutter clean` antes de gerar o build de release.

#### ✅ `dart run flutter_native_splash:remove`
```powershell
dart run flutter_native_splash:remove
```
- **O que faz:** desfaz o que o `:create` fez, devolvendo os arquivos nativos ao estado padrão.
- **Quando usar:** ao mudar de ideia sobre a splash, ou quando uma configuração errada gerou um resultado quebrado.
- **Saída esperada:** mensagens de restauração dos arquivos.
- **Observação:** rode `flutter clean` depois, para o Gradle não reaproveitar os recursos antigos do cache.

---

## 7. Testes

#### ✅ `flutter test`
```powershell
flutter test
```
- **O que faz:** roda todos os arquivos `*_test.dart` da pasta `test/`.
- **Quando usar:** antes de cada commit e sempre depois de mexer em lógica.
- **Saída esperada:** pontos ou nomes dos testes e, no fim, `All tests passed!`. Se falhar, mostra o teste, o `Expected:` e o `Actual:`.
- **Observação:** ⚠️ Se algum teste usar `Future.delayed`, finalize com `await tester.pump(const Duration(milliseconds: 50));` ou `await tester.pumpAndSettle();` — senão você recebe `A Timer is still pending even after the widget tree was disposed.`

#### ✅ `flutter test --plain-name "nome do teste"`
```powershell
flutter test --plain-name "copyWith troca so o campo informado"
```
- **O que faz:** roda apenas os testes cujo nome contém o texto informado.
- **Quando usar:** ao consertar um teste específico. Rodar a suíte inteira a cada tentativa desperdiça minutos.
- **Saída esperada:** só aquele teste, com `All tests passed!` ou a falha detalhada.
- **Observação:** o texto é comparado literalmente (não é expressão regular) e precisa estar entre aspas se tiver espaço.

#### 📘 `flutter test --coverage`
```powershell
flutter test --coverage
```
- **O que faz:** roda a suíte e grava o relatório de cobertura em `coverage/lcov.info`.
- **Quando usar:** para descobrir quais partes do código nenhum teste toca.
- **Saída esperada:** igual ao `flutter test`, mais o arquivo `coverage/lcov.info` criado.
- **Observação:** cobertura é um termômetro, não uma nota. 90% com testes que não verificam nada vale menos que 50% com testes honestos. Coloque `coverage/` no `.gitignore`.

#### 📘 `flutter test integration_test`
```powershell
flutter test integration_test
```
- **O que faz:** roda os testes de integração, que sobem o app de verdade em um dispositivo ou emulador.
- **Quando usar:** para validar um fluxo completo de ponta a ponta antes de gerar um release.
- **Saída esperada:** o app abre no aparelho, o teste dirige a interface sozinho e o terminal conclui com `All tests passed!`.
- **Observação:** exige um dispositivo conectado; é bem mais lento que os testes de widget. Use-o para poucos fluxos críticos, não para tudo.

---

## 8. Build Web 🌐 (PWA)

> É o **canal principal de distribuição** do curso. O passo a passo está em
> [14.08 — Gerando o build web](../modulos/14-build-web-pwa/08-gerando-o-build-web.md).

#### ✅ `flutter build web --release`
```powershell
flutter build web --release
```
- **O que faz:** compila o app para a pasta `build/web/`, pronta para ser servida por qualquer servidor HTTPS.
- **Quando usar:** quando o app fica na **raiz** do domínio.
- **Saída esperada:** `√ Built build\web`.
- **Observação:** não há assinatura nem `versionCode` — publicar é copiar arquivos.

#### ✅ `flutter build web --release --base-href /foco/`
```powershell
flutter build web --release --base-href /foco/
```
- **O que faz:** o mesmo, dizendo ao `index.html` que o app mora numa **subpasta**.
- **Quando usar:** sempre que a URL não for a raiz — é o caso do GitHub Pages de projeto.
- **Saída esperada:** `<base href="/foco/">` dentro de `build/web/index.html`.
- **Observação:** ⚠️ **A pegadinha nº 1 da web.** Precisa começar e terminar com `/`, e ser **igual ao `scope`** do `web/manifest.json`. Errado, a página abre **branca** com 404 em `main.dart.js`.

#### ✅ `flutter build web --release --no-web-resources-cdn`
```powershell
flutter build web --release --base-href /foco/ --no-web-resources-cdn --source-maps
```
- **O que faz:** serve o CanvasKit do **seu** servidor em vez do CDN do Google, e gera os source maps.
- **Quando usar:** **sempre**, em PWA que promete funcionar offline.
- **Saída esperada:** `build/web/canvaskit/canvaskit.wasm` presente.
- **Observação:** ⚠️ sem essa flag o service worker **não** guarda o engine (é de outra origem) e o app instalado pode não abrir em modo avião.

#### ✅ `flutter test --platform chrome`
```powershell
flutter test --platform chrome
```
- **O que faz:** roda a suíte de testes dentro de um Chrome headless.
- **Quando usar:** antes de todo build web, e como portão no CI.
- **Saída esperada:** `All tests passed!`.
- **Observação:** ⭐ É o **único** portão automatizado que pega `dart:io`, `Platform.isX` e plugins sem implementação web. `flutter test` sozinho roda na Dart VM e dá **falso verde**.

#### ✅ `dart run sqflite_common_ffi_web:setup`
```powershell
dart run sqflite_common_ffi_web:setup
```
- **O que faz:** baixa `sqlite3.wasm` e `sqflite_sw.js` para a pasta `web/`.
- **Quando usar:** uma vez, ao habilitar o banco na web.
- **Saída esperada:** os dois arquivos em `web/`.
- **Observação:** ⚠️ **commite os dois.** Sem eles no Git, o app publicado abre e o **banco não** — e funciona perfeitamente na sua máquina.

#### ✅ Servir o build localmente, em subpasta
```powershell
dart pub global activate dhttpd
New-Item -ItemType Directory -Force -Path .\publicadooco | Out-Null
Copy-Item -Recurse -Force .uild\web\* .\publicadoocodart pub global run dhttpd --path publicado --port 8080
```
- **O que faz:** serve os arquivos como um servidor comum, imitando o GitHub Pages.
- **Quando usar:** **antes de publicar**, sempre.
- **Saída esperada:** o app abre em `http://localhost:8080/foco/`.
- **Observação:** ⚠️ `flutter run -d chrome` serve na **raiz** e por isso **não reproduz** o problema de `--base-href`. E recarregue com **Ctrl+Shift+R**: um F5 recebe o cache do service worker antigo.

---

## 9. Build Android 🤖

> Antes de qualquer build de release, confira o passo a passo de
> [15.08 — Gerando APK e AAB](../modulos/15-build-android/08-gerando-apk-e-aab.md).

#### ✅ `flutter build apk --debug`
```powershell
flutter build apk --debug
```
- **O que faz:** gera um APK em modo debug.
- **Quando usar:** para enviar uma versão de teste rápida a alguém, sabendo que ela é lenta e grande.
- **Saída esperada:** `✓ Built build\app\outputs\flutter-apk\app-debug.apk`.
- **Observação:** **não** meça desempenho com esta versão. O modo debug tem checagens extras que deixam tudo mais lento de propósito.

#### ✅ `flutter build apk --release`
```powershell
flutter build apk --release
```
- **O que faz:** gera um APK único, otimizado e compilado em AOT, contendo **todas** as ABIs.
- **Quando usar:** para distribuir fora da loja (link direto, e-mail, site próprio).
- **Saída esperada:** `✓ Built build\app\outputs\flutter-apk\app-release.apk` com o tamanho do arquivo.
- **Observação:** ⚠️ Enquanto o `android/app/build.gradle.kts` mantiver
  `signingConfig = signingConfigs.getByName("debug")` no bloco `release`, esse APK está assinado com a **chave de depuração** e não pode ser publicado. Isso vem assim do `flutter create`, junto de um comentário `TODO`.

#### ✅ `flutter build apk --split-per-abi`
```powershell
flutter build apk --split-per-abi
```
- **O que faz:** gera um APK **por arquitetura de processador**, cada um bem menor que o APK universal.
- **Quando usar:** ao distribuir fora da loja e querer economizar o download do usuário.
- **Saída esperada:** três arquivos em `build\app\outputs\flutter-apk\`:
  ```text
  app-armeabi-v7a-release.apk
  app-arm64-v8a-release.apk
  app-x86_64-release.apk
  ```
- **Observação:** você precisa saber qual entregar a quem. Celular moderno usa `arm64-v8a`; emulador normalmente usa `x86_64`. Para a loja, esse problema nem existe — use AAB.

#### ✅ `flutter build appbundle`
```powershell
flutter build appbundle
```
- **O que faz:** gera o Android App Bundle, o formato **obrigatório** para apps novos na Google Play.
- **Quando usar:** sempre que for publicar na Play.
- **Saída esperada:** `✓ Built build\app\outputs\bundle\release\app-release.aab`.
- **Observação:** o AAB **não se instala** no celular — quem monta o APK final é a loja. Para testar o resultado no aparelho, use o APK de release.

---

## 10. keytool — chaves e keystore 🤖

#### ✅ `keytool -genkey ...` — criar o keystore
**🪟 Windows (PowerShell)** — a crase `` ` `` no fim da linha é a continuação de linha do PowerShell:
```powershell
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks `
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
        -alias SEU_ALIAS
```

**🖥️ macOS / 🐧 Linux (bash/zsh)** — a barra invertida `\` é a continuação de linha:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
        -alias SEU_ALIAS
```
- **O que faz:** cria o arquivo de chaves com uma chave RSA de 2048 bits válida por 10.000 dias (cerca de 27 anos).
- **Quando usar:** **uma vez só** por app, antes do primeiro release.
- **Saída esperada:** ele pergunta, em sequência: a senha do keystore (digite duas vezes), seu nome, unidade organizacional, organização, cidade, estado e o código do país (duas letras, ex.: `BR`). No fim, confirma com `[Armazenando <caminho>]`.
- **Observação:** 🔴 **Três regras inegociáveis.** (1) A senha que você digitar é `SUA_SENHA_AQUI` nos exemplos — nunca escreva a verdadeira em arquivo versionado. (2) Guarde o `.jks` num backup seguro: **perdeu a chave, perdeu a capacidade de atualizar o app**. (3) Coloque `*.jks`, `*.keystore` e `key.properties` no `.gitignore` antes do próximo commit.

#### 📘 `keytool -list -v -keystore ... -alias ...`
**🪟 Windows (PowerShell)**
```powershell
keytool -list -v -keystore $env:USERPROFILE\upload-keystore.jks -alias SEU_ALIAS
```
**🖥️ macOS / 🐧 Linux**
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias SEU_ALIAS
```
- **O que faz:** mostra os dados da chave: dono, validade e as impressões digitais SHA-1 e SHA-256.
- **Quando usar:** para conferir que o alias está certo, para verificar a validade e quando algum serviço pedir a impressão digital SHA-1 do seu certificado.
- **Saída esperada:** um bloco com `Nome do alias`, `Data de criação`, `Proprietário`, `Emissor`, `Válido de ... até ...` e as impressões digitais.
- **Observação:** ele pede a senha do keystore. Se você esqueceu a senha, não há recuperação — por isso o backup importa tanto.

---

## 11. Gradle 🤖

> No dia a dia você **não chama o Gradle direto**: o `flutter build` faz isso por você. Os
> comandos abaixo servem para diagnóstico, quando a mensagem de erro vem do Gradle e você
> precisa vê-la com mais detalhe. Todos rodam **de dentro da pasta `android/`**.

#### 📘 `.\gradlew --version`
**🪟 Windows (PowerShell)**
```powershell
cd android
.\gradlew --version
```
**🖥️ macOS / 🐧 Linux**
```bash
cd android
./gradlew --version
```
- **O que faz:** mostra a versão do Gradle usada pelo projeto e a versão da JVM (Java) que está executando.
- **Quando usar:** quando o build reclamar de incompatibilidade entre Gradle, AGP e JDK.
- **Saída esperada:** um bloco com `Gradle 9.3.1`, `JVM: 17.0.18 (Eclipse Adoptium)` e o sistema operacional.
- **Observação:** o Flutter 3.47 gera o wrapper do Gradle **9.3.1**, AGP **9.1.0** e Kotlin **2.4.0**, exigindo **JDK 17**. Se a linha `JVM` mostrar outra versão, é aí que está o seu problema.

#### 📘 `.\gradlew clean`
**🪟 Windows (PowerShell)**
```powershell
cd android
.\gradlew clean
```
**🖥️ macOS / 🐧 Linux**
```bash
cd android
./gradlew clean
```
- **O que faz:** apaga as saídas de build do lado Android.
- **Quando usar:** quando `flutter clean` não bastou e o Gradle continua entregando resultado antigo.
- **Saída esperada:** `BUILD SUCCESSFUL in 4s`.
- **Observação:** depois dele, volte para a raiz do projeto (`cd ..`) antes de rodar comandos do Flutter.

#### 📘 `.\gradlew signingReport`
**🪟 Windows (PowerShell)**
```powershell
cd android
.\gradlew signingReport
```
**🖥️ macOS / 🐧 Linux**
```bash
cd android
./gradlew signingReport
```
- **O que faz:** lista, para cada variante de build, qual configuração de assinatura está sendo usada e as impressões digitais correspondentes.
- **Quando usar:** para **provar** que o release está sendo assinado com a sua chave e não com a de debug.
- **Saída esperada:** blocos `Variant: release`, `Config: release`, `Store: <caminho do seu .jks>`, mais SHA-1 e SHA-256.
- **Observação:** se em `Variant: release` aparecer `Config: debug`, você esqueceu de trocar o `buildTypes.release` no `android/app/build.gradle.kts`.

---

## 12. adb — falando com o aparelho 🤖

> O `adb` fica em `platform-tools`, dentro do Android SDK. Se o comando não for reconhecido,
> adicione essa pasta ao PATH.

#### 📘 `adb devices`
```powershell
adb devices
```
- **O que faz:** lista os aparelhos e emuladores que o Android reconhece.
- **Quando usar:** quando o celular não aparece em `flutter devices` e você quer saber se o problema é do Flutter ou da conexão.
- **Saída esperada:**
  ```text
  List of devices attached
  1A2B3C4D5E      device
  ```
- **Observação:** se aparecer `unauthorized`, olhe a tela do celular: há um aviso pedindo para autorizar este computador. Se aparecer `offline`, desconecte e reconecte o cabo.

#### 📘 `adb install -r <arquivo.apk>`
```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```
- **O que faz:** instala o APK no aparelho conectado. O `-r` significa *reinstall*: substitui a versão que já estiver lá, preservando os dados.
- **Quando usar:** para testar no celular o APK de **release**, que o `flutter run` não instala.
- **Saída esperada:** `Performing Streamed Install` e depois `Success`.
- **Observação:** se der `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, o app instalado foi assinado com outra chave (por exemplo, a de debug). Desinstale antes.

#### 📘 `adb uninstall <applicationId>`
```powershell
adb uninstall br.com.estudos.foco
```
- **O que faz:** desinstala o app pelo identificador do pacote.
- **Quando usar:** ao trocar a chave de assinatura, ao limpar dados antigos ou ao resolver o erro de instalação incompatível acima.
- **Saída esperada:** `Success`.
- **Observação:** apaga também os dados do app — banco sqflite e preferências. É justamente isso que você quer ao testar a primeira execução.

#### 📘 `adb logcat`
```powershell
adb logcat
```
- **O que faz:** despeja no terminal o registro de eventos do sistema Android inteiro, em tempo real.
- **Quando usar:** para investigar travamentos que acontecem **fora** do Flutter — crash nativo, permissão negada pelo sistema, erro de plugin.
- **Saída esperada:** um fluxo contínuo de linhas com marca de tempo, nível (`D`, `I`, `W`, `E`) e a etiqueta do componente.
- **Observação:** é muita informação. Filtre pelo que interessa e pare com `Ctrl + C`:
  **🪟 Windows (PowerShell)**
  ```powershell
  adb logcat | Select-String "flutter"
  ```
  **🖥️ macOS / 🐧 Linux**
  ```bash
  adb logcat | grep flutter
  ```

#### 📘 `adb kill-server` e `adb start-server`
```powershell
adb kill-server
adb start-server
```
- **O que faz:** derruba e sobe de novo o processo servidor do `adb`, que faz a ponte entre o computador e os aparelhos.
- **Quando usar:** quando `adb devices` mostra lista vazia mesmo com o cabo conectado e a depuração USB ligada.
- **Saída esperada:** `* daemon started successfully`.
- **Observação:** é o "desliga e liga" do Android. Resolve uma boa parte dos casos de aparelho fantasma.

---

## 13. Build iOS 🍎

> 🍎 **SÓ NO MAC.** Todos os comandos desta seção e da próxima exigem **macOS + Xcode**.
> No Windows você pode ler, entender e até editar os arquivos da pasta `ios/` — mas
> **não** executar estes comandos e **não** gerar um `.ipa`. O que fazer enquanto isso está
> em [16.01 — Por que exige macOS](../modulos/16-build-ios/01-por-que-exige-macos.md).

#### ✅ `flutter build ipa` 🖥️
```bash
flutter build ipa
```
- **O que faz:** compila o app iOS, cria o arquivo de archive e exporta o pacote `.ipa`.
- **Quando usar:** para gerar o arquivo que será enviado ao TestFlight ou à App Store.
- **Saída esperada:** o archive em `build/ios/archive/Runner.xcarchive` e o pacote em `build/ios/ipa/<nome>.ipa`.
- **Observação:** exige assinatura válida: um certificado de distribuição e um provisioning profile correspondentes ao seu Bundle ID. Sem isso, o comando falha na etapa de exportação.

#### ✅ `flutter build ipa --export-method app-store-connect` 🖥️
```bash
flutter build ipa --export-method app-store-connect
```
- **O que faz:** exporta o `.ipa` já no formato aceito pelo App Store Connect.
- **Quando usar:** quando o destino é a loja ou o TestFlight.
- **Saída esperada:** o `.ipa` em `build/ios/ipa/`.
- **Observação:** o método de exportação decide quais aparelhos podem instalar o arquivo. Escolher o método errado produz um `.ipa` que a loja recusa.

#### ✅ `flutter build ipa --export-options-plist=<caminho>` 🖥️
```bash
flutter build ipa --export-options-plist=ios/ExportOptions.plist
```
- **O que faz:** usa um arquivo `.plist` com as opções de exportação detalhadas (time, método, perfis).
- **Quando usar:** em automação e CI, onde nada pode ser perguntado interativamente.
- **Saída esperada:** o `.ipa` em `build/ios/ipa/`.
- **Observação:** esse `.plist` contém o identificador do seu time — nos exemplos do curso ele aparece como `SEU_TEAM_ID`. Não versione o arquivo com o valor real.

#### ✅ `flutter build ipa --build-name=1.0.0 --build-number=1` 🖥️
```bash
flutter build ipa --build-name=1.0.0 --build-number=1
```
- **O que faz:** define, na hora do build, a versão visível e o número do build, sobrescrevendo o `version:` do `pubspec.yaml`.
- **Quando usar:** para reenviar uma correção sem mexer no arquivo, ou quando o número do build vem da esteira de CI.
- **Saída esperada:** o `.ipa` com `CFBundleShortVersionString = 1.0.0` e `CFBundleVersion = 1`.
- **Observação:** o App Store Connect **recusa** um build cujo número já foi enviado. O `--build-number` é o que você incrementa a cada reenvio.

#### ✅ `xcrun altool --upload-app ...` 🖥️
```bash
xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa \
  --apiKey SUA_API_KEY --apiIssuer SEU_ISSUER_ID
```
- **O que faz:** envia o `.ipa` para o App Store Connect pela linha de comando.
- **Quando usar:** em automação, quando você não quer abrir o Transporter à mão.
- **Saída esperada:** mensagens de progresso do envio e, no fim, a confirmação de que o pacote foi aceito para processamento.
- **Observação:** 🔴 `SUA_API_KEY` e `SEU_ISSUER_ID` são **credenciais reais** da sua conta Apple. Nunca escreva os valores num arquivo versionado nem os cole em um chat. Guarde-os como variáveis secretas do seu ambiente.

---

## 14. Xcode e CocoaPods 🍎

> 🍎 **SÓ NO MAC.** Toda esta seção exige macOS.

#### ✅ `open ios/Runner.xcworkspace` 🖥️
```bash
open ios/Runner.xcworkspace
```
- **O que faz:** abre o projeto iOS no Xcode.
- **Quando usar:** para definir o Bundle ID, escolher o time de assinatura, conferir capacidades e ver mensagens de erro nativas que o terminal não mostra.
- **Saída esperada:** o Xcode abre com o projeto `Runner` carregado.
- **Observação:** ⚠️ Abra **sempre o `.xcworkspace`**, nunca o `Runner.xcodeproj`. O `.xcodeproj` sozinho não enxerga as dependências nativas e o build falha.

#### ✅ `sudo gem install cocoapods` 🖥️
```bash
sudo gem install cocoapods
```
- **O que faz:** instala o CocoaPods, o gerenciador de dependências nativas escrito em Ruby.
- **Quando usar:** só quando algum plugin do projeto ainda não suportar o Swift Package Manager.
- **Saída esperada:** `Successfully installed cocoapods-<versão>`.
- **Observação:** ⚠️ O registro público do CocoaPods torna-se **somente-leitura em 2 de dezembro de 2026**; a ferramenta está em modo de manutenção. Desde o Flutter 3.44 o padrão é o SPM, e o Flutter só volta ao CocoaPods quando precisa.

#### ✅ `pod install` 🖥️
```bash
cd ios
pod install
```
- **O que faz:** lê o `Podfile` e instala as dependências nativas do projeto iOS.
- **Quando usar:** depois de adicionar ou remover um plugin que dependa de CocoaPods.
- **Saída esperada:** `Analyzing dependencies`, `Downloading dependencies`, `Pod installation complete!`.
- **Observação:** quem normalmente roda isso é o próprio `flutter build`/`flutter run`. Você só chama à mão ao investigar problema.

#### ✅ `pod repo update` 🖥️
```bash
pod repo update
```
- **O que faz:** atualiza o catálogo local de especificações de pods.
- **Quando usar:** quando o `pod install` reclama que não encontra uma versão que você sabe que existe.
- **Saída esperada:** mensagens de atualização do repositório. Pode demorar alguns minutos.
- **Observação:** com o registro ficando somente-leitura, esse catálogo deixará de receber novidades — mais um motivo para preferir SPM.

#### ✅ `pod deintegrate` 🖥️
```bash
cd ios
pod deintegrate
```
- **O que faz:** remove o CocoaPods do projeto iOS.
- **Quando usar:** quando **todos** os plugins do seu projeto já suportam Swift Package Manager e você quer simplificar o build.
- **Saída esperada:** confirmação da remoção da integração.
- **Observação:** confira plugin por plugin antes. Se um só ainda depender de CocoaPods, você quebra o build do iOS.

#### ✅ `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` 🖥️
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```
- **O que faz:** aponta as ferramentas de linha de comando para a instalação completa do Xcode.
- **Quando usar:** quando o `flutter doctor` avisa que só as Command Line Tools estão instaladas.
- **Saída esperada:** nenhuma saída; ele pede a senha do seu usuário do macOS.
- **Observação:** é um dos passos clássicos para o `flutter doctor` parar de reclamar do bloco Xcode.

#### ✅ `sudo xcodebuild -runFirstLaunch` 🖥️
```bash
sudo xcodebuild -runFirstLaunch
```
- **O que faz:** executa a configuração de primeira execução do Xcode, instalando os componentes que faltam.
- **Quando usar:** logo depois de instalar ou atualizar o Xcode.
- **Saída esperada:** mensagens de instalação dos componentes.
- **Observação:** pode demorar bastante na primeira vez. Deixe rodar até o fim.

#### ✅ `xcodebuild -license accept` 🖥️
```bash
sudo xcodebuild -license accept
```
- **O que faz:** aceita o contrato de licença do Xcode pela linha de comando.
- **Quando usar:** quando qualquer build iOS falha dizendo que a licença não foi aceita.
- **Saída esperada:** nenhuma saída em caso de sucesso.
- **Observação:** é o equivalente iOS do aceite de licenças do Android — com a diferença de que no iOS o passo continua existindo.

---

## 15. Git

> 📘 Todos os comandos desta seção vêm da documentação oficial do Git. Eles não dependem de
> Flutter e funcionam igual nos três sistemas — o que muda é apenas o terminal onde você digita.

#### `git --version`
```powershell
git --version
```
- **O que faz:** mostra a versão instalada do Git.
- **Quando usar:** ao montar o ambiente.
- **Saída esperada:** `git version 2.46.0.windows.1` (ou equivalente no seu sistema).
- **Observação:** se o comando não for reconhecido, o Git não está instalado ou não está no PATH.

#### `git init`
```powershell
git init
```
- **O que faz:** transforma a pasta atual em um repositório Git, criando a subpasta oculta `.git`.
- **Quando usar:** uma vez, no começo de um projeto novo.
- **Saída esperada:** `Initialized empty Git repository in .../.git/`.
- **Observação:** faça isso **antes** do primeiro commit e crie o `.gitignore` antes de adicionar qualquer arquivo — assim você nunca versiona um segredo por acidente.

#### `git status`
```powershell
git status
```
- **O que faz:** mostra em que branch você está, o que foi alterado, o que já está preparado para o commit e o que o Git ainda não conhece.
- **Quando usar:** o tempo todo. É o comando mais usado do Git.
- **Saída esperada:** seções `Changes to be committed`, `Changes not staged for commit` e `Untracked files`.
- **Observação:** se um arquivo de segredo aparecer em `Untracked files`, esse é o momento de colocá-lo no `.gitignore` — antes que ele entre no histórico.

#### `git add .` e `git add <arquivo>`
```powershell
git add .
git add lib/features/materias/data/materia_dao.dart
```
- **O que faz:** move alterações para a área de preparação (*staging*), escolhendo o que entra no próximo commit.
- **Quando usar:** `git add .` quando tudo que você mexeu pertence ao mesmo assunto; o caminho específico quando você quer separar em commits diferentes.
- **Saída esperada:** nenhuma saída em caso de sucesso — confira com `git status`.
- **Observação:** o `.` adiciona tudo que não está no `.gitignore`. Rode `git status` **antes** e leia a lista.

#### `git commit -m "mensagem"`
```powershell
git commit -m "Adiciona cronometro da sessao de estudo"
```
- **O que faz:** grava no histórico as alterações preparadas, com uma mensagem que explica o porquê.
- **Quando usar:** sempre que uma parte do trabalho fizer sentido sozinha.
- **Saída esperada:** `[main a1b2c3d] Adiciona cronometro da sessao de estudo` seguido do número de arquivos e linhas alteradas.
- **Observação:** escreva a mensagem no imperativo e diga o **porquê**, não o "o quê" (o diff já mostra o quê).

#### `git log --oneline`
```powershell
git log --oneline
```
- **O que faz:** lista os commits, um por linha, com o identificador curto e a mensagem.
- **Quando usar:** para achar rapidamente um ponto do histórico.
- **Saída esperada:**
  ```text
  a1b2c3d Adiciona cronometro da sessao de estudo
  9f8e7d6 Cria tabela de materias no sqflite
  ```
- **Observação:** saia da visualização com `q`.

#### `git diff`
```powershell
git diff
```
- **O que faz:** mostra, linha a linha, o que mudou e ainda não foi preparado.
- **Quando usar:** antes de `git add`, para revisar o próprio trabalho.
- **Saída esperada:** blocos com `-` (linha removida) e `+` (linha adicionada).
- **Observação:** para ver o que já está preparado, use `git diff --staged`. Saia com `q`.

#### `git branch` e `git switch`
```powershell
git branch
git switch -c feature/cronometro
git switch main
```
- **O que faz:** `git branch` lista os branches; `git switch -c <nome>` cria um novo e já muda para ele; `git switch <nome>` muda para um existente.
- **Quando usar:** ao começar uma funcionalidade nova, para não bagunçar o `main`.
- **Saída esperada:** `Switched to a new branch 'feature/cronometro'`.
- **Observação:** commite ou guarde o que está pendente antes de trocar de branch.

#### `git merge <branch>`
```powershell
git switch main
git merge feature/cronometro
```
- **O que faz:** traz para o branch atual o trabalho feito no branch indicado.
- **Quando usar:** quando a funcionalidade está pronta e testada.
- **Saída esperada:** `Fast-forward` ou um resumo do commit de mesclagem.
- **Observação:** se os dois branches alteraram a mesma linha, o Git para e marca o conflito no arquivo com `<<<<<<<`, `=======` e `>>>>>>>`. Edite à mão, apague os marcadores, `git add` e conclua com `git commit`.

#### `git restore <arquivo>` e `git restore --staged <arquivo>`
```powershell
git restore lib/main.dart
git restore --staged lib/main.dart
```
- **O que faz:** o primeiro **descarta** as alterações não salvas de um arquivo, voltando ao último commit. O segundo tira o arquivo da área de preparação sem perder o que você escreveu.
- **Quando usar:** quando você bagunçou um arquivo e quer recomeçar, ou quando adicionou algo ao commit por engano.
- **Saída esperada:** nenhuma saída em caso de sucesso.
- **Observação:** ⚠️ `git restore <arquivo>` **apaga** o que você escreveu e não foi commitado. Não há desfazer.

#### `git rm --cached <arquivo>`
```powershell
git rm --cached android/key.properties
```
- **O que faz:** tira o arquivo do controle de versão **mantendo-o no disco**.
- **Quando usar:** quando você percebeu que versionou um segredo. Faça isso, acrescente o arquivo ao `.gitignore` e commite.
- **Saída esperada:** `rm 'android/key.properties'`.
- **Observação:** ⚠️ Isso remove o arquivo dos commits **futuros**, mas ele continua no histórico antigo. Se o segredo já foi enviado a um repositório remoto, considere-o vazado: troque a senha e gere uma chave nova.

#### `git remote add origin <url>` e `git push -u origin main`
```powershell
git remote add origin https://github.com/<seu-usuario>/<seu-repositorio>.git
git push -u origin main
```
- **O que faz:** o primeiro cadastra o endereço do repositório remoto com o apelido `origin`; o segundo envia o branch `main` e passa a lembrar essa ligação (`-u`).
- **Quando usar:** ao publicar seu projeto pela primeira vez.
- **Saída esperada:** contagem de objetos enviados e a confirmação `branch 'main' set up to track 'origin/main'`.
- **Observação:** dos próximos envios em diante basta `git push`. Confira o `.gitignore` **antes** do primeiro push.

#### `git pull` e `git clone <url>`
```powershell
git pull
git clone https://github.com/<seu-usuario>/<seu-repositorio>.git
```
- **O que faz:** `git pull` traz e mescla o que mudou no remoto; `git clone` baixa um repositório inteiro, com todo o histórico, para uma pasta nova.
- **Quando usar:** `pull` ao voltar a trabalhar em outra máquina; `clone` ao pegar um projeto pela primeira vez.
- **Saída esperada:** `Already up to date.` ou o resumo do que veio; no clone, `Cloning into '<repositorio>'...`.
- **Observação:** depois de clonar um projeto Flutter, rode `flutter pub get` — a pasta de dependências não é versionada.

---

## 16. Windows — comandos do sistema 🪟

#### ✅ `start ms-settings:developers`
```powershell
start ms-settings:developers
```
- **O que faz:** abre direto a página **Para desenvolvedores** das Configurações do Windows.
- **Quando usar:** quando o `flutter pub get` em um projeto com plugins falhar com
  `Building with plugins requires symlink support. Please enable Developer Mode in your system settings.`
- **Saída esperada:** a janela de Configurações abre na seção certa. Ligue a chave **Modo de Desenvolvedor** e confirme.
- **Observação:** esse modo permite ao Windows criar *symlinks* (atalhos internos do sistema de arquivos) sem privilégio de administrador — que é exatamente o que o Flutter precisa para ligar os plugins ao projeto.

#### 📘 `where.exe flutter`
```powershell
where.exe flutter
```
- **O que faz:** mostra o caminho completo do executável `flutter` que o PowerShell está achando pelo PATH.
- **Quando usar:** quando você suspeita de duas instalações do Flutter, ou quer confirmar que o SDK está mesmo em `C:\src\flutter\bin`.
- **Saída esperada:** uma ou mais linhas, por exemplo `C:\src\flutter\bin\flutter.bat`.
- **Observação:** ⚠️ Se o caminho mostrado tiver **acento** (como `C:\Users\Usuário\Documents\flutter`), esse é o seu problema. Mova o SDK para `C:\src\flutter` e atualize o PATH. Veja [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md).

#### 📘 `$env:Path -split ';'`
```powershell
$env:Path -split ';'
```
- **O que faz:** imprime uma por linha todas as pastas do PATH da sessão atual.
- **Quando usar:** quando um comando "não é reconhecido" e você quer conferir se a pasta dele está listada.
- **Saída esperada:** uma lista de caminhos, uma pasta por linha.
- **Observação:** isso mostra o PATH **daquela janela**. Se você acabou de alterar a variável no Windows, feche e abra o PowerShell de novo para ver o valor novo.

#### 📘 `java -version`
```powershell
java -version
```
- **O que faz:** mostra a versão do Java instalada e visível no PATH.
- **Quando usar:** antes de qualquer build Android, e sempre que o Gradle reclamar de versão de JDK.
- **Saída esperada:** três linhas começando por `openjdk version "17.0.18"`.
- **Observação:** o curso usa **JDK 17 (Temurin)**. Versões mais novas podem brigar com a combinação AGP 9.1.0 / Gradle 9.3.1 gerada pelo Flutter 3.47.

---

## 🧯 Sequências que resolvem a maioria dos problemas

### Sequência 1 — "não sei o que está acontecendo"
```powershell
flutter clean
flutter pub get
flutter run
```
Apaga o cache de build, rebaixa as dependências e sobe o app do zero.

### Sequência 2 — "antes de commitar"
```powershell
dart format .
flutter analyze
flutter test
git status
```
Formata, procura problemas sem rodar, roda os testes e mostra o que vai entrar no commit.

### Sequência 3 — identidade visual e release 🤖
```powershell
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter clean
flutter pub get
flutter build appbundle
```
Esta é a ordem validada. O `flutter clean` no meio existe porque os geradores mexem em recursos
nativos e o Gradle pode reaproveitar cache antigo.

### Sequência 4 — ambiente do zero 🪟
```powershell
flutter --version
flutter doctor -v
flutter devices
```
Confirma a versão, examina o ambiente — inclusive o estado das licenças do Android, na linha
`All Android licenses accepted.` — e lista o que está conectado. O passo a passo completo está em
[02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md).

---

## 🧭 Para onde ir agora

| Você quer... | Vá para |
|---|---|
| Entender uma palavra desta página | [Glossário](glossario.md) |
| Decifrar uma mensagem de erro | [Erros comuns](erros-comuns.md) |
| Conferir o ambiente item por item | [checklists/ambiente-android.md](../checklists/ambiente-android.md) |
| Conferir o que dá para fazer de iOS no Windows | [checklists/ambiente-ios.md](../checklists/ambiente-ios.md) |
| Rodar o build Android com checklist | [checklists/build-android.md](../checklists/build-android.md) |
| Rodar o build iOS com checklist 🍎 | [checklists/build-ios.md](../checklists/build-ios.md) |
| Ler a documentação oficial | [Referências oficiais](referencias-oficiais.md) |

---

⬅️ [Voltar ao índice do curso](../README.md)
