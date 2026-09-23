# Aula 4 — Medindo desempenho

> **Módulo:** 13 - Desempenho e Segurança · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que **medir em modo debug não vale nada** e rodar em **modo profile**.
- Ler o **gráfico de frames** do DevTools e identificar quadros fora do orçamento.
- Distinguir **UI thread × raster thread** — e por que isso muda a correção.
- Usar os **overlays** (`showPerformanceOverlay`, `debugPaintSizeEnabled`, repaint rainbow).
- Marcar trechos do seu código com **`Timeline.timeSync`** e vê-los no gráfico.
- Medir o **tamanho do app** com `--analyze-size` e entender o que ocupa espaço.
- Seguir um **método de 6 passos** para investigar lentidão.

## ✅ Pré-requisitos

- [Aula 3 — Assíncrono sem travar](03-assincrono-sem-travar.md) — o orçamento de 16 ms e os
  isolates; a tela de relatório é o alvo da medição.
- [Aula 1 — Rebuilds, const e keys](01-rebuilds-const-e-keys.md) — o que causa `build` demais.
- [Módulo 12, aula 3 — DevTools](../12-testes-e-debug/03-devtools.md) — abrir e navegar o DevTools.
- Um aparelho Android (ou emulador) para medir de verdade.

---

## 📖 Conceito

### Os três modos, e por que isso vem primeiro

```powershell
flutter run                  # debug   — o padrão
flutter run --profile        # profile — para MEDIR
flutter run --release        # release — o que vai para a loja
```

| | debug | **profile** | release |
|---|---|---|---|
| Compilação | JIT | **AOT** | AOT |
| Velocidade | ⚠️ Várias vezes mais lento | ✅ ≈ release | ✅ |
| Hot reload | ✅ | ❌ | ❌ |
| Asserts | ✅ ligados | ❌ | ❌ |
| DevTools | ✅ Completo | ✅ **Completo** | ⚠️ Limitado |
| Serve para medir | ❌ **Nunca** | ✅ **Sempre** | ⚠️ Sem ferramentas |
| Roda em emulador | ✅ | ⚠️ Use aparelho | ⚠️ |

> ⚠️ **Nunca tire conclusão de desempenho em modo debug.** O debug roda com JIT, verificações
> ligadas e código de instrumentação. É comum ser **5 a 10 vezes** mais lento. Uma lista que parece
> travada em debug pode estar perfeita em profile — e você passaria a tarde "otimizando" um
> problema que não existe.

```powershell
flutter run --profile -d <aparelho>
```

> 💡 **E no aparelho, não no emulador.** O emulador usa a CPU e a GPU do PC — o desempenho não tem
> relação com o do celular do usuário. Para desempenho, **aparelho físico, modo profile**. Sem
> exceção.

### O gráfico de frames

DevTools → aba **Performance**. Cada barra é um quadro.

```text
     ms
  32 ┤              ██
  16 ┼──────────────██──────────  ← a linha do orçamento
   8 ┤  ▄▄ ▄▄ ▄▄ ▄▄ ██ ▄▄ ▄▄
   0 ┴──────────────────────────
        quadros ao longo do tempo
```

| Cor da barra | Thread | Significa |
|---|---|---|
| 🔵 Azul | **UI** | Seu código Dart: `build`, layout |
| 🟢 Verde | **Raster** | Desenhar na GPU |

Barra acima da linha = quadro perdido. E **a cor diz onde está o problema**:

| Barra alta | Culpado | Onde procurar |
|---|---|---|
| 🔵 UI alta | Seu Dart | `build` pesado, cálculo, JSON, muitos rebuilds |
| 🟢 Raster alta | Pintura | Sombras, `Opacity`, `ClipPath`, blur, imagem grande |
| 🔵🟢 As duas | Ambos | Comece pela UI |

> 📌 **Esta distinção economiza horas.** Otimizar `build` quando o problema é raster não muda nada
> — e vice-versa. **Olhe a cor antes de mexer em qualquer coisa.**

O que costuma pesar em cada uma:

| 🔵 UI thread | 🟢 Raster thread |
|---|---|
| `build` caro | `BoxShadow` em muitos widgets |
| Rebuild da árvore inteira | `Opacity` (crie uma camada) |
| `jsonDecode` grande | `ClipPath`, `ClipRRect` sem `RepaintBoundary` |
| Cálculo sem isolate | `BackdropFilter` (blur) |
| `setState` em excesso | Imagem grande sem `cacheWidth` |
| Layout complexo demais | `saveLayer` (o mais caro de todos) |

### Os overlays

Ferramentas visuais, sem abrir o DevTools:

```dart
MaterialApp(
  // Dois gráficos no topo: verde = raster, azul = UI.
  showPerformanceOverlay: true,
  home: const Inicio(),
)
```

```dart
import 'package:flutter/rendering.dart';

void main() {
  // Contornos de todas as caixas — acha layout errado.
  debugPaintSizeEnabled = true;

  // Pisca a borda de quem foi REPINTADO. A cor muda a cada
  // repintura: se algo fica piscando parado, está repintando à toa.
  debugRepaintRainbowEnabled = true;

  runApp(const MeuApp());
}
```

| Overlay | Para quê |
|---|---|
| `showPerformanceOverlay` | Ver jank sem o DevTools |
| `debugPaintSizeEnabled` | Contornos de layout |
| `debugRepaintRainbowEnabled` | **Quem repinta à toa** |
| `debugPaintLayerBordersEnabled` | Fronteiras de camada |
| `debugProfileBuildsEnabled` | Manda cada `build` para o Timeline |

> 💡 **O repaint rainbow é o mais útil dos cinco.** Abra uma tela parada: se alguma borda fica
> piscando, algo está repintando sem motivo. É o caminho mais rápido para descobrir onde falta um
> `RepaintBoundary` (aula 1).

### `Timeline`: marcar o seu código

O gráfico mostra que o quadro demorou 40 ms — mas **em quê**? Para saber, marque:

```dart
import 'dart:developer';

Timeline.timeSync('calcular resumo', () {
  resumo = calcularResumo(sessoes);
});
```

O trecho aparece nomeado no gráfico, com a duração exata.

```dart
// Assíncrono: início e fim separados.
final TimelineTask tarefa = TimelineTask()..start('importar histórico');
await importar();
tarefa.finish();
```

> ⚠️ **`Timeline` só funciona em debug e profile** — em release as chamadas são removidas. Isso é
> bom: você pode deixar as marcações no código sem custo em produção.

### `--analyze-size`

Desempenho não é só velocidade: o tamanho do download decide se o usuário instala.

```powershell
flutter build apk --analyze-size --target-platform android-arm64
flutter build appbundle --analyze-size
```

A saída mostra o que ocupa espaço:

```text
  libapp.so (código Dart)          4,2 MB
  libflutter.so (engine)           7,1 MB
  assets/imagens/                  8,9 MB   ← ⚠️
  assets/fonts/                    2,1 MB
```

| Referência de tamanho (APK release) | Veredito |
|---|---|
| < 15 MB | ✅ Ótimo |
| 15–30 MB | ✅ Normal |
| 30–50 MB | ⚠️ Revise os assets |
| > 50 MB | ❌ Algo está errado |

O que costuma inchar:

| Causa | Correção |
|---|---|
| Imagens PNG grandes | WebP; redimensione para o uso real |
| Fontes inteiras | Só os pesos usados |
| APK universal | **AAB** (Módulo 15, aula 8) |
| Pacote inteiro por uma função | Escreva a função |
| Assets esquecidos | Limpe a pasta |

> 💡 O **App Bundle** entrega a cada aparelho só a arquitetura e a densidade dele: costuma cortar
> 30–40 % do download sem você mexer em nada. É o assunto do Módulo 15.

### O método de 6 passos

1. **Reproduza** — qual gesto, em qual tela, em qual aparelho?
2. **Meça em profile, no aparelho.** Confirme que o problema existe fora do debug.
3. **Olhe a cor da barra.** UI ou raster? Isso decide todo o resto.
4. **Ache o culpado** com `Timeline`, Inspector ou repaint rainbow.
5. **Corrija uma coisa só.**
6. **Meça de novo** e compare com o número de antes.

