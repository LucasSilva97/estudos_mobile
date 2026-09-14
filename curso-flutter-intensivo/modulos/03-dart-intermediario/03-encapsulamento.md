# Aula 3 — Encapsulamento

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Tornar um membro **privado** com `_` e explicar o que "privado" significa em Dart (não é o que
  você aprendeu em Java).
- Escrever **getters** e **setters** e diferenciá-los de métodos comuns.
- Criar **campos calculados** que não ocupam memória.
- Defender por que uma classe **imutável** gera menos bugs — e escrever uma.
- Implementar `copyWith` corretamente, inclusive conhecendo a sua armadilha com `null`.
- Sobrescrever `==` e `hashCode` juntos usando `Object.hash`, e dizer por que "juntos" é obrigatório.
- Sobrescrever `toString` para depurar com dignidade.

## ✅ Pré-requisitos

- [Aula 1 — Classes e objetos](01-classes-e-objetos.md) e [Aula 2 — Construtores](02-construtores.md).
- `Set` e `Map` do [Módulo 02](../02-dart-basico/09-sets-e-maps.md).

---

## 📖 Conceito

### O que é encapsulamento

**Encapsulamento** é separar o que a classe **promete** (a interface pública) do **como** ela cumpre
a promessa (o interior). Quem usa a sua classe deveria conseguir trabalhar sem saber como ela guarda
os dados por dentro — e, principalmente, **sem conseguir colocá-la num estado inválido**.

Na Aula 1, qualquer linha do programa podia fazer:

```dart
dart.minutosEstudados = -9999; // e ninguém impediu
```

Um objeto assim não tem dono. Ele é uma sacola de variáveis com um nome bonito.

### Privacidade em Dart: o caractere `_`

Dart não tem as palavras `private`, `protected` ou `public`. Tem uma convenção que o compilador
faz valer: **um nome começando com `_` é privado**.

```dart
class Cronometro {
  int _segundos = 0; // campo privado
  void _tick() {}    // método privado
}
```

⚠️ **Detalhe que quase todo mundo erra:** em Dart, privado é **privado à biblioteca**, e uma
biblioteca é, na prática, **um arquivo `.dart`**. Não é privado à classe.

Isso significa que:

- Outra classe **no mesmo arquivo** consegue ler `_segundos`. Isso é intencional e útil.
- Qualquer código em **outro arquivo** não consegue nem enxergar o membro — ele não aparece no
  autocompletar.

O limite, portanto, é o arquivo. A [Aula 10](10-arquivos-bibliotecas-pacotes.md) fecha esse assunto.

### Getters e setters

Um **getter** é um membro que se lê como um campo, mas é calculado por código:

```dart
int get segundos => _segundos;
```

Um **setter** é um membro que se escreve como um campo, mas passa por código:

```dart
set segundos(int valor) {
  if (valor < 0) {
    throw ArgumentError.value(valor, 'segundos', 'Não pode ser negativo.');
  }
  _segundos = valor;
}
```

Uso, do lado de fora:

```dart
cronometro.segundos = 120;    // chama o setter
print(cronometro.segundos);   // chama o getter
```

Repare: **sem parênteses**. Essa é a diferença visível entre getter e método.

Quando usar cada um?

| Use **getter** | Use **método** |
|---|---|
| A operação é barata (O(1)) e não tem efeito colateral | A operação faz trabalho pesado ou de I/O |
| Parece um "dado" do objeto: `area`, `estaVazio`, `duracao` | Parece uma "ação": `salvar()`, `recarregar()` |
| Chamar duas vezes seguidas dá o mesmo resultado | Chamar duas vezes muda alguma coisa |

### Campo calculado

Um getter que **deriva** seu valor de outros campos, sem guardar nada:

```dart
double get percentualDaMeta => minutosEstudados / metaSemanalEmMinutos * 100;
```

Não ocupa memória e **nunca fica desatualizado**. Compare com a alternativa ruim: guardar um campo
`double percentual` e ter que lembrar de recalculá-lo toda vez que `minutosEstudados` mudar. Esse
esquecimento é uma das fontes de bug mais comuns em qualquer sistema.

Regra: **se dá para calcular, calcule. Não guarde.**

### Imutabilidade

Um objeto **imutável** é aquele cujo estado nunca muda depois de criado. Em Dart: todos os campos
`final`, nenhum setter.

