# Gabarito — Módulo 13: Desempenho e segurança

> Compare depois de resolver os [exercícios](../exercicios/13-desempenho-e-seguranca.md).

<a id="m13-e01"></a>
## M13-E01
| Versão | Linhas em 5 toques |
|---|---:|
| `setState` na tela toda | ~200 (≈40 por toque: `Scaffold`, `AppBar`, `Column`, `ListView` e os 4 `MateriaTile`) |
| `ValueListenableBuilder` sem `const` | ~90 (≈18 por toque: o builder e a subárvore do `ListTile`) |
| `ValueListenableBuilder` com `const` | ~90 — o **mesmo** número |

- **`setState`** — só a versão 1: marca o `Element` da tela inteira como sujo.
- **O pai reconstruiu** — só a versão 1: `Column`, `ListView` e os `MateriaTile` entram na conta de carona; é este disparador que o `const CabecalhoDaSemana()` corta.
- **Dependência mudou** (`Theme.of`, `MediaQuery.of`) — nenhuma das três dispara; só trocando tema ou girando a tela.
- **O listenable notificou** — versões 2 e 3: só a subárvore do `builder`.

As linhas 2 e 3 empatam porque o pai não reconstrói: sem rebuild do pai, `const` não tem o que economizar. A diferença do `const` aparece na versão 1.

<a id="m13-e02"></a>
## M13-E02
```dart
return MateriaTile(
  key: ValueKey<String>(materia.id),
  materia: materia,
);
```
`UniqueKey()` seria pior porque, criada dentro de `build`, gera uma key nova a cada quadro: o `Element` é descartado sempre e `_favorita` volta a `false` sozinha.

<a id="m13-e03"></a>
## M13-E03
```dart
class PaginaMaterias {
  const PaginaMaterias({
    this.itens = const <Materia>[],
    this.pagina = 0,
    this.carregandoMais = false,
    this.acabou = false,
    this.erro,
  });

  final List<Materia> itens;
  final int pagina;
  final bool carregandoMais;
  final bool acabou;
  final Object? erro;

  PaginaMaterias copiarCom({
    List<Materia>? itens,
    int? pagina,
    bool? carregandoMais,
    bool? acabou,
    Object? erro,
    bool limparErro = false,
  }) {
    return PaginaMaterias(
      itens: itens ?? this.itens,
      pagina: pagina ?? this.pagina,
      carregandoMais: carregandoMais ?? this.carregandoMais,
      acabou: acabou ?? this.acabou,
      erro: limparErro ? null : (erro ?? this.erro),
    );
  }
}

class MateriasPaginadas extends AsyncNotifier<PaginaMaterias> {
  static const int _porPagina = 20;

  @override
  Future<PaginaMaterias> build() async {
    final List<Materia> primeira = await _buscar(0);
    return PaginaMaterias(
      itens: primeira,
      acabou: primeira.length < _porPagina,
    );
  }

  Future<void> carregarMais() async {
    final PaginaMaterias? atual = state.value;
    if (atual == null || atual.carregandoMais || atual.acabou) return;

    state = AsyncData<PaginaMaterias>(
      atual.copiarCom(carregandoMais: true, limparErro: true),
    );

    try {
      final int proxima = atual.pagina + 1;
      final List<Materia> novos = await _buscar(proxima);
      state = AsyncData<PaginaMaterias>(
        atual.copiarCom(
          itens: <Materia>[...atual.itens, ...novos],
          pagina: proxima,
          carregandoMais: false,
          acabou: novos.length < _porPagina,
        ),
      );
    } catch (e) {
      // AsyncError apagaria as páginas 1 e 2 da tela.
      state = AsyncData<PaginaMaterias>(
        atual.copiarCom(carregandoMais: false, erro: e),
      );
    }
  }
}

final AsyncNotifierProvider<MateriasPaginadas, PaginaMaterias>
    materiasPaginadasProvider =
    AsyncNotifierProvider<MateriasPaginadas, PaginaMaterias>(
  MateriasPaginadas.new,
);

// Na tela, no listener do ScrollController:
void _aoRolar() {
  final ScrollPosition p = _controle.position;
  if (p.pixels >= p.maxScrollExtent * 0.8) {
    ref.read(materiasPaginadasProvider.notifier).carregarMais();
  }
}
```

