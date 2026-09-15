# Aula 12 — Estados de UI

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Nomear os **quatro estados** que toda tela que busca dados tem: carregando, vazio, sucesso e
  erro — e reconhecer que esquecer um deles é a causa mais comum de app "quebrado".
- Construir widgets **reutilizáveis** para cada estado, em vez de repetir `if` em cada tela.
- Modelar o estado de uma tela com um **`sealed class`**, para que o compilador **exija** que você
  trate todos os casos.
- Escolher entre **`CircularProgressIndicator`**, **esqueleto** (*skeleton*) e **placeholder**, e
  justificar.
- Escrever telas de erro que o usuário **consegue resolver**, com ação de repetir.
- Diferenciar **vazio por falta de dados** de **vazio por filtro** — dois estados que parecem
  iguais e exigem textos diferentes.
- Fechar o módulo com uma `MateriasTab` que trata os quatro estados sem um único `if` solto.

## ✅ Pré-requisitos

- [Aula 9 — Listas e rolagem](09-listas-e-rolagem.md) e
  [Aula 10 — Gestos e feedback](10-gestos-e-feedback.md) — a `MateriasTab` continua de lá.
- [Aula 11 — Responsividade](11-responsividade.md) — os estados precisam funcionar em qualquer
  largura.
- [Módulo 04 — Sealed classes](../04-dart-avancado/06-sealed-classes.md) — **essencial**: é o que
  faz o compilador cobrar todos os casos.
- [Módulo 04 — Patterns e switch](../04-dart-avancado/05-patterns-e-switch.md) — o `switch` que
  desenha cada estado.
- [Módulo 04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) e
  [Exceptions](../04-dart-avancado/01-exceptions.md).

---

## 📖 Conceito

### A tela que "funciona" na máquina do desenvolvedor

Todo aplicativo que busca dados passa por isto:

```dart
@override
Widget build(BuildContext context) {
  return ListView.builder(
    itemCount: _materias.length,
    itemBuilder: (context, i) => MateriaTile(materia: _materias[i]),
  );
}
```

Na sua máquina, com dados de exemplo, funciona perfeitamente. No celular do usuário:

| Momento | O que o usuário vê | O que ele conclui |
|---|---|---|
| Primeiro segundo, buscando dados | **Tela branca** | "Travou" |
| Usuário novo, sem nenhuma matéria | **Tela branca** | "Quebrou" |
| Sem internet | **Tela branca** | "Esse app é ruim" |
| Servidor fora do ar | **Tela branca** | Desinstala |

O código não tem bug. Ele só **não tem os outros três estados**.

### Os quatro estados

Toda tela que carrega dados tem exatamente estes quatro:

| Estado | Quando acontece | O que mostrar |
|---|---|---|
| **Carregando** | A busca começou e não terminou | Indicador de progresso ou esqueleto |
| **Sucesso** | Vieram dados | Os dados |
| **Vazio** | A busca deu certo, mas não há nada | Explicação + caminho de saída |
| **Erro** | A busca falhou | O que houve + **botão de tentar de novo** |

E há um quinto, meio escondido, que separa app bom de app ruim:

| Estado | Quando acontece | O que mostrar |
|---|---|---|
| **Recarregando com dados antigos** | Puxou para atualizar e já havia dados | Os dados antigos + indicador discreto |

Mostrar tela de carregamento por cima de dados que já existem é um erro clássico: a tela pisca e o
usuário perde a posição da rolagem.

### Por que `if` solto não escala

A primeira tentativa de todo mundo:

```dart
if (_carregando) {
  return const Center(child: CircularProgressIndicator());
}
if (_erro != null) {
  return Center(child: Text(_erro!));
}
if (_materias.isEmpty) {
  return const Center(child: Text('Vazio'));
}
return ListView.builder(...);
```

Funciona. E tem três problemas que só aparecem no terceiro mês do projeto:

1. **Estados impossíveis existem.** Nada impede `_carregando = true` **e** `_erro != null` ao
   mesmo tempo. Qual ganha? Depende da ordem dos `if` — ou seja, de um acidente.
2. **O compilador não ajuda.** Se você acrescentar um estado novo ("sem permissão"), nada avisa as
   12 telas que precisam tratá-lo.
3. **Cada tela reinventa os textos.** Uma diz "Nada encontrado", outra "Lista vazia", outra "Sem
   itens". O app parece feito por três pessoas que não se falam.

### A solução: `sealed class`

Um **`sealed class`** (visto no [Módulo 04](../04-dart-avancado/06-sealed-classes.md)) declara
**todos os casos possíveis** num lugar só, e o compilador passa a exigir que você trate todos.

```dart
sealed class EstadoTela<T> {
  const EstadoTela();
}

final class Carregando<T> extends EstadoTela<T> {
  const Carregando();
}

final class Sucesso<T> extends EstadoTela<T> {
  const Sucesso(this.dados);
  final T dados;
}

final class Vazio<T> extends EstadoTela<T> {
  const Vazio();
}

final class Falha<T> extends EstadoTela<T> {
  const Falha(this.mensagem);
  final String mensagem;
}
```

E, na tela:

