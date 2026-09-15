# Aula 6 — Ciclo de vida do app

> **Módulo:** 11 - Recursos Nativos · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Listar os estados de **`AppLifecycleState`** e o que cada transição significa de verdade.
- Escolher entre **`WidgetsBindingObserver`** e **`AppLifecycleListener`**.
- Decidir **o que fazer em cada transição** — e o que nunca fazer.
- Entender que o app pode ser **morto sem aviso** e projetar para isso.
- Construir um **cronômetro que não mente**, baseado em carimbo de tempo.
- Conhecer os limites de **segundo plano** em Android e iOS.
- Proteger dados sensíveis quando o app aparece no **alternador de tarefas**.

## ✅ Pré-requisitos

- [Módulo 05, aula 6 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md)
  — **essencial**: aquele é o ciclo de vida de um **widget**; este é o do **app inteiro**.
- [Módulo 10, aula 2 — shared_preferences](../10-persistencia-de-dados/02-shared-preferences.md) —
  salvar estado antes de o app morrer.
- [Aula 4 — Notificações](04-notificacoes.md) — o que continua funcionando com o app fechado.
- [Módulo 08, aula 8 — Family, autoDispose e listen](../08-estado-e-arquitetura/08-family-autodispose-listen.md)
  — `ref.onDispose`.

---

## 📖 Conceito

### Dois ciclos de vida diferentes

No Módulo 05 você aprendeu `initState`, `dispose` e companhia. Aquilo é o ciclo de vida de **um
widget** — ele nasce e morre conforme a navegação.

Este é o ciclo de vida do **aplicativo**: o que acontece quando o usuário aperta o botão home,
atende uma ligação, ou o sistema decide matar o processo.

| | Ciclo do **widget** | Ciclo do **app** |
|---|---|---|
| Quem controla | A navegação do app | O **sistema operacional** |
| Dispara em | `push`, `pop`, rebuild | Home, alternador, ligação, bloqueio |
| API | `initState`, `dispose` | `AppLifecycleState` |
| Você pode impedir | ✅ | ❌ **Nunca** |

A última linha é a que muda o modo de pensar: **o sistema não pede licença**.

### Os cinco estados

```dart
enum AppLifecycleState {
  detached,   // sem tela; o app existe mas não está anexado
  resumed,    // visível e recebendo toques
  inactive,   // visível mas NÃO recebendo toques
  hidden,     // não visível (agrupa paused em algumas plataformas)
  paused,     // em segundo plano, código Dart suspenso
}
```

O que cada um significa na vida real:

| Estado | Quando acontece | O usuário vê |
|---|---|---|
| **`resumed`** | App em uso | Tudo normal |
| **`inactive`** | Ligação chegando, Central de Controle aberta, alternador de tarefas | O app, mas sem poder tocar |
| **`hidden`** | Prestes a ir para segundo plano | Transição |
| **`paused`** | Botão home, outro app aberto | Outra coisa |
| **`detached`** | Antes de o processo morrer | Nada |

A sequência típica ao apertar o botão home:

```text
resumed → inactive → hidden → paused
```

E ao voltar:

```text
paused → hidden → inactive → resumed
```

> ⚠️ **`inactive` acontece muito mais do que se imagina.** Puxar a central de notificações, receber
> uma ligação, abrir o alternador de tarefas — todos disparam `inactive` e voltam a `resumed` em
> seguida. Salvar dados em `inactive` significa salvar dezenas de vezes por dia sem necessidade.

### O que fazer em cada transição

| Transição | Faça | **Não** faça |
|---|---|---|
| → `inactive` | Esconder dado sensível da tela | Salvar no banco (acontece demais) |
| → `paused` | **Salvar estado**, pausar timers, soltar câmera/áudio | Operação longa (o código pode ser suspenso) |
| → `resumed` | Recarregar dados, revalidar sessão, retomar timers | Assumir que pouco tempo passou |
| → `detached` | Quase nada — **pode não ser chamado** | Confiar nele para salvar |
| → `hidden` | Tratar como `paused` | — |

E a regra que resume:

> **Salve em `paused`. Recarregue em `resumed`. Nunca conte com `detached`.**

### O app pode morrer sem aviso

Este é o ponto mais importante da aula:

```text
Usuário aperta home → app vai para paused
… 20 minutos depois, com o celular sob pressão de memória …
O sistema MATA o processo. Nenhum callback é chamado.
Usuário volta ao app → ele INICIA DO ZERO
```

O `detached` **não é garantido**. Em muitos casos, o processo simplesmente deixa de existir.

As consequências práticas:

1. **Salve em `paused`**, não em `detached`. `paused` é chamado; `detached`, talvez.
2. **Nunca guarde estado importante só na memória.**
3. **Projete a volta ao app como se fosse uma abertura nova.**

> 📌 No Android, há o `onSaveInstanceState` nativo, que permite restaurar estado de tela. No Flutter,
> o equivalente é `RestorationMixin` — útil, mas mais trabalhoso. Para a maioria dos apps, salvar em
> `paused` no `SharedPreferences` (Módulo 10) resolve.

### O cronômetro que não mente

O exemplo clássico de bug de ciclo de vida:

```dart
// ❌ este cronômetro MENTE
Timer.periodic(const Duration(seconds: 1), (_) => _segundos++);
```

O que acontece: o usuário inicia um cronômetro de 25 minutos, aperta home, e volta 30 minutos
depois. O cronômetro mostra **3 minutos**, porque o Dart foi suspenso em segundo plano e o `Timer`
parou de disparar.

