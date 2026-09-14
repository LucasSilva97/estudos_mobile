# Aula 1 — O problema do estado

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Definir **estado** e distinguir estado **local** de estado **compartilhado**.
- Demonstrar, com código que roda, por que `setState` não resolve estado compartilhado.
- Reconhecer e nomear o **_prop drilling_** (passar dado e *callback* por vários níveis de widget).
- Listar os **quatro sintomas concretos** de um app que precisa de gerenciamento de estado.
- Medir *rebuilds* com `debugPrint` e ver, no terminal, widgets reconstruídos à toa.

## ✅ Pré-requisitos

- `StatefulWidget`, `State` e `setState` — [Módulo 05, Aula 5](../05-introducao-ao-flutter/05-statefulwidget-e-setstate.md).
- `BuildContext` e árvore de widgets — [Módulo 05, Aula 7](../05-introducao-ao-flutter/07-buildcontext.md).
- `Scaffold`, `Column`, `ListView` — [Módulo 06](../06-widgets-e-layouts/README.md).
- Funções como valor (*callbacks*) — [Módulo 02, Aula 7](../02-dart-basico/07-funcoes-em-dart.md).

## 📖 Conceito

### O que é estado

**Estado** é toda informação que o seu app guarda, que **pode mudar enquanto ele roda** e cuja
mudança precisa aparecer na tela.

| Informação | É estado? | Por quê |
|---|---|---|
| Minutos estudados hoje | ✅ Sim | Muda a cada sessão registrada e aparece em duas telas |
| Lista de matérias | ✅ Sim | Cresce, encolhe e é exibida em três lugares |
| Meta diária em minutos | ✅ Sim | A pessoa usuária edita nos ajustes |
| O texto fixo `'Foco'` no `AppBar` | ❌ Não | Nunca muda; é conteúdo, não estado |

### Estado local × estado compartilhado

> **Estado local** — só interessa a **um** widget. Exemplo: se um campo de senha está com o texto
> visível ou escondido. Ninguém fora daquele widget precisa saber disso.
>
> **Estado compartilhado** — dois ou mais widgets, muitas vezes em telas diferentes, precisam ler
> ou escrever o **mesmo** dado. Exemplo: os minutos estudados hoje.

Essa distinção é a mais importante da aula: **`setState` resolve perfeitamente estado local** —
não troque `setState` por biblioteca nenhuma quando o dado não sai do widget — mas **não resolve
estado compartilhado**, e é aí que os apps quebram.

### Por que `setState` não alcança o vizinho

```dart
setState(() {
  _minutosHoje += 25;
});
```

`setState` é um método **do objeto `State`**. Ele faz uma coisa só: marca **aquele** elemento da
árvore como sujo e pede ao Flutter que chame o `build` **dele** de novo — e, por consequência, o
`build` de tudo que esse `build` constrói abaixo. Isso significa, literalmente:

1. Um widget **não consegue** chamar o `setState` de outro widget: o método pertence a um `State`
   específico e é protegido.
2. Um widget **não enxerga** o campo `_minutosHoje` de um `State` que não é o dele.
3. A única direção em que um dado flui de graça no Flutter é **de cima para baixo**, pelo
   construtor.

Conclusão: se dois widgets precisam do mesmo dado, esse dado tem que estar **acima dos dois** na
árvore. E aí começa o problema desta aula.

### O problema concreto: três telas, um dado

O app **Foco** tem três abas:

```text
Foco
├── Aba "Hoje"      → mostra os minutos de hoje e tem os botões de registrar sessão
├── Aba "Matérias"  → lista as matérias e mostra quantos minutos você já fez hoje
└── Aba "Ajustes"   → mostra quanto falta para a meta diária (usa os minutos de hoje)
```

As três abas precisam de `minutosHoje`. Só a aba "Hoje" o altera; as outras duas só leem.

Onde esse `int` deve morar? Com o que você sabe até agora, só existe uma resposta: **no `State`
do ancestral comum das três abas**. A partir daí ele é entregue a cada aba pelo construtor, cada
aba repassa para os filhos, e os filhos para os netos.

### _Prop drilling_

> ***Prop drilling*** (literalmente "perfuração de propriedades") — passar um dado, ou uma função
> de *callback*, de construtor em construtor através de vários níveis de widgets que **não usam
> esse dado**, só para entregá-lo a um widget lá no fundo.

O sintoma visual é este: um widget intermediário recebe um parâmetro, não faz nada com ele e só
repassa. Todo parâmetro nessa situação é **ruído**.

