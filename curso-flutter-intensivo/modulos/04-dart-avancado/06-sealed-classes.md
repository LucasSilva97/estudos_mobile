# Aula 6 — Sealed classes e modificadores

> **Módulo:** 04 - Dart Avançado · **Tempo estimado:** 35 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que os modificadores `sealed`, `final`, `base` e `interface class` fazem.
- Criar uma hierarquia `sealed` e consumi-la com `switch` **exaustivo**.
- Modelar os estados de uma tela (Carregando / Sucesso / Erro / Vazio) com dados próprios em cada
  estado.
- Comparar `sealed class` com `enum` e saber quando cada um cabe.
- Reconhecer o `AsyncValue` do Riverpod como uma hierarquia selada pronta.

## ✅ Pré-requisitos

- [Aula 5 — Patterns e switch](05-patterns-e-switch.md): exaustividade e object patterns.
- [Aula 1 — Exceptions](01-exceptions.md): o `Resultado<S, F>` já era uma `sealed class`.
- [Módulo 03 — Abstratas e interfaces](../03-dart-intermediario/05-abstratas-e-interfaces.md) e
  [Enums](../03-dart-intermediario/07-enums.md).

---

## 📖 Conceito

### O problema: "quais são todos os casos possíveis?"

Uma tela que carrega dados tem quatro situações reais: **carregando**, **deu certo com dados**,
**deu certo mas está vazio** e **deu erro**. Com `bool carregando` + `String? erro` + `List? dados`
você consegue representar estados impossíveis — carregando **e** com erro ao mesmo tempo — e
esquecer de tratar algum.

A `sealed class` (*classe selada*) resolve: você declara uma hierarquia **fechada**, e o compilador
passa a saber a lista completa de casos.

### Os modificadores do Dart 3

Antes do Dart 3 havia `abstract` e pronto. Hoje existem modificadores que controlam **quem pode
herdar de quê**:

| Modificador | Pode ser instanciada? | Pode ser `extends` fora da biblioteca? | Pode ser `implements` fora? | Serve para |
|---|---|---|---|---|
| (nenhum) | sim | sim | sim | classe comum |
| `abstract` | não | sim | sim | contrato com implementação parcial |
| `base` | sim | sim (o filho precisa ser `base`, `final` ou `sealed`) | **não** | garantir que todo mundo herde a sua implementação |
| `interface class` | sim | **não** | sim | publicar um contrato e proteger a implementação |
| `final` | sim | **não** | **não** | fechar a classe de vez |
| `sealed` | **não** (é abstrata) | **não** | **não** | hierarquia fechada com `switch` exaustivo |

Onde "biblioteca" (*library*) significa, na prática, **o arquivo** `.dart` onde a classe foi
declarada (mais os `part` dele).

Os dois que você vai usar a toda hora são:

- **`sealed`** — para estados e resultados.
- **`final`** — para as classes concretas dessa hierarquia, porque ninguém de fora deveria
  estendê-las.

> `sealed` já é abstrata: não escreva `abstract sealed`. E `sealed` não se combina com os outros
> modificadores da tabela.

### A regra que dá o superpoder

Como as subclasses de uma `sealed class` **precisam estar no mesmo arquivo**, o compilador conhece
todas elas. Então um `switch` sobre a classe selada é **exaustivo** sem `_`:

```dart
sealed class Forma {
  const Forma();
}

final class Circulo extends Forma {
  const Circulo(this.raio);
  final double raio;
}

final class Quadrado extends Forma {
  const Quadrado(this.lado);
  final double lado;
}

double area(Forma f) => switch (f) {
  Circulo(:final raio) => 3.14159 * raio * raio,
  Quadrado(:final lado) => lado * lado,
};
```

Acrescente `final class Triangulo extends Forma` e o `dart analyze` passa a apontar **todos** os
`switch` que ficaram incompletos, com a mensagem:

```text
error • The type 'Forma' is not exhaustively matched by the switch cases
since it doesn't match 'Triangulo()'
```

Isso é a diferença entre descobrir o caso faltante **na sua máquina** e descobrir na mão do
usuário.

