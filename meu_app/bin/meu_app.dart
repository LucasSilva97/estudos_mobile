
import 'dart:io';

 /* print("Hello World"); //Exibe mensagem
  // stdin.readLineSync(); // Para receber mensagens no terminal (função semelhante ao input() do python)
  // Observação: praticamente toda função do projeto terá um bloco de parênteses.

  // Declarando uma variável
  // var entrada = "Uma mensagem";
  var entrada = stdin.readLineSync(); // Dessa forma a variável recebe um valor de entrada do usuário, igual ao input do python
  print(entrada);

// Anot importante: o Dart, para não ficar pesado, foi dividido em várias partes
// para manter suas várias funcionalidades, usando de bom desempenho

// Dart Core - possui as principais funções, como a main() e a print()
// dart:io - Usa comandos de IN-OUT (entrada e saída)

*/

// Reescrevendo o programa

void main() {
  
  print("Olá, me chamo Dart. Qual o seu nome?");
  var entrada = stdin.readLineSync();
  // Usando interpolação
  print("Muito prazer, $entrada. Vamos fazer vários programas juntos!");

}