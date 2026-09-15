# Gabarito — Módulo 06: Widgets e layouts

> Compare depois de resolver os [exercícios](../exercicios/06-widgets-e-layouts.md).

<a id="m06-e01"></a>
## M06-E01
```dart
class _HomeScreenState extends State<HomeScreen> {
  int _aba = 0;
  static const List<String> _titulos = <String>['Hoje', 'Matérias', 'Trilhas', 'Ajustes'];
  static const List<IconData> _icones = <IconData>[Icons.today_outlined,
      Icons.menu_book_outlined, Icons.route_outlined, Icons.settings_outlined];

  void _mostrar(String texto) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // evita fila de barras em toques rápidos
    ..showSnackBar(SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_titulos[_aba]), actions: <Widget>[
          IconButton(tooltip: 'Buscar', icon: const Icon(Icons.search),
              onPressed: () => _mostrar('Busca chega na aula 9')),
          IconButton(tooltip: 'Estatísticas', icon: const Icon(Icons.insights_outlined),
              onPressed: () => _mostrar('Estatísticas chegam no projeto final')),
        ]),
        drawer: Drawer(child: ListView(children: <Widget>[
          ListTile(
            leading: const Icon(Icons.today_outlined),
            title: const Text('Sessão de estudo'),
            onTap: () => Navigator.of(context).pop(), // feche o menu antes de agir
          ),
        ])),
        body: Center(
            child: Text(_titulos[_aba], style: Theme.of(context).textTheme.titleLarge)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _mostrar('Formulário de matéria chega no Módulo 07'),
          icon: const Icon(Icons.add),
          label: const Text('Nova matéria'),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _aba,
          type: BottomNavigationBarType.fixed,
          onTap: (int i) => setState(() => _aba = i),
          items: <BottomNavigationBarItem>[
            for (int i = 0; i < _titulos.length; i++)
              BottomNavigationBarItem(icon: Icon(_icones[i]), label: _titulos[i]),
          ],
        ),
      );
}
```
Com quatro itens o `BottomNavigationBar` vira `shifting` e esconde os rótulos: `type: BottomNavigationBarType.fixed` é obrigatório.

<a id="m06-e02"></a>
## M06-E02
```dart
final TextTheme tipografia = Theme.of(context).textTheme;
final int restante =
    (materia.metaMinutos - materia.minutosEstudados).clamp(0, materia.metaMinutos);

Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    Text(materia.nome, style: tipografia.titleMedium,
        maxLines: 1, overflow: TextOverflow.ellipsis),
    Text('Meta: ${materia.metaMinutos} min por semana', style: tipografia.bodySmall),
    Text('${materia.minutosEstudados} min', style: tipografia.labelLarge,
        semanticsLabel: '${materia.minutosEstudados} minutos estudados'),
    Text.rich(
      TextSpan(text: 'Faltam ', children: <InlineSpan>[
        TextSpan(text: '$restante min',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      style: tipografia.bodySmall,
    ),
  ],
);
```
`semanticsLabel` troca só o que o leitor de tela fala; `fontSize` solto não acompanharia a fonte do sistema a 200 %.

<a id="m06-e03"></a>
## M06-E03
```dart
class CartaoDestaque extends StatelessWidget {
  const CartaoDestaque({required this.minutosHoje, required this.metaMinutos,
      required this.materiaAtual, super.key});

  final int minutosHoje;
  final int metaMinutos;
  final String materiaAtual;

  @override
  Widget build(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;
    final ColorScheme cores = Theme.of(context).colorScheme;
    final int restante = (metaMinutos - minutosHoje).clamp(0, metaMinutos);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: cores.outlineVariant),
        // Sombra tirada do tema: nenhum 0xFF... neste arquivo.
        boxShadow: <BoxShadow>[BoxShadow(color: cores.shadow.withValues(alpha: 0.08),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Bom estudo!', style: tipografia.titleMedium),
        const SizedBox(height: 4), // espaço puro: SizedBox, nunca Container vazio
        Text('$minutosHoje min', style: tipografia.displaySmall?.copyWith(
            fontWeight: FontWeight.w700, color: cores.primary)),
        const SizedBox(height: 8),
        Text('Faltam $restante min para bater a meta.', style: tipografia.bodyMedium),
        const SizedBox(height: 20),
        Text(materiaAtual, style: tipografia.bodyLarge,
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
```
`Container` só aqui, porque há decoração; se fosse apenas recuo, `Padding` bastaria.

