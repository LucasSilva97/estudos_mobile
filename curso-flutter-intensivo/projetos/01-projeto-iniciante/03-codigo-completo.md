# Código completo — Projeto 01: Meu Primeiro App

> **Pasta:** `meu_primeiro_app` · **Referência:** [01-especificacao.md](01-especificacao.md) ·
> **Construção guiada:** [02-passo-a-passo.md](02-passo-a-passo.md)

> ⚠️ **Este arquivo é para CONFERIR, não para copiar.** Se você colar tudo isto antes de
> construir, o projeto fica pronto e você não aprende nada — o dedo digitou, a cabeça não.
> Construa pelo [passo a passo](02-passo-a-passo.md), trave, tente resolver, e **só então** abra
> aqui para comparar. A comparação é a parte útil: onde o seu código ficou diferente, pergunte-se
> qual das duas versões você consegue explicar.

> 📌 São **8 arquivos em `lib/`** mais o `pubspec.yaml`. Nenhum está abreviado: cada bloco abaixo
> é o arquivo inteiro, do primeiro `import` à última chave.

---

## 📁 pubspec.yaml

O `flutter create` gera este arquivo com `cupertino_icons` em `dependencies`. **Apague essa linha.**
O Projeto 01 não tem pacote externo nenhum — só o SDK do Flutter.

```yaml
name: meu_primeiro_app
description: "Contador de sessões de estudo — Projeto 01 do curso intensivo."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

> 💡 O `analysis_options.yaml` fica **exatamente** como o `flutter create` deixou
> (`include: package:flutter_lints/flutter.yaml`). Neste projeto você não precisa mexer nele.

---

## 📦 Os arquivos de `lib/`

A ordem abaixo é a de **dependência**: cada arquivo só usa o que já apareceu antes dele.

| # | Arquivo | Depende de |
|---|---|---|
| 1 | `lib/modelos/materia.dart` | nada além do Flutter |
| 2 | `lib/tema/tema_app.dart` | nada além do Flutter |
| 3 | `lib/widgets/barra_resumo.dart` | `tema_app.dart` |
| 4 | `lib/widgets/contador_sessoes.dart` | `tema_app.dart` |
| 5 | `lib/widgets/cartao_materia.dart` | `materia.dart`, `tema_app.dart` |
| 6 | `lib/telas/home_tela.dart` | os 5 anteriores |
| 7 | `lib/app.dart` | `home_tela.dart`, `tema_app.dart` |
| 8 | `lib/main.dart` | `app.dart` |

---

### lib/modelos/materia.dart

> **O que este arquivo faz:** define a matéria de estudo — imutável, com os três valores derivados
> (progresso, meta atingida, tempo formatado) e a lista fixa das 4 matérias iniciais.

```dart
import 'package:flutter/material.dart';

/// Matéria de estudo. Imutável: para alterar minutos, use [copyWith].
///
/// Tudo aqui é `final`. O que muda com o uso do app é a **lista** guardada no
/// `_HomeTelaState`, não o objeto — trocar um item por uma cópia é mais
/// previsível do que deixar campos mutáveis espalhados pela tela.
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.icone,
    required this.minutosEstudados,
    required this.metaMinutos,
  }) : assert(metaMinutos > 0, 'A meta precisa ser maior que zero.');

  /// Identificador estável, usado para saber qual matéria está selecionada.
  /// Não é o nome: o nome é texto de interface e pode mudar.
  final String id;

  /// Nome exibido. Ex.: "Git e terminal".
  final String nome;

  /// Ícone à esquerda no cartão.
  final IconData icone;

  /// Minutos já estudados nesta matéria.
  final int minutosEstudados;

  /// Meta de minutos. O `assert` do construtor garante que nunca é zero —
  /// é ela que vira denominador em [progresso].
  final int metaMinutos;

  /// RF16 — o `clamp` é o que impede a barra de passar de 100 %.
  double get progresso => (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  /// RF17 — usado pelo cartão para exibir o selo de meta cumprida.
  bool get metaAtingida => minutosEstudados >= metaMinutos;

  /// RF18 — "45 min", "2 h" ou "1 h 15 min".
  String get tempoFormatado {
    final int horas = minutosEstudados ~/ 60;
    final int restante = minutosEstudados % 60;
    if (horas == 0) {
      return '$restante min';
    }
    return restante == 0 ? '$horas h' : '$horas h $restante min';
  }

  /// Só `minutosEstudados` é parâmetro: é o único campo que o app altera.
  /// Um `copyWith` com cinco opcionais que ninguém usa é peso morto.
  Materia copyWith({int? minutosEstudados}) {
    return Materia(
      id: id,
      nome: nome,
      icone: icone,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaMinutos: metaMinutos,
    );
  }
}

