# Passo a passo — Projeto 01: Meu Primeiro App

> **Pasta:** `meu_primeiro_app` · **Tempo:** ≈ 2 h em 8 etapas ·
> **O que construir:** [01-especificacao.md](01-especificacao.md) ·
> **Gabarito:** [03-codigo-completo.md](03-codigo-completo.md)

> 📌 **Construa junto, não copie do [03](03-codigo-completo.md).** Digite, rode, veja quebrar,
> conserte — código colado passa pelos dedos, código consertado passa pela cabeça. Aqui aparece só
> **o que muda em cada etapa**, e às vezes só a linha que decide: o resto é com você.

> ⚠️ Ao fim de cada etapa o app **roda**. Se a Etapa 4 não abre, não comece a 5.

| Etapa | O que entra | ≈ |
|---|---|---|
| 1 | Projeto criado, `pubspec.yaml` sem pacote externo | 10 min |
| 2 | `tema_app.dart`, `main.dart`, `app.dart`, `HomeTela` vazia | 25 min |
| 3 | `Materia` e as 4 matérias | 15 min |
| 4 | `CartaoMateria` e a seleção com `SnackBar` | 25 min |
| 5 | `ContadorSessoes` e as três ações do dia | 25 min |
| 6 | `SegmentedButton` de duração | 10 min |
| 7 | `BarraResumo` e o rodapé | 20 min |
| 8 | Acabamento, `flutter analyze`, 320 px | 10 min |

---

## Etapa 1 — Criar o projeto e rodar (≈ 10 min)

**Objetivo:** ter um app Flutter em pé, já sem pacote externo no `pubspec.yaml`.

```powershell
flutter create meu_primeiro_app
cd meu_primeiro_app
flutter run -d chrome
```

Abriu o contador padrão do Flutter? Ambiente certo — encerre com `q`. Agora abra o `pubspec.yaml`,
**apague a linha do `cupertino_icons`** (este projeto roda só com o SDK do Flutter), deixe
`sdk: ^3.13.0` no `environment:` e rode `flutter pub get`.

> ✅ **Como saber que funcionou:** `Got dependencies!` no terminal, `dependencies:` com só `flutter`
> dentro, e o app ainda abre no Chrome.

> 🍎 Use `-d chrome` ou `-d windows`. iPhone exigiria Mac com Xcode ou runner macOS em CI — nada
> aqui depende disso.

---

## Etapa 2 — O tema e a raiz do app (≈ 25 min)

**Objetivo:** trocar o contador padrão pela sua tela, com o botão de tema já ciclando.

Em `lib/tema/tema_app.dart` — o **único** arquivo do projeto onde pode existir cor literal (RF05) —
crie `abstract final class TemaApp` com `static const Color _semente = Color(0xFF3F51B5)`,
`static const double espaco = 16` e `raio = 12`, mais os getters `claro` e `escuro`. Os dois temas
saem de um `_construir(Brightness brilho)` só, e diferem **apenas** no brilho (RF04):

```dart
  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get escuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final ColorScheme esquema =
        ColorScheme.fromSeed(seedColor: _semente, brightness: brilho);
    return ThemeData(colorScheme: esquema /* + os 4 sub-temas abaixo */);
  }
```

Dentro do `ThemeData`, quatro sub-temas: `appBarTheme` (`centerTitle: false`, fundo
`esquema.surfaceContainer`, frente `esquema.onSurface`); `cardTheme` — atenção, é
**`CardThemeData`** — com `elevation: 0`, `margin: EdgeInsets.zero` e canto `raio`;
`filledButtonTheme` com `minimumSize: const Size.fromHeight(48)`; e `dividerTheme` com
`esquema.outlineVariant` e `space: espaco * 2`.

