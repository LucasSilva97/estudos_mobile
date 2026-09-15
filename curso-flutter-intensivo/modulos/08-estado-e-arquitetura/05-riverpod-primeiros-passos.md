# Aula 5 — Riverpod: primeiros passos

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que o **`ProviderScope`** guarda e por que ele é obrigatório.
- Declarar um **`Provider<T>`** e entender por que ele é uma variável global **sem estado**.
- Usar **`ConsumerWidget`**, **`ConsumerStatefulWidget`** e **`Consumer`** — e escolher o certo.
- Dominar a diferença entre **`ref.watch`**, **`ref.read`** e **`ref.listen`** — a fonte de 90% dos
  erros de quem começa.
- **Combinar providers**: um provider que lê outro e se atualiza sozinho.
- Reduzir rebuilds com **`select`**.
- Reconhecer e corrigir os erros clássicos: `read` no `build`, `watch` em callback, `listen` fora
  do `build`.

## ✅ Pré-requisitos

- [Aula 3 — InheritedWidget](03-inheritedwidget.md) — o `ProviderScope` **é** um `InheritedWidget`
  por dentro. Sem isso, o resto vira mágica.
- [Aula 4 — Por que Riverpod](04-por-que-riverpod.md) — o `foco_estado` já precisa ter
  `flutter_riverpod: ^3.4.3` instalado e `ProviderScope` na raiz.
- [Módulo 05, aula 7 — BuildContext](../05-introducao-ao-flutter/07-buildcontext.md) — a busca para
  cima; `ref` faz algo parecido, mas sem `context`.
- O projeto `foco_estado` rodando.

---

## 📖 Conceito

### As três peças

O Riverpod inteiro se apoia em três coisas:

| Peça | O que é | Onde vive |
|---|---|---|
| **Provider** | Uma **receita**: como criar um valor | Variável global, no topo de um arquivo |
| **`ProviderScope`** | Onde o **estado** dos providers é guardado | Na raiz da árvore de widgets |
| **`ref`** | O **acesso**: ler, observar e reagir | Dentro de `ConsumerWidget` ou de outro provider |

A separação entre "receita" e "estado" é o que torna o provider global seguro:

```dart
// Esta linha NÃO cria nada. Ela só descreve COMO criar.
final Provider<String> saudacaoProvider = Provider<String>((Ref ref) => 'Olá');
```

O valor `'Olá'` só passa a existir quando alguém lê o provider — e ele é guardado **dentro do
`ProviderScope`**, não na variável global. Por isso dois `ProviderScope` diferentes (por exemplo,
dois testes rodando em paralelo) têm estados independentes, mesmo usando a mesma variável.

### `Provider<T>`: valor que não muda sozinho

O tipo mais simples. Serve para valores derivados, configurações e dependências.

```dart
final Provider<int> metaDiariaProvider = Provider<int>((Ref ref) => 120);

final Provider<String> versaoProvider = Provider<String>((Ref ref) => '1.0.0');
```

> ⚠️ `Provider` é **somente leitura**. Não existe `provider.state = x`. Para estado que muda em
> resposta ao usuário, você usa `NotifierProvider` — assunto da
> [aula 6](06-notifier-e-notifierprovider.md). Aqui a ideia é entender o mecanismo com a peça mais
> simples possível.

O que torna o `Provider` útil mesmo sendo imutável é a **combinação**:

```dart
final Provider<int> minutosEstudadosProvider = Provider<int>((Ref ref) => 95);
final Provider<int> metaProvider = Provider<int>((Ref ref) => 120);

// Este provider LÊ os outros dois. Quando qualquer um mudar,
// este recalcula sozinho — e quem o observa é notificado.
final Provider<double> progressoProvider = Provider<double>((Ref ref) {
  final int estudados = ref.watch(minutosEstudadosProvider);
  final int meta = ref.watch(metaProvider);
  return meta == 0 ? 0 : (estudados / meta).clamp(0.0, 1.0);
});
```

Isso é o **grafo de dependências** do Riverpod. Você declara o que depende do quê, e ele cuida da
propagação. Compare com o `InheritedWidget` da aula 3, onde você recalculava na mão.

### Os três widgets que dão acesso ao `ref`

**1. `ConsumerWidget`** — substitui `StatelessWidget`:

```dart
class MinhaTela extends ConsumerWidget {
  const MinhaTela({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {   // <- dois parâmetros
    final int meta = ref.watch(metaProvider);
    return Text('$meta');
  }
}
```

**2. `ConsumerStatefulWidget`** — substitui `StatefulWidget`, quando você também precisa de
`initState`, `dispose` ou controllers:

```dart
class MinhaTela extends ConsumerStatefulWidget {
  const MinhaTela({super.key});

  @override
  ConsumerState<MinhaTela> createState() => _MinhaTelaState();
}

class _MinhaTelaState extends ConsumerState<MinhaTela> {
  @override
  void initState() {
    super.initState();
    // `ref` está disponível AQUI. Com InheritedWidget isso seria erro.
    final int meta = ref.read(metaProvider);
  }

  @override
  Widget build(BuildContext context) {   // <- só um parâmetro; ref é campo
    final int meta = ref.watch(metaProvider);
    return Text('$meta');
  }
}
```

> 📌 Repare: no `ConsumerState`, o `ref` é um **campo da classe**, não um parâmetro do `build`. E
> ele funciona no `initState` — algo impossível com `.of(context)`.

**3. `Consumer`** — um widget que dá `ref` a um **pedaço** da árvore:

```dart
Scaffold(
  appBar: AppBar(title: const Text('Foco')),   // não reconstrói
  body: Column(
    children: <Widget>[
      const CabecalhoPesado(),                  // não reconstrói
      Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final int meta = ref.watch(metaProvider);
          return Text('$meta');                 // SÓ ISTO reconstrói
        },
      ),
    ],
  ),
)
```

Use `Consumer` quando só uma parte pequena da tela depende do estado. Sem ele, a tela inteira
reconstrói a cada mudança.

### `watch` × `read` × `listen` — a parte que todo mundo erra

Esta é a tabela mais importante da aula:

| | `ref.watch` | `ref.read` | `ref.listen` |
|---|---|---|---|
| Lê o valor | ✅ | ✅ | ❌ (recebe antigo e novo) |
| Se inscreve em mudanças | ✅ | ❌ | ✅ |
| Reconstrói o widget | ✅ | ❌ | ❌ |
| Executa código na mudança | ❌ | ❌ | ✅ |
| Onde usar | **No `build`** | **Em callbacks** (`onPressed`, `initState`) | **No `build`**, para efeitos |

**`ref.watch` — "eu dependo disto".**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final int meta = ref.watch(metaProvider);   // reconstrói quando mudar
  return Text('$meta');
}
```

**`ref.read` — "só quero o valor agora".**

```dart
onPressed: () {
  ref.read(contadorProvider.notifier).incrementar();   // não se inscreve
}
```

**`ref.listen` — "quando isto mudar, execute algo".**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Chamado quando o valor muda. NÃO reconstrói o widget.
  ref.listen<int>(sessoesProvider, (int? anterior, int atual) {
    if (atual > (anterior ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão registrada!')),
      );
    }
  });

  return const SizedBox();
}
```

`listen` existe para **efeitos colaterais**: mostrar `SnackBar`, navegar, tocar som, gravar log.
Coisas que **não** são "desenhar a tela".

### As duas regras que evitam quase todos os erros

> **Regra 1 — Nunca `ref.read` dentro do `build`.**
>
> ```dart
> Widget build(BuildContext context, WidgetRef ref) {
>   final int meta = ref.read(metaProvider);   // ❌ a tela não atualiza nunca
>   return Text('$meta');
> }
> ```
>
> O valor é lido uma vez e o widget **nunca** reconstrói. O bug é silencioso: nada quebra, a tela
> só fica desatualizada — e você passa uma hora procurando o erro na lógica.

> **Regra 2 — Nunca `ref.watch` dentro de callback.**
>
> ```dart
> onPressed: () {
>   final int meta = ref.watch(metaProvider);   // ❌
> }
> ```
>
> ```text
> Tried to use ref.watch outside of the build method
> ```
>
> `watch` cria inscrição, e inscrição só faz sentido durante a construção.

E uma terceira, menos conhecida:

> **Regra 3 — `ref.listen` só dentro do `build`** (ou de outro provider). Chamá-lo num `onPressed`
> criaria um ouvinte novo a cada toque, e nenhum deles seria removido.

### `select`: reconstruir menos

Quando o provider guarda um objeto grande e você só precisa de um campo:

```dart
// ❌ reconstrói quando QUALQUER campo do usuário mudar
final Usuario u = ref.watch(usuarioProvider);
return Text(u.nome);

// ✅ reconstrói SÓ quando o nome mudar
final String nome = ref.watch(usuarioProvider.select((Usuario u) => u.nome));
return Text(nome);
```

`select` recebe uma função que extrai a parte que interessa. O Riverpod compara **só o resultado
dessa função** para decidir se reconstrói.

> 📌 Não saia usando `select` em tudo. Ele custa uma comparação extra e polui o código. Use quando
> o objeto é grande **e** o widget é caro de reconstruir — e prefira, antes disso, providers
> menores e mais específicos.

### Escopo e ciclo de vida

Por padrão, um provider:

- é criado na **primeira leitura** (preguiçoso);
- vive **enquanto alguém o observa**;
- é **descartado** quando ninguém observa mais — se for `autoDispose`.

