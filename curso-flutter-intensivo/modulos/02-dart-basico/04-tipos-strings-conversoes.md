# Aula 4 — Tipos, strings e conversões

> **Módulo:** 02 - Dart Básico · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Reconhecer os tipos primitivos do Dart: `int`, `double`, `num`, `String`, `bool`.
- Escrever texto com aspas simples, duplas, triplas e *raw strings*, e saber quando usar cada uma.
- Usar interpolação (`$variavel` e `${expressão}`) em vez de concatenar com `+`.
- Aplicar os métodos de `String` mais usados no dia a dia.
- Converter texto em número com `int.parse`, `int.tryParse`, `double.parse` e `num.parse` —
  e entender por que `tryParse` é quase sempre a escolha certa.
- Formatar números para exibição com `toStringAsFixed`.
- Entender por que `'😀'.length` devolve `2` e o que são *runes*.

## ✅ Pré-requisitos

- [Aula 3](03-var-final-const.md) concluída.
- Tipos de dados no conceito — [Módulo 01, Aula 5](../01-logica-e-fundamentos/05-tipos-de-dados.md).

## 📖 Conceito

### Os tipos numéricos

Dart tem dois tipos numéricos concretos — `int` (inteiro: `45`, `-3`) e `double` (com casas
decimais: `3.14`, `2.0`) — e um pai comum, `num`, que aceita os dois.

> **Supertipo** — um tipo mais geral que engloba outros. Toda variável `int` também é um `num`,
> mas nem todo `num` é um `int`.

```dart
int inteiro = 45;
double decimal = 4.5;
num qualquerNumero = 45;      // aceita int
qualquerNumero = 4.5;         // e depois aceita double

print(7 / 2);     // 3.5   — a barra SEMPRE devolve double
print(7 ~/ 2);    // 3     — divisão inteira
print(7 % 2);     // 1     — resto
print(2.0 == 2);  // true  — comparação numérica ignora o tipo
```

E a armadilha universal do ponto flutuante, que não é do Dart e sim do padrão IEEE 754 usado por
praticamente todas as linguagens:

```dart
print(0.1 + 0.2);          // 0.30000000000000004
print(0.1 + 0.2 == 0.3);   // false
```

Para dinheiro e notas, a regra profissional é **guardar em centavos, como `int`**, e só dividir
na hora de exibir.

O tipo `bool` tem só dois valores, `true` e `false`, e Dart **não** aceita número ou texto no
lugar de uma condição: `if (1)` não compila, `if (minutos > 0)` sim.

### Strings: quatro formas de escrever texto

```dart
final a = 'aspas simples';                   // forma preferida pelo guia oficial
final b = "aspas duplas";                    // igual; use quando o texto tem apóstrofo
final c = 'Ele disse: "vamos estudar"';      // aspas duplas dentro de simples
final d = "Não é o que você acha";           // apóstrofo dentro de duplas

final multi = '''
Primeira linha
Segunda linha
Terceira linha''';                            // aspas triplas: preserva quebras

final caminho = r'C:\Users\novo\teste.dart'; // raw string
```

> **Raw string** — texto cru. O `r` antes das aspas desliga todos os códigos de escape. Sem ele,
> `\n` viraria quebra de linha e `\t` viraria tabulação; com ele, `\n` são dois caracteres
> literais. É a forma correta de escrever caminhos do Windows e expressões regulares.

Os principais escapes quando você **não** usa `r`: `\n` (quebra de linha), `\t` (tabulação),
`\\` (uma barra invertida), `\'` (aspas simples dentro de aspas simples) e `\$` (um cifrão
literal — sem a barra, o Dart tentaria interpolar).

### Interpolação — o jeito Dart de montar texto

```dart
final nome = 'Lucas';
final minutos = 135;

print('Olá, $nome!');                                     // forma curta
print('Você estudou ${minutos ~/ 60}h${minutos % 60}min.'); // com expressão
print('Nome em maiúsculas: ${nome.toUpperCase()}');
```

Use `${...}` sempre que houver ponto, chamada de método, cálculo ou operador. Use `$nome` só
para um identificador simples. O lint `unnecessary_brace_in_string_interps` avisa quando as
chaves são supérfluas.

Concatenação com `+` também existe (`'Olá, ' + nome + '!'`), mas evite: é mais verbosa. Dois
literais vizinhos, por outro lado, se juntam sozinhos: `'Olá, ' 'mundo'` vira `'Olá, mundo'`.

