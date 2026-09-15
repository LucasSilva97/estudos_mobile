# Gabarito — Módulo 15: Build e distribuição iOS

> Compare depois de resolver os [exercícios](../exercicios/15-build-ios.md).

<a id="m15-e01"></a>
## M15-E01
```text
docs/por-que-mac.md
1. Toolchain: clang, ld, codesign, xcodebuild, actool e ibtool são binários Mach-O
   distribuídos só dentro do Xcode, só para macOS.
2. SDK: o iPhoneOS.sdk (UIKit, Metal, AVFoundation) vive dentro do pacote do Xcode;
   não existe download separado para outro sistema.
3. Assinatura: o codesign busca a chave privada no Keychain do macOS, e nenhum app
   iOS roda em aparelho sem assinatura válida — nem em debug.
4. Licença: o Xcode and Apple SDKs Agreement autoriza o uso apenas em hardware Apple.
```
Sumiria só o motivo 4: licença é permissão, não porte — os binários continuariam Mach-O, o SDK continuaria dentro do `.xip` e o `codesign` continuaria dependendo do chaveiro.

<a id="m15-e02"></a>
## M15-E02
```diff
 ios/Runner.xcodeproj/project.pbxproj
-  PRODUCT_BUNDLE_IDENTIFIER = com.example.foco;              (Debug/Release/Profile do Runner)
+  PRODUCT_BUNDLE_IDENTIFIER = br.com.estudos.foco;
-  PRODUCT_BUNDLE_IDENTIFIER = com.example.foco.RunnerTests;  (Debug/Release/Profile de RunnerTests)
+  PRODUCT_BUNDLE_IDENTIFIER = br.com.estudos.foco.RunnerTests;
```
O `Info.plist` continua com `$(PRODUCT_BUNDLE_IDENTIFIER)`: valor literal ali faz o app divergir do projeto sem erro de build.

<a id="m15-e03"></a>
## M15-E03
```ruby
# ios/Podfile
platform :ios, '13.0'
```
```text
# ios/Runner.xcodeproj/project.pbxproj — nas três configurações
IPHONEOS_DEPLOYMENT_TARGET = 13.0;
```
O defeito: o Podfile ficou em `12.0` e o projeto em `13.0`. O `pod install` propaga o `12.0` do Podfile para **cada** pod, e cada um emite o próprio aviso de deployment target — o log enche de dezenas de linhas por dependência, nenhuma delas dizendo que os dois arquivos discordam.

<a id="m15-e04"></a>
## M15-E04
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  ios: true
  android: true
  image_path: "assets/icone/foco.png"
  remove_alpha_ios: true   # o iOS rejeita canal alfa no ícone da loja
```
```bash
dart run flutter_launcher_icons
```
O PNG entra sem cantos arredondados: o iOS aplica a máscara sozinho, e cantos já desenhados viram cantos duplos.

<a id="m15-e05"></a>
## M15-E05
```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Para você tirar uma foto e usar como capa da matéria.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Para salvar na sua galeria o gráfico semanal dos seus estudos.</string>
```
"Este app precisa da câmera" descreve o app, não o benefício: o revisor lê esse texto dentro da caixa de diálogo e reprova quando ele não responde *para quê*. E declarar `NSMicrophoneUsageDescription` sem usar o microfone cria uma pergunta que você não consegue responder — "um plugin trouxe" não é justificativa aceita, e a chave sobrando vira motivo de rejeição.

<a id="m15-e06"></a>
## M15-E06
```xml
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>

<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
```
O defeito era o valor literal: ele congela a versão do iOS e faz o `pubspec.yaml` valer só para o Android, sem nenhum aviso.

<a id="m15-e07"></a>
## M15-E07
```text
docs/conta-apple.md — critérios: custo, validade do app instalado (7 dias × 1 ano),
aparelhos (3 × 100 por tipo), App IDs por semana, TestFlight, App Store,
push/iCloud/Sign in with Apple, distribuição Ad Hoc.
```
Resposta de referência: enquanto o objetivo for aprender e testar no simulador ou no próprio iPhone, a conta gratuita basta. Os US$ 99 se pagam no dia em que você precisa de TestFlight — o limite de **7 dias** derruba o app do seu iPhone toda semana, as **3 vagas** de aparelho não permitem mandar para testadores, e **não existe TestFlight** sem o Developer Program. Pagar cedo demais queima meses da assinatura: marque a data para o fim do módulo 16, quando houver build para enviar. Se a escolha for organização, peça o **D-U-N-S** antes de tudo — são 5 a 30 dias, e ele é o gargalo do cadastro inteiro.

<a id="m15-e08"></a>
## M15-E08
| Mensagem | Peça | Correção |
|---|---|---|
| `Signing for "Runner" requires a development team` | App ID / equipe não selecionada | Xcode → Runner → Signing & Capabilities → Team |
| `No profiles for 'br.com.estudos.foco' were found` | Provisioning profile ausente, vencido ou de outro Bundle ID | Confira o Bundle ID e gere o profile; profiles valem 1 ano |
| `doesn't include signing certificate` | Certificado — revogado, de outro Mac, ou sem a chave privada | `security find-identity -v -p codesigning`; importe o `.p12`, não o `.cer` |
| `Provisioning profile doesn't include device` | Provisioning profile desatualizado | Cadastre o UDID **e regere** o profile |
Cadastrar o UDID não atualiza profiles já emitidos: o profile é um documento assinado com a lista de aparelhos congelada no instante em que foi gerado — baixá-lo de novo traz a mesma lista.

