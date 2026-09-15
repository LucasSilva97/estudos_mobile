# Aula 10 — Injeção de dependências

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é **injeção de dependências** e por que ela é o que torna código testável.
- Usar **`overrides`** no `ProviderScope` para substituir uma implementação por outra.
- Escrever testes com **`ProviderContainer`**, sem montar nenhum widget.
- Criar **fakes** e usá-los no lugar de banco, rede e relógio.
- Testar widgets com `ProviderScope(overrides: ...)` e `tester.pumpWidget`.
- Configurar **ambientes** (desenvolvimento, produção) com o mesmo código.
- Comparar o Riverpod com **`get_it`** e justificar a escolha do curso.
- Resolver dependências que só existem em tempo de execução (`SharedPreferences`, banco aberto).

## ✅ Pré-requisitos

- [Aula 9 — Arquitetura feature-first](09-arquitetura-feature-first.md) — **essencial**: sem o
  contrato de repositório, não há o que injetar.
- [Aula 6 — Notifier](06-notifier-e-notifierprovider.md) e
  [Aula 7 — AsyncNotifier](07-asyncnotifier-e-asyncvalue.md) — o `ProviderContainer` apareceu lá;
  aqui ele é o assunto.
- [Módulo 03, aula 5 — Abstratas e interfaces](../03-dart-intermediario/05-abstratas-e-interfaces.md).
- O projeto `foco_estado` já reorganizado pela aula 9.

---

## 📖 Conceito

### O que é injeção de dependências

Uma classe que **cria** as próprias dependências fica presa a elas:

```dart
// ❌ acoplado: este controller SEMPRE usa SQLite
class MateriasController extends AsyncNotifier<List<Materia>> {
  final MateriaRepositorio _repo = MateriaRepositorioSqflite();

  @override
  Future<List<Materia>> build() => _repo.listar();
}
```

Para testar isso você precisa de um banco de verdade. Para rodar com dados falsos, precisa editar
o código. Para trocar por HTTP, precisa editar o código.

Uma classe que **recebe** as dependências fica livre:

```dart
// ✅ injetado: quem decide a implementação é de fora
class MateriasController extends AsyncNotifier<List<Materia>> {
  @override
  Future<List<Materia>> build() {
    final MateriaRepositorio repo = ref.watch(materiaRepositorioProvider);
    return repo.listar();
  }
}
```

**Injeção de dependências** é isso: a classe declara **o que precisa** (o tipo do contrato) e
alguém de fora **fornece** a implementação. No Riverpod, esse "alguém de fora" é o `ProviderScope`.

> 📌 Você já vem fazendo injeção desde a aula 7, quando escreveu
> `ref.watch(trilhasFonteProvider)`. O que faltava era o mecanismo para **trocar** o que aquele
> provider devolve — e é isso que os `overrides` fazem.

### `overrides`: trocar a implementação

```dart
ProviderScope(
  overrides: <Override>[
    // Onde o app pediria o repositório real, entregue este.
    materiaRepositorioProvider.overrideWithValue(MateriaRepositorioFalso()),
  ],
  child: const MeuApp(),
)
```

Nenhuma linha de `presentation` muda. O controller continua pedindo
`ref.watch(materiaRepositorioProvider)` — e recebe outra coisa.

Há duas formas de sobrescrever:

```dart
// 1. Por VALOR: quando você já tem a instância pronta.
materiaRepositorioProvider.overrideWithValue(repositorioFalso)

// 2. Por FUNÇÃO: quando a criação depende de outros providers.
materiaRepositorioProvider.overrideWith(
  (Ref ref) => MateriaRepositorioHttp(ref.watch(clienteHttpProvider)),
)
```

> ⚠️ Isso só funciona porque o provider foi tipado com o **contrato**
> (`Provider<MateriaRepositorio>`), como a [aula 9](09-arquitetura-feature-first.md) insistiu. Se o
> tipo fosse `Provider<MateriaRepositorioMemoria>`, você só poderia substituí-lo por outra instância
> da mesma classe — o que não serve para nada.

### `ProviderContainer`: Riverpod sem widgets

```dart
final ProviderContainer container = ProviderContainer(
  overrides: <Override>[
    materiaRepositorioProvider.overrideWithValue(repositorioFalso),
  ],
);
addTearDown(container.dispose);

final AsyncValue<List<Materia>> estado = container.read(materiasProvider);
```

`ProviderContainer` é o `ProviderScope` **sem a árvore de widgets**. Ele tem `read`, `listen`,
`refresh` e `invalidate` — tudo menos `watch` (que só faz sentido dentro de um `build`).

| | `ProviderScope` | `ProviderContainer` |
|---|---|---|
| É um widget | ✅ | ❌ |
| Usado em | O app | **Testes** e código Dart puro |
| Precisa de `dispose` manual | ❌ | ✅ |

> ⚠️ **Sempre `addTearDown(container.dispose)`** logo depois de criar. Sem isso, os providers do
> teste anterior continuam vivos e contaminam o próximo.

### Esperar um `AsyncNotifier` no teste

Um `AsyncNotifier` começa em `AsyncLoading`. Para testá-lo você precisa esperar:

```dart
test('carrega as matérias', () async {
  final ProviderContainer container = ProviderContainer(overrides: ...);
  addTearDown(container.dispose);

  // `.future` devolve um Future que completa quando o AsyncValue vira data.
  final List<Materia> lista = await container.read(materiasProvider.future);

  expect(lista.length, 3);
});
```

`provider.future` é a peça que faltava: ele espera a primeira carga terminar.

Para observar a **sequência** de estados:

```dart
test('passa por loading antes de data', () async {
  final ProviderContainer container = ProviderContainer();
  addTearDown(container.dispose);

  final List<AsyncValue<List<Materia>>> estados = <AsyncValue<List<Materia>>>[];
  container.listen(
    materiasProvider,
    (AsyncValue<List<Materia>>? antes, AsyncValue<List<Materia>> agora) =>
        estados.add(agora),
    fireImmediately: true,
  );

  await container.read(materiasProvider.future);

  expect(estados.first, isA<AsyncLoading<List<Materia>>>());
  expect(estados.last, isA<AsyncData<List<Materia>>>());
});
```

### Fakes: o que injetar nos testes

Três palavras que as pessoas confundem:

| Termo | O que é |
|---|---|
| **Fake** | Uma implementação **funcional** e simplificada (repositório em memória) |
| **Stub** | Devolve respostas fixas, sem lógica |
| **Mock** | Verifica **como** foi chamado (quantas vezes, com quais argumentos) |

**Este curso usa fakes escritos à mão.** Motivo: eles são código Dart comum, não exigem pacote nem
geração, e você lê o comportamento inteiro no arquivo.

```dart
class MateriaRepositorioFalso implements MateriaRepositorio {
  MateriaRepositorioFalso([List<Materia>? iniciais])
      : _materias = <Materia>[...?iniciais];

  final List<Materia> _materias;

  /// Controle do teste: quando true, toda chamada falha.
  bool falharSempre = false;

  /// Registro para o teste verificar o que aconteceu.
  int chamadasDeListar = 0;

  @override
  Future<List<Materia>> listar() async {
    chamadasDeListar++;
    if (falharSempre) throw const FalhaDeArmazenamento();
    return List<Materia>.unmodifiable(_materias);
  }
  // …
}
```

Três coisas que um bom fake tem:

1. **Sem atraso.** Testes não esperam 250 ms à toa.
2. **Controle de falha.** Um campo que faz as chamadas lançarem, para testar o caminho de erro.
3. **Registro.** Contadores que o teste pode verificar.

O pacote `mocktail` é ótimo e você vai encontrá-lo em projetos profissionais — é assunto do
[Módulo 12, aula 7](../12-testes-e-debug/07-mocks-e-fakes.md).

### Dependências que só existem em tempo de execução

Alguns objetos só podem ser criados **depois** de um `await`: `SharedPreferences`, um banco aberto,
um cliente autenticado.

O padrão do Riverpod para isso:

```dart
// 1. Declare o provider que "não pode existir ainda".
final Provider<SharedPreferences> prefsProvider = Provider<SharedPreferences>(
  (Ref ref) => throw UnimplementedError('Sobrescreva no main()'),
);

// 2. No main, crie o objeto e sobrescreva.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[prefsProvider.overrideWithValue(prefs)],
      child: const MeuApp(),
    ),
  );
}
```

O `throw UnimplementedError` é intencional: se alguém esquecer o override, o erro é **imediato e
claro**, em vez de um `null` silencioso viajando pelo app.

> 💡 A alternativa moderna é um `FutureProvider` e um `AsyncValue` na raiz. O padrão do `throw` é
> mais simples quando a dependência é obrigatória para o app funcionar.

### Ambientes

O mesmo código, configurações diferentes:

```dart
// main_dev.dart
void main() => runApp(ProviderScope(
      overrides: <Override>[
        urlBaseProvider.overrideWithValue('https://api-dev.exemplo.com'),
        materiaRepositorioProvider.overrideWith(
          (Ref ref) => MateriaRepositorioMemoria(),   // dados falsos
        ),
      ],
      child: const MeuApp(),
    ));

// main.dart (produção)
void main() => runApp(const ProviderScope(child: MeuApp()));
```

```powershell
flutter run -t lib/main_dev.dart
```

Nenhum `if (ehDesenvolvimento)` espalhado pelo código. A diferença fica **em um lugar**.

### Riverpod × `get_it`

`get_it` é o outro pacote popular de injeção em Flutter:

| | Riverpod | `get_it` |
|---|---|---|
| Erro de dependência não registrada | Em **compilação** (o provider é tipado) | Em **execução** |
| Reatividade (mudou → a tela atualiza) | ✅ nativa | ❌ (precisa de outro pacote) |
| Escopo por tela | ✅ `autoDispose`, `family` | ⚠️ manual |
| Substituir em teste | `overrides` | `registerSingleton` antes do teste |
| Também gerencia estado | ✅ | ❌ (é só um localizador de serviços) |
| Curva | Média-alta | Baixa |

**Decisão do curso: Riverpod.** Motivo principal: você já precisa dele para estado, e usar **um**
mecanismo para estado e dependências é mais simples que manter dois. E o erro em tempo de
compilação é uma vantagem real.

