# Aula 6 — Formulários

> **Módulo:** 07 - Navegação e Formulários · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que o widget **`Form`** faz — e por que ele não desenha nada.
- Usar **`GlobalKey<FormState>`** para validar, salvar e limpar todos os campos de uma vez.
- Diferenciar **`TextField`** de **`TextFormField`** e saber quando cada um é o certo.
- Gerenciar **`TextEditingController`** sem vazar memória.
- Configurar `InputDecoration`, `keyboardType`, `textCapitalization` e `inputFormatters` para que o
  teclado ajude em vez de atrapalhar.
- Usar **`DropdownButtonFormField`**, `SwitchListTile`, `CheckboxListTile` e `Slider` dentro de um
  `Form`.
- Decidir entre **controller** e **`onSaved`** — e por que o curso usa controller.

## ✅ Pré-requisitos

- [Aula 3 — Argumentos e resultados](03-argumentos-e-resultados.md) — o formulário devolve a
  matéria salva.
- [Aula 5 — Navegação Android × iOS](05-navegacao-android-x-ios.md) — o `PopScope` que protege o
  formulário continua aqui.
- [Módulo 05, aula 6 — Ciclo de vida do State](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md)
  — **essencial**: todo controller precisa de `dispose`.
- [Módulo 06, aula 11 — Responsividade](../06-widgets-e-layouts/11-responsividade.md) — o teclado
  não pode cobrir o campo.
- O projeto `foco_navegacao` rodando.

---

## 📖 Conceito

### Por que existe o widget `Form`

Sem `Form`, validar cinco campos é isto:

```dart
// ❌ a cada campo novo, mais uma linha em cada um dos três lugares
String? _erroNome, _erroEmail, _erroMeta;

void _salvar() {
  setState(() {
    _erroNome = _nome.text.isEmpty ? 'Obrigatório' : null;
    _erroEmail = !_email.text.contains('@') ? 'E-mail inválido' : null;
    _erroMeta = int.tryParse(_meta.text) == null ? 'Número inválido' : null;
  });
  if (_erroNome != null || _erroEmail != null || _erroMeta != null) return;
  // … enfim salvar
}
```

Com `Form`, é isto:

```dart
void _salvar() {
  if (!_chaveDoFormulario.currentState!.validate()) return;
  // … salvar
}
```

O `Form` é um widget que **não desenha nada**. Ele apenas:

1. Registra todos os `FormField` que estão abaixo dele na árvore.
2. Oferece três operações em lote: `validate()`, `save()` e `reset()`.
3. Guarda o estado de validação de cada campo.

> 💡 O `Form` encontra os campos pelo mesmo mecanismo do `Theme.of(context)`: cada `FormField` sobe
> a árvore procurando o `Form` mais próximo e se registra nele. Revisão da
> [aula 7 do Módulo 05](../05-introducao-ao-flutter/07-buildcontext.md).

### `GlobalKey<FormState>`

Para chamar `validate()` você precisa de uma referência ao `FormState`. É para isso que serve a
`GlobalKey`:

```dart
final GlobalKey<FormState> _chaveDoFormulario = GlobalKey<FormState>();

// … no build:
Form(
  key: _chaveDoFormulario,
  child: Column(children: <Widget>[ ...campos... ]),
)

// … ao salvar:
if (_chaveDoFormulario.currentState!.validate()) { ... }
```

Três regras que evitam 90% dos problemas com `GlobalKey`:

1. **Declare como campo `final` do `State`**, nunca dentro do `build`. Criada no `build`, ela seria
   uma chave nova a cada rebuild — e o estado do formulário se perderia.
2. **Uma `GlobalKey` por `Form`.** Duas chaves iguais em árvores diferentes causam erro em tempo de
   execução.
3. **`GlobalKey` é cara.** Use só onde precisa mesmo — não como atalho para acessar widgets.

> ⚠️ `_chave.currentState` é **anulável**: ele é `null` antes do primeiro `build`. Dentro de um
> `onPressed` o `!` é seguro (a tela está montada), mas em `initState` não.

### `TextField` × `TextFormField`

```dart
TextField(controller: _nome)                      // simples

TextFormField(
  controller: _nome,
  validator: (String? v) => v!.isEmpty ? 'Obrigatório' : null,
)                                                  // participa do Form
```

| | `TextField` | `TextFormField` |
|---|---|---|
| Participa do `Form` | ❌ | ✅ |
| Tem `validator` | ❌ | ✅ |
| Tem `onSaved` | ❌ | ✅ |
| Mostra erro sozinho | Só com `errorText` manual | ✅ automático |
| Quando usar | Busca, filtro, campo solto | **Qualquer campo de formulário** |

`TextFormField` é, por dentro, um `FormField<String>` que constrói um `TextField`. Você não perde
nada usando o segundo — só ganha.

> **Regra do curso:** campo dentro de formulário → **sempre** `TextFormField`. Campo solto (uma
> busca na `AppBar`, por exemplo) → `TextField`.

### `TextEditingController`

O controller guarda o texto e permite lê-lo e alterá-lo por código.

