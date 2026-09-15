# Exercícios — Módulo 08: Estado e arquitetura

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Trabalhe no projeto `foco_estado` e rode `flutter analyze` (sem nenhum aviso) e `flutter test` antes de consultar o gabarito.

<a id="m08-e01"></a>
## M08-E01 — Quatro sintomas no `main.dart` · Diagnóstico
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Reconhecer que falta gerenciamento de estado | Fácil | 20 min | Sim |
Revise o `lib/main.dart` da Aula 1 e aponte, citando o widget, uma evidência de cada sintoma: *rebuild* em excesso, estado perdido ao navegar, regra de negócio na UI (onde está `progresso = minutos ÷ meta`?) e impossibilidade de testar sem `WidgetTester`. **Esperado:** quatro itens, cada um com widget, evidência e uma frase de justificativa. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e01)

<a id="m08-e02"></a>
## M08-E02 — Elevar `EstadoFoco` · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Elevar estado e isolar a regra derivada | Média | 30 min | Sim |
Agrupe `minutosHoje`, `metaDiaria` e `materias` na classe imutável `EstadoFoco`, com `copyWith`, `progresso` e `faltam`, guardada em `_CascaFocoState`; `CartaoResumo` recebe o valor por parâmetro e `LinhaDeBotoes` devolve a ordem por *callback*. **Teste:** `test/estado_foco_test.dart` verifica `progresso` e `faltam` sem montar nenhum widget. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e02)

<a id="m08-e03"></a>
## M08-E03 — `EscopoFoco` que nunca notifica · Correção de bugs
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Depurar dependência de `InheritedWidget` | Média | 25 min | Sim |
Neste `EscopoFoco`, `updateShouldNotify` devolve `false` e o `of(context)` usa `getInheritedWidgetOfExactType`: a `AbaHoje` fica congelada mesmo com o estado mudando. Corrija os dois pontos, usando `!identical(estado, anterior.estado)` e `dependOnInheritedWidgetOfExactType`. **Esperado:** registrar sessão atualiza o cartão sem nenhum `setState` dentro das abas. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e03)

<a id="m08-e04"></a>
## M08-E04 — Tabela de decisão do Foco · Decisão
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Escolher a solução pelo problema, não pela moda | Fácil | 20 min | Sim |
Escreva `docs/decisao-de-estado.md` classificando quatro estados — aba selecionada da `NavigationBar`, texto digitado no campo de nova matéria, lista de matérias e trilhas vindas do servidor — entre `setState`, elevação e Riverpod. **Esperado:** uma justificativa por linha respondendo se o dado é compartilhado e se precisa sobreviver à tela; pelo menos um deles continua em `setState`. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e04)

<a id="m08-e05"></a>
## M08-E05 — `watch`, `read` e `listen` · Compreensão
Responda por escrito, com um trecho do Foco em cada caso: por que `ref.watch` vai no `build`, `ref.read` em *callbacks* e `ref.listen` em efeitos colaterais (`SnackBar`, navegação); e o que o `ProviderScope` guarda, já que o provider é variável global. **Esperado:** explicar por que `ref.read` no `build` congela a tela **sem** lançar erro, enquanto `ref.watch` dentro de um `onPressed` dá erro em execução. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e05)

<a id="m08-e06"></a>
## M08-E06 — Painel diário derivado · Aplicação
A partir de `minutosHojeProvider`, `sessoesHojeProvider` e `metaDiariaProvider`, escreva os derivados `progressoDiarioProvider` (0.0 a 1.0), `minutosRestantesProvider`, `metaAtingidaProvider` e `mediaPorSessaoProvider` (devolve `'—'` quando não há sessão). Dentro de provider, dependência é sempre `watch`. **Teste:** com `debugPrint` no `build` de cada cartão, alterar a meta reconstrói só quem depende dela. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e06)

<a id="m08-e07"></a>
## M08-E07 — `state.add` silencioso · Correção de bugs
`MateriasNotifier.adicionar` faz `state.add(nova)` e a lista na tela não muda — sem nenhum erro no console — e `Materia` não sobrescreve `==`/`hashCode`. Substitua pela atribuição de uma lista nova (`state = <Materia>[...state, nova]`) e implemente igualdade por valor com `Object.hash`. **Teste:** adicionar uma matéria atualiza a `ListView`; salvar a mesma matéria duas vezes não dispara *rebuild* na segunda. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e07)

