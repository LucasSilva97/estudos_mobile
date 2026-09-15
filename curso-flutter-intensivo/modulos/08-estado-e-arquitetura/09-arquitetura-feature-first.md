# Aula 9 — Arquitetura feature-first

> **Módulo:** 08 - Estado e Arquitetura · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que organizar `lib/` **por feature** vence organizar **por tipo**.
- Descrever as três camadas — **`presentation`**, **`domain`** e **`data`** — e o que vai em cada.
- Aplicar a **regra de dependência**: as setas apontam sempre **para dentro**.
- Escrever um **contrato de repositório** no domínio e a implementação em `data`.
- Decidir o que vai para **`core/`** e o que fica dentro de uma feature.
- Reconhecer os sintomas de uma arquitetura que está degradando — e corrigi-los cedo.
- Reorganizar o `foco_estado` inteiro sem quebrar nada.

## ✅ Pré-requisitos

- [Aula 6 — Notifier](06-notifier-e-notifierprovider.md), [Aula 7 — AsyncNotifier](07-asyncnotifier-e-asyncvalue.md)
  e [Aula 8 — Family e autoDispose](08-family-autodispose-listen.md) — todo o código que você vai
  reorganizar.
- [Módulo 03, aula 5 — Abstratas e interfaces](../03-dart-intermediario/05-abstratas-e-interfaces.md)
  — **essencial**: o contrato de repositório é uma classe abstrata.
- [Módulo 03, aula 10 — Arquivos, bibliotecas e pacotes](../03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)
  — `import`, `export`, visibilidade.
- [Módulo 07, aula 4 — Abas e organização](../07-navegacao-e-formularios/04-abas-e-organizacao.md) —
  a organização por feature apareceu lá; aqui ela ganha camadas.

---

## 📖 Conceito

### Por tipo × por feature

Você já viu essa comparação no Módulo 07. Agora ela ganha profundidade:

```text
❌ Por tipo (layer-first)              ✅ Por feature (feature-first)
lib/                                   lib/
├── models/                            ├── core/
│   ├── materia.dart                   │   ├── tema/
│   ├── sessao.dart                    │   ├── rotas/
│   └── trilha.dart                    │   └── widgets/
├── repositories/                      └── features/
│   ├── materia_repo.dart                  ├── materias/
│   ├── sessao_repo.dart                   │   ├── data/
│   └── trilha_repo.dart                   │   ├── domain/
├── providers/                             │   └── presentation/
│   ├── materias_notifier.dart             ├── sessoes/
│   ├── sessoes_notifier.dart              │   ├── data/
│   └── trilhas_notifier.dart              │   ├── domain/
└── screens/                                │   └── presentation/
    ├── materias_tab.dart                  └── trilhas/
    ├── detalhe_screen.dart                    ├── data/
    └── trilhas_tab.dart                       ├── domain/
                                              └── presentation/
```

Por que a segunda vence, em termos concretos:

| Situação | Por tipo | Por feature |
|---|---|---|
| Implementar "excluir matéria" | Abrir 4 pastas | Abrir **1** pasta |
| Remover a funcionalidade "trilhas" | Caçar arquivos em 4 pastas | Apagar **1** pasta |
| Duas pessoas em features diferentes | Conflito nos mesmos arquivos | Quase nenhum conflito |
| Entender o app pela primeira vez | "O que este app faz?" é invisível | `ls features/` responde |
| App com 30 telas | `screens/` com 30 arquivos sem relação | 8 pastas com 4 arquivos cada |

> 📌 A melhor forma de julgar uma arquitetura é perguntar: **"quantas pastas eu abro para fazer uma
> mudança típica?"** Se a resposta for mais de duas, a organização está trabalhando contra você.

### As três camadas

Dentro de cada feature, três pastas com responsabilidades bem separadas:

```text
features/materias/
├── domain/          ← O QUE é uma matéria e O QUE se pode fazer com ela
│   ├── materia.dart                       (o modelo)
│   └── materia_repositorio.dart           (o CONTRATO, abstrato)
├── data/            ← DE ONDE vêm os dados
│   ├── materia_dao.dart                   (SQL, HTTP, arquivo…)
│   └── materia_repositorio_impl.dart      (a implementação do contrato)
└── presentation/    ← COMO isso aparece na tela
    ├── materias_controller.dart           (o notifier)
    ├── materias_tab.dart                  (a tela)
    └── widgets/materia_tile.dart          (os pedaços)
```

| Camada | Responde | Contém | **Não** contém |
|---|---|---|---|
| **domain** | "o que existe no negócio?" | Modelos, contratos, regras puras | Nada de Flutter, nada de HTTP, nada de SQL |
| **data** | "de onde vêm os dados?" | HTTP, SQL, arquivos, cache, mapeamento JSON | Widgets, `BuildContext` |
| **presentation** | "como o usuário vê e interage?" | Notifiers, telas, widgets | SQL, HTTP, regras de negócio complexas |

### A regra de dependência

Esta é a regra que sustenta tudo:

```text
presentation  ──────►  domain  ◄──────  data
                        (centro)
```

**Todas as setas apontam para dentro.** Em código:

| Camada | Pode importar | **Nunca** importa |
|---|---|---|
| `domain` | **Nada** do próprio app (só `dart:core` e talvez `meta`) | `data`, `presentation`, `flutter/material` |
| `data` | `domain` | `presentation` |
| `presentation` | `domain`, e os **providers** de `data` | Os detalhes de `data` (SQL, HTTP) |

