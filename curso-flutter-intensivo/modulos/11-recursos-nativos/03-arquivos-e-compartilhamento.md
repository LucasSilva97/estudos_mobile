# Aula 3 — Arquivos e compartilhamento

> **Módulo:** 11 - Recursos Nativos · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Diferenciar os **arquivos do app** (que você controla) dos **arquivos do usuário** (que exigem
  um seletor do sistema).
- Exportar dados do app em **JSON**, com versão e validação na volta.
- Usar **`file_picker`** para o usuário escolher um arquivo, e **`share_plus`** para abrir o menu
  nativo de compartilhar.
- Explicar o **escopo de armazenamento** (*scoped storage*) do Android e por que
  `WRITE_EXTERNAL_STORAGE` deixou de funcionar.
- Entender a **sandbox** do iOS e por onde os arquivos entram e saem dela.
- Decidir **quando um pacote vale a pena** e quando `dart:io` basta.
- Tratar os erros reais: arquivo inexistente, JSON inválido, versão incompatível, cancelamento.

## ✅ Pré-requisitos

- [Aula 1 — Permissões](01-permissoes.md) — e a boa notícia desta aula: quase nada aqui precisa de
  permissão.
- [Módulo 10, aula 3 — Arquivos e path_provider](../10-persistencia-de-dados/03-arquivos-e-path-provider.md)
  — **essencial**: `getApplicationDocumentsDirectory`, `package:path`, `writeAsString`.
- [Módulo 09, aula 2 — JSON](../09-consumo-de-api/02-json.md) — `jsonEncode`, `jsonDecode`,
  validação.
- [Módulo 10, aula 6 — Migrações](../10-persistencia-de-dados/06-migracoes.md) — a ideia de versão
  de formato volta aqui.

---

## 📖 Conceito

### Dois mundos de arquivos

Esta é a distinção que organiza a aula inteira:

| | **Arquivos do app** | **Arquivos do usuário** |
|---|---|---|
| Onde ficam | Pasta privada do app | Downloads, Documentos, Google Drive, iCloud |
| Quem acessa | Só o seu app | O usuário e outros apps |
| Precisa de permissão | ❌ **Nunca** | ⚠️ Via seletor do sistema (sem permissão) |
| Some ao desinstalar | ✅ | ❌ |
| Como chegar lá | `path_provider` + `dart:io` | `file_picker` / `share_plus` |
| Exemplo | Banco, cache, rascunho | Backup que o usuário guarda, PDF que ele envia |

> 📌 **A confusão mais comum:** achar que salvar um backup "na pasta Downloads" é um problema de
> permissão. Não é — é um problema de **modelo de acesso**. As duas plataformas modernas resolvem
> isso com um **seletor do sistema**: o usuário escolhe onde salvar, e o app recebe acesso **àquele
> arquivo específico**, sem permissão nenhuma.

### O escopo de armazenamento do Android

Até o Android 9, um app com `WRITE_EXTERNAL_STORAGE` podia ler e escrever em **qualquer lugar** do
armazenamento. Isso produzia celulares cheios de pastas abandonadas de apps desinstalados — e
qualquer app podia ler as fotos, os documentos e os backups de outro.

A partir do Android 10, e obrigatoriamente do 11, existe o **escopo de armazenamento**:

| Versão | O que mudou |
|---|---|
| Android 10 (API 29) | Escopo opcional (`requestLegacyExternalStorage`) |
| Android 11 (API 30) | **Obrigatório.** `WRITE_EXTERNAL_STORAGE` deixa de ter efeito |
| Android 13 (API 33) | Permissões de mídia separadas: `READ_MEDIA_IMAGES`, `_VIDEO`, `_AUDIO` |

O que o app pode fazer hoje, **sem nenhuma permissão**:

- ler e escrever na **própria pasta** (`getApplicationDocumentsDirectory`);
- usar o **seletor do sistema** para o usuário escolher um arquivo;
- usar o **seletor de salvamento** para o usuário escolher onde gravar;
- **compartilhar** um arquivo pelo menu nativo.

> ⚠️ **`MANAGE_EXTERNAL_STORAGE` é uma armadilha.** Ela dá acesso amplo — e o Google **exige
> justificativa** na publicação. Um app de estudos não passa nessa revisão. Se você acha que
> precisa dela, quase certamente precisa do seletor de arquivos.

### A sandbox do iOS

O iOS sempre funcionou assim: cada app vive numa **caixa isolada** e não enxerga os arquivos dos
outros. As pastas dentro dela:

| Pasta | `path_provider` | Some ao desinstalar | Vai para backup |
|---|---|---|---|
| `Documents/` | `getApplicationDocumentsDirectory()` | ✅ | ✅ |
| `Library/Application Support/` | `getApplicationSupportDirectory()` | ✅ | ✅ |
| `Library/Caches/` | `getTemporaryDirectory()` | ✅ | ❌ (o sistema pode apagar) |
| `tmp/` | — | ✅ | ❌ |

Para entrar e sair da caixa, existem duas portas:

- **`UIDocumentPickerViewController`** — o usuário escolhe um arquivo de fora (é o que o
  `file_picker` usa);
- **`UIActivityViewController`** — o menu de compartilhar (é o que o `share_plus` usa).

> 📌 **Uma diferença que aparece no dia a dia:** no iOS, arquivos em `Documents/` podem aparecer no
> app **Arquivos** do sistema, se você declarar `UIFileSharingEnabled` e
> `LSSupportsOpeningDocumentsInPlace` no `Info.plist`. Isso é ótimo para um app que produz
> documentos — e indesejado para um que guarda banco de dados ali.

### Exportar: o formato importa

Um backup é um **contrato com o futuro**. Daqui a um ano, uma versão diferente do app vai tentar
ler o arquivo que você está gerando hoje.

```json
{
  "formato": "foco-backup",
  "versao": 1,
  "exportado_em": "2026-03-10T14:30:00.000Z",
  "app": { "versao": "1.4.2" },
  "dados": {
    "materias": [ ... ],
    "sessoes": [ ... ]
  }
}
```

Quatro campos que parecem burocracia e salvam o backup:

| Campo | Para quê |
|---|---|
| `formato` | Distinguir um backup do Foco de qualquer outro JSON que o usuário escolher |
| `versao` | Saber se a versão atual do app consegue ler |
| `exportado_em` | Mostrar ao usuário de quando é o backup |
| `app.versao` | Diagnóstico quando algo dá errado |

E a regra que evita perda de dados:

> **Na importação, valide antes de aplicar.** Leia o arquivo inteiro, valide a estrutura, e só
> então grave. Importar linha a linha enquanto valida deixa o banco pela metade quando o arquivo
> está corrompido.

### `file_picker`: o usuário escolhe

```dart
final FilePickerResult? resultado = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: <String>['json'],
  // withData: lê o conteúdo para a memória. Bom para arquivos pequenos;
  // ruim para um vídeo de 2 GB.
  withData: true,
);

// null = o usuário cancelou. Não é erro.
if (resultado == null) return;

final PlatformFile arquivo = resultado.files.single;
```

Pontos que sempre pegam:

**1. `null` significa cancelamento, não erro.** O usuário abrir o seletor e desistir é o caminho
mais comum depois do sucesso.

**2. `withData: true` × `path`.**

```dart
// Arquivo pequeno: leia para a memória.
final Uint8List? bytes = arquivo.bytes;

// Arquivo grande: use o caminho e leia em fluxo.
final String? caminho = arquivo.path;
```

Na **web**, `path` é sempre `null` — só existe `bytes`. Se o app roda na web, `withData: true` é
obrigatório.

**3. `allowedExtensions` não é garantia.** O usuário pode renomear um `.mp4` para `.json`. Valide
o **conteúdo**, sempre.

### `share_plus`: o menu nativo

```dart
await SharePlus.instance.share(
  ShareParams(
    files: <XFile>[XFile(caminho)],
    text: 'Backup do Foco',
    subject: 'Meu progresso de estudos',
    // Obrigatório no iPad: sem isso, o app trava.
    sharePositionOrigin: _posicaoDoBotao(context),
  ),
);
```

O que o menu oferece depende do que o usuário tem instalado: salvar em Arquivos/Drive, enviar por
e-mail, WhatsApp, AirDrop.

> ⚠️ **`sharePositionOrigin` é obrigatório no iPad.** O iOS mostra o menu de compartilhar como um
> *popover* ancorado em algo, e sem a posição de origem ele **lança exceção**. No iPhone o
> parâmetro é ignorado — mas escreva sempre, ou o app quebra só nos tablets, onde você não testou.

### Quando um pacote vale a pena

Esta aula usa dois pacotes. Vale entender por quê — e quando **não** usar:

| Tarefa | Precisa de pacote? |
|---|---|
| Ler/escrever na pasta do app | ❌ `dart:io` + `path_provider` |
| Criar JSON | ❌ `dart:convert` |
| Listar arquivos da pasta do app | ❌ `Directory.list()` |
| **Usuário escolher um arquivo** | ✅ `file_picker` — exige UI nativa |
| **Abrir o menu de compartilhar** | ✅ `share_plus` — exige API nativa |
| Abrir um PDF | ✅ depende do visualizador do sistema |

A regra: **precisa de tela ou API do sistema operacional? Pacote. É só arquivo? `dart:io`.**

> 📌 Escrever essas duas telas nativas à mão significaria código Kotlin **e** Swift, mais um canal
> de plataforma, mais manutenção a cada versão do SO. Aqui o pacote paga por si. A
> [aula 10](10-avaliando-pacotes.md) dá o checklist completo de avaliação.

---

## 💡 Analogia

Pense num apartamento em um condomínio.

- **Os arquivos do app** são os móveis **dentro** do seu apartamento. Você entra, sai, muda de
  lugar, joga fora — sem pedir nada a ninguém. É por isso que ler e escrever na pasta do app **não
  precisa de permissão**.
- **Os arquivos do usuário** ficam no **depósito coletivo** do prédio. Antigamente (Android 9) cada
  morador tinha a chave do depósito inteiro e mexia nas caixas dos outros. Deu no que deu: caixas
  abandonadas de quem se mudou, e gente fuçando na mudança alheia.
- **O escopo de armazenamento** é a regra nova: ninguém tem a chave do depósito. Quando você precisa
  de uma caixa de lá, **o zelador vai com você**, você aponta qual caixa quer, e ele te entrega
  **aquela** caixa. É o seletor do sistema — e é por isso que ele não precisa de permissão: o
  usuário autorizou ao apontar.
- **`MANAGE_EXTERNAL_STORAGE`** é pedir a chave-mestra do prédio. O síndico (o Google) pergunta:
  "por que exatamente você precisa disso?" — e "é mais prático" não é resposta aceita.
- **A sandbox do iOS** é o mesmo modelo, desde sempre. O iPhone nunca teve o depósito coletivo.
- **O menu de compartilhar** é o porteiro: você entrega o envelope e diz "mande isso". Para onde
  vai — correio, motoboy, vizinho — é o usuário que escolhe na hora.
- **A versão no arquivo de backup** é o rótulo na caixa dizendo o que tem dentro e de quando é.
  Uma caixa sem rótulo, achada três anos depois, é uma caixa que ninguém abre com confiança.

---

## 🧪 Exemplo mínimo

Exportar, compartilhar e importar, com todos os erros tratados.

> **Arquivo:** `foco_nativo/lib/main.dart` (temporário)
> **Instale antes:** `flutter pub add file_picker share_plus path_provider path`
> **Como executar:** `flutter run -d windows`

```dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const AppArquivos());

class AppArquivos extends StatelessWidget {
  const AppArquivos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaArquivos(),
    );
  }
}

class TelaArquivos extends StatefulWidget {
  const TelaArquivos({super.key});

  @override
  State<TelaArquivos> createState() => _TelaArquivosState();
}

class _TelaArquivosState extends State<TelaArquivos> {
  final List<String> _log = <String>[];

  /// Dados de exemplo. No app real vêm do banco (Módulo 10).
  final List<Map<String, Object?>> _materias = <Map<String, Object?>>[
    <String, Object?>{'id': 'dart', 'nome': 'Dart', 'minutos': 120},
    <String, Object?>{'id': 'flutter', 'nome': 'Flutter', 'minutos': 90},
  ];

  void _registrar(String linha) {
    debugPrint(linha);
    setState(() => _log.insert(0, linha));
  }

  // ── Exportar ─────────────────────────────────────────────────────────────

  /// Gera o backup na pasta do app.
  ///
  /// Nenhuma permissão é necessária: esta é a pasta PRIVADA do app.
  Future<File> _gerarBackup() async {
    final Map<String, Object?> conteudo = <String, Object?>{
      // Distingue um backup do Foco de qualquer outro JSON que o
      // usuário venha a escolher na importação.
      'formato': 'foco-backup',
      // Permite à versão futura do app saber se consegue ler.
      'versao': 1,
      'exportado_em': DateTime.now().toUtc().toIso8601String(),
      'app': <String, Object?>{'versao': '1.0.0'},
      'dados': <String, Object?>{'materias': _materias},
    };

    final Directory pasta = await getApplicationDocumentsDirectory();

    // Data no nome: o usuário acumula backups e precisa distingui-los.
    final String carimbo = DateTime.now()
        .toIso8601String()
        .substring(0, 19)
        .replaceAll(':', '-');
    final File arquivo = File(p.join(pasta.path, 'foco-backup-$carimbo.json'));

    // Indentado: um backup que o usuário pode abrir e entender vale mais
    // que alguns bytes economizados.
    await arquivo.writeAsString(
      const JsonEncoder.withIndent('  ').convert(conteudo),
    );

    return arquivo;
  }

  Future<void> _exportar() async {
    try {
      final File arquivo = await _gerarBackup();
      final int bytes = await arquivo.length();
      _registrar('✅ gerado: ${p.basename(arquivo.path)} ($bytes bytes)');
      _registrar('   em: ${arquivo.parent.path}');
    } on FileSystemException catch (e) {
      // Disco cheio, permissão do sistema de arquivos, caminho inválido.
      _registrar('❌ não foi possível gravar: ${e.message}');
    }
  }

  // ── Compartilhar ─────────────────────────────────────────────────────────

  Future<void> _compartilhar() async {
    try {
      final File arquivo = await _gerarBackup();

      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(arquivo.path)],
          text: 'Backup do Foco',
          subject: 'Meu progresso de estudos',
          // OBRIGATÓRIO no iPad: o menu é um popover ancorado, e sem
          // a posição de origem o app LANÇA EXCEÇÃO. No iPhone é
          // ignorado — mas escreva sempre, ou quebra só no tablet.
          sharePositionOrigin: _posicaoDoBotao(),
        ),
      );

      _registrar('📤 menu de compartilhar aberto');
    } on Object catch (e) {
      _registrar('❌ falha ao compartilhar: $e');
    }
  }

  Rect _posicaoDoBotao() {
    final RenderBox? caixa = context.findRenderObject() as RenderBox?;
    if (caixa == null) return Rect.zero;
    return caixa.localToGlobal(Offset.zero) & caixa.size;
  }

  // ── Importar ─────────────────────────────────────────────────────────────

  Future<void> _importar() async {
    final FilePickerResult? resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['json'],
      // Backup é pequeno: ler para a memória é seguro.
      // Para um vídeo de 2 GB, use `path` e leia em fluxo.
      withData: true,
    );

    // null = o usuário CANCELOU. Não é erro — é o segundo caminho
    // mais comum depois do sucesso.
    if (resultado == null) {
      _registrar('↩️ cancelado pelo usuário');
      return;
    }

    final PlatformFile arquivo = resultado.files.single;
    _registrar('📥 escolhido: ${arquivo.name} (${arquivo.size} bytes)');

    // Na WEB, `path` é sempre null: só existe `bytes`.
    final List<int>? bytes = arquivo.bytes;
    if (bytes == null) {
      _registrar('❌ não foi possível ler o conteúdo');
      return;
    }

    try {
      // VALIDA TUDO antes de aplicar qualquer coisa. Importar enquanto
      // valida deixaria o banco pela metade com arquivo corrompido.
      final Map<String, Object?> dados = _validar(utf8.decode(bytes));

      final List<Object?> materias =
          (dados['dados']! as Map<String, Object?>)['materias']! as List<Object?>;

      _registrar('✅ válido · ${materias.length} matérias');
      _registrar('   exportado em ${dados['exportado_em']}');
    } on FormatoInvalido catch (e) {
      // Mensagem que diz O QUE está errado, não "erro ao importar".
      _registrar('❌ ${e.mensagem}');
    } on FormatException {
      _registrar('❌ Este arquivo não é um JSON válido');
    }
  }

  /// Valida a estrutura inteira antes de qualquer gravação.
  Map<String, Object?> _validar(String texto) {
    final Object? bruto = jsonDecode(texto);

    if (bruto is! Map<String, Object?>) {
      throw const FormatoInvalido('O arquivo não tem o formato esperado');
    }

    // O usuário pode escolher QUALQUER json. Sem esta checagem, o app
    // tentaria importar a configuração de outro programa.
    if (bruto['formato'] != 'foco-backup') {
      throw const FormatoInvalido('Este arquivo não é um backup do Foco');
    }

    final Object? versao = bruto['versao'];
    if (versao is! int) {
      throw const FormatoInvalido('O backup não informa a versão do formato');
    }
    if (versao > 1) {
      // Backup de uma versão MAIS NOVA do app. Importar às cegas
      // poderia perder campos que esta versão não conhece.
      throw const FormatoInvalido(
        'Este backup foi feito por uma versão mais recente do app. '
        'Atualize o Foco para importá-lo.',
      );
    }

    final Object? dados = bruto['dados'];
    if (dados is! Map<String, Object?> || dados['materias'] is! List<Object?>) {
      throw const FormatoInvalido('O backup está incompleto ou corrompido');
    }

    return bruto;
  }

  // ── Listar ───────────────────────────────────────────────────────────────

  Future<void> _listarBackups() async {
    final Directory pasta = await getApplicationDocumentsDirectory();

    final List<FileSystemEntity> arquivos = pasta
        .listSync()
        .where((FileSystemEntity e) =>
            e is File && p.basename(e.path).startsWith('foco-backup-'))
        .toList()
      ..sort((FileSystemEntity a, FileSystemEntity b) =>
          b.path.compareTo(a.path));

    if (arquivos.isEmpty) {
      _registrar('📂 nenhum backup na pasta do app');
      return;
    }

    _registrar('📂 ${arquivos.length} backup(s):');
    for (final FileSystemEntity e in arquivos.take(5)) {
      _registrar('   ${p.basename(e.path)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arquivos e compartilhamento')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _exportar,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Exportar'),
                ),
                FilledButton.tonal(
                  onPressed: _compartilhar,
                  child: const Text('Compartilhar'),
                ),
                OutlinedButton(
                  onPressed: _importar,
                  child: const Text('Importar'),
                ),
                TextButton(
                  onPressed: _listarBackups,
                  child: const Text('Listar'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (BuildContext c, int i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Text(
                  _log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Erro de formato, com mensagem pronta para o usuário.
class FormatoInvalido implements Exception {
  const FormatoInvalido(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}
```

**Teste os quatro caminhos:**

1. **Exportar** → o arquivo aparece na pasta do app, sem permissão nenhuma.
2. **Listar** → confirme que está lá.
3. **Importar** e **cancelar** → `↩️ cancelado`, sem erro.
4. **Importar** um JSON qualquer (o `pubspec.lock`, renomeado para `.json`) →
   `❌ Este arquivo não é um backup do Foco`.

O quarto é o que separa um importador robusto de um que corrompe o banco do usuário.

---

## 📱 Aplicando no Flutter

O `foco_nativo` ganha backup completo:

- `ExportadorDeEstudo` — gera o JSON com versão;
- `ImportadorDeEstudo` — valida antes de aplicar, com resumo de conferência;
- `CompartilhadorDeArquivo` — menu nativo, com o cuidado do iPad;
- tela de backup com exportar, compartilhar, importar e limpar antigos.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/lib/core/arquivos/formato_de_backup.dart` (novo)
> **Como executar:** `flutter test`

```dart
import 'dart:convert';

/// O formato do arquivo de backup.
///
/// Um backup é um CONTRATO COM O FUTURO: daqui a um ano, uma versão
/// diferente do app vai tentar ler o arquivo gerado hoje. Os quatro
/// campos de cabeçalho parecem burocracia e são o que torna isso possível.
abstract final class FormatoDeBackup {
  /// Identifica o arquivo. Sem isto, o app tentaria importar qualquer
  /// JSON que o usuário escolhesse por engano.
  static const String identificador = 'foco-backup';

  /// Versão do FORMATO, não do app.
  ///
  /// Histórico:
  ///   1 → materias + sessoes
  ///   2 → acrescenta trilhas (futuro)
  static const int versaoAtual = 1;

  /// A versão mais antiga que ainda conseguimos ler.
  static const int versaoMinimaSuportada = 1;

