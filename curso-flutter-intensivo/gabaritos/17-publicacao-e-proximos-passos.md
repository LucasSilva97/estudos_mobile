# Gabarito — Módulo 17: Publicação e próximos passos

> Compare depois de resolver os [exercícios](../exercicios/17-publicacao-e-proximos-passos.md).

<a id="m17-e01"></a>
## M17-E01
```kotlin
// android/app/build.gradle.kts — corrige as etapas 2 e 3 do script
android {
    defaultConfig { applicationId = "br.com.estudos.foco" }
    buildTypes {
        release { signingConfig = signingConfigs.getByName("release") }
    }
}
```
```gitignore
key.properties
*.jks
*.keystore
```
O script reprova `signingConfigs.getByName("debug")` no `release` porque a Play recusa AAB assinado com a chave de depuração.

<a id="m17-e02"></a>
## M17-E02
```text
NOME (max 30):        Foco: Organizador de Estudos    (28)
DESCRICAO CURTA (80): Organize matérias, cronometre sessões e acompanhe sua meta semanal.  (67)
DESCRICAO COMPLETA (max 4000):
O Foco transforma tempo de estudo em progresso visível.
- Cadastre suas matérias e mantenha tudo em um só lugar.
- Cronometre cada sessão e veja os minutos somarem na matéria certa.
- Defina uma meta semanal em minutos e acompanhe o quanto já cumpriu.
Seus dados ficam no seu aparelho: sem cadastro, sem login.

POLITICA DE PRIVACIDADE: https://<seu-usuario>.github.io/foco/privacidade.html
IMAGENS: icone-512x512.png · destaque-1024x500.png · captura-celular-1..4.png
```
```powershell
$curta = 'Organize matérias, cronometre sessões e acompanhe sua meta semanal.'
$curta.Length   # 67
```
O limite é de caracteres, não de palavras: meça antes de colar, porque o formulário recusa e você perde o preenchimento.

<a id="m17-e03"></a>
## M17-E03
```text
<uses-permission android:name="android.permission.INTERNET" />
  única permissão do manifesto principal do Foco (o template só a injeta
  nos manifestos de debug e profile; no release ela é declarada à mão).

1. Coleta ou compartilha dados? NÃO — matérias, sessões e metas ficam no
   aparelho (sqflite + shared_preferences); nada sai para servidor.
2. Criptografia em trânsito? SIM — a busca de trilhas usa
   https://jsonplaceholder.typicode.com e não envia dado do usuário.
3. Permite pedir exclusão? SIM — desinstalar ou limpar os dados do app
   apaga tudo, porque não existe cópia remota.
```
Declarar "não coleta" com `CAMERA` ou `ACCESS_FINE_LOCATION` no manifesto é a contradição que a Google checa: permissão sem uso se remove, não se justifica.

<a id="m17-e04"></a>
## M17-E04
```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da câmera para você anexar a foto do quadro ao material da matéria.</string>
```
```powershell
dart run tool/checar_info_plist.dart
$LASTEXITCODE   # 0
```
O defeito era o texto genérico: 30 caracteres, a expressão "precisamos de acesso" e nenhuma finalidade — o novo diz o que a câmera faz dentro do Foco.

<a id="m17-e05"></a>
## M17-E05
```text
version: 1.4.2+37
  🤖 versionName = 1.4.2   versionCode = 37
  🍎 CFBundleShortVersionString = 1.4.2   CFBundleVersion = 37

Reenvio após rejeição: 1.4.2+38 — mesmo nome, binário novo.
```
O `+N` identifica o binário, não a versão: um número já enviado nunca volta a ficar livre — nem o de um build rejeitado, nem ao subir o MAJOR.

<a id="m17-e06"></a>
## M17-E06
```powershell
.\tool\nova-versao.ps1 -Tipo patch -Simular   # propõe 1.4.2+37 -> 1.4.3+38, sem escrever nada
.\tool\nova-versao.ps1 -Tipo patch
git show v1.4.3                               # tagger, data e mensagem: tag anotada
git push origin main v1.4.3
```
```markdown
## [1.4.3] — 2026-09-14

### Corrigido
- O app travava ao excluir a última matéria
```
Com `git status --porcelain` devolvendo qualquer linha o script sai com `1`: uma tag precisa apontar para um estado conhecido.

