# Aula 7 — Enums

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Declarar um `enum` simples e explicar por que ele é melhor que `String` ou `int` mágicos.
- Usar `values`, `index`, `name` e `values.byName(...)`.
- Escrever um `switch` **exaustivo** sobre um enum, sem `default`, e dizer por que isso é uma
  vantagem enorme de manutenção.
- Criar um **enum avançado** (*enhanced enum*): com campos, construtor `const`, getters, métodos e
  membros estáticos.
- Saber por que **nunca** se guarda o `index` de um enum em banco de dados.

## ✅ Pré-requisitos

- [Aula 2 — Construtores](02-construtores.md) (construtor `const`).
- [Aula 3 — Encapsulamento](03-encapsulamento.md) (getters).
- `switch` do [Módulo 02](../02-dart-basico/06-controle-de-fluxo.md).

---

## 📖 Conceito

### O problema: valores mágicos

Como você representaria o estado de uma sessão de estudo?

```dart
String status = 'em_andamento'; // ❌
```

Três desastres esperando para acontecer:

1. **Erro de digitação passa batido.** `'em_andamemto'` compila, roda e quebra a lógica em silêncio.
2. **Não existe lista de valores válidos.** Quantos estados existem? Só lendo o código inteiro.
3. **O compilador não ajuda.** Se você acrescentar o estado `'cancelada'` amanhã, nada aponta os 12
   lugares que precisam tratar o caso novo.

Com `int` é ainda pior: `status = 3` não diz nada a quem lê.

### `enum`: um conjunto fechado e nomeado

```dart
enum StatusDaSessao { naoIniciada, emAndamento, pausada, concluida, cancelada }
```

Agora:

- `StatusDaSessao.pausada` é um **tipo**, verificado na compilação. Digitou errado, não compila.
- A lista de valores possíveis é a própria declaração.
- O compilador **sabe** que existem exatamente cinco, e vai cobrar isso de você nos `switch`.

Cada constante de um enum é um objeto único, `const` e canonicalizado — comparar com `==` é seguro
e barato.

### Membros que todo enum já tem

| Membro | O que faz | Exemplo |
|---|---|---|
| `values` | `List` com todas as constantes, na ordem de declaração | `StatusDaSessao.values` |
| `index` | Posição na declaração, começando em 0 | `StatusDaSessao.pausada.index` → `2` |
| `name` | O nome da constante, como `String` | `StatusDaSessao.pausada.name` → `'pausada'` |
| `values.byName('x')` | Busca a constante pelo nome; lança se não existir | `StatusDaSessao.values.byName('pausada')` |
| `toString()` | `'StatusDaSessao.pausada'` | útil para depurar |

⚠️ **Regra de ouro sobre `index`:** ele é **posicional**. Se você reordenar as constantes, todos os
índices mudam. Por isso:

> **Nunca guarde `index` em banco de dados, arquivo ou API. Guarde `name`.**

Um dia alguém vai inserir `pausada` no meio da lista, e todas as sessões salvas no banco vão virar
outra coisa. Com `name`, isso não acontece. Você aplica essa regra de verdade no
[Módulo 10](../10-persistencia-de-dados/05-sqflite-crud.md).

### `switch` exaustivo

Esta é a maior vantagem prática dos enums.

```dart
String mensagemDe(StatusDaSessao status) => switch (status) {
      StatusDaSessao.naoIniciada => 'Pronta para começar.',
      StatusDaSessao.emAndamento => 'Foco total!',
      StatusDaSessao.pausada => 'Pausada.',
      StatusDaSessao.concluida => 'Concluída.',
      StatusDaSessao.cancelada => 'Cancelada.',
    };
```

Isso é uma **switch expression**: ela **devolve um valor**, usa `=>` por caso e vírgula no fim de
cada linha. (A forma clássica, `switch` como comando com `case:`, continua existindo — o código
completo mostra as duas.)

O ponto crucial: **não há `default`**. E é de propósito. Se amanhã você acrescentar
`StatusDaSessao.expirada` ao enum, o Dart acusa **erro de compilação** em todos os `switch`
incompletos:

```text
Error: The type 'StatusDaSessao' is not exhaustively matched by the switch cases
since it doesn't match 'StatusDaSessao.expirada'.
```

O compilador vira a sua lista de tarefas. Colocar um `default: return 'outro';` destrói justamente
essa proteção — o código compilaria e o estado novo cairia silenciosamente no caso genérico.

> 🧭 Regra do curso: **`switch` sobre enum nunca leva `default`.**

Os detalhes de `switch` com padrões (patterns) vêm em
[`04-dart-avancado/05-patterns-e-switch.md`](../04-dart-avancado/05-patterns-e-switch.md).

### Enum avançado (*enhanced enum*)

Desde o Dart 2.17, um enum pode ter **campos, construtor, getters, métodos e membros estáticos**.
É um recurso maravilhoso e pouco conhecido.

```dart
enum NivelDeEnergia {
  baixa('Baixa', 15),
  media('Média', 30),
  alta('Alta', 50);          // ponto e vírgula fecha a lista de constantes

  const NivelDeEnergia(this.rotulo, this.minutosSugeridos);

  final String rotulo;
  final int minutosSugeridos;

  Duration get duracaoSugerida => Duration(minutes: minutosSugeridos);
}
```

Regras obrigatórias:

1. As **constantes vêm primeiro**, separadas por vírgula, e a lista termina em `;`.
2. O construtor precisa ser `const`.
3. Os campos precisam ser `final`.
4. Você não pode sobrescrever `index`, `hashCode`, `==` nem declarar um membro chamado `values`.

Um enum avançado também pode usar mixins e implementar interfaces:
`enum X with Logavel implements Comparable<X> { ... }`.

**Quando usar o avançado em vez do simples?** Quando você perceber que está escrevendo um `switch`
só para traduzir a constante em um dado fixo (um rótulo, um ícone, um número). Esse dado **pertence
à constante** — coloque-o lá dentro e o `switch` desaparece.

---

## 💡 Analogia

Os **estados civis** de um formulário: solteiro, casado, divorciado, viúvo.

- Escrever o estado civil como texto livre (`String`) permite "Cazado", "casado ", "CASADO" — quatro
  valores diferentes para a mesma coisa. É o valor mágico.
- A lista fechada de opções do formulário é o **enum**.
- Quando o governo cria um novo estado civil, **todo** sistema precisa ser revisado. O `switch`
  exaustivo é o auditor que percorre o sistema inteiro e aponta cada lugar esquecido —
  antes de o programa rodar.

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_enum.dart`
> **Como executar:** `dart run bin/exemplo_enum.dart`

```dart
enum Prioridade { baixa, media, alta }

String comoTratar(Prioridade prioridade) => switch (prioridade) {
      Prioridade.baixa => 'Deixe para o fim de semana.',
      Prioridade.media => 'Encaixe hoje se sobrar tempo.',
      Prioridade.alta => 'Faça agora, antes de qualquer outra coisa.',
    };

void main() {
  for (final prioridade in Prioridade.values) {
    print('${prioridade.index} · ${prioridade.name}: ${comoTratar(prioridade)}');
  }

  final escolhida = Prioridade.values.byName('alta');
  print('Escolhida: $escolhida');
}
```

Saída:

```text
0 · baixa: Deixe para o fim de semana.
1 · media: Encaixe hoje se sobrar tempo.
2 · alta: Faça agora, antes de qualquer outra coisa.
Escolhida: Prioridade.alta
```

Agora faça o teste que ensina: acrescente `urgente` ao enum e rode de novo. O programa **não
compila** até você tratar o caso novo. Esse erro é o seu melhor amigo.

---

## 📱 Aplicando no Flutter

Enums estão por toda parte no Flutter, em dois papéis.

**1. Os enums que o framework te dá.** Quase toda propriedade de layout é um enum:

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: const [Text('Dart'), Text('Flutter')],
)
```

`MainAxisAlignment`, `TextAlign`, `ThemeMode`, `Axis` — todos enums. É por isso que o editor te
oferece a lista fechada de opções assim que você digita o ponto. Você usa isso já no
[Módulo 06](../06-widgets-e-layouts/04-row-column-expanded.md).

