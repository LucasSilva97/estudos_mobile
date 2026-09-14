# Aula 2 — JSON

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Explicar o que é **JSON** e por que praticamente toda API moderna usa esse formato.
- Listar os **seis tipos** que existem em JSON e o tipo Dart correspondente de cada um.
- Usar `jsonDecode` e `jsonEncode` da biblioteca `dart:convert`.
- Explicar **por que `jsonDecode` devolve `dynamic`** e por que `dynamic` é perigoso.
- Converter um `Map<String, dynamic>` em um objeto Dart com um construtor
  `factory Trilha.fromJson(...)` e voltar com `Map<String, dynamic> toJson()`.
- Converter uma **lista de objetos** JSON em `List<Trilha>`.
- Tratar **campo ausente**, **campo nulo** e a diferença entre os dois.
- Ler JSON **aninhado** (objeto dentro de objeto, lista dentro de objeto).
- Converter **datas em ISO 8601** com `DateTime.parse` e `toIso8601String`.
- Entender por que este curso ensina a conversão **à mão** antes de mencionar geradores de
  código.

## ✅ Pré-requisitos

- [Aula 1 — HTTP e REST](01-http-e-rest.md): você precisa saber que o corpo da resposta chega
  como uma `String`.
- [03/01 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md) e
  [03/02 — Construtores](../03-dart-intermediario/02-construtores.md): `factory` é um tipo de
  construtor.
- [02/05 — Null safety](../02-dart-basico/05-null-safety.md): `String?`, `??`, `!` e `as`.
- [02/08 — Listas](../02-dart-basico/08-listas.md): `map`, `toList`, `where`.
- Dart no PATH. Confira com `dart --version` (esperado: `Dart SDK version: 3.13.1`).

---

## 📖 Conceito

### O que é JSON

**JSON** (*JavaScript Object Notation* — "notação de objetos do JavaScript") é um formato de
**texto** para representar dados estruturados.

Duas palavras dessa definição são importantes:

- **Texto.** Um JSON é uma `String`. Quando ele chega pela rede, chega como uma sequência de
  bytes que vira uma `String`. Ele não é um objeto — precisa ser **convertido** em objeto.
- **Estruturado.** Diferente de um texto solto, um JSON tem regras rígidas de forma: chaves entre
  aspas duplas, vírgula entre itens, nada de vírgula sobrando no final.

Apesar do nome, JSON não tem mais relação com JavaScript do que com Dart, Python ou Java. Ele
virou o formato universal de troca de dados porque é legível por humanos, compacto o suficiente,
e todas as linguagens sabem ler e escrever.

Um exemplo real, vindo de `GET https://jsonplaceholder.typicode.com/posts/1`:

```json
{
  "userId": 1,
  "id": 1,
  "title": "sunt aut facere repellat provident",
  "body": "quia et suscipit\nsuscipit recusandae"
}
```

No nosso app **Foco**, esse mesmo objeto vai ser lido como uma **trilha de estudo**: `title` vira
o título da trilha e `body` vira a descrição.

### Os tipos do JSON

JSON tem exatamente **seis** tipos. Não existem outros. Isso é bom: significa que a lista abaixo
é completa, e você pode memorizá-la.

| Tipo JSON | Como se escreve | Vira em Dart, depois do `jsonDecode` |
|---|---|---|
| **objeto** | `{"chave": valor}` | `Map<String, dynamic>` |
| **array** (lista) | `[1, 2, 3]` | `List<dynamic>` |
| **string** | `"texto"` (sempre aspas **duplas**) | `String` |
| **number** | `42` ou `3.14` ou `-1e5` | `int` se for inteiro, `double` se tiver parte decimal |
| **boolean** | `true` ou `false` (minúsculo) | `bool` |
| **null** | `null` (minúsculo) | `Null` (o valor `null`) |

Repare no que **não existe** em JSON, e que é a fonte de quase todo problema de conversão:

- ❌ **Não existe tipo data.** Datas viajam como **string** (no formato ISO 8601) ou como
  **número** (*timestamp*, milissegundos desde 1970). Você converte na mão.
- ❌ **Não existe tipo decimal exato.** `19.90` é um `double` binário, com todas as imprecisões
  de ponto flutuante. Para dinheiro, APIs sérias mandam **centavos como inteiro** (`1990`).
- ❌ **Não existem comentários.** `// isto` quebra o `jsonDecode`.
- ❌ **Não existe aspas simples.** `{'a': 1}` **não é JSON válido**. Tem que ser `{"a": 1}`.
- ❌ **Não existe vírgula sobrando.** `{"a": 1,}` é inválido.
- ❌ **Não existem chaves sem aspas.** `{a: 1}` é inválido (isso é JavaScript, não JSON).

> ⚠️ **Armadilha de número que pega quase todo mundo.** Em JSON, `3` e `3.0` são números
> diferentes para o Dart: o primeiro decodifica como `int`, o segundo como `double`. Se você
> escrever `mapa['nota'] as double` e o servidor mandar `4` (sem decimal), você recebe
> `type 'int' is not a subtype of type 'double' in type cast`. A forma correta é sempre
> `(mapa['nota'] as num).toDouble()`, porque `num` é a superclasse de `int` e `double`.

### `jsonDecode` e `jsonEncode`

As duas funções vêm de `dart:convert`, que faz parte do SDK — não precisa de pacote:

```dart
import 'dart:convert';
```

