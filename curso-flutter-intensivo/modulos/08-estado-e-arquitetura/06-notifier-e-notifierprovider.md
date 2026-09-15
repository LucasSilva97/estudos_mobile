# Aula 6 — Notifier e NotifierProvider

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Escrever um **`Notifier<T>`** completo: `build()`, campo `state` e métodos que alteram o estado.
- Explicar por que o estado precisa ser **imutável** — e o que exatamente quebra quando não é.
- Usar `copyWith` e *spread* (`...`) para produzir estado novo a partir do antigo.
- Diferenciar **`ref.watch(provider)`** de **`ref.read(provider.notifier)`** e usar cada um no
  lugar certo.
- Colocar as **regras de negócio dentro do notifier**, e não espalhadas pelas telas.
- Ler outros providers de dentro de um notifier com `ref.watch` e `ref.read`.
- Testar um notifier **sem montar nenhum widget**.

## ✅ Pré-requisitos

- [Aula 5 — Riverpod: primeiros passos](05-riverpod-primeiros-passos.md) — `ProviderScope`,
  `ConsumerWidget`, `watch` × `read` × `listen`. Esta aula continua exatamente de lá.
- [Módulo 03, aula 1 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md) e
  [aula 3 — Encapsulamento](../03-dart-intermediario/03-encapsulamento.md) — o notifier **é** uma
  classe, com estado privado e métodos públicos.
- [Módulo 02, aula 8 — Listas](../02-dart-basico/08-listas.md) — `map`, `where`, *spread*.
- O projeto `foco_estado` rodando com os providers da aula 5.

---

## 📖 Conceito

### O que é um `Notifier`

Na aula 5 você usou `NotifierProvider` sem explicação. Agora ele é o assunto.

Um **`Notifier<T>`** é uma classe que:

1. **guarda** um estado do tipo `T`;
2. **cria** o valor inicial no método `build()`;
3. **expõe métodos** que alteram esse estado;
4. **avisa** automaticamente quem observa, sempre que `state` recebe um valor novo.

```dart
final NotifierProvider<ContadorNotifier, int> contadorProvider =
    NotifierProvider<ContadorNotifier, int>(ContadorNotifier.new);

class ContadorNotifier extends Notifier<int> {
  @override
  int build() => 0;                          // estado inicial

  void incrementar() => state = state + 1;   // altera e notifica
  void zerar() => state = 0;
}
```

Três detalhes da declaração:

- **`NotifierProvider<ContadorNotifier, int>`** — dois tipos: a **classe** e o **estado**. Nessa
  ordem.
- **`ContadorNotifier.new`** — referência ao construtor, não uma chamada. Sem parênteses. O
  Riverpod chama quando precisar.
- **`build()`** — roda **uma vez**, na primeira leitura do provider. Não confunda com o `build` de
  widget, que roda muitas vezes.

### O campo `state`

`state` vem de graça na classe `Notifier`. Ele é:

| | |
|---|---|
| **Leitura** | `state` devolve o valor atual |
| **Escrita** | `state = novoValor` notifica todos os observadores |
| **Comparação** | O Riverpod compara o valor antigo com o novo. Se forem **iguais**, **não** notifica |

Essa última linha é a origem do erro número 1 desta aula.

### Por que o estado precisa ser imutável

O Riverpod decide se notifica comparando antigo e novo com `==`. Para uma `List`, `==` compara
**referência**, não conteúdo. Então:

```dart
// ❌ a lista muda, mas a REFERÊNCIA continua a mesma
void adicionar(Materia m) {
  state.add(m);          // a lista agora tem um item a mais…
  // …e o Riverpod compara a mesma referência com ela mesma: "não mudou".
  // Ninguém é notificado. A tela não atualiza.
}
```

```dart
// ✅ lista NOVA: referência diferente, notificação acontece
void adicionar(Materia m) {
  state = <Materia>[...state, m];
}
```

Esse bug é especialmente cruel porque **não dá erro**. O dado está certo na memória; a tela é que
não sabe. Você olha o estado no depurador, vê o item lá, e não entende por que a lista não mostra.

As três operações imutáveis que você vai usar todo dia:

```dart
// Adicionar
state = <Materia>[...state, nova];

// Remover
state = state.where((Materia m) => m.id != id).toList();

// Alterar um item
state = <Materia>[
  for (final Materia m in state)
    if (m.id == id) m.copyWith(nome: novoNome) else m,
];
```

> 💡 O terceiro usa `for` **dentro** de um literal de lista — *collection for*, do Dart. Ele
> substitui `map` + ternário e fica mais legível. Visto no
> [Módulo 02, aula 8](../02-dart-basico/08-listas.md).

Para objetos, o `copyWith` faz o mesmo papel:

```dart
// ❌ objeto mutável, mesma referência
state.nome = 'Novo';

// ✅ objeto novo
state = state.copyWith(nome: 'Novo');
```

### `provider` × `provider.notifier`

Todo `NotifierProvider` tem **duas faces**:

```dart
// A face do ESTADO: devolve o valor (int, List<Materia>, …)
final List<Materia> materias = ref.watch(materiasProvider);

// A face do NOTIFIER: devolve a classe, com os métodos
ref.read(materiasProvider.notifier).adicionar(nova);
```

| | `ref.watch(provider)` | `ref.read(provider.notifier)` |
|---|---|---|
| Devolve | O **estado** (`T`) | A **classe** notifier |
| Para quê | Desenhar a tela | Chamar métodos |
| Onde | No `build` | Em callbacks |
| Reconstrói | ✅ | ❌ |

