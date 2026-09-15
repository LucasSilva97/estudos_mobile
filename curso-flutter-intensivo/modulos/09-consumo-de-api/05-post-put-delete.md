# Aula 5 — POST, PUT e DELETE

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Enviar dados ao servidor com **`POST`**, montando corpo e cabeçalhos corretamente.
- Explicar por que **`Content-Type: application/json`** não é opcional.
- Diferenciar **`PUT`** de **`PATCH`** e escolher o certo para cada situação.
- Usar **`DELETE`** e tratar o caso "já não existe".
- Interpretar os códigos de sucesso: **`200`**, **`201 Created`** e **`204 No Content`**.
- Entender **idempotência** na prática — e por que ela decide se você pode repetir uma requisição.
- Reconhecer que a **JSONPlaceholder não persiste** nada, e o que isso significa para o seu teste.
- Aplicar **atualização otimista** em operações de escrita.

## ✅ Pré-requisitos

- [Aula 1 — HTTP e REST](01-http-e-rest.md) — métodos, cabeçalhos, famílias de status.
- [Aula 2 — JSON](02-json.md) — `jsonEncode`, `toJson`, `fromJson`.
- [Aula 3 — Primeiro GET](03-primeiro-get.md) — o `foco_api` rodando, com `http: ^1.6.0`.
- [Aula 4 — Modelando respostas e erros](04-modelando-respostas-e-erros.md) — `ApiException` e o
  `sealed class Falha`. Esta aula usa os dois.
- [Módulo 08, aula 7 — AsyncNotifier](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)
  — atualização otimista.

---

## 📖 Conceito

### Leitura × escrita

Até a aula 4 você só **leu** dados: `GET`. Requisições de leitura são simples porque:

- não mudam nada no servidor;
- podem ser repetidas à vontade;
- não têm corpo.

Escrever é diferente em todos esses pontos. Um `POST` repetido por engano cria **dois** cadastros.

### Os quatro métodos de escrita

| Método | Para quê | Tem corpo | Idempotente | Status de sucesso |
|---|---|:---:|:---:|---|
| `POST` | **Criar** um recurso novo | ✅ | ❌ | `201 Created` |
| `PUT` | **Substituir** um recurso inteiro | ✅ | ✅ | `200 OK` |
| `PATCH` | **Alterar** parte de um recurso | ✅ | ⚠️ depende | `200 OK` |
| `DELETE` | **Remover** um recurso | ❌ | ✅ | `204 No Content` ou `200 OK` |

### Idempotência: a propriedade que decide tudo

Uma operação é **idempotente** quando fazê-la **uma** ou **dez** vezes dá o mesmo resultado final.

```text
PUT /trilhas/7  {"titulo": "Dart básico"}
→ rode 10 vezes: a trilha 7 tem o título "Dart básico". Uma vez. ✅ idempotente

POST /trilhas   {"titulo": "Dart básico"}
→ rode 10 vezes: existem 10 trilhas chamadas "Dart básico". ❌ não idempotente
```

Por que isso importa na prática, e não só na teoria:

| Situação | Idempotente | Não idempotente |
|---|---|---|
| A conexão caiu e você não sabe se chegou | **Pode repetir** | **Não pode** repetir às cegas |
| O usuário tocou duas vezes no botão | Sem problema | Cria duas coisas |
| Retry automático (aula 6) | Seguro | Perigoso |

> ⚠️ **Nunca faça retry automático de `POST`** sem uma chave de idempotência. É por isso que a
> [aula 6](06-timeout-retry-cancelamento.md) vai tratar retry com tanto cuidado — e por que o botão
> "Salvar" precisa ser desabilitado durante o envio
> ([Módulo 07, aula 7](../07-navegacao-e-formularios/07-validacao-foco-teclado.md)).

### `POST`: criar

```dart
final http.Response resposta = await http.post(
  Uri.parse('https://jsonplaceholder.typicode.com/todos'),
  headers: <String, String>{
    // Diz ao servidor COMO interpretar o corpo que estou enviando.
    'Content-Type': 'application/json; charset=utf-8',
    // Diz ao servidor o formato que EU quero de volta.
    'Accept': 'application/json',
  },
  body: jsonEncode(<String, Object?>{
    'title': 'Estudar Dart',
    'completed': false,
    'userId': 1,
  }),
);

if (resposta.statusCode != 201) {
  throw ApiException(resposta.statusCode, resposta.body);
}
```

Três coisas que sempre dão problema:

**1. `Content-Type` é obrigatório.** Sem ele, muitos servidores recebem o corpo como texto puro e
devolvem `400 Bad Request` ou — pior — `415 Unsupported Media Type`. O `charset=utf-8` garante que
acentos cheguem certos.

**2. `body` precisa ser `String`, não `Map`.**

```dart
body: <String, Object?>{'title': 'x'},   // ❌ o http não serializa para você
body: jsonEncode(<String, Object?>{'title': 'x'}),   // ✅
```

**3. O sucesso de um `POST` é `201`, não `200`.** Verificar `== 200` faz o seu código tratar uma
criação bem-sucedida como erro.

Uma resposta `201` bem-feita traz o recurso criado **com o id do servidor**:

```json
{ "id": 201, "title": "Estudar Dart", "completed": false, "userId": 1 }
```

Use esse id. Não invente um localmente e assuma que o servidor aceitou o seu.

### `PUT` × `PATCH`

