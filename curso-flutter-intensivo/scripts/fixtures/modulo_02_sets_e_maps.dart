void main() {
  final materiasUnicas = <String>['Dart', 'Git', 'Dart', 'Flutter'].toSet();
  print('Únicas: $materiasUnicas');
  print('Adicionou SQL? ${materiasUnicas.add('SQL')}');
  print('Adicionou Dart? ${materiasUnicas.add('Dart')}');

  const basicas = <String>{'Dart', 'Git', 'Flutter'};
  const concluidas = <String>{'Git', 'Terminal'};
  print('União: ${basicas.union(concluidas)}');
  print('Interseção: ${basicas.intersection(concluidas)}');
  print('Pendentes: ${basicas.difference(concluidas)}');

  final minutosPorMateria = <String, int>{'Dart': 40, 'Git': 25};
  minutosPorMateria['Flutter'] = 30;
  minutosPorMateria.update('Dart', (atual) => atual + 20);
  minutosPorMateria.update('SQL', (atual) => atual + 15, ifAbsent: () => 15);
  print('Dart: ${minutosPorMateria['Dart']} min');
  print('Inexistente: ${minutosPorMateria['Kotlin']}');

  for (final entrada in minutosPorMateria.entries) {
    print('${entrada.key}: ${entrada.value} min');
  }

  final sessoes = <(String, int)>[('Dart', 25), ('Git', 30), ('Dart', 40)];
  final totais = <String, int>{};
  for (final (materia, minutos) in sessoes) {
    totais.update(materia, (atual) => atual + minutos, ifAbsent: () => minutos);
  }
  print('Totais: $totais');

  final copiaProtegida = Map<String, int>.unmodifiable(totais);
  print('Protegido: $copiaProtegida');
}
