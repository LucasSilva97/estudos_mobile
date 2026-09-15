# Aula 10 — Gestos e feedback

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Escolher entre **`GestureDetector`** e **`InkWell`** sabendo exatamente o que cada um faz — e por
  que o segundo é o padrão em apps Material.
- Explicar por que a **onda do toque** (*ripple*) às vezes não aparece, e como consertar em três
  cenários diferentes.
- Usar os **cinco botões do Material 3** (`Elevated`, `Filled`, `FilledTonal`, `Outlined`, `Text`)
  na hierarquia certa dentro de uma tela.
- Dar feedback ao usuário com **`SnackBar`**, **`AlertDialog`**, **`showModalBottomSheet`** e
  **`Tooltip`** — e saber qual usar em cada situação.
- Receber o **resultado** de um diálogo com `await` e tipo garantido.
- Respeitar o **alvo mínimo de toque** de 48 px e por que isso não é opcional.
- Usar **`onLongPress`**, **`onDoubleTap`** e arrastar sem conflito entre gestos.

## ✅ Pré-requisitos

- [Aula 1 — Scaffold e AppBar](01-scaffold-e-appbar.md) — o `Scaffold` é quem hospeda o `SnackBar`.
- [Aula 7 — Cores, temas e modo escuro](07-cores-temas-modo-escuro.md) — `colorScheme` e
  `filledButtonTheme`.
- [Aula 9 — Listas e rolagem](09-listas-e-rolagem.md) — a `MateriasTab` continua de lá.
- [Módulo 05, aula 7 — BuildContext](../05-introducao-ao-flutter/07-buildcontext.md) — `Builder`,
  `ScaffoldMessenger.of` e `context.mounted` depois do `await`. Esta aula usa os três.
- [Módulo 04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) — diálogos
  devolvem `Future`.

---

## 📖 Conceito

### Os dois detectores de toque

O Flutter tem duas formas de fazer um widget reagir ao toque, e elas **não** são intercambiáveis.

**`GestureDetector`** — detecta gestos e **não desenha nada**.

```dart
GestureDetector(
  onTap: () => debugPrint('toquei'),
  child: Container(width: 100, height: 100, color: Colors.blue),
)
```

**`InkWell`** — detecta gestos **e desenha a onda** (*ripple*) do Material.

```dart
InkWell(
  onTap: () => debugPrint('toquei'),
  child: Container(width: 100, height: 100, color: Colors.blue),
)
```

| | `GestureDetector` | `InkWell` |
|---|---|---|
| Onda visual ao tocar | ❌ | ✅ |
| Destaque ao passar o mouse (desktop/web) | ❌ | ✅ |
| Foco de teclado (`Tab`) | ❌ | ✅ |
| Arrastar, escalar, girar | ✅ | ❌ |
| Precisa de um `Material` acima | Não | **Sim** |

> **Regra do curso:** se o usuário vai **tocar** em algo, use `InkWell`. Use `GestureDetector`
> apenas para gestos que o `InkWell` não tem — arrastar (`onPanUpdate`), pinçar (`onScaleUpdate`)
> —, ou quando a área tocável é deliberadamente invisível.

Por que a onda importa: ela é a **confirmação de que o toque foi registrado**. Sem ela, em um app
lento ou numa ação que demora, o usuário toca de novo — e dispara a ação duas vezes.

### Por que a onda não aparece

Esse é o problema visual número 1 desta aula, e ele tem três causas distintas.

**Causa 1 — o `InkWell` está abaixo de um fundo opaco.**

```dart
Container(
  color: Colors.white,          // ❌ pinta POR CIMA da onda
  child: InkWell(onTap: () {}, child: const Text('Toque')),
)
```

A onda é desenhada pelo widget `Material` mais próximo **acima** do `InkWell`. Um `Container` com
`color:` entre os dois cobre a tinta.

**Correção** — use `Material` (ou `Ink`) para pintar o fundo, e o `InkWell` **por dentro**:

```dart
Material(
  color: Theme.of(context).colorScheme.surfaceContainer,  // ✅
  child: InkWell(onTap: () {}, child: const Text('Toque')),
)
```

Ou, quando você quer decoração (bordas, gradiente, cantos):

```dart
Ink(
  decoration: BoxDecoration(
    color: cores.primaryContainer,
    borderRadius: BorderRadius.circular(12),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),  // ✅ a onda respeita o mesmo raio
    onTap: () {},
    child: const Padding(padding: EdgeInsets.all(16), child: Text('Toque')),
  ),
)
```

**Causa 2 — a onda vaza dos cantos arredondados.**

```dart
Card(
  child: InkWell(onTap: () {}, child: ...),  // ⚠️ onda quadrada num card redondo
)
```

**Correção:** `clipBehavior: Clip.antiAlias` no `Card`, ou `borderRadius:` no próprio `InkWell`
(com o mesmo valor do pai).

