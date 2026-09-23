# Aula 1 — HTTP e REST

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Explicar o modelo **cliente-servidor** e dizer quem é o cliente e quem é o servidor no seu app.
- Descrever o que é **HTTP** e por que ele é um protocolo de *pergunta e resposta*.
- Separar uma **URL** nas suas partes: esquema, host, porta, caminho, *query string* e fragmento.
- Escolher corretamente entre `GET`, `POST`, `PUT`, `PATCH` e `DELETE`.
- Ler **cabeçalhos** e **corpo** de uma requisição e de uma resposta.
- Interpretar um **código de status** por família (`1xx`, `2xx`, `3xx`, `4xx`, `5xx`) e explicar,
  um a um, os mais comuns.
- Definir **idempotência** e dizer quais verbos são idempotentes — e por que isso importa na hora
  de repetir uma requisição que falhou.
- Dizer o que é uma **API REST** e quais características fazem uma API ser considerada RESTful.
- Inspecionar uma API com o **navegador** e com **`curl.exe`** no PowerShell, antes de escrever
  uma linha de Dart.

## ✅ Pré-requisitos

- [Módulo 08 — Estado e Arquitetura](../08-estado-e-arquitetura/README.md) concluído.
- [04/02 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md): você precisa
  estar confortável com a ideia de "isto vai demorar e o resultado chega depois".
- Terminal aberto. Se `curl.exe` te assusta, releia
  [00/01 — O terminal sem medo](../00-git-e-terminal/01-o-terminal-sem-medo.md).
- Nenhum código Flutter ainda. Esta aula é de **entendimento**: você vai usar o navegador e o
  terminal. O primeiro `flutter create` deste módulo acontece na aula 3.

---

## 📖 Conceito

### O modelo cliente-servidor

Quase tudo o que você faz na internet segue o mesmo desenho:

- Um programa **pede** alguma coisa. Ele se chama **cliente**.
- Outro programa, rodando em outro computador, **responde**. Ele se chama **servidor**.

No seu aplicativo Flutter:

| Papel | Quem é |
|---|---|
| Cliente | O aplicativo `Foco` rodando no celular da pessoa |
| Servidor | O computador da JSONPlaceholder, em algum datacenter, ligado 24 h por dia |
| Meio de transporte | A internet (Wi-Fi ou dados móveis do aparelho) |
| Língua falada entre os dois | **HTTP** |

Três características desse modelo mudam a forma como você programa:

1. **O cliente sempre começa a conversa.** O servidor nunca "empurra" nada sozinho num HTTP
   comum: ele só responde a quem perguntou. (Existem mecanismos de *push*, como notificações e
   WebSocket, mas eles são outra história — no módulo 11 você vê notificações.)
2. **Cada requisição é independente.** O HTTP é *stateless* (*sem estado* — o servidor não
   lembra da requisição anterior). Se você precisa que o servidor saiba quem você é, precisa
   dizer isso **em toda requisição**, normalmente num cabeçalho. É exatamente por isso que a
   aula [08 — Autenticação e tokens](08-autenticacao-e-tokens.md) existe.
3. **Tudo pode falhar.** A rede é o único componente do seu app que está fora do seu controle.
   Ela cai, fica lenta, volta. Programar rede é programar para o fracasso; isso é o assunto da
   aula [06 — Timeout, retry e cancelamento](06-timeout-retry-cancelamento.md).

### O que é HTTP

**HTTP** (*HyperText Transfer Protocol* — "protocolo de transferência de hipertexto") é o
conjunto de regras que define **como** o cliente pergunta e **como** o servidor responde.

Um protocolo é um acordo de formato. Assim como um envelope de carta precisa ter destinatário
no lugar certo, uma requisição HTTP precisa ter método, caminho e cabeçalhos no lugar certo —
senão o servidor não entende.

**HTTPS** é o mesmo HTTP dentro de um túnel criptografado (TLS). O conteúdo continua sendo HTTP;
o que muda é que ninguém no caminho consegue ler nem alterar. **Todo app moderno usa HTTPS.**
Tanto o Android quanto o iOS bloqueiam HTTP puro por padrão — você vê isso na aula 3.

### A estrutura de uma requisição

Uma requisição HTTP tem quatro partes. Guarde esta lista, porque ela vira código literal na
aula 3:

```text
1. MÉTODO   — o verbo: GET, POST, PUT, PATCH, DELETE...
2. URL      — o endereço do recurso
3. CABEÇALHOS (headers) — pares nome: valor com informações sobre a requisição
4. CORPO (body) — os dados enviados (opcional; GET e DELETE normalmente não têm)
```

Na prática, o texto cru que viaja na rede se parece com isto:

```text
POST /todos HTTP/1.1
Host: jsonplaceholder.typicode.com
Content-Type: application/json; charset=utf-8
Accept: application/json
Content-Length: 62

{"title":"Revisar Álgebra","completed":false,"userId":1}
```

E a resposta, com as mesmas quatro partes (só que a primeira é o código de status):

```text
HTTP/1.1 201 Created
Content-Type: application/json; charset=utf-8
Location: https://jsonplaceholder.typicode.com/todos/201

{"title":"Revisar Álgebra","completed":false,"userId":1,"id":201}
```

Você **não vai escrever esse texto à mão**. O pacote `http` monta isso para você. Mas quando
algo der errado, é esse texto que está acontecendo por baixo — e entender ele é a diferença
entre depurar e adivinhar.

### URL e URI, e todas as suas partes

