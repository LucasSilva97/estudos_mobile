# Gabarito dos desafios — Projeto 02: Bloco de Notas de Estudo

> Compare depois de tentar. Estes desafios têm armadilhas específicas — o `copyWith` que não serve,
> o JSON que já está no aparelho, o tema que pisca claro antes de virar escuro — e bater nelas é o
> que fixa a lição.

Enunciados em [05-desafios.md](../projetos/02-projeto-intermediario/05-desafios.md).

---

<a id="p02-d01"></a>
## P02-D01 — Busca por título e conteúdo

> **Arquivo:** `lib/telas/home_screen.dart`

```dart
final TextEditingController _busca = TextEditingController();

@override
void initState() {
  super.initState();
  // Cada tecla refiltra. Sem o listener, o texto muda e a lista não.
  _busca.addListener(_aoDigitar);
}

@override
void dispose() {
  _busca.removeListener(_aoDigitar);
  _busca.dispose();          // ⚠️ sem isto, vaza o controller
  super.dispose();
}

void _aoDigitar() => setState(() {});

List<Nota> get _visiveis {
  final String termo = _busca.text.trim().toLowerCase();

  // Filtra sobre uma CÓPIA derivada: `_notas` continua sendo a
  // fonte da verdade e nunca muda de tamanho.
  return _notas.where((Nota n) {
    final bool casaEtiqueta = _filtro == null || n.etiqueta == _filtro;
    final bool casaTexto = termo.isEmpty ||
        n.titulo.toLowerCase().contains(termo) ||
        n.conteudo.toLowerCase().contains(termo);
    return casaEtiqueta && casaTexto;   // ← os dois combinam
  }).toList()
    ..sort(_comparadorDaOrdenacao);
}

void _limparFiltro() {
  setState(() {
    _filtro = null;
    _busca.clear();          // zera os DOIS, como o enunciado pede
  });
}
```

E o campo, acima dos chips:

```dart
TextField(
  controller: _busca,
  decoration: InputDecoration(
    hintText: 'Buscar no título ou no conteúdo',
    prefixIcon: const Icon(Icons.search),
    suffixIcon: _busca.text.isEmpty
        ? null
        : IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Limpar busca',
            onPressed: () => setState(_busca.clear),
          ),
  ),
),
```

O erro que o enunciado antecipa é filtrar **modificando** `_notas` — `_notas.removeWhere(...)` —
e depois não conseguir trazer as notas de volta, porque elas foram embora de verdade. O getter
`_visiveis` resolve isso por construção: ele **deriva** a lista visível a cada build, e a lista
real continua intacta.

---

<a id="p02-d02"></a>
## P02-D02 — Duplicar a nota

> **Arquivo:** `lib/modelos/acao_da_nota.dart`

```dart
enum AcaoDaNota { editar, excluir, duplicar }
```

> **Arquivo:** `lib/telas/detalhe_screen.dart`

```dart
IconButton(
  icon: const Icon(Icons.copy_outlined),
  tooltip: 'Duplicar nota',
  onPressed: () => Navigator.of(context).pop(AcaoDaNota.duplicar),
),
```

> **Arquivo:** `lib/telas/home_screen.dart`

```dart
switch (acao) {
  case AcaoDaNota.editar:
    await _editarNota(nota);
  case AcaoDaNota.excluir:
    await _excluirNota(nota);
  case AcaoDaNota.duplicar:
    await _duplicarNota(nota);
}

Future<void> _duplicarNota(Nota original) async {
  // O teto vale para a cópia também.
  if (_notas.length >= NotasRepositorio.maxNotas) {
    _avisar('Limite de ${NotasRepositorio.maxNotas} notas atingido');
    return;
  }

  final DateTime agora = DateTime.now();
  final String titulo = 'Cópia de ${original.titulo}';

  // ⚠️ copyWith NÃO serve: ele preserva id e criadaEm, e a cópia
  // nasceria com a identidade da original — duas notas, um id.
  final Nota copia = Nota(
    id: '${agora.microsecondsSinceEpoch}',
    titulo: titulo.length > 60 ? titulo.substring(0, 60) : titulo,
    conteudo: original.conteudo,
    etiqueta: original.etiqueta,
    criadaEm: agora,
    atualizadaEm: agora,
  );

  setState(() => _notas = <Nota>[..._notas, copia]);
  await _repositorio.salvar(_notas);
}
```

Dois pontos que o enunciado cobra de propósito:

O **`switch` sem `default`** é o que transforma o enum novo num erro de compilação em vez de um bug
silencioso. Com `default: break`, acrescentar `duplicar` compilaria e o botão simplesmente não
faria nada — e você descobriria testando, não compilando.