```dart
// Vive para sempre depois de criado.
final Provider<int> configProvider = Provider<int>((Ref ref) => 10);

// Descartado quando o último observador sai da tela.
final Provider<int> temporarioProvider =
    Provider.autoDispose<int>((Ref ref) => 10);
```

`autoDispose` é o assunto da [aula 8](08-family-autodispose-listen.md). Por ora, saiba que ele
existe e que a escolha importa.

---

## 💡 Analogia

Pense numa cozinha de restaurante.

- **O provider** é a **receita** afixada na parede. Ela não é comida — é a instrução de como fazer.
  Por isso pode ficar afixada para sempre sem estragar nada: uma receita global é inofensiva.
- **O `ProviderScope`** é a **cozinha**. É onde os pratos de verdade são preparados e ficam
  guardados. Duas cozinhas (dois testes) usam as mesmas receitas e produzem pratos independentes.
- **`ref`** é o seu **acesso à cozinha** — e a diferença crucial em relação ao `BuildContext` é que
  você não precisa estar **dentro do salão** para usá-lo. Por isso dá para testar sem montar o
  restaurante inteiro.
- **`ref.watch`** é **assinar** um prato: "sempre que sair uma fornada nova, me traga". O garçom
  volta à sua mesa toda vez — que é o widget reconstruindo.
- **`ref.read`** é pedir **uma vez**: "me traga um café agora". Ninguém volta depois. Por isso ler
  com `read` no `build` é pedir um café e achar que ele vai se renovar sozinho.
- **`ref.listen`** é pedir ao garçom: "**me avise** quando sair pão fresco — não precisa trazer".
  Você não recebe o prato; você recebe o aviso e decide o que fazer.
- **Um provider que lê outro** é a receita do molho que usa o caldo. Quando o caldo muda, o molho
  é refeito — e todo prato que leva o molho também. Você declarou a dependência uma vez; a cozinha
  cuida da cascata.
- **`select`** é dizer "só me avise se mudar **o pão**; se mudarem a salada do mesmo prato, não
  preciso saber".

---

## 🧪 Exemplo mínimo

Este programa mostra `watch`, `read` e `listen` acontecendo ao mesmo tempo, com contadores de
rebuild visíveis.

