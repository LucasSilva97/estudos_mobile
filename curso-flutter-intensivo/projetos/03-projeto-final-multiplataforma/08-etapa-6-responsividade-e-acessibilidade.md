# Etapa 6 — Responsividade e acessibilidade — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 90 min · **Depende de:** [Etapa 5 — API e trilhas](07-etapa-5-api-e-trilhas.md) ·
> **Aulas:** [M06 · 11 Responsividade](../../modulos/06-widgets-e-layouts/11-responsividade.md) ·
> [M06 · 07 Cores e temas](../../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) ·
> [M13 · 05 Acessibilidade](../../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

O app já funciona. Agora ele precisa funcionar **para quem segura o celular com uma mão no ônibus,
para quem usa a fonte do sistema em 200% e para quem não vê a tela** — o RNF01 ao RNF04 e o RNF18
da [especificação](01-especificacao.md).

---

## 🎯 O que existe ao fim desta etapa

| Antes | Depois |
|---|---|
| `NavigationBar` na base em qualquer largura | Barra abaixo de 600 dp, `NavigationRail` acima — **a mesma tela**, invólucro diferente |
| Lista de matérias sempre em 1 coluna | 1 coluna no celular, **2 colunas** a partir de 600 dp (RNF18) |
| `IconButton` sem `tooltip` | Todo botão só-ícone com `tooltip` — que é também o rótulo do leitor de tela (RNF04) |
| Estatísticas sem gráfico | `BarrasDaSemana`: `CustomPaint` com **um nó de semântica por dia** |

> 📌 **RNF08.** O Foco não carrega imagem nenhuma. Se acrescentar uma nos desafios, passe
> `cacheWidth` — nada é decodificado no tamanho original.

---

## 📦 Dependências

**Nenhuma dependência nova**, e isso é intencional: `NavigationRail`, `MediaQuery.sizeOf`,
`LayoutBuilder`, `SafeArea`, `Semantics` e `CustomPaint` vêm do `package:flutter/material.dart`;
`SemanticsService.announce` vem de `package:flutter/semantics.dart`.

> ⚠️ Pacotes de "responsividade" (`responsive_framework`, `sizer`) resolvem com dependência um
> problema que o SDK resolve com dois `if`.

---

## 🧩 Os arquivos desta etapa

| Arquivo | Papel |
|---|---|
| `lib/core/layout/quebras.dart` | 🆕 Os cortes 600 / 900 dp e a grade que nasce deles |
| `lib/features/inicio/presentation/inicio_screen.dart` | ♻️ `NavigationBar` ↔ `NavigationRail`, `tooltip` e anúncio de aba |
| `lib/features/estatisticas/presentation/widgets/barras_da_semana.dart` | 🆕 `CustomPaint` com semântica por dia |

---

### lib/core/layout/quebras.dart

> **Por que ele existe:** para nenhuma tela inventar o próprio número mágico — quando o corte muda,
> muda em um arquivo.

```dart
import 'package:flutter/material.dart';

/// Faixas de largura do Foco, na linha dos cortes do Material 3.
enum FaixaDeLargura {
  compacta, // < 600 dp: celular em pé
  media, // 600 a 899 dp: celular deitado, tablet pequeno
  expandida; // >= 900 dp: tablet, dobrável aberto, desktop

  bool get ehCompacta => this == FaixaDeLargura.compacta;
  bool get temTrilho => this != FaixaDeLargura.compacta;
  bool get trilhoEstendido => this == FaixaDeLargura.expandida;

  /// RNF18: uma coluna no celular, duas a partir de 600 dp.
  int get colunas => ehCompacta ? 1 : 2;
}

/// O Material 3 corta "expanded" em 840 dp; o Foco sobe para 900, que é onde o
/// trilho estendido para de espremer o conteúdo.
abstract final class Quebras {
  static const double media = 600;
  static const double expandida = 900;

  /// Alvo mínimo de toque, em dp (RNF02).
  static const double alvoMinimo = 48;

  static FaixaDeLargura de(double largura) {
    if (largura < media) return FaixaDeLargura.compacta;
    if (largura < expandida) return FaixaDeLargura.media;
    return FaixaDeLargura.expandida;
  }

  /// ⚠️ Decida sempre pela LARGURA: um celular deitado tem 400 dp de altura e
  /// 900 de largura — pela altura, ele viraria "tablet".
  static FaixaDeLargura doContext(BuildContext context) =>
      de(MediaQuery.sizeOf(context).width);
}

/// Lista que vira grade conforme o espaço DISPONÍVEL — não o da tela.
class GradeDeCartoes extends StatelessWidget {
  const GradeDeCartoes({
    super.key,
    required this.quantidade,
    required this.construirItem,
    this.padding = const EdgeInsets.fromLTRB(8, 8, 8, 96),
  });

  final int quantidade;
  final Widget Function(BuildContext context, int indice) construirItem;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder, e não MediaQuery: com o trilho aberto sobram ~250 dp a
    // menos que a tela. Quem decide as colunas é o espaço DESTE widget.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints restricoes) {
        final int colunas = Quebras.de(restricoes.maxWidth).colunas;
        final int linhas = (quantidade + colunas - 1) ~/ colunas;

        // ⚠️ Sem GridView de propósito: childAspectRatio é altura disfarçada e
        // corta o texto a 200% de fonte. Aqui a altura vem do conteúdo.
        return ListView.builder(
          padding: padding,
          itemCount: linhas,
          itemBuilder: (BuildContext context, int linha) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int coluna = 0; coluna < colunas; coluna++)
                Expanded(
                  child: linha * colunas + coluna < quantidade
                      ? Padding(
                          padding: const EdgeInsets.all(4),
                          child:
                              construirItem(context, linha * colunas + coluna),
                        )
                      // Buraco da última linha ímpar.
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        );
      },
    );
  }
}
```

> 📌 **Adoção.** Na `MateriasTab` e na `TrilhasTab` os quatro estados continuam iguais: só o ramo
> `data` troca `ListView.builder` por `GradeDeCartoes(quantidade: lista.length, construirItem:
> (BuildContext _, int i) => MateriaTile(key: ValueKey<String>(lista[i].id), ...))`.

---

### lib/features/inicio/presentation/inicio_screen.dart

> **Por que ele existe:** é a casca das três abas — e o único lugar do app onde a navegação troca
> de forma conforme a largura.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:foco/core/layout/quebras.dart';
import 'package:foco/core/rotas/rotas.dart';
import 'package:foco/features/inicio/presentation/painel_tab.dart';
import 'package:foco/features/materias/presentation/materias_tab.dart';
import 'package:foco/features/trilhas/presentation/trilhas_tab.dart';

/// Tela 1 — rota `/`. Casca com as três abas (RF01).
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  static const List<String> _rotulos = <String>['Painel', 'Matérias', 'Trilhas'];
  static const List<IconData> _icones = <IconData>[
    Icons.dashboard_outlined,
    Icons.menu_book_outlined,
    Icons.explore_outlined,
  ];

  int _aba = 0;

  void _selecionar(int indice) {
    if (indice == _aba) return;
    setState(() => _aba = indice);

    // Trocar de aba não move o foco do leitor de tela: sem o anúncio, quem usa
    // TalkBack continua ouvindo a aba antiga e acha que o toque falhou.
    SemanticsService.announce(
      '${_rotulos[indice]} selecionado',
      Directionality.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FaixaDeLargura faixa = Quebras.doContext(context);

    // IndexedStack mantém as três abas vivas: a rolagem e o estado de cada uma
    // sobrevivem à troca e à volta de /estatisticas (RF01).
    final Widget conteudo = IndexedStack(
      index: _aba,
      children: const <Widget>[PainelTab(), MateriasTab(), TrilhasTab()],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foco'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            // O tooltip é o rótulo que o leitor de tela lê. Botão só-ícone sem
            // tooltip é anunciado como "botão" e mais nada (RNF04).
            tooltip: 'Estatísticas da semana',
            onPressed: () => Navigator.of(context).pushNamed(Rotas.estatisticas),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () =>
                Navigator.of(context).pushNamed(Rotas.configuracoes),
          ),
        ],
      ),
      // ⚠️ top: false. O Scaffold com AppBar já protegeu o topo; um SafeArea
      // completo somaria a barra de status duas vezes.
      body: faixa.temTrilho
          ? SafeArea(
              top: false,
              child: Row(
                children: <Widget>[
                  NavigationRail(
                    selectedIndex: _aba,
                    onDestinationSelected: _selecionar,
                    extended: faixa.trilhoEstendido,
                    // ⚠️ Com extended: true o labelType PRECISA ser nulo — há
                    // um assert no NavigationRail exatamente para isso.
                    labelType: faixa.trilhoEstendido
                        ? null
                        : NavigationRailLabelType.all,
                    destinations: <NavigationRailDestination>[
                      for (int i = 0; i < _rotulos.length; i++)
                        NavigationRailDestination(
                          icon: Icon(_icones[i]),
                          label: Text(_rotulos[i]),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: conteudo),
                ],
              ),
            )
          : conteudo,
      bottomNavigationBar: faixa.temTrilho
          ? null
          : NavigationBar(
              selectedIndex: _aba,
              onDestinationSelected: _selecionar,
              destinations: <Widget>[
                for (int i = 0; i < _rotulos.length; i++)
                  NavigationDestination(
                    icon: Icon(_icones[i]),
                    label: _rotulos[i],
                  ),
              ],
            ),
    );
  }
}
```

---

### lib/features/estatisticas/presentation/widgets/barras_da_semana.dart

> **Por que ele existe:** é o gráfico do RF16 — e a prova de que `CustomPaint` não precisa ser um
> buraco negro de acessibilidade.

```dart
import 'package:flutter/material.dart';

