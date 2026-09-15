# Aula 5 — Testes unitários

> **Módulo:** 12 - Testes e Debug · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar a **pirâmide de testes** e por que a base dela é a mais larga.
- Escrever testes com **`test`**, **`group`**, `setUp` e `tearDown`.
- Escolher o **matcher** certo, e não usar `equals` para tudo.
- Testar **exceções** com `throwsA` e código **assíncrono** com `expectLater`.
- Escrever nomes de teste que servem de **documentação**.
- Rodar testes seletivamente com `--plain-name` e `--name`.
- Saber **o que não testar** — e por que cobertura de 100% é um mau objetivo.

## ✅ Pré-requisitos

- [Aula 4 — Análise, lint e formatação](04-analise-lint-formatacao.md) — o analisador pega o que o
  teste não precisa pegar.
- [Módulo 04, aula 1 — Exceptions](../04-dart-avancado/01-exceptions.md) e
  [aula 2 — Futures](../04-dart-avancado/02-futures-e-async-await.md).
- [Módulo 08, aula 10 — Injeção de dependências](../08-estado-e-arquitetura/10-injecao-de-dependencias.md)
  — você já escreveu testes lá; aqui eles ganham fundamento.
- O projeto `foco_lab` criado.

---

## 📖 Conceito

### A pirâmide de testes

```text
         ╱╲          Integração (poucos)
        ╱  ╲         lentos, frágeis, realistas
       ╱────╲
      ╱      ╲       Widget (alguns)
     ╱        ╲      médios
    ╱──────────╲
   ╱            ╲    Unitários (muitos)
  ╱______________╲   rápidos, estáveis, focados
```

| Tipo | Testa | Velocidade | Quantos |
|---|---|---|---|
| **Unitário** | Uma função, uma classe | **Milissegundos** | Centenas |
| **Widget** | Uma tela, sem app real | Décimos de segundo | Dezenas |
| **Integração** | O app inteiro, em aparelho | **Minutos** | Poucos |

A forma da pirâmide não é estética — é economia:

| | Unitário | Integração |
|---|---|---|
| Tempo para rodar 100 | ~2 segundos | ~30 minutos |
| Quando falha, você sabe onde | ✅ na linha | ❌ "algo no fluxo" |
| Quebra sozinho (*flaky*) | Raro | **Comum** |
| Roda no PC sem emulador | ✅ | ❌ |

> ⚠️ **A pirâmide invertida é o erro clássico.** Uma equipe escreve 50 testes de integração e 5
> unitários; a suíte leva 40 minutos, falha aleatoriamente, e em dois meses ninguém mais roda.
>
> **Se o teste demora, ele não é rodado. Se não é rodado, não protege nada.**

### O primeiro teste

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('soma dois números', () {
    expect(2 + 2, 4);
  });
}
```

```powershell
flutter test
```

Três peças:

| Peça | Papel |
|---|---|
| `test('nome', () { … })` | Um caso de teste |
| `expect(real, esperado)` | A verificação |
| `group('nome', () { … })` | Agrupa testes relacionados |

E a estrutura que todo bom teste segue — **Arrange, Act, Assert**:

```dart
test('registrar sessão soma os minutos da matéria', () {
  // Arrange (preparar)
  final Materia materia = Materia(id: 'dart', nome: 'Dart', minutos: 0);

  // Act (agir)
  final Materia resultado = materia.comSessaoDe(25);

  // Assert (verificar)
  expect(resultado.minutos, 25);
});
```

Um teste com três blocos claros é legível. Um teste com `expect` no meio da preparação, não.

### O nome do teste é documentação

Compare:

```dart
// ❌ não diz nada
test('teste 1', () { … });
test('materia', () { … });
test('funciona', () { … });

// ✅ descreve o COMPORTAMENTO
test('registrar sessão soma os minutos da matéria', () { … });
test('recusa sessão com menos de 1 minuto', () { … });
test('meta acima de 480 minutos é inválida', () { … });
```

Quando um teste falha, o nome é a **primeira coisa** que você lê. `teste 3 falhou` não ajuda;
`recusa sessão com menos de 1 minuto falhou` diz exatamente o que quebrou.

O padrão que funciona: **`<ação> <resultado esperado>`**, sem a palavra "deve" e sem "testa que".

E `group` completa a frase:

```dart
group('Materia.problema', () {
  test('devolve null quando tudo está válido', () { … });
  test('reclama de nome com menos de 2 letras', () { … });
});
// Saída: "Materia.problema reclama de nome com menos de 2 letras"
```

### Matchers: `expect` faz mais que comparar

```dart
expect(valor, 42);                      // igualdade
expect(lista, isEmpty);                 // vazio
expect(lista, hasLength(3));            // tamanho
expect(lista, contains('dart'));        // contém
expect(lista, <int>[1, 2, 3]);          // igualdade de lista, item a item
expect(texto, startsWith('Olá'));       // prefixo
expect(texto, matches(RegExp(r'\d+'))); // expressão regular
expect(valor, isNull);                  // nulo
expect(valor, isNotNull);
expect(valor, isA<Materia>());          // tipo
expect(numero, greaterThan(10));        // comparação
expect(numero, inInclusiveRange(1, 10));
expect(dobro, closeTo(3.14, 0.01));     // ponto flutuante
```

Por que o matcher certo importa:

```dart
// ❌ a mensagem de falha é inútil
expect(lista.length > 0, true);
// Expected: <true>  Actual: <false>

// ✅ a mensagem diz o que aconteceu
expect(lista, isNotEmpty);
// Expected: non-empty  Actual: []
```

O `closeTo` merece destaque:

```dart
expect(0.1 + 0.2, 0.3);              // ❌ FALHA
// Expected: <0.3>  Actual: <0.30000000000000004>

