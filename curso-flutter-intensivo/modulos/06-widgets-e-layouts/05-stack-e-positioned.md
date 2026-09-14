# Aula 5 — Stack e Positioned

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Sobrepor widgets com `Stack` e explicar a **ordem de pintura**.
- Posicionar um filho por coordenadas com `Positioned` e `Positioned.fill`.
- Usar `Align` e o sistema de coordenadas de `Alignment` (de `-1` a `1`).
- Controlar o tamanho do `Stack` com `fit` (`StackFit.loose`, `expand`, `passthrough`).
- Decidir entre `clipBehavior: Clip.hardEdge` e `Clip.none` e saber o que cada um corta.
- Deixar um widget "invisível ao toque" com `IgnorePointer` (e a diferença para `AbsorbPointer`).
- Implementar três casos reais: **selo de notificação**, **gradiente sobre imagem** e **botão
  sobreposto**.

## ✅ Pré-requisitos

- [Aula 4 — Row, Column e Expanded](04-row-column-expanded.md), com o `MateriaTile` funcionando.
- [Aula 3 — Container, Padding e SizedBox](03-container-padding-sizedbox.md) (`BoxDecoration`,
  `gradient`).

---

## 📖 Conceito

### O que é `Stack`

`Row` enfileira na horizontal. `Column` enfileira na vertical. **`Stack` empilha na profundidade** —
um widget por cima do outro, como folhas de papel numa mesa.

```dart
Stack(
  children: <Widget>[
    Container(color: Colors.indigo, width: 200, height: 120), // fundo
    const Text('Em cima'),                                     // frente
  ],
)
```

### Ordem de pintura: o primeiro é o de baixo

A regra é literal e não tem exceção:

> **O primeiro filho da lista é pintado primeiro, portanto fica embaixo. O último é pintado por
> último, portanto fica na frente.**

Isso é o oposto do que muita gente supõe. Se o seu selo sumiu, quase sempre é porque ele está antes
do widget que o cobriu na lista de `children`.

### Filhos posicionados e não posicionados

O `Stack` trata seus filhos de duas formas diferentes:

**Filho não posicionado** (um widget comum): fica **alinhado** conforme o parâmetro `alignment` do
`Stack` (padrão: `AlignmentDirectional.topStart`, ou seja, canto superior esquerdo em português).

**Filho posicionado** (envolvido em `Positioned`): fica exatamente onde as coordenadas mandarem.

```dart
Stack(
  alignment: Alignment.center,     // vale para os NÃO posicionados
  children: <Widget>[
    const FlutterLogo(size: 120),  // não posicionado → centro
    Positioned(                    // posicionado → canto
      top: 4,
      right: 4,
      child: const Icon(Icons.close),
    ),
  ],
)
```

E o tamanho do `Stack`? Ele é definido pelos filhos **não posicionados** — o maior deles. Filhos
posicionados **não contam** para o tamanho. Consequência importante: um `Stack` que só tem filhos
posicionados fica do tamanho mínimo possível (ou do tamanho máximo, dependendo do `fit`), e
normalmente não é o que você queria.

### `Positioned`: as seis medidas

```dart
Positioned(
  left: 8,      // distância da borda esquerda do Stack
  top: 8,       // distância do topo
  right: 8,     // distância da direita
  bottom: 8,    // distância da base
  width: 40,    // largura fixa
  height: 40,   // altura fixa
  child: ...,
)
```

Regra que evita a maioria dos erros: **você pode informar no máximo dois valores por eixo.**
No eixo horizontal, escolha dois entre `left`, `right` e `width`. No vertical, dois entre `top`,
`bottom` e `height`. Informar os três lança exceção.

Atalhos úteis:

```dart
Positioned.fill(child: ...)                    // left/top/right/bottom = 0
Positioned.fill(top: null, child: ...)          // preenche, exceto o topo
PositionedDirectional(start: 8, child: ...)     // respeita idiomas da direita para a esquerda
```

### `Align` e o sistema de coordenadas de `Alignment`

`Align` coloca um único filho em uma posição relativa dentro do espaço disponível:

```dart
Align(
  alignment: Alignment.bottomRight,
  child: const Icon(Icons.edit),
)
```

