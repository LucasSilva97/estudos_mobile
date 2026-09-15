# Exercícios — Módulo 14: Build e distribuição Android

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Comece todo exercício de build com `flutter clean` e `flutter pub get`, e confira o artefato no aparelho antes de consultar o gabarito.

<a id="m14-e01"></a>
## M14-E01 — Três modos, três números · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Comparar debug, profile e release | Fácil | 20 min | Sim |
Gere os três APKs do Foco (`flutter build apk --debug`, `--profile` e `--release`) e monte uma tabela com o tamanho em MB e o tempo de build de cada um. **Esperado:** o release é o menor dos três e você justifica em uma frase por que o de debug é o maior, citando JIT, asserts e as ferramentas de depuração embutidas. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e01)

<a id="m14-e02"></a>
## M14-E02 — Modo na tela · Leitura de código
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Entender `kDebugMode` em tempo de compilação | Fácil | 15 min | Sim |
Leia `modoAtual()` e `CartaoDoModo` da Aula 1 e explique por escrito por que o `switch` sobre o modo não custa nada em release e por que o `debugPrint` dentro de `if (kDebugMode)` some do binário. **Teste:** rode `flutter run` e depois `flutter run --release`; o cartão muda de `DEBUG (JIT)` para `RELEASE (AOT)` e a mensagem no terminal desaparece. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e02)

<a id="m14-e03"></a>
## M14-E03 — Identidade definitiva · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Adotar o domínio invertido do app | Média | 30 min | Sim |
Troque `applicationId` e `namespace` de `com.example.foco` para `br.com.estudos.foco` em `android/app/build.gradle.kts`, mova a pasta do `MainActivity.kt` para `kotlin/br/com/estudos/foco/`, ajuste a linha `package` e mude `android:label` para `Foco`. **Teste:** `adb shell pm list packages` imprime `package:br.com.estudos.foco`, e `adb shell dumpsys package br.com.estudos.foco` mostra `versionName=1.0.0` e `versionCode=1`, vindos de `version: 1.0.0+1`. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e03)

<a id="m14-e04"></a>
## M14-E04 — Pacote fora do lugar · Correção de bugs
O projeto já tem `namespace = "br.com.estudos.foco"`, mas o arquivo continua em `kotlin/com/example/foco/MainActivity.kt` com `package com.example.foco`, e o build para em `Package directive doesn't match file location`. Corrija sem tocar no `namespace`. **Esperado:** o app abre normalmente; se ele instalar e fechar na abertura com `ClassNotFoundException: Didn't find class "br.com.estudos.foco.MainActivity"`, você moveu a pasta e esqueceu a primeira linha do arquivo. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e04)

<a id="m14-e05"></a>
## M14-E05 — Ícone em cinco densidades · Aplicação
Gere o ícone do Foco a partir de um PNG 1024×1024 em `assets/icone/icone.png` com `flutter_launcher_icons`, usando `min_sdk_android: 24`, `adaptive_icon_background: "#3F51B5"` e `remove_alpha_ios: true`. **Teste:** existem cinco arquivos `ic_launcher_foreground*`, um `mipmap-anydpi-v26/ic_launcher.xml` com as tags `<background>` e `<foreground>`, e `values/colors.xml` com a cor configurada. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e05)

<a id="m14-e06"></a>
## M14-E06 — Bloco no nível errado · Correção de bugs
Alguém indentou `flutter_launcher_icons:` dentro de `flutter:` e o gerador responde `Could not find a config file`, mesmo com o bloco presente no `pubspec.yaml`. Corrija e explique em uma frase por que a mensagem é enganosa. **Esperado:** com o bloco na coluna 1, `dart run flutter_launcher_icons` termina em `✓ Successfully generated launcher icons`. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e06)

<a id="m14-e07"></a>
## M14-E07 — Splash clara e escura · Aplicação
Configure `flutter_native_splash` com `color: "#3F51B5"`, `color_dark: "#121212"` e a seção `android_12:`, gere os recursos e force um cold start com `adb shell am force-stop br.com.estudos.foco` seguido de `am start -n br.com.estudos.foco/.MainActivity`, nos dois temas do sistema. **Teste:** existem quatro `styles.xml` (incluindo `values-v31` e `values-night-v31`) e a abertura não pisca branco; escreva também, em duas linhas, por que essa splash aparece antes de qualquer widget Flutter. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e07)