```dart
return switch (_estado) {
  Carregando<List<Materia>>() => const CarregandoWidget(),
  Falha<List<Materia>>(mensagem: final String m) => EstadoErro(mensagem: m, onTentarDeNovo: _buscar),
  Vazio<List<Materia>>() => EstadoVazio(onAcao: _adicionar),
  Sucesso<List<Materia>>(dados: final List<Materia> lista) => _construirLista(lista),
};
```

O que você ganhou:

- **Estados impossíveis não compilam.** Não existe "carregando com erro": são classes diferentes.
- **Esquecer um caso é erro de compilação**, não bug em produção.
- **Os dados só existem onde fazem sentido.** `dados` está dentro de `Sucesso` — você não consegue
  ler uma lista que ainda não chegou.

> 📌 Este padrão é a base do `AsyncValue` do Riverpod, que você vai usar no
> [Módulo 08](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md). Aprender agora, na mão,
> faz o Riverpod parecer óbvio depois.

### Carregando: indicador, esqueleto ou nada

| Técnica | Como é | Quando usar |
|---|---|---|
| **`CircularProgressIndicator`** | Círculo girando no centro | Carga rápida (< 1 s) ou de conteúdo imprevisível |
| **Esqueleto** (*skeleton*) | Blocos cinza no formato do conteúdo | Quando você **sabe** o formato do resultado. Parece mais rápido |
| **Indicador linear no topo** | Barra fina abaixo da `AppBar` | **Recarregando** com dados já na tela |
| **Nada** | Sem indicador | Cargas abaixo de ~200 ms — o indicador pisca e incomoda mais que ajuda |

O esqueleto é superior porque comunica **o que vem**: o usuário já entende a estrutura da tela
antes de os dados chegarem. É a diferença entre "espere" e "está quase".

> 💡 **Não gire um indicador por menos de 200 ms.** Um *spinner* que aparece e some no mesmo quadro
> é percebido como falha visual. Se a carga costuma ser instantânea, não mostre nada.

### Vazio: os dois tipos

Estes dois parecem o mesmo estado e **não são**:

| Tipo | Causa | Texto certo | Ação certa |
|---|---|---|---|
| **Vazio inicial** | O usuário nunca criou nada | "Você ainda não tem matérias" | "Adicionar matéria" |
| **Vazio por filtro** | Há dados, mas o filtro escondeu todos | "Nenhuma matéria com esse filtro" | "Limpar filtro" |

Mostrar "Você ainda não tem matérias" para quem tem 40 matérias e digitou uma busca errada é o tipo
de detalhe que faz o usuário achar que o app perdeu os dados dele.

**Um bom estado vazio tem três partes:** um ícone, uma frase que **explica**, e um botão que
**resolve**. Nunca só a palavra "Vazio".

### Erro: o usuário precisa poder agir

Um bom estado de erro responde a três perguntas:

1. **O que houve?** Em linguagem de gente: "Sem conexão com a internet", não
   `SocketException: Failed host lookup`.
2. **É culpa de quem?** "Verifique sua conexão" (dele) × "Estamos com um problema" (seu).
3. **O que eu faço agora?** Um botão **Tentar de novo**.

```dart
// ❌ inútil para o usuário
Text(erro.toString())

// ✅ acionável
EstadoErro(
  titulo: 'Sem conexão',
  mensagem: 'Verifique sua internet e tente de novo.',
  onTentarDeNovo: _buscar,
)
```

> ⚠️ **Nunca mostre a exceção crua na tela.** Ela não ajuda o usuário, e pode vazar informação
> interna (caminhos de servidor, nomes de tabela). Registre a exceção no log
> ([Módulo 12](../12-testes-e-debug/02-logs-e-breakpoints.md)) e **traduza** para a tela.

---

## 💡 Analogia

Pense num restaurante e no que acontece entre pedir e comer.

- **Carregando** é o garçom dizendo "já vai sair". Sem isso, você fica olhando para a cozinha sem
  saber se o pedido foi anotado. A **tela branca** é o garçom que some.
- **O esqueleto** é a mesa sendo posta enquanto o prato vem: talher, guardanapo, pão. Você ainda
  não comeu, mas já sabe o que está por vir — e a espera encolhe.
- **Vazio** é o cardápio dizendo "hoje não temos peixe". O ruim é o garçom dizendo só "não". O bom
  é "hoje não temos peixe, mas o risoto saiu agora" — explicação **e** saída.
- **Vazio por filtro** é você ter pedido "peixe sem sal, sem óleo e sem glúten" e não haver nada.
  A cozinha não está vazia; **o seu filtro** é que está apertado. Dizer "estamos sem comida" seria
  mentira.
- **Erro** é a cozinha pegar fogo. O usuário não quer o laudo dos bombeiros
  (`SocketException: Failed host lookup`). Ele quer saber: dá para pedir de novo? em quanto tempo?
  tem outra coisa?
- **Recarregar com dados antigos** é o garçom trocar a jarra de água sem tirar o seu prato da
  frente. Limpar a mesa inteira para trazer água — que é o que a tela de carregamento por cima
  faz — é irritante.

---

## 🧪 Exemplo mínimo

Este programa alterna entre os quatro estados com um botão, para você ver cada um.