**URI** (*Uniform Resource Identifier*) é o nome geral de "identificador de recurso".
**URL** (*Uniform Resource Locator*) é uma URI que, além de identificar, diz **onde** achar.
Na prática do dia a dia de app, você usa URL. Em Dart, a classe se chama `Uri` — por isso você
vai escrever `Uri.parse(...)`.

Dissecando uma URL completa:

```text
https://api.exemplo.com:443/v1/trilhas/42?ordem=nome&pagina=2#secao-3
└─┬──┘   └──────┬───────┘└┬┘└─────┬─────┘ └────────┬────────┘└──┬──┘
  │             │         │       │                │            │
esquema       host      porta   caminho       query string   fragmento
```

| Parte | Nome técnico | O que é | No exemplo |
|---|---|---|---|
| `https` | esquema (*scheme*) | O protocolo usado | `https` |
| `api.exemplo.com` | host / autoridade | O nome do servidor, traduzido em número de IP pelo DNS | `api.exemplo.com` |
| `443` | porta | O "número da sala" dentro do servidor. `80` é o padrão do HTTP e `443` o do HTTPS — por isso quase nunca aparece escrito | `443` |
| `/v1/trilhas/42` | caminho (*path*) | Qual recurso você quer. É aqui que aparece o `id` | `/v1/trilhas/42` |
| `ordem=nome&pagina=2` | *query string* | Parâmetros extras, depois de `?`, separados por `&`, no formato `chave=valor` | `ordem=nome`, `pagina=2` |
| `secao-3` | fragmento | Depois do `#`. **Nunca é enviado ao servidor** — serve ao navegador. Num app, é irrelevante | `secao-3` |

Duas consequências práticas:

- **A query string precisa ser codificada.** Espaços, acentos e `&` dentro de um valor quebram a
  URL. Em Dart, `Uri.https` e `Uri(queryParameters: ...)` fazem essa codificação para você.
  Escrever a URL concatenando strings é a origem de metade dos bugs de busca.
- **Caminho identifica, query string filtra.** `/trilhas/42` é *a trilha 42*.
  `/trilhas?autor=42` é *a lista de trilhas filtrada pelo autor 42*. São coisas diferentes.

### Os métodos (verbos) HTTP

O método diz **a intenção** da requisição. O servidor decide o que fazer com base nele.

| Método | Intenção | Tem corpo? | Seguro? | Idempotente? |
|---|---|---|---|---|
| `GET` | **Ler** um recurso. Não deve mudar nada no servidor | Não | ✅ Sim | ✅ Sim |
| `POST` | **Criar** um recurso novo | Sim | ❌ Não | ❌ Não |
| `PUT` | **Substituir** um recurso inteiro | Sim | ❌ Não | ✅ Sim |
| `PATCH` | **Alterar parcialmente** um recurso | Sim | ❌ Não | ⚠️ Depende |
| `DELETE` | **Apagar** um recurso | Não (normalmente) | ❌ Não | ✅ Sim |
| `HEAD` | Igual ao `GET`, mas o servidor devolve só os cabeçalhos | Não | ✅ Sim | ✅ Sim |
| `OPTIONS` | Perguntar o que o servidor aceita | Não | ✅ Sim | ✅ Sim |

**Seguro** (*safe*), aqui, tem um sentido técnico específico: o método **não altera** o estado do
servidor. `GET` é seguro; `POST` não é. Não confunda com "seguro" no sentido de segurança.

Um detalhe que costuma gerar confusão: nada **impede** um servidor mal escrito de apagar dados
num `GET`. O HTTP define a **convenção**, não a obrigação. Mas a convenção é levada a sério: os
navegadores, os caches e as bibliotecas assumem que `GET` não muda nada. Um `GET` que apaga
coisas vai ser apagado por um cache repetindo a chamada.

### Cabeçalhos

**Cabeçalhos** (*headers*) são pares `Nome: valor` que descrevem a requisição ou a resposta.
Os que você mais vai usar:

**Enviados pelo cliente (seu app):**

| Cabeçalho | Para que serve | Exemplo |
|---|---|---|
| `Content-Type` | Diz em que formato está o **corpo que você está enviando** | `application/json; charset=utf-8` |
| `Accept` | Diz em que formato você **quer** a resposta | `application/json` |
| `Authorization` | Prova quem você é. Assunto da aula 8 | `Bearer <seu-token>` |
| `User-Agent` | Identifica o programa que está pedindo | `Foco/1.0.0 (Android 14)` |
| `Accept-Language` | Idioma preferido da resposta | `pt-BR` |
| `If-None-Match` | "Só me mande se mudou". Usado com cache | `"a1b2c3"` |

**Devolvidos pelo servidor:**

| Cabeçalho | Para que serve |
|---|---|
| `Content-Type` | Formato do corpo que **veio**. É ele que diz se é JSON e qual é a codificação |
| `Content-Length` | Tamanho do corpo em bytes |
| `Location` | Em um `201 Created`, a URL do recurso recém-criado |
| `ETag` | Uma "impressão digital" da versão atual do recurso, para cache |
| `Retry-After` | Em um `429` ou `503`, quantos segundos esperar antes de tentar de novo |
| `Set-Cookie` | Cria um cookie (usado em web; em app, prefira token) |

> 🔴 **Detalhe que vai te morder na aula 3:** o `charset` dentro do `Content-Type` **não é
> decoração**. O pacote `http` do Dart usa esse valor para decidir como transformar bytes em
> texto. Se o servidor não declarar `charset=utf-8`, o `http` assume `latin1` e seus acentos
> viram lixo. A aula 3 mostra o sintoma e a correção.

