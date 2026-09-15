# Aula 5 — Conectividade

> **Módulo:** 11 - Recursos Nativos · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que **`connectivity_plus` não garante internet** — e o que ele realmente diz.
- Usar `checkConnectivity` e `onConnectivityChanged` corretamente.
- Reconhecer o **portal cativo** e outras situações de "conectado sem internet".
- Fazer uma **verificação real** de internet, com timeout e sem custo excessivo.
- Modelar o estado de rede com um **`StreamProvider`** do Riverpod.
- Montar um **banner de offline** que informa sem atrapalhar.
- Decidir quando **tentar mesmo assim** e quando **avisar antes**.

## ✅ Pré-requisitos

- [Módulo 09, aula 6 — Timeout, retry e cancelamento](../09-consumo-de-api/06-timeout-retry-cancelamento.md)
  — timeout e o tratamento de `SocketException`.
- [Módulo 10, aula 8 — Cache e offline](../10-persistencia-de-dados/08-cache-e-offline.md) —
  **essencial**: a regra "nunca decida com base em conectividade" nasceu lá; aqui ela é explicada
  por inteiro.
- [Módulo 08, aula 5 — Riverpod: primeiros passos](../08-estado-e-arquitetura/05-riverpod-primeiros-passos.md)
  — `StreamProvider`, `ref.watch`.
- [Módulo 04, aula 3 — Streams](../04-dart-avancado/03-streams.md).

---

## 📖 Conceito

### O que `connectivity_plus` realmente diz

```dart
final List<ConnectivityResult> resultado =
    await Connectivity().checkConnectivity();
```

Os valores possíveis:

| Valor | Significado |
|---|---|
| `wifi` | Conectado a uma rede Wi-Fi |
| `mobile` | Conectado por dados móveis |
| `ethernet` | Cabo (desktop, alguns tablets) |
| `vpn` | Túnel VPN ativo |
| `bluetooth` | Compartilhamento por Bluetooth |
| `other` | Outra interface |
| `none` | **Nenhuma** interface ativa |

E a frase que resume a aula:

> **`connectivity_plus` responde "existe uma interface de rede ativa?" — não "existe internet?"**

A diferença não é acadêmica. Estas situações reportam `wifi` e **não têm internet**:

| Situação | O que acontece |
|---|---|
| **Portal cativo** (hotel, aeroporto, café) | Wi-Fi conectado, todo tráfego redirecionado para uma página de login |
| Roteador ligado sem link | Wi-Fi conectado, a operadora caiu |
| Franquia de dados esgotada | `mobile` ativo, tráfego bloqueado |
| Rede corporativa com firewall | Conectado, o seu domínio está bloqueado |
| DNS quebrado | Conectado, nenhum nome resolve |
| VPN conectada a servidor fora do ar | `vpn` ativo, nada passa |

E o contrário também acontece, embora seja mais raro: o `checkConnectivity` retorna `none` durante
uma transição (Wi-Fi caindo, dados assumindo) e, um segundo depois, tudo funciona.

### A regra que decorre disso

> **Nunca use a conectividade para decidir SE você tenta a requisição.**

```dart
// ❌ ERRADO
if (resultado.contains(ConnectivityResult.none)) {
  return 'Sem internet';
}
final dados = await api.buscar();
```

Isso produz dois bugs opostos:

1. **Falso negativo:** o app diz "sem internet" numa transição momentânea, quando a requisição
   funcionaria.
2. **Falso positivo:** o app tenta a requisição num portal cativo, e o usuário recebe um erro
   genérico de servidor — quando o problema era o Wi-Fi do hotel.

```dart
// ✅ CERTO: tenta sempre; a conectividade EXPLICA a falha
try {
  return await api.buscar();
} on SocketException {
  final bool semInterface = await _semInterface();
  throw semInterface
      ? const FalhaSemConexao()        // "verifique sua internet"
      : const FalhaDeServidor();       // "o servidor está com problema"
}
```

Os três usos **legítimos** do `connectivity_plus`:

| Uso | Por quê |
|---|---|
| **Explicar** uma falha já ocorrida | "Sem conexão" é mais útil que "erro desconhecido" |
| **Disparar** sincronização quando a rede volta | O momento certo para tentar de novo |
| **Mostrar** um indicador de estado | O usuário entende por que está vendo dado antigo |

### Verificação real de internet

Quando você precisa mesmo saber se há internet — antes de um upload grande, por exemplo —, a única
resposta confiável é **tentar**:

```dart
Future<bool> temInternetDeVerdade() async {
  try {
    final List<InternetAddress> resultado =
        await InternetAddress.lookup('one.one.one.one')
            .timeout(const Duration(seconds: 3));
    return resultado.isNotEmpty && resultado.first.rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } on TimeoutException {
    return false;
  }
}
```

Três decisões nesse código:

**1. Por que um DNS lookup, e não um `GET`?** É a verificação mais barata: poucos bytes, sem TLS,
sem corpo de resposta.

**2. Por que `one.one.one.one` (Cloudflare)?** Um domínio estável, global, com alta
disponibilidade. Evite `google.com`: é bloqueado em alguns países e redes corporativas.

**3. Por que timeout de 3 segundos?** Sem ele, num portal cativo o lookup pode ficar pendurado até
o timeout do sistema.