> 📌 Tecnicamente, `get_it` é um **service locator**, não um injetor: o código **pede** a
> dependência a um registro global. A diferença prática aparece nos testes: com `get_it`, esquecer
> de registrar algo só explode quando aquela linha roda.

---

## 💡 Analogia

Pense numa cozinha profissional e no fornecimento de ingredientes.

- **Sem injeção** é o chef **ir pessoalmente à fazenda** buscar tomate toda vez. Funciona — e
  amarra a receita àquela fazenda. Testar a receita exige uma viagem. Trocar de fornecedor exige
  reescrever a receita.
- **Com injeção** é a receita dizer **"300 g de tomate"**. De onde ele vem é problema do estoque.
  A receita virou independente do fornecedor.
- **O contrato** (`MateriaRepositorio`) é a especificação "tomate italiano, maduro". Qualquer
  fornecedor que atenda serve.
- **Os `overrides`** são o gerente dizendo: "hoje, onde a receita pedir tomate, use o da caixa de
  amostras". O chef não fica sabendo — e nem precisa.
- **O `fake`** é o ingrediente de treinamento: parece tomate, comporta-se como tomate, custa nada e
  está sempre disponível. O aprendiz treina o corte mil vezes sem desperdiçar comida.
- **`ProviderContainer`** é a **cozinha de testes**: as mesmas receitas, sem o salão, sem clientes,
  sem garçons. Você testa a receita em segundos em vez de abrir o restaurante.
- **A dependência que só existe em tempo de execução** é a chave do freezer: ela só existe depois
  que alguém abre o restaurante. A receita não pode criá-la. Por isso o provider **lança um erro
  claro** ("a chave não foi entregue") em vez de devolver uma chave falsa que não abre nada.

---

## 🧪 Exemplo mínimo

Um teste que prova que a injeção funciona, e o mesmo código rodando com duas implementações.

> **Arquivo:** `foco_estado/test/injecao_test.dart` (novo)
> **Como executar:** `flutter test`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── O contrato (normalmente em domain/) ────────────────────────────────────
abstract interface class Relogio {
  DateTime agora();
}

// ── A implementação real (normalmente em data/) ────────────────────────────
class RelogioDoSistema implements Relogio {
  @override
  DateTime agora() => DateTime.now();
}

/// Provider tipado com o CONTRATO. É isto que permite substituí-lo.
final Provider<Relogio> relogioProvider =
    Provider<Relogio>((Ref ref) => RelogioDoSistema());

// ── O fake, para os testes ────────────────────────────────────────────────
class RelogioFalso implements Relogio {
  RelogioFalso(this._agora);

  DateTime _agora;

  /// Controle do teste: permite "viajar no tempo".
  void avancar(Duration d) => _agora = _agora.add(d);

  @override
  DateTime agora() => _agora;
}

// ── O código que depende do relógio ───────────────────────────────────────
final Provider<String> saudacaoProvider = Provider<String>((Ref ref) {
  final int hora = ref.watch(relogioProvider).agora().hour;
  if (hora < 12) return 'Bom dia';
  if (hora < 18) return 'Boa tarde';
  return 'Boa noite';
});

void main() {
  group('saudação conforme a hora', () {
    /// Sem injeção, este teste seria IMPOSSÍVEL de escrever:
    /// você não controla DateTime.now().
    test('de manhã', () {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          relogioProvider.overrideWithValue(
            RelogioFalso(DateTime(2026, 3, 10, 8)),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(saudacaoProvider), 'Bom dia');
    });

    test('à tarde', () {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          relogioProvider.overrideWithValue(
            RelogioFalso(DateTime(2026, 3, 10, 15)),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(saudacaoProvider), 'Boa tarde');
    });

    test('à noite', () {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          relogioProvider.overrideWithValue(
            RelogioFalso(DateTime(2026, 3, 10, 22)),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(saudacaoProvider), 'Boa noite');
    });

    test('a mesma instância de container mantém estado isolado', () {
      // Dois containers, dois estados independentes — apesar de os
      // providers serem variáveis GLOBAIS. É o ProviderScope/Container
      // que guarda o valor, não a variável.
      final ProviderContainer manha = ProviderContainer(
        overrides: <Override>[
          relogioProvider
              .overrideWithValue(RelogioFalso(DateTime(2026, 3, 10, 8))),
        ],
      );
      final ProviderContainer noite = ProviderContainer(
        overrides: <Override>[
          relogioProvider
              .overrideWithValue(RelogioFalso(DateTime(2026, 3, 10, 22))),
        ],
      );
      addTearDown(manha.dispose);
      addTearDown(noite.dispose);

      expect(manha.read(saudacaoProvider), 'Bom dia');
      expect(noite.read(saudacaoProvider), 'Boa noite');
    });
  });
}
```

```powershell
flutter test test/injecao_test.dart
```

**O ponto:** sem injeção, testar "o que o app mostra às 22h" exigiria mudar o relógio da máquina.
Com injeção, é uma linha.

---

## 📱 Aplicando no Flutter

Agora o `foco_estado` ganha:

1. Um **fake** completo do `MateriaRepositorio`, com controle de falha e registro de chamadas.
2. Testes do `MateriasController` cobrindo sucesso, erro e validação.
3. Um **teste de widget** com `ProviderScope(overrides: ...)`.
4. Um `main_dev.dart` com dados falsos, para desenvolver sem backend.

---

## 💻 Código completo

> **Arquivo:** `foco_estado/test/fakes/materia_repositorio_falso.dart` (novo)
> **Como executar:** `flutter test`

```dart
import 'package:foco_estado/features/materias/domain/materia.dart';
import 'package:foco_estado/features/materias/domain/materia_repositorio.dart';