O centro — `domain` — não conhece ninguém. É código Dart puro, testável sem Flutter, sem banco e
sem rede.

> ⚠️ **O teste mais rápido de arquitetura:** abra qualquer arquivo de `domain/` e olhe os
> `import`. Se houver `package:flutter/...`, `package:http/...` ou `package:sqflite/...`, a regra
> foi quebrada. Um modelo de domínio que importa `material.dart` para usar `IconData` já está
> acoplado ao Flutter.

### O contrato de repositório

Esta é a peça que faz a regra funcionar. No domínio, você declara **o que** se pode fazer:

```dart
// domain/materia_repositorio.dart
// Nenhum import de Flutter, HTTP ou SQL. Dart puro.

abstract interface class MateriaRepositorio {
  Future<List<Materia>> listar();
  Future<Materia> salvar(Materia materia);
  Future<void> excluir(String id);
}
```

Em `data`, você implementa **como**:

```dart
// data/materia_repositorio_sqflite.dart
class MateriaRepositorioSqflite implements MateriaRepositorio {
  MateriaRepositorioSqflite(this._dao);
  final MateriaDao _dao;

  @override
  Future<List<Materia>> listar() async {
    final List<Map<String, Object?>> linhas = await _dao.consultarTodas();
    return linhas.map(_paraDominio).toList();
  }
  // …
}
```

E em `presentation`, o notifier depende **do contrato**, não da implementação:

```dart
// presentation/materias_controller.dart
class MateriasController extends AsyncNotifier<List<Materia>> {
  @override
  Future<List<Materia>> build() {
    // O tipo é o CONTRATO. O notifier não sabe se é SQL, HTTP ou memória.
    final MateriaRepositorio repo = ref.watch(materiaRepositorioProvider);
    return repo.listar();
  }
}
```

O ganho é concreto e imediato:

| Ganho | Como |
|---|---|
| **Testar sem banco** | Troque o provider por uma implementação falsa ([aula 10](10-injecao-de-dependencias.md)) |
| **Trocar SQLite por API** | Escreva outra implementação; `presentation` não muda |
| **Trabalhar antes de o backend existir** | Implementação em memória hoje, HTTP depois |
| **Modo offline** | Uma implementação que decide entre cache e rede |

> 💡 `abstract interface class` é um modificador do Dart 3: a classe **só** pode ser implementada
> (`implements`), nunca estendida. É exatamente o que um contrato deve permitir. Visto no
> [Módulo 03, aula 5](../03-dart-intermediario/05-abstratas-e-interfaces.md).

### O que vai para `core/`

A pergunta que decide:

> **"Isto faria sentido se a feature X não existisse?"**

Se **sim** → `core/`. Se **não** → dentro da feature.

| Vai para `core/` | Fica na feature |
|---|---|
| Tema do app | Cores específicas de um gráfico daquela tela |
| Rotas (a classe `Rotas`) | Os argumentos de uma rota específica |
| `EstadoVazio`, `EstadoErro`, `Carregando` | `MateriaTile` |
| Formatadores de data e número | Formatação do progresso de trilha |
| Cliente HTTP configurado | O repositório de matérias |
| Validadores genéricos | Validador de "nome de matéria já existe" |
| Constantes globais | Constantes daquela feature |

> ⚠️ **`core/` não é `utils/`.** A pasta `utils` clássica vira um depósito onde tudo que não tem
> lugar acaba — e ninguém consegue apagar nada porque não sabe quem usa. Se algo em `core/` é usado
> por **uma** feature só, ele não pertence a `core/`.

### Quando uma feature depende de outra

Acontece: a tela de detalhe de matéria mostra as sessões daquela matéria. `materias` precisa de
`sessoes`.

Três formas, da pior para a melhor:

**1. Import direto de `presentation` para `presentation`** — ❌ acopla as telas.

```dart
// features/materias/presentation/detalhe.dart
import 'package:foco/features/sessoes/presentation/sessoes_notifier.dart';  // ⚠️
```

**2. Import do `domain` da outra feature** — ✅ aceitável e comum.

```dart
import 'package:foco/features/sessoes/domain/sessao.dart';         // ok
import 'package:foco/features/sessoes/domain/sessao_repositorio.dart';  // ok
```

**3. Uma feature "compartilhada"** — ✅ quando o modelo é de fato comum.

```text
features/
├── _compartilhado/domain/    ← modelos usados por 3+ features
├── materias/
└── sessoes/
```

**Regra:** dependa do **`domain`** da outra feature, nunca da `presentation` nem da `data`.

### Sintomas de degradação

Cinco sinais de que a arquitetura está apodrecendo — e todos aparecem cedo:

| Sintoma | O que significa | Correção |
|---|---|---|
| Um arquivo com 800 linhas | Responsabilidades demais | Divida por camada |
| `import` circular entre features | As fronteiras não existem mais | Extraia o comum para `domain` compartilhado |
| `flutter/material.dart` em `domain/` | O centro está acoplado à UI | Tire o Flutter do modelo |
| SQL dentro de um notifier | `data` vazou para `presentation` | Crie o repositório |
| `core/utils/helpers.dart` com 40 funções | Depósito de sobras | Distribua por assunto |

O mais insidioso é o terceiro. Um `IconData` no modelo parece inofensivo — e amarra o domínio ao
Flutter, impedindo que ele seja usado num backend Dart, num teste puro ou numa CLI.

**Correção:** guarde o **nome** do ícone (uma `String` ou um `enum`) no domínio, e traduza para
`IconData` na `presentation`.

---

## 💡 Analogia