> **Arquivo:** `foco_ui/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppEstados());

/// Os quatro estados possíveis de uma tela que busca dados.
sealed class Estado {
  const Estado();
}

final class Carregando extends Estado {
  const Carregando();
}

final class Sucesso extends Estado {
  const Sucesso(this.itens);
  final List<String> itens;
}

final class Vazio extends Estado {
  const Vazio();
}

final class Falha extends Estado {
  const Falha(this.mensagem);
  final String mensagem;
}

class AppEstados extends StatelessWidget {
  const AppEstados({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: const TelaEstados(),
    );
  }
}

class TelaEstados extends StatefulWidget {
  const TelaEstados({super.key});

  @override
  State<TelaEstados> createState() => _TelaEstadosState();
}

class _TelaEstadosState extends State<TelaEstados> {
  Estado _estado = const Carregando();

  static const List<Estado> _ciclo = <Estado>[
    Carregando(),
    Sucesso(<String>['Dart', 'Flutter', 'Git']),
    Vazio(),
    Falha('Sem conexão com a internet'),
  ];

  int _indice = 0;

  void _proximo() {
    setState(() {
      _indice = (_indice + 1) % _ciclo.length;
      _estado = _ciclo[_indice];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estado: ${_estado.runtimeType}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _proximo,
        icon: const Icon(Icons.skip_next),
        label: const Text('Próximo estado'),
      ),

      // O switch é EXAUSTIVO: apague um caso e o código não compila.
      body: switch (_estado) {
        Carregando() => const Center(child: CircularProgressIndicator()),

        Sucesso(itens: final List<String> lista) => ListView(
            children: <Widget>[
              for (final String item in lista) ListTile(title: Text(item)),
            ],
          ),

        Vazio() => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.inbox_outlined, size: 64),
                SizedBox(height: 16),
                Text('Você ainda não tem matérias'),
              ],
            ),
          ),

        Falha(mensagem: final String m) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.cloud_off_outlined, size: 64),
                const SizedBox(height: 16),
                Text(m),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _proximo,
                  child: const Text('Tentar de novo'),
                ),
              ],
            ),
          ),
      },
    );
  }
}
```

**Faça o teste que ensina:** apague o caso `Vazio()` do `switch` e salve. O analisador diz:

```text
The type 'Estado' is not exhaustively matched by the switch cases
since it doesn't match 'Vazio()'.
```

**Isso é um erro de compilação, não um bug em produção.** É esse o ganho do `sealed class`.

---

## 📱 Aplicando no Flutter

Agora o `foco_ui` ganha os três widgets de estado reutilizáveis — que já estavam previstos na
estrutura do módulo desde a aula 1 — e a `MateriasTab` passa a usá-los.

```text
lib/core/widgets/
├── carregando.dart      ← indicador e esqueleto
├── estado_vazio.dart    ← vazio inicial e vazio por filtro
└── estado_erro.dart     ← erro com ação de repetir
```

Depois disso, **qualquer** tela nova do curso tem os quatro estados de graça.

---

## 💻 Código completo

> **Arquivo:** `foco_ui/lib/core/widgets/carregando.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Indicador simples, centralizado. Para cargas curtas e imprevisíveis.
class Carregando extends StatelessWidget {
  const Carregando({super.key, this.mensagem});

  final String? mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // .adaptive: arco no Android, "pás" no iOS. Uma palavra, zero custo.
          const CircularProgressIndicator.adaptive(),
          if (mensagem != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(mensagem!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Esqueleto de lista: blocos no formato do conteúdo que está vindo.
///
/// Comunica melhor que um spinner porque mostra a ESTRUTURA do resultado.
class EsqueletoLista extends StatefulWidget {
  const EsqueletoLista({super.key, this.linhas = 6});

  final int linhas;

  @override
  State<EsqueletoLista> createState() => _EsqueletoListaState();
}

class _EsqueletoListaState extends State<EsqueletoLista>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;

  @override
  void initState() {
    super.initState();
    // Pulsar devagar sugere "carregando" sem competir com o conteúdo.
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Toda animação criada precisa ser liberada. Módulo 05, aula 6.
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color cor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListView.builder(
      // Ignora toques: não há nada para tocar ainda.
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.linhas,
      itemBuilder: (BuildContext context, int i) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.4, end: 1).animate(_controlador),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                _Bloco(cor: cor, largura: 44, altura: 44, circulo: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Larguras variadas imitam nomes de tamanhos diferentes.
                      _Bloco(cor: cor, largura: i.isEven ? 140 : 180, altura: 14),
                      const SizedBox(height: 8),
                      _Bloco(cor: cor, largura: double.infinity, altura: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Bloco extends StatelessWidget {
  const _Bloco({
    required this.cor,
    required this.largura,
    required this.altura,
    this.circulo = false,
  });

  final Color cor;
  final double largura;
  final double altura;
  final bool circulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: cor,
        shape: circulo ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circulo ? null : BorderRadius.circular(4),
      ),
    );
  }
}

/// Barra fina para recarga COM dados já na tela.
///
/// Substituir a lista por um spinner faria o usuário perder a rolagem.
class RecarregandoBarra extends StatelessWidget {
  const RecarregandoBarra({super.key, required this.visivel});

  final bool visivel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: visivel ? const LinearProgressIndicator(minHeight: 4) : null,
    );
  }
}
```

