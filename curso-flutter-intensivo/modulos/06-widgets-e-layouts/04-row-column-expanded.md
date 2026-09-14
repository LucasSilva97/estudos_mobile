# Aula 4 — Row, Column e Expanded

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 50 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Empilhar widgets na horizontal com `Row` e na vertical com `Column`.
- Explicar o que são **eixo principal** (*main axis*) e **eixo cruzado** (*cross axis*) e dizer qual é
  qual em cada um dos dois widgets.
- Distribuir espaço com `MainAxisAlignment`, alinhar com `CrossAxisAlignment` e encolher com
  `mainAxisSize`.
- Usar `Expanded`, `Flexible`, `flex` e `Spacer`, e dizer a diferença exata entre `Expanded` e
  `Flexible`.
- Ler, entender e **corrigir de quatro formas diferentes** o erro
  `A RenderFlex overflowed by X pixels`.
- Construir o item de lista de matérias do Foco (`MateriaTile`).

## ✅ Pré-requisitos

- [Aula 3 — Container, Padding e SizedBox](03-container-padding-sizedbox.md).
- Classes com campos `final` e construtor `const`
  ([03 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md)).
- `List` e `map` ([02 — Listas](../02-dart-basico/08-listas.md)).

---

## 📖 Conceito

### Row e Column são o mesmo widget em direções diferentes

`Row` coloca os filhos **lado a lado**, da esquerda para a direita.
`Column` coloca os filhos **um abaixo do outro**, de cima para baixo.

Os dois herdam de `Flex` e têm **exatamente os mesmos parâmetros**. Se você entender um, entendeu o
outro — desde que domine a ideia de eixos.

### Eixo principal e eixo cruzado

- **Eixo principal** (*main axis*) é a direção em que os filhos são enfileirados.
- **Eixo cruzado** (*cross axis*) é a direção perpendicular a ela.

| Widget | Eixo principal | Eixo cruzado |
|---|---|---|
| `Row` | **horizontal** (↔) | vertical (↕) |
| `Column` | **vertical** (↕) | horizontal (↔) |

Decore esta frase, porque ela resolve metade das dúvidas de layout:
**`mainAxisAlignment` distribui, `crossAxisAlignment` alinha.**

### `MainAxisAlignment`: como sobra o espaço

Imagine uma `Row` com três quadrados de 40 pixels numa tela de 300. Sobram 180 pixels. O
`mainAxisAlignment` decide onde eles ficam:

| Valor | Resultado |
|---|---|
| `start` (padrão) | `[■■■················]` — tudo no começo |
| `end` | `[················■■■]` — tudo no fim |
| `center` | `[········■■■········]` — tudo no meio |
| `spaceBetween` | `[■········■········■]` — espaço **entre** os itens, nada nas pontas |
| `spaceAround` | `[··■·····■·····■··]` — cada item com metade de espaço nas pontas |
| `spaceEvenly` | `[····■····■····■····]` — espaços todos iguais, inclusive nas pontas |

`spaceBetween` é o mais usado em itens de lista: nome à esquerda, valor à direita.

### `CrossAxisAlignment`: como alinha no outro eixo

| Valor | Numa `Row` (eixo cruzado = vertical) |
|---|---|
| `center` (padrão) | Filhos centralizados verticalmente |
| `start` | Alinhados pelo topo |
| `end` | Alinhados pela base |
| `stretch` | Todos esticados para a **altura máxima** disponível |
| `baseline` | Alinhados pela linha de base do texto (exige `textBaseline:`) |

`stretch` é a razão de muitos layouts inesperados: ele **ignora** a altura natural dos filhos e
estica todos. Dentro de uma `Column`, `crossAxisAlignment: CrossAxisAlignment.stretch` faz todos os
filhos ocuparem a largura inteira — o que às vezes é exatamente o que você quer.

### `mainAxisSize`: a `Column` ocupa a tela toda?

Por padrão, `mainAxisSize: MainAxisSize.max`: a `Column` tenta ocupar **toda a altura disponível** e a
`Row`, toda a largura.

Com `MainAxisSize.min`, ela ocupa apenas o necessário para caber os filhos.

```dart
Column(
  mainAxisSize: MainAxisSize.min, // encolhe até o tamanho dos filhos
  children: <Widget>[...],
)
```