/// Fake do repositório de matérias.
///
/// Um bom fake tem três coisas:
/// 1. Nenhum atraso — testes não esperam à toa.
/// 2. Controle de falha — para testar o caminho de erro.
/// 3. Registro — contadores que o teste pode verificar.
class MateriaRepositorioFalso implements MateriaRepositorio {
  MateriaRepositorioFalso([List<Materia>? iniciais])
      : _materias = <Materia>[...?iniciais];

  final List<Materia> _materias;

  // ── Controle do teste ─────────────────────────────────────────────────
  /// Quando não é null, TODA chamada lança esta falha.
  FalhaMateria? falhaForcada;

  /// Atraso artificial, para testar estados de carregamento.
  Duration atraso = Duration.zero;

  // ── Registro, para o teste verificar ──────────────────────────────────
  int chamadasDeListar = 0;
  int chamadasDeSalvar = 0;
  int chamadasDeExcluir = 0;
  final List<Materia> salvas = <Materia>[];
  final List<String> excluidas = <String>[];

  Future<void> _preparar() async {
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);
    final FalhaMateria? falha = falhaForcada;
    if (falha != null) throw falha;
  }

  @override
  Future<List<Materia>> listar() async {
    chamadasDeListar++;
    await _preparar();
    final List<Materia> copia = <Materia>[..._materias]
      ..sort((Materia a, Materia b) => a.nome.compareTo(b.nome));
    return List<Materia>.unmodifiable(copia);
  }

  @override
  Future<Materia> buscarPorId(String id) async {
    await _preparar();
    final int i = _materias.indexWhere((Materia m) => m.id == id);
    if (i == -1) throw MateriaNaoEncontrada(id);
    return _materias[i];
  }

  @override
  Future<Materia> salvar(Materia materia) async {
    chamadasDeSalvar++;
    salvas.add(materia);
    await _preparar();

    final bool duplicada = _materias.any((Materia m) =>
        m.id != materia.id &&
        m.nome.trim().toLowerCase() == materia.nome.trim().toLowerCase());
    if (duplicada) throw MateriaDuplicada(materia.nome);

    final int i = _materias.indexWhere((Materia m) => m.id == materia.id);
    if (i == -1) {
      _materias.add(materia);
    } else {
      _materias[i] = materia;
    }
    return materia;
  }

  @override
  Future<void> excluir(String id) async {
    chamadasDeExcluir++;
    excluidas.add(id);
    await _preparar();
    _materias.removeWhere((Materia m) => m.id == id);
  }

  /// Atalhos para os testes montarem cenários.
  static Materia materiaDeTeste({
    String id = 'teste',
    String nome = 'Matéria de teste',
    int meta = 60,
  }) =>
      Materia(id: id, nome: nome, metaMinutos: meta);
}
```

> **Arquivo:** `foco_estado/test/materias_controller_test.dart` (novo)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_estado/features/materias/data/materia_repositorio_memoria.dart'
    show materiaRepositorioProvider;
import 'package:foco_estado/features/materias/domain/materia.dart';
import 'package:foco_estado/features/materias/domain/materia_repositorio.dart';
import 'package:foco_estado/features/materias/presentation/materias_controller.dart';

import 'fakes/materia_repositorio_falso.dart';

void main() {
  late MateriaRepositorioFalso repo;
  late ProviderContainer container;

  /// Monta um container com o repositório FALSO no lugar do real.
  /// Nenhuma linha de presentation precisou mudar para isto funcionar.
  ProviderContainer montar({List<Materia>? iniciais}) {
    repo = MateriaRepositorioFalso(iniciais ??
        <Materia>[
          const Materia(id: 'dart', nome: 'Dart', metaMinutos: 120),
          const Materia(id: 'flutter', nome: 'Flutter', metaMinutos: 90),
        ]);

    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[
        materiaRepositorioProvider.overrideWithValue(repo),
      ],
    );
    // SEMPRE. Sem isto, o estado vaza para o próximo teste.
    addTearDown(c.dispose);
    return c;
  }

  group('carga inicial', () {
    test('começa em AsyncLoading', () {
      container = montar();

      // Leitura SÍNCRONA, antes de o Future completar.
      expect(container.read(materiasProvider), isA<AsyncLoading<List<Materia>>>());
    });

    test('termina em AsyncData com a lista ordenada', () async {
      container = montar();

      // .future espera a primeira carga terminar.
      final List<Materia> lista = await container.read(materiasProvider.future);

      expect(lista.length, 2);
      expect(lista.first.nome, 'Dart'); // ordenado por nome
      expect(repo.chamadasDeListar, 1);
    });

    test('vira AsyncError quando o repositório falha', () async {
      container = montar();
      repo.falhaForcada = const FalhaDeArmazenamento();
      container.invalidate(materiasProvider);

      // Esperamos o erro, não o valor.
      await expectLater(
        container.read(materiasProvider.future),
        throwsA(isA<FalhaDeArmazenamento>()),
      );
      expect(container.read(materiasProvider), isA<AsyncError<List<Materia>>>());
    });

    test('passa por loading antes de data', () async {
      container = montar();

      final List<AsyncValue<List<Materia>>> estados =
          <AsyncValue<List<Materia>>>[];
      container.listen<AsyncValue<List<Materia>>>(
        materiasProvider,
        (AsyncValue<List<Materia>>? antes, AsyncValue<List<Materia>> agora) =>
            estados.add(agora),
        fireImmediately: true,
      );

      await container.read(materiasProvider.future);

      expect(estados.first, isA<AsyncLoading<List<Materia>>>());
      expect(estados.last, isA<AsyncData<List<Materia>>>());
    });
  });

  group('salvar', () {
    test('recusa nome curto SEM chamar o repositório', () async {
      container = montar();
      await container.read(materiasProvider.future);

      final String? erro = await container
          .read(materiasProvider.notifier)
          .salvar(const Materia(id: 'x', nome: 'A', metaMinutos: 60));

      expect(erro, contains('2 a 40'));
      // A validação é do DOMÍNIO: nem chegou a tocar no repositório.
      expect(repo.chamadasDeSalvar, 0);
    });

    test('recusa meta fora da faixa', () async {
      container = montar();
      await container.read(materiasProvider.future);

      final String? erro = await container
          .read(materiasProvider.notifier)
          .salvar(const Materia(id: 'x', nome: 'Química', metaMinutos: 999));

      expect(erro, contains('5 e 480'));
      expect(repo.chamadasDeSalvar, 0);
    });

    test('salva matéria válida e recarrega a lista', () async {
      container = montar();
      await container.read(materiasProvider.future);

      final String? erro = await container
          .read(materiasProvider.notifier)
          .salvar(const Materia(id: 'sql', nome: 'SQL', metaMinutos: 60));

      expect(erro, isNull);
      expect(repo.chamadasDeSalvar, 1);
      expect(repo.salvas.single.nome, 'SQL');

      final List<Materia> lista = container.read(materiasProvider).requireValue;
      expect(lista.length, 3);
    });

    test('devolve mensagem quando o nome já existe', () async {
      container = montar();
      await container.read(materiasProvider.future);

      final String? erro = await container
          .read(materiasProvider.notifier)
          .salvar(const Materia(id: 'novo', nome: 'dart', metaMinutos: 60));

      expect(erro, contains('Já existe'));
    });

    test('erro no salvar MANTÉM a lista anterior na tela', () async {
      container = montar();
      await container.read(materiasProvider.future);

      repo.falhaForcada = const FalhaDeArmazenamento();
      await container
          .read(materiasProvider.notifier)
          .salvar(const Materia(id: 'sql', nome: 'SQL', metaMinutos: 60));

      final AsyncValue<List<Materia>> estado = container.read(materiasProvider);
      expect(estado.hasError, isTrue);
      // O ponto: os dados antigos continuam disponíveis.
      expect(estado.hasValue, isTrue);
      expect(estado.value!.length, 2);
    });
  });

  group('excluir', () {
    test('remove e recarrega', () async {
      container = montar();
      await container.read(materiasProvider.future);

      await container.read(materiasProvider.notifier).excluir('dart');

      expect(repo.excluidas.single, 'dart');
      expect(container.read(materiasProvider).requireValue.length, 1);
    });
  });

  group('providers derivados', () {
    test('totalDeMaterias acompanha a lista', () async {
      container = montar();
      await container.read(materiasProvider.future);

      expect(container.read(totalDeMateriasProvider).value, 2);

      await container
          .read(materiasProvider.notifier)
          .salvar(const Materia(id: 'sql', nome: 'SQL', metaMinutos: 60));

      expect(container.read(totalDeMateriasProvider).value, 3);
    });
  });
}
```

