void main() {
  final materiasUnicas = <String>['Dart', 'Git', 'Dart', 'Flutter'].toSet();
  print('Únicas: $materiasUnicas');
  print('Adicionou SQL? ${materiasUnicas.add('SQL')}');
  print('Adicionou Dart? ${materiasUnicas.add('Dart')}');

  const basicas = <String>{'Dart', 'Git', 'Flutter'};
  const concluidas = <String>{'Git', 'Terminal'};
  print(
    'União: ${basicas.union(concluidas)}',
  ); // Une o set da esquerda ao da direita, eliminando duplicatas
  print(
    'Interseção: ${basicas.intersection(concluidas)}',
  ); // Traz da esquerda pra direita
  // mantendo apenas os valores que tem em ambos o sets que sejam iguais
  print(
    'Pendentes: ${basicas.difference(concluidas)}',
  ); // traz da esquerda pra direita, e mantém os
  // itens da esquerda que não tem no set usado como parâmetro

  final minutosPorMateria = <String, int>{'Dart': 40, 'Git': 25};
  minutosPorMateria['Flutter'] = 30;
  minutosPorMateria.update('Dart', (atual) => atual + 20);
  minutosPorMateria.update('SQL', (atual) => atual + 15, ifAbsent: () => 15);
  minutosPorMateria.update('Kotlin', (atual) => atual + 5, ifAbsent: () => 5);
  print('Dart: ${minutosPorMateria['Dart']} min');
  print('Kotlin: ${minutosPorMateria['Kotlin'] ?? 0} min');

  // Mostrando chave e valor
  print('');
  print('=== Mostrando chave e valor');
  for (final entrada in minutosPorMateria.entries) {
    print('${entrada.key}: ${entrada.value} min');
  }

  final sessoes = <(String, int)>[('Dart', 25), ('Git', 30), ('Dart', 40)];

  final totais = <String, int>{};
  for (final (materia, minutos) in sessoes) {
    totais.update(materia, (atual) => atual + minutos, ifAbsent: () => minutos);
  }

  print('Totais: $totais');

  // Fazendo cópia protegida
  final copiaProtegida = Map<String, int>.unmodifiable(totais);
  print('Protegido: $copiaProtegida');
}
