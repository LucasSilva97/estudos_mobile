# Exercícios — Módulo 04: Dart avançado

> Faça E01–E08 obrigatoriamente. E09–E12 são opcionais. Todos rodam em `bin/` com `dart run`. Execute `dart format .` e `dart analyze` (sem apontamentos) antes de consultar o gabarito.

<a id="m04-e01"></a>
## M04-E01 — Exceção do domínio · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Criar, lançar e capturar exceção própria | Fácil | 15 min | Sim |
Crie `SessaoInvalidaException implements Exception` com os campos `materia` e `motivo` e `toString()` no formato `SessaoInvalidaException: "Dart" — minutos precisam ser positivos`. Lance-a em `registrarSessao(String materia, int minutos)` quando a matéria for vazia ou os minutos forem menores ou iguais a zero, e capture com `on SessaoInvalidaException catch (e)`. **Teste:** `('Dart', 45)`, `('', 45)` e `('Dart', 0)`. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e01)

<a id="m04-e02"></a>
## M04-E02 — Resultado no lugar do `throw` · Implementação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Result pattern com `sealed class` | Média | 25 min | Sim |
Implemente `sealed class Resultado<S, F>` com `final class Sucesso<S, F>` e `final class Falha<S, F>`, e escreva `Resultado<int, String> registrarComResultado(String materia, int minutos)` que converta a exceção do E01 em `Falha`. Consuma com `switch` expressão usando `Sucesso(:final valor)` e `Falha(:final erro)`. **Esperado:** o chamador não tem nenhum `try` e o analisador aceita o `switch` sem caso `_`. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e02)

<a id="m04-e03"></a>
## M04-E03 — `catch` que engole o bug · Correção de bugs
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Distinguir `Exception` de `Error` e usar `rethrow` | Média | 20 min | Sim |
O código atual envolve `registrarSessao` em `catch (e) { print('deu erro'); }`: ele captura também o `RangeError` de um índice fora da lista, esconde o bug, descarta o *stack trace* e não deixa o chamador reagir. Reescreva com `on SessaoInvalidaException catch (e, s)` — registre `e` e as três primeiras linhas de `s` e use `rethrow` — deixando `Error` subir sem tratamento. **Esperado:** o `RangeError` derruba o programa com o rastro de pilha visível; a exceção de domínio é logada e relançada. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e03)

<a id="m04-e04"></a>
## M04-E04 — Painel em paralelo · Aplicação
`carregarMaterias()`, `carregarMinutosDaSemana()` e `carregarFraseDoDia()` levam 1 s cada. Troque os três `await` sequenciais por um único `Future.wait`, aplique `.timeout(const Duration(seconds: 2))` sobre ele e meça as duas versões com `Stopwatch`. **Esperado:** cai de ~3 s para ~1 s; baixando o prazo para 500 ms você recebe `TimeoutException`. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e04)

<a id="m04-e05"></a>
## M04-E05 — Ordem do event loop · Leitura de código
Dado um `main` que executa, nesta ordem, `print('1')`, `Future(() => print('2'))`, `Future.microtask(() => print('3'))` e `print('4')`: escreva **antes de rodar** a ordem de saída que você espera, rode e explique em duas frases por que a microtask fura a fila dos eventos. **Esperado:** sua previsão bate com a saída do terminal. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e05)

<a id="m04-e06"></a>
## M04-E06 — Stream da sessão com cancelamento · Implementação
Escreva `Stream<int> minutosDaSessao(int total) async*` que emite `1..total` com `Duration(milliseconds: 100)` entre os eventos. Escute com `listen`, guarde a `StreamSubscription` e chame `await assinatura.cancel()` ao receber o minuto 3. **Esperado:** exatamente três eventos impressos e o programa termina sem esperar os minutos restantes. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e06)

<a id="m04-e07"></a>
## M04-E07 — Resumo da semana em record · Fixação
Escreva `({int minimo, int maximo, double media}) estatisticas(List<int> minutos)` e consuma no chamador com destructuring `final (:minimo, :maximo, :media) = estatisticas(...)`. Para lista vazia devolva `(minimo: 0, maximo: 0, media: 0)`. **Teste:** `[30, 90, 45]` e `[]`. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e07)

<a id="m04-e08"></a>
## M04-E08 — Estado da tela de matérias · Revisão cumulativa
Modele `sealed class EstadoTela<T>` com `Carregando`, `Vazio`, `Sucesso` e `ErroEstado`, e escreva `EstadoTela<List<String>> paraEstado(Resultado<List<String>, String> resultado)` reusando o `Resultado` do E02 — sucesso com lista sem itens vira `Vazio`. Descreva cada estado em um `switch` expressão. **Esperado:** apagar um dos quatro casos faz o `dart analyze` acusar falta de exaustividade. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e08)

<a id="m04-e09"></a>
## M04-E09 — Ordem dos casos · Correção de bugs
Neste `switch` sobre `Sessao`, o caso genérico `Sessao(:final materia)` foi escrito primeiro, então `Sessao(concluida: false)` e `Sessao(:final minutos) when minutos >= 60` nunca são alcançados — e um deles testa a duração com `if` dentro do corpo em vez de `when`. Reordene do mais específico para o mais genérico e troque o `if` pelo guard. **Teste:** sessão de 90 min concluída, de 90 min em andamento e de 20 min concluída. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e09)

<a id="m04-e10"></a>
## M04-E10 — Analisador limpo · Aplicação
Crie na raiz um `analysis_options.yaml` com `include: package:lints/recommended.yaml`, `unused_local_variable: error`, `strict-casts` e as regras `prefer_final_locals`, `unawaited_futures` e `cancel_subscriptions`; depois crie `verificar.ps1` com `dart format --output=none --set-exit-if-changed .` seguido de `dart analyze --fatal-infos`. Corrija os apontamentos do seu E06 em vez de silenciá-los. **Esperado:** `No issues found!` e `verificar.ps1` termina sem falhar. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e10)

<a id="m04-e11"></a>
## M04-E11 — Cálculo pesado sem travar · Desafio
Meça `somaDosPrimos(2000000)` com `Stopwatch` em duas versões: chamada direta e `await Isolate.run(() => somaDosPrimos(2000000))`. Nas duas, mantenha um `Stream.periodic` imprimindo um tique a cada 200 ms. **Esperado:** na versão direta os tiques somem durante o cálculo; com `Isolate.run` eles continuam saindo. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e11)

<a id="m04-e12"></a>
## M04-E12 — Painel do Foco · Desafio prático
Monte `bin/painel_foco.dart` juntando as aulas 1 a 8: um repositório fake assíncrono de matérias que falha em uma das chamadas, `Resultado` convertido em `EstadoTela` pelo E08, progresso da sessão por `Stream`, resumo semanal em record e o ranking de minutos calculado em `Isolate.run`. **Esperado:** a saída percorre Carregando → Sucesso/Vazio/ErroEstado e `dart analyze` fica sem apontamentos. [🔑 Gabarito](../gabaritos/04-dart-avancado.md#m04-e12)

[Módulo](../modulos/04-dart-avancado/README.md)