Agora `lib/telas/home_tela.dart`. `HomeTela` já nasce `StatefulWidget` —
`const HomeTela({super.key, required this.modoAtual, required this.onAlternarTema})`, os campos
`final ThemeMode modoAtual` / `final VoidCallback onAlternarTema` — mas **sem estado próprio** ainda.
O `build` devolve `Scaffold` → `SafeArea(top: false)` (a `AppBar` já cobre a barra de status) →
`ListView(padding: const EdgeInsets.all(TemaApp.espaco))` com um `Text('Matérias')` solto dentro. Na
`AppBar`, título `'Meu Primeiro App'` e uma única `action`:

```dart
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
```

Em `lib/app.dart` mora o `ThemeMode` — o único estado acima da tela. `MeuPrimeiroApp` é
`StatefulWidget` e seu `build` devolve um `MaterialApp` com `title: 'Meu Primeiro App'`,
`debugShowCheckedModeBanner: false`, os três campos que trabalham juntos (`theme: TemaApp.claro`,
`darkTheme: TemaApp.escuro`, `themeMode: _modo`) e
`home: HomeTela(modoAtual: _modo, onAlternarTema: _alternarTema)`. O ciclo do RF03:

```dart
  ThemeMode _modo = ThemeMode.system;

  // Switch de expressão é exaustivo: se um dia existir um quarto ThemeMode,
  // o compilador avisa exatamente aqui.
  void _alternarTema() {
    setState(() {
      _modo = switch (_modo) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }
```

`lib/main.dart` inteiro vira `void main() { runApp(const MeuPrimeiroApp()); }` mais o import do
`app.dart`. Nada mais entra nele, nunca. Por fim, **apague `test/widget_test.dart`**: ele testa o
`MyApp` que você excluiu e trava o `flutter analyze` — os testes de verdade chegam em
[04-testes.md](04-testes.md).

> ✅ **Como saber que funcionou:** abre uma `AppBar` índigo escrita `Meu Primeiro App`, com
> "Matérias" no corpo. Tocando no ícone da direita, o app inteiro vira claro, depois escuro, depois
> volta ao automático — e o ícone muda junto.

---

## Etapa 3 — O modelo `Materia` (≈ 15 min)

**Objetivo:** ter os dados das 4 matérias na tela, com tempo formatado, antes de existir cartão.

Crie `lib/modelos/materia.dart`. A classe é **imutável**: campos todos `final` (`String id`,
`String nome`, `IconData icone`, `int minutosEstudados`, `int metaMinutos`), construtor `const`
terminando em `: assert(metaMinutos > 0, 'A meta precisa ser maior que zero.')`, e um
`Materia copyWith({int? minutosEstudados})` — só esse parâmetro, é o único campo que o app altera.
Os três valores derivados:

```dart
  /// RF16 — o clamp é o que impede a barra de passar de 100 %.
  double get progresso => (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  /// RF17.
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
```

Abaixo da classe, `const List<Materia> materiasIniciais` com as 4 da especificação —
`dart`/Dart/`Icons.code`/95/120, `flutter`/Flutter/`Icons.phone_android`/40/120,
`git`/Git e terminal/`Icons.terminal`/20/90, `testes`/Testes/`Icons.fact_check_outlined`/0/60. É
`const` de propósito: o "zerar o dia" vai copiar daqui de volta.

Em `home_tela.dart`, importe o modelo e mostre a lista com `Text` **provisórios**:

```dart
  /// `List.of` COPIA. Sem ele, o app alteraria a lista constante e o RF14
  /// não teria para onde voltar.
  List<Materia> _materias = List<Materia>.of(materiasIniciais);

  // ... no ListView, logo depois do Text('Matérias'):
            for (final Materia m in _materias) // provisório: sai na Etapa 4
              Text('${m.nome}: ${m.tempoFormatado} de ${m.metaMinutos} min'),
```

> 💡 Até a Etapa 5 o `flutter analyze` pode sugerir `final` em `_materias`. Ignore: o `_zerarDia`
> vai reatribuir o campo e o aviso some sozinho.

