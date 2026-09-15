# Aula 3 — DevTools

> **Módulo:** 12 - Testes e Debug · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Abrir o **DevTools** de três formas e saber qual usar em cada situação.
- Inspecionar a **árvore de widgets** e descobrir por que um widget está onde está.
- Usar o **Layout Explorer** para diagnosticar `Row`, `Column` e `Expanded` quebrados.
- Ler a aba **Performance** e identificar um quadro que estourou o orçamento de 16 ms.
- Encontrar um **vazamento de memória** com a aba Memory.
- Inspecionar requisições HTTP na aba **Network**.
- Ativar os **debug flags** (`debugPaintSizeEnabled` e companhia) sem editar código.
- Saber o que o DevTools **não** resolve.

## ✅ Pré-requisitos

- [Aula 1 — Lendo stack traces](01-lendo-stack-traces.md) — o DevTools ajuda **depois** que você
  sabe ler o erro.
- [Aula 2 — Logs e breakpoints](02-logs-e-breakpoints.md) — a aba Logging é a continuação natural.
- [Módulo 06, aula 4 — Row, Column e Expanded](../06-widgets-e-layouts/04-row-column-expanded.md) e
  [aula 6 — Constraints](../06-widgets-e-layouts/06-constraints.md) — o Layout Explorer só faz
  sentido depois deles.
- O projeto `foco_lab` rodando com `flutter run`.

---

## 📖 Conceito

### O que é o DevTools

O **Flutter DevTools** é um conjunto de ferramentas de diagnóstico que roda no navegador e se
conecta ao app em execução. Ele mostra coisas que o código não mostra:

| Aba | Responde |
|---|---|
| **Flutter Inspector** | "Por que este widget está aqui? Qual o tamanho dele?" |
| **Performance** | "Por que a animação está travando?" |
| **CPU Profiler** | "Qual função está consumindo o processador?" |
| **Memory** | "Por que o app está usando 400 MB?" |
| **Network** | "Qual requisição demorou 8 segundos?" |
| **Logging** | "O que o app imprimiu, com filtro e carimbo de tempo?" |
| **App Size** | "Por que o APK tem 60 MB?" |

> ⚠️ **O DevTools só funciona em modo debug ou profile.** Em release não há como conectá-lo — e é
> por isso que medir desempenho exige o modo **profile**, não o release nem o debug.

### Como abrir

Três caminhos, para situações diferentes:

**1. Pelo terminal** — o mais rápido:

```powershell
flutter run
# … depois que o app abrir, aperte:
v
```

A tecla `v` abre o DevTools no navegador, já conectado.

**2. Pelo VS Code:**

`Ctrl` + `Shift` + `P` → *Flutter: Open DevTools* → escolha a aba.

Ou os atalhos diretos na barra de status enquanto o app roda.

**3. Avulso**, conectando a um app já em execução:

```powershell
dart devtools
```

E cole a URL do serviço de VM que o `flutter run` imprimiu:

```text
A Dart VM Service on sdk gphone64 x86 64 is available at:
http://127.0.0.1:52847/AbCdEf=/
```

> 📌 **Use o caminho 3 quando o app roda em um aparelho físico** e você quer o DevTools em outra
> máquina — ou quando o app foi iniciado pelo Android Studio e você prefere o navegador.

### Flutter Inspector: a árvore de verdade

O Inspector mostra a **árvore de widgets** em execução — não o seu código, mas o que o Flutter
realmente construiu.

O botão mais útil é o **Select Widget Mode** (o alvo no canto): ative, toque em qualquer coisa no
app, e o Inspector pula direto para aquele widget na árvore.

O que a árvore revela e o código esconde:

| Descoberta | Por que importa |
|---|---|
| Widgets que você não escreveu | `Scaffold` cria dezenas; entender ajuda a ler erros |
| Onde o `MediaQuery`, o `Theme` e o `Navigator` moram | A busca para cima do `.of(context)` |
| Qual widget tem qual tamanho | O número real, não o que você imaginou |
| Quantas camadas existem entre dois widgets | Explica por que um `Expanded` não funcionou |

E há dois painéis ao lado:

- **Widget Details Tree** — as propriedades daquele widget, incluindo `renderObject` com o
  tamanho e a posição reais.
- **Layout Explorer** — a próxima seção.

> 💡 **O primeiro uso que todo mundo faz:** clicar num texto que está no lugar errado e descobrir
> que há um `Padding` de 40 px que ninguém lembrava de ter escrito.

### Layout Explorer: onde o `Expanded` quebrou

Esta é, de longe, a ferramenta mais útil do DevTools para quem está aprendendo layout.

Selecione uma `Row` ou `Column` e o Layout Explorer desenha:

- o **espaço total** disponível;
- quanto cada filho **pediu** e quanto **recebeu**;
- o valor de `flex` de cada `Expanded`/`Flexible`;
- o `mainAxisAlignment` e o `crossAxisAlignment` ativos, clicáveis para experimentar;
- o **excesso**, quando há *overflow*, com o número de pixels.

O que ele resolve na prática:

| Sintoma | O que o Layout Explorer mostra |
|---|---|
| "A RenderFlex overflowed by 42 pixels" | **Qual** filho estourou, e quanto ele pediu |
| "O `Expanded` não expandiu" | O pai não tinha espaço definido |
| "Os dois `Expanded` ficaram de tamanhos diferentes" | Os valores de `flex` |
| "O texto está espremido" | Um `Flexible` com `fit: FlexFit.loose` |

> 📌 **O truque que economiza mais tempo:** você pode **mudar o `mainAxisAlignment` direto no
> Layout Explorer** e ver o resultado no app imediatamente — sem editar o código, sem hot reload.
> Quando acertar, copie para o código.

### Performance: o orçamento de 16 ms

Para uma animação fluida a 60 quadros por segundo, cada quadro tem **16,67 ms** para ser
construído e desenhado. A 120 Hz, **8,3 ms**.

A aba Performance mostra uma barra por quadro:

| Cor | Significa |
|---|---|
| **Azul** | UI thread — construir os widgets (o seu código Dart) |
| **Roxo/verde** | Raster thread — desenhar na tela (a engine) |
| **Vermelho** | O quadro **estourou** o orçamento |

Como interpretar:

| Barra alta em… | Causa provável | Onde procurar |
|---|---|---|
| **UI (azul)** | `build` pesado, rebuild demais, cálculo no `build` | [Módulo 13, aula 1](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md) |
| **Raster (roxo)** | Sombras, `Opacity`, `ClipRRect`, blur, imagens grandes | [Módulo 13, aula 2](../13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md) |
| **Ambas** | Lista sem `builder`, imagem sem `cacheWidth` | Idem |

> ⚠️ **Meça no modo profile, nunca no debug.** O modo debug tem verificações extras que deixam o
> app 2 a 10 vezes mais lento. Uma animação que "trava" em debug costuma estar perfeita em
> profile — e você perde horas otimizando o que não era problema.
>
> ```powershell
> flutter run --profile
> ```

E duas opções da aba Performance que ajudam muito:

- **Track widget builds** — mostra **quais** widgets foram reconstruídos em cada quadro.
- **Enhance tracing → Track layouts/paints** — detalha onde o tempo foi gasto.

### Memory: encontrando vazamentos

A aba Memory mostra o uso ao longo do tempo. O padrão saudável é uma **serra**: sobe, o coletor de
lixo roda, desce.

O padrão de vazamento é uma **escada**: sobe, desce um pouco, sobe mais, desce um pouco — e nunca
volta ao patamar inicial.

Como investigar:

1. Chegue a um estado estável do app.
2. Clique em **GC** (forçar coleta) e anote o valor.
3. Faça a ação suspeita **20 vezes** (abrir e fechar uma tela, por exemplo).
4. Clique em **GC** de novo e compare.

Se o número não voltou ao patamar, há vazamento.

Para achar o culpado, use **Diff Snapshots**:

1. Tire um *snapshot* antes.
2. Faça a ação 20 vezes.
3. Tire outro *snapshot*.
4. Compare: as classes com 20 instâncias a mais são as vazadas.

As causas mais comuns, todas já vistas no curso:

| Causa | Onde foi tratada |
|---|---|
| `TextEditingController` sem `dispose` | [Módulo 05, aula 6](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) |
| `Timer` sem `cancel` | Idem |
| `StreamSubscription` sem `cancel` | [Módulo 11, aula 5](../11-recursos-nativos/05-conectividade.md) |
| `AnimationController` sem `dispose` | [Módulo 06, aula 12](../06-widgets-e-layouts/12-estados-de-ui.md) |
| `family` sem `autoDispose` | [Módulo 08, aula 8](../08-estado-e-arquitetura/08-family-autodispose-listen.md) |
| Guardar `BuildContext` em campo | [Módulo 05, aula 7](../05-introducao-ao-flutter/07-buildcontext.md) |

### Network: a requisição lenta

A aba Network lista todas as requisições HTTP feitas pelo `dart:io` e pelo pacote `http`, com:

- método, URL e status;
- **duração** de cada uma;
- tamanho da resposta;
- cabeçalhos enviados e recebidos;
- o corpo, formatado.

Três usos concretos:

| Situação | O que procurar |
|---|---|
| "A tela demora a carregar" | A requisição de maior duração |
| "O app faz requisições demais" | Chamadas repetidas para a mesma URL |
| "O servidor recusou" | Os cabeçalhos enviados — falta `Content-Type`? |

> ⚠️ **A aba Network não captura tudo.** Requisições feitas em um `Isolate` separado ou por código
> nativo (um SDK de terceiros, por exemplo) não aparecem. E o corpo de respostas muito grandes é
> truncado.

### Debug flags sem editar código

O Inspector tem botões que ligam os *debug flags* em tempo de execução:

| Botão | Flag | O que mostra |
|---|---|---|
| **Show Guidelines** | `debugPaintSizeEnabled` | Caixa de cada widget, com padding e alinhamento |
| **Show Baselines** | `debugPaintBaselinesEnabled` | Linha de base do texto |
| **Highlight Repaints** | `debugRepaintRainbowEnabled` | Borda colorida que **muda de cor a cada repintura** |
| **Highlight Oversized Images** | `debugInvertOversizedImages` | Inverte imagens maiores que o necessário |
| **Slow Animations** | `timeDilation = 5.0` | Animações em câmera lenta |

Os dois mais úteis:

**Show Guidelines** — o equivalente à tecla `p` do terminal. Quando o layout está estranho e você
não sabe por quê, ligue: as bordas de cada widget aparecem, e o problema costuma ficar óbvio.

**Highlight Repaints** — a borda muda de cor **sempre que aquela região é repintada**. Uma área que
pisca constantemente está sendo repintada sem necessidade — geralmente por falta de `const` ou de
`RepaintBoundary`.

> 📌 **Highlight Oversized Images** é o que encontra o problema de memória mais comum em apps com
> muitas fotos: uma imagem de 4000 × 3000 sendo exibida num espaço de 100 × 100. Ela ocupa
> **48 MB** de memória para desenhar 30 KB de pixels. A correção é `cacheWidth`
> ([Módulo 06, aula 8](../06-widgets-e-layouts/08-imagens-e-assets.md)).

### O que o DevTools **não** resolve

Ser honesto aqui evita frustração:

| Não resolve | Use |
|---|---|
| Bug de lógica | Breakpoints (aula 2) e **testes** (aulas 5 a 7) |
| Crash em release | Relatório de erro (Módulo 16) |
| Problema só em um aparelho específico | `adb logcat` / Xcode (aula 9) |
| Erro de build | A mensagem do Gradle/Xcode (aula 9) |
| Bug que não se reproduz | Log estruturado (aula 2) |

> 💡 **A regra:** o DevTools responde "**o que** está acontecendo agora". Para "**por que** acontece"
> você precisa de breakpoint; para "**não acontecer de novo**", de teste.

---

## 💡 Analogia

Pense num carro que está fazendo um barulho estranho.

- **O stack trace** (aula 1) é a **luz no painel**: diz que algo está errado e, às vezes, o quê.
- **O `debugPrint`** (aula 2) é você **anotar num papel** a cada trecho: "no quilômetro 10 estava
  ok, no 20 já fazia barulho".
- **O breakpoint** é **parar o carro** e olhar o motor com ele desligado.
- **O DevTools** é levar o carro para o **elevador hidráulico da oficina**, com o motor ligado.
  - O **Inspector** é ver a estrutura por baixo: onde cada peça está encaixada de verdade, não onde
    o manual diz que deveria estar.
  - O **Layout Explorer** é o **paquímetro**: mede exatamente o espaço que cada peça ocupa e mostra
    qual está 2 mm maior que o vão.
  - A **Performance** é o **dinamômetro**: mostra em qual rotação o motor engasga.
  - A **Memory** é o teste de **vazamento de óleo**: você mede o nível, roda 20 voltas, mede de
    novo. Se baixou, está vazando em algum lugar.
  - A **Network** é ver as **mangueiras**: por onde passa o quê, e onde está entupido.
  - Os **debug flags** são a **luz negra** que revela marcas invisíveis a olho nu.
- **O que o elevador não faz:** dizer por que o motorista dirige daquele jeito. Isso é
  comportamento — e, no software, é lógica. Para isso, breakpoint e teste.

---

## 🧪 Exemplo mínimo

Um app com **quatro problemas plantados**, um para cada aba do DevTools.

> **Arquivo:** `foco_lab/lib/main.dart` (temporário)
> **Como executar:** `flutter run --profile` e aperte **`v`**

