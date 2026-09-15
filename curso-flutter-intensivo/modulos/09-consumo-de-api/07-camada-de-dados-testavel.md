# Aula 7 — Camada de dados testável

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Separar **`service`** (fala HTTP) de **`repository`** (fala domínio) e justificar a divisão.
- Declarar o **contrato** no `domain` e a implementação no `data`, respeitando a regra de
  dependência.
- Converter **DTO → modelo de domínio** e explicar por que os dois não devem ser a mesma classe.
- Injetar o **`http.Client`** pelo construtor — o que torna a camada testável sem rede.
- Escrever testes com **`mocktail`** cobrindo `200`, `500`, timeout e JSON inválido.
- Usar **`MockClient`** do próprio pacote `http` quando o mock não precisa verificar chamadas.
- Montar **fixtures** de JSON reais e reaproveitá-los nos testes.

## ✅ Pré-requisitos

- [Aula 5 — POST, PUT e DELETE](05-post-put-delete.md) e
  [Aula 6 — Timeout, retry e cancelamento](06-timeout-retry-cancelamento.md).
- [Módulo 08, aula 9 — Arquitetura feature-first](../08-estado-e-arquitetura/09-arquitetura-feature-first.md)
  — **essencial**: a regra de dependência e o contrato de repositório.
- [Módulo 08, aula 10 — Injeção de dependências](../08-estado-e-arquitetura/10-injecao-de-dependencias.md)
  — `overrides`, `ProviderContainer`, fakes.
- [Módulo 04, aula 1 — Exceptions](../04-dart-avancado/01-exceptions.md).

---

## 📖 Conceito

### `service` × `repository`: duas responsabilidades

Até agora a `TrilhaApi` fazia tudo: montava a URL, mandava a requisição, checava o status,
decodificava o JSON e construía o modelo. Isso funciona em um app pequeno e endurece rápido.

A divisão profissional é:

| Camada | Fala a língua de | Responsabilidade |
|---|---|---|
| **Service** (ou *datasource*) | **HTTP** | Montar URL, enviar requisição, checar status, devolver **DTO** |
| **Repository** | **Domínio** | Converter DTO → modelo, traduzir exceções, decidir cache/fonte |

```text
Controller  →  Repository  →  Service  →  http.Client  →  rede
(AsyncValue)   (Trilha)       (TrilhaDto)  (Response)
```

Por que separar, em termos concretos:

1. **O service é trocável.** Amanhã a fonte vira GraphQL ou banco local: você escreve outro service
   e o repositório não muda.
2. **O repositório é onde mora a decisão.** "Tentar rede, e se falhar usar cache" é decisão de
   repositório, não de HTTP.
3. **Testar fica simples.** O service se testa com um cliente HTTP falso; o repositório se testa com
   um service falso — sem tocar em rede em nenhum dos dois.

> 📌 Em app pequeno, juntar os dois é aceitável. A divisão compensa quando existe **mais de uma
> fonte** (rede + cache) ou quando a conversão DTO → domínio é não trivial. No `foco_api` fazemos a
> divisão porque o [Módulo 10](../10-persistencia-de-dados/08-cache-e-offline.md) vai acrescentar o
> cache local — e aí ela deixa de ser opcional.

### DTO × modelo de domínio

Um **DTO** (*Data Transfer Object*) espelha **exatamente** o que a API devolve. O **modelo de
domínio** representa o conceito do seu app.

```dart
// DTO — espelha a API. Nomes em inglês, tipos frouxos, campos que
// só existem por causa do backend.
class TrilhaDto {
  const TrilhaDto({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  final int id;
  final String title;
  final String body;
  final int userId;
}

// Domínio — o conceito do app. Nomes em português, tipos certos,
// só o que o app precisa.
class Trilha {
  const Trilha({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.concluidos = const <String>{},
  });

  final String id;
  final String titulo;
  final String descricao;
  final Set<String> concluidos;
}
```

Por que não usar a mesma classe para os dois:

| Situação | Com uma classe só | Com DTO + domínio |
|---|---|---|
| A API renomeia `title` para `name` | Muda no modelo, nas telas, nos testes | Muda **só no DTO** |
| A API devolve `id` como `int`, o app usa `String` | Conversão espalhada | Conversão em **um** lugar |
| A API devolve 20 campos, o app usa 3 | O modelo carrega 17 campos inúteis | O domínio tem 3 |
| O app tem cache local com formato diferente | Impossível sem gambiarra | Dois DTOs, um domínio |
| Testar regra de negócio | Precisa montar JSON | Constrói o modelo direto |

> ⚠️ **O sintoma de que você precisava de DTO:** quando um campo do seu modelo de domínio existe
> "porque a API manda". `userId` não é um conceito do Foco — é detalhe do backend de demonstração.

Em app pequeno, com API estável e nomes já bons, pular o DTO é uma escolha razoável. Saiba que você
a está fazendo.

### Injeção do `http.Client`

Este é o detalhe que decide se a camada é testável:

```dart
// ❌ cria o cliente por dentro: impossível testar sem rede
class TrilhaService {
  final http.Client _cliente = http.Client();
}

// ✅ recebe de fora: o teste passa um cliente falso
class TrilhaService {
  TrilhaService({required http.Client cliente}) : _cliente = cliente;
  final http.Client _cliente;
}
```

No teste:

```dart
final TrilhaService service = TrilhaService(cliente: MockClient(...));
```

Sem sobrescrever nada global, sem rede, sem emulador. É exatamente a injeção de dependências do
[Módulo 08, aula 10](../08-estado-e-arquitetura/10-injecao-de-dependencias.md), aplicada a HTTP.

### Duas formas de simular o cliente HTTP

**1. `MockClient`, do próprio pacote `http`** — simples, sem dependência extra:

```dart
import 'package:http/testing.dart';

final MockClient cliente = MockClient((http.Request req) async {
  if (req.url.path == '/posts') {
    return http.Response(jsonFixture, 200);
  }
  return http.Response('{"erro":"não encontrado"}', 404);
});
```

Você escreve uma função que recebe a requisição e devolve a resposta. Ótimo para a maioria dos
casos.

**2. `mocktail`** — quando você precisa **verificar** como foi chamado:

```dart
class ClienteFalso extends Mock implements http.Client {}

when(() => cliente.get(any(), headers: any(named: 'headers')))
    .thenAnswer((_) async => http.Response(jsonFixture, 200));

// … e depois:
verify(() => cliente.get(Uri.parse('$base/posts?_limit=10'), headers: any(named: 'headers')))
    .called(1);
```

