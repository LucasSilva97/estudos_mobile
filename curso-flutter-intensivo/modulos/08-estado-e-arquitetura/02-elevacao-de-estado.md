# Aula 2 — Elevação de estado

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Aplicar a **elevação de estado** (*lifting state up*): mover o dado para o ancestral comum.
- Implementar o fluxo oficial do Flutter: **valor desce, *callback* sobe**.
- Agrupar vários campos em um **objeto de estado imutável** com `copyWith` para encolher as
  assinaturas dos construtores.
- Identificar os **cinco pontos concretos** em que essa técnica quebra.
- Provar, com `Navigator.push`, que uma rota nova **não** enxerga o estado elevado.

## ✅ Pré-requisitos

- [Aula 1 — O problema do estado](01-o-problema-do-estado.md), com o projeto `foco_estado` criado.
- Classes, construtores nomeados e `const` — [Módulo 03, Aula 2](../03-dart-intermediario/02-construtores.md).
- `Navigator.push` e rotas — [Módulo 07, Aula 1](../07-navegacao-e-formularios/01-navigator-a-pilha.md).
- `final` e imutabilidade — [Módulo 02, Aula 3](../02-dart-basico/03-var-final-const.md).

## 📖 Conceito

### O que é elevar o estado

> **Elevação de estado** (*lifting state up*) — quando dois ou mais widgets precisam do mesmo
> dado, você **sobe** esse dado até o widget que é ancestral comum dos dois e, de lá, o distribui
> para baixo. Nenhum irmão guarda o dado; só o ancestral guarda.

É a técnica que o próprio time do Flutter recomenda como primeira resposta, antes de qualquer
biblioteca. E é a técnica que a Aula 1 já usou sem dar nome a ela.

A regra tem três partes: **encontre o ancestral comum** (suba na árvore até o primeiro widget que
contém todos os interessados abaixo dele); **mova o campo para o `State` desse ancestral**, que
passa a ser a fonte única da verdade; e **faça o valor descer por parâmetro e a ordem subir por
*callback***.

> **Fonte única da verdade** (*single source of truth*) — a garantia de que um dado existe em
> **um** lugar só. Se `minutosHoje` estivesse copiado em dois `State` diferentes, os dois
> poderiam divergir e a tela mostraria números contraditórios.

### Valor desce, *callback* sobe

Esse é o padrão que o Flutter usa nos próprios widgets. Olhe o `Switch`:

```dart
Switch(
  value: _modoEscuro,                                  // valor DESCE
  onChanged: (bool novo) => setState(() => _modoEscuro = novo), // ordem SOBE
)
```

O `Switch` **não guarda** se está ligado. Ele desenha o que recebe em `value` e, quando tocado,
chama `onChanged` pedindo que alguém acima decida. Se o pai não chamar `setState`, o interruptor
não se mexe — porque ele não tem estado próprio.

> **Widget controlado** — widget que não guarda o próprio estado; ele recebe o valor pronto e
> delega a decisão de mudar. `Switch`, `Checkbox`, `Radio` e `Slider` são todos controlados.
> Essa é a razão pela qual, no Flutter, o fluxo de dados é **unidirecional**: para baixo.

### O truque que salva a assinatura: um objeto de estado

Na Aula 1, cada aba recebia três parâmetros soltos (`minutosHoje`, `metaDiaria`, `materias`).
Elevar o estado não resolve isso sozinho — mas agrupar os campos em **um objeto imutável**
resolve boa parte: `AbaHoje(estado: _estado, aoRegistrar: _registrarSessao)` tem dois parâmetros
estáveis, em vez de quatro que só crescem.

> **Objeto imutável** — objeto cujos campos são todos `final`: depois de construído, ele nunca
> muda. Para "alterar" um campo, você cria uma **cópia** com o valor novo. O método que faz isso,
> por convenção em Dart, chama-se `copyWith`
> ([Módulo 03, Aula 1](../03-dart-intermediario/01-classes-e-objetos.md)).

Por que imutável? Porque o Flutter compara objetos para decidir o que redesenhar. Se você mudar
um campo por dentro do mesmo objeto, o widget continua vendo **a mesma referência** e pode nem
perceber que algo mudou. Trocar o objeto inteiro deixa a mudança explícita. Essa ideia volta com
força na Aula 6.