### `sealed` × `enum`

| | `enum` | `sealed class` |
|---|---|---|
| Quantidade de valores | fixa e **sem dados por caso** | fixa, **cada caso com seus próprios dados** |
| Exemplo | `Nivel.iniciante` | `Erro('sem internet', podeTentarDeNovo: true)` |
| Genéricos (`<T>`) | não | sim |
| Exaustividade no `switch` | sim | sim |
| Quando usar | rótulo fechado (`Nivel`, `DiaDaSemana`, `Prioridade`) | estado que carrega dados diferentes por caso |

Um `enum` avançado (*enhanced enum*, do
[módulo 03](../03-dart-intermediario/07-enums.md)) até guarda campos — mas **os mesmos campos para
todos os valores**. Se "Erro" precisa de mensagem e "Sucesso" precisa de uma lista, é `sealed`.

### Estados de tela: o padrão que você vai repetir o curso inteiro

```dart
sealed class EstadoTela<T> { const EstadoTela(); }
final class Carregando<T> extends EstadoTela<T> { const Carregando(); }
final class Vazio<T> extends EstadoTela<T> { const Vazio(); }
final class Sucesso<T> extends EstadoTela<T> { const Sucesso(this.dados); final T dados; }
final class ErroEstado<T> extends EstadoTela<T> { const ErroEstado(this.mensagem); final String mensagem; }
```

Estados impossíveis deixam de existir: ou é `Carregando`, ou é `Sucesso`, ou é `Vazio`, ou é
`ErroEstado`. Nunca dois.

### E o `AsyncValue` do Riverpod?

O Riverpod 3.4.3 já traz `AsyncValue<T>`, que é exatamente esta ideia pronta, com três casos:
**loading**, **data** e **error**. Você vai usá-lo no lugar de escrever o seu `EstadoTela` quando o
estado vier de um provider.

Três diferenças que valem anotar desde já:

1. `AsyncValue` **não tem** estado "vazio": lista vazia é `data` com uma lista sem itens, e a tela
   decide mostrar "nada por aqui".
2. O acesso ao valor é `estado.value` (que é `T?`, nulo enquanto carrega) — a propriedade
   `.valueOrNull` **não existe mais** no Riverpod 3.
3. Ele guarda o valor anterior durante um recarregamento, para a tela não "piscar".

Você aprende tudo isso em
[08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).
O que você escreve hoje à mão é o que vai reconhecer pronto lá.

## 💡 Analogia

Um `enum` é a lista de opções de um formulário: iniciante, intermediário, avançado. Cada opção é
só um rótulo.

Uma `sealed class` é o **conjunto de envelopes oficiais** de uma repartição: envelope "protocolo em
andamento" (vazio por dentro), envelope "deferido" (traz o documento), envelope "indeferido" (traz
o motivo). São só esses, estão todos catalogados, e o funcionário do balcão é **obrigado** a saber
o que fazer com cada um — se aparecer um envelope novo, o manual de atendimento acusa a falta antes
de o balcão abrir.

---

## 🧪 Exemplo mínimo

```dart
sealed class Resposta {
  const Resposta();
}

final class Ok extends Resposta {
  const Ok(this.corpo);
  final String corpo;
}

final class Falhou extends Resposta {
  const Falhou(this.codigo);
  final int codigo;
}

String descrever(Resposta r) => switch (r) {
  Ok(:final corpo) => 'deu certo: $corpo',
  Falhou(:final codigo) => 'falhou com código $codigo',
};

void main() {
  print(descrever(const Ok('lista de matérias')));
  print(descrever(const Falhou(404)));
}
```

Saída:

```text
deu certo: lista de matérias
falhou com código 404
```

---

## 📱 Aplicando no Flutter

Este é, provavelmente, o conceito desta aula que você mais vai usar:

- **A tela inteira em um `switch`.** Em
  [06 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) o `build` de uma tela vira um
  `switch` sobre o estado que devolve o widget certo: indicador de progresso, mensagem de erro com
  botão "Tentar de novo", tela de "nada por aqui" ou a lista.
