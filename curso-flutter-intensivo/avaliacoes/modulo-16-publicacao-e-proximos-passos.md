# Avaliação — Módulo 16: Publicação e próximos passos

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Uma conta pessoal nova na Google Play só pode pedir acesso à produção depois de: A) publicar em teste aberto por 7 dias; B) manter um teste fechado com 12 testadores por 14 dias seguidos; C) concluir a verificação de identidade, que já basta; D) pagar a taxa de US$ 25 uma segunda vez.  
2. Com `version: 1.4.2+37` no `pubspec.yaml`, o `versionCode` do Android e o `CFBundleVersion` do iOS valem: A) `1.4.2`; B) `37`; C) `1.4.2+37`; D) `142`.  
3. Você enviou `1.0.1+3`, o build foi rejeitado e você corrigiu o problema. O próximo envio deve ser: A) `1.0.1+3` de novo, já que o nome da versão não mudou; B) `1.0.1+4`; C) `1.0.2+1`, reiniciando a contagem de build; D) `1.0.1+2`, reaproveitando o número que ficou livre.  
4. No workflow do Foco, `flutter analyze` e `flutter test` devem rodar em: A) `macos-latest`, para ficar igual ao ambiente do build iOS; B) `ubuntu-latest`, deixando o `macos-latest` só para o build iOS; C) `windows-latest`, porque você desenvolve no Windows; D) qualquer um — o consumo da cota é o mesmo.  
5. Configurar apenas `FlutterError.onError` no Crashlytics deixa passar: A) erros de build, layout e gestos; B) erros em `Future` sem `catch`, em isolates e em callbacks de plugin; C) nada — esse manipulador captura tudo; D) apenas os crashes nativos do Android.  
6. A 1.4.2 do Foco saiu com bug grave. Você interrompe o rollout na Play Console e reativa a 1.4.1. O resultado é: A) quem já atualizou volta sozinho para a 1.4.1; B) novas instalações recebem a 1.4.1, mas quem já atualizou continua na 1.4.2; C) a 1.4.2 é desinstalada dos aparelhos que a receberam; D) o mesmo procedimento vale na App Store.

7. Diferencie a chave de upload da chave de assinatura do app no Play App Signing, dizendo o que acontece se você perder cada uma.  
8. Explique por que a seção Segurança dos Dados da Play e a Nutrition Label da Apple precisam bater com o que o app realmente faz.  
9. Explique por que nunca se registra conteúdo digitado pelo usuário no crash reporting e o que registrar no lugar.  
10. Explique por que o branch de hotfix parte da tag `v1.4.2`, e não da `main`.

## 2. Prática

Prepare a release **1.1.0** do Foco (`br.com.estudos.foco`) no repositório local, **sem publicar nada em loja**. A versão atual é `1.0.3+7` e a novidade é a tela de metas semanais. Atualize `pubspec.yaml` e `CHANGELOG.md`, crie a tag anotada, escreva o `.github/workflows/ci.yml` que roda análise e testes a cada push e registre em `docs/release-1.1.0.md` a faixa de lançamento escolhida, o plano de rollout e os limites que disparam ação.

| Critério | Pontos |
|---|---:|
| `version: 1.1.0+8` no `pubspec.yaml`, com MINOR e build justificados | 2 |
| `CHANGELOG.md` com `## [1.1.0] — <data>` e categorias corretas | 2 |
| Tag anotada `v1.1.0` criada e verificável por `git show v1.1.0` | 1 |
| `ci.yml` em `ubuntu-latest`, com Flutter 3.47.1, `flutter analyze` e `flutter test`, sem segredo escrito no YAML | 3 |
| `docs/release-1.1.0.md` com faixa, rollout gradual e limites de Android vitals | 2 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem erros e o workflow verde na aba **Actions**.
- Plano de 90 dias escrito, com as metas da primeira semana definidas.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Chaves, faixas e ficha da Play | [Aula 1](../modulos/16-publicacao-e-proximos-passos/01-google-play.md) | E01 e E02 |
| Ficha, privacidade e revisão da Apple | [Aula 2](../modulos/16-publicacao-e-proximos-passos/02-app-store-connect.md) | E03 |
| Numeração, tags, rollout e hotfix | [Aula 3](../modulos/16-publicacao-e-proximos-passos/03-versionamento-e-releases.md) | E04 e E05 |
| Workflow, runners e segredos | [Aula 4](../modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md) | E06 |
| Crashes, símbolos, métricas e LGPD | [Aula 5](../modulos/16-publicacao-e-proximos-passos/05-monitoramento-e-feedback.md) | E07 |
| Escolher o caminho depois do curso | [Aula 6](../modulos/16-publicacao-e-proximos-passos/06-proximos-passos.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-16)
