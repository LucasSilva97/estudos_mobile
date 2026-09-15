# Aula 9 — go_router (OPCIONAL)

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 40 min · **Nível:** Intermediário
> **Status:** 🔵 **Opcional.** Nenhum projeto do curso depende desta aula.

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é **navegação declarativa** e como ela difere da pilha imperativa das aulas 1 a 4.
- Dizer **quais problemas concretos** o `go_router` resolve — e reconhecer quando esses problemas
  não existem no seu app.
- Configurar `GoRouter`, `GoRoute` e `MaterialApp.router`.
- Diferenciar **`context.go`** de **`context.push`** e escolher o certo.
- Usar **parâmetros de rota** (`/materia/:id`) e receber dados tipados com `extra`.
- Implementar **`redirect`** para proteger rotas que exigem login.
- Montar uma casca com abas usando **`StatefulShellRoute`**.
- Decidir, com critérios, se o seu próximo app usa `Navigator` ou `go_router`.

## ✅ Pré-requisitos

- [Aula 2 — Rotas nomeadas](02-rotas-nomeadas.md) e
  [Aula 3 — Argumentos e resultados](03-argumentos-e-resultados.md) — você precisa dominar o jeito
  do SDK **antes** de trocar por um pacote.
- [Aula 4 — Abas e organização](04-abas-e-organizacao.md) — o `StatefulShellRoute` é a versão
  declarativa do que você fez lá.
- [Módulo 03, aula 10 — Arquivos, bibliotecas e pacotes](../03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)
  — `pubspec.yaml` e `flutter pub add`.
- O projeto `foco_navegacao` rodando.

---

## 📖 Por que esta aula é opcional

O curso inteiro — incluindo os três projetos — usa `Navigator` + `onGenerateRoute`, do próprio SDK.
Essa é a decisão registrada em [05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md), e ela tem
três razões:

1. **Zero dependências.** Vem no Flutter, nunca quebra numa atualização de pacote.
2. **É o que você precisa entender de qualquer jeito.** O `go_router` é construído **em cima** do
   `Navigator`. Quem não entende a pilha não depura nem o `go_router`.
3. **Resolve 100% do que o curso precisa.** Nenhum projeto do curso tem link externo nem URL de
   navegador.

Então **por que esta aula existe?** Porque o `go_router` é mantido pelo próprio time do Flutter, é
o pacote de navegação mais usado do ecossistema, e você vai encontrá-lo em praticamente todo código
profissional. Você precisa **saber ler** um projeto que o usa, e saber **quando** ele vale a pena.

> 📌 Se você está no ritmo intensivo e com pouco tempo, **pule esta aula sem culpa** e volte depois
> do projeto final. Nada mais adiante depende dela.

---

## 📖 Conceito

### Imperativo × declarativo

O que você fez até aqui é **navegação imperativa**: você dá ordens.

```dart
Navigator.of(context).pushNamed(Rotas.materiaDetalhe, arguments: args);
Navigator.of(context).pop();
```

"Empilhe esta tela." "Desempilhe." Você controla a pilha passo a passo.

A **navegação declarativa** inverte isso: você descreve **onde o usuário está**, e o roteador
calcula qual pilha corresponde a esse lugar.

```dart
context.go('/materia/dart');
```

"O usuário está em `/materia/dart`." O `go_router` olha a árvore de rotas e monta a pilha
necessária — que pode ser `/` → `/materia` → `/materia/dart`, três telas de uma vez.

A diferença fica evidente quando a navegação **vem de fora**: um link, uma notificação, uma URL
digitada. Nesses casos ninguém apertou botão nenhum — não há sequência de `push` para reproduzir.
Só existe um **destino**.

### O que o `go_router` resolve de verdade

| Problema | Com `Navigator` puro | Com `go_router` |
|---|---|---|
| **Deep link** (`meuapp://materia/dart`) | Você escreve o interpretador de URL na mão | Nativo: a rota **é** a URL |
| **URL do navegador** no Flutter Web | A barra mostra sempre `/` | A URL acompanha a navegação, e o botão voltar do navegador funciona |
| **Proteger rota com login** | `if` espalhado por cada tela | Um `redirect` central |
| **Pilha profunda de uma vez** | Vários `push` em sequência | Um `go` para o caminho completo |
| **Parâmetro na rota** (`/materia/:id`) | `switch` com `RegExp` na mão | `GoRoute(path: '/materia/:id')` |
| **Rotas aninhadas com abas** | `Navigator` aninhado + `GlobalKey` (o desafio da aula 4) | `StatefulShellRoute` |

E o que ele **não** resolve — ou seja, quando não vale a pena:

- App sem deep link, sem web, sem login: você adiciona uma dependência e ganha nada.
- Apps pequenos: o `switch` de `onGenerateRoute` é mais simples de ler que a árvore de `GoRoute`.
- Devolver resultado de tela (`pop(valor)`): funciona, mas é **menos** direto que no `Navigator`.

