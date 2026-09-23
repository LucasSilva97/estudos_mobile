# Aula 3 — Primeiro GET

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Criar o projeto `foco_api` e adicionar o pacote **`http: ^1.6.0`**.
- Declarar a permissão **`android.permission.INTERNET`** no `AndroidManifest.xml` e explicar por
  que o *debug* funciona sem ela e o *release* não. 🤖
- Entender o que é **ATS** no iOS e por que a API do curso precisa ser HTTPS. 🍎
- Montar uma URL com `Uri.parse` e com `Uri.https`.
- Fazer uma requisição `GET` real a
  `https://jsonplaceholder.typicode.com/todos?_limit=20`.
- Ler `response.statusCode`, `response.body` e `response.bodyBytes`, e saber quando usar cada um.
- Converter o corpo em `List<Tarefa>` usando o `fromJson` da aula 2.
- Exibir o resultado numa `ListView.builder` com `FutureBuilder`, cobrindo carregando, erro e
  dados.
- Ver o aplicativo funcionando de ponta a ponta no emulador ou no desktop.

## ✅ Pré-requisitos

- [Aula 1 — HTTP e REST](01-http-e-rest.md) e [Aula 2 — JSON](02-json.md).
- [06/09 — Listas e rolagem](../06-widgets-e-layouts/09-listas-e-rolagem.md): `ListView.builder`
  e `ListTile`.
- [06/12 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md): carregando, vazio, erro.
- [04/02 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md).
- Ambiente pronto conforme
  [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md), com um destino para
  rodar: emulador Android, aparelho físico ou desktop Windows.
- **Internet funcionando na máquina.** A partir daqui o código sai de verdade para a rede.

---

## 📖 Conceito

### O pacote `http`

O Dart tem `dart:io` com `HttpClient`, que é de baixo nível e não funciona na web. O time do Dart
mantém o pacote **`http`**, que embrulha isso numa API mínima, funciona em todas as plataformas e
é o que o curso usa (veja a justificativa em
[05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md)).

A superfície que você precisa conhecer cabe numa tabela:

| Elemento | O que é |
|---|---|
| `http.get(Uri url, {Map<String, String>? headers})` | Faz um `GET` e devolve `Future<http.Response>` |
| `http.post`, `http.put`, `http.patch`, `http.delete` | Os outros verbos (aula 5) |
| `http.Client` | Um cliente reutilizável, que mantém a conexão aberta entre chamadas (aula 6) |
| `http.Response` | A resposta. Tem `statusCode`, `body`, `bodyBytes`, `headers`, `reasonPhrase` |
| `http.ClientException` | Exceção lançada pelo pacote quando a requisição não se completa |

### `statusCode`, `body` e `bodyBytes`

Depois do `await`, você tem um `http.Response`. Três propriedades importam agora:

```dart
final resposta = await http.get(uri);

resposta.statusCode;   // int   — 200, 404, 500...
resposta.body;         // String — o corpo já convertido em texto
resposta.bodyBytes;    // Uint8List — o corpo cru, em bytes
resposta.headers;      // Map<String, String> — cabeçalhos em minúsculas
```

**A diferença entre `body` e `bodyBytes` importa mais do que parece, e é a fonte de um bug
clássico com português.**

`body` não é mágica: ele pega `bodyBytes` e decodifica em texto usando a codificação declarada no
cabeçalho `Content-Type`. Se o servidor mandar:

```text
Content-Type: application/json; charset=utf-8
```

tudo certo — o pacote usa UTF-8. Mas se o servidor **não declarar o `charset`**, o pacote `http`
segue a especificação antiga do HTTP e assume **`latin1`** (também chamado ISO-8859-1). O
resultado é o famoso texto quebrado:

```text
esperado:  Álgebra Linear
recebido:  Ã¡lgebra Linear
```

Como o `Content-Type` é decisão do servidor e você não controla, a forma robusta é decodificar
você mesmo, sempre em UTF-8:

```dart
final texto = utf8.decode(resposta.bodyBytes);
```

A JSONPlaceholder **declara** `charset=utf-8` corretamente, então `resposta.body` funcionaria.
Mesmo assim, o curso adota `utf8.decode(resposta.bodyBytes)` como padrão, porque:

- funciona com qualquer servidor, declarando ou não;
- deixa explícito no código qual codificação você espera;
- custa uma linha.

> Se você precisar sobreviver a bytes inválidos (raro, mas acontece com APIs antigas), use
> `utf8.decode(resposta.bodyBytes, allowMalformed: true)`, que troca os bytes inválidos pelo
> caractere `�` em vez de lançar exceção.

### Verificar o status ANTES de decodificar

Um erro de iniciante é chamar `jsonDecode` direto no corpo. Quando a API devolve `404`, o corpo
costuma ser `{}` ou uma página HTML de erro — e aí você recebe um `FormatException` confuso, ou
pior, um `Map` vazio que vira uma lista vazia silenciosa.

O fluxo correto tem três perguntas, nesta ordem:

```text
1. A requisição chegou a acontecer?   -> se não, exceção (SocketException). Assunto da aula 4.
2. O statusCode está na faixa 2xx?    -> se não, erro do servidor ou do pedido.
3. O corpo é o JSON que eu esperava?  -> se não, FormatException.
```

Nesta aula você trata os casos 2 e 3 de forma simples, com `throw Exception(...)`. Na
[aula 4](04-modelando-respostas-e-erros.md) isso vira uma modelagem de erros de verdade.

### 🤖 A permissão de internet no Android

No Android, um aplicativo só pode usar a rede se **declarar** isso no manifesto. O manifesto é o
arquivo `android/app/src/main/AndroidManifest.xml` — o "documento de identidade" do app, onde o
sistema lê nome, ícone, telas e permissões.

Aqui mora uma armadilha que faz o aluno perder horas:

> 🔴 **O Flutter adiciona `android.permission.INTERNET` automaticamente nos builds de *debug*.**
> Ele faz isso para que o *hot reload* e o *debugger* funcionem, já que eles conversam pela rede.
> Resultado: o seu app funciona perfeitamente no emulador, você gera o APK de release, instala no
> celular e **todas as requisições falham**. O sintoma é uma `SocketException` com
> `Operation not permitted`.

A correção é uma linha, e ela precisa estar no manifesto **principal** (não só no de debug):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Ela é filha direta de `<manifest>` e vem **antes** de `<application>`. A ordem importa: o Android
exige que as permissões venham antes.

`INTERNET` é uma permissão **normal**, não perigosa: ela é concedida na instalação e **não gera
diálogo** para o usuário. Permissões perigosas (câmera, localização) são outra história, tratada
em [11/01 — Permissões](../11-recursos-nativos/01-permissoes.md).

### 🍎 ATS no iOS

O iOS não tem permissão de internet — o acesso à rede é liberado. O que ele tem é o **ATS**
(*App Transport Security*), uma trava de segurança ativa desde o iOS 9 que **bloqueia conexões
HTTP sem criptografia**.

Na prática:

| Endereço | 🍎 iOS com ATS |
|---|---|
| `https://jsonplaceholder.typicode.com/todos` | ✅ Funciona, sem configurar nada |
| `http://meu-servidor-de-testes.com/api` | ❌ Bloqueado |
| `http://localhost:3000` | ⚠️ Permitido (o ATS libera `localhost`) |

A mensagem de erro que aparece é:

```text
App Transport Security has blocked a cleartext HTTP (http://) resource load
since it is insecure. Temporary exceptions can be configured via your app's
Info.plist file.
```

Existe uma chave no `ios/Runner/Info.plist` para desligar isso (`NSAllowsArbitraryLoads`).
**Não use.** Três motivos:

1. A Apple exige justificativa na revisão e **rejeita** apps que desligam o ATS sem motivo real.
2. Você estaria transmitindo os dados dos seus usuários em texto aberto.
3. Certificado HTTPS gratuito existe há anos (Let's Encrypt). Não há desculpa técnica.

A recomendação do curso, que vale para as duas plataformas:

> **Use HTTPS sempre. Não configure exceção de ATS, não configure
> `android:usesCleartextTraffic="true"`.** Se a sua API de testes é HTTP, arrume a API — não o
> app. A API deste módulo já é HTTPS, então você não precisa mexer em nada no iOS.

> 🪟 **Você está no Windows e não tem Mac.** Sobre a parte iOS desta aula: você **consegue** ler
> e editar o `ios/Runner/Info.plist` (é um arquivo de texto XML, e o `flutter create` o gerou na
> sua máquina). O que você **não consegue** é compilar e rodar no simulador ou no iPhone — isso
> exige macOS com Xcode, e é o assunto de
> [15/01 — Por que exige macOS](../16-build-ios/01-por-que-exige-macos.md). A boa notícia desta
> aula específica: **não há nada a configurar no iOS**, porque a API é HTTPS. Então o seu código
> já está correto para iOS, e você pode provar isso lendo o `Info.plist` e confirmando que não há
> bloco `NSAppTransportSecurity`.

---

## 💡 Analogia

Fazer um `GET` é **pedir uma fotocópia pelo correio**.

Você escreve o endereço no envelope (a `Uri`), coloca na caixa e **vai fazer outra coisa** — não
fica parado na caixa de correio esperando. Isso é o `await`: o programa continua respondendo a
toques na tela enquanto a resposta não chega.

Quando o envelope de volta chega, três coisas podem ter acontecido:

- Chegou a fotocópia (`200` + corpo) — você lê.
- Chegou um bilhete "endereço não existe" (`404`) — você tem resposta, mas não o que queria.
- **Não chegou nada**, porque o carteiro não conseguiu sair da cidade (`SocketException`) — aqui
  não existe envelope nenhum para abrir, e é por isso que não existe "status 0".

A analogia quebra num ponto: no correio, você poderia esperar para sempre. Na rede, esperar para
sempre trava o aplicativo — por isso a [aula 6](06-timeout-retry-cancelamento.md) coloca um prazo
em todo envelope.

---

## 🧪 Exemplo mínimo

Antes de montar a tela, prove que a requisição funciona num programa de terminal de 15 linhas.
Assim, se der errado, você sabe que o problema é de rede — não de widget.

Crie o projeto do módulo, **uma única vez**:

```powershell
cd C:\Users\Usuário\source\repos\Estudos\estudos_mobile
flutter create --platforms=android,ios foco_api
cd foco_api
flutter pub add http
```

A saída de `flutter pub add http` deve terminar com algo como:

```text
Resolving dependencies...
+ http 1.6.0
Changed 1 dependency!
```

Confira o `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.6.0
```

> 🪟 Se o `flutter pub add` falhar com
> `Building with plugins requires symlink support. Please enable Developer Mode`,
> ative o Modo de Desenvolvedor: **Configurações → Sistema → Para desenvolvedores → Modo do
> desenvolvedor**. Ou rode `start ms-settings:developers`. Esse problema está detalhado em
> [referencias/erros-comuns.md](../../referencias/erros-comuns.md).

Agora o teste de terminal:

> **Arquivo:** `foco_api/bin/testar_get.dart`
> **Como executar:** `dart run bin/testar_get.dart` (de dentro de `foco_api`)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=3');

  print('Pedindo: $uri');
  final resposta = await http.get(uri);

  print('Status: ${resposta.statusCode}');
  print('Content-Type: ${resposta.headers['content-type']}');
  print('Tamanho: ${resposta.bodyBytes.length} bytes');

  if (resposta.statusCode == 200) {
    final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
    print('Itens: ${lista.length}');
    for (final item in lista) {
      final mapa = item as Map<String, dynamic>;
      print('  #${mapa['id']} ${mapa['title']}');
    }
  }
}
```

Saída real:

```text
Pedindo: https://jsonplaceholder.typicode.com/todos?_limit=3
Status: 200
Content-Type: application/json; charset=utf-8
Tamanho: 275 bytes
Itens: 3
  #1 delectus aut autem
  #2 quis ut nam facilis et officia qui
  #3 fugiat veniam minus
```

Se você viu isso, a rede funciona, o pacote está instalado e a API está no ar. **Só agora** vale
a pena montar a tela.

---

## 📱 Aplicando no Flutter

A estrutura de pastas que você cria nesta aula já é a do projeto final:

```text
foco_api/
├── bin/
│   └── testar_get.dart                       <- só laboratório, não vai para o app
└── lib/
    ├── main.dart
    └── features/
        └── tarefas/
            ├── domain/
            │   └── tarefa.dart               <- o modelo (aula 2)
            └── presentation/
                └── tarefas_screen.dart       <- a tela
