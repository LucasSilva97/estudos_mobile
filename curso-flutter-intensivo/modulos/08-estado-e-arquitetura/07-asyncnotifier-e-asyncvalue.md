# Aula 7 — AsyncNotifier e AsyncValue

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 55 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é **`AsyncValue<T>`** e por que ele substitui o `sealed class` de estado que você
  escreveu no Módulo 06.
- Escrever um **`AsyncNotifier<T>`** com `Future<T> build()`.
- Desenhar os três estados com **`.when`** — e escolher entre `.when`, `.maybeWhen` e o `switch`
  com *pattern matching*.
- Usar **`AsyncValue.guard`** para capturar erros sem `try/catch` espalhado.
- Diferenciar `.value`, `.requireValue`, `.hasValue` e `.isLoading` — e saber quando cada um
  explode.
- Fazer **recarga sem piscar**, mantendo os dados antigos na tela.
- Alterar dados (criar, editar, excluir) num `AsyncNotifier` sem quebrar o estado.
- Tratar o caso de **erro depois de sucesso** (a recarga que falha).

## ✅ Pré-requisitos

- [Aula 6 — Notifier e NotifierProvider](06-notifier-e-notifierprovider.md) — `state`,
  imutabilidade, regras no notifier. Esta aula é a versão assíncrona daquilo.
- [Módulo 06, aula 12 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) —
  **essencial**: o `sealed class EstadoTela` que você escreveu lá **é** o `AsyncValue`.
- [Módulo 04, aula 2 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) e
  [aula 1 — Exceptions](../04-dart-avancado/01-exceptions.md).
- O projeto `foco_estado` rodando com os notifiers da aula 6.

---

## 📖 Conceito

### O problema

Tudo que você fez até aqui era **síncrono**: a lista de matérias já existia na memória. No mundo
real ela vem de uma API ou de um banco — e isso muda tudo:

```dart
class MateriasNotifier extends Notifier<List<Materia>> {
  @override
  List<Materia> build() {
    return _api.buscarMaterias();   // ❌ isto devolve Future<List<Materia>>
  }
}
```

Não compila. E mesmo que você contornasse, sobrariam as três perguntas do Módulo 06:

- E enquanto está carregando?
- E se der erro?
- E se vier vazio?

No Módulo 06 você resolveu isso escrevendo um `sealed class` na mão. O Riverpod já traz esse
`sealed class` pronto — e o nome dele é **`AsyncValue`**.

### `AsyncValue<T>`: os três estados prontos

```dart
sealed class AsyncValue<T> { }

// As três formas possíveis:
AsyncLoading<T>()               // carregando
AsyncData<T>(valor)             // deu certo, tem dados
AsyncError<T>(erro, pilha)      // falhou
```

Compare com o que você escreveu no Módulo 06:

| Seu `sealed class` (Módulo 06) | `AsyncValue` |
|---|---|
| `TelaCarregando<T>` | `AsyncLoading<T>` |
| `TelaSucesso<T>(dados)` | `AsyncData<T>(value)` |
| `TelaFalha<T>(mensagem)` | `AsyncError<T>(error, stackTrace)` |
| `TelaVazia<T>` | — (é `AsyncData` com lista vazia) |

É o mesmo padrão. A diferença é que o `AsyncValue` já vem integrado ao Riverpod: ele transiciona
sozinho entre os estados, captura exceções e cuida da recarga.

> 📌 **O "vazio" não é um estado do `AsyncValue`.** Uma lista vazia é sucesso — a busca funcionou e
> o resultado é "nenhum item". Você decide na tela se mostra `EstadoVazio` ou a lista. Isso é mais
> correto que o seu `sealed class` do Módulo 06: "vazio" é uma propriedade do **dado**, não da
> operação.

### `AsyncNotifier<T>`: o notifier assíncrono

```dart
final AsyncNotifierProvider<MateriasNotifier, List<Materia>> materiasProvider =
    AsyncNotifierProvider<MateriasNotifier, List<Materia>>(MateriasNotifier.new);

class MateriasNotifier extends AsyncNotifier<List<Materia>> {
  /// Note o Future no retorno. É a única diferença estrutural.
  @override
  Future<List<Materia>> build() async {
    return _api.buscarMaterias();
  }
}
```

O que o Riverpod faz por você, automaticamente:

1. Coloca o estado em **`AsyncLoading`** enquanto o `build()` não termina.
2. Se o `Future` completa, vira **`AsyncData(resultado)`**.
3. Se o `Future` **lança**, vira **`AsyncError(erro, pilha)`** — sem você escrever `try/catch`.

E o tipo do `state` passa a ser `AsyncValue<List<Materia>>`, não `List<Materia>`.

### Desenhando os três estados: `.when`

```dart
final AsyncValue<List<Materia>> materias = ref.watch(materiasProvider);

return materias.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (Object erro, StackTrace pilha) => EstadoErro(
    titulo: 'Não foi possível carregar',
    onTentarDeNovo: () => ref.invalidate(materiasProvider),
  ),
  data: (List<Materia> lista) => ListaMaterias(lista),
);
```

`.when` **exige** os três casos. Você não consegue esquecer nenhum — é o mesmo benefício do
`switch` exaustivo do Módulo 06, mas sem escrever a classe.

Existem variantes:

| Método | Quando usar |
|---|---|
| `.when(loading:, error:, data:)` | O caso normal. Os três obrigatórios |
| `.maybeWhen(data:, orElse:)` | Quando só um caso importa e o resto cai num padrão |
| `.whenOrNull(data:)` | Devolve `null` nos casos não tratados |
| `switch` com padrões | Quando você precisa de condições dentro dos casos |

