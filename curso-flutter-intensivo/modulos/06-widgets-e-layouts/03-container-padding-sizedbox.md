# Aula 3 — Container, Padding e SizedBox

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Listar **tudo** o que um `Container` faz (`padding`, `margin`, `color`, `decoration`, `alignment`,
  `constraints`, `transform`) e explicar que ele é uma **conveniência**, não um widget primitivo.
- Decorar uma caixa com `BoxDecoration`: cor, borda, `borderRadius`, sombra e gradiente.
- Escrever espaçamento com as quatro formas de `EdgeInsets`.
- Escolher conscientemente entre `Padding`, `SizedBox` e `Container` — e justificar a escolha.
- Entender por que `color` e `decoration` juntos no mesmo `Container` causam erro.
- Extrair o resumo do dia da `HomeScreen` para um widget próprio, `CartaoDestaque`.

## ✅ Pré-requisitos

- [Aula 1 — Scaffold e AppBar](01-scaffold-e-appbar.md) e
  [Aula 2 — Texto, tipografia e ícones](02-texto-tipografia-icones.md).
- Saber criar uma classe com construtor `const` e parâmetros nomeados obrigatórios
  ([03 — Construtores](../03-dart-intermediario/02-construtores.md)).

---

## 📖 Conceito

### O que é o `Container`

`Container` é um widget de **conveniência**: ele não sabe fazer nada sozinho. Internamente, ele monta
uma pilha de widgets menores, cada um com uma responsabilidade única, e só inclui na pilha os que
você realmente pediu.

Quando você escreve isto:

```dart
Container(
  padding: const EdgeInsets.all(16),
  color: Colors.indigo,
  child: const Text('Oi'),
)
```

o Flutter monta, por baixo, algo próximo de:

```dart
ColoredBox(
  color: Colors.indigo,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: const Text('Oi'),
  ),
)
```

Entender isso muda a forma como você lê o código dos outros: um `Container` com cinco parâmetros é
uma pilha de cinco widgets.

### Todos os parâmetros do `Container`, e em que ordem eles agem

Esta é a ordem real, **de fora para dentro**:

| Ordem | Parâmetro | O que faz |
|---|---|---|
| 1 | `margin` | Espaço **por fora** da caixa. Nada é pintado aqui |
| 2 | `constraints` | Restrições de tamanho mínimo e máximo |
| 3 | `width` / `height` | Atalho que vira `constraints` apertadas |
| 4 | `transform` | Rotação, escala, translação |
| 5 | `decoration` | O que é pintado **atrás** do filho (cor, borda, sombra, gradiente) |
| 6 | `padding` | Espaço **por dentro**, entre a decoração e o filho |
| 7 | `alignment` | Onde o filho fica dentro do espaço disponível |
| 8 | `foregroundDecoration` | O que é pintado **na frente** do filho |
| 9 | `child` | O widget interno |
| — | `color` | Atalho para `decoration: BoxDecoration(color: ...)` |
| — | `clipBehavior` | Se o conteúdo é cortado nos limites da decoração |

Duas regras que decorrem diretamente dessa ordem:

1. **`margin` é por fora, `padding` é por dentro.** A cor pinta a área do `padding`, nunca a do
   `margin`.
2. **`color` e `decoration` não podem coexistir.** `color` já é um atalho para criar a `decoration`;
   informar os dois é uma contradição, e o Flutter lança uma exceção explicando isso.

### `EdgeInsets`: as quatro formas de dizer "espaço"

```dart
const EdgeInsets.all(16)                                  // 16 nos quatro lados
const EdgeInsets.symmetric(horizontal: 24, vertical: 12)  // laterais 24, topo/base 12
const EdgeInsets.only(left: 16, top: 8)                   // só os que você citar
const EdgeInsets.fromLTRB(16, 8, 16, 24)                  // esquerda, topo, direita, base
EdgeInsets.zero                                           // nenhum espaço
```

Existe ainda `EdgeInsetsDirectional`, que troca `left`/`right` por `start`/`end`. Em idiomas escritos
da direita para a esquerda (árabe, hebraico), `start` vira o lado direito automaticamente. Para um app
só em português, `EdgeInsets` basta — mas saiba que a outra existe.

