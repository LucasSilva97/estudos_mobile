# Gabarito — Módulo 10: Persistência de dados

> Compare depois de resolver os [exercícios](../exercicios/10-persistencia-de-dados.md).

<a id="m10-e01"></a>
## M10-E01
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_dados/core/armazenamento/politica_de_armazenamento.dart';

void main() {
  test('triagem dos seis dados do Foco', () {
    const List<(PerfilDoDado, OpcaoDeArmazenamento, String)> casos =
        <(PerfilDoDado, OpcaoDeArmazenamento, String)>[
      (PerfilDoDado(nome: 'Token de acesso', ehSegredo: true),
          OpcaoDeArmazenamento.cofre, 'ehSegredo'),
      (PerfilDoDado(nome: 'Modo de tema'),
          OpcaoDeArmazenamento.preferencia, 'nenhum campo: valor pequeno'),
      (PerfilDoDado(nome: '3 mil sessões', precisaConsultar: true),
          OpcaoDeArmazenamento.banco, 'precisaConsultar'),
      (PerfilDoDado(nome: 'CSV do mês', ehArquivoOuBinario: true),
          OpcaoDeArmazenamento.arquivo, 'ehArquivoOuBinario'),
      (PerfilDoDado(nome: 'Total de minutos da semana', ehDerivado: true),
          OpcaoDeArmazenamento.naoPersistir, 'ehDerivado'),
      (PerfilDoDado(nome: 'PIN de desbloqueio', ehSegredo: true),
          OpcaoDeArmazenamento.cofre, 'ehSegredo'),
    ];

    for (final (PerfilDoDado dado, OpcaoDeArmazenamento esperado, String campo)
        in casos) {
      expect(escolherArmazenamento(dado), esperado,
          reason: '${dado.nome}: decidido por $campo');
    }
  });
}
```
A ordem das perguntas é a resposta: `ehSegredo` vem antes de tudo, e `ehDerivado` antes de `precisaConsultar` — invertidos, o total da semana iria parar no banco.

<a id="m10-e02"></a>
## M10-E02
```dart
class MetaRepositorio {
  const MetaRepositorio(this._prefs);

  final SharedPreferences _prefs;

  static const String _kMeta = 'meta_semanal_minutos';
  static const String _kNotificar = 'notificar_meta_atingida';
  static const String _kFixadas = 'materias_fixadas';
  static const String _kSessao = 'preferencias_de_sessao';
  static const int metaPadraoMinutos = 300;

  int lerMetaSemanalMinutos() => _prefs.getInt(_kMeta) ?? metaPadraoMinutos;
  Future<void> salvarMetaSemanalMinutos(int m) => _prefs.setInt(_kMeta, m);

  bool lerNotificarMetaAtingida() => _prefs.getBool(_kNotificar) ?? true;
  Future<void> salvarNotificarMetaAtingida(bool v) =>
      _prefs.setBool(_kNotificar, v);

  List<String> lerMateriasFixadas() =>
      _prefs.getStringList(_kFixadas) ?? const <String>[];

  Future<void> fixarMateria(String id) async {
    final List<String> atuais = lerMateriasFixadas();
    if (atuais.contains(id)) return;
    await _prefs.setStringList(_kFixadas, <String>[...atuais, id]);
  }

  PreferenciasDeSessao lerPreferenciasDeSessao() {
    final String? texto = _prefs.getString(_kSessao);
    if (texto == null || texto.isEmpty) return const PreferenciasDeSessao();
    try {
      final Object? bruto = jsonDecode(texto);
      if (bruto is! Map<String, Object?>) return const PreferenciasDeSessao();
      return PreferenciasDeSessao.doMapa(bruto);
    } on FormatException {
      return const PreferenciasDeSessao();
    }
  }

