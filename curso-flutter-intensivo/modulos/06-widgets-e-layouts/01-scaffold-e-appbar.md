# Aula 1 — Scaffold e AppBar

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é o `Scaffold` e **para que serve cada um dos seus espaços** (`appBar`, `body`,
  `floatingActionButton`, `bottomNavigationBar`, `drawer`).
- Montar uma `AppBar` com `title`, `actions` e `leading`, e dizer quem coloca a seta de voltar lá.
- Mostrar uma mensagem temporária com `SnackBar` usando `ScaffoldMessenger` — e explicar por que
  `Scaffold.of(context).showSnackBar` **não existe mais**.
- Usar `SafeArea` e dizer exatamente qual problema físico de tela ele resolve.
- Escrever, de memória, a **estrutura padrão de uma tela** de app Flutter.
- Criar o projeto `foco_ui` que você vai usar nas 12 aulas deste módulo.

## ✅ Pré-requisitos

- [Módulo 05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md) inteiro, em especial
  [`StatefulWidget` e `setState`](../05-introducao-ao-flutter/05-statefulwidget-e-setstate.md).
- Flutter 3.47.1 respondendo no terminal ([02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md)).
- Saber o que é uma classe, um construtor e um parâmetro nomeado
  ([Módulo 03](../03-dart-intermediario/README.md)).

---

## 📖 Conceito

### O que é um Scaffold

**Scaffold** (em inglês, "andaime") é o widget que dá a **estrutura visual padrão de uma tela**
seguindo as regras do Material Design (o sistema de design criado pelo Google, que o Flutter
implementa por padrão).

Ele não decide o que aparece. Ele decide **onde** cada coisa aparece. Você entrega peças pelos
parâmetros nomeados, e o `Scaffold` posiciona cada uma no lugar certo, sem você calcular pixel.

Um `Scaffold` sozinho, sem nenhum parâmetro, já é uma tela válida: um retângulo do tamanho da
janela, pintado com a cor de fundo do tema.

### Os espaços (slots) do Scaffold

*Slot* é o nome que se dá a um "encaixe" nomeado de um widget: um parâmetro que recebe outro widget
e o coloca numa posição pré-definida.

| Slot | Onde fica | Para que serve |
|---|---|---|
| `appBar` | topo, fixo | Barra superior: título da tela, botão de voltar, ações |
| `body` | todo o espaço restante | O conteúdo da tela — é aqui que você passa 95 % do tempo |
| `floatingActionButton` | flutuando, canto inferior direito | **A** ação principal da tela (uma só) |
| `bottomNavigationBar` | rodapé, fixo | Navegação entre as seções principais do app |
| `drawer` | fora da tela, entra pela esquerda | Menu lateral, aberto por arrasto ou pelo ícone ☰ |
| `endDrawer` | fora da tela, entra pela direita | Menu lateral secundário (filtros, por exemplo) |
| `bottomSheet` | colado no rodapé, acima da `bottomNavigationBar` | Painel persistente (raro) |
| `backgroundColor` | fundo | Cor do fundo da tela |
| `resizeToAvoidBottomInset` | — | Se `true` (padrão), o `body` encolhe quando o teclado abre |

E o **SnackBar**? Ele é a exceção importante desta lista.

### SnackBar: o slot que não é um parâmetro

