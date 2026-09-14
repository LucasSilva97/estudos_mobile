# Aula 4 — StatelessWidget

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Escrever um `StatelessWidget` completo, com construtor `const`, `{super.key}` e parâmetros
  `required`.
- Explicar o que significa dizer que um widget é **imutável** e por que todos os campos são `final`.
- Descrever quando o método `build` é chamado — e por que ele pode ser chamado muitas vezes por
  segundo sem que isso seja um problema.
- Explicar, em termos de árvore de Elements, **por que `const` importa** e quanto ele economiza.
- Justificar por que **extrair um widget** é melhor que **extrair um método que devolve `Widget`**.
- Construir o `CartaoMateria`, o primeiro widget reutilizável do `meu_primeiro_app`.

## ✅ Pré-requisitos

- [Aula 3 — main, runApp e a árvore de widgets](03-main-runapp-arvore-de-widgets.md), com a
  `HomeTela` funcionando.
- [Módulo 02 — Aula 03: var, final e const](../02-dart-basico/03-var-final-const.md) — a diferença
  entre `final` e `const` é o coração desta aula.
- [Módulo 03 — Aula 02: Construtores](../03-dart-intermediario/02-construtores.md) — parâmetros
  nomeados, `required` e `this.campo`.
- [Módulo 02 — Aula 05: Null safety](../02-dart-basico/05-null-safety.md) — tipos com `?`.

---

## 📖 Conceito

### O que é um `StatelessWidget`

Um `StatelessWidget` (*widget sem estado*) é um widget cuja aparência depende **apenas** dos
parâmetros que ele recebeu no construtor e do contexto em que ele foi colocado na árvore.

Dê a ele os mesmos parâmetros, no mesmo lugar da árvore, e ele desenha exatamente a mesma coisa.
Sempre. Ele não guarda nada entre um desenho e outro.

O esqueleto mínimo:

```dart
class Saudacao extends StatelessWidget {
  const Saudacao({super.key, required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) {
    return Text('Olá, $nome!');
  }
}
```

Quatro partes, e todas são obrigatórias no padrão deste curso:

1. `extends StatelessWidget` — herda a infraestrutura do framework.
2. Construtor **`const`** com `{super.key}` e parâmetros nomeados.
3. Campos **`final`**.
4. `@override Widget build(BuildContext context)` devolvendo a subárvore.

### Imutabilidade: por que tudo é `final`

Um widget é **imutável**: depois de construído, nenhum campo dele muda de valor. Isso não é
preferência de estilo — é requisito do framework. A classe `Widget` é declarada como
`@immutable`, e o analisador reclama se você tentar um campo mutável:

```dart
class Errado extends StatelessWidget {
  Errado({super.key, required this.nome});

  String nome;  // ❌ must_be_immutable: This class inherits from a class
                //    marked as @immutable, and all such classes must be immutable.

  @override
  Widget build(BuildContext context) => Text(nome);
}
```

**Por que o framework exige isso?** Porque widgets são descartáveis. Como você viu na
[aula 3](03-main-runapp-arvore-de-widgets.md), a cada `build` o Flutter cria widgets novos e compara
com os antigos. Se um widget pudesse mudar por dentro, a comparação não valeria nada: o Flutter não
teria como saber se algo mudou.

**Então como a tela muda?** Você **não muda o widget**. Você cria um widget novo, com valores novos,
na mesma posição da árvore. O Element daquela posição percebe, reaproveita o RenderObject e atualiza
os pixels. Mudar a tela = trocar a descrição, nunca editar a descrição.

```text
build nº 1:  Saudacao(nome: 'Ana')     →  Element existente  →  RenderParagraph mostra "Olá, Ana!"
build nº 2:  Saudacao(nome: 'Bruno')   →  MESMO Element      →  MESMO RenderParagraph, texto novo
             (objeto Widget nº 1 é jogado no lixo)
```

