# Avaliação — Módulo 01: Lógica e fundamentos

> **Tempo sugerido:** 25 min de questionário + 35 min de prática. Faça sem consultar o material.

## 1. Questionário de revisão

Cada questão vale 1 ponto. Nas questões 1 a 6, escolha uma alternativa.

**1. Qual descrição separa corretamente entrada, processamento e saída?**

- A. Imprimir, salvar e compilar.
- B. Receber durações, calcular o total e mostrar a situação.
- C. Criar variável, criar constante e criar função.
- D. Abrir editor, executar e fechar terminal.

**2. Qual declaração representa um horário obtido agora que não será reatribuído?**

- A. `const horario = DateTime.now();`
- B. `dynamic horario = DateTime.now();`
- C. `final horario = DateTime.now();`
- D. `var horario; horario = 1; horario = 'agora';`

**3. Qual é o resultado de `(7 ~/ 2) + (7 % 2)`?**

- A. 3
- B. 3.5
- C. 4
- D. 5

**4. Em um `for`, o que `continue` faz?**

- A. Encerra a função.
- B. Reinicia o programa.
- C. Pula o restante da passagem atual e segue o laço.
- D. Repete para sempre.

**5. Qual função calcula e permite reutilizar seu resultado?**

- A. `void dobro(int n) { print(n * 2); }`
- B. `int dobro(int n) { return n * 2; }`
- C. `void dobro() { return 2; }`
- D. `int dobro(int n) { print(n * 2); }`

**6. O programa compila e começa, mas `int.parse('x')` lança `FormatException`. É um erro de:**

- A. execução.
- B. sintaxe apenas.
- C. lógica sem falha.
- D. instalação do Android.

Responda às questões 7 a 10 em duas a quatro frases.

**7.** Explique a diferença entre parâmetro e argumento com um exemplo curto.

**8.** Demonstre por que `while (restante > 0)` termina quando o corpo contém
`restante -= 25` e o valor inicial é 50. O que ocorreria sem a subtração?

**9.** Compare `int.parse` e `int.tryParse` para entrada do usuário. Como você trataria `abc`?

**10.** Diferencie erro de compilação, execução e lógica usando um exemplo de cada.

## 2. Exercício prático avaliativo

Crie `bin/avaliacao_modulo01.dart`. O programa usa a lista fixa
`<String>['25', 'abc', '0', '40', '-5', ' 30 ']` e uma meta de 120 minutos.

Implemente funções para:

1. converter texto para um inteiro positivo, devolvendo `null` quando inválido;
2. somar apenas entradas válidas e contar quantas foram aceitas;
3. calcular a média válida sem dividir por zero;
4. informar `Meta atingida` ou `Faltam N min`;
5. imprimir cada entrada rejeitada e um resumo final.

Para os dados fornecidos, a saída precisa comunicar três válidos, total 95, média 31.7, falta 25
e as três entradas rejeitadas (`abc`, `0`, `-5`). Teste também uma lista sem valores válidos.

| Critério verificável | Pontos |
|---|---:|
| Conversão segura e rejeição de não positivos | 2 |
| Contagem e soma corretas, sem alterar a entrada | 2 |
| Média 31.7 e caso sem válidos | 2 |
| Situação da meta correta no limite e acima dele | 1 |
| Funções pequenas e apresentação legível | 1 |
| Casos principal, vazio/inválido e meta exata executados | 2 |

## 3. Autoavaliação

Use 1 para “não consigo” e 5 para “faço e explico sem consultar”.

| Competência | Nota | Evidência ou dúvida |
|---|---:|---|
| Decompor entrada, processamento e saída | | |
| Escolher tipos e mutabilidade | | |
| Escrever operadores e condições | | |
| Demonstrar que um laço termina | | |
| Escrever funções com parâmetros e retorno | | |
| Diagnosticar erros com um caso mínimo | | |

## 4. Critérios mínimos para avançar

- Pelo menos 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- Prática passa no conjunto principal e no caso sem válidos.
- Você explica a diferença entre imprimir e retornar e demonstra a parada de um `while`.

## 5. Se você teve dificuldade

| Sintoma | Revisar | Refazer |
|---|---|---|
| Não consigo transformar o enunciado em passos | [Algoritmos](../modulos/01-logica-e-fundamentos/03-algoritmos-e-decomposicao.md) | E01 |
| Fórmulas dão resultados estranhos | [Operadores](../modulos/01-logica-e-fundamentos/06-operadores.md) | E03 |
| Faixas se sobrepõem | [Condições](../modulos/01-logica-e-fundamentos/07-condicoes.md) | E04 |
| O programa não termina | [Repetições](../modulos/01-logica-e-fundamentos/08-repeticoes.md) | E05 e E06 |
| Função imprime quando deveria calcular | [Funções](../modulos/01-logica-e-fundamentos/09-funcoes.md) | E07 |
| Entrada inválida encerra o programa | [Mensagens de erro](../modulos/01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-01) ·
[Módulo 02](../modulos/02-dart-basico/README.md)