Pense num hospital.

- **Organizar por tipo** é um hospital com "andar das camas", "andar dos remédios", "andar dos
  médicos" e "andar dos pacientes". Cada categoria junta. E, para atender **um** paciente, você
  sobe e desce quatro andares.
- **Organizar por feature** é um hospital com **alas**: cardiologia, ortopedia, pediatria. Cada ala
  tem as próprias camas, remédios e equipe. Atender um paciente acontece **em um lugar**. Fechar a
  pediatria é fechar uma ala, não caçar itens em quatro andares.
- **O `domain`** é o **prontuário**. Ele descreve o paciente e o tratamento em termos que valem em
  qualquer hospital do mundo — não menciona a marca do tomógrafo nem o sistema de computador daquela
  unidade. É por isso que o prontuário **não importa `flutter/material.dart`**: ele não pode
  depender do equipamento.
- **O `data`** é o **laboratório e a farmácia**: de onde as informações e os insumos vêm de fato.
  Trocar de fornecedor não muda o prontuário.
- **A `presentation`** é o **atendimento**: como o médico conversa com o paciente, o que mostra na
  tela, como registra.
- **A regra de dependência** é: o atendimento consulta o prontuário; o laboratório preenche o
  prontuário; **o prontuário não conhece nem um nem outro**. Se o formato do prontuário dependesse
  da marca do tomógrafo, trocar de equipamento exigiria reescrever todos os prontuários do hospital.
- **O contrato de repositório** é o **pedido de exame padronizado**. O médico pede "hemograma"; se
  o exame é feito no laboratório do prédio, terceirizado ou por um aparelho novo, o pedido é o
  mesmo. É isso que permite trocar o laboratório inteiro sem retreinar os médicos.

---

## 🧪 Exemplo mínimo

Uma feature completa, com as três camadas, em um arquivo por camada.

> **Arquivos:** três, dentro de `foco_estado/lib/features/exemplo/`
> **Como executar:** `flutter run -d chrome`

**1. O domínio — Dart puro, sem nenhum import do app.**

```dart
// lib/features/exemplo/domain/nota.dart
//
// Repare nos imports: NENHUM. Nem Flutter, nem HTTP, nem SQL.
// Este arquivo compilaria num backend Dart ou numa CLI sem mudança.

/// Uma nota de estudo.
class Nota {
  const Nota({
    required this.id,
    required this.texto,
    required this.criadaEm,
    this.fixada = false,
  });

  final String id;
  final String texto;
  final DateTime criadaEm;
  final bool fixada;

  /// Regra de NEGÓCIO, não de tela: uma nota vazia não é válida.
  bool get valida => texto.trim().isNotEmpty && texto.trim().length <= 500;

  /// Regra de negócio: notas fixadas vêm primeiro; depois, as mais recentes.
  static int comparar(Nota a, Nota b) {
    if (a.fixada != b.fixada) return a.fixada ? -1 : 1;
    return b.criadaEm.compareTo(a.criadaEm);
  }

  Nota copyWith({String? id, String? texto, DateTime? criadaEm, bool? fixada}) {
    return Nota(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      criadaEm: criadaEm ?? this.criadaEm,
      fixada: fixada ?? this.fixada,
    );
  }

  @override
  bool operator ==(Object outro) =>
      outro is Nota &&
      outro.id == id &&
      outro.texto == texto &&
      outro.criadaEm == criadaEm &&
      outro.fixada == fixada;

  @override
  int get hashCode => Object.hash(id, texto, criadaEm, fixada);
}

/// O CONTRATO. Diz O QUE se pode fazer, nunca COMO.
///
/// `abstract interface class` (Dart 3): só pode ser implementado,
/// nunca estendido. É exatamente o que um contrato deve permitir.
abstract interface class NotaRepositorio {
  Future<List<Nota>> listar();
  Future<Nota> salvar(Nota nota);
  Future<void> excluir(String id);
}
```

**2. Os dados — implementa o contrato.**

```dart
// lib/features/exemplo/data/nota_repositorio_memoria.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/features/exemplo/domain/nota.dart';

/// Implementação em memória.
///
/// Amanhã isto pode virar NotaRepositorioSqflite ou NotaRepositorioHttp —
/// e NADA da presentation precisa mudar, porque ela depende do contrato.
class NotaRepositorioMemoria implements NotaRepositorio {
  final List<Nota> _notas = <Nota>[];

  @override
  Future<List<Nota>> listar() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final List<Nota> copia = <Nota>[..._notas]..sort(Nota.comparar);
    return copia;
  }

  @override
  Future<Nota> salvar(Nota nota) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final int i = _notas.indexWhere((Nota n) => n.id == nota.id);
    if (i == -1) {
      _notas.add(nota);
    } else {
      _notas[i] = nota;
    }
    return nota;
  }

  @override
  Future<void> excluir(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _notas.removeWhere((Nota n) => n.id == id);
  }
}

/// O provider expõe o CONTRATO, não a implementação.
///
/// Este tipo — NotaRepositorio, e não NotaRepositorioMemoria — é o que
/// permite trocar a implementação nos testes. Aula 10.
final Provider<NotaRepositorio> notaRepositorioProvider =
    Provider<NotaRepositorio>((Ref ref) => NotaRepositorioMemoria());
```

**3. A apresentação — não sabe de onde vêm os dados.**

