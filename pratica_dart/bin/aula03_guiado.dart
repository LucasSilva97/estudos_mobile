// Escrevendo em código o teste de mesa abaixo:
/*
INÍCIO
  RECEBER horasTotais, horasFeitas, horasPorDia
  horasRestantes  <- horasTotais - horasFeitas
  diasRestantes   <- horasRestantes / horasPorDia
  percentual      <- (horasFeitas / horasTotais) * 100
  ESCREVER horasRestantes, diasRestantes, percentual
FIM
*/

// `horasTotais = 120`, `horasFeitas = 18`,
// `horasPorDia = 4


void main(){
  // ENTRADAS
  const int horasTotais = 120;
  const int horasFeitas = 18;
  const int horasPorDia = 4;

  // PROCESSAMENTO
  final int horasRestantes = horasTotais - horasFeitas;
  final double diasRestantes = horasRestantes / horasPorDia;
  final double percentual = (horasFeitas / horasTotais) * 100;

  //SAÍDA

  print('===============================');
  print('Resumo de Carga horária do curso');

  print('Faltam ${horasRestantes.toStringAsFixed(0)} horas para completar o curso.');
  print('Faltam, aproximadamente, ${diasRestantes.toStringAsFixed(0)} dias para completar o curso.');
  print('Percentual de conclusão do curso: ${percentual.toStringAsFixed(2)}%');
  print('===============================');
}