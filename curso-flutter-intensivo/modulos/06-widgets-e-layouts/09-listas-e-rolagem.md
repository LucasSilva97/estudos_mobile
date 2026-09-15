# Aula 9 — Listas e rolagem

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 55 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar a diferença entre **`ListView(children: [...])`** e **`ListView.builder`** — e por que a
  segunda é obrigatória em listas que crescem.
- Entender o que significa **construção preguiçosa** (*lazy*) e por que ela é a razão de o Flutter
  rolar 10 000 itens sem engasgar.
- Usar **`ListView.separated`** para linhas divisórias sem gambiarra.
- Montar grades com **`GridView.builder`** e escolher entre `SliverGridDelegate` de contagem fixa
  e de largura máxima.
- Resolver o erro **`Vertical viewport was given unbounded height`** — o erro de lista mais comum
  do Flutter.
- Implementar **arrastar para excluir** com `Dismissible`, incluindo confirmação e desfazer.
- Adicionar **puxar para atualizar** com `RefreshIndicator`.
- Saber quando usar `shrinkWrap`, `physics` e **por que os dois são quase sempre o sintoma de um
  layout errado**.

## ✅ Pré-requisitos

- [Aula 4 — Row, Column e Expanded](04-row-column-expanded.md) — a classe `Materia` e o
  `MateriaTile` vêm de lá.
- [Aula 6 — Constraints](06-constraints.md) — **essencial**. Metade dos erros desta aula é de
  restrição, não de lista.
- [Aula 8 — Imagens e assets](08-imagens-e-assets.md) — as capas dos itens usam `Image.asset`.
- [Módulo 02 — Listas](../02-dart-basico/08-listas.md) — `List<T>`, `map`, `where`.
- O projeto `foco_ui` rodando: `flutter run -d chrome` (ou `-d windows`).

---

## 📖 Conceito

### O problema: uma lista com 5 000 matérias

Até aqui você montou telas com `Column` e `ListView(children: [...])`. Funciona — enquanto os
itens couberem na mão. Agora imagine 5 000 itens.

```dart
ListView(
  children: <Widget>[
    for (final Materia m in materias) MateriaTile(materia: m), // ❌ com 5 000 itens
  ],
)
```

O que acontece: **o Dart cria os 5 000 widgets antes de desenhar o primeiro pixel**. Se cada um
custa 0,05 ms, são 250 ms de travamento — e isso a cada rebuild. O usuário vê a tela congelar.

E o absurdo é que **só uns 8 itens cabem na tela**. Os outros 4 992 foram construídos para nada.

### A solução: construção preguiçosa

```dart
ListView.builder(
  itemCount: materias.length,
  itemBuilder: (BuildContext context, int indice) {
    return MateriaTile(materia: materias[indice]);
  },
)
```

Aqui a lista **não recebe widgets**. Ela recebe uma **receita** (`itemBuilder`) e a **quantidade**
(`itemCount`). O `ListView` então:

1. Mede quanto espaço tem.
2. Chama `itemBuilder` **só para os índices visíveis** — mais uma pequena margem acima e abaixo
   (*cache extent*).
3. Conforme você rola, chama o `itemBuilder` para os que entram e **descarta** os que saem.

Com 5 000 itens, ele constrói uns 12. Com 5 000 000, também uns 12.

> 💡 **A regra prática:** se a lista tem **mais de ~20 itens** ou o número **vem de fora do seu
> controle** (banco de dados, API, usuário), use `ListView.builder`. Sempre.

| | `ListView(children:)` | `ListView.builder` |
|---|---|---|
| Quantos widgets são criados | **Todos**, sempre | Só os visíveis |
| Quando usar | Poucos itens, quantidade fixa e conhecida | Muitos itens, ou quantidade variável |
| Itens diferentes entre si | Natural | Precisa de `if` no `itemBuilder` |
| `itemCount` | — | Obrigatório na prática |

> ⚠️ `itemCount` é tecnicamente opcional. Se você omitir, o `ListView` considera a lista
> **infinita** e chama o `itemBuilder` para sempre, enquanto você rolar. Isso é útil para
> calendários infinitos — e é um bug silencioso em todo o resto. **Sempre passe `itemCount`.**

### `ListView.separated`: divisórias sem gambiarra

Precisa de uma linha entre os itens? A tentação é:

```dart
// ❌ funciona, mas mistura conteúdo com decoração e erra no último item
itemBuilder: (context, i) => Column(
  children: <Widget>[MateriaTile(materia: materias[i]), const Divider()],
),
```

O jeito certo:

```dart
ListView.separated(
  itemCount: materias.length,
  itemBuilder: (BuildContext context, int i) => MateriaTile(materia: materias[i]),
  separatorBuilder: (BuildContext context, int i) => const Divider(height: 1),
)
```

O `separatorBuilder` é chamado **`itemCount - 1` vezes** — entre os itens, nunca depois do último.
E o `i` que ele recebe é o índice do item **acima** do separador, o que permite separadores
diferentes conforme o conteúdo (um cabeçalho de mês, por exemplo).

### `GridView`: a mesma ideia em duas dimensões

```dart
GridView.builder(
  itemCount: materias.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,        // 2 colunas, sempre
    mainAxisSpacing: 12,      // espaço vertical entre as linhas
    crossAxisSpacing: 12,     // espaço horizontal entre as colunas
    childAspectRatio: 3 / 2,  // largura / altura de cada célula
  ),
  itemBuilder: (BuildContext context, int i) => CartaoMateria(materia: materias[i]),
)
```

O **`gridDelegate`** é quem decide o formato da grade. Existem dois na prática:

| Delegate | O que fixa | Quando usar |
|---|---|---|
| `SliverGridDelegateWithFixedCrossAxisCount` | O **número de colunas** | Quando você quer 2 colunas no celular, sempre |
| `SliverGridDelegateWithMaxCrossAxisExtent` | A **largura máxima** de cada célula | Quando o app roda em celular, tablet e desktop |

O segundo é o que faz grades responsivas **sem `if` de largura**:

```dart
gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 220,  // "cada célula tem no máximo 220 px"
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 3 / 2,
)
```

Numa tela de 400 px → 2 colunas. Numa de 900 px → 5 colunas. O Flutter faz a conta.

> ⚠️ **`childAspectRatio` é largura ÷ altura.** `3 / 2` = mais largo que alto. `2 / 3` = mais alto
> que largo. Errar isso causa 90% dos *overflows* em `GridView` — porque a altura da célula é
> **imposta** pela grade, e o conteúdo não cabe.

### O erro que todo mundo comete: viewport sem altura

```dart
Column(
  children: <Widget>[
    const Text('Minhas matérias'),
    ListView.builder(...),   // 💥
  ],
)
```

```text
Vertical viewport was given unbounded height.
Viewports expand in the scrolling direction to fill their container...
```

**Por que acontece** (e aqui a [aula 6](06-constraints.md) volta): um `ListView` precisa saber
**qual é a altura disponível** para calcular quais itens são visíveis. Uma `Column` oferece aos
filhos **altura infinita** no eixo principal. Altura infinita ÷ itens visíveis = impossível.

Três correções, em ordem de preferência:

**1. `Expanded` — quase sempre a resposta certa.**

```dart
Column(
  children: <Widget>[
    const Text('Minhas matérias'),
    Expanded(                      // ✅ "ocupe o que sobrou, e o número é finito"
      child: ListView.builder(...),
    ),
  ],
)
```

**2. Altura fixa com `SizedBox` — quando a lista é uma faixa de tamanho conhecido.**

```dart
SizedBox(height: 200, child: ListView.builder(scrollDirection: Axis.horizontal, ...))
```

**3. `shrinkWrap: true` — o último recurso.**

```dart
ListView.builder(
  shrinkWrap: true,                             // ⚠️
  physics: const NeverScrollableScrollPhysics(), // ⚠️
  ...
)
```

`shrinkWrap: true` manda a lista **medir todos os itens** para descobrir o próprio tamanho — ou
seja, **desliga a construção preguiçosa**, que era o motivo de usar `.builder`. Você volta ao
problema dos 5 000 widgets.

> 📌 **Regra do curso:** `shrinkWrap: true` só é aceitável quando a lista tem **poucos itens** e
> está **dentro de outra lista rolável**. Em qualquer outro caso, `Expanded` é a resposta — e, se
> você precisa de conteúdo variado rolando junto, a resposta é `CustomScrollView` com *slivers*
> (assunto do [Módulo 13](../13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md)).

### `Dismissible`: arrastar para excluir

```dart
Dismissible(
  key: ValueKey<String>(materia.id),   // OBRIGATÓRIO e precisa ser único
  direction: DismissDirection.endToStart,
  background: Container(color: Colors.red),
  confirmDismiss: (DismissDirection d) async => await _perguntar(context),
  onDismissed: (DismissDirection d) => _remover(materia),
  child: MateriaTile(materia: materia),
)
```

Três pontos que sempre dão problema:

**1. A `key` é obrigatória e precisa ser estável.** Sem ela, o Flutter não sabe **qual** item saiu
e a lista embaralha. E `ValueKey(indice)` **não serve** — os índices mudam quando um item sai.
Use o `id` do dado.

