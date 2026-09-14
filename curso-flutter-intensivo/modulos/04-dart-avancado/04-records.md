# Aula 4 — Records

> **Módulo:** 04 - Dart Avançado · **Tempo estimado:** 30 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Criar records **posicionais**, **nomeados** e **mistos**.
- Escrever o **tipo** de um record na assinatura de uma função.
- Devolver **vários valores** de uma função sem criar classe.
- Desmontar um record com *destructuring* (*desestruturação*).
- Explicar a **igualdade estrutural** dos records e usá-los como chave de `Map`.
- Decidir com critério entre **record** e **classe**.

## ✅ Pré-requisitos

- [Módulo 03 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md).
- [Módulo 02 — Listas](../02-dart-basico/08-listas.md) e
  [Sets e Maps](../02-dart-basico/09-sets-e-maps.md).
- Dart 3.13.1 (records existem a partir do Dart 3; não funcionam em Dart 2).

---

## 📖 Conceito

### O problema que os records resolvem

Uma função em Dart devolve **um** valor. E quando você precisa de dois?

Antes do Dart 3 havia três saídas ruins: devolver `List<Object>` (perde os tipos), devolver `Map`
(perde os tipos e erra o nome da chave em silêncio) ou criar uma classe só para isso (muito código
para algo passageiro).

O **record** (*registro*) é a quarta saída: um agrupamento **leve, imutável e tipado** de vários
valores, sem declarar classe nenhuma.

### Record posicional

```dart
final ponto = (10, 20);        // tipo: (int, int)
print(ponto.$1);               // 10  — o primeiro campo
print(ponto.$2);               // 20  — o segundo campo
```

Os campos posicionais são acessados por `$1`, `$2`, `$3`... (começando em **1**, não em 0).

### Record nomeado

```dart
final aluno = (nome: 'Ana', minutos: 320);   // tipo: ({String nome, int minutos})
print(aluno.nome);                            // Ana
print(aluno.minutos);                         // 320
```

Aqui os campos têm nome de verdade, e o acesso fica legível.

### Record misto

```dart
final leitura = ('Dart', ok: true);   // tipo: (String, {bool ok})
print(leitura.$1);                     // Dart   — campo posicional
print(leitura.ok);                     // true   — campo nomeado
```

Os campos posicionais continuam sendo `$1`, `$2`... — os nomeados **não entram** nessa contagem.

### Escrevendo o tipo

O tipo de um record é a própria "forma" dele. Use na assinatura da função:

```dart
(int minimo, int maximo) faixa(List<int> valores) { ... }
({String nome, int minutos}) resumo() { ... }
```

No primeiro caso, `minimo` e `maximo` são apenas **nomes de documentação** dos campos posicionais:
quem recebe continua acessando por `$1` e `$2` (ou por destructuring). No segundo, `nome` e
`minutos` são campos nomeados de verdade.

> Detalhe de sintaxe: um record de **um único** campo posicional exige vírgula final — `(42,)` —
> porque `(42)` é apenas o número 42 entre parênteses.

### Destructuring — desmontando o record

Essa é a parte que deixa o código bonito:

```dart
final (menor, maior) = faixa([3, 9, 1]);           // posicional
final (nome: n, minutos: m) = resumo();            // nomeado, renomeando
final (:nome, :minutos) = resumo();                // nomeado, mesmo nome
```

Também funciona dentro de `for`:

```dart
final pares = <(String, int)>[('Dart', 120), ('Flutter', 80)];
for (final (materia, minutos) in pares) {
  print('$materia: $minutos min');
}
```

E até para trocar dois valores de lugar sem variável auxiliar:

```dart
var a = 1;
var b = 2;
(a, b) = (b, a);   // agora a == 2 e b == 1
```

O destructuring é um caso de **pattern** — o assunto completo da
[aula 5](05-patterns-e-switch.md).

### Igualdade estrutural

Dois records são iguais quando têm a **mesma forma** e os **mesmos valores**. Você não escreve
`==` nem `hashCode`: o Dart já faz.

```dart
print((1, 2) == (1, 2));                              // true
print((nome: 'Ana') == (nome: 'Ana'));                // true
print((1, 2) == (2, 1));                              // false
```

Duas consequências práticas: records funcionam como **chave de `Map`** e como elemento de `Set`,
e comparar dois records é comparar conteúdo — diferente de uma classe comum, onde `==` compara
identidade a menos que você implemente `==` e `hashCode` na mão.

### Record × classe — a decisão

