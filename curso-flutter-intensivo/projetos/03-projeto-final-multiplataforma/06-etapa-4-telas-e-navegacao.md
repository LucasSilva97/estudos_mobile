# Etapa 4 — Telas e navegação — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 4 h a 5 h · **Depende de:** [Etapa 3 — Estado com Riverpod](05-etapa-3-estado-com-riverpod.md) ·
> **Aulas:** [06/09 Listas e rolagem](../../modulos/06-widgets-e-layouts/09-listas-e-rolagem.md) ·
> [06/12 Estados de UI](../../modulos/06-widgets-e-layouts/12-estados-de-ui.md) ·
> [07/03 Argumentos e resultados](../../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md) ·
> [07/04 Abas e organização](../../modulos/07-navegacao-e-formularios/04-abas-e-organizacao.md) ·
> [07/05 Navegação Android × iOS](../../modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md) ·
> [07/06 Formulários](../../modulos/07-navegacao-e-formularios/06-formularios.md) ·
> [07/07 Validação, foco e teclado](../../modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md) ·
> [07/08 UX de formulários](../../modulos/07-navegacao-e-formularios/08-ux-de-formularios.md)

---

## 🎯 O que existe ao fim desta etapa

Você tinha dados e providers sem rosto. Agora o Foco é **um app usável**: cadastra matéria com cor,
abre o detalhe, liga o cronômetro, registra a sessão e vê o anel da meta subir.

| Você consegue | Onde |
|---|---|
| Trocar de aba sem empilhar rota e sem perder rolagem | `InicioScreen` |
| Criar e **editar** matéria, com 2–60 e duplicata normalizada barradas no campo | `MateriaFormScreen` |
| Ser perguntado antes de perder o que digitou | `PopScope` |
| Cronometrar, registrar e remover sessão com desfazer | `MateriaDetalheScreen` |
| Ver 7 dias, total, média e comparação com a semana anterior | `EstatisticasScreen` |
| Ajustar meta e tema, aplicados **sem reiniciar** | `ConfiguracoesScreen` |
| Ver os **4 estados** em toda tela que lê dado | `core/widgets/` |

Duas coisas seguem como casca, de propósito: a aba **Trilhas** (Etapa 5, com a API) e o gráfico
`BarrasDaSemana` (Etapa 6). Nesta etapa elas ocupam o lugar certo com um vazio honesto — não com
tela quebrada.

## 📦 Dependências

Uma, e só se a Etapa 1 ainda não a adicionou:

```bash
flutter pub add intl
```

Ela existe por causa do **RNF20**: data e duração vêm de biblioteca, nunca de concatenação.

> 💡 `Formato` usa só padrões **numéricos** (`dd/MM/yyyy`), que não dependem de
> `initializeDateFormatting` — nada a carregar antes do `runApp`. Os nomes dos dias são constante
> nossa, em pt-BR.

## 🧩 Os arquivos desta etapa

| Arquivo | Papel |
|---|---|
| `core/rotas/argumentos.dart` | `MateriaFormArgs` e `MateriaDetalheArgs` tipados |
| `core/rotas/rotas.dart` | **Atualizado**: o `onGenerateRoute` aponta para as telas reais |
| `core/tema/cores_de_materia.dart` | As 8 cores do RF04, como `int` ARGB |
| `core/formato/formato.dart` | minutos → "2 h 15 min", datas, relógio |
| `core/widgets/estado_carregando.dart` | Estado 1 |
| `core/widgets/estado_vazio.dart` | Estado 2 — sempre com saída |
| `core/widgets/estado_de_erro.dart` | Estado 3 — pt-BR e "Tentar de novo" |
| `features/inicio/presentation/inicio_screen.dart` | Tela 1: `NavigationBar` + `IndexedStack` |
| `features/inicio/presentation/painel_tab.dart` | Resumo do dia e da semana |
| `features/metas/presentation/widgets/anel_de_meta.dart` | Anel com `Semantics` |
| `features/materias/presentation/widgets/materia_tile.dart` | Item e porta do detalhe |
| `features/materias/presentation/materias_tab.dart` | Lista + FAB |
| `features/materias/presentation/widgets/seletor_de_cor.dart` | 8 alvos de 48 dp |
| `features/materias/presentation/materia_form_screen.dart` | Tela 2: valida e devolve `bool` |
| `features/sessoes/presentation/widgets/sessao_tile.dart` | Item de sessão |
| `features/sessoes/presentation/widgets/form_sessao_sheet.dart` | Folha de registro |
| `features/sessoes/presentation/widgets/cronometro_card.dart` | Iniciar/pausar/parar/descartar |
| `features/materias/presentation/materia_detalhe_screen.dart` | Tela 3 |
| `features/estatisticas/presentation/estatisticas_screen.dart` | Tela 4 |
| `features/configuracoes/presentation/configuracoes_screen.dart` | Tela 5 |

---

### lib/core/rotas/argumentos.dart

> **Por que ele existe:** para o argumento de rota ser um **tipo**, e não um `Map` que só quebra em
> execução.

```dart
import 'package:flutter/foundation.dart';
import '../../features/materias/domain/materia.dart';

@immutable
class MateriaFormArgs {
  /// `materia` nula = criação; não nula = edição.
  const MateriaFormArgs({this.materia});
  final Materia? materia;
}

@immutable
class MateriaDetalheArgs {
  /// Só o id: a tela relê do provider e nunca mostra dado velho.
  const MateriaDetalheArgs({required this.materiaId});
  final String materiaId;
}
```

### lib/core/tema/cores_de_materia.dart

> **Por que ele existe:** as 8 cores ficam em um lugar só, e como `int` — o domínio não importa
> `dart:ui`.

```dart
/// `0xFF6750A4` é o mesmo 4284960932 que `Materia.corValor` usa como padrão.
abstract final class CoresDeMateria {
  static const int padrao = 0xFF6750A4;

  static const List<int> valores = <int>[
    0xFF6750A4, 0xFF386A20, 0xFF00629E, 0xFF8F4C38,
    0xFF6E5E00, 0xFF984061, 0xFF00696E, 0xFF4A4458,
  ];

  /// Rótulos do `Semantics`: cor sozinha não é informação acessível.
  static const List<String> nomes = <String>[
    'Roxo', 'Verde', 'Azul', 'Terracota', 'Mostarda', 'Vinho', 'Turquesa', 'Grafite',
  ];
}
```

