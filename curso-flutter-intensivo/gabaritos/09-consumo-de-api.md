# Gabarito — Módulo 09: Consumo de API

> Compare depois de resolver os [exercícios](../exercicios/09-consumo-de-api.md).

<a id="m09-e01"></a>
## M09-E01
| Status | Significado | Culpa |
|---|---|---|
| 200 | Deu certo, o corpo vem junto | — |
| 201 | Recurso criado; `Location` aponta para ele | — |
| 204 | Deu certo e **não há corpo** (`jsonDecode('')` lança) | — |
| 304 | O cache do cliente ainda vale | — |
| 400 | Pedido malformado | Cliente |
| 401 | **Não autenticado**: não se identificou ou a sessão expirou | Cliente |
| 403 | Autenticado, mas **sem permissão** | Cliente |
| 404 | O recurso não existe | Cliente |
| 409 | Conflito de estado (duplicado, versão antiga) | Cliente |
| 422 | JSON válido, validação de negócio reprovou | Cliente |
| 429 | Requisições demais; respeite `Retry-After` | Cliente |
| 500 | Erro interno | Servidor |
| 503 | Indisponível ou em manutenção; transitório | Servidor |

Famílias: `2xx` sucesso, `3xx` cache/redirecionamento, `4xx` culpa do cliente, `5xx` culpa do servidor.

- `GET` — **idempotente**: só lê, não muda estado.
- `POST` — **não**: cada chamada cria um recurso novo.
- `PUT` — **idempotente**: manda o objeto inteiro, o estado final é o mesmo na 1ª e na 5ª vez.
- `PATCH` — **não**: o corpo pode ser relativo ("some 10 minutos"), e repetir soma duas vezes.
- `DELETE` — **idempotente**: depois da primeira vez o recurso já não existe; `404` é o mesmo estado final.

<a id="m09-e02"></a>
## M09-E02
**(a) `429` com `Retry-After: 30`** — você passou do limite de taxa; a culpa é do volume que o cliente disparou. O app espera os 30 s que o servidor pediu (`erro.retryAfter`) antes de repetir, nunca dispara retry imediato.

**(b) `201` com `Location: /posts/201`** — a criação deu certo, ninguém errou. O app adota o `id` do corpo (ou do `Location`) como id real e descarta o id provisório que tinha inventado.

**(c) `200` com `Content-Type: text/html`** — o corpo não é JSON: um portal de wi-fi (captive portal) ou proxy corporativo respondeu no lugar da API. `jsonDecode` vai lançar `FormatException`; o repositório traduz para `FalhaDeFormato` e a tela mostra "resposta inesperada do servidor", nunca a stack.

<a id="m09-e03"></a>
## M09-E03
```dart
class Autor {
  const Autor({required this.id, required this.nome});

  factory Autor.fromJson(Map<String, Object?> json) => Autor(
        id: json['id']! as String,
        nome: json['nome']! as String,
      );

  final String id;
  final String nome;

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'nome': nome};
}

class Topico {
  const Topico({required this.titulo, required this.minutos});

  factory Topico.fromJson(Map<String, Object?> json) => Topico(
        titulo: json['titulo']! as String,
        // Opcional: ausente OU nulo vira 0, sem exceção.
        minutos: json['minutos'] is int ? json['minutos']! as int : 0,
      );

  final String titulo;
  final int minutos;

  Map<String, Object?> toJson() =>
      <String, Object?>{'titulo': titulo, 'minutos': minutos};
}

class Trilha {
  const Trilha({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.topicos,
    required this.criadaEm,
  });

  factory Trilha.fromJson(Map<String, Object?> json) => Trilha(
        id: json['id']! as String,
        titulo: json['titulo']! as String,
        autor: Autor.fromJson(json['autor']! as Map<String, Object?>),
        topicos: (json['topicos'] as List<Object?>? ?? const <Object?>[])
            .map((Object? e) => Topico.fromJson(e! as Map<String, Object?>))
            .toList(growable: false),
        criadaEm: DateTime.parse(json['criadaEm']! as String),
      );

  final String id;
  final String titulo;
  final Autor autor;
  final List<Topico> topicos;
  final DateTime criadaEm;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'titulo': titulo,
        'autor': autor.toJson(),
        'topicos': topicos.map((Topico t) => t.toJson()).toList(),
        'criadaEm': criadaEm.toIso8601String(),
      };
}
```
`"topicos": []` passa sem caso especial (`map` de lista vazia devolve lista vazia) e o `??` cobre a chave ausente.