A correção não é "fazer o timer continuar" — é **não depender dele para medir tempo**:

```dart
// ✅ o timer só ATUALIZA A TELA; o tempo vem do relógio
DateTime? _inicio;

Duration get decorrido =>
    _inicio == null ? Duration.zero : DateTime.now().difference(_inicio!);
```

Agora o `Timer` serve só para redesenhar a cada segundo. O valor real vem sempre da diferença entre
**agora** e o **carimbo de início** — que é verdadeiro mesmo que o app tenha ficado uma hora
suspenso.

> 💡 Essa distinção — **contar** tempo versus **medir** tempo — vale para tudo que envolve duração:
> cronômetro, tempo de sessão, expiração de token, intervalo de sincronização.

### `WidgetsBindingObserver` × `AppLifecycleListener`

Duas formas de observar. A antiga:

```dart
class _MinhaTelaState extends State<MinhaTela> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Esquecer isto vaza o observer.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // Um método só, com switch.
  }
}
```

E a moderna (Flutter 3.13+):

```dart
late final AppLifecycleListener _listener = AppLifecycleListener(
  onResume: _aoVoltar,
  onPause: _aoPausar,
  onInactive: _aoFicarInativo,
  onDetach: _aoDesanexar,
  // E o mais interessante:
  onExitRequested: _aoPedirSaida,
);

@override
void dispose() {
  _listener.dispose();
  super.dispose();
}
```

| | `WidgetsBindingObserver` | `AppLifecycleListener` |
|---|---|---|
| Versão | Sempre existiu | Flutter 3.13+ |
| API | Um método com `switch` | Um callback por evento |
| Também observa | Tamanho de tela, tema, idioma | Só o ciclo de vida |
| `onExitRequested` | ❌ | ✅ (desktop) |
| Legibilidade | Menor | Maior |

**Decisão do curso:** `AppLifecycleListener` para ciclo de vida; `WidgetsBindingObserver` quando
você também precisa observar mudanças de tema, idioma ou tamanho de tela.

### Segundo plano: o que realmente funciona

| Tarefa | 🤖 Android | 🍎 iOS |
|---|---|---|
| Código Dart rodando | ❌ suspenso em `paused` | ❌ suspenso |
| `Timer` continuando | ❌ | ❌ |
| Notificação agendada | ✅ (o sistema dispara) | ✅ |
| Download longo | ✅ com `WorkManager` | ⚠️ muito limitado |
| Sincronizar periodicamente | ✅ `WorkManager` (mín. 15 min) | ⚠️ `BGTaskScheduler`, sem garantia |
| Tocar áudio | ✅ com serviço em primeiro plano | ✅ com categoria de áudio |
| Rastrear localização | ✅ com permissão e serviço | ✅ com permissão "sempre" |

> ⚠️ **A regra honesta:** com o app em segundo plano, **o seu código Dart não roda**. O que
> funciona são recursos **agendados no sistema** (notificações) ou **serviços declarados**
> (áudio, localização, WorkManager).
>
> Se o seu app "precisa contar o tempo em segundo plano", ele na verdade precisa **medir** o tempo
> por carimbo — como o cronômetro acima.

### Proteger a tela no alternador de tarefas

Quando o usuário abre o alternador de tarefas, o sistema tira uma **captura** da tela do app. Se
houver dado sensível ali (saldo, mensagens, documento), ele fica visível — e, no Android, a captura
é gravada em disco.

```dart
// Android: impede captura de tela E a miniatura no alternador.
if (estado == AppLifecycleState.inactive) {
  await _canal.invokeMethod('ativarFlagSegura');
}
```

No Android, é a flag `FLAG_SECURE`. No iOS, o padrão é cobrir a tela com um widget na transição
para `inactive`.

Para o Foco isso não é necessário — mas é o tipo de coisa que você precisa saber que existe antes
de fazer um app bancário.

---

## 💡 Analogia

Pense em trabalhar numa sala de coworking.

- **`resumed`** é você na sua mesa, trabalhando.
- **`inactive`** é alguém te chamar no ombro: você ainda está na mesa, olhando para a tela, mas
  **não está mais digitando**. Acontece o tempo todo — e é por isso que você **não guarda tudo e
  fecha o notebook** a cada interrupção.
- **`paused`** é você sair da sala. O notebook fica lá, mas você **parou de trabalhar**. É aqui que
  você salva o documento — porque não sabe quando volta.
- **`detached`** seria a recepção te avisar "vamos fechar a sala". **E muitas vezes não avisam**: a
  sala é fechada e o seu material é recolhido enquanto você está no almoço. Contar com esse aviso
  para salvar o trabalho é perder o trabalho.
- **O app morto sem aviso** é exatamente isso: você volta do almoço e a mesa está vazia. Não houve
  negligência de ninguém — a sala precisava do espaço.
- **O cronômetro que mente** é você medir quanto tempo trabalhou **contando os minutos em que
  esteve digitando**. Se você saiu para almoçar, o contador parou — e você conclui que trabalhou
  duas horas quando o relógio da parede diz cinco. **Medir** é olhar o relógio na entrada e na
  saída; **contar** é o que o `Timer` faz.
- **A captura no alternador** é a foto que a portaria tira da sua mesa quando você sai. Se havia um
  documento confidencial aberto, ele está na foto.

---

## 🧪 Exemplo mínimo

Todos os estados visíveis, e o cronômetro certo lado a lado com o errado.

> **Arquivo:** `foco_nativo/lib/main.dart` (temporário)
> **Como executar:** `flutter run` em um **emulador Android** — no desktop os estados são diferentes

