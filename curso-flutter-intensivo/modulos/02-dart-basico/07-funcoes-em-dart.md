# Aula 7 — Funções em Dart

> **Módulo:** 02 - Dart Básico · **Tempo estimado:** 50 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Declarar funções com parâmetros posicionais obrigatórios e opcionais.
- Declarar parâmetros **nomeados**, com valor padrão e com `required`.
- Escrever *arrow functions* (`=>`) e saber quando elas cabem.
- Criar funções **anônimas** e passá-las como argumento.
- Entender o que é uma **closure** e por que ela "lembra" o valor de fora.
- Tratar função como valor: tipos de função, *tear-off* e `typedef`.
- Escrever uma função que recebe outra função (*callback*).

## ✅ Pré-requisitos

- [Aula 5](05-null-safety.md) e [Aula 6](06-controle-de-fluxo.md).
- Noção de função — [Módulo 01, Aula 9](../01-logica-e-fundamentos/09-funcoes.md).

## 📖 Conceito

Uma função em Dart tem quatro partes:

```dart
String formatar(String materia, int minutos) {
  return '$materia: $minutos min';
}
//  ↑         ↑          ↑
//  |         |          └─ parâmetros (tipo + nome)
//  |         └─ nome, em lowerCamelCase
//  └─ tipo de retorno
```

Se a função não devolve nada, o tipo de retorno é `void`.

### Os três tipos de parâmetro

Dart tem **três** formatos, e a escolha entre eles é uma decisão de legibilidade.

**1. Posicionais obrigatórios** — a forma padrão. A ordem importa.

```dart
String formatar(String materia, int minutos) { ... }

formatar('Dart', 45);      // certo
formatar(45, 'Dart');      // ERRO de tipo
```

**2. Posicionais opcionais** — entre colchetes `[ ]`, sempre no fim, com valor padrão ou tipo anulável.

```dart
String registrar(String materia, [int minutos = 25]) { ... }

registrar('Flutter');       // usa 25
registrar('Git', 50);       // usa 50
```

Você não pode pular um do meio: para passar o terceiro opcional, precisa passar o segundo.

**3. Nomeados** — entre chaves `{ }`. A ordem **não** importa e o nome aparece na chamada.

```dart
String agendar({required String materia, required int minutos, String? observacao}) { ... }

agendar(materia: 'Dart', minutos: 90);
agendar(minutos: 45, materia: 'Flutter', observacao: 'widgets');   // ordem livre
```

Regras dos nomeados:

- Por padrão são **opcionais**. Para torná-los obrigatórios, use `required`.
- Se não são obrigatórios, precisam de um valor padrão **ou** de tipo anulável.
- O valor padrão precisa ser uma **constante de tempo de compilação** (`25`, `'Dart'`, `const []`).
  `DateTime.now()` como padrão não compila.

```dart
String planejar({String materia = 'Dart', int minutos = 25, bool revisao = false}) { ... }
```

**Quando usar cada um?** A regra prática: até **dois** parâmetros claros, posicional. A partir do
terceiro, ou quando há `bool` na lista, use nomeados. Ninguém entende `registrar('Dart', 45, true, false)`
sem abrir a documentação; `registrar(materia: 'Dart', minutos: 45, revisao: true, silencioso: false)`
se explica sozinho. O Flutter levou essa ideia ao extremo — quase todo parâmetro de widget é nomeado.

> ⚠️ Você **não** pode misturar posicionais opcionais `[ ]` e nomeados `{ }` na mesma função.
> Escolha um dos dois. Na prática, prefira os nomeados.

### Arrow functions

Quando o corpo é **uma única expressão**, `=>` substitui as chaves e o `return`:

```dart
int dobro(int valor) => valor * 2;

// Idêntico a:
int dobro(int valor) {
  return valor * 2;
}
```

`=>` só aceita **uma expressão**. Se precisar de `if` com bloco, laço ou várias instruções, use
chaves. (Um `switch` expression é uma expressão, então cabe: veja `classificar` na
[Aula 6](06-controle-de-fluxo.md).)