```dart
import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const AppComProblemas());

class AppComProblemas extends StatelessWidget {
  const AppComProblemas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaProblemas(),
    );
  }
}

class TelaProblemas extends StatelessWidget {
  const TelaProblemas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caça aos problemas')),
      body: ListView(
        children: const <Widget>[
          _Cartao(
            titulo: '1. Layout Explorer',
            descricao: 'Uma Row que estoura. Selecione-a no Inspector.',
            destino: TelaOverflow(),
          ),
          _Cartao(
            titulo: '2. Performance',
            descricao: 'Uma lista que trava. Abra a aba Performance.',
            destino: TelaLenta(),
          ),
          _Cartao(
            titulo: '3. Memory',
            descricao: 'Entre e saia 20 vezes. Depois compare os snapshots.',
            destino: TelaQueVaza(),
          ),
          _Cartao(
            titulo: '4. Repaints',
            descricao: 'Ligue "Highlight Repaints" e observe o que pisca.',
            destino: TelaRepintando(),
          ),
        ],
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.titulo,
    required this.descricao,
    required this.destino,
  });

  final String titulo;
  final String descricao;
  final Widget destino;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(titulo),
        subtitle: Text(descricao),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => destino),
        ),
      ),
    );
  }
}

// ═══ 1. OVERFLOW — para o Layout Explorer ═══════════════════════════════
class TelaOverflow extends StatelessWidget {
  const TelaOverflow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overflow')),
      body: Center(
        child: Container(
          width: 300,
          color: Colors.amber.shade100,
          padding: const EdgeInsets.all(16),
          // ❌ Três textos longos numa Row de 300 px.
          //
          // No Inspector: ative o Select Widget Mode, toque nesta Row,
          // e o Layout Explorer mostra QUANTO cada filho pediu e por
          // quantos pixels estourou.
          child: Row(
            children: <Widget>[
              const Text('Primeiro texto bem longo'),
              const Text('Segundo texto bem longo'),
              const Text('Terceiro texto bem longo'),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══ 2. LENTIDÃO — para a aba Performance ═══════════════════════════════
class TelaLenta extends StatelessWidget {
  const TelaLenta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista lenta')),
      body: ListView.builder(
        itemCount: 200,
        itemBuilder: (BuildContext context, int i) {
          // ❌ Cálculo caro DENTRO do itemBuilder.
          //
          // Na aba Performance: role a lista e observe as barras
          // AZUIS (UI thread) estourando os 16 ms.
          int soma = 0;
          for (int k = 0; k < 200000; k++) {
            soma += k % 7;
          }

          return ListTile(
            // ❌ E sombras pesadas: elas aparecem na barra ROXA (raster).
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            title: Text('Item $i'),
            subtitle: Text('soma: $soma'),
          );
        },
      ),
    );
  }
}

// ═══ 3. VAZAMENTO — para a aba Memory ═══════════════════════════════════
class TelaQueVaza extends StatefulWidget {
  const TelaQueVaza({super.key});

  @override
  State<TelaQueVaza> createState() => _TelaQueVazaState();
}

class _TelaQueVazaState extends State<TelaQueVaza> {
  final TextEditingController _campo = TextEditingController();
  Timer? _timer;
  int _tique = 0;

  /// ❌ Uma lista grande que fica presa pelo Timer, que nunca é cancelado.
  final List<String> _pesado =
      List<String>.generate(50000, (int i) => 'linha de texto número $i');

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _tique++);
    });
  }

  // ❌ SEM dispose.
  //
  // Na aba Memory: force um GC, entre e saia desta tela 20 vezes,
  // force GC de novo. O uso NÃO volta ao patamar.
  //
  // Em Diff Snapshots, `_TelaQueVazaState` aparece com 20 instâncias
  // vivas — uma por visita.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vazamento')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Text('Tique: $_tique'),
            const SizedBox(height: 16),
            TextField(controller: _campo),
            const SizedBox(height: 16),
            Text('${_pesado.length} linhas presas na memória'),
            const SizedBox(height: 24),
            const Text(
              'Volte e entre nesta tela 20 vezes.\n'
              'Depois force GC e compare os snapshots.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ 4. REPINTURA — para Highlight Repaints ═════════════════════════════
class TelaRepintando extends StatefulWidget {
  const TelaRepintando({super.key});

  @override
  State<TelaRepintando> createState() => _TelaRepintandoState();
}

class _TelaRepintandoState extends State<TelaRepintando> {
  int _contador = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => setState(() => _contador++),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repinturas')),
      body: Column(
        children: <Widget>[
          // ❌ Este cabeçalho NÃO muda — e é repintado 10 vezes por
          //    segundo, porque está dentro do build que o setState roda.
          //
          //    Ligue "Highlight Repaints" no Inspector: a borda dele
          //    fica piscando de cor.
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.teal.shade100,
            child: const Center(
              child: Text(
                'Este cabeçalho NÃO muda\n'
                'mas está sendo repintado 10×/s',
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // ✅ Só ISTO deveria repintar.
          Expanded(
            child: Center(
              child: Text(
                '$_contador',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Inspector → Highlight Repaints.\n'
              'A borda que pisca é a que está sendo repintada.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
```

**O roteiro, uma aba por problema:**

1. **Overflow** → Inspector → Select Widget Mode → toque na `Row` → Layout Explorer. Ele mostra que
   os três textos pedem ~420 px num espaço de 268 px.
2. **Lista lenta** → aba Performance → role a lista. As barras azuis estouram. Ative
   **Track widget builds** e veja quantos são construídos por quadro.
3. **Vazamento** → aba Memory → GC → entre e saia 20 vezes → GC. O patamar subiu. Use
   **Diff Snapshots** e encontre `_TelaQueVazaState` com 20 instâncias.
4. **Repinturas** → Inspector → **Highlight Repaints** → observe o cabeçalho piscando junto com o
   contador.

---

## 📱 Aplicando no Flutter

Agora você usa o DevTools para **corrigir** os quatro problemas — e confirma cada correção com a
mesma ferramenta que encontrou o defeito.

---

## 💻 Código completo

> **Arquivo:** `foco_lab/lib/diagnostico/tela_corrigida.dart` (novo)
> **Como executar:** `flutter run --profile` e aperte `v`

