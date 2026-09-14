# Aula 9 — Extensions

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é uma **extension method** e qual problema ela resolve.
- Escrever a sintaxe correta: `extension Nome on Tipo { ... }`.
- Criar extensões úteis de verdade: `int.comoTempoDeEstudo`, `String.capitalizado`,
  `List<Materia>.totalDeMinutos`.
- Decidir **quando** uma extensão é a ferramenta certa — e quando ela é a errada.
- Listar as **limitações**: sem estado, sem sobrescrever membros, resolução estática, escopo.
- Resolver conflitos entre extensões com `show`/`hide` e com a chamada explícita.

## ✅ Pré-requisitos

- [Aula 3 — Encapsulamento](03-encapsulamento.md) (getters).
- [Aula 8 — Generics](08-generics.md) (para extensões sobre `List<T>`).

---

## 📖 Conceito

### O problema: o tipo não é seu

Você quer transformar minutos em um texto bonito:

```dart
String formatar(int minutos) {
  final horas = minutos ~/ 60;
  return horas == 0 ? '${minutos}min' : '${horas}h';
}

print(formatar(90));
```

Funciona, mas a leitura fica invertida: o verbo vem antes do dado. E não há autocompletar — você
precisa lembrar que existe uma função chamada `formatar` em algum arquivo.

O que você **queria** era escrever `90.comoTempoDeEstudo`. Mas `int` é uma classe do próprio Dart:
você não pode abrir e acrescentar um método.

### A solução: `extension`

Uma **extension method** (método de extensão) acrescenta membros a um tipo **existente**, sem
modificá-lo e sem herdar dele:

```dart
extension DuracaoDeEstudo on int {
  String get comoTempoDeEstudo {
    final horas = this ~/ 60;
    final minutos = this % 60;
    if (horas == 0) {
      return '${minutos}min';
    }
    return '${horas}h${minutos.toString().padLeft(2, '0')}';
  }
}

print(90.comoTempoDeEstudo); // 1h30
```

Anatomia:

| Parte | Significado |
|---|---|
| `extension` | palavra-chave |
| `DuracaoDeEstudo` | **nome** da extensão (opcional, mas quase sempre vale a pena) |
| `on int` | o tipo que está sendo estendido |
| `this` | dentro da extensão, é **o próprio valor** (aqui, o `int`) |

Uma extensão pode declarar **getters, setters, métodos, operadores e membros estáticos**.
Não pode declarar campos nem construtores.

### Quando usar

✅ **Bons usos:**

1. **Formatação e conversão** sobre tipos do SDK: `int` → texto, `DateTime` → "ontem",
   `Duration` → "1h30".
2. **Atalhos de leitura** que deixam a chamada mais próxima do português:
   `materias.totalDeMinutos` em vez de `calcularTotal(materias)`.
3. **Utilidades de coleção** específicas do seu domínio: `List<Materia>.maisEstudada`.
4. **Reduzir repetição em código de UI** (o caso do `BuildContext` no Flutter, mais adiante).

❌ **Maus usos:**

1. **Regra de negócio importante.** Se o comportamento pertence ao seu domínio, ele pertence à
   **sua classe**. Extensão é acessório, não é lugar de esconder decisão de negócio.
2. **Extensões "gerais" com 40 membros** sobre `String` ou `Object`. Elas poluem o autocompletar de
   todo o projeto e viram um depósito.
3. **Quando você controla a classe.** Se `Materia` é sua, acrescente o método nela.

Teste rápido: *"se eu apagar esta extensão, o programa vira mais difícil de ler ou vira errado?"*
Se vira **errado**, a lógica estava no lugar errado.

### Escopo: extensão precisa estar importada

Uma extensão só funciona onde está **visível**. No mesmo arquivo, sempre. Em outro arquivo, você
precisa importar o arquivo que a declara ([Aula 10](10-arquivos-bibliotecas-pacotes.md)). Se o
autocompletar não mostra `.comoTempoDeEstudo`, quase sempre falta o `import`.

Extensões **sem nome** existem (`extension on int { ... }`), mas você perde duas coisas: não dá para
resolver conflito nem para esconder com `hide`. Prefira sempre dar nome.

### Limitações (a parte que evita horas perdidas)