A forma com `switch` (Dart 3) é útil quando há lógica:

```dart
return switch (materias) {
  AsyncData<List<Materia>>(value: final List<Materia> lista) when lista.isEmpty =>
    const EstadoVazio(),
  AsyncData<List<Materia>>(value: final List<Materia> lista) =>
    ListaMaterias(lista),
  AsyncError<List<Materia>>(error: final Object e) =>
    EstadoErro(mensagem: '$e', onTentarDeNovo: _recarregar),
  _ => const EsqueletoLista(),
};
```

Repare no **`when lista.isEmpty`** — uma cláusula de guarda dentro do padrão. É assim que você
separa "vazio" de "com itens" sem criar um estado novo.

### Os acessadores: `.value`, `.requireValue` e amigos

| Acessador | Tipo | Quando é seguro |
|---|---|---|
| `.value` | `T?` | **Sempre.** É `null` se não houver dados |
| `.requireValue` | `T` | **Só** quando você tem certeza de que há dados; senão **lança** |
| `.hasValue` | `bool` | Sempre |
| `.isLoading` | `bool` | Sempre |
| `.hasError` | `bool` | Sempre |
| `.error` | `Object?` | Sempre |

```dart
// ✅ seguro em qualquer estado
final List<Materia> lista = materias.value ?? <Materia>[];

// ⚠️ lança se ainda estiver carregando
final List<Materia> lista = materias.requireValue;
```

> ⚠️ **`.requireValue` é a fonte de crash número 1 com `AsyncValue`.** Ele parece prático, e
> funciona nos seus testes manuais — até o dia em que a rede está lenta e o widget constrói antes de
> os dados chegarem. Use `.value ?? padrão` ou `.when`.

### `AsyncValue.guard`: erro sem `try/catch`

Quando você **altera** dados (criar, excluir), precisa capturar o erro para o estado virar
`AsyncError` em vez de quebrar o app:

```dart
// ❌ verboso, e fácil de esquecer um caso
Future<void> adicionar(Materia nova) async {
  state = const AsyncLoading<List<Materia>>();
  try {
    await _api.criar(nova);
    final List<Materia> lista = await _api.buscarMaterias();
    state = AsyncData<List<Materia>>(lista);
  } catch (erro, pilha) {
    state = AsyncError<List<Materia>>(erro, pilha);
  }
}
```

```dart
// ✅ AsyncValue.guard faz o try/catch por você
Future<void> adicionar(Materia nova) async {
  state = const AsyncLoading<List<Materia>>();
  state = await AsyncValue.guard(() async {
    await _api.criar(nova);
    return _api.buscarMaterias();
  });
}
```

`AsyncValue.guard` roda a função e devolve `AsyncData` se der certo, `AsyncError` se lançar. Duas
linhas no lugar de oito.

### Recarga sem piscar

O problema: ao recarregar, `state = AsyncLoading()` **apaga os dados da tela**. O usuário perde a
rolagem e vê um esqueleto onde havia conteúdo.

A solução do Riverpod é `copyWithPrevious`:

```dart
Future<void> recarregar() async {
  // Mantém os dados antigos visíveis DURANTE o carregamento.
  state = const AsyncLoading<List<Materia>>()
      .copyWithPrevious(state);

  state = await AsyncValue.guard(() => _api.buscarMaterias());
}
```

Com isso, durante a recarga o estado é:

- `isLoading == true` (para mostrar a barra fina no topo);
- `hasValue == true` e `.value` com os **dados antigos** (para a lista continuar na tela).

Na tela:

```dart
final AsyncValue<List<Materia>> materias = ref.watch(materiasProvider);

// Recarregando COM dados: barra fina + lista antiga.
final bool recarregando = materias.isLoading && materias.hasValue;
```

> 💡 Esse é exatamente o quinto estado que o [Módulo 06, aula 12](../06-widgets-e-layouts/12-estados-de-ui.md)
> chamou de "recarregando com dados antigos". O `AsyncValue` o modela nativamente.

### `ref.invalidate` e `ref.refresh`

Duas formas de mandar um provider recarregar:

```dart
ref.invalidate(materiasProvider);   // descarta o estado; recarrega na próxima leitura
final AsyncValue<List<Materia>> novo = ref.refresh(materiasProvider);  // descarta E devolve o novo
```

| | `invalidate` | `refresh` |
|---|---|---|
| Descarta o estado | ✅ | ✅ |
| Devolve o novo valor | ❌ (`void`) | ✅ |
| Quando usar | Botão "tentar de novo", `RefreshIndicator` | Quando você precisa do valor na hora |

> ⚠️ Chamar `ref.refresh` e **ignorar** o retorno dispara o lint `unused_result`. Se você não vai
> usar o valor, use `invalidate`.

### Erro depois de sucesso

Um caso que quase todo app trata mal: a lista carregou, o usuário puxa para atualizar, e **a
recarga falha**.

O que **não** fazer: substituir a lista por uma tela de erro. O usuário tinha dados válidos e
agora não tem nada.

O que fazer: manter os dados e avisar do erro:

```dart
ref.listen<AsyncValue<List<Materia>>>(materiasProvider,
    (AsyncValue<List<Materia>>? antes, AsyncValue<List<Materia>> agora) {
  // Falhou MAS ainda há dados antigos na tela.
  if (agora.hasError && agora.hasValue) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não conseguimos atualizar. Mostrando dados salvos.')),
    );
  }
});
```

---

## 💡 Analogia

Pense num painel de voo no aeroporto.