  static String nomeDeArquivo([DateTime? quando]) {
    final DateTime agora = quando ?? DateTime.now();
    // Data no nome: o usuário acumula backups e precisa distingui-los
    // na tela de Arquivos, onde não há metadados visíveis.
    final String carimbo = agora
        .toIso8601String()
        .substring(0, 19)
        .replaceAll(':', '-');
    return 'foco-backup-$carimbo.json';
  }
}

/// Erro de importação, com mensagem pronta para o usuário.
///
/// `orientacao` diz O QUE FAZER — sem isso, o usuário só sabe que
/// falhou, não como resolver.
class BackupInvalido implements Exception {
  const BackupInvalido(this.mensagem, {this.orientacao});

  final String mensagem;
  final String? orientacao;

  @override
  String toString() => mensagem;
}

/// O conteúdo de um backup, já validado.
class Backup {
  const Backup({
    required this.versao,
    required this.exportadoEm,
    required this.versaoDoApp,
    required this.materias,
    required this.sessoes,
  });

  /// Lê e valida um backup.
  ///
  /// VALIDA TUDO antes de devolver. Quem chama recebe um objeto
  /// completo ou uma exceção — nunca um estado pela metade.
  factory Backup.deTexto(String texto) {
    final Object? bruto;
    try {
      bruto = jsonDecode(texto);
    } on FormatException {
      throw const BackupInvalido(
        'Este arquivo não é um JSON válido',
        orientacao: 'Escolha um arquivo .json gerado pelo próprio Foco.',
      );
    }

    if (bruto is! Map<String, Object?>) {
      throw const BackupInvalido('O arquivo não tem o formato esperado');
    }

    // 1. É nosso?
    if (bruto['formato'] != FormatoDeBackup.identificador) {
      throw const BackupInvalido(
        'Este arquivo não é um backup do Foco',
        orientacao: 'Escolha um arquivo gerado pelo botão "Exportar".',
      );
    }

    // 2. Conseguimos ler esta versão?
    final Object? versao = bruto['versao'];
    if (versao is! int) {
      throw const BackupInvalido('O backup não informa a versão do formato');
    }
    if (versao > FormatoDeBackup.versaoAtual) {
      // Backup de uma versão mais NOVA. Importar às cegas perderia
      // campos que esta versão não conhece — silenciosamente.
      throw const BackupInvalido(
        'Este backup foi feito por uma versão mais recente do Foco',
        orientacao: 'Atualize o app e tente de novo.',
      );
    }
    if (versao < FormatoDeBackup.versaoMinimaSuportada) {
      throw const BackupInvalido(
        'Este backup é de uma versão antiga demais',
        orientacao: 'Ele não pode mais ser importado.',
      );
    }

    // 3. A estrutura está completa?
    final Object? dados = bruto['dados'];
    if (dados is! Map<String, Object?>) {
      throw const BackupInvalido('O backup está corrompido');
    }

    final Object? materias = dados['materias'];
    final Object? sessoes = dados['sessoes'];
    if (materias is! List<Object?> || sessoes is! List<Object?>) {
      throw const BackupInvalido('O backup está incompleto');
    }

    // 4. Cada item é um mapa? Um único item inválido no meio de 500
    //    quebraria a importação lá adiante, com o banco pela metade.
    for (final Object? m in materias) {
      if (m is! Map<String, Object?> || m['id'] is! String) {
        throw const BackupInvalido('Há matérias inválidas no backup');
      }
    }
    for (final Object? s in sessoes) {
      if (s is! Map<String, Object?> || s['materia_id'] is! String) {
        throw const BackupInvalido('Há sessões inválidas no backup');
      }
    }

    // 5. Integridade referencial: sessão apontando para matéria que
    //    não existe no arquivo deixaria o banco inconsistente.
    final Set<String> ids = materias
        .cast<Map<String, Object?>>()
        .map((Map<String, Object?> m) => m['id']! as String)
        .toSet();

    for (final Map<String, Object?> s in sessoes.cast<Map<String, Object?>>()) {
      if (!ids.contains(s['materia_id'])) {
        throw const BackupInvalido(
          'O backup tem sessões sem a matéria correspondente',
          orientacao: 'O arquivo pode ter sido editado à mão.',
        );
      }
    }

    return Backup(
      versao: versao,
      exportadoEm: DateTime.tryParse(bruto['exportado_em'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      versaoDoApp:
          (bruto['app'] as Map<String, Object?>?)?['versao'] as String? ?? '?',
      materias: materias.cast<Map<String, Object?>>(),
      sessoes: sessoes.cast<Map<String, Object?>>(),
    );
  }

  final int versao;
  final DateTime exportadoEm;
  final String versaoDoApp;
  final List<Map<String, Object?>> materias;
  final List<Map<String, Object?>> sessoes;

  /// Resumo para o usuário CONFERIR antes de importar.
  ///
  /// Importar sem mostrar o que vai entrar é pedir para o usuário
  /// confiar às cegas em um arquivo que ele talvez nem lembre de onde veio.
  String get resumo {
    final int minutos = sessoes.fold(
      0,
      (int soma, Map<String, Object?> s) => soma + ((s['minutos'] as int?) ?? 0),
    );
    return '${materias.length} matérias · ${sessoes.length} sessões · '
        '$minutos minutos de estudo';
  }

  String get quandoLegivel {
    final Duration idade = DateTime.now().difference(exportadoEm);
    if (idade.inDays == 0) return 'hoje';
    if (idade.inDays == 1) return 'ontem';
    if (idade.inDays < 30) return 'há ${idade.inDays} dias';
    return 'em ${exportadoEm.day}/${exportadoEm.month}/${exportadoEm.year}';
  }

  static String gerarTexto({
    required List<Map<String, Object?>> materias,
    required List<Map<String, Object?>> sessoes,
    required String versaoDoApp,
    DateTime? quando,
  }) {
    final Map<String, Object?> conteudo = <String, Object?>{
      'formato': FormatoDeBackup.identificador,
      'versao': FormatoDeBackup.versaoAtual,
      'exportado_em': (quando ?? DateTime.now()).toUtc().toIso8601String(),
      'app': <String, Object?>{'versao': versaoDoApp},
      'dados': <String, Object?>{
        'materias': materias,
        'sessoes': sessoes,
      },
    };

    // Indentado: um backup que o usuário consegue abrir e entender vale
    // mais que os bytes economizados. E facilita muito o suporte.
    return const JsonEncoder.withIndent('  ').convert(conteudo);
  }
}
```

> **Arquivo:** `foco_nativo/lib/core/arquivos/servico_de_backup.dart` (novo)

```dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:foco_nativo/core/arquivos/formato_de_backup.dart';

/// Backup: gerar, compartilhar, importar.
///
/// Note o que NÃO existe aqui: nenhuma permissão. Escrever na pasta do
/// app é livre, e o seletor do sistema dispensa permissão porque o
/// próprio usuário aponta o arquivo.
class ServicoDeBackup {
  const ServicoDeBackup({
    required Future<List<Map<String, Object?>>> Function() lerMaterias,
    required Future<List<Map<String, Object?>>> Function() lerSessoes,
    required Future<void> Function(Backup) gravar,
    required String versaoDoApp,
  })  : _lerMaterias = lerMaterias,
        _lerSessoes = lerSessoes,
        _gravar = gravar,
        _versaoDoApp = versaoDoApp;

  final Future<List<Map<String, Object?>>> Function() _lerMaterias;
  final Future<List<Map<String, Object?>>> Function() _lerSessoes;
  final Future<void> Function(Backup) _gravar;
  final String _versaoDoApp;

  // ── Exportar ─────────────────────────────────────────────────────────────

  /// Gera o arquivo na pasta PRIVADA do app.
  ///
  /// Nenhuma permissão. Nenhum seletor. Depois disso, o usuário decide
  /// o que fazer com o arquivo pelo menu de compartilhar.
  Future<File> gerar() async {
    final String texto = Backup.gerarTexto(
      materias: await _lerMaterias(),
      sessoes: await _lerSessoes(),
      versaoDoApp: _versaoDoApp,
    );

    final Directory pasta = await _pastaDeBackups();
    final File arquivo =
        File(p.join(pasta.path, FormatoDeBackup.nomeDeArquivo()));

    await arquivo.writeAsString(texto, flush: true);
    return arquivo;
  }

  /// Subpasta dedicada.
  ///
  /// Sem ela, os backups se misturam com o banco e os arquivos internos —
  /// e listar fica cheio de filtros.
  Future<Directory> _pastaDeBackups() async {
    final Directory documentos = await getApplicationDocumentsDirectory();
    final Directory pasta = Directory(p.join(documentos.path, 'backups'));
    // create com recursive não falha se a pasta já existir.
    if (!pasta.existsSync()) await pasta.create(recursive: true);
    return pasta;
  }

  // ── Compartilhar ─────────────────────────────────────────────────────────

  /// Abre o menu nativo de compartilhar.
  ///
  /// O que aparece depende do que o usuário tem instalado: salvar em
  /// Arquivos/Drive, e-mail, WhatsApp, AirDrop.
  Future<void> compartilhar(File arquivo, {required BuildContext context}) {
    return SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile(arquivo.path, mimeType: 'application/json'),
        ],
        text: 'Backup do meu progresso no Foco',
        subject: 'Foco — backup de ${p.basename(arquivo.path)}',
        // OBRIGATÓRIO no iPad. Sem isto o app LANÇA EXCEÇÃO ao abrir
        // o menu — e só no tablet, onde você provavelmente não testou.
        sharePositionOrigin: _origem(context),
      ),
    );
  }

  Rect _origem(BuildContext context) {
    final RenderBox? caixa = context.findRenderObject() as RenderBox?;
    if (caixa == null || !caixa.hasSize) {
      // Um retângulo pequeno no canto é melhor que Rect.zero,
      // que em algumas versões do iPadOS também falha.
      return const Rect.fromLTWH(0, 0, 1, 1);
    }
    return caixa.localToGlobal(Offset.zero) & caixa.size;
  }

  // ── Importar ─────────────────────────────────────────────────────────────

  /// Deixa o usuário escolher um arquivo e VALIDA — sem gravar nada.
  ///
  /// Devolve null se o usuário cancelar. A gravação só acontece em
  /// `aplicar`, depois de o usuário conferir o resumo.
  Future<Backup?> escolherEValidar() async {
    final FilePickerResult? resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['json'],
      // Backup é pequeno. Para arquivo grande, use `path` e leia
      // em fluxo — `withData` carregaria tudo na memória.
      withData: true,
      dialogTitle: 'Escolha o backup do Foco',
    );

    // null = CANCELOU. É o segundo caminho mais comum, não um erro.
    if (resultado == null || resultado.files.isEmpty) return null;

    final PlatformFile escolhido = resultado.files.single;

    // Na WEB, `path` é sempre null: só existe `bytes`.
    final List<int>? bytes = escolhido.bytes;
    final String? caminho = escolhido.path;

    final String texto;
    if (bytes != null) {
      try {
        texto = utf8.decode(bytes);
      } on FormatException {
        // Arquivo binário renomeado para .json. `allowedExtensions`
        // não impede isso — só o conteúdo é prova.
        throw const BackupInvalido(
          'Este arquivo não é um texto válido',
          orientacao: 'Escolha um arquivo .json gerado pelo Foco.',
        );
      }
    } else if (caminho != null) {
      texto = await File(caminho).readAsString();
    } else {
      throw const BackupInvalido('Não foi possível ler o arquivo escolhido');
    }

    // Valida a estrutura INTEIRA. Se algo estiver errado, nada foi
    // gravado — o banco do usuário continua intacto.
    return Backup.deTexto(texto);
  }

  /// Aplica o backup. Chame só DEPOIS de o usuário confirmar o resumo.
  Future<void> aplicar(Backup backup) => _gravar(backup);

  // ── Manutenção ───────────────────────────────────────────────────────────

  Future<List<File>> listar() async {
    final Directory pasta = await _pastaDeBackups();

    final List<File> arquivos = pasta
        .listSync()
        .whereType<File>()
        .where((File f) => p.extension(f.path) == '.json')
        .toList()
      // Nome com data ISO ordena alfabeticamente na ordem cronológica:
      // é por isso que o formato do nome importa.
      ..sort((File a, File b) => b.path.compareTo(a.path));

    return arquivos;
  }

  /// Mantém só os N mais recentes.
  ///
  /// Sem isto, um backup por semana durante dois anos ocupa espaço
  /// que o usuário nunca vai limpar sozinho.
  Future<int> limparAntigos({int manter = 5}) async {
    final List<File> arquivos = await listar();
    if (arquivos.length <= manter) return 0;

    int apagados = 0;
    for (final File f in arquivos.skip(manter)) {
      try {
        await f.delete();
        apagados++;
      } on FileSystemException {
        // Arquivo em uso ou já apagado. Não é motivo para falhar
        // a limpeza inteira.
      }
    }
    return apagados;
  }
}
```

> **Arquivo:** `foco_nativo/lib/features/backup/presentation/backup_screen.dart` (novo)

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:foco_nativo/core/arquivos/formato_de_backup.dart';
import 'package:foco_nativo/core/arquivos/servico_de_backup.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.servico});

  final ServicoDeBackup servico;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  List<File> _backups = <File>[];
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _carregarLista();
  }

  Future<void> _carregarLista() async {
    final List<File> lista = await widget.servico.listar();
    if (!mounted) return;
    setState(() => _backups = lista);
  }

  void _avisar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // ── Ações ────────────────────────────────────────────────────────────────

  Future<void> _exportarECompartilhar() async {
    setState(() => _ocupado = true);
    try {
      final File arquivo = await widget.servico.gerar();
      if (!mounted) return;

      await widget.servico.compartilhar(arquivo, context: context);
      await widget.servico.limparAntigos();
      await _carregarLista();

      _avisar('Backup gerado: ${p.basename(arquivo.path)}');
    } on FileSystemException catch (e) {
      // Disco cheio é a causa mais comum aqui.
      _avisar('Não foi possível gravar o backup: ${e.message}');
    } on Object catch (e) {
      _avisar('Não foi possível compartilhar: $e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _importar() async {
    setState(() => _ocupado = true);
    try {
      // Valida SEM gravar nada.
      final Backup? backup = await widget.servico.escolherEValidar();

      // Cancelamento: silêncio. Mostrar "cancelado" seria ruído.
      if (backup == null) return;
      if (!mounted) return;

      // O usuário CONFERE antes de aplicar. Importar sem mostrar o que
      // vai entrar é pedir confiança cega num arquivo que ele talvez
      // nem lembre de onde veio.
      final bool confirmou = await _confirmarImportacao(backup);
      if (!confirmou || !mounted) return;

      await widget.servico.aplicar(backup);
      _avisar('Backup importado: ${backup.resumo}');
    } on BackupInvalido catch (e) {
      // Mensagem que diz o que está errado E o que fazer.
      _avisar(e.orientacao == null ? e.mensagem : '${e.mensagem}. ${e.orientacao}');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<bool> _confirmarImportacao(Backup backup) async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Importar este backup?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Feito ${backup.quandoLegivel}'),
            const SizedBox(height: 8),
            Text(backup.resumo),
            const SizedBox(height: 16),
            Text(
              'Isto substitui os dados atuais do app.',
              style: TextStyle(color: Theme.of(c).colorScheme.error),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Seus dados',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'O backup fica no aparelho e some se você desinstalar '
                    'o app. Compartilhe para guardar em outro lugar.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _ocupado ? null : _exportarECompartilhar,
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Exportar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _ocupado ? null : _importar,
                          icon: const Icon(Icons.file_open_outlined),
                          label: const Text('Importar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Backups no aparelho',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_backups.isEmpty)
            const ListTile(
              leading: Icon(Icons.inbox_outlined),
              title: Text('Nenhum backup ainda'),
            )
          else
            for (final File f in _backups)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(p.basename(f.path)),
                subtitle: Text('${(f.lengthSync() / 1024).toStringAsFixed(1)} KB'),
                trailing: IconButton(
                  icon: const Icon(Icons.ios_share),
                  tooltip: 'Compartilhar',
                  onPressed: () =>
                      widget.servico.compartilhar(f, context: context),
                ),
              ),
        ],
      ),
    );
  }
}
```

