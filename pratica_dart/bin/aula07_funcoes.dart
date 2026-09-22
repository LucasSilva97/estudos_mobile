
/// Assinatura de um validador de texto
/// 
/// Devolve a mensagem de erro, ou `null` quando a entrada é válida.
typedef Validador = String? Function(String entrada);

/// 1. Parâmetros posicionais obrigatórios - usando arrow function
String formatar(String materia, int minutos) => '$materia: $minutos min';

void main(){
  print(formatar('Flutter', 90));
}