# Aula 4 — Abas e organização

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Distinguir os **três níveis de navegação** de um app: entre seções (abas), dentro de uma seção
  (pilha) e dentro de uma tela (`TabBar`).
- Montar a navegação principal com **`NavigationBar`** do Material 3 — e saber por que
  `BottomNavigationBar` está obsoleto.
- Usar **`IndexedStack`** para preservar o estado de cada aba, e saber quando **não** usá-lo.
- Montar abas internas com **`TabBar` + `TabBarView`** e `DefaultTabController`.
- Decidir entre **`Drawer`**, `NavigationBar` e `NavigationRail` — e por que o `Drawer` quase nunca
  é a resposta em um app moderno.
- Organizar o projeto em **pastas por feature**, entendendo por que isso importa mais do que
  parece.

## ✅ Pré-requisitos

- [Aula 1 — Navigator: a pilha](01-navigator-a-pilha.md) e
  [Aula 2 — Rotas nomeadas](02-rotas-nomeadas.md).
- [Aula 3 — Argumentos e resultados](03-argumentos-e-resultados.md) — as telas continuam de lá.
- [Módulo 06, aula 11 — Responsividade](../06-widgets-e-layouts/11-responsividade.md) — a troca
  entre `NavigationBar` e `NavigationRail` foi montada lá; aqui ela entra no projeto de verdade.
- [Módulo 05, aula 6 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md)
  — para entender o que "preservar o estado da aba" significa de verdade.
- O projeto `foco_navegacao` rodando.

---

## 📖 Conceito

### Os três níveis de navegação

Confundir esses três é a origem de metade dos apps com navegação estranha.

| Nível | Pergunta que responde | Widget | O botão voltar age? |
|---|---|---|---|
| **1. Entre seções** | "Em que parte do app eu estou?" | `NavigationBar` / `NavigationRail` | ❌ Não. Trocar de aba **não** empilha |
| **2. Dentro de uma seção** | "Estou vendo a lista ou o detalhe?" | `Navigator` (push/pop) | ✅ Sim |
| **3. Dentro de uma tela** | "Que recorte deste mesmo conteúdo?" | `TabBar` + `TabBarView` | ❌ Não |

Um exemplo concreto, no app que você está construindo:

```text
┌─ NavigationBar (nível 1) ───────────────────────────────┐
│  Hoje  │  Matérias  │  Trilhas  │  Ajustes              │
└─────────┬───────────────────────────────────────────────┘
          │
          ├─ ListaMateriasScreen         (nível 2: base da pilha)
          │    └─ DetalheMateriaScreen   (nível 2: empilhada)
          │         └─ MateriaFormScreen (nível 2: empilhada)
          │
          └─ dentro do Detalhe:
               ┌─ TabBar (nível 3) ──────────────────────┐
               │  Resumo  │  Sessões  │  Anotações       │
               └─────────────────────────────────────────┘
```

> ⚠️ **A regra que mais se quebra:** trocar de aba **nunca** deve empilhar uma rota. Se o usuário
> vai de "Hoje" para "Matérias" e aperta voltar, ele espera **sair do app** (ou voltar para "Hoje",
> se você implementar isso de propósito) — não desempilhar cinco telas.

### `NavigationBar`: a barra do Material 3

```dart
Scaffold(
  body: _telaAtual,
  bottomNavigationBar: NavigationBar(
    selectedIndex: _indice,
    onDestinationSelected: (int i) => setState(() => _indice = i),
    destinations: const <Widget>[
      NavigationDestination(
        icon: Icon(Icons.today_outlined),
        selectedIcon: Icon(Icons.today),
        label: 'Hoje',
      ),
      NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book),
        label: 'Matérias',
      ),
    ],
  ),
)
```

| | `BottomNavigationBar` (antigo) | `NavigationBar` (Material 3) |
|---|---|---|
| Status | Ainda funciona, mas é Material 2 | **Atual** |
| Ícone selecionado diferente | Não tem | `selectedIcon` |
| Comportamento com 4+ itens | Precisa de `type: fixed` ou some o rótulo | Correto por padrão |
| Indicador de seleção | Só a cor | Pílula atrás do ícone |
| Altura | 56 px | 80 px (alvo de toque melhor) |

**Regras de quantidade:**

- **3 a 5 destinos.** Menos de 3 não justifica a barra; mais de 5 não cabe em tela de celular.
- Se você tem 7 seções, o problema **não é** a barra — é a arquitetura de informação do app.
- **Nunca** use rótulos com mais de uma palavra. "Minhas matérias" vira "Matérias".

### `IndexedStack`: preservar o estado das abas

Esta é a decisão técnica central da aula. Compare:

```dart
// ❌ Opção A: o widget da aba é DESTRUÍDO ao trocar
body: switch (_indice) {
  0 => const HojeTab(),
  1 => const MateriasTab(),
  _ => const AjustesTab(),
},
```

