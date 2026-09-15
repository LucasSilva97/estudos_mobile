# Gabarito — Módulo 12: Testes e debug

> Compare depois de resolver os [exercícios](../exercicios/12-testes-e-debug.md).

<a id="m12-e01"></a>
## M12-E01
| # | Frase depois de `was thrown` | Classificação | Sua linha |
|---|---|---|---|
| 1 | `A RenderFlex overflowed by 84 pixels on the right.` | layout · `RENDERING` | `relevant error-causing widget`: `Row` — `tela_de_erros.dart:48:14` |
| 2 | `setState() called after dispose(): _TelaTimerSoltoState#… (defunct, not mounted)` | estado · `WIDGETS` | `_TelaTimerSoltoState.initState.<anonymous closure> (package:foco_lab/laboratorio/tela_de_erros.dart:76:62)` |
| 3 | `Null check operator used on a null value` | build · `WIDGETS` | `TelaNuloEstourado.build (package:foco_lab/laboratorio/tela_de_erros.dart:97:52)` |
| 4 | `No Material widget found.` | build · `WIDGETS` | `relevant error-causing widget`: `TextField` — `tela_de_erros.dart:110:16` |
| 5 | `Vertical viewport was given unbounded height.` | layout · `RENDERING` | `relevant error-causing widget`: `ListView` — `tela_de_erros.dart:130:13` |

Nos dois erros de layout o stack só tem `package:flutter/` — quem falhou foi o motor medindo a árvore — e o **seu** arquivo aparece no campo `relevant error-causing widget`.

<a id="m12-e02"></a>
## M12-E02
```dart
import 'dart:async';
import 'dart:developer' as developer;

void _iniciarOuPausar() {
  if (_rodando) {
    _timer?.cancel();
    developer.log('Sessão pausada em ${_sessao.segundos}s',
        name: 'foco.sessoes', level: 800);
  } else {
    _timer = Timer.periodic(const Duration(seconds: 1), _aoPassarUmSegundo);
    developer.log('Sessão iniciada em ${_sessao.materia}',
        name: 'foco.sessoes', level: 800);
  }
  setState(() => _rodando = !_rodando);
}

// Botão direito aqui → Add Conditional Breakpoint → _sessao.segundos % 10 == 0
void _aoPassarUmSegundo(Timer t) => setState(() => _sessao.segundos++);

Future<void> _finalizar() async {
  _timer?.cancel();
  try {
    final int gravados = await _gravarNaMateria(_sessao);
    developer.log('Gravados $gravados min', name: 'foco.sessoes', level: 800);
  } catch (erro, pilha) {
    developer.log('Falha ao gravar a sessão',
        name: 'foco.sessoes', level: 1000, error: erro, stackTrace: pilha);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível gravar a sessão')));
  }
}
```
`print` sobrevive ao release e não tem etiqueta; é o `name` do `developer.log` que faz a aba Logging filtrar por `foco.sessoes`.

<a id="m12-e03"></a>
## M12-E03
| Layout Explorer | Antes | Depois |
|---|---:|---:|
| `Text` (fontSize 26) | 440,0 px · sem flex | 356,0 px · flex 1 |
| 3 × `Icon(size: 48)` | 144,0 px | 144,0 px |
| Soma dos filhos | 584,0 px | 500,0 px |
| Constraint da `Row` | `w=500,0` | `w=500,0` |
| Sobra | **−84,0 px** | 0,0 px |

```dart
Row(children: <Widget>[
  const Expanded(
    child: Text('Introdução à Análise Matemática',
        style: TextStyle(fontSize: 26), overflow: TextOverflow.ellipsis),
  ),
  const Icon(Icons.timer, size: 48),
  const Icon(Icons.edit, size: 48),
  const Icon(Icons.delete, size: 48),
]);
```
`Expanded` entrega ao `Text` só o que sobrou dos ícones e o `ellipsis` decide o que fazer com o excesso — sem os dois juntos a faixa amarela volta.

