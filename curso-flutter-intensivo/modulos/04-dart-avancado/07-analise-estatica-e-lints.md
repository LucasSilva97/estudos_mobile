# Aula 7 — Análise estática e lints

> **Módulo:** 04 - Dart Avançado · **Tempo estimado:** 30 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é **análise estática** e por que ela encontra bugs antes de rodar o programa.
- Ler e escrever um `analysis_options.yaml`.
- Diferenciar **error**, **warning** e **info**, e mudar a severidade de uma regra.
- Usar `dart analyze` e `dart format` (e saber o que `flutter analyze` acrescenta).
- Ativar regras de lint úteis do `flutter_lints ^6.0.0`.
- Usar `// ignore:` e `// ignore_for_file:` com parcimônia — e saber por quê.
- Montar uma verificação local no estilo CI antes de cada commit.

## ✅ Pré-requisitos

- [Módulo 00 — Commits, branches e .gitignore](../00-git-e-terminal/04-commits-branches-gitignore.md).
- [Aula 2 — Futures](02-futures-e-async-await.md): a regra `unawaited_futures` aparece aqui.
- [02 — Configuração do ambiente](../../02-configuracao-do-ambiente.md) com Flutter 3.47.1 e
  Dart 3.13.1 funcionando.

---

## 📖 Conceito

### O que é análise estática

**Análise estática** é o computador lendo o seu código **sem executá-lo** e apontando problemas.
Enquanto o compilador só recusa o que é impossível de traduzir, o analisador vai além e reclama do
que é **legal, mas provavelmente errado**: uma variável nunca usada, um `Future` não aguardado, um
`switch` que esqueceu um caso.

No Flutter e no Dart, quem faz isso é o **analyzer** — o mesmo motor que o VS Code usa para
sublinhar em amarelo e vermelho enquanto você digita. Ele é configurado por **um** arquivo.

### `analysis_options.yaml`

Fica na **raiz do projeto**, ao lado do `pubspec.yaml`, e tem três blocos:

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml   # 1) conjunto de regras base

analyzer:                                      # 2) comportamento do analisador
  errors:
    avoid_print: error
    todo: ignore
  exclude:
    - "**/*.g.dart"
  language:
    strict-casts: true

linter:                                        # 3) regras de estilo ligadas/desligadas
  rules:
    - prefer_final_locals
    - unawaited_futures
```

1. **`include`** puxa um conjunto pronto de regras. O padrão do curso é
   `package:flutter_lints/flutter.yaml`, que vem do pacote **`flutter_lints: ^6.0.0`** declarado em
   `dev_dependencies`. Em um projeto **Dart puro** (sem Flutter), o equivalente é
   `package:lints/recommended.yaml`.
2. **`analyzer`** ajusta o analisador: muda a severidade de diagnósticos (`errors:`), ignora
   arquivos gerados (`exclude:`) e aperta as checagens de tipo (`language:`).
3. **`linter`** liga regras de estilo além das que vieram no `include`.

### Error, warning e info

| Severidade | Significado | Impede compilar? | Exemplo |
|---|---|---|---|
| **error** | o código está errado | **sim** | tipo incompatível, `switch` não exaustivo |
| **warning** | quase certamente é bug | não | variável possivelmente nula sendo usada |
| **info** (lint) | estilo/boa prática | não | `print` em código de produção, falta de `const` |

Você pode **promover** ou **rebaixar** qualquer diagnóstico no bloco `errors:`:

```yaml
analyzer:
  errors:
    avoid_print: error      # vira erro: o build para
    unused_import: warning  # sobe de info para warning
    todo: ignore            # para de aparecer
```

A promoção é a ferramenta mais útil aqui: transforme em `error` as regras que você **não** quer
negociar com você mesmo.

### `dart analyze` e `dart format`

```powershell
dart analyze
dart analyze --fatal-infos
dart format .
dart format --output=none --set-exit-if-changed .
```

- `dart analyze` roda o analisador e devolve **código de saída diferente de zero** se houver
  problemas — é isso que permite usá-lo em automação.
- `--fatal-infos` faz até os `info` (os lints) derrubarem o comando. É o modo rigoroso.
- `dart format .` reescreve os arquivos no formato oficial (indentação, quebra de linha, vírgulas).
  Não é gosto pessoal: é o mesmo formato em todo projeto Dart do mundo.
- `dart format --output=none --set-exit-if-changed .` **não altera nada** e falha se algo estiver
  fora do formato — a forma certa de checar sem modificar.

Em projeto Flutter existe também `flutter analyze`, que é o `dart analyze` já ciente das
particularidades do SDK do Flutter. No módulo 04 (Dart puro de terminal) usamos `dart analyze`.

O formato da saída é sempre o mesmo:

```text
   info • Don't invoke 'print' in production code • bin/exemplo.dart:8:3 • avoid_print
