// Nomeados obrigatórios + arrow function
String resumo({required String materia, required int minutos}) =>
  '$materia estudada por $minutos min';

void main(){
  print(resumo(materia: 'Dart', minutos: 45));
  print(resumo(minutos: 90, materia: 'Flutter')); // usando ordem livre de parâmetros

  // Função anônima passada como argumento
  final dobrados = <int>[10, 20, 30].map((m) => m * 2).toList();
  print(dobrados);
}
