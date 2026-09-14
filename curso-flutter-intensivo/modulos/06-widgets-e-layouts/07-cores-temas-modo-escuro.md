# Aula 7 — Cores, temas e modo escuro

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Gerar uma paleta completa e harmônica a partir de **uma única cor** com `ColorScheme.fromSeed`.
- Explicar os **papéis de cor** do Material 3 (`primary`, `onPrimary`, `surface`, `error`…) e o
  padrão `X` ↔ `onX`.
- Montar um `ThemeData` e ligar `theme`, `darkTheme` e `themeMode`.
- Ler o tema atual com `Theme.of(context)` e nunca mais escrever um código hexadecimal solto no meio
  da tela.
- Criar o arquivo de tema do projeto (`lib/core/tema/tema_app.dart`) e usá-lo no `main.dart`.
- Verificar **contraste** e entender por que isso é requisito de acessibilidade, não de estética.

## ✅ Pré-requisitos

- [Aula 6 — Constraints](06-constraints.md) e o `foco_ui` com a `HomeScreen` reorganizada.
- `StatefulWidget` e `setState`
  ([05 — StatefulWidget e setState](../05-introducao-ao-flutter/05-statefulwidget-e-setstate.md)).
- Enums em Dart ([03 — Enums](../03-dart-intermediario/07-enums.md)).

---

## 📖 Conceito

### O problema que o tema resolve

Sem tema, cada tela escolhe as próprias cores. Em três semanas você tem sete tons de azul
levemente diferentes, e o modo escuro é impossível: não há um lugar único para trocar tudo.

Com tema, você define as cores **uma vez**, e cada widget pergunta ao tema qual cor usar. Trocar a
identidade visual do app inteiro vira uma linha alterada.

### `ColorScheme.fromSeed`: uma cor vira uma paleta

O Material 3 introduziu um algoritmo que recebe **uma cor semente** (*seed color*) e gera dezenas de
cores derivadas, todas harmônicas entre si e com **contraste garantido** entre os pares:

```dart
final ColorScheme claro = ColorScheme.fromSeed(
  seedColor: const Color(0xFF4F46E5),
);

final ColorScheme escuro = ColorScheme.fromSeed(
  seedColor: const Color(0xFF4F46E5),   // a MESMA semente
  brightness: Brightness.dark,          // muda só isto
);
```

Pontos importantes:

- A cor semente **não aparece necessariamente** na tela. Ela é o ponto de partida do cálculo; o
  algoritmo ajusta luminosidade e saturação para garantir legibilidade.
- A mesma semente gera o tema claro **e** o escuro. Você não escolhe as cores do modo escuro à mão.
- `Color(0xFF4F46E5)` é o formato de cor do Flutter: `0xAARRGGBB` — dois dígitos de opacidade
  (`FF` = opaco), depois vermelho, verde e azul em hexadecimal.

### Os papéis de cor e a regra do `on`

Um `ColorScheme` não tem "azul" e "cinza". Tem **papéis**: o nome diz *para que serve*, não *qual cor
é*. Os principais:

| Papel | Onde usar | Par de texto/ícone |
|---|---|---|
| `primary` | Ação principal, destaque | `onPrimary` |
| `primaryContainer` | Fundo suave de destaque (cartões, chips) | `onPrimaryContainer` |
| `secondary` | Ação secundária, menos peso | `onSecondary` |
| `secondaryContainer` | Fundo suave secundário | `onSecondaryContainer` |
| `tertiary` | Contraponto, sucesso, acento | `onTertiary` |
| `error` | Erro, exclusão, alerta crítico | `onError` |
| `errorContainer` | Fundo suave de erro | `onErrorContainer` |
| `surface` | Fundo de telas e componentes | `onSurface` |
| `surfaceContainerHighest` | Superfície mais destacada que o fundo | `onSurfaceVariant` |
| `outline` | Bordas de campos e divisores fortes | — |
| `outlineVariant` | Bordas sutis | — |
| `inverseSurface` | Fundo invertido (`SnackBar`) | `onInverseSurface` |

**A regra do `on`, que resolve 90 % das dúvidas de cor:**

> Sempre que você pintar um fundo com `X`, pinte o texto e os ícones sobre ele com `onX`.