### Corpo (body)

O **corpo** são os dados em si. Em API moderna, o corpo é quase sempre **JSON** — o assunto
inteiro da [aula 2](02-json.md).

- `GET` e `DELETE` normalmente **não têm corpo na requisição**, mas têm **na resposta**
  (o `GET` devolve os dados; o `DELETE` pode devolver um corpo vazio).
- `POST`, `PUT` e `PATCH` **têm corpo na requisição** — é ali que vão os dados que você quer
  gravar.

### Códigos de status

Toda resposta começa com um número de três dígitos. **O primeiro dígito é a família**, e ele
já te diz quem tem o problema:

| Família | Nome | Significado prático para você |
|---|---|---|
| `1xx` | Informativo | Raro em app. "Recebi, continue." |
| `2xx` | **Sucesso** | Deu certo. Siga em frente. |
| `3xx` | **Redirecionamento** | O recurso está em outro lugar, ou não mudou desde a última vez. |
| `4xx` | **Erro do cliente** | **O problema é seu.** Repetir igual não adianta. |
| `5xx` | **Erro do servidor** | **O problema é deles.** Repetir mais tarde pode adiantar. |

Essa divisão entre `4xx` e `5xx` é a regra que vai governar o seu código de *retry* na aula 6:
**repita `5xx`, não repita `4xx`.**

#### `2xx` — Sucesso

| Código | Nome | Quando aparece | O que fazer no app |
|---|---|---|---|
| `200` | OK | Resposta padrão de sucesso. `GET`, `PUT`, `PATCH` e `DELETE` bem-sucedidos | Ler o corpo e converter |
| `201` | Created | **Um recurso novo foi criado.** Resposta certa para `POST` | Ler o corpo (costuma trazer o objeto com `id`) e o cabeçalho `Location` |
| `202` | Accepted | "Recebi, vou processar depois" | Mostrar "em processamento", não "pronto" |
| `204` | No Content | Deu certo e **não há corpo**. Comum em `DELETE` | **Não chame `jsonDecode` no corpo vazio** — isso lança `FormatException` |

#### `3xx` — Redirecionamento

| Código | Nome | Quando aparece | O que fazer no app |
|---|---|---|---|
| `301` | Moved Permanently | O endereço mudou **para sempre** | Atualize a URL no seu código. O `http` do Dart segue redirecionamentos de `GET` automaticamente |
| `302` | Found | Mudou **temporariamente** | Seguir, mas não gravar o novo endereço |
| `304` | Not Modified | "Nada mudou desde a versão que você já tem" | Usar o cache local. **A resposta vem sem corpo** |
| `307`/`308` | Temporary/Permanent Redirect | Como `302`/`301`, mas **preservando o método e o corpo** | Seguir sem transformar `POST` em `GET` |

#### `4xx` — Erro do cliente (o problema é seu)

| Código | Nome | Causa típica | Mensagem que você mostra ao usuário |
|---|---|---|---|
| `400` | Bad Request | Você mandou JSON malformado, campo faltando, tipo errado | "Não foi possível enviar os dados. Confira os campos e tente de novo." |
| `401` | Unauthorized | **Você não se identificou**, ou o token expirou | "Sua sessão expirou. Entre novamente." (aula 8) |
| `403` | Forbidden | Você se identificou, mas **não tem permissão** para isso | "Você não tem permissão para acessar este conteúdo." |
| `404` | Not Found | O recurso não existe (ou o caminho está errado) | "Não encontramos esta trilha. Ela pode ter sido removida." |
| `405` | Method Not Allowed | O caminho existe, mas não aceita esse verbo (ex.: `DELETE` em `/trilhas`) | Erro de programação. Corrija o código |
| `408` | Request Timeout | O servidor cansou de esperar você terminar de enviar | "A conexão demorou demais. Tente novamente." |
| `409` | Conflict | Conflito de estado: e-mail já cadastrado, versão desatualizada | "Já existe um registro com esses dados." |
| `413` | Payload Too Large | Você enviou um arquivo grande demais | "O arquivo é grande demais. O limite é X MB." |
| `422` | Unprocessable Content | O JSON está bem formado, mas os **valores** não passam na validação | Mostrar o erro por campo, se o servidor disser qual |
| `429` | Too Many Requests | Você fez requisições demais em pouco tempo (*rate limit*) | "Muitas tentativas. Aguarde alguns instantes." Respeite o `Retry-After` |

**A diferença entre `401` e `403` cai em prova e em entrevista:** `401` é "não sei quem você é";
`403` é "sei quem você é e você não pode".

#### `5xx` — Erro do servidor (o problema é deles)

| Código | Nome | Causa típica | O que fazer |
|---|---|---|---|
| `500` | Internal Server Error | O código do servidor lançou uma exceção | Mostrar erro genérico; **pode** repetir uma vez |
| `501` | Not Implemented | O servidor não sabe fazer esse método | Não repetir. É bug de integração |
| `502` | Bad Gateway | Um servidor intermediário recebeu resposta inválida do servidor real | Repetir com backoff |
| `503` | Service Unavailable | Fora do ar, sobrecarregado ou em manutenção | Repetir com backoff, respeitando `Retry-After` |
| `504` | Gateway Timeout | O intermediário cansou de esperar o servidor real | Repetir com backoff |

