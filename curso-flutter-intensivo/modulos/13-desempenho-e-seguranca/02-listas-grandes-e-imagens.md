# Aula 2 — Listas grandes e imagens

> **Módulo:** 13 - Desempenho e Segurança · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que **`ListView(children: [...])` com 5 000 itens trava** e `ListView.builder` não.
- Usar **`itemExtent`** e **`prototypeItem`** para acelerar a rolagem.
- Implementar **paginação** (rolagem infinita) com `ScrollController`.
- Entender por que **uma imagem de 4 MB ocupa 48 MB de memória** — e o que fazer.
- Usar **`cacheWidth`/`cacheHeight`** e `ResizeImage` para cortar esse custo.
- Carregar imagens de rede com **`cached_network_image`**, placeholder e erro.
- Medir o consumo real na aba **Memory** do DevTools.

## ✅ Pré-requisitos

- [Aula 1 — Rebuilds, const e keys](01-rebuilds-const-e-keys.md) — o projeto `foco_desempenho`,
  o modelo `Materia` e o `MateriaTile` vêm de lá.
- [Módulo 06, aula 9 — Listas e rolagem](../06-widgets-e-layouts/09-listas-e-rolagem.md) —
  `ListView.builder` e `ListView.separated`.
- [Módulo 12, aula 3 — DevTools](../12-testes-e-debug/03-devtools.md) — a aba Memory.
- [Módulo 08 — Estado e arquitetura](../08-estado-e-arquitetura/README.md) — a paginação usa um
  `AsyncNotifier`.

---

## 📖 Conceito

### Por que a lista trava

```dart
// ❌ 5 000 itens: constrói TODOS agora, antes de mostrar o primeiro.
ListView(
  children: <Widget>[
    for (final Materia m in materias) MateriaTile(materia: m),
  ],
)
```

```dart
// ✅ 5 000 itens: constrói ~15, os que cabem na tela.
ListView.builder(
  itemCount: materias.length,
  itemBuilder: (BuildContext context, int i) => MateriaTile(materia: materias[i]),
)
```

A diferença tem nome: **lazy building**. O `.builder` só chama `itemBuilder` para o que está (ou
está quase) visível, e descarta o que saiu.

| | `ListView(children:)` | `ListView.builder` |
|---|---|---|
| 10 itens | ✅ Tudo bem | ✅ |
| 100 itens | ⚠️ Perceptível | ✅ |
| 5 000 itens | ❌ Congela ~4 s | ✅ Instantâneo |
| Widgets criados | **Todos** | ~15 |
| Memória | Cresce com a lista | Constante |

> 📌 **A regra:** se a lista tem quantidade **variável** de itens — ou seja, vem de banco, de API,
> do usuário — use **sempre** `.builder`. `children:` só para quantidade fixa e pequena, como as
> quatro linhas de um menu.

O mesmo vale para os primos:

| Widget | Quando |
|---|---|
| `ListView.builder` | Lista simples |
| `ListView.separated` | Com divisor entre itens |
| `GridView.builder` | Grade |
| `SliverList` / `SliverGrid` | Dentro de `CustomScrollView` |
| `ListView(children:)` | Poucos itens, quantidade fixa |

### `itemExtent`: dizer a altura de antemão

Quando todos os itens têm a **mesma altura**, informe-a:

```dart
ListView.builder(
  itemExtent: 72,        // ← todos têm 72 px
  itemCount: materias.length,
  itemBuilder: …,
)
```

Sem `itemExtent`, o Flutter precisa **medir** cada item para saber onde está a barra de rolagem e
para onde pular. Com ele, a conta é multiplicação: item 3 000 está em `3000 × 72`.

| | Sem `itemExtent` | Com `itemExtent` |
|---|---|---|
| Rolagem normal | ✅ Ok | ✅ Melhor |
| Arrastar a barra até o fim | ⚠️ Mede tudo | ✅ Instantâneo |
| `jumpTo(50000)` | ❌ Lento | ✅ Instantâneo |

Quando a altura é sempre a mesma mas você não sabe qual, use `prototypeItem`:

```dart
ListView.builder(
  prototypeItem: MateriaTile(materia: materiaExemplo),   // mede UMA vez
  itemCount: materias.length,
  itemBuilder: …,
)
```