<a id="m12-e04"></a>
## M12-E04
| | Antes | Depois |
|---|---:|---:|
| Pior quadro em 5 s de rolagem | 68 ms | 7 ms |
| Onde | **UI** (barra azul) | dentro do orçamento |
| Função mais cara (CPU Profiler) | o laço `for` dentro do `itemBuilder` de `TelaLenta.build` | `_TelaRapidaState._calcular`, fora da rolagem |

```dart
class _TelaRapidaState extends State<TelaRapida> {
  /// O cálculo caro sai do itemBuilder e roda UMA vez.
  late final List<int> _somas = List<int>.generate(200, _calcular);

  static int _calcular(int i) {
    int soma = 0;
    for (int k = 0; k < 200000; k++) {
      soma += k % 7;
    }
    return soma;
  }
  // No itemBuilder sobra `Text('soma: ${_somas[i]}')`, e o BoxShadow de
  // blurRadius 20 / spreadRadius 4 sai do BoxDecoration (barra roxa).
}
```
Medir em `--profile`, nunca em debug: o modo debug roda sem as otimizações do AOT e com asserts ligados, então os números saem 3 a 10 vezes piores e apontam gargalo onde não existe.

<a id="m12-e05"></a>
## M12-E05
Primeiro GC: **48 MB**. Depois de entrar e sair 20 vezes e forçar GC de novo: **112 MB**, em degraus de ~3 MB — um por visita. Em **Diff Snapshots**, `_TelaQueVazaState` aparece com **20 instâncias retidas**, cada uma segurando a `List<String>` de 50 000 linhas. Falta `_timer?.cancel()` — o `Timer.periodic` segura o callback, o callback segura o `State` e o `State` segura a lista — e falta `_campo.dispose()`.

```dart
@override
void dispose() {
  _timer?.cancel();
  _campo.dispose();
  super.dispose();
}
```
Depois: 47 MB no segundo GC e 1 instância no snapshot — o `if (mounted)` dentro do callback evitava o crash, mas não o vazamento.

<a id="m12-e06"></a>
## M12-E06
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    use_build_context_synchronously: error
    unawaited_futures: error
    cancel_subscriptions: error
    close_sinks: error
    todo: ignore
  exclude:
    - "**/*.g.dart"
    - "build/**"
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    # `errors:` muda a SEVERIDADE de uma regra ativa — não ativa regra nenhuma.
    # Estas três não vêm no flutter_lints; sem ligá-las aqui, a promoção acima
    # não tem efeito e os defeitos do E07 passam batido.
    - unawaited_futures
    - cancel_subscriptions
    - close_sinks
```
`use_build_context_synchronously` já vem ativa no `flutter_lints`, por isso basta promovê-la; e não copie o `plugins: - custom_lint` da aula sem instalar o pacote, senão o `analyze` falha antes de analisar qualquer coisa.

<a id="m12-e07"></a>
## M12-E07
```dart
import 'dart:async' show unawaited;
import 'dart:convert';

// 1. use_build_context_synchronously
Future<void> _salvar() async {
  final int gravados = await _repositorio.salvar(_sessao);
  if (!mounted) return; // <- a linha que faltava
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('$gravados min gravados')));
}

// 2. unawaited_futures — era `_repositorio.gravarSessao(sessao);`
await _repositorio.gravarSessao(sessao);
// Quando o "sem esperar" é intencional, diga isso no código:
unawaited(_analytics.registrar('sessao_gravada', <String, Object?>{}));

