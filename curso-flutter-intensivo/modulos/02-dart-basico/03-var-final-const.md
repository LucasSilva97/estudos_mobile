# Aula 3 — `var`, `final`, `const` e `late`

> **Módulo:** 02 - Dart Básico · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Declarar variáveis com `var`, `final`, `const` e `late` e justificar cada escolha.
- Explicar o que é **inferência de tipo** e quando escrever o tipo à mão mesmo assim.
- Diferenciar **tempo de compilação** (`const`) de **tempo de execução** (`final`).
- Entender por que `final` protege a variável, não o conteúdo dela.
- Usar `late` para inicialização preguiçosa e saber o risco que ela traz.
- Antecipar por que `const` é uma das ferramentas de desempenho mais importantes do Flutter.

## ✅ Pré-requisitos

- [Aula 1](01-anatomia-de-um-programa.md) e [Aula 2](02-sintaxe-convencoes-comentarios.md).
- Noção de variável e constante — [Módulo 01, Aula 4](../01-logica-e-fundamentos/04-variaveis-e-constantes.md).

## 📖 Conceito

Em Dart existem quatro formas de declarar uma variável, e a escolha entre elas comunica
**intenção**. Quem lê o seu código descobre, só pelo declarador, se aquele valor vai mudar,
quando ele é conhecido e se ele existe desde o início.

### `var` — pode mudar, tipo inferido

```dart
var minutos = 45;      // Dart deduz: int
minutos = 60;          // permitido
// minutos = 'uma hora'; // ERRO: já é int, não aceita String
```

> **Inferência de tipo** — o compilador olha o valor que você atribuiu e descobre sozinho o
> tipo da variável. `var minutos = 45` é **idêntico** a `int minutos = 45` depois de compilado.

Ponto importante: `var` **não** significa "sem tipo". Dart é estaticamente tipado. Uma vez que
o tipo foi inferido, ele é permanente. Se você realmente quer aceitar qualquer coisa, precisa
escrever `dynamic` — e vai ficar sem a proteção do compilador, o que raramente compensa.

```dart
dynamic qualquerCoisa = 45;
qualquerCoisa = 'agora é texto';   // permitido, e perigoso
```

Quando você declara sem valor inicial, não há o que inferir, e o tipo vira `dynamic`:

```dart
var x;        // x é dynamic — evite
int? y;       // melhor: diz o tipo e admite nulo
```

### `final` — atribuída uma vez, valor conhecido em execução

```dart
final agora = DateTime.now();   // valor só existe quando o programa roda
// agora = DateTime.now();      // ERRO: já foi atribuída
```

`final` diz: "esta variável recebe valor **uma única vez** e depois não é reatribuída".
O valor pode vir de qualquer lugar — do relógio, de um cálculo, do que a pessoa digitou.

Você pode combinar com o tipo explícito: `final String nome = 'Lucas';`

### `const` — valor congelado em tempo de compilação

```dart
const minutosPorHora = 60;
const diasDaSemana = 7;
const horasPorSemana = 24 * 7;   // cálculo com valores já conhecidos: permitido
// const agora = DateTime.now(); // ERRO: só se sabe em execução
```

> **Tempo de compilação** — o momento em que o Dart traduz o seu código, **antes** de rodar.
> **Tempo de execução** — o momento em que o programa está rodando de verdade.

`const` exige que o valor seja conhecido no primeiro momento. Em troca, o Dart faz algo valioso:
**canonicalização**. Dois `const` com o mesmo conteúdo viram, na memória, **o mesmo objeto**.

```dart
const a = [1, 2, 3];
const b = [1, 2, 3];
print(identical(a, b));   // true — é literalmente o mesmo objeto

final c = [1, 2, 3];
final d = [1, 2, 3];
print(identical(c, d));   // false — dois objetos diferentes
```

Essa única linha explica boa parte do desempenho do Flutter, como você vai ver adiante.

