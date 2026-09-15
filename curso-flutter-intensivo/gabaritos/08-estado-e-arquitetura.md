# Gabarito — Módulo 08: Estado e arquitetura

> Compare depois de resolver os [exercícios](../exercicios/08-estado-e-arquitetura.md).

<a id="m08-e01"></a>
## M08-E01
1. **Rebuild em excesso — `AbaMaterias` e `AbaAjustes`.** Tocar em `+25 min` imprime oito linhas de `build`, incluindo as duas abas invisíveis dentro do `IndexedStack`. `setState` invalida o `build` inteiro de `_CascaFocoState`, e ele recria toda a subárvore.
2. **Estado perdido ao navegar — `TelaSessao`.** Aberta por `Navigator.push`, ela nasce abaixo do `Navigator` do `MaterialApp`, que está *acima* de `CascaFoco`: não alcança `_minutosHoje` nem `_registrarSessao`.
3. **Regra de negócio na UI — `CartaoResumo.build`.** É lá que está `progresso = minutosHoje / metaDiaria`. Qualquer tela nova pode calcular diferente, porque a regra não tem dono.
4. **Impossível testar sem `WidgetTester` — `CartaoResumo`.** A regra só existe dentro de um `build`; para verificá-la você precisa de `pumpWidget` e de uma árvore inteira.

<a id="m08-e02"></a>
## M08-E02
```dart
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

  EstadoFoco copyWith({int? minutosHoje, int? metaDiaria, List<String>? materias}) =>
      EstadoFoco(
        minutosHoje: minutosHoje ?? this.minutosHoje,
        metaDiaria: metaDiaria ?? this.metaDiaria,
        materias: materias ?? this.materias,
      );
}

class _CascaFocoState extends State<CascaFoco> {
  EstadoFoco _estado = const EstadoFoco();

  void _registrarSessao(int minutos) => setState(
        () => _estado = _estado.copyWith(minutosHoje: _estado.minutosHoje + minutos),
      );
}

// CartaoResumo recebe o valor; LinhaDeBotoes devolve a ordem.
class CartaoResumo extends StatelessWidget {
  const CartaoResumo({required this.estado, required this.aoRegistrar, super.key});
  final EstadoFoco estado;
  final ValueChanged<int> aoRegistrar;
}
```
```dart
// test/estado_foco_test.dart — nenhum widget montado.
test('progresso e faltam', () {
  const EstadoFoco e = EstadoFoco(minutosHoje: 45, metaDiaria: 90);
  expect(e.progresso, 0.5);
  expect(e.faltam, 45);
  expect(const EstadoFoco(minutosHoje: 200, metaDiaria: 90).progresso, 1.0);
});
```

<a id="m08-e03"></a>
## M08-E03
```dart
static EscopoFoco? maybeOf(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<EscopoFoco>();

@override
bool updateShouldNotify(EscopoFoco anterior) => !identical(estado, anterior.estado);
```
`getInheritedWidgetOfExactType` **lê sem registrar dependência**, e `updateShouldNotify` em `false` manda o framework não avisar ninguém: os dois juntos congelam a aba.

<a id="m08-e04"></a>
## M08-E04
| Estado | Solução | Por quê |
|---|---|---|
| Aba selecionada da `NavigationBar` | `setState` | Não é compartilhado nem sobrevive à tela: é estado de UI local. |
| Texto do campo de nova matéria | `setState` (com `TextEditingController`) | Rascunho; ninguém fora do formulário lê, e some ao fechar. |
| Lista de matérias | Riverpod (`NotifierProvider`) | Compartilhada entre abas e rotas, e é a fonte da verdade do app. |
| Trilhas do servidor | Riverpod (`AsyncNotifier`) | Além de compartilhada, tem carregando/erro/dados e precisa de cache entre telas. |

O critério é o par de perguntas: *o dado é lido por mais alguém?* e *precisa sobreviver a sair da tela?* Dois "não" = `setState`; um "sim" dentro da mesma tela = elevação; dois "sim" = Riverpod.

<a id="m08-e05"></a>
## M08-E05
`ref.watch(minutosHojeProvider)` fica no `build` porque inscreve o widget: mudou o valor, o `build` roda de novo. `ref.read(sessoesProvider.notifier).registrar(...)` fica no `onPressed` porque *callback* não é reconstruído — ali você quer agir, não observar. `ref.listen(metaAtingidaProvider, ...)` também fica no `build`, mas não reconstrói nada: serve para `SnackBar` e `Navigator.push`, efeitos que não podem rodar a cada *rebuild*.