> **Arquivo:** `foco_nativo/test/formato_de_backup_test.dart` (novo)

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:foco_nativo/core/arquivos/formato_de_backup.dart';

void main() {
  String backupValido({
    int versao = 1,
    List<Map<String, Object?>>? materias,
    List<Map<String, Object?>>? sessoes,
  }) {
    return jsonEncode(<String, Object?>{
      'formato': 'foco-backup',
      'versao': versao,
      'exportado_em': DateTime(2026, 3, 10).toUtc().toIso8601String(),
      'app': <String, Object?>{'versao': '1.0.0'},
      'dados': <String, Object?>{
        'materias': materias ??
            <Map<String, Object?>>[
              <String, Object?>{'id': 'dart', 'nome': 'Dart'},
            ],
        'sessoes': sessoes ??
            <Map<String, Object?>>[
              <String, Object?>{
                'id': 's1',
                'materia_id': 'dart',
                'minutos': 25,
              },
            ],
      },
    });
  }

  group('backup válido', () {
    test('lê os dados', () {
      final Backup b = Backup.deTexto(backupValido());

      expect(b.versao, 1);
      expect(b.materias, hasLength(1));
      expect(b.sessoes, hasLength(1));
      expect(b.versaoDoApp, '1.0.0');
    });

    test('resumo conta minutos', () {
      final Backup b = Backup.deTexto(backupValido(
        sessoes: <Map<String, Object?>>[
          <String, Object?>{'id': 's1', 'materia_id': 'dart', 'minutos': 25},
          <String, Object?>{'id': 's2', 'materia_id': 'dart', 'minutos': 50},
        ],
      ));

      expect(b.resumo, contains('75 minutos'));
    });

    test('ida e volta preserva os dados', () {
      final String texto = Backup.gerarTexto(
        materias: <Map<String, Object?>>[
          <String, Object?>{'id': 'dart', 'nome': 'Dart'},
        ],
        sessoes: <Map<String, Object?>>[
          <String, Object?>{'id': 's1', 'materia_id': 'dart', 'minutos': 25},
        ],
        versaoDoApp: '1.0.0',
      );

      final Backup b = Backup.deTexto(texto);
      expect(b.materias.single['nome'], 'Dart');
    });
  });

  group('arquivo recusado', () {
    test('não é JSON', () {
      expect(
        () => Backup.deTexto('isto não é json'),
        throwsA(isA<BackupInvalido>()),
      );
    });

    test('JSON de outro app', () {
      // O usuário pode escolher QUALQUER json no seletor.
      expect(
        () => Backup.deTexto('{"name":"outro-app","version":"2.0"}'),
        throwsA(isA<BackupInvalido>().having(
          (BackupInvalido e) => e.mensagem,
          'mensagem',
          contains('não é um backup do Foco'),
        )),
      );
    });

    test('versão mais nova que a do app', () {
      expect(
        () => Backup.deTexto(backupValido(versao: 99)),
        throwsA(isA<BackupInvalido>().having(
          (BackupInvalido e) => e.orientacao,
          'orientacao',
          contains('Atualize'),
        )),
      );
    });

    test('estrutura incompleta', () {
      expect(
        () => Backup.deTexto(
          '{"formato":"foco-backup","versao":1,"dados":{}}',
        ),
        throwsA(isA<BackupInvalido>()),
      );
    });

    test('matéria sem id', () {
      expect(
        () => Backup.deTexto(backupValido(
          materias: <Map<String, Object?>>[
            <String, Object?>{'nome': 'sem id'},
          ],
          sessoes: <Map<String, Object?>>[],
        )),
        throwsA(isA<BackupInvalido>()),
      );
    });

    test('sessão órfã é recusada', () {
      // Sem esta checagem, o banco ficaria com sessões apontando
      // para matérias que não existem.
      expect(
        () => Backup.deTexto(backupValido(
          materias: <Map<String, Object?>>[
            <String, Object?>{'id': 'dart', 'nome': 'Dart'},
          ],
          sessoes: <Map<String, Object?>>[
            <String, Object?>{
              'id': 's1',
              'materia_id': 'materia_que_nao_existe',
              'minutos': 25,
            },
          ],
        )),
        throwsA(isA<BackupInvalido>().having(
          (BackupInvalido e) => e.mensagem,
          'mensagem',
          contains('sem a matéria correspondente'),
        )),
      );
    });

    test('toda mensagem de erro é compreensível', () {
      // Nenhuma pode conter jargão técnico.
      for (final String texto in <String>[
        'nada disso',
        '{}',
        '{"formato":"outro"}',
        backupValido(versao: 99),
      ]) {
        try {
          Backup.deTexto(texto);
          fail('deveria ter lançado');
        } on BackupInvalido catch (e) {
          expect(e.mensagem, isNot(contains('Exception')));
          expect(e.mensagem, isNot(contains('FormatException')));
          expect(e.mensagem.length, greaterThan(15));
        }
      }
    });
  });

  group('nome de arquivo', () {
    test('ordena cronologicamente por ordem alfabética', () {
      final String antigo =
          FormatoDeBackup.nomeDeArquivo(DateTime(2026, 1, 5, 10));
      final String novo =
          FormatoDeBackup.nomeDeArquivo(DateTime(2026, 3, 10, 14));

      // É por isso que o formato ISO no nome importa: ordenar por
      // nome é ordenar por data.
      expect(antigo.compareTo(novo), lessThan(0));
    });

    test('não tem caractere proibido em nome de arquivo', () {
      final String nome = FormatoDeBackup.nomeDeArquivo(DateTime.now());
      // ':' é proibido no Windows e confunde no Android.
      expect(nome, isNot(contains(':')));
    });
  });
}
```

> **Arquivo:** `foco_nativo/ios/Runner/Info.plist` (opcional — só se o app **produz** documentos)

```xml
<!--
  Faz a pasta Documents do app aparecer no app "Arquivos" do iOS.

  Bom para um app que PRODUZ documentos que o usuário quer manipular.
  RUIM para um app que guarda banco de dados ali — o usuário passaria
  a ver (e a poder apagar) o `foco.db`.

  Se você ativar isto, mova o banco para
  getApplicationSupportDirectory(), que NÃO fica visível.