> ⚠️ **`ref.watch(provider.notifier)` é quase sempre erro.** A instância do notifier praticamente
> nunca muda, então o `watch` não vai reconstruir nada — e você provavelmente queria observar o
> **estado**, não a classe.

### Regras de negócio moram no notifier

Compare duas formas de impedir uma meta inválida:

```dart
// ❌ regra na tela — e repetida em cada tela que mexe na meta
onPressed: () {
  if (valor >= 5 && valor <= 480) {
    ref.read(metaProvider.notifier).definir(valor);
  }
}
```

```dart
// ✅ regra no notifier — vale para TODAS as telas, sempre
class MetaNotifier extends Notifier<int> {
  @override
  int build() => 120;

  void definir(int minutos) {
    if (minutos < 5 || minutos > 480) return;   // a regra vive aqui
    state = minutos;
  }
}
```

A segunda forma tem três vantagens concretas:

1. Uma tela nova que mexa na meta **herda a regra de graça**.
2. A regra é testável sem widget.
3. Quando a regra mudar (meta máxima passa a 600), você edita **um** lugar.

> 📌 O notifier é a camada de **aplicação** do seu app. Ele conhece as regras; a tela só desenha e
> dispara ações. Essa separação é o que a [aula 9](09-arquitetura-feature-first.md) formaliza.

### Ler outros providers de dentro do notifier

Dentro de um `Notifier`, o `ref` é um campo da classe:

```dart
class SessoesNotifier extends Notifier<List<Sessao>> {
  @override
  List<Sessao> build() {
    // watch AQUI: se a meta mudar, este notifier é RECRIADO do zero.
    final int meta = ref.watch(metaProvider);
    return _gerarSessoesPadrao(meta);
  }

  void registrar(int minutos) {
    // read AQUI: só quero o valor agora, sem recriar o notifier.
    final int meta = ref.read(metaProvider);
    if (state.length >= meta) return;
    state = <Sessao>[...state, Sessao(minutos: minutos)];
  }
}
```

A diferença é grande:

| | `ref.watch` dentro do notifier | `ref.read` dentro do notifier |
|---|---|---|
| Onde usar | **No `build()`** | **Nos métodos** |
| Efeito quando a dependência muda | O notifier é **recriado**: `build()` roda de novo e o estado é **perdido** | Nada acontece |

> ⚠️ **`ref.watch` no `build()` do notifier reinicia o estado** quando a dependência muda. Às vezes
> é exatamente o que você quer (trocar de usuário deve zerar a lista). Muitas vezes não é (mudar a
> meta não deveria apagar as sessões do dia). Decida conscientemente.

### Testar sem widget

A vantagem prática mais concreta do Riverpod:

```dart
test('não deixa registrar sessão com minutos negativos', () {
  final ProviderContainer container = ProviderContainer();
  addTearDown(container.dispose);

  container.read(minutosProvider.notifier).registrarSessao(-10);

  expect(container.read(minutosProvider), 0);
});
```

Nenhum `pumpWidget`, nenhum emulador, nenhuma tela. O teste roda em milissegundos. O
`ProviderContainer` é o `ProviderScope` sem widgets — e é o assunto da
[aula 10](10-injecao-de-dependencias.md).

---

## 💡 Analogia

Pense num caixa de banco e no saldo da sua conta.

- **O `state`** é o **saldo**. Ele existe, tem um valor, e todo mundo que consulta vê o mesmo.
- **O `Notifier`** é o **caixa**: a única pessoa autorizada a mexer no saldo. Você não altera o
  saldo diretamente — você **pede uma operação** (`depositar`, `sacar`), e o caixa decide se pode.
- **As regras dentro do notifier** são as regras do banco: "não saca mais do que tem", "depósito
  mínimo de 1 real". Elas ficam **no caixa**, não em cada cliente. Se cada cliente tivesse que
  lembrar as regras, um dia alguém esqueceria — que é exatamente o que acontece quando a validação
  está na tela.
- **A imutabilidade** é o extrato. O banco não **apaga e reescreve** o número do saldo: ele emite um
  **saldo novo**. É por isso que dá para auditar, desfazer e comparar. E é por isso que
  `state.add(x)` não funciona: você rabiscou o extrato antigo em vez de emitir um novo — e o
  sistema, que só compara extratos, não vê diferença nenhuma.
- **`provider` × `provider.notifier`** é a diferença entre **consultar o saldo** e **falar com o
  caixa**. Você consulta o tempo todo; fala com o caixa só quando quer fazer algo.
- **`ref.watch` no `build()` do notifier** é o caixa dizendo "se a agência mudar de gerente, eu
  reabro a conta do zero". Às vezes é o certo (trocou de cliente); muitas vezes é desastre (mudou
  a taxa e o saldo sumiu).

---

## 🧪 Exemplo mínimo

Este programa mostra o erro da mutação acontecendo **lado a lado** com a forma correta.

