# Aula 11 — Responsividade

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar a diferença entre **`MediaQuery`** (o tamanho da **tela**) e **`LayoutBuilder`** (o
  espaço **disponível para aquele widget**) — e escolher o certo.
- Usar os **pontos de corte** oficiais do Material 3 (*breakpoints*) em vez de números inventados.
- Montar layouts que **quebram linha sozinhos** com `Wrap`.
- Trocar `NavigationBar` por `NavigationRail` conforme a largura, sem duplicar a tela.
- Impedir que o **teclado** cubra o campo que o usuário está digitando.
- Respeitar entalhes, ilhas e barras de gesto com **`SafeArea`** e `MediaQuery.paddingOf`.
- Usar **`FittedBox`** e `textScaler` para não quebrar o layout quando o usuário aumenta a fonte do
  sistema.
- Saber quando **não** vale a pena adaptar.

## ✅ Pré-requisitos

- [Aula 4 — Row, Column e Expanded](04-row-column-expanded.md) — `Wrap` é primo do `Row`.
- [Aula 6 — Constraints](06-constraints.md) — **essencial**: `LayoutBuilder` entrega justamente as
  `BoxConstraints` daquela posição.
- [Aula 9 — Listas e rolagem](09-listas-e-rolagem.md) e
  [Aula 10 — Gestos e feedback](10-gestos-e-feedback.md) — a `MateriasTab` continua de lá.
- [Módulo 05, aula 7 — BuildContext](../05-introducao-ao-flutter/07-buildcontext.md) —
  `MediaQuery.sizeOf` e os irmãos `paddingOf` / `viewInsetsOf`.
- O projeto `foco_ui` rodando: `flutter run -d chrome` ou `-d windows`.

---

## 📖 Conceito

### Responsivo × adaptativo

Dois termos que as pessoas misturam:

| Termo | O que significa | Exemplo |
|---|---|---|
| **Responsivo** | O layout **se ajusta ao tamanho** disponível | 1 coluna no celular, 3 no tablet |
| **Adaptativo** | O app muda de **componente ou comportamento** conforme a plataforma | `Switch` no Android, `CupertinoSwitch` no iOS |

Esta aula é sobre **responsivo**. O adaptativo foi tratado em
[Módulo 05, aula 9](../05-introducao-ao-flutter/09-material-e-cupertino.md).

E por que isso importa em um curso de **mobile**? Porque "mobile" hoje inclui:

- Celular pequeno em pé: 360 × 640
- Celular grande em pé: 430 × 930
- Qualquer celular **deitado**: a altura vira ~400 px
- Celular dobrável aberto: 700 × 840
- Tablet: 800 a 1300 px de largura
- **Teclado aberto**: a altura útil cai pela metade
- **Fonte do sistema em 200%**: seu texto de 14 px vira 28 px

Você não precisa de um tablet para quebrar o seu layout. Basta girar o celular.

### `MediaQuery` × `LayoutBuilder`

Esta é a distinção central da aula.

**`MediaQuery.sizeOf(context)`** devolve o tamanho da **janela inteira**.

```dart
final Size tela = MediaQuery.sizeOf(context);  // ex.: 412 × 915
```

**`LayoutBuilder`** devolve o espaço que **o pai está oferecendo àquele widget**.

```dart
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints restricoes) {
    // restricoes.maxWidth pode ser 180, mesmo numa tela de 1200 px
    return restricoes.maxWidth < 200 ? const Icon(Icons.star) : const Text('Favorito');
  },
)
```

| | `MediaQuery` | `LayoutBuilder` |
|---|---|---|
| Responde | "Qual o tamanho da tela?" | "Quanto espaço **eu** tenho?" |
| Serve para | Decisões de **nível de tela**: 1 coluna ou 2 painéis | Decisões de **nível de componente**: cabe o texto ou só o ícone |
| Dentro de um painel lateral de 300 px | Diz 1200 (a tela toda) ❌ | Diz 300 ✅ |
| Custo | Barato | Reconstrói quando as restrições mudam |

> **Regra prática:** use `MediaQuery` para decidir **a estrutura da tela**; use `LayoutBuilder`
> dentro de um widget que pode ser colocado em lugares de tamanhos diferentes. Um `CartaoMateria`
> que vai tanto numa lista larga quanto numa grade estreita **precisa** de `LayoutBuilder`.

### Os pontos de corte do Material 3

Pare de inventar números. O Material 3 define:

| Nome | Largura | Aparelho típico | Layout recomendado |
|---|---|---|---|
| **Compact** | < 600 px | Celular em pé | 1 coluna, navegação na base |
| **Medium** | 600 – 839 px | Celular deitado, tablet pequeno | 1 coluna larga ou 2, `NavigationRail` |
| **Expanded** | 840 – 1199 px | Tablet, dobrável aberto | 2 painéis, `NavigationRail` |
| **Large** | 1200 – 1599 px | Desktop | 2-3 painéis |
| **Extra-large** | ≥ 1600 px | Monitor grande | Conteúdo com largura máxima |

Na prática, para um app mobile, **dois cortes bastam**: 600 e 840.

```dart
enum TamanhoTela { compacto, medio, expandido }

TamanhoTela tamanhoDe(double largura) {
  if (largura < 600) return TamanhoTela.compacto;
  if (largura < 840) return TamanhoTela.medio;
  return TamanhoTela.expandido;
}
```

> ⚠️ **Nunca decida pela altura** para saber "se é tablet". Um celular deitado tem 400 px de
> altura e 900 de largura. A largura é o que manda.

### `Wrap`: a `Row` que quebra linha

Uma `Row` com muitos filhos estoura:

```text
A RenderFlex overflowed by 148 pixels on the right.
```

Uma `Wrap` simplesmente **desce para a linha de baixo**:

```dart
Wrap(
  spacing: 8,        // espaço horizontal entre os filhos
  runSpacing: 8,     // espaço vertical entre as LINHAS
  children: <Widget>[
    for (final String tag in tags) Chip(label: Text(tag)),
  ],
)
```

É o widget certo para: etiquetas, filtros, botões de ação, listas de opções — qualquer coisa cujo
número você não controla.

| | `Row` | `Wrap` |
|---|---|---|
| Passou da largura | **Estoura** | Quebra linha |
| `Expanded` funciona? | ✅ | ❌ (não existe flex no `Wrap`) |
| Espaço entre filhos | `MainAxisAlignment` ou `SizedBox` | `spacing` / `runSpacing` |
| Custo | Menor | Um pouco maior |

### O teclado

Quando o teclado sobe, a área útil encolhe — e o campo que o usuário está digitando some atrás dele.

O `Scaffold` já ajuda: `resizeToAvoidBottomInset` é `true` por padrão, e ele **encolhe o corpo**
para o teclado caber. Mas isso só funciona se o corpo **puder** encolher:

```dart
// ❌ Column não rola: o conteúdo estoura quando o teclado sobe
body: Column(children: <Widget>[ ...muitos campos... ])

// ✅ ListView rola: o usuário alcança qualquer campo
body: ListView(children: <Widget>[ ...muitos campos... ])
```

Para saber **quanto** o teclado ocupa:

```dart
final double alturaTeclado = MediaQuery.viewInsetsOf(context).bottom;
final bool tecladoAberto = alturaTeclado > 0;
```

Uso mais comum — dar espaço extra embaixo de uma folha com formulário:

```dart
Padding(
  padding: EdgeInsets.only(
    bottom: MediaQuery.viewInsetsOf(context).bottom,
  ),
  child: TextField(...),
)
```

> 📌 Esconder o `FloatingActionButton` quando o teclado está aberto é um detalhe pequeno que faz o
> app parecer caro: `floatingActionButton: tecladoAberto ? null : FloatingActionButton(...)`.

### `SafeArea` e os entalhes

`SafeArea` afasta o conteúdo das regiões que o sistema ocupa: barra de status, entalhe, ilha
dinâmica, barra de gestos.

```dart
SafeArea(
  child: minhaColuna,
)
```

Quando você **não** precisa dela: dentro de um `Scaffold` com `AppBar`, o topo já está protegido —
o `Scaffold` aplica o `SafeArea` por você. Você precisa dela quando:

- Usa `Scaffold` **sem** `AppBar`.
- Coloca conteúdo dentro de um `Stack` posicionado na borda.
- Monta uma folha inferior (`showModalBottomSheet`) — a última opção pode ficar sob a barra de
  gestos do iPhone.

Quando precisar do número cru:

```dart
final double topoSeguro = MediaQuery.paddingOf(context).top;     // barra de status / entalhe
final double baseSegura = MediaQuery.paddingOf(context).bottom;  // barra de gestos
```

> ⚠️ **Nunca escreva `const EdgeInsets.only(top: 24)` "para a barra de status"**. Esse número muda
> em cada aparelho — e em alguns Android com câmera perfurada ele é 40+.

### Fonte do sistema aumentada

Um usuário com baixa visão pode colocar a fonte do sistema em **200%**. Seu `Text` de 14 px vira
28 px e o layout quebra.

