# Aula 1 — Navigator: a pilha

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é uma **pilha** (*stack*) e por que o Flutter usa essa estrutura para guardar as
  telas abertas.
- Abrir uma tela com `Navigator.push` + `MaterialPageRoute` e fechá-la com `Navigator.pop`.
- Usar `pushReplacement` para **trocar** a tela atual em vez de empilhar mais uma.
- Voltar várias telas de uma vez com `popUntil`, e perguntar se há para onde voltar com `canPop`
  e `maybePop`.
- Descrever como o **botão voltar do Android** e o **gesto do iOS** agem sobre essa mesma pilha.
- Abrir uma tela como **diálogo em tela cheia** com `fullscreenDialog: true`.

## ✅ Pré-requisitos

- [Módulo 05 — StatefulWidget e setState](../05-introducao-ao-flutter/05-statefulwidget-e-setstate.md)
  e [BuildContext](../05-introducao-ao-flutter/07-buildcontext.md) — o `Navigator` é encontrado
  **através** do `BuildContext`.
- [Módulo 06 — Scaffold e AppBar](../06-widgets-e-layouts/01-scaffold-e-appbar.md) e
  [Listas e rolagem](../06-widgets-e-layouts/09-listas-e-rolagem.md).
- [Módulo 03 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md) e Flutter 3.47.1
  instalado ([02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md)).

---

## 📖 Conceito

### O que é uma pilha

Uma **pilha** (*stack*) é uma estrutura de dados com uma regra única e rígida: **o último que entra
é o primeiro que sai** (em inglês *LIFO* — *Last In, First Out*). Você só tem acesso ao elemento do
**topo**, e existem duas operações: `push` (*empilhar*, coloca no topo) e `pop` (*desempilhar*,
remove do topo).

O Flutter guarda as telas abertas exatamente assim. Cada tela empilhada é uma **rota** (*route*), e
o widget que administra a pilha é o **`Navigator`**. Quando o app abre, o `Navigator` já tem uma
rota na pilha: a tela definida em `home:` (ou em `initialRoute:`, que entra na
[aula 2](02-rotas-nomeadas.md)).

```text
    ┌──────────────────────────┐  ← TOPO (a tela que você vê)
    │  EstatisticasScreen      │
    ├──────────────────────────┤
    │  DetalheMateriaScreen    │
    ├──────────────────────────┤
    │  ListaMateriasScreen     │  ← base (a primeira rota)
    └──────────────────────────┘
```

Só a rota do topo é visível. As de baixo continuam **existindo na memória**, com o estado delas
preservado — posição da rolagem, texto já digitado, contador. É por isso que, ao voltar de uma tela
de detalhe, a lista aparece exatamente onde você parou. E é por isso também que empilhar tela custa
memória: um app que empilha 40 telas sem nunca desempilhar fica pesado.

### As operações que existem

| Chamada | O que acontece com a pilha | Quando usar |
|---|---|---|
| `Navigator.push(context, rota)` | Empilha uma rota nova no topo | Abrir detalhe, formulário, tela filha |
| `Navigator.pop(context)` | Remove a rota do topo | "Voltar", "Cancelar", "Salvar e fechar" |
| `Navigator.pushReplacement(context, rota)` | Remove a do topo **e** empilha a nova no lugar | Splash → Home, Login → Home |
| `Navigator.popUntil(context, teste)` | Desempilha até uma rota satisfazer o teste | "Concluir" no fim de um fluxo longo |
| `Navigator.canPop(context)` | Devolve `bool`: existe algo abaixo? | Decidir se mostra o botão voltar |
| `Navigator.maybePop(context)` | Volta **se puder**; não faz nada se for a última | Botão voltar genérico e reutilizável |

`pop` e `maybePop` parecem iguais, mas não são. `Navigator.pop(context)` na **última** rota tenta
esvaziar a pilha e costuma deixar o app com uma tela preta — erro clássico de iniciante. Já
`Navigator.maybePop(context)` pergunta antes e só volta se der; além disso, `maybePop` respeita o
`PopScope` (a confirmação de saída da [aula 5](05-navegacao-android-x-ios.md)), e `pop` **não**.

### `Route` e `MaterialPageRoute`

**`Route`** é a classe abstrata que representa "uma coisa empilhada no Navigator".
**`MaterialPageRoute`** é a implementação concreta mais comum: ocupa a tela inteira e **anima** a
entrada e a saída com o estilo da plataforma.