### Quando o `build` é chamado

O método `build` pode ser chamado:

- na primeira vez que o widget entra na árvore;
- toda vez que o widget pai reconstrói e recria este widget;
- quando um `InheritedWidget` do qual ele depende muda — por exemplo, o `Theme` ou o `MediaQuery`
  (foi por isso que, no exercício da aula 3, redimensionar a janela disparou um `build` novo);
- quando um `State` ancestral chama `setState` ([aula 5](05-statefulwidget-e-setstate.md));
- quando um hot reload acontece ([aula 8](08-hot-reload-e-hot-restart.md)).

Isso pode ser **60 vezes por segundo** durante uma animação. Daí duas regras de ouro:

> ✅ **`build` deve ser rápido e puro.** Só monte widgets.
> ❌ **Nunca** faça dentro do `build`: chamada de rede, leitura de banco, gravação de arquivo,
> criação de `Timer`, criação de `TextEditingController`, `setState`.

Essas operações vão para `initState` ou para a camada de estado — assunto das aulas
[5](05-statefulwidget-e-setstate.md) e [6](06-ciclo-de-vida-do-state.md).

### Parâmetros: `required`, `{super.key}` e valores padrão

```dart
class CartaoMateria extends StatelessWidget {
  const CartaoMateria({
    super.key,                       // sempre primeiro, sempre presente
    required this.nome,              // obrigatório
    required this.minutosEstudados,  // obrigatório
    this.icone = Icons.book_outlined,// opcional com padrão
    this.onTap,                      // opcional, pode ser nulo
  });

  final String nome;
  final int minutosEstudados;
  final IconData icone;
  final VoidCallback? onTap;
  // ...
}
```

Detalhe por detalhe:

| Elemento | Significado |
|---|---|
| `{ }` nas chaves do construtor | Parâmetros **nomeados**: quem chama escreve `CartaoMateria(nome: 'Dart')`. Isso torna a chamada legível mesmo com 6 parâmetros. |
| `super.key` | Repassa a `key` para a superclasse `Widget`. A `Key` é o "RG" do widget: quando dois widgets do mesmo tipo trocam de posição em uma lista, é a `key` que diz ao Flutter quem é quem. Aprofundado em [13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md). |
| `required` | Obrigatório. Sem ele, o código nem compila: `The parameter 'nome' can't have a value of 'null' because of its type`. |
| `this.icone = Icons.book_outlined` | Valor padrão. Para ter valor padrão em construtor `const`, o valor precisa ser ele mesmo uma constante. |
| `VoidCallback? onTap` | `VoidCallback` é apelido para `void Function()`. O `?` permite `null`, que significa "sem ação". |

### Por que `const` importa

Esta é a otimização mais barata do Flutter, e é de graça.

Quando você escreve `const Text('Olá')`, o Dart cria o objeto **em tempo de compilação** e o
**reaproveita**: toda vez que aquela expressão aparece, é literalmente o **mesmo objeto na memória**.

O Flutter aproveita isso no `updateChild`, o método que decide o que fazer com cada posição da
árvore. A primeira coisa que ele faz é:

```text
se (widgetNovo é identical(widgetAntigo))  →  não faz NADA nesta subárvore inteira
```

`identical()` compara **endereço de memória**, não conteúdo. Com `const`, o endereço é o mesmo, e a
subárvore inteira é pulada: nenhum `build`, nenhum recálculo de layout, nenhuma repintura.

Compare:

```dart
// ❌ Sem const: um novo objeto Text a cada build do pai.
//    O Flutter precisa comparar campo a campo e decidir se algo mudou.
Text('sessões concluídas')

// ✅ Com const: mesmo objeto, sempre. O Flutter pula a subárvore.
const Text('sessões concluídas')
```

**A regra:** coloque `const` em todo widget cujos parâmetros sejam todos constantes. O lint
`prefer_const_constructors`, que você ligou na [aula 2](02-estrutura-do-projeto.md), avisa quando
você esquece:

```text
info • Use 'const' with the constructor to improve performance •
       lib/main.dart:42:14 • prefer_const_constructors
```

**Quando `const` não é possível:** quando algum parâmetro só é conhecido em tempo de execução.

```dart
// Não pode ser const: `nome` vem de uma variável.
CartaoMateria(nome: materia.nome, minutosEstudados: materia.minutos)

// Não pode ser const: a cor vem do tema, que depende do context.
Icon(Icons.timer, color: Theme.of(context).colorScheme.primary)
```

Nesses casos, ainda vale declarar o **construtor** como `const`. Um construtor `const` pode ser
chamado sem `const` normalmente — mas o contrário é impossível. Declarar o construtor `const` é
abrir a porta para quem usar o seu widget conseguir otimizar.

> 📌 É por isso que a regra do curso é: **todo widget tem construtor `const`**, mesmo que você
> raramente consiga instanciá-lo como `const`.

### Extrair widget × extrair método

Quando o `build` fica grande, existem duas formas de dividir. Elas **não** são equivalentes.

**Forma A — extrair um método (evite):**

```dart
class HomeTela extends StatelessWidget {
  const HomeTela({super.key});

  Widget _construirCabecalho(BuildContext context) {
    return const Text('Resumo de hoje');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _construirCabecalho(context),   // ⚠️ só parece organizado
        // ...
      ],
    );
  }
}
```

**Forma B — extrair um widget (prefira):**

```dart
class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return const Text('Resumo de hoje');
  }
}

// e no build:
const _Cabecalho(),
```

Por que a forma B é melhor:

| Critério | Método `_construirCabecalho()` | Widget `_Cabecalho` |
|---|---|---|
| Aparece na árvore de widgets? | ❌ Não. O resultado é colado direto no pai. | ✅ Sim, com nome próprio. |
| Aparece no Flutter Inspector? | ❌ Não | ✅ Sim — você acha o problema em segundos |
| Pode ser `const`? | ❌ Nunca. É uma chamada de função. | ✅ Sim |
| Tem seu próprio Element? | ❌ Não | ✅ Sim |
| Reconstrói quando o pai reconstrói? | **Sempre** | Só se algo dele mudar (e nunca, se for `const`) |
| Pode ter `key`? | ❌ Não | ✅ Sim |
| Dá para testar isoladamente? | ❌ Não | ✅ Sim, com `pumpWidget` |

O ponto decisivo é o quarto: como o método é executado dentro do `build` do pai, **todo** o conteúdo
dele é reconstruído sempre que o pai reconstrói, mesmo que nada ali tenha mudado. O widget extraído,
por ter Element próprio, pode ser pulado.

Em uma tela pequena a diferença é imperceptível. Em uma lista com 200 itens, ou dentro de uma
animação que roda a 60 quadros por segundo, a diferença é visível.

> 💭 Sinal de alerta: se você está escrevendo um método `Widget _algumaCoisa()` dentro de um widget,
> quase sempre ele deveria ser uma classe. A exceção razoável é um trecho de 3 linhas usado uma vez
> só, que não depende de nada.

---

## 💡 Analogia

Um `StatelessWidget` é como uma **etiqueta de preço impressa**.

Ela mostra "R$ 12,90" porque foi impressa com esse valor. Ela não sabe somar, não muda sozinha, não
guarda o preço de ontem. Se o preço mudar, alguém **imprime uma etiqueta nova** e troca — a etiqueta
velha vai para o lixo.

`const` é o carimbo de um lote de etiquetas idênticas: em vez de imprimir "PROMOÇÃO" mil vezes, a
loja imprime uma única vez e reutiliza a mesma folha em todas as prateleiras. Quando o gerente passa
conferindo a loja e vê que a etiqueta é exatamente aquela folha conhecida, ele nem para para ler.

