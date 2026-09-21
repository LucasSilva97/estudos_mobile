# Aula 2 — Sintaxe, convenções e comentários

> **Módulo:** 02 - Dart Básico · **Tempo estimado:** 30 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Aplicar as regras de sintaxe obrigatórias do Dart: ponto e vírgula, chaves e blocos.
- Nomear variáveis, funções, classes e arquivos segundo o guia de estilo oficial.
- Escrever os três tipos de comentário (`//`, `/* */`, `///`) e saber quando usar cada um.
- Gerar documentação HTML do seu código com `dart doc`.
- Formatar o código automaticamente com `dart format` e parar de discutir espaçamento.
- Reconhecer e corrigir avisos de `dart analyze`.

## ✅ Pré-requisitos

- Projeto `dart_basico` criado e rodando — [Aula 1](01-anatomia-de-um-programa.md).
- VS Code com a extensão Dart instalada.

## 📖 Conceito

Dart tem uma sintaxe da família **C** — a mesma "cara" de Java, C#, JavaScript e Kotlin. Se você
já viu Java, quase tudo aqui vai parecer familiar. Se veio do Python, a diferença mais visível é
que **indentação não significa nada** para o compilador: quem delimita blocos são as chaves.

### Regra 1 — ponto e vírgula termina toda instrução

```dart
int minutos = 45;
print(minutos);
```

> **Instrução** (*statement*) — uma ordem completa dada ao programa.
> **Expressão** (*expression*) — um pedaço de código que **produz um valor**, como `2 + 3` ou
> `minutos > 30`. Uma expressão vira instrução quando você põe `;` no fim.

Não levam ponto e vírgula: o fim de um bloco `{ }` de função, de `if`, de `for` e de `class`.

```dart
void resumir() {
  print('ok');
}          // ← sem ponto e vírgula aqui
```

### Regra 2 — chaves delimitam blocos

```dart
if (minutos > 30) {
  print('Sessão longa');
} else {
  print('Sessão curta');
}
```

O Dart **aceita** omitir as chaves quando o bloco tem uma instrução só:

```dart
if (minutos > 30) print('Sessão longa');   // válido, porém desaconselhado
```

O guia de estilo oficial pede que você **sempre use chaves** em `if`, com uma única exceção:
um `if` sem `else` que cabe inteiro em uma linha. A razão é histórica e prática — sem chaves,
acrescentar uma segunda linha depois cria um bug silencioso, porque só a primeira continua
dentro do `if`.

### Regra 3 — os três padrões de nome

| Padrão | Como se escreve | Onde se usa |
|---|---|---|
| `lowerCamelCase` | `minutosEstudados`, `calcularTotal` | variáveis, parâmetros, funções, métodos, constantes |
| `UpperCamelCase` | `SessaoDeEstudo`, `Materia`, `ThemeData` | classes, enums, *typedefs*, *extensions* |
| `snake_case` | `calculadora_estudo.dart`, `dart_basico` | nomes de **arquivo**, de **pasta** e de **pacote** |

> **Enum** — um tipo com um conjunto fixo de valores possíveis (ex.: segunda, terça, quarta).
> Detalhado em [03 — Enums](../03-dart-intermediario/07-enums.md).
> **Typedef** — um apelido para um tipo. Aparece na [Aula 7](07-funcoes-em-dart.md).

Regras adicionais que os *lints* cobram:

- Um sublinhado no início (`_total`) significa **privado ao arquivo**. Não é estilo, é
  semântica — o compilador leva a sério. Detalhado em
  [03 — Encapsulamento](../03-dart-intermediario/03-encapsulamento.md).
- Constantes usam `lowerCamelCase` também. Dart **não** usa `MAIUSCULA_COM_SUBLINHADO` como
  Java: escreva `const taxaPadrao = 0.1`, não `const TAXA_PADRAO`.
- Siglas de duas letras ficam maiúsculas em classes (`IOSink`), mas siglas maiores viram
  camel (`HttpRequest`, não `HTTPRequest`).

### Regra 4 — os três tipos de comentário

```dart
// Comentário de uma linha. É o mais usado.

/*
  Comentário de bloco. Serve para trechos longos
  ou para desativar código temporariamente.
*/

/// Comentário de documentação. Vira documentação de verdade.
/// Descreve o que vem logo abaixo dele.
int dobro(int valor) => valor * 2;
```

A diferença entre `//` e `///` não é cosmética:

- `//` é uma nota **para quem lê o código-fonte**.
- `///` é **dartdoc**: o Dart entende esse texto como a documentação oficial daquele elemento.
  Ele aparece no balão de ajuda do VS Code quando você passa o mouse sobre o nome, e vira
  página HTML quando você roda `dart doc`.

> **dartdoc** — o gerador de documentação do Dart. Lê os comentários `///` e produz um site
> HTML navegável. É o mesmo mecanismo que gera a documentação de todos os pacotes do pub.dev.

Boas práticas de `///` que o guia oficial pede:

1. Comece com uma **frase única e curta**, terminada em ponto.
2. Deixe uma linha em branco entre o resumo e o resto.
3. Use `[nome]` entre colchetes para criar um link para outro elemento do código.
4. Descreva **o que** a função faz e o que ela devolve, não como ela está implementada.

```dart
/// Converte [minutos] em um texto no formato `2h15`.
///
/// Quando [minutos] é menor que 60, devolve apenas os minutos, como `45min`.
/// Lança [ArgumentError] se [minutos] for negativo.
String formatarDuracao(int minutos) {
  // ...
}
```

### Regra 5 — deixe a máquina formatar

O Dart tem um formatador oficial. Ele decide indentação, quebra de linha, espaço em volta de
operadores e vírgula final. Não há configuração de "estilo pessoal", e isso é de propósito:
todo código Dart do mundo fica parecido.

```powershell
dart format .
```

```text
Formatted bin/estilo.dart
Formatted 3 files (1 changed) in 0.31 seconds.
```

No VS Code, ative **Format on Save** (Arquivo → Preferências → Configurações → pesquise
`format on save`) e o arquivo se ajeita a cada `Ctrl+S`.

Um truque útil: a **vírgula final** (*trailing comma*). Se você deixa uma vírgula depois do
último argumento, o formatador coloca cada argumento em sua própria linha:

```dart
// Com vírgula final → uma linha por argumento
print(
  formatarDuracao(
    135,
  ),
);
```

Isso vai ser importantíssimo no Flutter, onde os construtores de *widget* têm muitos argumentos.

### Regra 6 — `dart analyze` é seu revisor

```powershell
dart analyze
```

```text
Analyzing dart_basico...
   info • Unused import: 'dart:math' • bin/estilo.dart:2:8 • unused_import
1 issue found.
```

Três níveis de gravidade: `error` (não compila), `warning` (compila, mas quase certamente é bug)
e `info` (estilo). **Trate `info` como se fosse erro.** É assim que você aprende o idioma.

Muitos avisos têm correção automática:

```powershell
dart fix --dry-run   # mostra o que seria mudado
dart fix --apply     # aplica
```

## 💡 Analogia

Sintaxe é **ortografia**; convenção de estilo é **redação**.

Escrever `int minutos = 45` sem o ponto e vírgula é um erro de ortografia: o texto não é lido.
Escrever `int Minutos_Estudados = 45;` funciona, mas é como escrever um e-mail profissional
todo em CAIXA ALTA com abreviações de mensagem de celular: comunica, porém desqualifica e faz
qualquer pessoa perder tempo para entender. `dart format` é o corretor automático; `dart analyze`
é o revisor que lê antes de publicar.

## 🧪 Exemplo mínimo

```dart
/// Devolve o total de minutos de duas sessões de estudo.
int somarSessoes(int primeira, int segunda) {
  return primeira + segunda;
}

void main() {
  // Nomes em lowerCamelCase.
  final int totalMinutos = somarSessoes(45, 30);
  print('Total: $totalMinutos minutos');
}
```

```text
Total: 75 minutos
```

Passe o mouse sobre `somarSessoes` no VS Code: o texto do `///` aparece no balão.

## 📱 Aplicando no Flutter

Nada do que você viu aqui muda no Flutter — e é justamente por isso que esta aula existe cedo.

- **Nomes de arquivo em `snake_case`** é o que você vai ver em todo o projeto final:
  `materia_form_screen.dart`, `sessao_controller.dart`. Nunca `MateriaFormScreen.dart`.
- **Classes em `UpperCamelCase`** é a regra de todo *widget*: `Scaffold`, `AppBar`, `ListView`,
  e os seus próprios, como `MateriaTile`.
- **Vírgula final** deixa de ser detalhe e vira necessidade. Um *widget* Flutter típico tem
  vários argumentos nomeados aninhados; sem vírgula final, o formatador comprime tudo em uma
  linha ilegível. Você vai ver isso na prática em
  [06 — Row, Column e Expanded](../06-widgets-e-layouts/04-row-column-expanded.md).
