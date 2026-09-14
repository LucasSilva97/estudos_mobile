# Aula 5 — Patterns e switch

> **Módulo:** 04 - Dart Avançado · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é *pattern matching* (*casamento de padrões*) e para que serve.
- Escrever `switch` como **expressão** (que devolve valor) e como **instrução**.
- Casar por **tipo**, por **constante**, por **comparação** (`>=`) e por **ou lógico** (`||`).
- Usar **object patterns** para desmontar objetos direto no `case`.
- Filtrar um caso com **guard** `when`.
- Testar um único padrão com **`if-case`**.
- Desmontar `List`, `Map` e `Record` com destructuring.
- Entender **exaustividade** e por que ela é uma rede de segurança.

## ✅ Pré-requisitos

- [Aula 4 — Records](04-records.md): destructuring começou lá.
- [Módulo 03 — Enums](../03-dart-intermediario/07-enums.md) e
  [Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md).
- [Módulo 02 — Controle de fluxo](../02-dart-basico/06-controle-de-fluxo.md): o `switch` antigo.

---

## 📖 Conceito

### O que é um pattern

Um **pattern** (*padrão*) é uma descrição de **forma**. Você mostra ao Dart um desenho — "uma lista
de dois números", "um objeto `Sessao` cujo campo `concluida` é `false`", "um inteiro maior que 60"
— e ele responde duas coisas ao mesmo tempo: **casa ou não casa?** e, se casar, **desmonta** o
valor em variáveis que você nomeia ali mesmo.

Esse "dois em um" é o ganho. Sem patterns, você escreve `if` para testar e depois linhas extras
para extrair os campos. Com patterns, testar e extrair é o mesmo gesto.

### `switch` como expressão

Além do `switch` de sempre (que **executa** blocos), o Dart 3 tem o `switch` **expressão**, que
**devolve** um valor:

```dart
final conceito = switch (nota) {
  >= 9 => 'Excelente',
  >= 7 => 'Bom',
  >= 5 => 'Regular',
  _ => 'Insuficiente',
};
```

Diferenças de sintaxe em relação ao `switch` instrução:

| | `switch` instrução | `switch` expressão |
|---|---|---|
| Palavra `case` | obrigatória | **não existe** |
| Separador | `:` e corpo em linhas | `=>` e vírgula no fim |
| Caso padrão | `default:` | `_ =>` |
| Resultado | nenhum (executa) | **um valor** |

> Em Dart 3, um `case` com corpo **não** precisa de `break`: ao terminar o corpo, a execução sai do
> `switch`. `break` continua válido, mas deixou de ser obrigatório.

### Os padrões que você mais vai usar

```dart
case 0: ...                     // constante
case >= 60: ...                 // comparação (relational pattern)
case 'sim' || 's' || 'ok': ...  // ou lógico
case >= 7 && < 9: ...           // e lógico (combina dois padrões)
case final int minutos: ...     // tipo + variável
case _: ...                     // curinga (wildcard): casa com qualquer coisa
```

### Object pattern — desmontando objetos no `case`

```dart
switch (sessao) {
  case Sessao(concluida: false):
    print('ainda em andamento');
  case Sessao(:final materia, :final minutos):
    print('$materia levou $minutos min');
}
```

`Sessao(:final materia)` é a forma curta de `Sessao(materia: final materia)`: casa se o objeto for
uma `Sessao` e já cria a variável `materia` com o valor do campo (o Dart chama o *getter* por você).

### Guard `when` — a condição extra

`when` adiciona uma condição ao caso **depois** de ele casar:

```dart
case Sessao(:final minutos) when minutos >= 60:
  print('sessão longa');
```

Diferença importante em relação a um `if` dentro do corpo: se o `when` falhar, o Dart **continua
tentando os próximos casos**. Um `if` dentro do corpo já teria "consumido" o caso.

### Destructuring de `List`, `Map` e `Record`

```dart
// Lista
switch (argumentos) {
  case []: print('sem argumentos');
  case ['ajuda']: print('ajuda');
  case ['iniciar', final materia]: print('iniciar $materia');
}

// Map — casa se as chaves existirem com os tipos indicados
if (json case {'titulo': final String titulo, 'minutos': final int minutos}) {
  print('$titulo: $minutos min');
}

// Record
final (materia, minutos) = ('Dart', 120);
```

