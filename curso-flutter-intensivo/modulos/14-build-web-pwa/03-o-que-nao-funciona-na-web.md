# Aula 3 — O que não funciona na web

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que quase todo problema de web no Flutter aparece em **tempo de execução**, e não de
  compilação — e por que isso é a característica mais perigosa desta aula.
- Identificar as três categorias de incompatibilidade: **o que lança exceção**, **o que muda de
  comportamento em silêncio** e **o que simplesmente não existe**.
- Usar `kIsWeb` corretamente e reconhecer os casos em que ele **não basta**.
- Escrever **importações condicionais** para ter uma implementação por plataforma com a mesma
  interface.
- Entender **CORS**: o que é, por que só aparece na web, como ler o erro e o que dá (e não dá) para
  fazer no cliente.
- Auditar os cinco pacotes de plataforma do Foco e saber o que fazer com cada um.

## ✅ Pré-requisitos

- [Aula 2 — Como o Flutter compila para web](02-como-o-flutter-compila-para-web.md).
- [Módulo 11, aula 9 — Material × Cupertino](../11-recursos-nativos/09-material-x-cupertino.md) —
  a classe `Plataforma` que você escreveu lá é a peça central desta aula.
- [Módulo 09 — Consumo de API](../09-consumo-de-api/README.md) — a seção de CORS assume o
  `TrilhaApi` do Foco.

---

## 📖 Conceito

### A regra que organiza a aula inteira

```text
No Android, o que não funciona quebra o BUILD.
Na web, o que não funciona quebra o USUÁRIO.
```

Este é o ponto. Se você declarar uma permissão inválida no `AndroidManifest.xml`, o Gradle reclama e
o build falha — você descobre em 40 segundos, sentado na sua cadeira. Se você chamar
`Platform.isIOS` num app web, **o build passa**, o deploy passa, o Lighthouse passa, e a exceção
estoura na tela da primeira pessoa que abrir o link.

```text
Compilação  ✅ ─── Deploy  ✅ ─── Você testou a tela A  ✅ ─── Usuário abre a tela B  💥
                                                                UnsupportedError
```

Por isso esta aula vem **antes** de qualquer coisa prática do módulo: a lista do que quebra é a
única defesa que existe, já que o compilador não vai te avisar.

### As três categorias

| Categoria | Como se manifesta | Gravidade | Exemplos no Foco |
|---|---|---|---|
| **1. Lança exceção** | `UnsupportedError`, `MissingPluginException` | 💥 Tela quebrada | `Platform.isX`, `File`, `path_provider`, `sqflite` |
| **2. Muda em silêncio** | Funciona, com outra garantia | ⚠️ **A pior** | `flutter_secure_storage`, `connectivity_plus` |
| **3. Não existe** | Recurso ausente da plataforma | 📋 Requisito a repensar | Segundo plano, notificação local agendada |

> ⚠️ **A categoria 2 é a mais perigosa.** Uma exceção você vê. Um `flutter_secure_storage` que, na
> web, guarda o dado em `localStorage` em vez de no cofre do sistema operacional **não avisa nada** —
> e você só descobre a diferença quando alguém pergunta onde o token fica salvo.

### Categoria 1 — o que lança

#### `dart:io` existe, mas é uma casca vazia

Este é o detalhe que confunde todo mundo. Na web, `import 'dart:io'` **compila**. O `dart2js`
fornece uma versão da biblioteca em que praticamente tudo lança:

```dart
import 'dart:io';                 // ✅ compila na web

if (Platform.isIOS) { … }         // 💥 em runtime:
                                  // Unsupported operation: Platform._operatingSystem
```

```text
Unsupported operation: Platform._operatingSystem
  at Object.wrapException (main.dart.js:1234)
  at Object.Platform__operatingSystem (main.dart.js:5678)
```

| De `dart:io` | Na web |
|---|---|
| `Platform.isAndroid` / `.isIOS` / `.operatingSystem` | 💥 `UnsupportedError` |
| `File`, `Directory` | 💥 `UnsupportedError` |
| `Process` | 💥 `UnsupportedError` |
| `Socket`, `ServerSocket` | 💥 `UnsupportedError` |
| `HttpClient` | 💥 `UnsupportedError` — use `package:http` |
| `exit()` | 💥 `UnsupportedError` |

