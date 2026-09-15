# Aula 5 — sqflite: CRUD

> **Módulo:** 10 - Persistência de Dados · **Tempo estimado:** 60 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Inserir com **`insert`** e escolher o `ConflictAlgorithm` certo.
- Consultar com **`query`**, usando `where`, `whereArgs`, `orderBy`, `limit` e `offset`.
- Explicar o que é **SQL injection** e por que `whereArgs` não é opcional.
- Atualizar com **`update`** e remover com **`delete`**, sempre com `where`.
- Usar **`rawQuery`** e **`rawUpdate`** quando o `query` não dá conta — e saber quando não usar.
- Agrupar operações em **`transaction`** e **`batch`**, sabendo a diferença.
- Converter **`Map` ↔ modelo de domínio** sem espalhar `as` pelo código.
- Reconhecer e corrigir **o bug do `ORDER BY` em português** — acentos na ordenação.

## ✅ Pré-requisitos

- [Aula 4 — sqflite: criando o banco](04-sqflite-criando-o-banco.md) — **essencial**: o
  `BancoFoco`, o esquema e a coluna `nome_ordenacao` vêm de lá.
- [Módulo 08, aula 9 — Arquitetura feature-first](../08-estado-e-arquitetura/09-arquitetura-feature-first.md)
  — DAO fica em `data`, modelo em `domain`.
- [Módulo 09, aula 7 — Camada de dados testável](../09-consumo-de-api/07-camada-de-dados-testavel.md)
  — a mesma separação service/repositório, agora com banco.
- [Módulo 02, aula 9 — Sets e Maps](../02-dart-basico/09-sets-e-maps.md).

---

## 📖 Conceito

### As quatro operações

**CRUD** é *Create, Read, Update, Delete*. No `sqflite`, cada uma tem um método:

| Operação | Método | Devolve |
|---|---|---|
| Criar | `insert` | O `rowid` da linha inserida (`int`) |
| Ler | `query` | `List<Map<String, Object?>>` |
| Atualizar | `update` | Quantas linhas mudaram (`int`) |
| Remover | `delete` | Quantas linhas saíram (`int`) |

Todos devolvem `Future` — o banco é I/O, e I/O é assíncrono.

### `insert`

```dart
final int linhas = await db.insert(
  'materias',
  <String, Object?>{
    'id': 'dart',
    'nome': 'Dart',
    'nome_ordenacao': 'dart',
    'minutos': 0,
    'criada_em': DateTime.now().millisecondsSinceEpoch,
  },
  conflictAlgorithm: ConflictAlgorithm.abort,
);
```

O **`conflictAlgorithm`** decide o que fazer quando a inserção viola uma restrição (chave primária
duplicada, por exemplo):

| Valor | Comportamento | Use quando |
|---|---|---|
| `abort` (padrão) | **Lança exceção** | Você quer saber que houve duplicata |
| `replace` | Apaga a linha antiga e insere a nova | Sincronizar com servidor: "esta é a verdade" |
| `ignore` | Não faz nada, sem erro | Inserir só se não existir |
| `fail` | Lança, mas mantém alterações anteriores do comando | Raro |
| `rollback` | Desfaz a transação inteira | Dentro de transação, quando tudo-ou-nada |

> ⚠️ **`replace` apaga e reinsere.** Se houver uma chave estrangeira com `ON DELETE CASCADE`
> apontando para aquela linha, **os filhos são apagados junto**. Substituir uma matéria com
> `replace` apagaria todas as sessões dela — silenciosamente. Para atualizar, use `update`.

### `query` e os argumentos

```dart
final List<Map<String, Object?>> linhas = await db.query(
  'sessoes',
  columns: <String>['id', 'minutos', 'inicio_em'],   // só o que precisa
  where: 'materia_id = ? AND inicio_em >= ?',
  whereArgs: <Object?>[materiaId, inicioDoDia],
  orderBy: 'inicio_em DESC',
  limit: 50,
  offset: 0,
);
```

| Parâmetro | Para quê |
|---|---|
| `columns` | Quais colunas trazer. Omitir traz todas |
| `where` | A condição, com `?` no lugar dos valores |
| `whereArgs` | Os valores, na ordem dos `?` |
| `orderBy` | Ordenação: `'nome ASC'`, `'criada_em DESC'` |
| `limit` / `offset` | Paginação |
| `groupBy` / `having` | Agregação |
| `distinct` | Remove duplicatas |

> 💡 **`columns` importa.** Uma tabela com um campo de texto longo (uma anotação de 2 000
> caracteres) desperdiça memória quando você só queria o título. Traga o que vai usar.

### SQL injection: por que `whereArgs` não é opcional

Esta é a parte mais importante da aula em termos de segurança.

```dart
// ❌ NUNCA faça isto
final busca = campoDeTexto.text;
await db.query('materias', where: "nome = '$busca'");
```

Se o usuário digitar `'; DELETE FROM materias; --`, a consulta vira:

```sql
SELECT * FROM materias WHERE nome = ''; DELETE FROM materias; --'
```

E o banco **apaga tudo**. Isso é **SQL injection**.

```dart
// ✅ sempre assim
await db.query('materias', where: 'nome = ?', whereArgs: <Object?>[busca]);
```

Com `whereArgs`, o valor **nunca** é interpretado como SQL. O banco recebe a consulta e os valores
**separadamente**, e o valor é sempre tratado como dado — mesmo que contenha aspas, ponto e vírgula
ou comandos inteiros.

> ⚠️ Vale para **todos** os valores: `where`, `rawQuery`, `rawUpdate`. E vale mesmo quando o valor
> "vem do seu código": um dia ele vai vir do usuário, de um arquivo importado ou de uma API.

Um detalhe que confunde: **o nome da tabela e da coluna não podem ser parametrizados.**

```dart
await db.query('?', whereArgs: <Object?>[tabela]);   // ❌ não funciona
```

Se o nome da coluna for dinâmico (uma ordenação escolhida pelo usuário), valide contra uma **lista
branca**:

```dart
const Set<String> colunasPermitidas = <String>{'nome_ordenacao', 'minutos', 'criada_em'};
final String coluna = colunasPermitidas.contains(escolha) ? escolha : 'nome_ordenacao';
await db.query('materias', orderBy: '$coluna ASC');   // ✅ valor validado
```

### `update` e `delete`

```dart
final int alteradas = await db.update(
  'materias',
  <String, Object?>{'minutos': 120},
  where: 'id = ?',
  whereArgs: <Object?>[id],
);

final int removidas = await db.delete(
  'sessoes',
  where: 'inicio_em < ?',
  whereArgs: <Object?>[limite],
);
```

> ⚠️ **`update` e `delete` sem `where` afetam a tabela inteira.** `await db.delete('materias')`
> apaga tudo, sem confirmação, sem aviso. O `sqflite` não protege você disso.

O retorno é o número de linhas afetadas — use-o:

```dart
final int alteradas = await db.update(...);
if (alteradas == 0) throw MateriaNaoEncontrada(id);
```

### `rawQuery` e `rawUpdate`

Quando o `query` não dá conta — `JOIN`, agregação com expressão, subconsulta:

```dart
final List<Map<String, Object?>> resumo = await db.rawQuery(
  '''
  SELECT m.id, m.nome, COUNT(s.id) AS total_sessoes, COALESCE(SUM(s.minutos), 0) AS minutos
  FROM materias m
  LEFT JOIN sessoes s ON s.materia_id = m.id
  WHERE s.inicio_em >= ? OR s.inicio_em IS NULL
  GROUP BY m.id
  ORDER BY m.nome_ordenacao
  ''',
  <Object?>[inicioDaSemana],   // os ? continuam obrigatórios
);
```

| | `query` | `rawQuery` |
|---|---|---|
| Tabela única | ✅ | ✅ |
| `JOIN` | ❌ | ✅ |
| Agregação (`SUM`, `COUNT`) | ⚠️ limitada | ✅ |
| Subconsulta | ❌ | ✅ |
| Risco de erro de digitação | Baixo | **Alto** — o erro só aparece em execução |

**Prefira `query`.** Use `raw` quando precisar de verdade — e, quando usar, **teste**, porque um
erro de SQL não é pego pelo compilador.

### `transaction` × `batch`

Duas formas de agrupar operações, com propósitos **diferentes**:

**`transaction` — tudo ou nada (atomicidade).**

```dart
await db.transaction((Transaction txn) async {
  await txn.insert('sessoes', dadosDaSessao);
  await txn.update(
    'materias',
    <String, Object?>{'minutos': novoTotal},
    where: 'id = ?',
    whereArgs: <Object?>[materiaId],
  );
});
```

Se qualquer operação falhar, **todas** são desfeitas. Use quando as operações formam uma unidade:
registrar a sessão **e** atualizar o total é uma coisa só — o banco nunca pode ficar com uma e não
a outra.

**`batch` — muitas operações de uma vez (desempenho).**

```dart
final Batch lote = db.batch();
for (final Materia m in materias) {
  lote.insert('materias', m.paraLinha(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}
await lote.commit(noResult: true);
```

Envia todas as operações ao banco **de uma vez**, em vez de uma ida e volta por operação. Inserir
500 linhas com `batch` é ordens de grandeza mais rápido.

| | `transaction` | `batch` |
|---|---|---|
| Objetivo | **Atomicidade** | **Desempenho** |
| Desfaz tudo se falhar | ✅ | ⚠️ só dentro de transação |
| Lê resultados intermediários | ✅ | ❌ |
| Muitas operações iguais | Funciona, mas lento | **Ideal** |

E os dois juntos, para importação grande:

```dart
await db.transaction((Transaction txn) async {
  final Batch lote = txn.batch();
  for (final Materia m in materias) {
    lote.insert('materias', m.paraLinha());
  }
  await lote.commit(noResult: true);
});
```

> ⚠️ **Dentro de uma `transaction`, use sempre o `txn`, nunca o `db`.** Usar `db` dentro do bloco
> abre uma segunda conexão que espera a transação terminar — e a transação espera a operação. O app
> **trava**, sem erro.

### `Map` ↔ modelo

O banco fala `Map<String, Object?>`; o app fala `Materia`. A conversão fica **no modelo**, em dois
métodos:

```dart
factory Materia.deLinha(Map<String, Object?> linha) => Materia(
      id: linha['id']! as String,
      nome: linha['nome']! as String,
      minutos: linha['minutos']! as int,
      criadaEm: DateTime.fromMillisecondsSinceEpoch(linha['criada_em']! as int),
    );

Map<String, Object?> paraLinha() => <String, Object?>{
      'id': id,
      'nome': nome,
      'nome_ordenacao': Texto.paraOrdenacao(nome),
      'minutos': minutos,
      'criada_em': criadaEm.millisecondsSinceEpoch,
    };
```

Dois cuidados:

1. **Datas viram `int`.** O SQLite não tem tipo de data. Guarde `millisecondsSinceEpoch` — é
   ordenável, comparável e não tem fuso ambíguo.
2. **Booleanos viram `0`/`1`.** O SQLite não tem `BOOLEAN`. Converta nos dois sentidos:
   `linha['ativo'] == 1`.

### O bug do `ORDER BY` em português

Este é o bug que a aula 4 antecipou com a coluna `nome_ordenacao`, e agora ele aparece.

```dart
await db.query('materias', orderBy: 'nome ASC');
```

Com os nomes `Álgebra`, `Biologia`, `Cálculo`, `Zoologia`, o resultado é:

```text
Biologia
Zoologia
Álgebra     ← ?!
Cálculo     ← ?!
```

**Por quê:** o SQLite ordena por **código de caractere**. Em UTF-8, `Á` (U+00C1) e `á` (U+00E1) vêm
**depois** de todas as letras sem acento (`A`–`Z`, `a`–`z`). E, pior, `a` (97) vem depois de `Z`
(90) — então `Zoologia` viria antes de `algebra` numa ordenação sensível a maiúsculas.

O `COLLATE NOCASE` do SQLite resolve a segunda parte, mas **só para ASCII** — ele não sabe nada de
acentos.

**A solução:** uma coluna auxiliar com o texto **normalizado** — minúsculo e sem acento — e ordenar
por ela.

```dart
// Na inserção:
'nome_ordenacao': Texto.paraOrdenacao(nome),   // 'Álgebra' → 'algebra'

// Na consulta:
orderBy: 'nome_ordenacao ASC'
```

Resultado correto:

```text
Álgebra
Biologia
Cálculo
Zoologia
```

E o mesmo vale para **busca**: procurar "calculo" precisa encontrar "Cálculo".

```dart
where: 'nome_ordenacao LIKE ?',
whereArgs: <Object?>['%${Texto.paraOrdenacao(termo)}%'],
```

> 📌 Esse é o tipo de detalhe que passa despercebido em um app em inglês e aparece no **primeiro
> dia** de uso em português. É por isso que a coluna existe desde a aula 4.

---

## 💡 Analogia

Pense num arquivo físico de fichas.

- **`insert`** é arquivar uma ficha nova. O **`conflictAlgorithm`** é a regra para quando já existe
  uma ficha com aquele número: `abort` é recusar e avisar; `ignore` é deixar a antiga e seguir;
  **`replace` é rasgar a antiga e pôr a nova** — e, se havia documentos grampeados nela (as sessões,
  pela chave estrangeira), eles vão para o lixo junto.
- **`query`** é pedir fichas ao arquivista. **`columns`** é dizer "só quero o nome, não precisa
  trazer o processo inteiro". **`where`** é o critério.
- **`whereArgs`** é a diferença entre **entregar um papel com o nome escrito** e **ditar a frase
  para o arquivista escrever**. No segundo caso, se você ditar "João — e agora queime o arquivo", o
  arquivista obedece. O papel entregue é sempre tratado como **nome**, nunca como instrução. Isso é
  SQL injection.
- **`update` e `delete` sem `where`** é dizer "atualize as fichas" sem dizer quais. O arquivista
  atualiza **todas**.
- **`transaction`** é o envelope lacrado: ou todas as fichas dele entram no arquivo, ou nenhuma. Se
  a terceira ficha estiver rasgada, as duas primeiras voltam.
- **`batch`** é levar as 500 fichas **de uma vez** em vez de uma viagem por ficha. A economia não
  está no arquivamento; está nas 499 caminhadas que você não fez.
- **O bug do `ORDER BY`** é o arquivista ordenar pela **forma da letra** e não pelo alfabeto: para
  ele, `Á` é um símbolo estranho que vai lá no fim da gaveta, depois do `Z`. A coluna
  `nome_ordenacao` é você escrever, no canto da ficha e a lápis, o nome "achatado" — sem acento,
  minúsculo — e pedir que ele ordene **por aquilo**.

