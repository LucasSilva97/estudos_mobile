# Aula 4 — Por que Riverpod

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Listar os **quatro problemas** que sobraram depois do `setState`, da elevação de estado e do
  `InheritedWidget`.
- Comparar **Riverpod**, **Provider**, **BLoC** e **`setState`** de forma honesta — incluindo o que
  cada um custa.
- Explicar por que o Riverpod **não depende de `BuildContext`**, e por que isso elimina uma classe
  inteira de erro.
- Justificar a decisão do curso: **Riverpod 3.4.3 sem *code generation***.
- Reconhecer as APIs **legadas** do Riverpod (`StateProvider`, `StateNotifierProvider`,
  `ChangeNotifierProvider`) e saber por que não usá-las.
- Decidir, com critérios, quando **não** usar Riverpod.

## ✅ Pré-requisitos

- [Aula 1 — O problema do estado](01-o-problema-do-estado.md) — os quatro sintomas do *prop
  drilling*.
- [Aula 2 — Elevação de estado](02-elevacao-de-estado.md) — valor desce, callback sobe, e onde isso
  quebra.
- [Aula 3 — InheritedWidget](03-inheritedwidget.md) — **essencial**: o Riverpod é, por dentro, uma
  camada sobre `InheritedWidget`. Sem entender o de baixo, o de cima vira mágica.
- [Módulo 06, aula 12 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) — o
  `sealed class` de estado que você escreveu lá é quase o `AsyncValue`.

---

## 📖 Conceito

### Onde paramos

Nas três aulas anteriores você percorreu o caminho inteiro na mão:

| Aula | Técnica | O que resolveu | O que **não** resolveu |
|---|---|---|---|
| 1 | `setState` | Estado de um widget | Compartilhar entre telas |
| 2 | Elevação de estado | Compartilhar entre irmãos | Passar por 5 níveis (*prop drilling*) |
| 3 | `InheritedWidget` | Acesso de qualquer profundidade | Escrever tudo na mão, testar, combinar estados |

E o `InheritedWidget` da aula 3 funciona. O problema é o que ele custa:

```dart
// Para UM estado compartilhado, na aula 3, você escreveu:
class EscopoFoco extends InheritedWidget { ... }        // ~30 linhas
class _EscopoFocoState extends State<EscopoFoco> { ... } // ~40 linhas
// + o of(context)
// + o updateShouldNotify
// + um StatefulWidget por cima para guardar o estado
```

Setenta linhas por estado. Com oito estados no app, são 560 linhas de infraestrutura que não fazem
nada de útil para o usuário — e que você precisa manter.

### Os quatro problemas que sobraram

**1. Todo widget que lê o estado precisa de `BuildContext`.**

```dart
final int sessoes = EscopoFoco.of(context).sessoes;
```

Isso significa que você **não consegue** ler o estado:

- dentro do `initState` (erro da [aula 7 do Módulo 05](../05-introducao-ao-flutter/07-buildcontext.md));
- depois de um `await`, sem checar `mounted`;
- em um teste, sem montar uma árvore de widgets inteira;
- em código que não é widget nenhum (uma classe de serviço, por exemplo).

**2. Reconstrói demais.** O `updateShouldNotify` é tudo-ou-nada: se qualquer campo do escopo muda,
**todos** os widgets inscritos reconstroem. Quem só queria o contador de sessões reconstrói quando
a lista de matérias muda.

**3. Combinar estados é manual.** "Minutos totais desta semana" depende de sessões **e** de
matérias. Com `InheritedWidget`, você recalcula na mão, e precisa lembrar de recalcular sempre que
qualquer um dos dois mudar.

**4. Carregando/erro é responsabilidade sua.** Todo dado que vem de fora tem quatro estados
(Módulo 06, aula 12). Com `InheritedWidget`, você escreve o `sealed class`, os campos e as
transições **para cada estado do app**.

### As quatro opções reais

