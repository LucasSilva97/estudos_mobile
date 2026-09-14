# Aula 3 — InheritedWidget

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Explicar como `Theme.of(context)` e `MediaQuery.of(context)` funcionam por dentro.
- Escrever um `InheritedWidget` na mão, com `of(context)`, `maybeOf` e `updateShouldNotify`.
- Diferenciar `dependOnInheritedWidgetOfExactType` de `getInheritedWidgetOfExactType`.
- Combinar `InheritedWidget` (distribuir) com `StatefulWidget` (mudar) no padrão de duas peças.
- Listar, com honestidade, por que ninguém escreve isso à mão hoje.
- Reconhecer que o Riverpod é **exatamente este mecanismo**, resolvido de forma genérica.

## ✅ Pré-requisitos

- [Aula 2 — Elevação de estado](02-elevacao-de-estado.md), com `EstadoFoco` e `copyWith` prontos.
- `BuildContext` — [Módulo 05, Aula 7](../05-introducao-ao-flutter/07-buildcontext.md).
- Herança e `@override` — [Módulo 03, Aula 4](../03-dart-intermediario/04-heranca-e-polimorfismo.md).
- Temas e `Theme.of` — [Módulo 06, Aula 7](../06-widgets-e-layouts/07-cores-temas-modo-escuro.md).

## 📖 Conceito

### O Flutter já resolveu isso — e você usa desde a primeira aula

Pare e repare em uma coisa estranha que você escreve há vários módulos:

```dart
Text('Hoje', style: Theme.of(context).textTheme.titleMedium)
```

Ninguém passou o tema para esse widget pelo construtor. Não houve *prop drilling*. O widget
pegou o tema **do ar** — mais precisamente, **do `context`**.

O mesmo acontece com `MediaQuery.of(context).size`, `Navigator.of(context).push(...)`,
`ScaffoldMessenger.of(context).showSnackBar(...)` e `DefaultTextStyle.of(context)`.

Todos esses `.of(context)` compartilham um mesmo mecanismo: **`InheritedWidget`**.

> **`InheritedWidget`** — um tipo especial de widget que **não desenha nada**. Ele envolve uma
> subárvore e oferece dados a **qualquer descendente**, a qualquer profundidade, sem passar por
> construtores. O Flutter guarda, em cada elemento da árvore, um mapa de qual `InheritedWidget`
> de cada tipo está acima dele — por isso a busca é rápida.

Essa é a resposta nativa ao *prop drilling* da Aula 1.

### As duas perguntas que o mecanismo responde

**1. Como um descendente acha o ancestral?**

```dart
final EscopoFoco? escopo = context.dependOnInheritedWidgetOfExactType<EscopoFoco>();
```

Esse método faz duas coisas ao mesmo tempo, e o nome diz as duas:

- **`...OfExactType<T>`** — sobe a árvore procurando o `InheritedWidget` **exatamente** do tipo
  `T` mais próximo (não aceita subclasse; é "exact type" mesmo).
- **`dependOn...`** — **registra uma dependência**: este widget quer ser reconstruído quando
  aquele `InheritedWidget` for trocado por outro.

É a segunda parte que faz a mágica acontecer. Sem ela, você leria o valor uma vez e nunca mais
seria avisado.

> Existe também `context.getInheritedWidgetOfExactType<T>()`, que **lê sem registrar
> dependência**. Use-o quando quiser consultar um valor dentro de um *callback* (um `onPressed`,
> por exemplo) sem que o widget passe a ser reconstruído. Guarde esta distinção: ela é a mesma
> diferença entre `ref.watch` e `ref.read` que você vai ver na Aula 5.

**2. Quando os dependentes devem ser reconstruídos?**

```dart
@override
bool updateShouldNotify(EscopoFoco anterior) => estado != anterior.estado;
```

