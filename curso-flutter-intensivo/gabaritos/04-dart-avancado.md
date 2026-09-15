# Gabarito — Módulo 04: Dart avançado

> Compare depois de resolver os [exercícios](../exercicios/04-dart-avancado.md).

<a id="m04-e01"></a>
## M04-E01
```dart
class SessaoInvalidaException implements Exception {
  const SessaoInvalidaException(this.materia, this.motivo);
  final String materia;
  final String motivo;
  @override
  String toString() => 'SessaoInvalidaException: "$materia" — $motivo';
}

int registrarSessao(String materia, int minutos) {
  if (materia.trim().isEmpty) {
    throw const SessaoInvalidaException('', 'matéria não pode ser vazia');
  }
  if (minutos <= 0) {
    throw SessaoInvalidaException(materia, 'minutos precisam ser positivos');
  }
  return minutos;
}

void main() {
  for (final (materia, minutos) in [('Dart', 45), ('', 45), ('Dart', 0)]) {
    try {
      print('registrado: ${registrarSessao(materia, minutos)} min');
    } on SessaoInvalidaException catch (e) {
      print(e);
    }
  }
}
```
`implements Exception` marca a falha como esperada: matéria vazia é entrada do usuário, não bug seu.

<a id="m04-e02"></a>
## M04-E02
```dart
sealed class Resultado<S, F> { const Resultado(); }
final class Sucesso<S, F> extends Resultado<S, F> { const Sucesso(this.valor); final S valor; }
final class Falha<S, F> extends Resultado<S, F> { const Falha(this.erro); final F erro; }

Resultado<int, String> registrarComResultado(String materia, int minutos) {
  try {
    return Sucesso(registrarSessao(materia, minutos));
  } on SessaoInvalidaException catch (e) {
    return Falha('${e.materia}: ${e.motivo}');
  }
}

String descrever(Resultado<int, String> resultado) => switch (resultado) {
  Sucesso(:final valor) => 'sessão de $valor min registrada',
  Falha(:final erro) => 'não registrou — $erro',
};
```
O `try` fica só na borda; como `Resultado` é `sealed`, o `switch` é exaustivo sem `_` — um caso novo viraria erro de compilação, não bug silencioso.

<a id="m04-e03"></a>
## M04-E03
```dart
const List<int> minutosDaSemana = [30, 45, 60];

int registrarDoDia(int dia, String materia) {
  try {
    return registrarSessao(materia, minutosDaSemana[dia]);
  } on SessaoInvalidaException catch (e, s) {
    print('falha de domínio: $e');
    print(s.toString().split('\n').take(3).join('\n'));
    rethrow;
  }
}
```
O defeito era o `catch (e)` sem `on`: ele engolia também o `RangeError` de `minutosDaSemana[7]` — um `Error`, bug de programação — e descartava o stack trace.

<a id="m04-e04"></a>
## M04-E04
```dart
import 'dart:async';

Future<T> lento<T>(T valor) =>
    Future.delayed(const Duration(seconds: 1), () => valor);

Future<List<String>> carregarMaterias() => lento(['Dart', 'Flutter']);
Future<int> carregarMinutosDaSemana() => lento(320);
Future<String> carregarFraseDoDia() => lento('Consistência vence intensidade.');

Future<void> painel(Duration prazo) async {
  final relogio = Stopwatch()..start();
  try {
    final dados = await Future.wait<Object>([
      carregarMaterias(),
      carregarMinutosDaSemana(),
      carregarFraseDoDia(),
    ]).timeout(prazo);
    final materias = dados[0] as List<String>;
    print('${materias.length} matérias, ${dados[1]} min — ${dados[2]}');
  } on TimeoutException {
    print('painel demorou demais; mostrando o cache');
  }
  print('tempo: ${relogio.elapsedMilliseconds} ms');
}

Future<void> main() async {
  await painel(const Duration(seconds: 2)); // ~1000 ms
  await painel(const Duration(milliseconds: 500)); // TimeoutException
}
```
O ganho vem de os três futures serem **criados** antes de qualquer `await`: no sequencial, o segundo só começa depois de o primeiro terminar (~3 s).

