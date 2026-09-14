# Aula 5 — Classes abstratas e interfaces

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Declarar uma `abstract class` e explicar por que ela não pode ser instanciada.
- Escrever **métodos abstratos** (sem corpo) e misturá-los com métodos concretos.
- Usar `implements` e entender a frase mais importante da aula:
  **em Dart, toda classe é também uma interface**.
- Diferenciar `extends` de `implements` com precisão, sabendo o que cada um obriga.
- Escrever um **contrato de repositório** — a base de toda arquitetura testável do curso.
- Reconhecer os modificadores de classe do Dart 3 (`interface`, `base`, `final`, `sealed`).

## ✅ Pré-requisitos

- [Aula 4 — Herança e polimorfismo](04-heranca-e-polimorfismo.md).
- [Aula 3 — Encapsulamento](03-encapsulamento.md) (`toString`, campos `final`).

---

## 📖 Conceito

### O problema: prometer sem entregar

Na Aula 4, `Atividade` tinha uma implementação padrão de `pontos`. Mas e quando **não existe**
padrão razoável?

Pense em um **repositório** (*repository* — o objeto responsável por guardar e recuperar dados,
escondendo de quem usa se eles vêm da memória, de um banco SQLite ou de um servidor). Você quer
escrever a tela **antes** de decidir onde os dados moram. Precisa de algo que diga apenas:

> "Existe alguém capaz de `listarTodas()`, `salvar()` e `remover()`. Quem é esse alguém, decidimos
> depois."

Isso é um **contrato**. Em Dart há duas formas de escrever contratos: `abstract class` e
`implements`.

### `abstract class`

Uma classe marcada com `abstract` **não pode ser instanciada**. Ela existe para ser estendida ou
implementada.

```dart
abstract class MateriaRepositorio {
  List<Materia> listarTodas();       // método ABSTRATO: sem corpo, sem {}
  void salvar(Materia materia);      // abstrato

  int contar() => listarTodas().length; // CONCRETO: tem corpo
}
```

Tentar `MateriaRepositorio()` dá:

```text
Error: The class 'MateriaRepositorio' is abstract and can't be instantiated.
```

Note os dois tipos de membro convivendo:

- **Método abstrato**: declara assinatura e termina com `;`. É uma **obrigação** para quem herdar.
- **Método concreto**: tem corpo. É um **presente** para quem herdar — e pode chamar os abstratos,
  mesmo sem saber como serão implementados.

Getters também podem ser abstratos:

```dart
abstract class Exportador {
  String get extensao; // getter abstrato
}
```

Esse padrão — um método concreto no topo definindo o **esqueleto** e chamando métodos abstratos que
as filhas preenchem — tem nome: **Template Method**. Você usa isso no código completo.

### `implements` — toda classe é uma interface

Aqui está a característica de Dart que surpreende quem vem de Java:

> **Em Dart não existe a palavra-chave `interface` para declarar um tipo. Toda classe declarada
> define automaticamente uma interface implícita: a lista dos seus membros públicos.**

Consequência direta: você pode `implements` **qualquer** classe, inclusive uma classe concreta que
você não escreveu.

```dart
class Relogio {
  DateTime agora() => DateTime.now();
}

// RelogioFixo NÃO herda nada de Relogio. Só promete ter os mesmos membros.
class RelogioFixo implements Relogio {
  final DateTime instante;
  RelogioFixo(this.instante);

  @override
  DateTime agora() => instante;
}
```

Isso é ouro para testes: qualquer função que peça um `Relogio` aceita um `RelogioFixo`, e o seu
teste deixa de depender da hora real do computador.

E, diferente de `extends`, `implements` aceita **vários**:

```dart
class Repositorio implements Leitor, Escritor, Fechavel { ... }
```

### `extends` × `implements` — a tabela decisiva

| | `extends` (herdar) | `implements` (assinar contrato) |
|---|---|---|
| Quantas por classe? | **Uma** superclasse | **Várias** interfaces |
| Herda a implementação dos métodos concretos? | **Sim** | **Não** — você reescreve tudo |
| Herda campos? | Sim | Não. Você declara os seus |
| Precisa reimplementar métodos concretos? | Não | **Sim, todos** |
| Pode usar `super.metodo()`? | Sim | **Não** |
| Enxerga membros privados (`_x`) do mesmo arquivo? | Sim | Não os herda |
| Usa quando... | há código de verdade para reaproveitar | só interessa a **forma** (a assinatura) |