> ⚠️ **Não existe código para "sem internet".** Se o celular está sem rede, você **não recebe
> status nenhum** — a requisição nem sai. O que acontece é uma exceção Dart
> (`SocketException`). Muita gente escreve `if (response.statusCode == 0)` esperando isso, e
> nunca funciona. A [aula 4](04-modelando-respostas-e-erros.md) trata desse caso.

### Idempotência

**Idempotente** é a operação que, repetida várias vezes com os mesmos dados, deixa o servidor no
**mesmo estado final** que deixaria se tivesse rodado uma vez só.

Compare:

| Operação | Rodar 1 vez | Rodar 3 vezes | Idempotente? |
|---|---|---|---|
| `GET /trilhas/42` | Lê a trilha 42 | Lê a trilha 42 três vezes. O servidor continua igual | ✅ Sim |
| `PUT /trilhas/42` com `{"titulo":"Álgebra"}` | O título vira "Álgebra" | O título vira "Álgebra" — três vezes o mesmo resultado | ✅ Sim |
| `DELETE /trilhas/42` | A trilha 42 some | A trilha 42 some; as outras duas chamadas dão `404`. **O estado final é o mesmo: não existe trilha 42** | ✅ Sim |
| `POST /trilhas` com `{"titulo":"Álgebra"}` | Cria **uma** trilha | Cria **três** trilhas | ❌ Não |
| `PATCH /trilhas/42` com `{"minutos": 30}` | Minutos = 30 | Minutos = 30 | ✅ Sim (neste caso) |
| `PATCH /trilhas/42` com `{"incrementarMinutos": 30}` | Minutos + 30 | Minutos + 90 | ❌ Não |

Repare no `PATCH`: ele **pode** ser idempotente, dependendo do que a alteração faz. Por isso a
tabela de verbos diz "⚠️ Depende". Se a alteração é "defina o valor para X", é idempotente. Se é
"some X ao valor atual", não é.

**Por que isso importa tanto?** Porque a rede mente. Imagine: você envia um `POST` para criar uma
trilha, o servidor cria e responde `201` — mas a resposta se perde no caminho de volta. Do seu
lado, parece que falhou. Se o seu código repetir automaticamente, você cria **duas** trilhas.

Regra prática que você vai codificar na aula 6:

> **Repita automaticamente apenas operações idempotentes** (`GET`, `PUT`, `DELETE`) **e apenas
> quando o erro for `5xx` ou de rede.** Para `POST`, ou você não repete, ou o servidor precisa
> oferecer uma **chave de idempotência** (um identificador único que você manda no cabeçalho para
> o servidor reconhecer a repetição).

### O que é uma API REST

**REST** (*REpresentational State Transfer*) é um **estilo de arquitetura** proposto por Roy
Fielding em 2000. Não é um protocolo nem uma biblioteca: é um jeito de organizar uma API em cima
do HTTP. Uma API é chamada **RESTful** quando segue estas ideias:

1. **Tudo é um recurso, identificado por uma URL.** Uma trilha é `/trilhas/42`. A lista de
   trilhas é `/trilhas`. O recurso é um **substantivo**, não um verbo.
2. **O verbo está no método HTTP, não na URL.** Você escreve `DELETE /trilhas/42`, e **não**
   `GET /apagarTrilha?id=42`. Este é o erro mais comum de quem vem de outras tecnologias.
3. **Sem estado (*stateless*).** Cada requisição carrega tudo o que o servidor precisa. O
   servidor não guarda "em que passo você estava".
4. **Representações.** O mesmo recurso pode ser entregue em formatos diferentes (JSON, XML). Na
   prática moderna, é JSON.
5. **Respostas cacheáveis.** O servidor diz, por cabeçalho, se e por quanto tempo a resposta pode
   ser guardada.
6. **Interface uniforme.** Todos os recursos seguem o mesmo padrão, então quem já usou um sabe
   usar os outros.

Um conjunto REST típico, no vocabulário do nosso app:

| Método + caminho | O que faz | Status de sucesso |
|---|---|---|
| `GET /trilhas` | Lista todas as trilhas | `200` |
| `GET /trilhas/42` | Detalha a trilha 42 | `200` (ou `404`) |
| `POST /trilhas` | Cria uma trilha | `201` |
| `PUT /trilhas/42` | Substitui a trilha 42 inteira | `200` |
| `PATCH /trilhas/42` | Altera parte da trilha 42 | `200` |
| `DELETE /trilhas/42` | Apaga a trilha 42 | `204` |

> Na vida real, muita API se chama "REST" sem seguir tudo isso. Você vai encontrar
> `POST /getUsuario`, `GET /delete?id=1` e coisas piores. Saber o padrão serve para dois fins:
> escrever bem quando a decisão é sua, e reconhecer rápido quando a API alheia é esquisita.

---

## 💡 Analogia

Pense num **restaurante com balcão de pedidos**.

- Você (o **cliente**) vai até o balcão e faz um pedido. A cozinha (o **servidor**) prepara e
  entrega. A cozinha nunca traz comida para você sem pedido.
- O **método** é o tipo de pedido: "quero ver o cardápio" (`GET`), "quero fazer um pedido novo"
  (`POST`), "quero trocar o meu pedido inteiro por outro" (`PUT`), "quero só tirar a cebola"
  (`PATCH`), "quero cancelar" (`DELETE`).
- A **URL** é o que você aponta no cardápio: a página (`/trilhas`) ou o item específico
  (`/trilhas/42`).