Os números são **pixels lógicos** (*dp*, *density-independent pixels*): unidades que o Flutter
converte para os pixels reais do aparelho. Assim, 16 dp têm o mesmo tamanho físico num celular
barato e num topo de linha, mesmo que o segundo tenha três vezes mais pixels.

O Material Design trabalha em múltiplos de **4**: 4, 8, 12, 16, 24, 32. Use essa escala; ela é a
diferença entre uma tela "arrumada" e uma tela "quase arrumada".

### `BoxDecoration`

`BoxDecoration` descreve a pintura da caixa:

```dart
BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: Colors.indigo, width: 1.5),
  boxShadow: const <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000), // preto com 10 % de opacidade
      blurRadius: 12,           // quanto a sombra "borra"
      offset: Offset(0, 4),     // deslocamento: 0 na horizontal, 4 para baixo
    ),
  ],
  gradient: const LinearGradient(
    colors: <Color>[Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
)
```

Variações de `borderRadius`:

```dart
BorderRadius.circular(16)                         // todos os cantos
BorderRadius.only(topLeft: Radius.circular(16))   // um canto
BorderRadius.vertical(top: Radius.circular(24))   // dois cantos de cima
const BorderRadius.all(Radius.circular(16))       // versão const de circular()
```

⚠️ `BorderRadius.circular(16)` **não** é `const` (é uma função). Se você precisa de uma decoração
`const` — e você quase sempre quer, por desempenho — use `BorderRadius.all(Radius.circular(16))`.

### Quando **não** usar `Container`

Esta é a parte que separa código de iniciante de código de profissional.

| Você quer só… | Use | Por quê |
|---|---|---|
| espaço interno | `Padding` | Um widget, uma responsabilidade. Mais legível e mais barato |
| espaço vazio entre widgets | `SizedBox(height: 8)` | É `const`, não aloca decoração nenhuma |
| tamanho fixo | `SizedBox(width: 48, height: 48)` | Idem |
| pintar uma cor | `ColoredBox` | Mais direto que `Container(color:)` |
| cantos arredondados + sombra do tema | `Card` | Já aplica elevação e cor de superfície do Material 3 |
| cortar num formato | `ClipRRect` | `Container` com `clipBehavior` é mais indireto |
| **duas ou mais dessas coisas juntas** | `Container` | Aí ele compensa, e o código fica mais curto |

Regra prática do curso: **`Container` com um único parâmetro é quase sempre o widget errado.**

### `SizedBox`: três usos distintos

```dart
const SizedBox(height: 16)                  // 1. espaçador vertical
const SizedBox(width: 48, height: 48)       // 2. caixa de tamanho fixo
const SizedBox.shrink()                     // 3. "não desenhe nada" (0 × 0)
SizedBox.expand(child: ...)                 // 4. ocupe todo o espaço que o pai permitir
```

O `SizedBox.shrink()` é a resposta idiomática para "esse widget não deve aparecer agora":

```dart
mostrarSelo ? const Selo() : const SizedBox.shrink()
```

---

## 💡 Analogia

Pense num **quadro pendurado na parede**:

- A **moldura** é a `decoration`: cor, borda, sombra projetada na parede.
- O **passe-partout** (aquela margem de papel entre a moldura e a foto) é o `padding`: fica *dentro*
  da moldura, e é pintado da cor da moldura.
- A **distância até o próximo quadro** é a `margin`: está fora da moldura e não pertence a ela.
- A **foto** é o `child`.

Quando alguém pergunta "por que a cor não apareceu nessa parte?", a resposta quase sempre é: aquela
parte é `margin`, e `margin` não é pintada.

---

## 🧪 Exemplo mínimo

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ExemploCaixa()));

