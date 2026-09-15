# Avaliação — Cumulativa 05: Build e distribuição

> Cobre os **módulos 14 a 16**. Aqui nada se resolve olhando um módulo só: cada questão junta
> assinatura, artefato, loja e monitoramento na mesma resposta.

> **Tempo sugerido:** 35 min de questões + 80 min de prática. Faça sem consultar o material.

Cobra-se a **cadeia inteira** do Foco depois que o código já está pronto: `pubspec.yaml` →
assinatura → artefato (`.aab` / `.ipa`) → loja → CI → monitoramento. Quase tudo aqui é **decisão**
e **diagnóstico**, não código.

## 1. Questionário

Cada questão vale 1 ponto — **12 pontos no total**.

1. **(módulos 14 + 16)** O Foco está publicado com Play App Signing e você perdeu o `foco-upload.jks` e o backup. O que acontece: A) o app morreu, porque a chave é insubstituível; B) você abre chamado na Play Console, comprova identidade e recebe autorização para uma chave de upload nova — a chave que assina o que chega ao aparelho está com o Google; C) você publica com outro `applicationId` e avisa os usuários; D) basta gerar outro keystore com o mesmo alias e a mesma senha.  
2. **(módulos 14 + 15)** A diferença correta entre assinar no 🤖 Android e no 🍎 iOS é: A) nos dois casos a plataforma emite e guarda a chave; B) o Android tem **uma** peça (o keystore), emitida por você, com validade que você escolhe; o iOS tem **cinco** (chave privada → CSR → certificado → App ID → provisioning profile), emitidas pela Apple, com certificado de 1 ano e aparelhos por UDID; C) o iOS dispensa certificado na assinatura automática; D) o keystore Android também é renovado todo ano.  
3. **(módulos 14 + 16)** Um SDK de terceiro trouxe `ACCESS_FINE_LOCATION` para o manifest fundido do Foco, e na Play você declarou "não coleta dados". O certo é: A) ignorar, porque a permissão não é do seu código; B) conferir o manifest fundido e remover a permissão com `tools:node="remove"` se o recurso não é usado — ou declarar a coleta na Segurança dos Dados; declarar o contrário do que o app faz é motivo de suspensão; C) responder o formulário só com o que está no seu `AndroidManifest.xml` principal; D) trocar por `ACCESS_COARSE_LOCATION`, que não precisa ser declarada.  
4. Você enviou `1.2.0+11` ao TestFlight, a revisão rejeitou e você corrigiu. No mesmo dia vai subir o AAB para a faixa interna da Play. O certo é: A) reenviar `+11` nas duas, já que o binário rejeitado liberou o número; B) subir para `1.2.0+12` nas duas — nem `versionCode` nem `CFBundleVersion` aceitam repetição, e o mesmo número nas duas evita divergência; C) `1.2.1+1` no iOS e `1.2.0+11` no Android; D) `1.2.0+12` só no iOS, porque a Play aceita `versionCode` repetido em faixa interna.  
5. **(módulos 14 + 15 + 16)** Três destinos no mesmo dia: a produção da Play, um colega que vai instalar por link e o TestFlight. Os artefatos são, na ordem: A) AAB, AAB e AAB; B) APK universal, AAB e `.xcarchive`; C) `app-release.aab`, o APK `arm64-v8a` e o `.ipa` gerado em macOS; D) AAB, APK universal e `.aab` convertido em IPA.  
6. No workflow do Foco, `flutter build ipa` deve rodar: A) em `ubuntu-latest`, com o SDK do iOS instalado por action; B) em `macos-latest`, e só em `push` de tag, porque o minuto de macOS consome 10× a cota; C) em `windows-latest`, já que você desenvolve no Windows; D) em `macos-latest` a cada push, para pegar erro cedo.  
7. **(módulos 14 + 16)** Chegou um stack trace da release com `#0 a.b (package:foco/a.dart:1:1)`. Para lê-lo: A) rebuildar sem `--obfuscate` e pedir para o usuário repetir; B) `adb logcat -d` no seu aparelho; C) desligar a ofuscação em produção; D) `flutter symbolize` com os símbolos **daquele** build, gravados por `--split-debug-info` — por isso a pasta é arquivada junto da release.  
8. No job Android, a keystore chega por `ANDROID_KEYSTORE_B64`. O que mantém o segredo seguro: A) escrever a senha no YAML, já que o repositório é privado; B) decodificar o secret para um arquivo dentro do runner, passar as senhas por `env` vindas de `secrets.*` e nunca dar `echo` em variável derivada — o mascaramento cobre só o valor exato; C) commitar o `.jks` numa branch separada; D) gerar a keystore dentro do CI a cada build.