- Os **cabeçalhos** são os bilhetes grudados na comanda: "sem glúten", "para viagem", "mesa 7".
- O **corpo** é a comanda preenchida.
- O **código de status** é a resposta do atendente: `200` "aqui está"; `201` "criei seu pedido,
  número 201"; `404` "esse item não existe no cardápio"; `401` "você precisa se identificar para
  pedir na conta"; `500` "o fogão pegou fogo".
- **Idempotência** é a diferença entre dizer três vezes "traga um copo d'água" (você fica com
  três copos — não idempotente, como o `POST`) e dizer três vezes "quero a mesa 7" (você continua
  na mesa 7 — idempotente, como o `PUT`).

A analogia quebra num ponto e é bom saber onde: no restaurante o atendente **lembra** de você
entre um pedido e outro. O HTTP **não lembra** — é como se, a cada pedido, fosse um atendente
novo que nunca te viu. Por isso você precisa se identificar toda vez.

---

## 🧪 Exemplo mínimo

Antes de qualquer código Dart, **veja a API com os próprios olhos**. Isso economiza horas de
depuração, porque separa "meu código está errado" de "a API responde diferente do que eu achava".

### 1. Pelo navegador

Abra o Chrome e cole:

```text
https://jsonplaceholder.typicode.com/todos/1
```

Você deve ver:

```json
{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```

O navegador só consegue fazer `GET` digitando na barra de endereço. Para ver os cabeçalhos e o
código de status, pressione **F12** (DevTools), vá na aba **Network**, e recarregue a página com
**F5**. Clique na linha da requisição: em **Headers** você vê *Status Code*, *Request Headers* e
*Response Headers*.

### 2. Pelo PowerShell com `curl.exe`

> 🪟 **Atenção, isto derruba muita gente no Windows.** No PowerShell, `curl` é um **apelido** para
> o comando `Invoke-WebRequest`, que tem parâmetros completamente diferentes. Se você digitar
> `curl -i https://...`, recebe um erro do tipo
> `Invoke-WebRequest : Não é possível localizar um parâmetro posicional`.
> **Sempre escreva `curl.exe`, com a extensão.** O `curl.exe` de verdade vem instalado no
> Windows 11 desde a fábrica, em `C:\Windows\System32\curl.exe`.

**🪟 Windows (PowerShell)**

```powershell
curl.exe -i https://jsonplaceholder.typicode.com/todos/1
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
curl -i https://jsonplaceholder.typicode.com/todos/1
```

A flag `-i` (de *include*) manda mostrar os cabeçalhos junto com o corpo. Saída real:

```text
HTTP/2 200
date: Sun, 14 Sep 2026 12:00:00 GMT
content-type: application/json; charset=utf-8
content-length: 83
cache-control: max-age=43200

{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```

Leia essa saída linha a linha: `200` é o status; `content-type` confirma que é JSON **em UTF-8**;
`cache-control: max-age=43200` diz que a resposta pode ser guardada por 43 200 segundos (12 h).

Outras flags que valem memorizar:

```powershell
curl.exe -s https://jsonplaceholder.typicode.com/posts        # -s = silencioso, sem barra de progresso
curl.exe -I https://jsonplaceholder.typicode.com/todos/1      # -I (maiúsculo) = só os cabeçalhos (faz um HEAD)
curl.exe -X DELETE https://jsonplaceholder.typicode.com/todos/1   # -X escolhe o método
```

### 3. Pelo PowerShell, do jeito nativo

Se preferir não usar `curl.exe`, o PowerShell tem um comando próprio que já converte o JSON em
objeto:

```powershell
Invoke-RestMethod -Uri https://jsonplaceholder.typicode.com/todos/1
```

Saída:

```text
userId    : 1
id        : 1
title     : delectus aut autem
completed : False
```

Para ver o código de status, use `Invoke-WebRequest` em vez de `Invoke-RestMethod`:

```powershell
(Invoke-WebRequest -Uri https://jsonplaceholder.typicode.com/todos/1).StatusCode
```

### 4. Experimentando a query string

A JSONPlaceholder aceita filtros por query string. Compare as três:

```powershell
curl.exe -s "https://jsonplaceholder.typicode.com/todos?_limit=3"
curl.exe -s "https://jsonplaceholder.typicode.com/todos?userId=2&_limit=3"
curl.exe -s "https://jsonplaceholder.typicode.com/posts/1/comments?_limit=2"
```

> 🪟 As aspas em volta da URL são **necessárias** no PowerShell quando há `&`, porque `&` é um
> caractere reservado do shell. Sem aspas, você recebe
> `O operador '&' é reservado para uso futuro.`

---

## 📱 Aplicando no Flutter

Nada do que você viu acima muda quando o cliente passa a ser um app Flutter — só o jeito de
escrever. Este é o mapa de tradução, e ele vale para o módulo inteiro:

| Conceito HTTP | Como aparece no Dart/Flutter |
|---|---|
| URL | `Uri.parse('https://...')` ou `Uri.https('host', '/caminho', {'chave': 'valor'})` |
| Método `GET` | `http.get(uri)` ou `cliente.get(uri)` |
| Método `POST` | `http.post(uri, headers: ..., body: ...)` |
| Cabeçalhos | `Map<String, String>` no parâmetro `headers:` |
| Corpo enviado | `String` no parâmetro `body:` (normalmente `jsonEncode(mapa)`) |
| Código de status | `response.statusCode` (um `int`) |
| Corpo recebido | `response.body` (uma `String`) ou `response.bodyBytes` (`Uint8List`) |
| Cabeçalhos recebidos | `response.headers` (um `Map<String, String>`) |
| "Sem internet" | Uma exceção `SocketException`, **não** um status |
| "Demorou demais" | `.timeout(...)` lançando `TimeoutException` |

