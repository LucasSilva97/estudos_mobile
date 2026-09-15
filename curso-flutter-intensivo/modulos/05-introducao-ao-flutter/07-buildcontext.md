# Aula 7 — BuildContext

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar que `BuildContext` é a **posição de um widget na árvore**, e não uma variável mágica
  nem "o app inteiro".
- Descrever o que `Theme.of(context)` realmente faz: uma **busca para cima** na árvore.
- Usar `Theme.of`, `MediaQuery.sizeOf`, `Navigator.of` e `ScaffoldMessenger.of` sabendo o que cada
  um procura.
- Diagnosticar e corrigir o erro mais comum de todo iniciante em Flutter: **usar o `context` do
  widget que *criou* o `Scaffold`** em vez de um `context` abaixo dele.
- Resolver esse erro com **`Builder`** — e explicar por que extrair um widget resolve igualmente.
- Checar **`context.mounted`** depois de todo `await` e dizer o que acontece quando você não checa.
- Saber por que o `context` **não** pode ser usado dentro do `dispose()`.

## ✅ Pré-requisitos

- [Aula 3 — main, runApp e a árvore de widgets](03-main-runapp-arvore-de-widgets.md) — a distinção
  entre **Widget**, **Element** e **RenderObject**. Esta aula é a continuação direta dela.
- [Aula 5 — StatefulWidget e setState](05-statefulwidget-e-setstate.md) — o `ScaffoldMessenger`
  apareceu ali sem explicação; aqui ele é explicado.
- [Aula 6 — Ciclo de vida do State](06-ciclo-de-vida-do-state.md) — `initState`,
  `didChangeDependencies`, `dispose` e a checagem de `mounted`.
- O projeto `meu_primeiro_app` rodando com `flutter run -d chrome`.

---

## 📖 Conceito

### A pergunta que abre a aula

Você já escreveu esta linha várias vezes:

```dart
Widget build(BuildContext context) {
```

E já usou o `context` sem pensar:

```dart
final ThemeData tema = Theme.of(context);
```

Mas o que é, exatamente, esse `context`? De onde ele vem? Por que ele precisa ser **passado**
para o `Theme.of` em vez de o `Theme` simplesmente saber o tema sozinho?

A resposta inteira cabe em uma frase:

> **`BuildContext` é o endereço do seu widget dentro da árvore de widgets.**

Ele não carrega o tema. Ele não carrega o `Navigator`. Ele carrega **a sua posição** — e, a partir
dela, é possível *subir* pela árvore procurando quem tem o que você quer.

### Widget, Element e BuildContext

Na aula 3 você viu que existem três árvores paralelas:

| Árvore | O que é | Vida |
|---|---|---|
| **Widget** | A *descrição* da interface. Imutável, barata, descartável. | Recriada a cada `build` |
| **Element** | A *instância viva* que liga o widget à tela e guarda o estado. | Persiste entre builds |
| **RenderObject** | Quem mede, posiciona e pinta pixels. | Persiste entre builds |

Agora a peça que faltava:

> **`BuildContext` é o `Element`.**

Literalmente. Se você abrir o código-fonte do Flutter, vai encontrar
`abstract class Element extends DiagnosticableTree implements BuildContext`. O framework entrega
o `Element` para você disfarçado sob o nome `BuildContext`, expondo só a parte que é segura usar
de dentro de um `build`.

Isso explica três coisas de uma vez:

1. **Por que o `context` muda de widget para widget** — cada widget tem o seu próprio `Element`,
   na sua própria posição.
2. **Por que o `context` sabe subir a árvore** — o `Element` guarda uma referência ao pai.
3. **Por que o `context` deixa de valer quando o widget sai da tela** — o `Element` é desmontado.

### O que `.of(context)` faz por dentro

Quando você escreve:

```dart
final ThemeData tema = Theme.of(context);
```

O que acontece é, em português:

> "Começando na **minha** posição, suba pela árvore até encontrar o `InheritedWidget` mais próximo
> do tipo `_InheritedTheme`. Quando achar, devolva o `ThemeData` que ele carrega. E, já que estou
> aqui, **me inscreva**: se esse tema mudar, reconstrua o meu widget."

Duas coisas importantes nessa frase:

- A busca é **para cima**, nunca para baixo nem para os lados.
- A busca acha **o mais próximo**. Se houver dois `Theme` na árvore, você recebe o de baixo.

```text
MaterialApp            <- tem o Theme aqui dentro
 └─ Scaffold
     └─ Column
         └─ Text       <- Theme.of(context) daqui sobe e ENCONTRA ✅
```

E o caso que dá errado:

```text
MeuWidget              <- o context deste build...
 └─ Scaffold           <- ...está ACIMA do Scaffold
     └─ Column
```

Se, de dentro do `build` de `MeuWidget`, você procurar algo que o **próprio `Scaffold` fornece**,
a busca sobe e **não encontra** — porque o `Scaffold` está *abaixo* de você, não acima.

Esse é o erro que a seção "Erros comuns" desta aula disseca.

### Os quatro `.of` que você vai usar todo dia

**1. `Theme.of(context)`** — cores, fontes e estilos do app.

```dart
final ThemeData tema = Theme.of(context);
Text('Olá', style: tema.textTheme.titleLarge);
Container(color: tema.colorScheme.primary);
```

**2. `MediaQuery.sizeOf(context)`** — tamanho da tela, teclado, densidade, modo escuro do sistema.

```dart
final Size tela = MediaQuery.sizeOf(context);
final bool estreita = tela.width < 600;
```

> ⚠️ Prefira **`MediaQuery.sizeOf(context)`** a `MediaQuery.of(context).size`. O primeiro só
> reconstrói o seu widget quando o **tamanho** muda; o segundo reconstrói quando *qualquer coisa*
> do `MediaQuery` muda — inclusive a altura do teclado. Existem irmãos para cada campo:
> `MediaQuery.paddingOf`, `MediaQuery.viewInsetsOf`, `MediaQuery.platformBrightnessOf`.

**3. `Navigator.of(context)`** — empilhar e desempilhar telas.

```dart
Navigator.of(context).pop();
```

Assunto inteiro do [Módulo 07](../07-navegacao-e-formularios/01-navigator-a-pilha.md). Aqui só
interessa saber que ele também sobe a árvore, procurando o `Navigator` que o `MaterialApp` criou.

