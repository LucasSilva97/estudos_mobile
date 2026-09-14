# Aula 8 — Listas

> **Módulo:** 02 - Dart Básico · **Tempo estimado:** 50 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Criar listas com literal, `List.filled`, `List.generate` e `List.of`.
- Acessar por índice e usar `length`, `first`, `last`, `isEmpty`, `contains`, `indexOf`.
- Modificar com `add`, `addAll`, `insert`, `remove`, `removeAt`, `removeWhere`.
- Montar listas com *spread* (`...`), *collection-if* e *collection-for*.
- Transformar e filtrar com `map`, `where`, `take`, `skip`, `reversed` e `join`.
- Consultar com `firstWhere`, `any`, `every`, `indexWhere`.
- Acumular com `reduce` e `fold`, e ordenar com `sort`.
- Criar listas imutáveis e entender por que `Iterable` é **preguiçoso**.

## ✅ Pré-requisitos

- [Aula 6](06-controle-de-fluxo.md) (laços) e [Aula 7](07-funcoes-em-dart.md) (funções anônimas).

## 📖 Conceito

Uma `List` é uma sequência **ordenada** de elementos, acessíveis por um índice que começa em `0`.
É a coleção que você mais vai usar — e, no Flutter, é literalmente o que vira uma tela com itens.

### Criando

```dart
final materias = <String>['Dart', 'Flutter', 'Git'];   // literal
final vazia = <int>[];                                  // vazia, cresce depois
final zeros = List<int>.filled(3, 0);                   // [0, 0, 0] — tamanho FIXO
final blocos = List<int>.generate(5, (i) => (i + 1) * 25); // [25, 50, 75, 100, 125]
final copia = List<String>.of(materias);                // cópia independente
const fixa = <String>['Dart', 'Flutter'];               // imutável
```

Repare no `<String>` antes do colchete: é o **tipo dos elementos**. Sem ele, `[]` sozinho vira
`List<dynamic>` e você perde a proteção do compilador. Escreva sempre o tipo.

> ⚠️ `List.filled` cria lista de **tamanho fixo**: `add` nela lança
> `Unsupported operation: Cannot add to a fixed-length list`. Para poder crescer, passe
> `growable: true`.

### Lendo

```dart
materias[0]              // 'Dart' — índice começa em 0
materias.first           // 'Dart'
materias.last            // 'Git'
materias.length          // 3
materias.isEmpty         // false
materias.isNotEmpty      // true
materias.contains('Git') // true
materias.indexOf('Git')  // 2  (ou -1 se não existir)
```

Índice fora do intervalo lança `RangeError`. `first` e `last` em lista vazia lançam
`StateError: Bad state: No element`.

### Modificando

```dart
materias.add('SQL');                      // no fim
materias.addAll(<String>['Testes']);      // vários no fim
materias.insert(1, 'Lógica');             // na posição 1
materias.remove('SQL');                   // remove o primeiro igual
materias.removeAt(0);                     // remove por índice
materias.removeWhere((m) => m.length > 6); // remove por condição
materias.clear();                         // esvazia
```

### Montando listas: spread, collection-if e collection-for

Estes três recursos são **específicos do Dart** e são a razão de o código de interface do Flutter
ficar tão limpo.

```dart
final todas = <String>[...basicas, ...extras, 'Testes'];       // spread
final segura = <String>[...basicas, ...?talvezNulas];          // spread seguro

final plano = <String>[
  'Abertura',
  for (final m in minutos) if (m > 0) '$m min',   // collection-for + collection-if
  if (incluirExtras) 'Revisão extra',
  'Encerramento',
];
```

- `...lista` **despeja** os elementos de outra lista dentro desta.
- `...?lista` faz o mesmo, ignorando se a lista for `null`.
- `if (condição) valor` inclui o elemento **só se** a condição for verdadeira.
- `for (final x in fonte) valor` gera vários elementos de uma vez.

Nada disso precisa de `;` — são elementos de uma lista, separados por vírgula.

### Transformando: `map` e `where`