`ref.read` no `build` não dá erro porque ler um valor é legítimo — só não cria inscrição, então a tela congela no valor do primeiro `build`. `ref.watch` dentro de `onPressed` lança em execução porque não há `build` acontecendo para associar a inscrição a um ciclo de vida.

O provider é global porque é **receita**, não estado: o `ProviderScope` é quem guarda as instâncias e os valores, e por isso dois `ProviderScope` (app e teste) nunca se contaminam.

<a id="m08-e06"></a>
## M08-E06
```dart
final Provider<double> progressoDiarioProvider = Provider<double>((Ref ref) {
  final int minutos = ref.watch(minutosHojeProvider);
  final int meta = ref.watch(metaDiariaProvider);
  return meta == 0 ? 0 : (minutos / meta).clamp(0.0, 1.0);
});

final Provider<int> minutosRestantesProvider = Provider<int>((Ref ref) {
  final int falta = ref.watch(metaDiariaProvider) - ref.watch(minutosHojeProvider);
  return falta < 0 ? 0 : falta;
});

final Provider<bool> metaAtingidaProvider =
    Provider<bool>((Ref ref) => ref.watch(progressoDiarioProvider) >= 1.0);

final Provider<String> mediaPorSessaoProvider = Provider<String>((Ref ref) {
  final int sessoes = ref.watch(sessoesHojeProvider);
  if (sessoes == 0) return '—';
  return '${(ref.watch(minutosHojeProvider) / sessoes).round()} min';
});
```
Dentro de provider é sempre `watch`: com `read` a cascata não se recalcula e o derivado fica preso ao primeiro valor.

<a id="m08-e07"></a>
## M08-E07
```dart
@override
bool operator ==(Object outro) {
  if (identical(this, outro)) return true;
  return outro is Materia &&
      outro.id == id &&
      outro.nome == nome &&
      outro.metaMinutos == metaMinutos &&
      outro.icone == icone;
}

@override
int get hashCode => Object.hash(id, nome, metaMinutos, icone);
```
```dart
bool adicionar(Materia nova) {
  final String nome = nova.nome.trim();
  if (nome.isEmpty || _existeNome(nome)) return false;
  state = <Materia>[...state, nova.copyWith(nome: nome)];  // lista NOVA
  return true;
}
```
O defeito: `state.add` muda a lista no lugar, então `state` continua sendo o **mesmo objeto** e o Riverpod, que compara por identidade, não notifica ninguém — sem erro nenhum no console.

<a id="m08-e08"></a>
## M08-E08
```dart
void remover(String id) =>
    state = state.where((Materia m) => m.id != id).toList();

bool renomear(String id, String novoNome) {
  final String nome = novoNome.trim();
  if (nome.isEmpty || _existeNome(nome, exceto: id)) return false;
  state = <Materia>[
    for (final Materia m in state)
      if (m.id == id) m.copyWith(nome: nome) else m,
  ];
  return true;
}

bool definirMeta(String id, int minutos) {
  if (minutos < 5 || minutos > 480) return false;
  state = <Materia>[
    for (final Materia m in state)
      if (m.id == id) m.copyWith(metaMinutos: minutos) else m,
  ];
  return true;
}

bool _existeNome(String nome, {String? exceto}) {
  final String alvo = nome.toLowerCase();
  return state.any((Materia m) => m.id != exceto && m.nome.toLowerCase() == alvo);
}
```
`exceto: id` é o que permite renomear "Dart" para "dart" sem a própria matéria se acusar de duplicada.

<a id="m08-e09"></a>
## M08-E09
```dart
final AsyncNotifierProvider<TrilhasNotifier, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider<TrilhasNotifier, List<Trilha>>(TrilhasNotifier.new);

class TrilhasNotifier extends AsyncNotifier<List<Trilha>> {
  @override
  Future<List<Trilha>> build() => ref.watch(trilhasFonteProvider).listar();

  Future<void> recarregar() async {
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => ref.read(trilhasFonteProvider).listar());
  }
}

class TrilhasTab extends ConsumerWidget {
  const TrilhasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(trilhasProvider).when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object erro, StackTrace _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('$erro'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(trilhasProvider),
                  child: const Text('Tentar de novo'),
                ),
              ],
            ),
          ),
          // Lista vazia é AsyncData vazio — não um quarto estado.
          data: (List<Trilha> lista) => lista.isEmpty
              ? const Center(child: Text('Nenhuma trilha ainda.'))
              : ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (BuildContext _, int i) =>
                      ListTile(title: Text(lista[i].titulo)),
                ),
        );
  }
}
```