## 💡 Analogia

Duas pessoas na mesma sala precisam saber o placar de um jogo. A solução ruim: cada uma anota no
próprio caderno — em cinco minutos os cadernos divergem. A solução da elevação de estado: existe
**um** quadro branco na parede e só o professor escreve nele; quem quer saber o placar olha o
quadro, e quem quer mudá-lo levanta a mão e pede ao professor — esse pedido é o *callback*.

O limite da analogia é exatamente o limite da técnica: só funciona para quem está **na mesma
sala**. Quem sair para o corredor (uma rota nova) não enxerga mais o quadro.

## 🧪 Exemplo mínimo

Dois widgets irmãos: um mostra, o outro altera. Antes da elevação, isso é impossível.

```dart
class Termometro extends StatefulWidget {
  const Termometro({super.key});
  @override
  State<Termometro> createState() => _TermometroState();
}

class _TermometroState extends State<Termometro> {
  // 1. O estado subiu para o ancestral comum dos dois irmãos.
  int _minutos = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // 2. O valor DESCE para o irmão que só lê.
        Mostrador(minutos: _minutos),
        // 3. A ordem SOBE do irmão que só escreve.
        Controles(aoSomar: (int m) => setState(() => _minutos += m)),
      ],
    );
  }
}

class Mostrador extends StatelessWidget {
  const Mostrador({required this.minutos, super.key});
  final int minutos;
  @override
  Widget build(BuildContext context) => Text('$minutos min');
}

class Controles extends StatelessWidget {
  const Controles({required this.aoSomar, super.key});
  final ValueChanged<int> aoSomar;
  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: () => aoSomar(25), child: const Text('+25'));
}
```

`Mostrador` e `Controles` são `StatelessWidget` — nenhum dos dois guarda nada. Toda a verdade
está em `_TermometroState`. Esse é o formato-alvo.

## 📱 Aplicando no Flutter

Agora vamos refatorar o `foco_estado` da Aula 1 com duas melhorias:

1. Criar a classe imutável `EstadoFoco`, que junta `minutosHoje`, `metaDiaria` e `materias`, e
   ainda carrega as **regras derivadas** (`progresso` e `faltam`) que antes estavam soltas dentro
   do `build` de `CartaoResumo`.
2. Passar esse objeto único para as abas, em vez de campos soltos.

Repare no ganho e, principalmente, no que **não** muda: o *prop drilling* continua existindo, só
que com uma caixa em vez de três embrulhos.

## 💻 Código completo

> **Arquivo:** `lib/main.dart` (substitui o da Aula 1)
> **Como executar:** `flutter run` (ou `flutter run -d windows`)

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const AppFoco());
}

/// Objeto de estado imutável: a "fonte única da verdade" do app.
@immutable
class EstadoFoco {
  const EstadoFoco({
    this.minutosHoje = 0,
    this.metaDiaria = 90,
    this.materias = const <String>['Dart', 'Flutter', 'Git'],
  });

  final int minutosHoje;
  final int metaDiaria;
  final List<String> materias;

  // Regras derivadas moram JUNTO do dado, não dentro do build.
  double get progresso =>
      metaDiaria == 0 ? 0 : (minutosHoje / metaDiaria).clamp(0.0, 1.0);

  int get faltam => (metaDiaria - minutosHoje).clamp(0, metaDiaria);

  EstadoFoco copyWith({int? minutosHoje, int? metaDiaria, List<String>? materias}) {
    return EstadoFoco(
      minutosHoje: minutosHoje ?? this.minutosHoje,
      metaDiaria: metaDiaria ?? this.metaDiaria,
      materias: materias ?? this.materias,
    );
  }
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

/// Ancestral comum: aqui mora TODO o estado elevado.
class CascaFoco extends StatefulWidget {
  const CascaFoco({super.key});

  @override
  State<CascaFoco> createState() => _CascaFocoState();
}

class _CascaFocoState extends State<CascaFoco> {
  int _abaAtual = 0;
  EstadoFoco _estado = const EstadoFoco();