**SnackBar** é aquela barrinha preta que sobe do rodapé, mostra uma mensagem curta ("Matéria
salva") e some sozinha em alguns segundos.

O `Scaffold` **reserva o espaço** para ela na parte de baixo — inclusive empurrando o
`floatingActionButton` para cima quando ela aparece. Mas você não passa um `snackBar:` como
parâmetro. Você pede que ela seja exibida, em tempo de execução, através do **`ScaffoldMessenger`**:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Matéria salva')),
);
```

> ⛔ **API removida:** `Scaffold.of(context).showSnackBar(...)` era a forma antiga e **não funciona
> mais**. Se você encontrar isso num tutorial, o tutorial está velho. Use sempre
> `ScaffoldMessenger.of(context)`.

O motivo da mudança é concreto: se você troca de tela enquanto o `SnackBar` está visível, o
`Scaffold` antigo é destruído e a mensagem sumiria no meio. O `ScaffoldMessenger` vive **acima** dos
`Scaffold`s, então a mensagem sobrevive à troca de tela. Você aprofunda isso na
[Aula 10 — Gestos e feedback](10-gestos-e-feedback.md).

### AppBar: title, actions, leading

A `AppBar` tem três regiões, da esquerda para a direita:

```text
┌──────────────────────────────────────────────────┐
│ [leading]   title                    [actions…]  │
└──────────────────────────────────────────────────┘
```

- **`leading`** — o widget da esquerda. Se você **não** informar, o Flutter decide sozinho:
  - se o `Scaffold` tem um `drawer`, ele coloca o ícone ☰ que abre o menu;
  - senão, se dá para voltar (há outra tela empilhada abaixo), ele coloca a seta de voltar;
  - senão, fica vazio.
- **`title`** — normalmente um `Text`, mas aceita qualquer widget (um campo de busca, por exemplo).
- **`actions`** — uma `List<Widget>` à direita. Use `IconButton`. Regra prática de Material Design:
  **no máximo 3 ícones**; o resto vai para um menu de três pontinhos.

Outros parâmetros úteis: `centerTitle` (centraliza o título), `elevation` (sombra),
`backgroundColor`, `bottom` (recebe uma `TabBar`, usada no [Módulo 07](../07-navegacao-e-formularios/04-abas-e-organizacao.md)).

### SafeArea: o widget do "buraco na tela"

Celulares modernos não têm a tela inteira disponível. Existem:

- o **notch** ou a "ilha" da câmera frontal, que come um pedaço do topo;
- a **barra de status** (relógio, bateria, sinal);
- a **barra de gestos** do rodapé (aquela listrinha que substituiu os botões);
- cantos **arredondados**, que cortam conteúdo.

`SafeArea` é um widget que envolve o seu conteúdo e adiciona espaçamento automático exatamente do
tamanho desses obstáculos, em cada aparelho.

```dart
SafeArea(
  child: SeuConteudo(),
)
```

Detalhe que evita espaço duplicado: quando você usa `AppBar`, **o topo já está protegido** — a
própria `AppBar` se encarrega da barra de status. Então, no `body`, o `SafeArea` serve
principalmente para o **rodapé** e para as **laterais** (importante no modo paisagem, onde o notch
fica de lado). Você pode desligar os lados que não precisa:

```dart
SafeArea(
  top: false, // a AppBar já cuidou do topo
  child: SeuConteudo(),
)
```

---

## 💡 Analogia

Pense no `Scaffold` como a **planta baixa de um apartamento**: já vem com os cômodos definidos. Você
não decide onde fica a porta; decide **o que coloca em cada cômodo**. A `AppBar` é a porta de entrada
com a plaquinha do número; o `body` é a sala, onde a vida acontece; o `floatingActionButton` é o
interruptor principal, no lugar mais alcançável; o `drawer` é o armário embutido, que só aparece
quando você puxa.

Onde a analogia **quebra**: num apartamento os cômodos são fixos. No Flutter, se você não quiser nada
disso, pode usar um `Container` puro como raiz da tela. O `Scaffold` é uma conveniência forte, não uma
obrigação.

---

## 🧪 Exemplo mínimo

A menor tela possível com `Scaffold`:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: TelaMinima()));

class TelaMinima extends StatelessWidget {
  const TelaMinima({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foco')),
      body: const Center(child: Text('Olá, layout!')),
    );
  }
}
```

São 14 linhas e você já tem: barra superior com título na cor do tema, fundo correto, texto centrado
e comportamento adequado ao girar a tela. Fazer isso "na mão" levaria dezenas de linhas.

---

## 📱 Aplicando no Flutter

### Passo 1 — Crie o projeto do módulo

Abra o PowerShell na pasta onde você guarda seus estudos e rode:

```powershell
flutter create foco_ui
```