### Funções anônimas

Uma função **sem nome**, criada na hora:

```dart
final rotulos = minutos.map((int m) => m >= 90 ? 'longa' : 'curta').toList();

// Com corpo em bloco:
minutos.map((int m) {
  final String nivel = m >= 90 ? 'longa' : 'curta';
  return '$m min ($nivel)';
});
```

Os tipos dos parâmetros podem ser omitidos quando o Dart consegue inferir:
`minutos.map((m) => m * 2)`.

### Função é um valor

Em Dart, funções são **objetos de primeira classe**: podem ser guardadas em variáveis, passadas
como argumento e devolvidas por outra função.

O tipo de uma função se escreve `Retorno Function(Tipos...)`:

```dart
int Function(int) dobrar = (int v) => v * 2;
void Function(String) imprimir = print;      // tear-off
String? Function(String) validador = validarNaoVazio;
```

> **Tear-off** — usar o **nome** de uma função existente como valor, sem parênteses e sem
> reembrulhar em uma função anônima. `list.forEach(print)` é melhor do que
> `list.forEach((x) => print(x))`.

### `typedef` — dando nome a um tipo de função

```dart
typedef Validador = String? Function(String entrada);
```

Agora `Validador` é um apelido legível. Em vez de repetir `String? Function(String)` por todo
lado, você escreve `Validador`:

```dart
String? primeiroErro(String entrada, List<Validador> validadores) { ... }
```

`typedef` não cria um tipo novo — é só um nome mais curto para o mesmo tipo. O ganho é
documentação: `List<Validador>` diz o que aquilo significa; `List<String? Function(String)>` não.

### Closures

Uma **closure** é uma função que **captura** variáveis do escopo onde foi criada, e continua
enxergando essas variáveis mesmo depois que aquele escopo terminou.

```dart
int Function() criarContador() {
  int contagem = 0;          // vive fora da função interna...
  return () {
    contagem++;              // ...mas continua acessível por ela
    return contagem;
  };
}

final contar = criarContador();
print(contar());   // 1
print(contar());   // 2
print(contar());   // 3
```

Cada chamada de `criarContador()` cria um `contagem` **novo e independente**. Duas closures
criadas separadamente não compartilham estado.

Closures são o mecanismo por trás de praticamente todo *callback* que você vai escrever.

### Callbacks

Um **callback** é uma função que você entrega a outra função, para ser chamada quando algo
acontecer. É a base da programação orientada a eventos — e, portanto, de qualquer interface.

```dart
void processar(
  List<int> valores, {
  required void Function(int) aoAceitar,
  required void Function(int, String) aoRejeitar,
}) {
  for (final int v in valores) {
    if (v <= 0) {
      aoRejeitar(v, 'precisa ser positivo');
    } else {
      aoAceitar(v);
    }
  }
}
```

Quem chama decide **o que fazer**; a função `processar` decide **quando fazer**.

## 💡 Analogia

Um parâmetro **posicional** é um pedido em uma máquina de café por número: você aperta 1, 3, 2 e
espera ter decorado a ordem. Um parâmetro **nomeado** é o pedido no balcão: "café, sem açúcar,
com leite" — a ordem é livre e ninguém precisa decorar nada.

Uma **closure** é um funcionário que leva uma **anotação no bolso**. Ele sai da sala onde a
anotação foi escrita, mas continua com ela. Dois funcionários diferentes saem com anotações
diferentes, e o que um rabisca não altera o papel do outro.

Um **callback** é deixar o seu telefone: "quando a encomenda chegar, me ligue neste número".
A loja não sabe o que você vai fazer com a notícia; ela só sabe **quando** ligar.

## 🧪 Exemplo mínimo

```dart
// Nomeados obrigatórios + arrow function
String resumo({required String materia, required int minutos}) =>
    '$materia estudada por $minutos min';

void main() {
  print(resumo(materia: 'Dart', minutos: 45));
  print(resumo(minutos: 90, materia: 'Flutter')); // ordem livre

  // Função anônima passada como argumento
  final dobrados = <int>[10, 20, 30].map((m) => m * 2).toList();
  print(dobrados);
}
```

