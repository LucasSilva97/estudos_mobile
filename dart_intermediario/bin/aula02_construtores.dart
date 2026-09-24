class Materia {
  final String nome;
  final int minutosEstudados;

  Materia({required this.nome, this.minutosEstudados = 0});
  // Como nome não tem como ser definido um padrão, para usar como parâmetro nomeado
  // tem que declará-lo como item obrigatório, com o required, pois não pode ser anulável

  Materia.rapida({required this.nome, this.minutosEstudados = 0}); // construtores com nome

  /**Initializer list - é a parte entre os dois-pontos e o corpo */
  Materia.doMapa(Map<String, Object?> mapa)
    : nome = mapa['nome'] as String,
    minutosEstudados = 0;

}

void main(){
  final m = Materia(nome: 'Dart', minutosEstudados: 120);
  print('Matéria: ${m.nome} | Min estudados: ${m.minutosEstudados}');

  final mm = Materia.rapida(nome: 'Flutter', minutosEstudados: 150);
  print('Matéria: ${mm.nome} | Min estudados: ${mm.minutosEstudados}');
}