**2. Você precisa remover o item da lista no `onDismissed`.** O `Dismissible` só faz a animação.
Se você não tirar o item da sua `List`, o próximo rebuild o traz de volta — e você ganha:

```text
A dismissed Dismissible widget is still part of the tree.
```

**3. `confirmDismiss` devolve `Future<bool?>`.** `true` = pode remover, `false` = volta ao lugar,
`null` = volta ao lugar. É onde você mostra um diálogo de confirmação.

### `RefreshIndicator`: puxar para atualizar

```dart
RefreshIndicator(
  onRefresh: () async {
    await _recarregarDaApi();   // precisa ser async de verdade
  },
  child: ListView.builder(...), // precisa ser um widget rolável
)
```

Duas exigências:

- O `child` tem que **rolar**. Um `Column` dentro de `RefreshIndicator` não funciona.
- Se a lista pode ficar **vazia**, ela ainda precisa rolar — senão não há como puxar. Resolve-se
  com `physics: const AlwaysScrollableScrollPhysics()`.

---

## 💡 Analogia

Pense em duas formas de servir um jantar para 500 pessoas.

- **`ListView(children: [...])`** é preparar **os 500 pratos** antes de abrir as portas. A cozinha
  para tudo por horas, a comida esfria, e você descobre que só 30 pessoas apareceram. Foi tudo
  desperdício — e as portas ficaram fechadas enquanto isso.

- **`ListView.builder`** é a cozinha **à la minute**: você tem a receita e a lista de reservas,
  mas só monta o prato quando a mesa senta. Se 500 pessoas vierem, você faz 500 — um de cada vez,
  no ritmo em que elas chegam. A cozinha nunca para, e nada esfria.

- **`itemCount`** é a lista de reservas. Sem ela, o garçom continua trazendo pratos até o
  restaurante afundar.

- **O erro de altura infinita** é pedir para o cozinheiro montar "quantos pratos couberem no
  salão", sem ninguém ter medido o salão. Ele precisa de um número. `Expanded` é a fita métrica.

- **`shrinkWrap: true`** é o cozinheiro montar todos os pratos só para descobrir quantas mesas
  cabem. Responde à pergunta, mas joga fora a vantagem toda do à la minute.

---

## 🧪 Exemplo mínimo

Este programa prova, com números, a diferença entre as duas listas.

> **Arquivo:** `foco_ui/lib/main.dart` (temporário — é só para experimentar)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppLista());

class AppLista extends StatelessWidget {
  const AppLista({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaContagem(),
    );
  }
}

class TelaContagem extends StatefulWidget {
  const TelaContagem({super.key});

  @override
  State<TelaContagem> createState() => _TelaContagemState();
}

class _TelaContagemState extends State<TelaContagem> {
  static const int _total = 5000;
  bool _preguicosa = true;

  /// Conta quantos itens foram REALMENTE construídos.
  int _construidos = 0;

  @override
  Widget build(BuildContext context) {
    // Zera a contagem a cada troca de modo.
    _construidos = 0;

    return Scaffold(
      appBar: AppBar(title: Text('$_total itens')),
      body: Column(
        children: <Widget>[
          SwitchListTile(
            title: Text(_preguicosa ? 'ListView.builder' : 'ListView(children:)'),
            subtitle: const Text('Veja o console depois de trocar'),
            value: _preguicosa,
            onChanged: (bool v) => setState(() => _preguicosa = v),
          ),
          const Divider(height: 1),

          // O Expanded é o que dá altura FINITA para a lista.
          Expanded(
            child: _preguicosa ? _construirPreguicosa() : _construirTudo(),
          ),
        ],
      ),
    );
  }

  Widget _construirPreguicosa() {
    return ListView.builder(
      itemCount: _total,
      itemBuilder: (BuildContext context, int i) {
        _construidos++;
        debugPrint('builder: item $i construído (total até agora: $_construidos)');
        return ListTile(
          leading: CircleAvatar(child: Text('$i')),
          title: Text('Item $i'),
        );
      },
    );
  }