### `final` protege a variável, não o conteúdo

Esta é a confusão nº 1 de quem começa:

```dart
final materias = ['Dart', 'Flutter'];
materias.add('Git');        // PERMITIDO — a lista mudou
print(materias);            // [Dart, Flutter, Git]
// materias = ['Outra'];    // ERRO — a variável não pode apontar para outra lista
```

`final` impede **reatribuir**. A lista continua sendo modificável por dentro.

Para congelar o conteúdo também, use `const`:

```dart
const materias = ['Dart', 'Flutter'];
materias.add('Git');        // compila, mas EXPLODE em execução
```

```text
Unhandled exception:
Unsupported operation: Cannot add to an unmodifiable list
```

### `late` — prometo inicializar antes de usar

```dart
late String configuracao;

void iniciar() {
  configuracao = 'modo intensivo';
}
```

`late` diz ao compilador: "confie em mim, vou atribuir antes de alguém ler". O compilador aceita
e troca a verificação de tempo de compilação por uma **verificação em tempo de execução**. Se
você quebrar a promessa:

```text
LateInitializationError: Local 'configuracao' has not been initialized.
```

O segundo uso de `late`, muito mais interessante, é a **inicialização preguiçosa**
(*lazy*): com inicializador, o cálculo só acontece na **primeira leitura**.

```dart
late final String relatorio = gerarRelatorioCaro();
// gerarRelatorioCaro() ainda NÃO rodou aqui.
print(relatorio);   // roda agora, e guarda o resultado
print(relatorio);   // não roda de novo, reaproveita
```

### Tabela de decisão

| Situação | Use | Por quê |
|---|---|---|
| Valor fixo, conhecido ao escrever o código (60, 'kg', `[1,2,3]`) | `const` | Compartilhado na memória, não pode mudar nunca |
| Valor calculado uma vez e não reatribuído | `final` | Comunica "isto não muda" e o compilador garante |
| Valor que realmente é reatribuído (acumulador, contador de laço) | `var` | Único caso em que reatribuir faz parte da intenção |
| Valor caro que talvez nem seja usado | `late final` com inicializador | Só calcula se alguém ler |
| Valor que não existe no início mas existirá antes do uso | `late` | Evita ter que declarar como anulável |

**Regra prática do curso:** comece sempre com `const`. Se não der, use `final`. Só use `var`
quando você for realmente reatribuir. `late` é a última opção, e sempre com um comentário
explicando por quê.

## 💡 Analogia

Pense em três recipientes de cozinha:

- `var` é um **pote reutilizável**: você tira o arroz e põe feijão quando quiser.
- `final` é um **pote lacrado depois de cheio**: você escolhe o que colocar no momento em que
  enche, mas depois de fechado ninguém troca o conteúdo por outro. Só que, se dentro dele houver
  uma sacola aberta, alguém ainda pode mexer **dentro da sacola** — é exatamente isso que
  acontece com `final materias` e `materias.add(...)`.
- `const` é uma **peça de fábrica**: já veio pronta de antes, todas as unidades idênticas são
  literalmente a mesma peça no estoque, e não existe ferramenta que abra.

`late` é um **pote com etiqueta escrita antes de você comprar o conteúdo**. Você assume o
compromisso de encher antes de servir; se servir vazio, o jantar acaba ali.

## 🧪 Exemplo mínimo

```dart
void main() {
  const int minutosPorHora = 60;      // nunca muda, conhecido agora
  final DateTime inicio = DateTime.now(); // conhecido só ao rodar
  var totalMinutos = 0;                // vai ser somado várias vezes

  for (final int sessao in <int>[45, 30, 60]) {
    totalMinutos += sessao;
  }

  print('Total: $totalMinutos minutos');
  print('Horas completas: ${totalMinutos ~/ minutosPorHora}');
  print('Registrado em: ${inicio.year}');
}
```

```text
Total: 135 minutos
Horas completas: 2
Registrado em: 2026
```

