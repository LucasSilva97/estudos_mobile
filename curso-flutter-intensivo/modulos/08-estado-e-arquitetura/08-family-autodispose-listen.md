# Aula 8 — Family, autoDispose e listen

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Usar **`.family`** para criar um provider por parâmetro — um estado por matéria, por exemplo.
- Explicar por que o parâmetro de uma `family` precisa ter **`==` e `hashCode`** por valor.
- Entender o **ciclo de vida** de um provider: quando ele nasce, vive e morre.
- Usar **`.autoDispose`** para liberar estado que ninguém observa mais — e saber quando **não**
  usar.
- Manter um provider vivo temporariamente com **`ref.keepAlive()`**.
- Reagir a mudanças com **`ref.listen`** de dentro de um widget e com **`ref.listenSelf`** de
  dentro de um notifier.
- Limpar recursos com **`ref.onDispose`** (timers, subscriptions, controllers).
- Combinar `family` + `autoDispose` sem vazar memória.

## ✅ Pré-requisitos

- [Aula 6 — Notifier e NotifierProvider](06-notifier-e-notifierprovider.md) e
  [Aula 7 — AsyncNotifier e AsyncValue](07-asyncnotifier-e-asyncvalue.md).
- [Módulo 05, aula 6 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md)
  — `ref.onDispose` é o `dispose` do mundo dos providers.
- [Módulo 03, aula 1 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md) — `==`
  e `hashCode`, que aqui deixam de ser detalhe e passam a ser requisito.
- O projeto `foco_estado` rodando com os notifiers das aulas 6 e 7.

---

## 📖 Conceito

### O problema: um estado por item

A tela de detalhe de matéria precisa do estado **daquela** matéria. Com o que você sabe até agora:

```dart
// ❌ Opção 1: um provider por matéria, escrito à mão
final detalheDartProvider = ...;
final detalheFlutterProvider = ...;
// … e quando o usuário criar uma matéria nova?
```

```dart
// ❌ Opção 2: um provider com um Map
final Provider<Map<String, Detalhe>> detalhesProvider = ...;
// Funciona, mas: qualquer mudança em QUALQUER matéria notifica todo mundo,
// e o estado de matérias já excluídas nunca é liberado.
```

A resposta do Riverpod é **`.family`**: um provider parametrizado.

### `.family`: um provider por parâmetro

```dart
final AsyncNotifierProviderFamily<DetalheNotifier, Detalhe, String>
    detalheProvider = AsyncNotifierProvider.family<DetalheNotifier, Detalhe, String>(
  DetalheNotifier.new,
);

class DetalheNotifier extends FamilyAsyncNotifier<Detalhe, String> {
  @override
  Future<Detalhe> build(String materiaId) async {
    //                  ↑ o parâmetro chega aqui
    return ref.read(fonteProvider).buscarDetalhe(materiaId);
  }
}
```

E na tela:

```dart
final AsyncValue<Detalhe> detalhe = ref.watch(detalheProvider('dart'));
//                                              ↑ o parâmetro vai aqui
```

O que acontece por dentro: o Riverpod mantém um `Map` interno de **parâmetro → estado**. Cada
`detalheProvider('dart')` e `detalheProvider('flutter')` tem estado **independente**, com ciclo de
vida próprio.

| Tipo | Versão family |
|---|---|
| `Provider<T>` | `Provider.family<T, Arg>` |
| `NotifierProvider<N, T>` | `NotifierProvider.family<N, T, Arg>` + `FamilyNotifier<T, Arg>` |
| `AsyncNotifierProvider<N, T>` | `AsyncNotifierProvider.family<N, T, Arg>` + `FamilyAsyncNotifier<T, Arg>` |

> ⚠️ A classe do notifier muda: `Notifier<T>` vira **`FamilyNotifier<T, Arg>`**, e o `build()` passa
> a **receber** o argumento. Esquecer isso é o primeiro erro de compilação de todo mundo.

### O parâmetro precisa ter `==` e `hashCode`

Esta é a regra que mais causa bug silencioso:

```dart
// ❌ classe sem == : cada chamada cria um provider NOVO
class Filtro {
  const Filtro({required this.categoria, required this.apenasAtivas});
  final String categoria;
  final bool apenasAtivas;
}

// Na tela:
ref.watch(materiasProvider(const Filtro(categoria: 'exatas', apenasAtivas: true)));
```

Sem `==`, dois `Filtro` com os mesmos valores são objetos **diferentes**. O Riverpod cria um estado
novo a cada `build` do widget — e nenhum é liberado. **Vazamento de memória garantido.**

**Correção:** implemente `==` e `hashCode`, ou use tipos que já os têm:

```dart
// ✅ String, int, bool, enum e records já têm == por valor
ref.watch(detalheProvider('dart'));
ref.watch(sessoesProvider((materiaId: 'dart', apenasHoje: true)));  // record
```

> 💡 **Records** (Dart 3) são a forma mais prática de passar múltiplos parâmetros para uma family:
> eles já têm `==` e `hashCode` por valor, de graça. Visto no
> [Módulo 04, aula 4](../04-dart-avancado/04-records.md).