<a id="m09-e04"></a>
## M09-E04
```dart
factory TrilhaDto.fromJson(Map<String, Object?> json) {
  final Object? id = json['id'];
  final Object? title = json['title'];

  if (id is! int) {
    throw FormatException('Campo "id" ausente ou não é número: $id');
  }
  if (title is! String) {
    throw FormatException('Campo "title" ausente ou não é texto: $title');
  }

  return TrilhaDto(
    id: id,
    title: title,
    // Opcionais: valor padrão em vez de exceção.
    body: json['body'] is String ? json['body']! as String : '',
    userId: json['userId'] is int ? json['userId']! as int : 0,
  );
}
```
O defeito era o `as String`: o cast roda **antes** de qualquer validação e só sabe dizer "Null is not a String", sem citar o campo; o `is!` valida e nomeia.

<a id="m09-e05"></a>
## M09-E05
```dart
class Tarefa {
  const Tarefa({required this.id, required this.titulo, required this.concluida});

  factory Tarefa.fromJson(Map<String, Object?> json) => Tarefa(
        id: '${json['id']}',
        titulo: json['title'] is String ? json['title']! as String : '(sem título)',
        concluida: json['completed'] == true,
      );

  final String id;
  final String titulo;
  final bool concluida;
}

Future<List<Tarefa>> _buscarTarefas() async {
  // Uri.https codifica os parâmetros; a interpolação em Uri.parse, não.
  final Uri uri = Uri.https(
    'jsonplaceholder.typicode.com',
    '/todos',
    <String, String>{'_limit': '20'},
  );

  final http.Response resposta = await _cliente.get(
    uri,
    headers: const <String, String>{'Accept': 'application/json'},
  );

  // Checar ANTES de decodificar: corpo de erro não é o JSON esperado.
  if (resposta.statusCode != 200) {
    throw ApiException(resposta.statusCode, resposta.body, cabecalhos: resposta.headers);
  }

  // bodyBytes + utf8.decode: imune a servidor que esquece o charset.
  final List<Object?> bruto =
      jsonDecode(utf8.decode(resposta.bodyBytes)) as List<Object?>;
  return bruto
      .map((Object? e) => Tarefa.fromJson(e! as Map<String, Object?>))
      .toList(growable: false);
}
```
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
```
O Flutter injeta `INTERNET` só nos manifestos de **debug** e **profile** (o hot reload precisa de socket); o release usa o manifesto de `main/`, e sem a linha toda requisição lança `SocketException`.

<a id="m09-e06"></a>
## M09-E06
```dart
class _TarefasScreenState extends State<TarefasScreen> {
  late Future<List<Tarefa>> _futuroTarefas;

  @override
  void initState() {
    super.initState();
    _futuroTarefas = _buscarTarefas();
  }

