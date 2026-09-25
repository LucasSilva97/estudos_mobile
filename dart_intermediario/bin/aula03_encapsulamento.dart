class Materia {
  final String nome;
  final int minutosEstudados;
  final int metaSemanalEmMinutos;

  const Materia({
    required this.nome,
    this.minutosEstudados = 0,
    this.metaSemanalEmMinutos = 300,
  }) : assert(minutosEstudados >= 0, 'Minutos não podem ser negativos.'),
       assert(metaSemanalEmMinutos > 0, 'A meta precisa ser maior que zero.');

  double get percentualDaMeta => minutosEstudados / metaSemanalEmMinutos;
  bool get metaAtingida => minutosEstudados >= metaSemanalEmMinutos;
  
  int get minutosRestantes {
    final falta = metaSemanalEmMinutos - minutosEstudados;
    return falta > 0 ? falta : 0;
  }
  
  String get horasFormatadas {
    final horas = minutosEstudados ~/ 60;
    final minutos = minutosEstudados % 60;
    return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
  }
  
  Materia copyWith({
    String? nome,
    int? minutosEstudados,
    int? metaSemanalEmMinutos,
  }) {
    return Materia(
      nome: nome ?? this.nome,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaSemanalEmMinutos: metaSemanalEmMinutos ?? this.metaSemanalEmMinutos,
    );
  }
  
  Materia registrarEstudo(int minutos) {
    if(minutos <= 0){
      return this; // devolve o próprio objeto
    }
    return copyWith(minutosEstudados: minutosEstudados + minutos);
  }
  
}