> ⚠️ **`itemExtent` com itens de alturas diferentes corta o conteúdo.** Se um item precisa de
> 90 px e você declarou 72, o texto fica cortado sem nenhum aviso. Na dúvida, não use.

### O `cacheExtent`

O Flutter constrói um pouco **além** da tela, para a rolagem não mostrar branco:

```dart
ListView.builder(
  cacheExtent: 500,   // 500 px acima e abaixo do visível
  …
)
```

| Valor | Efeito |
|---|---|
| Baixo (0–100) | Menos memória; pode piscar ao rolar rápido |
| Padrão (250) | ✅ Equilibrado |
| Alto (1000+) | Rolagem mais suave; mais memória e mais construção |

> 💡 Mexa nisso **só depois de medir**. O padrão é bom; aumentar sem necessidade é trocar jank de
> rolagem por jank de construção.

### Imagens: o cálculo que assusta

Um JPEG de 4 MB, 4000 × 3000 px, exibido num avatar de 48 × 48:

```text
Em disco (comprimido):     4 MB
Na memória (descomprimido):
  4000 × 3000 × 4 bytes  = 48 000 000 bytes ≈ 48 MB
```

> ⚠️ **O arquivo é comprimido; a memória não.** Para desenhar, o Flutter precisa do bitmap cru:
> largura × altura × 4 bytes (RGBA). O tamanho do arquivo **não importa** para a memória — só as
> dimensões importam.

Vinte avatares assim = **960 MB**. O app é morto pelo sistema muito antes disso.

A correção é decodificar **no tamanho em que vai aparecer**:

```dart
// ❌ decodifica 4000 × 3000 para mostrar em 48 × 48
Image.asset('assets/imagens/capa.jpg', width: 48, height: 48)

// ✅ decodifica em 96 × 96 (48 × devicePixelRatio 2)
Image.asset(
  'assets/imagens/capa.jpg',
  width: 48,
  height: 48,
  cacheWidth: 96,
  cacheHeight: 96,
)
```

```text
Antes:  4000 × 3000 × 4 = 48 MB
Depois:   96 ×   96 × 4 = 36 KB      ← 1300 vezes menos
```

> 📌 **`width`/`height` mudam o tamanho na tela. `cacheWidth`/`cacheHeight` mudam o tamanho na
> memória.** São coisas diferentes, e é o segundo par que evita o app ser morto.

O valor certo do `cacheWidth` é o tamanho de exibição **vezes o `devicePixelRatio`** — um celular
comum tem 2 ou 3. Menos que isso, e a imagem sai borrada.

```dart
final double dpr = MediaQuery.devicePixelRatioOf(context);
final int alvo = (48 * dpr).round();
```

### Imagens de rede

```dart
// Básico: sem placeholder, sem cache entre execuções.
Image.network(url)

// Melhor: com estados.
Image.network(
  url,
  loadingBuilder: (_, Widget filho, ImageChunkEvent? p) =>
      p == null ? filho : const CircularProgressIndicator(),
  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
)
```

Mas `Image.network` só guarda em memória: fechou o app, baixa tudo de novo. Para cache em disco:

```yaml
dependencies:
  cached_network_image: ^3.4.1
```

```dart
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 96,                                   // ← o cacheWidth daqui
  placeholder: (_, __) => const _EsqueletoCapa(),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
)
```

| | `Image.network` | `CachedNetworkImage` |
|---|---|---|
| Cache em memória | ✅ | ✅ |
| Cache em **disco** | ❌ | ✅ |
| Sobrevive a fechar o app | ❌ | ✅ |
| Placeholder | `loadingBuilder` | `placeholder` |
| Limitar memória | `cacheWidth` | `memCacheWidth` |

> 💡 **Sempre trate os dois estados**: carregando e erro. Uma imagem que falha sem `errorWidget`
> deixa um buraco cinza — e no `Image.network` ainda **lança uma exceção** no console a cada
> tentativa.

### Paginação

Carregar 5 000 itens de uma vez é errado mesmo com `.builder`: o `.builder` resolve o custo de
**construir**, não o de **buscar**.