**2. Os enums que você cria para descrever a tela.** O caso mais comum é o **estado da UI**:

```dart
enum EstadoDaTela { carregando, vazio, comDados, erro }

Widget corpo(EstadoDaTela estado) => switch (estado) {
      EstadoDaTela.carregando => const Center(child: CircularProgressIndicator()),
      EstadoDaTela.vazio => const Center(child: Text('Nenhuma matéria ainda')),
      EstadoDaTela.comDados => const ListaDeMaterias(),
      EstadoDaTela.erro => const Center(child: Text('Algo deu errado')),
    };
```

Repare que o `switch` exaustivo aqui vira uma garantia de **qualidade de interface**: é
impossível esquecer de desenhar a tela de erro ou a tela vazia, porque o compilador não deixa.
Esse é exatamente o assunto de
[`06-widgets-e-layouts/12-estados-de-ui.md`](../06-widgets-e-layouts/12-estados-de-ui.md).

No módulo 08 você descobre que o Riverpod já entrega esse "carregando / erro / dados" pronto, num
tipo chamado `AsyncValue` — que é a mesma ideia levada adiante
([`08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md`](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)).

---

## 💻 Código completo

> **Arquivo:** `bin/07_enums.dart`
> **Como executar:** `dart run bin/07_enums.dart`

