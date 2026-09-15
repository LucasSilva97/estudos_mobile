# Aula 9 — API com Riverpod

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Montar a **cadeia completa de providers**: cliente → service → repositório → controller → tela.
- Escrever um **`AsyncNotifier`** que consome API e trata os quatro estados de UI.
- Usar **`AsyncValue.when`** ligando os estados do Riverpod aos widgets do
  [Módulo 06](../06-widgets-e-layouts/12-estados-de-ui.md).
- Implementar **puxar para atualizar** com `RefreshIndicator` + `ref.invalidate`.
- Usar **`family`** para carregar o detalhe de um item por id, com `autoDispose`.
- Testar a cadeia inteira substituindo **um único** provider.
- Comprovar a promessa do [Módulo 08](../08-estado-e-arquitetura/09-arquitetura-feature-first.md):
  trocar a fonte de dados **sem tocar** na camada de estado.

## ✅ Pré-requisitos

- [Aula 7 — Camada de dados testável](07-camada-de-dados-testavel.md) — service, repositório,
  contrato e `Falha`.
- [Aula 8 — Autenticação e tokens](08-autenticacao-e-tokens.md) — o `clienteAutenticadoProvider`.
- [Módulo 08, aulas 7, 8 e 10](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) —
  `AsyncNotifier`, `AsyncValue`, `family`, `autoDispose` e `overrides`.
- [Módulo 06, aula 12 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) — os widgets
  `Carregando`, `EstadoVazio` e `EstadoErro`.

---

## 📖 Conceito

### A cadeia completa

Tudo que você construiu neste módulo se encaixa assim:

```text
┌──────────────────────────────────────────────────────────────┐
│ presentation                                                 │
│   trilhas_tab.dart ──── ref.watch(trilhasProvider) ────┐     │
│   trilhas_controller.dart (AsyncNotifier)  ◄───────────┘     │
└────────────────────────┬─────────────────────────────────────┘
                         │ ref.watch(trilhaRepositorioProvider)
┌────────────────────────▼─────────────────────────────────────┐
│ data                                                         │
│   TrilhaRepositorio ──── converte DTO→domínio, traduz erros  │
│   TrilhaApi (service) ── monta URL, checa status, decodifica │
│   ClienteAutenticado ─── acrescenta o token, trata 401       │
│   http.Client ────────── a conexão                           │
└──────────────────────────────────────────────────────────────┘
```

Cada camada só conhece **a de baixo**, e sempre pelo **contrato**. Isso é o que permite substituir
qualquer peça sem tocar nas outras.

### Os providers, em ordem

```dart
// 1. A conexão. Um por app, fechado no fim.
final Provider<http.Client> clienteHttpProvider = ...;

// 2. O cliente com token. Aula 8.
final Provider<http.Client> clienteAutenticadoProvider = ...;

// 3. O service. Fala HTTP, devolve DTO.
final Provider<TrilhaApi> trilhaApiProvider = Provider<TrilhaApi>((Ref ref) {
  return TrilhaApi(cliente: ref.watch(clienteAutenticadoProvider));
});

// 4. O repositório, tipado pelo CONTRATO.
final Provider<TrilhaRepositorioContrato> trilhaRepositorioProvider =
    Provider<TrilhaRepositorioContrato>((Ref ref) {
  return TrilhaRepositorio(ref.watch(trilhaApiProvider));
});

// 5. O controller. É o que a tela observa.
final AsyncNotifierProvider<TrilhasController, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider<TrilhasController, List<Trilha>>(TrilhasController.new);
```

A cadeia de `ref.watch` cria o **grafo de dependências**. Substituir o
`trilhaRepositorioProvider` num teste faz o controller — e toda a tela — usar o falso, sem que
nenhuma outra linha mude.

> 📌 Repare que cada provider é declarado **junto da classe que ele cria**, no arquivo daquela
> camada. Uma pasta `providers/` com todos juntos seria organização por tipo — exatamente o que o
> [Módulo 08, aula 9](../08-estado-e-arquitetura/09-arquitetura-feature-first.md) desaconselha.

### Ligando `AsyncValue` aos widgets de estado

No Módulo 06 você escreveu `Carregando`, `EstadoVazio` e `EstadoErro`. Agora eles ganham a fonte:

```dart
final AsyncValue<List<Trilha>> trilhas = ref.watch(trilhasProvider);

return trilhas.when(
  loading: () => const EsqueletoLista(),
  error: (Object erro, StackTrace pilha) => EstadoErro(
    titulo: erro is Falha ? erro.mensagem : 'Algo deu errado',
    onTentarDeNovo: () => ref.invalidate(trilhasProvider),
  ),
  data: (List<Trilha> lista) => lista.isEmpty
      ? const EstadoVazio.inicial(oQue: 'trilha', aoCriar: ...)
      : ListaTrilhas(lista),
);
```

Os quatro estados do Módulo 06 saem de três casos do `AsyncValue` — porque **"vazio" é conteúdo**,
não estado da operação.

E o quinto estado — "recarregando com dados antigos" — vem de graça:

```dart
final bool recarregando = trilhas.isLoading && trilhas.hasValue;
```

### `RefreshIndicator` + `ref.invalidate`

```dart
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(trilhasProvider);
    // Espera a nova carga terminar, senão o indicador some na hora.
    await ref.read(trilhasProvider.future);
  },
  child: ListView(...),
)
```

Duas linhas, duas responsabilidades:

- **`invalidate`** descarta o estado e faz o `build()` rodar de novo.
- **`await ...future`** segura o indicador até a carga terminar.

Sem a segunda, o indicador gira por um quadro e some, enquanto os dados ainda estão vindo.

> ⚠️ `ref.invalidate` **apaga** o estado: a tela volta a `AsyncLoading` **sem** dados. Para
> recarregar mantendo a lista visível, use um método do controller com `copyWithPrevious`, como na
> [aula 7 do Módulo 08](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md). O curso usa
> `invalidate` no botão "tentar de novo" (onde não há dados mesmo) e o método do controller no
> `RefreshIndicator`.

### `family` para o detalhe

A tela de detalhe precisa de **uma** trilha:

```dart
final AutoDisposeFutureProviderFamily<Trilha, String> trilhaPorIdProvider =
    FutureProvider.autoDispose.family<Trilha, String>((Ref ref, String id) {
  return ref.watch(trilhaRepositorioProvider).buscarPorId(id);
});
```

E na tela:

```dart
final AsyncValue<Trilha> trilha = ref.watch(trilhaPorIdProvider(id));
```