### Ciclo de vida de um provider

Por padrão, um provider:

1. **Nasce** na primeira leitura (preguiçoso — antes disso ele não existe).
2. **Vive** enquanto o `ProviderScope` existir.
3. **Morre** só quando o `ProviderScope` for descartado.

Isso é bom para estado global (usuário logado, tema) e **ruim** para estado de tela — porque o
estado de 200 telas de detalhe visitadas continua na memória.

### `.autoDispose`: liberar quando ninguém observa

```dart
final AsyncNotifierProvider<TrilhasNotifier, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider.autoDispose<TrilhasNotifier, List<Trilha>>(
  TrilhasNotifier.new,
);
```

Com `autoDispose`, o provider é **descartado** quando o último observador sai. Na próxima leitura,
ele nasce de novo — e o `build()` roda outra vez.

| | Sem `autoDispose` | Com `autoDispose` |
|---|---|---|
| Vive até | O app fechar | O último observador sair |
| Estado ao voltar à tela | **Preservado** | **Recriado** (busca de novo) |
| Memória | Acumula | Liberada |
| Use para | Sessão, tema, configuração, carrinho | Detalhe de item, busca, tela temporária |

> 📌 **Combine sempre `family` com `autoDispose`.** Uma family sem autoDispose acumula um estado
> por parâmetro já usado — e nenhum é liberado. Numa lista de 500 itens, o usuário que abrir todos
> os detalhes deixa 500 estados na memória.

### `ref.keepAlive()`: manter vivo condicionalmente

Às vezes você quer `autoDispose`, **mas** não descartar um resultado que custou caro:

```dart
class DetalheNotifier extends AutoDisposeFamilyAsyncNotifier<Detalhe, String> {
  @override
  Future<Detalhe> build(String id) async {
    final Detalhe d = await ref.read(fonteProvider).buscar(id);

    // A busca deu certo: vale a pena guardar o resultado.
    // Se o usuário voltar a esta matéria, não busca de novo.
    ref.keepAlive();

    return d;
  }
}
```

`keepAlive()` cancela o descarte automático **daquela instância**. Erros continuam sendo
descartados (o que é bom: o usuário pode querer tentar de novo).

Para um cache com prazo:

```dart
@override
Future<Detalhe> build(String id) async {
  final Detalhe d = await _buscar(id);

  final KeepAliveLink link = ref.keepAlive();
  // Guarda por 5 minutos; depois volta a poder ser descartado.
  final Timer timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  return d;
}
```

### `ref.onDispose`: o `dispose` dos providers

Todo recurso criado dentro de um provider precisa ser liberado:

```dart
class CronometroNotifier extends AutoDisposeNotifier<int> {
  @override
  int build() {
    final Timer timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => state = state + 1,
    );

    // Chamado quando o provider é descartado.
    // Sem isto, o Timer continua rodando e tentando escrever
    // num estado que já não existe.
    ref.onDispose(timer.cancel);

    return 0;
  }
}
```

`ref.onDispose` aceita quantas chamadas você quiser, e todas rodam na ordem inversa. Use para:
`Timer`, `StreamSubscription`, `TextEditingController`, conexões, arquivos abertos.

> 💡 É o equivalente exato do `dispose()` do `State`, visto no
> [Módulo 05, aula 6](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md). A diferença é que
> aqui ele é registrado **dentro** do `build`, junto da criação — o que torna muito mais difícil
> esquecer.

### `invalidate`, `refresh` e `invalidateSelf`

| Método | Onde | O que faz |
|---|---|---|
| `ref.invalidate(p)` | Widget ou provider | Descarta o estado de `p`; recarrega na próxima leitura |
| `ref.refresh(p)` | Widget ou provider | Descarta **e devolve** o novo valor |
| `ref.invalidateSelf()` | Dentro do notifier | O provider descarta **a si mesmo** e roda `build()` de novo |

`invalidateSelf` é útil quando o notifier sabe que os próprios dados venceram:

```dart
void aoReceberNotificacaoDeMudanca() {
  ref.invalidateSelf();   // recarrega tudo do zero
}
```

E para invalidar uma family inteira:

```dart
ref.invalidate(detalheProvider);           // TODAS as instâncias
ref.invalidate(detalheProvider('dart'));   // só a do 'dart'
```

### `ref.listen` × `ref.listenSelf`

Você já usou `ref.listen` no widget (aula 5). Dentro de um provider existem dois:

```dart
class SessoesNotifier extends Notifier<List<Sessao>> {
  @override
  List<Sessao> build() {
    // Reage à mudança de OUTRO provider, sem se recriar.
    ref.listen<String?>(usuarioIdProvider, (String? antes, String? agora) {
      if (antes != agora) state = <Sessao>[];
    });

    // Reage às mudanças do PRÓPRIO estado.
    ref.listenSelf((List<Sessao>? antes, List<Sessao> agora) {
      debugPrint('sessões: ${antes?.length ?? 0} → ${agora.length}');
    });

    return <Sessao>[];
  }
}
```