### lib/core/formato/formato.dart

> **Por que ele existe:** "135 min" não é resposta para humano; "2 h 15 min" é.

```dart
import 'package:intl/intl.dart';

abstract final class Formato {
  static final DateFormat _data = DateFormat('dd/MM/yyyy');
  static final DateFormat _dataHora = DateFormat('dd/MM/yyyy HH:mm');

  static const List<String> diasDaSemana = <String>['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

  static String minutos(int total) {
    if (total <= 0) return '0 min';
    final int horas = total ~/ 60;
    final int resto = total % 60;
    if (horas == 0) return '$resto min';
    return resto == 0 ? '$horas h' : '$horas h $resto min';
  }

  static String data(DateTime quando) => _data.format(quando);
  static String dataHora(DateTime quando) => _dataHora.format(quando);

  static String cronometro(Duration d) {
    String dois(int v) => v.toString().padLeft(2, '0');
    return '${dois(d.inHours)}:${dois(d.inMinutes % 60)}:${dois(d.inSeconds % 60)}';
  }
}
```

### lib/core/widgets/estado_carregando.dart

> **Por que ele existe:** o leitor de tela precisa **ouvir** que algo está acontecendo, não só ver
> o pixel girar.

```dart
import 'package:flutter/material.dart';

class EstadoCarregando extends StatelessWidget {
  const EstadoCarregando({super.key, this.mensagem = 'Carregando…'});
  final String mensagem;

  @override
  Widget build(BuildContext context) => Center(
        child: Semantics(
          liveRegion: true,
          label: mensagem,
          child: const CircularProgressIndicator(),
        ),
      );
}
```

### lib/core/widgets/estado_vazio.dart

> **Por que ele existe:** vazio sem ação é beco sem saída.

```dart
import 'package:flutter/material.dart';

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({super.key, required this.titulo, required this.mensagem,
      this.icone = Icons.inbox_outlined, this.rotuloAcao, this.aoAgir});

  final String titulo;
  final String mensagem;
  final IconData icone;
  final String? rotuloAcao;
  final VoidCallback? aoAgir;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    // ⚠️ ListView, não Column: Column estoura em fonte 200% (RNF03) e mata o RefreshIndicator.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      children: <Widget>[
        Icon(icone, size: 56, color: tema.colorScheme.outline),
        const SizedBox(height: 16),
        Text(titulo, textAlign: TextAlign.center, style: tema.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(mensagem, textAlign: TextAlign.center, style: tema.textTheme.bodyMedium),
        if (aoAgir != null && rotuloAcao != null) ...<Widget>[
          const SizedBox(height: 24),
          Center(child: FilledButton(onPressed: aoAgir, child: Text(rotuloAcao!))),
        ],
      ],
    );
  }
}
```

### lib/core/widgets/estado_de_erro.dart

> **Por que ele existe:** para o usuário receber um botão, e não um `Exception` na cara.

```dart
import 'package:flutter/material.dart';

class EstadoDeErro extends StatelessWidget {
  const EstadoDeErro({super.key, required this.mensagem, required this.aoTentarDeNovo,
      this.titulo = 'Algo deu errado'});

  final String titulo;

  /// ⚠️ Frase em português escrita por você. NUNCA `erro.toString()`: não ajuda
  /// o usuário e pode vazar caminho de arquivo ou consulta SQL.
  final String mensagem;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      children: <Widget>[
        Icon(Icons.error_outline, size: 56, color: tema.colorScheme.error),
        const SizedBox(height: 16),
        Text(titulo, textAlign: TextAlign.center, style: tema.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(mensagem, textAlign: TextAlign.center, style: tema.textTheme.bodyMedium),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: aoTentarDeNovo,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar de novo'),
          ),
        ),
      ],
    );
  }
}
```

### lib/core/rotas/rotas.dart

> **Por que ele existe:** é o único lugar que sabe qual `String` vira qual tela — e o único que
> confere o tipo do argumento.

```dart
import 'package:flutter/material.dart';

import '../../features/configuracoes/presentation/configuracoes_screen.dart';
import '../../features/estatisticas/presentation/estatisticas_screen.dart';
import '../../features/inicio/presentation/inicio_screen.dart';
import '../../features/materias/presentation/materia_detalhe_screen.dart';
import '../../features/materias/presentation/materia_form_screen.dart';
import 'argumentos.dart';

abstract final class Rotas {
  static const String inicio = '/';
  static const String materiaForm = '/materia/form';
  static const String materiaDetalhe = '/materia/detalhe';
  static const String estatisticas = '/estatisticas';
  static const String configuracoes = '/configuracoes';

  // ⚠️ O parâmetro se chama `rota`, não `configuracoes`: um parâmetro com o nome de
  // uma constante da classe sombrearia o `case configuracoes:` e o switch não compila.
  static Route<dynamic>? aoGerar(RouteSettings rota) {
    switch (rota.name) {
      case inicio:
        return MaterialPageRoute<void>(settings: rota, builder: (_) => const InicioScreen());
      case materiaForm:
        final Object? args = rota.arguments;
        // Sem argumento = criação. Tipo errado NÃO vira cast cego.
        return MaterialPageRoute<bool>(
          settings: rota,
          builder: (_) => MateriaFormScreen(
            args: args is MateriaFormArgs ? args : const MateriaFormArgs(),
          ),
        );
      case materiaDetalhe:
        final Object? args = rota.arguments;
        if (args is! MateriaDetalheArgs) return _desconhecida(rota);
        return MaterialPageRoute<void>(
          settings: rota,
          builder: (_) => MateriaDetalheScreen(args: args), // aqui args JÁ é do tipo certo
        );
      case estatisticas:
        return MaterialPageRoute<void>(settings: rota, builder: (_) => const EstatisticasScreen());
      case configuracoes:
        return MaterialPageRoute<void>(settings: rota, builder: (_) => const ConfiguracoesScreen());
      default:
        return _desconhecida(rota);
    }
  }

  static Route<dynamic> _desconhecida(RouteSettings rota) => MaterialPageRoute<void>(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(title: const Text('Rota inválida')),
          body: Center(child: Text('Não existe rota para "${rota.name}".')),
        ),
      );
}
```