```dart
// lib/features/exemplo/presentation/notas_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/features/exemplo/data/nota_repositorio_memoria.dart';
import 'package:foco_estado/features/exemplo/domain/nota.dart';

final AsyncNotifierProvider<NotasController, List<Nota>> notasProvider =
    AsyncNotifierProvider<NotasController, List<Nota>>(NotasController.new);

class NotasController extends AsyncNotifier<List<Nota>> {
  /// O tipo é o CONTRATO. Este controller não sabe — nem precisa saber —
  /// se os dados vêm de memória, SQLite ou de uma API.
  NotaRepositorio get _repo => ref.read(notaRepositorioProvider);

  @override
  Future<List<Nota>> build() => ref.watch(notaRepositorioProvider).listar();

  Future<String?> criar(String texto) async {
    final Nota nova = Nota(
      id: 'n_${DateTime.now().microsecondsSinceEpoch}',
      texto: texto,
      criadaEm: DateTime.now(),
    );

    // A regra de validade vem do DOMÍNIO, não é reinventada aqui.
    if (!nova.valida) return 'A nota precisa ter de 1 a 500 caracteres';

    state = const AsyncLoading<List<Nota>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _repo.salvar(nova);
      return _repo.listar();
    });

    return state.hasError ? 'Não foi possível salvar' : null;
  }

  Future<void> alternarFixada(Nota nota) async {
    state = const AsyncLoading<List<Nota>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _repo.salvar(nota.copyWith(fixada: !nota.fixada));
      return _repo.listar();
    });
  }

  Future<void> excluir(String id) async {
    state = const AsyncLoading<List<Nota>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _repo.excluir(id);
      return _repo.listar();
    });
  }
}
```

**O teste da arquitetura, em três perguntas:**

1. `domain/nota.dart` importa alguma coisa? **Não.** ✅
2. `data/` importa `presentation/`? **Não.** ✅
3. `presentation/` sabe que os dados estão em memória? **Não** — ela só vê `NotaRepositorio`. ✅

Se as três respostas estiverem certas, trocar memória por SQLite amanhã é escrever **um** arquivo
novo e mudar **uma** linha (o provider).

---

## 📱 Aplicando no Flutter

Agora você reorganiza o `foco_estado` inteiro. O código é o mesmo das aulas 6 a 8 — o que muda é
**onde** cada coisa mora, e as fronteiras entre as partes.

Antes (plano, das aulas anteriores):

```text
lib/
├── main.dart
├── app.dart
├── dominio/{materia.dart,sessao.dart,trilha.dart}
├── dados/trilhas_fonte.dart
├── estado/{materias_notifier.dart,sessoes_notifier.dart,trilhas_notifier.dart,
│           detalhe_materia_notifier.dart,providers_basicos.dart}
└── telas/{home_screen.dart,trilhas_tab.dart,detalhe_materia_screen.dart}
```

Depois (feature-first com camadas):

```text
lib/
├── main.dart
├── app.dart
│
├── core/                                    ← serve ao app INTEIRO
│   ├── tema/tema_app.dart
│   ├── rotas/rotas.dart
│   ├── widgets/{carregando.dart,estado_vazio.dart,estado_erro.dart}
│   └── formato/formatadores.dart
│
└── features/
    ├── materias/
    │   ├── domain/{materia.dart,materia_repositorio.dart}
    │   ├── data/materia_repositorio_memoria.dart
    │   └── presentation/
    │       ├── materias_controller.dart
    │       ├── materias_tab.dart
    │       ├── detalhe_materia_screen.dart
    │       └── widgets/materia_tile.dart
    │
    ├── sessoes/
    │   ├── domain/{sessao.dart,sessao_repositorio.dart}
    │   ├── data/sessao_repositorio_memoria.dart
    │   └── presentation/{sessoes_controller.dart,widgets/sessao_tile.dart}
    │
    └── trilhas/
        ├── domain/{trilha.dart,trilha_repositorio.dart}
        ├── data/trilha_repositorio_memoria.dart
        └── presentation/{trilhas_controller.dart,trilhas_tab.dart}
```

---

## 💻 Código completo

> **Arquivo:** `foco_estado/lib/features/materias/domain/materia.dart`
> **Como executar:** `flutter run -d chrome`

```dart
// ┌──────────────────────────────────────────────────────────────────────┐
// │ CAMADA: domain                                                       │
// │ Regra: NENHUM import de Flutter, HTTP ou SQL.                        │
// │ Este arquivo compila num backend Dart ou numa CLI sem mudar nada.    │
// └──────────────────────────────────────────────────────────────────────┘

/// Categoria de uma matéria.
///
/// Guarda o NOME do ícone, não um IconData. Colocar IconData aqui
/// amarraria o domínio ao Flutter — o erro de arquitetura mais comum
/// e mais difícil de desfazer depois.
enum CategoriaMateria {
  exatas('Exatas', 'calculate'),
  humanas('Humanas', 'history_edu'),
  idiomas('Idiomas', 'translate'),
  tecnologia('Tecnologia', 'code');

  const CategoriaMateria(this.rotulo, this.nomeDoIcone);

  final String rotulo;
  final String nomeDoIcone;
}

/// Uma matéria de estudo.
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.metaMinutos,
    this.categoria = CategoriaMateria.exatas,
  });

  final String id;
  final String nome;
  final int metaMinutos;
  final CategoriaMateria categoria;

  // ── Regras de NEGÓCIO ─────────────────────────────────────────────────
  // Elas moram aqui porque valem em qualquer tela, em qualquer plataforma
  // e em qualquer fonte de dados.

  static const int metaMinima = 5;
  static const int metaMaxima = 480;

  bool get metaValida =>
      metaMinutos >= metaMinima && metaMinutos <= metaMaxima;

  bool get nomeValido {
    final String limpo = nome.trim();
    return limpo.length >= 2 && limpo.length <= 40;
  }

  bool get valida => metaValida && nomeValido;

  /// Mensagem de erro, ou null se estiver tudo certo.
  /// A tela mostra; o domínio decide.
  String? get problema {
    if (!nomeValido) return 'O nome precisa ter de 2 a 40 caracteres';
    if (!metaValida) {
      return 'A meta precisa ficar entre $metaMinima e $metaMaxima minutos';
    }
    return null;
  }

  double progressoCom(int minutosEstudados) =>
      metaMinutos == 0 ? 0 : (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  Materia copyWith({
    String? id,
    String? nome,
    int? metaMinutos,
    CategoriaMateria? categoria,
  }) {
    return Materia(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      metaMinutos: metaMinutos ?? this.metaMinutos,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  bool operator ==(Object outro) =>
      outro is Materia &&
      outro.id == id &&
      outro.nome == nome &&
      outro.metaMinutos == metaMinutos &&
      outro.categoria == categoria;

  @override
  int get hashCode => Object.hash(id, nome, metaMinutos, categoria);

  @override
  String toString() => 'Materia($id, $nome)';
}
```

