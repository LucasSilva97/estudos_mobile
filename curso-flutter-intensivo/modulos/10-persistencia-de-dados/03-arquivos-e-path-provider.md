# Aula 3 — Arquivos e path_provider

> **Módulo:** 10 - Persistência de Dados · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Explicar a diferença entre `getApplicationDocumentsDirectory`, `getApplicationSupportDirectory`
  e `getTemporaryDirectory`, e escolher a certa para cada caso.
- Montar caminhos de arquivo com `package:path` de forma que funcione em 🤖 Android, 🍎 iOS e 🪟
  Windows.
- Escrever e ler texto com `File.writeAsString` e `File.readAsString`.
- Tratar o caso "o arquivo ainda não existe" sem deixar exceção vazar para a interface.
- Criar subpastas com `Directory.create(recursive: true)` e gravar com segurança usando arquivo
  temporário + `rename`.
- Entender por que 🍎 a pasta de documentos do iOS entra no backup do iCloud e a temporária não.
- Escrever toda essa camada de forma testável no Windows, sem emulador.

## ✅ Pré-requisitos

- [Aula 2 — shared_preferences](02-shared-preferences.md) concluída.
- [Aula 1 — Qual armazenamento usar](01-qual-armazenamento-usar.md): a pergunta 3 da árvore.
- Exceções — [04 — Exceptions](../04-dart-avancado/01-exceptions.md).

---

## 📖 Conceito

Quando o dado é grande, binário ou pensado para sair do app (um relatório em CSV, uma foto, um PDF
gerado), ele não cabe numa preferência nem faz sentido numa tabela. Ele é um **arquivo**.

Escrever arquivo em Dart é a classe `File`, de `dart:io` — a mesma que você usaria num programa de
terminal. A diferença em mobile é uma só, e é decisiva: **você não escolhe a pasta**. O sistema
operacional dá ao seu app um punhado de pastas pré-definidas dentro do sandbox, cada uma com
regras próprias de duração e de backup. Quem descobre o caminho dessas pastas é o pacote
`path_provider`.

### As três pastas que este curso usa

| Função do `path_provider` | Duração | Entra no backup? | Use para |
|---|---|---|---|
| `getApplicationDocumentsDirectory()` | permanente, até o usuário apagar | **sim** | conteúdo criado pelo usuário que ele perderia se sumisse: exportações, anotações, anexos |
| `getApplicationSupportDirectory()` | permanente | **sim** | dados internos do app que o usuário não vê nem nomeia: índices, arquivos de estado, bancos auxiliares |
| `getTemporaryDirectory()` | **o sistema pode apagar a qualquer momento** | **não** | cache, download em andamento, rascunho descartável, arquivo intermediário |

Duas frases para gravar:

> **Se o usuário ficaria bravo ao perder, vai em documentos.**
> **Se o app consegue recriar sozinho, vai em temporário.**

Existem outras funções no pacote (`getExternalStorageDirectory`, por exemplo), mas várias são
**específicas de uma plataforma** e devolvem `null` ou lançam exceção na outra. O curso fica nas
três acima, que funcionam em 🤖 Android e 🍎 iOS igualmente.

### Por que `package:path` e não concatenar texto

Você pode pensar em montar o caminho assim:

```dart
final caminho = pasta.path + '/relatorios/setembro.csv'; // ERRADO
```

Isso quebra por dois motivos. Primeiro, o separador de pastas muda por sistema: 🤖 Android e 🍎
iOS usam `/`, 🪟 Windows usa `\`. Seus **testes rodam no Windows**, então esse código falha logo
na primeira execução da sua máquina. Segundo, `pasta.path` pode ou não terminar com separador, e
você acaba com `//` no meio do caminho.

A solução é o pacote `path`, oficial do time Dart:

```dart
import 'package:path/path.dart' as p;

final caminho = p.join(pasta.path, 'relatorios', 'setembro.csv');
```

`p.join` usa o separador certo do sistema onde o código está rodando e nunca duplica separadores.
O apelido `as p` é convenção quase universal: sem ele, o nome `join` colide com o `join` de
`Iterable` e o código fica ambíguo para quem lê.

Funções de `package:path` que valem conhecer:

| Função | O que faz | Exemplo |
|---|---|---|
| `p.join(a, b, c)` | monta caminho | `p.join('/dados', 'rel', 'a.csv')` |
| `p.basename(caminho)` | nome do arquivo com extensão | `a.csv` |
| `p.basenameWithoutExtension` | nome sem extensão | `a` |
| `p.extension(caminho)` | extensão com ponto | `.csv` |
| `p.dirname(caminho)` | pasta que contém | `/dados/rel` |
| `p.setExtension(caminho, '.txt')` | troca a extensão | `/dados/rel/a.txt` |

---

## 💡 Analogia

As três pastas são três gavetas da sua escrivaninha:

- **Documentos** é a gaveta onde você guarda o trabalho impresso e as provas antigas. Se a casa
  pegar fogo, é o que você quer no seguro (o backup).
- **Suporte** é a gaveta das ferramentas: grampeador, tesoura, cartucho reserva. Você precisa, mas
  não é "seu conteúdo" — se sumir, você recompra igual.
- **Temporário** é a lixeira ao lado da mesa. Você joga rascunho lá e a faxina esvazia sem
  perguntar. É por isso que você nunca joga a prova ali.

O limite da analogia: a faxina do celular esvazia a lixeira **enquanto você ainda está usando a
mesa**, quando o armazenamento aperta. Por isso todo código que lê de `getTemporaryDirectory()`
precisa aceitar que o arquivo pode ter sumido entre a gravação e a leitura.

---

## 🧪 Exemplo mínimo

```dart
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<void> exemplo() async {
  // 1. Descobrir a pasta (assíncrono: conversa com o código nativo)
  final pasta = await getApplicationDocumentsDirectory();

  // 2. Montar o caminho de forma segura
  final caminho = p.join(pasta.path, 'anotacao.txt');
  final arquivo = File(caminho);

  // 3. Escrever
  await arquivo.writeAsString('Estudei 45 minutos de Cálculo.');

  // 4. Ler, tratando a ausência
  if (await arquivo.exists()) {
    final texto = await arquivo.readAsString();
    print(texto);
  }

  // 5. Apagar
  if (await arquivo.exists()) {
    await arquivo.delete();
  }
}
```

Note que **nada disso é síncrono**. Existem versões `writeAsStringSync` e `readAsStringSync`, mas
elas travam a thread da interface durante a operação de disco. Em mobile, sempre a versão
assíncrona.

### `FileMode`: sobrescrever ou acrescentar

```dart
// Padrão: apaga o conteúdo anterior e grava do zero
await arquivo.writeAsString(conteudo);

// Acrescenta ao final, sem apagar o que já havia
await arquivo.writeAsString(linha, mode: FileMode.append);

// Garante que o sistema empurrou os bytes para o disco antes do Future resolver
await arquivo.writeAsString(conteudo, flush: true);
```

---

## 📱 Aplicando no Flutter

O Foco usa arquivo para duas coisas:

1. **Exportar o relatório de estudo em CSV** (*Comma-Separated Values* — um texto em que cada
   linha é um registro e as colunas são separadas por vírgula ou ponto e vírgula; abre no Excel e
   no Google Planilhas). Isso é conteúdo do usuário → **documentos**.
2. **Guardar o rascunho da anotação da sessão** enquanto o cronômetro roda, para não perder o
   texto se o app for encerrado pelo sistema. Isso é descartável → **temporário**.

### O problema de testabilidade, e a solução

`path_provider` é um plugin nativo. Num teste `flutter test` puro, chamar
`getApplicationDocumentsDirectory()` falha: não há Android nem iOS do outro lado do canal.

A saída não é desistir do teste — é **isolar a dependência da plataforma num ponto só**. O
exportador não chama `path_provider`: ele **recebe** as pastas prontas. Quem chama o plugin é uma
única classe de fronteira, `PastasDoApp`, montada quando o app de verdade sobe.

```text
main()  →  PastasDoApp.reais()  ─┐
                                 ├→  ExportadorDeEstudo(documentos, temporaria)
teste   →  pastas temporárias  ──┘
```

Esse é o mesmo princípio de [09 — Camada de dados testável](../09-consumo-de-api/07-camada-de-dados-testavel.md):
a fronteira com o mundo externo fica fina e o miolo, testável.

---

## 💻 Código completo

> **Arquivo:** `foco_dados/lib/core/arquivos/pastas_do_app.dart`
> **Como executar:** faz parte do app; a execução é validada pelo teste do exportador

```dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Fronteira única entre o app e o plugin `path_provider`.
///
/// Todo o resto do código recebe [Directory] já pronto e, por isso, é
/// testável no Windows sem emulador.
class PastasDoApp {
  const PastasDoApp({
    required this.documentos,
    required this.suporte,
    required this.temporaria,
  });

  /// Conteúdo do usuário. Permanente e incluído no backup do sistema.
  final Directory documentos;

  /// Dados internos do app. Permanente e incluído no backup do sistema.
  final Directory suporte;

  /// Descartável. O sistema pode apagar a qualquer momento; fora do backup.
  final Directory temporaria;

  /// Pergunta ao sistema operacional onde ficam as três pastas.
  ///
  /// Só pode ser chamada com o Flutter em execução em um aparelho,
  /// emulador ou simulador — nunca dentro de um teste `flutter test` puro.
  static Future<PastasDoApp> reais() async {
    final documentos = await getApplicationDocumentsDirectory();
    final suporte = await getApplicationSupportDirectory();
    final temporaria = await getTemporaryDirectory();
    return PastasDoApp(
      documentos: documentos,
      suporte: suporte,
      temporaria: temporaria,
    );
  }
}
```

> **Arquivo:** `foco_dados/lib/core/arquivos/exportador_de_estudo.dart`
> **Como executar:** `flutter test test/exportador_de_estudo_test.dart`

```dart
import 'dart:io';

import 'package:path/path.dart' as p;

/// Uma linha do relatório exportado.
class LinhaDeRelatorio {
  const LinhaDeRelatorio({
    required this.data,
    required this.materia,
    required this.minutos,
  });

  final DateTime data;
  final String materia;
  final int minutos;
}

/// Grava e lê os arquivos do Foco.
///
/// Recebe as pastas prontas: não conhece `path_provider` e, por isso,
/// roda em teste no Windows com pastas temporárias de verdade.
class ExportadorDeEstudo {
  const ExportadorDeEstudo({
    required this.pastaDeDocumentos,
    required this.pastaTemporaria,
  });

  final Directory pastaDeDocumentos;
  final Directory pastaTemporaria;

  static const String _subpastaRelatorios = 'relatorios';
  static const String _arquivoDeRascunho = 'rascunho_de_sessao.txt';

  /// Caminho do relatório de um mês, montado com `p.join` para funcionar
  /// em Android, iOS e Windows com o separador correto de cada um.
  String caminhoDoRelatorio(int ano, int mes) {
    final nome = 'foco-${ano.toString().padLeft(4, '0')}'
        '-${mes.toString().padLeft(2, '0')}.csv';
    return p.join(pastaDeDocumentos.path, _subpastaRelatorios, nome);
  }

  /// Exporta as sessões do mês em CSV e devolve o arquivo criado.
  ///
  /// Usa separador `;` porque o Excel em português do Brasil interpreta a
  /// vírgula como separador decimal, e um CSV com vírgula abre embaralhado.
  Future<File> exportarCsv({
    required int ano,
    required int mes,
    required List<LinhaDeRelatorio> linhas,
  }) async {
    final destino = File(caminhoDoRelatorio(ano, mes));

    // A subpasta pode não existir. `recursive: true` cria toda a árvore.
    await destino.parent.create(recursive: true);

    final buffer = StringBuffer()..writeln('data;materia;minutos');
    for (final linha in linhas) {
      final dia = linha.data.day.toString().padLeft(2, '0');
      final mesDaLinha = linha.data.month.toString().padLeft(2, '0');
      final nome = linha.materia.replaceAll(';', ',');
      buffer.writeln('$dia/$mesDaLinha/${linha.data.year};$nome;${linha.minutos}');
    }

    // Gravação em duas etapas: escreve num arquivo temporário e só então
    // renomeia. Se o app for encerrado no meio, o relatório anterior
    // continua íntegro em vez de virar um arquivo pela metade.
    final parcial = File('${destino.path}.parcial');
    await parcial.writeAsString(buffer.toString(), flush: true);
    return parcial.rename(destino.path);
  }

  /// Lê um relatório já exportado.
  ///
  /// Devolve `null` quando o arquivo não existe — ausência é um resultado
  /// normal, não um erro, e não deve virar exceção na interface.
  Future<String?> lerRelatorio(int ano, int mes) async {
    final arquivo = File(caminhoDoRelatorio(ano, mes));
    if (!await arquivo.exists()) return null;
    try {
      return await arquivo.readAsString();
    } on FileSystemException {
      // Sumiu entre o `exists` e o `readAsString`, ou o sistema negou o
      // acesso. Tratar como ausente é melhor do que derrubar a tela.
      return null;
    }
  }

  /// Lista os relatórios já exportados, do mais novo para o mais antigo.
  Future<List<String>> listarRelatorios() async {
    final pasta = Directory(p.join(pastaDeDocumentos.path, _subpastaRelatorios));
    if (!await pasta.exists()) return const <String>[];

    final nomes = <String>[];
    await for (final item in pasta.list()) {
      if (item is File && p.extension(item.path) == '.csv') {
        nomes.add(p.basename(item.path));
      }
    }
    nomes.sort((a, b) => b.compareTo(a));
    return nomes;
  }

  Future<void> apagarRelatorio(int ano, int mes) async {
    final arquivo = File(caminhoDoRelatorio(ano, mes));
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }

  // ------------------------------------------------------ rascunho
  // Vai na pasta TEMPORÁRIA: o app consegue viver sem ele, ele não deve
  // consumir o backup do usuário e o sistema pode apagá-lo sem aviso.

  File get _rascunho =>
      File(p.join(pastaTemporaria.path, _arquivoDeRascunho));

  Future<void> salvarRascunho(String texto) =>
      _rascunho.writeAsString(texto, flush: true);

  Future<String?> lerRascunho() async {
    final arquivo = _rascunho;
    if (!await arquivo.exists()) return null;
    try {
      return await arquivo.readAsString();
    } on FileSystemException {
      return null;
    }
  }

  Future<void> descartarRascunho() async {
    final arquivo = _rascunho;
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}
```