E a diferença entre extrair método e extrair widget: extrair método é **escrever o texto da etiqueta
em outro caderno e copiar à mão toda vez**. Extrair widget é **fazer uma etiqueta de verdade**, que
o gerente consegue apontar, nomear e reaproveitar.

---

## 🧪 Exemplo mínimo

Um widget reutilizável de 12 linhas, usado três vezes com parâmetros diferentes:

```dart
import 'package:flutter/material.dart';

class Etiqueta extends StatelessWidget {
  const Etiqueta({super.key, required this.texto, this.cor = Colors.grey});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(texto, style: const TextStyle(color: Colors.white)),
    );
  }
}

// Uso — o mesmo widget, três aparências:
Row(
  children: const <Widget>[
    Etiqueta(texto: 'Dart', cor: Colors.blue),
    SizedBox(width: 8),
    Etiqueta(texto: 'Flutter', cor: Colors.teal),
    SizedBox(width: 8),
    Etiqueta(texto: 'Revisar'),
  ],
)
```

Repare que a lista inteira é `const`: como todos os parâmetros são constantes, o Flutter cria
aqueles cinco widgets **uma vez só** durante toda a vida do app.

---

## 📱 Aplicando no Flutter

Chegou a hora do primeiro widget reutilizável de verdade do `meu_primeiro_app`: o **`CartaoMateria`**.

Ele mostra uma matéria de estudo com ícone, nome, minutos acumulados e uma barra de progresso em
relação à meta. Ele será usado na `HomeTela` agora e volta no Projeto 1 e no app final.

Requisitos que ele precisa atender:

1. Receber `nome`, `minutosEstudados` e `metaMinutos` como obrigatórios.
2. Aceitar um ícone opcional, com padrão.
3. Aceitar um `onTap` opcional — se for nulo, o cartão não reage ao toque.
4. Calcular sozinho a porcentagem, sem receber nada pronto.
5. Ter construtor `const`.
6. Não conhecer **nada** do resto do app: nenhum import de tela, nenhuma variável global.