```dart
final TextEditingController _nome = TextEditingController();

@override
void dispose() {
  _nome.dispose();   // OBRIGATÓRIO
  super.dispose();
}
```

O que ele oferece:

```dart
_nome.text;                          // ler
_nome.text = 'Novo valor';           // escrever
_nome.clear();                       // limpar
_nome.addListener(() { ... });       // reagir a cada tecla
_nome.selection;                     // posição do cursor
```

> ⚠️ **Todo `TextEditingController` criado precisa de `dispose()`.** Sem isso, o objeto continua
> na memória e o listener continua vivo depois de a tela morrer. Escreva as duas linhas juntas —
> criação e `dispose` — como um par.

Para inicializar com um valor existente (edição):

```dart
late final TextEditingController _nome =
    TextEditingController(text: widget.args.original?.nome ?? '');
```

O `late` é necessário porque `widget` não existe ainda no inicializador de campo simples — mesma
razão do `initState` da [aula 6 do Módulo 05](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md).

### Controller ou `onSaved`?

Há duas formas de coletar os valores:

**Forma A — `onSaved` (a forma "oficial" do `Form`):**

```dart
String _nomeColetado = '';

TextFormField(
  initialValue: widget.original?.nome,
  onSaved: (String? v) => _nomeColetado = v ?? '',
)

// … ao salvar:
if (_chave.currentState!.validate()) {
  _chave.currentState!.save();   // dispara todos os onSaved
  _enviar(_nomeColetado);
}
```

**Forma B — controller:**

```dart
final TextEditingController _nome = TextEditingController();

TextFormField(controller: _nome)

// … ao salvar:
if (_chave.currentState!.validate()) {
  _enviar(_nome.text.trim());
}
```

| | `onSaved` | Controller |
|---|---|---|
| Ler o valor **enquanto** o usuário digita | ❌ | ✅ |
| Alterar o valor por código | ❌ | ✅ |
| Precisa de `dispose` | ❌ | ✅ |
| Código de campo | Menos | Mais |
| Detectar "há alterações não salvas" | ❌ | ✅ |

**Decisão do curso: controller.** O motivo prático: a proteção contra perda de dados da
[aula 5](05-navegacao-android-x-ios.md) precisa comparar o valor atual com o original **a cada
tecla** — e isso só o controller permite. O custo é lembrar do `dispose`.

> 📌 Nunca use os dois no mesmo campo. `controller:` e `initialValue:` juntos lançam exceção:
> `InitialValue and controller are mutually exclusive`.

### `InputDecoration`: o visual do campo

```dart
TextFormField(
  controller: _nome,
  decoration: const InputDecoration(
    labelText: 'Nome da matéria',        // flutua para cima ao focar
    hintText: 'Ex.: Cálculo I',          // some ao digitar
    helperText: 'Como aparecerá na lista',  // fica sempre visível
    prefixIcon: Icon(Icons.menu_book_outlined),
    counterText: '',                     // esconde o contador de caracteres
  ),
)
```

| Propriedade | Aparece | Some |
|---|---|---|
| `labelText` | Dentro do campo; flutua ao focar | Nunca |
| `hintText` | Dentro do campo, cinza | Ao digitar |
| `helperText` | Abaixo do campo | Nunca (é substituído pelo erro) |
| `errorText` | Abaixo, em vermelho | Quando o erro é resolvido |
| `prefixIcon` / `suffixIcon` | Nas laterais internas | Nunca |

> ⚠️ **Nunca use só `hintText` como rótulo.** Ao digitar, o texto some — e o usuário esquece o que
> aquele campo pede. Leitores de tela também não anunciam `hintText` de forma confiável. Use
> `labelText` sempre; `hintText` é para **exemplo**, não para nome.

Para definir o estilo de todos os campos de uma vez, use o tema
([Módulo 05, aula 9](../05-introducao-ao-flutter/09-material-e-cupertino.md)):

```dart
inputDecorationTheme: InputDecorationTheme(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  filled: true,
)
```

### O teclado certo para cada campo

Esse é o detalhe que mais diferencia um formulário profissional de um amador:

| Campo | `keyboardType` | `textCapitalization` |
|---|---|---|
| Nome de pessoa/coisa | `TextInputType.name` | `TextCapitalization.words` |
| Frase, descrição | `TextInputType.multiline` | `TextCapitalization.sentences` |
| E-mail | `TextInputType.emailAddress` | `none` |
| Telefone | `TextInputType.phone` | `none` |
| Número inteiro | `TextInputType.number` | `none` |
| Número com vírgula | `const TextInputType.numberWithOptions(decimal: true)` | `none` |
| Senha | `TextInputType.visiblePassword` + `obscureText: true` | `none` |
| URL | `TextInputType.url` | `none` |

O ganho é concreto: quem digita um telefone com o teclado alfabético aberto perde três toques só
para achar os números.

### `inputFormatters`: filtrar enquanto digita

