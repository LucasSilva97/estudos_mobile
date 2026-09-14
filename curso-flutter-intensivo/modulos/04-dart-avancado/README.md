# Módulo 04 — Dart Avançado

> **Nível:** Avançado · **Tempo estimado total:** 295 min (≈ 4 h 55 min de conteúdo)
> **Pré-requisito direto:** [Módulo 03 — Dart Intermediário](../03-dart-intermediario/README.md)

Este é o último módulo de **Dart puro no terminal**. Depois dele você abre o Flutter — e, quando
abrir, praticamente tudo que a tela faz (carregar, esperar, falhar, tentar de novo, mostrar estado)
vai ser uma aplicação direta do que está aqui.

Tudo neste módulo roda com o Dart que já veio junto com o Flutter **3.47.1** (Dart **3.13.1**),
com o comando `dart run` em um terminal do Windows 11.

---

## 🎯 O que você vai aprender

Ao terminar este módulo você será capaz de:

- **Tratar erros de verdade**: diferenciar `Exception` de `Error`, usar `try` / `catch` / `on` /
  `finally`, relançar com `rethrow`, ler um *stack trace* (*rastro de pilha* — a lista de chamadas
  de função que levou até o erro) e criar exceções próprias com nome e dados do seu domínio.
- **Decidir entre lançar exceção e devolver um erro como valor**, implementando o
  **Result pattern** (*padrão Resultado* — em vez de lançar, a função devolve um objeto que é
  "sucesso com valor" ou "falha com erro").
- **Escrever código assíncrono** (que espera algo demorado sem travar o programa): entender o
  *event loop* (*laço de eventos* — o mecanismo que decide o que o Dart executa a seguir),
  `Future`, `async` / `await`, `Future.wait`, `timeout` e tratamento de erro assíncrono.
- **Trabalhar com `Stream`** (*fluxo* — uma sequência de valores que chegam ao longo do tempo),
  criar streams com `async*`/`yield` e com `StreamController`, escutar, transformar e **cancelar**.
- **Usar recursos do Dart 3**: `record` (*registro* — um agrupamento leve de valores),
  *pattern matching* (*casamento de padrões*), `switch` como expressão e `sealed class`
  (*classe selada* — hierarquia fechada que o compilador consegue checar por inteiro).
- **Modelar estados de tela** (Carregando / Sucesso / Erro / Vazio) de forma que o compilador
  **obrigue** você a tratar todos os casos.
- **Configurar análise estática e lints**: `analysis_options.yaml`, `dart analyze`, `dart format`
  e uma verificação local no estilo CI (*Continuous Integration* — integração contínua: rodar
  automaticamente as checagens de qualidade antes de aceitar um código).
- **Usar isolates** (*isolados* — unidades de execução com memória própria) para trabalho pesado
  de CPU sem travar a interface, e **medir antes de otimizar**.

---

## ✅ Pré-requisitos

Antes de começar, você precisa ter concluído:

| Pré-requisito | Onde está | Por que é necessário |
|---|---|---|
| Módulo 03 — Dart Intermediário | [modulos/03-dart-intermediario/README.md](../03-dart-intermediario/README.md) | Classes, construtores, herança, interfaces, enums e **generics** — usados em todas as aulas daqui |
| Módulo 02 — Dart Básico | [modulos/02-dart-basico/README.md](../02-dart-basico/README.md) | Null safety, listas, maps e funções |
| Terminal funcionando | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) | Você vai rodar `dart run bin/...` o tempo todo |

Checagem rápida — abra o PowerShell e rode:

```powershell
flutter --version
```

A saída precisa mostrar `Flutter 3.47.1` e `Dart 3.13.1`. Se não mostrar, volte para
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) antes de seguir.

Você também precisa de um projeto Dart de terminal com a pasta `bin/` (o mesmo que você usou nos
módulos 02 e 03). Todos os exemplos deste módulo são salvos dentro de `bin/` e executados com
`dart run bin/<arquivo>.dart`.

---

## 🗺️ Ordem recomendada das aulas

Siga **nesta ordem**. Cada aula assume a anterior.

| # | Aula | Tempo | O que entra na sua cabeça |
|---|---|---|---|
| 1 | [01 — Exceptions e tratamento de erros](01-exceptions.md) | 35 min | `Exception` × `Error`, `throw`, `try/catch/on/finally`, `rethrow`, stack trace, exceções customizadas, Result pattern |
| 2 | [02 — Futures e async/await](02-futures-e-async-await.md) | 45 min | Síncrono × assíncrono, event loop, microtask, `Future`, `async`/`await`, `Future.wait`, `timeout`, `unawaited` |
| 3 | [03 — Streams](03-streams.md) | 45 min | `Stream`, single-subscription × broadcast, `listen`, `async*`/`yield`, `StreamController`, cancelamento, `map`/`where` |
| 4 | [04 — Records](04-records.md) | 30 min | Record posicional e nomeado, retorno múltiplo, *destructuring*, record × classe |
| 5 | [05 — Patterns e switch](05-patterns-e-switch.md) | 40 min | Pattern matching, `switch` expression, guard `when`, `if-case`, destructuring de List/Map/Record, exaustividade |
| 6 | [06 — Sealed classes](06-sealed-classes.md) | 35 min | `sealed`, `final`, `base`, `interface class`; estados Carregando/Sucesso/Erro/Vazio; comparação com `enum` e com `AsyncValue` |
| 7 | [07 — Análise estática e lints](07-analise-estatica-e-lints.md) | 30 min | `analysis_options.yaml`, `flutter_lints ^6.0.0`, `dart analyze`, `dart format`, `ignore_for_file`, CI local |
| 8 | [08 — Isolates e desempenho](08-isolates-e-desempenho.md) | 35 min | Concorrência do Dart, isolate, `Isolate.run`, `compute()`, medir com `Stopwatch` |

