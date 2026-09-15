# Aula 4 — Análise, lint e formatação

> **Módulo:** 12 - Testes e Debug · **Tempo estimado:** 30 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar a diferença entre **erro do compilador**, **aviso do analisador** e **lint**.
- Configurar o **`analysis_options.yaml`** com critério, não copiando de tutoriais.
- Distinguir **`error`**, **`warning`** e **`info`** — e quando promover um ao outro.
- Usar **`// ignore:`** e **`// ignore_for_file:`** com responsabilidade.
- Rodar **`dart format`** e entender por que não há o que configurar nele.
- Montar uma **verificação antes do commit** que roda em segundos.
- Saber quais lints **valem de verdade** e quais são preferência pessoal.

## ✅ Pré-requisitos

- [Módulo 05, aula 2 — Estrutura do projeto](../05-introducao-ao-flutter/02-estrutura-do-projeto.md)
  — o `analysis_options.yaml` apareceu lá.
- [Aula 1 — Lendo stack traces](01-lendo-stack-traces.md) — o analisador pega, **antes de rodar**,
  boa parte do que viraria erro em execução.
- [Módulo 00, aula 4 — Commits, branches e .gitignore](../00-git-e-terminal/04-commits-branches-gitignore.md)
  — a verificação antes do commit.

---

## 📖 Conceito

### Três camadas de verificação

Elas acontecem em momentos diferentes e custam coisas diferentes:

| Camada | Quando | O que pega | Você pode ignorar? |
|---|---|---|---|
| **Compilador** | Ao compilar | Erro de tipo, sintaxe, `null` | ❌ **Não compila** |
| **Analisador** | Enquanto você digita | Código que compila mas está errado | ⚠️ Sim, com esforço |
| **Lint** | Idem | Estilo e boas práticas | ✅ Sim |

O ganho de cada uma é diferente:

```dart
// Compilador: não compila.
final int x = 'texto';

// Analisador: compila e quebra em execução.
final List<int> lista = <int>[];
print(lista.first);   // Bad state: No element

// Lint: compila, funciona, e é uma má ideia.
print('debug');       // avoid_print
```

> 📌 **O analisador é o teste mais barato que existe.** Ele roda enquanto você digita, encontra
> problemas antes de o app abrir, e custa zero segundos do seu tempo. Um lint bem escolhido paga
> por si na primeira vez que evita um bug.

### `dart analyze` e o que ele reporta

```powershell
dart analyze
# ou, num projeto Flutter:
flutter analyze
```

A saída tem três níveis:

```text
error • The argument type 'String' can't be assigned to 'int' • lib/x.dart:12:5
warning • The value of the local variable 'y' isn't used • lib/x.dart:20:9
info • Don't invoke 'print' in production code • lib/x.dart:30:3 • avoid_print
```

| Nível | Significa | `flutter analyze` falha? |
|---|---|---|
| **error** | Não compila, ou quebra na certa | ✅ código de saída 1 |
| **warning** | Provavelmente um bug | ✅ código de saída 1 |
| **info** | Sugestão de estilo | ❌ não falha por padrão |

> ⚠️ **`info` não falhar é uma armadilha.** Numa equipe (ou num projeto seu, seis meses depois), os
> `info` se acumulam até ninguém mais ler a saída do `analyze`. A seção sobre `errors:` mostra como
> promover os que importam.

### `analysis_options.yaml`, por dentro

```yaml
# Herda um conjunto pronto de regras.
include: package:flutter_lints/flutter.yaml

analyzer:
  # Muda a severidade de regras específicas.
  errors:
    avoid_print: error

  # Arquivos que o analisador ignora.
  exclude:
    - "**/*.g.dart"
    - "build/**"

  language:
    # Verificações mais rígidas (ver adiante).
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    - always_declare_return_types
    - prefer_final_locals
```

Quatro seções, quatro propósitos:

| Seção | Para quê |
|---|---|
| `include` | Herdar um conjunto pronto |
| `analyzer.errors` | **Promover ou rebaixar** a severidade de uma regra |
| `analyzer.exclude` | Ignorar arquivos gerados |
| `linter.rules` | Ligar regras além das herdadas |

### Os conjuntos prontos

| Pacote | Quantas regras | Para quem |
|---|---|---|
| `lints/core.yaml` | ~30 | O mínimo, para qualquer projeto Dart |
| `lints/recommended.yaml` | ~60 | Dart, com boas práticas |
| **`flutter_lints/flutter.yaml`** | ~70 | **Projetos Flutter — o padrão** |
| `very_good_analysis` | ~200 | Times que querem rigor alto |

**Decisão do curso:** `flutter_lints` como base, mais um punhado de regras que valem a pena. Os
conjuntos gigantes (`very_good_analysis`) impõem escolhas de estilo que atrapalham quem está
aprendendo — e geram centenas de avisos num projeto existente.

### As regras que valem mesmo

Nem todo lint tem o mesmo valor. Estas **pegam bugs**:

| Regra | O que evita |
|---|---|
| `use_build_context_synchronously` | Usar `context` depois de `await` sem checar `mounted` |
| `avoid_dynamic_calls` | Chamada em `dynamic` que explode em execução |
| `cancel_subscriptions` | `StreamSubscription` sem `cancel` — vazamento |
| `close_sinks` | `StreamController` sem `close` |
| `unawaited_futures` | `Future` esquecido sem `await` — erro engolido |
| `avoid_slow_async_io` | `File.exists()` assíncrono, que é mais lento que o síncrono |
| `no_adjacent_strings_in_list` | `['a' 'b']` — vírgula esquecida vira concatenação |
| `avoid_returning_null_for_future` | `Future` nulo em vez de `Future.value(null)` |

Estas são **estilo** — úteis para consistência, sem pegar bug:

| Regra | O que padroniza |
|---|---|
| `prefer_single_quotes` | Aspas simples |
| `always_declare_return_types` | Tipo de retorno explícito |
| `prefer_final_locals` | `final` em variáveis locais |
| `sort_child_properties_last` | `child:` por último |
| `always_specify_types` | Tipos explícitos em tudo |

> 💡 **A distinção importa na hora de decidir.** Um lint que pega bug vale ser promovido a `error`.
> Um lint de estilo que gera 300 avisos num projeto existente talvez não valha o esforço de
> corrigir agora.

### As verificações de linguagem

Além dos lints, o analisador tem três chaves que mudam o **rigor do sistema de tipos**:

```yaml
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
    strict-inference: true
```

| Chave | O que passa a ser erro |
|---|---|
| `strict-casts` | Conversão implícita de `dynamic` para um tipo |
| `strict-raw-types` | Tipo genérico sem argumento (`List` em vez de `List<int>`) |
| `strict-inference` | Tipo que o analisador não conseguiu inferir |

O `strict-casts` é o mais valioso:

```dart
final Map<String, dynamic> json = jsonDecode(texto);

// Sem strict-casts: compila, e explode se não for String.
final String nome = json['nome'];

// Com strict-casts: o analisador EXIGE o cast explícito.
final String nome = json['nome'] as String;
```

Ele força você a **ver** cada ponto onde um tipo está sendo assumido — exatamente os pontos que
quebram quando a API muda ([Módulo 09, aula 7](../09-consumo-de-api/07-camada-de-dados-testavel.md)).

### `// ignore:` com responsabilidade

Às vezes um lint está errado para o seu caso:

```dart
// ignore: avoid_print
print('Esta linha roda só no script de build');
```

E, para o arquivo inteiro:

```dart
// ignore_for_file: avoid_print
```

Três regras de uso:

**1. Sempre explique por quê.**

```dart
// ❌ ignora sem contexto
// ignore: use_build_context_synchronously
Navigator.of(context).pop();

// ✅ explica
// O `mounted` foi checado três linhas acima; o analisador não
// consegue rastrear através do método auxiliar.
// ignore: use_build_context_synchronously
Navigator.of(context).pop();
```

**2. Prefira `// ignore:` a `// ignore_for_file:`.** O primeiro cobre uma linha; o segundo cobre
tudo — inclusive o problema real que aparecer amanhã.

**3. `// ignore_for_file:` é legítimo em arquivos gerados** e em scripts de ferramenta
(`tool/`), onde `print` é a saída esperada.

> ⚠️ **O sinal de alerta:** um `// ignore:` de `use_build_context_synchronously` quase sempre
> significa que o `mounted` **não** foi checado. Esse lint específico raramente está errado.

### `dart format`: não há o que configurar

```powershell
dart format .
dart format --output=none --set-exit-if-changed .   # só verifica
```

O formatador do Dart é **deliberadamente sem opções**. Não dá para escolher aspas, indentação ou
posição de chaves.

Isso é uma decisão de projeto, e ela resolve um problema real: **discussões de formatação em
revisão de código**. Com um formatador sem opções, não há o que discutir — todo código Dart do
mundo tem a mesma cara.

A única coisa que você controla é a **largura da linha**:

```yaml
# analysis_options.yaml
formatter:
  page_width: 80
```

> 📌 **80 colunas é o padrão**, e vale manter. Linhas curtas cabem lado a lado em revisão de código
> e em telas divididas. Se o seu código não cabe em 80 colunas, geralmente o problema é o
> aninhamento — não a largura.

E o truque que evita `dart format` desfazer a sua formatação manual:

```dart
// A vírgula final (trailing comma) força o formatador a quebrar
// cada argumento em uma linha.
Widget build(BuildContext context) {
  return Column(
    children: <Widget>[
      Text('a'),
      Text('b'),
    ],   // ← esta vírgula
  );
}
```

Sem a vírgula final, o formatador tentaria juntar tudo numa linha só. **Com** ela, ele preserva
uma linha por item.

### A verificação antes do commit

Três comandos, poucos segundos:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

| Comando | Pega |
|---|---|
| `dart format --set-exit-if-changed` | Arquivo não formatado |
| `flutter analyze` | Erro, aviso e lint |
| `flutter test` | Regressão |

Rodar isso antes de cada commit evita o cenário mais chato do trabalho em equipe: um *pull request*
com 400 linhas alteradas, das quais 380 são só reformatação.