Você precisa de `min` sempre que a `Column` estiver dentro de algo que não impõe altura — dentro de um
`Center`, de um `AlertDialog`, de um `BottomSheet`. Sem isso, ela tenta ocupar infinito e você recebe
um erro de altura ilimitada ([Aula 6](06-constraints.md)).

### `Expanded`, `Flexible` e `flex`

`Expanded` é um widget que só existe dentro de `Row`, `Column` ou `Flex`. Ele diz: **"pegue todo o
espaço livre que sobrar no eixo principal"**.

```dart
Row(
  children: <Widget>[
    const Icon(Icons.menu_book),
    Expanded(child: Text(nomeMuitoLongo)),  // fica com o resto
    const Text('120 min'),
  ],
)
```

Quando há mais de um `Expanded`, o espaço livre é dividido na proporção do `flex` (padrão `1`):

```dart
Row(
  children: <Widget>[
    Expanded(flex: 2, child: ColoredBox(color: Colors.indigo)), // 2/3
    Expanded(flex: 1, child: ColoredBox(color: Colors.amber)),  // 1/3
  ],
)
```

**`Flexible` é o irmão mais educado.** A diferença exata:

| | `Expanded` | `Flexible` |
|---|---|---|
| Espaço que pode usar | **Deve** ocupar todo o espaço oferecido | **Pode** ocupar até o espaço oferecido |
| `fit` interno | `FlexFit.tight` | `FlexFit.loose` (padrão) |
| Filho menor que o espaço | É esticado | Fica no tamanho natural |

Na prática: `Expanded` é `Flexible(fit: FlexFit.tight)`. Use `Expanded` quando quiser preencher (o
caso comum); use `Flexible` quando quiser apenas **permitir encolher** sem forçar crescimento — por
exemplo, dois textos lado a lado onde o segundo deve ficar colado no primeiro.

### `Spacer`: espaço elástico

`Spacer` é um `Expanded` que não desenha nada:

```dart
Row(
  children: <Widget>[
    const Text('Álgebra'),
    const Spacer(),          // empurra o resto para a direita
    const Text('120 min'),
  ],
)
```

O resultado é igual a `mainAxisAlignment: MainAxisAlignment.spaceBetween` com dois filhos. A vantagem
do `Spacer` aparece com três ou mais filhos, quando você quer empurrar só **parte** deles, ou com
`flex` diferente: `Spacer(flex: 2)`.

### O erro mais famoso do Flutter

```text
════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 87 pixels on the right.
The overflowing RenderFlex has an orientation of Axis.horizontal.
```

Junto com ele aparece na tela aquela faixa listrada **amarela e preta**.

**O que ele significa, literalmente:** os filhos de uma `Row`/`Column` pediram mais espaço do que
existe no eixo principal. Não é um *bug* misterioso: é o Flutter avisando que você mandou desenhar
mais do que cabe, em vez de esconder o problema silenciosamente.

O erro diz três coisas úteis: **quantos pixels** faltaram, **de que lado**, e se o eixo era
`horizontal` (`Row`) ou `vertical` (`Column`). Comece sempre lendo essas três informações.

### As quatro formas de resolver — escolha pela intenção

**1. Deixar um filho encolher: `Expanded` ou `Flexible`.**
Use quando um dos filhos é "elástico" e os outros têm tamanho fixo. É o caso do nome da matéria ao
lado de um ícone e de um número.

```dart
Row(
  children: <Widget>[
    const Icon(Icons.menu_book),
    Expanded(child: Text(nome, maxLines: 1, overflow: TextOverflow.ellipsis)),
    const Text('120 min'),
  ],
)
```

