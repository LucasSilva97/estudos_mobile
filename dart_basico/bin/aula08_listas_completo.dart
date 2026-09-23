// bin/listas.dart
// Demonstra: criação, acesso, modificação, spread, collection-if/for,
// map/where/fold/reduce/sort e imutabilidade.

void main() {
  print('=== 1. Criando listas ===');
  final List<String> materias = <String>['Dart', 'Flutter', 'Git'];
  final List<int> vazia = <int>[];
  final List<int> zeros = List<int>.filled(3, 0);
  final List<int> blocos = List<int>.generate(5, (int i) => (i + 1) * 25);
  print('literal  : $materias');
  print('vazia    : $vazia (isEmpty = ${vazia.isEmpty})');
  print('filled   : $zeros');
  print('generate : $blocos');

  print('');
  print('=== 2. Acesso por índice ===');
  print('materias[0]      : ${materias[0]}');
  print('first / last     : ${materias.first} / ${materias.last}');
  print('length           : ${materias.length}');
  print('indexOf("Git")   : ${materias.indexOf('Git')}');
  print('contains("Java") : ${materias.contains('Java')}');

  print('');
  print('=== 3. Modificando ===');
  materias.add('SQL');
  materias.insert(1, 'Lógica');
  materias.addAll(<String>['Testes', 'Build']);
  print('add/insert/addAll : $materias');
  materias.remove('SQL');
  materias.removeAt(0);
  print('remove/removeAt   : $materias');
  materias.removeWhere((String m) => m.startsWith('B'));
  print('removeWhere       : $materias');

  print('');
  print('=== 4. Spread ===');
  const List<String> basicas = <String>['Dart', 'Flutter'];
  const List<String> extras = <String>['Git', 'SQL'];
  print('spread simples : ${<String>[...basicas, ...extras, 'Testes']}');
  List<String>? opcionais;
  print('spread seguro (null) : ${<String>[...basicas, ...?opcionais]}');
  opcionais = <String>['Build'];
  print('spread seguro (cheio): ${<String>[...basicas, ...?opcionais]}');

  print('');
  print('=== 5. collection-if e collection-for ===');
  const bool incluirExtras = true;
  const List<int> minutos = <int>[45, 0, 120, 300, 30];
  final List<String> plano = <String>[
    'Abertura',
    for (final int m in minutos)
      if (m > 0) '$m min'else 'sessão vazia',
    if (incluirExtras) 'Revisão extra',
    'Encerramento',
  ];
  print('plano: $plano');

  print('');
  print('=== 6. map, where, take, skip, reversed, join ===');
  final List<int> dobrados = minutos.map((int m) => m * 2).toList();
  final List<int> validos =
      minutos.where((int m) => m > 0 && m <= 240).toList();
  print('map dobrado : $dobrados');
  print('where válido: $validos');
  print('take(2)     : ${minutos.take(2).toList()}');
  print('skip(3)     : ${minutos.skip(3).toList()}');
  print('reversed    : ${minutos.reversed.toList()}');
  print('join        : ${validos.join(' + ')}');

  print('');
  print('=== 7. firstWhere, any, every, indexWhere ===');
  print('any(> 240)       : ${minutos.any((int m) => m > 240)}');
  print('every(> 0)       : ${minutos.every((int m) => m > 0)}');
  print('indexWhere(== 0) : ${minutos.indexWhere((int m) => m == 0)}');
  print('firstWhere >= 90 : '
      '${minutos.firstWhere((int m) => m >= 90, orElse: () => -1)}');
  print('firstWhere == 999: '
      '${minutos.firstWhere((int m) => m == 999, orElse: () => -1)}');

  print('');
  print('=== 8. reduce e fold ===');
  print('reduce soma  : ${validos.reduce((int a, int b) => a + b)}');
  print('reduce maior : ${minutos.reduce((int a, int b) => a > b ? a : b)}');
  print('fold soma    : '
      '${minutos.fold<int>(0, (int acc, int m) => acc + m)}');
  print('fold texto   : '
      '${validos.fold<String>('', (String txt, int m) => '$txt[$m]')}');

  print('');
  print('=== 9. sort ===');
  final List<int> ordenados = List<int>.of(minutos)..sort();
  print('crescente   : $ordenados');
  ordenados.sort((int a, int b) => b.compareTo(a));
  print('decrescente : $ordenados');
  const List<String> nomes = <String>['Flutter', 'dart', 'Git', 'ansible'];
  final List<String> alfabetica = List<String>.of(nomes)
    ..sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
  print('original    : $nomes');
  print('alfabética  : $alfabetica');

  print('');
  print('=== 10. Listas imutáveis ===');
  final List<String> protegida = List<String>.unmodifiable(materias);
  print('protegida : $protegida');
  try {
    protegida.add('Novo');
  } on UnsupportedError catch (erro) {
    print('Erro esperado: ${erro.message}');
  }
  materias.add('Extra');
  print('original depois do add : $materias');
  print('protegida não mudou    : $protegida');

  print('');
  print('=== 11. Iterable é preguiçoso ===');
  final Iterable<int> preguicoso = minutos.map((int m) {
    print('  calculando $m');
    return m * 2;
  });
  print('criado, mas nada calculou ainda');
  print('first   : ${preguicoso.first}');
  print('toList(): ${preguicoso.toList()}');

  /**Exercício guiado */
  print('');
  print('=== Exercício guiado ===');
  print('');

  // Provando um RangeError
  // print(materias[10]);
  /*
    RangeError (length): Invalid value: Not in inclusive range 0..4: 10

    Unhandled exception:
    Bad state: No element
  //  */
  // print('firstWhere >= 90 : '
  //     '${minutos.firstWhere((int m) => m >= 90, orElse: () => -1)}');
  // print('firstWhere == 999: '
  //     '${minutos.firstWhere((int m) => m == 999 /*, orElse: () => -1*/)}');

  /** Trocando fold por reduce em lista vazia */
  final List<int> nenhuma = <int>[];
  print(nenhuma.fold<int>(0, (int acc, int m) => acc + m)); // 0
  // print(nenhuma.reduce((int a, int b) => a + b)); // explode um problema de Unhandled exception: Bad state: No element

  /** Passo 6 — brinque com o collection-for. Mude a seção 5 para incluir também os zeros */

}