```text
Página 1 (20 itens) → usuário rola → chegou a 80% → busca página 2 → …
```

Os cuidados que fazem a diferença:

| Cuidado | Por quê |
|---|---|
| Disparar a 80%, não no fim | O usuário não vê o carregamento |
| Trava contra chamada dupla | O `ScrollController` dispara várias vezes |
| Saber quando acabou | Senão busca a página 99 para sempre |
| Mostrar erro **sem** perder o que já veio | O usuário não quer recomeçar |
| `itemCount + 1` para o rodapé | O indicador é o último item |

---

## 💡 Analogia

Pense numa biblioteca.

- **`ListView(children:)`** é o bibliotecário que, ao pedirem "quero ver os livros", **traz todos os
  cinco mil** para o balcão antes de deixar você olhar o primeiro. Você espera quatro segundos
  olhando para o nada, e o balcão desaba.
- **`ListView.builder`** traz **quinze** — os que cabem na mesa. Quando você empurra um para o
  lado, ele guarda e traz o seguinte. Cinco mil ou cinco milhões: a mesa tem sempre quinze.
- **`itemExtent`** é saber que **todo livro tem a mesma espessura**. Aí, para chegar ao livro 3 000,
  o bibliotecário mede: 3 000 × 2 cm. Sem isso, ele precisa percorrer a estante inteira medindo
  livro por livro — que é o que acontece ao arrastar a barra de rolagem até o fim.
- **`cacheExtent`** é deixar alguns livros **já separados** na estante ao lado. Se você rolar
  rápido, eles estão à mão. Separar demais é ocupar a estante inteira à toa.
- **A imagem** é o ponto mais contraintuitivo. O livro fechado é fino — 4 MB. Mas para **ler**, o
  bibliotecário precisa abrir e espalhar todas as páginas na mesa: 48 MB. Você só queria ver a capa
  em miniatura, e ele ocupou a sala inteira. **`cacheWidth` é pedir a miniatura da capa** em vez do
  livro aberto.
- **A paginação** é pedir "os próximos vinte" enquanto ainda restam quatro na mesa. Pedir só quando
  a mesa esvazia deixa você esperando; pedir cedo demais enche o balcão de novo.

---

## 🧪 Exemplo mínimo

Os dois lados, medidos.

> **Arquivo:** `foco_desempenho/lib/features/materias/presentation/lista_grande_screen.dart` (novo)
> **Como executar:** dentro de `foco_desempenho`, `flutter run -d windows`

```dart
import 'package:flutter/material.dart';

import '../domain/materia.dart';
import 'widgets/materia_tile.dart';

/// Três listas com os MESMOS 5 000 itens, para comparar.
///
/// Rode e troque de aba: a diferença é visível a olho nu,
/// sem precisar de ferramenta nenhuma.
class ListaGrandeScreen extends StatelessWidget {
  const ListaGrandeScreen({super.key});

  static final List<Materia> _materias = List<Materia>.generate(
    5000,
    (int i) => Materia(
      id: 'm$i',
      nome: 'Matéria ${i + 1}',
      minutosEstudados: (i * 7) % 300,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('5 000 itens'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'children ❌'),
              Tab(text: 'builder ✅'),
              Tab(text: '+ extent ✅✅'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _ListaRuim(materias: _materias),
            _ListaBoa(materias: _materias),
            _ListaOtima(materias: _materias),
          ],
        ),
      ),
    );
  }
}

/// ❌ Constrói os 5 000 ANTES de mostrar o primeiro.
///
/// A aba congela por ~4 s ao abrir. Toda a memória dos 5 000
/// widgets fica ocupada enquanto a aba existir.
class _ListaRuim extends StatelessWidget {
  const _ListaRuim({required this.materias});

  final List<Materia> materias;

  @override
  Widget build(BuildContext context) {
    // O cronômetro mostra o custo em número, não em sensação.
    final Stopwatch relogio = Stopwatch()..start();

    final List<Widget> filhos = <Widget>[
      for (final Materia m in materias) MateriaTile(materia: m, key: ValueKey<String>(m.id)),
    ];

    relogio.stop();
    debugPrint('❌ children: ${relogio.elapsedMilliseconds} ms para 5 000');

    return ListView(children: filhos);
  }
}

/// ✅ Constrói ~15 — os que cabem na tela.
class _ListaBoa extends StatelessWidget {
  const _ListaBoa({required this.materias});

  final List<Materia> materias;

  @override
  Widget build(BuildContext context) {
    int construidos = 0;

    return ListView.builder(
      itemCount: materias.length,
      itemBuilder: (BuildContext context, int i) {
        construidos++;
        if (construidos % 10 == 0) {
          debugPrint('✅ builder: $construidos construídos até agora');
        }
        return MateriaTile(
          materia: materias[i],
          key: ValueKey<String>(materias[i].id),
        );
      },
    );
  }
}

/// ✅✅ Com itemExtent: arrastar a barra até o fim é instantâneo.
class _ListaOtima extends StatelessWidget {
  const _ListaOtima({required this.materias});

  final List<Materia> materias;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Todos os MateriaTile têm a MESMA altura: 72 px.
      // ⚠️ Se um item precisasse de mais, o conteúdo seria
      // cortado sem aviso nenhum.
      itemExtent: 72,
      itemCount: materias.length,
      itemBuilder: (BuildContext context, int i) => MateriaTile(
        materia: materias[i],
        key: ValueKey<String>(materias[i].id),
      ),
    );
  }
}
```