```dart
// Aula 7 do Módulo 03 — Enums simples, switch exaustivo e enums avançados.

// ===========================================================================
// PARTE 1 — ENUM SIMPLES
// ===========================================================================

enum StatusDaSessao { naoIniciada, emAndamento, pausada, concluida, cancelada }

/// switch EXPRESSION: devolve um valor. Sem `default`, de propósito.
String mensagemDe(StatusDaSessao status) => switch (status) {
      StatusDaSessao.naoIniciada => 'Pronta para começar. Toque em iniciar.',
      StatusDaSessao.emAndamento => 'Foco total! O cronômetro está correndo.',
      StatusDaSessao.pausada => 'Pausada. Retome quando puder.',
      StatusDaSessao.concluida => 'Concluída. Minutos registrados na matéria.',
      StatusDaSessao.cancelada => 'Cancelada. Nada foi registrado.',
    };

/// switch STATEMENT (a forma clássica), também exaustivo.
/// Dois `case` juntos compartilham o mesmo corpo.
bool podeIniciar(StatusDaSessao status) {
  switch (status) {
    case StatusDaSessao.naoIniciada:
    case StatusDaSessao.pausada:
      return true;
    case StatusDaSessao.emAndamento:
    case StatusDaSessao.concluida:
    case StatusDaSessao.cancelada:
      return false;
  }
}

// ===========================================================================
// PARTE 2 — ENUM AVANÇADO (campos, construtor const, getters, métodos, static)
// ===========================================================================

enum NivelDeEnergia {
  // 1) As constantes vêm primeiro, com os argumentos do construtor.
  baixa('Baixa', 15, '🪫'),
  media('Média', 30, '🔋'),
  alta('Alta', 50, '⚡'); // o ponto e vírgula fecha a lista

  // 2) Construtor: obrigatoriamente `const`.
  const NivelDeEnergia(this.rotulo, this.minutosSugeridos, this.icone);

  // 3) Campos: obrigatoriamente `final`.
  final String rotulo;
  final int minutosSugeridos;
  final String icone;

  // 4) Getters comuns.
  Duration get duracaoSugerida => Duration(minutes: minutosSugeridos);

  bool get permiteSessaoLonga => minutosSugeridos >= 30;

  // 5) Métodos comuns.
  String descrever() => '$icone $rotulo — sugere $minutosSugeridos min';

  // 6) Membro estático: pertence ao enum, não a uma constante.
  static NivelDeEnergia paraMinutosDisponiveis(int minutos) {
    if (minutos >= 50) {
      return alta;
    }
    if (minutos >= 30) {
      return media;
    }
    return baixa;
  }
}

// ===========================================================================
// PARTE 3 — MODELO QUE USA OS DOIS ENUMS
// ===========================================================================

class Sessao {
  final String materia;
  final StatusDaSessao status;
  final NivelDeEnergia energia;

  const Sessao({
    required this.materia,
    this.status = StatusDaSessao.naoIniciada,
    this.energia = NivelDeEnergia.media,
  });

  Sessao copyWith({StatusDaSessao? status, NivelDeEnergia? energia}) => Sessao(
        materia: materia,
        status: status ?? this.status,
        energia: energia ?? this.energia,
      );

  @override
  String toString() => '$materia [${status.name}] ${energia.icone}';
}

// ===========================================================================
// PROGRAMA
// ===========================================================================

void main() {
  print('--- 1. Membros que todo enum já tem ---');
  final nomes = StatusDaSessao.values.map((status) => status.name).toList();
  print('Valores: $nomes');
  print('Quantidade: ${StatusDaSessao.values.length}');
  print('pausada -> index ${StatusDaSessao.pausada.index}, '
      'name "${StatusDaSessao.pausada.name}"');
  print('toString(): ${StatusDaSessao.pausada}');
  print('byName("concluida"): ${StatusDaSessao.values.byName('concluida')}');

  print('');
  print('--- 2. switch exaustivo sobre todos os valores ---');
  for (final status in StatusDaSessao.values) {
    final pode = podeIniciar(status) ? 'pode iniciar' : 'não pode iniciar';
    print('${status.name.padRight(12)} $pode | ${mensagemDe(status)}');
  }

  print('');
  print('--- 3. Enum avançado ---');
  for (final nivel in NivelDeEnergia.values) {
    print('${nivel.descrever()} (sessão longa? ${nivel.permiteSessaoLonga})');
  }
  print('Duração sugerida da alta: ${NivelDeEnergia.alta.duracaoSugerida}');
  print('Com 40 min livres: '
      '${NivelDeEnergia.paraMinutosDisponiveis(40).descrever()}');
  print('Com 12 min livres: '
      '${NivelDeEnergia.paraMinutosDisponiveis(12).descrever()}');

  print('');
  print('--- 4. Enums dentro de um modelo ---');
  const sessao = Sessao(materia: 'Dart', energia: NivelDeEnergia.alta);
  final iniciada = sessao.copyWith(status: StatusDaSessao.emAndamento);
  final finalizada = iniciada.copyWith(status: StatusDaSessao.concluida);
  print(sessao);
  print(iniciada);
  print(finalizada);

  print('');
  print('--- 5. Contagem por status ---');
  const historico = <StatusDaSessao>[
    StatusDaSessao.concluida,
    StatusDaSessao.concluida,
    StatusDaSessao.cancelada,
    StatusDaSessao.emAndamento,
    StatusDaSessao.concluida,
  ];

  final contagem = <StatusDaSessao, int>{};
  for (final status in historico) {
    contagem[status] = (contagem[status] ?? 0) + 1;
  }

  // Percorrer `values` garante que TODOS os status apareçam no relatório,
  // inclusive os que não ocorreram nenhuma vez.
  for (final status in StatusDaSessao.values) {
    print('${status.name.padRight(12)} ${contagem[status] ?? 0}');
  }
}
```

**Saída esperada:**

```text
--- 1. Membros que todo enum já tem ---
Valores: [naoIniciada, emAndamento, pausada, concluida, cancelada]
Quantidade: 5
pausada -> index 2, name "pausada"
toString(): StatusDaSessao.pausada
byName("concluida"): StatusDaSessao.concluida

--- 2. switch exaustivo sobre todos os valores ---
naoIniciada  pode iniciar | Pronta para começar. Toque em iniciar.
emAndamento  não pode iniciar | Foco total! O cronômetro está correndo.
pausada      pode iniciar | Pausada. Retome quando puder.
concluida    não pode iniciar | Concluída. Minutos registrados na matéria.
cancelada    não pode iniciar | Cancelada. Nada foi registrado.

--- 3. Enum avançado ---
🪫 Baixa — sugere 15 min (sessão longa? false)
🔋 Média — sugere 30 min (sessão longa? true)
⚡ Alta — sugere 50 min (sessão longa? true)
Duração sugerida da alta: 0:50:00.000000
Com 40 min livres: 🔋 Média — sugere 30 min
Com 12 min livres: 🪫 Baixa — sugere 15 min

--- 4. Enums dentro de um modelo ---
Dart [naoIniciada] ⚡
Dart [emAndamento] ⚡
Dart [concluida] ⚡

--- 5. Contagem por status ---
naoIniciada  0
emAndamento  1
pausada      0
concluida    3
cancelada    1
```