- **Widgets reutilizáveis de estado.** O projeto final tem `lib/core/widgets/carregando.dart`,
  `estado_vazio.dart` e `estado_erro.dart` justamente porque cada caso do `sealed` vira um widget
  ([projeto final — etapa 1](../../projetos/03-projeto-final-multiplataforma/03-etapa-1-fundacao.md)).
- **Falhas de domínio.** `lib/core/erros/falhas.dart` usa uma hierarquia selada de falhas
  (sem internet, servidor fora, dado inválido) para a camada de apresentação escolher a mensagem em
  português — veja [09 — Modelando respostas e erros](../09-consumo-de-api/04-modelando-respostas-e-erros.md).
- **`AsyncValue` pronto.** Com Riverpod 3.4.3 você raramente escreve o `EstadoTela` à mão; mas
  entender a mecânica é o que evita usar `AsyncValue` como caixa-preta
  ([08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)).

---

## 💻 Código completo

> **Arquivo:** `bin/aula06_sealed.dart`
> **Como executar:** `dart run bin/aula06_sealed.dart`

```dart
// Aula 6 — sealed, final, base e interface class; estados de tela com switch exaustivo.

/// ---------------------------------------------------------------------------
/// 1) Hierarquia SELADA de estados de tela, genérica no tipo dos dados.
/// ---------------------------------------------------------------------------
sealed class EstadoTela<T> {
  const EstadoTela();
}

/// `final class`: ninguém fora deste arquivo estende nem implementa.
final class Carregando<T> extends EstadoTela<T> {
  const Carregando();
}

final class Vazio<T> extends EstadoTela<T> {
  const Vazio({this.dica = 'Nada por aqui ainda.'});
  final String dica;
}

final class Sucesso<T> extends EstadoTela<T> {
  const Sucesso(this.dados);
  final T dados;
}

final class ErroEstado<T> extends EstadoTela<T> {
  const ErroEstado(this.mensagem, {this.podeTentarDeNovo = true});
  final String mensagem;
  final bool podeTentarDeNovo;
}

/// O switch é exaustivo porque EstadoTela é sealed: não existe `_`.
String descreverTela(EstadoTela<List<String>> estado) => switch (estado) {
  Carregando() => '[spinner] Carregando matérias...',
  Vazio(:final dica) => '[vazio] $dica',
  Sucesso(:final dados) => '[lista] ${dados.length} matérias: ${dados.join(", ")}',
  ErroEstado(:final mensagem, :final podeTentarDeNovo) =>
    '[erro] $mensagem${podeTentarDeNovo ? ' — botão "Tentar de novo"' : ''}',
};

/// Simula o ciclo de vida de uma tela que busca dados.
EstadoTela<List<String>> carregar(List<String> materias, {bool falhar = false}) {
  if (falhar) {
    return const ErroEstado<List<String>>('Sem conexão com a internet');
  }
  if (materias.isEmpty) {
    return const Vazio<List<String>>(dica: 'Cadastre sua primeira matéria.');
  }
  return Sucesso<List<String>>(materias);
}

/// ---------------------------------------------------------------------------
/// 2) sealed para RESULTADO de operação (o padrão da aula 1, agora com nome).
/// ---------------------------------------------------------------------------
sealed class Falha {
  const Falha();
}

final class FalhaDeRede extends Falha {
  const FalhaDeRede();
}

final class FalhaDoServidor extends Falha {
  const FalhaDoServidor(this.codigo);
  final int codigo;
}

final class FalhaDeDados extends Falha {
  const FalhaDeDados(this.campo);
  final String campo;
}

/// Cada falha vira uma mensagem em português — sem `_`, sem esquecer nenhuma.
String mensagemPara(Falha falha) => switch (falha) {
  FalhaDeRede() => 'Você está sem internet. Verifique a conexão.',
  FalhaDoServidor(:final codigo) when codigo >= 500 =>
    'O servidor está com problemas (código $codigo). Tente mais tarde.',
  FalhaDoServidor(:final codigo) => 'Não foi possível concluir (código $codigo).',
  FalhaDeDados(:final campo) => 'O campo "$campo" veio em formato inesperado.',
};

/// ---------------------------------------------------------------------------
/// 3) Comparação com ENUM: rótulo fechado, sem dados por caso.
/// ---------------------------------------------------------------------------
enum Prioridade {
  baixa('Pode esperar'),
  media('Nesta semana'),
  alta('Hoje');

  const Prioridade(this.descricao);
  final String descricao;
}

/// ---------------------------------------------------------------------------
/// 4) base e interface class.
/// ---------------------------------------------------------------------------

/// `base`: quem herdar é obrigado a reaproveitar esta implementação,
/// e ninguém pode apenas "implementar" a assinatura por fora.
base class Notificador {
  void avisar(String mensagem) => print('   [aviso] $mensagem');
}

/// Filho de classe `base` precisa ser `base`, `final` ou `sealed`.
final class NotificadorDeEstudo extends Notificador {
  void lembrarSessao(String materia) => avisar('Hora de estudar $materia!');
}

/// `interface class`: pode ser IMPLEMENTADA por qualquer um, mas não estendida
/// fora deste arquivo. É o formato ideal para contratos de repositório.
interface class RepositorioDeMaterias {
  List<String> listar() => const <String>[];
}

/// Implementação falsa, útil em testes: reescreve tudo.
final class RepositorioFake implements RepositorioDeMaterias {
  @override
  List<String> listar() => const <String>['Dart', 'Flutter'];
}

void main() {
  print('--- 1) estados de tela ---');
  final cenarios = <EstadoTela<List<String>>>[
    const Carregando<List<String>>(),
    carregar(const <String>[]),
    carregar(const <String>['Dart', 'Flutter', 'SQL']),
    carregar(const <String>['Dart'], falhar: true),
    const ErroEstado<List<String>>('Dados corrompidos', podeTentarDeNovo: false),
  ];
  for (final estado in cenarios) {
    print('   ${descreverTela(estado)}');
  }

  print('\n--- 2) falhas seladas ---');
  const falhas = <Falha>[
    FalhaDeRede(),
    FalhaDoServidor(503),
    FalhaDoServidor(404),
    FalhaDeDados('minutos'),
  ];
  for (final falha in falhas) {
    print('   ${mensagemPara(falha)}');
  }

  print('\n--- 3) enum: rótulo fechado ---');
  for (final p in Prioridade.values) {
    print('   ${p.name}: ${p.descricao}');
  }

  print('\n--- 4) base e interface class ---');
  NotificadorDeEstudo().lembrarSessao('Dart');
  final RepositorioDeMaterias repositorio = RepositorioFake();
  print('   repositório fake devolveu: ${repositorio.listar()}');
}
```

