# Gabarito — Módulo 07: Navegação e formulários

> Compare depois de resolver os [exercícios](../exercicios/07-navegacao-e-formularios.md).

<a id="m07-e01"></a>
## M07-E01
```dart
void _abrir(BuildContext context, String nome, Widget tela) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: nome), builder: (_) => tela));

// Lista → Detalhe → Estatísticas → Resumo: cada tela chama _abrir com a seguinte.
FilledButton(
  onPressed: () => _abrir(context, '/materia/detalhe', const DetalheMateriaScreen()),
  child: const Text('Cálculo I'),
);

// Em ResumoSessaoScreen:
FilledButton(
  onPressed: () => Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst),
  child: const Text('Concluir'),
);
```
`popUntil` repete `pop` até o predicado casar: três rotas saem num toque, e o observador imprime três `POP`.

<a id="m07-e02"></a>
## M07-E02
Pilha final, de baixo para cima: **raiz, A, C, D** — `pushReplacement(C)` trocou B por C no mesmo nível, sem empilhar. `Navigator.canPop` é `true` em D e `false` na raiz. `pop` desempilha sem perguntar: na primeira rota esvazia a pilha e sobra tela preta. `maybePop` consulta `canPop` e os `PopScope` acima antes de agir — na raiz, não faz nada.

<a id="m07-e03"></a>
## M07-E03
```dart
abstract final class Rotas {
  static const String home = '/';
  static const String materiaForm = '/materia/form';
  static const String estatisticas = '/estatisticas';

  static Route<dynamic> gerar(RouteSettings configuracoes) {
    switch (configuracoes.name) {
      case home:
        return MaterialPageRoute<void>(
            settings: configuracoes, builder: (_) => const ListaMateriasScreen());
      case materiaForm:
        return MaterialPageRoute<void>(
            settings: configuracoes,
            fullscreenDialog: true,
            builder: (_) => const MateriaFormScreen());
      case estatisticas:
        return MaterialPageRoute<void>(
            settings: configuracoes, builder: (_) => const EstatisticasScreen());
      default:
        return desconhecida(configuracoes);
    }
  }

  static Route<dynamic> desconhecida(RouteSettings configuracoes) =>
      MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => RotaDesconhecidaScreen(nome: configuracoes.name));
}

MaterialApp(
  initialRoute: Rotas.home, // sem `home:` junto, senão o initialRoute é ignorado
  onGenerateRoute: Rotas.gerar,
  onUnknownRoute: Rotas.desconhecida,
  navigatorObservers: <NavigatorObserver>[ObservadorDePilha()],
);
```
Na tela de erro, `pushNamedAndRemoveUntil(Rotas.home, (_) => false)`: o predicado sempre falso limpa a pilha inteira.

<a id="m07-e04"></a>
## M07-E04
```dart
case materiaForm:
  return MaterialPageRoute<void>(
    settings: configuracoes, // <- linha que faltava
    fullscreenDialog: true,
    builder: (_) => const MateriaFormScreen(),
  );
```
O defeito: sem `settings`, a rota nasce anônima — some do log e `ModalRoute.of(context)?.settings.arguments` volta `null`.

<a id="m07-e05"></a>
## M07-E05
```dart
case materiaForm:
  final Object? args = configuracoes.arguments;
  if (args is! MateriaFormArgs) return desconhecida(configuracoes);
  return MaterialPageRoute<Materia>(
      settings: configuracoes,
      fullscreenDialog: true,
      builder: (_) => MateriaFormScreen(args: args));

// DetalheMateriaScreen
Future<void> _editar() async {
  final Materia? salva = await Navigator.of(context).pushNamed<Materia>(
      Rotas.materiaForm, arguments: MateriaFormArgs.editar(_materia));
  if (!context.mounted) return;
  if (salva == null) return; // cancelou: silêncio é a resposta certa
  setState(() => _materia = salva);
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('"${salva.nome}" atualizada')));
}
```
O genérico precisa casar nos três pontos: `pushNamed<Materia>`, `MaterialPageRoute<Materia>` e `pop(materia)`.