expect(0.1 + 0.2, closeTo(0.3, 0.0001));   // ✅
```

Ponto flutuante **nunca** é comparado com igualdade exata. É a regra que mais pega gente.

E, para objetos, o `isA` com `having` deixa a falha legível:

```dart
expect(
  falha,
  isA<FalhaDeConexao>()
      .having((Falha f) => f.podeRepetir, 'podeRepetir', isTrue),
);
```

### `setUp` e `tearDown`

```dart
group('MateriaDao', () {
  late Database db;
  late MateriaDao dao;

  setUp(() async {
    // Roda ANTES DE CADA teste.
    db = await abrirBancoEmMemoria();
    dao = MateriaDao(db);
  });

  tearDown(() async {
    // Roda DEPOIS DE CADA teste.
    await db.close();
  });

  test('…', () { … });
});
```

| Função | Quando roda |
|---|---|
| `setUp` | Antes de **cada** teste |
| `tearDown` | Depois de **cada** teste |
| `setUpAll` | Uma vez, antes de todos |
| `tearDownAll` | Uma vez, depois de todos |

> ⚠️ **`setUpAll` é uma armadilha de estado compartilhado.** Se ele cria um objeto e o teste 1 o
> modifica, o teste 2 recebe o objeto modificado — e a suíte passa a depender da **ordem**. Use
> `setUpAll` só para coisas **imutáveis** (inicializar o `sqflite_ffi`, por exemplo).

E o `addTearDown`, que é melhor que o `tearDown` quando o recurso é criado dentro do teste:

```dart
test('…', () {
  final ProviderContainer container = ProviderContainer();
  // Registrado AQUI, junto da criação — impossível esquecer.
  addTearDown(container.dispose);
  // …
});
```

### Testar exceções

```dart
// Função síncrona.
expect(() => calcular(-1), throwsArgumentError);
expect(() => calcular(-1), throwsA(isA<ArgumentError>()));

// Com verificação da mensagem.
expect(
  () => materia.definirMeta(999),
  throwsA(isA<MetaInvalida>()
      .having((MetaInvalida e) => e.mensagem, 'mensagem', contains('480'))),
);

// Função ASSÍNCRONA — repare no expectLater e no await.
await expectLater(
  repositorio.listar(),
  throwsA(isA<FalhaDeConexao>()),
);
```

> ⚠️ **O erro mais comum com exceções:** esquecer a função anônima.
>
> ```dart
> expect(calcular(-1), throwsArgumentError);        // ❌ lança ANTES do expect
> expect(() => calcular(-1), throwsArgumentError);  // ✅
> ```
>
> No primeiro caso, `calcular(-1)` roda imediatamente, lança, e o teste falha com a exceção crua —
> sem chegar no `expect`.

### Testar código assíncrono

Duas formas, para propósitos diferentes:

```dart
// 1. await direto — quando você quer o valor.
test('busca devolve a lista', () async {
  final List<Materia> lista = await dao.listar();
  expect(lista, hasLength(3));
});

// 2. expectLater — quando você quer verificar o Future em si.
test('busca falha sem conexão', () async {
  await expectLater(dao.listar(), throwsA(isA<FalhaDeConexao>()));
});
```

E, para `Stream`:

```dart
test('emite carregando e depois os dados', () {
  expect(
    controller.observar(),
    emitsInOrder(<Object>[
      isA<Carregando>(),
      isA<Sucesso>(),
      emitsDone,
    ]),
  );
});
```

> 📌 **Sempre `await` no `expectLater`.** Sem ele, o teste termina antes de o `Future` completar, e
> passa mesmo estando errado. O lint `unawaited_futures` (aula 4) pega isso.

### O que **não** testar

Cobertura de 100% é um mau objetivo — ela mede linhas executadas, não comportamentos verificados.

| Não teste | Por quê |
|---|---|
| Getters e setters triviais | Testa o compilador, não o seu código |
| `copyWith` sem lógica | Idem |
| Código de terceiros | O pacote tem os testes dele |
| Constantes | `expect(PI, 3.14)` não protege nada |
| Layout exato (`padding == 16`) | Quebra a cada ajuste de design |
| Métodos privados diretamente | Teste pelo comportamento público |

| Teste sempre | Por quê |
|---|---|
| **Regras de negócio** | É o que o app **faz** |
| **Casos-limite** | 0, 1, negativo, vazio, nulo, máximo |
| **Conversões** | `fromJson`, `deLinha`, mapeamentos |
| **Tratamento de erro** | O caminho que ninguém testa à mão |
| **Bug corrigido** | Para não voltar |

> 💡 **O melhor momento para escrever um teste é logo depois de corrigir um bug.** O teste que
> reproduz aquele bug é o mais valioso da suíte: ele é a prova de que o problema existia, e o
> alarme se ele voltar.

### Rodar seletivamente

```powershell
# Tudo.
flutter test

# Um arquivo.
flutter test test/materia_test.dart

# Testes cujo nome CONTÉM o texto.
flutter test --plain-name "recusa sessão"

# Por expressão regular.
flutter test --name "recusa.*minuto"

# Com relatório de cobertura.
flutter test --coverage

# Parar no primeiro erro (útil ao corrigir).
flutter test --fail-fast
```

---

## 💡 Analogia

Pense na inspeção de um prédio em construção.

- **O teste unitário** é testar **uma peça** na bancada: este tijolo aguenta o peso? Esta tomada
  fecha o circuito? Rápido, barato, e quando falha você sabe **exatamente** qual peça.
- **O teste de widget** é montar **um cômodo** e verificar: a porta abre, a luz acende, a janela
  fecha. Mais lento, mais realista.
- **O teste de integração** é a **vistoria do prédio pronto**, com água, luz e elevador
  funcionando. O mais realista — e o que leva um dia inteiro, e no qual "tem algo errado no 3º
  andar" não diz qual apartamento.
- **A pirâmide invertida** é inspecionar só o prédio pronto. Quando o problema aparece, você não
  sabe se é o tijolo, o cimento ou o pedreiro — e a vistoria custa um dia para descobrir.
- **O nome do teste** é a etiqueta no laudo. "Ensaio 3: reprovado" não ajuda ninguém. "Tijolo não
  suporta carga de 5 t: reprovado" manda o engenheiro direto ao ponto.
- **O matcher certo** é o instrumento certo: usar trena onde precisa de paquímetro dá um número —
  só não o número útil.
- **O `closeTo`** é aceitar tolerância: nenhuma peça tem exatamente 10,000000 cm. Exigir igualdade
  exata reprova o prédio inteiro.
- **O que não testar** são os parafusos que vieram certificados de fábrica. Testá-los de novo é
  refazer o trabalho de outra pessoa.

---

## 🧪 Exemplo mínimo

Um modelo com regras de negócio, e a suíte que o cobre.

> **Arquivo:** `foco_lab/lib/dominio/sessao.dart` (novo)

```dart
/// Uma sessão de estudo.
///
/// Toda a lógica está aqui, em Dart puro: nenhum import de Flutter,
/// nenhum banco, nenhuma rede. É o que torna esta classe testável em
/// milissegundos — e o que a coloca na BASE da pirâmide.
class Sessao {
  Sessao({
    required this.materiaId,
    required this.minutos,
    required this.quando,
    this.anotacao = '',
  }) {
    // Guardas no construtor: um objeto inválido NUNCA existe.
    //
    // A alternativa — validar em quem cria — garante que um dia
    // alguém esqueça.
    if (materiaId.trim().isEmpty) {
      throw ArgumentError.value(materiaId, 'materiaId', 'Não pode ser vazio');
    }
    if (minutos < minimoDeMinutos) {
      throw SessaoInvalida(
        'A sessão precisa ter pelo menos $minimoDeMinutos minuto(s)',
      );
    }
    if (minutos > maximoDeMinutos) {
      throw SessaoInvalida(
        'Uma sessão não pode passar de ${maximoDeMinutos ~/ 60} horas',
      );
    }
  }