> **Arquivo:** `foco_estado/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── ❌ ERRADO: muta a lista no lugar ───────────────────────────────────────
final NotifierProvider<ListaMutavelNotifier, List<String>> listaMutavelProvider =
    NotifierProvider<ListaMutavelNotifier, List<String>>(
        ListaMutavelNotifier.new);

class ListaMutavelNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => <String>['Dart'];

  void adicionar(String item) {
    // A lista realmente ganha o item. Mas a REFERÊNCIA é a mesma,
    // então o Riverpod compara a lista com ela mesma e conclui
    // que nada mudou. Ninguém é notificado. A tela não atualiza.
    state.add(item);
  }
}

// ── ✅ CERTO: cria uma lista nova ──────────────────────────────────────────
final NotifierProvider<ListaImutavelNotifier, List<String>>
    listaImutavelProvider =
    NotifierProvider<ListaImutavelNotifier, List<String>>(
        ListaImutavelNotifier.new);

class ListaImutavelNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => <String>['Dart'];

  void adicionar(String item) {
    // Lista NOVA. Referência diferente → notificação acontece.
    state = <String>[...state, item];
  }

  void remover(String item) {
    state = state.where((String e) => e != item).toList();
  }

  void renomear(String antigo, String novo) {
    // collection for dentro do literal: substitui map + ternário.
    state = <String>[
      for (final String e in state)
        if (e == antigo) novo else e,
    ];
  }
}

// ── App ────────────────────────────────────────────────────────────────────

void main() => runApp(const ProviderScope(child: AppNotifier()));

class AppNotifier extends StatelessWidget {
  const AppNotifier({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaDemo(),
    );
  }
}

class TelaDemo extends ConsumerWidget {
  const TelaDemo({super.key});

  static const List<String> _candidatos = <String>[
    'Flutter', 'Git', 'SQL', 'Testes', 'HTTP',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch(provider) → o ESTADO. É o que a tela desenha.
    final List<String> mutavel = ref.watch(listaMutavelProvider);
    final List<String> imutavel = ref.watch(listaImutavelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mutar × Atribuir')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            color: Colors.red.withValues(alpha: 0.10),
            child: ListTile(
              title: const Text('❌ state.add(item)'),
              subtitle: Text('${mutavel.length} itens: ${mutavel.join(", ")}'),
            ),
          ),
          Card(
            color: Colors.green.withValues(alpha: 0.10),
            child: ListTile(
              title: const Text('✅ state = [...state, item]'),
              subtitle: Text('${imutavel.length} itens: ${imutavel.join(", ")}'),
            ),
          ),
          const SizedBox(height: 16),

          FilledButton(
            onPressed: () {
              final String item =
                  _candidatos[mutavel.length % _candidatos.length];
              // read(provider.notifier) → a CLASSE, com os métodos.
              ref.read(listaMutavelProvider.notifier).adicionar(item);
              ref.read(listaImutavelProvider.notifier).adicionar(item);
            },
            child: const Text('Adicionar nos dois'),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Aperte várias vezes. O cartão vermelho NÃO muda na tela — '
              'apesar de a lista dele estar crescendo na memória.\n\n'
              'Depois aperte "Forçar rebuild": o número do vermelho pula '
              'de uma vez. O dado sempre esteve lá; faltou a notificação.',
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // Mexer no provider CERTO força um rebuild da tela,
              // e aí o valor do errado aparece — provando que o dado
              // estava lá o tempo todo.
              ref.read(listaImutavelProvider.notifier).adicionar('—');
            },
            child: const Text('Forçar rebuild'),
          ),
        ],
      ),
    );
  }
}
```

**O roteiro que prova o ponto:**

1. Aperte "Adicionar nos dois" **três vezes**. O cartão verde vai de 1 para 4 itens; o vermelho
   fica em 1.
2. Aperte "Forçar rebuild". O vermelho **pula para 4 de uma vez**.
3. Conclusão: o dado sempre esteve lá. O que faltava era a **notificação** — e ela só acontece
   quando `state` recebe um valor novo.

Esse é, com folga, o bug mais comum de quem começa com Riverpod.

---

## 📱 Aplicando no Flutter

Agora o `foco_estado` ganha estado **de verdade**: uma lista de matérias e uma lista de sessões,
com regras de negócio dentro dos notifiers.

Você vai criar:

- `lib/dominio/materia.dart` e `lib/dominio/sessao.dart` — os modelos imutáveis;
- `lib/estado/materias_notifier.dart` — CRUD de matérias;
- `lib/estado/sessoes_notifier.dart` — registro de sessões, com regras;
- providers derivados que combinam os dois.

---

## 💻 Código completo

> **Arquivo:** `foco_estado/lib/dominio/materia.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Uma matéria de estudo.
///
/// Todos os campos são `final`: o objeto é IMUTÁVEL. Para "mudar" uma
/// matéria, você cria outra com copyWith. Isso é o que permite ao Riverpod
/// comparar estado antigo e novo de forma confiável.
@immutable
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.metaMinutos,
    this.icone = Icons.menu_book_outlined,
  });

  final String id;
  final String nome;
  final int metaMinutos;
  final IconData icone;

  Materia copyWith({
    String? id,
    String? nome,
    int? metaMinutos,
    IconData? icone,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      metaMinutos: metaMinutos ?? this.metaMinutos,
      icone: icone ?? this.icone,
    );
  }

  /// == e hashCode por VALOR.
  ///
  /// Sem isto, duas matérias com os mesmos dados seriam consideradas
  /// diferentes — e o Riverpod notificaria mudanças que não existem.
  @override
  bool operator ==(Object outro) {
    if (identical(this, outro)) return true;
    return outro is Materia &&
        outro.id == id &&
        outro.nome == nome &&
        outro.metaMinutos == metaMinutos &&
        outro.icone == icone;
  }

  @override
  int get hashCode => Object.hash(id, nome, metaMinutos, icone);

  @override
  String toString() => 'Materia($id, $nome, $metaMinutos min)';
}
```

> **Arquivo:** `foco_estado/lib/dominio/sessao.dart` (novo)