> ⚠️ **Nem isso é infalível.** Um portal cativo pode **responder** ao DNS (redirecionando tudo para
> o próprio servidor) e o lookup dá certo. A verificação realmente definitiva é bater no **seu
> próprio servidor** e conferir a resposta:
>
> ```dart
> final r = await cliente.get(Uri.parse('$base/health')).timeout(prazo);
> return r.statusCode == 200 && r.body.contains('ok');
> ```

**E quando usar isso?** Quase nunca. Gastar uma requisição para descobrir se a próxima vai
funcionar é desperdício — a própria requisição já responde. Reserve a verificação explícita para:

- antes de um **upload longo**, para não perder o trabalho no meio;
- antes de uma operação **irreversível**;
- numa tela de **diagnóstico** ("testar conexão").

### O estado de rede no Riverpod

```dart
final StreamProvider<EstadoDeRede> estadoDeRedeProvider =
    StreamProvider<EstadoDeRede>((Ref ref) async* {
  final Connectivity c = Connectivity();

  // O primeiro valor: o stream só emite quando MUDA. Sem isto, a tela
  // ficaria em AsyncLoading até a primeira mudança de rede — que pode
  // não acontecer nunca.
  yield _classificar(await c.checkConnectivity());

  yield* c.onConnectivityChanged.map(_classificar);
});
```

Dois pontos:

**1. O `yield` inicial é obrigatório.** `onConnectivityChanged` só emite em **mudanças**. Se o
usuário abrir o app com Wi-Fi e não mexer em nada, o stream nunca emite — e a tela fica carregando
para sempre.

**2. O stream emite mais do que você espera.** Trocar de rede Wi-Fi, ativar VPN, alternar entre
Wi-Fi e dados: cada evento emite. Se você disparar uma ação a cada emissão, vai disparar demais.

### O banner de offline

O indicador precisa informar **sem atrapalhar**:

| ❌ Ruim | ✅ Bom |
|---|---|
| Diálogo modal bloqueando a tela | Faixa discreta no topo |
| "ERRO: SEM CONEXÃO" em vermelho | "Sem conexão · mostrando dados salvos" |
| Aparece e some a cada oscilação | Espera 2 s antes de aparecer |
| Some sem avisar que voltou | "Conectado" por 2 s e some |
| Impede o uso do app | O app continua funcionando com cache |

O detalhe do **atraso** merece explicação: redes móveis oscilam. Um banner que pisca a cada
segundo é pior que banner nenhum. Espere ~2 segundos de estado estável antes de mostrar.

---

## 💡 Analogia

Pense em pegar o carro para ir ao mercado.

- **`connectivity_plus`** é **olhar pela janela e ver que a rua está aberta**. Informação útil — e
  que **não diz** se o mercado está funcionando. Ele pode estar em greve, sem energia, ou fechado
  para reforma.
- **O portal cativo** é a rua aberta com um **pedágio no meio**: você sai de casa, anda dois
  quarteirões, e é parado por uma cancela que exige cadastro. Da janela, a rua parecia livre.
- **"Nunca decida se tenta com base na conectividade"** é: não deixe de sair de casa porque **acha**
  que o mercado está fechado. Vá. Se estiver fechado, você descobre na porta — e aí a informação
  "a rua está aberta" te ajuda a concluir que o problema é o **mercado**, não o seu carro.
- **A verificação real** é ligar para o mercado antes de sair. Faz sentido antes de uma viagem de
  uma hora (o upload grande); não faz sentido antes de atravessar a rua.
- **Ligar para o mercado e alguém atender** ainda não garante nada: pode ser a gravação automática
  (o portal cativo respondendo ao DNS). A prova definitiva é perguntar algo que **só o mercado
  aberto** responderia — o endpoint `/health` do seu próprio servidor.
- **O banner** é a placa "trânsito lento" no painel do carro. Ela informa; ela não trava o volante.
  E não fica piscando a cada buraco.

---

## 🧪 Exemplo mínimo

Conectividade, verificação real e a diferença entre as duas, visíveis lado a lado.

> **Arquivo:** `foco_nativo/lib/main.dart` (temporário)
> **Instale antes:** `flutter pub add connectivity_plus`
> **Como executar:** `flutter run -d windows` (ou em emulador)