> **_Callback_** — uma função que você passa como argumento para outro objeto, para que ele a
> chame quando algo acontecer. Em Dart, funções são valores
> ([Módulo 02, Aula 7](../02-dart-basico/07-funcoes-em-dart.md)). É assim que um widget filho
> "avisa" o pai: o pai entrega a função, o filho a executa.

## 💡 Analogia

Um prédio de quatro andares. A informação "minutos estudados hoje" está no quarto andar, com a
diretoria; quem precisa dela é o estagiário do térreo. Não há elevador nem telefone: a diretoria
fala com o gerente do terceiro, que fala com o supervisor do segundo, que fala com o assistente
do primeiro, que fala com o estagiário. Três pessoas ouviram um número que não lhes serve para
nada — e, quando o estagiário quer **registrar** uma sessão, o recado sobe de volta pelo mesmo
caminho. Se um quinto setor passa a precisar do número, você abre **outro** corredor de repasses.

## 🧪 Exemplo mínimo

O menor caso possível de *prop drilling*: quatro níveis para um botão.

```dart
class Nivel0 extends StatefulWidget {
  const Nivel0({super.key});
  @override
  State<Nivel0> createState() => _Nivel0State();
}

class _Nivel0State extends State<Nivel0> {
  int _contador = 0;
  @override
  Widget build(BuildContext context) =>
      Nivel1(valor: _contador, aoTocar: () => setState(() => _contador++));
}

// Nível 1 — NÃO usa nada disso; só repassa. O Nível 2 é uma cópia exata dele,
// trocando `Nivel2(...)` por `Nivel3(...)`: transporte puro, duas vezes.
class Nivel1 extends StatelessWidget {
  const Nivel1({required this.valor, required this.aoTocar, super.key});
  final int valor;
  final VoidCallback aoTocar;
  @override
  Widget build(BuildContext context) => Nivel2(valor: valor, aoTocar: aoTocar);
}

// Nível 3 — finalmente usa.
class Nivel3 extends StatelessWidget {
  const Nivel3({required this.valor, required this.aoTocar, super.key});
  final int valor;
  final VoidCallback aoTocar;
  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: aoTocar, child: Text('Sessões: $valor'));
}
```

> **`VoidCallback`** — apelido do Flutter para `void Function()`: função sem parâmetros e sem
> retorno. Quando o *callback* recebe argumento, o Flutter oferece `ValueChanged<T>`
> (`void Function(T)`).

`Nivel1` e `Nivel2` existem **só** para repassar. Multiplique isso por cinco telas e oito dados.

## 📱 Aplicando no Flutter

Crie o projeto que vai acompanhar o módulo inteiro:

```powershell
flutter create foco_estado
cd foco_estado
```

> 🪟 **Windows.** Se o SDK do Android ainda não estiver instalado, rode em
> `flutter run -d windows` ou `flutter run -d chrome`. O assunto do módulo é estado, e estado
> funciona igual em todas as plataformas. Instale o emulador depois, seguindo o
> [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

> **`IndexedStack`** — empilha todos os filhos e exibe apenas o de índice `index`. Diferente de
> trocar o widget do `body`, ele **mantém vivo** o estado de todas as abas.
>
> **`NavigationBar`** — a barra inferior de navegação do **Material 3**, sucessora do
> `BottomNavigationBar` do Material 2.

Ao digitar, repare em quantos widgets recebem `minutosHoje` e `aoRegistrar` sem precisar deles.

## 💻 Código completo

> **Arquivo:** `lib/main.dart`
> **Como executar:** `flutter run` (ou `flutter run -d windows`)

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const AppFoco());
}

class AppFoco extends StatelessWidget {
  const AppFoco({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF3F51B5)),
      home: const CascaFoco(),
    );
  }
}

/// Ancestral comum das três abas. Todo o estado do app mora aqui.
class CascaFoco extends StatefulWidget {
  const CascaFoco({super.key});

  @override
  State<CascaFoco> createState() => _CascaFocoState();
}

class _CascaFocoState extends State<CascaFoco> {
  int _abaAtual = 0;
  int _minutosHoje = 0;
  int _metaDiaria = 90;
  List<String> _materias = const <String>['Dart', 'Flutter', 'Git'];

  void _registrarSessao(int minutos) => setState(() => _minutosHoje += minutos);
  void _alterarMeta(int novaMeta) => setState(() => _metaDiaria = novaMeta);
  void _adicionarMateria(String nome) =>
      setState(() => _materias = <String>[..._materias, nome]);

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CascaFoco');

