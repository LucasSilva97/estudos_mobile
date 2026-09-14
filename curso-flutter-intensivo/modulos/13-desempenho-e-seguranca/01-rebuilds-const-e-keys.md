# Aula 1 — Rebuilds, const e keys

> **Módulo:** 13 - Desempenho, Acessibilidade e Segurança · **Tempo estimado:** 55 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Listar as **quatro** situações que disparam um `build()` no Flutter.
- Explicar por que `build` roda muitas vezes por segundo e por que isso obriga o método a ser barato.
- Usar `const` em widgets e descrever o **mecanismo real** do ganho.
- Justificar por que **extrair um widget** é diferente (e melhor) do que extrair um método que
  devolve `Widget`.
- Limitar o escopo do rebuild com `Consumer` (Riverpod 3) e `ValueListenableBuilder`.
- Explicar o que `RepaintBoundary` faz — e por que ele resolve **repaint**, não **rebuild**.
- Diferenciar `ValueKey`, `ObjectKey`, `UniqueKey` e `GlobalKey`.
- Reproduzir e corrigir o bug clássico da **lista reordenada sem key**.
- Contar rebuilds com `debugPrintRebuildDirtyWidgets` e com o DevTools.

## ✅ Pré-requisitos

- [Módulo 05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md): você sabe o que é um
  widget, o que `setState` faz e o que é `BuildContext`.
- [Módulo 12 — Testes e Debug](../12-testes-e-debug/03-devtools.md): você já abriu o DevTools.
- Flutter 3.47.1 funcionando. Confirme com `flutter --version`.

---

## 📖 Conceito

### As três árvores

Quando você escreve `const Text('Álgebra')`, você **não** cria algo que aparece na tela: cria uma
**descrição** do que deve aparecer. O Flutter mantém três estruturas paralelas:

| Árvore | O que é | Quem cria |
|---|---|---|
| **Widget** | A descrição, imutável e barata. Um objeto Dart comum. | Você, a cada `build()` |
| **Element** | O "cargo" que liga um widget a um pedaço da tela. Guarda o `State`. | O Flutter |
| **RenderObject** | Quem mede, posiciona e pinta pixels. Caro de criar. | O Flutter |

A árvore de **widgets** é descartada e recriada o tempo todo — por isso precisa ser barata. As de
**element** e **render object** são preservadas e **atualizadas**; o trabalho caro é layout e
pintura. O objetivo da aula é evitar que widgets reconstruídos à toa arrastem esse trabalho junto.

### O que dispara um `build()`

São exatamente quatro caminhos. Decore-os:

1. **`setState()`** — marca aquele `Element` como "sujo" (*dirty*); ele reconstrói no próximo frame.
2. **O pai reconstruiu** — ao reconstruir, o pai devolve filhos novos, e o Flutter compara cada
   filho novo com o antigo. Isso, por padrão, reconstrói a subárvore.
3. **Uma dependência mudou** — se o seu `build` chamou `Theme.of(context)`, `MediaQuery.of(context)`
   ou `ref.watch(...)`, ele se **inscreveu** naquela informação. Quando ela muda, você reconstrói.
4. **Um listenable notificou** — `AnimationController`, `ValueNotifier`, `ScrollController` e
   parentes disparam rebuild em quem os escuta.

### Por que `build` roda tanto

A meta do Flutter é entregar um frame a cada **16,67 ms** (60 quadros por segundo); em telas de
120 Hz o orçamento cai para **8,3 ms**. Dentro dele cabem construir widgets, calcular layout, pintar
e enviar para a GPU. Durante uma rolagem, uma animação ou o cronômetro da tela de sessão do **Foco**,
`build` roda 60 vezes por segundo — com 300 widgets na árvore, são 18.000 chamadas por segundo. Cada
uma precisa custar quase nada. A regra é literal:

> **`build()` deve apenas montar widgets.** Nada de ler arquivo, chamar rede, ordenar lista grande,
> criar `Random()`, formatar 500 datas ou instanciar controladores. Se `build` "faz" alguma coisa
> além de descrever a tela, está errado.

### `const`: o que ganha, e por quê

Ao reconstruir um pai, o Flutter chama `Element.updateChild` para cada filho, e a primeira
verificação é de **identidade**: se o widget novo é **o mesmo objeto** que o antigo (`identical`),
ele pula a atualização daquela subárvore inteira. `const` faz exatamente isso acontecer, porque
expressões `const` são **canonizadas** pelo Dart: existe **uma única instância** de
`const Text('Álgebra')` no programa todo. A cada `build` você devolve *a mesma instância*, o Flutter
compara, vê que é idêntica e não desce. Sem `const`, um `Text` novo nasce a cada frame, a comparação
falha e a subárvore é atualizada.

