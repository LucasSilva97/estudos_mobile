# Exercícios — Módulo 17: Publicação e próximos passos

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Rode `flutter analyze` e `flutter test` antes de consultar o gabarito; os scripts PowerShell rodam na raiz do projeto `foco`.

<a id="m17-e01"></a>
## M17-E01 — Conferência pré-envio · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Validar o artefato antes da loja | Fácil | 20 min | Sim |
Rode `tool/preparar_release_play.ps1` e conserte tudo que ele reprovar. **Esperado:** o bloco verde `PRONTO PARA ENVIAR A GOOGLE PLAY`, com `applicationId = "br.com.estudos.foco"`, `signingConfigs.getByName("release")` e `key.properties`, `*.jks` e `*.keystore` no `.gitignore`. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e01)

<a id="m17-e02"></a>
## M17-E02 — Ficha da loja nos limites · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Escrever a ficha antes do navegador | Fácil | 25 min | Sim |
Escreva `tool/ficha-da-loja.txt` com nome (≤ 30), descrição curta (≤ 80), descrição completa do Foco e a URL da política de privacidade. **Teste:** `$curta.Length` devolve um número ≤ 80 no PowerShell, e o arquivo lista o ícone 512×512 e o gráfico de destaque 1024×500. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e02)

<a id="m17-e03"></a>
## M17-E03 — Segurança dos Dados coerente · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Declarar coleta sem contradição | Média | 20 min | Sim |
Liste as `<uses-permission>` de `android/app/src/main/AndroidManifest.xml` e responda por escrito as três perguntas do formulário para o Foco. **Esperado:** "não coleta" sustentado por sqflite e `shared_preferences` locais, "criptografia em trânsito: sim" por causa de `https://jsonplaceholder.typicode.com`, e nenhuma permissão declarada sem uso. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e03)

<a id="m17-e04"></a>
## M17-E04 — Texto de permissão reprovado · Correção de bugs
O `Info.plist` tem `NSCameraUsageDescription` igual a `Precisamos de acesso à câmera.` e `dart run tool/checar_info_plist.dart` sai com `1` apontando três motivos. Reescreva o texto dizendo a finalidade concreta para quem usa o app. **Teste:** a linha vira `OK NSCameraUsageDescription` e `$LASTEXITCODE` passa de `1` para `0`. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e04)

<a id="m17-e05"></a>
## M17-E05 — Numeração de versão · Fixação
Dado `version: 1.4.2+37`, escreva os quatro valores gerados (`versionName`, `versionCode`, `CFBundleShortVersionString`, `CFBundleVersion`) e a versão do reenvio depois de uma rejeição. **Esperado:** `1.4.2+38` — mesmo nome, binário novo — com a justificativa de por que o `+N` nunca reinicia, nem ao subir o MAJOR. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e05)

<a id="m17-e06"></a>
## M17-E06 — Ciclo de release completo · Aplicação
Rode `tool/nova-versao.ps1 -Tipo patch -Simular`, depois de verdade, escrevendo a entrada de `### Corrigido` no `CHANGELOG.md`. **Teste:** `git show v<versão>` mostra uma tag **anotada** com autor e mensagem, o `pubspec.yaml` subiu nome e build, e o script recusa rodar com o repositório sujo. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e06)

<a id="m17-e07"></a>
## M17-E07 — CI que barra push quebrado · Aplicação
Crie `.github/workflows/ci.yml` em `ubuntu-latest`, Flutter `3.47.1`, com `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze --no-fatal-infos` e `flutter test --coverage`. **Teste:** quebre um teste de propósito, faça push e veja o ❌ na aba Actions; tire `--set-exit-if-changed` e comprove que a formatação deixa de ser verificada. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e07)

<a id="m17-e08"></a>
## M17-E08 — Bug grave em produção · Reflexão
A 1.4.2 do Foco trava ao excluir a última matéria. Escreva o plano de resposta para **Android** e para **iOS**, com os comandos do hotfix a partir da tag `v1.4.2`. **Esperado:** texto justificando por que o Android interrompe o rollout e reativa a versão anterior, por que no iOS só resta publicar a 1.4.3 e esperar a revisão, e por que quem já atualizou permanece na versão ruim nas duas lojas. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e08)

<a id="m17-e09"></a>
## M17-E09 — Segredos em base64 · Aplicação
Converta o `foco-upload.jks` para base64 e cadastre `ANDROID_KEYSTORE_B64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD` e `ANDROID_KEY_ALIAS` como secrets do repositório. **Teste:** o passo que restaura o keystore falha com mensagem própria quando `[ ! -s "$RUNNER_TEMP/upload.jks" ]`, e nenhum `echo` do workflow imprime valor derivado de segredo. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e09)

<a id="m17-e10"></a>
## M17-E10 — Telemetria que vaza · Correção de bugs
Em `ObservadorDeRotas._registrar` alguém passou a enviar `rota.settings.arguments` junto do nome, e `Telemetria.configurar()` ficou só com `FlutterError.onError`. Corrija os dois. **Teste:** um erro lançado dentro de um `Future` sem `catch` chega ao painel, e o rastro registra apenas o nome da rota. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e10)

<a id="m17-e11"></a>
## M17-E11 — Stack trace ilegível · Diagnóstico
Um crash da v1.4.2 chega como endereços hexadecimais, sem nome de função, mesmo tendo sido compilado com `--obfuscate --split-debug-info=simbolos/v1.4.2`. Diga o que falta e como impedir que se repita. **Esperado:** você aponta o envio dos símbolos daquela versão exata (mais os dSYM, no iOS) e o passo de arquivamento com `retention-days` no `release.yml`. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e11)

<a id="m17-e12"></a>
## M17-E12 — O que automatizar e o que não · Reflexão
Classifique em "automatizo" ou "deixo manual", justificando cada um: analyze/test, build em tag, texto de "Novidades", rollout gradual, envio à faixa interna e promoção para produção. **Esperado:** a conta de minutos do mês (Ubuntu 1×, Windows 2×, macOS 10×) mostrando por que o build iOS roda só em tag. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e12)

<a id="m17-e13"></a>
## M17-E13 — Autodiagnóstico e plano de 90 dias · Reflexão
Responda as dez perguntas do autodiagnóstico sem consultar nada, escolha **um** dos quatro caminhos e escreva `docs/plano-90-dias.md` com o mês 1 inteiro. **Esperado:** cada "não" vira o número de um módulo a revisar, e o entregável do mês 1 é um app **seu**, diferente do Foco, com data de início e a frase do "por quê". [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e13)

<a id="m17-e14"></a>
## M17-E14 — Release em tag, de ponta a ponta · Desafio prático
Una tudo: `tool/nova-versao.ps1 -Tipo minor`, push da tag `v1.1.0` e um `.github/workflows/release.yml` com `qualidade → android`, `--obfuscate --split-debug-info`, artefato de símbolos e `track: internal`. **Teste:** a execução aparece em Actions disparada pela tag, o `.aab` e os símbolos ficam baixáveis, e nada foi promovido para produção sem decisão humana. [🔑 Gabarito](../gabaritos/17-publicacao-e-proximos-passos.md#m17-e14)

[Módulo](../modulos/17-publicacao-e-proximos-passos/README.md)