import 'package:foco/features/estatisticas/domain/resumo_semanal.dart';

/// Sete barras, segunda a domingo, com um nó de semântica por dia.
class BarrasDaSemana extends StatelessWidget {
  const BarrasDaSemana({super.key, required this.resumo});

  final ResumoSemanal resumo;

  static const List<String> _siglas = <String>[
    'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom',
  ];
  static const List<String> _nomes = <String>[
    'segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira',
    'sexta-feira', 'sábado', 'domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final int maior = resumo.minutosPorDia
        .fold<int>(0, (int maximo, int m) => m > maximo ? m : maximo);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          // Altura fixa aceitável: aqui dentro não há texto para cortar.
          height: 140,
          child: Stack(
            children: <Widget>[
              // A pintura é decoração; a informação vive nos nós de cima.
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _PintorDasBarras(
                      minutos: resumo.minutosPorDia,
                      maior: maior,
                      cor: tema.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  for (int dia = 0; dia < 7; dia++)
                    Expanded(
                      child: Semantics(
                        label: _nomes[dia],
                        value: '${resumo.minutosPorDia[dia]} minutos',
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            for (final String sigla in _siglas)
              Expanded(
                // A sigla já foi anunciada por extenso na barra de cima.
                child: ExcludeSemantics(
                  child: Text(
                    sigla,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodySmall
                        ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PintorDasBarras extends CustomPainter {
  const _PintorDasBarras({
    required this.minutos,
    required this.maior,
    required this.cor,
  });

  final List<int> minutos;
  final int maior;
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    // Semana sem sessão nenhuma: nada a pintar, e sem dividir por zero.
    if (maior <= 0) return;

    final double faixa = size.width / 7;
    final double largura = faixa * 0.55;
    final Paint pincel = Paint()..color = cor;

    for (int dia = 0; dia < 7; dia++) {
      final double alta = size.height * (minutos[dia] / maior);
      if (alta <= 0) continue;
      final double x = faixa * dia + (faixa - largura) / 2;

      canvas.drawRRect(
        RRect.fromLTRBR(
          x, size.height - alta, x + largura, size.height,
          const Radius.circular(6),
        ),
        pincel,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorDasBarras anterior) =>
      anterior.maior != maior ||
      anterior.cor != cor ||
      !listEquals(anterior.minutos, minutos);
}
```

> 📌 Na `EstatisticasScreen` (etapa 4), troque o espaço reservado do gráfico por
> `BarrasDaSemana(resumo: resumo)`. É a única linha que muda lá.

---

### Pente fino nos widgets da etapa 4

> **Por que não é um arquivo inteiro aqui:** estes já existem. A mudança é pequena, sempre a mesma,
> e você aplica em minutos.

| Arquivo | O que muda |
|---|---|
| `widgets/materia_tile.dart` | `MergeSemantics` no item; `ExcludeSemantics` na inicial do `CircleAvatar`, que só repete o nome; `ConstrainedBox(minHeight: Quebras.alvoMinimo + 24)` no lugar de qualquer `height`; subtítulo em `colorScheme.onSurfaceVariant` |
| Cor de matéria, onde aparecer | Só como **fundo** de `CircleAvatar`; a inicial por cima escolhe branco ou preto com `ThemeData.estimateBrightnessForColor(cor)` (RNF01) |
| `cronometro_card.dart`, `sessao_tile.dart` | `tooltip` em todo `IconButton`, dizendo o **resultado** ("Pausar o cronômetro"); `SemanticsService.announce` ao parar e ao remover |
| `anel_de_meta.dart` | `Semantics(label: 'Meta semanal', value: '180 de 300 minutos, 60 por cento', liveRegion: true, excludeSemantics: true)` (RNF04) |
| `materia_form_screen.dart` | `textInputAction` e `FocusNode` na ordem visual; `ListView` no lugar de `Column`, para o teclado não cobrir o campo |

---

## ▶️ Rodando

```powershell
flutter analyze
flutter run
```

Com o app aberto no emulador 🤖, mude o aparelho por baixo dele, sem recompilar:

```powershell
adb shell wm size 320x640 ; adb shell wm density 160    # 320 dp: o menor celular
adb shell wm size 1600x2560 ; adb shell wm density 240  # ~1066 dp: tablet
adb shell settings put system font_scale 2.0            # fonte do sistema a 200%

adb shell settings put system font_scale 1.0
adb shell wm size reset ; adb shell wm density reset    # devolve tudo ao normal
```

**O que você vê:** a 320 dp, uma coluna e a barra na base, sem listra amarela de estouro. A
1066 dp, o trilho à esquerda com rótulos abertos e a lista em duas colunas — **a mesma
`MateriasTab`**, sem um widget duplicado. A 200% de fonte, os cartões crescem e o texto continua
inteiro. Para inspecionar a árvore de semântica, ligue por um minuto
`MaterialApp(showSemanticsDebugger: true, ...)` em `app.dart`.

> 💡 Cinco minutos de TalkBack valem mais que qualquer teste automático. Decore antes o atalho de
> desligar: **segurar as duas teclas de volume por 3 segundos**.

---

## ✅ Conferência

- [ ] `flutter analyze` termina com **No issues found!** (RNF15)
- [ ] Abaixo de 600 dp: `NavigationBar` na base e lista em 1 coluna
- [ ] A partir de 600 dp: `NavigationRail` à esquerda e lista em 2 colunas (RNF18)
- [ ] Trocar de aba, ir a `/estatisticas` e voltar **mantém a aba escolhida** (RF01)
- [ ] A 320 dp com fonte a 200%, **nenhuma** tela mostra listra de estouro (RNF03)
- [ ] Todo `IconButton` do app tem `tooltip`, inclusive os dois da `AppBar` (RNF04)
- [ ] Com TalkBack, o item de matéria é uma parada só, não três nós soltos
- [ ] O gráfico anuncia dia a dia ("segunda-feira, 45 minutos") e o anel anuncia a meta
- [ ] Nenhuma cor crua de texto: só papéis do `ColorScheme`, e o tema escuro segue legível (RNF01)

---

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| `A RenderFlex overflowed by N pixels` a 200% | `Text` sem `Expanded` numa `Row`, ou `height` fixo em volta de texto | `Expanded` + `maxLines` + `ellipsis`; troque `height:` por `ConstrainedBox(minHeight:)` |
| Assert do `NavigationRail` ao passar de 900 dp | `extended: true` com `labelType` diferente de `none` | `labelType: null` quando `trilhoEstendido` for `true` |
| A aba volta ao Painel ao retornar de `/estatisticas` | O `IndexedStack` virou um `switch` que recria o filho | Mantenha o `State` e o `IndexedStack` |
| `meetsGuideline(androidTapTargetGuideline)` falha | `GestureDetector` em volta de um `Icon` de 24 dp | `IconButton` (48 dp por padrão) ou `ConstrainedBox(minWidth: 48, minHeight: 48)` |
| Alvo de 48 dp certo, mas sem rótulo | `IconButton` sem `tooltip` | Rotule pelo RESULTADO: "Pausar o cronômetro", não "Ícone de pausa" |
| O trilho encosta na barra de gestos 🍎, ou sobra espaço sob a barra de status | `SafeArea` ausente, ou `SafeArea` completo dentro de `Scaffold` com `AppBar` | `SafeArea(top: false, child: Row(...))` |

---

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [07 — Etapa 5: API e trilhas](07-etapa-5-api-e-trilhas.md) | [README do projeto](README.md) | [09 — Etapa 7: Testes](09-etapa-7-testes.md) |
