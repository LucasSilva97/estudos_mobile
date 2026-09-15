# Aula 9 — Material × Cupertino

> **Módulo:** 11 - Recursos Nativos · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Decidir **quando adaptar e quando não** com um critério, em vez de intuição.
- Usar os widgets **`.adaptive`** que o Flutter oferece — e conhecer os limites deles.
- Detectar a plataforma com segurança: **`Theme.of(context).platform`**, `defaultTargetPlatform`,
  `Platform.isIOS` e `kIsWeb`.
- Escrever widgets adaptativos próprios (`BotaoAdaptativo`, `confirmarAdaptativo`) sem duplicar a
  tela.
- Medir o **custo real** de manter duas interfaces.
- Reconhecer o que **nunca** deve ser adaptado.

## ✅ Pré-requisitos

- [Módulo 05, aula 9 — Material e Cupertino](../05-introducao-ao-flutter/09-material-e-cupertino.md)
  — **essencial**: a decisão do curso (Material nas duas), `ColorScheme.fromSeed` e os widgets
  `.adaptive` foram apresentados lá. **Esta aula aprofunda**, não repete.
- [Aula 8 — Botão voltar e gestos](08-botao-voltar-e-gestos.md) — adaptação de comportamento.
- [Módulo 06, aula 10 — Gestos e feedback](../06-widgets-e-layouts/10-gestos-e-feedback.md) —
  diálogos e folhas.

---

## 📖 Conceito

### O critério: aparência × comportamento

O Módulo 05 disse que o curso usa Material nas duas plataformas. Isso deixa uma pergunta em aberto:
**onde vale a exceção?**

O critério que resolve:

> **Adapte o que o usuário faz com o dedo. Não adapte o que ele apenas vê.**

| Categoria | Adaptar? | Por quê |
|---|---|---|
| **Gestos e navegação** | ✅ **Sempre** | O automatismo do usuário está no dedo |
| **Controles que ele manipula** | ✅ Quando `.adaptive` existe | Switch, slider, seletor de data |
| **Diálogos e alertas** | ✅ Barato | Uma linha, e a expectativa é forte |
| **Cores e tipografia** | ❌ | É a sua marca, não a do sistema |
| **Layout e espaçamento** | ❌ | Duplica o trabalho sem ganho |
| **Ícones decorativos** | ❌ | Ninguém repara |
| **Ícones de ação do sistema** | ⚠️ `Icons.adaptive` | Compartilhar muda de símbolo |

A razão do critério está no que o usuário **aprendeu sem perceber**. Um usuário de iPhone arrasta da
borda para voltar sem pensar; ele não tem um automatismo sobre o raio do canto do botão.

> 📌 **A boa notícia:** a primeira linha — gestos e navegação — o **Flutter já adapta sozinho**.
> Transição de tela, seta de voltar, gesto de borda, física de rolagem: tudo vem pronto. O que
> sobra para você decidir é pouco.

### Os widgets `.adaptive` e seus limites

O Flutter oferece:

```dart
Switch.adaptive(value: v, onChanged: f)
CircularProgressIndicator.adaptive()
Slider.adaptive(value: v, onChanged: f)
Checkbox.adaptive(value: v, onChanged: f)
Radio.adaptive(value: v, groupValue: g, onChanged: f)
AlertDialog.adaptive(title: t, actions: a)
showAdaptiveDialog<T>(context: c, builder: b)
Icon(Icons.adaptive.share)
Icon(Icons.adaptive.arrow_back)
```

E aqui está o limite que não é óbvio:

> ⚠️ **`.adaptive` olha `Theme.of(context).platform`, não o sistema operacional.** Isso significa
> que ele funciona em **qualquer** plataforma — inclusive na web e no desktop, onde ele usa a
> variante Material por padrão.
>
> Significa também que a tecla `o` do terminal (que troca `TargetPlatform`) muda os widgets
> `.adaptive` — o que é ótimo para testar.

O que **não** existe em `.adaptive`, e às vezes se espera:

| Widget | Existe `.adaptive`? | Alternativa |
|---|---|---|
| `Switch`, `Slider`, `Checkbox`, `Radio` | ✅ | — |
| `AlertDialog`, `showDialog` | ✅ | — |
| `CircularProgressIndicator` | ✅ | — |
| **Botão** (`FilledButton`…) | ❌ | Escreva o seu |
| **Folha inferior** | ❌ | `showModalBottomSheet` × `showCupertinoModalPopup` |
| **Seletor de data** | ❌ | `showDatePicker` × `CupertinoDatePicker` |
| **Seletor de hora** | ❌ | `showTimePicker` × `CupertinoTimerPicker` |
| **Campo de texto** | ❌ | `TextField` × `CupertinoTextField` |
| **Barra de navegação** | ❌ | `NavigationBar` × `CupertinoTabBar` |

Para o que falta, a pergunta é sempre: **vale o custo?**

### Como detectar a plataforma

Quatro formas, com armadilhas diferentes:

```dart
// 1. ✅ A recomendada dentro de widgets.
final bool ehIOS = Theme.of(context).platform == TargetPlatform.iOS;

// 2. ✅ Fora de widgets (sem BuildContext).
final bool ehIOS = defaultTargetPlatform == TargetPlatform.iOS;

// 3. ⚠️ Quebra na web.
import 'dart:io';
final bool ehIOS = Platform.isIOS;

// 4. ✅ A forma segura de usar a 3.
final bool ehIOS = !kIsWeb && Platform.isIOS;
```

