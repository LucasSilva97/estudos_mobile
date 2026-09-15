# Aula 5 — Acessibilidade

> **Módulo:** 13 - Desempenho e Segurança · **Tempo estimado:** 55 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Ligar e usar o **TalkBack** (Android) e o **VoiceOver** (iOS) para testar o seu app.
- Entender a **árvore de semântica** e o widget **`Semantics`**.
- Corrigir os quatro problemas mais comuns: **ícone sem rótulo**, **contraste baixo**, **alvo de
  toque pequeno** e **texto que quebra com fonte grande**.
- Aplicar os números que importam: **4.5:1**, **48 dp / 44 pt**, **200 % de escala de fonte**.
- Usar `MergeSemantics`, `ExcludeSemantics`, `Semantics(liveRegion:)` e `SemanticsService`.
- Escrever **testes automáticos** de acessibilidade com `meetsGuideline`.
- Saber o que **só dá para verificar com o leitor de tela ligado**.

## ✅ Pré-requisitos

- [Aula 4 — Medindo desempenho](04-medindo-desempenho.md) — o projeto `foco_desempenho` e o método
  de medir antes de mudar.
- [Módulo 06, aula 10 — Gestos e feedback](../06-widgets-e-layouts/10-gestos-e-feedback.md) —
  `tooltip` e alvos de toque.
- [Módulo 12, aula 6 — Testes de widget](../12-testes-e-debug/06-testes-de-widget.md) —
  `meetsGuideline` apareceu lá.
- Um aparelho Android para o TalkBack (o emulador serve, mas é desconfortável).

---

## 📖 Conceito

### Por que isso importa

Cerca de **uma em cada seis pessoas** no mundo vive com alguma deficiência. Mas o alcance é maior
que isso, porque acessibilidade não é só deficiência permanente:

| Situação | Quem é |
|---|---|
| Permanente | Cegueira, baixa visão, daltonismo, deficiência motora |
| Temporária | Braço quebrado, conjuntivite, pupila dilatada |
| Circunstancial | Sol na tela, ônibus balançando, uma mão ocupada, celular velho |

> 💡 **Quase todo mundo é usuário circunstancial de acessibilidade.** Contraste bom ajuda quem está
> no sol; alvo de toque grande ajuda quem está no ônibus; texto que não quebra com fonte grande
> ajuda quem esqueceu os óculos. **Corrigir acessibilidade melhora o app para todos.**

E há a parte legal: no Brasil, a **LBI (Lei 13.146/2015)** exige acessibilidade em sites e
aplicativos. Google Play e App Store também têm diretrizes próprias.

### A árvore de semântica

O Flutter mantém **duas árvores** em paralelo:

```text
Árvore de widgets              Árvore de semântica
─────────────────              ───────────────────
Scaffold                       (ignorado)
 └ Column                       └ (ignorado)
    ├ Text('Cálculo I')            ├ "Cálculo I"            ← label
    ├ Icon(Icons.star)             ├ (nada!)   ⚠️
    └ IconButton(                  └ "Adicionar, botão"     ← label + role
        icon: Icon(Icons.add),
        tooltip: 'Adicionar')
```

O leitor de tela lê a **segunda**. Um `Icon` sem rótulo simplesmente **não existe** para quem não
vê — e um `IconButton` sem `tooltip` é anunciado apenas como "botão", sem dizer o que faz.

```dart
// ❌ O usuário ouve: "botão".
IconButton(icon: const Icon(Icons.delete), onPressed: excluir)

// ✅ "Excluir matéria, botão"
IconButton(
  icon: const Icon(Icons.delete),
  tooltip: 'Excluir matéria',      // ← vira o rótulo semântico
  onPressed: excluir,
)
```

> 📌 **O `tooltip` faz dois trabalhos**: mostra a dica ao pressionar e longo, **e** vira o rótulo
> semântico. É a correção mais barata de acessibilidade que existe — uma linha por ícone.

### O widget `Semantics`

Quando não há `tooltip` nem texto, descreva à mão:

```dart
Semantics(
  label: 'Progresso da matéria Cálculo',
  value: '45 de 90 minutos, metade da meta',
  child: LinearProgressIndicator(value: 0.5),
)
```

As propriedades que você mais usa:

| Propriedade | Para quê |
|---|---|
| `label` | O nome do elemento |
| `value` | O valor atual |
| `hint` | O que acontece ao ativar |
| `button: true` | Anuncia como botão |
| `header: true` | Título de seção; permite navegar por títulos |
| `excludeSemantics: true` | Ignora os filhos e usa só o que você declarou |
| `liveRegion: true` | Reanuncia quando muda |
| `sortKey` | Ordem de leitura |
| `textField: true` | Anuncia como campo |

