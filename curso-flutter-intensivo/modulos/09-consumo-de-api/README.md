# Módulo 09 — Consumo de API

> **Nível:** Intermediário · **Tempo estimado total:** 400 min (≈ 6 h 40 min)
> · **Pré-requisito direto:**
> [Módulo 08 — Estado e Arquitetura](../08-estado-e-arquitetura/README.md)

Até agora todo dado do seu aplicativo nasceu dentro dele: uma lista escrita no código, um número
guardado em memória, um formulário preenchido na tela. Neste módulo o aplicativo passa a
**conversar com o mundo** — ele pede dados a um computador que está em outro lugar, espera a
resposta, entende o que voltou, e sobrevive quando nada volta.

Esse é o ponto em que um app de estudo vira um app de verdade. E é também o ponto em que os
problemas deixam de ser só de lógica e passam a ser de **realidade**: a internet cai, o servidor
demora, o usuário entra no elevador, a resposta vem num formato diferente do esperado, o token
expira. Um aplicativo profissional não é o que funciona quando tudo dá certo — é o que continua
compreensível quando algo dá errado.

O módulo é construído sobre **um único aplicativo que cresce aula após aula**: o **`foco_api`**,
um laboratório que monta exatamente a funcionalidade de **Trilhas sugeridas** do projeto final
**Foco — Organizador de Estudos**. Ao terminar a aula 9, você terá a aba **Trilhas** funcionando
de ponta a ponta, com estados de carregando, vazio, sucesso e erro, puxar-para-atualizar e
testes automatizados rodando no Windows sem emulador.

Versões usadas em todas as aulas: **Flutter 3.47.1** · **Dart 3.13.1** · **`http: ^1.6.0`** ·
**`flutter_riverpod: ^3.4.3`** · **`mocktail: ^1.0.5`** · **`flutter_secure_storage: ^11.1.1`**.

---

## 🌐 A API que o curso usa

Todas as aulas apontam para a mesma API pública:

```text
https://jsonplaceholder.typicode.com
```

API (*Application Programming Interface* — "interface de programação de aplicações": um conjunto
de endereços que um programa oferece para outro programa consumir, em vez de oferecer telas para
uma pessoa usar).

Ela foi escolhida porque é pública, usa HTTPS, não exige cadastro nem token, e responde a
`GET`, `POST`, `PUT`, `PATCH` e `DELETE`. Foi **verificada online em 2026-09-14**, com estas
respostas reais:

| Requisição | Resposta real medida |
|---|---|
| `GET /todos/1` | `200` · `{"userId":1,"id":1,"title":"delectus aut autem","completed":false}` |
| `GET /posts` | `200` · 100 itens |
| `POST /todos` | `201` · devolve o objeto com `"id": 201` |

> ⚠️ **Aviso que se repete em todo o módulo, porque é a maior fonte de confusão:**
> a JSONPlaceholder **simula** a escrita. Ela responde `201 Created` e devolve o objeto com um
> `id` novo, mas **não guarda nada**. Se você recarregar a lista, o item que você "criou" não
> estará lá. Isso **não é um bug do seu código** — é o comportamento declarado do serviço.
> A aula [05 — POST, PUT e DELETE](05-post-put-delete.md) explica isso em detalhe.

---

## 🎯 O que você vai aprender

Ao terminar este módulo você será capaz de:

- **Explicar o modelo cliente-servidor** e descrever, campo a campo, o que sai do seu aplicativo
  numa requisição HTTP e o que volta numa resposta: método, URL, cabeçalhos, corpo e código de
  status.
- **Ler um código de status** e saber, sem consultar nada, se o problema é seu (`4xx`), do
  servidor (`5xx`), ou se deu tudo certo (`2xx`) — e o que significam `200`, `201`, `204`, `301`,
  `304`, `400`, `401`, `403`, `404`, `409`, `422`, `429`, `500`, `502`, `503` e `504`.
- **Dizer o que é idempotência** e por que ela decide se você pode ou não repetir uma requisição
  que falhou.
- **Converter JSON em objetos Dart à mão**, com `jsonDecode`, `jsonEncode`, construtor
  `factory ... .fromJson` e método `toJson`, tratando campo ausente, campo nulo, aninhamento e
  data em ISO 8601 — e entender exatamente por que `dynamic` é perigoso.