```dart
// ✅ Opção B: todas as abas existem; só uma é visível
body: IndexedStack(
  index: _indice,
  children: const <Widget>[HojeTab(), MateriasTab(), AjustesTab()],
),
```

O que muda, na prática:

| | `switch` (Opção A) | `IndexedStack` (Opção B) |
|---|---|---|
| Rolagem da lista ao voltar para a aba | **Perdida** (volta ao topo) | **Preservada** |
| Texto digitado num campo | **Perdido** | **Preservado** |
| `initState` da aba | Roda a **cada** troca | Roda **uma** vez |
| Requisição de rede | Refeita a cada troca | Feita uma vez |
| Memória usada | Só a aba visível | **Todas** as abas |
| Primeira abertura do app | Rápida | Mais lenta (constrói todas) |

**Quando usar `IndexedStack`:** 3 a 5 abas, conteúdo de tamanho normal — a esmagadora maioria dos
apps. É o que o usuário espera: voltar para uma aba e encontrá-la como deixou.

**Quando NÃO usar:** abas com listas gigantes, mapas, vídeos ou câmera. Nesses casos, manter tudo
vivo consome memória demais — e o sistema pode matar o app.

> 💡 `IndexedStack` **constrói** todos os filhos, mas só **pinta** o visível. O custo é de memória
> e de construção inicial, não de desempenho de rolagem.

### O botão voltar com abas

Cenário: o usuário está na aba "Ajustes" e aperta voltar. O que deve acontecer?

| Comportamento | Quando é certo |
|---|---|
| Sair do app | Padrão do Android. Simples e previsível |
| Voltar para a primeira aba | Comum em apps grandes (Instagram, YouTube) |
| Voltar pelo histórico de abas | Confuso — evite |

Para "voltar para a primeira aba", use `PopScope` (assunto detalhado da
[aula 5](05-navegacao-android-x-ios.md)):

```dart
PopScope(
  // Só deixa sair do app quando já estamos na primeira aba.
  canPop: _indice == 0,
  onPopInvokedWithResult: (bool saiu, Object? resultado) {
    if (saiu) return;
    setState(() => _indice = 0);
  },
  child: Scaffold(...),
)
```

### `TabBar` + `TabBarView`: abas dentro de uma tela

Para recortes do **mesmo** conteúdo — não para seções diferentes do app.

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: const Text('Dart'),
      bottom: const TabBar(
        tabs: <Widget>[
          Tab(text: 'Resumo'),
          Tab(text: 'Sessões'),
          Tab(text: 'Anotações'),
        ],
      ),
    ),
    body: const TabBarView(
      children: <Widget>[AbaResumo(), AbaSessoes(), AbaAnotacoes()],
    ),
  ),
)
```

**`DefaultTabController`** cria e gerencia o controlador para você — é a forma simples, e resolve
90% dos casos. Quando você precisa **trocar de aba por código**, ou **reagir** à troca, use um
`TabController` próprio:

```dart
class _MinhaTelaState extends State<MinhaTela>
    with SingleTickerProviderStateMixin {
  late final TabController _abas = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _abas.dispose();   // obrigatório
    super.dispose();
  }
  // … depois: _abas.animateTo(2);
}
```

> ⚠️ `TabController` criado à mão **precisa** de `dispose()`, e a classe precisa do
> `SingleTickerProviderStateMixin` (ou `TickerProviderStateMixin`, se houver mais de uma
> animação). Os mixins vêm do [Módulo 03](../03-dart-intermediario/06-mixins.md).

Diferente do `IndexedStack`, o `TabBarView` **preserva** o estado das abas por padrão — mas só
enquanto elas estão montadas. Para garantir a preservação com muitas abas, use
`AutomaticKeepAliveClientMixin` na aba:

```dart
class _AbaSessoesState extends State<AbaSessoes>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);   // obrigatório com este mixin
    return ListView(...);
  }
}
```

### `Drawer`: por que quase nunca

O `Drawer` (menu lateral que desliza) foi o padrão do Android por anos. Hoje:

| Problema | Consequência |
|---|---|
| **Invisível** | O usuário precisa saber que ele existe para abrir |
| **Longe do polegar** | O ícone fica no canto superior esquerdo — o ponto mais difícil de alcançar |
| **Um toque a mais** | Toda navegação custa: abrir → escolher → fechar |
| **Esconde a hierarquia** | O usuário não sabe onde está |

Pesquisas de uso mostram engajamento muito menor em itens dentro de `Drawer` do que em barras
visíveis. Por isso o Material 3 empurra `NavigationBar` e `NavigationRail`.

**Quando o `Drawer` ainda faz sentido:**

- **Mais de 5 seções** e você não consegue reduzir (apps corporativos, ERPs).
- Itens **raramente usados**: sair da conta, sobre, termos, ajuda.
- **Complementando** a `NavigationBar` — as 4 seções principais na barra, o resto no menu.

**Decisão do curso:** `NavigationBar` (ou `Rail`) para as seções principais; `Drawer` só como
complemento para itens secundários.

### Organização por feature

Duas formas de organizar `lib/`:

```text
❌ Por tipo (layer-first)          ✅ Por feature (feature-first)
lib/                               lib/
├── models/                        ├── core/
│   ├── materia.dart               │   ├── rotas/
│   ├── sessao.dart                │   ├── tema/
│   └── trilha.dart                │   └── widgets/
├── screens/                       └── features/
│   ├── lista_materias.dart            ├── materias/
│   ├── detalhe_materia.dart           │   ├── domain/materia.dart
│   └── form_materia.dart              │   └── presentation/
└── widgets/                           │       ├── materias_tab.dart
    ├── materia_tile.dart              │       ├── detalhe_materia_screen.dart
    └── sessao_tile.dart               │       └── widgets/materia_tile.dart
                                       └── trilhas/
                                           ├── domain/trilha.dart
                                           └── presentation/