```dart
// PUT: substitui o recurso INTEIRO.
// Campos omitidos podem ser apagados pelo servidor.
await http.put(
  Uri.parse('$base/todos/1'),
  headers: cabecalhos,
  body: jsonEncode(<String, Object?>{
    'id': 1,
    'title': 'Título novo',
    'completed': true,
    'userId': 1,           // precisa mandar TUDO
  }),
);

// PATCH: altera só o que você mandar.
await http.patch(
  Uri.parse('$base/todos/1'),
  headers: cabecalhos,
  body: jsonEncode(<String, Object?>{'completed': true}),   // só isto
);
```

| | `PUT` | `PATCH` |
|---|---|---|
| Envia | O recurso completo | Só os campos que mudam |
| Campos omitidos | Podem ser **apagados** | Ficam como estão |
| Tráfego | Maior | Menor |
| Risco de sobrescrever mudança de outro | **Alto** | Menor |
| Suporte nas APIs | Universal | Muito comum, mas nem sempre |

> 📌 **Prefira `PATCH` para alterações parciais.** O caso clássico: dois dispositivos editam a mesma
> trilha. O celular A muda o título; o celular B marca um tema como concluído. Se ambos usarem
> `PUT`, o segundo **desfaz** a mudança do primeiro — porque mandou o objeto inteiro com os dados
> que tinha em mãos. Com `PATCH`, cada um altera só o seu campo.

### `DELETE`

```dart
final http.Response resposta = await http.delete(
  Uri.parse('$base/todos/1'),
  headers: <String, String>{'Accept': 'application/json'},
);

// 200 (com corpo), 204 (sem corpo) e 404 (já não existe) são TODOS aceitáveis.
if (resposta.statusCode != 200 &&
    resposta.statusCode != 204 &&
    resposta.statusCode != 404) {
  throw ApiException(resposta.statusCode, resposta.body);
}
```

O `404` merece atenção. Excluir algo que **já não existe** deixou o sistema no estado desejado — o
recurso não está lá. Tratar isso como erro faz o app mostrar "falha ao excluir" quando, na verdade,
deu tudo certo.

> 💡 Essa é a idempotência do `DELETE` na prática: a segunda chamada devolve `404`, e isso é
> **sucesso** do ponto de vista do usuário.

### Os códigos de sucesso

| Código | Nome | Tem corpo | Quando |
|---|---|:---:|---|
| `200` | OK | ✅ | Leitura, atualização com retorno |
| `201` | Created | ✅ (o recurso criado) | `POST` bem-sucedido |
| `202` | Accepted | ⚠️ | Aceito, será processado depois (fila) |
| `204` | No Content | ❌ | `DELETE`, ou atualização sem retorno |

> ⚠️ **`204` não tem corpo.** Chamar `jsonDecode(resposta.body)` numa resposta `204` lança
> `FormatException: Unexpected end of input`. Sempre cheque o status **antes** de decodificar.

E o `201` costuma trazer um cabeçalho útil:

```dart
final String? local = resposta.headers['location'];   // ex.: /todos/201
```

### A JSONPlaceholder não persiste

Isto confunde todo mundo na primeira vez:

```dart
// 1. Cria — devolve 201 com {"id": 201, ...}
await http.post(Uri.parse('$base/todos'), ...);

// 2. Busca — a trilha 201 NÃO ESTÁ LÁ
final r = await http.get(Uri.parse('$base/todos/201'));
// 404
```

