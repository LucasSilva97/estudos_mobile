# Aula 8 — UX de formulários

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Escrever mensagens de erro que **ajudam a corrigir** em vez de culpar o usuário.
- Decidir **quando** validar cada tipo de campo, e por que a resposta não é a mesma para todos.
- Usar `labelText`, `hintText` e `helperText` com o propósito certo de cada um.
- Marcar campos **obrigatórios** e **opcionais** de um jeito honesto — e por que marcar o opcional
  costuma ser melhor.
- Salvar **rascunho** para o usuário não perder o trabalho ao ser interrompido.
- Tornar o formulário acessível: rótulos, `semanticsLabel`, ordem de foco, contraste.
- Reconhecer os sinais de um formulário longo demais e saber como dividi-lo.

## ✅ Pré-requisitos

- [Aula 6 — Formulários](06-formularios.md) e
  [Aula 7 — Validação, foco e teclado](07-validacao-foco-teclado.md) — o `MateriaFormScreen`
  continua de lá. Esta aula é a camada de **experiência** sobre a mecânica das duas anteriores.
- [Aula 5 — Navegação Android × iOS](05-navegacao-android-x-ios.md) — o `PopScope` e a proteção
  contra perda de dados.
- [Módulo 06, aula 12 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) — a mesma ideia
  de "texto que ajuda" aplicada a estados de tela.
- O projeto `foco_navegacao` rodando.

---

## 📖 Conceito

### Mensagens que ajudam × mensagens que culpam

Compare:

| ❌ Culpa ou é vaga | ✅ Ajuda a corrigir |
|---|---|
| "Campo inválido" | "Informe a meta em minutos, entre 5 e 480" |
| "Erro" | "Não conseguimos salvar. Verifique sua internet e tente de novo" |
| "Nome inválido" | "Use pelo menos 2 letras" |
| "Você digitou errado" | "O e-mail precisa ter @ e um domínio, como nome@escola.com" |
| "Valor fora do intervalo" | "A meta máxima é 480 minutos (8 horas)" |
| "Preenchimento obrigatório" | "Informe o nome da matéria" |

As três regras que separam as colunas:

1. **Diga o que fazer, não o que está errado.** "Use pelo menos 2 letras" contém a correção;
   "nome inválido" não.
2. **Seja específico com números e formatos.** "Entre 5 e 480 minutos" elimina a adivinhação.
3. **Nunca use "você".** "Você digitou errado" acusa. "Informe o nome" instrui.

E um quarto princípio que vale ouro:

> **Nunca peça algo que o app pode descobrir sozinho.** Se você consegue derivar, calcular ou
> lembrar o valor, não pergunte. Cada campo removido do formulário é uma melhoria garantida.

### Quando validar cada campo

Não existe uma resposta única. Depende do custo de errar e do custo de checar:

| Tipo de campo | Quando validar | Por quê |
|---|---|---|
| Texto simples (nome) | Ao sair do campo ou ao enviar | Validar a cada tecla acusa erro enquanto a pessoa ainda digita |
| Número com faixa | Ao sair do campo | Idem — "3" é inválido a caminho de "30" |
| E-mail | Ao sair do campo | O `@` só aparece no meio da digitação |
| Senha (força) | **A cada tecla** | O usuário precisa ver a barra de força enquanto escolhe |
| Confirmação de senha | A cada tecla, **depois** que a primeira estiver preenchida | Retorno imediato evita frustração no envio |
| Disponibilidade (nome já usado) | Com **atraso** (~500 ms após parar de digitar) | Cada checagem custa uma ida ao servidor |
| Seleção (dropdown, switch) | No envio | Não há como "digitar errado" |

> ⚠️ **Validar a cada tecla um campo de texto é o erro mais comum de UX de formulário.** O usuário
> digita "C" e já lê "Use pelo menos 2 letras". Ele nem terminou. A estratégia da
> [aula 7](07-validacao-foco-teclado.md) — silêncio até a primeira falha de envio, e retorno
> imediato depois — resolve isso sem código extra.

### Rótulo, exemplo e ajuda

Os três textos de um campo têm funções diferentes e não são intercambiáveis:

```dart
decoration: const InputDecoration(
  labelText: 'Meta diária',                      // O QUE é. Fica sempre.
  hintText: 'Ex.: 45',                           // EXEMPLO. Some ao digitar.
  helperText: 'Quantos minutos por dia você quer estudar',  // AJUDA. Fica sempre.
)
```

| Texto | Responde | Some? | Leitor de tela anuncia? |
|---|---|---|---|
| `labelText` | "o que é este campo?" | Não (flutua) | ✅ Sempre |
| `hintText` | "como eu preencho?" | **Sim, ao digitar** | ⚠️ Nem sempre |
| `helperText` | "por que preciso disso?" | Não (só é trocado pelo erro) | ✅ |

> ❌ **O erro clássico:** usar `hintText` como rótulo, sem `labelText`. Fica bonito na tela vazia e
> vira um desastre assim que o usuário digita: ele esquece o que o campo pedia, e quem usa leitor
> de tela pode não ouvir nada. **Todo campo precisa de `labelText`.**