- **`analysis_options.yaml`** muda de `package:lints` para `package:flutter_lints` e passa a
  cobrar regras específicas de UI — entre elas a que proíbe `print` e manda usar `debugPrint`.
  O tema completo é [12 — Análise, lint e formatação](../12-testes-e-debug/04-analise-lint-formatacao.md).
- **`///`** é como você vai documentar as classes do domínio do app **Foco** (`Materia`,
  `Sessao`, `Meta`) para lembrar em dezembro o que você escreveu em setembro.

## 💻 Código completo

> **Arquivo:** `dart_basico/bin/estilo.dart`
> **Como executar:** `dart run bin/estilo.dart`

```dart
// bin/estilo.dart
// Demonstra: convenções de nome, os três tipos de comentário e dartdoc.

/// Quantidade de minutos que compõem uma hora.
///
/// Constante nomeada em lowerCamelCase — Dart não usa MAIUSCULA_COM_SUBLINHADO.
const int minutosPorHora = 60;

/// Uma sessão de estudo registrada pela pessoa que estuda.
///
/// Classes usam UpperCamelCase. Esta é uma versão bem simples;
/// classes são o assunto do módulo 03.
class SessaoDeEstudo {
  /// Cria uma sessão com o nome da [materia] e a duração em [minutos].
  SessaoDeEstudo(this.materia, this.minutos);

  /// Nome da matéria estudada, por exemplo `Dart`.
  final String materia;

  /// Duração da sessão, em minutos. Nunca negativa.
  final int minutos;
}

/// Converte [minutos] em um texto legível.
///
/// Devolve `2h15` quando há horas completas e `45min` quando não há.
/// Lança [ArgumentError] se [minutos] for negativo.
String formatarDuracao(int minutos) {
  if (minutos < 0) {
    throw ArgumentError.value(minutos, 'minutos', 'Não pode ser negativo');
  }

  final int horas = minutos ~/ minutosPorHora; // ~/ é divisão inteira
  final int resto = minutos % minutosPorHora; // % é o resto da divisão

  if (horas == 0) {
    return '${resto}min';
  }
  if (resto == 0) {
    return '${horas}h';
  }
  // padLeft garante 05 em vez de 5, para ficar 2h05.
  return '${horas}h${resto.toString().padLeft(2, '0')}';
}

/// Monta uma linha de relatório para uma [sessao].
String descrever(SessaoDeEstudo sessao) {
  final String duracao = formatarDuracao(sessao.minutos);
  return '${sessao.materia.padRight(12)} $duracao';
}

void main() {
  /*
    Comentário de bloco: útil para uma explicação longa ou para
    desativar um trecho durante a depuração. Evite abusar dele —
    código comentado que fica no arquivo confunde quem lê depois.
  */

  final List<SessaoDeEstudo> sessoes = <SessaoDeEstudo>[
    SessaoDeEstudo('Dart', 135),
    SessaoDeEstudo('Flutter', 45),
    SessaoDeEstudo('Git', 60),
    SessaoDeEstudo('Inglês', 20),
  ];

  print('=== Relatório de estudo ===');

  // Soma acumulada dos minutos de todas as sessões.
  int total = 0;
  for (final SessaoDeEstudo sessao in sessoes) {
    print(descrever(sessao));
    total += sessao.minutos;
  }

  print('-' * 20); // repete o traço 20 vezes
  print('${'TOTAL'.padRight(12)} ${formatarDuracao(total)}');

  // Demonstração do erro tratado: duração negativa não é aceita.
  try {
    formatarDuracao(-10);
  } on ArgumentError catch (erro) {
    print('');
    print('Erro capturado como esperado: $erro');
  }
}
```

Saída esperada:

```text
=== Relatório de estudo ===
Dart         2h15
Flutter      45min
Git          1h
Inglês       20min
--------------------
TOTAL        4h20

Erro capturado como esperado: Invalid value: Não pode ser negativo: -10
```

## 🔍 Explicando o código

**`const int minutosPorHora = 60;`**
Constante de arquivo, em `lowerCamelCase`. Se você escrevesse `MINUTOS_POR_HORA`, o lint
`constant_identifier_names` reclamaria. `const` é detalhado na [Aula 3](03-var-final-const.md).

**`class SessaoDeEstudo { ... }`**
Classe em `UpperCamelCase`. `SessaoDeEstudo(this.materia, this.minutos);` é um construtor com
**parâmetros de inicialização** — a forma curta de dizer "receba dois valores e guarde-os nos
campos de mesmo nome". Construtores são o tema de
[03 — Construtores](../03-dart-intermediario/02-construtores.md).