// 3. strict-casts — era `final String nome = json['nome'];`
final Map<String, dynamic> json = jsonDecode(corpo) as Map<String, dynamic>;
final Object? bruto = json['nome'];
final String nome = bruto is String ? bruto : '';
```
- `use_build_context_synchronously`: o usuário sai da tela durante o `await` e o `ScaffoldMessenger` procura um `context` já desmontado — crash em produção.
- `unawaited_futures`: a exceção dentro do `Future` esquecido é engolida; a sessão não grava e ninguém fica sabendo.
- `strict-casts`: no dia em que a API renomear `nome`, o `dynamic` vira `null` e o erro estoura na tela, não na camada de dados.

<a id="m12-e08"></a>
## M12-E08
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_lab/dominio/sessao.dart';

void main() {
  late DateTime quandoPadrao;
  setUp(() => quandoPadrao = DateTime(2026, 3, 10, 14));

  Sessao criar({String materia = 'dart', int minutos = 25, DateTime? quando}) =>
      Sessao(
          materiaId: materia, minutos: minutos, quando: quando ?? quandoPadrao);

  group('Sessao — fronteiras de minutos', () {
    test('aceita 1 e 480 — os extremos exatos', () {
      expect(criar(minutos: 1).minutos, 1);
      expect(criar(minutos: 480).minutos, 480);
    });
    test('recusa 0 e 481 — um passo fora de cada extremo', () {
      expect(() => criar(minutos: 0), throwsA(isA<SessaoInvalida>()));
      expect(
          () => criar(minutos: 481),
          throwsA(isA<SessaoInvalida>().having(
              (SessaoInvalida e) => e.mensagem, 'mensagem', contains('8 horas'))));
    });
  });

  group('Sessao — fronteiras da classificação', () {
    test('14 é curta e 15 é ideal', () {
      expect(criar(minutos: 14).classificacao, ClassificacaoDeSessao.curta);
      expect(criar(minutos: 15).classificacao, ClassificacaoDeSessao.ideal);
    });
    test('240 é longa; 241 e 480 são suspeitas', () {
      expect(criar(minutos: 240).classificacao, ClassificacaoDeSessao.longa);
      expect(criar(minutos: 241).classificacao, ClassificacaoDeSessao.suspeita);
      expect(criar(minutos: 480).classificacao, ClassificacaoDeSessao.suspeita);
    });
  });

  group('Entradas degeneradas', () {
    test('materiaId só com espaços é recusado',
        () => expect(() => criar(materia: '   '), throwsA(isA<ArgumentError>())));
    test('totalDeMinutos de lista vazia é 0, não null',
        () => expect(Estatisticas.totalDeMinutos(<Sessao>[]), 0));
    test('materiaEmDestaque de lista vazia é null',
        () => expect(Estatisticas.materiaEmDestaque(<Sessao>[]), isNull));
    test('duas sessões no MESMO dia contam um dia só', () {
      final List<Sessao> sessoes = <Sessao>[
        criar(quando: DateTime(2026, 3, 10, 8)),
        criar(quando: DateTime(2026, 3, 10, 21)),
      ];
      expect(Estatisticas.sequenciaDeDias(sessoes, hoje: DateTime(2026, 3, 10)),
          1);
    });
  });
}
```
O `expect` de exceção precisa da função `() => criar(...)`, não do resultado: sem ela a exceção sobe antes do matcher e o teste quebra como erro, não como falha.