A regra prática: **`extends` para reaproveitar código; `implements` para prometer um formato.**

Um detalhe que pega muita gente: se você fizer `implements` de uma classe abstrata que tinha o
método concreto `contar()`, você é obrigado a escrever `contar()` de novo. `implements` copia
apenas as **assinaturas**, nunca o corpo.

### Modificadores de classe do Dart 3

Desde o Dart 3, a declaração `class` pode receber modificadores que controlam como ela pode ser
usada por outros arquivos:

| Modificador | Significado |
|---|---|
| `abstract class` | Não pode ser instanciada. Pode ter métodos abstratos. |
| `interface class` | Pode ser `implements`, **não** pode ser `extends` de fora da biblioteca. |
| `abstract interface class` | O jeito moderno de escrever um **contrato puro**. |
| `base class` | Só pode ser `extends` (nunca `implements`) fora da biblioteca. Garante que o comportamento concreto acompanhe o tipo. |
| `final class` | Não pode ser estendida nem implementada fora da biblioteca. |
| `sealed class` | Conjunto **fechado** de subtipos, tudo no mesmo arquivo. Habilita `switch` exaustivo. Assunto de [`04-dart-avancado/06-sealed-classes.md`](../04-dart-avancado/06-sealed-classes.md). |

Neste curso usamos `abstract class` (simples e suficiente) e, no módulo 04, `sealed class` para
modelar resultados. Os demais você precisa **reconhecer** ao ler código de pacotes, e é por isso que
estão listados aqui.

### Por que contratos importam tanto

Com um contrato, a sua tela depende de `MateriaRepositorio` (uma ideia), não de
`MateriaRepositorioSqflite` (um detalhe). Isso permite:

1. **Testar sem banco de dados** — injete uma implementação falsa em memória. Testes voam.
2. **Trocar a fonte de dados** sem tocar na tela — memória hoje, SQLite amanhã, API depois.
3. **Trabalhar em paralelo** — uma pessoa escreve a tela, outra o banco, contra o mesmo contrato.
4. **Ler código mais rápido** — o contrato é um resumo de uma página do que o sistema faz.

Esse é o alicerce da arquitetura em 3 camadas que você adota a partir do módulo 08.

---

## 💡 Analogia

Uma **tomada elétrica**.

- A tomada é o **contrato**: três furos, 127 V. Ela não gera energia nenhuma sozinha — é abstrata.
- A **usina hidrelétrica** e o **gerador a diesel** são implementações diferentes do mesmo contrato.
- O seu carregador de celular é o código cliente: ele funciona com qualquer uma das duas, porque
  depende do **formato da tomada**, não da usina.
- E o padrão da tomada também diz **o que não fazer**: se o seu gerador tiver dois furos, ele não
  cumpre o contrato e o compilador — perdão, o eletricista — reprova.

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_abstratas.dart`
> **Como executar:** `dart run bin/exemplo_abstratas.dart`

```dart
abstract class FonteDeFrases {
  String proxima();                      // abstrato: cada fonte resolve do seu jeito

  String comAspas() => '"${proxima()}"'; // concreto: usa o abstrato
}

class FrasesFixas extends FonteDeFrases {
  @override
  String proxima() => 'Estudar 25 minutos hoje vale mais que 5 horas domingo.';
}

class FrasesEmMaiusculas implements FonteDeFrases {
  @override
  String proxima() => 'foco no que você controla';

  // `implements` NÃO herda o corpo: precisamos escrever comAspas() de novo.
  @override
  String comAspas() => '«${proxima().toUpperCase()}»';
}