O ganho de um `const` isolado é pequeno; o de um **cabeçalho com 40 widgets dentro**, numa tela que
anima, é grande — o corte acontece no topo e os 40 somem do trabalho.

> `const` só é possível se **tudo** dentro do widget for constante em tempo de compilação. Por isso o
> curso insiste que modelos como `Materia` tenham **construtor `const`**: sem isso, nenhum widget que
> os receba pode ser `const`.

### Extrair widget × extrair método

Esta é a otimização mais mal compreendida do Flutter. Trocar `Widget _construirCabecalho() { ... }`
por `class Cabecalho extends StatelessWidget { ... }` **não** é uma mudança estética:

| | Método | Widget extraído |
|---|---|---|
| Tem `Element` próprio? | Não — os widgets viram filhos diretos do pai | Sim |
| Pode ser `const`? | Não | Sim, quando não depende de nada variável |
| Reconstrói quando o pai reconstrói? | **Sempre** | Só se o widget dele mudou |
| Aparece separado no DevTools? | Não | Sim — dá para medir |
| Pode ter `State` próprio? | Não | Sim |

Método que devolve widget **não isola nada**; ele só organiza o texto do arquivo.

### Limitando o escopo do rebuild

A ideia geral: **quem depende do dado que muda deve ser o menor widget possível**. Com Riverpod 3
isso se faz com `Consumer`, que recebe um `builder` e só reconstrói o que está dentro dele:

```dart
Consumer(
  builder: (BuildContext context, WidgetRef ref, Widget? filho) {
    final int minutos = ref.watch(minutosDaSessaoProvider);
    return Text('$minutos min');
  },
)
```

Se a tela fosse um `ConsumerWidget` com `ref.watch` no topo, ela inteira reconstruiria a cada
segundo. Sem Riverpod, o equivalente do SDK é `ValueListenableBuilder`, que escuta um
`ValueNotifier`. Os dois têm o parâmetro `child`: construído **uma vez**, fora do `builder`, ele
chega pronto lá dentro — é o jeito oficial de tirar do rebuild a parte que não muda.

### `RepaintBoundary`: repaint não é rebuild

- **Rebuild** = rodar `build()` de novo e comparar widgets.
- **Repaint** = redesenhar pixels.

Por padrão, widgets vizinhos compartilham a mesma **camada** de pintura: se um se anima, a camada
inteira é repintada — inclusive um gráfico caro e parado ao lado. `RepaintBoundary(child: ...)` põe o
filho numa camada separada, e o resto é reaproveitado. Custa memória (mais uma camada), então não
saia embrulhando tudo: use onde algo animado convive com algo caro e estático, e confirme no
DevTools. O `ListView.builder` já coloca `RepaintBoundary` em cada item; lá você não repete.

### Keys: a identidade do widget

Ao atualizar a árvore, o Flutter decide se o `Element` antigo pode ser reaproveitado para o widget
novo. A regra é `Widget.canUpdate(antigo, novo)`, verdadeira quando:

```text
antigo.runtimeType == novo.runtimeType   E   antigo.key == novo.key
```

Sem key, `key` é `null` dos dois lados — então **qualquer** `MateriaTile` casa com **qualquer** outro
na mesma posição. É aí que nasce o bug clássico.

| Key | Quando usar | Cuidado |
|---|---|---|
| `ValueKey(valor)` | O item tem identificador estável: `ValueKey(materia.id)` | O valor precisa ser **único** na lista |
| `ObjectKey(objeto)` | A identidade é o próprio objeto (compara por `identical`) | Se você recria o objeto a cada frame, a key muda |
| `UniqueKey()` | Forçar um widget novo, **descartando** o estado | Criada dentro de `build`, destrói o estado a cada frame |
| `GlobalKey()` | Alcançar o `State` de fora, ou mover o widget de lugar mantendo estado | Cara; nunca crie dentro de `build` |

> `GlobalKey<FormState>` é o caso legítimo mais comum: guardada num campo do `State` e usada em
> `_formKey.currentState!.validate()`. Você já fez isso no módulo 07.

---

## 💡 Analogia

