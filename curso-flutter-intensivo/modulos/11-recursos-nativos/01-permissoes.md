# Aula 1 — Permissões

> **Módulo:** 11 - Recursos Nativos e Plataformas · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é uma **permissão** e o que é um **recurso protegido** do sistema operacional.
- Declarar uma permissão no `AndroidManifest.xml` 🤖 no lugar certo do arquivo e escrever o texto de
  justificativa no `Info.plist` 🍎 de um jeito que a Apple aceite.
- Pedir uma permissão em tempo de execução com `permission_handler ^13.0.2` e tratar os cinco
  estados: `granted`, `denied`, `permanentlyDenied`, `restricted`, `limited`.
- Levar o usuário aos ajustes do sistema com `openAppSettings()` quando não há mais o que pedir.
- Escolher **o momento certo** de pedir e explicar o porquê **antes** de o sistema perguntar.

## ✅ Pré-requisitos

- [README do Módulo 11](README.md): o projeto `foco_nativo` precisa estar criado.
- [Módulo 05 — Estrutura do projeto](../05-introducao-ao-flutter/02-estrutura-do-projeto.md) e
  [Módulo 04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md): você vai
  abrir as pastas `android/` e `ios/` e pedir permissão é uma operação assíncrona.
- 🤖 Um emulador ou aparelho Android. Sem ele, leia a aula inteira — o código não roda no Windows,
  porque `permission_handler` **não suporta Windows** (você vai confirmar isso sozinho na
  [aula 10](10-avaliando-pacotes.md)).

---

## 📖 Conceito

### O que é uma permissão

**Recurso protegido** é qualquer coisa do aparelho que possa expor o usuário: câmera, microfone,
localização, contatos, fotos, barra de notificações. O sistema operacional não deixa um aplicativo
tocar neles só porque está instalado. **Permissão** é a autorização formal para usar um recurso
protegido — e ela tem duas partes, cuja confusão é o erro número 1 de quem começa:

| | O que é | Quem lê | Quando acontece |
|---|---|---|---|
| **Declaração** | Uma linha escrita em um arquivo do projeto | O **sistema**, na instalação, e a **loja**, na publicação | Você escreve **uma vez**, no código |
| **Concessão** | O usuário tocar em "Permitir" numa caixa do sistema | O **usuário** | Em **tempo de execução**, com o app aberto |

Se você esquecer a declaração, o pedido em tempo de execução falha silenciosamente — o sistema nem
mostra a caixa. Se você fizer só a declaração e nunca pedir, a chamada à câmera lança uma exceção.

### 🤖 O modelo do Android

No Android você faz **as duas coisas**:

1. **Declarar** no arquivo `android/app/src/main/AndroidManifest.xml`. A tag `<uses-permission>` é
   filha direta de `<manifest>` e vem **antes** de `<application>`:

   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.CAMERA"/>
       <application
           android:label="foco_nativo"
           android:icon="@mipmap/ic_launcher">
   ```

   > Colocar `<uses-permission>` **dentro** de `<application>` é um erro comum e o build até passa
   > em alguns casos, mas a permissão não vale. O lugar certo é filho de `<manifest>`.

2. **Pedir em tempo de execução.** Desde o **Android 6.0 (API 23, de 2015)**, permissões
   *dangerous* (perigosas — câmera, microfone, localização, contatos) precisam ser aceitas com o app
   rodando. As *normal* (como `INTERNET`) são concedidas só pela declaração.

**Negação permanente.** Se o usuário negar e marcar "Não perguntar novamente" (ou, no Android 11+,
negar **duas vezes**), o sistema responde "negado" a qualquer novo pedido **sem mostrar a caixa**.
Seu código roda, o usuário não vê nada, e parece bug. Esse é o `permanentlyDenied`, e a única saída
é levar a pessoa até os ajustes do app.

### 🍎 O modelo do iOS

No iOS não existe declaração de permissão com nome técnico. Existe uma **chave de texto** no
`ios/Runner/Info.plist` explicando, **em linguagem de usuário**, por que o app quer aquilo:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da câmera para você anexar uma foto ao seu material de estudo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos da galeria para você escolher a imagem de capa da matéria.</string>
```

Esse texto **aparece dentro da caixa de diálogo** que o iOS mostra ao usuário. Três consequências:

1. **A Apple rejeita o app na revisão se o texto for genérico.** "Precisamos de acesso", "Para
   melhor experiência" ou texto em inglês num app em português são motivos reais de rejeição.
   Escreva o motivo concreto, voltado ao usuário final, no idioma do app.
2. **Se a chave não existir e o app tocar no recurso, o app fecha na hora** (*crash*), sem erro
   tratável. É comportamento intencional do iOS.
3. **O sistema pergunta uma única vez.** Se o usuário negar, o iOS **nunca mais** mostra aquela
   caixa. Do segundo pedido em diante, a resposta já é "negado permanentemente".

### Os estados de uma permissão

O pacote `permission_handler` devolve um `PermissionStatus`. Estes são os estados que importam:

| Estado | Significa | O que o seu app deve fazer |
|---|---|---|
| `granted` | Concedida | Use o recurso |
| `denied` | Negada agora, mas ainda dá para perguntar | Explique o valor e ofereça pedir de novo |
| `permanentlyDenied` | Não adianta mais pedir | Ofereça abrir os **ajustes do sistema** |
| `restricted` | 🍎 Bloqueada por controle parental / política do aparelho | Explique que não depende do usuário comum |
| `limited` | 🍎 Acesso **parcial** (o usuário liberou só algumas fotos) | Funcione com o que tem; ofereça ampliar |

Existe também `provisional` (🍎 notificações entregues em silêncio sem perguntar), que este curso
não usa — saiba que existe para não se assustar ao ler a documentação.

> ⚠️ Detalhe do iOS que confunde muita gente: como o sistema só pergunta uma vez, o
> `permission_handler` devolve `denied` apenas **antes** do primeiro pedido; depois de uma negativa,
> o status vira `permanentlyDenied`. No Android, `denied` pode aparecer muitas vezes.

### Pedir no momento certo

Regra que vale mais do que qualquer API: **não peça permissão na abertura do app.** Uma caixa de
sistema que aparece antes de a pessoa entender o produto é negada com muito mais frequência — e, no
iOS, uma negação é definitiva.

O padrão correto tem três passos: (1) o usuário **toca em algo** que precisa do recurso ("Adicionar
foto da matéria"); (2) o app mostra uma explicação **sua**, em um diálogo comum; (3) só então o app
chama `request()` e o **sistema** mostra a caixa oficial. O passo 2 tem nome — *pre-permission
prompt* (aviso pré-permissão) — é barato de fazer e muda bastante a taxa de aceitação.

---

## 💡 Analogia

Pense em um condomínio. A **declaração** no manifesto é o seu nome na lista de moradores autorizados
a usar a piscina — sem esse cadastro, nem adianta descer. A **concessão** é o porteiro abrindo o
portão: ele pode abrir, dizer "hoje não" (amanhã você pergunta de novo — `denied`) ou "seu nome foi
bloqueado, resolva na administração" (`permanentlyDenied` — insistir não adianta, é preciso ir ao
escritório, que é o `openAppSettings()`). E o `Info.plist` do iOS é o **bilhete que o porteiro lê em
voz alta** antes de decidir: bilhete mal escrito, cadastro devolvido — a revisão da App Store.

---

## 🧪 Exemplo mínimo

