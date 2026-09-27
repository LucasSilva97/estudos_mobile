import 'dart:io';

void main() {
   List<String> operacoes = <String>["deposito", "retirada", "transferencia", "pagamento"];


   void realizaOperacao(){
    print("Digite uma operação (deposito, retirada, transferencia, pagamento):");
    var operacao = stdin.readLineSync();
    var valorSeguro;

    if(!operacoes.contains(operacao)){
      print("Operação inválida. Tente novamente.");
      realizaOperacao();
    } else {
      print("Digite o valor da operação: ");
      var valor = stdin.readLineSync() ?? '0';
      valorSeguro = double.tryParse(valor) ?? 0;
    }

    print('Operação escolhida: $operacao, Valor: $valorSeguro');

   }

   realizaOperacao();
}