- **Fazer a sua primeira requisição real** com o pacote `http`, exibir o resultado numa
  `ListView` e ver o app funcionando de ponta a ponta no emulador.
- **Modelar falhas** com uma exceção própria (`ApiException`) e uma hierarquia `sealed`, traduzir
  `SocketException`, `FormatException` e `TimeoutException` em mensagens em português que
  realmente ajudam, e **nunca** mostrar *stack trace* ao usuário final.
- **Escrever com `POST`, `PUT`, `PATCH` e `DELETE`**, montar cabeçalhos `Content-Type`, enviar o
  corpo com `jsonEncode` e conferir o `statusCode` de cada verbo.
- **Blindar toda requisição** com `.timeout(Duration(seconds: 15))`, implementar **retry com
  backoff exponencial** escrito à mão, saber **quando não repetir**, cancelar requisições com
  `http.Client` + `close()` e aplicar **debounce** numa busca.
- **Separar `service` de `repository`**, injetar o `http.Client` pelo construtor e escrever
  testes com `mocktail` que cobrem `200`, `500` e JSON inválido — rodando com `flutter test` no
  Windows, **sem emulador e sem aparelho**.
- **Entender autenticação e autorização**, o cabeçalho `Authorization: Bearer`, onde **nunca**
  guardar um token, como guardar direito com `flutter_secure_storage` (Keychain no iOS, Keystore
  no Android), como reagir a um `401` e como usar `--dart-define` em vez de escrever segredo no
  código.
- **Juntar tudo com Riverpod 3**: provider do cliente HTTP, provider do serviço, provider do
  repositório, `AsyncNotifier` consumindo o contrato, `AsyncValue.when` cobrindo os quatro
  estados de tela e `ref.invalidate` no puxar-para-atualizar.

---

## ✅ Pré-requisitos

| Pré-requisito | Onde está | Por que é necessário |
|---|---|---|
| Módulo 08 — Estado e Arquitetura | [modulos/08-estado-e-arquitetura/README.md](../08-estado-e-arquitetura/README.md) | A aula 9 é a junção de Riverpod com API; sem `AsyncNotifier` e `AsyncValue` ela não faz sentido |
| `AsyncNotifier` e `AsyncValue` | [08/07-asyncnotifier-e-asyncvalue.md](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) | Os quatro estados de tela saem daí |
| Injeção de dependências | [08/10-injecao-de-dependencias.md](../08-estado-e-arquitetura/10-injecao-de-dependencias.md) | Injetar `http.Client` pelo construtor é o que torna a camada testável |
| `Future` e `async`/`await` | [04/02-futures-e-async-await.md](../04-dart-avancado/02-futures-e-async-await.md) | **Toda** chamada de rede é assíncrona |
| Exceções em Dart | [04/01-exceptions.md](../04-dart-avancado/01-exceptions.md) | `try`/`on`/`catch`/`finally` aparece em todas as aulas a partir da 4 |
| `sealed class` e `switch` exaustivo | [04/06-sealed-classes.md](../04-dart-avancado/06-sealed-classes.md) | A hierarquia de falhas da aula 4 é uma `sealed class` |
| Estados de UI | [06/12-estados-de-ui.md](../06-widgets-e-layouts/12-estados-de-ui.md) | Carregando, vazio, erro e sucesso são exatamente os quatro estados da aula 9 |
| Ambiente funcionando | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) | Você vai rodar `flutter run` e `flutter test` em quase todas as aulas |

Checagem rápida — abra o **PowerShell** e rode:

```powershell
flutter --version
```

A saída precisa mostrar `Flutter 3.47.1` e `Dart 3.13.1`. Se não mostrar, volte para
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) antes de seguir.

E confirme que você tem internet funcionando na máquina, porque **a partir da aula 3 o código
realmente sai para a rede**:

```powershell
curl.exe -s -o NUL -w "%{http_code}`n" https://jsonplaceholder.typicode.com/todos/1
```

O esperado é imprimir `200`.

> 🪟 Repare que é `curl.exe`, com extensão. No PowerShell, `curl` puro é um apelido para
> `Invoke-WebRequest`, que tem outros parâmetros e vai reclamar de `-s` e `-o`. A aula 1 explica
> isso com calma.

---

## 🧱 O projeto que cresce ao longo do módulo

Na aula 3 você cria **uma única vez** o projeto do módulo:

```powershell
flutter create --platforms=android,ios foco_api
```

Da aula 3 em diante, cada aula acrescenta arquivos a esse mesmo projeto. Este é o estado final
dele, ao terminar a aula 9:

```text
foco_api/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── config/ambiente.dart
│   │   ├── erros/{api_exception.dart,falhas.dart}
│   │   ├── http/{cliente_http.dart,repetir.dart}
│   │   └── seguranca/cofre_token.dart
│   └── features/
│       ├── tarefas/
│       │   ├── domain/tarefa.dart
│       │   └── presentation/tarefas_screen.dart
│       └── trilhas/
│           ├── data/{trilha_api.dart,trilha_repositorio.dart}
│           ├── domain/{trilha.dart,trilha_repositorio_contrato.dart}
│           └── presentation/{trilhas_controller.dart,trilhas_tab.dart}
├── test/
│   └── trilhas/{trilha_test.dart,trilha_api_test.dart,trilha_repositorio_test.dart}
└── pubspec.yaml
```

Compare com a árvore do projeto final em
[projetos/03-projeto-final-multiplataforma/01-especificacao.md](../../projetos/03-projeto-final-multiplataforma/01-especificacao.md):
`features/trilhas/data/{trilha_api.dart,trilha_repositorio.dart}`,
`features/trilhas/domain/trilha.dart` e
`features/trilhas/presentation/{trilhas_controller.dart,trilhas_tab.dart}` são **os mesmos
caminhos**. Isso é de propósito: o que você montar aqui é literalmente a etapa 5 do projeto
final, descrita em
[07-etapa-5-api-e-trilhas.md](../../projetos/03-projeto-final-multiplataforma/07-etapa-5-api-e-trilhas.md).

---

## 🗺️ Ordem recomendada das aulas

Siga **nesta ordem**. Cada aula assume a anterior e mexe no mesmo projeto.

| # | Aula | Tempo | O que entra na sua cabeça |
|---|---|---|---|
| 1 | [01 — HTTP e REST](01-http-e-rest.md) | 40 min | Cliente-servidor, HTTP, partes da URL/URI, `GET`/`POST`/`PUT`/`PATCH`/`DELETE`, cabeçalhos, corpo, famílias `2xx`/`3xx`/`4xx`/`5xx`, idempotência, o que é REST, inspecionar com navegador e `curl.exe` |
| 2 | [02 — JSON](02-json.md) | 45 min | Tipos do JSON, `jsonDecode`/`jsonEncode`, o perigo do `dynamic`, `factory fromJson` e `toJson`, listas de objetos, campo ausente × nulo, aninhamento, ISO 8601 e `DateTime.parse` |
| 3 | [03 — Primeiro GET](03-primeiro-get.md) | 45 min | `http: ^1.6.0`, permissão `INTERNET` no Android 🤖, ATS no iOS 🍎, `Uri.parse`, `statusCode`, `body`, `List<Tarefa>`, `ListView.builder`, app rodando |
| 4 | [04 — Modelando respostas e erros](04-modelando-respostas-e-erros.md) | 45 min | `ApiException` com `statusCode`, `SocketException`, `FormatException`, `TimeoutException`, `sealed class Falha`, mensagens em português, nunca mostrar *stack trace* |
| 5 | [05 — POST, PUT e DELETE](05-post-put-delete.md) | 40 min | `Content-Type`, corpo com `jsonEncode`, `201 Created`, `PUT` × `PATCH`, `DELETE`, e por que a JSONPlaceholder **não persiste** |
| 6 | [06 — Timeout, retry e cancelamento](06-timeout-retry-cancelamento.md) | 45 min | `.timeout(Duration(seconds: 15))`, backoff exponencial à mão, quando **não** repetir, `http.Client` reutilizado, `client.close()`, debounce de busca |
| 7 | [07 — Camada de dados testável](07-camada-de-dados-testavel.md) | 50 min | `service` × `repository`, contrato abstrato no `domain`, DTO → modelo de domínio, injeção do `http.Client`, testes com `mocktail` cobrindo `200`, `500` e JSON inválido |
| 8 | [08 — Autenticação e tokens](08-autenticacao-e-tokens.md) | 40 min | Autenticação × autorização, `Authorization: Bearer`, onde **nunca** guardar token, `flutter_secure_storage ^11.1.1`, Keychain 🍎 e Keystore 🤖, tratar `401`, `.gitignore`, `--dart-define` |
| 9 | [09 — API com Riverpod](09-api-com-riverpod.md) | 50 min | Providers do cliente/serviço/repositório, `AsyncNotifier`, `AsyncValue.when` nos 4 estados, `RefreshIndicator` + `ref.invalidate`, aba Trilhas completa |

**Total: 400 min.** Nenhuma aula deste módulo é opcional: a aula 9 depende de todas as outras.

No [plano intensivo de 30 dias](../../01-plano-intensivo.md), este módulo ocupa:

| Dia | O que fazer |
|---|---|
| **19** | Aulas 1 a 5 + os exercícios que citam essas aulas |
| **20** | Aulas 6 a 9 + avaliação do módulo |

---

## 📝 Exercícios e avaliação

| Etapa | Arquivo | Quando fazer |
|---|---|---|
| Exercícios do módulo | [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md) | Ao terminar cada aula, faça os exercícios que citam aquela aula |
| Gabarito comentado | [gabaritos/09-consumo-de-api.md](../../gabaritos/09-consumo-de-api.md) | **Só depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-09-consumo-de-api.md](../../avaliacoes/modulo-09-consumo-de-api.md) | Depois da aula 9 |
| Avaliação cumulativa de estado e dados | [avaliacoes/cumulativa-03-estado-e-dados.md](../../avaliacoes/cumulativa-03-estado-e-dados.md) | Dia 22 do plano, cobrindo os módulos 08, 09 e 10 |
| Projeto final — etapa 5 | [projetos/.../07-etapa-5-api-e-trilhas.md](../../projetos/03-projeto-final-multiplataforma/07-etapa-5-api-e-trilhas.md) | Dia 26: é a aplicação direta deste módulo |

---

## 🔗 Para onde isso vai

| Conceito deste módulo | Onde reaparece |
|---|---|
| Guardar a resposta para uso offline | [10 — Cache e offline](../10-persistencia-de-dados/08-cache-e-offline.md) |
| Token em armazenamento seguro | [10 — Dados sensíveis](../10-persistencia-de-dados/07-dados-sensiveis.md) |
| Saber se há internet antes de tentar | [11 — Conectividade](../11-recursos-nativos/05-conectividade.md) |
| `mocktail`, mocks e fakes a fundo | [12 — Mocks e fakes](../12-testes-e-debug/07-mocks-e-fakes.md) |
| Não travar a tela durante a rede | [13 — Assíncrono sem travar](../13-desempenho-e-seguranca/03-assincrono-sem-travar.md) |
| Segurança de rede no app publicado | [13 — Segurança mobile](../13-desempenho-e-seguranca/06-seguranca-mobile.md) |
| Permissão `INTERNET` no build de release 🤖 | [14 — Permissões Android](../14-build-android/05-permissoes-android.md) |
| Chaves de `Info.plist` no iOS 🍎 | [15 — Ícone, splash, versão e Info.plist](../15-build-ios/05-icone-splash-versao-infoplist.md) |
| A aba Trilhas dentro do app Foco | [Projeto final — etapa 5](../../projetos/03-projeto-final-multiplataforma/07-etapa-5-api-e-trilhas.md) |

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir fazer **sem consultar a aula**:

- [ ] Descrevo, em voz alta, o que sai do app numa requisição HTTP e o que volta na resposta.
- [ ] Separo uma URL em esquema, host, porta, caminho, query string e fragmento.
- [ ] Digo o significado de `200`, `201`, `204`, `304`, `400`, `401`, `403`, `404`, `409`, `422`,
      `429`, `500`, `502`, `503` e `504` sem consultar tabela.
- [ ] Explico idempotência e digo quais verbos HTTP são idempotentes e por quê.
- [ ] Converto um JSON aninhado em objetos Dart à mão, com `fromJson` e `toJson`, tratando campo
      ausente, campo nulo e data em ISO 8601.
- [ ] Explico por que `jsonDecode` devolve `dynamic` e por que isso é perigoso.
- [ ] Faço um `GET` real com `package:http`, converto para `List<T>` e exibo numa `ListView`.
- [ ] Declaro `android.permission.INTERNET` no `AndroidManifest.xml` e explico por que o build de
      **debug** funciona sem ela mas o de **release** não. 🤖
- [ ] Explico o que é ATS no iOS e por que a API do curso é HTTPS. 🍎
- [ ] Tenho uma `ApiException` com mensagem e `statusCode` e uma `sealed class Falha` com
      `switch` exaustivo.
- [ ] Traduzo `SocketException`, `FormatException` e `TimeoutException` em mensagens em português
      que dizem o que aconteceu e o que fazer.
- [ ] Nunca mostro `toString()` de exceção nem *stack trace* na tela do usuário final.
- [ ] Faço `POST` com `Content-Type: application/json` e corpo `jsonEncode`, e confiro o `201`.
- [ ] Explico a diferença entre `PUT` e `PATCH` com um exemplo concreto.
- [ ] Explico por que a JSONPlaceholder devolve `201` mas não persiste.
- [ ] Coloco `.timeout(Duration(seconds: 15))` em **toda** requisição e explico o que acontece sem
      isso.
- [ ] Implemento retry com backoff exponencial e digo quando **não** repetir.
- [ ] Reutilizo um `http.Client` e chamo `close()` no lugar certo.
- [ ] Aplico debounce numa busca e explico quantas requisições isso economiza.
- [ ] Separo `service` de `repository`, com contrato abstrato no `domain`.
- [ ] Injeto o `http.Client` pelo construtor e escrevo teste com `mocktail` para `200`, `500` e
      JSON inválido — e `flutter test` passa no Windows sem emulador.
- [ ] Explico a diferença entre autenticação e autorização.
- [ ] Listo quatro lugares onde **nunca** se guarda token e digo onde guardar de verdade.
- [ ] Uso `--dart-define` para a URL base em vez de escrever no código.
- [ ] Monto os providers do cliente, do serviço e do repositório, e o `AsyncNotifier` da tela.
- [ ] Minha tela cobre os quatro estados — carregando, vazio, sucesso e erro — e tem
      puxar-para-atualizar com `ref.invalidate`.
- [ ] Todos os exercícios **obrigatórios** de
      [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md) estão feitos.
- [ ] Acertei ao menos 7 das 10 questões de
      [avaliacoes/modulo-09-consumo-de-api.md](../../avaliacoes/modulo-09-consumo-de-api.md).
- [ ] `flutter analyze` no `foco_api` termina com `No issues found!`.
- [ ] `flutter test` no `foco_api` termina com `All tests passed!`.

Quando todos estiverem marcados, siga para o
[Módulo 10 — Persistência de Dados](../10-persistencia-de-dados/README.md).

---

## 📚 Referências oficiais do módulo

- [Fetch data from the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [Send data to the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/send-data)
- [Update data over the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/update-data)
- [Delete data on the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/delete-data)
- [Parse JSON in the background — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/background-parsing)
- [JSON and serialization — docs.flutter.dev](https://docs.flutter.dev/data-and-backend/serialization/json)
- [http package — pub.dev](https://pub.dev/packages/http)
- [dart:convert library — api.dart.dev](https://api.dart.dev/stable/dart-convert/dart-convert-library.html)
- [dart:io library — api.dart.dev](https://api.dart.dev/stable/dart-io/dart-io-library.html)
- [mocktail package — pub.dev](https://pub.dev/packages/mocktail)
- [flutter_secure_storage package — pub.dev](https://pub.dev/packages/flutter_secure_storage)
- [Riverpod — Networking, error handling](https://riverpod.dev/)
- [MDN — HTTP overview](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview)
- [MDN — HTTP response status codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [JSONPlaceholder — Guide](https://jsonplaceholder.typicode.com/guide/)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 08 — Estado e Arquitetura](../08-estado-e-arquitetura/README.md) | [README do curso](../../README.md) | [Aula 1 — HTTP e REST](01-http-e-rest.md) |
