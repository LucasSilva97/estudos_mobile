# Aula 5 — Navegação Android × iOS

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Descrever as diferenças **reais** de navegação entre Android e iOS — e quais o Flutter já resolve
  sozinho.
- Configurar **`PageTransitionsTheme`** para escolher a animação de troca de tela por plataforma.
- Entender o **gesto de arrastar da borda** do iOS: quando ele funciona, quando não funciona, e o
  que o desabilita sem você perceber.
- Usar **`PopScope`** corretamente na API atual (`canPop` + `onPopInvokedWithResult`) e saber por
  que `WillPopScope` sumiu.
- Impedir a perda de dados com um diálogo de "descartar alterações?" que funciona **nas duas**
  plataformas.
- Saber o que `SystemNavigator.pop()` faz, e por que você **nunca** deve chamá-lo no iOS.
- Decidir o que fazer quando o usuário aperta voltar na tela raiz.

## ✅ Pré-requisitos

- [Aula 1 — Navigator: a pilha](01-navigator-a-pilha.md) — `push`, `pop`, `fullscreenDialog`.
- [Aula 3 — Argumentos e resultados](03-argumentos-e-resultados.md) — o resultado `null` que o
  gesto de borda produz.
- [Aula 4 — Abas e organização](04-abas-e-organizacao.md) — o `PopScope` apareceu lá; aqui ele é
  explicado por inteiro.
- [Módulo 05, aula 9 — Material e Cupertino](../05-introducao-ao-flutter/09-material-e-cupertino.md)
  — a decisão do curso sobre adaptação.
- O projeto `foco_navegacao` rodando.

---

## 📖 Conceito

### O que o Flutter já faz sozinho

Boa notícia antes da lista de diferenças: **o Flutter adapta a navegação automaticamente**. Sem
você escrever nada, um `MaterialPageRoute` se comporta assim:

| Comportamento | 🤖 Android | 🍎 iOS |
|---|---|---|
| Animação de entrada da tela | Sobe de baixo, com fade | Desliza da **direita para a esquerda** |
| Animação de saída | Desce | Desliza de volta para a direita |
| Seta de voltar na `AppBar` | `←` | `‹` (mais fina, estilo iOS) |
| Rótulo ao lado da seta | Não | Sim, o título da tela anterior |
| Arrastar da borda esquerda para voltar | Não | **Sim, automaticamente** |
| Botão/gesto de voltar do sistema | Sim | Não existe |

Ou seja: o app que você construiu nas aulas 1 a 4 **já parece nativo** nos dois sistemas. Esta aula
é sobre os casos em que isso não basta — e sobre não estragar o que já funciona.

### O gesto de borda do iOS

No iPhone, arrastar da borda esquerda para a direita volta uma tela. Esse gesto é tão enraizado que
muitos usuários **nunca** tocam na seta da `AppBar`.

O Flutter implementa isso via `CupertinoPageTransitionsBuilder`, que está ativo por padrão quando
`Theme.of(context).platform == TargetPlatform.iOS`.

**O que desliga o gesto sem você perceber:**

| Causa | Por quê |
|---|---|
| `fullscreenDialog: true` | Modais não voltam por gesto lateral — é o padrão do iOS |
| `PopScope(canPop: false)` | Você bloqueou o pop; o gesto respeita isso |
| Uma transição customizada sem suporte ao gesto | `PageRouteBuilder` cru não tem o gesto |
| `PageTransitionsTheme` forçando o builder do Android | Você trocou a transição do iOS sem querer |

> ⚠️ **Consequência prática:** se você configurar uma transição customizada "bonitinha" para o app
> inteiro, você **remove o gesto de voltar do iOS**. Usuários de iPhone vão achar o app quebrado.
> Essa é a razão número 1 para não mexer nas transições sem necessidade.

### `PageTransitionsTheme`

Se você quiser controlar as animações por plataforma:

```dart
ThemeData(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
)
```

Os builders disponíveis:

| Builder | Efeito | Onde é padrão |
|---|---|---|
| `FadeUpwardsPageTransitionsBuilder` | Sobe com fade | Android antigo |
| `OpenUpwardsPageTransitionsBuilder` | Abre de baixo, Material 2 | — |
| `ZoomPageTransitionsBuilder` | Zoom suave | **Android atual** |
| `CupertinoPageTransitionsBuilder` | Desliza lateral **+ gesto de borda** | **iOS e macOS** |
| `PredictiveBackPageTransitionsBuilder` | *Predictive back* do Android 14+ | Android moderno |