```dart
import 'package:flutter/services.dart';

TextFormField(
  keyboardType: TextInputType.number,
  inputFormatters: <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,   // só números
    LengthLimitingTextInputFormatter(3),      // no máximo 3 dígitos
  ],
)
```

Os mais úteis:

| Formatter | O que faz |
|---|---|
| `FilteringTextInputFormatter.digitsOnly` | Aceita só `0-9` |
| `FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))` | Lista branca por expressão regular |
| `FilteringTextInputFormatter.deny(RegExp(r'\s'))` | Lista negra (aqui: sem espaços) |
| `LengthLimitingTextInputFormatter(n)` | Limita o comprimento |
| `UpperCaseTextFormatter` (você escreve) | Converte para maiúsculas |

> 📌 `keyboardType: TextInputType.number` **sugere** o teclado numérico, mas não impede colar texto
> nem digitar em teclados físicos. O `inputFormatter` é quem **garante**. Use os dois juntos.

### Outros campos dentro do `Form`

**Seleção — `DropdownButtonFormField`:**

```dart
DropdownButtonFormField<String>(
  initialValue: _categoria,
  decoration: const InputDecoration(labelText: 'Categoria'),
  items: const <DropdownMenuItem<String>>[
    DropdownMenuItem<String>(value: 'exatas', child: Text('Exatas')),
    DropdownMenuItem<String>(value: 'humanas', child: Text('Humanas')),
  ],
  onChanged: (String? v) => setState(() => _categoria = v),
  validator: (String? v) => v == null ? 'Escolha uma categoria' : null,
)
```

É o único seletor que **participa do `Form`** e tem `validator`. `DropdownButton` puro não tem.

**Booleano — `SwitchListTile` e `CheckboxListTile`:**

```dart
SwitchListTile(
  title: const Text('Lembrete diário'),
  subtitle: const Text('Notifica no horário escolhido'),
  value: _lembrete,
  onChanged: (bool v) => setState(() => _lembrete = v),
)
```

Use `Switch` para **ligar/desligar algo que age imediatamente**; `Checkbox` para **marcar um item
de uma lista** que será confirmada depois.

**Faixa — `Slider`:** bom para valores aproximados (meta em minutos). Ruim para valores exatos
(idade, preço) — nesses, um campo de texto é mais rápido.

---

## 💡 Analogia

Pense num formulário de papel em um balcão de atendimento.

- **O widget `Form`** é a **prancheta** que segura todas as folhas juntas. Ela não tem nada escrito;
  serve para você entregar tudo de uma vez e o atendente conferir tudo de uma vez.
- **`GlobalKey<FormState>`** é a **etiqueta com o número do protocolo** na prancheta. Sem ela, você
  não tem como dizer "confira aquela prancheta ali" — é o identificador que permite agir sobre o
  conjunto.
- **`validate()`** é o atendente passar o olho em todas as folhas e devolver com marcações a
  vermelho **nos campos errados** — não rejeitar a prancheta inteira dizendo "tem erro".
- **`TextEditingController`** é você ter uma **cópia carbono** de cada folha na mão. Dá para ler o
  que está escrito a qualquer momento, corrigir, apagar. O preço é: no fim do dia, você precisa
  **descartar as cópias** (o `dispose`) — senão elas se acumulam na sua mesa até não caber mais.
- **`onSaved`** é entregar a folha e só então descobrir o que estava escrito. Mais leve, mas você
  não consegue conferir nada no meio do preenchimento.
- **O `keyboardType`** é o atendente entregar a **caneta certa** para cada campo: uma caneta que só
  escreve números para o campo do CPF. Entregar sempre a mesma caneta funciona — mas faz o cliente
  trabalhar mais.
- **`labelText` × `hintText`**: o rótulo impresso na folha **fica lá para sempre**; o exemplo
  escrito a lápis **é apagado** quando o cliente escreve por cima. Se o nome do campo estava a
  lápis, ninguém mais sabe o que aquela linha pedia.

---

## 🧪 Exemplo mínimo

Um formulário completo, pequeno, com tudo que importa.

