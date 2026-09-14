# Aula 1 — Lendo stack traces

> **Módulo:** 12 - Testes e Depuração · **Tempo estimado:** 30 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Descrever a **anatomia de um erro do Flutter**: o quadro `EXCEPTION CAUGHT BY ...`, a mensagem,
  o stack trace e o widget culpado.
- Diferenciar a **caixa vermelha** (modo debug) da **tela cinza** (modo release) e saber onde
  procurar o erro em cada caso.
- Ler um stack trace **de cima para baixo** e encontrar a **primeira linha do seu código**.
- Classificar um erro em **build**, **layout** ou **estado** apenas pelo texto.
- Reconhecer, pelo texto real, os cinco erros mais comuns do Flutter e dizer a causa de cada um.
- Aplicar um **método de 5 passos** para depurar sozinho um erro que você nunca viu.

## ✅ Pré-requisitos

- [Módulo 01 — Lendo mensagens de erro](../01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md)
  e [Módulo 04 — Exceptions](../04-dart-avancado/01-exceptions.md): `throw`, `try/catch`, pilha.
- [Módulo 06 — Constraints](../06-widgets-e-layouts/06-constraints.md) e
  [Módulo 05 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md).
- O projeto `foco_lab` criado conforme o [README do módulo](README.md).

---

## 📖 Conceito

### Por que esta é a primeira aula do módulo

Programar é, na prática, passar boa parte do tempo lendo erros. A diferença entre quem trava duas
horas e quem resolve em dois minutos quase nunca é "saber mais Flutter" — é **saber ler**.

O Flutter é generoso: quando algo quebra, ele devolve um relatório com título, explicação,
sugestão de correção e o caminho exato até o problema. O custo é que esse relatório é **longo**,
e o iniciante bate o olho, vê 60 linhas em inglês e fecha o terminal. Esta aula é o antídoto.

### Anatomia de um erro do Flutter

Quando uma exceção escapa durante a construção ou o desenho de um widget, o Flutter imprime no
terminal um bloco delimitado por barras, sempre com as mesmas partes:

```text
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════
The following _TypeError was thrown building MateriaTile(dirty):
Null check operator used on a null value

The relevant error-causing widget was:
  MateriaTile MateriaTile:file:///C:/src/foco_lab/lib/features/materias/presentation/materias_tab.dart:41:26

When the exception was thrown, this was the stack:
#0      MateriaTile.build (package:foco_lab/features/materias/presentation/widgets/materia_tile.dart:23:38)
#1      StatelessElement.build (package:flutter/src/widgets/framework.dart:5738:49)
#2      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5626:15)
#3      Element.rebuild (package:flutter/src/widgets/framework.dart:5330:7)
...
════════════════════════════════════════════════════════════════════════════════
```

Leia por partes:

| Parte | O que é | Como usar |
|---|---|---|
| `EXCEPTION CAUGHT BY WIDGETS LIBRARY` | **Quem** capturou o erro. Pode ser `WIDGETS LIBRARY`, `RENDERING LIBRARY`, `GESTURE`, `SCHEDULER`, `SERVICES`, `FLUTTER TEST FRAMEWORK` | Já classifica o erro: `RENDERING` = layout, `WIDGETS` = construção, `GESTURE` = toque |
| `The following _TypeError was thrown building MateriaTile` | **Tipo** da exceção + **em qual widget** ela ocorreu | Diz onde começar a procurar |
| `Null check operator used on a null value` | **Mensagem** da exceção | É a frase que você joga no buscador, entre aspas |
| `The relevant error-causing widget was:` | O widget que o Flutter aponta como culpado, com arquivo, linha e coluna | Muitas vezes é a resposta pronta |
| `When the exception was thrown, this was the stack:` | O **stack trace** — quem chamou quem | Ache a **primeira** linha com `package:foco_lab/` |

> **Stack trace** (*rastro de pilha*): a lista, do mais recente para o mais antigo, das funções que
> estavam em execução no momento do erro. `#0` é onde a bomba explodiu; `#1` é quem chamou `#0`;
> e assim por diante até o começo do programa.