**O que observar:**

1. A aba **children** congela ao abrir. O `debugPrint` mostra quantos milissegundos.
2. A aba **builder** abre instantaneamente; o contador sobe só conforme você rola.
3. Nas duas primeiras, **arraste a barra de rolagem** até o fim de uma vez. Na terceira, o mesmo
   gesto é instantâneo.

---

## 📱 Aplicando no Flutter

Agora o caso real: lista paginada com capas vindas da rede.

---

## 💻 Código completo

> **Arquivo:** `foco_desempenho/lib/features/materias/presentation/widgets/capa_materia.dart` (novo)

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Capa da matéria, com o consumo de memória sob controle.
///
/// O ponto desta classe é uma linha só: `memCacheWidth`.
/// Sem ela, cada capa de 1200 × 800 ocuparia 3,8 MB de RAM —
/// e 30 capas visíveis matariam o app.
class CapaMateria extends StatelessWidget {
  const CapaMateria({
    required this.url,
    this.tamanho = 56,
    super.key,
  });

  final String? url;

  /// Tamanho de EXIBIÇÃO, em pixels lógicos.
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final String? endereco = url;

    if (endereco == null || endereco.isEmpty) {
      return _Vazia(tamanho: tamanho);
    }

    // O tamanho de DECODIFICAÇÃO é o de exibição × a densidade
    // da tela. Num celular com dpr 3, 56 lógicos = 168 físicos.
    // Menos que isso sai borrado; mais é desperdício.
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final int alvo = (tamanho * dpr).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: endereco,
        width: tamanho,
        height: tamanho,
        fit: BoxFit.cover,

        // ⭐ A linha que importa: decodifica em `alvo`, não no
        // tamanho original do arquivo.
        memCacheWidth: alvo,
        memCacheHeight: alvo,

        // Placeholder do MESMO tamanho da imagem final: sem isso,
        // a lista "pula" quando cada capa chega.
        placeholder: (BuildContext _, String __) => _Esqueleto(tamanho: tamanho),

        // Toda imagem de rede PODE falhar. Sem errorWidget,
        // fica um buraco cinza e uma exceção no console.
        errorWidget: (BuildContext _, String __, Object ___) =>
            _Vazia(tamanho: tamanho, erro: true),

        // Some suavemente em vez de aparecer de supetão.
        fadeInDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

class _Esqueleto extends StatelessWidget {
  const _Esqueleto({required this.tamanho});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _Vazia extends StatelessWidget {
  const _Vazia({required this.tamanho, this.erro = false});

  final double tamanho;
  final bool erro;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: erro ? cores.errorContainer : cores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        erro ? Icons.broken_image_outlined : Icons.menu_book_outlined,
        size: tamanho * 0.5,
        color: erro ? cores.onErrorContainer : cores.onSurfaceVariant,
      ),
    );
  }
}
```

Agora a lista paginada:

> **Arquivo:** `foco_desempenho/lib/features/materias/presentation/lista_paginada_screen.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/materia.dart';
import 'widgets/capa_materia.dart';

