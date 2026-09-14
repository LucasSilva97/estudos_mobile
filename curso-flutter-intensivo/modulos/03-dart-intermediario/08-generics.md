# Aula 8 — Generics

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar **por que** generics existem, com um exemplo de bug que eles impedem.
- Ler e escrever `<T>`: classe genérica, método genérico e função genérica.
- Usar um **limite** (`<T extends Algo>`) e dizer o que ele libera dentro da classe.
- Entender o que `List<String>` e `Map<String, int>` realmente significam.
- Escrever um `Repositorio<T extends Entidade>` reaproveitável para todo o app.
- Reconhecer a armadilha da **covariância** de listas em Dart.

## ✅ Pré-requisitos

- [Aula 5 — Classes abstratas e interfaces](05-abstratas-e-interfaces.md).
- `List`, `Map` e `Set` do [Módulo 02](../02-dart-basico/09-sets-e-maps.md).

---

## 📖 Conceito

### O problema: repetir a mesma classe para cada tipo

Na Aula 5 você escreveu `MateriaRepositorio`. Agora o app precisa guardar sessões. E metas.
E trilhas. Copiar a classe quatro vezes, trocando só o tipo?

```dart
class MateriaRepositorio { Map<String, Materia> _itens = {}; /* ... */ }
class SessaoRepositorio  { Map<String, Sessao>  _itens = {}; /* ... */ }
class MetaRepositorio    { Map<String, Meta>    _itens = {}; /* ... */ }
```

Quatro cópias do mesmo algoritmo. Corrigir um bug significa corrigir quatro vezes — e esquecer de
uma.

A tentação seguinte é usar `Object`:

```dart
class Repositorio {
  final Map<String, Object> _itens = {};
  Object? buscar(String id) => _itens[id];
}

final materia = repositorio.buscar('m1') as Materia; // ❌ cast em todo lugar
```

Isso "funciona" e é pior: você perdeu a verificação do compilador. Nada impede guardar uma `Sessao`
no repositório de matérias e só descobrir quando o app quebrar na mão do usuário:

```text
Unhandled exception: type 'Sessao' is not a subtype of type 'Materia' in type cast
```

### A solução: tipo como parâmetro

**Generics** (tipos genéricos, ou *parametrização de tipo*) permitem que o **tipo** seja um
parâmetro, igual a um valor comum:

```dart
class Repositorio<T> {
  final Map<String, T> _itens = <String, T>{};

  void salvar(String id, T item) => _itens[id] = item;
  T? buscar(String id) => _itens[id];
}
```

`T` é um **parâmetro de tipo**. Quem usa a classe decide o valor dele:

```dart
final materias = Repositorio<Materia>();
final sessoes = Repositorio<Sessao>();

materias.salvar('m1', Materia(...));   // ✅
materias.salvar('s1', Sessao(...));    // ❌ ERRO DE COMPILAÇÃO
```

Três ganhos, todos concretos:

1. **Erro na compilação, não na mão do usuário.**
2. **Zero casts.** `materias.buscar('m1')` já devolve `Materia?`.
3. **Uma implementação só** para infinitos tipos.

Por convenção, os parâmetros de tipo se chamam `T` (*type*), `E` (*element*), `K` e `V` (*key* e
*value*), `R` (*result*). Nomes maiores também valem quando ajudam a ler.

### Generics em `List`, `Map` e `Set`

Você já usa generics desde o módulo 02, sem saber o nome:

```dart
List<String> nomes = <String>['Dart', 'Flutter'];
Map<String, int> minutos = <String, int>{'Dart': 150};
Set<Materia> favoritas = <Materia>{};
```

`List<String>` significa literalmente "a classe `List`, com `E` valendo `String`". É por isso que
`nomes.first` já é uma `String` e `nomes.add(42)` não compila.

E é por isso que `var lista = [];` é perigoso: sem contexto, o Dart infere `List<dynamic>`, e
`dynamic` desliga toda a verificação de tipo. **Sempre** deixe o tipo claro: `<String>[]`.

### Método e função genéricos

Não é preciso uma classe inteira. Uma função sozinha pode ter parâmetro de tipo:

```dart
T? primeiroOuNulo<T>(List<T> itens, bool Function(T item) teste) {
  for (final item in itens) {
    if (teste(item)) {
      return item;
    }
  }
  return null;
}
```

