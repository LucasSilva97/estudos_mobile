# Etapa 7 — Testes — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 150 min · **Depende de:** [Etapa 6 — Responsividade e acessibilidade](08-etapa-6-responsividade-e-acessibilidade.md) ·
> **Aulas:** [12.5 Unitários](../../modulos/12-testes-e-debug/05-testes-unitarios.md) ·
> [12.6 Widget](../../modulos/12-testes-e-debug/06-testes-de-widget.md) ·
> [12.7 Mocks e fakes](../../modulos/12-testes-e-debug/07-mocks-e-fakes.md) ·
> [12.8 Integração](../../modulos/12-testes-e-debug/08-testes-de-integracao.md)

Nenhuma linha de `lib/` muda aqui. É a etapa em que a arquitetura das etapas 2 e 3 paga o prêmio:
como nada cria a própria dependência, trocar banco, rede ou repositório no teste é **uma linha de
`overrides`**.

## 🎯 O que existe ao fim desta etapa

| Nível | O que é verificado | Onde |
|---|---|---|
| 🧱 Unitário | `MetaSemanal`, `Sessao`, `CronometroEstado`, `ResumoSemanal`, `Texto` | `test/dominio/` |
| 🗄️ Banco real | `ORDER BY` do RF03, regra 9, transação do RF13 e `CASCADE` do RF08 | `test/data/` |
| 🖼️ Widget | `MateriasTab` nos 4 estados, 48 dp (RNF02) e fonte a 200% (RNF03) | `test/presentation/` |
| 🚀 Integração | App de verdade: criar matéria → registrar sessão → reabrir e o dado lá | `integration_test/` |

`flutter test` termina em **`All tests passed!`** e o RNF16 está cumprido.

> 📌 Só `integration_test/` precisa de aparelho — e no Windows `-d windows` resolve o dia a dia.

## 📦 Dependências

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:          # vem com o SDK — sem número de versão
    sdk: flutter
  sqflite_common_ffi: ^2.4.3 # sqflite no Windows, sem emulador
```

Não entra `mocktail` (ADR-06) porque não precisou: **todo contrato do Foco tem um fake**, e a aula
12.7 é clara — prefira o fake, o mock fica para efeito colateral sem resultado observável.
`MockClient` também não é dependência nova: mora em `package:http/testing.dart`, dentro do `http`
da etapa 5.

## 🧩 Os arquivos desta etapa

| Arquivo | Papel |
|---|---|
| `test/apoio/dubles.dart` | Amostras de domínio e o fake com **atraso** e **falha** configuráveis |
| `test/dominio/modelos_test.dart` | As regras de negócio em Dart puro |
| `test/data/daos_test.dart` | Banco real em memória: ordenação, transação e `CASCADE` |
| `test/presentation/materias_tab_test.dart` | Os 4 estados de UI, 48 dp e 200% de fonte |
| `integration_test/fluxo_completo_test.dart` | O app inteiro, com banco de verdade e rede falsa |

### test/apoio/dubles.dart

> **Por que ele existe:** escrever o dublê **uma vez** é o que faz o resto da suíte caber em cinco
> linhas por teste.

```dart
import 'package:foco/core/banco/texto.dart';
import 'package:foco/features/materias/domain/materia.dart';
import 'package:foco/features/materias/domain/materia_repositorio_contrato.dart';
import 'package:foco/features/sessoes/domain/sessao.dart';

/// Data fixa de toda a suíte: uma segunda-feira, 20h.
///
/// ⚠️ Dado montado com `DateTime.now()` é bomba-relógio: passa hoje e falha na
/// virada da semana, do mês ou no horário de verão.
final DateTime agoraDeTeste = DateTime(2026, 3, 9, 20);

Materia materia(String id, String nome,
        {int minutos = 0, bool arquivada = false}) =>
    Materia(
        id: id,
        nome: nome,
        criadaEm: agoraDeTeste,
        minutos: minutos,
        arquivada: arquivada);

Sessao sessao(String id, String materiaId,
        {int minutos = 45, DateTime? inicioEm}) =>
    Sessao(
        id: id,
        materiaId: materiaId,
        inicioEm: inicioEm ?? agoraDeTeste,
        minutos: minutos);

