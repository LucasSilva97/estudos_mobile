class Materia {
  String nome = 'Sem nome';
  int minutosEstudados = 0;

  void registrarEstudo(int minutos){
    minutosEstudados += minutos;
  }
}

void main() {
  final dart = Materia();
  dart.nome = 'Dart';
  dart.registrarEstudo(90);

  print('${dart.nome} tem ${dart.minutosEstudados} minutos');
}