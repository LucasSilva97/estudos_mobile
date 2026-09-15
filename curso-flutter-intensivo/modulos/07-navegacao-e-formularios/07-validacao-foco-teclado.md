# Aula 7 — Validação, foco e teclado

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Escrever **validadores reutilizáveis** e compô-los, em vez de repetir `if` em cada campo.
- Escolher o **`autovalidateMode`** certo e explicar por que `always` é quase sempre errado.
- Controlar o **foco** entre campos com `FocusNode` — e liberá-lo no `dispose`.
- Configurar **`textInputAction`** para que o teclado mostre "Próximo" e "Concluído" nos lugares
  certos.
- Fechar o teclado com **`unfocus()`**, inclusive no caso do teclado numérico do iOS.
- Rolar até o **primeiro campo com erro** depois de uma validação que falhou.
- Implementar o **estado de envio**: botão desabilitado, indicador de progresso e proteção contra
  envio duplo.
- Tratar erros que só o **servidor** conhece (e-mail já cadastrado) dentro do mesmo formulário.

## ✅ Pré-requisitos

- [Aula 6 — Formulários](06-formularios.md) — `Form`, `GlobalKey<FormState>`, `TextFormField`,
  controllers. Esta aula continua exatamente de lá.
- [Aula 5 — Navegação Android × iOS](05-navegacao-android-x-ios.md) — o `PopScope` continua ativo.
- [Módulo 05, aula 6 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md)
  — `FocusNode`, assim como controller, precisa de `dispose`.
- [Módulo 04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) — o envio é
  assíncrono.
- O projeto `foco_navegacao` rodando.

---

## 📖 Conceito

### Validadores reutilizáveis

Na aula 6, cada `validator` era escrito na mão, dentro do campo:

```dart
validator: (String? v) {
  final String texto = (v ?? '').trim();
  if (texto.isEmpty) return 'Informe o nome da matéria';
  if (texto.length < 2) return 'Use pelo menos 2 letras';
  return null;
},
```

Com 5 campos em 8 telas, isso vira 40 blocos parecidos — com mensagens ligeiramente diferentes em
cada um. O app parece feito por várias pessoas.

A solução é uma biblioteca de validadores:

```dart
validator: Validadores.combinar(<String? Function(String?)>[
  Validadores.obrigatorio('Informe o nome da matéria'),
  Validadores.minimo(2),
  Validadores.maximo(40),
]),
```

O tipo `String? Function(String?)` é a assinatura de todo validador do Flutter: recebe o valor
(anulável) e devolve `null` se estiver válido, ou a mensagem de erro.

E `combinar` é simples:

```dart
static String? Function(String?) combinar(
  List<String? Function(String?)> validadores,
) {
  return (String? valor) {
    for (final String? Function(String?) v in validadores) {
      final String? erro = v(valor);
      if (erro != null) return erro;   // para no PRIMEIRO erro
    }
    return null;
  };
}
```

> 💡 Parar no primeiro erro é intencional. Mostrar "obrigatório, mínimo 2 letras, formato inválido"
> ao mesmo tempo é ruído. Uma mensagem por vez, na ordem em que faz sentido corrigir.

### `autovalidateMode`: **quando** validar

Este é o detalhe que mais afeta a sensação de usar o formulário.

| Modo | Quando valida | Experiência |
|---|---|---|
| `disabled` (padrão) | Só quando você chama `validate()` | O usuário preenche em paz e só vê erros ao enviar |
| `onUserInteraction` | Depois que o usuário mexeu **naquele** campo | **O melhor equilíbrio** |
| `always` | A cada rebuild, desde o primeiro | ❌ Formulário abre **todo vermelho** |

`always` é hostil: o usuário abre a tela e já é recebido com "Informe o nome", "Informe o e-mail",
"Informe a meta" — antes de digitar uma letra.

`onUserInteraction` faz o certo: o campo fica em silêncio até o usuário interagir com ele, e a
partir daí dá retorno imediato.

**A estratégia completa que este curso usa:**

```dart
AutovalidateMode _modo = AutovalidateMode.disabled;

void _salvar() {
  // Na PRIMEIRA tentativa falha, ligamos a autovalidação.
  // A partir daí o usuário vê o erro sumir enquanto corrige.
  if (!_chave.currentState!.validate()) {
    setState(() => _modo = AutovalidateMode.onUserInteraction);
    return;
  }
  // … enviar
}

// … no build:
Form(
  key: _chave,
  autovalidateMode: _modo,
  child: ...,
)
```

Comportamento resultante:

1. Abre limpo, sem nenhum vermelho.
2. O usuário tenta enviar → todos os erros aparecem.
3. Enquanto ele corrige, **cada erro some sozinho** ao ficar correto.

Isso é, de longe, o melhor comportamento de formulário — e custa três linhas.

### `FocusNode`: controlar onde o cursor está

Um `FocusNode` representa "o foco de um campo". Ele permite:

```dart
final FocusNode _focoEmail = FocusNode();

// … dar foco a um campo por código:
_focoEmail.requestFocus();

// … saber se ele está focado:
_focoEmail.hasFocus;

// … reagir a ganhar/perder foco:
_focoEmail.addListener(() { ... });
```

> ⚠️ **`FocusNode` precisa de `dispose()`**, igual ao controller. Mesmo par: criar e liberar.

O uso mais comum é **pular para o próximo campo** quando o usuário aperta a tecla de ação do
teclado:

```dart
TextFormField(
  controller: _nome,
  textInputAction: TextInputAction.next,       // o teclado mostra "Próximo"
  onFieldSubmitted: (_) => _focoMeta.requestFocus(),
)

TextFormField(
  controller: _meta,
  focusNode: _focoMeta,
  textInputAction: TextInputAction.done,       // o teclado mostra "Concluído"
  onFieldSubmitted: (_) => _salvar(),
)
```