---

## 🔍 Explicando o código

**`enum StatusDaSessao { ... }`**
Cinco constantes, cinco objetos únicos e `const`. `StatusDaSessao.pausada == StatusDaSessao.pausada`
é sempre `true` e não custa nada.

**`String mensagemDe(...) => switch (status) { ... };`**
Switch **expression**. Cada caso usa `=>` e termina em vírgula; o `switch` inteiro devolve o valor.
Repare no `;` no final, porque é uma expressão dentro de uma função de flecha.

**Ausência de `default`**
Intencional. É o que faz o compilador te avisar quando o enum crescer. Se você quiser experimentar:
acrescente `expirada` ao enum e rode `dart analyze` — vão aparecer erros apontando os dois `switch`.

**`switch (status) { case A: case B: return true; ... }`**
Forma clássica. Dois `case` seguidos, sem corpo no primeiro, compartilham o mesmo bloco. Como a
função devolve valor em todos os ramos e o `switch` é exaustivo, o Dart não exige `return` no fim.

**`baixa('Baixa', 15, '🪫'),`**
Constante de enum avançado com argumentos. É uma chamada ao construtor `const` declarado abaixo.

**`const NivelDeEnergia(this.rotulo, this.minutosSugeridos, this.icone);`**
O construtor **tem que** ser `const`: as constantes do enum são criadas em tempo de compilação.
Usa o açúcar `this.x` da [Aula 2](02-construtores.md).

**`Duration get duracaoSugerida => Duration(minutes: minutosSugeridos);`**
Getter comum, dentro de um enum. Isso costuma surpreender quem vem de outras linguagens — em Dart,
um enum é uma classe especial, com quase todos os poderes de uma classe.

**`static NivelDeEnergia paraMinutosDisponiveis(int minutos)`**
Membro estático: pertence ao **enum**, não a uma constante. Note que dentro dele você escreve
`alta` e `media` sem prefixo — já se está dentro do próprio tipo. É uma fábrica: em vez de espalhar
`if` pelo app, a regra de escolha mora junto do conceito.

**`enum` dentro de `Sessao`**
`this.status = StatusDaSessao.naoIniciada` como valor padrão de parâmetro: funciona porque a
constante é `const`. E `copyWith` (Aula 3) troca o status devolvendo uma sessão nova.

**`'${status.name.padRight(12)} ...'`**
`padRight(12)` completa com espaços à direita até 12 caracteres, alinhando o relatório. `name` é a
forma correta de imprimir o enum — `toString()` traria o prefixo `StatusDaSessao.`.

**`contagem[status] = (contagem[status] ?? 0) + 1;`**
O padrão "contar ocorrências" com `Map`. O `??` cobre a primeira vez, quando a chave ainda não
existe.

**O laço final sobre `StatusDaSessao.values`**
Detalhe que separa um relatório bom de um relatório enganoso: percorrer `values` (e não as chaves do
`Map`) garante que status com **zero** ocorrências apareçam com 0, em vez de sumirem do relatório.

---

## ⚠️ Erros comuns

**1. `switch` sobre enum com `default`**

```dart
switch (status) {
  case StatusDaSessao.concluida: return 'ok';
  default: return 'outro'; // ❌ mata a verificação de exaustividade
}
```
✅ Liste todos os casos. Se houver muitos com o mesmo corpo, empilhe os `case`.

**2. `switch` incompleto**

```text
Error: The type 'StatusDaSessao' is not exhaustively matched by the switch cases
since it doesn't match 'StatusDaSessao.cancelada'.
```
✅ O compilador está te mostrando um bug que ainda não aconteceu. Trate o caso.

