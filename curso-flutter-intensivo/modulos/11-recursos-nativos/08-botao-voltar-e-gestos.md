# Aula 8 — Botão voltar e gestos

> **Módulo:** 11 - Recursos Nativos · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Tratar o botão voltar do Android e o gesto de borda do iOS como **o mesmo problema de produto**.
- Reconhecer o **antipadrão de bloquear o voltar** — e os poucos casos em que interceptar é
  legítimo.
- Aplicar `PopScope` com `canPop` sempre atualizado, em cenários reais.
- Coordenar **múltiplos `PopScope`** aninhados sem que eles briguem.
- Decidir o que fazer quando há **trabalho em andamento** e o usuário quer sair.
- Entender as **consequências de design** de cada escolha para o usuário.

## ✅ Pré-requisitos

- [Módulo 07, aula 5 — Navegação Android × iOS](../07-navegacao-e-formularios/05-navegacao-android-x-ios.md)
  — **essencial**: a mecânica do `PopScope`, `canPop`, `onPopInvokedWithResult` e o
  *predictive back* foi explicada lá. **Esta aula não repete** — ela trata das **decisões**.
- [Aula 6 — Ciclo de vida do app](06-ciclo-de-vida-do-app.md) — salvar antes de sair.
- [Módulo 07, aula 8 — UX de formulários](../07-navegacao-e-formularios/08-ux-de-formularios.md) —
  o rascunho, que muda a resposta desta aula.

---

## 📖 Conceito

### O mesmo problema, dois gestos

O Módulo 07 mostrou **como** interceptar. Esta aula responde **quando** — e a resposta começa por
entender que Android e iOS resolvem a mesma necessidade de formas diferentes:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Como se volta | Botão/gesto **global** do sistema | Arrastar da **borda esquerda**, ou a seta |
| Onde funciona | Qualquer tela | Só se houver tela anterior |
| Na tela raiz | Sai do app | Não faz nada |
| Frequência de uso acidental | Média | **Alta** — a borda é fácil de tocar sem querer |
| O usuário espera | "Voltar um passo" | "Voltar um passo" |

A última linha é o que importa: **a expectativa é a mesma**. O usuário quer desfazer o último
passo de navegação. Qualquer coisa diferente disso é uma surpresa — e surpresa, em navegação, é
defeito.

### O antipadrão: bloquear o voltar

```dart
// ❌ o pior código de navegação que existe
PopScope(
  canPop: false,
  onPopInvokedWithResult: (bool saiu, Object? r) {},
  child: minhaTela,
)
```

O usuário fica **preso**. No iOS, sem botão voltar na barra, ele precisa fechar o app.

Os pretextos comuns e por que nenhum se sustenta:

| "Preciso bloquear porque…" | A resposta |
|---|---|
| "…o usuário não pode sair sem salvar" | Salve **automaticamente**, ou pergunte — não prenda |
| "…há um upload em andamento" | Continue em segundo plano, ou avise e deixe sair |
| "…a tela é obrigatória (onboarding)" | Permita pular; um onboarding que prende é desinstalado |
| "…é um fluxo de pagamento" | Cancelar precisa ser **possível**; o que não pode é ficar ambíguo |
| "…estou em tela cheia de vídeo" | Voltar **sai da tela cheia** — não sai do app |

> ⚠️ **A regra:** interceptar o voltar é aceitável; **impedir** o voltar não é. A diferença é que
> interceptar **sempre** leva a um caminho de saída — no máximo, com uma pergunta no meio.

### Os quatro casos legítimos

Depois de descartar os pretextos, sobram quatro situações em que interceptar é a decisão certa:

**1. Perda de dados.** O usuário preencheu um formulário e vai perder.

```dart
canPop: !temAlteracoes,   // pergunta só quando há o que perder
```

**2. Desfazer uma camada de interface.** Voltar fecha o que está aberto, antes de mudar de tela.

```text
Busca aberta → voltar FECHA A BUSCA
Seleção múltipla ativa → voltar CANCELA A SELEÇÃO
Tela cheia → voltar SAI DA TELA CHEIA
```

Esse é o caso mais comum e o menos implementado. O usuário abre a busca, aperta voltar, e o app
**muda de tela** em vez de fechar a busca — obrigando-o a navegar de volta.

**3. Voltar para a primeira aba.** Em app com abas, voltar na aba 3 vai para a aba 1 antes de sair
(visto no [Módulo 07, aula 4](../07-navegacao-e-formularios/04-abas-e-organizacao.md)).

**4. Confirmar a saída do app.** "Aperte voltar de novo para sair" — **só no Android**, e só na
tela raiz.

### A ordem importa: `PopScope` aninhados

Numa tela com busca aberta **e** formulário sujo, há dois `PopScope`. Qual age primeiro?

> **O mais interno vence.** O Flutter consulta os `PopScope` de dentro para fora, e o primeiro com
> `canPop: false` intercepta.