> **Arquivo:** `foco_estado/lib/features/materias/domain/materia_repositorio.dart`

```dart
// ┌──────────────────────────────────────────────────────────────────────┐
// │ CAMADA: domain — o CONTRATO                                          │
// │ Diz O QUE se pode fazer. Nunca COMO.                                 │
// └──────────────────────────────────────────────────────────────────────┘

import 'package:foco_estado/features/materias/domain/materia.dart';

/// Erros de domínio. Uma classe por causa permite à tela dar
/// mensagens diferentes — e ao teste verificar a causa exata.
sealed class FalhaMateria implements Exception {
  const FalhaMateria(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

final class MateriaNaoEncontrada extends FalhaMateria {
  const MateriaNaoEncontrada(this.id) : super('Matéria não encontrada');
  final String id;
}

final class MateriaDuplicada extends FalhaMateria {
  const MateriaDuplicada(this.nome)
      : super('Já existe uma matéria com esse nome');
  final String nome;
}

final class FalhaDeArmazenamento extends FalhaMateria {
  const FalhaDeArmazenamento([String mensagem = 'Falha ao acessar os dados'])
      : super(mensagem);
}

/// O contrato.
///
/// `abstract interface class` (Dart 3): só pode ser IMPLEMENTADO,
/// nunca estendido. É o que um contrato deve permitir.
///
/// A presentation depende deste tipo. Por isso ela nunca sabe se os dados
/// vêm de memória, SQLite, HTTP ou de um arquivo.
abstract interface class MateriaRepositorio {
  /// Todas as matérias, ordenadas por nome.
  Future<List<Materia>> listar();

  /// Uma matéria pelo id. Lança [MateriaNaoEncontrada].
  Future<Materia> buscarPorId(String id);

  /// Cria ou atualiza. Lança [MateriaDuplicada] se o nome já existir.
  Future<Materia> salvar(Materia materia);

  /// Remove. Silencioso se o id não existir.
  Future<void> excluir(String id);
}
```

> **Arquivo:** `foco_estado/lib/features/materias/data/materia_repositorio_memoria.dart`

```dart
// ┌──────────────────────────────────────────────────────────────────────┐
// │ CAMADA: data — a IMPLEMENTAÇÃO                                       │
// │ Pode importar domain. NUNCA importa presentation.                    │
// └──────────────────────────────────────────────────────────────────────┘

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/features/materias/domain/materia.dart';
import 'package:foco_estado/features/materias/domain/materia_repositorio.dart';

/// Implementação em memória.
///
/// No Módulo 10 nasce a MateriaRepositorioSqflite, e no Módulo 09 a
/// MateriaRepositorioHttp. Nenhuma linha de `presentation` muda —
/// só o provider lá embaixo aponta para outra classe.
class MateriaRepositorioMemoria implements MateriaRepositorio {
  MateriaRepositorioMemoria([List<Materia>? iniciais])
      : _materias = <Materia>[...?iniciais ?? _padrao];

  final List<Materia> _materias;

  static const List<Materia> _padrao = <Materia>[
    Materia(
        id: 'dart',
        nome: 'Dart',
        metaMinutos: 120,
        categoria: CategoriaMateria.tecnologia),
    Materia(
        id: 'flutter',
        nome: 'Flutter',
        metaMinutos: 120,
        categoria: CategoriaMateria.tecnologia),
    Materia(
        id: 'ingles',
        nome: 'Inglês',
        metaMinutos: 60,
        categoria: CategoriaMateria.idiomas),
  ];

  @override
  Future<List<Materia>> listar() async {
    await _latencia();
    final List<Materia> copia = <Materia>[..._materias]
      ..sort((Materia a, Materia b) => a.nome.compareTo(b.nome));
    return List<Materia>.unmodifiable(copia);
  }

  @override
  Future<Materia> buscarPorId(String id) async {
    await _latencia();
    final int i = _materias.indexWhere((Materia m) => m.id == id);
    if (i == -1) throw MateriaNaoEncontrada(id);
    return _materias[i];
  }

  @override
  Future<Materia> salvar(Materia materia) async {
    await _latencia();

    // Regra de INTEGRIDADE DE DADOS (nome único) — diferente das regras
    // de validade, que ficam no domínio. Esta depende do conjunto
    // armazenado, e por isso mora aqui.
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
    await _latencia();
    _materias.removeWhere((Materia m) => m.id == id);
  }

  Future<void> _latencia() =>
      Future<void>.delayed(const Duration(milliseconds: 250));
}

/// O provider expõe o CONTRATO, não a implementação.
///
/// O tipo `Provider<MateriaRepositorio>` — e não
/// `Provider<MateriaRepositorioMemoria>` — é o que permite substituí-lo
/// nos testes com `overrides`. Aula 10.
final Provider<MateriaRepositorio> materiaRepositorioProvider =
    Provider<MateriaRepositorio>((Ref ref) => MateriaRepositorioMemoria());
```