> **O critério honesto:** se o seu app precisa de **deep link** ou roda na **web**, `go_router`
> compensa. Caso contrário, `onGenerateRoute` é mais simples e tem menos peças.

### Instalação

```powershell
flutter pub add go_router
```

Isso acrescenta ao `pubspec.yaml`:

```yaml
dependencies:
  go_router: ^18.0.1
```

> ⚠️ O `go_router` muda de API com frequência entre versões maiores. Código da versão 6 não compila
> na 18. Ao procurar exemplos na internet, **confira a versão** — esta é a causa número 1 de
> frustração com este pacote.

### A estrutura básica

```dart
final GoRouter _roteador = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
      routes: <RouteBase>[
        // Rota FILHA: o caminho completo é '/materia/:id'
        GoRoute(
          path: 'materia/:id',
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id']!;
            return DetalheMateriaScreen(id: id);
          },
        ),
      ],
    ),
  ],
);

// E no MaterialApp:
MaterialApp.router(
  routerConfig: _roteador,
  theme: TemaApp.claro,
)
```

Três peças novas:

- **`GoRoute`** — uma rota. `path` pode ter parâmetros (`:id`) e rotas filhas.
- **`GoRouterState`** — o que o roteador sabe sobre a navegação atual: parâmetros, query, `extra`.
- **`MaterialApp.router`** — variante do `MaterialApp` que delega a navegação a um roteador.

> 📌 Rotas **filhas** herdam o caminho do pai. `path: 'materia/:id'` dentro de `path: '/'` produz
> `/materia/:id`. Não repita a barra inicial nas filhas.

### `go` × `push`: a distinção central

Este é o ponto que mais confunde quem vem do `Navigator`:

```dart
context.go('/materia/dart');     // SUBSTITUI a pilha pela pilha do caminho
context.push('/materia/dart');   // EMPILHA por cima do que já existe
```

| | `context.go` | `context.push` |
|---|---|---|
| O que faz | Troca a localização; a pilha é **recalculada** | Empilha uma rota a mais |
| Botão voltar | Volta para o **pai** da rota | Volta para a tela **anterior** |
| Devolve resultado | ❌ | ✅ `await context.push<T>(...)` |
| Use para | Navegação principal, abas, deep link | Detalhe, formulário, fluxo temporário |

Regra prática: **`go` para "onde o usuário está"; `push` para "o que ele está fazendo agora"**.

### `extra`: passar objetos

Parâmetros de caminho só carregam texto. Para objetos, use `extra`:

```dart
context.push('/materia/dart', extra: materia);

// … na rota:
builder: (BuildContext context, GoRouterState state) {
  final Materia? previa = state.extra as Materia?;
  final String id = state.pathParameters['id']!;
  return DetalheMateriaScreen(id: id, previa: previa);
},
```

> ⚠️ **`extra` não sobrevive a um deep link nem a um recarregamento da página na web** — só existe
> em memória. Por isso o padrão híbrido da [aula 3](03-argumentos-e-resultados.md) continua valendo:
> o **id** vai no caminho (funciona sempre) e o objeto vai no `extra` como **prévia opcional**.

E, como `extra` é `Object?`, a validação da aula 3 continua obrigatória:

```dart
final Object? bruto = state.extra;
final Materia? previa = bruto is Materia ? bruto : null;   // ✅ nunca cast cego
```

### `redirect`: proteger rotas

```dart
GoRouter(
  routes: <RouteBase>[ ... ],
  redirect: (BuildContext context, GoRouterState state) {
    final bool logado = Sessao.instancia.estaLogado;
    final bool indoParaLogin = state.matchedLocation == '/login';

    // Não logado tentando entrar em qualquer lugar que não seja o login.
    if (!logado && !indoParaLogin) return '/login';

    // Já logado tentando ver a tela de login.
    if (logado && indoParaLogin) return '/';

    // null = siga como está.
    return null;
  },
)
```

Isso substitui o `if (!logado) Navigator.pushReplacement(...)` espalhado por 12 telas. Uma única
função decide.

> ⚠️ Cuidado com laço infinito: se o `redirect` devolver sempre um caminho diferente do atual, o
> roteador entra em ciclo. O `go_router` detecta e lança
> `RedirectionLimitExceeded`, mas o bug é seu. **Sempre** haja um caso que devolve `null`.

### `StatefulShellRoute`: abas declarativas

Na [aula 4](04-abas-e-organizacao.md) você montou abas com `IndexedStack`, e o desafio pedia um
`Navigator` aninhado por aba — trabalhoso. O `go_router` traz isso pronto:

```dart
StatefulShellRoute.indexedStack(
  builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell shell) =>
      CascaComAbas(shell: shell),
  branches: <StatefulShellBranch>[
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(path: '/hoje', builder: (_, __) => const HojeTab()),
    ]),
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
        path: '/materias',
        builder: (_, __) => const MateriasTab(),
        routes: <RouteBase>[
          // Esta rota empilha DENTRO da aba de matérias.
          GoRoute(path: ':id', builder: (_, GoRouterState s) =>
              DetalheMateriaScreen(id: s.pathParameters['id']!)),
        ],
      ),
    ]),
  ],
)
```