Toda vez que o `InheritedWidget` é reconstruído, o Flutter chama `updateShouldNotify` passando a
**versão anterior** dele. Se você devolver `true`, todos os widgets que dependem dele são
reconstruídos. Se devolver `false`, ninguém é avisado — mesmo que o widget tenha sido
reconstruído.

Devolver `true` sempre funciona, mas desperdiça *rebuilds*. Devolver a comparação certa é o que
dá controle fino.

### O padrão de duas peças

Um `InheritedWidget` é **imutável**: todos os campos são `final`, e ele não tem `setState`. Então
ele **distribui**, mas não **muda**.

Para o dado poder mudar, o padrão clássico usa duas peças:

```text
ProvedorFoco (StatefulWidget)   ← guarda o estado e tem setState
      └── EscopoFoco (InheritedWidget)   ← distribui o estado para os descendentes
              └── MaterialApp
                      └── ... o app inteiro, incluindo rotas novas
```

Quando o `State` chama `setState`, ele reconstrói o `EscopoFoco` **com um objeto de estado
diferente**. O Flutter compara com o anterior via `updateShouldNotify` e avisa só quem depende.

Repare onde o `ProvedorFoco` foi colocado: **acima do `MaterialApp`**. Isso resolve o problema que
travou a Aula 2 — qualquer rota aberta pelo `Navigator` continua sendo descendente do escopo.

## 💡 Analogia

O *prop drilling* era o recado passando de mão em mão pelos andares. O `InheritedWidget` é um
**mural no saguão do prédio**: quem precisa da informação desce e lê; ninguém precisa carregar
recado. E existe uma lista de quem quer ser avisado — quando o mural é atualizado, só essas
pessoas recebem a notificação (`updateShouldNotify`).

O que o mural **não** faz: ele não escreve nada sozinho. Alguém com caneta (o `StatefulWidget`)
precisa trocar o cartaz. Daí as duas peças.

## 🧪 Exemplo mínimo

O menor `InheritedWidget` possível, com as três partes obrigatórias:

```dart
class ContadorEscopo extends InheritedWidget {
  const ContadorEscopo({
    required this.valor,
    required super.child,
    super.key,
  });

  final int valor;

  // 1. Busca conveniente, por convenção chamada `of`.
  static ContadorEscopo of(BuildContext context) {
    final ContadorEscopo? escopo =
        context.dependOnInheritedWidgetOfExactType<ContadorEscopo>();
    assert(escopo != null, 'Nenhum ContadorEscopo acima deste widget.');
    return escopo!;
  }

  // 2. Regra de notificação.
  @override
  bool updateShouldNotify(ContadorEscopo anterior) => valor != anterior.valor;
}

// 3. Uso, em qualquer profundidade, sem construtor:
class Mostrador extends StatelessWidget {
  const Mostrador({super.key});
  @override
  Widget build(BuildContext context) =>
      Text('${ContadorEscopo.of(context).valor}');
}
```

> **`assert`** — verificação que só roda em modo de depuração e é removida do *release*. Ela
> transforma um `null` silencioso numa mensagem clara na hora certa
> ([Módulo 02, Aula 6](../02-dart-basico/06-controle-de-fluxo.md)).

## 📱 Aplicando no Flutter

Vamos aplicar o padrão de duas peças ao `foco_estado`. Três mudanças:

1. Criar `lib/escopo_foco.dart` com `EstadoFoco` (que sai do `main.dart`), `EscopoFoco` e
   `ProvedorFoco`.
2. Colocar `ProvedorFoco` **acima** do `MaterialApp` no `runApp`.
3. Apagar **todos** os parâmetros de estado dos construtores das abas. Elas passam a ler
   `EscopoFoco.of(context)`.

O item 3 é o ganho visível: os construtores voltam a ter só `{super.key}`.

> ⚠️ Se você fez o teste `test/estado_foco_test.dart` da Aula 2, troque o `import` dele de
> `package:foco_estado/main.dart` para `package:foco_estado/escopo_foco.dart`, porque a classe
> `EstadoFoco` mudou de arquivo.

## 💻 Código completo

