class Materia {
  final String nome;
  final int minutosEstudados;
  final int metaSemanalEmMinutos;

  // Construtor padrão com sugar syntax e parâmetros nomeados
  Materia(
    this.nome, {
    this.minutosEstudados = 0,
    this.metaSemanalEmMinutos = 60,
  }) : assert(nome.length >= 2, 'Precisa ter pelo menos 2 caracteres.'),
       assert(minutosEstudados >= 0, 'Minutagem não pode negativa.'),
       assert(metaSemanalEmMinutos > 0, 'A meta precisa ser maior que zero');

  /// Construtor sem corpo, reaproveita 100% a validação acima
  Materia.rapida(String nome) : this(nome, metaSemanalEmMinutos: 30);

  /// Construtor com INITIALIZER LIST própria
  Materia.doMapa(Map<String, Object?> mapa)
    : nome = (mapa['nome'] as String?) ?? 'Sem nome',
      minutosEstudados = (mapa['minutos'] as int?) ?? 0,
      metaSemanalEmMinutos = (mapa['meta'] as int?) ?? 60;

  /// Construtor FACTORY: processa a entrada antes de decidir o que devolver.
  /// Um construtor comum não poderia fazer o `split` nem lançar antes de concluir
  factory Materia.doCsv(String linha) {
    final partes = linha.split(';');
    if (partes.length != 3) {
      throw FormatException(
        'Esperava-se 3 campos separados por ";", recebido $linha',
      );
    }
    return Materia(
      partes[0].trim(),
      minutosEstudados: int.tryParse(partes[1].trim()) ?? 0,
      metaSemanalEmMinutos: int.tryParse(partes[2].trim()) ?? 60,
    );
  }

  String resumo() => '$nome: $minutosEstudados/$metaSemanalEmMinutos min';
}

class NivelDeDificuldade {
  final String rotulo;
  final int peso;

  const NivelDeDificuldade(this.rotulo, this.peso)
    : assert(peso >= 1 && peso <= 3, 'O peso vai de 1 a 3.');

  // Constantes reaproveitáveis: montadas em tempo de compilação.
  static const facil = NivelDeDificuldade('Fácil', 1);
  static const media = NivelDeDificuldade('Média', 1);
  static const dificil = NivelDeDificuldade('Difícil', 1);
}

class RegistroDeEstudo {
  // Usar o `_` defini o construtor como de uso interno, ou seja, somente nesse arquivo
  RegistroDeEstudo._interno();

  static final RegistroDeEstudo instancia = RegistroDeEstudo._interno();

  // O factory NÃO cria nada: devolve sempre a mesma instância
  factory RegistroDeEstudo() => instancia;

  final List<String> _eventos = <String>[];

  void registrar(String evento) => _eventos.add(evento);

  int total() => _eventos.length;

  String ultimo() => _eventos.isEmpty ? '(nenhum) ' : _eventos.last;
}

void main() {
  print('--- 1. Construtores ---');
  final dart = Materia(
    'Dart',
    minutosEstudados: 120,
    metaSemanalEmMinutos: 300,
  );
  final revisao = Materia.rapida('Revisão');
  final flutter = Materia.doMapa(<String, Object?>{
    'nome': 'Flutter',
    'minutos': 180,
    'meta': 600,
  });
  final logica = Materia.doCsv('Lógica; 45; 120');

  for (final materia in <Materia>[dart, revisao, flutter, logica]) {
    print(materia.resumo());
  }

  print('');
  print('--- 2. Construtor const e canonicalização ---');
  const copiaFacil = NivelDeDificuldade('Fácil', 1);
  final semConst = NivelDeDificuldade('Fácil', 1);
  print('const == const ? ${identical(copiaFacil, NivelDeDificuldade.facil)}');
  print('const == sem Const? ${identical(copiaFacil, semConst)}');

  print('');
  print('--- 3. Factory singleton ---');
  final registro1 = RegistroDeEstudo();
  final registro2 = RegistroDeEstudo();

  registro1.registrar('Iniciou sessão de Dart');
  registro2.registrar('Concluiu sessão de Dart');
  print('São o mesmo objeto? ${identical(registro1, registro2)}');
  print('Total de eventos:   ${registro1.total()}');
  print('Último evento:      ${registro2.ultimo()}');

  print('');
  print('--- 4. Validações ---');
  try {
    Materia.doCsv('linha bagunçada');
  } on FormatException catch (erro) {
    print('FormatException: ${erro.message}');
  }

  try {
    Materia('D');
  } on AssertionError catch (erro) {
    print('AssertionError: ${erro.message}');
  }
}
