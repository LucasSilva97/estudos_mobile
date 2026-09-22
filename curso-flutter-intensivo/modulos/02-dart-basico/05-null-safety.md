# Aula 5 — Null safety

> **Módulo:** 02 - Dart Básico · **Tempo estimado:** 50 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Explicar o que é `null` e por que ele causou tantos bugs na história da programação.
- Distinguir um tipo **não anulável** (`String`) de um tipo **anulável** (`String?`).
- Usar com segurança os operadores `?.`, `??`, `??=`, `...?` e `?[]`.
- Entender exatamente o que o operador `!` faz — e por que ele é perigoso.
- Reconhecer, reproduzir e corrigir o erro `Null check operator used on a null value`.
- Aproveitar a **promoção de tipo** para não precisar de `!`.
- Escolher entre `T?`, `late` e valor padrão em cada situação.

## ✅ Pré-requisitos

- [Aula 3](03-var-final-const.md) (`late`) e [Aula 4](04-tipos-strings-conversoes.md) (`tryParse`).
- Saber ler uma mensagem de erro — [Módulo 01, Aula 10](../01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md).

## 📖 Conceito

### O que é `null`

`null` é um valor especial que significa **"aqui não há valor"**. Não é zero, não é texto vazio,
não é `false`: é a ausência.

O problema clássico: se uma variável pode ser `null` e você tenta usá-la como se não fosse,
o programa quebra.

```dart
String? nome;          // ainda não recebeu nada → null
print(nome.length);    // e agora? null não tem length
```

