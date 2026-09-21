void main(){
  const int minutosPorHora = 60;            // nunca muda, conhecido agora
  final DateTime inicio = DateTime.now();   // conhecido só ao rodar
  var totalMinutos = 0;                     // vai ser somado várias vezes


  for(final int sessao in <int>[45, 30, 60]){
    totalMinutos += sessao;
  }

  print('Total: $totalMinutos minutos');
  print('Horas completas: ${totalMinutos ~/ minutosPorHora}');
  print('Registrado em: ${inicio.year}');
}