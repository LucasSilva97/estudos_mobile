class Meta {
  final String titulo;
  final int minutosPorSemana;

  // Construtor padrão com this.x + valor padrão + assert.
  const Meta(this.titulo, {this.minutosPorSemana = 300})
    : assert(minutosPorSemana > 0, 'A meta precisa ser maior que zero.');

  // Construtor nomeado que REDIRECIONA para o padrão.
  const Meta.leve(String titulo) : this(titulo, minutosPorSemana: 60);
}


/** Mais uma Classe */
class Funcionario {
  String nome;
  int idade;
  String funcao;
  String? hobby;

  // Forma tradicional do construtor
  /*Funcionario(String nome, int idade, String funcao, String hobby) {
    this.nome = nome;
    this.idade = idade;
    this.funcao = funcao;
    this.hobby= hobby;
  }*/

  // Declarando um construtor usando Syntax Sugar
  Funcionario(this.nome, this.idade, this.funcao, {this.hobby});
}


void main() {
  const padrao = Meta('Estudar Dart');
  const leve = Meta.leve('Revisar anotações');

  print('${padrao.titulo}: ${padrao.minutosPorSemana} min/semana');
  print('${leve.titulo}: ${leve.minutosPorSemana} min/semana');

  print('Canonicalizado? ${identical(padrao, const Meta('Estudar Dart'))}');

  Funcionario funcionario = Funcionario('Pam', 26, "recp", hobby: "art");
  Funcionario funcionario2 = Funcionario('PamB', 26, "recp");



}