Para "alterar" um objeto imutável você **cria outro**:

```dart
final depois = antes.copyWith(minutosEstudados: 150);
```

Por que isso é melhor?

1. **Não existe alteração à distância.** Se você passou o objeto para cinco funções, nenhuma delas
   pode mudá-lo por baixo dos panos (lembre da Aula 1: variáveis guardam referências).
2. **Não existe estado inválido intermediário.** Não há aquele instante em que `nome` já mudou mas
   `minutos` ainda não.
3. **Pode ser `const`.** Ganho de memória e desempenho (Aula 2).
4. **Comparar por valor passa a fazer sentido**, e o objeto pode viver com segurança dentro de um
   `Set` ou como chave de um `Map`.
5. **É o que o Flutter espera.** Estado imutável + "novo estado substitui o anterior" é o modelo do
   Riverpod, que você usa no módulo 08.

O custo: você cria mais objetos. Para modelos de domínio (dezenas ou milhares de objetos pequenos),
isso é irrelevante no celular. Para listas de milhões de itens, aí sim se pensa duas vezes.

### `copyWith`

Método que devolve uma **cópia** do objeto com alguns campos trocados:

```dart
Materia copyWith({String? nome, int? minutosEstudados}) {
  return Materia(
    nome: nome ?? this.nome,
    minutosEstudados: minutosEstudados ?? this.minutosEstudados,
  );
}
```

Aqui `this.` é **obrigatório**: sem ele, `nome ?? nome` compararia o parâmetro consigo mesmo.

⚠️ **A armadilha do `copyWith`:** ele **não consegue** trocar um campo para `null`, porque
"não passei nada" e "passei `null`" chegam iguais dentro do método. Se a sua classe tem um campo
anulável que precisa ser limpo, resolva com um parâmetro extra explícito:

```dart
Materia copyWith({String? observacao, bool limparObservacao = false}) {
  return Materia(
    observacao: limparObservacao ? null : (observacao ?? this.observacao),
  );
}
```

### `==` e `hashCode` — sempre em par

Por padrão, `a == b` só é verdadeiro quando `a` e `b` são **o mesmo objeto** na memória. Para
comparar por **valor**, sobrescreva `==`:

```dart
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is Materia &&
        runtimeType == other.runtimeType &&
        nome == other.nome &&
        minutosEstudados == other.minutosEstudados;
```

E **sempre** sobrescreva `hashCode` junto:

```dart
@override
int get hashCode => Object.hash(nome, minutosEstudados);
```

**Por que junto?** `Set` e `Map` funcionam em duas etapas: primeiro comparam o `hashCode` para
achar a "gaveta" certa, depois usam `==` para conferir. Se dois objetos são `==` mas têm
`hashCode` diferentes, eles caem em gavetas diferentes e o `Set` guarda os dois — um bug que só
aparece muito depois, difícil de rastrear.

O contrato, em duas linhas:

- Se `a == b`, então **obrigatoriamente** `a.hashCode == b.hashCode`.
- O contrário não vale: dois objetos diferentes **podem** ter o mesmo `hashCode` (colisão), e isso
  não é um problema.

`Object.hash(a, b, c)` é a função oficial do Dart para combinar até 20 valores num hash de
qualidade. Para uma lista/coleção, use `Object.hashAll(lista)`.

**Regra de ouro:** use **exatamente os mesmos campos** no `==` e no `hashCode`.

### `toString`

Por padrão, imprimir um objeto mostra algo inútil: `Instance of 'Materia'`. Sobrescreva:

```dart
@override
String toString() => 'Materia(nome: $nome, minutos: $minutosEstudados)';
```

Convenção da comunidade: `NomeDaClasse(campo: valor, campo: valor)`. Isso aparece nos seus `print`,
nas mensagens de falha de teste e no DevTools — vale cada segundo investido.

---

## 💡 Analogia

Um **caixa eletrônico**.

- Você não abre o cofre nem mexe nas cédulas: o dinheiro é `_privado`.
- Você aperta "saldo" e a máquina te **mostra** um número: isso é um **getter**.
- Você pede um saque e a máquina **verifica** se há saldo antes de liberar: isso é um **setter**
  com validação. Ele pode recusar.