**`autoDispose` é obrigatório aqui.** Sem ele, cada trilha visitada deixa um estado na memória para
sempre — e o `family` multiplica isso por item.

> 💡 **`FutureProvider` em vez de `AsyncNotifierProvider`** quando o estado é **só leitura**. Se a
> tela de detalhe também **altera** a trilha, aí sim vale um `AsyncNotifier`.

### O reaproveitamento entre lista e detalhe

Um detalhe de produto que faz diferença: se a lista já foi carregada, a tela de detalhe não precisa
buscar nada.

```dart
final AutoDisposeProviderFamily<Trilha?, String> trilhaDaListaProvider =
    Provider.autoDispose.family<Trilha?, String>((Ref ref, String id) {
  // Tenta encontrar na lista já carregada.
  return ref.watch(trilhasProvider).whenOrNull(
        data: (List<Trilha> lista) =>
            lista.where((Trilha t) => t.id == id).firstOrNull,
      );
});
```

A tela usa isso como **prévia** — exatamente o padrão da
[aula 3 do Módulo 07](../07-navegacao-e-formularios/03-argumentos-e-resultados.md) — e continua
buscando o dado completo em segundo plano.

### Testar a cadeia inteira substituindo uma peça

```dart
final ProviderContainer container = ProviderContainer(
  overrides: <Override>[
    trilhaRepositorioProvider.overrideWithValue(repositorioFalso),
  ],
);
```

**Um** override, e toda a cadeia acima dele passa a usar o falso: controller, providers derivados e
tela. Nada de HTTP, nada de rede, nada de emulador.

E se você quiser testar o repositório **de verdade** com HTTP falso, substitua mais embaixo:

```dart
overrides: <Override>[
  clienteHttpProvider.overrideWithValue(MockClient(...)),
],
```

Agora o service, o repositório e o controller são os **reais** — só a conexão é falsa. É o teste
mais próximo do comportamento em produção que se consegue sem rede.

| Onde substituir | O que fica real | Use para |
|---|---|---|
| `clienteHttpProvider` | Service, repositório, controller | Teste de integração da feature |
| `trilhaApiProvider` | Repositório, controller | Testar conversão e tradução de erro |
| `trilhaRepositorioProvider` | Controller | Testar estados da tela |

---

## 💡 Analogia

Pense numa linha de montagem de uma fábrica.

- **O `http.Client`** é a **esteira** que traz a matéria-prima de fora.
- **O `service`** é o **setor de recebimento**: confere a nota fiscal, o lacre, o código. Rejeita o
  que veio errado.
- **O `repositório`** é o **setor de preparo**: desembala, converte as medidas para o padrão da
  casa, descarta o que não serve.
- **O `controller`** é a **linha de produção**: transforma a matéria-prima preparada no produto que
  a loja vende — e sabe dizer se está "produzindo", "pronto" ou "deu problema".
- **A tela** é a **vitrine**: só mostra. Ela não sabe de onde veio nada.
- **A cadeia de `ref.watch`** é o **fluxo da esteira**: cada setor puxa do anterior, e nenhum
  precisa saber o que vem antes do seu fornecedor direto.
- **Substituir um provider** é **desviar a esteira** num ponto. Desviar no recebimento testa a
  fábrica inteira com matéria-prima controlada. Desviar no preparo testa só a produção. O produto
  final sai igual nos dois casos — e é por isso que você pode testar em níveis diferentes sem
  mudar o resto.
- **`autoDispose` no detalhe** é desmontar a bancada de um pedido especial quando ele termina. Sem
  isso, cada pedido especial já feito continua ocupando espaço no chão de fábrica.

---

## 🧪 Exemplo mínimo

A cadeia inteira em um arquivo, para você ver o encaixe.