| | `ref.watch` | `ref.listen` | `ref.listenSelf` |
|---|---|---|---|
| Dentro do `build()` do notifier | **Recria** o notifier quando muda | Executa código, **sem** recriar | Observa o próprio estado |
| Uso típico | Dependência real | Efeito colateral (limpar, logar, salvar) | Log, persistência automática |

O caso mais útil de `listenSelf`: **salvar automaticamente** toda mudança de estado.

```dart
ref.listenSelf((List<Sessao>? antes, List<Sessao> agora) {
  if (antes != null) _persistir(agora);   // grava sem espalhar chamadas
});
```

---

## 💡 Analogia

Pense num arquivo de pastas de clientes num escritório.

- **Sem `family`**, você tem **uma pasta gigante** com todos os clientes dentro. Para ver um
  cliente, abre a pasta inteira. E quando um dado de um cliente muda, **todo mundo** que consulta a
  pasta é avisado, mesmo quem só queria outro cliente.
- **Com `family`**, cada cliente tem a **própria pasta**, identificada pelo CPF. Você pede a pasta
  do CPF X e recebe só ela. Mudanças no cliente Y não incomodam quem está lendo o X.
- **O `==` do parâmetro** é o CPF ser um identificador **de valor**. Se o arquivista tratasse
  "CPF 123" escrito em papéis diferentes como identificadores **diferentes**, ele criaria uma pasta
  nova a cada consulta — e o arquivo encheria de pastas duplicadas até não caber mais. É
  exatamente isso que acontece com uma classe sem `==`.
- **`autoDispose`** é a regra: "pasta que ninguém está consultando volta para o arquivo morto". Sem
  ela, toda pasta já consultada fica **espalhada na mesa** para sempre.
- **`keepAlive()`** é dizer "esta pasta custou três dias para montar — deixe na mesa mesmo que
  ninguém esteja usando agora".
- **`ref.onDispose`** é o procedimento de arquivamento: apagar o quadro, desligar a luminária,
  devolver a chave. Se você guarda a pasta e deixa a luminária acesa — o `Timer` ainda rodando —,
  ela continua consumindo energia a noite inteira.
- **`listenSelf`** é o arquivista registrar no livro toda vez que a própria pasta muda, sem ninguém
  precisar lembrar de avisá-lo.

---

## 🧪 Exemplo mínimo

Este programa mostra o ciclo de vida acontecendo, com logs de nascimento e morte de cada provider.

> **Arquivo:** `foco_estado/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome` — **e olhe o console**

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Family SEM autoDispose: acumula estado ────────────────────────────────
final ProviderFamily<String, String> eternoProvider =
    Provider.family<String, String>((Ref ref, String id) {
  debugPrint('🟢 NASCEU eterno($id)');
  ref.onDispose(() => debugPrint('🔴 MORREU eterno($id)'));
  return 'Detalhe de $id';
});

// ── Family COM autoDispose: libera quando ninguém observa ─────────────────
final AutoDisposeProviderFamily<String, String> efemeroProvider =
    Provider.autoDispose.family<String, String>((Ref ref, String id) {
  debugPrint('🟢 NASCEU efemero($id)');
  ref.onDispose(() => debugPrint('🔴 MORREU efemero($id)'));
  return 'Detalhe de $id';
});

// ── autoDispose + keepAlive: só sobrevive se valer a pena ─────────────────
final AutoDisposeProviderFamily<String, String> comCacheProvider =
    Provider.autoDispose.family<String, String>((Ref ref, String id) {
  debugPrint('🟢 NASCEU comCache($id)');
  ref.onDispose(() => debugPrint('🔴 MORREU comCache($id)'));

  // Só vale a pena guardar os "caros".
  if (id == 'caro') {
    debugPrint('   📌 keepAlive em comCache($id)');
    ref.keepAlive();
  }

  return 'Detalhe de $id';
});

// ── Notifier com Timer: mostra por que onDispose importa ──────────────────
final AutoDisposeNotifierProvider<CronometroNotifier, int> cronometroProvider =
    NotifierProvider.autoDispose<CronometroNotifier, int>(
        CronometroNotifier.new);

class CronometroNotifier extends AutoDisposeNotifier<int> {
  @override
  int build() {
    debugPrint('🟢 NASCEU cronometro');

    final Timer timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => state = state + 1,
    );

    // SEM esta linha, o Timer continuaria rodando depois do descarte,
    // tentando escrever num estado que já não existe.
    ref.onDispose(() {
      timer.cancel();
      debugPrint('🔴 MORREU cronometro (timer cancelado)');
    });

    return 0;
  }
}

// ── App ────────────────────────────────────────────────────────────────────

void main() => runApp(const ProviderScope(child: AppCicloDeVida()));

class AppCicloDeVida extends StatelessWidget {
  const AppCicloDeVida({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaLista(),
    );
  }
}

class TelaLista extends StatelessWidget {
  const TelaLista({super.key});