    // Note o tamanho da lista de argumentos. Ela só cresce.
    final List<Widget> abas = <Widget>[
      AbaHoje(
        minutosHoje: _minutosHoje,
        metaDiaria: _metaDiaria,
        aoRegistrar: _registrarSessao,
      ),
      AbaMaterias(
        materias: _materias,
        minutosHoje: _minutosHoje,
        aoAdicionar: _adicionarMateria,
      ),
      AbaAjustes(
        metaDiaria: _metaDiaria,
        minutosHoje: _minutosHoje,
        aoAlterarMeta: _alterarMeta,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Foco')),
      body: IndexedStack(index: _abaAtual, children: abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (int indice) => setState(() => _abaAtual = indice),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Hoje'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Matérias'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
    );
  }
}

// --- Nível 1 da perfuração -------------------------------------------------
class AbaHoje extends StatelessWidget {
  const AbaHoje({
    required this.minutosHoje,
    required this.metaDiaria,
    required this.aoRegistrar,
    super.key,
  });

  final int minutosHoje;
  final int metaDiaria;
  final ValueChanged<int> aoRegistrar;

  @override
  Widget build(BuildContext context) {
    debugPrint('build: AbaHoje');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CartaoResumo(
        minutosHoje: minutosHoje,
        metaDiaria: metaDiaria,
        aoRegistrar: aoRegistrar, // <- não usa; só repassa
      ),
    );
  }
}

// --- Nível 2 ---------------------------------------------------------------
class CartaoResumo extends StatelessWidget {
  const CartaoResumo({
    required this.minutosHoje,
    required this.metaDiaria,
    required this.aoRegistrar,
    super.key,
  });

  final int minutosHoje;
  final int metaDiaria;
  final ValueChanged<int> aoRegistrar;

  @override
  Widget build(BuildContext context) {
    debugPrint('build: CartaoResumo');
    final double progresso =
        metaDiaria == 0 ? 0 : (minutosHoje / metaDiaria).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Hoje', style: Theme.of(context).textTheme.titleMedium),
            Text('$minutosHoje min',
                style: Theme.of(context).textTheme.displaySmall),
            Text('Meta: $metaDiaria min'),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progresso),
            const SizedBox(height: 16),
            LinhaDeBotoes(aoRegistrar: aoRegistrar), // <- continua repassando
          ],
        ),
      ),
    );
  }
}

// --- Nível 3 ---------------------------------------------------------------
class LinhaDeBotoes extends StatelessWidget {
  const LinhaDeBotoes({required this.aoRegistrar, super.key});

  final ValueChanged<int> aoRegistrar;

  @override
  Widget build(BuildContext context) {
    debugPrint('build: LinhaDeBotoes');
    return Row(
      children: <Widget>[
        Expanded(child: BotaoSessao(minutos: 25, aoRegistrar: aoRegistrar)),
        const SizedBox(width: 12),
        Expanded(child: BotaoSessao(minutos: 50, aoRegistrar: aoRegistrar)),
      ],
    );
  }
}

// --- Nível 4: finalmente alguém usa o callback ------------------------------
class BotaoSessao extends StatelessWidget {
  const BotaoSessao({required this.minutos, required this.aoRegistrar, super.key});

  final int minutos;
  final ValueChanged<int> aoRegistrar;

  @override
  Widget build(BuildContext context) {
    debugPrint('build: BotaoSessao($minutos)');
    return FilledButton(
      onPressed: () {
        aoRegistrar(minutos);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sessão de $minutos min registrada.')),
        );
      },
      child: Text('+$minutos min'),
    );
  }
}

// --- Aba Matérias ----------------------------------------------------------
class AbaMaterias extends StatelessWidget {
  const AbaMaterias({
    required this.materias,
    required this.minutosHoje,
    required this.aoAdicionar,
    super.key,
  });

  final List<String> materias;
  final int minutosHoje;
  final ValueChanged<String> aoAdicionar;

  @override
  Widget build(BuildContext context) {
    debugPrint('build: AbaMaterias');
    return Column(
      children: <Widget>[
        Text('Você já estudou $minutosHoje min hoje.'),
        Expanded(
          child: ListView.separated(
            itemCount: materias.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int i) =>
                ListTile(title: Text(materias[i])),
          ),
        ),
        FilledButton.tonal(
          onPressed: () => aoAdicionar('Matéria ${materias.length + 1}'),
          child: const Text('Adicionar matéria'),
        ),
      ],
    );
  }
}