```

Por que separar `domain` de `presentation` já numa aula tão simples? Porque o modelo `Tarefa`
não sabe nada de tela, e a tela não sabe nada de JSON. Essa separação é o que vai permitir, na
[aula 7](07-camada-de-dados-testavel.md), testar a conversão sem abrir nenhuma tela. A arquitetura
completa está em
[08/09 — Arquitetura feature-first](../08-estado-e-arquitetura/09-arquitetura-feature-first.md).

Para a tela, nesta aula você usa **`FutureBuilder`**: um widget que recebe um `Future` e
reconstrói a si mesmo quando o `Future` completa. Ele é a forma mais direta de ligar uma chamada
assíncrona a uma tela, e é o que a documentação oficial do Flutter usa no cookbook de rede.

Na [aula 9](09-api-com-riverpod.md) você troca o `FutureBuilder` por Riverpod. O motivo da troca
vai ficar evidente aqui mesmo, na seção de erros comuns: o `FutureBuilder` recria o `Future` a
cada `build` se você não tomar cuidado, e não compartilha o resultado entre telas.

---

## 💻 Código completo

### 1. O modelo

> **Arquivo:** `foco_api/lib/features/tarefas/domain/tarefa.dart`

```dart
/// Uma tarefa de estudo vinda da API pública.
///
/// Corresponde a um item de `GET https://jsonplaceholder.typicode.com/todos`.
class Tarefa {
  const Tarefa({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.concluida,
  });

  final int id;
  final int usuarioId;
  final String titulo;
  final bool concluida;

  /// Converte um objeto JSON já decodificado em uma [Tarefa].
  ///
  /// Lança [FormatException] se um campo obrigatório vier ausente ou com
  /// tipo errado. É melhor falhar aqui, com mensagem clara, do que deixar
  /// um valor inválido chegar à tela.
  factory Tarefa.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) {
      throw FormatException('Campo "id" ausente ou não numérico em: $json');
    }

    final usuarioId = json['userId'];
    if (usuarioId is! int) {
      throw FormatException('Campo "userId" ausente ou não numérico na tarefa $id');
    }

    final tituloBruto = json['title'] as String? ?? '';

    return Tarefa(
      id: id,
      usuarioId: usuarioId,
      titulo: tituloBruto.trim().isEmpty ? '(sem título)' : tituloBruto.trim(),
      // A API manda booleano, mas aceitamos 0/1 por robustez.
      concluida: json['completed'] == true || json['completed'] == 1,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': usuarioId,
        'title': titulo,
        'completed': concluida,
      };

  @override
  String toString() => 'Tarefa($id, $titulo, concluida: $concluida)';
}
```

### 2. A tela

> **Arquivo:** `foco_api/lib/features/tarefas/presentation/tarefas_screen.dart`

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/tarefa.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  /// Guardado em um campo, e NÃO criado dentro do build.
  /// Se fosse criado no build, cada reconstrução dispararia uma nova
  /// requisição — inclusive ao girar o aparelho ou abrir o teclado.
  late Future<List<Tarefa>> _futuroTarefas;

  @override
  void initState() {
    super.initState();
    _futuroTarefas = _buscarTarefas();
  }

  Future<List<Tarefa>> _buscarTarefas() async {
    // Uri.https codifica os parâmetros automaticamente.
    final uri = Uri.https(
      'jsonplaceholder.typicode.com',
      '/todos',
      <String, String>{'_limit': '20'},
    );

    final resposta = await http.get(
      uri,
      headers: const <String, String>{'Accept': 'application/json'},
    );

    // 1. O status é de sucesso?
    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(
        'O servidor respondeu ${resposta.statusCode}. '
        'Não foi possível carregar as tarefas.',
      );
    }

    // 2. Decodificar os bytes explicitamente em UTF-8.
    final texto = utf8.decode(resposta.bodyBytes);

    // 3. O corpo é mesmo uma lista?
    final decodificado = jsonDecode(texto);
    if (decodificado is! List) {
      throw const FormatException('Esperava uma lista de tarefas.');
    }

    // 4. Converter item a item.
    return decodificado
        .map((item) => Tarefa.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void _recarregar() {
    setState(() {
      _futuroTarefas = _buscarTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas de estudo'),
        actions: <Widget>[
          IconButton(
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: FutureBuilder<List<Tarefa>>(
        future: _futuroTarefas,
        builder: (context, snapshot) {
          // Estado 1: carregando.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          // Estado 2: erro.
          if (snapshot.hasError) {
            return _Erro(aoTentarDeNovo: _recarregar);
          }

          final tarefas = snapshot.data ?? const <Tarefa>[];

          // Estado 3: vazio.
          if (tarefas.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa encontrada.'));
          }

          // Estado 4: dados.
          return ListView.separated(
            itemCount: tarefas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, indice) {
              final tarefa = tarefas[indice];
              return ListTile(
                leading: Icon(
                  tarefa.concluida
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: tarefa.concluida
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(tarefa.titulo),
                subtitle: Text('Tarefa #${tarefa.id} · autor ${tarefa.usuarioId}'),
              );
            },
          );
        },
      ),
    );
  }
}

/// Estado de erro apresentado ao usuário final.
///
/// Repare que NÃO mostramos `snapshot.error.toString()`: o usuário não tem
/// nada a fazer com um texto técnico. A aula 4 aprofunda esse ponto.
class _Erro extends StatelessWidget {
  const _Erro({required this.aoTentarDeNovo});

  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 16),
            Text(
              'Não conseguimos carregar as tarefas.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: aoTentarDeNovo,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. O `main.dart`

> **Arquivo:** `foco_api/lib/main.dart`
> **Como executar:** `flutter run` (com um emulador ou aparelho conectado)

```dart
import 'package:flutter/material.dart';