Cada `StatefulShellBranch` tem a **própria pilha**, preservada ao trocar de aba — exatamente o
comportamento do Instagram que o desafio da aula 4 pedia, e aqui sem escrever uma `GlobalKey`.

---

## 💡 Analogia

Pense na diferença entre dar direções e dar um endereço.

- **`Navigator` (imperativo)** é dar o caminho passo a passo: "vire à direita, siga duas quadras,
  entre no prédio, suba ao terceiro andar". Funciona perfeitamente **quando a pessoa está no ponto
  de partida que você imaginou**.
- **`go_router` (declarativo)** é dar o endereço: "Rua das Matérias, 42". A pessoa pode estar em
  qualquer lugar da cidade — o GPS calcula a rota. É por isso que o declarativo é natural para
  **deep link**: quem clica no link de uma notificação não está no ponto de partida; ele caiu de
  paraquedas no meio da cidade.
- **`go` × `push`** é a diferença entre **"mude-se para este endereço"** e **"passe lá para
  resolver uma coisa"**. No primeiro, você não volta para onde estava — aquele era o endereço
  antigo. No segundo, você volta.
- **`extra`** é um recado que você entrega **em mãos** para a pessoa antes de ela sair. Funciona
  quando vocês estão juntos — e não existe quando a pessoa chega ao endereço vinda de um link. Por
  isso o **endereço** (o id, no caminho) precisa ser suficiente sozinho.
- **`redirect`** é a portaria do prédio: todo mundo passa por ela, e quem não está na lista é
  mandado para o cadastro. Muito melhor do que colocar um porteiro na porta de cada apartamento.

---

## 🧪 Exemplo mínimo

Um app completo com `go_router`, mostrando `go`, `push`, parâmetro e `redirect`.

> **Arquivo:** `foco_navegacao/lib/main.dart` (temporário)
> **Instale antes:** `flutter pub add go_router`
> **Como executar:** `flutter run -d chrome` — **olhe a barra de endereços**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const AppGoRouter());

/// Sessão falsa, só para demonstrar o redirect.
class Sessao {
  static bool logado = false;
}

final GoRouter _roteador = GoRouter(
  initialLocation: '/',

  // Porteiro único do app: roda antes de QUALQUER navegação.
  redirect: (BuildContext context, GoRouterState state) {
    final bool indoParaLogin = state.matchedLocation == '/login';

    if (!Sessao.logado && !indoParaLogin) return '/login';
    if (Sessao.logado && indoParaLogin) return '/';

    // null = pode seguir. SEMPRE precisa existir um caminho que
    // devolve null, ou o roteador entra em laço infinito.
    return null;
  },

  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const TelaLogin(),
    ),

    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const TelaLista(),
      routes: <RouteBase>[
        // Rota FILHA: o caminho completo é '/materia/:id'.
        // Não repita a barra inicial em rotas filhas.
        GoRoute(
          path: 'materia/:id',
          builder: (BuildContext context, GoRouterState state) {
            // O parâmetro do caminho é sempre String.
            final String id = state.pathParameters['id']!;

            // extra é Object? — valide, nunca faça cast cego.
            final Object? bruto = state.extra;
            final String? nomePrevia = bruto is String ? bruto : null;

            return TelaDetalhe(id: id, nomePrevia: nomePrevia);
          },
        ),
      ],
    ),
  ],

  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    appBar: AppBar(title: const Text('Rota desconhecida')),
    body: Center(child: Text('Não existe: ${state.uri}')),
  ),
);

class AppGoRouter extends StatelessWidget {
  const AppGoRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router, não MaterialApp.
    return MaterialApp.router(
      routerConfig: _roteador,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
    );
  }
}

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Sessao.logado = true;
            // go: SUBSTITUI a pilha. O usuário não deve "voltar" ao login.
            context.go('/');
          },
          child: const Text('Entrar'),
        ),
      ),
    );
  }
}

class TelaLista extends StatelessWidget {
  const TelaLista({super.key});

  static const List<String> _materias = <String>['dart', 'flutter', 'git'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matérias'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Sessao.logado = false;
              context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          for (final String m in _materias)
            ListTile(
              title: Text(m),
              // push: EMPILHA. O usuário volta para a lista.
              onTap: () => context.push('/materia/$m', extra: m.toUpperCase()),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Ir direto para /materia/sql (deep link)'),
            subtitle: const Text('Sem prévia: simula chegada por link externo'),
            // go com caminho profundo: a pilha inteira é montada de uma vez.
            onTap: () => context.go('/materia/sql'),
          ),
        ],
      ),
    );
  }
}