**1. Não funciona com `dynamic`.**
Extensões são resolvidas **estaticamente**, isto é, pelo tipo que o compilador conhece. Se o tipo é
`dynamic`, o compilador não sabe nada e a chamada falha só em tempo de execução:

```dart
dynamic valor = 90;
valor.comoTempoDeEstudo; // 💥 NoSuchMethodError
```

**2. Não pode ter estado.**
Nada de campos. Uma extensão não guarda informação entre chamadas; ela só calcula a partir de
`this`.

**3. Não sobrescreve membros existentes.**
Se o tipo já tem um membro com aquele nome, **o membro real sempre vence**. Você não consegue trocar
o comportamento de `String.length` com uma extensão.

**4. Não cria um tipo.**
`90 is DuracaoDeEstudo` não faz sentido e não compila. Extensão não é herança nem interface: é
açúcar de sintaxe resolvido na compilação.

**5. Conflitos precisam de desempate manual.**
Se duas extensões visíveis definem `capitalizado` sobre `String`, o compilador acusa ambiguidade.
Três saídas:

```dart
import 'textos_a.dart' show TextoBonito;      // traga só o que quer
import 'textos_b.dart' hide TextoBonito;      // esconda o conflitante
print(TextoBonito('dart').capitalizado);      // chamada explícita
```

A terceira forma, `NomeDaExtensao(objeto).membro`, sempre resolve — e também é a forma de chamar um
membro que está sendo encoberto por um membro real do tipo.

> ⚠️ Não confunda `extension` com **`extension type`**, um recurso diferente do Dart 3 que cria um
> "apelido" com verificação de tipo em cima de um valor existente. Nesta aula tratamos apenas de
> `extension` (métodos de extensão).

---

## 💡 Analogia

Uma **capinha com suporte para celular**.

- O celular (o tipo `int`, `String`) é fechado: você não abre e solda um botão novo nele.
- A capinha acrescenta funções por fora: suporte, alça, porta-cartão. Na prática, o aparelho
  "passa a ter" essas funções.
- Mas a capinha **não muda o aparelho**: não troca a tela nem melhora a câmera. Se o celular já tem
  um botão ali, é o botão de verdade que responde ao toque — a capinha não sobrepõe.
- E a capinha não guarda energia: ela não tem bateria própria (nada de estado).
- Por fim, quem pega o celular **sem** a capinha (outro arquivo, sem `import`) não tem nenhuma
  dessas funções.

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_extension.dart`
> **Como executar:** `dart run bin/exemplo_extension.dart`

```dart
extension TextoDeEstudo on String {
  /// Primeira letra maiúscula, resto minúsculo.
  String get capitalizado =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Corta o texto e marca o corte com reticências.
  String resumir(int limite) =>
      length <= limite ? this : '${substring(0, limite - 1)}…';
}

void main() {
  print('dart'.capitalizado);
  print('FLUTTER'.capitalizado);
  print(''.capitalizado.isEmpty);
  print('Organizador de estudos'.resumir(12));
  print('Dart'.resumir(12));
}
```

Saída:

```text
Dart
Flutter
true
Organizador…
Dart
```

Repare em `isEmpty` e `substring` usados **sem** `this.`: dentro da extensão, os membros do tipo
estendido estão diretamente disponíveis, como se você estivesse dentro da classe.

---

## 📱 Aplicando no Flutter

Esta é, provavelmente, a extensão mais copiada do mundo Flutter. Todo projeto sério tem uma versão
dela:

```dart
extension ContextoDeTema on BuildContext {
  ThemeData get tema => Theme.of(this);
  TextTheme get textos => Theme.of(this).textTheme;
  ColorScheme get cores => Theme.of(this).colorScheme;

  Size get tamanhoDaTela => MediaQuery.sizeOf(this);
  bool get ehTelaLarga => MediaQuery.sizeOf(this).width >= 600;

  void mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }
}
```

`BuildContext` é o objeto que o Flutter passa para o método `build` e que dá acesso a tudo o que
está "acima" do widget na árvore — tema, tamanho da tela, navegação. Você o conhece em
[`05-introducao-ao-flutter/07-buildcontext.md`](../05-introducao-ao-flutter/07-buildcontext.md).

Com a extensão, o código da tela encolhe de forma notável:

```dart
// Sem extensão
Text('Minhas matérias', style: Theme.of(context).textTheme.titleLarge);
if (MediaQuery.sizeOf(context).width >= 600) { /* layout de tablet */ }
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Matéria salva')),
);