import 'features/tarefas/presentation/tarefas_screen.dart';

void main() => runApp(const FocoApiApp());

class FocoApiApp extends StatelessWidget {
  const FocoApiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco — API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.dark,
        ),
      ),
      home: const TarefasScreen(),
    );
  }
}
```

### 4. 🤖 A permissão no Android

> **Arquivo:** `foco_api/android/app/src/main/AndroidManifest.xml`

Adicione a linha `<uses-permission ...>` como **primeira filha** de `<manifest>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="foco_api"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2"/>
    </application>
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

### 5. Rodando

**No emulador Android ou aparelho físico** (o destino principal do curso):

```powershell
flutter devices
flutter run
```

**No desktop Windows**, se você quiser testar sem emulador:

```powershell
flutter run -d windows
```

**Para conferir que não há nenhum aviso de análise estática:**

```powershell
flutter analyze
```

Esperado: `No issues found!`

---

## 🔍 Explicando o código

| Trecho | Por que está assim |
|---|---|
| `import 'package:http/http.dart' as http;` | O `as http` cria um **prefixo**. Sem ele, `get` e `Response` entrariam no escopo global e colidiriam com outros nomes. Este é o padrão oficial do pacote |
| `late Future<List<Tarefa>> _futuroTarefas;` | `late` diz "vou atribuir antes do primeiro uso". A atribuição acontece no `initState` |
| `_futuroTarefas = _buscarTarefas();` no `initState` | **O ponto mais importante da aula.** O `build` roda muitas vezes: ao girar o aparelho, ao abrir o teclado, ao mudar o tema. Se o `Future` nascesse dentro do `build`, cada uma dessas situações dispararia uma requisição nova |
| `Uri.https('host', '/caminho', {params})` | Monta a URL codificando os parâmetros. Compare com `Uri.parse('...?_limit=20')`: as duas funcionam aqui, mas `Uri.https` é a única segura quando o parâmetro tem acento ou espaço |
| `headers: const {'Accept': 'application/json'}` | Diz ao servidor que você quer JSON. Nem toda API respeita, mas é boa prática e algumas exigem |
| `if (resposta.statusCode < 200 \|\| resposta.statusCode >= 300)` | Testa a **faixa**, não `== 200`. Um `201` ou `204` também é sucesso |
| `utf8.decode(resposta.bodyBytes)` | Decodificação explícita, imune a servidor que esquece o `charset`. Evita "Ã¡lgebra" |
| `if (decodificado is! List)` | Quando a API dá erro, ela costuma devolver um **objeto** com a mensagem. Sem essa checagem, o erro seria `type '_Map' is not a subtype of type 'List'` |
| `FutureBuilder<List<Tarefa>>` | O `<List<Tarefa>>` explícito faz o `snapshot.data` ser `List<Tarefa>?`, e não `dynamic` |
| `snapshot.connectionState == ConnectionState.waiting` | A forma correta de detectar "carregando". Testar `snapshot.data == null` é errado: os dados podem ser nulos e o `Future` já ter terminado |
| `snapshot.data ?? const <Tarefa>[]` | `snapshot.data` é `List<Tarefa>?`. O `??` dá uma lista vazia const, sem alocação |
| `separatorBuilder: (_, _) => const Divider(height: 1)` | **Dois underscores simples separados**, e não `(_, __)`. Com `flutter_lints 6.0.0`, `(_, __)` dispara o lint `unnecessary_underscores` |
| `CircularProgressIndicator.adaptive()` | Mostra o indicador circular do Material no Android e o do Cupertino no iOS, automaticamente |
| `const Divider(height: 1)` | `const` em todo widget que puder. O Flutter reaproveita a instância em vez de recriar a cada quadro |
| `FilledButton.icon` | Botão do Material 3. `RaisedButton` e `FlatButton` **não existem mais** |
| `_Erro` como widget privado | O sublinhado no nome deixa a classe visível só neste arquivo. Widget de estado é reaproveitável dentro da tela, não fora |
| A classe `_Erro` **não** recebe a exceção | De propósito. O usuário final não deve ver `Exception: O servidor respondeu 500`. A aula 4 mostra como traduzir isso em mensagem útil |