Em um `Map`, o padrão **não** exige todas as chaves — checa só as que você escreveu. Em uma `List`,
o tamanho importa: `[a, b]` casa só com listas de exatamente dois itens (para "o resto", use `...`
ou `...final resto`).

> Cuidado: em uma **declaração** como `final [a, b] = lista;` não há caso alternativo. Se a lista
> não tiver exatamente dois itens, o programa falha em tempo de execução. Dentro de um `switch`, o
> mesmo padrão simplesmente não casa e o próximo caso é tentado.

### `if-case` — um padrão só

Quando há **um** formato que interessa, `switch` é exagero:

```dart
if (resposta case {'dados': final List<Object?> lista}) {
  print('vieram ${lista.length} itens');
} else {
  print('formato inesperado');
}
```

### Exaustividade — a rede de segurança

Um `switch` é **exaustivo** quando o compilador consegue provar que todos os valores possíveis
foram tratados. `switch` expressão **exige** exaustividade.

O Dart consegue provar exaustividade para **`bool`** (`true` e `false`), **`enum`** (todos os
valores declarados), **hierarquias `sealed`** (assunto da [aula 6](06-sealed-classes.md)) e para
qualquer coisa que termine em um caso `_` ou `default`.

Para um tipo comum (`int`, `String`, sua classe não selada), é impossível listar tudo — então
termine com `_`. A exaustividade é o que transforma "esqueci de tratar um caso" de bug em produção
em erro do `dart analyze`.

## 💡 Analogia

Pattern matching é a esteira de triagem dos Correios. Cada pacote passa por uma sequência de
moldes; o primeiro molde em que ele **encaixa** define o destino — e, no mesmo movimento, já separa
o conteúdo em "remetente", "destinatário" e "peso", sem ninguém abrir o pacote depois.

O **guard `when`** é o fiscal ao lado da esteira: "encaixou no molde de encomenda grande, mas só
vale se estiver com o selo pago; senão, continue na esteira". E a **exaustividade** é a regra da
agência: nenhum pacote chega ao fim da esteira sem destino — se existir um formato sem molde, o
sistema avisa **antes** de o caminhão sair.

---

## 🧪 Exemplo mínimo

```dart
String classificar(int minutos) => switch (minutos) {
  0 => 'nenhum estudo hoje',
  < 0 => 'valor inválido',
  < 30 => 'sessão curta',
  < 90 => 'sessão boa',
  _ => 'maratona de estudos',
};

void main() {
  for (final m in [0, -5, 20, 60, 150]) {
    print('$m min -> ${classificar(m)}');
  }
}
```

Saída:

```text
0 min -> nenhum estudo hoje
-5 min -> valor inválido
20 min -> sessão curta
60 min -> sessão boa
150 min -> maratona de estudos
```

Repare: a ordem dos casos importa. `0` vem antes de `< 30` porque o primeiro que casa vence.

---

## 📱 Aplicando no Flutter

Pattern matching é o que deixa a tela do Flutter **curta e sem `if` aninhado**:

- **Decidir o widget pelo estado.** Em vez de três `if`, a tela vira um `switch` expressão que
  devolve o widget: carregando → indicador; erro → mensagem com botão; dados → lista. Esse é
  exatamente o formato de [06 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md).
- **`AsyncValue` do Riverpod 3.4.3.** Além do método `.when(...)`, o `AsyncValue` pode ser tratado
  com `switch` e object patterns, porque ele é uma hierarquia selada. Você vê as duas formas em
  [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).
- **Ler JSON com segurança.** O corpo de uma resposta HTTP chega como `Map<String, dynamic>`. Um
  `if-case` com map pattern valida o formato **e** extrai os campos tipados na mesma linha, em vez
  de uma pilha de `as` que explode quando o servidor muda algo. Você aplica isso em
  [09 — JSON](../09-consumo-de-api/02-json.md).
