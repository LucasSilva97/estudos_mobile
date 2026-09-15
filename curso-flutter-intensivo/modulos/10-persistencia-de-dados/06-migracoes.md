# Aula 6 — Migrações

> **Módulo:** 10 - Persistência de Dados · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que um app **quebra em produção** quando o esquema muda sem migração.
- Usar **`version` + `onUpgrade`** para evoluir o banco sem perder dados do usuário.
- Escrever migrações **em etapas**, para funcionar de qualquer versão antiga até a atual.
- Acrescentar coluna com **`ALTER TABLE ADD COLUMN`** e conhecer os limites do SQLite.
- **Recriar uma tabela** quando `ALTER TABLE` não basta — o padrão das 6 etapas.
- Tratar **`onDowngrade`** e decidir o que fazer quando o usuário instala uma versão antiga.
- Testar migrações com **`PRAGMA table_info`**, sem emulador.
- Preencher dados derivados numa migração (**backfill**).

## ✅ Pré-requisitos

- [Aula 4 — sqflite: criando o banco](04-sqflite-criando-o-banco.md) — `BancoFoco`, `version`,
  `onCreate`, e o `onUpgrade` que ficou vazio.
- [Aula 5 — sqflite: CRUD](05-sqflite-crud.md) — o `MateriaDao` e a coluna `nome_ordenacao`.
- [Módulo 00, aula 4 — Commits, branches e .gitignore](../00-git-e-terminal/04-commits-branches-gitignore.md)
  — versão de esquema é como versão de código: nunca se reescreve o que já saiu.

---

## 📖 Conceito

### O problema

Você publicou a versão 1.0 do Foco. Mil pessoas instalaram. O banco delas tem:

```sql
CREATE TABLE materias (
  id             TEXT    PRIMARY KEY,
  nome           TEXT    NOT NULL,
  nome_ordenacao TEXT    NOT NULL,
  minutos        INTEGER NOT NULL DEFAULT 0,
  criada_em      INTEGER NOT NULL
);
```

Agora você quer acrescentar `arquivada`. Você edita o `onCreate`, testa no emulador (onde o banco
é criado do zero), funciona perfeitamente, e publica a 1.1.

**No aparelho do usuário:**

```text
DatabaseException(no such column: arquivada (code 1 SQLITE_ERROR))
```

**Por quê:** o `onCreate` só roda quando o arquivo do banco **não existe**. No aparelho de quem já
usava o app, ele existe — com o esquema antigo. O `onCreate` nunca é chamado, a coluna nunca é
criada, e o app quebra **em toda tela que lê matérias**.

E a "solução" que muita gente tenta:

```dart
// ❌ NUNCA faça isto num app publicado
await deleteDatabase(caminho);
```

Isso apaga **todos os dados do usuário**. Meses de sessões de estudo, para acrescentar uma coluna.

### `version` e `onUpgrade`

O `sqflite` guarda a versão do esquema **dentro** do arquivo do banco:

```dart
openDatabase(
  caminho,
  version: 2,              // ← a versão que o CÓDIGO espera
  onCreate: criar,         // banco não existe
  onUpgrade: atualizar,    // banco existe, com versão MENOR
  onDowngrade: rebaixar,   // banco existe, com versão MAIOR
);
```

O que acontece na abertura:

| Situação | Método chamado | Argumentos |
|---|---|---|
| Arquivo não existe | `onCreate(db, 2)` | A versão atual |
| Arquivo na versão 1 | `onUpgrade(db, 1, 2)` | De 1 para 2 |
| Arquivo na versão 2 | **Nenhum** | Já está atualizado |
| Arquivo na versão 3 | `onDowngrade(db, 3, 2)` | O usuário instalou versão antiga |

> ⚠️ **`version` é a versão do ESQUEMA, não do app.** Ela sobe quando a estrutura das tabelas muda —
> nunca porque o app ganhou uma tela nova. Um app na versão 4.2 pode ter esquema na versão 2.

### Migração em etapas

O erro mais comum é escrever a migração pensando só no **último** usuário:

```dart
// ❌ só funciona para quem está exatamente na versão 2
Future<void> atualizar(Database db, int de, int para) async {
  await db.execute('ALTER TABLE materias ADD COLUMN cor INTEGER');
}
```

Mas os usuários não estão todos na mesma versão. Alguém instalou na 1.0 e não atualiza há um ano:
o banco dele está na versão **1**, e ele vai direto para a **4**.

A forma correta é **em etapas**, sem `else`:

```dart
Future<void> atualizar(Database db, int de, int para) async {
  // Cada bloco leva de uma versão à seguinte.
  // Sem `else`: quem vem da 1 executa TODOS os blocos, em ordem.
  if (de < 2) await _de1Para2(db);
  if (de < 3) await _de2Para3(db);
  if (de < 4) await _de3Para4(db);
}
```

| Usuário na versão | Blocos executados |
|---|---|
| 1 | `_de1Para2`, `_de2Para3`, `_de3Para4` |
| 2 | `_de2Para3`, `_de3Para4` |
| 3 | `_de3Para4` |

> 📌 **Uma migração publicada nunca se edita.** Depois que a 1.1 saiu, `_de1Para2` rodou no
> aparelho de milhares de pessoas. Mudá-la faria bancos diferentes terem estruturas diferentes na
> mesma versão. Precisa corrigir? Escreva `_de2Para3`. É a mesma regra do
> [Módulo 00](../00-git-e-terminal/04-commits-branches-gitignore.md): não se reescreve o que já
> saiu.

### `ALTER TABLE ADD COLUMN` e seus limites

O SQLite tem um `ALTER TABLE` **muito** limitado:

| Operação | SQLite suporta? |
|---|---|
| `ADD COLUMN` | ✅ |
| `RENAME TO` (tabela) | ✅ |
| `RENAME COLUMN` | ✅ desde 3.25 (Android 11+) |
| `DROP COLUMN` | ⚠️ desde 3.35 — **não** em Android antigo |
| Mudar tipo de coluna | ❌ |
| Acrescentar `NOT NULL` sem `DEFAULT` | ❌ |
| Acrescentar/remover chave estrangeira | ❌ |
| Mudar `PRIMARY KEY` | ❌ |

E o `ADD COLUMN` tem uma regra que pega todo mundo:

```sql
-- ❌ não funciona
ALTER TABLE materias ADD COLUMN cor INTEGER NOT NULL;

-- ✅ NOT NULL exige DEFAULT
ALTER TABLE materias ADD COLUMN cor INTEGER NOT NULL DEFAULT 0;
```

Faz sentido: as linhas que já existem precisam de **algum** valor para a coluna nova.

> ⚠️ **Não confie no `DROP COLUMN`.** Ele existe desde o SQLite 3.35 (2021), mas a versão do SQLite
> vem **do sistema operacional**. Um Android 10 tem 3.28 — e o `DROP COLUMN` falha. Para remover
> coluna com segurança, recrie a tabela.

### Recriar a tabela: o padrão das 6 etapas

Quando `ALTER TABLE` não basta — mudar tipo, remover coluna, alterar chave —, o SQLite documenta
este procedimento:

```dart
Future<void> _recriarMaterias(Database db) async {
  // 1. Desligar chaves estrangeiras (fora de transação).
  await db.execute('PRAGMA foreign_keys = OFF');

  await db.transaction((Transaction txn) async {
    // 2. Criar a tabela nova com o esquema desejado.
    await txn.execute(
      'CREATE TABLE materias_nova ('
      '  id TEXT PRIMARY KEY,'
      '  nome TEXT NOT NULL,'
      '  nome_ordenacao TEXT NOT NULL,'
      '  minutos INTEGER NOT NULL DEFAULT 0,'
      '  criada_em INTEGER NOT NULL,'
      '  arquivada INTEGER NOT NULL DEFAULT 0'
      ')',
    );

    // 3. Copiar os dados, nomeando TODAS as colunas.
    await txn.execute(
      'INSERT INTO materias_nova (id, nome, nome_ordenacao, minutos, criada_em) '
      'SELECT id, nome, nome_ordenacao, minutos, criada_em FROM materias',
    );

    // 4. Apagar a tabela antiga.
    await txn.execute('DROP TABLE materias');

    // 5. Renomear a nova.
    await txn.execute('ALTER TABLE materias_nova RENAME TO materias');

    // Os índices morrem com a tabela: recrie-os.
    await txn.execute(
      'CREATE INDEX idx_materias_nome_ordenacao ON materias (nome_ordenacao)',
    );
  });

  // 6. Religar as chaves e conferir a integridade.
  await db.execute('PRAGMA foreign_keys = ON');
  final List<Map<String, Object?>> problemas =
      await db.rawQuery('PRAGMA foreign_key_check');
  if (problemas.isNotEmpty) {
    throw StateError('Migração quebrou a integridade: $problemas');
  }
}
```

Três detalhes que dão problema:

1. **`PRAGMA foreign_keys` não funciona dentro de transação.** Precisa vir antes e depois.
2. **Nomeie as colunas no `INSERT ... SELECT`.** `SELECT *` quebra se a ordem mudar.
3. **Índices morrem com a tabela.** Recrie todos.

### Backfill: preencher dados derivados

Às vezes a coluna nova precisa de valor **calculado** a partir dos dados existentes. Foi
exatamente o caso do `nome_ordenacao`:

```dart
Future<void> _de1Para2(Database db) async {
  await db.execute(
    "ALTER TABLE materias ADD COLUMN nome_ordenacao TEXT NOT NULL DEFAULT ''",
  );

  // Preenche as linhas que já existiam.
  // Isto é Dart, não SQL: o SQLite não sabe remover acentos.
  final List<Map<String, Object?>> linhas =
      await db.query('materias', columns: <String>['id', 'nome']);

  final Batch lote = db.batch();
  for (final Map<String, Object?> linha in linhas) {
    lote.update(
      'materias',
      <String, Object?>{
        'nome_ordenacao': Texto.paraOrdenacao(linha['nome']! as String),
      },
      where: 'id = ?',
      whereArgs: <Object?>[linha['id']],
    );
  }
  await lote.commit(noResult: true);

  await db.execute(
    'CREATE INDEX idx_materias_nome_ordenacao ON materias (nome_ordenacao)',
  );
}
```