```dart
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AppConectividade());

class AppConectividade extends StatelessWidget {
  const AppConectividade({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaConectividade(),
    );
  }
}

class TelaConectividade extends StatefulWidget {
  const TelaConectividade({super.key});

  @override
  State<TelaConectividade> createState() => _TelaConectividadeState();
}

class _TelaConectividadeState extends State<TelaConectividade> {
  final Connectivity _conectividade = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _inscricao;

  List<ConnectivityResult> _interfaces = <ConnectivityResult>[];
  final List<String> _log = <String>[];

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    // Toda StreamSubscription precisa ser cancelada. Sem isto, o
    // callback continua rodando depois de a tela morrer.
    _inscricao?.cancel();
    super.dispose();
  }

  Future<void> _iniciar() async {
    // O estado ATUAL. O stream abaixo só emite em MUDANÇAS — sem esta
    // leitura, a tela ficaria vazia até o usuário mexer no Wi-Fi.
    final List<ConnectivityResult> agora =
        await _conectividade.checkConnectivity();
    if (!mounted) return;
    setState(() => _interfaces = agora);
    _registrar('estado inicial: ${_descrever(agora)}');

    _inscricao = _conectividade.onConnectivityChanged.listen(
      (List<ConnectivityResult> resultado) {
        if (!mounted) return;
        setState(() => _interfaces = resultado);
        _registrar('mudou para: ${_descrever(resultado)}');
      },
    );
  }

  void _registrar(String linha) {
    debugPrint(linha);
    if (mounted) setState(() => _log.insert(0, linha));
  }

  String _descrever(List<ConnectivityResult> r) {
    if (r.isEmpty || r.every((ConnectivityResult x) => x == ConnectivityResult.none)) {
      return 'nenhuma interface';
    }
    return r.map((ConnectivityResult x) => x.name).join(' + ');
  }

  bool get _temInterface =>
      _interfaces.isNotEmpty &&
      !_interfaces.every((ConnectivityResult r) => r == ConnectivityResult.none);

  // ── Verificação real ─────────────────────────────────────────────────────

  /// Verifica se há internet DE VERDADE, com um DNS lookup.
  ///
  /// Mais barato que um GET: poucos bytes, sem TLS, sem corpo.
  /// `one.one.one.one` (Cloudflare) é estável e global — evite
  /// `google.com`, bloqueado em alguns países e redes corporativas.
  Future<bool> _temInternetDeVerdade() async {
    try {
      final List<InternetAddress> r =
          await InternetAddress.lookup('one.one.one.one')
              // Sem timeout, num portal cativo o lookup fica pendurado
              // até o prazo do sistema — mais de um minuto.
              .timeout(const Duration(seconds: 3));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> _compararOsDois() async {
    _registrar('— comparando interface × internet real —');

    final List<ConnectivityResult> interfaces =
        await _conectividade.checkConnectivity();
    final bool interface = !interfaces.every(
      (ConnectivityResult r) => r == ConnectivityResult.none,
    );
    _registrar('1. connectivity_plus: ${interface ? "conectado" : "sem rede"}');

    final Stopwatch relogio = Stopwatch()..start();
    final bool internet = await _temInternetDeVerdade();
    relogio.stop();
    _registrar('2. DNS lookup: ${internet ? "há internet" : "sem internet"} '
        '(${relogio.elapsedMilliseconds} ms)');

    if (interface && !internet) {
      _registrar('⚠️ CONECTADO SEM INTERNET');
      _registrar('   portal cativo, franquia esgotada ou DNS quebrado');
    } else if (!interface && internet) {
      _registrar('🤔 sem interface mas com internet — transição momentânea');
    } else {
      _registrar('✅ os dois concordam');
    }
  }

  /// O jeito CERTO: tenta sempre; a conectividade só explica a falha.
  Future<void> _requisicaoCerta() async {
    _registrar('— tentando a requisição SEM checar conectividade antes —');

    try {
      final HttpClient cliente = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      final HttpClientRequest req = await cliente
          .getUrl(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));
      final HttpClientResponse resposta = await req.close();
      cliente.close();

      _registrar('✅ funcionou (HTTP ${resposta.statusCode})');
    } on SocketException {
      // A conectividade entra AQUI, para explicar — não antes, para decidir.
      final bool interface = _temInterface;
      _registrar(interface
          ? '❌ falhou COM interface ativa → portal cativo ou servidor fora'
          : '❌ falhou SEM interface → sem conexão');
    } on TimeoutException {
      _registrar('⏱️ demorou demais');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conectividade')),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            color: _temInterface
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.orange.withValues(alpha: 0.20),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Icon(_temInterface ? Icons.wifi : Icons.wifi_off, size: 32),
                const SizedBox(height: 8),
                Text(_descrever(_interfaces)),
                const SizedBox(height: 4),
                const Text(
                  'Isto é a INTERFACE, não a internet',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: _compararOsDois,
                  child: const Text('Comparar'),
                ),
                FilledButton.tonal(
                  onPressed: _requisicaoCerta,
                  child: const Text('Requisição'),
                ),
                TextButton(
                  onPressed: () => setState(_log.clear),
                  child: const Text('Limpar'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (BuildContext c, int i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Text(
                  _log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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

**O roteiro:**

1. **Comparar** com internet normal → os dois concordam.
2. Desligue o Wi-Fi e os dados → o banner muda, o log registra a mudança.
3. **Comparar** offline → os dois concordam de novo.
4. **O teste que ensina a aula:** conecte-se a um Wi-Fi com **portal cativo** (a rede aberta de um
   café ou shopping, antes de fazer login) e aperte **Comparar**. O `connectivity_plus` diz
   "conectado" e o lookup diz "sem internet" — exatamente o cenário que quebra apps que decidem pela
   conectividade.

---

## 📱 Aplicando no Flutter

O `foco_nativo` ganha:

- `EstadoDeRede` — o modelo, com verificação real opcional;
- `estadoDeRedeProvider` — `StreamProvider` com o valor inicial;
- `BannerDeRede` — faixa discreta, com atraso contra oscilação;
- integração com o repositório: conectividade **explica**, nunca decide.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/lib/core/rede/estado_de_rede.dart` (novo)
> **Como executar:** `flutter run`