| | `MockClient` | `mocktail` |
|---|---|---|
| Dependência extra | ❌ (vem no `http`) | ✅ `dev_dependencies` |
| Simular resposta | ✅ | ✅ |
| **Verificar** chamadas | ❌ | ✅ |
| Verificar cabeçalhos enviados | ⚠️ manual | ✅ |
| Simular exceção | ✅ (`throw` na função) | ✅ `thenThrow` |
| Legibilidade | Alta | Alta |

**Decisão do curso:** `MockClient` para testar o **service** (o foco é a resposta), `mocktail` para
testar o **repositório** (o foco é o comportamento sob diferentes respostas do service).

> 📌 `mocktail` é preferido a `mockito` porque **não precisa de geração de código**. Sem
> `build_runner`, sem arquivo `.mocks.dart`. Consistente com a decisão de não usar `riverpod_generator`
> ([Módulo 08, aula 4](../08-estado-e-arquitetura/04-por-que-riverpod.md)).

### Fixtures: JSON de verdade nos testes

Escrever JSON dentro do teste polui e envelhece mal. Guarde em arquivo:

```text
test/
├── fixtures/
│   ├── trilhas_200.json
│   ├── trilha_unica_200.json
│   └── trilhas_malformado.json
└── trilhas/
    ├── trilha_service_test.dart
    └── trilha_repositorio_test.dart
```

```dart
String fixture(String nome) =>
    File('test/fixtures/$nome').readAsStringSync();
```

E a regra mais importante: **copie o JSON real da API**, com `curl` ou pelo navegador. Um JSON
inventado à mão não tem os campos extras, os `null` inesperados nem os formatos de data que a API
de verdade manda — e é justamente isso que quebra em produção.

### O que testar em cada camada

| Camada | Teste | Casos obrigatórios |
|---|---|---|
| **Modelo** | `fromJson` / `toJson` | JSON completo, campo ausente, campo `null`, tipo errado |
| **Service** | Requisição e resposta | `200`, `404`, `500`, timeout, JSON malformado |
| **Repository** | Conversão e tradução de erro | Cada exceção do service vira a `Falha` certa |
| **Controller** | Estados | `AsyncLoading` → `AsyncData`, `AsyncError`, reversão otimista |

Os quatro níveis, com fakes diferentes em cada um. Nenhum deles toca a rede.

---

## 💡 Analogia

Pense numa importadora.

- **O `http.Client`** é a **transportadora**: ela traz a caixa do exterior e não sabe o que tem
  dentro.
- **O `service`** é o **despachante aduaneiro**. Ele fala a língua da alfândega: conhece os códigos,
  os formulários, os carimbos. O que ele entrega é a mercadoria **como veio** — na embalagem
  original, com a etiqueta em inglês. Isso é o **DTO**.
- **O `repository`** é o **setor de recebimento**. Ele reembala, traduz a etiqueta para o padrão da
  empresa, descarta o que não interessa e registra no estoque na **língua da casa**. O que sai dali
  é o **modelo de domínio**.
- **Por que separar:** quando o país de origem muda o formulário da alfândega, só o **despachante**
  precisa se adaptar. O estoque continua igual. Se as duas funções fossem a mesma pessoa, uma
  mudança de formulário obrigaria a reorganizar o estoque inteiro.
- **Injetar o `http.Client`** é a empresa **contratar** a transportadora em vez de ter caminhão
  próprio. Para treinar o despachante, você simula uma entrega — não precisa mandar um caminhão até
  a China.
- **`MockClient`** é a caixa de treinamento: você mesmo monta o que vem dentro. **`mocktail`** é a
  caixa de treinamento **com câmera**: além do conteúdo, você confere se o despachante preencheu o
  formulário certo e carimbou no lugar certo.
- **As fixtures** são caixas reais que você guardou de entregas passadas. Treinar com uma caixa que
  você mesmo inventou é fácil demais: ela nunca tem o rótulo rasgado, o campo em branco nem a data
  em formato estranho — que é exatamente o que chega na vida real.

---

## 🧪 Exemplo mínimo

Um service completo com o teste ao lado, os dois curtos.

> **Arquivo:** `foco_api/lib/exemplo_service.dart` (temporário)
> **Como executar:** `flutter test`

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

/// DTO: espelha EXATAMENTE o que a API devolve.
/// Nomes em inglês, campos que só existem por causa do backend.
class TarefaDto {
  const TarefaDto({
    required this.id,
    required this.title,
    required this.completed,
    required this.userId,
  });

  factory TarefaDto.fromJson(Map<String, Object?> json) {
    // Cada campo é validado. Um cast direto quebraria com JSON
    // ligeiramente diferente — e APIs mudam.
    final Object? id = json['id'];
    final Object? title = json['title'];
    if (id is! int) throw const FormatException('Campo "id" ausente ou inválido');
    if (title is! String) {
      throw const FormatException('Campo "title" ausente ou inválido');
    }

    return TarefaDto(
      id: id,
      title: title,
      completed: json['completed'] == true,
      userId: json['userId'] is int ? json['userId']! as int : 0,
    );
  }

  final int id;
  final String title;
  final bool completed;
  final int userId;
}

/// Modelo de DOMÍNIO: o conceito do app.
/// Nomes em português, só o que o app usa. Note que userId sumiu:
/// ele é detalhe do backend, não conceito do Foco.
class Tarefa {
  const Tarefa({
    required this.id,
    required this.titulo,
    required this.concluida,
  });

  final String id;
  final String titulo;
  final bool concluida;
}

/// Erro do service. O repositório o traduz para uma Falha de domínio.
class ApiException implements Exception {
  const ApiException(this.statusCode);
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode)';
}

/// SERVICE: fala HTTP. Devolve DTO, nunca modelo de domínio.
class TarefaService {
  /// O cliente vem de FORA. É isto que torna a classe testável:
  /// o teste passa um cliente falso e nada toca a rede.
  TarefaService({required http.Client cliente, required String base})
      : _cliente = cliente,
        _base = base;

  final http.Client _cliente;
  final String _base;

