# Aula 6 — Constraints

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Recitar e **aplicar** a regra do layout do Flutter: *constraints descem, tamanhos sobem, o pai
  posiciona*.
- Ler um `BoxConstraints` e dizer se ele é **apertado** (*tight*) ou **frouxo** (*loose*).
- Explicar por que um `Container` sem filho ocupa a tela inteira e com filho encolhe.
- Usar `ConstrainedBox`, `UnconstrainedBox` e `IntrinsicHeight` — e saber o custo de cada um.
- Depurar layout com `debugPrint`, com as linhas de depuração do `flutter run` e com o
  **Flutter Inspector** do DevTools.
- Diagnosticar e corrigir o erro `Vertical viewport was given unbounded height`.

## ✅ Pré-requisitos

- [Aula 4 — Row, Column e Expanded](04-row-column-expanded.md) e
  [Aula 5 — Stack e Positioned](05-stack-e-positioned.md).
- O projeto `foco_ui` com `CartaoDestaque` e `MateriaTile` funcionando.

---

## 📖 Conceito

### A regra que explica todo layout no Flutter

Tudo o que você já viu neste módulo — `Expanded` que estica, `Container` que ocupa tudo, texto que
estoura — decorre de **uma única regra**, repetida em todas as camadas da árvore:

> **1. As *constraints* (restrições) descem.**
> **2. Os tamanhos sobem.**
> **3. O pai decide a posição.**

Em português corrente: o pai diz ao filho **"você pode ter entre tanto e tanto"**; o filho escolhe um
tamanho dentro disso e **responde** com o tamanho escolhido; o pai então **coloca** o filho em algum
lugar do espaço que ele mesmo ocupa.

Três consequências que vale a pena entender agora:

- **Um widget nunca sabe onde ele está.** A posição é decisão do pai, e o filho não tem acesso a ela.
- **Um widget não pode ter o tamanho que quiser.** Ele escolhe *dentro* do que o pai permitiu.
- **Um widget não sabe qual é o tamanho dos irmãos.** Toda comunicação é entre pai e filho.

Por isso não existe, no Flutter, o equivalente a "posicione este elemento 20 pixels acima daquele
outro". Você compõe widgets; não posiciona coordenadas globais.

### O que é um `BoxConstraints`

`BoxConstraints` é o objeto que desce do pai para o filho. Ele tem quatro números:

```dart
BoxConstraints(
  minWidth: 0,
  maxWidth: 412,
  minHeight: 0,
  maxHeight: 803,
)
```

Isso se lê: "você pode ter qualquer largura de 0 a 412 e qualquer altura de 0 a 803".

### Apertado (*tight*) × frouxo (*loose*)

| Tipo | Definição | Exemplo | Efeito |
|---|---|---|---|
| **Apertado** (*tight*) | mínimo **igual** ao máximo | `BoxConstraints.tight(Size(100, 50))` | O filho **é obrigado** a ter exatamente aquele tamanho |
| **Frouxo** (*loose*) | mínimo zero, máximo definido | `BoxConstraints.loose(Size(100, 50))` | O filho pode ser **até** aquele tamanho |
| **Ilimitado** (*unbounded*) | máximo `double.infinity` | dentro de um `ListView`, na vertical | O filho pode ser **de qualquer tamanho** — e precisa se decidir sozinho |

Quem entrega restrições apertadas na sua tela:

- `runApp` entrega ao widget raiz restrições **apertadas** do tamanho da janela.
- `Expanded` entrega restrições **apertadas** ao seu filho (é o que "tight" significa em
  `FlexFit.tight`).
- `SizedBox(width: 48, height: 48)` entrega restrições **apertadas** de 48 × 48.
- `Center`, `Align` e `Padding` entregam restrições **frouxas**: "pode ser até este tamanho".

### Por que um `Container` sem filho ocupa tudo

Agora dá para responder à pergunta que ficou aberta na [Aula 3](03-container-padding-sizedbox.md):

```dart
Container(color: Colors.red)          // ocupa a tela inteira
Container(color: Colors.red, child: const Text('Oi'))  // fica do tamanho do texto
```