```dart
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de rede do aparelho.
///
/// ⚠️ Leia com atenção: `comInterface` NÃO significa "com internet".
/// Significa que existe uma interface de rede ativa.
///
/// Situações reais em que há interface e não há internet:
///  - portal cativo (hotel, aeroporto, café);
///  - roteador ligado, operadora caída;
///  - franquia de dados esgotada;
///  - firewall corporativo bloqueando o domínio;
///  - DNS quebrado.
enum EstadoDeRede {
  /// Nenhuma interface ativa. Aqui a certeza é alta: não há internet.
  semInterface,

  /// Há interface. A internet é PROVÁVEL, não certa.
  comInterface,

  /// Verificado de verdade: há internet. Só aparece quando alguém
  /// pede `verificarDeVerdade`.
  comInternetConfirmada;

  bool get provavelmenteOnline => this != EstadoDeRede.semInterface;

  /// Só `semInterface` dá certeza. Com interface, a ausência de
  /// internet é possível — e é por isso que não decidimos com base nisso.
  bool get certamenteOffline => this == EstadoDeRede.semInterface;
}

/// Tipo de interface, para o texto do banner.
enum TipoDeConexao {
  wifi('Wi-Fi'),
  movel('dados móveis'),
  cabo('cabo'),
  vpn('VPN'),
  outra('rede'),
  nenhuma('sem rede');

  const TipoDeConexao(this.rotulo);
  final String rotulo;
}

class LeituraDeRede {
  const LeituraDeRede({required this.estado, required this.tipo});

  final EstadoDeRede estado;
  final TipoDeConexao tipo;

  bool get online => estado.provavelmenteOnline;
}

class ObservadorDeRede {
  ObservadorDeRede([Connectivity? conectividade])
      : _conectividade = conectividade ?? Connectivity();

  final Connectivity _conectividade;

  /// Estado atual, a partir das interfaces.
  Future<LeituraDeRede> atual() async {
    return _classificar(await _conectividade.checkConnectivity());
  }

  /// Emite a cada mudança.
  ///
  /// ⚠️ Emite MAIS do que se espera: trocar de rede Wi-Fi, ativar VPN,
  /// alternar entre Wi-Fi e dados. Não dispare ação a cada emissão
  /// sem filtrar.
  Stream<LeituraDeRede> observar() => _conectividade.onConnectivityChanged
      .map(_classificar)
      // distinct evita emissões repetidas com o mesmo valor, que
      // acontecem em transições de rede.
      .distinct((LeituraDeRede a, LeituraDeRede b) =>
          a.estado == b.estado && a.tipo == b.tipo);

  /// Verifica se há internet DE VERDADE.
  ///
  /// Use com parcimônia: gastar uma requisição para descobrir se a
  /// próxima vai funcionar é desperdício — a própria requisição já
  /// responde. Reserve para: antes de upload longo, antes de operação
  /// irreversível, ou numa tela de diagnóstico.
  Future<bool> verificarDeVerdade({
    Duration prazo = const Duration(seconds: 3),
    String host = 'one.one.one.one',
  }) async {
    try {
      // DNS lookup: mais barato que um GET — poucos bytes, sem TLS.
      // one.one.one.one (Cloudflare) é estável e global; evite
      // google.com, bloqueado em alguns países e redes corporativas.
      final List<InternetAddress> resultado =
          await InternetAddress.lookup(host).timeout(prazo);
      return resultado.isNotEmpty && resultado.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      // Sem o timeout, num portal cativo o lookup ficaria pendurado
      // por mais de um minuto.
      return false;
    } on Object catch (e) {
      debugPrint('Verificação de rede falhou: ${e.runtimeType}');
      return false;
    }
  }

  LeituraDeRede _classificar(List<ConnectivityResult> resultado) {
    // A lista pode ter mais de um item: Wi-Fi + VPN, por exemplo.
    final bool nenhuma = resultado.isEmpty ||
        resultado.every((ConnectivityResult r) => r == ConnectivityResult.none);

    if (nenhuma) {
      return const LeituraDeRede(
        estado: EstadoDeRede.semInterface,
        tipo: TipoDeConexao.nenhuma,
      );
    }

    // Ordem de prioridade para o rótulo: VPN é o mais informativo
    // (pode explicar lentidão), depois Wi-Fi, depois móvel.
    final TipoDeConexao tipo = switch (resultado) {
      _ when resultado.contains(ConnectivityResult.vpn) => TipoDeConexao.vpn,
      _ when resultado.contains(ConnectivityResult.wifi) => TipoDeConexao.wifi,
      _ when resultado.contains(ConnectivityResult.mobile) =>
        TipoDeConexao.movel,
      _ when resultado.contains(ConnectivityResult.ethernet) =>
        TipoDeConexao.cabo,
      _ => TipoDeConexao.outra,
    };

    return LeituraDeRede(estado: EstadoDeRede.comInterface, tipo: tipo);
  }
}

final Provider<ObservadorDeRede> observadorDeRedeProvider =
    Provider<ObservadorDeRede>((Ref ref) => ObservadorDeRede());

/// Estado de rede, para a interface.
///
/// O `yield` inicial é OBRIGATÓRIO: `onConnectivityChanged` só emite em
/// MUDANÇAS. Sem ele, um usuário que abre o app com Wi-Fi e não mexe em
/// nada ficaria em AsyncLoading para sempre.
final StreamProvider<LeituraDeRede> estadoDeRedeProvider =
    StreamProvider<LeituraDeRede>((Ref ref) async* {
  final ObservadorDeRede observador = ref.watch(observadorDeRedeProvider);

  yield await observador.atual();
  yield* observador.observar();
});

/// Atalho booleano, para quem só precisa de sim/não.
final Provider<bool> estaOfflineProvider = Provider<bool>((Ref ref) {
  // Enquanto carrega, assume ONLINE. Assumir offline faria o app
  // mostrar o banner por um instante a cada abertura.
  return ref.watch(estadoDeRedeProvider).maybeWhen(
        data: (LeituraDeRede r) => r.estado.certamenteOffline,
        orElse: () => false,
      );
});
```