| Forma | Funciona na web | Respeita a tecla `o` | Precisa de `context` |
|---|---|---|---|
| `Theme.of(context).platform` | ✅ | ✅ | ✅ |
| `defaultTargetPlatform` | ✅ | ✅ | ❌ |
| `Platform.isIOS` | ❌ **lança** | ❌ | ❌ |
| `kIsWeb && Platform.isIOS` | ✅ | ❌ | ❌ |

> ⚠️ **`Platform.isIOS` sozinho lança na web:**
>
> ```text
> Unsupported operation: Platform._operatingSystem
> ```
>
> E o erro acontece em **tempo de execução**, não de compilação — então o app compila, publica, e
> quebra no primeiro usuário que abrir no navegador.

**A regra:** use `Theme.of(context).platform` dentro de widgets, `defaultTargetPlatform` fora. Só
use `Platform` quando precisar distinguir **macOS de Linux**, por exemplo — e sempre com `kIsWeb`
antes.

### O custo real de duas interfaces

Adaptar parece barato até você medir. Considere uma tela com formulário:

| Item | Uma UI | Duas UIs |
|---|---|---|
| Arquivos | 1 | 2 (ou 1 com muitos `if`) |
| Testes de widget | 1 conjunto | **2 conjuntos** |
| Revisão de design | 1 | 2 |
| Correção de um bug | 1 lugar | **2 lugares** (e um vai ser esquecido) |
| Funcionalidade nova | 1 vez | **2 vezes** |

E o custo que só aparece depois: **divergência**. Alguém corrige um bug na versão Material,
esquece a Cupertino, e por três meses os usuários de iPhone têm um comportamento diferente — que
ninguém percebe porque ninguém testa as duas.

> 💡 **A pergunta honesta:** *"eu vou conseguir manter isso em dia daqui a um ano, sozinho?"* Se a
> resposta for não, uma interface bem-feita vale mais que duas mal mantidas.

### O que nunca adaptar

| Item | Por quê |
|---|---|
| **Cores da marca** | Elas identificam o **seu** app, não o sistema |
| **Tipografia da marca** | Idem |
| **Estrutura de navegação** | Trocar abas por menu confunde quem usa nos dois |
| **Nomes e textos** | "Concluir" no iOS e "Salvar" no Android é gratuito |
| **Regras de negócio** | Óbvio, e acontece |
| **Formato de dados** | Idem |

E um caso específico que aparece muito:

```dart
// ❌ não adapte espaçamento
final double padding = ehIOS ? 16 : 12;
```

Ninguém vai notar — e você acabou de criar dois layouts para manter.

### Quando a adaptação completa **vale**

Para ser justo, há casos em que duas UIs é a decisão certa:

| Situação | Por quê |
|---|---|
| App de **grande empresa** com equipe por plataforma | O custo é absorvido |
| App cujo diferencial **é** parecer nativo | Ex.: um cliente de e-mail |
| Público **exclusivo** de uma plataforma | Aí não são duas UIs, é uma |
| App que **substitui** um nativo do sistema | Ex.: um discador, uma agenda |

Fora disso: uma interface, com adaptações pontuais de comportamento.

---

## 💡 Analogia

Pense em abrir uma filial da sua loja em outro país.

- **Os gestos e a navegação** são o **lado da rua em que se dirige** e o **sentido da porta
  giratória**. Ignorar isso não é estilo — é fazer o cliente esbarrar na porta. É por isso que essa
  categoria se adapta **sempre**.
- **Os controles que o cliente manipula** são as **torneiras do banheiro** e a **tomada da parede**.
  Ele mexe nelas sem pensar; a forma importa.
- **As cores e a tipografia** são a **sua marca**. A Starbucks não fica verde no Brasil e azul no
  Japão — ela é reconhecível justamente por **não** se adaptar.
- **O layout e o espaçamento** são a **largura dos corredores**. Ninguém entra numa loja e pensa
  "os corredores aqui têm 4 cm a mais que no meu país".
- **Manter duas lojas idênticas em países diferentes** parece o ideal — até você precisar mudar a
  vitrine. Agora são duas viagens, duas equipes, dois orçamentos. E, no mês em que o orçamento
  apertar, uma das duas fica com a vitrine de Natal em março.
- **`.adaptive`** é o fornecedor que já entrega a tomada no padrão de cada país. Custa o mesmo,
  vem certo. Onde ele não existe, você precisa decidir se contrata um eletricista local — ou se o
  adaptador universal resolve.

---

## 🧪 Exemplo mínimo

Cada categoria de adaptação, lado a lado, com a tecla `o` trocando a plataforma ao vivo.

> **Arquivo:** `foco_nativo/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome` — e aperte **`o`** no terminal

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AppAdaptativo());

class AppAdaptativo extends StatelessWidget {
  const AppAdaptativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: const TelaAdaptativa(),
    );
  }
}

class TelaAdaptativa extends StatefulWidget {
  const TelaAdaptativa({super.key});

  @override
  State<TelaAdaptativa> createState() => _TelaAdaptativaState();
}

class _TelaAdaptativaState extends State<TelaAdaptativa> {
  bool _ligado = true;
  double _valor = 0.5;
  bool _marcado = false;