Saída esperada:

```text
--- 1) estados de tela ---
   [spinner] Carregando matérias...
   [vazio] Cadastre sua primeira matéria.
   [lista] 3 matérias: Dart, Flutter, SQL
   [erro] Sem conexão com a internet — botão "Tentar de novo"
   [erro] Dados corrompidos

--- 2) falhas seladas ---
   Você está sem internet. Verifique a conexão.
   O servidor está com problemas (código 503). Tente mais tarde.
   Não foi possível concluir (código 404).
   O campo "minutos" veio em formato inesperado.

--- 3) enum: rótulo fechado ---
   baixa: Pode esperar
   media: Nesta semana
   alta: Hoje

--- 4) base e interface class ---
   [aviso] Hora de estudar Dart!
   repositório fake devolveu: [Dart, Flutter]
```

### Experimento obrigatório

Acrescente ao arquivo, **depois** das outras:

```dart
final class Reconectando<T> extends EstadoTela<T> {
  const Reconectando();
}
```

Salve e rode `dart analyze`. Você verá o erro apontando `descreverTela`, dizendo que o `switch` não
cobre `Reconectando()`. **Esse erro é o produto desta aula**: o compilador encontrou, em segundos,
o caso que você esqueceria por meses.

---

## 🔍 Explicando o código