```dart
final dobrados = minutos.map((m) => m * 2).toList();
final validos = minutos.where((m) => m > 0 && m <= 240).toList();
```

- `map` aplica a função a **cada** elemento e devolve a mesma quantidade.
- `where` mantém apenas os elementos em que a função devolve `true`.

Ambos devolvem um **`Iterable`**, não uma `List`. E `Iterable` é **preguiçoso**: nada é calculado
até você pedir. `toList()` força o cálculo e devolve uma lista de verdade.

> **Iterable preguiçoso** (*lazy*) — a operação fica "agendada". Se você nunca percorrer o
> resultado, o cálculo nunca acontece. Se percorrer duas vezes, ele acontece **duas vezes**. Por
> isso, quando o resultado vai ser usado mais de uma vez, chame `toList()`.

Outros transformadores úteis:

| Método | O que faz |
|---|---|
| `take(n)` | os `n` primeiros |
| `skip(n)` | tudo depois dos `n` primeiros |
| `reversed` | ordem invertida (não altera a original) |
| `join(sep)` | junta tudo em uma `String` |
| `expand(f)` | achata: cada elemento vira vários |
| `toSet()` | remove duplicatas (veja a [Aula 9](09-sets-e-maps.md)) |

### Consultando

```dart
minutos.any((m) => m > 240);      // existe pelo menos um?
minutos.every((m) => m > 0);      // todos satisfazem?
minutos.indexWhere((m) => m == 0); // índice do primeiro que satisfaz, ou -1
minutos.firstWhere((m) => m >= 90, orElse: () => -1);
```

⚠️ `firstWhere` **sem** `orElse` lança `StateError: Bad state: No element` quando nada casa.
Sempre passe `orElse`, ou verifique antes com `any`.

### Acumulando: `reduce` e `fold`

```dart
final soma = valores.reduce((a, b) => a + b);              // exige lista NÃO vazia
final total = valores.fold<int>(0, (acc, m) => acc + m);   // funciona em lista vazia
final texto = valores.fold<String>('', (txt, m) => '$txt[$m]');
```

- `reduce` combina os elementos dois a dois; o resultado é do **mesmo tipo** dos elementos e ele
  **lança** em lista vazia.
- `fold` recebe um valor inicial, aceita lista vazia e pode mudar de tipo (`List<int>` → `String`).

Na dúvida, use `fold`.

### Ordenando

```dart
final copia = List<int>.of(minutos);
copia.sort();                                 // crescente, MODIFICA a lista
copia.sort((a, b) => b.compareTo(a));         // decrescente
nomes.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())); // sem diferenciar maiúsculas
```

`sort` ordena **no lugar** e devolve `void`. Escrever `final ordenada = lista.sort();` não
funciona — `ordenada` seria `void`. Para ordenar uma cópia em uma linha, use a cascata `..`:

```dart
final ordenada = List<int>.of(minutos)..sort();
```

> **Cascata (`..`)** — chama um método no objeto e devolve **o objeto**, não o resultado do
> método. É o que permite encadear `..sort()` e ainda receber a lista.

A função de comparação devolve negativo (a vem antes), zero (empate) ou positivo (a vem depois).
`compareTo` já faz isso para números e textos.

### Listas imutáveis

```dart
const fixa = <String>['Dart', 'Flutter'];               // congelada na compilação
final protegida = List<String>.unmodifiable(materias);  // cópia congelada
```

As duas lançam `UnsupportedError` em qualquer tentativa de modificação. `List.unmodifiable` faz
uma **cópia**: mudanças na lista original depois disso não aparecem nela.

## 💡 Analogia

Uma `List` é um **trem com vagões numerados a partir do zero**. Você pode entrar no vagão 2,
engatar um vagão no fim (`add`), encaixar um no meio (`insert`) ou desengatar (`removeAt`).