**2. Deixar rolar: `SingleChildScrollView` ou `ListView`.**
Use quando o conteúdo é legitimamente maior que a tela — um formulário longo, uma tela de detalhes.

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(children: <Widget>[...]),
)
```

**3. Deixar quebrar linha: `Wrap`.**
Use quando os filhos são muitos e independentes — etiquetas, filtros, chips. `Wrap` tem os mesmos
`spacing` e `runSpacing` e joga para a linha de baixo o que não couber.

```dart
Wrap(
  spacing: 8,      // espaço entre itens na mesma linha
  runSpacing: 8,   // espaço entre linhas
  children: <Widget>[...],
)
```

**4. Reduzir o conteúdo: `maxLines` + `ellipsis`, ou `FittedBox`.**
Use quando o conteúdo **precisa** caber. `FittedBox` encolhe o filho proporcionalmente até caber:

```dart
FittedBox(
  fit: BoxFit.scaleDown, // só diminui, nunca aumenta
  child: Text('Número gigante que precisa caber'),
)
```

⚠️ Existe uma quinta "solução" que você vai ver na internet e **não deve usar**: envolver em
`SizedBox` com altura chutada, ou trocar `Row` por `ListView` horizontal só para o aviso sumir. Isso
esconde o sintoma, e o layout continua errado em outro tamanho de tela.

---

## 💡 Analogia

Pense numa **estante de livros**.

- A `Row` é uma prateleira: os livros ficam lado a lado. O eixo principal é a horizontal.
- `mainAxisAlignment` decide se você empurra todos para a esquerda, distribui com espaço igual, ou
  encosta nas duas pontas.
- `crossAxisAlignment` decide se os livros ficam alinhados pelo topo, pela base ou pelo meio (livros
  de alturas diferentes).
- `Expanded` é um livro de capa mole que se espreme para preencher o vão que sobrou.
- O `RenderFlex overflowed` é o momento em que você tenta colocar mais um livro e ele fica para fora
  da prateleira. A prateleira não estica sozinha — e é bom que não estique, senão você nunca saberia.

---

## 🧪 Exemplo mínimo

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ExemploEixos()));

class ExemploEixos extends StatelessWidget {
  const ExemploEixos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              Text('Álgebra'),
              Text('120 min'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: const <Widget>[
              Text('Cálculo'),
              Spacer(),
              Text('45 min'),
            ],
          ),
        ],
      ),
    );
  }
}
```

As duas `Row` produzem o mesmo resultado visual por caminhos diferentes. Rode e confirme.

---

## 📱 Aplicando no Flutter

Agora vamos ao item de lista do Foco: o **`MateriaTile`**. Ele é uma `Row` com três partes:

```text
┌────────────────────────────────────────────────────────┐
│ [ícone]  Álgebra Linear                      120 min   │
│          Meta: 180 min                       ▓▓▓▓░░░   │
└────────────────────────────────────────────────────────┘
   fixo    ←──── Expanded (elástico) ────→     fixo
```

Antes, precisamos de um **modelo**: uma classe que representa uma matéria. Ela vai viver em
`domain/`, porque descreve o problema (o domínio "estudos"), não a tela.

Crie a pasta:

```powershell
mkdir lib\features\materias\domain
```

> Se você fez os desafios opcionais das aulas 2 e 3, o arquivo `materia_tile.dart` já existe com
> outros widgets dentro. Cole o código desta aula **acima** do que você já tinha; um arquivo `.dart`
> pode conter várias classes.

---

## 💻 Código completo

> **Arquivo:** `lib/features/materias/domain/materia.dart`
> **Como executar:** `flutter run -d windows`

```dart
/// Uma matéria de estudo do app Foco.
///
/// Classe imutável: todos os campos são `final` e o construtor é `const`.
/// Isso permite usar `const` nos widgets que a recebem.
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.minutosEstudados,
    required this.metaMinutos,
  }) : assert(metaMinutos > 0, 'A meta precisa ser maior que zero');

  final String id;
  final String nome;
  final int minutosEstudados;
  final int metaMinutos;

  /// Progresso entre 0.0 e 1.0, pronto para barras de progresso.
  double get progresso =>
      (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  Materia copyWith({
    String? id,
    String? nome,
    int? minutosEstudados,
    int? metaMinutos,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaMinutos: metaMinutos ?? this.metaMinutos,
    );
  }

  @override
  String toString() => 'Materia($id, $nome, $minutosEstudados/$metaMinutos)';
}
```

> **Arquivo:** `lib/features/materias/presentation/widgets/materia_tile.dart`
> **Como executar:** `flutter run -d windows`