| Critério | Record | Classe |
|---|---|---|
| Declarar | nada, só usar | `class`, campos, construtor |
| Nome do conceito | não tem | tem (`Materia`, `Sessao`) |
| Métodos e regras de negócio | não (só via `extension`) | sim |
| Validação no construtor | não | sim |
| Igualdade por conteúdo | de graça | você escreve `==` e `hashCode` |
| Mutável | nunca | se você quiser |
| Aparece na API pública do app | evite | sim |

**Regra do curso:**

> Use **record** para agrupar valores **passageiros** dentro de uma função ou entre duas funções
> próximas. Use **classe** para tudo que tem **nome de domínio**, **regra** ou **validação**.

Uma `Materia` do projeto final é classe. O par "(quantidade de acertos, quantidade de erros)" que
uma função de estatística devolve é record.

### Records são imutáveis

Não existe `ponto.$1 = 5`. Para "mudar", crie outro record. Isso é uma vantagem: nenhum ponto do
código altera o valor por baixo dos panos.

## 💡 Analogia

Uma **classe** é um formulário oficial: tem nome, campos com rótulo, regras de preenchimento e
carimbo. Serve para o documento que vai ficar arquivado.

Um **record** é o bilhete que você escreve para si: "Dart, 120". Tem exatamente a informação
necessária, dura o tempo do recado, e ninguém cria um formulário oficial para escrever um recado.

E a **igualdade estrutural** é o fato de dois bilhetes com o mesmo texto serem, para todos os
efeitos, o mesmo recado.

---

## 🧪 Exemplo mínimo

```dart
(int soma, int quantidade) somar(List<int> numeros) {
  var total = 0;
  for (final n in numeros) {
    total += n;
  }
  return (total, numeros.length);
}

void main() {
  final (soma, quantidade) = somar([10, 20, 30]);
  print('soma=$soma quantidade=$quantidade');
}
```

Saída:

```text
soma=60 quantidade=3
```

---

## 📱 Aplicando no Flutter

Records aparecem no Flutter sempre que você precisa de "duas informações juntas" sem criar classe:

- **Riverpod + `select`.** Para que um widget seja reconstruído apenas quando **dois** campos
  específicos mudarem, você observa um record: `ref.watch(perfilProvider.select((p) => (p.nome,
  p.minutos)))`. Como o record tem igualdade estrutural, o Riverpod 3.4.3 consegue comparar o
  valor antigo com o novo e evitar reconstruções inúteis. Isso aparece em
  [08 — Family, autoDispose e listen](../08-estado-e-arquitetura/08-family-autodispose-listen.md).
- **Camada de dados com paginação.** Um repositório que devolve "a página de itens **e** se ainda
  há mais" fica `Future<(List<Trilha> itens, bool temMais)>` em vez de exigir uma classe só para
  transportar isso ([09 — Camada de dados testável](../09-consumo-de-api/07-camada-de-dados-testavel.md)).
- **Medidas de layout.** Cálculos auxiliares que devolvem largura e altura, ou "colunas e espaço
  entre elas", cabem bem em record — veja [06 — Responsividade](../06-widgets-e-layouts/11-responsividade.md).
- **Testes.** Casos de teste em tabela ficam naturais como `List<(entrada, esperado)>`, algo que
  você vai usar em [12 — Testes unitários](../12-testes-e-debug/05-testes-unitarios.md).

Cuidado que vale desde já: **não** transforme o modelo do seu app (matéria, sessão, meta) em
record. Esses têm nome, regra e validação — são classe.

---

## 💻 Código completo

> **Arquivo:** `bin/aula04_records.dart`
> **Como executar:** `dart run bin/aula04_records.dart`

