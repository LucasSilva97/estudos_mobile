# Aula 9 — Material e Cupertino

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é uma **linguagem de design** e por que o Flutter traz **duas** delas prontas.
- Diferenciar **Material 3** (Google/Android) de **Cupertino** (Apple/iOS) em componentes, gestos
  e sensação de uso.
- Escolher entre `MaterialApp`, `CupertinoApp` e a abordagem adaptativa — e **justificar** a
  escolha.
- Montar um tema com **`ColorScheme.fromSeed`** e entender o que ele gera a partir de **uma única
  cor**.
- Configurar **tema claro e escuro** que seguem a preferência do sistema.
- Separar o tema do app em um arquivo próprio, com `ThemeData` reaproveitável.
- Decidir **quando adaptar** a interface por plataforma e quando adaptar é **desperdício de
  tempo**.

## ✅ Pré-requisitos

- [Aula 1 — Como o Flutter funciona](01-como-o-flutter-funciona.md) — o Flutter **pinta os
  próprios pixels**; é por isso que ele pode ter duas linguagens de design ao mesmo tempo.
- [Aula 3 — main, runApp e a árvore de widgets](03-main-runapp-arvore-de-widgets.md) — o
  `MaterialApp` na raiz.
- [Aula 7 — BuildContext](07-buildcontext.md) — `Theme.of(context)` é o mecanismo que faz o tema
  chegar a cada widget.
- O projeto `meu_primeiro_app` rodando.

---

## 📖 Conceito

### O que é uma linguagem de design

Uma **linguagem de design** (*design system*) é um conjunto de regras que define como um app
**parece** e como ele **se comporta**: quais cores, quais tamanhos de texto, quanto espaço entre
os elementos, como um botão reage ao toque, de que lado a seta de voltar aparece, como uma tela
entra e sai.

Existem duas dominantes no mundo mobile:

| | **Material Design** | **Cupertino (Human Interface Guidelines)** |
|---|---|---|
| Criada por | Google | Apple |
| Padrão em | 🤖 Android | 🍎 iOS |
| Versão atual | Material 3 ("Material You") | HIG do iOS 18 |
| No Flutter | `package:flutter/material.dart` | `package:flutter/cupertino.dart` |

> 📌 Aqui está a consequência do que você aprendeu na aula 1: como o Flutter **desenha tudo**, ele
> pode desenhar um botão Material rodando no iPhone, ou um botão Cupertino rodando no Android. As
> duas bibliotecas vêm no SDK e funcionam nas duas plataformas.

### As diferenças que o usuário percebe

| Elemento | 🤖 Material 3 | 🍎 Cupertino |
|---|---|---|
| Barra superior | `AppBar` — título à **esquerda**, sombra/tonalidade ao rolar | `CupertinoNavigationBar` — título **centralizado**, fundo translúcido |
| Botão principal | `FilledButton` — retângulo arredondado preenchido | `CupertinoButton.filled` — cantos mais suaves, sem elevação |
| Voltar | Seta `←` à esquerda **+ botão físico/gesto do sistema** | `‹ Nome da tela anterior` **+ arrastar da borda esquerda** |
| Trocar de tela | Desliza de baixo para cima, com fade | Desliza da direita para a esquerda |
| Interruptor | `Switch` — trilho retangular | `CupertinoSwitch` — trilho totalmente arredondado, verde |
| Carregando | `CircularProgressIndicator` — arco girando | `CupertinoActivityIndicator` — as famosas "pás" cinza |
| Alerta | `AlertDialog` — botões de texto à direita | `CupertinoAlertDialog` — botões empilhados, divididos por linhas |
| Seleção de data | Calendário em grade | Rolete (as "rodinhas" de números) |
| Rolar além do fim | Brilho na borda (*glow*) | Elástico (*bounce*) |
| Navegação principal | `NavigationBar` na base ou `NavigationRail` na lateral | `CupertinoTabBar` na base |

> A diferença que os usuários de iPhone mais sentem falta é o **arrastar da borda esquerda para
> voltar**. Boa notícia: o Flutter faz isso automaticamente quando a plataforma é iOS, mesmo em um
> app Material. Você não precisa fazer nada. Detalhes no
> [Módulo 07, aula 5](../07-navegacao-e-formularios/05-navegacao-android-x-ios.md).

### As três estratégias possíveis