| Função | Recebe | Devolve |
|---|---|---|
| `jsonDecode(String texto)` | Uma `String` com JSON válido | `dynamic` — na prática, `Map<String, dynamic>`, `List<dynamic>`, `String`, `num`, `bool` ou `null` |
| `jsonEncode(Object? valor)` | Um valor Dart "encodável" | Uma `String` com o JSON |

O que `jsonEncode` aceita diretamente: `Map`, `List`, `String`, `int`, `double`, `bool` e `null`.
Qualquer outra coisa lança `JsonUnsupportedObjectError` — **a menos que** o objeto tenha um método
`toJson()`, que o `jsonEncode` chama automaticamente. É por isso que o padrão do curso é escrever
`toJson()` em todo modelo.

### O perigo do `dynamic`

`jsonDecode` devolve `dynamic`. E `dynamic`, em Dart, quer dizer: **"desligue a verificação de
tipos aqui"**.

```dart
final dados = jsonDecode('{"id": 1, "title": "Álgebra"}');

// O Dart compila TUDO isto sem reclamar:
print(dados['id']);
print(dados['titulo']);          // chave que não existe -> null, silenciosamente
print(dados.qualquerCoisa);      // método inexistente -> compila!
print(dados['id'] + 'texto');    // int + String -> compila!
```

Nenhuma dessas quatro linhas dá erro de compilação. As três últimas **explodem em tempo de
execução**, no celular do usuário, depois de publicado. Isso é exatamente o que o *null safety*
e o sistema de tipos do Dart existem para evitar — e `dynamic` desliga essa proteção.

A defesa tem três camadas, e você vai usar as três:

1. **Converta o `dynamic` para um tipo concreto imediatamente**, com `as`:
   ```dart
   final mapa = jsonDecode(corpo) as Map<String, dynamic>;
   ```
   A partir daqui, `mapa['id']` ainda é `dynamic` (porque o valor do `Map` é `dynamic`), mas
   pelo menos `mapa` é um `Map` de verdade — se o servidor mandar uma lista, você recebe um erro
   claro **na linha do cast**, e não vinte linhas depois.

2. **Converta cada campo para o tipo esperado, na entrada**:
   ```dart
   final id = mapa['id'] as int;
   final titulo = mapa['title'] as String;
   ```

3. **Concentre toda essa conversão num único lugar**: o `fromJson` do modelo. Depois dele, o
   resto do aplicativo só vê tipos fortes. Esse é o ponto central da aula.

> A regra que resume tudo: **`dynamic` só pode existir entre a linha do `jsonDecode` e a última
> linha do `fromJson`.** Se um `dynamic` escapa para a camada de tela, o desenho está errado.

### O modelo: `fromJson` e `toJson`

O padrão que o curso adota em **todos** os modelos:

```dart
class Trilha {
  const Trilha({required this.id, required this.titulo});

  final int id;
  final String titulo;

  factory Trilha.fromJson(Map<String, dynamic> json) {
    return Trilha(
      id: json['id'] as int,
      titulo: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': titulo};
}
```

Três decisões nesse código merecem explicação:

- **`factory`.** Um construtor `factory` é um construtor que **não é obrigado** a criar uma
  instância nova: ele pode fazer contas, validar, escolher uma subclasse ou devolver um objeto
  de cache antes de retornar. Um construtor comum (`Trilha.fromJson(...) : id = ...`) só aceita
  expressões simples na lista de inicialização. Como o `fromJson` quase sempre precisa validar e
  transformar, `factory` é a escolha certa.
- **Construtor `const`.** O construtor principal é `const`. Isso permite usar `const` nos widgets
  que recebem o modelo, o que evita reconstruções desnecessárias — um ganho real de desempenho,
  confirmado no módulo 13.
- **O nome do campo em Dart não precisa ser igual ao do JSON.** A API manda `title`; o nosso
  modelo chama `titulo`. O `fromJson` é justamente o lugar onde essa tradução acontece. Isso
  isola o app de nomes ruins de API.

### Campo ausente × campo nulo

São coisas diferentes, e o Dart trata as duas do mesmo jeito — o que é traiçoeiro:

```json
{"id": 1, "descricao": null}
```

```json
{"id": 1}
```

Em ambos, `json['descricao']` devolve `null`. O `Map` do Dart devolve `null` para chave
inexistente **e** para chave com valor nulo.

| Situação | O que você quer fazer |
|---|---|
| Campo **obrigatório** que veio nulo ou ausente | Falhar com uma mensagem clara: o contrato foi quebrado |
| Campo **opcional** | Aceitar `null` e declarar o tipo como `String?` |
| Campo opcional com valor padrão | Usar `??`: `json['minutos'] as int? ?? 0` |

Se você precisa **mesmo** distinguir ausente de nulo (raro, mas acontece em `PATCH`), use
`json.containsKey('descricao')`.

Padrões seguros para cada caso:

```dart
// Obrigatório: se vier errado, quero saber AGORA, com erro claro.
final int id = json['id'] as int;

// Opcional: aceita null.
final String? descricao = json['body'] as String?;

// Opcional com padrão:
final int minutos = json['minutos'] as int? ?? 0;

// Número que pode vir int ou double:
final double nota = (json['nota'] as num?)?.toDouble() ?? 0.0;

// Booleano que às vezes vem como 0/1 (acontece com APIs antigas e com SQLite):
final bool concluida = json['completed'] == true || json['completed'] == 1;
```