  Widget _construirTudo() {
    final List<Widget> itens = <Widget>[];
    for (int i = 0; i < _total; i++) {
      _construidos++;
      itens.add(ListTile(
        leading: CircleAvatar(child: Text('$i')),
        title: Text('Item $i'),
      ));
    }
    debugPrint('children: TODOS os $_construidos itens foram construídos de uma vez');
    return ListView(children: itens);
  }
}
```

**O que observar:**

- Com o interruptor **ligado** (`.builder`), o console mostra umas 12 linhas. Role a lista: novas
  linhas aparecem conforme os itens entram na tela.
- Com o interruptor **desligado**, o console mostra **uma linha dizendo 5000** — e a interface
  trava por um instante visível antes de desenhar.

Esse contraste é a aula inteira em 30 segundos.

---

## 📱 Aplicando no Flutter

Agora o `foco_ui` ganha a aba de matérias de verdade: uma lista rolável, com separadores, arrastar
para excluir, desfazer, puxar para atualizar e alternância entre lista e grade.

Você vai criar `lib/features/materias/presentation/materias_tab.dart` e evoluir o
`materia_tile.dart` da aula 4 para aceitar toque e ícone.

---

## 💻 Código completo

> **Arquivo:** `foco_ui/lib/features/materias/domain/materia.dart` (acrescente o campo `icone`)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Uma matéria de estudo, com meta e progresso.
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.minutosEstudados,
    required this.metaMinutos,
    this.icone = Icons.menu_book_outlined,
  }) : assert(metaMinutos > 0, 'A meta precisa ser maior que zero');

  final String id;
  final String nome;
  final int minutosEstudados;
  final int metaMinutos;
  final IconData icone;

  /// Progresso entre 0.0 e 1.0, pronto para barras de progresso.
  double get progresso => (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  /// Verdadeiro quando a meta já foi atingida.
  bool get concluida => minutosEstudados >= metaMinutos;

  Materia copyWith({
    String? id,
    String? nome,
    int? minutosEstudados,
    int? metaMinutos,
    IconData? icone,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaMinutos: metaMinutos ?? this.metaMinutos,
      icone: icone ?? this.icone,
    );
  }
}
```