- **Rotas com argumentos.** Ao tratar os argumentos de uma rota nomeada, o pattern separa "veio um
  `Materia`" de "veio um `int`" de "veio `null`" — veja
  [07 — Argumentos e resultados](../07-navegacao-e-formularios/03-argumentos-e-resultados.md).

---

## 💻 Código completo

> **Arquivo:** `bin/aula05_patterns.dart`
> **Como executar:** `dart run bin/aula05_patterns.dart`

```dart
// Aula 5 — Patterns e switch: expressão, tipos, guards, listas, maps, records e if-case.

enum Nivel { iniciante, intermediario, avancado }

class Sessao {
  const Sessao({
    required this.materia,
    required this.minutos,
    this.concluida = false,
  });

  final String materia;
  final int minutos;
  final bool concluida;
}

/// 1) switch EXPRESSÃO com padrões de comparação.
String classificarMinutos(int minutos) => switch (minutos) {
  0 => 'nenhum estudo',
  < 0 => 'valor inválido',
  < 30 => 'sessão curta',
  >= 30 && < 90 => 'sessão boa',
  _ => 'maratona',
};

/// 2) switch expressão sobre ENUM: exaustivo sem precisar de `_`.
String descrever(Nivel nivel) => switch (nivel) {
  Nivel.iniciante => 'Está começando agora',
  Nivel.intermediario => 'Já escreve código sozinho',
  Nivel.avancado => 'Resolve problemas novos',
};

/// 3) switch INSTRUÇÃO com padrões de tipo e guard `when`.
void analisarEntrada(Object? entrada) {
  switch (entrada) {
    case null:
      print('   nada foi informado');
    case int n when n < 0:
      print('   inteiro negativo: $n');
    case final int n:
      print('   inteiro: $n');
    case final String s when s.trim().isEmpty:
      print('   texto em branco');
    case final String s:
      print('   texto de ${s.length} caracteres: "$s"');
    case final List<Object?> lista:
      print('   lista com ${lista.length} itens');
    default:
      print('   tipo não tratado: ${entrada.runtimeType}');
  }
}

/// 4) Object pattern + guard.
String avaliarSessao(Sessao sessao) => switch (sessao) {
  Sessao(concluida: false, :final materia) => '$materia ainda em andamento',
  Sessao(:final materia, :final minutos) when minutos >= 60 =>
    '$materia: sessão longa de $minutos min',
  _ => '${sessao.materia}: ${sessao.minutos} min',
};

/// 5) Destructuring de LISTA (argumentos de linha de comando).
String interpretarComando(List<String> args) => switch (args) {
  [] => 'nenhum comando informado',
  ['ajuda'] || ['-h'] => 'mostrando a ajuda',
  ['iniciar', final materia] => 'iniciando sessão de $materia',
  ['iniciar', final materia, final minutos] =>
    'iniciando $materia por $minutos min',
  [final primeiro, ...] => 'comando desconhecido: $primeiro',
  _ => 'entrada não reconhecida',
};

/// 6) Destructuring de RECORD.
String descreverPonto((int, int) ponto) => switch (ponto) {
  (0, 0) => 'origem',
  (final x, 0) => 'sobre o eixo X, em $x',
  (0, final y) => 'sobre o eixo Y, em $y',
  (final x, final y) when x == y => 'na diagonal, em ($x, $y)',
  _ => 'ponto (${ponto.$1}, ${ponto.$2})',
};

/// 7) if-case com MAP pattern: validar e extrair de uma vez.
void lerRespostaDoServidor(Map<String, Object?> resposta) {
  if (resposta case {
    'titulo': final String titulo,
    'minutos': final int minutos,
    'tags': final List<Object?> tags,
  }) {
    print('   ok: "$titulo", $minutos min, ${tags.length} tags');
  } else if (resposta case {'erro': final String mensagem}) {
    print('   servidor recusou: $mensagem');
  } else {
    print('   formato inesperado: ${resposta.keys.toList()}');
  }
}

void main() {
  print('--- 1) switch expressão ---');
  for (final m in <int>[0, -5, 20, 60, 150]) {
    print('   $m min -> ${classificarMinutos(m)}');
  }

  print('\n--- 2) enum é exaustivo ---');
  for (final nivel in Nivel.values) {
    print('   ${nivel.name}: ${descrever(nivel)}');
  }

  print('\n--- 3) padrões de tipo com guard ---');
  for (final entrada in <Object?>[null, -3, 42, '   ', 'Dart', [1, 2, 3], 3.14]) {
    analisarEntrada(entrada);
  }

  print('\n--- 4) object pattern ---');
  const sessoes = <Sessao>[
    Sessao(materia: 'Dart', minutos: 25),
    Sessao(materia: 'Flutter', minutos: 90, concluida: true),
    Sessao(materia: 'SQL', minutos: 40, concluida: true),
  ];
  for (final sessao in sessoes) {
    print('   ${avaliarSessao(sessao)}');
  }

  print('\n--- 5) destructuring de lista ---');
  final comandos = <List<String>>[
    <String>[],
    <String>['ajuda'],
    <String>['iniciar', 'Dart'],
    <String>['iniciar', 'Flutter', '45'],
    <String>['voar'],
  ];
  for (final args in comandos) {
    print('   $args -> ${interpretarComando(args)}');
  }

  print('\n--- 6) destructuring de record ---');
  for (final ponto in <(int, int)>[(0, 0), (5, 0), (0, 7), (3, 3), (2, 9)]) {
    print('   $ponto -> ${descreverPonto(ponto)}');
  }

  print('\n--- 7) if-case com map ---');
  lerRespostaDoServidor(<String, Object?>{
    'titulo': 'Estudar patterns',
    'minutos': 45,
    'tags': <String>['dart', 'estudo'],
  });
  lerRespostaDoServidor(<String, Object?>{'erro': 'token expirado'});
  lerRespostaDoServidor(<String, Object?>{'qualquer': 1});

  print('\n--- 8) destructuring em declaração ---');
  final perfil = <String, Object?>{'nome': 'Ana', 'idade': 30};
  final {'nome': nome, 'idade': idade} = perfil;
  print('   nome=$nome idade=$idade');
}
```