  void _registrarSessao(int minutos) {
    setState(() {
      _estado = _estado.copyWith(minutosHoje: _estado.minutosHoje + minutos);
    });
  }

  void _alterarMeta(int novaMeta) {
    setState(() => _estado = _estado.copyWith(metaDiaria: novaMeta));
  }

  void _adicionarMateria(String nome) {
    setState(() {
      _estado = _estado.copyWith(
        materias: <String>[..._estado.materias, nome],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> abas = <Widget>[
      AbaHoje(estado: _estado, aoRegistrar: _registrarSessao),
      AbaMaterias(estado: _estado, aoAdicionar: _adicionarMateria),
      AbaAjustes(estado: _estado, aoAlterarMeta: _alterarMeta),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Foco')),
      body: IndexedStack(index: _abaAtual, children: abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (int i) => setState(() => _abaAtual = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Hoje'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Matérias'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class AbaHoje extends StatelessWidget {
  const AbaHoje({required this.estado, required this.aoRegistrar, super.key});

  final EstadoFoco estado;
  final ValueChanged<int> aoRegistrar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CartaoResumo(estado: estado, aoRegistrar: aoRegistrar),
    );
  }
}

class CartaoResumo extends StatelessWidget {
  const CartaoResumo({required this.estado, required this.aoRegistrar, super.key});

  final EstadoFoco estado;
  final ValueChanged<int> aoRegistrar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Hoje', style: Theme.of(context).textTheme.titleMedium),
            Text('${estado.minutosHoje} min',
                style: Theme.of(context).textTheme.displaySmall),
            Text('Meta: ${estado.metaDiaria} min · faltam ${estado.faltam} min'),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: estado.progresso),
            const SizedBox(height: 16),
            LinhaDeBotoes(aoRegistrar: aoRegistrar),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const TelaSessao()),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Abrir sessão em outra tela'),
            ),
          ],
        ),
      ),
    );
  }
}

class LinhaDeBotoes extends StatelessWidget {
  const LinhaDeBotoes({required this.aoRegistrar, super.key});

  final ValueChanged<int> aoRegistrar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final int m in <int>[25, 50])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: FilledButton(
                onPressed: () => aoRegistrar(m),
                child: Text('+$m min'),
              ),
            ),
          ),
      ],
    );
  }
}

/// Uma ROTA NOVA. Ela não é descendente de CascaFoco: é filha do Navigator.
class TelaSessao extends StatelessWidget {
  const TelaSessao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessão')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Esta tela NÃO lê os minutos de hoje nem registra uma sessão: '
            'ela está fora da subárvore de CascaFoco.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AbaMaterias extends StatelessWidget {
  const AbaMaterias({required this.estado, required this.aoAdicionar, super.key});

  final EstadoFoco estado;
  final ValueChanged<String> aoAdicionar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Você já estudou ${estado.minutosHoje} min hoje.'),
        Expanded(
          child: ListView.separated(
            itemCount: estado.materias.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int i) =>
                ListTile(title: Text(estado.materias[i])),
          ),
        ),
        FilledButton.tonal(
          onPressed: () => aoAdicionar('Matéria ${estado.materias.length + 1}'),
          child: const Text('Adicionar matéria'),
        ),
      ],
    );
  }
}

class AbaAjustes extends StatelessWidget {
  const AbaAjustes({required this.estado, required this.aoAlterarMeta, super.key});

