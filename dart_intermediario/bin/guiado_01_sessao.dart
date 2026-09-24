class SessaoDeEstudo {
  String materia = 'Sem matéria';
  int minutos = 0;
  bool concluida = false;

  SessaoDeEstudo(String materia, int minutos) {
    this.materia = materia;
    this.minutos = minutos;
  }

  void concluir() {
    concluida = true;
  }

  String duracaoFormatada() {
    final horas = minutos ~/ 60;
    final restante = minutos % 60;
    if (horas == 0) {
      return '${restante}min';
    }

    if (restante == 0) {
      return '${horas}h';
    }

    return '${horas}h ${restante}min';
  }

  String resumo() {
    final estado = concluida ? 'concluída' : 'em andamento';
    return '$materia - ${duracaoFormatada()} ($estado)';
  }
}

void main() {
  final manha = SessaoDeEstudo('Dart', 90);
  final noite = SessaoDeEstudo('Flutter', 45);

  manha.concluir();

  print(manha.resumo());
  print(noite.resumo());
}