  static const List<String> _ids = <String>['dart', 'flutter', 'caro'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ciclo de vida')),
      body: ListView(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Abra um detalhe, volte, e olhe o console.\n\n'
              '• eterno   → nasce e NUNCA morre\n'
              '• efemero  → morre ao sair da tela\n'
              '• comCache → só "caro" sobrevive (keepAlive)\n'
              '• cronometro → morre e zera ao sair',
            ),
          ),
          for (final String id in _ids)
            ListTile(
              title: Text(id),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => TelaDetalhe(id: id)),
              ),
            ),
        ],
      ),
    );
  }
}

class TelaDetalhe extends ConsumerWidget {
  const TelaDetalhe({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cada watch cria (ou reaproveita) a instância daquele parâmetro.
    final String eterno = ref.watch(eternoProvider(id));
    final String efemero = ref.watch(efemeroProvider(id));
    final String comCache = ref.watch(comCacheProvider(id));
    final int segundos = ref.watch(cronometroProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Detalhe: $id')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ListTile(title: const Text('eterno'), subtitle: Text(eterno)),
          ListTile(title: const Text('efemero'), subtitle: Text(efemero)),
          ListTile(title: const Text('comCache'), subtitle: Text(comCache)),
          const Divider(),
          ListTile(
            title: const Text('cronômetro'),
            subtitle: Text('$segundos s nesta tela'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Volte e entre de novo: o cronômetro ZERA (autoDispose), '
            'mas o "caro" não reimprime NASCEU (keepAlive).',
          ),
        ],
      ),
    );
  }
}
```

**O roteiro que ensina a aula inteira:**

1. Abra `dart`. O console mostra **quatro** `🟢 NASCEU`.
2. Espere 3 segundos e **volte**. O console mostra três `🔴 MORREU`: `efemero`, `comCache` e
   `cronometro`. O `eterno` **não morre**.
3. Abra `dart` de novo: `efemero` e `cronometro` **nascem de novo** (o cronômetro zerou); o
   `eterno` **não reimprime** (nunca morreu).
4. Abra `caro`, volte, e abra `caro` de novo: o `comCache` **não** reimprime `NASCEU` — o
   `keepAlive` o preservou.
5. Abra e volte de `dart` dez vezes. Conte quantos `eterno` continuam vivos: **um por id**, para
   sempre. Agora imagine uma lista de 500 itens.

---

## 📱 Aplicando no Flutter

O `foco_estado` ganha a tela de detalhe de matéria, com:

- **`family`** para o estado por matéria;
- **`autoDispose`** para não acumular estado das matérias já visitadas;
- **`keepAlive`** condicional: guarda o resultado por 2 minutos;
- **`ref.onDispose`** cancelando um cronômetro de sessão;
- **`ref.listen`** para navegar quando a meta é batida;
- **`ref.listenSelf`** registrando toda mudança num log.

---

## 💻 Código completo

> **Arquivo:** `foco_estado/lib/estado/detalhe_materia_notifier.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/dominio/materia.dart';
import 'package:foco_estado/dominio/sessao.dart';
import 'package:foco_estado/estado/materias_notifier.dart';
import 'package:foco_estado/estado/sessoes_notifier.dart';

/// Estado de uma matéria específica, montado a partir de duas fontes.
@immutable
class DetalheMateria {
  const DetalheMateria({
    required this.materia,
    required this.sessoes,
    required this.minutosHoje,
  });

  final Materia materia;
  final List<Sessao> sessoes;
  final int minutosHoje;

  double get progresso =>
      materia.metaMinutos == 0
          ? 0
          : (minutosHoje / materia.metaMinutos).clamp(0.0, 1.0);

  bool get metaBatida => minutosHoje >= materia.metaMinutos;
}

/// ─────────────────────────────────────────────────────────────────────────
/// FAMILY + AUTODISPOSE
///
/// family      → um estado POR matéria, independente dos outros.
/// autoDispose → o estado morre quando ninguém observa mais.
///
/// Os dois juntos são a combinação obrigatória: family sozinha acumularia
/// um estado por matéria já visitada, e nenhum seria liberado.
/// ─────────────────────────────────────────────────────────────────────────
final AutoDisposeProviderFamily<DetalheMateria?, String> detalheMateriaProvider =
    Provider.autoDispose.family<DetalheMateria?, String>(
        (Ref ref, String materiaId) {
  // O parâmetro é uma String: ela já tem == e hashCode por valor.
  // Uma classe sem == criaria um provider novo a cada build do widget.

  final List<Materia> materias = ref.watch(materiasProvider);
  final int indice = materias.indexWhere((Materia m) => m.id == materiaId);

  // Matéria excluída: devolvemos null em vez de lançar.
  // A tela decide o que fazer — geralmente voltar.
  if (indice == -1) return null;

  final List<Sessao> sessoes = ref
      .watch(sessoesProvider)
      .where((Sessao s) => s.materiaId == materiaId)
      .toList();

  final int minutosHoje = sessoes
      .where((Sessao s) => s.ehDeHoje)
      .fold(0, (int soma, Sessao s) => soma + s.minutos);

  return DetalheMateria(
    materia: materias[indice],
    sessoes: sessoes,
    minutosHoje: minutosHoje,
  );
});