-->
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

Rode:

```powershell
flutter pub add file_picker share_plus path_provider path
flutter analyze
flutter test
flutter run -d windows
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `formato`, `versao`, `exportado_em`, `app.versao` | Um backup é contrato com o futuro. Sem esses campos, uma versão futura não sabe se consegue ler. |
| `versao > versaoAtual` → recusa | Backup de app mais novo pode ter campos que esta versão não conhece. Importar às cegas os perderia **em silêncio**. |
| Validação **item a item** de matérias e sessões | Um único item inválido no meio de 500 quebraria a importação lá adiante, com o banco pela metade. |
| Checagem de **sessão órfã** | Sessão apontando para matéria ausente deixaria o banco inconsistente. |
| `Backup.deTexto` valida **tudo** antes de devolver | Quem chama recebe objeto completo ou exceção — nunca estado parcial. |
| `BackupInvalido` com `orientacao` | Diz **o que fazer**, não só que falhou. |
| `JsonEncoder.withIndent('  ')` | Backup legível vale mais que bytes economizados — e facilita muito o suporte. |
| Nome com data ISO, `:` trocado por `-` | `:` é proibido no Windows. E o formato ISO faz ordenar por nome ser ordenar por data. |
| Subpasta `backups/` | Sem ela, os backups se misturam com o banco e listar vira um filtro. |
| `writeAsString(..., flush: true)` | Garante a gravação em disco antes de retornar. Importa se o app for morto logo depois. |
| `sharePositionOrigin` com fallback `Rect.fromLTWH(0,0,1,1)` | **Obrigatório no iPad**; `Rect.zero` também falha em algumas versões. |
| `escolherEValidar` devolvendo `null` no cancelamento | Cancelar é o segundo caminho mais comum. Tratar como erro produziria mensagens irritantes. |
| `bytes` **e** `path` tratados | Na web, `path` é sempre `null`. |
| `utf8.decode` em `try/catch` | Arquivo binário renomeado para `.json`. `allowedExtensions` não impede — só o conteúdo prova. |
| `escolherEValidar` separado de `aplicar` | O usuário confere o resumo **antes** de qualquer gravação. |
| `limparAntigos(manter: 5)` | Um backup por semana durante dois anos ocupa espaço que o usuário nunca limpa sozinho. |
| `on FileSystemException` dentro do laço de limpeza | Um arquivo em uso não deve falhar a limpeza inteira. |
| Nenhuma permissão em todo o arquivo | Pasta do app é livre; o seletor dispensa permissão porque o usuário aponta. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Pasta do app | `/data/data/<pacote>/files/` | `Documents/` na sandbox |
| Escrever lá | Sem permissão | Sem permissão |
| Escolher arquivo | Storage Access Framework | `UIDocumentPickerViewController` |
| Permissão para o seletor | ❌ Nenhuma | ❌ Nenhuma |
| Compartilhar | `Intent.ACTION_SEND` | `UIActivityViewController` |
| Menu ancorado | Não precisa | **Precisa** no iPad |
| Salvar em Downloads | Via seletor (`saveFile`) | Via app Arquivos |
| Visível para o usuário | Só se ele escolher salvar fora | Só com `UIFileSharingEnabled` |
| Acesso amplo | `MANAGE_EXTERNAL_STORAGE` — exige justificativa ao Google | ❌ Não existe |

> ⚠️ **As duas linhas que mais geram bug:**
>
> **`sharePositionOrigin`** — o app funciona perfeitamente no iPhone e **trava** no iPad. Como
> poucos testam em tablet, o bug chega à loja.
>
> **`MANAGE_EXTERNAL_STORAGE`** — funciona no seu aparelho e é **rejeitada na publicação**. O Google
> exige justificativa, e "meu app faz backup" não é aceita: para isso existe o seletor.

> 📌 Para **salvar** em um local escolhido pelo usuário (em vez de compartilhar),
> `FilePicker.platform.saveFile(...)` abre o seletor de salvamento nas duas plataformas.

---

## ⚠️ Erros comuns

### 1. Pedir `WRITE_EXTERNAL_STORAGE`

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

Do Android 11 em diante, **não tem efeito**.

**Correção:** pasta do app + seletor do sistema.

### 2. Pedir `MANAGE_EXTERNAL_STORAGE`

Funciona no seu aparelho; o app é **rejeitado** na publicação.

**Correção:** seletor de arquivos.

### 3. Escrever um caminho absoluto

```dart
final File f = File('/storage/emulated/0/Download/backup.json');   // ❌
```

```text
FileSystemException: Cannot open file, path = '...' (OS Error: Permission denied)
```

**Correção:** `path_provider` para a pasta do app; seletor para o resto.

### 4. Tratar cancelamento como erro

```dart
if (resultado == null) {
  mostrarErro('Falha ao selecionar arquivo');   // ❌
}
```

O usuário desistir é normal.

**Correção:** `return` em silêncio.

### 5. Esquecer `sharePositionOrigin`

```dart
await SharePlus.instance.share(ShareParams(files: <XFile>[XFile(caminho)]));
```

```text
PlatformException: Failed to present UIActivityViewController
```

Só no iPad.

**Correção:** sempre passe a origem.

### 6. Confiar em `allowedExtensions`

```dart
final Backup b = Backup.deTexto(await File(caminho).readAsString());   // ⚠️
```

O usuário pode renomear qualquer arquivo para `.json`.

**Correção:** valide o **conteúdo**, sempre.

### 7. Importar sem validar tudo antes

```dart
for (final m in materias) {
  await dao.inserir(Materia.deJson(m));   // ⚠️ e se o item 300 for inválido?
}
```

O banco fica pela metade.

**Correção:** valide o arquivo inteiro; só então grave (e dentro de uma transação).

### 8. Backup sem versão

```json
{ "materias": [...] }
```

Um ano depois, ninguém sabe se o app consegue ler.

**Correção:** `formato` + `versao` no cabeçalho.

### 9. Importar sem mostrar o que vai entrar

O usuário confia às cegas num arquivo que talvez nem lembre de onde veio.

**Correção:** resumo + confirmação.

### 10. `withData: true` em arquivo grande

```dart
withData: true,   // ⚠️ um vídeo de 2 GB na memória
```

**Correção:** use `path` e leia em fluxo para arquivos grandes.

### 11. Esquecer que na web `path` é `null`

```dart
final File f = File(arquivo.path!);   // ❌ quebra na web
```

**Correção:** trate `bytes` e `path`.

### 12. Backups acumulando sem limite

**Correção:** `limparAntigos(manter: 5)`.

### 13. Ativar `UIFileSharingEnabled` com o banco em `Documents/`

O usuário passa a ver — e a poder apagar — o `foco.db`.

**Correção:** mova o banco para `getApplicationSupportDirectory()`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test test/formato_de_backup_test.dart`. Leia o teste
`sessão órfã é recusada` e explique por escrito o que ele evita.