Esse comando cria a pasta `foco_ui` com o app de contador de exemplo. Entre nela e abra no VS Code:

```powershell
cd foco_ui
code .
```

> 🪟 **Windows sem Android SDK?** Sem problema neste módulo. Rode `flutter run -d windows` (abre como
> programa de Windows) ou `flutter run -d chrome` (abre no navegador). O *hot reload* funciona nos
> dois. Para ver a lista de aparelhos disponíveis: `flutter devices`.

### Passo 2 — Crie a estrutura de pastas

Dentro de `lib/`, crie as pastas que vão acompanhar o módulo inteiro:

```powershell
mkdir lib\features\materias\presentation
```

Essa organização (`features/<assunto>/presentation`) é a mesma do projeto final; você já começa
praticando a arquitetura definida em [05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md).

### Passo 3 — Entenda o que vamos montar

A tela inicial do **Foco** tem quatro seções: **Hoje**, **Matérias**, **Trilhas** e **Ajustes**.
Nesta aula montamos o **esqueleto completo** dessa tela: barra superior com ações, menu lateral,
botão de ação principal, barra de navegação inferior e um `body` que ainda é só um texto — o
conteúdo real entra nas próximas aulas.

Repare no uso de `NavigationBar`. No Material 3, `NavigationBar` é o widget recomendado para a
navegação inferior; ele vai no slot `bottomNavigationBar` do `Scaffold` (o nome do slot continua o
mesmo, o widget que você coloca lá é que mudou).

---

## 💻 Código completo

> **Arquivo:** `lib/main.dart`
> **Como executar:** `flutter run -d windows`

```dart
import 'package:flutter/material.dart';

import 'features/materias/presentation/home_screen.dart';

void main() {
  runApp(const FocoUiApp());
}

/// Widget raiz do aplicativo.
class FocoUiApp extends StatelessWidget {
  const FocoUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      ),
      home: const HomeScreen(),
    );
  }
}
```

> **Arquivo:** `lib/features/materias/presentation/home_screen.dart`
> **Como executar:** `flutter run -d windows`

```dart
import 'package:flutter/material.dart';

/// Tela inicial do Foco: o esqueleto de quatro seções.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Índice da aba selecionada na barra inferior.
  int _abaAtual = 0;

  static const List<String> _titulos = <String>[
    'Hoje',
    'Matérias',
    'Trilhas',
    'Ajustes',
  ];

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _trocarAba(int indice) {
    setState(() {
      _abaAtual = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_abaAtual]),
        actions: <Widget>[
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search),
            onPressed: () => _mostrarMensagem('Busca chega na Aula 9'),
          ),
          IconButton(
            tooltip: 'Estatísticas',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => _mostrarMensagem('Estatísticas chegam no projeto final'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4F46E5)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Foco',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.today_outlined),
              title: const Text('Sessão de estudo'),
              onTap: () {
                Navigator.pop(context); // fecha o menu lateral
                _mostrarMensagem('Cronômetro chega no projeto final');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Sobre o Foco'),
              onTap: () {
                Navigator.pop(context);
                _mostrarMensagem('Laboratório de UI do módulo 06');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: Text(
            'Seção: ${_titulos[_abaAtual]}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarMensagem('Formulário de matéria chega no Módulo 07'),
        icon: const Icon(Icons.add),
        label: const Text('Nova matéria'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: _trocarAba,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoje',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Matérias',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Trilhas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
```

Rode e confira:

```powershell
flutter run -d windows
```

Você deve ver: barra superior escrita **Hoje**, ícone ☰ à esquerda, lupa e gráfico à direita, texto
"Seção: Hoje" no meio, botão **Nova matéria** flutuando e quatro abas embaixo. Clicar numa aba muda
o título **e** o texto do meio. Clicar na lupa faz subir uma mensagem que some sozinha.

---

## 🔍 Explicando o código

**`runApp(const FocoUiApp())`** — coloca o widget raiz na árvore e começa a desenhar. Já visto em
[05 — main, runApp e a árvore de widgets](../05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md).