Repare também que o `helperText` **é substituído** pela mensagem de erro. Então o espaço vertical
já está reservado — e o layout não "pula" quando um erro aparece. Um campo sem `helperText`
empurra tudo para baixo ao errar. Por isso: ou todos têm `helperText`, ou nenhum tem.

### Obrigatório × opcional

Três formas de marcar, da pior para a melhor:

**1. Asterisco em todos os obrigatórios** — o padrão herdado da web.

```dart
labelText: 'Nome da matéria *'
```

Problema: se **quase tudo** é obrigatório, a tela vira um mar de asteriscos que não informa nada.

**2. Marcar só os opcionais** — geralmente a melhor escolha em mobile.

```dart
labelText: 'Observações (opcional)'
```

Em um formulário com 5 campos obrigatórios e 1 opcional, isso é **uma** marcação em vez de cinco.
E a marcação fica onde a informação é útil: no campo que o usuário pode pular.

**3. Não marcar nada** — só aceitável quando **todos** os campos são obrigatórios, e você diz isso
uma vez no topo.

> **Regra prática:** conte. Se há mais obrigatórios que opcionais, marque os **opcionais**. Se há
> mais opcionais, marque os **obrigatórios**. Marque sempre o grupo menor.

### Rascunho: não perder o trabalho

O `PopScope` da [aula 5](05-navegacao-android-x-ios.md) protege contra o usuário sair por engano.
Mas ele não protege contra:

- o sistema matar o app por falta de memória;
- uma ligação entrando;
- a bateria acabar;
- o usuário sair de propósito e querer voltar depois.

Para isso existe o **rascunho**: salvar o que foi digitado e oferecer de volta na próxima abertura.

```dart
// Ao digitar (com atraso, para não gravar a cada tecla):
_temporizador?.cancel();
_temporizador = Timer(const Duration(seconds: 1), _gravarRascunho);

// Ao abrir:
final Rascunho? r = await _store.carregar('materia_form');
if (r != null) _perguntarSeRestaura(r);

// Ao salvar com sucesso:
await _store.limpar('materia_form');
```

Três decisões importantes:

1. **Grave com atraso** (*debounce*), não a cada tecla. Gravar 40 vezes enquanto alguém digita um
   nome é desperdício.
2. **Pergunte antes de restaurar.** Preencher a tela sozinho assusta. Um `SnackBar` com
   "Restaurar rascunho?" é o suficiente.
3. **Limpe ao salvar.** Um rascunho antigo reaparecendo depois de o usuário já ter salvo é pior
   que não ter rascunho.

> 📌 Nesta aula o rascunho fica **em memória** (um `Map` estático), para não depender de
> persistência ainda. No [Módulo 10](../10-persistencia-de-dados/02-shared-preferences.md) ele
> passa a sobreviver ao fechamento do app.

### Acessibilidade em formulários

Quatro coisas que custam pouco e mudam tudo para quem depende delas:

**1. `labelText` em todo campo.** Já foi dito, e é o item mais importante. O leitor de tela anuncia
"Nome da matéria, campo de texto, editando".

**2. `semanticsLabel` onde o texto visível não basta:**

```dart
Text('5/10', semanticsLabel: '5 de 10 sessões concluídas')
IconButton(icon: const Icon(Icons.delete), tooltip: 'Excluir matéria', onPressed: _excluir)
```

**3. Ordem de foco coerente.** A ordem de `Tab` (e do leitor de tela) segue a ordem da árvore de
widgets. Se o seu layout visual não bate com a ordem do código, use `FocusTraversalGroup`.

**4. Não use cor como único sinal.** Um campo com erro precisa de **texto**, não só de borda
vermelha. O Flutter já faz isso por padrão com `errorText` — não o esconda.

Como testar sem equipamento especial:

```powershell
flutter run -d chrome
```

Depois, navegue pelo formulário inteiro **só com a tecla `Tab`**. Se você não conseguir preencher e
enviar sem tocar no mouse, quem usa teclado também não vai conseguir.

### Quando o formulário está longo demais

Sinais de alerta:

- Mais de **7 campos** em uma tela.
- O usuário precisa rolar mais de **duas telas**.
- Campos que só fazem sentido para uma parte dos usuários.
- Você mesmo se perde ao testar.

Três formas de dividir:

| Técnica | Quando |
|---|---|
| **Seções com títulos** | O formulário é longo mas coeso |
| **Campos condicionais** | Metade dos campos só importa se uma opção for marcada |
| **Várias etapas** (*stepper*) | O preenchimento tem ordem natural e o usuário precisa de progresso visível |

Campos condicionais são a técnica mais subestimada:

```dart
SwitchListTile(
  title: const Text('Lembrete diário'),
  value: _lembrete,
  onChanged: (bool v) => setState(() => _lembrete = v),
),
// Estes dois só existem se o lembrete estiver ligado.
if (_lembrete) ...<Widget>[
  _campoHorario(),
  _campoDiasDaSemana(),
],
```