```dart
import 'package:flutter/material.dart';

import '../../domain/materia.dart';

/// Item de lista que mostra uma matéria, seus minutos e o progresso da meta.
class MateriaTile extends StatelessWidget {
  const MateriaTile({required this.materia, super.key});

  final Materia materia;

  @override
  Widget build(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 1. Parte fixa: o ícone dentro de um círculo colorido.
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cores.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 22,
              color: cores.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),

          // 2. Parte elástica: nome + meta + barra de progresso.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  materia.nome,
                  style: tipografia.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Meta: ${materia.metaMinutos} min por semana',
                  style: tipografia.bodySmall?.copyWith(
                    color: cores.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: LinearProgressIndicator(
                    value: materia.progresso,
                    minHeight: 6,
                    backgroundColor: cores.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 3. Parte fixa: os minutos estudados.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${materia.minutosEstudados}',
                style: tipografia.titleLarge?.copyWith(
                  color: cores.primary,
                  fontWeight: FontWeight.w700,
                ),
                semanticsLabel:
                    '${materia.minutosEstudados} minutos em ${materia.nome}',
              ),
              Text('min', style: tipografia.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
```

> **Arquivo:** `lib/features/materias/presentation/home_screen.dart`
> **Como executar:** `flutter run -d windows`

Acrescente os dois `import` no topo e troque o `body`:

```dart
import '../domain/materia.dart';
import 'widgets/cartao_destaque.dart';
import 'widgets/materia_tile.dart';
```

Dentro de `_HomeScreenState`, adicione a lista de exemplo:

```dart
  static const List<Materia> _materias = <Materia>[
    Materia(
      id: '1',
      nome: 'Introdução à Álgebra Linear com Aplicações',
      minutosEstudados: 120,
      metaMinutos: 180,
    ),
    Materia(id: '2', nome: 'Cálculo I', minutosEstudados: 45, metaMinutos: 240),
    Materia(id: '3', nome: 'Inglês técnico', minutosEstudados: 240, metaMinutos: 120),
  ];
```

E o `body`:

```dart
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 96),
          children: <Widget>[
            const CartaoDestaque(
              minutosHoje: 120,
              metaMinutos: 180,
              materiaAtual: 'Introdução à Álgebra Linear com Aplicações',
            ),
            for (final Materia materia in _materias)
              MateriaTile(materia: materia),
          ],
        ),
      ),
```

Aquele `for` dentro da lista de `children` é o *collection-for* do Dart, visto em
[02 — Listas](../02-dart-basico/08-listas.md). Na [Aula 9](09-listas-e-rolagem.md) ele dá lugar ao
`ListView.builder`, e você vai entender exatamente por quê.

---

## 🔍 Explicando o código

**`assert(metaMinutos > 0, ...)` na lista de inicialização** — o `assert` roda apenas em modo de
depuração e derruba o app com mensagem clara se alguém criar uma matéria com meta zero. Repare que o
construtor continua `const`: `assert` na lista de inicialização **não** impede `const`.

**`double get progresso => (minutosEstudados / metaMinutos).clamp(0.0, 1.0);`** — campo calculado, sem
ocupar memória. O `clamp` evita que 240/120 = 2.0 estoure o `LinearProgressIndicator`, que só aceita
valores entre 0 e 1.

**`Container(width: 44, height: 44, shape: BoxShape.circle)`** — aqui o `Container` é a escolha certa:
ele faz **três** coisas ao mesmo tempo (tamanho, decoração circular e alinhamento do filho). É o caso
que a Aula 3 descreveu como legítimo.

**`Expanded` no meio da `Row`** — este é o coração da aula. O ícone tem 44 pixels, o bloco de minutos
tem a largura do texto, e o `Expanded` fica com **todo o resto**. Por isso o nome comprido vira
`Introdução à Álgebra Li…` em vez de estourar.

**`mainAxisSize: MainAxisSize.min` nas duas `Column` internas** — sem isso, cada `Column` tentaria
ocupar toda a altura disponível dentro da `Row`, e a `Row` ficaria mais alta do que o necessário.
Dentro de `Row`, quase toda `Column` quer `MainAxisSize.min`.

**`crossAxisAlignment: CrossAxisAlignment.end` na `Column` da direita** — alinha "240" e "min" pela
direita, para os números ficarem em coluna reta.

**`ClipRRect` em volta do `LinearProgressIndicator`** — a barra de progresso é retangular por padrão.
`ClipRRect` corta as pontas em arco. É mais direto que `Container(clipBehavior:)`.