E os companheiros:

```dart
// Junta vários nós num só: "Cálculo I, 45 minutos" em vez de
// duas paradas separadas.
MergeSemantics(
  child: Row(children: <Widget>[Text(nome), Text('$minutos min')]),
)

// Esconde do leitor: decoração que não acrescenta nada.
ExcludeSemantics(child: Image.asset('assets/imagens/ornamento.png'))
```

> ⚠️ **`ExcludeSemantics` é uma faca de dois gumes.** Usado em decoração pura, limpa o ruído.
> Usado em conteúdo, **apaga informação** para quem não vê. Na dúvida, não exclua.

### Os quatro números

**1. Contraste — 4.5:1**

| Tipo de texto | Mínimo (WCAG AA) |
|---|---|
| Texto normal | **4.5:1** |
| Texto grande (≥18 pt, ou 14 pt negrito) | 3:1 |
| Ícone, borda, componente | 3:1 |
| AAA (ideal) | 7:1 |

```dart
// ❌ cinza claro em branco ≈ 2.3:1 — ilegível no sol
Text('Detalhe', style: TextStyle(color: Color(0xFFAAAAAA)))

// ✅ ≈ 4.6:1
Text('Detalhe', style: TextStyle(color: Color(0xFF6B6B6B)))
```

> 💡 **Use os papéis do `ColorScheme`** (`onSurface`, `onSurfaceVariant`, `onPrimary`) em vez de
> cores cruas. O Material 3 já garante contraste entre cada par `x`/`onX` — e você ganha o tema
> escuro de graça.

**2. Alvo de toque — 48 dp (Android) / 44 pt (iOS)**

```dart
// ❌ 24 × 24: difícil de acertar no ônibus, impossível com tremor
GestureDetector(onTap: …, child: const Icon(Icons.close, size: 24))

// ✅ o ícone continua 24; a ÁREA é 48
IconButton(
  icon: const Icon(Icons.close),
  tooltip: 'Fechar',
  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  onPressed: …,
)
```

> 📌 **O tamanho do ícone e o tamanho do alvo são coisas diferentes.** O ícone pode ser pequeno e
> bonito; a área tocável ao redor é que precisa ter 48 dp. `IconButton` já faz isso por padrão —
> `GestureDetector` em volta de um `Icon` não faz.

**3. Escala de fonte — até 200 %**

O usuário pode aumentar a fonte no sistema. O seu layout precisa aguentar.

```dart
// ❌ altura fixa: o texto é cortado com fonte grande
SizedBox(height: 48, child: Text(nome))

// ✅ cresce conforme necessário
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 48),
  child: Text(nome),
)
```

```dart
// ⚠️ Ignora a preferência do usuário. Só use com motivo forte.
MediaQuery.withNoTextScaling(child: const Text('logo'))

// ✅ Limita sem ignorar: respeita até 150 %.
MediaQuery.withClampedTextScaling(maxScaleFactor: 1.5, child: tela)
```

**4. Ordem e agrupamento**

O leitor de tela percorre a árvore numa ordem. Se ela não faz sentido, o app é confuso mesmo com
todos os rótulos certos. `MergeSemantics` e `sortKey` corrigem isso.

### Anunciar mudanças

Quando algo muda sem o usuário tocar, ele precisa ser avisado:

```dart
// Reanuncia automaticamente quando o texto muda.
Semantics(
  liveRegion: true,
  child: Text('$quantidade matérias'),
)

// Anúncio pontual, imperativo.
SemanticsService.announce(
  'Matéria excluída',
  TextDirection.ltr,
);
```

> 💡 Um `SnackBar` com "Matéria excluída" é **visual**. Sem `liveRegion` ou `announce`, quem usa
> leitor de tela não fica sabendo que a ação funcionou.

### Como testar

| Ferramenta | O que pega | Custo |
|---|---|---|
| `meetsGuideline` em teste | Contraste, alvo de toque, rótulo | ✅ Automático |
| `SemanticsDebugger` | A árvore, visualmente | ✅ Grátis |
| **TalkBack / VoiceOver** | **A experiência real** | ⚠️ Exige prática |
| Accessibility Scanner (Android) | Varredura na tela | ✅ Fácil |

```dart
MaterialApp(
  showSemanticsDebugger: true,   // desenha os nós de semântica sobre a tela
  home: const Inicio(),
)
```

**Ligar o TalkBack:**

```text
Configurações → Acessibilidade → TalkBack → Ativar
```