Fundo `primary` → texto `onPrimary`. Fundo `errorContainer` → texto `onErrorContainer`. O algoritmo
garante que esse par tenha contraste suficiente **nos dois modos**, claro e escuro. É por isso que o
`CartaoDestaque` da [Aula 5](05-stack-e-positioned.md) usa `onPrimaryContainer` em todos os textos.

> ⛔ **Papéis removidos:** `background`, `onBackground` e `surfaceVariant` pertenciam a versões
> anteriores e não devem mais ser usados. Substitua por `surface`, `onSurface` e
> `surfaceContainerHighest`. Se um tutorial usar `colorScheme.background`, ele está desatualizado.

### `ThemeData`: o tema completo

`ColorScheme` é só a parte das cores. `ThemeData` é o pacote inteiro: cores, tipografia, formatos
padrão de botões, cartões, campos de texto, `AppBar`.

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
  appBarTheme: const AppBarTheme(centerTitle: false),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
  ),
)
```

> `useMaterial3` **não precisa mais ser informado**: no Flutter 3.47 ele já vale `true` por padrão.
> Se você vir `useMaterial3: true` em um tutorial, não está errado — só é redundante hoje.

### `theme`, `darkTheme` e `themeMode`

O `MaterialApp` aceita **dois** temas e uma chave que decide qual vale:

```dart
MaterialApp(
  theme: TemaApp.claro,        // usado no modo claro
  darkTheme: TemaApp.escuro,   // usado no modo escuro
  themeMode: ThemeMode.system, // quem decide
  home: const HomeScreen(),
)
```

Os três valores de `ThemeMode`:

| Valor | Comportamento |
|---|---|
| `ThemeMode.system` | Segue a configuração do aparelho. **Padrão e recomendado** |
| `ThemeMode.light` | Força o claro |
| `ThemeMode.dark` | Força o escuro |

Um app bem feito oferece as três opções numa tela de ajustes — e começa em `system`.

### `Theme.of(context)`

É assim que qualquer widget lê o tema vigente:

```dart
final ColorScheme cores = Theme.of(context).colorScheme;
final TextTheme tipografia = Theme.of(context).textTheme;
final Brightness brilho = Theme.of(context).brightness;
```

`Theme.of(context)` sobe a árvore de widgets a partir do `context` até achar o `Theme` mais próximo.
Isso significa que você pode **sobrescrever o tema de um pedaço da tela**:

```dart
Theme(
  data: Theme.of(context).copyWith(
    colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.red),
  ),
  child: const AreaDePerigo(),
)
```

### Contraste e acessibilidade

**Contraste** é a diferença de luminosidade entre o texto e o fundo. É medido como uma razão, de
`1:1` (invisível) a `21:1` (preto sobre branco).

As diretrizes internacionais de acessibilidade (WCAG) exigem:

| Elemento | Contraste mínimo |
|---|---|
| Texto comum (menor que 18 pt) | **4,5:1** |
| Texto grande (18 pt ou 14 pt em negrito) | **3:1** |
| Ícones e bordas de componentes | **3:1** |

Por que isso importa de verdade: cerca de uma em cada doze pessoas com visão masculina tem alguma
deficiência de percepção de cores, e praticamente todo mundo acima dos 40 anos perde sensibilidade ao
contraste. Além disso, contraste baixo torna o app inutilizável **ao sol** — o que, num celular, é a
situação de uso mais comum que existe.

Três regras práticas para este curso:

1. **Use sempre o par `X` / `onX`.** O algoritmo do Material 3 já garante o contraste.
2. **Nunca use a cor como única informação.** "Campo vermelho" não basta: escreva a mensagem de erro.
   Quem não distingue vermelho de verde não recebe nenhuma informação da cor.
3. **Teste no escuro e no claro** antes de considerar uma tela pronta. Alternar o tema é um comando
   de teclado; não há desculpa para não fazer.

---

## 💡 Analogia

Pense num **uniforme escolar**. A escola define: camisa branca, calça azul-marinho, tênis preto. Não
importa quem é o aluno, o uniforme é o mesmo — e por isso a escola inteira "combina".

`ColorScheme.fromSeed` é a direção da escola escolhendo o azul-marinho e derivando dele o azul da
gravata, o azul do agasalho e o azul do brasão, todos harmônicos.

A regra `X` / `onX` é o bordado: sobre a camisa branca, o brasão é escuro; sobre o agasalho escuro, o
brasão é claro. Ninguém borda branco sobre branco.

---

## 🧪 Exemplo mínimo

```dart
import 'package:flutter/material.dart';