/// Fake do contrato de matérias com os dois controles que abrem os quatro
/// estados de tela: sem `atraso` a carga termina no mesmo quadro e o estado de
/// carregando é impossível de observar; `falha` produz o de erro.
class MateriaRepositorioFake implements MateriaRepositorioContrato {
  MateriaRepositorioFake([List<Materia> iniciais = const <Materia>[]]) {
    for (final Materia m in iniciais) {
      _itens[m.id] = m;
    }
  }

  final Map<String, Materia> _itens = <String, Materia>{};
  Duration atraso = Duration.zero;
  Object? falha;
  int chamadas = 0;

  Future<void> _preparar() async {
    chamadas++;
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);
    final Object? f = falha;
    if (f != null) throw f;
  }

  @override
  Future<List<Materia>> listar({bool incluirArquivadas = false}) async {
    await _preparar();
    final List<Materia> r = _itens.values
        .where((Materia m) => incluirArquivadas || !m.arquivada)
        .toList()
      // ⚠️ O fake ordena EXATAMENTE como o DAO real (regra 1). Fake com ordem
      // diferente da produção deixa todo teste de UI instável.
      ..sort((Materia a, Materia b) =>
          Texto.paraOrdenacao(a.nome).compareTo(Texto.paraOrdenacao(b.nome)));
    return List<Materia>.unmodifiable(r);
  }

  @override
  Future<Materia?> porId(String id) async {
    await _preparar();
    return _itens[id];
  }

  @override
  Future<void> salvar(Materia materia) async {
    await _preparar();
    _itens[materia.id] = materia;
  }

  @override
  Future<void> arquivar(String id, {required bool arquivada}) async {
    await _preparar();
    final Materia? m = _itens[id];
    if (m != null) _itens[id] = m.copyWith(arquivada: arquivada);
  }

  @override
  Future<void> excluir(String id) async {
    await _preparar();
    _itens.remove(id);
  }

  @override
  Future<List<Materia>> buscar(String termo) async {
    final String alvo = Texto.paraOrdenacao(termo);
    return (await listar())
        .where((Materia m) => Texto.paraOrdenacao(m.nome).contains(alvo))
        .toList();
  }
}
```

### test/dominio/modelos_test.dart

> **Por que ele existe:** é a base da pirâmide — roda em milissegundos porque `domain/` não importa
> Flutter, sqflite nem http.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco/core/banco/texto.dart';
import 'package:foco/features/estatisticas/domain/resumo_semanal.dart';
import 'package:foco/features/metas/domain/meta_semanal.dart';
import 'package:foco/features/sessoes/domain/cronometro_estado.dart';
import 'package:foco/features/sessoes/domain/sessao.dart';

import '../apoio/dubles.dart';

void main() {
  test('MetaSemanal · progresso, clamp e minutos restantes', () {
    const MetaSemanal meio = MetaSemanal(minutosAlvo: 300, minutosFeitos: 180);
    // ⚠️ Nunca compare double com igualdade: use closeTo.
    expect(meio.progresso, closeTo(0.6, 0.001));
    expect(meio.minutosRestantes, 120);
    expect(meio.atingida, isFalse);

    const MetaSemanal cheia = MetaSemanal(minutosAlvo: 300, minutosFeitos: 420);
    expect(cheia.progresso, 1.0); // o anel não passa da volta completa
    expect(cheia.minutosRestantes, 0); // nem anuncia "-120 minutos"
    expect(MetaSemanal.padraoMinutos, 300);
  });

  test('Sessao · ehDeHoje compara o DIA, não o instante', () {
    final DateTime hoje = DateTime.now();
    expect(sessao('s1', 'alg', inicioEm: hoje).ehDeHoje, isTrue);
    expect(
        sessao('s2', 'alg', inicioEm: hoje.subtract(const Duration(days: 1)))
            .ehDeHoje,
        isFalse);
    expect(Sessao.minimoDeMinutos, 1); // RF12
    expect(Sessao.maximoDeMinutos, 480);
  });

  test('CronometroEstado · conta por diferença de relógio, não por ticks', () {
    final CronometroEstado rodando = CronometroEstado(
        materiaId: 'alg',
        inicioEm: agoraDeTeste,
        acumulado: const Duration(minutes: 10),
        rodando: true);
    // RF10: voltar do segundo plano não pode perder nem inventar tempo.
    expect(rodando.decorridoAte(agoraDeTeste.add(const Duration(minutes: 5))),
        const Duration(minutes: 15));

    const CronometroEstado pausado =
        CronometroEstado(materiaId: 'alg', acumulado: Duration(minutes: 7));
    expect(pausado.decorridoAte(agoraDeTeste.add(const Duration(hours: 3))),
        const Duration(minutes: 7));

    final CronometroEstado curto = CronometroEstado(
        materiaId: 'alg', inicioEm: agoraDeTeste, rodando: true);
    // 20 segundos viram 1 minuto — o mínimo, nunca 0.
    expect(
        curto.minutosArredondados(agoraDeTeste.add(const Duration(seconds: 20))),
        1);
  });

  test('ResumoSemanal · total, média, progresso e semana vazia', () {
    ResumoSemanal resumo(List<int> dias, Map<String, int> porMateria) =>
        ResumoSemanal(
            inicioDaSemana: agoraDeTeste,
            minutosPorDia: dias,
            minutosPorMateria: porMateria,
            metaMinutos: 300,
            minutosSemanaAnterior: 150);

    final ResumoSemanal cheia = resumo(<int>[30, 30, 30, 30, 30, 30, 30],
        <String, int>{'alg': 120, 'bio': 90});
    expect(cheia.totalMinutos, 210);
    expect(cheia.mediaDiariaMinutos, 30);
    expect(cheia.progressoDaMeta, closeTo(0.7, 0.001));
    expect(cheia.materiaMaisEstudadaId, 'alg');

    // Semana sem sessão nenhuma não pode dividir por zero.
    final ResumoSemanal vazia =
        resumo(List<int>.filled(7, 0), const <String, int>{});
    expect(vazia.mediaDiariaMinutos, 0);
    expect(vazia.materiaMaisEstudadaId, '');
  });

  test('Texto.paraOrdenacao achata acento e caixa', () {
    expect(Texto.paraOrdenacao('Álgebra Linear'), 'algebra linear');
    // Regra 2: nome duplicado compara o normalizado.
    expect(Texto.paraOrdenacao('cálculo'), Texto.paraOrdenacao('Calculo'));

    final Map<String, Object?> linha = materia('alg', 'Álgebra').paraLinha();
    expect(linha['nome_ordenacao'], 'algebra'); // derivado num lugar só
    expect(linha['cor_valor'], 4284960932);
  });
}
```

