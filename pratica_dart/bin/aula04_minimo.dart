void main(){
  const int metaDiaria = 240; // nunca muda
  int estudadoHoje = 0; // vai/pode mudar

  print('Meta: $metaDiaria min | Estudado: $estudadoHoje min');

  estudadoHoje = estudadoHoje + 90;
  print('Depois da 1ª sessão: $estudadoHoje min');

  estudadoHoje = estudadoHoje + 60;
  print('Depois da 2ª sessão: $estudadoHoje min');
}