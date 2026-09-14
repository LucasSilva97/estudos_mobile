# Aula 4 — Herança e polimorfismo

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Criar uma subclasse com `extends` e entender o que ela herda.
- Chamar o construtor e os métodos da superclasse com `super` (inclusive `super.parametro`).
- Usar `@override` corretamente e saber por que ele existe.
- Explicar **polimorfismo** e demonstrá-lo com uma lista de objetos de tipos diferentes.
- Aplicar o teste **"é-um" × "tem-um"** para decidir entre **herança** e **composição**.
- Justificar por que o conselho profissional é **prefira composição à herança**.
- Manter a hierarquia **rasa** (no máximo 2 níveis) e dizer o que dá errado quando ela cresce.

## ✅ Pré-requisitos

- [Aula 1](01-classes-e-objetos.md), [Aula 2](02-construtores.md) e
  [Aula 3](03-encapsulamento.md) deste módulo.

---

## 📖 Conceito

### O que é herança

**Herança** é declarar que uma classe é uma **versão especializada** de outra. A classe nova
(subclasse, ou classe-filha) recebe automaticamente todos os campos e métodos da antiga
(superclasse, ou classe-mãe) e pode:

- **acrescentar** membros novos;
- **substituir** (sobrescrever) o comportamento de um método herdado.

```dart
class Atividade {
  final String nome;
  const Atividade(this.nome);
  String descrever() => 'Atividade: $nome';
}

class Leitura extends Atividade {
  const Leitura(super.nome);
}
```

`Leitura` já tem `nome` e `descrever()` sem escrever uma linha. Em Dart, **toda** classe herda de
`Object` quando você não escreve `extends` — é de lá que vêm `toString`, `hashCode` e `==` que você
sobrescreveu na Aula 3.

Dart tem **herança simples**: uma classe tem **uma única** superclasse. Reaproveitar código de
várias fontes é papel dos **mixins** ([Aula 6](06-mixins.md)).

### `super` — três usos distintos

**1. Chamar o construtor da superclasse** (na initializer list):

```dart
class Leitura extends Atividade {
  final int paginas;
  Leitura(String nome, this.paginas) : super(nome);
}
```

**2. A forma curta: `super.parametro`** (a preferida hoje):

```dart
class Leitura extends Atividade {
  final int paginas;
  const Leitura({required super.nome, required this.paginas});
}
```

`super.nome` significa "receba este parâmetro e **encaminhe-o** para o construtor da superclasse".
É o mesmo açúcar de `this.nome`, mirando o andar de cima. É exatamente o `super.key` que você verá
em todo widget do Flutter.

**3. Chamar a versão da superclasse de um método que você sobrescreveu:**

```dart
@override
String descrever() => '${super.descrever()} — $paginas páginas';
```

Se você escrevesse `descrever()` sem o `super.`, a chamada voltaria para a **sua própria** versão:
recursão infinita e `StackOverflowError`.

Quando a superclasse **não tem** construtor sem parâmetros, chamar `super(...)` é **obrigatório**.
O erro é claro:

```text
Error: The superclass 'Atividade' doesn't have a zero argument constructor.
```

### `@override`

`@override` é uma **anotação**: um marcador que não muda o funcionamento do programa, mas informa
ferramentas e leitores.

```dart
@override
String descrever() => '...';
```

Ela faz duas coisas valiosas:

1. **Documenta** para quem lê: "este método existe lá em cima, estou trocando o comportamento".
2. **Protege contra erro de digitação.** Se você escrever `descreveer()` por engano, o analisador
   acusa que não há nada com esse nome para sobrescrever. Sem `@override`, você teria criado, em
   silêncio, um método novo que nunca é chamado — um bug clássico e muito chato de achar.

O lint `annotate_overrides` (ligado pelo `flutter_lints`, do módulo 04) reclama quando você esquece.

**Regra da assinatura:** o método que sobrescreve precisa aceitar **pelo menos** o que o original
aceitava e devolver **no máximo** o que o original prometia. Na prática: mantenha a mesma assinatura.

### Polimorfismo

**Polimorfismo** (do grego, "muitas formas") é a capacidade de tratar objetos de tipos diferentes
**pela mesma interface**, deixando cada um responder do seu jeito.

```dart
final atividades = <Atividade>[
  Leitura(nome: 'Effective Dart', minutos: 40, paginas: 12),
  Videoaula(nome: 'Widgets 101', minutos: 30),
];

for (final atividade in atividades) {
  print(atividade.descrever()); // cada uma responde diferente
}
```