> 📌 **A correção é a classe `Plataforma`** que você escreveu no
> [Módulo 11, aula 9](../11-recursos-nativos/09-material-x-cupertino.md). Ela usa
> `Theme.of(context).platform` e `defaultTargetPlatform`, que são do `flutter/foundation` e
> **funcionam na web**. Se o Foco já usa `Plataforma.ehApple(context)` em todo lugar, metade desta
> categoria já está resolvida.

#### Plugins sem implementação web

Quando um plugin não tem código para a web, a chamada estoura assim:

```text
MissingPluginException(No implementation found for method
getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
```

A mensagem é boa: ela diz o **método** e o **canal**. O nome do canal identifica o plugin.

| Plugin do Foco | Web | O que fazer |
|---|---|---|
| `path_provider` | ❌ `MissingPluginException` | Não há pasta de documentos no navegador. Não chame na web. |
| `sqflite` | ❌ Não funciona | Trocar a *factory* — [Aula 4](04-banco-de-dados-na-web.md) |
| `image_picker` | ⚠️ Parcial | Funciona para escolher arquivo; sem câmera nativa |
| `permission_handler` | ❌ Sem sentido | Permissões na web são pedidas pela própria API do navegador |

### Categoria 2 — o que muda em silêncio

#### `flutter_secure_storage`

| | 🤖 Android | 🍎 iOS | 🌐 Web |
|---|---|---|---|
| Onde guarda | Keystore do sistema | Keychain | **`localStorage`**, com uma chave derivada |
| Protegido de outro app | ✅ | ✅ | ✅ (outra origem não lê) |
| Protegido de quem tem o aparelho | ✅ | ✅ | ⚠️ Menos |
| Protegido de XSS na sua própria página | ✅ | ✅ | ❌ **Não** |

> ⚠️ **Na web, "secure storage" significa menos do que no mobile.** O conteúdo fica na origem, e
> qualquer script que consiga rodar na sua página alcança. A conclusão prática, que o
> [Módulo 13, aula 6](../13-desempenho-e-seguranca/06-seguranca-mobile.md) já antecipa: **segredo de
> longa duração não mora no cliente**. Na web isso deixa de ser recomendação e vira restrição.

#### `connectivity_plus`

```dart
// No Android: distingue Wi-Fi, celular, ethernet, VPN…
// Na web: basicamente só "tem rede" × "não tem rede"
```

E há um detalhe pior, que vale nos três alvos mas morde mais na web: o navegador dizer `online`
significa que **existe uma interface de rede**, não que o seu servidor responde. Um Wi-Fi de
aeroporto com portal cativo reporta `online` e não deixa nada passar.

> 💡 **A defesa é a mesma dos outros módulos:** não confie no status de conectividade para decidir
> se a chamada vai dar certo. Faça a chamada, trate o erro e use o status só para **explicar** a
> falha ao usuário. É o que o `ClienteHttp` do Foco já faz com `timeout` e retry
> ([Módulo 09](../09-consumo-de-api/README.md)).

### Categoria 3 — CORS, o que mais surpreende

CORS não é um bug nem uma limitação do Flutter. É uma regra do **navegador**, e ela não existe no
Android nem no iOS. Por isso o mesmo código que busca as trilhas funciona no celular e falha no
Chrome.

**O que acontece:** quando o Foco, servido em `seu-usuario.github.io`, pede dados de
`api.exemplo.com`, o navegador considera isso uma requisição *cross-origin*. Ele faz a chamada, mas
**esconde a resposta de você** a menos que o servidor responda com um cabeçalho autorizando:

```text
Access-Control-Allow-Origin: *
```

```text
   Foco (github.io)                    api.exemplo.com
        │                                     │
        │──────── GET /trilhas ──────────────►│
        │                                     │
        │◄─── 200 OK + dados ─────────────────│
        │                                     │
        │  ⚠️ o navegador OLHA os cabeçalhos  │
        │     não achou Access-Control-*      │
        │     → joga a resposta fora          │
        │     → entrega um erro ao seu código │
```

O erro no console é característico:

```text
Access to XMLHttpRequest at 'https://api.exemplo.com/trilhas' from origin
'https://seu-usuario.github.io' has been blocked by CORS policy: No
'Access-Control-Allow-Origin' header is present on the requested resource.
```

E o seu código Dart recebe um `ClientException` sem detalhe útil — o navegador não conta o motivo
para a página, de propósito.