  @override
  Widget build(BuildContext context) {
    // ✅ A forma recomendada dentro de widgets.
    //
    // Funciona na web, e RESPEITA a tecla `o` do terminal — o que
    // torna o teste trivial. `Platform.isIOS` falharia nas duas coisas.
    final TargetPlatform plataforma = Theme.of(context).platform;
    final bool ehIOS = plataforma == TargetPlatform.iOS;

    return Scaffold(
      appBar: AppBar(title: Text('Plataforma: ${plataforma.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const _Titulo('✅ ADAPTAR — controles que o dedo manipula'),

          ListTile(
            title: const Text('Switch.adaptive'),
            subtitle: Text(ehIOS ? 'CupertinoSwitch' : 'Switch Material'),
            trailing: Switch.adaptive(
              value: _ligado,
              onChanged: (bool v) => setState(() => _ligado = v),
            ),
          ),

          ListTile(
            title: const Text('Checkbox.adaptive'),
            trailing: Checkbox.adaptive(
              value: _marcado,
              onChanged: (bool? v) => setState(() => _marcado = v ?? false),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Slider.adaptive'),
                Slider.adaptive(
                  value: _valor,
                  onChanged: (double v) => setState(() => _valor = v),
                ),
              ],
            ),
          ),

          const ListTile(
            title: Text('CircularProgressIndicator.adaptive'),
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(),
            ),
          ),

          ListTile(
            title: const Text('showAdaptiveDialog'),
            subtitle: Text(
              ehIOS ? 'Botões empilhados' : 'Botões lado a lado',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _mostrarDialogo(context),
          ),

          ListTile(
            title: const Text('Icons.adaptive.share'),
            subtitle: const Text('O símbolo de compartilhar muda'),
            trailing: Icon(Icons.adaptive.share),
          ),

          const Divider(height: 32),
          const _Titulo('⚠️ NÃO EXISTE .adaptive — decida se vale'),

          ListTile(
            title: const Text('Botão'),
            subtitle: const Text('FilledButton × CupertinoButton'),
            trailing: _BotaoAdaptativo(
              rotulo: 'Salvar',
              aoTocar: () {},
            ),
          ),

          ListTile(
            title: const Text('Seletor de data'),
            subtitle: const Text('Calendário × rolete'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _escolherData(context, ehIOS),
          ),

          const Divider(height: 32),
          const _Titulo('❌ NÃO ADAPTAR — é a sua marca'),

          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Cores e tipografia',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elas identificam o SEU app, não o sistema. '
                    'A Starbucks não fica verde no Brasil e azul no Japão.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Espaçamento, layout e ícones decorativos também não. '
                'Ninguém entra num app e pensa "o padding aqui tem 4 px '
                'a mais que no outro sistema".',
              ),
            ),
          ),

          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '👆 Aperte "o" no terminal para trocar de plataforma '
                'e observar o que muda — e o que não muda.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogo(BuildContext context) async {
    // showAdaptiveDialog + AlertDialog.adaptive: uma linha cada,
    // e o diálogo fica com a cara certa nas duas plataformas.
    final bool? r = await showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog.adaptive(
        title: const Text('Excluir matéria?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (!context.mounted || r == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r ? 'Excluiu' : 'Cancelou')),
    );
  }

  Future<void> _escolherData(BuildContext context, bool ehIOS) async {
    if (!ehIOS) {
      // Material: calendário em grade.
      await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      return;
    }

    // Cupertino: o rolete. Não existe `.adaptive` para isto —
    // é preciso escrever os dois caminhos.
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext c) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(c),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: DateTime.now(),
          onDateTimeChanged: (DateTime d) {},
        ),
      ),
    );
  }
}

/// Botão adaptativo. Não existe `.adaptive` para botões.
class _BotaoAdaptativo extends StatelessWidget {
  const _BotaoAdaptativo({required this.rotulo, required this.aoTocar});

  final String rotulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final bool ehIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (ehIOS) {
      return CupertinoButton.filled(
        // Aperta o botão para caber na linha da lista.
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: aoTocar,
        child: Text(rotulo),
      );
    }

