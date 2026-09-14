# Aula 6 — Mixins

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Declarar um `mixin` e aplicá-lo a uma classe com `with`.
- Usar a cláusula `on` para exigir um tipo-base e ganhar acesso aos membros dele.
- Explicar a **ordem de aplicação** (linearização) e prever o resultado de `super` dentro do mixin.
- Decidir entre **mixin**, **herança** e **composição** diante de um problema concreto.
- Escrever dois mixins úteis de verdade: um de **log** e um de **validação**.
- Reconhecer `mixin class` e saber por que ele existe no Dart 3.

## ✅ Pré-requisitos

- [Aula 4 — Herança e polimorfismo](04-heranca-e-polimorfismo.md).
- [Aula 5 — Classes abstratas e interfaces](05-abstratas-e-interfaces.md).

---

## 📖 Conceito

### O problema: comportamento que atravessa a hierarquia

Você tem `Materia`, `Sessao` e `SincronizadorRemoto`. As três precisam **registrar um log** do que
fazem. Elas não têm nada em comum além disso.

As saídas que você conhece até aqui não resolvem bem:

| Tentativa | Por que falha |
|---|---|
| Criar `class Logavel` e herdar | Dart tem herança simples. `Materia` já herda de `Entidade`. Acabou. |
| Copiar o método de log nas três | Três cópias para manter em sincronia. |
| Criar um contrato `abstract class Logavel` | O contrato só dá a **assinatura**; você escreveria o corpo três vezes. |
| Composição (um campo `Registrador`) | Funciona bem, mas você precisa escrever os métodos de delegação em cada classe. |

O **mixin** resolve exatamente isso: um bloco de **código pronto** (com corpo, e até com campos)
que você "mistura" dentro de quantas classes quiser, sem mexer na hierarquia delas.

### Declarando e aplicando

```dart
mixin Logavel {
  final List<String> _eventos = <String>[];

  void registrar(String evento) => _eventos.add(evento);

  List<String> get historico => List.unmodifiable(_eventos);
}

class Materia extends Entidade with Logavel { }
class SincronizadorRemoto with Logavel { }   // sem extends: herda de Object
```

Duas regras estruturais:

1. Um `mixin` **não pode ter construtor**. Ele não é instanciável por si só — é um pedaço de classe.
2. Você pode aplicar **vários** de uma vez: `class X extends Y with A, B, C {}`.

E um detalhe do sistema de tipos que costuma surpreender: aplicar um mixin **cria um tipo**.
Depois de `class Materia extends Entidade with Logavel`, a expressão `materia is Logavel` é `true`,
e você pode declarar `void auditar(Logavel alvo)`.

### A cláusula `on`

Por padrão, um mixin pode ser aplicado a qualquer classe — e, por isso, não pode contar com nada.
A cláusula `on` restringe:

```dart
mixin Validavel on Entidade {
  List<String> validar() {
    final erros = <String>[];
    if (id.isEmpty) { // `id` vem de Entidade: só posso usar por causa do `on`
      erros.add('O id não pode ser vazio.');
    }
    return erros;
  }
}
```

`on Entidade` significa: **"só posso ser aplicado a classes que sejam `Entidade`"**. Em troca, posso
usar todos os membros de `Entidade` lá dentro. É um contrato ao contrário — em vez de prometer, o
mixin **exige**.

Se você aplicar onde não vale:

```text
Error: 'Sessao' can't use the mixin 'Validavel' because 'Validavel' can only be
mixed in on subclasses of 'Entidade'.
```

Um mixin também pode exigir membros declarando-os **abstratos**, sem `on`:

```dart
mixin Logavel {
  String get identificacao;  // quem me usar TEM que fornecer isto
  void registrar(String e) => _eventos.add('[$identificacao] $e');
}
```

### Ordem de aplicação e linearização

Quando você escreve `class C extends Base with A, B`, o Dart monta uma **cadeia linear** de tipos:

```text
Object → Base → Base+A → Base+A+B → C
```

Ou seja: os mixins entram **entre** a superclasse e a classe, **na ordem em que aparecem**, da
esquerda para a direita. Disso saem três consequências práticas:

1. **O último ganha.** Se `A` e `B` definem o mesmo método, vale o de `B` (o mais à direita).
2. **A classe ganha de todos.** Um método definido em `C` sobrescreve o de qualquer mixin.
3. **`super` dentro de um mixin aponta para o elemento anterior da cadeia**, não necessariamente
   para `Base`. Em `B`, `super.metodo()` chama a versão de `A`.