| | `setState` | Provider | Riverpod | BLoC |
|---|---|---|---|---|
| Vem no SDK | ✅ | ❌ | ❌ | ❌ |
| Precisa de `BuildContext` para ler | — | ✅ sim | ❌ **não** | ✅ sim (com `context.read`) |
| Estados de carregando/erro prontos | ❌ | ❌ | ✅ `AsyncValue` | ❌ (você modela) |
| Combina estados | ❌ | ⚠️ `ProxyProvider`, verboso | ✅ `ref.watch` de outro provider | ⚠️ `StreamSubscription` entre blocs |
| Testável sem widget | ❌ | ⚠️ difícil | ✅ `ProviderContainer` | ✅ |
| Erro de "provider não encontrado" | — | Em **tempo de execução** | Em **tempo de compilação** | Em tempo de execução |
| Linhas para um contador | 5 | ~15 | ~10 | ~40 |
| Curva de aprendizado | Baixa | Média | **Média-alta** | **Alta** |
| Quem mantém | Google | Comunidade (Remi Rousselet) | Comunidade (Remi Rousselet) | Comunidade (Felix Angelov) |

Sobre as duas últimas colunas com honestidade:

- **Provider** é o antecessor do Riverpod, **do mesmo autor**. Ele funciona, tem muito material, e
  está em manutenção — não em desenvolvimento ativo. Migrar de Provider para Riverpod depois é
  trabalho real.
- **BLoC** é excelente e muito usado em empresas grandes. O custo é a cerimônia: para um contador,
  você escreve eventos, estados, um bloc e os *handlers*. Em app pequeno, isso pesa; em app grande
  com equipe grande, a estrutura rígida vira vantagem.

### Por que este curso escolheu Riverpod

Quatro razões, na ordem de importância:

**1. `AsyncValue` resolve os quatro estados de graça.**

No Módulo 06, aula 12, você escreveu um `sealed class` com carregando, sucesso, vazio e erro. O
Riverpod já traz isso pronto e integrado:

```dart
final AsyncValue<List<Materia>> materias = ref.watch(materiasProvider);

return materias.when(
  loading: () => const EsqueletoLista(),
  error: (Object erro, StackTrace pilha) => EstadoErro(onTentarDeNovo: ...),
  data: (List<Materia> lista) => ListaMaterias(lista),
);
```

Você não escreve o `sealed class`, nem as transições, nem o `try/catch` em cada chamada.

**2. Não precisa de `BuildContext`.**

```dart
// Riverpod: o ref não é um context
final int sessoes = ref.read(sessoesProvider);
```

`ref` funciona no `initState`, depois de um `await`, em testes sem árvore de widgets, e em classes
que não são widgets. Toda aquela família de erros — "usei o context errado", "o context morreu
depois do await", "`.of(context)` no initState" — simplesmente **deixa de existir**.

**3. Erros em tempo de compilação.**

Com Provider, esquecer de registrar um provider dá erro **quando o usuário abre a tela**:

```text
ProviderNotFoundException: Could not find the correct Provider<Contador> above this widget
```

Com Riverpod, o provider é uma **variável global tipada**. Esquecer de declarar é erro de
compilação; usar o tipo errado é erro de compilação.

**4. É testável fora da árvore.**

```dart
test('conta sessões', () {
  final ProviderContainer container = ProviderContainer();
  addTearDown(container.dispose);

  container.read(sessoesProvider.notifier).registrar(25);
  expect(container.read(sessoesProvider), 25);
});
```

Nenhum `pumpWidget`, nenhum emulador. É a diferença entre testes que rodam em 50 ms e testes que
ninguém roda porque demoram.

### Sem *code generation* — e por quê

O Riverpod tem duas formas de escrever provider:

**Com gerador (`riverpod_generator`):**

```dart
@riverpod
int contador(ContadorRef ref) => 0;
// … e o build_runner gera contadorProvider em um arquivo .g.dart
```

**Sem gerador (a forma deste curso):**

```dart
final Provider<int> contadorProvider = Provider<int>((Ref ref) => 0);
```

| | Com gerador | Sem gerador |
|---|---|---|
| Linhas escritas | Menos | Mais |
| Precisa rodar `build_runner` | ✅ sempre | ❌ |
| Arquivos `.g.dart` no projeto | ✅ | ❌ |
| Você lê a declaração inteira | ❌ está no arquivo gerado | ✅ |
| Espera de geração ao editar | Segundos a minutos | Zero |