Esse último requisito é o que torna um widget reutilizável: ele recebe tudo pelo construtor.

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/lib/widgets/cartao_materia.dart`
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Cartão que resume uma matéria de estudo.
///
/// É um StatelessWidget puro: tudo o que ele desenha vem dos parâmetros do
/// construtor. Ele não guarda estado, não faz chamada de rede e não conhece
/// nenhuma outra parte do aplicativo — por isso pode ser reaproveitado em
/// qualquer tela.
class CartaoMateria extends StatelessWidget {
  const CartaoMateria({
    super.key,
    required this.nome,
    required this.minutosEstudados,
    required this.metaMinutos,
    this.icone = Icons.menu_book_outlined,
    this.onTap,
  }) : assert(metaMinutos > 0, 'A meta precisa ser maior que zero.');

  /// Nome exibido da matéria. Ex.: "Dart".
  final String nome;

  /// Quantos minutos já foram estudados nesta matéria.
  final int minutosEstudados;

  /// Meta de minutos. Usada para calcular a barra de progresso.
  final int metaMinutos;

  /// Ícone à esquerda. Tem valor padrão para não obrigar quem usa a escolher.
  final IconData icone;

  /// Ação ao tocar no cartão. Se for nulo, o cartão não reage ao toque.
  final VoidCallback? onTap;

  /// Progresso entre 0.0 e 1.0.
  ///
  /// É um getter, não um campo: o valor é derivado dos outros dois e nunca
  /// pode ficar dessincronizado.
  double get progresso =>
      (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  /// Texto amigável: "45 min" ou "1 h 15 min".
  String get tempoFormatado {
    if (minutosEstudados < 60) {
      return '$minutosEstudados min';
    }
    final int horas = minutosEstudados ~/ 60;
    final int restante = minutosEstudados % 60;
    return restante == 0 ? '$horas h' : '$horas h $restante min';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;
    final bool metaAtingida = minutosEstudados >= metaMinutos;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Passar null desliga o toque e o efeito visual automaticamente.
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: cores.primaryContainer,
                foregroundColor: cores.onPrimaryContainer,
                child: Icon(icone),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            nome,
                            style: tema.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (metaAtingida)
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: cores.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$tempoFormatado de $metaMinutos min',
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: cores.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 6,
                        backgroundColor: cores.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Agora use o cartão na tela. Substitua o bloco `Row` de `_InfoSimples` da aula 3 por uma lista de
matérias.

> **Arquivo:** `meu_primeiro_app/lib/main.dart` (trecho alterado do `body` da `HomeTela`)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

import 'package:meu_primeiro_app/widgets/cartao_materia.dart';

void main() {
  runApp(const MeuPrimeiroApp());
}

class MeuPrimeiroApp extends StatelessWidget {
  const MeuPrimeiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Primeiro App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      home: const HomeTela(),
    );
  }
}

class HomeTela extends StatelessWidget {
  const HomeTela({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Primeiro App')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // const: este widget nunca muda, então o Flutter pula a subárvore.
          const _Cabecalho(),
          const SizedBox(height: 16),

          CartaoMateria(
            nome: 'Dart',
            minutosEstudados: 95,
            metaMinutos: 120,
            icone: Icons.code,
            onTap: () => _avisar(context, 'Dart'),
          ),
          const SizedBox(height: 12),

          CartaoMateria(
            nome: 'Flutter',
            minutosEstudados: 130,
            metaMinutos: 120,
            icone: Icons.phone_android,
            onTap: () => _avisar(context, 'Flutter'),
          ),
          const SizedBox(height: 12),

          // Sem onTap: o cartão fica visível, mas não reage ao toque.
          const CartaoMateria(
            nome: 'Git e terminal',
            minutosEstudados: 20,
            metaMinutos: 90,
            icone: Icons.terminal,
          ),
          const SizedBox(height: 24),

          Text(
            'Os números ainda são fixos. Na aula 5 eles passam a mudar.',
            style: tema.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _avisar(BuildContext context, String materia) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Você tocou em $materia.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Cabeçalho da tela. Extraído como WIDGET (e não como método) para poder ser
/// const e para aparecer com nome próprio no Flutter Inspector.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Resumo de hoje', style: tema.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Acompanhe quanto você estudou em cada matéria.',
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
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

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `class CartaoMateria extends StatelessWidget` | Widget público (sem `_`): ele será importado por outras telas. |
| `const CartaoMateria({ ... })` | Construtor `const`. Quem usar o cartão com valores fixos ganha a otimização de graça. |
| `}) : assert(metaMinutos > 0, ...)` | Lista de inicialização com `assert`. Ele roda **só no modo debug** e falha alto se alguém passar meta zero — o que causaria divisão por zero. Um construtor `const` **pode** ter `assert`. |
| `final String nome;` | Campo imutável. Todos os campos de um widget precisam ser `final`. |
| `final VoidCallback? onTap;` | `VoidCallback` = `void Function()`. O `?` permite nulo. |
| `double get progresso => ...clamp(0.0, 1.0)` | **Getter**: valor calculado na hora, nunca armazenado. `clamp` limita o resultado entre 0 e 1 — sem ele, estudar 130 de 120 minutos daria `1.08` e o `LinearProgressIndicator` lançaria erro. |
| `String get tempoFormatado` | Segunda derivação. Lógica de apresentação pode ficar no widget; regra de negócio, não. |
| `~/` e `%` | Divisão inteira e resto ([módulo 01, aula 06](../01-logica-e-fundamentos/06-operadores.md)). |
| `Card(clipBehavior: Clip.antiAlias)` | Faz o conteúdo respeitar os cantos arredondados do cartão. Sem isso, o efeito de toque do `InkWell` vaza pelos cantos. |
| `InkWell(onTap: onTap, ...)` | Detecta toque **e** desenha o efeito de ondulação do Material. Passar `null` desliga os dois automaticamente — por isso não é preciso nenhum `if`. |
| `CircleAvatar` | Círculo com ícone dentro. |
| `Expanded` dentro de `Row` | Faz a coluna de textos ocupar todo o espaço que sobra depois do ícone. Sem ele, um nome longo estoura a linha com `RenderFlex overflowed by N pixels`. |
| `maxLines: 1, overflow: TextOverflow.ellipsis` | Corta o nome longo com "…" em vez de quebrar o layout. |
| `if (metaAtingida) Icon(...)` | **`if` dentro de uma lista de `children`**. É uma `collection if` do Dart ([módulo 02, aula 08](../02-dart-basico/08-listas.md)): o elemento só entra na lista se a condição for verdadeira. Muito mais legível que operador ternário com `SizedBox.shrink()`. |
| `ClipRRect` em volta do `LinearProgressIndicator` | Arredonda as pontas da barra. |
| `cores.surfaceContainerHighest` | Cor de superfície do Material 3. Substitui o antigo `surfaceVariant`. |
| `import 'package:meu_primeiro_app/widgets/cartao_materia.dart';` | Import por `package:`, usando o `name` do `pubspec.yaml`. Funciona de qualquer arquivo do projeto e não quebra se você mover a tela de pasta. |
| `const _Cabecalho()` | Widget extraído, `const`, privado ao arquivo. Comparado a um método `_construirCabecalho()`, ele ganha Element próprio e pode ser pulado pelo framework. |
| `onTap: () => _avisar(context, 'Dart')` | Função anônima que captura o `context` do `build` da `HomeTela`. É esse `context` que o `ScaffoldMessenger` usa. |

**Um detalhe sobre `const` neste arquivo:** os dois primeiros `CartaoMateria` **não** são `const`,
porque `onTap` é uma função anônima criada a cada `build`. O terceiro **é** `const`, porque todos os
seus parâmetros são literais. O lint `prefer_const_constructors` marca exatamente esses casos para
você — não é preciso decorar.

---

## 🤖🍎 Android × iOS

O `InkWell` do `CartaoMateria` expõe uma diferença real de plataforma no **feedback de toque**:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Efeito visual ao tocar | **ripple** (ondulação que se espalha a partir do dedo) | nenhuma ondulação; o padrão é o item **escurecer ou ficar translúcido** |
| Widget idiomático | `InkWell` / `InkResponse` | `CupertinoButton` / `GestureDetector` com mudança de opacidade |
| Expectativa do usuário | ver a onda confirma o toque | ver a onda parece "coisa de Android" |

O Flutter **não** adapta isso sozinho: `InkWell` desenha ripple em toda plataforma. Se você quiser
o comportamento nativo em cada lado, a [aula 9](09-material-e-cupertino.md) mostra as opções.

A decisão deste curso é usar **Material 3 como base em ambas as plataformas**, com adaptação
pontual. Um `InkWell` com ripple no iPhone é aceitável e é o que a maioria dos apps Flutter faz.

> 🍎 **SÓ NO MAC.** Sentir a diferença exige rodar no simulador ou em um iPhone. 🪟 No Windows você
> consegue ver o efeito Cupertino usando widgets Cupertino explicitamente no Chrome — o desenho é o
> mesmo, porque quem pinta é o Flutter. O que você não consegue reproduzir é o **gesto de sistema**
> (arrastar da borda esquerda para voltar), que depende do sistema operacional.

---

## ⚠️ Erros comuns

**1. Campo não `final` em um widget.**
```text
error • This class (or a class that this class inherits from) is marked as
        '@immutable', but one or more of its instance fields aren't final •
        must_be_immutable