Isso costuma ser o que você quer — mas exige que cada camada **libere** a seguinte:

```text
Estado: busca aberta + formulário sujo

1º voltar → fecha a busca (PopScope interno)
2º voltar → pergunta sobre o formulário (PopScope externo)
3º voltar → sai
```

Se o `PopScope` interno não desligar o próprio `canPop` depois de fechar a busca, o usuário fica
preso na primeira camada.

> 📌 **O teste que revela o problema:** abra tudo que pode ser aberto na tela e aperte voltar
> repetidamente. Cada toque deve desfazer **uma** camada, na ordem inversa da abertura, e o último
> deve sair. Se algum toque não fizer nada, há um `canPop` que não foi atualizado.

### Trabalho em andamento

O usuário aperta voltar enquanto algo está sendo enviado. Três estratégias:

| Estratégia | Quando | O que o usuário sente |
|---|---|---|
| **Bloquear até terminar** | Operação curta (< 2 s) e crítica | Aceitável se houver indicador |
| **Deixar sair, continuar em segundo plano** | Upload, sincronização | Melhor — o app respeita o tempo dele |
| **Deixar sair, cancelar** | Busca, pré-visualização | Certo: o resultado já não interessa |

A segunda é quase sempre a resposta, e exige que a operação **não dependa da tela**:

```dart
// ❌ a operação morre com a tela
Future<void> _enviar() async {
  setState(() => _enviando = true);
  await _api.enviar(dados);
  if (!mounted) return;   // se a tela sumiu, o resultado se perde
  setState(() => _enviando = false);
}
```

```dart
// ✅ a operação vive no controller; a tela só observa
Future<void> _enviar() => ref.read(envioProvider.notifier).enviar(dados);
```

Com o estado no provider ([Módulo 08](../08-estado-e-arquitetura/README.md)), o usuário pode sair,
navegar, e receber o resultado por um `SnackBar` — em vez de ficar preso olhando um indicador.

### As consequências de design

Cada escolha tem um custo que só aparece com o uso:

| Escolha | Custo escondido |
|---|---|
| Confirmar saída em **toda** tela | O usuário para de ler o diálogo e aperta "sim" no automático |
| Salvar automático sem avisar | Ele não sabe se salvou; volta para conferir |
| Bloquear durante envio | Em rede ruim, ele fica preso 30 segundos |
| Rascunho silencioso | Ele perde a confiança quando o rascunho **não** aparece uma vez |
| Nada (deixar perder) | Ele perde trabalho e não volta |

> 💡 **A melhor solução costuma ser a que não pergunta nada:** salvar rascunho automaticamente
> ([Módulo 07, aula 8](../07-navegacao-e-formularios/08-ux-de-formularios.md)) e deixar o usuário
> sair livremente. O diálogo de descarte é o **segundo** melhor caminho — necessário quando o
> rascunho não faz sentido (um formulário de pagamento, por exemplo).

---

## 💡 Analogia

Pense na porta de uma loja.

- **O botão voltar** é a porta de saída. O cliente espera que ela **sempre** abra.
- **Bloquear o voltar** é trancar a porta enquanto o cliente está dentro. Não importa a
  justificativa — "ele ainda não pagou", "a promoção não acabou" —, trancar a porta é o que
  transforma uma loja em um problema.
- **Interceptar** é o vendedor na porta perguntando "você viu que deixou a sacola no provador?".
  A porta continua destrancada; ele só chama a atenção para algo que o cliente talvez não tenha
  notado. Depois de ouvir, o cliente **sai se quiser**.
- **Perguntar em toda saída** é o vendedor fazendo essa pergunta **todas as vezes**, mesmo quando
  não há sacola nenhuma. Em uma semana, o cliente aprende a dizer "não, obrigado" sem ouvir — e
  no dia em que a sacola estava mesmo no provador, ele sai sem ela.
- **As camadas** são as portas internas: provador, corredor, salão, rua. Sair do provador não
  deveria jogar o cliente direto na calçada. Cada "voltar" desfaz **um** passo.
- **Trabalho em andamento** é a compra sendo embalada. Prender o cliente no caixa até a embalagem
  terminar é desnecessário: ele pode circular pela loja, e você o chama quando estiver pronto.
- **O rascunho automático** é a loja **guardar a sacola do provador** sem perguntar nada. Da
  próxima vez que o cliente entrar, ela está lá. Nenhuma pergunta, nenhum trabalho perdido.

---

## 🧪 Exemplo mínimo

As camadas de "voltar" funcionando corretamente, e o antipadrão ao lado.

> **Arquivo:** `foco_nativo/lib/main.dart` (temporário)
> **Como executar:** `flutter run` em um **emulador Android** (para ter o botão voltar)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const AppVoltar());

class AppVoltar extends StatelessWidget {
  const AppVoltar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaComCamadas(),
    );
  }
}

class TelaComCamadas extends StatefulWidget {
  const TelaComCamadas({super.key});

