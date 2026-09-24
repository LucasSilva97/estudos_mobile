import 'dart:async';
import 'dart:ffi';
/*
// ANOTAÇÕES
class Materia {
  String nome = '';           // Campo/Propriedade/Atributo
  int minutosEstudados = 0;   // Campo/Propriedade/Atributo

  void registrarEstudo(int minutos) { //método
    minutosEstudados = minutosEstudados + minutos;
  }

  void renomear(String nome) {
    this.nome = nome; // this.nome = o campo; nome = o parâmetro da função
    // o this vai ser necessário nesse caso, apenas pelo fato do parâmetro da função
    // ter o mesmo nome do atributo da classe matéria, caso contrário, seu uso é desnecessário.
  }
}

final dart = Materia();
final flutter = Materia();

void main(){

  dart.registrarEstudo(60);
  print(dart.minutosEstudados);

  print(flutter.minutosEstudados);
}*/

class Materia {
  // cada objeto materia tem a sua cópia destes três valores
  // os valores à direita do "=" são os valores iniciais (default): sem eles, um campo
  // não anulável ficaria sem valor e o programa nem compilaria.
  String nome = 'Sem nome';
  int minutosEstudados = 0;
  int metaSemanalEmMinutos = 60;

  // ---- CONSTRUTOR ----
  /**Ao contrário do que foi feito nas anotações, aqui o construtor foi feito à mão */
  
  Materia(String nome, int minutosEstudados, int metaSemanalEmMinutos) {
    this.nome = nome;
    this.minutosEstudados = minutosEstudados;
    this.metaSemanalEmMinutos = metaSemanalEmMinutos;
  }

  // ---- MÉTODOS ----

  /// Soma [minutos] ao total já estudado
  void registrarEstudo(int minutos) {
    if(minutos <= 0){
      print('"!" Ignorado: $minutos não é um valor válido');
      return;
    }
    minutosEstudados += minutos;
  }

  /// Quanto da meta semanal já foi cumprido, em porcentagem.
  double percentualDaMeta(){
    if (metaSemanalEmMinutos <= 0 ){
      return 0.0;
    }

    return minutosEstudados / metaSemanalEmMinutos * 100; 
  }

  /// Verdadeiro quando a meta da semana já foi atingida ou ultrapassada
  bool metaAtingida(){
    return minutosEstudados >= metaSemanalEmMinutos;
  }

  /// Quantos minutos ainda faltam. Nunca devolver número negativo
  int minutosRestantes(){
    final falta = metaSemanalEmMinutos - minutosEstudados;
    return falta > 0 ? falta : 0;
  }

  /// Uma linha de texto descrevendo o estado atual da matéria.
  String resumo(){
    final marca = metaAtingida() ? 'Ok' : 'Em andamento';
    final percentual = percentualDaMeta().toStringAsFixed(1);
    return '$marca $nome: $minutosEstudados/$metaSemanalEmMinutos min ($percentual %)';
  }
}

/**DESAFIO OPCIONAL */

class Semana {

  List <Materia> materias = <Materia>[];

  void adicionarMateria (Materia materia) {
    materias.add(materia);
  }
  
  int totalDeMinutos(){
    int total = 0;
    for (final m in materias){
      total += m.minutosEstudados;
    }
    return total;
  }

  Materia? materiaMaisEstudada(){
    if (materias.isEmpty) return null;

    // var maior = materias.first;

  /*  for(final m in materias){
      if(m.minutosEstudados > maior.minutosEstudados) {
          maior = m;
      }
    }*/
    return materias.reduce(
      (a, b) => a.minutosEstudados > b.minutosEstudados ? a: b
      );
  }


}



void main() {
  // Criando três OBJETOS (instâncias) a partir da mesma CLASSE.
  final dart = Materia('Dart', 0, 300);
  final flutter = Materia('Flutter', 0, 300);
  final logica = Materia('Lógica', 45, 120);

  // Uma lista de objetos é uma lista como qualquer outra
  final materias = <Materia>[dart, flutter, logica];

  // Cada chamada altera APENAS o objeto à esquerda do ponto.
  dart.registrarEstudo(90);
  dart.registrarEstudo(30);
  flutter.registrarEstudo(60);
  logica.registrarEstudo(-10); // Valor inválido: será recusado

  print('=== Minhas matérias ===');
  for (final materia in materias) {
    print(materia.resumo());
  }

  // Somando um campo de todos os objetos da Lista.
  var total = 0;
  for (final materia in materias){
    total += materia.minutosEstudados;
  }

  print('');
  print('Total estudado: $total minutos');
  print('Faltam para Dart: ${dart.minutosRestantes()} minutos');

  // Dois objetos com os MESMOS valores continuam sendo objetos DIFERENTES.
  print('');
  print('Total estudado: $total minutos');
  print('Faltam para Dart: ${dart.minutosRestantes()} minutos');

  // Dois objetos com  os MESMOS valores continuam sendo objetos DIFERENTES.
  final outraDart = Materia('Dart', 120, 300);
  print('');
  print('São o mesmo objeto na memória? ${identical(dart, outraDart)}');
  print('São iguais com == ? ${dart == outraDart}');
  print('Tipo em tempo de execução: ${dart.runtimeType}');

  /**DESAFIO OPCIONAL */

  print('');
  final progressoSemana = Semana();

  final sql = Materia('SQL', 70, 100);

  progressoSemana.adicionarMateria(sql);
  progressoSemana.adicionarMateria(logica);
  print(progressoSemana.totalDeMinutos());
  print(progressoSemana.materiaMaisEstudada()?.nome);

}