Pense na lista de matérias como um **quadro de avisos com fichas presas por clipes**. O **widget** é
a ficha impressa (barata, descartável); o **element** é o clipe, que segura a posição e o histórico
daquela vaga; o **render object** é o furo na parede, caro e refeito com relutância. Ao imprimir
fichas novas, o funcionário compara ficha nova com ficha velha, clipe a clipe — e se a ficha é
**fisicamente a mesma folha** (`const`), nem tira do clipe.

A **key** é o nome escrito no canto da ficha. Sem nome, o funcionário assume que a ficha da posição 3
continua sendo "a da posição 3" — e se você reordenou tudo, o post-it amarelo grudado na ficha de
Álgebra fica na terceira vaga, agora ocupada por Física. O post-it é o `State`. Esse é o bug inteiro,
em uma frase.

---

## 🧪 Exemplo mínimo

Crie o projeto do módulo:

```powershell
flutter create foco_desempenho
```

Entre na pasta, abra `lib/main.dart` e substitua tudo por este teste de uma palavra:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Exemplo()));

class Exemplo extends StatefulWidget {
  const Exemplo({super.key});
  @override
  State<Exemplo> createState() => _ExemploState();
}

class _ExemploState extends State<Exemplo> {
  int _toques = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: <Widget>[
          const _Barulhento(rotulo: 'SOU const'), // constrói 1 vez
          _Barulhento(rotulo: 'NÃO sou const'), // constrói a cada toque
          FilledButton(
            onPressed: () => setState(() => _toques++),
            child: Text('Tocar ($_toques)'),
          ),
        ]),
      );
}

class _Barulhento extends StatelessWidget {
  const _Barulhento({required this.rotulo});
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    debugPrint('build de $rotulo');
    return Text(rotulo);
  }
}
```

Rode com `flutter run -d windows`, toque cinco vezes e olhe o terminal: `SOU const` aparece **uma**
vez; `NÃO sou const` aparece **seis**. Mesma classe, mesmo conteúdo — a única diferença é a palavra
`const`.

---

## 📱 Aplicando no Flutter

Agora o caso real do **Foco**. A aba "Matérias" tem três partes: um cabeçalho fixo com a meta da
semana, um cronômetro que atualiza a cada segundo e a lista de matérias. Se tudo estiver no mesmo
`build`, o cronômetro reconstrói cabeçalho e lista 60 vezes por minuto — trabalho 100 % desperdiçado.

O que vamos fazer, em ordem:

1. Criar o modelo `Materia` com **construtor `const`**.
2. Separar o cabeçalho num widget próprio, marcado `const`.
3. Isolar o cronômetro dentro de um `ValueListenableBuilder`.
4. Montar a lista com `ListView.builder` e `ValueKey(materia.id)` em cada item.
5. Colocar um botão "inverter" e um interruptor de keys, para você **ver o bug acontecer**.

---

## 💻 Código completo

> **Arquivo:** `foco_desempenho/lib/features/materias/domain/materia.dart`
> **Como executar:** usado pelo `main.dart` abaixo; não roda sozinho.

```dart
/// Uma matéria de estudo do app Foco.
///
/// O construtor é `const` de propósito: sem isso, nenhum widget que receba uma
/// `Materia` pode ser `const`, e a otimização desta aula não acontece.
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.minutosEstudados,
  });

  final String id;
  final String nome;
  final int minutosEstudados;
}
```

> **Arquivo:** `foco_desempenho/lib/features/materias/presentation/widgets/materia_tile.dart`

```dart
import 'package:flutter/material.dart';

import '../../domain/materia.dart';

/// Item da lista de matérias.
///
/// É StatefulWidget de propósito: só um widget com estado próprio revela o
/// efeito das keys, porque esse estado vive no Element, não no widget.
class MateriaTile extends StatefulWidget {
  const MateriaTile({required this.materia, super.key});

  final Materia materia;

  @override
  State<MateriaTile> createState() => _MateriaTileState();
}

class _MateriaTileState extends State<MateriaTile> {
  bool _favorita = false;

  @override
  Widget build(BuildContext context) {
    debugPrint('build MateriaTile ${widget.materia.nome}');
    return ListTile(
      leading: CircleAvatar(child: Text(widget.materia.nome.substring(0, 1))),
      title: Text(widget.materia.nome),
      subtitle: Text('${widget.materia.minutosEstudados} min estudados'),
      trailing: IconButton(
        tooltip: _favorita ? 'Remover dos favoritos' : 'Marcar como favorita',
        icon: Icon(_favorita ? Icons.star : Icons.star_border),
        onPressed: () => setState(() => _favorita = !_favorita),
      ),
    );
  }
}
```

> **Arquivo:** `foco_desempenho/lib/main.dart`
> **Como executar:** dentro de `foco_desempenho`, rode `flutter run -d windows`
> (ou `flutter run` se você já tem emulador ou aparelho Android).

```dart
import 'package:flutter/material.dart';

