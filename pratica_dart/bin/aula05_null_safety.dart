// Demonstra: T?, ?., ??, ??=, !, promoção de tipo e padrões seguros.

/// Uma matéria de estudo. `observacao` é opcional de verdade.

class Materia {
  Materia(this.nome, {this.observacao, this.minutosMeta});

  /// Sempre existe: não pode ser de tipo anulável
  final String nome;

  /// Pode não existir(não é obrigatório): tipo anulável
  final String? observacao;

  /// Meta de minutos por semana; `null` significa "sem meta definida"
  final int? minutosMeta;
}

  /// Devolve os minutos válidos de [entrada] ou `null` se não der para converter.
  int? converterMinutos(String? entrada) {
    if (entrada == null) return null;
    final String limpo = entrada.trim();
    if (limpo.isEmpty) return null;
    final int? valor = int.tryParse(limpo);
    if (valor == null || valor < 0) return null;
    return valor;
  }

  /// Procura o apelido de [nome] em um cadastro que, neste exemplo, está vazio.
  /// 
  /// Existe para produzir um `null` que o compilado não consegue prever
  String? buscarApelido(String nome) {
    const Map<String, String> cadastro = <String, String> {};
    return cadastro[nome];
  }

  /// Monta a linha de relatório de uma [materia], sem nunca usar `!`.
  String descrever(Materia materia) {
    // ?? dá um padrão quando o valor é nulo.
    final String observacao = materia.observacao ?? '(sem observação)';

    // Cópia local + promoção de tipo: dentro do if, meta é int.
    final int? meta = materia.minutosMeta;
    final String textoMeta;
    if (meta != null) {
      textoMeta = 'meta de $meta min/semana (${meta ~/ 60}h aprox.)';
    } else {
      textoMeta = 'sem meta';
    }

    return '${materia.nome.padRight(10)} | $observacao | $textoMeta';
  }

void main(){

  // final String? teste = buscarApelido('Ana');
  // print(teste!.length);

  print('=== 1. Anulável x não anulável ===');
  const String nome = 'Lucas'; // nunca null
  String? apelido;
  print('nome   : $nome');
  print('apelido: $apelido');

  print('');
  print('=== 2. Operador ?. (acesso seguro) ===');
  print('apelido?.length        :${apelido?.length}');
  print('apelido?.toUpperCase   :${apelido?.toUpperCase()}');
  apelido = 'Lu';
  print('depois de atribuir     :${apelido?.length}');

  print('');
  print('=== 3. Operador ?? (padrão) ===');
  String? temaEscolhido;
  print('tema: ${temaEscolhido ?? 'claro (padrão)'}');
  final int minutosSeguros = int.tryParse('abc') ?? 0;
  print('int.tryParse("abc") ?? 0 = $minutosSeguros');

  print('');
  print('=== 4. Operador ??= (atribui só se nulo) ===');
  temaEscolhido ??= 'claro';
  print('primeira atribuição: $temaEscolhido');
  // temaEscolhido ??= 'escuro';
  // print('segunda tentativa: $temaEscolhido');

  print('');
  print('=== 5. Promoção de tipo ===');
  final String? entradaUsuario = '135';
  final int? minutos = converterMinutos(entradaUsuario);
  if(minutos != null) {
    print('Convertido: $minutos min, o dobro é ${minutos * 2}');
  } else {
    print('Entrada inválida.');
  }

  print('');
  print('=== 6. Saída antecipada também promove ===');
  for (final String? teste in <String?> ['90', null, '', 'abc', '  45  ', '-5']){
    final int? valor = converterMinutos(teste);
    final String rotulo = teste == null ? 'null' : '"$teste"';
    print('$rotulo -> ${valor ?? 'invalido'}');
  }

  print('');
  print('=== 7. Spread seguro e lista anulável');
  List<String>? extras;
  final List<String> materiasBase = <String>['Dart', 'Flutter'];
  print('sem extras : ${<String>[...materiasBase, ...?extras]}');
  extras = <String>['Git', 'SQL'];
  print('com extras : ${<String>[...materiasBase, ...?extras]}');

  print('');
  print('=== 8. Objetos com campos opcionais ===');
  final List<Materia> materias = <Materia>[
    Materia('Dart', observacao: 'revisar null safety', minutosMeta: 300),
    Materia('Flutter', minutosMeta: 300),
    Materia('Git', observacao: 'praticar rebase'),
    Materia('Inglês'),
  ];
  for (final Materia materia in materias) {
    print(descrever(materia));
  }

  print('');
  print('=== 9. O operador ! e o erro que ele causa ===');
  final String? valorAusente = buscarApelido('Lucas');
  try {
    final int tamanho = valorAusente!.length;
    print('nunca chega aqui: $tamanho');
  } on TypeError catch (erro) {
    print('Capturado: $erro');
  }

  print('');
  print('=== 10. As alternativas ao ! ===');
  print('com ?.   :${valorAusente?.length}');   
  print('com ??   :${valorAusente?? 'texto fallback'}');   
  print('com ?.??   :${valorAusente?.length ?? 0}');

  if (valorAusente != null){
    print('com if   :${valorAusente.length}');
  }  else {
    print('com if   : valor ausente, nada a fazer');
  }
}