  void _recarregar() => setState(() => _futuroTarefas = _buscarTarefas());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Tarefas'),
          actions: <Widget>[
            IconButton(onPressed: _recarregar, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: FutureBuilder<List<Tarefa>>(
          future: _futuroTarefas, // o CAMPO, não a chamada
          builder: (BuildContext c, AsyncSnapshot<List<Tarefa>> s) {
            if (s.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (s.hasError) {
              return Center(child: Text('Não foi possível carregar: ${s.error}'));
            }
            final List<Tarefa> lista = s.data ?? const <Tarefa>[];
            return ListView.builder(
              itemCount: lista.length,
              itemBuilder: (BuildContext c, int i) => CheckboxListTile(
                value: lista[i].concluida,
                onChanged: null,
                title: Text(lista[i].titulo),
              ),
            );
          },
        ),
      );
}
```
O defeito era `future: _buscarTarefas()`: o `build` roda a cada teclado, rotação ou troca de tema, e cada execução criava um `Future` novo.

<a id="m09-e07"></a>
## M09-E07
```dart
// core/erros/falhas.dart
final class FalhaManutencao extends Falha {
  const FalhaManutencao()
      : super(
          mensagem: 'O sistema está em manutenção programada.',
          comoResolver: 'Voltamos em instantes. Tente de novo mais tarde.',
          podeTentarDeNovo: true,
        );
}

// converterParaFalha — 503 ANTES de >= 500.
return switch (erro.statusCode) {
  400 || 422 => FalhaPedidoInvalido(erro.statusCode),
  401 => const FalhaNaoAutenticado(),
  403 => const FalhaSemPermissao(),
  404 => const FalhaNaoEncontrado(),
  429 => const FalhaMuitasTentativas(),
  503 => const FalhaManutencao(),
  >= 500 => FalhaServidor(erro.statusCode),
  _ => FalhaDesconhecida(erro.toString()),
};

// EstadoDeFalha._icone — o switch exaustivo cobre o caso novo
FalhaManutencao() => Icons.construction,
```
O `503` precisa vir antes de `>= 500`: no `switch` o primeiro padrão que casa vence, e `FalhaServidor` engoliria o caso novo em silêncio.

<a id="m09-e08"></a>
## M09-E08
`PATCH`, com corpo `{"title": "..."}`. Um `PUT` manda a trilha inteira do jeito que **este** aparelho a conhece e reescreveria a lista de concluídos com a versão antiga — o tópico marcado no outro aparelho desaparece. Com `PATCH`, campo que não foi enviado não é tocado.

Entram em `repetir()`: `listar` (GET), `substituir` (PUT) e `excluir` (DELETE), todos idempotentes — e `excluir` aceita `404` como sucesso, porque "já não existe" é exatamente o estado desejado. Ficam de fora `criar`, porque um POST repetido cria duas trilhas (o botão é desabilitado durante o envio e a repetição fica a cargo do usuário), e `alterar`, porque PATCH só é idempotente quando o corpo é absoluto; um corpo relativo aplicado duas vezes dobra a mudança.

<a id="m09-e09"></a>
## M09-E09
```dart
static const Map<String, String> _comCorpo = <String, String>{
  'Content-Type': 'application/json; charset=utf-8',
  'Accept': 'application/json',
};

Future<TrilhaDto> criar(TrilhaDto nova) async {
  final http.Response r = await _cliente.post(
    Uri.parse('$_base/posts'),
    headers: _comCorpo,
    body: jsonEncode(nova.toJson()), // o pacote http não serializa Map
  );
  _exigirSucesso(r, esperados: const <int>[201, 200]);
  // O id vem do SERVIDOR, nunca do app.
  return TrilhaDto.fromJson(jsonDecode(r.body) as Map<String, Object?>);
}

Future<TrilhaDto> alterar(String id, {String? titulo, String? descricao}) async {
  final Map<String, Object?> mudancas = <String, Object?>{
    if (titulo != null) 'title': titulo,
    if (descricao != null) 'body': descricao,
  };
  if (mudancas.isEmpty) {
    throw ArgumentError('Informe ao menos um campo para alterar');
  }

  final http.Response r = await _cliente.patch(
    Uri.parse('$_base/posts/$id'),
    headers: _comCorpo,
    body: jsonEncode(mudancas),
  );
  _exigirSucesso(r, esperados: const <int>[200]);
  return TrilhaDto.fromJson(jsonDecode(r.body) as Map<String, Object?>);
}

Future<void> excluir(String id) async {
  final http.Response r = await _cliente.delete(
    Uri.parse('$_base/posts/$id'),
    headers: _semCorpo,
  );
  // 404 é sucesso; e nada a decodificar: 204 vem sem corpo.
  _exigirSucesso(r, esperados: const <int>[200, 204, 404]);
}

void _exigirSucesso(http.Response r, {required List<int> esperados}) {
  if (!esperados.contains(r.statusCode)) {
    throw ApiException(r.statusCode, r.body, cabecalhos: r.headers);
  }
}
```
A trilha some ao recarregar porque a JSONPlaceholder **finge** a escrita: devolve `201` com `id: 101` e não persiste nada.

<a id="m09-e10"></a>
## M09-E10
```dart
Future<T> repetir<T>(
  Future<T> Function() acao, {
  int maximoDeTentativas = 3,
  Duration esperaBase = const Duration(milliseconds: 400),
  Duration esperaMaxima = const Duration(seconds: 8),
}) async {
  assert(maximoDeTentativas >= 1, 'Pelo menos uma tentativa');

  final math.Random random = math.Random();
  Object? ultimoErro;
  StackTrace? ultimaPilha;

  for (int tentativa = 0; tentativa < maximoDeTentativas; tentativa++) {
    try {
      return await acao();
    } on Object catch (erro, pilha) {
      ultimoErro = erro;
      ultimaPilha = pilha;

      if (!_ehTransitorio(erro)) rethrow; // 404 falha já na primeira
      if (tentativa == maximoDeTentativas - 1) break;

      await Future<void>.delayed(_esperaDe(
        tentativa: tentativa,
        base: esperaBase,
        maxima: esperaMaxima,
        random: random,
        erro: erro,
      ));
    }
  }
  Error.throwWithStackTrace(ultimoErro!, ultimaPilha!);
}

bool _ehTransitorio(Object erro) {
  if (erro is SocketException) return true;
  if (erro is http.ClientException) return true;
  if (erro is TimeoutException) return true;
  if (erro is ApiException) {
    return erro.statusCode >= 500 ||
        erro.statusCode == 429 ||
        erro.statusCode == 408;
  }
  return false; // desconhecido: falhe rápido e visível
}

Duration _esperaDe({
  required int tentativa,
  required Duration base,
  required Duration maxima,
  required math.Random random,
  required Object erro,
}) {
  // Se o servidor mandou Retry-After, ele manda.
  if (erro is ApiException) {
    final Duration? pedida = erro.retryAfter;
    if (pedida != null) return pedida > maxima ? maxima : pedida;
  }
  final int baseMs = base.inMilliseconds * (1 << tentativa); // base × 2^tentativa
  final int limitado = math.min(baseMs, maxima.inMilliseconds);
  final int jitter = random.nextInt(math.max(1, limitado ~/ 3));
  return Duration(milliseconds: limitado + jitter);
}
```
Sem o jitter, mil aparelhos derrubados no mesmo segundo repetiriam no mesmo instante e derrubariam o servidor de novo.

<a id="m09-e11"></a>
## M09-E11
```dart
class BuscaController extends AutoDisposeNotifier<AsyncValue<List<Trilha>>> {
  Timer? _debounce;
  int _sequencia = 0;
  String _termoAtual = '';

  @override
  AsyncValue<List<Trilha>> build() {
    ref.onDispose(() => _debounce?.cancel());
    return const AsyncData<List<Trilha>>(<Trilha>[]);
  }

  void aoDigitar(String termo) {
    _termoAtual = termo.trim();
    _debounce?.cancel();

    if (_termoAtual.isEmpty) {
      _sequencia++; // invalida o que estiver em voo
      state = const AsyncData<List<Trilha>>(<Trilha>[]);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _buscar(_termoAtual),
    );
  }

  Future<void> _buscar(String termo) async {
    final int minhaVez = ++_sequencia;
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);

    try {
      final List<Trilha> resultado =
          await ref.read(trilhaRepositorioProvider).buscar(termo);
      if (minhaVez != _sequencia) return; // chegou tarde: descarte
      state = AsyncData<List<Trilha>>(resultado);
    } on Object catch (erro, pilha) {
      if (minhaVez != _sequencia) return; // o erro obsoleto também some
      state = AsyncError<List<Trilha>>(erro, pilha).copyWithPrevious(state);
    }
  }
}
```
Descartar só a resposta e não o erro deixa a busca antiga pintar uma tela de falha por cima do resultado novo.

<a id="m09-e12"></a>
## M09-E12
```dart
// domain/trilha_repositorio_contrato.dart — sem http, sem Flutter
abstract interface class TrilhaRepositorioContrato {
  Future<List<Trilha>> listar();
  Future<Trilha> criar(Trilha nova);
  Future<void> excluir(String id);
}

// data/trilha_repositorio.dart — DTO → domínio, exceção técnica → Falha
Future<T> _traduzindoErros<T>(Future<T> Function() acao) async {
  try {
    return await acao();
  } on SocketException catch (_, pilha) {
    Error.throwWithStackTrace(const FalhaDeConexao(), pilha);
  } on http.ClientException catch (_, pilha) {
    Error.throwWithStackTrace(const FalhaDeConexao(), pilha);
  } on TimeoutException catch (_, pilha) {
    Error.throwWithStackTrace(const FalhaDeTempoEsgotado(), pilha);
  } on FormatException catch (e, pilha) {
    Error.throwWithStackTrace(FalhaDeFormato('$e'), pilha);
  } on ApiException catch (e, pilha) {
    Error.throwWithStackTrace(
      switch (e.statusCode) {
        401 || 403 => const FalhaDeAutenticacao(),
        404 => const FalhaNaoEncontrado(),
        429 => const FalhaDeLimite(),
        >= 500 => const FalhaDoServidor(),
        _ => FalhaInesperada('HTTP ${e.statusCode}'),
      },
      pilha,
    );
  }
}
```
```dart
// test/trilhas/trilha_api_test.dart
String fixture(String nome) => File('test/fixtures/$nome').readAsStringSync();

void main() {
  TrilhaApi comResposta(
    FutureOr<http.Response> Function(http.Request) responder,
  ) =>
      TrilhaApi(
        cliente: MockClient((http.Request req) async => responder(req)),
        base: 'https://api.test',
      );

  group('TrilhaApi.listar', () {
    test('200 devolve os DTOs', () async {
      final List<TrilhaDto> dtos = await comResposta(
        (_) => http.Response(fixture('trilhas_200.json'), 200),
      ).listar();

      expect(dtos.length, 2);
      expect(dtos.first.id, 1);
    });

    test('404 lança ApiException com o status', () {
      expect(
        comResposta((_) => http.Response('{}', 404)).listar(),
        throwsA(isA<ApiException>()
            .having((ApiException e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('500 lança ApiException', () {
      expect(
        comResposta((_) => http.Response('erro', 500)).listar(),
        throwsA(isA<ApiException>()),
      );
    });

    test('JSON malformado lança FormatException', () {
      expect(
        comResposta((_) => http.Response('<html>erro</html>', 200)).listar(),
        throwsA(isA<FormatException>()),
      );
    });

    test('sem rede lança SocketException', () {
      expect(
        comResposta((_) => throw const SocketException('Failed host lookup'))
            .listar(),
        throwsA(isA<SocketException>()),
      );
    });
  });
}
```
O `MockClient` roda na VM do Dart: `flutter test` passa no Windows sem emulador, e o teste do repositório espera `Falha`, nunca `ApiException`.

<a id="m09-e13"></a>
## M09-E13
- **Token de acesso** — `flutter_secure_storage`: é credencial viva, e `SharedPreferences` guarda em texto puro.
- **Token de renovação** — `flutter_secure_storage` também: vale mais que o de acesso, porque gera novos.
- **`URL_BASE`** — `--dart-define`: muda por ambiente, não é segredo e não deve virar `if` no código.
- **Chave de API de pagamento** — **no seu backend**: o que está no binário pode ser extraído dele, inclusive o que veio por `--dart-define`.
- **Preferência de tema** — `SharedPreferences`: não é segredo e precisa ser lida rápido no boot.

Os cinco `401` compartilham um único `Future<String>? _renovacaoEmAndamento` porque cada renovação **invalida o refresh token anterior**: cinco renovações em paralelo derrubariam a sessão. Todas aguardam o mesmo `Future` e reaproveitam o token novo.

Para testar a `TrilhasTab` sem rede, substitua o `trilhaRepositorioProvider` com `overrideWithValue(TrilhaRepositorioFalso())` — ele é tipado pelo **contrato**, então corta HTTP, JSON e tradução de erro de uma vez.

<a id="m09-e14"></a>
## M09-E14
```dart
final Provider<http.Client> clienteHttpProvider = Provider<http.Client>((Ref ref) {
  final http.Client cliente = http.Client();
  ref.onDispose(cliente.close); // sem autoDispose: o cliente vive o app todo
  return cliente;
});

final Provider<TrilhaApi> trilhaApiProvider = Provider<TrilhaApi>(
  (Ref ref) => TrilhaApi(cliente: ref.watch(clienteHttpProvider)),
);

final Provider<TrilhaRepositorioContrato> trilhaRepositorioProvider =
    Provider<TrilhaRepositorioContrato>(
  (Ref ref) => TrilhaRepositorio(ref.watch(trilhaApiProvider)),
);

final AsyncNotifierProvider<TrilhasController, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider<TrilhasController, List<Trilha>>(TrilhasController.new);

class TrilhasController extends AsyncNotifier<List<Trilha>> {
  @override
  Future<List<Trilha>> build() => ref.watch(trilhaRepositorioProvider).listar();

  /// Recarrega MANTENDO a lista visível.
  Future<void> recarregar() async {
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(trilhaRepositorioProvider).listar(),
    );
  }
}

class TrilhasTab extends ConsumerWidget {
  const TrilhasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trilha>> trilhas = ref.watch(trilhasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trilhas')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(trilhasProvider.notifier).recarregar(),
        child: trilhas.when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object erro, StackTrace pilha) {
            final Falha? falha = erro is Falha ? erro : null;
            return EstadoErro(
              titulo: falha is FalhaDeConexao ? 'Sem conexão' : 'Algo deu errado',
              mensagem: falha?.mensagem ?? 'Não conseguimos carregar as trilhas.',
              onTentarDeNovo: () => ref.read(trilhasProvider.notifier).recarregar(),
            );
          },
          data: (List<Trilha> lista) => lista.isEmpty
              ? const EstadoVazio(oQue: 'trilha')
              // AlwaysScrollable: sem isso a lista curta não puxa para atualizar.
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: lista.length,
                  itemBuilder: (BuildContext c, int i) =>
                      CartaoTrilha(trilha: lista[i]),
                ),
        ),
      ),
    );
  }
}
```
`ref.invalidate` apagaria o estado e voltaria a `AsyncLoading` **sem dados**; `copyWithPrevious` carrega a lista antiga junto, então a tela não pisca e a rolagem não se perde.

[Módulo](../modulos/09-consumo-de-api/README.md)