**`debugShowCheckedModeBanner: false`** — remove a faixa cinza "DEBUG" do canto superior direito.
Ela só aparece em modo de depuração; desligar deixa as capturas de tela limpas.

**`ColorScheme.fromSeed(seedColor: ...)`** — gera um conjunto completo e harmônico de cores a partir
de **uma** cor. É o coração do Material 3; a [Aula 7](07-cores-temas-modo-escuro.md) é inteira sobre
isso. Por enquanto, aceite que essa linha define a paleta do app.

**`StatefulWidget` + `_abaAtual`** — a aba selecionada é um dado que **muda com o tempo**, então
precisa viver num `State`. O `setState` dentro de `_trocarAba` avisa o Flutter: "esse valor mudou,
redesenhe esta parte da árvore".

**`static const List<String> _titulos`** — a lista é `static` porque é a mesma para todas as
instâncias, e `const` porque é conhecida em tempo de compilação. Com `const`, essa lista é criada
**uma única vez** durante toda a execução do programa
([02 — var, final, const](../02-dart-basico/03-var-final-const.md)).

**`ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(...)`** — o `..` é o
*operador de cascata* do Dart: chama vários métodos **no mesmo objeto** sem repetir o nome dele.
Aqui: esconda a mensagem atual (se houver) e mostre a nova. Sem o `hideCurrentSnackBar`, cliques
rápidos empilham mensagens e o usuário espera uma fila inteira.

**`behavior: SnackBarBehavior.floating`** — faz a barra "flutuar" com cantos arredondados e margem,
em vez de ficar colada na base. É o visual do Material 3.

**`Drawer` + `ListView(padding: EdgeInsets.zero)`** — o `ListView` já vem com um espaçamento próprio
no topo; `EdgeInsets.zero` remove esse espaço para que o `DrawerHeader` encoste no topo da tela.

**`Navigator.pop(context)` dentro do `onTap`** — o menu lateral é, tecnicamente, uma tela empilhada
por cima. `pop` é o que o fecha. Sem essa linha, você toca no item e o menu continua aberto. A pilha
do `Navigator` é o assunto do [Módulo 07](../07-navegacao-e-formularios/01-navigator-a-pilha.md).

**`Theme.of(context).textTheme.titleLarge`** — pega o estilo de texto "título grande" definido pelo
tema, em vez de chutar um tamanho de fonte. É o assunto da [Aula 2](02-texto-tipografia-icones.md).

**`SafeArea(top: false, ...)`** — protege laterais e rodapé; o topo é responsabilidade da `AppBar`.

**`tooltip:` em cada `IconButton`** — texto que aparece ao manter o dedo/mouse sobre o ícone. Não é
enfeite: é o que um **leitor de tela** anuncia para uma pessoa cega. Ícone sem `tooltip` é um botão
mudo.

---

## 🤖🍎 Android × iOS

O mesmo `Scaffold` produz resultados **fisicamente diferentes** em cada plataforma:

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Alinhamento do `title` da `AppBar` | À **esquerda** | **Centralizado** (o Flutter detecta a plataforma e centraliza) |
| Ícone de voltar automático | Seta reta `←` | Chevron `‹`, mais fino |
| Gesto para voltar | Botão/gesto do sistema, tratado pelo Android | **Arrastar da borda esquerda** para dentro — o Flutter imita isso automaticamente |
| Abrir o `drawer` por arrasto | Arrastar da borda esquerda | Conflita com o gesto de voltar; por isso apps iOS usam menos `drawer` e mais abas |
| Barra de status | Altura fixa menor | Varia conforme o modelo (notch / ilha dinâmica) |

Se quiser o mesmo alinhamento nas duas plataformas, force com `centerTitle: true` ou
`centerTitle: false` na `AppBar`.

> 🍎 **No Windows você consegue ler e entender tudo isso, mas não consegue ver o resultado num
> iPhone.** Compilar e rodar em iOS exige macOS com Xcode. O que você **pode** fazer agora: rodar em
> Android ou em `-d windows` e conferir a aparência. O processo completo de iOS está em
> [16 — Por que exige macOS](../16-build-ios/01-por-que-exige-macos.md).