- O "saldo em dólares" é calculado na hora com a cotação: **campo calculado**.
- E dois extratos com exatamente os mesmos lançamentos são considerados **o mesmo extrato**, mesmo
  sendo dois papéis diferentes: isso é `==` sobrescrito.

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_encapsulamento.dart`
> **Como executar:** `dart run bin/exemplo_encapsulamento.dart`

```dart
class Cofre {
  int _moedas = 0;

  int get moedas => _moedas;              // getter
  bool get vazio => _moedas == 0;         // campo calculado

  set moedas(int valor) {                 // setter com validação
    if (valor < 0) {
      throw ArgumentError.value(valor, 'moedas', 'Não pode ser negativo.');
    }
    _moedas = valor;
  }
}

void main() {
  final cofre = Cofre();
  print('Vazio? ${cofre.vazio}');

  cofre.moedas = 7;
  print('Agora tem ${cofre.moedas} moedas. Vazio? ${cofre.vazio}');

  try {
    cofre.moedas = -1;
  } on ArgumentError catch (erro) {
    print('Recusado: ${erro.message}');
  }
  print('Continua com ${cofre.moedas} moedas.');
}
```

Saída:

```text
Vazio? true
Agora tem 7 moedas. Vazio? false
Recusado: Não pode ser negativo.
Continua com 7 moedas.
```

---

## 📱 Aplicando no Flutter

Esta aula é, de longe, a que mais economiza sofrimento no módulo 08. O motivo:

> **No Riverpod, o estado do app é um objeto imutável. Você nunca altera o estado — você o
> substitui por um novo, feito com `copyWith`.**

Assim (não rode isto agora, é só para você reconhecer depois):

```dart
class MateriasNotifier extends Notifier<Materia> {
  @override
  Materia build() => const Materia(nome: 'Dart', metaSemanalEmMinutos: 300);

  void registrarEstudo(int minutos) {
    // ❌ state.minutosEstudados += minutos;  — a tela nem perceberia a mudança
    // ✅ novo objeto: o Riverpod compara o antigo com o novo e redesenha a tela
    state = state.copyWith(
      minutosEstudados: state.minutosEstudados + minutos,
    );
  }
}
```

E é aqui que `==` e `hashCode` deixam de ser teoria: o Riverpod (e o próprio Flutter) decidem
**se vale a pena redesenhar a tela** comparando o estado antigo com o novo usando `==`. Se você
esquecer de sobrescrever `==`, todo objeto novo será "diferente" e a tela redesenha à toa. Se você
sobrescrever errado (campos de menos), a tela **não redesenha** quando deveria — e você vai passar
uma hora achando que o botão está quebrado.

Detalhes completos em
[`08-estado-e-arquitetura/06-notifier-e-notifierprovider.md`](../08-estado-e-arquitetura/06-notifier-e-notifierprovider.md).

---

## 💻 Código completo

> **Arquivo:** `bin/03_encapsulamento.dart`
> **Como executar:** `dart run bin/03_encapsulamento.dart`

```dart
// Aula 3 do Módulo 03 — Encapsulamento, imutabilidade, copyWith, ==/hashCode.

/// Modelo IMUTÁVEL de matéria.
/// Todos os campos são `final` e não há setter: depois de criada, não muda.
class Materia {
  final String nome;
  final int minutosEstudados;
  final int metaSemanalEmMinutos;

  const Materia({
    required this.nome,
    this.minutosEstudados = 0,
    this.metaSemanalEmMinutos = 300,
  })  : assert(minutosEstudados >= 0, 'Minutos não podem ser negativos.'),
        assert(metaSemanalEmMinutos > 0, 'A meta precisa ser maior que zero.');

  // ----- CAMPOS CALCULADOS (getters) -----
  // Não ocupam memória e nunca ficam desatualizados.

  double get percentualDaMeta => minutosEstudados / metaSemanalEmMinutos * 100;

  bool get metaAtingida => minutosEstudados >= metaSemanalEmMinutos;

  int get minutosRestantes {
    final falta = metaSemanalEmMinutos - minutosEstudados;
    return falta > 0 ? falta : 0;
  }

  String get horasFormatadas {
    final horas = minutosEstudados ~/ 60;
    final minutos = minutosEstudados % 60;
    return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
  }

  // ----- "ALTERAÇÃO" SEM MUTAÇÃO -----

