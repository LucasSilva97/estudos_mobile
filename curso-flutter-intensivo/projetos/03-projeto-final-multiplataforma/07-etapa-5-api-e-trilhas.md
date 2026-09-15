# Etapa 5 — API e trilhas — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 3 h · **Depende de:** [Etapa 4 — Telas e navegação](06-etapa-4-telas-e-navegacao.md) ·
> **Aulas:** [9.4 Respostas e erros](../../modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md) ·
> [9.6 Timeout e retry](../../modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md) ·
> [9.7 Camada de dados](../../modulos/09-consumo-de-api/07-camada-de-dados-testavel.md) ·
> [9.9 API com Riverpod](../../modulos/09-consumo-de-api/09-api-com-riverpod.md)

## 🎯 O que existe ao fim desta etapa

A aba **Trilhas** deixa de ser `Placeholder`: busca `GET /posts?_limit=20`, cobre os **quatro
estados** de tela, grava o JSON cru em `cache_trilhas` e o reaproveita por **6 h**. Em modo avião
ela continua funcionando — mostra o cache com a faixa **"Atualizado há X · sem conexão"** e um
botão "Tentar de novo". Sem cache e sem rede, um `EstadoDeErro` em português, nunca um
`toString()` de exceção. Tocar num cartão abre o `TrilhaDetalheSheet`
(RF17, RF18, RF19, RNF12, RNF13).

## 📦 Dependências

| Pacote | Versão | Por quê |
|---|---|---|
| `http` | `^1.6.0` | O único cliente HTTP do projeto (ADR-04), e o que o `MockClient` da etapa 7 entende |
| `meta` | `^1.16.0` | O `@immutable` do `domain/`, que não pode importar Flutter. Pode já estar lá desde a etapa 2 |

```bash
flutter pub add http meta
```

Da etapa 4 esta página usa `const EstadoCarregando()`, `EstadoVazio({titulo, mensagem, icone})` e
`EstadoDeErro({titulo, mensagem, onTentarDeNovo})`. Se as suas assinaturas divergirem, ajuste a
chamada em `trilhas_tab.dart`.

## 🧩 Os arquivos desta etapa

| Arquivo | Papel |
|---|---|
| `core/erros/api_exception.dart` | Exceção técnica: status, URI, `Retry-After` |
| `core/erros/falhas.dart` | `sealed class Falha` + `converterParaFalha` |
| `core/http/cliente_http.dart` | Prazos e retentativa com backoff |
| `core/widgets/aviso_offline.dart` | A faixa "Atualizado há X · sem conexão" |
| `trilhas/domain/trilha.dart` | O modelo — sem `userId` |
| `trilhas/domain/trilhas_resultado.dart` | Lista + carimbo de tempo + `deCache` |
| `trilhas/domain/trilha_repositorio_contrato.dart` | O que a presentation enxerga |
| `trilhas/data/trilha_dto.dart` | Espelha o JSON da API |
| `trilhas/data/trilha_api.dart` | Monta a URL, confere o status, devolve o corpo cru |
| `trilhas/data/trilha_cache_dao.dart` | A linha única da tabela `cache_trilhas` |
| `trilhas/data/trilha_repositorio.dart` | Rede + cache + TTL + tradução de erro |
| `trilhas/presentation/trilhas_controller.dart` | `AsyncNotifier<TrilhasResultado>` |
| `trilhas/presentation/trilhas_tab.dart` | Os 4 estados + puxar-para-atualizar |
| `trilhas/presentation/widgets/cartao_trilha.dart` | O item da lista |
| `trilhas/presentation/widgets/trilha_detalhe_sheet.dart` | O sheet (não é rota) |

### lib/core/erros/api_exception.dart

> **Por que ele existe:** guardar o status como **número** deixa quem está acima decidir: repetir
> um `5xx`, respeitar um `Retry-After`, desistir de um `4xx`.