<a id="m12-e09"></a>
## M12-E09
```dart
// Escrito ANTES da correção — e visto falhar com "Expected: 2, Actual: 0".
test('sequência não zera às 00h05 de um dia ainda sem sessão', () {
  final List<Sessao> sessoes = <Sessao>[
    Sessao(materiaId: 'dart', minutos: 30, quando: DateTime(2026, 3, 9, 20)),
    Sessao(materiaId: 'dart', minutos: 30, quando: DateTime(2026, 3, 10, 20)),
  ];
  expect(
      Estatisticas.sequenciaDeDias(sessoes, hoje: DateTime(2026, 3, 11, 0, 5)),
      2);
});
```
```dart
static int sequenciaDeDias(List<Sessao> sessoes, {DateTime? hoje}) {
  if (sessoes.isEmpty) return 0;
  final DateTime r = hoje ?? DateTime.now();
  final Set<int> dias = sessoes
      .map((Sessao s) => DateTime(s.quando.year, s.quando.month, s.quando.day)
          .millisecondsSinceEpoch)
      .toSet();

  DateTime dia = DateTime(r.year, r.month, r.day);
  // O dia corrente ainda pode não ter sessão: a contagem começa de ontem.
  if (!dias.contains(dia.millisecondsSinceEpoch)) {
    dia = DateTime(dia.year, dia.month, dia.day - 1);
  }

  int sequencia = 0;
  while (dias.contains(dia.millisecondsSinceEpoch)) {
    sequencia++;
    dia = DateTime(dia.year, dia.month, dia.day - 1);
  }
  return sequencia;
}
```
O defeito era exigir sessão no próprio dia; de quebra, `DateTime(ano, mês, dia - 1)` substitui `subtract(const Duration(days: 1))`, que escorrega uma hora na virada do horário de verão e perde um dia da sequência.

<a id="m12-e10"></a>
## M12-E10
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_lab/telas/form_materia.dart';

void main() {
  late Duration atraso;
  late List<({String nome, int meta})> salvos;

  setUp(() {
    atraso = Duration.zero;
    salvos = <({String nome, int meta})>[];
  });

  Future<void> montar(WidgetTester t) => t.pumpWidget(MaterialApp(
        home: FormMateria(aoSalvar: (String nome, int meta) async {
          if (atraso > Duration.zero) await Future<void>.delayed(atraso);
          salvos.add((nome: nome, meta: meta));
          return null;
        }),
      ));

  FilledButton botao(WidgetTester t) =>
      t.widget<FilledButton>(find.byKey(const Key('botao_salvar')));

  testWidgets('nome vazio deixa o botão desabilitado', (WidgetTester t) async {
    await montar(t);
    expect(botao(t).onPressed, isNull);
  });

  testWidgets('digitar o nome habilita o botão', (WidgetTester t) async {
    await montar(t);
    await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
    await t.pump(); // sem ele o rebuild do listener ainda não aconteceu
    expect(botao(t).onPressed, isNotNull);
  });

  testWidgets('nome de 1 letra mostra a mensagem', (WidgetTester t) async {
    await montar(t);
    await t.enterText(find.byKey(const Key('campo_nome')), 'A');
    await t.pump();
    await t.tap(find.byKey(const Key('botao_salvar')));
    await t.pump();
    expect(find.text('Use pelo menos 2 letras'), findsOneWidget);
    expect(salvos, isEmpty);
  });

  testWidgets('meta 4 mostra "Entre 5 e 480 minutos"', (WidgetTester t) async {
    await montar(t);
    await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
    await t.enterText(find.byKey(const Key('campo_meta')), '4');
    await t.pump();
    await t.tap(find.byKey(const Key('botao_salvar')));
    await t.pump();
    expect(find.text('Entre 5 e 480 minutos'), findsOneWidget);
  });

  testWidgets('durante o envio: indicador na tela e botão travado',
      (WidgetTester t) async {
    atraso = const Duration(seconds: 2);
    await montar(t);
    await t.enterText(find.byKey(const Key('campo_nome')), 'Cálculo');
    await t.pump();
    await t.tap(find.byKey(const Key('botao_salvar')));
    await t.pump(); // avança até o primeiro await de _salvar
    expect(find.byKey(const Key('indicador')), findsOneWidget);
    expect(botao(t).onPressed, isNull);
    await t.pump(const Duration(seconds: 2)); // deixa o Future terminar
  });
}
```
Sem esse último `pump` de 2 s o `Future.delayed` fica pendente e o teste falha com `A Timer is still pending even after the widget tree was disposed`.

<a id="m12-e11"></a>
## M12-E11
```dart
// test/apoio/dubles.dart
import 'package:foco_lab/dominio/materia.dart';
import 'package:foco_lab/dominio/relogio.dart';
import 'package:foco_lab/features/materias/domain/materia_repositorio_contrato.dart';
import 'package:mocktail/mocktail.dart';

