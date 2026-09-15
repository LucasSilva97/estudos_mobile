# Exercícios — Módulo 09: Consumo de API

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Rode `flutter analyze` e `flutter test` no `foco_api` antes de consultar o gabarito.

<a id="m09-e01"></a>
## M09-E01 — Status e idempotência · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Ler status e classificar verbos | Fácil | 15 min | Sim |
Escreva, sem consultar tabela, o significado de `200`, `201`, `204`, `304`, `400`, `401`, `403`, `404`, `409`, `422`, `429`, `500` e `503`, e de quem é a culpa em cada família. Depois classifique `GET`, `POST`, `PUT`, `PATCH` e `DELETE` como idempotentes ou não, com uma frase de justificativa cada. **Esperado:** `POST` e `PATCH` fora da lista de idempotentes, e `401` descrito como "não autenticado", não "sem permissão". [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e01)

<a id="m09-e02"></a>
## M09-E02 — Resposta crua sob a lupa · Leitura de código
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Diagnosticar pela resposta HTTP | Fácil | 20 min | Sim |
Dadas três respostas cruas — (a) `429` com `Retry-After: 30`; (b) `201` com `Location: /posts/201` e corpo `{"id":201}`; (c) `200` com `Content-Type: text/html` num endereço que deveria devolver JSON — diga em duas linhas cada: o que aconteceu, de quem é a culpa e o que o app deve fazer. **Esperado:** em (c) você identifica que `jsonDecode` vai lançar `FormatException` e que um portal de wi-fi é o suspeito. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e02)

<a id="m09-e03"></a>
## M09-E03 — `Trilha.fromJson` aninhado · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Converter JSON aninhado à mão | Média | 30 min | Sim |
Escreva `Autor`, `Topico` e `Trilha` com construtor `const`, `factory fromJson` e `toJson`, para um JSON com `autor` aninhado, lista `topicos`, `minutos` opcional (padrão `0`) e `criadaEm` em ISO 8601 lido com `DateTime.parse`. **Teste:** JSON completo, JSON sem `minutos` e JSON com `"topicos": []`. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e03)

<a id="m09-e04"></a>
## M09-E04 — `title` nulo derruba a lista · Correção de bugs
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Distinguir campo ausente de nulo | Média | 20 min | Sim |
`TrilhaDto.fromJson` faz `title: json['title'] as String` e o app quebra com `type 'Null' is not a subtype of type 'String'` quando um item vem sem `title`. Corrija validando `id` e `title` com `is!` e mensagem que diz **qual** campo falhou, e dê valor padrão a `body` e `userId`. **Esperado:** campo obrigatório ausente lança `FormatException` legível; campo opcional ausente não lança nada. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e04)

<a id="m09-e05"></a>
## M09-E05 — Primeiro GET em `/todos` · Implementação
Na `TarefasScreen`, busque `https://jsonplaceholder.typicode.com/todos` com `Uri.https` e `_limit=20`, cheque o `statusCode` **antes** de decodificar, use `utf8.decode(resposta.bodyBytes)` e exiba `List<Tarefa>` numa `ListView.builder`. Declare `android.permission.INTERNET` no `AndroidManifest.xml`. **Teste:** `flutter run` mostra 20 itens; explique por que o build de debug funcionaria sem a permissão e o de release não. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e05)

<a id="m09-e06"></a>
## M09-E06 — `Future` nascendo no `build` · Correção de bugs
Uma tela faz `FutureBuilder(future: _buscarTarefas(), ...)` direto no `build`: girar o aparelho ou abrir o teclado dispara uma requisição nova. Mova o `Future` para um campo `late Future<List<Tarefa>>` criado no `initState` e acrescente um botão que recarrega dentro de `setState`. **Teste:** com um `debugPrint` na função de busca, abra o teclado e confirme que ela não roda de novo. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e06)

<a id="m09-e07"></a>
## M09-E07 — `FalhaManutencao` de ponta a ponta · Implementação
Acrescente `final class FalhaManutencao extends Falha` em `core/erros/falhas.dart`, com `mensagem` e `comoResolver` em português, traduza o `503` para ela no ponto em que `ApiException` vira `Falha`, e cubra o novo caso no `switch` exaustivo do widget `EstadoDeFalha`. **Esperado:** o compilador aponta todo `switch` incompleto, e a tela mostra texto em português sem nenhum `toString()` de exceção. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e07)

