# Exercícios — Módulo 12: Testes e debug

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Rode `flutter analyze`, `dart format .` e `flutter test` antes de consultar o gabarito.

<a id="m12-e01"></a>
## M12-E01 — Cinco erros, cinco causas · Diagnóstico
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Ler um quadro `EXCEPTION CAUGHT BY` | Fácil | 20 min | Sim |
Rode `flutter run -d windows -t lib/laboratorio/tela_de_erros.dart` e abra os cinco itens do menu. Para cada erro anote três coisas: a frase logo depois de `The following ... was thrown`, a classificação (build · layout · estado) e a **primeira** linha `package:foco_lab/` do stack trace. **Esperado:** cinco fichas apontando arquivo e linha exatos, escritas sem reabrir a aula. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e01)

<a id="m12-e02"></a>
## M12-E02 — Cronômetro instrumentado · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Trocar `print` por log e parar no ponto certo | Média | 25 min | Sim |
Em `lib/laboratorio/cronometro_sessao.dart`, registre início, pausa e falha de gravação com `developer.log`, sempre com `name: 'foco.sessoes'` e `level` 800 para informação e 1000 para erro (com `error` e `stackTrace` preenchidos). Depois ponha um breakpoint condicional em `setState(() => _sessao.segundos++)` com `_sessao.segundos % 10 == 0`. **Esperado:** `dart analyze` sem `avoid_print`, a aba Logging do DevTools filtrando `foco.sessoes`, e a execução parando de 10 em 10 segundos. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e02)

<a id="m12-e03"></a>
## M12-E03 — O `Row` que estoura, medido · Diagnóstico
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Provar a causa no Layout Explorer | Média | 25 min | Sim |
Abra a `TelaOverflow`, selecione a `Row` no Flutter Inspector e use o **Layout Explorer** para anotar: a largura que cada filho pede, a largura disponível e quantos pixels sobraram. Só então corrija, envolvendo o `Text` em `Expanded` com `overflow: TextOverflow.ellipsis`. **Esperado:** a faixa amarela e preta some e o Layout Explorer mostra a soma dos filhos cabendo na constraint — com os números de antes e depois anotados. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e03)

<a id="m12-e04"></a>
## M12-E04 — Orçamento de 16 ms · Medição
Rode `flutter run --profile`, abra a aba **Performance** na `TelaLenta` e role a lista por 5 segundos. Registre o pior quadro em milissegundos, se o gargalo está em **UI** ou em **Raster**, e a função mais cara apontada pelo CPU Profiler. Corrija e meça de novo. **Esperado:** dois números comparáveis, com o pior quadro abaixo de 16 ms depois da correção — e a explicação de por que medir em `--profile`, não em debug. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e04)

<a id="m12-e05"></a>
## M12-E05 — Escada na memória · Investigação
Na `TelaQueVaza`, siga o roteiro da aula: force **GC**, anote o valor, entre e saia da tela 20 vezes, force GC de novo. Use **Diff Snapshots** para nomear a classe que ficou retida e diga qual `dispose`/`cancel` está faltando. **Esperado:** antes da correção o gráfico sobe em escada; depois, o valor após o segundo GC volta ao patamar inicial (±2 MB). [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e05)

<a id="m12-e06"></a>
## M12-E06 — `analysis_options` que pega bug · Configuração
Escreva o `foco_lab/analysis_options.yaml` do zero: `include: package:flutter_lints/flutter.yaml`; promova a `error` as regras `use_build_context_synchronously`, `unawaited_futures`, `cancel_subscriptions` e `close_sinks`; rebaixe `todo` para `ignore`; exclua `**/*.g.dart` e `build/**`; ligue `strict-casts` e `strict-raw-types`. **Teste:** `flutter analyze` termina com `No issues found!` no projeto limpo e acusa **erro** (não aviso) nos defeitos do E07. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e06)

<a id="m12-e07"></a>
## M12-E07 — O que o analisador pegou · Correção de bugs
`lib/exemplo_analise.dart` tem três defeitos reais: um `ScaffoldMessenger.of(context)` chamado depois de um `await` sem checar `mounted`; um `Future` de gravação disparado sem `await`; e um `final String nome = json['nome'];` sem cast, que `strict-casts` reprova. Corrija os três **sem** usar `// ignore:` e explique, em uma linha cada, que bug de produção aquela regra evita. **Esperado:** `flutter analyze` limpo e `dart format .` sem alterar mais nada. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e07)

