void main(){
  const String metaDigitada = '750';
  const String estudadoDigitado = '690';
  const String notaDigitada = '8,5';

  final int? meta = int.tryParse(metaDigitada);
  final int? estudado = int.tryParse(estudadoDigitado);
  print('meta = $meta | estudado = $estudado');

  final double? nota = double.tryParse(notaDigitada);
  print('nota com vírgula = $nota');

  // Para consertar o problema com null
  final String notaNormalizada = notaDigitada.replaceAll(',', '.');
  final double? notaCorrigida = double.tryParse(notaNormalizada);
  print('nota corrigida = $notaCorrigida');
}