<a id="m04-e05"></a>
## M04-E05
Saída: **1, 4, 3, 2**. Os dois `print` são síncronos e saem antes de o `main` devolver o controle ao event loop; só então ele esvazia **por completo** a fila de microtasks (o `3`) e, apenas depois, pega o primeiro item da fila de eventos (o `2`). A fila de microtasks tem prioridade — por isso uma microtask infinita trava o app inteiro.

<a id="m04-e06"></a>
## M04-E06
```dart
import 'dart:async';

Stream<int> minutosDaSessao(int total) async* {
  for (var minuto = 1; minuto <= total; minuto++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    yield minuto;
  }
}

Future<void> main() async {
  final cortou = Completer<void>();
  late final StreamSubscription<int> assinatura;
  assinatura = minutosDaSessao(10).listen((minuto) async {
    print('minuto $minuto');
    if (minuto == 3) {
      await assinatura.cancel();
      cortou.complete();
    }
  });
  await cortou.future;
  print('sessão interrompida no minuto 3');
}
```
Depois do `cancel()` a stream não emite mais nem chama `onDone` — o `Completer` é o que segura o `main` até o corte.

<a id="m04-e07"></a>
## M04-E07
```dart
({int minimo, int maximo, double media}) estatisticas(List<int> minutos) {
  if (minutos.isEmpty) return (minimo: 0, maximo: 0, media: 0);
  final ordenado = [...minutos]..sort();
  final media = minutos.reduce((a, b) => a + b) / minutos.length;
  return (minimo: ordenado.first, maximo: ordenado.last, media: media);
}

void main() {
  final (:minimo, :maximo, :media) = estatisticas([30, 90, 45]);
  print('min $minimo, max $maximo, média ${media.toStringAsFixed(1)}'); // 30 / 90 / 55.0
  print(estatisticas([])); // (maximo: 0, media: 0.0, minimo: 0)
}
```
O `0` de `media` vira `0.0` porque o tipo de retorno dá contexto `double` ao literal; lista vazia devolve record em vez de lançar — "nenhuma sessão" não é erro.

<a id="m04-e08"></a>
## M04-E08
```dart
import 'e02_resultado.dart' as r; // Resultado/Sucesso/Falha do E02

sealed class EstadoTela<T> { const EstadoTela(); }
final class Carregando<T> extends EstadoTela<T> { const Carregando(); }
final class Vazio<T> extends EstadoTela<T> { const Vazio({this.dica = 'Cadastre sua primeira matéria.'}); final String dica; }
final class Sucesso<T> extends EstadoTela<T> { const Sucesso(this.dados); final T dados; }
final class ErroEstado<T> extends EstadoTela<T> { const ErroEstado(this.mensagem); final String mensagem; }

EstadoTela<List<String>> paraEstado(
  r.Resultado<List<String>, String> resultado,
) => switch (resultado) {
  r.Sucesso(:final valor) when valor.isEmpty => const Vazio<List<String>>(),
  r.Sucesso(:final valor) => Sucesso<List<String>>(valor),
  r.Falha(:final erro) => ErroEstado<List<String>>(erro),
};

String descrever(EstadoTela<List<String>> estado) => switch (estado) {
  Carregando() => '[spinner] Carregando matérias...',
  Vazio(:final dica) => '[vazio] $dica',
  Sucesso(:final dados) => '[ok] ${dados.length} matérias',
  ErroEstado(:final mensagem) => '[erro] $mensagem',
};
```
O prefixo `r.` separa os dois `Sucesso`; e o caso com `when` não conta para exaustividade, por isso `r.Sucesso` aparece duas vezes.

