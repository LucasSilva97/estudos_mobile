int calcularRestante(int meta, int estudado){

  final diferenca = meta - estudado;
  if (diferenca < 0) return 0;

  return diferenca;
  // IMPORTANTE: A FUNÇÃO É ENCERRADA NO PELO SEU RETURN.
}

int contarBlocos(int minutos, int tamanho) {
  if (minutos <= 0 || tamanho <= 0) return 0;

  final inteiros = minutos ~/ tamanho;
  final sobra = minutos % tamanho;
  return sobra == 0 ? inteiros : inteiros + 1;
}

void mostrarPlano(String materia, int restante) {
  final blocos = contarBlocos(restante, 25);
  print('$materia: faltam $restante min em $blocos blocos');
}

void main(){
  final restante = calcularRestante(120, 50);

  mostrarPlano('Dart', restante);
  mostrarPlano('Git', calcularRestante(30, 45));
  print('Blocos para 50 min: ${contarBlocos(50, 25)}');

  print(calcularRestante(120, 120));
  print(calcularRestante(120, 150));
  //Em ambos os casos vai retornar 0, por conta da condição que trata os casos onde a 
  // diferença pode dar negativo
}