Saída esperada:

```text
--- 1) switch expressão ---
   0 min -> nenhum estudo
   -5 min -> valor inválido
   20 min -> sessão curta
   60 min -> sessão boa
   150 min -> maratona

--- 2) enum é exaustivo ---
   iniciante: Está começando agora
   intermediario: Já escreve código sozinho
   avancado: Resolve problemas novos

--- 3) padrões de tipo com guard ---
   nada foi informado
   inteiro negativo: -3
   inteiro: 42
   texto em branco
   texto de 4 caracteres: "Dart"
   lista com 3 itens
   tipo não tratado: double

--- 4) object pattern ---
   Dart ainda em andamento
   Flutter: sessão longa de 90 min
   SQL: 40 min

--- 5) destructuring de lista ---
   [] -> nenhum comando informado
   [ajuda] -> mostrando a ajuda
   [iniciar, Dart] -> iniciando sessão de Dart
   [iniciar, Flutter, 45] -> iniciando Flutter por 45 min
   [voar] -> comando desconhecido: voar

--- 6) destructuring de record ---
   (0, 0) -> origem
   (5, 0) -> sobre o eixo X, em 5
   (0, 7) -> sobre o eixo Y, em 7
   (3, 3) -> na diagonal, em (3, 3)
   (2, 9) -> ponto (2, 9)

--- 7) if-case com map ---
   ok: "Estudar patterns", 45 min, 2 tags
   servidor recusou: token expirado
   formato inesperado: [qualquer]

--- 8) destructuring em declaração ---
   nome=Ana idade=30
```

---

## 🔍 Explicando o código

**`switch (minutos) { 0 => ..., < 0 => ..., ... }`**
Não há `case` nem `:`. Cada linha é `padrão => valor,`. O `_` final é o curinga: sem ele, este
`switch` sobre `int` não compila, porque o compilador não consegue provar que todos os inteiros
foram cobertos.

**`>= 30 && < 90 => 'sessão boa'`**
Dois padrões de comparação unidos por `&&`. Leia como "maior ou igual a 30 **e** menor que 90".
Isso não é uma expressão booleana: são padrões, e por isso não há `minutos` escrito no meio.