<a id="m04-e09"></a>
## M04-E09
```dart
String avaliarSessao(Sessao sessao) => switch (sessao) {
  Sessao(concluida: false, :final materia) => '$materia ainda em andamento',
  Sessao(:final materia, :final minutos) when minutos >= 60 =>
    '$materia: sessão longa de $minutos min',
  Sessao(:final materia, :final minutos) => '$materia: $minutos min',
};
```
O defeito era a ordem: o `switch` usa o **primeiro** caso que casa, e o genérico casa com tudo — duração testada com `if` dentro do corpo não influencia a escolha do caso, só o guard `when` influencia.

<a id="m04-e10"></a>
## M04-E10
```yaml
# analysis_options.yaml
include: package:lints/recommended.yaml

analyzer:
  errors:
    unused_local_variable: error
    avoid_print: ignore # em app Flutter, deixe como error e use debugPrint
  language:
    strict-casts: true

linter:
  rules:
    - prefer_final_locals
    - unawaited_futures
    - cancel_subscriptions
```
```powershell
# verificar.ps1
dart format --output=none --set-exit-if-changed .
if ($?) { dart analyze --fatal-infos }
```
No E06 o conserto de `cancel_subscriptions` é guardar a `StreamSubscription` e cancelá-la: `// ignore:` some com o apontamento e mantém o vazamento.

<a id="m04-e11"></a>
## M04-E11
```dart
import 'dart:async';
import 'dart:isolate';

// somaDosPrimos e _ehPrimo: os mesmos da aula 8.

Future<void> medir(String rotulo, Future<int> Function() calcular) async {
  final tiques = Stream<int>.periodic(const Duration(milliseconds: 200), (i) => i)
      .listen((i) => print('   tique $i'));
  final relogio = Stopwatch()..start();
  final soma = await calcular();
  relogio.stop();
  await tiques.cancel();
  print('$rotulo: soma=$soma em ${relogio.elapsedMilliseconds} ms');
}

Future<void> main() async {
  await medir('direto', () async => somaDosPrimos(2000000));
  await medir('isolate', () => Isolate.run(() => somaDosPrimos(2000000)));
}
```
O tempo total é parecido nas duas versões; o que muda é que, no cálculo direto, o laço ocupa o isolate principal e o event loop não entrega os tiques — no Flutter, a tela congelada.

<a id="m04-e12"></a>
## M04-E12
```dart
// bin/painel_foco.dart — E01 a E11 juntos, com o Resultado do E02 sob o prefixo `r`.
import 'dart:isolate';

class RepositorioFakeMaterias {
  int _chamadas = 0;

  Future<r.Resultado<List<String>, String>> buscar() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _chamadas++;
    return switch (_chamadas) {
      2 => const r.Falha('Sem conexão com o servidor'),
      3 => const r.Sucesso(<String>[]),
      _ => const r.Sucesso(['Dart', 'Flutter', 'SQL']),
    };
  }
}

List<String> rankingPorMinutos(Map<String, int> minutosPorMateria) {
  final entradas = minutosPorMateria.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return [for (final e in entradas) '${e.key} (${e.value} min)'];
}

Future<void> main() async {
  final repositorio = RepositorioFakeMaterias();
  for (var tentativa = 1; tentativa <= 3; tentativa++) {
    print('\n--- tentativa $tentativa ---');
    print(descrever(const Carregando<List<String>>()));
    final estado = paraEstado(await repositorio.buscar());
    print(descrever(estado));
    if (estado case Sucesso(:final dados) when dados.isNotEmpty) {
      await for (final minuto in minutosDaSessao(3)) {
        print('   minuto $minuto');
      }
      final (:minimo, :maximo, :media) = estatisticas([30, 90, 45]);
      print('   semana: $minimo a $maximo min, média $media');
      final ranking = await Isolate.run(
        () => rankingPorMinutos({'Dart': 320, 'Flutter': 180, 'SQL': 95}),
      );
      print('   ranking: $ranking');
    }
  }
}
```
A borda devolve `Resultado`, `paraEstado` converte em `EstadoTela` e só a apresentação decide o que mostrar — o mesmo desenho que o Riverpod 3.4.3 entrega pronto com `AsyncValue` no módulo 08.