Sem isso, o usuário digita o nome, olha o teclado, não encontra jeito de avançar, fecha o teclado,
toca no próximo campo, abre o teclado de novo. Quatro ações para o que deveria ser uma.

### `textInputAction`: a tecla de ação do teclado

| Valor | Tecla mostrada | Use em |
|---|---|---|
| `TextInputAction.next` | Próximo / → | Todo campo que **não** é o último |
| `TextInputAction.done` | Concluído / ✓ | O **último** campo |
| `TextInputAction.send` | Enviar | Campo de mensagem de chat |
| `TextInputAction.search` | Buscar / 🔍 | Campo de busca |
| `TextInputAction.newline` | Quebra de linha | Campo multilinha |

> ⚠️ Em campo **multilinha** (`maxLines: null`), use `TextInputAction.newline` — caso contrário o
> usuário não consegue quebrar linha, porque a tecla virou "Concluído".

### Fechar o teclado

```dart
FocusScope.of(context).unfocus();
```

Isso tira o foco de qualquer campo e fecha o teclado. Três lugares onde ele é necessário:

**1. Ao tocar fora dos campos** — o usuário espera isso:

```dart
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  // Sem isto, tocar numa área "vazia" não é detectado.
  behavior: HitTestBehavior.opaque,
  child: Scaffold(...),
)
```

**2. Antes de enviar** — para o teclado não cobrir o `SnackBar` de retorno:

```dart
void _salvar() {
  FocusScope.of(context).unfocus();
  if (!_chave.currentState!.validate()) return;
  // …
}
```

**3. No teclado numérico do iOS** — ele **não tem** tecla de concluído:

Sem uma saída, o usuário fica preso olhando o teclado numérico. O toque-fora do item 1 resolve — e
é por isso que ele não é opcional em formulários com campos numéricos.

### Rolar até o primeiro erro

Num formulário longo, `validate()` marca o erro num campo que pode estar **fora da tela**. O
usuário aperta Salvar, nada parece acontecer, e ele conclui que o botão está quebrado.

A solução mais simples e confiável usa `Scrollable.ensureVisible` com o `context` do campo:

```dart
final Map<String, GlobalKey> _chavesDosCampos = <String, GlobalKey>{
  'nome': GlobalKey(),
  'meta': GlobalKey(),
};

void _rolarAte(String campo) {
  final BuildContext? c = _chavesDosCampos[campo]?.currentContext;
  if (c == null) return;
  Scrollable.ensureVisible(
    c,
    duration: const Duration(milliseconds: 300),
    alignment: 0.1,   // deixa o campo perto do topo, não colado
  );
}
```

E o campo carrega a chave:

```dart
TextFormField(key: _chavesDosCampos['nome'], ...)
```

### Estado de envio

Quando o salvamento é assíncrono (API, banco), três coisas precisam acontecer:

1. **O botão desabilita** — senão o usuário toca duas vezes e envia dois cadastros.
2. **Um indicador aparece** — senão ele acha que travou.
3. **Os campos desabilitam** (opcional, mas recomendado) — para não editar durante o envio.

```dart
bool _enviando = false;

Future<void> _salvar() async {
  FocusScope.of(context).unfocus();
  if (!_chave.currentState!.validate()) {
    setState(() => _modo = AutovalidateMode.onUserInteraction);
    return;
  }

  setState(() => _enviando = true);
  try {
    final Materia salva = await _repositorio.salvar(...);
    if (!mounted) return;
    Navigator.of(context).pop(salva);
  } on Exception catch (erro) {
    if (!mounted) return;
    setState(() => _enviando = false);
    // trata o erro
  }
}
```

> 📌 Repare que `_enviando = false` **só** aparece no `catch`. No caminho feliz a tela é fechada, e
> chamar `setState` depois disso seria erro. Esse detalhe é fonte comum de
> `setState() called after dispose()`.

### Erros que só o servidor conhece

Alguns erros não podem ser validados no aparelho: "e-mail já cadastrado", "nome de matéria
duplicado", "sessão expirada". Eles chegam **depois** do envio.

A forma errada é só mostrar um `SnackBar` — a mensagem some e o usuário não sabe qual campo está
errado. A forma certa é devolver o erro **para dentro do campo**:

```dart
String? _erroDoServidorNoNome;

// no validator:
validator: (String? v) {
  final String? erroLocal = Validadores.obrigatorio()(v);
  if (erroLocal != null) return erroLocal;
  // O erro do servidor entra na mesma fila dos validadores locais.
  if (_erroDoServidorNoNome != null) return _erroDoServidorNoNome;
  return null;
},

// ao digitar de novo, o erro do servidor precisa ser limpo:
onChanged: (_) {
  if (_erroDoServidorNoNome != null) {
    setState(() => _erroDoServidorNoNome = null);
  }
},
```

---

## 💡 Analogia

Volte ao balcão de atendimento da aula anterior.

- **`autovalidateMode: always`** é o atendente parado sobre o seu ombro, dizendo "está errado" em
  cada campo **antes de você escrever qualquer coisa**. Tecnicamente correto — todos os campos
  vazios são inválidos — e insuportável.
- **`disabled`** é o atendente que espera você terminar a folha inteira e só então marca tudo a
  vermelho. Melhor, mas se houver seis erros você faz seis viagens ao balcão.
- **A estratégia do curso** é o atendente que fica quieto até você entregar; a partir da primeira
  devolução, ele passa a **conferir campo a campo** enquanto você corrige — e as marcações somem
  conforme você acerta. É como um humano atencioso se comportaria.
- **`textInputAction: next`** é o atendente **virando a folha para você** ao terminar cada linha.
  Sem isso, você precisa procurar sozinho onde continuar.
- **Rolar até o primeiro erro** é o atendente **apontar com o dedo** a linha errada. Dizer "tem um
  erro aí" sem apontar, numa folha de três páginas, não é ajuda.