O **`copyWith` não serve** porque a cópia precisa de identidade própria. É a diferença entre
"o mesmo objeto com um campo diferente" e "um objeto novo parecido com aquele" — e confundir as
duas coisas é como se cria o bug de duas notas com o mesmo `id`, que quebra a exclusão.

---

<a id="p02-d03"></a>
## P02-D03 — Nota fixada no topo

> **Arquivo:** `lib/modelos/nota.dart`

```dart
class Nota {
  const Nota({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.etiqueta,
    required this.criadaEm,
    required this.atualizadaEm,
    this.fixada = false,            // ← padrão, não required
  });

  final bool fixada;

  Map<String, Object?> paraMapa() => <String, Object?>{
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'etiqueta': etiqueta.name,
        'criadaEm': criadaEm.toIso8601String(),
        'atualizadaEm': atualizadaEm.toIso8601String(),
        'fixada': fixada,
      };

  factory Nota.doMapa(Map<String, Object?> mapa) => Nota(
        id: mapa['id']! as String,
        titulo: mapa['titulo']! as String,
        conteudo: mapa['conteudo']! as String,
        etiqueta: Etiqueta.values.byName(mapa['etiqueta']! as String),
        criadaEm: DateTime.parse(mapa['criadaEm']! as String),
        atualizadaEm: DateTime.parse(mapa['atualizadaEm']! as String),
        // ⭐ A LINHA QUE IMPORTA. O arquivo que já está no aparelho
        // não tem a chave 'fixada'. Com `mapa['fixada']! as bool`
        // isso lançaria, o doMapa falharia para TODAS as notas e o
        // usuário abriria o app com a lista vazia — os dados dele
        // apagados por um campo novo.
        fixada: mapa['fixada'] as bool? ?? false,
      );

  Nota copyWith({
    String? titulo,
    String? conteudo,
    Etiqueta? etiqueta,
    DateTime? atualizadaEm,
    bool? fixada,
  }) =>
      Nota(
        id: id,
        titulo: titulo ?? this.titulo,
        conteudo: conteudo ?? this.conteudo,
        etiqueta: etiqueta ?? this.etiqueta,
        criadaEm: criadaEm,
        atualizadaEm: atualizadaEm ?? this.atualizadaEm,
        fixada: fixada ?? this.fixada,
      );

  @override
  bool operator ==(Object other) =>
      other is Nota &&
      other.id == id &&
      other.titulo == titulo &&
      other.conteudo == conteudo &&
      other.etiqueta == etiqueta &&
      other.criadaEm == criadaEm &&
      other.atualizadaEm == atualizadaEm &&
      other.fixada == fixada;

  @override
  int get hashCode =>
      Object.hash(id, titulo, conteudo, etiqueta, criadaEm, atualizadaEm, fixada);
}
```

A ordenação, com as fixadas em cima:

```dart
List<Nota> get _visiveis {
  final List<Nota> lista = _notas.where(_passaNoFiltro).toList();

  lista.sort((Nota a, Nota b) {
    // Primeiro critério: fixada vence. Só empatando é que a
    // Ordenacao escolhida entra.
    if (a.fixada != b.fixada) return a.fixada ? -1 : 1;
    return _comparadorDaOrdenacao(a, b);
  });

  return lista;
}
```

E o teste que o enunciado exige:

> **Arquivo:** `test/nota_test.dart`

```dart
test('mapa antigo, sem a chave fixada, ainda vira Nota', () {
  // Exatamente o que está gravado no aparelho de quem já usava o app.
  final Map<String, Object?> antigo = <String, Object?>{
    'id': '1',
    'titulo': 'Revisão de Dart',
    'conteudo': 'null safety',
    'etiqueta': 'estudo',
    'criadaEm': '2026-09-01T10:00:00.000',
    'atualizadaEm': '2026-09-01T10:00:00.000',
    // sem 'fixada'
  };

  final Nota nota = Nota.doMapa(antigo);

  expect(nota.fixada, isFalse);
  expect(nota.titulo, 'Revisão de Dart');
});
```

> 📌 Este é o desafio mais valioso do projeto 2, e o menos aparente. Ele é uma **migração de
> dados** disfarçada de campo novo — o mesmo problema que o módulo 10 trata com versões de banco.
> A diferença é que aqui não há mecanismo de migração nenhum: o `?? false` **é** a migração.

---

<a id="p02-d04"></a>
## P02-D04 — Os três testes que faltam

> **Arquivo:** `test/notas_repositorio_test.dart`

