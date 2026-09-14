# Aula 6 — Ciclo de vida do State

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Listar, na ordem correta, os sete métodos do ciclo de vida de um `State` e dizer o que fazer em
  cada um.
- Saber exatamente onde inicializar um `Timer`, um `TextEditingController` e um listener — e onde
  desfazê-los.
- Explicar por que `initState` não pode acessar `Theme.of(context)` e por que
  `didChangeDependencies` existe.
- Usar `didUpdateWidget` para reagir a uma mudança de parâmetro vinda do widget pai.
- Entender a diferença entre `deactivate` e `dispose`.
- Reconhecer e corrigir vazamento de memória causado por `dispose` esquecido.
- Construir o cronômetro de sessão do `meu_primeiro_app`, com `Timer` e campo de texto.

## ✅ Pré-requisitos

- [Aula 5 — StatefulWidget e setState](05-statefulwidget-e-setstate.md), com o contador funcionando.
- [Módulo 04 — Aula 02: Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md).
- [Módulo 04 — Aula 03: Streams](../04-dart-avancado/03-streams.md) — a ideia de "assinatura que
  precisa ser cancelada" é a mesma.
- [Módulo 03 — Aula 04: Herança e polimorfismo](../03-dart-intermediario/04-heranca-e-polimorfismo.md)
  — você vai chamar `super.initState()` e `super.dispose()`.

---

## 📖 Conceito

### O ciclo completo, em ordem

Um objeto `State` nasce, vive e morre. O Flutter chama métodos específicos em cada etapa, e cada um
tem um trabalho próprio.

```text
 1. createState()             ← no WIDGET, não no State. Cria o objeto de estado.
          ↓
 2. initState()               ← uma vez. Inicialize controllers, timers, listeners.
          ↓
 3. didChangeDependencies()   ← logo após initState, e sempre que um InheritedWidget muda.
          ↓
 4. build()                   ← muitas vezes. Só monte widgets.
          ↓
 ┌────────┴────────────────────────────────────┐
 │                                             │
 │  5. didUpdateWidget(velho)  ← quando o pai   │
 │        ↓                       passa         │
 │     build()                    parâmetros    │  ciclo de atualização
 │                                novos          │  (repete muitas vezes)
 │                                             │
 │     setState() → build()                    │
 └────────┬────────────────────────────────────┘
          ↓
 6. deactivate()              ← o State saiu da árvore (pode voltar).
          ↓
 7. dispose()                 ← definitivo. Cancele tudo. Nunca mais volta.
```

Vamos a cada um.

### 1. `createState()`

```dart
@override
State<Cronometro> createState() => _CronometroState();
```

Fica no **widget**, não no `State`. É chamado **uma vez**, quando o Element é criado.

**O que fazer aqui:** só devolver a instância. Nada mais. Não passe parâmetros pelo construtor do
`State` — o `State` lê tudo por `widget.<campo>`.

### 2. `initState()`

Chamado **uma vez**, logo depois de o `State` ser criado e antes do primeiro `build`.

```dart
@override
void initState() {
  super.initState();   // SEMPRE primeiro
  _controladorNota = TextEditingController(text: widget.notaInicial);
  _cronometro = Timer.periodic(const Duration(seconds: 1), _aoPassarSegundo);
  _controladorNota.addListener(_aoDigitar);
}
```

**O que fazer aqui:**

- criar `TextEditingController`, `ScrollController`, `AnimationController`, `FocusNode`;
- iniciar `Timer`;
- assinar `Stream` (`stream.listen(...)`);
- registrar listeners (`addListener`);
- disparar a primeira busca de dados;
- ler `widget.<campo>` para calcular o estado inicial.

**O que NÃO fazer aqui:**

- ❌ `Theme.of(context)`, `MediaQuery.of(context)`, `Navigator.of(context)` — o `context` já existe,
  mas o `State` ainda não está totalmente conectado aos `InheritedWidget` acima. O erro é:
  ```text
  dependOnInheritedWidgetOfExactType<_InheritedTheme>() or dependOnInheritedElement() was called
  before _CronometroState.initState() completed.
  ```
- ❌ `setState()` — ainda não houve `build`; basta atribuir direto ao campo.
- ❌ `await` sem cuidado: `initState` **não pode ser `async`**. Se precisar de assincronia, chame
  um método `Future<void>` sem `await`, com `unawaited(...)` ou apenas `_carregar();`.

> 📌 `super.initState()` vem **primeiro**. `super.dispose()` vem **por último**. Essa assimetria
> confunde, então decore assim: **abra a porta antes de entrar, feche a porta depois de sair.**