- **O estado de envio** é o atendente pegar a folha da sua mão e dizer "estou processando". Se ele
  deixasse a folha no balcão sem dizer nada, você entregaria uma segunda cópia — e sairia com dois
  cadastros.
- **O erro do servidor no campo** é a marcação vermelha voltar **na linha certa** quando o sistema
  interno descobre que aquele CPF já existe — em vez de um bilhete solto dizendo "deu problema".

---

## 🧪 Exemplo mínimo

Este programa mostra os três modos de autovalidação lado a lado.

> **Arquivo:** `foco_navegacao/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppValidacao());

class AppValidacao extends StatelessWidget {
  const AppValidacao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const TelaValidacao(),
    );
  }
}

class TelaValidacao extends StatefulWidget {
  const TelaValidacao({super.key});

  @override
  State<TelaValidacao> createState() => _TelaValidacaoState();
}

class _TelaValidacaoState extends State<TelaValidacao> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();

  final TextEditingController _nome = TextEditingController();
  final TextEditingController _idade = TextEditingController();

  // O foco do segundo campo, para o "Próximo" do teclado funcionar.
  final FocusNode _focoIdade = FocusNode();

  AutovalidateMode _modo = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nome.dispose();
    _idade.dispose();
    // FocusNode também precisa de dispose. Mesmo par: criar e liberar.
    _focoIdade.dispose();
    super.dispose();
  }

  void _enviar() {
    // 1. Fecha o teclado: ele cobriria o SnackBar de retorno.
    FocusScope.of(context).unfocus();

    // 2. Valida.
    if (!_chave.currentState!.validate()) {
      // 3. Falhou pela primeira vez? Liga a autovalidação daqui em diante.
      setState(() => _modo = AutovalidateMode.onUserInteraction);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_nome.text.trim()}, ${_idade.text} anos')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tocar fora fecha o teclado. Obrigatório quando há campo numérico:
      // no iOS o teclado numérico NÃO tem tecla de concluído.
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,

      child: Scaffold(
        appBar: AppBar(title: Text('Modo: ${_modo.name}')),
        body: Form(
          key: _chave,
          autovalidateMode: _modo,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              SegmentedButton<AutovalidateMode>(
                segments: const <ButtonSegment<AutovalidateMode>>[
                  ButtonSegment<AutovalidateMode>(
                    value: AutovalidateMode.disabled,
                    label: Text('disabled'),
                  ),
                  ButtonSegment<AutovalidateMode>(
                    value: AutovalidateMode.onUserInteraction,
                    label: Text('interaction'),
                  ),
                  ButtonSegment<AutovalidateMode>(
                    value: AutovalidateMode.always,
                    label: Text('always'),
                  ),
                ],
                selected: <AutovalidateMode>{_modo},
                onSelectionChanged: (Set<AutovalidateMode> s) =>
                    setState(() => _modo = s.first),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nome,
                autofocus: true,
                // "Próximo" no teclado, em vez de "Concluído".
                textInputAction: TextInputAction.next,
                // Enter no teclado leva ao próximo campo.
                onFieldSubmitted: (_) => _focoIdade.requestFocus(),
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (String? v) =>
                    (v ?? '').trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _idade,
                focusNode: _focoIdade,
                keyboardType: TextInputType.number,
                // Último campo: "Concluído", e Enter envia.
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _enviar(),
                decoration: const InputDecoration(labelText: 'Idade'),
                validator: (String? v) {
                  final int? n = int.tryParse(v ?? '');
                  if (n == null) return 'Informe um número';
                  if (n < 1 || n > 120) return 'Idade entre 1 e 120';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              FilledButton(onPressed: _enviar, child: const Text('Enviar')),
            ],
          ),
        ),
      ),
    );
  }
}
```

**O roteiro que ensina a aula:**

1. Escolha **`always`** e recarregue (`R`). O formulário abre **todo vermelho**. Sinta o incômodo.
2. Escolha **`disabled`**, recarregue e aperte Enviar vazio. Os erros aparecem. Agora **corrija o
   nome**: o erro dele **não some** até você apertar Enviar de novo.
3. Escolha **`onUserInteraction`** e repita. Agora o erro some **enquanto você digita**.
4. Com o foco no nome, aperte **Enter**. O cursor pula para a idade. Aperte Enter de novo: envia.

---

## 📱 Aplicando no Flutter

O `MateriaFormScreen` do `foco_navegacao` ganha a versão final do módulo:

- validadores reutilizáveis em `core/validacao/validadores.dart`;
- autovalidação que liga na primeira falha;
- navegação por teclado entre os campos;
- rolagem automática até o primeiro erro;
- estado de envio com proteção contra envio duplo;
- erro de servidor ("já existe uma matéria com esse nome") dentro do campo.

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/core/validacao/validadores.dart` (novo)
> **Como executar:** `flutter run -d chrome`

```dart
/// Assinatura de todo validador do Flutter:
/// recebe o valor (anulável) e devolve null se válido.
typedef Validador = String? Function(String?);

/// Validadores reutilizáveis do app.
///
/// Centralizar aqui garante que "Informe o nome" tenha exatamente o mesmo
/// texto nas 12 telas — em vez de 12 variações escritas por pessoas
/// diferentes em dias diferentes.
abstract final class Validadores {
  /// Executa os validadores em ordem e para no PRIMEIRO erro.
  ///
  /// Mostrar três mensagens ao mesmo tempo é ruído: o usuário corrige uma
  /// coisa por vez.
  static Validador combinar(List<Validador> validadores) {
    return (String? valor) {
      for (final Validador validar in validadores) {
        final String? erro = validar(valor);
        if (erro != null) return erro;
      }
      return null;
    };
  }

