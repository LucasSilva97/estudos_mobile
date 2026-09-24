import 'dart:io';

void main(){
  stdout.write('Seu nome: ');
  final nome = stdin.readLineSync();
  if (nome == null || nome.trim().isEmpty){
    stderr.writeln('Nome não informado.');
    exitCode = 2;
    return;
  }
  print('Olá, ${nome.trim()}');
}
