# Avaliação — Módulo 08: Estado e arquitetura

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Guardar se um `ExpansionTile` está aberto, numa única tela do Foco, pede: A) um `StateProvider` global; B) um `NotifierProvider` com `autoDispose`; C) `setState` no próprio `State`; D) um `InheritedWidget` acima da aba.  
2. `setState` não resolve estado compartilhado com uma tela aberta por `Navigator.push` porque: A) `setState` só reconstrói widgets `const`; B) a rota nova não é descendente da aba — é filha do `Navigator` do `MaterialApp`; C) o `push` descarta o `State` de quem chamou; D) `setState` não pode ser chamado depois de um `await`.  
3. Um `updateShouldNotify` que devolve `true` fixo: A) não compila, porque o método é `abstract`; B) faz `of(context)` devolver `null`; C) transforma o `InheritedWidget` em `StatefulWidget`; D) compila e reconstrói todos os dependentes a cada `build` do provedor, mesmo sem mudança.  
4. `void adicionar(Materia m) => state.add(m);` num `Notifier<List<Materia>>`: A) altera a lista, mas a referência é a mesma, ninguém é notificado e nenhum erro aparece; B) lança `Unsupported operation` porque `state` é imutável; C) funciona, desde que a tela use `ref.read`; D) só falha se `Materia` não tiver `==`.  
5. `final int minutos = ref.read(minutosHojeProvider);` no `build` de um `ConsumerWidget`: A) lança `Tried to use ref.read outside of the build method`; B) compila, mostra o valor da primeira construção e nunca mais atualiza, sem erro nenhum; C) reconstrói o widget a cada mudança, igual a `ref.watch`; D) só funciona se o provider for `autoDispose`.  
6. `ref.watch(trilhasProvider).requireValue` enquanto a carga ainda não terminou: A) devolve uma lista vazia; B) devolve `null`, e o `!` resolve; C) lança `Bad state: Tried to call requireValue on an AsyncValue that has no value`; D) espera o `Future` e devolve os dados.

7. Diferencie `ref.watch` de `ref.listen` e dê um uso de cada um no app Foco.  
8. Explique por que um parâmetro de `.family` sem `==` e `hashCode` provoca vazamento silencioso.  
9. Explique a regra de dependência entre `presentation`, `domain` e `data`, e diga o teste mais rápido para descobrir que ela foi quebrada.  
10. Explique por que o provider do repositório deve ser tipado com o contrato e o que `addTearDown(container.dispose)` evita nos testes.

## 2. Prática

Crie a feature `sessoes` do app Foco em `lib/features/sessoes/`, com as três camadas. No `domain`, escreva o modelo imutável `Sessao` (`id`, `materia`, `minutos`) com `==`, `hashCode` e a regra `valida`, mais o contrato `abstract interface class SessaoRepositorio` — sem nenhum import de Flutter. Em `data`, implemente `SessaoRepositorioMemoria` com um campo `falharSempre`. Em `presentation`, escreva `SessoesController extends AsyncNotifier<List<Sessao>>` que carrega pelo provider tipado com o contrato, registra com `AsyncValue.guard` e recarrega sem apagar a lista da tela. Feche com `test/sessoes_controller_test.dart` usando `ProviderContainer` e `overrides`, cobrindo carga, registro e falha.

| Critério | Pontos |
|---|---:|
| `domain/` sem nenhum import de Flutter, com modelo imutável, `==` e `hashCode` | 2 |
| Contrato `abstract interface class` e provider tipado com ele | 2 |
| `AsyncNotifier` com `Future<List<Sessao>> build()` e `AsyncValue.guard` na escrita | 2 |
| Regra de negócio no notifier e recarga que preserva os dados (`copyWithPrevious`) | 1 |
| Teste com `ProviderContainer`, `overrides` e `addTearDown(container.dispose)` | 2 |
| `flutter analyze` sem nenhum aviso | 1 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem avisos e `flutter test` passando sem emulador.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Estado compartilhado e *prop drilling* | [Aulas 01 e 02](../modulos/08-estado-e-arquitetura/01-o-problema-do-estado.md) | E01 |
| `of(context)` e `updateShouldNotify` | [Aula 03](../modulos/08-estado-e-arquitetura/03-inheritedwidget.md) | E02 |
| `watch`, `read` e `listen` trocados | [Aula 05](../modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md) | E03 |
| Estado mutado em vez de substituído | [Aula 06](../modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md) | E04 |
| `AsyncValue`, `.when` e recarga que pisca | [Aula 07](../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) | E05 |
| `.family`, descarte e efeitos colaterais | [Aula 08](../modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md) | E06 |
| Camadas e regra de dependência | [Aula 09](../modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md) | E07 |
| `overrides` e teste sem emulador | [Aula 10](../modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-08)