A regra do `Container` é: **se não tenho filho nem tamanho definido, fico o maior possível dentro das
restrições recebidas; se tenho filho, fico do tamanho do filho.**

E se o pai for um `Center`? Aí as restrições que chegam já são frouxas, mas o `Container` sem filho
continua escolhendo o máximo. Para forçá-lo a encolher, dê-lhe um tamanho, ou um filho, ou
`constraints`.

### `ConstrainedBox`: apertar ou afrouxar o que desce

`ConstrainedBox` intercepta as restrições e as modifica antes de repassar ao filho:

```dart
ConstrainedBox(
  constraints: const BoxConstraints(
    minHeight: 80,
    maxHeight: 200,
    minWidth: double.infinity,   // ocupe toda a largura disponível
  ),
  child: const Card(child: Text('Altura entre 80 e 200')),
)
```

Atenção a uma armadilha: `ConstrainedBox` só consegue apertar **dentro** do que o pai permitiu. Se o
pai mandou "no máximo 100 pixels de altura" e você pedir `minHeight: 300`, o resultado será 100. As
restrições do pai sempre vencem.

### `UnconstrainedBox`: deixar o filho decidir sozinho

`UnconstrainedBox` remove as restrições: entrega ao filho um espaço **ilimitado** e depois desenha o
tamanho que ele escolheu.

```dart
UnconstrainedBox(
  child: Container(width: 600, height: 40, color: Colors.amber),
)
```

Se o filho escolher um tamanho maior que o espaço real, você verá o aviso de estouro. É uma
ferramenta de casos específicos, não de uso diário — e um sinal, na maioria das vezes, de que o
layout poderia ser resolvido de outra forma.

### `IntrinsicHeight` e `IntrinsicWidth`

Às vezes você quer que dois irmãos de uma `Row` tenham **a mesma altura**, igual à do mais alto —
por exemplo, uma barra colorida à esquerda acompanhando a altura do texto ao lado.

`IntrinsicHeight` faz isso: ele pergunta a cada filho "qual é a sua altura natural?", pega a maior e
impõe a todos.

```dart
IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      const ColoredBox(color: Colors.indigo, child: SizedBox(width: 4)),
      const Expanded(child: Text('Texto de duas ou três linhas...')),
    ],
  ),
)
```

⚠️ **Custo real:** `IntrinsicHeight` faz uma passagem extra de medição em toda a subárvore. A própria
documentação do Flutter o classifica como "relativamente caro". Não use dentro de `ListView.builder`
com centenas de itens. Alternativas: altura fixa, ou `CrossAxisAlignment.stretch` dentro de um pai que
já tenha altura definida.

### O erro da altura infinita

Este é o erro que todo mundo encontra ao tentar colocar uma lista dentro de uma coluna:

```text
════════ Exception caught by rendering library ═════════════════════════════════
Vertical viewport was given unbounded height.
Viewports expand in the scrolling direction to fill their container. In this case,
a vertical viewport was given an unlimited amount of vertical space in which to
expand. This situation typically happens when a scrollable widget is nested inside
another scrollable widget.
```

**O que acontece, em termos da regra:** um `ListView` é um *viewport* (janela de rolagem). Ele diz:
"me dê uma altura, e eu rolo o conteúdo dentro dela". Mas uma `Column` diz ao filho: "você pode ter a
altura que quiser". Um pede altura definida, o outro oferece infinito — impasse, exceção.

**As três correções, e quando usar cada uma:**

| Correção | Código | Quando usar |
|---|---|---|
| Dar altura elástica | `Expanded(child: ListView(...))` | A lista deve ocupar o espaço que sobrou. **É o caso comum** |
| Dar altura fixa | `SizedBox(height: 240, child: ListView(...))` | Carrossel, seção de altura conhecida |
| Tirar a rolagem | `ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), ...)` | Lista **curta** dentro de outra área rolável |

⚠️ Sobre `shrinkWrap: true`: ele manda o `ListView` medir **todos** os filhos de uma vez para saber a
altura total — exatamente o oposto da otimização que o `ListView.builder` oferece. Em lista curta e
fixa, tudo bem. Em lista de 500 itens, é um problema de desempenho real.