```dart
import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const AppCicloDeVida());

class AppCicloDeVida extends StatelessWidget {
  const AppCicloDeVida({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaCicloDeVida(),
    );
  }
}

class TelaCicloDeVida extends StatefulWidget {
  const TelaCicloDeVida({super.key});

  @override
  State<TelaCicloDeVida> createState() => _TelaCicloDeVidaState();
}

class _TelaCicloDeVidaState extends State<TelaCicloDeVida> {
  /// AppLifecycleListener (Flutter 3.13+): um callback por evento,
  /// em vez de um método com switch.
  late final AppLifecycleListener _listener;

  final List<String> _log = <String>[];

  // ── Os dois cronômetros ──────────────────────────────────────────────────

  /// ❌ CONTA segundos. Para quando o app é suspenso.
  int _segundosContados = 0;

  /// ✅ MEDE tempo. Verdadeiro mesmo com o app suspenso por uma hora.
  DateTime? _inicio;

  Timer? _tique;

  Duration get _decorridoReal =>
      _inicio == null ? Duration.zero : DateTime.now().difference(_inicio!);

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onResume: () => _registrar('▶️ resumed — visível e recebendo toques'),
      onInactive: () => _registrar('⏸️ inactive — visível, SEM toques'),
      onHide: () => _registrar('👻 hidden — saindo de vista'),
      onPause: () => _registrar('💤 paused — segundo plano, Dart SUSPENSO'),
      onRestart: () => _registrar('🔄 restart — voltando do segundo plano'),
      onDetach: () => _registrar('🔌 detached — pode NÃO ser chamado'),
      // O evento bruto, para ver a sequência completa.
      onStateChange: (AppLifecycleState estado) =>
          _registrar('   estado = ${estado.name}'),
    );
  }

  @override
  void dispose() {
    // Esquecer isto vaza o listener.
    _listener.dispose();
    _tique?.cancel();
    super.dispose();
  }

  void _registrar(String linha) {
    final String hora = DateTime.now().toIso8601String().substring(11, 19);
    debugPrint('[$hora] $linha');
    if (mounted) setState(() => _log.insert(0, '[$hora] $linha'));
  }

  void _iniciarCronometros() {
    setState(() {
      _segundosContados = 0;
      // O carimbo é a fonte da verdade. O Timer só redesenha.
      _inicio = DateTime.now();
    });

    _tique?.cancel();
    _tique = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _segundosContados++);
    });

    _registrar('⏱️ cronômetros iniciados');
  }

  void _pararCronometros() {
    _tique?.cancel();
    _registrar('⏹️ parados · contado: ${_segundosContados}s · '
        'real: ${_decorridoReal.inSeconds}s');
  }

  String _formatar(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:'
      '${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final int diferenca =
        _decorridoReal.inSeconds - _segundosContados;

    return Scaffold(
      appBar: AppBar(title: const Text('Ciclo de vida do app')),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          const Text('❌ contado'),
                          Text(
                            _formatar(Duration(seconds: _segundosContados)),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('Timer.periodic', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          const Text('✅ medido'),
                          Text(
                            _formatar(_decorridoReal),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('carimbo de tempo',
                              style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  if (diferenca > 2) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      '⚠️ diferença de ${diferenca}s — '
                      'o Timer parou enquanto o app estava suspenso',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FilledButton(
                        onPressed: _iniciarCronometros,
                        child: const Text('Iniciar'),
                      ),
                      OutlinedButton(
                        onPressed: _pararCronometros,
                        child: const Text('Parar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Inicie, aperte o botão home, espere 1 minuto e volte.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (BuildContext c, int i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                child: Text(
                  _log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**O roteiro que ensina a aula inteira:**

1. Toque em **Iniciar**. Os dois cronômetros andam juntos.
2. Aperte o **botão home**. Observe o log: `inactive` → `hidden` → `paused`.
3. **Espere 1 minuto** com o app em segundo plano.
4. Volte ao app. O log mostra `restart` → `resumed`.
5. **Compare os dois números:** o contado parou em ~5 segundos; o medido mostra ~65. A diferença é
   exatamente o tempo em que o Dart esteve suspenso.
6. Puxe a central de notificações e feche: `inactive` → `resumed`, **sem** `paused`. É por isso que
   salvar em `inactive` salvaria dezenas de vezes por dia.

---

## 📱 Aplicando no Flutter

O `foco_nativo` ganha um cronômetro de sessão de estudo que **não mente**, mais:

- salvamento automático em `paused`;
- recuperação de sessão interrompida na abertura;
- revalidação de dados em `resumed`;
- aviso quando o app ficou muito tempo fechado.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/lib/core/ciclo/observador_de_ciclo.dart` (novo)
> **Como executar:** `flutter run`

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O que o app faz em cada transição.
///
/// ⚠️ Regra central: SALVE em `paused`, RECARREGUE em `resumed`,
/// NUNCA conte com `detached`.
///
/// O `detached` pode simplesmente não ser chamado: sob pressão de
/// memória, o sistema mata o processo sem avisar ninguém.
class ObservadorDeCiclo {
  ObservadorDeCiclo({
    required Future<void> Function() aoPausar,
    required Future<void> Function(Duration tempoFora) aoVoltar,
    void Function()? aoFicarInativo,
  })  : _aoPausar = aoPausar,
        _aoVoltar = aoVoltar,
        _aoFicarInativo = aoFicarInativo;

