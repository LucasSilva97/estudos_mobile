# Gabarito dos desafios — Projeto 01: Meu Primeiro App

> Compare depois de tentar. Ver a solução antes de tentar não ensina nada — e estes desafios foram
> escritos justamente para você bater na parede que o enunciado descreve.

Enunciados em [05-desafios.md](../projetos/01-projeto-iniciante/05-desafios.md).

---

<a id="p01-d01"></a>
## P01-D01 — Sessão de 90 minutos

> **Arquivo:** `lib/telas/home_tela.dart`

```dart
Text(
  'Duração da sessão (min)',            // ← a unidade migrou para o título
  style: Theme.of(context).textTheme.titleSmall,
),
const SizedBox(height: 8),
SegmentedButton<int>(
  segments: const <ButtonSegment<int>>[
    ButtonSegment<int>(value: 15, label: Text('15')),
    ButtonSegment<int>(value: 25, label: Text('25')),
    ButtonSegment<int>(value: 50, label: Text('50')),
    ButtonSegment<int>(value: 90, label: Text('90')),
  ],
  selected: <int>{_duracaoMinutos},
  onSelectionChanged: (Set<int> escolha) {
    setState(() => _duracaoMinutos = escolha.first);
  },
),
```

O `SegmentedButton` divide a largura igualmente entre os segmentos: com quatro rótulos de seis
caracteres (`90 min`), o texto não cabe em 320 px e o `RenderFlex` estoura. Tirar a unidade de cada
botão resolve sem `Expanded` nem `FittedBox` — e o título passa a informar melhor, porque a unidade
aparece uma vez em vez de quatro.

Nada muda em `_concluirSessao()`: ela já soma `_duracaoMinutos`, seja qual for o valor.

---

<a id="p01-d02"></a>
## P01-D02 — Percentual no cartão

> **Arquivo:** `lib/modelos/materia.dart`

```dart
/// Derivado de [progresso], que já tem o clamp — por isso nunca passa de 100.
int get percentual => (progresso * 100).round();
```

> **Arquivo:** `lib/widgets/cartao_materia.dart`

```dart
Row(
  children: <Widget>[
    Text(
      '${materia.tempoFormatado} de ${materia.metaMinutos} min',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    const Spacer(),
    Text(
      '${materia.percentual}%',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    ),
  ],
),
```

O detalhe que importa é **onde** o cálculo mora. Escrever
`(materia.minutosEstudados / materia.metaMinutos * 100).round()` no widget funcionaria — e
duplicaria a regra, inclusive o `clamp`, que o widget provavelmente esqueceria. Como `percentual`
deriva de `progresso`, o teto de 100 % vem junto de graça: dez sessões de 50 min em Dart continuam
mostrando `100%`.

---

<a id="p01-d03"></a>
## P01-D03 — Metas cumpridas no resumo

> **Arquivo:** `lib/widgets/barra_resumo.dart`

```dart
class BarraResumo extends StatelessWidget {
  const BarraResumo({
    required this.sessoesConcluidas,
    required this.minutosTotais,
    required this.materiaEmFoco,
    required this.metasAtingidas,     // ← novo
    super.key,
  });

  final int sessoesConcluidas;
  final int minutosTotais;
  final String materiaEmFoco;

  /// Quantas matérias já bateram a meta. Quem conta é a HomeTela:
  /// a barra continua sem calcular nada.
  final int metasAtingidas;
```

E na linha do `Em foco:`:

```dart
Text(
  'Em foco: $materiaEmFoco · $metasAtingidas de 4 metas cumpridas',
  style: Theme.of(context).textTheme.bodySmall,
),
```

> **Arquivo:** `lib/telas/home_tela.dart`

```dart
BarraResumo(
  sessoesConcluidas: _sessoes,
  minutosTotais: _minutosTotais,
  materiaEmFoco: _materiaSelecionada.nome,
  metasAtingidas:
      _materias.where((Materia m) => m.metaAtingida).length,
),
```

