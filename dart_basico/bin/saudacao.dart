void main(List<String> argumentos) {
  print('=== Saudação configurável ===');
  print('Quantidade de argumentos recebidos: ${argumentos.length}');

  if (argumentos.isEmpty) {
    print('');
    print('Você não passou nenhum argumento.');
    print('Uso: dart run bin/saudacao.dart <nome> [manha|tarde|noite]');
    return;
  }

  final String nome = argumentos[0];

  // Se o segundo argumento não veio, usamos 'dia' como valor padrão.
  final String periodo = argumentos.length >= 2 ? argumentos[1] : 'dia';

  final String cumprimento;
  if (periodo == 'manha') {
    cumprimento = 'Bom dia';
  } else if (periodo == 'tarde') {
    cumprimento = 'Boa tarde';
  } else if (periodo == 'noite') {
    cumprimento = 'Boa noite';
  } else {
    cumprimento = 'Olá';
  }

  print('');
  print('$cumprimento, $nome');
  print('Este programa rodou a partir da função main de bin/saudacao.dart.');
  
  // Mostra todos os argumentos numerados, um por linha
  print('');
  print('Argumentos, um a um:');
  for (int i = 0; i < argumentos.length; i++){
    print('  [$i] ${argumentos[i]}');
  }
}