> ✅ **Como saber que funcionou:** quatro linhas na tela, e a primeira lê
> `Dart: 1 h 35 min de 120 min` — prova de que o `tempoFormatado` divide certo. `Testes` mostra
> `0 min`.

---

## Etapa 4 — `CartaoMateria` e a seleção (≈ 25 min)

**Objetivo:** trocar os `Text` crus por cartões com progresso, que reagem ao toque.

Crie `lib/widgets/cartao_materia.dart`: `StatelessWidget` com
`const CartaoMateria({super.key, required this.materia, this.selecionada = false, this.onTap})` —
o objeto `Materia` inteiro, não cinco parâmetros soltos: quem calcula progresso e tempo é o modelo.

O esqueleto é `Card` → `InkWell(onTap: onTap)` → `Padding` → `Row`, com
`CircleAvatar(child: Icon(materia.icone))` à esquerda e, num `Expanded`, uma `Column`: o nome em
`titleMedium` mais `Icon(Icons.check_circle, size: 20)` só `if (materia.metaAtingida)`; o texto
`'${materia.tempoFormatado} de ${materia.metaMinutos} min'`; e um
`LinearProgressIndicator(value: materia.progresso, minHeight: 6)` dentro de um `ClipRRect`. O que
decide a aparência do selecionado (RF09):

```dart
    // Sem estas duas, o texto do cartão selecionado some no tema escuro.
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
```

Em `home_tela.dart`, a seleção (RF07/RF08) e o aviso que você vai reusar o projeto inteiro:

```dart
  String _idSelecionado = 'dart';

  /// Getter, não campo: derivado do id, nunca fica dessincronizado da lista.
  Materia get _materiaSelecionada =>
      _materias.firstWhere((Materia m) => m.id == _idSelecionado);

  void _selecionarMateria(String id) {
    setState(() {
      _idSelecionado = id;
    });
    _avisar('As próximas sessões contam para ${_materiaSelecionada.nome}.');
  }

  void _avisar(String mensagem) {
    // Sem o hide, toques rápidos formam fila e você lê aviso atrasado.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensagem), duration: const Duration(seconds: 2)),
      );
  }
```

Os `Text` provisórios dão lugar aos cartões — gerados da lista, nada de 4 blocos copiados. Antes
deles ficam o `Text('Matérias')` em `titleLarge` e a dica
`'Toque para escolher onde os minutos entram.'` em `bodySmall`:

```dart
            for (final Materia materia in _materias) ...<Widget>[
              CartaoMateria(
                materia: materia,
                selecionada: materia.id == _idSelecionado,
                onTap: () => _selecionarMateria(materia.id),
              ),
              const SizedBox(height: 12),
            ],
```

> ✅ **Como saber que funcionou:** quatro cartões com ícone, nome, tempo e barra; o de Dart nasce
> destacado com borda de 2 px. Tocando em "Git e terminal", o destaque muda e sobe o `SnackBar`
> `As próximas sessões contam para Git e terminal.`. Nenhuma barra passa do fim.

---

## Etapa 5 — `ContadorSessoes` e as três ações (≈ 25 min)

**Objetivo:** fazer o app **contar** — concluir, remover e zerar — sem nunca ficar negativo.

Crie `lib/widgets/contador_sessoes.dart`: `Card` de fundo `cores.primaryContainer` com seis
parâmetros — `int sessoes`, `int duracaoMinutos`, `String nomeMateria` e os `VoidCallback`
`onConcluir`, `onRemover`, `onZerar`. Dentro, uma `Column` com `'Sessões de hoje'` (`titleMedium`),
`'$sessoes'` em `displayLarge` + `FontWeight.bold`,
`'$duracaoMinutos min por sessão em $nomeMateria'` e a linha de botões.

> 📌 Ele é **Stateless**. O número de sessões não mora nele, mora no `_HomeTelaState` — se morasse
> aqui, a `BarraResumo` da Etapa 7 não teria como mostrar o mesmo número.