  final Future<void> Function() _aoPausar;
  final Future<void> Function(Duration tempoFora) _aoVoltar;
  final void Function()? _aoFicarInativo;

  AppLifecycleListener? _listener;

  /// Quando o app foi para segundo plano. Serve para medir
  /// quanto tempo ficou fora.
  DateTime? _pausadoEm;

  void iniciar() {
    _listener = AppLifecycleListener(
      onInactive: () {
        // `inactive` acontece MUITO: central de notificações, ligação,
        // alternador de tarefas. Nunca salve dados aqui — seriam
        // dezenas de gravações por dia sem necessidade.
        // Use só para esconder informação sensível da tela.
        _aoFicarInativo?.call();
      },

      onPause: () {
        _pausadoEm = DateTime.now();
        // Salve AQUI. `paused` é chamado de forma confiável;
        // `detached` não é.
        //
        // Sem await de propósito: o Dart pode ser suspenso a
        // qualquer momento, e esperar não garante nada. Grave o
        // essencial de forma rápida.
        _aoPausar();
      },

      onResume: () {
        final Duration fora = _pausadoEm == null
            ? Duration.zero
            : DateTime.now().difference(_pausadoEm!);
        _pausadoEm = null;
        _aoVoltar(fora);
      },

      onDetach: () {
        // Quase nada aqui. Este callback PODE NÃO SER CHAMADO.
        // Confiar nele para salvar é perder dados.
        debugPrint('App desanexando');
      },
    );
  }

  void parar() {
    _listener?.dispose();
    _listener = null;
  }
}

/// Instala o observador no app inteiro.
final Provider<ObservadorDeCiclo> observadorDeCicloProvider =
    Provider<ObservadorDeCiclo>((Ref ref) {
  throw UnimplementedError('Sobrescreva no app.dart');
});
```

> **Arquivo:** `foco_nativo/lib/features/cronometro/domain/sessao_em_andamento.dart` (novo)

```dart
/// Uma sessão de estudo em andamento.
///
/// A ideia central: guardamos o INSTANTE de início, não o número de
/// segundos decorridos.
///
/// Contar segundos com um Timer produz um cronômetro que MENTE: o Dart
/// é suspenso em segundo plano, o Timer para, e o usuário que estudou
/// 30 minutos vê 3.
///
/// Medir pela diferença entre agora e o carimbo é verdadeiro mesmo que
/// o app tenha ficado uma hora suspenso — ou tenha sido MORTO e reaberto.
class SessaoEmAndamento {
  const SessaoEmAndamento({
    required this.materiaId,
    required this.iniciadaEm,
    this.pausadaEm,
    this.tempoPausado = Duration.zero,
  });

  factory SessaoEmAndamento.deJson(Map<String, Object?> json) {
    return SessaoEmAndamento(
      materiaId: json['materia_id']! as String,
      iniciadaEm:
          DateTime.fromMillisecondsSinceEpoch(json['iniciada_em']! as int),
      pausadaEm: json['pausada_em'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['pausada_em']! as int),
      tempoPausado:
          Duration(milliseconds: (json['tempo_pausado'] as int?) ?? 0),
    );
  }

  final String materiaId;
  final DateTime iniciadaEm;

  /// Quando o usuário pausou. Null = rodando.
  final DateTime? pausadaEm;

  /// Quanto tempo já ficou pausada, acumulado.
  final Duration tempoPausado;

  bool get rodando => pausadaEm == null;

  /// Tempo real de estudo.
  ///
  /// Calculado a partir do RELÓGIO, nunca de um contador. É isto que
  /// torna o cronômetro honesto.
  Duration get decorrido {
    final DateTime fim = pausadaEm ?? DateTime.now();
    return fim.difference(iniciadaEm) - tempoPausado;
  }

  int get minutos => decorrido.inMinutes;

  /// Sessão absurdamente longa indica que o app ficou aberto a noite
  /// inteira com o cronômetro ligado. Ninguém estuda 12 horas seguidas.
  bool get suspeita => decorrido.inHours >= 12;

  SessaoEmAndamento pausar() {
    if (!rodando) return this;
    return SessaoEmAndamento(
      materiaId: materiaId,
      iniciadaEm: iniciadaEm,
      pausadaEm: DateTime.now(),
      tempoPausado: tempoPausado,
    );
  }

  SessaoEmAndamento retomar() {
    final DateTime? pausa = pausadaEm;
    if (pausa == null) return this;

    return SessaoEmAndamento(
      materiaId: materiaId,
      iniciadaEm: iniciadaEm,
      // Acumula o tempo em que ficou pausada, para descontar depois.
      tempoPausado: tempoPausado + DateTime.now().difference(pausa),
    );
  }