> **Arquivo:** `foco_ui/lib/features/materias/presentation/materias_tab.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'package:foco_ui/features/materias/domain/materia.dart';
import 'package:foco_ui/features/materias/presentation/widgets/materia_tile.dart';

/// Aba de matérias: lista ou grade, com excluir, desfazer e atualizar.
class MateriasTab extends StatefulWidget {
  const MateriasTab({super.key});

  @override
  State<MateriasTab> createState() => _MateriasTabState();
}

class _MateriasTabState extends State<MateriasTab> {
  /// Dados de exemplo. No Módulo 10 eles passam a vir do banco.
  List<Materia> _materias = <Materia>[
    const Materia(id: 'dart', nome: 'Dart', minutosEstudados: 95, metaMinutos: 120, icone: Icons.code),
    const Materia(id: 'flutter', nome: 'Flutter', minutosEstudados: 40, metaMinutos: 120, icone: Icons.phone_android),
    const Materia(id: 'git', nome: 'Git e terminal', minutosEstudados: 95, metaMinutos: 90, icone: Icons.terminal),
    const Materia(id: 'sql', nome: 'Banco de dados', minutosEstudados: 30, metaMinutos: 180, icone: Icons.storage),
    const Materia(id: 'http', nome: 'APIs e HTTP', minutosEstudados: 10, metaMinutos: 150, icone: Icons.cloud_outlined),
    const Materia(id: 'testes', nome: 'Testes', minutosEstudados: 0, metaMinutos: 90, icone: Icons.science_outlined),
  ];

  bool _emGrade = false;

  // ── Ações ─────────────────────────────────────────────────────────────────

  /// Pergunta antes de excluir. Devolve null se o usuário tocar fora.
  Future<bool?> _confirmarExclusao(Materia materia) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext contextDoDialogo) => AlertDialog(
        title: const Text('Excluir matéria?'),
        content: Text('"${materia.nome}" e o progresso dela serão removidos.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(contextDoDialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contextDoDialogo).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  /// Remove o item da lista e oferece desfazer.
  void _remover(Materia materia, int posicaoOriginal) {
    setState(() {
      _materias = _materias.where((Materia m) => m.id != materia.id).toList();
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // evita fila de snackbars em exclusões rápidas
      ..showSnackBar(
        SnackBar(
          content: Text('"${materia.nome}" excluída'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () {
              setState(() {
                final List<Materia> novas = List<Materia>.of(_materias);
                // Devolve exatamente onde estava, se a posição ainda existir.
                novas.insert(posicaoOriginal.clamp(0, novas.length), materia);
                _materias = novas;
              });
            },
          ),
        ),
      );
  }

  /// Simula uma recarga vinda de fora. No Módulo 09 vira uma chamada HTTP.
  Future<void> _atualizar() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _materias = _materias
          .map((Materia m) => m.copyWith(minutosEstudados: m.minutosEstudados + 5))
          .toList();
    });
  }

  void _abrir(Materia materia) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrir ${materia.nome} — tela do Módulo 07')),
    );
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matérias'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_emGrade ? Icons.view_list_outlined : Icons.grid_view_outlined),
            tooltip: _emGrade ? 'Ver como lista' : 'Ver como grade',
            onPressed: () => setState(() => _emGrade = !_emGrade),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: _materias.isEmpty
            ? _ListaVazia(onRecarregar: _atualizar)
            : (_emGrade ? _construirGrade() : _construirLista()),
      ),
    );
  }

  /// Lista com separadores e arrastar-para-excluir.
  Widget _construirLista() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _materias.length,
      separatorBuilder: (BuildContext context, int i) =>
          const Divider(height: 1, indent: 72, endIndent: 16),
      itemBuilder: (BuildContext context, int i) {
        final Materia materia = _materias[i];

        return Dismissible(
          // A key precisa ser ÚNICA e ESTÁVEL. O id do dado serve;
          // o índice NÃO serve, porque muda quando um item sai.
          key: ValueKey<String>(materia.id),
          direction: DismissDirection.endToStart,
          background: _FundoExcluir(),
          confirmDismiss: (DismissDirection direcao) =>
              _confirmarExclusao(materia),
          onDismissed: (DismissDirection direcao) => _remover(materia, i),
          child: MateriaTile(
            materia: materia,
            onTap: () => _abrir(materia),
          ),
        );
      },
    );
  }

  /// Grade responsiva: o número de colunas vem da largura disponível.
  Widget _construirGrade() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materias.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // largura ÷ altura. Menor que 1 = célula mais alta que larga.
        childAspectRatio: 4 / 3,
      ),
      itemBuilder: (BuildContext context, int i) =>
          _CartaoGrade(materia: _materias[i], onTap: () => _abrir(_materias[i])),
    );
  }
}

/// Fundo vermelho que aparece durante o arraste.
class _FundoExcluir extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Container(
      color: cores.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Icon(Icons.delete_outline, color: cores.onErrorContainer),
    );
  }
}

/// Célula da grade.
class _CartaoGrade extends StatelessWidget {
  const _CartaoGrade({required this.materia, required this.onTap});

  final Materia materia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme tipografia = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias, // o InkWell respeita os cantos arredondados
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(materia.icone, color: cores.primary),
              const Spacer(),
              Text(
                materia.nome,
                style: tipografia.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: materia.progresso,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '${materia.minutosEstudados} / ${materia.metaMinutos} min',
                style: tipografia.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Estado vazio. Precisa ROLAR, senão o RefreshIndicator não funciona.
class _ListaVazia extends StatelessWidget {
  const _ListaVazia({required this.onRecarregar});

  final Future<void> Function() onRecarregar;

  @override
  Widget build(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;

    return ListView(
      // Sem esta linha, uma lista de um item só não rola — e não dá para puxar.
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 120),
        Icon(Icons.inbox_outlined,
            size: 64, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Center(child: Text('Nenhuma matéria', style: tipografia.titleMedium)),
        const SizedBox(height: 8),
        Center(
          child: Text('Puxe para baixo para recarregar',
              style: tipografia.bodySmall),
        ),
      ],
    );
  }
}
```

E o `MateriaTile` da aula 4 ganha `onTap` e o ícone da matéria:

> **Arquivo:** `foco_ui/lib/features/materias/presentation/widgets/materia_tile.dart`
> (só o cabeçalho e o ícone mudam)

```dart
class MateriaTile extends StatelessWidget {
  const MateriaTile({
    required this.materia,
    this.onTap,
    super.key,
  });

  final Materia materia;

  /// Opcional: quando nulo, o tile não reage ao toque.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;
    final ColorScheme cores = Theme.of(context).colorScheme;

    // InkWell por FORA do Padding: a onda do toque cobre a linha inteira.
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: materia.concluida
                    ? cores.tertiaryContainer
                    : cores.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                materia.concluida ? Icons.check : materia.icone,
                size: 22,
                color: materia.concluida
                    ? cores.onTertiaryContainer
                    : cores.onPrimaryContainer,
              ),
            ),
            // … o restante do Row continua igual ao da aula 4 …
          ],
        ),
      ),
    );
  }
}
```

Por fim, use a aba na tela principal:

```dart
// foco_ui/lib/main.dart
home: const MateriasTab(),
```

Rode e teste os cinco comportamentos:

```powershell
flutter analyze
flutter run -d chrome
```