<a id="m07-e06"></a>
## M07-E06
Devolve `null` quando: o gesto de borda do iOS ou o botão voltar do Android desempilham; `pop()` é chamado sem argumento; `popUntil` / `pushNamedAndRemoveUntil` removem a rota; ou o genérico do `push` não é o do `MaterialPageRoute`.

Com `MaterialPageRoute<void>`, `pop(materia)` compila porque `pop` recebe `Object?` e `void` aceita qualquer valor por atribuição. O `Future<void>` da rota não tem onde guardar o objeto, então ele é descartado: nada falha em compilação e nada avisa em execução.

<a id="m07-e07"></a>
## M07-E07
```dart
class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;
  static const List<Widget> _telas = <Widget>[
    HojeScreen(), MateriasScreen(), TrilhasScreen(), AjustesScreen()];
  static const List<NavigationDestination> _destinos = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Hoje'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Matérias'),
    NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Trilhas'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes')];

  void _selecionar(int i) => setState(() => _indice = i);

  @override
  Widget build(BuildContext context) {
    final bool telaLarga = MediaQuery.sizeOf(context).width >= 600;
    return Scaffold(
      body: Row(children: <Widget>[
        if (telaLarga) ...<Widget>[
          NavigationRail(
            selectedIndex: _indice,
            onDestinationSelected: _selecionar,
            labelType: NavigationRailLabelType.all,
            destinations: <NavigationRailDestination>[
              for (final NavigationDestination d in _destinos)
                NavigationRailDestination(icon: d.icon, label: Text(d.label)),
            ],
          ),
          const VerticalDivider(width: 1),
        ],
        // IndexedStack mantém as quatro telas montadas: a rolagem sobrevive.
        Expanded(child: IndexedStack(index: _indice, children: _telas)),
      ]),
      bottomNavigationBar: telaLarga
          ? null
          : NavigationBar(
              selectedIndex: _indice,
              onDestinationSelected: _selecionar,
              destinations: _destinos),
    );
  }
}
```
`setState` troca o índice sem tocar no `Navigator`: por isso o observador fica em silêncio ao mudar de aba.

<a id="m07-e08"></a>
## M07-E08
```dart
final GlobalKey<FormState> _chave = GlobalKey<FormState>();
late final Materia? _original = widget.args.original;
late final TextEditingController _nome = TextEditingController(text: _original?.nome ?? '');
late final TextEditingController _meta =
    TextEditingController(text: '${_original?.metaMinutos ?? 60}');
late final TextEditingController _observacao =
    TextEditingController(text: _original?.observacao ?? '');
late final TextEditingController _horario = TextEditingController();
late CategoriaMateria _categoria = _original?.categoria ?? CategoriaMateria.exatas;
late bool _lembrete = _original?.lembreteDiario ?? false;

@override
void dispose() {
  _nome.dispose();
  _meta.dispose();
  _observacao.dispose();
  _horario.dispose();
  super.dispose();
}

// body do Scaffold:
Form(
  key: _chave,
  child: ListView(padding: const EdgeInsets.all(24), children: <Widget>[
    TextFormField(
      controller: _nome,
      maxLength: 40,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(labelText: 'Nome da matéria'),
    ),
    DropdownButtonFormField<CategoriaMateria>(
      initialValue: _categoria,
      decoration: const InputDecoration(labelText: 'Categoria'),
      items: <DropdownMenuItem<CategoriaMateria>>[
        for (final CategoriaMateria c in CategoriaMateria.values)
          DropdownMenuItem<CategoriaMateria>(value: c, child: Text(c.rotulo)),
      ],
      onChanged: (CategoriaMateria? v) {
        if (v != null) setState(() => _categoria = v);
      },
    ),
    TextFormField(
      controller: _meta,
      keyboardType: TextInputType.number,
      // keyboardType sugere o teclado; o formatter garante o conteúdo, inclusive ao colar.
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: const InputDecoration(labelText: 'Meta diária', suffixText: 'minutos'),
    ),
    TextFormField(
      controller: _observacao,
      keyboardType: TextInputType.multiline,
      minLines: 3,
      maxLines: null,
      decoration: const InputDecoration(
          labelText: 'Observações (opcional)', alignLabelWithHint: true),
    ),
    SwitchListTile(
      title: const Text('Lembrete diário'),
      value: _lembrete,
      onChanged: (bool v) => setState(() => _lembrete = v),
    ),
    if (_lembrete)
      TextFormField(
        controller: _horario,
        decoration: const InputDecoration(
            labelText: 'Horário do lembrete', hintText: '19:30'),
      ),
  ]),
);
```
`maxLines: null` sem `minLines: 3` começaria com uma linha só; e `controller:` junto de `initialValue:` lança exceção.

