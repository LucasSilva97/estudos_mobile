# Aula 2 — Construtores

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Escrever um **construtor padrão** usando o açúcar sintático `this.x`.
- Criar **construtores nomeados** para dar nome a formas diferentes de construir o mesmo objeto.
- Usar a **initializer list** (lista de inicialização) e dizer por que ela roda **antes** do corpo.
- Declarar um **construtor `const`** e explicar o ganho real de memória e desempenho.
- Escrever um **construtor `factory`** e saber quando ele é necessário.
- **Redirecionar** um construtor para outro sem duplicar código.
- Validar pré-condições com `assert` — e saber que `assert` **some** no build de produção.

## ✅ Pré-requisitos

- [Aula 1 — Classes e objetos](01-classes-e-objetos.md).
- *Null safety* e parâmetros nomeados do
  [Módulo 02](../02-dart-basico/07-funcoes-em-dart.md).

---

## 📖 Conceito

### O que é um construtor

Um **construtor** é o método especial que roda **uma única vez**, no instante em que o objeto nasce.
Ele tem o mesmo nome da classe e **não declara tipo de retorno** (nem `void`).

Sua única responsabilidade é deixar o objeto em um **estado válido**. Um objeto que sai do
construtor pela metade é uma bomba-relógio no resto do programa.

### 1. Construtor padrão e o açúcar `this.x`

Na Aula 1 você escreveu isto:

```dart
class Materia {
  String nome = 'Sem nome';
  Materia(String nome) {
    this.nome = nome;
  }
}
```

Repetitivo. Dart tem um atalho chamado **initializing formal** (parâmetro que já inicializa o campo):

```dart
class Materia {
  final String nome;
  Materia(this.nome);
}
```

Escrever `this.nome` **na lista de parâmetros** significa: "receba um valor e grave-o direto no
campo `nome`, antes de qualquer outra coisa". Três vantagens imediatas:

1. Some a repetição.
2. O campo pode ser `final` (só recebe valor uma vez e nunca mais muda) — impossível na forma longa,
   porque um campo `final` não pode ser atribuído no corpo do construtor.
3. O campo não precisa mais de valor inicial.

Com parâmetros nomeados e valores padrão:

```dart
class Materia {
  final String nome;
  final int minutosEstudados;

  Materia(this.nome, {this.minutosEstudados = 0});
}

final m = Materia('Dart', minutosEstudados: 120);
```

Se um parâmetro nomeado **não** tiver valor padrão e o campo for não anulável, marque-o como
`required`:

```dart
Materia({required this.nome, this.minutosEstudados = 0});
```

### 2. Construtor nomeado

Dart **não tem sobrecarga de construtor** (você não pode declarar dois `Materia(...)` com
assinaturas diferentes, como em Java). Em troca, ele tem algo melhor: construtores com **nome**.

```dart
Materia.rapida(this.nome) : minutosEstudados = 0, metaSemanalEmMinutos = 30;
```

Uso: `Materia.rapida('Revisão')`. A vantagem sobre a sobrecarga é a **legibilidade**: o nome diz
o que está acontecendo. `Materia.doMapa(...)` é infinitamente mais claro que `Materia(mapa)`.

### 3. Initializer list

É a parte entre os **dois-pontos** e o corpo `{}`:

```dart
Materia.doMapa(Map<String, Object?> mapa)
    : nome = mapa['nome'] as String,
      minutosEstudados = 0;
```

Regras que você precisa memorizar:

- Roda **antes** do corpo `{}` do construtor.
- Roda **antes** do construtor da superclasse... na prática, é onde os campos `final` recebem valor.
- **Não existe `this` ainda** dentro dela. Você não pode chamar um método do objeto ali, porque
  o objeto ainda não está pronto. Só dá para usar os **parâmetros** e valores calculados a partir
  deles.
- Itens separados por **vírgula**, terminando em `;`.

É o único lugar onde um campo `final` pode ser inicializado quando o valor precisa de algum cálculo.

### 4. Construtor `const`

Um construtor `const` diz ao Dart: *"os valores deste objeto são conhecidos em tempo de compilação;
monte o objeto durante a compilação, não durante a execução"*.