Para montar texto dentro de um laço grande, use `StringBuffer` (`buffer.writeln('- $materia')`
e, no fim, `buffer.toString()`): cada `+` em `String` cria um objeto novo, e isso pesa.

Uma diferença em relação a Java: em Dart, `==` compara **conteúdo**, não endereço de memória.
`'dart' == 'dart'` é `true`, e não existe `.equals()`.

### Métodos de `String` que você vai usar sempre

| Método | O que faz | Exemplo → resultado |
|---|---|---|
| `.length` | quantidade de unidades de código | `'Dart'.length` → `4` |
| `.isEmpty` / `.isNotEmpty` | vazia ou não | `''.isEmpty` → `true` |
| `.trim()` | remove espaços das pontas | `'  oi  '.trim()` → `'oi'` |
| `.toUpperCase()` / `.toLowerCase()` | troca a caixa | `'dart'.toUpperCase()` → `'DART'` |
| `.contains(x)` / `.startsWith(x)` / `.endsWith(x)` | contém, começa ou termina com | `'main.dart'.endsWith('.dart')` → `true` |
| `.indexOf(x)` | posição da primeira ocorrência, ou `-1` | `'Dart'.indexOf('r')` → `2` |
| `.substring(i, j)` | pedaço de `i` até `j-1` | `'Flutter'.substring(0, 4)` → `'Flut'` |
| `.replaceAll(a, b)` | troca todas as ocorrências | `'a-b-c'.replaceAll('-', '/')` → `'a/b/c'` |
| `.split(x)` | quebra em lista | `'a,b,c'.split(',')` → `['a','b','c']` |
| `.padLeft(n, c)` / `.padRight(n, c)` | completa até `n` caracteres | `'5'.padLeft(2, '0')` → `'05'` |
| `.compareTo(outra)` | ordem alfabética: negativo, zero ou positivo | `'a'.compareTo('b')` → `-1` |

### Conversões: texto ⇄ número

**De número para texto** é sempre seguro: `135.toString()` devolve `'135'` e
`3.14159.toStringAsFixed(2)` devolve `'3.14'` (uma `String`, não um número).

**De texto para número** pode falhar, e aí está a decisão mais importante desta aula:

```dart
int.parse('135');        // 135
int.parse('abc');        // LANÇA FormatException e derruba o programa
int.tryParse('abc');     // null — não lança nada
```

| Função | Quando falha | Use quando |
|---|---|---|
| `int.parse(texto)` | lança `FormatException` | o texto vem do **seu próprio código** e você tem certeza |
| `int.tryParse(texto)` | devolve `null` | o texto vem de **fora**: teclado, arquivo, API |
| `double.parse` / `double.tryParse` | idem, para decimais | idem |
| `num.parse` / `num.tryParse` | idem, aceita ambos | quando tanto faz inteiro ou decimal |

Regra do curso: **todo texto digitado por uma pessoa passa por `tryParse`.** Sem exceção.

`int.parse` ainda aceita uma base numérica:

```dart
int.parse('ff', radix: 16);   // 255
```

### Runes e Unicode — por que `length` engana

Uma `String` em Dart é uma sequência de **unidades de código UTF-16** (blocos de 16 bits).
A maioria dos caracteres cabe em uma unidade; emojis e alguns símbolos precisam de **duas**.

> **Rune** — em Dart, um *code point* Unicode inteiro, independentemente de quantas unidades de
> código UTF-16 ele ocupa.

```dart
print('café'.length);         // 4
final emoji = '😀';
print(emoji.length);          // 2   ← surpresa
print(emoji.runes.length);    // 1
print(emoji.runes.first);     // 128512  (o número Unicode)
print(String.fromCharCode(128512));  // 😀
```

Isso importa quando você corta texto: `'😀ok'.substring(0, 1)` produz **meio emoji**, um
caractere inválido. Para contar e cortar do jeito que uma pessoa espera (respeitando emojis
compostos e bandeiras), existe o pacote `characters`, que já vem disponível em todo projeto
Flutter. Em Dart puro você precisaria adicioná-lo ao `pubspec.yaml`; neste módulo vamos ficar em
`runes`, que resolve os casos comuns.

## 💡 Analogia

Uma `String` é uma **fita de caixinhas**, não uma folha de papel. Cada caixinha guarda 16 bits.
Letras comuns ocupam uma caixinha; um emoji ocupa duas caixinhas **coladas**, que só fazem
sentido juntas. `length` conta caixinhas; `runes` conta desenhos.