<a id="m09-e08"></a>
## M09-E08 — `PUT`, `PATCH` e o que pode repetir · Decisão
Responda por escrito, em até 15 linhas: o usuário renomeia só o título de uma trilha enquanto outro aparelho marcou um tópico como concluído — `PUT` ou `PATCH`, e o que se perde escolhendo errado? Depois diga quais métodos de `TrilhaApi` (`listar`, `criar`, `substituir`, `alterar`, `excluir`) podem entrar em `repetir()`, justificando cada exclusão. **Esperado:** `criar` fora do retry por não ser idempotente, e `excluir` aceitando `404` como sucesso. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e08)

<a id="m09-e09"></a>
## M09-E09 — Escrita completa na `TrilhaApi` · Aplicação
Implemente `criar`, `alterar` e `excluir` em `TrilhaApi` com `Content-Type: application/json; charset=utf-8`, corpo via `jsonEncode` e `_exigirSucesso` com os status esperados de cada verbo (`201`/`200`, `200`, `200`/`204`/`404`). O corpo do `PATCH` leva só os campos informados, e um `ArgumentError` é lançado se nada mudou. **Teste:** crie uma trilha, confira o `201` com `id` novo e explique por que ela some ao recarregar a lista. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e09)

<a id="m09-e10"></a>
## M09-E10 — `repetir` com backoff e jitter · Aplicação
Escreva `Future<T> repetir<T>(Future<T> Function() acao, {int maximoDeTentativas = 3, Duration esperaBase = const Duration(milliseconds: 400), Duration esperaMaxima = const Duration(seconds: 8)})` que repete `SocketException`, `TimeoutException`, `5xx` e `429`, nunca repete os demais `4xx`, dobra a espera a cada tentativa e soma uma variação aleatória. **Teste:** uma ação que falha com `500` duas vezes e acerta na terceira devolve o valor; uma que falha com `404` lança já na primeira. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e10)

<a id="m09-e11"></a>
## M09-E11 — Busca que mostra o resultado errado · Correção de bugs
No `BuscaController`, digitar "dar" logo depois de "da" às vezes deixa a tela com os resultados de "da", porque a resposta lenta chega por último. Acrescente o contador `_sequencia`, descarte respostas **e erros** cuja vez não é mais a atual, e mantenha o debounce de 400 ms com o `Timer` cancelado em `ref.onDispose`. **Teste:** dispare duas buscas com atrasos invertidos e confirme que só a última pinta o estado. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e11)

<a id="m09-e12"></a>
## M09-E12 — Camada de dados sob teste · Revisão cumulativa
Separe `TrilhaApi` (HTTP e JSON, devolve `TrilhaDto`) de `TrilhaRepositorio` (DTO → `Trilha`, exceção técnica → `Falha`), ambos atrás de `TrilhaRepositorioContrato` no `domain`. Escreva `test/trilhas/trilha_api_test.dart` com `MockClient` e um fixture real cobrindo `200`, `404`, `500`, JSON malformado e `SocketException`. **Esperado:** `flutter test` passa no Windows sem emulador e nenhuma `ApiException` escapa do repositório. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e12)

<a id="m09-e13"></a>
## M09-E13 — Onde mora cada segredo · Decisão
Diga por escrito onde guardar cada item — token de acesso, token de renovação, `URL_BASE`, chave de API de pagamento e preferência de tema — entre `flutter_secure_storage`, `SharedPreferences`, `--dart-define` e "no seu backend", uma frase por escolha. Explique também por que cinco `401` simultâneos compartilham um único `Future<String>? _renovacaoEmAndamento`, e qual provider você substituiria para testar a `TrilhasTab` sem rede. **Esperado:** a chave de pagamento fora do app, e `trilhaRepositorioProvider` como ponto de substituição. [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e13)

<a id="m09-e14"></a>
## M09-E14 — Aba Trilhas de ponta a ponta · Desafio prático
Monte a cadeia `clienteHttpProvider → trilhaApiProvider → trilhaRepositorioProvider → trilhasProvider` e uma `TrilhasTab` que cubra carregando, vazio, sucesso e erro com `AsyncValue.when`. O `RefreshIndicator` deve chamar `ref.read(trilhasProvider.notifier).recarregar()`, que usa `AsyncLoading().copyWithPrevious(state)`, em vez de `ref.invalidate` — senão a lista pisca e a rolagem se perde. **Teste:** puxe para atualizar e veja os itens continuarem visíveis; substitua o repositório por um falso que lança `FalhaDeConexao` e confirme o estado de erro com "Tentar de novo". [🔑 Gabarito](../gabaritos/09-consumo-de-api.md#m09-e14)

[Módulo](../modulos/09-consumo-de-api/README.md)