  static Validador obrigatorio([String mensagem = 'Campo obrigatório']) {
    // trim: três espaços não contam como preenchido.
    return (String? v) => (v ?? '').trim().isEmpty ? mensagem : null;
  }

  static Validador minimo(int caracteres, [String? mensagem]) {
    return (String? v) {
      final String texto = (v ?? '').trim();
      if (texto.isEmpty) return null; // "vazio" é assunto de `obrigatorio`
      return texto.length < caracteres
          ? (mensagem ?? 'Use pelo menos $caracteres caracteres')
          : null;
    };
  }

  static Validador maximo(int caracteres, [String? mensagem]) {
    return (String? v) {
      final String texto = (v ?? '').trim();
      return texto.length > caracteres
          ? (mensagem ?? 'Use no máximo $caracteres caracteres')
          : null;
    };
  }

  static Validador numeroInteiro([String mensagem = 'Informe um número']) {
    return (String? v) => int.tryParse((v ?? '').trim()) == null ? mensagem : null;
  }

  static Validador entre(int minimo, int maximo, {String? unidade}) {
    return (String? v) {
      final int? n = int.tryParse((v ?? '').trim());
      if (n == null) return null; // "não é número" é assunto de `numeroInteiro`
      if (n < minimo || n > maximo) {
        final String sufixo = unidade == null ? '' : ' $unidade';
        return 'Informe um valor entre $minimo e $maximo$sufixo';
      }
      return null;
    };
  }

  static Validador email([String mensagem = 'E-mail inválido']) {
    // Deliberadamente permissiva: validar e-mail por regex "perfeita" é um
    // problema conhecido e sem solução boa. A confirmação real é o envio.
    final RegExp padrao = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
    return (String? v) {
      final String texto = (v ?? '').trim();
      if (texto.isEmpty) return null;
      return padrao.hasMatch(texto) ? null : mensagem;
    };
  }

  /// Rejeita um valor que já existe. Útil para nome duplicado.
  static Validador naoRepetido(
    Iterable<String> existentes, {
    String? ignorar,
    String mensagem = 'Já existe um item com esse nome',
  }) {
    return (String? v) {
      final String texto = (v ?? '').trim().toLowerCase();
      if (texto.isEmpty) return null;
      final bool repetido = existentes
          .where((String e) => e.toLowerCase() != ignorar?.toLowerCase())
          .any((String e) => e.toLowerCase() == texto);
      return repetido ? mensagem : null;
    };
  }