```

Leia da direita para a esquerda: o **nome da regra**, o **arquivo:linha:coluna**, a **mensagem** e
a **severidade**. Com o nome da regra você pesquisa a explicação oficial em
[dart.dev/tools/linter-rules](https://dart.dev/tools/linter-rules).

Existe ainda `dart fix --apply`, que aplica automaticamente as correções que o analisador sabe
fazer sozinho. Rode-o com o repositório limpo, para poder revisar o `git diff` depois.

### Regras que valem a pena ligar

| Regra | O que evita |
|---|---|
| `avoid_print` | `print` esquecido em app de produção (use `debugPrint` no Flutter) |
| `prefer_const_constructors` | widget reconstruído à toa |
| `prefer_final_locals` | variável local reatribuída sem querer |
| `unawaited_futures` | `Future` disparado e esquecido ([aula 2](02-futures-e-async-await.md)) |
| `cancel_subscriptions` | `StreamSubscription` sem `cancel` ([aula 3](03-streams.md)) |
| `close_sinks` | `StreamController` sem `close` |
| `only_throw_errors` | `throw 'texto'` ([aula 1](01-exceptions.md)) |
| `avoid_dynamic_calls` | chamada em `dynamic` que explode só em produção |
| `use_super_parameters` | construtor verboso no Flutter (`{super.key}`) |
| `sort_pub_dependencies` | `pubspec.yaml` bagunçado |

### `// ignore:` e `// ignore_for_file:`

Quando uma regra está errada **naquele ponto específico**, você pode silenciá-la:

```dart
// ignore: avoid_print
print('Isto é uma ferramenta de linha de comando, print é a saída correta.');
```

O comentário vale para a **linha seguinte** (ou, se ficar no fim da linha, para aquela linha). Já
o `ignore_for_file` vale para o arquivo inteiro e costuma ficar no topo:

```dart
// ignore_for_file: avoid_print
```

**Por que usar pouco:** cada `ignore` é uma exceção que ninguém revisa depois. Um
`ignore_for_file` desliga a regra até para o código que você escrever amanhã naquele arquivo. Três
perguntas antes de escrever um:

1. Dá para **corrigir** em vez de silenciar? (quase sempre dá)
2. Se a regra não faz sentido no projeto inteiro, não seria melhor **desligá-la** no
   `analysis_options.yaml`, à vista de todos?
3. Se é só aqui, o `ignore` vem acompanhado de um comentário explicando **por quê**?

### CI local — a verificação antes do commit

**CI** (*Continuous Integration* — integração contínua) é a prática de rodar as checagens
automaticamente a cada mudança. Antes de ter um servidor fazendo isso, tenha um script:

```powershell
# verificar.ps1
dart format --output=none --set-exit-if-changed .
if ($?) { dart analyze --fatal-infos }
```

Rode-o antes de cada `git commit`. Se ele falhar, o commit não sai — e você corrige enquanto o
assunto ainda está fresco.

## 💡 Analogia

O **compilador** é o porteiro: só barra quem não tem como entrar.

O **analisador** é o revisor de texto: o texto está gramaticalmente possível, mas ele aponta a
frase confusa, a palavra repetida e o parágrafo que ficou sem conclusão. Ele não impede a
publicação; impede a vergonha.

O `// ignore:` é o bilhete "aqui foi de propósito" colado na margem. Um ou outro, tudo bem. A
página inteira coberta de bilhetes significa que ninguém mais lê as marcações.

---

## 🧪 Exemplo mínimo

Arquivo `analysis_options.yaml` mínimo de um projeto Dart de terminal:

```yaml
include: package:lints/recommended.yaml

linter:
  rules:
    - prefer_final_locals
    - unawaited_futures
```

Depois, no terminal:

```powershell
dart analyze
```

```text
Analyzing meu_projeto...
No issues found!
```

---

## 📱 Aplicando no Flutter

- **O projeto já nasce com isso.** `flutter create` gera um `analysis_options.yaml` com
  `include: package:flutter_lints/flutter.yaml` e adiciona `flutter_lints: ^6.0.0` em
  `dev_dependencies`. Você verá esse arquivo em
  [05 — Estrutura do projeto](../05-introducao-ao-flutter/02-estrutura-do-projeto.md).
