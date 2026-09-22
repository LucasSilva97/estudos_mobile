String classificar(int minutos) => switch (minutos) {
  < 0 => 'inválida',
  0 => 'sem estudo',
  < 25 => 'muito curta',
  < 50 => 'curta',
  < 90 => 'média',
  _ => 'longa',
};

/*
String mensagemDoDia(String dia) {
  switch (dia) {
    case 'sab' || 'dom':
      return 'Fim de semana: revisão leve.';
    case 'seg':
      return 'Começo de semana: conteúdo novo.';
    case 'sex':
      return 'Sexta: feche o ciclo com exercícios.';
      default:
        return 'Dia útil: siga o plano';
  }
}*/

String mensagemDoDia(String dia) => switch (dia) {
  'sab' || 'dom' => 'Fim de semana: revisão leve.',
  'seg' => 'Conteúdo novo.',
  'sex' => 'Sexta: feche o ciclo com exercícios.',
  _ => 'Dia útil: siga o plano.',
};

/// Registra uma sessão. Usa assert para checar suposições do desenvolvimento
void registrarSessao(String materia, int minutos) {
  assert(materia.isNotEmpty, 'A matéria não pode ser vazia');
  assert(minutos > 0, 'Minutos deve ser maior que zero, recebi $minutos');
  print('Registrado: $materia por $minutos min');
}

void main() {
  const List<int> sessoes = <int>[45, 0, 120, -10, 30, 75];
  const List<String> dias = <String>['seg', 'ter', 'sex', 'sab', 'dom'];
  const int meta = 300;

  print('=== 1. if / else if / else ===');
  int total = 0;
  for (final int m in sessoes) {
    if (m > 0) total += m;
  }
  if (total >= meta) {
    print('Total $total min: meta de $meta atingida.');
  } else if (total >= meta * 0.7) {
    print('Total $total min: perto da meta de $meta');
  } else {
    print('Total $total min: ainda longe da meta de $meta.');
  }

  print('');
  print('=== 2. switch statement ===');
  for (final String dia in dias) {
    print('${dia.padRight(4)}-> ${mensagemDoDia(dia)}');
  }

  print('');
  print('=== 3. switch expression com padrões relacionais ===');
  for (final int m in sessoes) {
    print('${m.toString().padLeft(4)} min -> ${classificar(m)}');
  }

  print('');
  print('=== 4. switch expression com guarda (when) ===');
  for (final int m in sessoes) {
    final String conselho = switch (m) {
      final int v when v < 0 => 'corrija o registro',
      0 => 'registre ao menos uma sessão',
      final int v when v >= 90 => 'faça uma pausa de 10 min',
      _ => 'siga assim',
    };
    print('${m.toString().padLeft(4)} min -> $conselho');
  }

  print('');
  print('=== 5. for clássico com índice ===');
  for (int i = 0; i < sessoes.length; i++) {
    print('Sessão ${i + 1} de ${sessoes.length}: ${sessoes[i]} min');
  }

  print('');
  print('=== 6. for-in com continue ===');
  int validas = 0;
  for (final int m in sessoes) {
    if (m <= 0) continue;
    validas++;
  }
  print('Sessões válidas: $validas de ${sessoes.length}');

  print('');
  print('=== 7. indexed: índice e valor juntos ===');
  for (final (indice, minutos) in sessoes.indexed) {
    print('[$indice] $minutos min (${classificar(minutos)})');
  }

  print('');
  print('=== 8. while e do-while ===');
  int restante = 300;
  int blocos = 0;
  while (restante >= 25) {
    restante -= 25;
    blocos++;
  }

  int tentativa = 0;
  do {
    tentativa++;
  } while (tentativa < 3);
  print('300 min cabem em $blocos blocos de 25 min, sobrando $tentativa vezes');

  print('');
  print('=== 9. break, continue e labels ===');
  const List<List<int>> semanas = <List<int>>[
    <int>[30, 45, 60],
    <int>[0, 20, 40],
    <int>[15, 120, 35],
  ];

  busca:
  for (final (semana, minutosDaSemana) in semanas.indexed) {
    for (final (dia, minutos) in minutosDaSemana.indexed) {
      if (minutos == 0) {
        print(
          'Semana ${semana + 1}, dia ${dia + 1}: sem estudo, pulando a semana',
        );
        continue busca;
      }
      if (minutos >= 90) {
        print(
          'Semana ${semana + 1}, dia ${dia + 1}: $minutos min, maratona encontrada',
        );
        break busca;
      }
    }
  }

  print('');
  print('=== 10. assert ===');
  try {
    registrarSessao('Dart', 45);
    registrarSessao('Flutter', -5);
  } on AssertionError catch (erro) {
    print('AssertionError capturado: ${erro.message}');
  }
}
