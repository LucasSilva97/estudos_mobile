import 'dart:io';

void main() {

  List<String> nomes = [];
  List<List<double>> notas = [];

  menu(nomes, notas);
}

void registrarAluno(List<String> nomes, List<List<double>> notas) {
  print("Digite o nome do aluno: ");
  String? nome = stdin.readLineSync();

  if (nome != null) {
    nomes.add(nome);
    List<double> notasAluno = [];

    while (true) {
      print('Digite uma nota para o aluno (ou "fim" para terminar): ');
      String? entrada = stdin.readLineSync();

      if (entrada == "fim") {
        break;
      } else if (entrada != null ) {
        double nota = double.parse(entrada);
        notasAluno.add(nota);
      }
    }

    notas.add(notasAluno);
  } else {
    print("Nome inválido.");
  }
}

double calcularMedia(List<double> notas) {
  double soma = 0;
  for (double nota in notas){
    soma += nota;
  }

  return soma / notas.length;
}

void listarAlunos(List<String> nomes, List<List<double>> notas) {
  print("Lista de alunos e suas médias: ");
  for (int i = 0; i < nomes.length; i++){
    double media = calcularMedia(notas[i]);
    print("${nomes[i]}: ${media.toStringAsFixed(2)}");
  }
}

void menu(List<String> nomes, List<List<double>> notas) {
  String? acao = "";

  while (acao != "sair") {
    print("Escolha uma ação: registrar, listar, sair");
    acao = stdin.readLineSync();

    switch (acao) {
      case 'registrar':
        registrarAluno(nomes, notas);
        break;
      case 'listar':
        listarAlunos(nomes, notas);
        break;
      case 'sair':
        print('Saindo...');
        break;
      default:
        print('Ação inválida!');
    }
  }
}