**Estratégia 1 — Material nos dois sistemas.**

```dart
MaterialApp(
  theme: ThemeData(useMaterial3: true, colorScheme: ...),
  home: const HomeTela(),
)
```

O app fica com cara de Android em todo lugar. Um código só, um visual só.

- ✅ Metade do trabalho, metade dos bugs, identidade visual consistente.
- ✅ É o que Google, Alibaba, BMW e a maioria dos apps Flutter comerciais fazem.
- ❌ Um usuário de iPhone atento percebe que "não parece um app de iPhone".

**Estratégia 2 — Cupertino nos dois sistemas.**

```dart
CupertinoApp(
  theme: const CupertinoThemeData(primaryColor: CupertinoColors.activeBlue),
  home: const HomeTela(),
)
```

Raramente é a escolha certa. O catálogo Cupertino é **muito menor** que o Material — não existe
`CupertinoDrawer`, não existe `CupertinoSnackBar`, o suporte a Material 3 de temas não se aplica.
E um app com cara de iPhone rodando no Android parece fora do lugar.

**Estratégia 3 — Adaptar por plataforma.**

```dart
Widget build(BuildContext context) {
  final bool ehIOS = Theme.of(context).platform == TargetPlatform.iOS;
  return ehIOS ? const CupertinoButton(...) : const FilledButton(...);
}
```

- ✅ O app parece nativo nos dois sistemas.
- ❌ **Dobra** o trabalho de interface, os testes e a manutenção de cada tela.
- ❌ Divergências aparecem com o tempo: alguém corrige um bug num ramo e esquece o outro.

### A decisão deste curso

> **Usamos Material 3 nas duas plataformas, com adaptações pontuais onde o custo é baixo e o
> ganho é alto.**

"Adaptações pontuais" significa: os **widgets `.adaptive`** que o próprio Flutter fornece.

```dart
Switch.adaptive(value: ligado, onChanged: _alternar);
CircularProgressIndicator.adaptive();
showAdaptiveDialog<void>(context: context, builder: ...);
Slider.adaptive(value: v, onChanged: _mudar);
Icon(Icons.adaptive.share);            // ícone de compartilhar certo em cada sistema
```

Esses widgets **olham a plataforma sozinhos** e desenham a versão Material ou a versão Cupertino.
É uma palavra a mais no código e nenhuma linha de manutenção extra. Todo o resto continua Material.

Essa decisão está registrada em [05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md), com o
raciocínio completo.

### `ColorScheme.fromSeed`: uma cor vira o app inteiro

Esta é, provavelmente, a função mais útil do Material 3:

```dart
ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5))
```

Você dá **uma cor semente**. O Flutter roda o algoritmo de cores do Material 3 e gera **mais de
40 cores harmonizadas**, todas com contraste garantido entre texto e fundo.

As que você mais vai usar:

| Cor | Para quê | O par de texto |
|---|---|---|
| `primary` | Ação principal: botão de destaque, seleção | `onPrimary` |
| `primaryContainer` | Fundo suave ligado à cor principal | `onPrimaryContainer` |
| `secondary` | Ação de apoio, destaque secundário | `onSecondary` |
| `tertiary` | Terceiro acento, para contraste pontual | `onTertiary` |
| `surface` | Fundo de cartões, folhas, diálogos | `onSurface` |
| `surfaceContainerHighest` | Fundo levemente elevado (o `Card` do curso usa) | `onSurface` |
| `error` | Estado de erro | `onError` |
| `outline` | Bordas e divisores | — |

> 💡 **A regra do `on`.** Toda cor de fundo tem uma companheira com prefixo `on`, que é a cor de
> **texto/ícone** garantidamente legível sobre ela. Se você pintar o fundo com
> `colorScheme.primary`, pinte o texto com `colorScheme.onPrimary`. Seguindo essa regra você nunca
> produz texto ilegível — e o modo escuro funciona de graça.

**Nunca escreva cores fixas no meio dos widgets:**

```dart
Container(color: Colors.blue)            // ❌ fica errado no modo escuro
Text('Oi', style: TextStyle(color: Colors.black))  // ❌ some no fundo escuro

Container(color: Theme.of(context).colorScheme.primaryContainer)   // ✅
Text('Oi', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)) // ✅
```

### Tema claro e tema escuro

O `MaterialApp` aceita três campos que trabalham juntos:

```dart
MaterialApp(
  theme: temaClaro,        // usado quando o sistema está no modo claro
  darkTheme: temaEscuro,   // usado quando o sistema está no modo escuro
  themeMode: ThemeMode.system,   // quem decide: o sistema operacional
  home: const HomeTela(),
)
```

| `themeMode` | Efeito |
|---|---|
| `ThemeMode.system` | Segue a preferência do celular. **Padrão e recomendado.** |
| `ThemeMode.light` | Força o claro, ignorando o sistema |
| `ThemeMode.dark` | Força o escuro |

Para gerar o tema escuro, use **a mesma cor semente** com `brightness: Brightness.dark`:

```dart
ColorScheme.fromSeed(
  seedColor: const Color(0xFF3F51B5),
  brightness: Brightness.dark,
)
```

O algoritmo reajusta luminosidade e saturação para o fundo escuro, mantendo a identidade da marca.
Você **não** escolhe 40 cores duas vezes.

### `useMaterial3`

No Flutter 3.16 em diante, `useMaterial3: true` é o **padrão**. Você não precisa escrever a linha.
Se encontrar `useMaterial3: false` em algum código, é porque alguém está segurando o visual antigo
(Material 2) de propósito — normalmente em migração de app legado.

O que o Material 3 mudou e você vai notar:

- `FilledButton` e `FilledButton.tonal` **passaram a existir** (antes só havia `ElevatedButton`).
- `AppBar` não tem mais sombra por padrão: ela muda de **tonalidade** ao rolar.
- Cantos ficaram mais arredondados; `Card` e `Dialog` ganharam raios maiores.
- `BottomNavigationBar` foi substituído por **`NavigationBar`**.
- Cores passaram a vir do `ColorScheme`, não de `primaryColor`/`accentColor` (que estão obsoletos).

---

## 💡 Analogia

Pense em dois países com regras de trânsito diferentes.

- **Material** é dirigir na mão direita, com placas de um formato; **Cupertino** é dirigir na
  esquerda, com placas de outro formato. Nenhum dos dois é "o certo" — são convenções que os
  motoristas locais já têm na cabeça.
- Um **motorista brasileiro no Reino Unido** dirige mais devagar e comete pequenos erros, não por
  falta de habilidade, mas porque **o automatismo dele não bate com o lugar**. É isso que um
  usuário de iPhone sente em um app 100% Material: nada está quebrado, mas a mão dele vai para o
  lugar errado.
- A **estratégia deste curso** é dirigir de um jeito só, mas **respeitar as placas locais onde elas
  importam de verdade** — a mão que a porta do carro abre, o lado em que você olha antes de
  atravessar. É o que os widgets `.adaptive` fazem: mudam o essencial, sem duplicar o carro.
- E o **`ColorScheme.fromSeed`** é como escolher uma cor de tinta e a loja preparar sozinha todos
  os tons combinando — o mais claro para a parede, o mais escuro para o rodapé, o contrastante
  para a porta. Você escolhe **uma** lata; sai com a cartela inteira, já harmonizada.

---

## 🧪 Exemplo mínimo

Este programa mostra Material e Cupertino lado a lado, para você comparar com os próprios olhos.

> **Arquivo:** `meu_primeiro_app/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AppComparacao());

class AppComparacao extends StatelessWidget {
  const AppComparacao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: const TelaComparacao(),
    );
  }
}

class TelaComparacao extends StatefulWidget {
  const TelaComparacao({super.key});

  @override
  State<TelaComparacao> createState() => _TelaComparacaoState();
}

class _TelaComparacaoState extends State<TelaComparacao> {
  bool _ligado = true;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Material × Cupertino')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text('Botões', style: tema.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              FilledButton(onPressed: () {}, child: const Text('Material')),
              const SizedBox(width: 16),
              CupertinoButton.filled(
                onPressed: () {},
                child: const Text('Cupertino'),
              ),
            ],
          ),
          const Divider(height: 48),

          Text('Interruptores', style: tema.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Switch(
                value: _ligado,
                onChanged: (bool v) => setState(() => _ligado = v),
              ),
              const SizedBox(width: 24),
              CupertinoSwitch(
                value: _ligado,
                onChanged: (bool v) => setState(() => _ligado = v),
              ),
              const SizedBox(width: 24),
              // Este decide sozinho, olhando a plataforma:
              Switch.adaptive(
                value: _ligado,
                onChanged: (bool v) => setState(() => _ligado = v),
              ),
            ],
          ),
          const Divider(height: 48),

          Text('Indicadores de carregamento', style: tema.textTheme.titleLarge),
          const SizedBox(height: 12),
          const Row(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 32),
              CupertinoActivityIndicator(),
            ],
          ),
          const Divider(height: 48),

          Text('Plataforma detectada', style: tema.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            '${tema.platform}',
            style: tema.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Dica: no terminal, aperte "o" para alternar entre Android e iOS '
            'e veja os widgets .adaptive mudarem sozinhos.',
          ),
        ],
      ),
    );
  }
}
```

