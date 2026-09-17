void main (){
  const String digitadoPeloUsuario = '150';

  final int? minutos = int.tryParse(digitadoPeloUsuario);
  print('Texto original: $digitadoPeloUsuario (${digitadoPeloUsuario.runtimeType})');
  print('Convertido: $minutos');

  final int? invalido = int.tryParse('cento e cinquenta');
  print('Entrada inválida vira: $invalido');
}