```text
Dart estudada por 45 min
Flutter estudada por 90 min
[20, 40, 60]
```

## 📱 Aplicando no Flutter

Esta aula é a que mais se parece com o Flutter de verdade. Três pontes diretas:

**1. Todo widget é construído com parâmetros nomeados.**

```dart
// prévia do módulo 06
ElevatedButton(
  onPressed: () => print('clicou'),
  child: const Text('Salvar'),
)
```

`onPressed` e `child` são parâmetros nomeados. E `onPressed` recebe uma **função anônima** —
exatamente o que você acabou de aprender.

**2. `onPressed` é um callback.**
O botão não sabe o que acontece quando alguém toca nele. Ele guarda a sua função e chama quando
o toque ocorre. Você vai ver isso em
[06 — Gestos e feedback](../06-widgets-e-layouts/10-gestos-e-feedback.md).

**3. Validador de formulário é literalmente o `typedef` desta aula.**
No módulo 07, o `TextFormField` recebe:

```dart
validator: (valor) {
  if (valor == null || valor.trim().isEmpty) return 'Informe a matéria';
  return null;
}
```

O tipo esperado é `String? Function(String?)` — a mesma ideia do seu `typedef Validador`.
Devolver `null` significa "está válido". Detalhado em
[07 — Validação, foco e teclado](../07-navegacao-e-formularios/07-validacao-foco-teclado.md).

**4. Closures aparecem em `setState`.**

```dart
// prévia do módulo 05
setState(() {
  contador++;
});
```

`setState` recebe uma função anônima que captura `contador` do escopo de fora — uma closure.
Tema de [05 — StatefulWidget e setState](../05-introducao-ao-flutter/05-statefulwidget-e-setstate.md).

## 💻 Código completo

> **Arquivo:** `dart_basico/bin/funcoes.dart`
> **Como executar:** `dart run bin/funcoes.dart`