| Sintoma | Causa |
|---|---|
| Funciona no celular, falha no Chrome | É CORS. Sempre. |
| `ClientException: Failed to fetch` | O erro genérico que o CORS produz no Dart |
| A aba Network mostra `200` e mesmo assim falhou | Clássico: o servidor respondeu, o navegador descartou |

**O que dá para fazer:**

| Solução | Serve para | Observação |
|---|---|---|
| A API já mandar `Access-Control-Allow-Origin` | ✅ O caso do Foco | `jsonplaceholder.typicode.com` manda `*` |
| Você controla a API → adicione o cabeçalho | ✅ | Feito no servidor, não no Flutter |
| Um proxy seu, no mesmo domínio | ✅ | O navegador só vê uma origem |
| `--disable-web-security` no Chrome | ⚠️ **Só para depurar** | Nunca é solução; o usuário não vai fazer isso |
| Mudar algo no Dart | ❌ **Impossível** | Não existe flag no `package:http` que desative CORS |

> ⚠️ **Nenhuma configuração do lado do Flutter resolve CORS.** Se a API não coopera, as opções são
> proxy ou trocar de API. Tempo gasto procurando a flag mágica no `package:http` é tempo perdido —
> a decisão é do navegador, por segurança, e ela é deliberadamente inescapável.

> 💡 **O Foco não sofre com isso** porque a API de exemplo do curso
> (`https://jsonplaceholder.typicode.com`) responde `Access-Control-Allow-Origin: *`. Confira você
> mesmo na Aula guiada — vale ver o cabeçalho com os próprios olhos.

### `kIsWeb` e quando ele não basta

```dart
import 'package:flutter/foundation.dart';

if (kIsWeb) {
  // caminho web
} else {
  // caminho nativo
}
```

`kIsWeb` é uma **constante de compilação**. Em build web ela é `true`, e o compilador **elimina o
ramo `else` inteiro** por tree shaking. Isso resolve o problema de *executar* código errado.

**Mas ele não resolve o problema de importar.** Se um arquivo faz `import 'dart:io'` no topo, esse
import existe independentemente do `if`. Em `dart:io` isso passa (é a casca vazia). Em bibliotecas
web-only, como `package:web`, **não passa**: o build nativo falha na hora.

```dart
import 'package:web/web.dart';   // 💥 quebra o build Android/iOS

void salvar() {
  if (kIsWeb) {
    window.localStorage.setItem('k', 'v');   // não adianta o if
  }
}
```

A solução é **importação condicional**: três arquivos com a mesma interface, e o compilador escolhe
um.

```dart
export 'armazenamento_stub.dart'
    if (dart.library.io) 'armazenamento_io.dart'
    if (dart.library.js_interop) 'armazenamento_web.dart';
```

```text
                      ┌─ dart.library.io existe?        → armazenamento_io.dart
import condicional ───┤
                      └─ dart.library.js_interop existe? → armazenamento_web.dart
                         (nenhum dos dois)               → armazenamento_stub.dart
```

| Situação | Ferramenta |
|---|---|
| Decidir **comportamento** em runtime | `kIsWeb` |
| Decidir **visual** por plataforma | `Plataforma.ehApple(context)` (Módulo 11) |
| Decidir qual **arquivo compilar** | **Importação condicional** |
| Usar uma API só-web (`package:web`) | **Importação condicional**, obrigatoriamente |

---

## 💡 Analogia

Pense em levar o seu carro para outro país.

- **Categoria 1 — o que lança** é a tomada do carregador. O plugue simplesmente não entra. Você
  descobre na hora, dá raiva, e resolve com um adaptador. Ruim, mas honesto.
- **Categoria 2 — o que muda em silêncio** é o combustível. A bomba diz "gasolina", o bico entra, o
  carro anda. Só que é uma octanagem diferente, e o motor vai sofrer daqui a seis meses. **Nada
  avisou.** É o `flutter_secure_storage` guardando no `localStorage`: entra, funciona, e a garantia
  que você achava que tinha não está mais lá.
- **Categoria 3 — CORS** é a alfândega. Você tem a mercadoria, o caminhão chegou, a carga está no
  porto — e o fiscal não libera porque falta um carimbo que **só o remetente** pode dar. Não adianta
  argumentar, subornar o motorista ou trocar de caminhão: ou o remetente carimba, ou você despacha
  por outro porto (o proxy).