/// ─────────────────────────────────────────────────────────────────────────
/// CRONÔMETRO POR MATÉRIA
///
/// Um Timer por matéria, cancelado automaticamente quando o usuário sai
/// da tela. O onDispose é o que impede o Timer de continuar rodando
/// e escrever num estado que já não existe.
/// ─────────────────────────────────────────────────────────────────────────
final AutoDisposeNotifierProviderFamily<CronometroNotifier, EstadoCronometro,
    String> cronometroProvider =
    NotifierProvider.autoDispose.family<CronometroNotifier, EstadoCronometro,
        String>(CronometroNotifier.new);

@immutable
class EstadoCronometro {
  const EstadoCronometro({this.segundos = 0, this.rodando = false});

  final int segundos;
  final bool rodando;

  int get minutos => segundos ~/ 60;

  EstadoCronometro copyWith({int? segundos, bool? rodando}) {
    return EstadoCronometro(
      segundos: segundos ?? this.segundos,
      rodando: rodando ?? this.rodando,
    );
  }

  @override
  bool operator ==(Object outro) =>
      outro is EstadoCronometro &&
      outro.segundos == segundos &&
      outro.rodando == rodando;

  @override
  int get hashCode => Object.hash(segundos, rodando);
}

/// Note a classe: AutoDisposeFamilyNotifier<Estado, Argumento>.
/// O build() RECEBE o argumento — diferente do Notifier comum.
class CronometroNotifier
    extends AutoDisposeFamilyNotifier<EstadoCronometro, String> {
  Timer? _timer;

  @override
  EstadoCronometro build(String materiaId) {
    // Todo recurso criado aqui precisa ser liberado aqui.
    // Registrar o onDispose JUNTO da criação é o que torna
    // difícil esquecer.
    ref.onDispose(() {
      _timer?.cancel();
      debugPrint('cronometro($materiaId): descartado, timer cancelado');
    });

    // listenSelf: registra toda mudança do PRÓPRIO estado,
    // sem espalhar chamadas de log pelos métodos.
    ref.listenSelf((EstadoCronometro? antes, EstadoCronometro agora) {
      if (antes?.rodando != agora.rodando) {
        debugPrint(
          'cronometro($materiaId): ${agora.rodando ? "iniciado" : "pausado"}',
        );
      }
    });

    return const EstadoCronometro();
  }

  void alternar() {
    if (state.rodando) {
      _timer?.cancel();
      state = state.copyWith(rodando: false);
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(segundos: state.segundos + 1);
    });
    state = state.copyWith(rodando: true);
  }

  /// Encerra o cronômetro e registra a sessão. Devolve os minutos gravados.
  int concluir() {
    _timer?.cancel();
    final int minutos = state.minutos;

    if (minutos > 0) {
      // `arg` é o parâmetro da family, disponível em qualquer método.
      ref.read(sessoesProvider.notifier).registrar(
            materiaId: arg,
            minutos: minutos,
          );
    }

    state = const EstadoCronometro();
    return minutos;
  }

  void zerar() {
    _timer?.cancel();
    state = const EstadoCronometro();
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// FAMILY COM RECORD
///
/// Records (Dart 3) já têm == e hashCode por valor — a forma mais prática
/// de passar vários parâmetros para uma family sem escrever uma classe.
/// ─────────────────────────────────────────────────────────────────────────
typedef FiltroSessoes = ({String materiaId, bool apenasHoje});

final AutoDisposeProviderFamily<List<Sessao>, FiltroSessoes>
    sessoesFiltradasProvider =
    Provider.autoDispose.family<List<Sessao>, FiltroSessoes>(
        (Ref ref, FiltroSessoes filtro) {
  return ref.watch(sessoesProvider).where((Sessao s) {
    if (s.materiaId != filtro.materiaId) return false;
    if (filtro.apenasHoje && !s.ehDeHoje) return false;
    return true;
  }).toList();
});
```

> **Arquivo:** `foco_estado/lib/telas/detalhe_materia_screen.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/dominio/sessao.dart';
import 'package:foco_estado/estado/detalhe_materia_notifier.dart';

class DetalheMateriaScreen extends ConsumerWidget {
  const DetalheMateriaScreen({super.key, required this.materiaId});

  final String materiaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // O parâmetro vai entre parênteses. Cada materiaId tem estado próprio.
    final DetalheMateria? detalhe =
        ref.watch(detalheMateriaProvider(materiaId));

    // listen no provider de detalhe: reage a EFEITOS, sem reconstruir.
    ref.listen<DetalheMateria?>(detalheMateriaProvider(materiaId),
        (DetalheMateria? antes, DetalheMateria? agora) {
      // 1. A matéria foi excluída em outra tela: saia daqui.
      if (antes != null && agora == null) {
        Navigator.of(context).pop();
        return;
      }

      // 2. A meta acabou de ser batida: comemore UMA vez.
      if (agora != null && agora.metaBatida && !(antes?.metaBatida ?? false)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('🎉 Meta de ${agora.materia.nome} cumprida!'),
          ));
      }
    });

    if (detalhe == null) {
      return const Scaffold(
        body: Center(child: Text('Matéria não encontrada')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(detalhe.materia.nome)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _CartaoProgresso(detalhe: detalhe),
          const SizedBox(height: 16),
          _Cronometro(materiaId: materiaId),
          const SizedBox(height: 24),
          _ListaSessoes(materiaId: materiaId),
        ],
      ),
    );
  }
}

