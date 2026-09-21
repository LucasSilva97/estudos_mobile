int somarValidos(List<int> minutos){
  var somaAcumulada = 0;
  for(var i = 0; i < minutos.length - 1; i++){
    if (minutos[i] > 0) somaAcumulada += minutos[i];
  }

  return somaAcumulada;
}

String situacao (int total, int meta){
  final int diferenca = meta - total;

  if(diferenca == 0){
    return 'Meta batida';
  } else if (diferenca < 0){
    return 'Meta excedida';
  } else {
    return 'Faltam $diferenca min.';
  }
}

void main(){
  const int meta = 120;
  final minutosRealizados = <int>[25, 0, -5, 30];

  final int totalRealizado = somarValidos(minutosRealizados);
  final String situacaoFinal = situacao(totalRealizado, meta);

  print('Total: $totalRealizado - $situacaoFinal');
}