class ExemploCaixa extends StatelessWidget {
  const ExemploCaixa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Text('Cartão'),
        ),
      ),
    );
  }
}
```

Troque `margin` por `padding` e vice-versa e rode de novo: você vê imediatamente qual das duas áreas
recebe a cor branca.

---

## 📱 Aplicando no Flutter

O resumo do dia que você escreveu na Aula 2 está solto dentro da `HomeScreen`. Vamos:

1. **Extrair** para um widget próprio, `CartaoDestaque`, em arquivo separado.
2. Envolver em um cartão com cor de superfície, cantos arredondados e sombra suave.
3. Usar as três ferramentas da aula no lugar certo: `Padding` para espaço, `SizedBox` para
   espaçadores, `Container` para a caixa decorada.

Extrair widget para arquivo próprio não é organização por capricho: widgets menores são reconstruídos
menos vezes e podem ser `const`, o que o Flutter aproveita para pular trabalho
([13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md)).

Crie a pasta:

```powershell
mkdir lib\features\materias\presentation\widgets
```

---

## 💻 Código completo

> **Arquivo:** `lib/features/materias/presentation/widgets/cartao_destaque.dart`
> **Como executar:** `flutter run -d windows`

```dart
import 'package:flutter/material.dart';

/// Cartão do topo da aba "Hoje": mostra o total de minutos estudados
/// e o quanto falta para a meta do dia.
class CartaoDestaque extends StatelessWidget {
  const CartaoDestaque({
    required this.minutosHoje,
    required this.metaMinutos,
    required this.materiaAtual,
    super.key,
  });

  final int minutosHoje;
  final int metaMinutos;
  final String materiaAtual;

  @override
  Widget build(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;
    final ColorScheme cores = Theme.of(context).colorScheme;
    final int restante = (metaMinutos - minutosHoje).clamp(0, metaMinutos);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: cores.outlineVariant),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Bom estudo!', style: tipografia.titleMedium),
          const SizedBox(height: 4),
          Text(
            '$minutosHoje min',
            style: tipografia.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cores.primary,
            ),
            semanticsLabel: '$minutosHoje minutos estudados hoje',
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: restante == 0 ? 'Meta de hoje ' : 'Faltam ',
              children: <InlineSpan>[
                TextSpan(
                  text: restante == 0 ? 'concluída' : '$restante minutos',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: restante == 0 ? '. ' : ' para bater a meta. '),
              ],
            ),
            style: tipografia.bodyMedium,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('Matéria em andamento', style: tipografia.labelLarge),
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.menu_book_outlined,
                size: 20,
                color: cores.primary,
                semanticLabel: 'Matéria',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  materiaAtual,
                  style: tipografia.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

Troque o `body:` e apague o método `_construirResumo` (ele virou o widget novo). No topo do arquivo,
acrescente o `import`:

```dart
import 'widgets/cartao_destaque.dart';
```

E o `body`:

```dart
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 96),
          children: const <Widget>[
            CartaoDestaque(
              minutosHoje: 120,
              metaMinutos: 180,
              materiaAtual: 'Introdução à Álgebra Linear com Aplicações',
            ),
          ],
        ),
      ),
```

Rode e compare com a aula anterior:

```powershell
flutter run -d windows
```

---

## 🔍 Explicando o código

**`const CartaoDestaque({required this.minutosHoje, ..., super.key});`** — construtor `const` com
parâmetros nomeados obrigatórios. Como todos os campos são `final` e o construtor é `const`, o Flutter
pode reutilizar a mesma instância do widget entre reconstruções quando os valores não mudam.

**`(metaMinutos - minutosHoje).clamp(0, metaMinutos)`** — `clamp` prende o número dentro de um
intervalo. Sem ele, quem estudasse 200 minutos com meta de 180 veria "Faltam -20 minutos". Detalhes
que ninguém percebe quando estão certos, e todo mundo percebe quando estão errados.

**`cores.surfaceContainerHighest`** — um dos papéis de cor do Material 3, pensado exatamente para
"caixa elevada sobre o fundo". Usar o papel, e não um hexadecimal, é o que faz o cartão funcionar
sozinho no modo escuro ([Aula 7](07-cores-temas-modo-escuro.md)).

**`border: Border.all(color: cores.outlineVariant)`** — borda de 1 pixel na cor de contorno suave do
tema. Junto com a sombra leve, dá o relevo do Material 3 sem pesar.

**`const BorderRadius.all(Radius.circular(20))`** — versão `const` de `BorderRadius.circular(20)`.
Repare que a `decoration` inteira **não** pôde ser `const`, porque `cores.surfaceContainerHighest`
só é conhecido em tempo de execução. Mas o `boxShadow` e o `borderRadius` internos são — e isso já
economiza alocações.