> **Arquivo:** `foco_ui/lib/core/widgets/estado_vazio.dart` (novo)

```dart
import 'package:flutter/material.dart';

/// Tela de "não há nada aqui", com explicação e caminho de saída.
///
/// Três partes obrigatórias: ícone, frase que explica, botão que resolve.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.titulo,
    required this.mensagem,
    this.icone = Icons.inbox_outlined,
    this.rotuloAcao,
    this.onAcao,
  });

  /// Vazio porque o usuário ainda não criou nada.
  const EstadoVazio.inicial({
    super.key,
    required String oQue,
    required VoidCallback aoCriar,
    String? rotuloCriar,
  })  : titulo = 'Nenhuma $oQue por aqui',
        mensagem = 'Crie a sua primeira $oQue para começar.',
        icone = Icons.add_circle_outline,
        rotuloAcao = rotuloCriar ?? 'Adicionar',
        onAcao = aoCriar;

  /// Vazio porque o FILTRO escondeu tudo. Texto e ação são diferentes.
  const EstadoVazio.semResultado({
    super.key,
    required VoidCallback aoLimpar,
  })  : titulo = 'Nenhum resultado',
        mensagem = 'Nenhum item corresponde ao filtro atual.',
        icone = Icons.search_off_outlined,
        rotuloAcao = 'Limpar filtros',
        onAcao = aoLimpar;

  final String titulo;
  final String mensagem;
  final IconData icone;
  final String? rotuloAcao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme tipografia = Theme.of(context).textTheme;

    // ListView (e não Column) para que o RefreshIndicator continue funcionando
    // e para não estourar em telas baixas ou com fonte aumentada.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: <Widget>[
        Icon(icone, size: 64, color: cores.outline),
        const SizedBox(height: 24),
        Text(titulo, textAlign: TextAlign.center, style: tipografia.titleLarge),
        const SizedBox(height: 8),
        Text(
          mensagem,
          textAlign: TextAlign.center,
          style: tipografia.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
        if (onAcao != null) ...<Widget>[
          const SizedBox(height: 24),
          Center(
            child: FilledButton.tonal(
              onPressed: onAcao,
              child: Text(rotuloAcao ?? 'Continuar'),
            ),
          ),
        ],
      ],
    );
  }
}
```

> **Arquivo:** `foco_ui/lib/core/widgets/estado_erro.dart` (novo)

```dart
import 'package:flutter/material.dart';

/// Tela de erro que o usuário CONSEGUE resolver.
///
/// Responde a três perguntas: o que houve, de quem é o problema,
/// e o que fazer agora.
class EstadoErro extends StatelessWidget {
  const EstadoErro({
    super.key,
    required this.titulo,
    required this.mensagem,
    required this.onTentarDeNovo,
    this.icone = Icons.error_outline,
    this.detalheTecnico,
  });

  /// Construtor para o erro mais comum de todos.
  const EstadoErro.semConexao({super.key, required this.onTentarDeNovo})
      : titulo = 'Sem conexão',
        mensagem = 'Verifique sua internet e tente de novo.',
        icone = Icons.cloud_off_outlined,
        detalheTecnico = null;

  final String titulo;
  final String mensagem;
  final VoidCallback onTentarDeNovo;
  final IconData icone;

  /// Só aparece em modo debug. NUNCA mostre exceção crua ao usuário final.
  final String? detalheTecnico;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme tipografia = Theme.of(context).textTheme;

    // Constante do Flutter: true em debug, false em release.
    const bool ehDebug = !bool.fromEnvironment('dart.vm.product');

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: <Widget>[
        Icon(icone, size: 64, color: cores.error),
        const SizedBox(height: 24),
        Text(titulo, textAlign: TextAlign.center, style: tipografia.titleLarge),
        const SizedBox(height: 8),
        Text(
          mensagem,
          textAlign: TextAlign.center,
          style: tipografia.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: onTentarDeNovo,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar de novo'),
          ),
        ),

        // Detalhe técnico só para você, durante o desenvolvimento.
        if (ehDebug && detalheTecnico != null) ...<Widget>[
          const SizedBox(height: 32),
          ExpansionTile(
            title: const Text('Detalhe técnico (só em debug)'),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  detalheTecnico!,
                  style: tipografia.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
```

Agora o modelo de estado e a tela final:

> **Arquivo:** `foco_ui/lib/core/estado/estado_tela.dart` (novo)

```dart
/// Os estados possíveis de uma tela que carrega dados.
///
/// Sendo sealed, o compilador EXIGE que todo switch trate os quatro casos.
/// Acrescentar um quinto estado quebra a compilação de quem não o tratou —
/// que é exatamente o comportamento desejado.
sealed class EstadoTela<T> {
  const EstadoTela();
}

/// Buscando pela primeira vez. Não há dados para mostrar.
final class TelaCarregando<T> extends EstadoTela<T> {
  const TelaCarregando();
}

/// Deu certo e veio conteúdo.
final class TelaSucesso<T> extends EstadoTela<T> {
  const TelaSucesso(this.dados, {this.recarregando = false});

  final T dados;

  /// Recarga em andamento COM dados na tela: barra fina, não spinner.
  final bool recarregando;
}

/// Deu certo, mas não há nada. O motivo muda o texto mostrado.
final class TelaVazia<T> extends EstadoTela<T> {
  const TelaVazia({this.porFiltro = false});

  final bool porFiltro;
}

/// Falhou. A mensagem já vem traduzida para o usuário.
final class TelaFalha<T> extends EstadoTela<T> {
  const TelaFalha(this.mensagem, {this.detalheTecnico, this.semConexao = false});

  final String mensagem;
  final String? detalheTecnico;
  final bool semConexao;
}
```