> **Arquivo:** `foco_estado/lib/features/materias/presentation/materias_controller.dart`

```dart
// ┌──────────────────────────────────────────────────────────────────────┐
// │ CAMADA: presentation                                                 │
// │ Importa domain e o PROVIDER de data — nunca os detalhes de data.     │
// └──────────────────────────────────────────────────────────────────────┘

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_estado/features/materias/data/materia_repositorio_memoria.dart'
    show materiaRepositorioProvider;
import 'package:foco_estado/features/materias/domain/materia.dart';
import 'package:foco_estado/features/materias/domain/materia_repositorio.dart';

final AsyncNotifierProvider<MateriasController, List<Materia>>
    materiasProvider =
    AsyncNotifierProvider<MateriasController, List<Materia>>(
        MateriasController.new);

class MateriasController extends AsyncNotifier<List<Materia>> {
  /// O tipo é o CONTRATO. Este controller não sabe se os dados vêm de
  /// memória, banco ou rede — e essa ignorância é a arquitetura funcionando.
  MateriaRepositorio get _repo => ref.read(materiaRepositorioProvider);

  @override
  Future<List<Materia>> build() {
    return ref.watch(materiaRepositorioProvider).listar();
  }

  Future<void> recarregar() async {
    state = const AsyncLoading<List<Materia>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _repo.listar());
  }

  /// Salva. Devolve null em caso de sucesso, ou a mensagem de erro.
  ///
  /// A validação vem do DOMÍNIO (`materia.problema`); a integridade
  /// vem do repositório (MateriaDuplicada). O controller só orquestra.
  Future<String?> salvar(Materia materia) async {
    final String? problema = materia.problema;
    if (problema != null) return problema;

    state = const AsyncLoading<List<Materia>>().copyWithPrevious(state);

    try {
      await _repo.salvar(materia);
      final List<Materia> lista = await _repo.listar();
      state = AsyncData<List<Materia>>(lista);
      return null;
    } on FalhaMateria catch (falha, pilha) {
      // Erro de domínio: a lista antiga permanece na tela.
      state = AsyncError<List<Materia>>(falha, pilha)
          .copyWithPrevious(state);
      return falha.mensagem;
    }
  }

  Future<String?> excluir(String id) async {
    state = const AsyncLoading<List<Materia>>().copyWithPrevious(state);

    try {
      await _repo.excluir(id);
      state = AsyncData<List<Materia>>(await _repo.listar());
      return null;
    } on FalhaMateria catch (falha, pilha) {
      state = AsyncError<List<Materia>>(falha, pilha).copyWithPrevious(state);
      return falha.mensagem;
    }
  }
}

/// Providers derivados ficam junto do controller que os origina.
final Provider<AsyncValue<int>> totalDeMateriasProvider =
    Provider<AsyncValue<int>>((Ref ref) {
  return ref.watch(materiasProvider).whenData((List<Materia> l) => l.length);
});
```

> **Arquivo:** `foco_estado/lib/core/formato/icones.dart` (a tradução domínio → Flutter)

```dart
// ┌──────────────────────────────────────────────────────────────────────┐
// │ CAMADA: core                                                         │
// │ A ponte entre o nome do ícone (domínio) e o IconData (Flutter).      │
// │                                                                      │
// │ É AQUI que o Flutter entra — nunca no domínio.                       │
// └──────────────────────────────────────────────────────────────────────┘

import 'package:flutter/material.dart';

import 'package:foco_estado/features/materias/domain/materia.dart';

abstract final class Icones {
  static const Map<String, IconData> _porNome = <String, IconData>{
    'calculate': Icons.calculate_outlined,
    'history_edu': Icons.history_edu_outlined,
    'translate': Icons.translate_outlined,
    'code': Icons.code,
  };

  static IconData de(String nome) =>
      _porNome[nome] ?? Icons.menu_book_outlined;

  static IconData daCategoria(CategoriaMateria c) => de(c.nomeDoIcone);
}
```

E a tela usa a tradução:

```dart
// features/materias/presentation/widgets/materia_tile.dart
Icon(Icones.daCategoria(materia.categoria))
```

Confirme que a arquitetura está correta:

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

E faça a **auditoria de imports** — o teste mais rápido de arquitetura:

```powershell
# Nenhum destes comandos deve devolver resultado:
Select-String -Path "lib\features\*\domain\*.dart" -Pattern "package:flutter/"
Select-String -Path "lib\features\*\data\*.dart" -Pattern "presentation"
Select-String -Path "lib\features\*\presentation\*.dart" -Pattern "sqflite|package:http"
```

