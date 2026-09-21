String classificarMeta(int percentual) {

  var classificacao;

  if(percentual < 0){
    classificacao = 'inválido';
  } else if (percentual >= 0 && percentual <= 49){
    classificacao = 'Começando';
  } else if (percentual >= 50 && percentual <= 99) {
    classificacao = 'Quase lá';
  } else {
    classificacao = 'Meta atingida';
  }

  return classificacao;
}

void main(){
  print('Meta -1: ${classificarMeta(-1)}');
  print('Meta 0: ${classificarMeta(0)}');
  print('Meta 49: ${classificarMeta(49)}');
  print('Meta 50: ${classificarMeta(50)}');
  print('Meta 99: ${classificarMeta(99)}');
  print('Meta 100: ${classificarMeta(100)}');
  print('Meta 150: ${classificarMeta(150)}');
}