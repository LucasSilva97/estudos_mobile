// PRINCIPAIS FUNÇÕES DE LISTA
void main() {
  var frutas = ['banana', 'abacaxi', 'melancia'];

  // 1. forEach()
  // Executa uma função em cada elemento da lista.
  frutas.forEach((fruta) => print(fruta));

  //2. map()
  // Gera uma nova lista após transformar cada elemento em uma lista dada.
  print('');
  var mapeadasFrutas = frutas.map((fruta) => 'Eu amo $fruta');
  print(mapeadasFrutas);
  mapeadasFrutas.forEach((mensagemFruta) => print(mensagemFruta));
  print('');

  //3. contains()
  // Verifica se o elemento em questão está presente na lista
  var numeros = [1, 3, 2, 5, 4];
  print(numeros.contains(2)); // => true
  print(numeros.contains(10)); // => false

  //4. sort() - ordenar
  // Ordena os elementos com base na função de ordenação definida
  numeros.sort((num1, num2) => num1 - num2);
  print(numeros);

  //5. reduce(), fold()
  // Comprime os elementos em um único valor, usando a função fornecida
  print('');
  var soma = numeros.reduce(
    (valorAtual, proximoValor) => valorAtual + proximoValor,
  );
  print(soma);

  const valorInicial = 10;
  var soma2 = numeros.fold(valorInicial, (atual, proximo) => atual + proximo);
  print(soma2);
  print('');

  //6. every() - cada
  // Confirma se todos, e somente TODOS, atendem ao teste definido na função
  List<Map<String, dynamic>> usuarios = [
    {"nome": "João", "idade": 18},
    {"nome": "Jane", "idade": 21},
    {"nome": "Maria", "idade": 23},
  ];

  var ehMaiorDeIdade = usuarios.every((usuario) => usuario["idade"] >= 18);
  print(ehMaiorDeIdade);
  
  var nomeInicialJ = usuarios.every((usuario) => usuario["nome"].startsWith("J"));
  print(nomeInicialJ);
  
  //7. where(), firtsWhere(), singleWhere()
  // Retorna uma coleção de elementos que satisfazem um teste, sem alterar a original
  
  // retorna todos que atendem a condição
  var maiorQue21 = usuarios.where((usuario) => usuario["idade"] > 21);
  print("Usuário com mais de 21 anos de idade: $maiorQue21");
  print("Quantos? ${maiorQue21.length}");
  
  // retorna o primeiro que atender a condição
  var nomeJ = usuarios.firstWhere((usuario) => usuario["nome"].startsWith("J"));
  print(nomeJ);
  print('');
  // E se nenhum começasse por J ?
  /*
  List<Map<String, dynamic>> usuariosDois = [
    {"nome": "Moana", "idade": 18},
    {"nome": "Darc", "idade": 21},
    {"nome": "Luiz", "idade": 23},
  ];*/
  
 /* var nomeJDois = usuariosDois.firstWhere((usuario) => usuario["nome"].startsWith("J"),
                                         orElse: () => null);*/
  
  // print(nomeJDois);
  
  //8. take, skip - "pegar" ou "pular"
  var fiboNumeros = [1, 2, 3, 5, 8, 13, 21];
  print(fiboNumeros.take(3).toList()); // percorra 3 elementos
  print(fiboNumeros.skip(5).toList()); // pule 5 elementos
  print('');
  
  //9. List.from()
  // Cria uma nova lista a partir da coleção fornecida.
  var clonadoFiboNumeros = List.from(fiboNumeros);
  print("Lista clonada: $clonadoFiboNumeros");
  print('');
  
}