  @override
  State<TelaComCamadas> createState() => _TelaComCamadasState();
}

class _TelaComCamadasState extends State<TelaComCamadas> {
  /// Camada 1: busca aberta.
  bool _buscaAberta = false;

  /// Camada 2: itens selecionados.
  final Set<int> _selecionados = <int>{};

  /// Camada 3: formulário com alterações.
  final TextEditingController _rascunho = TextEditingController();

  DateTime? _ultimoVoltar;

  bool get _temAlteracoes => _rascunho.text.trim().isNotEmpty;

  /// O `canPop` consulta TODAS as camadas.
  ///
  /// Só deixa sair quando nenhuma está aberta. Cada "voltar" desfaz
  /// UMA camada, na ordem inversa da abertura.
  bool get _podeSair =>
      !_buscaAberta && _selecionados.isEmpty && !_temAlteracoes;

  @override
  void initState() {
    super.initState();
    // Cada tecla muda o `canPop`. Sem este listener, o valor ficaria
    // congelado e a proteção não funcionaria.
    _rascunho.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _rascunho.dispose();
    super.dispose();
  }

  /// Desfaz UMA camada por vez.
  Future<void> _aoTentarVoltar(bool saiu, Object? resultado) async {
    if (saiu) return;

    // Ordem inversa da abertura: a última camada aberta é a primeira
    // a fechar. É o que o usuário espera.
    if (_buscaAberta) {
      setState(() => _buscaAberta = false);
      return;
    }

    if (_selecionados.isNotEmpty) {
      setState(_selecionados.clear);
      return;
    }

    if (_temAlteracoes) {
      final bool descartar = await _confirmarDescarte();
      if (!descartar || !mounted) return;
      _rascunho.clear();
      return;
    }

    // Tela raiz, nada aberto: confirmar a saída.
    // Só no Android — o iOS não tem voltar global, e a Apple proíbe
    // o app de se encerrar.
    if (Theme.of(context).platform != TargetPlatform.android) return;

    final DateTime agora = DateTime.now();
    final bool recente = _ultimoVoltar != null &&
        agora.difference(_ultimoVoltar!) < const Duration(seconds: 2);

    if (recente) {
      // Manda o app para segundo plano. NUNCA no iOS.
      await SystemNavigator.pop();
      return;
    }

    _ultimoVoltar = agora;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aperte voltar de novo para sair'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _confirmarDescarte() async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Descartar o que você escreveu?'),
        content: const Text('O texto não será salvo.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _podeSair,
      onPopInvokedWithResult: _aoTentarVoltar,
      child: Scaffold(
        appBar: AppBar(
          title: _buscaAberta
              ? const TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Buscar…',
                    border: InputBorder.none,
                  ),
                )
              : Text(_selecionados.isEmpty
                  ? 'Camadas de voltar'
                  : '${_selecionados.length} selecionados'),
          actions: <Widget>[
            if (!_buscaAberta && _selecionados.isEmpty)
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Buscar',
                onPressed: () => setState(() => _buscaAberta = true),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Camadas abertas:'),
                    const SizedBox(height: 8),
                    _Camada(rotulo: 'busca', ativa: _buscaAberta),
                    _Camada(
                      rotulo: 'seleção (${_selecionados.length})',
                      ativa: _selecionados.isNotEmpty,
                    ),
                    _Camada(rotulo: 'texto digitado', ativa: _temAlteracoes),
                    const Divider(),
                    Text(
                      _podeSair
                          ? '✅ voltar SAI do app'
                          : '↩️ voltar desfaz uma camada',
                      style: TextStyle(
                        color: _podeSair
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rascunho,
              decoration: const InputDecoration(
                labelText: 'Digite algo (cria uma camada)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Toque longo para selecionar:'),
            for (int i = 1; i <= 4; i++)
              ListTile(
                leading: Icon(
                  _selecionados.contains(i)
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                ),
                title: Text('Item $i'),
                selected: _selecionados.contains(i),
                onLongPress: () => setState(() => _selecionados.add(i)),
                onTap: _selecionados.isEmpty
                    ? null
                    : () => setState(() => _selecionados.contains(i)
                        ? _selecionados.remove(i)
                        : _selecionados.add(i)),
              ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const TelaPresa()),
              ),
              child: const Text('Ver o antipadrão →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Camada extends StatelessWidget {
  const _Camada({required this.rotulo, required this.ativa});

  final String rotulo;
  final bool ativa;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          ativa ? Icons.layers : Icons.layers_clear,
          size: 16,
          color: ativa ? Theme.of(context).colorScheme.primary : null,
        ),
        const SizedBox(width: 8),
        Text(rotulo, style: TextStyle(color: ativa ? null : Colors.grey)),
      ],
    );
  }
}