---

## 🧪 Exemplo mínimo

CRUD completo, rodando **no Windows**, sem emulador.

> **Arquivo:** `foco_dados/test/exemplo_crud_test.dart` (temporário)
> **Instale antes:** `flutter pub add --dev sqflite_common_ffi`
> **Como executar:** `flutter test test/exemplo_crud_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // sqflite_common_ffi: roda o SQLite de verdade no desktop.
  // É o que permite testar a camada de dados inteira no Windows,
  // sem emulador e sem aparelho.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;

  setUp(() async {
    // inMemoryDatabasePath: cada teste ganha um banco novo, na memória.
    // Nada fica no disco entre testes.
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (Database db) async {
          // Sem esta linha, ON DELETE CASCADE não acontece.
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (Database db, int v) async {
          await db.execute(
            'CREATE TABLE materias ('
            '  id TEXT PRIMARY KEY,'
            '  nome TEXT NOT NULL,'
            '  nome_ordenacao TEXT NOT NULL,'
            '  minutos INTEGER NOT NULL DEFAULT 0'
            ')',
          );
          await db.execute(
            'CREATE TABLE sessoes ('
            '  id TEXT PRIMARY KEY,'
            '  materia_id TEXT NOT NULL,'
            '  minutos INTEGER NOT NULL,'
            '  FOREIGN KEY (materia_id) REFERENCES materias (id)'
            '    ON DELETE CASCADE'
            ')',
          );
        },
      ),
    );
  });

  tearDown(() => db.close());

  Future<void> inserirMateria(String id, String nome) {
    return db.insert('materias', <String, Object?>{
      'id': id,
      'nome': nome,
      // A coluna achatada: minúscula e sem acento.
      'nome_ordenacao': _paraOrdenacao(nome),
      'minutos': 0,
    });
  }

  group('insert', () {
    test('insere e devolve o rowid', () async {
      final int rowid = await inserirMateria('dart', 'Dart');
      expect(rowid, greaterThan(0));
    });

    test('id duplicado com abort lança', () async {
      await inserirMateria('dart', 'Dart');

      await expectLater(
        inserirMateria('dart', 'Dart de novo'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('replace substitui — E APAGA OS FILHOS', () async {
      await inserirMateria('dart', 'Dart');
      await db.insert('sessoes', <String, Object?>{
        'id': 's1',
        'materia_id': 'dart',
        'minutos': 25,
      });

      // replace APAGA a linha antiga antes de inserir. O ON DELETE
      // CASCADE dispara, e a sessão vai junto — silenciosamente.
      await db.insert(
        'materias',
        <String, Object?>{
          'id': 'dart',
          'nome': 'Dart 3',
          'nome_ordenacao': 'dart 3',
          'minutos': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final List<Map<String, Object?>> sessoes = await db.query('sessoes');
      expect(sessoes, isEmpty, reason: 'replace apagou a sessão junto!');
    });

    test('update preserva os filhos', () async {
      await inserirMateria('dart', 'Dart');
      await db.insert('sessoes', <String, Object?>{
        'id': 's1',
        'materia_id': 'dart',
        'minutos': 25,
      });

      await db.update(
        'materias',
        <String, Object?>{'nome': 'Dart 3'},
        where: 'id = ?',
        whereArgs: <Object?>['dart'],
      );

      expect(await db.query('sessoes'), hasLength(1));
    });
  });

  group('SQL injection', () {
    test('whereArgs trata o valor como DADO, nunca como comando', () async {
      await inserirMateria('dart', 'Dart');
      await inserirMateria('flutter', 'Flutter');

      // O que um usuário mal-intencionado digitaria na busca.
      const String maldoso = "'; DELETE FROM materias; --";

      final List<Map<String, Object?>> r = await db.query(
        'materias',
        where: 'nome = ?',
        whereArgs: <Object?>[maldoso],
      );

      // Nenhuma matéria se chama assim: resultado vazio.
      expect(r, isEmpty);
      // E, o que importa: as duas matérias CONTINUAM lá.
      expect(await db.query('materias'), hasLength(2));
    });
  });

  group('o bug do ORDER BY em português', () {
    setUp(() async {
      for (final String nome in <String>[
        'Zoologia',
        'Álgebra',
        'Biologia',
        'Cálculo',
      ]) {
        await inserirMateria(nome.toLowerCase(), nome);
      }
    });

    test('❌ ordenar por "nome" joga os acentuados para o fim', () async {
      final List<Map<String, Object?>> r =
          await db.query('materias', orderBy: 'nome ASC');
      final List<String> nomes =
          r.map((Map<String, Object?> l) => l['nome']! as String).toList();

      // O SQLite ordena por código de caractere: Á (U+00C1) vem
      // DEPOIS de todas as letras sem acento.
      expect(nomes, <String>['Biologia', 'Zoologia', 'Álgebra', 'Cálculo']);
    });

    test('✅ ordenar por "nome_ordenacao" fica correto', () async {
      final List<Map<String, Object?>> r =
          await db.query('materias', orderBy: 'nome_ordenacao ASC');
      final List<String> nomes =
          r.map((Map<String, Object?> l) => l['nome']! as String).toList();

      expect(nomes, <String>['Álgebra', 'Biologia', 'Cálculo', 'Zoologia']);
    });

    test('busca sem acento encontra o nome COM acento', () async {
      final List<Map<String, Object?>> r = await db.query(
        'materias',
        where: 'nome_ordenacao LIKE ?',
        whereArgs: <Object?>['%${_paraOrdenacao("calculo")}%'],
      );

      expect(r.single['nome'], 'Cálculo');
    });
  });

  group('transaction e batch', () {
    test('transaction desfaz tudo se algo falhar', () async {
      await inserirMateria('dart', 'Dart');

      await expectLater(
        db.transaction((Transaction txn) async {
          await txn.update(
            'materias',
            <String, Object?>{'minutos': 100},
            where: 'id = ?',
            whereArgs: <Object?>['dart'],
          );
          // Falha de propósito: materia_id não existe.
          await txn.insert('sessoes', <String, Object?>{
            'id': 's1',
            'materia_id': 'inexistente',
            'minutos': 25,
          });
        }),
        throwsA(isA<DatabaseException>()),
      );

      // O update foi DESFEITO: minutos continua 0.
      final List<Map<String, Object?>> r =
          await db.query('materias', where: 'id = ?', whereArgs: <Object?>['dart']);
      expect(r.single['minutos'], 0);
    });

    test('batch insere muitas linhas de uma vez', () async {
      final Batch lote = db.batch();
      for (int i = 0; i < 300; i++) {
        lote.insert('materias', <String, Object?>{
          'id': 'm$i',
          'nome': 'Matéria $i',
          'nome_ordenacao': 'materia $i',
          'minutos': 0,
        });
      }
      // noResult: true descarta os retornos — mais rápido quando
      // você não precisa dos rowids.
      await lote.commit(noResult: true);

      final List<Map<String, Object?>> r =
          await db.rawQuery('SELECT COUNT(*) AS total FROM materias');
      expect(r.single['total'], 300);
    });
  });

  group('rawQuery com JOIN', () {
    test('soma minutos por matéria', () async {
      await inserirMateria('dart', 'Dart');
      await inserirMateria('git', 'Git');

      for (final (String id, String materia, int min) in <(String, String, int)>[
        ('s1', 'dart', 25),
        ('s2', 'dart', 50),
        ('s3', 'git', 15),
      ]) {
        await db.insert('sessoes', <String, Object?>{
          'id': id,
          'materia_id': materia,
          'minutos': min,
        });
      }

      final List<Map<String, Object?>> r = await db.rawQuery('''
        SELECT m.nome, COALESCE(SUM(s.minutos), 0) AS total
        FROM materias m
        LEFT JOIN sessoes s ON s.materia_id = m.id
        GROUP BY m.id
        ORDER BY m.nome_ordenacao
      ''');

      expect(r.map((Map<String, Object?> l) => l['total']).toList(),
          <int>[75, 15]);
    });
  });
}

/// Achata o texto para ordenação e busca: minúsculo e sem acento.
String _paraOrdenacao(String texto) {
  const String comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const String semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

  final StringBuffer buffer = StringBuffer();
  for (final String caractere in texto.split('')) {
    final int indice = comAcento.indexOf(caractere);
    buffer.write(indice >= 0 ? semAcento[indice] : caractere);
  }
  return buffer.toString().toLowerCase().trim();
}
```