> 📌 **`PredictiveBackPageTransitionsBuilder`** é o que faz a animação de "espiada" do Android 14+:
> quando o usuário começa o gesto de voltar, ele já vê a tela anterior atrás, e pode desistir. Vale
> ativar — mas exija também a configuração no `AndroidManifest.xml`, mostrada na seção prática.

**Decisão do curso:** deixe o padrão, exceto por ativar o *predictive back* no Android. Toda
customização de transição corre o risco de quebrar o gesto do iOS.

### `PopScope`: interceptar o voltar

`WillPopScope` foi **removido** do Flutter. A API atual é `PopScope`, e ela funciona de um jeito
diferente — o que confunde quem aprendeu com tutoriais antigos.

```dart
PopScope(
  canPop: !_temAlteracoesNaoSalvas,
  onPopInvokedWithResult: (bool saiu, Object? resultado) async {
    if (saiu) return;             // o pop aconteceu; nada a fazer
    // Chegamos aqui porque canPop era false: o pop foi BLOQUEADO.
    final bool descartar = await _perguntarSeDescarta();
    if (descartar && context.mounted) {
      Navigator.of(context).pop();   // agora sim, saímos
    }
  },
  child: Scaffold(...),
)
```

A diferença central em relação ao `WillPopScope`:

| | `WillPopScope` (removido) | `PopScope` (atual) |
|---|---|---|
| Como decide | Uma função `async` que devolve `bool` | Um `bool` **síncrono** (`canPop`) |
| Quando decide | Na hora do pop | **Antes**, continuamente |
| Por que mudou | O Android 14 precisa saber **antes** do gesto se a tela vai sair, para animar a espiada | |

> 💡 **Essa é a razão técnica da mudança.** O *predictive back* precisa da resposta **antes** de o
> gesto terminar. Uma função `async` responderia tarde demais. Por isso `canPop` é um booleano que
> você mantém atualizado com `setState`.

**O erro clássico:** deixar `canPop: false` fixo e esquecer de dar `pop` depois. O usuário fica
preso na tela.

```dart
PopScope(
  canPop: false,                       // ❌ nunca deixa sair
  onPopInvokedWithResult: (s, r) {},   // ❌ e não faz nada
  child: ...,
)
```

### Voltar na tela raiz

O que acontece quando o usuário aperta voltar na primeira tela do app?

| Plataforma | Comportamento padrão |
|---|---|
| 🤖 Android | O app vai para segundo plano (não é fechado) |
| 🍎 iOS | Não acontece nada — não existe voltar global |

Se você quiser confirmar antes de sair ("aperte voltar de novo para sair"), o padrão é:

```dart
DateTime? _ultimoVoltar;

PopScope(
  canPop: false,
  onPopInvokedWithResult: (bool saiu, Object? r) {
    if (saiu) return;

    final DateTime agora = DateTime.now();
    final bool recente = _ultimoVoltar != null &&
        agora.difference(_ultimoVoltar!) < const Duration(seconds: 2);

    if (recente) {
      SystemNavigator.pop();   // sai do app — só Android
      return;
    }

    _ultimoVoltar = agora;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aperte voltar de novo para sair'),
        duration: Duration(seconds: 2),
      ),
    );
  },
  child: Scaffold(...),
)
```

> ⚠️ **`SystemNavigator.pop()` no iOS é proibido.** A Apple rejeita apps que se fecham
> programaticamente — o guia de revisão diz que o usuário deve fechar o app, não o app a si mesmo.
> No iOS, esse código simplesmente não deve rodar. E nem faz falta: não há botão voltar lá.

### Quando o usuário perde dados

O caso mais importante desta aula: o usuário preencheu um formulário e aperta voltar por engano —
ou faz o gesto de borda sem querer, o que é **muito** mais comum no iPhone.

Sem proteção, o trabalho some sem aviso. Com `PopScope`:

```dart
final bool sujo = _nome.text != _nomeOriginal || _meta != _metaOriginal;

PopScope(
  canPop: !sujo,
  onPopInvokedWithResult: (bool saiu, Object? r) async {
    if (saiu) return;
    final bool descartar = await Dialogos.confirmar(
      context,
      titulo: 'Descartar alterações?',
      mensagem: 'O que você preencheu será perdido.',
      rotuloConfirmar: 'Descartar',
      destrutivo: true,
    );
    if (descartar && context.mounted) Navigator.of(context).pop();
  },
  child: Scaffold(...),
)
```