class _CartaoProgresso extends StatelessWidget {
  const _CartaoProgresso({required this.detalhe});

  final DetalheMateria detalhe;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${detalhe.minutosHoje} de ${detalhe.materia.metaMinutos} min hoje',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: detalhe.progresso, minHeight: 8),
          ],
        ),
      ),
    );
  }
}

class _Cronometro extends ConsumerWidget {
  const _Cronometro({required this.materiaId});

  final String materiaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EstadoCronometro estado = ref.watch(cronometroProvider(materiaId));

    final String mmss =
        '${(estado.segundos ~/ 60).toString().padLeft(2, '0')}:'
        '${(estado.segundos % 60).toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(mmss, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(cronometroProvider(materiaId).notifier).alternar(),
                  icon: Icon(estado.rodando ? Icons.pause : Icons.play_arrow),
                  label: Text(estado.rodando ? 'Pausar' : 'Iniciar'),
                ),
                OutlinedButton.icon(
                  onPressed: estado.minutos == 0
                      ? null
                      : () {
                          final int min = ref
                              .read(cronometroProvider(materiaId).notifier)
                              .concluir();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$min min registrados')),
                          );
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Concluir'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Saia desta tela: o cronômetro é descartado e o Timer '
              'cancelado automaticamente.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaSessoes extends ConsumerWidget {
  const _ListaSessoes({required this.materiaId});

  final String materiaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Family com record: dois parâmetros, == de graça.
    final List<Sessao> sessoes = ref.watch(
      sessoesFiltradasProvider((materiaId: materiaId, apenasHoje: true)),
    );

    if (sessoes.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Nenhuma sessão hoje'),
        ),
      );
    }

    return Card(
      child: Column(
        children: <Widget>[
          for (final Sessao s in sessoes)
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text('${s.minutos} minutos'),
              subtitle: Text(s.anotacao.isEmpty ? '—' : s.anotacao),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remover sessão',
                onPressed: () =>
                    ref.read(sessoesProvider.notifier).remover(s.id),
              ),
            ),
        ],
      ),
    );
  }
}
```

Rode e teste:

```powershell
flutter analyze
flutter run -d chrome
```

1. Abra o detalhe de "Dart", inicie o cronômetro e espere 10 segundos.
2. **Volte**. O console mostra `cronometro(dart): descartado, timer cancelado`.
3. Entre de novo: o cronômetro está **zerado** — `autoDispose` funcionou.
4. Abra "Dart" e "Flutter" em sequência: cada um tem cronômetro **independente**.
5. Bata a meta de uma matéria: o `SnackBar` aparece **uma vez**.
6. Com o detalhe aberto, exclua a matéria pela lista: a tela **fecha sozinha** (o `listen` detectou
   `null`).

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `Provider.autoDispose.family<Detalhe?, String>` | As duas coisas juntas: estado por parâmetro **e** liberação automática. Family sem autoDispose acumula. |
| Parâmetro `String materiaId` | `String` já tem `==` e `hashCode` por valor. Uma classe sem `==` criaria um provider novo a cada `build`. |
| `if (indice == -1) return null;` | Matéria excluída devolve `null` em vez de lançar. A tela decide o que fazer. |
| `AutoDisposeFamilyNotifier<EstadoCronometro, String>` | A classe muda quando há family: o `build()` **recebe** o argumento. |
| `ref.onDispose(() { _timer?.cancel(); ... })` **dentro do `build`** | Registrado junto da criação — é o que torna difícil esquecer. Equivale ao `dispose()` do `State`. |
| `ref.listenSelf((antes, agora) {...})` | Observa o **próprio** estado. Log e persistência automática sem espalhar chamadas pelos métodos. |
| `arg` dentro dos métodos do notifier | O parâmetro da family fica disponível como `arg` em toda a classe. |
| `typedef FiltroSessoes = ({String materiaId, bool apenasHoje});` | *Record* nomeado: `==` e `hashCode` por valor **de graça**. A forma prática de passar vários parâmetros. |
| `ref.watch(detalheMateriaProvider(materiaId))` | O parâmetro vai entre parênteses. Cada valor tem instância própria. |
| `ref.listen` detectando `antes != null && agora == null` | A matéria sumiu: feche a tela. Um efeito que `watch` sozinho não resolveria. |
| `agora.metaBatida && !(antes?.metaBatida ?? false)` | Só age na **transição**. Sem isso, a mensagem repetiria a cada sessão depois da meta. |
| `EstadoCronometro` com `==` e `hashCode` | Estado imutável comparável: sem isso, o Riverpod notificaria a cada segundo mesmo sem mudança real. |
| `onPressed: estado.minutos == 0 ? null : ...` | Botão desabilitado quando não há o que concluir. |

---

## ⚠️ Erros comuns

### 1. `family` com parâmetro sem `==`

```dart
class Filtro { final String cat; const Filtro(this.cat); }   // ❌ sem ==