**Passo 2.** Exporte um backup no app. Encontre o arquivo (o log mostra o caminho) e abra num
editor de texto. Confirme que ele é legível.

**Passo 3.** Edite o backup à mão: mude `"formato"` para `"outro"`. Importe e leia a mensagem.

**Passo 4.** Mude `"versao"` para `99`. Importe e compare a mensagem com a do passo 3.

**Passo 5.** Apague uma matéria do backup, mantendo as sessões dela. Importe e veja a validação de
órfã agir.

**Passo 6.** Renomeie um `.png` para `.json` e tente importar. Qual mensagem aparece? O
`allowedExtensions` impediu a escolha?

**Passo 7.** Remova o `sharePositionOrigin` do `compartilhar`. Se tiver um iPad ou simulador de
iPad, rode e observe. Se não tiver, anote por que isso é perigoso.

**Passo 8.** Acrescente `WRITE_EXTERNAL_STORAGE` ao manifest e tente escrever em
`/storage/emulated/0/Download/`. Em um emulador Android 11+, leia o erro.

**Passo 9.** Gere 8 backups seguidos e rode `limparAntigos(manter: 5)`. Confirme que 3 foram
apagados e que sobraram **os mais recentes**.

**Passo 10.** Responda por escrito: por que `escolherEValidar` e `aplicar` são métodos separados? O
que aconteceria se fossem um só?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os exercícios de **Aplicação** com exportação e importação, o de **Correção de bugs** com
validação ausente, e o de **Compreensão** sobre escopo de armazenamento.