### A regra de ouro: ache a PRIMEIRA linha do SEU código

Um stack trace do Flutter tem facilmente 40 linhas, quase todas do framework
(`package:flutter/src/...`) — encanamento interno, não o seu bug.

**Leia de cima para baixo e pare na primeira linha que contenha o nome do seu pacote**
(`package:foco_lab/...`) ou um caminho `file:///C:/...` do seu projeto. No exemplo acima, a linha
`#0` diz: arquivo `lib/features/materias/presentation/widgets/materia_tile.dart`, **linha 23**,
**coluna 38**, dentro do método `build` da classe `MateriaTile`. É ali que você abre o editor.

> ⚠️ Se **nenhuma** linha do stack trace for do seu pacote, olhe o campo
> `The relevant error-causing widget was:` — ele aponta o lugar do seu código que **criou** o
> widget problemático. É comum em erros de layout: quem falha é o `RenderFlex` interno, não o
> seu `Row`.

### Caixa vermelha × tela cinza

O Flutter mostra o erro de duas formas, conforme o **modo de compilação**:

| | 🔴 Caixa vermelha | ⬜ Tela cinza |
|---|---|---|
| Aparece em | `flutter run` (modo **debug**) | modo **release** (`flutter build apk --release`) |
| Mostra | Título, mensagem completa e stack trace resumido | Nada: um retângulo cinza ou área em branco |
| Por quê | Debug prioriza diagnóstico | Release não embarca as mensagens, para não vazar detalhes internos nem pesar o app |

> **Um bug só aparece descrito na tela em modo debug.** Se alguém reclamar de "um quadrado cinza"
> no APK de release, o seu trabalho é reproduzir a mesma tela com `flutter run` para ler a caixa
> vermelha. Em release o texto do erro **não some** — vai para o log do sistema operacional
> (🤖 `adb logcat`, 🍎 Console.app), assunto da [aula 9](09-depurando-android-e-ios.md).

A caixa vermelha só ocupa a região do widget que falhou: se apenas um item da lista falhou, você
vê a lista normal com **uma faixa vermelha** no lugar daquele item. Isso já é uma pista de escopo.

### Três famílias de erro: build, layout e estado

Classificar antes de investigar economiza muito tempo:

| Família | Quando acontece | Marca registrada no texto | Exemplos |
|---|---|---|---|
| **Build** | Ao construir a árvore, dentro de `build()` | `CAUGHT BY WIDGETS LIBRARY`, "thrown building" | `Null check operator used on a null value`, `No Material widget found` |
| **Layout** | Ao medir e posicionar, depois do build | `CAUGHT BY RENDERING LIBRARY`, nomes com `Render...` | `A RenderFlex overflowed by 84 pixels`, `Vertical viewport was given unbounded height` |
| **Estado** | Fora do build, em callbacks e código assíncrono | Fala de ciclo de vida, `setState`, `dispose`, `mounted` | `setState() called after dispose()`, `Looking up a deactivated widget's ancestor is unsafe` |

Cada família tem um **lugar** para olhar. Build → os dados que chegam no widget. Layout → as
**constraints** (restrições de tamanho que o pai impõe ao filho). Estado → o que acontece
**depois** de um `await` ou de um `Timer`.

---

## 💡 Analogia

Um stack trace é o **registro de encaminhamento de uma ligação telefônica** que deu errado: você
ligou para a central (`main`), que transferiu para o setor de widgets, que transferiu para o seu
`MateriaTile`, que discou um número inexistente — e a ligação caiu. O relatório lista as
transferências **na ordem inversa**. Os intermediários
(`package:flutter/...`) são a operadora: funcionaram direitinho, só encaminharam. Você quer falar
com **a primeira pessoa da sua empresa** que aparece na lista — foi ela quem discou errado.

---

## 🧪 Exemplo mínimo

O menor erro completo possível, para você ver as partes juntas.