<a id="m07-e09"></a>
## M07-E09
```dart
/// Getter, nunca campo: precisa ser recalculado a cada rebuild.
bool get _temAlteracoes =>
    _nome.text.trim() != (_original?.nome ?? '') ||
    _meta.text != '${_original?.metaMinutos ?? 60}' ||
    _observacao.text.trim() != (_original?.observacao ?? '') ||
    _lembrete != (_original?.lembreteDiario ?? false);

Future<bool> _confirmarDescarte() async {
  final bool? r = await showDialog<bool>(
    context: context,
    builder: (BuildContext c) => AlertDialog(
      title: const Text('Descartar alterações?'),
      content: const Text('O que foi preenchido não será salvo.'),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Continuar editando')),
        FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Descartar')),
      ],
    ),
  );
  return r ?? false;
}

@override
Widget build(BuildContext context) => PopScope(
      canPop: !_temAlteracoes,
      onPopInvokedWithResult: (bool saiu, Object? resultado) async {
        if (saiu) return;
        final bool descartar = await _confirmarDescarte();
        if (!context.mounted) return;
        if (descartar) Navigator.of(context).pop();
      },
      child: Scaffold(/* … */),
    );
```
`onPopInvokedWithResult` roda **depois** da tentativa de sair: por isso `canPop` já precisa estar correto quando o gesto começa.

<a id="m07-e10"></a>
## M07-E10
```dart
// ANTES (bug): late final bool _sujo = _nome.text.isNotEmpty;
bool get _sujo => _nome.text.trim().isNotEmpty;

@override
void initState() {
  super.initState();
  _nome.addListener(_aoMudar);
}

void _aoMudar() => setState(() {});

@override
void dispose() {
  _nome..removeListener(_aoMudar)..dispose();
  super.dispose();
}
```
O defeito: `late final` avalia uma única vez e congela o valor; o getter recalcula a cada rebuild, e o `addListener` é quem garante o rebuild a cada tecla.

<a id="m07-e11"></a>
## M07-E11
```dart
typedef Validador = String? Function(String?);

abstract final class Validadores {
  static Validador combinar(List<Validador> lista) => (String? valor) {
        for (final Validador validar in lista) {
          final String? erro = validar(valor);
          if (erro != null) return erro; // para no primeiro
        }
        return null;
      };

  static Validador obrigatorio([String msg = 'Campo obrigatório']) =>
      (String? v) => (v ?? '').trim().isEmpty ? msg : null;

  static Validador minimo(int n, [String? msg]) => (String? v) {
        final String t = (v ?? '').trim();
        if (t.isEmpty) return null; // vazio é assunto de `obrigatorio`
        return t.length < n ? (msg ?? 'Use pelo menos $n caracteres') : null;
      };

  static Validador maximo(int n, [String? msg]) => (String? v) =>
      (v ?? '').trim().length > n ? (msg ?? 'Use no máximo $n caracteres') : null;

  static Validador numeroInteiro([String msg = 'Informe um número']) =>
      (String? v) => int.tryParse((v ?? '').trim()) == null ? msg : null;

  static Validador entre(int min, int max, {String? unidade}) => (String? v) {
        final int? n = int.tryParse((v ?? '').trim());
        if (n == null) return null; // "não é número" é assunto de numeroInteiro
        final String sufixo = unidade == null ? '' : ' $unidade';
        return n < min || n > max ? 'Informe um valor entre $min e $max$sufixo' : null;
      };
}

final FocusNode _focoMeta = FocusNode();
final FocusNode _focoObservacao = FocusNode();
// dispose: _focoMeta.dispose(); _focoObservacao.dispose(); antes do super.dispose().

TextFormField(
  controller: _nome,
  textInputAction: TextInputAction.next,
  onFieldSubmitted: (_) => _focoMeta.requestFocus(),
  validator: Validadores.combinar(<Validador>[
    Validadores.obrigatorio('Informe o nome da matéria'),
    Validadores.minimo(2, 'Use pelo menos 2 letras no nome'),
    Validadores.maximo(40),
  ]),
);

TextFormField(
  controller: _meta,
  focusNode: _focoMeta,
  textInputAction: TextInputAction.next,
  onFieldSubmitted: (_) => _focoObservacao.requestFocus(),
  validator: Validadores.combinar(<Validador>[
    Validadores.obrigatorio('Informe a meta diária'),
    Validadores.numeroInteiro('Informe a meta em números inteiros'),
    Validadores.entre(5, 480, unidade: 'minutos'),
  ]),
);

TextFormField(
  controller: _observacao,
  focusNode: _focoObservacao,
  // Multilinha usa `newline`: com `next` o usuário não consegue quebrar linha.
  textInputAction: TextInputAction.newline,
  minLines: 3,
  maxLines: null,
  validator: Validadores.maximo(200),
);
```