**`switch (nivel) { Nivel.iniciante => ..., ... }` sem `_`**
Como `Nivel` é um `enum`, o compilador conhece **todos** os valores possíveis. Acrescente um quarto
valor ao enum sem tratar aqui e o `dart analyze` acusa erro de exaustividade — superpoder que você
leva para os estados de tela na [aula 6](06-sealed-classes.md).

**`case int n when n < 0:` antes de `case final int n:`**
O primeiro casa só para negativos; o segundo pega o resto. Se a ordem fosse invertida, o caso com
`when` nunca seria alcançado. `final int n` e `int n` fazem a mesma coisa aqui; `final` deixa
explícito que a variável não será reatribuída. Mais abaixo, `case final List<Object?> lista:` casa
qualquer lista — `Object?` é o "qualquer coisa, inclusive nulo" do Dart, mais seguro que `dynamic`.

**`Sessao(concluida: false, :final materia)`**
Duas coisas em um padrão só: `concluida: false` é uma **condição** (só casa se o campo for `false`)
e `:final materia` é uma **extração**. Se o campo `concluida` for `true`, o caso não casa e o
`switch` tenta o próximo.

**`['ajuda'] || ['-h'] => 'mostrando a ajuda'`**
O `||` entre padrões cria "um **ou** outro". Só é permitido quando os dois lados declaram as mesmas
variáveis (aqui, nenhuma). Logo abaixo, `[final primeiro, ...]` casa qualquer lista com **pelo
menos** um item: o primeiro vai para a variável e `...` descarta o resto (para guardá-lo, escreva
`...final resto`).

**`(final x, 0)`**
Padrão de record: casa quando o segundo campo é exatamente `0`, guardando o primeiro em `x`. É a
mesma sintaxe de criação de record, usada ao contrário.

**`if (resposta case { 'titulo': final String titulo, ... })`**
O `if-case`. O map pattern casa se as três chaves existirem **e** os valores forem dos tipos
indicados; se o servidor mandar `'minutos': '45'` (texto em vez de número), o padrão não casa e o
`else if` assume, sem nenhuma exceção lançada.

**`final {'nome': nome, 'idade': idade} = perfil;`**
Destructuring direto na declaração: duas variáveis nascem prontas. Como não existe "senão" aqui, o
mapa **precisa** ter essas chaves — do contrário o programa falha ao rodar. Use esta forma apenas
quando o formato for garantido por você, e o `if-case` quando o dado vier de fora.

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | Escrever `case` dentro de `switch` expressão | Erro de sintaxe | Em expressão é só `padrão => valor,` |
| 2 | Esquecer a vírgula entre os casos da expressão | `Expected ','` | Toda linha termina com vírgula |
| 3 | `switch` expressão sem `_` em tipo aberto | `The type 'int' is not exhaustively matched` | Acrescente `_ => ...` |
| 4 | Caso genérico antes do específico | O caso específico "não funciona" | Ordene do mais específico para o mais genérico |
| 5 | Usar `if` dentro do corpo em vez de `when` | O caso é consumido e os próximos não são testados | Use `when` no próprio `case` |
| 6 | Achar que map pattern exige todas as chaves | Padrão casa quando você não esperava | Ele checa só as chaves escritas |
| 7 | `final [a, b] = lista;` com lista de outro tamanho | Falha em tempo de execução | Use `switch`/`if-case` para dado externo |
| 8 | `\|\|` entre padrões que declaram variáveis diferentes | Erro de compilação | Os dois lados precisam declarar as mesmas variáveis |
| 9 | Confundir `_` (curinga) com variável | Tentar usar `_` no corpo | `_` descarta o valor de propósito |

---

## 🛠️ Exercício guiado

Vamos escrever o interpretador de um mini-terminal de estudos.

**Passo 1.** Crie `bin/guiado05_terminal.dart`.

**Passo 2.** Modele o resultado como record nomeado e escreva o interpretador com list patterns:

```dart
({String acao, String? alvo, int? minutos}) interpretar(List<String> args) =>
    switch (args) {
      ['listar'] => (acao: 'listar', alvo: null, minutos: null),
      ['iniciar', final materia] => (acao: 'iniciar', alvo: materia, minutos: 25),
      ['iniciar', final materia, final tempo] when int.tryParse(tempo) != null =>
        (acao: 'iniciar', alvo: materia, minutos: int.parse(tempo)),
      ['iniciar', final materia, _] =>
        (acao: 'erro', alvo: materia, minutos: null),
      _ => (acao: 'erro', alvo: null, minutos: null),
    };
```

**Passo 3.** No `main`, teste com `['listar']`, `['iniciar', 'Dart']`, `['iniciar', 'Dart', '50']`,
`['iniciar', 'Dart', 'cinquenta']` e `['voar']`. Depois use um `switch` sobre o resultado para
imprimir a mensagem final:

```dart
final mensagem = switch (resultado) {
  (acao: 'listar', alvo: _, minutos: _) => 'Listando matérias...',
  (acao: 'iniciar', :final alvo, :final minutos) =>
    'Iniciando $alvo por $minutos min',
  _ => 'Comando inválido',
};
```

**Passo 5.** Rode com `dart run bin/guiado05_terminal.dart`. Em seguida, retire o caso
`['iniciar', final materia, _]` e observe: a entrada
`['iniciar', 'Dart', 'cinquenta']` passa a cair no `_` final. Explique em um comentário por que o
guard `when` foi essencial para separar os dois casos.

**Resultado esperado:** cinco linhas, uma por entrada, com "Comando inválido" apenas nas duas
entradas problemáticas.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md)

Foque nos exercícios de **Leitura de código** e **Correção de bugs** sobre ordem de casos.

---

## 🏆 Desafio opcional

Escreva `String formatar(Object? valor)` que trate, em **um único** `switch` expressão: `null` →
`'—'`; `bool` → `'sim'`/`'não'`; `int` em minutos → `'2h 30min'`; `double` → duas casas decimais;
`DateTime` → `'dd/MM/aaaa'` montado com `padLeft`; `List` vazia → `'lista vazia'` e com itens →
`'N itens'`; `Map` com as chaves `'titulo'` e `'minutos'` → `'Título (N min)'`; qualquer outra
coisa → `valor.toString()`.

Depois transforme os casos de `Map` em um `if-case` separado e compare a legibilidade.

---

## 📌 Resumo

- Um **pattern** testa a forma **e** extrai os dados no mesmo gesto.
- `switch` **expressão** devolve valor: sem `case`, com `=>`, vírgula no fim, `_` como `default`.
- Padrões úteis: constante, `>=`/`<`, `||`, `&&`, tipo + variável, curinga `_`.
- **Object pattern** `Classe(campo: valor, :final outro)` filtra e desmonta objetos.
- **Guard `when`** adiciona condição ao caso; se falhar, os próximos casos ainda são tentados.
- List pattern liga o **tamanho**; map pattern checa **só as chaves escritas**.
- **`if-case`** resolve quando há um único formato de interesse.
- **Exaustividade** vale para `bool`, `enum`, `sealed` e para qualquer tipo com `_` — é o que
  impede você de esquecer um caso.

---

## ☑️ Checklist de domínio

- [ ] Converto uma cadeia de `if/else if` em um `switch` expressão.
- [ ] Explico por que `switch` expressão exige exaustividade.
- [ ] Uso object pattern com campo-condição e campo-extração no mesmo caso.
- [ ] Sei por que `when` é diferente de um `if` dentro do corpo.
- [ ] Desmonto uma `List` e um `Map` com patterns.
- [ ] Uso `if-case` para validar JSON sem lançar exceção.
- [ ] Ordeno casos do mais específico ao mais genérico.
- [ ] Rodei `bin/aula05_patterns.dart` e entendi cada bloco da saída.

---

## 📚 Referências oficiais

- [Patterns — dart.dev](https://dart.dev/language/patterns)
- [Pattern types — dart.dev](https://dart.dev/language/pattern-types)
- [Branches: if, switch — dart.dev](https://dart.dev/language/branches)
- [Records — dart.dev](https://dart.dev/language/records)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Records](04-records.md) | [README](README.md) | [Aula 6 — Sealed classes](06-sealed-classes.md) |
