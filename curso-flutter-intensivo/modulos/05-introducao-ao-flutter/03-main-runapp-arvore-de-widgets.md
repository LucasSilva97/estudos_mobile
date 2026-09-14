# Aula 3 — main, runApp e a árvore de widgets

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que `main()` e `runApp()` fazem, e por que `runApp()` recebe **um único** widget.
- Descrever o papel do `MaterialApp` e o que deixa de funcionar sem ele.
- Desenhar a **árvore de widgets** de uma tela e identificar quem é pai e quem é filho.
- Explicar por que o Flutter usa **composição** em vez de **herança** para montar interfaces.
- Explicar, em nível introdutório, como o Flutter transforma a árvore em pixels através de três
  árvores paralelas: **Widget → Element → RenderObject**.
- Substituir o app de contador gerado pelo `flutter create` por um app seu, do zero, com o teste
  automatizado passando.

## ✅ Pré-requisitos

- [Aula 2 — Estrutura do projeto](02-estrutura-do-projeto.md), com `meu_primeiro_app` criado e
  `flutter analyze` rodando.
- [Módulo 02 — Aula 01: Anatomia de um programa](../02-dart-basico/01-anatomia-de-um-programa.md) —
  você já sabe o que é a função `main()`.
- [Módulo 03 — Aula 04: Herança e polimorfismo](../03-dart-intermediario/04-heranca-e-polimorfismo.md)
  — `extends` e `@override`.
- [Módulo 03 — Aula 02: Construtores](../03-dart-intermediario/02-construtores.md) — parâmetros
  nomeados e `required`.

---

## 📖 Conceito

### `main()` — o mesmo de sempre

A função `main()` é o ponto de entrada de qualquer programa Dart. Você já a usou em todo o módulo
02. No Flutter ela continua exatamente igual:

```dart
void main() {
  runApp(const MeuApp());
}
```

A diferença é que, em vez de imprimir texto e terminar, ela entrega o controle ao framework — e o
programa **nunca termina sozinho**. Ele fica em um laço eterno: desenhar quadro, esperar evento,
desenhar quadro de novo.

Existem duas variações que você vai encontrar:

```dart
// Forma curta com arrow (=>), válida porque runApp devolve void.
void main() => runApp(const MeuApp());
```

```dart
// Quando você precisa fazer algo ANTES de o app subir (ler preferências,
// inicializar banco). O ensureInitialized é obrigatório nesse caso.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... inicializações assíncronas ...
  runApp(const MeuApp());
}
```

`WidgetsFlutterBinding.ensureInitialized()` (*garanta que a ligação está inicializada*) acorda a
ponte entre o Dart e a engine antes da hora. Sem ela, qualquer chamada a um *plugin* (código nativo)
antes do `runApp` falha com `Binding has not yet been initialized`. Você vai usar isso no módulo
[10 — Persistência de dados](../10-persistencia-de-dados/README.md). Por enquanto, a forma simples
basta.

### `runApp()` — a raiz da árvore

```dart
void runApp(Widget app)
```

`runApp` faz três coisas:

1. **Infla** o widget que você passou — ou seja, cria a estrutura interna que o Flutter usa para
   gerenciá-lo (você vai entender o que é "inflar" na seção sobre Element).
2. **Anexa** essa estrutura à raiz da tela, ocupando a tela inteira.
3. **Inicia** o laço de renderização: layout → pintura → composição, repetido a cada quadro.

Repare que o parâmetro é **um único `Widget`**, não uma lista. Isso não é limitação: um widget pode
conter outro, que contém outro, e assim por diante. É exatamente o ponto da árvore.

> ⚠️ `runApp` deve ser chamado **uma vez** por execução do app. Chamar duas vezes substitui a
> árvore inteira — o que é útil em testes, mas é um erro de arquitetura em código de produção.

### `MaterialApp` — o widget que liga os serviços

`MaterialApp` é um widget de conveniência que instala, de uma vez só, quase tudo o que uma tela
Material precisa para existir:

| O que ele fornece | Sem isso, o que quebra |
|---|---|
| `Theme` (cores, fontes, formatos) | `Theme.of(context)` lança erro; widgets ficam sem estilo |
| `Navigator` (a pilha de telas) | `Navigator.of(context)` lança erro; não dá para navegar |
| `Directionality` | `Text` lança `No Directionality widget found` |
| `MediaQuery` | `MediaQuery.of(context)` lança erro; não dá para saber o tamanho da tela |
| `ScaffoldMessenger` | `SnackBar` não aparece |
| `Localizations` | textos internos dos widgets (ex.: "Cancelar" de um diálogo) somem |
| `Overlay` | diálogos, menus e dicas não têm onde ser desenhados |

Os parâmetros mais usados:

```dart
MaterialApp(
  title: 'Meu Primeiro App',              // nome na lista de apps recentes 🤖
  debugShowCheckedModeBanner: false,      // remove a faixa "DEBUG"
  theme: ThemeData(...),                  // tema claro
  darkTheme: ThemeData(...),              // tema escuro
  themeMode: ThemeMode.system,            // segue a configuração do aparelho
  home: const HomeTela(),                 // a primeira tela
)
```

`home` é um atalho para "a rota inicial". Quando você aprender rotas nomeadas em
[07 — Rotas nomeadas](../07-navegacao-e-formularios/02-rotas-nomeadas.md), vai trocar `home` por
`initialRoute` + `onGenerateRoute`.

### A árvore de widgets

Toda interface no Flutter é uma **árvore**: um widget raiz, que tem filhos, que têm filhos.

Veja esta tela e a árvore que a descreve:

```text
MaterialApp
└── Scaffold
    ├── AppBar
    │   └── Text('Meu Primeiro App')
    └── Column                        (body)
        ├── Text('Sessões de hoje')
        ├── SizedBox(height: 12)
        └── FilledButton
            └── Text('Começar')
```

Vocabulário obrigatório:

- **Widget pai** — o que contém. `Column` é pai de `Text`.
- **Widget filho** — o contido. Um widget pode ter:
  - **nenhum filho** (`Text`, `Icon`);
  - **um filho**, no parâmetro `child` (`Center`, `Padding`, `Container`);
  - **vários filhos**, no parâmetro `children` (`Column`, `Row`, `Stack`, `ListView`).
- **Subárvore** — um widget e tudo o que está abaixo dele.
- **Ancestral** — qualquer widget acima na árvore. `MaterialApp` é ancestral de todos.
- **Descendente** — qualquer widget abaixo.

Esses nomes não são decoração: as mensagens de erro do Flutter usam exatamente esse vocabulário.
Por exemplo:

```text
No MediaQuery ancestor could be found starting from the context that was passed to
MediaQuery.of().
```

Traduzindo: "subi a árvore a partir da sua posição e não achei nenhum `MediaQuery` acima de você".

### Composição em vez de herança

Em muitos frameworks antigos, você criava um botão especial **herdando** do botão padrão e
sobrescrevendo métodos. O resultado eram hierarquias gigantes: `Button` → `RoundButton` →
`RoundIconButton` → `RoundIconButtonWithBadge`.

O Flutter faz o contrário. Para obter um botão com margem, centralizado e com sombra, você **embrulha**
widgets simples uns nos outros:

```dart
Center(                       // centraliza
  child: Padding(             // dá margem interna
    padding: const EdgeInsets.all(16),
    child: DecoratedBox(      // desenha sombra e fundo
      decoration: const BoxDecoration(color: Colors.amber),
      child: const Text('Olá'),
    ),
  ),
)
```

Cada widget faz **uma coisa só**. Você combina.

| | Herança | Composição |
|---|---|---|
| Como se estende | `class MeuBotao extends Botao` | `Padding(child: Botao(...))` |
| Acoplamento | alto: mudar a base quebra os filhos | baixo: cada peça é independente |
| Combinações possíveis | precisa de uma classe para cada combinação | qualquer combinação, sem código novo |
| Legibilidade | esconde comportamento na superclasse | tudo visível na árvore |