void main() {
  final fontes = <FonteDeFrases>[FrasesFixas(), FrasesEmMaiusculas()];
  for (final fonte in fontes) {
    print(fonte.comAspas());
  }
}
```

Saída:

```text
"Estudar 25 minutos hoje vale mais que 5 horas domingo."
«FOCO NO QUE VOCÊ CONTROLA»
```

---

## 📱 Aplicando no Flutter

Esta aula é a mais "arquitetural" do módulo, e o retorno vem em três momentos do curso.

**1. A camada de dados do app Foco.** No projeto final, a pasta
`lib/features/materias/domain/` tem um arquivo chamado `materia_repositorio_contrato.dart`.
Ele contém **exatamente** o que você escreve hoje:

```dart
abstract class MateriaRepositorioContrato {
  Future<List<Materia>> listarTodas();
  Future<void> salvar(Materia materia);
  Future<void> remover(int id);
}
```

(O `Future` aparece porque o banco é assíncrono — assunto do
[Módulo 04](../04-dart-avancado/02-futures-e-async-await.md). A ideia do contrato é idêntica.)

A implementação real, `MateriaRepositorio` com `sqflite`, mora em `data/` e é escrita no
[Módulo 10](../10-persistencia-de-dados/05-sqflite-crud.md).

**2. Testes.** No [Módulo 12](../12-testes-e-debug/07-mocks-e-fakes.md) você vai escrever uma
implementação falsa do contrato — em memória, instantânea — e testar toda a lógica da tela sem
abrir banco nenhum. Isso só é possível porque a tela depende da **abstração**.

**3. Injeção de dependência com Riverpod.** No
[Módulo 08](../08-estado-e-arquitetura/10-injecao-de-dependencias.md), um provider entrega a
implementação concreta, e no teste você **sobrescreve** esse provider por um falso. O código da
tela não muda uma linha.

> 🎯 Se você entender só uma coisa desta aula, que seja esta: **dependa de contratos, não de
> implementações.** É a diferença entre um app que você consegue testar e um que você só consegue
> torcer para funcionar.

---

## 💻 Código completo

> **Arquivo:** `bin/05_abstratas_e_interfaces.dart`
> **Como executar:** `dart run bin/05_abstratas_e_interfaces.dart`

```dart
// Aula 5 do Módulo 03 — Classes abstratas, interfaces e contrato de repositório.

/// Modelo imutável (Aula 3).
class Materia {
  final String id;
  final String nome;
  final int minutos;

  const Materia({required this.id, required this.nome, required this.minutos});

  @override
  String toString() => 'Materia($id, $nome, $minutos min)';
}

// ===========================================================================
// PARTE 1 — O CONTRATO
// ===========================================================================

/// Contrato de armazenamento de matérias.
/// Quem usa esta classe NÃO precisa saber se os dados estão em memória,
/// num banco de dados ou num servidor.
abstract class MateriaRepositorio {
  // --- Métodos ABSTRATOS: sem corpo, terminam em ponto e vírgula. ---
  List<Materia> listarTodas();
  Materia? buscarPorId(String id);
  void salvar(Materia materia);
  void remover(String id);

  // --- Métodos CONCRETOS: já vêm prontos para quem usar `extends`. ---
  int contar() => listarTodas().length;

  int totalDeMinutos() {
    var total = 0;
    for (final materia in listarTodas()) {
      total += materia.minutos;
    }
    return total;
  }
}

// ===========================================================================
// PARTE 2 — DUAS IMPLEMENTAÇÕES DO MESMO CONTRATO
// ===========================================================================

/// Implementação real (para este módulo: em memória).
/// Usa `extends`: HERDA `contar()` e `totalDeMinutos()` de graça.
class MateriaRepositorioEmMemoria extends MateriaRepositorio {
  // Map mantém a ordem de inserção e garante id único.
  final Map<String, Materia> _itens = <String, Materia>{};

  @override
  List<Materia> listarTodas() => _itens.values.toList();

  @override
  Materia? buscarPorId(String id) => _itens[id];

  @override
  void salvar(Materia materia) => _itens[materia.id] = materia;

  @override
  void remover(String id) => _itens.remove(id);
}

/// Dublê para teste. Usa `implements`: NÃO herda nada.
/// Por isso é obrigada a reescrever até `contar()` e `totalDeMinutos()`.
class MateriaRepositorioFalso implements MateriaRepositorio {
  static const _fixas = <Materia>[
    Materia(id: 'fake-1', nome: 'Matéria de teste', minutos: 10),
  ];

  @override
  List<Materia> listarTodas() => _fixas;

  @override
  Materia? buscarPorId(String id) => id == 'fake-1' ? _fixas.first : null;

  @override
  void salvar(Materia materia) {
    // Dublê não guarda nada: o teste só quer garantir que foi chamado.
  }