> **Arquivo:** `foco_api/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// ═══ 1. A conexão ═════════════════════════════════════════════════════════
final Provider<http.Client> clienteProvider = Provider<http.Client>((Ref ref) {
  final http.Client c = http.Client();
  ref.onDispose(c.close);
  return c;
});

// ═══ 2. Domínio ═══════════════════════════════════════════════════════════
class Tarefa {
  const Tarefa({required this.id, required this.titulo, required this.feita});

  final String id;
  final String titulo;
  final bool feita;
}

sealed class Falha implements Exception {
  const Falha(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

final class SemConexao extends Falha {
  const SemConexao() : super('Sem conexão. Verifique sua internet.');
}

final class ServidorComProblema extends Falha {
  const ServidorComProblema()
      : super('O servidor está com problema. Tente mais tarde.');
}

abstract interface class TarefaRepositorio {
  Future<List<Tarefa>> listar();
}

// ═══ 3. Service (fala HTTP) ═══════════════════════════════════════════════
class TarefaApi {
  const TarefaApi(this._cliente);
  final http.Client _cliente;

  Future<List<Map<String, Object?>>> listar() async {
    final http.Response r = await _cliente
        .get(Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=8'))
        .timeout(const Duration(seconds: 15));

    if (r.statusCode != 200) throw _StatusRuim(r.statusCode);

    return (jsonDecode(r.body) as List<Object?>)
        .cast<Map<String, Object?>>();
  }
}

class _StatusRuim implements Exception {
  const _StatusRuim(this.status);
  final int status;
}

final Provider<TarefaApi> tarefaApiProvider = Provider<TarefaApi>((Ref ref) {
  return TarefaApi(ref.watch(clienteProvider));
});

// ═══ 4. Repositório (fala domínio) ════════════════════════════════════════
class TarefaRepositorioHttp implements TarefaRepositorio {
  const TarefaRepositorioHttp(this._api);
  final TarefaApi _api;

  @override
  Future<List<Tarefa>> listar() async {
    try {
      final List<Map<String, Object?>> bruto = await _api.listar();
      return bruto
          .map((Map<String, Object?> j) => Tarefa(
                id: '${j['id']}',
                titulo: j['title']! as String,
                feita: j['completed'] == true,
              ))
          .toList();
    } on _StatusRuim catch (e) {
      throw e.status >= 500
          ? const ServidorComProblema()
          : const SemConexao();
    } on Object {
      // Rede, timeout, JSON quebrado: tudo vira Falha de domínio.
      throw const SemConexao();
    }
  }
}

/// Tipado pelo CONTRATO. É isto que permite substituí-lo nos testes.
final Provider<TarefaRepositorio> tarefaRepositorioProvider =
    Provider<TarefaRepositorio>((Ref ref) {
  return TarefaRepositorioHttp(ref.watch(tarefaApiProvider));
});

// ═══ 5. Controller (estado da tela) ═══════════════════════════════════════
final AsyncNotifierProvider<TarefasController, List<Tarefa>> tarefasProvider =
    AsyncNotifierProvider<TarefasController, List<Tarefa>>(
        TarefasController.new);

class TarefasController extends AsyncNotifier<List<Tarefa>> {
  @override
  Future<List<Tarefa>> build() =>
      ref.watch(tarefaRepositorioProvider).listar();

  /// Recarga que MANTÉM os dados na tela. Diferente de ref.invalidate,
  /// que apaga e volta a AsyncLoading sem dados.
  Future<void> recarregar() async {
    state = const AsyncLoading<List<Tarefa>>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(tarefaRepositorioProvider).listar(),
    );
  }
}

/// Derivado: a assincronia se propaga com whenData.
final Provider<AsyncValue<int>> pendentesProvider =
    Provider<AsyncValue<int>>((Ref ref) {
  return ref.watch(tarefasProvider).whenData(
        (List<Tarefa> l) => l.where((Tarefa t) => !t.feita).length,
      );
});

// ═══ 6. Tela ══════════════════════════════════════════════════════════════
void main() => runApp(const ProviderScope(child: AppCadeia()));

class AppCadeia extends StatelessWidget {
  const AppCadeia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaTarefas(),
    );
  }
}

class TelaTarefas extends ConsumerWidget {
  const TelaTarefas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tarefa>> tarefas = ref.watch(tarefasProvider);
    final AsyncValue<int> pendentes = ref.watch(pendentesProvider);

    // Recarregando COM dados: barra fina, não esqueleto por cima.
    final bool recarregando = tarefas.isLoading && tarefas.hasValue;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas · ${pendentes.value ?? 0} pendentes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: SizedBox(
            height: 4,
            child: recarregando ? const LinearProgressIndicator() : null,
          ),
        ),
      ),
      body: RefreshIndicator(
        // Método do controller: mantém a lista visível durante a recarga.
        onRefresh: () => ref.read(tarefasProvider.notifier).recarregar(),

        child: tarefas.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),

          error: (Object erro, StackTrace pilha) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            children: <Widget>[
              const Icon(Icons.cloud_off_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                // A Falha já traz mensagem pronta para o usuário.
                erro is Falha ? erro.mensagem : 'Algo deu errado',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Center(
                child: FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar de novo'),
                  // invalidate: não há dados para preservar mesmo.
                  onPressed: () => ref.invalidate(tarefasProvider),
                ),
              ),
            ],
          ),

          data: (List<Tarefa> lista) {
            // "Vazio" é CONTEÚDO do sucesso, não um estado do AsyncValue.
            if (lista.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const <Widget>[
                  SizedBox(height: 120),
                  Center(child: Text('Nenhuma tarefa')),
                ],
              );
            }

            return ListView.builder(
              itemCount: lista.length,
              itemBuilder: (BuildContext c, int i) => CheckboxListTile(
                value: lista[i].feita,
                onChanged: null,
                title: Text(lista[i].titulo),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

**O que observar:** seis blocos, cada um com uma responsabilidade, ligados por `ref.watch`. A tela
não sabe que existe HTTP; o service não sabe que existe tela.

---

## 📱 Aplicando no Flutter

Agora a aba de Trilhas do `foco_api`, completa: lista, detalhe, criação, edição, exclusão — tudo
com API real, os quatro estados e testes.

---

## 💻 Código completo

> **Arquivo:** `foco_api/lib/features/trilhas/presentation/trilhas_controller.dart` (final)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/features/trilhas/data/trilha_repositorio.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';

/// Controller da lista de trilhas.
///
/// Note o que ele NÃO tem: nenhum import de `http`, nenhum `jsonDecode`,
/// nenhum status HTTP. Ele conhece apenas o contrato do repositório e
/// as Falhas de domínio.
///
/// É isso que torna verdadeira a promessa do Módulo 08: quando o
/// Módulo 10 trocar HTTP por SQLite, este arquivo não muda.
final AsyncNotifierProvider<TrilhasController, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider<TrilhasController, List<Trilha>>(
        TrilhasController.new);

class TrilhasController extends AsyncNotifier<List<Trilha>> {
  @override
  Future<List<Trilha>> build() {
    // watch (não read): se o repositório for substituído — por um
    // override em teste, por exemplo —, este controller é recriado.
    return ref.watch(trilhaRepositorioProvider).listar();
  }

  // ── Recarga ───────────────────────────────────────────────────────────────

  /// Recarrega mantendo a lista visível.
  ///
  /// Diferente de `ref.invalidate(trilhasProvider)`, que apaga o estado
  /// e volta a AsyncLoading SEM dados — fazendo a tela piscar e o
  /// usuário perder a rolagem.
  Future<void> recarregar() async {
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(trilhaRepositorioProvider).listar(),
    );
  }

  // ── Escrita ───────────────────────────────────────────────────────────────

  /// Cria. Devolve null em caso de sucesso, ou a mensagem de erro.
  ///
  /// NÃO é otimista: o id vem do servidor, e um item com id inventado
  /// quebraria no primeiro toque. Aula 5.
  Future<String?> criar(String titulo, String descricao) async {
    final String limpo = titulo.trim();
    if (limpo.length < 3) return 'O título precisa ter pelo menos 3 letras';

    final List<Trilha> atual = state.value ?? <Trilha>[];
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);

    try {
      final Trilha criada = await ref
          .read(trilhaRepositorioProvider)
          .criar(Trilha(id: '', titulo: limpo, descricao: descricao));

      state = AsyncData<List<Trilha>>(<Trilha>[criada, ...atual]);
      return null;
    } on Falha catch (falha, pilha) {
      // Erro SEM apagar a lista: o usuário mantém o que já tinha.
      state = AsyncError<List<Trilha>>(falha, pilha)
          .copyWithPrevious(AsyncData<List<Trilha>>(atual));
      return falha.mensagem;
    }
  }

  /// Marca/desmarca um tema.
  ///
  /// OTIMISTA: reversível e sem consequência. A tela responde na hora.
  Future<String?> alternarTema(String trilhaId, String tema) async {
    final List<Trilha>? antes = state.value;
    if (antes == null) return null;

    final int i = antes.indexWhere((Trilha t) => t.id == trilhaId);
    if (i == -1) return null;

    final Set<String> novos = <String>{...antes[i].concluidos};
    if (!novos.remove(tema)) novos.add(tema);

    // 1. Aplica localmente, agora.
    state = AsyncData<List<Trilha>>(<Trilha>[
      for (final Trilha t in antes)
        if (t.id == trilhaId) t.copyWith(concluidos: novos) else t,
    ]);

    try {
      // 2. Confirma no servidor.
      await ref
          .read(trilhaRepositorioProvider)
          .alterarConcluidos(trilhaId, novos);

      // 3. O detalhe daquela trilha, se estiver aberto, precisa saber.
      ref.invalidate(trilhaPorIdProvider(trilhaId));
      return null;
    } on Falha catch (falha) {
      // 4. Falhou: reverte.
      state = AsyncData<List<Trilha>>(antes);
      return falha.mensagem;
    }
  }

  /// Exclui. OTIMISTA com reversão.
  Future<String?> excluir(String id) async {
    final List<Trilha>? antes = state.value;
    if (antes == null) return null;

    state = AsyncData<List<Trilha>>(
      antes.where((Trilha t) => t.id != id).toList(),
    );

    try {
      await ref.read(trilhaRepositorioProvider).excluir(id);
      return null;
    } on Falha catch (falha) {
      state = AsyncData<List<Trilha>>(antes);
      return falha.mensagem;
    }
  }
}

/// ── Providers derivados ──────────────────────────────────────────────────
/// Derivados de AsyncValue continuam AsyncValue: a assincronia se propaga
/// pela cascata sem você tratar nada.

final Provider<AsyncValue<int>> totalDeTrilhasProvider =
    Provider<AsyncValue<int>>((Ref ref) {
  return ref.watch(trilhasProvider).whenData((List<Trilha> l) => l.length);
});

final Provider<AsyncValue<double>> progressoGeralProvider =
    Provider<AsyncValue<double>>((Ref ref) {
  return ref.watch(trilhasProvider).whenData((List<Trilha> lista) {
    if (lista.isEmpty) return 0;
    final double soma =
        lista.fold(0, (double acc, Trilha t) => acc + t.progresso);
    return soma / lista.length;
  });
});

/// ── Detalhe por id ───────────────────────────────────────────────────────

/// FutureProvider (não AsyncNotifier) porque o detalhe é SÓ LEITURA:
/// quem altera é o controller da lista.
///
/// autoDispose é OBRIGATÓRIO com family: sem ele, cada trilha visitada
/// deixaria um estado na memória para sempre.
final AutoDisposeFutureProviderFamily<Trilha, String> trilhaPorIdProvider =
    FutureProvider.autoDispose.family<Trilha, String>((Ref ref, String id) {
  return ref.watch(trilhaRepositorioProvider).buscarPorId(id);
});

/// Prévia vinda da lista já carregada.
///
/// Evita a tela de detalhe piscar: ela desenha com o que a lista já
/// sabia, enquanto o dado completo chega. Padrão da aula 3 do Módulo 07.
final AutoDisposeProviderFamily<Trilha?, String> previaDaTrilhaProvider =
    Provider.autoDispose.family<Trilha?, String>((Ref ref, String id) {
  return ref.watch(trilhasProvider).whenOrNull(
        data: (List<Trilha> lista) =>
            lista.where((Trilha t) => t.id == id).firstOrNull,
      );
});
```