Você ainda usa herança no Flutter — todo widget seu faz `extends StatelessWidget` ou
`extends StatefulWidget`. Mas você herda **da infraestrutura**, não do comportamento visual. O
visual é sempre composto.

> 💭 Consequência prática: as árvores ficam profundas e muito indentadas. Isso assusta no começo.
> A solução **não** é diminuir a indentação: é **extrair widgets**, e isso é a
> [aula 4](04-statelesswidget.md).

### Widget → Element → RenderObject

Aqui está a parte que separa quem "usa Flutter" de quem "entende Flutter".

O Flutter mantém **três árvores paralelas**, não uma:

```text
  ÁRVORE DE WIDGETS          ÁRVORE DE ELEMENTS          ÁRVORE DE RENDER OBJECTS
  (a receita)                (o gerente)                 (o pintor)

  Padding          ──cria──▶  PaddingElement  ──cria──▶  RenderPadding
    └── Text       ──cria──▶  TextElement     ──cria──▶  RenderParagraph

  descartável                 vive muito tempo           vive muito tempo
  imutável                    guarda a posição           calcula tamanho
  criada a cada build         e o estado                 e desenha pixels
```

**Widget** — a descrição. Imutável, barata, criada e jogada fora milhares de vezes por segundo.
Pense nela como a **planta** de um cômodo.

**Element** — a instância viva na árvore. Ele guarda: quem é o pai, quem são os filhos, qual widget
está descrevendo agora e — no caso de um `StatefulWidget` — o objeto `State`. O `BuildContext` que
você recebe em `build(BuildContext context)` **é um Element**. Literalmente: a classe `Element`
implementa a interface `BuildContext`. Isso é o assunto da [aula 7](07-buildcontext.md).

**RenderObject** — o objeto que mede, posiciona e pinta. É caro de criar. É ele que sabe que o texto
tem 142 pixels de largura.

#### Como isso economiza trabalho

Quando algo muda, o Flutter chama `build()` e recebe uma árvore de widgets **nova**. Em vez de jogar
tudo fora e recriar todos os RenderObjects (o que seria lentíssimo), ele percorre a árvore de
Elements e, para cada posição, compara o widget novo com o antigo:

1. **Mesmo tipo (`runtimeType`) e mesma `key`?** → o Element é **reaproveitado**. Ele só atualiza o
   RenderObject com os valores novos. Barato.
2. **Tipo diferente?** → o Element velho é descartado, junto com o RenderObject, e um novo é criado.
   Caro.
3. **Widget idêntico (`identical()`, o que acontece com `const`)?** → o Flutter nem desce naquela
   subárvore. Ainda mais barato.

Esse é o motivo técnico de duas regras que você vai ouvir o curso inteiro:

- **Use `const` sempre que puder** — o Flutter pula a subárvore inteira.
- **Cuidado ao trocar o tipo do widget** em uma mesma posição — você joga fora estado sem querer.

Resumo em uma frase: **widgets são descartáveis, Elements são persistentes, RenderObjects são caros.**

---

## 💡 Analogia

Imagine uma peça de teatro em cartaz há anos.

- O **roteiro** (Widget) é reescrito e reimpresso toda noite, com pequenas mudanças. É papel, é
  barato, é jogado fora depois.
- O **elenco** (Element) é o mesmo há anos. Cada ator ocupa um papel fixo. Quando o roteiro muda uma
  fala, o ator apenas decora a fala nova — ninguém é demitido.
- O **cenário montado no palco** (RenderObject) é pesado: leva horas para construir. Só é
  desmontado se a peça mudar de verdade.

Se o roteiro novo troca o papel "mordomo" por "detetive" na mesma cena, aí sim o ator sai e outro
entra (tipo diferente = Element descartado). Se o roteiro novo é **exatamente igual** ao de ontem
(`const`), o diretor nem convoca ensaio.

