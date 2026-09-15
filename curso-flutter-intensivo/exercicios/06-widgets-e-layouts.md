# Exercícios — Módulo 06: Widgets e layouts

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Trabalhe sempre no projeto `foco_ui`, rode `flutter run -d windows` e deixe `flutter analyze` sem avisos antes de abrir o gabarito.

<a id="m06-e01"></a>
## M06-E01 — Esqueleto da Home · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Ocupar os slots do `Scaffold` | Fácil | 20 min | Sim |
Em `lib/features/materias/presentation/home_screen.dart`, monte `HomeScreen` com `AppBar` cujo `title` acompanha a aba atual (Hoje, Matérias, Trilhas, Ajustes), duas `IconButton` com `tooltip`, `drawer`, `floatingActionButton` e `BottomNavigationBar` de quatro itens. **Esperado:** trocar de aba muda o título via `setState`; o FAB mostra um `SnackBar` flutuante. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e01)

<a id="m06-e02"></a>
## M06-E02 — Tipografia do tile · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Usar o `textTheme` do Material 3 | Fácil | 20 min | Sim |
No `MateriaTile`, escreva o nome com `titleMedium`, a meta com `bodySmall` e o total de minutos com `labelLarge`, todos vindos de `Theme.of(context).textTheme` — nenhum `fontSize` solto. Dê ao total `semanticsLabel: '95 minutos estudados'` e monte "Faltam **25 min**" com `Text.rich`. **Teste:** com a fonte do sistema em 200 %, nenhum texto some nem sobrepõe o vizinho. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e02)

<a id="m06-e03"></a>
## M06-E03 — Cartão de destaque decorado · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Escolher entre `Container`, `Padding` e `SizedBox` | Média | 25 min | Sim |
Crie `CartaoDestaque({required int minutosHoje, required int metaMinutos, required String materiaAtual})` em `presentation/widgets/cartao_destaque.dart`: `margin` horizontal 16 / vertical 12, `padding` 20, `BoxDecoration` com `cores.surfaceContainerHighest`, raio 20, borda `outlineVariant` e uma sombra discreta. Os espaços internos usam `SizedBox`, nunca `Container` vazio. **Esperado:** o cartão abre a aba Hoje e nenhum hexadecimal aparece no arquivo. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e03)

<a id="m06-e04"></a>
## M06-E04 — Tile que estoura · Correção de bugs
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Matar o `RenderFlex overflowed` | Média | 25 min | Sim |
A `Row` do `MateriaTile` (ícone + nome + minutos) mostra a faixa listrada `RenderFlex overflowed by 37 pixels` quando o nome é "Introdução à Programação Orientada a Objetos". Corrija com `Expanded` no bloco do meio e `maxLines: 1` + `TextOverflow.ellipsis` no nome — e não com `SingleChildScrollView`. **Teste:** janela de 320 px e nome de 60 caracteres, sem nenhuma listra na tela nem aviso no console. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e04)

<a id="m06-e05"></a>
## M06-E05 — Selo sobre o cartão · Aplicação
Envolva o conteúdo do `CartaoDestaque` em um `Stack`: camada de fundo com `Positioned(right: -24, bottom: -24)` e `Icon(Icons.timer_outlined, size: 160)` em opacidade 0,08 dentro de `IgnorePointer`; camada da frente com os textos. Ponha `clipBehavior: Clip.antiAlias` no `Container` e um `LinearGradient` de `primaryContainer` a `secondaryContainer`. **Esperado:** o ícone é cortado pela borda arredondada e não rouba toques. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e05)

<a id="m06-e06"></a>
## M06-E06 — Prever antes de rodar · Leitura de código
Sem executar, escreva o resultado de cada trecho e a regra que o explica: (a) `Container(color: cores.primary)` sem filho, direto no `body`; (b) o mesmo `Container` com um `Text` dentro, embrulhado em `Center`; (c) `ConstrainedBox(constraints: BoxConstraints(minWidth: 500))` dentro de um pai de 300 px; (d) um `Stack` de quatro camadas — `Positioned(top: 0)`, `Align(bottomRight)` e dois filhos soltos —, dizendo quem pinta por cima de quem. Depois traduza um `Container` com `margin`, `padding`, `alignment`, `width`, `height`, `decoration` e `child` na pilha equivalente de widgets simples. **Esperado:** cada resposta citando "constraints descem, tamanhos sobem, o pai posiciona". [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e06)

<a id="m06-e07"></a>
## M06-E07 — Tema do Foco com semente própria · Implementação
Crie `lib/core/tema/tema_app.dart` com `abstract final class TemaApp`: uma `semente` diferente de `0xFF4F46E5`, os getters `claro` e `escuro` gerados por `ColorScheme.fromSeed(seedColor:, brightness:)`, mais `appBarTheme` e `cardTheme`. Ligue `theme`, `darkTheme` e `themeMode` no `MaterialApp` e um `IconButton` que cicla claro → escuro → sistema. **Teste:** os três modos trocam sem reiniciar o app e nenhum arquivo fora de `tema_app.dart` contém `Color(0x...)`. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e07)