  static const int minimoDeMinutos = 1;
  static const int maximoDeMinutos = 480;

  final String materiaId;
  final int minutos;
  final DateTime quando;
  final String anotacao;

  // ── Regras de negócio ────────────────────────────────────────────

  /// Uma sessão "produtiva" tem pelo menos 15 minutos.
  ///
  /// Abaixo disso, a pessoa mal se concentrou.
  bool get produtiva => minutos >= 15;

  /// Sessões muito longas indicam que o usuário esqueceu o cronômetro
  /// ligado. Registrar 6 horas seguidas seria pior que perguntar.
  bool get suspeita => minutos > 240;

  /// Classificação para a tela de estatísticas.
  ClassificacaoDeSessao get classificacao {
    if (minutos < 15) return ClassificacaoDeSessao.curta;
    if (minutos <= 60) return ClassificacaoDeSessao.ideal;
    if (minutos <= 240) return ClassificacaoDeSessao.longa;
    return ClassificacaoDeSessao.suspeita;
  }

  bool ehDoMesmoDiaQue(DateTime outra) =>
      quando.year == outra.year &&
      quando.month == outra.month &&
      quando.day == outra.day;

  /// Quantos "pomodoros" de 25 minutos a sessão equivale.
  ///
  /// Arredonda para baixo: 49 minutos são 1 pomodoro, não 2.
  int get pomodoros => minutos ~/ 25;
}

enum ClassificacaoDeSessao { curta, ideal, longa, suspeita }