  @override
  void remover(String id) {}

  @override
  int contar() => _fixas.length;

  @override
  int totalDeMinutos() => 10;
}

// ===========================================================================
// PARTE 3 — TEMPLATE METHOD: esqueleto concreto + peças abstratas
// ===========================================================================

abstract class Exportador {
  String get extensao;            // getter abstrato
  String cabecalho();             // método abstrato
  String linha(Materia materia);  // método abstrato

  /// Esqueleto CONCRETO. Ele já sabe a ordem das operações,
  /// mesmo sem saber como cada peça será escrita.
  String exportar(List<Materia> materias) {
    // StringBuffer acumula texto sem criar uma String nova a cada concatenação.
    final buffer = StringBuffer(cabecalho());
    for (final materia in materias) {
      buffer.writeln();
      buffer.write(linha(materia));
    }
    return buffer.toString();
  }
}

class ExportadorCsv extends Exportador {
  @override
  String get extensao => 'csv';

  @override
  String cabecalho() => 'id;nome;minutos';

  @override
  String linha(Materia materia) =>
      '${materia.id};${materia.nome};${materia.minutos}';
}

class ExportadorMarkdown extends Exportador {
  @override
  String get extensao => 'md';

  @override
  String cabecalho() => '| Matéria | Minutos |\n|---|---|';

  @override
  String linha(Materia materia) => '| ${materia.nome} | ${materia.minutos} |';
}

// ===========================================================================
// PARTE 4 — TODA CLASSE É UMA INTERFACE
// ===========================================================================

/// Classe CONCRETA, comum. Nada de abstrato aqui.
class Relogio {
  DateTime agora() => DateTime.now();
}

/// Mesmo assim, podemos `implements` nela: toda classe define uma interface.
/// Resultado: um relógio determinístico para testes.
class RelogioFixo implements Relogio {
  final DateTime instante;

  RelogioFixo(this.instante);

  @override
  DateTime agora() => instante;
}

/// Função cliente: depende do TIPO Relogio, não de quem o implementa.
String saudacaoDeEstudo(Relogio relogio) {
  final hora = relogio.agora().hour;
  if (hora < 12) {
    return 'Bom dia! Que tal 25 minutos de Dart?';
  }
  if (hora < 18) {
    return 'Boa tarde! Hora da sessão principal.';
  }
  return 'Boa noite! Uma revisão curta fecha o dia.';
}

// ===========================================================================
// PROGRAMA
// ===========================================================================

/// Note o parâmetro: `MateriaRepositorio`, o CONTRATO.
/// Esta função funciona com qualquer implementação, hoje e no futuro.
String relatorio(String rotulo, MateriaRepositorio repositorio) =>
    '$rotulo: ${repositorio.contar()} matéria(s), '
    '${repositorio.totalDeMinutos()} minutos';

void main() {
  print('--- 1. Implementação em memória (extends) ---');
  final emMemoria = MateriaRepositorioEmMemoria();
  emMemoria.salvar(const Materia(id: 'm1', nome: 'Dart', minutos: 120));
  emMemoria.salvar(const Materia(id: 'm2', nome: 'Flutter', minutos: 180));
  emMemoria.salvar(const Materia(id: 'm1', nome: 'Dart', minutos: 150));

  for (final materia in emMemoria.listarTodas()) {
    print(' - $materia');
  }
  print('Busca m2: ${emMemoria.buscarPorId('m2')}');
  print('Busca m9: ${emMemoria.buscarPorId('m9')}');

  emMemoria.remover('m1');
  print('Depois de remover m1: ${emMemoria.contar()} item(ns)');

  print('');
  print('--- 2. O mesmo código serve às duas implementações ---');
  final falso = MateriaRepositorioFalso();
  print(relatorio('Em memória', emMemoria));
  print(relatorio('Falso     ', falso));

  print('');
  print('--- 3. Template Method ---');
  const amostra = <Materia>[
    Materia(id: 'm1', nome: 'Dart', minutos: 150),
    Materia(id: 'm2', nome: 'Flutter', minutos: 180),
  ];
  for (final exportador in <Exportador>[ExportadorCsv(), ExportadorMarkdown()]) {
    print('Formato .${exportador.extensao}:');
    print(exportador.exportar(amostra));
    print('');
  }

  print('--- 4. Interface implícita: relógio determinístico ---');
  final manha = RelogioFixo(DateTime(2026, 9, 14, 8, 30));
  final tarde = RelogioFixo(DateTime(2026, 9, 14, 15, 0));
  final noite = RelogioFixo(DateTime(2026, 9, 14, 21, 45));
  print(saudacaoDeEstudo(manha));
  print(saudacaoDeEstudo(tarde));
  print(saudacaoDeEstudo(noite));
}
```

**Saída esperada:**

```text
--- 1. Implementação em memória (extends) ---
 - Materia(m1, Dart, 150 min)
 - Materia(m2, Flutter, 180 min)