**Decisão do curso: sem gerador.** A razão é pedagógica: quando tudo está visível na linha que você
escreveu, não existe mágica. Você vê o tipo do provider, o tipo do estado e quem cria — e quando
der erro, o erro aponta para código que você escreveu.

> 📌 Em projeto grande, com 40+ providers, o gerador compensa: a repetição vira erro de digitação.
> Essa transição é fácil de fazer depois. Começar com ela é que atrapalha o aprendizado.

### As APIs legadas que você vai encontrar

O Riverpod 3 **moveu** três APIs antigas para `package:riverpod/legacy.dart`:

| API legada | Por que saiu | Use no lugar |
|---|---|---|
| `StateProvider` | Estado mutável sem regras; vira bagunça rápido | `NotifierProvider` |
| `StateNotifierProvider` | Substituído por `Notifier`, mais simples | `NotifierProvider` |
| `ChangeNotifierProvider` | Estado mutável, difícil de testar e de otimizar | `NotifierProvider` |

> ⚠️ **Praticamente todo tutorial de Riverpod na internet usa `StateProvider` ou
> `StateNotifierProvider`.** Eles foram o padrão até 2023. O código ainda compila (importando
> `legacy.dart`), mas é a API antiga. Se você encontrar um exemplo com eles, ele é de antes do
> Riverpod 3 — traduza para `NotifierProvider`, que é o assunto da
> [aula 6](06-notifier-e-notifierprovider.md).

### Quando **não** usar Riverpod

Ser honesto aqui é mais útil que vender a ferramenta:

| Situação | Use |
|---|---|
| Estado de **um** widget (campo focado, aba aberta, animação) | **`setState`.** Sempre. |
| App de 2 telas sem dado compartilhado | `setState` + elevação |
| Estado que **é** a árvore (formulário, rolagem, foco) | Os controladores do próprio Flutter |
| A equipe já usa BLoC em tudo | BLoC — consistência vale mais que preferência |
| Você ainda não entendeu `InheritedWidget` | Volte à [aula 3](03-inheritedwidget.md) |

> ⚠️ **O erro mais comum de quem aprende Riverpod é usar Riverpod para tudo.** Um `bool
> _expandido` que controla um `ExpansionTile` **não** é estado de aplicação — é estado de widget.
> Colocá-lo em um provider adiciona indireção e não ganha nada. A pergunta que decide: *"mais de um
> widget precisa disso, ou isso precisa sobreviver a esta tela?"* Se a resposta é não, é
> `setState`.

---

## 💡 Analogia

Pense em como uma empresa guarda informação.

- **`setState`** é um post-it na sua mesa. Perfeito para o que só você precisa. Inútil para o
  resto da empresa.
- **Elevação de estado** é levar o papel até o chefe comum das duas pessoas que precisam dele.
  Funciona com duas pessoas; com cinco níveis de hierarquia, o papel passa por gente que não tem
  nada a ver com o assunto — que é o *prop drilling*.
- **`InheritedWidget`** é um mural no corredor: quem passa, lê. Bom. Mas **você construiu o mural,
  a moldura e o sistema de avisos na mão** — e, quando qualquer papel do mural muda, o alarme toca
  para todo mundo, inclusive para quem só queria saber do cardápio.
- **Riverpod** é um sistema de informação com **assinaturas por assunto**. Cada pessoa assina só o
  que lhe interessa e é avisada só quando **aquilo** muda. E — aqui está a parte que mais importa —
  **você não precisa estar no prédio para consultar**: o sistema é acessível de fora, o que é
  exatamente o significado de "não depende de `BuildContext`". É por isso que dá para testar sem
  montar o prédio inteiro.
- **`AsyncValue`** é o sistema já saber que toda consulta a um sistema externo tem três respostas
  possíveis — "ainda buscando", "aqui está" e "deu erro" — e já ter formulário para as três, em vez
  de cada departamento inventar o seu.
- **BLoC** é o mesmo sistema com **protocolo formal**: toda solicitação em formulário próprio, toda
  resposta registrada. Excelente numa empresa de mil pessoas; burocracia numa de cinco.