---

## 💡 Analogia

Pense em **alugar uma sala comercial**.

- O prédio (o pai) diz: "tenho salas de 20 a 60 m². Escolha." Isso é o `BoxConstraints` descendo.
- Você (o filho) responde: "vou querer 45 m²". Isso é o **tamanho subindo**.
- O prédio decide em qual andar e em qual canto do corredor fica a sua sala. Isso é **o pai
  posicionando**.

`BoxConstraints.tight` é o prédio que só tem salas de 45 m²: você não escolhe.
`unbounded` é um terreno aberto sem limites — e é por isso que o `ListView` reclama: ele precisa saber
onde termina a "sala" para saber quanto conteúdo cabe visível.

Onde a analogia quebra: no Flutter esse diálogo acontece de novo, inteiro, a cada quadro de animação
e a cada `setState`. É rápido justamente porque é simples: uma pergunta, uma resposta, sem
negociação.

---

## 🧪 Exemplo mínimo

Este exemplo **imprime** as restrições que cada nível recebe. É a forma mais direta de ver a regra
funcionando:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ExemploConstraints()));

class ExemploConstraints extends StatelessWidget {
  const ExemploConstraints({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Constraints')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints restricoes) {
          debugPrint('body recebeu: $restricoes');
          return Center(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints internas) {
                debugPrint('dentro do Center: $internas');
                return SizedBox(
                  width: 200,
                  height: 100,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints finais) {
                      debugPrint('dentro do SizedBox: $finais');
                      return const ColoredBox(color: Colors.indigo);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

Saída típica no console (os números variam com a sua janela):

```text
body recebeu: BoxConstraints(w=800.0, h=544.0)
dentro do Center: BoxConstraints(0.0<=w<=800.0, 0.0<=h<=544.0)
dentro do SizedBox: BoxConstraints(w=200.0, h=100.0)
```

Leia com atenção: o `body` recebeu restrições **apertadas** (`w=800.0` significa mínimo = máximo). O
`Center` **afrouxou** (`0.0<=w<=800.0`). O `SizedBox` **apertou de novo** em 200 × 100. Está tudo
ali: descem, mudam de forma, e o filho responde.

---

## 📱 Aplicando no Flutter

Hoje o `body` da `HomeScreen` é um `ListView` único, com o cartão e os itens rolando juntos. Vamos
mudar para um layout mais realista: **o cartão de destaque fica fixo no topo** e **só a lista de
matérias rola**.

Essa mudança parece trivial e é exatamente onde o erro de altura infinita aparece. Vamos provocá-lo de
propósito antes de corrigi-lo — ler o erro uma vez com calma vale mais que decorar a solução.

**Passo 1 — provoque.** Troque o `body` por:

```dart
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            const CartaoDestaque(
              minutosHoje: 120,
              metaMinutos: 180,
              materiaAtual: 'Introdução à Álgebra Linear com Aplicações',
            ),
            ListView(                                   // ❌ vai explodir
              children: <Widget>[
                for (final Materia materia in _materias)
                  MateriaTile(materia: materia),
              ],
            ),
          ],
        ),
      ),
```

Salve. Você recebe, na tela vermelha e no console:

```text
Vertical viewport was given unbounded height.
```

**Passo 2 — corrija.** Envolva o `ListView` em `Expanded`. O código completo abaixo já está corrigido.

---

## 💻 Código completo

> **Arquivo:** `lib/features/materias/presentation/home_screen.dart`
> **Como executar:** `flutter run -d windows`

Substitua o `body:` por:

```dart
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            // Parte fixa: não rola.
            const CartaoDestaque(
              minutosHoje: 120,
              metaMinutos: 180,
              materiaAtual: 'Introdução à Álgebra Linear com Aplicações',
            ),

            // Cabeçalho da seção, também fixo.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: <Widget>[
                  Text(
                    'Suas matérias',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  Text(
                    '${_materias.length} no total',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),

            // Parte elástica: recebe todo o espaço que sobrou e rola dentro dele.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: <Widget>[
                  for (final Materia materia in _materias)
                    MateriaTile(materia: materia),
                ],
              ),
            ),
          ],
        ),
      ),
```

Rode:

```powershell
flutter run -d windows
```

Diminua a altura da janela até a lista não caber mais. Observe: o cartão continua no lugar, e apenas
a lista rola. Esse é o comportamento que você esperava desde o começo.

---

## 🔍 Explicando o código

**`Column` no lugar de `ListView` na raiz do `body`** — a `Column` recebe restrições apertadas de
altura (o `Scaffold` diz exatamente quanta altura existe) e pode, por isso, repassar altura definida
aos filhos.

**`Expanded(child: ListView(...))`** — aqui está a solução do erro, e ela é exatamente a regra da
aula: `Expanded` pega a altura que sobrou depois do cartão e do cabeçalho e a entrega ao `ListView`
como restrição **apertada**. O `ListView` agora sabe onde termina a janela dele.

**Por que `Expanded` e não `SizedBox(height: 400)`** — a altura que sobra depende do aparelho, da
orientação e do tamanho da fonte do sistema. Qualquer número fixo estaria errado em algum aparelho.

**`padding: EdgeInsets.only(bottom: 96)` dentro do `ListView`** — o espaço para o
`FloatingActionButton` não cobrir o último item. Repare que agora ele está no `ListView` e não na
`Column`: o `padding` precisa rolar junto com a lista.

**`Spacer()` no cabeçalho da seção** — empurra o contador para a direita. Poderia ser
`mainAxisAlignment: MainAxisAlignment.spaceBetween`; escolhi `Spacer` para praticar a
[Aula 4](04-row-column-expanded.md).

**`_materias.length`** — a contagem vem da lista, não de um número escrito à mão. Parece detalhe, mas
é a diferença entre um número que continua certo quando os dados mudam e um que mente em silêncio.

---

## 🔧 Depurando layout de verdade

Três ferramentas, da mais simples à mais poderosa.

### 1. `LayoutBuilder` + `debugPrint`

Já usado no exemplo mínimo. É o "print de depuração" do layout: envolva o widget suspeito em
`LayoutBuilder` e imprima o que chega.

```dart
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints restricoes) {
    debugPrint('MateriaTile recebeu: $restricoes');
    return const MateriaTile(...);
  },
)
```

> Use `debugPrint`, não `print`. O lint `avoid_print` do `flutter_lints 6.0.0` acusa `print` em código
> Flutter, e o `debugPrint` ainda evita que mensagens longas sejam truncadas pelo sistema.

### 2. Linhas de depuração no `flutter run`

Com o app rodando por `flutter run`, o terminal aceita teclas:

| Tecla | Efeito |
|---|---|
| `p` | Liga/desliga as **linhas de construção**: desenha a borda de cada caixa do layout |
| `o` | Alterna entre o visual 🤖 Android e 🍎 iOS |
| `r` | *Hot reload* |
| `R` | *Hot restart* |
| `q` | Encerra |

Apertar `p` e olhar a tela responde na hora perguntas do tipo "esse `Padding` está aí mesmo?" e
"quem está ocupando esse espaço vazio?".

### 3. Flutter Inspector (DevTools)

O **DevTools** é o conjunto de ferramentas de depuração do Flutter, que abre no navegador. Com o app
rodando:

**🪟 Windows (PowerShell)**
```powershell
flutter run -d windows
```

No terminal aparece uma linha como:

```text
The Flutter DevTools debugger and profiler on Windows is available at:
http://127.0.0.1:9101?uri=http://127.0.0.1:60123/AbCdEf=/
```

Abra esse endereço no Chrome. No VS Code, a alternativa é a paleta de comandos
(`Ctrl` + `Shift` + `P`) → **Flutter: Open DevTools**.

O que usar dentro do Inspector:

- **Árvore de widgets** à esquerda: clique em qualquer widget para selecioná-lo.
- **Select Widget Mode**: clique no ícone de mira e depois **no próprio app** — o Inspector salta
  para o widget correspondente. É a forma mais rápida de achar quem causou um espaço estranho.
- **Layout Explorer**: mostra, em diagrama, as restrições recebidas, o tamanho escolhido e os valores
  de `flex` de cada filho de uma `Row`/`Column`. É a materialização visual desta aula inteira.

O DevTools completo é o assunto de [12 — DevTools](../12-testes-e-debug/03-devtools.md).

---

## ⚠️ Erros comuns

**1. `Vertical viewport was given unbounded height`** — `ListView` dentro de `Column` ou de
`SingleChildScrollView` sem altura. Corrija com `Expanded`, `SizedBox` ou `shrinkWrap`.

**2. `RenderBox was not laid out: RenderFlex#... NEEDS-LAYOUT`**

```text
RenderBox was not laid out: RenderFlex#1a2b3 relayoutBoundary=up2 NEEDS-LAYOUT
'package:flutter/src/rendering/box.dart': Failed assertion: line 1965 pos 12: 'hasSize'
```

Este erro é quase sempre **consequência** de outro, mais acima no console. Role a saída para cima e
corrija o **primeiro** erro; este costuma desaparecer junto.

**3. `BoxConstraints forces an infinite height`**

```text
BoxConstraints forces an infinite height.
The offending constraints were: BoxConstraints(w=411.4, h=Infinity)
```

Alguém pediu `height: double.infinity` num lugar que não tem altura definida. Troque por `Expanded`.

**4. `Expanded` dentro de `SingleChildScrollView`**

```text
RenderFlex children have non-zero flex but incoming height constraints are unbounded.
```

Dentro da rolagem a altura é infinita, e "uma fração do infinito" não existe. Ou tire a rolagem, ou
troque `Expanded` por altura fixa.

**5. Esperar que `ConstrainedBox` aumente além do que o pai deu**

`ConstrainedBox(constraints: BoxConstraints(minWidth: 500))` dentro de um pai de 300 pixels resulta em
300. As restrições do pai sempre vencem. Se você precisa de 500, quem tem de mudar é o pai.

**6. `IntrinsicHeight` dentro de `ListView.builder`**

Não gera erro, gera **lentidão**: cada item passa por uma medição extra. Em listas longas, a rolagem
engasga. Meça antes de otimizar, mas saiba onde procurar.

---

## 🛠️ Exercício guiado

Vamos usar o Layout Explorer para responder a uma pergunta concreta: **quanto espaço o `Expanded` do
`MateriaTile` está realmente recebendo?**

**Passo 1.** Rode o app com `flutter run -d windows` e abra o DevTools pelo endereço que aparece no
terminal.

**Passo 2.** Clique no ícone de **Select Widget Mode** (a mira) e depois clique, dentro do app, no
**nome de uma matéria**.

**Passo 3.** Na árvore da esquerda, suba até encontrar a `Row` do `MateriaTile` e selecione-a. Abra a
aba **Layout Explorer**.

**Passo 4.** Leia o diagrama. Você vai ver:

- a largura total da `Row`;
- cada filho com sua largura;
- o `Expanded` marcado com `flex: 1` e a largura resultante;
- as restrições (`constraints`) que chegaram à `Row`.

**Passo 5.** Ainda no Layout Explorer, mude o `flex` do `Expanded` **pela interface** (o Explorer
permite alterar `flex` e `mainAxisAlignment` ao vivo) e veja o app mudar na hora, sem recompilar.

**Passo 6.** Agora estreite a janela do app para uns 320 pixels e repita a leitura. Anote quanto o
`Expanded` recebeu antes e depois.

**O que observar:** o ícone e o bloco de minutos mantêm a mesma largura; **toda** a diferença sai do
`Expanded`. É exatamente o que a regra prevê: o pai distribuiu, o filho elástico absorveu, os fixos
responderam o mesmo tamanho de sempre.

**Resultado esperado:** você consegue dizer, em números, quantos pixels o nome da matéria tem em cada
largura de janela — e por isso sabe, sem adivinhar, quando o `ellipsis` vai entrar em ação.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Priorize os de **Leitura de código**: eles dão um trecho e pedem que você preveja o tamanho final
antes de rodar. É o melhor treino possível para esta aula.

---

## 🏆 Desafio opcional

Construa um widget de diagnóstico chamado `MostraConstraints`:

1. Ele recebe um `child` e o envolve em um `LayoutBuilder`.
2. Desenha, sobre o filho (use `Stack` da [Aula 5](05-stack-e-positioned.md)), uma etiqueta pequena
   com as restrições recebidas formatadas, por exemplo `0≤w≤380 · 0≤h≤∞`.
3. A etiqueta fica em `IgnorePointer`, para não atrapalhar toques.
4. Só desenha a etiqueta quando `kDebugMode` for verdadeiro (importe
   `package:flutter/foundation.dart`).
5. Use-o para envolver o `CartaoDestaque` e o `MateriaTile` e registre no seu caderno quais
   restrições cada um recebe.

Critério de sucesso: em modo release (`flutter run --release`) a etiqueta não aparece, e o app roda
igual.

---

## 📌 Resumo

- A regra, em três partes: **constraints descem, tamanhos sobem, o pai posiciona.**
- Um widget não sabe onde está, não escolhe tamanho fora das restrições e não enxerga os irmãos.
- `BoxConstraints` = `minWidth`, `maxWidth`, `minHeight`, `maxHeight`.
  **Apertado** = mínimo igual ao máximo. **Frouxo** = mínimo zero. **Ilimitado** = máximo infinito.
- `Container` sem filho e sem tamanho fica o maior possível; com filho, fica do tamanho do filho.
- `ConstrainedBox` aperta ou afrouxa o que desce, **mas nunca ultrapassa** o que o pai permitiu.
  `UnconstrainedBox` entrega espaço ilimitado ao filho. `IntrinsicHeight` iguala alturas e é caro.
- `Vertical viewport was given unbounded height` = rolagem dentro de altura infinita.
  Corrija com `Expanded` (comum), `SizedBox` (altura conhecida) ou `shrinkWrap` (lista curta).
- Ferramentas de depuração: `LayoutBuilder` + `debugPrint`, tecla `p` no `flutter run`, e o
  **Layout Explorer** do Flutter Inspector.

---

## ☑️ Checklist de domínio

- [ ] Recito a regra do layout sem consultar e explico cada uma das três partes.
- [ ] Leio um `BoxConstraints` impresso e digo se é apertado, frouxo ou ilimitado.
- [ ] Explico por que `Container(color: Colors.red)` ocupa a tela toda.
- [ ] Sei quem entrega restrições apertadas: `runApp`, `Expanded`, `SizedBox`.
- [ ] Provoquei `Vertical viewport was given unbounded height` e corrigi das três formas.
- [ ] Sei o custo de `shrinkWrap: true` e de `IntrinsicHeight`.
- [ ] Abri o Flutter Inspector, usei o Select Widget Mode e li o Layout Explorer.
- [ ] Apertei `p` no terminal do `flutter run` e entendi o que as linhas mostram.
- [ ] A `HomeScreen` tem cartão fixo no topo e lista rolando abaixo, sem nenhum erro.

---

## 📚 Referências oficiais

- [Flutter — Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)
- [API — `BoxConstraints`](https://api.flutter.dev/flutter/rendering/BoxConstraints-class.html)
- [API — `ConstrainedBox`](https://api.flutter.dev/flutter/widgets/ConstrainedBox-class.html)
- [API — `UnconstrainedBox`](https://api.flutter.dev/flutter/widgets/UnconstrainedBox-class.html)
- [API — `IntrinsicHeight`](https://api.flutter.dev/flutter/widgets/IntrinsicHeight-class.html)
- [API — `LayoutBuilder`](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)
- [DevTools — Flutter Inspector](https://docs.flutter.dev/tools/devtools/inspector)
- [Flutter — Erros comuns](https://docs.flutter.dev/testing/common-errors)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Stack e Positioned](05-stack-e-positioned.md) | [README](README.md) | [Aula 7 — Cores, temas e modo escuro](07-cores-temas-modo-escuro.md) |