### 3. `didChangeDependencies()`

Chamado logo depois do `initState` **e** toda vez que um `InheritedWidget` do qual este `State`
depende muda — ou seja, quando muda o `Theme`, o `MediaQuery`, o `Localizations`, um provider herdado.

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Agora SIM o context está pronto para Theme.of / MediaQuery.of.
  _alturaDisponivel = MediaQuery.of(context).size.height;
}
```

**O que fazer aqui:** tudo o que você queria fazer no `initState` mas que precisa de `context`.

**Cuidado:** este método pode ser chamado **muitas vezes**. Girar o celular dispara ele. Então nunca
crie um `Timer` aqui sem antes cancelar o anterior — você acabaria com dez timers rodando juntos.

### 4. `build()`

Já conhecido da [aula 4](04-statelesswidget.md): monte widgets, nada mais. Pode rodar 60 vezes por
segundo.

### 5. `didUpdateWidget(velhoWidget)`

Chamado quando o **pai reconstrói** e coloca, na mesma posição da árvore, um widget do mesmo tipo
mas com **parâmetros diferentes**. O `State` é o mesmo; o `widget` é novo.

```dart
@override
void didUpdateWidget(covariant Cronometro widgetAntigo) {
  super.didUpdateWidget(widgetAntigo);

  // O pai mudou a duração da sessão? Então reinicie o cronômetro.
  if (widget.duracaoMinutos != widgetAntigo.duracaoMinutos) {
    _cronometro?.cancel();
    _segundosRestantes = widget.duracaoMinutos * 60;
    _iniciarContagem();
  }
}
```

**O que fazer aqui:** comparar `widget.<campo>` com `widgetAntigo.<campo>` e reagir só ao que mudou.

**A armadilha:** se você não comparar e simplesmente refizer tudo, o trabalho acontece a cada
reconstrução do pai — que pode ser 60 vezes por segundo.

`covariant` na assinatura significa "aceito um tipo mais específico que o declarado na superclasse".
Copie como está; o analisador exige.

### 6. `deactivate()`

Chamado quando o `State` é **removido da árvore**. Ele pode voltar: se, no mesmo quadro, o mesmo
Element for reinserido em outro lugar (com `GlobalKey`), o `State` continua vivo.

Na prática, você raramente sobrescreve `deactivate`. Use-o apenas para desregistrar algo que dependa
da posição na árvore — por exemplo, remover-se de um `InheritedWidget` que mantém uma lista.

### 7. `dispose()`

Chamado quando o `State` é destruído **definitivamente**. Não volta mais.

```dart
@override
void dispose() {
  _cronometro?.cancel();                          // 1. cancele timers
  _controladorNota.removeListener(_aoDigitar);    // 2. remova listeners
  _controladorNota.dispose();                     // 3. libere controllers
  _assinatura?.cancel();                          // 4. cancele streams
  super.dispose();                                // 5. SEMPRE por último
}
```

**Tudo o que foi criado no `initState` precisa ser desfeito aqui.** Sem exceção.

### Por que `dispose` não é opcional

Um `TextEditingController` esquecido, um `Timer` não cancelado ou um `StreamSubscription` não
cancelado continuam existindo depois que a tela fecha. Isso se chama **vazamento de memória**
(*memory leak*): objetos que ninguém usa mais, mas que o coletor de lixo não pode remover porque
alguém ainda aponta para eles.

Os sintomas reais:

| Objeto esquecido | O que acontece |
|---|---|
| `Timer.periodic` | Continua disparando depois que a tela fechou. Se ele chama `setState`, você recebe `setState() called after dispose()`. Se ele chama a rede, você gasta bateria e dados do usuário para nada. |
| `TextEditingController` | Fica na memória com o texto digitado. Abrir e fechar a tela 100 vezes deixa 100 controllers vivos. |
| `AnimationController` | Continua consumindo quadros. Em modo debug o Flutter chega a avisar: `AnimationController.dispose() called more than once` ou `was not disposed`. |
| `StreamSubscription` | Continua recebendo eventos. Cada abertura de tela duplica o número de ouvintes; em uma lista, o mesmo item aparece duas, três, quatro vezes. |
| `FocusNode` | Erros estranhos de foco em telas seguintes. |

O Flutter tem uma checagem em modo debug que às vezes denuncia isso:

```text
A <ClasseDoController> was used after being disposed.
Once you have called dispose() on a <ClasseDoController>, it can no longer be used.
```

> 📌 **Padrão que evita o problema para sempre:** ao escrever a linha que **cria** um controller no
> `initState`, escreva **imediatamente** a linha que o destrói no `dispose`. Não deixe para depois.

### O erro `setState() called after dispose()`, por inteiro

Você já viu o erro na [aula 5](05-statefulwidget-e-setstate.md). Agora dá para entender a causa
completa.

```text
════════ Exception caught by widgets library ═══════════════════════════════════
The following assertion was thrown while finalizing the widget tree:
setState() called after dispose(): _CronometroState#3f1a2(lifecycle state: defunct, not mounted)

