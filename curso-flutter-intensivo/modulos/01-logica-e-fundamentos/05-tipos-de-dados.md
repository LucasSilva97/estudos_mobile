# Aula 5 — Tipos de dados

> **Módulo:** 01 - Lógica e Fundamentos · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Explicar o que é um **tipo de dado** e por que ele existe.
- Usar `int`, `double`, `num`, `String` e `bool` corretamente.
- Explicar o que são `Object` e `dynamic` e por que `dynamic` é perigoso.
- Diferenciar **tipagem estática** de **tipagem dinâmica**, e **inferência** de "sem tipo".
- Converter número em texto com `toString` e `toStringAsFixed`.
- Converter texto em número com `parse` e, principalmente, com `tryParse`.
- Converter entre `int` e `double` com `toInt`, `toDouble`, `round`, `floor` e `ceil`.
- Testar o tipo de um valor em execução com `is`.

## ✅ Pré-requisitos

- [Aula 4 — Variáveis e constantes](04-variaveis-e-constantes.md): `var`, `final`, `const`.
- [Aula 3 — Algoritmos e decomposição](03-algoritmos-e-decomposicao.md): teste de mesa.
- Projeto `C:\src\pratica_dart` funcionando.

---

## 📖 Conceito

### 1. O que é um tipo

**Tipo de dado** é a classificação que diz **que espécie de valor** uma variável guarda e **que
operações** fazem sentido sobre ele.

`5 + 3` dá `8`. `'5' + '3'` dá `'53'`, porque somar textos significa juntá-los. E `5 + '3'` não
significa nada — é justamente por isso que o Dart recusa compilar essa linha. O tipo é o que
permite à linguagem saber a diferença.

### 2. Os tipos numéricos: `int`, `double`, `num`

```dart
int minutos = 240;      // inteiro: sem casas decimais
double nota = 8.75;     // ponto flutuante: com casas decimais
num qualquer = 95;      // aceita int OU double
```

- **`int`** guarda números inteiros (64 bits com sinal na VM do Dart).
- **`double`** guarda números de **ponto flutuante** de 64 bits (IEEE 754) — a técnica que
  representa números muito grandes e muito pequenos com um número fixo de bits, ao custo de
  **arredondamentos**.
- **`num`** é o tipo "pai" de `int` e `double`; prefira `int` ou `double` quando souber qual é.

```text
        num
       /   \
     int   double
```

> ⚠️ **A armadilha do ponto flutuante:** `0.1 + 0.2` não dá exatamente `0.3` em nenhuma linguagem
> que use IEEE 754 — o resultado é `0.30000000000000004`. Não é bug do Dart; é consequência de
> representar frações decimais em binário. Regra prática: **nunca guarde dinheiro em `double`**.
> Guarde centavos em `int`. No app `Foco` guardamos **minutos** em `int` pelo mesmo motivo.

### 3. `String`: texto

```dart
String materia = 'Dart';
String outra = "Flutter";   // aspas duplas também valem
```

Convenção do curso (e do `flutter_lints`): **aspas simples**. Recursos que ganham nome agora:

- **Interpolação**: `'Estudei $minutos minutos'` insere o valor da variável.
- **Expressão interpolada**: `'${nota.toStringAsFixed(1)}'`, para qualquer coisa além de um nome.
- **Concatenação**: `'a' + 'b'` produz `'ab'` — funciona, mas interpolação é mais legível.

Strings em Dart são **imutáveis**: `toUpperCase()` não altera o texto original, devolve um novo.

### 4. `bool`: verdadeiro ou falso

Só existem `true` e `false`. Diferentemente de JavaScript ou Python, **o Dart não aceita "valor que
parece verdadeiro"**: `if (1)` e `if ('texto')` não compilam. A condição precisa ser um `bool` de
verdade — o que elimina uma fonte enorme de bugs sutis (veja a [Aula 7](07-condicoes.md)).

### 5. `Object` e `dynamic`

**`Object`** é o tipo-raiz: toda coisa não nula em Dart é um `Object`. Uma variável `Object` aceita
qualquer valor, mas você **só pode chamar nela o que todo objeto tem** (`toString()`, `hashCode`,
`runtimeType`). Para usar algo específico, é preciso verificar o tipo antes.