/// RF06 — as 4 matérias do app.
///
/// É `const` de propósito: o RF14 ("zerar o dia") copia daqui de volta, e uma
/// lista constante não tem como ter sido alterada por engano no meio do uso.
const List<Materia> materiasIniciais = <Materia>[
  Materia(
    id: 'dart',
    nome: 'Dart',
    icone: Icons.code,
    minutosEstudados: 95,
    metaMinutos: 120,
  ),
  Materia(
    id: 'flutter',
    nome: 'Flutter',
    icone: Icons.phone_android,
    minutosEstudados: 40,
    metaMinutos: 120,
  ),
  Materia(
    id: 'git',
    nome: 'Git e terminal',
    icone: Icons.terminal,
    minutosEstudados: 20,
    metaMinutos: 90,
  ),
  Materia(
    id: 'testes',
    nome: 'Testes',
    icone: Icons.fact_check_outlined,
    minutosEstudados: 0,
    metaMinutos: 60,
  ),
];
```

---

### lib/tema/tema_app.dart

> **O que este arquivo faz:** gera os temas claro e escuro a partir de **uma** cor semente e guarda
> as duas medidas que o app inteiro reutiliza (`espaco` e `raio`).

```dart
import 'package:flutter/material.dart';

/// Temas do aplicativo, claro e escuro, gerados de uma única cor semente.
///
/// A classe é `abstract final` para deixar explícito que ela nunca é
/// instanciada: serve só como espaço de nomes.
///
/// RF05 — este é o ÚNICO arquivo do projeto com cor literal. Em qualquer outro
/// lugar, cor vem de `Theme.of(context).colorScheme`.
abstract final class TemaApp {
  /// A cor da identidade do app. Trocar esta linha muda o app inteiro.
  static const Color _semente = Color(0xFF3F51B5); // índigo

  /// Espaçamento padrão, usado em toda a interface.
  static const double espaco = 16;

  /// Raio de canto padrão dos cartões.
  static const double raio = 12;

  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData get escuro => _construir(Brightness.dark);

  /// Monta o ThemeData. Os dois temas compartilham TUDO menos o brilho —
  /// é isso que garante que o modo escuro não vire um app diferente (RF04).
  static ThemeData _construir(Brightness brilho) {
    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: _semente,
      brightness: brilho,
    );

    return ThemeData(
      colorScheme: esquema,

      // ── Barra superior ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false, // padrão do Material; no iOS o Flutter centraliza
        backgroundColor: esquema.surfaceContainer,
        foregroundColor: esquema.onSurface,
      ),