This error happens if you call setState() on a State object for a widget that no longer appears
in the widget tree (e.g., whose parent widget no longer includes the widget in its build).
This error can occur when code calls setState() from a timer or an animation callback.

The preferred solution is to cancel the timer or stop listening to the animation in the dispose()
callback. Another solution is to check the "mounted" property of this object before calling
setState() to ensure the object is still in the tree.
```

A própria mensagem dá as **duas** soluções, e elas não são alternativas — são complementares:

1. **Cancele no `dispose`** (`_cronometro?.cancel()`). Essa é a correção estrutural: o callback nem
   chega a rodar.
2. **Cheque `mounted`** depois de cada `await`. Essa é a rede de segurança para o que você não
   consegue cancelar (uma requisição HTTP já em voo, por exemplo).

O campo `lifecycle state: defunct` no erro significa literalmente "extinto": o `State` já passou
pelo `dispose`.

---

## 💡 Analogia

Pense em alugar uma **sala de estudo por hora**.

| Etapa | Na sala | No `State` |
|---|---|---|
| Pegar a chave na recepção | você recebe a sala | `createState()` |
| Entrar, ligar o ar, ligar o cronômetro da parede, plugar o notebook | preparação, uma vez só | `initState()` |
| Perguntar à recepção a senha do wi-fi (que só existe depois de você entrar) | depende do ambiente | `didChangeDependencies()` |
| Estudar | acontece o tempo todo | `build()` |
| A recepção avisa que a sua reserva foi estendida de 1 h para 2 h | parâmetro externo mudou | `didUpdateWidget()` |
| Você sai para o banheiro levando a chave | saiu, mas pode voltar | `deactivate()` |
| Devolver a chave, desligar o ar, parar o cronômetro, desplugar o notebook | definitivo | `dispose()` |

Esquecer o `dispose` é sair da sala com o ar-condicionado ligado, o cronômetro apitando e o notebook
plugado. Ninguém está lá, mas a energia continua sendo gasta — e, pior, o cronômetro continua
apitando em uma sala que já foi alugada para outra pessoa. É exatamente isso que o
`setState() called after dispose()` está dizendo.

---

## 🧪 Exemplo mínimo

Um `State` que imprime cada etapa do próprio ciclo de vida:

```dart
import 'package:flutter/material.dart';

class Espiao extends StatefulWidget {
  const Espiao({super.key, required this.rotulo});

  final String rotulo;

  @override
  State<Espiao> createState() => _EspiaoState();
}