<a id="m13-e04"></a>
## M13-E04
```text
1 capa:  1200 × 800 × 4 = 3 840 000 B  ≈ 3,84 MB
30 capas: 3,84 × 30                    ≈ 115,2 MB
memCacheWidth = 56 × 3                 = 168 px  → 168 × 168 × 4 ≈ 0,11 MB/capa (≈ 3,4 MB as 30)
```
`width: 56` só encolhe na tela; a decodificação continua em 1200 × 800 até você passar `memCacheWidth`.

<a id="m13-e05"></a>
## M13-E05
```dart
/// Função de TOPO: `compute` exige e `Isolate.run` aceita.
ResumoEstatistico calcularResumo(List<int> minutos) { /* ... */ }

class ImportadorHistorico {
  Future<List<int>> importar(Uri url) async {
    final http.Response resposta = await _cliente.get(url); // rede é espera: sem isolate
    if (resposta.statusCode != 200) throw ImportacaoFalhou('HTTP ${resposta.statusCode}');
    final List<int> bytes = resposta.bodyBytes; // `body` decodificaria UTF-8 na thread de UI
    return bytes.length < _limiteParaIsolate
        ? _extrairMinutos(bytes)
        : Isolate.run(() => _extrairMinutos(bytes));
  }

  Future<ResumoEstatistico> resumir(List<int> minutos) async {
    if (minutos.length < 10000) return calcularResumo(minutos); // cabe nos 16,67 ms
    return Isolate.run(() => calcularResumo(minutos));
  }
}
```
Com `compute(this._calcular, dados)` o Dart quebra em execução com `Invalid argument(s): Illegal argument in isolate message: object is unsendable` — o método carrega o `this` junto, e `this` não atravessa a fronteira do isolate.

<a id="m13-e06"></a>
## M13-E06
Estourou a **raster thread** (38,4 ms contra o orçamento de 16,67 ms); os 3,9 ms de `buildDuration` mostram que o Dart não é o problema — mexer em `const` e rebuild não mudaria nada.

| Causa provável | Correção |
|---|---|
| `Opacity` com valor < 1 forçando `saveLayer` | Cor com alfa (`cores.primary.withValues(alpha: .6)`) ou `AnimatedOpacity` só enquanto anima |
| Sombras com blur alto (três `BoxShadow`) e clips | Uma sombra só / `elevation: 1`, e `RepaintBoundary` para a parte que repinta |

`MonitorDeQuadros.diagnostico` devolve `🟢 Raster: sombras, Opacity, clips ou imagem grande`. Medido em profile: `p99Ui` ~4,1 ms antes e depois (não muda); `p99Raster` ~38 ms antes e ~8 ms depois de remover o `Opacity`.

<a id="m13-e07"></a>
## M13-E07
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: <Widget>[
        Semantics(
          label: 'Matéria favorita',
          child: Icon(Icons.star, color: cores.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          // Altura MÍNIMA, não fixa: com TextScaler 2.0 uma altura fixa corta o texto.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Cálculo I', style: Theme.of(context).textTheme.titleMedium),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      '$minutos minutos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cores.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Excluir sessão de Cálculo I',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: _excluir,
        ),
        ExcludeSemantics(
          child: Icon(Icons.auto_stories_outlined,
              size: 40, color: cores.surfaceContainerHighest),
        ),
      ],
    ),
  ),
)
```
Sem `tester.ensureSemantics()` a árvore de semântica nem é construída e as quatro diretrizes passam à toa.

<a id="m13-e08"></a>
## M13-E08
```dart
static const Set<String> _colunasOrdenaveis = <String>{
  'nome_ordenacao', 'minutos', 'criada_em',
};

