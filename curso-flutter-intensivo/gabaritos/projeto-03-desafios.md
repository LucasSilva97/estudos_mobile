# Gabarito dos desafios — Projeto Final: Foco

> Compare depois de tentar. Estes desafios são o fecho do curso: vários exigem combinar módulos
> diferentes, e é justamente nessa junção que o aprendizado sedimenta.

Enunciados em [13-desafios.md](../projetos/03-projeto-final-multiplataforma/13-desafios.md).

---

<a id="p03-d01"></a>
## P03-D01 — Exportar as sessões em CSV

> **Arquivo:** `lib/features/sessoes/domain/exportador_csv.dart` (novo)

```dart
/// Gera o CSV. Dart puro, sem I/O — por isso é testável sem plugin.
abstract final class ExportadorCsv {
  static const String _sep = ';';

  static String gerar(List<Sessao> sessoes, Map<String, String> nomePorMateria) {
    final StringBuffer buffer = StringBuffer()
      // O BOM é o que faz o Excel abrir em UTF-8; sem ele,
      // "Matemática" vira "MatemÃ¡tica".
      ..write('﻿')
      ..writeln(<String>['data', 'materia', 'minutos', 'anotacao'].join(_sep));

    for (final Sessao s in sessoes) {
      buffer.writeln(<String>[
        _formatarData(s.quando),
        _escapar(nomePorMateria[s.materiaId] ?? '(removida)'),
        '${s.minutos}',
        _escapar(s.anotacao),
      ].join(_sep));
    }
    return buffer.toString();
  }

  /// Campo com separador, aspas ou quebra de linha vai entre aspas,
  /// e aspas internas viram duas. É a regra do RFC 4180 — sem ela,
  /// uma anotação com ';' desloca todas as colunas seguintes.
  static String _escapar(String valor) {
    if (!valor.contains(_sep) &&
        !valor.contains('"') &&
        !valor.contains('\n')) {
      return valor;
    }
    return '"${valor.replaceAll('"', '""')}"';
  }

  static String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
```

E a ação, na tela:

```dart
Future<void> _exportar() async {
  final String csv = ExportadorCsv.gerar(sessoes, nomePorMateria);

  final Directory dir = await getTemporaryDirectory();
  final File arquivo = File('${dir.path}/foco-sessoes.csv');
  await arquivo.writeAsString(csv, encoding: utf8);

  await Share.shareXFiles(<XFile>[XFile(arquivo.path)]);
}
```

Duas decisões que valem explicar. O **BOM** (`﻿`) é o que evita a pergunta "por que os acentos
estão estranhos?" — o Excel assume a codificação local sem ele. E a geração ficar em **Dart puro**,
separada da escrita do arquivo, é o que permite testar o escape de `;` sem nenhum plugin de
plataforma.

---

<a id="p03-d02"></a>
## P03-D02 — Busca com filtro por período

> **Arquivo:** `lib/features/materias/data/materia_dao.dart`

```dart
Future<List<Materia>> buscar({
  String termo = '',
  int? ultimosDias,
}) async {
  final List<String> condicoes = <String>['arquivada = 0'];
  final List<Object?> args = <Object?>[];

  if (termo.trim().isNotEmpty) {
    condicoes.add('nome_ordenacao LIKE ?');
    // O % faz parte do VALOR, não da query.
    args.add('%${Texto.paraOrdenacao(termo)}%');
  }

  if (ultimosDias != null) {
    condicoes.add('''
      id IN (SELECT DISTINCT materia_id FROM sessoes WHERE quando >= ?)
    ''');
    args.add(
      DateTime.now()
          .subtract(Duration(days: ultimosDias))
          .toIso8601String(),
    );
  }

  final List<Map<String, Object?>> linhas = await _db.query(
    'materias',
    where: condicoes.join(' AND '),
    whereArgs: args,              // ⭐ RNF11, sem exceção
    orderBy: 'nome_ordenacao ASC',
  );

  return linhas.map(Materia.doMapa).toList();
}
```

O *debounce*, para não consultar a cada tecla:

```dart
Timer? _debounce;

void _aoDigitar(String termo) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () {
    ref.read(buscaProvider.notifier).state = termo;
  });
}

@override
void dispose() {
  _debounce?.cancel();     // ⚠️ sem isto, o teste acusa Timer pendente
  super.dispose();
}
```

Repare que **as condições são montadas em código e os valores vão em `whereArgs`**. Essa separação
é o que permite uma query dinâmica sem abrir a porta para injeção: o SQL é sempre escrito por você,
nunca pelo usuário.

---

<a id="p03-d03"></a>
## P03-D03 — Modo foco com bloqueio de saída

> **Arquivo:** `lib/features/sessoes/presentation/cronometro_screen.dart`

```dart
@override
Widget build(BuildContext context) {
  final CronometroEstado estado = ref.watch(cronometroProvider);
  final bool contando = estado.rodando;

  return PopScope(
    // canPop dinâmico: livre quando parado, bloqueado quando conta.
    canPop: !contando,
    onPopInvokedWithResult: (bool saiu, Object? resultado) async {
      if (saiu) return;             // já saiu, nada a fazer

      final bool descartar = await _confirmarDescarte(context) ?? false;
      if (descartar && context.mounted) {
        ref.read(cronometroProvider.notifier).descartar();
        Navigator.of(context).pop();
      }
    },
    child: Scaffold(/* ... */),
  );
}

Future<bool?> _confirmarDescarte(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog.adaptive(
        title: const Text('Sessão em andamento'),
        content: const Text(
          'Você tem uma sessão sendo cronometrada. Sair agora descarta o tempo.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
```

`canPop: !contando` é o que faz a coisa certa nas duas plataformas de uma vez: 🤖 no Android
intercepta o botão voltar e o gesto; 🍎 no iOS intercepta o arrastar da borda. Fixar `canPop: false`
e liberar só no diálogo funcionaria, mas bloquearia a saída **também** com o cronômetro parado —
atrito onde não há nada a perder.

`WillPopScope` foi removido do Flutter; material antigo que o mencione está desatualizado.

---

<a id="p03-d04"></a>
## P03-D04 — Lembrete diário que lê a meta do banco

> **Arquivo:** `lib/features/lembretes/domain/texto_do_lembrete.dart` (novo)

```dart
/// Dart puro: o texto é regra de negócio, e regra de negócio se testa
/// sem plugin de notificação.
abstract final class TextoDoLembrete {
  static String montar({
    required int minutosHoje,
    required int metaSemanal,
    required int minutosSemana,
  }) {
    final int metaDiaria = (metaSemanal / 7).round();

    if (minutosHoje >= metaDiaria) {
      return 'Meta batida! $minutosSemana min esta semana';
    }
    final int faltam = metaDiaria - minutosHoje;
    return 'Faltam $faltam min para a sua meta de hoje';
  }
}
```

O agendamento:

```dart
Future<void> agendarLembrete(TimeOfDay horario) async {
  // 1. A permissão é pedida AQUI — no momento em que o usuário
  //    ativa o lembrete, nunca na abertura do app.
  final ResultadoPermissao r =
      await const GerenciadorPermissoes().pedirNotificacoes();

  switch (r) {
    case ResultadoPermissao.concedida:
      break;
    case ResultadoPermissao.negada:
      _avisar('Sem problema. Você pode ativar depois em Ajustes.');
      return;
    case ResultadoPermissao.negadaParaSempre:
      // ⚠️ request() aqui não abriria diálogo nenhum.
      await _mandarParaConfiguracoes();
      return;
    case ResultadoPermissao.restrita:
      _avisar('As notificações estão bloqueadas neste aparelho.');
      return;
  }

  // 2. Só depois de concedida é que o dado real é lido.
  final int hoje = await _repo.minutosDe(DateTime.now());
  final int semana = await _repo.minutosDaSemana();
  final int meta = await _prefs.metaSemanal();

  await _notificacoes.zonedSchedule(
    0,
    'Foco',
    TextoDoLembrete.montar(
      minutosHoje: hoje,
      metaSemanal: meta,
      minutosSemana: semana,
    ),
    _proximaOcorrencia(horario),
    const NotificationDetails(/* ... */),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,   // repete diariamente
  );
}
```