void main() => runApp(const ExemploTema());

class ExemploTema extends StatelessWidget {
  const ExemploTema({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (BuildContext context) {
          final ColorScheme cores = Theme.of(context).colorScheme;
          return Scaffold(
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                color: cores.primary,
                child: Text(
                  'Contraste garantido',
                  style: TextStyle(color: cores.onPrimary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

Mude o tema do Windows entre claro e escuro (Configurações → Personalização → Cores) com o app aberto:
ele muda sozinho, porque `themeMode` é `system`.

---

## 📱 Aplicando no Flutter

Vamos fazer três coisas:

1. Criar `lib/core/tema/tema_app.dart` com os dois temas, claro e escuro, em um lugar só.
2. Ligar `theme`, `darkTheme` e `themeMode` no `main.dart`.
3. Colocar um **botão de alternar tema** na `AppBar`, para você testar sem mexer no Windows.

A pasta `core/` guarda o que serve ao app **inteiro**, não a uma funcionalidade específica — é a mesma
divisão do projeto final descrita em [05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md).

```powershell
mkdir lib\core\tema
```

Para o botão de alternar, o estado (qual `ThemeMode` está ativo) precisa viver **acima** do
`MaterialApp`, porque é ele quem consome o valor. Então o `FocoUiApp` deixa de ser `StatelessWidget` e
vira `StatefulWidget`, e passa um *callback* para baixo. Essa técnica se chama **elevação de estado**
e é o assunto de [08 — Elevação de estado](../08-estado-e-arquitetura/02-elevacao-de-estado.md).

---

## 💻 Código completo

> **Arquivo:** `lib/core/tema/tema_app.dart`
> **Como executar:** `flutter run -d windows`

```dart
import 'package:flutter/material.dart';

/// Tema visual do aplicativo Foco.
///
/// Tudo o que é cor, forma e tipografia do app nasce aqui.
/// Nenhuma tela deve escrever um código hexadecimal de cor diretamente.
abstract final class TemaApp {
  /// Cor semente: o algoritmo do Material 3 deriva a paleta inteira dela.
  static const Color semente = Color(0xFF4F46E5);

  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData get escuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final ColorScheme cores = ColorScheme.fromSeed(
      seedColor: semente,
      brightness: brilho,
    );

    return ThemeData(
      colorScheme: cores,
      scaffoldBackgroundColor: cores.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: cores.surface,
        foregroundColor: cores.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: cores.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cores.outlineVariant),
        ),
      ),

      // Área mínima de toque de 48 dp em todos os botões (ver Aula 10).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cores.inverseSurface,
        contentTextStyle: TextStyle(color: cores.onInverseSurface),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),

      dividerTheme: DividerThemeData(
        color: cores.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
```

> **Arquivo:** `lib/main.dart`
> **Como executar:** `flutter run -d windows`

```dart
import 'package:flutter/material.dart';

import 'core/tema/tema_app.dart';
import 'features/materias/presentation/home_screen.dart';

void main() {
  runApp(const FocoUiApp());
}

class FocoUiApp extends StatefulWidget {
  const FocoUiApp({super.key});

  @override
  State<FocoUiApp> createState() => _FocoUiAppState();
}

class _FocoUiAppState extends State<FocoUiApp> {
  /// Começa seguindo a configuração do aparelho — o comportamento esperado.
  ThemeMode _modoTema = ThemeMode.system;

  void _alternarTema() {
    setState(() {
      _modoTema = switch (_modoTema) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.escuro,
      themeMode: _modoTema,
      home: HomeScreen(
        modoTema: _modoTema,
        aoAlternarTema: _alternarTema,
      ),
    );
  }
}
```

> **Arquivo:** `lib/features/materias/presentation/home_screen.dart`
> **Como executar:** `flutter run -d windows`

Mude o cabeçalho da classe para receber os dois novos parâmetros:

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.modoTema,
    required this.aoAlternarTema,
    super.key,
  });

  final ThemeMode modoTema;
  final VoidCallback aoAlternarTema;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

E acrescente, **no início** da lista `actions` da `AppBar`:

```dart
          IconButton(
            tooltip: switch (widget.modoTema) {
              ThemeMode.system => 'Tema: seguindo o sistema',
              ThemeMode.light => 'Tema: claro',
              ThemeMode.dark => 'Tema: escuro',
            },
            icon: Icon(switch (widget.modoTema) {
              ThemeMode.system => Icons.brightness_auto_outlined,
              ThemeMode.light => Icons.light_mode_outlined,
              ThemeMode.dark => Icons.dark_mode_outlined,
            }),
            onPressed: widget.aoAlternarTema,
          ),
```

Rode:

```powershell
flutter run -d windows
```

Toque no ícone de brilho três vezes: automático → claro → escuro → automático. Repare que **nenhum
widget do app precisou ser alterado** para funcionar nos dois modos — porque todos leem cores do
tema.

---

## 🔍 Explicando o código

**`abstract final class TemaApp`** — `abstract` impede instanciar (`TemaApp()` não compila) e `final`
impede herdar. É a forma moderna, em Dart 3, de declarar uma classe que só serve como "coleção de
membros estáticos". Revise em
[03 — Abstratas e interfaces](../03-dart-intermediario/05-abstratas-e-interfaces.md).

**`static ThemeData get claro => _construir(Brightness.light);`** — *getter* estático, sem parênteses
no uso: `TemaApp.claro`. Os dois temas passam pela **mesma** função privada `_construir`, então é
impossível o escuro ficar com forma de botão diferente do claro.

**`scaffoldBackgroundColor: cores.surface`** — garante que o fundo de todas as telas venha do papel
`surface`, e não do padrão interno do Flutter.

**`scrolledUnderElevation: 2`** — quando a lista rola **por baixo** da `AppBar`, ela ganha uma sombra
sutil. É o comportamento do Material 3, e é o que separa visualmente a barra do conteúdo.

**`CardThemeData` (e não `CardTheme`)** — o tipo aceito pelo parâmetro `cardTheme` do `ThemeData` é o
`CardThemeData`. É um detalhe que o editor corrige, mas vale saber por que o nome tem o sufixo
`Data`.

**`minimumSize: const Size.fromHeight(48)`** — define a altura mínima de todos os botões preenchidos e
com contorno do app. Os 48 dp são a área mínima de toque recomendada para dedos, assunto da
[Aula 10](10-gestos-e-feedback.md). Definir no tema significa **nunca mais esquecer** disso numa tela.

**`snackBarTheme` com `inverseSurface`/`onInverseSurface`** — o `SnackBar` do Material 3 usa cores
invertidas em relação à tela, para chamar atenção. Aqui usamos os papéis certos em vez de preto fixo,
e a barra funciona nos dois modos.

**`switch (_modoTema) { ThemeMode.system => ..., }`** — é uma *switch expression* do Dart 3: devolve
um valor em vez de executar comandos, e o compilador **exige** que você trate todos os casos do enum.
Se o Flutter acrescentasse um quarto `ThemeMode`, seu código pararia de compilar — o que é bom.
Revise em [04 — Patterns e switch](../04-dart-avancado/05-patterns-e-switch.md).

**`final VoidCallback aoAlternarTema;`** — `VoidCallback` é um apelido para `void Function()`. O
widget filho não sabe **o que** o callback faz; ele apenas avisa que aconteceu. Essa é a forma padrão
de um filho comunicar um evento ao pai no Flutter.

**`widget.modoTema` dentro do `_HomeScreenState`** — dentro de um `State`, os campos do widget são
acessados por `widget.`. Revisto em
[05 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md).

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Origem do modo escuro | Configurações → Tela → Tema escuro | Ajustes → Tela e brilho → Escuro |
| Troca automática por horário | Comum, configurável pelo usuário | Também disponível ("Automático") |
| Cor dinâmica do papel de parede | **Material You**: o sistema oferece uma paleta derivada do papel de parede (Android 12+). Para usar, combine `ColorScheme.fromSeed` com o `dynamic_color` — fora do escopo deste curso | Não existe equivalente |
| Barra de status | A cor dos ícones acompanha o tema automaticamente | Idem |

Nos dois casos, `ThemeMode.system` é o que faz o app respeitar a escolha do usuário. Não force
`ThemeMode.light` "porque fica mais bonito": para quem tem fotofobia ou usa o celular à noite, isso é
um problema de acessibilidade concreto.

> 🍎 **No Windows você consegue** projetar, escrever e testar o tema escuro inteiro rodando em
> `-d windows` ou em um emulador Android. **O que você não consegue** é ver como ele fica num iPhone
> real, porque isso exige compilar em macOS.

---

## ⚠️ Erros comuns

**1. Usar `colorScheme.background`**

```text
The getter 'background' isn't defined for the type 'ColorScheme'.
```

Papel removido. Use `surface`. O mesmo vale para `onBackground` (→ `onSurface`) e `surfaceVariant`
(→ `surfaceContainerHighest`).

**2. Texto invisível no modo escuro**

Causa: alguém escreveu `color: Colors.black` em vez de `cores.onSurface`. No modo escuro, o fundo
também é escuro. Procure por `Colors.` no seu código — fora do arquivo de tema, cada ocorrência é
suspeita.

**3. Escrever o hexadecimal em várias telas**

`Color(0xFF4F46E5)` espalhado por dez arquivos é dívida técnica garantida. A semente mora em
`TemaApp.semente`; as telas usam papéis.

**4. Esquecer `darkTheme`**

Com `themeMode: ThemeMode.system` mas sem `darkTheme`, o app usa o tema claro mesmo no modo escuro do
sistema — e o usuário acha que está quebrado.

**5. Achar que a cor semente vai aparecer na tela**

`seedColor: Colors.red` não deixa tudo vermelho. O algoritmo ajusta tom e saturação. Se você precisa
de uma cor **exata** em algum lugar, use `ColorScheme.fromSeed(...).copyWith(primary: minhaCor)` — e
verifique o contraste com `onPrimary` à mão.

**6. Confiar só no olho para julgar contraste**

Seu monitor tem brilho alto e você está num ambiente controlado. Use uma ferramenta de verificação de
contraste, ou fique nos pares `X`/`onX`, que já foram calculados.

---

## 🛠️ Exercício guiado

Vamos criar uma **tela de amostra de cores** dentro do próprio app, para você ver todos os papéis lado
a lado. É a ferramenta que eu uso toda vez que preciso escolher uma cor.

**Passo 1.** No `endDrawer` (ou no `drawer`), adicione um `ListTile` que troque a aba atual para
Ajustes. Mais simples ainda: no `body`, quando `_abaAtual == 3`, mostre a amostra em vez da lista.

**Passo 2.** Adicione este método em `_HomeScreenState`:

```dart
  Widget _amostraDeCores(BuildContext context) {
    final ColorScheme c = Theme.of(context).colorScheme;
    final List<(String, Color, Color)> papeis = <(String, Color, Color)>[
      ('primary', c.primary, c.onPrimary),
      ('primaryContainer', c.primaryContainer, c.onPrimaryContainer),
      ('secondary', c.secondary, c.onSecondary),
      ('secondaryContainer', c.secondaryContainer, c.onSecondaryContainer),
      ('tertiary', c.tertiary, c.onTertiary),
      ('error', c.error, c.onError),
      ('errorContainer', c.errorContainer, c.onErrorContainer),
      ('surface', c.surface, c.onSurface),
      ('surfaceContainerHighest', c.surfaceContainerHighest, c.onSurfaceVariant),
      ('inverseSurface', c.inverseSurface, c.onInverseSurface),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: <Widget>[
        for (final (String nome, Color fundo, Color texto) in papeis)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fundo,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Text(nome, style: TextStyle(color: texto)),
          ),
      ],
    );
  }
```

**Passo 3.** No `body`, troque o `Expanded(child: ListView(...))` por:

```dart
            Expanded(
              child: _abaAtual == 3
                  ? _amostraDeCores(context)
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 96),
                      children: <Widget>[
                        for (final Materia materia in _materias)
                          MateriaTile(materia: materia),
                      ],
                    ),
            ),
```

**Passo 4.** Rode, vá para a aba **Ajustes** e alterne o tema pelo ícone da `AppBar`.

**O que observar:** cada faixa mostra o papel pintado com a cor de fundo e o nome escrito com a cor
`on` correspondente. **Todas** permanecem legíveis nos dois modos, e nenhuma cor foi escolhida por
você. Esse é o argumento definitivo a favor de usar papéis em vez de hexadecimais.

A lista de `records` `(String, Color, Color)` é um uso natural de
[records](../04-dart-avancado/04-records.md) com desestruturação no `for`.

**Resultado esperado:** dez faixas coloridas, legíveis em claro e em escuro, sem nenhum
`Colors.alguma_coisa` no código.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Faça o exercício de **Correção de bugs** sobre texto invisível no modo escuro e o de **Implementação**
que pede um tema com semente diferente.

---

## 🏆 Desafio opcional

Acrescente ao `TemaApp` um **tema de alto contraste**:

1. Crie `TemaApp.altoContraste`, usando
   `ColorScheme.fromSeed(seedColor: semente, contrastLevel: 1.0)`.
2. Acrescente à `AppBar` um quarto estado no ciclo do botão de tema.
3. Compare, na sua tela de amostra, as cores dos dois temas claros lado a lado.
4. Escreva, em um comentário no código, quais papéis mudaram mais e por que isso ajuda alguém com
   baixa visão.
5. Garanta que o app continue compilando com `flutter analyze` limpo.

Critério de sucesso: a diferença entre os dois temas é visível na amostra, e você consegue explicar
qual dos dois usaria como padrão e por quê.

---

## 📌 Resumo

- `ColorScheme.fromSeed(seedColor:)` gera a paleta inteira a partir de **uma** cor.
  A mesma semente + `brightness: Brightness.dark` gera o tema escuro.
- Os papéis dizem **para que serve** a cor, não qual cor é. Regra de ouro: fundo `X` → texto `onX`.
- `background`, `onBackground` e `surfaceVariant` foram removidos. Use `surface`, `onSurface`,
  `surfaceContainerHighest`.
- `ThemeData` reúne cores, tipografia e estilos padrão de componentes.
  `useMaterial3` já é `true` por padrão no Flutter 3.47.
- `MaterialApp` recebe `theme`, `darkTheme` e `themeMode`. Comece em `ThemeMode.system`.
- `Theme.of(context)` lê o tema vigente e pode ser sobrescrito por subárvore com `Theme(data: ...)`.
- Contraste mínimo: 4,5:1 para texto comum, 3:1 para texto grande e componentes. Nunca use cor como
  **única** informação.
- O tema mora em `lib/core/tema/tema_app.dart`. Fora dele, nenhum hexadecimal.

---

## ☑️ Checklist de domínio

- [ ] Explico o que a cor semente faz — e o que ela **não** garante.
- [ ] Recito a regra `X`/`onX` e a aplico sem pensar.
- [ ] Converto `colorScheme.background` para o papel correto.
- [ ] Sei a diferença entre `theme`, `darkTheme` e `themeMode`.
- [ ] Meu app alterna entre automático, claro e escuro pelo botão da `AppBar`.
- [ ] Nenhum arquivo do `foco_ui`, fora de `tema_app.dart`, contém um código hexadecimal de cor.
- [ ] Testei todas as telas nos dois modos e nada ficou ilegível.
- [ ] Sei citar os contrastes mínimos exigidos para texto comum e para texto grande.
- [ ] `flutter analyze` passa sem avisos.

---

## 📚 Referências oficiais

- [API — `ColorScheme.fromSeed`](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)
- [API — `ThemeData`](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [API — `ThemeMode`](https://api.flutter.dev/flutter/material/ThemeMode.html)
- [API — `Theme`](https://api.flutter.dev/flutter/material/Theme-class.html)
- [Flutter — Usando temas](https://docs.flutter.dev/cookbook/design/themes)
- [Material 3 — Color roles](https://m3.material.io/styles/color/roles)
- [Material 3 — Color system](https://m3.material.io/styles/color/system/overview)
- [WCAG — Contraste mínimo](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Constraints](06-constraints.md) | [README](README.md) | [Aula 8 — Imagens e assets](08-imagens-e-assets.md) |