- **E o `kIsWeb` é a placa "dirija pela esquerda"**: te diz o que fazer, mas não adapta o volante do
  carro. Para isso serve a importação condicional — que é literalmente ter dois carros e pegar o
  certo na garagem.

---

## 🧪 Exemplo mínimo

Os três erros, lado a lado, com a mensagem exata que você vai encontrar.

**1. `dart:io` na web:**

```dart
import 'dart:io';
void main() => print(Platform.operatingSystem);
```

```text
Unsupported operation: Platform._operatingSystem
```

**2. Plugin sem web:**

```dart
final dir = await getApplicationDocumentsDirectory();
```

```text
MissingPluginException(No implementation found for method
getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
```

**3. CORS:**

```dart
final r = await http.get(Uri.parse('https://api-sem-cors.exemplo/dados'));
```

```text
// No console do navegador (F12):
Access to XMLHttpRequest at 'https://api-sem-cors.exemplo/dados' from origin
'http://localhost:8080' has been blocked by CORS policy

// No seu código Dart:
ClientException: Failed to fetch, uri=https://api-sem-cors.exemplo/dados
```

> 📌 **Decore o padrão de cada um.** `Unsupported operation` = `dart:io`.
> `MissingPluginException` = plugin sem web. `Failed to fetch` **sem nenhum detalhe** = quase sempre
> CORS, e a confirmação está no console do navegador, nunca no terminal do Flutter.

---

## 📱 Aplicando no Flutter

### A auditoria dos cinco pacotes do Foco

| Pacote | Categoria | Estado na web | Ação |
|---|---|---|---|
| `sqflite` | 1 — lança | ❌ Sem implementação web | [Aula 4](04-banco-de-dados-na-web.md) |
| `shared_preferences` | — | ✅ Usa `localStorage` | Nada |
| `http` | 3 — CORS | ⚠️ Depende da API | Confirmar cabeçalho |
| `connectivity_plus` | 2 — silêncio | ⚠️ Só online/offline | Ajustar expectativa |
| `flutter_secure_storage` | 2 — silêncio | ⚠️ `localStorage` | Nada sensível ali |
| `path_provider` | 1 — lança | ❌ `MissingPluginException` | Não chamar na web |

### Como saber, antes de quebrar, se um pacote suporta web

```powershell
flutter pub deps --style=compact
```

E, para cada pacote, abra a página dele no pub.dev: há um quadro de **plataformas** com
`Android · iOS · Linux · macOS · Web · Windows`. Se `Web` não estiver lá, o pacote não roda —
e nenhuma quantidade de `kIsWeb` conserta.

> 💡 **Isso é o mesmo critério do [Módulo 11, aula 10 — Avaliando pacotes](../11-recursos-nativos/10-avaliando-pacotes.md).**
> A diferença é que, agora que a web é o canal principal, o selo `Web` deixou de ser um detalhe
> simpático e virou requisito de escolha.

---

## 💻 Código completo

O padrão de importação condicional, aplicado a algo que o Foco realmente precisa: **exportar o
histórico de sessões para um arquivo**. No Android isso escreve em disco; na web, dispara um
download pelo navegador. Mesma interface, duas implementações.

> **Arquivo:** `lib/core/exportacao/exportador.dart` (novo)
> **Como executar:** `flutter run -d chrome` e `flutter run -d <android>` — o mesmo botão, dois caminhos

```dart
/// Ponto único de entrada. Quem usa não sabe em que plataforma está.
///
/// O compilador escolhe UM dos três arquivos abaixo e descarta os outros.
/// Se nenhuma das condições bater, fica o stub — que lança um erro claro
/// em vez de um erro confuso.
export 'exportador_stub.dart'
    if (dart.library.io) 'exportador_io.dart'
    if (dart.library.js_interop) 'exportador_web.dart';
```

> **Arquivo:** `lib/core/exportacao/exportador_stub.dart` (novo)

```dart
/// Contrato. Este arquivo nunca roda de verdade — ele existe para
/// definir a assinatura e para falhar de forma legível se o app for
/// compilado para um alvo que não previmos.
Future<void> exportarCsv(String nomeArquivo, String conteudo) {
  throw UnsupportedError(
    'exportarCsv não tem implementação para esta plataforma. '
    'Adicione um arquivo e a condição correspondente em exportador.dart.',
  );
}
```

