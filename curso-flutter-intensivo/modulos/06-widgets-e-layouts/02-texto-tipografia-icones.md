# Aula 2 — Texto, tipografia e ícones

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Exibir texto com `Text` e personalizá-lo com `TextStyle` (tamanho, peso, cor, espaçamento, altura).
- Usar os **13 estilos do `textTheme`** do Material 3, de `displayLarge` a `labelSmall`, e escolher o
  certo para cada situação — em vez de chutar `fontSize`.
- Impedir que um texto longo quebre o layout, com `maxLines` e `overflow`.
- Misturar estilos dentro de **uma mesma frase** com `Text.rich` e `TextSpan`.
- Colocar ícones com `Icon` e `Icons`, controlando `size` e `color`.
- Tornar texto e ícones legíveis por **leitores de tela** com `semanticsLabel` e `semanticLabel`.
- Entender a **escala de fonte do sistema** (`TextScaler`) e por que ela quebra layouts mal feitos.

## ✅ Pré-requisitos

- [Aula 1 — Scaffold e AppBar](01-scaffold-e-appbar.md), com o projeto `foco_ui` rodando.
- Interpolação de string em Dart (`'${variavel}'`) —
  [02 — Tipos, strings e conversões](../02-dart-basico/04-tipos-strings-conversoes.md).
- Noção de `BuildContext` — [05 — BuildContext](../05-introducao-ao-flutter/07-buildcontext.md).

---

## 📖 Conceito

### O widget `Text`

`Text` é o widget que desenha uma sequência de caracteres na tela. Na forma mais curta:

```dart
const Text('Matérias')
```

Ele aceita, entre outros:

| Parâmetro | Tipo | Para que serve |
|---|---|---|
| `style` | `TextStyle?` | Aparência: fonte, tamanho, peso, cor |
| `textAlign` | `TextAlign?` | Alinhamento horizontal dentro do espaço disponível |
| `maxLines` | `int?` | Número máximo de linhas |
| `overflow` | `TextOverflow?` | O que fazer quando não cabe |
| `softWrap` | `bool?` | Se pode quebrar linha (padrão `true`) |
| `semanticsLabel` | `String?` | O que o leitor de tela fala, no lugar do texto visível |
| `textScaler` | `TextScaler?` | Sobrescreve a escala de fonte (use com muito cuidado) |

### `TextStyle`

`TextStyle` é uma classe de **descrição de aparência**. Ela não desenha nada sozinha; é entregue ao
`Text`.

```dart
const TextStyle(
  fontSize: 16,             // tamanho em pixels lógicos
  fontWeight: FontWeight.w600, // espessura: w100 (fina) a w900 (preta); bold = w700
  color: Colors.black87,    // cor
  height: 1.4,              // altura da linha como MULTIPLICADOR do fontSize
  letterSpacing: 0.2,       // espaço entre letras
  fontStyle: FontStyle.italic,
  decoration: TextDecoration.underline,
)
```

Detalhe que confunde: **`height` não é altura em pixels**. É um multiplicador. Com `fontSize: 16` e
`height: 1.4`, cada linha ocupa 22,4 pixels. É assim que se controla o "respiro" entre linhas de um
parágrafo.

### `textTheme`: pare de chutar `fontSize`

Escolher `fontSize: 22` numa tela e `fontSize: 23` em outra é como pintar cada parede da casa com
uma cor "quase" igual. O Material 3 resolve isso com uma **escala tipográfica**: 13 estilos prontos,
já ajustados em tamanho, peso e espaçamento, disponíveis pelo tema.

```dart
Text('Matérias', style: Theme.of(context).textTheme.headlineSmall)
```

Os 13 estilos, em três famílias:

| Família | Estilos | Uso pretendido |
|---|---|---|
| **Display** | `displayLarge` (57), `displayMedium` (45), `displaySmall` (36) | Números e frases de destaque gigantes. Uma por tela, no máximo |
| **Headline** | `headlineLarge` (32), `headlineMedium` (28), `headlineSmall` (24) | Títulos de seção importantes |
| **Title** | `titleLarge` (22), `titleMedium` (16), `titleSmall` (14) | Títulos de cartões, itens de lista, `AppBar` |
| **Body** | `bodyLarge` (16), `bodyMedium` (14), `bodySmall` (12) | Texto corrido, descrições. `bodyMedium` é o padrão |
| **Label** | `labelLarge` (14), `labelMedium` (12), `labelSmall` (11) | Texto dentro de botões, etiquetas, legendas |

Os números entre parênteses são os tamanhos padrão em pixels lógicos, na fonte padrão do Material 3.

> ⛔ **API depreciada:** `textTheme.headline6`, `bodyText1`, `subtitle2` e companhia pertencem ao
> Material 2 e **não devem ser usados**. Se um tutorial mostrar `headline6`, o equivalente atual é
> `titleLarge`.

Para mudar só um detalhe de um estilo do tema, use `copyWith`:

```dart
Theme.of(context).textTheme.titleMedium?.copyWith(
  color: Theme.of(context).colorScheme.primary,
  fontWeight: FontWeight.bold,
)
```

O `?.` é necessário porque os estilos do `textTheme` são anuláveis (`TextStyle?`) —
[05 — Null safety](../02-dart-basico/05-null-safety.md).

### Texto que não cabe: `maxLines` + `overflow`

Se um `Text` recebe mais caracteres do que cabem na largura disponível, ele **quebra linha**. Se não
houver altura para tantas linhas, você vê o aviso amarelo-e-preto de estouro de layout.

A dupla que resolve:

```dart
Text(
  'Introdução à Álgebra Linear com Aplicações em Computação Gráfica',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

Valores de `TextOverflow`:

| Valor | Resultado |
|---|---|
| `TextOverflow.clip` | Corta no limite, sem aviso visual (padrão quando há `maxLines`) |
| `TextOverflow.ellipsis` | Corta e coloca `…` — **é o que o usuário espera** |
| `TextOverflow.fade` | Desvanece o fim do texto |
| `TextOverflow.visible` | Deixa vazar (você verá a faixa de estouro) |

### Frase com estilos misturados: `Text.rich` e `TextSpan`

Quando parte da frase precisa de outro estilo — "Você estudou **120 minutos** hoje" — não use dois
`Text` colados, porque eles não quebram linha juntos. Use um `TextSpan`, que é um **pedaço** de texto
com estilo próprio, dentro de uma árvore de pedaços:

```dart
Text.rich(
  TextSpan(
    text: 'Você estudou ',
    children: <InlineSpan>[
      TextSpan(
        text: '120 minutos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: ' hoje.'),
    ],
  ),
)
```

Existe também o widget `RichText`, que recebe o mesmo `TextSpan`. A diferença prática e importante:

- **`RichText` não herda o estilo padrão do tema.** Se você não informar cor e tamanho, o texto sai
  com a aparência bruta (geralmente preto, 14, sem respeitar o modo escuro).
- **`Text.rich` herda.** Por isso, prefira `Text.rich` em 99 % dos casos.

### Ícones: `Icon` e `Icons`

`Icons` é uma classe cheia de constantes: `Icons.search`, `Icons.timer`, `Icons.menu_book`. São
**fontes de ícones** (cada ícone é um "caractere" de uma fonte), por isso escalam sem perder
qualidade e aceitam cor.

```dart
Icon(
  Icons.timer_outlined,
  size: 20,               // padrão é 24
  color: Colors.indigo,
  semanticLabel: 'Tempo estudado',
)
```

Convenções de nome úteis:

| Sufixo | Estilo |
|---|---|
| sem sufixo | Preenchido (`Icons.timer`) |
| `_outlined` | Contorno (`Icons.timer_outlined`) |
| `_rounded` | Cantos arredondados |
| `_sharp` | Cantos retos |

Padrão do Material 3 e usado neste curso: **contorno quando inativo, preenchido quando ativo** — foi
exatamente isso que você fez na `NavigationBar` da Aula 1 com `icon` e `selectedIcon`.

Se você não informar `color`, o ícone usa a cor do `IconTheme` mais próximo — que o tema define. Isso
faz o ícone mudar sozinho no modo escuro, o que é desejável.

### Acessibilidade: `semanticsLabel` e escala de fonte

**Leitor de tela** é o recurso do sistema que lê a tela em voz alta para pessoas cegas ou com baixa
visão (TalkBack no 🤖 Android, VoiceOver no 🍎 iOS).

Duas armadilhas comuns e como resolvê-las:

**1. Texto que não se lê em voz alta.** `Text('120 min')` é lido como "cento e vinte min". Melhor:

```dart
const Text('120 min', semanticsLabel: '120 minutos estudados')
```

O usuário vidente continua vendo `120 min`; o leitor de tela fala a frase completa.

⚠️ Repare na grafia: no `Text` o parâmetro é **`semanticsLabel`** (com "s"); no `Icon` é
**`semanticLabel`** (sem "s"). É assimétrico mesmo; o editor avisa se você errar.

**2. Escala de fonte do sistema.** Tanto no Android quanto no iOS o usuário pode aumentar o tamanho
da fonte nas configurações do aparelho — até **200 %** ou mais. Seu app precisa continuar usável.

No Flutter isso chega pelo `TextScaler`:

```dart
final TextScaler escala = MediaQuery.textScalerOf(context);
final double alturaMinima = escala.scale(48); // 48 dp ajustados à escala do usuário
```

> ⛔ **API depreciada:** `MediaQuery.of(context).textScaleFactor` e o parâmetro `textScaleFactor` do
> `Text` foram substituídos por `TextScaler`. Não use os antigos.

Regra prática deste curso: **nunca** trave a altura de um widget que contém texto. Use `Padding` em
vez de `SizedBox(height: ...)` fixo ao redor de texto, para o widget crescer junto com a fonte. Você
volta a isso na [Aula 11 — Responsividade](11-responsividade.md).

---

## 💡 Analogia

O `textTheme` é o **guia de estilo de uma revista**. A revista não deixa cada repórter escolher a
fonte da sua matéria: existe um estilo "manchete", um "olho", um "corpo de texto", um "legenda de
foto". Todo mundo usa os mesmos, e por isso a revista inteira parece uma coisa só.

Escrever `fontSize: 23` espalhado pelo app é como cada repórter escolher sua própria fonte: funciona
na página isolada, e vira uma colcha de retalhos quando você folheia.

---

## 🧪 Exemplo mínimo

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ExemploTexto()));

class ExemploTexto extends StatelessWidget {
  const ExemploTexto({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('120', style: tipografia.displayMedium),
            Text('minutos hoje', style: tipografia.titleMedium),
            const Icon(Icons.local_fire_department, size: 32),
          ],
        ),
      ),
    );
  }
}
```

Três estilos diferentes, nenhum `fontSize` escrito à mão, e o resultado já está coerente com o resto
do app.

---

## 📱 Aplicando no Flutter

Vamos trocar o `body` genérico da `HomeScreen` por um **resumo do dia** de verdade, usando só texto e
ícones. Nas próximas aulas ele ganha cartão, cores e imagem.

O que o resumo mostra:

1. Uma saudação (`titleMedium`).
2. O total de minutos estudados hoje, em número grande (`displaySmall`).
3. Uma frase com parte em negrito, montada com `Text.rich`.
4. Uma linha com ícone + nome da matéria atual, com `overflow: ellipsis` para nomes longos.

---

## 💻 Código completo

> **Arquivo:** `lib/features/materias/presentation/home_screen.dart`
> **Como executar:** `flutter run -d windows`

Substitua **apenas** o `body:` do `Scaffold` pelo código abaixo e acrescente os dois métodos
auxiliares dentro de `_HomeScreenState`. O resto do arquivo (da Aula 1) continua igual.

```dart
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _construirResumo(context),
        ),
      ),
```

E, dentro da classe `_HomeScreenState`, antes do `build`:

```dart
  /// Dados de exemplo enquanto não há banco de dados (Módulo 10).
  static const int _minutosHoje = 120;
  static const int _metaMinutos = 180;
  static const String _materiaAtual =
      'Introdução à Álgebra Linear com Aplicações';

  Widget _construirResumo(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;
    final ColorScheme cores = Theme.of(context).colorScheme;
    final int restante = _metaMinutos - _minutosHoje;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Bom estudo!', style: tipografia.titleMedium),
        const SizedBox(height: 4),
        Text(
          '$_minutosHoje min',
          style: tipografia.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cores.primary,
          ),
          semanticsLabel: '$_minutosHoje minutos estudados hoje',
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: 'Faltam ',
            children: <InlineSpan>[
              TextSpan(
                text: '$restante minutos',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' para bater a meta de hoje.'),
            ],
          ),
          style: tipografia.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text('Matéria em andamento', style: tipografia.labelLarge),
        const SizedBox(height: 4),
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
                _materiaAtual,
                style: tipografia.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
```

Rode:

```powershell
flutter run -d windows
```

Depois, com o app aberto, **estreite a janela** até uns 300 pixels de largura. Observe o nome da
matéria virar `Introdução à Álgebra Line…` em vez de estourar o layout.

---

## 🔍 Explicando o código

**`final TextTheme tipografia = Theme.of(context).textTheme;`** — guardamos numa variável local
porque vamos usar cinco vezes. `Theme.of(context)` percorre a árvore de widgets para cima até achar
o tema; fazer isso uma vez por `build` é mais barato e mais legível.

**`static const int _minutosHoje = 120;`** — dado falso, declarado `static const` porque ainda não
muda. Quando o banco de dados chegar no [Módulo 10](../10-persistencia-de-dados/README.md), esses
valores virão do `sqflite`. Deixar explícito que é dado de exemplo evita você esquecer depois.

**`crossAxisAlignment: CrossAxisAlignment.start`** — alinha todos os filhos da `Column` à esquerda. O
padrão é `center`, que deixaria o resumo centralizado e estranho. Eixos e alinhamentos são o assunto
da [Aula 4](04-row-column-expanded.md).

**`tipografia.displaySmall?.copyWith(...)`** — pega o estilo pronto do tema e muda **só** peso e cor.
Se você escrevesse um `TextStyle` do zero, perderia a família de fonte e o espaçamento definidos pelo
Material 3.

**`semanticsLabel: '$_minutosHoje minutos estudados hoje'`** — o TalkBack/VoiceOver lê a frase
completa em vez de "cento e vinte min".

**`Text.rich(TextSpan(...), style: tipografia.bodyMedium)`** — o `style` no `Text.rich` vale como base
para **todos** os spans; cada `TextSpan` filho só declara a diferença (aqui, o negrito).

**`const SizedBox(height: 8)`** — espaço vertical vazio. É a forma idiomática de separar widgets numa
`Column`. A [Aula 3](03-container-padding-sizedbox.md) detalha por que `SizedBox` é melhor que
`Container` para isso.

**`Expanded` em volta do `Text` dentro da `Row`** — sem ele, o `Text` tentaria ocupar a largura que
quisesse e estouraria a linha. `Expanded` diz: "ocupe o que sobrou depois do ícone e do espaço".
Só com uma largura definida o `overflow: ellipsis` tem como funcionar.

**`maxLines: 1` + `overflow: TextOverflow.ellipsis`** — a dupla obrigatória em qualquer texto vindo
de dados do usuário. Nome de matéria pode ter 3 ou 300 caracteres; seu layout precisa aguentar os
dois.

**`semanticLabel: 'Matéria'` no `Icon`** — sem isso, o leitor de tela ignora o ícone (o que às vezes
é o certo, quando o ícone é puramente decorativo e o texto ao lado já diz tudo). Aqui ele reforça o
contexto.

---

## ⚠️ Erros comuns

**1. Usar `headline6`, `bodyText2`, `subtitle1`**

```text
The getter 'headline6' isn't defined for the type 'TextTheme'.
```

São nomes do Material 2, removidos. Tabela de conversão dos mais vistos:

| Material 2 (morto) | Material 3 (use este) |
|---|---|
| `headline4` | `headlineMedium` |
| `headline6` | `titleLarge` |
| `subtitle1` | `titleMedium` |
| `bodyText1` | `bodyLarge` |
| `bodyText2` | `bodyMedium` |
| `caption` | `bodySmall` |
| `button` | `labelLarge` |

**2. `overflow: TextOverflow.ellipsis` sem largura definida**

O `…` não aparece e o texto continua estourando. Motivo: sem restrição de largura, o `Text` acha que
tem espaço infinito, então nada "não cabe". Solução: `Expanded`, `Flexible` ou um `SizedBox(width:)`
em volta. Isso fica cristalino na [Aula 6 — Constraints](06-constraints.md).

**3. `RichText` que ignora o modo escuro**

`RichText` não herda o estilo padrão. No modo escuro o texto continua preto sobre fundo preto. Use
`Text.rich`, ou informe o estilo explicitamente no `TextSpan` raiz.

**4. Travar a altura de um texto**

```dart
// ❌ quebra quando o usuário aumenta a fonte do sistema
SizedBox(height: 20, child: Text('Matérias'))
```

Com escala de 200 %, o texto precisa de 40 pixels e você deu 20. Resultado: estouro. Use `Padding`.

**5. Ícone sem rótulo em botão sem texto**

Um `IconButton` só com `Icons.delete` e sem `tooltip`/`semanticLabel` é anunciado pelo leitor de tela
apenas como "botão". A pessoa não tem como saber que aquilo apaga algo.

**6. Esquecer o `?.` no `textTheme`**

```text
The method 'copyWith' can't be unconditionally invoked because the receiver can be 'null'.
```

Os estilos são `TextStyle?`. Use `?.copyWith(...)` ou, se tiver certeza, `!`.

---

## 🛠️ Exercício guiado

Vamos exibir um **selo de nível de foco** que muda de texto, cor e ícone conforme os minutos.

**Passo 1.** Dentro de `_HomeScreenState`, acrescente:

```dart
  ({String rotulo, IconData icone}) _nivelDeFoco(int minutos) {
    if (minutos >= 180) {
      return (rotulo: 'Foco máximo', icone: Icons.local_fire_department);
    }
    if (minutos >= 60) {
      return (rotulo: 'Bom ritmo', icone: Icons.trending_up);
    }
    return (rotulo: 'Começando', icone: Icons.play_arrow);
  }
```

Isso é um **record** do Dart: uma estrutura leve que devolve mais de um valor sem criar classe.
Revise em [04 — Records](../04-dart-avancado/04-records.md).

**Passo 2.** No fim da `Column` do `_construirResumo`, antes do fechamento, adicione:

```dart
        const SizedBox(height: 16),
        Builder(
          builder: (BuildContext context) {
            final nivel = _nivelDeFoco(_minutosHoje);
            return Row(
              children: <Widget>[
                Icon(nivel.icone, size: 18, color: cores.tertiary),
                const SizedBox(width: 6),
                Text(
                  nivel.rotulo,
                  style: tipografia.labelLarge?.copyWith(color: cores.tertiary),
                ),
              ],
            );
          },
        ),
```

**Passo 3.** Salve e use o *hot reload*. Depois mude `_minutosHoje` para `30`, depois para `200`, e
recarregue a cada mudança.

**O que observar:** o texto do selo usa `labelLarge` — o estilo pensado exatamente para etiquetas — e
a cor vem de `cores.tertiary`, um papel do `ColorScheme` que você vai entender por completo na
[Aula 7](07-cores-temas-modo-escuro.md). Nenhum `fontSize` e nenhum código hexadecimal de cor foram
escritos à mão.

**Resultado esperado:** com 120 minutos, aparece "Bom ritmo" com a seta de tendência; com 200,
"Foco máximo" com a chama; com 30, "Começando".

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Foque nos exercícios de **Fixação** sobre tipografia e no de **Correção de bugs** que envolve texto
estourando a linha.

---

## 🏆 Desafio opcional

Crie um widget `TituloDeSecao` reutilizável, em
`lib/features/materias/presentation/widgets/materia_tile.dart` (o arquivo nasce completo na
[Aula 4](04-row-column-expanded.md); por enquanto crie-o só com este widget):

1. Recebe `titulo` (`String`), `icone` (`IconData`) e um `contador` opcional (`int?`).
2. Usa `titleSmall` para o título e `labelSmall` para o contador.
3. Quando `contador` for nulo, não desenha nada no lugar dele — nem espaço vazio.
4. O widget inteiro tem construtor `const` e recebe `{super.key}`.
5. O título usa `maxLines: 1` e `ellipsis`.

Critério de sucesso: `flutter analyze` sem avisos e o widget usado duas vezes na `HomeScreen` com
aparências diferentes, sem nenhum `fontSize` escrito à mão.

---

## 📌 Resumo

- `Text` desenha texto; `TextStyle` descreve a aparência. `height` é **multiplicador**, não pixels.
- Use os 13 estilos do `textTheme` do Material 3 (`displayLarge` … `labelSmall`) em vez de `fontSize`
  solto. Ajuste com `copyWith`, nunca do zero.
- `headline6`, `bodyText1` e afins são Material 2 e foram removidos.
- Texto vindo de dados sempre com `maxLines` + `overflow: TextOverflow.ellipsis` — e só funciona se
  houver uma largura definida (`Expanded`, `Flexible`, `SizedBox`).
- Para estilos misturados na mesma frase use `Text.rich` + `TextSpan`. Evite `RichText`, que não
  herda o estilo do tema.
- `Icon` + `Icons`, com `size` (padrão 24) e `color` (padrão vem do `IconTheme`).
  Contorno = inativo, preenchido = ativo.
- Acessibilidade: `semanticsLabel` no `Text`, `semanticLabel` no `Icon`, `tooltip` no `IconButton`.
- A escala de fonte do sistema chega por `MediaQuery.textScalerOf(context)` (`TextScaler`).
  `textScaleFactor` está depreciado. Nunca trave a altura de um widget com texto.

---

## ☑️ Checklist de domínio

- [ ] Cito as cinco famílias do `textTheme` e digo para que serve cada uma.
- [ ] Converto `headline6` para o nome correto do Material 3 sem consultar.
- [ ] Explico por que `height: 1.4` não significa 1,4 pixel.
- [ ] Escrevo `maxLines` + `overflow` e sei por que preciso de largura definida.
- [ ] Sei dizer a diferença entre `Text.rich` e `RichText` e escolho o certo.
- [ ] Uso `copyWith` para variar um estilo do tema em vez de criar `TextStyle` novo.
- [ ] Coloco `semanticsLabel` em número ou abreviação que o leitor de tela falaria errado.
- [ ] Aumentei a fonte do sistema para 200 % e meu resumo continuou legível.
- [ ] O `body` da `HomeScreen` mostra o resumo do dia sem nenhum `fontSize` escrito à mão.

---

## 📚 Referências oficiais

- [API — `Text`](https://api.flutter.dev/flutter/widgets/Text-class.html)
- [API — `TextStyle`](https://api.flutter.dev/flutter/painting/TextStyle-class.html)
- [API — `TextTheme`](https://api.flutter.dev/flutter/material/TextTheme-class.html)
- [API — `TextSpan`](https://api.flutter.dev/flutter/painting/TextSpan-class.html)
- [API — `Icon`](https://api.flutter.dev/flutter/widgets/Icon-class.html)
- [API — `Icons` (catálogo completo)](https://api.flutter.dev/flutter/material/Icons-class.html)
- [API — `TextScaler`](https://api.flutter.dev/flutter/painting/TextScaler-class.html)
- [Material 3 — Type scale](https://m3.material.io/styles/typography/type-scale-tokens)
- [Flutter — Acessibilidade](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Scaffold e AppBar](01-scaffold-e-appbar.md) | [README](README.md) | [Aula 3 — Container, Padding e SizedBox](03-container-padding-sizedbox.md) |