**4. `ScaffoldMessenger.of(context)`** — mensagens temporárias na base da tela (`SnackBar`).

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Sessão salva')),
);
```

> 📌 **Por que não `Scaffold.of(context).showSnackBar(...)`?** Porque essa API foi **removida**. Ela
> existia até 2020 e tinha um defeito grave: se a tela fosse trocada enquanto o `SnackBar` estava
> visível, a mensagem sumia junto. O `ScaffoldMessenger` vive **acima** do `Scaffold` — ele é criado
> pelo `MaterialApp` — então a mensagem sobrevive à troca de tela. Se você encontrar
> `Scaffold.of(context).showSnackBar` em um tutorial, o tutorial está desatualizado.

### `Builder`: um widget que só existe para criar um `context` novo

O `Builder` é o widget mais simples do Flutter inteiro. Ele não desenha nada. Ele recebe uma função
e devolve o que ela devolver:

```dart
Builder(
  builder: (BuildContext context) {
    // Este `context` é NOVO e está UM NÍVEL ABAIXO do context de fora.
    return Text(MediaQuery.sizeOf(context).width.toString());
  },
)
```

Por que isso é útil? Porque **todo widget cria um `Element` novo**, e o `builder` recebe o `context`
*desse* `Element`. Se você colocar um `Builder` como filho de um `Scaffold`, o `context` de dentro
dele está **abaixo** do `Scaffold` — e a busca para cima passa a encontrar o que antes não
encontrava.

O `Builder` é a solução de **uma linha** para o erro clássico. A solução *estrutural* é extrair um
widget de verdade — e é a que você deve preferir em código que vai crescer.

### `context` depois de um `await`: o perigo invisível

Este código parece correto e é uma das principais fontes de crash em apps Flutter:

```dart
Future<void> _salvar() async {
  await _repositorio.gravar(anotacao);          // demora 2 segundos
  ScaffoldMessenger.of(context).showSnackBar(   // 💥 pode explodir aqui
    const SnackBar(content: Text('Salvo!')),
  );
}
```

Durante esses 2 segundos o usuário pode ter apertado "voltar". O widget saiu da árvore, o `Element`
foi desmontado — e o `context` que você guardou virou um endereço para uma casa demolida.

A correção tem duas formas, e você vai ver as duas em código real:

```dart
// Dentro de um State: use `mounted` (propriedade do próprio State).
await _repositorio.gravar(anotacao);
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(...);
```

```dart
// Fora de um State (ex.: função que recebe o context): use `context.mounted`.
await _repositorio.gravar(anotacao);
if (!context.mounted) return;
ScaffoldMessenger.of(context).showSnackBar(...);
```

> O lint `use_build_context_synchronously` — ativado no `analysis_options.yaml` do curso — avisa
> sobre isso automaticamente. Ele é uma das melhores razões para rodar `flutter analyze` sempre.

**Alternativa que dispensa a checagem:** capture o que você precisa **antes** do `await`.

```dart
final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
await _repositorio.gravar(anotacao);
mensageiro.showSnackBar(const SnackBar(content: Text('Salvo!')));
```

Isso funciona porque o `ScaffoldMessengerState` **não é** o `context` — é um objeto que continua
válido mesmo que o seu widget saia da tela.

### Onde o `context` **não** pode ser usado

| Lugar | Pode? | Por quê |
|---|---|---|
| `build(context)` | ✅ | É para isso que ele existe |
| `initState()` | ⚠️ parcialmente | O `context` existe, mas ainda **não** pode chamar `.of(context)` que se inscreve em mudanças |
| `didChangeDependencies()` | ✅ | O primeiro lugar seguro para `Theme.of` / `MediaQuery.of` em um `State` |
| Callback de botão (`onPressed`) | ✅ | O widget está na tela naquele instante |
| Depois de um `await` | ⚠️ só com `mounted` | O widget pode ter saído |
| `dispose()` | ❌ | O `Element` já está sendo desmontado; a busca para cima não é confiável |

> Se você precisa de algo do `context` no `dispose` — por exemplo, remover um `SnackBar` —,
> **guarde a referência no `didChangeDependencies`** e use a referência guardada no `dispose`.

---

## 💡 Analogia

Imagine um prédio de escritórios com muitos andares.

- **A árvore de widgets** é o prédio.
- **Cada widget** é uma sala.
- **O `BuildContext`** é o crachá que diz: *"você está na sala 704"*. Ele não contém o café da
  empresa nem a impressora. Ele só diz onde você está.
- **`Theme.of(context)`** é você sair da sua sala e **subir** de andar em andar perguntando
  "vocês têm a paleta de cores oficial?" — até alguém dizer "temos, aqui está". Você nunca desce
  para procurar, e nunca vai para outra sala do mesmo andar.
- **O erro clássico** é estar na sala 704 procurando algo que está guardado na sala 803 — um
  andar **acima de onde a coisa está**, e não abaixo. Você sobe, sobe, chega ao telhado e não acha.
- **O `Builder`** é você pedir emprestada uma mesa no andar de baixo antes de começar a procurar.
  Do andar certo, a mesma pergunta encontra resposta.
- **`context.mounted`** é conferir se a sua sala ainda existe antes de voltar para ela. Se a
  empresa se mudou enquanto você estava no elevador, voltar para a sala 704 não faz sentido.

---

## 🧪 Exemplo mínimo

Este programa mostra o `context` sendo o que ele é: uma posição. Rode e leia o console.

> **Arquivo:** `meu_primeiro_app/lib/main.dart` (temporário — é só para experimentar)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppDemo());

class AppDemo extends StatelessWidget {
  const AppDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // AQUI o Theme ainda NÃO existe: o MaterialApp é criado abaixo desta linha.
    debugPrint('AppDemo   -> $context');

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TelaDemo(),
    );
  }
}

class TelaDemo extends StatelessWidget {
  const TelaDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // AQUI o Theme existe: estamos ABAIXO do MaterialApp.
    final ThemeData tema = Theme.of(context);
    debugPrint('TelaDemo  -> $context');
    debugPrint('cor primária encontrada: ${tema.colorScheme.primary}');

    return Scaffold(
      appBar: AppBar(title: const Text('BuildContext')),
      body: Column(
        children: <Widget>[
          Builder(
            builder: (BuildContext contextInterno) {
              // Um context DIFERENTE, um nível abaixo.
              debugPrint('Builder   -> $contextInterno');
              return Text(
                'Largura: ${MediaQuery.sizeOf(contextInterno).width.toInt()} px',
              );
            },
          ),
        ],
      ),
    );
  }
}
```

Saída no console (os números mudam, a estrutura não):

```text
AppDemo   -> AppDemo
TelaDemo  -> TelaDemo
cor primária encontrada: Color(0xff006a60)
Builder   -> Builder
```

Três `context` diferentes, três posições diferentes. **Não existe "o context" do app.**

---

## 📱 Aplicando no Flutter

Agora o `meu_primeiro_app`. A `HomeTela` da aula 6 já usa `ScaffoldMessenger.of(context)` e
funciona — porque ela é um `StatefulWidget` cujo `context` fica **acima** do `Scaffold`, e o
`ScaffoldMessenger` que ela procura vive no `MaterialApp`, mais acima ainda. A busca sobe e acha.

Nesta aula você vai:

1. Adicionar um botão **"Resumo do dia"** na `AppBar`, que abre um `showModalBottomSheet` —
   e ver por que ele precisa do `context` certo.
2. Criar um widget `BarraResumo` que se adapta à **largura da tela** usando `MediaQuery.sizeOf`.
3. Adicionar um botão **"Salvar progresso"** com `await` de verdade, e proteger o `context` depois
   dele.
4. Ver, na prática, o erro de `Scaffold` e corrigi-lo com `Builder`.

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/lib/widgets/barra_resumo.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Faixa de resumo que muda de formato conforme a largura disponível.
///
/// Existe para mostrar três usos de BuildContext em um widget só:
/// Theme.of, MediaQuery.sizeOf e a passagem explícita de context.
class BarraResumo extends StatelessWidget {
  const BarraResumo({
    super.key,
    required this.sessoesConcluidas,
    required this.minutosTotais,
  });

  final int sessoesConcluidas;
  final int minutosTotais;

  @override
  Widget build(BuildContext context) {
    // 1) Theme: sobe a árvore até o MaterialApp e se inscreve em mudanças.
    final ThemeData tema = Theme.of(context);

    // 2) MediaQuery: só o tamanho, com sizeOf (não com .of(context).size).
    final double largura = MediaQuery.sizeOf(context).width;
    final bool estreita = largura < 600;

    final List<Widget> blocos = <Widget>[
      _Metrica(
        rotulo: 'Sessões',
        valor: '$sessoesConcluidas',
        icone: Icons.check_circle_outline,
      ),
      _Metrica(
        rotulo: 'Minutos',
        valor: '$minutosTotais',
        icone: Icons.schedule,
      ),
      _Metrica(
        rotulo: 'Média',
        valor: sessoesConcluidas == 0
            ? '—'
            : '${(minutosTotais / sessoesConcluidas).round()} min',
        icone: Icons.trending_up,
      ),
    ];

    return Card(
      color: tema.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Resumo', style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),

            // Layout adaptado à largura: empilhado no estreito, lado a lado no largo.
            if (estreita)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final Widget bloco in blocos) ...<Widget>[
                    bloco,
                    const SizedBox(height: 8),
                  ],
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: blocos,
              ),