---

## 🧪 Exemplo mínimo

O mesmo contador, escrito das quatro formas. Compare o tamanho e o que cada um exige.

> **Arquivo:** `foco_estado/lib/main.dart` (temporário — é só para comparar)
> **Instale antes:** `flutter pub add flutter_riverpod`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ═══════════════════════════════════════════════════════════════════════
// 1. setState — 5 linhas úteis. Só funciona DENTRO deste widget.
// ═══════════════════════════════════════════════════════════════════════
class ContadorSetState extends StatefulWidget {
  const ContadorSetState({super.key});

  @override
  State<ContadorSetState> createState() => _ContadorSetStateState();
}

class _ContadorSetStateState extends State<ContadorSetState> {
  int _valor = 0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('setState: $_valor'),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => setState(() => _valor++),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 2. InheritedWidget (aula 3) — ~70 linhas. Omitido aqui de propósito:
//    releia a aula 3 e compare o tamanho com o bloco 3 abaixo.
// ═══════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════
// 3. Riverpod — 8 linhas, e funciona em QUALQUER lugar do app.
// ═══════════════════════════════════════════════════════════════════════

/// O provider é uma variável global TIPADA.
/// Esquecer de declarar é erro de compilação, não de execução.
final NotifierProvider<ContadorNotifier, int> contadorProvider =
    NotifierProvider<ContadorNotifier, int>(ContadorNotifier.new);

class ContadorNotifier extends Notifier<int> {
  /// Devolve o estado inicial. É chamado uma vez, na primeira leitura.
  @override
  int build() => 0;

  /// Estado é IMUTÁVEL: você atribui um valor novo, nunca modifica o antigo.
  void incrementar() => state = state + 1;
}

/// ConsumerWidget é um StatelessWidget que recebe um `ref`.
class ContadorRiverpod extends ConsumerWidget {
  const ContadorRiverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch: lê E se inscreve. Este widget reconstrói quando o valor muda.
    final int valor = ref.watch(contadorProvider);

    return ListTile(
      title: Text('Riverpod: $valor'),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        // read + .notifier: chama o método SEM se inscrever.
        onPressed: () => ref.read(contadorProvider.notifier).incrementar(),
      ),
    );
  }
}