```powershell
flutter pub add --dev sqflite_common_ffi
flutter test test/exemplo_crud_test.dart
```

**Os dois testes que mais ensinam:**

- **`replace substitui — E APAGA OS FILHOS`**: a sessão some sem nenhum erro. É o comportamento
  correto do SQLite, e a fonte de perda de dados mais silenciosa desta aula.
- **`❌ ordenar por "nome"`**: `Álgebra` depois de `Zoologia`. Rode e veja com os próprios olhos.

---

## 📱 Aplicando no Flutter

Agora o `foco_dados` ganha o DAO completo de matérias e sessões:

- `features/materias/domain/materia.dart` — modelo com `deLinha` / `paraLinha`;
- `features/materias/data/materia_dao.dart` — todo o CRUD;
- `features/sessoes/data/sessao_dao.dart` — sessões, com transação;
- `features/materias/data/materia_repositorio.dart` — o contrato do
  [Módulo 09](../09-consumo-de-api/07-camada-de-dados-testavel.md), agora com banco.

---

## 💻 Código completo

> **Arquivo:** `foco_dados/lib/features/materias/domain/materia.dart` (novo)
> **Como executar:** `flutter test`

```dart
import 'package:foco_dados/core/banco/texto.dart';

/// Uma matéria de estudo.
///
/// Camada de DOMÍNIO: nenhum import de sqflite, de Flutter ou de HTTP.
/// A conversão de/para linha de banco fica aqui porque é a tradução
/// de um formato de armazenamento — não conhecimento do banco em si.
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    this.minutos = 0,
    required this.criadaEm,
    this.arquivada = false,
  });

  /// Constrói a partir de uma linha do banco.
  ///
  /// Repare nos dois cuidados de tipo do SQLite:
  /// - datas são INTEGER (millisecondsSinceEpoch);
  /// - booleanos são INTEGER 0/1.
  factory Materia.deLinha(Map<String, Object?> linha) {
    return Materia(
      id: linha['id']! as String,
      nome: linha['nome']! as String,
      minutos: linha['minutos']! as int,
      criadaEm:
          DateTime.fromMillisecondsSinceEpoch(linha['criada_em']! as int),
      // O SQLite não tem BOOLEAN: 0/1 vira bool aqui.
      arquivada: (linha['arquivada'] as int? ?? 0) == 1,
    );
  }

  final String id;
  final String nome;
  final int minutos;
  final DateTime criadaEm;
  final bool arquivada;

  /// Converte para uma linha do banco.
  ///
  /// O `nome_ordenacao` é derivado AQUI, num lugar só. Deixar isso a
  /// cargo de quem chama garantiria que um dia alguém esqueceria — e a
  /// matéria ficaria fora de ordem na lista, sem erro nenhum.
  Map<String, Object?> paraLinha() => <String, Object?>{
        'id': id,
        'nome': nome,
        'nome_ordenacao': Texto.paraOrdenacao(nome),
        'minutos': minutos,
        'criada_em': criadaEm.millisecondsSinceEpoch,
        'arquivada': arquivada ? 1 : 0,
      };

  Materia copyWith({
    String? id,
    String? nome,
    int? minutos,
    DateTime? criadaEm,
    bool? arquivada,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      minutos: minutos ?? this.minutos,
      criadaEm: criadaEm ?? this.criadaEm,
      arquivada: arquivada ?? this.arquivada,
    );
  }

  @override
  bool operator ==(Object outro) =>
      outro is Materia &&
      outro.id == id &&
      outro.nome == nome &&
      outro.minutos == minutos &&
      outro.criadaEm == criadaEm &&
      outro.arquivada == arquivada;

  @override
  int get hashCode => Object.hash(id, nome, minutos, criadaEm, arquivada);

  @override
  String toString() => 'Materia($id, $nome, $minutos min)';
}
```

> **Arquivo:** `foco_dados/lib/features/materias/data/materia_dao.dart` (novo)