```dart
// foco_lab/lib/laboratorio/erro_minimo.dart
import 'package:flutter/material.dart';

// O nome da matéria ainda não foi carregado do banco: continua nulo.
String? nomeDaMateria;

// O '!' afirma "confie em mim, não é nulo". Quando é nulo, o app quebra aqui.
void main() => runApp(MaterialApp(
      home: Scaffold(body: Center(child: Text(nomeDaMateria!.toUpperCase()))),
    ));
```

```powershell
flutter run -d windows -t lib/laboratorio/erro_minimo.dart
```

Saída no terminal:

```text
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════
The following _TypeError was thrown building Center(alignment: center):
Null check operator used on a null value

When the exception was thrown, this was the stack:
#0      main (package:foco_lab/laboratorio/erro_minimo.dart:9:60)
```

Três leituras imediatas: (1) `WIDGETS LIBRARY` → família **build**; (2) `_TypeError` → erro de
tipo, e a mensagem diz que alguém usou `!` em algo nulo; (3) a linha `#0` é do **seu** pacote:
arquivo `erro_minimo.dart`, linha 9, coluna 60. É exatamente onde está o `!`.

---

## 📱 Aplicando no Flutter

Os erros que realmente aparecem, com o **texto real** e a **causa**.
### 1. `A RenderFlex overflowed by 84 pixels on the right`

```text
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞═════════════════════════════════════
A RenderFlex overflowed by 84 pixels on the right.

The relevant error-causing widget was:
  Row Row:file:///C:/src/foco_lab/lib/features/materias/presentation/widgets/materia_tile.dart:28:14

The overflowing RenderFlex has an orientation of Axis.horizontal.
The edge of the RenderFlex that is overflowing has been marked in the rendering
with a yellow and black striped pattern.
```

- **Família:** layout.
- **Causa:** a soma da largura dos filhos de um `Row` (ou a altura, num `Column`) passou do espaço
  que o pai ofereceu. O `Row` **não rola e não quebra linha** por conta própria. Sintoma visual:
  faixas amarelas e pretas na borda.
- **Correções:** (1) envolver o filho elástico em `Expanded` ou `Flexible`;
  (2) `overflow: TextOverflow.ellipsis` no `Text` longo; (3) trocar `Row` por `Wrap`;
  (4) em `Column` alta, envolver em `SingleChildScrollView`.
- **Onde nasce no Foco:** o `MateriaTile` mostra nome + minutos + botões numa linha só. Um nome
  longo — "Introdução à Análise Matemática" — estoura em tela pequena.

### 2. `setState() called after dispose()`

```text
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════
setState() called after dispose(): _SessaoScreenState#3a1b2(lifecycle state: defunct, not mounted)

This error happens if you call setState() on a State object for a widget that no
longer appears in the widget tree.
```

- **Família:** estado.
- **Causa:** um `Timer`, uma `Future` ou um `Stream` terminou **depois** que a tela saiu da
  árvore, e o callback chamou `setState()` num `State` já descartado.
- **Onde nasce no Foco:** a `SessaoScreen` tem um cronômetro com `Timer.periodic`. Voltar da tela
  sem cancelar o timer faz o próximo tique disparar este erro.
- **Correções:** cancelar o recurso em `dispose()` e checar `mounted` depois de cada `await`.

```dart
Future<void> _salvarSessao() async {
  await _repositorio.salvar(_sessao);
  if (!mounted) return;              // ← sem isto, risco de setState após dispose
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sessão registrada')),
  );
}
```

### 3. `Null check operator used on a null value`

- **Família:** build (mas pode aparecer em qualquer lugar).
- **Causa:** o operador `!` (*null check operator* — afirma que um valor anulável não é nulo) foi
  aplicado a algo que era `null`. No Foco: `snapshot.data!` antes de os dados chegarem,
  `_materiaSelecionada!` antes de o usuário escolher, `json['title']!` num campo ausente.