O `for` não sabe nem quer saber quais tipos existem. Adicionar uma `Podcast extends Atividade`
amanhã **não muda uma vírgula** deste laço. Isso é o valor real da OO: pontos de extensão sem
reescrita.

O mecanismo por trás chama-se **despacho dinâmico**: a decisão de qual `descrever()` chamar é
tomada em **tempo de execução**, olhando o tipo real do objeto — não o tipo da variável.

Um efeito importante: se o método da superclasse chama outro método que a subclasse sobrescreveu,
a versão **da subclasse** é que roda. Você vê isso funcionando no código completo.

Para "descer" do tipo geral para o específico, use `is`:

```dart
if (atividade is Exercicio) {
  print(atividade.aproveitamento); // membro só de Exercicio
}
```

Depois do `is`, o Dart faz **promoção de tipo**: dentro do `if`, a variável já é tratada como
`Exercicio`, sem cast manual.

### Quando herdar e quando compor

Esta é a parte que separa código bom de código que apodrece. Faça o teste da frase:

| Relação | Frase | Ferramenta |
|---|---|---|
| **é-um** | "Uma Leitura **é uma** Atividade" ✅ | **Herança** (`extends`) |
| **tem-um** | "Uma Matéria **tem um** cronômetro" ✅ | **Composição** (um campo) |
| **tem-um** disfarçado | "Uma Matéria **é um** cronômetro" ❌ soa errado | Composição |

**Composição** é simplesmente guardar outro objeto como campo e delegar trabalho a ele:

```dart
class Materia {
  final RegistroDeTempo _tempo = RegistroDeTempo(); // TEM-UM
  void estudar(int segundos) => _tempo.adicionarSegundos(segundos);
}
```

**Por que a comunidade repete "prefira composição à herança":**

1. **Herança é o acoplamento mais forte que existe.** A subclasse depende de **detalhes internos**
   da superclasse. Mudar a classe-mãe pode quebrar filhas que você nem lembra que existem.
2. **Você herda tudo, inclusive o que não quer.** Se `Atividade` ganhar um método `excluir()`,
   todas as filhas ganham — mesmo aquelas onde excluir não faz sentido.
3. **Só dá para herdar de uma.** Composição não tem limite: um objeto pode ter cinco colaboradores.
4. **Composição é trocável em tempo de execução.** Você pode injetar um `RegistroDeTempo` falso num
   teste. Herança é decidida na compilação e não se troca.
5. **Herança amarra a hierarquia cedo demais**, quando você ainda entende pouco do problema.

Use herança quando **todas** as condições valerem: a relação é honestamente "é-um", você controla a
superclasse, e a subclasse pode ser usada em **qualquer** lugar onde a superclasse é esperada sem
surpresas.

### Hierarquia rasa

Mantenha **no máximo dois níveis** (`Object` → `Atividade` → `Leitura`).

Quando a hierarquia passa de três níveis, aparecem sintomas conhecidos:

- Para entender um método você precisa abrir quatro arquivos e montar mentalmente a cadeia de
  `super`. É o chamado **problema do ioiô**.
- Ninguém mais sabe em que nível um comportamento foi definido.
- Qualquer mudança no topo vira um jogo de dominó.

Se você sentir vontade de criar o terceiro nível, quase sempre a resposta certa é: extraia um
colaborador (composição) ou um [mixin](06-mixins.md).

---

## 💡 Analogia

Uma **habilitação de motorista**.

- "Todo motorista sabe dirigir" — `Motorista` é a superclasse.
- "Um motorista de caminhão **é um** motorista, e também sabe engatar carreta" — `extends`, com um
  método novo.
- "Um motorista de ambulância **é um** motorista, mas dirige de um jeito diferente em emergência" —
  `@override` do método `dirigir()`.
- A central de despacho pede "vá até o endereço X" para **qualquer** motorista, sem perguntar o
  tipo: **polimorfismo**.

Onde a analogia **para**: a ambulância tem sirene, rádio e maca. Isso não se herda — a ambulância
**tem** esses equipamentos. Equipamento é **composição**.

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_heranca.dart`
> **Como executar:** `dart run bin/exemplo_heranca.dart`

```dart
class Atividade {
  final String nome;
  final int minutos;

  const Atividade({required this.nome, required this.minutos});