Já `parse` × `tryParse` é a diferença entre **um porteiro que expulsa o prédio inteiro** quando
alguém chega sem crachá (`parse` derruba o programa) e **um porteiro que anota "não identificado"
e segue trabalhando** (`tryParse` devolve `null`).

## 🧪 Exemplo mínimo

```dart
void main() {
  const String entradaDoUsuario = '90';

  final int? minutos = int.tryParse(entradaDoUsuario);

  if (minutos == null) {
    print('Valor inválido: "$entradaDoUsuario"');
    return;
  }

  final double horas = minutos / 60;
  print('$minutos minutos = ${horas.toStringAsFixed(1)} h');
}
```

```text
90 minutos = 1.5 h
```

Troque `'90'` por `'noventa'` e rode de novo: o programa avisa e encerra, sem quebrar.

## 📱 Aplicando no Flutter

Praticamente toda tela de aplicativo é feita de texto convertido.

**1. Todo campo de formulário devolve `String`.**
No módulo 07 você vai usar `TextField` com um `TextEditingController`. O valor digitado chega
como `controller.text`, que é `String` — mesmo em um campo de "minutos". Converter com
`int.tryParse` e tratar o `null` é literalmente a validação do formulário:

```dart
// prévia do módulo 07 — você ainda não precisa entender tudo
final minutos = int.tryParse(controller.text);
if (minutos == null) {
  return 'Digite um número inteiro de minutos';
}
```

Isso é detalhado em
[07 — Validação, foco e teclado](../07-navegacao-e-formularios/07-validacao-foco-teclado.md).

**2. Todo texto na tela nasce de uma `String` interpolada.**
O widget `Text` recebe uma `String`: `Text('${sessao.minutos} min · ${sessao.materia}')`.
Aparência, tamanho e fonte são o tema de
[06 — Texto, tipografia e ícones](../06-widgets-e-layouts/02-texto-tipografia-icones.md).

**3. Formatação e emoji.**
`toStringAsFixed(2)` devolve `3.14` com **ponto**, no padrão dos Estados Unidos; para exibir
`3,14` em português do Brasil, o curso usa o pacote `intl: ^0.20.2` a partir do projeto final.
E se você cortar um título com `substring` e partir um emoji ao meio, o celular mostra o
caractere `�` — o problema de `length` saindo do terminal e chegando ao usuário.

## 💻 Código completo

> **Arquivo:** `dart_basico/bin/textos.dart`
> **Como executar:** `dart run bin/textos.dart`