Requisitos, todos obrigatórios:

- **Todos** os campos da classe são `final`.
- O construtor **não tem corpo** `{}` (só initializer list com atribuições e `assert`).
- Os valores passados também precisam ser constantes na hora de usar `const`.

O ganho real chama-se **canonicalização**: dois `const` idênticos viram **o mesmo objeto** na
memória.

```dart
const a = Nivel('Fácil', 1);
const b = Nivel('Fácil', 1);
print(identical(a, b)); // true — é literalmente o mesmo objeto
```

Declarar o construtor como `const` **não obriga** ninguém a usar `const`: `Nivel('Fácil', 1)` sem a
palavra continua criando um objeto novo. O `const` é uma opção que você abre para quem usa a classe.

> 🔮 Guarde bem este conceito. No Flutter, um widget `const` **não é reconstruído** quando a tela
> se redesenha. Isso é a otimização de desempenho mais barata que existe no framework, e você vai
> vê-la em [`13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md`](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md).

### 5. Construtor `factory`

Um construtor normal **sempre** cria um objeto novo daquela classe. Um construtor `factory`
("fábrica") é diferente: ele tem um **corpo obrigatório** e precisa **devolver** um objeto com
`return`. Esse objeto pode ser:

- um objeto novo,
- um objeto já existente (cache, *singleton*),
- um objeto de uma **subclasse**.

Use `factory` quando:

| Situação | Por quê |
|---|---|
| Precisa **decidir** qual objeto devolver | Construtor comum não pode escolher |
| Precisa **processar** a entrada antes de construir | Ex.: converter uma linha de texto |
| Quer **reaproveitar** instâncias | Cache / singleton |
| Precisa devolver `null`? | ❌ **Não pode.** Um `factory` não pode devolver `null`. Use um método estático. |

Dentro de um `factory` **não existe `this`** — o objeto ainda não foi criado.

### 6. Redirecionamento

Um construtor pode simplesmente **chamar outro** da mesma classe, sem corpo nenhum:

```dart
Materia.rapida(String nome) : this(nome, metaSemanalEmMinutos: 30);
```

`this(...)` aqui significa "chame o construtor padrão desta classe". Toda a validação do construtor
principal continua valendo, sem copiar e colar. Um construtor redirecionador **não pode** ter corpo
nem outras entradas na initializer list.

### 7. `assert` — contratos durante o desenvolvimento

`assert(condicao, 'mensagem')` interrompe o programa se `condicao` for falsa. Pode aparecer na
initializer list, antes das atribuições ou depois.

```dart
Materia(this.nome) : assert(nome.length >= 2, 'O nome precisa ter ao menos 2 letras.');
```

⚠️ **O ponto mais importante desta aula:** `assert` só roda em **modo de desenvolvimento**. Em um
build de produção (`flutter build apk --release`) todos os `assert` são **removidos** do binário.

Consequência prática: **nunca** use `assert` para validar dado que vem do usuário ou de um servidor.
Para isso, lance uma exceção de verdade (`ArgumentError`, `FormatException`), assunto do
[Módulo 04 — Exceptions](../04-dart-avancado/01-exceptions.md). `assert` serve para pegar **erro de
programador**: "eu jamais deveria ter chamado isso com uma lista vazia".

---

## 💡 Analogia

Pense numa **lanchonete**:

- O **construtor padrão** é o balcão: você diz os ingredientes e recebe um lanche montado.
- Os **construtores nomeados** são os combos do cardápio: "X-Salada", "Combo Infantil". Mesmo
  lanche, pedidos com nomes que já dizem o que vem dentro.
- A **initializer list** é a ordem de montagem do pão antes de embrulhar: tem que acontecer antes
  de entregar, e você ainda não pode dar uma mordida (ainda não há `this`).
- O construtor **`const`** é o lanche que já está pronto na estufa: se alguém pedir exatamente o
  mesmo, entrega-se aquele mesmo.
- O **`factory`** é o atendente que pode dizer "esse a gente não faz na hora, pega do estoque" ou
  "esse pedido na verdade é o combo, vou te entregar o combo".

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_construtores.dart`
> **Como executar:** `dart run bin/exemplo_construtores.dart`

```dart
class Meta {
  final String titulo;
  final int minutosPorSemana;

