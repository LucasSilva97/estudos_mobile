// bin/aula01_ola.dart
// Aula 1 - O que é programar

void main(){
  const String nomeDoCurso = 'Curso Flutter Intensivo';
  const int minutosPorDia = 180;
  const diasDoPlano = 30;


  final int minutosTotais = minutosPorDia * diasDoPlano;
  final double horasTotais = minutosTotais / 60;
  final double horasPorSemana = (minutosPorDia * 5 ) / 60;

  print('====================================================');
  print('Bem-vindo ao $nomeDoCurso!');
  print('====================================================');
  print('Plano: $diasDoPlano dias de estudo.');
  print('Carga diária: $minutosPorDia minutos.');
  print('Total em minutos: $minutosTotais');
  print('Total em horas: ${horasTotais.toStringAsFixed(1)}');
  print('Horas por semana (5 dias úteis): ${horasPorSemana.toStringAsFixed(1)}');
  print('----------------------------------------------------');
  print('Este texto foi escrito por você, traduzido');
  print('pelo Dart e executado pelo seu processador.');
}