Uso:

```dart
final nome = primeiroOuNulo<String>(nomes, (n) => n.startsWith('F'));
final idade = primeiroOuNulo(idades, (i) => i > 18); // T inferido: int
```

Na segunda linha, o Dart **inferiu** que `T` é `int` olhando o argumento. Escrever `<int>` é opcional
quando a inferência acerta — e ela quase sempre acerta.

Uma função genérica sem `<T>` teria que devolver `Object?`, e quem chamasse precisaria de cast.
Com `<T>`, o tipo de entrada **acompanha** o tipo de saída.

### Limites com `extends`

Por padrão, dentro de `class Repositorio<T>`, o Dart não sabe **nada** sobre `T` — só que é um
objeto. Você não pode chamar `item.id`, porque nem todo tipo tem `id`.

O **limite** (*bound*) resolve:

```dart
abstract class Entidade {
  String get id;
}

class Repositorio<T extends Entidade> {
  final Map<String, T> _itens = <String, T>{};

  void salvar(T item) => _itens[item.id] = item; // ✅ item.id existe: T é Entidade
}
```

`<T extends Entidade>` faz duas coisas ao mesmo tempo:

1. **Restringe**: `Repositorio<int>` não compila mais.
2. **Libera**: dentro da classe, `T` tem garantidamente todos os membros de `Entidade`.

Sem limite, `T` equivale a `T extends Object?` — ou seja, pode até ser nulo.

### `Repositorio<T>` — o padrão que você vai reusar o curso inteiro

Juntando tudo, esta é a peça que substitui quatro classes copiadas:

```dart
class Repositorio<T extends Entidade> {
  final Map<String, T> _itens = <String, T>{};

  void salvar(T item) => _itens[item.id] = item;
  T? buscar(String id) => _itens[id];
  List<T> listar() => _itens.values.toList();
  List<T> onde(bool Function(T item) teste) => listar().where(teste).toList();
  bool remover(String id) => _itens.remove(id) != null;
  int get total => _itens.length;
}
```

Repare no `onde`: ele recebe uma **função** que trabalha com `T`, e devolve uma `List<T>`. O tipo
atravessa a assinatura inteira sem nenhum cast.

---

## 💡 Analogia

Uma **caixa de transporte com etiqueta**.

- Uma caixa sem etiqueta (`Object`) aceita qualquer coisa. Na chegada, alguém precisa abrir e
  adivinhar o que é — e às vezes adivinha errado.
- Uma caixa com etiqueta "FRÁGIL — TAÇAS" (`Caixa<Taca>`) é conferida **na hora de fechar**: se
  alguém tentar pôr um tijolo, o conferente barra ali mesmo.
- O molde da caixa é o mesmo; muda só a etiqueta. Isso é a classe genérica: **uma** implementação,
  **muitas** etiquetas.
- E `<T extends Fragil>` é a regra da transportadora: "esta prateleira só aceita caixas de itens
  frágeis" — o que também garante que todas elas têm o selo de frágil para o operador consultar.

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_generics.dart`
> **Como executar:** `dart run bin/exemplo_generics.dart`

```dart
class Caixa<T> {
  final T conteudo;

  const Caixa(this.conteudo);

  T abrir() => conteudo;

  /// Método genérico DENTRO de uma classe genérica:
  /// transforma o conteúdo e devolve uma caixa de outro tipo.
  Caixa<R> mapear<R>(R Function(T item) transformar) =>
      Caixa<R>(transformar(conteudo));

  @override
  String toString() => 'Caixa<$T>($conteudo)';
}

void main() {
  const texto = Caixa<String>('Dart');
  const numero = Caixa<int>(42);

  print(texto);
  print(numero);

  // O tipo acompanha: abrir() de Caixa<String> devolve String.
  final tamanho = texto.abrir().length;
  print('Letras: $tamanho');

  // mapear muda o tipo da caixa.
  final emMaiusculas = texto.mapear<String>((valor) => valor.toUpperCase());
  final dobrado = numero.mapear((valor) => valor * 2); // R inferido: int
  print(emMaiusculas);
  print(dobrado);
}
```

Saída:

```text
Caixa<String>(Dart)
Caixa<int>(42)
Letras: 4
Caixa<String>(DART)
Caixa<int>(84)
```

---

## 📱 Aplicando no Flutter

Você não vai conseguir escrever **uma tela sequer** sem generics. Eles estão em todo lugar:

```dart
List<Widget> filhos = const <Widget>[Text('Dart'), Text('Flutter')];