  int get pontos => minutos;

  String descrever() => '$nome — $minutos min — $pontos pontos';
}

class Leitura extends Atividade {
  final int paginas;

  const Leitura({
    required super.nome,
    required super.minutos,
    required this.paginas,
  });

  @override
  int get pontos => super.pontos + paginas * 2;
}

void main() {
  const lista = <Atividade>[
    Atividade(nome: 'Revisão', minutos: 25),
    Leitura(nome: 'Effective Dart', minutos: 40, paginas: 12),
  ];

  for (final atividade in lista) {
    print(atividade.descrever());
  }
}
```

Saída:

```text
Revisão — 25 min — 25 pontos
Effective Dart — 40 min — 64 pontos
```

Olhe bem a segunda linha: `descrever()` **não** foi sobrescrito, então rodou a versão de
`Atividade`. Mas o `$pontos` dentro dela devolveu **64**, o valor da `Leitura`. Isso é despacho
dinâmico: dentro da superclasse, `pontos` já é o da subclasse.

---

## 📱 Aplicando no Flutter

Herança é a primeira coisa que você faz em qualquer arquivo Flutter, em toda tela que criar:

```dart
class TelaDeMaterias extends StatefulWidget {
  const TelaDeMaterias({super.key});

  @override
  State<TelaDeMaterias> createState() => _TelaDeMateriasState();
}

class _TelaDeMateriasState extends State<TelaDeMaterias> {
  @override
  void initState() {
    super.initState(); // chamar super PRIMEIRO é obrigatório aqui
    // sua inicialização
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}
```

Reconheça, item por item, o que você acabou de aprender:

- `extends StatefulWidget` → herança;
- `const TelaDeMaterias({super.key})` → encaminhamento de parâmetro para o construtor da superclasse;
- `@override Widget build(...)` → sobrescrita de um método que o framework vai chamar;
- `super.initState()` → chamada explícita à versão da superclasse. No Flutter, **esquecer essa
  linha** é um dos erros mais comuns de iniciante, e o framework lança um erro em tempo de execução.

E o **polimorfismo** é o coração do Flutter: a árvore de widgets é uma lista de objetos de tipos
completamente diferentes (`Text`, `Row`, `Card`, o seu `CartaoDeMateria`) e o framework chama
`build()` em todos, sem saber quem é quem — exatamente o laço `for` desta aula.

Continua em
[`05-introducao-ao-flutter/05-statefulwidget-e-setstate.md`](../05-introducao-ao-flutter/05-statefulwidget-e-setstate.md)
e [`05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md`](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md).

> 💡 Repare também no conselho da própria documentação do Flutter: para reaproveitar visual entre
> telas, **não** crie `class MinhaTelaBase extends StatelessWidget` e herde dela. Crie widgets
> menores e **componha**. Composição é literalmente o modelo mental do Flutter.

---

## 💻 Código completo

> **Arquivo:** `bin/04_heranca_e_polimorfismo.dart`
> **Como executar:** `dart run bin/04_heranca_e_polimorfismo.dart`

```dart
// Aula 4 do Módulo 03 — Herança, super, @override, polimorfismo e composição.

// ===========================================================================
// PARTE 1 — HERANÇA: uma hierarquia RASA (2 níveis) de atividades de estudo.
// ===========================================================================

/// Superclasse: o que TODA atividade de estudo tem em comum.
class Atividade {
  final String nome;
  final int minutos;

  const Atividade({required this.nome, required this.minutos})
      : assert(minutos > 0, 'Uma atividade precisa durar mais que zero.');

  /// Regra padrão de pontuação: 1 ponto por minuto.
  /// As subclasses podem sobrescrever este getter.
  int get pontos => minutos;

  /// Repare: este método usa `pontos`. Quando uma subclasse sobrescreve
  /// `pontos`, é a versão DELA que roda aqui dentro (despacho dinâmico).
  String descrever() => '$nome — $minutos min — $pontos pontos';
}

/// Leitura É UMA atividade: relação "é-um" honesta → herança faz sentido.
class Leitura extends Atividade {
  final int paginas;

  const Leitura({
    required super.nome, // encaminha para o construtor da superclasse
    required super.minutos,
    required this.paginas,
  });

  @override
  int get pontos => super.pontos + paginas * 2; // aproveita a regra de cima

