# Exercícios — Módulo 16: Build e distribuição iOS

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. 🪟 Tudo roda no Windows, exceto os passos marcados 🍎. Rode `flutter analyze` e `git diff` antes de consultar o gabarito.

<a id="m16-e01"></a>
## M16-E01 — Os quatro motivos · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Explicar a exigência de macOS | Fácil | 15 min | Sim |
Escreva `docs/por-que-mac.md` com um parágrafo técnico para cada motivo: toolchain compilada só para macOS, SDKs iOS distribuídos dentro do Xcode, assinatura dependente do chaveiro e contrato de licença do Xcode. **Esperado:** quatro causas distintas, e você consegue dizer qual delas *sumiria* se a Apple licenciasse o Xcode para Windows (e por que as outras três continuariam de pé). [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e01)

<a id="m16-e02"></a>
## M16-E02 — Bundle ID nas três configurações · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Trocar o identificador do Foco | Média | 25 min | Sim |
Troque `com.example.foco` por `br.com.estudos.foco` em `ios/Runner.xcodeproj/project.pbxproj`, nas três ocorrências de `PRODUCT_BUNDLE_IDENTIFIER` do target **Runner** (Debug, Release, Profile) e nas três de **RunnerTests** (`br.com.estudos.foco.RunnerTests`). **Teste:** `git diff` mostra exatamente seis linhas alteradas, e `ios/Runner/Info.plist` continua com `$(PRODUCT_BUNDLE_IDENTIFIER)` — sem nenhum valor literal. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e02)

<a id="m16-e03"></a>
## M16-E03 — Deployment Target divergente · Correção de bugs
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Alinhar Podfile e pbxproj | Média | 20 min | Sim |
No Foco, `ios/Podfile` declara `platform :ios, '12.0'` e o `project.pbxproj` declara `IPHONEOS_DEPLOYMENT_TARGET = 13.0` nas três configurações. Alinhe tudo em `13.0`. **Esperado:** você explica em uma frase por que essa divergência produz avisos em massa no `pod install` sem que a mensagem cite a palavra "divergência". [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e03)

<a id="m16-e04"></a>
## M16-E04 — Ícone iOS sem alfa · Aplicação
Ponha um PNG 1024×1024 sem cantos arredondados em `assets/icone/foco.png`, configure `flutter_launcher_icons` com `image_path` e `remove_alpha_ios: true`, e rode `dart run flutter_launcher_icons`. **Teste:** `AppIcon.appiconset` ganha cerca de 15 PNGs mais o `Contents.json`, e `Icon-App-1024x1024@1x.png` não tem canal alfa — o que evita o `ITMS-90717` no upload. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e04)

<a id="m16-e05"></a>
## M16-E05 — Textos de permissão que passam na revisão · Reflexão
Escreva em `docs/permissoes-ios.md` os textos de `NSCameraUsageDescription` e `NSPhotoLibraryAddUsageDescription` para o Foco (foto da capa da matéria; salvar o gráfico semanal na galeria) e justifique, em um parágrafo cada, por que "Este app precisa da câmera" seria reprovado. **Esperado:** cada texto diz *para quê*, em português, e você explica por que declarar `NSMicrophoneUsageDescription` sem usar o microfone é risco de rejeição. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e05)

<a id="m16-e06"></a>
## M16-E06 — Versão literal no Info.plist · Correção de bugs
O `Info.plist` do Foco tem `<string>1.0.0</string>` em `CFBundleShortVersionString` e `<string>1</string>` em `CFBundleVersion`: subir o `pubspec.yaml` para `version: 1.1.0+3` não muda nada no app iOS. Troque pelas variáveis corretas. **Teste:** após `flutter build ios --config-only`, o `ios/Flutter/Generated.xcconfig` mostra `FLUTTER_BUILD_NAME=1.1.0` e `FLUTTER_BUILD_NUMBER=3`. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e06)

<a id="m16-e07"></a>
## M16-E07 — Gratuita ou Developer Program · Reflexão
Preencha `docs/conta-apple.md` com a sua decisão, comparando as duas contas em pelo menos seis critérios e dizendo a **data** em que você vai pagar (ou não). **Esperado:** a justificativa cita explicitamente o limite de 7 dias do app instalado, o teto de 3 aparelhos e a ausência de TestFlight — e, se você escolheu organização, o D-U-N-S como gargalo de 5 a 30 dias. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e07)

