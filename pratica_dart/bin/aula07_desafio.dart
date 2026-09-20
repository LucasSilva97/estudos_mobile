void main () {
  const String? diaDaSemana = 'seg';
  const int minutosEstudados = 190;
  const bool dormiuBem = false;

  final int metaDiaria;

  switch(diaDaSemana){
    case 'seg':
    case 'ter':
    case 'qua':
    case 'qui':
    case 'sex':
      metaDiaria = 240;
      break;
    case 'sab':
      metaDiaria = 120;
      break;
    case 'dom':
      metaDiaria = 0;
      break;
    default:
      metaDiaria = -1;
  }

  final double percProgressoDia = (minutosEstudados / metaDiaria) * 100;
  final String progressoDia;
  
  if (percProgressoDia == 0){
    progressoDia = '0%';
  } else if (percProgressoDia < 51) {
    progressoDia = 'até 50%';
  } else if (percProgressoDia < 100) {
    progressoDia = 'até 99%';
  } else {
    progressoDia = '100% ou mais';
  }

  final int difMinutos = metaDiaria - minutosEstudados;
  final String mensagemProgressoMinutos = 
      metaDiaria >= minutosEstudados ? 'Faltam $difMinutos min' : 'Excedeu em $difMinutos min';

  final String recomendacao;

  if (!dormiuBem && minutosEstudados > 180) {
    recomendacao = 'pare por hoje';
  } else if (percProgressoDia < 100){
    recomendacao = 'dá para mais uma sessão';
  } else {
    recomendacao = 'Está indo muito bem. Continue mais uma sessão ou considere parar por hoje.';
  }

  //MENSAGENS
  print('=== Resumo do dia ===');
  print('Dia da semana: $diaDaSemana');
  print('Dormiu bem? $dormiuBem');
  print('Minutos estudados: $minutosEstudados // Meta diária: $metaDiaria');
  print('--- Métricas ---');
  print('Classificação: $progressoDia - %Progresso: ${percProgressoDia.toStringAsFixed(2)}%');
  print('');
  print('--- Recomendação ----');
  print('Mensagem: $recomendacao');
  print('=====================');


}