> **Arquivo:** `foco_estado/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Providers ──────────────────────────────────────────────────────────────
// São RECEITAS. Nada é criado aqui; o valor nasce na primeira leitura
// e é guardado dentro do ProviderScope.

final NotifierProvider<MinutosNotifier, int> minutosProvider =
    NotifierProvider<MinutosNotifier, int>(MinutosNotifier.new);

class MinutosNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void adicionar(int quanto) => state = state + quanto;
  void zerar() => state = 0;
}

/// Valor fixo. Serve para mostrar que um provider pode ser só configuração.
final Provider<int> metaProvider = Provider<int>((Ref ref) => 120);

/// Provider DERIVADO: lê os outros dois e se recalcula sozinho.
/// Quando `minutosProvider` muda, este muda — e quem observa este é avisado.
final Provider<double> progressoProvider = Provider<double>((Ref ref) {
  final int minutos = ref.watch(minutosProvider);
  final int meta = ref.watch(metaProvider);
  return meta == 0 ? 0 : (minutos / meta).clamp(0.0, 1.0);
});

/// Outro derivado, para mostrar que a cascata continua.
final Provider<bool> metaAtingidaProvider = Provider<bool>((Ref ref) {
  return ref.watch(progressoProvider) >= 1.0;
});

// ── App ────────────────────────────────────────────────────────────────────

void main() => runApp(const ProviderScope(child: AppRiverpod()));

class AppRiverpod extends StatelessWidget {
  const AppRiverpod({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaDemo(),
    );
  }
}

class TelaDemo extends ConsumerWidget {
  const TelaDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // listen: reage à mudança SEM reconstruir este widget.
    // Precisa estar no build — nunca em um callback.
    ref.listen<bool>(metaAtingidaProvider, (bool? antes, bool agora) {
      if (agora && !(antes ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Meta do dia atingida!')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('watch × read × listen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Zerar',
            // read: só quero chamar o método, não me inscrever.
            onPressed: () => ref.read(minutosProvider.notifier).zerar(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          _PainelComWatch(),
          SizedBox(height: 12),
          _PainelComRead(),
          SizedBox(height: 12),
          _PainelIsolado(),
          SizedBox(height: 12),
          _PainelSoMeta(),
          SizedBox(height: 24),
          _Botoes(),
        ],
      ),
    );
  }
}

/// ✅ watch no build: reconstrói quando o valor muda.
class _PainelComWatch extends ConsumerStatefulWidget {
  const _PainelComWatch();

  @override
  ConsumerState<_PainelComWatch> createState() => _PainelComWatchState();
}

class _PainelComWatchState extends ConsumerState<_PainelComWatch> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    _rebuilds++;
    final int minutos = ref.watch(minutosProvider);
    final double progresso = ref.watch(progressoProvider);

    return Card(
      color: Colors.green.withValues(alpha: 0.12),
      child: ListTile(
        title: Text('✅ watch: $minutos min'),
        subtitle: Text(
          'progresso ${(progresso * 100).round()}% · '
          'rebuilds: $_rebuilds',
        ),
      ),
    );
  }
}

/// ❌ read no build: lê UMA vez e nunca mais atualiza.
class _PainelComRead extends ConsumerStatefulWidget {
  const _PainelComRead();

  @override
  ConsumerState<_PainelComRead> createState() => _PainelComReadState();
}

class _PainelComReadState extends ConsumerState<_PainelComRead> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    _rebuilds++;
    // ❌ ERRO DE PROPÓSITO: read no build não cria inscrição.
    // Este número congela no valor do primeiro build.
    final int minutos = ref.read(minutosProvider);

    return Card(
      color: Colors.red.withValues(alpha: 0.12),
      child: ListTile(
        title: Text('❌ read: $minutos min'),
        subtitle: Text('rebuilds: $_rebuilds — congelado de propósito'),
      ),
    );
  }
}

/// Consumer isolando o pedaço que reconstrói.
class _PainelIsolado extends StatelessWidget {
  const _PainelIsolado();

  @override
  Widget build(BuildContext context) {
    debugPrint('_PainelIsolado (fora do Consumer) construiu');

    return Card(
      child: Column(
        children: <Widget>[
          const ListTile(
            title: Text('Este título NÃO reconstrói'),
            subtitle: Text('Veja o console: ele aparece uma vez só'),
          ),
          // Só o que está aqui dentro reconstrói.
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final double p = ref.watch(progressoProvider);
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: LinearProgressIndicator(value: p),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// select: só reconstrói quando a PARTE observada muda.
class _PainelSoMeta extends ConsumerStatefulWidget {
  const _PainelSoMeta();

  @override
  ConsumerState<_PainelSoMeta> createState() => _PainelSoMetaState();
}

class _PainelSoMetaState extends ConsumerState<_PainelSoMeta> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    _rebuilds++;
    // Só observa "passou de 60?". Minutos indo de 10 para 20 NÃO reconstrói.
    final bool passouDe60 =
        ref.watch(minutosProvider.select((int m) => m > 60));

    return Card(
      color: Colors.blue.withValues(alpha: 0.12),
      child: ListTile(
        title: Text(passouDe60 ? 'Mais de 60 min' : 'Menos de 60 min'),
        subtitle: Text('select · rebuilds: $_rebuilds'),
      ),
    );
  }
}

class _Botoes extends ConsumerWidget {
  const _Botoes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (final int q in <int>[15, 25, 50])
          FilledButton(
            // read em callback: correto. Não queremos inscrição aqui.
            onPressed: () => ref.read(minutosProvider.notifier).adicionar(q),
            child: Text('+$q'),
          ),
      ],
    );
  }
}
```

**O roteiro que ensina a aula inteira:**

1. Toque em `+15` quatro vezes, devagar, observando cada cartão:
   - O **verde** (`watch`) atualiza sempre.
   - O **vermelho** (`read`) fica congelado em `0`.
   - O **azul** (`select`) só muda quando passa de 60 — e o contador de rebuilds dele fica bem
     menor que o do verde.
2. Olhe o **console**: `_PainelIsolado (fora do Consumer) construiu` aparece **uma vez só**, apesar
   de a barra de progresso dentro dele atualizar sempre.
3. Continue até passar de 120 minutos: o `SnackBar` do `ref.listen` aparece — **uma vez**, no
   momento em que a meta é atingida.
4. Aperte o botão de zerar e passe de 120 de novo: o `SnackBar` volta. O `listen` compara antes e
   depois.

---

## 📱 Aplicando no Flutter

Agora o `foco_estado` troca o `InheritedWidget` da aula 3 por providers. O `escopo_foco.dart`
continua no projeto para comparação, mas deixa de ser usado.

Você vai criar `lib/estado/providers_basicos.dart` com:

- o estado das sessões de estudo;
- a meta diária (configuração);
- providers **derivados**: progresso, minutos restantes, meta atingida;
- um `ref.listen` que comemora a meta.

---

## 💻 Código completo