```

Por que a segunda ganha:

1. **Tudo de um assunto fica junto.** Mexer em "matérias" é abrir **uma** pasta, não caçar em três.
2. **Apagar uma feature é apagar uma pasta.** Na organização por tipo, restos ficam espalhados.
3. **Escala.** Com 20 telas, a pasta `screens/` vira uma lista de 20 arquivos sem relação entre si.
4. **Trabalho em equipe.** Duas pessoas em features diferentes quase não tocam nos mesmos arquivos.

`core/` guarda o que serve **ao app inteiro**: tema, rotas, widgets genéricos, utilitários. A
pergunta que decide: *"isso faz sentido sem a feature X?"* Se sim, é `core/`.

> 📌 Esta é a mesma organização do projeto final
> ([05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md)) e a que o
> [Módulo 08, aula 9](../08-estado-e-arquitetura/09-arquitetura-feature-first.md) aprofunda com
> camadas de dados.

---

## 💡 Analogia

Pense num shopping center.

- **`NavigationBar`** são os **andares**. Você vê todos listados no elevador, sabe em qual está, e
  ir do 2º ao 3º **não** é "entrar" em lugar nenhum — é mudar de contexto. Apertar "voltar" depois
  de subir um andar não deveria te devolver ao andar anterior; deveria te levar para fora do
  shopping.
- **O `Navigator` (pilha)** são as **lojas dentro do andar**. Você entra na loja, entra no
  provador, sai do provador, sai da loja. Aqui "voltar" faz todo o sentido: é o caminho por onde
  você entrou.
- **`TabBar`** são as **seções dentro de uma loja**: masculino, feminino, infantil. Mesma loja,
  mesmo contexto, só um recorte diferente da mesma coisa.
- **`IndexedStack`** é o shopping **não desmontar** o andar quando você sobe de elevador. Você volta
  ao 2º e as lojas continuam abertas, do jeito que você deixou — em vez de tudo ter sido remontado
  do zero.
- **O `Drawer`** é aquele corredor de serviço com uma porta sem placa. Tem coisa útil lá dentro,
  mas quem não sabe que ele existe nunca entra. Por isso não se coloca a loja principal ali.
- **Organização por feature** é agrupar a loja inteira num ponto: estoque, provador e caixa juntos.
  A alternativa — todos os estoques do shopping num andar, todos os provadores em outro — é
  exatamente o que "pasta de models, pasta de screens" faz.

---

## 🧪 Exemplo mínimo

Este programa mostra, lado a lado, a diferença entre destruir e preservar o estado das abas.

> **Arquivo:** `foco_navegacao/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppAbas());

class AppAbas extends StatelessWidget {
  const AppAbas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const CascaAbas(),
    );
  }
}

class CascaAbas extends StatefulWidget {
  const CascaAbas({super.key});

  @override
  State<CascaAbas> createState() => _CascaAbasState();
}

class _CascaAbasState extends State<CascaAbas> {
  int _indice = 0;

  /// Troque para false e compare o comportamento.
  bool _preservar = true;

  @override
  Widget build(BuildContext context) {
    const List<Widget> abas = <Widget>[
      _AbaContador(nome: 'A', cor: Colors.red),
      _AbaContador(nome: 'B', cor: Colors.green),
      _AbaContador(nome: 'C', cor: Colors.blue),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_preservar ? 'IndexedStack' : 'switch'),
        actions: <Widget>[
          Switch(
            value: _preservar,
            onChanged: (bool v) => setState(() => _preservar = v),
          ),
        ],
      ),