Future<List<Materia>> carregar() async => <Materia>[];

class _TelaState extends State<Tela> { }   // State<T>
```

E o ponto alto vem no módulo 08, com o Riverpod:

```dart
class TarefasNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async => <String>['Estudar Dart'];

  void adicionar(String titulo) {
    final atuais = state.value ?? <String>[];
    state = AsyncValue<List<String>>.data(<String>[...atuais, titulo]);
  }
}

final tarefasProvider =
    AsyncNotifierProvider<TarefasNotifier, List<String>>(TarefasNotifier.new);
```

Leia com os olhos desta aula e note quantos parâmetros de tipo aparecem:

- `AsyncNotifier<List<String>>` → o notifier promete produzir uma lista de strings;
- `AsyncValue<List<String>>` → um valor que pode estar carregando, com erro **ou** com dados desse
  tipo;
- `AsyncNotifierProvider<TarefasNotifier, List<String>>` → **dois** parâmetros: quem gerencia e o
  que é gerenciado.

Quando a tela lê `ref.watch(tarefasProvider)`, o resultado já vem tipado como
`AsyncValue<List<String>>` e o `data: (lista) => ...` entrega uma `List<String>` de verdade — sem um
único cast. Isso é generics trabalhando por você.

Detalhes em
[`08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md`](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).

E o `Repositorio<T>` desta aula reaparece, com `Future`, na camada de dados do app Foco, no
[Módulo 10](../10-persistencia-de-dados/05-sqflite-crud.md).

---

## 💻 Código completo

> **Arquivo:** `bin/08_generics.dart`
> **Como executar:** `dart run bin/08_generics.dart`

```dart
// Aula 8 do Módulo 03 — Generics: classes, métodos, limites e Repositorio<T>.

// ===========================================================================
// PARTE 1 — O CONTRATO QUE SERVE DE LIMITE
// ===========================================================================

abstract class Entidade {
  String get id;
  String get descricao;
}

class Materia implements Entidade {
  @override
  final String id;
  final String nome;
  final int minutos;

  const Materia({required this.id, required this.nome, required this.minutos});

  @override
  String get descricao => '$nome ($minutos min)';
}

class Sessao implements Entidade {
  @override
  final String id;
  final String materiaId;
  final int minutos;

  const Sessao({
    required this.id,
    required this.materiaId,
    required this.minutos,
  });

  @override
  String get descricao => 'Sessão de $minutos min (matéria $materiaId)';
}

// ===========================================================================
// PARTE 2 — CLASSE GENÉRICA SEM LIMITE
// ===========================================================================

class Par<A, B> {
  final A primeiro;
  final B segundo;

  const Par(this.primeiro, this.segundo);

  Par<B, A> invertido() => Par<B, A>(segundo, primeiro);

  @override
  String toString() => '($primeiro, $segundo)';
}

// ===========================================================================
// PARTE 3 — CLASSE GENÉRICA COM LIMITE
// ===========================================================================

/// `T extends Entidade` restringe o que pode entrar E libera `item.id`
/// e `item.descricao` aqui dentro.
class Repositorio<T extends Entidade> {
  final Map<String, T> _itens = <String, T>{};

  void salvar(T item) => _itens[item.id] = item;

  T? buscar(String id) => _itens[id];

  List<T> listar() => _itens.values.toList();

  List<T> onde(bool Function(T item) teste) => listar().where(teste).toList();

  bool remover(String id) => _itens.remove(id) != null;

  int get total => _itens.length;
}

// ===========================================================================
// PARTE 4 — FUNÇÕES GENÉRICAS
// ===========================================================================

/// Devolve o primeiro item que satisfaz o teste, ou null.
T? primeiroOuNulo<T>(List<T> itens, bool Function(T item) teste) {
  for (final item in itens) {
    if (teste(item)) {
      return item;
    }
  }
  return null;
}

/// Transforma uma lista de T em uma lista de R.
List<R> converter<T, R>(List<T> itens, R Function(T item) transformar) {
  final resultado = <R>[];
  for (final item in itens) {
    resultado.add(transformar(item));
  }
  return resultado;
}