**`margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12)`** — afasta o cartão das bordas da tela
e do próximo elemento. Como é `margin`, a sombra do cartão tem espaço para aparecer; se fosse
`padding` do pai, funcionaria também, mas a responsabilidade ficaria no lugar errado.

**`Padding(padding: EdgeInsets.only(bottom: 4), child: Text(...))`** — aqui eu quero espaço **abaixo
de um widget só**. Um `SizedBox(height: 4)` depois dele daria o mesmo resultado visual; escolhi
`Padding` para você ver as duas formas lado a lado no mesmo arquivo. Ambas são aceitáveis; o que não
é aceitável é `Container(padding: ...)` sem mais nada.

**`ListView` no `body` com `padding: EdgeInsets.only(bottom: 96)`** — trocamos o `Center` por um
`ListView` porque a tela vai crescer nas próximas aulas. Os 96 pixels embaixo garantem que o
`FloatingActionButton` não cubra o último item — aquele erro que a Aula 1 anunciou.

---

## ⚠️ Erros comuns

**1. `color` e `decoration` no mesmo `Container`**

```text
Cannot provide both a color and a decoration
The color argument is just a shorthand for "decoration: BoxDecoration(color: color)".
```

A própria mensagem ensina a correção: mova a cor para dentro da `BoxDecoration`.

**2. Esperar que a `margin` seja pintada**

`Container(margin: EdgeInsets.all(20), color: Colors.red)` pinta de vermelho apenas a área **interna**.
Os 20 pixels externos continuam mostrando o fundo da tela. É assim mesmo.

**3. `Container` vazio ocupando a tela inteira**

```dart
Container(color: Colors.red) // ocupa TUDO
```

Sem filho e sem tamanho, o `Container` fica o maior possível dentro do que o pai permite. Esse
comportamento parece arbitrário agora e vai fazer sentido completo na
[Aula 6 — Constraints](06-constraints.md).

**4. `BoxShadow` sem `const` dentro de lista `const`**

```text
Arguments of a constant creation must be constant expressions.
```

Se a lista é `const`, cada `BoxShadow` dela também precisa ser `const` — e cada `Color` também. Por
isso usamos `Color(0x14000000)` em vez de `Colors.black.withValues(alpha: 0.08)`: o segundo é uma
chamada de método, não uma constante.

**5. Sombra que não aparece**

Três causas comuns: (a) a cor da sombra é opaca demais ou transparente demais; (b) o widget está
dentro de um `ClipRRect` que corta a sombra; (c) existe outro widget pintando por cima. Para
depurar, aumente o `blurRadius` para 30 e ponha a sombra vermelha — se nem assim aparecer, é corte.

**6. Usar `Container` como espaçador**

```dart
Container(height: 16) // ❌
const SizedBox(height: 16) // ✅
```

O primeiro cria uma pilha de widgets para não desenhar nada e não pode ser `const`.

---

## 🛠️ Exercício guiado

Vamos trocar o `Container` decorado por um `Card` do Material 3 e comparar os dois.

**Passo 1.** Em `cartao_destaque.dart`, duplique o `build` mentalmente: substitua o `Container`
externo por:

```dart
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          // ... exatamente o mesmo conteúdo de antes
        ),
      ),
    );
```

**Passo 2.** Rode e compare.

**O que observar:**

- O `Card` já aplica a cor de superfície, o raio de canto e a elevação **definidos pelo tema**. Você
  escreveu menos código e ganhou coerência automática com o resto do app.
- Em compensação, você perdeu o controle fino: para mudar o raio, agora precisa de
  `shape: RoundedRectangleBorder(...)` ou de mexer no `CardTheme` do tema.
- `clipBehavior: Clip.antiAlias` faz o conteúdo respeitar os cantos arredondados — necessário quando
  houver imagem dentro do cartão, o que acontece na [Aula 8](08-imagens-e-assets.md).

**Passo 3.** Decida. Para este curso, **volte para o `Container`**: ele nos dá controle sobre a borda
e a sombra exatas que queremos, e nos obriga a praticar `BoxDecoration`. Guarde o `Card` para quando
quiser o padrão do tema sem esforço.