  /// Devolve uma CÓPIA com os campos informados trocados.
  Materia copyWith({
    String? nome,
    int? minutosEstudados,
    int? metaSemanalEmMinutos,
  }) {
    return Materia(
      nome: nome ?? this.nome,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaSemanalEmMinutos: metaSemanalEmMinutos ?? this.metaSemanalEmMinutos,
    );
  }

  /// Devolve uma NOVA matéria com os minutos somados. O objeto atual não muda.
  Materia registrarEstudo(int minutos) {
    if (minutos <= 0) {
      return this; // nada a fazer: devolve o próprio objeto
    }
    return copyWith(minutosEstudados: minutosEstudados + minutos);
  }

  // ----- IGUALDADE POR VALOR -----

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Materia &&
          runtimeType == other.runtimeType &&
          nome == other.nome &&
          minutosEstudados == other.minutosEstudados &&
          metaSemanalEmMinutos == other.metaSemanalEmMinutos;

  // Os MESMOS três campos usados no ==. Sempre.
  @override
  int get hashCode => Object.hash(nome, minutosEstudados, metaSemanalEmMinutos);

  @override
  String toString() => 'Materia(nome: $nome, minutos: $minutosEstudados, '
      'meta: $metaSemanalEmMinutos)';
}

/// Classe MUTÁVEL, com estado interno protegido por getters e setters.
/// Um cronômetro precisa mudar — e por isso mesmo precisa de encapsulamento.
class Cronometro {
  int _segundos = 0;
  bool _rodando = false;

  // Getters: leitura livre.
  int get segundos => _segundos;
  bool get rodando => _rodando;

  /// Campo calculado: HH:MM:SS.
  String get formatado {
    final horas = _segundos ~/ 3600;
    final minutos = (_segundos % 3600) ~/ 60;
    final segundosRestantes = _segundos % 60;
    return '${_doisDigitos(horas)}:${_doisDigitos(minutos)}:'
        '${_doisDigitos(segundosRestantes)}';
  }

  /// Setter: escrita controlada.
  set segundos(int valor) {
    if (valor < 0) {
      throw ArgumentError.value(valor, 'segundos', 'Não pode ser negativo.');
    }
    _segundos = valor;
  }

  // Método PRIVADO: detalhe interno, invisível fora deste arquivo.
  String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

  void iniciar() => _rodando = true;

  void parar() => _rodando = false;

  /// Só avança se estiver rodando: a regra mora DENTRO do objeto.
  void avancar(int segundos) {
    if (_rodando && segundos > 0) {
      _segundos += segundos;
    }
  }

  void zerar() {
    _segundos = 0;
    _rodando = false;
  }

  @override
  String toString() => 'Cronometro($formatado, rodando: $_rodando)';
}

void main() {
  print('--- 1. Imutabilidade e copyWith ---');
  const dart = Materia(nome: 'Dart', metaSemanalEmMinutos: 300);
  final dartDepois = dart.registrarEstudo(120).registrarEstudo(30);

  print('Original: $dart');
  print('Cópia:    $dartDepois');
  print('Percentual da meta: ${dartDepois.percentualDaMeta.toStringAsFixed(1)}%');
  print('Horas formatadas:   ${dartDepois.horasFormatadas}');
  print('Faltam:             ${dartDepois.minutosRestantes} min');
  print('Meta atingida?      ${dartDepois.metaAtingida}');

  print('');
  print('--- 2. Igualdade por valor ---');
  const copia = Materia(
    nome: 'Dart',
    minutosEstudados: 150,
    metaSemanalEmMinutos: 300,
  );
  print('dartDepois == copia?    ${dartDepois == copia}');
  print('identical?              ${identical(dartDepois, copia)}');
  print('hashCodes iguais?       ${dartDepois.hashCode == copia.hashCode}');

  final conjunto = <Materia>{dartDepois, copia, dart};
  print('Itens em um Set de 3:   ${conjunto.length}');

  final porMateria = <Materia, String>{dartDepois: 'em dia'};
  print('Busca no Map por valor: ${porMateria[copia]}');

  print('');
  print('--- 3. Encapsulamento com getters e setters ---');
  final cronometro = Cronometro();
  cronometro.avancar(50); // ignorado: não está rodando
  print('Parado, após avancar(50): ${cronometro.formatado}');

  cronometro.iniciar();
  cronometro.avancar(65);
  cronometro.avancar(3600);
  print('Rodando:                  $cronometro');

  cronometro.parar();
  cronometro.avancar(1000); // ignorado de novo
  print('Depois de parar:          ${cronometro.segundos} s');

  try {
    cronometro.segundos = -5;
  } on ArgumentError catch (erro) {
    print('Setter recusou:           ${erro.message}');
  }
  print('Estado preservado:        ${cronometro.formatado}');
}
```

**Saída esperada:**

```text
--- 1. Imutabilidade e copyWith ---
Original: Materia(nome: Dart, minutos: 0, meta: 300)
Cópia:    Materia(nome: Dart, minutos: 150, meta: 300)
Percentual da meta: 50.0%
Horas formatadas:   2h 30min
Faltam:             150 min
Meta atingida?      false