<a id="m17-e07"></a>
## M17-E07
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  qualidade:
    runs-on: ubuntu-latest   # 1× a cota; macOS custaria 10× sem benefício
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
          channel: stable
          cache: true
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --no-fatal-infos
      - run: flutter test --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: cobertura
          path: coverage/lcov.info
```
Sem `--set-exit-if-changed`, o `dart format` formata os arquivos no runner e sai com `0`: o passo fica verde sempre e não verifica nada.

<a id="m17-e08"></a>
## M17-E08
```text
🤖 Android: interromper o rollout da 1.4.2 (para de espalhar), reativar a
   1.4.1 para quem ainda não atualizou e publicar a 1.4.3.
🍎 iOS: não há rollback, só pausar o phased release; resta publicar a 1.4.3
   e esperar a revisão humana, que leva de horas a dias.

Nas duas lojas quem já atualizou continua na 1.4.2: interromper rollout e
reativar versão antiga impedem novas instalações, não desfazem as feitas.
```
```bash
git checkout -b hotfix/1.4.3 v1.4.2   # da TAG, não da main
# corrige só o travamento; pubspec.yaml -> version: 1.4.3+38
git commit -am "Corrige travamento ao excluir a última matéria"
git tag -a v1.4.3 -m "Hotfix: travamento na exclusão"
git checkout main && git merge hotfix/1.4.3
git push origin main v1.4.3
```
Partir da tag entrega a versão publicada mais a correção; partir da `main` levaria junto tudo que ainda está pela metade.

<a id="m17-e09"></a>
## M17-E09
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\chaves\foco-upload.jks")) |
    Set-Clipboard
# Settings → Secrets and variables → Actions → New repository secret
# ANDROID_KEYSTORE_B64 · ANDROID_STORE_PASSWORD · ANDROID_KEY_PASSWORD · ANDROID_KEY_ALIAS
```
```yaml
- name: Restaurar o keystore
  env:
    KEYSTORE_B64: ${{ secrets.ANDROID_KEYSTORE_B64 }}
  run: |
    echo "$KEYSTORE_B64" | base64 -d > "$RUNNER_TEMP/upload.jks"
    if [ ! -s "$RUNNER_TEMP/upload.jks" ]; then
      echo "Keystore vazio ou corrompido — confira o secret."
      exit 1
    fi
```
O GitHub mascara só o valor exato do secret: um `echo` de algo derivado dele sai inteiro num log que, em repositório público, é permanente.

<a id="m17-e10"></a>
## M17-E10
```dart
// lib/core/monitoramento/observador_de_rotas.dart
void _registrar(String acao, Route<dynamic> rota) {
  final String nome = rota.settings.name ?? 'sem-nome';
  Telemetria.instancia.rastro('$acao $nome');
  Telemetria.instancia.telaAtual(nome);
}

// lib/core/monitoramento/telemetria.dart — precisa de import 'dart:ui';
static Future<void> configurar() async {
  FlutterError.onError = (FlutterErrorDetails detalhes) {
    FlutterError.presentError(detalhes);
    FirebaseCrashlytics.instance.recordFlutterFatalError(detalhes);
  };
  PlatformDispatcher.instance.onError = (Object erro, StackTrace pilha) {
    FirebaseCrashlytics.instance.recordError(erro, pilha, fatal: true);
    return true;
  };
}
```
Dois defeitos: `settings.arguments` carrega o que o usuário digitou, e sem `PlatformDispatcher.instance.onError` o erro do `Future` sem `catch` nunca chega ao painel.

<a id="m17-e11"></a>
## M17-E11
```text
Falta enviar os símbolos daquela versão exata:

  🤖 firebase crashlytics:symbols:upload --app=<APP_ID> simbolos/v1.4.2
  🍎 os mesmos + os dSYM:
     ./ios/Pods/FirebaseCrashlytics/upload-symbols \
       -gsp ios/Runner/GoogleService-Info.plist -p ios \
       build/ios/archive/Runner.xcarchive/dSYMs

Para não repetir: o passo "Arquivar símbolos" do release.yml guarda
simbolos/ e mapping.txt com retention-days: 90.
```
Os símbolos só servem ao build que os gerou: perdidos os da v1.4.2, os crashes dela ficam ilegíveis para sempre — recompilar a mesma tag não os reproduz.