      body: _preservar
          // Todas existem; só uma aparece. O estado sobrevive.
          ? IndexedStack(index: _indice, children: abas)
          // Só a atual existe. Trocar de aba DESTRÓI a anterior.
          : abas[_indice],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (int i) => setState(() => _indice = i),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.looks_one_outlined),
            selectedIcon: Icon(Icons.looks_one),
            label: 'A',
          ),
          NavigationDestination(
            icon: Icon(Icons.looks_two_outlined),
            selectedIcon: Icon(Icons.looks_two),
            label: 'B',
          ),
          NavigationDestination(
            icon: Icon(Icons.looks_3_outlined),
            selectedIcon: Icon(Icons.looks_3),
            label: 'C',
          ),
        ],
      ),
    );
  }
}

class _AbaContador extends StatefulWidget {
  const _AbaContador({required this.nome, required this.cor});

  final String nome;
  final Color cor;

  @override
  State<_AbaContador> createState() => _AbaContadorState();
}

class _AbaContadorState extends State<_AbaContador> {
  int _toques = 0;

  @override
  void initState() {
    super.initState();
    // Observe o console ao trocar de aba nos dois modos.
    debugPrint('initState da aba ${widget.nome}');
  }

  @override
  void dispose() {
    debugPrint('dispose da aba ${widget.nome}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.cor.withValues(alpha: 0.08),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Aba ${widget.nome}',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('$_toques toques',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _toques++),
              child: const Text('Tocar'),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                decoration: InputDecoration(labelText: 'Digite algo e troque de aba'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**O roteiro que ensina a aula inteira:**

1. Com o interruptor **ligado** (`IndexedStack`): toque 5 vezes na aba A, digite algo no campo,
   vá para B e volte. O contador continua em 5, o texto continua lá.
   O console mostra **três `initState`** no começo e **nenhum** depois.
2. Desligue o interruptor (`switch`): repita. Contador zerado, campo vazio.
   O console mostra `dispose` + `initState` **a cada troca**.

---

## 📱 Aplicando no Flutter

Agora o `foco_navegacao` ganha a casca definitiva do app:

- **Quatro seções** na `NavigationBar`: Hoje, Matérias, Trilhas, Ajustes.
- **`IndexedStack`** preservando o estado de cada uma.
- **`NavigationRail`** automaticamente em telas largas (reaproveitando o
  [Módulo 06, aula 11](../06-widgets-e-layouts/11-responsividade.md)).
- **`Drawer`** só com os itens secundários: Estatísticas, Sobre.
- **Abas internas** (`TabBar`) na tela de detalhe de matéria.
- **`PopScope`** fazendo o botão voltar retornar à primeira aba.

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/features/home/presentation/home_screen.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

import 'package:foco_navegacao/core/widgets/menu_lateral.dart';
import 'package:foco_navegacao/features/hoje/presentation/hoje_tab.dart';
import 'package:foco_navegacao/features/materias/presentation/materias_tab.dart';
import 'package:foco_navegacao/features/metas/presentation/ajustes_tab.dart';
import 'package:foco_navegacao/features/trilhas/presentation/trilhas_tab.dart';

/// Uma seção do app.
class _Secao {
  const _Secao({
    required this.rotulo,
    required this.icone,
    required this.iconeSelecionado,
    required this.tela,
  });

  final String rotulo;
  final IconData icone;
  final IconData iconeSelecionado;
  final Widget tela;
}

/// Casca do app: a navegação de PRIMEIRO nível.
///
/// Trocar de seção aqui NÃO empilha rota — é mudança de contexto,
/// não de profundidade.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;

  static const List<_Secao> _secoes = <_Secao>[
    _Secao(
      rotulo: 'Hoje',
      icone: Icons.today_outlined,
      iconeSelecionado: Icons.today,
      tela: HojeTab(),
    ),
    _Secao(
      rotulo: 'Matérias',
      icone: Icons.menu_book_outlined,
      iconeSelecionado: Icons.menu_book,
      tela: MateriasTab(),
    ),
    _Secao(
      rotulo: 'Trilhas',
      icone: Icons.route_outlined,
      iconeSelecionado: Icons.route,
      tela: TrilhasTab(),
    ),
    _Secao(
      rotulo: 'Ajustes',
      icone: Icons.settings_outlined,
      iconeSelecionado: Icons.settings,
      tela: AjustesTab(),
    ),
  ];

  void _selecionar(int i) => setState(() => _indice = i);

  @override
  Widget build(BuildContext context) {
    // Ponto de corte do Material 3. Módulo 06, aula 11.
    final bool telaLarga = MediaQuery.sizeOf(context).width >= 600;

    return PopScope(
      // Só deixa o gesto de voltar sair do app quando já estamos na aba 0.
      canPop: _indice == 0,
      onPopInvokedWithResult: (bool saiu, Object? resultado) {
        if (saiu) return;
        // Não saiu: em vez de sair, volta para a primeira aba.
        _selecionar(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_secoes[_indice].rotulo),
        ),

        // Drawer: SÓ itens secundários. As seções principais estão na barra.
        drawer: const MenuLateral(),

        body: Row(
          children: <Widget>[
            // Em tela larga, o trilho substitui a barra de baixo.
            if (telaLarga) ...<Widget>[
              NavigationRail(
                selectedIndex: _indice,
                onDestinationSelected: _selecionar,
                labelType: NavigationRailLabelType.all,
                destinations: <NavigationRailDestination>[
                  for (final _Secao s in _secoes)
                    NavigationRailDestination(
                      icon: Icon(s.icone),
                      selectedIcon: Icon(s.iconeSelecionado),
                      label: Text(s.rotulo),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
            ],

            Expanded(
              // ── A decisão central da aula ───────────────────────────────
              // IndexedStack mantém TODAS as abas montadas: rolagem, texto
              // digitado e requisições já feitas sobrevivem à troca.
              // Com `_secoes[_indice].tela`, tudo isso seria perdido.
              child: IndexedStack(
                index: _indice,
                children: <Widget>[
                  for (final _Secao s in _secoes) s.tela,
                ],
              ),
            ),
          ],
        ),

        bottomNavigationBar: telaLarga
            ? null
            : NavigationBar(
                selectedIndex: _indice,
                onDestinationSelected: _selecionar,
                destinations: <Widget>[
                  for (final _Secao s in _secoes)
                    NavigationDestination(
                      icon: Icon(s.icone),
                      selectedIcon: Icon(s.iconeSelecionado),
                      label: s.rotulo,
                    ),
                ],
              ),
      ),
    );
  }
}
```

> **Arquivo:** `foco_navegacao/lib/core/widgets/menu_lateral.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'package:foco_navegacao/core/rotas/rotas.dart';

/// Menu lateral com os itens SECUNDÁRIOS do app.
///
/// As quatro seções principais ficam na NavigationBar, visíveis.
/// Aqui entra só o que é usado raramente.
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return NavigationDrawer(
      // O Drawer é uma rota: fechá-lo é um pop.
      onDestinationSelected: (int i) => Navigator.of(context).pop(),
      children: <Widget>[
        DrawerHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.school_outlined, size: 40, color: cores.primary),
              const SizedBox(height: 12),
              Text('Foco', style: Theme.of(context).textTheme.titleLarge),
              Text('Organizador de estudos',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        ListTile(
          leading: const Icon(Icons.bar_chart_outlined),
          title: const Text('Estatísticas'),
          onTap: () {
            // Fecha o menu ANTES de empilhar a rota — senão o menu
            // fica aberto atrás da tela nova.
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(Rotas.estatisticas);
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Sobre'),
          onTap: () {
            Navigator.of(context).pop();
            showAboutDialog(
              context: context,
              applicationName: 'Foco',
              applicationVersion: '0.1.0',
              applicationLegalese: 'Curso Flutter Intensivo',
            );
          },
        ),
      ],
    );
  }
}
```

Agora as abas internas na tela de detalhe:

> **Arquivo:** `foco_navegacao/lib/features/materias/presentation/detalhe_materia_screen.dart`
> (o `build` passa a usar `DefaultTabController`)

```dart
  @override
  Widget build(BuildContext context) {
    final Materia? materia = _materia;

    // TERCEIRO nível de navegação: recortes do MESMO conteúdo.
    // Trocar de aba aqui não empilha rota e não afeta o botão voltar.
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(materia?.nome ?? 'Carregando…'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar matéria',
              onPressed: materia == null ? null : _editar,
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Resumo'),
              Tab(text: 'Sessões'),
              Tab(text: 'Anotações'),
            ],
          ),
        ),
        body: materia == null
            ? const Center(child: CircularProgressIndicator.adaptive())
            : TabBarView(
                children: <Widget>[
                  _AbaResumo(materia: materia, carregando: _carregando),
                  _AbaSessoes(materiaId: materia.id),
                  _AbaAnotacoes(materiaId: materia.id),
                ],
              ),
      ),
    );
  }
