void main() {
  const int estudado = 690;
  const int meta = 750;

  if(estudado >= meta) {
    print('Meta batida! Você excedeu em ${estudado - meta} min.');
  } else {
    print('Faltam ${meta - estudado} min para a meta.');
  }
}