<a id="m08-e10"></a>
## M08-E10
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final AsyncValue<List<Trilha>> trilhas = ref.watch(trilhasProvider);
  final bool recarregando = trilhas.isLoading && trilhas.hasValue;

  return Column(
    children: <Widget>[
      if (recarregando) const LinearProgressIndicator(),
      Expanded(
        child: trilhas.when(
          skipLoadingOnRefresh: true, // mantém a lista antiga durante a recarga
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object erro, StackTrace _) => Center(child: Text('$erro')),
          data: (List<Trilha> lista) => ListView.builder(
            itemCount: lista.length,
            itemBuilder: (BuildContext _, int i) =>
                ListTile(title: Text(lista[i].titulo)),
          ),
        ),
      ),
    ],
  );
}
```
`requireValue` lança `StateError` sempre que o estado não é `AsyncData` — e na primeira abertura ele é `AsyncLoading`.

<a id="m08-e11"></a>
## M08-E11
```dart
final AutoDisposeNotifierProviderFamily<CronometroNotifier, EstadoCronometro, String>
    cronometroProvider = NotifierProvider.autoDispose
        .family<CronometroNotifier, EstadoCronometro, String>(CronometroNotifier.new);

class CronometroNotifier
    extends AutoDisposeFamilyNotifier<EstadoCronometro, String> {
  Timer? _timer;

  @override
  EstadoCronometro build(String materiaId) {
    // onDispose registrado JUNTO da criação: é o que torna difícil esquecer.
    ref.onDispose(() {
      _timer?.cancel();
      debugPrint('cronometro($materiaId): descartado, timer cancelado');
    });
    return const EstadoCronometro();
  }

  void alternar() {
    if (state.rodando) {
      _timer?.cancel();
      state = state.copyWith(rodando: false);
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) => state = state.copyWith(segundos: state.segundos + 1));
    state = state.copyWith(rodando: true);
  }

  void zerar() {
    _timer?.cancel();
    state = const EstadoCronometro();
  }

  int concluir() {
    _timer?.cancel();
    final int minutos = state.minutos;
    if (minutos > 0) {
      // `arg` é o parâmetro da family, visível em qualquer método.
      ref.read(sessoesProvider.notifier).registrar(materiaId: arg, minutos: minutos);
    }
    state = const EstadoCronometro();
    return minutos;
  }
}
```
Cada `arg` tem a própria instância e o próprio `Timer`: o cronômetro de Flutter não enxerga o de Dart.

<a id="m08-e12"></a>
## M08-E12
```dart
typedef FiltroSessoes = ({String materiaId, bool apenasHoje});

final AutoDisposeProviderFamily<List<Sessao>, FiltroSessoes> sessoesFiltradasProvider =
    Provider.autoDispose.family<List<Sessao>, FiltroSessoes>(
        (Ref ref, FiltroSessoes filtro) {
  ref.onDispose(() => debugPrint('sessoesFiltradas(${filtro.materiaId}): descartado'));
  return ref.watch(sessoesProvider).where((Sessao s) {
    if (s.materiaId != filtro.materiaId) return false;
    if (filtro.apenasHoje && !s.ehDeHoje) return false;
    return true;
  }).toList();
});

