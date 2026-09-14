# Aula 2 — Rotas nomeadas

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que espalhar `MaterialPageRoute` pelo app vira um problema de manutenção.
- Criar uma classe `Rotas` com **constantes** para todos os caminhos do aplicativo.
- Resolver rotas com **`onGenerateRoute`** e um `switch`, devolvendo a `Route` certa para cada nome.
- Definir a tela inicial com `initialRoute` em vez de `home:`.
- Tratar **rota desconhecida** sem deixar o app quebrar.
- Comparar `routes:` (mapa) com `onGenerateRoute` e justificar por que o curso usa o segundo.

## ✅ Pré-requisitos

- [Aula 1 — Navigator: a pilha](01-navigator-a-pilha.md) e o projeto `foco_navegacao` rodando.
- [Módulo 02 — var, final e const](../02-dart-basico/03-var-final-const.md) — as constantes de rota
  são `static const String`.
- [Módulo 04 — Patterns e switch](../04-dart-avancado/05-patterns-e-switch.md) — o `switch` do
  `onGenerateRoute`.
- [Módulo 03 — Abstratas e interfaces](../03-dart-intermediario/05-abstratas-e-interfaces.md) — a
  classe `Rotas` usa modificadores de classe do Dart 3.

---

## 📖 Conceito

### O problema de escrever a rota na mão toda vez