> ⚠️ **Backfill com muitas linhas precisa de `batch`.** Um `update` por linha, em 20 000 registros,
> faz o app ficar segundos parado na abertura — e o Android pode matá-lo por ANR ("o app não está
> respondendo").

### `onDowngrade`

Acontece quando o banco está numa versão **maior** que a do código: o usuário instalou uma versão
antiga do app (uma build de teste, um APK lateral, um rollback na loja).

```dart
// A opção pronta do sqflite: apaga e recria.
onDowngrade: onDatabaseDowngradeDelete,
```

| Estratégia | Consequência |
|---|---|
| `onDatabaseDowngradeDelete` | **Apaga tudo** e recria. Simples e destrutivo |
| Lançar exceção | O app não abre — mas avisa em vez de corromper |
| Ignorar (padrão) | O app abre com colunas que o código não conhece; pode funcionar ou quebrar |

**Decisão do curso:** `onDatabaseDowngradeDelete`. Rebaixamento é raro, e tentar adivinhar como
desfazer uma migração costuma dar mais errado do que recriar. Mas **avise o usuário**.

### Testar migrações

Testar migração é diferente de testar CRUD: você precisa criar um banco **na versão antiga**,
rodar a migração e verificar o resultado.

```dart
// 1. Abre na versão 1, com o onCreate ANTIGO.
Database db = await databaseFactory.openDatabase(
  caminho,
  options: OpenDatabaseOptions(version: 1, onCreate: _criarEsquemaV1),
);
await db.insert('materias', <String, Object?>{...});
await db.close();

// 2. Reabre na versão atual: o onUpgrade roda.
db = await databaseFactory.openDatabase(
  caminho,
  options: OpenDatabaseOptions(
    version: BancoFoco.versaoAtual,
    onCreate: BancoFoco.criar,
    onUpgrade: BancoFoco.atualizar,
  ),
);

// 3. Verifica estrutura E dados.
final List<Map<String, Object?>> colunas =
    await db.rawQuery('PRAGMA table_info(materias)');
```

**`PRAGMA table_info(tabela)`** devolve uma linha por coluna, com `name`, `type`, `notnull`,
`dflt_value` e `pk`. É a ferramenta para verificar estrutura.

> 📌 Use **arquivo temporário**, não `inMemoryDatabasePath`: o banco em memória some ao fechar, e a
> migração precisa de um banco que **persiste** entre as duas aberturas.

---

## 💡 Analogia

Pense num prédio habitado.

- **`onCreate`** é construir o prédio do zero, com a planta nova. Fácil — não há ninguém dentro.
- **`onUpgrade`** é uma **reforma com moradores dentro**. Você não pode demolir e reconstruir: as
  pessoas e os móveis delas (os dados) precisam continuar lá.
- **Apagar o banco** é demolir o prédio para trocar uma tomada. Resolve o problema técnico e
  destrói tudo o que importava.
- **A migração em etapas** é a reforma que funciona **qualquer que seja o estado do apartamento**.
  Alguns moradores já fizeram a reforma de 2023; outros ainda estão com a instalação de 2021. A
  equipe precisa de um roteiro que leve **de cada estado** ao atual, um passo por vez.
- **Não editar migração publicada** é não mudar a planta da reforma de 2023 depois de ela ter sido
  feita em 300 apartamentos. Se ela estava errada, você faz **uma reforma nova** que corrige — não
  reescreve o histórico, porque os apartamentos já reformados não vão ser reformados de novo.
- **Recriar a tabela** é quando não dá para só acrescentar uma tomada: é preciso derrubar a parede.
  Aí você monta o cômodo novo ao lado, **muda os móveis com cuidado** (o `INSERT ... SELECT`),
  derruba o antigo e renomeia. E religa a fiação (os índices, as chaves estrangeiras) no fim.
- **`onDowngrade`** é o morador voltar com a planta de 2021 e tentar morar num apartamento já
  reformado. O prédio não sabe desfazer a reforma — por isso a saída honesta é avisar e recomeçar.

---

## 🧪 Exemplo mínimo

Uma migração de verdade, testada, rodando no Windows.

> **Arquivo:** `foco_dados/test/exemplo_migracao_test.dart` (temporário)
> **Como executar:** `flutter test test/exemplo_migracao_test.dart`

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory pasta;
  late String caminho;

  setUp(() async {
    // ARQUIVO temporário, não inMemoryDatabasePath: o banco precisa
    // sobreviver entre as duas aberturas, e o de memória some ao fechar.
    pasta = await Directory.systemTemp.createTemp('foco_migracao_');
    caminho = p.join(pasta.path, 'foco.db');
  });

  tearDown(() async => pasta.delete(recursive: true));

  // ── Os esquemas, versão por versão ───────────────────────────────────────

  /// O esquema v1, como foi publicado. Este método NUNCA muda.
  Future<void> criarV1(Database db, int v) async {
    await db.execute(
      'CREATE TABLE materias ('
      '  id TEXT PRIMARY KEY,'
      '  nome TEXT NOT NULL,'
      '  minutos INTEGER NOT NULL DEFAULT 0'
      ')',
    );
  }

  /// v1 → v2: acrescenta `nome_ordenacao` e preenche as linhas existentes.
  Future<void> de1Para2(Database db) async {
    // NOT NULL exige DEFAULT: as linhas existentes precisam de um valor.
    await db.execute(
      "ALTER TABLE materias ADD COLUMN nome_ordenacao TEXT NOT NULL DEFAULT ''",
    );

    // BACKFILL: preenche o valor derivado nas linhas que já existiam.
    // O SQLite não sabe remover acentos — isto é Dart.
    final List<Map<String, Object?>> linhas =
        await db.query('materias', columns: <String>['id', 'nome']);

    // batch: com 20 000 linhas, um update por vez travaria a abertura
    // do app por segundos — e o Android mataria por ANR.
    final Batch lote = db.batch();
    for (final Map<String, Object?> linha in linhas) {
      lote.update(
        'materias',
        <String, Object?>{
          'nome_ordenacao': _paraOrdenacao(linha['nome']! as String),
        },
        where: 'id = ?',
        whereArgs: <Object?>[linha['id']],
      );
    }
    await lote.commit(noResult: true);

    await db.execute(
      'CREATE INDEX idx_materias_nome_ordenacao ON materias (nome_ordenacao)',
    );
  }

  /// v2 → v3: acrescenta `arquivada`.
  Future<void> de2Para3(Database db) async {
    await db.execute(
      'ALTER TABLE materias ADD COLUMN arquivada INTEGER NOT NULL DEFAULT 0',
    );
  }

  /// v3 → v4: `minutos` precisa virar `REAL`.
  ///
  /// O SQLite NÃO sabe mudar tipo de coluna: é preciso recriar a tabela.
  Future<void> de3Para4(Database db) async {
    // PRAGMA foreign_keys NÃO funciona dentro de transação:
    // precisa vir antes e depois.
    await db.execute('PRAGMA foreign_keys = OFF');

    await db.transaction((Transaction txn) async {
      await txn.execute(
        'CREATE TABLE materias_nova ('
        '  id TEXT PRIMARY KEY,'
        '  nome TEXT NOT NULL,'
        '  nome_ordenacao TEXT NOT NULL DEFAULT \'\','
        '  minutos REAL NOT NULL DEFAULT 0,'
        '  arquivada INTEGER NOT NULL DEFAULT 0'
        ')',
      );

      // Nomeie TODAS as colunas. SELECT * quebraria se a ordem mudasse.
      await txn.execute(
        'INSERT INTO materias_nova (id, nome, nome_ordenacao, minutos, arquivada) '
        'SELECT id, nome, nome_ordenacao, CAST(minutos AS REAL), arquivada '
        'FROM materias',
      );

      await txn.execute('DROP TABLE materias');
      await txn.execute('ALTER TABLE materias_nova RENAME TO materias');

      // Os índices morrem com a tabela: recrie-os.
      await txn.execute(
        'CREATE INDEX idx_materias_nome_ordenacao ON materias (nome_ordenacao)',
      );
    });

    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// A migração completa, EM ETAPAS.
  ///
  /// Sem `else`: quem vem da v1 executa os três blocos, em ordem.
  /// Com `else if`, um usuário da v1 só ganharia o primeiro — e o app
  /// quebraria na primeira consulta a `arquivada`.
  Future<void> atualizar(Database db, int de, int para) async {
    if (de < 2) await de1Para2(db);
    if (de < 3) await de2Para3(db);
    if (de < 4) await de3Para4(db);
  }

  Future<Database> abrirNaVersao(
    int versao, {
    Future<void> Function(Database, int)? onCreate,
  }) {
    return databaseFactory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versao,
        onCreate: onCreate ?? criarV1,
        onUpgrade: atualizar,
        onDowngrade: onDatabaseDowngradeDelete,
      ),
    );
  }

  Future<Set<String>> colunasDe(Database db, String tabela) async {
    final List<Map<String, Object?>> info =
        await db.rawQuery('PRAGMA table_info($tabela)');
    return info.map((Map<String, Object?> c) => c['name']! as String).toSet();
  }

  // ── Os testes ────────────────────────────────────────────────────────────

  test('v1 → v4 executa TODAS as etapas', () async {
    // 1. Banco na versão antiga, com dados do "usuário".
    Database db = await abrirNaVersao(1);
    await db.insert('materias', <String, Object?>{
      'id': 'dart',
      'nome': 'Álgebra Linear',
      'minutos': 120,
    });
    await db.close();

    // 2. Reabre na versão atual: o onUpgrade roda.
    db = await abrirNaVersao(4);

    // 3. A estrutura mudou…
    expect(
      await colunasDe(db, 'materias'),
      containsAll(<String>['nome_ordenacao', 'arquivada']),
    );

    // …e os DADOS DO USUÁRIO continuam lá. Este é o ponto.
    final List<Map<String, Object?>> linhas = await db.query('materias');
    expect(linhas.single['nome'], 'Álgebra Linear');
    expect(linhas.single['minutos'], 120.0); // virou REAL

    // O backfill preencheu a coluna derivada.
    expect(linhas.single['nome_ordenacao'], 'algebra linear');

    await db.close();
  });

  test('v3 → v4 executa só a última etapa', () async {
    Database db = await abrirNaVersao(1);
    await db.close();

    // Passa pela v2 e v3.
    db = await abrirNaVersao(3);
    await db.insert('materias', <String, Object?>{
      'id': 'x',
      'nome': 'X',
      'nome_ordenacao': 'x',
      'minutos': 10,
      'arquivada': 0,
    });
    await db.close();

    db = await abrirNaVersao(4);
    final List<Map<String, Object?>> linhas = await db.query('materias');
    expect(linhas.single['minutos'], 10.0);
    await db.close();
  });

  test('abrir na mesma versão NÃO roda migração', () async {
    Database db = await abrirNaVersao(4);
    await db.insert('materias', <String, Object?>{
      'id': 'x',
      'nome': 'X',
      'nome_ordenacao': 'x',
      'minutos': 10.0,
      'arquivada': 0,
    });
    await db.close();

    // Se a migração rodasse de novo, o ALTER TABLE lançaria
    // "duplicate column name".
    db = await abrirNaVersao(4);
    expect(await db.query('materias'), hasLength(1));
    await db.close();
  });

  test('os índices sobrevivem à recriação da tabela', () async {
    Database db = await abrirNaVersao(1);
    await db.close();
    db = await abrirNaVersao(4);

    final List<Map<String, Object?>> indices = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='materias'",
    );
    final Set<String> nomes =
        indices.map((Map<String, Object?> i) => i['name']! as String).toSet();

    // Sem o CREATE INDEX no fim da recriação, este índice teria
    // morrido com o DROP TABLE — e a listagem ficaria lenta,
    // sem nenhum erro aparecer.
    expect(nomes, contains('idx_materias_nome_ordenacao'));

    await db.close();
  });

  test('a coluna nova tem o DEFAULT declarado', () async {
    Database db = await abrirNaVersao(1);
    await db.close();
    db = await abrirNaVersao(4);

    final List<Map<String, Object?>> info =
        await db.rawQuery('PRAGMA table_info(materias)');
    final Map<String, Object?> arquivada = info
        .firstWhere((Map<String, Object?> c) => c['name'] == 'arquivada');

    expect(arquivada['notnull'], 1);
    expect(arquivada['dflt_value'], '0');

    await db.close();
  });

  test('backfill preenche TODAS as linhas antigas', () async {
    Database db = await abrirNaVersao(1);
    for (final String nome in <String>['Álgebra', 'Cálculo', 'Ética']) {
      await db.insert('materias', <String, Object?>{
        'id': nome,
        'nome': nome,
        'minutos': 0,
      });
    }
    await db.close();

    db = await abrirNaVersao(4);
    final List<Map<String, Object?>> linhas =
        await db.query('materias', orderBy: 'nome_ordenacao');

    expect(
      linhas.map((Map<String, Object?> l) => l['nome_ordenacao']).toList(),
      <String>['algebra', 'calculo', 'etica'],
    );

    await db.close();
  });
}

