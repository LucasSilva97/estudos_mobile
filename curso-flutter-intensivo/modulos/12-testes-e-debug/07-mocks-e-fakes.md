# Aula 7 — Mocks e fakes

> **Módulo:** 12 - Testes e Debug · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Distinguir **dummy, stub, fake, spy e mock** — e saber quando usar cada um.
- Escrever **mocks com mocktail**, sem geração de código.
- Usar **`when`**, **`verify`**, **`verifyNever`**, **`captureAny`** e **`registerFallbackValue`**.
- Escrever um **fake à mão** e entender por que ele costuma ser melhor que o mock.
- Simular HTTP com **`MockClient`** e banco com **fake em memória**.
- Testar controllers Riverpod com **`ProviderContainer`**, sem montar tela.
- Rodar testes contra um **banco sqflite de verdade** com `sqflite_common_ffi`.
- Reconhecer o **teste que testa o mock** — o erro mais comum e mais inútil.
- Decidir **o que dublar e o que não dublar**.

## ✅ Pré-requisitos

- [Aula 6 — Testes de widget](06-testes-de-widget.md) — o `RepositorioFalso` de lá é o ponto de
  partida desta aula.
- [Módulo 09, aula 7 — Camada de dados testável](../09-consumo-de-api/07-camada-de-dados-testavel.md)
  — `MockClient` e a separação DTO/domínio.
- [Módulo 08, aula 10 — Injeção de dependências](../08-estado-e-arquitetura/10-injecao-de-dependencias.md)
  — sem injeção, não há como dublar nada.
- `mocktail: ^1.0.5` já em `dev_dependencies` (Módulo 09, aula 7).

---

## 📖 Conceito

### O problema

Um teste precisa ser **rápido**, **determinístico** e **isolado**. Uma dependência real quebra as
três coisas:

| Dependência real | O que quebra |
|---|---|
| API HTTP | Lenta; falha sem internet; o servidor muda |
| Banco de dados | Lento; estado sobrevive entre testes |
| `DateTime.now()` | O teste passa hoje e falha amanhã |
| `Random()` | Passa 9 vezes e falha na décima |
| Câmera, GPS, notificação | Não existem no ambiente de teste |

A solução é substituir a dependência por um **dublê** (*test double*) — uma implementação de
mentira que você controla.

### Os cinco tipos de dublê

Os nomes vêm do vocabulário de Gerard Meszaros, e vale conhecê-los porque as bibliotecas os usam:

| Tipo | O que é | Exemplo |
|---|---|---|
| **Dummy** | Só ocupa o lugar; nunca é usado | Um `Logger` que ignora tudo |
| **Stub** | Devolve respostas prontas | `when(() => repo.listar()).thenAnswer((_) async => [])` |
| **Fake** | Implementação **funcionando**, simplificada | Repositório que guarda numa `List` |
| **Spy** | Registra as chamadas para conferência | Um fake que conta quantas vezes foi chamado |
| **Mock** | Stub + spy, com verificação de interação | `verify(() => repo.excluir('dart')).called(1)` |

Na prática, no dia a dia, você usa dois:

```dart
// FAKE — escrito à mão, funcionando.
class MateriaRepositorioFake implements MateriaRepositorioContrato {
  final List<Materia> _itens = <Materia>[];

  @override
  Future<List<Materia>> listar() async => List<Materia>.from(_itens);

  @override
  Future<Materia> salvar(Materia m) async { _itens.add(m); return m; }
}

// MOCK — gerado pela biblioteca, sem comportamento próprio.
class MateriaRepositorioMock extends Mock
    implements MateriaRepositorioContrato {}
```

### Fake ou mock?

Esta é a decisão que mais afeta a qualidade dos seus testes.

| | Fake | Mock |
|---|---|---|
| Escrita | À mão, ~30 linhas | 1 linha |
| Setup em cada teste | Quase nenhum | `when(...)` para cada método |
| Comportamento | Real (simplificado) | Nenhum — você dita tudo |
| Detecta erro de uso | ✅ (salvar → listar reflete) | ❌ |
| Acopla ao contrato | ✅ (compilador cobra) | ✅ |
| Acopla à **implementação** | ❌ | ⚠️ `verify` acopla |
| Reutilizável | ✅ Muito | ⚠️ Por teste |
| Bom para | Repositórios, storage, cache | Efeitos colaterais, envio |

> 💡 **A regra prática deste curso: prefira o fake.** Escreva um fake para cada contrato
> (repositório, storage, serviço) e reutilize-o na suíte inteira. Use mock quando o que importa é
> **se a chamada aconteceu**, não o que ela devolveu — enviar um e-mail, gravar um log de analytics,
> disparar uma notificação.

A razão profunda: um fake testa **o resultado**; um mock testa **o caminho**. Testar o caminho
amarra o teste à implementação — refatore o código sem mudar o comportamento, e o teste quebra sem
que nada esteja errado.

### mocktail, sem geração de código

Este curso usa **mocktail**, não mockito, pela mesma razão que usa Riverpod sem codegen (ADR-01):
nada de `build_runner`, nada de arquivos gerados.

```dart
import 'package:mocktail/mocktail.dart';

class MateriaRepositorioMock extends Mock
    implements MateriaRepositorioContrato {}
```

Pronto. Sem anotação, sem `dart run build_runner build`, sem `.mocks.dart`.

**Stub — dizer o que devolver:**

```dart
final repo = MateriaRepositorioMock();

// Future → thenAnswer
when(() => repo.listar()).thenAnswer((_) async => <Materia>[m1, m2]);

// Valor síncrono → thenReturn
when(() => repo.contarLocal()).thenReturn(2);

// Lançar
when(() => repo.listar()).thenThrow(Exception('sem rede'));

// Resposta que depende do argumento
when(() => repo.buscar(any())).thenAnswer((Invocation i) async {
  final String id = i.positionalArguments.first as String;
  return id == 'dart' ? m1 : null;
});
```