```dart
Object valor = 'texto';
print(valor.toString());  // permitido
// print(valor.length);   // NÃO compila: nem todo Object tem length
```

**`dynamic`** é diferente: ele **desliga a verificação de tipos**. O Dart aceita qualquer chamada
em tempo de compilação e só descobre o problema quando a linha executa.

```dart
dynamic solto = 'texto';
print(solto.length);   // 5 — funciona
solto = 10;
print(solto.length);   // COMPILA, mas EXPLODE em execução
```

O erro de execução seria:

```text
Unhandled exception:
NoSuchMethodError: Class 'int' has no instance getter 'length'.
```

> ⚠️ **Regra do curso:** use `dynamic` apenas quando não houver alternativa — basicamente ao
> receber JSON de uma API, no [Módulo 09](../09-consumo-de-api/README.md) — e mesmo lá saia de
> `dynamic` o mais rápido possível, convertendo para uma classe própria.

### 6. Tipagem estática × tipagem dinâmica

**Tipagem estática**: o tipo é verificado **antes** de o programa rodar (Dart, Java, Kotlin, Swift,
TypeScript). **Tipagem dinâmica**: o tipo só é conhecido na execução (Python, JavaScript).

| | Estática (Dart) | Dinâmica (Python) |
|---|---|---|
| Quando o erro de tipo aparece | ao compilar / ao digitar | ao executar aquela linha |
| Custo | escrever um pouco mais | descobrir tarde |
| Ferramenta | autocompletar preciso, refatoração segura | mais liberdade |

**Inferência de tipo** é o que faz o Dart parecer dinâmico sem ser:

```dart
var minutos = 240;      // o Dart deduz: int
minutos = 300;          // ok
minutos = 'trezentos';  // ERRO de compilação
```

`var` não é `dynamic`. `var` é "descubra o tipo para mim e fixe-o"; `dynamic` é "não verifique
nada". Confundir os dois é um dos erros mais comuns de quem vem de Python ou JavaScript.

**Por que tipagem importa?** O erro de tipo que aparece na sua tela ao digitar custa 5 segundos. O
mesmo erro descoberto pelo usuário depois da publicação custa uma atualização de emergência na
loja — que, na App Store, pode levar dias de revisão.

### 7. Conversão e *parsing*

**Conversão** é transformar um valor de um tipo em outro. **Parsing** (análise) é o caso específico
de transformar **texto** em outro tipo — o que acontece com tudo que o usuário digita, porque
teclado produz texto, nunca número.

```dart
// Número -> texto
240.toString();            // '240'
8.75.toStringAsFixed(2);   // '8.75'
8.75.toStringAsFixed(0);   // '9'   (arredonda!)

// Texto -> número
int.parse('180');          // 180
double.parse('2.5');       // 2.5
```

`parse` **lança uma exceção** se o texto não for um número válido:

```text
Unhandled exception:
FormatException: Invalid radix-10 number (at character 1)
```

Por isso existe `tryParse`, que devolve `null` em vez de explodir:

```dart
int? valor = int.tryParse('cento e oitenta');  // null
```

O `?` em `int?` significa "pode conter um `int` **ou** nulo" — é o *null safety* do Dart, com aula
própria em [`02-dart-basico/05-null-safety.md`](../02-dart-basico/05-null-safety.md).

> ✅ **Regra do curso:** para qualquer texto vindo de fora do programa (usuário, arquivo, API), use
> **`tryParse`**. `parse` só quando você mesmo escreveu o texto no código.

Entre `int` e `double`:

```dart
240.toDouble();   // 240.0
8.75.toInt();     // 8  — TRUNCA, não arredonda
8.75.round();     // 9  — mais próximo
8.75.floor();     // 8  — para baixo
8.75.ceil();      // 9  — para cima
```

Atenção ao caminho contrário: `double d = 42;` compila (o Dart converte o **literal**), mas
`int i = 42; double d = i;` **não** compila. Use `i.toDouble()`.

Por fim, `is` testa o tipo em execução e devolve um `bool`, o que o combina naturalmente com `if`:

```dart
print(240 is int);      // true
print(240 is num);      // true
print(240 is double);   // false
```

---

## 💡 Analogia