  Map<String, Object?> paraJson() => <String, Object?>{
        'materia_id': materiaId,
        'iniciada_em': iniciadaEm.millisecondsSinceEpoch,
        'pausada_em': pausadaEm?.millisecondsSinceEpoch,
        'tempo_pausado': tempoPausado.inMilliseconds,
      };
}
```

> **Arquivo:** `foco_nativo/lib/features/cronometro/presentation/cronometro_controller.dart` (novo)

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foco_nativo/features/cronometro/domain/sessao_em_andamento.dart';

final NotifierProvider<CronometroController, SessaoEmAndamento?>
    cronometroProvider =
    NotifierProvider<CronometroController, SessaoEmAndamento?>(
        CronometroController.new);

class CronometroController extends Notifier<SessaoEmAndamento?> {
  static const String _chave = 'sessao_em_andamento';

  /// Só REDESENHA a tela. O tempo vem do carimbo, não deste timer.
  Timer? _tique;

  @override
  SessaoEmAndamento? build() {
    // Todo Timer criado precisa ser cancelado.
    ref.onDispose(() => _tique?.cancel());

    // Recupera uma sessão que ficou aberta. O app pode ter sido MORTO
    // pelo sistema enquanto o cronômetro rodava.
    Future<void>.microtask(_recuperar);

    return null;
  }

  // ── Persistência ─────────────────────────────────────────────────────────

  /// Salva a sessão. Chamado em `paused` e a cada mudança.
  ///
  /// Sem isto, o app morto em segundo plano perde a sessão inteira —
  /// e o usuário perde 25 minutos de estudo registrados.
  Future<void> salvar() async {
    final SessaoEmAndamento? sessao = state;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (sessao == null) {
      await prefs.remove(_chave);
      return;
    }
    await prefs.setString(_chave, jsonEncode(sessao.paraJson()));
  }

  Future<void> _recuperar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bruto = prefs.getString(_chave);
    if (bruto == null) return;

    try {
      final SessaoEmAndamento sessao = SessaoEmAndamento.deJson(
        jsonDecode(bruto) as Map<String, Object?>,
      );

      // Sessão absurda: o app ficou aberto a noite inteira com o
      // cronômetro ligado. Registrar 14 horas de estudo seria pior
      // que descartar.
      if (sessao.suspeita) {
        debugPrint('Sessão suspeita descartada: ${sessao.decorrido}');
        await prefs.remove(_chave);
        return;
      }

      state = sessao;
      if (sessao.rodando) _iniciarTique();
    } on Object catch (e) {
      // Formato antigo ou corrompido. Descarte — é estado transitório,
      // não dado do usuário.
      debugPrint('Sessão salva inválida: $e');
      await prefs.remove(_chave);
    }
  }

  // ── Controle ─────────────────────────────────────────────────────────────

  Future<void> iniciar(String materiaId) async {
    state = SessaoEmAndamento(
      materiaId: materiaId,
      // O carimbo é a FONTE DA VERDADE.
      iniciadaEm: DateTime.now(),
    );
    _iniciarTique();
    await salvar();
  }

  Future<void> pausar() async {
    final SessaoEmAndamento? atual = state;
    if (atual == null || !atual.rodando) return;

    state = atual.pausar();
    _tique?.cancel();
    await salvar();
  }

  Future<void> retomar() async {
    final SessaoEmAndamento? atual = state;
    if (atual == null || atual.rodando) return;

    state = atual.retomar();
    _iniciarTique();
    await salvar();
  }

  /// Encerra e devolve os minutos, para quem chama registrar no banco.
  Future<int> encerrar() async {
    final SessaoEmAndamento? atual = state;
    if (atual == null) return 0;

    final int minutos = atual.minutos;

    _tique?.cancel();
    state = null;
    await salvar();

    return minutos;
  }

  void _iniciarTique() {
    _tique?.cancel();
    // O Timer só existe para a tela redesenhar a cada segundo.
    // Se ele parar (app suspenso), o VALOR não é afetado: ele vem
    // sempre de DateTime.now() - iniciadaEm.
    _tique = Timer.periodic(const Duration(seconds: 1), (_) {
      // Reatribuir o mesmo objeto não notificaria (o Riverpod compara).
      // `ref.notifyListeners()` força o redesenho sem mudar o estado.
      ref.notifyListeners();
    });
  }

  // ── Ciclo de vida ────────────────────────────────────────────────────────

  /// Chamado quando o app vai para segundo plano.
  Future<void> aoPausarApp() async {
    // O Timer não vai disparar em segundo plano de qualquer forma;
    // cancelar economiza bateria e evita disparos estranhos na volta.
    _tique?.cancel();

    // Salva AGORA. O app pode ser morto a qualquer momento daqui
    // em diante, sem nenhum outro callback.
    await salvar();
  }

  /// Chamado quando o app volta.
  void aoVoltarApp(Duration tempoFora) {
    final SessaoEmAndamento? atual = state;
    if (atual == null) return;

    // O tempo continuou correndo: a sessão já reflete isso, porque
    // é medida pelo relógio. Só precisamos redesenhar.
    if (atual.rodando) {
      _iniciarTique();
      debugPrint(
        'Voltou após ${tempoFora.inMinutes} min · '
        'sessão acumulou ${atual.minutos} min',
      );
    }
  }
}
```

> **Arquivo:** `foco_nativo/lib/app.dart` (instalando o observador)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_nativo/core/ciclo/observador_de_ciclo.dart';
import 'package:foco_nativo/features/cronometro/presentation/cronometro_controller.dart';
import 'package:foco_nativo/features/trilhas/presentation/trilhas_controller.dart';

class FocoApp extends ConsumerStatefulWidget {
  const FocoApp({super.key});

  @override
  ConsumerState<FocoApp> createState() => _FocoAppState();
}

class _FocoAppState extends ConsumerState<FocoApp> {
  late final ObservadorDeCiclo _ciclo;

  /// Quanto tempo fora justifica recarregar os dados.
  ///
  /// Voltar depois de 10 segundos não precisa de requisição nova;
  /// depois de 5 minutos, os dados podem ter mudado.
  static const Duration _limiteParaRecarregar = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();

