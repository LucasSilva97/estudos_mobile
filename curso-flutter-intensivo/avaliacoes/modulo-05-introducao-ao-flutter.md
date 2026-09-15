# Avaliação — Módulo 05: Introdução ao Flutter

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. O Impeller é: A) o embedder, que pede a janela ao sistema operacional; B) o renderizador que pré-compila os shaders no build e elimina o engasgo do primeiro quadro; C) o compilador AOT usado no modo release; D) a engine inteira, que substituiu o framework escrito em Dart.  
2. Qual caminho **nunca** pode ir para o Git? A) `pubspec.lock`; B) `.metadata`; C) `android/key.properties`; D) `analysis_options.yaml`.  
3. O `BuildContext` que chega no `build` é: A) o widget que está sendo construído; B) o `Element` daquela posição na árvore; C) o `RenderObject` que mede e pinta; D) uma referência global ao `MaterialApp`.  
4. Sobre `setState`, é verdade que: A) ele descobre sozinho o que mudou e redesenha só aquele pedaço; B) ele executa o callback na hora, marca o `Element` como sujo e agenda um novo `build`; C) ele redesenha a tela imediatamente, ainda dentro da chamada; D) ele aceita um callback `async` para esperar os dados antes de reconstruir.  
5. Para ler a largura da tela dentro do `build`, prefira: A) `MediaQuery.of(context).size`, por ser a API tradicional; B) `MediaQuery.sizeOf(context)`, que só reconstrói o widget quando o tamanho muda; C) `MediaQuery.of(context).size` no `initState`, para ler uma vez só; D) guardar o `context` em um campo da classe e consultá-lo quando precisar.  
6. Você trocou `int _sessoes = 0;` por `int _sessoes = 5;` e apertou `r`. A tela continua mostrando 0 porque: A) o hot reload não recompila campos privados; B) o hot reload não reexecuta inicializadores de campo nem o `initState`, e o estado antigo foi preservado; C) o arquivo não chegou a ser salvo; D) valores iniciais só passam a valer no modo release.

7. Diferencie `initState` de `didChangeDependencies`, dizendo o que pode e o que não pode ser feito em cada um.  
8. Explique por que extrair um widget é melhor que extrair um método que devolve `Widget`.  
9. Explique por que checar `mounted` depois de um `await` não dispensa cancelar o `Timer` no `dispose`.  
10. Explique a decisão do curso de usar Material 3 nas duas plataformas e o que significa "adaptação pontual".

## 2. Prática

Crie `flutter create -e --platforms=android,ios,web foco_avaliacao` e monte uma tela única do app Foco. Em `lib/tema/tema_app.dart`, gere tema claro e escuro a partir de uma única semente com `ColorScheme.fromSeed`. Em `lib/widgets/cartao_meta.dart`, escreva um `StatelessWidget` `const` que recebe `nome`, `minutosEstudados` e `metaMinutos` e desenha o progresso da meta semanal. Em `lib/widgets/cronometro_sessao.dart`, escreva um `StatefulWidget` com `Timer.periodic` iniciado no `initState`, cancelado no `dispose`, e um botão "Encerrar sessão" que simula a gravação com `await` e depois mostra um `SnackBar`.

| Critério | Pontos |
|---|---:|
| `TemaApp` com `ColorScheme.fromSeed`, tema escuro pela mesma semente e `themeMode: ThemeMode.system` | 2 |
| `CartaoMeta` com construtor `const`, `{super.key}`, `required` e progresso derivado por getter | 2 |
| Nenhuma cor fixa na interface: tudo sai do `colorScheme`, respeitando a regra do `on` | 1 |
| `Timer.periodic` criado no `initState` e cancelado no `dispose` | 2 |
| `SnackBar` exibido com `ScaffoldMessenger.of(context)` e `if (!mounted) return;` depois do `await` | 2 |
| `flutter analyze` termina com `No issues found!` | 1 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem erros, inclusive sem avisos de `use_build_context_synchronously`.
- O app roda com `flutter run -d chrome`.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Engine, Impeller e modos de build | [Aula 01](../modulos/05-introducao-ao-flutter/01-como-o-flutter-funciona.md) | E01 |
| Estrutura do projeto e o que versionar | [Aula 02](../modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md) | E02 |
| Árvore de widgets, `const` e extração | [Aulas 03 e 04](../modulos/05-introducao-ao-flutter/04-statelesswidget.md) | E03 e E04 |
| `setState` e ciclo de vida do `State` | [Aulas 05 e 06](../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) | E05 e E06 |
| `BuildContext`, `.of` e `mounted` | [Aula 07](../modulos/05-introducao-ao-flutter/07-buildcontext.md) | E07 |
| Hot reload, tema e Material 3 | [Aulas 08 e 09](../modulos/05-introducao-ao-flutter/09-material-e-cupertino.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-05)
