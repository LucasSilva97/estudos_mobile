
import 'dart:io';

void main() {
  print("Hello World"); //Exibe mensagem
  stdin.readLineSync(); // Para receber mensagens no terminal (função semelhante ao input() do python)
  // Observação: praticamente toda função do projeto terá um bloco de parênteses.

  // Declarando uma variável
  var entrada = "Uma mensagem";
  print(entrada);
}

// Anot importante: o Dart, para não ficar pesado, foi dividido em várias partes
// para manter suas várias funcionalidades, usando de bom desempenho

// Dart Core - possui as principais funções, como a main() e a print()
// dart:io - Usa comandos de IN-OUT (entrada e saída)