Três campos viram um, para quem não quer lembrete. E o `Form` só valida o que está na árvore — os
campos escondidos **não** entram na validação, o que é exatamente o desejado.

---

## 💡 Analogia

Pense na diferença entre dois atendentes preenchendo o mesmo cadastro com você.

- **O atendente ruim** diz "dado inválido" e fica olhando. Você não sabe se o problema é o formato,
  o tamanho ou o conteúdo. **A mensagem de erro que só diz "inválido"** é esse atendente.
- **O atendente bom** diz "o CEP tem 8 dígitos, você digitou 7". Você corrige em três segundos.
- **Validar a cada tecla** é o atendente interromper você **no meio de cada palavra**: "esse nome
  está curto demais" enquanto você escreveu a primeira letra.
- **`hintText` sem `labelText`** é o formulário em que o nome de cada campo está escrito **dentro da
  linha, a lápis** — e some assim que você escreve por cima. No meio da terceira página você não
  sabe mais o que aquela linha pedia.
- **Marcar o grupo menor** é o atendente dizer "só o campo de complemento é opcional" em vez de
  apontar, um por um, os outros doze como obrigatórios.
- **O rascunho** é o atendente guardar a sua folha meio preenchida na gaveta quando você precisa
  sair correndo — e ter ela pronta quando você volta. Sem rascunho, você recomeça do zero.
- **Campos condicionais** são as perguntas que o atendente **pula** quando você diz que não tem
  filhos. Perguntar "nome dos filhos" para quem acabou de dizer que não tem é o que um formulário
  sem condicionais faz.

---

## 🧪 Exemplo mínimo

Dois formulários idênticos em função e opostos em experiência. Preencha os dois.

> **Arquivo:** `foco_navegacao/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppUx());

class AppUx extends StatelessWidget {
  const AppUx({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const TelaComparacao(),
    );
  }
}

class TelaComparacao extends StatefulWidget {
  const TelaComparacao({super.key});

  @override
  State<TelaComparacao> createState() => _TelaComparacaoState();
}

class _TelaComparacaoState extends State<TelaComparacao> {
  bool _versaoBoa = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_versaoBoa ? 'Versão boa' : 'Versão ruim'),
        actions: <Widget>[
          Switch(
            value: _versaoBoa,
            onChanged: (bool v) => setState(() => _versaoBoa = v),
          ),
        ],
      ),
      body: _versaoBoa ? const _FormBom() : const _FormRuim(),
    );
  }
}

/// Tudo que esta aula diz para não fazer.
class _FormRuim extends StatelessWidget {
  const _FormRuim();

  @override
  Widget build(BuildContext context) {
    return Form(
      // ❌ 1. Abre todo vermelho, antes de o usuário digitar.
      autovalidateMode: AutovalidateMode.always,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          TextFormField(
            // ❌ 2. Sem labelText: o nome do campo SOME ao digitar.
            decoration: const InputDecoration(hintText: 'Nome *'),
            // ❌ 3. Mensagem que não diz o que fazer.
            validator: (String? v) =>
                (v ?? '').trim().length < 2 ? 'Nome inválido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Meta *'),
            // ❌ 4. Sem keyboardType: teclado alfabético para um número.
            validator: (String? v) {
              final int? n = int.tryParse(v ?? '');
              // ❌ 5. "Valor fora do intervalo" — qual intervalo?
              if (n == null || n < 5 || n > 480) return 'Valor fora do intervalo';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            // ❌ 6. Asterisco em tudo: a marcação perde o significado.
            decoration: const InputDecoration(hintText: 'Observações *'),
          ),
          const SizedBox(height: 16),
          // ❌ 7. Campos que só importam se houver lembrete, sempre visíveis.
          TextFormField(
            decoration: const InputDecoration(hintText: 'Horário do lembrete *'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Dias do lembrete *'),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Salvar')),
        ],
      ),
    );
  }
}

/// As mesmas informações, com as decisões desta aula.
class _FormBom extends StatefulWidget {
  const _FormBom();

  @override
  State<_FormBom> createState() => _FormBomState();
}

class _FormBomState extends State<_FormBom> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();
  AutovalidateMode _modo = AutovalidateMode.disabled;
  bool _lembrete = false;

  void _salvar() {
    FocusScope.of(context).unfocus();
    if (!_chave.currentState!.validate()) {
      setState(() => _modo = AutovalidateMode.onUserInteraction);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salvo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _chave,
      // ✅ 1. Abre limpo; liga a autovalidação só depois da primeira falha.
      autovalidateMode: _modo,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text('Nova matéria', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          // ✅ 2. Diz a regra UMA vez, em vez de cinco asteriscos.
          Text(
            'Campos marcados como opcionais podem ficar em branco.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),

          TextFormField(
            // ✅ 3. labelText fica sempre; hintText é só exemplo.
            decoration: const InputDecoration(
              labelText: 'Nome da matéria',
              hintText: 'Ex.: Cálculo I',
              helperText: 'Como ela vai aparecer na sua lista',
            ),
            textCapitalization: TextCapitalization.words,
            // ✅ 4. A mensagem contém a correção.
            validator: (String? v) {
              final String t = (v ?? '').trim();
              if (t.isEmpty) return 'Informe o nome da matéria';
              if (t.length < 2) return 'Use pelo menos 2 letras';
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            // ✅ 5. Teclado numérico.
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Meta diária',
              suffixText: 'minutos',
              helperText: 'Entre 5 e 480 minutos',
            ),
            // ✅ 6. A faixa aparece no helper E na mensagem de erro.
            validator: (String? v) {
              final int? n = int.tryParse((v ?? '').trim());
              if (n == null) return 'Informe um número de minutos';
              if (n < 5) return 'A meta mínima é 5 minutos';
              if (n > 480) return 'A meta máxima é 480 minutos (8 horas)';
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            // ✅ 7. Marca o grupo MENOR: só o opcional.
            decoration: const InputDecoration(
              labelText: 'Observações (opcional)',
              helperText: 'Livro, professor, link do material',
            ),
            maxLines: null,
            minLines: 2,
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Lembrete diário'),
            value: _lembrete,
            onChanged: (bool v) => setState(() => _lembrete = v),
            contentPadding: EdgeInsets.zero,
          ),

          // ✅ 8. Campos condicionais: dois campos a menos para quem
          //    não quer lembrete. E o Form não valida o que não existe.
          if (_lembrete) ...<Widget>[
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Horário do lembrete',
                hintText: 'Ex.: 19:30',
              ),
              validator: (String? v) =>
                  (v ?? '').trim().isEmpty ? 'Informe o horário' : null,
            ),
          ],
          const SizedBox(height: 24),

          FilledButton(onPressed: _salvar, child: const Text('Criar matéria')),
        ],
      ),
    );
  }
}
```