---

## ⚠️ Erros comuns

**1. `No Scaffold widget found` / `ScaffoldMessenger.of() called with a context that does not contain a Scaffold`**

Acontece quando você chama `ScaffoldMessenger.of(context)` usando o `context` do widget que
**criou** o `Scaffold`, e não de um widget **abaixo** dele. No nosso código isso não acontece porque a
chamada está em um **método do `State`**, executado depois que a árvore já foi montada. Se precisar
resolver dentro do `build`, envolva com `Builder`:

```dart
body: Builder(
  builder: (BuildContext contextInterno) => FilledButton(
    onPressed: () => ScaffoldMessenger.of(contextInterno).showSnackBar(
      const SnackBar(content: Text('Funciona')),
    ),
    child: const Text('Mostrar'),
  ),
),
```

**2. Usar `Scaffold.of(context).showSnackBar(...)`** — API removida. Use `ScaffoldMessenger`.

**3. Dois `Scaffold` aninhados sem necessidade** — cada tela tem **um** `Scaffold`. Aninhar cria duas
barras superiores, duas áreas de `SnackBar` e comportamento imprevisível do teclado.

**4. `FloatingActionButton` escondendo o último item da lista** — o botão flutua *por cima* do
`body`. Em listas, adicione espaço no fim (você faz isso na [Aula 9](09-listas-e-rolagem.md)).

**5. Esquecer `SafeArea` e o conteúdo sumir atrás da barra de gestos** — típico de tela **sem**
`AppBar`: o título encosta no relógio do celular. Teste sempre num aparelho com notch, ou no
emulador, e não só no Windows (onde não há notch nenhum).

**6. `NavigationDestination` com quantidade diferente de abas do que o código espera** — se
`selectedIndex` for maior ou igual ao número de `destinations`, o app quebra em tempo de execução.
O `_titulos` e o `destinations` precisam ter o mesmo tamanho.

---

## 🛠️ Exercício guiado

Vamos acrescentar um **`endDrawer`** (menu lateral da direita) com um filtro, e uma terceira ação na
`AppBar` que o abre.

**Passo 1.** Em `home_screen.dart`, dentro do `Scaffold`, logo depois do `drawer:`, acrescente:

```dart
endDrawer: Drawer(
  child: SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Filtrar por', style: TextStyle(fontSize: 20)),
        ),
        ListTile(
          leading: const Icon(Icons.sort_by_alpha),
          title: const Text('Nome'),
          onTap: () {
            Navigator.pop(context);
            _mostrarMensagem('Ordenando por nome');
          },
        ),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('Minutos estudados'),
          onTap: () {
            Navigator.pop(context);
            _mostrarMensagem('Ordenando por minutos');
          },
        ),
      ],
    ),
  ),
),
```

O `Column` acima ainda vai ser dissecado na [Aula 4](04-row-column-expanded.md); por ora, leia como
"empilhe estes widgets de cima para baixo".

**Passo 2.** Adicione a ação que abre esse menu. Atenção: `Scaffold.of(context)` **pode** ser usado
para abrir *drawers* — o que foi removido foi apenas o `showSnackBar`. Como estamos num método do
`State`, use a chave global mais simples: o próprio `Scaffold` do contexto atual. Acrescente ao fim
da lista `actions`:

```dart
Builder(
  builder: (BuildContext contextInterno) => IconButton(
    tooltip: 'Filtrar',
    icon: const Icon(Icons.filter_list),
    onPressed: () => Scaffold.of(contextInterno).openEndDrawer(),
  ),
),
```

**Passo 3.** Salve. O *hot reload* aplica na hora. Toque no ícone de filtro.

**O que observar:** ao adicionar o `endDrawer`, o Flutter **não** coloca ícone automático à direita
(diferente do `drawer`, que ganha o ☰ automático à esquerda). Por isso o `IconButton` é obrigatório.
E repare por que o `Builder` é necessário aqui: `Scaffold.of` precisa de um `context` que esteja
**dentro** da subárvore do `Scaffold`.