// --- Aba Ajustes -----------------------------------------------------------
class AbaAjustes extends StatelessWidget {
  const AbaAjustes({
    required this.metaDiaria,
    required this.minutosHoje,
    required this.aoAlterarMeta,
    super.key,
  });

  final int metaDiaria;
  final int minutosHoje;
  final ValueChanged<int> aoAlterarMeta;

  @override
  Widget build(BuildContext context) {
    debugPrint('build: AbaAjustes');
    final int faltam = (metaDiaria - minutosHoje).clamp(0, metaDiaria);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Meta diária: $metaDiaria min · faltam $faltam min hoje.'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: <Widget>[
            for (final int opcao in <int>[60, 90, 120])
              OutlinedButton(
                onPressed: () => aoAlterarMeta(opcao),
                child: Text('$opcao min'),
              ),
          ],
        ),
      ],
    );
  }
}
```

Rode e toque em **+25 min**. O app funciona. Agora olhe o terminal.

## 🔍 Explicando o código

### 1. Onde o estado mora, e por que ali

`_minutosHoje`, `_metaDiaria` e `_materias` estão em `_CascaFocoState` porque `CascaFoco` é o
**ancestral comum** das três abas — não existe lugar mais baixo na árvore que alcance as três.
Não foi preferência: foi a **única** escolha possível com `setState`.

### 2. A assinatura que só cresce, e o recado que sobe

`AbaHoje` e `CartaoResumo` têm três parâmetros cada. Quando o app ganhar "sessões da semana",
"matéria favorita" e "modo escuro", cada construtor ganha mais campos: o crescimento é **linear
no número de dados multiplicado pelo número de níveis**. O dado desce por valor (`minutosHoje`);
a ordem sobe por função (`aoRegistrar`), como em `TextField.onChanged`. Nada de errado com o
padrão — o problema é a **distância** que ele percorre aqui.

### 3. `(_, _)`, e não `(_, __)`

Em `separatorBuilder: (_, _) => const Divider(height: 1)`, com `flutter_lints 6.0.0`, escrever
`(_, __)` dispara o aviso `unnecessary_underscores`: em Dart 3, `_` virou um "descarte", então
vários parâmetros podem se chamar `_` ao mesmo tempo.

### 4. `debugPrint` em vez de `print`

`print` dispara o lint `avoid_print`. `debugPrint` some no build de *release* e enfileira as
linhas para não estourar o limite de saída do Android, que **descarta** mensagens em excesso.

### 5. A prova do problema: leia o terminal

Toque uma vez em **+25 min**:

```text
flutter: build: CascaFoco
flutter: build: AbaHoje
flutter: build: CartaoResumo
flutter: build: LinhaDeBotoes
flutter: build: BotaoSessao(25)
flutter: build: BotaoSessao(50)
flutter: build: AbaMaterias
flutter: build: AbaAjustes
```

**Oito widgets reconstruídos para atualizar um número.** `AbaMaterias` e `AbaAjustes` nem estão
visíveis — estão dentro do `IndexedStack` — e mesmo assim rodaram `build`. `LinhaDeBotoes` e os
dois `BotaoSessao` não mudaram em nada e também rodaram.

Isso acontece porque `setState` invalida o `build` **inteiro** de `CascaFoco`, e esse `build`
cria objetos widget novos para toda a subárvore.

## ⚠️ Erros comuns

**1. Achar que `setState` é "ruim".**
Não é. Para estado local — um `ExpansionTile` aberto/fechado, a visibilidade de uma senha, o
índice de um carrossel — `setState` é a ferramenta certa, mais simples e sem dependência externa.
O problema é usá-lo para estado **compartilhado**.

**2. Tentar chamar o `setState` de outro widget.**
Não existe caminho: `CascaFoco.setState(...)` não compila, porque `_CascaFocoState` é privado,
você não tem a instância dele e o método é protegido.

**3. Guardar o estado em uma variável global.**

```dart
int minutosHoje = 0; // variável global — NÃO faça isso
```

Compila e "funciona": qualquer arquivo lê e escreve. Mas nada avisa a interface de que o valor
mudou, então a tela não atualiza. Você acabaria chamando `setState(() {})` vazio em algum lugar
só para forçar o redesenho — gambiarra que esconde o problema e impede teste.

**4. Colocar tudo no `State` do topo "porque resolve".**
Resolve por um tempo — é o que esta aula fez. O custo aparece em três frentes: assinaturas
gigantes, *rebuild* de tudo e impossibilidade de testar a regra sem montar a árvore.

**5. Esquecer que uma rota nova não é filha da sua aba.**
Uma tela aberta com `Navigator.push` **não** é descendente de `AbaHoje`: é filha do `Navigator`
do `MaterialApp`. Passar o dado por construtor vira "reempacotar tudo no argumento da rota".

## 🛠️ Exercício guiado

Objetivo: **provar** o *rebuild* desnecessário e sentir o custo do *prop drilling*.

**Passo 1.** Rode o app com o terminal visível:

```powershell
flutter run -d windows
```

**Passo 2.** Toque em **+25 min**, copie as linhas `build:` para um arquivo de anotações e conte
quantos widgets rodaram.

**Passo 3.** Vá para a aba **Ajustes** e toque em **120 min**. Conte de novo: `BotaoSessao`, que
não tem nada a ver com meta, foi reconstruído.

**Passo 4.** Adicione `String _materiaFavorita = 'Dart';` em `_CascaFocoState` e exiba essa
informação **dentro de `BotaoSessao`** (nível 4), envolvendo o botão em um `Tooltip`:

```dart
return Tooltip(
  message: 'Favorita: $materiaFavorita',
  child: FilledButton(/* ... o mesmo de antes ... */),
);
```

Para isso funcionar você precisa adicionar o parâmetro `materiaFavorita` em **`AbaHoje`**,
**`CartaoResumo`**, **`LinhaDeBotoes`** e **`BotaoSessao`**. Faça isso de verdade.

**Passo 5.** Conte quantas classes você teve que alterar para exibir **uma string** quatro níveis
abaixo. Anote o número: na Aula 5, o mesmo efeito vai custar **uma linha**. Confirme no fim que
`flutter analyze` não aponta nada.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

## 🏆 Desafio opcional

Escreva um **diagnóstico** deste app, como se você revisasse o código de outra pessoa. Para cada
sintoma, aponte o widget ou a linha do `lib/main.dart` que o comprova: (1) *rebuild* demais;
(2) estado perdido ao navegar (pense num `Navigator.push`); (3) lógica misturada com UI (onde
está a regra "progresso = minutos ÷ meta"?); (4) impossível testar sem montar a árvore (como
testar a regra do item 3 sem `WidgetTester`?). Guarde o texto: na Aula 9 você reescreve o mesmo
app e confere se os quatro sintomas sumiram.

## 📌 Resumo

- **Estado** é informação que muda e precisa aparecer na tela: **local** (um widget) ou
  **compartilhado** (vários widgets, às vezes em telas diferentes).
- `setState` marca **um** `State` como sujo. Não alcança widgets vizinhos nem rotas diferentes.
  Para estado local é a escolha certa; para compartilhado, não serve.
- Dado desce por **construtor**; ordem sobe por ***callback***. Quando isso atravessa níveis que
  não usam o dado, chama-se ***prop drilling***.
- Os **quatro sintomas**: (1) *rebuild* demais, inclusive de widgets invisíveis; (2) estado
  perdido ao navegar; (3) regra de negócio misturada com a UI; (4) impossibilidade de testar a
  lógica sem montar a árvore de widgets.
- Este app funciona **hoje**. O custo é de manutenção, e ele cresce com dados × níveis.

## ☑️ Checklist de domínio

- [ ] Sei definir estado e dar dois exemplos de estado local e dois de compartilhado.
- [ ] Explico por que `setState` não consegue atualizar um widget vizinho.
- [ ] Sei o que é *prop drilling* e reconheço um parâmetro que só serve para repasse.
- [ ] Rodei o app e vi, no terminal, os 8 `build:` disparados por um único toque.
- [ ] Fiz o Passo 4 do exercício guiado e sei quantas classes precisei tocar.
- [ ] Cito os 4 sintomas de cabeça.
- [ ] `flutter analyze` não aponta nenhum aviso no meu `lib/main.dart`.

## 📚 Referências oficiais

- [Flutter — State management: introduction](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)
- [Flutter — StatefulWidget (API)](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)
- [Flutter — NavigationBar (Material 3)](https://api.flutter.dev/flutter/material/NavigationBar-class.html)
- [Flutter — IndexedStack (API)](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Elevação de estado](02-elevacao-de-estado.md) |