O menor código que faz sentido: pedir a câmera e reagir ao resultado.

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> pedirCamera() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}
```

`Permission.camera` é um objeto constante que representa a permissão. `.request()` devolve um
`Future<PermissionStatus>`: se o status já for `granted`, o sistema nem mostra a caixa e responde na
hora; se for `permanentlyDenied`, também responde na hora — negando. Para **consultar sem pedir**
(útil para desenhar a tela antes de incomodar o usuário), use `await Permission.camera.status`.

---

## 📱 Aplicando no Flutter

### Passo 1 — instalar o pacote

Na pasta `foco_nativo`:

```powershell
flutter pub add permission_handler
```

Confirme no `pubspec.yaml` que ficou `permission_handler: ^13.0.2` dentro de `dependencies:`. O
acento circunflexo `^` significa "esta versão ou qualquer maior que não quebre compatibilidade" —
ou seja, de `13.0.2` até (sem incluir) `14.0.0`.

### Passo 2 — 🤖 declarar no Android

Abra `foco_nativo/android/app/src/main/AndroidManifest.xml` e acrescente, no formato mostrado no
Conceito (filhas de `<manifest>`, antes de `<application>`), estas três linhas:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

> Nota importante: `android.permission.INTERNET` é adicionada automaticamente pelo Flutter nos
> builds de **debug**, mas precisa estar declarada no manifesto principal para o **release**. Quem
> esquece descobre só quando o APK assinado não carrega mais nada da API.

### Passo 3 — 🍎 escrever os textos no iOS

Abra `foco_nativo/ios/Runner/Info.plist` — sim, ele existe mesmo no Windows, porque o
`flutter create` gera a pasta `ios/` em qualquer sistema. Adicione antes do `</dict>` final as duas
chaves `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription` mostradas no Conceito.

> 🍎 **SÓ NO MAC.** Compilar e ver essa caixa aparecer exige macOS + Xcode; no Windows você escreve
> e versiona o arquivo agora, já correto para quem compilar. Veja
> [15-build-ios/01-por-que-exige-macos.md](../15-build-ios/01-por-que-exige-macos.md). Além disso, o
> `permission_handler` exige no iOS ligar macros (`PERMISSION_CAMERA=1` e afins) no `ios/Podfile`,
> para o app não carregar código de permissões que você **não** usa — a Apple rejeita apps assim.
> O passo está na página do pacote no pub.dev e só roda em um Mac.

### Passo 4 — envolver tudo em um serviço seu

Nunca espalhe `Permission.camera.request()` por dez telas: crie uma camada fina com vocabulário do
seu domínio. Quando o pacote mudar de API, você altera um arquivo só — e em testes você troca essa
classe por uma falsa.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/lib/core/plataforma/servico_permissoes.dart`
> **Como executar:** `flutter run -d <id-do-seu-android>` (veja os ids com `flutter devices`)

```dart
import 'package:permission_handler/permission_handler.dart';

/// Resultado de um pedido de permissão, traduzido para o vocabulário do app.
/// Usar um enum nosso isola o resto do app da biblioteca.
enum ResultadoPermissao {
  concedida,
  negada,
  negadaParaSempre,
  bloqueadaPeloSistema,
  parcial,
}

/// Camada fina sobre o `permission_handler`.
class ServicoPermissoes {
  const ServicoPermissoes();

  /// Consulta o estado atual SEM mostrar caixa nenhuma para o usuário.
  Future<ResultadoPermissao> consultar(Permission p) async => _traduzir(await p.status);

  /// Pede a permissão. O sistema só mostra a caixa se ainda fizer sentido mostrar.
  Future<ResultadoPermissao> pedir(Permission p) async => _traduzir(await p.request());

  /// Abre a tela de ajustes DO APP. Único caminho quando o estado é
  /// [ResultadoPermissao.negadaParaSempre]. Devolve `true` se a tela abriu —
  /// nunca se a permissão foi dada (isso você descobre reconsultando depois).
  Future<bool> abrirAjustes() => openAppSettings();

  ResultadoPermissao _traduzir(PermissionStatus status) {
    if (status.isGranted) return ResultadoPermissao.concedida;
    if (status.isLimited) return ResultadoPermissao.parcial;
    if (status.isPermanentlyDenied) return ResultadoPermissao.negadaParaSempre;
    if (status.isRestricted) return ResultadoPermissao.bloqueadaPeloSistema;
    return ResultadoPermissao.negada;
  }
}
```

E a tela que usa o serviço, com o aviso pré-permissão feito do jeito certo:

> **Arquivo:** `foco_nativo/lib/main.dart`
> **Como executar:** `flutter run -d <id-do-seu-android>`

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/plataforma/servico_permissoes.dart';

void main() => runApp(MaterialApp(
      title: 'Foco — laboratório nativo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const TelaPermissoes(),
    ));

class TelaPermissoes extends StatefulWidget {
  const TelaPermissoes({super.key});

  @override
  State<TelaPermissoes> createState() => _TelaPermissoesState();
}

class _TelaPermissoesState extends State<TelaPermissoes> {
  static const _servico = ServicoPermissoes();

  ResultadoPermissao? _estadoCamera;

  @override
  void initState() {
    super.initState();
    _atualizarEstado();
  }

  Future<void> _atualizarEstado() async {
    final estado = await _servico.consultar(Permission.camera);
    if (!mounted) return; // depois de todo await em um State: cheque mounted
    setState(() => _estadoCamera = estado);
  }