> **Arquivo:** `foco_estado/lib/estado/providers_basicos.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// ESTADO BASE
/// ─────────────────────────────────────────────────────────────────────────

/// Minutos estudados hoje.
///
/// O provider é uma variável GLOBAL, e isso é seguro: ele não guarda valor
/// nenhum. Ele é a receita. O valor vive dentro do ProviderScope.
final NotifierProvider<MinutosHojeNotifier, int> minutosHojeProvider =
    NotifierProvider<MinutosHojeNotifier, int>(MinutosHojeNotifier.new);

class MinutosHojeNotifier extends Notifier<int> {
  /// Chamado UMA vez, na primeira leitura do provider.
  /// Devolve o estado inicial.
  @override
  int build() => 0;

  /// Estado é imutável: você ATRIBUI um valor novo.
  /// `state++` funcionaria para int, mas o hábito da atribuição
  /// é o que salva quando o estado vira uma lista ou um objeto.
  void registrarSessao(int minutos) => state = state + minutos;

  void zerarDia() => state = 0;
}

/// Quantidade de sessões concluídas hoje.
final NotifierProvider<SessoesHojeNotifier, int> sessoesHojeProvider =
    NotifierProvider<SessoesHojeNotifier, int>(SessoesHojeNotifier.new);

class SessoesHojeNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void concluir() => state = state + 1;
  void zerar() => state = 0;
}

/// Meta diária em minutos. Configuração — muda pouco, mas pode mudar.
final NotifierProvider<MetaDiariaNotifier, int> metaDiariaProvider =
    NotifierProvider<MetaDiariaNotifier, int>(MetaDiariaNotifier.new);

class MetaDiariaNotifier extends Notifier<int> {
  @override
  int build() => 120;

  void definir(int minutos) {
    // Guarda de domínio: a meta nunca pode ser inválida.
    if (minutos < 5 || minutos > 480) return;
    state = minutos;
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// PROVIDERS DERIVADOS
///
/// Aqui está a vantagem central sobre o InheritedWidget da aula 3:
/// estes valores se recalculam SOZINHOS quando suas dependências mudam.
/// Você declara a dependência uma vez; o Riverpod cuida da cascata.
/// ─────────────────────────────────────────────────────────────────────────

/// Progresso entre 0.0 e 1.0.
final Provider<double> progressoDiarioProvider = Provider<double>((Ref ref) {
  final int minutos = ref.watch(minutosHojeProvider);
  final int meta = ref.watch(metaDiariaProvider);
  return meta == 0 ? 0 : (minutos / meta).clamp(0.0, 1.0);
});

/// Quantos minutos ainda faltam. Nunca negativo.
final Provider<int> minutosRestantesProvider = Provider<int>((Ref ref) {
  final int minutos = ref.watch(minutosHojeProvider);
  final int meta = ref.watch(metaDiariaProvider);
  final int falta = meta - minutos;
  return falta < 0 ? 0 : falta;
});

/// A meta foi batida? Depende do progresso, que depende dos outros dois.
/// A cascata tem três níveis e você não escreveu nenhuma linha de propagação.
final Provider<bool> metaAtingidaProvider = Provider<bool>((Ref ref) {
  return ref.watch(progressoDiarioProvider) >= 1.0;
});

/// Média de minutos por sessão. Texto pronto para a tela.
final Provider<String> mediaPorSessaoProvider = Provider<String>((Ref ref) {
  final int minutos = ref.watch(minutosHojeProvider);
  final int sessoes = ref.watch(sessoesHojeProvider);
  if (sessoes == 0) return '—';
  return '${(minutos / sessoes).round()} min';
});
```

> **Arquivo:** `foco_estado/lib/telas/home_screen.dart` (substitui a versão da aula 3)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/estado/providers_basicos.dart';

/// Tela principal.
///
/// Compare com a versão da aula 3: aqui não há EscopoFoco, não há
/// `of(context)`, não há callback descendo por parâmetro. Cada widget
/// pega o que precisa, de onde estiver.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // listen: EFEITO COLATERAL quando a meta é atingida.
    // Não reconstrói este widget; só executa o código.
    // Precisa estar no build — nunca dentro de um onPressed.
    ref.listen<bool>(metaAtingidaProvider, (bool? antes, bool agora) {
      // A comparação com o valor anterior evita repetir a mensagem
      // a cada sessão registrada depois da meta.
      if (agora && !(antes ?? false)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('🎉 Meta do dia atingida!'),
              duration: Duration(seconds: 3),
            ),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foco — Hoje'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Zerar o dia',
            // read em callback: correto. Não queremos inscrição aqui.
            onPressed: () {
              ref.read(minutosHojeProvider.notifier).zerarDia();
              ref.read(sessoesHojeProvider.notifier).zerar();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          _CartaoProgresso(),
          SizedBox(height: 16),
          _CartaoNumeros(),
          SizedBox(height: 16),
          _SeletorDeMeta(),
          SizedBox(height: 24),
          _BotoesDeSessao(),
        ],
      ),
    );
  }
}