  @override
  String descrever() => '${super.descrever()} (livro: $paginas páginas)';
}

/// Exercício É UMA atividade, com regra própria de pontuação.
class Exercicio extends Atividade {
  final int questoes;
  final int acertos;

  const Exercicio({
    required super.nome,
    required super.minutos,
    required this.questoes,
    required this.acertos,
  }) : assert(acertos <= questoes, 'Não dá para acertar mais do que existe.');

  double get aproveitamento => questoes == 0 ? 0 : acertos / questoes * 100;

  @override
  int get pontos => super.pontos + acertos * 5;

  @override
  String descrever() => '${super.descrever()} (acertos: $acertos/$questoes)';
}

/// Videoaula É UMA atividade, mas IGNORA a regra da superclasse:
/// assistir em 1.5x vale menos pontos por minuto de relógio.
class Videoaula extends Atividade {
  final double velocidade;

  const Videoaula({
    required super.nome,
    required super.minutos,
    this.velocidade = 1.0,
  }) : assert(velocidade > 0, 'Velocidade precisa ser positiva.');

  @override
  int get pontos => (minutos / velocidade).round(); // NÃO chama super

  @override
  String descrever() => '${super.descrever()} (vídeo em ${velocidade}x)';
}

// ===========================================================================
// PARTE 2 — COMPOSIÇÃO: "tem-um" em vez de "é-um".
// ===========================================================================

/// Colaborador reutilizável. Não é uma "atividade", é um serviço.
class RegistroDeTempo {
  int _segundos = 0;

  int get segundos => _segundos;
  int get minutos => _segundos ~/ 60;

  void adicionarSegundos(int valor) {
    if (valor > 0) {
      _segundos += valor;
    }
  }

  void zerar() => _segundos = 0;
}

/// ❌ ERRADO seria: `class Materia extends RegistroDeTempo`.
///    "Uma matéria É UM registro de tempo"? Não. Ela TEM UM.
/// ✅ CERTO: composição. A matéria guarda o colaborador e delega.
class Materia {
  final String nome;
  final int metaSemanalEmMinutos;

  // O colaborador é privado: quem usa Materia nem sabe que ele existe.
  final RegistroDeTempo _tempo = RegistroDeTempo();

  Materia({required this.nome, this.metaSemanalEmMinutos = 300});

  int get minutosEstudados => _tempo.minutos;

  bool get metaAtingida => minutosEstudados >= metaSemanalEmMinutos;

  void estudarPorSegundos(int segundos) => _tempo.adicionarSegundos(segundos);