  /// Passo 1: explicação NOSSA. Passo 2: caixa DO SISTEMA.
  Future<void> _anexarFotoDaMateria() async {
    final querContinuar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anexar foto à matéria'),
        content: const Text(
          'Para fotografar a página do seu caderno, o Foco precisa da câmera.\n\n'
          'Você pode recusar e continuar usando o app normalmente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (querContinuar != true) return;

    final resultado = await _servico.pedir(Permission.camera);
    if (!mounted) return;
    setState(() => _estadoCamera = resultado);

    switch (resultado) {
      case ResultadoPermissao.concedida:
        _mostrar('Permissão concedida. Agora dá para abrir a câmera.');
      case ResultadoPermissao.parcial:
        _mostrar('Acesso parcial concedido. Dá para trabalhar com o que foi liberado.');
      case ResultadoPermissao.negada:
        _mostrar('Sem problema. Você pode liberar depois, quando quiser.');
      case ResultadoPermissao.bloqueadaPeloSistema:
        _mostrar('Este aparelho bloqueia a câmera por política de segurança.');
      case ResultadoPermissao.negadaParaSempre:
        _ofereceAjustes();
    }
  }

  /// Não adianta mais chamar request(): o caminho é a tela de ajustes do sistema.
  void _ofereceAjustes() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('O sistema não vai mais perguntar. Libere nos ajustes.'),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
          label: 'Abrir ajustes', onPressed: () => _servico.abrirAjustes()),
    ));
  }

  void _mostrar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  String get _descricaoEstado => switch (_estadoCamera) {
        null => 'consultando...',
        ResultadoPermissao.concedida => 'concedida ✅',
        ResultadoPermissao.parcial => 'parcial (só alguns itens)',
        ResultadoPermissao.negada => 'negada — dá para perguntar de novo',
        ResultadoPermissao.negadaParaSempre => 'negada para sempre — só nos ajustes',
        ResultadoPermissao.bloqueadaPeloSistema => 'bloqueada pelo aparelho',
      };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissões')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text('Câmera: $_descricaoEstado',
                style: Theme.of(context).textTheme.titleMedium),
            FilledButton.icon(
              onPressed: _anexarFotoDaMateria,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Anexar foto à matéria'),
            ),
            OutlinedButton.icon(
              onPressed: _atualizarEstado,
              icon: const Icon(Icons.refresh),
              label: const Text('Reconsultar estado'),
            ),
          ],
        ),
      ),
    );
  }
}
```

> `spacing: 16` em `Column` e `Row` existe desde o Flutter 3.27 e substitui a fileira de
> `SizedBox(height: 16)` entre os filhos. Menos widgets na árvore, menos ruído no código.

---

## 🔍 Explicando o código

**`enum ResultadoPermissao`.** Em vez de vazar o `PermissionStatus` do pacote para o app inteiro,
traduzimos para cinco casos com nome em português. Isso isola a dependência: trocar de pacote depois
vira uma edição de um arquivo só.

**`const ServicoPermissoes()`.** A classe não guarda estado, então o construtor pode ser `const` —
e `static const _servico` cria a instância em tempo de compilação, sem custo em execução.

**`permissao.status` × `permissao.request()`.** `status` **consulta** e nunca mostra caixa;
`request()` **pede** e mostra caixa se o sistema permitir. Consultar antes é o que deixa você
desenhar a tela ("liberar câmera" × "câmera liberada") sem incomodar ninguém.

**A ordem dos `if` em `_traduzir`.** `isLimited` vem antes de `isPermanentlyDenied` de propósito: no
iOS, acesso parcial à galeria não é negação — é um caso útil.

**`if (!mounted) return;`.** Entre o `await` e o `setState`, o usuário pode ter saído da tela. Sem
essa linha você recebe `setState() called after dispose()`. Regra fixa deste curso: depois de todo
`await` dentro de um `State`, cheque `mounted`.

**O `switch` sem `default`.** Como `ResultadoPermissao` é um `enum`, o Dart verifica que todos os
casos foram cobertos. Se amanhã você adicionar um sexto valor, o compilador aponta este `switch` —
colocar `default` desligaria essa proteção. Já `_descricaoEstado` usa `switch` **como expressão**
(`=> switch (x) { padrão => valor, ... }`), com o caso `null =>` cobrindo o estado inicial.

**`openAppSettings()` é função de topo**, não método de `Permission`. Abre os ajustes **do seu app**
e devolve `true` só se a tela abriu — nunca diz se o usuário liberou algo. Por isso existe o botão
"Reconsultar estado". O aviso usa `ScaffoldMessenger.of(context).showSnackBar`, a forma atual —
`Scaffold.of(context).showSnackBar` não existe mais.

---

## 🤖🍎 Android × iOS

| Assunto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onde declara | `AndroidManifest.xml`, `<uses-permission>` filho de `<manifest>` | `Info.plist`, chave `NS...UsageDescription` |
| O que você escreve | Um **nome técnico** (`android.permission.CAMERA`) | Um **texto para o usuário**, no idioma do app |
| Quantas vezes pergunta | Várias, até "não perguntar novamente" ou 2 negativas | **Uma única vez na vida do app** |
| Se faltar a declaração | O pedido falha e a caixa nem aparece | O app **fecha na hora** ao tocar no recurso |
| Texto genérico | Sem impacto (ninguém lê) | **Motivo real de rejeição na App Store** |
| Estado "parcial" | Não existe para câmera; existe para mídia no Android 14+ | `limited` — usuário escolhe **quais fotos** liberar |
| `restricted` | Praticamente não acontece | Comum: controle parental, aparelho da empresa |

Consequência prática de design: **no iOS você só tem uma bala.** É por isso que o aviso
pré-permissão importa mais lá, e por isso a tela deste exemplo pergunta "Continuar?" antes de
`request()`. Tabela completa em
[referencias/diferencas-android-ios.md](../../referencias/diferencas-android-ios.md).

---

## ⚠️ Erros comuns

**1. Pedir tudo no `initState` da primeira tela.**
O usuário abre o app e leva quatro caixas na cara. Taxa de negação altíssima e, no iOS, definitiva.

**2. Colocar `<uses-permission>` dentro de `<application>`.**
Erro silencioso: o build passa e a permissão não vale. O lugar é filho direto de `<manifest>`.

**3. Achar que `request()` sempre mostra a caixa.**
Se o estado for `permanentlyDenied`, `request()` retorna negando **sem** caixa nenhuma. Quem não
trata esse caso escreve um botão que "não faz nada".

**4. Esquecer a chave do `Info.plist` e testar só no Android.**
Funciona no Android e derruba o app no iPhone na primeira vez. Sintoma no log do Xcode:

```text
This app has crashed because it attempted to access privacy-sensitive data
without a usage description. The app's Info.plist must contain an
NSCameraUsageDescription key with a string value.
```

**5. Escrever "Precisamos de acesso à sua câmera" no `Info.plist`.**
Diz o quê, não diz o porquê. A Apple rejeita. Escreva o benefício concreto para o usuário.

**6. Esquecer `if (!mounted) return;` depois do `await`** — sintoma:
`setState() called after dispose(): _TelaPermissoesState#a1b2c(lifecycle state: defunct)`.