// Com extensão
Text('Minhas matérias', style: context.textos.titleLarge);
if (context.ehTelaLarga) { /* layout de tablet */ }
context.mostrarAviso('Matéria salva');
```

Repare que isso é exatamente o "bom uso" número 4: **reduzir repetição de UI**, sem esconder regra
de negócio. Você aplica isso nos módulos
[06 — temas](../06-widgets-e-layouts/07-cores-temas-modo-escuro.md) e
[06 — responsividade](../06-widgets-e-layouts/11-responsividade.md).

> ⚠️ Cuidado com uma armadilha: dentro de um método `async`, depois de um `await`, o `context` pode
> já não estar mais válido (o widget pode ter saído da tela). A extensão **não** protege você disso.
> A regra completa vem em [`06-widgets-e-layouts/10-gestos-e-feedback.md`](../06-widgets-e-layouts/10-gestos-e-feedback.md).

---

## 💻 Código completo

> **Arquivo:** `bin/09_extensions.dart`
> **Como executar:** `dart run bin/09_extensions.dart`

```dart
// Aula 9 do Módulo 03 — Extension methods: sintaxe, usos e limitações.

class Materia {
  final String nome;
  final int minutos;

  const Materia(this.nome, this.minutos);

  @override
  String toString() => '$nome ($minutos min)';
}

// ===========================================================================
// PARTE 1 — EXTENSÃO SOBRE UM TIPO DO SDK: int
// ===========================================================================

extension DuracaoDeEstudo on int {
  /// `this` é o próprio int.
  Duration get comoMinutos => Duration(minutes: this);

  String get comoTempoDeEstudo {
    final horas = this ~/ 60;
    final minutos = this % 60;
    if (horas == 0) {
      return '${minutos}min';
    }
    if (minutos == 0) {
      return '${horas}h';
    }
    return '${horas}h${minutos.toString().padLeft(2, '0')}';
  }

  bool get ehSessaoLonga => this >= 60;

  /// Método (com parâmetro), não getter.
  String vezes(String palavra) => List<String>.filled(this, palavra).join(' ');
}

// ===========================================================================
// PARTE 2 — EXTENSÃO SOBRE String
// ===========================================================================

extension TextoDeEstudo on String {
  String get capitalizado =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  bool get ehVazioOuEspacos => trim().isEmpty;

  String resumir(int limite) =>
      length <= limite ? this : '${substring(0, limite - 1)}…';
}

// ===========================================================================
// PARTE 3 — EXTENSÃO SOBRE UMA COLEÇÃO DO SEU DOMÍNIO
// ===========================================================================

extension EstatisticasDeMaterias on List<Materia> {
  int get totalDeMinutos =>
      fold<int>(0, (soma, materia) => soma + materia.minutos);

  /// Cópia ordenada: NÃO altera a lista original.
  List<Materia> get ordenadasPorMinutos {
    final copia = <Materia>[...this];
    copia.sort((a, b) => b.minutos.compareTo(a.minutos));
    return copia;
  }

  Materia? get maisEstudada => isEmpty ? null : ordenadasPorMinutos.first;

  String get relatorio => isEmpty
      ? 'Nenhuma matéria cadastrada.'
      : ordenadasPorMinutos
          .map((m) => '${m.nome}: ${m.minutos.comoTempoDeEstudo}')
          .join(' | ');
}

// ===========================================================================
// PARTE 4 — EXTENSÃO GENÉRICA
// ===========================================================================

extension ListaSegura<T> on List<T> {
  T? get primeiroOuNulo => isEmpty ? null : first;

  T? elementoOuNulo(int indice) =>
      indice >= 0 && indice < length ? this[indice] : null;
}

// ===========================================================================
// PARTE 5 — DEMONSTRANDO UMA LIMITAÇÃO
// ===========================================================================

/// Esta extensão declara `length`, que JÁ EXISTE em String.
/// O membro real da classe SEMPRE vence na chamada normal.
/// Só a chamada explícita `NuncaVence('...').length` alcança este código.
extension NuncaVence on String {
  int get length => 999;
}