            const SizedBox(height: 8),
            Text(
              'Largura da janela: ${largura.toInt()} px '
              '(${estreita ? 'estreita' : 'larga'})',
              style: tema.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.rotulo,
    required this.valor,
    required this.icone,
  });

  final String rotulo;
  final String valor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    // Este é OUTRO context — o de _Metrica, abaixo do de BarraResumo.
    final ThemeData tema = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icone, size: 20, color: tema.colorScheme.primary),
        const SizedBox(width: 8),
        Text(valor, style: tema.textTheme.titleMedium),
        const SizedBox(width: 4),
        Text(rotulo, style: tema.textTheme.bodySmall),
      ],
    );
  }
}
```

Agora a tela. Repare especialmente no `Builder` da `AppBar` e na função `_salvarProgresso`.

> **Arquivo:** `meu_primeiro_app/lib/telas/home_tela.dart` (substitua o arquivo inteiro)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/widgets/barra_resumo.dart';
import 'package:meu_primeiro_app/widgets/cartao_materia.dart';
import 'package:meu_primeiro_app/widgets/cronometro_sessao.dart';

class HomeTela extends StatefulWidget {
  const HomeTela({super.key});

  @override
  State<HomeTela> createState() => _HomeTelaState();
}

class _HomeTelaState extends State<HomeTela> {
  final Map<String, int> _minutosPorMateria = <String, int>{
    'Dart': 95,
    'Flutter': 40,
    'Git e terminal': 20,
  };

  static const Map<String, int> _metas = <String, int>{
    'Dart': 120,
    'Flutter': 120,
    'Git e terminal': 90,
  };

  static const Map<String, IconData> _icones = <String, IconData>{
    'Dart': Icons.code,
    'Flutter': Icons.phone_android,
    'Git e terminal': Icons.terminal,
  };

  String _materiaSelecionada = 'Dart';
  int _sessoesConcluidas = 0;
  int _duracaoMinutos = 25;
  bool _salvando = false;

  int get _minutosTotais =>
      _minutosPorMateria.values.fold(0, (int soma, int m) => soma + m);

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Primeiro lugar SEGURO para ler o context em um State.
    // No initState isto lançaria erro.
    final Brightness brilho = MediaQuery.platformBrightnessOf(context);
    debugPrint('Tema do sistema: ${brilho == Brightness.dark ? 'escuro' : 'claro'}');
  }

  // ── Ações ─────────────────────────────────────────────────────────────────

  void _aoConcluirSessao(String anotacao) {
    setState(() {
      _sessoesConcluidas++;
      final int atual = _minutosPorMateria[_materiaSelecionada] ?? 0;
      _minutosPorMateria[_materiaSelecionada] = atual + _duracaoMinutos;
    });

    final String detalhe = anotacao.isEmpty ? '' : ' — $anotacao';

    // O context deste State está ACIMA do Scaffold, mas o ScaffoldMessenger
    // está no MaterialApp, ainda mais acima. Por isso esta busca funciona.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('+$_duracaoMinutos min em $_materiaSelecionada$detalhe')),
    );
  }

  void _selecionar(String materia) {
    setState(() {
      _materiaSelecionada = materia;
    });
  }

  /// Simula uma gravação demorada. O ponto da aula está nas três linhas
  /// depois do await.
  Future<void> _salvarProgresso() async {
    setState(() => _salvando = true);

    // FORMA 1 — capturar ANTES do await o que vai ser usado DEPOIS.
    // Um ScaffoldMessengerState continua válido mesmo se este widget sair.
    final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);

    await Future<void>.delayed(const Duration(seconds: 2));

    // FORMA 2 — checar mounted antes de tocar em setState ou no context.
    // Sem esta linha, sair da tela durante os 2 segundos causaria o erro
    // "setState() called after dispose()".
    if (!mounted) return;

    setState(() => _salvando = false);
    mensageiro.showSnackBar(
      const SnackBar(content: Text('Progresso salvo.')),
    );
  }

  void _abrirResumo(BuildContext contextDoBotao) {
    // showModalBottomSheet precisa de um context que enxergue o Navigator.
    // O Navigator vem do MaterialApp (acima), então qualquer context daqui
    // para baixo serve. O que NÃO serviria é um context acima do MaterialApp.
    showModalBottomSheet<void>(
      context: contextDoBotao,
      showDragHandle: true,
      builder: (BuildContext contextDaFolha) {
        // Um context NOVO, criado dentro da rota da folha.
        final ThemeData tema = Theme.of(contextDaFolha);

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Resumo do dia', style: tema.textTheme.headlineSmall),
              const SizedBox(height: 16),
              for (final MapEntry<String, int> e in _minutosPorMateria.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(e.key, style: tema.textTheme.bodyLarge),
                      Text('${e.value} min', style: tema.textTheme.bodyLarge),
                    ],
                  ),
                ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Total', style: tema.textTheme.titleMedium),
                  Text('$_minutosTotais min', style: tema.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                // Fecha a folha. Este Navigator é o da ROTA da folha —
                // por isso usamos contextDaFolha, e não o context da tela.
                onPressed: () => Navigator.of(contextDaFolha).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final List<String> materias = _minutosPorMateria.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Primeiro App'),
        actions: <Widget>[
          // ┌─ O PONTO DA AULA ────────────────────────────────────────────┐
          // │ Sem o Builder, o `context` aqui seria o de _HomeTelaState,   │
          // │ que está ACIMA deste Scaffold. Para o showModalBottomSheet   │
          // │ isso ainda funcionaria (o Navigator está mais acima), mas    │
          // │ qualquer coisa fornecida PELO Scaffold falharia.             │
          // │ O Builder cria um context abaixo — hábito que evita a classe │
          // │ inteira desses erros.                                        │
          // └──────────────────────────────────────────────────────────────┘
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          BarraResumo(
            sessoesConcluidas: _sessoesConcluidas,
            minutosTotais: _minutosTotais,
          ),
          const SizedBox(height: 16),

          SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 15, label: Text('15 min')),
              ButtonSegment<int>(value: 25, label: Text('25 min')),
              ButtonSegment<int>(value: 50, label: Text('50 min')),
            ],
            selected: <int>{_duracaoMinutos},
            onSelectionChanged: (Set<int> selecao) {
              setState(() {
                _duracaoMinutos = selecao.first;
              });
            },
          ),
          const SizedBox(height: 16),

          CronometroSessao(
            duracaoMinutos: _duracaoMinutos,
            onConcluir: _aoConcluirSessao,
          ),
          const SizedBox(height: 24),

          Text('Matérias', style: tema.textTheme.titleLarge),
          const SizedBox(height: 12),

          for (final String materia in materias) ...<Widget>[
            CartaoMateria(
              nome: materia,
              minutosEstudados: _minutosPorMateria[materia] ?? 0,
              metaMinutos: _metas[materia] ?? 60,
              icone: _icones[materia] ?? Icons.menu_book_outlined,
              onTap: () => _selecionar(materia),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _salvando ? null : _salvarProgresso,
            icon: _salvando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_salvando ? 'Salvando…' : 'Salvar progresso'),
          ),
        ],
      ),
    );
  }
}
```