<a id="m12-e08"></a>
## M12-E08 — Os limites da `Sessao` · Casos-limite
Em `test/sessao_test.dart`, cubra as bordas com `group` e `setUp`: `minutos` valendo 0, 1, 14, 15, 240, 241, 480 e 481; `materiaId` só com espaços; `Estatisticas.totalDeMinutos(<Sessao>[])`; `materiaEmDestaque(<Sessao>[])`; e `sequenciaDeDias` com duas sessões no **mesmo** dia. **Teste:** `flutter test test/sessao_test.dart` — `throwsA(isA<SessaoInvalida>())` nos dois extremos de minutos, `throwsA(isA<ArgumentError>())` no id vazio, e a `classificacao` certa em cada fronteira. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e08)

<a id="m12-e09"></a>
## M12-E09 — A sequência que zerou · Regressão
Relato do usuário: *"estudei ontem e hoje; abri o app às 00h05 e a sequência apareceu como 0"*. A causa está em `Estatisticas.sequenciaDeDias`, que conta para trás a partir de `hoje` e exige sessão no próprio dia. Escreva **primeiro** o teste que reproduz o relato (com `hoje` fixo, nunca `DateTime.now()`), veja-o falhar, corrija para tolerar o dia corrente ainda sem sessão, e veja-o passar. **Esperado:** o teste falha antes e passa depois; o resto da suíte continua verde. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e09)

<a id="m12-e10"></a>
## M12-E10 — O formulário inteiro · Aplicação
Escreva `test/form_materia_test.dart` com cinco `testWidgets` sobre `FormMateria`: botão desabilitado com nome vazio; digitar em `Key('campo_nome')` habilita o botão (com o `await t.pump()` depois do `enterText`); nome de 1 letra exibe "Use pelo menos 2 letras"; meta 4 exibe "Entre 5 e 480 minutos"; e, com `aoSalvar` atrasado em 2 s, `Key('indicador')` aparece e o `FilledButton.onPressed` fica `null`. **Teste:** o quinto termina com `await t.pump(const Duration(seconds: 2))` — sem isso ele falha com `A Timer is still pending even after the widget tree was disposed`. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e10)

<a id="m12-e11"></a>
## M12-E11 — Três testes quebrados · Correção de bugs
Crie `test/apoio/dubles.dart` com `RelogioFake`, `MateriaRepositorioFake` e `AnalyticsMock`, e conserte três falhas do `sincronizador_test.dart`: (1) `type 'Null' is not a subtype of type 'Future<List<Materia>>'` num mock sem `when`; (2) `Bad state: A test tried to use any ...` ao passar `any()` de tipo `Materia`; (3) um `verify(() => analytics.registrar('sync_ok', any())).called(1)` que passa mesmo com os dados errados. **Esperado:** (1) `when(...).thenAnswer((_) async => ...)`, (2) `registerFallbackValue(MateriaFalsa())` em `setUpAll`, (3) `captureAny()` conferindo o conteúdo do evento. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e11)

<a id="m12-e12"></a>
## M12-E12 — Fluxo completo de verdade · Aplicação
Escreva `integration_test/fluxo_completo_test.dart`: abre o app, cria a matéria "Cálculo I" com meta 90, registra uma sessão de 45 min e confere "50%" no resumo — usando `esperarPor`, `digitar` e `tocarComRolagem` de `integration_test/apoio/ajudantes.dart`, e limpando o banco no `setUp`. Nada de `Future.delayed` com tempo fixo. **Teste:** `flutter test integration_test/fluxo_completo_test.dart -d windows` passa **duas vezes seguidas**, sem `flutter clean` entre elas. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e12)

<a id="m12-e13"></a>
## M12-E13 — Promover, ou não · Decisão
Em cerca de 10 linhas, decida dois casos e justifique: (a) promover `prefer_const_constructors` a `error` no `analysis_options.yaml` do `foco_lab`; (b) escrever um teste de integração para "editar o nome de uma matéria". Em cada um, pese **custo** (tempo de suíte, atrito no commit) contra **risco evitado**, e diga qual fato novo faria você mudar de ideia. **Esperado:** uma decisão explícita por caso — "sim, porque…" ou "não, porque…" —, nunca "depende". [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e13)

<a id="m12-e14"></a>
## M12-E14 — Onde investir o seu tempo · Reflexão
Liste os cinco últimos erros que você enfrentou no `foco_lab` e classifique cada um por quem o pegaria mais barato: teste de unidade, de widget, de integração, ou só build/aparelho (`adb logcat`). Depois responda, em ~10 linhas: que camada da pirâmide te daria mais retorno agora, e em que ponto você pararia de insistir num erro nativo e escalaria — com que evidências em mãos (`flutter doctor -v`, log coletado com `adb logcat -c` antes de reproduzir, "o que mudou"). **Esperado:** conclusão apoiada nos seus cinco casos, não em opinião geral. [🔑 Gabarito](../gabaritos/12-testes-e-debug.md#m12-e14)

[Módulo](../modulos/12-testes-e-debug/README.md)