```dart
import 'dart:async';

import 'package:flutter/material.dart';

// ═══ 1. OVERFLOW CORRIGIDO ══════════════════════════════════════════════
class TelaSemOverflow extends StatelessWidget {
  const TelaSemOverflow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sem overflow')),
      body: Center(
        child: Container(
          width: 300,
          color: Colors.green.shade50,
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: <Widget>[
              // ✅ Expanded: cada texto recebe 1/3 do espaço.
              //
              // No Layout Explorer, os três agora aparecem com flex 1
              // e larguras iguais — e o retângulo de overflow sumiu.
              Expanded(
                child: Text(
                  'Primeiro texto bem longo',
                  // Sem isto, o texto quebraria em várias linhas.
                  // Com isto, vira "Primeiro tex…".
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  'Segundo texto bem longo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  'Terceiro texto bem longo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══ 2. LISTA RÁPIDA ════════════════════════════════════════════════════
class TelaRapida extends StatefulWidget {
  const TelaRapida({super.key});

  @override
  State<TelaRapida> createState() => _TelaRapidaState();
}

class _TelaRapidaState extends State<TelaRapida> {
  /// ✅ O cálculo caro sai do itemBuilder e acontece UMA vez.
  ///
  /// Na aba Performance, as barras azuis voltam para baixo dos 16 ms
  /// ao rolar a lista.
  late final List<int> _somas = List<int>.generate(200, _calcular);

  static int _calcular(int i) {
    int soma = 0;
    for (int k = 0; k < 200000; k++) {
      soma += k % 7;
    }
    return soma;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista rápida')),
      body: ListView.builder(
        itemCount: 200,
        itemBuilder: (BuildContext context, int i) {
          return ListTile(
            // ✅ Sombra leve. blurRadius e spreadRadius altos são
            // caros de rasterizar — aparecem na barra ROXA.
            leading: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
            ),
            title: Text('Item $i'),
            subtitle: Text('soma: ${_somas[i]}'),
          );
        },
      ),
    );
  }
}

// ═══ 3. SEM VAZAMENTO ═══════════════════════════════════════════════════
class TelaSemVazamento extends StatefulWidget {
  const TelaSemVazamento({super.key});

  @override
  State<TelaSemVazamento> createState() => _TelaSemVazamentoState();
}

class _TelaSemVazamentoState extends State<TelaSemVazamento> {
  final TextEditingController _campo = TextEditingController();
  Timer? _timer;
  int _tique = 0;

  /// ✅ Gerado sob demanda, não guardado inteiro na memória.
  ///
  /// A lista de 50 000 strings anterior ocupava megabytes — e ficava
  /// presa enquanto o State existisse.
  int get _quantasLinhas => 50000;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _tique++);
    });
  }

  @override
  void dispose() {
    // ✅ As duas linhas que resolvem o vazamento.
    //
    // Sem o cancel, o Timer continua disparando e mantém o State
    // INTEIRO vivo — inclusive a lista pesada.
    //
    // Sem o dispose do controller, ele vaza junto.
    //
    // Na aba Memory, depois desta correção: force GC, entre e saia
    // 20 vezes, force GC. O patamar VOLTA ao inicial.
    _timer?.cancel();
    _campo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sem vazamento')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Text('Tique: $_tique'),
            const SizedBox(height: 16),
            TextField(controller: _campo),
            const SizedBox(height: 16),
            Text('$_quantasLinhas linhas (geradas sob demanda)'),
          ],
        ),
      ),
    );
  }
}

// ═══ 4. SEM REPINTURA DESNECESSÁRIA ═════════════════════════════════════
class TelaSemRepintura extends StatefulWidget {
  const TelaSemRepintura({super.key});

  @override
  State<TelaSemRepintura> createState() => _TelaSemRepinturaState();
}

class _TelaSemRepinturaState extends State<TelaSemRepintura> {
  int _contador = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => setState(() => _contador++),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sem repintura')),
      body: Column(
        children: <Widget>[
          // ✅ const: este widget é criado UMA vez e reaproveitado.
          //
          // O Flutter reconhece que ele não mudou e pula a
          // reconstrução — e o Highlight Repaints para de piscar aqui.
          const _CabecalhoFixo(),

          // ✅ RepaintBoundary: isola a região que muda numa camada
          // própria. O que repinta aqui dentro não força a repintura
          // do resto da tela.
          Expanded(
            child: RepaintBoundary(
              child: Center(
                child: Text(
                  '$_contador',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget separado E const.
///
/// Extrair para uma classe própria é o que permite o `const` —
/// e o `const` é o que permite ao Flutter pular a reconstrução.
class _CabecalhoFixo extends StatelessWidget {
  const _CabecalhoFixo();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.green.shade50,
      child: const Center(
        child: Text(
          'Este cabeçalho NÃO é mais repintado',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
```

> **Arquivo:** `foco_lab/lib/diagnostico/flags_de_debug.dart` (novo)