**`sealed class EstadoTela<T> { const EstadoTela(); }`**
`sealed` fecha a hierarquia neste arquivo e torna a classe implicitamente abstrata — não dá para
fazer `EstadoTela()`. O construtor `const` existe para as subclasses poderem ser `const`, o que no
Flutter evita reconstruções desnecessárias de widget.

**`final class Carregando<T> extends EstadoTela<T>`**
`final` impede que alguém, em outro arquivo, estenda ou implemente `Carregando`. Um `class` simples
também funcionaria; usar `final` é a escolha conservadora: a hierarquia só muda **aqui**.

**`Carregando()` dentro do `switch`**
Um object pattern sem campos: casa apenas pelo tipo. Não é preciso repetir `<List<String>>` — o
Dart deduz o argumento genérico a partir do tipo da variável do `switch`.

**`Vazio(:final dica)`**
Casa e já extrai `dica`. Note que `Vazio` carrega **dados próprios** (a dica) que nenhum outro
estado tem — é justamente isso que um `enum` não consegue fazer.

**`FalhaDoServidor(:final codigo) when codigo >= 500` antes de `FalhaDoServidor(:final codigo)`**
Dois casos do mesmo tipo, separados pelo guard. Se você inverter a ordem, o segundo nunca é
alcançado. O `switch` continua exaustivo porque o caso **sem** guard cobre o restante — um `switch`
em que **todos** os casos de um tipo tivessem `when` não seria considerado exaustivo.

**`enum Prioridade { baixa('Pode esperar'), ... }`**
Um *enhanced enum*: cada valor guarda uma descrição. Repare no limite: todos os valores têm **o
mesmo** campo `descricao`. Não há como dar à `alta` um campo que a `baixa` não tenha.

**`base class Notificador` e `final class NotificadorDeEstudo extends Notificador`**
`base` garante que qualquer subtipo **herde** a implementação de `avisar` em vez de reescrevê-la
por `implements`. Por isso o filho precisa ser `base`, `final` ou `sealed` — a restrição é
transitiva, e o Dart obriga você a declará-la.

**`interface class RepositorioDeMaterias` e `final class RepositorioFake implements ...`**
Como é `interface class`, `RepositorioFake` pode **implementar** (reescrevendo tudo) mas não
estender. É o formato ideal para contratos: no
[módulo 09](../09-consumo-de-api/07-camada-de-dados-testavel.md) você troca o repositório real por
um falso nos testes exatamente assim.

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | Colocar as subclasses em outro arquivo | `The class 'X' can't be extended outside of its library` | Tudo no mesmo `.dart` |
| 2 | Tentar instanciar a classe selada | `Sealed class 'EstadoTela' can't be instantiated` | Instancie uma subclasse |
| 3 | Escrever `abstract sealed class` | Erro de compilação | `sealed` já é abstrata |
| 4 | Pôr `_` no `switch` sobre sealed | O compilador para de avisar quando você cria um caso novo | Remova o `_` e trate cada caso |
| 5 | Usar `enum` para estados com dados diferentes | Campos nulos espalhados em todos os valores | Use `sealed` |
| 6 | Estender classe `base` sem marcar o filho | `The class 'X' must be 'base', 'final' or 'sealed'` | Marque o filho |
| 7 | Todos os casos com `when` | `not exhaustively matched` | Deixe ao menos um caso sem guard |
| 8 | Usar `.valueOrNull` no `AsyncValue` | Não compila no Riverpod 3 | Use `.value` (ou `.requireValue`) |

---

## 🛠️ Exercício guiado

Vamos modelar o resultado de uma sincronização com o servidor.

**Passo 1.** Crie `bin/guiado06_sincronizacao.dart`.

**Passo 2.** Declare a hierarquia selada com quatro casos, cada um com dados próprios:

```dart
sealed class Sincronizacao {
  const Sincronizacao();
}

final class NuncaSincronizou extends Sincronizacao {
  const NuncaSincronizou();
}

final class EmAndamento extends Sincronizacao {
  const EmAndamento(this.porcentagem);
  final int porcentagem;
}

final class Concluida extends Sincronizacao {
  const Concluida({required this.enviados, required this.recebidos});
  final int enviados;
  final int recebidos;
}

final class Interrompida extends Sincronizacao {
  const Interrompida(this.motivo, {required this.tentativa});
  final String motivo;
  final int tentativa;
}
```