1. Role a lista — ela rola.
2. Arraste um item da direita para a esquerda — o fundo vermelho aparece e o diálogo pergunta.
3. Confirme — o item sai e o `SnackBar` oferece **Desfazer**. Toque em Desfazer: ele volta ao lugar.
4. Puxe a lista para baixo — o indicador gira e os minutos aumentam.
5. Toque no ícone de grade na `AppBar` e **redimensione a janela**: o número de colunas muda sozinho.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `ListView.separated` | Divisórias entre itens sem poluir o `itemBuilder`. O `separatorBuilder` roda `itemCount - 1` vezes. |
| `Divider(height: 1, indent: 72, endIndent: 16)` | `indent: 72` alinha a linha com o texto, pulando o ícone de 44 px + margens. Detalhe visual que separa app amador de app cuidado. |
| `key: ValueKey<String>(materia.id)` | **Obrigatório** no `Dismissible`, e precisa ser o `id` do dado — não o índice. |
| `direction: DismissDirection.endToStart` | Só da direita para a esquerda (e o contrário em idiomas RTL). `startToEnd` permitiria os dois sentidos. |
| `confirmDismiss` devolvendo `Future<bool?>` | `true` remove, `false`/`null` devolvem o item ao lugar. É onde mora o diálogo. |
| `onDismissed` chamando `_remover` | O `Dismissible` faz **só a animação**. Se você não tirar o item da `List`, ele volta e o Flutter lança erro. |
| `..hideCurrentSnackBar()` antes do `..showSnackBar(...)` | Sintaxe de cascata (`..`) do Dart. Evita fila de mensagens quando o usuário exclui vários itens seguidos. |
| `posicaoOriginal.clamp(0, novas.length)` | O "desfazer" devolve o item **onde ele estava**. O `clamp` protege contra a lista ter encolhido enquanto isso. |
| `List<Materia>.of(_materias)` | Cria uma **cópia** antes de inserir. Mutar a lista original dentro do `setState` esconde bugs. |
| `RefreshIndicator(onRefresh: ...)` | O `onRefresh` **precisa** devolver um `Future`; o indicador some quando ele completa. |
| `physics: const AlwaysScrollableScrollPhysics()` no estado vazio | Faz uma lista curta continuar rolável — sem isso, não há como puxar para atualizar. |
| `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 220)` | Grade responsiva sem `if` de largura: o Flutter divide o espaço em colunas de no máximo 220 px. |
| `childAspectRatio: 4 / 3` | Largura ÷ altura. Aumentar esse número deixa a célula **mais baixa** — e é o primeiro lugar para olhar quando dá *overflow* na grade. |
| `clipBehavior: Clip.antiAlias` no `Card` | Faz a onda do `InkWell` respeitar os cantos arredondados. Sem isso, a onda vaza nos cantos. |
| `Spacer()` dentro da `Column` do cartão | Empurra o conteúdo para baixo, ocupando a folga vertical da célula. |
| `maxLines: 1, overflow: TextOverflow.ellipsis` | Nome de matéria longo vira `Banco de da…` em vez de quebrar o layout. |
| `_materias.where(...).toList()` em vez de `removeAt` | Trabalha com uma lista nova. Estado imutável é mais fácil de depurar — e vira regra no [Módulo 08](../08-estado-e-arquitetura/README.md). |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Rolar além do fim | *Glow* colorido na borda | *Bounce* elástico |
| Puxar para atualizar | `RefreshIndicator` — círculo que gira | `CupertinoSliverRefreshControl` — as "pás" |
| Barra de rolagem | Aparece ao rolar, some depois | Mais fina, some mais rápido |
| Velocidade da inércia | Desacelera mais rápido | Desliza por mais tempo |
| Arrastar para excluir | Padrão do Material: fundo colorido + ícone | Padrão do iOS: botão "Excluir" vermelho revelado |

O Flutter aplica **as quatro primeiras linhas sozinho**, via `ScrollBehavior`, olhando
`Theme.of(context).platform`. Você não escreve nada.

> 📌 A última linha é a única que exige decisão. O `Dismissible` faz o estilo Material nas duas
> plataformas. Para o estilo iOS de botões revelados, existe o `CupertinoContextMenu` ou o pacote
> `flutter_slidable`. Seguindo a
> [decisão do curso](../../05-decisoes-tecnicas.md) — Material nas duas —, ficamos com o
> `Dismissible`.

---

## ⚠️ Erros comuns

### 1. `Vertical viewport was given unbounded height`

```dart
Column(
  children: <Widget>[
    const Text('Título'),
    ListView.builder(itemCount: 50, itemBuilder: ...), // ❌
  ],
)
```

**Correção:**