<a id="m17-e12"></a>
## M17-E12
```text
AUTOMATIZO
  analyze/test a cada push — barato (Ubuntu 1×) e barra o quebrado antes da revisão
  build em tag             — roteiro idêntico toda vez, sem passo esquecido
  envio à faixa interna    — entrega a testadores, não ao público

DEIXO MANUAL
  texto de "Novidades"     — escrita para o usuário, não etapa de build
  rollout gradual          — depende de olhar crash e avaliação por 24 h
  promoção para produção   — decisão humana, com os números na mesa

MINUTOS DO MÊS (Free privado: 2 000)
  30 pushes × 3 min  Ubuntu ×  1 =  90
   4 tags   × 8 min  Ubuntu ×  1 =  32
   4 tags   × 12 min macOS  × 10 = 480   → total ≈ 602
```
O iOS é 80% da conta por causa do multiplicador 10×: por isso roda só em tag — cortar os testes pouparia 90 minutos e devolveria o bug ao usuário.

<a id="m17-e13"></a>
## M17-E13
```text
Cada "não" é o endereço de um módulo: 1→05, 2→08, 3→12, 4→13, 5→15,
6→14, 7→16, 8→09, 9→15, 10→13.
```
```markdown
# Plano de 90 dias — depois do curso
**Início:** 2026-09-15
**Caminho escolhido:** 4 — Produto
**Por quê:** só descubro o que quero aprofundar mantendo um app com usuários reais.

## Mês 1 — Consolidar
**Entregável:** um app meu, diferente do Foco, na faixa interna do Android.

### Semana 1–2
- [ ] Ideia que resolve um problema meu
- [ ] Domínio em Dart puro, com testes (módulo 12)
- [ ] Arquitetura feature-first (módulo 08)

### Semana 3–4
- [ ] Telas com os 4 estados de UI (módulo 06)
- [ ] Persistência local com sqflite (módulo 10)
- [ ] Publicar na faixa interna (módulo 15)

### Verificação
- [ ] Instala num aparelho que não é o meu
- [ ] 20 testes passando e `flutter analyze` sem avisos
- [ ] Alguém além de mim usou
```
Refazer o Foco não conta: sem um app seu, a data de início e a frase do "por quê" escritas, o plano vira intenção.

<a id="m17-e14"></a>
## M17-E14
```powershell
.\tool\nova-versao.ps1 -Tipo minor   # 1.0.3+12 -> 1.1.0+13, commit e tag anotada v1.1.0
git push origin main v1.1.0
```
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags: ['v*']

env:
  FLUTTER_VERSION: '3.47.1'

jobs:
  qualidade:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '${{ env.FLUTTER_VERSION }}', cache: true }
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --no-fatal-infos
      - run: flutter test

  android:
    needs: qualidade
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17', cache: gradle }
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '${{ env.FLUTTER_VERSION }}', cache: true }
      - run: flutter pub get
      - name: Restaurar o keystore   # mesmo passo de M17-E09
        env:
          KEYSTORE_B64: ${{ secrets.ANDROID_KEYSTORE_B64 }}
        run: echo "$KEYSTORE_B64" | base64 -d > "$RUNNER_TEMP/upload.jks"
      - name: Build AAB
        env:
          ANDROID_KEYSTORE_PATH: ${{ runner.temp }}/upload.jks
          ANDROID_STORE_PASSWORD: ${{ secrets.ANDROID_STORE_PASSWORD }}
          ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
        run: |
          flutter build appbundle --release \
            --obfuscate --split-debug-info=simbolos/${{ github.ref_name }}
      - name: Arquivar símbolos
        uses: actions/upload-artifact@v4
        with:
          name: simbolos-${{ github.ref_name }}
          path: |
            simbolos/
            build/app/outputs/mapping/release/mapping.txt
          retention-days: 90
      - name: Publicar o AAB
        uses: actions/upload-artifact@v4
        with:
          name: aab-${{ github.ref_name }}
          path: build/app/outputs/bundle/release/app-release.aab
      - name: Enviar à faixa interna
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          packageName: br.com.estudos.foco
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed
```
`needs: qualidade` impede que uma tag quebrada chegue aos testadores, e `track: internal` mantém a promoção para produção como decisão humana.