### lib/features/inicio/presentation/inicio_screen.dart

> **Por que ele existe:** é a casca — a `AppBar` de atalhos e as três abas que **não** empilham
> rota.

```dart
import 'package:flutter/material.dart';

import '../../../core/rotas/rotas.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../materias/presentation/materias_tab.dart';
import 'painel_tab.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foco'),
        actions: <Widget>[
          // `tooltip` também vira o rótulo de acessibilidade do botão só-ícone (RNF04).
          IconButton(
            tooltip: 'Estatísticas',
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => Navigator.of(context).pushNamed(Rotas.estatisticas),
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(Rotas.configuracoes),
          ),
        ],
      ),
      // ⚠️ IndexedStack, não switch: trocar de aba não pode zerar a rolagem nem
      // recomeçar a aba do zero. E trocar de aba NUNCA empilha rota.
      body: IndexedStack(
        index: _aba,
        children: <Widget>[
          PainelTab(aoIrParaMaterias: () => setState(() => _aba = 1)),
          const MateriasTab(),
          const _TrilhasEmBreve(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (int indice) => setState(() => _aba = indice),
        destinations: const <NavigationDestination>[
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Painel'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Matérias'),
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Trilhas'),
        ],
      ),
    );
  }
}

/// Lugar guardado da aba Trilhas. Na Etapa 5 troque por `const TrilhasTab()`.
class _TrilhasEmBreve extends StatelessWidget {
  const _TrilhasEmBreve();
  @override
  Widget build(BuildContext context) => const EstadoVazio(
        titulo: 'Trilhas',
        mensagem: 'A aba de trilhas chega na Etapa 5, junto com a API.',
        icone: Icons.explore_outlined,
      );
}
```

### lib/features/inicio/presentation/painel_tab.dart

> **Por que ele existe:** responde em um olhar a "estudei o quanto eu precisava esta semana?".

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formato/formato.dart';
import '../../../core/widgets/estado_carregando.dart';
import '../../../core/widgets/estado_de_erro.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../estatisticas/domain/resumo_semanal.dart';
import '../../estatisticas/presentation/estatisticas_controller.dart';
import '../../metas/domain/meta_semanal.dart';
import '../../metas/presentation/widgets/anel_de_meta.dart';

class PainelTab extends ConsumerWidget {
  const PainelTab({super.key, required this.aoIrParaMaterias});
  final VoidCallback aoIrParaMaterias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ResumoSemanal> resumo = ref.watch(resumoSemanalProvider);
    return resumo.when(
      loading: () => const EstadoCarregando(mensagem: 'Somando a sua semana…'),
      error: (Object erro, StackTrace pilha) => EstadoDeErro(
        mensagem: 'Não foi possível montar o resumo da sua semana.',
        aoTentarDeNovo: () => ref.invalidate(resumoSemanalProvider),
      ),
      data: (ResumoSemanal dados) {
        if (dados.totalMinutos == 0) {
          return EstadoVazio(
            titulo: 'Semana em branco',
            mensagem: 'Registre a sua primeira sessão para o painel ganhar vida.',
            icone: Icons.timer_outlined,
            rotuloAcao: 'Registrar sessão',
            aoAgir: aoIrParaMaterias,
          );
        }
        final int hoje = DateTime.now().weekday - 1; // 0 = segunda
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Center(
              child: AnelDeMeta(
                meta: MetaSemanal(
                    minutosAlvo: dados.metaMinutos, minutosFeitos: dados.totalMinutos),
              ),
            ),
            const SizedBox(height: 16),
            _Linha('Hoje', Formato.minutos(dados.minutosPorDia[hoje])),
            _Linha('Esta semana', Formato.minutos(dados.totalMinutos)),
            _Linha('Média por dia', Formato.minutos(dados.mediaDiariaMinutos)),
            _Linha('Semana passada', Formato.minutos(dados.minutosSemanaAnterior)),
          ],
        );
      },
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.rotulo, this.valor);
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(rotulo),
        trailing: Text(valor, style: Theme.of(context).textTheme.titleMedium),
      );
}
```

> 📌 O RF02 fala em "3 sessões mais recentes". O contrato de providers expõe sessões **por matéria**
> (`sessoesDaMateriaProvider`), não uma lista global — então o painel mostra o agregado da semana e
> a lista de sessões vive na `MateriaDetalheScreen`. Juntar as últimas de todas as matérias é o
> primeiro item de [13-desafios.md](13-desafios.md).

### lib/features/metas/presentation/widgets/anel_de_meta.dart

> **Por que ele existe:** o progresso precisa ser lido num olhar **e** anunciado em voz alta
> (RNF04).

```dart
import 'package:flutter/material.dart';
import '../../domain/meta_semanal.dart';

class AnelDeMeta extends StatelessWidget {
  const AnelDeMeta({super.key, required this.meta});
  final MetaSemanal meta;