**Faça isto:** com o app rodando, aperte a tecla **`o`** no terminal. O Flutter alterna
`TargetPlatform` entre `android` e `iOS`. Observe que o `Switch.adaptive` — e **só ele** — muda de
aparência. Os outros dois continuam iguais, porque você pediu explicitamente por eles.

---

## 📱 Aplicando no Flutter

Chegou a hora de organizar o `meu_primeiro_app` como um app de verdade. Até agora tudo estava no
`main.dart`. Nesta aula você vai separar em três arquivos:

```text
lib/
├── main.dart              <- só o ponto de entrada: 4 linhas
├── app.dart               <- o MaterialApp e a configuração do app
├── tema/
│   └── tema_app.dart      <- os temas claro e escuro, isolados
└── telas/
    └── home_tela.dart     <- ganha um botão de alternar tema
```

Por que separar? Porque `main.dart` com 300 linhas é onde todo projeto Flutter começa a apodrecer.
Com a separação:

- Mexer no tema não arrisca quebrar o app.
- O `app.dart` mostra, em uma tela de código, **tudo** que o app configura.
- Dá para testar o tema isoladamente ([Módulo 12](../12-testes-e-debug/README.md)).

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/lib/tema/tema_app.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Temas do aplicativo, claro e escuro, gerados de uma única cor semente.
///
/// A classe é `abstract final` para deixar explícito que ela nunca é
/// instanciada: serve só como espaço de nomes para os dois temas.
abstract final class TemaApp {
  /// A cor da identidade do app. Trocar esta linha muda o app inteiro.
  static const Color _semente = Color(0xFF3F51B5); // índigo

  /// Espaçamento padrão, usado em toda a interface.
  static const double espaco = 16;

  /// Raio de canto padrão dos cartões.
  static const double raio = 12;

  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData get escuro => _construir(Brightness.dark);

  /// Monta o ThemeData. Os dois temas compartilham TUDO menos o brilho —
  /// é isso que garante que o modo escuro não vire um app diferente.
  static ThemeData _construir(Brightness brilho) {
    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: _semente,
      brightness: brilho,
    );

    return ThemeData(
      colorScheme: esquema,

      // ── Barra superior ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false, // padrão do Material; no iOS o Flutter centraliza
        backgroundColor: esquema.surfaceContainer,
        foregroundColor: esquema.onSurface,
      ),

      // ── Cartões ───────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raio),
        ),
      ),

      // ── Botões ────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48), // alvo de toque confortável
        ),
      ),

      // ── Campos de texto ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(raio),
        ),
        filled: true,
        fillColor: esquema.surfaceContainerHighest,
      ),

      // ── Divisores ─────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: esquema.outlineVariant,
        space: espaco * 2,
      ),
    );
  }
}
```

> **Arquivo:** `meu_primeiro_app/lib/app.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/telas/home_tela.dart';
import 'package:meu_primeiro_app/tema/tema_app.dart';

/// Raiz do aplicativo.
///
/// É StatefulWidget porque guarda o ThemeMode escolhido pelo usuário.
/// No Módulo 08 esse estado sai daqui e vai para um provider; no Módulo 10
/// ele passa a ser gravado no aparelho.
class MeuPrimeiroApp extends StatefulWidget {
  const MeuPrimeiroApp({super.key});

  @override
  State<MeuPrimeiroApp> createState() => _MeuPrimeiroAppState();
}

class _MeuPrimeiroAppState extends State<MeuPrimeiroApp> {
  /// system = segue o celular. É o padrão recomendado.
  ThemeMode _modo = ThemeMode.system;