/// Observa só o progresso — não sabe nada de minutos nem de meta.
class _CartaoProgresso extends ConsumerWidget {
  const _CartaoProgresso();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double progresso = ref.watch(progressoDiarioProvider);
    final int faltam = ref.watch(minutosRestantesProvider);
    final bool atingida = ref.watch(metaAtingidaProvider);
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              atingida ? 'Meta cumprida' : 'Faltam $faltam min',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progresso,
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
              color: atingida ? cores.tertiary : cores.primary,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progresso * 100).round()}% do dia',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Três números, cada um vindo de um provider diferente.
class _CartaoNumeros extends ConsumerWidget {
  const _CartaoNumeros();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int minutos = ref.watch(minutosHojeProvider);
    final int sessoes = ref.watch(sessoesHojeProvider);
    final String media = ref.watch(mediaPorSessaoProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _Numero(rotulo: 'minutos', valor: '$minutos'),
            _Numero(rotulo: 'sessões', valor: '$sessoes'),
            _Numero(rotulo: 'média', valor: media),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(valor, style: Theme.of(context).textTheme.headlineSmall),
        Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Usa select: só reconstrói quando a META muda — não quando os
/// minutos mudam, apesar de os dois virem da mesma família de estado.
class _SeletorDeMeta extends ConsumerWidget {
  const _SeletorDeMeta();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int meta = ref.watch(metaDiariaProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Meta diária: $meta min',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 60, label: Text('60')),
                ButtonSegment<int>(value: 120, label: Text('120')),
                ButtonSegment<int>(value: 180, label: Text('180')),
              ],
              selected: <int>{meta},
              onSelectionChanged: (Set<int> s) =>
                  ref.read(metaDiariaProvider.notifier).definir(s.first),
            ),
          ],
        ),
      ),
    );
  }
}

/// Registra sessões. Note que ele NÃO observa nada — só dispara ações.
/// Por isso nunca reconstrói.
class _BotoesDeSessao extends ConsumerWidget {
  const _BotoesDeSessao();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('_BotoesDeSessao construiu');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (final int minutos in <int>[15, 25, 50])
          FilledButton(
            onPressed: () {
              // Dois providers atualizados no mesmo callback.
              // Com InheritedWidget, isto exigiria dois callbacks
              // descendo por parâmetro desde o topo da árvore.
              ref.read(minutosHojeProvider.notifier).registrarSessao(minutos);
              ref.read(sessoesHojeProvider.notifier).concluir();
            },
            child: Text('+$minutos min'),
          ),
      ],
    );
  }
}
```

Rode e confirme:

```powershell
flutter analyze
flutter run -d chrome
```

1. Toque em `+25` várias vezes: **quatro** widgets atualizam, sem nenhum parâmetro passado.
2. Olhe o console: `_BotoesDeSessao construiu` aparece **uma vez** — ele não observa nada.
3. Chegue a 120 minutos: o `SnackBar` da meta aparece **uma vez**.
4. Continue registrando sessões: o `SnackBar` **não** repete.
5. Mude a meta para 180: o progresso recalcula sozinho, e a meta "desatinge".

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `final NotifierProvider<...> xProvider = ...` global | Provider é **receita**, não estado. Por isso a variável global é segura — o valor vive no `ProviderScope`. |
| `class MinutosHojeNotifier extends Notifier<int>` | A classe com a lógica. `build()` devolve o estado inicial. Detalhes na [aula 6](06-notifier-e-notifierprovider.md). |
| `state = state + minutos` | **Atribuição**, não mutação. O Riverpod compara antigo e novo para decidir se notifica. |
| `if (minutos < 5 \|\| minutos > 480) return;` | Guarda de domínio **dentro** do notifier. A regra fica com o estado, não espalhada pelas telas. |
| `Provider<double> progressoDiarioProvider` lendo dois providers | Provider **derivado**: recalcula sozinho quando qualquer dependência muda. |
| `metaAtingidaProvider` lendo `progressoDiarioProvider` | Cascata de **três** níveis, com zero linhas de propagação escritas por você. |
| `ref.listen<bool>(metaAtingidaProvider, (antes, agora) {...})` | Efeito colateral. Não reconstrói o widget. **Precisa** estar no `build`. |
| `if (agora && !(antes ?? false))` | Só age na **transição** false→true. Sem isso, a mensagem repetiria a cada sessão depois da meta. |
| `ref.read(...notifier).registrarSessao(...)` em `onPressed` | `read` em callback é o uso **correto**: não queremos inscrição ali. |
| `..hideCurrentSnackBar()` antes de `..showSnackBar(...)` | Cascata do Dart; evita fila de mensagens. |
| `_BotoesDeSessao` sem nenhum `watch` | Não observa nada → **nunca** reconstrói. O `debugPrint` prova isso. |
| `_CartaoProgresso` observando três providers derivados | Ele não sabe o que são minutos nem meta. Depende só do que usa — e isso é desacoplamento real. |
| `const <Widget>[...]` na lista do `ListView` | Os filhos são `const`: o Flutter os reaproveita e não os reconstrói junto com a tela. |

---

## ⚠️ Erros comuns

### 1. `ref.read` dentro do `build`

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final int minutos = ref.read(minutosHojeProvider);   // ❌
  return Text('$minutos');
}
```