<a id="m08-e08"></a>
## M08-E08 — CRUD imutável de matérias · Aplicação
Complete `MateriasNotifier` com `remover(id)`, `renomear(id, novoNome)` e `definirMeta(id, minutos)`, usando `where`/`toList` e *collection for* com `copyWith`; recuse nome vazio, nome duplicado (sem diferenciar maiúsculas) e meta fora de 5–480 minutos. **Esperado:** as telas apenas exibem o retorno dos métodos — nenhuma delas conhece a faixa 5–480. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e08)

<a id="m08-e09"></a>
## M08-E09 — Trilhas com `AsyncNotifier` · Aplicação
Implemente `TrilhasNotifier extends AsyncNotifier<List<Trilha>>` lendo `trilhasFonteProvider` no `build()`, com `recarregar()` usando `AsyncLoading().copyWithPrevious(state)` seguido de `AsyncValue.guard`, e monte `TrilhasTab` com `.when` tratando lista vazia como `AsyncData` vazio, não como estado próprio. **Teste:** quando a fonte lança `FalhaDeRede`, aparece a tela de erro com botão que chama `ref.invalidate(trilhasProvider)`. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e09)

<a id="m08-e10"></a>
## M08-E10 — `requireValue` na primeira carga · Correção de bugs
`TrilhasTab` faz `ref.watch(trilhasProvider).requireValue` e quebra ao abrir a aba, porque o estado ainda é `AsyncLoading`. Troque por `.when` e, na recarga, mantenha a lista antiga visível detectando `isLoading && hasValue`. **Esperado:** nenhum travamento na primeira abertura e a rolagem não pisca ao recarregar. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e10)

<a id="m08-e11"></a>
## M08-E11 — Cronômetro por matéria · Aplicação
Crie `cronometroProvider` como `NotifierProvider.autoDispose.family<CronometroNotifier, EstadoCronometro, String>`, com `alternar()`, `zerar()` e `concluir()` — que grava a sessão via `ref.read(sessoesProvider.notifier)` usando `arg` — e cancele o `Timer` dentro de `ref.onDispose`, registrado junto da criação. **Teste:** sair da tela imprime a mensagem do `onDispose`, e o cronômetro de outra matéria continua no próprio valor. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e11)

<a id="m08-e12"></a>
## M08-E12 — Family com parâmetro sem `==` · Correção de bugs
`sessoesFiltradasProvider` recebe `Filtro(materiaId, apenasHoje)`, uma classe sem `==`/`hashCode`: cada `build` cria uma instância nova, nasce um provider novo e nenhum é liberado. Troque o parâmetro pelo *record* `({String materiaId, bool apenasHoje})`. **Teste:** com `debugPrint` em `ref.onDispose`, rolar a tela dez vezes deixa de criar dez instâncias. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e12)

<a id="m08-e13"></a>
## M08-E13 — `core/` × feature e Riverpod × `get_it` · Decisão
Responda por escrito: (1) `Icones`, `MateriaTile`, `EstadoVazio` e o validador "já existe matéria com esse nome" vão para `core/` ou para `features/materias/`? (2) Por que o curso injeta dependências com Riverpod em vez de `get_it`? **Esperado:** no item 1, aplicar a pergunta "isto faria sentido se a feature matérias não existisse?"; no item 2, citar erro em tempo de compilação e reatividade. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e13)

<a id="m08-e14"></a>
## M08-E14 — Feature-first testável de ponta a ponta · Desafio prático
Reorganize matérias em `features/materias/{domain,data,presentation}`: contrato `abstract interface class MateriaRepositorio` e as falhas `sealed` no `domain`, `MateriaRepositorioMemoria` no `data` e `materiaRepositorioProvider` tipado com o **contrato**; depois escreva `test/materias_controller_test.dart` com `MateriaRepositorioFalso`, `ProviderContainer(overrides: ...)` e `addTearDown(container.dispose)`. **Teste:** `flutter test` cobre carga inicial via `materiasProvider.future`, nome duplicado (`MateriaDuplicada`) e `FalhaDeArmazenamento`; nenhum arquivo de `domain/` importa `package:flutter/material.dart`. [🔑 Gabarito](../gabaritos/08-estado-e-arquitetura.md#m08-e14)

[Módulo](../modulos/08-estado-e-arquitetura/README.md)