class RelogioFake implements Relogio {
  RelogioFake([DateTime? inicio])
      : _agora = inicio ?? DateTime(2026, 3, 10, 14, 30);
  DateTime _agora;
  @override
  DateTime get agora => _agora;
  void avancar(Duration d) => _agora = _agora.add(d);
  void definir(DateTime quando) => _agora = quando;
}

class MateriaRepositorioFake implements MateriaRepositorioContrato {
  final Map<String, Materia> _itens = <String, Materia>{};
  final List<Materia> salvas = <Materia>[]; // spy embutido
  Object? falha; // quando não é null, toda chamada lança

  void semear(List<Materia> iniciais) {
    for (final Materia m in iniciais) {
      _itens[m.id] = m;
    }
  }

  void _checar() {
    final Object? f = falha;
    if (f != null) throw f;
  }

  @override
  Future<List<Materia>> listar() async {
    _checar();
    // Reproduz a ordenação do real, senão os testes de UI oscilam.
    return List<Materia>.unmodifiable(_itens.values.toList()
      ..sort((Materia a, Materia b) =>
          a.nome.toLowerCase().compareTo(b.nome.toLowerCase())));
  }

  @override
  Future<Materia> salvar(Materia m) async {
    _checar();
    _itens[m.id] = m;
    salvas.add(m);
    return m;
  }

  @override
  Future<void> excluir(String id) async {
    _checar();
    // O real lança quando não existe; o fake precisa lançar também.
    if (_itens.remove(id) == null) throw MateriaNaoEncontrada(id);
  }
}

abstract interface class Analytics {
  Future<void> registrar(String evento, Map<String, Object?> dados);
}

class AnalyticsMock extends Mock implements Analytics {}
class MateriaFalsa extends Fake implements Materia {}

void registrarFallbacks() {
  registerFallbackValue(MateriaFalsa());
  registerFallbackValue(<String, Object?>{});
}
```
```dart
// sincronizador_test.dart — as três correções

// (1) type 'Null' is not a subtype of type 'Future<List<Materia>>'
//     O mock foi usado sem nenhum `when`: todo método devolvia null.
when(() => repo.listar())
    .thenAnswer((_) async => <Materia>[materia('dart', 'Dart')]);
when(() => analytics.registrar(any(), any())).thenAnswer((_) async {});

// (2) Bad state: A test tried to use `any` ... on a parameter of type Materia
setUpAll(registrarFallbacks);

// (3) o verify que passava mesmo com os dados errados
final List<dynamic> cap =
    verify(() => analytics.registrar('sync_ok', captureAny())).captured;