  Future<List<TarefaDto>> listar() async {
    final http.Response r = await _cliente
        .get(
          Uri.parse('$_base/todos?_limit=5'),
          headers: const <String, String>{'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));

    if (r.statusCode != 200) throw ApiException(r.statusCode);

    // FormatException daqui sobe: o repositório a traduz.
    final List<Object?> bruto = jsonDecode(r.body) as List<Object?>;
    return bruto
        .map((Object? e) => TarefaDto.fromJson(e! as Map<String, Object?>))
        .toList();
  }
}

/// REPOSITORY: fala domínio. Converte DTO e traduz erros.
class TarefaRepositorio {
  const TarefaRepositorio(this._service);

  final TarefaService _service;

  Future<List<Tarefa>> listar() async {
    try {
      final List<TarefaDto> dtos = await _service.listar();
      // A conversão DTO → domínio acontece AQUI, em um lugar só.
      return dtos.map(_paraDominio).toList();
    } on ApiException catch (e) {
      // Erro técnico vira erro de domínio, com mensagem para o usuário.
      throw Exception(
        e.statusCode >= 500
            ? 'O servidor está com problema. Tente mais tarde.'
            : 'Não conseguimos carregar suas tarefas.',
      );
    } on FormatException {
      throw Exception('A resposta do servidor veio em formato inesperado.');
    }
  }

  Tarefa _paraDominio(TarefaDto dto) => Tarefa(
        // int → String: a conversão de tipo fica em UM lugar.
        id: '${dto.id}',
        titulo: dto.title,
        concluida: dto.completed,
      );
}
```

> **Arquivo:** `foco_api/test/exemplo_service_test.dart` (temporário)

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:foco_api/exemplo_service.dart';

void main() {
  const String base = 'https://exemplo.test';

  /// JSON como a API realmente devolve.
  final String jsonOk = jsonEncode(<Map<String, Object?>>[
    <String, Object?>{
      'userId': 1,
      'id': 1,
      'title': 'Estudar Dart',
      'completed': false,
    },
    <String, Object?>{
      'userId': 1,
      'id': 2,
      'title': 'Estudar Flutter',
      'completed': true,
    },
  ]);

  /// MockClient vem no pacote http: você escreve a função que
  /// recebe a requisição e devolve a resposta. Sem dependência extra.
  TarefaService comResposta(http.Response Function(http.Request) responder) {
    return TarefaService(
      cliente: MockClient((http.Request req) async => responder(req)),
      base: base,
    );
  }

  group('TarefaService', () {
    test('200 devolve a lista de DTOs', () async {
      final TarefaService service =
          comResposta((_) => http.Response(jsonOk, 200));

      final List<TarefaDto> dtos = await service.listar();

      expect(dtos.length, 2);
      expect(dtos.first.title, 'Estudar Dart');
      expect(dtos.last.completed, isTrue);
    });

    test('monta a URL certa', () async {
      Uri? urlChamada;
      final TarefaService service = comResposta((http.Request req) {
        urlChamada = req.url;
        return http.Response(jsonOk, 200);
      });

      await service.listar();

      expect(urlChamada.toString(), '$base/todos?_limit=5');
    });

    test('500 lança ApiException', () async {
      final TarefaService service =
          comResposta((_) => http.Response('{"erro":"interno"}', 500));

      await expectLater(
        service.listar(),
        throwsA(isA<ApiException>()
            .having((ApiException e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('JSON malformado lança FormatException', () async {
      final TarefaService service =
          comResposta((_) => http.Response('isto não é json', 200));

      await expectLater(service.listar(), throwsA(isA<FormatException>()));
    });

    test('campo obrigatório ausente lança FormatException', () async {
      // O "title" sumiu: acontece de verdade quando a API muda.
      final TarefaService service = comResposta(
        (_) => http.Response('[{"id": 1, "completed": false}]', 200),
      );

      await expectLater(service.listar(), throwsA(isA<FormatException>()));
    });

    test('timeout lança TimeoutException', () async {
      final TarefaService service = TarefaService(
        cliente: MockClient((http.Request req) async {
          // Demora mais que o timeout de 15 s do service.
          await Future<void>.delayed(const Duration(seconds: 20));
          return http.Response(jsonOk, 200);
        }),
        base: base,
      );

      await expectLater(service.listar(), throwsA(isA<TimeoutException>()));
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  group('TarefaRepositorio', () {
    test('converte DTO para domínio', () async {
      final TarefaRepositorio repo = TarefaRepositorio(
        comResposta((_) => http.Response(jsonOk, 200)),
      );

      final List<Tarefa> tarefas = await repo.listar();

      expect(tarefas.first.id, '1');          // int virou String
      expect(tarefas.first.titulo, 'Estudar Dart');  // title virou titulo
      expect(tarefas.first.concluida, isFalse);
    });

    test('traduz 500 para mensagem de usuário', () async {
      final TarefaRepositorio repo = TarefaRepositorio(
        comResposta((_) => http.Response('', 500)),
      );

      await expectLater(
        repo.listar(),
        throwsA(predicate(
          (Object e) => e.toString().contains('servidor está com problema'),
        )),
      );
    });

    test('traduz JSON inválido para mensagem de usuário', () async {
      final TarefaRepositorio repo = TarefaRepositorio(
        comResposta((_) => http.Response('não é json', 200)),
      );

      await expectLater(
        repo.listar(),
        throwsA(predicate(
          (Object e) => e.toString().contains('formato inesperado'),
        )),
      );
    });
  });
}
```

```powershell
flutter test test/exemplo_service_test.dart
```

Dez testes, nenhum toca a rede, todos rodam em milissegundos. **Cada um deles cobre um caso que
acontece de verdade em produção.**

---

## 📱 Aplicando no Flutter

Agora o `foco_api` ganha a camada de dados completa:

```text
features/trilhas/
├── domain/
│   ├── trilha.dart                      ← modelo de domínio (Dart puro)
│   └── trilha_repositorio_contrato.dart ← o contrato
├── data/
│   ├── trilha_dto.dart                  ← espelha a API
│   ├── trilha_api.dart                  ← o service (HTTP)
│   └── trilha_repositorio.dart          ← implementa o contrato
└── presentation/…
```

E os testes:

```text
test/
├── fixtures/
│   ├── trilhas_200.json
│   └── trilhas_campo_ausente.json
└── trilhas/
    ├── trilha_dto_test.dart
    ├── trilha_api_test.dart
    └── trilha_repositorio_test.dart
```

---

## 💻 Código completo

> **Arquivo:** `foco_api/pubspec.yaml` (acrescente a dependência de teste)
> **Instale com:** `flutter pub add --dev mocktail`

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  # mocktail em vez de mockito: NÃO precisa de geração de código.
  # Sem build_runner, sem arquivos .mocks.dart no repositório.
  mocktail: ^1.0.4
```

> **Arquivo:** `foco_api/lib/features/trilhas/data/trilha_dto.dart` (novo)

```dart
/// DTO: espelha EXATAMENTE o que a API devolve.
///
/// Se a API renomear um campo, só este arquivo muda. O domínio, as telas
/// e os testes de regra de negócio continuam iguais.
class TrilhaDto {
  const TrilhaDto({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  /// Converte JSON em DTO, validando cada campo.
  ///
  /// Um cast direto (`json['id'] as int`) quebraria com JSON ligeiramente
  /// diferente — e APIs mudam sem avisar. Aqui a falha é explícita e
  /// diz QUAL campo está errado.
  factory TrilhaDto.fromJson(Map<String, Object?> json) {
    final Object? id = json['id'];
    final Object? title = json['title'];

    if (id is! int) {
      throw FormatException('Campo "id" ausente ou não é número: $id');
    }
    if (title is! String) {
      throw FormatException('Campo "title" ausente ou não é texto: $title');
    }

    return TrilhaDto(
      id: id,
      title: title,
      // Campos opcionais: valor padrão em vez de exceção.
      body: json['body'] is String ? json['body']! as String : '',
      userId: json['userId'] is int ? json['userId']! as int : 0,
    );
  }

  final int id;
  final String title;
  final String body;
  final int userId;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'body': body,
        'userId': userId,
      };
}
```

> **Arquivo:** `foco_api/lib/features/trilhas/domain/trilha_repositorio_contrato.dart` (novo)

```dart
// ┌──────────────────────────────────────────────────────────────────────┐
// │ CAMADA: domain                                                       │
// │ Nenhum import de http, de Flutter ou de data.                        │
// └──────────────────────────────────────────────────────────────────────┘

import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';

/// O contrato.
///
/// A presentation depende **deste tipo**. Por isso ela nunca sabe se os
/// dados vêm de HTTP, de banco local ou de memória.
///
/// Todos os métodos lançam [Falha] (nunca ApiException, nunca
/// SocketException): a tradução de erro técnico para erro de domínio é
/// responsabilidade da implementação.
abstract interface class TrilhaRepositorioContrato {
  Future<List<Trilha>> listar();
  Future<List<Trilha>> buscar(String termo);
  Future<Trilha> criar(Trilha nova);
  Future<Trilha> alterarConcluidos(String id, Set<String> concluidos);
  Future<void> excluir(String id);
}
```

> **Arquivo:** `foco_api/lib/features/trilhas/data/trilha_repositorio.dart` (novo)

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:foco_api/core/erros/api_exception.dart';
import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/core/http/cliente_http.dart';
import 'package:foco_api/features/trilhas/data/trilha_api.dart';
import 'package:foco_api/features/trilhas/data/trilha_dto.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';
import 'package:foco_api/features/trilhas/domain/trilha_repositorio_contrato.dart';

/// Implementação HTTP do contrato.
///
/// Duas responsabilidades, e só duas:
/// 1. Converter DTO → modelo de domínio.
/// 2. Traduzir exceção técnica → Falha de domínio.
///
/// Note o que ela NÃO faz: não monta URL, não checa status, não decodifica
/// JSON. Isso é do service.
class TrilhaRepositorio implements TrilhaRepositorioContrato {
  const TrilhaRepositorio(this._api);

  final TrilhaApi _api;

  @override
  Future<List<Trilha>> listar() =>
      _traduzindoErros(() async => (await _api.listar()).map(_paraDominio).toList());

  @override
  Future<List<Trilha>> buscar(String termo) => _traduzindoErros(
        () async => (await _api.buscar(termo)).map(_paraDominio).toList(),
      );

  @override
  Future<Trilha> criar(Trilha nova) => _traduzindoErros(
        () async => _paraDominio(await _api.criar(_paraDto(nova))),
      );

  @override
  Future<Trilha> alterarConcluidos(String id, Set<String> concluidos) =>
      _traduzindoErros(
        () async => _paraDominio(
          await _api.alterar(id, concluidos: concluidos),
        ),
      );

  @override
  Future<void> excluir(String id) => _traduzindoErros(() => _api.excluir(id));

  // ── Conversão ─────────────────────────────────────────────────────────────

  /// DTO → domínio. A conversão de tipo fica em UM lugar.
  Trilha _paraDominio(TrilhaDto dto) => Trilha(
        // int (da API) → String (do domínio).
        id: '${dto.id}',
        titulo: dto.title,
        descricao: dto.body,
        // A JSONPlaceholder não tem "temas"; derivamos da descrição
        // para o app ter algo com que trabalhar.
        temas: _temasDe(dto.body),
      );

  /// Domínio → DTO, para envio.
  TrilhaDto _paraDto(Trilha t) => TrilhaDto(
        id: int.tryParse(t.id) ?? 0,
        title: t.titulo,
        body: t.descricao,
        userId: 1,
      );

  List<String> _temasDe(String texto) {
    final List<String> linhas = texto
        .split('\n')
        .map((String l) => l.trim())
        .where((String l) => l.isNotEmpty)
        .toList();
    return linhas.isEmpty ? const <String>['Introdução'] : linhas;
  }

  // ── Tradução de erros ─────────────────────────────────────────────────────

  /// Converte toda exceção TÉCNICA em uma [Falha] de domínio.
  ///
  /// Depois deste ponto, nada que sobe conhece HTTP. O controller e a
  /// tela só veem Falha — e é por isso que trocar HTTP por banco local
  /// no Módulo 10 não vai exigir mudança nenhuma acima daqui.
  Future<T> _traduzindoErros<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on SocketException catch (e, pilha) {
      Error.throwWithStackTrace(const FalhaDeConexao(), pilha);
    } on TimeoutException catch (e, pilha) {
      Error.throwWithStackTrace(const FalhaDeTempoEsgotado(), pilha);
    } on http.ClientException catch (e, pilha) {
      Error.throwWithStackTrace(const FalhaDeConexao(), pilha);
    } on FormatException catch (e, pilha) {
      // A API mudou o formato, ou devolveu HTML de erro no lugar de JSON.
      Error.throwWithStackTrace(FalhaDeFormato('$e'), pilha);
    } on ApiException catch (e, pilha) {
      Error.throwWithStackTrace(_daApi(e), pilha);
    }
  }

  Falha _daApi(ApiException e) => switch (e.statusCode) {
        401 || 403 => const FalhaDeAutenticacao(),
        404 => const FalhaNaoEncontrado(),
        429 => const FalhaDeLimite(),
        >= 500 => const FalhaDoServidor(),
        _ => FalhaInesperada('HTTP ${e.statusCode}'),
      };
}

/// O repositório exposto pelo CONTRATO, não pela classe concreta.
///
/// É este tipo que permite substituí-lo nos testes com overrides.
/// Módulo 08, aula 10.
final Provider<TrilhaRepositorioContrato> trilhaRepositorioProvider =
    Provider<TrilhaRepositorioContrato>((Ref ref) {
  return TrilhaRepositorio(
    TrilhaApi(cliente: ref.watch(clienteHttpProvider)),
  );
});
```

> **Arquivo:** `foco_api/lib/core/erros/falhas.dart` (completo)

```dart
/// Falhas de DOMÍNIO.
///
/// Sendo sealed, um switch sobre Falha é exaustivo: acrescentar um caso
/// novo quebra a compilação de quem não o tratou — que é o comportamento
/// desejado. Módulo 04, aula 6.
sealed class Falha implements Exception {
  const Falha(this.mensagem);

  /// Texto pronto para mostrar ao usuário. Nunca uma stack trace.
  final String mensagem;

  /// Vale oferecer "Tentar de novo"?
  bool get podeRepetir => true;

  @override
  String toString() => mensagem;
}

final class FalhaDeConexao extends Falha {
  const FalhaDeConexao()
      : super('Sem conexão. Verifique sua internet e tente de novo.');
}

final class FalhaDeTempoEsgotado extends Falha {
  const FalhaDeTempoEsgotado()
      : super('A conexão demorou demais. Tente de novo.');
}

final class FalhaDoServidor extends Falha {
  const FalhaDoServidor()
      : super('O servidor está com problema. Tente em alguns minutos.');
}

final class FalhaDeAutenticacao extends Falha {
  const FalhaDeAutenticacao()
      : super('Sua sessão expirou. Entre de novo.');

  @override
  bool get podeRepetir => false; // repetir sem novo login não adianta
}

final class FalhaNaoEncontrado extends Falha {
  const FalhaNaoEncontrado() : super('Não encontramos o que você procurava.');

  @override
  bool get podeRepetir => false;
}

final class FalhaDeLimite extends Falha {
  const FalhaDeLimite()
      : super('Muitas tentativas. Aguarde um momento.');
}

final class FalhaDeFormato extends Falha {
  const FalhaDeFormato(this.detalhe)
      : super('A resposta do servidor veio em formato inesperado.');

  /// Só para log. NUNCA mostre isto ao usuário.
  final String detalhe;

  @override
  bool get podeRepetir => false;
}

final class FalhaInesperada extends Falha {
  const FalhaInesperada(this.detalhe)
      : super('Algo deu errado. Tente de novo.');

  final String detalhe;
}
```

---

## 💻 Os testes

> **Arquivo:** `foco_api/test/fixtures/trilhas_200.json` (novo)
>
> **Importante:** este JSON foi **copiado da API real**, não inventado.
> Gere o seu com: `curl.exe -s "https://jsonplaceholder.typicode.com/posts?_limit=2"`

```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur"
  },
  {
    "userId": 1,
    "id": 2,
    "title": "qui est esse",
    "body": "est rerum tempore vitae\nsequi sint nihil"
  }
]
```

> **Arquivo:** `foco_api/test/trilhas/trilha_api_test.dart` (novo)

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:foco_api/core/erros/api_exception.dart';
import 'package:foco_api/features/trilhas/data/trilha_api.dart';
import 'package:foco_api/features/trilhas/data/trilha_dto.dart';

/// Lê um JSON de arquivo.
///
/// Fixtures são JSON REAIS, copiados da API. Um JSON inventado à mão
/// não tem os campos extras, os nulls inesperados nem os formatos
/// estranhos que a API de verdade manda — e é justamente isso que
/// quebra em produção.
String fixture(String nome) =>
    File('test/fixtures/$nome').readAsStringSync();

void main() {
  const String base = 'https://api.test';

  /// Monta um service com uma resposta controlada.
  /// MockClient vem no pacote http — sem dependência extra.
  TrilhaApi comResposta(
    FutureOr<http.Response> Function(http.Request) responder,
  ) {
    return TrilhaApi(
      cliente: MockClient((http.Request req) async => responder(req)),
      base: base,
    );
  }

  group('TrilhaApi.listar', () {
    test('200 devolve os DTOs', () async {
      final TrilhaApi api =
          comResposta((_) => http.Response(fixture('trilhas_200.json'), 200));

      final List<TrilhaDto> dtos = await api.listar();

      expect(dtos.length, 2);
      expect(dtos.first.id, 1);
      expect(dtos.first.title, contains('sunt aut facere'));
    });

    test('envia o cabeçalho Accept', () async {
      Map<String, String>? cabecalhos;
      final TrilhaApi api = comResposta((http.Request req) {
        cabecalhos = req.headers;
        return http.Response(fixture('trilhas_200.json'), 200);
      });

      await api.listar();

      expect(cabecalhos?['Accept'], contains('application/json'));
    });

    test('404 lança ApiException com o status', () async {
      final TrilhaApi api = comResposta((_) => http.Response('{}', 404));

      await expectLater(
        api.listar(),
        throwsA(isA<ApiException>()
            .having((ApiException e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('500 lança ApiException', () async {
      final TrilhaApi api = comResposta((_) => http.Response('erro', 500));

      await expectLater(api.listar(), throwsA(isA<ApiException>()));
    });

    test('JSON malformado lança FormatException', () async {
      final TrilhaApi api =
          comResposta((_) => http.Response('<html>erro</html>', 200));

      await expectLater(api.listar(), throwsA(isA<FormatException>()));
    });

    test('campo obrigatório ausente lança FormatException', () async {
      final TrilhaApi api = comResposta(
        (_) => http.Response('[{"userId": 1, "body": "sem id nem title"}]', 200),
      );

      await expectLater(api.listar(), throwsA(isA<FormatException>()));
    });

    test('sem rede lança SocketException', () async {
      final TrilhaApi api = comResposta(
        (_) => throw const SocketException('Failed host lookup'),
      );

      await expectLater(api.listar(), throwsA(isA<SocketException>()));
    });
  });

  group('TrilhaApi.criar', () {
    test('201 devolve o DTO com o id do servidor', () async {
      final TrilhaApi api = comResposta(
        (_) => http.Response(
          '{"id": 101, "title": "Nova", "body": "x", "userId": 1}',
          201,
        ),
      );

      final TrilhaDto criada = await api.criar(
        const TrilhaDto(id: 0, title: 'Nova', body: 'x', userId: 1),
      );

      // O id veio do SERVIDOR, não do que enviamos.
      expect(criada.id, 101);
    });

    test('envia Content-Type: application/json', () async {
      Map<String, String>? cabecalhos;
      final TrilhaApi api = comResposta((http.Request req) {
        cabecalhos = req.headers;
        return http.Response('{"id":1,"title":"x","body":"","userId":1}', 201);
      });

      await api.criar(
        const TrilhaDto(id: 0, title: 'x', body: '', userId: 1),
      );

      expect(cabecalhos?['Content-Type'], contains('application/json'));
    });
  });

  group('TrilhaApi.excluir', () {
    test('204 é sucesso', () async {
      final TrilhaApi api = comResposta((_) => http.Response('', 204));
      await expectLater(api.excluir('1'), completes);
    });

    test('404 também é sucesso: o recurso já não existe', () async {
      final TrilhaApi api = comResposta((_) => http.Response('', 404));
      await expectLater(api.excluir('1'), completes);
    });

    test('500 falha', () async {
      final TrilhaApi api = comResposta((_) => http.Response('', 500));
      await expectLater(api.excluir('1'), throwsA(isA<ApiException>()));
    });
  });
}
```

> **Arquivo:** `foco_api/test/trilhas/trilha_repositorio_test.dart` (novo)

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:foco_api/core/erros/api_exception.dart';
import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/features/trilhas/data/trilha_api.dart';
import 'package:foco_api/features/trilhas/data/trilha_dto.dart';
import 'package:foco_api/features/trilhas/data/trilha_repositorio.dart';
import 'package:foco_api/features/trilhas/domain/trilha.dart';

/// mocktail: NÃO precisa de geração de código.
/// Uma linha e a classe falsa está pronta.
class TrilhaApiMock extends Mock implements TrilhaApi {}

void main() {
  late TrilhaApiMock api;
  late TrilhaRepositorio repo;

  setUpAll(() {
    // Necessário quando um método recebe um tipo customizado
    // e você usa any() nele.
    registerFallbackValue(
      const TrilhaDto(id: 0, title: '', body: '', userId: 0),
    );
  });

  setUp(() {
    api = TrilhaApiMock();
    repo = TrilhaRepositorio(api);
  });

  group('conversão DTO → domínio', () {
    test('converte os campos e os tipos', () async {
      when(() => api.listar()).thenAnswer(
        (_) async => const <TrilhaDto>[
          TrilhaDto(
            id: 7,
            title: 'Fundamentos de Dart',
            body: 'Variáveis\nFunções\nClasses',
            userId: 1,
          ),
        ],
      );

      final List<Trilha> trilhas = await repo.listar();

      expect(trilhas.length, 1);
      // int → String: a conversão fica em UM lugar.
      expect(trilhas.single.id, '7');
      expect(trilhas.single.titulo, 'Fundamentos de Dart');
      // As linhas do body viraram temas.
      expect(trilhas.single.temas, <String>['Variáveis', 'Funções', 'Classes']);
    });

    test('body vazio gera um tema padrão', () async {
      when(() => api.listar()).thenAnswer(
        (_) async => const <TrilhaDto>[
          TrilhaDto(id: 1, title: 'Sem corpo', body: '', userId: 1),
        ],
      );

      final List<Trilha> trilhas = await repo.listar();

      expect(trilhas.single.temas, <String>['Introdução']);
    });
  });

  group('tradução de erros', () {
    test('SocketException vira FalhaDeConexao', () async {
      when(() => api.listar())
          .thenThrow(const SocketException('Failed host lookup'));

      await expectLater(repo.listar(), throwsA(isA<FalhaDeConexao>()));
    });

    test('TimeoutException vira FalhaDeTempoEsgotado', () async {
      when(() => api.listar()).thenThrow(TimeoutException('demorou'));

      await expectLater(repo.listar(), throwsA(isA<FalhaDeTempoEsgotado>()));
    });

    test('500 vira FalhaDoServidor', () async {
      when(() => api.listar()).thenThrow(const ApiException(500, ''));

      await expectLater(repo.listar(), throwsA(isA<FalhaDoServidor>()));
    });

    test('401 vira FalhaDeAutenticacao, que NÃO pode repetir', () async {
      when(() => api.listar()).thenThrow(const ApiException(401, ''));

      await expectLater(
        repo.listar(),
        throwsA(isA<FalhaDeAutenticacao>()
            .having((Falha f) => f.podeRepetir, 'podeRepetir', isFalse)),
      );
    });

    test('404 vira FalhaNaoEncontrado', () async {
      when(() => api.listar()).thenThrow(const ApiException(404, ''));

      await expectLater(repo.listar(), throwsA(isA<FalhaNaoEncontrado>()));
    });

    test('429 vira FalhaDeLimite', () async {
      when(() => api.listar()).thenThrow(const ApiException(429, ''));

      await expectLater(repo.listar(), throwsA(isA<FalhaDeLimite>()));
    });

    test('FormatException vira FalhaDeFormato', () async {
      when(() => api.listar())
          .thenThrow(const FormatException('Unexpected character'));

      await expectLater(repo.listar(), throwsA(isA<FalhaDeFormato>()));
    });

    test('nenhuma mensagem de falha contém jargão técnico', () async {
      // O usuário nunca deve ver "SocketException" nem stack trace.
      for (final Falha falha in <Falha>[
        const FalhaDeConexao(),
        const FalhaDeTempoEsgotado(),
        const FalhaDoServidor(),
        const FalhaNaoEncontrado(),
        const FalhaDeFormato('detalhe técnico'),
      ]) {
        expect(falha.mensagem, isNot(contains('Exception')));
        expect(falha.mensagem, isNot(contains('#0')));
        expect(falha.mensagem.length, greaterThan(10));
      }
    });
  });

  group('escrita', () {
    test('criar converte domínio → DTO e devolve domínio', () async {
      when(() => api.criar(any())).thenAnswer(
        (_) async => const TrilhaDto(
          id: 101,
          title: 'Nova trilha',
          body: 'Tema 1',
          userId: 1,
        ),
      );

      final Trilha criada = await repo.criar(
        const Trilha(id: '', titulo: 'Nova trilha', descricao: 'Tema 1'),
      );

      // O id veio do servidor.
      expect(criada.id, '101');

      // Verifica O QUE foi enviado — algo que o MockClient não faria
      // com a mesma clareza.
      final TrilhaDto enviado =
          verify(() => api.criar(captureAny())).captured.single as TrilhaDto;
      expect(enviado.title, 'Nova trilha');
    });

    test('excluir chama a api uma vez', () async {
      when(() => api.excluir(any())).thenAnswer((_) async {});

      await repo.excluir('7');

      verify(() => api.excluir('7')).called(1);
    });
  });
}
```

Rode a suíte:

```powershell
flutter pub add --dev mocktail
flutter analyze
flutter test
```

Mais de vinte testes, nenhum toca a rede, todos em menos de um segundo.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `TrilhaDto` separado de `Trilha` | Se a API renomear `title`, **só o DTO** muda. O domínio, as telas e os testes de regra continuam iguais. |
| `if (id is! int) throw FormatException('Campo "id"…')` | Mensagem que diz **qual** campo está errado. `json['id'] as int` diria só "type cast failed". |
| `json['body'] is String ? … : ''` | Campo opcional ganha padrão; campo obrigatório lança. A distinção é uma decisão de produto. |
| `TrilhaService` recebendo `http.Client` no construtor | É **isto** que torna a camada testável. Criar o cliente por dentro tornaria o teste impossível sem rede. |
| `abstract interface class TrilhaRepositorioContrato` | Só implementável, nunca estendível. O tipo que a presentation conhece. |
| `_traduzindoErros<T>(...)` | Um lugar só para converter exceção técnica em `Falha`. Sem ele, cada método repetiria o mesmo `try/catch`. |
| `Error.throwWithStackTrace(const FalhaDeConexao(), pilha)` | Lança a falha **com a pilha original**, não com a do `catch`. Essencial para depurar. |
| `switch (e.statusCode) { 401 \|\| 403 => …, >= 500 => … }` | *Switch expression* com padrão relacional. Módulo 04, aula 5. |
| `sealed class Falha` com `podeRepetir` | A tela decide se mostra "Tentar de novo" perguntando à falha — não com um `if` de status HTTP. |
| `FalhaDeFormato` com `detalhe` separado de `mensagem` | `detalhe` vai para o log; `mensagem` vai para o usuário. Nunca inverta. |
| `Provider<TrilhaRepositorioContrato>` (o **contrato**) | É este tipo que permite `overrideWithValue(repoFalso)` nos testes. |
| `MockClient((req) async => …)` | Vem no pacote `http`. Você escreve a função que responde. Sem dependência extra. |
| `fixture('trilhas_200.json')` | JSON **real**, copiado da API. Um JSON inventado à mão não tem os casos que quebram. |
| `class TrilhaApiMock extends Mock implements TrilhaApi {}` | `mocktail` em uma linha. Sem `build_runner`, sem `.mocks.dart`. |
| `registerFallbackValue(...)` no `setUpAll` | Necessário quando `any()` é usado com tipo customizado. |
| `verify(() => api.criar(captureAny())).captured.single` | Captura **o que foi enviado**. É o que o `mocktail` faz e o `MockClient` não faz com a mesma clareza. |
| `expect(falha.mensagem, isNot(contains('Exception')))` | Teste de **qualidade de mensagem**: garante que nenhum jargão técnico vaze para o usuário. |
| `expectLater(api.excluir('1'), completes)` | Verifica que não lança — a forma certa de testar "404 no DELETE é sucesso". |

---

## ⚠️ Erros comuns

### 1. Criar o `http.Client` dentro do service

```dart
class TrilhaApi {
  final http.Client _cliente = http.Client();   // ❌
}
```

Impossível testar sem rede.

**Correção:** receba pelo construtor.

### 2. Usar o DTO como modelo de domínio

```dart
class Trilha {
  final int userId;   // ⚠️ conceito do backend, não do app
}
```

Quando a API mudar, o app inteiro muda junto.

**Correção:** DTO em `data`, modelo em `domain`, conversão no repositório.

### 3. `as` direto no `fromJson`

```dart
id: json['id'] as int,   // ❌
```

```text
type 'Null' is not a subtype of type 'int' in type cast
```

Não diz qual campo, não diz o que veio.

**Correção:** `if (id is! int) throw FormatException('Campo "id"…')`.

### 4. Repositório deixando `ApiException` vazar

```dart
Future<List<Trilha>> listar() async {
  final List<TrilhaDto> dtos = await _api.listar();   // ❌ sem try/catch
  return dtos.map(_paraDominio).toList();
}
```

O controller e a tela passam a conhecer HTTP — e a regra de dependência do
[Módulo 08, aula 9](../08-estado-e-arquitetura/09-arquitetura-feature-first.md) é quebrada.

**Correção:** traduza para `Falha` no repositório.

### 5. Mensagem de erro com jargão

```dart
throw Exception('SocketException: Failed host lookup');   // ❌
```

O usuário não sabe o que fazer com isso — e pode ver o endereço do seu servidor.

**Correção:** `FalhaDeConexao` com mensagem de gente; detalhe técnico só no log.

### 6. Testar só o caminho feliz

```dart
test('lista funciona', () async { … });   // ⚠️ e 500? e timeout? e JSON quebrado?
```

O caminho feliz nunca é o que quebra em produção.

**Correção:** `200`, `4xx`, `5xx`, timeout, sem rede e JSON malformado — sempre.

### 7. JSON inventado à mão no teste

```dart
const String json = '[{"id":1,"title":"x"}]';   // ⚠️ limpo demais
```

A API real manda campos extras, `null` inesperados e datas em formatos estranhos.

**Correção:** `curl` na API e salve a resposta como fixture.

### 8. Esquecer `registerFallbackValue` com `mocktail`

```text
Bad state: A test tried to use `any` or `captureAny` on a parameter
of type `TrilhaDto`, but registerFallbackValue was not previously called
```

**Correção:** `registerFallbackValue(const TrilhaDto(...))` no `setUpAll`.

### 9. Provider tipado com a classe concreta

```dart
final Provider<TrilhaRepositorio> repo = ...;   // ❌
```

Não dá para substituir por um falso nos testes.

**Correção:** `Provider<TrilhaRepositorioContrato>`.

### 10. Testar a implementação em vez do comportamento

```dart
verify(() => api.listar()).called(1);   // ⚠️ e se otimizarmos com cache?
```

O teste passa a proibir melhorias.

**Correção:** verifique o **resultado**; verifique chamadas só quando a chamada **é** o
comportamento (como `excluir` ter sido chamado).

### 11. Service devolvendo modelo de domínio

```dart
Future<List<Trilha>> listar();   // ⚠️ no service
```

O service passa a conhecer o domínio, e a conversão fica no lugar errado.

**Correção:** service devolve **DTO**; repositório devolve **domínio**.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test` e confirme todos passando. Anote o tempo total.

**Passo 2.** Gere a sua própria fixture:
`curl.exe -s "https://jsonplaceholder.typicode.com/posts?_limit=2" > test/fixtures/minha.json`.
Compare com a que está no curso.

**Passo 3.** Em `TrilhaDto.fromJson`, troque a validação de `title` por `json['title'] as String`.
Rode o teste de campo ausente e compare a mensagem de erro.

**Passo 4.** Em `_traduzindoErros`, remova o `on SocketException`. Rode os testes e veja qual falha.
O que o controller receberia agora?

**Passo 5.** Acrescente um caso `>= 300 && < 400` ao `_daApi`. O compilador reclama de algo? Por
quê? (Dica: pense no `sealed`.)

**Passo 6.** Escreva um teste que confirme que `buscar` envia o termo como parâmetro de consulta na
URL. Use `MockClient` e capture `req.url.queryParameters`.

**Passo 7.** Faça `TrilhaApi` criar o próprio `http.Client` internamente. Rode os testes e observe
o que acontece.

**Passo 8.** No teste de qualidade de mensagem, acrescente `FalhaDeLimite` e `FalhaInesperada` à
lista. Todas passam?

**Passo 9.** Crie `TrilhaRepositorioFalso` que implementa o contrato devolvendo dados fixos. Use-o
num `ProviderScope(overrides: ...)` e rode o app. Quantos arquivos de `presentation` você tocou?

**Passo 10.** Responda por escrito: se o backend mudar `title` para `name`, quais arquivos você
precisa editar? E se você não tivesse DTO?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Faça os exercícios de **Aplicação** com service + repository, o de **Correção de bugs** com
`ApiException` vazando, e o de **Decisão** sobre quando o DTO compensa.

---

## 🏆 Desafio opcional

Escreva uma **suíte de contrato** para `TrilhaRepositorioContrato`, no espírito do desafio do
[Módulo 08, aula 10](../08-estado-e-arquitetura/10-injecao-de-dependencias.md).

```dart
void testarContratoDeTrilhaRepositorio(
  String nome,
  TrilhaRepositorioContrato Function() criar,
) {
  group('contrato · $nome', () {
    test('listar devolve trilhas com id não vazio', () async { … });
    test('criar devolve a trilha com id do servidor', () async { … });
    test('excluir id inexistente não lança', () async { … });
    test('toda falha é uma Falha, nunca ApiException', () async { … });
  });
}
```

Requisitos:

- A mesma suíte roda contra a implementação HTTP (com `MockClient`) e contra uma implementação
  falsa em memória.
- Um teste verifica que **nenhuma** exceção técnica escapa: tudo que sobe é `Falha`.
- Um teste verifica que **nenhuma** mensagem de falha contém jargão.
- No [Módulo 10](../10-persistencia-de-dados/05-sqflite-crud.md), a implementação SQLite entra na
  mesma suíte sem alteração.

Depois responda: o seu repositório falso passa **exatamente** nos mesmos testes que o HTTP? Se não,
ele está mentindo — e um dia vai esconder um bug que só aparece em produção.

---

## 📌 Resumo

- **Service** fala HTTP e devolve **DTO**; **repository** fala domínio, converte e traduz erros.
- **DTO espelha a API**; **modelo de domínio** representa o conceito do app. Separá-los faz uma
  mudança de API tocar **um** arquivo.
- O sintoma de que faltava DTO: um campo do modelo existe "porque a API manda".
- **Injete o `http.Client` pelo construtor.** É isso que torna a camada testável sem rede.
- O contrato fica no **`domain`**; a implementação, no **`data`**. O provider é tipado com o
  **contrato**.
- No `fromJson`, **valide** cada campo obrigatório com `is!` e lance `FormatException` dizendo
  **qual** campo falhou. Campos opcionais ganham padrão.
- O repositório **traduz toda exceção técnica em `Falha`**. Depois dele, nada que sobe conhece HTTP.
- Use `Error.throwWithStackTrace` para preservar a pilha original.
- **`MockClient`** (vem no `http`) para testar o service; **`mocktail`** quando precisar
  **verificar** chamadas. `mocktail` não precisa de geração de código.
- **Fixtures são JSON reais**, copiados da API — não inventados à mão.
- Teste sempre: `200`, `4xx`, `5xx`, timeout, sem rede e JSON malformado.
- Teste também a **qualidade das mensagens**: nenhuma pode conter jargão técnico.
- Verifique **resultado**, não implementação — exceto quando a chamada **é** o comportamento.

---

## ☑️ Checklist de domínio

- [ ] Separo service de repository e justifico a divisão.
- [ ] Escrevo DTO separado do modelo de domínio.
- [ ] Sei dizer quando pular o DTO é aceitável.
- [ ] Injeto o `http.Client` pelo construtor.
- [ ] Declaro o contrato no `domain` e tipo o provider com ele.
- [ ] Valido cada campo no `fromJson` com mensagem específica.
- [ ] Traduzo toda exceção técnica em `Falha` no repositório.
- [ ] Preservo a pilha original com `Error.throwWithStackTrace`.
- [ ] Uso `MockClient` para service e `mocktail` para repositório.
- [ ] Minhas fixtures vêm da API real.
- [ ] Testo `200`, `4xx`, `5xx`, timeout, sem rede e JSON quebrado.
- [ ] Nenhuma mensagem de erro do meu app tem jargão técnico.
- [ ] `flutter analyze` e `flutter test` passam limpos.

---

## 📚 Referências oficiais

- [Testing Flutter apps — docs.flutter.dev](https://docs.flutter.dev/testing/overview)
- [Mock dependencies using Mockito — docs.flutter.dev](https://docs.flutter.dev/cookbook/testing/unit/mocking)
- [mocktail — pub.dev](https://pub.dev/packages/mocktail)
- [package:http/testing.dart — pub.dev](https://pub.dev/documentation/http/latest/testing/testing-library.html)
- [Parse JSON in the background — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/background-parsing)
- [Effective Dart: Design — dart.dev](https://dart.dev/effective-dart/design)
- [Flutter architecture guide — docs.flutter.dev](https://docs.flutter.dev/app-architecture/guide)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Timeout, retry e cancelamento](06-timeout-retry-cancelamento.md) | [README](README.md) | [Aula 8 — Autenticação e tokens](08-autenticacao-e-tokens.md) |