Na aula 1, cada navegação era assim:

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(builder: (context) => const NovaMateriaScreen()),
);
```

Funciona. Mas repare no que acontece quando o app cresce:

| Problema | Consequência real |
|---|---|
| A tela de destino é **importada** por quem navega | `lista_materias_screen.dart` passa a conhecer `materia_form_screen.dart`, que conhece outra… as telas viram um nó |
| Não existe **lista** das telas do app | Ninguém consegue responder "quantas telas este app tem?" sem abrir 30 arquivos |
| Rotas não têm **nome** | O `NavigatorObserver` da aula 1 imprimia `null`; logs, analytics e testes ficam cegos |
| Mudar uma tela de lugar | Você edita todos os arquivos que a empilhavam |
| Abrir a mesma tela de 5 lugares | Cinco cópias do mesmo `MaterialPageRoute`, e uma delas vai ficar diferente |

### A solução: dar nome às rotas

Uma **rota nomeada** (*named route*) é uma rota identificada por um texto, como `'/materia/form'`.
Quem navega diz apenas o **nome**; quem sabe construir a tela é um único lugar central.

```dart
Navigator.of(context).pushNamed(Rotas.materiaForm);
```

Esse texto segue a convenção de caminho da web: começa com `/`, usa minúsculas e separa níveis com
`/`. `'/'` é a raiz — a tela inicial.

> ⚠️ **Nunca escreva o texto da rota solto no meio do código.** `pushNamed(context, '/materia/form')`
> compila mesmo se você digitar `'/materia/from'`, e o erro só aparece em tempo de execução. Com uma
> constante (`Rotas.materiaForm`), o **compilador** pega o erro de digitação na hora.

### As duas formas de registrar rotas no `MaterialApp`

**Forma 1 — `routes:` (um mapa).**

```dart
MaterialApp(
  initialRoute: '/',
  routes: <String, WidgetBuilder>{
    '/': (context) => const ListaMateriasScreen(),
    '/estatisticas': (context) => const EstatisticasScreen(),
  },
)
```

Simples, mas limitada: o `WidgetBuilder` do mapa **só recebe o `BuildContext`**. Ele não vê os
argumentos da rota (você precisa buscá-los à parte, sem tipo), não decide se a rota é
`fullscreenDialog`, e não deixa você escolher entre `MaterialPageRoute` e `CupertinoPageRoute`.

**Forma 2 — `onGenerateRoute:` (uma função).**

```dart
MaterialApp(
  initialRoute: Rotas.home,
  onGenerateRoute: Rotas.gerar,
)
```

`onGenerateRoute` recebe um **`RouteSettings`** — um objeto com dois campos: `name` (o texto da
rota) e `arguments` (o que você mandou junto, do tipo `Object?`). E devolve a `Route` que quiser,
construída como quiser.

| Critério | `routes:` (mapa) | `onGenerateRoute:` (função) |
|---|---|---|
| Argumentos tipados | ❌ só via `ModalRoute.of(context)`, sem tipo | ✅ você lê `settings.arguments` e valida |
| `fullscreenDialog` | ❌ | ✅ |
| Escolher o tipo de `Route` por plataforma | ❌ | ✅ |
| Rotas com padrão (ex.: `/materia/123`) | ❌ | ✅ |
| Um lugar só para log/analytics de navegação | ❌ | ✅ |
| Simplicidade para 2 telas sem argumento | ✅ | Igual |

> **Decisão do curso:** usamos **`onGenerateRoute` com `switch`**. Ele vem no SDK, não adiciona
> dependência, e é o que permite a passagem de argumentos tipados da
> [aula 3](03-argumentos-e-resultados.md). O `go_router` — que resolve isso de outro jeito — é
> assunto da [aula 9, opcional](09-go-router-opcional.md).

### `onUnknownRoute`: a rede de proteção

Se `onGenerateRoute` devolver `null` para um nome, o Flutter chama `onUnknownRoute`. Se **esse**
também não existir, o app lança uma exceção e o usuário vê a tela vermelha de erro.

Um app de verdade nunca deixa isso acontecer. Nesta aula você monta uma `RotaDesconhecidaScreen`
que mostra o nome pedido e oferece um caminho de volta ao início — o equivalente móvel de uma
página "404".

---

## 💡 Analogia

Pense num prédio de escritórios. Na aula 1, cada pessoa que queria ir a uma sala carregava consigo
o mapa completo do caminho: "suba 3 andares, vire à direita, terceira porta". Se a sala mudasse de
lugar, todos os mapas ficavam errados.

Com rotas nomeadas, existe **uma recepção**. Você chega e diz apenas: "quero a sala Financeiro". A
recepção — o `onGenerateRoute` — é quem sabe onde fica. Se o Financeiro mudar de andar, você muda a
informação **na recepção**, e ninguém mais precisa saber.

E se alguém pedir uma sala que não existe, a recepção não deixa a pessoa perdida no corredor: ela
avisa educadamente e mostra o caminho de volta. Esse é o `onUnknownRoute`.

---

## 🧪 Exemplo mínimo

A menor `onGenerateRoute` possível, com duas rotas e um caso padrão:

```dart
Route<dynamic> gerar(RouteSettings configuracoes) {
  switch (configuracoes.name) {
    case '/':
      return MaterialPageRoute<void>(
        settings: configuracoes,
        builder: (_) => const ListaMateriasScreen(),
      );
    case '/estatisticas':
      return MaterialPageRoute<void>(
        settings: configuracoes,
        builder: (_) => const EstatisticasScreen(),
      );
    default:
      return MaterialPageRoute<void>(
        settings: configuracoes,
        builder: (_) => RotaDesconhecidaScreen(nome: configuracoes.name),
      );
  }
}
```

O detalhe que muita gente esquece: **repassar `settings: configuracoes`**. É isso que faz a rota
carregar o próprio nome — e, sem isso, `route.settings.name` volta a ser `null` no observador, nos
logs e nos testes.

---

## 📱 Aplicando no Flutter

Agora vamos reorganizar o `foco_navegacao`. Duas mudanças acontecem juntas:

1. As telas saem do `main.dart` e vão para **pastas por feature** (funcionalidade) — a mesma
   organização do projeto final.
2. Todas as navegações passam a usar **nomes**.

A `AberturaScreen` da aula 1 sai do app: ela existia só para demonstrar `pushReplacement`. Splash de
verdade em Flutter é **nativa**, feita com `flutter_native_splash`, e é assunto do
[módulo 14, aula 4](../14-build-android/04-splash-screen.md).

Crie as pastas e mova os arquivos:

```text
lib/
├── main.dart
├── core/
│   └── rotas/
│       ├── rotas.dart
│       └── rota_desconhecida_screen.dart
└── features/
    ├── materias/
    │   ├── domain/materia.dart
    │   └── presentation/
    │       ├── lista_materias_screen.dart
    │       ├── detalhe_materia_screen.dart
    │       └── materia_form_screen.dart
    └── estatisticas/
        └── presentation/estatisticas_screen.dart