> **Arquivo:** `foco_nativo/lib/core/rede/banner_de_rede.dart` (novo)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_nativo/core/rede/estado_de_rede.dart';

/// Faixa de aviso de rede.
///
/// Envolve a tela inteira e aparece no topo quando a conexão cai.
///
/// Decisões de experiência:
///  - faixa discreta, nunca diálogo modal: o app continua usável;
///  - espera 2 s antes de aparecer, porque rede móvel oscila e um
///    banner piscando é pior que banner nenhum;
///  - mostra "conectado" por 2 s ao voltar, e some.
class BannerDeRede extends ConsumerStatefulWidget {
  const BannerDeRede({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BannerDeRede> createState() => _BannerDeRedeState();
}

class _BannerDeRedeState extends ConsumerState<BannerDeRede> {
  Timer? _atraso;
  bool _mostrandoOffline = false;
  bool _mostrandoVoltou = false;

  @override
  void dispose() {
    _atraso?.cancel();
    super.dispose();
  }

  void _aoMudar(LeituraDeRede? antes, LeituraDeRede agora) {
    _atraso?.cancel();

    final bool caiu = agora.estado.certamenteOffline;
    final bool voltou = antes?.estado.certamenteOffline == true && !caiu;

    if (caiu) {
      // 2 s de estado estável antes de mostrar. Redes móveis oscilam:
      // sem este atraso, o banner pisca a cada buraco de sinal.
      _atraso = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _mostrandoOffline = true);
      });
      return;
    }

    setState(() => _mostrandoOffline = false);