```dart
// bin/funcoes.dart
// Demonstra: parâmetros posicionais, opcionais, nomeados, required,
// arrow, anônimas, closures, funções como valor, typedef e callbacks.

/// Assinatura de um validador de texto.
///
/// Devolve a mensagem de erro, ou `null` quando a entrada é válida.
typedef Validador = String? Function(String entrada);

/// 1. Parâmetros posicionais obrigatórios.
String formatar(String materia, int minutos) => '$materia: $minutos min';

/// 2. Parâmetro posicional opcional com valor padrão.
String registrar(String materia, [int minutos = 25]) => '$materia por $minutos min';

/// 3. Parâmetros nomeados, todos com valor padrão.
String planejar({
  String materia = 'Dart',
  int minutos = 25,
  bool revisao = false,
}) =>
    '$materia | $minutos min | ${revisao ? 'revisão' : 'novo conteúdo'}';

/// 4. Parâmetros nomeados obrigatórios e um opcional anulável.
String agendar({
  required String materia,
  required int minutos,
  String? observacao,
}) {
  final String obs = observacao ?? 'sem observação';
  return '$materia | $minutos min | $obs';
}

/// 5. Arrow function.
int dobro(int valor) => valor * 2;

/// Formata os minutos alinhados à direita, em três colunas.
String formatarMinutos(int minutos) => '${minutos.toString().padLeft(3)} min';

/// Validador: recusa entrada vazia.
String? validarNaoVazio(String entrada) =>
    entrada.trim().isEmpty ? 'Não pode ficar vazio' : null;

/// Validador: recusa entrada que não seja inteiro.
String? validarNumero(String entrada) =>
    int.tryParse(entrada.trim()) == null ? 'Digite um número inteiro' : null;

/// Aplica os [validadores] em ordem e devolve o primeiro erro encontrado.
String? primeiroErro(String entrada, List<Validador> validadores) {
  for (final Validador validar in validadores) {
    final String? erro = validar(entrada);
    if (erro != null) return erro;
  }
  return null;
}

/// Closure: devolve uma função que conta quantas vezes foi chamada.
int Function() criarContadorDeSessoes() {
  int total = 0;
  return () {
    total++;
    return total;
  };
}

/// Closure que captura o parâmetro [fator].
int Function(int) multiplicadorPor(int fator) => (int valor) => valor * fator;

/// Recebe callbacks e decide QUANDO chamá-los.
void processarSessoes(
  List<int> sessoes, {
  required void Function(int minutos) aoAceitar,
  required void Function(int minutos, String motivo) aoRejeitar,
}) {
  for (final int minutos in sessoes) {
    if (minutos <= 0) {
      aoRejeitar(minutos, 'duração precisa ser positiva');
    } else if (minutos > 240) {
      aoRejeitar(minutos, 'acima do limite de 240 min');
    } else {
      aoAceitar(minutos);
    }
  }
}

/// Devolve dois valores de uma vez, em um record.
(int, double) resumir(List<int> valores) {
  if (valores.isEmpty) return (0, 0.0);
  int soma = 0;
  for (final int valor in valores) {
    soma += valor;
  }
  return (soma, soma / valores.length);
}

void main() {
  const List<int> sessoes = <int>[45, 0, 120, 300, 30];

  print('=== 1. Posicionais obrigatórios ===');
  print(formatar('Dart', 45));

  print('');
  print('=== 2. Posicional opcional com padrão ===');
  print(registrar('Flutter'));
  print(registrar('Git', 50));

  print('');
  print('=== 3. Nomeados com valor padrão ===');
  print(planejar());
  print(planejar(materia: 'Flutter', minutos: 60));
  print(planejar(revisao: true, materia: 'Git'));

  print('');
  print('=== 4. Nomeados obrigatórios (required) ===');
  print(agendar(materia: 'Dart', minutos: 90));
  print(agendar(minutos: 45, materia: 'Flutter', observacao: 'widgets'));

  print('');
  print('=== 5. Arrow function ===');
  print('dobro(21) = ${dobro(21)}');

  print('');
  print('=== 6. Funções anônimas ===');
  final List<String> rotulos =
      sessoes.map((int m) => m >= 90 ? 'longa' : 'curta').toList();
  print('rótulos: $rotulos');

  // Tear-off: referencia a função pelo nome, sem parênteses.
  final String Function(int) formatarMin = formatarMinutos;
  print('guardada em variável: "${formatarMin(45)}"');

  print('');
  print('=== 7. typedef e funções como valor ===');
  const List<Validador> validadores = <Validador>[
    validarNaoVazio,
    validarNumero,
  ];
  for (final String entrada in <String>['', '  ', 'abc', '45']) {
    final String? erro = primeiroErro(entrada, validadores);
    print('"$entrada" -> ${erro ?? 'válido'}');
  }

  print('');
  print('=== 8. Closures ===');
  final int Function() contar = criarContadorDeSessoes();
  print('contar() = ${contar()}');
  print('contar() = ${contar()}');
  print('contar() = ${contar()}');
  final int Function() outroContador = criarContadorDeSessoes();
  print('outroContador() = ${outroContador()}  (estado independente)');

  final int Function(int) triplicar = multiplicadorPor(3);
  print('triplicar(15) = ${triplicar(15)}');

  print('');
  print('=== 9. Callbacks ===');
  processarSessoes(
    sessoes,
    aoAceitar: (int m) => print('  aceita   : $m min'),
    aoRejeitar: (int m, String motivo) => print('  rejeitada: $m min ($motivo)'),
  );

  print('');
  print('=== 10. Devolvendo dois valores ===');
  final (total, media) = resumir(sessoes);
  print('total = $total min, média = ${media.toStringAsFixed(1)} min');
}
```

Saída esperada:

```text
=== 1. Posicionais obrigatórios ===
Dart: 45 min

=== 2. Posicional opcional com padrão ===
Flutter por 25 min
Git por 50 min

=== 3. Nomeados com valor padrão ===
Dart | 25 min | novo conteúdo
Flutter | 60 min | novo conteúdo
Git | 25 min | revisão

=== 4. Nomeados obrigatórios (required) ===
Dart | 90 min | sem observação
Flutter | 45 min | widgets

=== 5. Arrow function ===
dobro(21) = 42

=== 6. Funções anônimas ===
rótulos: [curta, curta, longa, longa, curta]
guardada em variável: " 45 min"

=== 7. typedef e funções como valor ===
"" -> Não pode ficar vazio
"  " -> Não pode ficar vazio
"abc" -> Digite um número inteiro
"45" -> válido

=== 8. Closures ===
contar() = 1
contar() = 2
contar() = 3
outroContador() = 1  (estado independente)
triplicar(15) = 45

=== 9. Callbacks ===
  aceita   : 45 min
  rejeitada: 0 min (duração precisa ser positiva)
  aceita   : 120 min
  rejeitada: 300 min (acima do limite de 240 min)
  aceita   : 30 min

=== 10. Devolvendo dois valores ===
total = 495 min, média = 99.0 min
```

## 🔍 Explicando o código

**`typedef Validador = String? Function(String entrada);`**
Cria o apelido. O nome do parâmetro (`entrada`) na assinatura serve só como documentação — quem
implementar pode chamar como quiser.

**`String registrar(String materia, [int minutos = 25])`**
Os colchetes marcam o trecho opcional. `minutos` tem valor padrão, então não precisa ser anulável.
Se você escrevesse `[int minutos]` sem padrão, o Dart recusaria: um `int` não pode ser `null`.

**`bool revisao = false` em `planejar`**
Parâmetro booleano com padrão. Repare que na chamada `planejar(revisao: true, materia: 'Git')` a
ordem é invertida e tudo funciona — essa é a vantagem dos nomeados.

**`required String materia`**
`required` é uma palavra do próprio Dart (desde a versão 2.12). Sem ela, o parâmetro nomeado
seria opcional e precisaria de padrão ou de tipo anulável.

**`final String obs = observacao ?? 'sem observação';`**
Padrão de nulo da [Aula 5](05-null-safety.md), aplicado a um parâmetro opcional.

**`sessoes.map((int m) => m >= 90 ? 'longa' : 'curta').toList()`**
`map` percorre a lista aplicando a função anônima e devolve uma sequência preguiçosa; `toList()`
materializa. `map` é detalhado na [Aula 8](08-listas.md).

**`final String Function(int) formatarMin = formatarMinutos;`**
Aqui o **tipo** é `String Function(int)` — uma função que recebe `int` e devolve `String`. A
variável guarda a função, e `formatarMin(45)` a executa. Usamos um *tear-off* (o nome sem
parênteses) em vez de uma função anônima: o analisador cobra isso com o lint
`prefer_function_declarations_over_variables` quando você atribui uma função anônima a uma
variável que poderia ser simplesmente uma função declarada.

**`const List<Validador> validadores = <Validador>[validarNaoVazio, validarNumero];`**
A referência ao nome de uma função de topo é uma constante de tempo de compilação, então a lista
inteira pode ser `const`. Repare: **sem parênteses**. Com parênteses (`validarNaoVazio('x')`) você
estaria chamando a função, não referenciando.

**`int Function() criarContadorDeSessoes() { int total = 0; return () { ... }; }`**
`total` é uma variável local de `criarContadorDeSessoes`. Normalmente ela morreria quando a
função terminasse; como a função devolvida a **captura**, ela sobrevive. É isso que faz
`contar()` devolver 1, 2, 3. E `outroContador()` devolve 1 porque a segunda chamada de
`criarContadorDeSessoes()` criou um `total` novo.

**`int Function(int) multiplicadorPor(int fator) => (int valor) => valor * fator;`**
Duas setas na mesma linha: a primeira é o corpo de `multiplicadorPor`, a segunda é o corpo da
função devolvida. O `fator` fica capturado.