- **`AsyncLoading`** é o painel dizendo **"consultando"**. Não há informação ainda, mas você sabe
  que o sistema está trabalhando — o que já é melhor que um painel apagado (a tela branca).
- **`AsyncData`** é o painel mostrando os voos. Repare: um painel **sem nenhum voo listado** não é
  erro nem "carregando" — é a resposta correta para "não há voos agora". É por isso que "vazio"
  **não é um estado** do `AsyncValue`: é o conteúdo do sucesso.
- **`AsyncError`** é o painel dizendo "sistema indisponível". Ele precisa dizer **o que houve** e
  **o que fazer** — nunca só apagar.
- **`.requireValue`** é ler o painel de olhos fechados, afirmando que os voos já estão lá. Funciona
  quando já estão. Quebra na primeira vez que você chega cedo demais.
- **`copyWithPrevious`** é o painel **continuar mostrando os voos antigos** com um pisca-pisca de
  "atualizando" no canto, em vez de apagar tudo para consultar de novo. Ninguém apaga o painel
  inteiro do aeroporto para atualizar um horário.
- **Erro depois de sucesso** é a consulta falhar durante a atualização. O painel certo mantém os
  horários antigos e acrescenta "informação de 5 minutos atrás". O painel errado apaga tudo e
  escreve "erro" — deixando mil passageiros sem nenhuma informação, quando havia informação
  ligeiramente desatualizada disponível.
- **`AsyncValue.guard`** é o sistema do painel já saber que toda consulta pode falhar, e ter o
  procedimento padrão — em vez de cada funcionário inventar o que fazer.

---

## 🧪 Exemplo mínimo

Uma busca falsa que falha em uma de cada três tentativas, com os três estados visíveis.

> **Arquivo:** `foco_estado/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider assíncrono ────────────────────────────────────────────────────

final AsyncNotifierProvider<FrasesNotifier, List<String>> frasesProvider =
    AsyncNotifierProvider<FrasesNotifier, List<String>>(FrasesNotifier.new);

class FrasesNotifier extends AsyncNotifier<List<String>> {
  /// A ÚNICA diferença estrutural para o Notifier da aula 6:
  /// o retorno é Future<T>.
  ///
  /// O Riverpod cuida do resto:
  /// - enquanto este Future não completa → AsyncLoading
  /// - se completar → AsyncData
  /// - se lançar → AsyncError (sem você escrever try/catch)
  @override
  Future<List<String>> build() async {
    return _buscar();
  }

  Future<List<String>> _buscar() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    // Falha em 1 de cada 3, para você ver o estado de erro.
    if (math.Random().nextInt(3) == 0) {
      throw Exception('Servidor indisponível');
    }

    return <String>[
      'Estudar é repetir com atenção.',
      'Uma sessão curta feita vale mais que uma longa planejada.',
      'O erro que você lê é o erro que você corrige.',
    ];
  }

  /// Recarga que APAGA a tela (para você comparar).
  Future<void> recarregarPiscando() async {
    state = const AsyncLoading<List<String>>();
    state = await AsyncValue.guard(_buscar);
  }

  /// Recarga que MANTÉM os dados antigos visíveis.
  Future<void> recarregarSuave() async {
    // copyWithPrevious: isLoading vira true, mas .value continua
    // com os dados antigos — a lista não some da tela.
    state = const AsyncLoading<List<String>>().copyWithPrevious(state);
    state = await AsyncValue.guard(_buscar);
  }

  /// Alteração de dados com guard: sem try/catch escrito à mão.
  Future<void> adicionar(String frase) async {
    final List<String> atual = state.value ?? <String>[];

    state = await AsyncValue.guard(() async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return <String>[...atual, frase];
    });
  }
}

// ── App ────────────────────────────────────────────────────────────────────

void main() => runApp(const ProviderScope(child: AppAsync()));

class AppAsync extends StatelessWidget {
  const AppAsync({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaFrases(),
    );
  }
}

class TelaFrases extends ConsumerWidget {
  const TelaFrases({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<String>> frases = ref.watch(frasesProvider);

    // Falhou MAS ainda há dados antigos: avise sem apagar a tela.
    ref.listen<AsyncValue<List<String>>>(frasesProvider,
        (AsyncValue<List<String>>? antes, AsyncValue<List<String>> agora) {
      if (agora.hasError && agora.hasValue) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Falha ao atualizar. Mostrando dados anteriores.'),
          ));
      }
    });

    // Recarregando COM dados na tela: barra fina, não esqueleto.
    final bool recarregando = frases.isLoading && frases.hasValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AsyncValue'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: SizedBox(
            height: 4,
            child: recarregando ? const LinearProgressIndicator() : null,
          ),
        ),
      ),

      // .when EXIGE os três casos. Impossível esquecer um.
      body: frases.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (Object erro, StackTrace pilha) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.cloud_off_outlined, size: 64),
              const SizedBox(height: 16),
              const Text('Não conseguimos carregar as frases'),
              const SizedBox(height: 8),
              Text('$erro', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar de novo'),
                // invalidate: descarta o estado; recarrega na próxima leitura.
                onPressed: () => ref.invalidate(frasesProvider),
              ),
            ],
          ),
        ),

        data: (List<String> lista) {
          // "Vazio" NÃO é estado do AsyncValue: é AsyncData com lista vazia.
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhuma frase ainda'));
          }
          return ListView(
            children: <Widget>[
              for (final String f in lista)
                ListTile(leading: const Icon(Icons.format_quote), title: Text(f)),
            ],
          );
        },
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: 'piscando',
            onPressed: () =>
                ref.read(frasesProvider.notifier).recarregarPiscando(),
            icon: const Icon(Icons.refresh),
            label: const Text('Recarregar (pisca)'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'suave',
            onPressed: () => ref.read(frasesProvider.notifier).recarregarSuave(),
            icon: const Icon(Icons.refresh),
            label: const Text('Recarregar (suave)'),
          ),
        ],
      ),
    );
  }
}
```