`Alignment` usa um sistema de coordenadas onde o **centro é `(0, 0)`**, a esquerda/topo é `-1` e a
direita/base é `1`:

```text
(-1,-1) ───── (0,-1) ───── (1,-1)      topLeft    topCenter    topRight
   │             │             │
(-1, 0) ───── (0, 0) ───── (1, 0)      centerLeft   center    centerRight
   │             │             │
(-1, 1) ───── (0, 1) ───── (1, 1)      bottomLeft bottomCenter bottomRight
```

Você pode usar valores intermediários, inclusive fora do intervalo:

```dart
const Alignment(0.6, -0.8)   // um pouco à direita, bem no alto
const Alignment(1.4, 0)      // FORA da caixa, à direita
```

Constantes prontas: `Alignment.topLeft`, `topCenter`, `topRight`, `centerLeft`, `center`,
`centerRight`, `bottomLeft`, `bottomCenter`, `bottomRight`.

Dentro de um `Stack`, `Align` é uma alternativa a `Positioned` quando você quer uma posição
**relativa** (canto inferior direito, sempre) em vez de **absoluta** (8 pixels da borda).

### `fit`: quanto espaço o `Stack` oferece aos filhos

| Valor | Efeito |
|---|---|
| `StackFit.loose` (padrão) | Os filhos não posicionados podem ter o tamanho que quiserem, até o máximo |
| `StackFit.expand` | Os filhos não posicionados são **forçados** a ocupar todo o espaço |
| `StackFit.passthrough` | Repassa as restrições recebidas do pai, sem alterar |

`StackFit.expand` é o que você usa quando quer uma imagem de fundo cobrindo o `Stack` inteiro.

### `clipBehavior`: o que escapa é cortado?

O padrão do `Stack` é `Clip.hardEdge`: **tudo que ultrapassar os limites do `Stack` é cortado**.

Isso é ótimo para imagens e péssimo para selos. Um selo de notificação normalmente fica *meio para
fora* do canto do ícone — e some, cortado. A solução:

```dart
Stack(
  clipBehavior: Clip.none,   // deixa vazar
  children: <Widget>[...],
)
```

⚠️ Com `Clip.none`, a parte que vaza **é desenhada, mas continua fora da área de toque do `Stack`**.
Toques naquela região podem não chegar ao widget. Para selos (que são decorativos) isso não importa;
para botões, importa muito.

### `IgnorePointer` e `AbsorbPointer`

Quando você sobrepõe um widget a outro, o de cima intercepta os toques — mesmo sendo apenas um
gradiente decorativo. Dois widgets resolvem isso, de formas diferentes:

| Widget | O que faz com o toque |
|---|---|
| `IgnorePointer` | **Deixa passar** para quem está embaixo. O widget vira "vidro" |
| `AbsorbPointer` | **Engole** o toque. Nem ele nem quem está embaixo recebem |

```dart
IgnorePointer(
  child: Container(decoration: const BoxDecoration(gradient: ...)),
)
```

Use `IgnorePointer` em camadas decorativas. Use `AbsorbPointer` para bloquear a tela inteira enquanto
algo carrega — o que você reencontra na [Aula 12](12-estados-de-ui.md).

---

## 💡 Analogia

Pense em **transparências de retroprojetor** empilhadas.

- Cada `child` é uma folha transparente. Você vê todas ao mesmo tempo, com a de cima escondendo o que
  estiver exatamente atrás dela.
- A ordem da pilha importa: a primeira folha que você coloca fica no fundo.
- `Positioned` é você marcando na folha "desenhe isto a 8 cm da borda direita".
- `clipBehavior: Clip.hardEdge` é a moldura do retroprojetor: o que passa da borda simplesmente não
  é projetado.
- `IgnorePointer` é uma folha de vidro: você vê, mas a mão passa por ela e toca a folha de baixo.

---

## 🧪 Exemplo mínimo

O selo de notificação, em 20 linhas:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ExemploSelo()));

