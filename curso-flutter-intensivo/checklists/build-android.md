# 🤖 Checklist — Build Android de release (APK e AAB)

> **O que é:** a lista completa para transformar o app **Foco** em um arquivo instalável e
> publicável, assinado com a **sua** chave.
> **Quando usar:** no Dia 28 do plano intensivo, depois que o
> [checklist do projeto final](projeto-final.md) estiver todo marcado.
> **Módulo que ensina tudo isto:** [modulos/15-build-android/README.md](../modulos/15-build-android/README.md)
> **Onde você está:** 🪟 Windows 11. **Tudo nesta página roda no Windows.** Build Android não
> precisa de Mac. (O equivalente iOS, que **precisa**, está em [build-ios.md](build-ios.md).)

---

## Como usar

- Marque `- [x]` só depois de rodar a verificação.
- Faça na ordem: pré-build → build → pós-build. A ordem existe porque mudar identidade depois
  de publicar é impossível, e gerar APK antes de configurar a assinatura produz um arquivo
  inútil.
- Comandos em `powershell` → terminal do Windows, na raiz do projeto.

### Legenda

| Símbolo | Significa |
|---|---|
| 🔴 | Item crítico — errar aqui custa caro (ou é irreversível) |
| 🤖 | Específico do Android |
| 🪟 | Específico do Windows |
| ⏱️ | Demorado na primeira vez |

### Termos explicados na primeira vez

- **APK** (*Android Package*) — o pacote instalável do Android. Você instala direto no aparelho.
- **AAB** (*Android App Bundle*) — o formato que a Google Play **exige** para publicação. Você
  envia um AAB e a Play gera o APK sob medida para cada aparelho.
- **ABI** (*Application Binary Interface*, interface binária de aplicação) — a arquitetura do
  processador do aparelho: `arm64-v8a` (praticamente todo celular moderno), `armeabi-v7a`
  (aparelhos antigos), `x86_64` (emuladores). Um APK "gordo" contém todas; um APK por ABI
  contém só uma e é bem menor.
- **Keystore** — o arquivo (`.jks`) que guarda a sua chave de assinatura. É **a identidade do
  seu app** na Google Play.
- **Alias** — o apelido da chave dentro do keystore (o curso usa `upload` como exemplo).
- **Assinar** — carimbar o pacote criptograficamente. A Play só aceita atualizações assinadas
  com a **mesma** chave da primeira publicação.
- **Gradle** — o sistema de build do Android. No Flutter 3.47 ele é configurado em **Kotlin
  DSL**, ou seja, arquivos `.kts`.
- **`minSdk` / `compileSdk` / `targetSdk`** — respectivamente: a versão mais antiga do Android
  que roda o app, a versão do SDK usada para compilar, e a versão para a qual o app declara
  estar preparado.

---

## PARTE 1 — PRÉ-BUILD

### 1.1 Identidade do app (irreversível depois de publicar)

- [ ] 🔴 **`applicationId` definitivo: `br.com.estudos.foco`.**
  O valor gerado pelo `flutter create` é `com.example.foco` — **`com.example` é recusado pela
  Google Play**. E, uma vez publicado, o `applicationId` **nunca mais** pode mudar: mudar
  significa publicar um app novo, do zero, sem os usuários do antigo.
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\build.gradle.kts -Pattern 'applicationId|namespace'
    ```
    Esperado: nenhuma ocorrência de `com.example`.
  - Aula: [modulos/15-build-android/02-identidade-do-app.md](../modulos/15-build-android/02-identidade-do-app.md)

- [ ] **Nome exibido "Foco" em `android:label`.**
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\src\main\AndroidManifest.xml -Pattern 'android:label'
    ```
  - Aula: [modulos/15-build-android/02-identidade-do-app.md](../modulos/15-build-android/02-identidade-do-app.md)

- [ ] **`version:` atualizada no `pubspec.yaml`** no formato `1.0.0+1`.
  `1.0.0` vira o `versionName` (o que o usuário vê); `1` vira o `versionCode` (o número inteiro
  que a Play usa para saber o que é mais novo).
  - Verificar:
    ```powershell
    Select-String -Path .\pubspec.yaml -Pattern '^version:'
    ```
  - Aula: [modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md](../modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md)

