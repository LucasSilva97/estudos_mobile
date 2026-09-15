# Avaliação — Módulo 06: Widgets e layouts

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Para mostrar um `SnackBar` confirmando que a matéria foi removida, você chama: A) o slot `snackBar:` do `Scaffold`; B) `Scaffold.of(context).showSnackBar(...)`; C) `ScaffoldMessenger.of(context).showSnackBar(...)`; D) `showDialog` com duração curta.  
2. O nome da matéria vem do banco e pode ser longo. Dentro de uma `Row`, o `ellipsis` só funciona com: A) `softWrap: false` no `Text`; B) `maxLines: 1` e `overflow: TextOverflow.ellipsis` dentro de um `Expanded`; C) `maxLines: 1` sozinho, porque a `Row` já limita a largura; D) `FittedBox` reduzindo a fonte.  
3. A diferença entre `Expanded` e `Flexible` é: A) `Expanded` obriga o filho a ocupar o espaço livre (`FlexFit.tight`) e `Flexible` permite ocupar menos (`FlexFit.loose`); B) `Expanded` vale em `Row` e `Flexible` em `Column`; C) `Flexible` ignora o parâmetro `flex`; D) `Expanded` funciona em qualquer widget e `Flexible` só dentro de `Flex`.  
4. Um `ListView.builder` dentro de uma `Column` gera `Vertical viewport was given unbounded height`. A correção que **preserva a construção preguiçosa** é: A) `shrinkWrap: true` com `NeverScrollableScrollPhysics`; B) trocar a `Column` por um `SingleChildScrollView`; C) envolver o `ListView` em `Expanded`; D) envolver a `Column` em `IntrinsicHeight`.  
5. `background`, `onBackground` e `surfaceVariant` saíram do `ColorScheme`. Os substitutos no Material 3 são: A) `primary`, `onPrimary` e `primaryContainer`; B) `surface`, `onSurface` e `surfaceContainerHighest`; C) `scaffoldBackgroundColor`, `cardColor` e `dividerColor`; D) os próprios antigos, bastando `useMaterial3: true`.  
6. A `key` do `Dismissible` que exclui uma matéria da lista deve ser: A) `ValueKey<int>(indice)`, único dentro do `itemBuilder`; B) `ValueKey<String>(materia.id)`, estável; C) dispensável quando existe `confirmDismiss`; D) `UniqueKey()`, gerada a cada `build`.

7. Diferencie `MediaQuery` de `LayoutBuilder` e diga qual dos dois usar dentro do `MateriaTile`.  
8. Explique por que a onda do `InkWell` some quando há um `Container(color:)` entre ele e o `Material`, e como corrigir.  
9. Explique por que um `sealed class` de estado é melhor que `bool _carregando` + `String? _erro` + `List<Materia> _dados` na tela de matérias.  
10. Enuncie a regra de ouro do layout do Flutter e use-a para explicar por que um `Container` sem filho e sem tamanho ocupa a tela inteira.

## 2. Prática

No projeto `foco_ui`, monte a tela **Metas da semana** em `lib/features/materias/presentation/metas_screen.dart`. Ela carrega as matérias por um `Future` falso de 1 s e trata os quatro estados com um `sealed class`. No sucesso, exiba um `ListView.separated`; cada item responde ao toque com onda visível e pode ser arrastado para excluir, com **Desfazer** no `SnackBar`. Acima de 600 px de largura, troque a lista por duas colunas. Todas as cores vêm do `Theme.of(context)`, nos modos claro e escuro.

| Critério | Pontos |
|---|---:|
| `Scaffold` com `AppBar`, ação de recarregar e nenhum número fixo de barra de status | 1 |
| `sealed class` de estado e `switch` exaustivo cobrindo carregando, vazio, sucesso e erro | 2 |
| `ListView.separated` com `itemCount`, rolando dentro de `Expanded` e sem `shrinkWrap` | 2 |
| Item tocável com `Ink` + `InkWell`, onda no raio certo e alvo de 48 px | 2 |
| `Dismissible` com `key` pelo `id`, remoção da fonte de dados e `SnackBar` com Desfazer | 2 |
| `LayoutBuilder` com corte em 600 px e cores só do `ColorScheme`, claro e escuro | 1 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem nenhum aviso.
- A tela sobrevive ao Chrome redimensionado de 320 px até maximizado.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Slots do `Scaffold` e texto que estoura | [Aulas 01](../modulos/06-widgets-e-layouts/01-scaffold-e-appbar.md) e [02](../modulos/06-widgets-e-layouts/02-texto-tipografia-icones.md) | E01 |
| `RenderFlex overflowed by X pixels` | [Aula 04](../modulos/06-widgets-e-layouts/04-row-column-expanded.md) | E02 e E03 |
| `Vertical viewport was given unbounded height` | [Aulas 06](../modulos/06-widgets-e-layouts/06-constraints.md) e [09](../modulos/06-widgets-e-layouts/09-listas-e-rolagem.md) | E04 |
| Cor solta no widget em vez de tema | [Aula 07](../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) | E05 |
| Toque sem onda ou alvo menor que 48 px | [Aula 10](../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md) | E06 |
| Layout que quebra em tela larga | [Aula 11](../modulos/06-widgets-e-layouts/11-responsividade.md) | E07 |
| Tela branca quando não há dados | [Aula 12](../modulos/06-widgets-e-layouts/12-estados-de-ui.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-06)