## 📱 Aplicando no Flutter

Aqui `const` deixa de ser detalhe de estilo e vira **desempenho medível**.

No Flutter, a tela é descrita por *widgets*.

> **Widget** — um objeto que descreve um pedaço da interface: um texto, um botão, um espaçamento.
> A tela inteira é uma árvore de widgets. Tema de
> [05 — main, runApp e a árvore de widgets](../05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md).

Sempre que algo muda na tela, o Flutter **reconstrói** a árvore, chamando de novo os
construtores dos widgets. Se um widget é `const`, acontece a canonicalização que você acabou de
ver: o Flutter recebe **o mesmo objeto de antes**, percebe que é idêntico e **pula** a
reconstrução daquele ramo.

```dart
// Reconstruído a cada mudança de tela:
Text('Minhas matérias')

// Criado uma única vez e reaproveitado para sempre:
const Text('Minhas matérias')
```

É por isso que o `flutter_lints` tem a regra `prefer_const_constructors` e o VS Code vai
sublinhar seus widgets sugerindo `const`. E é por isso que a especificação técnica deste curso
manda usar `const` em todo widget que puder.

Você também vai reencontrar os outros três:

| Declarador | Uso típico no Flutter |
|---|---|
| `const` | Widgets sem dados variáveis, cores, espaçamentos, ícones |
| `final` | Campos de um `StatelessWidget` (todos são `final` por obrigação) e resultados de API |
| `var` | Contadores e acumuladores dentro de um método |
| `late final` | Um `TextEditingController` criado em `initState` e usado em toda a tela |

O aprofundamento está em
[13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md), e o
primeiro contato prático em
[05 — StatelessWidget](../05-introducao-ao-flutter/04-statelesswidget.md).

## 💻 Código completo

> **Arquivo:** `dart_basico/bin/variaveis.dart`
> **Como executar:** `dart run bin/variaveis.dart`

```dart
// bin/variaveis.dart
// Demonstra: var, final, const, late, inferência e mutabilidade de conteúdo.

/// Minutos que compõem uma hora. Valor fixo, conhecido em tempo de compilação.
const int minutosPorHora = 60;

/// Matérias padrão sugeridas pelo curso.
///
/// `const` congela a lista inteira: ninguém consegue acrescentar itens.
const List<String> materiasPadrao = <String>['Dart', 'Flutter', 'Git'];

/// Simula um cálculo demorado, para demonstrar o `late` preguiçoso.
String gerarRelatorioCaro() {
  print('  >> gerarRelatorioCaro() executou agora');
  return 'Relatório completo do mês';
}

void main() {
  print('=== 1. Inferência de tipo ===');
  var minutos = 45; // inferido como int
  final nome = 'Lucas'; // inferido como String
  const meta = 600; // inferido como int
  print('minutos é ${minutos.runtimeType}, valor $minutos');
  print('nome é ${nome.runtimeType}, valor $nome');
  print('meta é ${meta.runtimeType}, valor $meta');

  print('');
  print('=== 2. var pode ser reatribuída ===');
  minutos = 90;
  minutos += 30;
  print('minutos agora: $minutos');

  print('');
  print('=== 3. const é compartilhado na memória ===');
  const List<int> a = <int>[1, 2, 3];
  const List<int> b = <int>[1, 2, 3];
  final List<int> c = <int>[1, 2, 3];
  final List<int> d = <int>[1, 2, 3];
  print('identical(a, b) com const : ${identical(a, b)}');
  print('identical(c, d) com final : ${identical(c, d)}');

  print('');
  print('=== 4. final protege a variável, não o conteúdo ===');
  final List<String> minhasMaterias = <String>['Dart', 'Flutter'];
  minhasMaterias.add('Git'); // permitido
  print('Depois do add: $minhasMaterias');
  // minhasMaterias = <String>['Outra'];  // não compila: reatribuição

  print('');
  print('=== 5. const congela o conteúdo ===');
  print('Matérias padrão: $materiasPadrao');
  try {
    materiasPadrao.add('Kotlin');
  } on UnsupportedError catch (erro) {
    print('Erro esperado ao tentar modificar: ${erro.message}');
  }

  print('');
  print('=== 6. const só aceita valor de tempo de compilação ===');
  const int horasPorSemana = 24 * 7; // cálculo entre constantes: OK
  final DateTime agora = DateTime.now(); // só existe ao rodar
  // const DateTime invalido = DateTime.now();  // não compila
  print('horasPorSemana: $horasPorSemana');
  print('Ano atual (final, em execução): ${agora.year}');

  print('');
  print('=== 7. late com inicializador é preguiçoso ===');
  print('Antes de ler a variável...');
  late final String relatorio = gerarRelatorioCaro();
  print('Declarada, mas ainda não executou.');
  print('Primeira leitura: $relatorio');
  print('Segunda leitura : $relatorio'); // não executa de novo

  print('');
  print('=== 8. late sem inicializador exige disciplina ===');
  late String periodo;
  final int hora = agora.hour;
  if (hora < 12) {
    periodo = 'manhã';
  } else if (hora < 18) {
    periodo = 'tarde';
  } else {
    periodo = 'noite';
  }
  print('Período do dia: $periodo');

  print('');
  print('=== 9. Escolhendo na prática ===');
  const String unidade = 'min';
  final List<int> sessoes = <int>[45, 30, minutos];
  var total = 0;
  for (final int sessao in sessoes) {
    total += sessao;
  }
  final int horas = total ~/ minutosPorHora;
  final int resto = total % minutosPorHora;
  print('Sessões: $sessoes');
  print('Total: $total $unidade  ->  ${horas}h${resto.toString().padLeft(2, '0')}');
  print('Meta do dia: $meta $unidade');
  print('Faltam: ${meta - total} $unidade');
}
```

