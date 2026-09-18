void main(){
  // -------------- Dados da semana --------------
  const int minutosEstudados = 690;
  const int metaSemanal =750;
  const String diaDaSemana = 'qua';
  const bool fezExercicios = true;
  const bool fezRevisao = false;

  print('=== 1) IF / ELSE ===');
  if(minutosEstudados >= metaSemanal){
    print('Meta batida! Excedeu em ${minutosEstudados -metaSemanal} min.');
  }else {
    print('Faltam ${metaSemanal -minutosEstudados} min para a meta');
  }

  print('');
  print('=== 2) CADEIA ELSE IF ===');
  final double percentual = (minutosEstudados / metaSemanal) * 100;
  String classificacao;

  if(percentual >= 100){
    classificacao = 'Excelente';
  }else if (percentual >= 80){
    classificacao = 'Bom';
  }else if (percentual >= 50){
    classificacao = 'Regular';
  }else {
    classificacao = 'Precisa melhorar';
  }

  print('Percentual: ${percentual.toStringAsFixed(1)}%');
  print('Classificação: $classificacao');

  print('');
  print('=== 3) TERNÁRIO ===');
  final bool bateuMeta = minutosEstudados >= metaSemanal;
  final String status = bateuMeta ? 'concluída' : 'em andamento';
  final String rotulo = bateuMeta ? 'Excedeu em' : 'Faltam';

  final int diferenca = 
    bateuMeta ? minutosEstudados - metaSemanal : metaSemanal - minutosEstudados;
  print('Semana $status.');
  print('$rotulo $diferenca min.');

  print('');
  print('=== 4) SWITCH ===');
  int metaDoDia;
  switch(diaDaSemana) {
    case 'seg':
    case 'ter':
    case 'qua':
    case 'qui':
    case 'sex':
      metaDoDia = 240;
      break;
    case 'sab':
      metaDoDia = 120;
      break;
    case 'dom':
      metaDoDia = 0;
      break;
    default:
      metaDoDia = -1;
  }

  if(metaDoDia < 0){
    print('Dia "$diaDaSemana" não reconhecido.');
  } else if (metaDoDia == 0){
    print('Hoje ($diaDaSemana) é dia de descanso.');
  } else {
    print('Meta de hoje ($diaDaSemana): $metaDoDia min.');
  }

  print('');
  print('=== 5) CONDIÇÕES COMBINADAS ===');
  if(bateuMeta && fezExercicios && fezRevisao) {
    print('Semana perfeita: meta, exercícios e revisão.');
  } else if(fezExercicios && fezRevisao) {
    print('Praticou bem, mas faltou tempo de estudo.');
  } else if(fezExercicios || fezRevisao) {
    print('Você praticou em parte. Falta fechar o ciclo.');
  } else {
    print('Semana só de leitura: pratique mais.');
  }

  // Proteção com curto-circuito: o segundo teste só roda se o primeiro passar
  final int? minutosDeOntem = int.tryParse('abc');
  if (minutosDeOntem != null && minutosDeOntem > 0) {
    print('Ontem: $minutosDeOntem min.');
  } else {
    print('Não há registro válido de ontem.');
  }

}