  @override
  String toString() =>
      'Materia($nome: $minutosEstudados/$metaSemanalEmMinutos min)';
}

// ===========================================================================
// PROGRAMA
// ===========================================================================

void main() {
  print('--- 1. Polimorfismo: uma lista, quatro comportamentos ---');
  const atividades = <Atividade>[
    Atividade(nome: 'Revisão livre', minutos: 25),
    Leitura(nome: 'Effective Dart', minutos: 40, paginas: 12),
    Exercicio(nome: 'Exercícios M02', minutos: 60, questoes: 20, acertos: 17),
    Videoaula(nome: 'Widgets 101', minutos: 30, velocidade: 1.5),
  ];

  for (final atividade in atividades) {
    print(atividade.descrever());
  }

  var total = 0;
  for (final atividade in atividades) {
    total += atividade.pontos;
  }
  print('Total de pontos: $total');

  print('');
  print('--- 2. Descendo ao tipo específico com `is` ---');
  for (final atividade in atividades) {
    if (atividade is Exercicio) {
      // Promoção de tipo: aqui `atividade` já é tratada como Exercicio.
      final percentual = atividade.aproveitamento.toStringAsFixed(0);
      print('${atividade.nome}: aproveitamento de $percentual%');
    }
    if (atividade is Videoaula && atividade.velocidade > 1) {
      print('${atividade.nome}: assistida acelerada.');
    }
  }

  print('');
  print('--- 3. Tipos em tempo de execução ---');
  for (final atividade in atividades) {
    print('${atividade.nome} -> ${atividade.runtimeType} '
        '(é Atividade? ${atividade is Atividade})');
  }

  print('');
  print('--- 4. Composição: Materia TEM UM RegistroDeTempo ---');
  final dart = Materia(nome: 'Dart');
  dart.estudarPorSegundos(3600);
  dart.estudarPorSegundos(1800);
  dart.estudarPorSegundos(-100); // o colaborador recusa
  print(dart);
  print('Meta atingida? ${dart.metaAtingida}');

  final flutter = Materia(nome: 'Flutter', metaSemanalEmMinutos: 60);
  flutter.estudarPorSegundos(4200);
  print(flutter);
  print('Meta atingida? ${flutter.metaAtingida}');
}
```

**Saída esperada:**

```text
--- 1. Polimorfismo: uma lista, quatro comportamentos ---
Revisão livre — 25 min — 25 pontos
Effective Dart — 40 min — 64 pontos (livro: 12 páginas)
Exercícios M02 — 60 min — 145 pontos (acertos: 17/20)
Widgets 101 — 30 min — 20 pontos (vídeo em 1.5x)
Total de pontos: 254

--- 2. Descendo ao tipo específico com `is` ---
Exercícios M02: aproveitamento de 85%
Widgets 101: assistida acelerada.

--- 3. Tipos em tempo de execução ---
Revisão livre -> Atividade (é Atividade? true)
Effective Dart -> Leitura (é Atividade? true)
Exercícios M02 -> Exercicio (é Atividade? true)
Widgets 101 -> Videoaula (é Atividade? true)

--- 4. Composição: Materia TEM UM RegistroDeTempo ---
Materia(Dart: 90/300 min)
Meta atingida? false
Materia(Flutter: 70/60 min)
Meta atingida? true
```

---

## 🔍 Explicando o código

**`class Leitura extends Atividade`**
`Leitura` passa a ter `nome`, `minutos`, `pontos` e `descrever()` de graça, e acrescenta `paginas`.

**`required super.nome`**
Açúcar de **super parâmetro**: recebe o valor e encaminha ao construtor da superclasse. Equivale à
forma longa `Leitura({required String nome, ...}) : super(nome: nome)`, com menos ruído.

**`int get pontos => super.pontos + paginas * 2;`**
`super.pontos` executa **a versão da superclasse** (que devolve `minutos`) e soma o bônus. Se você
escrevesse `pontos + paginas * 2`, o getter chamaria a si mesmo: `StackOverflowError`.

**`'${super.descrever()} (livro: $paginas páginas)'`**
Padrão "estender em vez de reescrever": aproveita o texto da superclasse e acrescenta o seu.

**A linha 64 da saída (`Effective Dart — 40 min — 64 pontos`)**
Vale reler: quem montou esse texto foi `Atividade.descrever()`, chamado via `super`. Lá dentro,
`$pontos` chamou o getter... da `Leitura` (40 + 12×2 = 64). O tipo **real** do objeto é que decide,
não o lugar onde o código está escrito. Esse é o mecanismo mais importante da aula.

**`Videoaula.pontos` não chama `super`**
Sobrescrever **não obriga** a chamar a versão anterior. Aqui a regra é outra: 30 ÷ 1.5 = 20.
`(...).round()` converte `double` para `int` arredondando.

**`const atividades = <Atividade>[...]`**
Uma lista `const` de objetos `const` de **tipos diferentes**. Todos cabem porque todos **são**
`Atividade`. Esse é o polimorfismo já na declaração.

**`if (atividade is Exercicio)`**
`is` pergunta o tipo real. Depois dele, a promoção de tipo dá acesso a `aproveitamento`, que só
existe em `Exercicio`. Sem o `is`, `atividade.aproveitamento` não compila.

**`atividade is Videoaula && atividade.velocidade > 1`**
A promoção vale já no segundo operando do `&&`. É o mesmo mecanismo do `==` da Aula 3.

**`final RegistroDeTempo _tempo = RegistroDeTempo();`**
Composição. Note que `_tempo` é **privado**: a `Materia` expõe `minutosEstudados` e
`estudarPorSegundos`, e guarda para si **como** o tempo é contado. Amanhã você pode trocar o
`RegistroDeTempo` inteiro sem que nenhum usuário da `Materia` perceba. Com herança, essa troca
seria visível para todo mundo.

**`dart.estudarPorSegundos(-100)`**
A `Materia` nem valida: quem valida é o colaborador. Cada objeto cuida da sua regra.

**`flutter`: 4200 s = 70 min ≥ 60 → meta atingida**
Duas matérias, o mesmo código, comportamentos diferentes conforme os dados.

---

## ⚠️ Erros comuns

**1. Esquecer de chamar o construtor da superclasse**

```dart
class Leitura extends Atividade {
  Leitura(this.paginas); // ❌
  final int paginas;
}
```
```text
Error: The superclass 'Atividade' doesn't have a zero argument constructor.
```
✅ `Leitura({required super.nome, required super.minutos, required this.paginas});`

**2. Recursão infinita ao sobrescrever**

```dart
@override
int get pontos => pontos + 10; // ❌ chama a si mesmo
```
```text
Unhandled exception: Stack Overflow
```
✅ `super.pontos + 10`.

**3. Esquecer `@override`**

Compila, mas o lint `annotate_overrides` avisa. Pior: se você errar o nome do método, terá criado um
método novo que ninguém chama, sem nenhum aviso. ✅ Anote sempre.

**4. Mudar a assinatura ao sobrescrever**

```dart
@override
String descrever(int extra) => '...'; // ❌ o original não tem parâmetro
```
```text
Error: The override of 'Atividade.descrever' has fewer/different parameters.
```

**5. Herança por preguiça ("quero reaproveitar aquele método")**

```dart
class Materia extends RegistroDeTempo {} // ❌ "Matéria é um registro de tempo"?
```
Herdar só para pegar código carregado junto tudo o que você não quer, e amarra a classe a uma
hierarquia que não descreve a realidade. ✅ Componha: guarde um `RegistroDeTempo` como campo.

**6. Hierarquia profunda**

```dart
class A {} class B extends A {} class C extends B {} class D extends C {} // ❌
```
Depurar `D.metodo()` vira arqueologia. ✅ No máximo dois níveis; extraia colaboradores ou mixins.

**7. Sobrescrever `==` na subclasse sem cuidar do `runtimeType`**

Uma `Leitura` poderia ser considerada igual a uma `Atividade` com os mesmos campos. ✅ Inclua
`runtimeType == other.runtimeType`, como na [Aula 3](03-encapsulamento.md).

**8. Chamar método da subclasse a partir de um construtor da superclasse**

O construtor da superclasse roda **antes** de os campos da subclasse existirem. Se ele chamar um
método sobrescrito que usa esses campos, você lê valores não inicializados. ✅ Nunca chame métodos
sobrescrevíveis dentro de construtores.

---

## 🛠️ Exercício guiado

Vamos criar uma hierarquia rasa de **notificações de estudo**, e depois refatorá-la para composição.

**Passo 1.** Crie `bin/guiado_04_lembretes.dart` com a superclasse:

```dart
class Lembrete {
  final String mensagem;
  final int minutosAntes;

