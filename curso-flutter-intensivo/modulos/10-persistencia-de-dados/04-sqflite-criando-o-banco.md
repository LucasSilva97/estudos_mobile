# Aula 4 — sqflite: criando o banco

> **Módulo:** 10 - Persistência de Dados · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Justificar, com argumentos concretos, por que matérias e sessões pedem um banco relacional.
- Abrir um banco com `openDatabase` declarando `version`, `onConfigure`, `onCreate` e `onUpgrade`.
- Montar o caminho do arquivo com `getDatabasesPath()` + `p.join`.
- Escrever `CREATE TABLE` com `PRIMARY KEY`, `NOT NULL`, `DEFAULT` e chave estrangeira.
- Listar os cinco tipos de armazenamento do SQLite e dizer como se guarda data e booleano.
- Criar índices e explicar quando eles ajudam e quando atrapalham.
- Implementar o esquema completo das tabelas `materias` e `sessoes` do projeto **Foco**.
- Comparar o padrão *singleton* com injeção de dependência e explicar por que este curso injeta.
- Rodar os testes de banco **no Windows**, sem emulador, com `sqflite_common_ffi`.

## ✅ Pré-requisitos

- [Aula 3 — Arquivos e path_provider](03-arquivos-e-path-provider.md) concluída (o `p.join` volta
  aqui).
- [Aula 1](01-qual-armazenamento-usar.md): a pergunta 2 da árvore de decisão.
- Injeção de dependências — [08 — Injeção de dependências](../08-estado-e-arquitetura/10-injecao-de-dependencias.md).

---

## 📖 Conceito

### Por que um banco relacional

Nas duas aulas anteriores você chegou empiricamente à mesma parede duas vezes: tanto o
`shared_preferences` quanto o arquivo obrigam a **ler tudo, processar em Dart e regravar tudo** a
cada alteração, e não sabem responder perguntas.

Um **banco de dados relacional** resolve exatamente isso. "Relacional" quer dizer que os dados
ficam em **tabelas** (linhas e colunas, como uma planilha) e que as tabelas podem se **relacionar**
entre si — uma sessão de estudo aponta para a matéria a que pertence.

O que você ganha:

| Precisa de… | Sem banco | Com banco |
|---|---|---|
| "as 10 sessões mais recentes" | ler tudo, ordenar em Dart, cortar | `ORDER BY inicio_em DESC LIMIT 10` |
| "quantos minutos de Cálculo em setembro" | ler tudo, filtrar, somar | `SELECT SUM(minutos) WHERE ...` |
| alterar um registro | reescrever o arquivo inteiro | `UPDATE ... WHERE id = ?` |
| apagar a matéria e suas sessões | percorrer e limpar na mão | chave estrangeira `ON DELETE CASCADE` |
| impedir nome vazio | lembrar de validar em todo lugar | `NOT NULL` no esquema |

O banco embutido dos celulares é o **SQLite** — uma biblioteca em C que grava o banco inteiro em
**um único arquivo** e já vem instalada no 🤖 Android e no 🍎 iOS. Você não instala servidor, não
configura porta, não cria usuário. O pacote `sqflite` (**SQ**Lite + **fl**utter + **ite**) é a
ponte entre o Dart e essa biblioteca.

### `openDatabase`: os quatro parâmetros que importam

```dart
final db = await openDatabase(
  caminho,                 // onde o arquivo .db fica
  version: 1,              // versão do ESQUEMA (não do app)
  onConfigure: configurar, // roda SEMPRE, antes de tudo
  onCreate: criar,         // roda UMA vez, quando o arquivo não existe
  onUpgrade: atualizar,    // roda quando version > a versão gravada no arquivo
);
```

O SQLite guarda dentro do próprio arquivo um número chamado `user_version`. O `sqflite` compara
esse número com o `version` que você passou e decide o que chamar:

| Situação | O que roda |
|---|---|
| O arquivo não existe | `onConfigure` → `onCreate` |
| `user_version` == `version` | `onConfigure` |
| `user_version` < `version` | `onConfigure` → `onUpgrade` |
| `user_version` > `version` | `onConfigure` → `onDowngrade` |

Três regras que evitam bugs difíceis:

1. **`version` é a versão do esquema, não do app.** Você pode publicar 40 versões do app com
   `version: 3`. Só incrementa quando a estrutura das tabelas muda.
2. **`onCreate` roda só na primeira vez.** Quem já tem o app instalado **nunca** passa por ele de
   novo — é por isso que a [aula 6](06-migracoes.md) existe.