/// ❌ O ANTIPADRÃO: o usuário fica preso.
class TelaPresa extends StatelessWidget {
  const TelaPresa({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false SEM caminho de saída no callback.
      // O usuário aperta voltar e NADA acontece.
      canPop: false,
      onPopInvokedWithResult: (bool saiu, Object? r) {
        // Vazio de propósito. Este é o bug.
        debugPrint('tentou voltar — e não conseguiu');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tela presa'),
          // Sem esta seta, no iOS não haveria saída NENHUMA.
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Sair (a única saída)',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.lock, size: 64),
                SizedBox(height: 16),
                Text(
                  'Aperte o botão voltar do sistema.\n\n'
                  'Nada acontece.\n\n'
                  'No iOS, sem a seta acima, o usuário precisaria '
                  'fechar o app inteiro.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**O roteiro:**

1. Abra a busca, selecione dois itens, digite algo. As três camadas ficam ativas.
2. Aperte voltar **três vezes**: fecha a busca, limpa a seleção, pergunta sobre o texto.
3. Aperte voltar mais duas vezes: o aviso aparece e o app sai.
4. Entre na **tela presa** e aperte voltar. Nada acontece — e é exatamente esse o problema.
5. No iOS (`o` no terminal), tente o gesto de borda na tela presa: também não funciona.

---

## 📱 Aplicando no Flutter

O `foco_nativo` ganha um widget reutilizável que resolve as camadas de uma vez, e o aplica na tela
de matérias — que tem busca, seleção múltipla e cronômetro em andamento.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/lib/core/navegacao/camadas_de_voltar.dart` (novo)
> **Como executar:** `flutter run`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Uma camada que o botão voltar deve desfazer antes de sair da tela.
///
/// A ordem da lista é a ordem de FECHAMENTO: a primeira que estiver
/// ativa é a que fecha. Coloque as mais internas primeiro.
class CamadaDeVoltar {
  const CamadaDeVoltar({
    required this.ativa,
    required this.fechar,
    this.nome = '',
  });

  /// A camada está aberta agora? É consultado a cada rebuild.
  final bool Function() ativa;

  /// Fecha a camada. Devolve `false` para CANCELAR o voltar
  /// (o usuário escolheu "continuar editando", por exemplo).
  final Future<bool> Function() fechar;

  /// Só para diagnóstico.
  final String nome;
}

/// Trata o botão voltar do Android e o gesto de borda do iOS,
/// desfazendo uma camada por vez.
///
/// ⚠️ Regra desta aula: interceptar o voltar é aceitável; IMPEDIR não é.
/// Toda camada precisa de um caminho de saída — no máximo com uma
/// pergunta no meio.
class CamadasDeVoltar extends StatefulWidget {
  const CamadasDeVoltar({
    super.key,
    required this.camadas,
    required this.child,
    this.confirmarSaidaDoApp = false,
  });

  final List<CamadaDeVoltar> camadas;
  final Widget child;

  /// "Aperte voltar de novo para sair".
  ///
  /// Só faz sentido na tela RAIZ, e só no Android: o iOS não tem
  /// voltar global, e a Apple proíbe o app de se encerrar.
  final bool confirmarSaidaDoApp;

  @override
  State<CamadasDeVoltar> createState() => _CamadasDeVoltarState();
}

class _CamadasDeVoltarState extends State<CamadasDeVoltar> {
  DateTime? _ultimoVoltar;

  /// Só deixa o voltar passar quando NENHUMA camada está aberta.
  ///
  /// Este valor é lido pelo Android 14+ ANTES do gesto, para animar a
  /// espiada do predictive back — por isso ele precisa estar sempre
  /// atualizado. Módulo 07, aula 5.
  bool get _podeSair =>
      !widget.camadas.any((CamadaDeVoltar c) => c.ativa()) &&
      !widget.confirmarSaidaDoApp;

  Future<void> _aoTentarVoltar(bool saiu, Object? resultado) async {
    if (saiu) return;

    // Fecha a PRIMEIRA camada ativa. Uma por toque: o usuário espera
    // desfazer um passo de cada vez, na ordem inversa da abertura.
    for (final CamadaDeVoltar camada in widget.camadas) {
      if (!camada.ativa()) continue;

      final bool fechou = await camada.fechar();
      // `false` = o usuário cancelou (escolheu continuar editando).
      // Não seguimos para as camadas seguintes.
      return;
    }

    // Nenhuma camada aberta.
    if (!widget.confirmarSaidaDoApp) {
      // Não é a tela raiz: deixa sair de verdade.
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await _confirmarSaida();
  }

  Future<void> _confirmarSaida() async {
    // Só no Android. O iOS não tem voltar global, e chamar
    // SystemNavigator.pop() lá faz a Apple rejeitar o app.
    if (!mounted ||
        Theme.of(context).platform != TargetPlatform.android) {
      return;
    }

    final DateTime agora = DateTime.now();
    final bool recente = _ultimoVoltar != null &&
        agora.difference(_ultimoVoltar!) < const Duration(seconds: 2);

    if (recente) {
      // Manda o app para segundo plano — não "fecha".
      await SystemNavigator.pop();
      return;
    }

    _ultimoVoltar = agora;

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Aperte voltar de novo para sair'),
          // Mesmo tempo da janela de detecção: o aviso some
          // exatamente quando a segunda chance expira.
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _podeSair,
      onPopInvokedWithResult: _aoTentarVoltar,
      child: widget.child,
    );
  }
}
```

> **Arquivo:** `foco_nativo/lib/features/materias/presentation/materias_screen.dart` (usando)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_nativo/core/navegacao/camadas_de_voltar.dart';
import 'package:foco_nativo/features/cronometro/presentation/cronometro_controller.dart';

class MateriasScreen extends ConsumerStatefulWidget {
  const MateriasScreen({super.key});

  @override
  ConsumerState<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends ConsumerState<MateriasScreen> {
  bool _buscaAberta = false;
  final Set<String> _selecionadas = <String>{};
  final TextEditingController _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CamadasDeVoltar(
      // Esta é a tela raiz do app.
      confirmarSaidaDoApp: true,

      // ORDEM = ordem de fechamento. As mais internas primeiro.
      camadas: <CamadaDeVoltar>[
        // 1. Busca aberta: voltar FECHA A BUSCA.
        //    Sem isto, o usuário abre a busca, aperta voltar, e o app
        //    sai da tela — obrigando-o a navegar de volta.
        CamadaDeVoltar(
          nome: 'busca',
          ativa: () => _buscaAberta,
          fechar: () async {
            setState(() {
              _buscaAberta = false;
              _busca.clear();
            });
            return true;
          },
        ),

        // 2. Seleção múltipla: voltar CANCELA A SELEÇÃO.
        CamadaDeVoltar(
          nome: 'seleção',
          ativa: () => _selecionadas.isNotEmpty,
          fechar: () async {
            setState(_selecionadas.clear);
            return true;
          },
        ),

        // 3. Cronômetro rodando: voltar PERGUNTA.
        //
        //    Note que NÃO bloqueamos: o cronômetro é medido por
        //    carimbo (aula 6) e continua correndo mesmo com o app
        //    fechado. A pergunta existe só para o usuário não sair
        //    por engano achando que perdeu a sessão.
        CamadaDeVoltar(
          nome: 'cronômetro',
          ativa: () => ref.read(cronometroProvider) != null,
          fechar: _confirmarSaidaComCronometro,
        ),
      ],

      child: Scaffold(
        appBar: AppBar(
          title: _tituloDaBarra(),
          leading: _selecionadas.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancelar seleção',
                  onPressed: () => setState(_selecionadas.clear),
                )
              : null,
          actions: _acoesDaBarra(),
        ),
        body: const Center(child: Text('Lista de matérias')),
      ),
    );
  }

  Widget _tituloDaBarra() {
    if (_buscaAberta) {
      return TextField(
        controller: _busca,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Buscar matéria',
          border: InputBorder.none,
        ),
      );
    }
    if (_selecionadas.isNotEmpty) {
      return Text('${_selecionadas.length} selecionadas');
    }
    return const Text('Matérias');
  }

  List<Widget> _acoesDaBarra() {
    if (_selecionadas.isNotEmpty) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Excluir selecionadas',
          onPressed: () {},
        ),
      ];
    }
    if (_buscaAberta) return const <Widget>[];
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: 'Buscar',
        onPressed: () => setState(() => _buscaAberta = true),
      ),
    ];
  }

  /// Pergunta ao sair com o cronômetro rodando.
  ///
  /// Devolve `false` se o usuário decidir ficar — e aí o voltar
  /// é cancelado, sem fechar as outras camadas.
  Future<bool> _confirmarSaidaComCronometro() async {
    final int minutos = ref.read(cronometroProvider)?.minutos ?? 0;

    final String? escolha = await showDialog<String>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Sessão em andamento'),
        content: Text(
          'Você tem uma sessão de $minutos minutos rodando.\n\n'
          'O tempo continua contando mesmo se você sair do app.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop('ficar'),
            child: const Text('Ficar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop('concluir'),
            child: const Text('Concluir sessão'),
          ),
          FilledButton(
            // A opção que a maioria quer: sair sem mexer na sessão.
            onPressed: () => Navigator.of(c).pop('sair'),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (!mounted) return false;

    switch (escolha) {
      case 'concluir':
        final int registrados =
            await ref.read(cronometroProvider.notifier).encerrar();
        if (!mounted) return true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$registrados minutos registrados')),
        );
        return true;

      case 'sair':
        // A sessão continua. O cronômetro é medido por carimbo:
        // sair do app não interrompe nada.
        return true;

      default:
        // 'ficar' ou o usuário tocou fora: cancela o voltar.
        return false;
    }
  }
}
```

> **Arquivo:** `foco_nativo/lib/features/envio/presentation/envio_controller.dart` (novo)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de um envio em andamento.
///
/// Vive no PROVIDER, não na tela. É isso que permite ao usuário sair
/// da tela durante o envio: a operação continua, e o resultado chega
/// por um SnackBar global.
///
/// Com o estado na tela (`setState(() => _enviando = true)`), sair
/// mataria a operação — e o usuário ficaria preso esperando.
sealed class EstadoDoEnvio {
  const EstadoDoEnvio();
}

final class Parado extends EstadoDoEnvio {
  const Parado();
}

final class Enviando extends EstadoDoEnvio {
  const Enviando(this.descricao);
  final String descricao;
}

final class Enviado extends EstadoDoEnvio {
  const Enviado(this.descricao);
  final String descricao;
}

final class FalhouEnvio extends EstadoDoEnvio {
  const FalhouEnvio(this.mensagem);
  final String mensagem;
}

final NotifierProvider<EnvioController, EstadoDoEnvio> envioProvider =
    NotifierProvider<EnvioController, EstadoDoEnvio>(EnvioController.new);

class EnvioController extends Notifier<EstadoDoEnvio> {
  @override
  EstadoDoEnvio build() => const Parado();

  /// Envia. O usuário pode sair da tela — a operação continua.
  Future<void> enviar(String descricao) async {
    state = Enviando(descricao);

    try {
      await Future<void>.delayed(const Duration(seconds: 4));
      state = Enviado(descricao);
    } on Object catch (e) {
      state = FalhouEnvio('$e');
    }
  }
}
```

