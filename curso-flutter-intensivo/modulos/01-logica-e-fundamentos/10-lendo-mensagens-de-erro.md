# Aula 10 — Lendo mensagens de erro

> **Tempo:** 40 min · **Módulo:** 01 — Lógica e fundamentos

## 🎯 Objetivos de aprendizagem

- Distinguir erro de compilação, execução e lógica.
- Localizar arquivo, linha e operação que falhou.
- Reproduzir um defeito com a menor entrada que o demonstra.

## ✅ Pré-requisitos

[Funções](09-funcoes.md), operações aritméticas e execução de arquivos Dart.

## 📖 Conceito

Um erro de **compilação** impede executar: o programa não respeita a linguagem ou os tipos.
Um erro de **execução** ocorre depois que o programa começa, ao tentar uma operação inválida.
Um erro de **lógica** produz um resultado inadequado mesmo sem mensagem do sistema.

Uma stack trace é a sequência de chamadas que levou à falha. Procure a primeira linha que
aponta para **seu arquivo**, abra essa posição e identifique quais dados chegaram à operação.
O texto e a numeração podem variar entre versões; o importante é reconhecer tipo, arquivo e
contexto. Você aprofundará captura e propagação em [Exceptions](../04-dart-avancado/01-exceptions.md).

## 💡 Analogia

Um endereço errado impede o entregador de encontrar a casa; uma porta trancada impede a
entrega já no local; entregar o produto errado pode concluir o trajeto sem resolver o pedido.
Os três exigem diagnósticos diferentes, assim como os erros de um programa.

## 🧪 Exemplo mínimo

```dart
void main() {
  final minutos = int.parse('abc');
  print(minutos);
}
```

Esse exemplo **compila, mas falha intencionalmente**. Salve em `bin/erro_proposital.dart` e execute.
Procure `FormatException` e a linha que contém `int.parse`. Não memorize o número da linha.
`int.parse` converte texto válido; `int.tryParse` devolve `null` quando não consegue converter,
como documenta a [API de int](https://api.dart.dev/dart-core/int/tryParse.html).

## 📱 Aplicando no Flutter

Se um formulário aceita texto, a conversão precisa tratar entrada inválida antes de salvar.
Uma tela vermelha durante desenvolvimento ajuda a encontrar o defeito; no app entregue, o
usuário deve receber uma orientação útil, como `Digite minutos inteiros maiores que zero`.

## 💻 Código completo

Crie `bin/diagnostico.dart`. `int?` significa que o resultado pode ser inteiro ou `null`
(ausência de valor); isso será detalhado em null safety no módulo 02.

```dart
int lerMinutos(String texto) {
  final int? valor = int.tryParse(texto.trim());
  if (valor == null || valor <= 0) return 0;
  return valor;
}

void main() {
  final entradas = <String>['25', ' abc ', '0', '-10', ' 40 '];
  for (final entrada in entradas) {
    final minutos = lerMinutos(entrada);
    if (minutos == 0) {
      print('Entrada invalida: "$entrada"');
    } else {
      print('Sessao aceita: $minutos min');
    }
  }
}
```

Execute `dart run bin/diagnostico.dart`. Saída:

```text
Sessao aceita: 25 min
Entrada invalida: " abc "
Entrada invalida: "0"
Entrada invalida: "-10"
Sessao aceita: 40 min
```

## 🔍 Explicando o código

`trim` retira espaços das pontas; não transforma letras em números. `tryParse` permite
reconhecer essa falha. O operador `||` avalia a segunda parte apenas se a primeira for falsa;
portanto, a comparação com zero acontece quando existe um número. O retorno 0 é uma convenção
local para representar entrada rejeitada, possível porque zero não é sessão válida aqui.

## ⚠️ Erros comuns

| Situação | Diagnóstico |
|---|---|
| `Undefined name` | Confira digitação e escopo; o nome pode existir só dentro de outra função |
| `Expected ';'` | Confira também a linha anterior à posição indicada |
| `FormatException` | Registre a entrada fictícia que chegou ao conversor |
| Total errado sem exceção | Faça teste de mesa e compare cada parcela |
| Muitas mensagens após uma edição | Corrija a primeira causa e analise novamente |

Não cole tokens ou dados pessoais em logs ao reproduzir problemas.

## 🛠️ Exercício guiado

1. Execute a falha proposital e localize o arquivo no rastreamento de chamadas.
2. Execute a solução completa e confira as cinco linhas.
3. Acrescente `2.5`: deve ser rejeitado, pois a regra aceita minutos inteiros.
4. Troque temporariamente `valor <= 0` por `valor < 0`; observe zero cair no retorno 0, mas
   perceba que o contrato interno agora aceita zero na validação. Restaure e mantenha a regra explícita.
5. Rode `dart analyze bin/diagnostico.dart`; anote separadamente problemas do código e do ambiente.

## 📝 Exercícios independentes

Resolva os defeitos plantados na [lista do módulo](../../exercicios/01-logica-e-fundamentos.md).
Para cada um, entregue: entrada mínima, esperado, observado, causa e correção.

## 🏆 Desafio opcional

Crie um programa que calcula a média de duas sessões, plante um erro de precedência e escreva
um caso que o revele. Depois acrescente os parênteses corretos e repita o mesmo caso.

## 📌 Resumo

Leia a primeira mensagem relevante, localize seu arquivo e reduza a reprodução. Uma correção
só fica comprovada quando a entrada que falhava passa e as entradas válidas continuam corretas.

## ☑️ Checklist de domínio

- [ ] Classifico um erro como compilação, execução ou lógica.
- [ ] Encontro meu arquivo em uma stack trace.
- [ ] Registro esperado e observado antes de alterar o código.
- [ ] Trato texto inválido sem encerrar o programa.

## 📚 Referências oficiais

- [Dart — Diagnostics](https://dart.dev/tools/diagnostics)
- [Dart — Exceptions](https://dart.dev/language/error-handling)
- [int.tryParse](https://api.dart.dev/dart-core/int/tryParse.html)

| Anterior | Módulo | Próxima etapa |
|---|---|---|
| [Funções](09-funcoes.md) | [README](README.md) | [Exercícios](../../exercicios/01-logica-e-fundamentos.md) |