---

## 🧪 Exemplo mínimo

Três widgets, uma árvore de três níveis:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const AppMinimo());
}

class AppMinimo extends StatelessWidget {
  const AppMinimo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Árvore mínima')),
        body: const Center(
          child: Text('Um widget dentro do outro'),
        ),
      ),
    );
  }
}
```

A árvore correspondente:

```text
AppMinimo
└── MaterialApp
    └── Scaffold
        ├── AppBar
        │   └── Text('Árvore mínima')
        └── Center                      (body)
            └── Text('Um widget dentro do outro')
```

Note que `AppMinimo` é um widget **seu** que devolve outros widgets. É assim que toda a interface do
Flutter é construída: widgets que devolvem widgets.

---

## 📱 Aplicando no Flutter

Agora você substitui o app de contador gerado pelo `flutter create` pelo primeiro esboço do
`meu_primeiro_app`: uma tela que mostra o resumo de estudo do dia.

O app final deste módulo vai contar sessões de estudo. Este é o esqueleto visual dele — ainda sem
nenhum estado, tudo fixo. Nas próximas aulas ele ganha vida.

Você vai mexer em **dois** arquivos:

1. `lib/main.dart` — o app novo.
2. `test/widget_test.dart` — o teste gerado testa o contador que você acabou de apagar. Se você não
   ajustá-lo, `flutter test` falha com `Expected: exactly one matching candidate / Actual: _TextWidgetFinder:<zero widgets>`.

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/lib/main.dart`
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Ponto de entrada do programa. É a mesma função main() do Dart de terminal;
/// a diferença é que ela entrega o controle ao framework e nunca retorna.
void main() {
  runApp(const MeuPrimeiroApp());
}

/// Widget raiz da aplicação.
///
/// Ele existe por um motivo só: configurar o MaterialApp. Toda a interface de
/// verdade fica abaixo dele, na árvore.
class MeuPrimeiroApp extends StatelessWidget {
  const MeuPrimeiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nome que 🤖 o Android mostra na lista de apps recentes.
      title: 'Meu Primeiro App',
      // Remove a faixa vermelha "DEBUG" do canto superior direito.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Gera a paleta inteira do Material 3 a partir de uma cor semente.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      // A primeira (e por enquanto única) tela do app.
      home: const HomeTela(),
    );
  }
}