--- 2. Igualdade por valor ---
dartDepois == copia?    true
identical?              false
hashCodes iguais?       true
Itens em um Set de 3:   2
Busca no Map por valor: em dia

--- 3. Encapsulamento com getters e setters ---
Parado, após avancar(50): 00:00:00
Rodando:                  Cronometro(01:01:05, rodando: true)
Depois de parar:          3665 s
Setter recusou:           Não pode ser negativo.
Estado preservado:        01:01:05
```

---

## 🔍 Explicando o código

**`const Materia({required this.nome, ...})`**
Classe imutável = construtor `const` possível. Herança direta da [Aula 2](02-construtores.md).

**`double get percentualDaMeta => ...`**
Getter em forma de flecha (`=>` é açúcar para `{ return ...; }` quando o corpo é uma única
expressão). Sem `()` na declaração e sem `()` no uso.

**`int get minutosRestantes { ... }`**
Getter com corpo de bloco, quando precisa de mais de uma linha. Continua sendo lido sem parênteses.

**`minutos.toString().padLeft(2, '0')`**
`padLeft(2, '0')` completa a string à esquerda até ter 2 caracteres. `5` vira `'05'`.

**`return this;` dentro de `registrarEstudo`**
Quando não há nada para mudar, devolver o próprio objeto é correto e economiza uma alocação — afinal
o objeto é imutável, então compartilhá-lo é seguro. Esse truque só funciona **porque** a classe é
imutável.

**`nome ?? this.nome` dentro de `copyWith`**
Se quem chamou não informou `nome`, o parâmetro chega `null` e o `??` mantém o valor atual.
O `this.` aqui **não é opcional**.

**`identical(this, other) || other is Materia && ...`**
- `identical(this, other)` é um atalho: se for o mesmo objeto, já é igual, pule o resto.
- `other is Materia` é o **type test**. Depois dele, o Dart faz *promotion* (promoção de tipo):
  dentro do `&&`, `other` já é tratado como `Materia`, e por isso `other.nome` compila sem cast.
- `runtimeType == other.runtimeType` impede que uma subclasse seja considerada igual à classe-mãe.

**`operator ==(Object other)`**
O parâmetro **tem que ser `Object`**, não `Materia`. É a assinatura herdada de `Object`; mudar isso
não compila.

**`Object.hash(nome, minutosEstudados, metaSemanalEmMinutos)`**
Combina os valores num único `int` de boa distribuição. Use **exatamente** os campos do `==`.
Para muitos campos ou uma coleção, existe `Object.hashAll(...)`.

**`final conjunto = <Materia>{dartDepois, copia, dart};` → 2 itens**
`dartDepois` e `copia` têm os mesmos valores, então o `Set` os considera o mesmo elemento e guarda
só um. `dart` (0 minutos) é diferente, então entra. Se você apagar o `hashCode` e deixar só o `==`,
este número vira **3** — teste e veja.

**`porMateria[copia]` → `'em dia'`**
A chave do `Map` foi `dartDepois`, mas a busca com `copia` funciona: o `Map` usa `hashCode` + `==`.
Isso só é possível com objetos **imutáveis**; guardar objeto mutável em `Set`/`Map` é receita de bug.

**`String _doisDigitos(int valor)`**
Método privado. Ele existe só para o `formatado` funcionar; ninguém fora do arquivo precisa saber
que ele existe. Isso é encapsulamento em estado puro: a **interface** da classe fica pequena.

**`cronometro.avancar(50)` antes de `iniciar()`**
Nada acontece, e a regra está **dentro** do objeto. Se a verificação `if (_rodando)` estivesse em
quem chama, você teria que repeti-la em todos os lugares — e esquecer em um deles.

---

## ⚠️ Erros comuns

**1. Sobrescrever `==` e esquecer `hashCode`**

```dart
@override
bool operator ==(Object other) => other is Materia && other.nome == nome;
// ❌ sem hashCode
```
O analisador avisa com `hash_and_equals`, e o `Set` passa a guardar duplicados. ✅ Sempre os dois.

**2. Usar campos diferentes em `==` e `hashCode`**

```dart
bool operator ==(Object other) => ... nome e minutos ...;
int get hashCode => Object.hash(nome); // ❌ faltou minutos
```
Dois objetos `==` com hash igual: aqui até funciona por sorte, mas o contrário (hash usando **mais**
campos que o `==`) quebra o `Set` silenciosamente. ✅ Mesmos campos, sempre.

**3. Assinatura errada do `==`**

```dart
bool operator ==(Materia other) => ...; // ❌
```
```text
Error: The parameter type for overriding method is 'Object'.
```

**4. Guardar objeto mutável em `Set`/`Map` e depois alterá-lo**

```dart
final s = {minhaMateria};
minhaMateria.minutos = 999;  // muda o hashCode
print(s.contains(minhaMateria)); // false! o objeto "sumiu" do próprio Set
```
✅ Use objetos imutáveis como elementos de `Set` e chaves de `Map`.

**5. Esquecer `this.` no `copyWith`**

```dart
Materia copyWith({String? nome}) => Materia(nome: nome ?? nome); // ❌
```
`nome ?? nome` é sempre `null` quando o parâmetro é `null`. ✅ `nome ?? this.nome`.

**6. Achar que `_` esconde de outras classes do mesmo arquivo**

```dart
class A { int _x = 1; }
class B { void ler(A a) => print(a._x); } // ✅ compila, mesmo arquivo
```
Não é um bug: em Dart privado é por **arquivo**. Se você quer isolamento real, ponha as classes em
arquivos diferentes.

**7. Getter com efeito colateral**

```dart
int get proximoId => _id++; // ❌ ler duas vezes dá resultados diferentes
```
✅ Isso é uma ação: `int gerarProximoId()`.

**8. Getter caro**

```dart
List<Materia> get todas => _carregarDoBanco(); // ❌ parece barato, não é
```
✅ `Future<List<Materia>> carregarTodas()` — um método assíncrono, deixando o custo visível.

---

## 🛠️ Exercício guiado

Vamos transformar a `SessaoDeEstudo` da aula anterior em um modelo imutável completo.

**Passo 1.** Crie `bin/guiado_03_sessao.dart` com a classe e os campos `final`:

```dart
class SessaoDeEstudo {
  final String materia;
  final int minutos;
  final DateTime inicio;