Em linguagens sem *null safety* (Java, C#, JavaScript, Python...), esse código **compila** e só
explode quando roda, muitas vezes na mão do usuário. O criador do `null`, Tony Hoare, chamou a
invenção de "meu erro de um bilhão de dólares".

### O que o Dart faz de diferente

Desde o Dart 2.12, a linguagem tem *null safety* **sólida** (*sound null safety*). A regra é:

> **Por padrão, nenhuma variável pode ser `null`.** Se você quiser permitir `null`, precisa
> dizer isso no tipo, escrevendo `?` no final.

```dart
String nome = 'Lucas';   // NUNCA pode ser null
String? apelido;         // PODE ser null (e começa como null)
```

E o compilador passa a impedir o uso descuidado:

```dart
String? apelido;
print(apelido.length);
```

```text
Error: Property 'length' cannot be accessed on 'String?' because it is potentially null.
```

Isso é um erro de **compilação**, não de execução. Você descobre enquanto escreve, com o app
ainda no seu computador, e não em uma avaliação 1 estrela na loja.

> **Sound null safety** — "sólida" significa que a garantia é matemática: se o tipo diz
> `String`, o compilador prova que nunca haverá `null` ali, e por isso pode até gerar código
> mais rápido, sem verificações desnecessárias.

### `T` e `T?` são tipos diferentes

```dart
String nome = 'Lucas';
String? talvez = nome;    // OK: um String cabe em String?
// String obrigatorio = talvez;  // ERRO: um String? não cabe em String
```

A conversão de `T?` para `T` exige que você **prove** que não é nulo. Existem quatro maneiras
honestas de provar, e uma desonesta.

### 1. `?.` — acesso seguro

```dart
String? apelido;
print(apelido?.length);       // null (não quebra)
print(apelido?.toUpperCase()); // null
```

`?.` significa: "se o objeto à esquerda for `null`, pare aqui e devolva `null`; senão, siga".
O resultado de `apelido?.length` é `int?`, não `int`.

Existem parentes:

```dart
lista?[0]           // acesso seguro por índice
objeto?..metodo()   // cascata segura
<int>[...?talvezLista]   // spread seguro: ignora se for null
```

### 2. `??` — valor padrão

```dart
String? apelido;
final String exibicao = apelido ?? 'sem apelido';
print(exibicao);    // sem apelido
```

`a ?? b` devolve `a` se `a` não for `null`; senão devolve `b`. O resultado já é **não anulável**,
o que resolve o problema de vez.

Combinação muito usada:

```dart
final int minutos = int.tryParse(entrada) ?? 0;
```

### 3. `??=` — atribua só se estiver nulo

```dart
String? tema;
tema ??= 'claro';    // atribui, porque estava null
tema ??= 'escuro';   // NÃO atribui, já tem valor
print(tema);         // claro
```

### 4. Promoção de tipo — a forma mais elegante

Quando você **verifica** que algo não é nulo, o Dart passa a tratar aquela variável como não
anulável dentro do bloco. Isso se chama **promoção de tipo** (*type promotion*).

```dart
String? apelido = 'Lu';

if (apelido != null) {
  // Aqui dentro, apelido é String (não String?).
  print(apelido.length);      // sem ?. e sem !
  print(apelido.toUpperCase());
}
```

A promoção também funciona com saída antecipada:

```dart
void saudar(String? nome) {
  if (nome == null) return;
  print('Olá, ${nome.toUpperCase()}');   // promovido daqui em diante
}
```

Condições que quebram a promoção:

- Reatribuir a variável dentro do bloco.
- A variável ser um campo **público** ou **não-final** de uma classe (o compilador não consegue
  provar que outra parte do código não mudou o valor entre a checagem e o uso). Desde o Dart 3.2,
  campos **privados e `final`** são promovidos normalmente.

Quando a promoção não funciona, a saída é copiar para uma variável local:

```dart
final apelidoLocal = objeto.apelido;   // cópia local
if (apelidoLocal != null) {
  print(apelidoLocal.length);          // agora promove
}
```

### 5. `!` — a forma desonesta (bang operator)

```dart
String? apelido;
print(apelido!.length);
```

`!` diz ao compilador: **"confie em mim, aqui não é nulo"**. O compilador para de reclamar. Se
você estiver errado, o programa lança em tempo de execução:

```text
Unhandled exception:
Null check operator used on a null value
```

Essa é, disparado, a exceção mais comum em apps Flutter escritos por quem está começando. Ela
acontece porque `!` **não verifica nada** — ele apenas desliga a proteção.

> **Regra do curso:** trate `!` como o último recurso. Antes de escrever `!`, tente, nesta ordem:
> promoção de tipo (`if (x != null)`), `??` com valor padrão, `?.`. Se ainda assim você usar `!`,
> escreva um comentário explicando por que é seguro.

### `late` × `T?` — quando usar qual

| Pergunta | Resposta | Use |
|---|---|---|
| O valor pode legitimamente não existir? | Sim | `T?` e trate o `null` |
| O valor sempre existirá, mas só é conhecido depois da construção? | Sim | `late T` |
| Existe um padrão sensato para quando faltar? | Sim | `T` com `??` na origem |

Exemplo do app **Foco**: `Materia.cor` sempre tem valor → `Color cor`.
`Sessao.observacao` pode não ter → `String? observacao`.
Um controlador criado em `initState` → `late final TextEditingController controlador`.

### Parâmetros e null safety

```dart
// Parâmetro opcional posicional: precisa ser anulável ou ter padrão
void registrar(String materia, [String? observacao]) { }

// Parâmetro nomeado com padrão: não precisa ser anulável
void registrar2(String materia, {int minutos = 25}) { }
```

Isso é aprofundado na [Aula 7](07-funcoes-em-dart.md).

## 💡 Analogia

Imagine dois tipos de envelope em uma mesa de recepção:

- Envelope **branco** (`String`): a regra do prédio garante que ele **nunca** está vazio. Você
  pode abrir e ler sem olhar antes.
- Envelope **amarelo** (`String?`): pode estar vazio. Abrir sem olhar é imprudência.

Diante de um envelope amarelo você tem opções:
`?.` é "abro com cuidado e, se estiver vazio, sigo sem ler".
`??` é "se estiver vazio, uso a via de backup que já está na gaveta".
`if (x != null)` é "confiro a olho, vejo que tem papel dentro, e a partir daí trato como branco".
`!` é **rasgar o envelope amarelo de olhos fechados** afirmando que tem papel. Quando tem, ótimo.
Quando não tem, o atendimento inteiro para.

## 🧪 Exemplo mínimo

```dart
void main() {
  const String entrada = 'abc';

  final int? minutos = int.tryParse(entrada);   // pode ser null

  print('Com ?? : ${minutos ?? 0} minutos');
  print('Com ?. : ${minutos?.isEven}');

  if (minutos != null) {
    print('Promovido: o dobro é ${minutos * 2}');
  } else {
    print('Entrada "$entrada" não é um número.');
  }
}
```

```text
Com ?? : 0 minutos
Com ?. : null
Entrada "abc" não é um número.
```

## 📱 Aplicando no Flutter

Null safety é a diferença entre um app que avisa e um app que fecha sozinho.

**1. Dados que ainda não chegaram.**
Quando o app **Foco** busca as trilhas de estudo na internet, existe um intervalo em que a lista
ainda não existe. Modelar isso como `List<Trilha>?` é a forma ingênua; o Riverpod oferece
`AsyncValue<List<Trilha>>`, que separa explicitamente "carregando", "erro" e "dados". Mas o
raciocínio é o mesmo que você está aprendendo agora: **o tipo precisa admitir a ausência**.
Tema de [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).

**2. Campos opcionais do JSON.**
Uma resposta de API pode não trazer um campo. Ao converter JSON em objeto, você vai escrever
exatamente os operadores desta aula:

```dart
// prévia do módulo 09
final String titulo = mapa['title'] as String? ?? 'Sem título';
```

Detalhado em [09 — JSON](../09-consumo-de-api/02-json.md).

**3. O erro que você vai ver na prática.**
No Flutter, este é o formato em que a exceção desta aula aparece:

```text
════════ Exception caught by widgets library ═══════════════════════════════════
The following _TypeError was thrown building MateriasTab:
Null check operator used on a null value
```

Quem escreveu `snapshot.data!` ou `materia!.nome` sem verificar produziu isso.

**4. Estados de tela.**
Modelar "sem dados ainda" × "lista vazia" × "erro" é literalmente decidir entre `null`, lista
vazia e exceção. Assunto de
[06 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md).

**5. Parâmetros de widget.**
Todo widget tem parâmetros opcionais anuláveis. `Text('oi', style: null)` é válido, e o
`?.`/`??` aparece dentro do próprio Flutter para aplicar o padrão do tema.

## 💻 Código completo

> **Arquivo:** `dart_basico/bin/null_safety.dart`
> **Como executar:** `dart run bin/null_safety.dart`

```dart
// bin/null_safety.dart
// Demonstra: T?, ?., ??, ??=, !, promoção de tipo e padrões seguros.

/// Uma matéria de estudo. `observacao` é opcional de verdade.
class Materia {
  Materia(this.nome, {this.observacao, this.minutosMeta});

  /// Sempre existe: tipo não anulável.
  final String nome;

  /// Pode não existir: tipo anulável.
  final String? observacao;

  /// Meta de minutos por semana; `null` significa "sem meta definida".
  final int? minutosMeta;
}

/// Devolve os minutos válidos de [entrada] ou `null` se não der para converter.
int? converterMinutos(String? entrada) {
  if (entrada == null) return null;
  final String limpo = entrada.trim();
  if (limpo.isEmpty) return null;
  final int? valor = int.tryParse(limpo);
  if (valor == null || valor < 0) return null;
  return valor;
}

/// Procura o apelido de [nome] em um cadastro que, neste exemplo, está vazio.
///
/// Existe para produzir um `null` que o compilador não consegue prever.
String? buscarApelido(String nome) {
  const Map<String, String> cadastro = <String, String>{};
  return cadastro[nome];
}

/// Monta a linha de relatório de uma [materia], sem nunca usar `!`.
String descrever(Materia materia) {
  // ?? dá um padrão quando o valor é nulo.
  final String observacao = materia.observacao ?? '(sem observação)';

  // Cópia local + promoção de tipo: dentro do if, meta é int.
  final int? meta = materia.minutosMeta;
  final String textoMeta;
  if (meta != null) {
    textoMeta = 'meta de $meta min/semana (${meta ~/ 60}h aprox.)';
  } else {
    textoMeta = 'sem meta';
  }

  return '${materia.nome.padRight(10)} | $observacao | $textoMeta';
}

void main() {
  print('=== 1. Anulável x não anulável ===');
  const String nome = 'Lucas'; // nunca null
  String? apelido; // começa null
  print('nome    : $nome');
  print('apelido : $apelido');

  print('');
  print('=== 2. Operador ?. (acesso seguro) ===');
  print('apelido?.length      : ${apelido?.length}');
  print('apelido?.toUpperCase: ${apelido?.toUpperCase()}');
  apelido = 'Lu';
  print('depois de atribuir   : ${apelido?.length}');

  print('');
  print('=== 3. Operador ?? (valor padrão) ===');
  String? temaEscolhido;
  print('tema: ${temaEscolhido ?? 'claro (padrão)'}');
  final int minutosSeguros = int.tryParse('abc') ?? 0;
  print('int.tryParse("abc") ?? 0 = $minutosSeguros');

  print('');
  print('=== 4. Operador ??= (atribui só se nulo) ===');
  temaEscolhido ??= 'claro';
  print('primeira atribuição: $temaEscolhido');
  temaEscolhido ??= 'escuro';
  print('segunda tentativa  : $temaEscolhido');

  print('');
  print('=== 5. Promoção de tipo ===');
  final String? entradaUsuario = '135';
  final int? minutos = converterMinutos(entradaUsuario);
  if (minutos != null) {
    // minutos é int aqui dentro: dá para multiplicar sem ! e sem ?.
    print('Convertido: $minutos min, o dobro é ${minutos * 2}');
  } else {
    print('Entrada inválida.');
  }

  print('');
  print('=== 6. Saída antecipada também promove ===');
  for (final String? teste in <String?>['90', null, '', 'abc', ' 45 ', '-5']) {
    final int? valor = converterMinutos(teste);
    final String rotulo = teste == null ? 'null' : '"$teste"';
    print('$rotulo -> ${valor ?? 'inválido'}');
  }

  print('');
  print('=== 7. Spread seguro e lista anulável ===');
  List<String>? extras; // ainda não veio
  final List<String> materiasBase = <String>['Dart', 'Flutter'];
  print('sem extras : ${<String>[...materiasBase, ...?extras]}');
  extras = <String>['Git', 'SQL'];
  print('com extras : ${<String>[...materiasBase, ...?extras]}');

  print('');
  print('=== 8. Objetos com campos opcionais ===');
  final List<Materia> materias = <Materia>[
    Materia('Dart', observacao: 'revisar null safety', minutosMeta: 300),
    Materia('Flutter', minutosMeta: 600),
    Materia('Git', observacao: 'praticar rebase'),
    Materia('Inglês'),
  ];
  for (final Materia materia in materias) {
    print(descrever(materia));
  }

  print('');
  print('=== 9. O operador ! e o erro que ele causa ===');
  final String? valorAusente = buscarApelido('Lucas');
  try {
    // Afirmamos que não é nulo. Estamos errados de propósito.
    final int tamanho = valorAusente!.length;
    print('nunca chega aqui: $tamanho');
  } on TypeError catch (erro) {
    print('Capturado: $erro');
  }

  print('');
  print('=== 10. As alternativas ao ! ===');
  print('com ?.  : ${valorAusente?.length}');
  print('com ??  : ${valorAusente ?? 'texto padrão'}');
  print('com ?.?? : ${valorAusente?.length ?? 0}');
  if (valorAusente != null) {
    print('com if  : ${valorAusente.length}');
  } else {
    print('com if  : valor ausente, nada a fazer');
  }
}
```

Saída esperada:

```text
=== 1. Anulável x não anulável ===
nome    : Lucas
apelido : null

=== 2. Operador ?. (acesso seguro) ===
apelido?.length      : null
apelido?.toUpperCase: null
depois de atribuir   : 2

=== 3. Operador ?? (valor padrão) ===
tema: claro (padrão)
int.tryParse("abc") ?? 0 = 0

=== 4. Operador ??= (atribui só se nulo) ===
primeira atribuição: claro
segunda tentativa  : claro

=== 5. Promoção de tipo ===
Convertido: 135 min, o dobro é 270

=== 6. Saída antecipada também promove ===
"90" -> 90
null -> inválido
"" -> inválido
"abc" -> inválido
" 45 " -> 45
"-5" -> inválido

=== 7. Spread seguro e lista anulável ===
sem extras : [Dart, Flutter]
com extras : [Dart, Flutter, Git, SQL]

=== 8. Objetos com campos opcionais ===
Dart       | revisar null safety | meta de 300 min/semana (5h aprox.)
Flutter    | (sem observação) | meta de 600 min/semana (10h aprox.)
Git        | praticar rebase | sem meta
Inglês     | (sem observação) | sem meta

=== 9. O operador ! e o erro que ele causa ===
Capturado: Null check operator used on a null value

=== 10. As alternativas ao ! ===
com ?.  : null
com ??  : texto padrão
com ?.?? : 0
com if  : valor ausente, nada a fazer
```

## 🔍 Explicando o código

**`final String? observacao;` na classe `Materia`**
O `?` é uma **decisão de modelagem**, não um detalhe técnico: você está declarando ao resto do
programa que "sessão sem observação" é um estado legítimo, e quem usar a classe terá que tratar.

**`int? converterMinutos(String? entrada)`**
Recebe anulável e devolve anulável. As três saídas antecipadas (`entrada == null`,
`limpo.isEmpty`, `valor == null || valor < 0`) tornam a função à prova de qualquer entrada.
Note que depois de `if (entrada == null) return null;` a variável `entrada` está **promovida**
para `String`, e por isso `entrada.trim()` compila sem `?.`.

**`final int? meta = materia.minutosMeta;`**
Esta cópia local existe por um motivo técnico: um campo de outro objeto nem sempre é promovido.
Copiando para uma variável local `final`, o compilador consegue provar que ninguém mudou o valor
entre o `if` e o uso, e a promoção funciona. Guarde este padrão — ele resolve a maioria dos
"por que o Dart ainda acha que isso pode ser nulo?".

**`...?extras`**
O *spread* seguro. Com `...extras` o programa não compilaria, porque `extras` é `List<String>?`.
Com `...?`, se for `null`, simplesmente nada é acrescentado.

**`for (final String? teste in <String?>[...])`**
Repare no tipo explícito `<String?>` na lista. Sem ele, o Dart inferiria `List<String?>` do
mesmo jeito (por causa do `null` no meio), mas deixar escrito documenta a intenção.

**`final String rotulo = teste == null ? 'null' : '"$teste"';`**
Operador ternário para exibir a diferença visual entre a ausência (`null`) e o texto vazio
(`""`). São coisas diferentes, e confundi-las é fonte de bug.

**`buscarApelido('Lucas')` devolvendo `null`**
A função consulta um `Map` vazio, e um `Map` devolve `null` quando a chave não existe. Ela está
aqui porque queremos um `null` **vindo de fora**, igual ao que chega de um banco de dados ou de
uma API — e não um `null` que o compilador poderia adivinhar.

**`on TypeError catch (erro)`**
`Null check operator used on a null value` é lançado como um `TypeError`. Capturamos aqui
**apenas para demonstrar**. Em código real, você não captura esse erro: você evita que ele
aconteça, removendo o `!`.

**`valorAusente?.length ?? 0`**
A combinação mais útil da aula: "pegue o comprimento se existir; se não existir, use 0".
Resultado do tipo `int`, não `int?`.

**`if (valorAusente != null) { print(valorAusente.length); }`**
Sem `?.` e sem `!` dentro do bloco. Este é o código que você deve mirar.

## 🤖🍎 Android × iOS

O erro é o mesmo nos dois sistemas, mas **onde você lê o erro** muda:

- 🤖 **Android:** a exceção aparece no *Logcat* e no terminal do `flutter run`. Em versão
  `release`, o rastro de pilha vem **ofuscado** (nomes trocados por letras), a menos que você
  guarde o arquivo de símbolos gerado no build.
- 🍎 **iOS:** aparece no Console do Xcode e nos *crash logs* do dispositivo. Em `release`, o
  relatório chega pelo App Store Connect e precisa ser "simbolizado" para virar legível.

Em ambos, um `!` equivocado em uma tela pouco visitada pode ficar meses sem ser descoberto. É por
isso que a proteção em tempo de compilação vale mais do que qualquer monitoramento depois.
Os detalhes de depuração por plataforma estão em
[12 — Depurando Android e iOS](../12-testes-e-debug/09-depurando-android-e-ios.md).

## ⚠️ Erros comuns

**1. Usar `!` para "resolver" o aviso do compilador**

```text
Unhandled exception:
Null check operator used on a null value
```

O aviso não era o problema; ele era o **sintoma**. Remova o `!` e trate o nulo.

**2. Achar que `??` funciona com string vazia**

```dart
final String nome = '' ?? 'padrão';   // resultado: '' (string vazia!)
```

`??` só reage a `null`. Texto vazio **não é** nulo. Se você quer tratar os dois:

```dart
final String nome = (entrada == null || entrada.isEmpty) ? 'padrão' : entrada;
```

**3. Perder a promoção ao reatribuir**

```dart
if (apelido != null) {
  apelido = calcular();     // reatribuição quebra a promoção
  print(apelido.length);    // ERRO de compilação
}
```

Use uma variável local `final` para o valor verificado.

**4. Esperar promoção em campo público**

```text
Error: Property 'length' cannot be accessed on 'String?' because it is potentially null.
```

Copie para uma variável local antes do `if`.

**5. Usar `late` no lugar de `T?`**
`late` não elimina o problema — troca um erro de compilação por um `LateInitializationError`
em produção. Use `late` só quando o valor **com certeza** existirá antes do primeiro uso.

**6. Declarar tudo anulável "por segurança"**
É o oposto de segurança. Cada `?` que você escreve obriga todo o resto do programa a tratar
nulo. Declare anulável **só** o que pode legitimamente faltar.

**7. Confundir `null`, `0`, `''` e lista vazia**
São quatro estados diferentes: "não sei", "sei que é zero", "sei que é texto vazio" e "sei que
não há itens". Um relatório que mostra `0 minutos` quando na verdade os dados não carregaram é
uma mentira para o usuário.

**8. `!` em índice de lista ou mapa**

```dart
final int total = mapa['minutos']!;   // explode se a chave não existir
final int total = mapa['minutos'] ?? 0;  // melhor
```

## 🛠️ Exercício guiado

**Passo 1.** Crie `bin/null_safety.dart` e digite o código completo.

**Passo 2.** Rode e confira a saída:

```powershell
dart run bin/null_safety.dart
```

**Passo 3 — provoque o erro de compilação.** Acrescente no início do `main`:

```dart
final String? teste = buscarApelido('Ana');
print(teste.length);
```

Rode e leia:

```text
Error: Property 'length' cannot be accessed on 'String?' because it is potentially null.
```

Repare: o programa **nem chegou a rodar**. Essa é a proteção funcionando.

**Passo 4 — provoque o erro de execução.** Troque a segunda linha acima por:

```dart
print(teste!.length);
```

Rode. Agora compila e explode:

```text
Unhandled exception:
Null check operator used on a null value
```

Este é o erro que você vai encontrar em apps Flutter. Grave o texto dele. Apague as duas linhas
antes de seguir.

**Passo 5 — corrija com cada operador.** Substitua sucessivamente e rode a cada vez:

```dart
print(teste?.length);            // null
print(teste?.length ?? 0);       // 0
if (teste != null) print(teste.length);  // não imprime nada
```

**Passo 6 — quebre a promoção.** Dentro de `descrever`, troque:

```dart
final int? meta = materia.minutosMeta;
if (meta != null) { ... }
```

por acesso direto ao campo:

```dart
if (materia.minutosMeta != null) {
  textoMeta = 'meta de ${materia.minutosMeta} min/semana';
}
```

Note que `${materia.minutosMeta}` ainda funciona (é só interpolação), mas se você tentar
`materia.minutosMeta ~/ 60` o compilador recusa. Volte para a versão com cópia local.

**Passo 7 — acrescente um campo anulável.** Dê a `Materia` um campo
`final DateTime? ultimaSessao;` e mostre no relatório `nunca estudada` quando for nulo, ou o ano
quando existir. Use promoção, não `!`.

**Passo 8.** Rode `dart analyze`. Zero avisos.

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md)