Busca m2: Materia(m2, Flutter, 180 min)
Busca m9: null
Depois de remover m1: 1 item(ns)

--- 2. O mesmo código serve às duas implementações ---
Em memória: 1 matéria(s), 180 minutos
Falso     : 1 matéria(s), 10 minutos

--- 3. Template Method ---
Formato .csv:
id;nome;minutos
m1;Dart;150
m2;Flutter;180

Formato .md:
| Matéria | Minutos |
|---|---|
| Dart | 150 |
| Flutter | 180 |

--- 4. Interface implícita: relógio determinístico ---
Bom dia! Que tal 25 minutos de Dart?
Boa tarde! Hora da sessão principal.
Boa noite! Uma revisão curta fecha o dia.
```

---

## 🔍 Explicando o código

**`abstract class MateriaRepositorio`**
Não pode ser instanciada. Existe só para ser a "forma" que as implementações preenchem.

**`List<Materia> listarTodas();`**
Método abstrato: assinatura + `;`. Quem herdar **tem que** implementá-lo, ou vira abstrata também.

**`int contar() => listarTodas().length;`**
Método concreto chamando um abstrato. Na hora de escrever essa linha, ninguém sabe de onde a lista
virá — e não precisa saber. Esse é o coração do Template Method.

**`class MateriaRepositorioEmMemoria extends MateriaRepositorio`**
Com `extends`, `contar()` e `totalDeMinutos()` vêm prontos. Só os 4 abstratos precisam de código.

**`final Map<String, Materia> _itens = <String, Materia>{};`**
Campo privado (Aula 3). Quem usa o repositório não sabe que por dentro existe um `Map` — e é por
isso que trocar por SQLite depois não quebra ninguém.

**`_itens[materia.id] = materia;`**
Salvar duas vezes o mesmo `id` **substitui**. Por isso `m1` com 120 minutos virou `m1` com 150 e a
contagem final ficou em 2, não 3.

**`class MateriaRepositorioFalso implements MateriaRepositorio`**
Com `implements`, **nada** é herdado. Se você apagar o `contar()` desta classe, o compilador acusa:

```text
Error: Missing concrete implementation of 'MateriaRepositorio.contar'.
```

Compare mentalmente com a classe anterior: essa é a diferença prática entre `extends` e `implements`.

**`static const _fixas = <Materia>[...]`**
Constante da classe (Aula 2), privada (Aula 3), imutável, criada em tempo de compilação.

**`String relatorio(String rotulo, MateriaRepositorio repositorio)`**
Repare no tipo do parâmetro. Esta função nunca vai precisar mudar, nem quando surgir a implementação
com SQLite. Isso é **programar contra o contrato**.

**`final buffer = StringBuffer(cabecalho());`**
`StringBuffer` acumula texto de forma eficiente. Concatenar com `+` dentro de um laço cria uma
`String` nova a cada volta, o que é desperdício quando são muitos itens.

**`buffer.writeln();` e `buffer.write(...)`**
`writeln()` sem argumento escreve apenas a quebra de linha. Fazer quebra-antes (em vez de
quebra-depois) evita uma linha vazia sobrando no fim do arquivo.

**`class RelogioFixo implements Relogio`**
`Relogio` é uma classe comum, concreta, sem `abstract`. Mesmo assim serve de interface. Repare que
`RelogioFixo` **não** tem `DateTime.now()` em lugar nenhum: ela promete a mesma forma, com outro
conteúdo.

**`final manha = RelogioFixo(DateTime(2026, 9, 14, 8, 30));`**
Repare que aqui **não** dá para usar `const`: o construtor de `DateTime` não é `const`, então
`DateTime(2026, 9, 14, 8, 30)` só existe em tempo de execução. Usar uma data **fixa** (em vez de
`DateTime.now()`) é o que torna a saída deste programa reproduzível — e é exatamente a técnica que
deixa um teste confiável.

**`saudacaoDeEstudo(manha)`**
A função recebe `Relogio` e nem imagina que recebeu um `RelogioFixo`. É o polimorfismo da Aula 4,
agora sem nenhuma herança envolvida.

---

## ⚠️ Erros comuns

**1. Instanciar classe abstrata**

```dart
final repo = MateriaRepositorio(); // ❌
```
```text
Error: The class 'MateriaRepositorio' is abstract and can't be instantiated.
```
✅ Instancie uma implementação concreta.

**2. Esquecer de implementar um membro do contrato**

```text
Error: Missing concrete implementations of 'MateriaRepositorio.remover' and
'MateriaRepositorio.salvar'.
```
✅ Implemente todos, ou marque a sua classe como `abstract` também.

**3. Achar que `implements` traz o código junto**

```dart
class Falso implements MateriaRepositorio {
  // só os 4 abstratos... ❌ faltam contar() e totalDeMinutos()
}
```
✅ Com `implements` você reescreve **tudo**. Se quer reaproveitar, use `extends`.

**4. Usar `super` com `implements`**

```dart
class Falso implements MateriaRepositorio {
  @override
  int contar() => super.contar(); // ❌
}
```
```text
Error: Superclass has no method named 'contar'.
```
✅ Não há superclasse. Escreva a implementação.

**5. Método abstrato com corpo vazio**

```dart
List<Materia> listarTodas() {} // ❌ tem corpo, e não retorna nada
```
```text
Error: A non-null value must be returned since the return type 'List<Materia>'
doesn't allow null.
```
✅ Método abstrato termina em `;`, sem `{}`.

**6. Contrato grande demais**

Um contrato com 20 métodos obriga **toda** implementação (inclusive o dublê de teste) a escrever 20
métodos. ✅ Contratos pequenos e focados. Se necessário, dois contratos separados
(`Leitor` e `Escritor`) que uma classe implementa juntos.

**7. Declarar o tipo da variável como a implementação**

```dart
final MateriaRepositorioEmMemoria repo = MateriaRepositorioEmMemoria(); // ❌
```
Amarra o resto do código ao detalhe. ✅ `final MateriaRepositorio repo = MateriaRepositorioEmMemoria();`

**8. Esquecer `@override` nos membros do contrato**

Compila, mas perde a proteção contra erro de digitação e o lint `annotate_overrides` reclama.

---

## 🛠️ Exercício guiado

Vamos criar o contrato de **notificador** do app Foco e duas implementações.

**Passo 1.** Crie `bin/guiado_05_notificador.dart` com o contrato:

```dart
abstract class Notificador {
  /// Assinatura obrigatória para qualquer notificador.
  void enviar(String titulo, String corpo);