Saída esperada (o ano e o período variam conforme o relógio da sua máquina):

```text
=== 1. Inferência de tipo ===
minutos é int, valor 45
nome é String, valor Lucas
meta é int, valor 600

=== 2. var pode ser reatribuída ===
minutos agora: 120

=== 3. const é compartilhado na memória ===
identical(a, b) com const : true
identical(c, d) com final : false

=== 4. final protege a variável, não o conteúdo ===
Depois do add: [Dart, Flutter, Git]

=== 5. const congela o conteúdo ===
Matérias padrão: [Dart, Flutter, Git]
Erro esperado ao tentar modificar: Cannot add to an unmodifiable list

=== 6. const só aceita valor de tempo de compilação ===
horasPorSemana: 168
Ano atual (final, em execução): 2026

=== 7. late com inicializador é preguiçoso ===
Antes de ler a variável...
Declarada, mas ainda não executou.
  >> gerarRelatorioCaro() executou agora
Primeira leitura: Relatório completo do mês
Segunda leitura : Relatório completo do mês

=== 8. late sem inicializador exige disciplina ===
Período do dia: tarde

=== 9. Escolhendo na prática ===
Sessões: [45, 30, 120]
Total: 195 min  ->  3h15
Meta do dia: 600 min
Faltam: 405 min
```

## 🔍 Explicando o código

**`minutos.runtimeType`**
Devolve o tipo real do objeto em tempo de execução. Prova que `var minutos = 45` produziu um
`int`, e não algo "sem tipo".

**`identical(a, b)`**
Função do Dart que responde: "estes dois nomes apontam para o **mesmo objeto** na memória?".
Diferente de `==`, que compara conteúdo. Para as listas `const`, dá `true` por causa da
canonicalização; para as `final`, `false`, porque são duas listas criadas separadamente.

**`minhasMaterias.add('Git')` funcionar com `final`**
`final` congela a **ligação** entre o nome e o objeto. O objeto lista continua mutável. Se você
quiser uma lista `final` que também não aceite mudanças, o caminho é
`final lista = List<String>.unmodifiable([...])` — visto na [Aula 8](08-listas.md).