```dart
void main() {
  late NotasRepositorio repositorio;

  setUp(() async {
    // Sem isto, SharedPreferences lança MissingPluginException:
    // não há plataforma por baixo num teste de Dart.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    repositorio = NotasRepositorio(await SharedPreferences.getInstance());
  });

  test('salvar e carregar preserva as notas', () async {
    final List<Nota> originais = <Nota>[_nota('1', 'Dart'), _nota('2', 'Flutter')];

    await repositorio.salvar(originais);
    final List<Nota> lidas = await repositorio.carregar();

    expect(lidas, originais);          // depende do == do modelo
  });

  test('carregar sem nada gravado devolve lista vazia, não erro', () async {
    expect(await repositorio.carregar(), isEmpty);
  });

  test('JSON corrompido devolve lista vazia em vez de quebrar o app', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'notas': 'isto não é json',
    });
    final NotasRepositorio r =
        NotasRepositorio(await SharedPreferences.getInstance());

    // O app de um usuário não pode morrer na abertura por causa de
    // um arquivo estragado.
    expect(await r.carregar(), isEmpty);
  });

  test('acima de maxNotas o salvar recusa', () async {
    final List<Nota> demais = List<Nota>.generate(
      NotasRepositorio.maxNotas + 1,
      (int i) => _nota('$i', 'Nota $i'),
    );

    await expectLater(repositorio.salvar(demais), throwsA(isA<Exception>()));
  });
}
```

O teste de widget do formulário:

> **Arquivo:** `test/form_nota_test.dart`

```dart
testWidgets('título vazio bloqueia o envio', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: FormNotaScreen()));

  await tester.tap(find.byKey(const Key('botao_salvar')));
  await tester.pump();                 // ⚠️ sem este pump a árvore é a de antes

  expect(find.text('Informe um título'), findsOneWidget);
});
```

Os três valem por razões diferentes: o primeiro prova que a serialização **volta**, o de JSON
corrompido prova que o app **sobrevive** a um arquivo estragado, e o de widget prova que a
validação **impede** o envio em vez de só pintar de vermelho.

---

<a id="p02-d05"></a>
## P02-D05 — Tema no gosto do usuário

> **Arquivo:** `lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ Ler ANTES do runApp é o que evita o piscar. Se o tema for
  // carregado depois, o primeiro quadro sai no padrão (claro) e o
  // segundo já é escuro — e o usuário vê o flash.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String salvo = prefs.getString('tema') ?? 'system';

  runApp(
    BlocoNotasApp(
      repositorio: NotasRepositorio(prefs),
      temaInicial: ThemeMode.values.byName(salvo),
    ),
  );
}
```

> **Arquivo:** `lib/app.dart`

```dart
class BlocoNotasApp extends StatefulWidget {
  const BlocoNotasApp({
    required this.repositorio,
    required this.temaInicial,
    super.key,
  });

  final NotasRepositorio repositorio;
  final ThemeMode temaInicial;

  @override
  State<BlocoNotasApp> createState() => _BlocoNotasAppState();
}

class _BlocoNotasAppState extends State<BlocoNotasApp> {
  late ThemeMode _modo = widget.temaInicial;

  Future<void> _trocarTema(ThemeMode novo) async {
    setState(() => _modo = novo);
    await widget.repositorio.salvarTema(novo.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _modo,               // ← o estado mora ACIMA do MaterialApp
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      onGenerateRoute: (RouteSettings s) => Rotas.gerar(s, _trocarTema, _modo),
    );
  }
}
```

A dificuldade real do desafio não é o `ThemeMode` — é perceber **onde** o estado precisa morar.
Qualquer tela abaixo do `MaterialApp` pode mudar o próprio conteúdo, mas nenhuma pode mudar o tema
do `MaterialApp` que a contém. O estado tem que subir para um `StatefulWidget` que **envolve** o
`MaterialApp`. É o mesmo raciocínio de elevação de estado do módulo 08, aplicado ao topo da árvore.

---

<a id="p02-d06"></a>
## P02-D06 — Busca em tela cheia com `SearchDelegate`

> **Arquivo:** `lib/telas/busca_delegate.dart` (novo)

```dart
class BuscaDeNotas extends SearchDelegate<Nota?> {
  BuscaDeNotas(this.notas) : super(searchFieldLabel: 'Buscar notas');

  final List<Nota> notas;

  @override
  List<Widget> buildActions(BuildContext context) => <Widget>[
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Limpar',
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Voltar',
        // ⭐ close com null: cancelar NÃO seleciona nota nenhuma.
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _lista(context);

  @override
  Widget buildSuggestions(BuildContext context) => _lista(context);

  Widget _lista(BuildContext context) {
    final String termo = query.trim().toLowerCase();
    final List<Nota> achadas = termo.isEmpty
        ? notas
        : notas
            .where((Nota n) =>
                n.titulo.toLowerCase().contains(termo) ||
                n.conteudo.toLowerCase().contains(termo))
            .toList();

    if (achadas.isEmpty) {
      return const Center(child: Text('Nenhuma nota encontrada'));
    }

    return ListView.builder(
      itemCount: achadas.length,
      itemBuilder: (BuildContext context, int i) => CartaoNota(
        nota: achadas[i],
        aoTocar: () => close(context, achadas[i]),
      ),
    );
  }
}
```