> **Arquivo:** `lib/escopo_foco.dart` (novo)
> **Como executar:** `flutter run` (ou `flutter run -d windows`)

```dart
import 'package:flutter/material.dart';

/// Objeto de estado imutável (veio da Aula 2).
@immutable
class EstadoFoco {
  const EstadoFoco({
    this.minutosHoje = 0,
    this.metaDiaria = 90,
    this.materias = const <String>['Dart', 'Flutter', 'Git'],
  });

  final int minutosHoje;
  final int metaDiaria;
  final List<String> materias;

  double get progresso =>
      metaDiaria == 0 ? 0 : (minutosHoje / metaDiaria).clamp(0.0, 1.0);

  int get faltam => (metaDiaria - minutosHoje).clamp(0, metaDiaria);

  EstadoFoco copyWith({int? minutosHoje, int? metaDiaria, List<String>? materias}) {
    return EstadoFoco(
      minutosHoje: minutosHoje ?? this.minutosHoje,
      metaDiaria: metaDiaria ?? this.metaDiaria,
      materias: materias ?? this.materias,
    );
  }
}

/// PEÇA 1 — distribui. Não desenha nada e não muda nada.
class EscopoFoco extends InheritedWidget {
  const EscopoFoco({
    required this.estado,
    required this.registrarSessao,
    required this.alterarMeta,
    required this.adicionarMateria,
    required super.child,
    super.key,
  });

  final EstadoFoco estado;
  final ValueChanged<int> registrarSessao;
  final ValueChanged<int> alterarMeta;
  final ValueChanged<String> adicionarMateria;

  /// Lê E registra dependência: o widget que chamar isto será reconstruído.
  static EscopoFoco of(BuildContext context) {
    final EscopoFoco? escopo = maybeOf(context);
    assert(escopo != null, 'EscopoFoco não encontrado acima deste widget.');
    return escopo!;
  }

  /// Versão que admite ausência — útil em testes e em widgets reutilizáveis.
  static EscopoFoco? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EscopoFoco>();

  @override
  bool updateShouldNotify(EscopoFoco anterior) {
    // Compara por identidade do objeto: copyWith sempre devolve outro objeto,
    // então "mudou o estado" é o mesmo que "é outro objeto".
    return !identical(estado, anterior.estado);
  }
}

/// PEÇA 2 — guarda e muda. Fica ACIMA do MaterialApp.
class ProvedorFoco extends StatefulWidget {
  const ProvedorFoco({required this.child, super.key});

  final Widget child;

  @override
  State<ProvedorFoco> createState() => _ProvedorFocoState();
}

class _ProvedorFocoState extends State<ProvedorFoco> {
  EstadoFoco _estado = const EstadoFoco();

  void _registrarSessao(int minutos) => setState(
      () => _estado = _estado.copyWith(minutosHoje: _estado.minutosHoje + minutos));

  void _alterarMeta(int meta) =>
      setState(() => _estado = _estado.copyWith(metaDiaria: meta));

  void _adicionarMateria(String nome) => setState(() =>
      _estado = _estado.copyWith(materias: <String>[..._estado.materias, nome]));

  @override
  Widget build(BuildContext context) {
    return EscopoFoco(
      estado: _estado,
      registrarSessao: _registrarSessao,
      alterarMeta: _alterarMeta,
      adicionarMateria: _adicionarMateria,
      child: widget.child,
    );
  }
}
```

> **Arquivo:** `lib/main.dart` (substitui o da Aula 2)
> **Como executar:** `flutter run`