**`semanticsLabel` no número** — sem ele, o leitor de tela falaria só "cento e vinte", fora de
contexto. Com ele, fala "cento e vinte minutos em Introdução à Álgebra Linear com Aplicações".

**`static const List<Materia> _materias`** — a lista inteira é `const` porque `Materia` tem
construtor `const`. É o ganho concreto de imutabilidade mencionado no
[Módulo 03](../03-dart-intermediario/03-encapsulamento.md).

---

## ⚠️ Erros comuns

**1. `A RenderFlex overflowed by X pixels on the right`**

Causa quase sempre: um `Text` longo direto dentro de uma `Row`, sem `Expanded`. Teste você mesmo:
apague o `Expanded` do `MateriaTile`, salve, e observe a faixa listrada. Depois devolva.

**2. `Incorrect use of ParentDataWidget`**

```text
Incorrect use of ParentDataWidget.
The ownership chain for the RenderObject that received the incompatible parent data was: ...
```

Significa: você usou `Expanded`, `Flexible` ou `Spacer` **fora** de uma `Row`, `Column` ou `Flex`.
Erro clássico: colocar `Expanded` dentro de um `Stack` ou direto no `body` do `Scaffold`.

**3. `Vertical viewport was given unbounded height`**

Uma `Column` dentro de um `SingleChildScrollView` contendo um `ListView` sem altura. Isso é um caso
de *constraints*, e a [Aula 6](06-constraints.md) é inteira sobre esse erro.

**4. `Expanded` dentro de `Column` que está dentro de `SingleChildScrollView`**

```text
RenderFlex children have non-zero flex but incoming height constraints are unbounded.
```

Dentro de uma área rolável, a altura é infinita — e "uma fração do infinito" não faz sentido. Troque
`Expanded` por tamanho fixo, ou tire a rolagem.

**5. Confundir `MainAxisAlignment.center` com `CrossAxisAlignment.center` numa `Column`**

Centralizar **verticalmente** numa `Column` é `mainAxisAlignment`. Centralizar **horizontalmente** é
`crossAxisAlignment`. Numa `Row` é o contrário. Quando errar, releia a tabela de eixos.

**6. `Spacer` dentro de `Column` com `mainAxisSize: MainAxisSize.min`**

Não faz sentido: `Spacer` divide o espaço **livre**, e `min` diz que não há espaço livre. O Flutter
lança exceção.

---

## 🛠️ Exercício guiado

Vamos provocar o erro de estouro **de propósito** e corrigi-lo de quatro maneiras diferentes, para
você ver na prática o que cada uma faz.

**Passo 1 — Provoque.** No `MateriaTile`, troque `Expanded(child: Column(...))` por
`Column(...)` puro (apague o `Expanded`, mantendo o filho). Salve.

Resultado: faixa listrada à direita e, no console,
`A RenderFlex overflowed by 63 pixels on the right.` (o número varia com a largura da sua janela).

**Passo 2 — Corrija com `Flexible`.** Envolva a `Column` em `Flexible` em vez de `Expanded`:

```dart
Flexible(child: Column(...)),
```

Observe: o estouro some. Diferença em relação a `Expanded`: com nomes **curtos**, a `Column` fica do
tamanho natural e os minutos ficam colados nela, em vez de irem para a borda direita. Teste trocando
o nome da matéria 2 para `'Cálculo'`.