class TelaDetalhe extends StatelessWidget {
  const TelaDetalhe({super.key, required this.id, this.nomePrevia});

  final String id;

  /// Veio pelo `extra`. É null quando a tela foi aberta por deep link.
  final String? nomePrevia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nomePrevia ?? id)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('id (do caminho): $id'),
            Text('prévia (do extra): ${nomePrevia ?? "não veio"}'),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Recarregue a página do navegador (F5) e veja: o id continua, '
                'mas a prévia some. É por isso que o id precisa bastar sozinho.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Faça estes cinco testes — e olhe a barra de endereços em cada um:**

1. Abra: você cai em `/login`, mesmo tendo pedido `/`. O `redirect` agiu.
2. Entre: a URL vira `/`. Aperte o **botão voltar do navegador**: você **não** volta ao login.
3. Toque em "dart": a URL vira `/materia/dart` e a barra de título mostra `DART` (veio do `extra`).
4. Aperte **F5** nessa página. O `id` continua; a **prévia some**. Esse é o limite do `extra`.
5. Toque em "Ir direto para /materia/sql": a pilha inteira é montada de uma vez, e o botão voltar
   leva à lista — que você nunca visitou nesta sessão.

---

## 📱 Aplicando no Flutter

Aqui está o `foco_navegacao` **inteiro** convertido para `go_router`, para você comparar com o que
escreveu nas aulas 2 a 4. Este é um exercício de leitura: o projeto oficial do curso continua com
`onGenerateRoute`.

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/core/rotas/roteador.dart` (novo — versão `go_router`)
> **Instale antes:** `flutter pub add go_router`
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foco_navegacao/features/estatisticas/presentation/estatisticas_screen.dart';
import 'package:foco_navegacao/features/hoje/presentation/hoje_tab.dart';
import 'package:foco_navegacao/features/materias/domain/materia.dart';
import 'package:foco_navegacao/features/materias/presentation/detalhe_materia_screen.dart';
import 'package:foco_navegacao/features/materias/presentation/materia_form_screen.dart';
import 'package:foco_navegacao/features/materias/presentation/materias_tab.dart';
import 'package:foco_navegacao/features/metas/presentation/ajustes_tab.dart';
import 'package:foco_navegacao/features/trilhas/presentation/trilhas_tab.dart';

/// Caminhos do app, centralizados.
///
/// Mesma ideia da classe Rotas da aula 2: o compilador pega o erro de
/// digitação. O que muda é que aqui os caminhos são URLs de verdade.
abstract final class Caminhos {
  static const String hoje = '/hoje';
  static const String materias = '/materias';
  static const String trilhas = '/trilhas';
  static const String ajustes = '/ajustes';
  static const String estatisticas = '/estatisticas';

  /// Monta '/materias/dart' a partir do id.
  static String materia(String id) => '$materias/$id';

  /// '/materias/dart/editar'
  static String editarMateria(String id) => '${materia(id)}/editar';

  static const String novaMateria = '$materias/nova';
}

/// Chave do Navigator raiz: rotas que precisam cobrir as abas
/// (como o formulário em tela cheia) são registradas nele.
final GlobalKey<NavigatorState> _chaveRaiz = GlobalKey<NavigatorState>();

final GoRouter roteador = GoRouter(
  navigatorKey: _chaveRaiz,
  initialLocation: Caminhos.hoje,

  // Em desenvolvimento, imprime cada navegação no console. Vale muito
  // enquanto você aprende a entender o que o roteador está fazendo.
  debugLogDiagnostics: true,

  routes: <RouteBase>[
    // ── Casca com abas ────────────────────────────────────────────────────
    // Cada branch tem a PRÓPRIA pilha, preservada ao trocar de aba.
    // É o desafio da aula 4, resolvido pelo pacote.
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell casca) =>
          CascaComAbas(casca: casca),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Caminhos.hoje,
              builder: (_, __) => const HojeTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Caminhos.materias,
              builder: (_, __) => const MateriasTab(),
              routes: <RouteBase>[
                // '/materias/nova' — precisa vir ANTES de ':id',
                // senão 'nova' seria interpretado como um id.
                GoRoute(
                  path: 'nova',
                  parentNavigatorKey: _chaveRaiz, // cobre as abas
                  builder: (_, __) => const MateriaFormScreen(
                    args: MateriaFormArgs.criar(),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (BuildContext context, GoRouterState state) {
                    final String id = state.pathParameters['id']!;

                    // extra é Object?. Valide sempre — mesma regra da aula 3.
                    final Object? bruto = state.extra;
                    final Materia? previa = bruto is Materia ? bruto : null;

                    return DetalheMateriaScreen(
                      args: MateriaDetalheArgs(id: id, previa: previa),
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'editar',
                      parentNavigatorKey: _chaveRaiz,
                      builder: (BuildContext context, GoRouterState state) {
                        final Object? bruto = state.extra;
                        if (bruto is! Materia) {
                          // Sem a matéria não há o que editar.
                          return const _TelaArgumentoInvalido();
                        }
                        return MateriaFormScreen(
                          args: MateriaFormArgs.editar(bruto),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Caminhos.trilhas,
              builder: (_, __) => const TrilhasTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Caminhos.ajustes,
              builder: (_, __) => const AjustesTab(),
            ),
          ],
        ),
      ],
    ),

    // ── Fora das abas ─────────────────────────────────────────────────────
    GoRoute(
      path: Caminhos.estatisticas,
      builder: (_, __) => const EstatisticasScreen(),
    ),
  ],

  // Equivalente ao onUnknownRoute da aula 2.
  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    appBar: AppBar(title: const Text('Página não encontrada')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.wrong_location_outlined, size: 64),
          const SizedBox(height: 16),
          Text('Não encontramos: ${state.uri}'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go(Caminhos.hoje),
            child: const Text('Ir para o início'),
          ),
        ],
      ),
    ),
  ),
);

class _TelaArgumentoInvalido extends StatelessWidget {
  const _TelaArgumentoInvalido();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados insuficientes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Abra a matéria pela lista para poder editá-la.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(Caminhos.materias),
              child: const Text('Ver matérias'),
            ),
          ],
        ),
      ),
    );
  }
}
```

