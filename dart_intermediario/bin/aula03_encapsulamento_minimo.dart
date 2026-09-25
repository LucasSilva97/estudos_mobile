class Cofre {
  int _moedas = 0;

  int get moedas => _moedas;
  bool get vazio => _moedas == 0;

  set moedas(int valor) {
    if (valor < 0) {
      throw ArgumentError.value(valor, 'moedas', 'Não pode ser negativo.');
    }
    _moedas = valor;
  }
}

void main() {
  final cofre = Cofre();
  print(cofre.moedas);
  print('Vazio? ${cofre.vazio}');

  cofre.moedas = 7;
  print('Agora tem ${cofre.moedas} moedas. Vazio? ${cofre.vazio}');

  try {
    cofre.moedas = -1;
  } on ArgumentError catch (erro) {
    print('Recusado: ${erro.message}');
  }

  print('Continua com ${cofre.moedas} moedas');
}