import 'features/materias/domain/materia.dart';
import 'features/materias/presentation/widgets/materia_tile.dart';

void main() => runApp(const AppDesempenho());

class AppDesempenho extends StatelessWidget {
  const AppDesempenho({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco — laboratório de desempenho',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF3F51B5)),
      home: const RebuildsDemoScreen(),
    );
  }
}

class RebuildsDemoScreen extends StatefulWidget {
  const RebuildsDemoScreen({super.key});

  @override
  State<RebuildsDemoScreen> createState() => _RebuildsDemoScreenState();
}

class _RebuildsDemoScreenState extends State<RebuildsDemoScreen> {
  /// Cronômetro da sessão de estudo: o dado que muda o tempo todo.
  final ValueNotifier<int> _segundos = ValueNotifier<int>(0);

  /// Interruptor do experimento: usar `key` nos itens da lista?
  bool _usarKeys = true;

  List<Materia> _materias = const <Materia>[
    Materia(id: 'm1', nome: 'Álgebra', minutosEstudados: 120),
    Materia(id: 'm2', nome: 'Física', minutosEstudados: 75),
    Materia(id: 'm3', nome: 'História', minutosEstudados: 40),
    Materia(id: 'm4', nome: 'Inglês', minutosEstudados: 200),
  ];