**7. Tentar rodar no Windows.** `permission_handler` não declara suporte a Windows, e o erro só
aparece em tempo de execução:

```text
MissingPluginException(No implementation found for method checkPermissionStatus
on channel flutter.baseflow.com/permissions/methods)
```

Esse erro tem duas causas e você precisa diferenciá-las: (a) o plugin não suporta a plataforma, ou
(b) você adicionou o plugin e não reiniciou o app do zero — *hot reload* não carrega código nativo
novo. Pare o app e rode `flutter run` de novo.

---

## 🛠️ Exercício guiado

**Objetivo:** transformar a tela de permissões em um painel com **três** permissões do Foco.

**Passo 1.** No `AndroidManifest.xml`, declare também
`<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>` (acesso às imagens no
Android 13+). No `Info.plist`, escreva um texto novo, seu, para a câmera — citando "anexar a foto
do caderno à matéria".

**Passo 2.** Crie um modelo para descrever cada linha do painel e a lista com os textos do domínio:

```dart
class ItemPermissao {
  const ItemPermissao({required this.titulo, required this.motivo, required this.permissao});

  final String titulo;
  final String motivo;
  final Permission permissao;
}

const itens = <ItemPermissao>[
  ItemPermissao(
      titulo: 'Câmera',
      motivo: 'Fotografar a página do caderno e anexar à matéria.',
      permissao: Permission.camera),
  ItemPermissao(
      titulo: 'Fotos',
      motivo: 'Escolher a imagem de capa de cada matéria.',
      permissao: Permission.photos),
  ItemPermissao(
      titulo: 'Notificações',
      motivo: 'Lembrar você do horário de estudo que você mesmo marcou.',
      permissao: Permission.notification),
];
```