/// Limite `num` para poder usar o operador de comparação.
T maiorDe<T extends num>(T a, T b) => a >= b ? a : b;

/// Função genérica com limite de contrato: serve a QUALQUER repositório.
String resumir<T extends Entidade>(String rotulo, Repositorio<T> repositorio) {
  final descricoes = repositorio.listar().map((item) => item.descricao);
  return '$rotulo: ${repositorio.total} item(ns) -> ${descricoes.join(' · ')}';
}

// ===========================================================================
// PROGRAMA
// ===========================================================================

void main() {
  print('--- 1. Generics que você já usava ---');
  final nomes = <String>['Dart', 'Flutter', 'Lógica'];
  final minutosPorMateria = <String, List<int>>{
    'Dart': <int>[45, 30, 75],
    'Flutter': <int>[60, 120],
  };
  print('nomes: ${nomes.runtimeType}');
  print('mapa:  ${minutosPorMateria.length} chaves, valores do tipo List<int>');
  minutosPorMateria.forEach((materia, sessoes) {
    final total = sessoes.fold<int>(0, (soma, item) => soma + item);
    print('  $materia: ${sessoes.length} sessões, $total min');
  });

  print('');
  print('--- 2. Classe genérica com dois parâmetros ---');
  const par = Par<String, int>('Dart', 150);
  print('Par: $par');
  print('Invertido: ${par.invertido()}');

  print('');
  print('--- 3. Funções genéricas ---');
  final comF = primeiroOuNulo(nomes, (nome) => nome.startsWith('F'));
  final comZ = primeiroOuNulo(nomes, (nome) => nome.startsWith('Z'));
  print('Primeiro com F: $comF');
  print('Primeiro com Z: $comZ');

  final tamanhos = converter<String, int>(nomes, (nome) => nome.length);
  print('Tamanhos: $tamanhos');

  print('maiorDe(3, 7)     = ${maiorDe(3, 7)}');
  print('maiorDe(2.5, 1.5) = ${maiorDe(2.5, 1.5)}');

  print('');
  print('--- 4. Repositorio<T extends Entidade> ---');
  final materias = Repositorio<Materia>();
  materias.salvar(const Materia(id: 'm1', nome: 'Dart', minutos: 150));
  materias.salvar(const Materia(id: 'm2', nome: 'Flutter', minutos: 180));
  materias.salvar(const Materia(id: 'm3', nome: 'Lógica', minutos: 45));

  final sessoes = Repositorio<Sessao>();
  sessoes.salvar(const Sessao(id: 's1', materiaId: 'm1', minutos: 45));
  sessoes.salvar(const Sessao(id: 's2', materiaId: 'm1', minutos: 30));

  // materias.salvar(const Sessao(id: 's3', materiaId: 'm2', minutos: 10));
  // ↑ Descomente e veja o ERRO DE COMPILAÇÃO. É o generic te protegendo.

  print(resumir('Matérias', materias));
  print(resumir('Sessões ', sessoes));

  print('');
  print('--- 5. Consultas tipadas, sem nenhum cast ---');
  final longas = materias.onde((materia) => materia.minutos >= 150);
  for (final materia in longas) {
    // `materia` já é Materia: acesso direto a `nome`, que não existe em Entidade.
    print(' - ${materia.nome}: ${materia.minutos} min');
  }
  print('Busca m2: ${materias.buscar('m2')?.descricao}');
  print('Busca m9: ${materias.buscar('m9')?.descricao}');
  print('Removeu m3? ${materias.remover('m3')}');
  print('Removeu m9? ${materias.remover('m9')}');
  print('Total agora: ${materias.total}');
}
```

**Saída esperada:**

```text
--- 1. Generics que você já usava ---
nomes: List<String>
mapa:  2 chaves, valores do tipo List<int>
  Dart: 3 sessões, 150 min
  Flutter: 2 sessões, 180 min

--- 2. Classe genérica com dois parâmetros ---
Par: (Dart, 150)
Invertido: (150, Dart)

--- 3. Funções genéricas ---
Primeiro com F: Flutter
Primeiro com Z: null
Tamanhos: [4, 7, 6]
maiorDe(3, 7)     = 7
maiorDe(2.5, 1.5) = 2.5