---

## 💡 Analogia

Pense num texto que você vai publicar.

- **O compilador** é a **gramática**: "a frase não tem verbo" não é opinião. O texto não existe
  assim.
- **O analisador** é o **revisor**: a frase está gramaticalmente correta, mas diz "eu vi ela ontem
  de bicicleta" — e ninguém sabe quem estava de bicicleta. Compila, e está errado.
- **O lint** é o **manual de estilo da publicação**: números até dez por extenso, aspas duplas para
  citação. Nada disso é erro; é consistência.
- **Promover um lint a `error`** é dizer "nesta redação, usar 'a nível de' é motivo de devolução".
  Você elegeu uma regra de estilo como inegociável — porque ela sempre precede um problema maior.
- **O `// ignore:` com explicação** é a nota do autor na margem: "aqui a repetição é proposital".
  Sem a nota, o próximo revisor "corrige" e estraga.
- **O formatador sem opções** é a publicação ter **uma única** folha de estilo. Antes disso, cada
  reunião de pauta gastava vinte minutos discutindo se o título leva ponto final. Depois, ninguém
  discute — porque não há o que discutir.
- **A verificação antes do commit** é reler o texto antes de enviar. Custa dois minutos e evita a
  correção pública.

---

## 🧪 Exemplo mínimo

Um arquivo com **um problema de cada camada**, para você ver a diferença.

> **Arquivo:** `foco_lab/lib/exemplo_analise.dart` (temporário)
> **Como executar:** `flutter analyze lib/exemplo_analise.dart`

```dart
// ignore_for_file: unused_local_variable, avoid_print
//
// ⚠️ Este ignore_for_file existe só para o arquivo compilar como
// demonstração. Em código de verdade, ignorar o arquivo inteiro é
// o último recurso — ver a seção "Erros comuns".

import 'dart:async';
import 'dart:convert';

// ══════════════════════════════════════════════════════════════════
// CAMADA 1 — COMPILADOR: não compila
// ══════════════════════════════════════════════════════════════════

void erroDeCompilacao() {
  // Descomente para ver:
  //
  // final int x = 'texto';
  //   error • A value of type 'String' can't be assigned to
  //           a variable of type 'int'
  //
  // O compilador RECUSA. Não há discussão, não há ignore.
}

// ══════════════════════════════════════════════════════════════════
// CAMADA 2 — ANALISADOR: compila e quebra em execução
// ══════════════════════════════════════════════════════════════════

void avisosDoAnalisador() {
  // ⚠️ warning: variável nunca usada.
  //
  // Compila. E costuma indicar que você esqueceu de usar algo —
  // ou deixou lixo de uma refatoração.
  final int naoUsada = 42;

  // ⚠️ warning: comparação que é sempre falsa.
  //
  // O analisador sabe que String nunca é int. Este código roda
  // e o `if` NUNCA entra — um bug silencioso.
  const String texto = 'oi';
  if (texto == 42) {
    print('impossível');
  }

  // ⚠️ dead_code: nada depois do return roda.
  return;
  // ignore: dead_code
  print('nunca chega aqui');
}

/// O que `strict-casts` pega.
///
/// SEM a chave ligada, este código compila e explode em execução
/// quando a API muda um campo. COM ela, o analisador exige o cast
/// explícito — e você VÊ cada ponto onde está assumindo um tipo.
void semStrictCasts(String corpo) {
  final Map<String, dynamic> json =
      jsonDecode(corpo) as Map<String, dynamic>;

  // ❌ Sem strict-casts: compila.
  //    Com strict-casts: error • Implicit cast from 'dynamic' to 'String'
  //
  // final String nome = json['nome'];

  // ✅ Explícito: você VÊ que está assumindo.
  final String nome = json['nome'] as String;

  // ✅ Melhor ainda: valida antes.
  final Object? bruto = json['idade'];
  final int idade = bruto is int ? bruto : 0;

  print('$nome, $idade');
}

// ══════════════════════════════════════════════════════════════════
// CAMADA 3 — LINT: compila, funciona, e é má ideia
// ══════════════════════════════════════════════════════════════════

class ExemplosDeLint {
  /// ⚠️ avoid_print — `print` não é removido em release.
  ///
  /// Ele fica no binário, aparece no `logcat` do usuário, e pode
  /// vazar dados. `debugPrint` é removido automaticamente.
  void usoDePrint() {
    print('isto vai para o log do usuário em produção');
    debugPrintExemplo('isto some em release');
  }

  void debugPrintExemplo(String m) {}

  /// ⚠️ unawaited_futures — o Future é esquecido.
  ///
  /// Este é o lint que MAIS pega bug real: sem o await, uma
  /// exceção dentro do Future é ENGOLIDA. O app parece funcionar
  /// e simplesmente não faz o que deveria.
  void futureEsquecido() {
    // ❌ sem await: se `salvar` lançar, ninguém fica sabendo
    _salvar();

    // ✅ ou você espera…
    // await _salvar();

    // ✅ …ou declara que o esquecimento é PROPOSITAL
    // unawaited(_salvar());
  }

  Future<void> _salvar() async {
    throw Exception('esta exceção some sem o await');
  }

  /// ⚠️ cancel_subscriptions — vazamento garantido.
  StreamSubscription<int>? _inscricao;

  void semCancel(Stream<int> fonte) {
    // ❌ Sem o cancel no dispose, o callback continua rodando
    //    depois de o objeto morrer.
    _inscricao = fonte.listen(print);
  }

  /// ⚠️ no_adjacent_strings_in_list — o bug da vírgula esquecida.
  ///
  /// Duas strings adjacentes em Dart são CONCATENADAS. Uma vírgula
  /// esquecida transforma dois itens em um, sem nenhum erro.
  List<String> virgulaEsquecida() {
    return <String>[
      'primeiro'
      'segundo',   // ← faltou vírgula depois de 'primeiro'
      'terceiro',
    ];
    // Resultado: ['primeirosegundo', 'terceiro'] — DOIS itens,
    // não três. E nada avisa, sem o lint.
  }

  /// ⚠️ avoid_dynamic_calls — explode em execução.
  void chamadaEmDynamic(dynamic objeto) {
    // ❌ O analisador não tem como verificar se o método existe.
    //    Se não existir: NoSuchMethodError, em produção.
    // objeto.metodoQueTalvezNaoExista();

    // ✅ Verifique o tipo primeiro.
    if (objeto is String) {
      print(objeto.toUpperCase());
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// FORMATAÇÃO — a vírgula final
// ══════════════════════════════════════════════════════════════════

class ExemploDeFormatacao {
  /// SEM vírgula final: o formatador junta tudo que couber em 80
  /// colunas. Fica compacto e difícil de ler em árvore de widgets.
  void semVirgulaFinal() {
    final List<String> lista =
        <String>['primeiro', 'segundo', 'terceiro', 'quarto'];
    print(lista);
  }

  /// COM vírgula final: o formatador preserva uma linha por item.
  ///
  /// É o truque que torna árvores de widgets legíveis — e a razão
  /// de todo código Flutter ter vírgula depois do último argumento.
  void comVirgulaFinal() {
    final List<String> lista = <String>[
      'primeiro',
      'segundo',
      'terceiro',
      'quarto',
    ];   // ← a vírgula depois de 'quarto' é o que faz a diferença
    print(lista);
  }
}
```