```dart
import 'package:flutter/foundation.dart';

/// Uma sessão de estudo registrada.
@immutable
class Sessao {
  const Sessao({
    required this.id,
    required this.materiaId,
    required this.minutos,
    required this.quando,
    this.anotacao = '',
  });

  final String id;
  final String materiaId;
  final int minutos;
  final DateTime quando;
  final String anotacao;

  bool get ehDeHoje {
    final DateTime agora = DateTime.now();
    return quando.year == agora.year &&
        quando.month == agora.month &&
        quando.day == agora.day;
  }

  Sessao copyWith({
    String? id,
    String? materiaId,
    int? minutos,
    DateTime? quando,
    String? anotacao,
  }) {
    return Sessao(
      id: id ?? this.id,
      materiaId: materiaId ?? this.materiaId,
      minutos: minutos ?? this.minutos,
      quando: quando ?? this.quando,
      anotacao: anotacao ?? this.anotacao,
    );
  }

  @override
  bool operator ==(Object outro) {
    if (identical(this, outro)) return true;
    return outro is Sessao &&
        outro.id == id &&
        outro.materiaId == materiaId &&
        outro.minutos == minutos &&
        outro.quando == quando &&
        outro.anotacao == anotacao;
  }

  @override
  int get hashCode => Object.hash(id, materiaId, minutos, quando, anotacao);
}
```

> **Arquivo:** `foco_estado/lib/estado/materias_notifier.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/dominio/materia.dart';

/// Estado: a lista de matérias do usuário.
///
/// Dois tipos no NotifierProvider: a CLASSE e o ESTADO, nessa ordem.
/// `MateriasNotifier.new` é a referência ao construtor — sem parênteses.
final NotifierProvider<MateriasNotifier, List<Materia>> materiasProvider =
    NotifierProvider<MateriasNotifier, List<Materia>>(MateriasNotifier.new);

class MateriasNotifier extends Notifier<List<Materia>> {
  /// Roda UMA vez, na primeira leitura do provider.
  /// Não confunda com o build() de widget, que roda muitas vezes.
  @override
  List<Materia> build() {
    return <Materia>[
      const Materia(
          id: 'dart', nome: 'Dart', metaMinutos: 120, icone: Icons.code),
      const Materia(
          id: 'flutter',
          nome: 'Flutter',
          metaMinutos: 120,
          icone: Icons.phone_android),
      const Materia(
          id: 'git',
          nome: 'Git e terminal',
          metaMinutos: 90,
          icone: Icons.terminal),
    ];
  }

  // ── Regras de negócio ─────────────────────────────────────────────────────
  // Elas moram AQUI, não nas telas. Uma tela nova herda as regras de graça,
  // e quando a regra mudar você edita um lugar só.

  /// Adiciona uma matéria. Recusa nome vazio ou duplicado.
  ///
  /// Devolve true se adicionou, para a tela poder dar retorno ao usuário.
  bool adicionar(Materia nova) {
    final String nome = nova.nome.trim();
    if (nome.isEmpty) return false;
    if (_existeNome(nome)) return false;

    // Lista NOVA, com o spread. `state.add(nova)` não notificaria ninguém.
    state = <Materia>[...state, nova.copyWith(nome: nome)];
    return true;
  }

  /// Remove por id.
  void remover(String id) {
    // where + toList devolve uma lista nova — exatamente o que precisamos.
    state = state.where((Materia m) => m.id != id).toList();
  }

  /// Renomeia, mantendo o resto igual.
  bool renomear(String id, String novoNome) {
    final String nome = novoNome.trim();
    if (nome.isEmpty) return false;
    // Duplicata: ignora a própria matéria na comparação.
    if (_existeNome(nome, exceto: id)) return false;

    state = <Materia>[
      for (final Materia m in state)
        if (m.id == id) m.copyWith(nome: nome) else m,
    ];
    return true;
  }

  /// Altera a meta, respeitando a faixa válida.
  bool definirMeta(String id, int minutos) {
    if (minutos < 5 || minutos > 480) return false;

    state = <Materia>[
      for (final Materia m in state)
        if (m.id == id) m.copyWith(metaMinutos: minutos) else m,
    ];
    return true;
  }

  /// Volta ao estado inicial. Útil em testes e no botão "restaurar".
  void restaurarPadrao() => state = build();

  bool _existeNome(String nome, {String? exceto}) {
    final String alvo = nome.toLowerCase();
    return state.any((Materia m) =>
        m.id != exceto && m.nome.toLowerCase() == alvo);
  }
}

/// ── Providers derivados ──────────────────────────────────────────────────

/// Só os ids, para quem precisa validar referências sem carregar tudo.
final Provider<Set<String>> idsDeMateriasProvider = Provider<Set<String>>((Ref ref) {
  return ref.watch(materiasProvider).map((Materia m) => m.id).toSet();
});

/// Soma das metas de todas as matérias.
final Provider<int> metaTotalProvider = Provider<int>((Ref ref) {
  return ref
      .watch(materiasProvider)
      .fold(0, (int soma, Materia m) => soma + m.metaMinutos);
});
```

> **Arquivo:** `foco_estado/lib/estado/sessoes_notifier.dart` (novo)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/dominio/sessao.dart';
import 'package:foco_estado/estado/materias_notifier.dart';

/// Estado: todas as sessões registradas.
final NotifierProvider<SessoesNotifier, List<Sessao>> sessoesProvider =
    NotifierProvider<SessoesNotifier, List<Sessao>>(SessoesNotifier.new);

class SessoesNotifier extends Notifier<List<Sessao>> {
  @override
  List<Sessao> build() => <Sessao>[];