--- 4. Repositorio<T extends Entidade> ---
Matérias: 3 item(ns) -> Dart (150 min) · Flutter (180 min) · Lógica (45 min)
Sessões : 2 item(ns) -> Sessão de 45 min (matéria m1) · Sessão de 30 min (matéria m1)

--- 5. Consultas tipadas, sem nenhum cast ---
 - Dart: 150 min
 - Flutter: 180 min
Busca m2: Flutter (180 min)
Busca m9: null
Removeu m3? true
Removeu m9? false
Total agora: 2
```

> ℹ️ `nomes.runtimeType` imprime `List<String>`: o parâmetro de tipo faz parte do tipo em tempo de
> execução. Já para o `Map` preferimos imprimir uma frase, porque o nome interno da implementação
> de `Map` do Dart começa com `_` (é uma classe privada da biblioteca) e pode variar entre versões.

---

## 🔍 Explicando o código

**`abstract class Entidade { String get id; String get descricao; }`**
O contrato que serve de **limite**. Ele é pequeno de propósito: quanto menor o limite, mais tipos
cabem nele.

**`class Materia implements Entidade`**
`implements` (Aula 5) porque não há código a herdar — só o formato. Note o `@override` no campo
`final String id`: um campo pode implementar um getter do contrato.

**`class Par<A, B>`**
Dois parâmetros de tipo. `Par<String, int>` e `Par<int, bool>` são tipos diferentes, gerados da mesma
classe.

**`Par<B, A> invertido() => Par<B, A>(segundo, primeiro);`**
O tipo de retorno **troca a ordem** dos parâmetros. O compilador confere isso para você — invertê-lo
errado não compila.

> 💡 Dart 3 tem uma alternativa mais leve para pares de valores: os **records**, escritos
> `(String, int)`. Você os conhece em
> [`04-dart-avancado/04-records.md`](../04-dart-avancado/04-records.md). Uma classe genérica continua
> valendo quando você quer **comportamento** junto (como o `invertido()`).

**`class Repositorio<T extends Entidade>`**
O limite aparece **na declaração da classe**. A partir daí, em qualquer método, `T` tem `id` e
`descricao`.

**`void salvar(T item) => _itens[item.id] = item;`**
`item.id` só compila por causa do limite. Troque `<T extends Entidade>` por `<T>` e veja o erro:

```text
Error: The getter 'id' isn't defined for the type 'T'.
```

**`List<T> onde(bool Function(T item) teste)`**
`bool Function(T item)` é o **tipo de uma função**: recebe um `T`, devolve `bool`. Quando você chama
`materias.onde((materia) => ...)`, o Dart já sabe que `materia` é `Materia` — por isso o editor
autocompleta `.nome`.

**`T? primeiroOuNulo<T>(...)`**
O `<T>` vem **depois do nome da função**. O retorno é `T?`: o mesmo tipo da lista, podendo ser nulo.
Compare com a alternativa sem generics, que devolveria `Object?` e obrigaria a um cast.

**`primeiroOuNulo(nomes, (nome) => nome.startsWith('F'))`**
Sem `<String>` explícito. O Dart infere `T = String` a partir de `nomes`, e por isso `nome` dentro da
função já tem `startsWith`.

**`T maiorDe<T extends num>(T a, T b) => a >= b ? a : b;`**
Limite em uma **função**. `num` é a superclasse de `int` e `double`, e é ela quem define o operador
`>=`. Sem o limite, `a >= b` não compilaria. Chamar com `int` devolve `int`; com `double`, `double`.

**`String resumir<T extends Entidade>(String rotulo, Repositorio<T> repositorio)`**
Uma função genérica que recebe uma **classe genérica**. Ela serve a todos os repositórios do app,
presentes e futuros, sem nenhuma alteração.

**A linha comentada `// materias.salvar(const Sessao(...))`**
Descomente para ver o erro:

```text
Error: The argument type 'Sessao' can't be assigned to the parameter type 'Materia'.
```

Esse erro **na sua máquina, agora** é o que substitui um travamento no celular do usuário. É o
resumo de toda a aula.

**`materias.onde((materia) => materia.minutos >= 150)`**
`minutos` e `nome` não existem em `Entidade`, só em `Materia`. Funciona porque o repositório é
`Repositorio<Materia>`: o tipo concreto sobreviveu à viagem toda, sem cast.

