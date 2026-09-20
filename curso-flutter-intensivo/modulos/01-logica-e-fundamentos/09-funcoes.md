# Aula 9 — Funções

> **Tempo:** 45 min · **Módulo:** 01 — Lógica e fundamentos

## 🎯 Objetivos de aprendizagem

- Decompor um cálculo em operações com nomes claros.
- Distinguir parâmetro, argumento, retorno e impressão.
- Reconhecer o escopo de uma variável.

## ✅ Pré-requisitos

[Repetições](08-repeticoes.md), números inteiros, condicionais e interpolação de texto.

## 📖 Conceito

Uma função agrupa instruções sob um nome. Os **parâmetros** são as entradas declaradas;
os **argumentos** são os valores fornecidos na chamada. `return` devolve um resultado;
`void` indica que a chamada não oferece um valor utilizável. Uma variável local existe no
escopo, ou região de código, em que foi declarada. Veja a
[documentação de funções](https://dart.dev/language/functions).

Separe duas responsabilidades: calcular quanto falta e decidir como mostrar o resultado.
Assim, a mesma regra serve ao terminal, à tela do aplicativo e a um teste. Uma função que
só imprime `25` não permite a outra parte do programa somar esse resultado a um número.

## 💡 Analogia

Uma calculadora recebe dois números e devolve uma soma. A impressora recebe o resultado e
produz uma folha. Calcular e exibir podem colaborar sem precisar ser a mesma operação.

## 🧪 Exemplo mínimo

```dart
int dobrar(int valor) {
  return valor * 2;
}

void main() {
  final resultado = dobrar(12);
  print(resultado); // 24
}
```

`valor` é parâmetro; `12` é argumento. `resultado` recebe o valor retornado.

## 📱 Aplicando no Flutter

Uma tela pode chamar `calcularRestante` e usar o retorno num texto ou numa barra de progresso.
A função de cálculo não importa Flutter nem conhece botões: isso permite testá-la isoladamente.
Uma função sem efeitos externos, com saída determinada pelas entradas, costuma ser chamada de pura.

## 💻 Código completo

Crie `bin/funcoes.dart`:

```dart
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

void mostrarPlano(String materia, int restante) {
  final blocos = contarBlocos(restante, 25);
  print('$materia: faltam $restante min em $blocos blocos');
}

void main() {
  final restante = calcularRestante(120, 50);
  mostrarPlano('Dart', restante);
  mostrarPlano('Git', calcularRestante(30, 45));
  print('Blocos para 50 min: ${contarBlocos(50, 25)}');
}
```

Execute `dart run bin/funcoes.dart`:

```text
Dart: faltam 70 min em 3 blocos
Git: faltam 0 min em 0 blocos
Blocos para 50 min: 2
```

## 🔍 Explicando o código

O primeiro `return` de `calcularRestante` impede um resultado negativo quando a meta foi
ultrapassada. Em `contarBlocos`, `~/` conta os blocos completos; `%` revela se ainda falta um
bloco parcial. O retorno 0 para tamanho inválido é uma escolha desta introdução; no módulo 04
você aprenderá a sinalizar entrada inválida com exceções. Não confunda esse caso com uma meta
realmente concluída em um produto final.

`restante` em `main` e o parâmetro de mesmo nome em `mostrarPlano` são variáveis locais distintas.
A função recebe o valor da chamada. O `blocos` criado em `mostrarPlano` não pode ser usado
diretamente em `main`; você teria de devolvê-lo ou calculá-lo naquela função.

## ⚠️ Erros comuns

- Esquecer `return` em um caminho de uma função `int`.
- Usar o resultado de uma função `void` em uma conta.
- Trocar a ordem dos argumentos: `calcularRestante(50, 120)` descreve outro problema.
- Criar uma variável global apenas para transportar resultados entre funções.

## 🛠️ Exercício guiado

1. Digite, execute e explique cada chamada de `main`.
2. Teste `calcularRestante(120, 120)` e `(120, 150)`: ambos devem devolver 0.
3. Teste blocos para 1, 25 e 26 minutos com tamanho 25: espere 1, 1 e 2.
4. Mude o texto de `mostrarPlano`: o cálculo deve continuar igual.
5. Tente acessar `blocos` em `main`, leia o erro e remova essa tentativa.

## 📝 Exercícios independentes

Faça os exercícios de funções na [lista do módulo](../../exercicios/01-logica-e-fundamentos.md).
Entregue entradas, retornos previstos e retornos reais.

## 🏆 Desafio opcional

Escreva `String formatarDuracao(int minutos)` para produzir `1h 05min` quando recebe 65 e
`0h 00min` quando recebe 0. Use divisão inteira, resto e uma condição para preencher o zero.
Documente como sua função trata valores negativos.

## 📌 Resumo

Nomeie uma responsabilidade, declare entradas e devolva o resultado. Deixe a apresentação em
uma função separada. Variáveis locais ajudam a entender o que cada operação precisa conhecer.

## ☑️ Checklist de domínio

- [X] Aponto parâmetro e argumento em um exemplo meu.
- [X] Explico a diferença entre imprimir e retornar.
- [X] Testo zero, limite exato e valor acima do limite.
- [X] Divido um problema em cálculo e apresentação.

## 📚 Referências oficiais

[Dart — Functions](https://dart.dev/language/functions)

| Anterior                        | Módulo            | Próxima                                          |
| ------------------------------- | ------------------ | ------------------------------------------------- |
| [Repetições](08-repeticoes.md) | [README](README.md) | [Mensagens de erro](10-lendo-mensagens-de-erro.md) |