Rode e teste os dois comportamentos que importam:

```powershell
flutter analyze
flutter run -d chrome
```

1. Redimensione a janela do Chrome de estreita para larga. A `BarraResumo` muda de coluna para
   linha sozinha — `MediaQuery.sizeOf` reconstruiu o widget.
2. Aperte **"Salvar progresso"** e observe o `SnackBar` aparecer 2 segundos depois.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `Theme.of(context)` em `BarraResumo` e em `_Metrica` | São **dois contexts diferentes**, em posições diferentes, e ambos encontram o mesmo tema. A busca é para cima; o tema está lá em cima. |
| `MediaQuery.sizeOf(context)` | Só se inscreve em mudanças de **tamanho**. `MediaQuery.of(context).size` reconstruiria o widget também quando o teclado abrisse. |
| `final bool estreita = largura < 600` | 600 px é o ponto de corte que o Material Design usa para separar telefone de tablet. |
| `didChangeDependencies` com `MediaQuery.platformBrightnessOf` | Este é o **primeiro lugar seguro** de um `State` para ler algo do `context`. No `initState` a mesma linha lançaria erro. |
| `final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);` **antes** do `await` | Captura o objeto enquanto o widget certamente está vivo. Depois do `await`, usar `mensageiro` é seguro mesmo sem `context`. |
| `if (!mounted) return;` depois do `await` | Protege o `setState`. `mounted` é propriedade do `State`; fora de um `State`, o equivalente é `context.mounted`. |
| `Builder(builder: (contextAbaixoDoScaffold) => IconButton(...))` | Cria um `Element` novo **dentro** da subárvore do `Scaffold`. O `context` que ele entrega enxerga o `Scaffold` acima de si. |
| `Navigator.of(contextDaFolha).pop()` | Fecha **a folha**, não a tela. Se usássemos o `context` da `HomeTela`, o `pop` tentaria desempilhar a tela inteira. |
| `showModalBottomSheet(context: ...)` recebendo um `context` explícito | Mostra que `context` é um **argumento como outro qualquer** — dá para passar de função em função. |
| `onPressed: _salvando ? null : _salvarProgresso` | `null` desabilita o botão; impede duas gravações simultâneas. |
| `_minutosTotais` como getter com `fold` | Valor **derivado**. Nunca guarde em campo o que dá para calcular — ele ficaria desatualizado. |

---

## 🤖🍎 Android × iOS

O `BuildContext` é idêntico nas duas plataformas: ele é uma estrutura do framework Dart, não do
sistema operacional. O que muda é **o que você encontra ao subir a árvore**:

| Item | 🤖 Android | 🍎 iOS |
|---|---|---|
| `MediaQuery.paddingOf(context).top` | Altura da barra de status (varia com o recorte da câmera) | Altura do *notch* / Dynamic Island |
| `MediaQuery.paddingOf(context).bottom` | Geralmente `0`; com navegação por gestos, alguns px | Altura da barra de gestos do iPhone |
| `MediaQuery.viewInsetsOf(context).bottom` | Altura do teclado — muda conforme o teclado instalado | Altura do teclado do sistema |
| `Theme.of(context).platform` | `TargetPlatform.android` | `TargetPlatform.iOS` |

> 📌 Nunca escreva um número fixo para "a altura da barra de status". Use
> `MediaQuery.paddingOf(context).top` ou, melhor ainda, coloque o conteúdo dentro de um
> `SafeArea` — que faz essa conta por você, em qualquer aparelho.

---

## ⚠️ Erros comuns

### 1. `No Scaffold widget found` — o erro clássico

```dart
class MinhaTela extends StatelessWidget {
  const MinhaTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          // ❌ Este context é o de MinhaTela, que está ACIMA do Scaffold.
          Scaffold.of(context).openDrawer();
        },
        child: const Text('Abrir menu'),
      ),
    );
  }
}
```

Mensagem no console:

```text
Scaffold.of() called with a context that does not contain a Scaffold.
```

**O que o Flutter está dizendo:** "subi a partir da posição que você me deu e não encontrei
nenhum `Scaffold`". E é verdade — o `Scaffold` está **abaixo** do `context` de `MinhaTela`.

**Correção 1 — `Builder`:**

```dart
body: Builder(
  builder: (BuildContext context) => ElevatedButton(
    onPressed: () => Scaffold.of(context).openDrawer(), // ✅
    child: const Text('Abrir menu'),
  ),
),
```