Detalhe fundamental: `canPop` precisa ser **recalculado** sempre que o formulário muda. Se você
calcular uma vez no `initState`, a proteção não funciona.

---

## 💡 Analogia

Pense em duas casas com portas diferentes.

- **A casa Android** tem uma **porta de saída própria**, e um botão de campainha invertido: existe
  um "sair" universal, disponível em qualquer cômodo. É por isso que você precisa decidir o que
  acontece quando alguém aperta esse botão na sala de estar — sair da casa? voltar para o corredor?
- **A casa iOS** não tem esse botão. A única saída é **desfazer o caminho de entrada** — voltando
  pela porta por onde você veio. E a maçaneta fica na **borda esquerda** de cada porta: você
  empurra de lado e ela abre.
- **Transição customizada que quebra o gesto** é trocar todas as maçanetas da casa iOS por
  fechaduras eletrônicas bonitas — e esquecer que o morador abria as portas empurrando. Ele agora
  fica preso em cada cômodo, achando que a casa quebrou.
- **`PopScope`** é uma tranca que você controla. `canPop: false` é a tranca fechada. Se você fecha
  a tranca e não dá a chave a ninguém (`onPopInvokedWithResult` vazio), **prendeu o morador**.
- **O `WillPopScope` antigo** perguntava "posso sair?" no momento em que a pessoa já estava
  girando a maçaneta. O Android 14 precisa saber **antes** — para mostrar um vislumbre do que tem
  do outro lado enquanto a porta ainda está abrindo. Por isso hoje a resposta é um estado, não uma
  pergunta.
- **`SystemNavigator.pop()` no iOS** é demolir a própria casa para sair dela. A prefeitura (a
  Apple) não aprova a planta.

---

## 🧪 Exemplo mínimo

Este programa mostra `PopScope` protegendo um formulário — e você consegue provocar os dois
caminhos.

> **Arquivo:** `foco_navegacao/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome` (e aperte `o` no terminal para alternar a plataforma)

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppVoltar());

class AppVoltar extends StatelessWidget {
  const AppVoltar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        // Transições por plataforma. O Cupertino traz o gesto de borda junto.
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const TelaLista(),
    );
  }
}

class TelaLista extends StatelessWidget {
  const TelaLista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Plataforma: ${Theme.of(context).platform.name}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const TelaForm()),
              ),
              child: const Text('Abrir formulário (empilhado)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  // No iOS isto DESLIGA o gesto de borda — de propósito.
                  fullscreenDialog: true,
                  builder: (_) => const TelaForm(),
                ),
              ),
              child: const Text('Abrir formulário (modal)'),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaForm extends StatefulWidget {
  const TelaForm({super.key});

  @override
  State<TelaForm> createState() => _TelaFormState();
}

class _TelaFormState extends State<TelaForm> {
  final TextEditingController _texto = TextEditingController();

  /// Recalculado a cada tecla. É ESTE valor que o PopScope consulta.
  bool get _sujo => _texto.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Sem este listener, canPop nunca mudaria e a proteção não funcionaria.
    _texto.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<bool> _perguntarSeDescarta() async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você digitou será perdido.'),
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
      // Só deixa sair sem perguntar quando NÃO há nada digitado.
      canPop: !_sujo,