  // Construtor padrão com açúcar this.x + valor padrão + assert.
  const Meta(this.titulo, {this.minutosPorSemana = 300})
      : assert(minutosPorSemana > 0, 'A meta precisa ser maior que zero.');

  // Construtor nomeado que REDIRECIONA para o padrão.
  const Meta.leve(String titulo) : this(titulo, minutosPorSemana: 60);
}

void main() {
  const padrao = Meta('Estudar Dart');
  const leve = Meta.leve('Revisar anotações');

  print('${padrao.titulo}: ${padrao.minutosPorSemana} min/semana');
  print('${leve.titulo}: ${leve.minutosPorSemana} min/semana');
  print('Canonicalizado? ${identical(padrao, const Meta('Estudar Dart'))}');
}
```

Saída:

```text
Estudar Dart: 300 min/semana
Revisar anotações: 60 min/semana
Canonicalizado? true
```

---

## 📱 Aplicando no Flutter

Você vai escrever construtores **o dia inteiro** no Flutter. Todo widget que você criar começa assim:

```dart
class CartaoDeMateria extends StatelessWidget {
  const CartaoDeMateria({
    super.key,
    required this.nome,
    this.minutos = 0,
  });

  final String nome;
  final int minutos;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

Leia com o que você aprendeu hoje e veja que **não há novidade**:

- `const CartaoDeMateria({...})` → construtor `const`, porque todos os campos são `final`.
- `required this.nome` → açúcar `this.x` com parâmetro nomeado obrigatório.
- `this.minutos = 0` → açúcar `this.x` com valor padrão.
- `super.key` → o mesmo açúcar, mas encaminhando o parâmetro para o construtor da **superclasse**
  (você vê `super` na [Aula 4](04-heranca-e-polimorfismo.md)).

E o `const` na frente não é enfeite: escrever `const CartaoDeMateria(nome: 'Dart')` faz o Flutter
**pular a reconstrução** desse pedaço da tela. Os detalhes estão em
[`05-introducao-ao-flutter/04-statelesswidget.md`](../05-introducao-ao-flutter/04-statelesswidget.md)
e em [`13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md`](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md).

Já o `factory` aparece em quase todo modelo que vem de uma API, no formato
`factory Trilha.fromJson(Map<String, dynamic> json)` — você faz isso no
[Módulo 09 — JSON](../09-consumo-de-api/02-json.md).

---

## 💻 Código completo

> **Arquivo:** `bin/02_construtores.dart`
> **Como executar:** `dart run bin/02_construtores.dart`

```dart
// Aula 2 do Módulo 03 — Todos os tipos de construtor do Dart.

/// Matéria de estudo, agora com campos imutáveis (final) e vários construtores.
class Materia {
  final String nome;
  final int minutosEstudados;
  final int metaSemanalEmMinutos;

  /// 1) Construtor PADRÃO com açúcar `this.x`, parâmetros nomeados,
  ///    valores padrão e três `assert` de pré-condição.
  Materia(
    this.nome, {
    this.minutosEstudados = 0,
    this.metaSemanalEmMinutos = 60,
  })  : assert(nome.length >= 2, 'O nome precisa ter ao menos 2 letras.'),
        assert(minutosEstudados >= 0, 'minutosEstudados não pode ser negativo.'),
        assert(metaSemanalEmMinutos > 0, 'A meta precisa ser maior que zero.');

  /// 2) Construtor NOMEADO que REDIRECIONA para o padrão com `this(...)`.
  ///    Não tem corpo: reaproveita 100% da validação acima.
  Materia.rapida(String nome) : this(nome, metaSemanalEmMinutos: 30);

  /// 3) Construtor NOMEADO com INITIALIZER LIST própria.
  ///    Cada campo final recebe seu valor antes do objeto existir de fato.
  Materia.doMapa(Map<String, Object?> mapa)
      : nome = (mapa['nome'] as String?) ?? 'Sem nome',
        minutosEstudados = (mapa['minutos'] as int?) ?? 0,
        metaSemanalEmMinutos = (mapa['meta'] as int?) ?? 60;

  /// 4) Construtor FACTORY: processa a entrada ANTES de decidir o que devolver.
  ///    Um construtor comum não poderia fazer o `split` nem lançar antes de construir.
  factory Materia.doCsv(String linha) {
    final partes = linha.split(';');
    if (partes.length != 3) {
      throw FormatException('Esperava 3 campos separados por ";", recebi "$linha"');
    }
    return Materia(
      partes[0].trim(),
      minutosEstudados: int.tryParse(partes[1].trim()) ?? 0,
      metaSemanalEmMinutos: int.tryParse(partes[2].trim()) ?? 60,
    );
  }

  String resumo() => '$nome: $minutosEstudados/$metaSemanalEmMinutos min';
}

/// Classe 100% imutável: todos os campos são `final` e o construtor é `const`.
class NivelDeDificuldade {
  final String rotulo;
  final int peso;

  const NivelDeDificuldade(this.rotulo, this.peso)
      : assert(peso >= 1 && peso <= 3, 'O peso vai de 1 a 3.');

  // Constantes reaproveitáveis: montadas em tempo de compilação.
  static const facil = NivelDeDificuldade('Fácil', 1);
  static const media = NivelDeDificuldade('Média', 2);
  static const dificil = NivelDeDificuldade('Difícil', 3);
}

/// Uso clássico de `factory`: garantir UMA única instância (singleton).
class RegistroDeEstudo {
  // Construtor privado: o `_` no início do nome impede o uso fora deste arquivo.
  // (Privacidade é o assunto da Aula 3.)
  RegistroDeEstudo._interno();

  static final RegistroDeEstudo instancia = RegistroDeEstudo._interno();

  // O factory NÃO cria nada: devolve sempre a mesma instância.
  factory RegistroDeEstudo() => instancia;

  final List<String> _eventos = <String>[];

  void registrar(String evento) => _eventos.add(evento);

  int total() => _eventos.length;

  String ultimo() => _eventos.isEmpty ? '(nenhum)' : _eventos.last;
}

void main() {
  print('--- 1. Construtores ---');
  final dart = Materia('Dart', minutosEstudados: 120, metaSemanalEmMinutos: 300);
  final revisao = Materia.rapida('Revisão');
  final flutter = Materia.doMapa(<String, Object?>{
    'nome': 'Flutter',
    'minutos': 180,
    'meta': 600,
  });
  final logica = Materia.doCsv('Lógica; 45; 120');

  for (final materia in <Materia>[dart, revisao, flutter, logica]) {
    print(materia.resumo());
  }

  print('');
  print('--- 2. Construtor const e canonicalização ---');
  const copiaFacil = NivelDeDificuldade('Fácil', 1);
  final semConst = NivelDeDificuldade('Fácil', 1);
  print('const == const  ? ${identical(copiaFacil, NivelDeDificuldade.facil)}');
  print('const == sem const? ${identical(copiaFacil, semConst)}');
  print('Rótulo mais pesado: ${NivelDeDificuldade.dificil.rotulo}');

  print('');
  print('--- 3. Factory singleton ---');
  final registro1 = RegistroDeEstudo();
  final registro2 = RegistroDeEstudo();
  registro1.registrar('Iniciou sessão de Dart');
  registro2.registrar('Concluiu sessão de Dart');
  print('São o mesmo objeto? ${identical(registro1, registro2)}');
  print('Total de eventos:   ${registro1.total()}');
  print('Último evento:      ${registro2.ultimo()}');

  print('');
  print('--- 4. Validações ---');
  try {
    Materia.doCsv('linha bagunçada');
  } on FormatException catch (erro) {
    print('FormatException: ${erro.message}');
  }

  try {
    Materia('D'); // nome curto demais: o assert reprova
  } on AssertionError catch (erro) {
    print('AssertionError: ${erro.message}');
  }
}
```

**Saída esperada:**

```text
--- 1. Construtores ---
Dart: 120/300 min
Revisão: 0/30 min
Flutter: 180/600 min
Lógica: 45/120 min

--- 2. Construtor const e canonicalização ---
const == const  ? true
const == sem const? false
Rótulo mais pesado: Difícil

--- 3. Factory singleton ---
São o mesmo objeto? true
Total de eventos:   2
Último evento:      Concluiu sessão de Dart

--- 4. Validações ---
FormatException: Esperava 3 campos separados por ";", recebi "linha bagunçada"
AssertionError: O nome precisa ter ao menos 2 letras.
```

> ℹ️ Se você rodar este programa com `dart compile exe` e executar o binário, o bloco do
> `AssertionError` **não** vai disparar: os `assert` são removidos fora do modo de desenvolvimento.
> `dart run` mantém os `assert` ligados, por isso a saída acima.

---

## 🔍 Explicando o código

**`final String nome;` sem valor inicial**
Agora é permitido, porque **o construtor** garante o valor. Um campo `final` recebe valor **uma
única vez**: no parâmetro `this.nome` ou na initializer list. Depois disso, `dart.nome = 'outro'`
vira erro de compilação. Isso é imutabilidade, tema central da [Aula 3](03-encapsulamento.md).

**`Materia(this.nome, {this.minutosEstudados = 0, ...})`**
O primeiro parâmetro é **posicional** (obrigatório, identificado pela posição). Os entre chaves são
**nomeados** (opcionais, identificados pelo nome). Regra prática: se a classe tem 3 ou mais
parâmetros, prefira nomeados — `Materia('Dart', 120, 300)` não diz qual número é qual.

**`: assert(nome.length >= 2, '...')`**
Repare que a initializer list usa `nome`, e não `this.nome`. Dentro da initializer list você está
lendo o **parâmetro**; o objeto ainda não está pronto para ser lido via `this`.

**`Materia.rapida(String nome) : this(nome, metaSemanalEmMinutos: 30);`**
Redirecionamento. `this(...)` chama o construtor padrão. Note que `Materia.rapida` **não** declara
`this.nome`: quem grava o campo é o construtor de destino.

**`nome = (mapa['nome'] as String?) ?? 'Sem nome'`**
Três coisas numa linha só:
- `mapa['nome']` devolve `Object?` (pode não existir a chave).
- `as String?` é um **cast** (conversão de tipo declarada por você) que aceita nulo.
- `??` é o operador *if-null*: usa o valor da esquerda se ele não for nulo, senão o da direita.

**`factory Materia.doCsv(String linha)`**
Precisa ser `factory` porque há **trabalho antes** de construir: dividir a string, validar o
tamanho e possivelmente lançar exceção. Um construtor comum não conseguiria nem chamar `split`
antes de inicializar os campos `final`.

**`throw FormatException(...)`**
Aqui, sim, é uma exceção de verdade — e não um `assert` — porque a linha de CSV vem de **fora** do
programa (um arquivo, um usuário). Essa validação precisa existir também em produção. Exceções são
o assunto de [`04-dart-avancado/01-exceptions.md`](../04-dart-avancado/01-exceptions.md).

**`static const facil = NivelDeDificuldade('Fácil', 1);`**
`static` significa "pertence à **classe**, não a cada objeto". Existe uma única `facil` no programa
inteiro, acessível por `NivelDeDificuldade.facil`. Para conjuntos fechados como este, a
[Aula 7 — Enums](07-enums.md) mostra uma ferramenta ainda melhor.

**`RegistroDeEstudo._interno();`**
Construtor **nomeado e privado**. O `_` no início do nome torna o membro invisível fora do arquivo,
o que impede qualquer um de criar uma segunda instância por fora.

**`factory RegistroDeEstudo() => instancia;`**
O construtor "padrão" da classe virou uma fábrica que devolve sempre o mesmo objeto. Quem usa a
classe escreve `RegistroDeEstudo()` normalmente e nem percebe.

> ⚖️ *Singleton* resolve um problema real, mas cria outro: o objeto vira global e fica difícil de
> testar (você não consegue substituí-lo por um dublê). No Flutter deste curso, a forma preferida de
> compartilhar um objeto é **injeção de dependências com Riverpod**, em
> [`08-estado-e-arquitetura/10-injecao-de-dependencias.md`](../08-estado-e-arquitetura/10-injecao-de-dependencias.md).

**`on FormatException catch (erro)`**
`try`/`on`/`catch` captura o erro em vez de derrubar o programa. Você aprofunda isso no módulo 04.

---

## ⚠️ Erros comuns

**1. Atribuir a um campo `final` dentro do corpo do construtor**

```dart
class Materia {
  final String nome;
  Materia(String nome) {
    this.nome = nome; // ❌
  }
}
```
```text
Error: 'nome' can't be used as a setter because it's final.
```
✅ Use `Materia(this.nome);` ou a initializer list `Materia(String n) : nome = n;`.

**2. Usar `this` na initializer list**

```dart
Materia(this.nome) : minutosEstudados = this.calcular(); // ❌
```
```text
Error: Can't access 'this' in a field initializer to read 'calcular'.
```
✅ O objeto ainda não existe. Calcule a partir dos **parâmetros** ou mova para o corpo `{}`.

**3. Pôr corpo em construtor `const`**

```dart
const Nivel(this.rotulo) { print('criado'); } // ❌
```
```text
Error: A const constructor can't have a body.
```
✅ Construtor `const` só aceita initializer list e `assert`.

**4. Campo não-`final` em classe com construtor `const`**

```dart
class Nivel {
  String rotulo; // ❌ não é final
  const Nivel(this.rotulo);
}
```
```text
Error: Can't define a const constructor for a class with non-final fields.
```

**5. Esperar que `factory` devolva `null`**

```dart
factory Materia.talvez(String s) {
  if (s.isEmpty) return null; // ❌
  return Materia(s);
}
```
✅ Um `factory` não pode devolver `null`. Use um **método estático**:
`static Materia? talvez(String s) => s.isEmpty ? null : Materia(s);`

**6. Confiar em `assert` para validar entrada do usuário**

```dart
Materia(this.nome) : assert(nome.isNotEmpty); // ❌ some em release
```
✅ Para dados que vêm de fora, `if (nome.isEmpty) throw ArgumentError.value(nome, 'nome');`

**7. Esquecer `required` em parâmetro nomeado não anulável**

```dart
Materia({this.nome}); // ❌ com `final String nome`
```
```text
Error: The parameter 'nome' can't have a value of 'null' because of its type,
but the implicit default value is 'null'.
```
✅ `Materia({required this.nome});`

**8. Tentar sobrecarregar o construtor**

```dart
Materia(String nome);
Materia(String nome, int minutos); // ❌ dois construtores sem nome
```
```text
Error: 'Materia' is already declared in this scope.
```
✅ Dê nome ao segundo: `Materia.comMinutos(this.nome, this.minutos);`

---

## 🛠️ Exercício guiado

Vamos construir a classe `SessaoDeEstudo` com quatro formas de criação.

**Passo 1.** Crie `bin/guiado_02_sessao.dart` e declare a classe com campos `final`:

```dart
class SessaoDeEstudo {
  final String materia;
  final int minutos;
  final bool concluida;
```

**Passo 2.** Construtor padrão com `assert` e valores nomeados:

```dart
  const SessaoDeEstudo({
    required this.materia,
    required this.minutos,
    this.concluida = false,
  })  : assert(minutos > 0, 'Uma sessão precisa de pelo menos 1 minuto.'),
        assert(minutos <= 480, 'Sessão acima de 8 horas é erro de digitação.');
```

**Passo 3.** Construtor nomeado **redirecionador** para uma sessão "pomodoro" de 25 minutos:

```dart
  const SessaoDeEstudo.pomodoro(String materia)
      : this(materia: materia, minutos: 25);
```

**Passo 4.** Construtor nomeado com initializer list, a partir de segundos:

```dart
  SessaoDeEstudo.deSegundos(this.materia, int segundos)
      : minutos = segundos ~/ 60 < 1 ? 1 : segundos ~/ 60,
        concluida = true;
```

**Passo 5.** Um `factory` que interpreta um texto como `"Dart:90"`:

```dart
  factory SessaoDeEstudo.doTexto(String texto) {
    final partes = texto.split(':');
    if (partes.length != 2) {
      throw FormatException('Use o formato materia:minutos, recebi "$texto"');
    }
    final minutos = int.tryParse(partes[1].trim());
    if (minutos == null) {
      throw FormatException('"${partes[1]}" não é um número de minutos.');
    }
    return SessaoDeEstudo(materia: partes[0].trim(), minutos: minutos);
  }

  String resumo() =>
      '$materia — $minutos min${concluida ? ' ✅' : ''}';
}
```

**Passo 6.** No `main`, crie uma de cada e imprima:

```dart
void main() {
  final sessoes = <SessaoDeEstudo>[
    const SessaoDeEstudo(materia: 'Dart', minutos: 90),
    const SessaoDeEstudo.pomodoro('Flutter'),
    SessaoDeEstudo.deSegundos('Lógica', 2700),
    SessaoDeEstudo.doTexto('Git: 20'),
  ];

  for (final sessao in sessoes) {
    print(sessao.resumo());
  }
}
```

**Passo 7.** Execute:

```powershell
dart run bin/guiado_02_sessao.dart
```

**Saída esperada:**

```text
Dart — 90 min
Flutter — 25 min
Lógica — 45 min ✅
Git — 20 min
```

**Passo 8.** Experimente quebrar: troque `minutos: 90` por `minutos: 0` e veja o `AssertionError`.
Depois troque `'Git: 20'` por `'Git'` e veja o `FormatException` derrubar o programa — prova de que
exceção e `assert` servem a propósitos diferentes.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Crie a classe `Meta` com:

- campos `final`: `titulo`, `minutosPorSemana`, `criadaEm` (`DateTime`);
- construtor padrão `const`? — **descubra por que não dá** e escreva um comentário explicando
  (dica: `DateTime.now()` não é uma constante de compilação);
- construtor nomeado `Meta.dePadrao(String titulo)` que usa 300 min/semana;
- `factory Meta.doMapa(Map<String, Object?> mapa)` com validação de chave ausente;
- `factory Meta.clonandoCom(Meta original, {int? minutosPorSemana})` que devolve uma cópia
  com um campo trocado (isso é o embrião do `copyWith`, da [Aula 3](03-encapsulamento.md)).

---

## 📌 Resumo

- Construtor tem o nome da classe, **não** tem tipo de retorno e roda **uma vez**.
- `this.x` na lista de parâmetros grava direto no campo — permite campos `final`.
- Dart não tem sobrecarga; use **construtores nomeados**.
- A **initializer list** (depois dos `:`) roda antes do corpo e é onde campos `final` são calculados.
  Não existe `this` nela.
- `const` exige **todos os campos `final`** e **nenhum corpo**; ganha canonicalização.
- `factory` tem corpo, **precisa** dar `return`, pode devolver instância existente ou de subclasse,
  e **não pode** devolver `null`.
- `Construtor.x(...) : this(...)` **redireciona** e evita duplicar validação.
- `assert` é rede de proteção **de desenvolvimento** — desaparece em release. Para dado externo,
  lance exceção.

---

## ☑️ Checklist de domínio

- [x] Escrevo `Materia({required this.nome, this.minutos = 0})` sem consultar nada.
- [x] Explico por que um campo `final` não pode ser atribuído no corpo do construtor.
- [x] Sei citar duas regras da initializer list, inclusive a ausência de `this`.
- [x] Digo os dois requisitos obrigatórios de um construtor `const`.
- [x] Sei explicar canonicalização com o resultado de `identical`.
- [x] Sei citar duas situações em que `factory` é obrigatório.
- [x] Escrevo um construtor redirecionador com `this(...)`.
- [x] Explico por que `assert` não serve para validar entrada do usuário.
- [x] Rodei `bin/02_construtores.dart` e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Constructors](https://dart.dev/language/constructors)
- [Dart — Constructors: named, factory, redirecting](https://dart.dev/language/constructors#named-constructors)
- [Dart — Final e const](https://dart.dev/language/variables#final-and-const)
- [Dart — Error handling (`assert`)](https://dart.dev/language/error-handling#assert)
- [Effective Dart — Design: construtores](https://dart.dev/effective-dart/design#constructors)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Classes e objetos](01-classes-e-objetos.md) | [README](README.md) | [Aula 3 — Encapsulamento](03-encapsulamento.md) |