> ⚠️ **`thenReturn` com `Future` é uma armadilha.** `when(...).thenReturn(Future.value(x))`
> compila, mas o `Future` é criado **uma vez** e reutilizado — e um `Future` já completado se
> comporta de forma estranha em sequência. **Use sempre `thenAnswer` para métodos assíncronos.**

**Verify — conferir que a chamada aconteceu:**

```dart
verify(() => repo.excluir('dart')).called(1);
verify(() => repo.salvar(any())).called(greaterThan(0));
verifyNever(() => repo.excluir(any()));
verifyInOrder(<void Function()>[
  () => repo.listar(),
  () => repo.salvar(any()),
]);
verifyNoMoreInteractions(repo);
```

**Capturar argumentos:**

```dart
final List<Materia> capturadas =
    verify(() => repo.salvar(captureAny())).captured.cast<Materia>();

expect(capturadas.single.nome, 'Cálculo I');
```

`captureAny` é o que salva o `verify` de ser inútil: em vez de "foi chamado", você confere **com o
quê**.

**`registerFallbackValue` — o erro mais confuso do mocktail:**

```text
Bad state: A test tried to use `any` or `captureAny` on a parameter
of type `Materia`, but registerFallbackValue was not previously called
to register a fallback value for `Materia`.
```

O mocktail precisa de um valor qualquer do tipo para conseguir montar a chamada de referência.
Tipos primitivos (`String`, `int`, `bool`) já vêm registrados; os seus, não:

```dart
class MateriaFalsa extends Fake implements Materia {}

void main() {
  setUpAll(() {
    // setUpAll, não setUp: registra UMA vez para o arquivo inteiro.
    registerFallbackValue(MateriaFalsa());
  });
  // …
}
```

> 📌 `extends Fake` (do mocktail) é o atalho: ele permite implementar a interface **sem** escrever
> nenhum membro. Qualquer acesso lança — o que é exatamente o que você quer num valor que nunca
> deve ser usado de verdade.

### O teste que testa o mock

O erro mais comum desta aula:

```dart
test('listar devolve as matérias', () async {
  final repo = MateriaRepositorioMock();
  when(() => repo.listar()).thenAnswer((_) async => <Materia>[m1]);

  final List<Materia> r = await repo.listar();

  expect(r, <Materia>[m1]);   // ❌ testou o mocktail, não o seu código
});
```

Este teste sempre passa. Ele verifica que o mocktail devolve o que você mandou devolver — algo que
o mocktail já garante. **Nenhuma linha do seu código foi executada.**

> ⚠️ **O sinal de alerta:** se o teste não instancia nenhuma classe **sua**, ele não testa nada.
> O dublê é a dependência, nunca o sujeito do teste.

A versão correta:

```dart
test('o controller expõe as matérias em ordem alfabética', () async {
  final repo = MateriaRepositorioMock();
  when(() => repo.listar()).thenAnswer((_) async => <Materia>[flutter, dart]);

  // ← O SUJEITO do teste é o controller, código MEU.
  final container = ProviderContainer(
    overrides: <Override>[materiaRepositorioProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);

  final List<Materia> r =
      await container.read(materiasControllerProvider.future);

  expect(r.map((Materia m) => m.nome), <String>['Dart', 'Flutter']);
});
```

### O que **não** dublar

| Não duble | Por quê |
|---|---|
| Objetos de valor (`Materia`, `Sessao`) | São dados. Construa-os de verdade. |
| Funções puras | Não têm efeito colateral. |
| Classes da linguagem (`List`, `DateTime`) | Injete um valor, não um dublê. |
| Código que você **está testando** | Óbvio, mas acontece. |
| Widgets do Flutter | Use teste de widget. |

> 💡 **Duble o que atravessa a fronteira**: rede, disco, relógio, sorteio, sistema operacional.
> Dentro da fronteira, use objetos reais — eles são rápidos e testam mais.

---

## 💡 Analogia

Pense num **simulador de voo** para treinar um piloto.

- **Dummy** é o cinzeiro do painel: existe porque o painel tem um, e ninguém nunca usa.
- **Stub** é a tela do radar mostrando uma imagem gravada: sempre a mesma montanha, na mesma
  posição. Serve para treinar a reação.
- **Fake** é o motor simulado: **funciona de verdade** — acelera, esquenta, consome combustível —
  só que em software, não em metal. Se o piloto acelerar demais, ele reage como o motor reagiria.
- **Spy** é a caixa-preta: grava tudo que o piloto fez, para conferir depois.
- **Mock** é o instrutor de prancheta que já disse antes do voo: "você **vai** acionar o extintor
  do motor 2, exatamente uma vez" — e reprova se você não acionar.

E daí saem as duas decisões da aula:

- **Fake é melhor na maioria dos casos** porque testa **o resultado**: o avião chegou? O motor
  simulado deixa o piloto descobrir sozinho que acelerou demais. O mock não — ele só sabe se o
  botão foi apertado.
- **Mock é melhor para efeito colateral**: "disparou o sinal de socorro?" não tem resultado
  observável dentro do simulador. Só dá para verificar **se a chamada aconteceu**.
- **O teste que testa o mock** é treinar o piloto no radar de imagem gravada e concluir, ao fim,
  que **a imagem gravada está correta**. Claro que está — você gravou. O piloto não foi avaliado.

---

## 🧪 Exemplo mínimo

O mesmo teste escrito das duas formas, lado a lado.