**Causa 3 — não há `Material` nenhum acima.**

```text
No Material widget found. InkWell widgets require a Material widget ancestor.
```

Acontece dentro de `CupertinoApp`, dentro de `Overlay` cru, ou em testes isolados.
**Correção:** envolva em `Material(...)`.

### Os cinco botões do Material 3

O Material 3 organiza os botões por **ênfase**. A regra é: **um botão de ênfase máxima por tela**.

| Botão | Aparência | Ênfase | Quando usar |
|---|---|---|---|
| `FilledButton` | Preenchido com a cor primária | **Máxima** | A ação principal da tela: "Salvar", "Continuar", "Entrar" |
| `FilledButton.tonal` | Preenchido com cor suave | Alta | Ação importante, mas não a principal: "Adicionar matéria" |
| `ElevatedButton` | Com sombra | Média | Ação que precisa se destacar de um fundo com conteúdo |
| `OutlinedButton` | Só borda | Média-baixa | Alternativa à ação principal: "Cancelar" ao lado de "Salvar" |
| `TextButton` | Só texto | **Mínima** | Ações secundárias, links, ações dentro de diálogos |

```dart
FilledButton(onPressed: _salvar, child: const Text('Salvar'))
FilledButton.tonal(onPressed: _adicionar, child: const Text('Adicionar'))
OutlinedButton(onPressed: _cancelar, child: const Text('Cancelar'))
TextButton(onPressed: _saibaMais, child: const Text('Saiba mais'))
IconButton(icon: const Icon(Icons.share), onPressed: _compartilhar)
```

Todos têm variante `.icon`:

```dart
FilledButton.icon(
  onPressed: _salvar,
  icon: const Icon(Icons.save_outlined),
  label: const Text('Salvar'),
)
```

> 💡 **`onPressed: null` desabilita o botão** e aplica o estilo de desabilitado automaticamente.
> Isso é melhor do que esconder o botão: o usuário vê que a ação existe e entende que falta algo.

### Os quatro tipos de feedback

| Feedback | Interrompe? | Some sozinho? | Use para |
|---|:---:|:---:|---|
| **`SnackBar`** | Não | Sim (≈4 s) | Confirmar algo que já aconteceu: "Item excluído" |
| **`AlertDialog`** | **Sim** | Não | Perguntar algo que **exige** resposta: "Excluir mesmo?" |
| **`showModalBottomSheet`** | Sim | Não | Oferecer opções ou um formulário curto |
| **`Tooltip`** | Não | Sim | Explicar um ícone sem rótulo |

**`SnackBar` — confirmação leve com ação de desfazer.**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Matéria excluída'),
    action: SnackBarAction(label: 'Desfazer', onPressed: _desfazer),
    duration: const Duration(seconds: 4),
  ),
);
```

**`AlertDialog` — pergunta bloqueante que devolve resposta.**

```dart
final bool? confirmou = await showDialog<bool>(
  context: context,
  builder: (BuildContext contextDoDialogo) => AlertDialog(
    title: const Text('Excluir matéria?'),
    content: const Text('Esta ação não pode ser desfeita.'),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.of(contextDoDialogo).pop(false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.of(contextDoDialogo).pop(true),
        child: const Text('Excluir'),
      ),
    ],
  ),
);