  /// Registra uma sessão.
  ///
  /// Devolve null em caso de sucesso, ou a mensagem de erro — assim a tela
  /// não precisa saber nenhuma das regras para dar um retorno útil.
  String? registrar({
    required String materiaId,
    required int minutos,
    String anotacao = '',
  }) {
    // REGRA 1: duração válida.
    if (minutos < 1) return 'A sessão precisa ter pelo menos 1 minuto';
    if (minutos > 480) return 'Uma sessão não pode passar de 8 horas';

    // REGRA 2: a matéria precisa existir.
    //
    // ref.read aqui (não watch): queremos o valor AGORA, sem fazer este
    // notifier ser recriado toda vez que a lista de matérias mudar.
    final Set<String> ids = ref.read(idsDeMateriasProvider);
    if (!ids.contains(materiaId)) return 'Matéria não encontrada';

    // REGRA 3: limite diário.
    final int jaHoje = _minutosDeHoje();
    if (jaHoje + minutos > 720) {
      return 'Limite de 12 horas por dia atingido';
    }

    state = <Sessao>[
      ...state,
      Sessao(
        id: 's_${DateTime.now().microsecondsSinceEpoch}',
        materiaId: materiaId,
        minutos: minutos,
        quando: DateTime.now(),
        anotacao: anotacao.trim(),
      ),
    ];
    return null;
  }

  void remover(String id) {
    state = state.where((Sessao s) => s.id != id).toList();
  }

  bool anotar(String id, String anotacao) {
    final String texto = anotacao.trim();
    if (texto.length > 200) return false;

    state = <Sessao>[
      for (final Sessao s in state)
        if (s.id == id) s.copyWith(anotacao: texto) else s,
    ];
    return true;
  }

  /// Remove todas as sessões de uma matéria.
  /// Chamado quando a matéria é excluída, para não sobrar órfã.
  void removerDaMateria(String materiaId) {
    state = state.where((Sessao s) => s.materiaId != materiaId).toList();
  }

  void limparTudo() => state = <Sessao>[];

  int _minutosDeHoje() => state
      .where((Sessao s) => s.ehDeHoje)
      .fold(0, (int soma, Sessao s) => soma + s.minutos);
}

/// ── Providers derivados ──────────────────────────────────────────────────

final Provider<List<Sessao>> sessoesDeHojeProvider =
    Provider<List<Sessao>>((Ref ref) {
  return ref.watch(sessoesProvider).where((Sessao s) => s.ehDeHoje).toList();
});

final Provider<int> minutosDeHojeProvider = Provider<int>((Ref ref) {
  return ref
      .watch(sessoesDeHojeProvider)
      .fold(0, (int soma, Sessao s) => soma + s.minutos);
});

/// Minutos por matéria — combina os DOIS notifiers.
///
/// Com InheritedWidget, este cálculo teria que ser refeito na mão sempre
/// que qualquer um dos dois mudasse. Aqui, basta declarar as dependências.
final Provider<Map<String, int>> minutosPorMateriaProvider =
    Provider<Map<String, int>>((Ref ref) {
  final List<Sessao> sessoes = ref.watch(sessoesDeHojeProvider);

  final Map<String, int> mapa = <String, int>{};
  for (final Sessao s in sessoes) {
    mapa[s.materiaId] = (mapa[s.materiaId] ?? 0) + s.minutos;
  }
  return mapa;
});

/// A matéria mais estudada hoje. null quando não houve sessão.
final Provider<String?> materiaEmDestaqueProvider = Provider<String?>((Ref ref) {
  final Map<String, int> porMateria = ref.watch(minutosPorMateriaProvider);
  if (porMateria.isEmpty) return null;

  String? melhorId;
  int melhorMinutos = -1;
  for (final MapEntry<String, int> e in porMateria.entries) {
    if (e.value > melhorMinutos) {
      melhorId = e.key;
      melhorMinutos = e.value;
    }
  }
  return melhorId;
});
```

> **Arquivo:** `foco_estado/lib/telas/home_screen.dart` (usando os notifiers)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/dominio/materia.dart';
import 'package:foco_estado/estado/materias_notifier.dart';
import 'package:foco_estado/estado/sessoes_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Materia> materias = ref.watch(materiasProvider);
    final int minutosHoje = ref.watch(minutosDeHojeProvider);
    final String? destaque = ref.watch(materiaEmDestaqueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hoje · $minutosHoje min'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpar sessões',
            onPressed: () => ref.read(sessoesProvider.notifier).limparTudo(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (destaque != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events_outlined),
                title: const Text('Matéria em destaque hoje'),
                subtitle: Text(
                  materias.firstWhere((Materia m) => m.id == destaque).nome,
                ),
              ),
            ),
          const SizedBox(height: 8),

          for (final Materia m in materias)
            _CartaoMateria(materia: m),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova matéria',
        onPressed: () => _adicionarMateria(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _adicionarMateria(BuildContext context, WidgetRef ref) {
    final int quantas = ref.read(materiasProvider).length;

    // A TELA não valida nada: ela chama o método e usa a resposta.
    // Toda a regra (nome vazio, duplicado) está no notifier.
    final bool ok = ref.read(materiasProvider.notifier).adicionar(
          Materia(
            id: 'm_${DateTime.now().millisecondsSinceEpoch}',
            nome: 'Matéria ${quantas + 1}',
            metaMinutos: 60,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Matéria criada' : 'Já existe uma matéria com esse nome'),
      ),
    );
  }
}

class _CartaoMateria extends ConsumerWidget {
  const _CartaoMateria({required this.materia});

  final Materia materia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select: este cartão só reconstrói quando OS MINUTOS DESTA matéria
    // mudam. Registrar sessão em outra matéria não o afeta.
    final int minutos = ref.watch(
      minutosPorMateriaProvider.select(
        (Map<String, int> mapa) => mapa[materia.id] ?? 0,
      ),
    );

    final double progresso =
        (minutos / materia.metaMinutos).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(materia.icone),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(materia.nome,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir matéria',
                  onPressed: () {
                    // Duas operações coordenadas, cada uma no seu notifier.
                    ref
                        .read(sessoesProvider.notifier)
                        .removerDaMateria(materia.id);
                    ref.read(materiasProvider.notifier).remover(materia.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progresso),
            const SizedBox(height: 8),
            Text('$minutos de ${materia.metaMinutos} min'),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                for (final int q in <int>[15, 25, 50])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: () => _registrar(context, ref, q),
                      child: Text('+$q'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _registrar(BuildContext context, WidgetRef ref, int minutos) {
    // O notifier devolve null (ok) ou a mensagem de erro.
    // A tela não conhece nenhuma das três regras.
    final String? erro = ref.read(sessoesProvider.notifier).registrar(
          materiaId: materia.id,
          minutos: minutos,
        );

    if (erro != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erro)));
    }
  }
}
```