> **Arquivo:** `foco_lab/test/comparacao_fake_mock_test.dart` (novo)
> **Como executar:** `flutter test test/comparacao_fake_mock_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:foco_lab/dominio/materia.dart';
import 'package:foco_lab/features/materias/domain/materia_repositorio_contrato.dart';
import 'package:foco_lab/features/materias/domain/materia_servico.dart';

// ══════════════════════════════════════════════════════════════════
// Opção A — FAKE, escrito à mão.
// ══════════════════════════════════════════════════════════════════

/// Repositório em memória, FUNCIONANDO.
///
/// ~40 linhas escritas uma vez, reutilizadas na suíte inteira.
class MateriaRepositorioFake implements MateriaRepositorioContrato {
  final Map<String, Materia> _itens = <String, Materia>{};

  /// Controles de teste — a parte que um repositório real não tem.
  Duration atraso = Duration.zero;
  Object? falha;

  /// Spy embutido: conta as chamadas, sem precisar de mock.
  int chamadasDeListar = 0;

  Future<void> _preparar() async {
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);
    final Object? f = falha;
    if (f != null) throw f;
  }

  /// Semeia dados sem passar pelas regras — só para o teste.
  void semear(List<Materia> iniciais) {
    for (final Materia m in iniciais) {
      _itens[m.id] = m;
    }
  }

  @override
  Future<List<Materia>> listar() async {
    chamadasDeListar++;
    await _preparar();
    return _itens.values.toList();
  }

  @override
  Future<Materia> salvar(Materia m) async {
    await _preparar();
    _itens[m.id] = m;
    return m;
  }

  @override
  Future<void> excluir(String id) async {
    await _preparar();
    _itens.remove(id);
  }
}

// ══════════════════════════════════════════════════════════════════
// Opção B — MOCK, gerado pelo mocktail.
// ══════════════════════════════════════════════════════════════════

class MateriaRepositorioMock extends Mock
    implements MateriaRepositorioContrato {}

/// Valor de referência para `any()` e `captureAny()`.
///
/// `extends Fake` permite implementar Materia sem escrever
/// nenhum membro: qualquer acesso lança, o que é o desejado.
class MateriaFalsa extends Fake implements Materia {}

// ══════════════════════════════════════════════════════════════════

void main() {
  setUpAll(() {
    // setUpAll: UMA vez para o arquivo inteiro.
    registerFallbackValue(MateriaFalsa());
  });

  Materia materia(String id, String nome) => Materia(
        id: id,
        nome: nome,
        minutos: 0,
        metaMinutos: 60,
        criadaEm: DateTime(2026, 3, 10),
      );

  // ────────────────────────────────────────────────────────────────
  group('com FAKE', () {
    late MateriaRepositorioFake repo;
    late MateriaServico servico;

    setUp(() {
      repo = MateriaRepositorioFake();
      servico = MateriaServico(repo);
    });

    test('criar guarda a matéria', () async {
      await servico.criar('Cálculo I', metaMinutos: 90);

      // Verifico o RESULTADO: listar devolve o que foi criado.
      // Nenhum `when`, nenhum setup. O fake simplesmente funciona.
      final List<Materia> r = await repo.listar();
      expect(r, hasLength(1));
      expect(r.single.nome, 'Cálculo I');
      expect(r.single.metaMinutos, 90);
    });

    test('não cria duplicata', () async {
      await servico.criar('Cálculo I');

      // O fake DETECTA o erro: como ele guarda de verdade, a segunda
      // chamada encontra a primeira. Um mock não perceberia nada.
      await expectLater(
        servico.criar('cálculo i'),
        throwsA(isA<MateriaDuplicada>()),
      );

      expect(await repo.listar(), hasLength(1));
    });

    test('excluir remove de verdade', () async {
      repo.semear(<Materia>[materia('dart', 'Dart')]);

      await servico.excluir('dart');

      expect(await repo.listar(), isEmpty);
    });

    test('propaga a falha do repositório', () async {
      repo.falha = Exception('sem conexão');

      await expectLater(servico.criar('Dart'), throwsException);
    });
  });

  // ────────────────────────────────────────────────────────────────
  group('com MOCK', () {
    late MateriaRepositorioMock repo;
    late MateriaServico servico;

    setUp(() {
      repo = MateriaRepositorioMock();
      servico = MateriaServico(repo);

      // ⚠️ TODO método usado precisa de `when` — senão, devolve null
      // e estoura com "type 'Null' is not a subtype of 'Future<…>'".
      when(() => repo.listar()).thenAnswer((_) async => <Materia>[]);
      when(() => repo.salvar(any()))
          .thenAnswer((Invocation i) async => i.positionalArguments.first as Materia);
      when(() => repo.excluir(any())).thenAnswer((_) async {});
    });

    test('criar chama salvar com os dados certos', () async {
      await servico.criar('Cálculo I', metaMinutos: 90);

      // captureAny: confiro COM O QUÊ foi chamado, não só QUE foi.
      final List<Materia> cap = verify(() => repo.salvar(captureAny()))
          .captured
          .cast<Materia>();

      expect(cap, hasLength(1));
      expect(cap.single.nome, 'Cálculo I');
      expect(cap.single.metaMinutos, 90);
    });

    test('não cria duplicata', () async {
      // Com mock, preciso MONTAR o cenário à mão…
      when(() => repo.listar())
          .thenAnswer((_) async => <Materia>[materia('c', 'Cálculo I')]);

      await expectLater(
        servico.criar('cálculo i'),
        throwsA(isA<MateriaDuplicada>()),
      );

      // …e verificar que NÃO salvou.
      verifyNever(() => repo.salvar(any()));
    });

    test('consulta a lista ANTES de salvar', () async {
      await servico.criar('Dart');

      // verifyInOrder: acopla à IMPLEMENTAÇÃO.
      // Se eu inverter a ordem no código sem mudar o comportamento,
      // este teste quebra à toa. Use com parcimônia.
      verifyInOrder(<void Function()>[
        () => repo.listar(),
        () => repo.salvar(any()),
      ]);
    });
  });

  // ────────────────────────────────────────────────────────────────
  group('o teste que NÃO testa nada', () {
    test('ANTIPADRÃO: verifica o próprio mock', () async {
      final MateriaRepositorioMock repo = MateriaRepositorioMock();
      when(() => repo.listar())
          .thenAnswer((_) async => <Materia>[materia('dart', 'Dart')]);

      final List<Materia> r = await repo.listar();

      // ❌ Este expect verifica que o mocktail devolve o que mandei
      // devolver. Nenhuma linha do MEU código rodou.
      //
      // O sinal: o teste não instancia NENHUMA classe minha.
      expect(r.single.nome, 'Dart');
    }, skip: 'exemplo do que NÃO fazer');
  });
}
```