**Faça isto, nesta ordem:**

1. Abra na **versão ruim**. Anote a primeira impressão em uma frase.
2. Tente preencher a meta. Repare no teclado e na mensagem de erro.
3. Passe para a **versão boa** e preencha de novo.
4. Ligue e desligue o interruptor de lembrete na versão boa. Conte os campos.

O código das duas tem praticamente o mesmo tamanho. A diferença é inteira de **decisão**.

---

## 📱 Aplicando no Flutter

O `MateriaFormScreen` já tem a mecânica certa (aulas 6 e 7). Nesta aula ele ganha a camada de
experiência:

1. Mensagens revisadas — todas dizem o que fazer.
2. `helperText` em todos os campos, para o layout não pular ao errar.
3. Só o campo opcional marcado.
4. Campos de lembrete **condicionais**.
5. **Rascunho** em memória, com restauração oferecida (não imposta).
6. Ajustes de acessibilidade.

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/core/rascunho/rascunho_store.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:async';

/// Rascunho de um formulário: os campos preenchidos e quando foram salvos.
class Rascunho {
  const Rascunho({required this.campos, required this.salvoEm});

  final Map<String, String> campos;
  final DateTime salvoEm;

  /// Descrição amigável do tempo decorrido, para o aviso de restauração.
  String get quandoLegivel {
    final Duration d = DateTime.now().difference(salvoEm);
    if (d.inMinutes < 1) return 'agora há pouco';
    if (d.inMinutes < 60) return 'há ${d.inMinutes} min';
    if (d.inHours < 24) return 'há ${d.inHours} h';
    return 'há ${d.inDays} dia(s)';
  }
}

/// Guarda rascunhos de formulários.
///
/// Nesta aula fica em MEMÓRIA: o rascunho sobrevive a trocar de tela, mas
/// não a fechar o app. No Módulo 10 esta mesma interface passa a gravar em
/// SharedPreferences, e nenhuma tela precisa mudar.
abstract final class RascunhoStore {
  static final Map<String, Rascunho> _memoria = <String, Rascunho>{};

  /// Só grava se houver conteúdo de verdade — um rascunho vazio
  /// faria o app oferecer restauração de nada.
  static Future<void> salvar(String chave, Map<String, String> campos) async {
    final bool temConteudo =
        campos.values.any((String v) => v.trim().isNotEmpty);
    if (!temConteudo) {
      await limpar(chave);
      return;
    }
    _memoria[chave] = Rascunho(campos: campos, salvoEm: DateTime.now());
  }

  static Future<Rascunho?> carregar(String chave) async => _memoria[chave];

  static Future<void> limpar(String chave) async => _memoria.remove(chave);
}

/// Adia uma ação até o usuário parar de digitar.
///
/// Sem isto, gravar "a cada tecla" faria 40 gravações para um nome curto.
class Debounce {
  Debounce(this.duracao);

  final Duration duracao;
  Timer? _timer;

  void chamar(void Function() acao) {
    _timer?.cancel();
    _timer = Timer(duracao, acao);
  }

  /// Obrigatório no dispose da tela: um Timer pendente dispararia
  /// depois de o State morrer.
  void cancelar() => _timer?.cancel();
}
```

> **Arquivo:** `foco_navegacao/lib/features/materias/presentation/materia_form_screen.dart`
> (os trechos que mudam nesta aula)

```dart
import 'package:foco_navegacao/core/rascunho/rascunho_store.dart';

