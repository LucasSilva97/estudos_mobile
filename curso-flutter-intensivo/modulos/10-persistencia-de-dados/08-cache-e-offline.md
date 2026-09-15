# Aula 8 — Cache e offline

> **Módulo:** 10 - Persistência de Dados · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Escolher entre **cache-first**, **network-first** e **stale-while-revalidate**, com critério.
- Guardar um **carimbo de tempo** com o dado e aplicar **TTL** (tempo de vida).
- Avisar o usuário de que ele está vendo **dado antigo** — em vez de mentir.
- Detectar conectividade com **`connectivity_plus`** e saber por que ela **não garante internet**.
- Implementar uma **fila de operações pendentes** que sincroniza quando a rede volta.
- Resolver **conflito** entre a alteração local e a do servidor.
- Invalidar cache corretamente, sem deixar dado velho preso para sempre.

## ✅ Pré-requisitos

- [Aula 5 — sqflite: CRUD](05-sqflite-crud.md) e [Aula 6 — Migrações](06-migracoes.md).
- [Módulo 09, aula 9 — API com Riverpod](../09-consumo-de-api/09-api-com-riverpod.md) —
  **essencial**: o repositório e o `AsyncNotifier` que vão ganhar cache.
- [Módulo 09, aula 6 — Timeout e retry](../09-consumo-de-api/06-timeout-retry-cancelamento.md).
- [Módulo 08, aula 7 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)
  — `copyWithPrevious` e "erro com dados antigos".

---

## 📖 Conceito

### Por que cache

Sem cache, um app que depende de rede tem três problemas:

1. **Tela branca a cada abertura** — o usuário espera a requisição toda vez.
2. **Inútil sem internet** — no metrô, no elevador, no avião.
3. **Gasta dados** — busca de novo o que já tinha.

Com cache, os três desaparecem. E surge um novo: **como saber se o dado ainda vale?**

### As três estratégias

| Estratégia | Como funciona | Use quando |
|---|---|---|
| **Cache-first** | Lê o cache; só vai à rede se não houver | O dado muda raramente (catálogo, configurações) |
| **Network-first** | Vai à rede; usa o cache se falhar | O dado precisa estar atual (saldo, estoque) |
| **Stale-while-revalidate** | Mostra o cache **na hora** e busca em segundo plano | **A maioria dos casos** |

O terceiro merece atenção porque é o que dá a melhor experiência:

```text
1. Usuário abre a tela
2. Cache aparece INSTANTANEAMENTE (sem tela branca)
3. Requisição sai em segundo plano
4. Chegou dado novo? A tela atualiza sozinha
5. Falhou? A tela continua mostrando o cache, com um aviso discreto
```

O usuário nunca vê tela vazia, nunca espera, e nunca fica sem informação.

> 📌 **Esse é o padrão que o Foco usa.** Ele combina o melhor dos dois: a velocidade do cache-first
> com a atualidade do network-first. O custo é uma requisição que o usuário não pediu — aceitável
> na maioria dos apps, e evitável com TTL.

### Carimbo de tempo e TTL

Um cache sem prazo é um cache que apodrece. Guarde **quando** o dado foi buscado:

```sql
CREATE TABLE cache_trilhas (
  id          TEXT    PRIMARY KEY,
  conteudo    TEXT    NOT NULL,     -- o JSON
  buscado_em  INTEGER NOT NULL      -- millisecondsSinceEpoch
);
```

E defina um **TTL** (*time to live*) por tipo de dado:

```dart
abstract final class Validade {
  /// Catálogo público: muda raramente.
  static const Duration trilhas = Duration(hours: 6);

  /// Dados do usuário: mudam com frequência.
  static const Duration perfil = Duration(minutes: 15);

  /// Estatísticas: podem ficar um pouco atrasadas.
  static const Duration estatisticas = Duration(hours: 1);
}
```

Com isso, três situações:

| Idade do cache | O que fazer |
|---|---|
| Dentro do TTL | Usa o cache, **sem** ir à rede |
| Expirado, mas existe | Mostra o cache **e** busca em segundo plano |
| Não existe | Busca, mostrando carregamento |

> ⚠️ **Um cache expirado ainda é útil.** O erro comum é apagar o que expirou. Se a rede estiver
> fora, um dado de ontem é infinitamente melhor que tela vazia — desde que o usuário **saiba** que
> é de ontem.

### Avisar que o dado é antigo

Esta é a diferença entre um app honesto e um que mente:

```text
❌ Mostra dados de 3 dias atrás como se fossem de agora
✅ "Atualizado há 3 dias · sem conexão"  [Tentar de novo]
```

O aviso precisa ser **proporcional**:

| Idade | Aviso |
|---|---|
| Minutos | Nenhum |
| Horas | Discreto: "atualizado há 2 h" no rodapé |
| Dias | Visível: faixa no topo, com botão de atualizar |
| Sem conexão | Sempre: ícone + texto |

### `connectivity_plus` e o que ele **não** diz

```dart
final List<ConnectivityResult> resultado = await Connectivity().checkConnectivity();
final bool temInterface = !resultado.contains(ConnectivityResult.none);
```

> ⚠️ **`connectivity_plus` diz se há uma interface de rede ativa — não se há internet.**

Situações em que ele diz "conectado" e não há internet:

- Wi-Fi de aeroporto/hotel com portal cativo (precisa fazer login na página);
- roteador ligado, mas sem link com a operadora;
- dados móveis ativos, mas a franquia acabou;
- rede corporativa que bloqueia o seu domínio;
- modo avião com Wi-Fi ligado, sem estar conectado a nenhuma rede.

**A consequência prática:** nunca use `connectivity_plus` para **decidir se tenta** a requisição.
Use-o para:

1. **Explicar** uma falha já ocorrida ("sem conexão" em vez de "erro desconhecido").
2. **Disparar** a sincronização quando a rede volta.
3. **Mostrar** um indicador de estado offline.

```dart
// ❌ decide com base na conectividade
if (!temInternet) return cache;
final dados = await api.buscar();

// ✅ tenta sempre; a conectividade só EXPLICA a falha
try {
  return await api.buscar();
} on SocketException {
  final bool offline = await _semRede();
  throw offline ? const FalhaSemConexao() : const FalhaDeServidor();
}
```

### Fila de operações pendentes

Ler offline é fácil: mostra o cache. **Escrever** offline é o assunto difícil.

O usuário marca um tema como concluído sem internet. Três opções:

| Opção | Experiência |
|---|---|
| Bloquear a ação | "Sem conexão." O app fica inútil no metrô |
| Aplicar só localmente | Funciona — e a mudança se perde |
| **Enfileirar** | Aplica local, envia quando a rede voltar ✅ |

A fila é uma tabela:

```sql
CREATE TABLE operacoes_pendentes (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,  -- preserva a ORDEM
  tipo        TEXT    NOT NULL,     -- 'marcar_tema', 'criar_trilha'…
  alvo_id     TEXT    NOT NULL,     -- a qual recurso se aplica
  carga       TEXT    NOT NULL,     -- JSON com os dados
  criada_em   INTEGER NOT NULL,
  tentativas  INTEGER NOT NULL DEFAULT 0,
  ultimo_erro TEXT
);
```

Quatro decisões de projeto:

1. **`AUTOINCREMENT` preserva a ordem.** Criar uma trilha e depois marcar um tema dela **precisa**
   ser enviado nessa ordem.
2. **Colapsar operações redundantes.** Marcar e desmarcar o mesmo tema cinco vezes gera **uma**
   operação, não cinco.
3. **Limitar tentativas.** Uma operação que falha 5 vezes provavelmente nunca vai funcionar (dados
   inválidos, recurso apagado). Marque como falha permanente e **avise**.
4. **A tela mostra o estado otimista.** Ela reflete a fila aplicada sobre o cache — o usuário vê o
   que **vai** acontecer.

### Conflito

O usuário alterou local; o servidor também mudou. Quem ganha?

| Estratégia | Como | Use quando |
|---|---|---|
| **Servidor ganha** | Descarta a alteração local | Dado que o app só lê e exibe |
| **Cliente ganha** | Envia por cima | Dado que só aquele usuário edita |
| **Mais recente ganha** | Compara carimbos | Simples e razoável na maioria |
| **Mesclar** | Combina campo a campo | Quando os campos são independentes |
| **Perguntar** | O usuário decide | Dado importante e irrecuperável |

**Decisão do curso:** *mais recente ganha*, comparando o carimbo de alteração. Simples, previsível,
e adequado a um app de uso individual.

> ⚠️ "Mais recente" depende do **relógio**, e o relógio do aparelho pode estar errado. Numa API
> real, o carimbo vem do **servidor** (`updated_at`), e o cliente envia o que recebeu por último.

---

## 💡 Analogia

Pense numa geladeira e no supermercado.

- **Cache-first** é sempre comer o que tem na geladeira e só ir ao mercado quando ela está vazia.
  Rápido — e um dia você come algo estragado.
- **Network-first** é ir ao mercado a cada refeição. Sempre fresco, e você passa o dia na fila.
- **Stale-while-revalidate** é comer o que tem na geladeira **agora** e pedir a entrega do mercado
  **enquanto** come. Você não espera, e amanhã tem comida fresca. É assim que a maioria das pessoas
  vive.
- **O TTL** é a data de validade na embalagem. Sem ela, você não sabe se aquele iogurte é de ontem
  ou do mês passado.
- **O cache expirado ainda útil** é o iogurte vencido há dois dias quando o mercado está fechado e
  você está com fome. Você **avisa** ("olha, está vencido") e decide — bem melhor que jogar fora e
  ficar sem nada.
- **`connectivity_plus`** é olhar pela janela e ver que a rua está aberta. Isso **não** significa
  que o mercado está funcionando: pode estar em greve, sem energia, ou fechado para reforma. Por
  isso você não decide **se sai de casa** olhando a rua — você sai, e se o mercado estiver fechado,
  a rua aberta te ajuda a **entender** que o problema é o mercado, não o seu carro.
- **A fila de pendências** é a lista de compras que você escreve durante a semana. Você não vai ao
  mercado a cada item lembrado: anota, e leva a lista inteira de uma vez. **Na ordem certa** —
  porque não adianta comprar o recheio antes de decidir o bolo.
- **O conflito** é chegar em casa e descobrir que outra pessoa já comprou leite. Alguém precisa
  decidir qual fica.

---

## 🧪 Exemplo mínimo

Cache com TTL e as três estratégias, testável no Windows.

> **Arquivo:** `foco_dados/test/exemplo_cache_test.dart` (temporário)
> **Como executar:** `flutter test test/exemplo_cache_test.dart`

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Um item com carimbo de quando foi buscado.
class ItemDeCache {
  const ItemDeCache({required this.conteudo, required this.buscadoEm});

  final String conteudo;
  final DateTime buscadoEm;

  Duration get idade => DateTime.now().difference(buscadoEm);

  bool expirouEm(Duration ttl) => idade > ttl;
}

/// Cache em SQLite, com carimbo de tempo.
class Cache {
  const Cache(this._db);

  final Database _db;

  static Future<void> criarTabela(Database db, int v) async {
    await db.execute(
      'CREATE TABLE cache ('
      '  chave      TEXT    PRIMARY KEY,'
      '  conteudo   TEXT    NOT NULL,'
      '  buscado_em INTEGER NOT NULL'
      ')',
    );
  }

  Future<void> gravar(String chave, String conteudo) async {
    await _db.insert(
      'cache',
      <String, Object?>{
        'chave': chave,
        'conteudo': conteudo,
        'buscado_em': DateTime.now().millisecondsSinceEpoch,
      },
      // replace: o cache é sempre sobrescrito pelo valor mais novo.
      // Aqui não há chave estrangeira, então é seguro.
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ItemDeCache?> ler(String chave) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      'cache',
      where: 'chave = ?',
      whereArgs: <Object?>[chave],
      limit: 1,
    );
    if (linhas.isEmpty) return null;

    return ItemDeCache(
      conteudo: linhas.first['conteudo']! as String,
      buscadoEm: DateTime.fromMillisecondsSinceEpoch(
        linhas.first['buscado_em']! as int,
      ),
    );
  }

  /// Grava com um carimbo ARTIFICIAL. Só para testes poderem
  /// simular cache antigo sem esperar horas.
  Future<void> gravarComIdade(
    String chave,
    String conteudo,
    Duration idade,
  ) async {
    await _db.insert(
      'cache',
      <String, Object?>{
        'chave': chave,
        'conteudo': conteudo,
        'buscado_em':
            DateTime.now().subtract(idade).millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> invalidar(String chave) =>
      _db.delete('cache', where: 'chave = ?', whereArgs: <Object?>[chave]);
}

/// O que a tela recebe: os dados E de quando eles são.
class Resultado {
  const Resultado({
    required this.dados,
    required this.daRede,
    this.idadeDoCache,
  });

  final String dados;

  /// true = acabou de vir da rede; false = veio do cache.
  final bool daRede;

  /// Preenchido quando veio do cache. A tela usa para avisar o usuário.
  final Duration? idadeDoCache;
}

/// Repositório com as três estratégias.
class Repositorio {
  Repositorio(this._cache, this._api);

  final Cache _cache;
  final Future<String> Function() _api;

  /// CACHE-FIRST: só vai à rede se não houver cache válido.
  /// Para dados que mudam raramente.
  Future<Resultado> cachePrimeiro(String chave, Duration ttl) async {
    final ItemDeCache? item = await _cache.ler(chave);

    if (item != null && !item.expirouEm(ttl)) {
      return Resultado(
        dados: item.conteudo,
        daRede: false,
        idadeDoCache: item.idade,
      );
    }

    try {
      final String novo = await _api();
      await _cache.gravar(chave, novo);
      return Resultado(dados: novo, daRede: true);
    } on Object {
      // Cache EXPIRADO ainda é útil quando a rede falha.
      // Apagar o que expirou deixaria o usuário sem nada.
      if (item != null) {
        return Resultado(
          dados: item.conteudo,
          daRede: false,
          idadeDoCache: item.idade,
        );
      }
      rethrow;
    }
  }

  /// NETWORK-FIRST: tenta a rede; cai para o cache se falhar.
  /// Para dados que precisam estar atuais.
  Future<Resultado> redePrimeiro(String chave) async {
    try {
      final String novo = await _api();
      await _cache.gravar(chave, novo);
      return Resultado(dados: novo, daRede: true);
    } on Object {
      final ItemDeCache? item = await _cache.ler(chave);
      if (item == null) rethrow;
      return Resultado(
        dados: item.conteudo,
        daRede: false,
        idadeDoCache: item.idade,
      );
    }
  }

  /// STALE-WHILE-REVALIDATE: entrega o cache NA HORA e busca em
  /// segundo plano. A tela recebe dois valores pelo Stream.
  ///
  /// É o padrão do curso: velocidade de cache-first com a
  /// atualidade de network-first.
  Stream<Resultado> caducoEnquantoRevalida(String chave) async* {
    final ItemDeCache? item = await _cache.ler(chave);

    // 1. Cache primeiro, imediatamente. Sem tela branca.
    if (item != null) {
      yield Resultado(
        dados: item.conteudo,
        daRede: false,
        idadeDoCache: item.idade,
      );
    }

    // 2. Rede em seguida.
    try {
      final String novo = await _api();
      await _cache.gravar(chave, novo);
      yield Resultado(dados: novo, daRede: true);
    } on Object {
      // Falhou E não havia cache: não há o que mostrar.
      if (item == null) rethrow;
      // Falhou MAS havia cache: o usuário já viu o dado antigo.
      // Não emitimos erro — a tela avisa pela idadeDoCache.
    }
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late Cache cache;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1, onCreate: Cache.criarTabela),
    );
    cache = Cache(db);
  });

