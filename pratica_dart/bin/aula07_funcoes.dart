
/// Assinatura de um validador de texto
/// 
/// Devolve a mensagem de erro, ou `null` quando a entrada é válida.
typedef Validador = String? Function(String entrada);

/// 1. Parâmetros posicionais obrigatórios - usando arrow function
String formatar(String materia, int minutos) => '$materia: $minutos min';

/// 2. Parâmetro posicional opcional com valor padrão
String registrar(String materia, [int minutos = 25]) => '$materia por $minutos min';

/// 3. Parâmetros nomeados, todos com valor padrão
String planejar({
  String materia = 'Dart',
  int minutos = 25,
  bool revisao = false,
}) => '$materia | $minutos min | ${revisao ? 'revisão' : 'novo conteúdo'}';

/// 4. Parâmetros nomeados obrigatórios e um opcional anulável.
String agendar({
  required String materia,
  required int minutos,
  String? observacao,
}) {
  final String obs = observacao ?? 'sem observação';
  return '$materia | $minutos min | $obs';
}

/// 5. Arrow function
int dobro(int valor) => valor * 2;

/// Formata os minutos alinhados à direita, em três colunas.
String formatarMinutos(int minutos) => '${minutos.toString().padLeft(3)} min';

/// Validador: recusa entrada vazia.
String? validarNaoVazio(String entrada) =>
    entrada.trim().isEmpty ? 'Não pode ficar vazio' : null;

/// Validador: recusa entrada que não seja inteiro.
String? validarNumero(String entrada) =>
    int.tryParse(entrada.trim()) == null ? 'Digite um número inteiro' : null;

/// Aplica os [validadores] em ordem e devolve o primeiro erro encontrado.
String? primeiroErro(String entrada, List<Validador> validadores) {
  for (final Validador validar in validadores) {
    final String? erro = validar(entrada);
    if(erro != null) return erro;
  }
  return null;
}

/// Closure: devolve uma função que conta quantas vezes foi chamada.
int Function() criarContadorDeSessoes(){
  int total = 0;
  return () {
    total++;
    return total;
  };
}

/// Closure que captura o parâmetro [fator]
int Function(int) multiplicadorPor(int fator) => (int valor) => valor * fator;

/// Recebe callbacks e decide quando chamá-los
void processarSessoes(
  List<int> sessoes, {
    required void Function(int minutos) aoAceitar,
    required void Function(int minutos, String motivo) aoRejeitar,
  }) {
    for (final int minutos in sessoes) {
      if (minutos <= 0) {
        aoRejeitar(minutos, 'duração precisa ser positiva');
      } else if (minutos > 240) {
        aoRejeitar(minutos, 'acima do limite de 240 min');
      } else {
        aoAceitar(minutos);
      }
    }
  }

/// Devolve dois valores de uma vez, em um record.
(int, double) resumir(List<int> valores){
  if (valores.isEmpty) return (0, 0.0);
  int soma = 0;
  for (final int valor in valores){
    soma += valor;
  }
  return (soma, soma / valores.length);
}


void main() {
  const List<int> sessoes = <int>[45, 0, 120, 300, 30];

  print('=== 1. Posicionais obrigatórios ===');
  print(formatar('Dart', 45));

  print('');
  print('=== 2. Posicional opcional com padrão ===');
  print(registrar('Flutter'));
  print(registrar('Git', 50));

  print('');
  print('=== 3. Nomeados com valor padrão ===');
  print(planejar());
  print(planejar(materia: 'Flutter', minutos: 60));
  print(planejar(revisao: true, materia: 'Git'));

  print('');
  print('=== 4. Nomeados obrigatórios (required) ===');
  print(agendar(materia: 'Dart', minutos: 90));
  print(agendar(minutos: 45, materia: 'Flutter', observacao: 'widgets'));

  print('');
  print('=== 5. Arrow function ===');
  print('dobro(21) = ${dobro(21)}');

  print('');
  print('=== 6. Funções anônimas ===');
  final List<String> rotulos =
      sessoes.map((int m) => m >= 90 ? 'longa' : 'curta').toList();
  print('rótulos: $rotulos');

  // Tear-off: referencia a função pelo nome, sem parênteses.
  final String Function(int) formatarMin = formatarMinutos;
  print('guardada em variável: "${formatarMin(45)}"');

  print('');
  print('=== 7. typedef e funções como valor ===');
  const List<Validador> validadores = <Validador>[
    validarNaoVazio,
    validarNumero,
  ];
  for (final String entrada in <String>['', '  ', 'abc', '45']) {
    final String? erro = primeiroErro(entrada, validadores);
    print('"$entrada" -> ${erro ?? 'válido'}');
  }

  print('');
  print('=== 8. Closures ===');
  final int Function() contar = criarContadorDeSessoes();
  print('contar() = ${contar()}');
  print('contar() = ${contar()}');
  print('contar() = ${contar()}');
  final int Function() outroContador = criarContadorDeSessoes();
  print('outroContador() = ${outroContador()}  (estado independente)');

  final int Function(int) triplicar = multiplicadorPor(3);
  print('triplicar(15) = ${triplicar(15)}');

  print('');
  print('=== 9. Callbacks ===');
  processarSessoes(
    sessoes,
    aoAceitar: (int m) => print('  aceita   : $m min'),
    aoRejeitar: (int m, String motivo) => print('  rejeitada: $m min ($motivo)'),
  );

  print('');
  print('=== 10. Devolvendo dois valores ===');
  final (total, media) = resumir(sessoes);
  print('total = $total min, média = ${media.toStringAsFixed(1)} min');
}