O desafio cruza três módulos e cada um contribui uma decisão: o **10** dá o dado real (ler do banco,
não chutar), o **11** dá o agendamento, e o **14** dá o tratamento dos quatro estados de permissão.
Tratar só `granted` é o erro que deixa o usuário com um botão que não faz nada e nenhuma explicação.

`inexactAllowWhileIdle` evita precisar de `SCHEDULE_EXACT_ALARM`, que exige declaração justificada
na Play Console — e um lembrete de estudo não precisa de precisão ao segundo.

---

<a id="p03-d05"></a>
## P03-D05 — Sequência de dias estudados

> **Arquivo:** `lib/features/estatisticas/domain/sequencia.dart` (novo)

```dart
class Sequencia {
  const Sequencia({required this.atual, required this.recorde});
  final int atual;
  final int recorde;
}

abstract final class CalculadoraDeSequencia {
  /// [diasComSessao] são datas já normalizadas para meia-noite.
  /// [hoje] entra por parâmetro — é o que torna o teste determinístico.
  static Sequencia calcular({
    required Set<DateTime> diasComSessao,
    required DateTime hoje,
  }) {
    if (diasComSessao.isEmpty) return const Sequencia(atual: 0, recorde: 0);

    final DateTime dHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final List<DateTime> ordenados = diasComSessao.toList()..sort();

    // ── Sequência atual ──
    // Conta para trás a partir de hoje. Se hoje ainda não tem sessão,
    // a sequência continua viva desde que ontem tenha — o dia não acabou.
    int atual = 0;
    DateTime cursor = diasComSessao.contains(dHoje)
        ? dHoje
        : dHoje.subtract(const Duration(days: 1));

    while (diasComSessao.contains(cursor)) {
      atual++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // ── Recorde ──
    int recorde = 1;
    int corrente = 1;
    for (int i = 1; i < ordenados.length; i++) {
      final bool consecutivo = ordenados[i]
              .difference(ordenados[i - 1])
              .inDays ==
          1;
      corrente = consecutivo ? corrente + 1 : 1;
      if (corrente > recorde) recorde = corrente;
    }

    return Sequencia(atual: atual, recorde: recorde < atual ? atual : recorde);
  }
}
```

Os testes que o enunciado exige:

```dart
void main() {
  final DateTime hoje = DateTime(2026, 3, 10);   // fixo, nunca DateTime.now()
  DateTime d(int dia) => DateTime(2026, 3, dia);

  test('sem sessão nenhuma', () {
    final Sequencia s = CalculadoraDeSequencia.calcular(
        diasComSessao: <DateTime>{}, hoje: hoje);
    expect(s.atual, 0);
    expect(s.recorde, 0);
  });

  test('só hoje', () {
    expect(
      CalculadoraDeSequencia.calcular(
              diasComSessao: <DateTime>{d(10)}, hoje: hoje)
          .atual,
      1,
    );
  });

  test('termina ontem: a sequência continua viva', () {
    // O dia de hoje ainda não acabou — quebrar aqui puniria
    // quem vai estudar à noite.
    expect(
      CalculadoraDeSequencia.calcular(
              diasComSessao: <DateTime>{d(8), d(9)}, hoje: hoje)
          .atual,
      2,
    );
  });

  test('termina anteontem: a sequência quebrou', () {
    expect(
      CalculadoraDeSequencia.calcular(
              diasComSessao: <DateTime>{d(7), d(8)}, hoje: hoje)
          .atual,
      0,
    );
  });

  test('virada de mês', () {
    expect(
      CalculadoraDeSequencia.calcular(
        diasComSessao: <DateTime>{
          DateTime(2026, 2, 28),
          DateTime(2026, 3, 1),
        },
        hoje: DateTime(2026, 3, 1),
      ).atual,
      2,
    );
  });

  test('ano bissexto: 2024 tem 29 de fevereiro', () {
    expect(
      CalculadoraDeSequencia.calcular(
        diasComSessao: <DateTime>{
          DateTime(2024, 2, 28),
          DateTime(2024, 2, 29),
          DateTime(2024, 3, 1),
        },
        hoje: DateTime(2024, 3, 1),
      ).atual,
      3,
    );
  });

  test('recorde maior que a sequência atual', () {
    final Sequencia s = CalculadoraDeSequencia.calcular(
      diasComSessao: <DateTime>{d(1), d(2), d(3), d(4), d(10)},
      hoje: hoje,
    );
    expect(s.atual, 1);
    expect(s.recorde, 4);
  });

  test('virada de ano', () {
    expect(
      CalculadoraDeSequencia.calcular(
        diasComSessao: <DateTime>{
          DateTime(2025, 12, 31),
          DateTime(2026, 1, 1),
        },
        hoje: DateTime(2026, 1, 1),
      ).atual,
      2,
    );
  });
}
```