```dart
    // RF13 — `onPressed: null` apaga a cor, cancela o toque e tira o botão da
    // ordem de foco sozinho. Um `if` dentro do onPressed deixaria cara de ativo.
    final bool temSessao = sessoes > 0;
    // ...
            Row(
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: temSessao ? onRemover : null,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Remover uma sessão',
                ),
                const SizedBox(width: 8),
                Expanded( // é isto que segura a linha inteira em 320 px
                  child: FilledButton.icon(
                    onPressed: onConcluir,
                    icon: const Icon(Icons.add),
                    label: const Text('Concluir sessão',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                // e o IconButton.filledTonal de Icons.refresh,
                // tooltip 'Zerar o dia', também preso ao temSessao
              ],
            ),
```

No `_HomeTelaState`, três contadores — `int _sessoesConcluidas = 0;`, `int _minutosTotais = 0;`,
`int _duracaoMinutos = 25;` — e as ações. O `_registrarSessao()` acha o índice com
`_materias.indexWhere((Materia m) => m.id == _idSelecionado)`, guarda a matéria e faz tudo num
`setState` só (RF11):

```dart
      _sessoesConcluidas++;
      _minutosTotais += _duracaoMinutos;
      _materias[indice] = materia.copyWith(
        minutosEstudados: materia.minutosEstudados + _duracaoMinutos,
      );
      // fora do setState: _avisar('+$_duracaoMinutos min em ${materia.nome}.');
```

O `_removerSessao()` é o espelho, com duas diferenças: começa em
`if (_sessoesConcluidas == 0) { return; }` — o botão já está desabilitado, isto é o cinto de
segurança — e subtrai com `clamp`, que lê como a regra do RF13: *no mínimo zero, no máximo o que já
havia*. O aviso dele é `'−$_duracaoMinutos min em ${materia.nome}.'`:

```dart
      _minutosTotais =
          (_minutosTotais - _duracaoMinutos).clamp(0, _minutosTotais);
      _materias[indice] = materia.copyWith(
        minutosEstudados: (materia.minutosEstudados - _duracaoMinutos)
            .clamp(0, materia.minutosEstudados),
      );
```

O `_zerarDia()` também sai cedo com 0 sessões e faz o RF14 em três linhas dentro do `setState`:
`_materias = List<Materia>.of(materiasIniciais);` mais os dois contadores a zero. Avisa
`'Dia zerado. As matérias voltaram aos minutos iniciais.'`.

No topo do `build`, guarde `final Materia selecionada = _materiaSelecionada;` e ponha o widget no
`ListView`, **antes** do bloco "Matérias":

```dart
            ContadorSessoes(
              sessoes: _sessoesConcluidas,
              duracaoMinutos: _duracaoMinutos,
              nomeMateria: selecionada.nome,
              onConcluir: _registrarSessao,
              onRemover: _removerSessao,
              onZerar: _zerarDia,
            ),
```

> 💡 O sinal do aviso de remoção é `−` (menos matemático, U+2212), não o hífen `-`. Copie o
> caractere daqui.

> ✅ **Como saber que funcionou:** com 0 sessões, `−` e `↺` estão apagados e não aceitam toque. Um
> toque em "Concluir sessão" leva o número a 1, sobe `+25 min em Dart.` e empurra a barra do Dart.
> Remover desfaz. Zerar devolve o Dart aos 95 min.

---

## Etapa 6 — A duração da sessão (≈ 10 min)

**Objetivo:** deixar o usuário escolher se a próxima sessão vale 15, 25 ou 50 minutos.

Um `_mudarDuracao(int minutos)` de três linhas, que só faz
`setState(() { _duracaoMinutos = minutos; });` — RF10: não mexe no que já foi contado, só no que
vem. E, no `ListView`, **acima** do `ContadorSessoes`, um `Text('Duração da sessão')` em
`titleMedium` seguido de:

```dart
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 15, label: Text('15 min')),
                ButtonSegment<int>(value: 25, label: Text('25 min')),
                ButtonSegment<int>(value: 50, label: Text('50 min')),
              ],
              // `selected` é um Set porque o widget suporta seleção múltipla;
              // aqui ele tem sempre um item só.
              selected: <int>{_duracaoMinutos},
              // Sem o ✓: em 320 px ele é a diferença entre caber e estourar.
              showSelectedIcon: false,
              onSelectionChanged: (Set<int> selecao) =>
                  _mudarDuracao(selecao.first),
            ),
```

> ✅ **Como saber que funcionou:** `25 min` nasce marcado. Escolhendo `50 min`, o cartão passa a ler
> `50 min por sessão em Dart` e a próxima sessão soma 50, não 25 — mas o que já estava contado não
> muda.

---

## Etapa 7 — `BarraResumo` e o rodapé (≈ 20 min)

**Objetivo:** fechar a tela com o placar do dia no topo e a confirmação do RF07 embaixo.

Crie `lib/widgets/barra_resumo.dart` com `int sessoesConcluidas`, `int minutosTotais` e
`String materiaEmFoco`. É um `Card` de cor `cores.surfaceContainerHighest` com: `'Resumo do dia'`,
uma `Row` de três métricas, um `Divider` e a linha `'Em foco: $materiaEmFoco'` (com
`Icons.center_focus_strong_outlined`, dentro de `Expanded`, `maxLines: 1` e
`overflow: TextOverflow.ellipsis`). As métricas são `Icons.check_circle_outline`/`'Sessões'`,
`Icons.schedule`/`'Minutos'` e `Icons.trending_up`/`'Média'`, **cada uma dentro de um `Expanded`** —
com larguras iguais a linha cabe em 320 px.

O getter que evita o bug mais fácil do projeto — dividir por zero em Dart **não** estoura, devolve
`NaN`, e `NaN min` na tela é pior do que travar:

```dart
  /// RF19.
  String get _media {
    if (sessoesConcluidas == 0) {
      return '—';
    }
    return '${(minutosTotais / sessoesConcluidas).round()} min';
  }
```

No mesmo arquivo, abaixo, a classe **privada** `_Metrica` — `StatelessWidget` com
`{required IconData icone, required String valor, required String rotulo}` — desenhando uma `Column`
com `Icon(icone, size: 20, color: cores.primary)`, o valor em `titleLarge` e o rótulo em `bodySmall`
na cor `onSurfaceVariant`. Privada porque só a `BarraResumo` usa.

No `ListView`, a `BarraResumo` vira o **primeiro** filho e o rodapé, o último:

```dart
            BarraResumo(
              sessoesConcluidas: _sessoesConcluidas,
              minutosTotais: _minutosTotais,
              materiaEmFoco: selecionada.nome,
            ),
            // ... duração, contador, matérias, e no fim:
            Center(
              child: Text('Recebendo minutos: ${selecionada.nome}',
                  style: tema.textTheme.labelLarge),
            ),
```

> ✅ **Como saber que funcionou:** com 0 sessões a média mostra `—`, nunca `NaN`. Duas sessões de 50
> e uma de 15 dão `3 · 115 · 38 min`. Trocando a matéria, "Em foco:" e o rodapé mudam juntos.

---

## Etapa 8 — Acabamento e conferência (≈ 10 min)

**Objetivo:** entregar sem aviso do analisador e sem estouro de layout.

```powershell
flutter analyze
findstr /S /N "Colors\. Color(0x" lib\*.dart
```

O primeiro precisa responder `No issues found!`; o segundo, devolver **uma** linha — a semente em
`tema_app.dart` (RF05). Depois, com o app no Chrome, estreite a janela até ≈ 320 px e role a tela
inteira: nenhuma faixa amarela e preta de `RenderFlex overflowed` pode aparecer. Confira também a
ordem final do `ListView`: `BarraResumo` → "Duração da sessão" → `SegmentedButton` →
`ContadorSessoes` → "Matérias" + dica → 4 × `CartaoMateria` → rodapé.

