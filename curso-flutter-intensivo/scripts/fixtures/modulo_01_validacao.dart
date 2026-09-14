import 'dart:io';

int calcularRestante(int meta, int estudado) {
  final diferenca = meta - estudado;
  if (diferenca < 0) return 0;
  return diferenca;
}

int contarBlocos(int minutos, int tamanho) {
  if (minutos <= 0 || tamanho <= 0) return 0;
  final inteiros = minutos ~/ tamanho;
  final sobra = minutos % tamanho;
  return sobra == 0 ? inteiros : inteiros + 1;
}

int lerMinutos(String texto) {
  final int? valor = int.tryParse(texto.trim());
  if (valor == null || valor <= 0) return 0;
  return valor;
}

int? converterPositivo(String texto) {
  final valor = int.tryParse(texto.trim());
  if (valor == null || valor <= 0) return null;
  return valor;
}

String formatarDuracao(int minutos) {
  if (minutos < 0) return 'Inválido';
  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  final doisDigitos = resto < 10 ? '0$resto' : '$resto';
  return '${horas}h ${doisDigitos}min';
}

Never falhar(String mensagem) {
  stderr.writeln(mensagem);
  exitCode = 1;
  throw StateError(mensagem);
}

void conferir(bool condicao, String mensagem) {
  if (!condicao) falhar(mensagem);
}

void main() {
  conferir(calcularRestante(120, 50) == 70, 'restante comum');
  conferir(calcularRestante(120, 150) == 0, 'restante superado');
  conferir(contarBlocos(70, 25) == 3, 'bloco parcial');
  conferir(contarBlocos(50, 25) == 2, 'bloco exato');
  conferir(contarBlocos(1, 0) == 0, 'tamanho inválido');

  conferir(lerMinutos('25') == 25, 'inteiro válido');
  conferir(lerMinutos(' abc ') == 0, 'texto inválido');
  conferir(lerMinutos('-1') == 0, 'negativo inválido');
  conferir(converterPositivo(' 40 ') == 40, 'conversão com espaços');
  conferir(converterPositivo('2.5') == null, 'decimal rejeitado');

  final esperados = <int, String>{
    -1: 'Inválido',
    0: '0h 00min',
    5: '0h 05min',
    59: '0h 59min',
    60: '1h 00min',
    65: '1h 05min',
    120: '2h 00min',
  };
  for (final entrada in esperados.entries) {
    conferir(
      formatarDuracao(entrada.key) == entrada.value,
      'formatação para ${entrada.key}',
    );
  }
  print('Módulo 01: ${10 + esperados.length} verificações aprovadas.');
}
