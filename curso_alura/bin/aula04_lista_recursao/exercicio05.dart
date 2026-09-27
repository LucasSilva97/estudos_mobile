import 'dart:io';

void main(){
  List<String> listaPagamento = <String>["cartao", "boleto", "paypal", "pix"];

  void validaMetodoPagamento(){
    print("Escolha o método de pagamento: ");
    var metodoPagamento = stdin.readLineSync();

    if(!listaPagamento.contains(metodoPagamento)){
      print("Método inválido!");
      validaMetodoPagamento();
    } else {
      print("Método $metodoPagamento é válido!");
    }


  }

  validaMetodoPagamento();
}