3. **`onConfigure` roda toda vez.** É o lugar de ligar `PRAGMA`, e em especial:
   ```dart
   await db.execute('PRAGMA foreign_keys = ON');
   ```
   O SQLite vem com chaves estrangeiras **desligadas** por compatibilidade histórica. Sem essa
   linha, o `ON DELETE CASCADE` que você escreveu no `CREATE TABLE` simplesmente não acontece, e
   você fica com sessões órfãs apontando para matérias que não existem mais.

### Onde o arquivo `.db` mora

```dart
final pasta = await getDatabasesPath();
final caminho = p.join(pasta, 'foco.db');
```

`getDatabasesPath()` vem do próprio `sqflite` e devolve a pasta de bancos do app naquela
plataforma. Você **nunca** escreve esse caminho à mão e **nunca** usa
`getTemporaryDirectory()` para banco — a pasta temporária pode ser apagada pelo sistema, e você
perderia os dados do usuário sem nenhum aviso.

### Os cinco tipos de armazenamento do SQLite

O SQLite tem só cinco **classes de armazenamento**:

| Classe | Guarda | Em Dart |
|---|---|---|
| `NULL` | ausência de valor | `null` |
| `INTEGER` | número inteiro com sinal | `int` |
| `REAL` | número de ponto flutuante | `double` |
| `TEXT` | texto (o curso usa UTF-8) | `String` |
| `BLOB` | bytes crus, exatamente como entraram | `Uint8List` |

Repare no que **não** existe: não há tipo booleano, não há tipo data, não há tipo decimal exato.
As convenções do curso:

| Conceito | Coluna | Conversão |
|---|---|---|
| verdadeiro/falso | `INTEGER` | `true` → `1`, `false` → `0` |
| data e hora | `INTEGER` | `data.millisecondsSinceEpoch` ↔ `DateTime.fromMillisecondsSinceEpoch(n)` |
| identificador | `TEXT` | um `uuid` gerado no app |
| duração | `INTEGER` | sempre em **minutos**, uma unidade só no app inteiro |

Guardar data como `INTEGER` (milissegundos desde 1970) é melhor do que como texto porque a
comparação `inicio_em >= ?` funciona numericamente, sem depender de formato nem de fuso.

> O SQLite também é **dinamicamente tipado**: se você declarar `minutos INTEGER` e inserir a
> string `'quarenta'`, ele aceita. A declaração do tipo é uma **afinidade**, uma preferência de
> conversão, não uma trava. Quem garante o tipo é o seu código Dart — mais um motivo para toda
> escrita passar por um DAO.

### Restrições que valem a pena

```sql
CREATE TABLE materias (
  id             TEXT    PRIMARY KEY,
  nome           TEXT    NOT NULL,
  nome_ordenacao TEXT    NOT NULL,
  minutos        INTEGER NOT NULL DEFAULT 0,
  criada_em      INTEGER NOT NULL
);
```

- **`PRIMARY KEY`** — a coluna que identifica a linha de forma única. O banco recusa duas linhas
  com o mesmo `id` e cria um índice automaticamente.
- **`NOT NULL`** — a coluna não pode ficar vazia. É uma regra de negócio expressa no esquema, e
  vale mesmo que amanhã alguém escreva um `insert` esquecendo o campo.
- **`DEFAULT 0`** — se o `insert` não trouxer a coluna, o banco usa esse valor. Isso é o que
  permite inserir uma matéria nova sem repetir `minutos: 0` em todo lugar.
- **`FOREIGN KEY`** — liga uma coluna à chave primária de outra tabela. Com
  `ON DELETE CASCADE`, apagar a matéria apaga as sessões dela automaticamente.

### Índices

Um **índice** é uma estrutura extra que o banco mantém para achar linhas sem varrer a tabela
inteira. É o índice remissivo no fim do livro: ocupa páginas, precisa ser atualizado a cada edição,
e economiza um tempo enorme na busca.

```sql
CREATE INDEX idx_sessoes_materia ON sessoes (materia_id);
```

Crie índice para colunas que aparecem em `WHERE`, em `ORDER BY` ou em junção. **Não** crie índice
para tudo: cada índice deixa `insert`, `update` e `delete` um pouco mais lentos e ocupa espaço. Com
30 matérias você não mede diferença; com 50 mil sessões de estudo, mede muito.

### Singleton × injeção

Você vai encontrar, em quase todo tutorial de `sqflite`, este padrão:

```dart
// PADRÃO COMUM NA INTERNET — este curso NÃO usa
class BancoHelper {
  static final BancoHelper instancia = BancoHelper._();
  BancoHelper._();

  static Database? _db;

  Future<Database> get db async => _db ??= await _abrir();
}
```