**`required void Function(int minutos) aoAceitar`**
Um parâmetro cujo tipo é uma função. Quem chama fornece o comportamento; `processarSessoes`
fornece o momento. Esse é o desenho de `onPressed`, `onChanged`, `validator` e praticamente
todo evento do Flutter.

**`(int, double) resumir(List<int> valores)`**
O tipo de retorno é um **record** — um par anônimo. `final (total, media) = resumir(sessoes);`
desmonta o par em duas variáveis. Records são o tema de
[04 — Records](../04-dart-avancado/04-records.md); esta é só uma prévia útil.

**`soma / valores.length`**
Divisão com `/` devolve `double`, que é o que o record espera na segunda posição.

## ⚠️ Erros comuns

**1. Esquecer `required` em parâmetro nomeado sem padrão**

```text
Error: The parameter 'materia' can't have a value of 'null' because of its type 'String',
but the implicit default value is 'null'.
```

Acrescente `required` ou dê um valor padrão.

**2. Valor padrão que não é constante**

```dart
void registrar({DateTime quando = DateTime.now()}) { }
```

```text
Error: Constant evaluation error: The method 'DateTime.now' can't be used as a constant.
```

Solução: use `DateTime? quando` e, dentro da função, `final momento = quando ?? DateTime.now();`.

**3. Misturar `[ ]` e `{ }` na mesma função**

```text
Error: Can't have both optional positional parameters and named parameters.
```

**4. Usar `=>` com mais de uma instrução**

```dart
int dobro(int v) => { final r = v * 2; return r; };   // não compila
```

`=>` aceita **uma expressão**. Para várias instruções, use chaves e `return`.

**5. Chamar a função quando queria referenciá-la**

```dart
final Validador v = validarNaoVazio();   // ERRO: está chamando
final Validador v = validarNaoVazio;     // certo: está referenciando
```

**6. Achar que closures compartilham estado**
Cada chamada da função-fábrica cria variáveis novas. `criarContador()` chamado duas vezes
produz dois contadores independentes. Se você quer estado compartilhado, capture uma variável
declarada **fora** da fábrica.

**7. Closure capturando a variável do laço clássico**

```dart
final List<void Function()> acoes = <void Function()>[];
for (int i = 0; i < 3; i++) {
  acoes.add(() => print(i));
}
```

Em Dart isso funciona como você espera (imprime 0, 1, 2), porque cada iteração do `for` cria uma
nova ligação de `i`. Se você veio de JavaScript com `var`, esse é um comportamento **diferente**
do que você conhecia — e melhor.

**8. Parâmetros demais**
Uma função com seis parâmetros posicionais é ilegível. Converta para nomeados; se ainda assim
ficar grande, é sinal de que ela faz coisas demais e deveria ser dividida.

## 🛠️ Exercício guiado

**Passo 1.** Crie `bin/funcoes.dart` e digite o código completo.

**Passo 2.** Rode:

```powershell
dart run bin/funcoes.dart
```

**Passo 3 — remova um `required`.** Em `agendar`, apague o `required` de `materia` e rode. Leia
o erro sobre valor padrão implícito `null`. Restaure.

**Passo 4 — tente um padrão não constante.** Acrescente a `planejar` o parâmetro
`DateTime quando = DateTime.now()`. Leia o erro de constante e desfaça.

**Passo 5 — prove a independência das closures.** Chame `contar()` mais duas vezes **depois** de
criar `outroContador`, e chame `outroContador()` mais uma vez. Confirme que uma sequência
continua em 4, 5 enquanto a outra vai para 2.

**Passo 6 — troque um callback.** Chame `processarSessoes` uma segunda vez, agora acumulando em
vez de imprimir:

```dart
int aceitas = 0;
int rejeitadas = 0;
processarSessoes(
  sessoes,
  aoAceitar: (int m) => aceitas++,
  aoRejeitar: (int m, String motivo) => rejeitadas++,
);
print('aceitas: $aceitas | rejeitadas: $rejeitadas');
```

