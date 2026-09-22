void main() {
  const int minutos = 75;

  final String nivel = switch (minutos) {
    0 => 'sem estudo',
    < 25 => 'muito curta',
    < 90 => 'média',
    _ => 'longa',
  };

  print('$minutos min -> $nivel');

  for (final int m in <int>[20, 60, 120]) {
    print('$m -> ${m >= 90 ? 'longa' : 'ok'}');
  }
}
