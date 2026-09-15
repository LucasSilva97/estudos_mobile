# Avaliação — Módulo 12: Testes e debug

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Um quadro de erro abre com `EXCEPTION CAUGHT BY RENDERING LIBRARY`. Isso indica erro de: A) build, algo lançou dentro de `build`; B) layout, restrições e tamanho; C) estado, `setState` fora de hora; D) plugin nativo.  
2. Para medir desempenho no DevTools, o certo é rodar em: A) debug, porque só nele o DevTools conecta; B) profile, no aparelho mais fraco que você tem; C) release, porque é o que o usuário executa; D) debug no emulador, que é mais estável que o aparelho.  
3. `flutter analyze` terminou com sucesso, mas deixou 12 apontamentos na tela. A explicação é: A) os apontamentos são de nível `info`, e `info` não faz o comando falhar; B) o comando só falha quando o código não compila; C) `flutter_lints` só é aplicado no CI; D) faltou rodar `dart format` antes para o analisador contar.  
4. `pumpAndSettle()` fica preso até estourar o tempo limite quando: A) o widget não foi envolvido em `MaterialApp`; B) há na tela uma animação que nunca termina, como um `CircularProgressIndicator`; C) o finder encontrou mais de um widget; D) a tela do teste é 800 × 600.  
5. `listar()` devolve `Future<List<Materia>>`. O stub correto no mocktail é: A) `when(() => repo.listar()).thenReturn(Future.value(<Materia>[]))`; B) `when(() => repo.listar()).thenAnswer((_) async => <Materia>[])`; C) `when(repo.listar()).thenReturn(<Materia>[])`; D) `when(() => repo.listar()).thenAnswer((_) => <Materia>[])`.  
6. O app Android fecha sozinho, sem caixa vermelha e sem nada em `flutter logs`. O próximo passo é: A) abrir a aba Memory do DevTools; B) rodar `adb logcat -c`, reproduzir a falha e ler com `adb logcat -d` procurando `FATAL EXCEPTION`; C) rodar `flutter analyze --fatal-infos`; D) pôr um breakpoint condicional no `initState`.

7. Diferencie `print()` de `debugPrint()` e explique por que o lint `avoid_print` existe.  
8. Explique por que `setUp` é preferível a `setUpAll` quando o objeto preparado é mutável.  
9. Diferencie fake de mock e diga em que situação cada um é a escolha certa.  
10. Explique por que estabilizar um teste de integração com `await Future.delayed(Duration(seconds: 5))` é uma solução falsa, e o que fazer no lugar.

## 2. Prática

No `foco_lab`, crie `lib/dominio/meta_semanal.dart` com `MetaSemanal` (`minutosAlvo`, mais `minutosFeitos`, `progresso` entre 0 e 1 e `faltam`, calculados sobre `List<Sessao>`); o construtor rejeita `minutosAlvo` negativo com `ArgumentError`. Escreva `test/meta_semanal_test.dart` cobrindo lista vazia, a fronteira exata da meta, meta ultrapassada, alvo zero e a exceção. Depois monte `PainelMeta`, um widget que carrega a meta de um contrato de repositório injetado, e `test/painel_meta_test.dart` com um fake de `atraso` e `falha` configuráveis, verificando carregando, erro e sucesso. Feche com `dart format .`, `flutter analyze --fatal-infos` e `flutter test`.

| Critério | Pontos |
|---|---:|
| `MetaSemanal` com guarda de alvo zero, `clamp` no progresso e `ArgumentError` no construtor | 2 |
| Unitários com `group` e `setUp`, cobrindo lista vazia e a fronteira exata da meta | 2 |
| Exceção com função anônima em `throwsA(isA<ArgumentError>())` e progresso conferido com `closeTo` | 1 |
| Fake com `atraso` e `falha` configuráveis, injetado no widget | 2 |
| Teste de widget com `find.byKey`, `pump` após cada interação e sem Timer pendente | 2 |
| `dart format .`, `flutter analyze --fatal-infos` e `flutter test` sem apontamentos | 1 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze --fatal-infos` e `dart format --output=none --set-exit-if-changed .` sem apontamentos.
- `flutter test` verde, sem nenhum teste marcado com `skip`.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Não achar a sua linha no stack trace | [Aula 01](../modulos/12-testes-e-debug/01-lendo-stack-traces.md) | E01 |
| Escolher entre log e breakpoint | [Aula 02](../modulos/12-testes-e-debug/02-logs-e-breakpoints.md) | E02 |
| Layout que estoura e medição de desempenho | [Aula 03](../modulos/12-testes-e-debug/03-devtools.md) | E03 |
| Apontamentos `info` acumulados | [Aula 04](../modulos/12-testes-e-debug/04-analise-lint-formatacao.md) | E04 |
| Casos-limite e exceções nos unitários | [Aula 05](../modulos/12-testes-e-debug/05-testes-unitarios.md) | E05 |
| `pump`, finders e Timer pendente | [Aula 06](../modulos/12-testes-e-debug/06-testes-de-widget.md) | E06 |
| Dublês, `thenAnswer` e `registerFallbackValue` | [Aula 07](../modulos/12-testes-e-debug/07-mocks-e-fakes.md) | E07 |
| Teste de integração instável e diagnóstico nativo | [Aulas 08 e 09](../modulos/12-testes-e-debug/08-testes-de-integracao.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-12)