Pense em **recipientes de cozinha**: um **copo medidor** (`int`) só marca unidades inteiras; uma
**balança digital** (`double`) mostra casas decimais e, como toda balança, tem precisão limitada;
a **prateleira** (`num`) aceita os dois, porque ambos medem quantidade; uma **etiqueta escrita**
(`String`) guarda "duzentos e quarenta" — você não soma etiquetas, precisa ler e converter
(*parsing*); um **interruptor** (`bool`) só tem duas posições.

Uma **caixa fechada sem rótulo** (`Object`) guarda qualquer coisa, mas exige abrir e conferir antes
de usar; uma **caixa sem rótulo que ninguém confere** (`dynamic`) derruba a cozinha — você põe
açúcar achando que é sal e descobre quando o bolo sai do forno.

---

## 🧪 Exemplo mínimo

> Arquivo: `C:\src\pratica_dart\bin\aula05_minimo.dart`

```dart
void main() {
  const String digitadoPeloUsuario = '150';

  final int? minutos = int.tryParse(digitadoPeloUsuario);
  print('Texto original: $digitadoPeloUsuario (${digitadoPeloUsuario.runtimeType})');
  print('Convertido    : $minutos');

  final int? invalido = int.tryParse('cento e cinquenta');
  print('Entrada inválida vira: $invalido');
}
```

```powershell
dart run bin/aula05_minimo.dart
```

```text
Texto original: 150 (String)
Convertido    : 150
Entrada inválida vira: null
```

O ponto central: `'150'` e `150` parecem iguais na tela e são coisas diferentes na memória.

---

## 📱 Aplicando no Flutter

Tudo o que o usuário digita em um app chega como **`String`**; sem conversão segura, não há
formulário que funcione.

- O `TextField` e o `TextFormField` entregam o conteúdo como `String`. Converter com `tryParse` e
  tratar o `null` é exatamente o que você fará em
  [`07-navegacao-e-formularios/06-formularios.md`](../07-navegacao-e-formularios/06-formularios.md)
  e [`07-navegacao-e-formularios/07-validacao-foco-teclado.md`](../07-navegacao-e-formularios/07-validacao-foco-teclado.md).
  No app `Foco`, a meta semanal em minutos passa por esse caminho.
- Respostas de API chegam como JSON, que no Dart vira `Map<String, dynamic>` — o único lugar onde
  `dynamic` é inevitável. Transformá-lo em tipos seguros é o tema de
  [`09-consumo-de-api/02-json.md`](../09-consumo-de-api/02-json.md) e
  [`09-consumo-de-api/04-modelando-respostas-e-erros.md`](../09-consumo-de-api/04-modelando-respostas-e-erros.md).
- O `shared_preferences` guarda apenas tipos primitivos (`int`, `double`, `String`, `bool` e lista
  de `String`) — veja
  [`10-persistencia-de-dados/02-shared-preferences.md`](../10-persistencia-de-dados/02-shared-preferences.md).

Guarde esta frase: **teclado devolve texto; banco de dados guarda tipo; a conversão entre os dois é
sua responsabilidade.**

---

## 💻 Código completo

> **Arquivo:** `C:\src\pratica_dart\bin\aula05_tipos.dart`
> **Como executar:** `dart run bin/aula05_tipos.dart` (a partir de `C:\src\pratica_dart`)

