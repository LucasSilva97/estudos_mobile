void main(){
  const String entradaDoUsuario = '90';

  final int? minutos = int.tryParse(entradaDoUsuario);

  if (minutos == null) {
    print('Valor inválido: "$entradaDoUsuario"');
    return;
  }

  final double horas = minutos / 60;
  print('$minutos minutos = ${horas.toStringAsFixed(1)} h');
}