  @override
  Widget build(BuildContext context) {
    final int porcento = (meta.progresso * 100).round();
    final ThemeData tema = Theme.of(context);
    return Semantics(
      label: 'Meta semanal, ${meta.minutosFeitos} de ${meta.minutosAlvo} minutos, '
          '$porcento por cento',
      // O texto interno já entrou no rótulo acima; sem o Exclude, o leitor de tela repetiria.
      child: ExcludeSemantics(
        child: SizedBox(
          height: 148,
          width: 148,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                height: 148,
                width: 148,
                child: CircularProgressIndicator(
                  value: meta.progresso,
                  strokeWidth: 12,
                  backgroundColor: tema.colorScheme.surfaceContainerHighest,
                ),
              ),
              // FittedBox: em fonte 200% o texto encolhe em vez de estourar o anel.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('$porcento%', style: tema.textTheme.headlineSmall),
                    Text(
                      meta.atingida ? 'meta batida' : 'faltam ${meta.minutosRestantes} min',
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### lib/features/materias/presentation/widgets/materia_tile.dart

> **Por que ele existe:** é o item da lista e a porta do detalhe, com argumento tipado.

```dart
import 'package:flutter/material.dart';

import '../../../../core/formato/formato.dart';
import '../../../../core/rotas/argumentos.dart';
import '../../../../core/rotas/rotas.dart';
import '../../domain/materia.dart';

class MateriaTile extends StatelessWidget {
  const MateriaTile({super.key, required this.materia});
  final Materia materia;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          // A cor de matéria é FUNDO de avatar, nunca cor de texto (RNF01).
          backgroundColor: Color(materia.corValor),
          child: Text(materia.nome.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(materia.nome),
        subtitle: Text(Formato.minutos(materia.minutos)),
        trailing: const Icon(Icons.chevron_right),
        minVerticalPadding: 12, // garante 48 dp mesmo com nome curto (RNF02)
        onTap: () => Navigator.of(context).pushNamed(
          Rotas.materiaDetalhe,
          arguments: MateriaDetalheArgs(materiaId: materia.id),
        ),
      );
}
```

### lib/features/materias/presentation/materias_tab.dart

> **Por que ele existe:** é a primeira tela do app com os quatro estados de verdade.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/rotas/argumentos.dart';
import '../../../core/rotas/rotas.dart';
import '../../../core/widgets/estado_carregando.dart';
import '../../../core/widgets/estado_de_erro.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../domain/materia.dart';
import 'materias_controller.dart';
import 'widgets/materia_tile.dart';

class MateriasTab extends ConsumerWidget {
  const MateriasTab({super.key});

  Future<void> _novaMateria(BuildContext context) async {
    final bool? salvou = await Navigator.of(context)
        .pushNamed<bool>(Rotas.materiaForm, arguments: const MateriaFormArgs());
    // ⚠️ Este await pode durar minutos. Sem o mounted, o SnackBar cai num context morto.
    if (!context.mounted || salvou != true) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matéria salva.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Materia>> materias = ref.watch(materiasProvider);
    return Scaffold(
      body: materias.when(
        loading: () => const EstadoCarregando(),
        error: (Object erro, StackTrace pilha) => EstadoDeErro(
          mensagem: 'Não foi possível ler as suas matérias do banco.',
          aoTentarDeNovo: () => ref.invalidate(materiasProvider),
        ),
        data: (List<Materia> lista) {
          if (lista.isEmpty) {
            return EstadoVazio(
              titulo: 'Nenhuma matéria ainda',
              mensagem: 'Cadastre a primeira para começar a registrar sessões.',
              icone: Icons.menu_book_outlined,
              rotuloAcao: 'Nova matéria',
              aoAgir: () => _novaMateria(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88), // espaço do FAB
            itemCount: lista.length,
            itemBuilder: (BuildContext context, int i) =>
                MateriaTile(key: ValueKey<String>(lista[i].id), materia: lista[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _novaMateria(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova matéria'),
      ),
    );
  }
}
```

### lib/features/materias/presentation/widgets/seletor_de_cor.dart

> **Por que ele existe:** oito bolinhas de 48 dp, cada uma com nome — cor sozinha não é informação.

```dart
import 'package:flutter/material.dart';
import '../../../../core/tema/cores_de_materia.dart';

class SeletorDeCor extends StatelessWidget {
  const SeletorDeCor({super.key, required this.valor, required this.aoEscolher});
  final int valor;
  final ValueChanged<int> aoEscolher;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (int i = 0; i < CoresDeMateria.valores.length; i++)
            Semantics(
              button: true,
              selected: CoresDeMateria.valores[i] == valor,
              label: 'Cor ${CoresDeMateria.nomes[i]}',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => aoEscolher(CoresDeMateria.valores[i]),
                child: SizedBox(
                  width: 48, // RNF02: o alvo tem 48 dp mesmo com a bolinha menor
                  height: 48,
                  child: Center(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(CoresDeMateria.valores[i]),
                      child: CoresDeMateria.valores[i] == valor
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}
```

### lib/features/materias/presentation/materia_form_screen.dart

> **Por que ele existe:** é onde o módulo 07 inteiro cai de uma vez — validação, foco, teclado,
> `PopScope` e resultado de rota.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/banco/texto.dart';
import '../../../core/providers/providers_raiz.dart';
import '../../../core/rotas/argumentos.dart';
import '../../../core/tema/cores_de_materia.dart';
import '../domain/materia.dart';
import 'materias_controller.dart';
import 'widgets/seletor_de_cor.dart';

class MateriaFormScreen extends ConsumerStatefulWidget {
  const MateriaFormScreen({super.key, required this.args});
  final MateriaFormArgs args;

  @override
  ConsumerState<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends ConsumerState<MateriaFormScreen> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();
  final TextEditingController _nome = TextEditingController();
  final FocusNode _focoNome = FocusNode();
  late int _cor;
  bool _salvando = false;
  bool _jaTentouEnviar = false;

  bool get _editando => widget.args.materia != null;

  @override
  void initState() {
    super.initState();
    _nome.text = widget.args.materia?.nome ?? '';
    _cor = widget.args.materia?.corValor ?? CoresDeMateria.padrao;
  }

  @override
  void dispose() {
    _nome.dispose();
    _focoNome.dispose(); // ⚠️ FocusNode precisa de dispose igual ao controller
    super.dispose();
  }

  bool get _temRascunho {
    final Materia? original = widget.args.materia;
    return _nome.text.trim() != (original?.nome ?? '') ||
        _cor != (original?.corValor ?? CoresDeMateria.padrao);
  }

  String? _validarNome(String? bruto) {
    final String nome = (bruto ?? '').trim();
    if (nome.length < 2) return 'Use pelo menos 2 caracteres.';
    if (nome.length > 60) return 'Use no máximo 60 caracteres.';
    // Regra 2: a comparação é pelo nome NORMALIZADO — "cálculo" == "Calculo".
    final String chave = Texto.paraOrdenacao(nome);
    final List<Materia> existentes = ref.read(materiasProvider).valueOrNull ?? const <Materia>[];
    for (final Materia outra in existentes) {
      if (outra.id != widget.args.materia?.id && Texto.paraOrdenacao(outra.nome) == chave) {
        return 'Você já tem uma matéria com esse nome.';
      }
    }
    return null;
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus(); // fecha o teclado antes de tudo
    setState(() => _jaTentouEnviar = true);
    if (!(_chave.currentState?.validate() ?? false)) {
      _focoNome.requestFocus(); // leva o cursor ao campo que reprovou
      return;
    }
    setState(() => _salvando = true);
    final Materia base = widget.args.materia ??
        Materia(id: ref.read(uuidProvider).v4(), nome: '', criadaEm: DateTime.now());
    try {
      await ref
          .read(materiasProvider.notifier)
          .salvar(base.copyWith(nome: _nome.text.trim(), corValor: _cor));
      if (!mounted) return; // ⚠️ nada de setState depois do pop
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a matéria.')),
      );
    }
  }

  Future<bool> _confirmarDescarte() async {
    final bool? descartar = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogo) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você digitou não será salvo.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(dialogo).pop(false),
              child: const Text('Continuar editando')),
          FilledButton(
              onPressed: () => Navigator.of(dialogo).pop(true), child: const Text('Descartar')),
        ],
      ),
    );
    return descartar ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      // ⚠️ canPop precisa ser FALSE para o callback rodar: ele só dispara quando o pop é bloqueado.
      canPop: !_temRascunho && !_salvando,
      onPopInvokedWithResult: (bool saiu, bool? resultado) async {
        if (saiu) return;
        final bool descartar = await _confirmarDescarte();
        if (descartar && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_editando ? 'Editar matéria' : 'Nova matéria')),
        body: Form(
          key: _chave,
          // Só valida a cada tecla DEPOIS da primeira tentativa de envio.
          autovalidateMode:
              _jaTentouEnviar ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _nome,
                focusNode: _focoNome,
                autofocus: !_editando,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Nome da matéria',
                  helperText: 'De 2 a 60 caracteres. Ex.: Cálculo I',
                  border: OutlineInputBorder(),
                ),
                validator: _validarNome,
                onFieldSubmitted: (_) => _salvar(),
              ),
              const SizedBox(height: 8),
              Text('Cor', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SeletorDeCor(valor: _cor, aoEscolher: (int nova) => setState(() => _cor = nova)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> ⚠️ A checagem de duplicata aqui olha a lista **em memória**, que não inclui arquivadas. É
> conveniência de UI: a defesa final continua sendo o repositório, que rejeita o nome repetido antes
> de tocar no banco.

### lib/features/sessoes/presentation/widgets/sessao_tile.dart

> **Por que ele existe:** mostra "45 min · 12/03/2026 19:30 · revisão de limites" sem cálculo no
> `build`.

```dart
import 'package:flutter/material.dart';

import '../../../../core/formato/formato.dart';
import '../../domain/sessao.dart';

class SessaoTile extends StatelessWidget {
  const SessaoTile({super.key, required this.sessao});
  final Sessao sessao;

  @override
  Widget build(BuildContext context) {
    final String quando = Formato.dataHora(sessao.inicioEm);
    return ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: Text(Formato.minutos(sessao.minutos)),
      subtitle: Text(sessao.anotacao.isEmpty ? quando : '$quando · ${sessao.anotacao}'),
      minVerticalPadding: 12,
    );
  }
}
```

### lib/features/sessoes/presentation/widgets/form_sessao_sheet.dart

> **Por que ele existe:** é o único caminho de escrita de sessão — do cronômetro **e** do registro
> manual.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formato/formato.dart';
import '../../../../core/providers/providers_raiz.dart';
import '../../domain/sessao.dart';
import '../sessoes_controller.dart';

Future<bool?> mostrarFormSessaoSheet(
  BuildContext context, {
  required String materiaId,
  int minutosIniciais = 25,
  DateTime? inicioEm,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true, // ⚠️ sem isto o teclado cobre o campo de anotação
    useSafeArea: true,
    builder: (BuildContext contexto) => _FormSessao(
      materiaId: materiaId,
      minutosIniciais: minutosIniciais,
      inicioEm: inicioEm ?? DateTime.now(),
    ),
  );
}

class _FormSessao extends ConsumerStatefulWidget {
  const _FormSessao(
      {required this.materiaId, required this.minutosIniciais, required this.inicioEm});
  final String materiaId;
  final int minutosIniciais;
  final DateTime inicioEm;

  @override
  ConsumerState<_FormSessao> createState() => _FormSessaoState();
}

class _FormSessaoState extends ConsumerState<_FormSessao> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();
  final TextEditingController _anotacao = TextEditingController();
  final FocusNode _focoAnotacao = FocusNode();
  late final TextEditingController _minutos =
      TextEditingController(text: widget.minutosIniciais.toString());
  late DateTime _inicioEm = widget.inicioEm;
  bool _salvando = false;

  @override
  void dispose() {
    _minutos.dispose();
    _anotacao.dispose();
    _focoAnotacao.dispose();
    super.dispose();
  }

  String? _validarMinutos(String? bruto) {
    final int? valor = int.tryParse((bruto ?? '').trim());
    if (valor == null) return 'Digite um número de minutos.';
    if (valor < Sessao.minimoDeMinutos || valor > Sessao.maximoDeMinutos) {
      return 'Use de ${Sessao.minimoDeMinutos} a ${Sessao.maximoDeMinutos} minutos.';
    }
    return null;
  }

  Future<void> _escolherData() async {
    final DateTime agora = DateTime.now();
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _inicioEm,
      firstDate: agora.subtract(const Duration(days: 365)),
      lastDate: agora, // RF12: data não futura, garantida pelo próprio seletor
    );
    if (escolhida == null || !mounted) return;
    setState(() => _inicioEm = DateTime(
        escolhida.year, escolhida.month, escolhida.day, _inicioEm.hour, _inicioEm.minute));
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();
    if (!(_chave.currentState?.validate() ?? false)) return;
    setState(() => _salvando = true);
    final Sessao sessao = Sessao(
      id: ref.read(uuidProvider).v4(),
      materiaId: widget.materiaId,
      inicioEm: _inicioEm,
      minutos: int.parse(_minutos.text.trim()),
      anotacao: _anotacao.text.trim(),
    );
    try {
      await ref.read(sessoesDaMateriaProvider(widget.materiaId).notifier).registrar(sessao);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível registrar a sessão.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // viewInsets = altura do teclado: é o que mantém o botão visível.
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _chave,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Registrar sessão', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minutos,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Minutos',
                helperText: 'De 1 a 480',
                border: OutlineInputBorder(),
              ),
              validator: _validarMinutos,
              onFieldSubmitted: (_) => _focoAnotacao.requestFocus(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(Formato.data(_inicioEm)),
              trailing: TextButton(onPressed: _escolherData, child: const Text('Alterar')),
            ),
            TextFormField(
              controller: _anotacao,
              focusNode: _focoAnotacao,
              maxLength: 280,
              maxLines: 3,
              // ⚠️ Campo multilinha usa newline; done fecharia o teclado no Enter.
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                  labelText: 'Anotação (opcional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            FilledButton(
                onPressed: _salvando ? null : _registrar, child: const Text('Registrar')),
          ],
        ),
      ),
    );
  }
}
```

### lib/features/sessoes/presentation/widgets/cronometro_card.dart

> **Por que ele existe:** é a cara do RF10 — e ele só **lê** o estado, nunca conta tempo por conta
> própria.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formato/formato.dart';
import '../../domain/cronometro_estado.dart';
import '../cronometro_controller.dart';
import 'form_sessao_sheet.dart';

class CronometroCard extends ConsumerWidget {
  const CronometroCard({super.key, required this.materiaId});
  final String materiaId;

  Future<void> _pararERegistrar(
      BuildContext context, WidgetRef ref, CronometroEstado estado) async {
    final bool? registrou = await mostrarFormSessaoSheet(
      context,
      materiaId: materiaId,
      minutosIniciais: estado.minutosArredondados(DateTime.now()),
      inicioEm: estado.inicioEm,
    );
    if (registrou ?? false) ref.read(cronometroProvider.notifier).descartar();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CronometroEstado estado = ref.watch(cronometroProvider);
    final CronometroController controle = ref.read(cronometroProvider.notifier);
    final bool destaMateria = estado.materiaId == materiaId;
    // ⚠️ O tempo vem de diferença de DateTime. Somar ticks de Timer perderia tempo
    // toda vez que o app fosse para o segundo plano.
    final Duration decorrido = destaMateria ? estado.decorridoAte(DateTime.now()) : Duration.zero;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Semantics(
              liveRegion: true,
              label: 'Cronômetro, ${decorrido.inMinutes} minutos',
              child: ExcludeSemantics(
                child: Text(Formato.cronometro(decorrido),
                    style: Theme.of(context).textTheme.displaySmall),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                if (!destaMateria || decorrido == Duration.zero)
                  FilledButton.icon(
                      onPressed: () => controle.iniciar(materiaId),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar'))
                else if (estado.rodando)
                  FilledButton.icon(
                      onPressed: controle.pausar,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pausar'))
                else
                  FilledButton.icon(
                      onPressed: controle.retomar,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Retomar')),
                if (destaMateria && decorrido > Duration.zero) ...<Widget>[
                  OutlinedButton.icon(
                      onPressed: () => _pararERegistrar(context, ref, estado),
                      icon: const Icon(Icons.stop),
                      label: const Text('Parar e registrar')),
                  TextButton(onPressed: controle.descartar, child: const Text('Descartar')),
                ],
              ],
            ),
            TextButton.icon(
              onPressed: () => mostrarFormSessaoSheet(context, materiaId: materiaId),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Registrar manualmente'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### lib/features/materias/presentation/materia_detalhe_screen.dart

> **Por que ele existe:** é onde o usuário passa o tempo — cronômetro, histórico, arquivar e
> excluir.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formato/formato.dart';
import '../../../core/rotas/argumentos.dart';
import '../../../core/widgets/estado_carregando.dart';
import '../../../core/widgets/estado_de_erro.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../sessoes/domain/sessao.dart';
import '../../sessoes/presentation/sessoes_controller.dart';
import '../../sessoes/presentation/widgets/cronometro_card.dart';
import '../../sessoes/presentation/widgets/sessao_tile.dart';
import '../domain/materia.dart';
import 'materias_controller.dart';

class MateriaDetalheScreen extends ConsumerWidget {
  const MateriaDetalheScreen({super.key, required this.args});
  final MateriaDetalheArgs args;

  Materia? _procurar(List<Materia> lista) {
    for (final Materia materia in lista) {
      if (materia.id == args.materiaId) return materia;
    }
    return null;
  }

  Future<bool> _confirmar(BuildContext context, String titulo, String texto, String acao) async {
    final bool? sim = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogo) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(dialogo).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(dialogo).pop(true), child: Text(acao)),
        ],
      ),
    );
    return sim ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Materia>> materias = ref.watch(materiasProvider);
    final Materia? materia = _procurar(materias.valueOrNull ?? const <Materia>[]);

    if (materia == null) {
      return Scaffold(
        appBar: AppBar(),
        body: materias.isLoading
            ? const EstadoCarregando()
            : EstadoVazio(
                titulo: 'Matéria não encontrada',
                mensagem: 'Ela pode ter sido arquivada ou excluída.',
                icone: Icons.search_off_outlined,
                rotuloAcao: 'Voltar',
                aoAgir: () => Navigator.of(context).pop(),
              ),
      );
    }

    final AsyncValue<List<Sessao>> sessoes = ref.watch(sessoesDaMateriaProvider(materia.id));
    final SessoesController controle = ref.read(sessoesDaMateriaProvider(materia.id).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(materia.nome),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: 'Mais ações',
            onSelected: (String acao) async {
              if (acao == 'arquivar') {
                await ref
                    .read(materiasProvider.notifier)
                    .arquivar(materia.id, arquivada: !materia.arquivada);
              } else {
                final bool confirmou = await _confirmar(context, 'Excluir ${materia.nome}?',
                    'As sessões dessa matéria também serão apagadas.', 'Excluir');
                if (!confirmou) return;
                await ref.read(materiasProvider.notifier).excluir(materia.id);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            itemBuilder: (BuildContext contexto) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                  value: 'arquivar',
                  child: Text(materia.arquivada ? 'Desarquivar' : 'Arquivar')),
              const PopupMenuItem<String>(value: 'excluir', child: Text('Excluir')),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(backgroundColor: Color(materia.corValor)),
            title: const Text('Total estudado'),
            subtitle: Text(Formato.minutos(materia.minutos)),
          ),
          CronometroCard(materiaId: materia.id),
          Expanded(
            child: sessoes.when(
              loading: () => const EstadoCarregando(),
              error: (Object erro, StackTrace pilha) => EstadoDeErro(
                mensagem: 'Não foi possível ler as sessões desta matéria.',
                aoTentarDeNovo: () => ref.invalidate(sessoesDaMateriaProvider(materia.id)),
              ),
              data: (List<Sessao> lista) => lista.isEmpty
                  ? const EstadoVazio(
                      titulo: 'Nenhuma sessão ainda',
                      mensagem: 'Use o cronômetro acima ou registre os minutos à mão.',
                      icone: Icons.timer_outlined)
                  : ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (BuildContext contexto, int i) {
                        final Sessao sessao = lista[i];
                        return Dismissible(
                          key: ValueKey<String>(sessao.id),
                          direction: DismissDirection.endToStart,
                          background: ColoredBox(
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.delete_outline)),
                            ),
                          ),
                          confirmDismiss: (DismissDirection _) => _confirmar(context,
                              'Remover sessão?', 'Os minutos saem do total da matéria.', 'Remover'),
                          onDismissed: (DismissDirection _) async {
                            // Capture o messenger ANTES do await: depois dele o
                            // context pode não estar mais montado.
                            final ScaffoldMessengerState aviso = ScaffoldMessenger.of(context);
                            await controle.remover(sessao);
                            aviso.showSnackBar(SnackBar(
                              content: const Text('Sessão removida.'),
                              action: SnackBarAction(
                                  label: 'Desfazer',
                                  onPressed: () => controle.registrar(sessao)),
                            ));
                          },
                          child: SessaoTile(sessao: sessao),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### lib/features/estatisticas/presentation/estatisticas_screen.dart

> **Por que ele existe:** mostra a semana inteira com números já agregados em SQL — nada é calculado
> no `build`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formato/formato.dart';
import '../../../core/widgets/estado_carregando.dart';
import '../../../core/widgets/estado_de_erro.dart';
import '../../../core/widgets/estado_vazio.dart';
import '../../materias/domain/materia.dart';
import '../../materias/presentation/materias_controller.dart';
import '../../metas/domain/meta_semanal.dart';
import '../../metas/presentation/widgets/anel_de_meta.dart';
import '../domain/resumo_semanal.dart';
import 'estatisticas_controller.dart';

class EstatisticasScreen extends ConsumerWidget {
  const EstatisticasScreen({super.key});

  String _nomeDaMateria(List<Materia> materias, String id) {
    for (final Materia materia in materias) {
      if (materia.id == id) return materia.nome;
    }
    return '—';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ResumoSemanal> resumo = ref.watch(resumoSemanalProvider);
    final List<Materia> materias = ref.watch(materiasProvider).valueOrNull ?? const <Materia>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: resumo.when(
        loading: () => const EstadoCarregando(),
        error: (Object erro, StackTrace pilha) => EstadoDeErro(
          mensagem: 'Não foi possível calcular as estatísticas da semana.',
          aoTentarDeNovo: () => ref.invalidate(resumoSemanalProvider),
        ),
        data: (ResumoSemanal dados) {
          if (dados.totalMinutos == 0) {
            return const EstadoVazio(
              titulo: 'Semana sem sessões',
              mensagem: 'Registre uma sessão e os números aparecem aqui.',
              icone: Icons.insights_outlined,
            );
          }
          final int maximo = dados.minutosPorDia.reduce((int a, int b) => a > b ? a : b);
          final int diferenca = dados.totalMinutos - dados.minutosSemanaAnterior;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Center(
                child: AnelDeMeta(
                  meta: MetaSemanal(
                      minutosAlvo: dados.metaMinutos, minutosFeitos: dados.totalMinutos),
                ),
              ),
              const SizedBox(height: 16),
              // Barras provisórias: a Etapa 6 troca este bloco por BarrasDaSemana.
              for (int dia = 0; dia < 7; dia++)
                _BarraDoDia(Formato.diasDaSemana[dia], dados.minutosPorDia[dia], maximo),
              const Divider(height: 32),
              ListTile(
                  title: const Text('Total da semana'),
                  trailing: Text(Formato.minutos(dados.totalMinutos))),
              ListTile(
                  title: const Text('Média por dia'),
                  trailing: Text(Formato.minutos(dados.mediaDiariaMinutos))),
              ListTile(
                title: const Text('Contra a semana passada'),
                trailing: Text(
                    '${diferenca >= 0 ? '+' : '−'}${Formato.minutos(diferenca.abs())}'),
              ),
              ListTile(
                title: const Text('Matéria mais estudada'),
                trailing: Text(_nomeDaMateria(materias, dados.materiaMaisEstudadaId)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BarraDoDia extends StatelessWidget {
  const _BarraDoDia(this.rotulo, this.minutos, this.maximo);
  final String rotulo;
  final int minutos;
  final int maximo;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$rotulo, ${Formato.minutos(minutos)}',
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: <Widget>[
                SizedBox(width: 40, child: Text(rotulo)),
                Expanded(
                  child: LinearProgressIndicator(
                      value: maximo == 0 ? 0 : minutos / maximo, minHeight: 14),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 76, child: Text(Formato.minutos(minutos))),
              ],
            ),
          ),
        ),
      );
}
```

### lib/features/configuracoes/presentation/configuracoes_screen.dart

> **Por que ele existe:** meta e tema são do usuário, não do programador — e mudam **sem** reiniciar
> o app.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formato/formato.dart';
import '../../../core/tema/modo_de_tema.dart';
import '../../metas/domain/meta_semanal.dart';
import '../../metas/presentation/meta_controller.dart';
import 'tema_controller.dart';

class ConfiguracoesScreen extends ConsumerWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MetaSemanal> meta = ref.watch(metaSemanalProvider);
    final ModoDeTema modo = ref.watch(modoDeTemaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: <Widget>[
          const ListTile(title: Text('Meta semanal')),
          meta.when(
            loading: () => const LinearProgressIndicator(),
            error: (Object erro, StackTrace pilha) =>
                const ListTile(title: Text('Não foi possível ler a sua meta.')),
            data: (MetaSemanal atual) => _SliderDaMeta(alvo: atual.minutosAlvo),
          ),
          const Divider(),
          const ListTile(title: Text('Tema')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ModoDeTema>(
              segments: const <ButtonSegment<ModoDeTema>>[
                ButtonSegment<ModoDeTema>(value: ModoDeTema.claro, label: Text('Claro')),
                ButtonSegment<ModoDeTema>(value: ModoDeTema.escuro, label: Text('Escuro')),
                ButtonSegment<ModoDeTema>(value: ModoDeTema.sistema, label: Text('Sistema')),
              ],
              selected: <ModoDeTema>{modo},
              onSelectionChanged: (Set<ModoDeTema> escolha) =>
                  ref.read(modoDeTemaProvider.notifier).definir(escolha.first),
            ),
          ),
          const Divider(),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.cleaning_services_outlined),
            title: Text('Limpar cache de trilhas'),
            subtitle: Text('Fica ativo na Etapa 5, junto com a API.'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versão'),
            subtitle: Text('1.0.0+1 — a versão real do pacote chega na Etapa 8.'),
          ),
          const ListTile(
            leading: Text('🍎', style: TextStyle(fontSize: 20)),
            title: Text('Build iOS'),
            subtitle: Text('O código roda no iPhone, mas gerar o .ipa exige macOS com Xcode: '
                'no Windows você prepara o projeto e compila num Mac ou runner de CI.'),
          ),
        ],
      ),
    );
  }
}

class _SliderDaMeta extends ConsumerStatefulWidget {
  const _SliderDaMeta({required this.alvo});
  final int alvo;

  @override
  ConsumerState<_SliderDaMeta> createState() => _SliderDaMetaState();
}

class _SliderDaMetaState extends ConsumerState<_SliderDaMeta> {
  late double _valor = widget.alvo.toDouble();

  @override
  Widget build(BuildContext context) => Slider(
        value: _valor,
        min: 30,
        max: 3000,
        divisions: 99, // (3000 − 30) / 30 = 99 passos de 30 minutos
        label: Formato.minutos(_valor.round()),
        semanticFormatterCallback: (double v) => '${v.round()} minutos por semana',
        onChanged: (double novo) => setState(() => _valor = novo),
        // Grava só ao SOLTAR: arrastar não pode escrever 99 vezes nas preferências.
        onChangeEnd: (double novo) =>
            ref.read(metaSemanalProvider.notifier).definirAlvo(novo.round()),
      );
}
```

---

## ▶️ Rodando

```bash
flutter pub get
flutter analyze
flutter run
```

O app abre no **Painel** vazio, com o botão "Registrar sessão" que joga você na aba Matérias. Toque
no FAB, crie **Cálculo I** em roxo, abra a matéria, aperte **Iniciar**, espere um minuto, **Parar e
registrar** — a folha sobe com os minutos já preenchidos. Volte: o total da matéria subiu, o anel do
Painel girou e `Estatísticas` mostra a barra de hoje. Tente criar **cálculo i** de novo: o campo
reprova antes de o banco ser tocado.

## ✅ Conferência

- [ ] `flutter analyze` termina com **No issues found!**
- [ ] Trocar de aba não empilha rota, e a rolagem da lista se mantém ao voltar.
- [ ] Ir para `Estatísticas` e voltar devolve você à **mesma** aba (RF01).
- [ ] Salvar matéria devolve `true`, mostra o `SnackBar` e a lista atualiza sem `setState` seu.
- [ ] Nome com 1 caractere, com 61 e nome repetido normalizado são rejeitados **no campo**.
- [ ] Digitar algo e apertar voltar abre "Descartar alterações?"; sem digitar, sai direto.
- [ ] O seletor tem 8 cores e cada alvo mede **48 × 48 dp**.
- [ ] Cronômetro: iniciar, pausar, retomar, parar — e o tempo continua certo depois de 2 minutos em segundo plano.
- [ ] Deslizar a sessão pede confirmação, desconta os minutos e o **Desfazer** devolve os dois.
- [ ] Excluir matéria confirma e leva as sessões junto.
- [ ] As quatro telas com dado mostram os **quatro estados**; nenhuma exibe `Exception`.
- [ ] Meta e tema mudam na hora e sobrevivem a fechar e reabrir.
- [ ] Com fonte do sistema em **200%** nenhuma tela corta texto.

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| `type 'Null' is not a subtype of type 'MateriaDetalheArgs'` | `pushNamed` sem `arguments` ou com tipo errado | Passe `MateriaDetalheArgs(materiaId: ...)`; o `is!` do `onGenerateRoute` protege o resto |
| `pushNamed<bool>` devolve sempre `null` | A rota foi criada como `MaterialPageRoute<void>` | O tipo da rota tem de casar: `MaterialPageRoute<bool>` |
| `Looking up a deactivated widget's ancestor is unsafe` | `ScaffoldMessenger.of(context)` depois de um `await` | Capture o messenger **antes** do `await`, ou teste `context.mounted` |
| `setState() called after dispose()` | `setState` depois do `Navigator.pop` | `if (!mounted) return;` logo após cada `await` |
| O `PopScope` não abre o diálogo | `canPop: true` — o pop nem foi bloqueado | `canPop` precisa ser **false** para o callback rodar |
| Trocar de aba zera a rolagem | `switch` no `body` em vez de `IndexedStack` | Volte ao `IndexedStack`: os três filhos ficam vivos |
| Teclado cobre o botão da folha | Falta `isScrollControlled: true` **e** o `viewInsets` | Os dois juntos; um sem o outro não resolve |
| `RenderFlex overflowed` no estado vazio | `Column` no lugar de `ListView` | `EstadoVazio` e `EstadoDeErro` já usam `ListView` — não troque |
| Enter na anotação envia em vez de pular linha | `TextInputAction.done` em campo multilinha | `TextInputAction.newline` quando `maxLines > 1` |
| `The named parameter 'arquivada' isn't defined` | A assinatura do controller da Etapa 3 é outra | Alinhe a chamada com o `MateriasController` que você escreveu lá |

---

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [05 — Etapa 3: Estado com Riverpod](05-etapa-3-estado-com-riverpod.md) | [README do projeto](README.md) | [07 — Etapa 5: API e trilhas](07-etapa-5-api-e-trilhas.md) |