class SessaoInvalida implements Exception {
  const SessaoInvalida(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Agregados de uma lista de sessões.
///
/// Funções puras: mesma entrada, mesma saída, sem efeito colateral.
/// São as mais fáceis de testar que existem.
abstract final class Estatisticas {
  static int totalDeMinutos(List<Sessao> sessoes) =>
      sessoes.fold(0, (int soma, Sessao s) => soma + s.minutos);

  /// Média de minutos por sessão.
  ///
  /// Devolve 0 para lista vazia — dividir por zero daria NaN, e um
  /// NaN vazando para a tela vira "NaN min" na cara do usuário.
  double mediaDeMinutos(List<Sessao> sessoes) {
    if (sessoes.isEmpty) return 0;
    return totalDeMinutos(sessoes) / sessoes.length;
  }

  static Map<String, int> minutosPorMateria(List<Sessao> sessoes) {
    final Map<String, int> mapa = <String, int>{};
    for (final Sessao s in sessoes) {
      mapa[s.materiaId] = (mapa[s.materiaId] ?? 0) + s.minutos;
    }
    return mapa;
  }

  /// A matéria mais estudada. Null quando não há sessões.
  static String? materiaEmDestaque(List<Sessao> sessoes) {
    final Map<String, int> porMateria = minutosPorMateria(sessoes);
    if (porMateria.isEmpty) return null;

    String? melhor;
    int maiorTotal = -1;
    for (final MapEntry<String, int> e in porMateria.entries) {
      if (e.value > maiorTotal) {
        melhor = e.key;
        maiorTotal = e.value;
      }
    }
    return melhor;
  }

  /// Sequência de dias consecutivos com pelo menos uma sessão.
  ///
  /// A regra mais complexa daqui — e, por isso, a que mais precisa
  /// de teste.
  static int sequenciaDeDias(List<Sessao> sessoes, {DateTime? hoje}) {
    if (sessoes.isEmpty) return 0;

    final DateTime referencia = hoje ?? DateTime.now();
    final Set<int> diasComEstudo = sessoes
        .map((Sessao s) => DateTime(s.quando.year, s.quando.month, s.quando.day)
            .millisecondsSinceEpoch)
        .toSet();

    int sequencia = 0;
    DateTime dia = DateTime(referencia.year, referencia.month, referencia.day);

    while (diasComEstudo.contains(dia.millisecondsSinceEpoch)) {
      sequencia++;
      dia = dia.subtract(const Duration(days: 1));
    }

    return sequencia;
  }
}
```

> **Arquivo:** `foco_lab/test/sessao_test.dart` (novo)
> **Como executar:** `flutter test test/sessao_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_lab/dominio/sessao.dart';

void main() {
  /// Auxiliar que reduz a repetição.
  ///
  /// Sem ela, cada teste teria 4 linhas de preparação — e a intenção
  /// do teste se perderia no meio.
  Sessao criar({
    String materia = 'dart',
    int minutos = 25,
    DateTime? quando,
    String anotacao = '',
  }) {
    return Sessao(
      materiaId: materia,
      minutos: minutos,
      quando: quando ?? DateTime(2026, 3, 10, 14),
      anotacao: anotacao,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  group('Sessao — construtor', () {
    test('aceita uma sessão válida', () {
      final Sessao s = criar(minutos: 25);

      expect(s.minutos, 25);
      expect(s.materiaId, 'dart');
    });

    test('recusa matéria vazia', () {
      // ⚠️ Repare na FUNÇÃO ANÔNIMA: `() => criar(...)`.
      //
      // Sem ela, `criar(...)` rodaria imediatamente, lançaria, e o
      // teste falharia com a exceção crua — sem chegar no expect.
      expect(
        () => criar(materia: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('recusa matéria só com espaços', () {
      // Caso-limite que o `trim()` cobre e que quase ninguém testa.
      expect(() => criar(materia: '   '), throwsArgumentError);
    });

    test('recusa sessão de 0 minutos', () {
      expect(
        () => criar(minutos: 0),
        throwsA(isA<SessaoInvalida>().having(
          (SessaoInvalida e) => e.mensagem,
          'mensagem',
          contains('pelo menos'),
        )),
      );
    });

    test('recusa sessão negativa', () {
      expect(() => criar(minutos: -10), throwsA(isA<SessaoInvalida>()));
    });

    test('aceita exatamente o mínimo (1 minuto)', () {
      // Caso-limite: o valor EXATO da fronteira precisa passar.
      // É onde `<` e `<=` se confundem.
      expect(criar(minutos: 1).minutos, 1);
    });

    test('aceita exatamente o máximo (480 minutos)', () {
      expect(criar(minutos: 480).minutos, 480);
    });

    test('recusa um minuto acima do máximo', () {
      expect(() => criar(minutos: 481), throwsA(isA<SessaoInvalida>()));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Sessao — classificação', () {
    test('menos de 15 minutos é curta', () {
      expect(criar(minutos: 14).classificacao, ClassificacaoDeSessao.curta);
    });

    test('exatamente 15 minutos é ideal', () {
      // A fronteira entre curta e ideal.
      expect(criar(minutos: 15).classificacao, ClassificacaoDeSessao.ideal);
    });

    test('60 minutos ainda é ideal', () {
      expect(criar(minutos: 60).classificacao, ClassificacaoDeSessao.ideal);
    });

    test('61 minutos é longa', () {
      expect(criar(minutos: 61).classificacao, ClassificacaoDeSessao.longa);
    });

    test('acima de 240 minutos é suspeita', () {
      expect(criar(minutos: 241).classificacao, ClassificacaoDeSessao.suspeita);
    });

    test('produtiva a partir de 15 minutos', () {
      expect(criar(minutos: 14).produtiva, isFalse);
      expect(criar(minutos: 15).produtiva, isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Sessao — pomodoros', () {
    test('24 minutos não completam um pomodoro', () {
      expect(criar(minutos: 24).pomodoros, 0);
    });

    test('25 minutos completam exatamente um', () {
      expect(criar(minutos: 25).pomodoros, 1);
    });

    test('49 minutos ainda são um — arredonda para baixo', () {
      // O comportamento que o nome do teste DOCUMENTA.
      // Sem este teste, alguém "corrigiria" para arredondar para cima.
      expect(criar(minutos: 49).pomodoros, 1);
    });

    test('50 minutos são dois', () {
      expect(criar(minutos: 50).pomodoros, 2);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Sessao — mesmo dia', () {
    test('mesma data em horários diferentes é o mesmo dia', () {
      final Sessao s = criar(quando: DateTime(2026, 3, 10, 8));
      expect(s.ehDoMesmoDiaQue(DateTime(2026, 3, 10, 23, 59)), isTrue);
    });

    test('um minuto depois da meia-noite é outro dia', () {
      // O caso-limite clássico de data.
      final Sessao s = criar(quando: DateTime(2026, 3, 10, 23, 59));
      expect(s.ehDoMesmoDiaQue(DateTime(2026, 3, 11, 0, 1)), isFalse);
    });

    test('mesmo dia em meses diferentes NÃO é o mesmo dia', () {
      // Comparar só o `day` deixaria este passar. O teste existe
      // para impedir essa "simplificação".
      final Sessao s = criar(quando: DateTime(2026, 3, 10));
      expect(s.ehDoMesmoDiaQue(DateTime(2026, 4, 10)), isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Estatisticas.totalDeMinutos', () {
    test('lista vazia soma zero', () {
      // O caso-limite que mais quebra app: a lista vazia.
      expect(Estatisticas.totalDeMinutos(<Sessao>[]), 0);
    });

    test('soma os minutos de todas as sessões', () {
      final List<Sessao> sessoes = <Sessao>[
        criar(minutos: 25),
        criar(minutos: 50),
        criar(minutos: 15),
      ];

      expect(Estatisticas.totalDeMinutos(sessoes), 90);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Estatisticas.minutosPorMateria', () {
    test('lista vazia devolve mapa vazio', () {
      expect(Estatisticas.minutosPorMateria(<Sessao>[]), isEmpty);
    });

    test('agrupa e soma por matéria', () {
      final List<Sessao> sessoes = <Sessao>[
        criar(materia: 'dart', minutos: 25),
        criar(materia: 'dart', minutos: 35),
        criar(materia: 'flutter', minutos: 50),
      ];

      final Map<String, int> resultado =
          Estatisticas.minutosPorMateria(sessoes);

      // Comparação de mapa inteiro: mais expressiva que três expects.
      expect(resultado, <String, int>{'dart': 60, 'flutter': 50});
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Estatisticas.materiaEmDestaque', () {
    test('lista vazia devolve null', () {
      expect(Estatisticas.materiaEmDestaque(<Sessao>[]), isNull);
    });

    test('devolve a matéria com mais minutos', () {
      final List<Sessao> sessoes = <Sessao>[
        criar(materia: 'dart', minutos: 30),
        criar(materia: 'flutter', minutos: 90),
        criar(materia: 'git', minutos: 20),
      ];

      expect(Estatisticas.materiaEmDestaque(sessoes), 'flutter');
    });

    test('com uma matéria só, devolve ela', () {
      expect(
        Estatisticas.materiaEmDestaque(<Sessao>[criar(materia: 'dart')]),
        'dart',
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Estatisticas.sequenciaDeDias', () {
    // A regra mais complexa — e a que mais precisa de teste.
    //
    // Repare no `hoje:` injetado: sem ele, o teste dependeria da
    // data real e passaria a falhar amanhã. Injeção de dependência
    // aplicada ao RELÓGIO. Módulo 08, aula 10.
    final DateTime hoje = DateTime(2026, 3, 10);

    test('lista vazia é sequência zero', () {
      expect(Estatisticas.sequenciaDeDias(<Sessao>[], hoje: hoje), 0);
    });

    test('estudou só hoje: sequência de 1', () {
      final List<Sessao> sessoes = <Sessao>[criar(quando: hoje)];
      expect(Estatisticas.sequenciaDeDias(sessoes, hoje: hoje), 1);
    });

    test('três dias consecutivos: sequência de 3', () {
      final List<Sessao> sessoes = <Sessao>[
        criar(quando: DateTime(2026, 3, 10)),
        criar(quando: DateTime(2026, 3, 9)),
        criar(quando: DateTime(2026, 3, 8)),
      ];

      expect(Estatisticas.sequenciaDeDias(sessoes, hoje: hoje), 3);
    });

    test('um dia pulado INTERROMPE a sequência', () {
      final List<Sessao> sessoes = <Sessao>[
        criar(quando: DateTime(2026, 3, 10)),
        criar(quando: DateTime(2026, 3, 9)),
        // 8 de março faltando.
        criar(quando: DateTime(2026, 3, 7)),
        criar(quando: DateTime(2026, 3, 6)),
      ];

      // Só conta 10 e 9; o dia 8 quebra a corrente.
      expect(Estatisticas.sequenciaDeDias(sessoes, hoje: hoje), 2);
    });

    test('não estudou hoje: sequência zero, mesmo com ontem', () {
      // O comportamento que o nome documenta. Sem este teste, alguém
      // poderia "melhorar" a função para contar a partir de ontem —
      // e a tela passaria a mentir.
      final List<Sessao> sessoes = <Sessao>[
        criar(quando: DateTime(2026, 3, 9)),
        criar(quando: DateTime(2026, 3, 8)),
      ];

      expect(Estatisticas.sequenciaDeDias(sessoes, hoje: hoje), 0);
    });

    test('várias sessões no mesmo dia contam como um dia', () {
      final List<Sessao> sessoes = <Sessao>[
        criar(quando: DateTime(2026, 3, 10, 9)),
        criar(quando: DateTime(2026, 3, 10, 14)),
        criar(quando: DateTime(2026, 3, 10, 20)),
      ];

      expect(Estatisticas.sequenciaDeDias(sessoes, hoje: hoje), 1);
    });

    test('atravessa a virada do mês', () {
      // Caso-limite de data que quebra implementações ingênuas.
      final DateTime primeiroDeAbril = DateTime(2026, 4, 1);
      final List<Sessao> sessoes = <Sessao>[
        criar(quando: DateTime(2026, 4, 1)),
        criar(quando: DateTime(2026, 3, 31)),
        criar(quando: DateTime(2026, 3, 30)),
      ];

      expect(
        Estatisticas.sequenciaDeDias(sessoes, hoje: primeiroDeAbril),
        3,
      );
    });
  });
}
```

```powershell
flutter test test/sessao_test.dart
```

**O que observar:**

1. **Nenhum import de Flutter** no arquivo de domínio — é isso que faz o teste rodar em
   milissegundos.
2. Os testes de **caso-limite** (exatamente 15, exatamente 480, 481) são metade da suíte. É onde os
   bugs moram.
3. O `hoje:` injetado em `sequenciaDeDias`: sem ele, o teste passaria hoje e falharia amanhã.
4. Os nomes formam frases legíveis na saída — `Estatisticas.sequenciaDeDias um dia pulado
   INTERROMPE a sequência`.

---

## 📱 Aplicando no Flutter

Agora você testa uma regra de negócio **real** do Foco, com dependências injetadas — e um teste de
regressão para um bug corrigido.

---

## 💻 Código completo

> **Arquivo:** `foco_lab/lib/dominio/plano_de_estudo.dart` (novo)

```dart
import 'package:foco_lab/dominio/sessao.dart';

/// Distribui a meta diária entre as matérias.
///
/// Esta é a regra de negócio MAIS complexa do Foco — e, por isso, a
/// que mais precisa de teste. Ela decide o que o usuário vê na tela
/// inicial todo dia.
class PlanoDeEstudo {
  const PlanoDeEstudo({
    required this.metaDiariaMinutos,
    required this.materias,
  });

  final int metaDiariaMinutos;

  /// Matéria → meta própria em minutos.
  final Map<String, int> materias;

  /// Sugere quanto estudar de cada matéria hoje.
  ///
  /// Regras, em ordem de prioridade:
  ///  1. Matéria que já bateu a meta sai da sugestão;
  ///  2. O tempo restante é distribuído proporcionalmente ao que
  ///     FALTA em cada matéria;
  ///  3. Nenhuma sugestão fica abaixo de 5 minutos (abaixo disso,
  ///     não vale a pena sentar para estudar);
  ///  4. A soma nunca passa da meta diária.
  Map<String, int> sugerirPara(List<Sessao> sessoesDeHoje) {
    final Map<String, int> jaEstudado =
        Estatisticas.minutosPorMateria(sessoesDeHoje);

    final int totalHoje = Estatisticas.totalDeMinutos(sessoesDeHoje);
    final int restanteDoDia = metaDiariaMinutos - totalHoje;

    // Meta do dia já batida: nada a sugerir.
    if (restanteDoDia <= 0) return <String, int>{};

    // Regra 1: quanto falta em cada matéria.
    final Map<String, int> faltando = <String, int>{};
    for (final MapEntry<String, int> e in materias.entries) {
      final int falta = e.value - (jaEstudado[e.key] ?? 0);
      if (falta > 0) faltando[e.key] = falta;
    }

    if (faltando.isEmpty) return <String, int>{};

    final int totalFaltando =
        faltando.values.fold(0, (int s, int v) => s + v);

    // Regra 2: distribuição proporcional.
    final Map<String, int> sugestao = <String, int>{};
    for (final MapEntry<String, int> e in faltando.entries) {
      final int proporcional =
          (restanteDoDia * e.value / totalFaltando).round();

      // Regra 3: piso de 5 minutos.
      if (proporcional >= 5) {
        sugestao[e.key] = proporcional;
      }
    }

    // Regra 4: o arredondamento pode ter estourado a meta.
    // Ajusta na matéria com maior sugestão.
    final int somaSugerida = sugestao.values.fold(0, (int s, int v) => s + v);
    if (somaSugerida > restanteDoDia && sugestao.isNotEmpty) {
      final String maior = sugestao.entries
          .reduce((MapEntry<String, int> a, MapEntry<String, int> b) =>
              a.value >= b.value ? a : b)
          .key;
      sugestao[maior] = sugestao[maior]! - (somaSugerida - restanteDoDia);

      // O ajuste pode ter derrubado abaixo do piso.
      if (sugestao[maior]! < 5) sugestao.remove(maior);
    }

    return sugestao;
  }

  /// Progresso do dia, entre 0 e 1.
  double progressoDe(List<Sessao> sessoesDeHoje) {
    if (metaDiariaMinutos <= 0) return 0;
    final int total = Estatisticas.totalDeMinutos(sessoesDeHoje);
    return (total / metaDiariaMinutos).clamp(0.0, 1.0);
  }
}
```

> **Arquivo:** `foco_lab/test/plano_de_estudo_test.dart` (novo)

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_lab/dominio/plano_de_estudo.dart';
import 'package:foco_lab/dominio/sessao.dart';

void main() {
  late PlanoDeEstudo plano;

  // setUp (não setUpAll): cada teste ganha um plano NOVO.
  //
  // Com setUpAll, um teste que modificasse o mapa contaminaria os
  // seguintes — e a suíte passaria a depender da ORDEM.
  setUp(() {
    plano = const PlanoDeEstudo(
      metaDiariaMinutos: 120,
      materias: <String, int>{
        'dart': 60,
        'flutter': 60,
        'git': 30,
      },
    );
  });

  Sessao sessao(String materia, int minutos) => Sessao(
        materiaId: materia,
        minutos: minutos,
        quando: DateTime(2026, 3, 10, 14),
      );

  // ══════════════════════════════════════════════════════════════════
  group('sugerirPara — casos-limite', () {
    test('sem sessões, distribui a meta inteira', () {
      final Map<String, int> s = plano.sugerirPara(<Sessao>[]);

      // 120 min distribuídos proporcionalmente a 60/60/30 (total 150):
      //   dart:    120 × 60/150 = 48
      //   flutter: 120 × 60/150 = 48
      //   git:     120 × 30/150 = 24
      expect(s, <String, int>{'dart': 48, 'flutter': 48, 'git': 24});
    });

    test('a soma nunca passa da meta diária', () {
      final Map<String, int> s = plano.sugerirPara(<Sessao>[]);
      final int soma = s.values.fold(0, (int a, int b) => a + b);

      expect(soma, lessThanOrEqualTo(120));
    });

    test('meta do dia batida: nenhuma sugestão', () {
      final List<Sessao> hoje = <Sessao>[
        sessao('dart', 60),
        sessao('flutter', 60),
      ];

      expect(plano.sugerirPara(hoje), isEmpty);
    });

    test('meta ULTRAPASSADA: também nenhuma sugestão', () {
      // Caso-limite: restanteDoDia fica NEGATIVO.
      // Sem a guarda `<= 0`, a proporção daria números negativos.
      final List<Sessao> hoje = <Sessao>[
        sessao('dart', 200),
      ];

      expect(plano.sugerirPara(hoje), isEmpty);
    });

    test('matéria que bateu a própria meta sai da sugestão', () {
      final List<Sessao> hoje = <Sessao>[sessao('git', 30)];

      final Map<String, int> s = plano.sugerirPara(hoje);

      expect(s.containsKey('git'), isFalse);
      expect(s.keys, containsAll(<String>['dart', 'flutter']));
    });

    test('todas as metas batidas: nenhuma sugestão', () {
      final List<Sessao> hoje = <Sessao>[
        sessao('dart', 60),
        sessao('flutter', 60),
        sessao('git', 30),
      ];

      expect(plano.sugerirPara(hoje), isEmpty);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('sugerirPara — piso de 5 minutos', () {
    test('sugestão abaixo de 5 minutos é descartada', () {
      // Com quase tudo estudado, a proporção de uma matéria fica
      // minúscula. Sugerir "estude 2 minutos de Git" é ruído.
      final PlanoDeEstudo p = const PlanoDeEstudo(
        metaDiariaMinutos: 10,
        materias: <String, int>{'dart': 100, 'git': 1},
      );

      final Map<String, int> s = p.sugerirPara(<Sessao>[]);

      // git receberia 10 × 1/101 = 0,099 → 0. Descartado.
      expect(s.containsKey('git'), isFalse);
      expect(s['dart'], greaterThanOrEqualTo(5));
    });

    test('nenhuma sugestão fica abaixo do piso', () {
      final Map<String, int> s = plano.sugerirPara(<Sessao>[
        sessao('dart', 55),
        sessao('flutter', 55),
      ]);

      for (final int minutos in s.values) {
        expect(minutos, greaterThanOrEqualTo(5));
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('progressoDe', () {
    test('sem sessões, progresso zero', () {
      expect(plano.progressoDe(<Sessao>[]), 0);
    });

    test('metade da meta, progresso 0.5', () {
      expect(plano.progressoDe(<Sessao>[sessao('dart', 60)]), 0.5);
    });

    test('meta batida, progresso 1.0', () {
      expect(plano.progressoDe(<Sessao>[sessao('dart', 120)]), 1.0);
    });

    test('meta ultrapassada não passa de 1.0', () {
      // Sem o clamp, a barra de progresso ficaria com 250% —
      // e o LinearProgressIndicator lançaria assertion error.
      expect(plano.progressoDe(<Sessao>[sessao('dart', 300)]), 1.0);
    });

    test('meta zero não divide por zero', () {
      // Sem a guarda, isto daria NaN — e "NaN%" apareceria na tela.
      const PlanoDeEstudo p =
          PlanoDeEstudo(metaDiariaMinutos: 0, materias: <String, int>{});

      expect(p.progressoDe(<Sessao>[sessao('dart', 25)]), 0);
    });

    test('progresso parcial com precisão de ponto flutuante', () {
      // ⚠️ closeTo, não igualdade exata.
      //
      // 40/120 = 0.3333333333333333, e comparar com 0.3333 falharia.
      // Ponto flutuante NUNCA se compara com igualdade.
      expect(
        plano.progressoDe(<Sessao>[sessao('dart', 40)]),
        closeTo(0.333, 0.001),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('regressão', () {
    // ⚠️ TESTE DE REGRESSÃO.
    //
    // Bug real corrigido em 10/03/2026: com uma única matéria faltando,
    // o ajuste da regra 4 derrubava a sugestão para abaixo do piso e
    // a removia — e a tela ficava VAZIA, com o usuário sem saber o que
    // estudar.
    //
    // Este é o teste mais valioso da suíte: ele é a PROVA de que o
    // problema existia, e o alarme se ele voltar.
    test('uma matéria faltando ainda recebe sugestão', () {
      final List<Sessao> hoje = <Sessao>[
        sessao('dart', 60),
        sessao('flutter', 60),
        // git ainda tem 30 minutos faltando, mas a meta diária
        // (120) já foi batida.
      ];

      final Map<String, int> s = plano.sugerirPara(hoje);

      // Meta do dia batida: vazio é o comportamento CERTO.
      // O bug era devolver vazio em outro cenário.
      expect(s, isEmpty);
    });

    test('meta diária maior que a soma das metas das matérias', () {
      // Cenário que o arredondamento quebrava: a proporção somava
      // mais que o restante do dia.
      const PlanoDeEstudo p = PlanoDeEstudo(
        metaDiariaMinutos: 300,
        materias: <String, int>{'dart': 60, 'flutter': 60},
      );

      final Map<String, int> s = p.sugerirPara(<Sessao>[]);
      final int soma = s.values.fold(0, (int a, int b) => a + b);

      expect(soma, lessThanOrEqualTo(300));
      expect(s, isNotEmpty, reason: 'deve sugerir algo');
    });
  });
}
```

Rode e explore:

```powershell
flutter test

# Só os testes de sequência.
flutter test --plain-name "sequência"

# Só os de regressão.
flutter test --plain-name "regressão"

# Com cobertura.
flutter test --coverage
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Domínio **sem import de Flutter** | É o que faz o teste rodar em milissegundos, na base da pirâmide. |
| Guardas no **construtor** | Um objeto inválido nunca existe. Validar em quem cria garante que um dia alguém esqueça. |
| Função auxiliar `criar({...})` | Sem ela, cada teste teria 4 linhas de preparação e a intenção se perderia. |
| `() => criar(materia: '')` no `expect` | **Função anônima obrigatória.** Sem ela, a chamada roda antes do `expect` e o teste falha com a exceção crua. |
| Testes de **fronteira exata** (15, 480, 481) | É onde `<` e `<=` se confundem. Metade da suíte, e a metade que pega bug. |
| `hoje:` injetado em `sequenciaDeDias` | Sem isso, o teste passaria hoje e falharia amanhã. Injeção de dependência aplicada ao **relógio**. |
| `setUp` (não `setUpAll`) | Cada teste ganha um objeto novo. `setUpAll` faria a suíte depender da **ordem**. |
| `expect(resultado, <String, int>{...})` | Comparar o mapa inteiro é mais expressivo que três `expect` separados. |
| `closeTo(0.333, 0.001)` | Ponto flutuante **nunca** se compara com igualdade: `40/120` é `0.3333333333333333`. |
| `lessThanOrEqualTo` no lugar de `<` | A mensagem de falha diz o valor real; `expect(soma < 120, true)` diria só `false`. |
| Teste "meta ultrapassada" | `restanteDoDia` fica **negativo**. Sem a guarda, a proporção daria números negativos. |
| Teste "meta zero" | Sem a guarda, o resultado é `NaN` — e "NaN%" aparece na tela. |
| Teste "não passa de 1.0" | Sem o `clamp`, o `LinearProgressIndicator` lança *assertion error*. |
| `group('regressão')` com data e descrição do bug | O teste mais valioso da suíte: prova que o problema existiu, e alarme se voltar. |
| `reason: 'deve sugerir algo'` | Aparece na mensagem de falha. Vale em `expect` cujo motivo não é óbvio. |

---

## ⚠️ Erros comuns

### 1. Esquecer a função anônima ao testar exceção

```dart
expect(criar(minutos: 0), throwsA(isA<SessaoInvalida>()));   // ❌
```

A chamada roda **antes** do `expect` e lança direto.

**Correção:** `expect(() => criar(minutos: 0), ...)`.

### 2. Esquecer o `await` no `expectLater`

```dart
expectLater(repo.listar(), throwsA(isA<Falha>()));   // ❌
```

O teste termina antes de o `Future` completar e **passa mesmo errado**.

**Correção:** `await expectLater(...)`. O lint `unawaited_futures` pega.

### 3. Comparar ponto flutuante com igualdade

```dart
expect(0.1 + 0.2, 0.3);   // ❌ falha
```

**Correção:** `closeTo(0.3, 0.0001)`.

### 4. `expect(condicao, true)`

```dart
expect(lista.length > 0, true);   // ❌
// Expected: <true>  Actual: <false>
```

**Correção:** `expect(lista, isNotEmpty)` — a mensagem passa a dizer o que aconteceu.

### 5. Testar com `DateTime.now()`

```dart
test('sequência de hoje', () {
  expect(Estatisticas.sequenciaDeDias(sessoes), 3);   // ⚠️ falha amanhã
});
```

**Correção:** injete o relógio (`hoje:`).

### 6. `setUpAll` com estado mutável

O teste 1 modifica, o teste 2 recebe modificado, a suíte passa a depender da ordem.

**Correção:** `setUp`, ou `setUpAll` só para coisas imutáveis.

### 7. Nome de teste que não diz nada

`test('teste 2')` — quando falha, você não sabe o quê.

**Correção:** `<ação> <resultado esperado>`.

### 8. Testar getter trivial

```dart
test('nome devolve o nome', () => expect(m.nome, 'Dart'));   // ⚠️
```

Testa o compilador.

**Correção:** teste comportamento, não atribuição.

### 9. Perseguir 100% de cobertura

Ela mede **linhas executadas**, não comportamentos verificados. Um teste que roda a linha sem
verificar nada conta igual.

**Correção:** cubra as regras de negócio e os casos-limite; ignore o resto.

### 10. Não testar a lista vazia

É o caso que mais quebra app em produção.

**Correção:** todo teste de coleção começa com o caso vazio.

### 11. Testar método privado

```dart
// impossível, e é assim mesmo
expect(objeto._metodoPrivado(), 42);
```

**Correção:** teste o comportamento público que o usa. Se não dá, o método provavelmente deveria
ser público — ou estar em outra classe.

### 12. Não escrever teste ao corrigir bug

O bug volta em três meses.

**Correção:** o teste de regressão é o mais valioso da suíte.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test test/sessao_test.dart`. Quantos testes passaram? Quanto tempo levou?

**Passo 2.** Quebre uma regra de propósito: mude `minimoDeMinutos` para 0. Quais testes falham?
Leia as mensagens.

**Passo 3.** Remova a função anônima de um teste de exceção. Rode e leia a falha.

**Passo 4.** Troque `closeTo` por igualdade exata no teste de progresso parcial. Rode.

**Passo 5.** Remova o parâmetro `hoje:` de `sequenciaDeDias` e use `DateTime.now()`. Rode hoje;
depois mude o relógio do sistema para amanhã e rode de novo.

**Passo 6.** Troque um `setUp` por `setUpAll` no `plano_de_estudo_test.dart`. Acrescente um teste
que modifique o mapa `materias`. Rode a suíte duas vezes.

**Passo 7.** Escreva um teste para o caso: meta diária de 1 minuto, três matérias. O que a função
faz? É o comportamento certo?

**Passo 8.** Rode `flutter test --coverage` e abra `coverage/lcov.info`. Quais linhas não foram
cobertas? Elas merecem teste?

**Passo 9.** Encontre um bug real no seu código (ou plante um) e escreva o teste de regressão
**antes** de corrigir. Confirme que ele falha, corrija, confirme que passa.

**Passo 10.** Escreva cinco nomes de teste para a função `pomodoros`, seguindo o padrão
`<ação> <resultado esperado>`.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

Faça os exercícios de **Aplicação** com regras de negócio, o de **Casos-limite**, e o de
**Regressão** a partir de um bug dado.

---

## 🏆 Desafio opcional

Escreva um **teste baseado em propriedades** para `PlanoDeEstudo.sugerirPara`.

Em vez de testar casos específicos, verifique **invariantes** que devem valer para **qualquer**
entrada:

- a soma das sugestões **nunca** passa do restante da meta diária;
- nenhuma sugestão fica abaixo de 5 minutos;
- nenhuma matéria que já bateu a própria meta aparece;
- se há tempo restante e alguma matéria faltando, a sugestão **não** é vazia;
- a função **nunca** lança, para nenhuma entrada válida.

Gere 1 000 entradas aleatórias (metas, matérias e sessões variadas) e verifique as cinco
invariantes em todas.

Dica: `Random(42)` com semente fixa faz a geração ser **reproduzível** — quando um caso falha, você
consegue rodar de novo e depurar. Sem a semente, o teste falha uma vez e você nunca mais reproduz.

Depois responda: as 1 000 entradas encontraram algum caso que os seus testes manuais não cobriam?
E o que isso diz sobre escrever casos de teste à mão?

---

## 📌 Resumo

- A **pirâmide de testes**: muitos unitários (rápidos), alguns de widget, poucos de integração.
- **Se o teste demora, ele não é rodado. Se não é rodado, não protege nada.**
- A estrutura de todo teste: **Arrange, Act, Assert**.
- O **nome do teste é documentação**: `<ação> <resultado esperado>`, sem "deve" nem "testa que".
- Use o **matcher certo** — `isNotEmpty` em vez de `length > 0`. A mensagem de falha melhora muito.
- **Ponto flutuante nunca se compara com igualdade.** Use `closeTo`.
- Testar exceção exige **função anônima**: `expect(() => f(), throwsA(...))`.
- Testar `Future` exige **`await expectLater`**.
- **`setUp`**, não `setUpAll`, quando o objeto é mutável — senão a suíte depende da ordem.
- **`addTearDown`** junto da criação é mais seguro que `tearDown` no topo.
- **Injete o relógio** em qualquer função que dependa de data — senão o teste falha amanhã.
- **Sempre teste a lista vazia.** É o caso que mais quebra app.
- **Sempre teste as fronteiras exatas** (o valor mínimo, o máximo, e um a mais).
- **Não teste** getters triviais, código de terceiros, constantes nem layout exato.
- **Cobertura de 100% é um mau objetivo:** ela mede linhas executadas, não comportamentos.
- **O teste mais valioso é o de regressão**, escrito logo depois de corrigir um bug.

---

## ☑️ Checklist de domínio

- [ ] Explico a pirâmide de testes e por que a base é larga.
- [ ] Escrevo testes com Arrange, Act, Assert.
- [ ] Meus nomes de teste descrevem comportamento.
- [ ] Escolho o matcher certo em vez de `expect(cond, true)`.
- [ ] Uso `closeTo` para ponto flutuante.
- [ ] Testo exceção com função anônima.
- [ ] Uso `await expectLater` para `Future`.
- [ ] Uso `setUp` para estado mutável.
- [ ] Injeto o relógio em funções que dependem de data.
- [ ] Sempre testo lista vazia e fronteiras exatas.
- [ ] Sei o que não vale testar.
- [ ] Escrevo teste de regressão ao corrigir bug.
- [ ] Rodo `flutter test` antes de cada commit.

---

## 📚 Referências oficiais

- [An introduction to unit testing — docs.flutter.dev](https://docs.flutter.dev/cookbook/testing/unit/introduction)
- [Testing Flutter apps — docs.flutter.dev](https://docs.flutter.dev/testing/overview)
- [package:test — pub.dev](https://pub.dev/packages/test)
- [Matchers — api.flutter.dev](https://api.flutter.dev/flutter/package-matcher_matcher/package-matcher_matcher-library.html)
- [Effective Dart: Testing — dart.dev](https://dart.dev/guides/testing)
- [flutter test — docs.flutter.dev](https://docs.flutter.dev/reference/flutter-cli)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 4 — Análise, lint e formatação](04-analise-lint-formatacao.md) | [README](README.md) | [Aula 6 — Testes de widget](06-testes-de-widget.md) |