if (confirmou ?? false) { /* … */ }
```

Três detalhes que **sempre** dão problema:

1. **`showDialog<bool>`** — o tipo entre `<>` é o que o `pop` devolve. Se você escrever
   `showDialog(...)` sem tipo, recebe `dynamic` e perde a checagem do compilador.
2. **O retorno é `bool?`, não `bool`.** Ele é `null` quando o usuário toca fora do diálogo ou
   aperta "voltar". **Sempre** trate esse caso: `confirmou ?? false`.
3. **Use o `context` do `builder`** no `Navigator.of(...)`. Usar o `context` da tela funcionaria
   aqui, mas cria o hábito errado — e quebra em diálogos aninhados.

**`showModalBottomSheet` — folha que sobe de baixo.**

```dart
final String? escolha = await showModalBottomSheet<String>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,  // necessário quando há teclado ou conteúdo alto
  builder: (BuildContext contextDaFolha) => ListView(
    shrinkWrap: true,
    children: <Widget>[
      ListTile(
        leading: const Icon(Icons.edit_outlined),
        title: const Text('Editar'),
        onTap: () => Navigator.of(contextDaFolha).pop('editar'),
      ),
    ],
  ),
);
```

**`Tooltip` — o rótulo que aparece ao segurar (ou ao passar o mouse).**

```dart
IconButton(
  icon: const Icon(Icons.grid_view_outlined),
  tooltip: 'Ver como grade',   // ✅ acessibilidade de graça
  onPressed: _alternar,
)
```

> ⚠️ **Todo `IconButton` sem rótulo visível precisa de `tooltip`.** Não é enfeite: o leitor de tela
> usa esse texto para anunciar o botão. Sem ele, um usuário cego ouve apenas "botão".

### O alvo mínimo de toque

As duas plataformas exigem que qualquer alvo tocável tenha **pelo menos 48×48 px lógicos**
(Material) ou **44×44 pt** (Apple). Um ícone de 24 px é metade disso.

O Flutter já cuida disso em `IconButton`, `Checkbox`, `Radio` e `Switch` — eles têm área de toque
maior que o desenho. Mas **não** cuida quando você mesmo monta:

```dart
InkWell(
  onTap: _fechar,
  child: const Icon(Icons.close, size: 20),   // ❌ alvo de 20 px
)
```

**Correção:**

```dart
InkWell(
  onTap: _fechar,
  child: const Padding(
    padding: EdgeInsets.all(14),              // 20 + 14 + 14 = 48 ✅
    child: Icon(Icons.close, size: 20),
  ),
)
```

Ou envolva em `SizedBox(width: 48, height: 48, child: Center(child: ...))`.

### Gestos que conflitam

Quando dois widgets querem o mesmo toque, o Flutter usa a **arena de gestos**: cada detector se
inscreve, e quem tem o "melhor argumento" vence. Na prática:

- Um toque simples é vencido pelo detector **mais interno**.
- Um arraste vertical dentro de uma lista rolável é vencido pela **lista**.
- `onTap` e `onDoubleTap` no mesmo widget fazem o `onTap` **esperar** ~300 ms para saber se vem o
  segundo toque. Isso deixa o app perceptivelmente mais lento.

> 📌 **Não coloque `onDoubleTap` em elementos de uso frequente.** O atraso que ele impõe ao `onTap`
> é sentido pelo usuário como travamento. Reserve o toque duplo para ações raras — ou não use.

---

## 💡 Analogia

Pense num balcão de atendimento.

- **`GestureDetector`** é um atendente que **ouve** o que você pede mas não dá sinal nenhum de que
  ouviu — sem "pois não", sem aceno. Você fica em dúvida se precisa repetir.
- **`InkWell`** é o atendente que **acena com a cabeça** no instante em que você fala. A onda do
  toque é esse aceno: custa nada e resolve a ansiedade de quem espera.
- **`SnackBar`** é o atendente dizendo "pronto, resolvido" enquanto você já está indo embora. Não
  interrompe, e você pode ignorar.
- **`AlertDialog`** é o atendente **fechando a porta** e perguntando "tem certeza? isso não tem
  volta". Interrompe de propósito — e por isso deve ser raro. Um app que abre diálogo para tudo é
  como um balcão que fecha a porta a cada pergunta.
- **`Tooltip`** é a plaquinha discreta embaixo de cada botão do balcão. Quem já sabe não olha; quem
  não sabe, e quem não enxerga, depende dela.
- **O alvo de 48 px** é o tamanho do botão físico. Um botão do tamanho de uma cabeça de alfinete
  funciona no teste do engenheiro de dedo fino — e falha com todo mundo apressado, no ônibus,
  com uma mão só.

---

## 🧪 Exemplo mínimo

Este programa mostra as três causas do "a onda não aparece", lado a lado.

> **Arquivo:** `foco_ui/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppOnda());

class AppOnda extends StatelessWidget {
  const AppOnda({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const TelaOnda(),
    );
  }
}