      // ── Cartões ───────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero, // o espaçamento é da tela, não do cartão
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raio),
        ),
      ),

      // ── Botões ────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48), // alvo de toque confortável
        ),
      ),

      // ── Divisores ─────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: esquema.outlineVariant,
        space: espaco * 2,
      ),
    );
  }
}
```

---

### lib/widgets/barra_resumo.dart

> **O que este arquivo faz:** mostra o placar do dia — sessões, minutos, média e matéria em foco —
> sem guardar nada: recebe três valores prontos e desenha.

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/tema/tema_app.dart';

/// Faixa de resumo do dia (RF19).
///
/// StatelessWidget puro: não sabe de onde vêm os números nem quem os muda.
class BarraResumo extends StatelessWidget {
  const BarraResumo({
    super.key,
    required this.sessoesConcluidas,
    required this.minutosTotais,
    required this.materiaEmFoco,
  });

  /// Quantas sessões foram concluídas hoje.
  final int sessoesConcluidas;

  /// Soma dos minutos de todas as sessões de hoje.
  final int minutosTotais;

  /// Nome da matéria que está recebendo os minutos.
  final String materiaEmFoco;

  /// Média por sessão. Com zero sessões devolve "—": dividir por zero em Dart
  /// não estoura, devolve `NaN` — e "NaN min" na tela é pior do que travar.
  String get _media {
    if (sessoesConcluidas == 0) {
      return '—';
    }
    return '${(minutosTotais / sessoesConcluidas).round()} min';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;

    return Card(
      color: cores.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(TemaApp.espaco),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Resumo do dia', style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),

            // Cada métrica dentro de um Expanded: com três colunas de larguras
            // iguais, a linha cabe até em 320 px sem estourar.
            Row(
              children: <Widget>[
                Expanded(
                  child: _Metrica(
                    icone: Icons.check_circle_outline,
                    valor: '$sessoesConcluidas',
                    rotulo: 'Sessões',
                  ),
                ),
                Expanded(
                  child: _Metrica(
                    icone: Icons.schedule,
                    valor: '$minutosTotais',
                    rotulo: 'Minutos',
                  ),
                ),
                Expanded(
                  child: _Metrica(
                    icone: Icons.trending_up,
                    valor: _media,
                    rotulo: 'Média',
                  ),
                ),
              ],
            ),

            const Divider(),

            Row(
              children: <Widget>[
                Icon(
                  Icons.center_focus_strong_outlined,
                  size: 18,
                  color: cores.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Em foco: $materiaEmFoco',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: cores.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Um número com rótulo e ícone. Privado: só a [BarraResumo] usa.
class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.icone,
    required this.valor,
    required this.rotulo,
  });

  final IconData icone;
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;

    return Column(
      children: <Widget>[
        Icon(icone, size: 20, color: cores.primary),
        const SizedBox(height: 4),
        Text(
          valor,
          style: tema.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          rotulo,
          style: tema.textTheme.bodySmall?.copyWith(
            color: cores.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
```

---

### lib/widgets/contador_sessoes.dart

> **O que este arquivo faz:** mostra o número grande de sessões e os três botões de ação —
> concluir, remover e zerar — devolvendo cada toque ao pai por `VoidCallback`.

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/tema/tema_app.dart';

/// Painel de sessões concluídas.
///
/// Repare que ele é **Stateless**: o número de sessões não mora aqui, mora no
/// `_HomeTelaState`. Se morasse aqui, a `BarraResumo` não teria como saber dele.
class ContadorSessoes extends StatelessWidget {
  const ContadorSessoes({
    super.key,
    required this.sessoes,
    required this.duracaoMinutos,
    required this.nomeMateria,
    required this.onConcluir,
    required this.onRemover,
    required this.onZerar,
  });

  /// Sessões concluídas hoje.
  final int sessoes;

  /// Duração escolhida no `SegmentedButton`, em minutos.
  final int duracaoMinutos;

  /// Nome da matéria que vai receber os minutos.
  final String nomeMateria;

  /// Toque em "Concluir sessão".
  final VoidCallback onConcluir;

  /// Toque em "−". Só é chamado quando existe sessão para remover.
  final VoidCallback onRemover;

  /// Toque em "↺". Só é chamado quando existe algo para zerar.
  final VoidCallback onZerar;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;

    // RF13 — com zero sessões, os dois botões destrutivos ficam desligados.
    // `onPressed: null` é o jeito do Flutter de desabilitar: ele também apaga
    // a cor e cancela o efeito de toque, sem você escrever nada a mais.
    final bool temSessao = sessoes > 0;