```

O conteúdo das telas é o mesmo da aula 1 — só mudaram de arquivo. `NovaMateriaScreen` foi renomeada
para `MateriaFormScreen` (é o nome que ela terá no projeto final), e `EstatisticasScreen` agora
mostra o total de **todas** as matérias, sem depender de uma matéria específica. Cada arquivo de
tela começa com os imports de que precisa, por exemplo:

```dart
import 'package:flutter/material.dart';

import '../domain/materia.dart';
```

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/core/rotas/rotas.dart`
> **Como executar:** `flutter run` (dentro da pasta `foco_navegacao`)

```dart
import 'package:flutter/material.dart';

import '../../features/estatisticas/presentation/estatisticas_screen.dart';
import '../../features/materias/presentation/lista_materias_screen.dart';
import '../../features/materias/presentation/materia_form_screen.dart';
import 'rota_desconhecida_screen.dart';

/// Central de rotas do app.
///
/// `abstract final class` (Dart 3): ninguém consegue instanciar nem herdar.
/// É só um agrupador de constantes e de uma função estática.
abstract final class Rotas {
  /// Tela inicial: a lista de matérias.
  static const String home = '/';

  /// Formulário de criar/editar matéria (abre como diálogo em tela cheia).
  static const String materiaForm = '/materia/form';

  /// Estatísticas gerais de estudo.
  static const String estatisticas = '/estatisticas';

  /// Chamada pelo MaterialApp a cada `pushNamed`.
  static Route<dynamic> gerar(RouteSettings configuracoes) {
    switch (configuracoes.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => const ListaMateriasScreen(),
        );

      case materiaForm:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          fullscreenDialog: true, // sobe de baixo e ganha o X de fechar
          builder: (_) => const MateriaFormScreen(),
        );

      case estatisticas:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => const EstatisticasScreen(),
        );

      default:
        return desconhecida(configuracoes);
    }
  }

  /// Usada tanto pelo `default` acima quanto pelo `onUnknownRoute`.
  static Route<dynamic> desconhecida(RouteSettings configuracoes) {
    return MaterialPageRoute<void>(
      settings: configuracoes,
      builder: (_) => RotaDesconhecidaScreen(nome: configuracoes.name),
    );
  }
}
```

> **Arquivo:** `foco_navegacao/lib/core/rotas/rota_desconhecida_screen.dart`

```dart
import 'package:flutter/material.dart';

import 'rotas.dart';

/// O "404" do aplicativo: mostrada quando alguém pede uma rota que não existe.
class RotaDesconhecidaScreen extends StatelessWidget {
  const RotaDesconhecidaScreen({required this.nome, super.key});

  /// Pode ser nulo: o Flutter permite uma rota sem nome.
  final String? nome;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tela não encontrada')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.explore_off_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Não encontramos a tela "${nome ?? 'sem nome'}".',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Isso costuma acontecer quando um link antigo aponta para uma tela que mudou '
                'de nome. Você pode voltar ao início sem perder nada.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(Rotas.home, (_) => false),
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      );
}
```

> **Arquivo:** `foco_navegacao/lib/main.dart`

```dart
import 'package:flutter/material.dart';

import 'core/rotas/rotas.dart';

void main() => runApp(const FocoNavegacaoApp());

class ObservadorDePilha extends NavigatorObserver {
  String _nome(Route<dynamic>? r) => r?.settings.name ?? 'sem nome';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('PUSH  -> ${_nome(route)}  (abaixo: ${_nome(previousRoute)})');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint('POP   <- ${_nome(route)}  (volta para: ${_nome(previousRoute)})');
  }
}

class FocoNavegacaoApp extends StatelessWidget {
  const FocoNavegacaoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Foco — Navegação',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
        ),
        navigatorObservers: <NavigatorObserver>[ObservadorDePilha()],
        initialRoute: Rotas.home,
        onGenerateRoute: Rotas.gerar,
        onUnknownRoute: Rotas.desconhecida,
      );
}
```

E, dentro de `lista_materias_screen.dart`, as navegações ficam assim:

```dart
// Antes (aula 1):
Navigator.of(context).push(
  MaterialPageRoute<void>(builder: (context) => const NovaMateriaScreen()),
);

// Agora:
Navigator.of(context).pushNamed(Rotas.materiaForm);
```

Para você **ver** a rota de erro funcionando, acrescente este botão na `AppBar` da lista:

```dart
actions: <Widget>[
  IconButton(
    tooltip: 'Testar rota inexistente',
    icon: const Icon(Icons.bug_report_outlined),
    onPressed: () => Navigator.of(context).pushNamed('/tela-que-nao-existe'),
  ),
],
```

Rode `flutter run` e confira o console — agora os nomes aparecem:

```text
PUSH  -> /  (abaixo: sem nome)
PUSH  -> /materia/form  (abaixo: /)
POP   <- /materia/form  (volta para: /)
PUSH  -> /tela-que-nao-existe  (abaixo: /)
```

---

## 🔍 Explicando o código

**`abstract final class Rotas`.** `abstract` impede instanciar (`Rotas()` não compila) e `final`
impede herdar. É a forma do Dart 3 de dizer "esta classe é só um agrupador de coisas estáticas".
Os modificadores de classe estão explicados no
[módulo 04, aula 6](../04-dart-avancado/06-sealed-classes.md).

**`static const String home = '/';`.** `const` significa constante de tempo de compilação. Por serem
constantes, elas podem ser usadas como `case` de um `switch` — que é exatamente o que o
`onGenerateRoute` faz.

**`switch (configuracoes.name)`.** `RouteSettings.name` é `String?`. Como os `case` cobrem só os
nomes conhecidos e existe um `default`, o `switch` está completo e seguro, inclusive para `null`.

**`settings: configuracoes`.** Repassa o nome e os argumentos para a rota criada. Sem isso: o
observador imprime `sem nome`, `ModalRoute.of(context)?.settings.arguments` volta vazio, e os testes
de navegação por nome não conseguem encontrar a rota.

**`fullscreenDialog: true` dentro do `case materiaForm`.** Aqui está a vantagem concreta sobre o
mapa `routes:`: a decisão de *como* a rota aparece mora junto da definição dela, e quem chama só
precisa saber o nome.

**`onGenerateRoute: Rotas.gerar`.** Repare que você passa a **função sem parênteses** — está
entregando a função em si, não o resultado dela. O Flutter a chama a cada `pushNamed`.

**`onUnknownRoute: Rotas.desconhecida`.** Segunda rede de proteção. O `default` do `switch` já
resolveria, mas `onUnknownRoute` também cobre o caso de `onGenerateRoute` devolver `null` — e deixa
a intenção explícita para quem lê o `main.dart`.

**`pushNamedAndRemoveUntil(Rotas.home, (_) => false)`.** Empilha a home e remove **todas** as rotas
anteriores (o predicado sempre devolve `false`). É o "recomeçar do zero" — perfeito para uma tela de
erro, e também para o botão "Sair" de um app com login.

**`initialRoute` × `home:`.** Os dois definem a primeira tela, e você usa **um ou outro**. Com
`initialRoute`, o Flutter pede a rota ao `onGenerateRoute` como qualquer outra — então a tela inicial
também ganha nome, aparece nos logs e pode ser testada.

---

## ⚠️ Erros comuns

**1. Usar `home:` e `initialRoute:` ao mesmo tempo.** O Flutter ignora o `initialRoute` e usa o
`home`. Se a tela inicial não é a que você esperava, procure um `home:` esquecido.

**2. Esquecer `settings: configuracoes`.** Tudo funciona visualmente, mas rota fica sem nome e os
argumentos da [aula 3](03-argumentos-e-resultados.md) chegam nulos. É um bug silencioso.

**3. Digitar o nome da rota à mão.**

```dart
Navigator.pushNamed(context, '/materia/from'); // erro de digitação
```

Compila, roda, e o usuário cai na tela de rota desconhecida. Use sempre `Rotas.materiaForm`.

**4. `Could not find a generator for route RouteSettings("/x", null)`.** Mensagem real do Flutter
quando não existe `onGenerateRoute`, nem entrada no mapa `routes:`, nem `onUnknownRoute`. A correção
é o `default` do `switch`.

**5. Achar que o nome com `/` cria hierarquia automática.** `'/materia/form'` **não** empilha
`'/materia'` antes. É apenas um texto; a hierarquia de verdade é a pilha, e quem empilha é você.

---

## 🛠️ Exercício guiado