**Passo 3.** Troque o corpo do `Scaffold` por um `ListView` sobre `itens`, com um `ListTile` por
permissão: `title` com o `titulo`, `subtitle` com o `motivo` **mais** o estado atual, e um
`FilledButton` no `trailing` que chama o mesmo fluxo de explicação + pedido.

**Passo 4.** Rode `flutter run` no seu Android, negue **duas vezes** a câmera e confirme que a
terceira tentativa cai em `negadaParaSempre` e mostra a ação "Abrir ajustes".

**Resultado esperado:** três linhas mostrando o estado atual em português, com a ação de ajustes
aparecendo apenas quando não há mais o que pedir.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Comece pelos exercícios de **Fixação** sobre os estados de permissão e pelo de **Correção de bugs**
que mostra um `AndroidManifest.xml` com a tag no lugar errado.

---

## 🏆 Desafio opcional

Extraia um contrato — `abstract interface class ContratoPermissoes` com os três métodos
`consultar`, `pedir` e `abrirAjustes` — e faça `ServicoPermissoes` implementá-lo. Depois escreva um
`ServicoPermissoesFake` que devolve estados definidos por você no construtor, sem tocar em plugin
nenhum, e um teste de widget que comprova: quando o fake devolve `negadaParaSempre`, a tela mostra
a ação "Abrir ajustes"; quando devolve `concedida`, não mostra. Esse teste roda **no Windows, sem
emulador nenhum** — é justamente o ganho de isolar o plugin atrás de um contrato. A técnica completa
está em [12 — Mocks e fakes](../12-testes-e-debug/07-mocks-e-fakes.md).

---

## 📌 Resumo

- **Recurso protegido** é o que o sistema guarda; **permissão** é a autorização para usá-lo.
- 🤖 Android exige **declarar** (`<uses-permission>` filho de `<manifest>`) **e pedir** em tempo de
  execução desde o Android 6; o iOS exige uma **chave de texto** no `Info.plist`, mostrada ao
  usuário — sem ela o app **fecha**, e com texto genérico a Apple **rejeita**.
- O iOS pergunta **uma única vez**; o Android permite insistir até a negação permanente.
- `permission_handler ^13.0.2` unifica as plataformas: `Permission.x.status` (consulta) e
  `Permission.x.request()` (pede). Estados: `granted`, `denied`, `permanentlyDenied`,
  `restricted`, `limited`.
- `permanentlyDenied` só se resolve com `openAppSettings()` — e reconsultando quando o usuário volta.
- Peça **depois** de uma ação do usuário e **depois** de uma explicação sua. Nunca na abertura.
- Isole o plugin atrás de um serviço seu: troca de pacote fica barata e o teste roda no Windows.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre declarar e conceder uma permissão, e sei onde a tag
      `<uses-permission>` deve ficar no `AndroidManifest.xml`.
- [ ] Escrevo um `NSCameraUsageDescription` que a Apple aceitaria e sei o que acontece se a chave
      estiver faltando.
- [ ] Diferencio `Permission.x.status` de `Permission.x.request()`.
- [ ] Trato os cinco estados sem usar `default` no `switch`.
- [ ] Levo o usuário aos ajustes com `openAppSettings()` e reconsulto o estado depois.
- [ ] Mostro uma explicação minha **antes** de chamar `request()`.
- [ ] Reconheço `MissingPluginException` e sei distinguir as duas causas.
- [ ] Rodei a tela em um Android e vi o estado mudar para `negadaParaSempre`.

---

## 📚 Referências oficiais

- [Platform permissions — docs.flutter.dev](https://docs.flutter.dev/platform-integration/platform-permissions)
- [permission_handler — pub.dev](https://pub.dev/packages/permission_handler)
- [Permissions on Android — developer.android.com](https://developer.android.com/guide/topics/permissions/overview)
- [Request runtime permissions — developer.android.com](https://developer.android.com/training/permissions/requesting)
- [Requesting access to protected resources — developer.apple.com](https://developer.apple.com/documentation/uikit/protecting-the-user-s-privacy)
- [App Store Review Guidelines — 5.1 Privacy](https://developer.apple.com/app-store/review/guidelines/#privacy)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do Módulo 11](README.md) | [README](README.md) | [Aula 2 — Câmera e galeria](02-camera-e-galeria.md) |