**Faça isto, na ordem:**

1. `flutter analyze lib/exemplo_analise.dart` — leia cada aviso.
2. Remova o `// ignore_for_file:` do topo. Quantos avisos aparecem?
3. Descomente a linha `final int x = 'texto';`. Repare que agora é **error**, não warning.
4. Rode `dart format lib/exemplo_analise.dart` e compare `semVirgulaFinal` com `comVirgulaFinal`.
5. Descomente a linha de `strict-casts` no `semStrictCasts` **depois** de ligar a chave no
   `analysis_options.yaml`, e veja o erro aparecer.

---

## 📱 Aplicando no Flutter

Agora você monta o `analysis_options.yaml` definitivo do curso — com cada escolha justificada — e a
verificação antes do commit.

---

## 💻 Código completo

> **Arquivo:** `foco_lab/analysis_options.yaml`
> **Como executar:** `flutter analyze`

```yaml
# ═══════════════════════════════════════════════════════════════════
# Configuração do analisador — Curso Flutter Intensivo
#
# Base: flutter_lints (o conjunto oficial do time do Flutter).
# Acréscimos: só regras que PEGAM BUG ou que o curso usa como padrão.
#
# Deliberadamente NÃO usamos very_good_analysis: ~200 regras geram
# centenas de avisos num projeto em andamento, e boa parte delas é
# preferência de estilo que atrapalha quem está aprendendo.
# ═══════════════════════════════════════════════════════════════════

include: package:flutter_lints/flutter.yaml

analyzer:
  # ── Severidade ───────────────────────────────────────────────────
  errors:
    # ⚠️ PROMOVIDAS A ERROR: estas pegam bug de verdade, e um `info`
    # que ninguém lê não protege ninguém.

    # Usar context depois de await sem checar mounted.
    # É a causa nº 1 de crash em app Flutter. Módulo 05, aula 7.
    use_build_context_synchronously: error

    # Future esquecido sem await: a exceção dentro dele é ENGOLIDA.
    # O app parece funcionar e não faz o que deveria.
    unawaited_futures: error

    # StreamSubscription sem cancel = vazamento garantido.
    # Módulo 11, aula 5.
    cancel_subscriptions: error

    # StreamController sem close = idem.
    close_sinks: error

    # Duas strings adjacentes numa lista são CONCATENADAS.
    # Uma vírgula esquecida vira um item a menos, sem erro nenhum.
    no_adjacent_strings_in_list: error

    # ── REBAIXADAS ────────────────────────────────────────────────

    # TODO é legítimo durante o desenvolvimento. Vira problema
    # quando ninguém revisa — e isso é assunto de revisão de código,
    # não do analisador.
    todo: ignore

    # Comentário de documentação em membro público: valioso em
    # biblioteca, excessivo em app.
    public_member_api_docs: ignore

  # ── Arquivos ignorados ───────────────────────────────────────────
  exclude:
    # Gerados: você não escreveu, não vai corrigir.
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
    - "**/generated_plugin_registrant.dart"
    - "build/**"
    - ".dart_tool/**"

  # ── Rigor do sistema de tipos ────────────────────────────────────
  language:
    # A MAIS VALIOSA das três.
    #
    # Proíbe conversão implícita de dynamic. Força você a VER cada
    # ponto onde está assumindo um tipo — que são exatamente os
    # pontos que quebram quando a API muda.
    #
    #   final String nome = json['nome'];         ❌ com strict-casts
    #   final String nome = json['nome'] as String;  ✅
    strict-casts: true

    # Proíbe genérico sem argumento: `List` em vez de `List<int>`.
    # Um `List` cru é `List<dynamic>` — e perde toda a verificação.
    strict-raw-types: true

    # Proíbe tipo que o analisador não conseguiu inferir.
    # A mais rígida das três; ligue quando estiver confortável
    # com as outras duas.
    strict-inference: false

  # Trata arquivos que não compilam como erro, em vez de ignorá-los.
  plugins:
    - custom_lint

# ═══════════════════════════════════════════════════════════════════
linter:
  rules:
    # ── PEGAM BUG ─────────────────────────────────────────────────

    # Chamada em `dynamic` que o analisador não consegue verificar.
    # Vira NoSuchMethodError em produção.
    - avoid_dynamic_calls

    # File.exists() assíncrono é MAIS LENTO que o síncrono.
    # Um dos poucos casos em que async piora.
    - avoid_slow_async_io

    # Sempre trate a exceção OU declare que está ignorando.
    - avoid_catches_without_on_clauses

    # `catch (e) {}` vazio esconde o problema para sempre.
    - empty_catches

    # `==` sem `hashCode` quebra Set, Map e a comparação do Riverpod.
    # Módulo 08, aula 6.
    - hash_and_equals

    # Verificação de tipo que é sempre verdadeira ou sempre falsa.
    - unnecessary_type_check

    # `late` que nunca é inicializado antes do uso.
    - unnecessary_late

    # ── PADRÕES DO CURSO ──────────────────────────────────────────

    # Tipos explícitos.
    #
    # Escolha PEDAGÓGICA: enquanto você aprende, ver
    # `final NotifierProvider<X, int> p = ...` ensina mais do que
    # `final p = ...`. Em projeto profissional, muita gente desliga —
    # e é uma escolha defensável.
    - always_specify_types

    # Tipo de retorno explícito em toda função.
    - always_declare_return_types

    # `final` em variável local que não muda. Deixa a INTENÇÃO clara.
    - prefer_final_locals
    - prefer_final_in_for_each

    # `const` onde for possível: menos reconstrução.
    # Módulo 13, aula 1.
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables

    # `child:` por último deixa a árvore de widgets legível.
    - sort_child_properties_last

    # `key` como primeiro parâmetro, por convenção.
    - sort_constructors_first

    # Aspas simples, por consistência.
    - prefer_single_quotes

    # Chaves em todo `if`, mesmo de uma linha.
    #
    # Evita o bug clássico: acrescentar uma segunda linha e ela
    # ficar FORA do if, sem nenhum aviso.
    - curly_braces_in_flow_control_structures

    # Vírgula final: faz o formatador preservar uma linha por item.
    # É o que torna árvores de widgets legíveis.
    - require_trailing_commas

    # ── ORGANIZAÇÃO ───────────────────────────────────────────────

    # Imports ordenados e sem duplicata.
    - directives_ordering
    - unnecessary_import
    - depend_on_referenced_packages

    # `package:` em vez de caminho relativo entre features.
    # Caminho relativo quebra ao mover o arquivo de pasta.
    - always_use_package_imports

    # ── NÃO USADAS, E POR QUÊ ─────────────────────────────────────
    #
    # - lines_longer_than_80_chars
    #     O formatador já cuida disso. A regra reclamaria de strings
    #     longas e URLs em comentários, que não dá para quebrar.
    #
    # - prefer_double_quotes
    #     Conflita com prefer_single_quotes. Escolha uma.
    #
    # - avoid_classes_with_only_static_members
    #     O curso usa `abstract final class X` como espaço de nomes
    #     (TemaApp, Validadores, Rotas). É um padrão deliberado.
    #
    # - diagnostic_describe_all_properties
    #     Valioso em biblioteca de widgets, excessivo em app.

# ═══════════════════════════════════════════════════════════════════
formatter:
  # 80 colunas é o padrão do Dart, e vale manter: linhas curtas cabem
  # lado a lado em revisão de código e em tela dividida.
  #
  # Se o seu código não cabe em 80, o problema costuma ser o
  # ANINHAMENTO — extraia um widget.
  page_width: 80
```

