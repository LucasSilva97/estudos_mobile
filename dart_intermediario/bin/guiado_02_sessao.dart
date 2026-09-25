class SessaoDeEstudo {
  final String materia;
  final int minutos;
  final bool concluida;
  
  const SessaoDeEstudo({
    required this.materia,
    required this.minutos,
    this.concluida = false,
  })   : assert(minutos > 0, 'Uma sessão precisa de pelo menos 1 minuto.'),
         assert(minutos <= 480, 'Sessão acima de 8 horas é erro de digitação.');
  
  const SessaoDeEstudo.pomodoro(String materia)
    : this(materia: materia, minutos: 25);
  
  SessaoDeEstudo.deSegundos(this.materia, int segundos)
    : minutos = segundos ~/ 60 < 1 ? 1 : segundos ~/ 60,
    concluida = true;
  
  factory SessaoDeEstudo.doTexto(String texto) {
    final partes = texto.split(':');
    if (partes.length != 2) {
      throw FormatException('Use o formato materia:minutos, recebi "$texto"');
    }
    final minutos = int.tryParse(partes[1].trim());
    if (minutos == null) {
      throw FormatException('"${partes[1]}" não é um número de minutos.');
    }
    return SessaoDeEstudo(materia: partes[0].trim(), minutos: minutos);
  }
  
  String resumo() => '$materia - $minutos min${concluida ? '✅': ''}';
}

void main(){
  final sessoes = <SessaoDeEstudo>[
    const SessaoDeEstudo(materia: 'Dart', minutos: 90),
    const SessaoDeEstudo.pomodoro('Flutter'),
    SessaoDeEstudo.deSegundos('Lógica', 2700),
    SessaoDeEstudo.doTexto('Git: 20'),
  ];
  
  for(final sessao in  sessoes) {
    print(sessao.resumo());
  }
}


