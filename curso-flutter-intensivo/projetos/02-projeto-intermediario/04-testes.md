# Testes — Projeto 02: Bloco de Notas de Estudo

> 📌 Você já viu as aulas [5](../../modulos/12-testes-e-debug/05-testes-unitarios.md) e
> [6](../../modulos/12-testes-e-debug/06-testes-de-widget.md) do módulo 12. Aqui elas viram arquivos
> de verdade, cobrindo o que quebra calado: serialização, arquivo corrompido e validação.

> 🪟 `flutter test` roda no seu Windows, sem emulador e sem Mac. Mac só entra para gerar o `.ipa`,
> no [módulo 15](../../modulos/15-build-ios/README.md).

---

## 🧪 O que testar e em que nível

| O quê | Nível | Por quê |
|---|---|---|
| `paraMapa`, `doMapa`, `copyWith`, `==` | Unitário | Único ponto onde o dado do disco vira objeto. Errar aqui apaga notas (RF17, RF20, RF21). |
| `NotasRepositorio` inteiro | Unitário, com `setMockInitialValues` | O construtor recebe o `SharedPreferences`: testa tudo sem plugin nativo. |
| `NotaFormScreen`: validação e retorno | Widget | A regra só existe quando o `Form` roda; teste unitário não vê a mensagem na tela. |
| Aparência de `CartaoNota` e `ChipEtiqueta` | **Nenhum** | Cor e espaçamento mudam toda semana. Testar pixel é comprar manutenção. |
| `HomeScreen` com `Dismissible` e `SnackBar` | Integração — **fora daqui** | É a [aula 8 do M12](../../modulos/12-testes-e-debug/08-testes-de-integracao.md). |

---

## 📦 Preparando

Nada muda no `pubspec.yaml`: o `flutter create` já deixou o necessário.

```yaml
dev_dependencies:
  flutter_test:   # test, group, expect, testWidgets e o WidgetTester
    sdk: flutter
  flutter_lints: ^6.0.0
```

- **`setMockInitialValues`** não é pacote à parte: vem dentro do próprio `shared_preferences`, que já
  é dependência normal do app.
- **`mocktail` não entra aqui.** `NotasRepositorio` recebe o `SharedPreferences` pelo construtor, e o
  armazenamento em memória do plugin já é o dublê. Mock de verdade é a
  [aula 7 do M12](../../modulos/12-testes-e-debug/07-mocks-e-fakes.md), no Projeto 3.

Três arquivos em `test/`: `nota_test.dart` (modelo e JSON), `notas_repositorio_test.dart` (leitura
tolerante, gravação, ordenação) e `nota_form_screen_test.dart` (validação e resultado do `pop`).

---

## 1. Testes unitários

### test/nota_test.dart

```dart
import 'dart:convert';

import 'package:bloco_notas/features/notas/domain/etiqueta.dart';
import 'package:bloco_notas/features/notas/domain/nota.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Data FIXA: `DateTime.now()` no teste é o que faz ele passar hoje e falhar
  // na virada do ano.
  final DateTime criada = DateTime(2026, 9, 14, 22, 43);

  Nota exemplo({String id = '1757890980000000'}) => Nota(
        id: id,
        titulo: 'Ciclo de vida do State',
        conteudo: 'initState roda uma vez.',
        etiqueta: Etiqueta.aula,
        criadaEm: criada,
        atualizadaEm: DateTime(2026, 9, 15, 8, 5),
      );

  // `paraMapa` devolve um mapa NOVO a cada chamada: dá para editar à vontade.
  Map<String, Object?> mapa() => exemplo().paraMapa();

  group('Nota — serialização', () {
    test('paraMapa só usa tipos que o jsonEncode aceita', () {
      expect(mapa()['etiqueta'], 'aula');
      expect(mapa()['criadaEm'], criada.toIso8601String());
      // Um DateTime ou uma Etiqueta crus no mapa fariam esta linha lançar.
      expect(() => jsonEncode(mapa()), returnsNormally);
    });

    test('ida e volta pelo JSON devolve uma nota igual', () {
      final Map<String, Object?> cru =
          jsonDecode(jsonEncode(mapa())) as Map<String, Object?>;

      // Só passa porque Nota tem == por valor: um id diferente já não bate.
      expect(Nota.doMapa(cru), exemplo());
      expect(Nota.doMapa(cru), isNot(exemplo(id: 'outro')));
      expect(exemplo().hashCode, exemplo().hashCode);
    });
  });

  group('Nota.doMapa — entrada estragada (RF21)', () {
    test('sem id devolve null', () {
      expect(Nota.doMapa(mapa()..remove('id')), isNull);
    });

    test('título só com espaços devolve null', () {
      expect(Nota.doMapa(mapa()..['titulo'] = '   '), isNull);
    });

    test('data que o tryParse não entende devolve null', () {
      expect(Nota.doMapa(mapa()..['criadaEm'] = 'ontem'), isNull);
    });

    test('etiqueta desconhecida vira resumo, sem invalidar a nota', () {
      expect(Nota.doMapa(mapa()..['etiqueta'] = 'roxo')?.etiqueta,
          Etiqueta.resumo);
    });
  });

  test('copyWith preserva id e criadaEm e muda só o resto (RF17)', () {
    final DateTime agora = DateTime(2026, 10, 1, 9, 12);
    final Nota editada =
        exemplo().copyWith(titulo: 'Revisado', atualizadaEm: agora);

    expect(editada.id, exemplo().id);
    expect(editada.criadaEm, criada);
    expect(editada.conteudo, exemplo().conteudo);
    expect(editada.titulo, 'Revisado');
    expect(editada.atualizadaEm, agora);
  });
}
```