Se os três voltarem vazios, a regra de dependência está sendo respeitada.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `domain/materia.dart` **sem nenhum import** | O teste definitivo do domínio. Ele compila num backend Dart, numa CLI ou num teste puro. |
| `enum CategoriaMateria` com `nomeDoIcone` **String** | Guardar `IconData` aqui amarraria o domínio ao Flutter. A tradução acontece em `core/formato/icones.dart`. |
| `String? get problema` no modelo | A regra de validade pertence ao **domínio**. A tela mostra a mensagem; ela não decide o que é válido. |
| `sealed class FalhaMateria` | Erros tipados: a tela distingue "duplicada" de "falha de armazenamento" e dá mensagens diferentes. |
| `abstract interface class MateriaRepositorio` | Só pode ser implementado, nunca estendido. Modificador do Dart 3. |
| `Provider<MateriaRepositorio>` (o **contrato** no tipo) | É isto que permite substituir a implementação nos testes com `overrides`. Se o tipo fosse a classe concreta, não daria. |
| `List<Materia>.unmodifiable(copia)` | O repositório devolve cópia imutável: quem chama não altera o armazenamento por acidente. |
| Regra de **nome único** no repositório, não no modelo | Validade depende **só do objeto** (fica no domínio); unicidade depende **do conjunto** (fica em data). |
| `import '...memoria.dart' show materiaRepositorioProvider;` | `show` importa **só** o provider, deixando explícito que a presentation não usa a classe concreta. |
| `MateriaRepositorio get _repo => ref.read(...)` | Getter que esconde o `ref.read` repetido e deixa o tipo do contrato visível. |
| `on FalhaMateria catch (falha, pilha)` | Captura só os erros **esperados** do domínio. Erros inesperados sobem — e devem subir. |
| `AsyncError(...).copyWithPrevious(state)` | Erro **sem** apagar a lista da tela. Padrão da [aula 7](07-asyncnotifier-e-asyncvalue.md). |
| `core/formato/icones.dart` | A única ponte entre nome de ícone e `IconData`. Uma tradução, um lugar. |

---

## ⚠️ Erros comuns

### 1. Flutter no domínio

```dart
// domain/materia.dart
import 'package:flutter/material.dart';   // ❌
final IconData icone;
```

Parece inofensivo — e amarra o domínio ao Flutter para sempre.

**Correção:** guarde um `String` ou `enum` e traduza na `presentation`/`core`.

### 2. `data` importando `presentation`

```dart
// data/materia_repositorio.dart
import '../presentation/materias_controller.dart';   // ❌
```

Inverte a seta e cria dependência circular.

**Correção:** `data` só importa `domain`. Se precisa avisar a UI, use um `Stream` ou deixe o
controller observar.

### 3. SQL dentro do notifier

```dart
class MateriasController extends AsyncNotifier<List<Materia>> {
  Future<List<Materia>> build() async {
    final Database db = await openDatabase('foco.db');   // ❌
```

A camada `data` vazou para `presentation`. Testar isso exige um banco real.

**Correção:** crie o repositório e injete-o.

### 4. Provider tipado com a classe concreta

```dart
final Provider<MateriaRepositorioMemoria> repo = ...;   // ❌
```

Nos testes você não consegue substituir por outra implementação — o tipo não deixa.

**Correção:** `Provider<MateriaRepositorio>`.

### 5. `core/utils/helpers.dart`

Vira depósito: 40 funções sem relação, e ninguém consegue apagar nada porque não sabe quem usa.

**Correção:** distribua por assunto (`core/formato/`, `core/validacao/`), e mova para a feature o
que só uma usa.

### 6. Feature importando `presentation` de outra

```dart
// features/materias/presentation/detalhe.dart
import 'package:foco/features/sessoes/presentation/sessoes_tab.dart';   // ⚠️
```

**Correção:** dependa do `domain` da outra feature. Se o acoplamento for real e frequente, talvez
sejam a mesma feature.

### 7. Repositório devolvendo o formato do banco

```dart
Future<List<Map<String, Object?>>> listar();   // ❌ SQL vazando pelo contrato
```

**Correção:** o contrato fala a língua do **domínio**: `Future<List<Materia>>`. O mapeamento fica
em `data`.

### 8. Validação duplicada em três lugares

```dart
// no modelo, no controller E no widget
if (nome.length < 2) ...
```

Um dia as três divergem.

**Correção:** a regra vive **no domínio**; controller e tela consultam.

### 9. Uma pasta por camada **acima** das features

```text
lib/
├── domain/       ← ❌ isso é layer-first de novo, com outro nome
├── data/
└── presentation/
```

**Correção:** as camadas ficam **dentro** de cada feature.

### 10. Arquitetura demais para um app pequeno

Um app de 3 telas com 4 camadas, 12 interfaces e injeção completa gasta mais tempo em cerimônia que
em funcionalidade.

**Correção:** comece com `domain` + `presentation`, e acrescente `data` quando a fonte de dados
aparecer. A arquitetura acompanha o tamanho do problema.

---

## 🛠️ Exercício guiado

**Passo 1.** Reorganize o `foco_estado` na estrutura desta aula. Rode `flutter analyze` até voltar
limpo. Anote quantos `import` você precisou corrigir.

**Passo 2.** Rode a auditoria de imports (os três `Select-String`). Todos vazios? Se algum
retornou, corrija.

**Passo 3.** Acrescente `import 'package:flutter/material.dart';` a
`domain/materia.dart` e troque `nomeDoIcone` por `IconData`. Rode a auditoria de novo. Ela pega o
problema? Depois desfaça.

**Passo 4.** Crie `MateriaRepositorioFalso` em `test/` que devolve sempre uma lista fixa, sem
atraso. Quantos arquivos de `presentation` você precisou tocar? (Resposta esperada: zero.)