// Chamada: ref.watch(sessoesFiltradasProvider((materiaId: 'dart', apenasHoje: true)));
```
O *record* já tem `==` e `hashCode` por valor, então dois filtros iguais resolvem para a **mesma** instância de provider.

<a id="m08-e13"></a>
## M08-E13
1. Aplicando *"isto faria sentido se a feature matérias não existisse?"*: `Icones` (traduz nome do ícone → `IconData`) e `EstadoVazio` vão para `core/`, porque trilhas e sessões usam os dois. `MateriaTile` e o validador "já existe matéria com esse nome" ficam em `features/materias/` — fora dela não significam nada. `core/` não é `utils/`: o que só uma feature usa não pertence a `core/`.
2. Riverpod porque o provider é **tipado**, então dependência não registrada erra em tempo de compilação, e não em execução como no `get_it` — que é um *service locator*, e não um injetor. Some-se a isso a reatividade nativa (mudou o repositório, a tela se atualiza) e o fato de o curso já usar Riverpod para estado: um mecanismo em vez de dois.

<a id="m08-e14"></a>
## M08-E14
```dart
// lib/features/materias/domain/materia_repositorio.dart — sem import de Flutter.
sealed class FalhaMateria implements Exception {
  const FalhaMateria(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

final class MateriaNaoEncontrada extends FalhaMateria {
  const MateriaNaoEncontrada(this.id) : super('Matéria não encontrada');
  final String id;
}

final class MateriaDuplicada extends FalhaMateria {
  const MateriaDuplicada(this.nome) : super('Já existe uma matéria com esse nome');
  final String nome;
}

final class FalhaDeArmazenamento extends FalhaMateria {
  const FalhaDeArmazenamento([String mensagem = 'Falha ao acessar os dados'])
      : super(mensagem);
}

abstract interface class MateriaRepositorio {
  Future<List<Materia>> listar();
  Future<Materia> buscarPorId(String id);
  Future<Materia> salvar(Materia materia);
  Future<void> excluir(String id);
}
```
```dart
// lib/features/materias/data/materia_repositorio_memoria.dart
// O tipo é o CONTRATO — é isso que permite o override no teste.
final Provider<MateriaRepositorio> materiaRepositorioProvider =
    Provider<MateriaRepositorio>((Ref ref) => MateriaRepositorioMemoria());
```
```dart
// test/materias_controller_test.dart
class MateriaRepositorioFalso implements MateriaRepositorio {
  MateriaRepositorioFalso([List<Materia>? iniciais]) : _itens = <Materia>[...?iniciais];

  final List<Materia> _itens;
  bool falharSempre = false;

  @override
  Future<List<Materia>> listar() async {
    if (falharSempre) throw const FalhaDeArmazenamento();
    return List<Materia>.unmodifiable(_itens);
  }

  @override
  Future<Materia> buscarPorId(String id) async => _itens.firstWhere(
      (Materia m) => m.id == id,
      orElse: () => throw MateriaNaoEncontrada(id));

  @override
  Future<Materia> salvar(Materia materia) async {
    if (falharSempre) throw const FalhaDeArmazenamento();
    final bool duplicada = _itens.any((Materia m) =>
        m.id != materia.id && m.nome.toLowerCase() == materia.nome.toLowerCase());
    if (duplicada) throw MateriaDuplicada(materia.nome);
    _itens.add(materia);
    return materia;
  }

  @override
  Future<void> excluir(String id) async => _itens.removeWhere((Materia m) => m.id == id);
}

ProviderContainer _containerCom(MateriaRepositorioFalso falso) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[materiaRepositorioProvider.overrideWithValue(falso)],
  );
  addTearDown(container.dispose); // sem isto, um teste contamina o próximo
  return container;
}

void main() {
  const Materia dart = Materia(id: 'dart', nome: 'Dart', metaMinutos: 120);

  test('carga inicial vem do repositório', () async {
    final ProviderContainer c = _containerCom(MateriaRepositorioFalso(<Materia>[dart]));
    expect(await c.read(materiasProvider.future), <Materia>[dart]);
  });

  test('nome duplicado devolve a mensagem de MateriaDuplicada', () async {
    final ProviderContainer c = _containerCom(MateriaRepositorioFalso(<Materia>[dart]));
    await c.read(materiasProvider.future);
    final String? erro = await c
        .read(materiasProvider.notifier)
        .salvar(const Materia(id: 'dart2', nome: 'dart', metaMinutos: 60));
    expect(erro, 'Já existe uma matéria com esse nome');
  });

  test('falha de armazenamento vira AsyncError sem perder a lista', () async {
    final MateriaRepositorioFalso falso = MateriaRepositorioFalso(<Materia>[dart]);
    final ProviderContainer c = _containerCom(falso);
    await c.read(materiasProvider.future);
    falso.falharSempre = true;
    await c.read(materiasProvider.notifier).recarregar();
    expect(c.read(materiasProvider), isA<AsyncError<List<Materia>>>());
    expect(c.read(materiasProvider).hasValue, isTrue);
  });
}
```
`.future` é o que espera a primeira carga terminar; sem ele o teste leria `AsyncLoading` e falharia.