Essa é a diferença entre `A, B` e `B, A` — e é a fonte de confusão número um sobre mixins. O código
completo tem uma demonstração que imprime a cadeia.

### Mixin × herança × composição

| Pergunta | Ferramenta |
|---|---|
| "Isto **é um** daquilo?" | Herança (`extends`) |
| "Isto **tem um** daquilo?" | Composição (um campo) |
| "Isto **sabe fazer** aquilo, e outras coisas sem parentesco também sabem?" | **Mixin** (`with`) |

Mixin é melhor que herança quando:

- O comportamento é **transversal**: aparece em classes de hierarquias diferentes.
- Você quer **mais de um** bloco de comportamento na mesma classe (herança só dá um).
- A relação **não é** "é-um": `Materia` não **é** um `Logavel`; ela **sabe registrar log**.

Mixin **não** é melhor quando:

- O comportamento tem estado complexo e vida própria → prefira **composição**, que você pode trocar
  em teste e inspecionar separadamente.
- Você precisaria de três ou quatro mixins empilhados só para montar uma classe. Muitos mixins
  reproduzem o mesmo problema da hierarquia profunda: ninguém mais sabe de onde vem cada método.

Regra honesta: **mixin para comportamento pequeno, sem dependências, repetido em lugares sem
parentesco.** Para o resto, composição.

### `mixin class` (Dart 3)

Antes do Dart 3, qualquer classe sem construtor podia ser usada como mixin. Isso acabou: hoje, se
você quer um tipo que sirva **tanto** como classe **quanto** como mixin, precisa declarar:

```dart
mixin class Auditavel {
  void auditar() {}
}
```

Você raramente vai escrever isso, mas vai **encontrar** em código de pacotes. E um `mixin` puro
(sem `class`) não pode ser instanciado nem estendido — só misturado.

---

## 💡 Analogia

**Cursos livres e habilidades.**

- A **formação** de alguém é a herança: "é engenheiro", "é médico". Só uma, e define a identidade.
- Um **curso de primeiros socorros** é um mixin: o engenheiro faz, o médico faz, o professor faz.
  Nenhum deles vira "um socorrista" — todos **passam a saber socorrer**, com o mesmo treinamento.
- E quando duas pessoas fazem o curso de primeiros socorros **e** o de brigada de incêndio, a ordem
  importa: o treinamento mais recente é o que fica na ponta da língua na hora do improviso.
  Isso é a linearização.

Onde a analogia **para**: cursos são independentes entre si; um mixin com `on` **exige** uma
formação prévia ("só faz o curso quem já é da área da saúde").

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_mixin.dart`
> **Como executar:** `dart run bin/exemplo_mixin.dart`

```dart
mixin Contavel {
  int _chamadas = 0;

  void contar() => _chamadas++;

  int get totalDeChamadas => _chamadas;
}

class Cronometro with Contavel {
  int segundos = 0;

  void avancar(int valor) {
    segundos += valor;
    contar(); // método que veio do mixin
  }
}

class Formulario with Contavel {
  void enviar() => contar();
}

void main() {
  final cronometro = Cronometro()
    ..avancar(60)
    ..avancar(30);
  final formulario = Formulario()..enviar();

  print('Cronômetro: ${cronometro.segundos}s em '
      '${cronometro.totalDeChamadas} chamadas');
  print('Formulário: ${formulario.totalDeChamadas} envio(s)');
  print('Ambos são Contavel? '
      '${cronometro is Contavel && formulario is Contavel}');
}
```

Saída:

```text
Cronômetro: 90s em 2 chamadas
Formulário: 1 envio(s)
Ambos são Contavel? true
```

> O `..` é o **operador cascata**: chama vários membros no mesmo objeto sem repetir o nome da
> variável. `Cronometro()..avancar(60)..avancar(30)` devolve o **objeto**, não o resultado do
> último método.

---

## 📱 Aplicando no Flutter

Mixins não são um detalhe acadêmico no Flutter — você vai **ser obrigado** a usá-los.

**1. Animações.** Todo controlador de animação precisa de um "ticker" (um objeto que avisa a cada
quadro da tela). O framework exige que o seu `State` forneça isso, e a forma de fornecer é um mixin:

```dart
class _TelaState extends State<Tela> with SingleTickerProviderStateMixin {
  late final AnimationController _controlador =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
}
```

Repare: `vsync: this` só compila porque o mixin fez a sua classe passar a **ser** um
`TickerProvider`. É o mesmo mecanismo de `materia is Logavel` desta aula.

**2. Ciclo de vida do app.** Para saber quando o app foi para segundo plano (o usuário apertou o
botão home), você mistura `WidgetsBindingObserver`:

```dart
class _TelaState extends State<Tela> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // pausar o cronômetro da sessão de estudo, por exemplo
  }
}
```

Isso aparece no [Módulo 11](../11-recursos-nativos/06-ciclo-de-vida-do-app.md) — e é um requisito
real do app **Foco**: a sessão de estudo precisa pausar quando o app sai da frente.

**3. Abas que não perdem o estado.** `AutomaticKeepAliveClientMixin` mantém uma aba viva ao trocar
de aba, tema do [Módulo 07](../07-navegacao-e-formularios/04-abas-e-organizacao.md).

Em todos esses casos, a pergunta "por que não herança?" tem a mesma resposta: o seu `State` **já**
herda de `State<T>`. Só sobra mixin.

---

## 💻 Código completo

> **Arquivo:** `bin/06_mixins.dart`
> **Como executar:** `dart run bin/06_mixins.dart`

```dart
// Aula 6 do Módulo 03 — Mixins: with, on, linearização.