Priorize os de **Correção de bugs**: todos os `!` indevidos ficam nessa seção.

## 🏆 Desafio opcional

Escreva `bin/perfil.dart` com uma classe `PerfilEstudo` contendo:

- `final String nome;` (obrigatório)
- `final String? apelido;`
- `final int? metaSemanalMinutos;`
- `final List<String>? materiasFavoritas;`

E uma função `String resumo(PerfilEstudo p)` que produza, **sem usar `!` nenhuma vez**:

```text
Lucas (Lu) · meta 600 min/semana · favoritas: Dart, Flutter
Ana · sem meta · favoritas: nenhuma
```

Regras:
1. Se houver apelido, mostre entre parênteses; se não, omita o parêntese inteiro.
2. Se a meta existir, mostre também quantas horas dá (`600 min/semana (10h)`).
3. Se a lista de favoritas for `null` **ou** vazia, escreva `nenhuma`.
4. Rode `dart analyze` e garanta zero avisos.

Dica: para o item 3, lembre que `null` e lista vazia são estados **diferentes**; você pode tratar
os dois com `final favoritas = p.materiasFavoritas ?? const <String>[];` seguido de
`favoritas.isEmpty`.

## 📌 Resumo

- `null` é a ausência de valor; em Dart, nenhum tipo aceita `null` a menos que você escreva `?`.
- `String` e `String?` são tipos **diferentes**; converter de `?` para não-`?` exige prova.
- `?.` acessa com segurança e devolve `null` quando o alvo é nulo.
- `??` fornece valor padrão; `??=` atribui apenas se ainda for nulo.
- `...?` faz *spread* seguro de listas anuláveis.
- Promoção de tipo (`if (x != null) { ... }`) é a forma preferida: dentro do bloco, o tipo vira
  não anulável. Cópia local `final` destrava a promoção de campos.