```dart
import 'package:sqflite/sqflite.dart';

import 'package:foco_dados/core/banco/texto.dart';
import 'package:foco_dados/features/materias/domain/materia.dart';

/// Ordenações permitidas na listagem.
///
/// Existe porque o nome de coluna **não pode** ser parametrizado com `?`.
/// Um enum fechado é a lista branca: nenhum texto do usuário chega
/// ao `orderBy`.
enum OrdemDeMaterias {
  nome('nome_ordenacao ASC'),
  maisEstudadas('minutos DESC, nome_ordenacao ASC'),
  maisRecentes('criada_em DESC');

  const OrdemDeMaterias(this.clausula);

  /// Vai direto para o `orderBy`. Por ser `const` e vir de um enum,
  /// é impossível um valor de usuário chegar aqui.
  final String clausula;
}

/// Acesso à tabela `materias`.
///
/// O DAO recebe o `Database` pelo construtor (injeção, Módulo 08 aula 10),
/// e não o abre por conta própria. É isso que permite ao teste passar um
/// banco em memória.
class MateriaDao {
  const MateriaDao(this._db);

  final DatabaseExecutor _db;

  static const String tabela = 'materias';

  // ── Criar ─────────────────────────────────────────────────────────────────

  /// Insere. Lança se o id já existir.
  ///
  /// `abort` (o padrão) em vez de `replace`: replace APAGA a linha antiga,
  /// e o ON DELETE CASCADE levaria todas as sessões da matéria junto.
  Future<void> inserir(Materia materia) async {
    await _db.insert(
      tabela,
      materia.paraLinha(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Insere ou substitui — use só para sincronização, quando o
  /// servidor é a fonte da verdade.
  ///
  /// ⚠️ Apaga as sessões da matéria por causa do CASCADE.
  Future<void> inserirOuSubstituir(Materia materia) async {
    await _db.insert(
      tabela,
      materia.paraLinha(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Ler ───────────────────────────────────────────────────────────────────

  Future<List<Materia>> listar({
    OrdemDeMaterias ordem = OrdemDeMaterias.nome,
    bool incluirArquivadas = false,
    int? limite,
  }) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: incluirArquivadas ? null : 'arquivada = ?',
      whereArgs: incluirArquivadas ? null : <Object?>[0],
      // A cláusula vem do ENUM, nunca de texto do usuário.
      orderBy: ordem.clausula,
      limit: limite,
    );

    return linhas.map(Materia.deLinha).toList();
  }

  Future<Materia?> porId(String id) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'id = ?',
      // whereArgs SEMPRE. Sem ele, um id vindo de fora poderia
      // carregar comandos SQL.
      whereArgs: <Object?>[id],
      limit: 1,
    );

    return linhas.isEmpty ? null : Materia.deLinha(linhas.first);
  }

  /// Busca por nome, ignorando acentos e maiúsculas.
  ///
  /// Procurar "calculo" precisa encontrar "Cálculo" — e é a coluna
  /// achatada que torna isso possível.
  Future<List<Materia>> buscar(String termo) async {
    final String alvo = Texto.paraOrdenacao(termo);
    if (alvo.isEmpty) return listar();

    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'nome_ordenacao LIKE ? AND arquivada = 0',
      // O % faz parte do VALOR, não da consulta: continua parametrizado.
      whereArgs: <Object?>['%$alvo%'],
      orderBy: OrdemDeMaterias.nome.clausula,
      limit: 50,
    );

    return linhas.map(Materia.deLinha).toList();
  }

  Future<int> contar({bool incluirArquivadas = false}) async {
    // COUNT(*) devolve uma linha com uma coluna. firstIntValue é o
    // atalho do sqflite para esse caso, e trata o null.
    final List<Map<String, Object?>> linhas = await _db.rawQuery(
      incluirArquivadas
          ? 'SELECT COUNT(*) FROM $tabela'
          : 'SELECT COUNT(*) FROM $tabela WHERE arquivada = 0',
    );
    return Sqflite.firstIntValue(linhas) ?? 0;
  }

  // ── Atualizar ─────────────────────────────────────────────────────────────

  /// Atualiza. Devolve quantas linhas mudaram — 0 significa "não existe".
  Future<int> atualizar(Materia materia) {
    return _db.update(
      tabela,
      materia.paraLinha(),
      where: 'id = ?',
      whereArgs: <Object?>[materia.id],
    );
  }

  /// Soma minutos, sem ler antes.
  ///
  /// `rawUpdate` com `minutos = minutos + ?` é uma operação ATÔMICA do
  /// banco: ler, somar e gravar em Dart abriria espaço para duas
  /// atualizações simultâneas se perderem.
  Future<int> somarMinutos(String id, int minutos) {
    return _db.rawUpdate(
      'UPDATE $tabela SET minutos = minutos + ? WHERE id = ?',
      <Object?>[minutos, id],
    );
  }

  Future<int> arquivar(String id, {bool arquivada = true}) {
    return _db.update(
      tabela,
      <String, Object?>{'arquivada': arquivada ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  // ── Remover ───────────────────────────────────────────────────────────────

  /// Remove a matéria — e, por CASCADE, todas as sessões dela.
  Future<int> excluir(String id) {
    return _db.delete(
      tabela,
      // O where NÃO é opcional: sem ele, delete apaga a tabela inteira.
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  // ── Em lote ───────────────────────────────────────────────────────────────

  /// Importa muitas matérias de uma vez.
  ///
  /// batch envia tudo numa ida ao banco; sem ele seriam N idas e voltas.
  /// A transação garante que o conjunto entre inteiro ou não entre.
  Future<void> importar(List<Materia> materias) async {
    if (materias.isEmpty) return;

    final Database db = _db as Database;
    await db.transaction((Transaction txn) async {
      final Batch lote = txn.batch();
      for (final Materia m in materias) {
        lote.insert(
          tabela,
          m.paraLinha(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      // noResult: true descarta os rowids — mais rápido quando não
      // precisamos deles.
      await lote.commit(noResult: true);
    });
  }
}
```

> **Arquivo:** `foco_dados/lib/features/sessoes/data/sessao_dao.dart` (novo)

```dart
import 'package:sqflite/sqflite.dart';

import 'package:foco_dados/features/materias/data/materia_dao.dart';
import 'package:foco_dados/features/sessoes/domain/sessao.dart';

/// Acesso à tabela `sessoes`.
class SessaoDao {
  const SessaoDao(this._db);

  final DatabaseExecutor _db;

  static const String tabela = 'sessoes';

  /// Registra uma sessão E atualiza o total da matéria.
  ///
  /// As duas operações formam UMA unidade: o banco nunca pode ficar com
  /// a sessão registrada e o total desatualizado. Por isso, transação.
  ///
  /// Observe que tudo aqui usa `txn`, nunca `_db`. Usar `_db` dentro do
  /// bloco abriria uma segunda conexão que espera a transação terminar —
  /// e a transação espera a operação. O app TRAVA, sem erro nenhum.
  Future<void> registrar(Sessao sessao) async {
    final Database db = _db as Database;

    await db.transaction((Transaction txn) async {
      await txn.insert(
        tabela,
        sessao.paraLinha(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      await txn.rawUpdate(
        'UPDATE ${MateriaDao.tabela} '
        'SET minutos = minutos + ? WHERE id = ?',
        <Object?>[sessao.minutos, sessao.materiaId],
      );
    });
  }

  /// Remove uma sessão E desconta os minutos.
  Future<void> remover(String id) async {
    final Database db = _db as Database;

    await db.transaction((Transaction txn) async {
      // Lê ANTES de apagar: precisamos dos minutos para descontar.
      // Isto é possível numa transaction e NÃO seria num batch.
      final List<Map<String, Object?>> linhas = await txn.query(
        tabela,
        columns: <String>['materia_id', 'minutos'],
        where: 'id = ?',
        whereArgs: <Object?>[id],
        limit: 1,
      );
      if (linhas.isEmpty) return;

      final String materiaId = linhas.first['materia_id']! as String;
      final int minutos = linhas.first['minutos']! as int;

      await txn.delete(tabela, where: 'id = ?', whereArgs: <Object?>[id]);

      // MAX(0, ...) impede total negativo se algo já estiver inconsistente.
      await txn.rawUpdate(
        'UPDATE ${MateriaDao.tabela} '
        'SET minutos = MAX(0, minutos - ?) WHERE id = ?',
        <Object?>[minutos, materiaId],
      );
    });
  }

  Future<List<Sessao>> daMateria(String materiaId, {int limite = 100}) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'materia_id = ?',
      whereArgs: <Object?>[materiaId],
      orderBy: 'inicio_em DESC',
      limit: limite,
    );
    return linhas.map(Sessao.deLinha).toList();
  }

  Future<List<Sessao>> noPeriodo(DateTime de, DateTime ate) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'inicio_em >= ? AND inicio_em < ?',
      // Datas são INTEGER no SQLite: comparáveis e ordenáveis.
      whereArgs: <Object?>[
        de.millisecondsSinceEpoch,
        ate.millisecondsSinceEpoch,
      ],
      orderBy: 'inicio_em DESC',
    );
    return linhas.map(Sessao.deLinha).toList();
  }

  /// Resumo por matéria no período.
  ///
  /// Este é o caso em que `query` não serve: há JOIN e agregação.
  /// Quando usar `rawQuery`, TESTE — um erro de SQL não é pego pelo
  /// compilador, só em execução.
  Future<List<ResumoDeMateria>> resumoPorMateria(DateTime desde) async {
    final List<Map<String, Object?>> linhas = await _db.rawQuery(
      '''
      SELECT
        m.id           AS materia_id,
        m.nome         AS nome,
        COUNT(s.id)    AS total_sessoes,
        COALESCE(SUM(s.minutos), 0) AS total_minutos
      FROM ${MateriaDao.tabela} m
      LEFT JOIN $tabela s
        ON s.materia_id = m.id AND s.inicio_em >= ?
      WHERE m.arquivada = 0
      GROUP BY m.id
      ORDER BY total_minutos DESC, m.nome_ordenacao ASC
      ''',
      // Os ? continuam obrigatórios no rawQuery.
      <Object?>[desde.millisecondsSinceEpoch],
    );

    return linhas.map(ResumoDeMateria.deLinha).toList();
  }

  /// Apaga sessões antigas. Útil para limitar o tamanho do banco.
  Future<int> limparAnterioresA(DateTime limite) {
    return _db.delete(
      tabela,
      where: 'inicio_em < ?',
      whereArgs: <Object?>[limite.millisecondsSinceEpoch],
    );
  }
}

/// Resultado do resumo. Não é uma tabela — é uma projeção.
class ResumoDeMateria {
  const ResumoDeMateria({
    required this.materiaId,
    required this.nome,
    required this.totalSessoes,
    required this.totalMinutos,
  });

  factory ResumoDeMateria.deLinha(Map<String, Object?> linha) {
    return ResumoDeMateria(
      materiaId: linha['materia_id']! as String,
      nome: linha['nome']! as String,
      totalSessoes: linha['total_sessoes']! as int,
      // COALESCE garante que nunca vem null, mas o cast defensivo
      // protege de uma mudança futura na consulta.
      totalMinutos: (linha['total_minutos'] as int?) ?? 0,
    );
  }

  final String materiaId;
  final String nome;
  final int totalSessoes;
  final int totalMinutos;

  double get mediaPorSessao =>
      totalSessoes == 0 ? 0 : totalMinutos / totalSessoes;
}
```