```dart
// Aula 4 — Records: posicional, nomeado, misto, retorno múltiplo e comparação com classe.

/// Devolve mínimo, máximo e média de uma lista de minutos estudados.
/// O tipo de retorno é um RECORD NOMEADO.
({int minimo, int maximo, double media}) estatisticas(List<int> minutos) {
  if (minutos.isEmpty) {
    throw ArgumentError.value(minutos, 'minutos', 'A lista não pode ser vazia');
  }
  var menor = minutos.first;
  var maior = minutos.first;
  var soma = 0;
  for (final valor in minutos) {
    if (valor < menor) menor = valor;
    if (valor > maior) maior = valor;
    soma += valor;
  }
  return (minimo: menor, maximo: maior, media: soma / minutos.length);
}

/// Record POSICIONAL com nomes de documentação.
(String materia, int minutos) materiaMaisEstudada(Map<String, int> minutosPorMateria) {
  var melhorMateria = '';
  var melhorMinutos = -1;
  minutosPorMateria.forEach((materia, minutos) {
    if (minutos > melhorMinutos) {
      melhorMateria = materia;
      melhorMinutos = minutos;
    }
  });
  return (melhorMateria, melhorMinutos);
}

/// Extension em cima de um tipo de record: records não têm métodos próprios,
/// mas você pode acrescentar comportamento de fora.
extension ResumoEstatisticas on ({int minimo, int maximo, double media}) {
  int get amplitude => maximo - minimo;
  String get textoCurto =>
      'min $minimo / max $maximo / média ${media.toStringAsFixed(1)}';
}

/// Versão em CLASSE do mesmo dado, para comparação.
class Estatisticas {
  const Estatisticas({
    required this.minimo,
    required this.maximo,
    required this.media,
  });

  final int minimo;
  final int maximo;
  final double media;

  // Em classe, igualdade por conteúdo é trabalho manual.
  @override
  bool operator ==(Object other) =>
      other is Estatisticas &&
      other.minimo == minimo &&
      other.maximo == maximo &&
      other.media == media;

  @override
  int get hashCode => Object.hash(minimo, maximo, media);

  @override
  String toString() => 'Estatisticas($minimo, $maximo, $media)';
}

void demonstrarFormas() {
  print('--- 1) as três formas ---');

  final posicional = (10, 20);
  print('posicional: $posicional -> \$1=${posicional.$1} \$2=${posicional.$2}');

  final nomeado = (nome: 'Ana', minutos: 320);
  print('nomeado: $nomeado -> ${nomeado.nome} estudou ${nomeado.minutos} min');

  final misto = ('Dart', concluido: true);
  print('misto: $misto -> \$1=${misto.$1} concluido=${misto.concluido}');

  final umCampo = (42,); // a vírgula final é obrigatória
  print('um campo só: $umCampo -> ${umCampo.$1}');
}

void demonstrarRetornoMultiplo() {
  print('\n--- 2) retorno múltiplo e destructuring ---');

  final dados = <int>[40, 120, 30, 90];

  // Destructuring de record nomeado, reaproveitando os nomes dos campos.
  final (:minimo, :maximo, :media) = estatisticas(dados);
  print('minimo=$minimo maximo=$maximo media=${media.toStringAsFixed(1)}');

  // Destructuring de record posicional.
  final (materia, minutos) = materiaMaisEstudada({
    'Dart': 120,
    'Flutter': 80,
    'SQL': 45,
  });
  print('mais estudada: $materia com $minutos min');

  // Usando a extension.
  final resumo = estatisticas(dados);
  print('amplitude=${resumo.amplitude} | ${resumo.textoCurto}');
}

void demonstrarIgualdade() {
  print('\n--- 3) igualdade estrutural ---');

  print('(1, 2) == (1, 2) ? ${(1, 2) == (1, 2)}');
  print('(1, 2) == (2, 1) ? ${(1, 2) == (2, 1)}');
  print('(nome: "Ana") == (nome: "Ana") ? '
      '${(nome: 'Ana') == (nome: 'Ana')}');

  // Record como chave de Map: possível justamente por causa da igualdade.
  final agenda = <(int dia, int hora), String>{
    (2, 19): 'Dart',
    (4, 20): 'Flutter',
  };
  print('agenda[(2, 19)] = ${agenda[(2, 19)]}');
  print('agenda[(3, 19)] = ${agenda[(3, 19)]}'); // null: chave inexistente

  // Em Set, records repetidos são descartados.
  final vistos = <(String, int)>{('Dart', 1), ('Dart', 1), ('Flutter', 2)};
  print('set com repetido: $vistos (tamanho ${vistos.length})');
}

void compararComClasse() {
  print('\n--- 4) record x classe ---');

  final r1 = (minimo: 30, maximo: 120, media: 70.0);
  final r2 = (minimo: 30, maximo: 120, media: 70.0);
  print('records iguais sem escrever nada: ${r1 == r2}');

  const c1 = Estatisticas(minimo: 30, maximo: 120, media: 70.0);
  const c2 = Estatisticas(minimo: 30, maximo: 120, media: 70.0);
  print('classes iguais (exigiu == e hashCode escritos): ${c1 == c2}');
  print('classe tem nome e pode validar; record é leve e passageiro.');
}

void demonstrarTroca() {
  print('\n--- 5) troca de valores ---');
  var a = 'primeiro';
  var b = 'segundo';
  print('antes:  a=$a b=$b');
  (a, b) = (b, a);
  print('depois: a=$a b=$b');
}

void main() {
  demonstrarFormas();
  demonstrarRetornoMultiplo();
  demonstrarIgualdade();
  compararComClasse();
  demonstrarTroca();
}
```

