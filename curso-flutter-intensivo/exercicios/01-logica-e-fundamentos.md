# Exercícios — Módulo 01: Lógica e fundamentos

> Faça E01–E08 obrigatoriamente. E09–E12 são opcionais. Para cada exercício, escreva primeiro
> o resultado previsto, depois execute. Use `dart format` e `dart analyze` antes de concluir.

<a id="m01-e01"></a>
## M01-E01 — Entrada, processamento e saída · Fixação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Decompor um problema antes do código | Fácil | 10 min | Algoritmos e decomposição | Sim |

Descreva em português um programa que recebe três durações de estudo, calcula total e média e
informa se o total atingiu 120 minutos. Separe entrada, processamento e saída; ainda não programe.

**Resultado esperado:** algoritmo finito, sem passos ambíguos. **Concluído quando:** as três
partes e as fórmulas aparecem. **Como testar:** faça um teste de mesa com 30, 45 e 60; espere
total 135, média 45 e meta atingida. [🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e01)

<a id="m01-e02"></a>
## M01-E02 — Escolha de tipos e constantes · Fixação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Escolher tipo, `var`, `final` e `const` | Fácil | 10 min | Variáveis e tipos | Sim |

Declare nome da matéria, meta fixa de 120 minutos, minutos estudados mutáveis e horário de início
obtido com `DateTime.now()`. Atualize os minutos e imprima tudo. Justifique cada declaração.

**Resultado esperado:** tipos coerentes e minutos atualizados. **Concluído quando:** nenhuma
declaração usa `dynamic` e as quatro escolhas foram justificadas. **Como testar:** rode o arquivo
duas vezes; o horário pode mudar, a meta não. [🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e02)

<a id="m01-e03"></a>
## M01-E03 — Precedência da média · Correção de bugs

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Corrigir uma fórmula | Fácil | 10 min | Operadores e teste de mesa | Sim |

O código `final media = segunda + terca + quarta / 3;` recebe 30, 60 e 90. Preveja a saída,
explique a causa e corrija sem alterar os valores.

**Resultado esperado:** média 60.0. **Concluído quando:** a precedência e os parênteses estão
explicados. **Como testar:** execute também com 0, 0 e 0 e com 10, 10 e 10.
[🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e03)

<a id="m01-e04"></a>
## M01-E04 — Classificação da meta · Aplicação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Escrever condições sem faixas sobrepostas | Média | 15 min | Operadores e condições | Sim |

Crie `classificarMeta(int percentual)`: abaixo de 0 é inválido; 0–49 é `Começando`; 50–99 é
`Quase lá`; 100 ou mais é `Meta atingida`. Devolva texto, sem imprimir dentro da função.

**Resultado esperado:** as quatro classificações. **Concluído quando:** cada inteiro cai em uma
única faixa. **Como testar:** execute com -1, 0, 49, 50, 99, 100 e 150.
[🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e04)

<a id="m01-e05"></a>
## M01-E05 — Teste de mesa de um laço · Leitura de código

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Rastrear contador e acumulador | Média | 15 min | Repetições | Sim |

Sem executar, monte uma tabela com `i`, `total antes` e `total depois`:

```dart
var total = 0;
for (var i = 1; i <= 4; i++) {
  if (i == 3) continue;
  total += i * 10;
}
print(total);
```

**Resultado esperado:** 70. **Concluído quando:** a tabela mostra que 30 não foi somado.
**Como testar:** execute somente depois da previsão; troque `continue` por `break` e preveja 30.
[🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e05)

<a id="m01-e06"></a>
## M01-E06 — Laço que não termina · Correção de bugs

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Demonstrar a condição de parada | Média | 10 min | `while` | Sim |

Corrija sem executar a versão defeituosa: `var restante = 75; while (restante > 0) { print(restante); }`.
Imprima 75, 50 e 25 e termine. Explique a variável que aproxima o laço do fim.

**Resultado esperado:** três linhas e encerramento normal. **Concluído quando:** `restante` chega
a zero. **Como testar:** execute com 75, 25 e 0; imponha limite de tempo pelo terminal se testar
outra variante. [🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e06)

