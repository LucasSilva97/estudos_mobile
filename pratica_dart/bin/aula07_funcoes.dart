
/// Assinatura de um validador de texto
/// 
/// Devolve a mensagem de erro, ou `null` quando a entrada é válida.
typedef Validador = String? Function(String entrada);

/// 1. Parâmetros posicionais obrigatórios - usando arrow function
String formatar(String materia, int minutos) => '$materia: $minutos min';

/// 2. Parâmetro posicional opcional com valor padrão
String registrar(String materia, [int minutos = 25]) => '$materia por $minutos min';

void main(){
  print(formatar('Flutter', 90));
  print(registrar('Dart'));
}