<a id="m06-e04"></a>
## M06-E04
```dart
Row(children: <Widget>[
  Container(
    width: 44, height: 44, alignment: Alignment.center,
    decoration: BoxDecoration(color: cores.primaryContainer, shape: BoxShape.circle),
    child: Icon(materia.icone, size: 22, color: cores.onPrimaryContainer),
  ),
  const SizedBox(width: 12),
  // Único filho elástico: recebe o que sobrou, em restrição APERTADA.
  // Dentro dele vai a Column do E02, com maxLines: 1 e ellipsis no nome.
  Expanded(child: _textos(context, materia)),
  const SizedBox(width: 12),
  Text('${materia.minutosEstudados} min', style: tipografia.labelLarge),
]);
```
O defeito: os três filhos pediam a largura natural e a soma passava da tela — `Expanded` obriga o bloco do meio a caber no que sobrou, e o `ellipsis` corta o nome longo.

<a id="m06-e05"></a>
## M06-E05
```dart
Container(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  clipBehavior: Clip.antiAlias, // corta no MESMO lugar onde está o borderRadius
  decoration: BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(20)),
    gradient: LinearGradient(
      colors: <Color>[cores.primaryContainer, cores.secondaryContainer],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
  ),
  child: Stack(children: <Widget>[
    // Fundo: decorativo, sangra para fora do cartão e é invisível ao toque.
    Positioned(right: -24, bottom: -24,
      child: IgnorePointer(child: Icon(Icons.timer_outlined, size: 160,
          color: cores.onPrimaryContainer.withValues(alpha: 0.08)))),
    // Frente: os textos, com o padding que saiu do Container.
    Padding(padding: const EdgeInsets.all(20), child: _conteudo(context)),
  ]),
);
```
O `clipBehavior` vai no `Container` que tem a borda, não no `Stack`: é o `decoration` que define a forma do corte.

<a id="m06-e06"></a>
## M06-E06
**(a)** Pinta a tela inteira: o `body` do `Scaffold` desce restrição **apertada**, e um `Container` sem filho e sem tamanho assume o maior tamanho permitido — constraints descem, tamanhos sobem.

**(b)** Vira um retângulo do tamanho do `Text`: o `Center` afrouxa a restrição (mínimo zero), o `Container` passa a se dimensionar pelo filho e o pai é quem o posiciona no meio.

**(c)** Fica com 300 px: `ConstrainedBox` só aperta **dentro** do que o pai permitiu, e a restrição que desce é aplicada por cima.

**(d)** Pinta na ordem da lista: o `Positioned(top: 0)` é o primeiro, logo o mais ao fundo, e o último filho solto cobre todos. Só os não posicionados definem o tamanho do `Stack`, e o `Align`, com restrição frouxa, estica até o máximo — de novo, o pai posiciona.

```dart
// Container(margin:, padding:, alignment:, width:, height:, decoration:, child:)
// é atalho para esta pilha, de fora para dentro:
Padding(                                                    // margin
  padding: margem,
  child: ConstrainedBox(                                    // width + height
    constraints: BoxConstraints.tightFor(width: largura, height: altura),
    child: DecoratedBox(                                    // decoration
      decoration: decoracao,
      child: Padding(                                       // padding
        padding: recheio,
        child: Align(alignment: alinhamento, child: filho), // alignment
      ),
    ),
  ),
);
```

<a id="m06-e07"></a>
## M06-E07
```dart
// lib/core/tema/tema_app.dart
abstract final class TemaApp {
  /// Semente própria do Foco, diferente da usada na aula.
  static const Color semente = Color(0xFF0F766E);

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get escuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final ColorScheme cores =
        ColorScheme.fromSeed(seedColor: semente, brightness: brilho);
    return ThemeData(
      colorScheme: cores,
      appBarTheme: AppBarTheme(backgroundColor: cores.surface,
          foregroundColor: cores.onSurface, elevation: 0, centerTitle: false),
      cardTheme: CardThemeData(elevation: 0, color: cores.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }
}

// lib/main.dart — o estado do tema mora ACIMA do MaterialApp.
ThemeMode _modo = ThemeMode.system;

void _ciclar() => setState(() => _modo = switch (_modo) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    });

MaterialApp(theme: TemaApp.claro, darkTheme: TemaApp.escuro, themeMode: _modo,
    home: HomeScreen(modoAtual: _modo, onTrocarTema: _ciclar));

// Na AppBar da HomeScreen (modoAtual e onTrocarTema chegam pelo construtor):
IconButton(tooltip: 'Trocar tema', onPressed: onTrocarTema, icon: Icon(
    switch (modoAtual) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    }));
```
`themeMode` só escolhe entre `theme` e `darkTheme`: quem gera a paleta escura é `ColorScheme.fromSeed(brightness: Brightness.dark)` com a **mesma** semente.