A [JSONPlaceholder](https://jsonplaceholder.typicode.com) é uma API **de demonstração**. Ela
responde corretamente — com os status certos e o corpo certo — mas **finge**. Nada é gravado.

Isso é ótimo para aprender (você não quebra nada) e exige uma decisão no app: como testar o fluxo
completo?

**A resposta: atualização otimista.** Você atualiza a lista local com o que o servidor devolveu, em
vez de recarregar do servidor:

```dart
// ❌ com a JSONPlaceholder, isto "perde" o item criado
await api.criar(nova);
state = AsyncData(await api.listar());   // o item novo não vem

// ✅ usa o que o POST devolveu
final Trilha criada = await api.criar(nova);
state = AsyncData(<Trilha>[...atual, criada]);
```

E essa não é só uma gambiarra para a API de demonstração: é o padrão certo em qualquer API. Ele
economiza uma requisição e deixa a tela responder na hora.

### Atualização otimista em escrita

O padrão completo, do [Módulo 08, aula 7](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md):

```dart
Future<String?> excluir(String id) async {
  final List<Trilha> antes = state.value ?? <Trilha>[];

  // 1. Remove da tela IMEDIATAMENTE.
  state = AsyncData<List<Trilha>>(
    antes.where((Trilha t) => t.id != id).toList(),
  );

  try {
    // 2. Confirma no servidor.
    await _api.excluir(id);
    return null;
  } on Falha catch (falha) {
    // 3. Falhou? Devolve o item para a lista.
    state = AsyncData<List<Trilha>>(antes);
    return falha.mensagem;
  }
}
```

Quando **não** usar otimismo:

| Operação | Otimista? | Por quê |
|---|---|---|
| Marcar como concluído | ✅ | Reversível, sem consequência |
| Excluir item da lista | ✅ | Reversível, com "desfazer" |
| Criar item | ⚠️ | O id vem do servidor; use um temporário e substitua |
| Pagamento, transferência | ❌ | Mostrar sucesso falso é grave |
| Envio de mensagem | ✅ com marca | WhatsApp mostra "enviando" (um ✓ cinza) |

---

## 💡 Analogia

Pense nos serviços de um cartório.

- **`GET`** é **pedir uma cópia** de um documento. Peça dez vezes: nada muda no arquivo, e você sai
  com dez cópias iguais.
- **`POST`** é **registrar um documento novo**. Faça dez vezes o mesmo registro e você terá **dez
  registros**, cada um com número próprio. Por isso o funcionário devolve o **número do protocolo**
  (o `id` no corpo do `201`): é ele que identifica o registro, não o que você escreveu no papel.
- **`PUT`** é entregar uma **via completa e substituir** a antiga. Perigoso: se você deixou um campo
  em branco na sua via, ele **fica em branco** no arquivo — mesmo que estivesse preenchido antes. É
  por isso que duas pessoas editando com `PUT` desfazem o trabalho uma da outra.
- **`PATCH`** é pedir **"mude só o endereço"**. O resto do documento continua como estava. Duas
  pessoas podem alterar campos diferentes sem se atrapalhar.
- **`DELETE`** é pedir o **cancelamento**. Peça duas vezes: na segunda o funcionário diz "esse
  registro não existe" (`404`) — e isso **não é problema**. O seu objetivo (o registro não existir)
  foi alcançado.
- **A JSONPlaceholder** é um **cartório de treinamento**. Todo o procedimento é seguido, todos os
  carimbos são dados, todos os protocolos são emitidos — e no fim do dia o arquivo é esvaziado. Bom
  para treinar; inútil para guardar.
- **Atualização otimista** é você já anotar o novo endereço na sua agenda **enquanto** o
  funcionário registra. Se ele recusar, você apaga. Na esmagadora maioria das vezes ele aceita, e
  você não ficou parado no balcão.

---

## 🧪 Exemplo mínimo

Os quatro métodos, com os status e corpos reais aparecendo no console.

> **Arquivo:** `foco_api/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _base = 'https://jsonplaceholder.typicode.com';

/// Cabeçalhos padrão de toda requisição com corpo JSON.
///
/// Content-Type: como o SERVIDOR deve interpretar o que eu envio.
/// Accept:       o formato que EU quero receber de volta.
const Map<String, String> _cabecalhos = <String, String>{
  'Content-Type': 'application/json; charset=utf-8',
  'Accept': 'application/json',
};

void main() => runApp(const AppEscrita());

class AppEscrita extends StatelessWidget {
  const AppEscrita({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaEscrita(),
    );
  }
}

class TelaEscrita extends StatefulWidget {
  const TelaEscrita({super.key});

  @override
  State<TelaEscrita> createState() => _TelaEscritaState();
}

class _TelaEscritaState extends State<TelaEscrita> {
  final List<String> _log = <String>[];
  bool _ocupado = false;

  void _registrar(String linha) {
    debugPrint(linha);
    setState(() => _log.insert(0, linha));
  }

  Future<void> _executar(Future<void> Function() acao) async {
    if (_ocupado) return;              // impede toque duplo
    setState(() => _ocupado = true);
    try {
      await acao();
    } on Object catch (erro) {
      _registrar('💥 $erro');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  // ── POST: criar ──────────────────────────────────────────────────────────
  Future<void> _criar() async {
    final http.Response r = await http.post(
      Uri.parse('$_base/todos'),
      headers: _cabecalhos,
      // body precisa ser String. Passar um Map direto NÃO funciona.
      body: jsonEncode(<String, Object?>{
        'title': 'Estudar Dart',
        'completed': false,
        'userId': 1,
      }),
    );

    // Sucesso de POST é 201, não 200. Checar == 200 trataria
    // uma criação bem-sucedida como erro.
    _registrar('POST   → ${r.statusCode} ${r.statusCode == 201 ? "(Created)" : ""}');
    _registrar('        location: ${r.headers['location'] ?? "—"}');
    _registrar('        corpo: ${r.body}');

    // O id vem do SERVIDOR. Nunca invente um localmente.
    final Map<String, Object?> criado =
        jsonDecode(r.body) as Map<String, Object?>;
    _registrar('        id gerado: ${criado['id']}');
  }

  // ── PUT: substituir ──────────────────────────────────────────────────────
  Future<void> _substituir() async {
    final http.Response r = await http.put(
      Uri.parse('$_base/todos/1'),
      headers: _cabecalhos,
      // PUT manda o recurso INTEIRO. Campos omitidos podem
      // ser apagados pelo servidor.
      body: jsonEncode(<String, Object?>{
        'id': 1,
        'title': 'Substituído por PUT',
        'completed': true,
        'userId': 1,
      }),
    );
    _registrar('PUT    → ${r.statusCode}');
    _registrar('        corpo: ${r.body}');
  }

  // ── PATCH: alterar parte ─────────────────────────────────────────────────
  Future<void> _alterar() async {
    final http.Response r = await http.patch(
      Uri.parse('$_base/todos/1'),
      headers: _cabecalhos,
      // Só o campo que muda. O resto fica como está.
      body: jsonEncode(<String, Object?>{'completed': true}),
    );
    _registrar('PATCH  → ${r.statusCode}');
    _registrar('        corpo: ${r.body}');
  }

  // ── DELETE: remover ──────────────────────────────────────────────────────
  Future<void> _excluir() async {
    final http.Response r = await http.delete(
      Uri.parse('$_base/todos/1'),
      headers: <String, String>{'Accept': 'application/json'},
    );

    // 200, 204 e 404 são TODOS sucesso do ponto de vista do usuário:
    // em todos, o recurso não está mais lá.
    final bool ok = r.statusCode == 200 ||
        r.statusCode == 204 ||
        r.statusCode == 404;
    _registrar('DELETE → ${r.statusCode} ${ok ? "(ok)" : "(erro)"}');
    _registrar('        corpo: "${r.body}" (${r.body.length} bytes)');
  }

  // ── A prova de que a JSONPlaceholder não persiste ────────────────────────
  Future<void> _provarQueNaoPersiste() async {
    final http.Response criacao = await http.post(
      Uri.parse('$_base/todos'),
      headers: _cabecalhos,
      body: jsonEncode(<String, Object?>{'title': 'Some daqui a pouco'}),
    );
    final Map<String, Object?> criado =
        jsonDecode(criacao.body) as Map<String, Object?>;
    final Object? id = criado['id'];
    _registrar('1. POST criou o id $id (status ${criacao.statusCode})');

    final http.Response busca =
        await http.get(Uri.parse('$_base/todos/$id'));
    _registrar('2. GET /todos/$id → ${busca.statusCode}');
    _registrar(busca.statusCode == 404
        ? '   ⚠️ 404: a API de demonstração NÃO gravou nada.'
        : '   corpo: ${busca.body}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POST · PUT · PATCH · DELETE')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: _ocupado ? null : () => _executar(_criar),
                  child: const Text('POST'),
                ),
                FilledButton.tonal(
                  onPressed: _ocupado ? null : () => _executar(_substituir),
                  child: const Text('PUT'),
                ),
                FilledButton.tonal(
                  onPressed: _ocupado ? null : () => _executar(_alterar),
                  child: const Text('PATCH'),
                ),
                OutlinedButton(
                  onPressed: _ocupado ? null : () => _executar(_excluir),
                  child: const Text('DELETE'),
                ),
                OutlinedButton(
                  onPressed:
                      _ocupado ? null : () => _executar(_provarQueNaoPersiste),
                  child: const Text('POST + GET'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (BuildContext c, int i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Text(
                  _log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**O roteiro:**

1. Aperte **POST**. Veja `201`, o cabeçalho `location` e o **id gerado pelo servidor**.
2. Aperte **PUT** e depois **PATCH**. Compare os corpos de resposta: o `PUT` devolve o objeto
   inteiro; o `PATCH` devolve o objeto com só o campo alterado.
3. Aperte **DELETE**. Observe o corpo: `"{}"` ou vazio.
4. Aperte **POST + GET**. Esta é a prova: o `POST` devolve `201` com um id, e o `GET` naquele id
   devolve **404**. A API de demonstração não grava nada.

---

## 📱 Aplicando no Flutter

Agora o `foco_api` ganha escrita de verdade na feature de trilhas:

- `TrilhaApi` com `criar`, `atualizar`, `alternarTema` e `excluir`;
- o controller com **atualização otimista** e reversão em caso de falha;
- a tela com formulário de criação, exclusão com desfazer e marcação de temas;
- tratamento correto de `201`, `204` e `404`.

---

## 💻 Código completo

> **Arquivo:** `foco_api/lib/features/trilhas/data/trilha_api.dart` (atualizado)
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:foco_api/core/config/ambiente.dart';
import 'package:foco_api/core/erros/api_exception.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';

/// Acesso HTTP às trilhas.
///
/// Esta classe conhece HTTP e JSON — e **só** isso. Ela não sabe nada de
/// widgets, de estado nem de regras de negócio. Módulo 08, aula 9.
class TrilhaApi {
  TrilhaApi({required http.Client cliente, String? base})
      : _cliente = cliente,
        _base = base ?? Ambiente.urlBase;

  final http.Client _cliente;
  final String _base;

  /// Cabeçalhos de toda requisição COM corpo.
  ///
  /// Content-Type: como o servidor deve interpretar o que enviamos.
  /// Sem ele, muitos servidores devolvem 400 ou 415.
  /// O charset=utf-8 garante que acentos cheguem corretos.
  static const Map<String, String> _comCorpo = <String, String>{
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  /// Cabeçalhos de requisição SEM corpo (GET, DELETE).
  static const Map<String, String> _semCorpo = <String, String>{
    'Accept': 'application/json',
  };

  // ── Leitura ───────────────────────────────────────────────────────────────

  Future<List<Trilha>> listar() async {
    final http.Response r = await _cliente.get(
      Uri.parse('$_base/posts?_limit=10'),
      headers: _semCorpo,
    );

    _exigirSucesso(r, esperados: const <int>[200]);

    final List<Object?> bruto = jsonDecode(r.body) as List<Object?>;
    return bruto
        .map((Object? e) => Trilha.fromJson(e! as Map<String, Object?>))
        .toList();
  }

  // ── Escrita ───────────────────────────────────────────────────────────────

  /// Cria uma trilha.
  ///
  /// POST **não é idempotente**: chamar duas vezes cria duas trilhas.
  /// Por isso o botão que chama este método precisa ser desabilitado
  /// durante o envio, e não pode entrar em retry automático (aula 6).
  Future<Trilha> criar(Trilha nova) async {
    final http.Response r = await _cliente.post(
      Uri.parse('$_base/posts'),
      headers: _comCorpo,
      // jsonEncode é obrigatório: o pacote http não serializa Map.
      body: jsonEncode(nova.toJsonParaCriar()),
    );

    // Sucesso de POST é 201. Aceitamos 200 porque algumas APIs usam.
    _exigirSucesso(r, esperados: const <int>[201, 200]);

    // O id vem do SERVIDOR. Nunca assuma que ele aceitou o seu id local.
    return Trilha.fromJson(jsonDecode(r.body) as Map<String, Object?>);
  }

  /// Substitui a trilha inteira.
  ///
  /// PUT é idempotente — pode repetir com segurança. Em compensação,
  /// campos omitidos podem ser APAGADOS pelo servidor: sempre mande
  /// o objeto completo.
  Future<Trilha> substituir(Trilha trilha) async {
    final http.Response r = await _cliente.put(
      Uri.parse('$_base/posts/${trilha.id}'),
      headers: _comCorpo,
      body: jsonEncode(trilha.toJson()),
    );

    _exigirSucesso(r, esperados: const <int>[200]);
    return Trilha.fromJson(jsonDecode(r.body) as Map<String, Object?>);
  }

  /// Altera apenas os campos informados.
  ///
  /// PATCH é a escolha certa para edição parcial: se outro dispositivo
  /// alterou um campo diferente, a mudança dele não é desfeita.
  Future<Trilha> alterar(
    String id, {
    String? titulo,
    Set<String>? concluidos,
  }) async {
    // Monta só o que mudou. Um campo ausente do Map não é enviado.
    final Map<String, Object?> mudancas = <String, Object?>{
      if (titulo != null) 'title': titulo,
      if (concluidos != null) 'concluidos': concluidos.toList(),
    };

    if (mudancas.isEmpty) {
      throw ArgumentError('Informe ao menos um campo para alterar');
    }

    final http.Response r = await _cliente.patch(
      Uri.parse('$_base/posts/$id'),
      headers: _comCorpo,
      body: jsonEncode(mudancas),
    );

    _exigirSucesso(r, esperados: const <int>[200]);
    return Trilha.fromJson(jsonDecode(r.body) as Map<String, Object?>);
  }

  /// Exclui a trilha.
  ///
  /// DELETE é idempotente. Um 404 significa que o recurso já não existe —
  /// que é exatamente o que queríamos. Tratá-lo como erro faria o app
  /// dizer "falha ao excluir" quando deu tudo certo.
  Future<void> excluir(String id) async {
    final http.Response r = await _cliente.delete(
      Uri.parse('$_base/posts/$id'),
      headers: _semCorpo,
    );

    _exigirSucesso(r, esperados: const <int>[200, 204, 404]);
    // Nada a decodificar: 204 vem SEM corpo, e jsonDecode('') lança.
  }

  // ── Auxiliar ──────────────────────────────────────────────────────────────

  /// Lança [ApiException] se o status não estiver na lista de esperados.
  ///
  /// Concentrar a checagem aqui evita o erro clássico de verificar
  /// `== 200` numa operação cujo sucesso é 201 ou 204.
  void _exigirSucesso(http.Response r, {required List<int> esperados}) {
    if (!esperados.contains(r.statusCode)) {
      throw ApiException(r.statusCode, r.body);
    }
  }
}
```

> **Arquivo:** `foco_api/lib/features/trilhas/domain/trilha.dart` (acrescente os métodos de escrita)

```dart
/// Corpo enviado ao CRIAR.
///
/// Diferente do toJson completo: não manda o id (quem gera é o servidor)
/// e não manda campos que o servidor calcula.
Map<String, Object?> toJsonParaCriar() => <String, Object?>{
      'title': titulo,
      'body': descricao,
      'userId': 1,
    };

/// Corpo completo, para PUT.
Map<String, Object?> toJson() => <String, Object?>{
      'id': int.tryParse(id) ?? id,
      'title': titulo,
      'body': descricao,
      'userId': 1,
    };
```

> **Arquivo:** `foco_api/lib/features/trilhas/presentation/trilhas_controller.dart` (atualizado)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/features/trilhas/data/trilha_repositorio.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';

final AsyncNotifierProvider<TrilhasController, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider<TrilhasController, List<Trilha>>(
        TrilhasController.new);

class TrilhasController extends AsyncNotifier<List<Trilha>> {
  @override
  Future<List<Trilha>> build() =>
      ref.watch(trilhaRepositorioProvider).listar();

  Future<void> recarregar() async {
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(trilhaRepositorioProvider).listar(),
    );
  }

  /// Cria uma trilha.
  ///
  /// NÃO é otimista: o id vem do servidor, e criar um item na tela com
  /// id falso causaria problema no primeiro toque nele. Em vez disso,
  /// mostramos "salvando" e acrescentamos o que o POST devolveu.
  Future<String?> criar(String titulo, String descricao) async {
    final String limpo = titulo.trim();
    if (limpo.length < 3) return 'O título precisa ter pelo menos 3 letras';

    final List<Trilha> atual = state.value ?? <Trilha>[];

    // Mantém a lista visível enquanto salva.
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);

    try {
      final Trilha criada = await ref
          .read(trilhaRepositorioProvider)
          .criar(Trilha(id: '', titulo: limpo, descricao: descricao));

      // Usa o que o SERVIDOR devolveu — com o id real.
      //
      // Recarregar a lista do servidor aqui seria o "correto" numa API
      // que persiste, mas custaria uma requisição a mais. E com a
      // JSONPlaceholder (que não grava nada) o item recém-criado
      // simplesmente sumiria.
      state = AsyncData<List<Trilha>>(<Trilha>[criada, ...atual]);
      return null;
    } on Falha catch (falha, pilha) {
      state = AsyncError<List<Trilha>>(falha, pilha)
          .copyWithPrevious(AsyncData<List<Trilha>>(atual));
      return falha.mensagem;
    }
  }

  /// Marca ou desmarca um tema.
  ///
  /// OTIMISTA: a mudança é reversível e sem consequência, então a tela
  /// responde instantaneamente e o servidor confirma depois.
  Future<String?> alternarTema(String trilhaId, String tema) async {
    final List<Trilha>? antes = state.value;
    if (antes == null) return null; // ainda carregando

    final int i = antes.indexWhere((Trilha t) => t.id == trilhaId);
    if (i == -1) return null;

    final Trilha alvo = antes[i];
    final Set<String> novos = <String>{...alvo.concluidos};
    if (!novos.remove(tema)) novos.add(tema);

    // 1. Aplica localmente, AGORA.
    state = AsyncData<List<Trilha>>(<Trilha>[
      for (final Trilha t in antes)
        if (t.id == trilhaId) t.copyWith(concluidos: novos) else t,
    ]);

    try {
      // 2. Confirma no servidor com PATCH — só o campo que mudou.
      await ref
          .read(trilhaRepositorioProvider)
          .alterarConcluidos(trilhaId, novos);
      return null;
    } on Falha catch (falha) {
      // 3. Falhou: devolve o estado anterior.
      state = AsyncData<List<Trilha>>(antes);
      return falha.mensagem;
    }
  }

  /// Exclui.
  ///
  /// OTIMISTA com desfazer: o item sai da tela na hora, e a tela oferece
  /// "Desfazer" no SnackBar. Se o servidor recusar, o item volta sozinho.
  Future<String?> excluir(String id) async {
    final List<Trilha>? antes = state.value;
    if (antes == null) return null;

    state = AsyncData<List<Trilha>>(
      antes.where((Trilha t) => t.id != id).toList(),
    );

    try {
      await ref.read(trilhaRepositorioProvider).excluir(id);
      return null;
    } on Falha catch (falha) {
      state = AsyncData<List<Trilha>>(antes);
      return falha.mensagem;
    }
  }
}
```

> **Arquivo:** `foco_api/lib/features/trilhas/presentation/trilhas_tab.dart` (trechos de escrita)

```dart
  /// Formulário de criação numa folha inferior.
  Future<void> _criarTrilha(BuildContext context, WidgetRef ref) async {
    final TextEditingController titulo = TextEditingController();
    final TextEditingController descricao = TextEditingController();

    final bool? confirmou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext c) => Padding(
        // viewInsets: o teclado não pode cobrir os campos.
        // Módulo 06, aula 11.
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.viewInsetsOf(c).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Nova trilha', style: Theme.of(c).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: titulo,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título',
                helperText: 'Pelo menos 3 letras',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descricao,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );

    // Controllers criados aqui precisam ser liberados aqui.
    final String t = titulo.text;
    final String d = descricao.text;
    titulo.dispose();
    descricao.dispose();

    if (confirmou != true) return;
    if (!context.mounted) return;

    final String? erro =
        await ref.read(trilhasProvider.notifier).criar(t, d);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(erro ?? 'Trilha criada'),
      ));
  }

  /// Exclusão com desfazer.
  Future<void> _excluir(
    BuildContext context,
    WidgetRef ref,
    Trilha trilha,
  ) async {
    final String? erro =
        await ref.read(trilhasProvider.notifier).excluir(trilha.id);

    if (!context.mounted) return;

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('"${trilha.titulo}" excluída'),
        action: SnackBarAction(
          label: 'Desfazer',
          // Recria a trilha no servidor. Note que isto é um POST novo:
          // o id será diferente. Com uma API real, você usaria um
          // endpoint de "restaurar" ou exclusão lógica.
          onPressed: () => ref
              .read(trilhasProvider.notifier)
              .criar(trilha.titulo, trilha.descricao),
        ),
      ));
  }
