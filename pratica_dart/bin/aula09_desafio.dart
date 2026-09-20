String formatarDuracao(int minutos) {

  if(minutos <= 0){
    minutos = 0;
    return '0h 00min';
  } 

  final int horas = minutos ~/ 60;
  final int min = minutos % 60;

  final String horaFormatada = '${horas}h';
  final String minFormatado = 
    min < 10 ? '0${min}min' : '${min}min';

  return '$horaFormatada $minFormatado';
}

void main(){
  print(formatarDuracao(135));
}