```dart
import 'package:flutter/material.dart';

import 'escopo_foco.dart';

void main() {
  // O provedor fica ACIMA do MaterialApp: rotas novas continuam dentro do escopo.
  runApp(const ProvedorFoco(child: AppFoco()));
}

class AppFoco extends StatelessWidget {
  const AppFoco({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF3F51B5)),
      home: const CascaFoco(),
    );
  }
}

class CascaFoco extends StatefulWidget {
  const CascaFoco({super.key});

  @override
  State<CascaFoco> createState() => _CascaFocoState();
}

class _CascaFocoState extends State<CascaFoco> {
  int _abaAtual = 0;

  @override
  Widget build(BuildContext context) {
    // Nenhum parâmetro de estado: as abas se viram sozinhas.
    const List<Widget> abas = <Widget>[AbaHoje(), AbaMaterias(), AbaAjustes()];

    return Scaffold(
      appBar: AppBar(title: const Text('Foco')),
      body: IndexedStack(index: _abaAtual, children: abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (int i) => setState(() => _abaAtual = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Hoje'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Matérias'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class AbaHoje extends StatelessWidget {
  const AbaHoje({super.key});

  @override
  Widget build(BuildContext context) {
    final EstadoFoco estado = EscopoFoco.of(context).estado;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('${estado.minutosHoje} min',
            style: Theme.of(context).textTheme.displaySmall),
        Text('Meta: ${estado.metaDiaria} min · faltam ${estado.faltam} min'),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: estado.progresso),
        const SizedBox(height: 16),
        const LinhaDeBotoes(), // <- sem nenhum parâmetro
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const TelaSessao()),
          ),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Abrir sessão em outra tela'),
        ),
      ],
    );
  }
}

class LinhaDeBotoes extends StatelessWidget {
  const LinhaDeBotoes({super.key});

  @override
  Widget build(BuildContext context) {
    final EscopoFoco escopo = EscopoFoco.of(context);
    return Row(
      children: <Widget>[
        for (final int m in <int>[25, 50])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: FilledButton(
                onPressed: () => escopo.registrarSessao(m),
                child: Text('+$m min'),
              ),
            ),
          ),
      ],
    );
  }
}

/// A MESMA rota da Aula 2 — agora ela enxerga o estado.
class TelaSessao extends StatelessWidget {
  const TelaSessao({super.key});

  @override
  Widget build(BuildContext context) {
    final EscopoFoco escopo = EscopoFoco.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sessão')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Hoje: ${escopo.estado.minutosHoje} min'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => escopo.registrarSessao(15),
              child: const Text('Registrar 15 min daqui'),
            ),
          ],
        ),
      ),
    );
  }
}

class AbaMaterias extends StatelessWidget {
  const AbaMaterias({super.key});

  @override
  Widget build(BuildContext context) {
    final EscopoFoco escopo = EscopoFoco.of(context);
    final List<String> materias = escopo.estado.materias;

    return Column(
      children: <Widget>[
        Text('Você já estudou ${escopo.estado.minutosHoje} min hoje.'),
        Expanded(
          child: ListView.separated(
            itemCount: materias.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int i) =>
                ListTile(title: Text(materias[i])),
          ),
        ),
        FilledButton.tonal(
          onPressed: () => escopo.adicionarMateria('Matéria ${materias.length + 1}'),
          child: const Text('Adicionar matéria'),
        ),
      ],
    );
  }
}

class AbaAjustes extends StatelessWidget {
  const AbaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    final EscopoFoco escopo = EscopoFoco.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Meta diária: ${escopo.estado.metaDiaria} min'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: <Widget>[
            for (final int opcao in <int>[60, 90, 120])
              OutlinedButton(
                onPressed: () => escopo.alterarMeta(opcao),
                child: Text('$opcao min'),
              ),
          ],
        ),
      ],
    );
  }
}
```

Rode e abra **Abrir sessão em outra tela**. O número aparece, e o botão de 15 minutos funciona.
O limite que travou a Aula 2 desapareceu.

## 🔍 Explicando o código

### 1. `const List<Widget> abas` — as abas agora são constantes

```dart
const List<Widget> abas = <Widget>[AbaHoje(), AbaMaterias(), AbaAjustes()];
```