**O roteiro que ensina a aula:**

1. Abra e recarregue algumas vezes (`R`) até ver **os três estados**: carregando, lista e erro.
2. Com a lista na tela, aperte **"Recarregar (pisca)"**: a lista **some** e volta o indicador.
3. Aperte **"Recarregar (suave)"**: a lista **fica**, e uma barra fina aparece no topo.
4. Continue apertando "suave" até a recarga falhar: a lista **continua lá** e um `SnackBar` avisa.
   Compare com o que aconteceria se você tivesse usado `AsyncLoading()` puro.

O item 4 é a diferença entre um app que parece confiável e um que parece quebrado.

---

## 📱 Aplicando no Flutter

Agora o `foco_estado` passa a buscar as trilhas de estudo de uma **fonte de dados** — ainda falsa,
mas com atraso e falhas de verdade. No [Módulo 09](../09-consumo-de-api/README.md) essa fonte vira
HTTP real, e **nada** desta camada vai mudar.

Você vai criar:

- `lib/dados/trilhas_fonte.dart` — a fonte de dados falsa;
- `lib/dominio/trilha.dart` — o modelo;
- `lib/estado/trilhas_notifier.dart` — o `AsyncNotifier` com CRUD;
- a tela que trata os três estados sem um `if` solto.

---

## 💻 Código completo

> **Arquivo:** `foco_estado/lib/dominio/trilha.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/foundation.dart';

/// Uma trilha de estudo: um conjunto ordenado de temas.
@immutable
class Trilha {
  const Trilha({
    required this.id,
    required this.titulo,
    required this.temas,
    this.concluidos = const <String>{},
  });

  final String id;
  final String titulo;
  final List<String> temas;
  final Set<String> concluidos;

  double get progresso =>
      temas.isEmpty ? 0 : concluidos.length / temas.length;

  bool get completa => temas.isNotEmpty && concluidos.length == temas.length;

  Trilha copyWith({
    String? id,
    String? titulo,
    List<String>? temas,
    Set<String>? concluidos,
  }) {
    return Trilha(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      temas: temas ?? this.temas,
      concluidos: concluidos ?? this.concluidos,
    );
  }

  @override
  bool operator ==(Object outro) {
    if (identical(this, outro)) return true;
    return outro is Trilha &&
        outro.id == id &&
        outro.titulo == titulo &&
        listEquals(outro.temas, temas) &&
        setEquals(outro.concluidos, concluidos);
  }

  @override
  int get hashCode => Object.hash(
        id,
        titulo,
        Object.hashAll(temas),
        Object.hashAllUnordered(concluidos),
      );
}
```

> **Arquivo:** `foco_estado/lib/dados/trilhas_fonte.dart` (novo)

```dart
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/dominio/trilha.dart';

/// Erro de domínio da camada de dados.
///
/// Uma exceção PRÓPRIA (e não `Exception` genérica) permite que a tela
/// distinga "sem conexão" de "erro inesperado" — e dê mensagens diferentes.
class FalhaDeRede implements Exception {
  const FalhaDeRede([this.mensagem = 'Sem conexão com o servidor']);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Fonte de dados das trilhas.
///
/// Hoje é falsa, com atraso e falhas simuladas. No Módulo 09 ela vira HTTP
/// e NADA do TrilhasNotifier precisa mudar — porque ele depende desta
/// classe, não de `http`.
class TrilhasFonte {
  /// Estado interno simulando o "servidor".
  final List<Trilha> _servidor = <Trilha>[
    const Trilha(
      id: 'basico',
      titulo: 'Fundamentos de Dart',
      temas: <String>['Variáveis', 'Funções', 'Classes', 'Null safety'],
      concluidos: <String>{'Variáveis', 'Funções'},
    ),
    const Trilha(
      id: 'flutter',
      titulo: 'Primeiros widgets',
      temas: <String>['Stateless', 'Stateful', 'Layout', 'Navegação'],
      concluidos: <String>{'Stateless'},
    ),
  ];

  /// Falha em 1 de cada 4 chamadas, para exercitar o estado de erro.
  void _talvezFalhar() {
    if (math.Random().nextInt(4) == 0) {
      throw const FalhaDeRede();
    }
  }

  Future<List<Trilha>> listar() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _talvezFalhar();
    // Devolve uma CÓPIA: quem chama não deve poder mexer no "servidor".
    return List<Trilha>.unmodifiable(_servidor);
  }

  Future<Trilha> marcarTema(String trilhaId, String tema) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _talvezFalhar();

    final int i = _servidor.indexWhere((Trilha t) => t.id == trilhaId);
    if (i == -1) throw const FalhaDeRede('Trilha não encontrada');

    final Trilha antiga = _servidor[i];
    final Set<String> novos = <String>{...antiga.concluidos};
    if (!novos.remove(tema)) novos.add(tema);

    final Trilha nova = antiga.copyWith(concluidos: novos);
    _servidor[i] = nova;
    return nova;
  }

  Future<Trilha> criar(String titulo, List<String> temas) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _talvezFalhar();

    final Trilha nova = Trilha(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      titulo: titulo,
      temas: temas,
    );
    _servidor.add(nova);
    return nova;
  }

  Future<void> excluir(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _talvezFalhar();
    _servidor.removeWhere((Trilha t) => t.id == id);
  }
}

/// A fonte exposta como provider.
///
/// Isto é o que torna o notifier testável: na aula 10 você troca esta
/// implementação por uma falsa, sem tocar em nenhuma linha do notifier.
final Provider<TrilhasFonte> trilhasFonteProvider =
    Provider<TrilhasFonte>((Ref ref) => TrilhasFonte());
```