> **Arquivo:** `foco_navegacao/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const AppForm());

class AppForm extends StatelessWidget {
  const AppForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      home: const TelaForm(),
    );
  }
}

class TelaForm extends StatefulWidget {
  const TelaForm({super.key});

  @override
  State<TelaForm> createState() => _TelaFormState();
}

class _TelaFormState extends State<TelaForm> {
  // Campo do State, NUNCA criado dentro do build.
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();

  final TextEditingController _nome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _horas = TextEditingController();

  String? _categoria;
  bool _lembrete = false;

  @override
  void dispose() {
    // Um dispose por controller. Sem exceção.
    _nome.dispose();
    _email.dispose();
    _horas.dispose();
    super.dispose();
  }

  void _enviar() {
    // validate() roda TODOS os validators e desenha os erros nos campos.
    if (!_chave.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_nome.text.trim()} · ${_email.text.trim()} · '
          '${_horas.text}h · $_categoria · lembrete: $_lembrete',
        ),
      ),
    );
  }

  void _limpar() {
    // reset() limpa os campos E apaga as mensagens de erro.
    _chave.currentState!.reset();
    _nome.clear();
    _email.clear();
    _horas.clear();
    setState(() {
      _categoria = null;
      _lembrete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulário mínimo')),

      // ListView (não Column): o teclado não pode esconder os campos de baixo.
      body: Form(
        key: _chave,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: 'Nome',                 // fica sempre
                hintText: 'Ex.: Cálculo I',        // some ao digitar
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              // E-mail nunca leva maiúscula automática.
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (String? v) {
                final String texto = (v ?? '').trim();
                if (texto.isEmpty) return 'Informe o e-mail';
                if (!texto.contains('@') || !texto.contains('.')) {
                  return 'E-mail parece incompleto';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _horas,
              keyboardType: TextInputType.number,
              // keyboardType SUGERE; inputFormatters GARANTE.
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              decoration: const InputDecoration(
                labelText: 'Horas por dia',
                suffixText: 'h',
              ),
              validator: (String? v) {
                final int? n = int.tryParse(v ?? '');
                if (n == null) return 'Informe um número';
                if (n < 1 || n > 16) return 'Entre 1 e 16 horas';
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'exatas', child: Text('Exatas')),
                DropdownMenuItem<String>(value: 'humanas', child: Text('Humanas')),
                DropdownMenuItem<String>(value: 'idiomas', child: Text('Idiomas')),
              ],
              onChanged: (String? v) => setState(() => _categoria = v),
              validator: (String? v) => v == null ? 'Escolha uma categoria' : null,
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Lembrete diário'),
              value: _lembrete,
              onChanged: (bool v) => setState(() => _lembrete = v),
            ),
            const SizedBox(height: 24),

            FilledButton(onPressed: _enviar, child: const Text('Enviar')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _limpar, child: const Text('Limpar')),
          ],
        ),
      ),
    );
  }
}
```

**Teste três coisas:**

1. Aperte **Enviar** com tudo vazio → **todos** os erros aparecem de uma vez, cada um no seu campo.
2. Tente digitar letras no campo de horas → **não entram**.
3. Toque no campo de e-mail num celular → o teclado tem `@` e `.` visíveis.

---

## 📱 Aplicando no Flutter

Agora o `MateriaFormScreen` do `foco_navegacao` vira um formulário de verdade, com:

- `Form` + `GlobalKey<FormState>`;
- nome, categoria, meta diária, cor e lembrete;
- teclado correto em cada campo;
- a proteção contra perda de dados da [aula 5](05-navegacao-android-x-ios.md) mantida;
- devolvendo a `Materia` salva, como na [aula 3](03-argumentos-e-resultados.md).

A **validação a fundo** (quando validar, autovalidação, foco entre campos) é o assunto da
[aula 7](07-validacao-foco-teclado.md). Aqui os `validator` ficam simples de propósito.

---

## 💻 Código completo

> **Arquivo:** `foco_navegacao/lib/features/materias/domain/materia.dart` (acrescente os campos)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Categoria de estudo. Enum porque o conjunto é fechado e conhecido.
enum CategoriaMateria {
  exatas('Exatas', Icons.calculate_outlined),
  humanas('Humanas', Icons.history_edu_outlined),
  idiomas('Idiomas', Icons.translate_outlined),
  tecnologia('Tecnologia', Icons.code);

  const CategoriaMateria(this.rotulo, this.icone);

  final String rotulo;
  final IconData icone;
}