  /// Concreto: já pronto para quem usa `extends`.
  void enviarLembreteDeSessao(String materia) {
    enviar('Hora de estudar', 'Sua sessão de $materia começa agora.');
  }
}
```

**Passo 2.** Implementação de console, com `extends`:

```dart
class NotificadorConsole extends Notificador {
  @override
  void enviar(String titulo, String corpo) {
    print('🔔 $titulo — $corpo');
  }
}
```

**Passo 3.** Implementação "silenciosa" para testes, com `implements` (repare que ela é obrigada a
reescrever `enviarLembreteDeSessao`):

```dart
class NotificadorFalso implements Notificador {
  final List<String> enviados = <String>[];

  @override
  void enviar(String titulo, String corpo) {
    enviados.add('$titulo|$corpo');
  }

  @override
  void enviarLembreteDeSessao(String materia) {
    enviar('[teste] Hora de estudar', materia);
  }
}
```

**Passo 4.** Uma função que depende só do contrato:

```dart
void iniciarRotina(Notificador notificador, List<String> materias) {
  for (final materia in materias) {
    notificador.enviarLembreteDeSessao(materia);
  }
}
```

**Passo 5.** No `main`, use as duas:

```dart
void main() {
  const materias = <String>['Dart', 'Flutter'];

  print('--- Console ---');
  iniciarRotina(NotificadorConsole(), materias);

  print('--- Falso (teste) ---');
  final falso = NotificadorFalso();
  iniciarRotina(falso, materias);
  print('Mensagens capturadas: ${falso.enviados.length}');
  for (final mensagem in falso.enviados) {
    print(' > $mensagem');
  }
}
```

**Passo 6.** Execute:

```powershell
dart run bin/guiado_05_notificador.dart
```

**Saída esperada:**

```text
--- Console ---
🔔 Hora de estudar — Sua sessão de Dart começa agora.
🔔 Hora de estudar — Sua sessão de Flutter começa agora.
--- Falso (teste) ---
Mensagens capturadas: 2
 > [teste] Hora de estudar|Dart
 > [teste] Hora de estudar|Flutter