    if (voltou) {
      // Avisa que voltou — e some sozinho. Sem isto, o usuário não
      // sabe se pode tentar de novo.
      setState(() => _mostrandoVoltou = true);
      _atraso = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _mostrandoVoltou = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // listen, não watch: reagimos à mudança sem reconstruir o filho.
    ref.listen<AsyncValue<LeituraDeRede>>(estadoDeRedeProvider,
        (AsyncValue<LeituraDeRede>? antes, AsyncValue<LeituraDeRede> agora) {
      final LeituraDeRede? atual = agora.value;
      if (atual != null) _aoMudar(antes?.value, atual);
    });

    final ColorScheme cores = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        // AnimatedSize evita o salto brusco do conteúdo quando a
        // faixa aparece e some.
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _mostrandoOffline
              ? _Faixa(
                  cor: cores.errorContainer,
                  corDoTexto: cores.onErrorContainer,
                  icone: Icons.cloud_off_outlined,
                  // Texto que diz o que ESTÁ acontecendo, não só
                  // que deu errado.
                  texto: 'Sem conexão · mostrando dados salvos',
                )
              : _mostrandoVoltou
                  ? _Faixa(
                      cor: cores.tertiaryContainer,
                      corDoTexto: cores.onTertiaryContainer,
                      icone: Icons.cloud_done_outlined,
                      texto: 'Conectado',
                    )
                  : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _Faixa extends StatelessWidget {
  const _Faixa({
    required this.cor,
    required this.corDoTexto,
    required this.icone,
    required this.texto,
  });

  final Color cor;
  final Color corDoTexto;
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cor,
      child: SafeArea(
        // A faixa fica ABAIXO da barra de status, não sob ela.
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(icone, size: 18, color: corDoTexto),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(color: corDoTexto, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> **Arquivo:** `foco_nativo/lib/core/rede/diagnostico_de_rede.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_nativo/core/rede/estado_de_rede.dart';

/// Tela de diagnóstico.
///
/// Este é um dos poucos lugares em que a verificação REAL de internet
/// se justifica: o usuário pediu explicitamente para testar.
class DiagnosticoDeRede extends ConsumerStatefulWidget {
  const DiagnosticoDeRede({super.key});

  @override
  ConsumerState<DiagnosticoDeRede> createState() => _DiagnosticoDeRedeState();
}

class _DiagnosticoDeRedeState extends ConsumerState<DiagnosticoDeRede> {
  bool _testando = false;
  bool? _resultado;
  int? _duracaoMs;

  Future<void> _testar() async {
    setState(() {
      _testando = true;
      _resultado = null;
    });

    final Stopwatch relogio = Stopwatch()..start();
    final bool ok =
        await ref.read(observadorDeRedeProvider).verificarDeVerdade();
    relogio.stop();

    if (!mounted) return;
    setState(() {
      _testando = false;
      _resultado = ok;
      _duracaoMs = relogio.elapsedMilliseconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<LeituraDeRede> rede = ref.watch(estadoDeRedeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico de rede')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(
                rede.value?.online ?? false ? Icons.wifi : Icons.wifi_off,
              ),
              title: const Text('Interface de rede'),
              subtitle: Text(
                rede.when(
                  data: (LeituraDeRede r) => r.estado.certamenteOffline
                      ? 'Nenhuma interface ativa'
                      : 'Conectado por ${r.tipo.rotulo}',
                  loading: () => 'Verificando…',
                  error: (Object e, StackTrace s) => 'Não foi possível verificar',
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              // O usuário precisa entender POR QUE "conectado" pode
              // não significar "com internet".
              'Estar conectado a uma rede não garante acesso à internet. '
              'Redes de hotéis, aeroportos e cafés costumam exigir login '
              'em uma página antes de liberar o acesso.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: _resultado == null
                      ? const Icon(Icons.help_outline)
                      : Icon(
                          _resultado! ? Icons.check_circle : Icons.cancel,
                          color: _resultado!
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.error,
                        ),
                  title: const Text('Acesso à internet'),
                  subtitle: Text(
                    _resultado == null
                        ? 'Não testado'
                        : _resultado!
                            ? 'Funcionando (${_duracaoMs} ms)'
                            : 'Sem acesso — verifique se a rede exige login',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: FilledButton.icon(
                    onPressed: _testando ? null : _testar,
                    icon: _testando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check),
                    label: Text(_testando ? 'Testando…' : 'Testar conexão'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

> **Arquivo:** `foco_nativo/lib/features/trilhas/data/trilha_repositorio.dart` (o uso correto)

```dart
  /// Busca trilhas.
  ///
  /// Repare no que NÃO existe aqui: nenhuma checagem de conectividade
  /// ANTES da requisição. Tentamos sempre.
  ///
  /// Checar antes produziria dois bugs opostos:
  ///  - falso negativo: "sem internet" numa transição momentânea,
  ///    quando a requisição funcionaria;
  ///  - falso positivo: tentar num portal cativo e devolver "erro de
  ///    servidor", quando o problema era o Wi-Fi do hotel.
  Future<List<Trilha>> listar() async {
    try {
      return await _api.listar();
    } on SocketException catch (erro, pilha) {
      // A conectividade entra AQUI — para EXPLICAR a falha,
      // não para ter decidido se tentávamos.
      final LeituraDeRede rede = await _rede.atual();

      Error.throwWithStackTrace(
        rede.estado.certamenteOffline
            ? const FalhaSemConexao()
            // Com interface e sem resposta: portal cativo, firewall
            // ou servidor fora. A mensagem precisa cobrir os três.
            : const FalhaDeConexaoIncerta(),
        pilha,
      );
    } on TimeoutException catch (erro, pilha) {
      Error.throwWithStackTrace(const FalhaDeTempoEsgotado(), pilha);
    }
  }
}

class FalhaSemConexao implements Exception {
  const FalhaSemConexao();
  @override
  String toString() => 'Sem conexão. Verifique sua internet e tente de novo.';
}

/// Há interface, mas a requisição falhou.
///
/// A mensagem precisa cobrir as três causas possíveis: portal cativo,
/// firewall e servidor fora — porque o app não tem como distingui-las.
class FalhaDeConexaoIncerta implements Exception {
  const FalhaDeConexaoIncerta();
  @override
  String toString() =>
      'Não conseguimos acessar o servidor. Se você está numa rede '
      'pública, pode ser necessário fazer login nela.';
}

class FalhaDeTempoEsgotado implements Exception {
  const FalhaDeTempoEsgotado();
  @override
  String toString() => 'A conexão demorou demais. Tente de novo.';
}
```

E no `app.dart`, o banner envolve a tela:

```dart
MaterialApp(
  builder: (BuildContext context, Widget? child) {
    // Envolve TODAS as telas: o aviso de rede não é de uma tela só.
    return BannerDeRede(child: child ?? const SizedBox.shrink());
  },
  home: const HomeScreen(),
)
```

Rode:

```powershell
flutter pub add connectivity_plus
flutter analyze
flutter run
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `enum EstadoDeRede` com `comInterface` (não "online") | O nome é honesto: interface ativa não é internet. |
| `certamenteOffline` só para `semInterface` | Só a ausência de interface dá certeza. É por isso que não decidimos com base na presença. |
| `.distinct(...)` no stream | Transições de rede emitem valores repetidos. Sem filtrar, você dispara ações demais. |
| `yield await observador.atual()` **antes** do `yield*` | `onConnectivityChanged` só emite em **mudanças**. Sem isto, quem abre o app e não mexe no Wi-Fi fica em `AsyncLoading` para sempre. |
| `InternetAddress.lookup` em vez de `GET` | Mais barato: poucos bytes, sem TLS, sem corpo. |
| `one.one.one.one` em vez de `google.com` | Estável e global; `google.com` é bloqueado em alguns países e redes corporativas. |
| `.timeout(3 s)` no lookup | Sem ele, num portal cativo o lookup fica pendurado por mais de um minuto. |
| `orElse: () => false` no `estaOfflineProvider` | Enquanto carrega, assume **online**. Assumir offline mostraria o banner por um instante a cada abertura. |
| `switch` com `_ when resultado.contains(...)` | Prioriza VPN no rótulo: ela pode explicar lentidão que o usuário está sentindo. |
| `Timer` de 2 s antes de mostrar o banner | Redes móveis oscilam. Banner piscando é pior que banner nenhum. |
| Aviso "Conectado" que some sozinho | Sem ele, o usuário não sabe que pode tentar de novo. |
| `ref.listen`, não `ref.watch`, no banner | Reage à mudança **sem** reconstruir a árvore inteira. |
| `AnimatedSize` | Evita o salto brusco do conteúdo quando a faixa aparece. |
| `SafeArea(bottom: false)` na faixa | Fica **abaixo** da barra de status, não sob ela. |
| `MaterialApp.builder` envolvendo tudo | O aviso de rede não pertence a uma tela — é do app. |
| Repositório **sem** checagem antes da requisição | A regra central: tenta sempre; conectividade só explica. |
| `FalhaDeConexaoIncerta` com texto sobre rede pública | Com interface e sem resposta, o app **não sabe** se é portal cativo, firewall ou servidor. A mensagem cobre os três. |
| `verificarDeVerdade` só no diagnóstico | Gastar requisição para saber se a próxima funciona é desperdício. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| API por baixo | `ConnectivityManager` | `NWPathMonitor` |
| Permissão | `ACCESS_NETWORK_STATE` (normal, automática) | Nenhuma |
| Detecta portal cativo | ✅ o sistema avisa e abre a página | ✅ idem |
| Wi-Fi sem internet | Pode alternar para dados sozinho | Mostra "sem internet" no ícone |
| Modo avião + Wi-Fi | Reporta `wifi` | Reporta `wifi` |
| VPN | Aparece como `vpn` | Aparece como `vpn` |
| Frequência de eventos | Alta durante transições | Menor |
| Economia de dados | Pode bloquear em segundo plano | *Low Data Mode* limita |

> 📌 **A terceira linha é interessante:** os dois sistemas **detectam** portal cativo e avisam o
> usuário. Mas o `connectivity_plus` **não expõe** essa informação — ele só reporta a interface. É
> por isso que a única forma de o seu app saber é **tentar**.

> ⚠️ **No Android, `ACCESS_NETWORK_STATE` é permissão "normal"**: concedida automaticamente na
> instalação, sem diálogo. O plugin já a declara — você não precisa fazer nada. Se alguém te disser
> que precisa pedi-la em tempo de execução, está confundindo com `ACCESS_WIFI_STATE` ou com
> permissões de localização (que o Wi-Fi scanning exige, mas isso é outro assunto).

---

## ⚠️ Erros comuns

### 1. Decidir se tenta com base na conectividade

```dart
if (!temInternet) return cache;   // ❌
final dados = await api.buscar();
```

Produz falso negativo (transição) e falso positivo (portal cativo).

**Correção:** tente sempre; use a conectividade para **explicar** a falha.

### 2. Confundir interface com internet

```dart
if (resultado.contains(ConnectivityResult.wifi)) {
  // "tem internet" ❌
}
```

**Correção:** trate como "provavelmente online". A certeza só existe no `none`.

### 3. Esquecer o valor inicial no `StreamProvider`

```dart
StreamProvider<LeituraDeRede>((Ref ref) => observador.observar());   // ❌
```

Quem abre o app com Wi-Fi e não mexe em nada fica em `AsyncLoading` para sempre.

**Correção:** `yield` do estado atual antes do `yield*`.

### 4. Não cancelar a `StreamSubscription`

```dart
_conectividade.onConnectivityChanged.listen(...);   // ❌ sem cancel
```

**Correção:** guarde e cancele no `dispose` (ou `ref.onDispose`).

### 5. Banner sem atraso

Redes móveis oscilam; o banner pisca a cada buraco de sinal.

**Correção:** 2 segundos de estado estável antes de mostrar.

### 6. Diálogo modal em vez de faixa

```dart
showDialog(context: context, builder: ...);   // ❌ bloqueia o app
```

O app deveria continuar funcionando com cache.

**Correção:** faixa discreta.

### 7. Disparar ação a cada emissão

```dart
observador.observar().listen((_) => sincronizar());   // ⚠️
```

Trocar de rede Wi-Fi emite; ativar VPN emite. Dezenas de sincronizações.

**Correção:** `distinct` + agir só na **transição** offline → online.

### 8. `verificarDeVerdade` antes de toda requisição

```dart
if (!await verificarDeVerdade()) return;   // ⚠️ uma requisição a mais, sempre
await api.buscar();
```

**Correção:** só em upload longo, operação irreversível ou diagnóstico.

### 9. Lookup sem timeout

Num portal cativo, fica pendurado por mais de um minuto.

**Correção:** `.timeout(const Duration(seconds: 3))`.

### 10. Usar `google.com` na verificação

Bloqueado em alguns países e redes corporativas — e o app conclui "sem internet" numa rede
perfeitamente funcional.

**Correção:** `one.one.one.one`, ou melhor, o `/health` do **seu** servidor.

### 11. Mensagem de erro que culpa a internet do usuário

"Sem conexão" quando o problema é o servidor fora do ar deixa o usuário mexendo no roteador à toa.

**Correção:** com interface ativa, a mensagem cobre as três causas possíveis.

### 12. Não avisar que a rede voltou

**Correção:** faixa "Conectado" por 2 segundos.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e aperte **Comparar** com internet normal. Anote os dois
resultados.

**Passo 2.** Ative o modo avião e repita. Os dois concordam?

**Passo 3.** **O passo que ensina a aula:** conecte-se a uma rede pública com portal cativo (café,
shopping, aeroporto) **sem** fazer o login, e aperte Comparar. Anote a divergência.

**Passo 4.** No `verificarDeVerdade`, remova o `.timeout`. Repita o passo 3 e meça quanto tempo
leva.

**Passo 5.** Troque `one.one.one.one` por um domínio inexistente
(`nao-existe-mesmo-123456.com`). O que acontece?

**Passo 6.** No `estadoDeRedeProvider`, remova o `yield` inicial. Abra o app com Wi-Fi ligado, sem
mexer em nada. O que a tela mostra?

**Passo 7.** No `BannerDeRede`, remova o `Timer` de 2 s. Ative e desative o Wi-Fi rapidamente
algumas vezes e descreva a experiência.

**Passo 8.** Remova o `.distinct` do `observar()`. Acrescente um `debugPrint` e alterne entre
Wi-Fi e dados móveis. Quantas emissões?

**Passo 9.** No repositório, acrescente `if (offline) throw FalhaSemConexao();` **antes** da
requisição. Rode num portal cativo e no modo avião, e compare as mensagens com a versão correta.

**Passo 10.** Responda por escrito: o app precisa enviar um arquivo de 50 MB. Você verifica a
internet antes? Justifique.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os exercícios de **Correção de bugs** com decisão baseada em conectividade, o de **Aplicação**
com banner de offline, e o de **Compreensão** sobre portal cativo.

---

## 🏆 Desafio opcional

Implemente **qualidade de conexão**, não só presença.

Requisitos:

- Mede a latência até o seu servidor (`/health`) periodicamente, com o app aberto.
- Classifica em: **boa** (< 300 ms), **lenta** (300 ms – 2 s), **muito lenta** (> 2 s), **sem
  resposta**.
- Em conexão lenta, o app **avisa** antes de operações pesadas: "Sua conexão está lenta. O envio
  pode demorar."
- Em conexão muito lenta, usa timeouts maiores (o padrão de 15 s falharia sempre).
- A medição não pode ser cara: no máximo uma a cada 30 segundos, e **só** com o app em primeiro
  plano.
- Um teste simula as quatro faixas.

Dica: `Stopwatch` em volta de um `HEAD` para o `/health`. Guarde as últimas 5 medições e use a
**mediana** — uma medição isolada é ruído.

Depois responda: por que medir **só com o app em primeiro plano**? E por que a mediana, e não a
média? (Dica: pense no que uma única medição de 8 segundos faz com cada uma.)

---

## 📌 Resumo

- **`connectivity_plus` responde "há interface de rede?", não "há internet?"**
- Situações reais de **conectado sem internet**: portal cativo, roteador sem link, franquia
  esgotada, firewall, DNS quebrado, VPN morta.
- **Nunca decida se tenta a requisição com base na conectividade.** Isso produz falso negativo
  (transição) e falso positivo (portal cativo).
- Os três usos legítimos: **explicar** uma falha, **disparar** sincronização, **mostrar** um
  indicador.
- A verificação real é um **DNS lookup com timeout**, para um host estável (`one.one.one.one`, não
  `google.com`).
- Nem o lookup é infalível: um portal cativo pode responder ao DNS. A prova definitiva é o
  **`/health` do seu servidor**.
- Use a verificação real **raramente**: antes de upload longo, operação irreversível ou
  diagnóstico.
- No `StreamProvider`, o **`yield` inicial é obrigatório** — `onConnectivityChanged` só emite em
  mudanças.
- Use **`.distinct`**: transições emitem valores repetidos.
- O banner deve ser **faixa discreta**, com **atraso de 2 s** contra oscilação, e deve avisar que a
  rede **voltou**.
- Mensagem de erro com interface ativa precisa cobrir **três causas** — o app não sabe qual é.
- Sempre cancele a `StreamSubscription`.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre interface de rede e internet.
- [ ] Cito três situações de "conectado sem internet".
- [ ] Nunca decido se tento a requisição com base na conectividade.
- [ ] Uso a conectividade só para explicar, disparar e mostrar.
- [ ] Sei fazer verificação real com timeout e host adequado.
- [ ] Sei que nem a verificação real é infalível.
- [ ] Uso a verificação real raramente, e sei em quais casos.
- [ ] Incluo o valor inicial no `StreamProvider`.
- [ ] Uso `.distinct` para filtrar emissões repetidas.
- [ ] Meu banner é discreto, tem atraso e avisa quando a rede volta.
- [ ] Minhas mensagens de erro não culpam a internet do usuário sem certeza.
- [ ] Cancelo toda `StreamSubscription`.

---

## 📚 Referências oficiais

- [connectivity_plus — pub.dev](https://pub.dev/packages/connectivity_plus)
- [Networking — docs.flutter.dev](https://docs.flutter.dev/data-and-backend/networking)
- [InternetAddress.lookup — api.dart.dev](https://api.dart.dev/stable/dart-io/InternetAddress/lookup.html)
- [ConnectivityManager — developer.android.com](https://developer.android.com/reference/android/net/ConnectivityManager)
- [NWPathMonitor — developer.apple.com](https://developer.apple.com/documentation/network/nwpathmonitor)
- [Captive portal — MDN](https://developer.mozilla.org/docs/Glossary/Captive_portal)
- [StreamProvider — riverpod.dev](https://riverpod.dev/docs/providers/stream_provider)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Notificações](04-notificacoes.md) | [README](README.md) | [Aula 6 — Ciclo de vida do app](06-ciclo-de-vida-do-app.md) |