> **Arquivo:** `foco_navegacao/lib/core/layout/casca_com_abas.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Casca de abas alimentada pelo StatefulShellRoute.
///
/// Compare com o HomeScreen da aula 4: aqui não há `int _indice`, não há
/// `IndexedStack` e não há lista de telas. O shell cuida de tudo — e ainda
/// dá a cada aba a própria pilha de navegação.
class CascaComAbas extends StatelessWidget {
  const CascaComAbas({super.key, required this.casca});

  final StatefulNavigationShell casca;

  static const List<({String rotulo, IconData icone, IconData selecionado})>
      _destinos = <({String rotulo, IconData icone, IconData selecionado})>[
    (rotulo: 'Hoje', icone: Icons.today_outlined, selecionado: Icons.today),
    (
      rotulo: 'Matérias',
      icone: Icons.menu_book_outlined,
      selecionado: Icons.menu_book
    ),
    (rotulo: 'Trilhas', icone: Icons.route_outlined, selecionado: Icons.route),
    (
      rotulo: 'Ajustes',
      icone: Icons.settings_outlined,
      selecionado: Icons.settings
    ),
  ];

  void _aoSelecionar(int indice) {
    // initialLocation: true faz tocar na aba JÁ SELECIONADA voltar à raiz
    // dela — comportamento que os usuários esperam e que, com Navigator
    // puro, dá bastante trabalho.
    casca.goBranch(indice, initialLocation: indice == casca.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bool telaLarga = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: Row(
        children: <Widget>[
          if (telaLarga) ...<Widget>[
            NavigationRail(
              selectedIndex: casca.currentIndex,
              onDestinationSelected: _aoSelecionar,
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                for (final d in _destinos)
                  NavigationRailDestination(
                    icon: Icon(d.icone),
                    selectedIcon: Icon(d.selecionado),
                    label: Text(d.rotulo),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
          ],

          // O shell JÁ é um IndexedStack por dentro: o estado de cada
          // aba é preservado sem você escrever nada.
          Expanded(child: casca),
        ],
      ),
      bottomNavigationBar: telaLarga
          ? null
          : NavigationBar(
              selectedIndex: casca.currentIndex,
              onDestinationSelected: _aoSelecionar,
              destinations: <Widget>[
                for (final d in _destinos)
                  NavigationDestination(
                    icon: Icon(d.icone),
                    selectedIcon: Icon(d.selecionado),
                    label: d.rotulo,
                  ),
              ],
            ),
    );
  }
}
```

E as telas navegam assim:

```dart
// Abrir o detalhe, empilhando DENTRO da aba de matérias,
// com prévia para a tela não piscar (padrão da aula 3).
context.push(Caminhos.materia(materia.id), extra: materia);

// Abrir o formulário e ESPERAR o resultado.
final Object? retorno = await context.push<Object?>(Caminhos.novaMateria);
if (!context.mounted) return;
if (retorno is Materia) {
  setState(() => _materias = <Materia>[..._materias, retorno]);
}

// Voltar devolvendo a matéria salva.
context.pop(materiaSalva);

// Ir para uma aba (substituindo a pilha, não empilhando).
context.go(Caminhos.estatisticas);
```

E o `main.dart`:

```dart
import 'package:flutter/material.dart';

import 'package:foco_navegacao/core/rotas/roteador.dart';
import 'package:foco_navegacao/core/tema/tema_app.dart';

void main() => runApp(const FocoApp());

class FocoApp extends StatelessWidget {
  const FocoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router — não MaterialApp.
    return MaterialApp.router(
      title: 'Foco',
      routerConfig: roteador,
      theme: TemaApp.claro,
      darkTheme: TemaApp.escuro,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

Rode e compare com a versão das aulas 2 a 4:

```powershell
flutter pub add go_router
flutter analyze
flutter run -d chrome
```

1. Navegue entre as abas e **olhe a URL**: `/hoje`, `/materias`, `/trilhas`.
2. Abra uma matéria: a URL vira `/materias/dart`.
3. Aperte **F5**: a página recarrega **na mesma tela** — a prévia some, o id permanece.
4. Cole `/materias/inexistente` na barra: o `errorBuilder` aparece.
5. Vá para "Matérias", abra um detalhe, troque para "Hoje" e volte: o detalhe **ainda está aberto**.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `abstract final class Caminhos` | Mesma ideia da classe `Rotas` da aula 2. A diferença: aqui os caminhos **são URLs reais**. |
| `static String materia(String id) => '$materias/$id';` | Função em vez de constante, porque o caminho tem parâmetro. Impede montar a URL na mão e errar a barra. |
| `GlobalKey<NavigatorState> _chaveRaiz` | Identifica o `Navigator` de fora. Rotas que precisam **cobrir as abas** se registram nele. |
| `parentNavigatorKey: _chaveRaiz` no formulário | Sem isso, o formulário abriria **dentro** da aba, com a barra de navegação visível por baixo. |
| `path: 'nova'` **antes** de `path: ':id'` | A ordem importa: `:id` casa com qualquer texto, inclusive `'nova'`. O específico vem primeiro. |
| `state.pathParameters['id']!` | Parâmetro do caminho, sempre `String`. O `!` é seguro porque a rota só casa se o `:id` existir. |
| `final Object? bruto = state.extra; ... bruto is Materia ? bruto : null` | `extra` é `Object?`. **Nunca** faça cast cego — mesma regra da [aula 3](03-argumentos-e-resultados.md). |
| `if (bruto is! Materia) return const _TelaArgumentoInvalido();` | Deep link para `/materias/x/editar` chega **sem** `extra`. Tratar isso é obrigatório. |
| `StatefulShellRoute.indexedStack` | Abas com pilha própria por aba, preservadas. É o desafio da aula 4, pronto. |
| `casca.goBranch(indice, initialLocation: indice == casca.currentIndex)` | Tocar na aba já selecionada volta à raiz dela — comportamento que os usuários esperam. |
| `Expanded(child: casca)` | O `StatefulNavigationShell` **é** um widget: já contém o `IndexedStack` por dentro. |
| `debugLogDiagnostics: true` | Imprime cada navegação no console. Muito útil enquanto você aprende. |
| `errorBuilder` | Equivalente ao `onUnknownRoute` da aula 2 — e aqui é **essencial**, porque na web qualquer pessoa pode digitar uma URL. |
| `await context.push<Object?>(...)` + `retorno is Materia` | `push` devolve resultado, como o `Navigator`. `go` **não** devolve. |
| `({String rotulo, IconData icone, IconData selecionado})` | *Record* nomeado do Dart 3 — agrupa os três campos sem criar uma classe. [Módulo 04](../04-dart-avancado/04-records.md). |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Deep link | *App Links* — `AndroidManifest.xml` + verificação de domínio | *Universal Links* — `Info.plist` + arquivo no servidor |
| Esquema próprio (`meuapp://`) | `<intent-filter>` no manifest | `CFBundleURLTypes` no `Info.plist` |
| Botão voltar | Existe; o `go_router` integra | Não existe |
| Gesto de borda | — | Funciona normalmente |
| Configuração mínima | Uma tag no manifest | Uma chave no plist |

> 📌 **O `go_router` não configura deep link sozinho.** Ele interpreta a URL depois que o sistema
> operacional a entrega ao app — e entregar é trabalho de configuração **nativa**, em cada
> plataforma. Os arquivos ficam em `android/app/src/main/AndroidManifest.xml` e
> `ios/Runner/Info.plist`; o [Módulo 11, aula 7](../11-recursos-nativos/07-pastas-android-e-ios.md)
> mostra essas pastas por dentro.

---

## ⚠️ Erros comuns

### 1. `MaterialApp` em vez de `MaterialApp.router`

```dart
MaterialApp(home: const HomeScreen())   // ❌ o roteador nunca é usado
```

**Correção:** `MaterialApp.router(routerConfig: roteador)`.

### 2. Barra inicial em rota filha

```dart
GoRoute(
  path: '/',
  routes: <RouteBase>[
    GoRoute(path: '/materia/:id', ...),   // ❌ vira '//materia/:id'
  ],
)
```

**Correção:** `path: 'materia/:id'`, sem a barra.

### 3. Rota com parâmetro antes da rota literal

```dart
routes: <RouteBase>[
  GoRoute(path: ':id', ...),      // ❌ casa com 'nova' também
  GoRoute(path: 'nova', ...),     // nunca é alcançada
]
```

**Correção:** o caminho **específico** vem primeiro.

### 4. `go` onde deveria ser `push`