```dart
MaterialPageRoute<void>(
  builder: (context) => const DetalheMateriaScreen(),
)
```

- `builder` é uma função que constrói a tela **só quando ela for exibida**, não no momento em que
  você escreve o código; o `context` que chega nela é um contexto **novo**, abaixo da rota.
- O `<void>` é o **tipo do resultado** que a tela devolve ao fechar. Na
  [aula 3](03-argumentos-e-resultados.md) ele vira `<Materia>` e ganha papel central.

### `fullscreenDialog`: a tela que é um formulário modal

Com `fullscreenDialog: true`, três coisas mudam: a tela **sobe de baixo para cima** em vez de
deslizar da direita; o ícone automático da `AppBar` vira um **X (fechar)** em vez de seta; e 🍎 no
iOS o gesto de arrastar da borda é **desativado** nessa tela. Semanticamente isso comunica: *"isto é
uma tarefa que você começa, termina ou cancela"*. Use em criação, edição, escolha e filtros — não em
tela de detalhe comum.

---

## 💡 Analogia

Pense numa pilha de bandejas no restaurante universitário. Você coloca a bandeja nova **em cima**
(`push`) e tira a bandeja **de cima** (`pop`). Não dá para puxar a terceira do meio sem tirar as
duas de cima — por isso existe o `popUntil`, que repete o `pop` até a condição ser satisfeita.
`pushReplacement` é trocar a bandeja do topo por outra: a pilha mantém a altura, e a antiga não
volta mais. Onde a analogia para de valer: as rotas debaixo **guardam o estado inteiro delas** —
bandeja nenhuma guarda comida quente.

---

## 🧪 Exemplo mínimo

As duas chamadas, isoladas. Na tela A, dentro do `onPressed` de um botão:

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(builder: (context) => const TelaB()),
);
```

E na tela B, para fechar e voltar:

```dart
Navigator.of(context).pop();
```

É só isso — o resto do app fica igual. Dois detalhes que valem para o curso inteiro:

- `Navigator.of(context)` procura o `Navigator` **subindo** na árvore de widgets. Chamado de um
  contexto *acima* do `MaterialApp`, o app lança
  `Navigator operation requested with a context that does not include a Navigator`.
- A `AppBar` da tela B consulta `Navigator.canPop` e desenha a seta de voltar sozinha: você não
  escreve nada para isso acontecer.

---

## 📱 Aplicando no Flutter

Vamos criar o projeto que acompanha **todo o módulo 07**. No PowerShell, na pasta dos seus projetos:

```powershell
flutter create --platforms=android,ios foco_navegacao
cd foco_navegacao
flutter run
```

> 🪟 **Windows:** se aparecer `Building with plugins requires symlink support`, ative o Modo de
> Desenvolvedor (`start ms-settings:developers`) — passo a passo em
> [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).
> 🤖 Sem Android SDK ainda? Rode `flutter run -d chrome` ou `flutter run -d windows`: a navegação
> funciona igual, só a animação muda.

O app tem cinco telas e exercita **todas** as operações de pilha: `AberturaScreen` (sai com
`pushReplacement` e não fica na pilha), `ListaMateriasScreen` (vira a base), `DetalheMateriaScreen`
(`push`, `canPop`, `maybePop`), `EstatisticasScreen` (`popUntil`) e `NovaMateriaScreen`
(`fullscreenDialog: true`). Para você **ver** a pilha se mexendo, ele usa um `NavigatorObserver`
(*observador do Navigator* — objeto avisado a cada empilhamento e desempilhamento) que escreve no
console.

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/main.dart`
> **Como executar:** `flutter run` (dentro da pasta `foco_navegacao`)