> **Arquivo:** `foco_ui/lib/features/materias/presentation/materias_tab.dart`
> (versão final do módulo)

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:foco_ui/core/estado/estado_tela.dart';
import 'package:foco_ui/core/widgets/carregando.dart';
import 'package:foco_ui/core/widgets/estado_erro.dart';
import 'package:foco_ui/core/widgets/estado_vazio.dart';
import 'package:foco_ui/features/materias/domain/materia.dart';
import 'package:foco_ui/features/materias/presentation/widgets/materia_tile.dart';

class MateriasTab extends StatefulWidget {
  const MateriasTab({super.key});

  @override
  State<MateriasTab> createState() => _MateriasTabState();
}

class _MateriasTabState extends State<MateriasTab> {
  /// Um campo só guarda TODO o estado da tela.
  /// Não existe mais `bool _carregando` + `String? _erro` + `List _dados`
  /// podendo se contradizer.
  EstadoTela<List<Materia>> _estado = const TelaCarregando<List<Materia>>();

  String _filtro = '';

  /// Fonte de dados simulada. No Módulo 09 vira uma chamada HTTP;
  /// no Módulo 10, uma consulta ao banco.
  static const List<Materia> _todasAsMaterias = <Materia>[
    Materia(id: 'dart', nome: 'Dart', minutosEstudados: 95, metaMinutos: 120, icone: Icons.code),
    Materia(id: 'flutter', nome: 'Flutter', minutosEstudados: 40, metaMinutos: 120, icone: Icons.phone_android),
    Materia(id: 'git', nome: 'Git e terminal', minutosEstudados: 95, metaMinutos: 90, icone: Icons.terminal),
    Materia(id: 'sql', nome: 'Banco de dados', minutosEstudados: 30, metaMinutos: 180, icone: Icons.storage),
  ];

  @override
  void initState() {
    super.initState();
    // A primeira busca começa junto com a tela.
    _buscar();
  }

  // ── Busca ─────────────────────────────────────────────────────────────────