```dart
Column(
  children: <Widget>[
    const Text('Título'),
    Expanded(child: ListView.builder(itemCount: 50, itemBuilder: ...)), // ✅
  ],
)
```

### 2. `RenderBox was not laid out` dentro de um `Row`

```dart
Row(
  children: <Widget>[
    ListView.builder(...), // ❌ largura infinita, mesmo problema em outro eixo
    const Text('Lado'),
  ],
)
```

**Correção:** `Expanded(child: ListView...)`, igual ao caso anterior — só que na horizontal.

### 3. `A dismissed Dismissible widget is still part of the tree`

```dart
Dismissible(
  key: ValueKey<String>(m.id),
  onDismissed: (_) {
    debugPrint('excluiu'); // ❌ não removeu da lista!
  },
  child: MateriaTile(materia: m),
)
```

**Correção:** o `onDismissed` **precisa** remover o item da fonte de dados dentro de um `setState`.

### 4. Usar o índice como `key`

```dart
key: ValueKey<int>(indice), // ❌
```

Ao excluir o item 2, o antigo item 3 passa a ser o índice 2 — e o Flutter acha que é o mesmo
widget. Resultado: o item errado some, ou a animação embaralha.

**Correção:** use um identificador que pertence ao **dado**: `ValueKey<String>(materia.id)`.

### 5. `shrinkWrap: true` como reflexo

```dart
ListView.builder(
  shrinkWrap: true,                              // ⚠️
  physics: const NeverScrollableScrollPhysics(), // ⚠️
  itemCount: 500,
  ...
)
```

Isso "resolve" o erro de altura **desligando a otimização inteira**: os 500 itens são construídos.
Com listas grandes, o app trava.

**Correção:** `Expanded`. Se a tela precisa de conteúdo variado rolando junto com a lista, o certo
é `CustomScrollView` com `SliverList` — assunto do
[Módulo 13](../13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md).

### 6. `GridView` com *overflow* na célula

```text
A RenderFlex overflowed by 23 pixels on the bottom.
```

A grade **impõe** a altura da célula. Se o conteúdo é mais alto, estoura.

**Correção:** ajuste o `childAspectRatio` (número **menor** = célula mais alta), reduza o
conteúdo, ou troque `Column` por `Column` com `mainAxisSize: MainAxisSize.min` + `Flexible`.

### 7. `RefreshIndicator` que não aparece

```dart
RefreshIndicator(
  onRefresh: _atualizar,
  child: Column(children: <Widget>[...]), // ❌ Column não rola
)
```

**Correção:** o filho precisa ser rolável (`ListView`, `GridView`, `CustomScrollView`). E, se ele
puder ficar curto demais para rolar, acrescente
`physics: const AlwaysScrollableScrollPhysics()`.

### 8. Esquecer o `itemCount`

```dart
ListView.builder(
  itemBuilder: (context, i) => Text('Item $i'), // ❌ lista infinita
)
```

Sem `itemCount`, o `ListView` chama o `itemBuilder` enquanto você rolar. Com dados reais, isso
vira `RangeError (index): Invalid value` no primeiro índice que não existe.

---

## 🛠️ Exercício guiado

**Passo 1.** Na `MateriasTab`, troque `ListView.separated` por `ListView.builder` e some 500 itens
de teste à lista `_materias` (um `for` gerando `Materia(id: 'teste$i', ...)`). Role. Funciona liso?

**Passo 2.** Agora troque `ListView.builder` por `ListView(children: [...])` construindo os mesmos
500. Rode. Anote quanto tempo a tela demora para aparecer.

**Passo 3.** Volte para `.builder` e remova os 500 itens de teste.

**Passo 4.** Envolva o `body` inteiro em uma `Column` com um `Text('Minhas matérias')` acima da
lista — **sem** `Expanded`. Rode e leia a mensagem de erro **inteira**. Copie a primeira linha
dela para o seu caderno.

**Passo 5.** Corrija com `Expanded`. Depois tente corrigir com `shrinkWrap: true` e responda: as
duas funcionam? Qual delas você usaria com 5 000 itens, e por quê?

**Passo 6.** Troque a `key` do `Dismissible` para `ValueKey<int>(i)`. Exclua o **segundo** item da
lista e observe. Qual item sumiu da tela? Volte a `key` para o `id`.

**Passo 7.** Mude `childAspectRatio` da grade de `4 / 3` para `4 / 5` e depois para `2 / 1`.
Descreva o que acontece em cada caso e qual deles gera *overflow*.