---

## 🏆 Desafio opcional

Implemente **importação com mesclagem** em vez de substituição.

Hoje o backup substitui tudo. Faça o usuário poder escolher:

- **Substituir** — apaga o que existe e importa (o comportamento atual);
- **Mesclar** — mantém o que existe e acrescenta o que falta;
- **Só o que falta** — importa apenas matérias cujo `id` não existe localmente.

Requisitos:

- A tela de confirmação mostra o resultado de cada opção **antes** de aplicar:
  "Substituir: 12 matérias · Mesclar: 18 matérias (6 novas) · Só o que falta: 6 novas".
- Conflito de `id` com dados diferentes: o mais recente ganha (compare `alterada_em`).
- A importação inteira roda numa **transação**: falhou no meio, nada foi gravado.
- Testes cobrem os três modos e o caso de conflito.

Dica: calcule o resultado das três opções **antes** de mostrar o diálogo — é o que permite exibir os
números. Um `ResumoDaImportacao` com os três cenários resolve.

Depois responda: por que "mesclar" é mais perigoso que "substituir", apesar de parecer mais
conservador? (Dica: pense em duas matérias com o mesmo nome e ids diferentes.)

---

## 📌 Resumo

- **Arquivos do app** (pasta privada) não precisam de permissão. **Arquivos do usuário** exigem o
  **seletor do sistema** — que também dispensa permissão.
- Do **Android 11** em diante, `WRITE_EXTERNAL_STORAGE` **não tem efeito**.
  `MANAGE_EXTERNAL_STORAGE` exige justificativa ao Google e é rejeitada em apps comuns.
- O **iOS sempre foi sandbox**. As portas de entrada e saída são o seletor de documentos e o menu
  de compartilhar.
- Um backup precisa de **`formato`, `versao`, `exportado_em` e `app.versao`** — ele é um contrato
  com o futuro.
- **Valide tudo antes de aplicar.** Importar enquanto valida deixa o banco pela metade.
- Valide também a **integridade referencial** (sessão sem matéria) e recuse **versão mais nova**
  que o app conhece.
- **`allowedExtensions` não é garantia**: valide o conteúdo.
- `FilePicker` devolve **`null` no cancelamento** — não é erro.
- Na **web**, `path` é sempre `null`: use `bytes`.
- **`sharePositionOrigin` é obrigatório no iPad** — sem ele o app trava, e só no tablet.
- Separe **escolher/validar** de **aplicar**: o usuário confere o resumo antes de gravar.
- Nome de arquivo com **data ISO** faz ordem alfabética virar ordem cronológica. Sem `:`.
- **Limpe backups antigos** — o usuário nunca faz isso sozinho.
- Pacote só quando precisa de **tela ou API do sistema**. Arquivo puro é `dart:io`.

---

## ☑️ Checklist de domínio

- [ ] Distingo arquivos do app de arquivos do usuário.
- [ ] Sei que a pasta do app dispensa permissão.
- [ ] Sei que `WRITE_EXTERNAL_STORAGE` não funciona mais.
- [ ] Sei por que `MANAGE_EXTERNAL_STORAGE` é rejeitada.
- [ ] Incluo formato, versão e data no backup.
- [ ] Valido a estrutura inteira antes de gravar qualquer coisa.
- [ ] Valido integridade referencial e versão do formato.
- [ ] Nunca confio na extensão do arquivo.
- [ ] Trato cancelamento do seletor em silêncio.
- [ ] Trato `bytes` e `path`, pensando na web.
- [ ] Sempre passo `sharePositionOrigin`.
- [ ] Separo validar de aplicar, e mostro resumo ao usuário.
- [ ] Limpo backups antigos.
- [ ] Escolho pacote só quando preciso de API nativa.

---

## 📚 Referências oficiais

- [file_picker — pub.dev](https://pub.dev/packages/file_picker)
- [share_plus — pub.dev](https://pub.dev/packages/share_plus)
- [path_provider — pub.dev](https://pub.dev/packages/path_provider)
- [Read and write files — docs.flutter.dev](https://docs.flutter.dev/cookbook/persistence/reading-writing-files)
- [Scoped storage — developer.android.com](https://developer.android.com/training/data-storage#scoped-storage)
- [Storage Access Framework — developer.android.com](https://developer.android.com/guide/topics/providers/document-provider)
- [File System Programming Guide — developer.apple.com](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/)
- [UIActivityViewController — developer.apple.com](https://developer.apple.com/documentation/uikit/uiactivityviewcontroller)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Câmera e galeria](02-camera-e-galeria.md) | [README](README.md) | [Aula 4 — Notificações](04-notificacoes.md) |