```dart
/// O servidor respondeu, mas fora da faixa de sucesso (2xx).
class ApiException implements Exception {
  const ApiException(this.statusCode, this.uri,
      {this.cabecalhos = const <String, String>{}});

  final int statusCode;
  final Uri uri;
  final Map<String, String> cabecalhos;

  /// Quanto o servidor pediu para esperar. Só o formato em segundos, que é o
  /// usado pela maioria das APIs.
  Duration? get retryAfter {
    final int? s = int.tryParse(cabecalhos['retry-after']?.trim() ?? '');
    return s == null ? null : Duration(seconds: s);
  }

  @override
  String toString() => 'ApiException($statusCode) em $uri';
}
```

### lib/core/erros/falhas.dart

> **Por que ele existe:** é a única fronteira em que `SocketException` vira português. Depois
> daqui, o app inteiro fala a língua de `Falha`.

```dart
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:foco/core/erros/api_exception.dart';

/// Tudo o que pode dar errado ao falar com a API, em lista fechada.
///
/// `sealed`: só é estendida NESTE arquivo, então um `switch` que esqueça um
/// caso não compila — o erro aparece na análise, não em produção.
sealed class Falha {
  const Falha(this.mensagem, this.comoResolver, {this.podeTentarDeNovo = true});
  final String mensagem; // o que aconteceu, para o usuário
  final String comoResolver; // o que ele pode fazer agora
  final bool podeTentarDeNovo;
}

final class FalhaSemConexao extends Falha {
  const FalhaSemConexao()
      : super('Você está sem conexão com a internet.',
            'Ligue o Wi-Fi ou os dados móveis e tente de novo.');
}

final class FalhaTempoEsgotado extends Falha {
  const FalhaTempoEsgotado()
      : super('O servidor demorou demais para responder.',
            'Sua conexão pode estar lenta. Tente novamente.');
}

final class FalhaServidor extends Falha {
  const FalhaServidor(this.statusCode)
      : super('O servidor de trilhas está com problemas.',
            'Não é nada do seu lado. Tente em alguns minutos.');
  final int statusCode;
}

final class FalhaFormato extends Falha {
  const FalhaFormato(this.detalheTecnico)
      : super('Recebemos uma resposta inesperada do servidor.',
            'Já registramos o problema. Tente mais tarde.');
  final String detalheTecnico; // só para log. ⚠️ Nunca mostre na tela
}

final class FalhaDesconhecida extends Falha {
  const FalhaDesconhecida(this.detalheTecnico)
      : super('Algo inesperado aconteceu ao buscar as trilhas.',
            'Tente novamente. Se continuar, reinicie o app.');
  final String detalheTecnico;
}

/// Converte qualquer erro capturado na [Falha] correspondente.
/// A ordem importa: do mais específico para o mais genérico.
Falha converterParaFalha(Object erro) {
  if (erro is Falha) return erro;
  if (erro is ApiException) {
    return switch (erro.statusCode) {
      429 || >= 500 => FalhaServidor(erro.statusCode),
      _ => FalhaDesconhecida(erro.toString()),
    };
  }
  if (erro is TimeoutException) return const FalhaTempoEsgotado();
  if (erro is SocketException) return const FalhaSemConexao();
  // O pacote http embrulha queda de conexão em ClientException.
  if (erro is http.ClientException) return const FalhaSemConexao();
  if (erro is FormatException) return FalhaFormato(erro.message);
  return FalhaDesconhecida(erro.toString());
}
```

### lib/core/http/cliente_http.dart

> **Por que ele existe:** prazo e retentativa são política de rede, não regra de trilha.

```dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:foco/core/erros/api_exception.dart';

/// Prazos de rede do Foco. RNF12: nenhuma requisição sem timeout.
abstract final class Prazos {
  static const Duration leitura = Duration(seconds: 15);
  static const int tentativas = 3; // 1 original + 2 repetições
  static const Duration esperaBase = Duration(seconds: 1); // 1 s, depois 2 s
}

/// Executa [acao] repetindo **só** o que pode passar sozinho.
///
/// ⚠️ Vale apenas para operações idempotentes (aula 9.6). O Foco só faz GET;
/// num POST, repetir criaria dois registros.
Future<T> comRetentativa<T>(Future<T> Function() acao) async {
  final math.Random sorteio = math.Random();
  Object? ultimoErro;
  StackTrace? ultimaPilha;
  for (int tentativa = 0; tentativa < Prazos.tentativas; tentativa++) {
    try {
      return await acao();
    } on Object catch (erro, pilha) {
      ultimoErro = erro;
      ultimaPilha = pilha;
      if (!_ehTransitorio(erro)) rethrow; // permanente: repetir não adianta
      if (tentativa == Prazos.tentativas - 1) break;
      await Future<void>.delayed(_espera(tentativa, erro, sorteio));
    }
  }
  Error.throwWithStackTrace(ultimoErro!, ultimaPilha!); // com a pilha original
}

bool _ehTransitorio(Object erro) {
  if (erro is SocketException || erro is http.ClientException) return true;
  if (erro is TimeoutException) return true;
  // 5xx, 429 e 408 podem passar sozinhos. Outro 4xx é erro nosso.
  if (erro is ApiException) {
    final int s = erro.statusCode;
    return s >= 500 || s == 429 || s == 408;
  }
  return false;
}

Duration _espera(int tentativa, Object erro, math.Random sorteio) {
  if (erro is ApiException && erro.retryAfter != null) return erro.retryAfter!;
  // Backoff exponencial (base × 2^tentativa) + jitter de até 30%, para mil
  // aparelhos não repetirem no mesmo milissegundo.
  final int base = Prazos.esperaBase.inMilliseconds * (1 << tentativa);
  return Duration(milliseconds: base + sorteio.nextInt(base ~/ 3));
}
```

> 📌 O `clienteHttpProvider` — **um** `http.Client` para o app, fechado em `ref.onDispose` — já
> nasceu em `providers_raiz.dart` na etapa 2. ⚠️ Nunca use `http.get()` avulso: cada chamada
> abriria conexão TCP e handshake TLS novos.

### lib/features/trilhas/domain/trilha.dart

> **Por que ele existe:** o app não tem "post", tem trilha. E trilha não tem `userId`.

```dart
import 'package:meta/meta.dart';

@immutable
class Trilha {
  const Trilha(
      {required this.id, required this.titulo, required this.descricao});
  final String id; // veio int da API e virou String aqui
  final String titulo;
  final String descricao;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trilha &&
          other.id == id &&
          other.titulo == titulo &&
          other.descricao == descricao;

  @override
  int get hashCode => Object.hash(id, titulo, descricao);
}
```

### lib/features/trilhas/domain/trilhas_resultado.dart

> **Por que ele existe:** a tela precisa saber **de onde** veio a lista; sem isso não há aviso do
> RF19.

```dart
import 'package:meta/meta.dart';
import 'package:foco/features/trilhas/domain/trilha.dart';

@immutable
class TrilhasResultado {
  const TrilhasResultado(
      {required this.trilhas, required this.buscadoEm, required this.deCache});
  final List<Trilha> trilhas;
  final DateTime buscadoEm;

  /// `true` só quando a **rede falhou** e o app caiu no cache. Cache dentro
  /// do TTL é dado válido, não modo degradado: ali é `false`.
  final bool deCache;
}
```

### lib/features/trilhas/domain/trilha_repositorio_contrato.dart

> **Por que ele existe:** é este tipo que o teste da etapa 7 substitui.

```dart
import 'package:foco/features/trilhas/domain/trilhas_resultado.dart';

/// ⚠️ Todo método aqui lança [Falha] — nunca `ApiException`, nunca
/// `SocketException`. Traduzir erro técnico é trabalho da implementação.
abstract interface class TrilhaRepositorioContrato {
  Future<TrilhasResultado> listar();
  Future<void> limparCache();
}
```

