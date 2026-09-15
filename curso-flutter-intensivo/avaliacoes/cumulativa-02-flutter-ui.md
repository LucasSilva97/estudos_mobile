# Avaliação — Cumulativa 02: Flutter UI (módulos 05 a 07)

> **Tempo sugerido:** 35 min de questões + 80 min de prática. Faça sem consultar o material.

Esta avaliação não repete as três avaliações de módulo. Ela cobra o que só aparece quando árvore de
widgets, layout, estados de UI, navegação e formulários trabalham **na mesma tela** do app Foco.

## 1. Questionário

Cada questão vale 1 ponto. São 12 pontos no total.

1. `Theme.of(context)` chamado no `build` do widget que **cria** o `MaterialApp` devolve o tema padrão porque: A) `Theme.of` só funciona em `StatefulWidget`; B) esse `context` está acima do `MaterialApp` na árvore; C) faltou `useMaterial3: true`; D) `ColorScheme.fromSeed` só vale no modo escuro.  
2. Uma `ListView.builder` colocada direto dentro de uma `Column` quebra com: A) `RenderFlex overflowed by X pixels`; B) `Vertical viewport was given unbounded height`; C) `setState() called after dispose()`; D) `Could not find a generator for route`.  
3. Depois de `final editada = await Navigator.pushNamed<Materia>(context, Rotas.formMateria);`, antes de usar `context` de novo você precisa: A) chamar `setState` primeiro; B) checar `context.mounted` e sair se for `false`; C) chamar `dispose()` da tela; D) trocar `push` por `pushReplacement`.  
4. As 4 abas do Foco dentro de um `IndexedStack` preservam rolagem e filtro porque: A) o `IndexedStack` mantém todos os filhos na árvore e só pinta o selecionado; B) ele grava o estado no disco; C) os filhos são `const`; D) o `State` é recriado a cada troca.  
5. O `TextEditingController` do formulário de matéria nasce em `initState` e morre em `dispose` porque: A) `build` roda uma única vez; B) ele guarda estado fora do `build` e mantém ouvintes vivos até ser liberado; C) `setState` não funciona sem ele; D) o `Navigator.pop` já libera tudo sozinho.  
6. Um `MateriaTile` que muda de formato conforme o espaço **que o pai oferece** deve consultar: A) `MediaQuery.sizeOf`; B) `LayoutBuilder`; C) `Navigator.of`; D) `OrientationBuilder`.  
7. O filtro "Matemática" não encontrou nenhuma matéria. O estado correto de UI é: A) `TelaCarregando`; B) `TelaFalha` com botão "Tentar de novo"; C) `TelaVazia` com ação para limpar o filtro; D) `TelaSucesso` com lista vazia.  
8. Centralizar rotas em `onGenerateRoute` com `switch` e caso `default` serve para: A) preservar o estado das abas; B) evitar tela quebrada com nome de rota desconhecido e concentrar os nomes num lugar só; C) validar formulários; D) dispensar o `MaterialPageRoute`.

9. A `MateriaFormScreen` devolve a matéria editada. Descreva o caminho do dado desde `Navigator.pop(materia)` até a lista redesenhada, dizendo onde entra `context.mounted` e o que acontece quando o resultado volta `null`.  
10. Diferencie extrair um **widget** de extrair um **método que devolve `Widget`**, e explique o efeito de cada escolha numa `ListView.builder` com 300 matérias.  
11. Explique por que a aba de matérias já precisa dos quatro estados de UI mesmo antes de existir qualquer API no projeto, e cite o gatilho de cada estado no Foco.  
12. Explique por que `dispose()` dos `TextEditingController` e `FocusNode` continua obrigatório mesmo quando a tela sai da pilha por `Navigator.pop`, e diga qual erro aparece quando algo vivo tenta redesenhar a tela fechada.

## 2. Prática

No projeto `foco_navegacao` (pacote `br.com.estudos.foco`), entregue a fatia **Matérias** funcionando
de ponta a ponta: `MaterialApp` com tema Material 3 gerado por `ColorScheme.fromSeed`, `themeMode`
e `onGenerateRoute` com rota de erro; `HomeScreen` com as 4 abas (Hoje · Matérias · Trilhas ·
Ajustes) em `NavigationBar` + `IndexedStack`; aba de matérias modelada por um `sealed class
EstadoTela<T>` com os quatro estados resolvidos em `switch` exaustivo; e o formulário de matéria
aberto como `fullscreenDialog`, que valida, devolve a matéria por `Navigator.pop` e confirma
descarte com `PopScope`. A lista precisa sobreviver de 320 px a 1600 px de largura.

| Critério | Pontos |
|---|---:|
| Tema M3 com semente, `themeMode` e `onGenerateRoute` com rota desconhecida tratada | 2 |
| 4 abas com `NavigationBar` + `IndexedStack` preservando rolagem e filtro | 1 |
| `ListView.builder`, tile extraído como widget `const` e zero overflow entre 320 px e 1600 px | 2 |
| `sealed class EstadoTela<T>` com os quatro estados e `switch` exaustivo, sem booleano solto | 2 |
| `Form` + `GlobalKey<FormState>`, validadores com mensagem que ajuda, foco encadeado, `dispose` e `PopScope` de descarte | 2 |
| Argumento tipado na ida, resultado na volta, `context.mounted` após o `await` e `SnackBar` de confirmação | 1 |

## 3. Critérios para avançar

- 9/12 no questionário e 8/10 na prática.
- Exercícios obrigatórios de M05, M06 e M07 concluídos e conferidos.
- `flutter analyze` termina com `No issues found!`, inclusive sem `use_build_context_synchronously`.
- O app roda com `flutter run -d windows` maximizado e num celular estreito em pé.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| `context` errado em `Theme.of` / `ScaffoldMessenger.of` | [05 — Aula 07](../modulos/05-introducao-ao-flutter/07-buildcontext.md) | M05-E10 e M05-E11 |
| Ciclo de vida, `dispose` e vazamento no formulário | [05 — Aula 06](../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) e [07 — Aula 06](../modulos/07-navegacao-e-formularios/06-formularios.md) | M05-E08 e M07-E08 |
| Overflow, altura infinita e lista dentro de `Column` | [06 — Aula 06](../modulos/06-widgets-e-layouts/06-constraints.md) e [06 — Aula 09](../modulos/06-widgets-e-layouts/09-listas-e-rolagem.md) | M06-E04 e M06-E08 |
| Layout que quebra em tela larga | [06 — Aula 11](../modulos/06-widgets-e-layouts/11-responsividade.md) | M06-E14 |
| Tela branca e estados de UI | [06 — Aula 12](../modulos/06-widgets-e-layouts/12-estados-de-ui.md) | M06-E14 |
| Rotas espalhadas e nome desconhecido | [07 — Aula 02](../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md) | M07-E03 e M07-E04 |
| Argumento tipado, resultado `null` e `context.mounted` | [07 — Aula 03](../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md) | M07-E05 e M07-E06 |
| Abas que perdem estado e `PopScope` de descarte | [07 — Aula 04](../modulos/07-navegacao-e-formularios/04-abas-e-organizacao.md) e [07 — Aula 05](../modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md) | M07-E07 e M07-E09 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#cumulativa-02)