---

## 🤖🍎 Android × iOS

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Permissão de rede | **Obrigatória** no manifesto: `<uses-permission android:name="android.permission.INTERNET"/>` | Não existe. Rede liberada por padrão |
| Onde declarar | `android/app/src/main/AndroidManifest.xml`, antes de `<application>` | — |
| Debug × release | O Flutter injeta a permissão no **debug** automaticamente. O **release** só tem o que estiver no manifesto | Igual nos dois |
| Sintoma se esquecer | `SocketException: Failed host lookup` ou `Operation not permitted` **só no APK de release** | — |
| HTTP sem TLS | Bloqueado desde o Android 9 (*cleartext traffic*) | Bloqueado pelo **ATS** desde o iOS 9 |
| Arquivo de configuração | `AndroidManifest.xml` (`android:usesCleartextTraffic`) | `ios/Runner/Info.plist` (`NSAppTransportSecurity`) |
| Recomendação do curso | **Não** habilite tráfego em texto aberto | **Não** desligue o ATS |
| Indicador de carregamento | Círculo do Material | Espiral do Cupertino — `CircularProgressIndicator.adaptive()` resolve os dois |

> 🪟 **O que você consegue e o que não consegue no Windows, nesta aula:**
>
> | Ação | Consegue? |
> |---|---|
> | Criar o projeto e adicionar o `http` | ✅ Sim |
> | Rodar `dart run bin/testar_get.dart` | ✅ Sim |
> | Rodar o app no emulador Android | ✅ Sim (com o Android SDK instalado) |
> | Rodar o app no desktop Windows | ✅ Sim (`flutter run -d windows`) |
> | Editar o `AndroidManifest.xml` | ✅ Sim |
> | Ler e editar o `ios/Runner/Info.plist` | ✅ Sim — o arquivo existe na sua máquina |
> | **Compilar e rodar no simulador iOS ou iPhone** | ❌ **Não.** Exige macOS + Xcode |
>
> A parte iOS desta aula não precisa de nenhuma edição, porque a API é HTTPS. Ou seja: o seu
> código já está correto para iOS, e a única coisa que falta é uma máquina para compilar.

---

## ⚠️ Erros comuns