```dart
import 'package:flutter/material.dart';

void main() => runApp(const FocoNavegacaoApp());

/// Modelo de uma matéria. Construtor `const` para liberar `const` nos widgets.
class Materia {
  const Materia({required this.id, required this.nome, required this.minutos});
  final String id;
  final String nome;
  final int minutos;
}

/// Dados fixos por enquanto. No módulo 10 eles virão do banco sqflite.
const List<Materia> materiasIniciais = <Materia>[
  Materia(id: 'm1', nome: 'Álgebra', minutos: 120),
  Materia(id: 'm2', nome: 'Física', minutos: 90),
  Materia(id: 'm3', nome: 'História', minutos: 45),
];

/// Escreve no console o que entra e o que sai da pilha. Só para aprender.
class ObservadorDePilha extends NavigatorObserver {
  String _nome(Route<dynamic>? r) =>
      r?.settings.name ?? r?.runtimeType.toString() ?? 'nenhuma';

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

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugPrint('REPLACE ${_nome(oldRoute)} => ${_nome(newRoute)}');
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
        home: const AberturaScreen(),
      );
}

class AberturaScreen extends StatefulWidget {
  const AberturaScreen({super.key});
  @override
  State<AberturaScreen> createState() => _AberturaScreenState();
}

class _AberturaScreenState extends State<AberturaScreen> {
  @override
  void initState() {
    super.initState();
    _irParaLista();
  }

  Future<void> _irParaLista() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return; // depois de um await o widget pode ter saído da árvore
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const ListaMateriasScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.school_outlined, size: 72),
              SizedBox(height: 16),
              Text('Foco'),
              SizedBox(height: 24),
              CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
      );
}

class ListaMateriasScreen extends StatelessWidget {
  const ListaMateriasScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Matérias')),
        body: ListView.separated(
          itemCount: materiasIniciais.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, indice) {
            final Materia materia = materiasIniciais[indice];
            return ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(materia.nome),
              subtitle: Text('${materia.minutos} min estudados'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => DetalheMateriaScreen(materia: materia),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const NovaMateriaScreen(),
              fullscreenDialog: true, // sobe de baixo e ganha o X de fechar
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Nova matéria'),
        ),
      );
}

class DetalheMateriaScreen extends StatelessWidget {
  const DetalheMateriaScreen({required this.materia, super.key});
  final Materia materia;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(materia.nome)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('${materia.minutos} minutos',
                  style: Theme.of(context).textTheme.headlineMedium),
              Text('Existe rota abaixo desta? ${Navigator.canPop(context)}'),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => EstatisticasScreen(materia: materia),
                  ),
                ),
                icon: const Icon(Icons.insights_outlined),
                label: const Text('Ver estatísticas'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar (pop)'),
              ),
              TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Voltar com educação (maybePop)'),
              ),
            ],
          ),
        ),
      );
}

class EstatisticasScreen extends StatelessWidget {
  const EstatisticasScreen({required this.materia, super.key});
  final Materia materia;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Estatísticas')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Matéria: ${materia.nome}'),
              Text('Total: ${(materia.minutos / 60).toStringAsFixed(1)} h'),
              const SizedBox(height: 32),
              FilledButton.tonal(
                // Desempilha até chegar na primeira rota da pilha.
                onPressed: () => Navigator.of(context)
                    .popUntil((Route<dynamic> rota) => rota.isFirst),
                child: const Text('Voltar direto para a lista (popUntil)'),
              ),
            ],
          ),
        ),
      );
}

class NovaMateriaScreen extends StatelessWidget {
  const NovaMateriaScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Nova matéria')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aberta com fullscreenDialog: true — subiu de baixo, o botão da AppBar é um X em vez '
            'de seta, e no iPhone o gesto de borda não a fecha. O formulário entra na aula 6.',
          ),
        ),
      );
}
```

Rode e acompanhe o console do `flutter run`:

```text
PUSH  -> AberturaScreen  (abaixo: nenhuma)
REPLACE AberturaScreen => ListaMateriasScreen
PUSH  -> DetalheMateriaScreen  (abaixo: ListaMateriasScreen)
PUSH  -> EstatisticasScreen  (abaixo: DetalheMateriaScreen)
POP   <- EstatisticasScreen  (volta para: DetalheMateriaScreen)
POP   <- DetalheMateriaScreen  (volta para: ListaMateriasScreen)
```

---

## 🔍 Explicando o código

**`Materia` com construtor `const`.** Permite criar o objeto em tempo de compilação, o que libera
`const` nos widgets que o usam — e widget `const` não é reconstruído à toa (ganho medido no
[módulo 13](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md)).

**`separatorBuilder: (_, _) => const Divider(height: 1)`.** O `_` nomeia um parâmetro que você não
vai usar. Com `flutter_lints 6.0.0`, escrever `(_, __)` dispara o aviso `unnecessary_underscores`:
**a forma correta hoje é `(_, _)`**, com dois underscores simples.

**`ObservadorDePilha extends NavigatorObserver`.** Recebe uma notificação a cada mudança da pilha.
Repare que todo `route.settings.name` sai `null`: rotas criadas direto com `MaterialPageRoute`
**não têm nome** — exatamente o problema que a [aula 2](02-rotas-nomeadas.md) resolve.