- [ ] **Configuração do Gradle conferida** (são os valores que o Flutter 3.47 gera):
  `compileSdk = 36`, `minSdk = 24` (Android 7.0), `targetSdk = 36`, Java `VERSION_17` e
  `jvmTarget = JVM_17`.
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\build.gradle.kts -Pattern 'compileSdk|minSdk|targetSdk|JVM_17|VERSION_17'
    ```
  - Aula: [modulos/15-build-android/01-debug-profile-release.md](../modulos/15-build-android/01-debug-profile-release.md)

> ⚠️ **Atenção a tutoriais antigos.** Muitos mandam editar `android/app/build.gradle` **sem** o
> `.kts`. Isso está desatualizado: o Flutter 3.47 gera **Kotlin DSL** — `build.gradle.kts` e
> `settings.gradle.kts`. Se o tutorial que você achou fala em `def keystoreProperties = new
> Properties()`, ele é Groovy e não vai funcionar no seu arquivo.

### 1.2 Identidade visual

- [ ] **Ícone gerado.**
  Requisito da imagem de origem: PNG **quadrado 1024×1024**, sem transparência, com o desenho
  dentro dos ~66% centrais (o Android recorta as bordas do ícone adaptativo).
  - Executar:
    ```powershell
    flutter pub get
    dart run flutter_launcher_icons
    ```
  - Verificar:
    ```powershell
    Get-ChildItem .\android\app\src\main\res\mipmap-xxxhdpi
    Test-Path .\android\app\src\main\res\mipmap-anydpi-v26\ic_launcher.xml
    Test-Path .\android\app\src\main\res\values\colors.xml
    ```
    Esperado: `ic_launcher.png` nas pastas `mipmap-*` e os dois `True`.
  - A linha `No platform provided` na saída do gerador é **normal** e não é erro.
  - Aula: [modulos/15-build-android/03-icone.md](../modulos/15-build-android/03-icone.md)

- [ ] **Splash gerada, inclusive modo escuro e Android 12+.**
  - Executar:
    ```powershell
    dart run flutter_native_splash:create
    ```
  - Verificar:
    ```powershell
    Test-Path .\android\app\src\main\res\drawable\launch_background.xml
    Test-Path .\android\app\src\main\res\drawable-night\launch_background.xml
    Test-Path .\android\app\src\main\res\values-v31\styles.xml
    Test-Path .\android\app\src\main\res\values-night-v31\styles.xml
    ```
    Esperado: quatro `True`. O `values-v31` é o mecanismo novo de splash do Android 12+, que
    mostra só o ícone centralizado — por isso existe a seção `android_12:` na configuração.
  - Aula: [modulos/15-build-android/04-splash-screen.md](../modulos/15-build-android/04-splash-screen.md)

- [ ] **Os blocos `flutter_launcher_icons:` e `flutter_native_splash:` estão no nível superior
  do `pubspec.yaml`** — alinhados com `dependencies:` e `flutter:`, **não dentro** de
  `flutter:`. Indentar errado é o erro nº 1 aqui.
  - Verificar (as duas linhas devem aparecer **sem** espaços à esquerda):
    ```powershell
    Select-String -Path .\pubspec.yaml -Pattern '^flutter_launcher_icons:|^flutter_native_splash:'
    ```
  - Aula: [modulos/15-build-android/03-icone.md](../modulos/15-build-android/03-icone.md)

### 1.3 Permissões

- [ ] **Permissões revisadas: o app declara apenas o que usa.**
  Permissão sobrando é motivo de recusa na revisão da Play e de desconfiança do usuário.
  As `<uses-permission>` são filhas de `<manifest>`, **antes** de `<application>`:
  ```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android">
      <uses-permission android:name="android.permission.INTERNET"/>
      <application ...>
  ```
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\src\main\AndroidManifest.xml -Pattern 'uses-permission'
    ```
  - Aula: [modulos/15-build-android/05-permissoes-android.md](../modulos/15-build-android/05-permissoes-android.md)