  Future<void> _buscar({bool recarga = false}) async {
    // Recarga mantém os dados antigos na tela; carga inicial não tem o que manter.
    if (recarga && _estado is TelaSucesso<List<Materia>>) {
      final TelaSucesso<List<Materia>> atual =
          _estado as TelaSucesso<List<Materia>>;
      setState(() {
        _estado = TelaSucesso<List<Materia>>(atual.dados, recarregando: true);
      });
    } else {
      setState(() => _estado = const TelaCarregando<List<Materia>>());
    }

    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));

      // Simula falha em 1 de cada 4 buscas, para você ver o estado de erro.
      if (math.Random().nextInt(4) == 0) {
        throw Exception('Falha ao contatar o servidor de estudos');
      }

      final List<Materia> resultado = _todasAsMaterias
          .where((Materia m) =>
              m.nome.toLowerCase().contains(_filtro.toLowerCase()))
          .toList();

      if (!mounted) return;

      setState(() {
        _estado = resultado.isEmpty
            // O motivo do vazio muda o texto: filtro ou falta de dados.
            ? TelaVazia<List<Materia>>(porFiltro: _filtro.isNotEmpty)
            : TelaSucesso<List<Materia>>(resultado);
      });
    } on Exception catch (erro, pilha) {
      // O log técnico fica aqui; a tela recebe texto de gente.
      debugPrint('Erro ao buscar matérias: $erro\n$pilha');

      if (!mounted) return;

      setState(() {
        _estado = TelaFalha<List<Materia>>(
          'Não conseguimos carregar suas matérias agora.',
          detalheTecnico: '$erro',
        );
      });
    }
  }

  void _filtrar(String texto) {
    setState(() => _filtro = texto);
    _buscar();
  }

  void _limparFiltro() {
    setState(() => _filtro = '');
    _buscar();
  }

  void _adicionar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulário de matéria — Módulo 07')),
    );
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Extraído para uma variável para o switch caber em uma tela.
    final bool recarregando = _estado is TelaSucesso<List<Materia>> &&
        (_estado as TelaSucesso<List<Materia>>).recarregando;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matérias'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: RecarregandoBarra(visivel: recarregando),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionar,
        tooltip: 'Adicionar matéria',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar matéria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _filtro.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Limpar busca',
                        onPressed: _limparFiltro,
                      ),
              ),
              onSubmitted: _filtrar,
            ),
          ),

          // Expanded dá altura FINITA para o que vier abaixo. Aula 9.
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _buscar(recarga: true),

              // ── O coração da aula ─────────────────────────────────────
              // Um switch exaustivo. Nenhum `if` solto, nenhum estado
              // impossível, nenhum caso esquecido — o compilador garante.
              child: switch (_estado) {
                TelaCarregando<List<Materia>>() =>
                  const EsqueletoLista(linhas: 5),

                TelaFalha<List<Materia>>(
                  mensagem: final String msg,
                  detalheTecnico: final String? detalhe,
                  semConexao: final bool offline,
                ) =>
                  offline
                      ? EstadoErro.semConexao(onTentarDeNovo: _buscar)
                      : EstadoErro(
                          titulo: 'Algo deu errado',
                          mensagem: msg,
                          detalheTecnico: detalhe,
                          onTentarDeNovo: _buscar,
                        ),

                TelaVazia<List<Materia>>(porFiltro: true) =>
                  EstadoVazio.semResultado(aoLimpar: _limparFiltro),

                TelaVazia<List<Materia>>() => EstadoVazio.inicial(
                    oQue: 'matéria',
                    aoCriar: _adicionar,
                    rotuloCriar: 'Adicionar matéria',
                  ),

                TelaSucesso<List<Materia>>(dados: final List<Materia> lista) =>
                  ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (BuildContext c, int i) =>
                        const Divider(height: 1, indent: 72, endIndent: 16),
                    itemBuilder: (BuildContext c, int i) =>
                        MateriaTile(materia: lista[i], onTap: () {}),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

Rode e veja os quatro estados de verdade:

```powershell
flutter analyze
flutter run -d chrome
```

1. **Ao abrir:** o esqueleto pulsa por ~0,9 s.
2. **Uma em cada quatro vezes:** a tela de erro aparece, com botão **Tentar de novo** que funciona.
3. **Busque "zzz"** e aperte Enter: aparece "Nenhum resultado" com **Limpar filtros** — e **não**
   "você ainda não tem matérias".
4. **Puxe para atualizar** com dados na tela: a barra fina aparece no topo e a lista **não pisca**.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `sealed class EstadoTela<T>` | Declara **todos** os casos possíveis. O compilador passa a exigir `switch` exaustivo. Módulo 04. |
| `final class TelaSucesso<T>` com `T dados` | Os dados **só existem** dentro do caso de sucesso. É impossível ler uma lista que ainda não chegou. |
| `EstadoTela<List<Materia>> _estado` — um campo só | Substitui `bool _carregando` + `String? _erro` + `List _dados`. Estados contraditórios deixam de existir. |
| `TelaSucesso(atual.dados, recarregando: true)` | Recarga **preserva** os dados. Trocar por `TelaCarregando` faria a lista sumir e a rolagem se perder. |
| `TelaVazia(porFiltro: _filtro.isNotEmpty)` | O **motivo** do vazio vira parte do estado — e dois textos diferentes saem daí. |
| `on Exception catch (erro, pilha)` | Captura o erro **e** a pilha. Módulo 04, aula 1. |
| `debugPrint` do erro + mensagem traduzida na tela | Detalhe técnico vai para o log; usuário recebe texto de gente. |
| `const bool ehDebug = !bool.fromEnvironment('dart.vm.product');` | Constante avaliada em **tempo de compilação**: o bloco de detalhe técnico é removido do binário de release. |
| `switch (_estado) { TelaCarregando<List<Materia>>() => … }` | *Switch expression* exaustivo. Apagar um caso é **erro de compilação**. |
| `TelaVazia<List<Materia>>(porFiltro: true) => …` **antes** de `TelaVazia<List<Materia>>() => …` | Ordem importa: o padrão mais específico vem primeiro; o genérico funciona como "todos os outros". |
| `TelaFalha(mensagem: final String msg, …)` | *Destructuring* do Dart 3: extrai os campos direto no padrão, com tipo. Módulo 04, aula 5. |
| `EstadoVazio.inicial` / `.semResultado` | Construtores nomeados que **padronizam os textos** do app inteiro. Nenhuma tela reinventa a frase. |
| `EsqueletoLista` com `AnimationController` | Pulsa entre 0,4 e 1 de opacidade. `dispose()` obrigatório — Módulo 05, aula 6. |
| `physics: const NeverScrollableScrollPhysics()` no esqueleto | Não há o que rolar enquanto carrega; rolar um esqueleto confunde. |
| `physics: const AlwaysScrollableScrollPhysics()` nos estados vazio e erro | Garante que o `RefreshIndicator` funcione **mesmo** nessas telas — é justamente onde o usuário mais quer tentar de novo. |
| `PreferredSize` com `RecarregandoBarra` | Coloca a barra de 4 px logo abaixo da `AppBar`, sem empurrar o conteúdo. |
| `ListView` (e não `Column`) nos estados vazio e erro | Não estoura em tela baixa nem com fonte aumentada, e permite puxar para atualizar. Aula 11. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Indicador de carregamento | `CircularProgressIndicator` — arco girando | `CupertinoActivityIndicator` — "pás" cinza |
| `.adaptive()` | Usa o Material | Usa o Cupertino automaticamente |
| Expectativa de erro | Mensagem na tela, ou `SnackBar` | Mensagem na tela, ou alerta modal |
| Sem conexão | O sistema costuma avisar por conta própria | O sistema é mais silencioso; **seu app precisa avisar** |
| Puxar para atualizar | `RefreshIndicator` | `CupertinoSliverRefreshControl` |

> 📌 A diferença que mais importa: no iOS, o usuário **não recebe aviso do sistema** quando o app
> falha por falta de rede. Se a sua tela ficar branca, ele conclui que o app quebrou. O estado de
> erro não é enfeite — nessa plataforma, é a única informação que ele vai ter.

---

## ⚠️ Erros comuns

### 1. Só tratar sucesso

```dart
return ListView.builder(itemCount: _dados.length, ...); // ❌ e os outros três?
```

Tela branca no primeiro segundo, tela branca sem dados, tela branca sem internet.

**Correção:** os quatro estados, sempre.

### 2. Booleanos que se contradizem

```dart
bool _carregando = false;
String? _erro;
List<Materia> _dados = <Materia>[];
```

São **2 × 2 × 2 = 8 combinações**, das quais só 4 fazem sentido. As outras 4 são bugs esperando
acontecer.

**Correção:** um `sealed class` com um campo só.

### 3. Mostrar a exceção crua

```dart
Text(erro.toString()) // ❌
```

```text
SocketException: Failed host lookup: 'api.exemplo.com' (OS Error: No address associated with hostname, errno = 7)
```

O usuário não sabe o que fazer com isso — e pode ver o endereço do seu servidor.

**Correção:** traduza. `debugPrint` para o log, texto de gente para a tela.

### 4. Substituir a lista por um spinner ao recarregar

```dart
Future<void> _recarregar() async {
  setState(() => _estado = const TelaCarregando()); // ❌ a lista some
  ...
}
```

A tela pisca e o usuário perde a posição da rolagem.

**Correção:** `TelaSucesso(dadosAntigos, recarregando: true)` + barra fina no topo.

### 5. Um texto de vazio para os dois casos

```dart
const Text('Nenhuma matéria') // ❌ para quem tem 40 e filtrou errado
```

**Correção:** `porFiltro` no estado, dois textos e duas ações diferentes.

### 6. Estado vazio sem saída

```dart
const Center(child: Text('Vazio')) // ❌ e agora?
```

**Correção:** ícone + frase que explica + botão que resolve.

### 7. Erro sem "tentar de novo"

```dart
Center(child: Text('Erro ao carregar')) // ❌ o usuário só pode fechar o app
```

**Correção:** `FilledButton.icon(icon: Icon(Icons.refresh), label: Text('Tentar de novo'))`.

### 8. `Column` nos estados vazio e erro

```dart
Center(child: Column(children: <Widget>[...])) // ⚠️
```

Com fonte em 200%, ou em celular deitado, estoura. E o `RefreshIndicator` não funciona.

**Correção:** `ListView` com `AlwaysScrollableScrollPhysics`.

### 9. Spinner que pisca

Carga de 80 ms com `CircularProgressIndicator` aparece e some no mesmo instante — parece defeito.

**Correção:** não mostre indicador em cargas abaixo de ~200 ms. Se o tempo for imprevisível,
mostre o indicador só depois de um atraso mínimo.

### 10. Não checar `mounted` depois do `await`

```dart
await Future<void>.delayed(...);
setState(() => _estado = ...); // ❌ a tela pode ter saído
```

**Correção:** `if (!mounted) return;`. Módulo 05, aula 7.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode a `MateriasTab` e recarregue várias vezes até cair no estado de erro. Confirme
que **Tentar de novo** funciona.

**Passo 2.** No `switch` do `build`, **apague** o caso `TelaVazia<List<Materia>>()` (o genérico).
Salve e leia a mensagem do analisador. Copie-a para o seu caderno. Depois restaure.

**Passo 3.** Troque a ordem: ponha `TelaVazia<List<Materia>>()` **antes** de
`TelaVazia<List<Materia>>(porFiltro: true)`. Busque "zzz". Qual texto aparece? Explique por quê e
depois desfaça.

**Passo 4.** Troque `EsqueletoLista` por `Carregando(mensagem: 'Buscando matérias…')`. Rode as duas
versões cinco vezes cada. Qual **parece** mais rápida? Elas demoram o mesmo tempo.

**Passo 5.** No `_buscar`, troque o bloco de recarga para sempre usar
`const TelaCarregando<List<Materia>>()`. Role a lista até o fim e puxe para atualizar. Descreva o
que acontece com a rolagem. Depois desfaça.

**Passo 6.** Force o erro sempre (troque `math.Random().nextInt(4) == 0` por `true`). Confirme que
o bloco "Detalhe técnico" aparece. Depois rode com `flutter run --release` e confirme que ele
**sumiu**. Explique por escrito por quê.

**Passo 7.** Acrescente um **quinto** estado, `TelaSemPermissao<T>`, ao `sealed class` — e **não**
o trate no `switch`. Rode `flutter analyze`. Quantos erros aparecem? Esse é o valor do `sealed`.
Depois trate o caso ou remova o estado.

**Passo 8.** Responda por escrito: por que `EstadoVazio` e `EstadoErro` moram em `lib/core/widgets/`
e não dentro de `features/materias/`?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Faça os exercícios de **Aplicação** com `sealed class` de estado, o de **Correção de bugs** com os
booleanos contraditórios, e o de **Decisão** sobre esqueleto × spinner.

---

## 🏆 Desafio opcional

Crie um widget genérico `ConstrutorDeEstado<T>` que receba um `EstadoTela<T>` e três funções
(`aoSucesso`, `aoVazio`, `aoErro`) e faça o `switch` **uma vez só**, para o app inteiro.

```dart
ConstrutorDeEstado<List<Materia>>(
  estado: _estado,
  aoSucesso: (List<Materia> lista) => _construirLista(lista),
  aoTentarDeNovo: _buscar,
  aoCriar: _adicionar,
)
```

Requisitos:

- Nenhuma tela do app volta a escrever o `switch` dos quatro estados.
- Ainda é possível personalizar os textos de vazio e erro por tela.
- O esqueleto de carregamento é configurável (lista, grade ou indicador simples).

Depois responda: quantas linhas a `MateriasTab` perdeu? E o que aconteceria se você acrescentasse
um quinto estado agora — quantos arquivos precisariam mudar?

> 💡 Se você fizer este desafio, guarde o widget: ele é praticamente o `AsyncValue.when` do
> Riverpod, que chega no [Módulo 08](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).
> Tendo escrito o seu, o de lá vai parecer familiar em vez de mágico.

---

## 📌 Resumo

- Toda tela que carrega dados tem **quatro estados**: carregando, sucesso, vazio e erro — mais o
  quinto, "recarregando com dados antigos".
- Tratar só o sucesso é a causa número 1 de tela branca.
- **`bool _carregando` + `String? _erro` + `List _dados`** permite combinações impossíveis. Um
  **`sealed class`** com um campo só as elimina.
- Com `sealed`, esquecer um caso vira **erro de compilação**, não bug em produção.
- **Esqueleto** comunica melhor que *spinner*: mostra a estrutura do que vem.
- Não mostre indicador para cargas abaixo de ~200 ms — o piscar parece defeito.
- Recarga **preserva os dados na tela**; use uma barra fina, nunca substitua a lista.
- **Vazio inicial** e **vazio por filtro** são estados diferentes, com textos e ações diferentes.
- Um bom estado vazio tem **ícone + explicação + botão que resolve**.
- Um bom estado de erro responde: o que houve, de quem é, e **o que fazer** — com botão de repetir.
- **Nunca** mostre a exceção crua: log para você, texto de gente para o usuário.
- Estados vazio e erro usam **`ListView`** com `AlwaysScrollableScrollPhysics`, para não estourar
  e para permitir puxar-para-atualizar.
- Widgets de estado moram em `lib/core/widgets/` — eles servem ao app inteiro, não a uma feature.

---

## ☑️ Checklist de domínio

- [ ] Nomeio os quatro estados sem consultar, e digo por que o quinto existe.
- [ ] Modelo estado de tela com `sealed class` em vez de booleanos soltos.
- [ ] Escrevo `switch` exaustivo e entendo o erro do analisador quando falta um caso.
- [ ] Coloco o padrão mais específico **antes** do genérico.
- [ ] Escolho entre esqueleto e *spinner* e justifico.
- [ ] Nunca substituo dados existentes por tela de carregamento ao recarregar.
- [ ] Diferencio vazio inicial de vazio por filtro, com textos diferentes.
- [ ] Todo estado vazio tem ícone, explicação e ação.
- [ ] Todo estado de erro tem "Tentar de novo".
- [ ] Nunca mostro `erro.toString()` na tela; registro no log e traduzo.
- [ ] Meus estados vazio e erro funcionam com `RefreshIndicator` e com fonte em 200%.
- [ ] Meus widgets de estado são reutilizáveis e ficam em `core/widgets/`.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Sealed classes — dart.dev](https://dart.dev/language/class-modifiers#sealed)
- [Patterns — dart.dev](https://dart.dev/language/patterns)
- [Branches: switch — dart.dev](https://dart.dev/language/branches#switch-expressions)
- [CircularProgressIndicator — api.flutter.dev](https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html)
- [LinearProgressIndicator — api.flutter.dev](https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html)
- [Material 3 — Loading indicators](https://m3.material.io/components/progress-indicators/overview)
- [Empty states — material.io](https://m2.material.io/design/communication/empty-states.html)

---

## 🎓 Fim do Módulo 06

Você começou este módulo desenhando um `Scaffold` vazio e termina com uma tela que:

- tem **esqueleto de layout** e árvore de widgets bem composta (aulas 1 a 6);
- respeita **tema, modo escuro e assets** (aulas 7 e 8);
- **rola, exclui, desfaz e atualiza** (aula 9);
- dá **feedback em cada toque** (aula 10);
- funciona de **360 px a 1600 px** (aula 11);
- e trata **os quatro estados** que o mundo real impõe (aula 12).

Antes de seguir:

1. Faça os exercícios em
   [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md).
2. Faça a avaliação em
   [avaliacoes/modulo-06-widgets-e-layouts.md](../../avaliacoes/modulo-06-widgets-e-layouts.md).
3. Confirme que `flutter analyze` no `foco_ui` termina com `No issues found!`.

No [Módulo 07](../07-navegacao-e-formularios/README.md) essas telas param de ser uma só: você vai
empilhar, passar dados entre elas e construir formulários que validam de verdade.

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo |
|---|---|---|
| [Aula 11 — Responsividade](11-responsividade.md) | [README](README.md) | [Módulo 07 — Navegação e Formulários](../07-navegacao-e-formularios/README.md) |