> **Arquivo:** `foco_dados/test/materia_dao_test.dart` (novo)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:foco_dados/core/banco/banco_foco.dart';
import 'package:foco_dados/features/materias/data/materia_dao.dart';
import 'package:foco_dados/features/materias/domain/materia.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late MateriaDao dao;

  setUp(() async {
    // Banco novo em memória a cada teste: nenhum vazamento de estado.
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: BancoFoco.versaoAtual,
        onConfigure: BancoFoco.configurar,
        onCreate: BancoFoco.criar,
      ),
    );
    dao = MateriaDao(db);
  });

  tearDown(() => db.close());

  Materia nova(String id, String nome, {int minutos = 0}) => Materia(
        id: id,
        nome: nome,
        minutos: minutos,
        criadaEm: DateTime(2026, 3, 10),
      );

  group('inserir e ler', () {
    test('insere e recupera', () async {
      await dao.inserir(nova('dart', 'Dart'));

      final Materia? m = await dao.porId('dart');
      expect(m?.nome, 'Dart');
      expect(m?.minutos, 0);
    });

    test('id duplicado lança', () async {
      await dao.inserir(nova('dart', 'Dart'));
      await expectLater(
        dao.inserir(nova('dart', 'Outro')),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('porId devolve null quando não existe', () async {
      expect(await dao.porId('fantasma'), isNull);
    });

    test('a data sobrevive à ida e volta', () async {
      final DateTime quando = DateTime(2026, 3, 10, 14, 30);
      await dao.inserir(Materia(
        id: 'x',
        nome: 'X',
        criadaEm: quando,
      ));

      final Materia? m = await dao.porId('x');
      expect(m?.criadaEm, quando);
    });
  });

  group('ordenação em português', () {
    setUp(() async {
      for (final String nome in <String>[
        'Zoologia',
        'Álgebra',
        'Biologia',
        'Cálculo',
        'Ética',
      ]) {
        await dao.inserir(nova(nome.toLowerCase(), nome));
      }
    });

    test('lista em ordem alfabética CORRETA, com acentos', () async {
      final List<Materia> lista = await dao.listar();

      expect(
        lista.map((Materia m) => m.nome).toList(),
        <String>['Álgebra', 'Biologia', 'Cálculo', 'Ética', 'Zoologia'],
      );
    });

    test('a ordenação por "nome" cru estaria ERRADA', () async {
      // Este teste documenta o bug, para ninguém "simplificar" a
      // coluna nome_ordenacao no futuro.
      final List<Map<String, Object?>> linhas =
          await db.query('materias', orderBy: 'nome ASC');
      final List<String> nomes =
          linhas.map((Map<String, Object?> l) => l['nome']! as String).toList();

      expect(nomes.first, isNot('Álgebra'),
          reason: 'o SQLite ordena por código de caractere');
    });

    test('busca sem acento encontra nome com acento', () async {
      final List<Materia> r = await dao.buscar('calculo');
      expect(r.single.nome, 'Cálculo');
    });

    test('busca ignora maiúsculas', () async {
      final List<Materia> r = await dao.buscar('BIOLOGIA');
      expect(r.single.nome, 'Biologia');
    });
  });

  group('segurança', () {
    test('busca com texto malicioso não apaga nada', () async {
      await dao.inserir(nova('dart', 'Dart'));
      await dao.inserir(nova('git', 'Git'));

      await dao.buscar("'; DELETE FROM materias; --");

      // As duas continuam lá: whereArgs tratou o texto como DADO.
      expect(await dao.contar(), 2);
    });
  });

  group('atualizar', () {
    test('atualiza e devolve 1', () async {
      await dao.inserir(nova('dart', 'Dart'));

      final int alteradas =
          await dao.atualizar(nova('dart', 'Dart 3', minutos: 50));

      expect(alteradas, 1);
      expect((await dao.porId('dart'))?.nome, 'Dart 3');
    });

    test('atualizar inexistente devolve 0', () async {
      expect(await dao.atualizar(nova('fantasma', 'X')), 0);
    });

    test('somarMinutos acumula', () async {
      await dao.inserir(nova('dart', 'Dart'));

      await dao.somarMinutos('dart', 25);
      await dao.somarMinutos('dart', 50);

      expect((await dao.porId('dart'))?.minutos, 75);
    });

    test('renomear atualiza o nome_ordenacao junto', () async {
      await dao.inserir(nova('x', 'Zoologia'));
      await dao.atualizar(nova('x', 'Álgebra'));

      // Se paraLinha() não derivasse o nome_ordenacao, esta matéria
      // ficaria ordenada como "zoologia" para sempre.
      final List<Map<String, Object?>> linhas = await db.query('materias');
      expect(linhas.single['nome_ordenacao'], 'algebra');
    });
  });

  group('arquivar e excluir', () {
    test('arquivada some da lista padrão', () async {
      await dao.inserir(nova('dart', 'Dart'));
      await dao.arquivar('dart');

      expect(await dao.listar(), isEmpty);
      expect(await dao.listar(incluirArquivadas: true), hasLength(1));
    });

    test('excluir remove a matéria', () async {
      await dao.inserir(nova('dart', 'Dart'));
      expect(await dao.excluir('dart'), 1);
      expect(await dao.porId('dart'), isNull);
    });

    test('excluir inexistente devolve 0, sem lançar', () async {
      expect(await dao.excluir('fantasma'), 0);
    });
  });

  group('importar em lote', () {
    test('insere 200 matérias', () async {
      final List<Materia> muitas = <Materia>[
        for (int i = 0; i < 200; i++) nova('m$i', 'Matéria $i'),
      ];

      await dao.importar(muitas);

      expect(await dao.contar(), 200);
    });

    test('lista vazia não faz nada', () async {
      await dao.importar(<Materia>[]);
      expect(await dao.contar(), 0);
    });
  });
}
```

Rode:

```powershell
flutter analyze
flutter test
```

Mais de vinte testes, sem emulador, em menos de um segundo.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `MateriaDao(this._db)` recebendo `DatabaseExecutor` | `DatabaseExecutor` é a interface comum de `Database` **e** `Transaction` — o mesmo DAO funciona dentro e fora de transação. |
| `conflictAlgorithm: ConflictAlgorithm.abort` no `inserir` | `replace` apagaria a linha e, por CASCADE, as sessões da matéria. `abort` avisa. |
| `enum OrdemDeMaterias` com `clausula` | Nome de coluna **não** pode ser parametrizado. Um enum fechado é a lista branca. |
| `whereArgs: <Object?>[id]` em **toda** consulta | Sem ele, um valor com `'` ou `;` vira comando. É SQL injection. |
| `'%$alvo%'` dentro de `whereArgs` | O `%` faz parte do **valor**, não da consulta: continua parametrizado. |
| `Texto.paraOrdenacao(nome)` dentro de `paraLinha()` | Derivado em **um** lugar. Deixar a cargo de quem chama garantiria o esquecimento — e a matéria ficaria fora de ordem sem erro. |
| `orderBy: 'nome_ordenacao ASC'` | O SQLite ordena por código de caractere: `Á` (U+00C1) vem depois de `z`. |
| `Sqflite.firstIntValue(linhas)` | Atalho para `COUNT(*)`, que devolve uma linha com uma coluna. Trata o `null`. |
| `rawUpdate('SET minutos = minutos + ?')` | Operação **atômica do banco**. Ler, somar e gravar em Dart perderia atualizações simultâneas. |
| `MAX(0, minutos - ?)` no `remover` | Impede total negativo se o banco já estiver inconsistente. |
| `db.transaction((txn) async {...})` no `registrar` | Inserir a sessão **e** somar os minutos é uma unidade. Sem transação, uma falha deixaria o total errado. |
| Tudo usando `txn`, nunca `_db`, dentro da transação | Usar `db` ali abre outra conexão que espera a transação — e a transação espera a operação. O app **trava sem erro**. |
| `txn.query` antes do `txn.delete` no `remover` | Ler dentro da transação é possível; num `batch` não seria. |
| `txn.batch()` dentro de `transaction` no `importar` | `batch` para velocidade, `transaction` para atomicidade. Os dois juntos. |
| `commit(noResult: true)` | Descarta os rowids: menos dados de volta, mais rápido. |
| `LEFT JOIN` no `resumoPorMateria` | `LEFT` mantém matérias **sem** sessão no resultado; `INNER` as esconderia. |
| `COALESCE(SUM(s.minutos), 0)` | `SUM` de conjunto vazio é `NULL`. `COALESCE` devolve 0. |
| `DateTime.fromMillisecondsSinceEpoch(...)` no `deLinha` | O SQLite não tem tipo de data. `int` é ordenável e sem fuso ambíguo. |
| `(linha['arquivada'] as int? ?? 0) == 1` | O SQLite não tem `BOOLEAN`. Cast defensivo para coluna que pode não existir em bancos antigos (aula 6). |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onde fica o `.db` | `/data/data/<pacote>/databases/` | `Library/Application Support/` |
| Acesso por outro app | Impossível sem root | Impossível sem jailbreak |
| Backup automático | Vai para o Google Backup por padrão | Vai para o backup do iCloud por padrão |
| Desinstalar o app | Apaga o banco | Apaga o banco |
| Tamanho limite | Espaço livre do aparelho | Espaço livre do aparelho |
| Versão do SQLite | Do sistema (varia por versão do Android) | Do sistema |

> ⚠️ **A terceira linha merece atenção.** Um banco com dados pessoais indo para o backup em nuvem
> pode ser um problema de privacidade — e, no caso do iOS, a Apple **rejeita** apps que colocam
> grandes volumes de dados recriáveis no backup do iCloud.
>
> Para excluir o banco do backup:
>
> - **Android:** `android:fullBackupContent` apontando para um XML com
>   `<exclude domain="database" path="foco.db"/>`.
> - **iOS:** guarde o banco em `getApplicationSupportDirectory()` e marque com
>   `NSURLIsExcludedFromBackupKey` (via plugin nativo) — ou use
>   `getTemporaryDirectory()` **apenas** para cache descartável.

> 📌 A última linha é sutil: a versão do SQLite varia entre aparelhos. Funções recentes
> (`JSON1`, `RETURNING`, janelas) podem não existir em Android antigo. Se precisar delas, use o
> pacote `sqlite3_flutter_libs`, que embute uma versão própria.

---

## ⚠️ Erros comuns

### 1. Concatenar valores na consulta

```dart
await db.query('materias', where: "nome = '$busca'");   // ❌
```

SQL injection. Um texto com `'; DELETE FROM materias; --` apaga tudo.

**Correção:** `where: 'nome = ?', whereArgs: <Object?>[busca]`.

### 2. `update` ou `delete` sem `where`

```dart
await db.delete('materias');   // ❌ apaga a tabela inteira
```

**Correção:** sempre `where` + `whereArgs`.

### 3. `replace` para atualizar

```dart
await db.insert('materias', dados,
    conflictAlgorithm: ConflictAlgorithm.replace);   // ⚠️
```

Apaga a linha antiga; com `ON DELETE CASCADE`, os filhos vão junto — **sem erro**.

**Correção:** `update` para atualizar; `replace` só em sincronização.

### 4. Usar `db` dentro de `transaction`

```dart
await db.transaction((Transaction txn) async {
  await db.insert('sessoes', dados);   // ❌ TRAVA o app
});
```

Não dá erro. O app simplesmente **congela**.

**Correção:** use `txn` para tudo dentro do bloco.

### 5. `ORDER BY nome` em português

```dart
orderBy: 'nome ASC'   // ❌ 'Álgebra' depois de 'Zoologia'
```

**Correção:** coluna achatada + `orderBy: 'nome_ordenacao ASC'`.

### 6. Esquecer de atualizar o `nome_ordenacao` ao renomear

```dart
await db.update('materias', <String, Object?>{'nome': novoNome},
    where: 'id = ?', whereArgs: <Object?>[id]);   // ⚠️ nome_ordenacao ficou o antigo
```

A matéria fica ordenada pelo nome velho, para sempre, sem erro.

**Correção:** derive no `paraLinha()` e atualize a linha inteira.

### 7. Guardar `DateTime` direto

```dart
'criada_em': DateTime.now(),   // ❌
```

```text
DatabaseException: Invalid argument: Instance of 'DateTime'
```

**Correção:** `DateTime.now().millisecondsSinceEpoch`.

### 8. Guardar `bool` direto

```dart
'arquivada': true,   // ❌ mesmo erro
```

**Correção:** `arquivada ? 1 : 0`, e `linha['arquivada'] == 1` na volta.

### 9. `SUM` devolvendo `null`

```dart
final int total = linha['total']! as int;   // ❌ se não houver linhas, é null
```

**Correção:** `COALESCE(SUM(x), 0)` na consulta, e cast defensivo no Dart.

### 10. Inserir mil linhas uma a uma

```dart
for (final Materia m in muitas) {
  await dao.inserir(m);   // ⚠️ mil idas e voltas ao banco
}
```

**Correção:** `batch` dentro de `transaction`.

### 11. `INNER JOIN` onde deveria ser `LEFT`

```sql
FROM materias m INNER JOIN sessoes s ON s.materia_id = m.id   -- ⚠️
```

Matérias **sem** sessão somem do resultado.

**Correção:** `LEFT JOIN` + `COALESCE`.

### 12. `rawQuery` sem teste

Um erro de digitação em SQL **não é pego pelo compilador**. Ele aparece em execução — e, se aquela
consulta só roda numa tela pouco usada, só em produção.

**Correção:** todo `rawQuery` tem teste.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test test/exemplo_crud_test.dart`. Leia com atenção a saída do teste
`❌ ordenar por "nome"`. Anote a ordem que apareceu.

**Passo 2.** No `MateriaDao.inserir`, troque `abort` por `replace`. Rode o teste de id duplicado e
o de sessões. Descreva o que se perdeu.

**Passo 3.** Em `buscar`, troque `whereArgs` por interpolação:
`where: "nome_ordenacao LIKE '%$alvo%'"`. Rode o teste de segurança. O que aconteceu com as
matérias?

**Passo 4.** Em `SessaoDao.registrar`, troque `txn.insert` por `_db.insert` (mantendo a
transação). Rode o teste. O que acontece? Quanto tempo você esperou?

**Passo 5.** Remova a transação do `registrar` (use `_db` direto nas duas operações). Force o
`insert` a falhar (id duplicado) e verifique os minutos da matéria. O que ficou inconsistente?

**Passo 6.** Em `Materia.paraLinha`, remova a linha do `nome_ordenacao` e deixe `'nome_ordenacao':
nome`. Rode o teste de ordenação. Depois teste o de renomear.

**Passo 7.** Escreva um teste que insira 1 000 matérias com `for` + `await dao.inserir` e outro com
`dao.importar`. Compare os tempos (use `Stopwatch`).

**Passo 8.** No `resumoPorMateria`, troque `LEFT JOIN` por `INNER JOIN`. Crie uma matéria **sem**
sessões e rode. Ela aparece?

**Passo 9.** Remova o `COALESCE` do `SUM`. Rode com uma matéria sem sessões e leia o erro.

**Passo 10.** Escreva uma consulta que devolva as 5 matérias mais estudadas **da última semana**,
usando `rawQuery`. Escreva o teste antes da consulta.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md)

Faça os exercícios de **Aplicação** com CRUD completo, o de **Correção de bugs** com SQL injection,
e o de **Compreensão** sobre `transaction` × `batch`.

---

## 🏆 Desafio opcional

Implemente **paginação por cursor** (*keyset pagination*) no `MateriaDao`, em vez de
`limit`/`offset`.

O problema do `offset`: com `OFFSET 10000`, o banco **percorre e descarta** 10 000 linhas antes de
devolver as 20 que você quer. E, se uma linha for inserida entre duas páginas, um item aparece
duas vezes ou some.

Requisitos:

- `listarApos({Materia? ultima, int limite = 20})` usa a **última linha vista** como referência.
- A condição é `(nome_ordenacao, id) > (?, ?)`, comparando pela tupla — o `id` desempata nomes
  iguais.
- Inserir uma matéria no meio **não** causa item duplicado nem faltante.
- Um teste prova isso: pagine, insira no meio, continue paginando, e confirme que nenhum item
  aparece duas vezes.

Dica: o SQLite aceita comparação de tuplas:
`WHERE (nome_ordenacao, id) > (?, ?) ORDER BY nome_ordenacao, id LIMIT ?`.

Depois responda: por que o `id` precisa entrar na comparação? O que acontece com duas matérias de
nome idêntico se você paginar só por `nome_ordenacao`?

---

## 📌 Resumo

- `insert`, `query`, `update` e `delete` são os quatro métodos. Todos devolvem `Future`.
- **`conflictAlgorithm`**: `abort` avisa (padrão), `ignore` pula, **`replace` apaga e reinsere** —
  e leva os filhos junto por `ON DELETE CASCADE`.
- **`whereArgs` não é opcional.** Concatenar valores na consulta é **SQL injection**.
- Nome de tabela e de coluna **não podem** ser parametrizados: valide contra **lista branca**
  (um `enum` fechado).
- **`update` e `delete` sem `where` afetam a tabela inteira.** Use o retorno (linhas afetadas).
- `rawQuery` para `JOIN`, agregação e subconsulta — e **sempre com teste**, porque erro de SQL não é
  pego pelo compilador.
- **`transaction` = atomicidade; `batch` = desempenho.** Use os dois juntos em importação grande.
- **Dentro de `transaction`, use `txn`, nunca `db`** — ou o app trava sem erro.
- Datas viram **`int`** (`millisecondsSinceEpoch`); booleanos viram **`0`/`1`**.
- **O bug do `ORDER BY` em português:** o SQLite ordena por código de caractere, e acentuados vêm
  depois do `z`. A solução é a coluna achatada `nome_ordenacao`.
- Derive o `nome_ordenacao` **no `paraLinha()`** — deixar a cargo de quem chama garante o
  esquecimento.
- `LEFT JOIN` + `COALESCE` para incluir registros sem filhos e evitar `null` em `SUM`.
- Toda a camada de dados é testável **no Windows**, com `sqflite_common_ffi` e
  `inMemoryDatabasePath`.

---

## ☑️ Checklist de domínio

- [ ] Uso os quatro métodos do CRUD e sei o que cada um devolve.
- [ ] Escolho o `conflictAlgorithm` com critério, sabendo o risco do `replace`.
- [ ] **Nunca** concateno valor em consulta; sempre `whereArgs`.
- [ ] Valido nome de coluna dinâmico contra lista branca.
- [ ] Nunca uso `update`/`delete` sem `where`.
- [ ] Uso o número de linhas afetadas para detectar "não existe".
- [ ] Sei quando usar `rawQuery` — e testo toda consulta crua.
- [ ] Sei a diferença entre `transaction` e `batch`, e uso os dois juntos quando faz sentido.
- [ ] Nunca uso `db` dentro de uma `transaction`.
- [ ] Converto datas para `int` e booleanos para `0`/`1`.
- [ ] Ordeno e busco pela coluna achatada, não pela original.
- [ ] Derivo a coluna achatada no `paraLinha()`.
- [ ] Uso `LEFT JOIN` + `COALESCE` quando pode não haver filhos.
- [ ] Rodo os testes de banco no Windows, sem emulador.

---

## 📚 Referências oficiais

- [sqflite — pub.dev](https://pub.dev/packages/sqflite)
- [sqflite — SQL usage documentation](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/sql.md)
- [Persist data with SQLite — docs.flutter.dev](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [sqflite_common_ffi — pub.dev](https://pub.dev/packages/sqflite_common_ffi)
- [SQL As Understood By SQLite — sqlite.org](https://www.sqlite.org/lang.html)
- [ON CONFLICT clause — sqlite.org](https://www.sqlite.org/lang_conflict.html)
- [Datatypes In SQLite — sqlite.org](https://www.sqlite.org/datatype3.html)
- [SQL injection — OWASP](https://owasp.org/www-community/attacks/SQL_Injection)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — sqflite: criando o banco](04-sqflite-criando-o-banco.md) | [README](README.md) | [Aula 6 — Migrações](06-migracoes.md) |