ref.watch(materiasProvider(const Filtro('exatas')));
```

Um provider novo a cada `build`, e nenhum é liberado. Vazamento silencioso.

**Correção:** implemente `==`/`hashCode`, ou use `String`, `int`, `enum` ou **record**.

### 2. `family` sem `autoDispose`

```dart
final ProviderFamily<Detalhe, String> p = Provider.family<Detalhe, String>(...);   // ⚠️
```

Numa lista de 500 itens, abrir todos os detalhes deixa 500 estados na memória para sempre.

**Correção:** `Provider.autoDispose.family<...>`.

### 3. Classe de notifier errada com family

```dart
class MeuNotifier extends Notifier<int> {   // ❌
  @override
  int build(String arg) => 0;               // assinatura não bate
}
```

```text
'build' doesn't override an inherited method
```

**Correção:** `FamilyNotifier<int, String>` (ou `AutoDisposeFamilyNotifier`, com autoDispose).

### 4. Esquecer `ref.onDispose` de um `Timer`

```dart
@override
int build() {
  Timer.periodic(const Duration(seconds: 1), (_) => state++);   // ❌
  return 0;
}
```

O provider é descartado, o `Timer` continua rodando, e a escrita em `state` lança erro — ou, pior,
mantém o provider vivo por acidente.

**Correção:** `ref.onDispose(timer.cancel);`

### 5. `autoDispose` em estado que deveria persistir

```dart
final AutoDisposeNotifierProvider<CarrinhoNotifier, List<Item>> carrinho = ...;   // ⚠️
```

O usuário vai para outra aba, volta, e o carrinho está **vazio**.

**Correção:** sem `autoDispose` para estado que precisa sobreviver à navegação.

### 6. `keepAlive()` sem condição

```dart
@override
Future<Detalhe> build(String id) async {
  ref.keepAlive();              // ⚠️ desliga o autoDispose para tudo
  return _buscar(id);
}
```

Equivale a não ter `autoDispose` — inclusive para os erros, que ficam presos.

**Correção:** condicione (`if (sucesso)`) ou dê prazo com `KeepAliveLink` + `Timer`.

### 7. `ref.watch` de uma family com parâmetro criado no `build`

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final Filtro f = Filtro(cat: 'exatas');            // ⚠️ objeto novo a cada build
  final List<Materia> l = ref.watch(materiasProvider(f));
```

Mesmo **com** `==` implementado funciona, mas criar objetos a cada `build` é desperdício. Sem `==`,
é vazamento.

**Correção:** `const Filtro(...)`, ou um record, ou eleve o parâmetro para fora do `build`.

### 8. `ref.listen` sem comparar com o valor anterior

```dart
ref.listen<DetalheMateria?>(p, (antes, agora) {
  if (agora!.metaBatida) mostrarParabens();   // ⚠️ repete a cada mudança
});
```

**Correção:** compare com `antes` e aja só na **transição**.

### 9. `invalidate` numa family achando que invalida uma instância

```dart
ref.invalidate(detalheProvider);   // invalida TODAS as instâncias
```

Às vezes é o que você quer; muitas vezes não.

**Correção:** `ref.invalidate(detalheProvider('dart'))` para uma só.

### 10. Guardar o `Timer` em variável local do `build`

```dart
@override
int build() {
  final Timer t = Timer.periodic(...);   // ⚠️ métodos do notifier não alcançam
  ref.onDispose(t.cancel);
  return 0;
}

void pausar() => t.cancel();   // não compila
```

**Correção:** guarde em campo da classe (`Timer? _timer;`), como no código completo.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e execute o roteiro de cinco passos, lendo o console em cada um.

**Passo 2.** Abra e volte de `dart` dez vezes. Conte as linhas `🟢 NASCEU eterno(dart)` e
`🔴 MORREU eterno(dart)`. Explique a diferença.

**Passo 3.** Remova `.autoDispose` do `efemeroProvider`. Repita o passo 2 e compare.

**Passo 4.** No `comCacheProvider`, troque a condição do `keepAlive` para valer **sempre**. Abra e
volte de `dart` três vezes. O que mudou?

**Passo 5.** Remova o `ref.onDispose` do `CronometroNotifier` do exemplo mínimo. Inicie o
cronômetro, volte e espere. Leia o erro no console.

**Passo 6.** No `foco_estado`, abra o detalhe de duas matérias diferentes em sequência. Inicie o
cronômetro em cada uma. Confirme que os tempos são independentes.

**Passo 7.** Troque o record `FiltroSessoes` por uma classe **sem** `==`. Abra a tela, observe o
console (acrescente um `debugPrint` no provider) e conte quantas vezes ele nasce. Depois volte.

**Passo 8.** Com o detalhe de "Dart" aberto em uma aba, exclua "Dart" pela lista. A tela fecha?
Qual linha de código faz isso?