### lib/features/trilhas/data/trilha_dto.dart

> **Por que ele existe:** se a JSONPlaceholder renomear `title`, só este arquivo muda.

```dart
import 'dart:convert';

/// Espelha EXATAMENTE o JSON da API — inclusive `userId`, que o domínio não
/// quer.
class TrilhaDto {
  const TrilhaDto(
      {required this.id,
      required this.title,
      required this.body,
      required this.userId});

  /// ⚠️ Nada de `json['id'] as int` (aula 9.7): o cast direto estoura com
  /// `TypeError` e não diz qual campo veio errado.
  factory TrilhaDto.deJson(Map<String, Object?> json) {
    final Object? id = json['id'];
    final Object? title = json['title'];
    if (id is! int) throw FormatException('Campo "id" inválido: $id');
    if (title is! String) throw const FormatException('Campo "title" vazio');
    return TrilhaDto(
      id: id,
      title: title,
      // Opcionais: valor padrão em vez de exceção.
      body: json['body'] is String ? json['body']! as String : '',
      userId: json['userId'] is int ? json['userId']! as int : 0,
    );
  }

  /// Decodifica o corpo cru — o mesmo texto que vai para o cache.
  static List<TrilhaDto> listaDeJson(String corpo) {
    final Object? bruto = jsonDecode(corpo);
    if (bruto is! List<Object?>) {
      throw const FormatException('Esperava uma lista de trilhas.');
    }
    return bruto.map((Object? item) {
      if (item is! Map<String, Object?>) {
        throw const FormatException('Item de trilha inválido.');
      }
      return TrilhaDto.deJson(item);
    }).toList();
  }

  final int id;
  final String title;
  final String body;
  final int userId;
}
```

### lib/features/trilhas/data/trilha_api.dart

> **Por que ele existe:** montar URL e conferir status é uma responsabilidade; converter dado é
> outra.

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:foco/core/constantes/ambiente.dart';
import 'package:foco/core/erros/api_exception.dart';
import 'package:foco/core/http/cliente_http.dart';

class TrilhaApi {
  TrilhaApi({required http.Client cliente, String? urlBase})
      : _cliente = cliente,
        _urlBase = urlBase ?? Ambiente.urlBase; // --dart-define, etapa 1
  final http.Client _cliente;
  final String _urlBase;

  /// `GET /posts?_limit=20`. Devolve o corpo **cru**: é ele que o repositório
  /// grava no cache, byte por byte.
  Future<String> buscarTrilhas() {
    final Uri uri = Uri.parse('$_urlBase/posts?_limit=20');
    return comRetentativa<String>(() async {
      final http.Response r = await _cliente.get(uri,
          headers: const <String, String>{
            'Accept': 'application/json'
          }).timeout(Prazos.leitura);
      // Os cabeçalhos vão junto: é deles que sai o Retry-After.
      if (r.statusCode != 200) {
        throw ApiException(r.statusCode, uri, cabecalhos: r.headers);
      }
      // ⚠️ `r.body` decodifica em latin1 quando falta o charset no header —
      // acento vira "Ã§". Sempre utf8 sobre bodyBytes.
      return utf8.decode(r.bodyBytes);
    });
  }
}
```

### lib/features/trilhas/data/trilha_cache_dao.dart

> **Por que ele existe:** a tabela `cache_trilhas` (v3) tem **uma** linha, de id `'trilhas'`.

```dart
import 'package:sqflite/sqflite.dart';

class TrilhaCacheDao {
  const TrilhaCacheDao(this._db);
  static const String _id = 'trilhas';
  final Database _db;

  Future<({String conteudo, DateTime buscadoEm})?> ler() async {
    final List<Map<String, Object?>> linhas = await _db.query('cache_trilhas',
        where: 'id = ?', // RNF11: só `?` com whereArgs, sem exceção
        whereArgs: <Object?>[_id],
        limit: 1);
    if (linhas.isEmpty) return null;
    final Map<String, Object?> l = linhas.first;
    return (
      conteudo: l['conteudo']! as String,
      buscadoEm: DateTime.fromMillisecondsSinceEpoch(l['buscado_em']! as int),
    );
  }