> ✅ **Como saber que funcionou:** `No issues found!`, nada de overflow em 320 px e uma única cor
> literal no projeto. Feche e reabra o app: tudo volta ao início, e isso é intencional (RF20) —
> persistência é o [Módulo 10](../../modulos/10-persistencia-de-dados/README.md).

Só agora abra o [03-codigo-completo.md](03-codigo-completo.md) e compare. Onde ficou diferente,
pergunte-se qual das duas versões você consegue explicar. Depois feche os 20 itens do
[06-checklist.md](06-checklist.md).

---

## ⚠️ Se algo der errado

| Sintoma | Causa provável | Correção |
|---|---|---|
| `Target of URI doesn't exist: 'package:meu_primeiro_app/...'` | Arquivo em pasta errada, ou `name:` do `pubspec.yaml` diferente de `meu_primeiro_app` | Confira caminho e `name:`, depois `flutter pub get` |
| `Undefined name 'MyApp'` em `test/widget_test.dart` | O teste do `flutter create` ainda aponta para o app antigo | Apague o arquivo (Etapa 2); ele volta em [04-testes.md](04-testes.md) |
| `The argument type 'CardTheme' can't be assigned to 'CardThemeData?'` | Escreveu `CardTheme` no `cardTheme:` | Troque por `CardThemeData` |
| `RenderFlex overflowed by N pixels on the right` | "Concluir sessão" sem `Expanded`, ou `showSelectedIcon` ligado | `Expanded` no `FilledButton.icon` e `showSelectedIcon: false` |
| `Bad state: No element` ao abrir | `_idSelecionado` não bate com nenhum `id` da lista | Os ids são `'dart'`, `'flutter'`, `'git'`, `'testes'`, minúsculos |
| A tela não muda ao tocar | Alterou o campo **fora** do `setState` | Mova a atribuição para dentro do `setState(() { ... })` |
| Média aparece como `NaN min` | Dividiu por zero com 0 sessões | O `if (sessoesConcluidas == 0) return '—';` no getter `_media` |
| Minutos negativos ao remover | Subtração sem `clamp` | `(x - _duracaoMinutos).clamp(0, x)` nos **dois** lugares |
| A barra de progresso passa do fim | `value` maior que `1.0` | `(minutosEstudados / metaMinutos).clamp(0.0, 1.0)` |
| "Zerar o dia" não restaura os minutos originais | O State usou `materiasIniciais` direto, sem copiar | `List<Materia>.of(materiasIniciais)` na declaração **e** no `_zerarDia` |
| `SnackBar` empilhando e aparecendo atrasado | Faltou fechar o anterior | `..hideCurrentSnackBar()` antes do `..showSnackBar(...)` |
| Tocar no ícone não muda o tema | `themeMode: _modo` esquecido, ou `setState` no widget errado | `_alternarTema` mora no `_MeuPrimeiroAppState`; a `HomeTela` só recebe o `VoidCallback` |
| `flutter run -d chrome` não acha o dispositivo | Chrome não instalado ou não detectado | `flutter devices`; se preciso, use `-d windows` |

---

| Arquivo | Para quê |
|---|---|
| [README](README.md) | Visão geral |
| [01-especificacao](01-especificacao.md) | O que construir |
| **02-passo-a-passo.md** | 📍 Você está aqui |
| [03-codigo-completo](03-codigo-completo.md) | Arquivos finais |
| [04-testes](04-testes.md) | Validar com `flutter test` |
| [05-desafios](05-desafios.md) | Extensões ([gabarito](../../gabaritos/projeto-01-desafios.md)) |
| [06-checklist](06-checklist.md) | Critérios de "pronto" |
