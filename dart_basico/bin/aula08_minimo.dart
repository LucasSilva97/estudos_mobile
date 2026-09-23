void main() {
  const minutos = <int>[45, 0, 120, 30];

  final validos = minutos.where((m) => m > 0).toList();
  final total = validos.fold<int>(0, (acc, m) => acc + m);

  print('Sessões válidas: $validos');
  print('Total: $total min');
  print('Mais longa: ${validos.reduce((a, b) => a > b ? a : b)} min');
}