**`materias.buscar('m9')?.descricao` → `null`**
`buscar` devolve `T?`. O `?.` só chama `descricao` se não for nulo — *null safety* do módulo 02.

---

## ⚠️ Erros comuns

**1. `var lista = [];`**

```dart
var lista = [];       // ❌ List<dynamic>
lista.add('Dart');
final n = lista.first + 1; // compila! e explode em tempo de execução
```
✅ `final lista = <String>[];`

**2. Usar `dynamic` para "resolver" um erro de tipo**

`dynamic` desliga a verificação: todo erro vira erro de execução. ✅ Use generics ou `Object?` com
`is`.

**3. Chamar membro de `T` sem limite**

```dart
class Repositorio<T> {
  void salvar(T item) => _itens[item.id] = item; // ❌
}
```
```text
Error: The getter 'id' isn't defined for the type 'T'.
```
✅ `class Repositorio<T extends Entidade>`.

**4. Criar `T` dentro da classe**

```dart
class Fabrica<T> {
  T criar() => T(); // ❌ não existe "construtor de T"
}
```
✅ Receba uma função construtora: `Fabrica(this.construir); final T Function() construir;`

**5. Esquecer o `<>` ao instanciar e receber `dynamic`**

```dart
final repo = Repositorio(); // ❌ T vira Entidade (o limite), não Materia
```
✅ `final repo = Repositorio<Materia>();`

**6. A armadilha da covariância de listas**

Em Dart, `List<Materia>` **é** um `List<Entidade>`. Isso é prático, mas abre um buraco:

```dart
final List<Materia> materias = <Materia>[];
final List<Entidade> comoEntidades = materias; // permitido
comoEntidades.add(sessao);                     // compila... e explode:
```
```text
Unhandled exception: type 'Sessao' is not a subtype of type 'Materia'
```
✅ Não adicione itens através de uma variável tipada com o supertipo. Se a função só lê, deixe claro
devolvendo/recebendo `List<T>` com o tipo certo.

**7. Anotar tipos genéricos demais**

```dart
final Repositorio<Materia> repo = Repositorio<Materia>(); // redundante
```
✅ `final repo = Repositorio<Materia>();` — a inferência já resolve.

**8. Confundir `T` com o nome de uma classe**

`T` não é um tipo que existe: é um **espaço reservado**. `print(T)` dentro da classe imprime o tipo
real com que ela foi criada.

---

## 🛠️ Exercício guiado

Vamos escrever uma `Pilha<T>` genérica — a estrutura que o Flutter usa para navegação (módulo 07).

**Passo 1.** Crie `bin/guiado_08_pilha.dart`:

```dart
class Pilha<T> {
  final List<T> _itens = <T>[];

  void empilhar(T item) => _itens.add(item);

  /// Remove e devolve o topo; null se estiver vazia.
  T? desempilhar() => _itens.isEmpty ? null : _itens.removeLast();

  /// Espia o topo sem remover.
  T? get topo => _itens.isEmpty ? null : _itens.last;

  bool get vazia => _itens.isEmpty;

  int get altura => _itens.length;

  /// Devolve uma cópia imutável, do topo para a base.
  List<T> comoLista() => List<T>.unmodifiable(_itens.reversed);

  @override
  String toString() => 'Pilha<$T>${comoLista()}';
}
```

**Passo 2.** Use com `String` (rotas, como no Navigator do Flutter):

```dart
void main() {
  final rotas = Pilha<String>();
  rotas.empilhar('/');
  rotas.empilhar('/materias');
  rotas.empilhar('/materia/form');

  print(rotas);
  print('Topo: ${rotas.topo}');
  print('Altura: ${rotas.altura}');

  print('Voltou de: ${rotas.desempilhar()}');
  print('Agora no topo: ${rotas.topo}');
```

**Passo 3.** Use a **mesma** classe com outro tipo, sem escrever nenhuma linha nova:

```dart
  final numeros = Pilha<int>();
  for (final valor in <int>[10, 20, 30]) {
    numeros.empilhar(valor);
  }
  print('');
  print(numeros);
  print('Soma dos desempilhados:');
  var soma = 0;
  while (!numeros.vazia) {
    final valor = numeros.desempilhar()!;
    soma += valor;
    print('  tirou $valor, soma $soma');
  }
  print('Pilha vazia? ${numeros.vazia} · topo: ${numeros.topo}');
}
```