  Future<void> gravar({required String conteudo, required DateTime buscadoEm}) {
    return _db.insert(
      'cache_trilhas',
      <String, Object?>{
        'id': _id,
        'conteudo': conteudo,
        'buscado_em': buscadoEm.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // mantém a linha única
    );
  }

  Future<void> limpar() =>
      _db.delete('cache_trilhas', where: 'id = ?', whereArgs: <Object?>[_id]);
}
```

### lib/features/trilhas/data/trilha_repositorio.dart

> **Por que ele existe:** aqui mora a política do RF18 e do RF19 inteira — TTL, queda para o
> cache e tradução de exceção em `Falha`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco/core/erros/falhas.dart';
import 'package:foco/core/providers/providers_raiz.dart';
import 'package:foco/features/trilhas/data/trilha_api.dart';
import 'package:foco/features/trilhas/data/trilha_cache_dao.dart';
import 'package:foco/features/trilhas/data/trilha_dto.dart';
import 'package:foco/features/trilhas/domain/trilha.dart';
import 'package:foco/features/trilhas/domain/trilha_repositorio_contrato.dart';
import 'package:foco/features/trilhas/domain/trilhas_resultado.dart';

class TrilhaRepositorio implements TrilhaRepositorioContrato {
  TrilhaRepositorio(
      {required TrilhaApi api,
      required TrilhaCacheDao cache,
      DateTime Function()? agora})
      : _api = api,
        _cache = cache,
        _agora = agora ?? DateTime.now; // injetável: a etapa 7 congela o tempo

  static const Duration ttl = Duration(hours: 6); // RF18
  final TrilhaApi _api;
  final TrilhaCacheDao _cache;
  final DateTime Function() _agora;

  @override
  Future<TrilhasResultado> listar() async {
    final ({String conteudo, DateTime buscadoEm})? cache = await _cache.ler();
    final DateTime agora = _agora();

    // 1. Cache fresco: dado válido, sem rede e sem aviso de offline.
    if (cache != null && agora.difference(cache.buscadoEm) < ttl) {
      final List<Trilha>? doCache = _converter(cache.conteudo);
      if (doCache != null) {
        return TrilhasResultado(
            trilhas: doCache, buscadoEm: cache.buscadoEm, deCache: false);
      }
    }

    try {
      final String corpo = await _api.buscarTrilhas();
      // ⚠️ Converte ANTES de gravar: JSON inválido não substitui cache bom.
      final List<Trilha> trilhas =
          TrilhaDto.listaDeJson(corpo).map(_paraDominio).toList();
      await _cache.gravar(conteudo: corpo, buscadoEm: agora);
      return TrilhasResultado(
          trilhas: trilhas, buscadoEm: agora, deCache: false);
    } on Object catch (erro, pilha) {
      // 2. Rede falhou e existe cache, mesmo vencido: devolve com o aviso.
      if (cache != null) {
        final List<Trilha>? doCache = _converter(cache.conteudo);
        if (doCache != null) {
          return TrilhasResultado(
              trilhas: doCache, buscadoEm: cache.buscadoEm, deCache: true);
        }
      }
      // 3. Sem cache: sobe uma Falha, com a pilha original preservada.
      Error.throwWithStackTrace(converterParaFalha(erro), pilha);
    }
  }

  @override
  Future<void> limparCache() => _cache.limpar();

  /// Cache ilegível não derruba a tela: vale como "não tem cache".
  List<Trilha>? _converter(String conteudo) {
    try {
      return TrilhaDto.listaDeJson(conteudo).map(_paraDominio).toList();
    } on FormatException {
      return null;
    }
  }

  /// DTO → domínio, num lugar só. O `userId` fica para trás.
  Trilha _paraDominio(TrilhaDto dto) =>
      Trilha(id: dto.id.toString(), titulo: dto.title, descricao: dto.body);
}

/// Exposto pelo **contrato**, não pela classe concreta: é este tipo que a
/// etapa 7 troca com `overrideWithValue(repositorioFalso)`.
final Provider<TrilhaRepositorioContrato> trilhaRepositorioProvider =
    Provider<TrilhaRepositorioContrato>((Ref ref) {
  return TrilhaRepositorio(
    api: TrilhaApi(cliente: ref.watch(clienteHttpProvider)),
    cache: TrilhaCacheDao(ref.watch(bancoProvider)),
  );
});
```

### lib/features/trilhas/presentation/trilhas_controller.dart

> **Por que ele existe:** repare no que ele **não** importa — `http`, `jsonDecode`, `sqflite`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco/features/trilhas/data/trilha_repositorio.dart';
import 'package:foco/features/trilhas/domain/trilhas_resultado.dart';

final AsyncNotifierProvider<TrilhasController, TrilhasResultado>
    trilhasProvider =
    AsyncNotifierProvider<TrilhasController, TrilhasResultado>(
        TrilhasController.new);

class TrilhasController extends AsyncNotifier<TrilhasResultado> {
  @override
  Future<TrilhasResultado> build() =>
      ref.watch(trilhaRepositorioProvider).listar();