  const Lembrete({required this.mensagem, this.minutosAntes = 10});

  String get canal => 'genérico';

  String formatar() => '[$canal] $mensagem (em $minutosAntes min)';
}
```

**Passo 2.** Duas subclasses com `@override`:

```dart
class LembreteSonoro extends Lembrete {
  final String som;

  const LembreteSonoro({
    required super.mensagem,
    super.minutosAntes = 10,
    this.som = 'sino',
  });

  @override
  String get canal => 'som';

  @override
  String formatar() => '${super.formatar()} 🔔 $som';
}

class LembreteSilencioso extends Lembrete {
  const LembreteSilencioso({required super.mensagem, super.minutosAntes = 10});

  @override
  String get canal => 'silencioso';
}
```

Note que `LembreteSilencioso` **não** sobrescreve `formatar()`. Ela nem precisa: o `formatar()`
herdado já vai usar o `canal` dela, por despacho dinâmico.

**Passo 3.** Polimorfismo no `main`:

```dart
void main() {
  const lembretes = <Lembrete>[
    Lembrete(mensagem: 'Começar sessão de Dart'),
    LembreteSonoro(mensagem: 'Pausa do pomodoro', minutosAntes: 25, som: 'gongo'),
    LembreteSilencioso(mensagem: 'Revisar anotações', minutosAntes: 5),
  ];

  for (final lembrete in lembretes) {
    print(lembrete.formatar());
  }
}
```

**Passo 4.** Execute:

```powershell
dart run bin/guiado_04_lembretes.dart
```

**Saída esperada:**

```text
[genérico] Começar sessão de Dart (em 10 min)
[som] Pausa do pomodoro (em 25 min) 🔔 gongo
[silencioso] Revisar anotações (em 5 min)
```

**Passo 5 — a parte que ensina.** Agora suponha um requisito novo: **qualquer** lembrete pode
precisar gravar um log. Sua primeira ideia vai ser criar `LembreteComLog extends Lembrete` — e aí
você percebe que precisaria de `LembreteSonoroComLog`, `LembreteSilenciosoComLog`... explosão
combinatória.

Resolva por **composição**: acrescente um colaborador.

```dart
class Registrador {
  final List<String> _linhas = <String>[];
  void anotar(String linha) => _linhas.add(linha);
  int get total => _linhas.length;
  String get ultimo => _linhas.isEmpty ? '(vazio)' : _linhas.last;
}

class Agenda {
  final Registrador _log = Registrador();
  final List<Lembrete> _lembretes = <Lembrete>[];