<a id="m06-e08"></a>
## M06-E08 — Aba de matérias rolável · Aplicação
Crie `presentation/materias_tab.dart` com `MateriasTab`, 20 `Materia` de exemplo e um `IconButton` que alterna lista e grade: `ListView.separated` com `MateriaTile` e `Divider`; `GridView.builder` com `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 220)`; `RefreshIndicator` que aguarda 1 s; `Dismissible` com `confirmDismiss` e `SnackBarAction('Desfazer')`. **Teste:** excluir e tocar em Desfazer devolve o item à mesma posição, e a grade não recria os itens fora da tela. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e08)

<a id="m06-e09"></a>
## M06-E09 — A `key` do `Dismissible` · Compreensão
Troque a `key` para `ValueKey<int>(indice)`, exclua o **segundo** item e descreva por escrito o que aparece na tela. Volte para `ValueKey<String>(materia.id)` e explique, em até cinco linhas, o que a `key` informa ao Flutter quando a árvore é reconstruída e por que o índice não serve. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e09)

<a id="m06-e10"></a>
## M06-E10 — Modo escuro e capa sumida · Correção de bugs
Dois defeitos no mesmo commit: (1) `TextStyle(color: Colors.black)` no `MateriaTile` deixa o nome invisível no tema escuro; (2) a capa não carrega porque `assets:` ficou na raiz do `pubspec.yaml`, e não com 2 espaços dentro de `flutter:`. Corrija ambos usando `cores.onSurface` e a indentação certa. **Teste:** `flutter pub get`, pare e rode de novo — o nome é legível nos dois temas e `assets/imagens/capa_estudo.png` aparece sem cair no `errorBuilder`. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e10)

<a id="m06-e11"></a>
## M06-E11 — Excluir e registrar com confirmação · Aplicação
Em `core/widgets/dialogos.dart`, implemente `Dialogos.confirmar(context, {titulo, mensagem, destrutivo})` devolvendo `false` quando o usuário fecha sem escolher, e `Dialogos.pedirMinutos(context, materia)` com `SimpleDialog` de 15/25/50/90 devolvendo `int?`. Ligue os dois ao `MateriaTile` por `onTap` e `onLongPress` (folha de ações com `AcaoMateria`). **Teste:** voltar pelo botão do sistema não exclui nada; escolher 25 soma os minutos e oferece Desfazer. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e11)

<a id="m06-e12"></a>
## M06-E12 — Onda invisível e teclado por cima · Correção de bugs
(1) `Container(color: Colors.white, child: InkWell(onTap: ...))` engole a onda do toque — repinte o fundo com `Material` ou `Ink` e mantenha o `InkWell` por dentro. (2) Uma `Column` com `TextField` no fim estoura quando o teclado sobe: torne o corpo rolável e esconda o FAB quando `MediaQuery.viewInsetsOf(context).bottom > 0`. **Esperado:** onda visível ao tocar no tile e campo sempre acima do teclado num celular. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e12)

<a id="m06-e13"></a>
## M06-E13 — Três decisões, por escrito · Decisão
Responda em um parágrafo cada, com justificativa e um exemplo do Foco, sem código: (a) por que o diálogo de exclusão usa `FilledButton` + `TextButton` em vez de dois `FilledButton`; (b) quando consultar `MediaQuery.sizeOf` e quando usar `LayoutBuilder` no `CartaoAdaptavel`; (c) em que situação `EsqueletoLista` comunica melhor que `CircularProgressIndicator.adaptive`. **Esperado:** três respostas escritas, cada uma citando o widget do curso a que se refere. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e13)

<a id="m06-e14"></a>
## M06-E14 — Matérias em qualquer largura, nos quatro estados · Implementação
Use `TamanhoTela.de(largura)` no `EsqueletoApp` para escolher entre `NavigationBar`, `NavigationRail` e painel lateral; ponha os filtros em `Wrap` de `FilterChip` (`FiltrosMaterias`); e troque os `bool carregando/vazio/erro` contraditórios da `MateriasTab` por um `EstadoTela<List<Materia>>` `sealed`, resolvido em `switch` exaustivo sobre `TelaCarregando`, `TelaSucesso(recarregando)`, `TelaVazia(porFiltro)` e `TelaFalha`. **Teste:** redimensione de 320 a 1600 px forçando cada estado — sem estouro, sem tela branca e `flutter analyze` limpo. [🔑 Gabarito](../gabaritos/06-widgets-e-layouts.md#m06-e14)

[Módulo](../modulos/06-widgets-e-layouts/README.md)