> **Arquivo:** `foco_estado/lib/estado/trilhas_notifier.dart` (novo)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/dados/trilhas_fonte.dart';
import 'package:foco_estado/dominio/trilha.dart';

/// Estado assíncrono: a lista de trilhas.
///
/// O tipo do `state` aqui é AsyncValue<List<Trilha>>, não List<Trilha>.
final AsyncNotifierProvider<TrilhasNotifier, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider<TrilhasNotifier, List<Trilha>>(TrilhasNotifier.new);

class TrilhasNotifier extends AsyncNotifier<List<Trilha>> {
  /// A única diferença estrutural para o Notifier da aula 6: Future<T>.
  ///
  /// O Riverpod coloca AsyncLoading enquanto isto não termina,
  /// AsyncData se completar e AsyncError se lançar. Sem try/catch.
  @override
  Future<List<Trilha>> build() async {
    final TrilhasFonte fonte = ref.watch(trilhasFonteProvider);
    return fonte.listar();
  }

  // ── Recarga ───────────────────────────────────────────────────────────────

  /// Recarrega mantendo os dados antigos na tela.
  ///
  /// Sem o copyWithPrevious, a lista sumiria e o usuário perderia
  /// a posição da rolagem — o problema que o Módulo 06 chamou de
  /// "recarregando com dados antigos".
  Future<void> recarregar() async {
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);

    // guard faz o try/catch: AsyncData se der certo, AsyncError se lançar.
    state = await AsyncValue.guard(
      () => ref.read(trilhasFonteProvider).listar(),
    );
  }

  // ── Alterações ────────────────────────────────────────────────────────────

  /// Marca ou desmarca um tema.
  ///
  /// Usa ATUALIZAÇÃO OTIMISTA: a tela muda na hora, e o servidor confirma
  /// depois. Se falhar, voltamos ao estado anterior.
  Future<void> alternarTema(String trilhaId, String tema) async {
    final List<Trilha>? atual = state.value;
    if (atual == null) return; // ainda carregando: ignora o toque

    // 1. Aplica localmente, para a tela responder instantaneamente.
    final List<Trilha> otimista = <Trilha>[
      for (final Trilha t in atual)
        if (t.id == trilhaId)
          t.copyWith(
            concluidos: t.concluidos.contains(tema)
                ? (<String>{...t.concluidos}..remove(tema))
                : <String>{...t.concluidos, tema},
          )
        else
          t,
    ];
    state = AsyncData<List<Trilha>>(otimista);

    // 2. Confirma no servidor.
    final AsyncValue<Trilha> resultado = await AsyncValue.guard(
      () => ref.read(trilhasFonteProvider).marcarTema(trilhaId, tema),
    );

    // 3. Deu errado? Volta ao estado anterior e reporta o erro,
    //    SEM apagar a lista da tela.
    if (resultado case AsyncError<Trilha>(:final Object error,
        :final StackTrace stackTrace)) {
      state = AsyncError<List<Trilha>>(error, stackTrace)
          .copyWithPrevious(AsyncData<List<Trilha>>(atual));
    }
  }

  /// Cria uma trilha. Regras de negócio ficam aqui, como na aula 6.
  Future<String?> criar(String titulo, List<String> temas) async {
    final String nome = titulo.trim();
    if (nome.isEmpty) return 'Informe o título da trilha';
    if (temas.isEmpty) return 'A trilha precisa de pelo menos um tema';

    final List<Trilha> atual = state.value ?? <Trilha>[];
    if (atual.any((Trilha t) => t.titulo.toLowerCase() == nome.toLowerCase())) {
      return 'Já existe uma trilha com esse título';
    }

    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await ref.read(trilhasFonteProvider).criar(nome, temas);
      return ref.read(trilhasFonteProvider).listar();
    });

    // Se o guard capturou erro, devolvemos a mensagem para a tela.
    return state.hasError ? 'Não foi possível criar a trilha' : null;
  }

  Future<void> excluir(String id) async {
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await ref.read(trilhasFonteProvider).excluir(id);
      return ref.read(trilhasFonteProvider).listar();
    });
  }
}

/// ── Providers derivados ──────────────────────────────────────────────────
/// Derivados de um AsyncValue continuam sendo AsyncValue — a "assincronia"
/// se propaga pela cascata sem você tratar nada.

final Provider<AsyncValue<int>> trilhasCompletasProvider =
    Provider<AsyncValue<int>>((Ref ref) {
  // whenData transforma só o caso de sucesso; loading e error passam direto.
  return ref.watch(trilhasProvider).whenData(
        (List<Trilha> lista) => lista.where((Trilha t) => t.completa).length,
      );
});

final Provider<AsyncValue<double>> progressoGeralProvider =
    Provider<AsyncValue<double>>((Ref ref) {
  return ref.watch(trilhasProvider).whenData((List<Trilha> lista) {
    if (lista.isEmpty) return 0.0;
    final double soma = lista.fold(
      0.0,
      (double acc, Trilha t) => acc + t.progresso,
    );
    return soma / lista.length;
  });
});
```

> **Arquivo:** `foco_estado/lib/telas/trilhas_tab.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/dados/trilhas_fonte.dart';
import 'package:foco_estado/dominio/trilha.dart';
import 'package:foco_estado/estado/trilhas_notifier.dart';