E este é o esqueleto que você vai escrever na aula 3 — leia agora só para reconhecer as peças,
não para entender cada linha:

```dart
final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos/1');
final resposta = await http.get(uri).timeout(const Duration(seconds: 15));

if (resposta.statusCode == 200) {
  final mapa = jsonDecode(resposta.body) as Map<String, dynamic>;
  debugPrint(mapa['title'] as String);
}
```

Três linhas de HTTP e uma de JSON. Todo o resto do módulo é sobre fazer isso **de forma
confiável**.

> 💡 Use `Uri.https` sempre que a URL tiver parâmetros dinâmicos. Ele codifica acentos e espaços
> automaticamente:
>
> ```dart
> final uri = Uri.https(
>   'jsonplaceholder.typicode.com',
>   '/posts',
>   {'_limit': '20', 'q': 'álgebra linear'},
> );
> // vira: https://jsonplaceholder.typicode.com/posts?_limit=20&q=%C3%A1lgebra%20linear
> ```

---

## 💻 Código completo

Esta aula não tem projeto Flutter — ela tem um **roteiro de investigação** que você executa no
terminal. Salve-o para poder repetir contra qualquer API futura.

> **Arquivo:** `C:\Users\Usuário\estudos\explorar-api.ps1`
> **Como executar:** `powershell -ExecutionPolicy Bypass -File C:\Users\Usuário\estudos\explorar-api.ps1`

```powershell
# explorar-api.ps1
# Roteiro de investigação de uma API REST, antes de escrever qualquer código no app.
# Testado no PowerShell do Windows 11.

$base = "https://jsonplaceholder.typicode.com"

Write-Host "=== 1. A API responde? (só cabeçalhos, método HEAD) ===" -ForegroundColor Cyan
curl.exe -I "$base/todos/1"

Write-Host ""
Write-Host "=== 2. GET de um recurso único ===" -ForegroundColor Cyan
curl.exe -s -i "$base/todos/1"

Write-Host ""
Write-Host "=== 3. GET de uma coleção, limitada a 3 itens ===" -ForegroundColor Cyan
curl.exe -s "$base/todos?_limit=3"

Write-Host ""
Write-Host "=== 4. GET de um recurso que NAO existe (esperado: 404) ===" -ForegroundColor Cyan
curl.exe -s -o NUL -w "status=%{http_code}`n" "$base/todos/999999"

Write-Host ""
Write-Host "=== 5. POST criando um recurso (esperado: 201) ===" -ForegroundColor Cyan
curl.exe -s -i -X POST "$base/todos" `
  -H "Content-Type: application/json; charset=utf-8" `
  -d '{\"title\":\"Revisar Algebra\",\"completed\":false,\"userId\":1}'

Write-Host ""
Write-Host "=== 6. DELETE (esperado: 200 nesta API de testes) ===" -ForegroundColor Cyan
curl.exe -s -o NUL -w "status=%{http_code}`n" -X DELETE "$base/todos/1"

Write-Host ""
Write-Host "=== 7. Quanto tempo a API leva para responder? ===" -ForegroundColor Cyan
curl.exe -s -o NUL -w "conexao=%{time_connect}s  total=%{time_total}s`n" "$base/posts"
```

Saída esperada (os tempos variam conforme a sua conexão):

```text
=== 1. A API responde? (só cabeçalhos, método HEAD) ===
HTTP/2 200
content-type: application/json; charset=utf-8

=== 4. GET de um recurso que NAO existe (esperado: 404) ===
status=404

=== 5. POST criando um recurso (esperado: 201) ===
HTTP/2 201
content-type: application/json; charset=utf-8
{"title":"Revisar Algebra","completed":false,"userId":1,"id":201}

=== 6. DELETE (esperado: 200 nesta API de testes) ===
status=200

=== 7. Quanto tempo a API leva para responder? ===
conexao=0.089s  total=0.412s
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por que está aí |
|---|---|
| `$base = "https://..."` | Variável do PowerShell. Concentra a URL base num lugar só — a mesma ideia que você vai aplicar em `ambiente.dart` na aula 8 |
| `curl.exe -I` | `-I` maiúsculo manda um `HEAD`: pede **só os cabeçalhos**. É o jeito mais barato de perguntar "essa API está viva?" |
| `curl.exe -s -i` | `-s` esconde a barra de progresso; `-i` mostra os cabeçalhos junto com o corpo. Combinados, dão uma saída limpa e completa |
| `-o NUL -w "status=%{http_code}"` | `-o NUL` joga o corpo fora (o equivalente Windows de `/dev/null`); `-w` imprime só o que você pedir. Aqui, só o código de status |
| `` `n `` | No PowerShell, a crase é o caractere de escape. `` `n `` é a quebra de linha (o equivalente de `\n` em outras linguagens) |
| `` ` `` no fim da linha | A crase sozinha no fim da linha continua o comando na linha de baixo. É o equivalente PowerShell da barra invertida do bash |
| `-X POST` | Escolhe o método explicitamente |
| `-H "Content-Type: ..."` | Adiciona um cabeçalho. **Sem este cabeçalho, muitos servidores recusam o corpo com `400` ou `415`** |
| `-d '{...}'` | Envia o corpo. As aspas duplas internas estão escapadas com `\"` porque o argumento inteiro está entre aspas simples |
| `%{time_connect}` / `%{time_total}` | Variáveis do `curl`: tempo até conectar e tempo total. Servem para você escolher um valor honesto de `timeout` na aula 6 |

