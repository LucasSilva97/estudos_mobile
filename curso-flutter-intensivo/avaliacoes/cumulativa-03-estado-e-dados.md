# Avaliação — Cumulativa 03: Estado e dados

> **Cobre:** módulos 08, 09 e 10 · **Tempo sugerido:** 35 min de questões + 80 min de prática.
> Faça sem consultar o material.

Aqui não se cobra módulo por módulo, e sim a **cadeia inteira** do app Foco: `http.Client` →
`TrilhaApi` → `TrilhaRepositorio` → `sqflite` → `AsyncNotifier` → tela.

## 1. Questionário

Cada questão vale 1 ponto — **12 pontos no total**.

1. O provider do repositório é declarado `Provider<TrilhaRepositorioContrato>` e não `Provider<TrilhaRepositorio>` porque: A) o Riverpod só aceita interfaces; B) sem o contrato no tipo, `overrideWithValue(RepositorioFalso())` no teste não compila, já que o falso não é subtipo da classe concreta; C) `autoDispose` exige `abstract interface class`; D) é o que impede o `domain/` de importar `package:http`.  
2. Na cadeia `TrilhaApi` → `TrilhaRepositorio` → `TrilhasController`, o `.timeout(const Duration(seconds: 15))` fica: A) no `Future<List<Trilha>> build()` do controller; B) na chamada do `http.Client` dentro do `TrilhaApi`, antes de qualquer `jsonDecode`; C) dentro do `AsyncValue.guard`, que recebe o prazo; D) no `Provider<http.Client>`, como argumento de fábrica.  
3. No `observar()` com *stale-while-revalidate*, o cache do sqflite está **dentro** do TTL de `Validade.trilhas`. O repositório: A) emite o cache e ainda assim chama a API para conferir; B) emite o cache e encerra, sem ir à rede; C) apaga o cache e busca na rede; D) espera a rede antes de emitir qualquer coisa.  
4. A API falhou com `SocketException` e **existe** cache, já emitido para a tela. O certo é: A) relançar `FalhaSemConexao` para o `AsyncValue` virar `error`; B) manter os dados na tela e comunicar só pelo aviso de idade; C) apagar o cache expirado e mostrar tela vazia; D) consultar `connectivity_plus` antes de tentar de novo.  
5. Você trocou o `TrilhaRepositorio` que só falava HTTP por um que também grava no sqflite, mantendo `Future<List<Trilha>> listar()` do contrato. Na `presentation`: A) todo widget que usa `ref.watch(trilhasProvider)` muda; B) nada muda — o controller conhece só o contrato, e a troca acontece no provider; C) só o `ProviderScope` muda; D) o `AsyncNotifier` vira `Notifier` síncrono.  
6. A API passou a devolver o campo `nivel` e o cache gravado ontem não o tem. Quem quebra ao abrir o app offline: A) o `query` do `sqflite`, por coluna inexistente; B) o `fromJson` ao reidratar o JSON do cache, se `nivel` for lido com `as` direto e sem valor padrão; C) o `onUpgrade`, que não conhece o campo novo; D) o `AsyncValue.guard`, que rejeita mapa incompleto.  
7. Guardar o token numa tabela do banco de sessões é errado porque: A) o `sqflite` não aceita `TEXT` longo; B) o `.db` é arquivo comum, legível e sujeito a backup do sistema — token vai para o `flutter_secure_storage`; C) o `sqflite` não indexa colunas de token; D) o `http` não lê do `sqflite`.  
8. Ao voltar a conexão você quer sincronizar a fila de pendências e avisar com `SnackBar`. O lugar: A) no `build` do `ConsumerWidget`, comparando com o estado anterior; B) num `ref.listen` declarado no `build`, com o efeito dentro do callback; C) no `Future build()` do `AsyncNotifier`, após o `await`; D) num `ref.read` dentro do `initState`.

9. O repositório busca da API, grava no sqflite e o controller expõe `AsyncValue`. Explique onde entra o tratamento de timeout e por quê.  
10. Diga o que `TrilhaApi`, `TrilhaCacheDao` e `TrilhaRepositorio` fazem e o que cada um nunca faz — e qual deles o `AsyncNotifier` pode importar.  
11. Explique por que `domain/` não importa `material.dart`, `package:http` nem `package:sqflite`, e o que isso te dá na hora de testar.  
12. Explique por que o curso proíbe decidir com `connectivity_plus` **antes** de chamar a API, e qual é então o papel dele na falha que chega ao `AsyncValue.error`.

## 2. Prática

Entregue a feature `trilhas` do Foco de ponta a ponta, em `lib/features/trilhas/`. No `domain`, o
modelo imutável `Trilha`, o contrato `abstract interface class TrilhaRepositorioContrato` e a
`sealed class Falha`. No `data`, `TrilhaApi` com o `http.Client` injetado, `TrilhaCacheDao` gravando
o JSON com `buscado_em` no sqflite e `TrilhaRepositorio` com *stale-while-revalidate*, TTL e
tradução de exceção em `Falha`. No `presentation`, a cadeia de providers e
`TrilhasController extends AsyncNotifier<List<Trilha>>`. Feche com testes que rodam no Windows.

| Critério | Pontos |
|---|---:|
| Cadeia de providers (cliente → api → repositório tipado pelo contrato → controller) | 2 |
| `TrilhaApi` com `http.Client` injetado, `.timeout` e faixa `2xx` conferida antes do `jsonDecode` | 1 |
| Cache no sqflite com `buscado_em`, TTL e migração encadeada com `if (de < N)` | 2 |
| Repositório traduz toda exceção em `Falha` e serve o cache quando a rede falha | 2 |
| Controller com `AsyncValue.guard` e recarga que não apaga a lista da tela | 1 |
| Teste da cadeia com `ProviderContainer`, `overrides`, `MockClient` e `sqflite_common_ffi`, cobrindo rede OK, rede falha com cache e cache expirado | 2 |

## 3. Critérios para avançar

- **9/12** no questionário e **8/10** na prática.
- Avaliações dos módulos 08, 09 e 10 já aprovadas.
- `flutter analyze` sem nenhum aviso e `flutter test` verde no Windows, sem emulador.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Contrato, `overrides` e teste sem emulador | [08 — Injeção de dependências](../modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md) | M08 E07 e E08 |
| `AsyncValue`, recarga e efeitos colaterais | [08 — AsyncNotifier e AsyncValue](../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) | M08 E05 e E06 |
| Timeout e quando não repetir | [09 — Timeout, retry e cancelamento](../modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md) | M09 E05 |
| `service` × `repository` e tradução de falha | [09 — Camada de dados testável](../modulos/09-consumo-de-api/07-camada-de-dados-testavel.md) | M09 E06 |
| Providers em cadeia e os quatro estados | [09 — API com Riverpod](../modulos/09-consumo-de-api/09-api-com-riverpod.md) | M09 E08 |
| Migração e CRUD com `whereArgs` | [10 — Migrações](../modulos/10-persistencia-de-dados/06-migracoes.md) | M10 E05 e E07 |
| TTL, aviso de idade, cofre e fila offline | [10 — Cache e offline](../modulos/10-persistencia-de-dados/08-cache-e-offline.md) | M10 E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#cumulativa-03)