> **Arquivo:** `foco_lab/tool/verificar.ps1` (novo — a verificação antes do commit)

```powershell
# Verificação antes do commit.
#
# Roda em segundos e evita o cenário mais chato do trabalho em
# equipe: um PR com 400 linhas alteradas, das quais 380 são só
# reformatação.
#
# Uso: .\tool\verificar.ps1

$ErrorActionPreference = "Continue"
$falhou = $false

Write-Host "`n=== 1/3 FORMATAÇÃO ===" -ForegroundColor Cyan

# --set-exit-if-changed: falha se algum arquivo NÃO estiver formatado,
# sem alterar nada. É o que você quer numa verificação.
dart format --output=none --set-exit-if-changed .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Arquivos nao formatados. Rode: dart format ." -ForegroundColor Red
    $falhou = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

Write-Host "`n=== 2/3 ANALISE ===" -ForegroundColor Cyan

# --fatal-infos: faz o `info` falhar também.
#
# Sem isto, os `info` se acumulam ate ninguem mais ler a saida
# do analyze — e um erro real se perde no meio de 200 avisos.
flutter analyze --fatal-infos
if ($LASTEXITCODE -ne 0) {
    Write-Host "Problemas encontrados pelo analisador." -ForegroundColor Red
    $falhou = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

Write-Host "`n=== 3/3 TESTES ===" -ForegroundColor Cyan

flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Testes falharam." -ForegroundColor Red
    $falhou = $true
} else {
    Write-Host "OK" -ForegroundColor Green
}