> **Arquivo:** `lib/core/exportacao/exportador_io.dart` (novo)

```dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 🤖🍎 Android/iOS/desktop: grava no disco e devolve o caminho.
///
/// path_provider só é importado AQUI. O build web nunca compila este
/// arquivo, então o MissingPluginException da Aula 3 não acontece.
Future<void> exportarCsv(String nomeArquivo, String conteudo) async {
  final Directory pasta = await getApplicationDocumentsDirectory();
  final File arquivo = File('${pasta.path}${Platform.pathSeparator}$nomeArquivo');
  await arquivo.writeAsString(conteudo);
}
```

> **Arquivo:** `lib/core/exportacao/exportador_web.dart` (novo)

```dart
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// 🌐 Web: não existe "pasta de documentos". O equivalente honesto de
/// "salvar um arquivo" é disparar o download do navegador.
///
/// O truque é criar um Blob na memória, gerar uma URL temporária para
/// ele, clicar num link invisível e liberar a URL. É o padrão da
/// plataforma — não é gambiarra.
Future<void> exportarCsv(String nomeArquivo, String conteudo) async {
  final web.Blob blob = web.Blob(
    <JSAny>[conteudo.toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );

  final String url = web.URL.createObjectURL(blob);

  final web.HTMLAnchorElement link =
      web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = nomeArquivo;

  // Não precisa estar na árvore do DOM para o clique funcionar.
  link.click();

  // ⚠️ Sem isso, o Blob fica na memória até a aba fechar. Em um app
  // que exporta várias vezes, isso vaza de verdade.
  web.URL.revokeObjectURL(url);
}
```

E o uso, que é idêntico nos três alvos:

> **Arquivo:** `lib/features/estatisticas/presentation/botao_exportar.dart` (novo)