- **Correções:** trocar `!` por `?? valorPadrao`; tratar explicitamente o estado "ainda não tem
  dado" (é o que `AsyncValue.when(loading:, error:, data:)` do Riverpod faz); ou usar
  `if (valor != null) { ... }`, porque o Dart faz *promotion* e o `!` deixa de ser preciso.

### 4. `No Material widget found`

```text
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════
No Material widget found.

TextField widgets require a Material widget ancestor within the closest LookupBoundary.
```

- **Família:** build.
- **Causa:** um widget do Material Design (`TextField`, `ListTile`, `InkWell`, `Card`) precisa de
  um ancestral `Material` — normalmente fornecido pelo `Scaffold`.
- **Onde nasce no Foco:** **em teste de widget**. É o erro nº 1 da
  [aula 6](06-testes-de-widget.md): você chama `tester.pumpWidget(const MateriaTile(...))` sem
  envolver em `MaterialApp(home: Scaffold(body: ...))`.
- **Correção:** envolva em `Scaffold` (na tela) ou em `MaterialApp(home: Scaffold(body: ...))`
  (no teste).

### 5. `Vertical viewport was given unbounded height`

```text
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞═════════════════════════════════════
Vertical viewport was given unbounded height.

Viewports expand in the scrolling direction to fill their container. In this case,
a vertical viewport was given an unlimited amount of vertical space in which to
expand.
```

- **Família:** layout.
- **Causa:** um `ListView` (que quer crescer para sempre na vertical) ficou dentro de um pai que
  **não limita a altura** — tipicamente um `Column` dentro de `SingleChildScrollView`.
- **Onde nasce no Foco:** na aba "Hoje", com o texto da meta e a lista de sessões do dia dentro
  de um `Column`.
- **Correções:** (1) `Expanded(child: ListView(...))`; (2) `SizedBox(height: 240, child: ...)`;
  (3) `ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), ...)` —
  **cuidado**, isso mede todos os filhos e custa caro em listas grandes.
- **Erro-irmão, mesma causa invertida:** `BoxConstraints forces an infinite width`, quando um
  `Row` fica dentro de um `SingleChildScrollView` horizontal.

### O método de 5 passos para depurar sozinho

Decore isto. Funciona para qualquer erro, inclusive os que não estão nesta lista.

| Passo | O que fazer | Por quê |
|---|---|---|
| **1. Leia a primeira frase** | Só a linha depois de `The following ... was thrown`. Não role a tela ainda | Na maioria dos casos ela já diz tudo |
| **2. Classifique** | `WIDGETS` = build · `RENDERING` = layout · outros = estado/serviço | Define onde procurar |
| **3. Ache a sua linha** | Primeira ocorrência de `package:foco_lab/` no stack, ou o campo `relevant error-causing widget` | Dá arquivo e linha exatos |
| **4. Teste UMA hipótese** | "O `nome` está chegando nulo." Confirme com `debugPrint('nome=$nome')` ou um breakpoint | Mudar três coisas de uma vez impede saber qual resolveu |
| **5. Trave com um teste** | Escreva um teste que reproduza o bug, veja-o falhar, corrija, veja-o passar | O bug não volta. É o assunto das aulas 5 a 7 |

> Se depois do passo 3 você ainda estiver perdido: pesquise **a primeira frase do erro entre
> aspas** mais a palavra `flutter`. Não pesquise o stack trace inteiro — ele tem nomes do seu
> projeto e não casa com nada.

---

## 💻 Código completo

Um laboratório com os cinco erros, cada um atrás de um item de lista.

> **Arquivo:** `foco_lab/lib/laboratorio/tela_de_erros.dart`
> **Como executar:** `flutter run -d windows -t lib/laboratorio/tela_de_erros.dart`