// … dentro de _MateriaFormScreenState …

  static const String _chaveRascunho = 'materia_form';

  final Debounce _debounce = Debounce(const Duration(milliseconds: 800));

  @override
  void initState() {
    super.initState();
    _nome.addListener(_aoMudar);
    _meta.addListener(_aoMudar);
    _observacao.addListener(_aoMudar);

    // Só oferece rascunho ao CRIAR. Ao editar, a fonte da verdade é a
    // matéria existente — restaurar rascunho ali confundiria.
    if (!widget.args.ehEdicao) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _oferecerRascunho());
    }
  }

  @override
  void dispose() {
    // Um Timer pendente dispararia depois de o State morrer.
    _debounce.cancelar();
    _nome..removeListener(_aoMudar)..dispose();
    _meta..removeListener(_aoMudar)..dispose();
    _observacao..removeListener(_aoMudar)..dispose();
    _focoMeta.dispose();
    _focoObservacao.dispose();
    super.dispose();
  }

  void _aoMudar() {
    if (_erroServidorNome != null) _erroServidorNome = null;
    setState(() {});

    // Grava com atraso: uma vez depois que o usuário para, não a cada tecla.
    if (!widget.args.ehEdicao) {
      _debounce.chamar(_gravarRascunho);
    }
  }

  Future<void> _gravarRascunho() async {
    await RascunhoStore.salvar(_chaveRascunho, <String, String>{
      'nome': _nome.text,
      'meta': _meta.text,
      'observacao': _observacao.text,
    });
  }

  /// OFERECE a restauração — nunca preenche sozinho.
  ///
  /// Ver a tela se preencher do nada assusta o usuário e esconde o que
  /// aconteceu. Um SnackBar com ação deixa a escolha com ele.
  Future<void> _oferecerRascunho() async {
    final Rascunho? rascunho = await RascunhoStore.carregar(_chaveRascunho);
    if (rascunho == null) return;
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Você tem um rascunho de ${rascunho.quandoLegivel}'),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Restaurar',
          onPressed: () {
            setState(() {
              _nome.text = rascunho.campos['nome'] ?? '';
              _meta.text = rascunho.campos['meta'] ?? '60';
              _observacao.text = rascunho.campos['observacao'] ?? '';
            });
          },
        ),
      ),
    );
  }
```

E o `_salvar` ganha uma linha, na hora certa:

```dart
    try {
      final Materia salva = await _enviarAoServidor();

      // Salvou de verdade: o rascunho já não serve para nada.
      // Deixá-lo lá faria o app oferecer restauração de algo já gravado.
      await RascunhoStore.limpar(_chaveRascunho);

      if (!mounted) return;
      Navigator.of(context).pop(salva);
    } on _NomeDuplicadoException {
      // … igual à aula 7 …
    }
```

Agora os campos, com os textos revisados:

```dart
              // ── Cabeçalho que dispensa cinco asteriscos ─────────────────
              Text(
                'Preencha os campos abaixo. O que for opcional está marcado.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),

              // ── Nome ────────────────────────────────────────────────────
              TextFormField(
                key: _chaveNome,
                controller: _nome,
                autofocus: !widget.args.ehEdicao,
                enabled: !_enviando,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _focoMeta.requestFocus(),
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Nome da matéria',
                  hintText: 'Ex.: Cálculo I',
                  // helperText em TODOS os campos: o espaço da mensagem já
                  // fica reservado, e o layout não pula quando um erro surge.
                  helperText: 'Como ela vai aparecer na sua lista',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                validator: Validadores.combinar(<Validador>[
                  // Cada mensagem diz O QUE FAZER, nunca "inválido".
                  Validadores.obrigatorio('Informe o nome da matéria'),
                  Validadores.minimo(2, 'Use pelo menos 2 letras'),
                  Validadores.naoRepetido(
                    widget.args.nomesExistentes,
                    ignorar: _original?.nome,
                    mensagem: 'Você já tem uma matéria com esse nome',
                  ),
                  Validadores.doServidor(_erroServidorNome),
                ]),
              ),

              // ── Meta ────────────────────────────────────────────────────
              TextFormField(
                key: _chaveMeta,
                controller: _meta,
                focusNode: _focoMeta,
                enabled: !_enviando,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _focoObservacao.requestFocus(),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: const InputDecoration(
                  labelText: 'Meta diária',
                  suffixText: 'minutos',
                  // A faixa aparece ANTES de o usuário errar.
                  helperText: 'Entre 5 e 480 minutos (8 horas)',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: Validadores.combinar(<Validador>[
                  Validadores.obrigatorio('Informe a meta diária'),
                  Validadores.numeroInteiro('Informe um número de minutos'),
                  Validadores.entre(5, 480, unidade: 'minutos'),
                ]),
              ),

              // ── Observação ──────────────────────────────────────────────
              TextFormField(
                controller: _observacao,
                focusNode: _focoObservacao,
                enabled: !_enviando,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                maxLines: null,
                minLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  // O ÚNICO campo marcado — porque é o único opcional.
                  labelText: 'Observações (opcional)',
                  helperText: 'Livro, professor, link do material',
                  alignLabelWithHint: true,
                ),
                validator: Validadores.maximo(200),
              ),
              const SizedBox(height: 8),

              // ── Lembrete e seus campos condicionais ─────────────────────
              SwitchListTile(
                title: const Text('Lembrete diário'),
                subtitle: const Text('Avisa quando a meta não foi cumprida'),
                value: _lembrete,
                onChanged:
                    _enviando ? null : (bool v) => setState(() => _lembrete = v),
                contentPadding: EdgeInsets.zero,
              ),

              // Dois campos a menos para quem não quer lembrete.
              // E o Form NÃO valida o que não está na árvore — o que é
              // exatamente o comportamento desejado.
              if (_lembrete) ...<Widget>[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _horario,
                  enabled: !_enviando,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Horário do lembrete',
                    hintText: 'Ex.: 19:30',
                    helperText: 'Formato 24 h',
                    prefixIcon: Icon(Icons.alarm),
                  ),
                  validator: Validadores.combinar(<Validador>[
                    Validadores.obrigatorio('Informe o horário do lembrete'),
                    Validadores.horario('Use o formato hh:mm, como 19:30'),
                  ]),
                ),
              ],