```dart
import 'package:flutter/material.dart';

import '../../../core/exportacao/exportador.dart';

class BotaoExportar extends StatelessWidget {
  const BotaoExportar({required this.csv, super.key});

  final String csv;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(Icons.download),
      label: const Text('Exportar sessões'),
      onPressed: () async {
        final ScaffoldMessengerState mensageiro = ScaffoldMessenger.of(context);
        try {
          await exportarCsv('sessoes.csv', csv);
          // Nenhum kIsWeb aqui. A escolha já foi feita em tempo de compilação.
          mensageiro.showSnackBar(
            const SnackBar(content: Text('Sessões exportadas.')),
          );
        } on UnsupportedError catch (e) {
          mensageiro.showSnackBar(SnackBar(content: Text(e.message ?? 'Sem suporte.')));
        }
      },
    );
  }
}
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `export … if (dart.library.io) …` | O compilador testa a existência da **biblioteca**, não da plataforma. É a única forma de trocar de arquivo em tempo de compilação. |
| O stub como primeiro da lista | É o *fallback*. Sem ele, um alvo futuro (ou um teste) falharia com erro incompreensível. |
| O stub **lançar** em vez de virar no-op | Um no-op silencioso esconde o problema; a mensagem diz exatamente o arquivo a criar. |
| `path_provider` importado **só** no `_io` | É o que impede o `MissingPluginException` na web: o plugin nem entra no bundle. |
| `dart:js_interop` como condição web | É a biblioteca moderna de interoperabilidade; `dart:html` está descontinuada. |
| `Blob` + `createObjectURL` + `click()` | O caminho oficial de "salvar arquivo" no navegador — não existe acesso direto ao disco. |
| `revokeObjectURL` depois do clique | Sem isso o `Blob` fica retido na memória até a aba fechar. Vazamento real em uso repetido. |
| Nenhum `kIsWeb` no widget | Quando a importação condicional resolve, o código de UI fica limpo — esse é o objetivo. |
| `ScaffoldMessenger.of` capturado **antes** do `await` | Evita usar `context` depois de um gap assíncrono, como no [Módulo 08](../08-estado-e-arquitetura/README.md). |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| `dart:io` | ⚠️ Compila, lança em runtime | ✅ | ✅ |
| `Platform.isX` | 💥 `UnsupportedError` | ✅ | ✅ |
| `Theme.of(context).platform` | ✅ | ✅ | ✅ |
| Sistema de arquivos | ❌ Só download/upload | ✅ | ✅ (sandbox) |
| CORS | ⚠️ **Existe** | ❌ Não existe | ❌ Não existe |
| Armazenamento seguro | ⚠️ `localStorage` | Keystore | Keychain |
| Descobrir o erro | ⚠️ **Em runtime, no usuário** | Em build | Em build |

> 📌 **A linha mais importante é a última.** No mobile, o build é o seu revisor. Na web, o revisor é
> o usuário — a menos que você tenha teste. É por isso que a [Aula 10](10-diagnostico-web.md) insiste
> em rodar a suíte de testes com `flutter test --platform chrome`: é o único jeito de mover a
> descoberta de volta para antes do deploy.

🪟 **No Windows**, esta aula funciona por completo.

---

## ⚠️ Erros comuns

### 1. Confiar que o build avisa

Na web, quase nada avisa em build.

**Correção:** auditoria de pacotes + teste em Chrome.

### 2. `Platform.isIOS` sem `kIsWeb`

`UnsupportedError` no primeiro usuário.

**Correção:** `Plataforma.ehApple(context)` do Módulo 11.

### 3. Achar que `kIsWeb` resolve import

Ele elimina o ramo, não o import.

**Correção:** importação condicional.

### 4. Importar `package:web` direto num arquivo compartilhado

Quebra o build Android/iOS.

**Correção:** isolar no arquivo `_web.dart`.

### 5. Procurar flag do `http` para desligar CORS

Não existe, por design.

**Correção:** cabeçalho no servidor, ou proxy.

### 6. Rodar o Chrome com `--disable-web-security` e achar que resolveu

Resolveu na sua máquina. O usuário continua bloqueado.

**Correção:** é ferramenta de depuração, nunca de entrega.

### 7. Ver `200` na aba Network e descartar CORS

O servidor respondeu; o navegador é que jogou fora.

**Correção:** leia o **Console**, não a Network.

### 8. Guardar token no `flutter_secure_storage` esperando cofre

Na web é `localStorage`.

**Correção:** token de curta duração, e nada crítico no cliente.

### 9. Decidir offline pelo `connectivity_plus`

`online` não significa "meu servidor responde".

**Correção:** tente, trate o erro, use o status só para explicar.

### 10. Chamar `path_provider` na web

`MissingPluginException`.

**Correção:** importação condicional, como no exportador.

### 11. Esquecer `revokeObjectURL`

Vazamento de memória em exportações repetidas.

**Correção:** revogue logo após o clique.

### 12. Usar `dart:html`

Descontinuada.

**Correção:** `package:web` + `dart:js_interop`.

---

## 🛠️ Exercício guiado

**Passo 1.** Retome a mensagem de erro que você anotou no exercício guiado da Aula 1. Em qual das
três categorias ela se encaixa?

**Passo 2.** Procure `import 'dart:io'` em todo o `lib/` do Foco:
`Select-String -Path lib\*.dart -Pattern "dart:io" -Recurse`. Quantos arquivos?

**Passo 3.** Para cada ocorrência, decida: dá para trocar por `Plataforma`? Ou precisa de importação
condicional?

**Passo 4.** Procure `Platform.is`. Alguma sobrou fora da classe `Plataforma`?

**Passo 5.** Abra o pub.dev de `connectivity_plus` e confirme o selo `Web` na lista de plataformas.

**Passo 6.** Rode o Foco no Chrome e vá até a tela de trilhas (a que consome a API). Ela carrega?

**Passo 7.** No DevTools → Network, clique na requisição da API e abra **Response Headers**. Existe
`access-control-allow-origin`? Qual o valor?

**Passo 8.** Troque a URL da API por `https://exemplo.invalido/trilhas` e rode de novo. Compare a
mensagem do **Console** com a do **terminal**. Qual das duas explica o problema?

**Passo 9.** Crie os quatro arquivos do exportador. Compile para web e para Android. Os dois passam?

**Passo 10.** Apague a condição `if (dart.library.io)` do `exportador.dart` e compile para Android.
Que erro aparece, e por quê ele é melhor do que um no-op silencioso?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Correção de bugs** (`Platform.isIOS` na web), **Diagnóstico** (o erro que só aparece no
Chrome) e **Aplicação** (importação condicional).

---

## 🏆 Desafio opcional