- [ ] 🔴 **`android.permission.INTERNET` declarada no manifesto principal.**
  O Flutter adiciona essa permissão automaticamente nos builds de **debug**, mas o **release**
  precisa dela declarada. Sem isso, a aba Trilhas funciona em debug e falha no APK assinado —
  um erro clássico e difícil de diagnosticar.
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\src\main\AndroidManifest.xml -Pattern 'android.permission.INTERNET'
    ```
  - Aula: [modulos/15-build-android/05-permissoes-android.md](../modulos/15-build-android/05-permissoes-android.md)

### 1.4 🔴 Keystore

> **Aviso de segurança do curso:** nenhum valor real de senha, alias ou caminho aparece aqui.
> Onde estiver `SUA_SENHA_AQUI`, `SEU_ALIAS` ou `SEU_USUARIO`, coloque o **seu** valor — e
> nunca escreva o valor real em arquivo versionado, em mensagem, em captura de tela ou em
> commit.

- [ ] **Keystore criado.**
  - Executar (responda às perguntas; a senha que você digitar é a sua `SUA_SENHA_AQUI`):
    ```powershell
    keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks `
            -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
            -alias upload
    ```
  - Verificar:
    ```powershell
    Test-Path "$env:USERPROFILE\upload-keystore.jks"
    ```
    Esperado: `True`.
  - Aula: [modulos/15-build-android/06-keystore.md](../modulos/15-build-android/06-keystore.md)

- [ ] 🔴 **Backup do keystore feito em pelo menos 2 lugares fora do computador.**
  **Perder o keystore = perder o app.** Sem ele você não consegue publicar nenhuma atualização
  do app existente; a única saída é publicar um app novo com outro `applicationId` e pedir a
  todos os usuários que reinstalem.
  Guarde: (1) o arquivo `.jks`; (2) a senha do keystore; (3) a senha da chave; (4) o alias.
  - Verificar: você consegue localizar as duas cópias **agora**, sem procurar.
  - Aula: [modulos/15-build-android/06-keystore.md](../modulos/15-build-android/06-keystore.md)

- [ ] **Você sabe listar o conteúdo do keystore** (útil para conferir o alias mais tarde).
  - Executar:
    ```powershell
    keytool -list -v -keystore $env:USERPROFILE\upload-keystore.jks -alias upload
    ```
  - Aula: [modulos/15-build-android/06-keystore.md](../modulos/15-build-android/06-keystore.md)

### 1.5 🔴 `key.properties`

- [ ] **`android/key.properties` criado** com este conteúdo (substitua pelos seus valores):
  ```properties
  storePassword=SUA_SENHA_AQUI
  keyPassword=SUA_SENHA_AQUI
  keyAlias=upload
  storeFile=C:\\Users\\SEU_USUARIO\\upload-keystore.jks
  ```
  > Atenção às **duas barras invertidas** (`\\`) no caminho: em arquivo `.properties` a barra
  > invertida é caractere de escape, e uma barra sozinha é engolida.
  - Verificar (deve listar as 4 chaves):
    ```powershell
    Select-String -Path .\android\key.properties -Pattern 'storePassword|keyPassword|keyAlias|storeFile'
    ```
  - Aula: [modulos/15-build-android/07-assinatura-no-gradle.md](../modulos/15-build-android/07-assinatura-no-gradle.md)

### 1.6 🔴 Segredos fora do Git — e PROVADO

Este bloco não é burocracia. Um `.jks` publicado em repositório público é um incidente de
segurança: qualquer pessoa passa a poder assinar pacotes no seu nome.