A tela **nunca** atualiza. E o pior: **não dá erro**. Você procura o bug na lógica por uma hora.

**Correção:** `ref.watch`.

### 2. `ref.watch` dentro de um callback

```dart
onPressed: () {
  final int m = ref.watch(minutosHojeProvider);   // ❌
}
```

```text
Tried to use ref.watch outside of the build method
```

**Correção:** `ref.read`.

### 3. `ref.listen` dentro de um callback

```dart
onPressed: () {
  ref.listen<int>(minutosHojeProvider, (int? a, int b) { ... });   // ❌
}
```

Cria um ouvinte novo a cada toque, e nenhum é removido.

**Correção:** `listen` só no `build` (ou dentro de outro provider).

### 4. Esquecer o `ProviderScope`

```text
No ProviderScope found.
Perhaps you forgot to wrap your app in a ProviderScope?
```

**Correção:** `runApp(const ProviderScope(child: MeuApp()))`.

### 5. `StatelessWidget` em vez de `ConsumerWidget`

```text
Undefined name 'ref'.
```

**Correção:** troque a superclasse por `ConsumerWidget` e acrescente `WidgetRef ref` ao `build`.

### 6. Mutar o estado em vez de atribuir

```dart
void adicionar(Materia m) {
  state.add(m);            // ❌ a lista muda, mas a REFERÊNCIA é a mesma
}
```

O Riverpod compara a referência antiga com a nova. Sendo a mesma, ele conclui que nada mudou e
**não notifica ninguém**. A tela não atualiza.

**Correção:**

```dart
void adicionar(Materia m) {
  state = <Materia>[...state, m];   // ✅ lista nova
}
```

### 7. Provider que depende de outro usando `read`

```dart
final Provider<double> progressoProvider = Provider<double>((Ref ref) {
  final int m = ref.read(minutosProvider);   // ❌ não recalcula nunca
  return m / 120;
});
```

**Correção:** dentro de um provider, dependência é sempre `ref.watch`.

### 8. Colocar estado de widget num provider

```dart
final Provider<bool> expandidoProvider = ...   // ⚠️ um ExpansionTile aberto
```

**Correção:** `setState`. Revisão da [aula 4](04-por-que-riverpod.md).

### 9. `select` retornando objeto novo a cada chamada

```dart
ref.watch(usuarioProvider.select((Usuario u) => <String>[u.nome]));   // ❌
```

Uma lista nova a cada comparação nunca é igual à anterior → reconstrói **sempre**.

**Correção:** `select` deve devolver um valor comparável (`String`, `int`, `bool`) ou um objeto com
`==` implementado.

### 10. Ler `ref` no `initState` de um `StatefulWidget` comum

```dart
class _MinhaTelaState extends State<MinhaTela> {   // ❌ State, não ConsumerState
  @override
  void initState() {
    super.initState();
    ref.read(...);   // 'ref' não existe aqui
  }
}
```

**Correção:** `ConsumerStatefulWidget` + `ConsumerState`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e toque em `+15` quatro vezes. Anote os três comportamentos:
verde, vermelho e azul.

**Passo 2.** No `_PainelComRead`, troque `ref.read` por `ref.watch`. Rode de novo e confirme que o
cartão vermelho passa a funcionar.

**Passo 3.** No `_PainelSoMeta`, remova o `.select(...)` (use `ref.watch(minutosProvider)` direto).
Toque em `+15` cinco vezes e compare o contador de rebuilds com o de antes.

**Passo 4.** No `foco_estado`, mude a meta de 120 para 60 depois de já ter estudado 80 minutos.
O que acontece com o progresso e com o `SnackBar`? Explique a cascata em uma frase.

**Passo 5.** Em `_BotoesDeSessao`, acrescente `final int m = ref.watch(minutosHojeProvider);` no
início do `build` (sem usar a variável). Toque nos botões e olhe o console. O que mudou?

**Passo 6.** Tente chamar `ref.watch(minutosHojeProvider)` dentro do `onPressed`. Leia o erro
inteiro e copie a primeira linha.

**Passo 7.** Em `MinutosHojeNotifier`, troque `state = state + minutos` por um campo mutável
interno que você altera sem atribuir a `state`. Rode e observe a tela não atualizar. Explique por
quê.

**Passo 8.** Remova a condição `if (agora && !(antes ?? false))` do `ref.listen`. Chegue à meta e
continue registrando sessões. Descreva o incômodo. Depois restaure.