<a id="m07-e12"></a>
## M07-E12
```dart
AutovalidateMode _autovalidar = AutovalidateMode.disabled;

void _salvar() {
  FocusScope.of(context).unfocus(); // o teclado cobriria as mensagens de erro
  if (!_chave.currentState!.validate()) {
    setState(() => _autovalidar = AutovalidateMode.onUserInteraction);
    return;
  }
  Navigator.of(context).pop(_montarMateria());
}

Form(key: _chave, autovalidateMode: _autovalidar, child: /* … */);
```
O defeito: `always` valida já no primeiro `build`, acusando erro em campos que o usuário ainda nem viu.

<a id="m07-e13"></a>
## M07-E13
| Antes | Depois |
|---|---|
| Campo inválido | Informe o nome da matéria |
| Erro | Não foi possível salvar. Tente de novo. |
| Nome inválido | Use pelo menos 2 letras no nome |
| Você digitou errado | Informe a meta em números inteiros |
| Valor fora do intervalo | Informe uma meta entre 5 e 480 minutos |
| Preenchimento obrigatório | Escolha a categoria da matéria |

Cada mensagem cabe numa linha, começa por um verbo que diz o que fazer e não usa "você"; a da meta traz o intervalo de 5 a 480 minutos.

<a id="m07-e14"></a>
## M07-E14
**(a) `NavigationBar`.** São 4 seções de uso constante, e o `Drawer` esconde a hierarquia atrás de um toque extra no canto mais distante do polegar. Consequência: item dentro de `Drawer` recebe muito menos acesso que o mesmo item numa barra visível. Acima de 600 px o `NavigationRail` substitui a barra.

**(b) Controller.** O `PopScope` do E09 compara o valor atual com o original a cada tecla, e `onSaved` só entrega o valor depois de `save()`. Consequência: com `onSaved`, `canPop` ficaria sempre `true` e o formulário perderia o preenchimento em silêncio. O preço é lembrar do `dispose`.

**(c) Dentro do campo.** O erro pertence ao campo "nome" e precisa aparecer na linha errada, junto do texto a corrigir. Um `SnackBar` some em segundos e o usuário fica sem saber o que mudar. Basta guardar `_erroDoServidorNoNome`, devolvê-lo no `validator` e limpá-lo no `onChanged`.

**(d) Marque os opcionais.** Só "Observações" é opcional contra três obrigatórios: uma marcação em vez de três. Consequência: "Observações (opcional)" informa, enquanto um mar de asteriscos vira ruído e deixa de ser lido. Marque sempre o grupo menor.

**(e) Manter Navigator + `onGenerateRoute`.** O Foco é mobile, sem deep link e sem Flutter Web, e o `switch` central já resolve rota desconhecida, argumento tipado e `fullscreenDialog`. O critério de desempate é esse: com deep link ou web, o `go_router` compensa porque a URL acompanha a navegação e o voltar do navegador funciona; sem eles, você adiciona uma dependência e uma API nova a troco de nada.