> **Arquivo:** `foco_estado/test/materias_tab_widget_test.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_estado/features/materias/data/materia_repositorio_memoria.dart'
    show materiaRepositorioProvider;
import 'package:foco_estado/features/materias/domain/materia.dart';
import 'package:foco_estado/features/materias/domain/materia_repositorio.dart';
import 'package:foco_estado/features/materias/presentation/materias_tab.dart';

import 'fakes/materia_repositorio_falso.dart';

void main() {
  /// O mesmo mecanismo dos testes de unidade, agora com widgets:
  /// ProviderScope aceita os mesmos overrides.
  Widget montarApp(MateriaRepositorioFalso repo) {
    return ProviderScope(
      overrides: <Override>[
        materiaRepositorioProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: MateriasTab()),
    );
  }

  testWidgets('mostra indicador e depois a lista', (WidgetTester tester) async {
    final MateriaRepositorioFalso repo = MateriaRepositorioFalso(<Materia>[
      const Materia(id: 'dart', nome: 'Dart', metaMinutos: 120),
    ])
      // Atraso artificial para o estado de carregamento ser observável.
      ..atraso = const Duration(milliseconds: 50);

    await tester.pumpWidget(montarApp(repo));

    // Primeiro quadro: ainda carregando.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // pumpAndSettle espera todas as animações e futures pendentes.
    await tester.pumpAndSettle();

    expect(find.text('Dart'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('mostra a tela de erro quando o repositório falha',
      (WidgetTester tester) async {
    final MateriaRepositorioFalso repo = MateriaRepositorioFalso()
      ..falhaForcada = const FalhaDeArmazenamento();

    await tester.pumpWidget(montarApp(repo));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tentar de novo'), findsOneWidget);
  });

  testWidgets('mostra estado vazio quando não há matérias',
      (WidgetTester tester) async {
    await tester.pumpWidget(montarApp(MateriaRepositorioFalso(<Materia>[])));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhuma'), findsOneWidget);
  });
}
```

