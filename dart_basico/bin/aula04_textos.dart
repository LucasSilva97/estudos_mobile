/// Converte texto em minutos inteiros, mesmo que tenha espaço nas extremidades do texto
int? lerMinutos(String entrada){
  final String limpo = entrada.trim();
  final int? valor = int.tryParse(limpo);
  if (valor == null || valor < 0){
    return null;
  }
  return valor;
}

/// Formata [minutos] como `2h15` ou `45min`.
String formatarDuracao(int minutos){
  final int horas = minutos ~/ 60;
  final int resto = minutos % 60;

  if (horas == 0) return '${resto}min';
  if (resto == 0) return '${horas}h';

  return '${horas}h${resto.toString().padLeft(2, '0')}';
}

void main(){
  print('=== 1. Tipos numéricos ===');
  const int inteiro = 135;
  const double decimal = 4.5;
  const num generico = 10;

  print('int    : $inteiro   (${inteiro.runtimeType})'); /// retorna valor e tipo da variável
  print('double : $decimal   (${decimal.runtimeType})');
  print('num    : $generico  (${generico.runtimeType})');
  print('7 / 2 = ${7 / 2}  |  7 ~/ 2 = ${7 ~/ 2}  |  7 % 2 = ${7 % 2}');
  print('0.1 + 0.2 = ${0.1 + 0.2}  |  == 0.3 ? ${0.1 + 0.2 == 0.3}');

  print('');
  print('=== 2. Formas de escrever texto ===');
  const String duplas = "com 'apóstrofo' dentro";
  const String triplas = '''
  Linha 1
  Linha 2''';
  const String cru = r'C:\Users\novo\dart_basico\bin';
  const String comEscape = 'Coluna1\tColuna2\nValor\$ e barra \\';
  print(duplas);
  print(triplas);
  print('raw string: $cru');
  print(comEscape);

  print('');
  print('=== 3. Interpolação ===');
  const String nome = 'Lucas';
  const int minutos = 135;
  print('Olá, $nome!');
  print('Estudou ${formatarDuracao(minutos)} hoje.');
  print('Nome em maiúsculas: ${nome.toUpperCase()}');
  print('Metade dos minutos: ${minutos / 2}');

  print('');
  print('=== 4. Métodos de String ===');
  const String bruto = '    Flutter Intensivo   ';
  print('original   : "$bruto"');
  print('trim       : "${bruto.trim()}"');
  print('tamanho    : "${bruto.trim().length}"');
  print('maiúsculo  : "${bruto.trim().toUpperCase()}"');
  print('minúsculo  : "${bruto.trim().toLowerCase()}"');
  print('idx de "I" : "${bruto.trim().indexOf('I')}"');
  print('subtexto   : "${bruto.trim().substring(0,7)}"');
  print('replaceAll : "${bruto.trim().replaceAll(' ', '-')}"');
  print('split      : "${bruto.trim().split(' ')}"');
  print('igualdade  :  ${'dart' == 'dart'}');


  print('');
  print('=== 5. StringBuffer ===');
  final StringBuffer buffer = StringBuffer();
  buffer.writeln('Plano da semana');
  for (final String materia in <String>['Dart', 'Flutter', 'Git']){
    buffer.writeln('  - $materia');
  }
  buffer.write('Fim.');
  print(buffer.toString());

  print('');
  print('=== 7. Texto para número (o ponto crítico) ===');
  const List<String> entradas = <String>['135', ' 90 ', 'abc', '', '-20', '4.5'];
  for (final String entrada in entradas) {
    final int? resultado = lerMinutos(entrada);
    if (resultado == null) {
      print('"$entrada" -> inválido');
    } else {
      print('"$entrada" -> $resultado min (${formatarDuracao(resultado)})');
    }
  }

  print('');
  print('=== 8. double e num');
  print('double.tryParse("4.5") : ${double.tryParse('4.5')}');
  print('double.tryParse("abc") : ${double.tryParse('abc')}');
  print('num.tryParse("10.5") : ${num.tryParse('10.5')}');
  print('int.parse("ff", 16) : ${int.parse('ff', radix: 16)}');

  print('');
  print('=== 9. parse derruba o programa inteiro ===');
  try {
    final int valor = int.parse('abc');
    print('nunca chega aqui: $valor');
  } on FormatException catch (erro) {
    print('FormatException capturada: ${erro.message}');
  }

  print('');
  print('=== 10. Runes e Unicode ===');
  const String texto = 'café';
  const String emoji = '😀';
  print('"$texto": length = ${texto.length}, runes = ${texto.runes.length}');
  print('"$emoji": length = ${emoji.length}, runes = ${emoji.runes.length}');
  print('código do emoji = ${emoji.runes.first}');
  print('remontado       = ${String.fromCharCode(emoji.runes.first)}');
  print('runes de "$texto" = ${texto.runes.toList()}');

  const String bandeira = '🇧🇷';
  print('${bandeira.length} / ${bandeira.runes.length}');
}