```dart
// bin/textos.dart
// Demonstra: tipos numéricos, formas de string, interpolação,
// métodos de String, conversões e runes.

/// Converte um texto de minutos em `int`, devolvendo `null` se for inválido.
///
/// Aceita espaços em volta e recusa valores negativos.
int? lerMinutos(String entrada) {
  final String limpo = entrada.trim();
  final int? valor = int.tryParse(limpo);
  if (valor == null || valor < 0) {
    return null;
  }
  return valor;
}

/// Formata [minutos] como `2h15` ou `45min`.
String formatarDuracao(int minutos) {
  final int horas = minutos ~/ 60;
  final int resto = minutos % 60;
  if (horas == 0) return '${resto}min';
  if (resto == 0) return '${horas}h';
  return '${horas}h${resto.toString().padLeft(2, '0')}';
}

void main() {
  print('=== 1. Tipos numéricos ===');
  const int inteiro = 135;
  const double decimal = 4.5;
  const num generico = 10;
  print('int    : $inteiro  (${inteiro.runtimeType})');
  print('double : $decimal  (${decimal.runtimeType})');
  print('num    : $generico  (${generico.runtimeType})');
  print('7 / 2 = ${7 / 2}  |  7 ~/ 2 = ${7 ~/ 2}  |  7 % 2 = ${7 % 2}');
  print('0.1 + 0.2 = ${0.1 + 0.2}  |  == 0.3 ? ${0.1 + 0.2 == 0.3}');

  print('');
  print('=== 2. Formas de escrever texto ===');
  const String duplas = "com 'apóstrofo' dentro";
  const String triplas = '''
Linha 1
Linha 2''';
  const String cru = r'C:\Users\novo\dart_basico\bin';
  const String comEscape = 'Coluna1\tColuna2\nValor\$ e barra \\';
  print(duplas);
  print(triplas);
  print('raw string: $cru');
  print(comEscape);

  print('');
  print('=== 3. Interpolação ===');
  const String nome = 'Lucas';
  const int minutos = 135;
  print('Olá, $nome!');
  print('Estudou ${formatarDuracao(minutos)} hoje.');
  print('Nome em maiúsculas: ${nome.toUpperCase()}');
  print('Metade dos minutos: ${minutos / 2}');

  print('');
  print('=== 4. Métodos de String ===');
  const String bruto = '   Flutter Intensivo   ';
  print('original    : "$bruto"');
  print('trim        : "${bruto.trim()}"');
  print('length      : ${bruto.trim().length}');
  print('toUpperCase : ${bruto.trim().toUpperCase()}');
  print('indexOf "I" : ${bruto.trim().indexOf('I')}');
  print('substring   : ${bruto.trim().substring(0, 7)}');
  print('replaceAll  : ${bruto.trim().replaceAll(' ', '-')}');
  print('split       : ${bruto.trim().split(' ')}');
  print('igualdade   : ${'dart' == 'dart'}');

  print('');
  print('=== 5. StringBuffer ===');
  final StringBuffer buffer = StringBuffer();
  buffer.writeln('Plano da semana:');
  for (final String materia in <String>['Dart', 'Flutter', 'Git']) {
    buffer.writeln('  - $materia');
  }
  buffer.write('Fim.');
  print(buffer.toString());

  print('');
  print('=== 6. Número para texto ===');
  const double media = 3.14159;
  print('toStringAsFixed(2) : ${media.toStringAsFixed(2)}');
  print('padLeft em número  : ${minutos.toString().padLeft(5, '0')}');

  print('');
  print('=== 7. Texto para número (o ponto crítico) ===');
  const List<String> entradas = <String>['135', ' 90 ', 'abc', '', '-20', '4.5'];
  for (final String entrada in entradas) {
    final int? resultado = lerMinutos(entrada);
    if (resultado == null) {
      print('"$entrada" -> inválido');
    } else {
      print('"$entrada" -> $resultado min (${formatarDuracao(resultado)})');
    }
  }

  print('');
  print('=== 8. double e num ===');
  print('double.tryParse("4.5") : ${double.tryParse('4.5')}');
  print('double.tryParse("abc") : ${double.tryParse('abc')}');
  print('num.tryParse("10.5")   : ${num.tryParse('10.5')}');
  print('int.parse("ff", 16)    : ${int.parse('ff', radix: 16)}');

  print('');
  print('=== 9. parse derruba o programa ===');
  try {
    final int valor = int.parse('abc');
    print('nunca chega aqui: $valor');
  } on FormatException catch (erro) {
    print('FormatException capturada: ${erro.message}');
  }

  print('');
  print('=== 10. Runes e Unicode ===');
  const String texto = 'café';
  const String emoji = '😀';
  print('"$texto": length = ${texto.length}, runes = ${texto.runes.length}');
  print('"$emoji": length = ${emoji.length}, runes = ${emoji.runes.length}');
  print('código do emoji = ${emoji.runes.first}');
  print('remontado       = ${String.fromCharCode(emoji.runes.first)}');
  print('runes de "$texto" = ${texto.runes.toList()}');
}
```

Saída esperada:

```text
=== 1. Tipos numéricos ===
int    : 135  (int)
double : 4.5  (double)
num    : 10  (int)
7 / 2 = 3.5  |  7 ~/ 2 = 3  |  7 % 2 = 1
0.1 + 0.2 = 0.30000000000000004  |  == 0.3 ? false

=== 2. Formas de escrever texto ===
com 'apóstrofo' dentro
Linha 1
Linha 2
raw string: C:\Users\novo\dart_basico\bin
Coluna1	Coluna2
Valor$ e barra \

=== 3. Interpolação ===
Olá, Lucas!
Estudou 2h15 hoje.
Nome em maiúsculas: LUCAS
Metade dos minutos: 67.5

=== 4. Métodos de String ===
original    : "   Flutter Intensivo   "
trim        : "Flutter Intensivo"
length      : 17
toUpperCase : FLUTTER INTENSIVO
indexOf "I" : 8
substring   : Flutter
replaceAll  : Flutter-Intensivo
split       : [Flutter, Intensivo]
igualdade   : true

=== 5. StringBuffer ===
Plano da semana:
  - Dart
  - Flutter
  - Git
Fim.

=== 6. Número para texto ===
toStringAsFixed(2) : 3.14
padLeft em número  : 00135

=== 7. Texto para número (o ponto crítico) ===
"135" -> 135 min (2h15)
" 90 " -> 90 min (1h30)
"abc" -> inválido
"" -> inválido
"-20" -> inválido
"4.5" -> inválido

=== 8. double e num ===
double.tryParse("4.5") : 4.5
double.tryParse("abc") : null
num.tryParse("10.5")   : 10.5
int.parse("ff", 16)    : 255

=== 9. parse derruba o programa ===
FormatException capturada: Invalid radix-10 number

=== 10. Runes e Unicode ===
"café": length = 4, runes = 4
"😀": length = 2, runes = 1
código do emoji = 128512
remontado       = 😀
runes de "café" = [99, 97, 102, 233]
```