  void _alternarTema() {
    setState(() {
      _modo = switch (_modo) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Primeiro App',
      debugShowCheckedModeBanner: false,

      // Os três campos que trabalham juntos:
      theme: TemaApp.claro,
      darkTheme: TemaApp.escuro,
      themeMode: _modo,

      home: HomeTela(
        modoAtual: _modo,
        onAlternarTema: _alternarTema,
      ),
    );
  }
}
```

> **Arquivo:** `meu_primeiro_app/lib/main.dart` (substitua o arquivo inteiro)

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/app.dart';

/// Ponto de entrada. Mantenha-o curto: quem configura o app é o app.dart.
void main() {
  runApp(const MeuPrimeiroApp());
}
```

Agora a `HomeTela` recebe os dois parâmetros novos e ganha o botão de tema:

> **Arquivo:** `meu_primeiro_app/lib/telas/home_tela.dart` (só os trechos abaixo mudam)

```dart
class HomeTela extends StatefulWidget {
  const HomeTela({
    super.key,
    required this.modoAtual,
    required this.onAlternarTema,
  });

  /// Modo de tema em uso. Serve para desenhar o ícone certo no botão.
  final ThemeMode modoAtual;

  /// Chamado quando o usuário toca no botão de tema.
  final VoidCallback onAlternarTema;

  @override
  State<HomeTela> createState() => _HomeTelaState();
}
```

E, dentro do `build`, acrescente o botão como **primeira** `action` da `AppBar`:

```dart
appBar: AppBar(
  title: const Text('Meu Primeiro App'),
  actions: <Widget>[
    IconButton(
      // O ícone conta ao usuário qual é o modo atual.
      icon: Icon(switch (widget.modoAtual) {
        ThemeMode.system => Icons.brightness_auto_outlined,
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
      }),
      tooltip: switch (widget.modoAtual) {
        ThemeMode.system => 'Tema: automático',
        ThemeMode.light => 'Tema: claro',
        ThemeMode.dark => 'Tema: escuro',
      },
      onPressed: widget.onAlternarTema,
    ),
    Builder(
      builder: (BuildContext contextAbaixoDoScaffold) {
        return IconButton(
          icon: const Icon(Icons.summarize_outlined),
          tooltip: 'Resumo do dia',
          onPressed: () => _abrirResumo(contextAbaixoDoScaffold),
        );
      },
    ),
    Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(child: Text('$_sessoesConcluidas sessões')),
    ),
  ],
),
```

Por fim, um toque adaptativo no botão "Salvar progresso" — a única adaptação de plataforma do app:

```dart
FilledButton.icon(
  onPressed: _salvando ? null : _salvarProgresso,
  icon: _salvando
      ? const SizedBox(
          width: 16,
          height: 16,
          // .adaptive: arco no Android, "pás" cinza no iOS.
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        )
      : const Icon(Icons.save_outlined),
  label: Text(_salvando ? 'Salvando…' : 'Salvar progresso'),
),
```

Rode e confira:

```powershell
flutter analyze
flutter run -d chrome
```

1. Toque no botão de tema três vezes: automático → claro → escuro → automático.
2. No modo escuro, confirme que **todo texto continua legível**. Se algum sumir, é porque uma cor
   fixa escapou — procure por `Colors.` no seu código.
3. Aperte `o` no terminal e observe o `CircularProgressIndicator.adaptive` mudar de forma.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `abstract final class TemaApp` | Modificadores do Dart 3: `abstract` impede instanciar, `final` impede estender. Deixa explícito que a classe é só um espaço de nomes. Visto no [Módulo 03](../03-dart-intermediario/05-abstratas-e-interfaces.md). |
| `static const Color _semente` | **Uma linha** define a identidade visual do app inteiro. Trocar aqui muda tudo. |
| `static ThemeData get claro => _construir(Brightness.light);` | Getter estático: o tema é montado sob demanda, e os dois temas dividem o mesmo código. |
| `ColorScheme.fromSeed(seedColor: ..., brightness: ...)` | Gera 40+ cores harmonizadas a partir de uma. A mesma semente nos dois brilhos mantém a identidade. |
| `appBarTheme`, `cardTheme`, `filledButtonTheme`… | Definem o padrão **uma vez**. Sem isso, você repetiria `shape:` e `elevation:` em cada `Card` do app. |
| `CardThemeData` (e não `CardTheme`) | Mudança do Flutter 3.22+: os temas de componente passaram a usar o sufixo `Data`. Se você ver `CardTheme(` num tutorial antigo, é esse o motivo do erro. |
| `minimumSize: const Size.fromHeight(48)` | 48 px é o alvo de toque mínimo recomendado pelas duas plataformas. Acessibilidade sai de graça. |
| `MeuPrimeiroApp` ser `StatefulWidget` | Porque o `ThemeMode` é **estado**: muda em resposta ao usuário e precisa reconstruir o `MaterialApp`. |
| `switch (_modo) { ThemeMode.system => ... }` | *Switch expression* do Dart 3 — devolve valor em vez de executar comandos. Visto no [Módulo 04](../04-dart-avancado/05-patterns-e-switch.md). O compilador **exige** que você trate todos os casos do `enum`. |
| `debugShowCheckedModeBanner: false` | Tira a faixa "DEBUG" do canto. Cosmético; não muda o modo de compilação. |
| `HomeTela(modoAtual: ..., onAlternarTema: ...)` | **Elevação de estado**: o estado mora no pai, o filho recebe o valor e o callback. É o assunto central do [Módulo 08](../08-estado-e-arquitetura/02-elevacao-de-estado.md). |
| `final VoidCallback onAlternarTema;` | `VoidCallback` é apelido para `void Function()`. |
| `CircularProgressIndicator.adaptive(...)` | A única adaptação de plataforma do app: uma palavra, zero manutenção extra. |
| `main()` com 1 linha de corpo | Regra do curso: `main` **só chama** `runApp`. Configuração fica no `app.dart`. |

---

## 🤖🍎 Android × iOS

O que muda de verdade quando este mesmo código roda nos dois sistemas:

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Título da `AppBar` | À esquerda (`centerTitle: false`) | **Centralizado** — o Flutter ignora seu `centerTitle: false` no iOS por padrão |
| Transição entre telas | De baixo para cima, com fade | Da direita para a esquerda |
| Voltar | Seta + botão/gesto do sistema | Seta + **arrastar da borda esquerda** (automático) |
| Rolagem além do fim | *Glow* na borda | *Bounce* elástico |
| Fonte padrão | Roboto | SF Pro (a fonte do sistema) |
| `CircularProgressIndicator.adaptive()` | Arco girando | `CupertinoActivityIndicator` |
| `Switch.adaptive()` | `Switch` Material | `CupertinoSwitch` |
| `showAdaptiveDialog` | `AlertDialog` | `CupertinoAlertDialog` |
| Modo escuro do sistema | Configurações → Tela → Tema escuro | Ajustes → Tela e Brilho → Escuro |

> 📌 O Flutter aplica **as três primeiras linhas sozinho**, sem você escrever nada. Elas vêm do
> `PageTransitionsTheme` e do `ScrollBehavior` padrão, que consultam `Theme.of(context).platform`.
> É por isso que "usar Material nas duas plataformas" incomoda menos do que parece: as
> **interações** já são adaptadas; só a **aparência dos componentes** é que não é.

---

## ⚠️ Erros comuns

### 1. Cores fixas que somem no modo escuro

```dart
Container(
  color: Colors.white,                                    // ❌
  child: const Text('Olá', style: TextStyle(color: Colors.black)), // ❌
)
```

No modo escuro isso vira um retângulo branco gritante em uma tela preta — ou, pior, texto preto
sobre fundo preto.

**Correção:**

```dart
final ColorScheme cores = Theme.of(context).colorScheme;

Container(
  color: cores.surfaceContainerHighest,                    // ✅
  child: Text('Olá', style: TextStyle(color: cores.onSurface)), // ✅
)
```

> **Como auditar o seu app:** procure por `Colors.` no projeto. Cada resultado é um candidato a
> bug de modo escuro. As exceções legítimas são raras (`Colors.transparent`, uma marca fixa).

### 2. Usar `primaryColor` e `accentColor`

```dart
ThemeData(primaryColor: Colors.blue, accentColor: Colors.orange) // ❌ obsoleto
```

`accentColor` foi **removido**; `primaryColor` continua existindo mas é ignorado pela maioria dos
componentes Material 3.

**Correção:** use `colorScheme`.

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // ✅
)
```

### 3. `CardTheme` em vez de `CardThemeData`

```text
The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'.
```

A partir do Flutter 3.22 os temas de componente passaram a exigir o tipo com sufixo `Data`.

**Correção:** `CardTheme(...)` → `CardThemeData(...)`. O mesmo vale para `DialogThemeData`,
`TabBarThemeData` e outros.

### 4. Misturar `CupertinoApp` com widgets Material

```dart
CupertinoApp(
  home: Scaffold(  // ❌
    body: FilledButton(onPressed: () {}, child: const Text('Oi')),
  ),
)
```

```text
No Material widget found. FilledButton widgets require a Material widget ancestor.
```

Widgets Material precisam de um ancestral `Material` — que o `MaterialApp` fornece e o
`CupertinoApp` não.

**Correção:** escolha um dos dois. Se precisar mesmo dos dois, envolva o trecho Material em um
`Material(...)`. Mas, na prática: **use `MaterialApp`** e adicione widgets Cupertino pontuais
dentro dele — esse sentido funciona.

### 5. Adaptar tudo por plataforma "porque fica mais bonito"

```dart
// ❌ isto, multiplicado por 40 telas, é um projeto que não termina
Widget build(BuildContext context) {
  return Platform.isIOS ? _versaoIOS(context) : _versaoAndroid(context);
}
```

Além do custo, `Platform.isIOS` **quebra no Flutter Web** (`dart:io` não existe lá).

**Correção — se precisar mesmo checar a plataforma:**

```dart
final bool ehIOS = Theme.of(context).platform == TargetPlatform.iOS; // ✅ funciona na web
```

E prefira os widgets `.adaptive` antes de escrever qualquer `if` de plataforma.

### 6. Esquecer de passar `darkTheme`

```dart
MaterialApp(
  theme: TemaApp.claro,
  themeMode: ThemeMode.dark,   // ❌ pedi escuro, mas não forneci tema escuro
)
```

Sem `darkTheme`, o `themeMode: dark` não tem o que usar e o app fica **claro** — parecendo que o
botão de tema está quebrado.

### 7. Reconstruir o `ThemeData` a cada `build`

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)), // ⚠️
  );
}
```

