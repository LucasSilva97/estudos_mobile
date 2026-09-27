import 'dart:io';

void main(){
  solicitarNumero();
}

void solicitarNumero(){
  print("Digite um número de 1 a 12 para saber o mês correspondente:");
  String? input = stdin.readLineSync();

  int numero;
  if (input == null) {
    print("Entrada inválida. Por favor, insira um número válido.");
    solicitarNumero();
    return;
  }

  numero = int.parse(input);

  String mes = obterMes(numero);
  print(mes);

  if(mes == 'Número inválido. Por favor, insira um número de 1 a 12.'){
    solicitarNumero();
  }


}

  // Função que retorna o mês correspondente
String obterMes(int numero) {
  switch (numero) {
    case 1:
      return 'Janeiro';
    case 2:
      return 'Fevereiro';
    case 3:
      return 'Março';
    case 4:
      return 'Abril';
    case 5:
      return 'Maio';
    case 6:
      return 'Junho';
    case 7:
      return 'Julho';
    case 8:
      return 'Agosto';
    case 9:
      return 'Setembro';
    case 10:
      return 'Outubro';
    case 11:
      return 'Novembro';
    case 12:
      return 'Dezembro';
    default:
      return 'Número inválido. Por favor, insira um número de 1 a 12.';
  }
}