// ===========================================================================
// PROGRAMA
// ===========================================================================

void main() {
  print('--- 1. Extensões em int ---');
  for (final minutos in <int>[25, 90, 120]) {
    print('$minutos -> ${minutos.comoTempoDeEstudo} | '
        'Duration ${minutos.comoMinutos} | longa? ${minutos.ehSessaoLonga}');
  }
  print(3.vezes('foco'));

  print('');
  print('--- 2. Extensões em String ---');
  print("'dart'.capitalizado      = ${'dart'.capitalizado}");
  print("'FLUTTER'.capitalizado   = ${'FLUTTER'.capitalizado}");
  print("'   '.ehVazioOuEspacos   = ${'   '.ehVazioOuEspacos}");
  print("'Organizador de estudos'.resumir(12) = "
      "${'Organizador de estudos'.resumir(12)}");

  print('');
  print('--- 3. Extensão sobre List<Materia> ---');
  const materias = <Materia>[
    Materia('Dart', 150),
    Materia('Flutter', 180),
    Materia('Lógica', 45),
  ];
  print('Total: ${materias.totalDeMinutos.comoTempoDeEstudo}');
  print('Mais estudada: ${materias.maisEstudada}');
  print('Relatório: ${materias.relatorio}');
  print('Lista original preservada: $materias');
  print('Vazia: ${const <Materia>[].relatorio}');

  print('');
  print('--- 4. Extensão genérica ---');
  const nomes = <String>['Dart', 'Flutter'];
  print('primeiroOuNulo de nomes: ${nomes.primeiroOuNulo}');
  print('primeiroOuNulo de vazia: ${const <String>[].primeiroOuNulo}');
  print('elementoOuNulo(1): ${nomes.elementoOuNulo(1)}');
  print('elementoOuNulo(9): ${nomes.elementoOuNulo(9)}');

  print('');
  print('--- 5. Limitações ---');

  // (a) O membro real da classe vence.
  print("'Dart'.length              = ${'Dart'.length}");
  print("NuncaVence('Dart').length  = ${NuncaVence('Dart').length}");

  // (b) Chamada explícita da extensão.
  print('DuracaoDeEstudo(90).comoTempoDeEstudo = '
      '${DuracaoDeEstudo(90).comoTempoDeEstudo}');

  // (c) Extensões NÃO funcionam com dynamic.
  dynamic valorDinamico = 90;
  try {
    print(valorDinamico.comoTempoDeEstudo);
  } on NoSuchMethodError {
    print('dynamic: NoSuchMethodError — extensão é resolvida na compilação, '
        'e `dynamic` não tem tipo conhecido.');
  }
}
```

**Saída esperada:**

```text
--- 1. Extensões em int ---
25 -> 25min | Duration 0:25:00.000000 | longa? false
90 -> 1h30 | Duration 1:30:00.000000 | longa? true
120 -> 2h | Duration 2:00:00.000000 | longa? true
foco foco foco

--- 2. Extensões em String ---
'dart'.capitalizado      = Dart
'FLUTTER'.capitalizado   = Flutter
'   '.ehVazioOuEspacos   = true
'Organizador de estudos'.resumir(12) = Organizador…

--- 3. Extensão sobre List<Materia> ---
Total: 6h15
Mais estudada: Flutter (180 min)
Relatório: Flutter: 3h | Dart: 2h30 | Lógica: 45min
Lista original preservada: [Dart (150 min), Flutter (180 min), Lógica (45 min)]
Vazia: Nenhuma matéria cadastrada.

--- 4. Extensão genérica ---
primeiroOuNulo de nomes: Dart
primeiroOuNulo de vazia: null
elementoOuNulo(1): Flutter
elementoOuNulo(9): null

