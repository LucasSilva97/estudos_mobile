# Aula 8 — Repetições

> **Tempo:** 50 min · **Módulo:** 01 — Lógica e fundamentos

## 🎯 Objetivos de aprendizagem

- Repetir uma ação com `for`, `while` e `do-while`.
- Percorrer uma coleção com `for-in` e distinguir contador de acumulador.
- Escolher uma condição de parada e conferir seus limites.

## ✅ Pré-requisitos

[Condições](07-condicoes.md), comparação de números e atribuição com `+=`.
Use o projeto Dart de prática indicado no README do módulo.

## 📖 Conceito

Um laço repete instruções enquanto uma condição permite. `for` reúne início, condição e avanço;
`while` testa antes do corpo; `do-while` testa depois, executando o corpo ao menos uma vez.
`for-in` visita os elementos de uma coleção. `break` encerra o laço; `continue` pula o restante
da passagem atual. Essas são as estruturas da [documentação de laços do Dart](https://dart.dev/language/loops).

Um **contador** responde quantas vezes algo aconteceu. Um **acumulador** soma valores: três
sessões de durações diferentes têm contador 3, mas o acumulador pode ser 95 minutos.
Antes de programar, escreva: valor inicial, regra para continuar e mudança que aproxima o fim.

## 💡 Analogia

Ao distribuir cinco fichas, você conta 1, 2, 3, 4, 5 e para. Se esquecer de aumentar a contagem,
continuará distribuindo fichas. No código, isso vira um laço infinito.

## 🧪 Exemplo mínimo

```dart
void main() {
  for (var sessao = 1; sessao <= 3; sessao++) {
    print('Sessao $sessao');
  }
}
```

Leia o cabeçalho como: comece em 1; entre se for no máximo 3; ao terminar, some 1.

## 📱 Aplicando no Flutter

Uma lista de cartões pode ser construída percorrendo matérias. O cálculo de minutos deve
acontecer sobre os dados; mais tarde, widgets apenas exibirão esse total. Não coloque um
`while` esperando o usuário tocar na tela: ele impediria o processamento dos eventos.

## 💻 Código completo

Crie `bin/repeticoes.dart`. Uma `List<int>` é uma sequência de inteiros; aqui basta saber que
`[25, 0, 40, 30]` contém quatro valores e que `for-in` entrega um de cada vez. Coleções serão
aprofundadas no módulo 02.

```dart
void main() {
  final minutos = <int>[25, 0, 40, 30];
  var sessoes = 0;
  var total = 0;

  for (final duracao in minutos) {
    if (duracao <= 0) continue;
    sessoes++;
    total += duracao;
  }
  print('Sessoes validas: $sessoes');
  print('Total: $total min');

  var restante = 70;
  var blocos = 0;
  while (restante > 0) {
    final bloco = restante >= 25 ? 25 : restante;
    restante -= bloco;
    blocos++;
    print('Bloco $blocos: $bloco min');
  }

  var tentativa = 0;
  do {
    tentativa++;
    print('Tentativa $tentativa');
  } while (tentativa < 1);

  for (final duracao in minutos) {
    if (duracao >= 40) {
      print('Primeira sessao longa: $duracao');
      break;
    }
  }
}
```

Execute `dart run bin/repeticoes.dart`. Saída:

```text
Sessoes validas: 3
Total: 95 min
Bloco 1: 25 min
Bloco 2: 25 min
Bloco 3: 20 min
Tentativa 1
Primeira sessao longa: 40
```

## 🔍 Explicando o código

O zero não representa uma sessão concluída: `continue` impede contar e somar esse item.
Na divisão de 70 minutos, subtrair sempre 25 produziria um bloco maior que o restante no fim.
A expressão condicional escolhe o menor valor: 25, 25 e 20. `restante` diminui em toda passagem,
o que permite demonstrar que o laço termina. O último `break` encerra a procura ao encontrar 40;
a duração 30 não é examinada nesse último laço.

## ⚠️ Erros comuns

- Usar `i <= lista.length` ao indexar: o último índice é `length - 1`.
- Esquecer o avanço em um `while`: confira qual variável muda a condição.
- Zerar `total` dentro do laço: o acumulador precisa sobreviver às passagens.
- Achar que `break` encerra a função inteira: ele encerra o laço mais próximo.

## 🛠️ Exercício guiado

1. Digite e execute o programa; compare as oito linhas da saída.
2. Troque 70 por 50. Espere dois blocos de 25.
3. Troque por 0. Não deve haver linha de bloco; a tentativa ainda aparece uma vez.
4. Acrescente 15 à lista: contador 4, total 110.
5. Registre um teste de mesa com `restante` antes/depois para 70: 70/45, 45/20, 20/0.

## 📝 Exercícios independentes

Na [lista do módulo 01](../../exercicios/01-logica-e-fundamentos.md), faça os exercícios de
acumulação e identificação de laços que não terminam. Entregue código e saída observada.

## 🏆 Desafio opcional

Receba uma lista fixa de durações e encontre a maior usando somente laço e condição.
Para lista vazia, imprima `Nenhuma sessao`. Teste vazia, um item e valores repetidos.

## 📌 Resumo

Escolha o laço pela condição de parada. Contadores contam ocorrências; acumuladores combinam
valores. Demonstre os casos zero, um e vários para reconhecer erros de limite.

## ☑️ Checklist de domínio

- [ ] Explico a ordem das três partes do `for`.
- [ ] Consigo mostrar por que meu `while` termina.
- [ ] Diferencio `break` de `continue` com uma saída concreta.
- [ ] Testo o caso em que nenhuma repetição deve ocorrer.

## 📚 Referências oficiais

[Dart — Loops](https://dart.dev/language/loops)

| Anterior | Módulo | Próxima |
|---|---|---|
| [Condições](07-condicoes.md) | [README](README.md) | [Funções](09-funcoes.md) |