> 📌 **O passo 5 é o mais violado.** Mudar cinco coisas de uma vez e ver melhora não ensina nada:
> você não sabe qual funcionou, e pode ter piorado duas para melhorar três. **Uma mudança, uma
> medição.**

E antes dos seis: **anote o número de antes**. "Ficou mais rápido" não é medição; "de 42 ms para
9 ms" é.

---

## 💡 Analogia

Pense num médico investigando uma dor.

- **Medir em debug** é examinar o paciente **depois de ele correr dez quilômetros**. Tudo está
  alterado — pulso, respiração, pressão. Qualquer conclusão tirada dali é sobre a corrida, não
  sobre a doença. Modo profile é examinar em repouso.
- **Medir no emulador** é examinar **outra pessoa**. O emulador tem a CPU e a GPU do seu PC; o
  usuário tem um celular de 700 reais.
- **O gráfico de frames** é o eletrocardiograma: batimentos regulares e, de vez em quando, um pico.
  O pico é o quadro perdido.
- **A cor da barra** é o exame que diz **qual órgão**. Azul é o cérebro pensando demais (seu Dart);
  verde é o músculo desenhando demais (a GPU). Tratar o cérebro quando o problema é o músculo não
  cura nada — e é o erro mais comum.
- **`Timeline.timeSync`** é o contraste no exame: você marca a região suspeita para ela aparecer
  nítida na imagem.
- **`--analyze-size`** é a balança. Não tem a ver com a dor, mas o paciente também não pode pesar
  200 kg.
- **"Uma mudança, uma medição"** é a regra básica de qualquer tratamento: receitar cinco remédios
  juntos e o paciente melhorar não diz **qual** funcionou — e um deles pode estar fazendo mal.

---

## 🧪 Exemplo mínimo

Uma tela com jank de propósito, dos dois tipos.

> **Arquivo:** `foco_desempenho/lib/core/perf/marcadores.dart` (novo)

```dart
import 'dart:developer' as dev;

/// Marcadores de desempenho.
///
/// Ficam no código de produção sem custo: em release, as chamadas
/// de `Timeline` são removidas pelo compilador.
abstract final class Perf {
  /// Marca um trecho SÍNCRONO no gráfico do DevTools.
  ///
  /// ```dart
  /// final r = Perf.medir('calcular resumo', () => calcular(dados));
  /// ```
  static T medir<T>(String nome, T Function() corpo) {
    return dev.Timeline.timeSync(nome, corpo);
  }

  /// Marca um trecho ASSÍNCRONO.
  ///
  /// Início e fim ficam separados no tempo, então precisa de
  /// uma TimelineTask — `timeSync` não serve aqui.
  static Future<T> medirAsync<T>(
    String nome,
    Future<T> Function() corpo,
  ) async {
    final dev.TimelineTask tarefa = dev.TimelineTask()..start(nome);
    try {
      return await corpo();
    } finally {
      // finally: a tarefa fecha mesmo se der exceção.
      // Sem isso, uma falha deixaria a marcação aberta para sempre.
      tarefa.finish();
    }
  }

  /// Cronometra e imprime — para quando você quer o NÚMERO no
  /// console, sem abrir o DevTools.
  static T cronometrar<T>(String nome, T Function() corpo) {
    final Stopwatch relogio = Stopwatch()..start();
    final T r = corpo();
    relogio.stop();

    final int ms = relogio.elapsedMilliseconds;
    // 16 ms é o orçamento do quadro: acima disso, é jank.
    final String sinal = ms > 16 ? '⚠️' : '✅';
    dev.log('$sinal $nome: $ms ms', name: 'perf');

    return r;
  }
}
```

> **Arquivo:** `foco_desempenho/lib/features/estatisticas/presentation/jank_demo_screen.dart` (novo)
> **Como executar:** `flutter run --profile -d <aparelho>`

```dart
import 'package:flutter/material.dart';