A tentação é dar a lista inteira para a `BarraResumo` e deixá-la contar. O resultado seria o mesmo
na tela, e a barra passaria a depender de `Materia` — um widget de resumo que precisa conhecer o
modelo de domínio. Passando o número pronto, ela continua servindo para qualquer dado.

---

<a id="p01-d04"></a>
## P01-D04 — Ordenar por progresso

> **Arquivo:** `lib/telas/home_tela.dart`

```dart
bool _ordenadoPorProgresso = false;

/// Aplica a ordem escolhida sobre a lista atual.
///
/// Devolve lista nova em vez de ordenar no lugar: assim `_materias`
/// nunca fica numa ordem que o usuário não pediu.
List<Materia> _aplicarOrdem(List<Materia> lista) {
  if (!_ordenadoPorProgresso) return lista;
  return <Materia>[...lista]
    ..sort((Materia a, Materia b) => a.progresso.compareTo(b.progresso));
}

void _alternarOrdem() {
  setState(() {
    _ordenadoPorProgresso = !_ordenadoPorProgresso;
    _materias = _aplicarOrdem(_materias);
  });
}

void _zerarDia() {
  setState(() {
    _sessoes = 0;
    // ⚠️ Recriar de materiasIniciais desfaz a ordenação.
    // Reaplicar aqui é o que faz a preferência sobreviver.
    _materias = _aplicarOrdem(materiasIniciais);
    _materiaSelecionada = _materias.first;
  });
}
```

Na `AppBar`:

```dart
IconButton(
  icon: const Icon(Icons.sort),
  tooltip: _ordenadoPorProgresso
      ? 'Ordenar pela ordem original'
      : 'Ordenar por menor progresso',
  onPressed: _alternarOrdem,
),
```

O `tooltip` descreve **o que vai acontecer ao tocar**, não o estado atual — é o que o usuário
precisa saber antes de decidir tocar, e é o que o leitor de tela anuncia.

A armadilha do enunciado é real: `_zerarDia()` recria a lista a partir de `materiasIniciais`, que
está na ordem original. Sem a chamada a `_aplicarOrdem` ali, zerar o dia desfaz silenciosamente uma
escolha que o usuário fez.

---

<a id="p01-d05"></a>
## P01-D05 — Meta do dia

> **Arquivo:** `lib/widgets/meta_do_dia.dart` (novo)

```dart
import 'package:flutter/material.dart';

/// Meta diária, em minutos, somando todas as matérias.
const int metaDiariaMinutos = 120;

class MetaDoDia extends StatelessWidget {
  const MetaDoDia({required this.minutosTotais, super.key});

  final int minutosTotais;

  bool get _cumprida => minutosTotais >= metaDiariaMinutos;
  int get _bonus => minutosTotais - metaDiariaMinutos;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _cumprida
                ? 'Meta do dia cumprida — +$_bonus min de bônus'
                : '$minutosTotais de $metaDiariaMinutos min',
            style: tema.textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            // O clamp é o que impede a barra de estourar depois dos 120.
            value: (minutosTotais / metaDiariaMinutos).clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
```

E na `HomeTela`, logo abaixo da `BarraResumo`:

```dart
MetaDoDia(minutosTotais: _minutosTotais),
```

Nenhuma cor literal no arquivo: o `LinearProgressIndicator` sem `color` usa o `colorScheme` do
tema, e por isso o widget funciona no claro e no escuro sem uma linha a mais. Uma cor fixa aqui
ficaria bonita em um dos temas e ilegível no outro.

---

<a id="p01-d06"></a>
## P01-D06 — O número que anima

> **Arquivo:** `lib/widgets/contador_sessoes.dart`

```dart
TweenAnimationBuilder<double>(
  // A cada build com `sessoes` diferente, o Tween recomeça do valor
  // atual e corre até o novo — é isso que faz o número "andar"
  // tanto ao concluir quanto ao remover.
  tween: Tween<double>(begin: 0, end: sessoes.toDouble()),
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
  builder: (BuildContext context, double valor, Widget? filho) {
    return Text(
      '${valor.round()}',
      style: Theme.of(context).textTheme.displayLarge,
    );
  },
),
```