<a id="m06-e08"></a>
## M06-E08
```dart
List<Materia> _materias = List<Materia>.generate(20, (int i) => Materia(
    id: 'materia-$i', nome: 'Matéria ${i + 1}',
    minutosEstudados: (i * 17) % 130, metaMinutos: 60 + (i % 4) * 30));
bool _emGrade = false;

Future<void> _atualizar() async {
  await Future<void>.delayed(const Duration(seconds: 1));
  if (!mounted) return;
  setState(() => _materias = _materias
      .map((Materia m) => m.copyWith(minutosEstudados: m.minutosEstudados + 5))
      .toList());
}

void _remover(Materia materia, int posicao) {
  setState(() => _materias = _materias.where((Materia m) => m.id != materia.id).toList());
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('"${materia.nome}" excluída'),
    action: SnackBarAction(label: 'Desfazer', onPressed: () => setState(() {
          final List<Materia> novas = List<Materia>.of(_materias);
          novas.insert(posicao.clamp(0, novas.length), materia); // mesma posição
          _materias = novas;
        })),
  ));
}

// body do Scaffold; o IconButton da AppBar só alterna _emGrade.
RefreshIndicator(onRefresh: _atualizar, child: _emGrade ? _grade() : _lista());

Widget _lista() => ListView.separated(
      itemCount: _materias.length,
      separatorBuilder: (BuildContext c, int i) => const Divider(height: 1, indent: 72),
      itemBuilder: (BuildContext c, int i) => Dismissible(
        key: ValueKey<String>(_materias[i].id), // o id do dado, nunca o índice
        direction: DismissDirection.endToStart,
        background: const _FundoExcluir(),
        confirmDismiss: (DismissDirection d) => Dialogos.confirmar(context,
            titulo: 'Excluir matéria?', mensagem: '"${_materias[i].nome}" sai da lista.',
            rotuloConfirmar: 'Excluir', destrutivo: true),
        onDismissed: (DismissDirection d) => _remover(_materias[i], i),
        child: MateriaTile(materia: _materias[i], onTap: () {}),
      ),
    );

Widget _grade() => GridView.builder(
      itemCount: _materias.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220, mainAxisSpacing: 12, crossAxisSpacing: 12),
      itemBuilder: (BuildContext c, int i) =>
          CartaoAdaptavel(materia: _materias[i], onTap: () {}),
    );
```
`confirmDismiss` devolvendo `false` cancela o arraste sem remover nada, e `GridView.builder` constrói sob demanda — `GridView.count(children: ...)` montaria os vinte de uma vez.

<a id="m06-e09"></a>
## M06-E09
Com `ValueKey<int>(indice)`, ao excluir o segundo item a linha some e o terceiro desaparece junto — ou o app lança `A dismissed Dismissible widget is still part of the tree`.

A `key` diz **qual `Element`/`State` pertence a qual dado** quando a árvore é reconstruída. O índice descreve posição, não identidade: removido um item, todos os de baixo mudam de índice e as chaves "andam" junto, então o `State` já descartado é reaproveitado pelo dado seguinte. `ValueKey<String>(materia.id)` acompanha o dado, e só o item certo é descartado.

<a id="m06-e10"></a>
## M06-E10
```dart
// ANTES: style: tipografia.titleMedium?.copyWith(color: Colors.black)
Text(materia.nome, style: tipografia.titleMedium?.copyWith(color: cores.onSurface),
    maxLines: 1, overflow: TextOverflow.ellipsis);
```
```yaml
# pubspec.yaml — assets com 2 espaços, DENTRO de flutter:
flutter:
  uses-material-design: true

  assets:
    - assets/imagens/
```
Os defeitos: `Colors.black` é fixo e ignora o `ColorScheme` do tema escuro, e `assets:` na raiz do YAML nunca é lido — corrija, rode `flutter pub get` e reinicie, porque hot reload não empacota asset novo.