class TelaOnda extends StatelessWidget {
  const TelaOnda({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Onde está a onda?')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          const Text('1. ❌ Container com color POR CIMA — sem onda'),
          const SizedBox(height: 8),
          Container(
            color: cores.primaryContainer,
            child: InkWell(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('Toque aqui')),
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text('2. ✅ Ink pinta o fundo — a onda aparece'),
          const SizedBox(height: 8),
          Ink(
            decoration: BoxDecoration(
              color: cores.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('Toque aqui')),
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text('3. ⚠️ Card sem clipBehavior — a onda vaza nos cantos'),
          const SizedBox(height: 8),
          Card(
            child: InkWell(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('Toque aqui')),
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text('4. ✅ Card com clipBehavior: Clip.antiAlias'),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('Toque aqui')),
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text('5. ❌ GestureDetector — nunca tem onda'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              color: cores.secondaryContainer,
              padding: const EdgeInsets.all(20),
              child: const Center(child: Text('Toque aqui')),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Toque nos cinco e compare.** A diferença entre 1 e 2 — e entre 3 e 4 — é o que separa um app que
parece responsivo de um que parece travado.

---

## 📱 Aplicando no Flutter

A `MateriasTab` da aula 9 já exclui com arraste. Agora ela ganha o conjunto completo de interação:

1. **Toque longo** em uma matéria abre uma **folha de opções** (editar, duplicar, excluir).
2. **Toque simples** abre um diálogo de "registrar sessão" que **devolve os minutos escolhidos**.
3. Um **`FloatingActionButton`** adiciona matéria nova, com `FilledButton` e `OutlinedButton` na
   hierarquia certa.
4. Todo feedback passa por `SnackBar` com **desfazer**.
5. Todos os alvos de toque têm 48 px, e todo ícone tem `tooltip`.

---

## 💻 Código completo

> **Arquivo:** `foco_ui/lib/core/widgets/dialogos.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Diálogos reutilizáveis do app.
///
/// Concentrar os diálogos em um arquivo evita que cada tela invente o seu
/// próprio texto de confirmação — e deixa o estilo consistente.
abstract final class Dialogos {
  /// Pergunta sim/não. Devolve false quando o usuário fecha sem escolher.
  static Future<bool> confirmar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String rotuloConfirmar = 'Confirmar',
    String rotuloCancelar = 'Cancelar',
    bool destrutivo = false,
  }) async {
    final ColorScheme cores = Theme.of(context).colorScheme;

    final bool? resposta = await showDialog<bool>(
      context: context,
      builder: (BuildContext contextDoDialogo) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: <Widget>[
            // Ênfase mínima para a saída sem consequência.
            TextButton(
              onPressed: () => Navigator.of(contextDoDialogo).pop(false),
              child: Text(rotuloCancelar),
            ),
            // Ênfase máxima para a ação; vermelho quando é destrutiva.
            FilledButton(
              style: destrutivo
                  ? FilledButton.styleFrom(
                      backgroundColor: cores.error,
                      foregroundColor: cores.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(contextDoDialogo).pop(true),
              child: Text(rotuloConfirmar),
            ),
          ],
        );
      },
    );

    // null acontece quando o usuário toca fora ou aperta voltar.
    // Tratar como "não" é sempre a escolha segura.
    return resposta ?? false;
  }

  /// Pede a duração de uma sessão. Devolve null se o usuário desistir.
  static Future<int?> pedirMinutos(BuildContext context, String materia) {
    return showDialog<int>(
      context: context,
      builder: (BuildContext contextDoDialogo) {
        return SimpleDialog(
          title: Text('Registrar sessão de $materia'),
          children: <Widget>[
            for (final int minutos in <int>[15, 25, 50, 90])
              SimpleDialogOption(
                onPressed: () => Navigator.of(contextDoDialogo).pop(minutos),
                child: Padding(
                  // 48 px de alvo de toque, com folga.
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('$minutos minutos'),
                ),
              ),
            const Divider(),
            SimpleDialogOption(
              onPressed: () => Navigator.of(contextDoDialogo).pop(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Cancelar'),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

> **Arquivo:** `foco_ui/lib/features/materias/presentation/widgets/folha_acoes.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'package:foco_ui/features/materias/domain/materia.dart';

/// As ações possíveis sobre uma matéria.
enum AcaoMateria { editar, duplicar, excluir }

/// Folha de opções aberta com toque longo.
///
/// Devolve a ação escolhida, ou null se o usuário fechar sem escolher.
Future<AcaoMateria?> mostrarFolhaAcoes(
  BuildContext context,
  Materia materia,
) {
  return showModalBottomSheet<AcaoMateria>(
    context: context,
    showDragHandle: true, // a "alcinha" que convida a arrastar para fechar
    builder: (BuildContext contextDaFolha) {
      final ColorScheme cores = Theme.of(contextDaFolha).colorScheme;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(materia.icone),
              title: Text(materia.nome),
              subtitle: Text(
                '${materia.minutosEstudados} de ${materia.metaMinutos} min',
              ),
            ),
            const Divider(height: 1),

            // ListTile já garante 48 px de altura e onda do Material.
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () =>
                  Navigator.of(contextDaFolha).pop(AcaoMateria.editar),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicar'),
              onTap: () =>
                  Navigator.of(contextDaFolha).pop(AcaoMateria.duplicar),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: cores.error),
              title: Text('Excluir', style: TextStyle(color: cores.error)),
              onTap: () =>
                  Navigator.of(contextDaFolha).pop(AcaoMateria.excluir),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
```

Agora a `MateriasTab` liga tudo:

> **Arquivo:** `foco_ui/lib/features/materias/presentation/materias_tab.dart`
> (acrescente os métodos abaixo e ajuste o `build`)

```dart
import 'package:flutter/material.dart';

import 'package:foco_ui/core/widgets/dialogos.dart';
import 'package:foco_ui/features/materias/domain/materia.dart';
import 'package:foco_ui/features/materias/presentation/widgets/folha_acoes.dart';
import 'package:foco_ui/features/materias/presentation/widgets/materia_tile.dart';

// … dentro de _MateriasTabState …

  /// Toque simples: pergunta os minutos e registra a sessão.
  Future<void> _registrarSessao(Materia materia) async {
    final int? minutos = await Dialogos.pedirMinutos(context, materia.nome);

    // O usuário pode ter fechado o diálogo — e pode ter saído da tela.
    if (minutos == null) return;
    if (!mounted) return;

    setState(() {
      _materias = _materias
          .map((Materia m) => m.id == materia.id
              ? m.copyWith(minutosEstudados: m.minutosEstudados + minutos)
              : m)
          .toList();
    });

    final int anterior = materia.minutosEstudados;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('+$minutos min em ${materia.nome}'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _definirMinutos(materia.id, anterior),
          ),
        ),
      );
  }

  /// Toque longo: abre a folha e executa a ação escolhida.
  Future<void> _abrirAcoes(Materia materia, int posicao) async {
    final AcaoMateria? acao = await mostrarFolhaAcoes(context, materia);

    if (acao == null) return;
    if (!mounted) return;

    switch (acao) {
      case AcaoMateria.editar:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Editar ${materia.nome} — Módulo 07')),
        );

      case AcaoMateria.duplicar:
        setState(() {
          final List<Materia> novas = List<Materia>.of(_materias);
          novas.insert(
            posicao + 1,
            materia.copyWith(
              id: '${materia.id}_copia_${DateTime.now().millisecondsSinceEpoch}',
              nome: '${materia.nome} (cópia)',
              minutosEstudados: 0,
            ),
          );
          _materias = novas;
        });

      case AcaoMateria.excluir:
        final bool confirmou = await Dialogos.confirmar(
          context,
          titulo: 'Excluir matéria?',
          mensagem: '"${materia.nome}" e o progresso dela serão removidos.',
          rotuloConfirmar: 'Excluir',
          destrutivo: true,
        );
        if (!mounted) return;
        if (confirmou) _remover(materia, posicao);
    }
  }

  void _definirMinutos(String id, int minutos) {
    setState(() {
      _materias = _materias
          .map((Materia m) =>
              m.id == id ? m.copyWith(minutosEstudados: minutos) : m)
          .toList();
    });
  }

  /// Adiciona uma matéria nova. Formulário de verdade fica no Módulo 07.
  Future<void> _adicionar() async {
    final bool confirmou = await Dialogos.confirmar(
      context,
      titulo: 'Adicionar matéria',
      mensagem: 'Criar "Nova matéria" com meta de 60 minutos?',
      rotuloConfirmar: 'Criar',
    );
    if (!mounted) return;
    if (!confirmou) return;

    setState(() {
      _materias = <Materia>[
        ..._materias,
        Materia(
          id: 'nova_${DateTime.now().millisecondsSinceEpoch}',
          nome: 'Nova matéria',
          minutosEstudados: 0,
          metaMinutos: 60,
        ),
      ];
    });
  }
```

E, no `build`, o `FloatingActionButton` e os gestos no tile:

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matérias'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_emGrade ? Icons.view_list_outlined : Icons.grid_view_outlined),
            // Todo IconButton sem rótulo PRECISA de tooltip.
            tooltip: _emGrade ? 'Ver como lista' : 'Ver como grade',
            onPressed: () => setState(() => _emGrade = !_emGrade),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionar,
        icon: const Icon(Icons.add),
        label: const Text('Matéria'),
        tooltip: 'Adicionar matéria',
      ),

      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: _materias.isEmpty
            ? _ListaVazia(onRecarregar: _atualizar)
            : (_emGrade ? _construirGrade() : _construirLista()),
      ),
    );
  }
```

E o `itemBuilder` da lista passa a mandar os dois gestos:

```dart
        child: MateriaTile(
          materia: materia,
          onTap: () => _registrarSessao(materia),
          onLongPress: () => _abrirAcoes(materia, i),
        ),
```

O `MateriaTile` recebe o novo parâmetro:

```dart
class MateriaTile extends StatelessWidget {
  const MateriaTile({
    required this.materia,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final Materia materia;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    // … o resto igual …
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(/* … */),
    );
  }
}
```

Rode e confira:

```powershell
flutter analyze
flutter run -d chrome
```

1. Toque em uma matéria → diálogo de minutos → escolha 25 → `SnackBar` com Desfazer.
2. Toque em Desfazer → os minutos voltam ao valor anterior.
3. **Segure** uma matéria → a folha sobe → escolha Duplicar → a cópia aparece logo abaixo.
4. Segure de novo → Excluir → diálogo vermelho → confirme.
5. Passe o mouse sobre os ícones da `AppBar` (no Chrome) → os *tooltips* aparecem.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `abstract final class Dialogos` | Espaço de nomes: métodos estáticos, nunca instanciado. Mesmo padrão do `TemaApp` da [aula 7](07-cores-temas-modo-escuro.md). |
| `showDialog<bool>(...)` com tipo explícito | O `<bool>` define o que `pop(...)` pode devolver. Sem ele você recebe `dynamic` e o compilador para de te ajudar. |
| `return resposta ?? false;` | O diálogo devolve `null` quando o usuário toca fora ou aperta voltar. Tratar `null` como "não" é a escolha segura em ação destrutiva. |
| `Navigator.of(contextDoDialogo).pop(valor)` | Fecha **o diálogo** e devolve o valor para quem deu `await`. Usar o `context` da tela aqui é o erro clássico da [aula 7 do Módulo 05](../05-introducao-ao-flutter/07-buildcontext.md). |
| `FilledButton.styleFrom(backgroundColor: cores.error)` | Ação destrutiva em vermelho. Sinal visual que o usuário lê antes de ler o texto. |
| `SimpleDialogOption` com `padding: vertical 12` | Garante o alvo de 48 px. Sem o padding, cada opção teria ~20 px de altura. |
| `showModalBottomSheet<AcaoMateria>` | O tipo genérico é o `enum` — o `switch` que recebe o resultado fica **exaustivo** e o compilador cobra todos os casos. |
| `showDragHandle: true` | Desenha a alcinha do Material 3 e ativa o arraste para fechar. Uma linha, muita usabilidade. |
| `SafeArea` dentro da folha | Impede que a última opção fique embaixo da barra de gestos do iPhone. |
| `switch (acao) { case AcaoMateria.editar: … }` | *Switch statement* sobre `enum`: o analisador avisa se você esquecer um caso. Visto no [Módulo 03](../03-dart-intermediario/07-enums.md). |
| `if (minutos == null) return;` **antes** de `if (!mounted) return;` | Duas checagens diferentes: a primeira é "o usuário desistiu", a segunda é "a tela ainda existe". As duas são necessárias. |
| `final int anterior = materia.minutosEstudados;` | Guardado **antes** da mudança, para o "Desfazer" ter o que restaurar. |
| `..hideCurrentSnackBar()` antes de `..showSnackBar(...)` | Cascata do Dart. Evita fila de mensagens quando o usuário registra várias sessões seguidas. |
| `FloatingActionButton.extended` com `tooltip` | O FAB é a ação primária da tela. `.extended` mostra rótulo — melhor quando a ação não é óbvia pelo ícone. |
| `onTap` e `onLongPress` no mesmo `InkWell` | Não conflitam: o toque longo é decidido pelo **tempo**, não competindo com o toque simples (diferente de `onDoubleTap`). |
| `'${materia.id}_copia_${DateTime.now().millisecondsSinceEpoch}'` | Id único para a cópia. Sem isso, duas `key` iguais quebram o `Dismissible` da [aula 9](09-listas-e-rolagem.md). |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onda ao tocar | Padrão nativo — o usuário espera ver | Não existe nativamente; o usuário espera **mudança de opacidade** |
| Diálogo | `AlertDialog` — botões de texto lado a lado, à direita | `CupertinoAlertDialog` — botões empilhados, divididos por linhas |
| Folha inferior | `showModalBottomSheet` | `showCupertinoModalPopup` com `CupertinoActionSheet` |
| Toque longo | Costuma abrir menu de contexto | Costuma abrir *preview* (peek) ou menu de contexto |
| Retorno tátil (vibração) | `HapticFeedback.mediumImpact()` | Idem, mas o motor háptico é mais preciso |
| Alvo mínimo | 48 dp | 44 pt |

**Adaptação de custo zero:** use `showAdaptiveDialog` no lugar de `showDialog` e
`AlertDialog.adaptive` no lugar de `AlertDialog`. O Flutter desenha a versão Cupertino no iOS
sozinho:

```dart
final bool? r = await showAdaptiveDialog<bool>(
  context: context,
  builder: (BuildContext c) => AlertDialog.adaptive(
    title: const Text('Excluir?'),
    actions: <Widget>[ /* … */ ],
  ),
);
```

> 📌 Acrescente `HapticFeedback.selectionClick()` no `onLongPress` — a vibração curta é o que faz o
> toque longo "parecer" que funcionou antes mesmo de a folha subir. Importe
> `package:flutter/services.dart`.

---

## ⚠️ Erros comuns

### 1. A onda não aparece

Três causas, três correções — revisadas na seção Conceito. O resumo:

| Sintoma | Causa | Correção |
|---|---|---|
| Nenhuma onda | `Container(color:)` acima do `InkWell` | Troque por `Ink(decoration:)` ou `Material(color:)` |
| Onda quadrada em canto redondo | Falta recorte | `clipBehavior: Clip.antiAlias` no `Card`, ou `borderRadius:` no `InkWell` |
| `No Material widget found` | Não há `Material` acima | Envolva em `Material(...)` |

### 2. Usar o `context` errado no `pop`

```dart
showDialog<bool>(
  context: context,
  builder: (BuildContext contextDoDialogo) => AlertDialog(
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(true), // ⚠️ context da TELA
        child: const Text('Ok'),
      ),
    ],
  ),
);
```

Funciona por acaso — mas em um diálogo aberto **de dentro de outro** ele fecha o errado.
**Correção:** sempre `Navigator.of(contextDoDialogo)`.

### 3. Esquecer que o resultado é anulável

```dart
final bool confirmou = await showDialog<bool>(...); // ❌ não compila
if (confirmou) { … }
```

```text
A value of type 'bool?' can't be assigned to a variable of type 'bool'.
```

**Correção:** `final bool? r = await showDialog<bool>(...); if (r ?? false) { … }`.

### 4. Usar o `context` depois do `await` sem checar

```dart
Future<void> _excluir(Materia m) async {
  final bool ok = await Dialogos.confirmar(context, /* … */);
  ScaffoldMessenger.of(context).showSnackBar(...); // ❌
}
```

Enquanto o diálogo estava aberto, o usuário pode ter saído da tela.

**Correção:** `if (!mounted) return;` logo depois do `await`. O lint
`use_build_context_synchronously` avisa.

### 5. Alvo de toque pequeno demais

```dart
InkWell(onTap: _fechar, child: const Icon(Icons.close, size: 18)) // ❌ 18 px
```

**Correção:** use `IconButton` (que já garante 48 px) ou acrescente `Padding`/`SizedBox`.

### 6. `IconButton` sem `tooltip`

Não quebra nada visualmente — e torna o botão **inacessível** para leitor de tela.

**Correção:** `tooltip: 'Ver como grade'`. Sem exceção.

### 7. `SnackBar` empilhando

```dart
for (final Materia m in selecionadas) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${m.nome} excluída')));
}
```

As mensagens entram numa fila e o usuário fica 20 segundos vendo `SnackBar`.

**Correção:** `hideCurrentSnackBar()` antes, ou uma mensagem única: "3 matérias excluídas".

### 8. `onDoubleTap` em item de lista

```dart
InkWell(onTap: _abrir, onDoubleTap: _favoritar, child: ...) // ⚠️
```

O `onTap` passa a **esperar ~300 ms** em todo toque, para ver se vem o segundo. O app fica
perceptivelmente lento.

**Correção:** use toque longo em vez de toque duplo, ou coloque a ação em um botão explícito.

### 9. `GestureDetector` com `onTap` num widget transparente

```dart
GestureDetector(
  onTap: _fechar,
  child: Container(width: 200, height: 200), // ❌ sem color, não recebe toque
)
```

Um `Container` sem cor nem filho é **transparente aos toques**.

**Correção:** `behavior: HitTestBehavior.opaque` no `GestureDetector`, ou dê uma cor
(`Colors.transparent` **não** basta — precisa do `behavior`).

---

## 🛠️ Exercício guiado

**Passo 1.** No `_CartaoGrade` da aula 9, o `Card` já tem `clipBehavior: Clip.antiAlias`.
Remova essa linha, rode, e toque numa célula. Observe os cantos. Devolva a linha.

**Passo 2.** Troque o `InkWell` do `MateriaTile` por `GestureDetector`. Rode e toque. O que você
perdeu? Liste três coisas. Depois volte ao `InkWell`.

**Passo 3.** Remova o `tooltip` do `IconButton` de alternar visualização. Rode no Chrome e passe o
mouse. Depois devolva o `tooltip`.

**Passo 4.** Em `Dialogos.confirmar`, troque `return resposta ?? false;` por
`return resposta!;`. Rode, abra o diálogo de excluir e **toque fora dele**. Leia o erro. Depois
desfaça.

**Passo 5.** Acrescente `HapticFeedback.selectionClick()` no início de `_abrirAcoes`. Se estiver
testando no Chrome, você não vai sentir nada — mas o código fica pronto para o celular. Confirme
que o `import 'package:flutter/services.dart';` foi adicionado.

**Passo 6.** Troque `showDialog` por `showAdaptiveDialog` e `AlertDialog` por
`AlertDialog.adaptive` em `Dialogos.confirmar`. Rode, aperte `o` no terminal para alternar a
plataforma e abra o diálogo nas duas. Descreva as diferenças.

**Passo 7.** Acrescente `onDoubleTap` ao `MateriaTile` e faça-o registrar 25 minutos direto. Rode e
toque **uma vez** em várias matérias seguidas. Você sente o atraso? Descreva-o. Depois remova.

**Passo 8.** Responda por escrito: você tem cinco ações numa tela — "Salvar", "Cancelar",
"Excluir conta", "Ver termos" e "Adicionar item". Qual botão do Material 3 você usa em cada uma, e
por quê?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Faça os exercícios de **Aplicação** com diálogo que devolve valor, o de **Correção de bugs** com a
onda que não aparece, e o de **Decisão** sobre hierarquia de botões.

---

## 🏆 Desafio opcional

Crie um widget `AcaoComEspera` que envolve qualquer botão e resolve um problema real: **o usuário
toca duas vezes numa ação demorada**.

Requisitos:

- Recebe um `Future<void> Function()` e um `Widget child`.
- Enquanto o `Future` não completa, o botão fica desabilitado e mostra um
  `CircularProgressIndicator.adaptive` no lugar do rótulo.
- Se o `Future` lançar exceção, mostra um `SnackBar` de erro e reabilita o botão.
- Funciona mesmo se o widget sair da tela no meio (sem `setState() after dispose`).

Depois use-o em `_adicionar` e responda: quantas linhas de `bool _carregando` você apagou do resto
do app? Esse é o teste de um bom widget reutilizável.

---

## 📌 Resumo

- **`InkWell`** para tudo que o usuário toca; **`GestureDetector`** só para gestos que o `InkWell`
  não tem (arrastar, pinçar) ou áreas invisíveis.
- A **onda** é a confirmação visual do toque. Sem ela, o usuário toca de novo.
- A onda some quando há um `Container(color:)` entre o `Material` e o `InkWell` — use
  **`Ink(decoration:)`** ou **`Material(color:)`**.
- A onda vaza nos cantos sem `clipBehavior: Clip.antiAlias` (ou `borderRadius:` no `InkWell`).
- Hierarquia dos botões M3: `FilledButton` (máxima, **uma por tela**) → `FilledButton.tonal` →
  `ElevatedButton` → `OutlinedButton` → `TextButton` (mínima).
- `onPressed: null` **desabilita** e aplica o estilo certo — melhor que esconder o botão.
- `SnackBar` para confirmar o que já aconteceu; `AlertDialog` para perguntar o que exige resposta;
  `showModalBottomSheet` para oferecer opções; `Tooltip` para explicar ícones.
- `showDialog<T>` devolve **`T?`** — `null` quando o usuário fecha por fora. **Sempre trate.**
- Dentro do `builder`, use o **`context` do próprio diálogo** no `Navigator.of(...).pop(...)`.
- Depois de todo `await` de diálogo: **`if (!mounted) return;`**.
- Alvo de toque mínimo: **48 px**. `IconButton` garante; `InkWell` cru não.
- Todo `IconButton` sem rótulo visível **precisa** de `tooltip` — é acessibilidade, não enfeite.
- Evite `onDoubleTap` em elementos frequentes: ele atrasa todo `onTap` em ~300 ms.
- `showAdaptiveDialog` + `AlertDialog.adaptive` dão o visual de cada plataforma sem código extra.

---

## ☑️ Checklist de domínio

- [ ] Escolho entre `InkWell` e `GestureDetector` sem hesitar, e justifico.
- [ ] Diagnostico "a onda não aparece" identificando qual das três causas é.
- [ ] Uso `Ink(decoration:)` quando preciso de fundo decorado com onda.
- [ ] Coloco `clipBehavior: Clip.antiAlias` em todo `Card` que contém `InkWell`.
- [ ] Sei os cinco botões do Material 3 e uso **um** `FilledButton` por tela.
- [ ] Desabilito botões com `onPressed: null` em vez de escondê-los.
- [ ] Escolho entre `SnackBar`, `AlertDialog`, folha inferior e `Tooltip` pelo critério certo.
- [ ] Escrevo `showDialog<bool>` com tipo, e trato o retorno `null`.
- [ ] Uso o `context` do `builder` no `pop` do diálogo.
- [ ] Coloco `if (!mounted) return;` depois de todo `await` de diálogo.
- [ ] Garanto 48 px de alvo de toque em tudo que é tocável.
- [ ] Todo `IconButton` do meu app tem `tooltip`.
- [ ] Ofereço **Desfazer** em toda ação destrutiva reversível.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Handle taps — docs.flutter.dev](https://docs.flutter.dev/cookbook/gestures/handling-taps)
- [Gestures in Flutter — docs.flutter.dev](https://docs.flutter.dev/ui/interactivity/gestures)
- [InkWell class — api.flutter.dev](https://api.flutter.dev/flutter/material/InkWell-class.html)
- [Material 3 buttons — m3.material.io](https://m3.material.io/components/buttons/overview)
- [SnackBar class — api.flutter.dev](https://api.flutter.dev/flutter/material/SnackBar-class.html)
- [showDialog — api.flutter.dev](https://api.flutter.dev/flutter/material/showDialog.html)
- [showModalBottomSheet — api.flutter.dev](https://api.flutter.dev/flutter/material/showModalBottomSheet.html)
- [Accessibility — docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 9 — Listas e rolagem](09-listas-e-rolagem.md) | [README](README.md) | [Aula 11 — Responsividade](11-responsividade.md) |