> **Arquivo:** `foco_api/lib/features/trilhas/presentation/trilhas_tab.dart` (final)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/core/widgets/carregando.dart';
import 'package:foco_api/core/widgets/estado_erro.dart';
import 'package:foco_api/core/widgets/estado_vazio.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';
import 'package:foco_api/features/trilhas/presentation/trilhas_controller.dart';
import 'package:foco_api/features/trilhas/presentation/widgets/cartao_trilha.dart';

class TrilhasTab extends ConsumerWidget {
  const TrilhasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trilha>> trilhas = ref.watch(trilhasProvider);
    final AsyncValue<double> progresso = ref.watch(progressoGeralProvider);

    // Falhou MAS ainda há dados: avise sem apagar a tela.
    ref.listen<AsyncValue<List<Trilha>>>(trilhasProvider,
        (AsyncValue<List<Trilha>>? antes, AsyncValue<List<Trilha>> agora) {
      if (agora.hasError && agora.hasValue) {
        final Object? erro = agora.error;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(
              erro is Falha
                  ? '${erro.mensagem} Mostrando dados anteriores.'
                  : 'Falha ao sincronizar. Mostrando dados anteriores.',
            ),
          ));
      }
    });

    // Quinto estado: recarregando COM dados. Barra fina, não esqueleto.
    final bool recarregando = trilhas.isLoading && trilhas.hasValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trilhas'),
        actions: <Widget>[
          if (progresso.hasValue)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text('${(progresso.value! * 100).round()}%'),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: RecarregandoBarra(visivel: recarregando),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova trilha',
        onPressed: () => _abrirFormulario(context, ref),
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        // Método do controller, não invalidate: mantém a lista visível.
        onRefresh: () => ref.read(trilhasProvider.notifier).recarregar(),

        // Os TRÊS casos do AsyncValue viram os QUATRO estados do
        // Módulo 06 — porque "vazio" é conteúdo do sucesso.
        child: trilhas.when(
          // Primeira carga: esqueleto no formato da lista que vem.
          loading: () => const EsqueletoLista(linhas: 5),

          error: (Object erro, StackTrace pilha) {
            // A Falha já traz mensagem pronta e sabe se vale repetir.
            final Falha? falha = erro is Falha ? erro : null;
            return EstadoErro(
              titulo: falha is FalhaDeConexao ? 'Sem conexão' : 'Algo deu errado',
              mensagem: falha?.mensagem ?? 'Não conseguimos carregar as trilhas.',
              detalheTecnico: '$erro',
              onTentarDeNovo: () => ref.invalidate(trilhasProvider),
            );
          },

          data: (List<Trilha> lista) {
            if (lista.isEmpty) {
              return EstadoVazio.inicial(
                oQue: 'trilha',
                aoCriar: () => _abrirFormulario(context, ref),
                rotuloCriar: 'Criar trilha',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: lista.length,
              itemBuilder: (BuildContext c, int i) => CartaoTrilha(
                trilha: lista[i],
                onAlternarTema: (String tema) =>
                    _alternar(context, ref, lista[i].id, tema),
                onExcluir: () => _excluir(context, ref, lista[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Ações ─────────────────────────────────────────────────────────────────

  Future<void> _alternar(
    BuildContext context,
    WidgetRef ref,
    String trilhaId,
    String tema,
  ) async {
    final String? erro =
        await ref.read(trilhasProvider.notifier).alternarTema(trilhaId, tema);

    if (!context.mounted || erro == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(erro)));
  }

  Future<void> _excluir(
    BuildContext context,
    WidgetRef ref,
    Trilha trilha,
  ) async {
    final String? erro =
        await ref.read(trilhasProvider.notifier).excluir(trilha.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(erro ?? '"${trilha.titulo}" excluída'),
        action: erro != null
            ? null
            : SnackBarAction(
                label: 'Desfazer',
                onPressed: () => ref
                    .read(trilhasProvider.notifier)
                    .criar(trilha.titulo, trilha.descricao),
              ),
      ));
  }

  Future<void> _abrirFormulario(BuildContext context, WidgetRef ref) async {
    final TextEditingController titulo = TextEditingController();
    final TextEditingController descricao = TextEditingController();

    final bool? confirmou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext c) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.viewInsetsOf(c).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Nova trilha', style: Theme.of(c).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: titulo,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título',
                helperText: 'Pelo menos 3 letras',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descricao,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Temas',
                helperText: 'Um por linha',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );

    final String t = titulo.text;
    final String d = descricao.text;
    titulo.dispose();
    descricao.dispose();

    if (confirmou != true || !context.mounted) return;

    final String? erro = await ref.read(trilhasProvider.notifier).criar(t, d);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(erro ?? 'Trilha criada')));
  }
}
```

> **Arquivo:** `foco_api/lib/features/trilhas/presentation/detalhe_trilha_screen.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';
import 'package:foco_api/features/trilhas/presentation/trilhas_controller.dart';

class DetalheTrilhaScreen extends ConsumerWidget {
  const DetalheTrilhaScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prévia: o que a lista já sabia. Evita a tela piscar enquanto
    // o dado completo chega.
    final Trilha? previa = ref.watch(previaDaTrilhaProvider(id));

    // O dado completo, buscado por id. autoDispose garante que sai
    // da memória quando o usuário volta.
    final AsyncValue<Trilha> completa = ref.watch(trilhaPorIdProvider(id));

    // O que mostrar: o completo quando chegar, a prévia enquanto isso.
    final Trilha? trilha = completa.value ?? previa;

    return Scaffold(
      appBar: AppBar(
        title: Text(trilha?.titulo ?? 'Carregando…'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: SizedBox(
            height: 4,
            // Atualizando COM prévia na tela: barra fina.
            child: completa.isLoading && trilha != null
                ? const LinearProgressIndicator()
                : null,
          ),
        ),
      ),

      body: switch ((trilha, completa)) {
        // Nada para mostrar e ainda carregando.
        (null, AsyncLoading<Trilha>()) =>
          const Center(child: CircularProgressIndicator.adaptive()),

        // Nada para mostrar e deu erro.
        (null, AsyncError<Trilha>(:final Object error)) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                Text(error is Falha ? error.mensagem : 'Algo deu errado'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar de novo'),
                  onPressed: () => ref.invalidate(trilhaPorIdProvider(id)),
                ),
              ],
            ),
          ),

        // Há o que mostrar: prévia ou dado completo.
        (final Trilha t, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              Text(t.descricao,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: t.progresso, minHeight: 8),
              const SizedBox(height: 8),
              Text('${t.concluidos.length} de ${t.temas.length} temas'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final String tema in t.temas)
                    FilterChip(
                      label: Text(tema),
                      selected: t.concluidos.contains(tema),
                      // Altera pelo controller DA LISTA: uma fonte de
                      // verdade só. O detalhe é somente leitura.
                      onSelected: (_) => ref
                          .read(trilhasProvider.notifier)
                          .alternarTema(t.id, tema),
                    ),
                ],
              ),
            ],
          ),

        _ => const SizedBox.shrink(),
      },
    );
  }
}
```

---

## 💻 Os testes

> **Arquivo:** `foco_api/test/trilhas/trilhas_controller_test.dart` (novo)
> **Como executar:** `flutter test`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/features/trilhas/data/trilha_repositorio.dart'
    show trilhaRepositorioProvider;
import 'package:foco_api/features/trilhas/domain/trilha.dart';
import 'package:foco_api/features/trilhas/domain/trilha_repositorio_contrato.dart';
import 'package:foco_api/features/trilhas/presentation/trilhas_controller.dart';

/// Repositório falso: implementa o CONTRATO, sem HTTP nenhum.
class TrilhaRepositorioFalso implements TrilhaRepositorioContrato {
  TrilhaRepositorioFalso([List<Trilha>? iniciais])
      : _trilhas = <Trilha>[...?iniciais];

  final List<Trilha> _trilhas;

  /// Controle do teste.
  Falha? falhaForcada;
  int chamadasDeListar = 0;

  void _talvezFalhar() {
    final Falha? f = falhaForcada;
    if (f != null) throw f;
  }

  @override
  Future<List<Trilha>> listar() async {
    chamadasDeListar++;
    _talvezFalhar();
    return List<Trilha>.unmodifiable(_trilhas);
  }

  @override
  Future<Trilha> buscarPorId(String id) async {
    _talvezFalhar();
    final int i = _trilhas.indexWhere((Trilha t) => t.id == id);
    if (i == -1) throw const FalhaNaoEncontrado();
    return _trilhas[i];
  }

  @override
  Future<List<Trilha>> buscar(String termo) async {
    _talvezFalhar();
    return _trilhas
        .where((Trilha t) =>
            t.titulo.toLowerCase().contains(termo.toLowerCase()))
        .toList();
  }

  @override
  Future<Trilha> criar(Trilha nova) async {
    _talvezFalhar();
    // O id vem do "servidor", como numa API real.
    final Trilha criada =
        nova.copyWith(id: 'srv_${_trilhas.length + 1}');
    _trilhas.add(criada);
    return criada;
  }

  @override
  Future<Trilha> alterarConcluidos(String id, Set<String> concluidos) async {
    _talvezFalhar();
    final int i = _trilhas.indexWhere((Trilha t) => t.id == id);
    if (i == -1) throw const FalhaNaoEncontrado();
    final Trilha nova = _trilhas[i].copyWith(concluidos: concluidos);
    _trilhas[i] = nova;
    return nova;
  }

  @override
  Future<void> excluir(String id) async {
    _talvezFalhar();
    _trilhas.removeWhere((Trilha t) => t.id == id);
  }
}

void main() {
  late TrilhaRepositorioFalso repo;
  late ProviderContainer container;

  /// UM override substitui a cadeia inteira acima do repositório.
  /// O controller, os providers derivados e a tela passam a usar o falso.
  ProviderContainer montar({List<Trilha>? iniciais}) {
    repo = TrilhaRepositorioFalso(iniciais ??
        <Trilha>[
          const Trilha(
            id: '1',
            titulo: 'Dart',
            descricao: 'Variáveis\nFunções',
            temas: <String>['Variáveis', 'Funções'],
            concluidos: <String>{'Variáveis'},
          ),
          const Trilha(
            id: '2',
            titulo: 'Flutter',
            descricao: 'Widgets',
            temas: <String>['Widgets'],
          ),
        ]);

    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[
        trilhaRepositorioProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('carga inicial', () {
    test('começa em AsyncLoading', () {
      container = montar();
      expect(container.read(trilhasProvider),
          isA<AsyncLoading<List<Trilha>>>());
    });

    test('termina em AsyncData com a lista', () async {
      container = montar();
      final List<Trilha> lista =
          await container.read(trilhasProvider.future);

      expect(lista.length, 2);
      expect(repo.chamadasDeListar, 1);
    });

    test('falha vira AsyncError com a Falha de domínio', () async {
      container = montar();
      repo.falhaForcada = const FalhaDeConexao();
      container.invalidate(trilhasProvider);

      await expectLater(
        container.read(trilhasProvider.future),
        throwsA(isA<FalhaDeConexao>()),
      );
    });
  });

  group('providers derivados', () {
    test('total acompanha a lista', () async {
      container = montar();
      await container.read(trilhasProvider.future);

      expect(container.read(totalDeTrilhasProvider).value, 2);
    });

    test('progresso geral é a média das trilhas', () async {
      container = montar();
      await container.read(trilhasProvider.future);

      // Trilha 1: 1 de 2 = 0.5 · Trilha 2: 0 de 1 = 0.0 · média = 0.25
      expect(container.read(progressoGeralProvider).value, 0.25);
    });

    test('derivado propaga o erro sem tratar', () async {
      container = montar();
      repo.falhaForcada = const FalhaDoServidor();
      container.invalidate(trilhasProvider);

      await expectLater(
        container.read(trilhasProvider.future),
        throwsA(isA<FalhaDoServidor>()),
      );
      expect(container.read(totalDeTrilhasProvider).hasError, isTrue);
    });
  });

  group('criar', () {
    test('recusa título curto sem chamar o repositório', () async {
      container = montar();
      await container.read(trilhasProvider.future);
      final int antes = repo.chamadasDeListar;

      final String? erro =
          await container.read(trilhasProvider.notifier).criar('ab', '');

      expect(erro, contains('3 letras'));
      expect(repo.chamadasDeListar, antes); // não tocou no repositório
    });

    test('acrescenta a trilha com o id do servidor', () async {
      container = montar();
      await container.read(trilhasProvider.future);

      final String? erro = await container
          .read(trilhasProvider.notifier)
          .criar('Testes', 'Unitários');

      expect(erro, isNull);
      final List<Trilha> lista = container.read(trilhasProvider).requireValue;
      expect(lista.length, 3);
      // O id veio do "servidor", não foi inventado localmente.
      expect(lista.first.id, startsWith('srv_'));
    });

    test('erro mantém a lista anterior na tela', () async {
      container = montar();
      await container.read(trilhasProvider.future);

      repo.falhaForcada = const FalhaDoServidor();
      final String? erro = await container
          .read(trilhasProvider.notifier)
          .criar('Testes', 'x');

      expect(erro, isNotNull);
      final AsyncValue<List<Trilha>> estado = container.read(trilhasProvider);
      expect(estado.hasError, isTrue);
      // O ponto: os dados antigos continuam disponíveis.
      expect(estado.hasValue, isTrue);
      expect(estado.value!.length, 2);
    });
  });

  group('alternarTema (otimista)', () {
    test('marca o tema e confirma', () async {
      container = montar();
      await container.read(trilhasProvider.future);

      final String? erro = await container
          .read(trilhasProvider.notifier)
          .alternarTema('1', 'Funções');

      expect(erro, isNull);
      final Trilha t = container
          .read(trilhasProvider)
          .requireValue
          .firstWhere((Trilha t) => t.id == '1');
      expect(t.concluidos, containsAll(<String>['Variáveis', 'Funções']));
    });

    test('reverte quando o servidor recusa', () async {
      container = montar();
      await container.read(trilhasProvider.future);

      repo.falhaForcada = const FalhaDeConexao();
      final String? erro = await container
          .read(trilhasProvider.notifier)
          .alternarTema('1', 'Funções');

      expect(erro, isNotNull);
      // O estado voltou ao anterior: "Funções" NÃO está marcado.
      final Trilha t = container
          .read(trilhasProvider)
          .requireValue
          .firstWhere((Trilha t) => t.id == '1');
      expect(t.concluidos, <String>{'Variáveis'});
    });
  });

  group('excluir (otimista)', () {
    test('remove da lista', () async {
      container = montar();
      await container.read(trilhasProvider.future);

      await container.read(trilhasProvider.notifier).excluir('1');

      expect(container.read(trilhasProvider).requireValue.length, 1);
    });

    test('reverte quando falha', () async {
      container = montar();
      await container.read(trilhasProvider.future);

      repo.falhaForcada = const FalhaDoServidor();
      final String? erro =
          await container.read(trilhasProvider.notifier).excluir('1');

      expect(erro, isNotNull);
      // O item voltou para a lista.
      expect(container.read(trilhasProvider).requireValue.length, 2);
    });
  });

  group('detalhe por id', () {
    test('busca a trilha', () async {
      container = montar();
      final Trilha t = await container.read(trilhaPorIdProvider('1').future);
      expect(t.titulo, 'Dart');
    });

    test('id inexistente vira FalhaNaoEncontrado', () async {
      container = montar();
      await expectLater(
        container.read(trilhaPorIdProvider('999').future),
        throwsA(isA<FalhaNaoEncontrado>()),
      );
    });

    test('a prévia vem da lista, sem nova busca', () async {
      container = montar();
      await container.read(trilhasProvider.future);
      final int antes = repo.chamadasDeListar;

      final Trilha? previa = container.read(previaDaTrilhaProvider('1'));

      expect(previa?.titulo, 'Dart');
      // Nenhuma chamada nova: veio da lista já carregada.
      expect(repo.chamadasDeListar, antes);
    });
  });
}
```