// ══════════════════════════════════════════════════════════════════
// Estado da paginação
// ══════════════════════════════════════════════════════════════════

/// O estado precisa de MAIS que a lista de itens.
///
/// `carregandoMais` e `acabou` são o que impede os dois bugs
/// clássicos: buscar a mesma página duas vezes e buscar a
/// página 99 para sempre.
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
      pagina: 0,
      acabou: primeira.length < _porPagina,
    );
  }

  /// Carrega a próxima página, se houver.
  Future<void> carregarMais() async {
    final PaginaMaterias? atual = state.value;

    // ⭐ A TRAVA. O ScrollController dispara este método várias
    // vezes durante a mesma rolagem; sem estas três condições,
    // a página 2 seria buscada quatro vezes e os itens
    // apareceriam duplicados.
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
          // Veio menos que o tamanho da página = era a última.
          acabou: novos.length < _porPagina,
        ),
      );
    } catch (e) {
      // ⚠️ Erro na página 3 NÃO pode apagar as páginas 1 e 2.
      // Por isso o erro vai para dentro do estado, e não
      // vira AsyncError.
      state = AsyncData<PaginaMaterias>(
        atual.copiarCom(carregandoMais: false, erro: e),
      );
    }
  }

  /// Tenta de novo a página que falhou.
  Future<void> tentarDeNovo() async {
    final PaginaMaterias? atual = state.value;
    if (atual == null) return;
    state = AsyncData<PaginaMaterias>(atual.copiarCom(limparErro: true));
    await carregarMais();
  }

  Future<List<Materia>> _buscar(int pagina) async {
    // No app real: repositório → API ou banco.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    const int total = 137;
    final int inicio = pagina * _porPagina;
    if (inicio >= total) return const <Materia>[];

    final int fim = (inicio + _porPagina).clamp(0, total);
    return List<Materia>.generate(
      fim - inicio,
      (int i) => Materia(
        id: 'm${inicio + i}',
        nome: 'Matéria ${inicio + i + 1}',
        minutosEstudados: ((inicio + i) * 13) % 300,
      ),
    );
  }
}

final AsyncNotifierProvider<MateriasPaginadas, PaginaMaterias>
    materiasPaginadasProvider =
    AsyncNotifierProvider<MateriasPaginadas, PaginaMaterias>(
  MateriasPaginadas.new,
);

// ══════════════════════════════════════════════════════════════════
// Tela
// ══════════════════════════════════════════════════════════════════

class ListaPaginadaScreen extends ConsumerStatefulWidget {
  const ListaPaginadaScreen({super.key});

  @override
  ConsumerState<ListaPaginadaScreen> createState() =>
      _ListaPaginadaScreenState();
}

class _ListaPaginadaScreenState extends ConsumerState<ListaPaginadaScreen> {
  final ScrollController _rolagem = ScrollController();

  @override
  void initState() {
    super.initState();
    _rolagem.addListener(_aoRolar);
  }

  @override
  void dispose() {
    // Sem estas duas linhas, o controller vaza — e o teste de
    // widget acusa "A Timer is still pending".
    // Módulo 12, aula 6.
    _rolagem.removeListener(_aoRolar);
    _rolagem.dispose();
    super.dispose();
  }