Saída esperada:

```text
--- 1) as três formas ---
posicional: (10, 20) -> $1=10 $2=20
nomeado: (minutos: 320, nome: Ana) -> Ana estudou 320 min
misto: (Dart, concluido: true) -> $1=Dart concluido=true
um campo só: (42) -> 42

--- 2) retorno múltiplo e destructuring ---
minimo=30 maximo=120 media=70.0
mais estudada: Dart com 120 min
amplitude=90 | min 30 / max 120 / média 70.0

--- 3) igualdade estrutural ---
(1, 2) == (1, 2) ? true
(1, 2) == (2, 1) ? false
(nome: "Ana") == (nome: "Ana") ? true
agenda[(2, 19)] = Dart
agenda[(3, 19)] = null
set com repetido: {(Dart, 1), (Flutter, 2)} (tamanho 2)

--- 4) record x classe ---
records iguais sem escrever nada: true
classes iguais (exigiu == e hashCode escritos): true

--- 5) troca de valores ---
antes:  a=primeiro b=segundo
depois: a=segundo b=primeiro
```

> Observação: na impressão de um record nomeado, o Dart pode listar os campos nomeados em ordem
> alfabética, e não na ordem em que você os escreveu. Isso não muda nada no acesso por nome.

---

## 🔍 Explicando o código

**`({int minimo, int maximo, double media}) estatisticas(List<int> minutos)`**
O tipo de retorno é um record nomeado. As chaves `{ }` **dentro** dos parênteses marcam os campos
nomeados. Quem chama recebe algo com `.minimo`, `.maximo` e `.media` — tipados, sem classe nenhuma.

**`return (minimo: menor, maximo: maior, media: soma / minutos.length);`**
Construir o record é escrever os valores entre parênteses. `soma / minutos.length` devolve `double`
porque `/` em Dart sempre produz `double` (para divisão inteira existe `~/`).

**`(String materia, int minutos) materiaMaisEstudada(...)`**
Aqui os campos são **posicionais**; `materia` e `minutos` servem de documentação. Quem recebe usa
`.$1` e `.$2` ou, melhor, faz destructuring — que é o que fazemos no bloco 2.

**`extension ResumoEstatisticas on ({int minimo, int maximo, double media})`**
Records não têm métodos. Uma `extension` ([módulo 03](../03-dart-intermediario/09-extensions.md))
resolve: ela adiciona `amplitude` e `textoCurto` a **todo** record com exatamente essa forma.

**`final (:minimo, :maximo, :media) = estatisticas(dados);`**
Esta é a forma abreviada do destructuring nomeado. `(:minimo)` é açúcar para `(minimo: minimo)` —
cria uma variável local com o mesmo nome do campo. Três variáveis nascem em uma linha.

**`final agenda = <(int dia, int hora), String>{ (2, 19): 'Dart' };`**
A chave do `Map` é um record. Isso só funciona porque o record implementa `==` e `hashCode`
por conteúdo. Com uma classe comum sem `==` escrito, `agenda[(2, 19)]` devolveria `null` mesmo com
os mesmos valores.

**`operator ==` e `hashCode` na classe `Estatisticas`**
Compare o tamanho desse bloco com o esforço do record: zero. É por isso que, para agrupamentos
passageiros, o record ganha. `Object.hash(...)` é o utilitário do `dart:core` para combinar
campos em um código de hash.

**`(a, b) = (b, a);`**
Um *pattern assignment* (*atribuição por padrão*): o record da direita é desmontado nas variáveis
já existentes da esquerda. Não há `final`/`var` — as variáveis precisam existir antes.

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | Achar que campos começam em `$0` | `The getter '$0' isn't defined` | A contagem começa em `$1` |
| 2 | `(42)` achando que é record de um campo | Vira o número 42 | Escreva `(42,)` com vírgula |
| 3 | Tentar alterar: `r.$1 = 5` | Erro de compilação | Records são imutáveis; crie outro |
| 4 | Confundir campo nomeado com posicional | `The getter 'ok' isn't defined for (String, bool)` | `(String, {bool ok})` ≠ `(String, bool)` |
| 5 | Usar record como modelo do app | Ninguém sabe o que é `(String, int, bool)` seis meses depois | Classe, com nome e validação |
| 6 | Esperar ordem ao imprimir campos nomeados | A saída parece "errada" | Acesse por nome; a impressão pode reordenar |
| 7 | Retornar record gigante (5, 6 campos) | Ilegível no ponto de chamada | Acima de 3 campos, prefira classe |
| 8 | Esquecer que o tipo é a **forma** | `(int, String)` não é aceito onde se espera `(String, int)` | A ordem dos campos posicionais faz parte do tipo |