  /// Erro vindo do servidor, injetado na mesma fila dos validadores locais.
  static Validador doServidor(String? mensagem) {
    return (String? v) => mensagem;
  }
}
```

> **Arquivo:** `foco_navegacao/lib/features/materias/presentation/materia_form_screen.dart`
> (versão final do módulo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:foco_navegacao/core/validacao/validadores.dart';
import 'package:foco_navegacao/features/materias/domain/materia.dart';

class MateriaFormArgs {
  const MateriaFormArgs.criar({this.nomesExistentes = const <String>[]})
      : original = null;

  const MateriaFormArgs.editar(
    Materia materia, {
    this.nomesExistentes = const <String>[],
  }) : original = materia;

  final Materia? original;

  /// Nomes já usados, para impedir duplicata sem ir ao servidor.
  final List<String> nomesExistentes;

  bool get ehEdicao => original != null;
}

class MateriaFormScreen extends StatefulWidget {
  const MateriaFormScreen({super.key, required this.args});

  final MateriaFormArgs args;

  @override
  State<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends State<MateriaFormScreen> {
  final GlobalKey<FormState> _chaveDoFormulario = GlobalKey<FormState>();

  // Chaves de campo: usadas para rolar até o primeiro erro.
  final GlobalKey _chaveNome = GlobalKey();
  final GlobalKey _chaveMeta = GlobalKey();

  late final Materia? _original = widget.args.original;

  // ── Controllers ───────────────────────────────────────────────────────────
  late final TextEditingController _nome =
      TextEditingController(text: _original?.nome ?? '');
  late final TextEditingController _meta =
      TextEditingController(text: '${_original?.metaMinutos ?? 60}');
  late final TextEditingController _observacao =
      TextEditingController(text: _original?.observacao ?? '');

  // ── FocusNodes ────────────────────────────────────────────────────────────
  // Um por campo que precisa RECEBER foco por código.
  // Cada um precisa de dispose, igual aos controllers.
  final FocusNode _focoMeta = FocusNode();
  final FocusNode _focoObservacao = FocusNode();

  late CategoriaMateria _categoria =
      _original?.categoria ?? CategoriaMateria.exatas;
  late bool _lembrete = _original?.lembreteDiario ?? false;

  /// Começa desligada: o formulário abre limpo, sem vermelho.
  /// Liga na primeira tentativa de envio que falhar.
  AutovalidateMode _autovalidar = AutovalidateMode.disabled;

  bool _enviando = false;

  /// Erro que só o servidor conhece. Entra na fila do validator do nome.
  String? _erroServidorNome;

  bool get _temAlteracoes {
    final Materia? o = _original;
    if (o == null) {
      return _nome.text.trim().isNotEmpty ||
          _observacao.text.trim().isNotEmpty ||
          _meta.text != '60' ||
          _lembrete;
    }
    return _nome.text.trim() != o.nome ||
        _meta.text != '${o.metaMinutos}' ||
        _observacao.text.trim() != o.observacao ||
        _categoria != o.categoria ||
        _lembrete != o.lembreteDiario;
  }

  @override
  void initState() {
    super.initState();
    _nome.addListener(_aoMudar);
    _meta.addListener(_aoMudar);
    _observacao.addListener(_aoMudar);
  }

  @override
  void dispose() {
    _nome
      ..removeListener(_aoMudar)
      ..dispose();
    _meta
      ..removeListener(_aoMudar)
      ..dispose();
    _observacao
      ..removeListener(_aoMudar)
      ..dispose();

    // FocusNode também vaza memória se não for liberado.
    _focoMeta.dispose();
    _focoObservacao.dispose();

    super.dispose();
  }

  void _aoMudar() {
    // Digitar no nome limpa o erro que veio do servidor: ele já não vale
    // para o valor novo.
    if (_erroServidorNome != null) _erroServidorNome = null;
    setState(() {});
  }

  // ── Rolagem até o erro ────────────────────────────────────────────────────

  /// Leva o primeiro campo inválido para a vista.
  ///
  /// Sem isto, num formulário longo o usuário aperta Salvar, o erro é
  /// marcado fora da tela, e ele conclui que o botão não funciona.
  void _rolarAtePrimeiroErro() {
    final List<GlobalKey> ordem = <GlobalKey>[_chaveNome, _chaveMeta];

    for (final GlobalKey chave in ordem) {
      final BuildContext? contextDoCampo = chave.currentContext;
      if (contextDoCampo == null) continue;

      // O FormFieldState guarda se aquele campo está com erro.
      final FormFieldState<String>? estado =
          contextDoCampo.findAncestorStateOfType<FormFieldState<String>>();

      if (estado != null && estado.hasError) {
        Scrollable.ensureVisible(
          contextDoCampo,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.1, // perto do topo, não colado nele
        );
        return;
      }
    }
  }

  // ── Envio ─────────────────────────────────────────────────────────────────

  Future<void> _salvar() async {
    // 1. Fecha o teclado. Ele cobriria mensagens e atrapalharia a rolagem.
    FocusScope.of(context).unfocus();

    // 2. Valida tudo de uma vez.
    if (!_chaveDoFormulario.currentState!.validate()) {
      // 3. Primeira falha: liga a autovalidação. A partir daqui os erros
      //    somem sozinhos conforme o usuário corrige.
      setState(() => _autovalidar = AutovalidateMode.onUserInteraction);

      // 4. Mostra ao usuário ONDE está o problema.
      //    O post-frame garante que o erro já foi desenhado.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rolarAtePrimeiroErro();
      });
      return;
    }

    // 5. Estado de envio: botão e campos travados.
    setState(() => _enviando = true);

    try {
      final Materia salva = await _enviarAoServidor();

      if (!mounted) return;
      // Sucesso: a tela fecha. NÃO mexa em _enviando aqui —
      // o State está sendo descartado.
      Navigator.of(context).pop(salva);
    } on _NomeDuplicadoException {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        // O erro do servidor vira erro DE CAMPO, não um SnackBar solto.
        _erroServidorNome = 'Já existe uma matéria com esse nome';
        _autovalidar = AutovalidateMode.onUserInteraction;
      });
      // Revalida para o erro aparecer imediatamente no campo.
      _chaveDoFormulario.currentState!.validate();
      _rolarAtePrimeiroErro();
    } on Exception catch (erro) {
      debugPrint('Falha ao salvar matéria: $erro');
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar. Tente de novo.')),
      );
    }
  }

  /// Simula o envio. No Módulo 09 vira uma chamada HTTP real.
  Future<Materia> _enviarAoServidor() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    // Simula a regra que só o servidor conhece.
    if (_nome.text.trim().toLowerCase() == 'duplicada') {
      throw const _NomeDuplicadoException();
    }

    return (_original ??
            Materia(
              id: 'm_${DateTime.now().millisecondsSinceEpoch}',
              nome: '',
              minutosEstudados: 0,
              metaMinutos: 60,
            ))
        .copyWith(
      nome: _nome.text.trim(),
      metaMinutos: int.parse(_meta.text),
      categoria: _categoria,
      lembreteDiario: _lembrete,
      observacao: _observacao.text.trim(),
    );
  }

  Future<bool> _confirmarDescarte() async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você preencheu não será salvo.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Durante o envio, não deixa sair de jeito nenhum.
      canPop: !_temAlteracoes && !_enviando,
      onPopInvokedWithResult: (bool saiu, Object? r) async {
        if (saiu) return;
        if (_enviando) return; // envio em andamento: ignora o voltar
        final bool descartar = await _confirmarDescarte();
        if (!context.mounted) return;
        if (descartar) Navigator.of(context).pop();
      },

      child: GestureDetector(
        // Tocar fora fecha o teclado.
        // Obrigatório aqui: o campo de meta usa teclado numérico, que no
        // iOS não tem tecla de concluído.
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,

        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.args.ehEdicao ? 'Editar matéria' : 'Nova matéria'),
            actions: <Widget>[
              TextButton(
                onPressed: (_temAlteracoes && !_enviando) ? _salvar : null,
                child: const Text('Salvar'),
              ),
            ],
          ),

          body: Form(
            key: _chaveDoFormulario,
            autovalidateMode: _autovalidar,

            // Durante o envio, os campos ficam somente leitura.
            child: AbsorbPointer(
              absorbing: _enviando,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  // ── Nome ────────────────────────────────────────────────
                  TextFormField(
                    key: _chaveNome,
                    controller: _nome,
                    autofocus: !widget.args.ehEdicao,
                    enabled: !_enviando,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    // Teclado mostra "Próximo".
                    textInputAction: TextInputAction.next,
                    // Enter leva ao próximo campo.
                    onFieldSubmitted: (_) => _focoMeta.requestFocus(),
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: 'Nome da matéria',
                      hintText: 'Ex.: Cálculo I',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    validator: Validadores.combinar(<Validador>[
                      Validadores.obrigatorio('Informe o nome da matéria'),
                      Validadores.minimo(2),
                      Validadores.naoRepetido(
                        widget.args.nomesExistentes,
                        ignorar: _original?.nome,
                        mensagem: 'Você já tem uma matéria com esse nome',
                      ),
                      // O erro do servidor entra na MESMA fila dos locais.
                      Validadores.doServidor(_erroServidorNome),
                    ]),
                  ),
                  const SizedBox(height: 8),

                  // ── Categoria ───────────────────────────────────────────
                  DropdownButtonFormField<CategoriaMateria>(
                    initialValue: _categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: <DropdownMenuItem<CategoriaMateria>>[
                      for (final CategoriaMateria c in CategoriaMateria.values)
                        DropdownMenuItem<CategoriaMateria>(
                          value: c,
                          child: Row(
                            children: <Widget>[
                              Icon(c.icone, size: 20),
                              const SizedBox(width: 12),
                              Text(c.rotulo),
                            ],
                          ),
                        ),
                    ],
                    onChanged: _enviando
                        ? null
                        : (CategoriaMateria? v) {
                            if (v == null) return;
                            setState(() => _categoria = v);
                          },
                  ),
                  const SizedBox(height: 16),

                  // ── Meta ────────────────────────────────────────────────
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
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    validator: Validadores.combinar(<Validador>[
                      Validadores.obrigatorio('Informe a meta diária'),
                      Validadores.numeroInteiro(),
                      Validadores.entre(5, 480, unidade: 'minutos'),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // ── Observação ──────────────────────────────────────────
                  TextFormField(
                    controller: _observacao,
                    focusNode: _focoObservacao,
                    enabled: !_enviando,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    // Multilinha: "quebra de linha", nunca "concluído" —
                    // senão o usuário não consegue pular linha.
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    minLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                      alignLabelWithHint: true,
                    ),
                    validator: Validadores.maximo(200),
                  ),
                  const SizedBox(height: 8),

                  SwitchListTile(
                    title: const Text('Lembrete diário'),
                    value: _lembrete,
                    onChanged: _enviando
                        ? null
                        : (bool v) => setState(() => _lembrete = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  // ── Botão com estado de envio ───────────────────────────
                  FilledButton.icon(
                    // Desabilitado durante o envio: impede cadastro duplicado.
                    onPressed: (_temAlteracoes && !_enviando) ? _salvar : null,
                    icon: _enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _enviando
                          ? 'Salvando…'
                          : (widget.args.ehEdicao ? 'Salvar' : 'Criar matéria'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Erro que só o servidor sabe reconhecer.
class _NomeDuplicadoException implements Exception {
  const _NomeDuplicadoException();
}
```