Como nenhuma aba recebe parâmetro variável, a lista inteira virou `const`. O Flutter reaproveita
o **mesmo objeto** widget a cada `build` de `CascaFoco` e pula a reconstrução dessa subárvore
quando nada mudou. Esse ganho de desempenho só foi possível **porque** o dado deixou de viajar
por construtor. É o assunto de [13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md).

### 2. `identical` em `updateShouldNotify`

```dart
return !identical(estado, anterior.estado);
```

`identical(a, b)` pergunta "são o mesmo objeto na memória?". Como todo `copyWith` devolve um
objeto novo, isso equivale a "o estado mudou". É uma comparação de custo constante, muito mais
barata que comparar campo a campo — e só é correta **porque** `EstadoFoco` é imutável.

Se a classe implementasse `==` de valor, você poderia escrever `estado != anterior.estado` para
evitar notificar quando o conteúdo é igual. Você vai implementar `==` na Aula 6.

### 3. Por que `ProvedorFoco` fica acima do `MaterialApp`

```dart
runApp(const ProvedorFoco(child: AppFoco()));
```

O `Navigator` que atende `Navigator.of(context).push` mora **dentro** do `MaterialApp`. Rotas
empilhadas por ele são descendentes do `MaterialApp`. Colocando o escopo acima de tudo, qualquer
rota — inclusive diálogos e *bottom sheets* — continua dentro dele.

### 4. Ler dados e ler ações no mesmo `of`

`EscopoFoco` carrega os dados (`estado`) **e** as ações (`registrarSessao`, ...). Funciona, mas
tem um efeito colateral: `LinhaDeBotoes` só quer **agir**, nunca precisa do valor — e mesmo assim
`dependOnInheritedWidgetOfExactType` registrou dependência, então ela é reconstruída a cada
mudança de minutos.

Separar "dados" de "ações" em **dois** `InheritedWidget` resolveria isso. E é aí que o problema
começa a ficar cansativo — veja a seção seguinte.

### 5. `of` versus `maybeOf`

`of` devolve não-nulo e falha com mensagem clara se o escopo estiver faltando; `maybeOf` devolve
`EscopoFoco?`. A dupla é a convenção do próprio SDK: existem `Theme.of`/`Theme.maybeOf`,
`Navigator.of`/`Navigator.maybeOf`, `ScaffoldMessenger.of`/`.maybeOf`.

### 6. Por que ninguém escreve isso à mão hoje

Tudo o que você viu funciona. O problema é o custo por dado:

| Necessidade | O que você teria que escrever |
|---|---|
| Separar dados de ações | mais um `InheritedWidget` + mais um `of` |
| Estado por funcionalidade (matérias, sessões, metas) | um par `Provedor`+`Escopo` para **cada** |
| Estado assíncrono (carregando/erro/dados) | você mesmo modela os três casos, na mão |
| Um estado que depende de outro | encadear `StatefulWidget`s aninhados |
| Descartar o estado quando ninguém mais usa | você mesmo controla, no `dispose` |
| Testar a lógica sem árvore | impossível: o estado mora num `State` |
| Trocar a fonte de dados num teste | impossível sem reconstruir a árvore inteira |

Cada linha dessa tabela é um problema que o Riverpod resolve de forma genérica. E ele resolve
**usando exatamente este mecanismo**: o `ProviderScope` que você vai escrever na Aula 5 é um
`InheritedWidget`, e `ref.watch` termina chamando algo equivalente a
`dependOnInheritedWidgetOfExactType`. Você não está trocando de paradigma — está pegando uma
implementação pronta, genérica e testável do paradigma que acabou de aprender.

### 7. Parentes úteis no SDK

- **`InheritedNotifier<T extends Listenable>`** — notifica quando o objeto que ele carrega avisa,
  em vez de quando o widget é reconstruído.
- **`InheritedModel<T>`** — permite depender de **aspectos** específicos do dado, de modo que uma
  mudança em um aspecto não reconstrói quem depende de outro.

Saber que existem já basta; este curso não os usa.

## 🤖🍎 Android × iOS