  /// Recarrega **mantendo a lista na tela**.
  ///
  /// ⚠️ `ref.invalidate` aqui apagaria o estado e voltaria a `AsyncLoading`
  /// sem dados: a tela pisca e a rolagem se perde (aula 9.9, erro comum 2).
  Future<void> recarregar() async {
    state = const AsyncLoading<TrilhasResultado>().copyWithPrevious(state);
    state = await AsyncValue.guard(
        () => ref.read(trilhaRepositorioProvider).listar());
  }

  /// Usado pelo "Limpar cache de trilhas" da `ConfiguracoesScreen` (RF20).
  Future<void> limparCache() async {
    await ref.read(trilhaRepositorioProvider).limparCache();
    ref.invalidateSelf();
  }
}
```

### lib/core/widgets/aviso_offline.dart

> **Por que ele existe:** o RF19 exige dizer **quando** o dado foi buscado; "sem conexão" sozinho
> não diz se a lista tem uma hora ou três dias.

```dart
import 'package:flutter/material.dart';

class AvisoOffline extends StatelessWidget {
  const AvisoOffline(
      {required this.buscadoEm, required this.aoTentarDeNovo, super.key});
  final DateTime buscadoEm;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true, // o leitor de tela anuncia a perda de conexão
      child: Container(
        width: double.infinity,
        color: cores.secondaryContainer,
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        // Wrap e não Row: em 200% de fonte o botão desce para a linha de
        // baixo em vez de estourar o layout (RNF03).
        child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Icon(Icons.cloud_off_outlined,
                size: 20, color: cores.onSecondaryContainer),
            Text('Atualizado ${haQuantoTempo(buscadoEm)} · sem conexão',
                style: TextStyle(color: cores.onSecondaryContainer)),
            TextButton(
                onPressed: aoTentarDeNovo, child: const Text('Tentar de novo')),
          ],
        ),
      ),
    );
  }
}

