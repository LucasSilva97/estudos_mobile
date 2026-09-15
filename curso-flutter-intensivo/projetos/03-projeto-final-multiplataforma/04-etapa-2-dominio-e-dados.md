# Etapa 2 — Domínio e dados — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 3 h · **Depende de:** [Etapa 1 — Fundação](03-etapa-1-fundacao.md) ·
> **Aulas:** [M03 a5 Abstratas e interfaces](../../modulos/03-dart-intermediario/05-abstratas-e-interfaces.md) ·
> [M04 a1 Exceptions](../../modulos/04-dart-avancado/01-exceptions.md) ·
> [M10 a2 shared_preferences](../../modulos/10-persistencia-de-dados/02-shared-preferences.md) ·
> [M10 a4 Criando o banco](../../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) ·
> [M10 a5 CRUD](../../modulos/10-persistencia-de-dados/05-sqflite-crud.md) ·
> [M10 a6 Migrações](../../modulos/10-persistencia-de-dados/06-migracoes.md)

---

## 🎯 O que existe ao fim desta etapa

O Foco ganha memória. A tela continua a da etapa 1 — o que nasce aqui é tudo o que as próximas
seis etapas consomem.

| Depois desta etapa | Concretamente |
|---|---|
| `foco.db` na **versão 3** | `materias`, `sessoes`, `cache_trilhas`, 3 índices, `CASCADE` ligado |
| 4 modelos de domínio | `Materia`, `Sessao`, `MetaSemanal`, `ResumoSemanal`, em Dart puro |
| 2 contratos + 2 DAOs | Sessão gravada **e** minutos somados, ou nada gravado |
| Meta semanal persistida | `meta_semanal_minutos`, padrão 300 |
| `Álgebra` antes de `Biologia` | A coluna achatada `nome_ordenacao` |

> 📌 Etapa sem pixel novo é etapa normal. Errar aqui custa a etapa 3 e a 4.

---

## 📦 Dependências

```yaml
dependencies:
  sqflite: ^2.4.4
  path: ^1.9.1
  shared_preferences: ^2.5.5
  uuid: ^4.6.0
  meta: ^1.16.0
```

| Pacote | Por que entra agora |
|---|---|
| `sqflite` + `path` | Matérias e sessões são relacionadas e consultáveis: `SUM`, `GROUP BY`, `CASCADE` (ADR-05). `p.join` monta o caminho do arquivo |
| `shared_preferences` | A meta é **um inteiro**; tabela para guardar `300` seria desproporcional |
| `uuid` | O `id` é v4 gerado no app, nunca `AUTOINCREMENT` |
| `meta` | `domain/` não pode importar `package:flutter/foundation.dart` só para ter `@immutable`, e o lint `depend_on_referenced_packages` reprova usar pacote transitivo |

---

## 🧩 Os arquivos desta etapa

| Arquivo | Papel |
|---|---|
| `lib/core/banco/texto.dart` | Achata acento e caixa para ordenar e buscar |
| `lib/core/banco/banco_foco.dart` | Abre o banco, cria a v3, migra de v1 e v2 |
| `lib/core/providers/providers_raiz.dart` | Banco, prefs, uuid e relógio como providers |
| `lib/features/materias/domain/materia.dart` | Modelo + `deLinha` / `paraLinha` |
| `lib/features/sessoes/domain/sessao.dart` | Modelo com os limites 1–480 |
| `lib/features/metas/domain/meta_semanal.dart` | Progresso, atingida, restante |
| `lib/features/estatisticas/domain/resumo_semanal.dart` | Os números da semana |
| `lib/features/materias/domain/materia_repositorio_contrato.dart` | Contrato de matérias |
| `lib/features/sessoes/domain/sessao_repositorio_contrato.dart` | Contrato de sessões |
| `lib/features/materias/data/materia_dao.dart` | SQL de `materias`, sempre com `whereArgs` |
| `lib/features/sessoes/data/sessao_dao.dart` | SQL de `sessoes` — as duas transações |
| `lib/features/materias/data/materia_repositorio.dart` | Regra do nome único + provider |
| `lib/features/sessoes/data/sessao_repositorio.dart` | Limites da sessão + provider |
| `lib/features/metas/data/meta_repositorio.dart` | `shared_preferences` + provider |

---

### lib/core/banco/texto.dart

> **Por que ele existe:** o `ORDER BY` do SQLite compara bytes — sem ele, `Física` vem antes de
> `Álgebra`, e `COLLATE NOCASE` não resolve porque só conhece ASCII.