- `!` desliga a verificação e lança `Null check operator used on a null value` quando você erra.
  É o último recurso, nunca o primeiro.
- `null`, `0`, `''` e `[]` são quatro estados distintos — não os misture.

## ☑️ Checklist de domínio

- [x] Sei explicar a diferença entre `int` e `int?`.
- [x] Já vi, no meu terminal, o erro de compilação de acessar membro em tipo anulável.
- [x] Já vi, no meu terminal, `Null check operator used on a null value`.
- [x] Sei usar `?.`, `??` e `??=` sem consultar material.
- [x] Escrevo `if (x != null)` e uso `x` sem `!` dentro do bloco.
- [x] Sei por que copiar um campo para variável local destrava a promoção.
- [x] Consigo justificar quando usar `T?` e quando usar `late`.
- [x] Meu `bin/null_safety.dart` roda e passa em `dart analyze`.

## 📚 Referências oficiais

- [Dart — Sound null safety](https://dart.dev/null-safety)
- [Dart — Understanding null safety](https://dart.dev/null-safety/understanding-null-safety)
- [Dart — Operators](https://dart.dev/language/operators)
- [Dart — Type promotion and flow analysis](https://dart.dev/tools/non-promotion-reasons)
- [Dart — Null safety FAQ](https://dart.dev/null-safety/faq)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Tipos, strings e conversões](04-tipos-strings-conversoes.md) | [README](README.md) | [Controle de fluxo](06-controle-de-fluxo.md) |
