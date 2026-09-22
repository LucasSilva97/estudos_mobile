void main(){
  const String entrada = 'abc';

  final int? minutos = int.tryParse(entrada); // pode receber nulo

  print('Com ?? : ${minutos ?? 0} minutos');
  print('Com ?. : ${minutos?.isEven}'); // isEven testa se é par, se for par dá true, se não dá false
  print('Com ?. : ${minutos?.isEven}');// Aqui só retorna null por conta da proteção ?

  if (minutos != null) {
    print('Promovido o dobro é ${minutos * 2}');
  } else {
    print('Entrada "$entrada" não é um número.');
  }

}