`ColorScheme.fromSeed` roda um algoritmo de cores a cada chamada. Num `build` que acontece muitas
vezes por segundo, isso vira trabalho desperdiçado.

**Correção:** guarde os temas em `static` (como o `TemaApp` desta aula) ou em campos `final`.

---

## 🛠️ Exercício guiado

**Passo 1.** Em `tema_app.dart`, troque `_semente` por `const Color(0xFF00695C)` (verde-azulado).
Salve e aperte `R`. Observe que **o app inteiro** mudou de cor: botões, seleção do
`SegmentedButton`, ícones, barra de progresso. Você mudou **uma linha**.

**Passo 2.** Volte para o índigo. Agora acrescente ao `_construir` um
`textTheme: const TextTheme(titleLarge: TextStyle(fontWeight: FontWeight.w700))` e veja onde isso
aparece.

**Passo 3.** No `Card` da `BarraResumo`, troque `tema.colorScheme.surfaceContainerHighest` por
`Colors.white` fixo. Rode no modo escuro. Anote o que aconteceu com o texto. Depois desfaça.

**Passo 4.** Troque o `Switch` que você criar num teste por `Switch.adaptive`, rode, e aperte `o`
no terminal para alternar a plataforma. Anote a diferença visual.

**Passo 5.** Mude `themeMode` para `ThemeMode.dark` fixo no `app.dart`, e **remova** o
`darkTheme:`. Rode. O app ficou escuro? Explique por escrito o que aconteceu. Depois desfaça.

