# Avaliação — Cumulativa 04: Qualidade e plataforma

> Cobre os **módulos 11 a 13**. Aqui nada se resolve olhando um módulo só: cada questão e cada
> critério da prática pedem que você junte recurso nativo, teste e desempenho na mesma resposta.

> **Tempo sugerido:** 35 min de questões + 75 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto — 12 pontos no total.

1. A capa da matéria veio da galeria por `image_picker`: um JPEG de 4032 × 3024 exibido num avatar de 56 dp. O que evita os ~48 MB de bitmap na memória: A) `width: 56` no `Image.file`; B) `BoxFit.cover`; C) `cacheWidth`/`cacheHeight` calculados pelo `devicePixelRatio`; D) guardar o `XFile.path` no sqflite.  
2. Você quer um teste de widget provando que `BotaoSalvarSessao` vira `CupertinoButton` no 🍎 iOS. A forma testável é: A) `Platform.isIOS`, que o teste sobrescreve; B) montar com `MaterialApp(theme: ThemeData(platform: TargetPlatform.iOS))` e decidir por `Theme.of(context).platform`; C) só num Mac, em teste de integração; D) `kIsWeb`.  
3. O teste de widget da faixa de offline quebra com `MissingPluginException`. A causa e a saída: A) faltou `IntegrationTestWidgetsFlutterBinding`; B) faltou `pumpAndSettle`; C) faltou `registerFallbackValue` no `setUpAll`; D) `connectivity_plus` não existe no ambiente de teste — injete um fake do contrato `ObservadorDeRede` por `overrides`.  
4. `flutter test` está verde e a rolagem de matérias trava no aparelho. Isso acontece porque: A) faltam testes de integração; B) o teste de widget roda em debug, com relógio virtual e sem thread de raster — ele não mede quadro; C) `pumpAndSettle` esconde o jank; D) o analisador não reprova `ListView(children:)`.  
5. Ao mandar o resumo de 50 000 sessões para `Isolate.run`, o que **não** pode atravessar a fronteira: A) o `BuildContext`, o `WidgetRef` e o `Database` aberto do sqflite; B) uma `List<Map<String, Object?>>`; C) um `int` de minutos; D) uma `String` com o nome da matéria.  
6. Para `await expectLater(tester, meetsGuideline(androidTapTargetGuideline))` valer alguma coisa, o teste precisa: A) rodar em modo profile; B) usar `find.bySemanticsLabel`; C) chamar `tester.ensureSemantics()` antes e `handle.dispose()` no fim; D) rodar num aparelho com o TalkBack ligado.  
7. O Foco sincroniza com uma API. A URL base e o token de acesso do usuário ficam: A) ambos em `--dart-define`; B) URL em `--dart-define` e token em `flutter_secure_storage`; C) ambos em `SharedPreferences`; D) ambos numa tabela do sqflite, que já é do app.  
8. Um usuário mandou o stack trace de uma release ofuscada, cheio de nomes como `ce` e `a1`. Para ler: A) rodar em debug e esperar repetir; B) rebuildar sem `--obfuscate` e pedir para ele repetir; C) `adb logcat -d` no aparelho dele; D) `flutter symbolize -i crash.txt -d build/simbolos/<versão>/app.android-arm64.symbols`, com os símbolos **daquele** build.

9. Explique por que a regra "sessão com 12 h ou mais é descartada" deve viver no domínio, e não dentro do callback de `paused` do `AppLifecycleListener` — e o que isso muda no teste.  
10. Diferencie o que `flutter test` garante do que uma medição em modo profile garante, usando a lista de matérias do Foco como exemplo.  
11. Explique por que `meetsGuideline` no CI não substitui um teste com TalkBack no 🤖 Android e VoiceOver no 🍎 iOS, e cite dois problemas que só aparecem no aparelho.  
12. Diferencie o que `--obfuscate` protege do que `flutter_secure_storage` protege, e diga por que nenhum dos dois torna seguro um segredo embutido no binário.