Rode e confirme:

```powershell
flutter analyze
flutter run -d chrome
```

1. Registre sessões numa matéria: **só aquele cartão** reconstrói (por causa do `select`).
2. Exclua uma matéria: as sessões dela somem junto — o notifier de sessões foi avisado.
3. Aperte `+50` até passar de 12 horas no dia: a regra do notifier bloqueia com mensagem.
4. Crie matérias com o `+`: a segunda com o mesmo nome é recusada.

---

## 💻 Teste sem widget

> **Arquivo:** `foco_estado/test/sessoes_notifier_test.dart` (novo)
> **Como executar:** `flutter test`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_estado/dominio/sessao.dart';
import 'package:foco_estado/estado/sessoes_notifier.dart';

void main() {
  /// ProviderContainer é o ProviderScope SEM widgets.
  /// Cada teste ganha um container novo, com estado isolado —
  /// apesar de os providers serem variáveis globais.
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('registra sessão válida', () {
    final String? erro = container
        .read(sessoesProvider.notifier)
        .registrar(materiaId: 'dart', minutos: 25);

    expect(erro, isNull);
    expect(container.read(sessoesProvider).length, 1);
    expect(container.read(minutosDeHojeProvider), 25);
  });

  test('recusa sessão com menos de 1 minuto', () {
    final String? erro = container
        .read(sessoesProvider.notifier)
        .registrar(materiaId: 'dart', minutos: 0);

    expect(erro, isNotNull);
    expect(container.read(sessoesProvider), isEmpty);
  });

  test('recusa matéria inexistente', () {
    final String? erro = container
        .read(sessoesProvider.notifier)
        .registrar(materiaId: 'nao_existe', minutos: 25);

    expect(erro, 'Matéria não encontrada');
  });

  test('respeita o limite diário de 12 horas', () {
    final SessoesNotifier notifier = container.read(sessoesProvider.notifier);

    // 720 minutos = 12 h, em sessões de 480 + 240.
    expect(notifier.registrar(materiaId: 'dart', minutos: 480), isNull);
    expect(notifier.registrar(materiaId: 'dart', minutos: 240), isNull);

    final String? erro = notifier.registrar(materiaId: 'dart', minutos: 1);
    expect(erro, contains('Limite'));
  });

  test('o provider derivado soma por matéria', () {
    final SessoesNotifier notifier = container.read(sessoesProvider.notifier);
    notifier.registrar(materiaId: 'dart', minutos: 25);
    notifier.registrar(materiaId: 'dart', minutos: 15);
    notifier.registrar(materiaId: 'flutter', minutos: 50);

    final Map<String, int> porMateria =
        container.read(minutosPorMateriaProvider);

    expect(porMateria['dart'], 40);
    expect(porMateria['flutter'], 50);
    expect(container.read(materiaEmDestaqueProvider), 'flutter');
  });

  test('remover matéria remove as sessões dela', () {
    final SessoesNotifier notifier = container.read(sessoesProvider.notifier);
    notifier.registrar(materiaId: 'dart', minutos: 25);
    notifier.registrar(materiaId: 'flutter', minutos: 50);

    notifier.removerDaMateria('dart');

    final List<Sessao> restantes = container.read(sessoesProvider);
    expect(restantes.length, 1);
    expect(restantes.single.materiaId, 'flutter');
  });
}
```

```powershell
flutter test
```

Seis testes, sem emulador, sem `pumpWidget`, rodando em milissegundos. Essa é a vantagem prática de
ter as regras **no notifier** e não na tela.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `@immutable` nas classes de domínio | Anotação que faz o analisador cobrar campos `final`. Documenta a intenção e pega erro cedo. |
| `operator ==` e `hashCode` por valor | Sem isso, duas matérias idênticas seriam "diferentes", e o Riverpod notificaria mudanças inexistentes. |
| `Object.hash(a, b, c)` | Forma recomendada de combinar campos em `hashCode`. Nunca escreva o seu próprio algoritmo. |
| `NotifierProvider<MateriasNotifier, List<Materia>>` | Dois tipos: **classe** e **estado**, nessa ordem. |
| `MateriasNotifier.new` | Referência ao construtor, sem parênteses. O Riverpod chama quando precisar. |
| `List<Materia> build()` | Roda **uma vez**, na primeira leitura. Diferente do `build` de widget. |
| `state = <Materia>[...state, nova]` | Lista **nova** com *spread*. `state.add(...)` não notificaria. |
| `state.where(...).toList()` | `where` devolve um `Iterable` preguiçoso; `toList()` materializa a lista nova. |
| `for (final m in state) if (m.id == id) m.copyWith(...) else m` | *Collection for* dentro do literal: substitui `map` + ternário e lê melhor. |
| `bool adicionar(...)` devolvendo resultado | A tela não conhece as regras; ela chama e usa a resposta. |
| `String? registrar(...)` devolvendo mensagem | `null` = sucesso; texto = erro pronto para mostrar. Todas as três regras ficam no notifier. |
| `ref.read(idsDeMateriasProvider)` dentro de um **método** | `read`, não `watch`: queremos o valor agora, sem recriar o notifier quando matérias mudarem. |
| `restaurarPadrao() => state = build();` | Reaproveita o `build()` para voltar ao estado inicial. |
| `minutosPorMateriaProvider` lendo `sessoesDeHojeProvider` | Provider derivado combinando dados; recalcula sozinho. |
| `ref.watch(minutosPorMateriaProvider.select((mapa) => mapa[materia.id] ?? 0))` | O cartão só reconstrói quando **os minutos daquela matéria** mudam. |
| `removerDaMateria` chamado antes de `remover` | Ordem importa: apagar as sessões antes da matéria evita órfãs por um quadro. |
| `ProviderContainer()` + `addTearDown(container.dispose)` | Estado isolado por teste, apesar de os providers serem globais. |

---

## ⚠️ Erros comuns

### 1. Mutar o estado em vez de atribuir

```dart
void adicionar(Materia m) => state.add(m);   // ❌
```

A tela não atualiza. **E não dá erro.** O dado está lá; falta a notificação.

**Correção:** `state = <Materia>[...state, m];`

Vale para todas as mutações: `state.removeAt(0)`, `state.sort()`, `state.clear()`,
`state[0] = novo`, `state.nome = 'x'`. **Nenhuma** notifica.

### 2. `state.sort()`

```dart
void ordenar() => state.sort((Materia a, Materia b) => a.nome.compareTo(b.nome));   // ❌
```

`sort` ordena **no lugar**. Mesma referência, nenhuma notificação.

**Correção:**

```dart
void ordenar() {
  final List<Materia> copia = <Materia>[...state];
  copia.sort((Materia a, Materia b) => a.nome.compareTo(b.nome));
  state = copia;
}
```

### 3. Esquecer `==` e `hashCode` no modelo

Sem eles, `Materia(id: 'a') == Materia(id: 'a')` é `false`. O Riverpod acha que o estado mudou a
cada recálculo e reconstrói a tela sem parar.

**Correção:** implemente os dois — ou use um gerador de código para modelos, em projeto grande.

### 4. `ref.watch(provider.notifier)`

```dart
final MateriasNotifier n = ref.watch(materiasProvider.notifier);   // ⚠️
```

A instância do notifier quase nunca muda, então nada reconstrói. Você provavelmente queria o
**estado**.

**Correção:** `ref.watch(materiasProvider)` para o estado;
`ref.read(materiasProvider.notifier)` para os métodos.

### 5. `ref.watch` no `build()` do notifier sem querer

```dart
@override
List<Sessao> build() {
  final int meta = ref.watch(metaProvider);   // ⚠️
  return <Sessao>[];
}
```

Toda vez que a meta mudar, o notifier é **recriado** e todas as sessões são perdidas.

**Correção:** se a dependência não deve reiniciar o estado, use `ref.read` **dentro dos métodos**.

### 6. Regra de negócio na tela

```dart
onPressed: () {
  if (minutos > 0 && minutos < 480) {           // ❌ regra na tela
    ref.read(sessoesProvider.notifier).registrar(...);
  }
}
```

A próxima tela que registrar sessão vai esquecer a regra.

**Correção:** regra dentro do notifier; a tela chama e usa a resposta.

### 7. Chamar `build()` do notifier manualmente

```dart
void resetar() {
  build();   // ❌ roda o método, mas não atribui a state
}
```

**Correção:** `state = build();`

### 8. Guardar o estado em campo além do `state`

```dart
class MeuNotifier extends Notifier<int> {
  int _contadorInterno = 0;   // ❌ ninguém observa isto