### test/data/daos_test.dart

> **Por que ele existe:** aqui o que está sob teste **é o SQL**. Um fake testaria o seu Dart, não a
> sua query — e a transação do RF13 é justamente o que um fake não sabe quebrar.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco/core/banco/banco_foco.dart';
import 'package:foco/features/materias/data/materia_dao.dart';
import 'package:foco/features/materias/domain/materia.dart';
import 'package:foco/features/sessoes/data/sessao_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../apoio/dubles.dart';

void main() {
  // ⚠️ Sem estas duas linhas, openDatabase falha no Windows com
  // "databaseFactory not initialized".
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database banco;
  late MateriaDao materiaDao;
  late SessaoDao sessaoDao;

  setUp(() async {
    // inMemoryDatabasePath: banco novo e vazio a cada teste, sem arquivo em
    // disco e sem estado vazando de um teste para o outro.
    banco = await BancoFoco.abrir(caminho: inMemoryDatabasePath);
    materiaDao = MateriaDao(banco);
    sessaoDao = SessaoDao(banco);
  });

  tearDown(() => banco.close());

  test('regra 1 · ordena por nome_ordenacao; regra 9 · arquivada some',
      () async {
    for (final Materia m in <Materia>[
      materia('fis', 'Física'),
      materia('alg', 'Álgebra'),
      materia('bio', 'Biologia'),
    ]) {
      await materiaDao.salvar(m);
    }
    // Ordenando por `nome`, o SQLite compara bytes e devolveria
    // ['Biologia', 'Física', 'Álgebra'].
    expect((await materiaDao.listar()).map((Materia m) => m.nome),
        <String>['Álgebra', 'Biologia', 'Física']);

    await materiaDao.arquivar('bio', arquivada: true);
    expect(await materiaDao.listar(), hasLength(2));
    expect(await materiaDao.listar(incluirArquivadas: true), hasLength(3));
  });

  test('regra 3 · a transação move o total; RF08 · excluir faz CASCADE',
      () async {
    await materiaDao.salvar(materia('alg', 'Álgebra'));

    await sessaoDao.registrar(sessao('s1', 'alg', minutos: 45));
    await sessaoDao.registrar(sessao('s2', 'alg', minutos: 30));
    // INSERT e UPDATE valem como um só: nunca um sem o outro.
    expect((await materiaDao.porId('alg'))?.minutos, 75);

    await sessaoDao.remover('s2');
    expect((await materiaDao.porId('alg'))?.minutos, 45);
    expect(await sessaoDao.daMateria('alg'), hasLength(1));

    await materiaDao.excluir('alg');
    // Falhou aqui? O PRAGMA foreign_keys = ON saiu do onConfigure — sem ele o
    // CASCADE simplesmente não acontece.
    expect(await sessaoDao.daMateria('alg'), isEmpty);
  });

  test('RNF07 · 500 matérias e 5.000 sessões: listar continua rápido',
      () async {
    await banco.transaction((Transaction txn) async {
      for (int i = 0; i < 500; i++) {
        await txn.insert('materias', materia('m$i', 'Matéria $i').paraLinha());
      }
      for (int i = 0; i < 5000; i++) {
        await txn.insert(
            'sessoes', sessao('s$i', 'm${i % 500}', minutos: 10).paraLinha());
      }
    });

    final Stopwatch cronometro = Stopwatch()..start();
    final List<Materia> r = await materiaDao.listar();
    cronometro.stop();

    expect(r, hasLength(500));
    // Sem o índice idx_materias_nome_ordenacao isto passa de 1 s.
    expect(cronometro.elapsedMilliseconds, lessThan(500));
  });
}
```

### test/presentation/materias_tab_test.dart

> **Por que ele existe:** é o teste da regra 10 — os quatro estados de UI, 48 dp de alvo e 200% de
> fonte, com o repositório falso injetado por `ProviderScope`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foco/features/materias/data/materia_repositorio.dart'
    show materiaRepositorioProvider;
import 'package:foco/features/materias/domain/materia.dart';
import 'package:foco/features/materias/presentation/materias_tab.dart';

import '../apoio/dubles.dart';

void main() {
  late MateriaRepositorioFake repo;

  setUp(() {
    repo = MateriaRepositorioFake(<Materia>[
      materia('alg', 'Álgebra', minutos: 120),
      materia('bio', 'Biologia', minutos: 45),
    ]);
  });

  /// Um único override substitui a cadeia inteira acima do repositório:
  /// controller, providers derivados e tela.
  Future<void> montar(WidgetTester t, {TextScaler? escala}) async {
    await t.pumpWidget(ProviderScope(
      overrides: <Override>[materiaRepositorioProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: escala ?? TextScaler.noScaling),
            child: const Scaffold(body: MateriasTab()),
          ),
        ),
      ),
    ));
  }

  testWidgets('1. CARREGANDO', (WidgetTester t) async {
    repo.atraso = const Duration(seconds: 1);

    await montar(t);
    await t.pump(); // um quadro só: ainda carregando

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Álgebra'), findsNothing);

    // ⚠️ Deixe a carga terminar, senão o teste falha com
    // "A Timer is still pending".
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
  });

  testWidgets('2. DADOS, na ordem certa', (WidgetTester t) async {
    await montar(t);
    await t.pumpAndSettle();

    expect(find.text('Álgebra'), findsOneWidget);
    expect(t.getTopLeft(find.text('Álgebra')).dy,
        lessThan(t.getTopLeft(find.text('Biologia')).dy));
  });

  testWidgets('3. VAZIO mostra a saída "Nova matéria"', (WidgetTester t) async {
    repo = MateriaRepositorioFake();

    await montar(t);
    await t.pumpAndSettle();

    expect(find.textContaining('Nenhuma'), findsOneWidget);
    expect(find.textContaining('Nova matéria'), findsWidgets);
  });

  testWidgets('4. ERRO mostra a mensagem em português e refaz a busca',
      (WidgetTester t) async {
    repo.falha = Exception('banco indisponível');

    await montar(t);
    await t.pumpAndSettle();

    expect(find.textContaining('Tentar de novo'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing); // RNF12

    final int antes = repo.chamadas;
    repo.falha = null;
    await t.tap(find.textContaining('Tentar de novo'));
    await t.pumpAndSettle();

    expect(repo.chamadas, greaterThan(antes));
    expect(find.text('Álgebra'), findsOneWidget);
  });

  testWidgets('RNF02 e RNF03 · 48 dp, rótulo e fonte a 200%',
      (WidgetTester t) async {
    final SemanticsHandle handle = t.ensureSemantics();
    await montar(t);
    await t.pumpAndSettle();
    await expectLater(t, meetsGuideline(androidTapTargetGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();

    await montar(t, escala: const TextScaler.linear(2));
    await t.pumpAndSettle();
    // takeException devolve o RenderFlex overflowed, se houver algum.
    expect(t.takeException(), isNull);
    expect(find.text('Álgebra'), findsOneWidget);
  });
}
```