**Resultado esperado:** você consegue explicar, em uma frase, a diferença entre os dois — "`Card` é
opinião do tema, `Container` é decisão sua".

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Faça os exercícios de **Aplicação** que pedem cartões decorados e o de **Leitura de código** que
mostra um `Container` com sete parâmetros para você traduzir em widgets simples.

---

## 🏆 Desafio opcional

Crie um widget `Etiqueta` (uma "pílula" colorida, como as de categoria) em
`lib/features/materias/presentation/widgets/materia_tile.dart`:

1. Recebe `texto` (`String`) e `cor` (`Color`).
2. Tem `padding` horizontal 12 e vertical 6.
3. Cantos totalmente arredondados: use `BorderRadius.all(Radius.circular(999))` e entenda por que um
   raio gigante produz uma pílula perfeita em qualquer altura.
4. O fundo usa a cor recebida com baixa opacidade e o texto usa a cor cheia.
5. O construtor é `const`.
6. Use a `Etiqueta` no `CartaoDestaque` para mostrar a palavra "Meta" ao lado do número.

Critério de sucesso: a pílula fica com a altura exata do texto, cresce junto quando a fonte do sistema
aumenta, e `flutter analyze` não reclama.

---

## 📌 Resumo

- `Container` é conveniência: ele monta `Padding`, `DecoratedBox`, `ConstrainedBox`, `Align` e
  `Transform` conforme o que você pedir.
- Ordem de fora para dentro: `margin` → `constraints` → `transform` → `decoration` → `padding` →
  `alignment` → `child`.
- `margin` é por fora e **não é pintada**; `padding` é por dentro e **é** pintado.
- `color` e `decoration` no mesmo `Container` lançam exceção. Escolha um.
- `BoxDecoration` = cor + borda + `borderRadius` + `boxShadow` + `gradient`.
  `BorderRadius.circular()` não é `const`; `BorderRadius.all(Radius.circular())` é.
- `EdgeInsets`: `all`, `symmetric`, `only`, `fromLTRB`, `zero`. Trabalhe em múltiplos de 4.
- Use `Padding` para espaço, `SizedBox` para espaçador e tamanho fixo, `ColoredBox` para cor,
  `Card` para o padrão do tema — e `Container` só quando precisar de **duas ou mais** coisas juntas.
- `SizedBox.shrink()` é o jeito idiomático de dizer "não desenhe nada".

---

## ☑️ Checklist de domínio

- [ ] Listo pelo menos seis parâmetros do `Container` e digo a ordem em que agem.
- [ ] Explico por que `margin` não recebe a cor de fundo.
- [ ] Reproduzo, de propósito, o erro "Cannot provide both a color and a decoration" e o corrijo.
- [ ] Escrevo uma `BoxDecoration` com borda, raio e sombra sem consultar.
- [ ] Digo por que `BorderRadius.all(Radius.circular(20))` pode ser `const` e `circular(20)` não.
- [ ] Justifico, em cada uso do meu código, por que escolhi `Padding`, `SizedBox` ou `Container`.
- [ ] Meu `CartaoDestaque` está em arquivo próprio, com construtor `const`.
- [ ] Sei dizer em uma frase quando prefiro `Card` a `Container`.
- [ ] `flutter analyze` passa sem avisos.

---

## 📚 Referências oficiais

- [API — `Container`](https://api.flutter.dev/flutter/widgets/Container-class.html)
- [API — `BoxDecoration`](https://api.flutter.dev/flutter/painting/BoxDecoration-class.html)
- [API — `EdgeInsets`](https://api.flutter.dev/flutter/painting/EdgeInsets-class.html)
- [API — `Padding`](https://api.flutter.dev/flutter/widgets/Padding-class.html)
- [API — `SizedBox`](https://api.flutter.dev/flutter/widgets/SizedBox-class.html)
- [API — `Card`](https://api.flutter.dev/flutter/material/Card-class.html)
- [API — `BoxShadow`](https://api.flutter.dev/flutter/painting/BoxShadow-class.html)
- [Material 3 — Elevation](https://m3.material.io/styles/elevation/overview)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Texto, tipografia e ícones](02-texto-tipografia-icones.md) | [README](README.md) | [Aula 4 — Row, Column e Expanded](04-row-column-expanded.md) |