**Passo 3 — Corrija com rolagem.** Desfaça o passo 2 e envolva a `Row` inteira:

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(...),
)
```

Observe: o estouro some, mas agora o usuário precisa **arrastar para o lado** para ler o final. Para
um item de lista isso é péssima experiência — mas para uma barra de filtros pode ser exatamente o
certo.

**Passo 4 — Corrija com `FittedBox`.** Desfaça o passo 3 e envolva só o `Text` do nome:

```dart
FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(materia.nome, style: tipografia.titleMedium),
)
```

Observe: o texto **encolhe** até caber. Fica minúsculo com nomes longos, e ilegível. `FittedBox` é
ótimo para um número de destaque, e ruim para texto de leitura.

**Passo 5 — Volte para `Expanded`** e deixe o código como estava no "Código completo".

**O que observar, em uma frase:** as quatro soluções são válidas; o que muda é **o que você está
disposto a sacrificar** — posição, rolagem ou tamanho da fonte.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Priorize os exercícios de **Correção de bugs**: todos os de estouro de layout estão lá.

---

## 🏆 Desafio opcional

Transforme o `MateriaTile` em um item de duas colunas com alinhamento perfeito:

1. Alinhe o número de minutos de todas as linhas na **mesma posição horizontal**, independentemente
   do tamanho do número. Dica: dê ao bloco da direita uma largura fixa com `SizedBox(width: 64)`.
2. Faça a barra de progresso mudar de cor: `error` quando o progresso for menor que 0,25, `primary`
   entre 0,25 e 0,99, e `tertiary` quando chegar a 1,0.
3. Acrescente, entre o nome e a meta, uma `Row` com `Wrap` de duas etiquetas ("Exatas", "Prova
   dia 20") que quebre linha em telas estreitas.
4. Garanta que nada estoure com a fonte do sistema em 200 %.

Critério de sucesso: nenhuma faixa listrada em nenhuma largura de janela, de 320 a 1600 pixels.

---

## 📌 Resumo

- `Row` (horizontal) e `Column` (vertical) são o mesmo widget em direções diferentes.
- Eixo principal = direção do enfileiramento; eixo cruzado = perpendicular.
  **`mainAxisAlignment` distribui, `crossAxisAlignment` alinha.**
- `mainAxisSize: MainAxisSize.min` faz a `Row`/`Column` encolher até o tamanho dos filhos.
  Dentro de outra `Row`/`Column`, quase sempre é o que você quer.
- `Expanded` = ocupa **obrigatoriamente** o espaço livre (`FlexFit.tight`).
  `Flexible` = **pode** ocupar, mas não estica (`FlexFit.loose`).
- `flex` divide o espaço livre em proporções. `Spacer` é `Expanded` invisível.
- `A RenderFlex overflowed by X pixels` tem quatro soluções legítimas:
  **(1)** `Expanded`/`Flexible`, **(2)** rolagem, **(3)** `Wrap`, **(4)** reduzir com
  `ellipsis`/`FittedBox`. Escolha pela intenção, não pela pressa.
- `Expanded` fora de `Row`/`Column`/`Flex` gera `Incorrect use of ParentDataWidget`.

---

## ☑️ Checklist de domínio

- [ ] Digo, sem pensar, qual é o eixo principal de uma `Row` e de uma `Column`.
- [ ] Sei escolher entre `mainAxisAlignment` e `crossAxisAlignment` para centralizar em cada direção.
- [ ] Explico a diferença entre `Expanded` e `Flexible` com um exemplo concreto.
- [ ] Uso `flex` para dividir espaço em proporção 2:1.
- [ ] Provoquei um `RenderFlex overflowed` e o corrigi com **pelo menos duas** técnicas diferentes.
- [ ] Sei o que causa `Incorrect use of ParentDataWidget`.
- [ ] Meu `MateriaTile` não estoura com nome de 60 caracteres nem com janela de 320 pixels.
- [ ] A classe `Materia` tem construtor `const`, `copyWith` e campo calculado `progresso`.
- [ ] `flutter analyze` passa sem avisos.

---

## 📚 Referências oficiais

- [API — `Row`](https://api.flutter.dev/flutter/widgets/Row-class.html)
- [API — `Column`](https://api.flutter.dev/flutter/widgets/Column-class.html)
- [API — `Expanded`](https://api.flutter.dev/flutter/widgets/Expanded-class.html)
- [API — `Flexible`](https://api.flutter.dev/flutter/widgets/Flexible-class.html)
- [API — `Spacer`](https://api.flutter.dev/flutter/widgets/Spacer-class.html)
- [API — `Wrap`](https://api.flutter.dev/flutter/widgets/Wrap-class.html)
- [API — `FittedBox`](https://api.flutter.dev/flutter/widgets/FittedBox-class.html)
- [Flutter — Layouts em Flutter](https://docs.flutter.dev/ui/layout)
- [Flutter — Erros comuns de layout](https://docs.flutter.dev/testing/common-errors)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Container, Padding e SizedBox](03-container-padding-sizedbox.md) | [README](README.md) | [Aula 5 — Stack e Positioned](05-stack-e-positioned.md) |