--- 5. Limitações ---
'Dart'.length              = 4
NuncaVence('Dart').length  = 999
DuracaoDeEstudo(90).comoTempoDeEstudo = 1h30
dynamic: NoSuchMethodError — extensão é resolvida na compilação, e `dynamic` não tem tipo conhecido.
```

---

## 🔍 Explicando o código

**`extension DuracaoDeEstudo on int { ... }`**
`DuracaoDeEstudo` é o nome (usado para desempatar conflitos); `on int` é o alvo. Dentro do bloco,
`this` é o próprio número.

**`Duration get comoMinutos => Duration(minutes: this);`**
Getter de extensão. Note que ele **não pode** ser `const`: `this` só é conhecido em tempo de execução.

**`this ~/ 60` e `this % 60`**
`~/` é divisão inteira; `%` é o resto. 90 minutos → 1 hora e 30 minutos.

**`String vezes(String palavra) => List<String>.filled(this, palavra).join(' ');`**
Um **método** de extensão (com parâmetro), não um getter. `List.filled(3, 'foco')` cria
`['foco','foco','foco']`, e `join(' ')` junta com espaço. Chamada: `3.vezes('foco')`.

**`isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}'`**
Dentro da extensão sobre `String`, `isEmpty`, `substring` e `[0]` são membros da própria `String`,
usados sem `this.`. O `this` explícito aparece só onde é preciso (`this[0]`).

**`extension EstatisticasDeMaterias on List<Materia>`**
O alvo é um tipo **genérico já instanciado**. Esta extensão vale para `List<Materia>` e **não** para
`List<String>` — é justamente isso que a torna segura e específica.

**`fold<int>(0, (soma, materia) => soma + materia.minutos)`**
`fold` acumula um valor percorrendo a lista, começando em 0.

**`final copia = <Materia>[...this];`**
O operador *spread* (`...`) copia os elementos. Isso é essencial: `sort` **altera a lista original**,
e uma extensão que modifica a lista de quem a chamou seria uma armadilha. Devolver uma cópia
ordenada respeita a imutabilidade da [Aula 3](03-encapsulamento.md).

**`.map((m) => '${m.nome}: ${m.minutos.comoTempoDeEstudo}')`**
Extensão **dentro** de extensão: `m.minutos` é `int`, então `comoTempoDeEstudo` está disponível.
Extensões se compõem naturalmente.

**`extension ListaSegura<T> on List<T>`**
Extensão **genérica** (Aula 8): serve para qualquer `List`, e `primeiroOuNulo` devolve `T?`, ou seja,
o tipo certo. Em `nomes.primeiroOuNulo`, o resultado é `String?`.

**`extension NuncaVence on String { int get length => 999; }`**
Existe só para provar a limitação 3. Na chamada normal, `'Dart'.length` usa o `length` **da classe
`String`** e devolve 4. Para alcançar o da extensão é preciso a forma explícita
`NuncaVence('Dart').length`. Em código de verdade, **nunca** declare um membro com nome já existente.

**`DuracaoDeEstudo(90).comoTempoDeEstudo`**
Chamada explícita da extensão. É a solução universal para ambiguidade entre duas extensões.

**`dynamic valorDinamico = 90;` + `try / on NoSuchMethodError`**
A prova da limitação 1. O compilador nem tenta: com `dynamic`, a busca do membro acontece em tempo
de execução, e a extensão não existe lá. O erro é `NoSuchMethodError`, capturado aqui para o
programa continuar.

**`const <Materia>[].relatorio`**
Extensão funcionando sobre uma lista vazia constante — e o `relatorio` já cuida desse caso.

---

## ⚠️ Erros comuns

**1. Esquecer o `import` da extensão**

```text
Error: The getter 'comoTempoDeEstudo' isn't defined for the type 'int'.
```
✅ Importe o arquivo que declara a extensão ([Aula 10](10-arquivos-bibliotecas-pacotes.md)).

**2. Chamar extensão em `dynamic`**

```dart
dynamic x = 90;
x.comoTempoDeEstudo; // 💥 NoSuchMethodError em tempo de execução
```
✅ Dê um tipo: `final int x = 90;` ou `(x as int).comoTempoDeEstudo`.

**3. Tentar declarar campo na extensão**

```dart
extension Contador on int {
  int chamadas = 0; // ❌
}
```
```text
Error: Extensions can't declare instance fields.
```
✅ Extensão não guarda estado. Se precisa de estado, você precisa de uma **classe**.

**4. Esperar sobrescrever um membro existente**

```dart
extension on String { int get length => 0; } // nunca será usado implicitamente
```
✅ O membro real vence sempre. Escolha outro nome.