E um ouvinte global mostra o resultado, **independente da tela**:

```dart
// app.dart
class FocoApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o envio no nível do APP: o resultado chega mesmo que o
    // usuário tenha saído da tela onde iniciou.
    ref.listen<EstadoDoEnvio>(envioProvider,
        (EstadoDoEnvio? antes, EstadoDoEnvio agora) {
      final String? mensagem = switch (agora) {
        Enviado(descricao: final String d) => '$d enviado',
        FalhouEnvio(mensagem: final String m) => 'Falha no envio: $m',
        _ => null,
      };
      if (mensagem == null) return;

      _chaveDoMensageiro.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensagem)));
    });

    return MaterialApp(
      // GlobalKey: permite mostrar SnackBar de qualquer lugar,
      // sem depender do context de uma tela específica.
      scaffoldMessengerKey: _chaveDoMensageiro,
      home: const MateriasScreen(),
    );
  }
}

final GlobalKey<ScaffoldMessengerState> _chaveDoMensageiro =
    GlobalKey<ScaffoldMessengerState>();
```

Rode e teste o roteiro completo:

```powershell
flutter analyze
flutter run
```

1. Abra a busca → voltar **fecha a busca**.
2. Selecione matérias → voltar **cancela a seleção**.
3. Inicie o cronômetro → voltar **pergunta**, com três opções.
4. Escolha "Sair" → o app vai para segundo plano **com a sessão rodando**. Volte: o tempo
   continuou.