9. **(módulos 14 + 15)** Explique por que perder a chave privada do iOS e perder o keystore do Android têm gravidades diferentes, e o que o Play App Signing muda nessa comparação.  
10. O Foco guarda tudo no sqflite e não coleta nada. Você vai adicionar relatório de erro. Diga o que muda na Segurança dos Dados da Play, na Nutrition Label da Apple e o que **nunca** entra no log, citando o princípio da LGPD envolvido.  
11. **(módulos 14 + 15)** `NSCameraUsageDescription` ausente e `<uses-permission>` ausente são "a mesma permissão faltando", mas falham em momentos diferentes. Diga quando cada uma falha e o que isso muda na ordem do seu checklist de release.  
12. Com cota de CI apertada, diga o que automatizar e o que deixar manual na cadeia push → tag → loja, e justifique por que o build iOS entra só em tag.

## 2. Prática

Prepare a release **1.2.0** do Foco (`br.com.estudos.foco`), partindo de `1.1.3+11`, **sem publicar
em loja**. Tudo é feito no **Windows**, menos o que a última linha isola. Configure a assinatura
real do Android (`key.properties` fora do Git + `signingConfigs`), gere o AAB com
`--obfuscate --split-debug-info=simbolos/1.2.0+12` e arquive os símbolos. Atualize `pubspec.yaml`,
`CHANGELOG.md` e crie a tag anotada `v1.2.0`. Escreva `.github/workflows/release.yml` com três jobs:
verificação a cada push, build Android em tag e build iOS em tag. Deixe a parte iOS pronta em texto
(Bundle ID, `Info.plist`, ícone sem alfa, permissões) e registre em `docs/release-1.2.0.md` o que
**exige macOS** — archive, assinatura e envio — com a alternativa do runner macOS.

| Critério | Pontos |
|---|---:|
| `key.properties` fora do Git, `signingConfigs` lendo dele e `apksigner verify --print-certs` provando que não é a chave de depuração | 2 |
| `1.2.0+12` no `pubspec.yaml`, `CHANGELOG.md` com a entrada da versão e tag anotada `v1.2.0` coerentes entre si | 1 |
| AAB gerado com ofuscação e a pasta `simbolos/1.2.0+12` arquivada junto da release | 1 |
| `release.yml`: `analyze` + `test` em `ubuntu-latest` a cada push; Android em tag com keystore vinda de secret em base64; iOS em `macos-latest` **só** em tag | 3 |
| Preparação iOS no Windows: Bundle ID nas três configurações, `Info.plist` por `$(FLUTTER_BUILD_NAME)`/`$(FLUTTER_BUILD_NUMBER)`, ícone sem alfa e textos específicos | 1 |
| `docs/release-1.2.0.md`: Segurança dos Dados conferida contra o **manifest fundido**, faixa escolhida e rollout com limites de ação | 1 |
| Roteiro numerado do que exige macOS, com a alternativa de runner macOS e o custo em cota | 1 |

## 3. Critérios para avançar

- **9/12** no questionário e **8/10** na prática.
- Avaliações dos módulos 14, 15 e 16 já aprovadas.
- M14-E01 a M14-E14, M15-E01 a M15-E14 e M16-E01 a M16-E14 concluídos e conferidos.
- `flutter analyze` sem apontamentos e `flutter build appbundle --release` concluindo no Windows.
- `git status` não lista nenhum `*.jks`, `key.properties`, `*.p12` ou `*.mobileprovision`.
- Workflow verde na aba **Actions**, sem nenhum segredo escrito dentro do YAML.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Chave de upload, Play App Signing e backup | [M14 · Aula 06](../modulos/14-build-android/06-keystore.md) e [M16 · Aula 01](../modulos/16-publicacao-e-proximos-passos/01-google-play.md) | M14-E08 e M16-E01 |
| Assinatura no Gradle e build recusado pela loja | [M14 · Aula 07](../modulos/14-build-android/07-assinatura-no-gradle.md) | M14-E06 e M14-E14 |
| APK, ABI, AAB e o artefato de cada destino | [M14 · Aula 08](../modulos/14-build-android/08-gerando-apk-e-aab.md) | M14-E11 |
| Permissões, manifest fundido e Segurança dos Dados | [M14 · Aula 05](../modulos/14-build-android/05-permissoes-android.md) e [M16 · Aula 02](../modulos/16-publicacao-e-proximos-passos/02-app-store-connect.md) | M14-E09 e M16-E03 |
| As cinco peças da assinatura iOS | [M15 · Aula 07](../modulos/15-build-ios/07-certificados-e-provisioning.md) | M15-E08 e M15-E10 |
| Archive, IPA, TestFlight e build number | [M15 · Aulas 08 e 09](../modulos/15-build-ios/09-exportando-ipa-e-testflight.md) | M15-E13 e M15-E14 |
| Versão, tag, rollout e hotfix | [M16 · Aula 03](../modulos/16-publicacao-e-proximos-passos/03-versionamento-e-releases.md) | M16-E05 e M16-E06 |
| Workflow, runners, cota e segredos | [M16 · Aula 04](../modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md) | M16-E07 e M16-E09 |
| Símbolos, métricas e LGPD | [M16 · Aula 05](../modulos/16-publicacao-e-proximos-passos/05-monitoramento-e-feedback.md) e [M13 · Aula 07](../modulos/13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) | M16-E10 e M16-E11 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#cumulativa-05)