`MediaQuery` é o `InheritedWidget` mais visivelmente diferente entre as plataformas, porque ele
entrega as medidas reais do aparelho:

- 🍎 **iOS** — `MediaQuery.paddingOf(context).top` é grande em iPhones com recorte na tela
  (*notch* ou *Dynamic Island*), e `padding.bottom` é maior que zero por causa da **barra de
  gesto** (*home indicator*). Se você desenhar um botão colado no fundo sem `SafeArea`, ele fica
  sob essa barra.
- 🤖 **Android** — o `padding.top` corresponde à barra de status e o `padding.bottom` varia entre
  0 (navegação por três botões) e alguns pixels (navegação por gestos).
- Em ambos, a pessoa pode aumentar a fonte do sistema nas configurações de acessibilidade. Isso
  chega ao seu app por `MediaQuery.textScalerOf(context)` e é um `InheritedWidget` como qualquer
  outro: se o texto sair cortado, o motivo está aqui.

> 🪟 **No seu Windows, o que dá para fazer:** rodar em `-d windows` ou `-d chrome` e simular
> tamanhos com o DevTools; e, com o emulador Android instalado, ver o comportamento 🤖 real.
> **O que não dá:** medir o recorte de um iPhone de verdade. Você **não** consegue rodar o
> simulador iOS sem um Mac — isso está detalhado em
> [15 — Por que exige macOS](../15-build-ios/01-por-que-exige-macos.md). Escreva o layout com
> `SafeArea` e confie nela: é justamente para isso que ela existe.

Prefira `MediaQuery.sizeOf(context)`, `MediaQuery.paddingOf(context)` e
`MediaQuery.textScalerOf(context)` em vez de `MediaQuery.of(context)`: as versões específicas
registram dependência **só naquele aspecto**, então o teclado abrindo não reconstrói um widget
que só queria a largura.

## ⚠️ Erros comuns

**1. Chamar `of(context)` com o `context` errado.**
Se você chamar `EscopoFoco.of(context)` **dentro** do `build` do próprio `ProvedorFoco`, o
`context` ainda está acima do `EscopoFoco` e a busca falha. O `context` só enxerga o que está
**acima** dele.

**2. Esquecer o `updateShouldNotify`.**
É `abstract`: sem ele o código não compila. Mas devolver `true` fixo compila — e reconstrói todos
os dependentes a cada `build` do provedor, mesmo quando nada mudou.

**3. Achar que `InheritedWidget` guarda estado.**
Ele não guarda: todos os campos são `final`. Sem um `StatefulWidget` acima, o dado nunca muda.

**4. Chamar `of(context)` dentro de `initState`.**

```dart
@override
void initState() {
  super.initState();
  final EscopoFoco e = EscopoFoco.of(context); // ERRO em tempo de execução
}
```

Em `initState` o elemento ainda não está totalmente ligado à árvore para registrar dependências.
O lugar certo é `didChangeDependencies` — ou o próprio `build`.

**5. Depender do escopo só para disparar ação.**
`LinhaDeBotoes` usa `of` só para chamar `registrarSessao`, mas paga o preço de ser reconstruída a
cada mudança de estado. Sem separar em outro `InheritedWidget`, não há como evitar. Guarde esse
incômodo: ele é literalmente o motivo de existir `ref.read`.

## 🛠️ Exercício guiado

**Passo 1.** Rode e confirme que `TelaSessao` lê e escreve o estado.

```powershell
flutter run -d windows
```

**Passo 2.** Coloque `debugPrint('build: LinhaDeBotoes');` no `build` de `LinhaDeBotoes` e toque
em **+25 min**. Confirme no terminal que ela é reconstruída mesmo sem usar nenhum dado.

**Passo 3.** Crie um segundo `InheritedWidget` chamado `AcoesFoco`, contendo **apenas** os três
*callbacks*, e coloque-o entre `EscopoFoco` e `child`. O `updateShouldNotify` dele devolve
`false`, porque as funções nunca mudam. Faça `LinhaDeBotoes` usar `AcoesFoco.of(context)` e rode
o Passo 2 de novo: a linha `build: LinhaDeBotoes` some.