**Passo 1.** Acrescente uma quarta rota ao app, chamada `Rotas.sobre = '/sobre'`, apontando para uma
tela nova `lib/features/sobre/presentation/sobre_screen.dart` com o nome do app e a versão.

**Passo 2.** Registre o `case` dela no `switch` de `Rotas.gerar`, lembrando do
`settings: configuracoes`.

**Passo 3.** Adicione na `AppBar` da lista um `IconButton` com `Icons.info_outline` que chama
`Navigator.of(context).pushNamed(Rotas.sobre)`.

**Passo 4.** Rode e confirme no console: `PUSH  -> /sobre  (abaixo: /)`.

**Passo 5.** Agora **quebre de propósito**: troque, só no `IconButton`, `Rotas.sobre` pelo texto
`'/sobre-o-app'`. Rode de novo. Você deve cair na `RotaDesconhecidaScreen` mostrando o nome pedido —
e não numa tela vermelha de erro. Depois desfaça a mudança.

**Passo 6.** Responda por escrito: por que o passo 5 **não** teria sido pego pelo compilador, e o
que muda quando você usa a constante?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Faça os exercícios de **Aplicação** que pedem para centralizar rotas, e o de **Correção de bugs**
com a rota sem `settings`.

---

## 🏆 Desafio opcional

Faça o `Rotas.gerar` registrar cada navegação num log padronizado, sem repetir código em cada
`case`. Dica: extraia um método auxiliar
`static MaterialPageRoute<T> _rota<T>(RouteSettings s, WidgetBuilder builder, {bool dialogo = false})`
que cria a rota, aplica `settings`, aplica `fullscreenDialog` e chama `debugPrint` uma única vez.
Depois responda: quantas linhas o `switch` perdeu, e ficou mais fácil ou mais difícil de ler?

---

## 📌 Resumo

- Rota nomeada é uma rota identificada por um texto, no estilo de caminho web: `'/materia/form'`.
- Centralizar os nomes numa classe `Rotas` com `static const String` faz o **compilador** pegar erro
  de digitação.
- `routes:` (mapa) é simples mas limitado: não vê argumentos tipados, não faz `fullscreenDialog`,
  não escolhe o tipo de rota.
- `onGenerateRoute` recebe um `RouteSettings` (`name` + `arguments`) e devolve a `Route` que você
  quiser — é a escolha do curso.
- **Sempre** repasse `settings: configuracoes` na rota criada, ou a rota fica sem nome e sem
  argumentos.
- `initialRoute` define a tela inicial passando pelo `onGenerateRoute`; use-o **no lugar** de `home:`.
- `onUnknownRoute` + um `default` no `switch` garantem que nome errado leve a uma tela de erro
  amigável, nunca à tela vermelha.
- `pushNamedAndRemoveUntil(rota, (_) => false)` recomeça a pilha do zero.

---

## ☑️ Checklist de domínio

- [ ] Escrevo uma classe `Rotas` com constantes e uma função `gerar` estática.
- [ ] Explico por que `Rotas.materiaForm` é melhor que `'/materia/form'` escrito no meio do código.
- [ ] Digo duas coisas que `onGenerateRoute` faz e o mapa `routes:` não faz.
- [ ] Nunca esqueço `settings: configuracoes` ao criar a `Route`.
- [ ] Sei o que acontece se `home:` e `initialRoute:` existirem juntos.
- [ ] Tenho uma tela de rota desconhecida com caminho de volta ao início.
- [ ] Uso `pushNamedAndRemoveUntil` e explico o predicado `(_) => false`.
- [ ] Meu console mostra o nome da rota em cada `PUSH` e `POP`.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Navigate with named routes — docs.flutter.dev](https://docs.flutter.dev/cookbook/navigation/named-routes)
- [RouteSettings class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/RouteSettings-class.html)
- [MaterialApp.onGenerateRoute — api.flutter.dev](https://api.flutter.dev/flutter/material/MaterialApp/onGenerateRoute.html)
- [MaterialApp.onUnknownRoute — api.flutter.dev](https://api.flutter.dev/flutter/material/MaterialApp/onUnknownRoute.html)
- [Class modifiers — dart.dev](https://dart.dev/language/class-modifiers)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Navigator: a pilha](01-navigator-a-pilha.md) | [README](README.md) | [Aula 3 — Argumentos e resultados](03-argumentos-e-resultados.md) |