**`on UnsupportedError catch (erro)`**
Uma lista `const` é internamente **imutável**; `add` nela lança `UnsupportedError` com a mensagem
`Cannot add to an unmodifiable list`. Capturamos só para provar o comportamento sem derrubar o
programa.

**`const int horasPorSemana = 24 * 7;`**
O cálculo é feito **durante a compilação**. O binário já carrega o número 168; nenhuma
multiplicação acontece quando o programa roda.

**`late final String relatorio = gerarRelatorioCaro();`**
A combinação `late final` com inicializador é a inicialização preguiçosa: a função não roda na
linha da declaração, e sim na primeira vez que `relatorio` é lida. O resultado fica guardado,
então a segunda leitura não chama a função de novo — a saída prova isso: a mensagem
`>> gerarRelatorioCaro() executou agora` aparece **uma vez só**.

**`late String periodo;` atribuída dentro do `if`/`else`**
Sem `late`, o Dart exigiria que `periodo` fosse inicializada na declaração ou provada atribuída
em todos os caminhos. Neste caso específico, como há `else`, um `final String periodo;` também
funcionaria — e seria a escolha melhor. `late` aqui existe para você ver a sintaxe; na vida
real, prefira `final` sem `late` sempre que o compilador conseguir provar a atribuição.

**`total ~/ minutosPorHora` e `total % minutosPorHora`**
Divisão inteira e resto, como na [Aula 2](02-sintaxe-convencoes-comentarios.md).

## ⚠️ Erros comuns

**1. Achar que `var` é "sem tipo"**

```dart
var minutos = 45;
minutos = 'uma hora';
```

```text
Error: A value of type 'String' can't be assigned to a variable of type 'int'.
```

O tipo foi inferido e é definitivo.

**2. Tentar `const` com valor de execução**

```dart
const inicio = DateTime.now();
```

```text
Error: Cannot invoke a non-'const' constructor where a const expression is expected.
```

Troque por `final`.

**3. Reatribuir um `final`**

```text
Error: Can't assign to the final variable 'nome'.
```

**4. Achar que `final` congela a lista**
Ele não congela. `final lista = [1,2]; lista.add(3);` funciona. Se você precisa congelar o
conteúdo, use `const` (quando o conteúdo é conhecido) ou `List.unmodifiable`.

**5. Usar `late` para "calar" o compilador**

```text
LateInitializationError: Local 'periodo' has not been initialized.
```

`late` não resolve o problema; adia a explosão para o tempo de execução, quando o usuário já
está usando o app. Se o valor pode não existir, o certo é declarar anulável (`String?`) e tratar
o nulo — assunto da [Aula 5](05-null-safety.md).

**6. Declarar `var x;` sem valor**
Vira `dynamic` e você perde toda a proteção do compilador. Escreva o tipo: `int? x;`.

**7. Esquecer o `const` no Flutter**
Não é erro de compilação, é desperdício. O lint avisa:

```text
info • Use 'const' with the constructor to improve performance • prefer_const_constructors
```

## 🛠️ Exercício guiado

**Passo 1.** Crie `bin/variaveis.dart` e digite o código completo.

**Passo 2.** Rode:

```powershell
dart run bin/variaveis.dart
```

**Passo 3 — prove que `const` não aceita execução.** Descomente a linha:

```dart
// const DateTime invalido = DateTime.now();
```

Rode de novo e **leia a mensagem de erro inteira**. Depois comente novamente.

**Passo 4 — prove que `final` não pode ser reatribuída.** Descomente:

```dart
// minhasMaterias = <String>['Outra'];
```

Leia o erro `Can't assign to the final variable`. Comente novamente.

**Passo 5 — quebre o `late` de propósito.** Logo depois de `late String periodo;`, acrescente:

```dart
print(periodo);
```

Rode. Você vai ver:

```text
Unhandled exception:
LateInitializationError: Local 'periodo' has not been initialized.
```

Apague essa linha. Esse erro vai voltar a te visitar no Flutter — reconheça-o agora.

**Passo 6 — troque `late final` por `final`.** Mude a linha do relatório para:

```dart
final String relatorio = gerarRelatorioCaro();
```

Rode e observe: agora a mensagem `>> gerarRelatorioCaro() executou agora` aparece **antes** de
"Declarada, mas ainda não executou". Essa é a diferença entre preguiçoso e imediato. Volte para
`late final` ao final.

**Passo 7.** Rode `dart analyze` e garanta `No issues found!`.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md)

Priorize os de **Leitura de código**: eles treinam justamente prever qual declaração compila.

## 🏆 Desafio opcional

Escreva `bin/decisao.dart` que declare, com o declarador **mais restritivo possível** em cada
caso, e imprima um relatório de sessão de estudo com:

1. A duração padrão de uma sessão (25 minutos) — deve ser impossível mudar, sempre.
2. A lista fixa de técnicas suportadas (`['Pomodoro', 'Blocos longos', 'Revisão espaçada']`) —
   ninguém pode acrescentar item.
3. O horário de início da sessão — só existe quando o programa roda.
4. Um acumulador de minutos que cresce dentro de um laço.
5. Uma frase motivacional gerada por uma função que imprime `>> gerou` ao ser chamada, e que
   **só deve executar se** o total de minutos passar de 100.

Critério de acerto: se você conseguir transformar algum `final` em `const` sem quebrar o
programa, a escolha original estava frouxa. E a função do item 5 deve imprimir `>> gerou`
**zero vezes** quando o total for 90.

## 📌 Resumo

- `var` — reatribuível, tipo inferido e permanente. Use só quando for realmente reatribuir.
- `final` — atribuída uma vez, valor conhecido em **tempo de execução**.
- `const` — valor conhecido em **tempo de compilação**, congelado e canonicalizado (objetos
  `const` iguais são o mesmo objeto).
- `final` impede reatribuir a variável; **não** impede modificar o conteúdo de uma lista.
- `const` impede as duas coisas: mexer no conteúdo lança `UnsupportedError`.
- `late` adia a inicialização para o tempo de execução; com inicializador, torna o cálculo
  preguiçoso; sem cuidado, produz `LateInitializationError`.
- Ordem de preferência do curso: `const` → `final` → `var`, e `late` só com justificativa.
- No Flutter, `const` em widgets evita reconstruções e é cobrado por lint.

## ☑️ Checklist de domínio

- [ ] Sei explicar a diferença entre `final` e `const` em uma frase.
- [ ] Sei dizer por que `final lista = [...]; lista.add(x);` compila e roda.
- [ ] Já vi, no meu terminal, `identical` devolver `true` para `const` e `false` para `final`.
- [ ] Já provoquei e li um `LateInitializationError`.
- [ ] Já provoquei e li o erro `Cannot add to an unmodifiable list`.
- [ ] Consigo justificar por que `const DateTime.now()` não compila.
- [ ] Entendi por que `const` importa para o desempenho do Flutter.
- [ ] Meu `bin/variaveis.dart` passa em `dart analyze` sem avisos.

## 📚 Referências oficiais

- [Dart — Variables](https://dart.dev/language/variables)
- [Dart — Built-in types](https://dart.dev/language/built-in-types)
- [Dart — Effective Dart: Usage](https://dart.dev/effective-dart/usage)
- [Dart — Type system](https://dart.dev/language/type-system)
- [Flutter — Performance best practices](https://docs.flutter.dev/perf/best-practices)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Sintaxe, convenções e comentários](02-sintaxe-convencoes-comentarios.md) | [README](README.md) | [Tipos, strings e conversões](04-tipos-strings-conversoes.md) |
