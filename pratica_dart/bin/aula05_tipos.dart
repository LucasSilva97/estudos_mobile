// bin/aula05_tipos.dart
// Aula 5 — Tipos de dados: declaração, inspeção e conversão.

void main() {
  // ---------- 1) OS CINCO TIPOS DO DIA A DIA ----------
  const int minutosEstudados = 240;
  const double notaMedia = 8.75;
  const num pontuacao = 95;
  const String materia = 'Dart';
  const bool concluido = true;

  print('=== 1) TIPOS BÁSICOS ===');
  print('minutosEstudados = $minutosEstudados   tipo: ${minutosEstudados.runtimeType}');
  print('notaMedia        = $notaMedia   tipo: ${notaMedia.runtimeType}');
  print('pontuacao        = $pontuacao   tipo: ${pontuacao.runtimeType}');
  print('materia          = $materia   tipo: ${materia.runtimeType}');
  print('concluido        = $concluido   tipo: ${concluido.runtimeType}');
  print('');

  // ---------- 2) NÚMERO -> TEXTO ----------
  print('=== 2) NÚMERO PARA TEXTO ===');
  final String minutosComoTexto = minutosEstudados.toString();
  final String notaDuasCasas = notaMedia.toStringAsFixed(2);
  final String notaSemCasas = notaMedia.toStringAsFixed(0);

  print('toString()          -> "$minutosComoTexto" (${minutosComoTexto.runtimeType})');
  print('toStringAsFixed(2)  -> "$notaDuasCasas"');
  print('toStringAsFixed(0)  -> "$notaSemCasas"  (arredondou)');
  print('');

  // ---------- 3) TEXTO -> NÚMERO (parsing) ----------
  print('=== 3) TEXTO PARA NÚMERO ===');
  const String entradaValida = '180';
  const String entradaInvalida = 'cento e oitenta';

  final int comParse = int.parse(entradaValida);
  // O "?" diz: esta variável pode conter um int OU null.
  final int? tentativaValida = int.tryParse(entradaValida);
  final int? tentativaInvalida = int.tryParse(entradaInvalida);
  final double horasDecimais = double.parse('2.5');

  print('int.parse("180")                -> $comParse');
  print('int.tryParse("180")             -> $tentativaValida');
  print('int.tryParse("cento e oitenta") -> $tentativaInvalida');
  print('double.parse("2.5")             -> $horasDecimais');
  print('');

  // ---------- 4) int <-> double ----------
  print('=== 4) CONVERSÕES NUMÉRICAS ===');
  final double minutosComoDouble = minutosEstudados.toDouble();
  final int notaTruncada = notaMedia.toInt();
  final int notaArredondada = notaMedia.round();
  final int notaParaBaixo = notaMedia.floor();
  final int notaParaCima = notaMedia.ceil();

  print('240.toDouble()  -> $minutosComoDouble');
  print('8.75.toInt()    -> $notaTruncada   (corta a parte decimal)');
  print('8.75.round()    -> $notaArredondada   (mais próximo)');
  print('8.75.floor()    -> $notaParaBaixo   (para baixo)');
  print('8.75.ceil()     -> $notaParaCima   (para cima)');
  print('');

  // ---------- 5) TESTANDO O TIPO COM is ----------
  print('=== 5) VERIFICAÇÃO DE TIPO ===');
  print('minutosEstudados is int    -> ${minutosEstudados is int}');
  print('minutosEstudados is double -> ${minutosEstudados is double}');
  print('materia is String          -> ${materia is String}');
  print('');

  // ---------- 6) O PONTO FLUTUANTE NÃO É EXATO ----------
  print('=== 6) CUIDADO COM double ===');
  print('0.1 + 0.2 = ${0.1 + 0.2}');
  print('Por isso: minutos e centavos ficam em int.');
}