O ponto central é `hoje` entrar **por parâmetro**. Com `DateTime.now()` dentro da função, o teste
de "virada de mês" só passaria em 1º de março, e a suíte inteira viraria uma bomba-relógio. Usar
`Duration(days: 1)` em vez de aritmética manual resolve mês, ano e bissexto de graça.

---

<a id="p03-d06"></a>
## P03-D06 — Migração v2 → v3 sem perder dados

> **Arquivo:** `lib/core/banco/banco_foco.dart`

```dart
static const int versaoAtual = 3;

Future<void> _onUpgrade(Database db, int de, int para) async {
  // Sequência de ifs, não switch: quem está na v1 precisa passar
  // pela v2 e pela v3, na ordem.
  if (de < 2) await _paraV2(db);
  if (de < 3) await _paraV3(db);
}

Future<void> _paraV3(Database db) async {
  // ALTER TABLE ADD COLUMN preserva os dados existentes.
  // Recriar a tabela e copiar seria mais frágil e mais lento.
  await db.execute('ALTER TABLE sessoes ADD COLUMN humor INTEGER');
  await db.execute(
    'ALTER TABLE materias ADD COLUMN meta_semanal_minutos INTEGER',
  );
}

Future<void> _onCreate(Database db, int versao) async {
  // ⚠️ Instalação limpa precisa nascer com o esquema COMPLETO.
  // Esquecer as colunas novas aqui cria o bug mais confuso possível:
  // funciona para quem atualizou e quebra para quem instalou agora.
  await db.execute('''
    CREATE TABLE materias (
      id TEXT PRIMARY KEY,
      nome TEXT NOT NULL,
      nome_ordenacao TEXT NOT NULL,
      cor INTEGER NOT NULL,
      minutos INTEGER NOT NULL DEFAULT 0,
      arquivada INTEGER NOT NULL DEFAULT 0,
      meta_semanal_minutos INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE sessoes (
      id TEXT PRIMARY KEY,
      materia_id TEXT NOT NULL,
      minutos INTEGER NOT NULL,
      quando TEXT NOT NULL,
      anotacao TEXT NOT NULL DEFAULT '',
      humor INTEGER,
      FOREIGN KEY (materia_id) REFERENCES materias (id) ON DELETE CASCADE
    )
  ''');
}
```

Os dois testes:

```dart
test('migração v2 para v3 preserva os dados', () async {
  // 1. Abre na v2 e insere.
  Database db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(version: 2, onCreate: _criarV2),
  );
  await db.insert('materias', <String, Object?>{
    'id': 'dart',
    'nome': 'Dart',
    'nome_ordenacao': 'dart',
    'cor': 0xFF0175C2,
    'minutos': 120,
    'arquivada': 0,
  });
  await db.close();

  // 2. Reabre na v3 — a migração roda aqui.
  db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(version: 3, onUpgrade: banco.onUpgrade),
  );

  // 3. O dado continua lá, e a coluna nova existe como null.
  final List<Map<String, Object?>> linhas = await db.query('materias');
  expect(linhas, hasLength(1));
  expect(linhas.first['minutos'], 120);
  expect(linhas.first['meta_semanal_minutos'], isNull);
  await db.close();
});

test('instalação limpa na v3 já nasce com as colunas novas', () async {
  final Database db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(version: 3, onCreate: banco.onCreate),
  );

  // Se onCreate esquecer a coluna, este insert lança.
  await db.insert('sessoes', <String, Object?>{
    'id': 's1',
    'materia_id': 'dart',
    'minutos': 30,
    'quando': DateTime(2026, 3, 10).toIso8601String(),
    'humor': 4,
  });

  expect(await db.query('sessoes'), hasLength(1));
  await db.close();
});
```

> 📌 **O segundo teste é o que quase ninguém escreve** — e é exatamente o bug que passa despercebido:
> quem atualiza recebe a coluna pelo `ALTER TABLE`, quem instala do zero recebe pelo `onCreate`, e
> esquecer de atualizar o segundo produz um app que funciona para você (que atualizou) e quebra para
> todo usuário novo.

---

<a id="p03-d07"></a>
## P03-D07 — Sincronização offline-first com fila

> **Arquivo:** `lib/features/sync/data/fila_dao.dart` (novo)

```sql
CREATE TABLE fila_sync (
  id INTEGER PRIMARY KEY AUTOINCREMENT,   -- a ordem É o id
  operacao TEXT NOT NULL,
  carga TEXT NOT NULL,                    -- JSON
  tentativas INTEGER NOT NULL DEFAULT 0,
  ultimo_erro TEXT
)
```

> **Arquivo:** `lib/features/sync/data/sincronizador.dart`

```dart
/// Distinguir os dois tipos de falha é a decisão central deste desafio.
sealed class ResultadoEnvio {
  const ResultadoEnvio();
}

/// Rede fora, timeout, 5xx — o servidor não disse que está errado,
/// disse que não conseguiu. Vale tentar de novo.
final class FalhaTemporaria extends ResultadoEnvio {
  const FalhaTemporaria(this.motivo);
  final String motivo;
}

/// 4xx — o servidor recusou o conteúdo. Tentar de novo dará o mesmo
/// resultado para sempre; a operação sai da fila.
final class FalhaPermanente extends ResultadoEnvio {
  const FalhaPermanente(this.motivo);
  final String motivo;
}

final class EnvioOk extends ResultadoEnvio {
  const EnvioOk();
}

class Sincronizador {
  bool _rodando = false;

  Future<void> sincronizar() async {
    // ⭐ A trava. Sem ela, religar a rede com o app aberto dispara
    // duas sincronizações concorrentes e duplica o envio.
    if (_rodando) return;
    _rodando = true;

    try {
      final List<ItemFila> pendentes = await _fila.listarEmOrdem();

      for (final ItemFila item in pendentes) {
        final ResultadoEnvio r = await _enviar(item);

        switch (r) {
          case EnvioOk():
            await _fila.remover(item.id);

          case FalhaPermanente(motivo: final m):
            // Sai da fila: insistir não mudaria nada.
            await _fila.remover(item.id);
            await _registrarDescarte(item, m);

          case FalhaTemporaria():
            // Fica na fila E interrompe: as próximas falhariam igual,
            // e insistir só gastaria bateria.
            await _fila.marcarTentativa(item.id, r);
            return;
        }
      }
    } finally {
      _rodando = false;
    }
  }
}
```

O `id AUTOINCREMENT` é o que garante a ordem sem coluna de carimbo de tempo — e sem depender do
relógio do aparelho, que o usuário pode mudar. A parada na primeira falha temporária é deliberada:
se a rede caiu, a operação seguinte também vai falhar, e tentar as três só multiplica o gasto.

---

<a id="p03-d08"></a>
## P03-D08 — Pipeline que publica nas duas faixas internas

> **Arquivo:** `.github/workflows/release.yml`

A estrutura completa está no [módulo 17, aula 4](../modulos/17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md).
O que este desafio acrescenta é o **portão dos símbolos**:

```yaml
      - name: Build AAB
        env:
          ANDROID_KEYSTORE_PATH: ${{ runner.temp }}/upload.jks
          ANDROID_STORE_PASSWORD: ${{ secrets.ANDROID_STORE_PASSWORD }}
          ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
        run: |
          flutter build appbundle --release \
            --obfuscate --split-debug-info=simbolos/${{ github.ref_name }}

          # ⭐ O portão que o desafio pede. Um build sem símbolos
          # passaria despercebido — e os crashes dessa versão seriam
          # ilegíveis PARA SEMPRE, sem como regerar.
          if [ -z "$(find simbolos/${{ github.ref_name }} -name '*.symbols')" ]; then
            echo "::error::Nenhum símbolo gerado — abortando o release"
            exit 1
          fi
          if [ ! -f build/app/outputs/mapping/release/mapping.txt ]; then
            echo "::error::mapping.txt do R8 ausente"
            exit 1
          fi

      - name: Arquivar os três conjuntos de símbolos
        uses: actions/upload-artifact@v4
        with:
          name: simbolos-${{ github.ref_name }}
          path: |
            simbolos/
            build/app/outputs/mapping/release/mapping.txt
            build/ios/archive/Runner.xcarchive/dSYMs/
          retention-days: 90
```

E o que torna este desafio possível para quem está no Windows:

```yaml
  ios:
    needs: qualidade
    runs-on: macos-latest      # ⭐ o Mac que você não tem
```

Sobre os segredos: o `set-key-partition-list` do keychain temporário é o que impede o `codesign` de
travar o job pedindo senha interativamente — a pegadinha mais cara desse pipeline, porque o job
fica pendurado até o timeout sem mensagem de erro.

Nenhum `echo` de variável derivada de secret: o mascaramento do GitHub cobre o valor exato, não
transformações dele, e o log de um repositório público é permanente.

---

<a id="p03-d09"></a>
## P03-D09 — Gráfico próprio com `CustomPainter`

> **Arquivo:** `lib/features/estatisticas/presentation/grafico_semana.dart` (novo)

```dart
class _PintorDaSemana extends CustomPainter {
  _PintorDaSemana({
    required this.minutosPorDia,
    required this.cor,
    required this.indiceDeHoje,
  });

  final List<int> minutosPorDia;   // 7 posições, segunda a domingo
  final Color cor;
  final int indiceDeHoje;

  @override
  void paint(Canvas canvas, Size size) {
    if (minutosPorDia.isEmpty) return;

    final int maior = minutosPorDia.reduce((int a, int b) => a > b ? a : b);
    // Divisão por zero se a semana estiver vazia — o max(1) resolve.
    final double escala = size.height / (maior == 0 ? 1 : maior);
    final double passo = size.width / (minutosPorDia.length - 1);

    final List<Offset> pontos = <Offset>[
      for (int i = 0; i < minutosPorDia.length; i++)
        Offset(i * passo, size.height - minutosPorDia[i] * escala),
    ];

    // Área preenchida, fechada na base.
    final Path area = Path()..moveTo(0, size.height);
    for (final Offset p in pontos) {
      area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[cor.withValues(alpha: 0.35), cor.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );

    // A linha por cima.
    final Path linha = Path()..moveTo(pontos.first.dx, pontos.first.dy);
    for (final Offset p in pontos.skip(1)) {
      linha.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linha,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // O ponto de hoje.
    if (indiceDeHoje >= 0 && indiceDeHoje < pontos.length) {
      canvas.drawCircle(pontos[indiceDeHoje], 5, Paint()..color = cor);
    }
  }

  @override
  bool shouldRepaint(_PintorDaSemana anterior) =>
      // ⭐ Sem esta comparação, o gráfico é redesenhado a cada quadro
      // da árvore inteira — o custo aparece na thread de RASTER.
      !listEquals(anterior.minutosPorDia, minutosPorDia) ||
      anterior.cor != cor ||
      anterior.indiceDeHoje != indiceDeHoje;
}
```