```dart
// bin/aula05_tipos.dart
// Aula 5 — Tipos de dados: declaração, inspeção e conversão.

void main() {
  // ---------- 1) OS CINCO TIPOS DO DIA A DIA ----------
  const int minutosEstudados = 240;
  const double notaMedia = 8.75;
  const num pontuacao = 95;
  const String materia = 'Dart';
  const bool concluido = true;

  print('=== 1) TIPOS BÁSICOS ===');
  print('minutosEstudados = $minutosEstudados   tipo: ${minutosEstudados.runtimeType}');
  print('notaMedia        = $notaMedia   tipo: ${notaMedia.runtimeType}');
  print('pontuacao        = $pontuacao   tipo: ${pontuacao.runtimeType}');
  print('materia          = $materia   tipo: ${materia.runtimeType}');
  print('concluido        = $concluido   tipo: ${concluido.runtimeType}');
  print('');

  // ---------- 2) NÚMERO -> TEXTO ----------
  print('=== 2) NÚMERO PARA TEXTO ===');
  final String minutosComoTexto = minutosEstudados.toString();
  final String notaDuasCasas = notaMedia.toStringAsFixed(2);
  final String notaSemCasas = notaMedia.toStringAsFixed(0);

  print('toString()          -> "$minutosComoTexto" (${minutosComoTexto.runtimeType})');
  print('toStringAsFixed(2)  -> "$notaDuasCasas"');
  print('toStringAsFixed(0)  -> "$notaSemCasas"  (arredondou)');
  print('');

  // ---------- 3) TEXTO -> NÚMERO (parsing) ----------
  print('=== 3) TEXTO PARA NÚMERO ===');
  const String entradaValida = '180';
  const String entradaInvalida = 'cento e oitenta';

  final int comParse = int.parse(entradaValida);
  // O "?" diz: esta variável pode conter um int OU null.
  final int? tentativaValida = int.tryParse(entradaValida);
  final int? tentativaInvalida = int.tryParse(entradaInvalida);
  final double horasDecimais = double.parse('2.5');

  print('int.parse("180")                -> $comParse');
  print('int.tryParse("180")             -> $tentativaValida');
  print('int.tryParse("cento e oitenta") -> $tentativaInvalida');
  print('double.parse("2.5")             -> $horasDecimais');
  print('');

  // ---------- 4) int <-> double ----------
  print('=== 4) CONVERSÕES NUMÉRICAS ===');
  final double minutosComoDouble = minutosEstudados.toDouble();
  final int notaTruncada = notaMedia.toInt();
  final int notaArredondada = notaMedia.round();
  final int notaParaBaixo = notaMedia.floor();
  final int notaParaCima = notaMedia.ceil();

  print('240.toDouble()  -> $minutosComoDouble');
  print('8.75.toInt()    -> $notaTruncada   (corta a parte decimal)');
  print('8.75.round()    -> $notaArredondada   (mais próximo)');
  print('8.75.floor()    -> $notaParaBaixo   (para baixo)');
  print('8.75.ceil()     -> $notaParaCima   (para cima)');
  print('');

  // ---------- 5) TESTANDO O TIPO COM is ----------
  print('=== 5) VERIFICAÇÃO DE TIPO ===');
  print('minutosEstudados is int    -> ${minutosEstudados is int}');
  print('minutosEstudados is double -> ${minutosEstudados is double}');
  print('materia is String          -> ${materia is String}');
  print('');

  // ---------- 6) O PONTO FLUTUANTE NÃO É EXATO ----------
  print('=== 6) CUIDADO COM double ===');
  print('0.1 + 0.2 = ${0.1 + 0.2}');
  print('Por isso: minutos e centavos ficam em int.');
}
```

Saída esperada:

```text
=== 1) TIPOS BÁSICOS ===
minutosEstudados = 240   tipo: int
notaMedia        = 8.75   tipo: double
pontuacao        = 95   tipo: int
materia          = Dart   tipo: String
concluido        = true   tipo: bool

=== 2) NÚMERO PARA TEXTO ===
toString()          -> "240" (String)
toStringAsFixed(2)  -> "8.75"
toStringAsFixed(0)  -> "9"  (arredondou)

=== 3) TEXTO PARA NÚMERO ===
int.parse("180")                -> 180
int.tryParse("180")             -> 180
int.tryParse("cento e oitenta") -> null
double.parse("2.5")             -> 2.5

=== 4) CONVERSÕES NUMÉRICAS ===
240.toDouble()  -> 240.0
8.75.toInt()    -> 8   (corta a parte decimal)
8.75.round()    -> 9   (mais próximo)
8.75.floor()    -> 8   (para baixo)
8.75.ceil()     -> 9   (para cima)

=== 5) VERIFICAÇÃO DE TIPO ===
minutosEstudados is int    -> true
minutosEstudados is double -> false
materia is String          -> true

=== 6) CUIDADO COM double ===
0.1 + 0.2 = 0.30000000000000004
Por isso: minutos e centavos ficam em int.
```

---

## 🔍 Explicando o código

### `runtimeType` e o detalhe mais interessante da saída

`runtimeType` devolve o tipo que o valor **realmente tem durante a execução**. Repare:

```dart
const num pontuacao = 95;
print(pontuacao.runtimeType);  // int
```

A **variável** é declarada como `num` (o que o compilador sabe), mas o **valor** guardado é um
`int` (o que existe na memória). Tipo declarado e tipo em execução são coisas diferentes — e é
essa distinção que faz o `is` fazer sentido.

### `toStringAsFixed(0)` arredonda, `toInt()` trunca

`8.75.toStringAsFixed(0)` produz `"9"`, não `"8"`. Trocar um pelo outro é uma fonte silenciosa de
diferença de centavos em relatórios.

### `int?` e o valor `null`

```dart
final int? tentativaInvalida = int.tryParse('cento e oitenta');
```

`int?` é um tipo diferente de `int`: admite a ausência de valor. Ao interpolar um `null`, aparece
literalmente o texto `null` — o que, em um app de verdade, é um defeito visível para o usuário. A
[Aula 6](06-operadores.md) apresenta o operador `??`, que fornece um valor padrão, e a
[Aula 7](07-condicoes.md) mostra como decidir o que fazer.

### `0.1 + 0.2`

Não é curiosidade: é aviso. Se o app `Foco` guardasse tempo em horas decimais (`double`), somas
sucessivas acumulariam erro. Com **minutos inteiros** (`int`) a soma é exata; a conversão para
horas acontece só na exibição.

---

## ⚠️ Erros comuns

**1. Somar texto achando que soma número** — com `a = '10'` e `b = '5'`, `a + b` é `'105'`, não
`15`. Correção: `int.parse(a) + int.parse(b)`.

**2. Usar `parse` em texto do usuário** — se o usuário digitar algo não numérico, o app quebra com
`FormatException`. Use `tryParse` e trate o `null`.

**3. Guardar `/` em `int`**

```dart
final int media = 690 / 5;
```

```text
Error: A value of type 'double' can't be assigned to a variable of type 'int'.
```

Correção: declare `double`, ou use `~/` (Aula 6) para divisão inteira.

**4. Atribuir `int` a `double` via variável** — `int i = 42; double d = i;` não compila. Correção:
`double d = i.toDouble();`.

**5. Confundir `var` com `dynamic`** — `var` deduz e **fixa** o tipo; `dynamic` desliga a
verificação e transfere o erro para a execução.

**6. Esperar `if (1)` funcionar** — em Dart a condição precisa ser `bool`
(`Error: A value of type 'int' can't be assigned to a variable of type 'bool'.`).
Escreva `if (contador == 1)`.

**7. Guardar dinheiro em `double`** (erros de arredondamento acumulam) e **achar que `toInt()`
arredonda** (`8.9.toInt()` é `8`; para arredondar, `round()`).

---

## 🛠️ Exercício guiado

Você vai construir um **conversor de entrada de formulário** — o mesmo problema que aparecerá no
app `Foco`, só que sem tela.

**Passo 1.** Crie `bin/aula05_guiado.dart` com três entradas simulando o que um usuário digitaria:

```dart
void main() {
  const String metaDigitada = '750';
  const String estudadoDigitado = '690';
  const String notaDigitada = '8,5';   // repare: vírgula, como o brasileiro digita
}
```

**Passo 2.** Converta as duas primeiras com `tryParse` e imprima:

```dart
  final int? meta = int.tryParse(metaDigitada);
  final int? estudado = int.tryParse(estudadoDigitado);
  print('meta = $meta | estudado = $estudado');
```

**Passo 3.** Tente converter a nota **sem tratar a vírgula**:

```dart
  final double? nota = double.tryParse(notaDigitada);
  print('nota com vírgula = $nota');
```

Execute. A saída é `nota com vírgula = null`, porque o Dart espera **ponto** como separador
decimal. Esse é um dos bugs mais frequentes em apps brasileiros.

**Passo 4.** Conserte trocando a vírgula por ponto antes de converter:

```dart
  final String notaNormalizada = notaDigitada.replaceAll(',', '.');
  final double? notaCorrigida = double.tryParse(notaNormalizada);
  print('nota corrigida = $notaCorrigida');
```

`replaceAll(alvo, substituto)` devolve um **texto novo**: `String` é imutável.