class _EspiaoState extends State<Espiao> {
  @override
  void initState() {
    super.initState();
    debugPrint('1. initState — ${widget.rotulo}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('2. didChangeDependencies — ${widget.rotulo}');
  }

  @override
  void didUpdateWidget(covariant Espiao widgetAntigo) {
    super.didUpdateWidget(widgetAntigo);
    debugPrint('4. didUpdateWidget — de "${widgetAntigo.rotulo}" '
        'para "${widget.rotulo}"');
  }

  @override
  void deactivate() {
    debugPrint('5. deactivate — ${widget.rotulo}');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('6. dispose — ${widget.rotulo}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('3. build — ${widget.rotulo}');
    return Text(widget.rotulo);
  }
}
```

Coloque esse widget em qualquer tela, mude o `rotulo` e observe o terminal. É a forma mais rápida de
fixar a ordem.

---

## 📱 Aplicando no Flutter

Agora o `meu_primeiro_app` ganha o cronômetro de verdade — o recurso que dá sentido ao contador de
sessões da aula anterior.

O `CronometroSessao` vai ter:

1. Um **`Timer.periodic`** que decrementa um segundo por vez.
2. Um **`TextEditingController`** para a anotação sobre o que foi estudado na sessão.
3. Um **listener** no controller, para habilitar o botão "Concluir" só quando houver texto.
4. `initState` criando os três, e `dispose` desfazendo os três.
5. `didUpdateWidget` reagindo quando o pai mudar a duração da sessão.
6. Checagem de `mounted` no ponto onde ela é realmente necessária.

Você também vai adicionar um seletor de duração na `HomeTela`, para poder disparar o
`didUpdateWidget` e ver o método funcionando.

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/lib/widgets/cronometro_sessao.dart`
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:async';

import 'package:flutter/material.dart';

/// Cronômetro regressivo de uma sessão de estudo.
///
/// Demonstra o ciclo de vida completo de um State: cria Timer e
/// TextEditingController no initState, reage a mudança de parâmetro no
/// didUpdateWidget e desfaz tudo no dispose.
class CronometroSessao extends StatefulWidget {
  const CronometroSessao({
    super.key,
    required this.duracaoMinutos,
    required this.onConcluir,
  });

  /// Duração da sessão. Vem do pai; quando muda, o didUpdateWidget reage.
  final int duracaoMinutos;

  /// Chamado quando a sessão termina. Recebe a anotação digitada.
  final void Function(String anotacao) onConcluir;

  @override
  State<CronometroSessao> createState() => _CronometroSessaoState();
}

class _CronometroSessaoState extends State<CronometroSessao> {
  // ── Recursos que PRECISAM ser liberados no dispose ────────────────────────
  Timer? _cronometro;
  late final TextEditingController _controladorAnotacao;

  // ── Estado puro ───────────────────────────────────────────────────────────
  late int _segundosRestantes;
  bool _rodando = false;
  bool _temAnotacao = false;

  @override
  void initState() {
    super.initState(); // sempre primeiro

    // Estado inicial derivado do parâmetro do widget.
    _segundosRestantes = widget.duracaoMinutos * 60;

    // Controller criado aqui, destruído no dispose. Escreva as duas linhas
    // juntas, mentalmente, para nunca esquecer.
    _controladorAnotacao = TextEditingController();
    _controladorAnotacao.addListener(_aoDigitarAnotacao);

    debugPrint('initState: sessão de ${widget.duracaoMinutos} min preparada.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Aqui o context JÁ está pronto para Theme.of / MediaQuery.of.
    // Este debugPrint mostra que o método roda também ao redimensionar a tela.
    final Size tamanho = MediaQuery.sizeOf(context);
    debugPrint('didChangeDependencies: largura ${tamanho.width.toInt()} px.');
  }

  @override
  void didUpdateWidget(covariant CronometroSessao widgetAntigo) {
    super.didUpdateWidget(widgetAntigo);

    // Compare SEMPRE antes de agir. Sem este if, qualquer rebuild do pai
    // reiniciaria o cronômetro.
    if (widget.duracaoMinutos != widgetAntigo.duracaoMinutos) {
      debugPrint('didUpdateWidget: ${widgetAntigo.duracaoMinutos} min '
          '→ ${widget.duracaoMinutos} min. Reiniciando.');
      _pararCronometro();
      setState(() {
        _segundosRestantes = widget.duracaoMinutos * 60;
      });
    }
  }

  @override
  void dispose() {
    // Ordem: desfaça na ordem inversa da criação, e super por último.
    _cronometro?.cancel();
    _controladorAnotacao.removeListener(_aoDigitarAnotacao);
    _controladorAnotacao.dispose();
    debugPrint('dispose: timer cancelado e controller liberado.');
    super.dispose(); // sempre por último
  }

  // ── Lógica ────────────────────────────────────────────────────────────────

  void _aoDigitarAnotacao() {
    final bool agora = _controladorAnotacao.text.trim().isNotEmpty;
    if (agora != _temAnotacao) {
      setState(() {
        _temAnotacao = agora;
      });
    }
  }

  void _alternarCronometro() {
    if (_rodando) {
      _pararCronometro();
      setState(() {
        _rodando = false;
      });
      return;
    }

    setState(() {
      _rodando = true;
    });

    _cronometro = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_segundosRestantes <= 1) {
        timer.cancel();
        setState(() {
          _segundosRestantes = 0;
          _rodando = false;
        });
        return;
      }
      setState(() {
        _segundosRestantes--;
      });
    });
  }

  void _pararCronometro() {
    _cronometro?.cancel();
    _cronometro = null;
  }

  void _reiniciar() {
    _pararCronometro();
    setState(() {
      _segundosRestantes = widget.duracaoMinutos * 60;
      _rodando = false;
    });
  }