  void _aoRolar() {
    if (!_rolagem.hasClients) return;

    final double posicao = _rolagem.position.pixels;
    final double maximo = _rolagem.position.maxScrollExtent;

    // ⭐ 80%, não 100%. Buscar só ao chegar ao fim faz o usuário
    // VER o indicador e esperar; a 80% os dados chegam antes.
    if (posicao >= maximo * 0.8) {
      ref.read(materiasPaginadasProvider.notifier).carregarMais();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginaMaterias> estado =
        ref.watch(materiasPaginadasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matérias')),
      body: estado.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) => _Erro(
          mensagem: 'Não foi possível carregar',
          aoTentarDeNovo: () => ref.invalidate(materiasPaginadasProvider),
        ),
        data: (PaginaMaterias pagina) {
          if (pagina.itens.isEmpty) {
            return const Center(child: Text('Nenhuma matéria ainda'));
          }

          return RefreshIndicator.adaptive(
            onRefresh: () async => ref.invalidate(materiasPaginadasProvider),
            child: ListView.builder(
              controller: _rolagem,

              // Mantém um pouco além da tela pronto, para a rolagem
              // rápida não mostrar branco.
              cacheExtent: 500,

              // +1 para o rodapé: indicador, erro ou "fim".
              itemCount: pagina.itens.length + 1,

              itemBuilder: (BuildContext context, int i) {
                if (i == pagina.itens.length) {
                  return _Rodape(pagina: pagina);
                }

                final Materia m = pagina.itens[i];
                return ListTile(
                  // A key preserva o estado ao inserir itens novos
                  // no fim da lista. Aula 1.
                  key: ValueKey<String>(m.id),
                  leading: CapaMateria(
                    url: 'https://picsum.photos/seed/${m.id}/800',
                    tamanho: 56,
                  ),
                  title: Text(m.nome),
                  subtitle: Text('${m.minutosEstudados} min estudados'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Rodapé da lista: um dos três estados finais.
class _Rodape extends ConsumerWidget {
  const _Rodape({required this.pagina});

  final PaginaMaterias pagina;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pagina.erro != null) {
      // Erro no RODAPÉ, não na tela inteira: as páginas que já
      // vieram continuam visíveis.
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const Text('Erro ao carregar mais'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  ref.read(materiasPaginadasProvider.notifier).tentarDeNovo(),
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }

    if (pagina.carregandoMais) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (pagina.acabou) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            '${pagina.itens.length} matérias · fim da lista',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return const SizedBox(height: 80);
  }
}

class _Erro extends StatelessWidget {
  const _Erro({required this.mensagem, required this.aoTentarDeNovo});

  final String mensagem;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 12),
          Text(mensagem),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: aoTentarDeNovo,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}
```

E o `pubspec.yaml`:

```yaml
dependencies:
  cached_network_image: ^3.4.1
```

```powershell
flutter pub add cached_network_image
flutter run -d windows
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `ListView(children:)` vs `.builder` | O primeiro constrói 5 000 widgets antes do primeiro quadro; o segundo, ~15. |
| `Stopwatch` no `_ListaRuim` | Transforma a sensação de lentidão em **número**. |
| `itemExtent: 72` | Arrastar a barra até o fim vira multiplicação em vez de medição. ⚠️ Só com alturas iguais. |
| `cacheExtent: 500` | Constrói além da tela para a rolagem rápida não mostrar branco. |
| `memCacheWidth: alvo` na `CapaMateria` | **A linha mais importante da aula.** Decodifica em 168 px, não em 1200. |
| `MediaQuery.devicePixelRatioOf(context)` | O alvo é exibição × densidade; menos sai borrado, mais é desperdício. |
| `placeholder` do mesmo tamanho | Sem isso, a lista "pula" quando cada capa chega. |
| `errorWidget` | Toda imagem de rede pode falhar; sem ele, buraco cinza e exceção no console. |
| `carregandoMais` + `acabou` no estado | Impedem os dois bugs clássicos: página buscada em duplicidade e busca infinita. |
| `if (atual.carregandoMais \|\| atual.acabou) return;` | **A trava.** O `ScrollController` dispara o método várias vezes por rolagem. |
| `maximo * 0.8` | Buscar a 80% faz os dados chegarem antes de o usuário ver o indicador. |
| `erro` **dentro** de `AsyncData` | Erro na página 3 não pode apagar as páginas 1 e 2. |
| `acabou: novos.length < _porPagina` | Veio menos que o tamanho da página = era a última. |
| `itemCount: itens.length + 1` | O rodapé é o último item: indicador, erro ou "fim da lista". |
| `ValueKey<String>(m.id)` | Preserva estado ao inserir itens novos. Aula 1. |
| `removeListener` + `dispose` | Sem isso, o controller vaza — e o teste acusa Timer pendente. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Limite de memória | Varia: 192 MB a 512 MB por app | Mais generoso, mas mata **sem aviso** |
| App morto por memória | `lowmemorykiller` no logcat | Jetsam report |
| Rolagem | Para no lugar | **Bounce** nas extremidades |
| `RefreshIndicator` | Círculo Material | Use `.adaptive` para o estilo iOS |
| Imagem grande | Lento, depois morre | Morre mais rápido |

```dart
// Rolagem com o comportamento nativo de cada plataforma.
ListView.builder(
  physics: const AlwaysScrollableScrollPhysics(),   // permite puxar mesmo com poucos itens
  …
)
```

> ⚠️ **No iOS o app é encerrado sem nenhuma mensagem no console do Flutter** quando estoura a
> memória. Você vê apenas "Lost connection to device" — o mesmo sintoma de dezenas de outras
> causas. Se isso acontece ao rolar uma lista com imagens, **suspeite de `cacheWidth` faltando
> antes de qualquer outra coisa**. Módulo 12, aula 9.

---

## ⚠️ Erros comuns

### 1. `ListView(children:)` com lista de tamanho variável

Congela ao abrir.

**Correção:** `.builder`, sempre que a quantidade vier de dados.

### 2. Imagem sem `cacheWidth`

Uma foto de 4000 × 3000 ocupa 48 MB.

**Correção:** `cacheWidth: (exibição × dpr).round()`.

### 3. Confundir `width` com `cacheWidth`

```dart
Image.asset('foto.jpg', width: 48)   // ⚠️ ainda decodifica 4000 px
```

**Correção:** `width` é tela; `cacheWidth` é memória. Use os dois.

### 4. `itemExtent` com alturas diferentes

O conteúdo é cortado sem aviso.

**Correção:** `prototypeItem`, ou nada.

### 5. Paginação sem trava

A página 2 é buscada quatro vezes; os itens duplicam.

**Correção:** `if (carregandoMais) return;`.

### 6. Nunca saber que acabou

Busca a página 99 para sempre.

**Correção:** `acabou: novos.length < _porPagina`.

### 7. Erro de página apagando a lista

O usuário perde o que já tinha lido.

**Correção:** erro **dentro** do estado, exibido no rodapé.

### 8. Buscar só ao chegar ao fim

O usuário vê o indicador e espera.

**Correção:** dispare a 80%.

### 9. `Image.network` sem `errorBuilder`

Buraco cinza e exceção no console a cada tentativa.

**Correção:** trate carregando e erro.

### 10. Placeholder de tamanho diferente

A lista "pula" quando as imagens chegam.

**Correção:** mesmas dimensões da imagem final.

### 11. `ScrollController` sem `dispose`

Vazamento; o teste acusa Timer pendente.

**Correção:** `removeListener` + `dispose`.

### 12. `cacheExtent` alto "por precaução"

Troca jank de rolagem por jank de construção.

**Correção:** mexa só depois de medir.

---

## 🛠️ Exercício guiado

**Passo 1.** Crie `lista_grande_screen.dart` e rode. Quantos milissegundos o `debugPrint` mostra?

**Passo 2.** Troque as abas com o DevTools na aba **Memory**. Compare o consumo das três.

**Passo 3.** Arraste a barra de rolagem até o fim nas abas 2 e 3. Sente a diferença?

**Passo 4.** Mude `itemExtent` para 40. O que acontece com o conteúdo?

**Passo 5.** Ponha uma imagem grande (>2 MB) em `assets/imagens/` e exiba em 48 × 48 **sem**
`cacheWidth`. Veja a memória no DevTools.

**Passo 6.** Acrescente `cacheWidth: 96`. Compare os dois números.

**Passo 7.** Crie a lista paginada. Role até o fim: ele diz "137 matérias · fim da lista"?

**Passo 8.** Remova a trava `if (atual.carregandoMais) return;`. Role rápido e conte os itens
duplicados.

**Passo 9.** Faça `_buscar` lançar na página 3. A lista perde as páginas 1 e 2?

**Passo 10.** Mude o gatilho de `0.8` para `1.0`. Role e observe se você **vê** o indicador.

---

## 📝 Exercícios independentes

→ Exercícios completos em
[exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md)

Faça os de **Aplicação** (lista paginada), **Correção de bugs** (paginação sem trava) e
**Diagnóstico** (app morto por memória de imagem).

---

## 🏆 Desafio opcional

Implemente uma **galeria de capas** que aguente 2 000 imagens de rede sem estourar a memória.

Requisitos:

- `GridView.builder` com 3 colunas no celular e 6 no tablet (Módulo 06, aula 11).
- `memCacheWidth` calculado a partir da **largura real da célula**, não de um valor fixo — use
  `LayoutBuilder`.
- Paginação de 40 em 40, com a trava e o estado de fim.
- Limite explícito do cache: `PaintingBinding.instance.imageCache.maximumSizeBytes`.
- Um botão que despeja `imageCache.currentSizeBytes` no console.
- Teste: role 2 000 itens de ponta a ponta e verifique na aba Memory que o consumo **estabiliza**
  em vez de crescer.

Depois responda: por que o consumo estabiliza em vez de crescer para sempre, se as imagens ficam em
cache? O que o `imageCache` faz quando enche? (Dica: pesquise "LRU eviction".)

---

## 📌 Resumo

- **`ListView.builder` sempre que a quantidade vier de dados.** `children:` só para poucos itens
  fixos.
- O `.builder` constrói ~15 itens; `children:` constrói **todos** antes do primeiro quadro.
- **`itemExtent`** torna instantâneo pular para o item 3 000 — ⚠️ só com alturas **iguais**.
- `prototypeItem` quando a altura é uniforme mas desconhecida.
- `cacheExtent` constrói além da tela; o padrão (250) é bom — mexa só depois de medir.
- **O arquivo é comprimido; a memória não.** 4000 × 3000 × 4 bytes = **48 MB**, independente do
  tamanho do JPEG.
- **`width`/`height` são a tela; `cacheWidth`/`cacheHeight` são a memória.** Use os dois.
- O alvo do `cacheWidth` é **exibição × `devicePixelRatio`**.
- `cached_network_image` guarda em **disco**; `Image.network`, só em memória.
- Trate **sempre** carregando e erro; placeholder do **mesmo tamanho**, senão a lista pula.
- Na paginação: **trava** contra chamada dupla, saber quando **acabou**, disparar a **80%**.
- **Erro de página vai no rodapé**, dentro do estado — nunca apaga o que já veio.
- `itemCount + 1` para o rodapé; `ValueKey` nos itens.
- 🍎 No iOS, estourar a memória mata o app **sem mensagem**: só "Lost connection to device".

---

## ☑️ Checklist de domínio

- [ ] Uso `.builder` para toda lista de tamanho variável.
- [ ] Sei quando `itemExtent` ajuda e quando estraga.
- [ ] Calculo a memória de uma imagem pelas dimensões, não pelo arquivo.
- [ ] Uso `cacheWidth`/`memCacheWidth` em toda imagem que exibo menor que o original.
- [ ] Calculo o alvo com o `devicePixelRatio`.
- [ ] Trato carregando e erro em imagem de rede.
- [ ] Meu placeholder tem o tamanho da imagem final.
- [ ] Minha paginação tem trava contra chamada dupla.
- [ ] Minha paginação sabe quando a lista acabou.
- [ ] Disparo a busca antes do fim da rolagem.
- [ ] Erro de página não apaga o que já carreguei.
- [ ] Descarto o `ScrollController` no `dispose`.
- [ ] Sei ver o consumo na aba Memory do DevTools.

---

## 📚 Referências oficiais

- [ListView class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/ListView-class.html)
- [Work with long lists — docs.flutter.dev](https://docs.flutter.dev/cookbook/lists/long-lists)
- [Image class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Image-class.html)
- [ResizeImage — api.flutter.dev](https://api.flutter.dev/flutter/painting/ResizeImage-class.html)
- [ImageCache — api.flutter.dev](https://api.flutter.dev/flutter/painting/ImageCache-class.html)
- [cached_network_image — pub.dev](https://pub.dev/packages/cached_network_image)
- [Performance best practices — docs.flutter.dev](https://docs.flutter.dev/perf/best-practices)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Rebuilds, const e keys](01-rebuilds-const-e-keys.md) | [README](README.md) | [Aula 3 — Assíncrono sem travar](03-assincrono-sem-travar.md) |