**Passo 9.** Bata a meta de uma matéria, depois registre mais três sessões. O `SnackBar` aparece
quantas vezes? Remova a comparação com `antes` e repita.

**Passo 10.** Acrescente um `ref.listenSelf` ao `SessoesNotifier` que imprime o total de minutos a
cada mudança. Quantas chamadas de `debugPrint` você precisou espalhar pelos métodos?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

Faça os exercícios de **Aplicação** com `family` + `autoDispose`, o de **Correção de bugs** com
parâmetro sem `==`, e o de **Compreensão** sobre ciclo de vida.

---

## 🏆 Desafio opcional

Implemente um **cache com prazo** para o detalhe das matérias:

- O resultado de uma busca fica guardado por **2 minutos** após o último observador sair.
- Dentro desse prazo, reabrir a tela **não** busca de novo.
- Passado o prazo, o estado é descartado normalmente.
- Um provider `cacheStatusProvider` informa quantas instâncias estão em cache e há quanto tempo.
- Um botão "limpar cache" invalida todas as instâncias de uma vez.

Dica: `final KeepAliveLink link = ref.keepAlive();` guarda a referência;
`Timer(duracao, link.close)` agenda a liberação; `ref.onDispose(timer.cancel)` limpa o timer se o
provider morrer antes.

Depois responda: o que acontece se o usuário reabrir a tela **durante** os 2 minutos e sair de
novo? O prazo reinicia ou continua contando? Qual dos dois comportamentos você quer, e como
garantir?

---

## 📌 Resumo

- **`.family`** cria um provider **por parâmetro**: `detalheProvider('dart')` e
  `detalheProvider('flutter')` têm estados independentes.
- O parâmetro **precisa** ter `==` e `hashCode` por valor. Sem isso, um provider novo nasce a cada
  `build` e nenhum é liberado — **vazamento silencioso**.
- **Records** (Dart 3) são a forma mais prática de passar vários parâmetros: `==` de graça.
- Com family, a classe do notifier muda para **`FamilyNotifier<T, Arg>`** e o `build()` **recebe**
  o argumento. Dentro dos métodos, ele é `arg`.
- Por padrão um provider **nasce** na primeira leitura e **vive** até o app fechar.
- **`.autoDispose`** descarta quando o último observador sai. Use para detalhe de item, busca e
  telas temporárias; **não** use para sessão, tema e carrinho.
- **Sempre combine `family` com `autoDispose`** — ou o estado acumula um por parâmetro visitado.
- **`ref.keepAlive()`** cancela o descarte daquela instância. Condicione-o, ou dê prazo com
  `KeepAliveLink` + `Timer`.
- **`ref.onDispose`** é o `dispose()` dos providers. Registre-o **junto** da criação do recurso.
- **`ref.listen`** reage a outro provider sem se recriar; **`ref.listenSelf`** reage ao próprio
  estado (log, persistência automática).
- Dentro do `build()` do notifier: `watch` **recria**, `listen` **não**.
- `ref.invalidate(familyProvider)` invalida **todas** as instâncias;
  `ref.invalidate(familyProvider('x'))` invalida uma.
- No `listen`, compare com o valor anterior para agir só na **transição**.

---

## ☑️ Checklist de domínio

- [ ] Uso `.family` e explico o que ela cria por parâmetro.
- [ ] Sei por que o parâmetro precisa de `==` e `hashCode`, e o que quebra sem eles.
- [ ] Uso records para parâmetros compostos.
- [ ] Escrevo `FamilyNotifier` com o `build()` recebendo o argumento.
- [ ] Acesso o parâmetro pelos métodos usando `arg`.
- [ ] Descrevo o ciclo de vida padrão de um provider.
- [ ] Escolho entre com e sem `autoDispose` com critério, e cito um exemplo de cada.
- [ ] Combino `family` com `autoDispose` sempre.
- [ ] Uso `ref.keepAlive()` condicionalmente, nunca incondicionalmente.
- [ ] Registro `ref.onDispose` junto da criação de todo `Timer` ou subscription.
- [ ] Sei a diferença entre `ref.watch`, `ref.listen` e `ref.listenSelf` dentro de um notifier.
- [ ] Comparo com o valor anterior dentro do `listen`.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Passing arguments to your requests — riverpod.dev](https://riverpod.dev/docs/essentials/passing_args)
- [Auto dispose & state disposal — riverpod.dev](https://riverpod.dev/docs/essentials/auto_dispose)
- [Combining requests — riverpod.dev](https://riverpod.dev/docs/essentials/combining_requests)
- [Performing side effects — riverpod.dev](https://riverpod.dev/docs/essentials/side_effects)
- [Records — dart.dev](https://dart.dev/language/records)
- [Object.hash — api.dart.dev](https://api.dart.dev/stable/dart-core/Object/hash.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — AsyncNotifier e AsyncValue](07-asyncnotifier-e-asyncvalue.md) | [README](README.md) | [Aula 9 — Arquitetura feature-first](09-arquitetura-feature-first.md) |