Rode tudo:

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

Confirme na tela:

1. A lista carrega com esqueleto e depois mostra as trilhas.
2. Puxe para atualizar: a lista **não some**, a barra fina aparece.
3. Marque um tema: muda **instantaneamente**.
4. Desligue a internet e marque outro: o chip **volta** e a mensagem aparece.
5. Crie uma trilha: ela aparece no topo, com o id do servidor.
6. Exclua: some na hora, com **Desfazer**.
7. Abra o detalhe: o título aparece **imediatamente** (prévia) e o resto chega depois.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `ref.watch(trilhaRepositorioProvider)` no `build()` | `watch`, não `read`: um override em teste recria o controller. |
| Controller **sem** import de `http` | A prova de que a arquitetura funciona. Quando o Módulo 10 trocar HTTP por SQLite, este arquivo não muda. |
| `recarregar()` com `copyWithPrevious` × `ref.invalidate` | `invalidate` apaga o estado (bom no "tentar de novo"); `copyWithPrevious` mantém a lista (bom no puxar-para-atualizar). |
| `criar` **não** otimista | O id vem do servidor; item com id inventado quebraria no primeiro toque. |
| `alternarTema` e `excluir` otimistas | Reversíveis e sem consequência: a tela responde na hora. |
| `state = AsyncData(antes)` no `catch` | A reversão. Sem ela, a tela mostraria algo que o servidor recusou. |
| `ref.invalidate(trilhaPorIdProvider(trilhaId))` após alterar | O detalhe daquela trilha, se aberto, precisa saber. Invalida **uma** instância da family. |
| `.whenData((l) => ...)` nos derivados | A assincronia se propaga: o derivado continua `AsyncValue`. |
| `FutureProvider.autoDispose.family` no detalhe | `FutureProvider` porque é só leitura; `autoDispose` porque family sem ele acumula. |
| `previaDaTrilhaProvider` com `whenOrNull` | Reaproveita a lista já carregada: zero requisições, e a tela não pisca. |
| `completa.value ?? previa` | Dado completo quando chega; prévia enquanto isso. |
| `switch ((trilha, completa))` | *Pattern matching* sobre um **record** de dois valores: cobre "sem dado + carregando", "sem dado + erro" e "com dado". |
| `RecarregandoBarra(visivel: recarregando)` | O widget do Módulo 06, alimentado por `isLoading && hasValue`. |
| `EstadoErro(... onTentarDeNovo: () => ref.invalidate(...))` | O widget do Módulo 06 ligado ao Riverpod. |
| `erro is Falha ? erro.mensagem : ...` | A `Falha` já traz mensagem de usuário. Nunca `erro.toString()` cru. |
| `TrilhaRepositorioFalso implements TrilhaRepositorioContrato` | Implementa o **contrato**, sem HTTP. Um override substitui a cadeia inteira. |
| `expect(repo.chamadasDeListar, antes)` | Prova que a validação de título é **local**: nem tocou no repositório. |
| `expect(estado.hasError && estado.hasValue, isTrue)` | Verifica "erro sem apagar os dados". |