5. Inicie um envio e **saia da tela**. O `SnackBar` aparece 4 segundos depois, onde você estiver.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `CamadaDeVoltar` com `ativa` como **função** | Consultado a cada rebuild. Um `bool` fixo ficaria congelado e a proteção não funcionaria. |
| `fechar` devolvendo `bool` | `false` = o usuário cancelou. Sem isso, "continuar editando" fecharia a camada mesmo assim. |
| A **ordem** da lista | É a ordem de fechamento. Mais internas primeiro — o usuário desfaz na ordem inversa da abertura. |
| `for ... return;` depois de fechar uma | **Uma camada por toque.** Fechar todas de uma vez seria uma surpresa. |
| `_podeSair` consultando **todas** as camadas | O Android 14+ lê `canPop` **antes** do gesto, para animar a espiada. |
| `Navigator.of(context).pop()` quando não é raiz | Sem isto, uma tela sem camadas abertas ficaria **presa**. |
| `Theme.of(context).platform != TargetPlatform.android` | `SystemNavigator.pop()` no iOS faz a Apple **rejeitar** o app. |
| `duration: Duration(seconds: 2)` igual à janela | O aviso some exatamente quando a segunda chance expira. |
| Cronômetro como camada que **pergunta**, não bloqueia | Ele é medido por carimbo (aula 6): sair não interrompe nada. A pergunta evita a saída por engano. |
| Diálogo com **três** opções | "Ficar", "Concluir" e "Sair" cobrem as três intenções reais. Só sim/não obrigaria a escolher errado. |
| `FilledButton` em "Sair" | A ação de **maior ênfase** é a que a maioria quer. |
| `EstadoDoEnvio` no **provider** | Permite ao usuário sair durante o envio. Com `setState` na tela, sair mataria a operação. |
| `ref.listen` no `app.dart` | O resultado chega **onde o usuário estiver**, não só na tela que iniciou. |
| `scaffoldMessengerKey` global | Mostra `SnackBar` sem depender do `context` de uma tela. |