Rode e compare:

```powershell
flutter test test/comparacao_fake_mock_test.dart
```

**O que observar:**

| | Fake | Mock |
|---|---|---|
| `setUp` | 2 linhas | 6 linhas, e cresce a cada método |
| "não cria duplicata" | O cenário **se monta sozinho** | Preciso montar com `when` |
| Detecta que salvou errado | ✅ | ❌ (a não ser com `captureAny`) |
| Quebra se eu refatorar sem mudar comportamento | ❌ | ⚠️ com `verifyInOrder` |

---

## 📱 Aplicando no Flutter

Duas situações que aparecem em todo projeto Flutter e merecem tratamento próprio.

### Riverpod: `ProviderContainer` em teste sem widget

Para testar um controller **sem montar tela nenhuma**, use `ProviderContainer` — o equivalente ao
`ProviderScope`, mas em Dart puro:

```dart
test('o controller ordena as matérias por nome', () async {
  final MateriaRepositorioFake repo = MateriaRepositorioFake()
    ..semear(<Materia>[materia('f', 'Flutter'), materia('d', 'Dart')]);

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      materiaRepositorioProvider.overrideWithValue(repo),
    ],
  );
  // ⚠️ addTearDown junto da criação: sem o dispose, os providers
  // ficam vivos entre testes e a suíte falha em ordem aleatória.
  addTearDown(container.dispose);

  final List<Materia> r =
      await container.read(materiasControllerProvider.future);

  expect(r.map((Materia m) => m.nome), <String>['Dart', 'Flutter']);
});
```

Para observar as **transições de estado** — o que um `expect` no fim não pega:

```dart
test('passa por carregando antes de sucesso', () async {
  final MateriaRepositorioFake repo = MateriaRepositorioFake()
    ..atraso = const Duration(milliseconds: 50);

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      materiaRepositorioProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);

  final List<AsyncValue<List<Materia>>> estados =
      <AsyncValue<List<Materia>>>[];

  // listen com fireImmediately: captura o estado INICIAL também.
  container.listen(
    materiasControllerProvider,
    (_, AsyncValue<List<Materia>> novo) => estados.add(novo),
    fireImmediately: true,
  );

  await container.read(materiasControllerProvider.future);

  expect(estados.first, isA<AsyncLoading<List<Materia>>>());
  expect(estados.last, isA<AsyncData<List<Materia>>>());
});
```

> 💡 `ProviderContainer` roda em **teste unitário** (`flutter test`, ~1 ms), não em teste de widget.
> Sempre que a regra estiver no controller e não na tela, este é o teste certo — mais rápido e mais
> fácil de ler que um `testWidgets`.

### sqflite: banco de verdade no teste, com `sqflite_common_ffi`

Nem sempre vale escrever um fake de banco. Às vezes o que você quer testar **é o SQL** — e aí um
fake não serve para nada: ele testaria o seu Dart, não a sua query.

```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Sem estas duas linhas, `openDatabase` falha no desktop com
    // "databaseFactory not initialized".  Módulo 10, aula 4.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late BancoFoco banco;

  setUp(() async {
    // inMemoryDatabasePath: um banco novo e VAZIO por teste,
    // sem arquivo em disco e sem estado vazando.
    banco = BancoFoco();
    await banco.abrir(caminho: inMemoryDatabasePath);
  });

  tearDown(() async => banco.fechar());

  test('ORDER BY ignora o acento com nome_ordenacao', () async {
    await banco.inserirMateria(nome: 'Ética');
    await banco.inserirMateria(nome: 'Dart');
    await banco.inserirMateria(nome: 'Física');

    final List<String> nomes = await banco.listarNomes();

    // Sem a coluna achatada, o SQLite devolveria
    // ['Dart', 'Física', 'Ética'] — porque compara bytes, não letras.
    expect(nomes, <String>['Dart', 'Ética', 'Física']);
  });

  test('a migração da v1 para a v2 preserva os dados', () async {
    // Este teste vale por dez: migração quebrada apaga os dados
    // do usuário, e é o tipo de bug que só aparece em produção.
    await banco.fechar();
    await banco.abrir(caminho: inMemoryDatabasePath, versao: 1);
    await banco.inserirMateria(nome: 'Dart');

    await banco.fechar();
    await banco.abrir(caminho: inMemoryDatabasePath, versao: 2);

    final List<String> nomes = await banco.listarNomes();
    expect(nomes, <String>['Dart']);
  });
}
```

| | Fake em memória | `sqflite_common_ffi` |
|---|---|---|
| Velocidade | ~1 ms | ~20 ms |
| Testa o **SQL** | ❌ | ✅ |
| Testa **migrações** | ❌ | ✅ |
| Testa o bug do acento | ❌ | ✅ |
| Bom para | Testar quem **usa** o repositório | Testar o **repositório** |

> 📌 **A regra:** use `sqflite_common_ffi` nos testes **do repositório**; use o fake nos testes de
> **tudo que depende dele**. Um banco real em cada teste de tela deixaria a suíte lenta sem
> aumentar a confiança.

---

## 💻 Código completo

> **Arquivo:** `foco_lab/test/apoio/dubles.dart` (novo)
>
> Um arquivo de apoio, importado por toda a suíte. Escrever os dublês **uma vez**, num lugar só, é
> o que torna o resto dos testes curto.