Rode e teste os seis comportamentos:

```powershell
flutter analyze
flutter run -d chrome
```

1. Abra o formulário: **nenhum vermelho**, apesar de os campos estarem vazios.
2. Aperte Salvar: todos os erros aparecem **e** a tela rola até o primeiro.
3. Corrija o nome: o erro dele **some sozinho**, sem apertar Salvar.
4. Com o foco no nome, aperte Enter: o cursor pula para a meta.
5. Preencha tudo e salve: o botão vira "Salvando…" e os campos travam por 1,2 s.
6. Digite **`duplicada`** no nome e salve: o erro do servidor aparece **dentro do campo**.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `typedef Validador = String? Function(String?);` | Dá nome à assinatura. `List<Validador>` é muito mais legível que `List<String? Function(String?)>`. |
| `Validadores.combinar([...])` | Executa em ordem e para no **primeiro** erro. Uma mensagem por vez é menos ruído. |
| Validadores que devolvem `null` para campo vazio | `minimo`, `entre` e `email` ignoram vazio de propósito: "vazio" é responsabilidade exclusiva de `obrigatorio`. Isso permite campos opcionais com formato validado. |
| `Validadores.doServidor(_erroServidorNome)` | Truque simples: o erro remoto entra na **mesma fila** dos locais, e o `Form` o desenha no campo certo. |
| `AutovalidateMode _autovalidar = AutovalidateMode.disabled;` | Abre limpo. Liga só na primeira falha de envio. |
| `setState(() => _autovalidar = AutovalidateMode.onUserInteraction);` | A partir daqui, cada erro some sozinho conforme o usuário corrige. |
| `WidgetsBinding.instance.addPostFrameCallback` antes de rolar | A rolagem precisa acontecer **depois** de os erros serem desenhados; senão o campo ainda não tem estado de erro para detectar. |
| `contextDoCampo.findAncestorStateOfType<FormFieldState<String>>()` | Sobe a árvore a partir da chave do campo até achar o estado do `FormField`, que sabe se há erro. |
| `Scrollable.ensureVisible(..., alignment: 0.1)` | `0.0` colaria o campo no topo; `0.1` deixa uma folga que parece natural. |
| `FocusNode _focoMeta` + `_focoMeta.requestFocus()` | Pular para o próximo campo com a tecla do teclado. Sem isso, quatro toques onde bastaria um. |
| `_focoMeta.dispose()` | `FocusNode` vaza memória igual a controller. Mesmo par: criar e liberar. |
| `textInputAction: TextInputAction.next` / `.done` / `.newline` | `next` em todo campo menos o último; `newline` em multilinha — senão o usuário não consegue quebrar linha. |
| `FocusScope.of(context).unfocus()` no início do `_salvar` | Fecha o teclado antes de validar: ele cobriria mensagens e atrapalharia a rolagem. |
| `GestureDetector(onTap: unfocus, behavior: HitTestBehavior.opaque)` | Tocar fora fecha o teclado. **Obrigatório** com campo numérico: o iOS não tem tecla de concluído. |
| `AbsorbPointer(absorbing: _enviando, ...)` | Bloqueia todos os toques de uma vez durante o envio. Mais simples que desabilitar 6 widgets. |
| `enabled: !_enviando` nos campos | Além do `AbsorbPointer`, deixa o visual **cinza** — o usuário vê que está travado, não só sente. |
| `setState(() => _enviando = false)` **só** nos `catch` | No caminho feliz a tela fecha; mexer em `setState` depois disso seria `setState() after dispose()`. |
| `canPop: !_temAlteracoes && !_enviando` | Durante o envio não se sai da tela — evita fechar no meio de uma gravação. |
| `_erroServidorNome = null` no `_aoMudar` | O erro "nome duplicado" vale para o valor antigo. Ao digitar, ele precisa sumir. |
| `_chaveDoFormulario.currentState!.validate()` depois de setar o erro do servidor | Força o redesenho imediato da mensagem no campo, sem esperar a próxima interação. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Fechar teclado alfabético | Botão voltar do sistema | Tecla de concluído, ou tocar fora |
| Fechar teclado **numérico** | Botão voltar do sistema | **Só tocando fora** — não há tecla |
| `textInputAction.next` | Seta → no canto | "Próximo" escrito |
| `textInputAction.done` | ✓ ou "Concluído" | "Concluído" ou "return" |
| Autocorreção | Moderada | **Agressiva** — atrapalha nomes próprios |
| Preenchimento automático | Autofill do Google | Chaves do iCloud |
| Mensagem de erro | Abaixo do campo, vermelha | Idem (é o Material) |