```dart
onTap: () => context.go('/materias/dart'),   // ⚠️ o usuário perde o caminho
```

Se você queria empilhar o detalhe, `go` recalcula a pilha e o voltar pode não levar aonde você
espera.

**Correção:** `push` para detalhe e formulário; `go` para navegação principal.

### 5. Esperar resultado de um `go`

```dart
final Materia? m = await context.go('/materias/nova');   // ❌ go não devolve
```

**Correção:** `await context.push<Materia>('/materias/nova')`.

### 6. Cast cego no `extra`

```dart
final Materia m = state.extra! as Materia;   // ❌
```

```text
type 'Null' is not a subtype of type 'Materia' in type cast
```

Acontece no primeiro deep link — e deep link é justamente por que você adotou o `go_router`.

**Correção:** `state.extra is Materia ? ... : null` e trate o caso ausente.

### 7. Depender do `extra` para a tela funcionar

```dart
builder: (_, GoRouterState s) => DetalheScreen(materia: s.extra! as Materia),   // ❌
```

Funciona quando o usuário chega pela lista. Quebra quando ele chega por link, notificação, ou dá
F5 na web.

**Correção:** o **id no caminho** precisa bastar sozinho; `extra` é só prévia.

### 8. `redirect` em laço infinito

```dart
redirect: (BuildContext c, GoRouterState s) => '/login',   // ❌ sempre redireciona
```

```text
RedirectionLimitExceeded: too many redirects
```

**Correção:** haja sempre um caso que devolve `null`.

### 9. Esquecer `parentNavigatorKey` em tela que deveria cobrir as abas

O formulário abre **dentro** da aba, com a barra de navegação visível por baixo.

**Correção:** `parentNavigatorKey: _chaveRaiz`.

### 10. Copiar código de versão antiga

```dart
GoRouter(routes: [...], urlPathStrategy: UrlPathStrategy.path)   // ❌ removido
```

O `go_router` teve muitas mudanças de API. Código da versão 4, 6 ou 10 não compila na 18.