    _ciclo = ObservadorDeCiclo(
      aoPausar: _aoPausar,
      aoVoltar: _aoVoltar,
      aoFicarInativo: _aoFicarInativo,
    )..iniciar();
  }

  @override
  void dispose() {
    _ciclo.parar();
    super.dispose();
  }

  // ── As três transições ───────────────────────────────────────────────────

  void _aoFicarInativo() {
    // `inactive` acontece dezenas de vezes por dia: central de
    // notificações, ligação, alternador de tarefas.
    //
    // NÃO salve nada aqui. Use só para esconder dado sensível —
    // o sistema tira uma captura da tela para o alternador de tarefas.
    //
    // O Foco não tem dado sensível na tela, então não fazemos nada.
  }

  Future<void> _aoPausar() async {
    // SALVE AQUI. Este callback é confiável; `detached` não é.
    // Daqui em diante, o sistema pode matar o processo sem avisar.
    await ref.read(cronometroProvider.notifier).aoPausarApp();
  }

  Future<void> _aoVoltar(Duration tempoFora) async {
    // 1. O cronômetro retoma o tique. O VALOR já está correto:
    //    ele é medido pelo relógio, não contado.
    ref.read(cronometroProvider.notifier).aoVoltarApp(tempoFora);

    // 2. Recarrega os dados SÓ se ficou fora tempo suficiente.
    //    Recarregar a cada volta gastaria requisição à toa —
    //    o usuário alterna de app dezenas de vezes por hora.
    if (tempoFora >= _limiteParaRecarregar) {
      debugPrint('Fora por ${tempoFora.inMinutes} min: recarregando');
      await ref.read(trilhasProvider.notifier).recarregar();
    }

    // 3. Se ficou fora MUITO tempo, a sessão pode ter expirado.
    //    (No app com login: revalidar o token aqui.)
    if (tempoFora >= const Duration(hours: 12)) {
      debugPrint('Fora por ${tempoFora.inHours} h: revalidar sessão');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: const HomeScreen(),
    );
  }
}
```

> **Arquivo:** `foco_nativo/lib/features/cronometro/presentation/cronometro_widget.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_nativo/features/cronometro/domain/sessao_em_andamento.dart';
import 'package:foco_nativo/features/cronometro/presentation/cronometro_controller.dart';

class CronometroWidget extends ConsumerWidget {
  const CronometroWidget({super.key, required this.materiaId});

  final String materiaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessaoEmAndamento? sessao = ref.watch(cronometroProvider);
    final bool minhaSessao = sessao?.materiaId == materiaId;