**Passo 6.** Procure por `Colors.` em todo o `lib/` (no VS Code: `Ctrl` + `Shift` + `F`). Para
cada ocorrência, decida: é uma cor legítima ou um bug de modo escuro esperando acontecer? Corrija
as que forem bug.

**Passo 7.** Responda por escrito: por que o curso escolheu Material nas duas plataformas? Cite
uma situação real em que você **discordaria** dessa escolha e usaria adaptação completa.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Faça os exercícios de **Aplicação** sobre `ColorScheme.fromSeed`, o de **Correção de bugs** com a
cor fixa no modo escuro, e o de **Decisão** sobre Material × Cupertino.

---

## 🏆 Desafio opcional

Faça o `TemaApp` aceitar **mais de uma semente**, e a `HomeTela` oferecer um seletor com três
cores. O app deve trocar de identidade visual na hora, sem reiniciar.

Dica: transforme os getters `claro` e `escuro` em métodos que recebem a `Color` semente, e eleve o
estado da cor escolhida até o `_MeuPrimeiroAppState` — junto do `ThemeMode`, exatamente como você
fez com o tema.

Depois responda: quantos lugares do código você precisou tocar para acrescentar essa
funcionalidade? Se a resposta for "dois ou três", a separação em `tema_app.dart` e `app.dart`
valeu a pena. Guarde essa sensação: é assim que se avalia uma boa arquitetura.