```

**Passo 7 — entenda o que aconteceu.** A função `iniciarRotina` não mudou uma vírgula entre os dois
casos, e mesmo assim um enviou para o console e o outro guardou numa lista para você verificar.
Essa é, em miniatura, a estrutura de **todo teste** que você vai escrever no módulo 12.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Divida o contrato `MateriaRepositorio` em **dois contratos menores**:

```dart
abstract class LeitorDeMaterias {
  List<Materia> listarTodas();
  Materia? buscarPorId(String id);
}

abstract class EscritorDeMaterias {
  void salvar(Materia materia);
  void remover(String id);
}
```

Depois:

1. Faça `MateriaRepositorioEmMemoria implements LeitorDeMaterias, EscritorDeMaterias`.
2. Escreva uma função `int minutosTotais(LeitorDeMaterias leitor)` — repare que ela agora **não
   consegue** salvar nem remover nada, nem por acidente. O tipo virou uma garantia.
3. Crie um `RepositorioSomenteLeitura implements LeitorDeMaterias` para uma tela de relatório.
4. Anote em comentário: em que situação **juntar** os dois contratos de volta seria a melhor decisão?
   (Dica: contratos separados custam mais código. Vale quando existe ao menos um cliente que só
   precisa de metade.)

---

## 📌 Resumo

- `abstract class` não pode ser instanciada; serve de contrato e pode misturar métodos abstratos
  (sem corpo) e concretos (com corpo).
- **Em Dart, toda classe é também uma interface implícita** — você pode `implements` qualquer classe.
- `extends`: uma só, herda implementação, permite `super`.
- `implements`: várias, herda **apenas assinaturas**, obriga a reescrever tudo, sem `super`.
- **Template Method**: método concreto define o esqueleto e chama métodos abstratos.
- Dart 3 tem modificadores (`interface`, `base`, `final`, `sealed`) que restringem como sua classe
  pode ser usada de fora da biblioteca.
- Declare variáveis e parâmetros com o tipo do **contrato**, nunca o da implementação.
- Contratos pequenos e focados são mais fáceis de implementar e de testar.

---

## ☑️ Checklist de domínio

- [ ] Escrevo uma `abstract class` com método abstrato e método concreto.
- [ ] Explico por que uma classe abstrata não pode ser instanciada.
- [ ] Recito três diferenças entre `extends` e `implements`.
- [ ] Explico a frase "toda classe é uma interface em Dart" com um exemplo.
- [ ] Sei prever o erro que aparece quando falta implementar um membro.
- [ ] Escrevo um contrato de repositório com 4 operações sem consultar a aula.
- [ ] Sei dizer por que declarar a variável com o tipo do contrato importa.
- [ ] Reconheço `interface class`, `base class`, `final class` e `sealed class` ao ler código.
- [ ] Rodei `bin/05_abstratas_e_interfaces.dart` e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Implicit interfaces](https://dart.dev/language/classes#implicit-interfaces)
- [Dart — Abstract classes](https://dart.dev/language/class-modifiers#abstract)
- [Dart — Class modifiers](https://dart.dev/language/class-modifiers)
- [Dart — Class modifiers for API maintainers](https://dart.dev/language/class-modifiers-for-apis)
- [API — `StringBuffer`](https://api.dart.dev/stable/dart-core/StringBuffer-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Herança e polimorfismo](04-heranca-e-polimorfismo.md) | [README](README.md) | [Aula 6 — Mixins](06-mixins.md) |