```

Rode e teste:

```powershell
flutter analyze
flutter run -d chrome
```

1. Toque no `+`, preencha e crie: a trilha aparece **no topo**, com o id vindo do servidor.
2. Marque um tema: o chip muda **instantaneamente**; o `PATCH` confirma depois.
3. Exclua uma trilha: ela some na hora, e o `SnackBar` oferece **Desfazer**.
4. Desligue a internet e tente excluir: o item **volta** para a lista e a mensagem de erro aparece.
5. Recarregue a página (`F5`): as trilhas criadas **somem** — a JSONPlaceholder não persiste.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `'Content-Type': 'application/json; charset=utf-8'` | Sem ele, o servidor recebe o corpo como texto puro. O `charset` garante acentos corretos. |
| `'Accept': 'application/json'` | Diz o formato que **você** quer de volta. Algumas APIs devolvem XML sem isso. |
| `body: jsonEncode(...)` | Obrigatório: o pacote `http` **não** serializa `Map` automaticamente. |
| `_exigirSucesso(r, esperados: <int>[201, 200])` | Concentra a checagem e evita o erro clássico de verificar `== 200` num `POST`. |
| `esperados: <int>[200, 204, 404]` no `excluir` | `404` significa "já não existe" — que é o objetivo. Tratá-lo como erro mentiria para o usuário. |
| Nenhum `jsonDecode` no `excluir` | `204` vem **sem corpo**; `jsonDecode('')` lançaria `FormatException`. |
| `toJsonParaCriar()` separado de `toJson()` | Ao criar, não se manda o id (quem gera é o servidor). São corpos diferentes. |
| `Trilha.fromJson(jsonDecode(r.body))` no `criar` | O retorno do `201` traz o **id real**. Nunca invente um id local. |
| `if (titulo != null) 'title': titulo` no `alterar` | *Collection if*: só entra no `Map` o que mudou. É a essência do `PATCH`. |
| `PATCH` em `alternarTema`, `PUT` só em substituição completa | `PATCH` não desfaz alterações que outro dispositivo fez em outros campos. |
| `criar` **não** otimista | O id vem do servidor; um item com id falso quebraria no primeiro toque. |
| `alternarTema` e `excluir` otimistas | Reversíveis e sem consequência: a tela responde na hora e reverte se falhar. |
| `state = AsyncData(antes)` no `catch` | A reversão. Sem ela, a tela mostraria um estado que o servidor recusou. |
| `titulo.dispose()` depois de ler os textos | Controllers criados na função precisam ser liberados nela. |
| `MediaQuery.viewInsetsOf(c).bottom` | O teclado não pode cobrir os campos da folha. Módulo 06, aula 11. |
| `if (!context.mounted) return;` depois de cada `await` | A folha pode ter ficado aberta por minutos. Módulo 05, aula 7. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Permissão de internet | `<uses-permission android:name="android.permission.INTERNET"/>` | Não precisa |
| HTTP sem TLS (`http://`) | Bloqueado desde o Android 9 | Bloqueado pelo ATS |
| Liberar `http://` em dev | `usesCleartextTraffic` no manifest | `NSAllowsArbitraryLoads` no `Info.plist` |
| Certificado autoassinado | `network_security_config.xml` | Perfil de confiança no aparelho |
| Requisição em segundo plano | Limitada pelo Doze | Limitada pelo sistema |