**Passo 8.** Faça a lista ficar vazia (apague todas as matérias, uma a uma). Confirme que o
`_ListaVazia` aparece **e** que ainda é possível puxar para atualizar. Depois comente a linha
`physics: const AlwaysScrollableScrollPhysics()` e tente de novo.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Faça os exercícios de **Aplicação** com `ListView.builder` e `GridView`, o de **Correção de bugs**
com o viewport sem altura, e o de **Compreensão** sobre `key` no `Dismissible`.

---

## 🏆 Desafio opcional

Acrescente à `MateriasTab` um **campo de busca** na `AppBar` que filtra a lista enquanto o usuário
digita, e faça a lista mostrar **cabeçalhos de seção**: "Em andamento" e "Concluídas".

Requisitos:

- A busca não pode recriar a lista inteira a cada tecla — filtre sobre `_materias` e devolva uma
  lista nova só quando o texto mudar de verdade.
- Os cabeçalhos devem ser itens do próprio `ListView.builder` (dica: monte uma
  `List<Object>` em que cada elemento é ou uma `String` de cabeçalho ou uma `Materia`, e use um
  `switch` com *pattern matching* no `itemBuilder` — técnica do
  [Módulo 04](../04-dart-avancado/05-patterns-e-switch.md)).
- O `Dismissible` não pode ser aplicado aos cabeçalhos.

Depois responda: por que essa solução continua sendo preguiçosa, mesmo com dois tipos de item
misturados na mesma lista?

---

## 📌 Resumo

- `ListView(children: [...])` constrói **todos** os widgets. Use apenas com poucos itens e
  quantidade fixa.
- `ListView.builder` recebe uma **receita** e constrói **só o que está visível**. É a escolha
  padrão para qualquer lista que possa crescer.
- **Sempre passe `itemCount`.** Sem ele a lista é infinita.
- `ListView.separated` coloca divisórias **entre** os itens, nunca depois do último.
- `GridView.builder` + `SliverGridDelegateWithMaxCrossAxisExtent` dá grade responsiva sem `if` de
  largura. `childAspectRatio` é **largura ÷ altura**.
- `Vertical viewport was given unbounded height` significa: a lista está dentro de algo que oferece
  altura infinita. A correção quase sempre é **`Expanded`**.
- `shrinkWrap: true` **desliga a construção preguiçosa**. É o último recurso, não o primeiro.
- `Dismissible` exige `key` **única e estável** (o `id` do dado, nunca o índice) e exige que você
  **remova o item da fonte de dados** no `onDismissed`.
- `confirmDismiss` devolve `Future<bool?>`: `true` remove, `false`/`null` devolvem ao lugar.
- `RefreshIndicator` exige um filho rolável e um `onRefresh` que devolva `Future`. Para listas
  curtas ou vazias, use `AlwaysScrollableScrollPhysics`.
- Ofereça **Desfazer** em toda exclusão. Custa um `SnackBarAction` e evita perda de dados.

---

## ☑️ Checklist de domínio

- [ ] Explico, em uma frase, por que `ListView.builder` aguenta 5 000 itens e `ListView` não.
- [ ] Nunca esqueço o `itemCount`.
- [ ] Uso `ListView.separated` em vez de enfiar `Divider` dentro do `itemBuilder`.
- [ ] Reconheço `Vertical viewport was given unbounded height` e corrijo com `Expanded` sem pensar.
- [ ] Sei dizer o que `shrinkWrap: true` custa e quando ele é aceitável.
- [ ] Monto uma grade responsiva com `SliverGridDelegateWithMaxCrossAxisExtent`.
- [ ] Sei que `childAspectRatio` é largura ÷ altura, e uso isso para resolver *overflow* na grade.
- [ ] Uso `ValueKey` com o **id do dado** no `Dismissible`, nunca o índice.
- [ ] Removo o item da fonte de dados no `onDismissed`.
- [ ] Ofereço confirmação com `confirmDismiss` e desfazer com `SnackBarAction`.
- [ ] Meu `RefreshIndicator` funciona também quando a lista está vazia.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Use lists — docs.flutter.dev](https://docs.flutter.dev/cookbook/lists/basic-list)
- [Work with long lists — docs.flutter.dev](https://docs.flutter.dev/cookbook/lists/long-lists)
- [ListView class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/ListView-class.html)
- [GridView class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/GridView-class.html)
- [Dismissible class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Dismissible-class.html)
- [RefreshIndicator class — api.flutter.dev](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html)
- [Using keys — docs.flutter.dev](https://docs.flutter.dev/resources/architectural-overview#keys)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 8 — Imagens e assets](08-imagens-e-assets.md) | [README](README.md) | [Aula 10 — Gestos e feedback](10-gestos-e-feedback.md) |