- **Regras que só fazem sentido no Flutter.** `prefer_const_constructors` e
  `use_super_parameters` existem porque `const` evita reconstrução de widget e `{super.key}` é o
  formato atual de construtor — assunto de
  [12 — Análise, lint e formatação](../12-testes-e-debug/04-analise-lint-formatacao.md).
- **Qualidade contínua.** No módulo 12 você liga isso a testes e passa a rodar `flutter analyze` +
  `flutter test` antes de cada entrega
  ([12 — Testes unitários](../12-testes-e-debug/05-testes-unitarios.md)).

> 🪟 **Atenção, Windows.** Se o Flutter SDK estiver em um caminho com **acento** — por exemplo
> `C:\Users\Usuário\Documents\flutter` — o servidor de análise pode encerrar sozinho com código
> 255, e `flutter analyze` falha sem apontar nenhum problema do seu código. A correção é mover o
> SDK para um caminho sem acentos e sem espaços, como `C:\src\flutter`, conforme
> [02 — Configuração do ambiente](../../02-configuracao-do-ambiente.md) e
> [referências — erros comuns](../../referencias/erros-comuns.md).

---

## 💻 Código completo

Esta aula tem **dois** arquivos: a configuração e um programa com problemas propositais.

> **Arquivo 1:** `analysis_options.yaml` (na raiz do projeto, ao lado de `pubspec.yaml`)

```yaml
# Conjunto base de regras. Em projeto Flutter, troque por:
# include: package:flutter_lints/flutter.yaml
include: package:lints/recommended.yaml

analyzer:
  # Ajuste de severidade: o que é negociável e o que não é.
  errors:
    # Em projeto Flutter, deixe avoid_print como error e use debugPrint.
    # Aqui, em ferramenta de terminal, print é a saída legítima do programa.
    avoid_print: ignore
    unused_local_variable: error
    todo: ignore
  # Arquivos que não são escritos à mão não devem ser analisados.
  exclude:
    - "**/*.g.dart"
    - "build/**"
  language:
    # Recusa conversões implícitas silenciosas e tipos sem argumento genérico.
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    - prefer_final_locals
    - unawaited_futures
    - only_throw_errors
    - avoid_dynamic_calls
    - cancel_subscriptions
    - close_sinks
    - prefer_single_quotes
    - unnecessary_this
```

> **Arquivo 2:** `bin/aula07_lints.dart`
> **Como executar:** `dart run bin/aula07_lints.dart`
> **Como analisar:** `dart analyze` · **Como formatar:** `dart format .`

```dart
// Aula 7 — código propositalmente imperfeito, para o analisador reclamar.
// Depois de rodar `dart analyze`, corrija cada apontamento e rode de novo.
import 'dart:async';

class Sessao {
  Sessao(this.materia, this.minutos);

  final String materia;
  final int minutos;

  // unnecessary_this: o `this.` aqui não acrescenta nada.
  String get resumo => '${this.materia}: ${this.minutos} min';
}

/// prefer_final_locals: `total` muda, mas `sessoes` não deveria mudar.
int somarMinutos(List<Sessao> sessoes) {
  var total = 0;
  var lista = sessoes; // nunca é reatribuída -> deveria ser final
  for (final s in lista) {
    total += s.minutos;
  }
  return total;
}

/// only_throw_errors: lançar String impede tratar com `on`.
void validar(int minutos) {
  if (minutos < 0) {
    throw 'minutos não pode ser negativo'; // deveria ser ArgumentError
  }
}

Future<void> salvarNoServidor(Sessao sessao) async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
}

/// unawaited_futures: o Future é disparado e ninguém espera nem trata erro.
Future<void> registrar(Sessao sessao) async {
  salvarNoServidor(sessao); // falta await ou unawaited(...)
  print('registrado ${sessao.materia}');
}

/// cancel_subscriptions: a assinatura nunca é cancelada.
void escutarTiques() {
  final relogio = Stream<int>.periodic(const Duration(seconds: 1), (i) => i);
  final assinatura = relogio.listen((t) => print('tique $t'));
  // falta: await assinatura.cancel();
}

Future<void> main() async {
  final sessoes = <Sessao>[
    Sessao('Dart', 45),
    Sessao('Flutter', 90),
  ];

  print('total: ${somarMinutos(sessoes)} min');
  print(sessoes.first.resumo);

  try {
    validar(-1);
  } catch (e) {
    print('erro: $e');
  }

  await registrar(sessoes.first);
}
```

