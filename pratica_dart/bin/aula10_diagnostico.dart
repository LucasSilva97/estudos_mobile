int lerMinutos(String texto) {
  final int? valor = int.tryParse(texto.trim());
  if (valor == null || valor <= 0) return 0;
  return valor;
}

void main(){
  final entradas = <String>['25', 'abc', '0', '-10', ' 40 '];
  for (final entrada in entradas) {
    final minutos = lerMinutos(entrada);
    if (minutos == 0) {
      print('Entrada invalida: "$entrada"');
    } else {
      print('Sessão aceita: $minutos min');
    }
  }
}
