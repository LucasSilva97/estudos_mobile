// bin/estilo.dart
// Demonstra: convenções de nome, os três tipos de comentário e dartdoc.

/// Quantidade de minutos que compõem uma hora.
///
/// Constante nomeada em lowerCamelCase — Dart não usa MAIUSCULA_COM_SUBLINHADO.
/// 
library;


const int minutosPorHora = 60;

/// Uma sessão de estudo registrada pela pessoa que estuda.
///
/// Classes usam UpperCamelCase. Esta é uma versão bem simples;
/// classes são o assunto do módulo 03.
class SessaoDeEstudo {
  /// Cria uma sessão com o nome da [materia] e a duração em [minutos].
  SessaoDeEstudo(this.materia, this.minutos);

  /// Nome da matéria estudada, por exemplo `Dart`.
  final String materia;

  /// Duração da sessão, em minutos. Nunca negativa.
  final int minutos;
}

/// Converte [minutos] em um texto legível.
///
/// Devolve `2h15` quando há horas completas e `45min` quando não há.
/// Lança [ArgumentError] se [minutos] for negativo.
String formatarDuracao(int minutos) {
  if (minutos < 0) {
    throw ArgumentError.value(minutos, 'minutos', 'Não pode ser negativo');
  }

  final int horas = minutos ~/ minutosPorHora; // ~/ é divisão inteira
  final int resto = minutos % minutosPorHora; // % é o resto da divisão

  if (horas == 0) {
    return '${resto}min';
  }
  if (resto == 0) {
    return '${horas}h';
  }
  // padLeft garante 05 em vez de 5, para ficar 2h05.
  return '${horas}h${resto.toString().padLeft(2, '0')}';
}

/// Monta uma linha de relatório para uma [sessao].
/// Completando os caracteres a esquerda
String descrever(SessaoDeEstudo sessao) {
  final String duracao = formatarDuracao(sessao.minutos);
  return '${sessao.materia.padRight(12)} $duracao';
}

void main() {
  /*
    Comentário de bloco: útil para uma explicação longa ou para
    desativar um trecho durante a depuração. Evite abusar dele —
    código comentado que fica no arquivo confunde quem lê depois.
  */

  final List<SessaoDeEstudo> sessoes = <SessaoDeEstudo>[
    SessaoDeEstudo('Dart', 135),
    SessaoDeEstudo('Flutter', 45),
    SessaoDeEstudo('Git', 60),
    SessaoDeEstudo('Inglês', 20),
  ];

  print('=== Relatório de estudo ===');

  // Soma acumulada dos minutos de todas as sessões.
  int total = 0;
  for (final SessaoDeEstudo sessao in sessoes) {
    print(descrever(sessao));
    total += sessao.minutos;
  }

  print('-' * 20); // repete o traço 20 vezes
  print('${'TOTAL'.padRight(12)} ${formatarDuracao(total)}');

  // Demonstração do erro tratado: duração negativa não é aceita.
  try {
    formatarDuracao(-10);
  } on ArgumentError catch (erro) {
    print('');
    print('Erro capturado como esperado: $erro');
  }
}