```
Torne o campo `final`. Se ele **precisa** mudar, o widget deveria ser um `StatefulWidget`
([aula 5](05-statefulwidget-e-setstate.md)).

**2. Esquecer `super.key`.**
```text
info • Constructors for public widgets should have a named 'key' parameter •
       use_key_in_widget_constructors
```

**3. Fazer trabalho pesado dentro do `build`.**
```dart
@override
Widget build(BuildContext context) {
  final dados = buscarDaInternet();  // ❌ roda a cada quadro
  return Text(dados);
}
```
O `build` pode rodar 60 vezes por segundo. Isso vira 60 requisições por segundo.

**4. Tentar `const` com valor de execução.**
```text
error • Invalid constant value • invalid_constant
```
```dart
const CartaoMateria(nome: materia.nome, ...)  // ❌ materia.nome não é constante
```
Tire o `const` da chamada. O construtor continua `const`.

**5. `RenderFlex overflowed by 37 pixels on the right`.**
Faixa preta e amarela na tela. Dentro de uma `Row`, o texto não cabe. Solução: embrulhar o texto em
`Expanded` ou `Flexible`, como foi feito no `CartaoMateria`.

**6. Extrair método em vez de widget "porque é mais rápido de escrever".**
Funciona hoje, cobra depois: subárvore sem nome no Inspector, impossível de tornar `const`,
reconstruída sempre. Prefira a classe.

**7. Widget "reutilizável" que importa uma tela do app.**
```dart
import 'package:meu_primeiro_app/telas/detalhe_tela.dart';  // ❌ dentro do widget
```
O cartão passa a só funcionar naquele app, naquela tela. Receba um `VoidCallback onTap` e deixe
**quem usa** decidir o que acontece.

---

## 🛠️ Exercício guiado

**Objetivo:** provar com números que extrair widget e usar `const` mudam o comportamento real.

**Passo 1.** Em `lib/widgets/cartao_materia.dart`, adicione a primeira linha do `build`:

```dart
@override
Widget build(BuildContext context) {
  debugPrint('build do CartaoMateria: $nome');
  final ThemeData tema = Theme.of(context);
  // ... resto igual
```

**Passo 2.** Faça o mesmo em `_Cabecalho`:

```dart
@override
Widget build(BuildContext context) {
  debugPrint('build do _Cabecalho');
  // ... resto igual
```

**Passo 3.** Rode `flutter run -d chrome` e observe o terminal. Você verá quatro linhas: uma do
cabeçalho e três dos cartões.

**Passo 4.** Redimensione a janela do Chrome várias vezes. Observe quais `build` disparam de novo.

**Passo 5.** Agora transforme o `_Cabecalho` de widget em método. Apague a classe `_Cabecalho` e
coloque dentro da `HomeTela`:

```dart
Widget _construirCabecalho(BuildContext context) {
  debugPrint('build do _Cabecalho (versão método)');
  final ThemeData tema = Theme.of(context);
  return Column(/* ... o mesmo conteúdo ... */);
}
```

e troque `const _Cabecalho()` por `_construirCabecalho(context)`.

**Passo 6.** Redimensione de novo e compare a quantidade de mensagens no terminal.

**Passo 7.** Escreva em `anotacoes.md`:
1. Na versão widget `const`, o cabeçalho reconstruiu junto com a tela?
2. Na versão método, reconstruiu?
3. Se a `HomeTela` reconstruísse 60 vezes por segundo durante uma animação, qual das duas versões
   faria mais trabalho?

**Passo 8.** Volte para a versão com widget `const`. Ela é a versão oficial do curso, e é a que as
próximas aulas assumem.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Faça os de **Implementação** (criar widgets reutilizáveis próprios) e o de **Correção de bugs** que
envolve `must_be_immutable`.

---

## 🏆 Desafio opcional

Crie `lib/widgets/etiqueta_nivel.dart` com um `StatelessWidget` chamado `EtiquetaNivel` que:

1. Receba `required this.minutos` (int) e `this.compacta = false` (bool).
2. Calcule sozinho o nível: até 60 min = "Iniciante"; até 180 min = "Praticando"; até 600 min =
   "Consistente"; acima disso = "Veterano".
3. Escolha a cor a partir do `ColorScheme` do tema, nunca com cor fixa.
4. Quando `compacta` for `true`, mostre só a primeira letra.
5. Tenha construtor `const` e passe no `flutter analyze` sem nenhum aviso.

Depois, adicione a etiqueta dentro do `CartaoMateria`, ao lado do nome da matéria — **sem** criar
nenhum campo novo no cartão, porque `minutosEstudados` já existe. Esse é um teste real de
composição: um widget dentro do outro, cada um responsável por uma coisa.

---

## 📌 Resumo

- `StatelessWidget` é um widget cuja aparência depende **só** dos parâmetros do construtor e da
  posição na árvore. Ele não guarda nada.
- Widgets são **imutáveis**: todos os campos são `final`, e a classe `Widget` é `@immutable`. Para
  mudar a tela, o Flutter cria um widget novo na mesma posição — o Element e o RenderObject
  continuam os mesmos.
- `build` pode rodar dezenas de vezes por segundo. Ele deve **só montar widgets**: nada de rede,
  banco, `Timer` ou `setState` lá dentro.
- Padrão obrigatório do curso: construtor `const`, `{super.key}` primeiro, `required` no que é
  obrigatório, valores padrão constantes no que é opcional.
- `const` faz o Flutter comparar por `identical()` e **pular a subárvore inteira**. É a otimização
  mais barata que existe. O lint `prefer_const_constructors` avisa onde falta.
- **Extrair widget é melhor que extrair método**: o widget ganha Element próprio, pode ser `const`,
  pode ter `key`, aparece no Inspector, pode ser testado isolado e não reconstrói junto com o pai.
- Um widget reutilizável recebe **tudo** pelo construtor, incluindo o que fazer no toque
  (`VoidCallback? onTap`), e não importa nada de telas específicas.
- Valores derivados (progresso, texto formatado) devem ser **getters**, nunca campos — assim nunca
  ficam dessincronizados.

---

## ☑️ Checklist de domínio

- [ ] Escrevo um `StatelessWidget` completo de memória, com as quatro partes obrigatórias.
- [ ] Explico por que todos os campos de um widget precisam ser `final`.
- [ ] Explico como a tela muda se os widgets são imutáveis.
- [ ] Listo quatro situações que disparam um `build`.
- [ ] Digo três coisas que **nunca** podem estar dentro do `build`.
- [ ] Uso `required`, `{super.key}` e valores padrão corretamente.
- [ ] Explico, em termos de `identical()` e árvore de Elements, por que `const` acelera o app.
- [ ] Sei dizer, olhando uma chamada, se ela pode ser `const` ou não — e por quê.
- [ ] Listo quatro vantagens de extrair widget em vez de extrair método.
- [ ] Criei o `CartaoMateria`, usei-o três vezes na `HomeTela` e `flutter analyze` está limpo.
- [ ] Sei corrigir um `RenderFlex overflowed` dentro de uma `Row`.

---

## 📚 Referências oficiais

- [StatelessWidget class — API docs](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)
- [Introduction to widgets](https://docs.flutter.dev/ui/widgets-intro)
- [Performance best practices](https://docs.flutter.dev/perf/best-practices)
- [Using the Flutter inspector](https://docs.flutter.dev/tools/devtools/inspector)
- [Linter rule: prefer_const_constructors](https://dart.dev/tools/linter-rules/prefer_const_constructors)
- [Material 3 — Cards](https://api.flutter.dev/flutter/material/Card-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — main, runApp e a árvore de widgets](03-main-runapp-arvore-de-widgets.md) | [README](README.md) | [Aula 5 — StatefulWidget e setState](05-statefulwidget-e-setstate.md) |
