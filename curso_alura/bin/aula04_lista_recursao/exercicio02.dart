import 'dart:io';

void main() {
  List<String> tipos = ['pdf', 'jpg', 'png', 'docx'];
  String? tipo;

  tipo = validaTipo(tipo, tipos);

  print('Tipo válido: $tipo');
}

String? validaTipo(String? tipo, List<String> tipos) {
  print('Digite o tipo do arquivo (pdf, jpg, png, docx):');
  tipo = stdin.readLineSync();
  if (tipos.contains(tipo)) {
    return tipo;
  } else {
    print('Tipo inválido. Tente novamente.');
    return validaTipo(tipo, tipos);
  }
}