| # | Erro | Mensagem / sintoma | Correção |
|---|---|---|---|
| 1 | Criar o `Future` dentro do `build` | O app fica piscando, a lista recarrega sozinha, o contador de requisições explode | Crie no `initState` e guarde num campo |
| 2 | Esquecer `<uses-permission INTERNET>` 🤖 | Funciona no debug, falha **só no release** com `SocketException` | Adicione no `AndroidManifest.xml` |
| 3 | Usar `http://` numa API própria | `ClientException` no Android 9+; `App Transport Security has blocked...` no iOS | Use `https://` |
| 4 | Testar `statusCode == 200` | `201` e `204` são tratados como erro | Teste a faixa `>= 200 && < 300` |
| 5 | `jsonDecode(resposta.body)` sem checar o status | `FormatException` confuso quando a resposta é HTML de erro | Cheque o status primeiro |
| 6 | Usar `resposta.body` com servidor sem `charset` | Acentos viram `Ã¡`, `Ã§`, `Ãµ` | `utf8.decode(resposta.bodyBytes)` |
| 7 | `snapshot.data!` sem checar | `Null check operator used on a null value` | `snapshot.data ?? const []` |
| 8 | Detectar carregando por `snapshot.data == null` | O spinner nunca some quando a lista vem vazia | `snapshot.connectionState == ConnectionState.waiting` |
| 9 | `(_, __)` no `separatorBuilder` | Aviso `unnecessary_underscores` no `flutter analyze` | `(_, _)` |
| 10 | Mostrar `snapshot.error.toString()` na tela | O usuário lê `Exception: Failed host lookup: 'jsonplaceholder...'` | Mensagem em português; detalhes só em log (aula 4) |
| 11 | Emulador Android sem internet | `SocketException: Failed host lookup` mesmo com a permissão | Confira a rede do host; reinicie o emulador com `flutter emulators --launch <id>` |
| 12 | Rodar `flutter run` sem destino | `No supported devices connected.` | `flutter devices` para listar; inicie um emulador ou use `-d windows` |

---

## 🛠️ Exercício guiado

**Objetivo:** provar que você controla cada parte da requisição, mudando uma coisa de cada vez.

**Passo 1 — mude a quantidade.** Em `_buscarTarefas`, troque `'_limit': '20'` por `'_limit': '5'`.
Rode e confirme que a lista tem 5 itens.

**Passo 2 — filtre por usuário.** Acrescente um parâmetro:

```dart
final uri = Uri.https(
  'jsonplaceholder.typicode.com',
  '/todos',
  <String, String>{'_limit': '20', 'userId': '2'},
);
```

Confirme, com `curl.exe`, que a URL gerada bate:

```powershell
curl.exe -s "https://jsonplaceholder.typicode.com/todos?_limit=20&userId=2"
```

Todos os itens devem ter `"userId": 2`.

**Passo 3 — force um erro de status.** Troque o caminho `/todos` por `/todos-que-nao-existem`.
Rode. Você deve ver a tela de erro. Confirme no terminal do `flutter run` que a exceção lançada
menciona `404`.

**Passo 4 — force um erro de formato.** Volte o caminho e troque `/todos` por `/todos/1`
(um objeto, não uma lista). Você deve ver a tela de erro de novo, agora vinda do
`if (decodificado is! List)`. Repare que **a tela é a mesma** para causas diferentes — e que isso
é um problema, resolvido na próxima aula.

**Passo 5 — force um erro de rede.** Desligue o Wi-Fi da máquina (ou ative o modo avião no
emulador) e toque em "Tentar de novo". No terminal você verá algo como:

```text
SocketException: Failed host lookup: 'jsonplaceholder.typicode.com'
(OS Error: No address associated with hostname, errno = 7)
```

**Passo 6 — escreva as conclusões.** Responda por escrito:

1. Quantas causas diferentes de falha você produziu?
2. Quantas mensagens diferentes o usuário viu?
3. Qual dessas falhas o usuário **consegue** resolver sozinho, e qual não?

Essas três respostas são exatamente a motivação da [aula 4](04-modelando-respostas-e-erros.md).

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Desta aula saem exercícios de **implementação** (buscar `/posts` e exibir numa lista),
de **correção de bugs** (um `FutureBuilder` com o `Future` criado no `build`) e de **aplicação**
(montar uma URL com `Uri.https` e vários parâmetros).

---

## 🏆 Desafio opcional

Acrescente à `TarefasScreen` um filtro local de três estados: **todas**, **pendentes** e
**concluídas**, usando um `SegmentedButton` do Material 3.

Requisitos:

- A filtragem acontece **em memória**, sem nova requisição — a lista já está toda carregada.
- O contador no `AppBar` mostra `concluídas / total`.
- Se o filtro deixar a lista vazia, mostre uma mensagem específica
  ("Nenhuma tarefa pendente. Bom trabalho!"), diferente do estado vazio geral.