> 📌 **A diferença que exige código nesta aula** é a segunda linha. Sem o `GestureDetector` que
> chama `unfocus()`, um usuário de iPhone que toca no campo "Meta diária" fica com o teclado
> numérico aberto **sem saída** — ele não cobre o botão Salvar por sorte, mas em telas menores
> cobriria. É um bug real, comum, e que só aparece quando se testa no aparelho certo.

> 💡 Em campos de nome próprio, considere `autocorrect: false`. A autocorreção do iOS transforma
> "Cálculo I" em "Cálculo Í" com frequência irritante.

---

## ⚠️ Erros comuns

### 1. `autovalidateMode: AutovalidateMode.always`

```dart
Form(autovalidateMode: AutovalidateMode.always, ...)   // ❌
```

O formulário abre todo vermelho, antes de o usuário digitar uma letra.

**Correção:** comece com `disabled` e mude para `onUserInteraction` na primeira falha.

### 2. Esquecer o `dispose` do `FocusNode`

```dart
final FocusNode _focoMeta = FocusNode();
// … sem dispose ❌
```

Vazamento silencioso — e o analisador não avisa.

**Correção:** um `dispose()` por `FocusNode`, junto com os dos controllers.

### 3. `textInputAction.done` em campo multilinha

```dart
TextFormField(maxLines: null, textInputAction: TextInputAction.done)   // ❌
```

O usuário não consegue quebrar linha: a tecla de Enter virou "Concluído".

**Correção:** `TextInputAction.newline`.

### 4. Rolar até o erro **antes** de o erro existir

```dart
if (!_chave.currentState!.validate()) {
  _rolarAtePrimeiroErro();   // ⚠️ o erro ainda não foi desenhado
  return;
}
```

O `hasError` do campo ainda não foi atualizado no quadro atual.

**Correção:** `WidgetsBinding.instance.addPostFrameCallback((_) => _rolarAtePrimeiroErro());`

### 5. Não desabilitar o botão durante o envio

```dart
FilledButton(onPressed: _salvar, ...)   // ❌ durante o envio continua ativo
```

O usuário toca duas vezes e cria dois cadastros. É um dos bugs mais reportados em apps reais.

**Correção:** `onPressed: _enviando ? null : _salvar`.

### 6. `setState` depois do `pop`

```dart
Navigator.of(context).pop(salva);
setState(() => _enviando = false);   // ❌
```

```text
setState() called after dispose()
```

**Correção:** no caminho de sucesso, **não** mexa no estado depois de fechar a tela.

### 7. Erro de servidor só em `SnackBar`

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('E-mail já cadastrado')),   // ⚠️
);
```

A mensagem some em 4 segundos e o usuário não sabe **qual** campo corrigir.

**Correção:** injete o erro no `validator` do campo — como `Validadores.doServidor`.

### 8. Esquecer de limpar o erro do servidor

```dart
// o usuário corrige o nome, mas o erro "já existe" continua lá ❌
```

**Correção:** limpe no `onChanged`/listener do campo.

### 9. Validador que não ignora campo vazio

```dart
static Validador email() {
  return (String? v) => padrao.hasMatch(v ?? '') ? null : 'E-mail inválido';
}
```

Um campo **opcional** de e-mail passa a ser obrigatório na prática, porque vazio não casa com o
padrão.

**Correção:** devolva `null` quando vazio, e componha com `obrigatorio` quando o campo for
obrigatório.

### 10. Validar sem fechar o teclado

Num celular, o teclado ocupa metade da tela. O erro aparece atrás dele e o usuário não vê nada.

**Correção:** `FocusScope.of(context).unfocus()` como **primeira** linha do `_salvar`.

### 11. `currentState!` fora de um callback

```dart
@override
void initState() {
  super.initState();
  _chave.currentState!.validate();   // ❌ null: o build ainda não aconteceu
}
```

**Correção:** só use `currentState` dentro de callbacks de interação, ou depois de um
`addPostFrameCallback`.

---

## 🛠️ Exercício guiado

**Passo 1.** Abra o formulário e confirme que ele começa **limpo**. Aperte Salvar: todos os erros
aparecem juntos e a tela rola até o primeiro.

**Passo 2.** Corrija só o nome. Observe o erro dele sumir **sem** apertar Salvar. Explique por
escrito qual linha de código fez isso acontecer.

**Passo 3.** Troque `_autovalidar` inicial para `AutovalidateMode.always`. Recarregue com `R` e
descreva a primeira impressão. Depois desfaça.

**Passo 4.** Remova `_focoMeta.dispose()`. Rode `flutter analyze`. Ele avisa? Explique por que esse
tipo de vazamento é perigoso mesmo sem erro visível.

**Passo 5.** Com o foco no nome, aperte Enter. Depois troque `TextInputAction.next` por
`TextInputAction.done` no campo de nome e repita. Descreva a diferença.

**Passo 6.** No campo de observação, troque `TextInputAction.newline` por `.done`. Tente escrever
duas linhas. Depois desfaça.

**Passo 7.** Digite **`duplicada`** no nome e salve. Observe onde a mensagem aparece. Agora mude
uma letra do nome: o erro some? Explique qual linha fez isso.

**Passo 8.** Remova o `addPostFrameCallback` da rolagem (chame `_rolarAtePrimeiroErro()` direto).
Role a tela até o fim, aperte Salvar com tudo vazio e observe. Depois restaure.

**Passo 9.** Remova o `GestureDetector` de fechar teclado. Rode num emulador iOS (ou aperte `o`),
toque no campo de meta e tente fechar o teclado numérico. Descreva o que acontece.

**Passo 10.** Durante o "Salvando…", tente apertar o botão de novo e tente voltar. Confirme que
nenhum dos dois funciona. Explique quais duas linhas de código garantem isso.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Faça os exercícios de **Aplicação** com validadores compostos, o de **Correção de bugs** com
`autovalidateMode: always`, e o de **Decisão** sobre erro de servidor no campo × em `SnackBar`.

---

## 🏆 Desafio opcional

Crie um `GerenciadorDeFoco` que elimine a repetição de `FocusNode` em formulários longos:

```dart
final GerenciadorDeFoco _foco = GerenciadorDeFoco(<String>['nome', 'meta', 'obs']);