> ⚠️ As duas plataformas **bloqueiam `http://` sem TLS** por padrão. Se o seu backend de
> desenvolvimento roda em `http://192.168.0.10:3000`, a requisição falha **silenciosamente** —
> ou com um erro genérico de conexão que parece "sem internet". As liberações acima são **só para
> desenvolvimento**; nunca as deixe numa build de produção. O
> [Módulo 14, aula 5](../14-build-android/05-permissoes-android.md) e o
> [Módulo 15, aula 5](../15-build-ios/05-icone-splash-versao-infoplist.md) tratam disso.

---

## ⚠️ Erros comuns

### 1. Esquecer o `Content-Type`

```dart
await http.post(url, body: jsonEncode(dados));   // ❌ sem headers
```

```text
400 Bad Request
```

O servidor recebeu o corpo como `text/plain`.

**Correção:** `headers: {'Content-Type': 'application/json; charset=utf-8'}`.

### 2. Passar `Map` direto no `body`

```dart
body: <String, Object?>{'title': 'x'},   // ❌
```

O pacote `http` converte o `Map` para `application/x-www-form-urlencoded`, não para JSON.

**Correção:** `body: jsonEncode(...)`.

### 3. Verificar `== 200` num `POST`

```dart
if (resposta.statusCode != 200) throw ...;   // ❌ 201 é sucesso
```