<a id="m01-e07"></a>
## M01-E07 — Resumo semanal · Implementação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Combinar laço, condição e função | Média | 25 min | Aulas 4 a 9 | Sim |

Implemente `int somarValidos(List<int> minutos)`, ignorando valores menores ou iguais a zero,
e `String situacao(int total, int meta)`. No `main`, use `[25, 0, 40, -5, 30]` e meta 120.

**Resultado esperado:** total 95 e `Faltam 25 min`. **Concluído quando:** cálculo e texto estão
em funções separadas e a lista original permanece igual. **Como testar:** use lista vazia,
`[120]`, `[60, 60]` e `[150]`. [🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e07)

<a id="m01-e08"></a>
## M01-E08 — Diagnóstico de entrada · Revisão cumulativa

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Reproduzir e corrigir uma falha de conversão | Média | 20 min | Tipos, funções e erros | Sim |

Explique por que `int.parse('trinta')` falha. Crie `int? converterMinutos(String texto)` usando
`trim` e `tryParse`; rejeite zero e negativos devolvendo `null`.

**Resultado esperado:** `25` e ` 40 ` são aceitos; `trinta`, vazio, `0`, `-1` e `2.5` são
rejeitados. **Concluído quando:** o programa não encerra por entrada inválida. **Como testar:**
percorra exatamente esses sete casos e imprima aceito/rejeitado.
[🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e08)

<a id="m01-e09"></a>
## M01-E09 — FizzBuzz explicado · Aplicação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Ordenar condições sobrepostas | Média | 15 min | `%`, condições e laço | Não |

Imprima 1 a 30; múltiplos de 3 viram `Dart`, de 5 viram `Flutter` e de ambos `DartFlutter`.
Explique por que o caso de ambos deve ser verificado primeiro.

**Resultado esperado:** 15 e 30 produzem `DartFlutter`. **Concluído quando:** são 30 linhas.
**Como testar:** confira 3, 5, 15, 16 e 30. [🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e09)

<a id="m01-e10"></a>
## M01-E10 — Primeiro valor longo · Leitura e aplicação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Usar `break` conscientemente | Média | 15 min | Laços e condição | Não |

Percorra `[20, 0, 35, 90, 120]`, ignore não positivos e imprima somente a primeira sessão com
60 minutos ou mais. Se nenhuma existir, imprima `Nenhuma sessão longa`.

**Resultado esperado:** 90. **Concluído quando:** 120 não é impresso e o caso ausente funciona.
**Como testar:** use a lista original, `[20, 35]`, `[]` e `[60]`.
[🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e10)

<a id="m01-e11"></a>
## M01-E11 — Formatação de duração · Implementação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Decompor divisão inteira e texto | Difícil | 20 min | Funções, `~/`, `%` | Não |

Implemente `String formatarDuracao(int minutos)`. Para negativos, devolva `Inválido`; nos demais,
use `0h 00min`, `1h 05min` e `2h 00min`.

**Resultado esperado:** formatação com dois dígitos nos minutos. **Concluído quando:** os limites
59/60 funcionam. **Como testar:** -1, 0, 5, 59, 60, 65 e 120.
[🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e11)

<a id="m01-e12"></a>
## M01-E12 — Relatório sem resultado impossível · Desafio prático

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Construir um pequeno programa testável | Difícil | 30 min | Módulo inteiro | Não |

Para uma lista fixa, produza quantidade válida, total, média e maior duração. Valores não positivos
não entram. Se não houver válidos, imprima `Sem sessões` e não divida nem procure maior valor.

**Resultado esperado:** para `[25, 0, 40, -5, 30]`, quantidade 3, total 95, média 31.7 e maior
40. **Concluído quando:** o caso vazio não falha. **Como testar:** lista dada, `[]`, `[0, -1]`,
`[25]` e `[20, 20]`. [🔑 Gabarito](../gabaritos/01-logica-e-fundamentos.md#m01-e12)

[Módulo](../modulos/01-logica-e-fundamentos/README.md) ·
[Avaliação](../avaliacoes/modulo-01-logica-e-fundamentos.md)