**Sobre o passo 4:** repare que a API devolveu `404`, e isso **não é um erro do seu script**. É o
servidor dizendo corretamente "esse recurso não existe". Reconhecer isso é metade do trabalho da
[aula 4](04-modelando-respostas-e-erros.md).

**Sobre o passo 6:** a JSONPlaceholder devolve `200` num `DELETE` (uma API mais rigorosa devolveria
`204`). Isso ilustra por que o seu código não deve testar `statusCode == 200` cravado, e sim uma
faixa: `statusCode >= 200 && statusCode < 300`.

---

## 🤖🍎 Android × iOS

Nesta aula o conceito é idêntico nas duas plataformas — HTTP é HTTP. Mas há **uma** diferença
real que já vale registrar, porque ela vai aparecer em código na aula 3:

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Permissão para usar a rede | **Precisa declarar** `<uses-permission android:name="android.permission.INTERNET"/>` no `AndroidManifest.xml`. Sem isso, o `release` falha | **Não existe permissão de internet.** O acesso à rede é liberado por padrão |
| HTTP sem TLS (`http://`) | Bloqueado por padrão desde o Android 9 (*cleartext traffic*) | Bloqueado por padrão pelo **ATS** (*App Transport Security*) |
| Como isso te afeta neste curso | Você adiciona uma linha no manifesto na aula 3 | Você não faz nada, porque a API do curso é HTTPS |

> 🪟 Você está no **Windows** e não tem Mac. Sobre esta aula: você consegue fazer **tudo**.
> `curl.exe`, navegador e PowerShell rodam normalmente, e o comportamento do HTTP não depende do
> sistema operacional. A parte de iOS que você **não** consegue fazer é rodar o app num
> iPhone/simulador — mas isso só entra no módulo 16, e a aula 3 explica exatamente o que muda.

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | Digitar `curl` em vez de `curl.exe` no PowerShell | `Invoke-WebRequest : Não é possível localizar um parâmetro posicional que aceite o argumento '-i'` | Sempre `curl.exe` 🪟 |
| 2 | Esquecer as aspas numa URL com `&` | `O operador '&' é reservado para uso futuro.` | `curl.exe -s "https://...?a=1&b=2"` |
| 3 | Testar `statusCode == 200` cravado | O app trata `201` e `204` como erro | Teste a faixa: `statusCode >= 200 && statusCode < 300` |
| 4 | Esperar um status para "sem internet" | O `catch` genérico engole tudo e você nunca sabe o que houve | Trate `SocketException` separadamente (aula 4) |
| 5 | Chamar `jsonDecode` na resposta de um `204` | `FormatException: Unexpected end of input (at character 1)` | Verifique `response.body.isEmpty` antes de decodificar |
| 6 | Colocar o verbo na URL (`/apagarTrilha?id=42`) | Funciona, mas quebra cache, quebra convenção e confunde quem lê | `DELETE /trilhas/42` |
| 7 | Concatenar a query string com `+` e acento | A URL chega quebrada no servidor, com `400` ou resultado vazio | Use `Uri.https(host, caminho, {parametros})` |
| 8 | Repetir automaticamente um `POST` que falhou | Registros duplicados no servidor | Só repita operações idempotentes (aula 6) |
| 9 | Confundir `401` com `403` | Você manda o usuário fazer login de novo quando o problema era permissão | `401` = não sei quem é você; `403` = sei e você não pode |
| 10 | Usar `http://` numa API própria | `ClientException: Connection closed` ou bloqueio silencioso no Android 9+ / iOS | Use sempre `https://` |

---

## 🛠️ Exercício guiado

**Objetivo:** mapear, sozinho, um recurso da API que o curso ainda não usou — `/users` — e
escrever a tabela REST dele.

**Passo 1.** Descubra quantos usuários existem e qual é o formato de um deles:

```powershell
curl.exe -s "https://jsonplaceholder.typicode.com/users?_limit=1"
```

**Passo 2.** Confirme o código de status e o `Content-Type`:

```powershell
curl.exe -s -o NUL -w "status=%{http_code} tipo=%{content_type}`n" "https://jsonplaceholder.typicode.com/users/1"
```

Resultado esperado:

```text
status=200 tipo=application/json; charset=utf-8
```

**Passo 3.** Provoque um erro de propósito e veja o status:

```powershell
curl.exe -s -o NUL -w "status=%{http_code}`n" "https://jsonplaceholder.typicode.com/users/99999"
```

Resultado esperado: `status=404`.

**Passo 4.** Teste um verbo que o recurso não aceita nesse caminho:

```powershell
curl.exe -s -o NUL -w "status=%{http_code}`n" -X DELETE "https://jsonplaceholder.typicode.com/users"
```

**Passo 5.** Agora escreva, num arquivo de texto seu, a tabela REST de `/users`, no modelo da
seção "O que é uma API REST":

| Método + caminho | O que faz | Status de sucesso esperado |
|---|---|---|
| `GET /users` | ... | ... |
| `GET /users/1` | ... | ... |
| `POST /users` | ... | ... |
| `PUT /users/1` | ... | ... |
| `DELETE /users/1` | ... | ... |

**Passo 6.** Responda por escrito, em uma frase cada:

1. Quais desses cinco são idempotentes?
2. Quais podem ser repetidos automaticamente se a rede cair no meio?
3. Qual deles você **nunca** repetiria sem uma chave de idempotência?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Desta aula saem os exercícios de **fixação** (famílias de status, partes da URL, escolha do verbo)
e de **leitura de código** (dado um trecho de resposta HTTP crua, dizer o que aconteceu).

---

## 🏆 Desafio opcional

Escreva um script PowerShell chamado `diagnosticar.ps1` que receba uma URL como argumento e
imprima um relatório de diagnóstico com:

- o código de status;
- o `Content-Type`;
- o tamanho da resposta em bytes;
- o tempo total;
- uma linha de veredito em português — `2xx` → "Deu certo"; `3xx` → "Redirecionado";
  `4xx` → "Erro no pedido (culpa do cliente)"; `5xx` → "Erro no servidor".

Dica de esqueleto:

```powershell
param([Parameter(Mandatory=$true)][string]$Url)