**Correção:** aceite `201` (e `200`, para APIs que o usam).

### 4. `jsonDecode` numa resposta `204`

```dart
final Map<String, Object?> m = jsonDecode(r.body) as Map<String, Object?>;   // ❌
```

```text
FormatException: Unexpected end of input (at character 1)
```

**Correção:** cheque o status **antes**; `204` não tem corpo.

### 5. Tratar `404` no `DELETE` como erro

```dart
if (r.statusCode != 200) throw ApiException(...);   // ❌
```

O usuário vê "falha ao excluir" quando o item **já não existe** — ou seja, quando deu certo.

**Correção:** aceite `200`, `204` e `404`.

### 6. `PUT` para alteração parcial

```dart
await http.put(url, body: jsonEncode(<String, Object?>{'completed': true}));   // ⚠️
```

Campos omitidos podem ser **apagados** pelo servidor. E, se outro dispositivo alterou outro campo,
a alteração dele é desfeita.

**Correção:** `PATCH` para parcial; `PUT` só com o objeto completo.

### 7. Inventar o id localmente

```dart
final Trilha nova = Trilha(id: 'local_${DateTime.now()}', ...);
await api.criar(nova);
state = AsyncData([...atual, nova]);   // ⚠️ id que o servidor não conhece
```

O primeiro toque nesse item faz `PATCH /trilhas/local_1738…` → `404`.