---

## 🤖🍎 Android × iOS

Esta tabela complementa a do
[Módulo 07, aula 5](../07-navegacao-e-formularios/05-navegacao-android-x-ios.md), com foco nas
**consequências de produto**:

| Situação | 🤖 Android | 🍎 iOS |
|---|---|---|
| Voltar acidental | Ocasional | **Frequente** — a borda é fácil de tocar sem querer |
| Usuário preso sem saída | Pode usar o gesto do sistema para trocar de app | Precisa **fechar o app** |
| "Aperte de novo para sair" | Padrão conhecido | **Não existe** — não implemente |
| Fechar o app por código | `SystemNavigator.pop()` | **Proibido** pela Apple |
| Camadas (busca, seleção) | Esperado | Esperado, mas o usuário também usa o `X` na barra |
| Predictive back | Android 14+ mostra a espiada | Não aplicável |

> ⚠️ **A primeira linha muda o cálculo de produto.** No iPhone, o gesto de borda é acionado por
> acidente com frequência — ao rolar uma lista perto da margem, ao segurar o aparelho com uma mão.
> Um formulário sem proteção **perde trabalho de usuário toda semana** no iOS, e raramente no
> Android.
>
> Isso significa que o diálogo de descarte, que parece excesso de zelo, é **mais necessário** no iOS
> do que no Android.

> 📌 **No iOS, sempre ofereça uma saída visível na barra** (`X` ou `Cancelar`), além do gesto. É o
> que impede o usuário de ficar preso quando alguma camada não libera.

---

## ⚠️ Erros comuns

### 1. `canPop: false` sem saída

```dart
PopScope(canPop: false, onPopInvokedWithResult: (s, r) {}, child: tela)   // ❌
```

O usuário fica preso.

**Correção:** todo `canPop: false` precisa de um caminho que chame `Navigator.pop()`.

### 2. Fechar todas as camadas de uma vez

```dart
onPopInvokedWithResult: (bool saiu, Object? r) {
  setState(() {
    _buscaAberta = false;
    _selecionados.clear();   // ⚠️ o usuário só queria fechar a busca
  });
}
```

**Correção:** uma camada por toque, com `return` depois de fechar.

### 3. Esquecer de tratar o caso "nenhuma camada"

```dart
for (final camada in camadas) {
  if (camada.ativa()) { camada.fechar(); return; }
}
// … e nada aqui ❌ — a tela fica presa
```

**Correção:** `Navigator.pop()` quando não há camadas.

### 4. `SystemNavigator.pop()` no iOS

A Apple **rejeita** o app (guia 2.5.1).

**Correção:** cheque `Theme.of(context).platform`.

### 5. "Aperte de novo para sair" no iOS

Não existe voltar global. O código simplesmente nunca roda — ou, pior, o `SystemNavigator.pop()`
roda e o app é rejeitado.

**Correção:** só no Android.

### 6. Perguntar em toda tela

O usuário aprende a apertar "sim" sem ler — e no dia em que havia trabalho de verdade, ele perde.

**Correção:** pergunte só quando há **risco real** de perda.

### 7. Bloquear durante operação longa

```dart
canPop: !_enviando,   // ⚠️ em rede ruim, 30 segundos preso
```

**Correção:** estado no provider, operação continua, resultado por `SnackBar` global.

### 8. `canPop` congelado

```dart
late final bool _sujo = _campo.text.isNotEmpty;   // ❌ avaliado uma vez
```

**Correção:** getter recalculado, com `setState` a cada mudança.

### 9. Não oferecer saída visível no iOS

Sem `X` na barra, uma camada com bug deixa o usuário sem alternativa.

**Correção:** sempre ofereça a saída na interface, além do gesto.

### 10. Diálogo com só duas opções quando há três intenções

"Sair sem salvar?" [Cancelar] [Sair] — e o usuário que queria **salvar e sair** precisa cancelar,
salvar, e sair de novo.

**Correção:** as três opções reais.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e execute o roteiro de cinco passos. Confirme que cada voltar
desfaz **uma** camada.

**Passo 2.** Inverta a ordem das camadas em `_aoTentarVoltar` (cronômetro antes da busca). Abra a
busca com o cronômetro rodando e aperte voltar. O que acontece? É o que o usuário espera?

**Passo 3.** No `CamadasDeVoltar`, remova o `return` depois de `camada.fechar()`. Abra as três
camadas e aperte voltar uma vez. Descreva o resultado.

**Passo 4.** Remova o `Navigator.of(context).pop()` do caso "nenhuma camada". Navegue para uma tela
de detalhe e tente voltar.

**Passo 5.** Entre na **tela presa** do exemplo mínimo e tente sair pelo botão voltar. Depois pelo
gesto de borda (modo iOS). Anote quantos caminhos de saída restaram.