class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.minutosEstudados,
    required this.metaMinutos,
    this.categoria = CategoriaMateria.exatas,
    this.lembreteDiario = false,
    this.observacao = '',
  });

  final String id;
  final String nome;
  final int minutosEstudados;
  final int metaMinutos;
  final CategoriaMateria categoria;
  final bool lembreteDiario;
  final String observacao;

  IconData get icone => categoria.icone;

  double get progresso =>
      metaMinutos == 0 ? 0 : (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  Materia copyWith({
    String? id,
    String? nome,
    int? minutosEstudados,
    int? metaMinutos,
    CategoriaMateria? categoria,
    bool? lembreteDiario,
    String? observacao,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaMinutos: metaMinutos ?? this.metaMinutos,
      categoria: categoria ?? this.categoria,
      lembreteDiario: lembreteDiario ?? this.lembreteDiario,
      observacao: observacao ?? this.observacao,
    );
  }
}
```

> **Arquivo:** `foco_navegacao/lib/features/materias/presentation/materia_form_screen.dart`
> (versão completa desta aula)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:foco_navegacao/features/materias/domain/materia.dart';

class MateriaFormArgs {
  const MateriaFormArgs.criar() : original = null;
  const MateriaFormArgs.editar(Materia materia) : original = materia;

  final Materia? original;
  bool get ehEdicao => original != null;
}

class MateriaFormScreen extends StatefulWidget {
  const MateriaFormScreen({super.key, required this.args});

  final MateriaFormArgs args;

  @override
  State<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends State<MateriaFormScreen> {
  // ── A chave do formulário ─────────────────────────────────────────────────
  // Campo final do State. Criada dentro do build, seria uma chave nova a
  // cada rebuild e o formulário perderia o estado de validação.
  final GlobalKey<FormState> _chaveDoFormulario = GlobalKey<FormState>();

  // ── Valores originais, para detectar alterações ───────────────────────────
  late final Materia? _original = widget.args.original;

  // ── Controllers ───────────────────────────────────────────────────────────
  // Um dispose para cada um, lá embaixo. Escreva os dois juntos, sempre.
  late final TextEditingController _nome =
      TextEditingController(text: _original?.nome ?? '');
  late final TextEditingController _meta =
      TextEditingController(text: '${_original?.metaMinutos ?? 60}');
  late final TextEditingController _observacao =
      TextEditingController(text: _original?.observacao ?? '');

  // ── Campos que não são de texto ───────────────────────────────────────────
  late CategoriaMateria _categoria =
      _original?.categoria ?? CategoriaMateria.exatas;
  late bool _lembrete = _original?.lembreteDiario ?? false;

  /// Getter, não campo: precisa ser recalculado a cada rebuild.
  /// É ele que alimenta o canPop do PopScope. Aula 5.
  bool get _temAlteracoes {
    final Materia? o = _original;
    if (o == null) {
      // Criando: qualquer coisa preenchida já conta como alteração.
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
    // Cada tecla precisa disparar rebuild: é o rebuild que atualiza
    // o canPop e o estado do botão Salvar.
    _nome.addListener(_aoMudar);
    _meta.addListener(_aoMudar);
    _observacao.addListener(_aoMudar);
  }

  @override
  void dispose() {
    // Ordem: remover listeners, depois liberar. Sempre antes do super.
    _nome
      ..removeListener(_aoMudar)
      ..dispose();
    _meta
      ..removeListener(_aoMudar)
      ..dispose();
    _observacao
      ..removeListener(_aoMudar)
      ..dispose();
    super.dispose();
  }

  void _aoMudar() => setState(() {});

  // ── Ações ─────────────────────────────────────────────────────────────────

  void _salvar() {
    // Uma linha valida TODOS os campos e desenha os erros onde eles estão.
    if (!_chaveDoFormulario.currentState!.validate()) {
      // O Form já mostrou os erros; só reforçamos com um aviso.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corrija os campos destacados')),
      );
      return;
    }

    final Materia resultado = (_original ??
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

    Navigator.of(context).pop(resultado);
  }

  Future<bool> _confirmarDescarte() async {
    final bool? resposta = await showDialog<bool>(
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
    return resposta ?? false;
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_temAlteracoes,
      onPopInvokedWithResult: (bool saiu, Object? r) async {
        if (saiu) return;
        final bool descartar = await _confirmarDescarte();
        if (!context.mounted) return;
        if (descartar) Navigator.of(context).pop();
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.args.ehEdicao ? 'Editar matéria' : 'Nova matéria'),
          actions: <Widget>[
            TextButton(
              onPressed: _temAlteracoes ? _salvar : null,
              child: const Text('Salvar'),
            ),
          ],
        ),

        // Form não desenha nada: ele só registra os campos abaixo dele.
        body: Form(
          key: _chaveDoFormulario,

          // ListView, não Column: com o teclado aberto, os campos de baixo
          // precisam continuar alcançáveis. Módulo 06, aula 11.
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              // ── Nome ──────────────────────────────────────────────────
              TextFormField(
                controller: _nome,
                autofocus: !widget.args.ehEdicao,
                // Nomes próprios começam com maiúscula automaticamente.
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Nome da matéria',
                  hintText: 'Ex.: Cálculo I',
                  helperText: 'Como ela vai aparecer na sua lista',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                validator: (String? v) {
                  final String texto = (v ?? '').trim();
                  if (texto.isEmpty) return 'Informe o nome da matéria';
                  if (texto.length < 2) return 'Use pelo menos 2 letras';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // ── Categoria ─────────────────────────────────────────────
              // O único seletor que participa do Form e tem validator.
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
                onChanged: (CategoriaMateria? v) {
                  if (v == null) return;
                  setState(() => _categoria = v);
                },
              ),
              const SizedBox(height: 16),

              // ── Meta diária ───────────────────────────────────────────
              TextFormField(
                controller: _meta,
                keyboardType: TextInputType.number,
                // keyboardType sugere o teclado; o formatter é quem GARANTE
                // que só entra dígito (inclusive ao colar).
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: const InputDecoration(
                  labelText: 'Meta diária',
                  suffixText: 'minutos',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (String? v) {
                  final int? n = int.tryParse(v ?? '');
                  if (n == null) return 'Informe um número';
                  if (n < 5) return 'A meta mínima é 5 minutos';
                  if (n > 480) return 'A meta máxima é 480 minutos (8 h)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Observação ────────────────────────────────────────────
              TextFormField(
                controller: _observacao,
                // multiline + maxLines null = o campo cresce com o texto.
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                minLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Livro, professor, link do material…',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),

              // ── Lembrete ──────────────────────────────────────────────
              SwitchListTile(
                title: const Text('Lembrete diário'),
                subtitle: const Text('Avisa quando a meta não foi cumprida'),
                value: _lembrete,
                onChanged: (bool v) => setState(() => _lembrete = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _temAlteracoes ? _salvar : null,
                icon: const Icon(Icons.check),
                label: Text(widget.args.ehEdicao ? 'Salvar' : 'Criar matéria'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Rode e teste:

```powershell
flutter analyze
flutter run -d chrome
```

1. Abra o formulário vazio e aperte **Criar matéria** → o botão está desabilitado (nada mudou).
2. Digite uma letra só no nome e limpe a meta → aperte Salvar → **dois erros** aparecem juntos.
3. Tente digitar letras na meta → não entram.
4. Digite um texto longo na observação → o campo **cresce** sozinho.
5. Preencha tudo e salve → a matéria volta para a lista, como na aula 3.
6. Digite algo e tente voltar → o diálogo de descarte aparece, como na aula 5.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `final GlobalKey<FormState> _chaveDoFormulario` como **campo do State** | Criada no `build`, seria uma chave nova a cada rebuild — e o estado de validação se perderia. |
| `Form(key: ..., child: ListView(...))` | O `Form` não desenha nada; ele registra os `FormField` abaixo dele e oferece `validate`/`save`/`reset`. |
| `ListView` em vez de `Column` dentro do `Form` | Com o teclado aberto, os campos de baixo precisam continuar alcançáveis. |
| `enum CategoriaMateria` com campos | *Enhanced enum* do Dart 3: rótulo e ícone viajam junto com o valor. [Módulo 03](../03-dart-intermediario/07-enums.md). |
| `late final TextEditingController _nome = TextEditingController(text: ...)` | `late` porque depende de `widget`, que não existe no inicializador simples. |
| `_nome..removeListener(_aoMudar)..dispose();` | Cascata do Dart. Remover o listener antes de liberar é a ordem correta. |
| `bool get _temAlteracoes` | **Getter**, recalculado a cada rebuild. Um campo `late final` ficaria congelado e a proteção não funcionaria. |
| `_nome.addListener(_aoMudar)` + `setState(() {})` | Cada tecla dispara rebuild, que atualiza `canPop` **e** o estado do botão Salvar. |
| `if (!_chaveDoFormulario.currentState!.validate()) return;` | Roda todos os `validator` e desenha os erros **nos campos**. O `!` é seguro dentro de um callback de botão. |
| `validator: (String? v) => ...` devolvendo `String?` | `null` = válido; qualquer texto = mensagem de erro. Essa inversão confunde no começo. |
| `(v ?? '').trim()` dentro do validator | `v` é `String?`. E `trim()` impede que três espaços passem como "preenchido". |
| `textCapitalization: TextCapitalization.words` no nome | Cada palavra começa com maiúscula. Em e-mail seria um desastre — por isso é por campo. |
| `keyboardType` + `inputFormatters` juntos | O primeiro **sugere** o teclado; o segundo **garante** o conteúdo, inclusive ao colar. |
| `LengthLimitingTextInputFormatter(3)` × `maxLength: 40` | O formatter **impede** digitar além; `maxLength` mostra contador e também limita. No nome usamos `maxLength` (com contador visível); na meta, o formatter. |
| `maxLines: null, minLines: 3` | O campo começa com 3 linhas e **cresce** conforme o texto. `maxLines: null` sem `minLines` começaria com uma linha. |
| `alignLabelWithHint: true` | Em campo multilinha, alinha o rótulo no topo em vez de no meio. |
| `DropdownButtonFormField<CategoriaMateria>` | Participa do `Form` e aceita `validator` — `DropdownButton` puro não. |
| `contentPadding: EdgeInsets.zero` no `SwitchListTile` | Alinha o switch com os campos de texto, que já têm o próprio padding. |
| `onPressed: _temAlteracoes ? _salvar : null` | Botão desabilitado quando não há o que salvar. Mais honesto que escondê-lo. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Teclado numérico | Só dígitos, teclas grandes | Dígitos + botões extras; sem tecla "concluído" por padrão |
| `TextInputType.emailAddress` | `@` e `.com` visíveis | `@` e `.` visíveis |
| Autocorreção | Ligada por padrão | Ligada por padrão, **mais agressiva** |
| Barra de sugestões | Do teclado instalado | Do sistema, com "Concluído" em alguns tipos |
| Fechar o teclado | Botão voltar do sistema | **Só tocando fora** — não há botão voltar |
| Preenchimento automático | Autofill do Google | Chaves do iCloud, mais insistente |

> 📌 **A diferença que exige código:** no iOS, com `TextInputType.number`, **não existe** botão para
> fechar o teclado. O usuário fica preso olhando o teclado. Duas soluções:
> `TextInputType.numberWithOptions(signed: false, decimal: false)` combinado com um
> `GestureDetector` que chama `FocusScope.of(context).unfocus()` ao tocar fora — ou uma barra de
> ferramentas com "Concluído". A [aula 7](07-validacao-foco-teclado.md) implementa isso.

> ⚠️ Para campos de nome próprio, considere `autocorrect: false`. A autocorreção do iOS transforma
> "Cálculo I" em "Cálculo Í" com uma frequência irritante.

---

## ⚠️ Erros comuns

### 1. Esquecer o `dispose` do controller

```dart
final TextEditingController _nome = TextEditingController();
// … sem dispose ❌
```

Vazamento de memória. Com muitas telas de formulário, o app fica lento e acaba morrendo.

**Correção:** um `dispose()` para cada controller. Escreva as duas linhas juntas.

### 2. Criar a `GlobalKey` dentro do `build`

```dart
@override
Widget build(BuildContext context) {
  final GlobalKey<FormState> chave = GlobalKey<FormState>();   // ❌
  return Form(key: chave, ...);
}
```

A cada rebuild nasce uma chave nova. `validate()` age sobre um formulário diferente do que está na
tela — e os erros nunca aparecem.

**Correção:** campo `final` do `State`.

### 3. `controller` e `initialValue` juntos

```dart
TextFormField(
  controller: _nome,
  initialValue: 'Cálculo',   // ❌
)
```

```text
'initialValue == null || controller == null': is not true.
```

**Correção:** escolha um. Com controller, passe o valor inicial no construtor dele:
`TextEditingController(text: 'Cálculo')`.

### 4. `Column` dentro do `Form` com teclado aberto

```text
A RenderFlex overflowed by 210 pixels on the bottom.
```

**Correção:** `ListView` ou `SingleChildScrollView`.

### 5. Validator invertido

```dart
validator: (String? v) => v!.isEmpty ? null : 'Obrigatório',   // ❌
```

A convenção é contraintuitiva: **`null` significa válido**. Esse código reclama justamente quando o
campo está preenchido.

**Correção:** `v!.isEmpty ? 'Obrigatório' : null`.

### 6. `v!` dentro do validator

```dart
validator: (String? v) => v!.trim().isEmpty ? 'Obrigatório' : null,   // ⚠️
```

Funciona com `TextFormField` (que nunca passa `null`), mas quebra em outros `FormField`.

**Correção:** `(v ?? '').trim()`.

### 7. Validar sem `trim()`

```dart
validator: (String? v) => v!.isEmpty ? 'Obrigatório' : null,
```

Três espaços passam como "preenchido", e o app salva uma matéria chamada `"   "`.

**Correção:** `trim()` no validator **e** ao salvar.

### 8. `keyboardType` sem `inputFormatters`

```dart
TextFormField(keyboardType: TextInputType.number)   // ⚠️
```

O `keyboardType` só **sugere** o teclado. Colar texto, usar teclado físico ou um teclado de
terceiros permite letras — e `int.parse` explode.

**Correção:** `FilteringTextInputFormatter.digitsOnly` junto.

### 9. `hintText` no lugar de `labelText`

```dart
decoration: const InputDecoration(hintText: 'Nome da matéria')   // ❌
```

Ao digitar, o texto some e o usuário esquece o que o campo pede. Leitores de tela também não
anunciam `hintText` de forma confiável.

**Correção:** `labelText` sempre; `hintText` só para exemplo.

### 10. `TextField` dentro de um `Form`

```dart
Form(
  key: _chave,
  child: TextField(controller: _nome),   // ❌ não é registrado
)
```

`validate()` devolve `true` mesmo com o campo vazio — porque esse campo **não existe** para o
`Form`.

**Correção:** `TextFormField`.

### 11. `int.parse` sem validar antes

```dart
final int meta = int.parse(_meta.text);   // ⚠️ se o validator falhar, explode
```

```text
FormatException: Invalid radix-10 number
```

**Correção:** só chame `int.parse` **depois** de `validate()` retornar `true`; ou use
`int.tryParse` com valor padrão.

---

## 🛠️ Exercício guiado

**Passo 1.** Abra o formulário, aperte Salvar com tudo vazio e conte quantos erros aparecem de uma
vez. Compare mentalmente com o esforço de fazer isso na mão.

**Passo 2.** Troque o `TextFormField` do nome por `TextField` (mantendo o controller). Aperte
Salvar com o campo vazio. O que acontece e por quê? Depois desfaça.

**Passo 3.** Remova `_nome.dispose()` do `dispose`. Rode `flutter analyze`. O analisador avisa? E o
app quebra? Explique por que esse é um bug perigoso. Depois restaure.

**Passo 4.** Mova a criação da `GlobalKey` para dentro do `build`. Preencha o nome com uma letra e
aperte Salvar. Descreva o que acontece. Depois restaure.

**Passo 5.** Remova `FilteringTextInputFormatter.digitsOnly` do campo de meta. Cole um texto com
letras nele (`Ctrl` + `V`) e aperte Salvar. Leia o erro. Depois restaure.

**Passo 6.** Inverta o validator do nome (`null` quando vazio). Teste. Anote a mensagem que o
usuário veria.

**Passo 7.** Troque `ListView` por `Column` dentro do `Form`. Rode em um celular ou emulador, toque
no campo de observação e observe. Depois desfaça.

**Passo 8.** Troque `labelText` por `hintText` no campo de nome. Digite algo e observe o que
acontece com o rótulo. Explique por que isso é um problema de acessibilidade.

**Passo 9.** Acrescente um campo de **e-mail do professor** (opcional), com `keyboardType`
adequado, `textCapitalization: none` e validator que só reclama **se** algo foi digitado.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)

Faça os exercícios de **Aplicação** com `Form` + `GlobalKey`, o de **Correção de bugs** com o
controller sem `dispose`, e o de **Decisão** sobre controller × `onSaved`.

---

## 🏆 Desafio opcional

Crie um widget `CampoTexto` que padronize todos os campos do app:

```dart
CampoTexto.nome(controller: _nome, rotulo: 'Nome da matéria')
CampoTexto.numero(controller: _meta, rotulo: 'Meta', sufixo: 'min', min: 5, max: 480)
CampoTexto.email(controller: _email, rotulo: 'E-mail do professor')
CampoTexto.multilinha(controller: _obs, rotulo: 'Observações', maxCaracteres: 200)
```

Requisitos:

- Cada construtor nomeado já configura `keyboardType`, `textCapitalization`, `inputFormatters` e um
  `validator` padrão coerente.
- É possível **sobrescrever** o validator quando a tela precisar de uma regra específica.
- Nenhum formulário do app volta a repetir `keyboardType` e `inputFormatters`.

Depois responda: quantas linhas o `MateriaFormScreen` perdeu? E o que aconteceria se a equipe
decidisse que **todo** campo numérico passa a aceitar vírgula — quantos arquivos precisariam mudar?

---

## 📌 Resumo

- O widget **`Form`** não desenha nada: ele registra os `FormField` abaixo dele e oferece
  `validate()`, `save()` e `reset()` em lote.
- **`GlobalKey<FormState>`** é a referência que permite chamar essas operações. Declare como campo
  `final` do `State`, **nunca** dentro do `build`.
- Dentro de formulário, use **`TextFormField`**, nunca `TextField` — só o primeiro é registrado
  pelo `Form`.
- **Todo `TextEditingController` precisa de `dispose()`.** Escreva criação e `dispose` como um par.
- **Decisão do curso: controller**, não `onSaved` — porque só o controller permite detectar
  alterações a cada tecla (a proteção da aula 5).
- Nunca use `controller` e `initialValue` no mesmo campo.
- `validator` devolve **`null` quando está válido** e uma `String` quando há erro. Essa inversão
  confunde — memorize.
- Sempre aplique `trim()` no validator e ao salvar.
- Use **`labelText`** para nomear o campo (fica sempre) e `hintText` só para exemplo (some ao
  digitar).
- `keyboardType` **sugere** o teclado; `inputFormatters` **garante** o conteúdo. Use os dois.
- Formulário sempre dentro de **`ListView`** ou `SingleChildScrollView` — nunca `Column` pura.
- `DropdownButtonFormField` é o único seletor que participa do `Form` e aceita `validator`.
- Campo multilinha: `maxLines: null` + `minLines: n` + `alignLabelWithHint: true`.

---

## ☑️ Checklist de domínio

- [ ] Explico o que o `Form` faz sem usar a palavra "desenha".
- [ ] Declaro a `GlobalKey<FormState>` como campo do `State` e sei o que acontece se eu não fizer.
- [ ] Uso `TextFormField` em formulário e sei o que quebra ao usar `TextField`.
- [ ] Dou `dispose()` em todo controller que eu criar.
- [ ] Escolho entre controller e `onSaved` e justifico a escolha do curso.
- [ ] Escrevo validators que devolvem `null` para válido.
- [ ] Aplico `trim()` na validação e ao salvar.
- [ ] Uso `labelText` para o nome do campo e `hintText` só para exemplo.
- [ ] Configuro `keyboardType` e `textCapitalization` corretos em cada campo.
- [ ] Uso `inputFormatters` em todo campo numérico.
- [ ] Meu formulário fica dentro de um widget rolável.
- [ ] Uso `DropdownButtonFormField` quando preciso de seleção validável.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Build a form with validation — docs.flutter.dev](https://docs.flutter.dev/cookbook/forms/validation)
- [Form class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Form-class.html)
- [TextFormField class — api.flutter.dev](https://api.flutter.dev/flutter/material/TextFormField-class.html)
- [TextEditingController — api.flutter.dev](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)
- [InputDecoration class — api.flutter.dev](https://api.flutter.dev/flutter/material/InputDecoration-class.html)
- [TextInputType class — api.flutter.dev](https://api.flutter.dev/flutter/services/TextInputType-class.html)
- [FilteringTextInputFormatter — api.flutter.dev](https://api.flutter.dev/flutter/services/FilteringTextInputFormatter-class.html)
- [Material 3 text fields — m3.material.io](https://m3.material.io/components/text-fields/overview)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Navegação Android × iOS](05-navegacao-android-x-ios.md) | [README](README.md) | [Aula 7 — Validação, foco e teclado](07-validacao-foco-teclado.md) |
