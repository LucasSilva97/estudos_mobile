
import 'dart:async';
import 'dart:math';

void main(){
  final minutos = <int>[90, 120, 0, 40, 150];
  final materias = <String>['Dart', 'Flutter', 'Git']; // literal
  final vazia = <int>[]; // vazia, cresce depois
  final zeros = List<int>.filled(3, 0); // [0, 0, 0] - tamanho FIXO
  final blocos = List<int>.generate(5, (i) => (i++) * 25); // [25, 50, 75, 100, 125]
  final copia = List<String>.of(materias); // cria uma cópia independente de outra lista
  
  final nomes = <String>['Dart', 'Flutter', 'GOOGLE', 'android'];


  print(materias[0]);               /// Vai retornar Dart - o primeiro elemento de uma lista é o índice zero
  print(materias.first);            /// Traz o primeiro elemento da lista
  print(materias.last);             /// Traz o último elemento da lista
  print(materias.length);           /// Traz o tamanho da lista
  print(materias.isEmpty);          /// Testa se a lista está vazia
  print(materias.isNotEmpty);       /// Testa se a lista não está vazia
  print(materias.contains('Git'));  /// Aqui vai testar se contém esse elemento na lista
  print(materias.indexOf('Git'));   /// Testa qual o índice do elemento, se existir exibe o índice ou,
  print(materias.indexOf('Kotlin'));   /// se não existir, deve exibir o -1

  /**1. MODIFICANDO AS LISTAS */
  print('');
  print('=== Lista original ===');
  print(materias);

  // Fazendo as alterações
  materias.add('SQL');                              /// Adiciona um elemento no fim (semelhante ao append do python)
  materias.addAll(<String>['Testes', 'Testes 2']);  /// Permite adiciona vários elementos no fim
  materias.insert(1, 'Lógica');                     /// Adiciona um elemento numa posição específica (isso move o elemento existente hoje para uma posição atrás)
  materias.remove('SQL');                           /// remove o primeiro elemento igual ao especificado no parâmetro
  materias.removeAt(0);                             /// Remove o elemento por índice
  materias.removeWhere((qualquerNome) => qualquerNome.length > 6); /// Remove o elemento mediante condição
  // materias.clear();                                  /// Esvazia toda a lista

  print('');
  print("Lista alterada: $materias");

  /**2. Montando listas: spread operator, collection-if e collection-for */
  // final todas = <String>[...basicas, ...extras, 'Testes']; /// spread
  // final segura = <String>[...basicas, ...?talvezNulas]; // spread seguro

  // final plano = <String>[
  //   'Abertura',
  //   for (final m in minutos) if (m > 0) '$m min',
  //   if(incluirExtras) 'Revisão extra',
  //   'Encerramento',
  // ];

  /**3. Transformando: map e where */
  print('');
  print('=== Lista original ===');
  print(minutos);

  final dobrados = minutos.map((m)=> m * 2).toList(); /// O não uso do toList() faz retornar um record, e não uma lista
  print('Lista dobrada: $dobrados');
  final validos= minutos.where((m)=> m > 0 && m <= 240).toList();
  print('Válidos: $validos');
  //Ambos retornam um iterable, mas ele é preguiçoso.
  //Nesse caso é preciso usar a função toList() para indicar para ele que queremos criar uma lista

  /**4. Outros transformadores */
  // Esses transformadores abaixo vão retornar records, para retornar uma lista, use o toList()
  print('Os 3 primeiros elementos:${minutos.take(3)}'); // retorne os 3 primeiros
  print('Pulando 3 primeiros: ${minutos.skip(3)}'); // pule os 3 primeiros
  print('Exibindo a ordem invertida: ${minutos.reversed}'); 
  print(minutos.join(', ')); // Vai juntar todos os elementos de uma lista, usando um separador.

  /**5. Consultando */
  print(minutos.any((element) => element > 50)); // existe pelo menos um que atende essa condição?
  print(minutos.every((element) => element > 0)); // todos os elementos satisfazem essa condição?
  print(minutos.indexWhere((element) => element == 0)); // índice do primeiro item que satisfaça essa condição na lista
  print(minutos.firstWhere((m) => m >= 90, orElse: () => -1)); 
  
  /**6. Usando acumuladores: reduce e fold */
  List <int> valores = <int>[1, 2, 3, 4, 5, 6];
  final soma = valores.reduce((a, b) => a + b);     //exige lista não vazia/não nula
  print('Soma acumulada: $soma');
  final total = valores.fold<int>(0, (acc, m) => acc + m); // funcionacom lista vazia, pois na função é determinada o valor padrão
  print('Total: $total');
  final texto = valores.fold<String>('', (txt, m) => '$txt[$m]');
  print(texto);

  /**7. Ordenando */
  print('');
  final copiaMinutos = List<int>.of(minutos);
  print('Cópia original $copiaMinutos');
  copiaMinutos.sort();      // ordem crescente, MOIDIFICA a lista
  print('Cópia crescente: $copiaMinutos');
  copiaMinutos.sort((a, b) => b.compareTo(a)); // ordem descrecente, também MODIFICA a lista
  print('Cópia decrescente $copiaMinutos'); 
  nomes.sort((a, b)=> a.toLowerCase().compareTo(b.toLowerCase())); // garante ignorar se maiúscula ou minúscula, igualando os items à minúscula dentro da comparação
  print(nomes);

  // Para ordernar uma lista numa linha, com sort, deve se usar a cascata '..',
  // pois sort retorna void().

  final ordenada = List<int>.of(minutos)..sort();
  print(ordenada);

  /// Cascata - vai achmar um método no objeto e devolve o próprio objeto, e não o resultado do método.
  
  /**8. Listas imutáveis */
  const fixa = <String>['Dart', 'Flutter']; // const deixa a lista imutável, congelada na compilação
  final protegida = List<String>.unmodifiable(materias); // cópia congelada, mudanças na lista original deois disso não aparecem nessa,
    /// List<String>.unmodifiable(materias) - vai guardar um snapshot na compilação do estado em que a lista se encontrava. 
    /// 
  
  


}