Rodando `dart analyze`, a saída tem este formato (a redação exata da mensagem pode mudar entre
versões do SDK):

```text
Analyzing meu_projeto...

   info • Unnecessary 'this.' qualifier • bin/aula07_lints.dart:11:23 • unnecessary_this
   info • Local variables should be final • bin/aula07_lints.dart:18:3 • prefer_final_locals
   info • Don't throw instances of classes that aren't a subclass of 'Error'
        • bin/aula07_lints.dart:26:5 • only_throw_errors
   info • Missing an 'await' for the 'Future' computed by this expression
        • bin/aula07_lints.dart:37:3 • unawaited_futures
   info • Cancel instances of 'StreamSubscription'
        • bin/aula07_lints.dart:44:9 • cancel_subscriptions

5 issues found.
```

### Versão corrigida dos trechos

```dart
// 1. unnecessary_this
String get resumo => '$materia: $minutos min';

// 2. prefer_final_locals
final lista = sessoes;

// 3. only_throw_errors
if (minutos < 0) {
  throw ArgumentError.value(minutos, 'minutos', 'Não pode ser negativo');
}

// 4. unawaited_futures — escolha uma das duas intenções:
await salvarNoServidor(sessao);          // eu preciso do resultado
unawaited(salvarNoServidor(sessao));     // eu escolhi não esperar

// 5. cancel_subscriptions
final assinatura = relogio.listen((t) => print('tique $t'));
await Future<void>.delayed(const Duration(seconds: 3));
await assinatura.cancel();
```

Depois das correções, `dart analyze` deve imprimir:

```text
Analyzing meu_projeto...
No issues found!
```

---

## 🔍 Explicando a configuração

**`include: package:lints/recommended.yaml`**
Importa um conjunto de regras mantido pelo time do Dart. Tudo que vem depois no arquivo **sobrepõe**
o que veio do `include`. Em projeto Flutter, a linha equivalente é
`include: package:flutter_lints/flutter.yaml`, e o pacote `flutter_lints: ^6.0.0` precisa estar em
`dev_dependencies` do `pubspec.yaml`.

**`errors: avoid_print: ignore`**
Aqui estamos em uma ferramenta de terminal: `print` **é** a interface do programa. Desligar a regra
no arquivo de configuração é honesto e visível — melhor que espalhar `// ignore: avoid_print` em
vinte linhas. Em um app Flutter, a decisão se inverte: `avoid_print: error`.

**`unused_local_variable: error`**
Variável declarada e não usada quase sempre significa "escrevi e esqueci de usar" — um bug de
verdade. Promover para `error` faz o comando falhar.

**`exclude:`**
Arquivos gerados por ferramenta não são escritos por você; analisá-los só produz ruído. O padrão
`**/*.g.dart` cobre qualquer pasta.

**`language: strict-casts: true`**
Sem isso, o Dart aceita em silêncio que um `dynamic` seja usado onde se espera `String`, e o erro
só aparece em tempo de execução. Com `strict-casts`, a conversão precisa ser escrita à mão — e você
enxerga onde o tipo se perdeu.

**`strict-raw-types: true`**
Reclama de `List` sem `<...>`. Um `List` cru vira `List<dynamic>` e desliga a checagem de tipos dos
elementos.