class ExemploSelo extends StatelessWidget {
  const ExemploSelo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            const Icon(Icons.notifications_outlined, size: 40),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Troque `Clip.none` por `Clip.hardEdge` e rode de novo: o selo é cortado. Esse é o experimento que
fixa o conceito.

---

## 📱 Aplicando no Flutter

Vamos aplicar `Stack` em dois pontos do Foco:

1. **`CartaoDestaque`** ganha um fundo com gradiente e um ícone decorativo grande no canto,
   parcialmente cortado — o visual de cartão de destaque que você vê em apps reais.
2. **`MateriaTile`** ganha um **selo de "meta batida"** no canto do ícone circular, que só aparece
   quando o progresso chega a 100 %.

Nenhum arquivo novo: você edita os dois widgets que já existem.

---

## 💻 Código completo

> **Arquivo:** `lib/features/materias/presentation/widgets/cartao_destaque.dart`
> **Como executar:** `flutter run -d windows`

Substitua o `build` inteiro pelo código abaixo (o cabeçalho da classe e os campos continuam iguais):

```dart
  @override
  Widget build(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;
    final ColorScheme cores = Theme.of(context).colorScheme;
    final int restante = (metaMinutos - minutosHoje).clamp(0, metaMinutos);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          colors: <Color>[cores.primaryContainer, cores.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Camada 1 (fundo): ícone gigante, decorativo, cortado pela borda.
          Positioned(
            right: -24,
            bottom: -24,
            child: IgnorePointer(
              child: Icon(
                Icons.timer_outlined,
                size: 160,
                color: cores.onPrimaryContainer.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Camada 2 (frente): o conteúdo do cartão.
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Bom estudo!',
                  style: tipografia.titleMedium?.copyWith(
                    color: cores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$minutosHoje min',
                  style: tipografia.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cores.onPrimaryContainer,
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
                      TextSpan(
                        text: restante == 0 ? '.' : ' para bater a meta.',
                      ),
                    ],
                  ),
                  style: tipografia.bodyMedium?.copyWith(
                    color: cores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Matéria em andamento',
                  style: tipografia.labelLarge?.copyWith(
                    color: cores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.menu_book_outlined,
                      size: 20,
                      color: cores.onPrimaryContainer,
                      semanticLabel: 'Matéria',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        materiaAtual,
                        style: tipografia.bodyLarge?.copyWith(
                          color: cores.onPrimaryContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
```

> **Arquivo:** `lib/features/materias/presentation/widgets/materia_tile.dart`
> **Como executar:** `flutter run -d windows`

Troque **apenas** o bloco do ícone circular (a "parte fixa 1") por:

```dart
          // 1. Parte fixa: ícone circular com selo de meta batida.
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
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
              if (materia.progresso >= 1.0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: cores.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: cores.tertiary,
                      semanticLabel: 'Meta concluída',
                    ),
                  ),
                ),
            ],
          ),
```

Rode:

```powershell
flutter run -d windows
```

A matéria "Inglês técnico" (240 min de meta 120) deve exibir o selo verde de concluída. As outras
duas, não.

---

## 🔍 Explicando o código

**`clipBehavior: Clip.antiAlias` no `Container` externo do cartão** — sem isso, o ícone gigante do
fundo escaparia dos cantos arredondados e apareceria por fora, quadrado. `antiAlias` corta com borda
suavizada; é o corte de melhor qualidade (e um pouco mais caro que `hardEdge`).

**`Positioned(right: -24, bottom: -24, ...)`** — valores **negativos** empurram o widget para fora do
`Stack`. Combinado com o corte do `Container` pai, produz o efeito de ícone "espiando" pela borda.

**`IgnorePointer` em volta do ícone decorativo** — sem ele, esse ícone de 160 pixels roubaria os
toques de um terço do cartão. Como ele é puramente visual, deve ser transparente ao toque.

**`.withValues(alpha: 0.08)`** — cria a mesma cor com 8 % de opacidade. Repare que **não** usamos
`withOpacity`, que está depreciado: `withValues` trabalha com maior precisão de cor. Não é `const`
porque é uma chamada de método.

**`cores.onPrimaryContainer` em todos os textos** — o cartão agora tem fundo colorido, então o texto
precisa da cor "sobre esse fundo". Esse pareamento `primaryContainer` ↔ `onPrimaryContainer` é o
mecanismo de contraste do Material 3, detalhado na [Aula 7](07-cores-temas-modo-escuro.md).

**`Stack` do `MateriaTile` sem `alignment`** — o filho não posicionado (o círculo) fica no canto
superior esquerdo, que aqui é irrelevante porque ele é o único e define o tamanho do `Stack`.

**`if (materia.progresso >= 1.0)` dentro da lista de `children`** — é o *collection-if* do Dart: o
widget só entra na lista se a condição for verdadeira. Sem ele, você precisaria de um operador
ternário devolvendo `SizedBox.shrink()`.

**O `Container` branco de 2 pixels em volta do `check_circle`** — dá ao selo uma "borda" da cor do
fundo, separando-o visualmente do círculo colorido. É um truque padrão de selo em aplicativos.

**`clipBehavior: Clip.none` no `Stack` do tile** — sem isso, o selo, que está em `-2, -2`, seria
cortado e você veria só um pedaço dele.

---

## ⚠️ Erros comuns

**1. O widget de cima não aparece**

Ele está na posição errada da lista. Lembre: **último = na frente**. Mova-o para o fim de `children`.

**2. `Positioned` fora de um `Stack`**

```text
Incorrect use of ParentDataWidget.
```

Mesma família de erro do `Expanded` fora da `Row` ([Aula 4](04-row-column-expanded.md)). `Positioned`
só funciona como filho direto de `Stack`.

**3. Informar `left`, `right` **e** `width` juntos**

```text
'package:flutter/src/rendering/stack.dart': Failed assertion:
Horizontally positioned children must have at most two of left, right, and width.
```

Escolha dois por eixo.

**4. O selo some**

`clipBehavior` do `Stack` está no padrão (`Clip.hardEdge`) e o selo tem coordenada negativa. Coloque
`clipBehavior: Clip.none`.

**5. `Stack` ocupando a tela inteira sem querer**

Se todos os filhos forem `Positioned`, não há filho não posicionado para definir o tamanho, e o
`Stack` vira o maior possível. Solução: deixe **um** filho não posicionado (a imagem ou o conteúdo
principal) e posicione os demais.

**6. O botão sobreposto não responde ao toque**

Duas causas: ou existe uma camada decorativa por cima interceptando (falta `IgnorePointer` nela), ou o
botão está com coordenada negativa e a parte clicável ficou fora do `Stack`. No segundo caso,
reposicione: com `Clip.none`, o que vaza é **desenhado**, mas não é **tocável**.

---

## 🛠️ Exercício guiado

Vamos montar o terceiro caso real: **gradiente escuro sobre uma faixa colorida, com texto legível por
cima e um botão sobreposto**. É a base do cabeçalho com imagem que a
[Aula 8](08-imagens-e-assets.md) vai completar com uma foto de verdade.

**Passo 1.** No fim da lista de `children` do `ListView` da `HomeScreen`, adicione:

```dart
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: Stack(
                  children: <Widget>[
                    // Camada 1: a "imagem" (por enquanto, uma cor sólida).
                    Container(height: 160, color: Colors.indigo),

                    // Camada 2: gradiente para o texto ficar legível.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Camada 3: o texto.
                    const Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Text(
                        'Trilha da semana: Álgebra Linear',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Camada 4: botão sobreposto.
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton.filledTonal(
                        tooltip: 'Salvar trilha',
                        icon: const Icon(Icons.bookmark_outline),
                        onPressed: () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(content: Text('Trilha salva')),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
```

**Passo 2.** Rode e toque no botão de marcador.

**O que observar:**

- A **camada 1 é a única não posicionada** — é ela que define a altura de 160 pixels do `Stack`.
  Apague o `height: 160` e veja o `Stack` colapsar.
- O gradiente vai de transparente (em cima) para preto 65 % (embaixo). Esse é o padrão universal para
  colocar texto branco sobre imagem: sem ele, o texto some em fotos claras.
- Sem o `IgnorePointer` da camada 2, o botão da camada 4 **continuaria** funcionando (ele está por
  cima), mas um toque no meio da faixa seria engolido pelo gradiente. Comente o `IgnorePointer` e
  perceba que nada visualmente muda — por isso esse erro passa despercebido em revisões.

**Resultado esperado:** faixa azul com texto branco legível na base, botão arredondado no canto
superior direito que mostra "Trilha salva".

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Faça os exercícios de **Aplicação** sobre sobreposição e o de **Leitura de código** com um `Stack` de
quatro camadas para você prever o resultado antes de rodar.

---

## 🏆 Desafio opcional

Implemente um **avatar com indicador de status** reutilizável:

1. Um `Stack` com um `CircleAvatar` de 48 pixels e um pontinho de 14 pixels no canto inferior direito.
2. O pontinho muda de cor: verde se `estudandoAgora == true`, cinza caso contrário.
3. O pontinho tem borda de 2 pixels na cor do fundo da tela.
4. O conjunto inteiro tem `semanticsLabel` dizendo o nome e o status ("Álgebra, estudando agora").
   Dica: envolva o `Stack` em um widget `Semantics(label: ..., child: ...)`.
5. Use `Align(alignment: Alignment.bottomRight)` em vez de `Positioned` e compare: qual dos dois
   mantém o pontinho no lugar certo se o avatar mudar de 48 para 64 pixels?

Critério de sucesso: mudar o tamanho do avatar não exige recalcular nenhuma coordenada.

---

## 📌 Resumo

- `Stack` empilha na profundidade. **O primeiro filho fica embaixo; o último, na frente.**
- Filhos **não posicionados** seguem o `alignment` do `Stack` e **definem o tamanho dele**.
  Filhos `Positioned` não contam para o tamanho.
- `Positioned` aceita no máximo **dois valores por eixo**: (`left`, `right`, `width`) e
  (`top`, `bottom`, `height`). `Positioned.fill` preenche tudo.
- `Alignment` vai de `-1` (esquerda/topo) a `1` (direita/base), com `0` no centro. `Align` é a opção
  relativa; `Positioned`, a absoluta.
- `fit`: `loose` (padrão), `expand` (força os filhos a ocupar tudo), `passthrough`.
- `clipBehavior` do `Stack` é `Clip.hardEdge` por padrão — coloque `Clip.none` para selos que vazam.
  O que vaza é desenhado, mas **não** recebe toque.
- `IgnorePointer` deixa o toque passar; `AbsorbPointer` engole o toque. Camadas decorativas sempre
  em `IgnorePointer`.
- Gradiente de transparente para preto é o padrão para texto legível sobre imagem.

---

## ☑️ Checklist de domínio

- [ ] Digo qual filho de um `Stack` fica na frente sem precisar testar.
- [ ] Explico quem define o tamanho de um `Stack`.
- [ ] Escrevo um `Positioned` sem cair no erro dos três valores no mesmo eixo.
- [ ] Desenho de cabeça o sistema de coordenadas de `Alignment`.
- [ ] Sei quando preciso de `clipBehavior: Clip.none` — e sei o preço dele.
- [ ] Uso `IgnorePointer` em toda camada decorativa sobreposta.
- [ ] Meu `MateriaTile` mostra o selo de meta concluída só quando o progresso chega a 100 %.
- [ ] Meu `CartaoDestaque` tem gradiente, ícone de fundo cortado e texto com contraste adequado.
- [ ] `flutter analyze` passa sem avisos.

---

## 📚 Referências oficiais

- [API — `Stack`](https://api.flutter.dev/flutter/widgets/Stack-class.html)
- [API — `Positioned`](https://api.flutter.dev/flutter/widgets/Positioned-class.html)
- [API — `Align`](https://api.flutter.dev/flutter/widgets/Align-class.html)
- [API — `Alignment`](https://api.flutter.dev/flutter/painting/Alignment-class.html)
- [API — `IgnorePointer`](https://api.flutter.dev/flutter/widgets/IgnorePointer-class.html)
- [API — `AbsorbPointer`](https://api.flutter.dev/flutter/widgets/AbsorbPointer-class.html)
- [API — `LinearGradient`](https://api.flutter.dev/flutter/painting/LinearGradient-class.html)
- [API — `Color.withValues`](https://api.flutter.dev/flutter/dart-ui/Color/withValues.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Row, Column e Expanded](04-row-column-expanded.md) | [README](README.md) | [Aula 6 — Constraints](06-constraints.md) |