---

## 🛠️ Exercício guiado

Vamos montar um "boletim de estudos" que devolve várias informações de uma vez.

**Passo 1.** Crie `bin/guiado04_boletim.dart`.

**Passo 2.** Escreva a função que devolve três informações em um record nomeado:

```dart
({int total, String melhor, double mediaDiaria}) boletim(
  Map<String, int> minutosPorMateria,
  int dias,
) {
  var total = 0;
  var melhor = '';
  var melhorValor = -1;
  minutosPorMateria.forEach((materia, minutos) {
    total += minutos;
    if (minutos > melhorValor) {
      melhor = materia;
      melhorValor = minutos;
    }
  });
  return (total: total, melhor: melhor, mediaDiaria: total / dias);
}
```

**Passo 3.** No `main`, chame a função e use o destructuring abreviado:

```dart
void main() {
  final dados = {'Dart': 120, 'Flutter': 200, 'SQL': 60};
  final (:total, :melhor, :mediaDiaria) = boletim(dados, 7);
  print('total=$total min | melhor=$melhor | média=${mediaDiaria.toStringAsFixed(1)} min/dia');
}
```

**Passo 4.** Acrescente uma `extension` sobre esse tipo de record com o getter
`bool get bateuMeta => mediaDiaria >= 45;` e imprima o resultado.

**Passo 5.** Agora escreva a **mesma coisa como classe** `Boletim`, com `==`, `hashCode` e
`toString()`. Rode com `dart run bin/guiado04_boletim.dart`.

**Resultado esperado:** as duas versões imprimem os mesmos números. Escreva, em um comentário no
fim do arquivo, qual das duas você usaria se esse boletim fosse exibido em uma tela do app e
precisasse de validação — e por quê.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md)

Foque nos exercícios de **Fixação** e **Aplicação** sobre retorno múltiplo.

---

## 🏆 Desafio opcional

Implemente `List<(int indice, T valor)> comIndice<T>(List<T> itens)`, que devolve cada item
acompanhado da sua posição — o equivalente ao `enumerate` de outras linguagens.

Depois use a função em um `for (final (i, nome) in comIndice(materias))` para imprimir uma lista
numerada. Como extra, escreva `Map<K, V> paraMapa<K, V>(List<(K, V)> pares)`, que converte uma
lista de records em `Map`, e teste com chaves repetidas para ver qual valor sobrevive.

---

## 📌 Resumo

- Record é um agrupamento **leve, imutável e tipado** de valores, sem declarar classe.
- Posicional: `(10, 20)`, acessado por `$1`, `$2`. Nomeado: `(nome: 'Ana')`, acessado por `.nome`.
- O **tipo** do record é a sua forma: `(int, String)`, `({String nome, int minutos})`.
- Record de um campo exige vírgula: `(42,)`.
- Destructuring desmonta o record em variáveis — inclusive na forma curta `(:nome, :minutos)`.
- Igualdade é **estrutural**: dá para usar record como chave de `Map` e em `Set`, de graça.
- Records não têm métodos; use `extension` quando precisar de comportamento.
- Record para dados **passageiros**; classe para conceitos com **nome, regra e validação**.

---

## ☑️ Checklist de domínio

- [ ] Escrevo os três tipos de record sem consultar.
- [ ] Declaro uma função cujo retorno é record nomeado e a consumo com destructuring.
- [ ] Explico por que `(42)` não é record e `(42,)` é.
- [ ] Uso um record como chave de `Map` e sei explicar por que funciona.
- [ ] Adiciono comportamento a um record com `extension`.
- [ ] Justifico, num caso concreto, a escolha entre record e classe.
- [ ] Troco duas variáveis com `(a, b) = (b, a);`.
- [ ] Rodei `bin/aula04_records.dart` e conferi cada bloco da saída.

---

## 📚 Referências oficiais

- [Records — dart.dev](https://dart.dev/language/records)
- [Patterns — dart.dev](https://dart.dev/language/patterns)
- [Extension methods — dart.dev](https://dart.dev/language/extension-methods)
- [Object.hash — api.dart.dev](https://api.dart.dev/stable/dart-core/Object/hash.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Streams](03-streams.md) | [README](README.md) | [Aula 5 — Patterns e switch](05-patterns-e-switch.md) |