> **Arquivo:** `foco_estado/lib/main_dev.dart` (novo — ambiente de desenvolvimento)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/app.dart';
import 'package:foco_estado/features/materias/data/materia_repositorio_memoria.dart';
import 'package:foco_estado/features/materias/domain/materia.dart';

/// Ponto de entrada de DESENVOLVIMENTO.
///
/// Mesmo app, mesmos widgets, dados diferentes. Nenhum
/// `if (ehDesenvolvimento)` espalhado pelo código — a diferença
/// fica neste arquivo.
///
/// Rode com:
///   flutter run -t lib/main_dev.dart
void main() {
  runApp(
    ProviderScope(
      overrides: <Override>[
        // Muitas matérias, para testar rolagem e desempenho.
        materiaRepositorioProvider.overrideWith(
          (Ref ref) => MateriaRepositorioMemoria(<Materia>[
            for (int i = 1; i <= 50; i++)
              Materia(
                id: 'dev_$i',
                nome: 'Matéria de teste $i',
                metaMinutos: 30 + (i % 8) * 30,
              ),
          ]),
        ),
      ],
      child: const FocoEstadoApp(),
    ),
  );
}
```

Rode tudo:

```powershell
flutter analyze
flutter test
flutter run -t lib/main_dev.dart
```

Todos os testes devem passar, e o app de desenvolvimento abre com 50 matérias — sem que uma linha
de `presentation` tenha mudado.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `Provider<Relogio>` tipado com o **contrato** | Sem isso, `overrideWithValue(RelogioFalso())` não compilaria. O tipo do provider é o que habilita a substituição. |
| `RelogioFalso` com `avancar(Duration)` | Permite "viajar no tempo" no teste. Sem injeção, testar comportamento por horário é impossível. |
| `ProviderContainer(overrides: [...])` | O `ProviderScope` sem widgets. Mesmos overrides, sem árvore. |
| `addTearDown(container.dispose)` | **Obrigatório.** Sem isso, os providers do teste anterior vazam para o próximo. |
| `await container.read(materiasProvider.future)` | `.future` espera a primeira carga do `AsyncNotifier` terminar. |
| `container.listen(..., fireImmediately: true)` | Captura a **sequência** de estados, incluindo o `AsyncLoading` inicial. |
| `FalhaMateria? falhaForcada` no fake | Um campo, e o caminho de erro fica testável sem desligar a internet. |
| `Duration atraso` no fake | `Duration.zero` por padrão (testes rápidos); ajustável quando o teste precisa observar o carregamento. |
| `int chamadasDeListar`, `List<Materia> salvas` | Registro: o teste verifica **se** e **com o quê** o repositório foi chamado. |
| `expect(repo.chamadasDeSalvar, 0)` no teste de validação | Prova que a validação é do **domínio**: nem chegou a tocar no repositório. |
| `expect(estado.hasError && estado.hasValue, isTrue)` | Verifica o padrão "erro sem apagar os dados" da [aula 7](07-asyncnotifier-e-asyncvalue.md). |
| `ProviderScope(overrides: ...)` no teste de widget | O **mesmo** mecanismo dos testes de unidade, agora com árvore. |
| `..atraso = const Duration(milliseconds: 50)` | Sem atraso, o `AsyncLoading` passaria rápido demais para o teste observar. |
| `await tester.pumpAndSettle()` | Espera todos os quadros e futures pendentes. Sem isso, o teste checa a tela ainda carregando. |
| `main_dev.dart` com `-t` | Ambiente inteiro configurado em um arquivo, sem `if` espalhado. |
| `overrideWith((Ref ref) => ...)` | Forma por **função**: use quando a criação depende de outros providers. |

---

## ⚠️ Erros comuns

### 1. Provider tipado com a classe concreta

```dart
final Provider<MateriaRepositorioMemoria> repo = ...;   // ❌
```

```text
The argument type 'MateriaRepositorioFalso' can't be assigned to
the parameter type 'MateriaRepositorioMemoria'
```

**Correção:** tipe com o contrato: `Provider<MateriaRepositorio>`.

### 2. Esquecer `container.dispose`

```dart
test('...', () {
  final ProviderContainer c = ProviderContainer();   // ⚠️
  // sem addTearDown
});
```

Testes passam isolados e falham quando rodados juntos — o pior tipo de falha.

**Correção:** `addTearDown(container.dispose);` sempre.

### 3. Ler um `AsyncNotifier` sem esperar

```dart
final List<Materia> lista = container.read(materiasProvider).requireValue;   // ❌
```

```text
Bad state: Tried to call `requireValue` on an `AsyncValue` that has no value
```

**Correção:** `await container.read(materiasProvider.future);`

### 4. `overrideWithValue` com algo que depende de outro provider

```dart
materiaRepositorioProvider.overrideWithValue(
  MateriaRepositorioHttp(clienteHttp),   // ⚠️ e se o cliente vier de um provider?
)
```

**Correção:** use `overrideWith((Ref ref) => ...)`, que dá acesso ao `ref`.

### 5. Provider de dependência assíncrona sem `throw`

```dart
final Provider<SharedPreferences?> prefs = Provider<SharedPreferences?>((Ref r) => null);   // ⚠️
```

O `null` viaja silenciosamente pelo app e explode longe da causa.

**Correção:** `throw UnimplementedError('Sobrescreva no main()')` — falha imediata e clara.

### 6. `if (kDebugMode)` espalhado em vez de ambientes

```dart
final repo = kDebugMode ? MateriaRepositorioMemoria() : MateriaRepositorioHttp();   // ⚠️
```

Espalha decisão de ambiente pelo código e impede testar o caminho de produção em debug.

**Correção:** `main.dart` e `main_dev.dart` com overrides diferentes.

### 7. Fake com atraso real

```dart
Future<List<Materia>> listar() async {
  await Future<void>.delayed(const Duration(seconds: 1));   // ⚠️
```

Cem testes × 1 s = quase dois minutos por rodada. Ninguém roda testes lentos.

**Correção:** `Duration.zero` por padrão; atraso só onde o teste precisa.

### 8. Testar a implementação em vez do contrato

```dart
expect(repo, isA<MateriaRepositorioMemoria>());   // ⚠️ testa a fiação, não o comportamento
```

**Correção:** teste **o que o controller faz** com os dados, não qual classe está por trás.

### 9. `overrides` no `ProviderScope` errado

```dart
MaterialApp(
  home: ProviderScope(overrides: [...], child: const MinhaTela()),   // ⚠️
)
```

Um `ProviderScope` aninhado cria um escopo **novo**: providers lidos acima dele não são afetados.

**Correção:** os overrides globais ficam no `ProviderScope` **raiz**.

### 10. Esquecer `pumpAndSettle` no teste de widget

```dart
await tester.pumpWidget(montarApp(repo));
expect(find.text('Dart'), findsOneWidget);   // ❌ ainda está carregando
```

**Correção:** `await tester.pumpAndSettle();` antes de verificar.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test` e confirme todos os testes passando. Anote o tempo total.

**Passo 2.** Troque `materiaRepositorioProvider.overrideWithValue(repo)` por nada (remova o
override) em um teste. Rode e leia o que acontece. Explique por escrito.

**Passo 3.** Remova `addTearDown(c.dispose)` de `montar()`. Rode a suíte inteira. Passa? Rode de
novo. Descreva qualquer instabilidade.

**Passo 4.** Tipe `materiaRepositorioProvider` como `Provider<MateriaRepositorioMemoria>`. Rode os
testes e leia o erro de compilação. Depois desfaça.

**Passo 5.** No fake, mude `atraso` para `const Duration(milliseconds: 300)` por padrão. Rode a
suíte e compare o tempo com o do passo 1.

**Passo 6.** Escreva um teste novo que confirme: quando `salvar` falha, `chamadasDeListar` **não**
aumenta (ou seja, o controller não recarrega depois de um erro).

**Passo 7.** Rode `flutter run -t lib/main_dev.dart`. Confirme as 50 matérias. Quantos arquivos de
`presentation` foram tocados para isso acontecer?

**Passo 8.** Crie um `main_staging.dart` que usa o repositório em memória **com falha em 50% das
chamadas**. Use-o para testar manualmente a tela de erro.

**Passo 9.** No teste de widget, remova o `await tester.pumpAndSettle()`. Rode e leia a falha.
Explique o que o teste estava vendo.

**Passo 10.** Responda por escrito: se amanhã o repositório passar a usar SQLite, quantos arquivos
de teste precisam mudar? Por quê?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

Faça os exercícios de **Aplicação** com `overrides` e fakes, o de **Correção de bugs** com
`container.dispose` esquecido, e o de **Decisão** sobre Riverpod × `get_it`.

---

## 🏆 Desafio opcional

Escreva uma **suíte de contrato**: um conjunto de testes que qualquer implementação de
`MateriaRepositorio` precisa passar.

```dart
void testarContratoDeMateriaRepositorio(
  String nome,
  MateriaRepositorio Function() criar,
) {
  group('contrato · $nome', () {
    test('listar devolve lista ordenada por nome', () async { /* … */ });
    test('salvar nome duplicado lança MateriaDuplicada', () async { /* … */ });
    test('buscarPorId inexistente lança MateriaNaoEncontrada', () async { /* … */ });
    test('excluir id inexistente não lança', () async { /* … */ });
  });
}

// E no arquivo de teste:
void main() {
  testarContratoDeMateriaRepositorio('memória', MateriaRepositorioMemoria.new);
  testarContratoDeMateriaRepositorio('falso', MateriaRepositorioFalso.new);
  // No Módulo 10:
  // testarContratoDeMateriaRepositorio('sqflite', () => MateriaRepositorioSqflite(dao));
}
```

Requisitos:

- Os mesmos testes rodam contra **todas** as implementações.
- Uma implementação nova só é aceita se passar na suíte inteira.
- Nenhum teste depende de detalhe de implementação.

Depois responda: o seu **fake** passa nos mesmos testes que a implementação real? Se não, ele está
mentindo nos testes — e um dia vai esconder um bug que só aparece em produção. Essa é a armadilha
mais séria de trabalhar com fakes.

---

## 📌 Resumo

- **Injeção de dependências** é a classe **declarar** o que precisa e alguém de fora **fornecer** a
  implementação. É o que torna código testável.
- No Riverpod, quem fornece é o **`ProviderScope`**, e quem troca são os **`overrides`**.
- **Isso só funciona se o provider for tipado com o contrato**, não com a classe concreta.
- `overrideWithValue(x)` quando você já tem a instância; `overrideWith((ref) => ...)` quando a
  criação depende de outros providers.
- **`ProviderContainer`** é o `ProviderScope` sem widgets — a ferramenta de teste. **Sempre**
  `addTearDown(container.dispose)`.
- **`provider.future`** espera a primeira carga de um `AsyncNotifier`; `container.listen` com
  `fireImmediately` captura a sequência de estados.
- Um bom **fake** tem: nenhum atraso por padrão, controle de falha e registro de chamadas.
- `ProviderScope(overrides: ...)` funciona igual em testes de widget — com `pumpAndSettle` antes de
  verificar.
- Dependências assíncronas (`SharedPreferences`, banco) usam o padrão **`throw UnimplementedError`**
  + override no `main`. O `throw` faz a falha ser imediata e clara.
- **Ambientes** são pontos de entrada diferentes (`main.dart`, `main_dev.dart`) com overrides
  diferentes — nunca `if (kDebugMode)` espalhado.
- **Riverpod × `get_it`:** o curso usa Riverpod porque já é necessário para estado, erra em tempo
  de compilação e traz reatividade. `get_it` é um *service locator*, não um injetor.
- Um fake que não se comporta como a implementação real esconde bugs — teste os dois contra a mesma
  suíte de contrato.

---

## ☑️ Checklist de domínio

- [ ] Explico injeção de dependências em uma frase, sem jargão.
- [ ] Tipo meus providers com o contrato, nunca com a classe concreta.
- [ ] Uso `overrideWithValue` e `overrideWith` e sei quando cada um.
- [ ] Escrevo testes com `ProviderContainer` e nunca esqueço o `dispose`.
- [ ] Uso `provider.future` para esperar um `AsyncNotifier`.
- [ ] Capturo a sequência de estados com `container.listen(fireImmediately: true)`.
- [ ] Escrevo fakes com controle de falha e registro de chamadas.
- [ ] Meus fakes não têm atraso por padrão.
- [ ] Testo widgets com `ProviderScope(overrides: ...)` e `pumpAndSettle`.
- [ ] Resolvo dependências assíncronas com `throw` + override no `main`.
- [ ] Configuro ambientes com pontos de entrada diferentes.
- [ ] Justifico a escolha de Riverpod sobre `get_it`.
- [ ] `flutter analyze` e `flutter test` passam limpos.

---

## 📚 Referências oficiais

- [Testing your providers — riverpod.dev](https://riverpod.dev/docs/essentials/testing)
- [Eager initialization of providers — riverpod.dev](https://riverpod.dev/docs/essentials/eager_initialization)
- [ProviderContainer — pub.dev](https://pub.dev/documentation/riverpod/latest/riverpod/ProviderContainer-class.html)
- [Testing Flutter apps — docs.flutter.dev](https://docs.flutter.dev/testing/overview)
- [An introduction to unit testing — docs.flutter.dev](https://docs.flutter.dev/cookbook/testing/unit/introduction)
- [get_it — pub.dev](https://pub.dev/packages/get_it)

---

## 🎓 Fim do Módulo 08

Você começou este módulo com `setState` e um app onde os dados desciam de widget em widget. Termina
com:

- o **diagnóstico** do problema (aulas 1 a 3) — e o `InheritedWidget` escrito na mão;
- uma **decisão técnica justificada** sobre gerenciamento de estado (aula 4);
- **providers, notifiers e estados assíncronos** que se combinam sozinhos (aulas 5 a 7);
- **escopo e ciclo de vida** sob controle, sem vazamento (aula 8);
- uma **arquitetura em camadas** que aguenta o app crescer (aula 9);
- e **testes que rodam em milissegundos**, sem emulador (aula 10).

Antes de seguir:

1. Faça os exercícios em
   [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md).
2. Faça a avaliação em
   [avaliacoes/modulo-08-estado-e-arquitetura.md](../../avaliacoes/modulo-08-estado-e-arquitetura.md).
3. Confirme que `flutter analyze` e `flutter test` no `foco_estado` passam limpos.

No [Módulo 09](../09-consumo-de-api/README.md) a fonte de dados falsa vira **HTTP de verdade**. E
você vai comprovar a promessa da aula 9: **nada** da camada de estado precisa mudar.

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo |
|---|---|---|
| [Aula 9 — Arquitetura feature-first](09-arquitetura-feature-first.md) | [README](README.md) | [Módulo 09 — Consumo de API](../09-consumo-de-api/README.md) |