### test/notas_repositorio_test.dart

```dart
import 'dart:convert';

import 'package:bloco_notas/features/notas/data/notas_repositorio.dart';
import 'package:bloco_notas/features/notas/domain/etiqueta.dart';
import 'package:bloco_notas/features/notas/domain/nota.dart';
import 'package:bloco_notas/features/notas/domain/ordenacao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // shared_preferences fala com o nativo por um canal de plataforma. Sem o
  // binding iniciado, nem o canal FALSO existe.
  TestWidgetsFlutterBinding.ensureInitialized();

  Nota nota(String id) => Nota(
        id: id,
        titulo: 'Nota $id',
        conteudo: 'Conteúdo da nota $id',
        etiqueta: Etiqueta.resumo,
        criadaEm: DateTime(2026, 9, 14, 22, 43),
        atualizadaEm: DateTime(2026, 9, 14, 22, 43),
      );

  /// Monta o repositório sobre um "disco" em memória com o conteúdo pedido.
  Future<NotasRepositorio> comDisco(Map<String, Object> disco) async {
    SharedPreferences.setMockInitialValues(disco);
    return NotasRepositorio(await SharedPreferences.getInstance());
  }

  late NotasRepositorio repositorio;

  // `setMockInitialValues` zera o cache do `getInstance`: cada teste começa com
  // um disco limpo e independente.
  setUp(() async => repositorio = await comDisco(<String, Object>{}));

  group('lerNotas', () {
    test('disco vazio devolve lista vazia', () {
      expect(repositorio.lerNotas(), isEmpty);
    });

    test('grava e lê a mesma lista', () async {
      final List<Nota> notas = <Nota>[nota('1'), nota('2')];
      await repositorio.salvarNotas(notas);
      expect(repositorio.lerNotas(), notas);
    });

    test('texto corrompido devolve lista vazia, sem lançar (RF20)', () async {
      repositorio = await comDisco(<String, Object>{
        NotasRepositorio.chaveNotas: '[{"id": "1", "titulo"',
      });
      expect(repositorio.lerNotas(), isEmpty);
    });

    test('JSON que não é uma lista devolve lista vazia', () async {
      repositorio = await comDisco(<String, Object>{
        NotasRepositorio.chaveNotas: '{"id":"1"}',
      });
      expect(repositorio.lerNotas(), isEmpty);
    });

    test('item quebrado é descartado e os bons continuam (RF21)', () async {
      repositorio = await comDisco(<String, Object>{
        NotasRepositorio.chaveNotas: jsonEncode(<Object?>[
          nota('1').paraMapa(),
          <String, Object?>{'id': '2'}, // faltam campos obrigatórios
          'isto não é nem um objeto',
          nota('3').paraMapa(),
        ]),
      });
      expect(repositorio.lerNotas(), <Nota>[nota('1'), nota('3')]);
    });
  });

  group('salvarNotas', () {
    test('recusa id repetido (RF22)', () async {
      // O erro nasce DENTRO de um Future: quem verifica isso é o expectLater.
      await expectLater(
        repositorio.salvarNotas(<Nota>[nota('1'), nota('1')]),
        throwsArgumentError,
      );
    });

    test('aceita o limite de 200 e recusa a nota 201 (RF23)', () async {
      final List<Nota> cheia = <Nota>[
        for (int i = 0; i < NotasRepositorio.maxNotas; i++) nota('$i'),
      ];
      await repositorio.salvarNotas(cheia);
      expect(repositorio.lerNotas(), hasLength(NotasRepositorio.maxNotas));

      await expectLater(
        repositorio.salvarNotas(<Nota>[...cheia, nota('extra')]),
        throwsArgumentError,
      );
    });
  });

  test('ordenação: padrão maisRecente, grava e lê a escolha (RF06)', () async {
    expect(repositorio.lerOrdenacao(), Ordenacao.maisRecente);
    await repositorio.salvarOrdenacao(Ordenacao.tituloAZ);
    expect(repositorio.lerOrdenacao(), Ordenacao.tituloAZ);
  });
}
```