<a id="m16-e08"></a>
## M16-E08 — Quatro erros de assinatura · Diagnóstico
Para cada mensagem, diga qual das cinco peças (chave privada, CSR, certificado, App ID, provisioning profile) está faltando ou desatualizada e qual é a correção: `Signing for "Runner" requires a development team`; `No profiles for 'br.com.estudos.foco' were found`; `doesn't include signing certificate`; `Provisioning profile doesn't include device`. **Esperado:** a última exige **regerar** o profile depois de cadastrar o UDID, não só baixá-lo de novo. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e08)

<a id="m16-e09"></a>
## M16-E09 — O identificador do seu app · Reflexão
Escolha o Bundle ID do **seu** projeto pessoal em domínio invertido e justifique o domínio usado, em três a cinco frases. **Esperado:** sem underscore, sem `com.example`, e você explica o que exatamente se perde ao trocá-lo depois da publicação (ficha, URL, avaliações, instalações, atualização dos usuários antigos). [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e09)

<a id="m16-e10"></a>
## M16-E10 — Credenciais fora do Git · Aplicação
Acrescente ao `.gitignore` do Foco `*.p12`, `*.cer`, `*.mobileprovision`, `*.certSigningRequest` e `simbolos/`, com um comentário de aviso sobre os símbolos. **Teste:** crie `teste.p12` vazio na raiz e confirme que `git status` o ignora e que `git check-ignore -v teste.p12` aponta a linha nova. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e10)

<a id="m16-e11"></a>
## M16-E11 — ExportOptions e roteiro de build · Aplicação
Crie `ios/ExportOptions.plist` com `method` = `app-store-connect`, `teamID`, `uploadSymbols` e `signingStyle` = `automatic`, e escreva em `ferramentas/build-ios.sh` a chamada de `flutter build ipa --release` com `--obfuscate`, `--split-debug-info=simbolos/1.0.0+1` e `--export-options-plist`. **Teste:** o arquivo não contém o valor antigo `app-store`, e você sabe dizer o caminho exato do archive e do IPA gerados. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e11)

<a id="m16-e12"></a>
## M16-E12 — `PhaseScriptExecution failed` · Diagnóstico
Você rodou `flutter pub add connectivity_plus`, `flutter pub get` e mandou compilar; o Xcode parou em `Command PhaseScriptExecution failed with a nonzero exit code`. Explique por que pesquisar essa frase na internet não resolve, onde está a mensagem real e quais duas causas testar, nesta ordem. **Esperado:** Report Navigator (⌘9) primeiro; depois `cd ios && pod install`; e a confirmação de que o projeto foi aberto pelo `.xcworkspace`. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e12)

<a id="m16-e13"></a>
## M16-E13 — Build number e o `ITMS-4238` · Diagnóstico
Histórico do Foco: `1.0.0+1` enviado e **descartado**, `1.0.0+2` aprovado no TestFlight. Agora sai a correção `1.0.1`. Diga qual linha `version:` escrever no `pubspec.yaml` e por que `1.0.1+1` e `1.0.1+2` falham no upload. **Esperado:** você afirma que o número de um build descartado **não** volta a ficar livre e adota a regra de nunca reiniciar o `+N`. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e13)

<a id="m16-e14"></a>
## M16-E14 — Do `pubspec.yaml` ao TestFlight · Revisão cumulativa
Escreva `docs/testflight.md` com o roteiro completo de um envio do Foco: subir o `+N`, gerar ícone, conferir `ITSAppUsesNonExemptEncryption`, `pod install`, `flutter build ipa`, **Validate App**, upload, guardar os dSYM **e** os símbolos do Dart, notas de teste e convite do grupo interno. **Esperado:** cada passo tem um critério objetivo de "deu certo", e o roteiro só promove ao teste externo o build que sobreviveu ao interno. [🔑 Gabarito](../gabaritos/16-build-ios.md#m16-e14)

[Módulo](../modulos/16-build-ios/README.md)