    return FilledButton(onPressed: aoTocar, child: Text(rotulo));
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(texto, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
```

**O roteiro:**

1. Rode e aperte **`o`** no terminal. Observe **o que muda**: switch, checkbox, slider, indicador,
   ícone de compartilhar, botão.
2. Observe **o que não muda**: cores, tipografia, espaçamento, estrutura da lista. É a decisão do
   curso funcionando.
3. Abra o diálogo nas duas plataformas: botões lado a lado × empilhados.
4. Abra o seletor de data nas duas: calendário × rolete. Repare que esse exigiu **dois caminhos de
   código** — é onde o custo aparece.

---

## 📱 Aplicando no Flutter

O `foco_nativo` ganha uma pequena biblioteca de adaptação — o mínimo necessário, aplicando o
critério da aula:

- `BotaoAdaptativo` — o que falta no `.adaptive`;
- `confirmarAdaptativo` — diálogo de confirmação;
- `mostrarFolhaAdaptativa` — folha de opções;
- `Plataforma` — detecção segura, em um lugar só.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/lib/core/adaptativo/plataforma.dart` (novo)
> **Como executar:** `flutter run`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Detecção de plataforma, em um lugar só.
///
/// Centralizar evita que metade do app use `Theme.of(context).platform`
/// e a outra metade use `Platform.isIOS` — que quebra na web.
abstract final class Plataforma {
  /// ✅ A forma recomendada DENTRO de widgets.
  ///
  /// Funciona na web e respeita a tecla `o` do terminal, que troca
  /// TargetPlatform — o que torna o teste trivial.
  static bool ehIOS(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS;

  static bool ehAndroid(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.android;

  /// ✅ FORA de widgets, quando não há BuildContext.
  ///
  /// Também funciona na web e respeita a tecla `o`.
  static bool get ehIOSGlobal => defaultTargetPlatform == TargetPlatform.iOS;

  /// A plataforma é de celular?
  ///
  /// Útil para decidir entre layout de toque e de mouse.
  static bool ehCelular(BuildContext context) {
    final TargetPlatform p = Theme.of(context).platform;
    return p == TargetPlatform.iOS || p == TargetPlatform.android;
  }

  /// A plataforma segue o padrão visual da Apple?
  ///
  /// macOS também usa Cupertino — esquecer isso faz o app de desktop
  /// da Apple parecer um app Android.
  static bool ehApple(BuildContext context) {
    final TargetPlatform p = Theme.of(context).platform;
    return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
  }

  /// ⚠️ Use `Platform` SÓ quando precisar distinguir sistemas que o
  /// TargetPlatform não separa — macOS de Linux, por exemplo.
  ///
  /// E SEMPRE com kIsWeb antes: `Platform.isIOS` sozinho lança
  /// `Unsupported operation: Platform._operatingSystem` na web —
  /// em tempo de EXECUÇÃO, não de compilação. O app compila,
  /// publica, e quebra no primeiro usuário que abrir no navegador.
  static bool get rodaNaWeb => kIsWeb;
}
```

> **Arquivo:** `foco_nativo/lib/core/adaptativo/botao_adaptativo.dart` (novo)

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:foco_nativo/core/adaptativo/plataforma.dart';

/// Ênfase do botão, na linguagem do produto.
///
/// O widget traduz para o que cada plataforma usa — a tela não precisa
/// saber se existe `FilledButton` ou `CupertinoButton`.
enum EnfaseDoBotao {
  /// A ação principal da tela. Uma por tela.
  primaria,

  /// Ação importante, mas não a principal.
  secundaria,

  /// Ação de saída, link, ação dentro de diálogo.
  discreta,
}

/// Botão adaptativo.
///
/// Existe porque o Flutter NÃO tem `FilledButton.adaptive`. Os botões
/// são o caso mais comum de adaptação manual — e o que mais compensa,
/// porque o usuário toca neles o tempo todo.
class BotaoAdaptativo extends StatelessWidget {
  const BotaoAdaptativo({
    super.key,
    required this.rotulo,
    required this.aoTocar,
    this.enfase = EnfaseDoBotao.primaria,
    this.icone,
    this.carregando = false,
    this.larguraTotal = false,
  });

  final String rotulo;

  /// `null` desabilita o botão — nas duas plataformas.
  final VoidCallback? aoTocar;

  final EnfaseDoBotao enfase;
  final IconData? icone;

  /// Mostra indicador e desabilita. Impede envio duplicado.
  final bool carregando;

  final bool larguraTotal;

  @override
  Widget build(BuildContext context) {
    final Widget conteudo = _conteudo(context);
    final VoidCallback? acao = carregando ? null : aoTocar;

    final Widget botao = Plataforma.ehApple(context)
        ? _cupertino(context, conteudo, acao)
        : _material(conteudo, acao);

    return larguraTotal
        ? SizedBox(width: double.infinity, child: botao)
        : botao;
  }

  // ── Material ─────────────────────────────────────────────────────────────

  Widget _material(Widget conteudo, VoidCallback? acao) {
    return switch (enfase) {
      EnfaseDoBotao.primaria =>
        FilledButton(onPressed: acao, child: conteudo),
      EnfaseDoBotao.secundaria =>
        OutlinedButton(onPressed: acao, child: conteudo),
      EnfaseDoBotao.discreta =>
        TextButton(onPressed: acao, child: conteudo),
    };
  }

  // ── Cupertino ────────────────────────────────────────────────────────────

  Widget _cupertino(
    BuildContext context,
    Widget conteudo,
    VoidCallback? acao,
  ) {
    return switch (enfase) {
      // .filled é o equivalente do FilledButton.
      EnfaseDoBotao.primaria =>
        CupertinoButton.filled(onPressed: acao, child: conteudo),

      // O iOS não tem botão "contornado". A convenção é usar o botão
      // de texto com cor de destaque — insistir num contorno faria o
      // app parecer Android pintado de azul.
      EnfaseDoBotao.secundaria => CupertinoButton(
          onPressed: acao,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
            child: conteudo,
          ),
        ),

      EnfaseDoBotao.discreta =>
        CupertinoButton(onPressed: acao, child: conteudo),
    };
  }

  // ── Conteúdo ─────────────────────────────────────────────────────────────

  Widget _conteudo(BuildContext context) {
    if (carregando) {
      return const SizedBox(
        width: 18,
        height: 18,
        // .adaptive: arco no Android, "pás" no iOS. Uma palavra.
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      );
    }

    if (icone == null) return Text(rotulo);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icone, size: 18),
        const SizedBox(width: 8),
        Text(rotulo),
      ],
    );
  }
}
```

> **Arquivo:** `foco_nativo/lib/core/adaptativo/dialogos_adaptativos.dart` (novo)

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:foco_nativo/core/adaptativo/plataforma.dart';

/// Diálogo de confirmação, adaptado.
///
/// Usa `showAdaptiveDialog` + `AlertDialog.adaptive`: o Flutter cuida
/// da diferença visual (botões lado a lado × empilhados) sem você
/// escrever dois caminhos.
///
/// Devolve `false` quando o usuário fecha sem escolher — a escolha
/// segura em ação destrutiva.
Future<bool> confirmarAdaptativo(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String rotuloConfirmar = 'Confirmar',
  String rotuloCancelar = 'Cancelar',
  bool destrutivo = false,
}) async {
  final bool? resposta = await showAdaptiveDialog<bool>(
    context: context,
    builder: (BuildContext c) {
      final bool ehApple = Plataforma.ehApple(c);

      return AlertDialog.adaptive(
        title: Text(titulo),
        content: Text(mensagem),
        actions: <Widget>[
          // No iOS, a AÇÃO DESTRUTIVA fica em vermelho e o cancelar
          // em negrito — o oposto do Material, onde o destaque
          // vai para a ação principal.
          if (ehApple) ...<Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(c).pop(false),
              // isDefaultAction deixa em negrito: no iOS, a saída
              // segura é a destacada.
              isDefaultAction: true,
              child: Text(rotuloCancelar),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(c).pop(true),
              isDestructiveAction: destrutivo,
              child: Text(rotuloConfirmar),
            ),
          ] else ...<Widget>[
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(rotuloCancelar),
            ),
            FilledButton(
              style: destrutivo
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(c).colorScheme.error,
                      foregroundColor: Theme.of(c).colorScheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(rotuloConfirmar),
            ),
          ],
        ],
      );
    },
  );