import '../../../core/perf/marcadores.dart';

/// Três listas: uma lisa, uma com jank de UI, uma com jank de raster.
///
/// Rode em PROFILE, num aparelho, com o DevTools aberto na aba
/// Performance. A cor da barra alta diz qual aba você está vendo.
class JankDemoScreen extends StatelessWidget {
  const JankDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Onde está o jank?'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: '✅ Lisa'),
              Tab(text: '🔵 Jank de UI'),
              Tab(text: '🟢 Jank de raster'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _ListaLisa(),
            _JankDeUi(),
            _JankDeRaster(),
          ],
        ),
      ),
    );
  }
}

/// ✅ Referência: barras baixas nas duas threads.
class _ListaLisa extends StatelessWidget {
  const _ListaLisa();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemExtent: 80,
      itemCount: 500,
      itemBuilder: (BuildContext context, int i) => const _ItemSimples(),
    );
  }
}

class _ItemSimples extends StatelessWidget {
  const _ItemSimples();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: CircleAvatar(child: Icon(Icons.book)),
      title: Text('Matéria'),
      subtitle: Text('45 min estudados'),
    );
  }
}

/// 🔵 Jank de UI: cálculo dentro do build.
///
/// No DevTools: a barra AZUL estoura. O culpado é o seu Dart.
class _JankDeUi extends StatelessWidget {
  const _JankDeUi();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemExtent: 80,
      itemCount: 500,
      itemBuilder: (BuildContext context, int i) {
        // ⚠️ Cálculo caro DENTRO do itemBuilder: roda a cada item,
        // a cada rolagem. Marcado para aparecer nomeado no gráfico.
        final double valor = Perf.medir('calculo no build', () {
          double soma = 0;
          for (int k = 0; k < 200000; k++) {
            soma += k % 7;
          }
          return soma;
        });

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.book)),
          title: Text('Matéria ${i + 1}'),
          subtitle: Text('valor $valor'),
        );
      },
    );
  }
}