Write-Host ""
if ($falhou) {
    Write-Host "VERIFICACAO FALHOU - nao faca o commit ainda." -ForegroundColor Red
    exit 1
}

Write-Host "TUDO CERTO - pode commitar." -ForegroundColor Green
exit 0
```

> **Arquivo:** `foco_lab/.git/hooks/pre-commit` (opcional — automatiza a verificação)

```bash
#!/bin/sh
# Roda a verificação AUTOMATICAMENTE antes de cada commit.
#
# Para instalar (Git Bash, na raiz do projeto):
#   cp tool/pre-commit .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# Para pular em uma emergência: git commit --no-verify
# (E abra um issue para corrigir depois — "emergência" vira hábito.)

echo "Verificando formatação…"
if ! dart format --output=none --set-exit-if-changed . ; then
  echo ""
  echo "❌ Há arquivos não formatados."
  echo "   Rode: dart format ."
  exit 1
fi

echo "Analisando…"
if ! flutter analyze --fatal-infos ; then
  echo ""
  echo "❌ O analisador encontrou problemas."
  exit 1
fi

echo "✅ Verificação passou."
exit 0
```

> **Arquivo:** `foco_lab/lib/core/log.dart` (o `print` que você **pode** usar)

```dart
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Log do app.
///
/// Existe porque `avoid_print` está promovido a `error` no
/// analysis_options.yaml — e com razão:
///
///  - `print` NÃO é removido em release: ele fica no binário,
///    aparece no logcat do usuário e pode vazar dados;
///  - `print` limita a 1 KB por linha no Android e TRUNCA o resto,
///    silenciosamente;
///  - `print` não tem nível nem categoria, então não dá para filtrar.
///
/// Este arquivo concentra a saída e resolve os três problemas.
abstract final class Log {
  /// Diagnóstico durante o desenvolvimento.
  ///
  /// `debugPrint` é removido em release automaticamente, e limita a
  /// velocidade da saída para o Android não descartar linhas.
  static void debug(String mensagem, {String? categoria}) {
    if (!kDebugMode) return;
    debugPrint(categoria == null ? mensagem : '[$categoria] $mensagem');
  }

  /// Evento de negócio. Aparece na aba Logging do DevTools,
  /// com carimbo de tempo e filtro por nome.
  static void evento(String nome, {Map<String, Object?>? dados}) {
    developer.log(
      nome,
      name: 'foco',
      // Nível 800 = INFO, na convenção de `dart:developer`.
      level: 800,
      error: dados,
    );
  }