  // null = tocou fora ou apertou voltar. Tratar como "não" é a
  // escolha segura.
  return resposta ?? false;
}

/// Uma opção de uma folha de ações.
class OpcaoDeFolha<T> {
  const OpcaoDeFolha({
    required this.rotulo,
    required this.valor,
    this.icone,
    this.destrutiva = false,
  });

  final String rotulo;
  final T valor;
  final IconData? icone;
  final bool destrutiva;
}

/// Folha de opções, adaptada.
///
/// NÃO existe `.adaptive` para folhas: é preciso escrever os dois
/// caminhos. Vale o custo porque a diferença é grande — o iOS usa
/// um ActionSheet com formato bem distinto.
Future<T?> mostrarFolhaAdaptativa<T>(
  BuildContext context, {
  required List<OpcaoDeFolha<T>> opcoes,
  String? titulo,
  String? mensagem,
}) {
  if (Plataforma.ehApple(context)) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext c) => CupertinoActionSheet(
        title: titulo == null ? null : Text(titulo),
        message: mensagem == null ? null : Text(mensagem),
        actions: <Widget>[
          for (final OpcaoDeFolha<T> o in opcoes)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(c).pop(o.valor),
              isDestructiveAction: o.destrutiva,
              child: Text(o.rotulo),
            ),
        ],
        // No iOS, o "Cancelar" fica SEPARADO, embaixo. É a convenção —
        // colocá-lo na lista faria o usuário procurá-lo no lugar errado.
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(c).pop(),
          isDefaultAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext c) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (titulo != null)
            ListTile(
              title: Text(titulo, style: Theme.of(c).textTheme.titleMedium),
              subtitle: mensagem == null ? null : Text(mensagem),
            ),
          if (titulo != null) const Divider(height: 1),
          for (final OpcaoDeFolha<T> o in opcoes)
            ListTile(
              leading: o.icone == null
                  ? null
                  : Icon(
                      o.icone,
                      color: o.destrutiva
                          ? Theme.of(c).colorScheme.error
                          : null,
                    ),
              title: Text(
                o.rotulo,
                style: o.destrutiva
                    ? TextStyle(color: Theme.of(c).colorScheme.error)
                    : null,
              ),
              onTap: () => Navigator.of(c).pop(o.valor),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Seletor de data, adaptado.
///
/// Este é o caso em que o custo da adaptação é MAIS VISÍVEL: dois
/// caminhos completamente diferentes, sem nada em comum.
///
/// Vale o custo porque o rolete do iOS é uma expectativa forte —
/// um calendário em grade num iPhone parece um app de Android.
Future<DateTime?> escolherDataAdaptativa(
  BuildContext context, {
  required DateTime inicial,
  DateTime? minima,
  DateTime? maxima,
}) async {
  final DateTime min = minima ?? DateTime(2020);
  final DateTime max = maxima ?? DateTime(2035);

  if (!Plataforma.ehApple(context)) {
    return showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: min,
      lastDate: max,
    );
  }

  DateTime escolhida = inicial;

  final bool? confirmou = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (BuildContext c) => Container(
      height: 320,
      color: CupertinoColors.systemBackground.resolveFrom(c),
      child: Column(
        children: <Widget>[
          // O ActionSheet do iOS não tem botões próprios: é preciso
          // montar a barra de confirmação à mão.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                  onPressed: () => Navigator.of(c).pop(false),
                  child: const Text('Cancelar'),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.of(c).pop(true),
                  child: const Text('Concluir'),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: inicial,
              minimumDate: min,
              maximumDate: max,
              onDateTimeChanged: (DateTime d) => escolhida = d,
            ),
          ),
        ],
      ),
    ),
  );

  return (confirmou ?? false) ? escolhida : null;
}
```

> **Arquivo:** `foco_nativo/lib/features/materias/presentation/materia_card.dart` (usando)

```dart
import 'package:flutter/material.dart';

import 'package:foco_nativo/core/adaptativo/botao_adaptativo.dart';
import 'package:foco_nativo/core/adaptativo/dialogos_adaptativos.dart';

/// Um cartão de matéria.
///
/// Repare no que este arquivo NÃO tem: nenhum `if (ehIOS)`, nenhum
/// import de `cupertino.dart`. A adaptação está encapsulada nos
/// widgets do `core/adaptativo/`.
///
/// É isso que torna a adaptação sustentável: ela acontece em 3
/// arquivos, não em 30 telas.
class MateriaCard extends StatelessWidget {
  const MateriaCard({
    super.key,
    required this.nome,
    required this.minutos,
    required this.aoExcluir,
  });