    return Card(
      color: cores.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TemaApp.espaco,
          vertical: TemaApp.espaco * 1.5,
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Sessões de hoje',
              style: tema.textTheme.titleMedium?.copyWith(
                color: cores.onPrimaryContainer,
              ),
            ),
            Text(
              '$sessoes',
              style: tema.textTheme.displayLarge?.copyWith(
                color: cores.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$duracaoMinutos min por sessão em $nomeMateria',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: cores.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TemaApp.espaco),
            Row(
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: temSessao ? onRemover : null,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Remover uma sessão',
                ),
                const SizedBox(width: 8),

                // Expanded: o botão do meio ocupa o que sobrar. É isto que
                // segura a linha inteira em telas de 320 px sem overflow.
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onConcluir,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Concluir sessão',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: temSessao ? onZerar : null,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Zerar o dia',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### lib/widgets/cartao_materia.dart

> **O que este arquivo faz:** desenha uma matéria — ícone, nome, tempo, meta, barra e selo — e
> muda de aparência quando é a selecionada.

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/modelos/materia.dart';
import 'package:meu_primeiro_app/tema/tema_app.dart';

/// Cartão de uma matéria de estudo (RF15, RF17).
///
/// Recebe o objeto [Materia] inteiro, e não cinco parâmetros soltos: quem
/// calcula progresso e tempo é o modelo, não a interface.
class CartaoMateria extends StatelessWidget {
  const CartaoMateria({
    super.key,
    required this.materia,
    this.selecionada = false,
    this.onTap,
  });

  /// A matéria a desenhar.
  final Materia materia;

  /// RF09 — quando `true`, o cartão ganha fundo e borda próprios.
  final bool selecionada;

  /// Ação ao tocar. Nulo desliga o toque e o efeito visual de uma vez só.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;

    // Duas cores de texto calculadas a partir do estado: sem isto, o texto do
    // cartão selecionado fica ilegível no tema escuro.
    final Color corTexto =
        selecionada ? cores.onSecondaryContainer : cores.onSurface;
    final Color corApoio =
        selecionada ? cores.onSecondaryContainer : cores.onSurfaceVariant;

    return Card(
      clipBehavior: Clip.antiAlias, // faz o efeito de toque respeitar o canto
      color: selecionada ? cores.secondaryContainer : cores.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TemaApp.raio),
        side: BorderSide(
          color: selecionada ? cores.secondary : cores.outlineVariant,
          width: selecionada ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(TemaApp.espaco),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor:
                    selecionada ? cores.secondary : cores.primaryContainer,
                foregroundColor:
                    selecionada ? cores.onSecondary : cores.onPrimaryContainer,
                child: Icon(materia.icone),
              ),
              const SizedBox(width: TemaApp.espaco),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            materia.nome,
                            style: tema.textTheme.titleMedium?.copyWith(
                              color: corTexto,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (materia.metaAtingida)
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: selecionada ? cores.secondary : cores.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${materia.tempoFormatado} de ${materia.metaMinutos} min',
                      style: tema.textTheme.bodySmall?.copyWith(color: corApoio),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: materia.progresso,
                        minHeight: 6,
                        color: selecionada ? cores.secondary : cores.primary,
                        // Trilha derivada da própria cor do texto: assim ela
                        // aparece nos dois fundos e nos dois temas.
                        backgroundColor: corApoio.withValues(alpha: 0.15),
                      ),
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

---

### lib/telas/home_tela.dart

> **O que este arquivo faz:** guarda **todo** o estado do dia — matérias, seleção, sessões, minutos
> e duração — e monta a tela única na ordem da especificação.

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/modelos/materia.dart';
import 'package:meu_primeiro_app/tema/tema_app.dart';
import 'package:meu_primeiro_app/widgets/barra_resumo.dart';
import 'package:meu_primeiro_app/widgets/cartao_materia.dart';
import 'package:meu_primeiro_app/widgets/contador_sessoes.dart';

/// A única tela do app (RF01).
class HomeTela extends StatefulWidget {
  const HomeTela({
    super.key,
    required this.modoAtual,
    required this.onAlternarTema,
  });

  /// Modo de tema em uso. Serve para desenhar o ícone certo no botão.
  final ThemeMode modoAtual;

  /// Chamado quando o usuário toca no botão de tema. Quem troca o tema de
  /// verdade é o `MeuPrimeiroApp`: o estado mora onde ele é usado.
  final VoidCallback onAlternarTema;

  @override
  State<HomeTela> createState() => _HomeTelaState();
}

class _HomeTelaState extends State<HomeTela> {
  /// Cópia editável da lista constante. `List.of` copia; sem ele, o app
  /// alteraria `materiasIniciais` e o "zerar o dia" não teria para onde voltar.
  List<Materia> _materias = List<Materia>.of(materiasIniciais);

  /// RF07 — sempre exatamente uma selecionada, começando em 'dart'.
  String _idSelecionado = 'dart';

  int _sessoesConcluidas = 0;
  int _minutosTotais = 0;

  /// RF10 — 15, 25 ou 50. Vale para a próxima sessão concluída ou removida.
  int _duracaoMinutos = 25;

  /// A matéria que recebe os minutos. É getter: derivado de [_idSelecionado],
  /// então nunca fica dessincronizado com a lista.
  Materia get _materiaSelecionada =>
      _materias.firstWhere((Materia m) => m.id == _idSelecionado);

  // ── Ações ─────────────────────────────────────────────────────────────────

  /// RF11 — +1 sessão, +duração nos totais e na matéria selecionada.
  void _registrarSessao() {
    final int indice =
        _materias.indexWhere((Materia m) => m.id == _idSelecionado);
    final Materia materia = _materias[indice];

    setState(() {
      _sessoesConcluidas++;
      _minutosTotais += _duracaoMinutos;
      _materias[indice] = materia.copyWith(
        minutosEstudados: materia.minutosEstudados + _duracaoMinutos,
      );
    });

    _avisar('+$_duracaoMinutos min em ${materia.nome}.');
  }

  /// RF12 e RF13 — desfaz uma sessão usando a duração ATUAL, sem deixar nenhum
  /// número negativo.
  void _removerSessao() {
    if (_sessoesConcluidas == 0) {
      return; // o botão já está desabilitado; isto é o cinto de segurança
    }

    final int indice =
        _materias.indexWhere((Materia m) => m.id == _idSelecionado);
    final Materia materia = _materias[indice];

    setState(() {
      _sessoesConcluidas--;
      // clamp(0, valorAtual) = "no mínimo zero, no máximo o que já havia".
      _minutosTotais =
          (_minutosTotais - _duracaoMinutos).clamp(0, _minutosTotais);
      _materias[indice] = materia.copyWith(
        minutosEstudados: (materia.minutosEstudados - _duracaoMinutos)
            .clamp(0, materia.minutosEstudados),
      );
    });

    _avisar('−$_duracaoMinutos min em ${materia.nome}.');
  }

  /// RF14 — volta ao estado inicial das 4 matérias.
  void _zerarDia() {
    if (_sessoesConcluidas == 0) {
      return;
    }

    setState(() {
      _materias = List<Materia>.of(materiasIniciais);
      _sessoesConcluidas = 0;
      _minutosTotais = 0;
    });

    _avisar('Dia zerado. As matérias voltaram aos minutos iniciais.');
  }

  /// RF08 — troca a seleção e conta ao usuário para onde vão os minutos.
  void _selecionarMateria(String id) {
    setState(() {
      _idSelecionado = id;
    });

    _avisar('As próximas sessões contam para ${_materiaSelecionada.nome}.');
  }

  /// RF10 — muda quanto vale a próxima sessão. Não mexe no que já foi contado.
  void _mudarDuracao(int minutos) {
    setState(() {
      _duracaoMinutos = minutos;
    });
  }

  /// Aviso curto na base da tela.
  void _avisar(String mensagem) {
    // Fecha o aviso anterior antes de abrir o novo: sem `hideCurrentSnackBar`,
    // toques rápidos formam fila e o usuário lê mensagens atrasadas.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Materia selecionada = _materiaSelecionada;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Primeiro App'),
        actions: <Widget>[
          IconButton(
            // RF03 — o ícone conta ao usuário qual é o modo atual.
            icon: Icon(switch (widget.modoAtual) {
              ThemeMode.system => Icons.brightness_auto_outlined,
              ThemeMode.light => Icons.light_mode_outlined,
              ThemeMode.dark => Icons.dark_mode_outlined,
            }),
            tooltip: switch (widget.modoAtual) {
              ThemeMode.system => 'Tema: automático',
              ThemeMode.light => 'Tema: claro',
              ThemeMode.dark => 'Tema: escuro',
            },
            onPressed: widget.onAlternarTema,
          ),
        ],
      ),
      body: SafeArea(
        // top: false porque a AppBar já cuida da barra de status.
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(TemaApp.espaco),
          children: <Widget>[
            BarraResumo(
              sessoesConcluidas: _sessoesConcluidas,
              minutosTotais: _minutosTotais,
              materiaEmFoco: selecionada.nome,
            ),
            const SizedBox(height: TemaApp.espaco * 1.5),

            Text('Duração da sessão', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 15, label: Text('15 min')),
                ButtonSegment<int>(value: 25, label: Text('25 min')),
                ButtonSegment<int>(value: 50, label: Text('50 min')),
              ],
              // `selected` é um Set porque o widget também suporta seleção
              // múltipla; aqui ele tem sempre um item só.
              selected: <int>{_duracaoMinutos},
              // Sem o ✓ ao lado do rótulo: em 320 px ele é a diferença entre
              // caber e estourar.
              showSelectedIcon: false,
              onSelectionChanged: (Set<int> selecao) =>
                  _mudarDuracao(selecao.first),
            ),
            const SizedBox(height: TemaApp.espaco * 1.5),

            ContadorSessoes(
              sessoes: _sessoesConcluidas,
              duracaoMinutos: _duracaoMinutos,
              nomeMateria: selecionada.nome,
              onConcluir: _registrarSessao,
              onRemover: _removerSessao,
              onZerar: _zerarDia,
            ),
            const SizedBox(height: TemaApp.espaco * 1.5),

            Text('Matérias', style: tema.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Toque para escolher onde os minutos entram.',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // Um cartão por matéria, gerado da lista — nada de 4 blocos
            // copiados e colados.
            for (final Materia materia in _materias) ...<Widget>[
              CartaoMateria(
                materia: materia,
                selecionada: materia.id == _idSelecionado,
                onTap: () => _selecionarMateria(materia.id),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 8),
            Center(
              child: Text(
                'Recebendo minutos: ${selecionada.nome}',
                style: tema.textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### lib/app.dart

> **O que este arquivo faz:** é a raiz do app — guarda o `ThemeMode` escolhido e entrega `theme`,
> `darkTheme` e `themeMode` ao `MaterialApp`.

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/telas/home_tela.dart';
import 'package:meu_primeiro_app/tema/tema_app.dart';

/// Raiz do aplicativo.
///
/// É StatefulWidget porque guarda o ThemeMode escolhido pelo usuário. No
/// Módulo 08 esse estado sai daqui e vai para um provider; no Módulo 10 ele
/// passa a ser gravado no aparelho. Aqui ele morre ao fechar o app — RF20.
class MeuPrimeiroApp extends StatefulWidget {
  const MeuPrimeiroApp({super.key});

  @override
  State<MeuPrimeiroApp> createState() => _MeuPrimeiroAppState();
}

class _MeuPrimeiroAppState extends State<MeuPrimeiroApp> {
  /// system = segue o aparelho. É o padrão recomendado.
  ThemeMode _modo = ThemeMode.system;

  /// RF03 — o ciclo. O `switch` de expressão é exaustivo: se um dia existir um
  /// quarto `ThemeMode`, o compilador avisa exatamente aqui.
  void _alternarTema() {
    setState(() {
      _modo = switch (_modo) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Primeiro App',
      debugShowCheckedModeBanner: false,

      // Os três campos que trabalham juntos:
      theme: TemaApp.claro,
      darkTheme: TemaApp.escuro,
      themeMode: _modo,

      home: HomeTela(
        modoAtual: _modo,
        onAlternarTema: _alternarTema,
      ),
    );
  }
}
```

---

### lib/main.dart

> **O que este arquivo faz:** só entrega o app ao Flutter. Uma linha de corpo — quem configura
> qualquer coisa é o `app.dart`.

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/app.dart';

/// Ponto de entrada. Mantenha-o curto: assim o `main.dart` nunca vira o
/// arquivo-lixão onde tudo é adicionado "só por enquanto".
void main() {
  runApp(const MeuPrimeiroApp());
}
```

---

## 🔍 As decisões que valem explicar

| Decisão | Por quê |
|---|---|
| `Materia` imutável com `copyWith`, em vez de campos mutáveis | Alterar um item é trocá-lo por uma cópia. Não existe meio caminho: ou o `setState` rodou com o valor novo, ou não rodou. É o mesmo hábito que o Riverpod vai exigir no Módulo 08. |
| `materiasIniciais` é `const` e o State usa `List.of(...)` | O RF14 copia da lista original de volta. Se o State usasse a lista direto, o "zerar o dia" restauraria os valores **já alterados** — bug clássico e difícil de enxergar. |
| Todo o estado do dia no `_HomeTelaState`, nenhum nos widgets filhos | A `BarraResumo` e o `ContadorSessoes` mostram o **mesmo** número de sessões. Se o contador guardasse o seu, os dois divergiriam no primeiro toque. Um dado, um dono. |
| Filhos recebem `VoidCallback`, não a lógica | O filho sabe *que houve um toque*; o pai sabe *o que fazer*. É o que permite testar `CartaoMateria` isolado, sem app nenhum em volta. |
| `clamp` em vez de `if (valor < 0)` | O RF13 vira uma expressão só, no mesmo lugar em que a subtração acontece. `(x - d).clamp(0, x)` lê como a regra: "no mínimo zero, no máximo o que já havia". |
| `onPressed: null` para desabilitar botão | O Flutter apaga a cor, cancela o efeito de toque e tira o botão da ordem de foco sozinho. Um `if` dentro do `onPressed` deixaria o botão com cara de ativo. |
| `Expanded` no "Concluir sessão" e `showSelectedIcon: false` no `SegmentedButton` | São as duas linhas que seguram a largura do app. Sem elas, o `RenderFlex overflowed` aparece por volta de 360 px — e o RF20 exige 320 px limpos. |
| `TemaApp.espaco` e `TemaApp.raio` em vez de `16` e `12` soltos | Espaçamento e canto viram decisão de projeto, não digitação. Mudar o respiro do app inteiro passa a ser uma linha — a mesma ideia que o `ColorScheme.fromSeed` aplica às cores. |

---

## ✅ Antes de dar por pronto

```powershell
flutter analyze
flutter run -d chrome
```

O `analyze` precisa responder `No issues found!`. Depois percorra os 20 requisitos em
[06-checklist.md](06-checklist.md) — é ele, e não este arquivo, que diz se o projeto acabou.

> 🍎 Nada aqui depende de iPhone. Rodar em iOS exigiria um Mac com Xcode ou um runner macOS em CI;
> no Windows 11, `-d chrome` e `-d windows` cobrem o projeto inteiro.

---

| Arquivo | Para quê |
|---|---|
| [README](README.md) | Visão geral |
| [01-especificacao](01-especificacao.md) | O que construir |
| [02-passo-a-passo](02-passo-a-passo.md) | Construção guiada |
| **03-codigo-completo.md** | 📍 Você está aqui |
| [04-testes](04-testes.md) | Validar com `flutter test` |
| [05-desafios](05-desafios.md) | Extensões ([gabarito](../../gabaritos/projeto-01-desafios.md)) |
| [06-checklist](06-checklist.md) | Critérios de "pronto" |
