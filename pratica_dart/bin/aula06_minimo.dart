void main (){
  const int totalMinutos = 690;

  final int horas = totalMinutos ~/ 60;
  final int minutos = totalMinutos % 60;

  print('$totalMinutos minutos = $horas h e $minutos min');

   int? cache;
  cache ??= 120;
  print(cache);
  final int? lidoInvalido = int.tryParse('abc');
  final int? lidoValido = int.tryParse('4');

  print(lidoInvalido);
  final int minutosSeguros = lidoInvalido ?? 0;
  print(minutosSeguros);

  print(lidoInvalido?.isEven);
  print(lidoValido?.isEven);
  print(lidoInvalido?.isEven ?? false);
}