// no campo:
focusNode: _foco['meta'],
onFieldSubmitted: (_) => _foco.proximo('meta'),
```

Requisitos:

- Cria e libera todos os `FocusNode` sozinho (o `dispose` do gerenciador libera todos).
- `proximo(campo)` foca o seguinte; no último, chama um callback de envio.
- Expõe `focarPrimeiroComErro(GlobalKey<FormState> chave)` que, além de focar, rola até ele.
- Funciona com qualquer número de campos, sem você escrever um `FocusNode` na mão.

Depois responda: quantas linhas o `MateriaFormScreen` perdeu? E, se amanhã o formulário ganhar
mais três campos, quantas linhas você escreve a mais?

---

## 📌 Resumo

- Centralize validadores em `core/validacao/validadores.dart` e componha-os com `combinar`. O tipo
  é `String? Function(String?)` — vale dar um `typedef`.
- A composição **para no primeiro erro**: uma mensagem por vez, não três.
- Validadores de **formato** (mínimo, e-mail, faixa) devem ignorar campo vazio; "vazio" é
  responsabilidade só do `obrigatorio`. Isso permite campos opcionais com formato validado.
- **`autovalidateMode`:** comece `disabled`, mude para `onUserInteraction` na **primeira falha de
  envio**. `always` é hostil.
- **`FocusNode` precisa de `dispose()`**, igual a controller.
- `textInputAction: next` em todo campo menos o último; `done` no último; **`newline` em
  multilinha**.
- `onFieldSubmitted: (_) => _focoSeguinte.requestFocus()` faz o teclado avançar sozinho.
- **`FocusScope.of(context).unfocus()`** como primeira linha do envio, e num `GestureDetector`
  com `HitTestBehavior.opaque` cobrindo a tela — **obrigatório** quando há campo numérico, porque o
  teclado numérico do iOS não tem tecla de concluído.
- Role até o **primeiro campo com erro** usando `Scrollable.ensureVisible`, dentro de um
  `addPostFrameCallback`.
- **Estado de envio:** botão desabilitado, indicador visível, campos travados, `PopScope`
  bloqueado. Isso impede o cadastro duplicado.
- No caminho de sucesso, **não** chame `setState` depois do `pop`.
- Erros que só o servidor conhece devem virar **erro de campo**, não `SnackBar` — e precisam ser
  limpos quando o usuário edita o campo.

---

## ☑️ Checklist de domínio

- [ ] Escrevo validadores reutilizáveis e os componho com `combinar`.
- [ ] Sei por que validadores de formato devem ignorar campo vazio.
- [ ] Começo com `autovalidateMode: disabled` e ligo `onUserInteraction` na primeira falha.
- [ ] Explico por que `always` é uma má experiência.
- [ ] Dou `dispose()` em todo `FocusNode`.
- [ ] Configuro `textInputAction` correto em cada campo, incluindo `newline` em multilinha.
- [ ] Faço o teclado avançar entre campos com `onFieldSubmitted` + `requestFocus`.
- [ ] Fecho o teclado ao enviar e ao tocar fora.
- [ ] Sei por que o toque-fora é obrigatório em formulários com campo numérico.
- [ ] Rolo até o primeiro erro, dentro de `addPostFrameCallback`.
- [ ] Desabilito botão e campos durante o envio.
- [ ] Nunca chamo `setState` depois de fechar a tela.
- [ ] Mostro erros do servidor **dentro do campo** e os limpo quando o usuário edita.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Build a form with validation — docs.flutter.dev](https://docs.flutter.dev/cookbook/forms/validation)
- [Focus and text fields — docs.flutter.dev](https://docs.flutter.dev/ui/interactivity/focus)
- [FocusNode class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/FocusNode-class.html)
- [AutovalidateMode enum — api.flutter.dev](https://api.flutter.dev/flutter/widgets/AutovalidateMode.html)
- [TextInputAction enum — api.flutter.dev](https://api.flutter.dev/flutter/services/TextInputAction.html)
- [Scrollable.ensureVisible — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Scrollable/ensureVisible.html)
- [Retrieve the value of a text field — docs.flutter.dev](https://docs.flutter.dev/cookbook/forms/retrieve-input)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Formulários](06-formularios.md) | [README](README.md) | [Aula 8 — UX de formulários](08-ux-de-formularios.md) |