---

## 📌 Resumo

- Linguagem de design é o conjunto de regras de aparência e comportamento. O Flutter traz **duas**:
  **Material** (Google) e **Cupertino** (Apple), ambas funcionando nas duas plataformas.
- A **decisão do curso** é **Material 3 nas duas**, com widgets `.adaptive` onde o custo é uma
  palavra: `Switch.adaptive`, `CircularProgressIndicator.adaptive`, `showAdaptiveDialog`,
  `Icons.adaptive.*`.
- `ColorScheme.fromSeed(seedColor: ...)` gera 40+ cores harmonizadas a partir de **uma**. Trocar a
  semente muda o app inteiro.
- **Regra do `on`:** todo fundo tem um par `onX` legível. Fundo `primary` → texto `onPrimary`.
- **Nunca** escreva `Colors.algumaCoisa` no meio de um widget: quebra o modo escuro.
- Tema escuro: **mesma semente**, `brightness: Brightness.dark`. Não se escolhem 40 cores duas
  vezes.
- `theme` + `darkTheme` + `themeMode: ThemeMode.system` é a configuração padrão recomendada.
- `useMaterial3: true` já é o padrão. `primaryColor` e `accentColor` estão obsoletos.
- Temas de componente usam o sufixo `Data`: `CardThemeData`, `DialogThemeData`.
- Para checar plataforma, use `Theme.of(context).platform`, **não** `Platform.isIOS` — este último
  quebra na web.
- Guarde os `ThemeData` em `static`/`final`; não os reconstrua a cada `build`.
- Estrutura do app: `main.dart` só chama `runApp`; `app.dart` configura; `tema/tema_app.dart`
  isola o tema.

---

## ☑️ Checklist de domínio

- [ ] Explico o que é uma linguagem de design e por que o Flutter tem duas.
- [ ] Cito cinco diferenças visíveis entre Material e Cupertino.
- [ ] Justifico a escolha do curso (Material nas duas) com dois argumentos.
- [ ] Uso `ColorScheme.fromSeed` e explico o que ele gera.
- [ ] Aplico a regra do `on` sem pensar: fundo `primaryContainer` → texto `onPrimaryContainer`.
- [ ] Monto tema claro e escuro a partir da mesma semente.
- [ ] Configuro `theme`, `darkTheme` e `themeMode` corretamente.
- [ ] Sei que `Colors.` no meio de um widget é sinal de bug de modo escuro.
- [ ] Uso `Switch.adaptive` e `CircularProgressIndicator.adaptive` sabendo o que muda.
- [ ] Uso `Theme.of(context).platform` em vez de `Platform.isIOS`.
- [ ] Meu `main.dart` tem apenas o `runApp`, e a configuração está no `app.dart`.
- [ ] Meu tema está isolado em `tema/tema_app.dart`.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Material 3 no Flutter — docs.flutter.dev](https://docs.flutter.dev/ui/design/material)
- [Cupertino (iOS-style) widgets — docs.flutter.dev](https://docs.flutter.dev/ui/widgets/cupertino)
- [ColorScheme.fromSeed — api.flutter.dev](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)
- [ThemeData class — api.flutter.dev](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [Material 3 Design Kit — m3.material.io](https://m3.material.io/)
- [Human Interface Guidelines — developer.apple.com](https://developer.apple.com/design/human-interface-guidelines)
- [Platform adaptations — docs.flutter.dev](https://docs.flutter.dev/platform-integration/platform-adaptations)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo |
|---|---|---|
| [Aula 8 — Hot reload e hot restart](08-hot-reload-e-hot-restart.md) | [README](README.md) | [Módulo 06 — Widgets e Layouts](../06-widgets-e-layouts/README.md) |
