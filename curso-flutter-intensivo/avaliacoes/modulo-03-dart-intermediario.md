# Avaliação — Módulo 03: Dart intermediário

> **Tempo sugerido:** 25 min de questões + 40 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Uma instância é: A) o molde da classe; B) um objeto criado a partir da classe; C) um import; D) um enum.  
2. `final` em um campo significa: A) o objeto inteiro é imutável; B) a referência não é reatribuída; C) o campo é privado; D) o valor é compilado.  
3. Qual recurso expõe leitura controlada de `_total`? A) `import`; B) `get total`; C) `extends`; D) `late`.  
4. Uma classe abstrata pode: A) ser instanciada sempre; B) declarar contrato sem implementação; C) substituir `Map`; D) ignorar tipos.  
5. `implements` exige: A) herdar implementação; B) fornecer todos os membros do contrato; C) usar `super`; D) criar mixin.  
6. O principal papel de `<T>` é: A) desligar null safety; B) tornar uma classe reutilizável preservando tipo; C) criar enum; D) importar pacote.

7. Diferencie `extends` de `implements`.  
8. Explique por que `copyWith` ajuda a preservar estado previsível.  
9. Dê um caso apropriado para `Set` e um para `Map` no app Foco.  
10. Explique por que um `switch` sobre enum deve ser exaustivo.

## 2. Prática

Modele `TarefaEstudo` imutável (`id`, `titulo`, `minutos`, `status`), enum `StatusTarefa`, `copyWith` e interface genérica `Repositorio<T>`. Implemente repositório em memória, cadastre duas tarefas, atualize uma por cópia e liste somente as pendentes.

| Critério | Pontos |
|---|---:|
| Modelo imutável e validações | 2 |
| Enum e `switch` exaustivo | 2 |
| Contrato genérico e implementação em memória | 2 |
| Atualização não modifica o objeto original | 2 |
| Cadastro, busca ausente e filtro de pendentes testados | 2 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `dart analyze` sem erros.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Construtores e invariantes | [Aula 02](../modulos/03-dart-intermediario/02-construtores.md) | E02 |
| Estado mutável demais | [Aula 03](../modulos/03-dart-intermediario/03-encapsulamento.md) | E03 e E04 |
| Contratos e herança | [Aulas 04 e 05](../modulos/03-dart-intermediario/05-abstratas-e-interfaces.md) | E05 e E06 |
| Tipos genéricos | [Aula 08](../modulos/03-dart-intermediario/08-generics.md) | E09 e E10 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-03)