**Singleton** (*instância única*) é o padrão em que a classe cria e guarda a si mesma numa
variável estática, e todo mundo usa aquela mesma cópia. Ele resolve um problema real — abrir o
mesmo arquivo de banco duas vezes é desperdício — mas cria três problemas maiores:

1. **Não dá para testar.** Como o DAO chama `BancoHelper.instancia.db` por dentro, não há como
   entregar a ele um banco em memória. Você fica dependente de emulador para testar regra de
   negócio.
2. **Estado global entre testes.** A variável estática sobrevive de um teste para o outro, e um
   teste passa a depender do que o anterior gravou.
3. **Dependência escondida.** Lendo a assinatura `MateriaDao()`, ninguém descobre que ela precisa
   de um banco aberto. A dependência só aparece quando quebra.

A decisão do curso, e a que o [Anexo A.8 de validação](../../06-relatorio-de-validacao.md)
confirmou na prática:

> **O DAO recebe o `Database` pronto pelo construtor.** Quem abre o banco é o ponto de montagem
> do app (o `main`), uma vez só.

```dart
// main.dart (mundo real)
final db = await BancoFoco.abrir();
final dao = MateriaDao(db);

// teste (Windows, sem emulador)
final db = await databaseFactory.openDatabase(inMemoryDatabasePath, options: ...);
final dao = MateriaDao(db);
```

A mesma classe, dois ambientes, zero `if`. Foi assim que **10 testes de banco** rodaram nesta
máquina, no Windows, sem emulador.

---

## 💡 Analogia

O `shared_preferences` é o post-it; o arquivo é a pasta; o banco é o **fichário com índice**.

`CREATE TABLE` é você decidir, antes de guardar a primeira ficha, quais campos toda ficha vai ter
e quais são obrigatórios. `NOT NULL` é a linha do formulário que você recusa em branco no balcão.
`PRIMARY KEY` é o número de matrícula: dois alunos não podem ter o mesmo. `FOREIGN KEY` é a regra
de que a ficha de uma prova precisa citar uma matrícula que existe — e `ON DELETE CASCADE` é a
política de que, ao cancelar a matrícula, as provas daquele aluno saem junto.

O limite da analogia: no fichário de papel, ninguém impede você de guardar uma ficha errada. No
banco, a restrição é aplicada no momento da gravação e a operação **falha**. Isso é uma vantagem,
não um incômodo: é melhor descobrir o dado inválido na gravação do que seis meses depois, num
relatório.

---

## 🧪 Exemplo mínimo

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