/// "há 5 min", "há 2 h", "há 3 dias".
String haQuantoTempo(DateTime instante, {DateTime? agora}) {
  final Duration desde = (agora ?? DateTime.now()).difference(instante);
  if (desde.inMinutes < 1) return 'há menos de 1 min';
  if (desde.inMinutes < 60) return 'há ${desde.inMinutes} min';
  if (desde.inHours < 24) return 'há ${desde.inHours} h';
  return 'há ${desde.inDays} ${desde.inDays == 1 ? 'dia' : 'dias'}';
}
```

### lib/features/trilhas/presentation/trilhas_tab.dart

> **Por que ele existe:** traduz os três casos de `AsyncValue` nos **quatro** estados de tela —
> "vazio" é conteúdo do sucesso, não um quarto ramo do `when`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco/core/erros/falhas.dart';
import 'package:foco/core/widgets/aviso_offline.dart';
import 'package:foco/core/widgets/estado_carregando.dart';
import 'package:foco/core/widgets/estado_de_erro.dart';
import 'package:foco/core/widgets/estado_vazio.dart';
import 'package:foco/features/trilhas/domain/trilha.dart';
import 'package:foco/features/trilhas/domain/trilhas_resultado.dart';
import 'package:foco/features/trilhas/presentation/trilhas_controller.dart';
import 'package:foco/features/trilhas/presentation/widgets/cartao_trilha.dart';

class TrilhasTab extends ConsumerWidget {
  const TrilhasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TrilhasResultado> estado = ref.watch(trilhasProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(trilhasProvider.notifier).recarregar(),
      // `when` ignora o loading de uma recarga que já tem dado anterior
      // (skipLoadingOnRefresh): a lista não pisca ao puxar.
      child: estado.when(
        loading: () => const EstadoCarregando(),
        error: (Object erro, StackTrace pilha) {
          final Falha falha = converterParaFalha(erro); // ⚠️ nunca toString()
          return EstadoDeErro(
            titulo: falha.mensagem,
            mensagem: falha.comoResolver,
            onTentarDeNovo: () => ref.invalidate(trilhasProvider),
          );
        },
        data: (TrilhasResultado resultado) {
          if (resultado.trilhas.isEmpty) {
            return const EstadoVazio(
              titulo: 'Nenhuma trilha sugerida',
              mensagem: 'Puxe a lista para baixo para buscar de novo.',
              icone: Icons.explore_outlined,
            );
          }
          return Column(
            children: <Widget>[
              if (resultado.deCache)
                AvisoOffline(
                  buscadoEm: resultado.buscadoEm,
                  aoTentarDeNovo: () =>
                      ref.read(trilhasProvider.notifier).recarregar(),
                ),
              Expanded(
                child: ListView.builder(
                  // Sem isto, lista curta não aceita o puxar-para-atualizar.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: resultado.trilhas.length,
                  itemBuilder: (BuildContext context, int i) {
                    final Trilha trilha = resultado.trilhas[i];
                    return CartaoTrilha(
                        key: ValueKey<String>(trilha.id), trilha: trilha);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

> ⚠️ `EstadoVazio` e `EstadoDeErro` precisam ser **roláveis** (`ListView` com
> `AlwaysScrollableScrollPhysics`, como na aula 6.12). Widget não rolável dentro de
> `RefreshIndicator` não recebe o gesto — e o usuário fica sem saída.

### lib/features/trilhas/presentation/widgets/cartao_trilha.dart

> **Por que ele existe:** o item da lista, sem estado e `const` onde dá (RNF06).

```dart
import 'package:flutter/material.dart';

import 'package:foco/features/trilhas/domain/trilha.dart';
import 'package:foco/features/trilhas/presentation/widgets/trilha_detalhe_sheet.dart';

class CartaoTrilha extends StatelessWidget {
  const CartaoTrilha({required this.trilha, super.key});
  final Trilha trilha;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        minVerticalPadding: 12, // 48 dp de alvo mesmo com título curto (RNF02)
        leading: const Icon(Icons.explore_outlined),
        title:
            Text(trilha.titulo, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(trilha.descricao,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () => mostrarTrilhaDetalheSheet(context, trilha),
      ),
    );
  }
}
```

### lib/features/trilhas/presentation/widgets/trilha_detalhe_sheet.dart

> **Por que ele existe:** detalhe de trilha não é a sexta tela — é um `bottomSheet`, e por isso
> não tem rota nem argumento de rota.

```dart
import 'package:flutter/material.dart';

import 'package:foco/features/trilhas/domain/trilha.dart';

