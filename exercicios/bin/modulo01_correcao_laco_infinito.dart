void main(){
  var restante = 75;
  const int controlador= 25;

  while(restante > 0) {
    print(restante);

    // CORREÇÃO DE BUG DO LOOP INFINITO
    // Isso vai impedir que ficar em loop infinito, realizando decréscimo na variável constante, até que se torne menor que zero
    // para quebrar o fluxo de repetição
    // Usando controlador
    restante -= controlador;
  }
}