```dart
import 'dart:convert';

import 'package:foco_lab/dominio/materia.dart';
import 'package:foco_lab/dominio/relogio.dart';
import 'package:foco_lab/features/materias/domain/materia_repositorio_contrato.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

// ══════════════════════════════════════════════════════════════════
// 1. RELÓGIO — o dublê mais simples e mais esquecido.
// ══════════════════════════════════════════════════════════════════

/// Relógio de teste: o tempo só anda quando você manda.
///
/// Sem isto, todo teste que envolve data é uma bomba-relógio:
/// passa hoje, falha na virada do mês, do ano ou no horário de verão.
class RelogioFake implements Relogio {
  RelogioFake([DateTime? inicio])
      : _agora = inicio ?? DateTime(2026, 3, 10, 14, 30);

  DateTime _agora;

  @override
  DateTime get agora => _agora;

  /// Avança o relógio — para testar expiração, cache, streak.
  void avancar(Duration d) => _agora = _agora.add(d);

  /// Salta para uma data exata.
  void definir(DateTime quando) => _agora = quando;
}

// ══════════════════════════════════════════════════════════════════
// 2. HTTP — MockClient, do próprio pacote http.
// ══════════════════════════════════════════════════════════════════

/// Constrói um cliente HTTP falso a partir de um mapa de rotas.
///
/// Não precisa de mocktail: o pacote `http` já traz o MockClient,
/// que é um fake de verdade — ele roda a função que você der.
///
/// ```dart
/// final http.Client c = clienteFalso(<String, Object>{
///   'GET /materias': <Map<String, Object?>>[
///     <String, Object?>{'id': 'dart', 'nome': 'Dart'},
///   ],
///   'POST /materias': (RespostaConfig r) => r..status = 201,
/// });
/// ```
http.Client clienteFalso(
  Map<String, Object?> rotas, {
  Duration atraso = Duration.zero,
  int Function(String chave)? status,
}) {
  return MockClient((http.Request req) async {
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);

    final String chave = '${req.method} ${req.url.path}';
    final int codigo = status?.call(chave) ?? 200;

    if (!rotas.containsKey(chave)) {
      // 404 explícito é melhor que uma exceção obscura: o teste
      // falha dizendo qual rota faltou configurar.
      return http.Response(
        jsonEncode(<String, String>{'erro': 'rota não configurada: $chave'}),
        404,
        headers: <String, String>{'content-type': 'application/json'},
      );
    }

    return http.Response(
      jsonEncode(rotas[chave]),
      codigo,
      headers: <String, String>{'content-type': 'application/json'},
    );
  });
}

/// Cliente que SEMPRE falha — para testar o caminho de erro.
http.Client clienteQueFalha(Object erro) =>
    MockClient((http.Request _) async => throw erro);

/// Cliente que NUNCA responde — para testar timeout.
///
/// ⚠️ Só use com `pump(duration)` no teste, senão o Future fica
/// pendente e o teste falha com "A Timer is still pending".
http.Client clienteQueTrava() => MockClient(
      (http.Request _) =>
          Future<http.Response>.delayed(const Duration(days: 1)),
    );

// ══════════════════════════════════════════════════════════════════
// 3. REPOSITÓRIO — fake em memória, com controles de teste.
// ══════════════════════════════════════════════════════════════════

/// Repositório de matérias em memória.
///
/// O dublê mais usado da suíte. Reproduz o comportamento real
/// (inclusive a ordenação por nome), mas guarda num Map.
class MateriaRepositorioFake implements MateriaRepositorioContrato {
  MateriaRepositorioFake([List<Materia>? iniciais]) {
    semear(iniciais ?? const <Materia>[]);
  }

  final Map<String, Materia> _itens = <String, Materia>{};

  // ── Controles de teste ──────────────────────────────────────────

  /// Atraso artificial: permite observar o estado de carregamento.
  Duration atraso = Duration.zero;

  /// Quando não é null, toda chamada lança.
  Object? falha;

  /// Falha apenas nas N primeiras chamadas — para testar retry.
  int falharNasPrimeiras = 0;

  // ── Spy embutido ────────────────────────────────────────────────

  int chamadasDeListar = 0;
  final List<Materia> salvas = <Materia>[];
  final List<String> excluidas = <String>[];

  int _chamadas = 0;

  Future<void> _preparar() async {
    _chamadas++;
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);

    if (_chamadas <= falharNasPrimeiras) {
      throw Exception('falha simulada #$_chamadas');
    }
    final Object? f = falha;
    if (f != null) throw f;
  }

  /// Insere dados sem passar pelas regras — só para preparar o teste.
  void semear(List<Materia> iniciais) {
    for (final Materia m in iniciais) {
      _itens[m.id] = m;
    }
  }

  /// Zera tudo, inclusive os contadores.
  void limpar() {
    _itens.clear();
    salvas.clear();
    excluidas.clear();
    chamadasDeListar = 0;
    _chamadas = 0;
    falha = null;
    falharNasPrimeiras = 0;
    atraso = Duration.zero;
  }

  @override
  Future<List<Materia>> listar() async {
    chamadasDeListar++;
    await _preparar();

    // Reproduz a ordenação do repositório real. Se o fake devolvesse
    // em ordem aleatória, os testes de UI ficariam instáveis.
    final List<Materia> r = _itens.values.toList()
      ..sort((Materia a, Materia b) =>
          a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return List<Materia>.unmodifiable(r);
  }

  @override
  Future<Materia> salvar(Materia m) async {
    await _preparar();
    _itens[m.id] = m;
    salvas.add(m);
    return m;
  }

  @override
  Future<void> excluir(String id) async {
    await _preparar();
    if (!_itens.containsKey(id)) {
      // O repositório real lança. O fake também precisa lançar —
      // senão o teste passa e a produção quebra.
      throw MateriaNaoEncontrada(id);
    }
    _itens.remove(id);
    excluidas.add(id);
  }
}

// ══════════════════════════════════════════════════════════════════
// 4. MOCKS — para efeito colateral, onde não há resultado observável.
// ══════════════════════════════════════════════════════════════════

/// Analytics: não devolve nada útil, só registra. Caso clássico
/// de MOCK — o que importa é SE o evento foi disparado.
abstract interface class Analytics {
  Future<void> registrar(String evento, Map<String, Object?> dados);
}

class AnalyticsMock extends Mock implements Analytics {}

