# Exercícios — Módulo 02: Dart básico

> Faça E01–E08. E09–E12 são opcionais. Para todos, rode `dart format .` e `dart analyze` no
> projeto `dart_basico` antes de consultar a solução.

<a id="m02-e01"></a>
## M02-E01 — Anatomia e estilo · Fixação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Criar um programa legível | Fácil | 10 min | Aulas 01 e 02 | Sim |

Crie `bin/cartao.dart` com uma função `main`, uma constante de título e uma linha de saída.
Use `lowerCamelCase`, aspas simples e comentário `///` apenas se documentar uma função.

**Resultado esperado:** `Foco | Dart básico`. **Concluído quando:** formatador não muda o arquivo.
**Como testar:** execute `dart run bin/cartao.dart` e `dart analyze`.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e01)

<a id="m02-e02"></a>
## M02-E02 — `var`, `final`, `const` e `late` · Aplicação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Escolher mutabilidade | Média | 15 min | Aula 03 | Sim |

Declare uma meta fixa, minutos que aumentam, data obtida em execução e uma variável `late`
atribuída antes de ser lida. Justifique cada escolha em comentário.

**Resultado esperado:** compila sem reatribuir `final`/`const`. **Concluído quando:** as quatro
escolhas são justificadas. **Como testar:** aumente minutos e rode duas vezes.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e02)

<a id="m02-e03"></a>
## M02-E03 — Conversões seguras · Correção de bugs

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Corrigir conversão externa | Média | 15 min | Aula 04 | Sim |

Troque `int.parse(texto)` por uma solução que aceite `" 42 "` e rejeite `"quarenta"`, vazio e
`"2.5"` sem lançar exceção.

**Resultado esperado:** somente 42 aceito. **Concluído quando:** os quatro casos terminam normalmente.
**Como testar:** percorra a lista dos quatro textos e imprima aceito/rejeitado.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e03)

<a id="m02-e04"></a>
## M02-E04 — Nulo sem `!` · Leitura de código

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Prever null safety | Média | 10 min | Aula 05 | Sim |

Explique a saída de `final String? nome = null; print(nome?.toUpperCase() ?? 'SEM NOME');`.
Depois crie versão que recebe `String?` e devolve texto normalizado.

**Resultado esperado:** `SEM NOME`. **Concluído quando:** nenhuma solução usa `!`.
**Como testar:** use null, `' dart '` e string vazia.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e04)

<a id="m02-e05"></a>
## M02-E05 — Status por `switch` · Aplicação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Usar expressão switch | Média | 15 min | Aula 06 | Sim |

Escreva `String rotulo(int percentual)` para 0=`Não iniciado`, 1–99=`Em andamento` e 100 ou mais
=`Concluído`; negativos são inválidos.

**Resultado esperado:** quatro rótulos. **Concluído quando:** não há faixa descoberta.
**Como testar:** -1, 0, 1, 99, 100 e 150.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e05)

<a id="m02-e06"></a>
## M02-E06 — Função de duração · Implementação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Parâmetros nomeados e retorno | Média | 20 min | Aula 07 | Sim |

Implemente `formatarDuracao({required int minutos, bool mostrarHoras = true})`.

**Resultado esperado:** 65 vira `1h 05min`; com `mostrarHoras: false`, `65 min`.
**Concluído quando:** negativos recebem tratamento explícito. **Como testar:** 0, 5, 60, 65 e -1.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e06)

<a id="m02-e07"></a>
## M02-E07 — Transformar lista · Implementação

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Filtrar e transformar coleções | Média | 20 min | Aula 08 | Sim |

Com `[25, 0, 40, -5, 30]`, crie nova lista só com positivos, outra em horas como `double` e calcule
total com `fold`.

**Resultado esperado:** `[25, 40, 30]`, `[0.416..., 0.666..., 0.5]`, total 95.
**Concluído quando:** original não muda. **Como testar:** lista dada e lista vazia.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e07)

<a id="m02-e08"></a>
## M02-E08 — Agrupar e ler · Revisão cumulativa

| Objetivo | Dificuldade | Tempo | Conhecimentos | Obrigatório? |
|---|---|---|---|---|
| Combinar Map, Set e stdin | Difícil | 30 min | Aulas 09 e 10 | Sim |

Leia matéria e duração até linha vazia, ignore durações inválidas, guarde matérias únicas e some
minutos por matéria.

**Resultado esperado:** `Dart/25`, `Git/30`, `Dart/40` resulta em matérias `{Dart, Git}` e totais
`{Dart: 65, Git: 30}`. **Concluído quando:** Ctrl+Z/Ctrl+D não lança erro.
**Como testar:** caso dado, entrada vazia e duração inválida.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e08)

<a id="m02-e09"></a>
## M02-E09 — Frequência de palavras · Desafio prático

Conte palavras sem distinguir maiúsculas. **Esperado:** `['Dart','dart','Flutter']` →
`{dart: 2, flutter: 1}`. **Teste:** lista vazia e três repetições.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e09)

<a id="m02-e10"></a>
## M02-E10 — `firstWhere` seguro · Correção de bugs

Corrija busca que lança quando não acha uma matéria. **Esperado:** valor de reserva `-1`.
**Teste:** lista com e sem o alvo. [🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e10)

<a id="m02-e11"></a>
## M02-E11 — Coleção imutável · Leitura de código

Explique diferença entre `const` e `List.unmodifiable`, provoque e capture a alteração inválida.
**Esperado:** `UnsupportedError`. **Teste:** altere a lista original após criar cópia protegida.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e11)

<a id="m02-e12"></a>
## M02-E12 — Calculadora de estudo · Desafio prático

Amplie a Aula 10 com meta, sessões, total, média, maior sessão e matérias únicas.
**Esperado:** não divide por zero e não aceita texto inválido. **Teste:** sem sessões, meta exata e meta superada.
[🔑 Gabarito](../gabaritos/02-dart-basico.md#m02-e12)

[Módulo](../modulos/02-dart-basico/README.md)
