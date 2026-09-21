// Explicação - porque int.parse('trinta') falha?

/**
 * O parse vai funcionar caso o texto venha com um número dentro, caso contrário
 * vai dar erro de compilação. A alternativa para evitar esse erro é usar o tryparse, porém
 * nesse caso em específico, vai retornar null.
 */


int? converterMinutos(String texto) {

  final int? numeroConvertido = int.tryParse(texto.trim());


  return numeroConvertido;
}

void main(){
  print(converterMinutos('25'));
  print(converterMinutos('40'));
  print(converterMinutos('trinta'));
  print(converterMinutos('0'));
  print(converterMinutos('-1'));
  print(converterMinutos('2.5'));
}