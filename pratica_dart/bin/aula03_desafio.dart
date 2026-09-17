// DESAFIO

/*
Escreva o algoritmo e o programa de um **conversor de tempo de
estudo** que, a partir de um total em minutos, mostre:

1. quantas horas inteiras e quantos minutos sobram (ex.: `690 min = 11 h e 30 min`);
2. quantas sessões de 25 minutos cabem nesse total;
3. quantos minutos sobram fora das sessões de 25 minutos.

Regras:

- Escreva o pseudocódigo em comentários **antes** do código.
- Faça o teste de mesa em papel para `690` e para `100`.
- Você ainda não viu os operadores `~/` (divisão inteira) e `%` (resto). Resolva **por enquanto**
  com as constantes que quiser e comentários explicando o raciocínio; depois da
  [Aula 6](06-operadores.md), volte e reescreva o programa usando `~/` e `%`. Compare as duas
  versões: essa comparação é o desafio de verdade.
*/

// INÍCIO
// RECEBER VALORES
// totalMinutosEstudado = 690, tempoPomodoro = 25
//PROCESSAMENTO
//totalHoras <- totalMinutosEstudado ~/ 60
//sobramMinutos <- totalMinutosEstudado % 60
//qtdeSecoesPomodoro <- totalMinutosEstudado / tempoPomodoro
//minutosExcedemSecao <- totalMinutosEstudado % tempoPomodoro
// ESCREVA
// Total em Horas/Minutos: 11h e 30 min
// Quantidade de seções pomodoro: 28
// Minutos que excedem as seções: minutosExcedemSecao

void main(){
  const int totalMinutosEstudado = 690;
  const int tempoPomodoro = 25;

  final int totalEmHoras = totalMinutosEstudado ~/ 60;
  final int sobramMinutos = totalMinutosEstudado % 60;
  final double qtdeSecoesPomodoro = totalMinutosEstudado / tempoPomodoro;
  final int minutosExcedemSecao =  totalMinutosEstudado % tempoPomodoro;

  print('Tempo estudado: $totalEmHoras h e $sobramMinutos min');
  print('Quantidade de seções: ${qtdeSecoesPomodoro.toStringAsFixed(0)}');
  print('Minutos que excedem as seções: $minutosExcedemSecao');
}