/// 🟢 Jank de raster: efeitos caros de pintar.
///
/// No DevTools: a barra VERDE estoura, e a azul fica baixa.
/// Nenhum cálculo aqui — o custo é todo da GPU.
class _JankDeRaster extends StatelessWidget {
  const _JankDeRaster();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemExtent: 120,
      itemCount: 500,
      itemBuilder: (BuildContext context, int i) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Opacity(
            // ⚠️ Opacity < 1 força saveLayer: a GPU desenha numa
            // camada separada e depois compõe. É o efeito mais
            // caro do Flutter.
            opacity: 0.99,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: <BoxShadow>[
                    // ⚠️ Três sombras com blur alto, por item.
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.2),
                      blurRadius: 50,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Center(child: Text('Matéria ${i + 1}')),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

**O experimento:**

1. `flutter run --profile -d <aparelho>`.
2. Abra o DevTools → **Performance** → ligue **Track widget builds**.
3. Role cada aba por cinco segundos.
4. Compare:

| Aba | 🔵 UI | 🟢 Raster |
|---|---|---|
| ✅ Lisa | ~4 ms | ~3 ms |
| 🔵 Jank de UI | **~35 ms** | ~3 ms |
| 🟢 Jank de raster | ~4 ms | **~28 ms** |

> 📌 **Repare que as duas últimas abas parecem igualmente travadas para o usuário** — mas a correção
> é completamente diferente. Na aba azul, tire o cálculo do `build` (aulas 1 e 3). Na verde, tire o
> `Opacity` e reduza as sombras. Aplicar a correção errada não muda **nada**.

---

## 📱 Aplicando no Flutter

Um painel de medição embutido no app, para acompanhar o desempenho durante o desenvolvimento.

---

## 💻 Código completo

> **Arquivo:** `foco_desempenho/lib/core/perf/monitor_de_quadros.dart` (novo)

```dart
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

/// Acompanha o tempo de cada quadro e acumula estatísticas.
///
/// É o DevTools em miniatura, dentro do app: útil para deixar
/// ligado durante o desenvolvimento e ver o efeito de cada mudança
/// sem abrir ferramenta nenhuma.
///
/// ⚠️ Os números só têm valor em modo PROFILE. Em debug, tudo
/// estoura o orçamento e não significa nada.
class MonitorDeQuadros {
  MonitorDeQuadros({this.orcamentoMs = 16.67});

  /// 16,67 ms a 60 Hz; 8,33 ms a 120 Hz.
  final double orcamentoMs;

  final List<double> _ui = <double>[];
  final List<double> _raster = <double>[];

  bool _ligado = false;

  void ligar() {
    if (_ligado) return;
    _ligado = true;
    // addTimingsCallback entrega os tempos JÁ MEDIDOS pelo engine —
    // não custa desempenho para medir.
    SchedulerBinding.instance.addTimingsCallback(_aoReceber);
  }

  void desligar() {
    if (!_ligado) return;
    _ligado = false;
    SchedulerBinding.instance.removeTimingsCallback(_aoReceber);
  }

  void limpar() {
    _ui.clear();
    _raster.clear();
  }

  void _aoReceber(List<FrameTiming> tempos) {
    for (final FrameTiming t in tempos) {
      _ui.add(t.buildDuration.inMicroseconds / 1000);
      _raster.add(t.rasterDuration.inMicroseconds / 1000);
    }

    // Mantém só os últimos 300 quadros (~5 s a 60 Hz):
    // sem isso, a lista cresce para sempre — um vazamento
    // dentro do próprio medidor.
    if (_ui.length > 300) {
      _ui.removeRange(0, _ui.length - 300);
      _raster.removeRange(0, _raster.length - 300);
    }
  }

  int get quadros => _ui.length;

  double get mediaUi => _media(_ui);
  double get mediaRaster => _media(_raster);

  /// O percentil 99 importa mais que a média.
  ///
  /// Uma média de 8 ms com um quadro de 300 ms é uma experiência
  /// RUIM — e a média esconde isso. O usuário sente o pico.
  double get p99Ui => _percentil(_ui, 0.99);
  double get p99Raster => _percentil(_raster, 0.99);

  /// Quantos quadros estouraram o orçamento.
  int get perdidosUi => _ui.where((double v) => v > orcamentoMs).length;
  int get perdidosRaster =>
      _raster.where((double v) => v > orcamentoMs).length;

  double get percentualPerdido {
    if (_ui.isEmpty) return 0;
    final int ruins = <int>[perdidosUi, perdidosRaster].reduce(
      (int a, int b) => a > b ? a : b,
    );
    return ruins / _ui.length * 100;
  }

  /// Onde está o problema — a pergunta do passo 3 do método.
  String get diagnostico {
    if (_ui.isEmpty) return 'Sem dados ainda';

    final bool uiRuim = p99Ui > orcamentoMs;
    final bool rasterRuim = p99Raster > orcamentoMs;

    if (uiRuim && rasterRuim) {
      return '🔵🟢 As duas threads estouram — comece pela UI';
    }
    if (uiRuim) {
      return '🔵 UI: build caro, cálculo ou rebuilds demais';
    }
    if (rasterRuim) {
      return '🟢 Raster: sombras, Opacity, clips ou imagem grande';
    }
    return '✅ Dentro do orçamento';
  }

  static double _media(List<double> v) {
    if (v.isEmpty) return 0;
    return v.reduce((double a, double b) => a + b) / v.length;
  }

  static double _percentil(List<double> v, double p) {
    if (v.isEmpty) return 0;
    final List<double> ordenado = List<double>.from(v)..sort();
    final int i = ((ordenado.length - 1) * p).round();
    return ordenado[i];
  }
}
```

E o painel flutuante:

> **Arquivo:** `foco_desempenho/lib/core/perf/painel_perf.dart` (novo)

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'monitor_de_quadros.dart';

/// Painel flutuante com os números do quadro, em cima do app.
///
/// Envolva a tela que você quer medir:
/// ```dart
/// PainelPerf(child: MinhaTela())
/// ```
class PainelPerf extends StatefulWidget {
  const PainelPerf({required this.child, super.key});

  final Widget child;

  @override
  State<PainelPerf> createState() => _PainelPerfState();
}

class _PainelPerfState extends State<PainelPerf> {
  final MonitorDeQuadros _monitor = MonitorDeQuadros();
  Timer? _atualizador;
  bool _visivel = true;

  @override
  void initState() {
    super.initState();
    _monitor.ligar();

    // Atualiza o painel 2× por segundo. Atualizar a cada quadro
    // faria o próprio painel virar fonte de jank.
    _atualizador = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    // Sem estas duas linhas: vazamento, e o teste de widget
    // acusa "A Timer is still pending". Módulo 12, aula 6.
    _atualizador?.cancel();
    _monitor.desligar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,

        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 8,
          child: Material(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => setState(() => _visivel = !_visivel),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _visivel ? _Numeros(monitor: _monitor) : const Icon(
                  Icons.speed,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Numeros extends StatelessWidget {
  const _Numeros({required this.monitor});

  final MonitorDeQuadros monitor;

  @override
  Widget build(BuildContext context) {
    const TextStyle base = TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontFamily: 'monospace',
      fontFamilyFallback: <String>['Courier New', 'monospace'],
    );

    Color cor(double v) => v > monitor.orcamentoMs
        ? Colors.redAccent
        : (v > monitor.orcamentoMs * 0.7 ? Colors.amber : Colors.greenAccent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Em debug, TODO número estoura e não significa nada.
        // O aviso evita a conclusão errada.
        if (kDebugMode)
          const Text(
            '⚠️ DEBUG — números sem valor',
            style: TextStyle(color: Colors.orangeAccent, fontSize: 10),
          ),

        Text('quadros: ${monitor.quadros}', style: base),
        Text(
          'UI     ${monitor.mediaUi.toStringAsFixed(1)} ms',
          style: base.copyWith(color: cor(monitor.mediaUi)),
        ),
        Text(
          'raster ${monitor.mediaRaster.toStringAsFixed(1)} ms',
          style: base.copyWith(color: cor(monitor.mediaRaster)),
        ),
        const SizedBox(height: 4),
        // O p99 é o número que corresponde ao que o usuário SENTE.
        Text(
          'p99 UI     ${monitor.p99Ui.toStringAsFixed(1)} ms',
          style: base.copyWith(color: cor(monitor.p99Ui)),
        ),
        Text(
          'p99 raster ${monitor.p99Raster.toStringAsFixed(1)} ms',
          style: base.copyWith(color: cor(monitor.p99Raster)),
        ),
        const SizedBox(height: 4),
        Text(
          'perdidos: ${monitor.percentualPerdido.toStringAsFixed(1)}%',
          style: base,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 150,
          child: Text(monitor.diagnostico, style: base),
        ),
      ],
    );
  }
}
```

Use assim:

```dart
// lib/main.dart
MaterialApp(
  home: kProfileMode
      ? const PainelPerf(child: JankDemoScreen())
      : const JankDemoScreen(),
)
```

```powershell
flutter run --profile -d <aparelho>
flutter build apk --analyze-size --target-platform android-arm64
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `Perf.medir` com `Timeline.timeSync` | Nomeia o trecho no gráfico do DevTools. Removido em release: custo zero. |
| `finally { tarefa.finish(); }` | Sem isso, uma exceção deixaria a marcação aberta para sempre. |
| `Perf.cronometrar` com sinal `⚠️`/`✅` | Compara com os 16 ms automaticamente — o número sozinho não diz nada. |
| `addTimingsCallback` | Entrega tempos **já medidos** pelo engine: medir não custa desempenho. |
| `removeRange` acima de 300 quadros | Sem isso, a lista cresce para sempre — vazamento dentro do medidor. |
| **`p99`** além da média | Média de 8 ms com um pico de 300 ms é ruim; a média esconde, o p99 mostra. |
| `diagnostico` por cor | Automatiza o passo 3: UI ou raster? |
| `Timer.periodic(500ms)` no painel | Atualizar a cada quadro faria o painel virar fonte de jank. |
| `_atualizador?.cancel()` + `desligar()` | Vazamento e Timer pendente no teste sem isso. |
| Aviso `kDebugMode` no painel | Em debug todo número estoura; o aviso evita a conclusão errada. |
| `Opacity(opacity: 0.99)` no exemplo | Força `saveLayer` — o efeito mais caro do Flutter. |
| Três `BoxShadow` com blur alto | Custo de raster puro: nenhum Dart envolvido. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Profile | `flutter run --profile` | idem, **no macOS** |
| Taxa de quadros | 60/90/120 Hz | 60 Hz; 120 nos Pro |
| Ferramenta nativa | Perfetto, GPU rendering | Instruments, Metal Debugger |
| Renderizador | Impeller (padrão) | Impeller |
| Primeiro quadro lento | Comum em aparelho fraco | Menos comum |
| Medir sem Mac | ✅ | ❌ |

> 💡 **O "jank do primeiro quadro"** (*shader compilation jank*) era um problema clássico do
> Flutter: a primeira vez que uma animação aparecia, ela engasgava enquanto os shaders eram
> compilados. O **Impeller**, hoje padrão nas duas plataformas, compila os shaders antecipadamente
> e praticamente eliminou isso. Se você encontrar material antigo falando de
> `--cache-sksl`/`--bundle-sksl-path`, saiba que **não se aplica mais** ao Impeller.

🪟 **No Windows**, você mede Android completo. Para iOS, só via CI com runner macOS — e sem acesso
interativo ao DevTools durante a execução (Módulo 12, aula 9).

---

## ⚠️ Erros comuns

### 1. Medir em debug

Cinco a dez vezes mais lento; conclusões inválidas.

**Correção:** `--profile`, sempre.

### 2. Medir no emulador

CPU e GPU do PC.

**Correção:** aparelho físico.

### 3. Ignorar a cor da barra

Otimizar `build` quando o problema é raster não muda nada.

**Correção:** passo 3 antes de tudo.

### 4. Olhar só a média

Média de 8 ms com pico de 300 ms é experiência ruim.

**Correção:** olhe o **p99**.

### 5. Mudar cinco coisas de uma vez

Você não sabe qual funcionou.

**Correção:** uma mudança, uma medição.

### 6. Não anotar o número de antes

"Ficou mais rápido" não é medição.

**Correção:** anote; compare números.

### 7. Otimizar sem medir

Tempo gasto onde não havia problema.

**Correção:** meça primeiro.

### 8. `Opacity` para esconder widget

Força `saveLayer`.

**Correção:** `Visibility`, ou não construir.

### 9. Esquecer `showPerformanceOverlay: true` ligado

Vai para produção com o gráfico na tela.

**Correção:** `kProfileMode`.

### 10. Painel de medição sem `dispose`

Vazamento e Timer pendente.

**Correção:** `cancel` e `desligar`.

### 11. Ignorar o tamanho do app

40 MB afastam usuário.

**Correção:** `--analyze-size` e AAB.

### 12. Procurar shader jank hoje

O Impeller resolveu isso.

**Correção:** meça antes de aplicar receita antiga.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `jank_demo_screen.dart` em **debug**. Anote a sensação nas três abas.

**Passo 2.** Rode em `--profile` num aparelho. Mudou?

**Passo 3.** Abra o DevTools → Performance. Role a aba ✅ e anote UI e raster.

**Passo 4.** Role a aba 🔵. Qual barra estoura? Anote os números.

**Passo 5.** Role a aba 🟢. E agora?

**Passo 6.** Na aba 🔵, procure "calculo no build" no gráfico. Quanto tempo?

**Passo 7.** Tire o `Opacity` da aba 🟢. Meça de novo. Quanto melhorou?

**Passo 8.** Reduza de três sombras para uma. Meça. Qual mudança rendeu mais?

**Passo 9.** Ligue `debugRepaintRainbowEnabled` e abra uma tela parada. Algo pisca?

**Passo 10.** Rode `flutter build apk --analyze-size`. O que ocupa mais espaço?

---

## 📝 Exercícios independentes

→ Exercícios completos em
[exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md)

Faça os de **Diagnóstico** (identificar UI × raster a partir de um gráfico) e o de **Aplicação**
(medir, corrigir, medir de novo).

---

## 🏆 Desafio opcional

Monte um **teste de desempenho automatizado** que falha se o app piorar.

Requisitos:

- Um teste de integração (Módulo 12, aula 8) que rola uma lista de 500 itens.
- `binding.watchPerformance` para coletar as métricas durante a rolagem.
- O teste **falha** se o p99 da UI passar de 16 ms.
- Um arquivo de referência versionado com os números aceitáveis.
- Rodar no CI, num emulador, e publicar o relatório.

Depois responda: por que um teste de desempenho no CI é **menos confiável** que um teste funcional?
Como você reduziria os falsos positivos sem tornar o teste inútil? (Dica: pense em variação entre
execuções e no que significa comparar números de máquinas diferentes.)

---

## 📌 Resumo

- **Nunca meça em debug**: é 5 a 10× mais lento. Use **`--profile`**, num **aparelho físico**.
- O emulador usa a CPU e a GPU do PC — não representa o celular do usuário.
- Cada barra do gráfico é um quadro; a linha é o orçamento de **16,67 ms**.
- **🔵 UI = seu Dart. 🟢 Raster = pintura na GPU.** A cor decide toda a correção.
- UI alta: `build` caro, rebuilds, cálculo, JSON. Raster alta: sombras, `Opacity`, clips, blur.
- **`Opacity` e `ClipPath` forçam `saveLayer`** — o efeito mais caro do Flutter.
- `showPerformanceOverlay`, `debugPaintSizeEnabled`, **repaint rainbow** medem sem o DevTools.
- **`Timeline.timeSync`** nomeia trechos do seu código no gráfico; some em release.
- **O p99 importa mais que a média**: um pico de 300 ms é sentido, a média esconde.
- `--analyze-size` mostra o que ocupa espaço; **AAB** corta 30–40 % do download.
- Método: reproduzir → profile → **cor da barra** → achar o culpado → **uma mudança** → medir.
- **Anote o número de antes.** "Ficou mais rápido" não é medição.
- O **Impeller** eliminou o shader jank: receitas antigas com `--cache-sksl` não se aplicam mais.

---

## ☑️ Checklist de domínio

- [ ] Rodo em `--profile` para medir.
- [ ] Meço em aparelho físico.
- [ ] Leio o gráfico de frames e identifico quadros perdidos.
- [ ] Distingo barra azul de verde e sei o que cada uma significa.
- [ ] Sei o que pesa na UI e o que pesa no raster.
- [ ] Uso `Timeline.timeSync` para marcar meu código.
- [ ] Olho o p99, não só a média.
- [ ] Uso o repaint rainbow para achar repintura à toa.
- [ ] Mudo uma coisa por vez e meço de novo.
- [ ] Anoto o número de antes.
- [ ] Sei usar `--analyze-size`.
- [ ] Não deixo overlay de medição em produção.

---

## 📚 Referências oficiais

- [Flutter performance profiling — docs.flutter.dev](https://docs.flutter.dev/perf/ui-performance)
- [Using the Performance view — docs.flutter.dev](https://docs.flutter.dev/tools/devtools/performance)
- [Flutter build modes — docs.flutter.dev](https://docs.flutter.dev/testing/build-modes)
- [Timeline class — api.dart.dev](https://api.dart.dev/stable/dart-developer/Timeline-class.html)
- [FrameTiming — api.flutter.dev](https://api.flutter.dev/flutter/dart-ui/FrameTiming-class.html)
- [Measuring your app's size — docs.flutter.dev](https://docs.flutter.dev/perf/app-size)
- [Impeller rendering engine — docs.flutter.dev](https://docs.flutter.dev/perf/impeller)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Assíncrono sem travar](03-assincrono-sem-travar.md) | [README](README.md) | [Aula 5 — Acessibilidade](05-acessibilidade.md) |