O teste, com pastas temporárias de verdade do seu Windows:

> **Arquivo:** `foco_dados/test/exportador_de_estudo_test.dart`
> **Como executar:** `flutter test test/exportador_de_estudo_test.dart`

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foco_dados/core/arquivos/exportador_de_estudo.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory raiz;
  late Directory documentos;
  late Directory temporaria;
  late ExportadorDeEstudo exportador;

  setUp(() {
    // Pasta real, isolada, criada pelo sistema operacional do teste.
    raiz = Directory.systemTemp.createTempSync('foco_dados_teste_');
    documentos = Directory(p.join(raiz.path, 'documentos'))..createSync();
    temporaria = Directory(p.join(raiz.path, 'tmp'))..createSync();
    exportador = ExportadorDeEstudo(
      pastaDeDocumentos: documentos,
      pastaTemporaria: temporaria,
    );
  });

  tearDown(() {
    if (raiz.existsSync()) {
      raiz.deleteSync(recursive: true);
    }
  });

  group('exportarCsv', () {
    test('cria a subpasta e escreve cabeçalho mais linhas', () async {
      final arquivo = await exportador.exportarCsv(
        ano: 2026,
        mes: 9,
        linhas: <LinhaDeRelatorio>[
          LinhaDeRelatorio(
            data: DateTime(2026, 9, 14),
            materia: 'Cálculo I',
            minutos: 45,
          ),
          LinhaDeRelatorio(
            data: DateTime(2026, 9, 15),
            materia: 'Álgebra Linear',
            minutos: 30,
          ),
        ],
      );

      expect(await arquivo.exists(), isTrue);
      expect(p.basename(arquivo.path), 'foco-2026-09.csv');

      final conteudo = await arquivo.readAsString();
      final linhas = const LineSplitter().convert(conteudo);
      expect(linhas.first, 'data;materia;minutos');
      expect(linhas[1], '14/09/2026;Cálculo I;45');
      expect(linhas[2], '15/09/2026;Álgebra Linear;30');
    });

    test('não deixa arquivo .parcial para trás', () async {
      await exportador.exportarCsv(ano: 2026, mes: 9, linhas: const []);
      final pasta = Directory(p.join(documentos.path, 'relatorios'));
      final nomes = pasta.listSync().map((e) => p.basename(e.path)).toList();
      expect(nomes, <String>['foco-2026-09.csv']);
    });

    test('exportar de novo substitui o anterior', () async {
      await exportador.exportarCsv(
        ano: 2026,
        mes: 9,
        linhas: <LinhaDeRelatorio>[
          LinhaDeRelatorio(
            data: DateTime(2026, 9, 1),
            materia: 'Física',
            minutos: 10,
          ),
        ],
      );
      await exportador.exportarCsv(ano: 2026, mes: 9, linhas: const []);

      final conteudo = await exportador.lerRelatorio(2026, 9);
      expect(conteudo, 'data;materia;minutos\n');
    });

    test('ponto e vírgula no nome da matéria não quebra a coluna', () async {
      await exportador.exportarCsv(
        ano: 2026,
        mes: 9,
        linhas: <LinhaDeRelatorio>[
          LinhaDeRelatorio(
            data: DateTime(2026, 9, 2),
            materia: 'Redação; Gramática',
            minutos: 20,
          ),
        ],
      );
      final conteudo = await exportador.lerRelatorio(2026, 9);
      expect(conteudo, contains('Redação, Gramática'));
    });
  });

  group('lerRelatorio', () {
    test('devolve null quando o arquivo não existe', () async {
      expect(await exportador.lerRelatorio(2020, 1), isNull);
    });
  });

  group('listarRelatorios', () {
    test('lista vazia quando a pasta nunca foi criada', () async {
      expect(await exportador.listarRelatorios(), isEmpty);
    });

    test('lista do mais novo para o mais antigo', () async {
      await exportador.exportarCsv(ano: 2026, mes: 7, linhas: const []);
      await exportador.exportarCsv(ano: 2026, mes: 9, linhas: const []);
      await exportador.exportarCsv(ano: 2026, mes: 8, linhas: const []);

      expect(await exportador.listarRelatorios(), <String>[
        'foco-2026-09.csv',
        'foco-2026-08.csv',
        'foco-2026-07.csv',
      ]);
    });
  });

  group('rascunho na pasta temporária', () {
    test('salva, lê e descarta', () async {
      expect(await exportador.lerRascunho(), isNull);

      await exportador.salvarRascunho('Revisar integrais por partes');
      expect(await exportador.lerRascunho(), 'Revisar integrais por partes');

      await exportador.descartarRascunho();
      expect(await exportador.lerRascunho(), isNull);
    });

    test('o rascunho NÃO fica na pasta de documentos', () async {
      await exportador.salvarRascunho('nada importante');
      expect(documentos.listSync(), isEmpty);
      expect(temporaria.listSync(), isNotEmpty);
    });

    test('sumir sozinho é resultado normal, não erro', () async {
      await exportador.salvarRascunho('vai sumir');
      // Simula a faxina do sistema apagando a pasta temporária inteira.
      temporaria.deleteSync(recursive: true);
      expect(await exportador.lerRascunho(), isNull);
    });
  });
}
```

O teste usa `LineSplitter`, que vem de `dart:convert`. Acrescente o import no topo do arquivo de
teste:

```dart
import 'dart:convert';
```

Saída esperada:

```text
00:03 +10: All tests passed!
```

---

## 🔍 Explicando o código

- **`await destino.parent.create(recursive: true)`** — `File.parent` devolve o `Directory` que
  contém o arquivo. `recursive: true` cria a árvore inteira de pastas que faltar e **não dá erro
  se a pasta já existir**, o que dispensa um `if (await pasta.exists())`.
- **Gravar em `.parcial` e depois `rename`** — `rename` dentro do mesmo sistema de arquivos é uma
  operação atômica: ou o arquivo novo aparece inteiro, ou nada muda. Sem isso, um encerramento do
  app no meio do `writeAsString` deixaria o relatório antigo destruído e o novo incompleto. Esse
  padrão se chama **escrita atômica** e vale para qualquer arquivo importante.
- **`flush: true`** pede ao sistema que empurre os bytes para o disco antes de o `Future`
  completar. Sem ele, o dado pode ficar num buffer do sistema operacional por alguns instantes.
- **`if (!await arquivo.exists()) return null;`** — "não existe" é um estado esperado, não um
  problema. Devolver `null` deixa a camada de cima decidir se mostra estado vazio, e é bem mais
  honesto que devolver string vazia.
- **`on FileSystemException`** depois do `exists` — sim, é redundante em teoria, e sim, é
  necessário na prática. Entre o `exists` e o `readAsString` existe uma janela em que o sistema
  pode ter apagado a pasta temporária. Código de disco precisa aceitar que o mundo muda entre duas
  linhas.
- **`await for (final item in pasta.list())`** — `Directory.list()` devolve uma `Stream`, não uma
  lista. Isso é de propósito: uma pasta com dez mil arquivos é entregue aos poucos, sem carregar
  tudo na memória. O `await for` consome a stream item a item.
- **`item is File`** — `list()` devolve `FileSystemEntity`, que pode ser `File`, `Directory` ou
  `Link`. Sem a checagem, você trataria uma subpasta como se fosse um relatório.
- **`p.extension(item.path) == '.csv'`** — repare no ponto. `p.extension` devolve a extensão
  **com** o ponto.
- **`padLeft(2, '0')`** transforma `9` em `'09'`. Sem isso, os nomes `foco-2026-9.csv` e
  `foco-2026-10.csv` sairiam fora de ordem na ordenação alfabética.
- **`replaceAll(';', ',')`** no nome da matéria — sem isso, uma matéria chamada
  `Redação; Gramática` criaria uma coluna extra no CSV e embaralharia a planilha inteira. Tratar
  o separador dentro do dado é obrigação de quem gera CSV.
- **`Directory.systemTemp.createTempSync('prefixo_')`** no teste cria uma pasta real e exclusiva
  daquele teste. O `tearDown` apaga tudo, então os testes não interferem uns nos outros.

---

## 🤖🍎 Android × iOS

A API Dart é a mesma; o caminho, a duração e o backup são diferentes. Isso muda decisões reais.

### Onde cada pasta fica

| Função | 🤖 Android | 🍎 iOS |
|---|---|---|
| `getApplicationDocumentsDirectory()` | `/data/user/0/<applicationId>/app_flutter` | `<sandbox>/Documents` |
| `getApplicationSupportDirectory()` | `/data/user/0/<applicationId>/files` | `<sandbox>/Library/Application Support` |
| `getTemporaryDirectory()` | `/data/user/0/<applicationId>/cache` | `<sandbox>/tmp` |

### 🍎 O detalhe do iOS que muda o seu projeto

No iOS, **tudo dentro de `Documents` e de `Library/Application Support` entra no backup do
iCloud**. `tmp` e `Library/Caches` **não** entram.

Consequências práticas, em ordem de importância:

1. **Cache grande em `Documents` consome o iCloud do usuário.** Se o seu app baixar 200 MB de
   imagens e guardar em documentos, o usuário vai ver o app ocupando 200 MB do plano de iCloud
   dele — e pode desinstalar por causa disso.
2. A Apple publica diretrizes de armazenamento e **a revisão da App Store observa esse ponto**.
   Cache em pasta de backup é um motivo conhecido de reprovação.
3. No iOS, `Documents` também pode ficar **visível para o usuário** no app Arquivos, se o
   `Info.plist` declarar `UIFileSharingEnabled` e `LSSupportsOpeningDocumentsInPlace`. O relatório
   CSV do Foco é exatamente o tipo de coisa que faz sentido aparecer ali; o rascunho, não.

### 🤖 O detalhe do Android

O **Auto Backup** copia por padrão os arquivos do app (incluindo `app_flutter` e `files`) para o
Google Drive do usuário, e **exclui** a pasta `cache`. O comportamento é controlado no
`AndroidManifest.xml` pelos atributos do `<application>`: `android:allowBackup`,
`android:dataExtractionRules` (Android 12+) e `android:fullBackupContent` (versões anteriores). O
módulo 15 trata do manifesto em
[15 — Permissões Android](../15-build-android/05-permissoes-android.md).

Android também tem armazenamento **externo** (a área acessível por outros apps e pelo gerenciador
de arquivos), com `getExternalStorageDirectory()`. Duas advertências:

- Essa função **devolve `null` no iOS**, porque o conceito não existe lá. Qualquer uso dela vira
  código com `if` de plataforma.
- Desde o Android 10, o acesso a arquivos fora do app é restrito pelo *Scoped Storage*. O caminho
  moderno para "mandar um arquivo para fora" não é escrever no armazenamento externo: é
  **compartilhar** o arquivo, assunto de
  [11 — Arquivos e compartilhamento](../11-recursos-nativos/03-arquivos-e-compartilhamento.md).

### Resumo da decisão

| O dado é… | Vai em | Por quê |
|---|---|---|
| relatório que o usuário exportou | documentos | ele perderia se sumisse; faz sentido no backup |
| índice interno, arquivo de apoio | suporte | permanente, mas não é "conteúdo do usuário" |
| miniatura, download em andamento, rascunho | temporária | recriável; não deve consumir o backup |

> 🍎 **SÓ NO MAC.** Inspecionar o sandbox de um iPhone (Xcode → Window → Devices and Simulators →
> selecionar o app → *Download Container*) exige macOS + Xcode. No Windows você pode ler e
> entender o processo, mas não executá-lo. Veja
> [16-build-ios/01-por-que-exige-macos.md](../16-build-ios/01-por-que-exige-macos.md).

---

## ⚠️ Erros comuns

1. **Concatenar caminho com `'/'`.**
   ```dart
   final caminho = pasta.path + '/relatorios/a.csv'; // quebra no 🪟 Windows
   ```
   Use `p.join`. Seus testes rodam no Windows; esse erro aparece imediatamente.

2. **Guardar o caminho absoluto num banco ou em preferências.**
   🍎 O identificador do sandbox do iOS muda entre instalações. Guarde apenas o **nome do
   arquivo** e reconstrua o caminho a cada execução.

3. **Escrever num arquivo dentro de uma subpasta que não existe.**
   ```text
   FileSystemException: Cannot open file, path = '.../relatorios/foco-2026-09.csv'
   (OS Error: O sistema não pode encontrar o caminho especificado, errno = 3)
   ```
   Falta `await destino.parent.create(recursive: true)`.

4. **Chamar `readAsString` sem checar `exists`.**
   O erro é `FileSystemException: Cannot open file` e ele sobe até a interface como tela vermelha.
   Ausência de arquivo é estado normal do app; trate com `null`.

5. **Usar as versões `Sync` em código de interface.**
   `readAsStringSync` bloqueia a thread. Num arquivo pequeno você não percebe; num relatório de
   5 MB o app trava visivelmente. Nos **testes**, o `Sync` é aceitável e até conveniente.

6. **Colocar cache em `getApplicationDocumentsDirectory()`.**
   🍎 Consome o iCloud do usuário e é motivo conhecido de reprovação na App Store. Cache vai em
   `getTemporaryDirectory()`.

7. **Assumir que o arquivo temporário continua lá.**
   Ele pode ter sido apagado pelo sistema entre a gravação e a leitura. Todo `lerRascunho`
   precisa poder devolver `null`.

8. **Chamar `getApplicationDocumentsDirectory()` dentro de um teste `flutter test`.**
   O erro é `MissingPluginException(No implementation found for method ...)`. Injete o `Directory`
   como esta aula fez, em vez de chamar o plugin no miolo do código.

---

## 🛠️ Exercício guiado

Vamos acrescentar ao exportador a capacidade de **anexar** uma linha ao relatório do mês corrente,
sem reescrever o arquivo inteiro.

**Passo 1.** Adicione o método ao `ExportadorDeEstudo`:

```dart
/// Acrescenta uma linha ao relatório do mês, criando o arquivo com
/// cabeçalho se ele ainda não existir.
Future<File> anexarLinha({
  required int ano,
  required int mes,
  required LinhaDeRelatorio linha,
}) async {
  final destino = File(caminhoDoRelatorio(ano, mes));
  await destino.parent.create(recursive: true);

  if (!await destino.exists()) {
    await destino.writeAsString('data;materia;minutos\n', flush: true);
  }

  final dia = linha.data.day.toString().padLeft(2, '0');
  final mesDaLinha = linha.data.month.toString().padLeft(2, '0');
  final nome = linha.materia.replaceAll(';', ',');
  await destino.writeAsString(
    '$dia/$mesDaLinha/${linha.data.year};$nome;${linha.minutos}\n',
    mode: FileMode.append,
    flush: true,
  );
  return destino;
}
```

**Passo 2.** Escreva o teste:

```dart
test('anexarLinha cria com cabeçalho e depois só acrescenta', () async {
  await exportador.anexarLinha(
    ano: 2026,
    mes: 9,
    linha: LinhaDeRelatorio(
      data: DateTime(2026, 9, 10),
      materia: 'Cálculo I',
      minutos: 25,
    ),
  );
  await exportador.anexarLinha(
    ano: 2026,
    mes: 9,
    linha: LinhaDeRelatorio(
      data: DateTime(2026, 9, 11),
      materia: 'Física',
      minutos: 40,
    ),
  );

  final conteudo = await exportador.lerRelatorio(2026, 9);
  final linhas = const LineSplitter().convert(conteudo!);
  expect(linhas.length, 3);
  expect(linhas.first, 'data;materia;minutos');
  expect(linhas.last, '11/09/2026;Física;40');
});
```

**Passo 3.** Rode:

```powershell
flutter test test/exportador_de_estudo_test.dart
```

**Passo 4 — a reflexão.** `anexarLinha` é rápido porque não reescreve o arquivo. Agora responda
sem código: como você faria para **corrigir** a duração de uma sessão já gravada nesse CSV? E para
mostrar "só as sessões de Cálculo"?

A resposta é a mesma do passo 4 da aula anterior: você teria que ler o arquivo inteiro,
reprocessar e reescrever. Arquivo é ótimo para **acrescentar e exportar**, e ruim para
**consultar e alterar**. É por isso que a próxima aula abre um banco.

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

Implemente uma **limpeza de cache** no `ExportadorDeEstudo`:

```dart
Future<int> limparTemporariosAntigos({required Duration idadeMaxima});
```

Ela deve percorrer a pasta temporária, olhar a data de modificação de cada arquivo (`await
arquivo.lastModified()`), apagar os mais velhos que `idadeMaxima` e devolver quantos foram
apagados.

Dois cuidados que o desafio deve te ensinar:

1. `pasta.list()` devolve `FileSystemEntity`; trate `Directory` separadamente de `File` ou você
   vai tentar chamar `lastModified()` numa pasta.
2. No teste, não durma esperando o tempo passar. Use `await arquivo.setLastModified(DateTime.now()
   .subtract(const Duration(days: 10)))` para fabricar um arquivo "velho" instantaneamente.

---

## 📌 Resumo

- Arquivo é a opção certa para conteúdo grande, binário ou pensado para sair do app.
- O `path_provider` descobre **três** pastas: documentos (conteúdo do usuário, entra no backup),
  suporte (dados internos, entra no backup) e temporária (descartável, fora do backup).
- Monte caminhos com `p.join` de `package:path`, nunca com `+ '/'`.
- `writeAsString` sobrescreve; `mode: FileMode.append` acrescenta; `flush: true` garante a
  gravação; escrever em `.parcial` e depois `rename` protege o arquivo anterior.
- `readAsString` falha se o arquivo não existir: cheque `exists()` e devolva `null`, porque
  ausência é estado normal.
- `Directory.list()` é uma `Stream` e devolve `FileSystemEntity`; filtre por `is File`.
- 🍎 No iOS, `Documents` e `Library/Application Support` entram no backup do iCloud; `tmp` não.
  Cache em documentos consome o iCloud do usuário e é motivo conhecido de reprovação na App Store.
- 🤖 No Android, o Auto Backup copia os arquivos do app e exclui a pasta `cache`.
- Isole `path_provider` numa classe de fronteira (`PastasDoApp`) e **injete** os `Directory`: é o
  que permite testar essa camada inteira no Windows.

---

## ☑️ Checklist de domínio

- [ ] Escolho entre documentos, suporte e temporária sem consultar a tabela.
- [ ] Explico as duas frases-guia: "se o usuário ficaria bravo ao perder" e "se o app recria
      sozinho".
- [ ] Monto caminho com `p.join` e sei dizer por que a concatenação quebra no 🪟 Windows.
- [ ] Crio subpastas com `create(recursive: true)` antes de gravar.
- [ ] Escrevo com `writeAsString` e conheço `FileMode.append` e `flush: true`.
- [ ] Sei descrever a escrita atômica com arquivo `.parcial` + `rename` e por que ela protege.
- [ ] Trato arquivo inexistente devolvendo `null`, sem deixar `FileSystemException` subir.
- [ ] Percorro uma pasta com `await for` e filtro com `is File`.
- [ ] Explico por que 🍎 cache não pode ficar em `Documents`.
- [ ] Injeto `Directory` em vez de chamar `path_provider` no miolo, e meus testes passam no
      Windows com `Directory.systemTemp`.

---

## 📚 Referências oficiais

- [path_provider — pub.dev](https://pub.dev/packages/path_provider)
- [path — pub.dev](https://pub.dev/packages/path)
- [Read and write files — docs.flutter.dev](https://docs.flutter.dev/cookbook/persistence/reading-writing-files)
- [dart:io File class — api.dart.dev](https://api.dart.dev/stable/dart-io/File-class.html)
- [dart:io Directory class — api.dart.dev](https://api.dart.dev/stable/dart-io/Directory-class.html)
- [Data and file storage overview — developer.android.com](https://developer.android.com/training/data-storage)
- [File System Programming Guide — developer.apple.com](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — shared_preferences](02-shared-preferences.md) | [README](README.md) | [Aula 4 — sqflite: criando o banco](04-sqflite-criando-o-banco.md) |