---

## ⚠️ Erros comuns

### 1. Controller importando `http`

```dart
// presentation/trilhas_controller.dart
import 'package:http/http.dart' as http;   // ❌
```

A camada de dados vazou para a apresentação.

**Correção:** o controller só conhece o contrato do repositório.

### 2. `ref.invalidate` no `RefreshIndicator`

```dart
onRefresh: () async => ref.invalidate(trilhasProvider),   // ⚠️
```

Dois problemas: a lista **some** (volta a `AsyncLoading` sem dados) e o indicador desaparece antes
de a carga terminar.

**Correção:** método do controller com `copyWithPrevious`; ou, se usar `invalidate`, faça
`await ref.read(provider.future)` depois.

### 3. `family` sem `autoDispose`

```dart
final FutureProviderFamily<Trilha, String> p = FutureProvider.family(...);   // ⚠️
```

Cada trilha visitada deixa um estado na memória para sempre.

**Correção:** `FutureProvider.autoDispose.family`.

### 4. `erro.toString()` na tela

```dart
error: (Object e, StackTrace s) => Text('$e'),   // ❌
```

O usuário vê `SocketException: Failed host lookup: 'api.exemplo.com'`.

**Correção:** `e is Falha ? e.mensagem : 'Algo deu errado'`.

### 5. `requireValue` no `build` da tela