O ponto do desafio é perceber que **não é preciso** virar `StatefulWidget`. O
`TweenAnimationBuilder` guarda o controlador internamente e descarta-o sozinho; o estado do app
continua inteiro na `HomeTela`, como o escopo do projeto exige.

`Curves.easeOut` desacelera no fim — a animação parece terminar no valor em vez de bater nele.

**Onde a documentação responde:**
[`TweenAnimationBuilder`](https://api.flutter.dev/flutter/widgets/TweenAnimationBuilder-class.html)
e [`Curves`](https://api.flutter.dev/flutter/animation/Curves-class.html).

---

<a id="p01-d07"></a>
## P01-D07 — O app para quem não vê a tela

**1. O cartão, lido como um item só**

> **Arquivo:** `lib/widgets/cartao_materia.dart`

```dart
// Sem o MergeSemantics, o leitor de tela faz três paradas — "Dart",
// "95 de 120 min", "79%" — e o usuário não sabe que pertencem ao
// mesmo cartão.
MergeSemantics(
  child: Card(
    child: /* ... conteúdo como estava ... */,
  ),
)
```

**2. O número grande, com contexto**

> **Arquivo:** `lib/widgets/contador_sessoes.dart`

```dart
Semantics(
  label: '$sessoes sessões concluídas hoje',
  // Os filhos não têm semântica útil — o "12" sozinho não diz nada.
  excludeSemantics: true,
  child: Text(
    '$sessoes',
    style: Theme.of(context).textTheme.displayLarge,
  ),
),
```

**3. A barra de progresso, que é muda**

> **Arquivo:** `lib/widgets/cartao_materia.dart`

```dart
LinearProgressIndicator(
  value: materia.progresso,
  // Uma barra visual não comunica nada a quem não vê.
  semanticsLabel: 'Progresso de ${materia.nome}',
  semanticsValue: '${materia.percentual} por cento',
),
```

**4. Os botões só-ícone**

```dart
IconButton(
  icon: const Icon(Icons.remove),
  // O tooltip vira o rótulo semântico: sem ele o leitor
  // anuncia apenas "botão".
  tooltip: 'Remover uma sessão',
  onPressed: onRemover,
),
```

**5. E desligue o depurador**

```dart
MaterialApp(
  showSemanticsDebugger: false,   // ⚠️ nunca vai para produção
  // ...
)
```

O resultado é o cartão lido como `Dart, 95 de 120 minutos, 79 por cento` numa parada só. Repare
que os quatro consertos são de tipos diferentes — agrupar, rotular, dar valor e nomear ação — e que
a `showSemanticsDebugger` foi quem os revelou. É a mesma ferramenta que o
[módulo 13, aula 5](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md) usa depois, com o
assunto tratado por inteiro.

**Onde a documentação responde:**
[`Semantics`](https://api.flutter.dev/flutter/widgets/Semantics-class.html) e
[Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility).

---

## 🧭 Se a sua solução ficou diferente

Solução diferente não é solução errada. Julgue pela lista:

| Pergunta | Por que importa |
|---|---|
| O **Esperado:** do enunciado acontece? | É o contrato do desafio |
| O cálculo ficou no modelo, não no widget? | D02 e D03 são exatamente sobre isso |
| Alguma cor literal entrou no código? | Quebra o tema escuro (RF05) |
| Algum pacote externo entrou? | O projeto proíbe — o escopo é parte do exercício |
| Virou `StatefulWidget` sem precisar? | D06 tem solução sem isso |
| `flutter analyze` continua limpo? | Aviso novo é regressão |

Se o resultado é o mesmo e as regras acima valem, a sua versão serve. Guarde-a e siga para o
[checklist](../projetos/01-projeto-iniciante/06-checklist.md).

---

[Desafios](../projetos/01-projeto-iniciante/05-desafios.md) ·
[Projeto 1](../projetos/01-projeto-iniciante/README.md) ·
[Gabaritos](README.md)