### JSON aninhado

Um objeto pode conter outro objeto, e listas de objetos:

```json
{
  "id": 7,
  "titulo": "Álgebra Linear do zero",
  "autor": { "id": 3, "nome": "Marina" },
  "topicos": [
    { "ordem": 1, "nome": "Vetores" },
    { "ordem": 2, "nome": "Matrizes" }
  ]
}
```

A conversão é **recursiva**: cada modelo cuida do seu próprio `fromJson`, e o modelo de fora
chama o `fromJson` de dentro.

```dart
factory Trilha.fromJson(Map<String, dynamic> json) {
  return Trilha(
    id: json['id'] as int,
    titulo: json['titulo'] as String,
    autor: Autor.fromJson(json['autor'] as Map<String, dynamic>),
    topicos: (json['topicos'] as List<dynamic>)
        .map((item) => Topico.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
```

O trecho `(json['topicos'] as List<dynamic>).map(...).toList()` é **o idioma que você mais vai
escrever no módulo inteiro**. Leia com atenção:

1. `json['topicos']` é `dynamic`.
2. `as List<dynamic>` afirma que é uma lista. Se não for, erro aqui, com mensagem clara.
3. `.map((item) => ...)` percorre cada elemento; `item` é `dynamic`.
4. `item as Map<String, dynamic>` afirma que cada elemento é um objeto JSON.
5. `Topico.fromJson(...)` converte.
6. `.toList()` materializa o resultado, porque `map` devolve um `Iterable` preguiçoso.

> Esquecer o `.toList()` é erro comum: o código compila, mas a conversão só acontece quando
> alguém percorre o `Iterable` — e aí o erro estoura num lugar estranho, longe da causa.

### Datas em JSON

Como JSON não tem tipo data, a convenção universal é **ISO 8601**, uma norma internacional de
formato de data e hora:

```text
2026-09-14T13:45:00.000Z
└───┬────┘ └─────┬─────┘│
  data        hora      └── Z = Zulu = UTC (fuso zero)
```

| Formato | Exemplo | Significado |
|---|---|---|
| Data e hora em UTC | `2026-09-14T13:45:00Z` | O `Z` no fim indica UTC |
| Data e hora com fuso | `2026-09-14T10:45:00-03:00` | Mesmo instante, escrito no fuso de Brasília |
| Data e hora sem fuso | `2026-09-14T13:45:00` | **Ambíguo.** O Dart interpreta como hora local |
| Só data | `2026-09-14` | Vira meia-noite local |

Em Dart:

```dart
final DateTime criadaEm = DateTime.parse('2026-09-14T13:45:00Z');  // UTC
final String texto = criadaEm.toIso8601String();                   // volta para JSON
final DateTime local = criadaEm.toLocal();                         // converte para o fuso do aparelho
```

Três regras práticas que evitam bugs de fuso horário, e que valem para sempre:

1. **Guarde e transmita sempre em UTC.** Converta para o fuso local **só na hora de mostrar**.
2. **Nunca formate data com `toString()` na tela.** Use o pacote `intl ^0.20.2`:
   `DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(data.toLocal())`.
3. **`DateTime.parse` lança `FormatException`** se o texto não for ISO 8601. Se a API for
   duvidosa, use `DateTime.tryParse`, que devolve `null` em vez de lançar.

Se a API mandar **timestamp** (número de milissegundos desde 1º de janeiro de 1970, o chamado
*epoch*):

```dart
final data = DateTime.fromMillisecondsSinceEpoch(json['criadaEm'] as int, isUtc: true);
final numero = data.toUtc().millisecondsSinceEpoch;
```

### Por que à mão, antes de mostrar geradores

Existem ferramentas que escrevem o `fromJson`/`toJson` por você — `json_serializable`,
`freezed`, `dart_mappable`. Elas são úteis em projetos grandes e economizam bastante digitação.

Este curso ensina **à mão primeiro**, por quatro razões concretas:

1. **Porque o erro vai acontecer.** Quando o app quebrar com
   `type 'Null' is not a subtype of type 'String'`, você precisa saber que a causa está numa
   linha de `fromJson` e qual campo veio nulo. Quem só conhece o gerador fica olhando para código
   que não escreveu.
2. **Porque o gerador exige `build_runner`.** Ele acrescenta uma etapa de geração
   (`dart run build_runner build`) que precisa ser reexecutada a cada mudança de modelo,
   arquivos `.g.dart` no projeto e mais um ponto de falha. Para um app de 5 telas, o custo não
   compensa.