`map` é repintar **todos** os vagões — o trem continua com o mesmo número de vagões.
`where` é montar um trem novo só com os vagões que passam na inspeção.
`fold` é um funcionário que anda pelo trem com uma prancheta, somando o que vê em cada vagão e
saindo no fim com **um único número**.
`Iterable` preguiçoso é a **ordem de serviço** para repintar: enquanto ninguém for conferir o
trem, nenhuma lata de tinta é aberta.

## 🧪 Exemplo mínimo

```dart
void main() {
  const minutos = <int>[45, 0, 120, 30];

  final validos = minutos.where((m) => m > 0).toList();
  final total = validos.fold<int>(0, (acc, m) => acc + m);

  print('Sessões válidas: $validos');
  print('Total: $total min');
  print('Mais longa: ${validos.reduce((a, b) => a > b ? a : b)} min');
}
```

```text
Sessões válidas: [45, 120, 30]
Total: 195 min
Mais longa: 120 min
```

## 📱 Aplicando no Flutter

Listas são o coração de qualquer app de conteúdo — e o app **Foco** é um app de listas: matérias,
sessões, trilhas.

**1. `List` vira `ListView`.**

```dart
// prévia do módulo 06
ListView.builder(
  itemCount: materias.length,
  itemBuilder: (context, i) => ListTile(title: Text(materias[i].nome)),
)
```

`itemCount` é o `length` que você aprendeu aqui; `itemBuilder` recebe o índice. Tema de
[06 — Listas e rolagem](../06-widgets-e-layouts/09-listas-e-rolagem.md).

**2. `map` monta widgets.**

```dart
Column(
  children: materias.map((m) => Text(m.nome)).toList(),
)
```

O `.toList()` é obrigatório: `children` espera `List<Widget>`, não `Iterable<Widget>`.

**3. *Collection-if* e *collection-for* montam telas condicionais.**

```dart
Column(
  children: <Widget>[
    const Text('Minhas matérias'),
    if (carregando) const CircularProgressIndicator(),
    for (final m in materias) MateriaTile(materia: m),
    if (materias.isEmpty) const Text('Nenhuma matéria ainda'),
  ],
)
```

Este é, provavelmente, o padrão de código que você mais vai escrever no curso inteiro. Ele nasce
aqui, na Aula 8.

**4. Listas imutáveis e `const`.**
Widgets recebem `List` em `children`. Quando a lista é `const`, o widget inteiro pode ser `const`
e o Flutter pula a reconstrução —
[13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md).

## 💻 Código completo

> **Arquivo:** `dart_basico/bin/listas.dart`
> **Como executar:** `dart run bin/listas.dart`