**`linter: rules:`**
Cada item é o nome exato de uma regra. Para descobrir o que uma delas faz, procure o nome em
[dart.dev/tools/linter-rules](https://dart.dev/tools/linter-rules) — a lista oficial traz exemplo
de código bom e ruim para cada uma.

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | `analysis_options.yaml` fora da raiz | As regras "não funcionam" | Ao lado do `pubspec.yaml` |
| 2 | Indentação errada no YAML | `Invalid analysis options` | YAML usa **espaços**, nunca tabulação |
| 3 | Nome de regra escrito errado | A regra é ignorada em silêncio | Confira na lista oficial de lints |
| 4 | `flutter_lints` fora de `dev_dependencies` | Pacote de desenvolvimento vai para o app | `flutter pub add dev:flutter_lints` |
| 5 | `ignore_for_file` no topo "para resolver rápido" | O arquivo inteiro deixa de ser verificado | Corrija, ou desligue a regra no YAML |
| 6 | Rodar `dart format` só na véspera da entrega | Diff gigante que esconde a mudança real | Formate a cada commit |
| 7 | Confundir `warning` com `error` | Esperar que o build falhe e ele não falha | Promova no bloco `errors:` |
| 8 | Ignorar o analisador porque "o app roda" | Bug de `Future` sem `await` em produção | Deixe `dart analyze` limpo |

---

## 🛠️ Exercício guiado

**Passo 1.** Na raiz do seu projeto Dart, crie `analysis_options.yaml` com o conteúdo do
**Arquivo 1** acima.

**Passo 2.** Crie `bin/aula07_lints.dart` com o conteúdo do **Arquivo 2**.

**Passo 3.** Rode e anote **quantos** problemas apareceram:

```powershell
dart analyze
```

**Passo 4.** Corrija **um** problema por vez, rodando `dart analyze` depois de cada correção.
Observe o contador diminuindo — é o ciclo de trabalho real com o analisador.

**Passo 5.** Desformate o arquivo de propósito (junte tudo em poucas linhas, tire espaços) e rode:

```powershell
dart format --output=none --set-exit-if-changed .
```

O comando deve falhar. Depois rode `dart format .` e repita: agora passa.

**Passo 6.** Crie `verificar.ps1` na raiz com as duas checagens e rode-o. Acrescente uma regra nova
ao `linter: rules:` (por exemplo `always_declare_return_types`) e veja o que aparece.

**Resultado esperado:** `dart analyze` termina com `No issues found!` e `verificar.ps1` roda sem
falhar. Anote em um comentário do YAML por que você deixou `avoid_print` desligado neste projeto.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/04-dart-avancado.md](../../exercicios/04-dart-avancado.md)

Foque nos exercícios de **Correção de bugs**: quase todos são apontados pelo analisador.

---

## 🏆 Desafio opcional

Monte um `analysis_options.yaml` "rigoroso" para o seu próximo projeto Flutter, com
`include: package:flutter_lints/flutter.yaml` mais:

- `avoid_print: error`;
- `strict-casts`, `strict-inference` e `strict-raw-types` ligados;
- as regras `prefer_const_constructors`, `unawaited_futures`, `cancel_subscriptions`,
  `close_sinks`, `avoid_dynamic_calls` e `use_super_parameters`.

Depois escreva `verificar.ps1` com três etapas (formatar-checando, analisar com `--fatal-infos` e,
quando houver testes, rodá-los) e explique em comentário por que a ordem importa.

---

## 📌 Resumo

- Análise estática encontra bugs **sem rodar** o programa; o arquivo de controle é o
  `analysis_options.yaml`, na raiz do projeto.
- O arquivo tem três blocos: `include` (conjunto base), `analyzer` (severidades, exclusões,
  rigor de tipos) e `linter` (regras de estilo).
- O curso usa `flutter_lints: ^6.0.0` em projetos Flutter; em Dart puro, `package:lints`.
- Severidades: **error** (não compila), **warning** (quase certamente bug) e **info** (lint).
  Promova no bloco `errors:` o que você não quer negociar.
- `dart analyze` (com `--fatal-infos` para o modo rigoroso) e
  `dart format --output=none --set-exit-if-changed .` são a dupla da verificação local.
- `// ignore:` vale para a linha seguinte; `ignore_for_file` vale para o arquivo inteiro — use
  pouco, e sempre com justificativa escrita.
- Um script `verificar.ps1` antes do commit substitui, por enquanto, um servidor de CI.

---

## ☑️ Checklist de domínio

- [ ] Escrevo um `analysis_options.yaml` do zero com os três blocos.
- [ ] Explico a diferença entre error, warning e info.
- [ ] Promovo uma regra para `error` e comprovo que o comando falha.
- [ ] Rodo `dart analyze` e leio a linha de saída identificando a regra.
- [ ] Uso `dart format --output=none --set-exit-if-changed .` para checar sem alterar.
- [ ] Justifico por escrito qualquer `// ignore:` que eu escrever.
- [ ] Tenho um `verificar.ps1` que roda antes dos meus commits.
- [ ] Deixei `bin/aula07_lints.dart` com `No issues found!`.

---

## 📚 Referências oficiais

- [Customizing static analysis — dart.dev](https://dart.dev/tools/analysis)
- [Linter rules — dart.dev](https://dart.dev/tools/linter-rules)
- [dart analyze — dart.dev](https://dart.dev/tools/dart-analyze)
- [dart format — dart.dev](https://dart.dev/tools/dart-format)
- [dart fix — dart.dev](https://dart.dev/tools/dart-fix)
- [flutter_lints — pub.dev](https://pub.dev/packages/flutter_lints)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Sealed classes](06-sealed-classes.md) | [README](README.md) | [Aula 8 — Isolates e desempenho](08-isolates-e-desempenho.md) |