  Future<void> _concluir() async {
    _pararCronometro();
    final String anotacao = _controladorAnotacao.text.trim();

    // Simula uma gravação demorada (banco ou rede).
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // ✅ Depois de todo await: o State ainda está na árvore?
    if (!mounted) return;

    widget.onConcluir(anotacao);
    _controladorAnotacao.clear();
    setState(() {
      _segundosRestantes = widget.duracaoMinutos * 60;
      _rodando = false;
    });
  }

  String get _tempoFormatado {
    final int minutos = _segundosRestantes ~/ 60;
    final int segundos = _segundosRestantes % 60;
    final String mm = minutos.toString().padLeft(2, '0');
    final String ss = segundos.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  double get _progresso {
    final int total = widget.duracaoMinutos * 60;
    if (total == 0) return 0;
    return 1 - (_segundosRestantes / total);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;
    final bool terminou = _segundosRestantes == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Cronômetro da sessão', style: tema.textTheme.titleMedium),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: _progresso,
                        strokeWidth: 10,
                        backgroundColor: cores.surfaceContainerHighest,
                      ),
                    ),
                    Text(
                      _tempoFormatado,
                      style: tema.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controladorAnotacao,
              decoration: const InputDecoration(
                labelText: 'O que você estudou nesta sessão?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLength: 80,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: terminou ? null : _alternarCronometro,
                    icon: Icon(_rodando ? Icons.pause : Icons.play_arrow),
                    label: Text(_rodando ? 'Pausar' : 'Iniciar'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: _reiniciar,
                  icon: const Icon(Icons.restart_alt),
                  tooltip: 'Reiniciar',
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              // Só habilita quando há anotação: o listener controla isso.
              onPressed: _temAnotacao ? _concluir : null,
              icon: const Icon(Icons.check),
              label: Text(
                _temAnotacao
                    ? 'Concluir sessão'
                    : 'Escreva uma anotação para concluir',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Agora ligue o cronômetro à tela. Substitua o `_HomeTelaState` pela versão abaixo — ela ganha um
seletor de duração, que é o que dispara o `didUpdateWidget`.

> **Arquivo:** `meu_primeiro_app/lib/telas/home_tela.dart` (trechos novos, o restante continua igual)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/widgets/cartao_materia.dart';
import 'package:meu_primeiro_app/widgets/contador_sessoes.dart';
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

  /// Duração escolhida. Ao mudar, o CronometroSessao recebe um parâmetro novo
  /// e o didUpdateWidget dele é chamado.
  int _duracaoMinutos = 25;

  void _aoConcluirSessao(String anotacao) {
    setState(() {
      _sessoesConcluidas++;
      final int atual = _minutosPorMateria[_materiaSelecionada] ?? 0;
      _minutosPorMateria[_materiaSelecionada] = atual + _duracaoMinutos;
    });

    final String detalhe = anotacao.isEmpty ? '' : ' — $anotacao';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '+$_duracaoMinutos min em $_materiaSelecionada$detalhe',
        ),
      ),
    );
  }

  void _selecionar(String materia) {
    setState(() {
      _materiaSelecionada = materia;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final List<String> materias = _minutosPorMateria.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Primeiro App'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('$_sessoesConcluidas sessões')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Seletor de duração: mudar aqui dispara o didUpdateWidget do
          // cronômetro, que reinicia a contagem.
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

          Center(
            child: Text(
              'Recebendo minutos: $_materiaSelecionada',
              style: tema.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
```

> 📌 O `ContadorSessoes` da aula 5 continua no projeto e é usado nos exercícios, mas a `HomeTela`
> agora conta as sessões pelo cronômetro. Não apague o arquivo: ele volta no
> [Projeto 1](../../projetos/01-projeto-iniciante/README.md).

Rode:

```powershell
flutter analyze
flutter run -d chrome
```

Observe o terminal enquanto usa o app: os `debugPrint` mostram o ciclo de vida acontecendo de
verdade.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `import 'dart:async';` | Necessário para `Timer`. É biblioteca do Dart, não do Flutter. |
| `Timer? _cronometro;` | Nulo enquanto o cronômetro não estiver rodando. O `?` deixa isso explícito. |
| `late final TextEditingController _controladorAnotacao;` | `late` porque o valor só é atribuído no `initState`; `final` porque nunca será trocado depois. |
| `late int _segundosRestantes;` | `late` sem `final`: o valor inicial vem do `initState` (depende de `widget.duracaoMinutos`), mas muda a cada segundo. |
| `super.initState();` na primeira linha | Obrigatório. O framework registra coisas internas ali. |
| `_segundosRestantes = widget.duracaoMinutos * 60;` | Este é o motivo de o `initState` existir: derivar estado inicial de um parâmetro. Você **não** consegue fazer isso em um inicializador de campo, porque `widget` ainda não está disponível. |
| `_controladorAnotacao.addListener(_aoDigitarAnotacao)` | O controller notifica a cada tecla. |
| `MediaQuery.sizeOf(context)` em `didChangeDependencies` | Forma moderna e mais eficiente que `MediaQuery.of(context).size`: só reconstrói quando o **tamanho** muda, não quando qualquer coisa do `MediaQuery` muda. |
| `covariant CronometroSessao widgetAntigo` | Assinatura exigida pelo framework para `didUpdateWidget`. |
| `if (widget.duracaoMinutos != widgetAntigo.duracaoMinutos)` | Sem essa comparação, o cronômetro reiniciaria a cada rebuild do pai. |
| `_cronometro?.cancel();` no `dispose` | Cancela o `Timer`. Sem isso, ele continua disparando `setState` em um `State` morto. |
| `removeListener` **antes** de `dispose()` | Boa prática: desconecta o ouvinte antes de destruir o objeto. |
| `super.dispose();` na última linha | Obrigatório e por último. |
| `if (agora != _temAnotacao)` dentro de `_aoDigitarAnotacao` | Evita um `setState` por tecla digitada. Só reconstrói quando o **estado booleano** realmente muda. |
| `Timer.periodic(const Duration(seconds: 1), (Timer timer) { ... })` | Dispara a cada segundo. Repare que ele recebe o próprio timer, o que permite `timer.cancel()` de dentro do callback. |
| `await Future<void>.delayed(...)` + `if (!mounted) return;` | Simula gravação demorada e protege o `setState` seguinte. |
| `FontFeature.tabularFigures()` | Faz todos os dígitos terem a mesma largura. Sem isso, o cronômetro "pula" quando 1 vira 8. |
| `CircularProgressIndicator(value: _progresso)` | Com `value` entre 0 e 1 ele é **determinado** (mostra progresso real). Sem `value`, ele gira para sempre. |
| `onPressed: terminou ? null : _alternarCronometro` | `null` desabilita o botão. |
| `SegmentedButton<int>` | Seletor do Material 3 com `selected: <int>{...}` — um `Set`, porque o widget também suporta seleção múltipla. |
| `_progresso` como getter | `1 - restante/total`. Derivado, nunca armazenado. |

---

## 🤖🍎 Android × iOS

O ciclo de vida do `State` é **igual** nas duas plataformas — quem o executa é o mesmo framework
Dart. A diferença real aparece em **quando o sistema operacional decide matar o seu app**, o que faz
o `dispose` nunca ser chamado:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| App em segundo plano | pode ser encerrado a qualquer momento sob pressão de memória | encerrado mais agressivamente; apps em background têm tempo de execução muito limitado |
| `Timer` rodando em background | continua por pouco tempo, depois é congelado | é congelado quase imediatamente |
| Método do ciclo de vida do **app** (não do State) | `AppLifecycleState.paused` / `detached` | mesmos estados, disparados em momentos diferentes |
| `dispose` garantido? | ❌ Não. Se o sistema mata o processo, nada é chamado | ❌ Também não |

Consequência prática: **nunca confie no `dispose` para salvar dados do usuário.** Salve assim que o
dado muda, ou ao receber `AppLifecycleState.paused`. Isso é o assunto de
[11 — Ciclo de vida do app](../11-recursos-nativos/06-ciclo-de-vida-do-app.md).

Especificamente sobre o cronômetro: em ambas as plataformas, um `Timer` do Dart **não** continua
contando de forma confiável com o app em segundo plano. A solução correta é guardar o
`DateTime` de início e recalcular a diferença ao voltar, em vez de decrementar um contador.

> 🍎 **SÓ NO MAC.** Testar o congelamento real em segundo plano no iPhone exige macOS + Xcode.
> 🪟 No Windows, você consegue testar o equivalente em Android (com emulador) e simular no Chrome
> minimizando a aba — mas o comportamento do navegador não é igual ao do celular. As diferenças
> documentadas estão em
> [referencias/diferencas-android-ios.md](../../referencias/diferencas-android-ios.md).

---

## ⚠️ Erros comuns

**1. `Theme.of(context)` dentro do `initState`.**
```text
dependOnInheritedWidgetOfExactType<_InheritedTheme>() or dependOnInheritedElement() was called
before _CronometroSessaoState.initState() completed.
```
Mova para `didChangeDependencies` ou para o `build`.

**2. Esquecer `super.initState()` ou `super.dispose()`.**
```text
info • Every method override that is annotated with @mustCallSuper must invoke the
       overridden method • must_call_super
```

**3. `super.initState()` por último ou `super.dispose()` primeiro.**
O analisador não reclama, mas o framework pode se comportar de forma estranha. A ordem é:
`super` primeiro no `initState`, `super` por último no `dispose`.

**4. `Timer` não cancelado.**
```text
setState() called after dispose(): _CronometroSessaoState#3f1a2
(lifecycle state: defunct, not mounted)
```
Falta `_cronometro?.cancel();` no `dispose`.

**5. Criar `Timer` no `didChangeDependencies` sem cancelar o anterior.**
Girar o aparelho ou redimensionar a janela cria um timer novo a cada vez. Em um minuto você tem
dez cronômetros disparando juntos e o número na tela cai de dez em dez.

**6. `didUpdateWidget` sem comparação.**
Reiniciar o cronômetro toda vez que o pai reconstrói faz o tempo nunca avançar. Compare sempre.

**7. `initState` marcado como `async`.**
```text
error • The return type 'Future<void>' isn't assignable to 'void' • invalid_override
```
`initState` é `void` por definição. Chame um método assíncrono de dentro dele, sem `await`:
```dart
@override
void initState() {
  super.initState();
  _carregarDados(); // método Future<void>, sem await
}
```

**8. `TextEditingController` criado no `build`.**
```dart
@override
Widget build(BuildContext context) {
  final controlador = TextEditingController();  // ❌ novo a cada quadro
```
O texto some a cada reconstrução e cada controller antigo vaza. Crie no `initState`.

**9. Usar um controller depois do `dispose`.**
```text
A TextEditingController was used after being disposed.
```
Normalmente é um callback assíncrono que chegou atrasado. A correção é a mesma: cancelar no
`dispose` e checar `mounted`.

---

## 🛠️ Exercício guiado

**Objetivo:** observar o ciclo de vida inteiro no terminal e depois criar um vazamento de propósito.

**Passo 1.** Adicione um `debugPrint` em cada método do `_CronometroSessaoState` — `initState`,
`didChangeDependencies`, `didUpdateWidget`, `build`, `deactivate`, `dispose`. Alguns já existem;
acrescente os que faltam:

```dart
@override
void deactivate() {
  debugPrint('deactivate: saí da árvore (posso voltar).');
  super.deactivate();
}
```

e, na primeira linha do `build`:

```dart
debugPrint('build: $_tempoFormatado');
```

**Passo 2.** Rode `flutter run -d chrome`. Confirme no terminal a ordem:
`initState` → `didChangeDependencies` → `build`.

**Passo 3.** Toque em "Iniciar". Observe um `build` por segundo.

**Passo 4.** Mude a duração de 25 para 50 minutos no `SegmentedButton`. Confirme que aparece
`didUpdateWidget: 25 min → 50 min. Reiniciando.` seguido de um `build`.

**Passo 5.** Redimensione a janela do Chrome. Confirme que `didChangeDependencies` dispara de novo,
mas `initState` **não**.

**Passo 6.** Agora crie o vazamento. Comente a linha do `dispose`:

```dart
@override
void dispose() {
  // _cronometro?.cancel();   // ⚠️ bug proposital
  _controladorAnotacao.removeListener(_aoDigitarAnotacao);
  _controladorAnotacao.dispose();
  super.dispose();
}
```

**Passo 7.** Envolva o cronômetro em um interruptor na `HomeTela`, como você fez na aula 5:

```dart
bool _mostrarCronometro = true;
// ...
SwitchListTile(
  title: const Text('Mostrar cronômetro'),
  value: _mostrarCronometro,
  onChanged: (bool v) => setState(() => _mostrarCronometro = v),
),
if (_mostrarCronometro)
  CronometroSessao(
    duracaoMinutos: _duracaoMinutos,
    onConcluir: _aoConcluirSessao,
  ),
```

**Passo 8.** Inicie o cronômetro e desligue o interruptor. No terminal:

```text
════════ Exception caught by widgets library ═══════════════════════════════════
setState() called after dispose(): _CronometroSessaoState#... (lifecycle state: defunct,
not mounted)
```

Repare que o erro se repete **a cada segundo** — porque o timer continua vivo.

**Passo 9.** Descomente a linha do `cancel()`. O erro desaparece.

**Passo 10.** Registre em `anotacoes.md`: por que checar `mounted` dentro do callback do timer
**esconderia** o erro sem resolver o vazamento?

**Resposta esperada:** porque o `Timer` continuaria rodando para sempre, consumindo processamento e
bateria; o `mounted` apenas impediria a mensagem de erro. A correção certa é cancelar o recurso.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Faça os de **Correção de bugs** — este é o tema do módulo com mais bugs clássicos — e o de
**Leitura de código** que pede a ordem dos métodos.

---

## 🏆 Desafio opcional

Corrija o cronômetro para funcionar mesmo quando o app fica em segundo plano.

1. Em vez de decrementar `_segundosRestantes` a cada tique, guarde `DateTime? _inicio` e calcule
   `_segundosRestantes` a partir de `DateTime.now().difference(_inicio!)`.
2. Mantenha o `Timer.periodic` apenas para redesenhar a tela uma vez por segundo.
3. Teste: inicie o cronômetro, mude de aba no Chrome por 30 segundos e volte. Na versão original o
   tempo "congela"; na sua versão nova ele deve estar correto.
4. Escreva um comentário explicando por que a segunda versão é a correta.

Esse é exatamente o padrão que o app final usa em
[projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md](../../projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md).

---

## 📌 Resumo

- Ordem do ciclo de vida: `createState` → `initState` → `didChangeDependencies` → `build` →
  (`didUpdateWidget` → `build`, `setState` → `build`)* → `deactivate` → `dispose`.
- `initState` roda **uma vez**: crie controllers, timers, listeners e assinaturas; derive o estado
  inicial de `widget.<campo>`. Não use `context` para `Theme`/`MediaQuery` aqui, e ele não pode ser
  `async`.
- `didChangeDependencies` roda depois do `initState` **e** sempre que um `InheritedWidget` muda. É
  onde o `context` já está pronto. Pode rodar muitas vezes — não crie recursos aqui sem cancelar os
  anteriores.
- `didUpdateWidget` roda quando o pai passa parâmetros novos. **Sempre compare** antes de reagir.
- `deactivate` é a saída reversível; `dispose` é definitiva.
- **Tudo criado no `initState` precisa ser desfeito no `dispose`.** `Timer.cancel()`,
  `controller.dispose()`, `removeListener`, `subscription.cancel()`.
- `super.initState()` vem **primeiro**; `super.dispose()` vem **por último**.
- `setState() called after dispose()` tem duas correções complementares: cancelar o recurso no
  `dispose` (estrutural) e checar `mounted` depois de cada `await` (rede de segurança).
- O sistema operacional pode matar o app sem chamar `dispose`. Nunca dependa dele para salvar dados.

---

## ☑️ Checklist de domínio

- [ ] Listo os sete métodos na ordem certa, de memória.
- [ ] Digo o que fazer e o que não fazer em cada um.
- [ ] Explico por que `Theme.of(context)` falha no `initState`.
- [ ] Sei por que `initState` não pode ser `async` e como contornar.
- [ ] Uso `didChangeDependencies` para o que depende de `context`.
- [ ] Escrevo um `didUpdateWidget` com a comparação correta.
- [ ] Explico a diferença entre `deactivate` e `dispose`.
- [ ] Cancelo `Timer`, removo listener e chamo `dispose` do controller — sem esquecer nenhum.
- [ ] Coloco `super.initState()` primeiro e `super.dispose()` por último.
- [ ] Reproduzi o vazamento do `Timer` e vi o erro se repetir a cada segundo.
- [ ] Explico por que checar `mounted` esconde o sintoma mas não resolve o vazamento.
- [ ] O cronômetro do `meu_primeiro_app` funciona e `flutter analyze` está limpo.

---

## 📚 Referências oficiais

- [State class — API docs](https://api.flutter.dev/flutter/widgets/State-class.html)
- [State.initState — API docs](https://api.flutter.dev/flutter/widgets/State/initState.html)
- [State.dispose — API docs](https://api.flutter.dev/flutter/widgets/State/dispose.html)
- [State.didUpdateWidget — API docs](https://api.flutter.dev/flutter/widgets/State/didUpdateWidget.html)
- [TextEditingController class](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)
- [Timer class — dart:async](https://api.flutter.dev/flutter/dart-async/Timer-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — StatefulWidget e setState](05-statefulwidget-e-setstate.md) | [README](README.md) | [Aula 7 — BuildContext](07-buildcontext.md) |
