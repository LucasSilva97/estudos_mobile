void main(){
  const String digitado = 'quinhentos';
  final int totalMinutos = int.tryParse(digitado) ?? 0;

  final int horas = totalMinutos~/ 60;
  final int minutos= totalMinutos % 60;
  print('$totalMinutos = $horas h $minutos min');

  const int metaMinutos = 480;
  final int falta = metaMinutos - totalMinutos;
  final bool bateuMeta = totalMinutos >= metaMinutos;
  final bool quaseLa = !bateuMeta && falta <= 60;

  print('Bateu a meta? $bateuMeta');
  print('Está quase lá? $quaseLa (faltam $falta min)');
}