```dart
// bin/listas.dart
// Demonstra: criação, acesso, modificação, spread, collection-if/for,
// map/where/fold/reduce/sort e imutabilidade.

void main() {
  print('=== 1. Criando listas ===');
  final List<String> materias = <String>['Dart', 'Flutter', 'Git'];
  final List<int> vazia = <int>[];
  final List<int> zeros = List<int>.filled(3, 0);
  final List<int> blocos = List<int>.generate(5, (int i) => (i + 1) * 25);
  print('literal  : $materias');
  print('vazia    : $vazia (isEmpty = ${vazia.isEmpty})');
  print('filled   : $zeros');
  print('generate : $blocos');

  print('');
  print('=== 2. Acesso por índice ===');
  print('materias[0]      : ${materias[0]}');
  print('first / last     : ${materias.first} / ${materias.last}');
  print('length           : ${materias.length}');
  print('indexOf("Git")   : ${materias.indexOf('Git')}');
  print('contains("Java") : ${materias.contains('Java')}');

  print('');
  print('=== 3. Modificando ===');
  materias.add('SQL');
  materias.insert(1, 'Lógica');
  materias.addAll(<String>['Testes', 'Build']);
  print('add/insert/addAll : $materias');
  materias.remove('SQL');
  materias.removeAt(0);
  print('remove/removeAt   : $materias');
  materias.removeWhere((String m) => m.startsWith('B'));
  print('removeWhere       : $materias');

  print('');
  print('=== 4. Spread ===');
  const List<String> basicas = <String>['Dart', 'Flutter'];
  const List<String> extras = <String>['Git', 'SQL'];
  print('spread simples : ${<String>[...basicas, ...extras, 'Testes']}');
  List<String>? opcionais;
  print('spread seguro (null) : ${<String>[...basicas, ...?opcionais]}');
  opcionais = <String>['Build'];
  print('spread seguro (cheio): ${<String>[...basicas, ...?opcionais]}');

  print('');
  print('=== 5. collection-if e collection-for ===');
  const bool incluirExtras = true;
  const List<int> minutos = <int>[45, 0, 120, 300, 30];
  final List<String> plano = <String>[
    'Abertura',
    for (final int m in minutos)
      if (m > 0) '$m min',
    if (incluirExtras) 'Revisão extra',
    'Encerramento',
  ];
  print('plano: $plano');

  print('');
  print('=== 6. map, where, take, skip, reversed, join ===');
  final List<int> dobrados = minutos.map((int m) => m * 2).toList();
  final List<int> validos =
      minutos.where((int m) => m > 0 && m <= 240).toList();
  print('map dobrado : $dobrados');
  print('where válido: $validos');
  print('take(2)     : ${minutos.take(2).toList()}');
  print('skip(3)     : ${minutos.skip(3).toList()}');
  print('reversed    : ${minutos.reversed.toList()}');
  print('join        : ${validos.join(' + ')}');

  print('');
  print('=== 7. firstWhere, any, every, indexWhere ===');
  print('any(> 240)       : ${minutos.any((int m) => m > 240)}');
  print('every(> 0)       : ${minutos.every((int m) => m > 0)}');
  print('indexWhere(== 0) : ${minutos.indexWhere((int m) => m == 0)}');
  print('firstWhere >= 90 : '
      '${minutos.firstWhere((int m) => m >= 90, orElse: () => -1)}');
  print('firstWhere == 999: '
      '${minutos.firstWhere((int m) => m == 999, orElse: () => -1)}');

  print('');
  print('=== 8. reduce e fold ===');
  print('reduce soma  : ${validos.reduce((int a, int b) => a + b)}');
  print('reduce maior : ${minutos.reduce((int a, int b) => a > b ? a : b)}');
  print('fold soma    : '
      '${minutos.fold<int>(0, (int acc, int m) => acc + m)}');
  print('fold texto   : '
      '${validos.fold<String>('', (String txt, int m) => '$txt[$m]')}');

  print('');
  print('=== 9. sort ===');
  final List<int> ordenados = List<int>.of(minutos)..sort();
  print('crescente   : $ordenados');
  ordenados.sort((int a, int b) => b.compareTo(a));
  print('decrescente : $ordenados');
  const List<String> nomes = <String>['Flutter', 'dart', 'Git', 'ansible'];
  final List<String> alfabetica = List<String>.of(nomes)
    ..sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
  print('original    : $nomes');
  print('alfabética  : $alfabetica');

  print('');
  print('=== 10. Listas imutáveis ===');
  final List<String> protegida = List<String>.unmodifiable(materias);
  print('protegida : $protegida');
  try {
    protegida.add('Novo');
  } on UnsupportedError catch (erro) {
    print('Erro esperado: ${erro.message}');
  }
  materias.add('Extra');
  print('original depois do add : $materias');
  print('protegida não mudou    : $protegida');

  print('');
  print('=== 11. Iterable é preguiçoso ===');
  final Iterable<int> preguicoso = minutos.map((int m) {
    print('  calculando $m');
    return m * 2;
  });
  print('criado, mas nada calculou ainda');
  print('first   : ${preguicoso.first}');
  print('toList(): ${preguicoso.toList()}');
}
```

Saída esperada:

```text
=== 1. Criando listas ===
literal  : [Dart, Flutter, Git]
vazia    : [] (isEmpty = true)
filled   : [0, 0, 0]
generate : [25, 50, 75, 100, 125]

=== 2. Acesso por índice ===
materias[0]      : Dart
first / last     : Dart / Git
length           : 3
indexOf("Git")   : 2
contains("Java") : false

=== 3. Modificando ===
add/insert/addAll : [Dart, Lógica, Flutter, Git, SQL, Testes, Build]
remove/removeAt   : [Lógica, Flutter, Git, Testes, Build]
removeWhere       : [Lógica, Flutter, Git, Testes]

=== 4. Spread ===
spread simples : [Dart, Flutter, Git, SQL, Testes]
spread seguro (null) : [Dart, Flutter]
spread seguro (cheio): [Dart, Flutter, Build]

=== 5. collection-if e collection-for ===
plano: [Abertura, 45 min, 120 min, 300 min, 30 min, Revisão extra, Encerramento]

=== 6. map, where, take, skip, reversed, join ===
map dobrado : [90, 0, 240, 600, 60]
where válido: [45, 120, 30]
take(2)     : [45, 0]
skip(3)     : [300, 30]
reversed    : [30, 300, 120, 0, 45]
join        : 45 + 120 + 30

=== 7. firstWhere, any, every, indexWhere ===
any(> 240)       : true
every(> 0)       : false
indexWhere(== 0) : 1
firstWhere >= 90 : 120
firstWhere == 999: -1

=== 8. reduce e fold ===
reduce soma  : 195
reduce maior : 300
fold soma    : 495
fold texto   : [45][120][30]

=== 9. sort ===
crescente   : [0, 30, 45, 120, 300]
decrescente : [300, 120, 45, 30, 0]
original    : [Flutter, dart, Git, ansible]
alfabética  : [ansible, dart, Flutter, Git]

=== 10. Listas imutáveis ===
protegida : [Lógica, Flutter, Git, Testes]
Erro esperado: Cannot add to an unmodifiable list
original depois do add : [Lógica, Flutter, Git, Testes, Extra]
protegida não mudou    : [Lógica, Flutter, Git, Testes]

=== 11. Iterable é preguiçoso ===
criado, mas nada calculou ainda
  calculando 45
first   : 90
  calculando 45
  calculando 0
  calculando 120
  calculando 300
  calculando 30
toList(): [90, 0, 240, 600, 60]
```

## 🔍 Explicando o código

**`List<int>.generate(5, (int i) => (i + 1) * 25)`**
Chama a função para `i` de 0 a 4, montando `[25, 50, 75, 100, 125]`. É a forma direta de criar
uma lista calculada, sem laço manual.

**`materias.removeWhere((String m) => m.startsWith('B'))`**
Remove **todos** os que satisfazem. Como só `Build` começa com `B`, sobra o resto. Diferente de
`remove`, que tira apenas a primeira ocorrência de um valor específico.

**`<String>[...basicas, ...?opcionais]`**
Na primeira chamada `opcionais` é `null` e o `...?` simplesmente não acrescenta nada; na segunda,
já tem valor e os elementos entram. Sem o `?`, o código nem compilaria.

**O `for` dentro do literal de lista**

```dart
for (final int m in minutos)
  if (m > 0) '$m min',
```

Não há `{ }`, não há `;` e não há `add`. O `for` e o `if` aqui são **elementos de coleção**: eles
produzem itens diretamente na lista que está sendo construída. O `0` da lista de minutos é
descartado pelo `if`, e é por isso que o plano tem 4 durações e não 5.

**`minutos.where(...).toList()`**
Sem o `toList()`, `validos` seria um `Iterable<int>` e o `reduce` da seção 8 recalcularia o
filtro toda vez. Com `toList()`, o resultado é calculado uma vez e guardado.

**`firstWhere((m) => m == 999, orElse: () => -1)`**
`orElse` é uma **função** que fornece o valor de reserva — repare nos parênteses vazios `() =>`.
Sem `orElse`, esta linha lançaria `Bad state: No element`.

**`fold<int>(0, (acc, m) => acc + m)` × `reduce((a, b) => a + b)`**
`fold` começa do `0` e sobrevive a uma lista vazia; `reduce` começa do primeiro elemento e lança
`Bad state: No element` se a lista estiver vazia. O `fold<String>` mostra a outra vantagem:
o acumulador pode ter tipo diferente dos elementos.