/// O mesmo estado, lido de OUTRO widget, em outro lugar da árvore.
/// Sem passar nada por parâmetro. Sem InheritedWidget escrito na mão.
class EcoDoContador extends ConsumerWidget {
  const EcoDoContador({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int valor = ref.watch(contadorProvider);
    return ListTile(
      leading: const Icon(Icons.hearing),
      title: Text('Outro widget vê: $valor'),
      subtitle: const Text('Nenhum parâmetro foi passado até aqui'),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════

void main() {
  // ProviderScope guarda o estado de TODOS os providers.
  // Sem ele, qualquer ref.watch lança erro.
  runApp(const ProviderScope(child: AppComparacao()));
}

class AppComparacao extends StatelessWidget {
  const AppComparacao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: Scaffold(
        appBar: AppBar(title: const Text('setState × Riverpod')),
        body: const Column(
          children: <Widget>[
            Card(child: ContadorSetState()),
            Card(child: ContadorRiverpod()),
            Card(child: EcoDoContador()),
            Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Toque no "+" de cada linha.\n\n'
                'O setState só muda a própria linha.\n'
                'O Riverpod muda as duas linhas dele — e o EcoDoContador '
                'nunca recebeu nada por parâmetro.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**O que observar:** toque no `+` do Riverpod. **Duas** linhas mudam, e o `EcoDoContador` está em
outro lugar da árvore, sem nenhum parâmetro. Compare com as ~70 linhas que a aula 3 exigiu para o
mesmo efeito.

> ⚠️ Este exemplo usa `NotifierProvider` de propósito, e não `StateProvider`. A API detalhada é a
> [aula 6](06-notifier-e-notifierprovider.md) — aqui ele aparece só para a comparação de tamanho.

---

## 📱 Aplicando no Flutter

Esta aula é de **decisão**, não de código novo no projeto. O que você faz agora é preparar o
`foco_estado` para as aulas 5 a 10:

1. Instalar o Riverpod.
2. Envolver o app em `ProviderScope`.
3. Ativar os lints que evitam os erros mais comuns.

Nada mais muda ainda — o `InheritedWidget` da aula 3 continua funcionando lado a lado.

---

## 💻 Código completo

> **Arquivo:** `foco_estado/pubspec.yaml`
> **Instale com:** `flutter pub add flutter_riverpod`

```yaml
name: foco_estado
description: Laboratório de estado e arquitetura do Curso Flutter Intensivo.
publish_to: 'none'
version: 0.1.0

environment:
  sdk: ^3.13.1

dependencies:
  flutter:
    sdk: flutter
  # Riverpod 3.x. Sem riverpod_generator: o curso escreve os providers
  # à mão, para nada ficar escondido em arquivo gerado.
  flutter_riverpod: ^3.4.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

> **Arquivo:** `foco_estado/analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Tipos explícitos: enquanto você aprende, ver o tipo do provider
    # na própria linha ensina mais do que economizar caracteres.
    - always_specify_types
    - prefer_final_locals

    # Evita o erro nº 1 de quem começa com Riverpod:
    # usar context depois de await sem checar mounted.
    - use_build_context_synchronously

    # Estado imutável: o Riverpod compara o estado antigo com o novo
    # para decidir se notifica. Mutar no lugar quebra essa comparação.
    - avoid_setters_without_getters
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
```

> **Arquivo:** `foco_estado/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/app.dart';

void main() {
  // ProviderScope é onde o estado de TODOS os providers vive.
  //
  // Ele é, por dentro, um InheritedWidget — exatamente o que você
  // escreveu na aula 3. A diferença é que agora vem pronto, guarda
  // qualquer número de estados e notifica só quem assinou cada um.
  //
  // Sem este widget na raiz, o primeiro ref.watch lança:
  //   "No ProviderScope found"
  runApp(
    const ProviderScope(
      child: FocoEstadoApp(),
    ),
  );
}
```

> **Arquivo:** `foco_estado/lib/app.dart`

```dart
import 'package:flutter/material.dart';

import 'package:foco_estado/telas/home_screen.dart';

class FocoEstadoApp extends StatelessWidget {
  const FocoEstadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco — Estado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
```

Confirme que tudo está no lugar:

```powershell
flutter pub get
flutter analyze
flutter run -d chrome
```

O app deve rodar **exatamente como antes**. O `ProviderScope` não muda nada visualmente — ele só
prepara o terreno.

> 📌 Guarde o `escopo_foco.dart` da aula 3. Na [aula 5](05-riverpod-primeiros-passos.md) você vai
> substituir o uso dele por providers, mas manter o arquivo para comparar as duas implementações
> lado a lado.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `flutter_riverpod: ^3.4.3` | O pacote para apps Flutter. Existe também `riverpod` (Dart puro, sem widgets) e `hooks_riverpod` (com `flutter_hooks`) — o curso usa o primeiro. |
| Ausência de `riverpod_generator` | Decisão do curso: providers escritos à mão, nada escondido em `.g.dart`, zero `build_runner`. |
| `const ProviderScope(child: ...)` na raiz | Guarda o estado de todos os providers. Por dentro é um `InheritedWidget` — o mesmo mecanismo da aula 3. |
| `always_specify_types` | Enquanto você aprende, `final NotifierProvider<ContadorNotifier, int> x = ...` ensina mais que `final x = ...`. |
| `use_build_context_synchronously` | O Riverpod reduz o uso de `context`, mas não o elimina. O lint continua valendo. |
| `final NotifierProvider<...> contadorProvider` **global** | Provider é variável global — e isso é seguro, porque ele **não guarda estado**: é só uma receita. O estado vive no `ProviderScope`. |
| `class ContadorNotifier extends Notifier<int>` | A classe que **contém a lógica**. O `build()` devolve o estado inicial. |
| `state = state + 1` | Atribuição, não mutação. O Riverpod compara antigo e novo para decidir se notifica. |
| `ConsumerWidget` com `build(context, ref)` | `StatelessWidget` que ganha um `ref`. É o widget padrão do curso daqui em diante. |
| `ref.watch(provider)` | Lê **e se inscreve**: reconstrói quando o valor muda. Use no `build`. |
| `ref.read(provider.notifier)` | Lê **sem se inscrever** e acessa a classe com os métodos. Use em callbacks. |

> A diferença entre `watch`, `read` e `listen` é o assunto central da
> [aula 5](05-riverpod-primeiros-passos.md) — e é onde quase todo mundo erra no começo.

---

## ⚠️ Erros comuns

### 1. Usar Riverpod para estado de widget

```dart
// ❌ um ExpansionTile aberto não é estado de aplicação
final StateProvider<bool> expandidoProvider = StateProvider<bool>((Ref r) => false);
```

**Correção:** `setState`. A pergunta que decide: *"mais de um widget precisa disso, ou isso precisa
sobreviver a esta tela?"*

### 2. Esquecer o `ProviderScope`

```text
No ProviderScope found.
```

**Correção:** `runApp(const ProviderScope(child: MeuApp()))`.

### 3. Seguir tutorial com `StateProvider`

```dart
final StateProvider<int> contadorProvider = StateProvider<int>((Ref ref) => 0);   // ⚠️ legado
```

Compila se você importar `legacy.dart`, mas é a API antiga do Riverpod 2.

**Correção:** `NotifierProvider` ([aula 6](06-notifier-e-notifierprovider.md)).

### 4. Instalar `riverpod` em vez de `flutter_riverpod`

```text
The method 'ProviderScope' isn't defined
```

O pacote `riverpod` é Dart puro, sem widgets.

**Correção:** `flutter pub add flutter_riverpod`.

### 5. Adotar Riverpod sem entender `InheritedWidget`

Quando der erro — e vai dar —, você não terá modelo mental para depurar. O Riverpod é uma camada
**sobre** o `InheritedWidget`; quem não conhece a camada de baixo trata a de cima como mágica.

**Correção:** [aula 3](03-inheritedwidget.md), até estar confortável.

### 6. Trocar de solução no meio do projeto

Provider em três telas, Riverpod em cinco, `setState` no resto: ninguém entende de onde vem o
estado.

**Correção:** escolha uma e aplique. Migrar depois é uma tarefa dedicada, não algo que se faz aos
poucos.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo. Toque no `+` de cada linha e confirme: o `setState` muda uma
linha; o Riverpod muda duas.

**Passo 2.** Abra o `escopo_foco.dart` da aula 3 e conte as linhas. Compare com as 8 linhas do
`contadorProvider`. Anote a diferença.

**Passo 3.** Remova o `ProviderScope` do `runApp`. Rode e leia o erro **inteiro**. Copie a primeira
linha para o seu caderno. Depois restaure.

**Passo 4.** No `EcoDoContador`, troque `ref.watch` por `ref.read`. Toque no `+` e observe o que
acontece com aquela linha. Explique por escrito. Depois desfaça.

**Passo 5.** Acrescente um terceiro widget que também lê o `contadorProvider`, em outro lugar da
árvore. Quantos parâmetros você precisou passar até ele?

**Passo 6.** Instale o Riverpod no `foco_estado`, acrescente o `ProviderScope` e rode
`flutter analyze`. Confirme `No issues found!`.

**Passo 7.** Responda por escrito, com uma frase para cada: qual estado do seu app deveria usar
`setState` e qual deveria usar Riverpod? Dê um exemplo concreto de cada.

**Passo 8.** Procure um tutorial de Riverpod na internet. Ele usa `StateProvider`,
`StateNotifierProvider` ou `NotifierProvider`? Isso te diz de que ano ele é.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

Faça os exercícios de **Decisão** sobre qual solução usar em cada cenário, e o de **Compreensão**
sobre o que o `ProviderScope` guarda.

---

## 🏆 Desafio opcional

Escreva, no seu caderno ou em um arquivo `docs/decisao-de-estado.md` do projeto, a sua **própria**
tabela de decisão — com os critérios que **você** usaria, não os do curso.

Ela precisa responder, para cada tipo de estado do app Foco:

| Estado | Solução | Por quê |
|---|---|---|
| Aba selecionada na `NavigationBar` | ? | ? |
| Texto digitado num `TextField` | ? | ? |
| Lista de matérias do usuário | ? | ? |
| Sessão de estudo em andamento | ? | ? |
| Tema claro/escuro escolhido | ? | ? |
| `ExpansionTile` aberto num cartão | ? | ? |
| Token de autenticação | ? | ? |
| Resultado de uma busca na API | ? | ? |

Depois compare com o que as aulas 5 a 10 fazem. Onde você discordou, pergunte-se: foi engano seu ou
uma escolha diferente e defensável? Nem toda divergência é erro — e saber distinguir é o que separa
seguir tutorial de tomar decisão técnica.

---

## 📌 Resumo

- Depois do `setState`, da elevação e do `InheritedWidget`, sobraram **quatro problemas**: depender
  de `BuildContext`, reconstruir demais, combinar estados na mão, e modelar carregando/erro em cada
  tela.
- **Riverpod** resolve os quatro. O custo é uma dependência e uma curva de aprendizado média-alta.
- Ele **não depende de `BuildContext`**: `ref` funciona em `initState`, depois de `await`, em
  testes e fora de widgets. Isso elimina uma classe inteira de erros.
- **`AsyncValue`** já traz carregando/sucesso/erro — o `sealed class` que você escreveu no
  Módulo 06 vem pronto.
- Provider é o **antecessor**, do mesmo autor, em manutenção. BLoC é excelente e mais cerimonioso;
  compensa em equipe grande.
- **Decisão do curso: Riverpod 3.4.3 sem *code generation***, por razão pedagógica — nada escondido
  em arquivo gerado, zero `build_runner`.
- `StateProvider`, `StateNotifierProvider` e `ChangeNotifierProvider` são **legados** no Riverpod 3.
  Quase todo tutorial da internet os usa; traduza para `NotifierProvider`.
- Provider é **variável global** — e isso é seguro, porque ele é só uma receita: o estado vive no
  `ProviderScope`.
- `ProviderScope` na raiz é **obrigatório**; sem ele, o primeiro `ref.watch` lança erro.
- **Não use Riverpod para estado de widget.** Aba aberta, campo focado e animação continuam sendo
  `setState`.
- A pergunta que decide: *"mais de um widget precisa disso, ou isso precisa sobreviver a esta
  tela?"*

---

## ☑️ Checklist de domínio

- [ ] Listo os quatro problemas que sobraram depois do `InheritedWidget`.
- [ ] Comparo Riverpod, Provider, BLoC e `setState` citando um custo de cada.
- [ ] Explico por que não depender de `BuildContext` é uma vantagem concreta, com dois exemplos.
- [ ] Digo o que o `AsyncValue` traz pronto e onde eu escrevi isso na mão antes.
- [ ] Justifico a escolha do curso por Riverpod sem *code generation*.
- [ ] Reconheço `StateProvider` e `StateNotifierProvider` como APIs legadas.
- [ ] Sei que `ProviderScope` é obrigatório e qual erro aparece sem ele.
- [ ] Sei dizer por que um provider global não é uma variável global perigosa.
- [ ] Cito três estados que **não** devem virar provider.
- [ ] Instalei `flutter_riverpod` e o app roda com `ProviderScope`.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Riverpod — riverpod.dev](https://riverpod.dev/)
- [flutter_riverpod — pub.dev](https://pub.dev/packages/flutter_riverpod)
- [Why Riverpod? — riverpod.dev](https://riverpod.dev/docs/introduction/why_riverpod)
- [About code generation — riverpod.dev](https://riverpod.dev/docs/concepts/about_code_generation)
- [State management approaches — docs.flutter.dev](https://docs.flutter.dev/data-and-backend/state-mgmt/options)
- [Simple app state management — docs.flutter.dev](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)
- [05 — Decisões técnicas do curso](../../05-decisoes-tecnicas.md)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — InheritedWidget](03-inheritedwidget.md) | [README](README.md) | [Aula 5 — Riverpod: primeiros passos](05-riverpod-primeiros-passos.md) |