class TrilhasTab extends ConsumerWidget {
  const TrilhasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trilha>> trilhas = ref.watch(trilhasProvider);

    // Falhou MAS ainda há dados: avise sem apagar a lista.
    ref.listen<AsyncValue<List<Trilha>>>(trilhasProvider,
        (AsyncValue<List<Trilha>>? antes, AsyncValue<List<Trilha>> agora) {
      if (agora.hasError && agora.hasValue) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Falha ao sincronizar. Mostrando dados anteriores.'),
          ));
      }
    });

    // Recarregando COM dados: barra fina, nunca esqueleto por cima.
    final bool recarregando = trilhas.isLoading && trilhas.hasValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trilhas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: SizedBox(
            height: 4,
            child: recarregando ? const LinearProgressIndicator() : null,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () => ref.read(trilhasProvider.notifier).recarregar(),

        // switch com pattern matching: permite a cláusula `when` para
        // separar "vazio" de "com itens" sem criar um estado novo.
        child: switch (trilhas) {
          // Primeira carga: ainda não há nada para mostrar.
          AsyncLoading<List<Trilha>>(hasValue: false) =>
            const Center(child: CircularProgressIndicator.adaptive()),

          // Erro SEM dados anteriores: tela de erro inteira.
          AsyncError<List<Trilha>>(:final Object error, hasValue: false) =>
            _TelaErro(erro: error, aoTentarDeNovo: () {
              ref.invalidate(trilhasProvider);
            }),

          // Sucesso com lista vazia. "Vazio" é conteúdo, não estado.
          AsyncValue<List<Trilha>>(value: final List<Trilha> lista)
              when lista != null && lista.isEmpty =>
            const _ListaVazia(),

          // Sucesso com itens — inclui o caso "erro, mas com dados antigos".
          AsyncValue<List<Trilha>>(value: final List<Trilha> lista)
              when lista != null =>
            ListView(
              children: <Widget>[
                for (final Trilha t in lista) _CartaoTrilha(trilha: t),
              ],
            ),

          // Rede de segurança: nunca deveria acontecer.
          _ => const Center(child: CircularProgressIndicator.adaptive()),
        },
      ),
    );
  }
}

class _CartaoTrilha extends ConsumerWidget {
  const _CartaoTrilha({required this.trilha});