**Correção 2 — extrair um widget** (preferida quando o trecho vai crescer):

```dart
class _BotaoMenu extends StatelessWidget {
  const _BotaoMenu();

  @override
  Widget build(BuildContext context) {
    // O context de _BotaoMenu já nasce abaixo do Scaffold.
    return ElevatedButton(
      onPressed: () => Scaffold.of(context).openDrawer(), // ✅
      child: const Text('Abrir menu'),
    );
  }
}
```

### 2. Chamar `.of(context)` dentro do `initState`

```dart
@override
void initState() {
  super.initState();
  final ThemeData tema = Theme.of(context); // ❌
}
```

```text
dependOnInheritedWidgetOfExactType<_InheritedTheme>() or
dependOnInheritedElement() was called before _MeuState.initState() completed.
```

**Correção:** mova para `didChangeDependencies`.

```dart
late ThemeData _tema;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _tema = Theme.of(context); // ✅
}
```

> Exceção: `.of(context, listen: false)` e leituras que **não se inscrevem** funcionam no
> `initState` — mas, enquanto você está aprendendo, a regra simples ("nada de `.of` no
> `initState`") evita mais problemas do que atrapalha.

### 3. Usar o `context` depois do `await` sem checar

```dart
Future<void> _acao() async {
  await Future<void>.delayed(const Duration(seconds: 3));
  Navigator.of(context).pop(); // ❌ se o usuário já saiu, explode
}
```

```text
Looking up a deactivated widget's ancestor is unsafe.
```

**Correção:**

```dart
Future<void> _acao() async {
  await Future<void>.delayed(const Duration(seconds: 3));
  if (!mounted) return;              // ✅
  Navigator.of(context).pop();
}
```

### 4. Usar o `context` no `dispose`

```dart
@override
void dispose() {
  ScaffoldMessenger.of(context).hideCurrentSnackBar(); // ❌
  super.dispose();
}
```

**Correção — guarde a referência antes:**

```dart
ScaffoldMessengerState? _mensageiro;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _mensageiro = ScaffoldMessenger.of(context); // ✅ guardado enquanto é seguro
}

@override
void dispose() {
  _mensageiro?.hideCurrentSnackBar(); // ✅ usa a referência, não o context
  super.dispose();
}
```

### 5. Guardar o `context` em um campo da classe

```dart
class _MeuState extends State<Meu> {
  late BuildContext _contextGuardado; // ❌ nunca faça isso

  @override
  Widget build(BuildContext context) {
    _contextGuardado = context;
    return const SizedBox();
  }
}
```

O `Element` pode ser desmontado a qualquer momento. Um `BuildContext` guardado é uma bomba-relógio.
**Passe o `context` como argumento** para quem precisa dele, no momento em que precisa.

### 6. Achar que `context` é o "app" e reutilizá-lo em outra tela

```dart
// ❌ passar o context de uma tela para uma função que roda em outra tela
void mostrarEmQualquerLugar(BuildContext context) { ... }
```

Um `context` só é válido **enquanto aquele widget estiver montado**. Para mensagens que precisam
sobreviver a trocas de tela, guarde o `ScaffoldMessengerState` (como fizemos em `_salvarProgresso`)
ou use uma `GlobalKey<ScaffoldMessengerState>` no `MaterialApp` — técnica que o
[Módulo 08](../08-estado-e-arquitetura/01-o-problema-do-estado.md) revisita.

---

## 🛠️ Exercício guiado

**Passo 1.** No `meu_primeiro_app`, crie um `Drawer` no `Scaffold` da `HomeTela` com dois
`ListTile` quaisquer.

**Passo 2.** Adicione, **no `body`** (não na `AppBar`), um `TextButton` com o texto "Abrir menu"
que chama `Scaffold.of(context).openDrawer()`. Use o `context` do `build` da `HomeTela`.

**Passo 3.** Rode e aperte o botão. Leia a mensagem de erro **inteira**, sem pular. Anote em uma
frase o que o Flutter está reclamando.

**Passo 4.** Corrija envolvendo o `TextButton` em um `Builder`. Rode de novo e confirme que o menu
abre.

**Passo 5.** Agora corrija de outra forma: apague o `Builder` e extraia o botão para um
`class _BotaoAbrirMenu extends StatelessWidget`. Confirme que funciona igual.

**Passo 6.** Responda por escrito: as duas correções resolvem o mesmo problema pelo mesmo motivo?
Qual você usaria em um app que vai crescer, e por quê?

**Passo 7.** Em `_salvarProgresso`, comente a linha `if (!mounted) return;`. Rode `flutter analyze`
e veja o aviso do lint `use_build_context_synchronously` aparecer. Depois descomente. Você acabou
de ver por que essa linha existe — e que a ferramenta te avisa antes do usuário.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Faça os exercícios de **Compreensão** sobre a busca para cima, o de **Correção de bugs** com o
`Scaffold.of`, e o de **Aplicação** que pede um widget adaptado por `MediaQuery`.

---

## 🏆 Desafio opcional

Escreva um widget `DiagnosticoContext` que, ao ser tocado, imprima no console **a lista de
ancestrais** do próprio `context`, de baixo para cima, até a raiz.

Dica: `context.visitAncestorElements((Element e) { ... return true; })` — devolver `true` continua
subindo, `false` para a busca.

Depois responda: quantos widgets existem entre o seu botão e o `MaterialApp`? O número te
surpreendeu? Esses widgets intermediários são a razão pela qual a busca do `.of(context)` precisa
ser eficiente — e ela é, porque cada `Element` guarda um mapa direto dos `InheritedWidget`
que existem acima dele.

---

## 📌 Resumo

- `BuildContext` é a **posição do widget na árvore**. Por baixo dos panos, ele **é** o `Element`.
- Cada widget tem o seu próprio `context`. **Não existe "o context" do aplicativo.**
- `.of(context)` **sobe** a árvore procurando o ancestral mais próximo do tipo pedido — e inscreve
  o seu widget para reconstruir quando aquele ancestral mudar.
- A busca nunca desce nem vai para os lados. Por isso um `context` **acima** do `Scaffold` não
  encontra o `Scaffold`.
- `Builder` cria um `context` um nível abaixo — correção de uma linha para esse erro. Extrair um
  widget resolve do mesmo jeito e é melhor para código que cresce.
- Prefira `MediaQuery.sizeOf(context)` a `MediaQuery.of(context).size`: menos rebuilds.
- `ScaffoldMessenger.of(context).showSnackBar(...)` é a API atual. `Scaffold.of(...).showSnackBar`
  não existe mais.
- Depois de todo `await`: `if (!mounted) return;` dentro de um `State`, ou
  `if (!context.mounted) return;` fora dele. Ou capture o objeto **antes** do `await`.
- **Nunca** use o `context` no `dispose` nem guarde um `context` em campo de classe.
- No `initState` o `context` existe, mas `.of(context)` ainda não pode ser chamado — use o
  `didChangeDependencies`.

---

## ☑️ Checklist de domínio

- [ ] Explico `BuildContext` em uma frase sem usar a palavra "mágico".
- [ ] Digo qual das três árvores (Widget, Element, RenderObject) o `BuildContext` realmente é.
- [ ] Descrevo o que `Theme.of(context)` faz em duas etapas: busca e inscrição.
- [ ] Sei dizer por que a busca para cima **não encontra** um `Scaffold` criado abaixo.
- [ ] Corrijo `Scaffold.of() called with a context that does not contain a Scaffold` de duas formas.
- [ ] Uso `MediaQuery.sizeOf` e explico por que é melhor que `MediaQuery.of(context).size`.
- [ ] Uso `ScaffoldMessenger.of(context)` e explico por que ele vive acima do `Scaffold`.
- [ ] Coloco `if (!mounted) return;` depois de todo `await` que antecede um `setState` ou um
      `.of(context)`.
- [ ] Sei capturar um `ScaffoldMessengerState` antes do `await` como alternativa.
- [ ] Sei por que o `context` não pode ser usado no `dispose` e como contornar.
- [ ] Nunca guardo `BuildContext` em campo de classe.
- [ ] `flutter analyze` termina com `No issues found!` — inclusive sem avisos de
      `use_build_context_synchronously`.

---

## 📚 Referências oficiais

- [BuildContext class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
- [Element class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Element-class.html)
- [Builder class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Builder-class.html)
- [MediaQuery.sizeOf — api.flutter.dev](https://api.flutter.dev/flutter/widgets/MediaQuery/sizeOf.html)
- [ScaffoldMessenger class — api.flutter.dev](https://api.flutter.dev/flutter/material/ScaffoldMessenger-class.html)
- [use_build_context_synchronously — dart.dev](https://dart.dev/tools/linter-rules/use_build_context_synchronously)
- [Flutter architectural overview — docs.flutter.dev](https://docs.flutter.dev/resources/architectural-overview)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Ciclo de vida do State](06-ciclo-de-vida-do-state.md) | [README](README.md) | [Aula 8 — Hot reload e hot restart](08-hot-reload-e-hot-restart.md) |