**Correção:** use o objeto que o `POST` **devolveu**.

### 8. Retry automático de `POST`

```dart
for (int i = 0; i < 3; i++) {
  try { await api.criar(nova); break; } catch (_) { }   // ❌ pode criar 3
}
```

`POST` não é idempotente. Se a primeira tentativa **chegou** mas a resposta se perdeu, você criou
duas.

**Correção:** não repita `POST` automaticamente. Detalhes na
[aula 6](06-timeout-retry-cancelamento.md).

### 9. Botão de salvar sem desabilitar

O usuário toca duas vezes e cria dois cadastros.

**Correção:** `onPressed: _enviando ? null : _salvar`. Módulo 07, aula 7.

### 10. Achar que a JSONPlaceholder gravou

```dart
await api.criar(nova);
state = AsyncData(await api.listar());   // ⚠️ o item novo não vem
```

**Correção:** use o retorno do `POST`. E lembre-se: em uma API real, recarregar funcionaria — mas
custaria uma requisição a mais.

### 11. Otimismo em operação irreversível

```dart
// ❌ mostrar "pagamento aprovado" antes de o servidor confirmar
state = AsyncData(saldoComDesconto);
await api.pagar(valor);
```

**Correção:** operações com consequência financeira ou legal esperam a confirmação.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e execute o roteiro de quatro passos. Anote o id que o `POST`
devolveu.

**Passo 2.** Remova `headers: _cabecalhos` do `_criar`. Rode e anote o status e o corpo da
resposta.

**Passo 3.** Troque `body: jsonEncode(...)` por `body: <String, Object?>{...}`. Leia o erro de
compilação. Depois, se conseguir compilar com um `Map<String,String>`, veja o que o servidor
recebe.