  final Trilha trilha;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(trilha.titulo,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (trilha.completa)
                  const Icon(Icons.verified, color: Colors.green),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir trilha',
                  onPressed: () =>
                      ref.read(trilhasProvider.notifier).excluir(trilha.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: trilha.progresso),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final String tema in trilha.temas)
                  FilterChip(
                    label: Text(tema),
                    selected: trilha.concluidos.contains(tema),
                    // A tela muda NA HORA (atualização otimista);
                    // o servidor confirma depois.
                    onSelected: (_) => ref
                        .read(trilhasProvider.notifier)
                        .alternarTema(trilha.id, tema),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TelaErro extends StatelessWidget {
  const _TelaErro({required this.erro, required this.aoTentarDeNovo});

  final Object erro;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    // Exceção própria permite mensagem específica.
    final bool semRede = erro is FalhaDeRede;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: <Widget>[
        Icon(
          semRede ? Icons.cloud_off_outlined : Icons.error_outline,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          semRede ? 'Sem conexão' : 'Algo deu errado',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          semRede
              ? 'Verifique sua internet e tente de novo.'
              : 'Não conseguimos carregar suas trilhas agora.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: aoTentarDeNovo,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar de novo'),
          ),
        ),
      ],
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: const <Widget>[
        Icon(Icons.route_outlined, size: 64),
        SizedBox(height: 16),
        Text('Nenhuma trilha ainda', textAlign: TextAlign.center),
        SizedBox(height: 8),
        Text('Puxe para baixo para recarregar', textAlign: TextAlign.center),
      ],
    );
  }
}
```

Rode e teste:

```powershell
flutter analyze
flutter run -d chrome
```

1. Abra: o indicador aparece por ~0,8 s.
2. Recarregue (`R`) algumas vezes até cair no erro: a tela de erro tem **Tentar de novo**.
3. Com a lista na tela, **puxe para atualizar**: a lista **não some**; uma barra fina aparece.
4. Marque um tema: o chip muda **instantaneamente** (otimista), e o servidor confirma depois.
5. Marque vários rapidamente até uma falha: o chip **volta** ao estado anterior e o `SnackBar` avisa
   — sem a lista sumir.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `AsyncNotifierProvider<TrilhasNotifier, List<Trilha>>` | Mesmos dois tipos do `NotifierProvider`. O `state` é `AsyncValue<List<Trilha>>`. |
| `Future<List<Trilha>> build()` | A única diferença estrutural. Loading, data e error são gerenciados pelo Riverpod. |
| `ref.watch(trilhasFonteProvider)` no `build()` | Dependência declarada. Na [aula 10](10-injecao-de-dependencias.md) você troca a fonte por uma falsa nos testes, sem tocar aqui. |
| `class FalhaDeRede implements Exception` | Exceção **própria**. Permite à tela distinguir "sem rede" de "erro inesperado" e dar mensagens diferentes. |
| `List<Trilha>.unmodifiable(_servidor)` | A fonte devolve cópia imutável: quem chama não mexe no "servidor" por acidente. |
| `AsyncValue.guard(() => ...)` | Roda a função, devolve `AsyncData` ou `AsyncError`. Substitui oito linhas de `try/catch`. |
| `const AsyncLoading<T>().copyWithPrevious(state)` | `isLoading` vira `true` **e** `.value` mantém os dados antigos. A lista não some da tela. |
| `state = AsyncData<List<Trilha>>(otimista)` | **Atualização otimista**: a tela responde instantaneamente; o servidor confirma depois. |
| `if (resultado case AsyncError<Trilha>(:final error, :final stackTrace))` | *If-case* do Dart 3 com desestruturação. Substitui `is` + cast. |
| `AsyncError(...).copyWithPrevious(AsyncData(atual))` | Estado de erro **com** os dados anteriores: a lista continua visível e o `listen` dispara o aviso. |
| `Future<String?> criar(...)` | Mesmo padrão da aula 6: `null` = sucesso, texto = erro. A tela não conhece as regras. |
| `.whenData((lista) => ...)` | Transforma só o caso de sucesso; `loading` e `error` passam direto. A assincronia se propaga pela cascata. |
| `AsyncLoading<List<Trilha>>(hasValue: false)` no padrão | Separa a **primeira** carga (sem dados) da **recarga** (com dados) direto no `switch`. |
| `when lista != null && lista.isEmpty` | Cláusula de guarda: separa vazio de com-itens **sem** criar um estado novo. |
| `ref.invalidate(trilhasProvider)` no botão | Descarta e recarrega. `refresh` devolveria o valor — aqui não precisamos. |
| `physics: const AlwaysScrollableScrollPhysics()` nas telas de erro e vazio | Mantém o `RefreshIndicator` funcionando justamente onde o usuário mais quer tentar de novo. |

---

## ⚠️ Erros comuns

### 1. `.requireValue` sem ter certeza

```dart
final List<Trilha> lista = ref.watch(trilhasProvider).requireValue;   // ❌
```

```text
Bad state: Tried to call `requireValue` on an `AsyncValue` that has no value
```

Funciona nos seus testes manuais e quebra na primeira rede lenta.

**Correção:** `.value ?? <Trilha>[]` ou `.when(...)`.

### 2. Substituir os dados por `AsyncLoading` ao recarregar

```dart
Future<void> recarregar() async {
  state = const AsyncLoading<List<Trilha>>();   // ⚠️ a lista some
  state = await AsyncValue.guard(...);
}
```

O usuário perde a rolagem e vê a tela piscar.

**Correção:** `.copyWithPrevious(state)`.

### 3. Apagar a tela quando a recarga falha

```dart
state = AsyncError<List<Trilha>>(erro, pilha);   // ⚠️ os dados antigos somem
```

O usuário tinha dados válidos e agora não tem nada.

**Correção:** `AsyncError(...).copyWithPrevious(AsyncData(dadosAntigos))` + aviso via `ref.listen`.

### 4. `try/catch` em vez de `guard`

```dart
try {
  state = AsyncData<List<Trilha>>(await fonte.listar());
} catch (e) {
  state = AsyncError<List<Trilha>>(e, StackTrace.current);   // ⚠️ pilha errada
}
```

Além de verboso, `StackTrace.current` aponta para o `catch`, não para onde o erro nasceu.

**Correção:** `AsyncValue.guard`, que preserva a pilha original.

### 5. Esquecer um dos três casos

```dart
materias.when(
  data: (lista) => ListaMaterias(lista),
  error: (e, s) => const Text('erro'),
  // faltou loading ❌
);
```

```text
The named parameter 'loading' is required
```

Bom erro: o compilador impede.

### 6. Tratar lista vazia como estado do `AsyncValue`

```dart
if (trilhas.isLoading) return const Carregando();
if (trilhas.hasError) return const Erro();
if (trilhas.value!.isEmpty) return const Vazio();   // ⚠️ `!` perigoso
```

**Correção:** `switch` com cláusula `when lista.isEmpty`, ou o `if` dentro do `data:` do `.when`.

### 7. `ref.refresh` com retorno ignorado

```dart
onPressed: () => ref.refresh(trilhasProvider),   // ⚠️ lint unused_result
```

**Correção:** `ref.invalidate(trilhasProvider)`.

### 8. Chamar método do notifier durante o carregamento

```dart
Future<void> alternarTema(String id, String tema) async {
  final List<Trilha> atual = state.value!;   // ❌ null se ainda carregando
```

**Correção:** `final List<Trilha>? atual = state.value; if (atual == null) return;`

### 9. Provider derivado que "desembrulha" o `AsyncValue`

```dart
final Provider<int> completasProvider = Provider<int>((Ref ref) {
  return ref.watch(trilhasProvider).value!.length;   // ❌
});
```

**Correção:** `.whenData(...)`, devolvendo `AsyncValue<int>`. A assincronia deve se propagar.

### 10. `AsyncNotifier` para estado que não é assíncrono

```dart
class TemaNotifier extends AsyncNotifier<ThemeMode> { ... }   // ⚠️
```

Se não há `Future` envolvido, você ganhou três estados que nunca acontecem.

**Correção:** `Notifier` (aula 6). Use `AsyncNotifier` quando há **espera de verdade**.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e execute o roteiro de quatro passos. Confirme a diferença entre
"pisca" e "suave".

**Passo 2.** No `TrilhasNotifier.recarregar`, remova o `.copyWithPrevious(state)`. Puxe para
atualizar e descreva a diferença. Depois restaure.

**Passo 3.** Troque `state.value ?? <Trilha>[]` por `state.requireValue` em `criar`. Recarregue a
página e aperte criar **antes** de a lista carregar. Leia o erro. Depois desfaça.

**Passo 4.** Em `alternarTema`, remova o bloco que restaura o estado quando `resultado` é
`AsyncError`. Marque temas rapidamente até uma falha. Descreva o que fica errado na tela.

**Passo 5.** Substitua o `AsyncValue.guard` de `recarregar` por um `try/catch` escrito à mão. Conte
as linhas antes e depois.

**Passo 6.** No `switch` da tela, remova o caso `AsyncLoading(hasValue: false)`. O código ainda
compila? O que acontece na primeira carga?

**Passo 7.** Faça `TrilhasFonte._talvezFalhar` falhar **sempre**. Confirme que a tela de erro
aparece e que **Tentar de novo** funciona. Depois volte a 1 em 4.

**Passo 8.** Acrescente um provider derivado `temasPendentesProvider` que devolve
`AsyncValue<int>` com o total de temas não concluídos. Use `.whenData`.

**Passo 9.** Troque o `switch` da tela pelo `.when` de três casos. Você consegue manter a distinção
entre "vazio" e "com itens"? E entre "primeira carga" e "recarga"? Explique o que se perde.

**Passo 10.** Responda por escrito: por que `alternarTema` faz a atualização **antes** de falar com
o servidor? Em que tipo de operação isso seria uma má ideia?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

Faça os exercícios de **Aplicação** com `AsyncNotifier`, o de **Correção de bugs** com
`requireValue`, e o de **Decisão** sobre atualização otimista.

---

## 🏆 Desafio opcional

Implemente uma **fila de operações offline** no `TrilhasNotifier`.

Requisitos:

- Quando `marcarTema` falha por `FalhaDeRede`, a operação entra numa fila em vez de ser desfeita.
- A tela mostra um indicador de "N alterações pendentes".
- Um método `sincronizar()` tenta enviar a fila inteira, na ordem.
- Operações que falharem de novo **permanecem** na fila.
- Se a mesma trilha/tema for alterada duas vezes na fila, só a última vale.
- A lista na tela sempre reflete o estado **otimista** (com as pendências aplicadas).

Dica: um segundo provider `filaPendenteProvider` com a fila, e um provider derivado que aplica a
fila sobre os dados do servidor antes de entregar à tela.

Depois responda: quantos estados o seu app tem agora, além dos três do `AsyncValue`? Essa pergunta
mostra por que sincronização offline é um assunto próprio — e ele volta no
[Módulo 10, aula 8](../10-persistencia-de-dados/08-cache-e-offline.md).

---

## 📌 Resumo

- **`AsyncValue<T>`** é o `sealed class` de estado do Módulo 06, pronto: `AsyncLoading`,
  `AsyncData(value)` e `AsyncError(error, stackTrace)`.
- **"Vazio" não é um estado** do `AsyncValue`: é `AsyncData` com lista vazia. Vazio é propriedade
  do dado, não da operação.
- **`AsyncNotifier<T>`** é o `Notifier` com `Future<T> build()`. O Riverpod cuida de loading, data
  e error **sem `try/catch`**.
- **`.when(loading:, error:, data:)`** exige os três casos — impossível esquecer um.
- O **`switch` com padrões** permite cláusulas `when`, para separar vazio de com-itens e primeira
  carga de recarga.
- **`.value` é seguro** (`T?`); **`.requireValue` lança** se não houver dados. É a fonte de crash
  número 1.
- **`AsyncValue.guard`** substitui `try/catch` e **preserva a pilha original** do erro.
- **`copyWithPrevious`** mantém os dados antigos visíveis durante a recarga: `isLoading` é `true`
  **e** `.value` continua preenchido.
- Quando a recarga **falha**, use `AsyncError(...).copyWithPrevious(AsyncData(antigos))`: mantenha
  os dados e avise com `ref.listen`.
- `ref.invalidate` descarta e recarrega (`void`); `ref.refresh` faz o mesmo e **devolve** o valor.
- **Atualização otimista**: mude a tela primeiro, confirme depois, e reverta se falhar.
- Providers derivados de `AsyncValue` usam **`.whenData`** e continuam sendo `AsyncValue`.
- Use `AsyncNotifier` só quando há **espera de verdade**. Estado síncrono continua sendo `Notifier`.

---

## ☑️ Checklist de domínio

- [ ] Explico o que é `AsyncValue` e cito os três estados.
- [ ] Digo por que "vazio" não é um estado do `AsyncValue`.
- [ ] Escrevo um `AsyncNotifier` com `Future<T> build()`.
- [ ] Uso `.when` com os três casos e sei quando prefiro o `switch` com padrões.
- [ ] Nunca uso `.requireValue` sem ter certeza absoluta.
- [ ] Uso `AsyncValue.guard` em vez de `try/catch` manual.
- [ ] Recarrego com `copyWithPrevious` para a tela não piscar.
- [ ] Trato "erro depois de sucesso" mantendo os dados e avisando.
- [ ] Escolho entre `invalidate` e `refresh` conscientemente.
- [ ] Implemento atualização otimista com reversão em caso de falha.
- [ ] Meus providers derivados usam `.whenData` e continuam `AsyncValue`.
- [ ] Uso `AsyncNotifier` só onde há assincronia real.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [AsyncValue — riverpod.dev](https://riverpod.dev/docs/essentials/first_request)
- [Handling errors — riverpod.dev](https://riverpod.dev/docs/essentials/side_effects)
- [AsyncNotifier — pub.dev](https://pub.dev/documentation/riverpod/latest/riverpod/AsyncNotifier-class.html)
- [AsyncValue class — pub.dev](https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html)
- [Patterns — dart.dev](https://dart.dev/language/patterns)
- [Asynchronous programming — dart.dev](https://dart.dev/libraries/async/async-await)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Notifier e NotifierProvider](06-notifier-e-notifierprovider.md) | [README](README.md) | [Aula 8 — Family, autoDispose e listen](08-family-autodispose-listen.md) |