---

## 2. Testes de widget

### test/nota_form_screen_test.dart

```dart
import 'package:bloco_notas/features/notas/domain/etiqueta.dart';
import 'package:bloco_notas/features/notas/domain/nota.dart';
import 'package:bloco_notas/features/notas/presentation/nota_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Key titulo = Key('campo_titulo');
  const Key conteudo = Key('campo_conteudo');
  const Key salvar = Key('botao_salvar');

  // O que o formulário devolveu no pop. É uma LISTA porque a atribuição
  // acontece depois que a função que abriu a tela já retornou.
  late List<Nota?> devolvido;

  setUp(() => devolvido = <Nota?>[]);

  /// Abre a `NotaFormScreen` EMPILHADA sobre outra tela. Montá-la direto no
  /// `home:` não serve: sem rota embaixo, o `pop` não tem para onde devolver.
  Future<void> abrir(WidgetTester t, NotaFormArgs args) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => FilledButton(
              key: const Key('abrir'),
              onPressed: () async => devolvido.add(
                await Navigator.of(context).push<Nota>(
                  MaterialPageRoute<Nota>(
                    builder: (_) => NotaFormScreen(args: args),
                  ),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.byKey(const Key('abrir')));
    // pumpAndSettle porque a transição de rota é uma animação FINITA.
    await t.pumpAndSettle();
  }

  testWidgets('abre sem erro e salvar em branco não fecha a tela (RF16)',
      (WidgetTester t) async {
    await abrir(t, const NotaFormArgs.criar());
    expect(find.text('Nova nota'), findsOneWidget);
    expect(find.text('Informe um título'), findsNothing); // ainda não tentou

    await t.tap(find.byKey(salvar));
    await t.pump(); // sem este quadro o erro não chega à tela

    expect(find.text('Informe um título'), findsOneWidget);
    expect(find.text('Escreva alguma coisa'), findsOneWidget);
    expect(find.byKey(titulo), findsOneWidget); // a tela continua de pé
    expect(devolvido, isEmpty);
  });

  testWidgets('título de 2 letras é recusado (RF13)', (WidgetTester t) async {
    await abrir(t, const NotaFormArgs.criar());

    await t.enterText(find.byKey(titulo), 'Ab');
    await t.enterText(find.byKey(conteudo), 'Conteúdo qualquer');
    await t.pump();
    await t.tap(find.byKey(salvar));
    await t.pump();

    expect(find.text('Use pelo menos 3 caracteres'), findsOneWidget);
    expect(devolvido, isEmpty);
  });

  testWidgets('salvar válido devolve a Nota com trim (RF15, RF17)',
      (WidgetTester t) async {
    await abrir(t, const NotaFormArgs.criar());

    await t.enterText(find.byKey(titulo), '  Ciclo de vida  ');
    await t.enterText(find.byKey(conteudo), '  initState roda  ');
    await t.pump();
    await t.tap(find.byKey(salvar));
    await t.pumpAndSettle(); // a tela fecha: espere a animação acabar

    final Nota? nota = devolvido.single;
    expect(nota, isNotNull);
    expect(nota!.titulo, 'Ciclo de vida');
    expect(nota.conteudo, 'initState roda');
    expect(nota.etiqueta, Etiqueta.resumo); // padrão da criação
    expect(nota.criadaEm, nota.atualizadaEm); // nota nova
  });

  testWidgets('edição vem preenchida e preserva id e criadaEm (RF12)',
      (WidgetTester t) async {
    final Nota original = Nota(
      id: '42',
      titulo: 'Rotas nomeadas',
      conteudo: 'onGenerateRoute devolve a Route certa.',
      etiqueta: Etiqueta.aula,
      criadaEm: DateTime(2026, 9, 1, 10, 30),
      atualizadaEm: DateTime(2026, 9, 1, 10, 30),
    );

    await abrir(t, NotaFormArgs.editar(original));
    expect(find.text('Editar nota'), findsOneWidget);
    expect(find.text('Rotas nomeadas'), findsOneWidget);

    await t.enterText(find.byKey(titulo), 'Rotas revisadas');
    await t.pump();
    await t.tap(find.byKey(salvar));
    await t.pumpAndSettle();

    final Nota salva = devolvido.single!;
    expect(salva.id, original.id);
    expect(salva.criadaEm, original.criadaEm);
    expect(salva.titulo, 'Rotas revisadas');
    // A única data que muda é a de atualização.
    expect(salva.atualizadaEm.isAfter(original.atualizadaEm), isTrue);
  });
}
```