<a id="m15-e09"></a>
## M15-E09
```text
Escolhido: br.com.estudos.foco  (domínio estudos.com.br, invertido)
```
Resposta de referência: use um domínio que seja seu, invertido, só com letras, dígitos, ponto e hífen — underscore é inválido e `com.example` é recusado no envio. Depois da publicação o Bundle ID é imutável: trocá-lo cria um app **novo** na App Store, com ficha, URL, avaliações e contagem de instalações zeradas. E quem já tinha o app antigo não recebe a atualização — precisa baixar outro app, e você perde a base instalada.

<a id="m15-e10"></a>
## M15-E10
```gitignore
# ── Assinatura iOS: NUNCA versionar ───────────────────────────
*.p12
*.cer
*.mobileprovision
*.certSigningRequest

# ⚠️ Símbolos de ofuscação: sem eles os crashes desta versão
#    ficam ilegíveis PARA SEMPRE. Guarde fora do Git, com backup.
simbolos/
```
```bash
git check-ignore -v teste.p12
# .gitignore:2:*.p12    teste.p12
```
Certificado versionado é certificado comprometido; os símbolos ficam de fora por serem artefato de build, não código — mas precisam de backup próprio.

<a id="m15-e11"></a>
## M15-E11
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>SEU_TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```
```bash
#!/usr/bin/env bash
# ferramentas/build-ios.sh — 🍎 roda no Mac (ou em CI com runner macOS)
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build ipa --release \
  --obfuscate \
  --split-debug-info=simbolos/1.0.0+1 \
  --export-options-plist=ios/ExportOptions.plist
```
Archive em `build/ios/archive/Runner.xcarchive` e IPA em `build/ios/ipa/foco.ipa`; sem `--export-options-plist` o Flutter gera só o archive e para, pedindo que você exporte pelo Organizer.

<a id="m15-e12"></a>
## M15-E12
```text
1. ⌘9 (Report Navigator) → última build → etapa em VERMELHO
   → ícone de expandir transcrição (à direita) → mensagem real
2. cd ios && pod install
3. Confirmar que o Xcode abriu ios/Runner.xcworkspace, não .xcodeproj
```
Resposta de referência: `PhaseScriptExecution failed` não é o erro, é o Xcode dizendo que *algum* script saiu com código diferente de zero — pesquisar essa frase devolve centenas de causas, todas verdadeiras para outra pessoa. A mensagem real está no Report Navigator. O que mudou aqui foi um plugin: o `connectivity_plus` acrescentou um pod que o `pod install` ainda não instalou. Se persistir depois disso, o projeto foi aberto pelo `.xcodeproj`, que ignora os pods.

<a id="m15-e13"></a>
## M15-E13
```yaml
# pubspec.yaml
version: 1.0.1+3
```
`1.0.1+1` e `1.0.1+2` falham porque o `CFBundleVersion` é monotônico e definitivo dentro do app: o `+1` foi **descartado** e o número **não** volta a ficar livre, e o `+2` está publicado no TestFlight — os dois devolvem `ERROR ITMS-4238` depois do upload inteiro. A regra que evita isso é nunca reiniciar o `+N`, mesmo quando a versão muda.

<a id="m15-e14"></a>
## M15-E14
| Passo | Critério objetivo de "deu certo" |
|---|---|
| Subir o `+N` no `pubspec.yaml` | `+N` maior que todo build já enviado; a pasta `simbolos/<versão>` ainda não existe |
| Gerar o ícone | `Icon-App-1024x1024@1x.png` no `AppIcon.appiconset`, sem canal alfa |
| Conferir `ITSAppUsesNonExemptEncryption` | Chave `<false/>` no `Info.plist`; nenhum "Missing Compliance" após o upload |
| `cd ios && pod install` | Termina sem erro e o `Podfile.lock` fica coerente com o `pubspec.lock` |
| `flutter build ipa --release --obfuscate --split-debug-info=simbolos/<versão>` | Imprime `Built IPA to build/ios/ipa/foco.ipa` |
| Validate App (Organizer) | "No issues" — **antes** do upload, não depois |
| Upload | Sai de *Processing* em até 2 h e aparece no TestFlight; nenhum e-mail de falha |
| Guardar os símbolos | `simbolos/<versão>` com os `.symbols` do Dart **e** os `.dSYM` copiados do `.xcarchive` |
| Notas de teste | Passos numerados e reproduzíveis, mais a conta de teste em Information for Review |
| Grupo interno | Convite aceito e o build abre no iPhone de pelo menos um testador |
| Teste externo | Só promove o build que sobreviveu ao interno; a revisão da Apple leva 1 a 2 dias |
O interno é imediato e sem revisão: é ali que você descobre que o app trava na primeira tela, antes de expor isso a 10 000 pessoas.