<a id="m06-e11"></a>
## M06-E11
```dart
// core/widgets/dialogos.dart
abstract final class Dialogos {
  /// Pergunta sim/não. Devolve false quando o usuário fecha sem escolher.
  static Future<bool> confirmar(BuildContext context, {
    required String titulo,
    required String mensagem,
    String rotuloConfirmar = 'Confirmar',
    bool destrutivo = false,
  }) async {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final bool? resposta = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: <Widget>[
          // Ênfase mínima na saída sem consequência, máxima na ação.
          TextButton(onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
            style: destrutivo
                ? FilledButton.styleFrom(
                    backgroundColor: cores.error, foregroundColor: cores.onError)
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(rotuloConfirmar),
          ),
        ],
      ),
    );
    return resposta ?? false;
  }

  /// Devolve null se o usuário desistir.
  static Future<int?> pedirMinutos(BuildContext context, String materia) =>
      showDialog<int>(
        context: context,
        builder: (BuildContext ctx) => SimpleDialog(
          title: Text('Registrar sessão de $materia'),
          children: <Widget>[
            for (final int minutos in <int>[15, 25, 50, 90])
              SimpleDialogOption(
                onPressed: () => Navigator.of(ctx).pop(minutos),
                child: Padding( // 12 + 12 garante o alvo de toque de 48 px
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('$minutos minutos')),
              ),
          ],
        ),
      );
}

// MateriasTab — onTap registra minutos, onLongPress abre a folha de ações.
void _trocar(Materia nova) => setState(() =>
    _materias = _materias.map((Materia m) => m.id == nova.id ? nova : m).toList());

Future<void> _registrar(Materia materia) async {
  final int? minutos = await Dialogos.pedirMinutos(context, materia.nome);
  if (!mounted || minutos == null) return;
  _trocar(materia.copyWith(minutosEstudados: materia.minutosEstudados + minutos));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('+$minutos min em ${materia.nome}'),
    // `materia` ainda guarda o valor de antes: desfazer é só devolvê-lo.
    action: SnackBarAction(label: 'Desfazer', onPressed: () => _trocar(materia)),
  ));
}

Future<void> _acoes(Materia materia) async {
  final AcaoMateria? acao = await mostrarFolhaAcoes(context, materia);
  if (!mounted || acao != AcaoMateria.excluir) return;
  final int posicao = _materias.indexOf(materia);
  final bool confirmou = await Dialogos.confirmar(context,
      titulo: 'Excluir matéria?',
      mensagem: '"${materia.nome}" e o progresso dela serão removidos.',
      rotuloConfirmar: 'Excluir', destrutivo: true);
  if (!mounted || !confirmou) return;
  _remover(materia, posicao);
}
```
`resposta ?? false` é o que salva o dado: voltar pelo botão do sistema devolve `null`, e tratar `null` como "sim" excluiria sem confirmação.

<a id="m06-e12"></a>
## M06-E12
```dart
// (1) ANTES: Container(color: Colors.white, child: InkWell(onTap: ...))
Ink(
  decoration:
      BoxDecoration(color: cores.surface, borderRadius: BorderRadius.circular(12)),
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12), // a onda respeita o mesmo raio
    child: Padding(padding: const EdgeInsets.all(16), child: conteudo),
  ),
);

// (2) Corpo rolável e FAB que sai do caminho do teclado.
final bool tecladoAberto = MediaQuery.viewInsetsOf(context).bottom > 0;

Scaffold(
  resizeToAvoidBottomInset: true,
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: <Widget>[
        const CartaoDestaque(minutosHoje: 95, metaMinutos: 120, materiaAtual: 'Dart'),
        TextField(controller: _observacao,
            decoration: const InputDecoration(labelText: 'Como foi a sessão?')),
      ]),
    ),
  ),
  floatingActionButton: tecladoAberto
      ? null
      : FloatingActionButton(onPressed: _salvar, child: const Icon(Icons.check)),
);
```
A onda do `InkWell` é pintada no `Material` mais próximo: um `Container(color:)` acima dela pinta por cima e apaga o efeito.

<a id="m06-e13"></a>
## M06-E13
**(a) `FilledButton` + `TextButton`.** Hierarquia visual é informação: no `Dialogos.confirmar`, "Excluir" é a ação com consequência e recebe o preenchimento sólido, vermelho quando `destrutivo`; "Cancelar" é saída sem custo e fica em ênfase mínima. Dois `FilledButton` empatam o peso, obrigam a ler os dois rótulos e aumentam a chance de tocar em excluir por engano.

**(b) `MediaQuery.sizeOf` decide sobre a tela; `LayoutBuilder` decide sobre a caixa.** No `EsqueletoApp` a pergunta é "cabe um trilho lateral nesta janela?" — é tela. No `CartaoAdaptavel`, o mesmo cartão aparece numa célula de 160 px da grade e num painel de 500 px: quem responde é o `LayoutBuilder`, porque o espaço recebido não tem relação com a largura da janela.