## 🔍 Explicando o código

**`int? lerMinutos(String entrada)`**
O `?` depois de `int` significa "pode devolver um `int` **ou** `null`". Esse é o tipo anulável,
tema completo da [Aula 5](05-null-safety.md). Aqui ele é a forma honesta de dizer
"posso não conseguir converter".

**`entrada.trim()` antes de `int.tryParse`**
`int.tryParse(' 90 ')` devolveria `null`, porque o espaço não faz parte de um número. Limpar
antes de converter é obrigatório com texto vindo de teclado — foi exatamente isso que fez
`" 90 "` funcionar na saída.

**`if (valor == null || valor < 0) return null;`**
Duas regras em uma: recusa o que não é número e recusa número negativo. O operador `||` é
"ou"; ele tem **avaliação em curto-circuito**, isto é, se `valor == null` já for verdadeiro, a
segunda parte nem é avaliada — o que evita comparar `null < 0` e quebrar.

**`if (horas == 0) return '${resto}min';`**
Note as chaves em `${resto}min`: sem elas, o Dart tentaria ler a variável `restomin`, que não
existe. Sempre que o texto continua com letra logo depois da variável, as chaves são obrigatórias.

**`const String cru = r'C:\Users\novo\dart_basico\bin';`**
Sem o `r`, `\n` viraria quebra de linha e o caminho apareceria partido. No mesmo espírito,
`\$` imprime um cifrão literal e `\\` imprime uma barra invertida.

**`const num generico = 10;` imprimindo `int`**
O tipo **estático** da variável é `num`, mas o objeto guardado é um `int`. `runtimeType` mostra
o tipo real do objeto, não o declarado.

**`StringBuffer` com `writeln` e `write`**
`writeln` acrescenta o texto e uma quebra de linha; `write` acrescenta sem quebra. Para 3 itens
a diferença é irrelevante; para 10 mil, é enorme.

**`erro.message` no `FormatException`**
A propriedade `message` traz só a explicação (`Invalid radix-10 number`), sem o texto-fonte e o
marcador `^` que apareceriam se você imprimisse o erro inteiro com `$erro`.

**`texto.runes.toList()` mostrando `[99, 97, 102, 233]`**
São os códigos Unicode de `c`, `a`, `f` e `é`. O `é` é o ponto 233, que cabe em uma unidade de
código — por isso `'café'.length` e `'café'.runes.length` coincidem. Com o emoji, não coincidem.

## ⚠️ Erros comuns

**1. Usar `int.parse` em texto digitado**

```text
Unhandled exception:
FormatException: Invalid radix-10 number (at character 1)
abc
^
```

O programa **morre**. No terminal isso é chato; em um app de celular, é o app fechando na cara
do usuário. Use `int.tryParse`.

**2. Esquecer o `trim()`**
`int.tryParse('90 ')` devolve `null`. O usuário digitou certo e o programa disse que está errado.

**3. Interpolar sem chaves quando precisa**
`'$minutosmin'` procura a variável `minutosmin`; o certo é `'${minutos}min'`. E `toStringAsFixed`
devolve **`String`**, não número: `3.14159.toStringAsFixed(2) + 1` não compila.

**4. Comparar `double` com `==`**

```dart
if (0.1 + 0.2 == 0.3) { }   // nunca entra
```

Compare com tolerância: `if ((soma - 0.3).abs() < 0.0001) { }`.