```dart
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Os debug flags, ligáveis por código.
///
/// O Inspector do DevTools tem botões para todos estes — e usar os
/// botões é melhor, porque não exige recompilar.
///
/// Este arquivo existe para você saber QUE FLAGS SÃO, e para os casos
/// em que você quer ligar um deles automaticamente numa build de teste.
///
/// ⚠️ NUNCA deixe nenhum ligado em código que vá para produção.
abstract final class FlagsDeDebug {
  /// Desenha a caixa de cada widget, com padding e alinhamento.
  ///
  /// É o equivalente à tecla `p` no terminal. Quando o layout está
  /// estranho e você não sabe por quê, ligue: o problema costuma
  /// ficar óbvio.
  static void mostrarCaixas({bool ligado = true}) {
    debugPaintSizeEnabled = ligado;
  }

  /// Desenha a linha de base do texto.
  ///
  /// Útil quando dois textos lado a lado parecem desalinhados
  /// verticalmente por um ou dois pixels.
  static void mostrarLinhasDeBase({bool ligado = true}) {
    debugPaintBaselinesEnabled = ligado;
  }

  /// Borda colorida que MUDA DE COR a cada repintura.
  ///
  /// Uma área que pisca constantemente está sendo repintada sem
  /// necessidade — geralmente por falta de `const` ou de
  /// RepaintBoundary.
  static void destacarRepinturas({bool ligado = true}) {
    debugRepaintRainbowEnabled = ligado;
  }

  /// Marca as áreas que respondem a toque.
  ///
  /// Encontra o alvo de toque pequeno demais (< 48 px) e a área
  /// invisível que está capturando toques que deveriam passar.
  static void mostrarAreasDeToque({bool ligado = true}) {
    debugPaintPointersEnabled = ligado;
  }

  /// Animações em câmera lenta.
  ///
  /// 5.0 = cinco vezes mais devagar. Permite ver uma transição
  /// quadro a quadro e notar o que está estranho.
  static void animacoesLentas({double fator = 5}) {
    timeDilation = fator;
  }

  static void desligarTudo() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugRepaintRainbowEnabled = false;
    debugPaintPointersEnabled = false;
    timeDilation = 1;
  }
}
```

> **Arquivo:** `foco_lab/lib/diagnostico/marcadores_de_desempenho.dart` (novo)

```dart
import 'dart:developer' as developer;

/// Marcadores para a aba Performance.
///
/// O DevTools mostra quanto tempo cada quadro levou — mas não diz
/// QUAL PARTE do seu código gastou esse tempo. Os marcadores aparecem
/// como faixas nomeadas na linha do tempo, respondendo exatamente isso.
abstract final class Marcadores {
  /// Envolve um trecho síncrono e mede.
  ///
  /// Na aba Performance → Timeline Events, o trecho aparece como uma
  /// faixa com este nome.
  static T medir<T>(String nome, T Function() acao) {
    developer.Timeline.startSync(nome);
    try {
      return acao();
    } finally {
      // finally: a faixa fecha mesmo se a ação lançar. Sem isto,
      // uma exceção deixaria a timeline permanentemente aberta.
      developer.Timeline.finishSync();
    }
  }

  /// Versão assíncrona.
  ///
  /// Trechos assíncronos precisam de startSync/finishSync com task,
  /// porque podem se sobrepor no tempo.
  static Future<T> medirAsync<T>(
    String nome,
    Future<T> Function() acao,
  ) async {
    final developer.TimelineTask tarefa = developer.TimelineTask()
      ..start(nome);
    try {
      return await acao();
    } finally {
      tarefa.finish();
    }
  }

  /// Marca um instante pontual na linha do tempo.
  ///
  /// Útil para correlacionar um evento (o usuário tocou aqui) com
  /// um pico de quadros.
  static void marcar(String nome, [Map<String, Object?>? dados]) {
    developer.Timeline.instantSync(nome, arguments: dados);
  }
}
```

E o uso, num controller real:

```dart
// features/materias/presentation/materias_controller.dart
Future<void> recarregar() async {
  // Aparece como uma faixa "carregar_materias" na Timeline,
  // com a duração exata.
  await Marcadores.medirAsync('carregar_materias', () async {
    final List<Materia> lista = await _repo.listar();

    // E esta, aninhada dentro dela.
    Marcadores.medir('ordenar_materias', () {
      lista.sort((Materia a, Materia b) => a.nome.compareTo(b.nome));
    });

    state = AsyncData<List<Materia>>(lista);
  });
}
```

Rode e investigue:

```powershell
# Modo PROFILE: o debug é 2 a 10 vezes mais lento e mede errado.
flutter run --profile
# … e aperte `v` para abrir o DevTools.
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `Expanded` + `maxLines: 1` + `ellipsis` | Corrige o overflow **e** impede o texto de quebrar em várias linhas. O Layout Explorer mostra os três com `flex 1`. |
| `late final List<int> _somas = List.generate(200, _calcular)` | O cálculo sai do `itemBuilder` e roda **uma** vez. As barras azuis voltam ao normal. |
| Sombra removida | `blurRadius` e `spreadRadius` altos são caros de **rasterizar** — a barra roxa. |
| `_timer?.cancel()` no `dispose` | Sem isso, o `Timer` mantém o `State` **inteiro** vivo, incluindo a lista pesada. É o vazamento. |
| `_campo.dispose()` | O controller vaza junto. |
| Lista de 50 000 → getter | O dado não precisava existir na memória. |
| `const _CabecalhoFixo()` | Extrair para classe é o que **permite** o `const`; o `const` é o que permite pular a reconstrução. |
| `RepaintBoundary` em volta do contador | Isola a região que muda numa camada própria: repintar ali não força o resto. |
| `Timeline.startSync` / `finishSync` em `try/finally` | Sem o `finally`, uma exceção deixaria a faixa **permanentemente aberta** na timeline. |
| `TimelineTask` para assíncrono | Trechos assíncronos podem se sobrepor; `startSync` simples não daria conta. |
| `Timeline.instantSync` | Marca um instante, para correlacionar um toque do usuário com um pico de quadros. |
| `FlagsDeDebug` como referência | Os botões do Inspector são melhores (não exigem recompilar) — o arquivo existe para você saber **quais flags são**. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| DevTools funciona | ✅ igual | ✅ igual |
| Conectar por USB | ✅ | ✅ (com o Mac) |
| Conectar por Wi-Fi | ✅ `adb connect` | ⚠️ pelo Xcode |
| Memória disponível | Varia muito por aparelho | Mais uniforme |
| Limite antes de o SO matar | Generoso em aparelhos novos | **Mais rígido** |
| Aba Network captura | Requisições Dart | Requisições Dart |
| Perfil no emulador | ⚠️ não representa o aparelho real | ⚠️ idem no simulador |

> ⚠️ **A última linha é a mais importante para medir desempenho.** O emulador Android roda no seu
> PC, com processador de desktop; o simulador iOS idem. Um app fluido no emulador pode travar num
> celular de entrada.
>
> **Meça sempre no aparelho mais fraco que você pretende suportar.** Se o app roda bem nele, roda
> em todos.

> 📌 **No iOS, o limite de memória é mais rígido.** Um app que usa 800 MB pode funcionar num Android
> com 12 GB de RAM e ser **morto** num iPhone. A aba Memory é mais crítica para iOS do que para
> Android.

---

## ⚠️ Erros comuns

### 1. Medir desempenho em modo debug

O debug tem verificações extras e é 2 a 10 vezes mais lento.

**Correção:** `flutter run --profile`.

### 2. Medir no emulador

Ele usa o processador do seu PC.

**Correção:** meça no aparelho mais fraco que você suporta.

### 3. Otimizar sem medir

Você passa uma tarde otimizando o que não era o gargalo.

**Correção:** Performance primeiro, otimização depois.

### 4. Confundir barra azul com roxa

| Azul alta | Roxa alta |
|---|---|
| O problema é o seu **código Dart** | O problema é a **pintura** |
| `build` pesado, rebuild demais | Sombras, `Opacity`, blur, imagens grandes |

Otimizar o lado errado não muda nada.

### 5. Não forçar GC antes de comparar memória

O número sobe naturalmente entre coletas.

**Correção:** GC → ação → GC → compare.

### 6. Achar que todo crescimento de memória é vazamento

Cache, imagens pré-carregadas e listas grandes ocupam memória **legitimamente**.

**Correção:** vazamento é o que **não volta** depois do GC.

### 7. Deixar `debugPaintSizeEnabled` no código

```dart
void main() {
  debugPaintSizeEnabled = true;   // ⚠️ e esquecer
  runApp(const MeuApp());
}
```

**Correção:** use os botões do Inspector — eles não vão para o commit.

### 8. Não usar o Select Widget Mode

Procurar o widget na árvore à mão, com 200 nós.

**Correção:** o botão do alvo, e toque no app.

### 9. Ignorar "Highlight Oversized Images"

Uma imagem 4000 × 3000 num espaço 100 × 100 ocupa **48 MB**.

**Correção:** `cacheWidth` ([Módulo 06, aula 8](../06-widgets-e-layouts/08-imagens-e-assets.md)).

### 10. Esperar que o DevTools encontre bug de lógica

Ele mostra **o que** acontece, não **por que**.

**Correção:** breakpoint (aula 2) e testes (aulas 5 a 7).

### 11. `Timeline.startSync` sem `finally`

Uma exceção deixa a faixa aberta e a timeline fica inutilizável.

**Correção:** `try/finally`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo com `flutter run --profile` e aperte `v`.

**Passo 2.** Vá para **Overflow**. No Inspector, ative o Select Widget Mode, toque na `Row` e abra o
Layout Explorer. Anote quanto cada texto pediu e por quantos pixels estourou.

**Passo 3.** Ainda no Layout Explorer, mude o `mainAxisAlignment` pelos botões e observe o app. Sem
editar código.

**Passo 4.** Vá para **Lista lenta**, abra a aba Performance e role. Quantos milissegundos o quadro
mais lento levou? A barra alta é azul ou roxa?

**Passo 5.** Ative **Track widget builds** e role de novo. Quantos widgets são construídos por
quadro?

**Passo 6.** Vá para **Vazamento**. Na aba Memory: GC → anote o valor → entre e saia 20 vezes → GC →
compare.

**Passo 7.** Use **Diff Snapshots** e encontre `_TelaQueVazaState`. Quantas instâncias?

**Passo 8.** Aplique a correção (`_timer?.cancel()` e `_campo.dispose()`) e repita o passo 6. O
patamar voltou?

**Passo 9.** Vá para **Repinturas** e ligue **Highlight Repaints**. Quais regiões piscam? Aplique o
`const` e o `RepaintBoundary` e repita.

**Passo 10.** Acrescente `Marcadores.medirAsync` a uma função assíncrona do seu app e encontre a
faixa na Timeline.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

Faça os exercícios de **Diagnóstico** com Layout Explorer, o de **Medição** com a aba Performance, e
o de **Investigação** de vazamento de memória.

---

## 🏆 Desafio opcional

Crie uma **tela de diagnóstico** dentro do `foco_lab`, disponível só em debug, que reúna as
informações que o DevTools mostra — mas **dentro do app**, para usar em aparelho físico sem cabo.

Requisitos:

- Quadros por segundo em tempo real, com média e pior caso dos últimos 100 quadros.
- Uso de memória atual (`ProcessInfo.currentRss`).
- Contador de rebuilds por widget observado.
- Lista das últimas 20 requisições HTTP, com duração.
- Botões para ligar/desligar cada debug flag.
- A tela só existe com `kDebugMode` — nem compila em release.

Dica: `SchedulerBinding.instance.addTimingsCallback` entrega a duração de cada quadro
(`FrameTiming.totalSpan`). Para as requisições, um `http.BaseClient` que registra cada `send`.

Depois responda: por que uma tela dessas é útil **mesmo tendo o DevTools**? (Dica: pense em testar
com um usuário real, no aparelho dele, sem computador por perto.)

---

## 📌 Resumo

- O DevTools abre com **`v` no terminal**, pelo VS Code, ou com `dart devtools` + a URL do serviço
  de VM.
- Ele **só funciona em debug ou profile** — nunca em release.
- **Inspector** mostra a árvore real; o **Select Widget Mode** leva direto ao widget que você tocou.
- **Layout Explorer** é a ferramenta mais útil para layout: mostra quanto cada filho pediu, o `flex`
  de cada um, e **quantos pixels** estouraram. Dá até para mudar o alinhamento sem editar código.
- **Performance:** cada quadro tem 16,67 ms (60 Hz). Barra **azul** alta = seu código Dart; barra
  **roxa** alta = pintura.
- **Meça em modo profile, no aparelho mais fraco.** Debug é 2 a 10 vezes mais lento; emulador usa o
  processador do PC.
- **Memory:** vazamento é o que **não volta** depois do GC. Use GC → ação 20× → GC → `Diff
  Snapshots`.
- As causas de vazamento são sempre as mesmas: controller, `Timer`, `StreamSubscription`,
  `AnimationController` e `family` sem descarte.
- **Network** mostra duração, cabeçalhos e corpo — mas não captura requisições nativas nem de outro
  `Isolate`.
- **Debug flags** pelos botões do Inspector, não por código. Os mais úteis: **Show Guidelines** e
  **Highlight Repaints**.
- **Highlight Oversized Images** encontra o problema de memória mais comum em apps com fotos.
- O DevTools responde **"o que"**; breakpoint responde **"por que"**; teste garante que **não volte**.

---

## ☑️ Checklist de domínio

- [ ] Abro o DevTools das três formas.
- [ ] Uso o Select Widget Mode para chegar ao widget.
- [ ] Diagnostico overflow e `Expanded` com o Layout Explorer.
- [ ] Sei que cada quadro tem 16,67 ms e o que significa cada cor de barra.
- [ ] Meço sempre em profile, no aparelho mais fraco.
- [ ] Encontro vazamento com GC → ação → GC → Diff Snapshots.
- [ ] Conheço as cinco causas clássicas de vazamento.
- [ ] Uso a aba Network para achar a requisição lenta.
- [ ] Uso os debug flags pelos botões, não por código.
- [ ] Sei o que o DevTools **não** resolve.
- [ ] Sei instrumentar meu código com `Timeline`.

---

## 📚 Referências oficiais

- [Flutter DevTools — docs.flutter.dev](https://docs.flutter.dev/tools/devtools/overview)
- [Flutter Inspector — docs.flutter.dev](https://docs.flutter.dev/tools/devtools/inspector)
- [Performance view — docs.flutter.dev](https://docs.flutter.dev/tools/devtools/performance)
- [Memory view — docs.flutter.dev](https://docs.flutter.dev/tools/devtools/memory)
- [Network view — docs.flutter.dev](https://docs.flutter.dev/tools/devtools/network)
- [Debugging tools — docs.flutter.dev](https://docs.flutter.dev/testing/debugging)
- [Performance best practices — docs.flutter.dev](https://docs.flutter.dev/perf/best-practices)
- [dart:developer Timeline — api.dart.dev](https://api.dart.dev/stable/dart-developer/Timeline-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Logs e breakpoints](02-logs-e-breakpoints.md) | [README](README.md) | [Aula 4 — Análise, lint e formatação](04-analise-lint-formatacao.md) |