  final EstadoFoco estado;
  final ValueChanged<int> aoAlterarMeta;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Meta diária: ${estado.metaDiaria} min · faltam ${estado.faltam} min'),
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

## 🔍 Explicando o código

### 1. `@immutable` e o contrato da classe

```dart
@immutable
class EstadoFoco { ... }
```

`@immutable` é uma **anotação** do Flutter: ela não muda o comportamento em execução, mas faz a
análise estática avisar se algum campo da classe não for `final`. É um contrato verificado pelo
`flutter analyze`.

### 2. `copyWith`: mudar significa criar outro

```dart
_estado = _estado.copyWith(minutosHoje: _estado.minutosHoje + minutos);
```

Não existe `_estado.minutosHoje = ...` — o campo é `final`. Você cria um objeto novo com o valor
novo e reaponta a variável. O `?? this.x` dentro de `copyWith` significa "se você não passou este
parâmetro, mantenha o valor atual".

### 3. Regra de negócio saiu do `build`

Na Aula 1, o cálculo `minutosHoje / metaDiaria` estava **dentro** do `build` de `CartaoResumo`;
agora é o getter `progresso`, dentro de `EstadoFoco`. Com isso a regra tem um lugar só — nenhuma
tela pode calcular diferente — e virou **testável sem UI**, sem `WidgetTester` e sem emulador.
Esse é o primeiro passo em direção à arquitetura da Aula 9.

### 4. `TelaSessao` é a prova do limite

O botão "Abrir sessão em outra tela" faz `Navigator.push`. A tela que abre está na árvore, sim —
mas **abaixo do `Navigator` do `MaterialApp`**, que fica *acima* de `CascaFoco`. Logo,
`TelaSessao` não recebe `estado` por herança de contexto nem alcança `_registrarSessao`. As
únicas saídas com a técnica desta aula são: (a) passar tudo pelo construtor da rota, com
`Navigator.pop` devolvendo o resultado; ou (b) elevar o estado para **acima** do `MaterialApp` —
o caminho da Aula 3.

### 5. O que melhorou de verdade

| | Aula 1 | Aula 2 |
|---|---|---|
| Parâmetros de `AbaHoje` | 3 e crescendo | 2 e estável |
| Onde mora a regra de progresso | dentro do `build` | dentro de `EstadoFoco` |
| Testar a regra | só com `WidgetTester` | teste unitário puro |
| Fontes da verdade | 3 campos soltos | 1 objeto |

E o que **não** melhorou: o `IndexedStack` continua reconstruindo as três abas a cada `setState`,
`CartaoResumo` continua repassando `aoRegistrar` sem usá-lo, e `TelaSessao` segue incomunicável.

## ⚠️ Erros comuns

**1. Elevar o estado alto demais.**
Se o dado interessa a **um** widget só, mantenha-o lá. Subir por precaução transforma o `State`
do topo num depósito de tudo — o chamado *God State*, que reconstrói o app inteiro a cada toque.

**2. Duplicar o estado no filho.**
Escrever `late int _minutos = widget.minutos;` dentro de um `State` filho cria duas verdades: se
o pai mudar `minutos`, a cópia do filho **não** acompanha, porque o inicializador roda uma vez
só. Widget controlado não guarda cópia.

**3. Mutar a lista em vez de criar outra.**
`setState(() => _estado.materias.add(nome));` funciona por acidente: o `setState` força o `build`,
mas o objeto de estado continua sendo o mesmo, então qualquer otimização que compare referências
(e o Riverpod faz isso) não veria mudança nenhuma. Escreva sempre
`copyWith(materias: <String>[...antigos, nome])`.

**4. Chamar `setState` depois de um `await` sem checar `mounted`.**

```dart
Future<void> _carregar() async {
  final int minutos = await _buscarMinutos();
  if (!mounted) return;          // obrigatório
  setState(() => _estado = _estado.copyWith(minutosHoje: minutos));
}
```

Se a pessoa sair da tela durante o `await`, o `State` já foi descartado e o `setState` lança
exceção. A checagem `if (!mounted) return;` é obrigatória em todo `State`. Em código que guardou
um `BuildContext`, a checagem equivalente é `if (!context.mounted) return;`.

**5. Achar que elevar resolve a navegação.**
Não resolve. Rota nova é outro ramo da árvore. Esse é o ponto exato em que a técnica acaba.

## 🛠️ Exercício guiado

Objetivo: **provar na prática** os cinco limites da elevação de estado.

**Passo 1.** Rode o app e confirme que os +25/+50 atualizam as três abas.

```powershell
flutter run -d windows
```

**Passo 2.** Toque em **Abrir sessão em outra tela**. Tente exibir os minutos de hoje ali dentro,
usando só o que você sabe: você vai descobrir que precisa **passar o valor pelo construtor da
rota**. Faça isso:

```dart
MaterialPageRoute<void>(builder: (_) => TelaSessao(estado: estado)),
```

**Passo 3.** Agora faça a `TelaSessao` **registrar** 15 minutos. Você vai precisar levar o
*callback* junto (`aoRegistrar`) **ou** devolver o valor com `Navigator.pop(context, 15)` e
tratar o retorno. Implemente a versão com `pop` e retorno:

```dart
final int? minutos = await Navigator.of(context).push<int>(
  MaterialPageRoute<int>(builder: (_) => const TelaSessao()),
);
if (minutos != null) aoRegistrar(minutos);
```

Como há um `await`, este trecho precisa estar dentro de um `State` com `if (!mounted) return;`
antes de qualquer uso de `context` — ou, num `StatelessWidget`, com `if (!context.mounted) return;`.

**Passo 4.** Adicione um quarto dado ao `EstadoFoco`: `String materiaAtual`. Repare que agora
você **não** precisa tocar em nenhuma assinatura de construtor — foi exatamente para isso que o
objeto de estado serve. Compare com o Passo 4 da Aula 1.

**Passo 5.** Escreva um teste unitário de verdade para a regra de progresso. Crie
`test/estado_foco_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_estado/main.dart';

void main() {
  test('progresso é 0.5 quando metade da meta foi cumprida', () {
    const EstadoFoco estado = EstadoFoco(minutosHoje: 45, metaDiaria: 90);
    expect(estado.progresso, 0.5);
    expect(estado.faltam, 45);
  });
}
```

```powershell
flutter test
```

Você deve ver `All tests passed!`. Esse teste **não abre tela nenhuma** — é o primeiro sinal de
que separar dado de UI compensa.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

## 🏆 Desafio opcional

Implemente o modo escuro **sem** biblioteca, usando só elevação de estado: eleve um
`bool modoEscuro` para `AppFoco`, transformando-o em `StatefulWidget`, e use-o em
`MaterialApp(themeMode: ...)` com `theme:` e `darkTheme:`. O interruptor fica na aba Ajustes, três
níveis abaixo.

Depois responda por escrito: quantos construtores precisaram mudar? O que aconteceria se você
quisesse ler `modoEscuro` dentro de `TelaSessao`?

## 📌 Resumo

- **Elevar o estado** é mover o dado para o ancestral comum dos interessados e distribuí-lo de
  lá. É a primeira resposta recomendada pelo Flutter, antes de qualquer biblioteca.
- O fluxo é sempre **valor desce por parâmetro, ordem sobe por *callback***. Widgets como
  `Switch` e `Checkbox` são **controlados**: não guardam o próprio estado.
- Agrupar campos em um **objeto imutável** com `copyWith` reduz assinaturas e leva as **regras
  derivadas** para junto do dado, onde elas viram testáveis sem UI.
- A técnica **quebra** em cinco pontos: rota nova fora da subárvore; ancestral comum que sobe até
  o topo virando *God State*; *rebuild* da subárvore inteira; estado que morre com o widget;
  necessidade de `WidgetTester` para testar qualquer coisa ligada à árvore.
- Em todo `State`, depois de um `await`: `if (!mounted) return;` antes de `setState`.

## ☑️ Checklist de domínio

- [ ] Explico *lifting state up* em uma frase e sei achar o ancestral comum numa árvore.
- [ ] Sei dizer por que `Switch` não guarda o próprio valor.
- [ ] Escrevi `EstadoFoco` com `@immutable`, campos `final` e `copyWith`.
- [ ] Movi a regra de progresso para fora do `build` e a testei com `flutter test`.
- [ ] Vi, rodando, que `TelaSessao` não alcança o estado elevado.
- [ ] Implementei o retorno de valor com `Navigator.pop` e usei `if (!mounted) return;`.
- [ ] Cito os cinco limites da elevação de estado sem consultar, e `flutter analyze` está limpo.

## 📚 Referências oficiais

- [Flutter — Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)
- [Flutter — State management fundamentals](https://docs.flutter.dev/get-started/fundamentals/state-management)
- [Flutter — Switch (API)](https://api.flutter.dev/flutter/material/Switch-class.html)
- [Flutter — Navigator.push (API)](https://api.flutter.dev/flutter/widgets/Navigator/push.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [O problema do estado](01-o-problema-do-estado.md) | [README](README.md) | [InheritedWidget](03-inheritedwidget.md) |