  /// Erro tratado.
  ///
  /// ⚠️ NUNCA registre dado sensível: token, senha, CPF.
  /// Logs vazam — ferramentas de análise capturam, relatórios de
  /// erro incluem. Módulo 10, aula 7.
  static void erro(
    String mensagem, {
    Object? excecao,
    StackTrace? pilha,
    String? categoria,
  }) {
    developer.log(
      mensagem,
      name: categoria ?? 'foco',
      // 1000 = SEVERE.
      level: 1000,
      error: excecao,
      stackTrace: pilha,
    );
  }
}
```

Rode a verificação:

```powershell
.\tool\verificar.ps1
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `include: package:flutter_lints/flutter.yaml` | O conjunto oficial do time do Flutter. Base sólida sem excessos. |
| `use_build_context_synchronously: error` | A causa nº 1 de crash em app Flutter. Um `info` que ninguém lê não protege. |
| `unawaited_futures: error` | O lint que mais pega bug real: sem `await`, a exceção é **engolida**. |
| `no_adjacent_strings_in_list: error` | Uma vírgula esquecida transforma dois itens em um, **sem erro nenhum**. |
| `todo: ignore` | `TODO` é legítimo durante o desenvolvimento; revisá-los é assunto de revisão de código. |
| `exclude` com `*.g.dart` | Você não escreveu, não vai corrigir. |
| `strict-casts: true` | A chave mais valiosa: força você a **ver** cada tipo assumido — os pontos que quebram quando a API muda. |
| `strict-inference: false` | A mais rígida das três. Ligue depois de estar confortável com as outras. |
| `always_specify_types` com justificativa | Escolha **pedagógica**, e a nota admite que muita gente desliga em projeto profissional. |
| `curly_braces_in_flow_control_structures` | Evita o bug clássico: acrescentar uma segunda linha e ela ficar **fora** do `if`. |
| `require_trailing_commas` | Faz o formatador preservar uma linha por item — o que torna árvores de widgets legíveis. |
| `always_use_package_imports` | Caminho relativo quebra ao mover o arquivo de pasta. |
| A seção "NÃO USADAS, E POR QUÊ" | Registra as decisões. Sem ela, alguém acrescenta `lines_longer_than_80_chars` e ninguém lembra por que foi descartada. |
| `--set-exit-if-changed` no format | Falha **sem alterar nada**. É o que você quer numa verificação. |
| `--fatal-infos` no analyze | Sem isso, os `info` se acumulam e um erro real se perde no meio de 200 avisos. |
| `Log.debug` usando `debugPrint` | Removido em release, e limita a velocidade para o Android não descartar linhas. |
| `developer.log` com `name` e `level` | Aparece na aba Logging do DevTools, filtrável. |
| Aviso sobre dado sensível em log | Logs vazam: ferramentas capturam, relatórios de erro incluem. |

---

## 🤖🍎 Android × iOS

O analisador é o mesmo nas duas plataformas — mas há diferenças no **log**:

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| `print` em release | Fica no binário e aparece no `logcat` | Fica e aparece no Console |
| Limite por linha | **1 KB** — o resto é truncado em silêncio | Maior |
| `debugPrint` em release | Removido | Removido |
| Ver o log | `adb logcat` | Console.app / Xcode |
| Filtrar por `name` | ✅ com `developer.log` | ✅ |

> ⚠️ **O truncamento em 1 KB do Android pega todo mundo uma vez.** Você imprime um JSON de resposta,
> vê metade, e passa vinte minutos achando que a API está devolvendo dados incompletos.
>
> `debugPrint` resolve: ele quebra a saída em pedaços e limita a velocidade, para o Android não
> descartar linhas.

---

## ⚠️ Erros comuns

### 1. Copiar `analysis_options.yaml` sem entender

Você herda 200 regras, ganha 800 avisos e desliga tudo na semana seguinte.

**Correção:** comece com `flutter_lints` e acrescente o que fizer sentido.

### 2. Ignorar os `info`

Eles se acumulam até ninguém ler a saída do `analyze`.

**Correção:** `--fatal-infos` na verificação, e promova a `error` os que pegam bug.

### 3. `// ignore_for_file:` no topo de um arquivo real

```dart
// ignore_for_file: use_build_context_synchronously   // ❌
```

Cobre o problema de hoje **e** o de amanhã.

**Correção:** `// ignore:` na linha, com explicação.

### 4. `// ignore:` sem explicação

O próximo leitor (você) não sabe se foi decisão ou preguiça.

**Correção:** um comentário acima dizendo por quê.

### 5. Ignorar `use_build_context_synchronously`

Esse lint raramente está errado. Um `ignore` nele quase sempre significa que o `mounted` **não** foi
checado.

**Correção:** cheque o `mounted`.

### 6. `catch (e) {}` vazio

```dart
try {
  await salvar();
} catch (e) {}   // ❌ o erro some para sempre
```

**Correção:** trate, ou registre, ou relance.

### 7. Não usar vírgula final

O formatador junta tudo numa linha e a árvore de widgets fica ilegível.

**Correção:** `require_trailing_commas`.

### 8. Formatar e commitar junto com a mudança

O PR tem 400 linhas alteradas, 380 de reformatação.

**Correção:** formate **antes** de começar, num commit separado.

### 9. Discutir formatação em revisão de código

O formatador não tem opções justamente para isso.

**Correção:** `dart format` e siga em frente.

### 10. `print` em vez de `debugPrint`

Fica no binário de release, trunca em 1 KB no Android e não dá para filtrar.

**Correção:** `debugPrint` ou `developer.log`.

### 11. Registrar dado sensível

```dart
Log.debug('token: $token');   // ❌
```

**Correção:** nunca. Se precisar depurar, use os 4 primeiros caracteres.

### 12. Não rodar a verificação antes do commit

Você descobre o problema na CI, 20 minutos depois.