```dart
final List<Trilha> lista = ref.watch(trilhasProvider).requireValue;   // ❌
```

Quebra na primeira carga.

**Correção:** `.when` ou `.value ?? []`.

### 6. Duas fontes de verdade para o mesmo dado

```dart
// o detalhe altera por conta própria…
ref.read(trilhaPorIdProvider(id).notifier).alternar(tema);   // ⚠️
// …e a lista não fica sabendo
```

A lista e o detalhe divergem.

**Correção:** uma fonte só. O detalhe **lê**; quem altera é o controller da lista — e ele invalida o
detalhe depois.

### 7. Esquecer de invalidar o detalhe após alterar

O usuário marca um tema na lista, abre o detalhe e vê o estado antigo.

**Correção:** `ref.invalidate(trilhaPorIdProvider(id))` depois da alteração.

### 8. Providers todos num arquivo `providers.dart`

Organização por tipo, exatamente o que o Módulo 08 desaconselha.

**Correção:** cada provider junto da classe que ele cria.

### 9. Tela vazia tratada como erro

```dart
if (lista.isEmpty) return const EstadoErro(...);   // ❌
```

Lista vazia é **sucesso**.

**Correção:** `EstadoVazio` dentro do `data:`.

### 10. Substituir o provider errado no teste

```dart
overrides: [trilhaApiProvider.overrideWithValue(apiFalsa)],
// …mas o teste queria verificar o comportamento da TELA
```

**Correção:** escolha a altura pelo que você quer testar — a tabela da seção Conceito resume.

### 11. `ProviderContainer` sem `dispose`

Testes que passam isolados e falham em suíte.

