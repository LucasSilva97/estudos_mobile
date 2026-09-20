void main() {
  final minutos = <int>[25, 0, 40, 30, 15];
  var sessoes = 0;
  var total = 0;

  for (final duracao in minutos) {
    if (duracao <= 0) continue;
    sessoes++;
    total += duracao;
  }

  print('Sessões válidas: $sessoes');
  print('Total: $total min');

  var restante = 70;
  var blocos = 0;
  while(restante > 0) {
    final bloco = restante >= 25 ? 25 : restante;
    restante -= bloco;
    blocos++;
    print('Bloco $blocos: $bloco min');
  }

  var tentativa = 0;
  do {
    tentativa++;
    print('Tentativa $tentativa');
  } while (tentativa < 1);

  for (final duracao in minutos) {
    if (duracao >= 40) {
      print('Primeira sessão longa: $duracao');
      break;
    }
  }
}