**Passo 6.** Em `_confirmarSaidaComCronometro`, troque as três opções por duas (Cancelar / Sair).
Simule ser um usuário que queria concluir a sessão e sair. Quantos toques ele precisa?

**Passo 7.** Mova o estado do envio para dentro da tela (`setState(() => _enviando = true)`). Inicie
um envio, saia da tela, e espere. O `SnackBar` aparece?

**Passo 8.** Ponha `canPop: !_enviando` na tela de envio. Inicie e tente sair. Cronometre quanto
tempo você ficou preso.

**Passo 9.** Adicione uma quarta camada (um painel de filtros) e confirme que a ordem continua
correta.

**Passo 10.** Responda por escrito: por que o diálogo de descarte é **mais** necessário no iOS que
no Android, apesar de os dois terem a mesma mecânica?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os exercícios de **Aplicação** com camadas de voltar, o de **Correção de bugs** com usuário
preso, e o de **Decisão** sobre bloquear × continuar em segundo plano.

---

## 🏆 Desafio opcional

Implemente **desfazer global**: em vez de perguntar antes de sair, deixe o usuário sair e ofereça
desfazer depois.

Requisitos:

- Ao sair de um formulário com alterações, o app **salva rascunho** e sai **sem perguntar**.
- Um `SnackBar` aparece: "Rascunho salvo · **Voltar a editar**".
- Tocar em "Voltar a editar" reabre a tela com o conteúdo restaurado.
- Se o usuário ignorar, o rascunho fica disponível na próxima abertura do formulário.
- Rascunhos com mais de 7 dias são descartados.
- Nenhum diálogo de descarte em lugar nenhum do app.

Depois compare as duas abordagens medindo, em você mesmo: quantos toques cada uma custa no caminho
mais comum (sair sem querer salvar nada)?

E responda: em que tipo de formulário essa abordagem **não** funciona? (Dica: pense num formulário
de pagamento, e no que "rascunho salvo" significaria ali.)

---

## 📌 Resumo

- Android e iOS resolvem a mesma necessidade — "desfazer o último passo" — com gestos diferentes.
  A **expectativa do usuário é idêntica**.
- **Interceptar o voltar é aceitável; impedir não é.** Todo `canPop: false` precisa de um caminho
  de saída.
- Quatro casos legítimos: **perda de dados**, **desfazer camada de interface**, **voltar à primeira
  aba**, **confirmar saída do app**.
- O caso mais comum e menos implementado é o segundo: voltar deve **fechar a busca**, **cancelar a
  seleção**, **sair da tela cheia** — antes de mudar de tela.
- Feche **uma camada por toque**, na ordem inversa da abertura.
- Em `PopScope` aninhados, **o mais interno vence** — e cada camada precisa liberar a seguinte.
- Trabalho em andamento: prefira **continuar em segundo plano** a bloquear. Isso exige o estado no
  **provider**, não na tela.
- **"Aperte de novo para sair" e `SystemNavigator.pop()` são só Android.** No iOS, a Apple rejeita.
- **Perguntar em toda tela** treina o usuário a não ler o diálogo.
- No **iOS**, o voltar acidental é muito mais frequente — o que torna a proteção **mais**
  necessária lá, e exige uma saída visível na barra.
- A melhor solução costuma ser a que **não pergunta nada**: rascunho automático.

---

## ☑️ Checklist de domínio

- [ ] Sei que interceptar é aceitável e impedir não é.
- [ ] Cito os quatro casos legítimos de interceptação.
- [ ] Faço o voltar fechar busca, seleção e tela cheia antes de mudar de tela.
- [ ] Fecho uma camada por toque, na ordem inversa da abertura.
- [ ] Todo `canPop: false` do meu app tem caminho de saída.
- [ ] Mantenho `canPop` sempre atualizado.
- [ ] Deixo operações longas continuarem em segundo plano, com estado no provider.
- [ ] Uso `SystemNavigator.pop()` só no Android.
- [ ] Não pergunto em telas sem risco real de perda.
- [ ] Ofereço saída visível na barra, no iOS.
- [ ] Meus diálogos têm as opções que correspondem às intenções reais.

---

## 📚 Referências oficiais

- [PopScope — api.flutter.dev](https://api.flutter.dev/flutter/widgets/PopScope-class.html)
- [Predictive back gesture — docs.flutter.dev](https://docs.flutter.dev/release/breaking-changes/android-predictive-back)
- [Navigation and routing — docs.flutter.dev](https://docs.flutter.dev/ui/navigation)
- [Back navigation — developer.android.com](https://developer.android.com/guide/navigation/custom-back)
- [Navigation — Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search)
- [App Store Review Guidelines 2.5.1](https://developer.apple.com/app-store/review/guidelines/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — Pastas android/ e ios/](07-pastas-android-e-ios.md) | [README](README.md) | [Aula 9 — Material × Cupertino](09-material-x-cupertino.md) |
