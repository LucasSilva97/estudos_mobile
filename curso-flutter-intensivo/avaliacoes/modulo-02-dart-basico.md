# Avaliação — Módulo 02: Dart básico

> **Tempo sugerido:** 25 min de questões + 35 min de prática. Faça sem consultar aulas ou gabarito.

## 1. Questionário

Cada questão vale 1 ponto. Nas questões 1–6, escolha uma alternativa.

1. Qual declaração só pode receber um valor conhecido em compilação?
   - A. `var agora = DateTime.now()`  
   - B. `final agora = DateTime.now()`  
   - C. `const minutos = 60`  
   - D. `late String nome`
2. Para converter entrada do usuário sem lançar erro, escolha:
   - A. `int.parse(texto)`  
   - B. `int.tryParse(texto.trim())`  
   - C. `texto as int`  
   - D. `texto!`
3. Qual expressão trata uma `String?` sem forçar nulo?
   - A. `nome!.toUpperCase()`  
   - B. `nome?.toUpperCase() ?? 'SEM NOME'`  
   - C. `String nome = null`  
   - D. `nome as String`
4. Qual coleção garante elementos únicos?
   - A. `List`  
   - B. `Set`  
   - C. `Map`  
   - D. `String`
5. Em um `Map<String, int>`, para que serve `update` com `ifAbsent`?
   - A. Ordenar chaves.  
   - B. Somar ou criar um valor para uma chave.  
   - C. Converter o map em lista.  
   - D. Remover duplicatas.
6. Qual operação calcula o acumulado de uma lista?
   - A. `where`  
   - B. `map`  
   - C. `fold`  
   - D. `expand`

Responda 7–10 em duas a quatro frases.

7. Diferencie `final` e `const`, com um exemplo que use `DateTime.now()`.
8. Explique por que `String?` não pode ser usado onde se exige `String` sem uma verificação.
9. Compare `List`, `Set` e `Map` para registrar sessões por matéria.
10. Explique por que `stdin.readLineSync()` pode produzir `null` e como encerrar o laço com segurança.

## 2. Exercício prático avaliativo

Crie `bin/avaliacao_modulo02.dart`. Receba linhas no formato `matéria,minutos` até linha vazia ou EOF. Ignore linhas sem vírgula, matéria vazia, número inválido e número menor ou igual a zero. Ao fim, mostre total, quantidade de sessões, média sem divisão por zero, maior sessão, matérias únicas e total por matéria.

Com `Dart,25`, `Git,30`, `Dart,40`, `Dart,abc`, `,10`, a saída deve conter: 3 sessões, total 95, média `31.7`, maior 40, matérias Dart e Git, e Dart 65/Git 30. Teste também entrada vazia e meta exata de 120 minutos.

| Critério verificável | Pontos |
|---|---:|
| Conversão segura e rejeição das linhas inválidas | 2 |
| `Set` e `Map` adequados, com agrupamento correto | 2 |
| Total, quantidade, maior e média corretos | 2 |
| EOF e entrada vazia não lançam exceção | 1 |
| Código separado em funções legíveis | 1 |
| Casos principal, vazio e meta exata executados | 2 |

## 3. Autoavaliação

| Competência | Nota 1–5 | Evidência ou dúvida |
|---|---:|---|
| Escolho `var`, `final`, `const` e `late` | | |
| Converto texto sem lançar erro | | |
| Trato `null` sem `!` desnecessário | | |
| Uso `switch` e funções nomeadas | | |
| Transformo listas sem modificar a original | | |
| Agrupo dados com `Set` e `Map` | | |

## 4. Critérios para avançar

- Pelo menos 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `dart format .` não altera o código e `dart analyze` não mostra erros.
- Você explica o tratamento de entrada inválida e de lista vazia.

## 5. Se teve dificuldade

| Sintoma | Revisar | Refazer |
|---|---|---|
| Escolha de declaração confusa | [Aula 03](../modulos/02-dart-basico/03-var-final-const.md) | E02 |
| Conversão encerra o programa | [Aula 04](../modulos/02-dart-basico/04-tipos-strings-conversoes.md) | E03 |
| Nulo causa falha | [Aula 05](../modulos/02-dart-basico/05-null-safety.md) | E04 |
| Coleções não agrupam corretamente | [Aulas 08 e 09](../modulos/02-dart-basico/09-sets-e-maps.md) | E07 e E08 |
| Entrada do terminal falha | [Aula 10](../modulos/02-dart-basico/10-entrada-e-saida.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-02) · [Próximo módulo](../modulos/03-dart-intermediario/README.md)
