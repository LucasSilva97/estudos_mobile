import 'dart:io';

String? lerTextoObrigatorio(String pergunta) {
  while (true) {
    stdout.write(pergunta);
    final linha = stdin.readLineSync();
    if (linha == null) return null;
    final texto = linha.trim();
    if (texto.isNotEmpty) return texto;
    stderr.writeln('Digite um texto não vazio.');
  }
}

int? lerInteiroPositivo(String pergunta) {
  while (true) {
    stdout.write(pergunta);
    final linha = stdin.readLineSync();
    if (linha == null) return null;
    final valor = int.tryParse(linha.trim());
    if (valor != null && valor > 0) return valor;
    stderr.writeln('Digite um número inteiro maior que zero.');
  }
}

void main() {
  final materia = lerTextoObrigatorio('Matéria: ');
  if (materia == null) {
    stderr.writeln('Entrada encerrada antes da matéria.');
    exitCode = 2;
    return;
  }

  final meta = lerInteiroPositivo('Meta semanal em minutos: ');
  if (meta == null) {
    stderr.writeln('Entrada encerrada antes da meta.');
    exitCode = 2;
    return;
  }

  final sessoes = <int>[];
  while (true) {
    stdout.write('Minutos da sessão (vazio para concluir): ');
    final linha = stdin.readLineSync();
    if (linha == null || linha.trim().isEmpty) break;
    final minutos = int.tryParse(linha.trim());
    if (minutos == null || minutos <= 0) {
      stderr.writeln('Sessão ignorada: use um inteiro maior que zero.');
      continue;
    }
    sessoes.add(minutos);
  }

  final total = sessoes.fold<int>(0, (soma, valor) => soma + valor);
  final falta = meta - total;
  print('');
  print('=== Relatório ===');
  print('Matéria: $materia');
  print('Sessões válidas: ${sessoes.length}');
  print('Total: $total min');
  if (falta > 0) {
    print('Faltam $falta min para a meta.');
  } else {
    print('Meta atingida!');
  }
}
