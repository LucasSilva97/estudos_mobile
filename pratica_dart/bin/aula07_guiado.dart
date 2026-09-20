void main() {
  const String digitado = '120';
  final int minutos = int.tryParse(digitado) ?? - 1; //?? - faz praticamente a função de um coalesce aqui

  if(minutos < 0){
    print('Entrada inválida: "$digitado" não é um número.');
    return; // encerra o método main aqui nesta linha
  }

  // Classificando a sessão com uma cadeia 'else if'
  String tipo;
  
  if (minutos == 0){
    tipo = 'nenhuma sessão';
  } else if (minutos < 25) {
    tipo = 'sessão curta';
  } else if (minutos < 60) {
    tipo = 'sessão padrão';
  } else if (minutos < 120) {
    tipo = 'sessão longa';
  } else {
    tipo = 'maratona';
  }


  print('$minutos min = $tipo');

  final bool precisaPausa = minutos >= 50;
  final String recomendacao = precisaPausa ? 'Faça 15 min de pausa' : 'Pode emendar a pŕoxima.';
  print(recomendacao);

  final bool sessaoProdutiva = minutos >= 25 && minutos <= 120;
  final String mensagemTraduzida = sessaoProdutiva ? 'Parabéns! Sessão muito produtiva.' : 'Não foi produtiva.';
  print('Sessão produtiva? $sessaoProdutiva');
  print('Sessão produtiva? $mensagemTraduzida');
}