Esqueleto do controle:

```dart
enum FiltroTarefa { todas, pendentes, concluidas }

FiltroTarefa _filtro = FiltroTarefa.todas;

List<Tarefa> _aplicarFiltro(List<Tarefa> tarefas) => switch (_filtro) {
      FiltroTarefa.todas => tarefas,
      FiltroTarefa.pendentes => tarefas.where((t) => !t.concluida).toList(),
      FiltroTarefa.concluidas => tarefas.where((t) => t.concluida).toList(),
    };
```

Repare que o `switch` de expressão sobre um `enum` é **exaustivo**: se você acrescentar um quarto
filtro e esquecer de tratá-lo, o `flutter analyze` acusa. Esse é o mesmo mecanismo das
`sealed class` da próxima aula.

---

## 📌 Resumo

- `flutter pub add http` instala o pacote oficial; importe com
  `import 'package:http/http.dart' as http;`.
- `http.get(uri)` devolve `Future<http.Response>`. `await` para esperar sem travar a tela.
- Verifique **primeiro** o `statusCode`, na faixa `>= 200 && < 300`; depois decodifique.
- Use `utf8.decode(resposta.bodyBytes)` em vez de `resposta.body`: o `body` assume `latin1`
  quando o servidor não declara `charset`, e seus acentos quebram.
- `Uri.https(host, caminho, parametros)` codifica a *query string* corretamente.
- 🤖 **Declare `android.permission.INTERNET` no manifesto.** O debug funciona sem ela; o release
  não.
- 🍎 O iOS não tem permissão de internet, mas tem **ATS**, que bloqueia `http://`. Não desligue —
  use HTTPS.
- No `FutureBuilder`, **crie o `Future` no `initState`**, nunca no `build`.
- A tela precisa cobrir quatro estados: carregando, erro, vazio e dados.
- Nunca mostre o texto da exceção ao usuário final.

---

## ☑️ Checklist de domínio

- [ ] Crio um projeto e adiciono o `http ^1.6.0` sem consultar a aula.
- [ ] Escrevo `import 'package:http/http.dart' as http;` e explico o `as http`.
- [ ] Monto uma URL com `Uri.https` incluindo *query string*.
- [ ] Verifico a faixa `2xx` antes de decodificar.
- [ ] Explico a diferença entre `resposta.body` e `resposta.bodyBytes` e por que uso o segundo.
- [ ] Converto o corpo em `List<Tarefa>` com `map` + `fromJson` + `toList`.
- [ ] Sei por que o `Future` vai no `initState` e não no `build`.
- [ ] Trato os quatro estados do `FutureBuilder`.
- [ ] Declaro a permissão `INTERNET` no `AndroidManifest.xml` e digo por que o debug não precisa
      dela. 🤖
- [ ] Explico o que é ATS e por que não devo desligá-lo. 🍎
- [ ] Sei o que consigo e o que não consigo fazer para iOS estando no Windows. 🪟
- [ ] `flutter analyze` termina com `No issues found!` no meu projeto.
- [ ] O app roda e mostra as 20 tarefas.

---

## 📚 Referências oficiais

- [Fetch data from the internet — docs.flutter.dev](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [http package — pub.dev](https://pub.dev/packages/http)
- [http library — pub.dev API](https://pub.dev/documentation/http/latest/http/http-library.html)
- [FutureBuilder class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
- [ListView.separated — api.flutter.dev](https://api.flutter.dev/flutter/widgets/ListView/ListView.separated.html)
- [Uri class — api.dart.dev](https://api.dart.dev/stable/dart-core/Uri-class.html)
- [utf8 constant — api.dart.dev](https://api.dart.dev/stable/dart-convert/utf8-constant.html)
- [Android — App Manifest permissions](https://developer.android.com/guide/topics/manifest/uses-permission-element)
- [Apple — Preventing Insecure Network Connections (ATS)](https://developer.apple.com/documentation/security/preventing-insecure-network-connections)
- [Adding assets and permissions — docs.flutter.dev](https://docs.flutter.dev/platform-integration/android/platform-views)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — JSON](02-json.md) | [README](README.md) | [Aula 4 — Modelando respostas e erros](04-modelando-respostas-e-erros.md) |