- [ ] **`.gitignore` do projeto contém as linhas de exclusão.**
  ```text
  android/key.properties
  *.jks
  *.keystore
  *.p12
  *.cer
  *.mobileprovision
  .env
  ```
  - Verificar:
    ```powershell
    Select-String -Path .\.gitignore -Pattern 'key.properties|\*\.jks|\*\.keystore'
    ```
  - Aula: [modulos/00-git-e-terminal/04-commits-branches-gitignore.md](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

- [ ] 🔴 **`git check-ignore` CONFIRMA que o `key.properties` está ignorado.**
  O `.gitignore` só vale para arquivos que o Git ainda **não** rastreia. Este comando é a prova.
  - Executar:
    ```powershell
    git check-ignore -v android/key.properties
    ```
    **Esperado:** uma linha citando o arquivo `.gitignore`, o número da linha e o padrão que
    casou, por exemplo:
    ```text
    .gitignore:12:android/key.properties    android/key.properties
    ```
    **Se o comando não devolver nada, o arquivo NÃO está ignorado.** Corrija o `.gitignore`
    antes de continuar.
  - Aula: [modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md)

- [ ] 🔴 **`git check-ignore` CONFIRMA que o keystore está ignorado.**
  - Executar (o comando funciona mesmo que o arquivo não esteja nessa pasta — ele testa o
    padrão):
    ```powershell
    git check-ignore -v upload-keystore.jks
    git check-ignore -v android/app/upload-keystore.jks
    ```
    Esperado: uma linha de resposta para cada, citando o padrão `*.jks`.
  - Aula: [modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md)

- [ ] 🔴 **Nenhum segredo já rastreado pelo Git.**
  - Executar (**não pode devolver nada**):
    ```powershell
    git ls-files | Select-String -Pattern '\.(jks|keystore|p12|cer|mobileprovision|env)$|key\.properties'
    ```
    Se devolver alguma linha, o arquivo **já está no histórico**. Remova do rastreamento com
    `git rm --cached <arquivo>`, faça commit, e trate a chave como **comprometida**: gere um
    keystore novo antes de publicar.
  - Aula: [modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md)

- [ ] **Nenhuma senha escrita dentro de arquivo versionado.**
  - Executar (**não pode devolver nada**):
    ```powershell
    git ls-files | ForEach-Object { Select-String -Path $_ -Pattern 'storePassword=|keyPassword=' } 
    ```
  - Aula: [modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md)

### 1.7 🔴 Assinatura no `build.gradle.kts`

- [ ] 🔴 **O bloco `TODO` com a chave de DEBUG foi REMOVIDO.**
  O `flutter create` gera exatamente isto em `android/app/build.gradle.kts`:
  ```kotlin
  buildTypes {
      release {
          // TODO: Add your own signing config for the release build.
          // Signing with the debug keys for now, so `flutter run --release` works.
          signingConfig = signingConfigs.getByName("debug")
      }
  }
  ```
  Enquanto esse `TODO` estiver ali, o seu "release" está assinado com a **chave de depuração**.
  Ele roda no seu aparelho, mas **não pode ser publicado na Google Play** — e a Play recusa o
  upload. Esse comentário é um aviso, não decoração.
  - Verificar (**não pode devolver nada**):
    ```powershell
    Select-String -Path .\android\app\build.gradle.kts -Pattern 'signingConfigs.getByName\("debug"\)|TODO: Add your own signing config'
    ```
  - Aula: [modulos/15-build-android/07-assinatura-no-gradle.md](../modulos/15-build-android/07-assinatura-no-gradle.md)

- [ ] 🔴 **`build.gradle.kts` lê o `key.properties` e usa a assinatura de release.**
  O arquivo precisa ter, no topo, a leitura das propriedades:
  ```kotlin
  import java.util.Properties
  import java.io.FileInputStream

  val keystoreProperties = Properties()
  val keystorePropertiesFile = rootProject.file("key.properties")
  if (keystorePropertiesFile.exists()) {
      keystoreProperties.load(FileInputStream(keystorePropertiesFile))
  }
  ```
  e, dentro de `android { }`:
  ```kotlin
  android {
      signingConfigs {
          create("release") {
              keyAlias = keystoreProperties.getProperty("keyAlias")
              keyPassword = keystoreProperties.getProperty("keyPassword")
              storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
              storePassword = keystoreProperties.getProperty("storePassword")
          }
      }
      buildTypes {
          release { signingConfig = signingConfigs.getByName("release") }
      }
  }
  ```
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\build.gradle.kts -Pattern 'keystoreProperties|signingConfigs|getByName\("release"\)'
    ```
    Esperado: as três ocorrências presentes.
  - Aula: [modulos/15-build-android/07-assinatura-no-gradle.md](../modulos/15-build-android/07-assinatura-no-gradle.md)

### 1.8 Qualidade antes de compilar

- [ ] **Análise e testes passando** (não compile um release com código que nem passa no
  analisador).
  - Executar:
    ```powershell
    flutter analyze
    dart format --output=none --set-exit-if-changed .
    flutter test
    ```
  - Aula: [checklists/projeto-final.md](projeto-final.md)

---

## PARTE 2 — BUILD

- [ ] 🔴 **`flutter clean` executado.**
  Os geradores de ícone e splash mexeram em recursos nativos, e o Gradle pode reaproveitar
  cache antigo — produzindo um APK com o ícone velho. O `clean` também é parte da correção
  quando o cache ficou corrompido.
  - Executar:
    ```powershell
    flutter clean
    flutter pub get
    ```
  - Aula: [modulos/15-build-android/10-diagnostico-de-build.md](../modulos/15-build-android/10-diagnostico-de-build.md)

- [ ] **APK de release gerado.** ⏱️ (a primeira vez baixa dependências do Gradle)
  - Executar:
    ```powershell
    flutter build apk --release
    ```
  - Verificar:
    ```powershell
    Test-Path .\build\app\outputs\flutter-apk\app-release.apk
    ```
    Esperado: `True`. Caminho de saída oficial:
    `build/app/outputs/flutter-apk/app-release.apk`
  - Aula: [modulos/15-build-android/08-gerando-apk-e-aab.md](../modulos/15-build-android/08-gerando-apk-e-aab.md)

- [ ] **APKs por ABI gerados** (arquivos bem menores, úteis para distribuir fora da Play).
  - Executar:
    ```powershell
    flutter build apk --split-per-abi
    ```
  - Verificar:
    ```powershell
    Get-ChildItem .\build\app\outputs\flutter-apk\*.apk | Select-Object Name, Length
    ```
    Esperado: `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk` e
    `app-x86_64-release.apk`.
    Para um celular moderno, o que interessa é o **`arm64-v8a`**.
  - Aula: [modulos/15-build-android/08-gerando-apk-e-aab.md](../modulos/15-build-android/08-gerando-apk-e-aab.md)

- [ ] **AAB gerado** (é o formato exigido pela Google Play).
  - Executar:
    ```powershell
    flutter build appbundle
    ```
  - Verificar:
    ```powershell
    Test-Path .\build\app\outputs\bundle\release\app-release.aab
    ```
    Esperado: `True`. Caminho oficial: `build/app/outputs/bundle/release/app-release.aab`
  - Aula: [modulos/15-build-android/08-gerando-apk-e-aab.md](../modulos/15-build-android/08-gerando-apk-e-aab.md)

- [ ] **Os três caminhos de saída conferidos de uma vez.**
  - Executar:
    ```powershell
    Get-ChildItem .\build\app\outputs\flutter-apk\ , .\build\app\outputs\bundle\release\ |
      Select-Object FullName, @{Name='MB';Expression={[math]::Round($_.Length/1MB,2)}}
    ```
  - Aula: [modulos/15-build-android/08-gerando-apk-e-aab.md](../modulos/15-build-android/08-gerando-apk-e-aab.md)

- [ ] **Nenhum aviso de assinatura na saída do build** (nada dizendo que o app está assinado
  com chave de debug).
  - Aula: [modulos/15-build-android/07-assinatura-no-gradle.md](../modulos/15-build-android/07-assinatura-no-gradle.md)

---

## PARTE 3 — PÓS-BUILD (validação no mundo real)

### 3.1 Instalação

- [ ] **APK instalado no aparelho físico.**
  - Executar (com o aparelho conectado e autorizado):
    ```powershell
    flutter install
    ```
    Alternativa direta com o APK por ABI:
    ```powershell
    adb install -r .\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
    ```
  - Verificar: o ícone do **Foco** aparece na gaveta de apps.
  - Aula: [modulos/15-build-android/09-instalando-e-validando.md](../modulos/15-build-android/09-instalando-e-validando.md)

- [ ] **Ícone e nome corretos na tela inicial** (não o robô padrão do Flutter, não "foco" em
  minúsculo, não "flutter_app").
  - Aula: [modulos/15-build-android/03-icone.md](../modulos/15-build-android/03-icone.md)

- [ ] **Splash aparece com a cor e a imagem certas** — e também no modo escuro.
  - Aula: [modulos/15-build-android/04-splash-screen.md](../modulos/15-build-android/04-splash-screen.md)

### 3.2 Testes de comportamento

- [ ] 🔴 **App testado SEM o computador.**
  Desconecte o cabo USB, feche o app, reabra pelo ícone. É a prova de que o pacote é autônomo:
  em release não existe conexão com o *debugger* nem carregamento de código pela máquina.
  - Verificar: o app abre e funciona normalmente, desconectado.
  - Aula: [modulos/15-build-android/09-instalando-e-validando.md](../modulos/15-build-android/09-instalando-e-validando.md)

- [ ] **App testado OFFLINE** (modo avião ligado).
  Esperado: as funções locais (matérias, sessões, meta, estatísticas) continuam funcionando; a
  aba Trilhas mostra o **estado de erro** com mensagem em português e botão *Tentar novamente*
  — nunca uma tela branca nem um travamento.
  - Verificar: ligue o modo avião, navegue pelas 5 telas, desligue, toque em *Tentar novamente*.
  - Aula: [modulos/10-persistencia-de-dados/08-cache-e-offline.md](../modulos/10-persistencia-de-dados/08-cache-e-offline.md) ·
    [modulos/11-recursos-nativos/05-conectividade.md](../modulos/11-recursos-nativos/05-conectividade.md)

- [ ] **App testado no MODO ESCURO.**
  - Verificar: mude o tema do sistema Android e percorra as 5 telas. Nenhum texto some, nenhum
    contraste fica ilegível.
  - Aula: [modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md](../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md)

- [ ] **Dados persistem depois de fechar e reabrir.**
  - Verificar: cadastre uma matéria, feche o app pelo gerenciador de tarefas, reabra.
  - Aula: [modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md)

- [ ] **App testado com a fonte do sistema no tamanho máximo** (Acessibilidade → Tamanho da
  fonte). Nenhum estouro de layout.
  - Aula: [modulos/13-desempenho-e-seguranca/05-acessibilidade.md](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

- [ ] **App testado girando a tela** (retrato ↔ paisagem) nas 5 telas.
  - Aula: [modulos/06-widgets-e-layouts/11-responsividade.md](../modulos/06-widgets-e-layouts/11-responsividade.md)

- [ ] **Botão voltar do Android se comporta como esperado em todas as telas**, inclusive com o
  cronômetro rodando.
  - Aula: [modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md](../modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md)

### 3.3 Tamanho

- [ ] **Tamanho dos artefatos conferido e anotado.**
  - Executar:
    ```powershell
    Get-ChildItem .\build\app\outputs\flutter-apk\*.apk , .\build\app\outputs\bundle\release\*.aab |
      Select-Object Name, @{Name='MB';Expression={[math]::Round($_.Length/1MB,2)}}
    ```
  - O que esperar: o APK "gordo" (todas as ABIs) é sensivelmente maior que o
    `app-arm64-v8a-release.apk`. Se o seu APK universal estiver **muito** acima do APK por ABI,
    isso é normal — ele carrega três arquiteturas.
  - Aula: [modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md](../modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md)

- [ ] **Assets desnecessários removidos** (imagens gigantes, fontes não usadas, PNGs de teste).
  - Verificar:
    ```powershell
    Get-ChildItem .\assets -Recurse -File | Select-Object FullName, @{Name='KB';Expression={[math]::Round($_.Length/1KB,1)}}
    ```
  - Aula: [modulos/06-widgets-e-layouts/08-imagens-e-assets.md](../modulos/06-widgets-e-layouts/08-imagens-e-assets.md)

---

## PARTE 4 — Checklist pré-Google Play

Não envie nada antes de todas estas linhas estarem marcadas.

- [ ] **Conta de desenvolvedor da Google Play criada e paga** (taxa única).
  - Aula: [modulos/17-publicacao-e-proximos-passos/01-google-play.md](../modulos/17-publicacao-e-proximos-passos/01-google-play.md)

- [ ] **`applicationId` sem `com.example`** (conferido na Parte 1.1).
- [ ] **AAB assinado com a chave de release** (e não com a de debug).
- [ ] **`versionCode` maior que o da versão anterior** — a Play recusa upload com `versionCode`
  igual ou menor.
  - Verificar: o `+N` do `version:` no `pubspec.yaml` foi incrementado.
  - Aula: [modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md](../modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md)
- [ ] **Backup do keystore confirmado** (item 1.4 — sem ele não existe atualização futura).
- [ ] **Ícone de alta resolução 512×512** preparado para a ficha da loja.
- [ ] **Capturas de tela** do app (pelo menos 2, de aparelho real).
- [ ] **Descrição curta e descrição completa** escritas em português.
- [ ] **Política de privacidade** publicada em uma URL acessível — obrigatória mesmo para apps
  simples, e mais ainda se houver qualquer permissão sensível.
  - Aula: [modulos/17-publicacao-e-proximos-passos/01-google-play.md](../modulos/17-publicacao-e-proximos-passos/01-google-play.md)
- [ ] **Questionário de classificação indicativa** respondido.
- [ ] **Seção "Segurança dos dados"** preenchida com honestidade (o Foco guarda dados só no
  aparelho; diga exatamente isso).
- [ ] **Teste interno ou fechado feito antes da produção** (a Play permite faixas de teste; use
  uma).
  - Aula: [modulos/17-publicacao-e-proximos-passos/01-google-play.md](../modulos/17-publicacao-e-proximos-passos/01-google-play.md)
- [ ] **Nada sensível no repositório** (conferido na Parte 1.6, com `git check-ignore`).

---

## 🧪 Sequência completa de verificação (copie e rode)

```powershell
# --- PRÉ-BUILD: identidade e segredos ---
Select-String -Path .\android\app\build.gradle.kts -Pattern 'applicationId|namespace'
Select-String -Path .\pubspec.yaml -Pattern '^version:'
Select-String -Path .\android\app\src\main\AndroidManifest.xml -Pattern 'android:label|uses-permission'

git check-ignore -v android/key.properties        # PRECISA devolver uma linha
git check-ignore -v upload-keystore.jks           # PRECISA devolver uma linha
git ls-files | Select-String -Pattern '\.(jks|keystore|p12|cer|mobileprovision|env)$|key\.properties'   # NÃO pode devolver nada

# --- PRÉ-BUILD: assinatura ---
Select-String -Path .\android\app\build.gradle.kts -Pattern 'signingConfigs.getByName\("debug"\)'   # NÃO pode devolver nada
Select-String -Path .\android\app\build.gradle.kts -Pattern 'getByName\("release"\)'                # PRECISA devolver

# --- PRÉ-BUILD: identidade visual ---
dart run flutter_launcher_icons
dart run flutter_native_splash:create
Test-Path .\android\app\src\main\res\mipmap-anydpi-v26\ic_launcher.xml
Test-Path .\android\app\src\main\res\values-v31\styles.xml

# --- PRÉ-BUILD: qualidade ---
flutter analyze
flutter test

# --- BUILD ---
flutter clean
flutter pub get
flutter build apk --release
flutter build apk --split-per-abi
flutter build appbundle

# --- SAÍDAS ---
Get-ChildItem .\build\app\outputs\flutter-apk\*.apk , .\build\app\outputs\bundle\release\*.aab |
  Select-Object Name, @{Name='MB';Expression={[math]::Round($_.Length/1MB,2)}}

# --- PÓS-BUILD ---
flutter install
```

### Tabela de saídas esperadas

| Comando | Prova de sucesso |
|---|---|
| `Select-String ... applicationId` | `br.com.estudos.foco`, sem `com.example` |
| `git check-ignore -v android/key.properties` | uma linha citando `.gitignore` e o padrão |
| `git ls-files \| Select-String ...` | **nenhuma linha** |
| `Select-String ... getByName("debug")` | **nenhuma linha** |
| `Select-String ... getByName("release")` | uma linha |
| `flutter analyze` | `No issues found!` |
| `flutter test` | `All tests passed!` |
| `flutter build apk --release` | `✓ Built build\app\outputs\flutter-apk\app-release.apk` |
| `flutter build apk --split-per-abi` | 3 APKs: `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| `flutter build appbundle` | `✓ Built build\app\outputs\bundle\release\app-release.aab` |
| `flutter install` | app instalado e abrindo pelo ícone |

---

## Se o build falhar

| Mensagem / sintoma | Causa provável | Onde resolver |
|---|---|---|
| `Unsupported class file major version` | Java diferente do 17 | [checklists/ambiente-android.md](ambiente-android.md), item 6 |
| `Keystore file not found` | caminho errado no `key.properties` (falta `\\`) | Item 1.5 |
| `Failed to read key ... from store` | senha ou alias errado | Item 1.5 · [modulos/15-build-android/06-keystore.md](../modulos/15-build-android/06-keystore.md) |
| APK instala mas a Play recusa o upload | assinado com a chave de debug | Item 1.7 |
| Ícone antigo continua aparecendo | faltou `flutter clean` | Parte 2 |
| `Some Android licenses not accepted` | licenças do SDK | [checklists/ambiente-android.md](ambiente-android.md), item 8 |
| App funciona em debug e falha na rede em release | falta `INTERNET` no manifesto | Item 1.3 |
| Erro de Gradle genérico, sem pista | cache sujo | `flutter clean` · [modulos/15-build-android/10-diagnostico-de-build.md](../modulos/15-build-android/10-diagnostico-de-build.md) |
| `Building with plugins requires symlink support` | Modo de Desenvolvedor do Windows desligado | [checklists/ambiente-android.md](ambiente-android.md), item 5 |

Catálogo completo de erros: [referencias/erros-comuns.md](../referencias/erros-comuns.md)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [Checklist — Build Web (PWA)](build-web.md) | [Índice geral](../README.md) | [Checklist — Build iOS](build-ios.md) |