**Total: 295 min.** No [plano intensivo de 30 dias](../../01-plano-intensivo.md), este módulo inteiro
cai no **dia 8**. Se as 4 h do dia não forem suficientes, faça as aulas 1 a 5 no dia 8 e as aulas
6 a 8 logo no início do dia 9, antes da avaliação cumulativa.

---

## 📝 Exercícios e avaliação

| Etapa | Arquivo | Quando fazer |
|---|---|---|
| Exercícios do módulo | [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md) | Ao terminar cada aula, faça os exercícios que citam aquela aula |
| Gabarito comentado | [gabaritos/04-dart-avancado.md](../../gabaritos/04-dart-avancado.md) | **Só depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-04-dart-avancado.md](../../avaliacoes/modulo-04-dart-avancado.md) | Depois da aula 8 |
| Avaliação cumulativa de Dart | [avaliacoes/cumulativa-01-dart.md](../../avaliacoes/cumulativa-01-dart.md) | Dia 9 do plano, cobrindo os módulos 01 a 04 |

---

## 🔗 Para onde isso vai no Flutter

Nada aqui é teoria solta. Este é o mapa de reaproveitamento:

| Conceito deste módulo | Onde reaparece no Flutter |
|---|---|
| Exceptions e Result pattern | [09 — Modelando respostas e erros](../09-consumo-de-api/04-modelando-respostas-e-erros.md) |
| `Future` e `async/await` | [09 — Primeiro GET](../09-consumo-de-api/03-primeiro-get.md) e [13 — Assíncrono sem travar](../13-desempenho-e-seguranca/03-assincrono-sem-travar.md) |
| `Stream` | [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) e [11 — Conectividade](../11-recursos-nativos/05-conectividade.md) |
| Records e patterns | [08 — Notifier e NotifierProvider](../08-estado-e-arquitetura/06-notifier-e-notifierprovider.md) |
| Sealed classes | [06 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) |
| Lints e análise estática | [12 — Análise, lint e formatação](../12-testes-e-debug/04-analise-lint-formatacao.md) |
| Isolates e `compute()` | [13 — Medindo desempenho](../13-desempenho-e-seguranca/04-medindo-desempenho.md) |

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir fazer **sem consultar a aula**:

- [ ] Explico em uma frase a diferença entre `Exception` e `Error` e dou um exemplo de cada.
- [ ] Escrevo um `try` / `on` / `catch (e, s)` / `finally` correto e sei quando usar `rethrow`.
- [ ] Crio uma exceção customizada com `implements Exception` e `toString()` útil.
- [ ] Implemento um `Resultado<S, F>` com `sealed class` e consumo com `switch` exaustivo.
- [ ] Explico por que `await` não trava o programa e o que é o event loop.
- [ ] Uso `Future.wait` para rodar chamadas em paralelo e `timeout` para não esperar para sempre.
- [ ] Crio uma `Stream` com `async*`, escuto com `listen` e **cancelo** a `StreamSubscription`.
- [ ] Sei dizer, para um problema dado, se cabe `Future` ou `Stream`.
- [ ] Devolvo dois valores de uma função com record e faço *destructuring* no chamador.
- [ ] Escrevo um `switch` expression com guard `when` e sei quando ele é exaustivo.
- [ ] Modelo Carregando/Sucesso/Erro/Vazio com `sealed class` e trato todos no `switch`.
- [ ] Configuro `analysis_options.yaml`, rodo `dart analyze` e `dart format .` sem erros.
- [ ] Explico por que `ignore_for_file` deve ser raro.
- [ ] Movo um cálculo pesado para `Isolate.run` e meço a diferença com `Stopwatch`.
- [ ] Todos os exercícios **obrigatórios** de [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md) estão feitos.
- [ ] Acertei ao menos 7 das 10 questões de [avaliacoes/modulo-04-dart-avancado.md](../../avaliacoes/modulo-04-dart-avancado.md).

Quando todos estiverem marcados, siga para o
[Módulo 05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md).

---

## 📚 Referências oficiais do módulo

- [Error handling — dart.dev](https://dart.dev/language/error-handling)
- [Asynchronous programming — dart.dev](https://dart.dev/language/async)
- [Records — dart.dev](https://dart.dev/language/records)
- [Patterns — dart.dev](https://dart.dev/language/patterns)
- [Class modifiers — dart.dev](https://dart.dev/language/class-modifiers)
- [Customizing static analysis — dart.dev](https://dart.dev/tools/analysis)
- [Concurrency in Dart — dart.dev](https://dart.dev/language/concurrency)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 03 — Dart Intermediário](../03-dart-intermediario/README.md) | [README do curso](../../README.md) | [Aula 1 — Exceptions](01-exceptions.md) |