**3. Guardar `index` em banco ou API**

```dart
await db.insert('sessoes', {'status': status.index}); // ❌
```
Reordenou o enum? Todos os registros antigos viraram outra coisa.
✅ `{'status': status.name}` e, na leitura, `StatusDaSessao.values.byName(texto)`.

**4. `byName` com texto inválido**

```dart
StatusDaSessao.values.byName('pausadaa'); // ❌ lança ArgumentError
```
✅ Para dados externos, use uma versão tolerante:
```dart
StatusDaSessao lerStatus(String texto) => StatusDaSessao.values.firstWhere(
      (s) => s.name == texto,
      orElse: () => StatusDaSessao.naoIniciada,
    );
```

**5. Esquecer o `;` depois das constantes no enum avançado**

```dart
enum Nivel {
  baixa('Baixa', 15),
  alta('Alta', 50)      // ❌ faltou o ;
  const Nivel(this.rotulo, this.minutos);
}
```
```text
Error: Expected ';' after this.
```

**6. Campo não-`final` ou construtor não-`const` em enum avançado**

```text
Error: Constructor is marked 'const' so all fields must be final.
```
✅ Enum é imutável por natureza.

**7. Declarar um membro chamado `values`**

```dart
enum Nivel { a, b; static const values = 1; } // ❌
```
```text
Error: 'values' is already declared in this scope.
```

**8. `switch` sobre `String` no lugar de enum**

```dart
switch (statusComoTexto) { case 'concluida': ... } // ❌ sem verificação
```
✅ Converta para enum na **borda** do sistema (ao ler do banco ou da API) e trabalhe com o tipo forte
lá dentro.

---

## 🛠️ Exercício guiado

Vamos criar o enum avançado `TipoDeAtividade` para o app Foco.

**Passo 1.** Crie `bin/guiado_07_atividade.dart`:

```dart
enum TipoDeAtividade {
  leitura('Leitura', 1.0, '📖'),
  videoaula('Videoaula', 0.8, '🎬'),
  exercicio('Exercício', 1.5, '✏️'),
  revisao('Revisão', 1.2, '🔁');

  const TipoDeAtividade(this.rotulo, this.peso, this.icone);

  final String rotulo;
  final double peso;
  final String icone;

  /// Pontos que este tipo rende por minuto estudado.
  int pontosPara(int minutos) => (minutos * peso).round();

  /// O tipo de maior peso, calculado a partir dos próprios valores.
  static TipoDeAtividade get maisValioso => values.reduce(
        (a, b) => a.peso >= b.peso ? a : b,
      );
}
```

`reduce` percorre a lista comparando dois a dois e devolve o vencedor
([Módulo 02](../02-dart-basico/08-listas.md)).

**Passo 2.** Um enum simples para o turno, com `switch` exaustivo:

```dart
enum Turno { manha, tarde, noite }

String dicaDoTurno(Turno turno) => switch (turno) {
      Turno.manha => 'Cérebro descansado: aproveite para exercícios.',
      Turno.tarde => 'Energia média: leitura rende bem.',
      Turno.noite => 'Fim do dia: prefira revisão curta.',
    };
```

**Passo 3.** `main` juntando tudo:

```dart
void main() {
  print('--- Tipos de atividade ---');
  for (final tipo in TipoDeAtividade.values) {
    print('${tipo.icone} ${tipo.rotulo.padRight(10)} peso ${tipo.peso} '
        '| 60 min = ${tipo.pontosPara(60)} pontos');
  }
  print('Mais valioso: ${TipoDeAtividade.maisValioso.rotulo}');

  print('');
  print('--- Dica por turno ---');
  for (final turno in Turno.values) {
    print('${turno.name.padRight(6)} ${dicaDoTurno(turno)}');
  }

  print('');
  print('--- Serialização segura ---');
  final salvo = TipoDeAtividade.exercicio.name; // guarde o NAME, nunca o index
  print('Guardado no banco: "$salvo"');
  final lido = TipoDeAtividade.values.byName(salvo);
  print('Lido de volta: ${lido.icone} ${lido.rotulo}');
}
```