## 2. Prática

No projeto `foco_qualidade`, parta da `SessaoScreen` do módulo 11 — cronômetro pelo carimbo de início,
`AppLifecycleListener` salvando em `paused`, faixa de offline — e leve-a até qualidade de produção.
Extraia as regras para o domínio (`SessaoEmAndamento.duracao` e o descarte de sessão suspeita), injete
`ObservadorDeRede` e `RelogioDoApp` por provider para que nenhum teste dependa de plugin, e escreva as
três camadas: unitário do domínio, de widget com fake e `meetsGuideline`, e um de integração do fluxo
iniciar → pausar → retomar → salvar. Depois meça a lista de 5 000 matérias com `flutter run --profile`,
corrija o que a medição apontar, troque o `rawQuery` interpolado do `MateriaDao` por `where`/`whereArgs`
e gere a release com `--obfuscate --split-debug-info`.

| Critério | Pontos |
|---|---:|
| Domínio isolado: duração pelo carimbo e descarte de 12 h, sem `BuildContext` | 2 |
| `ObservadorDeRede` e `RelogioDoApp` injetados; fake nos testes, sem `MissingPluginException` | 2 |
| Teste de widget com `ensureSemantics` e `meetsGuideline` nas quatro diretrizes | 1 |
| Integração do fluxo iniciar → pausar → retomar → salvar, sem `Future.delayed` de estabilização | 1 |
| Adaptação por `Theme.of(context).platform`, provada em teste com `TargetPlatform.iOS` | 1 |
| Medição em profile: pior quadro antes e depois, com UI × raster identificados | 1 |
| `ListView.builder` com `ValueKey(materia.id)`, capa com `cacheWidth` e resumo em `Isolate.run` | 1 |
| Busca com `where`/`whereArgs`, nenhum segredo no código e símbolos do build guardados | 1 |

## 3. Critérios para avançar

- 9/12 no questionário e 8/10 na prática.
- M11-E01 a M11-E14, M12-E01 a M12-E14 e M13-E01 a M13-E14 concluídos e conferidos.
- `flutter analyze --fatal-infos` e `dart format --output=none --set-exit-if-changed .` sem apontamentos.
- `flutter test` verde, sem nenhum teste marcado com `skip`.
- Medição em profile registrada, com o pior quadro antes e depois.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Adaptar por plataforma sem `Platform.isIOS` | [M11 · Aula 09](../modulos/11-recursos-nativos/09-material-x-cupertino.md) | M11-E13 |
| Plugin nativo dentro de teste | [M12 · Aula 07](../modulos/12-testes-e-debug/07-mocks-e-fakes.md) e [M11 · Aula 05](../modulos/11-recursos-nativos/05-conectividade.md) | M12-E11 e M11-E09 |
| Ciclo de vida e cronômetro que mente | [M11 · Aula 06](../modulos/11-recursos-nativos/06-ciclo-de-vida-do-app.md) | M11-E07 |
| Teste verde e app travando | [M12 · Aula 03](../modulos/12-testes-e-debug/03-devtools.md) e [M13 · Aula 04](../modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md) | M13-E06 |
| Memória de imagem e listas grandes | [M13 · Aula 02](../modulos/13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md) | M13-E03 e M13-E04 |
| Trabalho pesado sem travar a UI | [M13 · Aula 03](../modulos/13-desempenho-e-seguranca/03-assincrono-sem-travar.md) | M13-E05 e M13-E11 |
| Acessibilidade verificada em teste | [M13 · Aula 05](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md) e [M12 · Aula 06](../modulos/12-testes-e-debug/06-testes-de-widget.md) | M13-E07 e M13-E12 |
| Segredos, `whereArgs` e símbolos | [M13 · Aulas 06 e 07](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md) | M13-E08 e M13-E14 |
| Fluxo completo e teste instável | [M12 · Aula 08](../modulos/12-testes-e-debug/08-testes-de-integracao.md) | M12-E12 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#cumulativa-04)