```dart
/// Utilitários de texto do banco. Dart puro, sem dependência nenhuma.
class Texto {
  const Texto._();

  /// Minúsculas, sem acento e sem espaço nas pontas. Alimenta a coluna
  /// `nome_ordenacao` e também a busca.
  static String paraOrdenacao(String texto) {
    const String comAcento =
        'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const String semAcento =
        'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    final StringBuffer buffer = StringBuffer();
    for (final int unidade in texto.trim().toLowerCase().runes) {
      final String caractere = String.fromCharCode(unidade);
      final int indice = comAcento.indexOf(caractere);
      buffer.write(indice >= 0 ? semAcento[indice] : caractere);
    }
    return buffer.toString();
  }
}
```

---

### lib/core/banco/banco_foco.dart

> **Por que ele existe:** é o único lugar que conhece a estrutura do banco — nenhum DAO abre
> banco por conta própria.

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BancoFoco {
  const BancoFoco._();

  /// Versão do ESQUEMA — sobe quando a estrutura muda, nunca porque o app
  /// ganhou uma tela. 1: materias+sessoes · 2: arquivada · 3: cor_valor,
  /// anotacao, cache_trilhas.
  static const int versaoAtual = 3;
  static const String nomeDoArquivo = 'foco.db';

  static Future<Database> abrir() async {
    final String pasta = await getDatabasesPath();
    return openDatabase(
      p.join(pasta, nomeDoArquivo),
      version: versaoAtual,
      onConfigure: configurar,
      onCreate: criar,
      onUpgrade: atualizar,
    );
  }

  /// ⚠️ O SQLite nasce com chave estrangeira DESLIGADA: sem esta linha o
  /// `ON DELETE CASCADE` não acontece e sobram sessões órfãs, sem erro nenhum.
  /// Vai aqui, e não no `onCreate`, porque roda a cada abertura.
  static Future<void> configurar(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Roda só quando o arquivo ainda não existe: já cria a forma final da v3.
  static Future<void> criar(Database db, int versao) async {
    await db.execute(
      'CREATE TABLE materias ('
      '  id             TEXT    PRIMARY KEY,'
      '  nome           TEXT    NOT NULL,'
      '  nome_ordenacao TEXT    NOT NULL,'
      '  minutos        INTEGER NOT NULL DEFAULT 0,'
      '  criada_em      INTEGER NOT NULL,'
      '  arquivada      INTEGER NOT NULL DEFAULT 0,'
      '  cor_valor      INTEGER NOT NULL DEFAULT 4284960932'
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
      '  FOREIGN KEY (materia_id) REFERENCES materias (id)'
      '    ON DELETE CASCADE'
      ')',
    );
    await db.execute('CREATE INDEX idx_sessoes_materia ON sessoes (materia_id)');
    await db.execute('CREATE INDEX idx_sessoes_inicio ON sessoes (inicio_em)');
    await db.execute(
      'CREATE TABLE cache_trilhas ('
      '  id         TEXT    PRIMARY KEY,'
      '  conteudo   TEXT    NOT NULL,'
      '  buscado_em INTEGER NOT NULL'
      ')',
    );
  }

  /// ⚠️ Em etapas e sem `else`: quem está na v1 executa os dois blocos, em
  /// ordem. Com `else if` ele ganharia só o primeiro.
  static Future<void> atualizar(Database db, int de, int para) async {
    if (de < 2) await _de1Para2(db);
    if (de < 3) await _de2Para3(db);
  }

  /// ⚠️ PUBLICADA. Migração que já rodou em aparelho alheio nunca se edita —
  /// precisou de outra coluna, crie a versão 4.
  static Future<void> _de1Para2(Database db) async {
    // NOT NULL exige DEFAULT: as linhas que já existem precisam de um valor.
    await db.execute(
      'ALTER TABLE materias ADD COLUMN arquivada INTEGER NOT NULL DEFAULT 0',
    );
  }

  /// ⚠️ PUBLICADA. Não edite.
  static Future<void> _de2Para3(Database db) async {
    await db.execute(
      'ALTER TABLE materias '
      'ADD COLUMN cor_valor INTEGER NOT NULL DEFAULT 4284960932',
    );
    await db.execute(
      "ALTER TABLE sessoes ADD COLUMN anotacao TEXT NOT NULL DEFAULT ''",
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS cache_trilhas ('
      '  id         TEXT    PRIMARY KEY,'
      '  conteudo   TEXT    NOT NULL,'
      '  buscado_em INTEGER NOT NULL'
      ')',
    );
  }
}
```

---

### lib/core/providers/providers_raiz.dart

> **Por que ele existe:** banco e preferências abrem em `main()` e entram por `overrides`, para
> nenhuma tela ficar assíncrona por causa de infraestrutura (RNF14).

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Fonte de "agora", como provider para o teste poder congelar o tempo.
typedef Relogio = DateTime Function();

/// ⚠️ Lança até ser sobrescrito, de propósito: esquecer o override no `main()`
/// falha na primeira leitura, e não silenciosamente depois.
final Provider<Database> bancoProvider = Provider<Database>((Ref ref) {
  throw UnimplementedError('bancoProvider exige override em main()');
});

final Provider<SharedPreferences> preferenciasProvider =
    Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('preferenciasProvider exige override em main()');
});

final Provider<Uuid> uuidProvider = Provider<Uuid>((Ref ref) => const Uuid());

final Provider<Relogio> relogioProvider =
    Provider<Relogio>((Ref ref) => DateTime.now);
```

> 💡 `clienteHttpProvider` nasce na etapa 5. Os providers de repositório moram junto de cada
> implementação: `core/` não conhece `features/`.

---

### lib/features/materias/domain/materia.dart

> **Por que ele existe:** é a matéria como o app pensa nela, sem saber que existe um banco.

```dart
import 'package:meta/meta.dart';

import 'package:foco/core/banco/texto.dart';

@immutable
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.criadaEm,
    this.corValor = corPadrao,
    this.minutos = 0,
    this.arquivada = false,
  });

  /// No SQLite, data é INTEGER em milissegundos e booleano é INTEGER 0/1.
  factory Materia.deLinha(Map<String, Object?> linha) {
    return Materia(
      id: linha['id']! as String,
      nome: linha['nome']! as String,
      criadaEm: DateTime.fromMillisecondsSinceEpoch(linha['criada_em']! as int),
      corValor: linha['cor_valor'] as int? ?? corPadrao,
      minutos: linha['minutos']! as int,
      arquivada: (linha['arquivada'] as int? ?? 0) == 1,
    );
  }

  /// 0xFF6750A4 em decimal: ARGB como `int` porque `domain` não importa
  /// `dart:ui`. Quem vira `Color` é a tela.
  static const int corPadrao = 4284960932;
  static const int minimoDoNome = 2;
  static const int maximoDoNome = 60;

  final String id;
  final String nome;
  final DateTime criadaEm;
  final int corValor;
  final int minutos;
  final bool arquivada;

  /// O `nome_ordenacao` é derivado AQUI, num lugar só: deixar isso a cargo de
  /// quem chama garante que um dia alguém esquece — e a matéria sai da ordem
  /// sem erro nenhum.
  Map<String, Object?> paraLinha() => <String, Object?>{
        'id': id,
        'nome': nome,
        'nome_ordenacao': Texto.paraOrdenacao(nome),
        'criada_em': criadaEm.millisecondsSinceEpoch,
        'cor_valor': corValor,
        'minutos': minutos,
        'arquivada': arquivada ? 1 : 0,
      };

  Materia copyWith({
    String? id,
    String? nome,
    DateTime? criadaEm,
    int? corValor,
    int? minutos,
    bool? arquivada,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      criadaEm: criadaEm ?? this.criadaEm,
      corValor: corValor ?? this.corValor,
      minutos: minutos ?? this.minutos,
      arquivada: arquivada ?? this.arquivada,
    );
  }

  @override
  bool operator ==(Object outro) =>
      identical(this, outro) ||
      outro is Materia &&
          outro.id == id &&
          outro.nome == nome &&
          outro.criadaEm == criadaEm &&
          outro.corValor == corValor &&
          outro.minutos == minutos &&
          outro.arquivada == arquivada;

  @override
  int get hashCode =>
      Object.hash(id, nome, criadaEm, corValor, minutos, arquivada);
}
```

---

### lib/features/sessoes/domain/sessao.dart

> **Por que ele existe:** um bloco de estudo de uma matéria, com início, duração e anotação.

```dart
import 'package:meta/meta.dart';

@immutable
class Sessao {
  const Sessao({
    required this.id,
    required this.materiaId,
    required this.inicioEm,
    required this.minutos,
    this.anotacao = '',
  });

  factory Sessao.deLinha(Map<String, Object?> linha) {
    return Sessao(
      id: linha['id']! as String,
      materiaId: linha['materia_id']! as String,
      inicioEm: DateTime.fromMillisecondsSinceEpoch(linha['inicio_em']! as int),
      minutos: linha['minutos']! as int,
      anotacao: linha['anotacao'] as String? ?? '',
    );
  }

  static const int minimoDeMinutos = 1;
  static const int maximoDeMinutos = 480;
  static const int maximoDaAnotacao = 280;

  final String id;
  final String materiaId;
  final DateTime inicioEm;
  final int minutos;
  final String anotacao;

  /// Compara ano, mês e dia — `difference` chamaria de "hoje" uma sessão de
  /// ontem às 23h55.
  bool get ehDeHoje {
    final DateTime agora = DateTime.now();
    return inicioEm.year == agora.year &&
        inicioEm.month == agora.month &&
        inicioEm.day == agora.day;
  }

  Map<String, Object?> paraLinha() => <String, Object?>{
        'id': id,
        'materia_id': materiaId,
        'inicio_em': inicioEm.millisecondsSinceEpoch,
        'minutos': minutos,
        'anotacao': anotacao,
      };

  Sessao copyWith({
    String? id,
    String? materiaId,
    DateTime? inicioEm,
    int? minutos,
    String? anotacao,
  }) {
    return Sessao(
      id: id ?? this.id,
      materiaId: materiaId ?? this.materiaId,
      inicioEm: inicioEm ?? this.inicioEm,
      minutos: minutos ?? this.minutos,
      anotacao: anotacao ?? this.anotacao,
    );
  }

  @override
  bool operator ==(Object outro) =>
      identical(this, outro) ||
      outro is Sessao &&
          outro.id == id &&
          outro.materiaId == materiaId &&
          outro.inicioEm == inicioEm &&
          outro.minutos == minutos &&
          outro.anotacao == anotacao;

  @override
  int get hashCode => Object.hash(id, materiaId, inicioEm, minutos, anotacao);
}
```

---

### lib/features/metas/domain/meta_semanal.dart

> **Por que ele existe:** a regra do progresso mora junto do dado, não dentro de um `build`.

```dart
import 'package:meta/meta.dart';

@immutable
class MetaSemanal {
  const MetaSemanal({required this.minutosAlvo, required this.minutosFeitos});

  /// 5 h por semana: o valor de quem nunca abriu as Configurações.
  static const int padraoMinutos = 300;

  final int minutosAlvo;
  final int minutosFeitos;

  /// `clamp` porque 360 de 300 daria 1.2 — e o `LinearProgressIndicator`
  /// lança erro acima de 1.0.
  double get progresso =>
      minutosAlvo <= 0 ? 0 : (minutosFeitos / minutosAlvo).clamp(0.0, 1.0);

  bool get atingida => minutosFeitos >= minutosAlvo;

  int get minutosRestantes =>
      (minutosAlvo - minutosFeitos).clamp(0, minutosAlvo);

  MetaSemanal copyWith({int? minutosAlvo, int? minutosFeitos}) => MetaSemanal(
        minutosAlvo: minutosAlvo ?? this.minutosAlvo,
        minutosFeitos: minutosFeitos ?? this.minutosFeitos,
      );

  @override
  bool operator ==(Object outro) =>
      identical(this, outro) ||
      outro is MetaSemanal &&
          outro.minutosAlvo == minutosAlvo &&
          outro.minutosFeitos == minutosFeitos;

  @override
  int get hashCode => Object.hash(minutosAlvo, minutosFeitos);
}
```

---

### lib/features/estatisticas/domain/resumo_semanal.dart

> **Por que ele existe:** a etapa 4 desenha as barras da semana; quem sabe somá-las é o domínio.

```dart
import 'package:meta/meta.dart';

@immutable
class ResumoSemanal {
  const ResumoSemanal({
    required this.inicioDaSemana,
    required this.minutosPorDia,
    required this.minutosPorMateria,
    required this.metaMinutos,
    required this.minutosSemanaAnterior,
  });

  /// Segunda-feira, 00:00 local.
  final DateTime inicioDaSemana;

  /// Sempre 7 posições; índice 0 = segunda.
  final List<int> minutosPorDia;
  final Map<String, int> minutosPorMateria;
  final int metaMinutos;
  final int minutosSemanaAnterior;

  int get totalMinutos =>
      minutosPorDia.fold<int>(0, (int soma, int dia) => soma + dia);

  /// Divide por 7, não pelos dias com sessão: a média da semana é da semana.
  int get mediaDiariaMinutos => totalMinutos ~/ 7;

  double get progressoDaMeta =>
      metaMinutos <= 0 ? 0 : (totalMinutos / metaMinutos).clamp(0.0, 1.0);

  /// `''` quando não houve sessão nenhuma — a tela trata isso como vazio.
  String get materiaMaisEstudadaId {
    String campea = '';
    int melhor = 0;
    minutosPorMateria.forEach((String id, int minutos) {
      if (minutos > melhor) {
        melhor = minutos;
        campea = id;
      }
    });
    return campea;
  }
}
```

---

### lib/features/materias/domain/materia_repositorio_contrato.dart

> **Por que ele existe:** é o tipo que a `presentation` conhece — por isso o teste de widget roda
> sem banco.

```dart
import 'package:foco/features/materias/domain/materia.dart';

/// `abstract interface class` (Dart 3): só pode ser IMPLEMENTADO, nunca
/// estendido. É exatamente o que um contrato deve permitir.
abstract interface class MateriaRepositorioContrato {
  Future<List<Materia>> listar({bool incluirArquivadas = false});
  Future<Materia?> porId(String id);
  Future<Materia> salvar(Materia materia);
  Future<void> arquivar(String id, {bool arquivada = true});
  Future<void> excluir(String id);
  Future<List<Materia>> buscar(String termo);
}
```

---

### lib/features/sessoes/domain/sessao_repositorio_contrato.dart

> **Por que ele existe:** separa "o que dá para fazer com sessões" de "como o SQLite faz".

```dart
import 'package:foco/features/sessoes/domain/sessao.dart';

abstract interface class SessaoRepositorioContrato {
  Future<List<Sessao>> daMateria(String materiaId, {int limite = 50});
  Future<List<Sessao>> noPeriodo(DateTime de, DateTime ate, {int limite = 500});
  Future<void> registrar(Sessao sessao);
  Future<void> remover(String id);

  /// Soma em SQL. Período `[de, ate)`: início incluído, fim excluído.
  Future<int> minutosNoPeriodo(DateTime de, DateTime ate);
}
```

---

### lib/features/materias/data/materia_dao.dart

> **Por que ele existe:** todo o SQL de `materias` num arquivo só — e todo ele parametrizado.

```dart
import 'package:sqflite/sqflite.dart';

import 'package:foco/core/banco/texto.dart';
import 'package:foco/features/materias/domain/materia.dart';

class MateriaDao {
  const MateriaDao(this._db);

  final Database _db;
  static const String tabela = 'materias';

  Future<List<Materia>> listar({bool incluirArquivadas = false}) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: incluirArquivadas ? null : 'arquivada = ?',
      whereArgs: incluirArquivadas ? null : <Object?>[0],
      orderBy: 'nome_ordenacao ASC', // pela coluna achatada, NUNCA por `nome`
    );
    return linhas.map(Materia.deLinha).toList();
  }

  Future<Materia?> porId(String id) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    return linhas.isEmpty ? null : Materia.deLinha(linhas.first);
  }

  Future<List<Materia>> buscar(String termo) async {
    final String alvo = Texto.paraOrdenacao(termo);
    if (alvo.isEmpty) return listar();

    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'nome_ordenacao LIKE ? AND arquivada = ?',
      // O `%` faz parte do VALOR, não da consulta: segue parametrizado.
      whereArgs: <Object?>['%$alvo%', 0],
      orderBy: 'nome_ordenacao ASC',
      limit: 50,
    );
    return linhas.map(Materia.deLinha).toList();
  }

  /// `exceto` é o id da própria matéria na edição — senão ela colidiria
  /// consigo mesma. Um uuid nunca é `''`, então o filtro sempre passa.
  Future<bool> existeNome(String nomeOrdenacao, {String? exceto}) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      columns: <String>['id'],
      where: 'nome_ordenacao = ? AND id <> ?',
      whereArgs: <Object?>[nomeOrdenacao, exceto ?? ''],
      limit: 1,
    );
    return linhas.isNotEmpty;
  }

  /// ⚠️ Nada de `ConflictAlgorithm.replace` aqui: `replace` APAGA a linha
  /// antiga, e o `ON DELETE CASCADE` levaria as sessões da matéria junto.
  Future<void> salvar(Materia materia) async {
    final int alteradas = await _db.update(
      tabela,
      materia.paraLinha(),
      where: 'id = ?',
      whereArgs: <Object?>[materia.id],
    );
    if (alteradas == 0) {
      await _db.insert(
        tabela,
        materia.paraLinha(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }

  Future<void> arquivar(String id, {bool arquivada = true}) async {
    await _db.update(
      tabela,
      <String, Object?>{'arquivada': arquivada ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  /// Remove a matéria — e, por CASCADE, as sessões dela. O `where` não é
  /// opcional: sem ele, `delete` apaga a tabela inteira.
  Future<void> excluir(String id) async {
    await _db.delete(tabela, where: 'id = ?', whereArgs: <Object?>[id]);
  }
}
```

> ⚠️ `salvar` grava **todas** as colunas. Ao editar, monte a matéria com
> `carregada.copyWith(nome: ..., corValor: ...)`: um `Materia(...)` novo zeraria `minutos` e
> `criadaEm`.

---

### lib/features/sessoes/data/sessao_dao.dart

> **Por que ele existe:** aqui moram as duas transações do projeto — registrar e remover sessão.

```dart
import 'package:sqflite/sqflite.dart';

import 'package:foco/features/materias/data/materia_dao.dart';
import 'package:foco/features/sessoes/domain/sessao.dart';

class SessaoDao {
  const SessaoDao(this._db);

  final Database _db;
  static const String tabela = 'sessoes';

  /// Grava a sessão E soma os minutos da matéria, como uma unidade só: sem
  /// transação, um app morto no meio deixaria a sessão gravada e o total
  /// errado — bug que não lança exceção nenhuma.
  ///
  /// ⚠️ Tudo aqui usa `txn`, nunca `_db`. Usar `_db` dentro do bloco abre uma
  /// segunda conexão que espera a transação terminar: o app TRAVA, calado.
  Future<void> registrar(Sessao sessao) async {
    await _db.transaction((Transaction txn) async {
      await txn.insert(
        tabela,
        sessao.paraLinha(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      // `minutos = minutos + ?` é atômico no banco; ler, somar e gravar em
      // Dart perderia atualizações simultâneas.
      await txn.rawUpdate(
        'UPDATE ${MateriaDao.tabela} SET minutos = minutos + ? WHERE id = ?',
        <Object?>[sessao.minutos, sessao.materiaId],
      );
    });
  }

  /// Apaga a sessão E desconta os minutos, na mesma transação.
  Future<void> remover(String id) async {
    await _db.transaction((Transaction txn) async {
      // Lê ANTES de apagar: precisamos dos minutos para descontar.
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

  Future<List<Sessao>> daMateria(String materiaId, {int limite = 50}) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'materia_id = ?',
      whereArgs: <Object?>[materiaId],
      orderBy: 'inicio_em DESC',
      limit: limite,
    );
    return linhas.map(Sessao.deLinha).toList();
  }

  Future<List<Sessao>> noPeriodo(
    DateTime de,
    DateTime ate, {
    int limite = 500,
  }) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'inicio_em >= ? AND inicio_em < ?',
      whereArgs: <Object?>[
        de.millisecondsSinceEpoch,
        ate.millisecondsSinceEpoch,
      ],
      orderBy: 'inicio_em DESC',
      limit: limite,
    );
    return linhas.map(Sessao.deLinha).toList();
  }

  /// Soma no banco, não em Dart varrendo lista (RNF09). `SUM` de conjunto
  /// vazio devolve NULL, e `firstIntValue` já trata isso.
  Future<int> minutosNoPeriodo(DateTime de, DateTime ate) async {
    final List<Map<String, Object?>> linhas = await _db.rawQuery(
      'SELECT SUM(minutos) FROM $tabela WHERE inicio_em >= ? AND inicio_em < ?',
      <Object?>[de.millisecondsSinceEpoch, ate.millisecondsSinceEpoch],
    );
    return Sqflite.firstIntValue(linhas) ?? 0;
  }
}
```

---

### lib/features/materias/data/materia_repositorio.dart

> **Por que ele existe:** o DAO fala SQL; o repositório aplica as regras do Foco e é ele que o
> provider entrega.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco/core/banco/texto.dart';
import 'package:foco/core/providers/providers_raiz.dart';
import 'package:foco/features/materias/data/materia_dao.dart';
import 'package:foco/features/materias/domain/materia.dart';
import 'package:foco/features/materias/domain/materia_repositorio_contrato.dart';

class MateriaRepositorio implements MateriaRepositorioContrato {
  const MateriaRepositorio(this._dao);

  final MateriaDao _dao;

  @override
  Future<List<Materia>> listar({bool incluirArquivadas = false}) =>
      _dao.listar(incluirArquivadas: incluirArquivadas);

  @override
  Future<Materia?> porId(String id) => _dao.porId(id);

  @override
  Future<List<Materia>> buscar(String termo) => _dao.buscar(termo);

  /// Rejeita duplicata pelo nome NORMALIZADO: "cálculo" e "Calculo" são a
  /// mesma matéria. A tela captura o `ArgumentError` e mostra a mensagem no
  /// próprio campo.
  @override
  Future<Materia> salvar(Materia materia) async {
    final String chave = Texto.paraOrdenacao(materia.nome);
    if (await _dao.existeNome(chave, exceto: materia.id)) {
      throw ArgumentError.value(
        materia.nome,
        'nome',
        'Já existe uma matéria com esse nome',
      );
    }
    await _dao.salvar(materia);
    return materia;
  }

  @override
  Future<void> arquivar(String id, {bool arquivada = true}) =>
      _dao.arquivar(id, arquivada: arquivada);

  @override
  Future<void> excluir(String id) => _dao.excluir(id);
}

/// O tipo do provider é o CONTRATO: no teste, uma linha de `overrides` troca a
/// implementação inteira.
final Provider<MateriaRepositorioContrato> materiaRepositorioProvider =
    Provider<MateriaRepositorioContrato>((Ref ref) {
  return MateriaRepositorio(MateriaDao(ref.watch(bancoProvider)));
});
```

---

### lib/features/sessoes/data/sessao_repositorio.dart

> **Por que ele existe:** é a última porta antes do banco — os limites da sessão param aqui.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco/core/providers/providers_raiz.dart';
import 'package:foco/features/sessoes/data/sessao_dao.dart';
import 'package:foco/features/sessoes/domain/sessao.dart';
import 'package:foco/features/sessoes/domain/sessao_repositorio_contrato.dart';

class SessaoRepositorio implements SessaoRepositorioContrato {
  const SessaoRepositorio(this._dao);

  final SessaoDao _dao;

  @override
  Future<List<Sessao>> daMateria(String materiaId, {int limite = 50}) =>
      _dao.daMateria(materiaId, limite: limite);

  @override
  Future<List<Sessao>> noPeriodo(
    DateTime de,
    DateTime ate, {
    int limite = 500,
  }) =>
      _dao.noPeriodo(de, ate, limite: limite);

  /// A tela valida para dar mensagem boa; aqui a validação se repete porque
  /// nem todo caminho até o banco passa por um formulário.
  @override
  Future<void> registrar(Sessao sessao) async {
    if (sessao.minutos < Sessao.minimoDeMinutos ||
        sessao.minutos > Sessao.maximoDeMinutos) {
      throw ArgumentError.value(
        sessao.minutos,
        'minutos',
        'A sessão precisa ter de 1 a 480 minutos',
      );
    }
    if (sessao.anotacao.length > Sessao.maximoDaAnotacao) {
      throw ArgumentError.value(
        sessao.anotacao.length,
        'anotacao',
        'A anotação passa de 280 caracteres',
      );
    }
    await _dao.registrar(sessao);
  }

  @override
  Future<void> remover(String id) => _dao.remover(id);

  @override
  Future<int> minutosNoPeriodo(DateTime de, DateTime ate) =>
      _dao.minutosNoPeriodo(de, ate);
}

final Provider<SessaoRepositorioContrato> sessaoRepositorioProvider =
    Provider<SessaoRepositorioContrato>((Ref ref) {
  return SessaoRepositorio(SessaoDao(ref.watch(bancoProvider)));
});
```

---

### lib/features/metas/data/meta_repositorio.dart

> **Por que ele existe:** a meta é um inteiro solto — e nenhum widget deve chamar
> `SharedPreferences` direto.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foco/core/providers/providers_raiz.dart';
import 'package:foco/features/metas/domain/meta_semanal.dart';

class MetaRepositorio {
  const MetaRepositorio(this._prefs);

  final SharedPreferences _prefs;

  // A chave em constante: digitá-la à mão em dois lugares é como o dado some
  // sem ninguém entender por quê.
  static const String chaveMeta = 'meta_semanal_minutos';

  static const int minimoMinutos = 30;
  static const int maximoMinutos = 3000;
  static const int passoMinutos = 30;

  /// Leitura SÍNCRONA: depois do `getInstance()`, o valor sai da cópia em
  /// memória — por isso a tela não precisa de `FutureBuilder`.
  int lerMinutosAlvo() => _prefs.getInt(chaveMeta) ?? MetaSemanal.padraoMinutos;

  /// Grava já ajustado à faixa e ao passo: valor fora disso travaria o
  /// `Slider` das Configurações.
  Future<void> salvarMinutosAlvo(int minutos) async {
    final int ajustado = (minutos ~/ passoMinutos * passoMinutos)
        .clamp(minimoMinutos, maximoMinutos);
    await _prefs.setInt(chaveMeta, ajustado);
  }

  /// Diferente de "a meta é zero": responde se a pessoa já escolheu alguma.
  bool jaDefiniuMeta() => _prefs.containsKey(chaveMeta);
}

final Provider<MetaRepositorio> metaRepositorioProvider =
    Provider<MetaRepositorio>((Ref ref) {
  return MetaRepositorio(ref.watch(preferenciasProvider));
});
```

> 💡 A chave `modo_de_tema` é do `TemaController`, na etapa 3 — ela não é meta.

---

## ▶️ Rodando

O `main()` da etapa 1 agora abre as duas fontes de dado e as injeta. Confira que ele tem estas
linhas — o widget raiz é o que a etapa 1 criou em `app.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Database banco = await BancoFoco.abrir();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Prova de vida — apague depois de conferir o console.
  debugPrint('matérias: ${(await MateriaDao(banco).listar()).length}');
  debugPrint('meta: ${MetaRepositorio(prefs).lerMinutosAlvo()} min');

  runApp(
    ProviderScope(
      overrides: <Override>[
        bancoProvider.overrideWithValue(banco),
        preferenciasProvider.overrideWithValue(prefs),
      ],
      child: const AppFoco(),
    ),
  );
}
```

```console
flutter pub get
flutter analyze
flutter run
```

**O que você vê:** a mesma tela da etapa 1 e, no console, `matérias: 0` e `meta: 300`. O arquivo
`foco.db` passou a existir no aparelho 🤖. Nenhuma tela lista nada ainda — quem liga o banco à
interface é a etapa 3.

---

## ✅ Conferência

- [ ] `flutter analyze` termina com `No issues found!` e `flutter run` sobe sem exceção
- [ ] O console imprime `matérias: 0` e `meta: 300` — e depois você apagou os dois `debugPrint`
- [ ] Nenhum arquivo de `domain/` importa `flutter`, `sqflite`, `http` ou `shared_preferences`
- [ ] `BancoFoco.versaoAtual` é `3`, `onConfigure` roda `PRAGMA foreign_keys = ON` e o
      `onUpgrade` usa `if` em sequência, **sem** `else if`
- [ ] Todo `where`, `rawQuery` e `rawUpdate` usa `?` com `whereArgs` — zero concatenação
- [ ] `registrar` e `remover` do `SessaoDao` estão dentro de `transaction` e só usam `txn`
- [ ] `Materia.paraLinha()` é o único lugar que deriva `nome_ordenacao`, e `listar` ordena por ela
- [ ] Os providers de repositório são tipados pelo **contrato**, não pela implementação

---

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| `UnimplementedError: bancoProvider exige override em main()` | `ProviderScope` sem `overrides` | Acrescente os dois `overrideWithValue` antes do `runApp` |
| `DatabaseException: no such column: cor_valor` | Você editou só o `onCreate` e o aparelho já tinha o banco | Trate a coluna no `onUpgrade`; ou desinstale o app para recriar do zero |
| `no such table: cache_trilhas` vindo da v2 | Falta o `CREATE TABLE` no `_de2Para3` | Confira o bloco `IF NOT EXISTS cache_trilhas` |
| Excluir matéria deixa as sessões no banco | Faltou `PRAGMA foreign_keys = ON` | Ele vai no `onConfigure`, que roda a **cada** abertura |
| O app congela ao registrar sessão, sem erro | `_db` usado dentro do bloco `transaction` | Troque por `txn` em todas as chamadas de dentro do bloco |
| `Física` aparece antes de `Álgebra` | `ORDER BY nome` em vez de `nome_ordenacao` | Ordene pela coluna achatada e confira que `paraLinha()` a preenche |
| `type 'Null' is not a subtype of type 'int'` em `deLinha` | Coluna nova lida com `!` num banco antigo | Use `linha['x'] as int? ?? padrao`, como em `cor_valor` |
| `depend_on_referenced_packages` em `package:meta` | `meta` fora do `pubspec.yaml` | Declare `meta: ^1.16.0` em `dependencies` |
| Total de minutos da matéria fica negativo | `UPDATE` sem `MAX(0, ...)` ao remover | Use `SET minutos = MAX(0, minutos - ?)` |

---

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [03 — Etapa 1: Fundação](03-etapa-1-fundacao.md) | [README do projeto](README.md) | [05 — Etapa 3: Estado com Riverpod](05-etapa-3-estado-com-riverpod.md) |