**Passo 4.** Execute:

```powershell
dart run bin/guiado_08_pilha.dart
```

**Saída esperada:**

```text
Pilha<String>[/materia/form, /materias, /]
Topo: /materia/form
Altura: 3
Voltou de: /materia/form
Agora no topo: /materias

Pilha<int>[30, 20, 10]
Soma dos desempilhados:
  tirou 30, soma 30
  tirou 20, soma 50
  tirou 10, soma 60
Pilha vazia? true · topo: null
```

**Passo 5.** Tente `rotas.empilhar(42)`. O erro aparece **antes** de rodar:

```text
Error: The argument type 'int' can't be assigned to the parameter type 'String'.
```

Guarde esta pilha: é literalmente o modelo mental do `Navigator` do Flutter, no
[Módulo 07](../07-navegacao-e-formularios/01-navigator-a-pilha.md).

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Implemente um **cache genérico com limite de tamanho**:

```dart
class CacheLimitado<K, V> {
  CacheLimitado({this.capacidade = 3});
  final int capacidade;
  // ...
}
```

Requisitos:

1. `void guardar(K chave, V valor)` — ao passar da capacidade, descarta a entrada **mais antiga**.
2. `V? ler(K chave)` — devolve nulo se não houver.
3. `bool contem(K chave)`, `int get tamanho`, `void limpar()`.
4. Um getter `List<K> get chavesEmOrdem`, da mais antiga para a mais nova.
5. Teste com `CacheLimitado<String, Materia>` e com `CacheLimitado<int, String>` — **a mesma classe**.
6. Escreva, em comentário, por que `K` **não** precisa de limite aqui, mas precisaria se você fosse
   ordenar as chaves (dica: ordenar exige `Comparable`).

Esse cache é o embrião do que você faz de verdade em
[`10-persistencia-de-dados/08-cache-e-offline.md`](../10-persistencia-de-dados/08-cache-e-offline.md).

---

## 📌 Resumo

- **Generics** transformam o tipo em um parâmetro: uma implementação, muitos tipos, zero casts.
- `List<String>`, `Map<String, int>` e `Set<Materia>` já eram generics desde o módulo 02.
- `var lista = []` infere `List<dynamic>` e desliga a checagem — escreva `<String>[]`.
- Classe genérica: `class Caixa<T>`. Função/método genérico: `T? primeiro<T>(...)`.
- A **inferência** normalmente descobre `T` sozinha; escreva `<Tipo>` quando ajudar a ler.
- `<T extends Algo>` **restringe** quem pode entrar e **libera** os membros de `Algo` lá dentro.
- Sem limite, `T` é `Object?`: você não pode chamar nada específico nele.
- `Repositorio<T extends Entidade>` é o padrão que substitui uma classe por tipo de dado.
- Listas em Dart são **covariantes**: `List<Materia>` é um `List<Entidade>`, e escrever através do
  supertipo explode em tempo de execução.

---

## ☑️ Checklist de domínio

- [ ] Explico, com um exemplo de bug, por que generics existem.
- [ ] Escrevo uma classe genérica com um e com dois parâmetros de tipo.
- [ ] Escrevo uma função genérica e sei onde o `<T>` entra na assinatura.
- [ ] Explico as duas coisas que um limite `extends` faz ao mesmo tempo.
- [ ] Sei prever o erro ao chamar `item.id` em um `T` sem limite.
- [ ] Escrevo `Repositorio<T extends Entidade>` inteiro sem consultar a aula.
- [ ] Sei explicar a armadilha da covariância de listas.
- [ ] Reconheço os parâmetros de tipo em `AsyncNotifierProvider<TarefasNotifier, List<String>>`.
- [ ] Rodei `bin/08_generics.dart` e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Generics](https://dart.dev/language/generics)
- [Dart — Restricting the parameterized type](https://dart.dev/language/generics#restricting-the-parameterized-type)
- [Dart — Using generic methods](https://dart.dev/language/generics#using-generic-methods)
- [Dart — Type system e inferência](https://dart.dev/language/type-system)
- [Effective Dart — Design: parâmetros de tipo](https://dart.dev/effective-dart/design#types)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — Enums](07-enums.md) | [README](README.md) | [Aula 9 — Extensions](09-extensions.md) |