```dart
final TextScaler escala = MediaQuery.textScalerOf(context);
```

Duas formas de lidar:

**1. Deixe o layout ser flexível** (o certo, na maioria dos casos): use `Wrap` em vez de `Row`,
`Expanded` no texto, `maxLines` + `overflow: TextOverflow.ellipsis`, e listas roláveis.

**2. `FittedBox`** — encolhe o conteúdo para caber, quando o espaço é mesmo fixo:

```dart
SizedBox(
  height: 40,
  child: FittedBox(
    fit: BoxFit.scaleDown,   // encolhe se precisar, nunca aumenta
    child: Text(valorGrande),
  ),
)
```

> ❌ **Nunca** faça `MediaQuery.withNoTextScaling(...)` nem force `textScaleFactor: 1.0` para
> "consertar" o layout. Isso remove a acessibilidade do usuário para resolver um problema seu.
> Corrija o layout.

---

## 💡 Analogia

Pense numa vitrine de loja.

- **`MediaQuery`** é perguntar **o tamanho da loja**. Serve para decidir se cabe um corredor
  central ou se é loja de corredor único.
- **`LayoutBuilder`** é perguntar **o tamanho daquela prateleira específica**. A loja pode ser
  enorme e a prateleira do canto, estreita. O manequim que você vai pôr ali precisa saber do
  espaço **da prateleira**, não do prédio.
- **`Wrap`** é a arrumação de produtos que, quando acaba o espaço da prateleira, **continua na
  prateleira de baixo** — em vez de empurrar tudo para fora e derrubar no chão (que é o que a
  `Row` faz).
- **O teclado** é uma parede provisória que sobe no meio da loja. Se as prateleiras são fixas,
  metade do estoque some atrás da parede. Se a loja tem um corredor que **rola**, o cliente
  alcança tudo.
- **`SafeArea`** é não colocar mercadoria embaixo da viga estrutural. A viga está lá em todo
  prédio, mas ela fica em alturas diferentes em cada um — por isso você mede, não chuta.
- **A fonte aumentada** é o cliente que precisa que as etiquetas de preço sejam maiores. A solução
  não é imprimir a etiqueta pequena e fingir que ele consegue ler: é ter prateleiras que aceitam
  etiqueta grande.

---

## 🧪 Exemplo mínimo

Este programa mostra `MediaQuery` e `LayoutBuilder` dando respostas **diferentes** ao mesmo tempo.

> **Arquivo:** `foco_ui/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome` — e **redimensione a janela**

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppMedidas());

class AppMedidas extends StatelessWidget {
  const AppMedidas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
      home: const TelaMedidas(),
    );
  }
}

class TelaMedidas extends StatelessWidget {
  const TelaMedidas({super.key});