**Passo 3.** Escreva `String statusEmTexto(Sincronizacao s)` com `switch` exaustivo, **sem** `_`,
usando um guard para diferenciar `EmAndamento` acima de 90% ("quase lá") do resto.

**Passo 4.** Escreva `bool podeTentarDeNovo(Sincronizacao s)` — `true` apenas para `Interrompida`
com `tentativa < 3`.

**Passo 5.** No `main`, percorra uma lista com os quatro casos e imprima status e se pode repetir.
Rode com `dart run bin/guiado06_sincronizacao.dart`.

**Passo 6.** Acrescente `final class AguardandoRede extends Sincronizacao` e rode `dart analyze`.
Anote no arquivo, em comentário, quantos lugares o analisador apontou.

**Resultado esperado:** quatro linhas de status; no passo 6, o analisador aponta as duas funções do
passo 3 e 4 como não exaustivas.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md)

Foque nos exercícios de **Implementação** e **Revisão cumulativa** com estados de tela.

---

## 🏆 Desafio opcional

Junte as aulas 1, 4, 5 e 6: escreva `EstadoTela<T> paraEstado<T>(Resultado<T, Falha> resultado)`,
que converte o `Resultado` da aula 1 em um `EstadoTela` desta aula, tratando como `Vazio` o caso em
que o sucesso é uma lista sem itens.

Dicas: a assinatura vai precisar de um `switch` sobre `Resultado` **e** de um teste do tipo do
valor (`if (valor case final List<Object?> lista when lista.isEmpty)`). Depois escreva uma função
que recebe `EstadoTela` e devolve um record `({String titulo, String? acao})`, simulando o que a
tela mostraria.

---

## 📌 Resumo

- `sealed` fecha a hierarquia no arquivo e é implicitamente abstrata; com ela o `switch` fica
  **exaustivo** sem `_`.
- `final` impede `extends` e `implements` de fora; `base` obriga herança; `interface class` permite
  só `implements`.
- Cada subclasse selada pode carregar **dados próprios** — é essa a vantagem sobre `enum`.
- `enum` continua ótimo para rótulos fechados sem dados variáveis por caso.
- Estados de tela: `Carregando` / `Sucesso` / `Vazio` / `Erro` — estados impossíveis deixam de
  existir.
- Criar um caso novo faz o `dart analyze` apontar **todos** os `switch` incompletos.
- O `AsyncValue` do Riverpod 3.4.3 é essa mesma ideia pronta, com `loading` / `data` / `error` —
  e com `.value`, nunca `.valueOrNull`.

---

## ☑️ Checklist de domínio

- [ ] Explico, em uma frase, o que `sealed`, `final`, `base` e `interface class` fazem.
- [ ] Crio uma hierarquia selada com quatro casos e dados diferentes em cada um.
- [ ] Escrevo um `switch` exaustivo sem `_` e sei por que isso é desejável.
- [ ] Provoco de propósito o erro de exaustividade e sei lê-lo.
- [ ] Justifico a escolha entre `enum` e `sealed` para um caso dado.
- [ ] Sei por que as subclasses precisam estar no mesmo arquivo.
- [ ] Relaciono `EstadoTela` com o `AsyncValue` do Riverpod.
- [ ] Rodei `bin/aula06_sealed.dart` e fiz o experimento do `Reconectando`.

---

## 📚 Referências oficiais

- [Class modifiers — dart.dev](https://dart.dev/language/class-modifiers)
- [Class modifiers for API maintainers — dart.dev](https://dart.dev/language/modifier-reference)
- [Patterns: exhaustiveness checking — dart.dev](https://dart.dev/language/branches)
- [Enums — dart.dev](https://dart.dev/language/enums)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Patterns e switch](05-patterns-e-switch.md) | [README](README.md) | [Aula 7 — Análise estática e lints](07-analise-estatica-e-lints.md) |