String _paraOrdenacao(String texto) {
  const String comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const String semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

  final StringBuffer buffer = StringBuffer();
  for (final String c in texto.split('')) {
    final int i = comAcento.indexOf(c);
    buffer.write(i >= 0 ? semAcento[i] : c);
  }
  return buffer.toString().toLowerCase().trim();
}
```

```powershell
flutter test test/exemplo_migracao_test.dart
```

**O teste que mais importa** é o primeiro: ele prova que um usuário parado na v1 chega à v4
**com os dados intactos**. É exatamente esse cenário que quebra apps em produção.

---

## 📱 Aplicando no Flutter

Agora o `BancoFoco` do `foco_dados` ganha migrações de verdade. O esquema evolui da versão 1
(aula 4) para a 3:

| Versão | O que muda | Por quê |
|---|---|---|
| 1 | Esquema inicial (aula 4) | — |
| 2 | `materias.arquivada` | Ocultar matéria sem apagar o histórico |
| 3 | `sessoes.anotacao` e `sessoes.humor`; índice composto | Registrar o que foi estudado |

---

## 💻 Código completo

> **Arquivo:** `foco_dados/lib/core/banco/banco_foco.dart` (atualizado)
> **Como executar:** `flutter test`

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:foco_dados/core/banco/texto.dart';

/// Abertura, criação e migração do banco do Foco.
///
/// Toda a lógica de esquema mora aqui. Nenhum DAO abre banco por conta
/// própria — eles recebem o `Database` pronto (Módulo 08, aula 10).
class BancoFoco {
  const BancoFoco._();

  /// Versão do ESQUEMA.
  ///
  /// Sobe quando a ESTRUTURA das tabelas muda — nunca porque o app
  /// ganhou uma tela nova. Um app na versão 4.2 pode ter esquema 3.
  ///
  /// Histórico:
  ///   1 → esquema inicial (materias, sessoes)
  ///   2 → materias.arquivada
  ///   3 → sessoes.anotacao, sessoes.humor, índice composto
  static const int versaoAtual = 3;

  static const String nomeDoArquivo = 'foco.db';

  static Future<Database> abrir() async {
    final pasta = await getDatabasesPath();
    final caminho = p.join(pasta, nomeDoArquivo);

    return openDatabase(
      caminho,
      version: versaoAtual,
      onConfigure: configurar,
      onCreate: criar,
      onUpgrade: atualizar,
      // Rebaixamento é raro e tentar desfazer migração dá mais errado
      // que recriar. Mas AVISE o usuário — veja `houveRebaixamento`.
      onDowngrade: rebaixar,
    );
  }

  /// Marcado quando o banco teve de ser recriado por rebaixamento.
  /// A tela consulta isto para avisar o usuário.
  static bool houveRebaixamento = false;

  static Future<void> configurar(Database db) async {
    // O SQLite nasce com chave estrangeira DESLIGADA, por compatibilidade.
    // Sem esta linha, ON DELETE CASCADE não acontece.
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ── Criação do zero ───────────────────────────────────────────────────────

  /// Roda só quando o arquivo do banco NÃO existe.
  ///
  /// ⚠️ É por isso que editar apenas este método quebra o app de quem já
  /// tinha o app instalado: no aparelho dele, o arquivo existe e este
  /// método nunca é chamado.
  static Future<void> criar(Database db, int versao) async {
    await db.execute(
      'CREATE TABLE materias ('
      '  id             TEXT    PRIMARY KEY,'
      '  nome           TEXT    NOT NULL,'
      '  nome_ordenacao TEXT    NOT NULL,'
      '  minutos        INTEGER NOT NULL DEFAULT 0,'
      '  criada_em      INTEGER NOT NULL,'
      '  arquivada      INTEGER NOT NULL DEFAULT 0'
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
      "  anotacao   TEXT    NOT NULL DEFAULT '',"
      '  humor      INTEGER,'
      '  FOREIGN KEY (materia_id) REFERENCES materias (id)'
      '    ON DELETE CASCADE'
      ')',
    );

    await db.execute('CREATE INDEX idx_sessoes_materia ON sessoes (materia_id)');
    await db.execute('CREATE INDEX idx_sessoes_inicio ON sessoes (inicio_em)');
    await db.execute(
      'CREATE INDEX idx_sessoes_materia_inicio '
      'ON sessoes (materia_id, inicio_em)',
    );
  }

  // ── Migração ──────────────────────────────────────────────────────────────

  /// Leva o banco de QUALQUER versão antiga até a atual.
  ///
  /// EM ETAPAS, sem `else`: quem está na v1 executa todos os blocos, em
  /// ordem. Com `else if`, ele só ganharia o primeiro — e o app quebraria
  /// na primeira consulta à coluna que faltou.
  static Future<void> atualizar(Database db, int de, int para) async {
    if (de < 2) await _de1Para2(db);
    if (de < 3) await _de2Para3(db);
    // Versão 4 futura entra aqui: `if (de < 4) await _de3Para4(db);`
  }

  /// v1 → v2: matérias podem ser arquivadas.
  ///
  /// ⚠️ PUBLICADA. Este método nunca muda: ele já rodou no aparelho de
  /// milhares de pessoas. Corrigir algo aqui faria bancos na "mesma
  /// versão" terem estruturas diferentes. Para corrigir, escreva a
  /// migração seguinte.
  static Future<void> _de1Para2(Database db) async {
    // NOT NULL exige DEFAULT: as linhas existentes precisam de um valor.
    await db.execute(
      'ALTER TABLE materias ADD COLUMN arquivada INTEGER NOT NULL DEFAULT 0',
    );
  }

  /// v2 → v3: sessões ganham anotação e humor.
  ///
  /// ⚠️ PUBLICADA. Não edite.
  static Future<void> _de2Para3(Database db) async {
    await db.execute(
      "ALTER TABLE sessoes ADD COLUMN anotacao TEXT NOT NULL DEFAULT ''",
    );

    // Sem NOT NULL: humor é opcional, e uma sessão antiga não tem como
    // ter um valor razoável. NULL é a resposta honesta para
    // "não informado".
    await db.execute('ALTER TABLE sessoes ADD COLUMN humor INTEGER');

    // Índice composto: acelera "sessões desta matéria, neste período",
    // que é a consulta mais frequente da tela de detalhe.
    await db.execute(
      'CREATE INDEX idx_sessoes_materia_inicio '
      'ON sessoes (materia_id, inicio_em)',
    );
  }

  // ── Recriação de tabela ───────────────────────────────────────────────────

  /// Modelo para quando `ALTER TABLE` não basta.
  ///
  /// O SQLite não sabe mudar tipo de coluna, remover coluna (em versões
  /// antigas), nem alterar chave. Nesses casos, o procedimento é este —
  /// documentado pelo próprio SQLite.
  ///
  /// Guarde este método como referência: a primeira migração que precisar
  /// dele vai acontecer, e improvisar na hora é como se perdem dados.
  static Future<void> recriarTabelaModelo(
    Database db, {
    required String tabela,
    required String esquemaNovo,
    required List<String> colunasACopiar,
    required List<String> indices,
  }) async {
    // 1. Desligar chaves. NÃO funciona dentro de transação.
    await db.execute('PRAGMA foreign_keys = OFF');

    await db.transaction((Transaction txn) async {
      // 2. Criar a nova.
      await txn.execute(esquemaNovo.replaceAll(tabela, '${tabela}_nova'));

      // 3. Copiar. Nomeie TODAS as colunas: SELECT * quebra se a ordem mudar.
      final String colunas = colunasACopiar.join(', ');
      await txn.execute(
        'INSERT INTO ${tabela}_nova ($colunas) SELECT $colunas FROM $tabela',
      );

      // 4. Apagar a antiga.
      await txn.execute('DROP TABLE $tabela');

      // 5. Renomear.
      await txn.execute('ALTER TABLE ${tabela}_nova RENAME TO $tabela');

      // Os índices morrem com a tabela. Recrie TODOS.
      for (final String indice in indices) {
        await txn.execute(indice);
      }
    });

    // 6. Religar e CONFERIR. Sem esta checagem, uma migração pode
    // deixar filhos órfãos e o problema só aparecer meses depois.
    await db.execute('PRAGMA foreign_keys = ON');
    final List<Map<String, Object?>> problemas =
        await db.rawQuery('PRAGMA foreign_key_check');
    if (problemas.isNotEmpty) {
      throw StateError('Migração quebrou a integridade: $problemas');
    }
  }

  // ── Rebaixamento ──────────────────────────────────────────────────────────

  /// O usuário instalou uma versão ANTIGA do app sobre um banco novo.
  ///
  /// Não há como desfazer uma migração com segurança: recriamos o banco.
  /// A marca permite à tela avisar o usuário em vez de ele descobrir
  /// sozinho que os dados sumiram.
  static Future<void> rebaixar(Database db, int de, int para) async {
    houveRebaixamento = true;
    await onDatabaseDowngradeDelete(db, de, para);
  }

  // ── Diagnóstico ───────────────────────────────────────────────────────────

  /// Colunas de uma tabela. Usado nos testes e no diagnóstico.
  static Future<Set<String>> colunasDe(Database db, String tabela) async {
    final info = await db.rawQuery('PRAGMA table_info($tabela)');
    return info.map((linha) => linha['name']! as String).toSet();
  }

  /// Checa se há filhos órfãos. Rode depois de qualquer migração
  /// que mexa em tabelas com chave estrangeira.
  static Future<bool> integridadeOk(Database db) async {
    final problemas = await db.rawQuery('PRAGMA foreign_key_check');
    return problemas.isEmpty;
  }

  /// Backfill de uma coluna derivada, em lote.
  ///
  /// Exemplo de uso numa migração futura que precise preencher
  /// `nome_ordenacao` a partir de `nome`.
  static Future<void> preencherNomeOrdenacao(Database db) async {
    final linhas = await db.query('materias', columns: <String>['id', 'nome']);

    // batch: com 20 000 linhas, um update por vez travaria a abertura
    // do app por segundos — e o Android mataria o processo por ANR.
    final lote = db.batch();
    for (final linha in linhas) {
      lote.update(
        'materias',
        <String, Object?>{
          'nome_ordenacao': Texto.paraOrdenacao(linha['nome']! as String),
        },
        where: 'id = ?',
        whereArgs: <Object?>[linha['id']],
      );
    }
    await lote.commit(noResult: true);
  }
}
```