  Future<void> salvarPreferenciasDeSessao(PreferenciasDeSessao p) =>
      _prefs.setString(_kSessao, jsonEncode(p.paraMapa()));
}
```
Os `get*` devolvem `null` quando a chave não existe — é o `??` que produz o padrão, e o `on FormatException` que impede um JSON pela metade de derrubar a abertura do app.

<a id="m10-e03"></a>
## M10-E03
```dart
class ExportadorDeEstudo {
  const ExportadorDeEstudo({
    required this.pastaDeDocumentos,
    required this.pastaTemporaria,
  });

  final Directory pastaDeDocumentos;
  final Directory pastaTemporaria;

  String caminhoDoRelatorio(int ano, int mes) => p.join(
        pastaDeDocumentos.path,
        'relatorios',
        'foco-${ano.toString().padLeft(4, '0')}'
            '-${mes.toString().padLeft(2, '0')}.csv',
      );

  Future<File> exportarCsv({
    required int ano,
    required int mes,
    required List<LinhaDeRelatorio> linhas,
  }) async {
    final File destino = File(caminhoDoRelatorio(ano, mes));
    await destino.parent.create(recursive: true);

    final StringBuffer buffer = StringBuffer()..writeln('data;materia;minutos');
    for (final LinhaDeRelatorio l in linhas) {
      final String dia = l.data.day.toString().padLeft(2, '0');
      final String mesDaLinha = l.data.month.toString().padLeft(2, '0');
      buffer.writeln('$dia/$mesDaLinha/${l.data.year};'
          '${l.materia.replaceAll(';', ',')};${l.minutos}');
    }

    // Grava no parcial e só então renomeia: se o app for encerrado no meio,
    // o relatório anterior continua íntegro em vez de virar metade.
    final File parcial = File('${destino.path}.parcial');
    await parcial.writeAsString(buffer.toString(), flush: true);
    return parcial.rename(destino.path);
  }