**Passo 5.** Faça o teste de mesa e confira a saída completa:

```text
meta = 750 | estudado = 690
nota com vírgula = null
nota corrigida = 8.5
```

**Passo 6.** Acrescente uma linha com `notaCorrigida.runtimeType`: aparece `double`, não `double?`,
porque `runtimeType` mostra o tipo do **valor**. Chamar esse membro em variável anulável é
permitido, pois todo objeto o tem — se o valor fosse nulo, a saída seria `Null`.

**Passo 7.** Salve no Git:

```powershell
git add .
git commit -m "aula 05: tipos, parsing e a armadilha da virgula decimal"
```

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/01-logica-e-fundamentos.md](../../exercicios/01-logica-e-fundamentos.md)

Faça em especial os de **Leitura de código** (prever qual tipo o Dart infere) e os de **Correção de
bugs** (conversões erradas entre `String`, `int` e `double`).

---

## 🏆 Desafio opcional

Escreva `bin/aula05_desafio.dart`, um **normalizador de entradas de estudo** com quatro constantes
de texto, simulando dados de fontes diferentes:

```dart
const String origem1 = '120';        // limpo
const String origem2 = ' 90 ';       // com espaços
const String origem3 = '1,5';        // horas com vírgula
const String origem4 = 'duas horas'; // impossível de converter
```

Para cada origem: remova espaços com `trim()`, troque `,` por `.` com `replaceAll`, converta com
`tryParse` e imprima o texto original, o normalizado e o resultado (que pode ser `null`). Depois
converta o que for hora para minutos inteiros (`1.5` → `90`) com `round()` e explique, em
comentário, por que `toInt()` seria a escolha errada se o valor fosse `0.999`. Guarde o arquivo:
ele reaparece quase inteiro no
[Módulo 07, aula 07](../07-navegacao-e-formularios/07-validacao-foco-teclado.md).

---

## 📌 Resumo

- **Tipo** define que valores cabem em uma variável e que operações fazem sentido: `int`, `double`,
  `num` (pai dos dois), `String` (texto imutável) e `bool`.
- `double` tem erro de arredondamento inerente (`0.1 + 0.2 != 0.3`): dinheiro e tempo ficam em
  `int`.
- `Object` aceita tudo mas exige verificação; `dynamic` desliga a checagem e transfere o erro para
  a execução.
- **Tipagem estática** (Dart) verifica antes de rodar; `var` é inferência, **não** é `dynamic`.
- Número → texto: `toString()`, `toStringAsFixed(n)` (que **arredonda**).
- Texto → número: `parse` (lança `FormatException`) e `tryParse` (devolve `null`). Para entrada de
  usuário, sempre `tryParse`.
- `int` ↔ `double`: `toDouble()`, `toInt()` (trunca), `round()`, `floor()`, `ceil()`.
- `is` testa o tipo em execução e devolve `bool`.
- No Brasil o usuário digita vírgula decimal; o Dart espera ponto. Normalize antes de converter.

---

## ☑️ Checklist de domínio

- [x] Explico a diferença entre `int`, `double` e `num`, e por que não se guarda dinheiro em
      `double`.
- [x] Explico a diferença entre `Object` e `dynamic`, e entre `var` e `dynamic`.
- [x] Digo a diferença entre tipagem estática e dinâmica e uma vantagem de cada.
- [x] Uso `tryParse` em toda entrada externa e sei por quê.
- [x] Sei que `toStringAsFixed` arredonda e `toInt` trunca.
- [x] Converto `int` para `double` e vice-versa sem erro de compilação.
- [x] Trato a vírgula decimal brasileira antes de converter.
- [x] Executei `bin/aula05_tipos.dart` e a saída bateu com a esperada.

---

## 📚 Referências oficiais

- [Dart — Tipos internos (built-in types)](https://dart.dev/language/built-in-types)
- [Dart — `int`](https://api.dart.dev/stable/dart-core/int-class.html)
- [Dart — `int.tryParse`](https://api.dart.dev/stable/dart-core/int/tryParse.html)
- [Dart — Sistema de tipos](https://dart.dev/language/type-system)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Variáveis e constantes](04-variaveis-e-constantes.md) | [README](README.md) | [Aula 6 — Operadores](06-operadores.md) |
