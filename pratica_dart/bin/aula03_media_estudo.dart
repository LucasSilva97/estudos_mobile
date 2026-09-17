// bin/aula03_media_estudo.dart
// Aula 3 — Algoritmos e decomposição.
//
// ALGORITMO (pseudocódigo):
// INÍCIO
//   RECEBER minutos de segunda a sexta e a meta diária
//   totalMinutos  <- soma dos cinco dias
//   mediaMinutos  <- totalMinutos / 5
//   totalHoras    <- totalMinutos / 60
//   metaSemanal   <- metaDiaria * 5
//   faltamMinutos <- metaSemanal - totalMinutos
//   percentual    <- (totalMinutos / metaSemanal) * 100
//   ESCREVER total, média, horas, meta, faltam e percentual
// FIM

void main(){

  //FLUXO EPS
  //ENTRADA
  const int metaDiaria = 150;

  const int minutosSeg = 120;
  const int minutosTer = 180;
  const int minutosQua = 90;
  const int minutosQui = 240;
  const int minutosSex = 60;

  const int diasUteis = 5;

  // PROCESSAMENTO
  final int totalMinutos = minutosSeg + minutosTer + minutosQua + minutosQui + minutosSex;
  final double mediaMinutos = totalMinutos / diasUteis;
  final double totalHoras = totalMinutos / 60;
  final int metaSemanal = metaDiaria * diasUteis;
  final int faltamMinutos = metaSemanal - totalMinutos;
  final double percentual = (totalMinutos / metaSemanal) * 100;

  //SAÍDA
  print('===== RELATÓRIO DA SEMANA =====');
  print('Segunda: $minutosSeg min');
  print('Terça:   $minutosTer min');
  print('Quarta:  $minutosQua min');
  print('Quinta:  $minutosQui min');
  print('Sexta:   $minutosSex min');
  print('-------------------------------');
  print('Total estudado : $totalMinutos min');
  print('Média por dia  : ${mediaMinutos.toStringAsFixed(1)} min');
  print('Em horas       : ${totalHoras.toStringAsFixed(1)} h');
  print('-------------------------------');
  print('Meta semanal   : $metaSemanal min');
  print('Faltam         : $faltamMinutos min');
  print('Cumprido       : ${percentual.toStringAsFixed(1)}%');
  print('===============================');


}