Deve imprimir `aceitas: 3 | rejeitadas: 2`. Note que as funções anônimas capturam `aceitas` e
`rejeitadas` do `main` — closures outra vez.

**Passo 7 — adicione um validador.** Crie
`String? validarLimite(String entrada)` que recuse números maiores que 240, e acrescente-o à
lista `validadores`. Teste com `'300'`.

**Passo 8.** Rode `dart format .` e `dart analyze`.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md)

Faça os de **Implementação** desta seção: eles pedem funções com parâmetros nomeados e callbacks.

## 🏆 Desafio opcional

Escreva `bin/pipeline.dart` com um mini sistema de transformação de texto:

1. Defina `typedef Transformacao = String Function(String texto);`.
2. Crie quatro transformações: `semAcentos`, `minusculas`, `semEspacosDuplos` e `comLimite30`
   (corta em 30 caracteres, acrescentando `...` se cortou).
3. Escreva `String aplicar(String texto, List<Transformacao> etapas)` que aplique cada etapa na
   ordem, usando `fold` ou um `for-in`.
4. Escreva uma função-fábrica `Transformacao prefixarCom(String prefixo)` que devolva uma closure.
5. No `main`, monte um *pipeline* com as cinco transformações e mostre o antes e o depois de
   `'   TÍTULO   Muito   Longo De Uma Matéria De Estudo Que Passa Do Limite  '`.

Dica para `semAcentos`: crie um `Map<String, String>` de substituições e use `replaceAll` em um
laço. `Map` é a [Aula 9](09-sets-e-maps.md) — se preferir, resolva com `replaceAll` encadeado.

## 📌 Resumo

- Parâmetros **posicionais obrigatórios** dependem da ordem; **posicionais opcionais** ficam em
  `[ ]`; **nomeados** ficam em `{ }` e podem vir em qualquer ordem.
- Nomeados são opcionais por padrão; `required` os torna obrigatórios.
- Valor padrão precisa ser constante de tempo de compilação.
- Não se pode misturar `[ ]` e `{ }` na mesma função.
- `=>` cria uma função de uma expressão só.
- Funções anônimas são criadas na hora e passadas como argumento.
- Função é valor: pode ir para variável, parâmetro e retorno. O tipo é `Retorno Function(Args)`.
- *Tear-off* é referenciar a função pelo nome, sem parênteses.
- `typedef` dá nome legível a um tipo de função.
- **Closure** é uma função que captura variáveis do escopo em que nasceu; cada criação tem
  estado próprio.
- **Callback** é a função que você entrega para alguém chamar depois — a base dos eventos no Flutter.

## ☑️ Checklist de domínio

- [ ] Escrevo uma função com dois parâmetros nomeados obrigatórios sem consultar material.
- [ ] Sei quando escolher posicional e quando escolher nomeado.
- [ ] Sei por que `DateTime.now()` não pode ser valor padrão.
- [ ] Converto uma função de bloco em *arrow function* quando cabe.
- [ ] Escrevo o tipo de uma função (`int Function(String)`) sem errar.
- [ ] Já criei um `typedef` e usei em uma assinatura.
- [ ] Explico, com o exemplo do contador, o que uma closure captura.
- [ ] Escrevi uma função que recebe um callback e a chamei com função anônima.
- [ ] `bin/funcoes.dart` roda e passa em `dart analyze`.

## 📚 Referências oficiais

- [Dart — Functions](https://dart.dev/language/functions)
- [Dart — Effective Dart: Design (parâmetros)](https://dart.dev/effective-dart/design)
- [Dart — Typedefs](https://dart.dev/language/typedefs)
- [Dart — Callable objects](https://dart.dev/language/callable-objects)
- [Dart — Records](https://dart.dev/language/records)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Controle de fluxo](06-controle-de-fluxo.md) | [README](README.md) | [Listas](08-listas.md) |