```

E uma aba que **preserva** o próprio estado mesmo quando o `TabBarView` a descarta:

```dart
class _AbaSessoes extends StatefulWidget {
  const _AbaSessoes({required this.materiaId});

  final String materiaId;

  @override
  State<_AbaSessoes> createState() => _AbaSessoesState();
}

class _AbaSessoesState extends State<_AbaSessoes>
    // Mantém esta aba viva mesmo fora de vista, preservando a rolagem.
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Obrigatório com AutomaticKeepAliveClientMixin.
    super.build(context);

    return ListView.builder(
      itemCount: 20,
      itemBuilder: (BuildContext context, int i) => ListTile(
        leading: const Icon(Icons.schedule),
        title: Text('Sessão ${i + 1}'),
        subtitle: Text('${25 + i} minutos'),
      ),
    );
  }
}
```

Por fim, a estrutura de pastas final do projeto:

```text
foco_navegacao/lib/
├── main.dart
├── core/                                  ← serve ao app INTEIRO
│   ├── rotas/
│   │   ├── rotas.dart
│   │   └── rota_desconhecida_screen.dart
│   ├── tema/tema_app.dart
│   └── widgets/menu_lateral.dart
└── features/                              ← um assunto por pasta
    ├── home/presentation/home_screen.dart
    ├── hoje/presentation/hoje_tab.dart
    ├── materias/
    │   ├── domain/materia.dart
    │   └── presentation/
    │       ├── materias_tab.dart
    │       ├── detalhe_materia_screen.dart
    │       ├── materia_form_screen.dart
    │       └── widgets/materia_tile.dart
    ├── trilhas/presentation/trilhas_tab.dart
    ├── metas/presentation/ajustes_tab.dart
    └── estatisticas/presentation/estatisticas_screen.dart