Future<Database> abrirBancoMinimo() async {
  final pasta = await getDatabasesPath();
  final caminho = p.join(pasta, 'exemplo.db');

  return openDatabase(
    caminho,
    version: 1,
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    onCreate: (db, versao) async {
      await db.execute(
        'CREATE TABLE materias ('
        'id TEXT PRIMARY KEY, '
        'nome TEXT NOT NULL'
        ')',
      );
    },
  );
}
```

Três observações sobre o SQL escrito assim:

- Cada `db.execute` roda **um** comando. Não coloque dois `CREATE TABLE` separados por `;` numa
  chamada só — use `execute` duas vezes.
- A concatenação de strings adjacentes do Dart (`'abc' 'def'` vira `'abcdef'`) mantém o SQL
  legível e alinhado, sem precisar de `'''`.
- `CREATE TABLE` não leva ponto e vírgula no fim quando vai dentro de `execute`.

---

## 📱 Aplicando no Flutter

### O esquema do Foco, versão 1

Duas tabelas, exatamente as do projeto final:

```text
materias                          sessoes
────────────────────────────      ──────────────────────────────────
id             TEXT  PK           id          TEXT    PK
nome           TEXT  NOT NULL     materia_id  TEXT    NOT NULL ──┐
nome_ordenacao TEXT  NOT NULL     inicio_em   INTEGER NOT NULL   │
minutos        INTEGER NOT NULL   minutos     INTEGER NOT NULL   │
criada_em      INTEGER NOT NULL                                  │
     ▲───────────────────────────────────────────────────────────┘
                     FOREIGN KEY ... ON DELETE CASCADE
```

A coluna `nome_ordenacao` vai parecer estranha agora: é o nome da matéria **sem acento e em
minúsculas**, guardado só para ordenar. Ela existe por causa de um bug real do SQLite com o
alfabeto português, que a [aula 5](05-sqflite-crud.md) demonstra com um teste. Por enquanto,
aceite que ela é necessária e repare que ela é `NOT NULL` e indexada.

### 🪟 Onde este código roda

| Ambiente | Roda? | Como |
|---|---|---|
| 🤖 Emulador ou aparelho Android | ✅ | `flutter run` |
| 🍎 Simulador ou iPhone | ✅ | `flutter run` — 🍎 SÓ NO MAC |
| 🪟 Teste no seu Windows | ✅ | `flutter test`, com `sqflite_common_ffi` |
| 🪟 App Flutter para desktop Windows | ⚠️ | o plugin `sqflite` cobre Android e iOS; para desktop existe o `sqflite_common_ffi`, que este curso usa **em testes** |

Ou seja: você desenvolve e **testa a camada de dados inteira no Windows**, e roda o app no
emulador Android.

---

## 💻 Código completo

> **Arquivo:** `foco_dados/lib/core/banco/texto.dart`
> **Como executar:** `flutter test test/banco_foco_test.dart`

```dart
/// Utilitários de texto usados pelo banco.
class Texto {
  const Texto._();

  /// Devolve o texto em minúsculas e sem acento, para uso em ordenação e
  /// busca. Este é o código validado na suíte de testes do curso.
  ///
  /// A tabela de maiúsculas existe como rede de segurança: como o texto é
  /// passado por `toLowerCase()` antes do laço, na prática só a metade
  /// minúscula é consultada.
  static String normalizar(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
    final buffer = StringBuffer();
    for (final unidade in texto.toLowerCase().runes) {
      final caractere = String.fromCharCode(unidade);
      final indice = comAcento.indexOf(caractere);
      buffer.write(indice >= 0 ? semAcento[indice] : caractere);
    }
    return buffer.toString();
  }
}
```

> **Arquivo:** `foco_dados/lib/core/banco/banco_foco.dart`
> **Como executar:** `flutter test test/banco_foco_test.dart`

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Define o esquema do banco do Foco e sabe abri-lo.
///
/// Esta classe **não** guarda a instância do banco em variável estática.
/// Quem abre é o ponto de montagem do app (`main`), que passa o
/// [Database] adiante para os DAOs. Isso é o que torna a camada de dados
/// testável no Windows, sem emulador.
class BancoFoco {
  const BancoFoco._();

  /// Versão do ESQUEMA. Só muda quando a estrutura das tabelas muda —
  /// nunca porque o app ganhou uma tela nova.
  static const int versaoAtual = 1;

  static const String nomeDoArquivo = 'foco.db';

  /// Abre (ou cria) o banco no aparelho.
  ///
  /// Só funciona com o Flutter rodando em Android ou iOS. Nos testes, o
  /// banco é aberto em memória — veja `test/banco_foco_test.dart`.
  static Future<Database> abrir() async {
    final pasta = await getDatabasesPath();
    final caminho = p.join(pasta, nomeDoArquivo);

    return openDatabase(
      caminho,
      version: versaoAtual,
      onConfigure: configurar,
      onCreate: criar,
      onUpgrade: atualizar,
    );
  }

  /// Roda em TODA abertura, antes de qualquer outra coisa.
  ///
  /// O SQLite nasce com chave estrangeira desligada por compatibilidade.
  /// Sem esta linha, `ON DELETE CASCADE` não acontece e o banco acumula
  /// sessões órfãs.
  static Future<void> configurar(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Roda UMA vez, quando o arquivo do banco ainda não existe.
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

    // Índice da coluna usada em ORDER BY. Sem ele, ordenar a lista de
    // matérias obriga o banco a varrer a tabela inteira.
    await db.execute(
      'CREATE INDEX idx_materias_nome_ordenacao '
      'ON materias (nome_ordenacao)',
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

    // Índice da coluna usada para achar as sessões de uma matéria.
    await db.execute(
      'CREATE INDEX idx_sessoes_materia ON sessoes (materia_id)',
    );

    // Índice da coluna usada para filtrar e ordenar por período.
    await db.execute(
      'CREATE INDEX idx_sessoes_inicio ON sessoes (inicio_em)',
    );
  }

  /// Roda quando o aparelho tem uma versão antiga do esquema.
  ///
  /// Na versão 1 não há nada a migrar, mas o parâmetro já fica declarado:
  /// esquecer de declará-lo é como o app quebra na primeira atualização
  /// de esquema. A aula 6 preenche este método.
  static Future<void> atualizar(
    Database db,
    int versaoAnterior,
    int versaoNova,
  ) async {
    // Intencionalmente vazio na versão 1 do esquema.
  }
}
```

O teste, rodando no seu Windows:

> **Arquivo:** `foco_dados/test/banco_foco_test.dart`
> **Como executar:** `flutter test test/banco_foco_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_dados/core/banco/banco_foco.dart';
import 'package:foco_dados/core/banco/texto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Padrão validado do curso para testar banco em desktop.
  sqfliteFfiInit(); // inicializa o SQLite nativo do desktop
  databaseFactory = databaseFactoryFfi; // troca a fábrica padrão

  late Database db;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath, // banco em memória: rápido e isolado
      options: OpenDatabaseOptions(
        version: BancoFoco.versaoAtual,
        onConfigure: BancoFoco.configurar,
        onCreate: BancoFoco.criar,
        onUpgrade: BancoFoco.atualizar,
      ),
    );
  });

  tearDown(() async => db.close());

  group('esquema', () {
    test('cria as tabelas materias e sessoes', () async {
      final tabelas = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final nomes = tabelas.map((t) => t['name'] as String).toSet();
      expect(nomes, containsAll(<String>['materias', 'sessoes']));
    });

    test('materias tem as cinco colunas esperadas', () async {
      final colunas = await db.rawQuery('PRAGMA table_info(materias)');
      final nomes = colunas.map((c) => c['name'] as String).toList();
      expect(nomes, <String>[
        'id',
        'nome',
        'nome_ordenacao',
        'minutos',
        'criada_em',
      ]);
    });

    test('cria os três índices', () async {
      final indices = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index' "
        "AND name LIKE 'idx_%'",
      );
      final nomes = indices.map((i) => i['name'] as String).toSet();
      expect(nomes, <String>{
        'idx_materias_nome_ordenacao',
        'idx_sessoes_materia',
        'idx_sessoes_inicio',
      });
    });

    test('a versão gravada no arquivo é a versão do esquema', () async {
      expect(await db.getVersion(), BancoFoco.versaoAtual);
    });
  });

  group('restrições', () {
    test('NOT NULL recusa matéria sem nome', () async {
      expect(
        () => db.insert('materias', <String, Object?>{
          'id': 'm1',
          'nome_ordenacao': 'x',
          'criada_em': 0,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('PRIMARY KEY recusa id repetido', () async {
      await db.insert('materias', <String, Object?>{
        'id': 'm1',
        'nome': 'Cálculo I',
        'nome_ordenacao': 'calculo i',
        'criada_em': 0,
      });

      expect(
        () => db.insert('materias', <String, Object?>{
          'id': 'm1',
          'nome': 'Outra',
          'nome_ordenacao': 'outra',
          'criada_em': 0,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('DEFAULT 0 preenche minutos quando não vem no insert', () async {
      await db.insert('materias', <String, Object?>{
        'id': 'm1',
        'nome': 'Cálculo I',
        'nome_ordenacao': 'calculo i',
        'criada_em': 0,
      });
      final linha = (await db.query('materias')).single;
      expect(linha['minutos'], 0);
    });

    test('FOREIGN KEY recusa sessão de matéria inexistente', () async {
      expect(
        () => db.insert('sessoes', <String, Object?>{
          'id': 's1',
          'materia_id': 'nao_existe',
          'inicio_em': 0,
          'minutos': 25,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('ON DELETE CASCADE apaga as sessões junto com a matéria', () async {
      await db.insert('materias', <String, Object?>{
        'id': 'm1',
        'nome': 'Cálculo I',
        'nome_ordenacao': 'calculo i',
        'criada_em': 0,
      });
      await db.insert('sessoes', <String, Object?>{
        'id': 's1',
        'materia_id': 'm1',
        'inicio_em': 1,
        'minutos': 25,
      });

      await db.delete('materias', where: 'id = ?', whereArgs: <Object?>['m1']);

      expect(await db.query('sessoes'), isEmpty);
    });
  });

  group('Texto.normalizar', () {
    test('tira acento e baixa a caixa', () {
      expect(Texto.normalizar('Álgebra Linear'), 'algebra linear');
      expect(Texto.normalizar('Física'), 'fisica');
      expect(Texto.normalizar('Redação'), 'redacao');
      expect(Texto.normalizar('História'), 'historia');
    });

    test('deixa intacto o que não tem acento', () {
      expect(Texto.normalizar('Calculo 2'), 'calculo 2');
    });
  });
}
```

Saída esperada:

```text
00:04 +12: All tests passed!
```

---

## 🔍 Explicando o código

- **`sqfliteFfiInit()` + `databaseFactory = databaseFactoryFfi`** — `sqflite` normalmente fala com
  o SQLite do Android/iOS por um canal de plataforma. `sqflite_common_ffi` troca essa implementação
  pela FFI (*Foreign Function Interface* — a forma de o Dart chamar código C diretamente), usando
  o SQLite do próprio sistema desktop. É a razão de você poder testar banco no Windows.
- **`inMemoryDatabasePath`** — uma constante do `sqflite` que significa "banco em memória". Ele
  nasce vazio a cada `setUp` e morre no `tearDown`, então nenhum teste contamina o outro.
- **`OpenDatabaseOptions`** — a forma de passar `version`, `onCreate` e companhia quando se usa
  `databaseFactory.openDatabase` em vez da função `openDatabase`.
- **`onConfigure: BancoFoco.configurar`** no teste — sem isso, `PRAGMA foreign_keys = ON` não roda
  e os dois testes de chave estrangeira falham. O teste está exercitando a **mesma** configuração
  do app de verdade, e é isso que dá valor a ele.
- **`sqlite_master`** é a tabela interna em que o SQLite guarda a definição de tudo que existe no
  banco: tabelas, índices, gatilhos, visões. Consultá-la é a forma de um teste verificar o
  esquema.
- **`PRAGMA table_info(materias)`** devolve uma linha por coluna, com `name`, `type`, `notnull`,
  `dflt_value` e `pk`. É a ferramenta de inspeção que a [aula 6](06-migracoes.md) usa para provar
  que uma migração rodou.
- **`db.getVersion()`** lê o `user_version` gravado dentro do arquivo. É o número que o `sqflite`
  compara com o seu `version` para decidir entre `onCreate` e `onUpgrade`.
- **`throwsA(isA<DatabaseException>())`** — `DatabaseException` é a exceção do `sqflite` para
  qualquer erro vindo do SQLite: violação de `NOT NULL`, de `PRIMARY KEY`, de `FOREIGN KEY`,
  sintaxe SQL errada. A mensagem dela carrega o texto original do SQLite, que é onde está a
  informação útil.
- **`const BancoFoco._();`** — o `_` no nome torna o construtor privado, e a classe passa a ser
  só um agrupador de membros estáticos. Ninguém consegue escrever `BancoFoco()` por engano.
- **`atualizar` vazio, mas declarado** — parece supérfluo hoje. Não é: quando você bumpar a
  `versaoAtual` para 2, o parâmetro já está no lugar certo e você só preenche o corpo. Esquecer de
  declarar `onUpgrade` faz o app de quem já tinha a versão antiga abrir com o esquema velho.

---

## 🤖🍎 Android × iOS

A API do `sqflite` é idêntica nas duas plataformas. A diferença real é **onde o arquivo mora** e
**o que acontece com ele no backup**.

| Item | 🤖 Android | 🍎 iOS |
|---|---|---|
| Pasta devolvida por `getDatabasesPath()` | `/data/data/<applicationId>/databases` | uma pasta dentro do sandbox do app; o caminho exato vem da função, e não deve ser escrito à mão |
| Formato do arquivo | `foco.db` (mais `foco.db-journal` ou `-wal`/`-shm` durante escritas) | idêntico |
| Desinstalar | apaga o banco | apaga o banco |
| Backup do sistema | entra no Auto Backup, se `android:allowBackup` estiver ativo | entra no backup do iCloud |
| Inspecionar durante o desenvolvimento | `adb shell run-as <applicationId> ls databases/`, ou `adb exec-out run-as <applicationId> cat databases/foco.db > foco.db` para trazer o arquivo ao PC | pelo Xcode: Window → Devices and Simulators → app → *Download Container* |

Os arquivos vizinhos com sufixo `-journal`, `-wal` e `-shm` **fazem parte do banco**. Eles guardam
transações em andamento. Se você um dia copiar o banco para depurar, copie os três ou feche o
banco antes — copiar só o `.db` pode trazer uma versão sem as últimas escritas.

> 🍎 **SÓ NO MAC.** Baixar o container de um iPhone e abrir o `.db` num visualizador de SQLite
> exige macOS + Xcode. No Windows você pode ler e entender o processo, mas não executá-lo — e,
> mais importante, **não precisa dele para este módulo**: seus testes com `sqflite_common_ffi`
> exercitam exatamente o mesmo SQL. Veja
> [16-build-ios/01-por-que-exige-macos.md](../16-build-ios/01-por-que-exige-macos.md).

---

## ⚠️ Erros comuns

1. **Esquecer `PRAGMA foreign_keys = ON`.**
   O `ON DELETE CASCADE` fica decorativo e o banco acumula sessões órfãs. O sintoma é cruel: o app
   funciona, as estatísticas é que ficam erradas. Coloque no `onConfigure`, nunca no `onCreate`.

2. **Achar que mexer no `onCreate` atualiza quem já tem o app.**
   `onCreate` **não roda** para quem já instalou. Alterar o `CREATE TABLE` só afeta instalações
   novas. Quem já tem o app continua com o esquema antigo até você escrever a migração
   ([aula 6](06-migracoes.md)).

3. **Incrementar `version` sem escrever o `onUpgrade` correspondente.**
   O app abre e o `onUpgrade` roda sem fazer nada; o `user_version` sobe; o esquema continua o
   antigo. A partir daí, o banco mente sobre a própria versão.

4. **Dois comandos SQL num `execute` só.**
   ```dart
   await db.execute('CREATE TABLE a (...); CREATE TABLE b (...)'); // ERRADO
   ```
   Chame `execute` uma vez por comando.

5. **Guardar data como texto em formato local.**
   `'14/09/2026'` não ordena e não compara. Use `INTEGER` com `millisecondsSinceEpoch`.

6. **Criar índice em todas as colunas "por precaução".**
   Cada índice custa espaço e deixa as escritas mais lentas. Crie quando a coluna aparece em
   `WHERE`, `ORDER BY` ou junção.

7. **Abrir o banco dentro de um widget, ou a cada uso.**
   Abrir o banco é caro e o resultado é compartilhado. Abra uma vez no ponto de montagem e passe
   o `Database` adiante.

8. **`DatabaseException (database_closed)`.**
   Você chamou `db.close()` e continuou usando a instância — normalmente porque duas partes do
   app abriram e fecharam o banco por conta própria. É mais um sintoma do padrão singleton
   descontrolado; com injeção, existe um dono claro do ciclo de vida.

9. **Rodar `flutter test` num teste de banco sem `sqfliteFfiInit()`.**
   A falha é `MissingPluginException` ou `Unsupported operation: databaseFactory not initialized`.
   As duas linhas de `sqflite_common_ffi` precisam vir **antes** de qualquer abertura de banco, no
   topo do `main()` do teste.

---

## 🛠️ Exercício guiado

Vamos acrescentar ao esquema a tabela `metas_por_materia`, que guarda uma meta semanal específica
por matéria.

**Passo 1.** Em `BancoFoco.criar`, depois dos índices de `sessoes`, acrescente:

```dart
await db.execute(
  'CREATE TABLE metas_por_materia ('
  '  materia_id      TEXT    PRIMARY KEY,'
  '  minutos_semana  INTEGER NOT NULL DEFAULT 0,'
  '  ativa           INTEGER NOT NULL DEFAULT 1,'
  '  FOREIGN KEY (materia_id) REFERENCES materias (id)'
  '    ON DELETE CASCADE'
  ')',
);
```

Repare em `ativa INTEGER NOT NULL DEFAULT 1`: é o booleano do SQLite, com `1` para verdadeiro.

**Passo 2.** Escreva os testes:

```dart
test('a meta por matéria some quando a matéria é apagada', () async {
  await db.insert('materias', <String, Object?>{
    'id': 'm1',
    'nome': 'Cálculo I',
    'nome_ordenacao': 'calculo i',
    'criada_em': 0,
  });
  await db.insert('metas_por_materia', <String, Object?>{
    'materia_id': 'm1',
    'minutos_semana': 180,
  });

  await db.delete('materias', where: 'id = ?', whereArgs: <Object?>['m1']);

  expect(await db.query('metas_por_materia'), isEmpty);
});

test('ativa vem como 1 por padrão', () async {
  await db.insert('materias', <String, Object?>{
    'id': 'm1',
    'nome': 'Cálculo I',
    'nome_ordenacao': 'calculo i',
    'criada_em': 0,
  });
  await db.insert('metas_por_materia', <String, Object?>{
    'materia_id': 'm1',
    'minutos_semana': 180,
  });

  final linha = (await db.query('metas_por_materia')).single;
  expect(linha['ativa'], 1);
});
```

**Passo 3.** Rode:

```powershell
flutter test test/banco_foco_test.dart
```

**Passo 4 — a pergunta de migração.** Você acabou de alterar o `onCreate`. Um usuário que já tem o
app instalado com a versão 1 do esquema vai receber essa tabela? Escreva a resposta antes de ler a
próxima linha.

**Não.** `onCreate` só roda em instalação nova. Para o aparelho de quem já usa o app, é preciso
subir `versaoAtual` para 2 e criar a tabela dentro de `onUpgrade`. É esse o assunto da
[aula 6](06-migracoes.md) — e agora você sabe por que ela não é opcional.

**Passo 5.**

```powershell
flutter analyze
```

Saída esperada: `No issues found!`

---

## 📝 Exercícios independentes
→ Exercícios completos em [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md)

---

## 🏆 Desafio opcional

Acrescente ao esquema a restrição `CHECK` e descubra como o SQLite reage.

```sql
minutos INTEGER NOT NULL CHECK (minutos >= 0)
```

`CHECK` é uma restrição que valida o valor no momento da gravação. Faça isto:

1. Acrescente o `CHECK (minutos >= 0)` na coluna `minutos` da tabela `sessoes`.
2. Escreva um teste que tenta inserir `minutos: -5` e espera `DatabaseException`.
3. Imprima a mensagem da exceção (`catch (e) { debugPrint('$e'); }`) e leia o texto original do
   SQLite. Você vai ver algo como `CHECK constraint failed`.
4. **Depois**, responda: essa validação substitui a validação no formulário do app? Justifique.

A resposta esperada é "não, ela complementa". A validação de formulário existe para dar uma
mensagem gentil ao usuário **antes** de tentar salvar; a restrição do banco existe para garantir
que nenhum caminho de código — nem uma importação, nem um teste, nem um bug futuro — consiga
gravar lixo. As duas defesas são necessárias e nenhuma delas dispensa a outra.

---

## 📌 Resumo

- Banco relacional resolve o que preferências e arquivos não resolvem: **consultar, filtrar,
  ordenar, alterar um registro e relacionar tabelas**.
- SQLite é embutido no 🤖 Android e no 🍎 iOS e guarda o banco todo em **um arquivo**; `sqflite`
  é a ponte Dart.
- `openDatabase` recebe `version` (do **esquema**), `onConfigure` (roda sempre), `onCreate` (roda
  uma vez) e `onUpgrade` (roda quando a versão sobe).
- `PRAGMA foreign_keys = ON` no `onConfigure` é obrigatório: sem ele, `ON DELETE CASCADE` não
  funciona.
- O caminho vem de `getDatabasesPath()` + `p.join`. Nunca escreva o caminho à mão, nunca use a
  pasta temporária.
- O SQLite tem cinco classes: `NULL`, `INTEGER`, `REAL`, `TEXT`, `BLOB`. Booleano vira `0`/`1`;
  data vira `INTEGER` com `millisecondsSinceEpoch`.
- `PRIMARY KEY`, `NOT NULL`, `DEFAULT`, `FOREIGN KEY` e `CHECK` colocam regra de negócio dentro do
  esquema. Índice acelera `WHERE` e `ORDER BY` e custa nas escritas.
- O esquema do Foco na versão 1 tem `materias` (com `nome_ordenacao` indexada) e `sessoes` (com
  chave estrangeira em cascata).
- O curso **injeta** o `Database` em vez de usar singleton: é o que permite rodar os testes de
  banco no Windows, em memória, sem emulador.

---

## ☑️ Checklist de domínio

- [ ] Dou dois argumentos concretos para preferir banco a arquivo em uma lista de sessões.
- [ ] Escrevo `openDatabase` com os quatro parâmetros de cabeça.
- [ ] Explico quando `onCreate` roda e quando **não** roda.
- [ ] Sei por que `PRAGMA foreign_keys = ON` vai no `onConfigure` e não no `onCreate`.
- [ ] Monto o caminho do banco com `getDatabasesPath()` + `p.join`.
- [ ] Listo as cinco classes de armazenamento do SQLite e digo como guardo `bool` e `DateTime`.
- [ ] Escrevo `CREATE TABLE` com `PRIMARY KEY`, `NOT NULL`, `DEFAULT` e `FOREIGN KEY ... ON DELETE
      CASCADE`.
- [ ] Explico o custo de um índice e quando ele vale a pena.
- [ ] Desenho o esquema `materias` + `sessoes` do Foco sem consultar.
- [ ] Explico três problemas do singleton e digo como a injeção resolve cada um.
- [ ] `flutter test test/banco_foco_test.dart` termina com `All tests passed!` no meu Windows.

---

## 📚 Referências oficiais

- [sqflite — pub.dev](https://pub.dev/packages/sqflite)
- [sqflite_common_ffi — pub.dev](https://pub.dev/packages/sqflite_common_ffi)
- [Persist data with SQLite — docs.flutter.dev](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Datatypes in SQLite — sqlite.org](https://www.sqlite.org/datatype3.html)
- [CREATE TABLE — sqlite.org](https://www.sqlite.org/lang_createtable.html)
- [SQLite Foreign Key Support — sqlite.org](https://www.sqlite.org/foreignkeys.html)
- [CREATE INDEX — sqlite.org](https://www.sqlite.org/lang_createindex.html)
- [PRAGMA statements — sqlite.org](https://www.sqlite.org/pragma.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Arquivos e path_provider](03-arquivos-e-path-provider.md) | [README](README.md) | [Aula 5 — sqflite: CRUD](05-sqflite-crud.md) |