**5. Usar `\` em caminho do Windows sem `r`**
`'C:\novo\teste.dart'` transforma `\n` e `\t` em escapes. Escreva `r'C:\novo\teste.dart'`.
E cortar texto com emoji (`'😀ok'.substring(0, 1)`) devolve meio caractere: use `runes`.

**6. `substring` com índice maior que o texto**

```text
RangeError (end): Invalid value: Not in inclusive range 0..4: 10
```

Verifique `length` antes de cortar.

## 🛠️ Exercício guiado

**Passo 1.** Crie `bin/textos.dart` e digite o código completo.

**Passo 2.** Rode e compare a saída linha a linha com a esperada:

```powershell
dart run bin/textos.dart
```

**Passo 3 — sinta a diferença entre `parse` e `tryParse`.** Troque, dentro de `lerMinutos`:

```dart
final int? valor = int.tryParse(limpo);
```

por

```dart
final int? valor = int.parse(limpo);
```

Rode. O programa vai quebrar na entrada `'abc'` e você vai ver a `FormatException` real,
com o texto-fonte e o marcador `^`. Volte para `tryParse` depois.

**Passo 4 — remova o `trim()`.** Apague `.trim()` de `lerMinutos` e rode. A entrada `" 90 "`
passa a ser rejeitada. Recoloque.

**Passo 5 — brinque com runes.** Acrescente no fim do `main`:

```dart
const String bandeira = '🇧🇷';
print('${bandeira.length} / ${bandeira.runes.length}');
```

Você vai ver `4 / 2`: a bandeira do Brasil é formada por **dois** símbolos regionais (B e R),
cada um ocupando duas unidades de código. É o caso em que nem `runes` conta "um desenho".

**Passo 6.** Rode `dart format .` e `dart analyze`. Zero avisos.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md)

Faça os de **Aplicação** e **Correção de bugs** ligados a conversão de texto em número.

## 🏆 Desafio opcional

Escreva `bin/normalizador.dart` com uma função
`String? normalizarMateria(String entrada)` que:

1. Remova espaços das pontas.
2. Devolva `null` se, depois disso, o texto ficar vazio.
3. Devolva `null` se o texto tiver mais de 30 caracteres.
4. Coloque a **primeira letra maiúscula** e o restante minúsculo (`'  fLUTTER '` → `'Flutter'`).
5. Troque qualquer sequência de espaços internos por um espaço só
   (`'dart   avancado'` → `'Dart avancado'`).

Teste com a lista `['  dart ', '', '   ', 'fLUTTER', 'git   e   terminal', 'a' * 40]` e imprima
o resultado de cada uma, marcando as inválidas. Dica para o item 5:
`entrada.split(' ').where((p) => p.isNotEmpty).join(' ')` — `where` é da
[Aula 8](08-listas.md).

## 📌 Resumo

- `int`, `double` e o supertipo `num`; `/` devolve `double`, `~/` devolve `int`.
- `0.1 + 0.2 != 0.3` — ponto flutuante nunca é exato; para dinheiro, guarde centavos em `int`.
- Aspas simples são o padrão; triplas preservam quebras de linha; `r'...'` desliga os escapes.
- Interpolação: `$variavel` para nome simples, `${expressão}` para qualquer outra coisa.
- `==` em `String` compara conteúdo; `toStringAsFixed(n)` devolve `String`, não número.
- `int.parse` lança `FormatException`; `int.tryParse` devolve `null`. Texto vindo de fora →
  **sempre** `tryParse`, sempre depois de `trim()`.
- `length` conta unidades de código UTF-16; `runes` conta *code points*. Emojis ocupam dois.

## ☑️ Checklist de domínio

- [ ] Sei dizer o resultado de `7 / 2` e de `7 ~/ 2` sem rodar.
- [ ] Uso interpolação em vez de `+`, e sei quando `${...}` é obrigatório.
- [ ] Escrevo caminhos do Windows com *raw string*.
- [ ] Uso `trim()` antes de qualquer `tryParse`.
- [ ] Sei explicar por que `int.tryParse` é melhor que `int.parse` para entrada do usuário.
- [ ] Já vi, no meu terminal, `'😀'.length` devolver `2`.
- [ ] Sei formatar um `double` com duas casas usando `toStringAsFixed(2)`.
- [ ] `bin/textos.dart` roda e passa em `dart analyze`.

## 📚 Referências oficiais

- [Dart — Built-in types](https://dart.dev/language/built-in-types)
- [Dart — `String` class](https://api.dart.dev/dart-core/String-class.html)
- [Dart — `int` class](https://api.dart.dev/dart-core/int-class.html)
- [Dart — `num` class](https://api.dart.dev/dart-core/num-class.html)
- [Dart — `Runes` class](https://api.dart.dev/dart-core/Runes-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [`var`, `final`, `const` e `late`](03-var-final-const.md) | [README](README.md) | [Null safety](05-null-safety.md) |