Future<List<Materia>> buscar(String termo) async {
  final List<Map<String, Object?>> linhas = await _db.query(
    'materias',
    where: 'nome_ordenacao LIKE ?',
    whereArgs: <Object?>['%${_paraOrdenacao(termo)}%'], // o % é VALOR, não SQL
    orderBy: 'nome_ordenacao ASC',
    limit: 100,
  );
  return linhas.map(Materia.doMapa).toList();
}

Future<List<Materia>> listar({
  String ordenarPor = 'nome_ordenacao',
  bool crescente = true,
}) async {
  // Nome de coluna não pode virar `?`; a lista fixa é a única defesa possível.
  if (!_colunasOrdenaveis.contains(ordenarPor)) {
    throw ArgumentError.value(ordenarPor, 'ordenarPor', 'Coluna não permitida');
  }
  final List<Map<String, Object?>> linhas = await _db.query(
    'materias',
    orderBy: '$ordenarPor ${crescente ? 'ASC' : 'DESC'}',
  );
  return linhas.map(Materia.doMapa).toList();
}
```
O defeito era interpolar o termo na string SQL: o `?` não é só segurança, é correção — `D'Ávila` fechava a aspa e quebrava a query mesmo sem má intenção.

<a id="m13-e09"></a>
## M13-E09
Previsão certa: **nenhum widget novo passa a reconstruir a cada segundo por causa do `const`**. `CabecalhoDaSemana` só reconstruiria se o pai reconstruísse, e o pai não reconstrói — o `ValueNotifier` só suja a subárvore do `builder`. O que muda é tirar o `child:`: o `Icon(Icons.timer_outlined)` sai de fora e passa a ser recriado a cada tique. O `const` do cabeçalho volta a pagar assim que você troca o cronômetro por `setState`.

<a id="m13-e10"></a>
## M13-E10
Sem a trava, uma rolagem rápida dispara `carregarMais()` ~4 vezes seguidas: `_buscar(1)` é chamada 4 vezes e a lista fica com 60 itens duplicados (3 repetições de 20); passado o item 137, cada rolagem chama `_buscar` de novo e recebe lista vazia, para sempre.

- `atual.carregandoMais` → mata a duplicação: enquanto uma busca está no ar, as outras chamadas voltam na porta.
- `atual.acabou` → mata a busca infinita depois do 137.
- `atual == null` → protege o primeiro quadro, quando o estado ainda é `AsyncLoading` e não há página para continuar.

<a id="m13-e11"></a>
## M13-E11
Criar isolate custa 50–200 ms de criação mais a cópia da mensagem, contra um orçamento de 16,67 ms por quadro — então ele só compensa quando o trabalho síncrono passa bem desses 16 ms.
Baixar o histórico da API é **espera**, não CPU: a thread de UI já fica livre durante o `await` (medi 380 ms de rede com 0,4 ms de UI ocupada). Isolate aqui só acrescenta 90 ms de criação e zero ganho.
Resumir 800 sessões levou 2,1 ms medidos com `Stopwatch` no meu Redmi — cabe no quadro. Jogar num isolate transformaria 2 ms em ~95 ms de latência percebida.
Copiar 200 mil itens para dentro do isolate: a lista é **copiada** na passagem da mensagem; medi 140 ms só de cópia, contra 60 ms de cálculo. O isolate piora porque o transporte custa mais que o trabalho.
Regra: meça primeiro; abaixo de ~16 ms de CPU, isolate é despesa.

