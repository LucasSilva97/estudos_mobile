// bin/aula04_variaveis.dart
// Aula 4 — Variáveis e constantes.
// Simula um dia de estudo: o que é fixo fica em const/final,
// o que evolui fica em variável.

void main() {
  // ---------- CONSTANTES (const): conhecidas antes de rodar ----------
  const String nomeDoAluno = 'Estudante Foco';
  const String nomeDoCurso = 'Curso Flutter Intensivo';
  const int metaDiariaMinutos = 240;
  const int duracaoSessaoMinutos = 45;
  const int duracaoPausaMinutos = 15;

  // ---------- FINAL: valor definido uma vez, durante a execução ----------
  // DateTime é o tipo do Dart para um instante no tempo.
  // DateTime.now() devolve o momento exato em que a linha executa,
  // por isso NÃO pode ser const: ninguém sabe isso antes de rodar.
  final DateTime inicioDoDia = DateTime.now();
  final int anoAtual = inicioDoDia.year;

  // ---------- VARIÁVEIS: mudam ao longo do programa ----------
  int minutosEstudados = 0;
  int sessoesConcluidas = 0;
  int minutosEmPausa = 0;

  print('=== $nomeDoCurso ===');
  print('Aluno: $nomeDoAluno');
  print('Ano: $anoAtual');
  print('Meta de hoje: $metaDiariaMinutos min');
  print('Sessão padrão: $duracaoSessaoMinutos min | Pausa: $duracaoPausaMinutos min');
  print('');

  // ----- Sessão 1 -----
  minutosEstudados = minutosEstudados + duracaoSessaoMinutos;
  sessoesConcluidas = sessoesConcluidas + 1;
  minutosEmPausa = minutosEmPausa + duracaoPausaMinutos;
  print('Sessão $sessoesConcluidas concluída -> estudado: $minutosEstudados min');

  // ----- Sessão 2 -----
  minutosEstudados = minutosEstudados + duracaoSessaoMinutos;
  sessoesConcluidas = sessoesConcluidas + 1;
  minutosEmPausa = minutosEmPausa + duracaoPausaMinutos;
  print('Sessão $sessoesConcluidas concluída -> estudado: $minutosEstudados min');

  // ----- Sessão 3 (mais longa que o padrão) -----
  const int sessaoLongaMinutos = 90;
  minutosEstudados = minutosEstudados + sessaoLongaMinutos;
  sessoesConcluidas = sessoesConcluidas + 1;
  print('Sessão $sessoesConcluidas concluída -> estudado: $minutosEstudados min');

  print('');

  // ---------- FECHAMENTO: valores derivados ----------
  final int faltaParaMeta = metaDiariaMinutos - minutosEstudados;
  final double percentualDaMeta = (minutosEstudados / metaDiariaMinutos) * 100;
  final int tempoTotalNaMesa = minutosEstudados + minutosEmPausa;

  print('=== FECHAMENTO DO DIA ===');
  print('Sessões concluídas : $sessoesConcluidas');
  print('Minutos estudados  : $minutosEstudados');
  print('Minutos em pausa   : $minutosEmPausa');
  print('Tempo na mesa      : $tempoTotalNaMesa min');
  print('Falta para a meta  : $faltaParaMeta min');
  print('Percentual da meta : ${percentualDaMeta.toStringAsFixed(1)}%');

  // ---------- O QUE NÃO COMPILA (deixe comentado e leia) ----------
  // metaDiariaMinutos = 300;
  //   -> erro: não é possível atribuir a uma constante.
  // inicioDoDia = DateTime.now();
  //   -> erro: 'final' só aceita uma atribuição.
  // const DateTime agora = DateTime.now();
  //   -> erro: 'const' exige valor conhecido em tempo de compilação.
}