/// Tela inicial: o resumo do dia.
///
/// Ainda não tem estado — todos os números são fixos. A aula 5 transforma isso
/// em um contador de verdade.
class HomeTela extends StatelessWidget {
  const HomeTela({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) sobe a árvore procurando o tema instalado pelo
    // MaterialApp acima. A aula 7 explica esse "subir a árvore".
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Primeiro App'),
        backgroundColor: cores.primaryContainer,
        foregroundColor: cores.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Resumo de hoje',
              style: tema.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Acompanhe quanto você estudou.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: cores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Cartão de destaque: número grande de sessões.
            Card(
              color: cores.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.timer_outlined,
                      size: 48,
                      color: cores.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '0',
                      style: tema.textTheme.displayMedium?.copyWith(
                        color: cores.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'sessões concluídas',
                      style: tema.textTheme.titleMedium?.copyWith(
                        color: cores.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Linha com duas informações lado a lado.
            Row(
              children: <Widget>[
                Expanded(
                  child: _InfoSimples(
                    rotulo: 'Minutos',
                    valor: '0',
                    icone: Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoSimples(
                    rotulo: 'Matérias',
                    valor: '3',
                    icone: Icons.school_outlined,
                  ),
                ),
              ],
            ),

            const Spacer(),

            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('O cronômetro chega na aula 6.'),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloco pequeno com ícone, valor e rótulo.
///
/// O sublinhado no início do nome (_InfoSimples) torna a classe privada ao
/// arquivo — conforme o módulo 03, aula 03 (encapsulamento).
class _InfoSimples extends StatelessWidget {
  const _InfoSimples({
    required this.rotulo,
    required this.valor,
    required this.icone,
  });

  final String rotulo;
  final String valor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Icon(icone, color: tema.colorScheme.primary),
            const SizedBox(height: 8),
            Text(valor, style: tema.textTheme.headlineSmall),
            Text(rotulo, style: tema.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
```

> **Arquivo:** `meu_primeiro_app/test/widget_test.dart`
> **Como executar:** `flutter test`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meu_primeiro_app/main.dart';

void main() {
  testWidgets('A tela inicial mostra o resumo e o botão de iniciar',
      (WidgetTester tester) async {
    // Monta a árvore de widgets do app dentro do ambiente de teste.
    await tester.pumpWidget(const MeuPrimeiroApp());

    // Procura por textos na árvore renderizada.
    expect(find.text('Meu Primeiro App'), findsOneWidget);
    expect(find.text('Resumo de hoje'), findsOneWidget);
    expect(find.text('sessões concluídas'), findsOneWidget);
    expect(find.text('Iniciar sessão'), findsOneWidget);
  });

  testWidgets('O botão mostra uma SnackBar ao ser tocado',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MeuPrimeiroApp());

    await tester.tap(find.text('Iniciar sessão'));
    // pump() avança um quadro: a SnackBar entra na árvore.
    await tester.pump();

    expect(find.text('O cronômetro chega na aula 6.'), findsOneWidget);
  });
}
```

Rode os três comandos, nesta ordem:

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

Saída esperada dos dois primeiros:

```text
Analyzing meu_primeiro_app...
No issues found!

00:02 +2: All tests passed!
```

---

## 🔍 Explicando o código

**A árvore que você acabou de escrever:**

```text
MeuPrimeiroApp
└── MaterialApp
    └── HomeTela
        └── Scaffold
            ├── AppBar
            │   └── Text('Meu Primeiro App')
            └── Padding                          (body)
                └── Column
                    ├── Text('Resumo de hoje')
                    ├── SizedBox
                    ├── Text('Acompanhe...')
                    ├── SizedBox
                    ├── Card
                    │   └── Padding
                    │       └── Column
                    │           ├── Icon · SizedBox · Text('0') · Text('sessões...')
                    ├── SizedBox
                    ├── Row
                    │   ├── Expanded → _InfoSimples → Card → Padding → Column
                    │   ├── SizedBox
                    │   └── Expanded → _InfoSimples → Card → Padding → Column
                    ├── Spacer
                    └── FilledButton
```

| Trecho | O que faz |
|---|---|
| `void main() { runApp(const MeuPrimeiroApp()); }` | Cria o widget raiz e entrega ao framework. O `const` aqui já economiza uma alocação. |
| `class MeuPrimeiroApp extends StatelessWidget` | Widget sem estado. Ele só configura; quem tem conteúdo é a `HomeTela`. |
| `const MeuPrimeiroApp({super.key})` | Construtor `const` com `super.key`. Sem a `key`, o lint `use_key_in_widget_constructors` reclama. |
| `theme: ThemeData(colorScheme: ColorScheme.fromSeed(...))` | Uma cor semente gera toda a paleta do Material 3 (primária, secundária, superfícies, contrastes). Aprofundado na [aula 9](09-material-e-cupertino.md). |
| `home: const HomeTela()` | Define a tela inicial. Note que `HomeTela` **não** é um parâmetro especial: é só outro widget na árvore. |
| `final ThemeData tema = Theme.of(context);` | Lê o tema mais próximo acima na árvore. Guardar em uma variável local evita repetir a busca. |
| `Scaffold` | Esqueleto Material: `appBar`, `body`, e (mais adiante) `floatingActionButton`, `drawer`, `bottomNavigationBar`. |
| `Padding(padding: const EdgeInsets.all(24))` | Margem interna de 24 pixels lógicos em todos os lados. **Pixel lógico** é uma unidade independente da densidade da tela: 24 dá o mesmo tamanho físico num celular barato e num topo de linha. |
| `Column(crossAxisAlignment: CrossAxisAlignment.stretch)` | Empilha verticalmente e faz cada filho ocupar toda a largura disponível. |
| `tema.textTheme.headlineSmall` | Estilo de texto do Material 3. **Nunca** use `textTheme.headline6` — foi removido há várias versões. |
| `?.copyWith(color: ...)` | `textTheme.bodyMedium` é `TextStyle?` (pode ser nulo). O `?.` é o acesso seguro do null safety ([módulo 02, aula 05](../02-dart-basico/05-null-safety.md)). |
| `Card` | Superfície elevada do Material 3. |
| `Row` + `Expanded` | `Row` alinha na horizontal; `Expanded` faz cada filho dividir o espaço em partes iguais. Detalhado em [06 — Row, Column, Expanded](../06-widgets-e-layouts/04-row-column-expanded.md). |
| `Spacer()` | Ocupa todo o espaço vertical que sobrar, empurrando o botão para o fim da tela. |
| `FilledButton.icon` | Botão de destaque do Material 3. `RaisedButton` e `FlatButton` **não existem mais**. |
| `ScaffoldMessenger.of(context).showSnackBar(...)` | Forma correta de mostrar mensagem temporária. `Scaffold.of(context).showSnackBar(...)` foi removido. |
| `class _InfoSimples extends StatelessWidget` | Widget privado ao arquivo (`_`). Aparece duas vezes na árvore com parâmetros diferentes — é reuso por composição. |
| `required this.rotulo` | Parâmetro nomeado obrigatório, do [módulo 03, aula 02](../03-dart-intermediario/02-construtores.md). |
| `final String rotulo;` | Campo `final`: o widget é **imutável**. É por isso que ele pode ser `const`. |

**Sobre o teste:** `tester.pumpWidget(...)` monta a árvore num ambiente de teste sem tela real.
`find.text('...')` procura na árvore de Elements. `await tester.pump()` avança **um** quadro — é o
que faz a `SnackBar` entrar em cena. Isso é aprofundado em
[12 — Testes de widget](../12-testes-e-debug/06-testes-de-widget.md).

---

## 🤖🍎 Android × iOS

O `MaterialApp` já aplica uma diferença de plataforma automaticamente, e você vai notar assim que
rodar o app nos dois lugares:

| Comportamento | 🤖 Android | 🍎 iOS |
|---|---|---|
| Transição ao empilhar uma tela nova | a tela nova **sobe** de baixo, com fade (`ZoomPageTransitionsBuilder`) | a tela nova **desliza** da direita para a esquerda (`CupertinoPageTransitionsBuilder`) |
| Voltar | botão/gesto de sistema na barra de navegação | **arrastar da borda esquerda** para trás |
| Título da `AppBar` | alinhado à **esquerda** | **centralizado** |
| Fonte padrão | Roboto | SF Pro (fonte do sistema) |

O Flutter faz isso sozinho porque o `ThemeData` consulta `defaultTargetPlatform`. Você escreve
**um** `MaterialApp` e ganha as duas transições.

> 🍎 **SÓ NO MAC.** Ver essas diferenças rodando no simulador de iPhone exige macOS + Xcode.
> 🪟 No Windows você tem duas saídas honestas:
> 1. forçar a plataforma no tema para **inspecionar** o comportamento iOS no Chrome/Android:
>    ```dart
>    theme: ThemeData(platform: TargetPlatform.iOS),
>    ```
>    Isso muda transições e alguns widgets adaptativos, mas **não** reproduz o iOS de verdade;
> 2. estudar as diferenças documentadas em
>    [referencias/diferencas-android-ios.md](../../referencias/diferencas-android-ios.md).
>
> O processo completo do iOS está em [15 — Build iOS](../15-build-ios/README.md).

---

## ⚠️ Erros comuns

**1. Esquecer o `MaterialApp`.**
```text
No Directionality widget found.
RichText widgets require a Directionality widget ancestor.
```
Você colocou um `Text` direto no `runApp`. Embrulhe tudo em `MaterialApp`.

**2. Usar `Theme.of(context)` no mesmo `build` que cria o `MaterialApp`.**
```dart
// ❌ ERRADO — este context está ACIMA do MaterialApp
@override
Widget build(BuildContext context) {
  final cores = Theme.of(context).colorScheme; // pega o tema padrão, não o seu
  return MaterialApp(theme: meuTema, home: ...);
}
```
O `context` do `build` de `MeuPrimeiroApp` é **anterior** ao `MaterialApp`. Por isso a `HomeTela`
existe como widget separado — o `build` dela roda **abaixo** do `MaterialApp`. A [aula 7](07-buildcontext.md)
mostra como resolver com `Builder` quando você não quer criar outra classe.

**3. `Column` com `Spacer` dentro de algo sem altura definida.**
```text
RenderFlex children have non-zero flex but incoming height constraints are unbounded.
```
`Spacer` precisa saber qual é o espaço total. Dentro de um `Scaffold.body` funciona; dentro de um
`SingleChildScrollView`, não. Assunto de [06 — Constraints](../06-widgets-e-layouts/06-constraints.md).

**4. Deixar o `test/widget_test.dart` gerado sem ajuste.**
```text
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<zero widgets with text "0">
```
O teste padrão procura o contador que você apagou. Substitua-o, como feito acima.

**5. Achar que `home:` é uma palavra mágica.**
`home` é só um parâmetro que recebe um widget. Qualquer widget serve. Não existe "tela" como tipo
especial no Flutter — tela é um widget que ocupa o espaço todo.

**6. Chamar `runApp` dentro de um widget.**
`runApp` é chamado **uma vez**, no `main()`. Chamar de dentro de um `onPressed` substitui a árvore
inteira e derruba todo o estado.

**7. Usar `textTheme.headline6` ou `accentColor`.**
Ambos foram removidos do Flutter. Os equivalentes atuais são `textTheme.titleLarge` e
`colorScheme.secondary`.

---

## 🛠️ Exercício guiado

**Objetivo:** provar na prática que Element e RenderObject sobrevivem ao `build`, e que trocar o
tipo do widget destrói o estado.

**Passo 1.** No `lib/main.dart`, adicione um `debugPrint` no início do `build` da `HomeTela`:

```dart
@override
Widget build(BuildContext context) {
  debugPrint('build da HomeTela executou');
  final ThemeData tema = Theme.of(context);
  // ... resto igual
```

**Passo 2.** Rode `flutter run -d chrome` e observe o terminal. A mensagem aparece **uma vez**.

**Passo 3.** Redimensione a janela do Chrome. A mensagem aparece de novo, a cada mudança de
tamanho — porque o `MediaQuery` mudou e o Flutter reconstruiu a subárvore.

**Passo 4.** Agora desenhe no papel (ou em `anotacoes.md`) a árvore de widgets completa da sua
`HomeTela`, com no mínimo 12 nós. Compare com a árvore da seção "Explicando o código".

**Passo 5.** Confirme sua árvore com a ferramenta oficial. Com o app rodando, no terminal do
`flutter run`, pressione `v` para abrir o **DevTools** no navegador e clique em **Flutter Inspector**.
Você verá exatamente a mesma árvore, viva. (A ferramenta completa é o tema de
[12 — DevTools](../12-testes-e-debug/03-devtools.md).)

**Passo 6.** Responda por escrito:
1. Quantos `Text` existem na sua árvore?
2. Se você trocar o `Card` do bloco de destaque por um `Container`, o Element daquela posição é
   reaproveitado ou descartado? Por quê?

**Resposta do item 2 (confira depois de responder):** descartado. `Card` e `Container` são tipos
diferentes (`runtimeType` diferente), então o Flutter destrói o Element e o RenderObject daquela
posição e cria novos.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Foque nos de **Leitura de código** (desenhar a árvore a partir de um trecho) e nos de **Aplicação**
(montar uma tela nova compondo widgets).

---

## 🏆 Desafio opcional

Reescreva a `HomeTela` **sem usar `Column` nem `Row`**, apenas com `Stack` e `Positioned`
(empilhamento com posição absoluta), produzindo um layout visualmente parecido.

Depois responda: qual das duas versões continua correta quando o texto do sistema está no tamanho
máximo de acessibilidade? Teste alterando a escala no seu próprio `MaterialApp`:

```dart
builder: (BuildContext context, Widget? filho) {
  final MediaQueryData dados = MediaQuery.of(context);
  return MediaQuery(
    data: dados.copyWith(textScaler: const TextScaler.linear(2.0)),
    child: filho ?? const SizedBox.shrink(),
  );
},
```

Esse experimento antecipa [13 — Acessibilidade](../13-desempenho-e-seguranca/05-acessibilidade.md).

---

## 📌 Resumo

- `main()` é a mesma função do Dart de terminal; `runApp(Widget)` entrega **um** widget ao framework
  e inicia o laço de renderização, que nunca termina.
- `WidgetsFlutterBinding.ensureInitialized()` é obrigatório quando você precisa usar plugins antes
  do `runApp`.
- `MaterialApp` instala tema, `Navigator`, `MediaQuery`, `Directionality`, `ScaffoldMessenger`,
  `Overlay` e localizações. Sem ele, quase nada funciona.
- Interface no Flutter é uma **árvore**: pai contém filho, via `child` (um) ou `children` (vários).
- O Flutter monta interface por **composição**, não por herança: cada widget faz uma coisa e você os
  embrulha uns nos outros.
- Existem **três árvores**: Widget (descrição imutável e descartável), Element (instância viva que
  guarda posição e estado; é o `BuildContext`) e RenderObject (mede, posiciona e pinta; é caro).
- O Flutter reaproveita Elements quando tipo e `key` batem; troca de tipo destrói o Element e o
  estado junto. `const` faz o Flutter pular a subárvore inteira.
- O teste gerado pelo `flutter create` precisa ser atualizado quando você apaga o contador.

---

## ☑️ Checklist de domínio

- [ ] Explico o que `runApp` faz em três etapas.
- [ ] Digo por que `runApp` recebe um único widget e por que isso não é limitação.
- [ ] Listo cinco coisas que o `MaterialApp` fornece e o erro que aparece sem cada uma.
- [ ] Desenho a árvore de widgets de uma tela olhando só o código.
- [ ] Uso corretamente os termos pai, filho, ancestral, descendente e subárvore.
- [ ] Explico composição × herança com um exemplo concreto de cada.
- [ ] Digo o papel de Widget, Element e RenderObject e qual deles é o `BuildContext`.
- [ ] Explico por que `const` deixa o app mais rápido, em termos de árvore de Elements.
- [ ] Explico por que trocar o tipo de um widget na mesma posição descarta o estado.
- [ ] Substituí o app de contador pelo meu, com `flutter analyze` e `flutter test` limpos.
- [ ] Abri o Flutter Inspector e conferi a minha árvore.

---

## 📚 Referências oficiais

- [Introduction to widgets](https://docs.flutter.dev/ui/widgets-intro)
- [Flutter architectural overview — Widgets, Elements, RenderObjects](https://docs.flutter.dev/resources/architectural-overview)
- [runApp — API docs](https://api.flutter.dev/flutter/widgets/runApp.html)
- [MaterialApp class — API docs](https://api.flutter.dev/flutter/material/MaterialApp-class.html)
- [Scaffold class — API docs](https://api.flutter.dev/flutter/material/Scaffold-class.html)
- [Inside Flutter](https://docs.flutter.dev/resources/inside-flutter)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Estrutura do projeto](02-estrutura-do-projeto.md) | [README](README.md) | [Aula 4 — StatelessWidget](04-statelesswidget.md) |