  const SessaoDeEstudo({
    required this.materia,
    required this.minutos,
    required this.inicio,
  }) : assert(minutos > 0, 'A sessão precisa de pelo menos 1 minuto.');
```

**Passo 2.** Adicione dois campos calculados:

```dart
  DateTime get fim => inicio.add(Duration(minutes: minutos));

  bool get foiLonga => minutos >= 60;
```

**Passo 3.** Um getter privado auxiliar + um público que o usa:

```dart
  String _doisDigitos(int v) => v.toString().padLeft(2, '0');

  String get faixaHoraria =>
      '${_doisDigitos(inicio.hour)}:${_doisDigitos(inicio.minute)} → '
      '${_doisDigitos(fim.hour)}:${_doisDigitos(fim.minute)}';
```

**Passo 4.** `copyWith`, `==`, `hashCode` e `toString`:

```dart
  SessaoDeEstudo copyWith({String? materia, int? minutos, DateTime? inicio}) {
    return SessaoDeEstudo(
      materia: materia ?? this.materia,
      minutos: minutos ?? this.minutos,
      inicio: inicio ?? this.inicio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessaoDeEstudo &&
          runtimeType == other.runtimeType &&
          materia == other.materia &&
          minutos == other.minutos &&
          inicio == other.inicio;

  @override
  int get hashCode => Object.hash(materia, minutos, inicio);

  @override
  String toString() =>
      'SessaoDeEstudo(materia: $materia, minutos: $minutos, inicio: $inicio)';
}
```

**Passo 5.** No `main`, use uma data **fixa** (não `DateTime.now()`) para a saída ser reproduzível:

```dart
void main() {
  final inicio = DateTime(2026, 9, 14, 19, 30);
  final sessao = SessaoDeEstudo(materia: 'Dart', minutos: 90, inicio: inicio);
  final estendida = sessao.copyWith(minutos: 120);
  final gemea = SessaoDeEstudo(materia: 'Dart', minutos: 90, inicio: inicio);

  print(sessao.faixaHoraria);
  print(estendida.faixaHoraria);
  print('Longa? ${sessao.foiLonga}');
  print('Iguais? ${sessao == estendida}');
  print('Cópia idêntica? ${sessao == gemea}');
  print(estendida);
}
```

**Passo 6.** Execute:

```powershell
dart run bin/guiado_03_sessao.dart
```

**Saída esperada:**

```text
19:30 → 21:00
19:30 → 21:30
Longa? true
Iguais? false
Cópia idêntica? true
SessaoDeEstudo(materia: Dart, minutos: 120, inicio: 2026-09-14 19:30:00.000)
```

**Passo 7.** Apague o `hashCode` e rode `dart analyze`. Leia o aviso `hash_and_equals`.
Depois recoloque.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Implemente a classe imutável `Meta` com um campo **anulável** `String? observacao` e faça o
`copyWith` conseguir **limpar** esse campo. Duas soluções válidas:

1. Parâmetro extra `bool limparObservacao = false`.
2. Um valor "sentinela": `copyWith({Object? observacao = _naoInformado})` com
   `static const Object _naoInformado = Object();` e comparação por `identical`.

Escreva as duas, rode as duas e anote no arquivo, em comentário, qual você acha mais legível **para
quem vai ler o código daqui a seis meses** — e por quê. Essa é a pergunta que separa código que
sobrevive de código que apodrece.

---

## 📌 Resumo

- `_` no início do nome = **privado à biblioteca (ao arquivo)**, não à classe.
- **Getter** lê-se sem parênteses; **setter** escreve-se com `=` e pode validar.
- **Campo calculado** é um getter derivado: não guarda nada, nunca desatualiza.
- **Imutável** = todos os campos `final`, nenhum setter, "mudanças" viram cópias.
- `copyWith` usa `parametro ?? this.campo` e **não consegue** colocar `null` sem ajuda extra.
- `==` e `hashCode` andam **sempre juntos** e usam **os mesmos campos**; combine com `Object.hash`.
- `operator ==(Object other)` — o parâmetro é `Object`, não a sua classe.
- `toString` no formato `Classe(campo: valor)` economiza horas de depuração.

---

## ☑️ Checklist de domínio

- [ ] Explico por que `_` em Dart é privacidade de **arquivo**.
- [ ] Sei decidir entre getter e método usando a tabela desta aula.
- [ ] Escrevo um campo calculado e digo por que ele é melhor que um campo guardado.
- [ ] Listo três vantagens concretas da imutabilidade.
- [ ] Escrevo `copyWith` completo de memória, com `this.` no lugar certo.
- [ ] Explico a armadilha do `copyWith` com campos anuláveis.
- [ ] Escrevo `==` + `hashCode` com `Object.hash` e explico o contrato entre eles.
- [ ] Sei prever o tamanho do `Set` no exemplo desta aula, e o que muda sem `hashCode`.
- [ ] Rodei `bin/03_encapsulamento.dart` e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Classes: getters e setters](https://dart.dev/language/methods#getters-and-setters)
- [Dart — Libraries e privacidade `_`](https://dart.dev/language/libraries)
- [API — `Object.hash`](https://api.dart.dev/stable/dart-core/Object/hash.html)
- [API — `Object.hashAll`](https://api.dart.dev/stable/dart-core/Object/hashAll.html)
- [Effective Dart — Design: equality](https://dart.dev/effective-dart/design#equality)
- [Regra de lint `hash_and_equals`](https://dart.dev/tools/linter-rules/hash_and_equals)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Construtores](02-construtores.md) | [README](README.md) | [Aula 4 — Herança e polimorfismo](04-heranca-e-polimorfismo.md) |