**Passo 5.** Mova `Icones` de `core/formato/` para `features/materias/presentation/`. Depois tente
usá-lo na feature de trilhas. O que acontece? Qual pergunta decide onde ele deve ficar?

**Passo 6.** Mova a regra de "nome único" do repositório para o modelo `Materia`. O que você
precisa passar para o modelo para que ela funcione? Por que ela pertence a `data`?

**Passo 7.** Conte quantas pastas você abre para implementar "renomear matéria". Compare com a
organização anterior (`dominio/`, `estado/`, `telas/`).

**Passo 8.** Crie uma feature nova, `metas/`, com as três camadas, mesmo que quase vazia. Quanto
tempo levou? Essa é a medida de quão previsível a estrutura está.

**Passo 9.** Apague a pasta `features/trilhas/` inteira. O app compila? Quantos `import` quebrados
apareceram? Depois restaure com `git checkout`.

**Passo 10.** Responda por escrito: o que aconteceria com `presentation/` se amanhã os dados
passassem a vir de uma API REST em vez da memória? Cite os arquivos que mudariam.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md)

Faça os exercícios de **Aplicação** com contrato de repositório, o de **Correção de bugs** com
Flutter no domínio, e o de **Decisão** sobre `core/` × feature.

---

## 🏆 Desafio opcional

Escreva um **teste de arquitetura** que falha automaticamente quando alguém quebra a regra de
dependência.

Requisitos:

- Um teste Dart que percorre `lib/` lendo os `import` de cada arquivo.
- Falha se um arquivo em `domain/` importar `package:flutter/`, `package:http/` ou `package:sqflite/`.
- Falha se um arquivo em `data/` importar qualquer coisa de `presentation/`.
- Falha se uma feature importar a `presentation` ou a `data` de outra feature.
- A mensagem de falha diz **qual arquivo** e **qual import** quebrou a regra.

Dica: `Directory('lib').listSync(recursive: true)` para percorrer,
`File.readAsLinesSync()` para ler, e uma `RegExp` para extrair os imports.

Depois rode-o e veja se o seu próprio projeto passa. Se não passar, você acabou de descobrir por
que esse tipo de teste existe: **a arquitetura degrada sozinha**, e revisão humana não pega tudo.

---

## 📌 Resumo

- Organize `lib/` **por feature**, não por tipo. A medida de qualidade é: *"quantas pastas eu abro
  para uma mudança típica?"*
- Cada feature tem três camadas: **`domain`** (o que é), **`data`** (de onde vem) e
  **`presentation`** (como aparece).
- **Regra de dependência:** as setas apontam para dentro. `presentation → domain ← data`.
- **`domain` não importa nada** do app — nem Flutter, nem HTTP, nem SQL. É Dart puro, testável
  isoladamente.
- Guardar `IconData` no domínio é o erro mais comum e mais difícil de desfazer. Guarde o **nome**
  e traduza fora.
- O **contrato de repositório** (`abstract interface class`) fica no domínio; a implementação fica
  em `data`.
- O **provider precisa ser tipado com o contrato**, não com a classe concreta — é isso que permite
  substituí-lo nos testes.
- **Validade** (depende só do objeto) fica no domínio; **integridade** (depende do conjunto) fica
  em `data`.
- **`core/`** guarda o que serve ao app inteiro. A pergunta: *"isto faria sentido sem a feature X?"*
  `core/` **não** é `utils/`.
- Feature que depende de outra deve depender do **`domain`** dela, nunca da `presentation` ou da
  `data`.
- Sintomas de degradação: arquivo de 800 linhas, import circular, Flutter no domínio, SQL no
  notifier, `helpers.dart` inchado.
- A auditoria de imports é o teste mais rápido de arquitetura — e dá para automatizá-la.
- **Arquitetura acompanha o tamanho do problema.** App de 3 telas não precisa de 4 camadas.

---

## ☑️ Checklist de domínio

- [ ] Explico por que feature-first vence layer-first, com um exemplo concreto.
- [ ] Nomeio as três camadas e digo o que vai em cada.
- [ ] Desenho a regra de dependência de memória.
- [ ] Meu `domain/` não tem nenhum import do Flutter.
- [ ] Guardo nome de ícone no domínio e traduzo na apresentação.
- [ ] Escrevo um contrato de repositório com `abstract interface class`.
- [ ] Tipo o provider com o contrato, nunca com a classe concreta.
- [ ] Sei separar validade (domínio) de integridade (data).
- [ ] Decido `core/` × feature com a pergunta certa.
- [ ] Dependo do `domain` de outra feature, nunca da `presentation`.
- [ ] Reconheço os cinco sintomas de degradação.
- [ ] Rodo a auditoria de imports e ela volta vazia.
- [ ] `flutter analyze` e `flutter test` passam limpos.

---

## 📚 Referências oficiais

- [Flutter architecture guide — docs.flutter.dev](https://docs.flutter.dev/app-architecture/guide)
- [Architecture case study — docs.flutter.dev](https://docs.flutter.dev/app-architecture/case-study)
- [Class modifiers — dart.dev](https://dart.dev/language/class-modifiers)
- [Effective Dart: Design — dart.dev](https://dart.dev/effective-dart/design)
- [Riverpod architecture — riverpod.dev](https://riverpod.dev/docs/essentials/do_dont)
- [05 — Decisões técnicas do curso](../../05-decisoes-tecnicas.md)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 8 — Family, autoDispose e listen](08-family-autodispose-listen.md) | [README](README.md) | [Aula 10 — Injeção de dependências](10-injecao-de-dependencias.md) |
