void main() {
  List<String> nomes = <String>["Ana", "João", "Maria"];
  String frase = "Parou! Este código não continua.";

  imprimeNumero();
  print("");
  listaNomes(nomes);
  print("");
  imprimeExclamacao(frase);
}

void imprimeNumero() {
  for (var i = 1; i <= 5; i++) {
    print("Número: $i");
  }
}

void listaNomes(List<String> nomes) {
  for (String nome in nomes) {
    print("Nome: $nome");
  }
}

void imprimeExclamacao(String texto) {
  for (var i = 0; i < texto.length; i++) {
    if (texto[i] == "!") {
      print('"!" encontrado, parando programa...' );
      break;
      };
    print(texto[i]);
  }
}