**Correção:** `addTearDown(container.dispose)`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test` e confirme os testes passando. Conte quantos rodam sem tocar a
rede.

**Passo 2.** No `TrilhasController.build()`, troque `ref.watch` por `ref.read`. Rode os testes e
veja qual falha. Explique por escrito.

**Passo 3.** No `RefreshIndicator`, troque o método do controller por `ref.invalidate`. Puxe para
atualizar e descreva as duas diferenças.

**Passo 4.** Remova `.autoDispose` do `trilhaPorIdProvider`. Abra cinco detalhes diferentes,
acrescentando um `debugPrint` no provider. Quantas instâncias continuam vivas?

**Passo 5.** No `EstadoErro` da tela, troque `falha?.mensagem` por `'$erro'`. Desligue a internet e
recarregue. Anote o que o usuário veria.

**Passo 6.** Remova `ref.invalidate(trilhaPorIdProvider(trilhaId))` do `alternarTema`. Abra o
detalhe, volte, marque um tema na lista, e abra o detalhe de novo. O que acontece?

**Passo 7.** Escreva um teste que confirme que `alternarTema` faz a tela mudar **antes** de o
repositório responder. (Dica: um repositório falso com `Completer` que você controla.)

**Passo 8.** Substitua `clienteHttpProvider` por um `MockClient` em vez do repositório. Escreva um
teste que passe pela cadeia inteira — service, repositório e controller reais.

**Passo 9.** Acrescente um provider `trilhasCompletasProvider` que devolve `AsyncValue<int>` com as
trilhas 100% concluídas. Escreva o teste.

**Passo 10.** Responda: você trocou a fonte de HTTP para SQLite. Quais arquivos mudam? Quais
**não** mudam? Liste-os.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Faça os exercícios de **Aplicação** com a cadeia completa, o de **Correção de bugs** com
`invalidate` no `RefreshIndicator`, e o de **Decisão** sobre onde substituir o provider no teste.

---

## 🏆 Desafio opcional

Implemente **paginação infinita** na lista de trilhas.

Requisitos:

- O controller guarda `({List<Trilha> itens, int pagina, bool temMais})`.
- Ao chegar perto do fim da lista, carrega a página seguinte automaticamente.
- Durante a carga da próxima página, os itens já carregados **continuam visíveis** e um indicador
  aparece **no fim** da lista (não por cima).
- Erro ao carregar uma página **não** apaga as anteriores: mostra uma linha "tentar de novo" no fim.
- Puxar para atualizar volta à página 1.
- O `RefreshIndicator` e a criação de trilha continuam funcionando.

Dica: `ScrollController` com `addListener` verificando
`position.pixels > position.maxScrollExtent - 300`; ou `NotificationListener<ScrollNotification>`.
Não esqueça o `dispose` do controller.

Depois responda: o que acontece se o usuário excluir um item da página 1 enquanto a página 3 está
carregando? Como você garante que a lista não fica com item duplicado ou faltando?

---

## 📌 Resumo

- A cadeia é: **cliente → service → repositório → controller → tela**, ligada por `ref.watch`, cada
  camada conhecendo só a de baixo, sempre pelo **contrato**.
- Cada provider mora **junto da classe que ele cria**, na pasta da sua camada.
- Os **três casos do `AsyncValue`** viram os **quatro estados** do Módulo 06 — "vazio" é conteúdo do
  sucesso, não estado da operação.
- O **quinto estado** ("recarregando com dados") é `isLoading && hasValue`.
- **`ref.invalidate`** apaga o estado (bom para "tentar de novo"); **método do controller com
  `copyWithPrevious`** mantém a lista (bom para puxar-para-atualizar).
- Se usar `invalidate` no `RefreshIndicator`, faça `await ref.read(provider.future)` para o
  indicador não sumir cedo.
- **`family` sempre com `autoDispose`.** Sem isso, cada item visitado deixa estado na memória.
- **`FutureProvider`** para leitura; **`AsyncNotifierProvider`** quando há escrita.
- Reaproveite a lista como **prévia** do detalhe: zero requisições e a tela não pisca.
- **Uma fonte de verdade:** o detalhe lê, o controller da lista escreve — e invalida o detalhe
  depois.
- Nunca mostre `erro.toString()`: a `Falha` já traz mensagem de usuário.
- Nos testes, **um override** substitui a cadeia inteira acima dele. Escolha a altura conforme o
  que quer testar.
- **A prova da arquitetura:** o controller não importa `http`. Trocar a fonte de dados não toca
  nele.

---

## ☑️ Checklist de domínio

- [ ] Monto a cadeia completa de providers e explico cada elo.
- [ ] Declaro cada provider junto da classe que ele cria.
- [ ] Ligo `AsyncValue.when` aos widgets de estado do Módulo 06.
- [ ] Trato "vazio" dentro do `data:`, não como estado separado.
- [ ] Mostro o quinto estado com `isLoading && hasValue`.
- [ ] Escolho entre `invalidate` e método do controller com critério.
- [ ] Uso `family` **sempre** com `autoDispose`.
- [ ] Escolho entre `FutureProvider` e `AsyncNotifierProvider`.
- [ ] Uso a lista como prévia do detalhe.
- [ ] Mantenho uma fonte de verdade e invalido o detalhe após alterar.
- [ ] Nunca mostro exceção crua na tela.
- [ ] Testo a cadeia substituindo um provider, sem rede.
- [ ] Meu controller não importa `http`.
- [ ] `flutter analyze` e `flutter test` passam limpos.

---

## 📚 Referências oficiais

- [Riverpod — Making your first provider/network request](https://riverpod.dev/docs/essentials/first_request)
- [Riverpod — Side effects](https://riverpod.dev/docs/essentials/side_effects)
- [Riverpod — Passing arguments](https://riverpod.dev/docs/essentials/passing_args)
- [Riverpod — Testing](https://riverpod.dev/docs/essentials/testing)
- [Fetch data from the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [RefreshIndicator — api.flutter.dev](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html)
- [Flutter architecture guide — docs.flutter.dev](https://docs.flutter.dev/app-architecture/guide)

---

## 🎓 Fim do Módulo 09

Você começou o módulo sem saber o que é um cabeçalho HTTP. Termina com:

- **HTTP e REST** entendidos de verdade, não decorados (aulas 1 e 2);
- um app que **busca dados reais** e os exibe (aula 3);
- **erros modelados** em vez de `try/catch` genérico (aula 4);
- **escrita completa** — criar, alterar, excluir — com idempotência entendida (aula 5);
- **resiliência**: timeout, retry com backoff, debounce e proteção de ordem (aula 6);
- uma **camada de dados testável**, com service, repositório e DTO (aula 7);
- **autenticação** com token guardado em cofre e renovação coordenada (aula 8);
- e a **cadeia inteira** ligada ao Riverpod, com testes sem rede (aula 9).

Antes de seguir:

1. Faça os exercícios em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md).
2. Faça a avaliação em
   [avaliacoes/modulo-09-consumo-de-api.md](../../avaliacoes/modulo-09-consumo-de-api.md).
3. Confirme que `flutter analyze` e `flutter test` no `foco_api` passam limpos.

No [Módulo 10](../10-persistencia-de-dados/README.md) os dados param de sumir quando o app fecha —
e você vai comprovar, na prática, a promessa desta aula: a camada de estado **não muda**.

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo |
|---|---|---|
| [Aula 8 — Autenticação e tokens](08-autenticacao-e-tokens.md) | [README](README.md) | [Módulo 10 — Persistência de Dados](../10-persistencia-de-dados/README.md) |