```dart
// foco_lab/lib/laboratorio/tela_de_erros.dart
// Aula 1: cada item provoca UM erro real. Apague esta pasta ao fim do módulo.
import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: MenuDeErros()));

class MenuDeErros extends StatelessWidget {
  const MenuDeErros({super.key});

  // Título + FUNÇÃO que cria a tela (não widget pronto: veja a explicação abaixo).
  static final List<(String, Widget Function())> itens = <(String, Widget Function())>[
    ('1. RenderFlex overflowed', () => const TelaOverflow()),
    ('2. setState() after dispose()', () => const TelaTimerSolto()),
    ('3. Null check operator', () => const TelaNuloEstourado()),
    ('4. No Material widget found', () => const TelaSemMaterial()),
    ('5. Unbounded height', () => const TelaViewportSemLimite()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratório de erros')),
      body: ListView(
        children: <Widget>[
          for (final (String titulo, Widget Function() criar) item in itens)
            ListTile(
              title: Text(item.$1),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => item.$2()),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── 1. Layout: Row com filhos largos demais ────────────────────────────────
// CORREÇÃO: envolver o Text em Expanded + overflow: TextOverflow.ellipsis.
class TelaOverflow extends StatelessWidget {
  const TelaOverflow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Row(
        children: <Widget>[
          Text('Introdução à Análise Matemática', style: TextStyle(fontSize: 26)),
          Icon(Icons.timer, size: 48),
          Icon(Icons.edit, size: 48),
          Icon(Icons.delete, size: 48),
        ],
      ),
    );
  }
}

// ─── 2. Estado: Timer que sobrevive ao dispose ──────────────────────────────
// CORREÇÃO: guardar em `Timer? _timer` e chamar `_timer?.cancel()` no dispose().
class TelaTimerSolto extends StatefulWidget {
  const TelaTimerSolto({super.key});

  @override
  State<TelaTimerSolto> createState() => _TelaTimerSoltoState();
}

class _TelaTimerSoltoState extends State<TelaTimerSolto> {
  int _segundos = 0;

  @override
  void initState() {
    super.initState();
    // Repare: não guardamos a referência e não cancelamos no dispose().
    Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _segundos++));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Sessão: $_segundos s — volte e espere 1 segundo.')),
    );
  }
}

// ─── 3. Build: operador ! em valor nulo ─────────────────────────────────────
// CORREÇÃO: Text((nome ?? 'Sem nome').toUpperCase())
class TelaNuloEstourado extends StatelessWidget {
  const TelaNuloEstourado({super.key});
  @override
  Widget build(BuildContext context) {
    // Simula o mapa que volta do sqflite quando a coluna 'nome' foi renomeada.
    const Map<String, Object?> doBanco = <String, Object?>{'id': 'm-01', 'minutos': 0};
    final String? nome = doBanco['nome'] as String?;

    return Scaffold(body: Center(child: Text(nome!.toUpperCase())));
  }
}

// ─── 4. Build: widget Material sem ancestral Material ───────────────────────
// CORREÇÃO: envolver em Scaffold(body: ...) ou em Material(child: ...).
class TelaSemMaterial extends StatelessWidget {
  const TelaSemMaterial({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 260,
        child: TextField(decoration: InputDecoration(labelText: 'Nome da matéria')),
      ),
    );
  }
}

// ─── 5. Layout: ListView dentro de Column sem limite de altura ──────────────
// CORREÇÃO 1: Column + Expanded(child: ListView...).
// CORREÇÃO 2: shrinkWrap: true + NeverScrollableScrollPhysics().
class TelaViewportSemLimite extends StatelessWidget {
  const TelaViewportSemLimite({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> materias = <String>['Cálculo I', 'Álgebra Linear'];
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Text('Meta da semana: 600 minutos'),
            ListView.builder(
              itemCount: materias.length,
              itemBuilder: (BuildContext context, int i) =>
                  ListTile(title: Text(materias[i])),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔍 Explicando o código

- **A lista `itens` guarda funções, não widgets prontos.** Cada entrada é um *record* (registro —
  um agrupamento leve de valores, do Dart 3) com título e uma função `Widget Function()`. Se
  guardasse o widget pronto, todas as telas seriam construídas ao montar o menu e o erro
  estouraria antes do toque. `item.$1` é o título; `item.$2()` cria a tela.
- **`TelaOverflow`** usa `fontSize: 26` e três ícones de 48 de propósito. O `Row` pergunta o
  tamanho de cada filho; nenhum é flexível, então a soma passa da largura da janela.
- **`_TelaTimerSoltoState`** não guarda o `Timer` e não sobrescreve `dispose()`. Ao voltar ao
  menu, o `State` vira `defunct`, mas o timer continua vivo no motor do Dart e dispara `setState`
  um segundo depois — a situação exata do cronômetro da `SessaoScreen`.
- **`TelaNuloEstourado`** simula o `Map<String, Object?>` que volta do `sqflite`. O cast
  `as String?` é honesto (pode ser nulo), mas o `!` da linha seguinte quebra a promessa: o dado
  some **na camada de dados** e explode **na camada de apresentação**.
- **`TelaSemMaterial`** devolve um `Center` sem `Scaffold`: o `TextField` desenha o efeito de
  tinta (*ink*) sobre uma folha de material e, sem essa folha, se recusa a existir. Já em
  **`TelaViewportSemLimite`** o `SingleChildScrollView` diz ao `Column` "você pode ter altura
  infinita", o `Column` repassa ao `ListView.builder` e ele responde "então não sei quanto
  medir" — o efeito dominó das constraints.

---

## 🤖🍎 Android × iOS

O texto do erro é **idêntico** nas duas plataformas — o motor é o mesmo. O que muda é **onde você
lê o erro quando não está com o terminal do `flutter run` aberto**:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Log em release/profile | `adb logcat -s flutter` | Console.app (macOS), filtrando pelo nome do app |
| Log com o aparelho conectado | `flutter logs` | `flutter logs`, mas o pareamento exige Mac |
| Caixa vermelha em debug | Sim, igual | Sim, igual |

> 🪟 **No Windows você consegue** ver a caixa vermelha e o stack trace completo com
> `flutter run -d windows`, `flutter run -d chrome` ou em um emulador Android. **Não consegue**
> ler o log de um iPhone físico: isso exige macOS ([aula 9](09-depurando-android-e-ios.md)).

---

## ⚠️ Erros comuns

| O que você faz de errado | O que acontece | O certo |
|---|---|---|
| Rolar o stack trace até o fim procurando "a resposta" | Perde tempo; o fim é sempre `main` e o motor do Flutter | Leia de **cima para baixo** e pare na primeira linha do seu pacote |
| Copiar o stack trace inteiro no buscador | Nenhum resultado, porque tem nomes do seu projeto | Pesquise só a **primeira frase**, entre aspas, mais `flutter` |
| Envolver tudo em `try/catch` para sumir com a caixa vermelha | O bug continua, agora invisível | Corrija a causa; `try/catch` é para falhas **esperadas** (rede, disco) |
| Espalhar `!` para calar o compilador | Troca erro de compilação por crash em produção | Trate o nulo: `??`, `if (x != null)`, `AsyncValue.when` |
| Chamar `setState` depois de `await` sem checar nada | `setState() called after dispose()` intermitente | `if (!mounted) return;` logo após **cada** `await` |

---

## 🛠️ Exercício guiado

**Objetivo:** provocar, ler e corrigir os cinco erros, aplicando o método de 5 passos.

1. Crie a pasta `lib/laboratorio/` dentro de `foco_lab` e salve ali o `tela_de_erros.dart`.
2. Rode:

   ```powershell
   flutter run -d windows -t lib/laboratorio/tela_de_erros.dart
   ```

3. Toque no item **1**. No terminal, anote: a linha `EXCEPTION CAUGHT BY ...` (qual biblioteca?),
   a primeira frase do erro, e o arquivo/linha do campo `relevant error-causing widget`.
4. Corrija o erro 1 envolvendo o `Text` em `Expanded` e acrescentando
   `overflow: TextOverflow.ellipsis`. Salve e use **hot reload** (tecla `r`): as faixas somem.
5. Toque no item **2**, volte ao menu e **espere um segundo**. Leia o erro e corrija guardando o
   timer em um campo e cancelando-o no `dispose()`:

   ```dart
   Timer? _timer;
   // em initState:
   _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _segundos++));

   @override
   void dispose() {
     _timer?.cancel();
     super.dispose();
   }
   ```

   Aqui é preciso **hot restart** (tecla `R` maiúsculo), porque `initState` já rodou.
6. Repita para os itens **3**, **4** e **5**, aplicando as correções comentadas no código.
7. Responda por escrito, em uma frase cada: qual dos cinco é de **layout**? Qual aparece
   **depois** de a tela sair da árvore? Qual você vai encontrar principalmente **em testes**?

**Resultado esperado:** os cinco itens abrem sem nenhum quadro de exceção no terminal, e você
explica de memória a causa de cada um.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

---

## 🏆 Desafio opcional

Crie um sexto item, **"6. Erro dentro da lista"**: uma `ListView.builder` com 20 matérias em que
**apenas o item de índice 7** lança `StateError('matéria corrompida')` dentro do `itemBuilder`.
Responda: (1) a caixa vermelha ocupa a tela inteira ou só a faixa daquele item? (2) a lista ainda
rola? (3) o que isso ensina sobre **escopo do erro**? (4) como devolver um widget de fallback
para o item inválido, em vez de deixar a lista inteira depender dele?

---

## 📌 Resumo

- Todo erro do Flutter vem num quadro com quatro partes: **quem capturou**, **tipo + widget**,
  **mensagem** e **stack trace**.
- `CAUGHT BY WIDGETS LIBRARY` = **build**; `RENDERING LIBRARY` = **layout**; os demais costumam
  ser de **estado**. Leia o stack trace **de cima para baixo** e pare na **primeira linha do seu
  pacote**.
- **Caixa vermelha** = debug, com texto completo. **Tela cinza** = release, sem texto: reproduza
  em debug ou leia o log do sistema operacional.
- Os cinco erros mais frequentes: `A RenderFlex overflowed` (falta `Expanded`),
  `setState() called after dispose()` (falta `cancel()`/`mounted`),
  `Null check operator used on a null value` (`!` indevido),
  `No Material widget found` (falta `Scaffold`),
  `Vertical viewport was given unbounded height` (falta limitar a altura).
- Método de 5 passos: **ler a primeira frase → classificar → achar a sua linha → testar uma
  hipótese → travar a correção com um teste**.

---

## ☑️ Checklist de domínio

- [ ] Aponto, num quadro de exceção, as quatro partes sem consultar a aula.
- [ ] Digo o que significa `EXCEPTION CAUGHT BY RENDERING LIBRARY`.
- [ ] Encontro a primeira linha do meu código em um stack trace de 40 linhas.
- [ ] Explico por que a tela cinza não mostra o erro e onde achar o texto nesse caso.
- [ ] Digo a causa e duas correções de `A RenderFlex overflowed`.
- [ ] Digo por que `setState() called after dispose()` acontece e as duas defesas contra ele.
- [ ] Reconheço `No Material widget found` como erro típico de teste de widget e explico por que
      `ListView` dentro de `Column` gera viewport sem limite.
- [ ] Recito o método de 5 passos e corrigi os cinco erros de `tela_de_erros.dart`.

---

## 📚 Referências oficiais

- [Common Flutter errors — docs.flutter.dev](https://docs.flutter.dev/testing/common-errors)
- [Debugging Flutter apps — docs.flutter.dev](https://docs.flutter.dev/testing/debugging)
- [Handling errors in Flutter — docs.flutter.dev](https://docs.flutter.dev/testing/errors)
- [Understanding constraints — docs.flutter.dev](https://docs.flutter.dev/ui/layout/constraints)
- [Flutter build modes — docs.flutter.dev](https://docs.flutter.dev/testing/build-modes)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — Logs e breakpoints](02-logs-e-breakpoints.md) |