```

E o validador de horário entra na biblioteca:

> **Arquivo:** `foco_navegacao/lib/core/validacao/validadores.dart` (acrescente)

```dart
  /// Aceita hh:mm em formato 24 horas.
  static Validador horario([String mensagem = 'Use o formato hh:mm']) {
    final RegExp padrao = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');
    return (String? v) {
      final String texto = (v ?? '').trim();
      if (texto.isEmpty) return null; // vazio é assunto de `obrigatorio`
      return padrao.hasMatch(texto) ? null : mensagem;
    };
  }
```

Rode e teste:

```powershell
flutter analyze
flutter run -d chrome
```

1. Abra o formulário de criar, digite um nome e **volte descartando**.
2. Abra de novo: o `SnackBar` oferece **Restaurar**. Toque nele.
3. Ligue o interruptor de lembrete: um campo novo aparece. Desligue: ele some — e **não** é
   validado.
4. Aperte Salvar com a meta vazia: a mensagem diz "Informe a meta diária", não "campo inválido".
5. Repare que o layout **não pula** quando o erro aparece — o `helperText` já reservava o espaço.
6. Navegue pelo formulário inteiro só com `Tab` e envie com `Enter`.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `class Debounce` com `Timer` | Adia a gravação até o usuário parar de digitar. Sem isso, um nome de 20 letras causaria 20 gravações. |
| `_debounce.cancelar()` no `dispose` | Um `Timer` pendente dispararia depois de o `State` morrer. Mesmo cuidado do [Módulo 05, aula 6](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md). |
| `RascunhoStore` como `abstract final class` com `Map` estático | Interface pronta para o Módulo 10 trocar a implementação por `SharedPreferences` **sem** nenhuma tela mudar. |
| `if (!temConteudo) { await limpar(chave); return; }` | Um rascunho vazio faria o app oferecer restauração de nada. |
| `if (!widget.args.ehEdicao)` antes de oferecer rascunho | Ao **editar**, a fonte da verdade é a matéria existente. Oferecer rascunho ali confundiria. |
| `addPostFrameCallback` para oferecer o rascunho | O `ScaffoldMessenger` precisa da árvore montada. Chamar no `initState` direto lançaria erro. |
| `SnackBarAction(label: 'Restaurar')` | **Oferece**, não impõe. Ver a tela se preencher sozinha assusta e esconde o que aconteceu. |
| `duration: const Duration(seconds: 8)` | Mais longo que o padrão de 4 s: é uma decisão, não um aviso. |
| `rascunho.quandoLegivel` | "há 12 min" é mais útil que um horário absoluto para decidir se vale restaurar. |
| `await RascunhoStore.limpar(...)` **dentro do try, após o sucesso** | Um rascunho antigo reaparecendo depois de salvo é pior que não ter rascunho. |
| `helperText` em **todos** os campos | Reserva o espaço vertical da mensagem. Sem ele, o layout salta quando um erro aparece. |
| Só `'Observações (opcional)'` marcado | Marca-se o **grupo menor**. Com 4 obrigatórios e 1 opcional, é 1 marcação em vez de 4. |
| Texto de cabeçalho explicando a convenção | Diz a regra **uma vez**, no lugar de repetir asteriscos. |
| `if (_lembrete) ...<Widget>[...]` | Campos condicionais. O `Form` **só valida o que está na árvore** — campo escondido não bloqueia o envio. |
| `Validadores.horario` devolvendo `null` para vazio | Mesma regra da aula 7: validadores de formato ignoram vazio; "vazio" é só do `obrigatorio`. |
| Mensagens com números (`'A meta máxima é 480 minutos (8 horas)'`) | O usuário corrige sem adivinhar. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Leitor de tela | TalkBack | VoiceOver |
| Anúncio de campo | "Nome da matéria, caixa de edição" | "Nome da matéria, campo de texto" |
| Anúncio de erro | Lido ao focar o campo | Lido ao focar o campo |
| `hintText` sozinho | TalkBack costuma ler | VoiceOver frequentemente **não** lê |
| Fonte grande do sistema | Até 200% | Até 310% com Texto Dinâmico |
| Preenchimento automático | Autofill do Google | Chaves do iCloud, mais insistente |
| Salvar rascunho | O sistema pode matar o app em segundo plano | Mata **mais cedo** e com mais frequência |

> 📌 As duas linhas que importam: `hintText` sozinho pode ser **silencioso** no VoiceOver — mais uma
> razão para `labelText` sempre. E o iOS descarta apps em segundo plano mais agressivamente, o que
> torna o rascunho mais valioso lá do que no Android.

> 💡 Teste a fonte grande: Android em Configurações → Tela → Tamanho da fonte; iOS em Ajustes →
> Tela e Brilho → Tamanho do texto. Formulários são o primeiro lugar onde o layout quebra —
> revisite o [Módulo 06, aula 11](../06-widgets-e-layouts/11-responsividade.md).

---

## ⚠️ Erros comuns

### 1. "Campo inválido"

```dart
validator: (String? v) => v!.isEmpty ? 'Campo inválido' : null,   // ❌
```

Não diz o que fazer nem qual é a regra.

**Correção:** `'Informe o nome da matéria'`.

### 2. `hintText` como rótulo

```dart
decoration: const InputDecoration(hintText: 'Nome da matéria')   // ❌
```

Some ao digitar, e o VoiceOver pode não ler.

**Correção:** `labelText` sempre.

### 3. `helperText` em alguns campos só

O layout **salta** quando um erro aparece num campo sem `helperText`, porque o espaço não estava
reservado.

**Correção:** ou todos têm, ou nenhum tem.

### 4. Asterisco em tudo

```dart
labelText: 'Nome *', 'Meta *', 'Categoria *', 'Observações *'   // ❌
```

Quando tudo é obrigatório, o asterisco não informa nada.

**Correção:** marque o **grupo menor** — aqui, só o opcional.

### 5. Validar a cada tecla um campo de texto

O usuário digita "C" e lê "Use pelo menos 2 letras". Ele ainda nem terminou a palavra.

**Correção:** a estratégia da aula 7 — silêncio até a primeira falha de envio.

### 6. Restaurar rascunho sozinho

A tela abre preenchida e o usuário não sabe de onde veio aquilo — nem se aquilo já foi salvo.

**Correção:** ofereça com `SnackBarAction`.

### 7. Não limpar o rascunho depois de salvar

O usuário salva, cria outra matéria, e o app oferece restaurar a anterior. Confuso e perigoso.

**Correção:** `limpar()` logo após o sucesso.

### 8. Gravar rascunho a cada tecla

40 gravações para um nome curto. Em `SharedPreferences` ou banco, isso é trabalho de I/O
desperdiçado.

**Correção:** *debounce* de ~800 ms.

### 9. Mostrar campos que não se aplicam

"Horário do lembrete" visível para quem desligou o lembrete — e, pior, **obrigatório**.

**Correção:** `if (_lembrete) ...`. O `Form` não valida o que não está na árvore.

### 10. Pedir o que o app já sabe

"Data de hoje", "seu nome de usuário", "sua categoria favorita" — se o app tem o dado, não pergunte.

**Correção:** preencha, ou simplesmente não mostre o campo.

### 11. Cor como único sinal de erro

Borda vermelha sem texto exclui quem não distingue as cores.

**Correção:** deixe o `errorText` aparecer. É o padrão — não o esconda.

---

## 🛠️ Exercício guiado

**Passo 1.** Abra o formulário e leia **todas** as mensagens de erro (deixe tudo vazio e aperte
Salvar). Para cada uma, pergunte: "isso me diz o que fazer?" Reescreva as que falharem.

**Passo 2.** Remova o `helperText` do campo de meta (mantendo nos outros). Aperte Salvar e observe
se o layout pula. Depois devolva.

**Passo 3.** Coloque asterisco em todos os rótulos. Rode e olhe a tela por cinco segundos. Depois
volte a marcar só o opcional e compare a primeira impressão.

**Passo 4.** Digite um nome, saia descartando, e volte. Restaure o rascunho. Agora salve de verdade
e abra o formulário mais uma vez: o rascunho **não** deve ser oferecido.

**Passo 5.** Comente a linha `await RascunhoStore.limpar(_chaveRascunho);`. Repita o passo 4 e
descreva o problema.

**Passo 6.** Troque o *debounce* para `Duration.zero` e acrescente um `debugPrint` no
`_gravarRascunho`. Digite um nome e conte as linhas no console. Depois volte para 800 ms.

**Passo 7.** Ligue o lembrete, **não** preencha o horário, desligue o lembrete e aperte Salvar.
Funciona? Explique por escrito por que o campo escondido não bloqueou o envio.

**Passo 8.** Navegue pelo formulário inteiro usando **só a tecla `Tab`** e envie com `Enter`. Anote
qualquer ponto em que você ficou preso.

**Passo 9.** Aumente a fonte do sistema para 200% e abra o formulário. Anote o que quebrou e
corrija com as técnicas do [Módulo 06, aula 11](../06-widgets-e-layouts/11-responsividade.md).

**Passo 10.** Conte os campos do formulário. Se passar de 7, escolha uma das três técnicas de
divisão e aplique.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Faça os exercícios de **Reescrita** de mensagens de erro, o de **Aplicação** com campos
condicionais, e o de **Decisão** sobre marcar obrigatórios ou opcionais.

---

## 🏆 Desafio opcional

Transforme o `MateriaFormScreen` em um formulário de **duas etapas** com `Stepper`:

- **Etapa 1 — O básico:** nome e categoria.
- **Etapa 2 — Metas e lembretes:** meta diária, observações, lembrete.

Requisitos:

- Não é possível avançar para a etapa 2 com a etapa 1 inválida.
- O indicador de progresso mostra em qual etapa o usuário está.
- Voltar da etapa 2 para a 1 **não** perde o que foi preenchido.
- O rascunho continua funcionando, guardando também **em qual etapa** o usuário parou.
- O `PopScope` continua protegendo contra saída acidental.

Dica: `Stepper` com `type: StepperType.horizontal` e um `GlobalKey<FormState>` **por etapa** — ou
um `Form` só com validação seletiva por etapa. Escolha uma abordagem e justifique.

Depois responda: o formulário ficou melhor ou pior? Para **quantos** campos você diria que a
divisão em etapas passa a valer a pena?

---

## 📌 Resumo

- Mensagem de erro boa **diz o que fazer**, é **específica** (com números e formatos) e **não
  usa "você"**.
- **Nunca peça o que o app pode descobrir sozinho.** Campo removido é melhoria garantida.
- **Quando validar depende do campo:** texto e número ao sair/enviar; força de senha a cada tecla;
  disponibilidade com atraso.
- Validar texto a cada tecla é o erro de UX mais comum — acusa antes de a pessoa terminar.
- **`labelText`** diz o que é (fica sempre), **`hintText`** dá exemplo (some), **`helperText`**
  explica (é trocado pelo erro).
- Use `helperText` em **todos** os campos ou em nenhum — senão o layout salta ao errar.
- Marque o **grupo menor**: mais obrigatórios → marque os opcionais, e vice-versa.
- **Rascunho** protege contra o que o `PopScope` não protege: app morto, ligação, bateria.
  Grave com *debounce*, **ofereça** a restauração, e **limpe** ao salvar.
- Acessibilidade: `labelText` sempre, `semanticsLabel` onde o texto visível não basta, ordem de
  foco coerente, e **nunca** só cor para indicar erro.
- Teste navegando só com `Tab` e com a fonte do sistema em 200%.
- Formulário com mais de 7 campos: divida em seções, use **campos condicionais** ou etapas.
- O `Form` **só valida o que está na árvore** — campo escondido por `if` não bloqueia o envio.

---

## ☑️ Checklist de domínio

- [ ] Reescrevo "campo inválido" em uma mensagem que diz o que fazer.
- [ ] Incluo números e formatos nas mensagens de erro.
- [ ] Escolho o momento de validar conforme o tipo de campo.
- [ ] Uso `labelText` em **todo** campo, e `hintText` só para exemplo.
- [ ] Uso `helperText` em todos os campos ou em nenhum, e sei por quê.
- [ ] Marco o grupo menor entre obrigatórios e opcionais.
- [ ] Implemento rascunho com *debounce*, restauração oferecida e limpeza após salvar.
- [ ] Cancelo o `Timer` do *debounce* no `dispose`.
- [ ] Uso campos condicionais para encurtar o formulário.
- [ ] Sei que o `Form` não valida campos fora da árvore.
- [ ] Navego pelo formulário inteiro só com `Tab`.
- [ ] Testei com a fonte do sistema aumentada.
- [ ] Nenhum erro do meu app é indicado **só** por cor.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Accessibility — docs.flutter.dev](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)
- [Material 3 text fields — m3.material.io](https://m3.material.io/components/text-fields/guidelines)
- [Error messages — m2.material.io](https://m2.material.io/design/communication/confirmation-acknowledgement.html)
- [Semantics class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [Stepper class — api.flutter.dev](https://api.flutter.dev/flutter/material/Stepper-class.html)
- [FocusTraversalGroup — api.flutter.dev](https://api.flutter.dev/flutter/widgets/FocusTraversalGroup-class.html)
- [Web Content Accessibility Guidelines (WCAG) 2.2](https://www.w3.org/WAI/WCAG22/quickref/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — Validação, foco e teclado](07-validacao-foco-teclado.md) | [README](README.md) | [Aula 9 — go_router (opcional)](09-go-router-opcional.md) |