  Future<String?> lerRelatorio(int ano, int mes) async {
    final File arquivo = File(caminhoDoRelatorio(ano, mes));
    if (!await arquivo.exists()) return null;
    try {
      return await arquivo.readAsString();
    } on FileSystemException {
      return null; // ausência é resultado normal, não erro de tela
    }
  }
}
```
O teste passa `pastaDeDocumentos: Directory.systemTemp.createTempSync()`: a classe não conhece `path_provider`, e é por isso que ela roda no Windows sem emulador.

<a id="m10-e04"></a>
## M10-E04
```dart
static Future<void> configurar(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

static Future<void> criar(Database db, int versao) async {
  await db.execute(
    'CREATE TABLE materias ('
    '  id             TEXT    PRIMARY KEY,'
    '  nome           TEXT    NOT NULL,'
    '  nome_ordenacao TEXT    NOT NULL,'
    '  minutos        INTEGER NOT NULL DEFAULT 0,'
    '  criada_em      INTEGER NOT NULL'
    ')',
  );
  await db.execute(
    'CREATE INDEX idx_materias_nome_ordenacao ON materias (nome_ordenacao)',
  );
  await db.execute(
    'CREATE TABLE sessoes ('
    '  id         TEXT    PRIMARY KEY,'
    '  materia_id TEXT    NOT NULL,'
    '  inicio_em  INTEGER NOT NULL,'
    '  minutos    INTEGER NOT NULL,'
    '  FOREIGN KEY (materia_id) REFERENCES materias (id)'
    '    ON DELETE CASCADE'
    ')',
  );
  await db.execute('CREATE INDEX idx_sessoes_materia ON sessoes (materia_id)');
  await db.execute('CREATE INDEX idx_sessoes_inicio ON sessoes (inicio_em)');
}
```
Um `execute` por comando, e o teste precisa passar `onConfigure: BancoFoco.configurar` para `openDatabase`: o SQLite nasce com chave estrangeira desligada, e sem o `PRAGMA` o `CASCADE` escrito no `CREATE TABLE` não acontece.

<a id="m10-e05"></a>
## M10-E05
```dart
enum OrdemDeMaterias {
  nome('nome_ordenacao ASC'),
  maisEstudadas('minutos DESC, nome_ordenacao ASC'),
  maisRecentes('criada_em DESC');

  const OrdemDeMaterias(this.clausula);
  final String clausula;
}

class MateriaDao {
  const MateriaDao(this._db);

  final DatabaseExecutor _db;
  static const String tabela = 'materias';

  // abort, não replace: replace APAGA a linha antiga e o CASCADE levaria
  // todas as sessões da matéria junto.
  Future<void> inserir(Materia m) async => _db.insert(tabela, m.paraLinha(),
      conflictAlgorithm: ConflictAlgorithm.abort);

  Future<List<Materia>> listar({
    OrdemDeMaterias ordem = OrdemDeMaterias.nome,
    bool incluirArquivadas = false,
  }) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: incluirArquivadas ? null : 'arquivada = ?',
      whereArgs: incluirArquivadas ? null : <Object?>[0],
      orderBy: ordem.clausula, // vem do enum, nunca de texto do usuário
    );
    return linhas.map(Materia.deLinha).toList();
  }

  Future<Materia?> porId(String id) async {
    final List<Map<String, Object?>> linhas = await _db
        .query(tabela, where: 'id = ?', whereArgs: <Object?>[id], limit: 1);
    return linhas.isEmpty ? null : Materia.deLinha(linhas.first);
  }

  Future<int> atualizar(Materia m) => _db.update(tabela, m.paraLinha(),
      where: 'id = ?', whereArgs: <Object?>[m.id]);

  Future<int> arquivar(String id, {bool arquivada = true}) => _db.update(
      tabela, <String, Object?>{'arquivada': arquivada ? 1 : 0},
      where: 'id = ?', whereArgs: <Object?>[id]);

  Future<int> excluir(String id) =>
      _db.delete(tabela, where: 'id = ?', whereArgs: <Object?>[id]);
}
```
Renomear `zoologia` para `Ácido` reordena a lista porque `paraLinha()` deriva o `nome_ordenacao` com `Texto.paraOrdenacao` e `atualizar` grava a linha inteira; nome de coluna não aceita `?`, e por isso a ordenação vem de um enum fechado.

<a id="m10-e06"></a>
## M10-E06
```dart
Future<List<Materia>> buscar(String termo) async {
  final String alvo = Texto.paraOrdenacao(termo);
  if (alvo.isEmpty) return listar();

  final List<Map<String, Object?>> linhas = await _db.query(
    tabela,
    where: 'nome_ordenacao LIKE ? AND arquivada = 0',
    whereArgs: <Object?>['%$alvo%'], // o % é VALOR: continua parametrizado
    orderBy: OrdemDeMaterias.nome.clausula,
    limit: 50,
  );
  return linhas.map(Materia.deLinha).toList();
}
```
Eram dois defeitos: o termo interpolado direto no SQL (a aspa do usuário fechava a string e o resto virava comando) e o `ORDER BY nome`, que ordena por code unit e joga `Álgebra` depois de `Física`.

<a id="m10-e07"></a>
## M10-E07
`transaction` é atomicidade: tudo o que está dentro dela é confirmado junto ou desfeito junto, e você pode **ler** no meio para decidir o passo seguinte. `batch` é desempenho: acumula as operações em Dart e as envia numa única ida ao SQLite, em vez de uma ida por comando — com `commit(noResult: true)` você ainda descarta os retornos, o que é o certo quando não vai usar os rowids. Usar `db` em vez de `txn` dentro de um `transaction` trava o app porque o `db` espera a transação terminar para atender o comando, e a transação espera esse comando terminar para fechar: nenhum dos dois sai do lugar. Para importar 1 000 matérias vindas do servidor, use os dois juntos — `txn.batch()` dentro de `db.transaction` — para ter a velocidade do lote e a garantia de que uma falha na linha 700 não deixe 699 matérias pela metade.

<a id="m10-e08"></a>
## M10-E08
```dart
/// 1 → inicial   2 → materias.arquivada
/// 3 → sessoes.anotacao/humor   4 → materias.cor
static const int versaoAtual = 4;

static Future<void> atualizar(Database db, int de, int para) async {
  if (de < 2) await _de1Para2(db);
  if (de < 3) await _de2Para3(db);
  if (de < 4) await _de3Para4(db);
}