  void incrementar() => _contadorInterno++;
}
```

**Correção:** todo estado observável vive em `state`. Campos privados servem só para coisas que a
tela não precisa ver (um `Timer`, por exemplo).

### 9. `ProviderContainer` sem `dispose` nos testes

```dart
test('...', () {
  final ProviderContainer container = ProviderContainer();   // ⚠️ vaza
});
```

**Correção:** `addTearDown(container.dispose);` logo depois de criar.

### 10. Modificar `state` dentro do `build()` do notifier

```dart
@override
List<Materia> build() {
  state = <Materia>[];   // ❌ state ainda não existe aqui
  return <Materia>[];
}
```

```text
Bad state: Cannot use "state" before the initialization is complete
```

**Correção:** o `build()` **devolve** o estado inicial; ele não o atribui.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e execute o roteiro de três passos. Confirme que o cartão
vermelho "pula" ao forçar o rebuild.

**Passo 2.** Em `MateriasNotifier.adicionar`, troque
`state = <Materia>[...state, nova]` por `state.add(nova)`. Crie uma matéria pelo `+`. Descreva o
que acontece e o que **não** acontece. Depois desfaça.

**Passo 3.** Remova `operator ==` e `hashCode` de `Materia`. Rode e registre uma sessão. Observe se
algo muda no comportamento ou no desempenho. Depois restaure.

**Passo 4.** Em `SessoesNotifier.registrar`, mova a regra do limite diário para dentro do
`_registrar` da tela. Depois crie uma **segunda** tela que também registre sessão. Quantas vezes
você precisou escrever a regra?

**Passo 5.** Em `SessoesNotifier.build()`, acrescente
`final Set<String> ids = ref.watch(idsDeMateriasProvider);`. Registre três sessões, depois crie uma
matéria nova. O que aconteceu com as sessões? Explique por escrito. Depois desfaça.

**Passo 6.** Acrescente um método `ordenarPorNome()` ao `MateriasNotifier` usando `state.sort()`.
Teste. Depois corrija para a forma imutável e teste de novo.

**Passo 7.** No `_CartaoMateria`, remova o `.select(...)` e observe com `debugPrint` quantos
cartões reconstroem ao registrar uma sessão. Depois restaure e compare.

**Passo 8.** Escreva um teste novo que confirme que `renomear` recusa nome duplicado — e que
**aceita** renomear uma matéria para o próprio nome atual.

**Passo 9.** Rode `flutter test` e confirme os seis testes passando. Depois quebre uma regra de
propósito no notifier e veja qual teste falha.

**Passo 10.** Responda por escrito: por que `registrar` devolve `String?` em vez de lançar exceção?
Quais seriam as vantagens e desvantagens de lançar?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

Faça os exercícios de **Aplicação** com CRUD imutável, o de **Correção de bugs** com `state.add`, e
o de **Compreensão** sobre onde as regras de negócio devem morar.

---

## 🏆 Desafio opcional

Acrescente **desfazer** (`undo`) e **refazer** (`redo`) ao `MateriasNotifier`, sem mudar nenhuma
linha das telas.

Requisitos:

- O notifier guarda um histórico dos estados anteriores (máximo de 20).
- `desfazer()` volta ao estado anterior; `refazer()` avança.
- Qualquer operação nova (`adicionar`, `remover`, `renomear`) **apaga** o histórico de refazer.
- Dois providers derivados, `podeDesfazerProvider` e `podeRefazerProvider`, controlam se os botões
  ficam habilitados.
- Os testes existentes continuam passando sem alteração.

Dica: a imutabilidade torna isso quase trivial — guardar o histórico é guardar as **referências**
dos estados antigos, e nenhum deles pode ter mudado no meio do caminho. Pense em qual método
privado deve ser o único ponto de escrita em `state`.

Depois responda: quanto código isso exigiria se o estado fosse mutável? Essa pergunta é a melhor
resposta para "por que imutabilidade?".

---

## 📌 Resumo

- Um **`Notifier<T>`** guarda o estado em `state`, cria o valor inicial em `build()` e expõe
  métodos que o alteram.
- `NotifierProvider<Classe, Estado>` leva **dois tipos**, nessa ordem, e recebe
  `Classe.new` (sem parênteses).
- O `build()` do notifier roda **uma vez**, na primeira leitura. Ele **devolve** o estado inicial —
  nunca atribui a `state`.
- **O estado precisa ser imutável.** O Riverpod compara antigo e novo com `==`; mutar no lugar
  mantém a referência e **não notifica ninguém** — sem dar erro.
- As três operações imutáveis: `[...state, novo]`, `state.where(...).toList()`, e *collection for*
  com `copyWith`.
- Modelos precisam de **`==` e `hashCode` por valor**, ou o Riverpod notifica mudanças inexistentes.
- **`ref.watch(provider)`** devolve o estado (use no `build`);
  **`ref.read(provider.notifier)`** devolve a classe (use em callbacks).
- `ref.watch(provider.notifier)` é quase sempre erro.
- **Regras de negócio moram no notifier**, não nas telas. Toda tela nova herda as regras de graça.
- Devolver `null` ou uma mensagem de erro deixa a tela dar retorno **sem conhecer as regras**.
- Dentro do notifier: `ref.watch` no `build()` **recria o notifier** quando a dependência muda;
  `ref.read` nos métodos, não.
- Notifiers são testáveis com **`ProviderContainer`**, sem widget, sem emulador — e cada teste tem
  estado isolado.

---

## ☑️ Checklist de domínio

- [ ] Escrevo um `Notifier<T>` completo sem consultar.
- [ ] Sei a ordem dos tipos em `NotifierProvider<Classe, Estado>`.
- [ ] Sei o que o `build()` do notifier faz e quantas vezes roda.
- [ ] Nunca muto o estado: adiciono, removo e altero produzindo valor novo.
- [ ] Reconheço `state.add`, `state.sort` e `state.campo = x` como bugs.
- [ ] Explico por que esse bug **não dá erro**.
- [ ] Implemento `==` e `hashCode` nos meus modelos.
- [ ] Uso `watch(provider)` para o estado e `read(provider.notifier)` para métodos.
- [ ] Coloco regras de negócio no notifier, e a tela só usa a resposta.
- [ ] Sei o efeito de `ref.watch` no `build()` do notifier e escolho conscientemente.
- [ ] Escrevo testes com `ProviderContainer` e `addTearDown(container.dispose)`.
- [ ] Meus testes de estado rodam sem `pumpWidget`.
- [ ] `flutter analyze` e `flutter test` passam limpos.

---

## 📚 Referências oficiais

- [Notifier — riverpod.dev](https://riverpod.dev/docs/essentials/first_request)
- [Side effects — riverpod.dev](https://riverpod.dev/docs/essentials/side_effects)
- [Testing — riverpod.dev](https://riverpod.dev/docs/essentials/testing)
- [NotifierProvider — pub.dev](https://pub.dev/documentation/riverpod/latest/riverpod/NotifierProvider-class.html)
- [Collection literals — dart.dev](https://dart.dev/language/collections#control-flow-operators)
- [Object.hash — api.dart.dev](https://api.dart.dev/stable/dart-core/Object/hash.html)
- [@immutable — api.flutter.dev](https://api.flutter.dev/flutter/meta/immutable-constant.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Riverpod: primeiros passos](05-riverpod-primeiros-passos.md) | [README](README.md) | [Aula 7 — AsyncNotifier e AsyncValue](07-asyncnotifier-e-asyncvalue.md) |