  final String nome;
  final int minutos;
  final VoidCallback aoExcluir;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(nome, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('$minutos minutos'),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                BotaoAdaptativo(
                  rotulo: 'Estudar',
                  icone: Icons.play_arrow,
                  aoTocar: () {},
                ),
                const SizedBox(width: 8),
                BotaoAdaptativo(
                  rotulo: 'Opções',
                  enfase: EnfaseDoBotao.discreta,
                  aoTocar: () => _abrirOpcoes(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirOpcoes(BuildContext context) async {
    final String? acao = await mostrarFolhaAdaptativa<String>(
      context,
      titulo: nome,
      opcoes: <OpcaoDeFolha<String>>[
        const OpcaoDeFolha<String>(
          rotulo: 'Editar',
          valor: 'editar',
          icone: Icons.edit_outlined,
        ),
        const OpcaoDeFolha<String>(
          rotulo: 'Excluir',
          valor: 'excluir',
          icone: Icons.delete_outline,
          destrutiva: true,
        ),
      ],
    );

    if (acao != 'excluir' || !context.mounted) return;

    final bool confirmou = await confirmarAdaptativo(
      context,
      titulo: 'Excluir $nome?',
      mensagem: 'As sessões registradas também serão apagadas.',
      rotuloConfirmar: 'Excluir',
      destrutivo: true,
    );

    if (confirmou) aoExcluir();
  }
}
```

> **Arquivo:** `foco_nativo/test/adaptativo_test.dart` (novo)

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_nativo/core/adaptativo/botao_adaptativo.dart';

void main() {
  /// Monta o widget forçando uma plataforma.
  ///
  /// `ThemeData(platform: ...)` é o que permite testar as duas UIs
  /// sem emulador — e é o mesmo mecanismo que a tecla `o` usa.
  Widget montar(Widget filho, TargetPlatform plataforma) {
    return MaterialApp(
      theme: ThemeData(platform: plataforma),
      home: Scaffold(body: Center(child: filho)),
    );
  }

  group('BotaoAdaptativo', () {
    testWidgets('no Android usa FilledButton', (WidgetTester t) async {
      await t.pumpWidget(montar(
        BotaoAdaptativo(rotulo: 'Salvar', aoTocar: () {}),
        TargetPlatform.android,
      ));

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
    });

    testWidgets('no iOS usa CupertinoButton', (WidgetTester t) async {
      await t.pumpWidget(montar(
        BotaoAdaptativo(rotulo: 'Salvar', aoTocar: () {}),
        TargetPlatform.iOS,
      ));

      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('no macOS também usa Cupertino', (WidgetTester t) async {
      // Esquecer o macOS faz o app de desktop da Apple parecer
      // um app Android.
      await t.pumpWidget(montar(
        BotaoAdaptativo(rotulo: 'Salvar', aoTocar: () {}),
        TargetPlatform.macOS,
      ));

      expect(find.byType(CupertinoButton), findsOneWidget);
    });

    testWidgets('carregando desabilita nas DUAS plataformas',
        (WidgetTester t) async {
      for (final TargetPlatform p in <TargetPlatform>[
        TargetPlatform.android,
        TargetPlatform.iOS,
      ]) {
        bool tocou = false;
        await t.pumpWidget(montar(
          BotaoAdaptativo(
            rotulo: 'Salvar',
            carregando: true,
            aoTocar: () => tocou = true,
          ),
          p,
        ));

        await t.tap(find.byType(BotaoAdaptativo));
        await t.pump();

        expect(tocou, isFalse, reason: 'em ${p.name}');
      }
    });

    testWidgets('o rótulo é o mesmo nas duas', (WidgetTester t) async {
      // A adaptação é de APARÊNCIA. Textos diferentes por plataforma
      // seriam adaptação gratuita — e uma fonte de divergência.
      for (final TargetPlatform p in <TargetPlatform>[
        TargetPlatform.android,
        TargetPlatform.iOS,
      ]) {
        await t.pumpWidget(montar(
          BotaoAdaptativo(rotulo: 'Criar matéria', aoTocar: () {}),
          p,
        ));
        expect(find.text('Criar matéria'), findsOneWidget);
      }
    });
  });
}
```

Rode:

```powershell
flutter analyze
flutter test test/adaptativo_test.dart
flutter run -d chrome
```

Com o app rodando, aperte **`o`** e observe: os botões, os switches e os diálogos mudam; as cores,
a tipografia e o layout **não**.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `Plataforma` centralizando a detecção | Evita metade do app usar `Theme.of(context).platform` e a outra `Platform.isIOS` — que quebra na web. |
| `Theme.of(context).platform` como padrão | Funciona na web **e** respeita a tecla `o`, o que torna o teste trivial. |
| `ehApple` incluindo `macOS` | Esquecer o macOS faz o app de desktop da Apple parecer Android. |
| Comentário sobre `Platform.isIOS` lançar na web | O erro é de **execução**, não de compilação: o app compila, publica e quebra no navegador. |
| `EnfaseDoBotao` em vez de "tipo de botão" | A tela pede **ênfase**; o widget traduz para `FilledButton` ou `CupertinoButton.filled`. |
| Cupertino sem botão "contornado" | O iOS não tem esse padrão. Insistir num contorno faria o app parecer Android pintado de azul. |
| `aoTocar: null` desabilitando | Funciona igual nas duas plataformas — sem `if`. |
| `CircularProgressIndicator.adaptive` dentro do botão | Uma palavra resolve o indicador; o botão em volta é que precisou de código. |
| `isDefaultAction: true` no **Cancelar** (iOS) | No iOS a saída **segura** é a destacada — o oposto do Material. |
| `cancelButton` separado no `CupertinoActionSheet` | Convenção do iOS: o Cancelar fica embaixo, destacado. Colocá-lo na lista faria o usuário procurá-lo no lugar errado. |
| `escolherDataAdaptativa` com dois caminhos completos | O caso em que o custo da adaptação **mais aparece**: nada é compartilhado. |
| Barra de Cancelar/Concluir montada à mão no iOS | O `CupertinoDatePicker` não traz botões. |
| `MateriaCard` **sem nenhum `if (ehIOS)`** | A adaptação vive em 3 arquivos do `core/`, não nas 30 telas. É isso que a torna sustentável. |
| `ThemeData(platform: ...)` nos testes | Permite testar as duas UIs **sem emulador** — o mesmo mecanismo da tecla `o`. |
| Teste "o rótulo é o mesmo nas duas" | Garante que a adaptação seja de **aparência**, não de texto. Texto diferente por plataforma é divergência gratuita. |

---

## 🤖🍎 Android × iOS

O que o Flutter adapta **sozinho**, sem você escrever nada:

| Item | Como muda |
|---|---|
| Transição entre telas | Zoom (Android) × deslizar lateral (iOS) |
| Seta de voltar | `←` × `‹` com o título da tela anterior |
| Gesto de arrastar da borda | Só no iOS, automático |
| Rolar além do fim | *Glow* × *bounce* |
| Velocidade da inércia da rolagem | Diferente |
| Fonte padrão | Roboto × SF Pro |
| Título da `AppBar` | À esquerda × centralizado |
| Barra de rolagem | Estilo diferente |

E o que você precisa decidir:

| Item | `.adaptive` existe? | Vale adaptar? |
|---|---|---|
| Switch, checkbox, slider, radio | ✅ | ✅ sempre — é uma palavra |
| Indicador de progresso | ✅ | ✅ |
| Diálogo de alerta | ✅ | ✅ |
| Ícone de compartilhar/voltar | ✅ `Icons.adaptive` | ✅ |
| **Botão** | ❌ | ✅ — o usuário toca o tempo todo |
| **Folha de opções** | ❌ | ✅ — a diferença é grande |
| **Seletor de data/hora** | ❌ | ✅ — o rolete é expectativa forte no iOS |
| **Campo de texto** | ❌ | ⚠️ raramente compensa |
| **Barra de navegação** | ❌ | ❌ muda a estrutura do app |

> 📌 **Repare no tamanho da primeira tabela.** A maior parte da "sensação de nativo" vem de coisas
> que o Flutter já faz. É por isso que a decisão do curso — Material nas duas, com adaptações
> pontuais — incomoda menos do que parece.

---

## ⚠️ Erros comuns

### 1. `Platform.isIOS` sem `kIsWeb`

```dart
import 'dart:io';
if (Platform.isIOS) { ... }   // ❌
```

```text
Unsupported operation: Platform._operatingSystem
```

Em tempo de **execução**, na web.

**Correção:** `Theme.of(context).platform`.

### 2. Esquecer o macOS

```dart
final bool cupertino = plataforma == TargetPlatform.iOS;   // ⚠️
```

O app de desktop da Apple fica com cara de Android.

**Correção:** inclua `macOS`.

### 3. Espalhar `if (ehIOS)` pelas telas

```dart
// em 30 arquivos diferentes ⚠️
final double padding = ehIOS ? 16 : 12;
```

Impossível de manter, e ninguém nota a diferença.

**Correção:** encapsule em widgets do `core/adaptativo/`, e **não adapte espaçamento**.

### 4. Adaptar cores e tipografia

```dart
final Color primaria = ehIOS ? CupertinoColors.activeBlue : Colors.indigo;   // ❌
```

A marca é sua. Adaptar destrói a identidade.

### 5. Adaptar textos

```dart
final String rotulo = ehIOS ? 'Concluir' : 'Salvar';   // ⚠️
```

Custo de manutenção, zero ganho — e dois lugares para traduzir.

### 6. Duplicar a tela inteira

```dart
return ehIOS ? const TelaIOS() : const TelaAndroid();   // ⚠️
```

Dois arquivos, dois conjuntos de testes, e um bug corrigido só em um deles.

**Correção:** uma tela, com widgets adaptativos dentro.

### 7. `showDialog` em vez de `showAdaptiveDialog`

Perde a adaptação de graça.

**Correção:** `showAdaptiveDialog` + `AlertDialog.adaptive`.

### 8. Botões do diálogo iOS na ordem Material

No iOS, o **Cancelar** é a ação destacada (`isDefaultAction`); no Material, a ação principal é a
destacada.

**Correção:** trate os dois casos, como faz o `confirmarAdaptativo`.

### 9. `cancelButton` dentro de `actions` no `CupertinoActionSheet`

O usuário procura o Cancelar no lugar errado.

**Correção:** use o parâmetro `cancelButton`.

### 10. Testar só uma plataforma

O bug aparece em produção, na plataforma que você não testa.

**Correção:** `ThemeData(platform: ...)` nos testes, para as duas.

### 11. Adaptar a estrutura de navegação

Abas no Android, menu lateral no iOS: quem usa nos dois aparelhos fica perdido.

**Correção:** a mesma estrutura em todo lugar.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e aperte `o`. Liste tudo que mudou e tudo que não mudou.

**Passo 2.** No `BotaoAdaptativo`, remova o caso `macOS` do `ehApple`. Rode com
`flutter run -d macos` (se tiver um Mac) ou force `TargetPlatform.macOS` num teste. O que acontece?

**Passo 3.** Troque `Theme.of(context).platform` por `Platform.isIOS` no `Plataforma`. Rode
`flutter run -d chrome` e leia o erro.

**Passo 4.** Aperte `o` com a versão do passo 3 (sem a web). O botão muda? Explique por quê.

**Passo 5.** No `confirmarAdaptativo`, remova o `isDefaultAction: true` do Cancelar no iOS. Abra o
diálogo em modo iOS e compare com um diálogo nativo do sistema.

**Passo 6.** No `mostrarFolhaAdaptativa`, mova o Cancelar para dentro de `actions`. Abra em modo
iOS e observe onde ele aparece.

**Passo 7.** Conte quantos arquivos do `foco_nativo` importam `cupertino.dart`. Depois conte quantas
telas. A proporção diz algo sobre a sustentabilidade da abordagem.

**Passo 8.** Escreva um teste que confirme que `confirmarAdaptativo` devolve `false` quando o
usuário toca fora, nas duas plataformas.

**Passo 9.** Adapte o espaçamento de um cartão (`ehIOS ? 20 : 16`). Mostre as duas versões para
alguém e pergunte qual é qual.

**Passo 10.** Responda por escrito: você tem 6 meses e trabalha sozinho. Vale adaptar o campo de
texto (`TextField` × `CupertinoTextField`)? Justifique com base no critério da aula.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os exercícios de **Decisão** sobre o que adaptar, o de **Correção de bugs** com
`Platform.isIOS` na web, e o de **Aplicação** com widget adaptativo próprio.

---

## 🏆 Desafio opcional

Crie um **catálogo adaptativo** no `foco_nativo`: uma tela que mostra **todos** os componentes do
app lado a lado, nas duas plataformas, ao mesmo tempo.

Requisitos:

- Duas colunas: "Android" e "iOS", cada uma envolvida num `Theme` com `platform` forçado.
- Mostra: botões (3 ênfases), switch, checkbox, slider, indicador, campo de texto, diálogo, folha.
- Um botão "abrir diálogo" em cada coluna, mostrando a versão correspondente.
- A tela só existe em **debug** (use `kDebugMode`), para não ir para a produção.
- Um teste de *golden* (captura de tela) para cada coluna, que falha se algo mudar sem querer.

Dica: envolver uma subárvore em `Theme(data: ThemeData(platform: TargetPlatform.iOS), child: ...)`
faz todo o `.adaptive` daquela subárvore usar Cupertino — mesmo rodando no Android.

Depois responda: quantos componentes do seu app **precisariam** de adaptação e ainda não têm? E
quantos você adaptou **sem precisar**?

---

## 📌 Resumo

- **O critério:** adapte o que o usuário **faz com o dedo**; não adapte o que ele **apenas vê**.
- **O Flutter já adapta sozinho** o mais importante: transições, seta de voltar, gesto de borda,
  física de rolagem, fonte, posição do título.
- Widgets **`.adaptive`** existem para switch, checkbox, slider, radio, indicador de progresso,
  diálogo e alguns ícones. São **uma palavra** — use sempre.
- **Não existe `.adaptive`** para botão, folha de opções, seletor de data e campo de texto. Para
  esses, decida se vale.
- **`Theme.of(context).platform`** dentro de widgets; **`defaultTargetPlatform`** fora.
  **`Platform.isIOS` lança na web** — em tempo de execução.
- Inclua **`macOS`** quando adaptar para Apple.
- **Nunca adapte:** cores, tipografia, espaçamento, textos, estrutura de navegação, regras de
  negócio.
- **Encapsule a adaptação** em poucos widgets do `core/`. Espalhar `if (ehIOS)` por 30 telas é
  insustentável.
- O custo de duas UIs é: dois conjuntos de testes, duas revisões, dois lugares para corrigir cada
  bug — e **divergência garantida** com o tempo.
- Teste as duas plataformas com **`ThemeData(platform: ...)`**, sem emulador.
- A pergunta honesta: *"eu vou manter isso em dia daqui a um ano, sozinho?"*

---

## ☑️ Checklist de domínio

- [ ] Aplico o critério "dedo × olho" para decidir o que adaptar.
- [ ] Sei o que o Flutter já adapta sozinho.
- [ ] Uso todos os widgets `.adaptive` disponíveis.
- [ ] Sei quais componentes **não** têm `.adaptive`.
- [ ] Uso `Theme.of(context).platform`, nunca `Platform.isIOS` sem `kIsWeb`.
- [ ] Incluo `macOS` na detecção de Apple.
- [ ] Nunca adapto cores, tipografia, espaçamento ou textos.
- [ ] Encapsulo a adaptação em poucos widgets do `core/`.
- [ ] Nenhuma tela do meu app tem `if (ehIOS)` solto.
- [ ] Trato a inversão de destaque nos botões do diálogo iOS.
- [ ] Testo as duas plataformas com `ThemeData(platform: ...)`.
- [ ] Sei estimar o custo de manutenção antes de adaptar.

---

## 📚 Referências oficiais

- [Platform adaptations — docs.flutter.dev](https://docs.flutter.dev/platform-integration/platform-adaptations)
- [Adaptive design — docs.flutter.dev](https://docs.flutter.dev/ui/adaptive-responsive)
- [Cupertino widgets — docs.flutter.dev](https://docs.flutter.dev/ui/widgets/cupertino)
- [TargetPlatform — api.flutter.dev](https://api.flutter.dev/flutter/foundation/TargetPlatform.html)
- [defaultTargetPlatform — api.flutter.dev](https://api.flutter.dev/flutter/foundation/defaultTargetPlatform.html)
- [Human Interface Guidelines — developer.apple.com](https://developer.apple.com/design/human-interface-guidelines)
- [Material 3 — m3.material.io](https://m3.material.io/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 8 — Botão voltar e gestos](08-botao-voltar-e-gestos.md) | [README](README.md) | [Aula 10 — Avaliando pacotes](10-avaliando-pacotes.md) |