      onPopInvokedWithResult: (bool saiu, Object? resultado) async {
        // saiu == true: o pop já aconteceu (canPop era true). Nada a fazer.
        if (saiu) return;

        // saiu == false: o pop foi BLOQUEADO. Agora decidimos.
        final bool descartar = await _perguntarSeDescarta();
        if (!context.mounted) return;
        if (descartar) Navigator.of(context).pop();
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text('Formulário'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _texto,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Digite algo e tente voltar',
                ),
              ),
              const SizedBox(height: 24),
              Text(_sujo
                  ? '⚠️ Há alterações: voltar vai perguntar'
                  : '✅ Sem alterações: voltar sai direto'),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Teste os quatro caminhos:**

1. Abra empilhado, **não** digite nada, volte → sai direto.
2. Abra empilhado, **digite algo**, volte → o diálogo pergunta.
3. Aperte `o` no terminal para virar iOS, abra **empilhado** e arraste da borda esquerda → o gesto
   funciona (e respeita o `PopScope`).
4. Ainda em iOS, abra **modal** (`fullscreenDialog`) e tente arrastar da borda → **não funciona**.
   Compare com o caminho 3.

---

## 📱 Aplicando no Flutter

No `foco_navegacao` você vai:

1. Configurar o `PageTransitionsTheme` com *predictive back* no Android.
2. Fazer o `MateriaFormScreen` proteger contra perda de dados, nas duas plataformas.
3. Ajustar o `HomeScreen` para tratar o voltar na raiz **só no Android**.
4. Ativar o *predictive back* também no `AndroidManifest.xml`.

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/core/tema/tema_app.dart` (acrescente o `pageTransitionsTheme`)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

abstract final class TemaApp {
  static const Color _semente = Color(0xFF3F51B5);

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get escuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _semente,
        brightness: brilho,
      ),

      // ── Transições por plataforma ──────────────────────────────────────
      // Cupertino no iOS é OBRIGATÓRIO: é ele que traz o gesto de arrastar
      // da borda. Trocá-lo por qualquer outro remove o gesto e faz o app
      // parecer quebrado no iPhone.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
```

> **Arquivo:** `foco_navegacao/android/app/src/main/AndroidManifest.xml`
> (acrescente o atributo na tag `<application>`)

```xml
<application
    android:label="foco_navegacao"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:enableOnBackInvokedCallback="true">
    <!--                    ↑
        Sem esta linha, o PredictiveBackPageTransitionsBuilder não tem
        efeito: o Android 14+ só entrega os eventos de "espiada" para apps
        que declararam suporte. O atributo é ignorado em versões antigas.
    -->
```

> **Arquivo:** `foco_navegacao/lib/features/materias/presentation/materia_form_screen.dart`
> (versão com proteção contra perda de dados)

```dart
import 'package:flutter/material.dart';

import 'package:foco_navegacao/features/materias/domain/materia.dart';

class MateriaFormArgs {
  const MateriaFormArgs.criar() : original = null;
  const MateriaFormArgs.editar(Materia materia) : original = materia;

  final Materia? original;
  bool get ehEdicao => original != null;
}

class MateriaFormScreen extends StatefulWidget {
  const MateriaFormScreen({super.key, required this.args});

  final MateriaFormArgs args;

  @override
  State<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends State<MateriaFormScreen> {
  late final String _nomeOriginal = widget.args.original?.nome ?? '';
  late final int _metaOriginal = widget.args.original?.metaMinutos ?? 60;

  late final TextEditingController _nome =
      TextEditingController(text: _nomeOriginal);
  late int _meta = _metaOriginal;

  /// Há alterações não salvas?
  ///
  /// É um GETTER, não um campo: precisa ser recalculado a cada rebuild.
  /// Um campo calculado no initState deixaria a proteção sempre falsa.
  bool get _temAlteracoes =>
      _nome.text.trim() != _nomeOriginal.trim() || _meta != _metaOriginal;

  @override
  void initState() {
    super.initState();
    // Cada tecla digitada precisa disparar rebuild — é o rebuild que
    // atualiza o `canPop` do PopScope.
    _nome.addListener(_aoDigitar);
  }

  @override
  void dispose() {
    _nome.removeListener(_aoDigitar);
    _nome.dispose();
    super.dispose();
  }

  void _aoDigitar() => setState(() {});

  Future<bool> _confirmarDescarte() async {
    final bool? resposta = await showDialog<bool>(
      context: context,
      builder: (BuildContext contextDoDialogo) {
        final ColorScheme cores = Theme.of(contextDoDialogo).colorScheme;
        return AlertDialog(
          title: const Text('Descartar alterações?'),
          content: const Text(
            'O que você preencheu não será salvo.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(contextDoDialogo).pop(false),
              child: const Text('Continuar editando'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cores.error,
                foregroundColor: cores.onError,
              ),
              onPressed: () => Navigator.of(contextDoDialogo).pop(true),
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );
    // null (tocou fora) = não descartar. Escolha segura.
    return resposta ?? false;
  }

  void _salvar() {
    final String nome = _nome.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da matéria')),
      );
      return;
    }

    final Materia resultado = widget.args.original
            ?.copyWith(nome: nome, metaMinutos: _meta) ??
        Materia(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          nome: nome,
          minutosEstudados: 0,
          metaMinutos: _meta,
        );

    Navigator.of(context).pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // O Android 14 consulta este booleano ANTES do gesto, para animar
      // a espiada. Por isso ele precisa estar sempre atualizado.
      canPop: !_temAlteracoes,

      onPopInvokedWithResult: (bool saiu, Object? resultado) async {
        if (saiu) return; // o pop passou; nada a fazer

        final bool descartar = await _confirmarDescarte();
        if (!context.mounted) return;
        if (descartar) Navigator.of(context).pop();
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.args.ehEdicao ? 'Editar matéria' : 'Nova matéria'),
          actions: <Widget>[
            TextButton(
              onPressed: _temAlteracoes ? _salvar : null,
              child: const Text('Salvar'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            TextField(
              controller: _nome,
              autofocus: !widget.args.ehEdicao,
              decoration: const InputDecoration(labelText: 'Nome da matéria'),
            ),
            const SizedBox(height: 24),
            Text('Meta: $_meta minutos'),
            Slider(
              value: _meta.toDouble(),
              min: 15,
              max: 240,
              divisions: 15,
              label: '$_meta min',
              onChanged: (double v) => setState(() => _meta = v.round()),
            ),
            const SizedBox(height: 24),
            // Indicador honesto do estado do formulário.
            Text(
              _temAlteracoes
                  ? 'Há alterações não salvas.'
                  : 'Nenhuma alteração.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

E o `HomeScreen`, com "aperte voltar de novo para sair" — **só no Android**:

> **Arquivo:** `foco_navegacao/lib/features/home/presentation/home_screen.dart`
> (o `PopScope` da aula 4, agora completo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// … dentro de _HomeScreenState …

  DateTime? _ultimoVoltar;

  void _aoTentarVoltar(bool saiu, Object? resultado) {
    if (saiu) return;

    // Regra 1: se não estamos na primeira aba, voltar leva para ela.
    if (_indice != 0) {
      _selecionar(0);
      return;
    }

    // Regra 2: já na primeira aba — confirmar antes de sair.
    // Só faz sentido no Android: o iOS não tem voltar global e
    // proíbe o app de se fechar sozinho.
    final bool ehAndroid =
        Theme.of(context).platform == TargetPlatform.android;
    if (!ehAndroid) return;

    final DateTime agora = DateTime.now();
    final bool apertouRecente = _ultimoVoltar != null &&
        agora.difference(_ultimoVoltar!) < const Duration(seconds: 2);

    if (apertouRecente) {
      // Manda o app para segundo plano. NUNCA chame isto no iOS:
      // a Apple rejeita apps que se encerram programaticamente.
      SystemNavigator.pop();
      return;
    }

    _ultimoVoltar = agora;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aperte voltar de novo para sair'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool telaLarga = MediaQuery.sizeOf(context).width >= 600;

    return PopScope(
      // Nunca deixamos o pop passar direto: sempre decidimos no callback.
      canPop: false,
      onPopInvokedWithResult: _aoTentarVoltar,
      child: Scaffold(
        // … o resto igual à aula 4 …
      ),
    );
  }
```

Rode e teste:

```powershell
flutter analyze
flutter run -d chrome
```

1. Aperte `o` no terminal para alternar entre Android e iOS. Abra o detalhe de uma matéria e
   observe **a animação mudar**.
2. Abra o formulário, digite algo e tente voltar → o diálogo aparece.
3. Apague o que digitou e tente voltar → sai direto, sem perguntar.
4. Na aba Ajustes, aperte voltar → vai para Hoje. Aperte de novo → aparece o aviso. De novo → sai
   (no Android).

> Para ver o *predictive back* de verdade, você precisa de um **emulador Android 14 ou superior**.
> No Chrome e no Windows a configuração é aplicada mas o efeito não aparece.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `TargetPlatform.iOS: CupertinoPageTransitionsBuilder()` | **Obrigatório** para manter o gesto de borda. Trocar por qualquer outro remove o gesto e quebra a expectativa do usuário de iPhone. |
| `TargetPlatform.android: PredictiveBackPageTransitionsBuilder()` | Ativa a animação de espiada do Android 14+. Precisa também do atributo no manifest. |
| `android:enableOnBackInvokedCallback="true"` | Sem isso, o Android 14+ não entrega os eventos preditivos ao app. Ignorado em versões antigas — é seguro deixar sempre. |
| `bool get _temAlteracoes` como **getter** | Recalculado a cada rebuild. Um campo calculado no `initState` ficaria congelado e a proteção nunca dispararia. |
| `_nome.addListener(_aoDigitar)` + `setState(() {})` | É o rebuild que atualiza o `canPop`. Sem o listener, `canPop` nunca muda enquanto o usuário digita. |
| `canPop: !_temAlteracoes` | Sem alterações → deixa sair direto. Com alterações → bloqueia e cai no callback. |
| `if (saiu) return;` | `saiu == true` significa que o pop **aconteceu** (porque `canPop` era `true`). Só agimos quando ele foi **impedido**. |
| `if (!context.mounted) return;` depois do diálogo | O diálogo é um `await`: entre abri-lo e fechá-lo, a tela pode ter sido descartada. |
| `return resposta ?? false;` | Tocar fora do diálogo devolve `null`. Tratar como "não descartar" protege o trabalho do usuário. |
| `onPressed: _temAlteracoes ? _salvar : null` | Botão Salvar desabilitado quando não há o que salvar. Sinal honesto do estado. |
| `canPop: false` no `HomeScreen` | Aqui **sempre** decidimos no callback — nunca queremos o pop automático na raiz. |
| `Theme.of(context).platform == TargetPlatform.android` | Checagem que funciona na web (diferente de `Platform.isAndroid`, que exige `dart:io`). |
| `SystemNavigator.pop()` | Manda o app para segundo plano no Android. **Nunca** no iOS. |
| `agora.difference(_ultimoVoltar!) < const Duration(seconds: 2)` | Janela de 2 s para o segundo toque — o mesmo tempo da duração do `SnackBar`, de propósito. |

---

## 🤖🍎 Android × iOS

Resumo completo das diferenças e do que você faz com cada uma:

| Diferença | 🤖 Android | 🍎 iOS | Quem resolve |
|---|---|---|---|
| Animação de troca de tela | Zoom / predictive | Deslizar lateral | **Flutter**, automático |
| Voltar por gesto de borda | Não | Sim | **Flutter**, automático |
| Botão/gesto de voltar global | Sim | Não | **Você**, com `PopScope` |
| Rótulo ao lado da seta de voltar | Não | Sim | **Flutter**, automático |
| Modal (`fullscreenDialog`) | `X` no lugar da seta | `Cancelar`, sem gesto de borda | **Flutter**, automático |
| Fechar o app por código | `SystemNavigator.pop()` | **Proibido** | **Você**, com checagem |
| Confirmação antes de sair | Comum e esperado | Não existe | **Você** |
| Perda de dados por gesto acidental | Menos comum | **Muito comum** | **Você**, com `PopScope` |

> 📌 A linha mais importante é a última. No iPhone, o gesto de borda é feito **dezenas de vezes por
> dia**, muitas vezes por acidente. Um formulário sem `PopScope` perde trabalho de usuário toda
> semana — e quem reporta o bug diz "o app apagou o que eu escrevi", não "o gesto voltou a tela".

---

## ⚠️ Erros comuns

### 1. Usar `WillPopScope`

```dart
WillPopScope(onWillPop: () async => true, child: ...) // ❌ removido
```

```text
The method 'WillPopScope' isn't defined for the type…
```

**Correção:** `PopScope` com `canPop` + `onPopInvokedWithResult`.

### 2. `onPopInvoked` (obsoleto) em vez de `onPopInvokedWithResult`

```dart
PopScope(canPop: false, onPopInvoked: (bool saiu) {...}) // ⚠️ obsoleto
```

`onPopInvoked` ainda compila mas está marcado como obsoleto; ele não recebe o resultado do pop.

**Correção:** `onPopInvokedWithResult: (bool saiu, Object? resultado) {...}`.

### 3. `canPop: false` sem saída

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (bool saiu, Object? r) {
    debugPrint('tentou voltar');   // ❌ e nunca deixa
  },
  child: ...,
)
```

O usuário fica **preso**. No iOS, sem botão voltar, ele precisa fechar o app.

**Correção:** todo `canPop: false` precisa de um caminho que chame `Navigator.pop()`.

### 4. `canPop` congelado

```dart
late final bool _sujo = _nome.text.isNotEmpty;   // ❌ calculado uma vez
```

Fica `false` para sempre, porque foi avaliado quando o campo estava vazio.

**Correção:** use um **getter** e dispare `setState` a cada mudança do campo.

### 5. Transição customizada que mata o gesto do iOS

```dart
pageTransitionsTheme: const PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),   // ❌
  },
),
```

Visualmente funciona. E o usuário de iPhone perde o gesto de arrastar da borda — a forma como ele
navega.

**Correção:** `CupertinoPageTransitionsBuilder()` no iOS. Sempre.

### 6. `SystemNavigator.pop()` no iOS

```dart
SystemNavigator.pop();   // ❌ sem checar plataforma
```

A Apple rejeita o app na revisão (guia 2.5.1: o app não deve se encerrar programaticamente).

**Correção:** `if (Theme.of(context).platform == TargetPlatform.android) SystemNavigator.pop();`

### 7. `exit(0)` para fechar o app

```dart
import 'dart:io';
exit(0);   // ❌ nunca
```

Encerra o processo abruptamente: nenhum `dispose` roda, dados em memória se perdem, e a Apple
rejeita.

**Correção:** `SystemNavigator.pop()` no Android; no iOS, nada.

### 8. `Platform.isIOS` em vez de `Theme.of(context).platform`

```dart
import 'dart:io';
if (Platform.isIOS) { ... }   // ❌ quebra no Flutter Web
```

```text
Unsupported operation: Platform._operatingSystem
```

**Correção:** `Theme.of(context).platform`, que funciona em todas as plataformas — e ainda respeita
a tecla `o` do terminal, o que facilita testar.

### 9. Esquecer o atributo do manifest

O `PredictiveBackPageTransitionsBuilder` é configurado no Dart mas nada acontece no aparelho.

**Correção:** `android:enableOnBackInvokedCallback="true"` na tag `<application>`.

### 10. Confirmar saída em toda tela

```dart
// em cada uma das 15 telas do app
PopScope(canPop: false, onPopInvokedWithResult: _confirmar, child: ...)   // ❌
```

Perguntar "tem certeza?" a cada volta é hostil. Confirme **só** quando houver risco real de perda
de dados.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o app no Chrome e aperte `o` no terminal. Abra o detalhe de uma matéria nas duas
plataformas e descreva a diferença de animação.

**Passo 2.** Ainda em modo iOS, abra o formulário pelo botão "+" da lista (que usa
`fullscreenDialog: true`) e tente arrastar da borda esquerda. Depois mude a rota para
`fullscreenDialog: false` e tente de novo. Explique a diferença.

**Passo 3.** No `tema_app.dart`, troque `CupertinoPageTransitionsBuilder()` por
`ZoomPageTransitionsBuilder()` no `TargetPlatform.iOS`. Rode em modo iOS e tente o gesto de borda.
Anote o que você quebrou. Depois desfaça.

**Passo 4.** No formulário, digite algo e tente voltar. Confirme que o diálogo aparece. Escolha
"Continuar editando" e confirme que você permanece na tela.

**Passo 5.** Troque `bool get _temAlteracoes` por
`late final bool _temAlteracoes = _nome.text.isNotEmpty;`. Rode, digite algo e tente voltar.
Explique por escrito por que a proteção parou de funcionar. Depois desfaça.

**Passo 6.** Remova `_nome.addListener(_aoDigitar)` do `initState` (mantendo o getter). Digite algo
e tente voltar. O que acontece e por quê?

**Passo 7.** No `HomeScreen`, remova a checagem `if (!ehAndroid) return;`. Rode em modo iOS e
aperte voltar duas vezes na aba Hoje (use o botão voltar do navegador). Explique por que esse
código seria rejeitado na App Store.

**Passo 8.** Abra o `AndroidManifest.xml` e confirme que `enableOnBackInvokedCallback` está lá. Se
você tiver um emulador Android 14+, rode e faça o gesto de voltar devagar, sem soltar. Descreva o
que vê.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Faça os exercícios de **Aplicação** com `PopScope`, o de **Correção de bugs** com `canPop`
congelado, e o de **Decisão** sobre customizar transições.

---

## 🏆 Desafio opcional

Crie um widget reutilizável `ProtegeAlteracoes` que envolva qualquer formulário e cuide de tudo:

```dart
ProtegeAlteracoes(
  temAlteracoes: () => _temAlteracoes,
  child: Scaffold(...),
)
```

Requisitos:

- Nenhum formulário do app volta a escrever `PopScope` na mão.
- O texto do diálogo é personalizável, mas tem um padrão bom.
- Funciona tanto para o botão voltar do Android quanto para o gesto do iOS.
- Também protege quando a tela é fechada pelo `X` da `AppBar` de um `fullscreenDialog` — e essa
  parte é a pegadinha: o `X` chama `Navigator.pop()` direto, **sem passar pelo `PopScope`**.

Dica para a pegadinha: exponha um método que o botão `X` possa chamar, ou substitua o botão de
fechar padrão por um que consulte a mesma lógica.

Depois responda: quantos lugares do seu app poderiam perder dados do usuário sem esse widget? Conte
os formulários.

---

## 📌 Resumo

- O Flutter **já adapta** animação, seta de voltar e gesto de borda por plataforma. Você não
  precisa fazer nada — e precisa tomar cuidado para não **estragar**.
- O **gesto de arrastar da borda** do iOS vem do `CupertinoPageTransitionsBuilder`. Trocá-lo
  remove o gesto e faz o app parecer quebrado no iPhone.
- `fullscreenDialog: true` desliga o gesto de borda **de propósito** — use em formulários que não
  devem ser abandonados por acidente.
- **`WillPopScope` foi removido.** A API atual é `PopScope` com `canPop` (booleano **síncrono**) e
  `onPopInvokedWithResult`.
- `canPop` é síncrono porque o **predictive back** do Android 14+ precisa da resposta **antes** de
  o gesto terminar.
- `canPop` precisa ser **recalculado** a cada mudança: use getter + `setState`. Um valor congelado
  quebra a proteção em silêncio.
- No callback, `saiu == true` significa que o pop passou; só agimos quando `saiu == false`.
- Todo `canPop: false` precisa de um caminho que chame `Navigator.pop()` — senão o usuário fica
  preso.
- **`SystemNavigator.pop()`** manda o app para segundo plano no Android. **Nunca** use no iOS: a
  Apple rejeita. E **nunca** use `exit(0)`.
- Use `Theme.of(context).platform`, não `Platform.isIOS` (que quebra na web).
- Ative o *predictive back* com `PredictiveBackPageTransitionsBuilder` **e**
  `android:enableOnBackInvokedCallback="true"` no manifest.
- Confirme a saída **só** quando houver risco real de perda de dados.

---

## ☑️ Checklist de domínio

- [ ] Listo três diferenças de navegação entre Android e iOS que o Flutter resolve sozinho.
- [ ] Explico o que é o gesto de borda e cito duas coisas que o desativam.
- [ ] Sei por que `CupertinoPageTransitionsBuilder` no iOS não é opcional.
- [ ] Uso `PopScope` com `canPop` + `onPopInvokedWithResult`, sem `WillPopScope`.
- [ ] Explico por que `canPop` é síncrono, citando o predictive back.
- [ ] Mantenho `canPop` atualizado com getter + `setState` a cada mudança do formulário.
- [ ] Nunca deixo o usuário preso com `canPop: false` sem saída.
- [ ] Protejo formulários contra perda de dados com diálogo de descarte.
- [ ] Sei que `SystemNavigator.pop()` é só Android, e por quê.
- [ ] Nunca uso `exit(0)`.
- [ ] Uso `Theme.of(context).platform` em vez de `Platform.isIOS`.
- [ ] Meu `AndroidManifest.xml` tem `enableOnBackInvokedCallback`.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [PopScope class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/PopScope-class.html)
- [Predictive back gesture — docs.flutter.dev](https://docs.flutter.dev/release/breaking-changes/android-predictive-back)
- [PageTransitionsTheme — api.flutter.dev](https://api.flutter.dev/flutter/material/PageTransitionsTheme-class.html)
- [CupertinoPageRoute — api.flutter.dev](https://api.flutter.dev/flutter/cupertino/CupertinoPageRoute-class.html)
- [SystemNavigator — api.flutter.dev](https://api.flutter.dev/flutter/services/SystemNavigator-class.html)
- [Platform adaptations — docs.flutter.dev](https://docs.flutter.dev/platform-integration/platform-adaptations)
- [App Store Review Guidelines 2.5.1 — developer.apple.com](https://developer.apple.com/app-store/review/guidelines/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Abas e organização](04-abas-e-organizacao.md) | [README](README.md) | [Aula 6 — Formulários](06-formularios.md) |