// ===========================================================================
// PARTE 1 — BASE DA HIERARQUIA
// ===========================================================================

abstract class Entidade {
  final String id;

  Entidade(this.id);

  String descrever();
}

// ===========================================================================
// PARTE 2 — MIXIN DE LOG (sem `on`: serve para QUALQUER classe)
// ===========================================================================

/// Mixin com ESTADO (um campo) e comportamento pronto.
/// Exige que quem o use forneça `identificacao` — um membro abstrato.
mixin Logavel {
  final List<String> _eventos = <String>[];

  /// Contrato: quem mistura este mixin precisa fornecer isto.
  String get identificacao;

  void registrar(String evento) {
    _eventos.add('[$identificacao] $evento');
  }

  /// `List.unmodifiable` devolve uma cópia que ninguém consegue alterar:
  /// o histórico não pode ser adulterado de fora.
  List<String> get historico => List<String>.unmodifiable(_eventos);

  int get totalDeEventos => _eventos.length;
}

// ===========================================================================
// PARTE 3 — MIXIN DE VALIDAÇÃO (com `on`: exige ser uma Entidade)
// ===========================================================================

mixin Validavel on Entidade {
  /// Cada classe declara as suas regras: mensagem -> condição que precisa ser true.
  Map<String, bool> get regras;

  List<String> validar() {
    final erros = <String>[];
    regras.forEach((mensagem, atendida) {
      if (!atendida) {
        erros.add(mensagem);
      }
    });
    // `id` só está acessível aqui por causa do `on Entidade`.
    if (id.trim().isEmpty) {
      erros.add('O id não pode ser vazio.');
    }
    return erros;
  }

  bool get valido => validar().isEmpty;
}

// ===========================================================================
// PARTE 4 — CLASSES QUE USAM OS MIXINS
// ===========================================================================

class Materia extends Entidade with Logavel, Validavel {
  String nome;
  int minutos;

  Materia({required String id, required this.nome, this.minutos = 0})
      : super(id);

  @override
  String get identificacao => 'Materia:$id';

  @override
  Map<String, bool> get regras => <String, bool>{
        'O nome precisa ter ao menos 2 letras.': nome.trim().length >= 2,
        'Os minutos não podem ser negativos.': minutos >= 0,
        'Mais de 10080 min (1 semana) é erro de digitação.': minutos <= 10080,
      };

  @override
  String descrever() => '$nome ($minutos min)';

  void estudar(int valor) {
    minutos += valor;
    registrar('estudou $valor min, total $minutos');
  }
}

/// Classe SEM parentesco com Entidade, usando o MESMO mixin de log.
/// É isto que a herança não conseguiria fazer.
class SincronizadorRemoto with Logavel {
  int _enviados = 0;

  @override
  String get identificacao => 'Sync';

  void sincronizar(int itens) {
    _enviados += itens;
    registrar('enviou $itens item(ns), acumulado $_enviados');
  }
}

// ===========================================================================
// PARTE 5 — LINEARIZAÇÃO: a ordem de `with` muda o resultado
// ===========================================================================

class Base {
  String quem() => 'Base';
}

mixin PassoA on Base {
  @override
  String quem() => '${super.quem()} → A';
}

mixin PassoB on Base {
  @override
  String quem() => '${super.quem()} → B';
}