**`~/` e `%`**
`~/` é a **divisão inteira**: `135 ~/ 60` resulta `2` (descarta a parte fracionária).
`/` sozinho sempre devolve `double`: `135 / 60` daria `2.25`.
`%` é o **resto**: `135 % 60` resulta `15`.

**`throw ArgumentError.value(...)`**
Interrompe a função e sinaliza uso incorreto. `ArgumentError` é a exceção padrão do Dart para
"você me passou um argumento inválido". Exceções são o tema de
[04 — Exceptions](../04-dart-avancado/01-exceptions.md); aqui interessa que o `///` da função
**documenta** esse comportamento com `Lança [ArgumentError]`.

**`resto.toString().padLeft(2, '0')`**
`toString()` transforma o número em texto; `padLeft(2, '0')` completa à esquerda com zeros até
ter 2 caracteres. Assim `5` vira `05` e `2h5` vira `2h05`.

**`sessao.materia.padRight(12)`**
Completa à direita com espaços até 12 caracteres, alinhando a coluna do relatório.

**`'-' * 20`**
Em Dart, `String * int` repete o texto. Produz vinte traços.

**`for (final SessaoDeEstudo sessao in sessoes)`**
Laço `for-in`: percorre cada elemento sem você controlar índice. `final` dentro do laço
significa que `sessao` não é reatribuída dentro daquela iteração. Detalhado na
[Aula 6](06-controle-de-fluxo.md).

**`try { ... } on ArgumentError catch (erro) { ... }`**
Executa o bloco e, se surgir um `ArgumentError`, desvia para o `catch` em vez de derrubar o
programa. Usado aqui só para provar que a validação funciona.

### Gerando a documentação

Ainda dentro de `dart_basico`:

```powershell
dart doc .
```

```text
Documenting dart_basico...
Success! Docs generated into C:\src\dart_basico\doc\api
```

Abra `doc\api\index.html` no navegador: os textos que você escreveu com `///` viraram páginas.

> ⚠️ Acrescente `doc/api/` ao `.gitignore`. Documentação gerada não se versiona — se regenera.

### Formatando e analisando

```powershell
dart format .
dart analyze
```

Para conferir se está formatado **sem alterar nada** (útil em automações):

```powershell
dart format --output=none --set-exit-if-changed .
```

Esse comando não escreve nos arquivos; ele apenas termina com código de erro se algum arquivo
estiver fora do padrão.

## ⚠️ Erros comuns

**1. Traduzir a convenção de outra linguagem**
Quem vem de Python escreve `minutos_estudados`; quem vem de Java escreve `MINUTOS_POR_HORA`.
Em Dart, os dois disparam lint. A regra é `lowerCamelCase` para tudo que não é classe.

**2. Nome de arquivo em camelCase**

```text
info • Name source files using `lowercase_with_underscores` • file_names
```

`minhaCalculadora.dart` está errado; use `minha_calculadora.dart`.

**3. Usar `///` para explicar como o código funciona por dentro**
`///` é a documentação pública: descreve **o contrato** (o que entra, o que sai, o que lança).
Explicação de implementação vai em `//` dentro do corpo.

**4. Confiar na indentação como delimitador**

```dart
if (minutos > 30)
  print('longa');
  print('isto SEMPRE executa');   // ← não está dentro do if!
```

Sem chaves, apenas a primeira instrução pertence ao `if`. É um bug clássico e silencioso.

**5. Formatar à mão e brigar com o formatador**
Se `dart format` desfaz o seu alinhamento manual, o formatador está certo. Aceite e siga.

**6. Ignorar avisos `info`**
Eles se acumulam. Depois de 200 avisos, você para de ler a lista e um `warning` de verdade
passa despercebido. Mantenha `dart analyze` com **zero** resultados.

**7. Esperar que `dart format` conserte código quebrado**
O formatador precisa de código sintaticamente válido. Se houver erro de sintaxe, ele recusa:

```text
Could not format because the source could not be parsed.
```

## 🛠️ Exercício guiado

**Passo 1.** Crie `bin/estilo.dart` e digite o código completo desta aula.

**Passo 2.** Rode e confira a saída:

```powershell
dart run bin/estilo.dart
```

**Passo 3 — quebre a formatação de propósito.** Apague a indentação de umas cinco linhas,
junte duas instruções em uma linha só e salve. Depois rode:

```powershell
dart format bin/estilo.dart
```

Observe o arquivo voltar ao padrão sozinho.

**Passo 4 — provoque um aviso.** Acrescente no topo do arquivo:

```dart
import 'dart:math';
```

Sem usar nada de `dart:math`. Rode `dart analyze` e leia:

```text
info • Unused import: 'dart:math' • bin/estilo.dart:3:8 • unused_import
```

**Passo 5 — corrija automaticamente:**

```powershell
dart fix --dry-run
dart fix --apply
dart analyze
```

O resultado final deve ser `No issues found!`.

**Passo 6 — renomeie errado de propósito.** Crie um arquivo chamado `MeuTeste.dart` em `bin/`
com um `main` vazio válido. Rode `dart analyze` e veja o aviso de `file_names`. Depois renomeie
para `meu_teste.dart` e confirme que o aviso sumiu. Apague o arquivo ao final.

**Passo 7 — documente.** Escreva um `///` para a função `descrever` do seu arquivo, com resumo
em uma frase, linha em branco e um segundo parágrafo. Rode `dart doc .` e abra
`doc/api/index.html`.

**Passo 8.** Ative **Format on Save** no VS Code e acrescente `doc/` ao `.gitignore`.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md)

Faça agora os de **Fixação** e **Correção de bugs** que envolvem nomes e formatação.

## 🏆 Desafio opcional

Pegue o trecho abaixo, propositalmente feio e fora das convenções, e reescreva em
`bin/limpo.dart` deixando-o correto de estilo, documentado com `///` e com `dart analyze`
devolvendo zero resultados:

```dart
class sessao_estudo{String Materia;int MINUTOS;sessao_estudo(this.Materia,this.MINUTOS);}
int Calcular_Total(List<sessao_estudo> L){int T=0;for(var i=0;i<L.length;i++){T=T+L[i].MINUTOS;}return T;}
void main(){var L=[sessao_estudo("dart",30),sessao_estudo("flutter",50)];print(Calcular_Total(L));}
```

Sua versão precisa: usar `UpperCamelCase` na classe, `lowerCamelCase` no resto, `final` nos
campos, `for-in` no laço, aspas simples, chaves em todos os blocos e um `///` em cada elemento
público. Rode `dart format` e `dart analyze` no final.

## 📌 Resumo

- Toda instrução termina com `;`; blocos são delimitados por `{ }`, nunca por indentação.
- Use chaves sempre em `if`, `for` e `while`, mesmo com uma linha.
- `lowerCamelCase` para variáveis, funções e constantes; `UpperCamelCase` para classes;
  `snake_case` para arquivos, pastas e pacotes.
- `//` comenta para quem lê o fonte; `/* */` comenta blocos; `///` é documentação (dartdoc).
- Documentação começa com uma frase curta, tem linha em branco depois e usa `[colchetes]`
  para referenciar outros elementos.
- `dart format .` padroniza; a vírgula final controla a quebra de linha.
- `dart analyze` aponta problemas e `dart fix --apply` corrige boa parte deles.
- `dart doc .` gera o site de documentação em `doc/api`.

## ☑️ Checklist de domínio

- [x] Escrevo um `if` com chaves sem pensar.
- [x] Sei dizer qual padrão de nome usar para uma classe, uma variável e um arquivo.
- [x] Sei a diferença prática entre `//` e `///`.
- [x] Escrevi pelo menos uma função documentada com `///` e vi o balão no VS Code.
- [x] Rodei `dart doc .` e abri o HTML gerado.
- [x] `dart format .` não altera mais nada no meu projeto.
- [x] `dart analyze` devolve `No issues found!`.
- [x] Ativei Format on Save no VS Code.

## 📚 Referências oficiais

- [Dart — Effective Dart: Style](https://dart.dev/effective-dart/style)
- [Dart — Effective Dart: Documentation](https://dart.dev/effective-dart/documentation)
- [Dart — Code formatting](https://dart.dev/tools/dart-format)
- [Dart — The `dart doc` command](https://dart.dev/tools/dart-doc)
- [Dart — The `dart analyze` command](https://dart.dev/tools/dart-analyze)
- [Dart — The `dart fix` command](https://dart.dev/tools/dart-fix)
- [Dart — Linter rules](https://dart.dev/tools/linter-rules)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Anatomia de um programa](01-anatomia-de-um-programa.md) | [README](README.md) | [`var`, `final`, `const` e `late`](03-var-final-const.md) |