  @override
  Widget build(BuildContext context) {
    final Size tela = MediaQuery.sizeOf(context);
    final EdgeInsets seguro = MediaQuery.paddingOf(context);
    final double teclado = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Quem mede o quê')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('MediaQuery — a TELA inteira',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('largura: ${tela.width.toInt()} px'),
                Text('altura:  ${tela.height.toInt()} px'),
                Text('topo seguro: ${seguro.top.toInt()} px'),
                Text('base segura: ${seguro.bottom.toInt()} px'),
                Text('teclado: ${teclado.toInt()} px'),
              ],
            ),
          ),
          const Divider(),

          // Dois painéis de larguras diferentes, cada um com seu LayoutBuilder.
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(flex: 1, child: _Painel(cor: Colors.orange.shade100)),
                Expanded(flex: 2, child: _Painel(cor: Colors.orange.shade300)),
              ],
            ),
          ),

          // Um campo, para você ver o teclado agir (no celular).
          const Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(labelText: 'Toque para abrir o teclado'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Painel extends StatelessWidget {
  const _Painel({required this.cor});

  final Color cor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints restricoes) {
        // ESTE número é o do painel, não o da tela.
        final double largura = restricoes.maxWidth;

        return Container(
          color: cor,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('LayoutBuilder', textAlign: TextAlign.center),
              Text('${largura.toInt()} px', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              // Decisão de nível de COMPONENTE.
              if (largura < 150)
                const Icon(Icons.star)
              else
                const Text('Espaço suficiente para o rótulo completo',
                    textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}
```

**O que observar:** o `MediaQuery` lá em cima mostra um número só — a tela. Os dois painéis
mostram números **diferentes entre si** e diferentes do da tela. Redimensione a janela e veja os
três mudarem em ritmos diferentes. É exatamente por isso que os dois existem.

---

## 📱 Aplicando no Flutter

O `foco_ui` vai ganhar um esqueleto responsivo de verdade:

- **< 600 px:** `NavigationBar` na base, lista em 1 coluna.
- **600–839 px:** `NavigationRail` estreito à esquerda, grade de 2 colunas.
- **≥ 840 px:** `NavigationRail` com rótulos, e **dois painéis** — lista à esquerda, detalhe à
  direita.

E tudo isso **sem duplicar as telas**: o conteúdo é o mesmo, muda só o invólucro.

---

## 💻 Código completo

> **Arquivo:** `foco_ui/lib/core/layout/tamanho_tela.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/widgets.dart';

/// Faixas de largura do Material 3.
///
/// Concentrar os pontos de corte aqui impede que cada tela invente o seu
/// próprio número mágico.
enum TamanhoTela {
  /// Celular em pé.
  compacto,

  /// Celular deitado, tablet pequeno.
  medio,

  /// Tablet, dobrável aberto, desktop.
  expandido;

  /// Classifica uma largura em px lógicos.
  static TamanhoTela de(double largura) {
    if (largura < 600) return TamanhoTela.compacto;
    if (largura < 840) return TamanhoTela.medio;
    return TamanhoTela.expandido;
  }

  /// Atalho a partir do context, para uso direto no build.
  static TamanhoTela doContext(BuildContext context) =>
      de(MediaQuery.sizeOf(context).width);

  bool get ehCompacto => this == TamanhoTela.compacto;
  bool get temPainelLateral => this == TamanhoTela.expandido;
}
```

> **Arquivo:** `foco_ui/lib/core/layout/esqueleto_app.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'package:foco_ui/core/layout/tamanho_tela.dart';

/// Um destino de navegação do app.
class DestinoApp {
  const DestinoApp({
    required this.rotulo,
    required this.icone,
    required this.iconeSelecionado,
  });

  final String rotulo;
  final IconData icone;
  final IconData iconeSelecionado;
}

/// Esqueleto responsivo: decide ONDE fica a navegação conforme a largura.
///
/// O conteúdo é sempre o mesmo widget — o que muda é só o invólucro.
/// Isso evita a armadilha de manter duas versões da mesma tela.
class EsqueletoApp extends StatelessWidget {
  const EsqueletoApp({
    super.key,
    required this.destinos,
    required this.indiceSelecionado,
    required this.onSelecionar,
    required this.corpo,
    this.painelLateral,
  });

  final List<DestinoApp> destinos;
  final int indiceSelecionado;
  final ValueChanged<int> onSelecionar;

  /// Conteúdo principal, idêntico em todas as larguras.
  final Widget corpo;

  /// Painel de detalhe. Só é mostrado na faixa "expandido";
  /// nas outras, vira uma tela empilhada (Módulo 07).
  final Widget? painelLateral;

  @override
  Widget build(BuildContext context) {
    final TamanhoTela tamanho = TamanhoTela.doContext(context);

    // ── Compacto: navegação na base ───────────────────────────────────────
    if (tamanho.ehCompacto) {
      return Scaffold(
        body: corpo,
        bottomNavigationBar: NavigationBar(
          selectedIndex: indiceSelecionado,
          onDestinationSelected: onSelecionar,
          destinations: <Widget>[
            for (final DestinoApp d in destinos)
              NavigationDestination(
                icon: Icon(d.icone),
                selectedIcon: Icon(d.iconeSelecionado),
                label: d.rotulo,
              ),
          ],
        ),
      );
    }

    // ── Médio e expandido: trilho lateral ─────────────────────────────────
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: indiceSelecionado,
            onDestinationSelected: onSelecionar,
            // Rótulos visíveis só quando há espaço de sobra.
            labelType: tamanho.temPainelLateral
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected,
            extended: tamanho.temPainelLateral,
            destinations: <NavigationRailDestination>[
              for (final DestinoApp d in destinos)
                NavigationRailDestination(
                  icon: Icon(d.icone),
                  selectedIcon: Icon(d.iconeSelecionado),
                  label: Text(d.rotulo),
                ),
            ],
          ),
          const VerticalDivider(width: 1),

          // O corpo ocupa o que sobrou.
          Expanded(flex: 2, child: corpo),

          // O painel de detalhe só existe na faixa mais larga.
          if (tamanho.temPainelLateral && painelLateral != null) ...<Widget>[
            const VerticalDivider(width: 1),
            Expanded(flex: 3, child: painelLateral!),
          ],
        ],
      ),
    );
  }
}
```

Agora uma barra de filtros que quebra linha sozinha:

> **Arquivo:** `foco_ui/lib/features/materias/presentation/widgets/filtros_materias.dart` (novo)

```dart
import 'package:flutter/material.dart';