<a id="m13-e12"></a>
## M13-E12
```dart
// 1. Cor do papel do ColorScheme, não hardcoded: contraste garantido nos dois temas.
Text('45 min · hoje',
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: cores.onSurfaceVariant,
        ));

// 2. GestureDetector + Icon(24) → IconButton com alvo de 48 dp e rótulo.
IconButton(
  icon: const Icon(Icons.delete_outline),
  tooltip: 'Excluir sessão de Cálculo I',
  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  onPressed: _excluir,
);

// 3. SizedBox(height: 48) → ConstrainedBox: mínimo, para a fonte grande caber.
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 48),
  child: Text(materia.nome),
);

// Prova:
debugPrint(Contraste.descrever(cores.onSurfaceVariant, cores.surface)); // AA
debugPrint(Contraste.descrever(const Color(0xFFAAAAAA), cores.surface)); // 2.32:1 — REPROVADO
```
O que o teste automático **não** pega: rótulo errado ou sem sentido (um `tooltip: 'botão'` passa em `labeledTapTargetGuideline`), ordem de leitura confusa e anúncios que faltam. Isso só aparece ligando o TalkBack/VoiceOver e navegando de olho fechado.

<a id="m13-e13"></a>
## M13-E13
| Dado | Onde mora | Sensível? |
|---|---|---|
| Token de acesso/renovação | `flutter_secure_storage` (Keystore/Keychain) | Sim — dá acesso à conta |
| Sessões de estudo | sqflite, em `databases/foco.db` | Baixo, mas é hábito pessoal |
| Matérias | sqflite | Não |
| `apiUrl`, `clientId` | `ConfigApp`, via `--dart-define-from-file` | Não — configuração pública, nenhum segredo real |

1. **Celular destravado na mão de outra pessoa** (mais provável) → `CofreToken.limpar()` no "Sair", e nada de sessão eterna.
2. **Token no `adb logcat`** → nunca registrar o valor do token; logar só a expiração.
3. **Banco copiado do backup** → `allowBackup=false` e `first_unlock_this_device` no Keychain, para o token não viajar no backup.
4. **APK extraído e lido** (menos provável, mas garantido se alguém tentar) → `--obfuscate`, e segredo de verdade só no servidor.

<a id="m13-e14"></a>
## M13-E14
```powershell
param([ValidateSet('dev','prod')][string]$Ambiente = 'prod')
$ErrorActionPreference = 'Stop'

$linha = Select-String -Path pubspec.yaml -Pattern '^version:\s*(.+)$'
if (-not $linha) { throw 'Não achei a versão no pubspec.yaml' }
$versao = $linha.Matches[0].Groups[1].Value.Trim()

flutter analyze; if ($LASTEXITCODE -ne 0) { throw 'flutter analyze falhou' }
flutter test;    if ($LASTEXITCODE -ne 0) { throw 'Testes falharam' }

$simbolos = "simbolos/$versao"
New-Item -ItemType Directory -Force -Path $simbolos | Out-Null

& flutter build apk --release "--dart-define-from-file=config/$Ambiente.json" `
  --obfuscate "--split-debug-info=$simbolos"
if ($LASTEXITCODE -ne 0) { throw 'Build falhou' }

# O portão que importa: build sem símbolos = crashes ilegíveis PARA SEMPRE.
$gerados = Get-ChildItem $simbolos -Filter '*.symbols' -ErrorAction SilentlyContinue
if (-not $gerados) { throw 'NENHUM símbolo foi gerado!' }
```
```powershell
adb logcat -c; adb shell am start -n br.com.estudos.foco/.MainActivity
adb logcat -d > crash.txt
flutter symbolize -i crash.txt -d simbolos/1.0.0/app.android-arm64.symbols
```
Com o `.symbols` da 1.0.0 o `RangeError` volta com nome de arquivo e linha; com o da 1.0.1 sai lixo ou `Error: symbols file not found` — os símbolos são únicos por build. Medido: APK 21,4 MB, e a maior fatia do `--analyze-size` foram os assets de imagem (6,1 MB), não o código Dart.