/// Cadeia: Object → Base → Base+PassoA → Base+PassoA+PassoB → OrdemAB
class OrdemAB extends Base with PassoA, PassoB {}

/// Cadeia: Object → Base → Base+PassoB → Base+PassoB+PassoA → OrdemBA
class OrdemBA extends Base with PassoB, PassoA {}

/// A própria classe vence qualquer mixin.
class OrdemComOverride extends Base with PassoA, PassoB {
  @override
  String quem() => '${super.quem()} → e a classe fecha';
}

// ===========================================================================
// PROGRAMA
// ===========================================================================

void main() {
  print('--- 1. O mesmo mixin de log em classes sem parentesco ---');
  final dart = Materia(id: 'm1', nome: 'Dart');
  dart.estudar(45);
  dart.estudar(30);

  final sincronizador = SincronizadorRemoto();
  sincronizador.sincronizar(2);
  sincronizador.sincronizar(3);

  for (final linha in dart.historico) {
    print(linha);
  }
  for (final linha in sincronizador.historico) {
    print(linha);
  }
  print('Eventos: matéria=${dart.totalDeEventos}, '
      'sync=${sincronizador.totalDeEventos}');

  print('');
  print('--- 2. Mixin de validação com `on Entidade` ---');
  print('${dart.descrever()} é válida? ${dart.valido}');

  final quebrada = Materia(id: '  ', nome: 'D', minutos: -5);
  print('Erros de "${quebrada.descrever()}":');
  for (final erro in quebrada.validar()) {
    print(' - $erro');
  }

  print('');
  print('--- 3. Mixins criam tipos ---');
  final objetos = <Object>[dart, sincronizador];
  for (final objeto in objetos) {
    print('${objeto.runtimeType}: Logavel=${objeto is Logavel}, '
        'Validavel=${objeto is Validavel}');
  }

  print('');
  print('--- 4. Ordem de aplicação (linearização) ---');
  print('with PassoA, PassoB  -> ${OrdemAB().quem()}');
  print('with PassoB, PassoA  -> ${OrdemBA().quem()}');
  print('classe sobrescreve   -> ${OrdemComOverride().quem()}');
}
```

**Saída esperada:**

```text
--- 1. O mesmo mixin de log em classes sem parentesco ---
[Materia:m1] estudou 45 min, total 45
[Materia:m1] estudou 30 min, total 75
[Sync] enviou 2 item(ns), acumulado 2
[Sync] enviou 3 item(ns), acumulado 5
Eventos: matéria=2, sync=2

--- 2. Mixin de validação com `on Entidade` ---
Dart (75 min) é válida? true
Erros de "D (-5 min)":
 - O nome precisa ter ao menos 2 letras.
 - Os minutos não podem ser negativos.
 - O id não pode ser vazio.

--- 3. Mixins criam tipos ---
Materia: Logavel=true, Validavel=true
SincronizadorRemoto: Logavel=true, Validavel=false