E a acessibilidade, que o enunciado cobra:

```dart
Semantics(
  label: 'Minutos estudados por dia da semana',
  value: _descrever(minutosPorDia),   // "segunda 45, terça 0, quarta 120..."
  // O canvas não tem nada que o leitor de tela possa ler.
  excludeSemantics: true,
  child: LayoutBuilder(
    builder: (BuildContext context, BoxConstraints limites) => CustomPaint(
      size: Size(limites.maxWidth, 140),   // adapta à largura disponível
      painter: _PintorDaSemana(/* ... */),
    ),
  ),
)
```

O `shouldRepaint` é o que separa um gráfico bonito de um gráfico caro. Devolver `true` sempre
funciona visualmente e repinta a cada quadro — exatamente o tipo de custo que aparece como barra
verde alta no DevTools (módulo 13, aula 4).

**Onde a documentação responde:**
[`CustomPainter`](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html) e
[`Canvas`](https://api.flutter.dev/flutter/dart-ui/Canvas-class.html).

---

<a id="p03-d10"></a>
## P03-D10 — Internacionalização pt-BR e en

> **Arquivo:** `l10n.yaml` (novo, na raiz)

```yaml
arb-dir: lib/l10n
template-arb-file: app_pt.arb
output-localization-file: app_localizations.dart
```

> **Arquivo:** `lib/l10n/app_pt.arb`

```json
{
  "@@locale": "pt",
  "minutosEstudados": "{contagem, plural, =0{Nenhum minuto} =1{1 minuto} other{{contagem} minutos}}",
  "@minutosEstudados": {
    "placeholders": { "contagem": { "type": "int" } }
  },
  "metaSemanal": "Meta semanal",
  "registrarSessao": "Registrar sessão",
  "nenhumaMateria": "Nenhuma matéria ainda"
}
```

```dart
// Uso
Text(AppLocalizations.of(context)!.minutosEstudados(45));   // "45 minutos"
Text(AppLocalizations.of(context)!.minutosEstudados(1));    // "1 minuto"
```

O `plural` do ICU é o que resolve o "1 minutos" — e a razão pela qual concatenar
`'$n ${n == 1 ? "minuto" : "minutos"}'` não escala: em inglês são duas formas, em polonês são
quatro, e a regra não é sua para decidir.

O teste por locale:

```dart
testWidgets('a tela monta em inglês', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    locale: Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: PainelScreen(),
  ));
  await tester.pumpAndSettle();

  expect(find.text('Weekly goal'), findsOneWidget);
});
```

> 📌 **O tamanho do trabalho é a lição.** Extrair as strings de um app pronto leva horas e toca
> praticamente todo arquivo de interface. É por isso que i18n se decide **no início** de um
> projeto — e sentir esse custo na prática ensina mais do que qualquer aviso teria ensinado.

**Onde a documentação responde:**
[Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization).

---

## 🧭 Se a sua solução ficou diferente

| Pergunta | Por que importa |
|---|---|
| O **Esperado:** do enunciado acontece? | É o contrato do desafio |
| A regra ficou no domínio, em Dart puro? | D01, D05 e D10 são sobre isso — e é o que torna testável |
| Alguma data usa `DateTime.now()` dentro da função? | D05 — o teste vira bomba-relógio |
| `onCreate` e `onUpgrade` produzem o mesmo esquema? | D06 — o bug que só atinge quem instala do zero |
| Todo SQL usa `whereArgs`? | RNF11, sem exceção |
| Todo `Timer` e controller tem `cancel`/`dispose`? | O teste acusa Timer pendente |
| `shouldRepaint` compara de verdade? | D09 — senão repinta a cada quadro |
| Algum segredo aparece no log do CI? | D08 — o log é permanente |

Se o resultado é o mesmo e as regras acima valem, a sua versão serve.

---

[Desafios](../projetos/03-projeto-final-multiplataforma/13-desafios.md) ·
[Projeto Final](../projetos/03-projeto-final-multiplataforma/README.md) ·
[Gabaritos](README.md)