### integration_test/fluxo_completo_test.dart

> **Por que ele existe:** é o único teste com **app de verdade e banco de verdade** — pega o que
> nenhum teste de widget pega: rota errada, provider não sobrescrito, dado que não persiste.

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foco/app.dart';
import 'package:foco/core/banco/banco_foco.dart';
import 'package:foco/core/providers/providers_raiz.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Espera pela CONDIÇÃO, não pelo relógio.
///
/// ⚠️ Nunca "conserte" um teste instável com Future.delayed: isso esconde o
/// problema e deixa a suíte lenta.
Future<void> esperarPor(WidgetTester tester, Finder alvo,
    {Duration limite = const Duration(seconds: 15)}) async {
  final DateTime fim = DateTime.now().add(limite);
  while (DateTime.now().isBefore(fim)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (alvo.evaluate().isNotEmpty) return;
  }
  fail('Não apareceu em ${limite.inSeconds}s: ${alvo.description}');
}

void main() {
  // ⚠️ Obrigatório, e antes de tudo: sem isto os plugins nativos falham com
  // MissingPluginException.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory pasta;
  late Database banco;
  late SharedPreferences prefs;

  setUp(() async {
    // Em `-d windows` o sqflite é o ffi; no 🤖 e no 🍎 é o nativo.
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // ⚠️ Banco de verdade PERSISTE. Sem uma pasta nova por teste, a suíte
    // passa na primeira rodada e falha na segunda.
    pasta = await Directory.systemTemp.createTemp('foco_integracao');
    banco = await BancoFoco.abrir(
        caminho: '${pasta.path}${Platform.pathSeparator}foco.db');
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await banco.close();
    await pasta.delete(recursive: true);
  });

  /// Monta o app como o main() monta — só o caminho do banco e o cliente HTTP
  /// mudam. Rede falsa: o teste verifica o FLUXO, não se a JSONPlaceholder
  /// está no ar hoje.
  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        bancoProvider.overrideWithValue(banco),
        preferenciasProvider.overrideWithValue(prefs),
        clienteHttpProvider.overrideWithValue(
            MockClient((http.Request _) async => http.Response(
                '[{"userId":1,"id":1,"title":"Dart","body":"Estude 30 min"}]',
                200))),
      ],
      child: const AppFoco(),
    ));
    await esperarPor(tester, find.byType(NavigationBar));
  }

  testWidgets('criar matéria, registrar sessão e reabrir com o dado lá',
      (WidgetTester tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Matérias'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Cálculo');
    // Fecha o teclado: teclado aberto cobre o botão e o toque erra o alvo.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await esperarPor(tester, find.text('Cálculo'));

    await tester.tap(find.text('Cálculo'));
    await esperarPor(tester, find.textContaining('Registrar sessão'));
    await tester.tap(find.textContaining('Registrar sessão'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '45');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));

    // Sessão gravada e total da matéria atualizado — a mesma transação.
    await esperarPor(tester, find.textContaining('45'));

    // Descarta a árvore, como se o app fechasse. O banco continua.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await abrirApp(tester);
    await tester.tap(find.text('Matérias'));
    await tester.pumpAndSettle();

    expect(find.text('Cálculo'), findsOneWidget);
  });
}
```

> ⚠️ `find.text('Salvar')` e `find.text('Matérias')` dependem dos rótulos da etapa 4. Mudou um
> rótulo? O teste de integração é o primeiro a reclamar — e é para isso que ele serve.

## ▶️ Rodando

```powershell
flutter pub add dev:sqflite_common_ffi