**5. Ambiguidade entre duas extensões**

```text
Error: The property 'capitalizado' is defined in multiple extensions and neither
is more specific.
```
✅ Use `show`/`hide` no `import` ou a chamada explícita `TextoDeEstudo('dart').capitalizado`.

**6. Extensão que modifica a coleção recebida**

```dart
extension Ruim on List<Materia> {
  void ordenar() => sort((a, b) => a.minutos.compareTo(b.minutos)); // ❌ efeito colateral
}
```
✅ Devolva uma cópia (`ordenadasPorMinutos`), como no código completo.

**7. Pôr regra de negócio em extensão**

```dart
extension Cobranca on Materia {
  bool get podeSerExcluida => ...; // ❌ isso é regra do domínio
}
```
✅ Se a classe é sua, o método vai **dentro** dela.

**8. Extensão sobre `Object` ou `dynamic`**

```dart
extension Tudo on Object { void logar() => print(this); } // ❌
```
Isso aparece no autocompletar de **toda** variável do projeto. ✅ Estenda o tipo mais específico
possível.

---

## 🛠️ Exercício guiado

Vamos criar as extensões de data que o app Foco usa na lista de sessões.

**Passo 1.** Crie `bin/guiado_09_datas.dart`:

```dart
extension DataDeEstudo on DateTime {
  String get diaMesAno =>
      '${_doisDigitos(day)}/${_doisDigitos(month)}/$year';

  String get horaMinuto => '${_doisDigitos(hour)}:${_doisDigitos(minute)}';

  bool ehMesmoDiaQue(DateTime outra) =>
      year == outra.year && month == outra.month && day == outra.day;

  /// Texto relativo a uma data de referência (passada por parâmetro
  /// para o resultado ser reproduzível em teste).
  String relativoA(DateTime referencia) {
    final diferenca = referencia.difference(this).inDays;
    if (ehMesmoDiaQue(referencia)) {
      return 'hoje às $horaMinuto';
    }
    if (diferenca == 1) {
      return 'ontem às $horaMinuto';
    }
    if (diferenca > 1 && diferenca < 7) {
      return 'há $diferenca dias';
    }
    return diaMesAno;
  }

  String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');
}
```

> O `_doisDigitos` com `_` é privado ao arquivo (Aula 3) — e, dentro de uma extensão, membros
> privados também são permitidos. Ele não aparece no autocompletar de quem importar o arquivo.

**Passo 2.** Uma extensão sobre `Duration`:

```dart
extension DuracaoLegivel on Duration {
  String get legivel {
    if (inMinutes < 1) {
      return '$inSeconds s';
    }
    if (inMinutes < 60) {
      return '$inMinutes min';
    }
    final horas = inHours;
    final minutos = inMinutes % 60;
    return minutos == 0 ? '$horas h' : '$horas h $minutos min';
  }
}
```

**Passo 3.** `main` com datas fixas (nada de `DateTime.now()`, para a saída ser reproduzível):

```dart
void main() {
  final hoje = DateTime(2026, 9, 14, 20, 0);

  final registros = <DateTime>[
    DateTime(2026, 9, 14, 8, 30),
    DateTime(2026, 9, 13, 19, 45),
    DateTime(2026, 9, 11, 7, 5),
    DateTime(2026, 8, 30, 15, 0),
  ];

  print('--- Sessões ---');
  for (final registro in registros) {
    print('${registro.diaMesAno} ${registro.horaMinuto} '
        '-> ${registro.relativoA(hoje)}');
  }

  print('');
  print('--- Durações ---');
  for (final segundos in <int>[45, 1500, 5400, 7200]) {
    print('$segundos s -> ${Duration(seconds: segundos).legivel}');
  }
}
```

**Passo 4.** Execute:

```powershell
dart run bin/guiado_09_datas.dart
```

**Saída esperada:**

```text
--- Sessões ---
14/09/2026 08:30 -> hoje às 08:30
13/09/2026 19:45 -> ontem às 19:45
11/09/2026 07:05 -> há 3 dias
30/08/2026 15:00 -> 30/08/2026

--- Durações ---
45 s -> 45 s
1500 s -> 25 min
5400 s -> 1 h 30 min
7200 s -> 2 h
```