/// Filtros em forma de chips. Usa Wrap para nunca estourar,
/// em nenhuma largura e com qualquer tamanho de fonte.
class FiltrosMaterias extends StatelessWidget {
  const FiltrosMaterias({
    super.key,
    required this.filtros,
    required this.selecionados,
    required this.onAlternar,
  });

  final List<String> filtros;
  final Set<String> selecionados;
  final ValueChanged<String> onAlternar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,     // entre os chips da mesma linha
        runSpacing: 8,  // entre as linhas, quando quebra
        children: <Widget>[
          for (final String filtro in filtros)
            FilterChip(
              label: Text(filtro),
              selected: selecionados.contains(filtro),
              onSelected: (_) => onAlternar(filtro),
            ),
        ],
      ),
    );
  }
}
```

E o cartão da grade passa a se adaptar ao **próprio espaço**, não ao da tela:

> **Arquivo:** `foco_ui/lib/features/materias/presentation/widgets/cartao_adaptavel.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'package:foco_ui/features/materias/domain/materia.dart';

/// Cartão que muda de forma conforme o espaço que RECEBE.
///
/// Este widget vai tanto numa grade estreita quanto num painel largo —
/// por isso ele consulta o LayoutBuilder, e não o MediaQuery.
class CartaoAdaptavel extends StatelessWidget {
  const CartaoAdaptavel({
    super.key,
    required this.materia,
    required this.onTap,
  });