$status = curl.exe -s -o NUL -w "%{http_code}" $Url
$familia = [int]($status.Substring(0,1))

switch ($familia) {
  2 { Write-Host "Deu certo ($status)" -ForegroundColor Green }
  3 { Write-Host "Redirecionado ($status)" -ForegroundColor Yellow }
  4 { Write-Host "Erro no pedido - culpa do cliente ($status)" -ForegroundColor Red }
  5 { Write-Host "Erro no servidor ($status)" -ForegroundColor Magenta }
  default { Write-Host "Status inesperado: $status" }
}
```

Teste contra `https://jsonplaceholder.typicode.com/posts`, contra
`https://jsonplaceholder.typicode.com/nao-existe` e contra um domínio inexistente (para ver o
comportamento quando **nem status existe**).

---

## 📌 Resumo

- No modelo **cliente-servidor**, o seu app é o cliente: ele sempre começa a conversa, e o
  servidor só responde.
- **HTTP** é o protocolo de pergunta e resposta. Ele é **sem estado**: cada requisição precisa
  carregar tudo o que o servidor precisa saber.
- Uma requisição tem **método, URL, cabeçalhos e corpo**. Uma resposta tem **código de status,
  cabeçalhos e corpo**.
- A **URL** se divide em esquema, host, porta, caminho, *query string* e fragmento. Em Dart ela é
  a classe `Uri`, e `Uri.https` codifica os parâmetros por você.
- Os verbos principais: `GET` lê, `POST` cria, `PUT` substitui, `PATCH` altera em parte,
  `DELETE` apaga.
- As famílias de status: `2xx` sucesso, `3xx` redirecionamento, **`4xx` problema seu**,
  **`5xx` problema do servidor**. Essa divisão decide se vale a pena repetir.
- **Não existe status para "sem internet"** — isso vira uma exceção (`SocketException`).
- **Idempotência** é poder repetir sem mudar o resultado final. `GET`, `PUT` e `DELETE` são
  idempotentes; `POST` não é; `PATCH` depende do que ele faz.
- **REST** é um estilo: recursos como substantivos na URL, verbo no método HTTP, sem estado,
  interface uniforme.
- **Investigue a API com `curl.exe` antes de escrever Dart.** No PowerShell, sempre `curl.exe` —
  `curl` puro é apelido de `Invoke-WebRequest`. 🪟

---

## ☑️ Checklist de domínio

- [ ] Explico o modelo cliente-servidor e digo quem é quem no meu app.
- [ ] Digo por que o HTTP é "sem estado" e que consequência isso tem para autenticação.
- [ ] Separo uma URL em esquema, host, porta, caminho, query string e fragmento.
- [ ] Sei que o fragmento (`#`) nunca é enviado ao servidor.
- [ ] Escolho o verbo certo para ler, criar, substituir, alterar em parte e apagar.
- [ ] Digo de cor o que significam `200`, `201`, `204`, `301`, `304`, `400`, `401`, `403`, `404`,
      `409`, `422`, `429`, `500`, `502`, `503` e `504`.
- [ ] Sei a diferença entre `401` e `403` e dou um exemplo de cada.
- [ ] Testo a faixa `>= 200 && < 300` em vez de `== 200`.
- [ ] Defino idempotência e classifico os cinco verbos principais.
- [ ] Explico por que repetir um `POST` automaticamente é perigoso.
- [ ] Listo pelo menos quatro características de uma API REST.
- [ ] Rodo `curl.exe -i`, `-s`, `-I`, `-X` e `-w "%{http_code}"` sem consultar a aula. 🪟
- [ ] Sei por que preciso escrever `curl.exe` e não `curl` no PowerShell. 🪟
- [ ] Sei que no Android preciso declarar a permissão `INTERNET` e que no iOS não existe essa
      permissão. 🤖🍎

---

## 📚 Referências oficiais

- [MDN — An overview of HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview)
- [MDN — HTTP request methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
- [MDN — HTTP response status codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [MDN — HTTP headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers)
- [MDN — Idempotent](https://developer.mozilla.org/en-US/docs/Glossary/Idempotent)
- [MDN — What is a URL?](https://developer.mozilla.org/en-US/docs/Learn/Common_questions/Web_mechanics/What_is_a_URL)
- [Uri class — api.dart.dev](https://api.dart.dev/stable/dart-core/Uri-class.html)
- [JSONPlaceholder — Guide](https://jsonplaceholder.typicode.com/guide/)
- [curl — Manual page](https://curl.se/docs/manpage.html)
- [Invoke-RestMethod — Microsoft Learn](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — JSON](02-json.md) |