**Resultado esperado:** um painel desliza da direita com duas opções; tocar em qualquer uma fecha o
painel e mostra a mensagem correspondente.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Comece pelos exercícios de **Fixação** e pelo primeiro de **Aplicação**; eles cobrem exatamente os
slots do `Scaffold` e a `AppBar`.

---

## 🏆 Desafio opcional

Faça a `AppBar` mudar conforme a aba selecionada:

1. Na aba **Hoje**, mostre um `title` com a data de hoje formatada por extenso (use
   `DateTime.now()`; formatação completa com `intl` vem depois).
2. Na aba **Matérias**, troque o `title` por um `TextField` de busca (aparência só; a busca real vem
   na [Aula 9](09-listas-e-rolagem.md)).
3. Na aba **Ajustes**, remova todas as `actions` — tela de ajustes não precisa de lupa.
4. Faça o `floatingActionButton` **desaparecer** nas abas Trilhas e Ajustes. Dica: o slot aceita
   `null`; use um operador condicional.

Critério de sucesso: `flutter analyze` sem avisos e nenhuma exceção ao trocar de aba rapidamente.

---

## 📌 Resumo

- `Scaffold` é a planta baixa da tela: define **onde** as coisas vão, não o que são.
- Slots principais: `appBar`, `body`, `floatingActionButton`, `bottomNavigationBar`, `drawer`,
  `endDrawer`.
- `SnackBar` **não** é um slot: chama-se `ScaffoldMessenger.of(context).showSnackBar(...)`.
  `Scaffold.of(context).showSnackBar` foi removido.
- `AppBar` = `leading` + `title` + `actions`. O `leading` é preenchido automaticamente com ☰ (se há
  `drawer`) ou com a seta de voltar (se há tela abaixo na pilha).
- `SafeArea` protege o conteúdo do notch, da barra de status e da barra de gestos. Com `AppBar`, o
  topo já está protegido: use `top: false`.
- 🤖 Android alinha o título à esquerda; 🍎 iOS centraliza. O Flutter faz isso sozinho.
- Todo `IconButton` precisa de `tooltip` — é acessibilidade, não enfeite.

---

## ☑️ Checklist de domínio

- [ ] Listo os seis slots principais do `Scaffold` e digo para que serve cada um.
- [ ] Explico por que `SnackBar` não é um parâmetro do `Scaffold`.
- [ ] Escrevo a chamada correta de `ScaffoldMessenger` de memória.
- [ ] Sei quem preenche o `leading` da `AppBar` quando eu não informo.
- [ ] Explico o que o `SafeArea` resolve, citando dois obstáculos físicos reais.
- [ ] Criei o projeto `foco_ui` e ele roda com `flutter run -d windows`.
- [ ] Minha `HomeScreen` troca de aba, abre o menu lateral e exibe `SnackBar`.
- [ ] Fiz o exercício guiado e o `endDrawer` abre pelo ícone de filtro.
- [ ] `flutter analyze` passa sem nenhum aviso no `foco_ui`.

---

## 📚 Referências oficiais

- [API — `Scaffold`](https://api.flutter.dev/flutter/material/Scaffold-class.html)
- [API — `AppBar`](https://api.flutter.dev/flutter/material/AppBar-class.html)
- [API — `ScaffoldMessenger`](https://api.flutter.dev/flutter/material/ScaffoldMessenger-class.html)
- [API — `SafeArea`](https://api.flutter.dev/flutter/widgets/SafeArea-class.html)
- [API — `NavigationBar`](https://api.flutter.dev/flutter/material/NavigationBar-class.html)
- [API — `Drawer`](https://api.flutter.dev/flutter/material/Drawer-class.html)
- [Cookbook — Exibir um SnackBar](https://docs.flutter.dev/cookbook/design/snackbars)
- [Material 3 — Navigation bar](https://m3.material.io/components/navigation-bar/overview)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — Texto, tipografia e ícones](02-texto-tipografia-icones.md) |