3. **Porque `fromJson` é o lugar certo de validar.** O gerador produz uma conversão mecânica.
   Regra de negócio ("minutos não pode ser negativo", "se `body` vier vazio, use um texto
   padrão") você precisa escrever de qualquer jeito.
4. **Porque é pouco código.** Um modelo com 5 campos dá 12 linhas de `fromJson`/`toJson`.

Quando adotar um gerador? Quando você tiver **dezenas** de modelos, ou modelos com **muitos**
campos, ou precisar de `copyWith`/`==`/`hashCode` para todos eles. Aí o gerador ganha. Mas você
vai adotá-lo **sabendo o que ele gera** — que é o objetivo desta aula.

---

## 💡 Analogia

JSON é o **formulário de papel** de um cartório.

O papel em si (o texto JSON) não sabe nada: são caixinhas rotuladas com texto dentro. Você não
consegue perguntar ao papel "qual a idade em meses?" — ele só tem o que está escrito.

O `fromJson` é o **atendente que digita o formulário no sistema**. Ele lê a caixinha "data de
nascimento", confere se está preenchida, converte "14/09/2026" em uma data de verdade, e recusa
o formulário se o campo obrigatório estiver em branco. Depois desse atendente, o sistema trabalha
com **dados tipados**, não com papel.

O `toJson` é o caminho inverso: imprimir o registro do sistema de volta em formulário, para
mandar por correio.

E `dynamic` é trabalhar **direto com a fotocópia do papel** pelo escritório inteiro: ninguém sabe
o que tem em cada caixinha até tentar ler, e o erro aparece na mesa de quem menos tem culpa.

---

## 🧪 Exemplo mínimo

Crie uma pasta para experimentar (fora do projeto do curso, é só um laboratório):

```powershell
mkdir C:\Users\Usuário\estudos\lab_json
```

> **Arquivo:** `C:\Users\Usuário\estudos\lab_json\minimo.dart`
> **Como executar:** `dart run C:\Users\Usuário\estudos\lab_json\minimo.dart`

```dart
import 'dart:convert';

void main() {
  // 1. Um JSON como ele chega da rede: uma String.
  const corpo = '{"userId": 1, "id": 1, "title": "Álgebra Linear", "body": "Vetores e matrizes"}';

  // 2. Decodificar: String -> dynamic (na prática, Map<String, dynamic>).
  final mapa = jsonDecode(corpo) as Map<String, dynamic>;

  print('Tipo do resultado: ${mapa.runtimeType}');
  print('Título: ${mapa['title']}');
  print('Id: ${mapa['id']} (tipo ${mapa['id'].runtimeType})');

  // 3. Codificar de volta: Map -> String.
  final novoMapa = <String, dynamic>{'title': 'Cálculo I', 'completed': false, 'userId': 1};
  final textoJson = jsonEncode(novoMapa);
  print('JSON gerado: $textoJson');

  // 4. Uma lista JSON vira List<dynamic>.
  const corpoLista = '[{"id": 1, "title": "A"}, {"id": 2, "title": "B"}]';
  final lista = jsonDecode(corpoLista) as List<dynamic>;
  print('Quantidade de itens: ${lista.length}');
  print('Primeiro título: ${(lista.first as Map<String, dynamic>)['title']}');
}
```

Saída:

```text
Tipo do resultado: _Map<String, dynamic>
Título: Álgebra Linear
Id: 1 (tipo int)
JSON gerado: {"title":"Cálculo I","completed":false,"userId":1}
Quantidade de itens: 2
Primeiro título: A
```

> `print()` dispara o lint `avoid_print` em código Flutter. Em Dart de terminal, como aqui, ele é
> aceitável. Dentro do app, você escreve `debugPrint()`.

---

## 📱 Aplicando no Flutter

No Flutter, a conversão acontece exatamente no mesmo lugar onde você vai colocá-la na aula 7: na
camada de dados, entre a resposta HTTP e o resto do aplicativo.

```text
┌──────────────┐  bytes   ┌──────────────┐  String  ┌─────────────┐  Map   ┌──────────┐
│  A internet  │ ───────► │ http.Response│ ───────► │  jsonDecode │ ─────► │ fromJson │
└──────────────┘          └──────────────┘          └─────────────┘        └────┬─────┘
                                                                                │ Trilha
                                                                                ▼
                                                                    ┌────────────────────┐
                                                                    │ Repositório, estado│
                                                                    │ e telas — tipado   │
                                                                    └────────────────────┘
```

Um ponto específico do Flutter: se a lista for **muito grande** (milhares de itens), o
`jsonDecode` pode segurar a interface por alguns quadros, porque ele roda na mesma *thread* da
tela. A solução oficial é rodar a decodificação em outro *isolate* com `compute`:

```dart
import 'package:flutter/foundation.dart';

List<Trilha> _converter(String corpo) {
  final lista = jsonDecode(corpo) as List<dynamic>;
  return lista
      .map((item) => Trilha.fromJson(item as Map<String, dynamic>))
      .toList();
}

// Na camada de dados:
final trilhas = await compute(_converter, resposta.body);
```

> `compute` só funciona com uma **função de nível superior** ou `static`, porque ela precisa ser
> enviada para outro *isolate*. Uma função anônima que captura variáveis do escopo não serve.
> Para as 100 trilhas da JSONPlaceholder isso é desnecessário — mas guarde a técnica, ela volta
> em [13/03 — Assíncrono sem travar](../13-desempenho-e-seguranca/03-assincrono-sem-travar.md).

---

## 💻 Código completo

Um programa Dart de terminal que exercita **todos** os pontos da aula: tipos, conversão à mão,
lista de objetos, campo ausente, aninhamento e data ISO 8601.

> **Arquivo:** `C:\Users\Usuário\estudos\lab_json\trilhas.dart`
> **Como executar:** `dart run C:\Users\Usuário\estudos\lab_json\trilhas.dart`

```dart
import 'dart:convert';

/// Autor de uma trilha de estudo. Objeto aninhado dentro de [Trilha].
class Autor {
  const Autor({required this.id, required this.nome});

  final int id;
  final String nome;

  factory Autor.fromJson(Map<String, dynamic> json) {
    return Autor(
      id: json['id'] as int,
      nome: json['nome'] as String? ?? 'Anônimo',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'nome': nome};

  @override
  String toString() => 'Autor($id, $nome)';
}

/// Um tópico dentro de uma trilha. Vem numa lista aninhada.
class Topico {
  const Topico({required this.ordem, required this.nome, this.minutos = 0});

  final int ordem;
  final String nome;
  final int minutos;

  factory Topico.fromJson(Map<String, dynamic> json) {
    return Topico(
      ordem: json['ordem'] as int,
      nome: json['nome'] as String,
      // Campo opcional com valor padrão: ausente OU nulo viram 0.
      minutos: json['minutos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ordem': ordem,
        'nome': nome,
        'minutos': minutos,
      };

  @override
  String toString() => '$ordem. $nome ($minutos min)';
}

/// Uma trilha de estudo compartilhada — o modelo central do módulo.
class Trilha {
  const Trilha({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.autor,
    required this.topicos,
    this.criadaEm,
    this.nota = 0,
  });

  final int id;
  final String titulo;
  final String descricao;
  final Autor autor;
  final List<Topico> topicos;
  final DateTime? criadaEm;
  final double nota;

  /// Converte um objeto JSON já decodificado em uma [Trilha].
  ///
  /// Lança [FormatException] se um campo obrigatório vier ausente ou com o
  /// tipo errado — de propósito: é melhor falhar aqui, com mensagem clara,
  /// do que deixar um `null` vazar para a tela.
  factory Trilha.fromJson(Map<String, dynamic> json) {
    final idBruto = json['id'];
    if (idBruto is! int) {
      throw FormatException('Campo "id" ausente ou não numérico em: $json');
    }

    final tituloBruto = json['titulo'];
    if (tituloBruto is! String || tituloBruto.trim().isEmpty) {
      throw FormatException('Campo "titulo" ausente ou vazio na trilha $idBruto');
    }

    final autorBruto = json['autor'];
    if (autorBruto is! Map<String, dynamic>) {
      throw FormatException('Campo "autor" ausente ou malformado na trilha $idBruto');
    }

    // Lista aninhada: se vier ausente, tratamos como lista vazia.
    final topicosBrutos = json['topicos'] as List<dynamic>? ?? <dynamic>[];

    return Trilha(
      id: idBruto,
      titulo: tituloBruto,
      // Campo opcional: ausente ou nulo viram texto padrão.
      descricao: json['descricao'] as String? ?? 'Sem descrição.',
      autor: Autor.fromJson(autorBruto),
      topicos: topicosBrutos
          .map((item) => Topico.fromJson(item as Map<String, dynamic>))
          .toList(),
      // Data opcional em ISO 8601. tryParse devolve null em vez de lançar.
      criadaEm: DateTime.tryParse(json['criadaEm'] as String? ?? ''),
      // num cobre int E double — a API pode mandar 4 ou 4.5.
      nota: (json['nota'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'autor': autor.toJson(),
        'topicos': topicos.map((t) => t.toJson()).toList(),
        // Sempre em UTC ao sair. O fuso local é assunto da tela, não do dado.
        'criadaEm': criadaEm?.toUtc().toIso8601String(),
        'nota': nota,
      };

  /// Converte um corpo de resposta com uma LISTA de trilhas.
  static List<Trilha> listaDoJson(String corpo) {
    final decodificado = jsonDecode(corpo);
    if (decodificado is! List) {
      throw FormatException('Esperava uma lista JSON, veio ${decodificado.runtimeType}');
    }
    return decodificado
        .map((item) => Trilha.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  int get minutosTotais =>
      topicos.fold<int>(0, (soma, topico) => soma + topico.minutos);
}

void main() {
  // ---------------------------------------------------------------
  // 1. Um JSON completo, aninhado, com data ISO 8601.
  // ---------------------------------------------------------------
  const corpoCompleto = '''
{
  "id": 7,
  "titulo": "Álgebra Linear do zero",
  "descricao": "Uma trilha de 4 semanas para quem nunca viu vetores.",
  "autor": { "id": 3, "nome": "Marina" },
  "topicos": [
    { "ordem": 1, "nome": "Vetores",  "minutos": 90 },
    { "ordem": 2, "nome": "Matrizes", "minutos": 120 },
    { "ordem": 3, "nome": "Determinantes" }
  ],
  "criadaEm": "2026-09-14T13:45:00.000Z",
  "nota": 4
}
''';

  final trilha = Trilha.fromJson(jsonDecode(corpoCompleto) as Map<String, dynamic>);

  print('=== 1. Trilha convertida ===');
  print('Título: ${trilha.titulo}');
  print('Autor: ${trilha.autor.nome}');
  print('Tópicos: ${trilha.topicos.length}');
  print('Minutos totais: ${trilha.minutosTotais}');
  print('Nota: ${trilha.nota} (tipo ${trilha.nota.runtimeType})');
  print('Criada em (UTC):   ${trilha.criadaEm}');
  print('Criada em (local): ${trilha.criadaEm?.toLocal()}');
  print('');

  // ---------------------------------------------------------------
  // 2. Campo ausente e campo nulo dão no mesmo: null.
  // ---------------------------------------------------------------
  const corpoMinimo = '''
{
  "id": 8,
  "titulo": "Cálculo I",
  "descricao": null,
  "autor": { "id": 3 }
}
''';

  final minima = Trilha.fromJson(jsonDecode(corpoMinimo) as Map<String, dynamic>);

  print('=== 2. Campos ausentes e nulos ===');
  print('Descrição (veio null):   ${minima.descricao}');
  print('Autor (nome ausente):    ${minima.autor.nome}');
  print('Tópicos (chave ausente): ${minima.topicos.length}');
  print('Data (chave ausente):    ${minima.criadaEm}');
  print('');

  // ---------------------------------------------------------------
  // 3. Lista de objetos.
  // ---------------------------------------------------------------
  const corpoLista = '''
[
  {"id": 1, "titulo": "Álgebra",  "autor": {"id": 1, "nome": "Ana"},  "nota": 4.5},
  {"id": 2, "titulo": "Física",   "autor": {"id": 2, "nome": "Bruno"}, "nota": 3},
  {"id": 3, "titulo": "História", "autor": {"id": 1, "nome": "Ana"},  "nota": 5}
]
''';

  final trilhas = Trilha.listaDoJson(corpoLista);

  print('=== 3. Lista de trilhas ===');
  for (final t in trilhas) {
    print('#${t.id} ${t.titulo} — ${t.autor.nome} — nota ${t.nota}');
  }
  print('Melhor nota: ${trilhas.map((t) => t.nota).reduce((a, b) => a > b ? a : b)}');
  print('');

  // ---------------------------------------------------------------
  // 4. Ida e volta: objeto -> JSON -> objeto.
  // ---------------------------------------------------------------
  final textoGerado = jsonEncode(trilha.toJson());
  final voltou = Trilha.fromJson(jsonDecode(textoGerado) as Map<String, dynamic>);

  print('=== 4. Ida e volta ===');
  print('JSON gerado tem ${textoGerado.length} caracteres.');
  print('Voltou igual? ${voltou.titulo == trilha.titulo && voltou.minutosTotais == trilha.minutosTotais}');
  print('');

  // ---------------------------------------------------------------
  // 5. JSON inválido: o erro que você VAI ver na vida real.
  // ---------------------------------------------------------------
  print('=== 5. JSON inválido ===');
  try {
    jsonDecode("{'titulo': 'aspas simples não são JSON'}");
  } on FormatException catch (e) {
    print('FormatException capturada: ${e.message}');
  }

  try {
    Trilha.fromJson(<String, dynamic>{'titulo': 'sem id', 'autor': <String, dynamic>{}});
  } on FormatException catch (e) {
    print('FormatException capturada: ${e.message}');
  }
}
```

Saída real do programa:

```text
=== 1. Trilha convertida ===
Título: Álgebra Linear do zero
Autor: Marina
Tópicos: 3
Minutos totais: 210
Nota: 4.0 (tipo double)
Criada em (UTC):   2026-09-14 13:45:00.000Z
Criada em (local): 2026-09-14 10:45:00.000

=== 2. Campos ausentes e nulos ===
Descrição (veio null):   Sem descrição.
Autor (nome ausente):    Anônimo
Tópicos (chave ausente): 0
Data (chave ausente):    null

=== 3. Lista de trilhas ===
#1 Álgebra — Ana — nota 4.5
#2 Física — Bruno — nota 3.0
#3 História — Ana — nota 5.0
Melhor nota: 5.0

=== 4. Ida e volta ===
JSON gerado tem 335 caracteres.
Voltou igual? true

=== 5. JSON inválido ===
FormatException capturada: Unexpected character
FormatException capturada: Campo "id" ausente ou não numérico em: {titulo: sem id, autor: {}}
```

---

## 🔍 Explicando o código

| Trecho | Por que está escrito assim |
|---|---|
| `final idBruto = json['id']; if (idBruto is! int)` | `is!` testa o tipo **e** o promove. Depois do `if`, o Dart sabe que `idBruto` é `int`, então não preciso de `as` nem de `!` |
| `throw FormatException('...')` | `FormatException` é a exceção padrão do Dart para "recebi um dado no formato errado". Usar a exceção certa deixa o `catch` da aula 4 mais simples |
| `json['descricao'] as String? ?? 'Sem descrição.'` | `as String?` aceita `null` (não lança se a chave não existir); `??` dá o valor padrão. Sem o `?` no `as`, isso lançaria com campo ausente |
| `json['topicos'] as List<dynamic>? ?? <dynamic>[]` | Lista opcional. Se ausente, vira lista vazia — a tela mostra "nenhum tópico", não quebra |
| `.map((item) => Topico.fromJson(item as Map<String, dynamic>)).toList()` | O idioma central: percorrer, converter cada item, materializar. **Sem `.toList()` a conversão fica preguiçosa** |
| `DateTime.tryParse(json['criadaEm'] as String? ?? '')` | `tryParse` devolve `null` em vez de lançar. Para campo opcional isso é o certo; para obrigatório, use `DateTime.parse` e deixe lançar |
| `(json['nota'] as num?)?.toDouble() ?? 0` | `num` cobre `int` e `double`. É a única forma segura de ler um número que pode vir `4` ou `4.5` |
| `criadaEm?.toUtc().toIso8601String()` | No `toJson`, sempre UTC. O `?.` propaga o `null` sem quebrar |
| `topicos.map((t) => t.toJson()).toList()` | `jsonEncode` não entra em objetos Dart dentro de listas. Converta explicitamente |
| `static List<Trilha> listaDoJson(String corpo)` | Um método `static` na própria classe evita espalhar `jsonDecode` pelo app. É `static` porque não depende de uma instância |
| `if (decodificado is! List)` | Defesa real: quando a API dá erro, ela costuma devolver um **objeto** com a mensagem, não uma lista. Sem essa checagem, o erro seria `type '_Map' is not a subtype of type 'List'` — bem menos claro |
| `fold<int>(0, (soma, topico) => soma + topico.minutos)` | `fold` acumula um valor percorrendo a lista. O `<int>` explícito evita que o Dart infira `num` |

**Sobre a saída do item 1:** repare que `nota` foi impressa como `4.0`, embora o JSON dissesse
`4`. Isso é o `(as num?).toDouble()` funcionando: o valor chegou como `int` e foi convertido.
Sem isso, `as double` teria lançado.

**Sobre a saída do item 5:** as duas exceções são `FormatException`, mas vêm de origens
diferentes — a primeira do `jsonDecode` (texto que não é JSON), a segunda do nosso `fromJson`
(JSON válido, mas com contrato quebrado). Na aula 4 você vai ver que ambas merecem **a mesma
mensagem para o usuário**: "recebemos uma resposta inesperada do servidor".

---

## ⚠️ Erros comuns

| # | Erro | Mensagem que você vê | Correção |
|---|---|---|---|
| 1 | `as double` num campo que veio inteiro | `type 'int' is not a subtype of type 'double' in type cast` | `(json['x'] as num).toDouble()` |
| 2 | `as String` num campo ausente | `type 'Null' is not a subtype of type 'String' in type cast` | `as String?` + `??`, ou validar e lançar `FormatException` |
| 3 | `jsonDecode` num corpo vazio (resposta `204`) | `FormatException: Unexpected end of input (at character 1)` | Verificar `corpo.isEmpty` antes |
| 4 | JSON com aspas simples | `FormatException: Unexpected character (at character 2)` | JSON exige aspas **duplas** |
| 5 | Esquecer `.toList()` depois do `.map` | O código compila, mas o erro aparece longe da causa | Sempre `.toList()` |
| 6 | `jsonEncode(objeto)` sem `toJson()` | `Converting object to an encodable object failed` | Implemente `Map<String, dynamic> toJson()` no modelo |
| 7 | `jsonDecode(corpo) as List<Trilha>` | `type 'List<dynamic>' is not a subtype of type 'List<Trilha>'` | Decodifique como `List<dynamic>` e converta item a item |
| 8 | Guardar data em fuso local no JSON | Os horários "andam" quando o usuário viaja ou muda o fuso | Sempre `toUtc().toIso8601String()` |
| 9 | Usar `dynamic` fora da camada de dados | Erros de tipo só na execução, no celular do usuário | Converta no `fromJson` e devolva tipos fortes |
| 10 | Comentário `//` dentro de um JSON de teste | `FormatException: Unexpected character` | JSON não aceita comentários |
| 11 | Ler `json['completed']` como `bool` quando a API manda `0`/`1` | `type 'int' is not a subtype of type 'bool'` | `json['completed'] == true \|\| json['completed'] == 1` |

---

## 🛠️ Exercício guiado

**Objetivo:** escrever do zero o modelo `Tarefa`, que é o que a [aula 3](03-primeiro-get.md) vai
usar contra a rota real `/todos`.

**Passo 1.** Veja o JSON verdadeiro:

```powershell
curl.exe -s "https://jsonplaceholder.typicode.com/todos/1"
```

```json
{"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false}
```

**Passo 2.** Crie o arquivo:

> **Arquivo:** `C:\Users\Usuário\estudos\lab_json\tarefa.dart`
> **Como executar:** `dart run C:\Users\Usuário\estudos\lab_json\tarefa.dart`

**Passo 3.** Escreva a classe seguindo este esqueleto. Preencha você mesmo os quatro pontos
marcados:

```dart
import 'dart:convert';

class Tarefa {
  const Tarefa({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.concluida,
  });

  final int id;
  final int usuarioId;
  final String titulo;
  final bool concluida;

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    // (1) leia 'id'        -> int obrigatório
    // (2) leia 'userId'    -> int obrigatório
    // (3) leia 'title'     -> String obrigatória, trocando vazio por '(sem título)'
    // (4) leia 'completed' -> bool, aceitando também 0 e 1
    throw UnimplementedError('escreva aqui');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': usuarioId,
        'title': titulo,
        'completed': concluida,
      };

  static List<Tarefa> listaDoJson(String corpo) {
    final lista = jsonDecode(corpo) as List<dynamic>;
    return lista
        .map((item) => Tarefa.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

void main() {
  const corpo = '''
[
  {"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false},
  {"userId": 1, "id": 2, "title": "",                   "completed": 1},
  {"userId": 2, "id": 3, "title": "fugiat veniam minus","completed": true}
]
''';

  final tarefas = Tarefa.listaDoJson(corpo);
  for (final t in tarefas) {
    print('[${t.concluida ? "x" : " "}] #${t.id} ${t.titulo} (usuário ${t.usuarioId})');
  }
  print('Concluídas: ${tarefas.where((t) => t.concluida).length} de ${tarefas.length}');
}
```

**Passo 4.** A saída correta é exatamente esta:

```text
[ ] #1 delectus aut autem (usuário 1)
[x] #2 (sem título) (usuário 1)
[x] #3 fugiat veniam minus (usuário 2)
Concluídas: 2 de 3
```

**Passo 5.** Depois que passar, quebre de propósito: troque `"id": 1` por `"id": "1"` (com aspas)
no primeiro item e rode de novo. Leia a mensagem de erro com atenção — ela diz exatamente qual
`as` falhou. Esse é o valor de converter à mão.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Desta aula saem exercícios de **aplicação** (escrever `fromJson`/`toJson` para um JSON dado),
de **correção de bugs** (um `fromJson` que quebra com campo nulo) e de **leitura de código**
(dizer que tipo Dart cada campo JSON vira).

---

## 🏆 Desafio opcional

Escreva uma função genérica de conversão de lista, para não repetir o `map`/`toList` em cada
modelo:

```dart
List<T> listaDeJson<T>(String corpo, T Function(Map<String, dynamic>) conversor) {
  final decodificado = jsonDecode(corpo);
  if (decodificado is! List) {
    throw FormatException('Esperava uma lista JSON, veio ${decodificado.runtimeType}');
  }
  return decodificado
      .map((item) => conversor(item as Map<String, dynamic>))
      .toList();
}
```

Use assim:

```dart
final tarefas = listaDeJson(corpo, Tarefa.fromJson);
final trilhas = listaDeJson(corpo, Trilha.fromJson);
```

**Parte 2 do desafio:** acrescente um parâmetro opcional `bool ignorarItensInvalidos = false`.
Quando `true`, um item que lançar `FormatException` é **descartado** e os demais continuam, em
vez de a lista inteira falhar. Escreva uma justificativa de três linhas para quando cada
comportamento é o certo — porque essa é uma decisão de produto, não de código: às vezes mostrar
19 de 20 trilhas é melhor que mostrar uma tela de erro, e às vezes é pior.

---

## 📌 Resumo

- **JSON é texto.** Ele chega como `String` e precisa ser convertido.
- Os **seis tipos** do JSON: objeto, array, string, number, boolean e null. Não existe tipo data
  nem decimal exato.
- `jsonDecode` transforma `String` em `dynamic` (`Map<String, dynamic>` ou `List<dynamic>`);
  `jsonEncode` faz o caminho inverso e chama `toJson()` automaticamente.
- **`dynamic` desliga a checagem de tipos.** Ele só pode viver entre o `jsonDecode` e o fim do
  `fromJson`.
- Todo modelo tem `factory X.fromJson(Map<String, dynamic>)` e `Map<String, dynamic> toJson()`.
  `factory` porque a conversão precisa validar antes de construir.
- Para listas: `(json['x'] as List<dynamic>).map((e) => T.fromJson(e as Map<String, dynamic>)).toList()`.
  **Não esqueça o `.toList()`.**
- **Campo ausente e campo nulo dão `null` igual.** Use `as Tipo?` + `??` para opcional, e valide
  explicitamente o obrigatório.
- Números: sempre `(json['x'] as num?)?.toDouble()`, porque `4` é `int` e `4.5` é `double`.
- Datas: **ISO 8601**, `DateTime.parse`/`tryParse`, sempre **UTC** no transporte, fuso local só
  na tela.
- O curso ensina à mão **antes** dos geradores porque você precisa saber ler o erro que o
  gerador produziria.

---

## ☑️ Checklist de domínio

- [ ] Listo os seis tipos do JSON e o tipo Dart de cada um.
- [ ] Digo três coisas que **não** existem em JSON (data, comentário, aspas simples).
- [ ] Escrevo `import 'dart:convert';` de memória.
- [ ] Explico por que `jsonDecode` devolve `dynamic` e qual o risco disso.
- [ ] Escrevo um `factory fromJson` completo, com validação de campo obrigatório.
- [ ] Escrevo o `toJson` correspondente, chamando `toJson()` dos objetos aninhados.
- [ ] Converto uma lista JSON em `List<Trilha>` sem consultar a aula.
- [ ] Trato campo opcional com `as Tipo?` + `??` e sei por que `as Tipo` sem `?` quebra.
- [ ] Leio um número que pode ser `int` ou `double` com `(x as num).toDouble()`.
- [ ] Converto data ISO 8601 com `DateTime.parse` e devolvo com `toUtc().toIso8601String()`.
- [ ] Sei quando usar `tryParse` em vez de `parse`.
- [ ] Explico por que o curso não usa `json_serializable` neste ponto.
- [ ] Sei que `compute` existe para decodificar listas grandes fora da thread da interface.

---

## 📚 Referências oficiais

- [JSON and serialization — docs.flutter.dev](https://docs.flutter.dev/data-and-backend/serialization/json)
- [Parse JSON in the background — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/background-parsing)
- [dart:convert library — api.dart.dev](https://api.dart.dev/stable/dart-convert/dart-convert-library.html)
- [jsonDecode function — api.dart.dev](https://api.dart.dev/stable/dart-convert/jsonDecode.html)
- [jsonEncode function — api.dart.dev](https://api.dart.dev/stable/dart-convert/jsonEncode.html)
- [DateTime class — api.dart.dev](https://api.dart.dev/stable/dart-core/DateTime-class.html)
- [FormatException class — api.dart.dev](https://api.dart.dev/stable/dart-core/FormatException-class.html)
- [compute function — api.flutter.dev](https://api.flutter.dev/flutter/foundation/compute-constant.html)
- [intl package — pub.dev](https://pub.dev/packages/intl)
- [JSON — especificação oficial (json.org)](https://www.json.org/json-pt.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — HTTP e REST](01-http-e-rest.md) | [README](README.md) | [Aula 3 — Primeiro GET](03-primeiro-get.md) |