class NotificadorMock extends Mock implements Notificador {}

abstract interface class Notificador {
  Future<void> agendar(String titulo, DateTime quando);
  Future<void> cancelar(int id);
}

// ── Valores de referência para any()/captureAny() ──────────────────

class MateriaFalsa extends Fake implements Materia {}

class UriFalsa extends Fake implements Uri {}

/// Chame em `setUpAll` de todo arquivo que usar `any()` com
/// tipos próprios.
void registrarFallbacks() {
  registerFallbackValue(MateriaFalsa());
  registerFallbackValue(UriFalsa());
  registerFallbackValue(DateTime(2026));
  registerFallbackValue(<String, Object?>{});
}
```

E o teste que usa tudo isso:

> **Arquivo:** `foco_lab/test/sincronizador_test.dart` (novo)
> **Como executar:** `flutter test test/sincronizador_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:foco_lab/dominio/materia.dart';
import 'package:foco_lab/features/sync/sincronizador.dart';

import 'apoio/dubles.dart';

void main() {
  setUpAll(registrarFallbacks);

  late MateriaRepositorioFake local;
  late RelogioFake relogio;
  late AnalyticsMock analytics;
  late NotificadorMock notificador;

  Materia materia(String id, String nome) => Materia(
        id: id,
        nome: nome,
        minutos: 0,
        metaMinutos: 60,
        criadaEm: DateTime(2026, 3, 10),
      );

  setUp(() {
    local = MateriaRepositorioFake();
    relogio = RelogioFake(DateTime(2026, 3, 10, 14, 30));
    analytics = AnalyticsMock();
    notificador = NotificadorMock();

    // Mocks precisam de `when` para TODO método usado.
    when(() => analytics.registrar(any(), any())).thenAnswer((_) async {});
    when(() => notificador.agendar(any(), any())).thenAnswer((_) async {});
    when(() => notificador.cancelar(any())).thenAnswer((_) async {});
  });

  Sincronizador criar({Map<String, Object?>? rotas, Duration? atraso}) {
    return Sincronizador(
      local: local,
      cliente: clienteFalso(
        rotas ??
            <String, Object?>{
              'GET /materias': <Map<String, Object?>>[
                <String, Object?>{
                  'id': 'dart',
                  'nome': 'Dart',
                  'minutos': 45,
                  'meta_minutos': 60,
                  'criada_em': '2026-03-01T10:00:00.000Z',
                },
              ],
            },
        atraso: atraso ?? Duration.zero,
      ),
      relogio: relogio,
      analytics: analytics,
      notificador: notificador,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  group('sincronização feliz', () {
    test('grava no local o que veio da rede', () async {
      final Sincronizador s = criar();

      await s.sincronizar();

      // FAKE: verifico o RESULTADO.
      final List<Materia> r = await local.listar();
      expect(r, hasLength(1));
      expect(r.single.nome, 'Dart');
      expect(r.single.minutos, 45);
    });

    test('registra o evento de sucesso', () async {
      final Sincronizador s = criar();

      await s.sincronizar();

      // MOCK: analytics não tem resultado observável.
      // O que importa é SE o evento foi disparado — e com quê.
      final List<dynamic> cap =
          verify(() => analytics.registrar('sync_ok', captureAny())).captured;

      final Map<String, Object?> dados = cap.single as Map<String, Object?>;
      expect(dados['quantidade'], 1);
      // O relógio fake torna isto determinístico.
      expect(dados['quando'], relogio.agora.toIso8601String());
    });

    test('NÃO dispara notificação quando tudo dá certo', () async {
      final Sincronizador s = criar();

      await s.sincronizar();

      verifyNever(() => notificador.agendar(any(), any()));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('falha de rede', () {
    test('mantém os dados locais intactos', () async {
      local.semear(<Materia>[materia('flutter', 'Flutter')]);

      final Sincronizador s = Sincronizador(
        local: local,
        cliente: clienteQueFalha(Exception('sem conexão')),
        relogio: relogio,
        analytics: analytics,
        notificador: notificador,
      );

      await s.sincronizar();

      // A regra mais importante do offline: falhar NÃO apaga.
      expect(await local.listar(), hasLength(1));
    });

    test('registra o evento de falha', () async {
      final Sincronizador s = Sincronizador(
        local: local,
        cliente: clienteQueFalha(Exception('sem conexão')),
        relogio: relogio,
        analytics: analytics,
        notificador: notificador,
      );

      await s.sincronizar();

      verify(() => analytics.registrar('sync_falhou', any())).called(1);
      verifyNever(() => analytics.registrar('sync_ok', any()));
    });

    test('rota não configurada devolve 404 com mensagem clara', () async {
      final Sincronizador s = criar(rotas: <String, Object?>{});

      await s.sincronizar();

      // O 404 explícito do clienteFalso torna o erro DIAGNOSTICÁVEL:
      // "rota não configurada" em vez de um null obscuro.
      expect(s.ultimoErro, contains('404'));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('retry', () {
    test('tenta de novo depois de falhar', () async {
      // Falha nas 2 primeiras chamadas ao LOCAL, sucesso na 3ª.
      local.falharNasPrimeiras = 2;

      final Sincronizador s = criar();

      await s.sincronizarComRetry(maximoDeTentativas: 3);

      expect(s.tentativas, 3);
      expect(s.ultimoErro, isNull);
    });

    test('desiste depois do limite', () async {
      local.falharNasPrimeiras = 99;

      final Sincronizador s = criar();

      await s.sincronizarComRetry(maximoDeTentativas: 3);

      expect(s.tentativas, 3);
      expect(s.ultimoErro, isNotNull);
      verify(() => analytics.registrar('sync_falhou', any())).called(1);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('o relógio controlado', () {
    test('não sincroniza duas vezes em menos de 5 minutos', () async {
      final Sincronizador s = criar();

      await s.sincronizar();
      final int depoisDaPrimeira = local.chamadasDeListar;

      // 2 minutos depois: pula.
      relogio.avancar(const Duration(minutes: 2));
      await s.sincronizar();

      expect(local.chamadasDeListar, depoisDaPrimeira,
          reason: 'deve pular: faz menos de 5 min');

      // 6 minutos: sincroniza.
      relogio.avancar(const Duration(minutes: 6));
      await s.sincronizar();

      expect(local.chamadasDeListar, greaterThan(depoisDaPrimeira));
    });

    test('lembrete é agendado para as 20h do MESMO dia', () async {
      relogio.definir(DateTime(2026, 3, 10, 14, 30));

      final Sincronizador s = criar();
      await s.agendarLembrete();

      final List<dynamic> cap =
          verify(() => notificador.agendar(any(), captureAny())).captured;

      // Determinístico: o relógio é fake. Sem ele, este teste
      // dependeria de QUANDO você o roda.
      expect(cap.single, DateTime(2026, 3, 10, 20));
    });

    test('depois das 20h, agenda para o dia SEGUINTE', () async {
      relogio.definir(DateTime(2026, 3, 10, 21, 15));

      final Sincronizador s = criar();
      await s.agendarLembrete();

      final List<dynamic> cap =
          verify(() => notificador.agendar(any(), captureAny())).captured;

      expect(cap.single, DateTime(2026, 3, 11, 20));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('higiene do mock', () {
    test('não houve interação inesperada com o notificador', () async {
      final Sincronizador s = criar();

      await s.sincronizar();

      // verifyNoMoreInteractions: pega o efeito colateral que você
      // NÃO esperava. Útil aqui; perigoso como hábito — ele quebra
      // a cada linha nova, mesmo inofensiva.
      verifyNoMoreInteractions(notificador);
    });
  });
}
```

```powershell
flutter test test/sincronizador_test.dart
flutter test
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `test/apoio/dubles.dart` | Dublês escritos **uma vez**, reutilizados na suíte. É o que torna cada teste curto. |
| `RelogioFake` | O dublê mais esquecido. Sem ele, todo teste com data passa hoje e falha na virada do ano. |
| `avancar(Duration)` | Testa expiração, cache e streak sem `sleep`. |
| `MockClient` do pacote `http` | Já é um **fake**: roda a função que você der. Não precisa de mocktail para HTTP. |
| 404 explícito na rota não configurada | O teste falha dizendo **qual rota faltou**, em vez de estourar num `null`. |
| `clienteQueTrava()` | Testa timeout. ⚠️ Precisa de `pump(duration)` ou vira Timer pendente. |
| `falharNasPrimeiras` | Permite testar **retry** — impossível com um mock simples. |
| `limpar()` | Evita vazamento entre testes quando o fake é compartilhado. |
| `listar()` ordenando no fake | Se o fake devolvesse fora de ordem, os testes de UI ficariam instáveis. |
| `excluir` lançando `MateriaNaoEncontrada` | **O fake precisa falhar onde o real falha** — senão o teste passa e a produção quebra. |
| `AnalyticsMock` | Caso clássico de mock: sem resultado observável, só interessa **se** foi chamado. |
| `extends Fake implements Materia` | Implementa a interface sem escrever membro nenhum; qualquer acesso lança. |
| `registrarFallbacks()` em `setUpAll` | Evita o erro "registerFallbackValue was not previously called". |
| `captureAny()` em `analytics.registrar` | Confere **com que dados** o evento foi disparado, não só que foi. |
| `verifyNever(() => notificador.agendar(...))` | Verifica uma **ausência** — algo que só o mock faz bem. |
| `verifyNoMoreInteractions` | Pega efeito colateral inesperado. Útil pontualmente; frágil como hábito. |
| "mantém os dados locais intactos" | A regra mais importante do offline, e só o fake consegue verificar. |

---

## ⚠️ Erros comuns

### 1. Esquecer `registerFallbackValue`

```text
Bad state: A test tried to use `any` … but registerFallbackValue
was not previously called for type `Materia`.
```

**Correção:** `setUpAll(() => registerFallbackValue(MateriaFalsa()));`

### 2. `thenReturn` em método assíncrono

```dart
when(() => repo.listar()).thenReturn(Future.value(<Materia>[]));   // ⚠️
```

O `Future` é criado uma vez e reutilizado.

**Correção:** `thenAnswer((_) async => <Materia>[])`.

### 3. Mock sem `when` para um método usado

```text
type 'Null' is not a subtype of type 'Future<List<Materia>>'
```

O mocktail devolve `null` para o que não foi configurado.

**Correção:** um `when` para cada método que o código chamar.

### 4. O teste que testa o mock

Se o teste não instancia nenhuma classe **sua**, ele não testa nada.

**Correção:** o dublê é a dependência; o sujeito é o seu código.

### 5. Fake que não falha onde o real falha

O fake devolve sucesso onde o banco lançaria. O teste passa, a produção quebra.

**Correção:** reproduza os erros do contrato no fake.

### 6. `verifyInOrder` por hábito

Acopla o teste à ordem interna da implementação.

**Correção:** só quando a ordem **é** a regra de negócio.

### 7. Dublar objeto de valor

```dart
class MateriaMock extends Mock implements Materia {}   // ⚠️
```

**Correção:** construa a `Materia` de verdade. É barato.

### 8. Estado do fake vazando entre testes

O fake declarado fora do `setUp` guarda dados do teste anterior — e a suíte falha **em ordem
aleatória**.

**Correção:** instancie no `setUp`, ou chame `limpar()`.

### 9. `verifyNoMoreInteractions` em tudo

Cada linha nova quebra o teste, mesmo inofensiva.

**Correção:** use pontualmente.

### 10. Dublar o que você está testando

**Correção:** o sujeito do teste é sempre real.

### 11. Fake com ordenação diferente do real

Testes de UI ficam instáveis sem motivo aparente.

**Correção:** reproduza a ordenação.

### 12. `clienteQueTrava()` sem `pump(duration)`

```text
A Timer is still pending…
```

**Correção:** avance o relógio até o timeout disparar.

---

## 🛠️ Exercício guiado

**Passo 1.** Crie `test/apoio/dubles.dart` com o código acima e rode `flutter analyze`.

**Passo 2.** Rode `comparacao_fake_mock_test.dart`. Conte as linhas de `setUp` de cada grupo.

**Passo 3.** No grupo do mock, apague um dos `when` do `setUp`. Rode e leia o erro.

**Passo 4.** No grupo do fake, apague o mesmo comportamento. Qual erro aparece? Compare.

**Passo 5.** Acrescente um método ao `MateriaRepositorioContrato`. Qual dos dois grupos quebra
**no compilador**?

**Passo 6.** Remova o `throw MateriaNaoEncontrada(id)` do fake. Qual teste deixa de pegar o bug?

**Passo 7.** No teste do lembrete, troque `RelogioFake` por `DateTime.now()`. Rode às 21h.

**Passo 8.** Use `falharNasPrimeiras = 1` e escreva um teste de retry com uma tentativa só.

**Passo 9.** Chame `verifyNoMoreInteractions(analytics)` num teste que dispara dois eventos. Leia a
mensagem: ela lista o que sobrou.

**Passo 10.** Escreva um fake de `FlutterSecureStorage` (Módulo 10, aula 7) e teste o fluxo de
login sem tocar no Keystore.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

Faça os de **Aplicação** (escrever um fake de repositório), **Correção de bugs** (mock sem `when`)
e **Diagnóstico** (`registerFallbackValue`).

---

## 🏆 Desafio opcional

Escreva um **fake de banco sqflite** e compare com usar o banco de verdade via
`sqflite_common_ffi` (Módulo 10, aula 4).

Requisitos:

- Um `BancoFake implements BancoContrato` em memória, com as mesmas regras do real.
- A mesma suíte de testes rodando **contra os dois** — um `group` parametrizado.
- O fake deve reproduzir o bug do `ORDER BY` com acento (Módulo 10, aula 4).
- Meça o tempo dos dois.
- Escreva um teste que **passa no fake e falha no real**. Documente por quê.

Depois responda: se o fake e o real divergem, qual dos dois está errado? E qual é o custo de manter
um fake sincronizado com um banco que evolui? (Dica: pesquise "contract test" — a técnica que
resolve exatamente isto.)

---

## 📌 Resumo

- Duble o que **atravessa a fronteira**: rede, disco, relógio, sorteio, sistema operacional.
- Cinco tipos: **dummy**, **stub**, **fake**, **spy**, **mock**. Na prática, fake e mock.
- **Prefira o fake.** Ele testa o **resultado**; o mock testa o **caminho**, e o caminho muda.
- Use **mock** quando não há resultado observável: analytics, log, notificação, envio.
- **mocktail** não precisa de codegen: `class X extends Mock implements Y {}`.
- **`thenAnswer` para assíncrono**, sempre. `thenReturn` com `Future` é armadilha.
- Todo método usado precisa de `when` — senão, `type 'Null' is not a subtype of…`.
- `registerFallbackValue` em **`setUpAll`**, para tipos próprios usados com `any()`.
- **`captureAny`** é o que salva o `verify`: confere **com o quê**, não só **que**.
- O **fake precisa falhar onde o real falha** — senão o teste passa e a produção quebra.
- Um **`RelogioFake`** torna determinístico todo teste que envolve data.
- Fakes com **`atraso`, `falha` e `falharNasPrimeiras`** testam carregamento, erro e retry.
- **Não duble** objetos de valor, funções puras nem o que você está testando.
- Se o teste **não instancia nenhuma classe sua**, ele não testa nada.
- **`ProviderContainer` + `addTearDown(container.dispose)`** testa controller sem montar tela.
- Use **`sqflite_common_ffi`** para testar o **SQL e as migrações**; o fake, para quem usa o repositório.
- Instancie os dublês no **`setUp`** — estado vazado faz a suíte falhar em ordem aleatória.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre stub, fake, spy e mock.
- [ ] Escolho fake ou mock com critério.
- [ ] Crio mocks com mocktail sem codegen.
- [ ] Uso `thenAnswer` para assíncrono.
- [ ] Sei corrigir "type 'Null' is not a subtype of".
- [ ] Registro fallbacks em `setUpAll`.
- [ ] Uso `captureAny` para conferir os argumentos.
- [ ] Escrevo fakes com atraso, falha e contadores.
- [ ] Meu fake falha onde o real falha.
- [ ] Injeto um relógio em vez de usar `DateTime.now()`.
- [ ] Reconheço o teste que testa o mock.
- [ ] Instancio dublês no `setUp`.
- [ ] Testo controllers com `ProviderContainer` e descarto no `addTearDown`.
- [ ] Uso `sqflite_common_ffi` com `inMemoryDatabasePath` para testar SQL e migrações.
- [ ] Mantenho os dublês num arquivo de apoio compartilhado.

---

## 📚 Referências oficiais

- [mocktail — pub.dev](https://pub.dev/packages/mocktail)
- [Mock dependencies using Mockito — docs.flutter.dev](https://docs.flutter.dev/cookbook/testing/unit/mocking)
- [MockClient — pub.dev/documentation/http](https://pub.dev/documentation/http/latest/testing/MockClient-class.html)
- [package:test — Mocking and test doubles](https://github.com/dart-lang/test/blob/master/pkgs/test/doc/configuration.md)
- [Test Double — martinfowler.com](https://martinfowler.com/bliki/TestDouble.html)
- [Mocks Aren't Stubs — martinfowler.com](https://martinfowler.com/articles/mocksArentStubs.html)
- [sqflite_common_ffi — pub.dev](https://pub.dev/packages/sqflite_common_ffi)
- [Riverpod — Testing](https://riverpod.dev/docs/essentials/testing)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Testes de widget](06-testes-de-widget.md) | [README](README.md) | [Aula 8 — Testes de integração](08-testes-de-integracao.md) |