--- 4. Ordem de aplicação (linearização) ---
with PassoA, PassoB  -> Base → A → B
with PassoB, PassoA  -> Base → B → A
classe sobrescreve   -> Base → A → B → e a classe fecha
```

---

## 🔍 Explicando o código

**`mixin Logavel { final List<String> _eventos = <String>[]; }`**
Mixins **podem ter campos**. Isso é o que os diferencia de uma interface: eles trazem estado e
comportamento, não só assinatura.

**`String get identificacao;` dentro do mixin**
Membro abstrato. Quem misturar o mixin é obrigado a fornecê-lo, senão:

```text
Error: Missing concrete implementation of 'Logavel.identificacao'.
```

É a forma de um mixin sem `on` **exigir** algo de quem o usa.

**`List<String>.unmodifiable(_eventos)`**
Devolve uma cópia imutável. Sem isso, quem chamasse `materia.historico.clear()` apagaria o log
interno — o encapsulamento da Aula 3 vazaria.

**`mixin Validavel on Entidade`**
Aqui está o poder do `on`: dentro do mixin, `id` é visível como se fosse um campo dele. Sem o `on`,
`id` nem compilaria.

**`class Materia extends Entidade with Logavel, Validavel`**
Uma superclasse e **dois** mixins. Herança simples continua valendo — mixin não é herança múltipla,
é inserção de camadas na mesma cadeia linear.

**`Materia({required String id, ...}) : super(id);`**
Construtor da subclasse chamando o da superclasse. Note que aqui **não** dá para usar `super.id`
como super parâmetro, porque `id` é posicional em `Entidade` e nomeado aqui — a forma longa resolve.

**`class SincronizadorRemoto with Logavel`**
Sem `extends`: a classe herda de `Object` implicitamente e recebe o mixin. Esta é a prova do
argumento da aula: o mesmo comportamento em duas hierarquias sem nenhum parentesco.

**`objeto is Logavel` → `true` para as duas classes**
Mixin cria tipo. Você poderia escrever `void auditar(Logavel alvo)` e passar qualquer uma delas.

**`mixin PassoA on Base { @override String quem() => '${super.quem()} → A'; }`**
`super.quem()` aqui **não** significa "Base" necessariamente: significa "o elemento anterior na
cadeia". Em `OrdemBA`, quando `PassoA` roda, o anterior é `Base+PassoB` — por isso a saída é
`Base → B → A`.

**`OrdemComOverride`**
A classe é o **último** elo da cadeia: o `super.quem()` dela executa toda a pilha de mixins e só
depois acrescenta o próprio texto.

**Por que `on Base` nos mixins de linearização?**
Sem `on Base`, o `super.quem()` não compilaria: o mixin não teria como saber que existe um `quem()`
acima dele.

---

## ⚠️ Erros comuns

**1. Aplicar mixin com `on` na classe errada**

```dart
class Sessao with Validavel {} // ❌ Sessao não é Entidade
```
```text
Error: 'Sessao' can't use the mixin 'Validavel' because 'Validavel' can only be
mixed in on subclasses of 'Entidade'.
```

**2. Tentar dar construtor a um mixin**

```dart
mixin Logavel {
  Logavel(); // ❌
}
```
```text
Error: Mixins can't declare constructors.
```
✅ Inicialize os campos na declaração: `final List<String> _eventos = <String>[];`

**3. Instanciar um mixin**

```dart
final l = Logavel(); // ❌
```
```text
Error: Mixins can't be instantiated.
```

**4. Usar uma `class` comum como mixin (Dart 3)**

```dart
class Auditavel { void auditar() {} }
class X with Auditavel {} // ❌ no Dart 3
```
```text
Error: The class 'Auditavel' can't be used as a mixin because it isn't a mixin
class nor a mixin.
```
✅ Declare `mixin class Auditavel` ou converta para `mixin`.

**5. Achar que a ordem não importa**

`with A, B` e `with B, A` produzem resultados diferentes quando ambos definem o mesmo membro.
✅ Leia da esquerda para a direita; o **último vence**.

**6. Empilhar mixins demais**

```dart
class Tela extends Base with A, B, C, D, E {} // ❌
```
Ninguém mais sabe de onde vem cada método. ✅ Três é muito; prefira composição a partir daí.

**7. Esperar `super` apontando para a superclasse original**

Dentro de um mixin, `super` é **o elo anterior da cadeia**, que pode ser outro mixin.
✅ Desenhe a cadeia antes de depender de `super`.

**8. Mixin com estado compartilhado por engano**

Campos de mixin são **por instância**, não globais. Cada `Materia` tem o seu `_eventos`. Se você
quer algo compartilhado, precisa de `static` — e aí pense duas vezes, porque estado global complica
teste.

---

## 🛠️ Exercício guiado

Vamos escrever um mixin de **auditoria de tempo** e aplicá-lo a duas classes sem parentesco.

**Passo 1.** Crie `bin/guiado_06_auditoria.dart` com o mixin:

```dart
mixin AuditaTempo {
  final List<int> _medicoes = <int>[];

  String get rotulo; // exigência para quem usar

  void medir(int minutos) {
    if (minutos > 0) {
      _medicoes.add(minutos);
    }
  }

  int get totalDeMinutos =>
      _medicoes.fold<int>(0, (soma, item) => soma + item);

  double get mediaDeMinutos =>
      _medicoes.isEmpty ? 0 : totalDeMinutos / _medicoes.length;

  String get resumoAuditoria =>
      '$rotulo: ${_medicoes.length} medição(ões), $totalDeMinutos min, '
      'média ${mediaDeMinutos.toStringAsFixed(1)} min';
}
```

`fold` percorre a lista acumulando um valor — você viu em
[`02-dart-basico/08-listas.md`](../02-dart-basico/08-listas.md).

**Passo 2.** Primeira classe, de estudo:

```dart
class PlanoDeEstudo with AuditaTempo {
  final String materia;

  PlanoDeEstudo(this.materia);

  @override
  String get rotulo => 'Estudo de $materia';

