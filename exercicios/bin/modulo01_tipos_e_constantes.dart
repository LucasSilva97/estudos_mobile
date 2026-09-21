
void main (){

  const int meta = 120;
  const String materia = 'Dart';
  var minutosEstudados = 100;

  final DateTime execucaoPrograma = DateTime.now();
  final int difMetaReal = meta - minutosEstudados;
  final int faltamMinutos =  difMetaReal <= 0 ? 0 : difMetaReal;
  final String metaBatida = faltamMinutos <= 0 ? 'Sim' : 'Não';

  print('Execução do Programa: $execucaoPrograma');
  print('Matéria: $materia');
  print('Minutos estudados: $minutosEstudados');
  print('Faltam: $faltamMinutos');
  print('Meta batida: $metaBatida');
}