> ⚠️ O `PopScope` **não** bloqueia o `Navigator.pop(nota)` do botão Salvar — ele intercepta só o
> botão do sistema e o gesto de borda. Por isso o teste passa com `_temAlteracoes` valendo `true`.

---

## ▶️ Rodando

```bash
flutter test                                  # tudo de uma vez
flutter test test/nota_form_screen_test.dart  # um arquivo: o ciclo rápido
flutter test --name "id repetido"             # só os testes com esse nome
flutter analyze                               # o analisador faz parte do verde
```

Saída boa é uma linha só, com o `+` crescendo e nenhum `-`:

```text
00:03 +16: All tests passed!
```

Quando algo quebra, vem o `-1`, o nome do caso e a diferença:

```text
00:02 +7 -1: Nota.doMapa — entrada estragada (RF21) sem id devolve null [E]
  Expected: null
    Actual: Instance of 'Nota'
```

O nome do teste é a primeira informação do erro — por isso ele descreve a **regra**, não o método.

---

## ⚠️ Erros comuns nestes testes

| Sintoma | Causa | Correção |
|---|---|---|
| `MissingPluginException (getAll)` | O `getInstance` procurando o plugin nativo, que não existe no `flutter test` | `TestWidgetsFlutterBinding.ensureInitialized()` no topo do `main` e `setMockInitialValues` **antes** de cada `getInstance` |
| A mensagem do validador não é encontrada (`findsNothing`) | `tap` e `enterText` mudam o estado, mas não desenham quadro | `await t.pump()` depois de **toda** interação |
| O teste de `ArgumentError` passa mesmo com o bug | `salvarNotas` é `async`: o erro vai para o `Future`, não para o `expect` síncrono | `await expectLater(repositorio.salvarNotas(...), throwsArgumentError)` |
| `devolvido` fica vazio no teste de retorno | A tela virou o `home:` do `MaterialApp` — sem rota embaixo, o `pop` não devolve nada | Empilhe com `Navigator.push<Nota>`, como no `abrir` |
| Passa hoje, falha amanhã | `DateTime.now()` dentro do `expect` | Datas fixas; para "agora", compare com `isAfter` |
| `pumpAndSettle timed out` ao testar a `HomeScreen` | O `CircularProgressIndicator` gira para sempre: nunca estabiliza | `await t.pump()` (um quadro) ou `pump(Duration(...))` — nunca `pumpAndSettle` com animação infinita |

---

| # | Arquivo | Conteúdo |
|---|---|---|
| — | [README.md](README.md) | Visão geral do projeto |
| 01 | [01-especificacao.md](01-especificacao.md) | Requisitos e modelo de dados |
| 02 | [02-passo-a-passo.md](02-passo-a-passo.md) | Construção guiada, do `flutter create` ao app rodando |
| 03 | [03-codigo-completo.md](03-codigo-completo.md) | Todos os arquivos finais de `lib/` |
| 04 | **04-testes.md** | 📍 Você está aqui |
| 05 | [05-desafios.md](05-desafios.md) | Extensões · [🔑 gabarito](../../gabaritos/projeto-02-desafios.md) |
| 06 | [06-checklist.md](06-checklist.md) | Critérios de "pronto" |