  tearDown(() => db.close());

  Future<String> apiOk() async => jsonEncode(<String>['a', 'b']);
  Future<String> apiFalha() async =>
      throw const SocketException('sem conexão');

  group('cache-first', () {
    test('cache válido NÃO chama a rede', () async {
      await cache.gravar('k', 'do cache');
      int chamadas = 0;

      final Repositorio repo = Repositorio(cache, () async {
        chamadas++;
        return 'da rede';
      });

      final Resultado r = await repo.cachePrimeiro('k', const Duration(hours: 1));

      expect(r.dados, 'do cache');
      expect(r.daRede, isFalse);
      expect(chamadas, 0, reason: 'economizou uma requisição');
    });

    test('cache expirado chama a rede', () async {
      await cache.gravarComIdade('k', 'antigo', const Duration(hours: 2));

      final Repositorio repo = Repositorio(cache, () async => 'novo');
      final Resultado r =
          await repo.cachePrimeiro('k', const Duration(hours: 1));

      expect(r.dados, 'novo');
      expect(r.daRede, isTrue);
    });

    test('rede falha: usa o cache EXPIRADO', () async {
      await cache.gravarComIdade('k', 'antigo', const Duration(days: 3));

      final Repositorio repo = Repositorio(cache, apiFalha);
      final Resultado r =
          await repo.cachePrimeiro('k', const Duration(hours: 1));

      // Dado de 3 dias é melhor que tela vazia — desde que
      // o usuário SAIBA que é de 3 dias.
      expect(r.dados, 'antigo');
      expect(r.idadeDoCache!.inDays, 3);
    });

    test('rede falha e não há cache: propaga o erro', () async {
      final Repositorio repo = Repositorio(cache, apiFalha);

      await expectLater(
        repo.cachePrimeiro('k', const Duration(hours: 1)),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('network-first', () {
    test('rede ok: usa a rede e ATUALIZA o cache', () async {
      await cache.gravar('k', 'antigo');

      final Repositorio repo = Repositorio(cache, () async => 'novo');
      final Resultado r = await repo.redePrimeiro('k');

      expect(r.dados, 'novo');
      expect((await cache.ler('k'))!.conteudo, 'novo');
    });

    test('rede falha: cai para o cache', () async {
      await cache.gravar('k', 'antigo');

      final Repositorio repo = Repositorio(cache, apiFalha);
      final Resultado r = await repo.redePrimeiro('k');

      expect(r.dados, 'antigo');
      expect(r.daRede, isFalse);
    });
  });

  group('stale-while-revalidate', () {
    test('emite cache e DEPOIS rede', () async {
      await cache.gravar('k', 'do cache');

      final Repositorio repo = Repositorio(cache, () async => 'da rede');
      final List<Resultado> emissoes =
          await repo.caducoEnquantoRevalida('k').toList();

      expect(emissoes, hasLength(2));
      // 1º: instantâneo, sem tela branca.
      expect(emissoes.first.dados, 'do cache');
      expect(emissoes.first.daRede, isFalse);
      // 2º: atualiza sozinho.
      expect(emissoes.last.dados, 'da rede');
      expect(emissoes.last.daRede, isTrue);
    });

    test('sem cache: emite só a rede', () async {
      final Repositorio repo = Repositorio(cache, () async => 'da rede');
      final List<Resultado> emissoes =
          await repo.caducoEnquantoRevalida('k').toList();

      expect(emissoes, hasLength(1));
      expect(emissoes.single.daRede, isTrue);
    });

    test('rede falha COM cache: uma emissão, sem erro', () async {
      await cache.gravar('k', 'do cache');

      final Repositorio repo = Repositorio(cache, apiFalha);
      final List<Resultado> emissoes =
          await repo.caducoEnquantoRevalida('k').toList();

      // O usuário já viu o dado. Jogar um erro na cara dele
      // depois disso seria ruído.
      expect(emissoes, hasLength(1));
      expect(emissoes.single.dados, 'do cache');
    });

    test('rede falha SEM cache: propaga o erro', () async {
      final Repositorio repo = Repositorio(cache, apiFalha);

      await expectLater(
        repo.caducoEnquantoRevalida('k').toList(),
        throwsA(isA<SocketException>()),
      );
    });
  });
}
```

```powershell
flutter test test/exemplo_cache_test.dart
```

**O teste que mais importa** é `rede falha: usa o cache EXPIRADO`. Ele prova que o cache vencido
continua valendo — e é justamente o que a maioria dos apps faz errado, apagando o que expirou.

---

## 📱 Aplicando no Flutter

O `foco_dados` ganha a camada offline completa:

- `TrilhaCacheDao` — cache em SQLite, com TTL;
- `StatusDeRede` — `connectivity_plus`, usado **só** para explicar e disparar;
- `FilaDePendencias` — operações offline, com colapso e limite de tentativas;
- `TrilhaRepositorio` — *stale-while-revalidate* com fila.

---

## 💻 Código completo

> **Arquivo:** `foco_dados/lib/core/rede/status_de_rede.dart` (novo)
> **Instale antes:** `flutter pub add connectivity_plus`

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de rede do aparelho.
///
/// ⚠️ LEIA COM ATENÇÃO: isto diz se há uma INTERFACE de rede ativa —
/// NÃO se há internet.
///
/// Situações em que o aparelho está "conectado" e não há internet:
///  - Wi-Fi de hotel/aeroporto com portal cativo;
///  - roteador ligado, sem link com a operadora;
///  - dados móveis ativos, franquia esgotada;
///  - rede corporativa bloqueando o seu domínio.
///
/// Por isso NUNCA use isto para decidir SE tenta a requisição.
/// Use para: (1) explicar uma falha, (2) disparar sincronização
/// quando a rede volta, (3) mostrar um indicador.
enum StatusDeRede {
  comInterface,
  semInterface;

  bool get provavelmenteOnline => this == StatusDeRede.comInterface;
}

class ObservadorDeRede {
  ObservadorDeRede([Connectivity? conectividade])
      : _conectividade = conectividade ?? Connectivity();

  final Connectivity _conectividade;

  Future<StatusDeRede> atual() async {
    final List<ConnectivityResult> resultado =
        await _conectividade.checkConnectivity();
    return _classificar(resultado);
  }

  /// Emite a cada mudança. É o gatilho para sincronizar a fila.
  Stream<StatusDeRede> get mudancas =>
      _conectividade.onConnectivityChanged.map(_classificar);

  StatusDeRede _classificar(List<ConnectivityResult> resultado) {
    // A lista pode ter mais de um item (Wi-Fi + VPN, por exemplo).
    final bool nenhuma = resultado.isEmpty ||
        resultado.every((ConnectivityResult r) => r == ConnectivityResult.none);
    return nenhuma ? StatusDeRede.semInterface : StatusDeRede.comInterface;
  }
}

final Provider<ObservadorDeRede> observadorDeRedeProvider =
    Provider<ObservadorDeRede>((Ref ref) => ObservadorDeRede());

/// Estado atual, para a tela mostrar o indicador offline.
final StreamProvider<StatusDeRede> statusDeRedeProvider =
    StreamProvider<StatusDeRede>((Ref ref) async* {
  final ObservadorDeRede observador = ref.watch(observadorDeRedeProvider);
  yield await observador.atual();
  yield* observador.mudancas;
});
```

> **Arquivo:** `foco_dados/lib/features/trilhas/data/trilha_cache_dao.dart` (novo)

```dart
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:foco_dados/features/trilhas/domain/trilha.dart';

/// Prazos de validade por tipo de dado.
///
/// Concentrados aqui para a política do app ser visível e ajustável
/// em um lugar só.
abstract final class Validade {
  /// Catálogo público: muda raramente.
  static const Duration trilhas = Duration(hours: 6);

  /// Dados do usuário: mudam com frequência.
  static const Duration perfil = Duration(minutes: 15);

  /// Estatísticas: podem ficar um pouco atrasadas.
  static const Duration estatisticas = Duration(hours: 1);
}

/// Cache de trilhas em SQLite.
///
/// Guarda o JSON cru, não as colunas normalizadas: o cache espelha a
/// resposta da API, e normalizá-lo obrigaria a migrar o cache toda vez
/// que a API mudasse. Para dados do PRÓPRIO usuário (matérias, sessões),
/// a escolha é a oposta — tabelas normalizadas.
class TrilhaCacheDao {
  const TrilhaCacheDao(this._db);

  final DatabaseExecutor _db;

  static const String tabela = 'cache_trilhas';
  static const String _chaveListagem = 'listagem';

  static Future<void> criarTabela(DatabaseExecutor db) async {
    await db.execute(
      'CREATE TABLE $tabela ('
      '  chave      TEXT    PRIMARY KEY,'
      '  conteudo   TEXT    NOT NULL,'
      '  buscado_em INTEGER NOT NULL'
      ')',
    );
  }

  Future<void> gravarListagem(List<Trilha> trilhas) async {
    await _db.insert(
      tabela,
      <String, Object?>{
        'chave': _chaveListagem,
        'conteudo': jsonEncode(
          trilhas.map((Trilha t) => t.paraJson()).toList(),
        ),
        'buscado_em': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lê o cache, **mesmo expirado**.
  ///
  /// A decisão de usar ou não é de quem chama: um dado de 3 dias é
  /// melhor que tela vazia, desde que o usuário saiba a idade dele.
  Future<CacheDeTrilhas?> lerListagem() async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'chave = ?',
      whereArgs: <Object?>[_chaveListagem],
      limit: 1,
    );
    if (linhas.isEmpty) return null;

    final DateTime buscadoEm = DateTime.fromMillisecondsSinceEpoch(
      linhas.first['buscado_em']! as int,
    );

    try {
      final List<Object?> bruto =
          jsonDecode(linhas.first['conteudo']! as String) as List<Object?>;
      return CacheDeTrilhas(
        trilhas: bruto
            .map((Object? e) => Trilha.deJson(e! as Map<String, Object?>))
            .toList(),
        buscadoEm: buscadoEm,
      );
    } on FormatException {
      // Cache corrompido, ou de uma versão anterior do app com outro
      // formato. Descarte em silêncio: é cache, não dado do usuário.
      await invalidar();
      return null;
    }
  }

  Future<void> invalidar() =>
      _db.delete(tabela, where: 'chave = ?', whereArgs: <Object?>[_chaveListagem]);

  Future<void> invalidarTudo() => _db.delete(tabela);

  /// Remove cache muito antigo, para o banco não crescer sem limite.
  /// Chame na abertura do app.
  Future<int> limparAnteriorA(Duration idade) {
    final int limite =
        DateTime.now().subtract(idade).millisecondsSinceEpoch;
    return _db.delete(tabela, where: 'buscado_em < ?', whereArgs: <Object?>[limite]);
  }
}

/// Cache lido, com a idade.
class CacheDeTrilhas {
  const CacheDeTrilhas({required this.trilhas, required this.buscadoEm});

  final List<Trilha> trilhas;
  final DateTime buscadoEm;

  Duration get idade => DateTime.now().difference(buscadoEm);

  bool expirouEm(Duration ttl) => idade > ttl;

  /// Texto pronto para o aviso na tela. O aviso é proporcional
  /// à idade: minutos não incomodam ninguém; dias precisam aparecer.
  String? get avisoDeIdade {
    final Duration d = idade;
    if (d.inMinutes < 5) return null;
    if (d.inMinutes < 60) return 'Atualizado há ${d.inMinutes} min';
    if (d.inHours < 24) return 'Atualizado há ${d.inHours} h';
    if (d.inDays == 1) return 'Atualizado ontem';
    return 'Atualizado há ${d.inDays} dias';
  }

  bool get muitoAntigo => idade.inDays >= 1;
}
```

> **Arquivo:** `foco_dados/lib/core/sincronizacao/fila_de_pendencias.dart` (novo)

```dart
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// Tipos de operação que podem ficar pendentes.
enum TipoDeOperacao {
  criarTrilha,
  marcarTema,
  desmarcarTema,
  excluirTrilha;

  /// Operações do mesmo tipo sobre o mesmo alvo se anulam ou
  /// se sobrepõem. Ver `_colapsar`.
  bool get ehAlternavel =>
      this == TipoDeOperacao.marcarTema || this == TipoDeOperacao.desmarcarTema;

  TipoDeOperacao? get oposta => switch (this) {
        TipoDeOperacao.marcarTema => TipoDeOperacao.desmarcarTema,
        TipoDeOperacao.desmarcarTema => TipoDeOperacao.marcarTema,
        _ => null,
      };
}

class OperacaoPendente {
  const OperacaoPendente({
    required this.id,
    required this.tipo,
    required this.alvoId,
    required this.carga,
    required this.criadaEm,
    this.tentativas = 0,
    this.ultimoErro,
  });

  factory OperacaoPendente.deLinha(Map<String, Object?> l) {
    return OperacaoPendente(
      id: l['id']! as int,
      tipo: TipoDeOperacao.values.byName(l['tipo']! as String),
      alvoId: l['alvo_id']! as String,
      carga: jsonDecode(l['carga']! as String) as Map<String, Object?>,
      criadaEm: DateTime.fromMillisecondsSinceEpoch(l['criada_em']! as int),
      tentativas: l['tentativas']! as int,
      ultimoErro: l['ultimo_erro'] as String?,
    );
  }

  final int id;
  final TipoDeOperacao tipo;
  final String alvoId;
  final Map<String, Object?> carga;
  final DateTime criadaEm;
  final int tentativas;
  final String? ultimoErro;

  /// Depois de 5 falhas, a operação provavelmente nunca vai funcionar:
  /// dados inválidos, recurso apagado no servidor, permissão revogada.
  /// Insistir só gasta bateria — e esconde o problema do usuário.
  static const int maximoDeTentativas = 5;

  bool get falhouDefinitivamente => tentativas >= maximoDeTentativas;
}

/// Fila de operações feitas offline.
class FilaDePendencias {
  const FilaDePendencias(this._db);

  final DatabaseExecutor _db;

  static const String tabela = 'operacoes_pendentes';

  static Future<void> criarTabela(DatabaseExecutor db) async {
    await db.execute(
      'CREATE TABLE $tabela ('
      // AUTOINCREMENT preserva a ORDEM. Criar uma trilha e depois
      // marcar um tema dela PRECISA ser enviado nessa ordem.
      '  id          INTEGER PRIMARY KEY AUTOINCREMENT,'
      '  tipo        TEXT    NOT NULL,'
      '  alvo_id     TEXT    NOT NULL,'
      '  carga       TEXT    NOT NULL,'
      '  criada_em   INTEGER NOT NULL,'
      '  tentativas  INTEGER NOT NULL DEFAULT 0,'
      '  ultimo_erro TEXT'
      ')',
    );
    await db.execute(
      'CREATE INDEX idx_pendentes_alvo ON $tabela (alvo_id, tipo)',
    );
  }

  /// Enfileira, colapsando operações redundantes.
  Future<void> enfileirar({
    required TipoDeOperacao tipo,
    required String alvoId,
    Map<String, Object?> carga = const <String, Object?>{},
  }) async {
    final Database db = _db as Database;

    await db.transaction((Transaction txn) async {
      // Colapso: marcar e desmarcar o mesmo tema cinco vezes deve
      // gerar UMA operação, não cinco. Sem isto, a fila cresce
      // com trabalho que se anula.
      if (tipo.ehAlternavel) {
        final int removidas = await txn.delete(
          tabela,
          where: 'alvo_id = ? AND tipo IN (?, ?)',
          whereArgs: <Object?>[
            alvoId,
            tipo.name,
            tipo.oposta!.name,
          ],
        );

        // Se removemos exatamente a operação OPOSTA, as duas se anulam
        // e não há nada a enviar.
        if (removidas > 0) {
          final List<Map<String, Object?>> restantes = await txn.query(
            tabela,
            where: 'alvo_id = ?',
            whereArgs: <Object?>[alvoId],
          );
          // Nada restou e a operação se anulou: encerra.
          if (restantes.isEmpty) return;
        }
      }

      await txn.insert(tabela, <String, Object?>{
        'tipo': tipo.name,
        'alvo_id': alvoId,
        'carga': jsonEncode(carga),
        'criada_em': DateTime.now().millisecondsSinceEpoch,
        'tentativas': 0,
      });
    });
  }

  /// Operações a enviar, **na ordem em que foram criadas**.
  Future<List<OperacaoPendente>> pendentes() async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'tentativas < ?',
      whereArgs: <Object?>[OperacaoPendente.maximoDeTentativas],
      orderBy: 'id ASC', // a ordem importa
    );
    return linhas.map(OperacaoPendente.deLinha).toList();
  }

  /// Operações que desistiram. A tela precisa AVISAR o usuário:
  /// ele acha que salvou, e não salvou.
  Future<List<OperacaoPendente>> falhasPermanentes() async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'tentativas >= ?',
      whereArgs: <Object?>[OperacaoPendente.maximoDeTentativas],
      orderBy: 'id ASC',
    );
    return linhas.map(OperacaoPendente.deLinha).toList();
  }

  Future<int> quantidadePendente() async {
    final List<Map<String, Object?>> r = await _db.rawQuery(
      'SELECT COUNT(*) FROM $tabela WHERE tentativas < ?',
      <Object?>[OperacaoPendente.maximoDeTentativas],
    );
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<void> concluir(int id) =>
      _db.delete(tabela, where: 'id = ?', whereArgs: <Object?>[id]);

  Future<void> registrarFalha(int id, String erro) {
    return _db.rawUpdate(
      'UPDATE $tabela SET tentativas = tentativas + 1, ultimo_erro = ? '
      'WHERE id = ?',
      // Mensagem cortada: `ultimo_erro` é diagnóstico, não um log inteiro.
      <Object?>[erro.length > 200 ? erro.substring(0, 200) : erro, id],
    );
  }

  /// Descarta uma falha permanente, depois de o usuário ser avisado.
  Future<void> descartar(int id) => concluir(id);

  Future<void> limparTudo() => _db.delete(tabela);
}
```

> **Arquivo:** `foco_dados/lib/features/trilhas/data/trilha_repositorio.dart` (versão offline)

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_dados/core/rede/status_de_rede.dart';
import 'package:foco_dados/core/sincronizacao/fila_de_pendencias.dart';
import 'package:foco_dados/features/trilhas/data/trilha_api.dart';
import 'package:foco_dados/features/trilhas/data/trilha_cache_dao.dart';
import 'package:foco_dados/features/trilhas/domain/trilha.dart';

/// O que a tela recebe: os dados, de onde vieram e se há pendências.
class TrilhasComOrigem {
  const TrilhasComOrigem({
    required this.trilhas,
    required this.daRede,
    this.avisoDeIdade,
    this.pendencias = 0,
  });

  final List<Trilha> trilhas;
  final bool daRede;

  /// "Atualizado há 3 dias". Null quando o dado é recente.
  final String? avisoDeIdade;

  /// Quantas alterações ainda não foram enviadas.
  final int pendencias;

  bool get temAvisoParaMostrar => avisoDeIdade != null || pendencias > 0;
}

/// Repositório com cache, fila offline e sincronização.
class TrilhaRepositorio {
  const TrilhaRepositorio({
    required TrilhaApi api,
    required TrilhaCacheDao cache,
    required FilaDePendencias fila,
    required ObservadorDeRede rede,
  })  : _api = api,
        _cache = cache,
        _fila = fila,
        _rede = rede;

  final TrilhaApi _api;
  final TrilhaCacheDao _cache;
  final FilaDePendencias _fila;
  final ObservadorDeRede _rede;

  // ── Leitura: stale-while-revalidate ───────────────────────────────────────

  /// Emite o cache IMEDIATAMENTE e depois o dado da rede.
  ///
  /// A tela nunca fica em branco, e se atualiza sozinha quando o dado
  /// novo chega. É o padrão do curso.
  Stream<TrilhasComOrigem> observar() async* {
    final CacheDeTrilhas? cache = await _cache.lerListagem();
    final int pendencias = await _fila.quantidadePendente();

    // 1. Cache primeiro, sem esperar rede.
    if (cache != null) {
      yield TrilhasComOrigem(
        trilhas: cache.trilhas,
        daRede: false,
        avisoDeIdade: cache.avisoDeIdade,
        pendencias: pendencias,
      );

      // Cache fresco: nem vale a pena ir à rede.
      if (!cache.expirouEm(Validade.trilhas)) return;
    }

    // 2. Rede em seguida.
    //
    // Note que NÃO checamos conectividade antes de tentar:
    // connectivity_plus diz se há interface, não se há internet.
    // Tentamos sempre; a conectividade só EXPLICA a falha.
    try {
      final List<Trilha> daRede = await _api.listar();
      await _cache.gravarListagem(daRede);

      yield TrilhasComOrigem(
        trilhas: daRede,
        daRede: true,
        pendencias: pendencias,
      );
    } on Object catch (erro) {
      // Sem cache e sem rede: não há o que mostrar.
      if (cache == null) {
        final StatusDeRede status = await _rede.atual();
        throw status.provavelmenteOnline
            ? FalhaDoServidor('$erro')
            : const FalhaSemConexao();
      }
      // Com cache: o usuário já viu os dados. Jogar um erro na
      // cara dele depois disso seria só ruído — o aviso de idade
      // já comunica o que importa.
    }
  }

  // ── Escrita com fila ──────────────────────────────────────────────────────

  /// Marca ou desmarca um tema.
  ///
  /// Sempre aplica LOCALMENTE primeiro; a fila cuida do envio.
  /// O usuário no metrô consegue usar o app normalmente.
  Future<void> alternarTema({
    required String trilhaId,
    required String tema,
    required bool marcar,
  }) async {
    // 1. Aplica no cache, para a tela refletir a mudança na hora.
    await _aplicarNoCache(trilhaId, tema, marcar);

    // 2. Enfileira. Se houver internet, a sincronização roda logo.
    await _fila.enfileirar(
      tipo: marcar ? TipoDeOperacao.marcarTema : TipoDeOperacao.desmarcarTema,
      alvoId: '$trilhaId/$tema',
      carga: <String, Object?>{'trilha_id': trilhaId, 'tema': tema},
    );

    // 3. Tenta enviar agora. Falhou? Fica na fila.
    unawaited(sincronizar());
  }

  Future<void> _aplicarNoCache(
    String trilhaId,
    String tema,
    bool marcar,
  ) async {
    final CacheDeTrilhas? cache = await _cache.lerListagem();
    if (cache == null) return;

    final List<Trilha> novas = <Trilha>[
      for (final Trilha t in cache.trilhas)
        if (t.id == trilhaId)
          t.copyWith(
            concluidos: <String>{
              ...t.concluidos,
              if (marcar) tema,
            }..removeWhere((String x) => !marcar && x == tema),
          )
        else
          t,
    ];

    await _cache.gravarListagem(novas);
  }

  // ── Sincronização ─────────────────────────────────────────────────────────

  /// Envia as pendências, **na ordem**.
  ///
  /// Para na primeira falha de rede: se a internet caiu, as próximas
  /// também vão falhar, e insistir só gasta bateria. Falha de DADOS
  /// (4xx), ao contrário, não impede as seguintes.
  Future<ResultadoDaSincronizacao> sincronizar() async {
    final List<OperacaoPendente> pendentes = await _fila.pendentes();
    if (pendentes.isEmpty) {
      return const ResultadoDaSincronizacao(enviadas: 0, falhas: 0);
    }

    int enviadas = 0;
    int falhas = 0;

    for (final OperacaoPendente op in pendentes) {
      try {
        await _executar(op);
        await _fila.concluir(op.id);
        enviadas++;
      } on SocketException {
        // Rede caiu: parar aqui. As próximas falhariam igual.
        await _fila.registrarFalha(op.id, 'sem conexão');
        return ResultadoDaSincronizacao(
          enviadas: enviadas,
          falhas: falhas + 1,
          interrompidaPorRede: true,
        );
      } on Object catch (erro) {
        // Erro de dados: registra e SEGUE para a próxima.
        await _fila.registrarFalha(op.id, '$erro');
        falhas++;
      }
    }

    // O servidor mudou: o cache local está desatualizado.
    if (enviadas > 0) await _cache.invalidar();

    return ResultadoDaSincronizacao(enviadas: enviadas, falhas: falhas);
  }

  Future<void> _executar(OperacaoPendente op) async {
    switch (op.tipo) {
      case TipoDeOperacao.marcarTema:
      case TipoDeOperacao.desmarcarTema:
        await _api.alterarTema(
          trilhaId: op.carga['trilha_id']! as String,
          tema: op.carga['tema']! as String,
          marcar: op.tipo == TipoDeOperacao.marcarTema,
        );

      case TipoDeOperacao.criarTrilha:
        await _api.criar(
          Trilha.deJson(op.carga['trilha']! as Map<String, Object?>),
        );

      case TipoDeOperacao.excluirTrilha:
        await _api.excluir(op.alvoId);
    }
  }

  /// Operações que desistiram depois de 5 tentativas.
  ///
  /// A tela PRECISA avisar: o usuário acha que salvou, e não salvou.
  Future<List<OperacaoPendente>> falhasPermanentes() =>
      _fila.falhasPermanentes();
}

class ResultadoDaSincronizacao {
  const ResultadoDaSincronizacao({
    required this.enviadas,
    required this.falhas,
    this.interrompidaPorRede = false,
  });

  final int enviadas;
  final int falhas;
  final bool interrompidaPorRede;

  bool get tudoCerto => falhas == 0 && !interrompidaPorRede;
}

class FalhaSemConexao implements Exception {
  const FalhaSemConexao();
  @override
  String toString() => 'Sem conexão. Verifique sua internet.';
}

class FalhaDoServidor implements Exception {
  const FalhaDoServidor(this.detalhe);
  final String detalhe;
  @override
  String toString() => 'O servidor está com problema. Tente mais tarde.';
}
```

> **Arquivo:** `foco_dados/lib/features/trilhas/presentation/sincronizador.dart` (novo)

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_dados/core/rede/status_de_rede.dart';
import 'package:foco_dados/features/trilhas/data/trilha_repositorio.dart';

/// Dispara a sincronização quando a rede volta.
///
/// Este é o uso LEGÍTIMO do connectivity_plus: não decidir se tenta,
/// mas saber QUANDO vale a pena tentar de novo.
final Provider<void> sincronizadorProvider = Provider<void>((Ref ref) {
  final ObservadorDeRede rede = ref.watch(observadorDeRedeProvider);
  final TrilhaRepositorio repo = ref.watch(trilhaRepositorioProvider);

  StatusDeRede? anterior;

  final StreamSubscription<StatusDeRede> inscricao =
      rede.mudancas.listen((StatusDeRede agora) {
    // Só age na TRANSIÇÃO offline → online. Sem esta comparação,
    // qualquer oscilação de sinal dispararia uma sincronização.
    final bool voltou = anterior == StatusDeRede.semInterface &&
        agora == StatusDeRede.comInterface;
    anterior = agora;

    if (voltou) unawaited(repo.sincronizar());
  });

  // Toda subscription precisa ser cancelada. Módulo 08, aula 8.
  ref.onDispose(inscricao.cancel);
});
```

Rode:

```powershell
flutter pub add connectivity_plus
flutter analyze
flutter test
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `abstract final class Validade` | Os TTLs em um lugar: a política de frescor do app fica visível e ajustável. |
| Cache guardando **JSON cru** | O cache espelha a API. Normalizá-lo obrigaria a migrar o cache toda vez que a API mudasse. Para dados do **próprio usuário**, a escolha é a oposta. |
| `lerListagem()` devolvendo **mesmo expirado** | A decisão de usar é de quem chama. Dado de 3 dias é melhor que tela vazia. |
| `on FormatException` invalidando o cache | Cache de versão antiga do app tem outro formato. Descarte em silêncio — é cache, não dado do usuário. |
| `avisoDeIdade` proporcional | Minutos não incomodam; dias precisam aparecer. Avisar demais é tão ruim quanto não avisar. |
| `Stream<TrilhasComOrigem> observar()` | *Stale-while-revalidate*: emite o cache na hora e a rede depois. Sem tela branca. |
| `if (!cache.expirouEm(...)) return;` | Cache fresco economiza a requisição inteira. |
| **Nenhuma** checagem de conectividade antes de tentar | `connectivity_plus` diz se há **interface**, não se há internet. Tentamos sempre. |
| `_rede.atual()` **dentro do `catch`** | A conectividade **explica** a falha: "sem conexão" em vez de "erro desconhecido". |
| Falha **com** cache não lança | O usuário já viu os dados. Um erro depois disso seria ruído; o aviso de idade já comunica. |
| `id INTEGER PRIMARY KEY AUTOINCREMENT` | Preserva a **ordem**. Criar uma trilha e depois marcar um tema dela precisa ser enviado nessa ordem. |
| Colapso em `enfileirar` | Marcar/desmarcar cinco vezes gera **uma** operação. Sem isso, a fila cresce com trabalho que se anula. |
| `maximoDeTentativas = 5` | Depois disso a operação provavelmente nunca vai funcionar. Insistir gasta bateria e **esconde o problema**. |
| `falhasPermanentes()` | A tela **precisa** avisar: o usuário acha que salvou, e não salvou. |
| `erro.substring(0, 200)` no `registrarFalha` | `ultimo_erro` é diagnóstico, não um log inteiro. |
| `on SocketException` → **para** a sincronização | A internet caiu; as próximas falhariam igual. |
| Outros erros → **seguem** para a próxima | Falha de dados numa operação não impede as outras. |
| `_cache.invalidar()` após enviar | O servidor mudou; o cache local está desatualizado. |
| `anterior == semInterface && agora == comInterface` | Só na **transição**. Sem isso, qualquer oscilação dispararia sincronização. |
| `ref.onDispose(inscricao.cancel)` | Toda `StreamSubscription` precisa ser cancelada. |
| `unawaited(sincronizar())` | Dispara sem bloquear a interface. O usuário não espera o envio. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Sincronizar em segundo plano | `WorkManager` (`workmanager`) | `BGTaskScheduler` — **muito** mais restrito |
| App fechado | Pode rodar com WorkManager | Praticamente não roda |
| Economia de dados | Bloqueia rede em segundo plano | *Low Data Mode* limita |
| Detecção de rede | `ConnectivityManager` | `NWPathMonitor` |
| Portal cativo | O sistema detecta e avisa | O sistema detecta e abre a página |
| Modo avião + Wi-Fi | Diz "conectado" ao Wi-Fi | Idem |

> ⚠️ **A segunda linha é uma restrição de produto, não de código.** No iOS, você **não** pode contar
> com sincronização em segundo plano: o sistema decide se e quando executa, e muitas vezes não
> executa. Projete a fila para sincronizar **quando o app abre** e quando a rede volta **com o app
> aberto**. Prometer "sincroniza sozinho" ao usuário é prometer o que o iOS não entrega.

> 📌 Os dois sistemas detectam portal cativo — e é justamente por isso que
> `connectivity_plus` não basta: ele reporta "Wi-Fi conectado" enquanto o portal bloqueia todo o
> tráfego.

---

## ⚠️ Erros comuns

### 1. Apagar cache expirado

```dart
if (item.expirou) {
  await cache.invalidar();   // ❌ e agora, sem rede, o usuário fica sem nada
  return null;
}
```

**Correção:** mantenha o cache; use-o como reserva quando a rede falhar.

### 2. Mostrar dado antigo como se fosse novo

Sem aviso, o usuário toma decisão com base em informação de três dias.

**Correção:** aviso proporcional à idade.

### 3. Decidir com base em `connectivity_plus`

```dart
if (!temInternet) return cache;   // ❌
```

Wi-Fi de hotel com portal cativo: o app usa cache quando a rede está perfeita — ou tenta rede
quando não há internet.

**Correção:** tente sempre; use a conectividade só para **explicar** a falha.

### 4. Bloquear a ação quando offline

```dart
if (!temInternet) {
  mostrar('Sem conexão');   // ⚠️ o app fica inútil no metrô
  return;
}
```

**Correção:** fila de pendências.

### 5. Fila sem ordem

```dart
orderBy: 'criada_em DESC'   // ❌
```

Marcar um tema de uma trilha **antes** de criar a trilha falha.

**Correção:** `ORDER BY id ASC`, com `AUTOINCREMENT`.

### 6. Fila sem colapso

O usuário marca e desmarca 20 vezes: 20 operações, 19 inúteis.

**Correção:** colapsar operações do mesmo tipo sobre o mesmo alvo.

### 7. Fila sem limite de tentativas

Uma operação impossível (recurso apagado no servidor) fica tentando para sempre, gastando bateria.

**Correção:** `maximoDeTentativas` e aviso ao usuário.

### 8. Não avisar a falha permanente

O usuário acha que salvou. Não salvou. Ele só descobre quando o dado sumir.

**Correção:** tela de "não conseguimos enviar N alterações", com opção de tentar de novo ou
descartar.

### 9. Continuar a fila depois de `SocketException`

```dart
for (final op in pendentes) {
  try { await enviar(op); } catch (_) { continue; }   // ⚠️
}
```

Com a internet fora, todas falham — e cada uma consome uma tentativa do limite.

**Correção:** `SocketException` **para** a sincronização; erro de dados segue.

### 10. Sincronizar a cada mudança de conectividade

Oscilação de sinal dispara dezenas de sincronizações.

**Correção:** só na transição offline → online.

### 11. Não cancelar a `StreamSubscription`

```dart
rede.mudancas.listen(...);   // ❌ sem cancel
```

**Correção:** `ref.onDispose(inscricao.cancel)`.

### 12. Cache crescendo sem limite

Meses de cache acumulado ocupam centenas de MB.

**Correção:** `limparAnteriorA(Duration(days: 30))` na abertura do app.

### 13. Prometer sincronização em segundo plano no iOS

**Correção:** sincronize quando o app abre e quando a rede volta **com o app aberto**. Não prometa
mais.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test test/exemplo_cache_test.dart`. Leia o teste
`rede falha: usa o cache EXPIRADO` e explique por escrito por que ele é o mais importante.

**Passo 2.** Em `cachePrimeiro`, remova o bloco que usa o cache expirado no `catch`. Rode e veja
qual teste falha. O que o usuário veria?

**Passo 3.** No `observar()`, acrescente uma checagem `if (!online) return;` antes da rede. Simule
Wi-Fi com portal cativo (conectividade ok, requisição falha). Descreva o que quebra.

**Passo 4.** Em `avisoDeIdade`, faça retornar sempre uma string, mesmo com 1 minuto. Rode o app e
avalie: o aviso constante ajuda ou vira ruído?

**Passo 5.** No `enfileirar`, remova o colapso. Marque e desmarque o mesmo tema 10 vezes offline.
Conte as operações na fila.

**Passo 6.** Em `sincronizar`, troque o `return` do `SocketException` por `continue`. Enfileire 5
operações, fique offline e sincronize. Quantas tentativas cada uma gastou?

**Passo 7.** Troque `orderBy: 'id ASC'` por `'id DESC'`. Enfileire "criar trilha" e depois "marcar
tema" dela. Sincronize e observe o erro.

**Passo 8.** No `sincronizadorProvider`, remova a comparação com `anterior`. Ative e desative o
Wi-Fi algumas vezes e conte as sincronizações (acrescente um `debugPrint`).

**Passo 9.** Escreva um teste que confirme: uma operação que falha 5 vezes sai de `pendentes()` e
aparece em `falhasPermanentes()`.

**Passo 10.** Projete a tela de falhas permanentes: o que ela mostra, quais botões tem, e o que
acontece em cada um. Escreva em 5 linhas.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md)

Faça os exercícios de **Decisão** entre as três estratégias, o de **Aplicação** com fila de
pendências, e o de **Correção de bugs** com `connectivity_plus` mal usado.

---

## 🏆 Desafio opcional

Implemente **resolução de conflito** no `TrilhaRepositorio`.

Cenário: o usuário marca um tema offline. Enquanto isso, ele usa o app no computador e **desmarca**
o mesmo tema. Quando o celular volta online, quem ganha?

Requisitos:

- Cada trilha carrega `alteradaEm` — vindo **do servidor**, não do relógio local.
- Ao sincronizar, o app envia também o `alteradaEm` que ele tinha ao fazer a alteração.
- Se o servidor devolver `409 Conflict`, o app compara os carimbos:
  - servidor mais recente → descarta a alteração local e **avisa** o usuário;
  - local mais recente → reenvia forçando.
- Para alterações em **campos diferentes** da mesma trilha, faça merge em vez de descartar.
- Um teste simula os três casos.

Dica: o cabeçalho `If-Unmodified-Since` (ou `If-Match` com ETag) faz o servidor recusar a alteração
se o recurso mudou — é assim que APIs REST tratam conflito.

Depois responda: por que o carimbo precisa vir do **servidor**? O que acontece se o relógio do
celular estiver 3 horas adiantado?

---

## 📌 Resumo

- **Cache-first** para dado estável; **network-first** para dado crítico;
  **stale-while-revalidate** para a maioria — e é o padrão do curso.
- Guarde **carimbo de tempo** com o dado e defina **TTL por tipo**.
- **Cache expirado ainda é útil.** Nunca apague o que venceu: use como reserva quando a rede falha.
- **Avise a idade do dado**, de forma proporcional. Mostrar dado de 3 dias como atual é mentir.
- **`connectivity_plus` diz se há interface, não se há internet.** Nunca decida com ele se tenta a
  requisição — use-o para **explicar** a falha, **disparar** a sincronização e **mostrar** o estado.
- Escrever offline exige **fila de pendências**, não bloqueio da ação.
- A fila precisa de: **ordem** (`AUTOINCREMENT`), **colapso** de redundantes, **limite de
  tentativas** e **aviso** de falha permanente.
- Na sincronização: `SocketException` **para** a fila; erro de dados **segue** para a próxima.
- Sincronize só na **transição** offline → online, e cancele a `StreamSubscription`.
- Invalide o cache **depois** de enviar alterações — o servidor mudou.
- **Limpe cache antigo** na abertura, para o banco não crescer sem limite.
- Conflito: o curso usa **"mais recente ganha"**, com carimbo **do servidor**.
- **No iOS não conte com sincronização em segundo plano.** Sincronize quando o app abre.

---

## ☑️ Checklist de domínio

- [ ] Escolho entre as três estratégias com justificativa.
- [ ] Guardo carimbo de tempo e defino TTL por tipo de dado.
- [ ] Uso cache expirado como reserva em vez de apagá-lo.
- [ ] Aviso a idade do dado de forma proporcional.
- [ ] Sei o que `connectivity_plus` **não** garante.
- [ ] Nunca decido se tento a requisição com base em conectividade.
- [ ] Implemento fila de pendências com ordem preservada.
- [ ] Colapso operações redundantes na fila.
- [ ] Limito tentativas e aviso falhas permanentes.
- [ ] Paro a sincronização em `SocketException` e sigo em erro de dados.
- [ ] Sincronizo só na transição offline → online.
- [ ] Cancelo toda `StreamSubscription`.
- [ ] Limpo cache antigo periodicamente.
- [ ] Não prometo sincronização em segundo plano no iOS.

---

## 📚 Referências oficiais

- [connectivity_plus — pub.dev](https://pub.dev/packages/connectivity_plus)
- [workmanager — pub.dev](https://pub.dev/packages/workmanager)
- [Offline-first apps — docs.flutter.dev](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)
- [HTTP caching — MDN](https://developer.mozilla.org/docs/Web/HTTP/Caching)
- [If-Unmodified-Since — MDN](https://developer.mozilla.org/docs/Web/HTTP/Headers/If-Unmodified-Since)
- [Background tasks — developer.apple.com](https://developer.apple.com/documentation/backgroundtasks)
- [WorkManager — developer.android.com](https://developer.android.com/topic/libraries/architecture/workmanager)

---

## 🎓 Fim do Módulo 10

Você começou o módulo sem saber onde guardar um número. Termina com:

- uma **árvore de decisão** para escolher o armazenamento certo (aula 1);
- **preferências** do usuário que sobrevivem ao fechamento (aula 2);
- **arquivos** lidos e escritos com segurança, nas pastas certas (aula 3);
- um **banco SQLite** com esquema pensado, índices e chaves estrangeiras (aula 4);
- **CRUD completo**, à prova de SQL injection e com ordenação correta em português (aula 5);
- **migrações** que evoluem o esquema sem perder dados do usuário (aula 6);
- **dados sensíveis** no cofre da plataforma, fora do backup (aula 7);
- e um app que **funciona offline**, com cache, fila e sincronização (aula 8).

Antes de seguir:

1. Faça os exercícios em
   [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md).
2. Faça a avaliação em
   [avaliacoes/modulo-10-persistencia-de-dados.md](../../avaliacoes/modulo-10-persistencia-de-dados.md).
3. Confirme que `flutter analyze` e `flutter test` no `foco_dados` passam limpos.

No [Módulo 11](../11-recursos-nativos/README.md) o app sai da tela e passa a usar **câmera, arquivos,
notificações e permissões** — os recursos que só existem em um celular de verdade.

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo |
|---|---|---|
| [Aula 7 — Dados sensíveis](07-dados-sensiveis.md) | [README](README.md) | [Módulo 11 — Recursos Nativos](../11-recursos-nativos/README.md) |