static Future<void> _de3Para4(Database db) async {
  // NOT NULL exige DEFAULT: as linhas que já existem precisam de um valor.
  await db.execute(
    'ALTER TABLE materias ADD COLUMN cor INTEGER NOT NULL DEFAULT 0',
  );
}
```
`_de1Para2` e `_de2Para3` já foram publicadas e não se editam — mexer nelas faria bancos "na mesma versão" terem estruturas diferentes; acrescente `cor` também no `criar`, senão quem instala hoje fica sem a coluna.

<a id="m10-e09"></a>
## M10-E09
Com `else if`, o aparelho na versão 1 entra só no primeiro bloco e ganha apenas `materias.arquivada`; mesmo assim o `user_version` vai para 4, então as migrações seguintes nunca mais rodam e o app quebra na primeira consulta a `sessoes.anotacao`. A forma correta é a sequência de `if` independentes, que leva o banco de qualquer versão antiga até a atual, em etapas.
```dart
static Future<void> atualizar(Database db, int de, int para) async {
  if (de < 2) await _de1Para2(db);
  if (de < 3) await _de2Para3(db);
  if (de < 4) await _de3Para4(db);
}
```

<a id="m10-e10"></a>
## M10-E10
Use `recriarTabelaModelo`. O `ALTER TABLE` do SQLite sabe acrescentar coluna e renomear, mas **não** sabe mudar o tipo de uma coluna existente nem alterar chave, e remover coluna só existe em versões recentes — versões que você não controla, porque o SQLite vem embutido no aparelho do usuário. As duas mudanças pedidas caem justamente nesse buraco, então o caminho é o procedimento documentado pelo próprio SQLite: criar `sessoes_nova` com o esquema certo, copiar **nomeando todas as colunas** (`SELECT *` quebra se a ordem mudar), `DROP TABLE sessoes`, renomear e recriar **todos** os índices, que morrem junto com a tabela antiga. O `PRAGMA foreign_keys = OFF` fica fora da transação porque esse pragma é ignorado dentro dela: colocado no `txn`, ele não desliga nada, e aí o `DROP TABLE` dispara o `ON DELETE CASCADE` e apaga exatamente as sessões que você está tentando preservar. Depois de religar, rode `PRAGMA foreign_key_check` e lance se sobrar órfão. O risco para quem já tem o app instalado é o pior tipo: a migração roda **uma vez**, sem rede e sem supervisão, e se falhar no meio o usuário fica com um banco inconsistente e sem cópia. Por isso ela vai inteira dentro de `db.transaction` e é testada abrindo um banco de verdade na versão antiga, com dados, antes de a versão subir.

<a id="m10-e11"></a>
## M10-E11
```dart
final SessaoLocal sessao = SessaoLocal(
  CofreSeguro(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        synchronizable: false,
      ),
    ),
  ),
);

/// Roda uma vez, na abertura, antes de qualquer leitura do cofre.
Future<void> migrarTokenAntigo(
  SharedPreferences prefs,
  SessaoLocal sessao,
) async {
  const String chaveAntiga = 'token';
  final String? antigo = prefs.getString(chaveAntiga);
  if (antigo == null) return;

  await sessao.salvar(access: antigo, refresh: '', usuarioId: '');
  // Sem o remove, o segredo continua em texto claro no XML do app.
  await prefs.remove(chaveAntiga);
}
```
O `debugPrint('token: $t')` sai junto: ele escreve no log do sistema, que qualquer captura de erro e qualquer ferramenta de diagnóstico enxerga.

<a id="m10-e12"></a>
## M10-E12
```dart
Future<void> definirPin(String pin) async {
  final String sal = _gerarSal();
  await _cofre.gravar(_kPinSal, sal);
  await _cofre.gravar(_kPinHash, _hashDe(pin, sal));
}

Future<bool> pinCorreto(String pin) async {
  final String? sal = await _lerTolerante(_kPinSal);
  final String? hash = await _lerTolerante(_kPinHash);
  if (sal == null || hash == null) return false;
  return _iguaisEmTempoConstante(_hashDe(pin, sal), hash);
}