**Correção:** confira a versão do exemplo antes de copiar; consulte o
[CHANGELOG do pacote](https://pub.dev/packages/go_router/changelog).

### 11. Adotar `go_router` sem precisar

App sem deep link, sem web e sem login: você acrescentou uma dependência, uma API nova e uma fonte
de quebras a cada atualização — em troca de nada.

**Correção:** `onGenerateRoute`. A decisão de ferramenta é uma decisão de **problema**, não de moda.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e navegue com a barra de endereços visível. Anote a URL de cada
tela.

**Passo 2.** Na tela de detalhe, aperte **F5**. Anote o que sobreviveu e o que sumiu. Explique por
escrito por que o id precisa bastar sozinho.

**Passo 3.** Troque `context.push('/materia/dart')` por `context.go('/materia/dart')` na lista.
Navegue e aperte voltar. Descreva a diferença.

**Passo 4.** Cole `/materia/inexistente` na barra. Depois cole `/rota/que/nao/existe`. As duas caem
no `errorBuilder`? Explique por que a primeira **não** cai.

**Passo 5.** No `redirect`, remova a linha `if (Sessao.logado && indoParaLogin) return '/';`. Entre
no app e depois navegue para `/login` pela barra. O que acontece?

**Passo 6.** Faça o `redirect` devolver sempre `'/login'`. Rode e leia o erro. Anote o nome dele.

**Passo 7.** No projeto convertido, inverta a ordem de `path: 'nova'` e `path: ':id'`. Toque no
botão de criar matéria e observe. Depois desfaça.

**Passo 8.** Remova `parentNavigatorKey: _chaveRaiz` da rota do formulário. Abra o formulário e
observe a barra de navegação. Depois desfaça.

**Passo 9.** Compare lado a lado: `core/rotas/rotas.dart` (aula 2) e `core/rotas/roteador.dart`
(esta aula). Conte as linhas de cada um. Qual você acha mais fácil de ler **hoje**? E daqui a seis
meses, com 30 telas?

**Passo 10.** Responda por escrito: o **seu** próximo app vai ter deep link ou rodar na web? Se não,
qual seria a justificativa para adotar `go_router`?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Os exercícios de `go_router` estão marcados como **opcionais**. Faça-os se pretende trabalhar com
Flutter Web ou com apps que recebem links externos.

---

## 🏆 Desafio opcional

Configure **deep link de verdade** no projeto convertido, para que
`https://foco.exemplo.com/materias/dart` abra o app direto na matéria.

Requisitos:

- Android: `<intent-filter>` com `android:autoVerify="true"` no `AndroidManifest.xml`.
- iOS: `CFBundleURLTypes` no `Info.plist` (para esquema próprio) ou *Associated Domains* (para
  Universal Links).
- O app precisa funcionar quando estiver **fechado** e quando estiver **em segundo plano**.
- A tela de detalhe precisa carregar a matéria **só pelo id** — sem `extra`.

Teste no Android com:

```powershell
adb shell am start -a android.intent.action.VIEW -d "https://foco.exemplo.com/materias/dart"
```

Depois responda: quanto do trabalho foi Dart e quanto foi configuração nativa? Essa proporção
explica por que "adotar go_router" e "ter deep link" são coisas diferentes.

---

## 📌 Resumo

- **Navegação declarativa** descreve **onde o usuário está**; o roteador calcula a pilha. A
  imperativa dá ordens de `push` e `pop`.
- O `go_router` compensa quando o app tem **deep link** ou roda na **web**. Sem isso, você adiciona
  dependência e ganha pouco.
- **A decisão do curso continua sendo `Navigator` + `onGenerateRoute`** — e você precisa dominá-lo
  de qualquer forma, porque o `go_router` é construído sobre ele.
- `MaterialApp.router(routerConfig: ...)`, nunca `MaterialApp`.
- Rotas **filhas** herdam o caminho do pai e **não** levam barra inicial.
- Caminho **literal** (`'nova'`) precisa vir **antes** do parâmetro (`':id'`).
- **`context.go`** substitui a pilha (navegação principal, abas, deep link);
  **`context.push`** empilha e **devolve resultado** (detalhe, formulário).
- `state.pathParameters['id']` é sempre `String`. `state.extra` é `Object?` — **valide sempre**.
- **`extra` não sobrevive a deep link nem a F5.** O id no caminho precisa bastar sozinho; `extra`
  é apenas prévia.
- **`redirect`** centraliza a proteção de rotas. Sempre haja um caso que devolve `null`, ou o
  roteador entra em laço.
- **`StatefulShellRoute.indexedStack`** dá abas com pilha própria por aba — o desafio da aula 4,
  pronto.
- `parentNavigatorKey` faz uma rota cobrir as abas em vez de abrir dentro delas.
- O `go_router` **não** configura deep link: isso é configuração nativa em cada plataforma.
- A API muda muito entre versões maiores. **Sempre confira a versão** dos exemplos que encontrar.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre navegação imperativa e declarativa.
- [ ] Listo três problemas que o `go_router` resolve e dois casos em que ele não vale a pena.
- [ ] Configuro `GoRouter` + `MaterialApp.router`.
- [ ] Escrevo rotas filhas sem barra inicial e na ordem certa.
- [ ] Escolho entre `go` e `push` e justifico.
- [ ] Leio parâmetros com `state.pathParameters` e valido `state.extra` sem cast cego.
- [ ] Sei que `extra` some em deep link e F5, e projeto a tela para funcionar só com o id.
- [ ] Escrevo um `redirect` que não entra em laço.
- [ ] Uso `StatefulShellRoute` para abas com pilha própria.
- [ ] Sei o que `parentNavigatorKey` resolve.
- [ ] Sei que deep link exige configuração nativa além do Dart.
- [ ] Consigo **justificar** a escolha entre `onGenerateRoute` e `go_router` para um app concreto.

---

## 📚 Referências oficiais

- [go_router — pub.dev](https://pub.dev/packages/go_router)
- [Navigation and routing — docs.flutter.dev](https://docs.flutter.dev/ui/navigation)
- [Deep linking — docs.flutter.dev](https://docs.flutter.dev/ui/navigation/deep-linking)
- [Learning Flutter's new navigation and routing system — Flutter Medium](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade)
- [go_router changelog — pub.dev](https://pub.dev/packages/go_router/changelog)
- [Android App Links — developer.android.com](https://developer.android.com/training/app-links)
- [Universal Links — developer.apple.com](https://developer.apple.com/ios/universal-links/)

---

## 🎓 Fim do Módulo 07

Você começou o módulo com um app de tela única e termina com:

- uma **pilha** de navegação que você entende de verdade (aulas 1 e 2);
- **dados indo e voltando** entre telas, com tipo garantido (aula 3);
- **abas** que preservam estado, em celular e em tablet (aula 4);
- navegação que **parece nativa** nas duas plataformas (aula 5);
- **formulários** completos, validados e acessíveis (aulas 6 a 8);
- e a capacidade de **ler e avaliar** um projeto que usa `go_router` (aula 9).

Antes de seguir:

1. Faça os exercícios em
   [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md).
2. Faça a avaliação em
   [avaliacoes/modulo-07-navegacao-e-formularios.md](../../avaliacoes/modulo-07-navegacao-e-formularios.md).
3. Confirme que `flutter analyze` no `foco_navegacao` termina com `No issues found!`.

No [Módulo 08](../08-estado-e-arquitetura/README.md) o `setState` encontra o seu limite: você vai
descobrir por que passar callbacks de tela em tela não escala, e como o estado sai dos widgets.

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo |
|---|---|---|
| [Aula 8 — UX de formulários](08-ux-de-formularios.md) | [README](README.md) | [Módulo 08 — Estado e Arquitetura](../08-estado-e-arquitetura/README.md) |