**`debugPrint` em vez de `print`.** `print()` dispara o lint `avoid_print`. `debugPrint` some do
build de release e **enfileira** as linhas, evitando que o Android descarte log muito rápido.

**`await Future.delayed(...)` seguido de `if (!mounted) return;`.** A regra mais importante de todo
código assíncrono em Flutter:

> Depois de qualquer `await`, o widget pode **já ter saído da árvore**. Usar `context` nesse estado
> lança exceção. Num `State`, cheque `mounted`. Em código que guardou um `BuildContext` fora de um
> `State`, cheque `context.mounted`.

Sem essa linha, fechar o app durante os 2 segundos da abertura produz o erro real
`Looking up a deactivated widget's ancestor is unsafe`.

**`pushReplacement` na abertura.** A splash não deve ficar na pilha — seria estranho apertar voltar
na lista e reaparecer a tela de abertura. Ele troca a rota do topo, e a pilha fica com altura 1.

**`Navigator.canPop(context)`.** `true` se existe rota abaixo; é o que a `AppBar` consulta para
decidir se desenha a seta. No detalhe imprime `true`; na lista imprimiria `false`.

**`popUntil((rota) => rota.isFirst)`.** Recebe um `RoutePredicate` — função que recebe uma `Route` e
devolve `bool` — e desempilha **enquanto** o resultado for `false`.

> ⚠️ Se o predicado **nunca** devolver `true`, o `popUntil` esvazia a pilha e você fica com tela
> preta. Use sempre um teste garantido, como `isFirst` ou um nome de rota
> (`rota.settings.name == Rotas.home`, possível a partir da aula 2).

---

## 🤖🍎 Android × iOS

Esta é a primeira aula em que a **mesma linha de código** se comporta de forma visivelmente
diferente nas duas plataformas.

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Animação do `push` | A tela nova **cresce e aparece** com zoom (`ZoomPageTransitionsBuilder`) | A tela nova **desliza da direita**; a antiga sai um pouco para a esquerda |
| Como o usuário volta | Botão voltar do sistema, ou gesto de borda em aparelhos com navegação por gestos | **Só** o gesto de arrastar da borda esquerda ou o botão da `AppBar` |
| Botão voltar do sistema | **Sim** | **Não** — o iPhone nunca teve um botão voltar global |
| `fullscreenDialog` | Sobe de baixo, seta vira X | Sobe de baixo, seta vira X, **e o gesto de borda é desativado** |

> 🤖 O botão voltar do Android e 🍎 o gesto de borda do iOS **não são recursos diferentes**: os dois
> chamam a mesma operação, um `pop` na pilha do `Navigator`.

> 🪟 **Você está no Windows e não tem Mac.** Você **consegue**: escrever todo o código, rodar no
> Android (emulador ou celular por USB), no Chrome e no Windows desktop, e simular a aparência do
> iOS trocando o tema (é a [aula 5](05-navegacao-android-x-ios.md)). Você **não consegue**: rodar no
> simulador do iPhone nem sentir o gesto de borda real — o simulador iOS só existe no macOS. Nada
> disso bloqueia o módulo; detalhes em
> [15-build-ios/01-por-que-exige-macos.md](../15-build-ios/01-por-que-exige-macos.md).

---

## ⚠️ Erros comuns

**1. `Navigator operation requested with a context that does not include a Navigator`.** Acontece
quando você chama `Navigator.of(context)` com um `context` obtido **acima** do `MaterialApp` — o
`Navigator` é criado por dentro dele. Corrija extraindo a tela para um widget próprio ou envolvendo
o trecho com um `Builder`.

**2. Chamar `pop` na última rota.** `Navigator.of(context).pop()` na `ListaMateriasScreen` deixa a
tela preta. Use `Navigator.maybePop(context)` ou proteja com `if (Navigator.canPop(context))`.

**3. Usar `context` depois de um `await` sem checar `mounted`.** Falta a linha
`if (!mounted) return;` entre o `await` e o `Navigator.of(context)`. O `flutter analyze` avisa com
`use_build_context_synchronously`; nunca ignore.

**4. Empilhar a mesma tela duas vezes sem perceber.** Dois toques rápidos no `ListTile` empilham
**duas** telas de detalhe; o usuário volta e vê a mesma tela, achando que travou.

**5. Achar que `popUntil` aceita um número.** Não existe `popUntil(context, 2)`: o segundo parâmetro
é sempre uma **função** que recebe a rota e devolve `bool`.