static String _gerarSal() {
  // Random() comum é previsível e não serve para segurança.
  final math.Random aleatorio = math.Random.secure();
  return base64Url.encode(List<int>.generate(16, (_) => aleatorio.nextInt(256)));
}

static String _hashDe(String pin, String sal) =>
    sha256.convert(utf8.encode('$sal:$pin')).toString();

static bool _iguaisEmTempoConstante(String a, String b) {
  if (a.length != b.length) return false;
  int diferenca = 0;
  for (int i = 0; i < a.length; i++) {
    diferenca |= a.codeUnitAt(i) ^ b.codeUnitAt(i); // percorre tudo, sempre
  }
  return diferenca == 0;
}
```
O sal é gravado porque sem ele não há como recalcular o hash na conferência, e é ele que impede uma tabela pronta de resolver de uma vez os 10 000 PINs de quatro dígitos.

<a id="m10-e13"></a>
## M10-E13
**Lista de trilhas — *stale-while-revalidate*, TTL `Validade.trilhas` (6 h).** É o catálogo: muda pouco e a tela nunca deve abrir em branco. O usuário vê o cache na hora, com `avisoDeIdade` quando ele passa de cinco minutos, e a lista se atualiza sozinha quando a rede responde; dentro das 6 h nem vale a pena ir à rede.

**Saldo de minutos da semana — *network-first*, TTL curto (1 min) ou nenhum.** Um número errado aqui é pior que um número ausente: é olhando para ele que a pessoa decide se estuda mais hoje. Tenta a rede primeiro; se falhar, mostra o último valor **rotulado como desatualizado**, nunca como se fosse o saldo de agora.

**Detalhe da trilha aberto no metrô — *cache-first*, TTL `Validade.trilhas`.** O conteúdo já veio com a listagem e não muda no meio da leitura; ir à rede a cada abertura entrega só uma espera de 30 segundos que termina em erro. Com cache-first a tela abre instantânea e offline, e a revalidação fica para quando a conexão voltar.

<a id="m10-e14"></a>
## M10-E14
```dart
Stream<TrilhasComOrigem> observar() async* {
  final CacheDeTrilhas? cache = await _cache.lerListagem();
  final int pendencias = await _fila.quantidadePendente();

  if (cache != null) {
    yield TrilhasComOrigem(
      trilhas: cache.trilhas,
      daRede: false,
      avisoDeIdade: cache.avisoDeIdade,
      pendencias: pendencias,
    );
    if (!cache.expirouEm(Validade.trilhas)) return;
  }

  // Sem checar conectividade antes: connectivity_plus diz se há interface,
  // não se há internet. Tenta sempre.
  try {
    final List<Trilha> daRede = await _api.listar();
    await _cache.gravarListagem(daRede);
    yield TrilhasComOrigem(trilhas: daRede, daRede: true, pendencias: pendencias);
  } on Object catch (erro) {
    if (cache == null) {
      final StatusDeRede status = await _rede.atual();
      throw status.provavelmenteOnline
          ? FalhaDoServidor('$erro')
          : const FalhaSemConexao();
    }
    // Com o cache já na tela, o aviso de idade diz o que importa.
  }
}

Future<void> alternarTema({
  required String trilhaId,
  required String tema,
  required bool marcar,
}) async {
  await _aplicarNoCache(trilhaId, tema, marcar); // a tela muda na hora
  await _fila.enfileirar(
    tipo: marcar ? TipoDeOperacao.marcarTema : TipoDeOperacao.desmarcarTema,
    alvoId: '$trilhaId/$tema',
    carga: <String, Object?>{'trilha_id': trilhaId, 'tema': tema},
  );
  unawaited(sincronizar()); // falhou? fica na fila
}
```
`StatusDeRede.semInterface` decide apenas a **mensagem** de erro, nunca se a requisição acontece; e `sincronizar()` envia na ordem do `id`, parando na primeira falha de rede porque as próximas falhariam igual.