**Passo 4.** No `_criar`, troque a checagem para `if (r.statusCode != 200)`. Aperte POST e observe
que uma criação bem-sucedida passa a ser tratada como erro.

**Passo 5.** Aperte **DELETE** duas vezes seguidas. Anote os dois status. Explique por que o
segundo **não** é um problema.

**Passo 6.** No `excluir` do `TrilhaApi`, remova o `404` da lista de esperados. Exclua a mesma
trilha duas vezes e descreva o que o usuário vê.

**Passo 7.** Compare os corpos de resposta do **PUT** e do **PATCH** na mesma trilha. Liste as
diferenças.

**Passo 8.** Em `alternarTema`, remova o `state = AsyncData(antes)` do `catch`. Desligue a internet
e marque um tema. Descreva o que fica errado na tela.

**Passo 9.** Em `criar`, troque o retorno do `POST` por `await listar()`. Crie uma trilha e observe.
Explique por escrito o que aconteceu e por quê.

**Passo 10.** Responda: quais das operações do seu app poderiam entrar em retry automático com
segurança? Liste-as e justifique com base em idempotência.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Faça os exercícios de **Aplicação** com `POST` e `PATCH`, o de **Correção de bugs** com
`Content-Type` ausente, e o de **Decisão** sobre `PUT` × `PATCH`.

---

## 🏆 Desafio opcional

Implemente uma **chave de idempotência** para tornar o `POST` seguro para repetição.

Requisitos:

- Antes de criar, o app gera um identificador único (`Idempotency-Key`) e o envia no cabeçalho.
- O mesmo identificador é reutilizado se a requisição precisar ser repetida.
- Um `Map<String, Trilha>` local simula o comportamento do servidor: se a chave já foi vista, ele
  devolve o recurso **já criado** em vez de criar outro.
- Um botão "simular conexão instável" faz a primeira tentativa "chegar" mas a resposta se perder —
  e a repetição **não** deve criar uma segunda trilha.

Dica: `Idempotency-Key` é um cabeçalho real, usado por Stripe, PayPal e outras APIs de pagamento.
Gere o valor com `DateTime.now().microsecondsSinceEpoch` + um número aleatório, ou com o pacote
`uuid`.

Depois responda: por que esse mecanismo precisa ficar no **servidor** para valer de verdade? O que
a sua simulação **não** protege?

---

## 📌 Resumo

- `POST` **cria** (sucesso `201`), `PUT` **substitui**, `PATCH` **altera parte**, `DELETE`
  **remove** (`204` ou `200`).
- **`Content-Type: application/json; charset=utf-8`** é obrigatório em toda requisição com corpo.
- **`body` precisa ser `String`**: use `jsonEncode`. O pacote `http` não serializa `Map`.
- **Idempotência** decide se você pode repetir: `PUT` e `DELETE` são idempotentes; **`POST` não é**.
- **Nunca faça retry automático de `POST`** sem chave de idempotência.
- Sucesso de `POST` é **`201`**, não `200`. Verificar `== 200` trata criação bem-sucedida como erro.
- **`204` não tem corpo** — `jsonDecode` nele lança `FormatException`.
- **`404` num `DELETE` é sucesso**: o recurso já não existe, que era o objetivo.
- Prefira **`PATCH`** para alteração parcial: `PUT` pode apagar campos omitidos e desfazer mudanças
  de outro dispositivo.
- **O id vem do servidor.** Use o objeto que o `POST` devolveu; nunca invente um id local.
- A **JSONPlaceholder não persiste** nada: ela responde corretamente e descarta. Use o retorno do
  `POST` em vez de recarregar.
- **Atualização otimista** em operações reversíveis (marcar, excluir), com reversão no `catch`.
  Nunca em operações irreversíveis.
- Botão de salvar **desabilitado** durante o envio — é a proteção mais simples contra duplicata.

---

## ☑️ Checklist de domínio

- [ ] Envio `POST` com `Content-Type`, `Accept` e `jsonEncode`.
- [ ] Verifico `201` (não `200`) como sucesso de criação.
- [ ] Uso o objeto devolvido pelo `POST`, com o id do servidor.
- [ ] Explico idempotência e digo quais métodos são idempotentes.
- [ ] Nunca repito `POST` automaticamente.
- [ ] Escolho entre `PUT` e `PATCH` com justificativa.
- [ ] Trato `200`, `204` e `404` como sucesso no `DELETE`.
- [ ] Nunca chamo `jsonDecode` sem checar o status antes.
- [ ] Sei que a JSONPlaceholder não persiste e projeto o app para isso.
- [ ] Aplico atualização otimista com reversão em caso de falha.
- [ ] Sei em quais operações **não** usar otimismo.
- [ ] Desabilito o botão de envio durante a requisição.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [Send data to the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/send-data)
- [Update data over the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/update-data)
- [Delete data on the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/delete-data)
- [http package — pub.dev](https://pub.dev/packages/http)
- [HTTP request methods — MDN](https://developer.mozilla.org/docs/Web/HTTP/Methods)
- [HTTP response status codes — MDN](https://developer.mozilla.org/docs/Web/HTTP/Status)
- [Idempotent methods — MDN](https://developer.mozilla.org/docs/Glossary/Idempotent)
- [JSONPlaceholder — Guide](https://jsonplaceholder.typicode.com/guide/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Modelando respostas e erros](04-modelando-respostas-e-erros.md) | [README](README.md) | [Aula 6 — Timeout, retry e cancelamento](06-timeout-retry-cancelamento.md) |