**`List<int>.of(minutos)..sort()`**
`List.of` faz uma cópia (a original `minutos` é `const` e não poderia ser ordenada). O `..sort()`
é a cascata: ordena e devolve **a lista**, não o `void` do `sort`.

**`a.toLowerCase().compareTo(b.toLowerCase())`**
Sem o `toLowerCase`, a ordenação usaria os códigos Unicode e todas as maiúsculas viriam antes das
minúsculas — `Flutter` e `Git` apareceriam antes de `ansible` e `dart`.

**`List<String>.unmodifiable(materias)`**
Cria uma **cópia** congelada. Por isso o `materias.add('Extra')` seguinte muda a original e não
toca na protegida. Se você quisesse uma "janela" que reflete mudanças, precisaria de outra
estratégia — e, na prática, é melhor não querer.

**A seção 11**
A função de `map` imprime `calculando`. Repare na saída: nada é calculado na criação; `first`
calcula **apenas o primeiro**; `toList()` calcula **todos de novo**. Esse é o comportamento
preguiçoso, e é a razão de `toList()` existir.

## ⚠️ Erros comuns

**1. Índice fora do intervalo**

```text
RangeError (index): Invalid value: Not in inclusive range 0..2: 5
```

O último índice válido é `length - 1`.

**2. `firstWhere` sem `orElse`**

```text
Bad state: No element
```

**3. `reduce` em lista vazia**
Mesmo erro acima. Use `fold` com valor inicial.

**4. `add` em lista de tamanho fixo ou `const`**

```text
Unsupported operation: Cannot add to a fixed-length list
Unsupported operation: Cannot add to an unmodifiable list
```

`List.filled(...)` sem `growable: true` é fixa; `const [...]` é imutável.

**5. Esperar que `sort` devolva a lista**

```dart
final ordenada = minutos.sort();   // ordenada é void!
final ordenada = List<int>.of(minutos)..sort();   // certo
```

**6. Modificar a lista enquanto a percorre**

```text
ConcurrentModificationError: Concurrent modification during iteration
```

Use `removeWhere`, ou percorra uma cópia (`for (final x in lista.toList())`).

**7. Esquecer `.toList()` depois de `map`**

```text
Error: The argument type 'Iterable<Widget>' can't be assigned to the parameter type 'List<Widget>'.
```

Este erro exato vai aparecer no seu primeiro `Column(children: ...)` do Flutter.

**8. Achar que `map` altera a lista original**
`map` **não** altera nada: devolve uma sequência nova. Quem altera no lugar são `add`, `remove`,
`sort`, `clear` e companhia.

**9. Declarar `[]` sem tipo**

```dart
final lista = [];        // List<dynamic> — evite
final lista = <String>[]; // certo
```

## 🛠️ Exercício guiado

**Passo 1.** Crie `bin/listas.dart` e digite o código completo.

**Passo 2.** Rode e confira a saída:

```powershell
dart run bin/listas.dart
```

**Passo 3 — provoque o `RangeError`.** Acrescente `print(materias[10]);` na seção 2, rode, leia
o erro e apague.

**Passo 4 — tire o `orElse`.** Na seção 7, apague `, orElse: () => -1` do `firstWhere == 999`.
Rode e leia `Bad state: No element`. Restaure.

**Passo 5 — troque `fold` por `reduce` em lista vazia.** Acrescente:

```dart
final List<int> nenhuma = <int>[];
print(nenhuma.fold<int>(0, (int acc, int m) => acc + m));   // 0
print(nenhuma.reduce((int a, int b) => a + b));             // explode
```

Rode, leia o erro e deixe só a linha do `fold`.

**Passo 6 — brinque com o collection-for.** Mude a seção 5 para incluir também os zeros, com
rótulo diferente:

```dart
for (final int m in minutos)
  if (m > 0) '$m min' else 'sessão vazia',
```

Rode e veja `sessão vazia` aparecer. O `else` dentro de um literal de coleção é permitido.

