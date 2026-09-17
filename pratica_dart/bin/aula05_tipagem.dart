void main() {
  // Número -> Texto
  print(240.toString()); //converte para string
  print(8.75.toStringAsFixed(1)); // converte para string e determina qtd de casas decimais
  print(8.75.toStringAsFixed(0)); // converte para string e arredonda o valor

  // Texto -> Número
  print(int.parse('200'));

  // Trabalhando conversão com valor nulo
  int? valor = int.tryParse('cento e oitenta'); // ? vai garantir que a variável possa receber valor nulo sem dar erro de compilação
  print(valor);

  // Comparando entre int e double
  print(240.toDouble()); // um ponto flutuante
  print(8.75.toInt()); // TRUNCA o valor
  print(8.75.round()); // arredonda pro mais próximo
  print(8.75.floor()); 
  print(8.75.ceil());
}