  void agendar(Lembrete lembrete) {
    _lembretes.add(lembrete);
    _log.anotar('Agendado: ${lembrete.formatar()}');
  }

  int get total => _lembretes.length;
  String get ultimoLog => _log.ultimo;
}
```

E no `main`:

```dart
  final agenda = Agenda();
  for (final lembrete in lembretes) {
    agenda.agendar(lembrete);
  }
  print('Agendados: ${agenda.total}');
  print('Último log: ${agenda.ultimoLog}');
```

**Saída adicional esperada:**

```text
Agendados: 3
Último log: Agendado: [silencioso] Revisar anotações (em 5 min)
```

Uma classe nova resolveu o problema para **todos** os tipos de lembrete, presentes e futuros.
Guarde essa sensação: é a razão de "prefira composição".

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Pegue a hierarquia `Atividade` do código completo e responda com **código**, não com opinião:

1. Acrescente `Podcast extends Atividade`, com campo `episodio` e pontuação de 1 ponto a cada
   2 minutos. Quantas linhas do `main` você precisou alterar? (A resposta correta é **zero**.)
2. Agora acrescente a exigência "toda atividade precisa saber se exigiu internet". Resolva **sem**
   criar novas subclasses — use um campo na superclasse e valores padrão.
3. Por fim, acrescente "algumas atividades podem ser exportadas para CSV". Implemente isso como um
   colaborador `ExportadorCsv` que recebe uma `List<Atividade>` e devolve uma `String` — e escreva,
   em comentário, por que essa responsabilidade **não** deveria virar um método na superclasse.

---

## 📌 Resumo

- `extends` cria uma subclasse; Dart tem herança **simples** (uma superclasse só).
- Toda classe herda de `Object` implicitamente.
- `super` chama o construtor da superclasse, encaminha parâmetros (`super.nome`) e chama a versão
  anterior de um método sobrescrito.
- `@override` documenta e protege contra erro de digitação; o lint `annotate_overrides` cobra.
- **Polimorfismo**: uma lista do tipo base, cada objeto respondendo do seu jeito, decidido em tempo
  de execução (**despacho dinâmico**).
- Método da superclasse que chama um membro sobrescrito executa a versão **da subclasse**.
- `is` faz o teste de tipo e **promove** a variável dentro do bloco.
- Teste **"é-um" × "tem-um"**: "é-um" → herança; "tem-um" → composição.
- **Prefira composição**: menos acoplamento, sem limite de colaboradores, trocável em teste.
- Hierarquia **rasa**: no máximo 2 níveis.

---

## ☑️ Checklist de domínio

- [ ] Escrevo uma subclasse com `super.parametro` sem consultar a aula.
- [ ] Explico os três usos de `super`.
- [ ] Digo duas coisas que `@override` faz por mim.
- [ ] Explico por que `Effective Dart` imprimiu 64 pontos no exemplo mínimo.
- [ ] Uso `is` e sei que a variável é promovida dentro do bloco.
- [ ] Aplico o teste "é-um"/"tem-um" a um caso novo e defendo a escolha.
- [ ] Cito três motivos concretos para preferir composição.
- [ ] Sei dizer o que é o "problema do ioiô" em hierarquias profundas.
- [ ] Rodei `bin/04_heranca_e_polimorfismo.dart` e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Extend a class](https://dart.dev/language/extend)
- [Dart — Constructors: super parameters](https://dart.dev/language/constructors#super-parameters)
- [Dart — Type system e promoção de tipo](https://dart.dev/language/type-system)
- [Effective Dart — Design: herança](https://dart.dev/effective-dart/design#inheritance)
- [Regra de lint `annotate_overrides`](https://dart.dev/tools/linter-rules/annotate_overrides)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Encapsulamento](03-encapsulamento.md) | [README](README.md) | [Aula 5 — Classes abstratas e interfaces](05-abstratas-e-interfaces.md) |