```

E o `main.dart` aponta a rota `home` para a nova casca:

```dart
// core/rotas/rotas.dart
case home:
  return MaterialPageRoute<void>(
    settings: configuracoes,
    builder: (_) => const HomeScreen(),   // era ListaMateriasScreen
  );
```

Rode e teste:

```powershell
flutter analyze
flutter run -d chrome
```

1. Role a lista de Matérias até o meio, vá para Trilhas e volte. **A rolagem continua onde estava.**
2. Abra o detalhe de uma matéria e troque entre as três abas internas.
3. Redimensione a janela para mais de 600 px: a barra de baixo vira **trilho lateral**.
4. Vá para a aba Ajustes e aperte voltar: o app volta para **Hoje**, em vez de fechar.
5. Abra o menu lateral e vá para Estatísticas: ela **empilha** (com botão voltar), porque é nível 2.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `class _Secao` privada | Agrupa rótulo, ícones e tela. Sem ela, você manteria três listas paralelas — e um dia elas desalinham. |
| `IndexedStack(index: _indice, children: …)` | **O ponto da aula.** Todas as abas ficam montadas; só a do índice aparece. Rolagem, texto e requisições sobrevivem. |
| `for (final _Secao s in _secoes) s.tela` dentro do `IndexedStack` | Uma lista só alimenta a navegação **e** o conteúdo. Acrescentar seção = acrescentar um item. |
| `selectedIcon:` diferente de `icon:` | Recurso do Material 3: o ícone preenchido marca a seção ativa, além da cor. |
| `PopScope(canPop: _indice == 0, …)` | Quando `canPop` é `false`, o Flutter **não** deixa o pop acontecer e chama `onPopInvokedWithResult` com `saiu == false`. |
| `if (saiu) return;` dentro do callback | Se o pop de fato aconteceu, não há nada a fazer. Só agimos quando ele foi **impedido**. |
| `bottomNavigationBar: telaLarga ? null : NavigationBar(...)` | `null` remove a barra. Sem isso, tela larga teria barra **e** trilho. |
| `NavigationRail` dentro de `Row` + `Expanded` | O trilho ocupa largura fixa; o conteúdo fica com o resto. Módulo 06, aula 11. |
| `Navigator.of(context).pop()` antes de `pushNamed` no `Drawer` | O `Drawer` é uma rota. Sem o `pop`, ele fica aberto atrás da tela nova. |
| `DefaultTabController(length: 3, …)` | Cria e descarta o `TabController` sozinho. Só use um controlador próprio quando precisar trocar de aba por código. |
| `bottom: const TabBar(...)` na `AppBar` | O slot `bottom` da `AppBar` é o lugar canônico da `TabBar` — ela vira parte da barra. |
| `with AutomaticKeepAliveClientMixin` + `wantKeepAlive => true` | Mantém a aba viva fora de vista. Preserva a rolagem da lista de sessões. |
| `super.build(context);` na primeira linha do `build` | **Obrigatório** com esse mixin — ele registra a manutenção do estado. Esquecer causa erro em tempo de execução. |
| `withValues(alpha: 0.08)` | API atual do Flutter para opacidade de cor. Substitui `withOpacity`, que está obsoleto. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Navegação principal | `NavigationBar` na base — padrão | `CupertinoTabBar` na base — padrão |
| Ícones | Material Symbols, versão preenchida quando ativo | SF Symbols, mais finos |
| Botão voltar com abas | Existe (botão/gesto) — **você decide** o que ele faz | Não existe voltar global; o usuário só troca de aba |
| `Drawer` | Aceito, mas em desuso | **Raro** — o iOS praticamente não usa menu lateral |
| Altura da barra | 80 px (Material 3) | 50 px + área segura |
| Abas dentro de tela | `TabBar` deslizável | Geralmente `CupertinoSegmentedControl` |

> 📌 **A diferença que exige decisão:** o `PopScope` desta aula só tem efeito no Android, porque o
> iOS não tem "voltar" global. Isso é ok — o código roda nas duas plataformas e simplesmente não
> faz nada no iPhone. O que **não** é ok é depender do `Drawer` para navegar: em iOS, muitos
> usuários nunca vão descobrir que ele existe.

---

## ⚠️ Erros comuns

### 1. Empilhar rota ao trocar de aba

```dart
onDestinationSelected: (int i) {
  Navigator.of(context).pushNamed(_rotas[i]);   // ❌
},
```

A pilha cresce sem parar. Depois de tocar nas abas 10 vezes, o usuário precisa de 10 "voltar" para
sair do app.

**Correção:** trocar de aba é `setState`, não `push`.

### 2. Usar `switch` quando o usuário espera preservação

```dart
body: switch (_indice) { 0 => const HojeTab(), ... },   // ⚠️
```

O usuário rola uma lista longa, confere outra aba, volta — e está no topo de novo. Parece bug.

**Correção:** `IndexedStack`, salvo quando a memória for problema de verdade.

### 3. `IndexedStack` com abas pesadas

```dart
IndexedStack(children: <Widget>[MapaTab(), CameraTab(), VideoTab()])   // ⚠️
```

Três recursos caros vivos ao mesmo tempo. Em aparelho modesto, o sistema mata o app.

**Correção:** `IndexedStack` para as abas leves e construção sob demanda para as pesadas — ou
`AutomaticKeepAliveClientMixin` seletivo.

### 4. Esquecer o `dispose` do `TabController`

```dart
late final TabController _abas = TabController(length: 3, vsync: this);
// … sem dispose ❌
```

Vazamento de memória, e o analisador nem sempre avisa.

**Correção:** `_abas.dispose()` no `dispose`. Ou use `DefaultTabController`, que não exige nada.

### 5. `TabBar` sem controlador

```text
No TabController for TabBar.
```

**Correção:** envolva em `DefaultTabController(length: n, child: ...)` — e confira se o `length`
bate com o número de `Tab` **e** de filhos do `TabBarView`.

### 6. `length` diferente do número de abas

```dart
DefaultTabController(
  length: 3,
  child: TabBarView(children: <Widget>[A(), B()]),   // ❌ só 2
)
```

```text
Controller's length property (3) does not match the number of children (2)
```

### 7. Esquecer `super.build(context)` com `AutomaticKeepAliveClientMixin`

```dart
@override
Widget build(BuildContext context) {
  return ListView(...);   // ❌ faltou super.build(context)
}
```

**Correção:** `super.build(context);` na primeira linha.

### 8. Não fechar o `Drawer` antes de navegar

```dart
onTap: () => Navigator.of(context).pushNamed(Rotas.estatisticas),   // ❌
```

A tela nova abre e o menu continua aberto **atrás** dela. Ao voltar, o usuário encontra o menu
escancarado.

**Correção:** `Navigator.of(context).pop();` antes do `pushNamed`.

### 9. Mais de 5 destinos na `NavigationBar`

Os rótulos ficam ilegíveis e os alvos de toque, pequenos demais.

**Correção:** reduza para 4 ou 5 seções e mova o resto para dentro delas (ou para o `Drawer`).
Se você não consegue reduzir, o problema é a arquitetura de informação — não o widget.

### 10. `Drawer` como navegação principal

Esconde as seções mais importantes do app atrás de um ícone que muitos usuários nunca tocam.

**Correção:** as seções principais **sempre** visíveis, em `NavigationBar` ou `NavigationRail`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o app, vá para a aba Matérias, role a lista até o fim, vá para Trilhas e volte.
Confirme que a rolagem foi preservada.

**Passo 2.** Troque o `IndexedStack` por `_secoes[_indice].tela`. Repita o passo 1 e descreva a
diferença. Observe o console: quantos `dispose` aparecem?

**Passo 3.** Volte ao `IndexedStack`. Acrescente `debugPrint('initState de ${runtimeType}')` ao
`initState` de cada aba. Rode e conte quantos aparecem **ao abrir o app** e quantos **ao trocar de
aba**. Explique o resultado.

**Passo 4.** Remova o `PopScope`. Vá para Ajustes e aperte voltar. O que acontece? Devolva o
`PopScope` e repita.

**Passo 5.** Mude `canPop: _indice == 0` para `canPop: false`. Tente sair do app. Explique por
escrito por que isso é uma armadilha para o usuário.

**Passo 6.** Acrescente uma **quinta** seção à `NavigationBar` e depois uma **sexta**. Rode em
janela estreita e observe os rótulos. Em que número o layout começa a sofrer?

**Passo 7.** Na `_AbaSessoes`, remova o `AutomaticKeepAliveClientMixin`. Role a lista de sessões,
vá para a aba Anotações e volte. Depois devolva o mixin e repita.

**Passo 8.** Remova a linha `super.build(context);` da `_AbaSessoes` (mantendo o mixin). Rode e leia
o erro.

**Passo 9.** Responda por escrito: por que `menu_lateral.dart` está em `core/widgets/` e
`materia_tile.dart` está em `features/materias/presentation/widgets/`? Qual pergunta decide isso?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Faça os exercícios de **Aplicação** com `NavigationBar` + `IndexedStack`, o de **Correção de bugs**
com a aba que perde estado, e o de **Decisão** sobre `Drawer` × barra.

---

## 🏆 Desafio opcional

Faça cada aba ter a **própria pilha de navegação** — como o Instagram, em que você abre um perfil
dentro da aba de busca, troca para a aba inicial e volta, encontrando o perfil ainda aberto.

Dica: coloque um `Navigator` **aninhado** dentro de cada aba, cada um com sua `GlobalKey`:

```dart
Navigator(
  key: _chavesDeNavegacao[i],
  onGenerateRoute: (RouteSettings s) => ...,
)
```

Requisitos:

- O botão voltar do sistema desempilha **a aba atual** primeiro; só quando ela está na raiz é que
  ele muda de aba (ou sai do app).
- Trocar de aba preserva a pilha da aba anterior.
- Tocar na aba **já selecionada** volta à raiz daquela aba (comportamento que os usuários esperam).

Depois responda: quantos `Navigator` existem no seu app agora? E o que `Navigator.of(context)`
passa a devolver dentro de uma aba — o de fora ou o de dentro? (Dica: a resposta está na busca para
cima da [aula 7 do Módulo 05](../05-introducao-ao-flutter/07-buildcontext.md); use
`rootNavigator: true` quando precisar do de fora.)

---

## 📌 Resumo

- Existem **três níveis de navegação**: entre seções (abas), dentro de uma seção (pilha), dentro de
  uma tela (`TabBar`). Confundi-los produz apps estranhos.
- **Trocar de aba nunca empilha rota.** É `setState`, não `push`.
- Use **`NavigationBar`** (Material 3), não `BottomNavigationBar`. De **3 a 5** destinos, rótulos de
  uma palavra.
- **`IndexedStack`** mantém todas as abas montadas e **preserva o estado** (rolagem, texto
  digitado, requisições). É o que o usuário espera.
- Não use `IndexedStack` com abas pesadas (mapa, câmera, vídeo) — o custo é de memória.
- **`PopScope`** decide o que o botão voltar faz com abas. Use `canPop` + `onPopInvokedWithResult`.
- **`TabBar` + `TabBarView`** são para recortes do mesmo conteúdo. `DefaultTabController` resolve a
  maioria dos casos; `TabController` próprio exige `dispose`.
- **`AutomaticKeepAliveClientMixin`** preserva uma aba interna fora de vista — e exige
  `super.build(context)`.
- O **`Drawer`** esconde a navegação. Use-o só para itens secundários, **complementando** a barra.
  Feche-o com `pop()` antes de empilhar outra rota.
- Organize `lib/` **por feature**, não por tipo. `core/` = serve ao app inteiro; `features/<x>/` =
  serve a um assunto só. A pergunta que decide: *"isso faz sentido sem a feature X?"*

---

## ☑️ Checklist de domínio

- [ ] Nomeio os três níveis de navegação e dou um exemplo de cada no meu app.
- [ ] Nunca empilho rota ao trocar de aba.
- [ ] Uso `NavigationBar` com 3 a 5 destinos e `selectedIcon`.
- [ ] Uso `IndexedStack` e explico exatamente o que ele preserva e o que ele custa.
- [ ] Sei quando **não** usar `IndexedStack`.
- [ ] Configuro o botão voltar com `PopScope` sem prender o usuário no app.
- [ ] Monto `TabBar` + `TabBarView` com `DefaultTabController`.
- [ ] Dou `dispose` em todo `TabController` que eu mesmo criar.
- [ ] Uso `AutomaticKeepAliveClientMixin` com `super.build(context)`.
- [ ] Fecho o `Drawer` antes de empilhar outra rota.
- [ ] Justifico por que o `Drawer` não guarda as seções principais.
- [ ] Organizo o projeto por feature e sei dizer o que vai para `core/`.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [NavigationBar class — api.flutter.dev](https://api.flutter.dev/flutter/material/NavigationBar-class.html)
- [IndexedStack class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html)
- [Work with tabs — docs.flutter.dev](https://docs.flutter.dev/cookbook/design/tabs)
- [TabController class — api.flutter.dev](https://api.flutter.dev/flutter/material/TabController-class.html)
- [AutomaticKeepAliveClientMixin — api.flutter.dev](https://api.flutter.dev/flutter/widgets/AutomaticKeepAliveClientMixin-mixin.html)
- [PopScope class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/PopScope-class.html)
- [Material 3 navigation bar — m3.material.io](https://m3.material.io/components/navigation-bar/overview)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Argumentos e resultados](03-argumentos-e-resultados.md) | [README](README.md) | [Aula 5 — Navegação Android × iOS](05-navegacao-android-x-ios.md) |
