/// Valor fixo, conhecido ainda em tempo de compilação
const int minutosPorHora = 60;

/// Matérias padrão sugeridas pelo cursos
/// 
/// `const` congela a lista inteira: ninguém consegue acrescentar itens.
const List<String> materiasPadrao = <String>['Dart', 'Flutter', 'Git'];

/// Simula um cálculo demorado, para demonstrar o `late` preguiçoso.
String gerarRelatorioCaro(){
  print('   >>gerarRelatorioCaro() executou agora');
  return 'Relatório completo do mês';
}

void main(){
  print('=== 1. Inferência de tipo ===');
  var minutos = 45; //inferido como int
  final nome = 'Lucas'; // inferido como String
  const meta = 600; // inferido como int
  print('minutos é ${minutos.runtimeType}, valor $minutos');
  print('nome é ${nome.runtimeType}, valor $nome');
  print('meta é ${meta.runtimeType}, valor $meta');

  print('');
  print('=== 2. var pode ser reatribuída ===');
  minutos = 90;
  minutos += 30;
  print('minutos agora: $minutos');

  print('');
  print('=== 3. const é compartilhado na memória ===');

  const List<int> a = <int>[1, 2, 3];
  const List<int> b = <int>[1, 2, 3];
  const List<int> c = <int>[1, 2, 3];
  const List<int> d = <int>[1, 2, 3];
  print('identical(a, b) com const: ${identical(a, b)}');
  print('identical(c, d) com const: ${identical(c, d)}');

  print('');
  print('=== 4. final protege a variável, não o conteúdo ===');
  final List<String> minhasMaterias = <String>['Dart', 'Flutter'];
  minhasMaterias.add('Git'); // permitido
  print('Depois do add: $minhasMaterias');
  // minhasMaterias = <String>['Outra'];  // não compila: reatribuição, só é permitido mexer no valor já existente em memória

  print('');
  print('=== 5. const congela o conteúdo ===');
  print('Matérias padrão: $materiasPadrao');

  try {
    materiasPadrao.add('Kotlin');
  } on UnsupportedError catch (erro)  {
    print('Erro esperado ao tentar modificar: ${erro.message}');
  }

  print('');
  print('=== 6. const só aceita valor de tempo de compilação ===');
  const int horasPorSemana = 24 * 7;
  final DateTime agora = DateTime.now();
  print('horasPorSemana: $horasPorSemana');
  print('Ano atual (final, em execução): ${agora.year}');

  print('');
  print('=== 7. late com inicializador é preguiçoso ===');
  print('Antes de ler a variável...');
  late final String relatorio = gerarRelatorioCaro();
  print('Declarada, mas ainda não executou.');
  print('Primeira leitura: $relatorio');
  print('Segunda leitura : $relatorio');

  print('');
  print('=== 8. late sem inicializador exige disciplina ===');
  late String periodo;
  final int hora = agora.hour;
  if (hora < 12) {
    periodo = 'manhã';
  } else if (hora < 18) {
    periodo = 'tarde';
  } else {
    periodo = 'noite';
  }
  print('Período do dia: $periodo');

  print('');
  print('=== 9. Escolhendo na prática ===');
  const String unidade = 'min';
  final List<int> sessoes = <int>[45, 30, minutos];
  var total = 0;
  for(final int sessao in sessoes) {
    total += sessao;
  }

  final int horas = total ~/ minutosPorHora;
  final int resto = total % minutosPorHora;

  print('Sessões: $sessoes');
  print('Total: $total $unidade -> ${horas}h${resto.toString().padLeft(2, '0')}');
  print('Meta do dia: $meta - $unidade');
  print('Faltam: ${meta - total} $unidade');

}

