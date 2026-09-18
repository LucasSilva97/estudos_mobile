void main() {
  const String origem1 = '120';        // limpo
  const String origem2 = ' 90 ';       // com espaços
  const String origem3 = '1,5';        // horas com vírgula
  const String origem4 = 'duas horas'; // impossível de converter

  final int numLimpo = int.parse(origem1);
  final int? semEspacos = int.tryParse(origem2.trim());
  final double? horasSemVirgula = double.tryParse(origem3.replaceAll(',', '.'));

  print('Número original 1 como número: $numLimpo');
  print('Número origem2 sem espaços: $semEspacos');
  print('Horas no formato double: $horasSemVirgula');

}