E na home:

```dart
IconButton(
  icon: const Icon(Icons.search),
  tooltip: 'Buscar',
  onPressed: () async {
    final Nota? escolhida = await showSearch<Nota?>(
      context: context,
      delegate: BuscaDeNotas(_notas),
    );
    // Cancelou? `escolhida` é null e a home continua exatamente
    // como estava — filtro, ordenação e posição de rolagem.
    if (escolhida != null && mounted) {
      await _abrirNota(escolhida);
    }
  },
),
```

O que o enunciado cobra — "cancelar devolve `null` e a home volta intacta" — é consequência de
`close(context, null)` no `buildLeading`. O erro comum é usar `Navigator.pop()` ali, que fecha a
busca sem passar pelo `SearchDelegate` e deixa o `showSearch` pendurado.

**Onde a documentação responde:**
[`SearchDelegate`](https://api.flutter.dev/flutter/material/SearchDelegate-class.html).

---

<a id="p02-d07"></a>
## P02-D07 — Backup em texto: exportar e importar

> **Arquivo:** `lib/dados/backup.dart` (novo)

```dart
abstract final class Backup {
  /// Uma nota por objeto, com indentação — o usuário vai olhar isto.
  static String exportar(List<Nota> notas) {
    const JsonEncoder bonito = JsonEncoder.withIndent('  ');
    return bonito.convert(<String, Object?>{
      'versao': 1,
      'exportadoEm': DateTime.now().toIso8601String(),
      'notas': notas.map((Nota n) => n.paraMapa()).toList(),
    });
  }

  /// Nunca lança. Texto inválido devolve lista vazia, e quem chama
  /// decide o que dizer ao usuário.
  static List<Nota> importar(String texto) {
    try {
      final Object? cru = jsonDecode(texto);
      if (cru is! Map<String, Object?>) return const <Nota>[];

      final Object? lista = cru['notas'];
      if (lista is! List) return const <Nota>[];

      final List<Nota> saida = <Nota>[];
      for (final Object? item in lista) {
        if (item is! Map<String, Object?>) continue;   // pula o inválido
        try {
          saida.add(Nota.doMapa(item));
        } catch (_) {
          continue;   // uma nota estragada não invalida o arquivo inteiro
        }
      }
      return saida;
    } catch (_) {
      return const <Nota>[];
    }
  }
}
```

Na tela, o uso:

```dart
Future<void> _importar(String texto) async {
  final List<Nota> lidas = Backup.importar(texto);

  if (lidas.isEmpty) {
    // Exatamente o que o enunciado pede: avisa e MANTÉM a lista atual.
    _avisar('Nenhuma nota encontrada no texto colado');
    return;
  }

  setState(() => _notas = lidas);
  await _repositorio.salvar(_notas);
  _avisar('${lidas.length} notas importadas');
}
```

O desafio é sobre **entrada hostil**. O texto colado pode ser qualquer coisa: JSON de outro app,
um pedaço truncado, texto solto. A regra que organiza a solução é "o importador nunca lança" —
ele devolve o que conseguiu ler, e a decisão de o que fazer com zero notas fica na interface, onde
há contexto para avisar o usuário.

Repare no `continue` de dentro do laço: **uma** nota corrompida não deve invalidar as outras
199. Essa escolha é deliberada e vale explicá-la para si mesmo — a alternativa (recusar o arquivo
inteiro) também seria defensável, e num app de dados financeiros seria a correta.

---

## 🧭 Se a sua solução ficou diferente

| Pergunta | Por que importa |
|---|---|
| O **Esperado:** do enunciado acontece? | É o contrato do desafio |
| `_notas` continua sendo a fonte da verdade? | D01 é exatamente sobre isso |
| O `switch` do enum ficou sem `default`? | É o que faz o compilador cobrar o caso novo |
| Mapa antigo sem a chave nova ainda carrega? | D03 — é o dado do usuário em jogo |
| O tema pisca claro antes de virar escuro? | Então ele está sendo lido depois do `runApp` |
| Texto inválido derruba o app? | D07 — o importador nunca deve lançar |
| Todo controller criado tem `dispose`? | Vazamento, e o teste acusa Timer pendente |
| `flutter analyze` continua limpo? | Aviso novo é regressão |

Se o resultado é o mesmo e as regras acima valem, a sua versão serve.

---

[Desafios](../projetos/02-projeto-intermediario/05-desafios.md) ·
[Projeto 2](../projetos/02-projeto-intermediario/README.md) ·
[Gabaritos](README.md)