  void sessao(int minutos) => medir(minutos);
}
```

**Passo 3.** Segunda classe, de assunto completamente diferente:

```dart
class RotinaDeExercicio with AuditaTempo {
  @override
  String get rotulo => 'Exercício físico';

  void treino(int minutos) => medir(minutos);
}
```

**Passo 4.** Uma função que aceita **qualquer** coisa que audite tempo:

```dart
void imprimirAuditoria(List<AuditaTempo> itens) {
  for (final item in itens) {
    print(item.resumoAuditoria);
  }
}
```

**Passo 5.** `main`:

```dart
void main() {
  final dart = PlanoDeEstudo('Dart')
    ..sessao(45)
    ..sessao(30)
    ..sessao(-10); // recusado pelo mixin

  final corrida = RotinaDeExercicio()
    ..treino(25)
    ..treino(35);

  imprimirAuditoria(<AuditaTempo>[dart, corrida]);
}
```

**Passo 6.** Execute:

```powershell
dart run bin/guiado_06_auditoria.dart
```

**Saída esperada:**

```text
Estudo de Dart: 2 medição(ões), 75 min, média 37.5 min
Exercício físico: 2 medição(ões), 60 min, média 30.0 min
```

**Passo 7.** Perceba o que aconteceu: `List<AuditaTempo>` aceitou duas classes que não têm
superclasse em comum. O mixin criou um tipo que atravessa a hierarquia — isso é impossível com
`extends`.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Construa três mixins pequenos e combine-os:

```dart
mixin Identificavel { String get id; }
mixin Datavel { DateTime get criadoEm; String get criadoFormatado => ...; }
mixin Serializavel { Map<String, Object?> paraMapa(); String paraJsonSimples() => ...; }
```

Depois:

1. Crie `class Nota with Identificavel, Datavel, Serializavel`.
2. Escreva `String exportar(Object item)` que, usando `is`, produz uma linha diferente conforme os
   mixins que o objeto tiver — mostrando que os testes de tipo funcionam com mixins.
3. Agora **desafie a si mesmo**: reescreva a mesma solução usando **composição** (um campo
   `Metadados` com `id` e `criadoEm`). Compare as duas versões e escreva, em comentário, qual delas
   você preferiria manter em um app com 30 modelos — e por quê. Não existe resposta única; existe
   resposta **justificada**.

---

## 📌 Resumo

- `mixin` é um bloco reutilizável de comportamento **com corpo e com campos**, aplicado via `with`.
- Mixins **não têm construtor** e **não podem ser instanciados**.
- `on Tipo` restringe onde o mixin pode ser aplicado e dá acesso aos membros desse tipo.
- Um mixin pode exigir membros declarando-os **abstratos**.
- Aplicar um mixin **cria um tipo**: `objeto is MeuMixin` funciona.
- **Linearização**: `extends Base with A, B` monta `Base → Base+A → Base+A+B → Classe`.
  O último mixin vence; a classe vence todos; `super` aponta para o elo anterior.
- Use mixin para comportamento **transversal e pequeno**; use composição quando houver estado
  complexo; use herança só para relações "é-um".
- No Dart 3, uma classe comum não serve de mixin: declare `mixin class`.

---

## ☑️ Checklist de domínio

- [ ] Declaro um mixin com campo e método e o aplico com `with`.
- [ ] Explico o que `on Entidade` garante e o que ele libera.
- [ ] Sei prever a saída de `with A, B` versus `with B, A`.
- [ ] Explico para onde aponta `super` dentro de um mixin.
- [ ] Justifico, num caso concreto, mixin × herança × composição.
- [ ] Sei o erro que aparece ao instanciar um mixin e ao dar construtor a ele.
- [ ] Sei por que `class X with UmaClasseComum` não compila no Dart 3.
- [ ] Rodei `bin/06_mixins.dart` e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Mixins](https://dart.dev/language/mixins)
- [Dart — Class modifiers (`mixin class`)](https://dart.dev/language/class-modifiers#mixin)
- [API — `List.unmodifiable`](https://api.dart.dev/stable/dart-core/List/List.unmodifiable.html)
- [Flutter — `SingleTickerProviderStateMixin`](https://api.flutter.dev/flutter/widgets/SingleTickerProviderStateMixin-mixin.html)
- [Flutter — `WidgetsBindingObserver`](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-mixin.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Classes abstratas e interfaces](05-abstratas-e-interfaces.md) | [README](README.md) | [Aula 7 — Enums](07-enums.md) |