**Correção:** `tool/verificar.ps1`, ou o hook de `pre-commit`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter analyze` no `foco_lab`. Quantos problemas? Anote os níveis.

**Passo 2.** Rode `flutter analyze --fatal-infos`. Mudou o código de saída? (`echo $LASTEXITCODE`
no PowerShell.)

**Passo 3.** Ligue `strict-casts: true` no `analysis_options.yaml` e rode de novo. Quantos erros
novos? Todos são casts implícitos de `dynamic`?

**Passo 4.** Corrija dois deles com `as Tipo` e dois com validação (`is`). Qual você preferiu?

**Passo 5.** Acrescente `print('teste')` a um arquivo e rode o analyze. Qual nível? Agora promova
`avoid_print: error` e repita.

**Passo 6.** Escreva o bug da vírgula esquecida (duas strings adjacentes numa lista). O lint pegou?
Desligue-o e veja o bug passar.

**Passo 7.** Escreva uma função `async` chamada **sem** `await`, que lança exceção. Rode o app. O
erro aparece? Agora ligue `unawaited_futures: error`.

**Passo 8.** Rode `dart format --output=none --set-exit-if-changed .`. Passou? Se não, veja quais
arquivos.

**Passo 9.** Remova todas as vírgulas finais de um `build` grande, rode `dart format` e compare.

**Passo 10.** Instale o hook de `pre-commit` e tente commitar um arquivo não formatado.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

Faça os exercícios de **Configuração** do `analysis_options.yaml`, o de **Correção de bugs** que o
lint pega, e o de **Decisão** sobre promover ou não uma regra.

---

## 🏆 Desafio opcional

Escreva um **lint personalizado** que pegue uma regra específica do seu projeto.

Sugestão: uma regra que **proíbe importar `sqflite` fora de `features/*/data/`** — a regra de
dependência do [Módulo 08, aula 9](../08-estado-e-arquitetura/09-arquitetura-feature-first.md).

Requisitos:

- Usa o pacote `custom_lint` + `analyzer`.
- Reporta o arquivo, a linha e uma mensagem clara.
- Aparece no `flutter analyze` e no VS Code, como qualquer outro lint.
- Tem uma correção automática (*quick fix*) quando possível.
- Um teste verifica que ela dispara no caso errado e **não** dispara no certo.

Alternativa mais simples: um script Dart que percorre `lib/` e reporta as violações, no espírito do
desafio do Módulo 08.

Depois responda: em que momento vale escrever um lint próprio, em vez de confiar na revisão de
código? (Dica: pense em quantas vezes a mesma correção apareceu em revisões.)

---

## 📌 Resumo

- Três camadas: **compilador** (não compila), **analisador** (compila e quebra), **lint** (compila,
  funciona, má ideia).
- O analisador é **o teste mais barato que existe** — roda enquanto você digita.
- `error` e `warning` fazem o `flutter analyze` falhar; **`info` não** — e por isso se acumulam.
- Use **`--fatal-infos`** na verificação, e **promova a `error`** os lints que pegam bug.
- Os que mais pegam bug: `use_build_context_synchronously`, `unawaited_futures`,
  `cancel_subscriptions`, `close_sinks`, `no_adjacent_strings_in_list`, `avoid_dynamic_calls`.
- **`strict-casts: true`** é a chave mais valiosa: força você a ver cada tipo assumido.
- **`// ignore:` com explicação**, nunca `// ignore_for_file:` em arquivo real.
- Um `ignore` de `use_build_context_synchronously` quase sempre esconde um `mounted` esquecido.
- **`dart format` não tem opções** — deliberadamente. A única configuração é `page_width`.
- **Vírgula final** faz o formatador preservar uma linha por item. É o que torna árvores de widgets
  legíveis.
- Use **`debugPrint`** ou `developer.log`, nunca `print`: ele fica no release e trunca em **1 KB** no
  Android.
- **Nunca registre dado sensível** em log.
- A verificação antes do commit são três comandos: **format**, **analyze**, **test**.

---

## ☑️ Checklist de domínio

- [ ] Distingo erro de compilador, aviso de analisador e lint.
- [ ] Sei que `info` não faz o `analyze` falhar, e uso `--fatal-infos`.
- [ ] Promovo a `error` os lints que pegam bug.
- [ ] Sei quais lints pegam bug e quais são estilo.
- [ ] Tenho `strict-casts: true` ligado.
- [ ] Uso `// ignore:` com explicação, na linha.
- [ ] Nunca ignoro `use_build_context_synchronously`.
- [ ] Uso vírgula final em toda lista de argumentos.
- [ ] Nunca uso `print` — só `debugPrint` ou `developer.log`.
- [ ] Nunca registro token, senha ou dado pessoal em log.
- [ ] Rodo format, analyze e test antes de cada commit.
- [ ] Registro no `analysis_options.yaml` **por que** cada regra está lá.

---

## 📚 Referências oficiais

- [Customizing static analysis — dart.dev](https://dart.dev/tools/analysis)
- [Linter rules — dart.dev](https://dart.dev/tools/linter-rules)
- [flutter_lints — pub.dev](https://pub.dev/packages/flutter_lints)
- [dart format — dart.dev](https://dart.dev/tools/dart-format)
- [Effective Dart: Style — dart.dev](https://dart.dev/effective-dart/style)
- [dart analyze — dart.dev](https://dart.dev/tools/dart-analyze)
- [custom_lint — pub.dev](https://pub.dev/packages/custom_lint)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — DevTools](03-devtools.md) | [README](README.md) | [Aula 5 — Testes unitários](05-testes-unitarios.md) |
