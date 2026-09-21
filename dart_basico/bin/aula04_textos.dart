int? lerMinutos(String entrada){
  final String limpo = entrada.trim();
  final int? valor = int.tryParse(limpo);
  if (valor == null || valor < 0){
    return null;
  }
  return valor;
}

/// Formata [minutos] como `2h15` ou `45min`.