# Avaliação — Módulo 09: Consumo de API

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. A API devolve `{"nota": 4}` e o seu modelo declara `final double nota`. A leitura correta é: A) `json['nota'] as double`; B) `(json['nota'] as num).toDouble()`; C) `double.parse(json['nota'] as String)`; D) `json['nota'] as int`.  
2. Um `DELETE` respondeu `204 No Content` e você chamou `jsonDecode(resposta.body)`. Acontece que: A) devolve `null`, sem erro; B) devolve um `Map` vazio; C) lança `FormatException: Unexpected end of input`; D) lança `ApiException` com `statusCode` 204.  
3. Qual chamada **não** pode ser envolvida pela função `repetir`: A) `GET /posts?_limit=10`; B) `PUT /posts/7`; C) `DELETE /posts/7`; D) `POST /posts`.  
4. Colocar `default:` num `switch` sobre a `sealed class Falha`: A) é obrigatório, senão não compila; B) faz o compilador parar de acusar a falha nova que você esquecer de tratar; C) impede o uso de `switch` de expressão; D) só afeta o desempenho em release.  
5. O app recebeu `403 Forbidden`. A reação certa é: A) renovar o token e repetir a requisição; B) apagar o token e mandar a pessoa entrar de novo; C) mostrar "você não tem permissão", sem renovar nada; D) repetir com backoff exponencial.  
6. Na arquitetura do módulo, quem converte `SocketException` em `Falha`: A) o `TrilhaApi`, logo depois do `await`; B) o `TrilhaRepositorio`, ao implementar o contrato; C) o `TrilhasController`, dentro do `AsyncValue.guard`; D) o widget `EstadoDeFalha`, no `switch` da tela.

7. Diferencie `TrilhaApi` de `TrilhaRepositorio`: o que cada um faz e o que cada um nunca faz.  
8. Explique por que `android.permission.INTERNET` precisa estar no `AndroidManifest.xml` principal, mesmo com o app funcionando no emulador sem ela. 🤖  
9. Explique por que o curso prefere um método do controller com `copyWithPrevious` a `ref.invalidate` dentro do `RefreshIndicator`.  
10. Cite dois lugares onde nunca se guarda um token, diga onde guardar de verdade e qual mecanismo cada plataforma usa.

## 2. Prática

No projeto `foco_api`, acrescente a feature `metas` seguindo a separação da aula 7. Crie `MetaDto`
com `fromJson` que valida campo ausente, o modelo de domínio `Meta`, o contrato
`MetaRepositorioContrato` com `Future<List<Meta>> listar()`, o service `MetaApi` recebendo o
`http.Client` pelo construtor e chamando `GET $base/posts?_limit=5`, e `MetaRepositorio`
implementando o contrato. Escreva três testes com `mocktail` cobrindo `200`, `500` e JSON inválido.
Tudo precisa rodar com `flutter test` no Windows, sem emulador e sem aparelho.

| Critério | Pontos |
|---|---:|
| `MetaApi` recebe o `http.Client` pelo construtor, aplica `.timeout` e confere a faixa `2xx` antes do `jsonDecode` | 2 |
| `MetaDto.fromJson` valida campo ausente e lança `FormatException` dizendo qual campo falhou | 2 |
| `MetaRepositorio` implementa o contrato e converte DTO em modelo de domínio num lugar só | 2 |
| Toda exceção técnica sai do repositório já traduzida em `Falha` | 2 |
| Três testes com `mocktail` (`200`, `500` e JSON inválido) passando | 1 |
| `flutter analyze` sem avisos e `flutter test` verde | 1 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem avisos e `flutter test` verde no `foco_api`.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Status, verbos e idempotência | [Aula 01](../modulos/09-consumo-de-api/01-http-e-rest.md) | E01 |
| Conversão de JSON e tipos | [Aula 02](../modulos/09-consumo-de-api/02-json.md) | E02 |
| Primeiro `GET`, permissão e ATS | [Aula 03](../modulos/09-consumo-de-api/03-primeiro-get.md) | E03 |
| Erros que chegam à tela | [Aula 04](../modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md) | E04 |
| Escrita, `201`, `204` e retry | [Aulas 05 e 06](../modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md) | E05 |
| Service, repositório e testes | [Aula 07](../modulos/09-consumo-de-api/07-camada-de-dados-testavel.md) | E06 |
| Token, `401` e `403` | [Aula 08](../modulos/09-consumo-de-api/08-autenticacao-e-tokens.md) | E07 |
| Providers e os quatro estados | [Aula 09](../modulos/09-consumo-de-api/09-api-com-riverpod.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-09)