| Gesto no TalkBack | O que faz |
|---|---|
| Deslizar → | Próximo elemento |
| Deslizar ← | Anterior |
| **Toque duplo** | Ativa (o toque simples só seleciona) |
| Dois dedos deslizando | Rolar |
| Segurar volume ↑ e ↓ por 3 s | Liga/desliga o TalkBack |

> ⚠️ **O TalkBack muda todos os gestos** — um toque simples passa a apenas selecionar. Na primeira
> vez, é desconcertante: parece que o celular quebrou. **Decore o atalho de desligar** (segurar as
> duas teclas de volume por 3 segundos) antes de ligar.

> 📌 **Nenhum teste automático substitui cinco minutos com o TalkBack ligado.** A ferramenta pega
> contraste e tamanho; ela não percebe que a ordem de leitura está embaralhada, que o rótulo diz
> "botão 3" ou que o usuário não tem como saber que a ação deu certo.

---

## 💡 Analogia

Pense numa **rampa de acesso** num prédio.

- A rampa foi feita para cadeirantes. Mas quem mais a usa? **Carrinho de bebê, entregador com
  carrinho de carga, pessoa com mala, idoso com joelho ruim, você carregando uma caixa.** Isso é
  acessibilidade em software: a correção feita para uma minoria acaba servindo a quase todo mundo.
- **A árvore de semântica** é a **descrição do prédio para quem não o vê** — a planta em braile na
  entrada. Se uma sala não está na planta, ela não existe para quem depende dela. É o `Icon` sem
  rótulo.
- **O `tooltip`** é a plaquinha na porta. Uma porta sem plaquinha continua sendo porta — mas
  ninguém sabe se dá no banheiro ou na sala de máquinas. "Botão" é uma porta sem plaquinha.
- **O contraste** é a iluminação. Um corredor mal iluminado é transitável por alguém de vinte anos
  com visão perfeita, e um obstáculo para todo o resto.
- **O alvo de toque de 48 dp** é a largura da porta. Cabe você, e cabe você com uma caixa nas mãos.
  Uma porta de 24 cm tecnicamente "funciona" — para quem passa de lado, sem pressa, com as duas
  mãos livres.
- **A escala de fonte** é a placa de sinalização que precisa continuar legível quando ampliada. Um
  layout que quebra com fonte grande é uma placa cuja moldura corta as letras.
- **E o TalkBack** é **vendar os olhos e atravessar o prédio**. Nenhuma planta, nenhuma inspeção,
  nenhuma checklist mostra o que essa travessia mostra em cinco minutos.

---

## 🧪 Exemplo mínimo

O mesmo card, antes e depois.

> **Arquivo:** `foco_desempenho/lib/features/sessoes/presentation/sessao_screen.dart` (novo)
> **Como executar:** `flutter run -d windows` (e depois num Android, com o TalkBack ligado)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class SessaoScreen extends StatelessWidget {
  const SessaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessões')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          Text('❌ Antes', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _CardRuim(),
          SizedBox(height: 32),
          Text('✅ Depois', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _CardBom(),
        ],
      ),
    );
  }
}