    // O valor vem do RELÓGIO a cada rebuild. O Timer do controller
    // só provoca o rebuild — ele não acumula nada.
    final Duration decorrido =
        minhaSessao ? sessao!.decorrido : Duration.zero;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(
              _formatar(decorrido),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontFeatures: const <FontFeature>[
                      // Dígitos de largura fixa: sem isto o cronômetro
                      // "pula" quando 1 vira 8.
                      FontFeature.tabularFigures(),
                    ],
                  ),
            ),
            const SizedBox(height: 16),

            if (!minhaSessao)
              FilledButton.icon(
                onPressed: () =>
                    ref.read(cronometroProvider.notifier).iniciar(materiaId),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar sessão'),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FilledButton.tonal(
                    onPressed: () => sessao!.rodando
                        ? ref.read(cronometroProvider.notifier).pausar()
                        : ref.read(cronometroProvider.notifier).retomar(),
                    child: Text(sessao!.rodando ? 'Pausar' : 'Retomar'),
                  ),
                  FilledButton(
                    onPressed: () => _encerrar(context, ref),
                    child: const Text('Concluir'),
                  ),
                ],
              ),

            if (minhaSessao && !sessao!.rodando) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Pausada',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            const SizedBox(height: 12),
            Text(
              // Honestidade com o usuário: o cronômetro conta o tempo
              // real, mesmo com o app fechado.
              'O tempo continua contando mesmo se você sair do app.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _encerrar(BuildContext context, WidgetRef ref) async {
    final int minutos =
        await ref.read(cronometroProvider.notifier).encerrar();

    if (!context.mounted) return;

    if (minutos < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão curta demais para registrar')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$minutos minutos registrados')),
    );
  }

  String _formatar(Duration d) {
    final String h = d.inHours.toString().padLeft(2, '0');
    final String m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final String s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
```

Rode e faça o teste decisivo:

```powershell
flutter analyze
flutter run
```

1. Inicie uma sessão.
2. **Feche o app completamente** (alternador de tarefas → deslizar para cima).
3. Espere 2 minutos.
4. Abra o app de novo.
5. **A sessão continua lá, com os 2 minutos contabilizados.**

Isso funciona porque o tempo é **medido**, não contado — e porque a sessão foi salva em `paused`.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `AppLifecycleListener` em vez de `WidgetsBindingObserver` | Um callback por evento, mais legível. Disponível desde o Flutter 3.13. |
| `_listener.dispose()` | Esquecer vaza o listener. |
| `onInactive` **sem salvar nada** | `inactive` acontece dezenas de vezes por dia. Salvar ali seria gravação constante sem motivo. |
| `onPause` salvando | É o callback **confiável**. Daqui em diante o processo pode morrer sem avisar. |
| `onDetach` quase vazio | **Pode não ser chamado.** Confiar nele para salvar é perder dados. |
| `_pausadoEm` para medir o tempo fora | Permite decidir se vale recarregar e se a sessão expirou. |
| `SessaoEmAndamento` guardando **`iniciadaEm`**, não segundos | **O ponto da aula.** O tempo é **medido** pelo relógio, não **contado** por um timer que para. |
| `decorrido` calculado a cada leitura | Verdadeiro mesmo com o app suspenso por horas — ou morto e reaberto. |
| `tempoPausado` acumulado | Pausar e retomar precisa descontar o intervalo, e o carimbo sozinho não sabe disso. |
| `suspeita` (≥ 12 h) | O app ficou aberto a noite inteira. Registrar 14 h de estudo seria pior que descartar. |
| `Timer` que só chama `ref.notifyListeners()` | Ele **redesenha**, não acumula. Se parar, o valor não é afetado. |
| `ref.onDispose(() => _tique?.cancel())` | Todo `Timer` precisa ser cancelado. |
| `_recuperar` no `build()` do notifier | O app pode ter sido morto com o cronômetro rodando. |
| `catch` no `_recuperar` descartando | Formato antigo ou corrompido. É estado transitório, não dado do usuário. |
| `_limiteParaRecarregar = 5 min` | Recarregar a cada volta gastaria requisição à toa: o usuário alterna de app dezenas de vezes por hora. |
| `FontFeature.tabularFigures()` | Dígitos de largura fixa. Sem isso o cronômetro "pula" quando 1 vira 8. |
| Texto "o tempo continua contando mesmo se você sair" | Honestidade: o usuário precisa saber que pode sair do app. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Código Dart em segundo plano | Suspenso | Suspenso |
| Tempo até ser morto | Minutos a horas | **Mais agressivo** |
| `detached` chamado | Às vezes | Raramente |
| Voltar após ser morto | App reinicia | App reinicia |
| Alternador de tarefas | Captura gravada em disco | Captura em memória |
| Impedir a captura | `FLAG_SECURE` | Cobrir a tela em `inactive` |
| `inactive` ao receber ligação | ✅ | ✅ |
| `inactive` ao puxar notificações | ✅ | ✅ |
| Multitarefa em tablet | Split screen → `resumed` nas duas | Split View → pode ficar `inactive` |

> ⚠️ **A segunda linha é a mais importante.** O iOS mata apps em segundo plano **muito** mais
> rápido que o Android. Um app que o usuário deixou de lado por 10 minutos provavelmente já foi
> encerrado no iPhone. Projete a volta como uma **abertura nova**, sempre.

> 📌 **A linha do Split View do iPad merece atenção:** com dois apps lado a lado, o app que não está
> em foco fica em `inactive` — não `paused`. Ele continua visível e o Dart continua rodando, mas
> não recebe toques. Um app que pausa o cronômetro em `inactive` pararia de contar sempre que o
> usuário tocasse no outro app.

---

## ⚠️ Erros comuns

### 1. Contar tempo com `Timer`

```dart
Timer.periodic(const Duration(seconds: 1), (_) => _segundos++);   // ❌
```

O Dart é suspenso em segundo plano. O usuário estuda 30 minutos e o app registra 3.

**Correção:** guarde o carimbo de início e calcule a diferença.

### 2. Salvar em `detached`

```dart
onDetach: () => salvarTudo(),   // ❌ pode não ser chamado
```

**Correção:** salve em `paused`.

### 3. Salvar em `inactive`

```dart
onInactive: () => salvarTudo(),   // ⚠️ dezenas de vezes por dia
```

Puxar a central de notificações dispara `inactive`.

**Correção:** salve em `paused`.

### 4. Pausar o cronômetro em `inactive`

```dart
onInactive: () => pausarCronometro(),   // ⚠️
```

No Split View do iPad, tocar no outro app pausaria o cronômetro do usuário.

**Correção:** trate `paused`, não `inactive` — e, com tempo medido, nem isso é necessário.

### 5. Esquecer `dispose` do listener

```dart
AppLifecycleListener(onResume: ...);   // ❌ sem guardar nem descartar
```

**Correção:** guarde em campo e chame `dispose()`.

### 6. Assumir que pouco tempo passou

```dart
onResume: () => atualizarRelogio(),   // ⚠️ e se passaram 8 horas?
```

**Correção:** meça o tempo fora e reaja proporcionalmente.

### 7. Recarregar tudo a cada `resumed`

```dart
onResume: () => recarregarTudo(),   // ⚠️ dezenas de requisições por hora
```

**Correção:** limite por tempo fora (5 minutos, por exemplo).

### 8. Não recuperar estado na abertura

O app foi morto com o cronômetro rodando. O usuário volta e perde 25 minutos.

**Correção:** salve em `paused` e recupere na inicialização.

### 9. Restaurar sessão absurda

O app ficou aberto a noite inteira; ao abrir, registra 14 horas de estudo.

**Correção:** descarte sessões com duração implausível.

### 10. Operação longa em `paused`

```dart
onPause: () async {
  await sincronizarTudoComServidor();   // ⚠️ o Dart pode ser suspenso no meio
}
```

**Correção:** grave só o essencial, rápido. Sincronização fica para o `resumed`.

### 11. Não avisar que o tempo continua

O usuário não sabe se pode sair do app e fica olhando o cronômetro.

**Correção:** uma frase na tela.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e execute o roteiro de seis passos. Anote a diferença entre os
dois cronômetros.

**Passo 2.** Puxe a central de notificações e feche, sem sair do app. Confira no log: aparece
`paused`? Explique por que isso importa para a decisão de onde salvar.

**Passo 3.** No `foco_nativo`, inicie uma sessão, **feche o app completamente** e reabra. A sessão
foi recuperada?

**Passo 4.** Remova o `await salvar()` do `aoPausarApp`. Repita o passo 3 e descreva o que se
perdeu.

**Passo 5.** Em `SessaoEmAndamento`, troque `decorrido` por um contador incrementado pelo `Timer`.
Feche o app por 2 minutos e volte. Compare.

**Passo 6.** Mude `_limiteParaRecarregar` para `Duration.zero`. Alterne entre o Foco e outro app
cinco vezes e conte as requisições (acrescente um `debugPrint`).

**Passo 7.** Remova o `ref.onDispose(() => _tique?.cancel())`. Navegue para outra tela e volte
várias vezes. Quantos timers estão rodando?

**Passo 8.** Ajuste `suspeita` para `>= 1 minuto`. Inicie uma sessão, espere 2 minutos, feche e
reabra. O que acontece?

**Passo 9.** Se tiver um iPhone ou simulador, abra o app, vá para outro e espere 15 minutos.
Ele foi morto? Compare com o comportamento no Android.

**Passo 10.** Responda por escrito: por que `detached` não serve para salvar? E o que aconteceria se
o seu app dependesse dele?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os exercícios de **Aplicação** com salvamento em `paused`, o de **Correção de bugs** com o
cronômetro que conta, e o de **Compreensão** sobre os cinco estados.

---

## 🏆 Desafio opcional

Implemente **detecção de sessão abandonada**.

Cenário: o usuário inicia o cronômetro, fecha o app e esquece. Três dias depois ele abre o Foco e há
uma sessão de 72 horas.

Requisitos:

- Ao recuperar uma sessão, o app calcula há quanto tempo o **app foi visto pela última vez** (não a
  duração da sessão).
- Se o app ficou fechado mais de 30 minutos com a sessão rodando, **pergunta** ao usuário:
  "Você tinha uma sessão de Dart aberta. Quanto tempo você estudou de verdade?"
- Oferece três opções: o tempo até o app ser fechado, um valor digitado, ou descartar.
- Se o app ficou fechado menos de 30 minutos, recupera normalmente, sem perguntar.
- Um teste simula os três cenários.

Dica: guarde também o `ultimaVezVisto` a cada `paused`. A diferença entre ele e `DateTime.now()` na
recuperação é o tempo em que o app esteve fechado — que é diferente da duração da sessão.

Depois responda: por que perguntar é melhor que adivinhar? E qual das três opções deve ser a
**sugerida** por padrão?

---

## 📌 Resumo

- O ciclo de vida do **app** é controlado pelo **sistema operacional** — você não pode impedir
  nenhuma transição.
- Cinco estados: `resumed`, `inactive`, `hidden`, `paused`, `detached`.
- **`inactive` acontece dezenas de vezes por dia** (notificações, ligação, alternador). Não salve
  nada ali.
- **Salve em `paused`. Recarregue em `resumed`. Nunca conte com `detached`** — ele pode não ser
  chamado.
- **O app pode ser morto sem aviso.** Projete a volta como uma abertura nova.
- **Nunca conte tempo com `Timer`**: o Dart é suspenso em segundo plano. Guarde o **carimbo de
  início** e **meça** pela diferença.
- O `Timer` serve só para **redesenhar** a tela; se ele parar, o valor não é afetado.
- Meça **quanto tempo o app ficou fora** e reaja proporcionalmente: recarregar a cada volta gasta
  requisição à toa.
- Descarte estado recuperado **implausível** (sessão de 14 horas).
- **`AppLifecycleListener`** (Flutter 3.13+) é mais legível que `WidgetsBindingObserver` — e
  precisa de `dispose()`.
- No **Split View do iPad**, o app fora de foco fica `inactive`, não `paused`.
- **O iOS mata apps em segundo plano muito mais rápido** que o Android.
- Em segundo plano, **seu código Dart não roda**. O que funciona é agendado pelo sistema
  (notificações) ou declarado como serviço.

---

## ☑️ Checklist de domínio

- [ ] Distingo o ciclo de vida do widget do ciclo de vida do app.
- [ ] Listo os cinco estados e o que cada um significa.
- [ ] Sei que `inactive` acontece o tempo todo e não salvo nada nele.
- [ ] Salvo em `paused` e nunca dependo de `detached`.
- [ ] Projeto a volta ao app como uma abertura nova.
- [ ] Meço tempo por carimbo, nunca por contador.
- [ ] Uso o `Timer` só para redesenhar.
- [ ] Cancelo todo `Timer` no descarte.
- [ ] Meço o tempo fora e reajo proporcionalmente.
- [ ] Descarto estado recuperado implausível.
- [ ] Uso `AppLifecycleListener` e chamo `dispose()`.
- [ ] Sei que no Split View o app fica `inactive`, não `paused`.
- [ ] Sei que meu código Dart não roda em segundo plano.

---

## 📚 Referências oficiais

- [AppLifecycleState — api.flutter.dev](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)
- [AppLifecycleListener — api.flutter.dev](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html)
- [WidgetsBindingObserver — api.flutter.dev](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-mixin.html)
- [Restore state on Android — docs.flutter.dev](https://docs.flutter.dev/platform-integration/android/restore-state-android)
- [Restore state on iOS — docs.flutter.dev](https://docs.flutter.dev/platform-integration/ios/restore-state-ios)
- [Activity lifecycle — developer.android.com](https://developer.android.com/guide/components/activities/activity-lifecycle)
- [Managing your app's life cycle — developer.apple.com](https://developer.apple.com/documentation/uikit/app_and_environment/managing_your_app_s_life_cycle)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Conectividade](05-conectividade.md) | [README](README.md) | [Aula 7 — Pastas android/ e ios/](07-pastas-android-e-ios.md) |