**(c) Quando já se sabe o formato do resultado.** Na `MateriasTab`, o `EsqueletoLista` mostra blocos no formato do `MateriaTile` e antecipa "vem uma lista de matérias", sem o salto de layout do spinner para o conteúdo. `CircularProgressIndicator.adaptive` segue melhor para espera curta dentro de um botão ou diálogo, onde não há estrutura a antecipar.

<a id="m06-e14"></a>
## M06-E14
```dart
// core/estado/estado_tela.dart
sealed class EstadoTela<T> { const EstadoTela(); }
final class TelaCarregando<T> extends EstadoTela<T> { const TelaCarregando(); }
final class TelaSucesso<T> extends EstadoTela<T> {
  const TelaSucesso(this.dados, {this.recarregando = false});
  final T dados; final bool recarregando;
}
final class TelaVazia<T> extends EstadoTela<T> {
  const TelaVazia({this.porFiltro = false});
  final bool porFiltro;
}
final class TelaFalha<T> extends EstadoTela<T> {
  const TelaFalha(this.mensagem, {this.semConexao = false});
  final String mensagem; final bool semConexao;
}

// EsqueletoApp: o `corpo` é SEMPRE o mesmo widget — muda só o invólucro.
LayoutBuilder(builder: (BuildContext context, BoxConstraints restricoes) {
  final TamanhoTela tamanho = TamanhoTela.de(restricoes.maxWidth);
  if (tamanho.ehCompacto) {
    return Scaffold(body: corpo, bottomNavigationBar: NavigationBar(
      selectedIndex: indiceSelecionado, onDestinationSelected: onSelecionar,
      destinations: <Widget>[
        for (final DestinoApp d in destinos)
          NavigationDestination(icon: Icon(d.icone), label: d.rotulo),
      ]));
  }
  return Scaffold(body: Row(children: <Widget>[
    NavigationRail(
      selectedIndex: indiceSelecionado, onDestinationSelected: onSelecionar,
      extended: tamanho.temPainelLateral,
      destinations: <NavigationRailDestination>[
        for (final DestinoApp d in destinos)
          NavigationRailDestination(icon: Icon(d.icone), label: Text(d.rotulo)),
      ]),
    const VerticalDivider(width: 1),
    Expanded(flex: 2, child: corpo),
    // O painel de detalhe só existe na faixa mais larga.
    if (tamanho.temPainelLateral && painelLateral != null)
      Expanded(flex: 3, child: painelLateral!),
  ]));
});

// MateriasTab: um campo só, resolvido por switch exaustivo.
EstadoTela<List<Materia>> _estado = const TelaCarregando<List<Materia>>();

Column(children: <Widget>[
  FiltrosMaterias(filtros: _filtros, selecionados: _selecionados,
      onAlternar: _alternarFiltro), // Wrap de FilterChip: nunca estoura
  if (_estado case TelaSucesso<List<Materia>>(recarregando: true))
    const LinearProgressIndicator(),
  // Expanded dá altura FINITA para a lista dentro da Column.
  Expanded(child: switch (_estado) {
    TelaCarregando<List<Materia>>() => const EsqueletoLista(linhas: 5),
    TelaFalha<List<Materia>>(mensagem: final String msg, semConexao: final bool off) =>
      EstadoErro(titulo: off ? 'Sem conexão' : 'Algo deu errado',
          mensagem: msg, onTentarDeNovo: _buscar),
    TelaVazia<List<Materia>>(porFiltro: true) =>
      EstadoVazio.semResultado(aoLimpar: _limparFiltros),
    TelaVazia<List<Materia>>() => EstadoVazio.inicial(oQue: 'matéria',
        aoCriar: _adicionar, rotuloCriar: 'Adicionar matéria'),
    TelaSucesso<List<Materia>>(dados: final List<Materia> lista) => ListView.builder(
        itemCount: lista.length,
        itemBuilder: (BuildContext c, int i) =>
            MateriaTile(materia: lista[i], onTap: () {})),
  }),
]);
```
`sealed` só garante exaustividade enquanto não houver `default`: é a ausência dele que transforma um estado esquecido em erro de compilação.

---

[Exercícios](../exercicios/06-widgets-e-layouts.md) · [Módulo](../modulos/06-widgets-e-layouts/README.md)