Faça a **auditoria completa de compatibilidade web** do Foco e entregue um documento acionável.

Requisitos:

- Liste **todas** as dependências do `pubspec.yaml`, não só as cinco desta aula.
- Para cada uma: selo `Web` no pub.dev (sim/não), categoria (1, 2 ou 3) e ação necessária.
- Percorra o `lib/` procurando `dart:io`, `Platform.`, `File(`, `Directory(` e
  `getApplicationDocumentsDirectory`. Registre arquivo e linha de cada ocorrência.
- Para cada ocorrência, classifique: **já seguro**, **trocar por `Plataforma`**, ou **precisa de
  importação condicional**.
- Escreva um teste que rode em Chrome (`flutter test --platform chrome`) e que **falhe** se alguém
  reintroduzir `Platform.isX` numa tela.
- Estime o esforço de cada correção em horas e ordene por **risco × esforço**.

Depois responda: quantas das ocorrências que você encontrou quebrariam **silenciosamente** (categoria
2) em vez de lançar? E por que essas deveriam estar no topo da sua lista, mesmo tendo risco aparente
menor?

---

## 📌 Resumo

- **No Android o que não funciona quebra o build; na web quebra o usuário.** A descoberta é em
  runtime, e essa é a característica que organiza toda a aula.
- Três categorias: **lança** (`dart:io`, plugins sem web), **muda em silêncio**
  (`flutter_secure_storage`, `connectivity_plus`) e **não existe** (segundo plano).
- A categoria **2 é a mais perigosa** justamente por não avisar nada.
- `dart:io` **compila** na web e lança `Unsupported operation` em runtime — a casca vazia do
  `dart2js`.
- `MissingPluginException` com nome de canal = plugin sem implementação web.
- **CORS é regra do navegador**, não do Flutter. Não existe flag no `package:http` que a desligue.
  Ou o servidor manda `Access-Control-Allow-Origin`, ou você usa proxy.
- Um `200` na aba Network **não descarta** CORS — a resposta chegou e o navegador a descartou. A
  explicação está no **Console**.
- `kIsWeb` decide **comportamento**; importação condicional decide **qual arquivo compila**. Um não
  substitui o outro.
- Para visual por plataforma, use a classe **`Plataforma`** do Módulo 11 — nunca `Platform.isX`.
- Na web, "salvar arquivo" é `Blob` + `createObjectURL` + clique + **`revokeObjectURL`**.
- Use `package:web` + `dart:js_interop`; `dart:html` está descontinuada.
- Confira o selo **`Web`** no pub.dev antes de adotar qualquer pacote — agora é requisito, não
  detalhe.

---

## ☑️ Checklist de domínio

- [ ] Explico por que os erros de web aparecem em runtime e o que isso muda na minha rotina.
- [ ] Classifico um problema nas três categorias.
- [ ] Reconheço `Unsupported operation`, `MissingPluginException` e `Failed to fetch` de imediato.
- [ ] Sei que `dart:io` compila na web e por quê.
- [ ] Explico CORS para alguém que nunca ouviu falar, sem usar a palavra "política".
- [ ] Sei onde ler a confirmação de um erro de CORS.
- [ ] Digo por que não existe solução de CORS no lado Flutter.
- [ ] Uso `kIsWeb` e sei o caso em que ele não basta.
- [ ] Escrevo uma importação condicional com stub, `_io` e `_web`.
- [ ] Não uso `Platform.isX` em lugar nenhum do app.
- [ ] Sei o que muda no `flutter_secure_storage` e no `connectivity_plus` na web.
- [ ] Confiro o selo `Web` no pub.dev antes de adicionar um pacote.

---

## 📚 Referências oficiais

- [Web FAQ — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/faq)
- [JavaScript interoperability — dart.dev](https://dart.dev/interop/js-interop)
- [package:web — pub.dev](https://pub.dev/packages/web)
- [Conditional imports — dart.dev](https://dart.dev/libraries/js-interop/package-web#conditional-imports)
- [Cross-Origin Resource Sharing (CORS) — MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [foundation library: kIsWeb — api.flutter.dev](https://api.flutter.dev/flutter/foundation/kIsWeb-constant.html)
- [Blob — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Blob)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Como o Flutter compila para web](02-como-o-flutter-compila-para-web.md) | [README](README.md) | [Banco de dados na web](04-banco-de-dados-na-web.md) |
