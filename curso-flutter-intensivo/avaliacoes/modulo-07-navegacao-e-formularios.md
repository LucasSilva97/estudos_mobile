# Avaliação — Módulo 07: Navegação e formulários

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Na tela base da pilha, um botão "Voltar" próprio deve usar: A) `Navigator.pop(context)`; B) `Navigator.maybePop(context)`; C) `Navigator.popUntil(context, 1)`; D) `Navigator.pushReplacement(context, rota)`.  
2. Você criou a `Route` no `onGenerateRoute` e esqueceu `settings: configuracoes`. O resultado é: A) o app lança `Could not find a generator for route`; B) a rota fica sem nome e `settings.arguments` chega nulo, sem nenhum erro visível; C) o `initialRoute` passa a ser ignorado; D) o `fullscreenDialog` deixa de funcionar.  
3. A rota devolve `MaterialPageRoute<void>` e quem chama usa `pushNamed<Materia>`. O `pop(materia)`: A) não compila; B) lança exceção em tempo de execução; C) é descartado em silêncio e o `await` recebe `null`; D) funciona, porque o Dart infere o tipo do `pop`.  
4. Trocar de aba com `body: switch (_indice) { ... }` faz o usuário perder: A) o tema do app; B) a rolagem e o texto digitado, porque o widget da aba é destruído; C) nada, o Flutter preserva as abas por padrão; D) só a rolagem, porque o texto fica guardado no `TextEditingController`.  
5. `PopScope` usa `canPop` **síncrono** em vez da função `async` do antigo `WillPopScope` porque: A) `async` não funciona dentro de widgets; B) o *predictive back* do Android 14+ precisa saber **antes** do fim do gesto se a tela vai sair; C) `WillPopScope` nunca funcionou no iOS; D) `canPop` também fecha o teclado.  
6. `keyboardType: TextInputType.number` no campo de meta garante que só chegue número? A) Sim, o Flutter bloqueia letras; B) não — ele só **sugere** o teclado, e falta `FilteringTextInputFormatter.digitsOnly`; C) sim, desde que exista um `validator`; D) não, e a correção é trocar para `TextInputType.phone`.

7. Explique por que o argumento da rota é validado com `if (args is! MateriaDetalheArgs) return desconhecida(configuracoes);` em vez de `as MateriaDetalheArgs`.  
8. Diferencie `labelText` de `hintText` e explique por que todo campo precisa de `labelText`.  
9. Explique a estratégia de `autovalidateMode` adotada no curso e por que validar um campo de texto a cada tecla é ruim.  
10. Explique por que `if (!context.mounted) return;` é obrigatório depois de `await Navigator.push`.

## 2. Prática

No app **Foco**, monte um projeto com duas telas: a lista de matérias (`Rotas.home`) e o formulário de matéria (`Rotas.materiaForm`, em `fullscreenDialog`). Centralize tudo numa classe `Rotas` com `onGenerateRoute` e rota desconhecida. A lista abre o formulário com `MateriaFormArgs.criar()` ou `.editar(materia)` e recebe de volta a `Materia` salva — nunca `true`. O formulário valida nome (mínimo 2 letras) e meta em minutos (entre 5 e 480), encadeia os campos pelo teclado e confirma o descarte quando há alterações não salvas.

| Critério | Pontos |
|---|---:|
| `Rotas` com constantes, `onGenerateRoute`, `settings:` repassado e rota desconhecida | 2 |
| Argumentos tipados validados com `is!` e entregues pelo **construtor** da tela | 2 |
| `MaterialPageRoute<Materia>` casando com `pushNamed<Materia>`, `null` tratado e `context.mounted` após o `await` | 2 |
| `Form` + `GlobalKey<FormState>`, validadores com mensagem que ajuda, `inputFormatters` e encadeamento `FocusNode` + `textInputAction` | 2 |
| `PopScope` com `onPopInvokedWithResult` para descarte, botão desabilitado durante o envio e `dispose` de todos os controllers e `FocusNode` | 2 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` termina com `No issues found!`.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Pilha, `pop` × `maybePop`, `fullscreenDialog` | [Aula 01](../modulos/07-navegacao-e-formularios/01-navigator-a-pilha.md) | E01 |
| Rotas centralizadas e rota de erro | [Aula 02](../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md) | E02 |
| Argumentos tipados e resultado de volta | [Aula 03](../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md) | E03 e E04 |
| Abas e preservação de estado | [Aula 04](../modulos/07-navegacao-e-formularios/04-abas-e-organizacao.md) | E05 |
| Transições por plataforma e `PopScope` | [Aula 05](../modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md) | E06 |
| `Form`, controllers, foco e teclado | [Aulas 06 e 07](../modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md) | E07 |
| Mensagens de erro e UX do formulário | [Aula 08](../modulos/07-navegacao-e-formularios/08-ux-de-formularios.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-07)