(Observação sobre a terceira linha: `difference(...).inDays` conta **dias completos** de 24 h.
De 11/09 07:05 até 14/09 20:00 são 3 dias e 12 h — `inDays` devolve 3.)

**Passo 5.** Note o que você ganhou: `registro.relativoA(hoje)` lê-se quase como português, e a
formatação de data parou de aparecer espalhada pelo código. Esse mesmo padrão reaparece no app
Foco, agora com o pacote `intl` (versão `^0.20.2`), no
[Módulo 06](../06-widgets-e-layouts/02-texto-tipografia-icones.md).

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Crie um arquivo de extensões de validação e use-o para validar um formulário de matéria:

```dart
extension ValidacaoDeTexto on String {
  bool get ehNomeValido => trim().length >= 2 && trim().length <= 40;
  bool get ehNumeroInteiro => int.tryParse(trim()) != null;
  String? validarNome() => ehNomeValido ? null : 'Informe de 2 a 40 caracteres.';
}
```

Requisitos:

1. Acrescente pelo menos mais três validações úteis (minutos entre 1 e 10080, sem caracteres
   especiais, não pode ser só números).
2. Escreva `Map<String, String?> validarFormulario({required String nome, required String minutos})`
   que devolve o campo e a mensagem de erro (ou `null`).
3. Teste com 5 entradas diferentes e imprima uma tabela do resultado.
4. Agora a pergunta que vale a nota: **essa validação deveria mesmo estar numa extensão sobre
   `String`?** Escreva sua resposta em comentário, considerando o critério da aula ("se eu apagar a
   extensão, o programa vira ilegível ou vira errado?"). Dica: a resposta muda dependendo de a regra
   ser genérica de texto ou específica de matéria.

O retorno `String?` (nulo = válido) não é coincidência: é exatamente a assinatura que o
`TextFormField` do Flutter espera em `validator`, no
[Módulo 07](../07-navegacao-e-formularios/07-validacao-foco-teclado.md).

---

## 📌 Resumo

- `extension Nome on Tipo { ... }` acrescenta membros a um tipo existente, sem herdar nem modificar.
- Dentro da extensão, `this` é o valor estendido, e os membros dele ficam acessíveis sem prefixo.
- Extensões podem ter getters, setters, métodos, operadores e membros estáticos — **nunca campos**.
- Bons usos: formatação, atalhos de leitura, utilidades de coleção, redução de repetição de UI.
- Mau uso: regra de negócio (ela pertence à classe) e extensões gigantes sobre tipos muito gerais.
- Limitações: não funcionam com `dynamic`, não guardam estado, não sobrescrevem membros existentes,
  não criam tipo e exigem estar no escopo (`import`).
- Conflitos se resolvem com `show`/`hide` ou com a chamada explícita `Extensao(objeto).membro`.
- No Flutter, a extensão sobre `BuildContext` é praticamente obrigatória em projetos reais.

---

## ☑️ Checklist de domínio

- [ ] Escrevo `extension X on Tipo` de memória, com getter e método.
- [ ] Explico o que é `this` dentro de uma extensão.
- [ ] Cito dois bons usos e dois maus usos.
- [ ] Sei por que a chamada em `dynamic` falha, e que erro aparece.
- [ ] Sei que o membro real da classe sempre vence, e como chamar a extensão mesmo assim.
- [ ] Resolvo um conflito entre duas extensões de três formas diferentes.
- [ ] Escrevo uma extensão genérica sobre `List<T>`.
- [ ] Explico por que `ordenadasPorMinutos` devolve uma cópia em vez de ordenar no lugar.
- [ ] Rodei `bin/09_extensions.dart` e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Extension methods](https://dart.dev/language/extension-methods)
- [Dart — Implementing extension methods](https://dart.dev/language/extension-methods#implementing-extension-methods)
- [Dart — Extension types](https://dart.dev/language/extension-types)
- [API — `Duration`](https://api.dart.dev/stable/dart-core/Duration-class.html)
- [API — `DateTime`](https://api.dart.dev/stable/dart-core/DateTime-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 8 — Generics](08-generics.md) | [README](README.md) | [Aula 10 — Arquivos, bibliotecas e pacotes](10-arquivos-bibliotecas-pacotes.md) |