flutter test                          # tudo, sem emulador
flutter test test/data --reporter expanded
flutter test --plain-name "transação" # só um caso, ao corrigir
flutter test --coverage

flutter test integration_test -d windows        # rápido, no dia a dia
flutter test integration_test -d emulator-5554  # antes do commit
```

No fim do `flutter test` sai uma linha só, e é ela que importa:

```text
00:05 +13: All tests passed!
```

`flutter analyze` continua em `No issues found!` — teste também é código do projeto.

## ✅ Conferência

- [ ] `flutter test` termina em **`All tests passed!`**, sem nenhum teste pulado.
- [ ] `test/data/daos_test.dart` passa no Windows, sem emulador, com `sqflite_common_ffi`.
- [ ] O `CASCADE` passa — prova de que `PRAGMA foreign_keys = ON` está no `onConfigure`.
- [ ] A carga de 500 matérias e 5.000 sessões lista em menos de 500 ms (RNF07).
- [ ] Os **quatro** estados de `MateriasTab` têm teste, inclusive o de carregando.
- [ ] `androidTapTargetGuideline` e `labeledTapTargetGuideline` passam.
- [ ] `flutter test integration_test -d windows` completa o fluxo inteiro.
- [ ] Nenhum teste monta dado com `DateTime.now()` — todos usam `agoraDeTeste`.
- [ ] `flutter analyze` segue em `No issues found!`.

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| `Bad state: databaseFactory not initialized` | Faltou ligar o ffi no desktop | `sqfliteFfiInit(); databaseFactory = databaseFactoryFfi;` no `setUpAll` |
| `A Timer is still pending` | O `atraso` do fake não terminou antes do fim do teste | `await t.pump(const Duration(seconds: 1));` e depois `pumpAndSettle()` |
| `MissingPluginException` no `integration_test` | Faltou `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` | Primeira linha do `main()`, antes de qualquer `testWidgets` |
| O `CASCADE` falha: a sessão continua lá | `PRAGMA foreign_keys = ON` fora do `onConfigure` | Ligue no `onConfigure` do `BancoFoco` — no `onOpen` já é tarde |
| Integração passa na 1ª rodada e falha na 2ª | Banco real não foi limpo | Pasta temporária nova por teste, apagada no `tearDown` |
| `Could not find any matching widgets` após um `tap` | `pumpAndSettle` terminou antes da operação real | Use `esperarPor(tester, finder)`, nunca `Future.delayed` |
| Ordenação sai `['Biologia','Física','Álgebra']` | A consulta ordenou por `nome` | `ORDER BY nome_ordenacao` no `MateriaDao` (regra 1) |
| `No devices found` no `integration_test` | Exige aparelho | `flutter devices`, depois `-d windows` ou `-d emulator-5554` |
| O teste de widget não acha `MateriasTab` | Faltou o `ProviderScope` em volta do `MaterialApp` | Use o `montar` deste arquivo, com o override do repositório |

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [08 — Etapa 6: Responsividade e acessibilidade](08-etapa-6-responsividade-e-acessibilidade.md) | [README do projeto](README.md) | [10 — Etapa 8: Ícone, splash e versão](10-etapa-8-icone-splash-e-versao.md) |