Future<void> mostrarTrilhaDetalheSheet(BuildContext context, Trilha trilha) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true, // o texto pode passar de meia tela
    builder: (BuildContext context) => TrilhaDetalheSheet(trilha: trilha),
  );
}

class TrilhaDetalheSheet extends StatelessWidget {
  const TrilhaDetalheSheet({required this.trilha, super.key});
  final Trilha trilha;

  @override
  Widget build(BuildContext context) {
    final TextTheme tipografia = Theme.of(context).textTheme;
    return SafeArea(
      // Rolável: em 200% de fonte o texto passa da altura do sheet (RNF03).
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(trilha.titulo, style: tipografia.headlineSmall),
            const SizedBox(height: 12),
            Text(trilha.descricao, style: tipografia.bodyLarge),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar')),
            ),
          ],
        ),
      ),
    );
  }
}
```

Por fim, troque o `Placeholder` da terceira aba do `InicioScreen` por `const TrilhasTab()`.

## ▶️ Rodando

```bash
flutter analyze
flutter run --dart-define=FOCO_API_BASE=https://jsonplaceholder.typicode.com
```

Um instante de carregando e 20 cartões na aba **Trilhas**. Feche e reabra o app: os cartões
aparecem **na hora**, sem tocar na rede, porque o TTL de 6 h não venceu. Ligue o modo avião,
limpe o cache em Configurações e volte à aba — agora é `EstadoDeErro` com "Você está sem conexão
com a internet." Desligue o avião e toque em "Tentar de novo".

## ✅ Conferência

- [ ] Primeira abertura mostra carregando e depois 20 trilhas.
- [ ] Puxar-para-atualizar **não** pisca a lista nem perde a rolagem.
- [ ] Reabrir em menos de 6 h não dispara requisição (DevTools → Network).
- [ ] Modo avião **com** cache: lista + faixa "Atualizado há X · sem conexão".
- [ ] Modo avião **sem** cache: `EstadoDeErro` em português, com botão que funciona.
- [ ] Nenhuma tela mostra `Exception`, `SocketException` ou *stack trace*.
- [ ] Tocar num cartão abre o sheet; "Fechar" volta para a lista.
- [ ] Nenhum arquivo de `domain/` importa `http`, `sqflite` ou `material.dart`.
- [ ] `flutter analyze` → `No issues found!`.

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| `no such table: cache_trilhas` | O banco ficou na v2 | Revise o `if (anterior < 3)` do `onUpgrade` e reinstale o app |
| Acentos viram `Ã§`, `Ã£` | Uso de `r.body`, que assume latin1 | `utf8.decode(r.bodyBytes)` |
| `Client is already closed` | O `http.Client` foi fechado e reusado | Um cliente só, do `clienteHttpProvider`, com `close` no `ref.onDispose` |
| A lista pisca a cada puxão | `ref.invalidate` no `onRefresh` | Chame `recarregar()`, que usa `copyWithPrevious` |
| `RefreshIndicator` não dispara no vazio | O widget de vazio não é rolável | `ListView` com `AlwaysScrollableScrollPhysics` |
| `Failed host lookup` no 🤖 emulador | Falta a permissão `INTERNET` | O manifesto de debug já a traz; o de `main` sai na etapa 8 |
| A tela mostra `FormatException: ...` | O erro não passou por `converterParaFalha` | A tela só lê `mensagem` e `comoResolver` de uma `Falha` |
| Um `4xx` repetido 3 vezes | `_ehTransitorio` aceitando `4xx` | Só `5xx`, `429` e `408` repetem |
| As trilhas somem após resposta corrompida | O cache foi gravado antes de converter | Grave **depois** de `TrilhaDto.listaDeJson` passar |

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [Etapa 4 — Telas e navegação](06-etapa-4-telas-e-navegacao.md) | [README do projeto](README.md) | [Etapa 6 — Responsividade e acessibilidade](08-etapa-6-responsividade-e-acessibilidade.md) |