final Map<String, Object?> dados = cap.single as Map<String, Object?>;
expect(dados['quantidade'], 1);
expect(dados['quando'], relogio.agora.toIso8601String());
```
Mock sem `when` devolve `null` para tudo (e é `thenAnswer`, não `thenReturn`, porque o método é assíncrono); `any()` de tipo próprio exige um valor de referência em `setUpAll`; e `any()` dentro de `verify` aceita qualquer conteúdo — só `captureAny()` confere **com o quê** a chamada foi feita.

<a id="m12-e12"></a>
## M12-E12
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:foco_lab/core/banco/banco_foco.dart';
import 'package:foco_lab/main.dart' as app;
import 'apoio/ajudantes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // O banco é real e sobrevive à execução: sem limpar, a segunda rodada
  // encontra "Cálculo I" já criada e o teste falha.
  setUp(() async => BancoFoco.instancia.apagarTudo());

  testWidgets('cria matéria, registra sessão e vê 50% no resumo',
      (WidgetTester t) async {
    app.main();
    await t.pumpAndSettle();
    await esperarPor(t, find.textContaining('Nenhuma'));

    await tocarComRolagem(t, find.byKey(const Key('fab_nova_materia')));
    await esperarPor(t, find.text('Nova matéria'));
    await digitar(t, find.byKey(const Key('campo_nome')), 'Cálculo I');
    await digitar(t, find.byKey(const Key('campo_meta')), '90');
    await tocarComRolagem(t, find.byKey(const Key('botao_salvar')));
    await esperarPor(t, find.text('Cálculo I'));

    await tocarComRolagem(t, find.text('Cálculo I'));
    await esperarPor(t, find.byKey(const Key('detalhe_materia')));
    await tocarComRolagem(t, find.byKey(const Key('botao_nova_sessao')));
    await digitar(t, find.byKey(const Key('campo_minutos')), '45');
    await tocarComRolagem(t, find.byKey(const Key('botao_registrar')));
    await esperarPor(t, find.textContaining('45'));

    await tocarComRolagem(t, find.byIcon(Icons.arrow_back));
    await tocarComRolagem(t, find.byKey(const Key('aba_resumo')));
    await esperarPor(t, find.textContaining('50%')); // 45 de 90
    expect(find.textContaining('45 min'), findsOneWidget);
  });
}
```
`esperarPor` dá `pump` em fatias de 100 ms até o widget existir, então o teste acompanha o banco e as animações reais — é o que o faz passar duas vezes seguidas aqui e também no CI, mais lento.

<a id="m12-e13"></a>
## M12-E13
**(a) Não promovo `prefer_const_constructors` a `error`.** É regra de desempenho, não de correção: sem ela o pior que acontece é um rebuild a mais, que o módulo 13 mede e resolve com dado na mão. Como `error` ela trava o commit em código que funciona, e esse atrito empurra para o `// ignore:` — pior que o aviso. Fica em `info`, o padrão do `flutter_lints`, e corrijo em lote. Mudo de ideia se a aba Performance mostrar quadro estourado numa lista atribuído a widget não-`const`: aí o risco vira medido e passa a pagar o custo.

**(b) Não escrevo teste de integração para "editar o nome de uma matéria".** É formulário mais repositório: o teste de widget cobre validação e estado do botão em ~200 ms, e o do `MateriaDao` com `sqflite_common_ffi` cobre a gravação. O de integração custa ~40 s por rodada e um emulador ligado para verificar quase a mesma coisa; guardo essa camada para o fluxo que **atravessa** telas, o do E12. Mudo de ideia se a edição passar a sincronizar com a API e a ter conflito de versão — aí o bug mora na costura e só o fluxo real o pega.

<a id="m12-e14"></a>
## M12-E14
| Erro que enfrentei | Quem pegaria mais barato |
|---|---|
| `sequenciaDeDias` zerando à meia-noite | unidade |
| Botão salvando com nome de 1 letra | widget |
| `RenderFlex overflowed` no `MateriaTile` | widget |
| Sessão gravada que sumia ao reabrir o app | integração |
| App fechando sem mensagem depois de `flutter build apk --release` | build/aparelho (`adb logcat`) |

Três dos cinco morrem em unidade ou widget, que rodam em segundos e sem emulador: é onde investir agora, e é a parte mais vazia da minha pirâmide. Integração fica com um fluxo só, o do E12 — mais que isso, a suíte fica lenta e eu paro de rodá-la. Paro de insistir num erro nativo quando tenho três coisas em mãos e nenhuma hipótese nova: `flutter doctor -v` limpo, o log coletado com `adb logcat -c` antes de reproduzir e `adb logcat -d > erro.txt` depois, e a resposta escrita para "o que mudou desde a última vez que funcionou" — dependência nova, versão do Gradle, permissão no Manifest. Com essas três, escalar custa cinco minutos de quem vai ajudar; sem elas, vira adivinhação a dois.

[Exercícios](../exercicios/12-testes-e-debug.md) · [Módulo](../modulos/12-testes-e-debug/README.md)
