# Avaliação — Módulo 14: Build e distribuição Android

> **Tempo sugerido:** 30 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. A diferença técnica entre debug e release é: A) debug usa AOT e release usa JIT; B) debug compila em JIT (por isso há hot reload) e release compila em AOT, sem asserts nem DevTools; C) os dois usam AOT e só muda a faixa "DEBUG" no canto; D) release é o debug com `--split-per-abi`.  
2. `applicationId` e `namespace` diferem porque: A) são sinônimos e precisam ser sempre iguais; B) o `applicationId` identifica o app para o sistema e para a loja, e o `namespace` é o pacote que o compilador usa para gerar `R` e `BuildConfig`; C) o `applicationId` é o nome exibido embaixo do ícone; D) o `namespace` é definido no `pubspec.yaml`.  
3. O Foco busca metas em uma API: funciona em `flutter run` e o APK de release não acessa a rede. Causa mais provável: A) `INTERNET` foi declarada em `android/app/src/debug/AndroidManifest.xml` e não no `main/`; B) `INTERNET` é perigosa e falta pedi-la em execução; C) faltou `flutter clean` antes do build; D) o R8 removeu o pacote `http`.  
4. O build de release falha com `Keystore file not found`. Causa mais comum: A) o keystore foi criado sem `-validity 10000`; B) o `storeFile` do `key.properties` usa barra invertida, que é escape em arquivos `.properties`; C) o `key.properties` foi commitado por engano; D) a senha do alias está errada.  
5. Você gerou `app-release.apk` sem mexer em `signingConfigs`. O resultado é: A) o build falha por não encontrar chave; B) o APK sai assinado com a chave de depuração — instala e funciona, mas a Play Console recusa o upload; C) o APK sai sem assinatura nenhuma e não instala; D) o Gradle cria um keystore novo a cada build.  
6. Publicar o Foco na Play Console e ainda mandar um instalável para dois colegas testarem pede: A) `--split-per-abi` para a loja e o AAB para os colegas; B) `flutter build appbundle --release` para a loja e o APK `arm64-v8a` para os colegas; C) o mesmo `app-release.aab` nos dois casos, porque o AAB instala direto; D) o APK universal para a loja, porque ele é menor que o AAB.

7. Diferencie a splash nativa da tela de carregamento feita em Flutter: quem desenha cada uma e o que é configurável na duração.  
8. Explique por que perder a chave de upload **sem** Play App Signing significa nunca mais atualizar o app publicado, e o que muda com o Play App Signing ativo.  
9. Explique por que instalação limpa e atualização por cima são dois testes diferentes, e qual defeito do Foco só o segundo revela.  
10. Diferencie `INSTALL_FAILED_UPDATE_INCOMPATIBLE` de `INSTALL_FAILED_NO_MATCHING_ABIS`: causa e correção de cada um.

## 2. Prática

Gere e **comprove** um release assinado do Foco (`br.com.estudos.foco`). Crie `android/key.properties` — com o `.gitignore` ajustado **antes** — e configure `signingConfigs` em `android/app/build.gradle.kts`, substituindo o `signingConfig = signingConfigs.getByName("debug")`. Rode `flutter clean`, gere o AAB com `--obfuscate --split-debug-info=simbolos/1.0.0` e o APK `arm64-v8a`. Instale o APK no aparelho e registre tudo em `docs/release-1.0.0.md`: comandos usados, saída de `apksigner verify --print-certs`, saída de `aapt dump permissions` e o checklist de validação preenchido.

| Critério | Pontos |
|---|---:|
| `key.properties` fora do Git e `signingConfigs` lendo dele | 2 |
| Bloco da chave de debug substituído e build de release concluído | 2 |
| AAB e APK `arm64-v8a` gerados, com ofuscação e símbolos arquivados | 2 |
| `apksigner verify` e `aapt dump permissions` colados no relatório | 2 |
| Checklist validado no aparelho: instalação limpa, atualização, modo avião, cold start | 2 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem erros e `flutter build appbundle --release` concluindo.
- `git status` não lista nenhum `*.jks`, `*.keystore` ou `key.properties`.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Modos de build e onde sai cada artefato | [Aula 01](../modulos/14-build-android/01-debug-profile-release.md) | E01 |
| Identidade, nome exibido e versão | [Aula 02](../modulos/14-build-android/02-identidade-do-app.md) | E02 |
| Ícone, splash e Android 12+ | [Aulas 03 e 04](../modulos/14-build-android/04-splash-screen.md) | E03 e E04 |
| Permissão no manifest errado | [Aula 05](../modulos/14-build-android/05-permissoes-android.md) | E05 |
| Keystore e assinatura no Gradle | [Aulas 06 e 07](../modulos/14-build-android/07-assinatura-no-gradle.md) | E06 |
| APK × AAB, instalação e diagnóstico | [Aulas 08 a 10](../modulos/14-build-android/09-instalando-e-validando.md) | E07 e E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-14)