**Passo 4.** Troque `EscopoFoco.of(context)` por `EscopoFoco.maybeOf(context)` em `AbaAjustes` e
trate o `null` com um `Text('Sem escopo')`. Depois remova o `ProvedorFoco` do `runApp` e veja a
diferença entre a falha do `assert` (com `of`) e a degradação silenciosa (com `maybeOf`).
Devolva o `ProvedorFoco` ao lugar no fim.

**Passo 5.** Conte: para dois tipos de conteúdo (dados e ações) você precisou de **duas** classes
`InheritedWidget` e **duas** funções `of`. Escreva quantas classes você precisaria para cinco
funcionalidades independentes do app Foco.

```powershell
flutter analyze
```

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

## 🏆 Desafio opcional

Implemente `EscopoFoco` como `InheritedModel<String>` em vez de `InheritedWidget`, com os
aspectos `'minutos'`, `'meta'` e `'materias'`. Sobrescreva
`updateShouldNotifyDependent(EscopoFoco anterior, Set<String> aspectos)` para notificar apenas
quem pediu o aspecto que mudou, e consuma com
`InheritedModel.inheritFrom<EscopoFoco>(context, aspect: 'meta')`.

Depois compare, por `debugPrint`, quantos *rebuilds* você economizou — e quanto código a mais
precisou escrever para isso.

## 📌 Resumo

- `InheritedWidget` é o mecanismo **nativo** do Flutter para entregar dados a qualquer
  descendente sem *prop drilling*. `Theme.of`, `MediaQuery.of` e `Navigator.of` são ele.
- `context.dependOnInheritedWidgetOfExactType<T>()` **busca e registra dependência**;
  `context.getInheritedWidgetOfExactType<T>()` **só busca**. É a mesma distinção de
  `ref.watch` × `ref.read`.
- `updateShouldNotify(anterior)` decide quem é reconstruído. Com estado imutável,
  `!identical(estado, anterior.estado)` é uma regra barata e correta.
- Um `InheritedWidget` é imutável: ele **distribui**, não **muda**. O padrão de duas peças
  (`StatefulWidget` + `InheritedWidget`) resolve isso; colocado acima do `MaterialApp`, alcança
  também as rotas.
- Ninguém escreve isso à mão hoje porque o custo cresce por dado: um par de classes por
  funcionalidade, nenhum suporte a assíncrono, nenhum descarte automático, nenhum teste sem
  árvore. O Riverpod é essa mesma ideia, resolvida de forma genérica.

## ☑️ Checklist de domínio

- [ ] Explico o que `Theme.of(context)` faz por dentro.
- [ ] Escrevi um `InheritedWidget` com `of`, `maybeOf` e `updateShouldNotify` que funciona.
- [ ] Sei a diferença entre `dependOn...` e `get...` e digo quando usar cada um.
- [ ] Entendo por que o `InheritedWidget` precisa de um `StatefulWidget` acima dele.
- [ ] Sei por que o provedor fica acima do `MaterialApp`.
- [ ] Fiz o Passo 3 e vi o *rebuild* de `LinhaDeBotoes` desaparecer.
- [ ] Sei citar três limitações que fariam eu não escrever isso à mão num app real.
- [ ] `flutter analyze` sem avisos.

## 📚 Referências oficiais

- [Flutter — InheritedWidget (API)](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)
- [Flutter — BuildContext.dependOnInheritedWidgetOfExactType](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html)
- [Flutter — MediaQuery (API)](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)
- [Flutter — InheritedModel (API)](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html)
- [Flutter — SafeArea (API)](https://api.flutter.dev/flutter/widgets/SafeArea-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Elevação de estado](02-elevacao-de-estado.md) | [README](README.md) | [Por que Riverpod](04-por-que-riverpod.md) |