<a id="m14-e08"></a>
## M14-E08 — Chave de upload e assinatura · Aplicação
Crie o keystore com `keytool -genkey -v -keystore ... -keyalg RSA -keysize 2048 -validity 10000 -alias foco` numa pasta **fora** do projeto, escreva `android/key.properties` com barras normais no `storeFile`, e substitua `signingConfig = signingConfigs.getByName("debug")` do `buildTypes.release` pelo bloco `create("release")` que lê esse arquivo. **Teste:** `git check-ignore -v android/key.properties` acusa a regra do `.gitignore`, e `apksigner verify --print-certs` no `app-release.apk` mostra o seu certificado, não o `CN=Android Debug`. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e08)

<a id="m14-e09"></a>
## M14-E09 — `INTERNET` no manifest errado · Correção de bugs
A sincronização do Foco funciona em `flutter run` e falha no APK de release porque `<uses-permission android:name="android.permission.INTERNET" />` está em `android/app/src/debug/AndroidManifest.xml`. Mova a linha para o manifest de `main/` e explique por que o debug funcionava. **Teste:** `aapt dump permissions app-release.apk` lista `INTERNET` e a chamada `http` volta a funcionar no aparelho sem o computador conectado. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e09)

<a id="m14-e10"></a>
## M14-E10 — App mudo no Android 13 · Diagnóstico
Os lembretes de sessão de estudo não aparecem num aparelho Android 13, mas aparecem num Android 11, e nenhum erro é registrado. Levante as hipóteses em ordem — `POST_NOTIFICATIONS` não declarada, nunca pedida, ou já em `negadaParaSempre` — e diga qual comando ou chamada confirma cada uma. **Esperado:** você fecha o diagnóstico sem alterar código no escuro e corrige com `GerenciadorPermissoes.pedirNotificacoes()` e, no último caso, `abrirConfiguracoes()`. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e10)

<a id="m14-e11"></a>
## M14-E11 — APK, ABI e AAB · Aplicação
Gere `flutter build apk --release`, o mesmo com `--split-per-abi`, e `flutter build appbundle --release --obfuscate --split-debug-info=simbolos/1.0.0`; registre numa tabela o caminho e o tamanho de cada artefato. **Teste:** os APKs por ABI compartilham o mesmo `versionCode` (`aapt dump badging`), existe `build/app/outputs/mapping/release/mapping.txt`, e você explica em uma frase por que comparar o tamanho do `.aab` com o do APK universal não faz sentido. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e11)

<a id="m14-e12"></a>
## M14-E12 — Três falhas de build · Diagnóstico
Diagnostique, uma a uma, três situações da tabela da Aula 10: `Keystore file not found` logo depois de editar o `key.properties`; o app que compila e roda em debug mas quebra em release com `ClassNotFoundException`; e `INSTALL_FAILED_NO_MATCHING_ABIS` ao instalar no emulador. **Esperado:** para cada uma, sintoma → causa → correção em uma linha, com o comando ou ajuste que comprova a causa (`--stacktrace`, regra `-keep`, `--target-platform android-x64`). [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e12)

<a id="m14-e13"></a>
## M14-E13 — Decisões do release · Reflexão
Escreva três respostas curtas, cada uma com justificativa: (a) qual formato você entrega para a Play Console, para um beta por link direto e para um emulador x86_64; (b) o que acontece com o Foco se você perder o `.jks`, com e sem Play App Signing, e onde ficam os seus três backups; (c) em que ponto você para de tentar sozinho um erro de build e pede ajuda, e o que esse pedido precisa conter para ser respondível. **Esperado:** decisões defendidas em texto, não listas de comandos. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e13)

<a id="m14-e14"></a>
## M14-E14 — Release completo do Foco · Desafio prático
Execute a ordem inteira do módulo — identidade, ícone, splash, permissões, keystore, assinatura, `flutter clean`, depois APK e AAB — e valide o artefato no aparelho com os 12 itens do checklist da Aula 9. **Teste:** o app instala em aparelho limpo, atualiza a partir da versão anterior **sem perder** as sessões gravadas no sqflite, funciona em modo avião e não deixa nenhuma linha `E/flutter` no `adb logcat`. [🔑 Gabarito](../gabaritos/14-build-android.md#m14-e14)

[Módulo](../modulos/14-build-android/README.md)
