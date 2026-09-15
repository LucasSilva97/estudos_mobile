# Exercícios — Módulo 03: Dart intermediário

> Faça E01–E08 obrigatoriamente. E09–E12 são opcionais. Execute `dart format .` e `dart analyze` antes de consultar o gabarito.

<a id="m03-e01"></a>
## M03-E01 — Classe de sessão · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Modelar dados e comportamento | Fácil | 15 min | Sim |
Crie `SessaoEstudo` com matéria, minutos e método `descricao()`. Teste duas instâncias independentes. **Esperado:** cada objeto preserva seus próprios valores. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e01)

<a id="m03-e02"></a>
## M03-E02 — Construtores válidos · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Usar construtor e `assert` | Média | 20 min | Sim |
Faça `MetaSemanal({required String materia, required int minutos})`, rejeitando matéria vazia e minutos não positivos. Acrescente construtor nomeado `MetaSemanal.padrao`. **Teste:** válido, vazio e zero. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e02)

<a id="m03-e03"></a>
## M03-E03 — Encapsular progresso · Correção de bugs
`progresso.minutos = -20` hoje é permitido. Torne o campo privado, exponha leitura e método `adicionar(int)`, que ignore valor não positivo. **Esperado:** o total nunca diminui. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e03)

<a id="m03-e04"></a>
## M03-E04 — Imutabilidade e `copyWith` · Implementação
Crie `Materia` imutável com nome, cor e `copyWith`. Verifique que alterar a cópia não altera a original. **Teste:** cópia com nova cor e cópia sem argumento. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e04)

<a id="m03-e05"></a>
## M03-E05 — Polimorfismo de notificação · Aplicação
Defina classe abstrata `Notificacao` com `mensagem()`. Implemente `Lembrete` e `AlertaMeta`; receba `List<Notificacao>` e imprima todas sem testar o tipo concreto. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e05)

<a id="m03-e06"></a>
## M03-E06 — Contrato de repositório · Implementação
Crie `abstract interface class Repositorio<T>` com `salvar`, `todos` e `buscarPorId`. Implemente armazenamento em memória para `Materia`. **Teste:** salvar, listar e buscar id ausente. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e06)

<a id="m03-e07"></a>
## M03-E07 — Mixin de auditoria · Aplicação
Crie `mixin Auditavel` que registra uma mensagem e aplique-o a uma classe de repositório. Restrinja-o com `on RepositorioBase`. **Esperado:** operações mostram uma evidência de auditoria. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e07)

<a id="m03-e08"></a>
## M03-E08 — Estado por enum · Revisão cumulativa
Crie enum avançado `StatusMeta` com rótulo e método `permiteRegistrar`. Use `switch` exaustivo para explicar cada estado. **Teste:** todos os valores de `StatusMeta.values`. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e08)

<a id="m03-e09"></a>
## M03-E09 — Caixa genérica · Desafio
Implemente `Caixa<T>` com valor opcional, `estaVazia` e `retirar`. Teste `Caixa<int>` e `Caixa<String>`. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e09)

<a id="m03-e10"></a>
## M03-E10 — Restrição genérica · Leitura de código
Escreva `maiorDuracao<T extends Comparable<T>>(Iterable<T>)`. Explique por que `Object` não basta. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e10)

<a id="m03-e11"></a>
## M03-E11 — Extension de duração · Fixação
Crie extension em `int` para formatar minutos em `1h 05min`, sem alterar `int`. Teste 0, 65 e negativo. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e11)

<a id="m03-e12"></a>
## M03-E12 — Catálogo de estudo · Desafio prático
Una `Materia`, `Repositorio<Materia>`, enum de status e extension em um programa de terminal. Demonstre cadastro, listagem e atualização imutável. [🔑 Gabarito](../gabaritos/03-dart-intermediario.md#m03-e12)

[Módulo](../modulos/03-dart-intermediario/README.md)