**Passo 7 — ordene por critério composto.** Crie
`final List<String> porTamanho = List<String>.of(nomes)..sort((a, b) => a.length.compareTo(b.length));`
e imprima. Depois troque para desempatar em ordem alfabética quando o tamanho for igual:

```dart
..sort((a, b) {
  final int porLength = a.length.compareTo(b.length);
  if (porLength != 0) return porLength;
  return a.toLowerCase().compareTo(b.toLowerCase());
})
```

**Passo 8.** Rode `dart format .` e `dart analyze`.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md)

Faça os de **Aplicação** e **Implementação** que envolvem transformação de listas.

## 🏆 Desafio opcional

Escreva `bin/relatorio_semanal.dart` que, a partir de

```dart
const List<String> dias = <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
const List<int> minutos = <int>[45, 0, 120, 300, 30, 0, 90];
```

produza, **sem nenhum laço `for` clássico com índice**:

1. Uma lista de linhas `Seg | 45 min | ████` onde a barra tem um `█` a cada 25 minutos
   (use `'█' * (m ~/ 25)`), montada com *collection-for*.
2. O total, a média (uma casa decimal) e o maior valor, usando `fold` e `reduce`.
3. Os dias sem estudo, usando `indexed` + `where` + `map`, no formato `Dias vazios: Ter, Sab`.
4. Os três dias mais produtivos, em ordem decrescente, usando cópia + `sort` + `take(3)`.
5. Uma lista final imutável com o relatório completo, criada com `List.unmodifiable`, e uma
   tentativa de `add` capturada com `try`/`on UnsupportedError`.

Dica para o item 3: `dias.indexed.where((par) => minutos[par.$1] == 0).map((par) => par.$2)`.
`par.$1` e `par.$2` são os dois campos do record — veja
[04 — Records](../04-dart-avancado/04-records.md).

## 📌 Resumo

- `List` é ordenada e indexada a partir de `0`. Escreva sempre o tipo: `<String>[]`.
- `List.filled` é de tamanho fixo; `List.generate` calcula; `List.of` copia.
- `add`, `insert`, `remove`, `removeAt`, `removeWhere` e `clear` modificam no lugar.
- `...` e `...?` despejam outra lista; *collection-if* e *collection-for* montam listas
  condicionais sem laço externo.
- `map` transforma, `where` filtra — os dois devolvem `Iterable` **preguiçoso**; use `toList()`.
- `firstWhere` precisa de `orElse`; `reduce` quebra em lista vazia, `fold` não.
- `sort` ordena no lugar e devolve `void`; use `List.of(x)..sort()` para ordenar uma cópia.
- `const` e `List.unmodifiable` produzem listas que lançam `UnsupportedError` ao serem alteradas.

## ☑️ Checklist de domínio

- [ ] Crio uma lista tipada sem pensar (`<String>[]`).
- [ ] Sei a diferença entre `remove`, `removeAt` e `removeWhere`.
- [ ] Monto uma lista com *collection-if* e *collection-for* sem consultar material.
- [ ] Sei por que `map` precisa de `.toList()` em muitos casos.
- [ ] Sempre passo `orElse` em `firstWhere`.
- [ ] Escolho `fold` quando a lista pode estar vazia.
- [ ] Sei ordenar uma cópia sem alterar a original.
- [ ] Já vi, no meu terminal, o `Iterable` preguiçoso calculando duas vezes.
- [ ] `bin/listas.dart` roda e passa em `dart analyze`.

## 📚 Referências oficiais

- [Dart — Collections](https://dart.dev/language/collections)
- [Dart — `List` class](https://api.dart.dev/dart-core/List-class.html)
- [Dart — `Iterable` class](https://api.dart.dev/dart-core/Iterable-class.html)
- [Dart — Iterable collections (tutorial)](https://dart.dev/libraries/collections/iterables)
- [Dart — Cascade notation](https://dart.dev/language/operators#cascade-notation)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Funções em Dart](07-funcoes-em-dart.md) | [README](README.md) | [Sets e Maps](09-sets-e-maps.md) |
