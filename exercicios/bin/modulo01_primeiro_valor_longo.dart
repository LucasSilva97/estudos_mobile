void main(){

  const listaSecoes = <int>[20, 0, 35, 90, 120];
  var sessao;

  for(var idx = 0; idx < listaSecoes.length; idx++){

    if(listaSecoes[idx] >= 60){
      sessao = 'Primeira sessão longa: ${listaSecoes[idx]}';
      break;
    }

    sessao = 'Nenhuma sessão longa';
  }

  print(sessao);
}