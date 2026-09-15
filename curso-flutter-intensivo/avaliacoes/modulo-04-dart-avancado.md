# Avaliação — Módulo 04: Dart avançado

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Dentro de um `catch`, para relançar preservando o stack trace original você usa: A) `throw e;`; B) `rethrow;`; C) `throw Exception(e);`; D) `return;`.  
2. Três chamadas independentes de 1 s cada, feitas com `await` dentro de um `for`, levam ~3 s. Para cair para ~1 s: A) marque a função com `async`; B) monte a lista e use `Future.wait`; C) troque `await` por `unawaited`; D) aumente o `timeout`.  
3. Chamar `listen` duas vezes em uma stream single-subscription: A) lança `Bad state: Stream has already been listened to.`; B) converte a stream em broadcast; C) entrega os eventos aos dois ouvintes; D) faz o segundo ouvinte receber só os eventos novos.  
4. Em um record posicional, o primeiro campo é acessado por: A) `$0`; B) `$1`; C) `[0]`; D) `.primeiro`.  
5. Um `switch` **expressão** sobre `int` acusa `The type 'int' is not exhaustively matched`. Falta: A) `break` no último caso; B) um caso `_ => ...`; C) a palavra `case` em cada linha; D) um `default:`.  
6. Um cálculo de CPU de 4 s congela a tela mesmo com `await`. A correção é: A) marcar a função com `async`; B) mover o cálculo para `Isolate.run`; C) envolver as chamadas em `Future.wait`; D) reduzir o `timeout`.

7. Diferencie `sealed class` de `enum` para modelar os estados da tela de sessões do app Foco.  
8. Explique por que incluir `_` em um `switch` sobre uma `sealed class` enfraquece a proteção do compilador.  
9. Explique por que `ignore_for_file` deve ser raro e o que fazer no lugar dele.  
10. Diferencie `Future` de `Stream` e dê um caso de cada no app Foco.

## 2. Prática

Crie `bin/avaliacao04_foco.dart` e monte o carregamento de sessões de estudo do Foco de ponta a ponta: uma exceção de domínio `SessaoInvalidaException` que carrega dados, um `Resultado<S, F>` selado e uma busca assíncrona falsa com `Future.delayed` e `.timeout(const Duration(seconds: 2))`. Converta o resultado em um `EstadoTela` selado (`Carregando` / `Vazio` / `SucessoEstado` / `ErroEstado`) e renderize com `switch` expressão **sem** `_`. Rode três matérias: uma que responde rápido, uma que volta vazia e uma que estoura o tempo. Para a que deu certo, calcule total e média de minutos dentro de `Isolate.run`, devolvendo um record `({int total, double media})` lido por destructuring. Feche com `dart analyze` e `dart format --output=none --set-exit-if-changed .` limpos.

| Critério | Pontos |
|---|---:|
| Exceção de domínio com dados e `Resultado<S, F>` selado | 2 |
| Busca assíncrona com `.timeout` e falha tratada por tipo (`on TimeoutException`) | 2 |
| `EstadoTela` selado com os quatro casos e `switch` expressão sem `_` | 2 |
| Resumo calculado em `Isolate.run`, devolvido em record e lido por destructuring | 2 |
| `dart analyze` e `dart format` sem apontamentos | 2 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `dart analyze` sem erros e `dart format` sem mudanças pendentes.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Tratamento de erro e Result pattern | [Aula 01](../modulos/04-dart-avancado/01-exceptions.md) | E01 e E02 |
| Espera assíncrona, `Future.wait` e `timeout` | [Aula 02](../modulos/04-dart-avancado/02-futures-e-async-await.md) | E03 |
| Streams, ouvintes e cancelamento | [Aula 03](../modulos/04-dart-avancado/03-streams.md) | E04 |
| Records, patterns e exaustividade | [Aulas 04 e 05](../modulos/04-dart-avancado/05-patterns-e-switch.md) | E05 e E06 |
| Estados selados, lints e isolates | [Aulas 06 e 08](../modulos/04-dart-avancado/06-sealed-classes.md) | E07 e E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-04)