> **Arquivo:** `foco_dados/test/migracoes_test.dart` (novo)

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:foco_dados/core/banco/banco_foco.dart';

/// O esquema da v1, EXATAMENTE como foi publicado.
///
/// Este arquivo é histórico: ele documenta o que existia no aparelho do
/// usuário. Nunca mude — se mudar, os testes passam a validar uma
/// migração que nunca aconteceu na vida real.
Future<void> criarEsquemaV1(Database db, int versao) async {
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
    '  FOREIGN KEY (materia_id) REFERENCES materias (id) ON DELETE CASCADE'
    ')',
  );
  await db.execute('CREATE INDEX idx_sessoes_materia ON sessoes (materia_id)');
  await db.execute('CREATE INDEX idx_sessoes_inicio ON sessoes (inicio_em)');
}

/// O esquema da v2.
Future<void> criarEsquemaV2(Database db, int versao) async {
  await criarEsquemaV1(db, 1);
  await db.execute(
    'ALTER TABLE materias ADD COLUMN arquivada INTEGER NOT NULL DEFAULT 0',
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory pasta;
  late String caminho;

  setUp(() async {
    // Arquivo temporário: o banco precisa sobreviver entre as aberturas.
    pasta = await Directory.systemTemp.createTemp('foco_migracao_');
    caminho = p.join(pasta.path, 'foco.db');
  });

  tearDown(() async {
    BancoFoco.houveRebaixamento = false;
    await pasta.delete(recursive: true);
  });

  Future<Database> abrir(
    int versao, {
    required Future<void> Function(Database, int) onCreate,
  }) {
    return databaseFactory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versao,
        onConfigure: BancoFoco.configurar,
        onCreate: onCreate,
        onUpgrade: BancoFoco.atualizar,
        onDowngrade: BancoFoco.rebaixar,
      ),
    );
  }

  Future<Database> abrirAtual() =>
      abrir(BancoFoco.versaoAtual, onCreate: BancoFoco.criar);

  group('v1 → atual', () {
    test('acrescenta todas as colunas novas', () async {
      Database db = await abrir(1, onCreate: criarEsquemaV1);
      await db.close();

      db = await abrirAtual();

      expect(await BancoFoco.colunasDe(db, 'materias'), contains('arquivada'));
      expect(
        await BancoFoco.colunasDe(db, 'sessoes'),
        containsAll(<String>['anotacao', 'humor']),
      );

      await db.close();
    });

    test('PRESERVA os dados do usuário', () async {
      Database db = await abrir(1, onCreate: criarEsquemaV1);
      await db.insert('materias', <String, Object?>{
        'id': 'dart',
        'nome': 'Dart',
        'nome_ordenacao': 'dart',
        'minutos': 120,
        'criada_em': DateTime(2026, 1, 1).millisecondsSinceEpoch,
      });
      await db.insert('sessoes', <String, Object?>{
        'id': 's1',
        'materia_id': 'dart',
        'inicio_em': DateTime(2026, 1, 2).millisecondsSinceEpoch,
        'minutos': 25,
      });
      await db.close();

      db = await abrirAtual();

      // Este é o ponto da aula inteira: 120 minutos de estudo
      // continuam lá depois de duas migrações.
      final List<Map<String, Object?>> materias = await db.query('materias');
      expect(materias.single['minutos'], 120);
      expect(materias.single['nome'], 'Dart');

      final List<Map<String, Object?>> sessoes = await db.query('sessoes');
      expect(sessoes.single['minutos'], 25);

      await db.close();
    });

    test('as colunas novas ganham os valores padrão', () async {
      Database db = await abrir(1, onCreate: criarEsquemaV1);
      await db.insert('materias', <String, Object?>{
        'id': 'dart',
        'nome': 'Dart',
        'nome_ordenacao': 'dart',
        'minutos': 0,
        'criada_em': 0,
      });
      await db.insert('sessoes', <String, Object?>{
        'id': 's1',
        'materia_id': 'dart',
        'inicio_em': 0,
        'minutos': 25,
      });
      await db.close();

      db = await abrirAtual();

      expect((await db.query('materias')).single['arquivada'], 0);
      expect((await db.query('sessoes')).single['anotacao'], '');
      // humor é opcional: NULL é a resposta honesta para "não informado".
      expect((await db.query('sessoes')).single['humor'], isNull);

      await db.close();
    });

    test('o índice composto é criado', () async {
      Database db = await abrir(1, onCreate: criarEsquemaV1);
      await db.close();
      db = await abrirAtual();

      final List<Map<String, Object?>> indices = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='sessoes'",
      );
      final Set<String> nomes =
          indices.map((Map<String, Object?> i) => i['name']! as String).toSet();

      expect(nomes, contains('idx_sessoes_materia_inicio'));
      await db.close();
    });

    test('a integridade referencial continua ok', () async {
      Database db = await abrir(1, onCreate: criarEsquemaV1);
      await db.insert('materias', <String, Object?>{
        'id': 'dart',
        'nome': 'Dart',
        'nome_ordenacao': 'dart',
        'minutos': 0,
        'criada_em': 0,
      });
      await db.insert('sessoes', <String, Object?>{
        'id': 's1',
        'materia_id': 'dart',
        'inicio_em': 0,
        'minutos': 25,
      });
      await db.close();

      db = await abrirAtual();
      expect(await BancoFoco.integridadeOk(db), isTrue);
      await db.close();
    });
  });

  group('v2 → atual', () {
    test('executa só a etapa que falta', () async {
      Database db = await abrir(2, onCreate: criarEsquemaV2);
      await db.close();

      db = await abrirAtual();

      // Se _de1Para2 rodasse de novo, o ALTER TABLE lançaria
      // "duplicate column name: arquivada".
      expect(await BancoFoco.colunasDe(db, 'materias'), contains('arquivada'));
      expect(await BancoFoco.colunasDe(db, 'sessoes'), contains('anotacao'));

      await db.close();
    });
  });

  group('sem migração', () {
    test('abrir na versão atual não roda onUpgrade', () async {
      Database db = await abrirAtual();
      await db.insert('materias', <String, Object?>{
        'id': 'x',
        'nome': 'X',
        'nome_ordenacao': 'x',
        'minutos': 0,
        'criada_em': 0,
        'arquivada': 0,
      });
      await db.close();

      db = await abrirAtual();
      expect(await db.query('materias'), hasLength(1));
      await db.close();
    });

    test('banco criado do zero tem o MESMO esquema de um migrado', () async {
      // Este teste pega o erro clássico: acrescentar coluna no
      // onUpgrade e ESQUECER de acrescentá-la no onCreate.
      Database migrado = await abrir(1, onCreate: criarEsquemaV1);
      await migrado.close();
      migrado = await abrirAtual();
      final Set<String> colunasMigrado =
          await BancoFoco.colunasDe(migrado, 'materias');
      final Set<String> sessoesMigrado =
          await BancoFoco.colunasDe(migrado, 'sessoes');
      await migrado.close();

      await pasta.delete(recursive: true);
      pasta = await Directory.systemTemp.createTemp('foco_migracao_b_');
      caminho = p.join(pasta.path, 'foco.db');

      final Database novo = await abrirAtual();
      final Set<String> colunasNovo =
          await BancoFoco.colunasDe(novo, 'materias');
      final Set<String> sessoesNovo =
          await BancoFoco.colunasDe(novo, 'sessoes');
      await novo.close();

      expect(colunasNovo, colunasMigrado,
          reason: 'onCreate e onUpgrade divergiram em materias');
      expect(sessoesNovo, sessoesMigrado,
          reason: 'onCreate e onUpgrade divergiram em sessoes');
    });
  });

  group('rebaixamento', () {
    test('banco mais novo que o código é recriado, com marca', () async {
      // Usuário na versão futura do esquema.
      Database db = await abrir(
        BancoFoco.versaoAtual + 1,
        onCreate: BancoFoco.criar,
      );
      await db.insert('materias', <String, Object?>{
        'id': 'x',
        'nome': 'X',
        'nome_ordenacao': 'x',
        'minutos': 0,
        'criada_em': 0,
        'arquivada': 0,
      });
      await db.close();

      // Ele instala uma versão antiga do app.
      db = await abrirAtual();

      expect(await db.query('materias'), isEmpty,
          reason: 'o banco foi recriado');
      expect(BancoFoco.houveRebaixamento, isTrue,
          reason: 'a marca permite avisar o usuário');

      await db.close();
    });
  });
}
```

Rode:

```powershell
flutter analyze
flutter test test/migracoes_test.dart
```

> 💡 O teste **`banco criado do zero tem o MESMO esquema de um migrado`** é o mais valioso da
> suíte. Ele pega o erro que acontece em quase todo projeto: acrescentar a coluna no `onUpgrade` e
> esquecer de acrescentá-la também no `onCreate`. O bug só aparece em **instalações novas** — ou
> seja, nos usuários que você mais quer conquistar.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `static const int versaoAtual = 3;` com histórico em comentário | O comentário documenta o que cada versão mudou. Sem ele, ninguém sabe por que a versão é 3. |
| `if (de < 2) ... if (de < 3) ...` **sem `else`** | Quem vem da v1 executa **todos** os blocos. Com `else if`, ele só ganharia o primeiro — e o app quebraria. |
| `_de1Para2` marcado como **PUBLICADA** | Ela já rodou em milhares de aparelhos. Editá-la faria bancos "na mesma versão" terem estruturas diferentes. |
| `ADD COLUMN arquivada INTEGER NOT NULL DEFAULT 0` | `NOT NULL` **exige** `DEFAULT`: as linhas existentes precisam de um valor. |
| `ADD COLUMN humor INTEGER` **sem** `NOT NULL` | Uma sessão antiga não tem como ter humor. `NULL` é a resposta honesta. |
| `onCreate` já contendo `arquivada`, `anotacao` e `humor` | Instalação nova precisa terminar com o **mesmo** esquema de uma migrada. É o erro que o último teste pega. |
| `PRAGMA foreign_keys = OFF` **fora** da transação | Esse pragma não funciona dentro de transação. Precisa vir antes e depois. |
| `INSERT INTO nova (col1, col2) SELECT col1, col2` | Nomeie **todas** as colunas. `SELECT *` quebra se a ordem mudar. |
| `CREATE INDEX` depois do `RENAME` | Índices **morrem** com o `DROP TABLE`. Esquecê-los deixa o app lento **sem erro nenhum**. |
| `PRAGMA foreign_key_check` no fim | Sem essa checagem, uma migração pode deixar órfãos e o problema aparecer meses depois. |
| `houveRebaixamento = true` | O usuário perdeu os dados; ele precisa **saber**, não descobrir sozinho. |
| `onDatabaseDowngradeDelete` | Opção pronta do `sqflite`. Destrutiva, mas honesta — tentar desfazer migração dá mais errado. |
| `batch` no `preencherNomeOrdenacao` | Com 20 000 linhas, um `update` por vez trava a abertura por segundos, e o Android mata por ANR. |
| `criarEsquemaV1` no arquivo de teste | Documento **histórico**: registra o que existia no aparelho. Mudá-lo faria os testes validarem uma migração que nunca aconteceu. |
| Arquivo temporário, não `inMemoryDatabasePath` | O banco precisa **sobreviver** entre as duas aberturas. |
| `PRAGMA table_info(tabela)` | Uma linha por coluna, com `name`, `type`, `notnull`, `dflt_value`, `pk`. A ferramenta de verificação de estrutura. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Versão do SQLite | **Do sistema** — varia por versão do Android | Do sistema — mais uniforme |
| `DROP COLUMN` (3.35+) | ❌ falha em Android 11 e anteriores | ✅ em iOS 15+ |
| `RENAME COLUMN` (3.25+) | ⚠️ falha em Android 8 e anteriores | ✅ |
| Migração demorada na abertura | **ANR** se passar de ~5 s | O sistema mata o app se demorar demais |
| Atualização do app | O banco é preservado | Preservado |
| Restaurar backup em aparelho novo | Pode trazer um banco de versão antiga | Idem |

> ⚠️ **A primeira linha é a mais importante e a mais esquecida.** O SQLite vem do sistema
> operacional, não do Flutter. Um recurso que funciona no seu emulador Android 14 pode **não
> existir** no Android 9 do usuário. Se precisar de recursos modernos, use o pacote
> `sqlite3_flutter_libs`, que embute uma versão própria — ao custo de alguns MB no APK.

> ⚠️ **Migração longa = app morto.** O Android mostra "o app não está respondendo" depois de ~5
> segundos sem resposta na thread principal. Uma migração que percorre 50 000 linhas precisa de
> `batch`, e mesmo assim vale mostrar uma tela de "atualizando seus dados" — assunto do
> [Módulo 13](../13-desempenho-e-seguranca/03-assincrono-sem-travar.md).

---

## ⚠️ Erros comuns

### 1. Editar só o `onCreate`

```dart
static Future<void> criar(Database db, int v) async {
  await db.execute('CREATE TABLE materias (... arquivada INTEGER ...)');
}
// … e esquecer o onUpgrade ❌
```

```text
DatabaseException(no such column: arquivada)
```

Funciona no emulador (banco novo) e quebra em **todo** aparelho que já tinha o app.

**Correção:** toda mudança de esquema precisa de `onCreate` **e** `onUpgrade`.

### 2. Esquecer de subir a `version`

```dart
version: 1,   // ⚠️ mas o onUpgrade tem a migração para 2
```

O `onUpgrade` **nunca** é chamado.

**Correção:** `version` e migrações andam juntas.

### 3. `else if` na migração

```dart
if (de == 1) {
  await _de1Para2(db);
} else if (de == 2) {   // ❌ quem vem da 1 nunca chega aqui
  await _de2Para3(db);
}
```

Um usuário da v1 fica na v2 — mas o banco é marcado como v3. O app quebra na primeira consulta à
coluna que faltou.

**Correção:** `if (de < 2) ... if (de < 3) ...`, sem `else`.

### 4. `NOT NULL` sem `DEFAULT`

```sql
ALTER TABLE materias ADD COLUMN cor INTEGER NOT NULL;   -- ❌
```

```text
Cannot add a NOT NULL column with default value NULL
```

**Correção:** `... NOT NULL DEFAULT 0`.

### 5. Apagar o banco para "resolver"

```dart
await deleteDatabase(caminho);   // ❌ em app publicado
```

Apaga meses de dados do usuário.

**Correção:** migração. Apagar só é aceitável em desenvolvimento, antes da primeira publicação.

### 6. Editar migração já publicada

```dart
static Future<void> _de1Para2(Database db) async {
  // "vou aproveitar e corrigir aqui" ❌
}
```

Quem já migrou **não** migra de novo. Você cria duas estruturas diferentes na mesma versão.

**Correção:** escreva `_de2Para3` corrigindo.

### 7. Esquecer os índices na recriação

```dart
await txn.execute('DROP TABLE materias');
await txn.execute('ALTER TABLE materias_nova RENAME TO materias');
// … e os índices? ❌
```

O app fica lento, **sem nenhum erro**. Você só descobre quando um usuário reclama.

**Correção:** recrie todos os índices.

### 8. `SELECT *` no `INSERT ... SELECT`

```sql
INSERT INTO materias_nova SELECT * FROM materias;   -- ⚠️
```

Se a ordem das colunas diferir, os dados vão para as colunas erradas — **sem erro**, se os tipos
forem compatíveis.

**Correção:** nomeie as colunas nos dois lados.

### 9. `PRAGMA foreign_keys` dentro de transação

```dart
await db.transaction((Transaction txn) async {
  await txn.execute('PRAGMA foreign_keys = OFF');   // ❌ ignorado
```

**Correção:** antes e depois da transação.

### 10. Migração sem teste

Você só descobre que quebrou quando os usuários relatam. E aí os dados já se perderam.

**Correção:** um teste por caminho de migração (v1→atual, v2→atual…).

### 11. Backfill sem `batch`

```dart
for (final linha in vinteMilLinhas) {
  await db.update(...);   // ⚠️ segundos parado na abertura
}
```

**Correção:** `batch` + `commit(noResult: true)`.

### 12. Não avisar o rebaixamento

O usuário abre o app e todos os dados sumiram, sem explicação.

**Correção:** marque o rebaixamento e mostre uma mensagem.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test test/migracoes_test.dart` e confirme todos passando.

**Passo 2.** Troque os `if` de `atualizar` por `else if`. Rode o teste de v1 → atual. Qual falha, e
qual coluna está faltando?

**Passo 3.** Remova `arquivada` do `onCreate` (mantendo no `onUpgrade`). Qual teste pega isso?
Explique por escrito por que esse bug só aparece em **instalações novas**.

**Passo 4.** Em `_de1Para2`, remova o `DEFAULT 0`. Rode e leia a mensagem de erro inteira.

**Passo 5.** Escreva a migração `_de3Para4` que acrescenta `materias.cor INTEGER NOT NULL DEFAULT
0`. Suba a `versaoAtual` para 4, acrescente a coluna ao `onCreate`, e escreva o teste v1 → v4.

**Passo 6.** Escreva `_de4Para5` que **remove** a coluna `cor`, usando `recriarTabelaModelo`.
Confirme que os dados e os índices sobrevivem.

**Passo 7.** No `recriarTabelaModelo`, remova o `CREATE INDEX` do fim. Rode o teste de índices e
anote o que aconteceu.

**Passo 8.** Crie um banco v1 com 5 000 matérias e rode a migração medindo o tempo com `Stopwatch`.
Depois troque o `batch` do `preencherNomeOrdenacao` por `update` em laço e compare.

**Passo 9.** Force o rebaixamento (abra na `versaoAtual + 1`, feche, reabra na atual) e confirme a
marca. Depois escreva uma tela que mostre um aviso quando `houveRebaixamento` for `true`.

**Passo 10.** Responda por escrito: você publicou a v2 com um erro na migração. Mil pessoas já
atualizaram. O que você faz?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md)

Faça os exercícios de **Aplicação** com migração em etapas, o de **Correção de bugs** com `else if`,
e o de **Decisão** sobre recriar tabela × `ALTER TABLE`.

---

## 🏆 Desafio opcional

Implemente **migração em segundo plano com tela de progresso**, para bancos grandes.

Requisitos:

- A abertura do banco verifica a versão **antes** de migrar (`getVersion()`).
- Se houver migração pendente e o banco tiver mais de N linhas, o app mostra uma tela
  "Atualizando seus dados… 42%".
- O progresso é real: cada migração informa quantas etapas tem e em qual está.
- A migração roda em blocos, cedendo a thread entre eles, para o Android não matar o app por ANR.
- Se a migração falhar no meio, o banco **não** fica corrompido — o usuário pode tentar de novo.
- Um teste simula 50 000 linhas e confirma que o progresso chega a 100%.

Dica: `await databaseFactory.getDatabaseVersion(caminho)` (ou abrir com
`OpenDatabaseOptions(readOnly: true)` e ler `PRAGMA user_version`) permite saber a versão sem
disparar a migração. Para ceder a thread, `await Future<void>.delayed(Duration.zero)` entre blocos.

Depois responda: por que a migração **não** pode simplesmente rodar em um `Isolate`? (Dica: pense
em quantas conexões o SQLite aceita e no que acontece com uma transação aberta em outra thread.)

---

## 📌 Resumo

- **`onCreate` só roda quando o arquivo do banco não existe.** Editar só ele quebra o app de quem
  já o tinha instalado.
- **`version`** é a versão do **esquema**, não do app. Sobe quando a estrutura das tabelas muda.
- **`onUpgrade(db, de, para)`** leva de qualquer versão antiga à atual — **em etapas, sem `else`**.
- **Migração publicada nunca se edita.** Para corrigir, escreva a migração seguinte.
- **`onCreate` e `onUpgrade` precisam terminar no MESMO esquema.** Esse é o bug que só aparece em
  instalações novas.
- `ALTER TABLE ADD COLUMN` com `NOT NULL` **exige** `DEFAULT`.
- O `ALTER TABLE` do SQLite é limitado: não muda tipo, não altera chave, e `DROP COLUMN` **não
  existe em Android antigo**.
- Para o resto, **recrie a tabela**: pragma off → criar nova → copiar nomeando colunas → drop →
  rename → **recriar índices** → pragma on → `foreign_key_check`.
- **`PRAGMA foreign_keys` não funciona dentro de transação.**
- **Backfill** precisa de `batch`: milhares de `update` travam a abertura e causam ANR.
- **`onDowngrade`**: o curso usa `onDatabaseDowngradeDelete` — destrutivo, mas honesto. **Avise o
  usuário.**
- Teste migrações com **arquivo temporário** (não em memória) e **`PRAGMA table_info`**.
- A versão do SQLite vem **do sistema operacional** e varia entre aparelhos.

---

## ☑️ Checklist de domínio

- [ ] Explico por que editar só o `onCreate` quebra o app em produção.
- [ ] Sei que `version` é do esquema, não do app.
- [ ] Escrevo migração em etapas, com `if (de < n)` e **sem `else`**.
- [ ] Nunca edito migração já publicada.
- [ ] Garanto que `onCreate` e `onUpgrade` terminam no mesmo esquema.
- [ ] Uso `DEFAULT` em toda coluna `NOT NULL` acrescentada.
- [ ] Conheço os limites do `ALTER TABLE` do SQLite.
- [ ] Sei o procedimento de recriação de tabela, incluindo os índices.
- [ ] Sei que `PRAGMA foreign_keys` não funciona dentro de transação.
- [ ] Uso `batch` em backfill.
- [ ] Trato o rebaixamento e **aviso** o usuário.
- [ ] Testo cada caminho de migração com arquivo temporário.
- [ ] Verifico estrutura com `PRAGMA table_info` e integridade com `foreign_key_check`.

---

## 📚 Referências oficiais

- [sqflite — Migration documentation](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/migration_example.md)
- [sqflite — pub.dev](https://pub.dev/packages/sqflite)
- [ALTER TABLE — sqlite.org](https://www.sqlite.org/lang_altertable.html)
- [Making Other Kinds Of Table Schema Changes — sqlite.org](https://www.sqlite.org/lang_altertable.html#otheralter)
- [PRAGMA statements — sqlite.org](https://www.sqlite.org/pragma.html)
- [Foreign key support — sqlite.org](https://www.sqlite.org/foreignkeys.html)
- [sqlite3_flutter_libs — pub.dev](https://pub.dev/packages/sqlite3_flutter_libs)
- [ANRs — developer.android.com](https://developer.android.com/topic/performance/vitals/anr)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — sqflite: CRUD](05-sqflite-crud.md) | [README](README.md) | [Aula 7 — Dados sensíveis](07-dados-sensiveis.md) |
