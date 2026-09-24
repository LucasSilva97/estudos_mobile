# Aula 10 — Entrada e saída no terminal

> **Módulo:** 02 — Dart básico · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Ler texto com `stdin.readLineSync` e entender seu retorno anulável.
- Validar entrada sem `!` e repetir a pergunta quando necessário.
- Escrever em saída normal e saída de erro e definir código de saída.
- Montar uma calculadora de tempo de estudo completa.

## ✅ Pré-requisitos

[Sets e Maps](09-sets-e-maps.md), null safety, controle de fluxo e funções.
Esta aula usa `dart:io`, disponível em programas de terminal e em aplicativos nativos; não na web.

## 📖 Conceito

`stdin`, `stdout` e `stderr` são fluxos padrão de entrada, saída normal e erros. A leitura
`stdin.readLineSync()` devolve `String?`: pode haver uma linha ou o fluxo pode terminar (`null`),
por exemplo com Ctrl+Z seguido de Enter no Windows ou Ctrl+D no macOS/Linux.

`stdout.write` não acrescenta quebra de linha; é útil para deixar o cursor após a pergunta.
`print` acrescenta a quebra. Mensagens de uso inválido podem ir para `stderr`, enquanto o
resultado vai para `stdout`. `exitCode` comunica sucesso (`0`) ou falha (valor diferente de zero)
ao terminal sem encerrar imediatamente. A biblioteca está documentada em
[dart:io](https://dart.dev/libraries/dart-io).

Uma função de leitura deve separar três casos: fim da entrada, texto inválido e valor válido.
Neste curso, `null` encerra a coleta com uma mensagem; texto inválido permite tentar novamente.

## 💡 Analogia

Uma recepção pergunta, escuta e confere o formulário. Se a pessoa escreveu algo inválido, explica
e pergunta de novo. Se a conversa terminou, não inventa uma resposta em seu lugar.

## 🧪 Exemplo mínimo

```dart
import 'dart:io';

void main() {
  stdout.write('Seu nome: ');
  final nome = stdin.readLineSync();
  if (nome == null || nome.trim().isEmpty) {
    stderr.writeln('Nome não informado.');
    exitCode = 2;
    return;
  }
  print('Olá, ${nome.trim()}!');
}
```

## 📱 Aplicando no Flutter

Flutter não lê formulários com `stdin`; usa campos e controllers. A regra continua igual:
receber texto, normalizar, validar, converter e só então atualizar o estado. Mantenha a função
de validação independente da interface para reutilizá-la em testes.

## 💻 Código completo

Crie `bin/calculadora_estudo.dart`:

```dart
import 'dart:io';

String? lerTextoObrigatorio(String pergunta) {
  while (true) {
    stdout.write(pergunta);
    final linha = stdin.readLineSync();
    if (linha == null) return null;
    final texto = linha.trim();
    if (texto.isNotEmpty) return texto;
    stderr.writeln('Digite um texto não vazio.');
  }
}

int? lerInteiroPositivo(String pergunta) {
  while (true) {
    stdout.write(pergunta);
    final linha = stdin.readLineSync();
    if (linha == null) return null;
    final valor = int.tryParse(linha.trim());
    if (valor != null && valor > 0) return valor;
    stderr.writeln('Digite um número inteiro maior que zero.');
  }
}

void main() {
  final materia = lerTextoObrigatorio('Matéria: ');
  if (materia == null) {
    stderr.writeln('Entrada encerrada antes da matéria.');
    exitCode = 2;
    return;
  }

  final meta = lerInteiroPositivo('Meta semanal em minutos: ');
  if (meta == null) {
    stderr.writeln('Entrada encerrada antes da meta.');
    exitCode = 2;
    return;
  }

  final sessoes = <int>[];
  while (true) {
    stdout.write('Minutos da sessão (vazio para concluir): ');
    final linha = stdin.readLineSync();
    if (linha == null || linha.trim().isEmpty) break;
    final minutos = int.tryParse(linha.trim());
    if (minutos == null || minutos <= 0) {
      stderr.writeln('Sessão ignorada: use um inteiro maior que zero.');
      continue;
    }
    sessoes.add(minutos);
  }

  final total = sessoes.fold<int>(0, (soma, valor) => soma + valor);
  final falta = meta - total;
  print('');
  print('=== Relatório ===');
  print('Matéria: $materia');
  print('Sessões válidas: ${sessoes.length}');
  print('Total: $total min');
  if (falta > 0) {
    print('Faltam $falta min para a meta.');
  } else {
    print('Meta atingida!');
  }
}
```

Execute `dart run bin/calculadora_estudo.dart`. Digite, em linhas separadas: `Dart`, `120`,
`25`, `abc`, `40`, `55` e uma linha vazia. O aviso de `abc` pode aparecer em ordem visual
diferente se o terminal intercalar stdout e stderr. O relatório deve informar 3 sessões,
total 120 e meta atingida.

## 🔍 Explicando o código

As duas funções de pergunta repetem enquanto há uma linha inválida e devolvem `null` quando o
fluxo termina. Depois do teste de `null`, a promoção de tipo permite usar matéria e meta com
segurança. A linha vazia tem significado somente na coleta de sessões: concluir a entrada.

`tryParse` evita que texto inválido encerre o processo. A lista guarda apenas valores aceitos.
`fold` começa em zero e funciona quando nenhuma sessão foi fornecida. `falta > 0` impede exibir
um número negativo quando o total supera a meta.

## 🤖🍎 Android × iOS

O programa roda em terminais de Windows, macOS e Linux. O atalho de fim de entrada varia.
Em um app Flutter Android/iOS, use `TextFormField`; não use stdin. `dart:io` também impede que
esse arquivo seja compilado para web, uma diferença de plataforma que deve permanecer explícita.

## ⚠️ Erros comuns

- Usar `stdin.readLineSync()!`: fim da entrada torna o valor nulo.
- Usar `int.parse` em texto do usuário sem tratar `FormatException`.
- Criar recursão para perguntar novamente; um laço é mais simples e não acumula chamadas.
- Usar `exit(2)` no meio de lógica reutilizável; `exitCode` e `return` permitem terminar de modo claro.
- Testar `linha.isEmpty` antes de conferir se `linha` é nula.
- Misturar regra de validação, cálculo e mensagens até ficar impossível testar partes isoladas.

## 🛠️ Exercício guiado

1. Execute o caso completo descrito acima.
2. Informe meta `zero`, `-1`, `2.5` e depois `60`; os três primeiros devem ser rejeitados.
3. Conclua sem sessões: total 0 e falta igual à meta.
4. Supere a meta: a mensagem não deve conter falta negativa.
5. Redirecione entrada de um arquivo no terminal e confira que cada linha é consumida na ordem.
6. Rode `dart format .` e `dart analyze`.

## 📝 Exercícios independentes

Conclua a [lista do módulo 02](../../exercicios/02-dart-basico.md), incluindo o exercício que
testa a calculadora por entradas e saídas conhecidas.

## 🏆 Desafio opcional

Acrescente comandos `listar` e `remover <número>` durante a coleta, sem quebrar a aceitação de
durações. Escreva antes uma tabela de entradas válidas, inválidas e seus efeitos.

## 📌 Resumo

Entrada externa é anulável e potencialmente inválida. Normalize, valide e converta antes de
usar. stdout leva resultados; stderr leva diagnósticos; o código de saída comunica o resultado
ao processo chamador.

## ☑️ Checklist de domínio

- [X] Leio uma linha sem usar `!`.
- [X] Repito a pergunta para texto inválido e encerro em fim de entrada.
- [X] Diferencio linha vazia de `null`.
- [X] Uso stderr e um código diferente de zero para falha.
- [X] Testo nenhuma sessão, sessão inválida, meta exata e meta superada.

## 📚 Referências oficiais

- [Dart — dart:io](https://dart.dev/libraries/dart-io)
- [stdin](https://api.dart.dev/dart-io/stdin.html)
- [stdout](https://api.dart.dev/dart-io/stdout.html)
- [exitCode](https://api.dart.dev/dart-io/exitCode.html)

| Anterior                        | Módulo            | Próxima etapa                                   |
| ------------------------------- | ------------------ | ------------------------------------------------ |
| [Sets e Maps](09-sets-e-maps.md) | [README](README.md) | [Exercícios](../../exercicios/02-dart-basico.md) |