/// ❌ Cinco problemas de acessibilidade, todos comuns.
class _CardRuim extends StatelessWidget {
  const _CardRuim();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            // 1. ❌ Ícone sem rótulo: NÃO EXISTE para o leitor de tela.
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),

            Expanded(
              // 2. ❌ Altura fixa: com fonte a 200%, o texto é cortado.
              child: SizedBox(
                height: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Cálculo I'),
                    // 3. ❌ Contraste ≈ 2.3:1 — ilegível no sol.
                    const Text(
                      '45 min · hoje',
                      style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // 4. ❌ Alvo de 24 dp: metade do mínimo.
            // 5. ❌ GestureDetector + Icon não é anunciado como botão.
            GestureDetector(
              onTap: () {},
              child: const Icon(Icons.delete, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Os mesmos elementos, acessíveis.
class _CardBom extends StatelessWidget {
  const _CardBom();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            // 1. ✅ Rótulo explícito no ícone informativo.
            Semantics(
              label: 'Matéria favorita',
              child: Icon(Icons.star, color: cores.primary),
            ),
            const SizedBox(width: 8),

            Expanded(
              // 2. ✅ MergeSemantics: uma parada de leitura em vez
              // de duas — "Cálculo I, 45 minutos, hoje".
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Cálculo I',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    // 3. ✅ onSurfaceVariant: contraste garantido
                    // pelo Material 3, e tema escuro de graça.
                    Text(
                      '45 min · hoje',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cores.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. ✅ IconButton: alvo de 48 dp por padrão.
            // 5. ✅ tooltip vira o rótulo: "Excluir sessão, botão".
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Excluir sessão de Cálculo I',
              onPressed: () {
                // 6. ✅ Anuncia o resultado: sem isto, quem usa
                // leitor de tela não sabe que a ação funcionou.
                SemanticsService.announce(
                  'Sessão excluída',
                  Directionality.of(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

**Como comparar:**

1. `MaterialApp(showSemanticsDebugger: true)` — veja quantos nós cada card gera.
2. Ligue o TalkBack e deslize entre os dois. Ouça a diferença.
3. Configurações → Tela → Tamanho da fonte → **máximo**. O card ruim corta o texto.

---

## 📱 Aplicando no Flutter

Agora um formulário e uma lista completos, acessíveis — e os testes que garantem que continuem.

---

## 💻 Código completo

> **Arquivo:** `foco_desempenho/lib/core/acessibilidade/contraste.dart` (novo)

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cálculo de contraste segundo a WCAG 2.1.
///
/// Serve para verificar as cores do tema em teste — em vez de
/// confiar no olho, que se engana com facilidade em tela boa.
abstract final class Contraste {
  /// Mínimo para texto normal.
  static const double minimoTextoNormal = 4.5;

  /// Mínimo para texto grande (≥18 pt, ou 14 pt negrito).
  static const double minimoTextoGrande = 3.0;

  /// Mínimo para ícones e bordas de componentes.
  static const double minimoComponente = 3.0;

  /// Razão de contraste entre duas cores: de 1:1 a 21:1.
  static double razao(Color a, Color b) {
    final double la = _luminancia(a);
    final double lb = _luminancia(b);

    final double clara = math.max(la, lb);
    final double escura = math.min(la, lb);

    // A fórmula da WCAG. O 0.05 evita divisão por zero
    // com preto puro.
    return (clara + 0.05) / (escura + 0.05);
  }

  static bool aprovaTextoNormal(Color texto, Color fundo) =>
      razao(texto, fundo) >= minimoTextoNormal;

  static bool aprovaTextoGrande(Color texto, Color fundo) =>
      razao(texto, fundo) >= minimoTextoGrande;

  /// Descrição legível, para usar em log e em mensagem de teste.
  static String descrever(Color texto, Color fundo) {
    final double r = razao(texto, fundo);
    final String nota = r >= 7
        ? 'AAA'
        : r >= 4.5
            ? 'AA'
            : r >= 3
                ? 'AA (só texto grande)'
                : 'REPROVADO';
    return '${r.toStringAsFixed(2)}:1 — $nota';
  }

  /// Luminância relativa, com a correção de gama da WCAG.
  ///
  /// Não é o brilho médio: os canais têm pesos diferentes porque
  /// o olho humano é muito mais sensível ao verde.
  static double _luminancia(Color c) {
    double canal(double v) {
      final double n = v;   // já vem normalizado de 0 a 1
      return n <= 0.03928 ? n / 12.92 : math.pow((n + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * canal(c.r) + 0.7152 * canal(c.g) + 0.0722 * canal(c.b);
  }
}
```

> **Arquivo:** `foco_desempenho/lib/features/sessoes/presentation/form_sessao_acessivel.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Formulário de sessão, acessível de ponta a ponta.
///
/// Cada decisão está comentada com o problema que ela resolve.
class FormSessaoAcessivel extends StatefulWidget {
  const FormSessaoAcessivel({super.key});

  @override
  State<FormSessaoAcessivel> createState() => _FormSessaoAcessivelState();
}

class _FormSessaoAcessivelState extends State<FormSessaoAcessivel> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();
  final TextEditingController _minutos = TextEditingController(text: '30');
  final FocusNode _focoMinutos = FocusNode();

  int _meta = 60;
  bool _salvando = false;

  @override
  void dispose() {
    _minutos.dispose();
    _focoMinutos.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) {
      // ⭐ Quem não vê a tela não vê a mensagem de erro em vermelho.
      // O anúncio é a única forma de saber que a validação falhou.
      SemanticsService.announce(
        'Formulário com erro. Verifique os minutos.',
        Directionality.of(context),
      );
      // E leva o foco para o campo com problema.
      _focoMinutos.requestFocus();
      return;
    }

    setState(() => _salvando = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _salvando = false);

    SemanticsService.announce(
      'Sessão de ${_minutos.text} minutos registrada',
      Directionality.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final double progresso =
        (int.tryParse(_minutos.text) ?? 0) / _meta;

    return Scaffold(
      appBar: AppBar(title: const Text('Nova sessão')),
      body: Form(
        key: _chave,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            // ── Título de seção ──────────────────────────────────
            // header: true permite navegar POR TÍTULOS no leitor
            // de tela — atalho essencial em tela longa.
            Semantics(
              header: true,
              child: Text(
                'Quanto você estudou?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),

            // ── Campo de minutos ─────────────────────────────────
            TextFormField(
              controller: _minutos,
              focusNode: _focoMinutos,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Minutos estudados',
                // O hint vira parte do anúncio: o leitor diz
                // "Minutos estudados, edição, entre 1 e 480".
                helperText: 'Entre 1 e 480',
                border: OutlineInputBorder(),
              ),
              validator: (String? v) {
                final int? n = int.tryParse(v ?? '');
                if (n == null) return 'Informe um número';
                if (n < 1 || n > 480) return 'Entre 1 e 480 minutos';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Progresso ────────────────────────────────────────
            // Uma barra visual não diz NADA para quem não vê.
            // O par label/value transforma-a em informação.
            Semantics(
              label: 'Progresso da meta diária',
              value: '${_minutos.text} de $_meta minutos, '
                  '${(progresso * 100).clamp(0, 100).round()} por cento',
              // liveRegion: reanuncia quando o valor muda.
              liveRegion: true,
              // Os filhos não têm semântica útil — só a nossa conta.
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Meta diária'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progresso.clamp(0.0, 1.0),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_minutos.text} / $_meta min',
                    // onSurfaceVariant garante 4.5:1 nos dois temas.
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cores.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Meta, com botões de ajuste ───────────────────────
            Row(
              children: <Widget>[
                const Expanded(child: Text('Ajustar meta')),

                // IconButton já tem 48 dp de alvo. O tooltip vira
                // o rótulo — e aqui ele diz o RESULTADO da ação,
                // não o nome do ícone.
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Diminuir meta em 15 minutos',
                  onPressed: _meta > 15
                      ? () {
                          setState(() => _meta -= 15);
                          SemanticsService.announce(
                            'Meta: $_meta minutos',
                            Directionality.of(context),
                          );
                        }
                      : null,
                ),

                // MergeSemantics para o número ser lido junto
                // com a unidade, não como "60" solto.
                MergeSemantics(
                  child: Row(
                    children: <Widget>[
                      Text('$_meta', style: const TextStyle(fontSize: 18)),
                      const Text(' min'),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Aumentar meta em 15 minutos',
                  onPressed: _meta < 480
                      ? () {
                          setState(() => _meta += 15);
                          SemanticsService.announce(
                            'Meta: $_meta minutos',
                            Directionality.of(context),
                          );
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Botão de salvar ──────────────────────────────────
            // ⚠️ Altura MÍNIMA, não fixa: com fonte a 200 %,
            // uma altura fixa cortaria o texto.
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    // Um indicador girando é mudo. O Semantics
                    // conta o que está acontecendo.
                    ? Semantics(
                        label: 'Salvando',
                        liveRegion: true,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Text('Registrar sessão'),
              ),
            ),
            const SizedBox(height: 16),

            // ── Decoração ────────────────────────────────────────
            // ExcludeSemantics: a ilustração não acrescenta NADA.
            // Sem isto, o leitor anunciaria "imagem" à toa.
            ExcludeSemantics(
              child: Icon(
                Icons.auto_stories_outlined,
                size: 64,
                color: cores.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

E os testes que impedem a regressão:

> **Arquivo:** `foco_desempenho/test/acessibilidade_test.dart` (novo)
> **Como executar:** `flutter test test/acessibilidade_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_desempenho/core/acessibilidade/contraste.dart';
import 'package:foco_desempenho/features/sessoes/presentation/form_sessao_acessivel.dart';

void main() {
  group('diretrizes automáticas', () {
    testWidgets('alvos de toque, contraste e rótulos',
        (WidgetTester tester) async {
      // ⚠️ A árvore de semântica não é construída por padrão
      // nos testes. Sem ensureSemantics, tudo passa à toa.
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        const MaterialApp(home: FormSessaoAcessivel()),
      );
      await tester.pumpAndSettle();

      // 48 dp no Android, 44 pt no iOS.
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      // 4.5:1 para texto normal.
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      // Todo elemento tocável precisa de rótulo.
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });

  group('rótulos', () {
    testWidgets('todo IconButton tem tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FormSessaoAcessivel()),
      );
      await tester.pumpAndSettle();

      final Iterable<IconButton> botoes =
          tester.widgetList<IconButton>(find.byType(IconButton));

      expect(botoes, isNotEmpty);
      for (final IconButton b in botoes) {
        expect(
          b.tooltip,
          isNotNull,
          reason: 'IconButton sem tooltip é anunciado só como "botão"',
        );
      }
    });

    testWidgets('a barra de progresso tem label e value',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        const MaterialApp(home: FormSessaoAcessivel()),
      );
      await tester.pumpAndSettle();

      // Uma barra sem label/value é invisível para quem não vê.
      expect(
        find.bySemanticsLabel('Progresso da meta diária'),
        findsOneWidget,
      );

      handle.dispose();
    });
  });

  group('escala de fonte', () {
    testWidgets('a tela não estoura com fonte a 200%',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          // 2.0 = o máximo que o Android permite.
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: const MaterialApp(home: FormSessaoAcessivel()),
        ),
      );
      await tester.pumpAndSettle();

      // tester.takeException devolve o erro de overflow, se houve.
      // Um RenderFlex overflow aqui significa altura fixa em
      // algum lugar.
      expect(tester.takeException(), isNull);
    });

    testWidgets('e com 150% também', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: const MaterialApp(home: FormSessaoAcessivel()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('contraste do tema', () {
    test('as cores do tema claro passam na WCAG AA', () {
      final ColorScheme c = ColorScheme.fromSeed(seedColor: Colors.indigo);

      // Cada par x/onX do Material 3 deve passar. Este teste pega
      // o dia em que alguém "ajustar" uma cor do tema.
      expect(
        Contraste.aprovaTextoNormal(c.onSurface, c.surface),
        isTrue,
        reason: Contraste.descrever(c.onSurface, c.surface),
      );
      expect(
        Contraste.aprovaTextoNormal(c.onPrimary, c.primary),
        isTrue,
        reason: Contraste.descrever(c.onPrimary, c.primary),
      );
      expect(
        Contraste.aprovaTextoNormal(c.onSurfaceVariant, c.surface),
        isTrue,
        reason: Contraste.descrever(c.onSurfaceVariant, c.surface),
      );
    });

    test('e as do tema escuro também', () {
      final ColorScheme c = ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      );

      expect(
        Contraste.aprovaTextoNormal(c.onSurface, c.surface),
        isTrue,
        reason: Contraste.descrever(c.onSurface, c.surface),
      );
    });

    test('cinza claro em branco REPROVA', () {
      // O caso do _CardRuim: ~2.3:1.
      final double r = Contraste.razao(
        const Color(0xFFBBBBBB),
        const Color(0xFFFFFFFF),
      );
      expect(r, lessThan(Contraste.minimoTextoNormal));
    });
  });
}
```

```powershell
flutter test test/acessibilidade_test.dart
flutter run -d windows        # com showSemanticsDebugger: true
# e, no Android, com o TalkBack ligado
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `Semantics(label:)` no ícone informativo | Um `Icon` sem rótulo **não existe** para o leitor de tela. |
| `tooltip` no `IconButton` | Faz dois trabalhos: dica visual **e** rótulo semântico. A correção mais barata. |
| Tooltip dizendo o **resultado** ("Diminuir meta em 15 minutos") | Melhor que o nome do ícone: o usuário quer saber o que **acontece**. |
| `MergeSemantics` | "Cálculo I, 45 minutos" numa parada, em vez de duas. |
| `onSurfaceVariant` em vez de cor crua | O Material 3 garante 4.5:1 em cada par `x`/`onX` — e o tema escuro vem junto. |
| `IconButton` em vez de `GestureDetector(child: Icon)` | 48 dp de alvo por padrão, e é anunciado como **botão**. |
| `ConstrainedBox(minHeight: 48)` | Altura **mínima**, não fixa: com fonte a 200 %, a fixa corta o texto. |
| `Semantics(label:, value:)` na barra de progresso | Uma barra visual é muda; o par transforma-a em informação. |
| `liveRegion: true` | Reanuncia quando o valor muda — sem isso, o usuário não percebe. |
| `SemanticsService.announce` na validação | Quem não vê a tela não vê a mensagem em vermelho. |
| `_focoMinutos.requestFocus()` no erro | Leva o leitor direto ao campo com problema. |
| `header: true` | Permite navegar por títulos — atalho essencial em tela longa. |
| `Semantics(label: 'Salvando')` no indicador | Um indicador girando é mudo. |
| `ExcludeSemantics` na ilustração | Sem isso, o leitor anuncia "imagem" à toa. |
| `tester.ensureSemantics()` no teste | **A árvore de semântica não é construída por padrão** nos testes — sem isso, tudo passa à toa. |
| `meetsGuideline(...)` | Quatro diretrizes verificadas automaticamente. |
| `textScaler: TextScaler.linear(2.0)` | 200 % é o máximo do Android; `takeException` pega o overflow. |
| `Contraste.razao` com correção de gama | Não é brilho médio: o verde pesa 0.7152 porque o olho é mais sensível a ele. |
| Teste do contraste do tema | Pega o dia em que alguém "ajustar" uma cor. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Leitor de tela | **TalkBack** | **VoiceOver** |
| Ligar | Config → Acessibilidade | Config → Acessibilidade, ou 3× no botão lateral |
| Atalho | Segurar os dois volumes por 3 s | Triplo clique no botão lateral |
| Alvo mínimo | **48 dp** | **44 pt** |
| Escala de fonte | Até 200 % | **Dynamic Type**, até ~310 % |
| Ativar elemento | Toque duplo | Toque duplo |
| Navegar | Deslizar ← → | Deslizar ← → |
| Varredura automática | Accessibility Scanner | Accessibility Inspector (Xcode) |

> ⚠️ **O iOS permite fontes bem maiores que o Android** — o Dynamic Type com "tamanhos de
> acessibilidade" chega a mais de 300 %. Um layout que aguenta 200 % no Android ainda pode quebrar
> no iPhone. Use `MediaQuery.withClampedTextScaling` se precisar de um teto, mas **prefira layouts
> que simplesmente crescem**.

> 💡 Os dois leitores de tela **anunciam de forma diferente**. O TalkBack diz "Excluir sessão,
> botão"; o VoiceOver diz "Excluir sessão, botão" também, mas a entonação e a ordem de alguns
> atributos mudam. Não escreva rótulos que dependam da ordem exata — escreva frases que funcionem
> soltas.

🪟 **No Windows**, você consegue: `SemanticsDebugger`, os testes de `meetsGuideline`, o teste de
escala de fonte e o cálculo de contraste. **Não** consegue: TalkBack e VoiceOver — e essa é a parte
que mais ensina. Um Android barato resolve metade disso.

---

## ⚠️ Erros comuns

### 1. `IconButton` sem `tooltip`

O usuário ouve só "botão".

**Correção:** `tooltip` sempre. Uma linha por ícone.

### 2. `GestureDetector` em volta de `Icon`

Alvo pequeno, e não é anunciado como botão.

**Correção:** `IconButton`, ou `Semantics(button: true)` + 48 dp.

### 3. Cor crua em vez do `ColorScheme`

Contraste baixo, e o tema escuro quebra.

**Correção:** `onSurface`, `onSurfaceVariant`, `onPrimary`.

### 4. Altura fixa em volta de texto

Corta com fonte grande.

**Correção:** `minHeight`, não `height`.

### 5. Barra de progresso sem `label`/`value`

Informação invisível para quem não vê.

**Correção:** `Semantics(label:, value:, liveRegion: true)`.

### 6. `SnackBar` como único aviso

É visual; o leitor de tela pode não anunciar.

**Correção:** `SemanticsService.announce` junto.

### 7. Esquecer `ensureSemantics()` no teste

O teste passa sem verificar nada.

**Correção:** `tester.ensureSemantics()` + `handle.dispose()`.

### 8. `ExcludeSemantics` em conteúdo

Apaga informação real.

**Correção:** só em decoração pura.

### 9. Rótulo que descreve o ícone

"Ícone de lixeira" não diz o que acontece.

**Correção:** descreva a **ação**: "Excluir sessão".

### 10. Ordem de leitura embaralhada

Rótulos certos, app confuso.

**Correção:** `MergeSemantics`, `sortKey`.

### 11. Confiar só no teste automático

Ele não percebe ordem ruim nem rótulo sem sentido.

**Correção:** cinco minutos de TalkBack.

### 12. Deixar acessibilidade para o fim

Vira refatoração grande.

**Correção:** `tooltip` e `ColorScheme` desde o primeiro widget.

---

## 🛠️ Exercício guiado

**Passo 1.** Crie `sessao_screen.dart` e ligue `showSemanticsDebugger: true`. Compare os dois cards.

**Passo 2.** Aumente a fonte do sistema ao máximo. Qual card corta o texto?

**Passo 3.** Ligue o TalkBack num Android. **Antes disso, decore o atalho de desligar.**

**Passo 4.** Deslize pelo card ruim. O que o TalkBack anuncia no ícone de estrela?

**Passo 5.** Deslize pelo card bom. Conte as paradas em cada um.

**Passo 6.** Crie `form_sessao_acessivel.dart` e navegue nele com o TalkBack.

**Passo 7.** Mude a meta com os botões. O anúncio acontece?

**Passo 8.** Aperte salvar com o campo inválido. Você fica sabendo do erro sem ver a tela?

**Passo 9.** Rode `acessibilidade_test.dart`. Depois remova um `tooltip` e rode de novo.

**Passo 10.** Remova o `ensureSemantics()` de um teste. Ele ainda passa? Por quê isso é grave?

---

## 📝 Exercícios independentes

→ Exercícios completos em
[exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md)

Faça os de **Aplicação** (tornar uma tela acessível), **Correção de bugs** (contraste e alvo) e
**Reflexão** (o que o teste automático não pega).

---

## 🏆 Desafio opcional

Faça uma **auditoria completa de acessibilidade** do app inteiro e produza um relatório.

Requisitos:

- Toda tela testada com `meetsGuideline` nas quatro diretrizes.
- Toda tela testada com `textScaler` a 1.0, 1.5 e 2.0.
- Um teste de contraste para cada par de cores do tema, claro e escuro.
- **Uma travessia com TalkBack por tela**, com anotações do que você ouviu.
- Um `ACESSIBILIDADE.md` com: o que passou, o que falhou, o que foi corrigido e o que ficou como
  dívida (com justificativa).
- Os testes rodando no CI.

Depois responda: quais problemas **só** apareceram com o TalkBack ligado? Por que nenhum teste
automático pegaria esses? E o que isso diz sobre confiar em ferramentas de varredura
automática?

---

## 📌 Resumo

- **Uma em cada seis pessoas** tem alguma deficiência — e quase todo mundo é usuário
  **circunstancial** de acessibilidade.
- O Flutter mantém uma **árvore de semântica** paralela; é ela que o leitor de tela lê.
- **Um `Icon` sem rótulo não existe** para quem não vê.
- **`tooltip` no `IconButton`** é a correção mais barata: vira o rótulo semântico.
- O tooltip deve descrever **a ação**, não o ícone: "Excluir sessão", não "lixeira".
- Os quatro números: **4.5:1** de contraste, **48 dp / 44 pt** de alvo, **200 %** de escala,
  ordem de leitura coerente.
- **Use o `ColorScheme`** (`onSurface`, `onSurfaceVariant`): contraste garantido e tema escuro de
  graça.
- **`minHeight`, nunca `height`** em volta de texto.
- `MergeSemantics` agrupa; `ExcludeSemantics` esconde **decoração** — nunca conteúdo.
- **`liveRegion`** e **`SemanticsService.announce`** avisam de mudanças que o usuário não viu.
- Nos testes, **`tester.ensureSemantics()` é obrigatório** — sem ele, tudo passa à toa.
- `meetsGuideline` cobre alvo, contraste e rótulo; `textScaler` pega layout que quebra.
- 🍎 O iOS permite fontes **bem maiores** que o Android: 200 % não é o teto lá.
- **Nenhum teste automático substitui cinco minutos com o TalkBack ligado.**

---

## ☑️ Checklist de domínio

- [ ] Sei ligar e desligar o TalkBack, e navegar com ele.
- [ ] Entendo a árvore de semântica.
- [ ] Ponho `tooltip` em todo `IconButton`.
- [ ] Meus rótulos descrevem a ação, não o ícone.
- [ ] Uso `ColorScheme` em vez de cores cruas.
- [ ] Verifico 4.5:1 nos dois temas.
- [ ] Meus alvos de toque têm 48 dp.
- [ ] Uso `minHeight` em vez de altura fixa.
- [ ] Barras e indicadores têm `label` e `value`.
- [ ] Anuncio mudanças com `liveRegion` ou `announce`.
- [ ] Uso `ensureSemantics()` nos testes.
- [ ] Testo com fonte a 200 %.
- [ ] Faço a travessia com leitor de tela antes de considerar pronto.

---

## 📚 Referências oficiais

- [Accessibility — docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)
- [Semantics class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [SemanticsService — api.flutter.dev](https://api.flutter.dev/flutter/semantics/SemanticsService-class.html)
- [AccessibilityGuideline — api.flutter.dev](https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html)
- [WCAG 2.1 — Contrast (Minimum)](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
- [Material Design — Accessibility](https://m3.material.io/foundations/accessible-design/overview)
- [TalkBack — support.google.com](https://support.google.com/accessibility/android/answer/6283677)
- [VoiceOver — support.apple.com](https://support.apple.com/guide/iphone/turn-on-and-practice-voiceover-iph3e2e415f/ios)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Medindo desempenho](04-medindo-desempenho.md) | [README](README.md) | [Aula 6 — Segurança mobile](06-seguranca-mobile.md) |