  @override
  void dispose() {
    _segundos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build RebuildsDemoScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rebuilds, const e keys'),
        actions: <Widget>[
          IconButton(
            tooltip: _usarKeys ? 'Desligar as keys' : 'Ligar as keys',
            icon: Icon(_usarKeys ? Icons.key : Icons.key_off),
            onPressed: () => setState(() => _usarKeys = !_usarKeys),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // 1) const: construído UMA vez no app inteiro.
          const CabecalhoDaSemana(),

          // 2) Só este trecho reconstrói quando o cronômetro anda.
          ValueListenableBuilder<int>(
            valueListenable: _segundos,
            child: const Icon(Icons.timer_outlined), // fora do rebuild
            builder: (BuildContext context, int valor, Widget? filho) {
              debugPrint('build do cronômetro');
              return ListTile(
                leading: filho,
                title: Text('Sessão atual: $valor s'),
              );
            },
          ),

          // 3) RepaintBoundary isola a PINTURA da barra: sem `value`, o
          //    LinearProgressIndicator anima sozinho e repinta todo frame.
          const RepaintBoundary(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              itemCount: _materias.length,
              itemBuilder: (BuildContext context, int indice) {
                final Materia materia = _materias[indice];
                return MateriaTile(
                  key: _usarKeys ? ValueKey<String>(materia.id) : null,
                  materia: materia,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: 'cronometro',
            onPressed: () => _segundos.value += 1,
            icon: const Icon(Icons.play_arrow),
            label: const Text('+1 s'),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'inverter',
            onPressed: () =>
                setState(() => _materias = _materias.reversed.toList()),
            icon: const Icon(Icons.swap_vert),
            label: const Text('Inverter'),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho estático. Como não depende de nada, é `const` — e some do rebuild.
class CabecalhoDaSemana extends StatelessWidget {
  const CabecalhoDaSemana({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build CabecalhoDaSemana');
    return const ListTile(
      leading: Icon(Icons.calendar_month),
      title: Text('Semana atual · meta de 600 min'),
    );
  }
}
```

---

## 🔍 Explicando o código

**`const <Materia>[...]`.** A lista inteira é constante, e isso só é possível porque `Materia` tem
construtor `const`. Modelo `const` libera widget `const`.

**`const CabecalhoDaSemana()`.** Rode e toque dez vezes em "+1 s": o terminal mostra
`build do cronômetro` dez vezes e `build CabecalhoDaSemana` **nenhuma** vez além da primeira. Agora
apague a palavra `const` dessa linha, salve (hot reload) e repita: o cabeçalho volta a reconstruir
junto. Esse é o experimento central da aula.

**`ValueListenableBuilder` com `child`.** O `Icon` é criado uma vez e chega no `builder` como
`filho`. Se o cronômetro usasse `setState`, o `build` da tela inteira rodaria a cada segundo. Com
Riverpod, `Consumer` faz o mesmo papel.

**`RepaintBoundary` em volta da barra.** Um `LinearProgressIndicator` sem `value` é *indeterminado*:
anima sozinho e repinta a cada frame; sem a fronteira, arrastaria a camada vizinha junto. Para ver a
diferença, abra o DevTools e ligue **Highlight Repaints** no Flutter Inspector — as bordas coloridas
piscam só onde há repintura real.

**`key: _usarKeys ? ValueKey<String>(materia.id) : null`.** Este é o interruptor do bug. Reproduza:

1. Rode o app; o ícone da AppBar está como 🔑 (keys **ligadas**).
2. Marque a estrela de **Álgebra**, o primeiro item.
3. Toque em **Inverter**: a estrela vai junto com Álgebra, agora no fim. ✅ Correto.
4. Toque no ícone da AppBar para **desligar** as keys.
5. Marque a estrela de Álgebra e toque em **Inverter**.
6. A estrela fica no **primeiro item da tela** — agora Inglês. ❌ O estado ficou na posição.

O motivo: sem key, `canUpdate` só compara o tipo. O `MateriaTile` da posição 0 casa com o da posição
0, o `Element` é reaproveitado e o `_MateriaTileState` (que guarda `_favorita`) fica onde estava. Com
`ValueKey(materia.id)` as keys não batem, o Flutter procura o Element daquela key em outra posição e
**move o estado junto com o dado**.

**`heroTag` nos dois FABs.** Dois `FloatingActionButton` na mesma tela colidem na animação Hero;
tags diferentes resolvem. E `debugPrint` em vez de `print`: em código Flutter, `print()` dispara o
lint `avoid_print` e ainda arrisca estourar o buffer de log do Android.

---

## ⚠️ Erros comuns

**1. Achar que um `const` lá fora resolve tudo.** `const` corta a subárvore **a partir daquele
ponto**. Se o widget mais externo não pode ser `const` porque recebe um dado variável, nada abaixo é
cortado. Extraia o pedaço realmente estático para um widget próprio.

**2. Criar key errada dentro do `build`.**

```dart
// ❌ UniqueKey destrói e recria o widget a cada frame: animação reinicia,
//    rolagem volta ao topo, campo de texto perde o conteúdo.
return MateriaTile(key: UniqueKey(), materia: materia);

// ❌ O índice muda quando a lista é reordenada: a key para de identificar o item.
key: ValueKey<int>(indice)
```

`UniqueKey` serve para **forçar** recriação — é exceção, não rotina. E a key vem do **dado**
(`materia.id`), nunca da posição.

**3. Achar que key resolve desempenho.** Key resolve **identidade** (estado no lugar certo). Quem
resolve desempenho é `const`, extração de widget e escopo de rebuild.

**4. Criar `GlobalKey` dentro do `build`.** Crie como campo `final` do `State`:
`final GlobalKey<FormState> _formKey = GlobalKey<FormState>();`.

**5. Embrulhar tudo em `RepaintBoundary`.** Cada fronteira é uma camada a mais na memória de vídeo;
usada demais, ela **piora** o desempenho.

**6. Confundir "não reconstruiu" com "não repintou"** — são problemas diferentes, com ferramentas
diferentes — ou **esquecer `debugPrintRebuildDirtyWidgets = true`** ligado: ele deixa o app lento e
polui o log.

---

## 🛠️ Exercício guiado

**Objetivo:** medir a queda de rebuilds com número, no seu próprio app.

**Passo 1 — ligue o contador do Flutter.** No `main()`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  debugPrintRebuildDirtyWidgets = true; // imprime cada widget reconstruído
  runApp(const AppDesempenho());
}
```

Rode com `flutter run -d windows`, toque cinco vezes em "+1 s" e **conte as linhas** do terminal.

**Passo 2 — piore de propósito.** Troque o `ValueListenableBuilder` por `setState`: adicione
`int _segundosSetState = 0;`, use `Text('Sessão atual: $_segundosSetState s')` e faça o FAB chamar
`setState(() => _segundosSetState++)`. Conte de novo — o número sobe, porque a tela toda entrou na
conta.

**Passo 3 — volte ao `ValueListenableBuilder` e remova os `const`** de `CabecalhoDaSemana()` e do
`Icon`. Conte de novo. Depois restaure tudo e preencha:

| Versão | Linhas de rebuild em 5 toques |
|---|---|
| `setState` na tela toda | |
| `ValueListenableBuilder` sem `const` | |
| `ValueListenableBuilder` com `const` | |

**Passo 4 — apague a linha do flag** e repita a medição no DevTools: abra a URL que o terminal
imprime, vá em **Performance** e ligue **Track widget builds**. A tabela mostra, classe por classe,
quantas vezes cada widget reconstruiu. Confira se bate com a sua contagem.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md)

Deste assunto, faça pelo menos o de fixação sobre os quatro disparadores de `build`, o de leitura de
código com `const` e o de correção de bug da lista reordenada.

---

## 🏆 Desafio opcional

Transforme o cronômetro em um `Notifier` do Riverpod 3 e prove que o comportamento é o mesmo. Rode
`flutter pub add flutter_riverpod`, embrulhe o app em `ProviderScope` e crie:

```dart
class CronometroNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void somarSegundo() => state = state + 1;
}

final cronometroProvider =
    NotifierProvider<CronometroNotifier, int>(CronometroNotifier.new);
```

Use `Consumer` **apenas** em volta do texto do cronômetro — não transforme a tela em
`ConsumerWidget`. Com `debugPrintRebuildDirtyWidgets = true`, mostre que o cabeçalho continua fora do
rebuild, e escreva no topo do arquivo por que `Consumer` faz aqui o mesmo papel do
`ValueListenableBuilder`.

---

## 📌 Resumo

- Quatro gatilhos de `build`: `setState`, pai reconstruiu, dependência (`of(context)` / `ref.watch`)
  mudou, listenable notificou.
- O orçamento de um frame é **16,67 ms** a 60 fps (8,3 ms a 120 Hz). Por isso `build` só monta
  widgets — nunca faz trabalho.
- `const` funciona porque o Dart canoniza a instância e o Flutter corta a subárvore na comparação de
  identidade. Modelo com construtor `const` é o que **libera** widget `const`.
- **Extrair widget** cria `Element` próprio e isola o rebuild; **extrair método** não isola nada.
- `Consumer` e `ValueListenableBuilder` reduzem o escopo ao menor widget que depende do dado; o
  parâmetro `child` tira do rebuild a parte estável.
- `RepaintBoundary` resolve **repintura**, não reconstrução. Custa memória; use com medida.
- `canUpdate` = mesmo tipo **e** mesma key. Sem key o estado gruda na **posição**; com
  `ValueKey(id)` ele segue o **dado**. `ObjectKey` para identidade de objeto, `UniqueKey` para
  forçar recriação, `GlobalKey` para alcançar o `State` — nunca criadas dentro de `build`.
- Meça com `debugPrintRebuildDirtyWidgets` e com **Track widget builds** no DevTools.

---

## ☑️ Checklist de domínio

- [ ] Listo os quatro gatilhos de `build()` sem consultar.
- [ ] Explico por que `const` corta rebuild, citando a comparação de identidade.
- [ ] Digo por que um método que devolve `Widget` não isola rebuild.
- [ ] Coloquei `const` em todos os widgets possíveis e `flutter analyze` não reclama.
- [ ] Uso `Consumer` ou `ValueListenableBuilder` em volta só do que depende do dado que muda.
- [ ] Explico a diferença entre rebuild e repaint e qual ferramenta enxerga cada um.
- [ ] Reproduzi o bug da estrela na lista invertida **sem key** e corrigi com `ValueKey`.
- [ ] Sei por que `ValueKey(indice)` é uma armadilha.
- [ ] Nunca crio `UniqueKey()` nem `GlobalKey()` dentro de `build`.
- [ ] Contei rebuilds no terminal e confirmei o mesmo número no DevTools.

---

## 📚 Referências oficiais

- [Flutter — Performance best practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter — Inside Flutter (widget, element, render object)](https://docs.flutter.dev/resources/inside-flutter)
- [Flutter API — `Widget.canUpdate`](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html)
- [Flutter API — `Key`](https://api.flutter.dev/flutter/foundation/Key-class.html)
- [Flutter API — `ValueListenableBuilder`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html)
- [Flutter API — `RepaintBoundary`](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html)
- [Flutter — Using the Flutter inspector](https://docs.flutter.dev/tools/devtools/inspector)
- [Riverpod — Reading a provider](https://riverpod.dev/docs/concepts/reading)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Listas grandes e imagens](02-listas-grandes-e-imagens.md) |
