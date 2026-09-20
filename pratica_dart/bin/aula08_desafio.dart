void main(){
  final duracoes = <int> [90, 120, 140, 50, 100, 120, 70, 90];
  
  var maiorDuracao = 0;
  var valoresRepetidos = 0;

  for(final duracao in duracoes){
    if(duracao > maiorDuracao) {
      maiorDuracao = duracao;
    } 

  }

  final int tamanhoLista = duracoes.length ?? 0;

  final String mensagemTamanhoLista = 
      tamanhoLista == 0 ? 'Nenhuma sessão': 
      tamanhoLista== 1? 'Lista com apenas 1 sessão': 'Total de $tamanhoLista sessões.';

   for(var i = 0; i < duracoes.length; i++){
    var numAtual = duracoes[i];
    var frequenciaNum = 0;
    for(var j = 0; j < duracoes.length; j++){
      var segundoNumAtual = duracoes[j];
      if(numAtual == segundoNumAtual){
        frequenciaNum++;
      }
    }

    if (frequenciaNum >= 2){
        valoresRepetidos++;
      }

  }

  print('=== Resultado Final ===');
  print('Maior tempo de duração: $maiorDuracao');
  print('Valores repetidos: $valoresRepetidos');
  print('Sessões: $mensagemTamanhoLista');

}