**Passo 4.** Execute:

```powershell
dart run bin/guiado_07_atividade.dart
```

**Saída esperada:**

```text
--- Tipos de atividade ---
📖 Leitura    peso 1.0 | 60 min = 60 pontos
🎬 Videoaula  peso 0.8 | 60 min = 48 pontos
✏️ Exercício  peso 1.5 | 60 min = 90 pontos
🔁 Revisão    peso 1.2 | 60 min = 72 pontos
Mais valioso: Exercício

--- Dica por turno ---
manha  Cérebro descansado: aproveite para exercícios.
tarde  Energia média: leitura rende bem.
noite  Fim do dia: prefira revisão curta.

--- Serialização segura ---
Guardado no banco: "exercicio"
Lido de volta: ✏️ Exercício
```

**Passo 5.** Acrescente `podcast('Podcast', 0.6, '🎧')` ao enum. Rode de novo: **nada quebra**,
porque não existe nenhum `switch` sobre `TipoDeAtividade` — o comportamento mora dentro das
constantes. Agora acrescente `madrugada` ao `Turno` e veja o compilador exigir o novo caso no
`switch`. Duas ferramentas, dois usos.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Modele a **meta semanal** do app Foco com enums:

1. `enum DiaDaSemana` com campos `abreviacao` (`'Seg'`) e `ehFimDeSemana` (getter calculado a partir
   do `index`).
2. `enum StatusDaMeta { atrasada, noRitmo, adiantada, cumprida }` com um `switch` exaustivo que
   devolve um emoji e uma frase.
3. Uma função `StatusDaMeta avaliar({required int minutosFeitos, required int meta,
   required DiaDaSemana hoje})` que compara o progresso esperado até hoje com o real.
4. Teste com pelo menos 5 combinações e imprima uma tabela.
5. Por fim, responda em comentário: por que `StatusDaMeta` é um bom caso para `switch`, enquanto
   `DiaDaSemana` é um bom caso para **campos no próprio enum**? (Dica: pense em quem "possui" a
   informação.)

---

## 📌 Resumo

- `enum` cria um conjunto **fechado, nomeado e verificado na compilação** de valores.
- Todo enum tem `values`, `index`, `name` e `values.byName(...)`.
- **Guarde `name`, nunca `index`**, em banco, arquivo ou API.
- `switch` sobre enum **sem `default`** é exaustivo: acrescentar uma constante vira erro de
  compilação em todos os lugares que precisam de atenção.
- A **switch expression** (`=> valor,`) devolve um valor; a forma clássica com `case:` continua
  disponível.
- **Enum avançado**: constantes primeiro (terminando em `;`), construtor `const`, campos `final`,
  mais getters, métodos e membros estáticos.
- Se um `switch` existe só para traduzir a constante em um dado fixo, esse dado deveria ser um
  **campo do enum**.

---

## ☑️ Checklist de domínio

- [ ] Declaro um enum simples e listo três vantagens sobre usar `String`.
- [ ] Uso `values`, `index`, `name` e `byName` sem consultar a aula.
- [ ] Explico por que `index` não pode ir para o banco de dados.
- [ ] Escrevo um `switch` exaustivo sem `default` e digo por que o `default` é nocivo aqui.
- [ ] Escrevo um enum avançado completo, com construtor `const` e um método estático.
- [ ] Sei prever o erro de compilação ao acrescentar uma constante nova.
- [ ] Sei decidir entre "campo no enum" e "switch fora do enum".
- [ ] Rodei `bin/07_enums.dart` e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Enumerated types](https://dart.dev/language/enums)
- [Dart — Enhanced enums](https://dart.dev/language/enums#declaring-enhanced-enums)
- [Dart — Branches: switch](https://dart.dev/language/branches#switch-statements)
- [Dart — Switch expressions](https://dart.dev/language/branches#switch-expressions)
- [API — `EnumByName.byName`](https://api.dart.dev/stable/dart-core/EnumByName/byName.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Mixins](06-mixins.md) | [README](README.md) | [Aula 8 — Generics](08-generics.md) |
