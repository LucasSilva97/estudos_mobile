void main(){
  const int realSegunda = 30; 
  const int realTerca = 60; 
  const int realQuarta = 90; 

  final double media = realSegunda + realTerca + realQuarta / 3; // Forma errada de calcular
  final double mediaCorreta = (realSegunda + realTerca + realQuarta) / 3; // Forma correta de calcular

  print('Média incorreta: $media');
  print('Média correta: $mediaCorreta');
  
  /**
   * media - está incorreta para regra da precedência. Se não isolar as somas primeiro, pela regra ele vai calcular primeiro a divisão, e depois somar:
   * nesse caso, essa media está dividindo o realizado de quarta por 3 e depois somando os reais de segunda e terça
   * 
   * mediaCorreta - aqui entra a forma correta, onde deve ser isolado toda a soma, tendo os parênteses precedência acima de qualquer operador aritmético,
   * dessa forma ele executa a divisão só após feita todas as somas. 
   */
}