**Passo 9.** Crie um provider derivado novo, `ritmoProvider`, que devolve `'acelerado'`,
`'constante'` ou `'devagar'` conforme a média por sessão. Use-o em algum cartão. Quantos lugares
você precisou tocar?

**Passo 10.** Abra o `escopo_foco.dart` da aula 3 ao lado de `providers_basicos.dart`. Conte as
linhas de cada um e liste três coisas que o segundo faz e o primeiro não.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

Faça os exercícios de **Aplicação** com providers derivados, o de **Correção de bugs** com `read`
no `build`, e o de **Compreensão** sobre `watch` × `read` × `listen`.

---

## 🏆 Desafio opcional

Monte um **painel de diagnóstico** que mostre, em tempo real, quantas vezes cada widget da tela
reconstruiu — sem usar `setState` em nenhum deles.

Requisitos:

- Um provider `rebuildsProvider` guarda um `Map<String, int>`.
- Cada widget observado registra o próprio rebuild ao construir.
- O painel mostra a tabela ordenada do maior para o menor.
- **A pegadinha:** o painel não pode entrar em laço infinito — ele reconstrói ao mostrar os números,
  o que registraria um rebuild, que o faria reconstruir…

Dica: o registro não pode acontecer durante o `build` que o Riverpod está processando. Procure por
`WidgetsBinding.instance.addPostFrameCallback` e pense em qual widget deve ficar **de fora** da
contagem.

Depois use o painel para responder: na sua tela, qual widget reconstrói mais? Ele precisa mesmo
observar tudo o que observa?

---

## 📌 Resumo

- **Provider é receita, não estado.** Por isso a variável global é segura: o valor vive no
  `ProviderScope`.
- **`ProviderScope`** na raiz é obrigatório. Ele é um `InheritedWidget` por dentro — o mesmo
  mecanismo da aula 3.
- **`ConsumerWidget`** substitui `StatelessWidget`; **`ConsumerStatefulWidget`** substitui
  `StatefulWidget`; **`Consumer`** isola um pedaço da árvore para reconstruir menos.
- No `ConsumerState`, `ref` é **campo da classe** — e funciona no `initState`.
- **`ref.watch`** lê e se inscreve → use **no `build`**.
- **`ref.read`** lê sem se inscrever → use **em callbacks**.
- **`ref.listen`** executa código na mudança sem reconstruir → use **no `build`**, para efeitos
  colaterais (`SnackBar`, navegação, log).
- `read` no `build` congela a tela **sem dar erro** — o bug mais difícil de achar do Riverpod.
- `watch` em callback dá erro em tempo de execução.
- **Providers derivados** (um que lê outros com `watch`) recalculam sozinhos. A cascata é
  automática; você declara a dependência uma vez.
- Dentro de um provider, dependência é **sempre `watch`**, nunca `read`.
- **Estado é imutável:** `state = novoValor`. Mutar no lugar (`state.add(x)`) não notifica ninguém.
- **`select`** reduz rebuilds observando só uma parte — mas deve devolver um valor comparável.
- No `ref.listen`, compare com o valor anterior para agir só na **transição**.

---

## ☑️ Checklist de domínio

- [ ] Explico por que um provider global não guarda estado.
- [ ] Digo o que o `ProviderScope` guarda e qual erro aparece sem ele.
- [ ] Escolho entre `ConsumerWidget`, `ConsumerStatefulWidget` e `Consumer`.
- [ ] Uso `ref.watch` no `build` e `ref.read` em callbacks, sem pensar.
- [ ] Sei o que acontece — e o que **não** acontece — ao usar `read` no `build`.
- [ ] Uso `ref.listen` para efeitos colaterais e sei por que ele fica no `build`.
- [ ] Comparo com o valor anterior dentro do `listen` para agir só na transição.
- [ ] Crio providers derivados e explico a cascata automática.
- [ ] Uso `watch` (nunca `read`) dentro de um provider.
- [ ] Atribuo a `state` em vez de mutar, e sei por que isso importa.
- [ ] Uso `select` quando faz sentido e sei quando ele não ajuda.
- [ ] Meu app não passa nenhum callback de estado por parâmetro entre telas.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Getting started — riverpod.dev](https://riverpod.dev/docs/introduction/getting_started)
- [Reading a provider — riverpod.dev](https://riverpod.dev/docs/concepts/reading)
- [Combining providers — riverpod.dev](https://riverpod.dev/docs/concepts/combining_providers)
- [Performing side effects — riverpod.dev](https://riverpod.dev/docs/essentials/side_effects)
- [Optimizing performance with select — riverpod.dev](https://riverpod.dev/docs/advanced/select)
- [ProviderScope — pub.dev](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ProviderScope-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Por que Riverpod](04-por-que-riverpod.md) | [README](README.md) | [Aula 6 — Notifier e NotifierProvider](06-notifier-e-notifierprovider.md) |