  final Materia materia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme tipografia = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints restricoes) {
            // A decisão é sobre O CARTÃO, não sobre a tela.
            final bool estreito = restricoes.maxWidth < 180;

            return Padding(
              padding: EdgeInsets.all(estreito ? 8 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(materia.icone,
                          size: estreito ? 18 : 24, color: cores.primary),
                      const SizedBox(width: 8),
                      // Expanded impede overflow quando a fonte aumenta.
                      Expanded(
                        child: Text(
                          materia.nome,
                          style: estreito
                              ? tipografia.bodyMedium
                              : tipografia.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  LinearProgressIndicator(
                    value: materia.progresso,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 6),
                  // Só cabe a legenda completa quando há largura.
                  Text(
                    estreito
                        ? '${(materia.progresso * 100).round()}%'
                        : '${materia.minutosEstudados} de '
                            '${materia.metaMinutos} min '
                            '(${(materia.progresso * 100).round()}%)',
                    style: tipografia.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

E a tela principal amarra tudo:

> **Arquivo:** `foco_ui/lib/main.dart` (substitua o `home:`)

```dart
import 'package:flutter/material.dart';

import 'package:foco_ui/core/layout/esqueleto_app.dart';
import 'package:foco_ui/features/materias/presentation/materias_tab.dart';

void main() => runApp(const FocoUiApp());

class FocoUiApp extends StatelessWidget {
  const FocoUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: const CascaApp(),
    );
  }
}

class CascaApp extends StatefulWidget {
  const CascaApp({super.key});

  @override
  State<CascaApp> createState() => _CascaAppState();
}

class _CascaAppState extends State<CascaApp> {
  int _indice = 0;

  static const List<DestinoApp> _destinos = <DestinoApp>[
    DestinoApp(
      rotulo: 'Matérias',
      icone: Icons.menu_book_outlined,
      iconeSelecionado: Icons.menu_book,
    ),
    DestinoApp(
      rotulo: 'Hoje',
      icone: Icons.today_outlined,
      iconeSelecionado: Icons.today,
    ),
    DestinoApp(
      rotulo: 'Ajustes',
      icone: Icons.settings_outlined,
      iconeSelecionado: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return EsqueletoApp(
      destinos: _destinos,
      indiceSelecionado: _indice,
      onSelecionar: (int i) => setState(() => _indice = i),
      corpo: switch (_indice) {
        0 => const MateriasTab(),
        1 => const Center(child: Text('Hoje — Módulo 07')),
        _ => const Center(child: Text('Ajustes — Módulo 07')),
      },
      painelLateral: const Center(
        child: Text('Selecione uma matéria para ver o detalhe'),
      ),
    );
  }
}
```

Rode e **redimensione a janela devagar**, da mais estreita para a mais larga:

```powershell
flutter analyze
flutter run -d chrome
```

Você deve ver, nesta ordem:

1. **< 600 px** → barra de navegação **na base**.
2. **600 px** → a barra some, aparece um **trilho estreito** à esquerda.
3. **840 px** → o trilho **ganha rótulos** e um **painel de detalhe** surge à direita.

Três layouts, **uma** implementação de conteúdo.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `enum TamanhoTela` com método estático `de(double)` | Os pontos de corte ficam em **um lugar só**. Mudar a régua do app é mudar um arquivo. |
| `TamanhoTela.doContext(context)` | Açúcar para `de(MediaQuery.sizeOf(context).width)`. Usa `sizeOf` (não `.of(context).size`) para não reconstruir quando o teclado abre. |
| `bool get ehCompacto` / `temPainelLateral` | Nomes com **significado de produto**, não de medida. O `build` lê "tem painel lateral?", não "é maior que 840?". |
| `EsqueletoApp` recebendo `corpo` como `Widget` | **Composição.** O esqueleto não sabe o que é o conteúdo — por isso as três telas do app reaproveitam ele sem nenhum `if`. |
| `NavigationBar` × `NavigationRail` | Componentes diferentes do Material 3 para a mesma função. O `Rail` na lateral aproveita a largura; a `Bar` na base aproveita o alcance do polegar. |
| `extended: tamanho.temPainelLateral` | O trilho estendido mostra rótulo ao lado do ícone. Só faz sentido quando sobra largura. |
| `if (tamanho.temPainelLateral && painelLateral != null) ...<Widget>[...]` | *Spread* condicional: os widgets só entram na lista se a condição valer. Visto no [Módulo 02](../02-dart-basico/08-listas.md). |
| `Expanded(flex: 2)` e `Expanded(flex: 3)` | Proporção 2:3 entre lista e detalhe. Números, não pixels — funciona em qualquer largura. |
| `Wrap(spacing: 8, runSpacing: 8)` | `spacing` é entre filhos da mesma linha; `runSpacing` é entre as linhas. Confundir os dois é erro comum. |
| `LayoutBuilder` dentro do `CartaoAdaptavel` | O cartão vai para grades e painéis de larguras diferentes. Ele precisa saber do **próprio espaço** — `MediaQuery` daria a resposta errada. |
| `Expanded` em volta do `Text` dentro do `Row` | Garante que o nome encolha em vez de estourar quando a fonte do sistema aumenta. |
| `maxLines: 1, overflow: TextOverflow.ellipsis` | Em **todo** texto de largura incerta. É a diferença entre `Banco de da…` e uma faixa amarela de overflow. |
| `switch (_indice) { 0 => …, _ => … }` | *Switch expression* do Dart 3 devolvendo o widget do corpo. Sem `if/else` aninhado. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Barra de status | 24 a 48 px, conforme a câmera perfurada | 44 a 59 px, conforme entalhe / ilha dinâmica |
| Base da tela | 0 px, ou ~24 px com navegação por gestos | ~34 px de barra de gestos, sempre em aparelhos sem botão |
| `MediaQuery.paddingOf(context)` | Reflete o recorte da câmera | Reflete entalhe e ilha dinâmica |
| Teclado | Altura varia muito (teclados de terceiros) | Altura previsível + barra de sugestões |
| Girar a tela | Quase sempre permitido | Quase sempre permitido; iPad tem multitarefa com **janelas redimensionáveis** |
| Tablets | Tamanhos muito variados | iPad tem larguras conhecidas — e *Split View*, que **muda a largura do seu app em tempo real** |

> 📌 O *Split View* do iPad é o argumento definitivo contra "detectar tablet uma vez e guardar". A
> largura do seu app pode mudar **enquanto ele roda**, sem rotação. `MediaQuery` e `LayoutBuilder`
> já reconstroem sozinhos; uma variável guardada no `initState` não.

---

## ⚠️ Erros comuns

### 1. Usar `MediaQuery` para decisão de componente

```dart
// dentro de um cartão que está num painel de 200 px, numa tela de 1200
final bool largo = MediaQuery.sizeOf(context).width > 600; // ❌ diz "largo"
```

O cartão tem 200 px, mas acha que tem 1200.

**Correção:** `LayoutBuilder`.

### 2. Decidir pela altura

```dart
final bool ehTablet = MediaQuery.sizeOf(context).height > 900; // ❌
```

Um celular deitado tem 400 px de altura; um tablet em pé tem 1024. Isso classifica errado os dois.

**Correção:** decida pela **largura**.

### 3. `Row` onde deveria haver `Wrap`

```text
A RenderFlex overflowed by 148 pixels on the right.
```

Chips, etiquetas e botões cujo número você não controla **sempre** estouram uma `Row`.

**Correção:** `Wrap`. (Ou `Expanded` em cada filho, se eles devem dividir a linha.)

### 4. `Column` com muitos campos e teclado aberto

```text
A RenderFlex overflowed by 210 pixels on the bottom.
```

O `Scaffold` encolheu o corpo para o teclado caber, e a `Column` não tem para onde encolher.

**Correção:** troque por `ListView`, ou envolva em `SingleChildScrollView`.

### 5. Número fixo para a barra de status

```dart
const Padding(padding: EdgeInsets.only(top: 24)) // ❌
```

**Correção:** `SafeArea`, ou `MediaQuery.paddingOf(context).top`.

### 6. `SafeArea` dentro de `Scaffold` com `AppBar`

```dart
Scaffold(
  appBar: AppBar(title: const Text('Oi')),
  body: SafeArea(child: conteudo), // ⚠️ padding duplicado no topo
)
```

O `Scaffold` já protegeu o topo. O `SafeArea` acrescenta o espaço de novo.

**Correção:** `SafeArea(top: false, child: conteudo)` — ou simplesmente remova.

### 7. Remover o `textScaler` para "consertar" o layout

```dart
MediaQuery.withNoTextScaling(child: minhaTela) // ❌
```

Isso desfaz a configuração de acessibilidade do usuário. O layout "conserta" à custa de quem
precisa de fonte grande.

**Correção:** torne o layout flexível (`Wrap`, `Expanded`, `maxLines`, rolagem) ou use `FittedBox`
onde o espaço é mesmo fixo.

### 8. Guardar o tamanho da tela no `initState`

```dart
@override
void initState() {
  super.initState();
  _largura = MediaQuery.sizeOf(context).width; // ❌ e ainda quebra: .of no initState
}
```

Dois erros: `.of(context)` no `initState` lança exceção (visto no
[Módulo 05, aula 7](../05-introducao-ao-flutter/07-buildcontext.md)), e o valor **não acompanha**
rotação, redimensionamento ou Split View.

**Correção:** leia no `build`, sempre.

### 9. Esconder conteúdo no celular em vez de reorganizar

```dart
if (compacto) return const SizedBox.shrink(); // ❌ o usuário perdeu a função
```

Responsivo é **reorganizar**, não **amputar**. Se a informação importa no tablet, ela importa no
celular — em outro lugar: uma aba, uma folha inferior, uma tela empilhada.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter run -d chrome` e redimensione a janela lentamente de ~400 px até
~1400 px. Anote **em que larguras exatas** o layout muda. Confira se batem com 600 e 840.

**Passo 2.** Em `TamanhoTela.de`, troque `600` por `500` e `840` por `1000`. Rode e redimensione de
novo. Você mexeu em **quantos arquivos** para mudar o comportamento do app inteiro? Depois desfaça.

**Passo 3.** No `CartaoAdaptavel`, troque o `LayoutBuilder` por
`MediaQuery.sizeOf(context).width < 180`. Rode em janela larga com a grade ativada. O que acontece
com os cartões estreitos? Explique por escrito e depois desfaça.

**Passo 4.** Troque o `Wrap` de `FiltrosMaterias` por `Row`. Acrescente 8 filtros. Rode em janela
estreita e leia o erro. Depois volte para `Wrap`.

**Passo 5.** No `FiltrosMaterias`, troque `runSpacing: 8` por `runSpacing: 24` e `spacing: 8` por
`spacing: 0`. Rode e descreva com precisão o que cada um controla.

**Passo 6.** Nas configurações do Chrome (ou do Windows), aumente o tamanho da fonte para 200%.
Rode o app. Anote **quais** widgets quebraram. Corrija cada um com `Expanded`, `maxLines` ou
`Wrap` — nunca desligando o `textScaler`.

**Passo 7.** Acrescente um `TextField` no topo da `MateriasTab`, dentro de uma `Column` com a lista
abaixo (sem `Expanded`). Rode em celular ou emulador, toque no campo e observe o erro. Corrija.

**Passo 8.** Responda por escrito: por que o `EsqueletoApp` recebe o conteúdo como parâmetro em vez
de ter um `if` interno escolhendo entre `MateriasTabCompacta` e `MateriasTabLarga`?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Faça os exercícios de **Aplicação** com `LayoutBuilder` e `Wrap`, o de **Correção de bugs** com o
teclado cobrindo o campo, e o de **Decisão** sobre `MediaQuery` × `LayoutBuilder`.

---

## 🏆 Desafio opcional

Faça o painel de detalhe funcionar de verdade nas **três** faixas, sem duplicar a tela de detalhe:

- **Expandido:** a matéria selecionada aparece no painel à direita.
- **Médio e compacto:** tocar na matéria **empilha** uma tela nova com o mesmo widget de detalhe.

Requisitos:

- O widget `DetalheMateria` é **um só**, usado nos dois caminhos.
- Ao redimensionar a janela de estreita para larga **com a tela de detalhe aberta**, o app não pode
  quebrar nem mostrar a mesma matéria duas vezes.

Dica: guarde a `Materia? _selecionada` no `_CascaAppState` e decida no `build` se ela vira painel
ou empilhamento. Empilhar é assunto do
[Módulo 07, aula 1](../07-navegacao-e-formularios/01-navigator-a-pilha.md) — vale adiantar a
leitura.

Depois responda: quantas cópias do layout de detalhe existem no seu código? Se for mais de uma,
tente de novo — porque manter duas cópias sincronizadas é exatamente o custo que este desafio
existe para evitar.

---

## 📌 Resumo

- **Responsivo** = se ajusta ao **tamanho**. **Adaptativo** = muda conforme a **plataforma**. Esta
  aula é sobre o primeiro.
- **`MediaQuery`** responde "qual o tamanho da tela"; **`LayoutBuilder`** responde "quanto espaço
  **eu** tenho". Use `MediaQuery` para a estrutura da tela e `LayoutBuilder` dentro de componentes
  reutilizáveis.
- Pontos de corte do Material 3: **600** e **840** px de **largura**. Nunca decida pela altura.
- Centralize os pontos de corte em um `enum` — mudar a régua do app vira mudar um arquivo.
- **`Wrap`** é a `Row` que quebra linha. Use sempre que o número de filhos não for controlado por
  você. `spacing` = entre filhos; `runSpacing` = entre linhas.
- O `Scaffold` encolhe o corpo quando o teclado sobe — mas só funciona se o corpo **puder** rolar.
  `Column` estoura; `ListView` resolve.
- `MediaQuery.viewInsetsOf(context).bottom` é a altura do teclado.
- **`SafeArea`** para entalhes e barra de gestos. Já vem aplicado no topo quando há `AppBar` —
  nesse caso use `SafeArea(top: false, ...)`.
- **Nunca** escreva números fixos para barra de status ou barra de gestos.
- **Nunca** desligue o `textScaler`. Torne o layout flexível ou use `FittedBox`.
- Nunca leia tamanho no `initState` — leia no `build`, porque a largura muda em tempo real
  (rotação, Split View do iPad, janela de desktop).
- Responsivo é **reorganizar**, nunca **esconder** função.
- O melhor teste de responsividade é gratuito: **redimensione a janela do Chrome devagar**.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre responsivo e adaptativo.
- [ ] Escolho entre `MediaQuery` e `LayoutBuilder` e justifico a escolha.
- [ ] Uso 600 e 840 px como pontos de corte, centralizados em um `enum`.
- [ ] Decido pela **largura**, nunca pela altura.
- [ ] Uso `Wrap` em toda coleção de chips, etiquetas ou botões de tamanho variável.
- [ ] Sei a diferença entre `spacing` e `runSpacing`.
- [ ] Meus formulários rolam, e o teclado nunca cobre o campo em foco.
- [ ] Uso `SafeArea` onde falta e evito o padding duplo onde já existe `AppBar`.
- [ ] Nunca escrevo número fixo para barra de status ou de gestos.
- [ ] Testei o app com a fonte do sistema em 200% e corrigi o layout, não a acessibilidade.
- [ ] Troco `NavigationBar` por `NavigationRail` sem duplicar a tela.
- [ ] Meu conteúdo é **um widget só**, usado em todas as larguras.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Adaptive and responsive design in Flutter — docs.flutter.dev](https://docs.flutter.dev/ui/adaptive-responsive)
- [LayoutBuilder class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)
- [MediaQuery class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)
- [Wrap class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Wrap-class.html)
- [SafeArea class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/SafeArea-class.html)
- [NavigationRail class — api.flutter.dev](https://api.flutter.dev/flutter/material/NavigationRail-class.html)
- [Material 3 layout — m3.material.io](https://m3.material.io/foundations/layout/applying-layout/window-size-classes)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 10 — Gestos e feedback](10-gestos-e-feedback.md) | [README](README.md) | [Aula 12 — Estados de UI](12-estados-de-ui.md) |
