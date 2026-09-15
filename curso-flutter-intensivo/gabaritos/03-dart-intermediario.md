# Gabarito — Módulo 03: Dart intermediário

> Compare depois de resolver os [exercícios](../exercicios/03-dart-intermediario.md).

<a id="m03-e01"></a>
## M03-E01
```dart
class SessaoEstudo {
  SessaoEstudo(this.materia, this.minutos);
  final String materia;
  final int minutos;
  String descricao() => '$materia: $minutos min';
}
```

<a id="m03-e02"></a>
## M03-E02
```dart
class MetaSemanal {
  MetaSemanal({required this.materia, required this.minutos})
      : assert(materia != ''), assert(minutos > 0);
  MetaSemanal.padrao(String materia) : this(materia: materia, minutos: 120);
  final String materia;
  final int minutos;
}
```

<a id="m03-e03"></a>
## M03-E03
```dart
class Progresso {
  int _minutos = 0;
  int get minutos => _minutos;
  void adicionar(int valor) { if (valor > 0) _minutos += valor; }
}
```
O campo `_minutos` é privado à biblioteca; a regra fica centralizada no método.

<a id="m03-e04"></a>
## M03-E04
```dart
class Materia {
  const Materia({required this.nome, required this.cor});
  final String nome;
  final String cor;
  Materia copyWith({String? nome, String? cor}) =>
      Materia(nome: nome ?? this.nome, cor: cor ?? this.cor);
}
```

<a id="m03-e05"></a>
## M03-E05
```dart
abstract class Notificacao { String mensagem(); }
class Lembrete implements Notificacao { Lembrete(this.texto); final String texto; @override String mensagem() => 'Lembrete: $texto'; }
class AlertaMeta implements Notificacao { AlertaMeta(this.falta); final int falta; @override String mensagem() => 'Faltam $falta min'; }
void mostrar(Iterable<Notificacao> itens) { for (final item in itens) { print(item.mensagem()); } }
```

<a id="m03-e06"></a>
## M03-E06
```dart
abstract interface class Repositorio<T> {
  void salvar(String id, T item);
  List<T> todos();
  T? buscarPorId(String id);
}
class Memoria<T> implements Repositorio<T> {
  final _itens = <String, T>{};
  @override void salvar(String id, T item) => _itens[id] = item;
  @override List<T> todos() => _itens.values.toList(growable: false);
  @override T? buscarPorId(String id) => _itens[id];
}
```

<a id="m03-e07"></a>
## M03-E07
```dart
abstract class RepositorioBase {}
mixin Auditavel on RepositorioBase { void auditar(String texto) => print('AUDIT: $texto'); }
class MateriasMemoria extends RepositorioBase with Auditavel {}
```

<a id="m03-e08"></a>
## M03-E08
```dart
enum StatusMeta {
  naoIniciada('Não iniciada', true), emAndamento('Em andamento', true), concluida('Concluída', false);
  const StatusMeta(this.rotulo, this.permiteRegistrar);
  final String rotulo;
  final bool permiteRegistrar;
}
```
O `switch` deve conter os três casos; não dependa de `index` para regra de negócio.

<a id="m03-e09"></a>
## M03-E09
```dart
class Caixa<T> { T? _valor; bool get estaVazia => _valor == null; void guardar(T valor) => _valor = valor; T? retirar() { final valor = _valor; _valor = null; return valor; } }
```

<a id="m03-e10"></a>
## M03-E10
```dart
T maior<T extends Comparable<T>>(Iterable<T> valores) => valores.reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
```
`Object` não declara `compareTo`; a restrição garante a operação em compilação.

<a id="m03-e11"></a>
## M03-E11
```dart
extension DuracaoFormatada on int {
  String get comoDuracao => this < 0 ? 'Inválida' : '${this ~/ 60}h ${(this % 60).toString().padLeft(2, '0')}min';
}
```

<a id="m03-e12"></a>
## M03-E12
A solução deve usar o contrato de E06 para armazenar `Materia`, `copyWith` de E04 para atualizar sem mutar e `StatusMeta` de E08 para impedir registro em meta concluída. Valide cadastro repetido, busca ausente e atualização.