---

## 🛠️ Exercício guiado

Acrescente uma quarta tela ao fluxo para sentir a pilha crescendo — e depois desempilhar tudo.

**Passo 1.** No fim de `lib/main.dart`, crie:

```dart
class ResumoSessaoScreen extends StatelessWidget {
  const ResumoSessaoScreen({required this.materia, super.key});
  final Materia materia;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Resumo da sessão')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Você estudou ${materia.nome}.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst),
                child: const Text('Concluir e voltar ao início'),
              ),
            ],
          ),
        ),
      );
}
```

**Passo 2.** Na `Column` da `EstatisticasScreen`, acrescente um botão que a empilha:

```dart
OutlinedButton(
  onPressed: () => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ResumoSessaoScreen(materia: materia),
    ),
  ),
  child: const Text('Ir para o resumo'),
),
```

**Passo 3.** Rode `flutter run` e faça o caminho lista → detalhe → estatísticas → resumo. Antes de
tocar em "Concluir", **desenhe a pilha num papel**: são quatro rotas. Toque em "Concluir e voltar ao
início" e confira o console: **três `POP` seguidos** num único toque — é o `popUntil` trabalhando.

**Passo 4.** 🤖 No Android, repita o caminho e volte usando o **botão voltar do sistema**, um por
vez: os logs são os mesmos `POP`. Prova concreta de que o botão do sistema e o seu código mexem na
mesma pilha.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Comece pelos exercícios de **Fixação** e pelo primeiro de **Leitura de código**: eles cobrem
exatamente `push`, `pop`, `pushReplacement` e `popUntil`.

---

## 🏆 Desafio opcional

Implemente um **botão "Início" na `AppBar`** das telas internas: ele só aparece quando
`Navigator.canPop(context)` for `true`; ao ser tocado, volta até a primeira rota; e se a tela for a
única da pilha, o botão **não existe** (nem desabilitado). Depois responda por escrito, em duas
frases: por que usar `maybePop` nesse botão seria errado? (Dica: `maybePop` volta **uma** rota, e o
pedido é voltar **todas**.)

---

## 📌 Resumo

- O Flutter guarda as telas numa **pilha**: último a entrar, primeiro a sair.
- `Navigator.push` empilha; `Navigator.pop` desempilha. Só o topo é visível; os de baixo continuam
  vivos, com estado preservado. `MaterialPageRoute<T>` cria a rota, anima conforme a plataforma, e
  o `<T>` é o tipo do resultado devolvido ao fechar (aula 3).
- `pushReplacement` troca a rota do topo — ideal para splash → home e login → home.
- `popUntil(teste)` desempilha até a condição ser verdadeira; `rota.isFirst` é o teste seguro.
- `canPop` pergunta se há para onde voltar; `maybePop` volta **se puder** e respeita `PopScope`.
- 🤖 botão voltar do Android e 🍎 gesto de borda do iOS fazem o **mesmo** `pop` na **mesma** pilha.
- `fullscreenDialog: true` transforma a rota num formulário modal.
- Depois de todo `await`, cheque `mounted` (ou `context.mounted`) antes de usar `context`.

---

## ☑️ Checklist de domínio

- [ ] Explico "pilha" e "LIFO" com minhas palavras, e desenho a pilha de um fluxo de 4 telas.
- [ ] Escrevo `Navigator.of(context).push(MaterialPageRoute<void>(builder: ...))` de memória.
- [ ] Digo a diferença entre `push` e `pushReplacement` com um caso real de cada.
- [ ] Uso `popUntil` com `isFirst` e sei o risco de um predicado que nunca casa.
- [ ] Diferencio `pop` de `maybePop` e sei em qual botão usar cada um.
- [ ] Justifico `fullscreenDialog: true` numa tela de criação.
- [ ] Coloco `if (!mounted) return;` depois de um `await` sem precisar do aviso do lint.
- [ ] Rodei o `foco_navegacao` e vi os `PUSH`/`POP` no console.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Navigation and routing — docs.flutter.dev](https://docs.flutter.dev/ui/navigation)
- [Navigator class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Navigator-class.html)
- [MaterialPageRoute class — api.flutter.dev](https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html)
- [NavigatorObserver class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html)
- [use_build_context_synchronously — dart.dev](https://dart.dev/tools/linter-rules/use_build_context_synchronously)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — Rotas nomeadas](02-rotas-nomeadas.md) |
