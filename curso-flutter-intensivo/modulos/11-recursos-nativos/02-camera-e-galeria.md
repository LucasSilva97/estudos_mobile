# Aula 2 — Câmera e galeria

> **Módulo:** 11 - Recursos Nativos e Plataformas · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Usar `image_picker ^1.2.3` para tirar foto e para escolher imagem da galeria.
- Entender o que é um `XFile` e por que o pacote não devolve um `File` direto.
- Reduzir o peso da imagem na origem com `imageQuality` e `maxWidth`.
- Tratar o caso mais frequente de todos: o usuário **cancelar** (o método devolve `null`).
- Exibir a imagem com `Image.file` e salvar uma cópia no diretório do app.
- Declarar as permissões certas em cada plataforma, com os textos exatos do `Info.plist` 🍎.
- Saber o que o 🤖 seletor de fotos do Android 13+ muda e o que o emulador **não** consegue simular.

## ✅ Pré-requisitos

- [Aula 1 — Permissões](01-permissoes.md): você vai pedir câmera e fotos de verdade.
- [Módulo 10 — Arquivos e path_provider](../10-persistencia-de-dados/03-arquivos-e-path-provider.md):
  a imagem precisa ir para uma pasta que pertença ao app.
- 🤖 Um emulador ou aparelho Android. `image_picker` no Windows existe, mas só abre um seletor de
  arquivos — não há câmera.

---

## 📖 Conceito

### O app não abre a câmera: ele **pede** que o sistema abra

Quando você toca em "tirar foto" em um app bem-feito, o que aparece não é uma câmera desenhada pelo
app. É a **câmera do sistema**, um aplicativo separado, que tira a foto, grava num arquivo temporário
e devolve o caminho para quem pediu. O mesmo vale para a galeria.

Esse desenho tem nome: **intent de captura** 🤖 / **picker do sistema** 🍎. As vantagens são grandes:

- O usuário usa a câmera que ele já conhece, com os recursos do fabricante.
- Seu app **não precisa** processar vídeo em tempo real, o que economiza bateria e código.
- Em muitos casos, **você nem precisa de permissão** — o app do sistema é que acessa o hardware.

O pacote `image_picker` é o plugin oficial do time Flutter para isso. Ele **não** é uma câmera
embutida. Se você precisar de pré-visualização dentro do app (um leitor de QR code, por exemplo),
o caminho é outro pacote — e a [aula 10](10-avaliando-pacotes.md) ensina a escolher.

### `XFile`: o arquivo que ainda não é um `File`

`pickImage` devolve um `XFile?` — não um `File`. `XFile` é uma abstração de arquivo que funciona
também na web, onde `dart:io` e a classe `File` **não existem**. Ele oferece:

| Membro | O que dá |
|---|---|
| `.path` | O caminho em disco (vazio/sintético na web) |
| `.name` | O nome do arquivo, com extensão |
| `.length()` | O tamanho em bytes (`Future<int>`) |
| `.readAsBytes()` | O conteúdo (`Future<Uint8List>`) — funciona em toda plataforma |
| `.saveTo(caminho)` | Copia o arquivo para onde você quiser |

Em app mobile, `File(xfile.path)` é seguro. Em código que também roda na web, use `readAsBytes()`.

### O arquivo devolvido é **temporário**

O `XFile` aponta para a pasta de cache do app. O sistema operacional pode apagar essa pasta a
qualquer momento — ao ficar sem espaço, ao reiniciar, ao usuário limpar o cache. Se você guardar
só esse caminho no banco, um dia a imagem some e o app mostra um retângulo cinza.

**Regra:** copie o arquivo para o diretório de documentos do app (`getApplicationDocumentsDirectory()`)
e guarde **esse** caminho.

### `imageQuality` e `maxWidth`: reduza na origem

Um celular moderno tira fotos de 12 MP, com 4 MB ou mais. Guardar isso para virar a capa de uma
matéria é desperdício de disco, de memória e, se um dia você subir para um servidor, de dados do
usuário.

```dart
await picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 85,  // 0–100: recompressão JPEG feita no lado nativo
  maxWidth: 1600,    // reduz mantendo a proporção
);
```

`imageQuality` só se aplica a JPEG (`maxWidth`/`maxHeight` valem para os formatos suportados).
Fazer isso **no pacote** é melhor do que carregar a imagem inteira em memória para redimensionar no
Dart: o trabalho acontece em código nativo, antes de o arquivo chegar até você.

### O usuário cancelar é o caso normal

`pickImage` devolve `Future<XFile?>`. O `?` não é decoração: **`null` significa que a pessoa saiu
sem escolher nada** — apertou voltar, fechou a câmera, mudou de ideia. Isso acontece o tempo todo.
Tratar `null` como erro e mostrar "Falha ao carregar imagem" é um bug clássico de iniciante.

---

## 💡 Analogia

Pedir uma foto ao sistema é como mandar alguém buscar um documento no cartório. Você não vai até lá
nem mexe nos arquivos: você entrega o pedido (`pickImage`), a pessoa vai, e volta com **um envelope**
(`XFile`) ou **de mãos vazias** (`null`, porque o cartório estava fechado ou ela desistiu).

E o envelope veio numa mesa de recepção que a faxina limpa toda noite — a pasta de cache. Se você
quer o documento amanhã, precisa arquivá-lo na **sua** gaveta (o diretório de documentos do app).

---

## 🧪 Exemplo mínimo

```dart
import 'package:image_picker/image_picker.dart';

Future<String?> tirarFoto() async {
  final picker = ImagePicker();
  final XFile? foto = await picker.pickImage(source: ImageSource.camera);
  if (foto == null) return null; // o usuário cancelou — não é erro
  return foto.path;
}
```

Trocar `ImageSource.camera` por `ImageSource.gallery` é a única diferença entre tirar e escolher.

---

## 📱 Aplicando no Flutter

### Passo 1 — instalar

Na pasta `foco_nativo`:

```powershell
flutter pub add image_picker
flutter pub add path_provider
flutter pub add path
```

O `pubspec.yaml` deve ficar com as versões do curso:

```yaml
dependencies:
  image_picker: ^1.2.3
  path_provider: ^2.1.6
  path: ^1.9.1
```

`path_provider` descobre as pastas oficiais do app em cada sistema; `path` monta caminhos de arquivo
sem você precisar saber se a barra é `/` ou `\`.

### Passo 2 — 🤖 permissões do Android

Abra `foco_nativo/android/app/src/main/AndroidManifest.xml` e garanta, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"
    android:minSdkVersion="33"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
```

Leia com atenção os atributos: `READ_MEDIA_IMAGES` só existe do **Android 13 (API 33)** para cima;
`READ_EXTERNAL_STORAGE` vale até o **Android 12 (API 32)**. Declarar as duas com essas faixas é o
jeito de suportar aparelhos antigos e novos sem pedir mais do que o necessário em cada um.

> 🤖 Se você usar **apenas** `ImageSource.gallery`, no Android 13+ **nenhuma permissão é
> necessária**: o sistema abre o **Photo Picker**, uma tela do próprio Android que devolve só a
> imagem escolhida. Por isso muitos apps modernos removeram `READ_MEDIA_IMAGES` — pedir permissão
> que não se usa piora a ficha de privacidade do app na loja.

### Passo 3 — 🍎 textos do Info.plist

Em `foco_nativo/ios/Runner/Info.plist`, antes do `</dict>` final:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da câmera para você anexar uma foto ao seu material de estudo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos da galeria para você escolher a imagem de capa da matéria.</string>
<key>NSMicrophoneUsageDescription</key>
<string>O microfone é usado apenas quando você grava um vídeo de revisão da matéria.</string>
```

> 🍎 A chave do microfone só é necessária se o app gravar **vídeo** (`pickVideo`). Se você não grava
> vídeo, **não** declare: a Apple questiona permissões sem uso, e cada chave a mais é uma linha a
> mais na sua Ficha de Privacidade (*Privacy Nutrition Label*) na App Store.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/lib/core/plataforma/servico_imagens.dart`
> **Como executar:** `flutter run -d <id-do-seu-android>` (ids com `flutter devices`)

```dart
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Escolher e guardar imagens de capa das matérias do Foco.
class ServicoImagens {
  ServicoImagens({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Abre a câmera do sistema. Devolve `null` se o usuário cancelar.
  Future<XFile?> tirarFoto() => _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
        preferredCameraDevice: CameraDevice.rear,
      );

  /// Abre o seletor de fotos do sistema. Devolve `null` se o usuário cancelar.
  Future<XFile?> escolherDaGaleria() => _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

  /// Copia o arquivo temporário para a pasta permanente do app.
  ///
  /// Devolve o caminho definitivo, que é o que deve ir para o banco.
  Future<String> guardarComoCapa(XFile origem, String idMateria) async {
    final pasta = await getApplicationDocumentsDirectory();
    final capas = Directory(p.join(pasta.path, 'capas'));
    if (!await capas.exists()) {
      await capas.create(recursive: true);
    }
    final extensao = p.extension(origem.name).toLowerCase();
    final destino = p.join(capas.path, 'materia_$idMateria$extensao');
    await origem.saveTo(destino);
    return destino;
  }

  /// Apaga a capa antiga, se existir. Chame ao trocar ou excluir a matéria.
  Future<void> removerCapa(String caminho) async {
    final arquivo = File(caminho);
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}
```

E a tela que usa o serviço:

> **Arquivo:** `foco_nativo/lib/features/materias/presentation/capa_materia_screen.dart`
> **Como executar:** aponte `home:` do `MaterialApp` para `CapaMateriaScreen` e rode `flutter run`

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/plataforma/servico_imagens.dart';

class CapaMateriaScreen extends StatefulWidget {
  const CapaMateriaScreen({super.key, this.idMateria = 'demo'});

  final String idMateria;

  @override
  State<CapaMateriaScreen> createState() => _CapaMateriaScreenState();
}

class _CapaMateriaScreenState extends State<CapaMateriaScreen> {
  final _servico = ServicoImagens();

  String? _caminhoCapa;
  bool _ocupado = false;

  Future<void> _selecionar(Future<XFile?> Function() escolher) async {
    setState(() => _ocupado = true);
    try {
      final imagem = await escolher();
      if (imagem == null) {
        if (!mounted) return;
        _avisar('Nenhuma imagem escolhida.'); // cancelar NÃO é erro
        return;
      }
      final definitivo = await _servico.guardarComoCapa(imagem, widget.idMateria);
      if (!mounted) return;
      setState(() => _caminhoCapa = definitivo);
    } on Exception catch (erro) {
      if (!mounted) return;
      _avisar('Não foi possível usar a imagem: $erro');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _avisar(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capa da matéria')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 16,
          children: [
            Expanded(
              child: _caminhoCapa == null
                  ? const Center(child: Text('Nenhuma capa escolhida ainda.'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_caminhoCapa!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        // O arquivo pode ter sumido (cache limpo, usuário apagou).
                        errorBuilder: (context, erro, pilha) =>
                            const Center(child: Text('Imagem indisponível.')),
                      ),
                    ),
            ),
            if (_ocupado) const LinearProgressIndicator(),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        _ocupado ? null : () => _selecionar(_servico.tirarFoto),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Tirar foto'),
                  ),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _ocupado
                        ? null
                        : () => _selecionar(_servico.escolherDaGaleria),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeria'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔍 Explicando o código

**`ServicoImagens({ImagePicker? picker})`.** O construtor aceita um `ImagePicker` de fora. Em
produção ninguém passa nada e a classe cria o dela; em teste você injeta um falso. É a mesma
injeção de dependência que o curso usa no DAO do sqflite — sem ela, a classe é impossível de testar.

**`preferredCameraDevice: CameraDevice.rear`.** Pede a câmera traseira. É uma **preferência**: se o
aparelho não tiver traseira, o sistema usa o que tem. Não confie nisso como garantia.

**`origem.saveTo(destino)`.** Copia o conteúdo do `XFile` para um caminho seu. É melhor do que
`File(origem.path).copy(...)` porque funciona igual nas plataformas em que `XFile` não representa um
arquivo de disco real.

**`p.join(...)` em vez de `'$pasta/capas'`.** O pacote `path` usa o separador correto do sistema
(`\` no Windows, `/` no Android e iOS). Concatenar com barra na mão é um bug que só aparece em uma
plataforma — o pior tipo de bug.

**`materia_$idMateria$extensao`.** O nome do arquivo deriva do id da matéria, então trocar a capa
sobrescreve a anterior e não deixa lixo acumulado no disco do usuário.

**`_selecionar(Future<XFile?> Function() escolher)`.** Os dois botões chamam o mesmo método,
passando **a função** a executar (`_servico.tirarFoto` ou `_servico.escolherDaGaleria`). Isso evita
duplicar o tratamento de `null`, de erro e do estado `_ocupado`.

**`if (imagem == null) { ... return; }`.** O cancelamento tem mensagem neutra, não vermelha. Se você
tratar isso como falha, o usuário acha que o app quebrou quando ele mesmo desistiu.

**`finally { if (mounted) setState(...) }`.** O `finally` roda mesmo se houver exceção, garantindo
que o botão volte a funcionar. O `if (mounted)` protege o caso de a tela ter sido fechada durante a
espera.

**`errorBuilder` no `Image.file`.** Sem ele, se o arquivo sumir, você recebe uma exceção pintada em
vermelho no meio da tela. Com ele, aparece um texto discreto — e você ainda pode oferecer "escolher
outra".

**`Expanded` dentro do `Row`.** Faz os dois botões dividirem a largura em partes iguais, em qualquer
tamanho de tela.

---

## 🤖🍎 Android × iOS

| Assunto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Galeria sem permissão | Sim, do Android 13+ (Photo Picker do sistema) | Sim, com o `PHPicker` (iOS 14+) |
| Permissão de câmera | `android.permission.CAMERA` no manifesto + pedido em execução | `NSCameraUsageDescription` no `Info.plist` |
| Acesso parcial à galeria | Existe a partir do Android 14 ("Selecionar fotos") | `limited` desde o iOS 14, e é comum |
| Pasta do arquivo devolvido | Cache do app (`/data/data/<pacote>/cache/...`) | Cache dentro da sandbox do app |
| Risco de o processo morrer | **Alto**: ao abrir a câmera, o Android pode matar seu app | Não acontece na prática |
| Recuperar resultado perdido | `picker.retrieveLostData()` | Não existe — e não é necessário |

### 🤖 O caso do app morto durante a foto

Em aparelhos com pouca memória, o Android pode **encerrar o seu app** enquanto o app da câmera está
aberto. Quando o usuário volta, a foto foi tirada mas o seu `await` nunca terminou: o processo em
que ele existia não existe mais. O `image_picker` oferece uma saída para isso:

```dart
Future<XFile?> recuperarFotoPerdida() async {
  final perdida = await ImagePicker().retrieveLostData();
  if (perdida.isEmpty) return null;      // nada foi perdido
  if (perdida.file != null) return perdida.file;
  debugPrint('Erro ao recuperar: ${perdida.exception}');
  return null;
}
```

Chame isso no `initState` da tela que usa a câmera. É código só do Android — no iOS ele devolve
"vazio" sempre, sem causar problema. Esse tipo de detalhe é o que separa um app que funciona no seu
celular de um app que funciona no celular dos outros.

---

## ⚠️ Erros comuns

**1. Tratar `null` como erro.** O usuário cancelou. Mensagem neutra, nada de vermelho.

**2. Guardar o `.path` do `XFile` no banco.** Aquele arquivo está no cache e vai sumir. Copie para o
diretório de documentos e guarde o caminho novo.

**3. Não limitar tamanho.** Sem `imageQuality`/`maxWidth`, a lista de matérias com 20 capas de 4 MB
cada trava a rolagem e estoura a memória em aparelhos modestos.

**4. Esquecer o `errorBuilder` no `Image.file`.** Quando o arquivo some, a tela inteira vira um
retângulo de erro.

**5. Achar que o emulador tem câmera de verdade.** O emulador do Android mostra uma cena 3D animada
ou uma imagem sintética. Serve para testar o **fluxo** (permissão, retorno, gravação em disco), não
para avaliar qualidade de imagem, foco ou flash. Alguns emuladores permitem usar a webcam do PC
como câmera traseira — mesmo assim, não confunda com o comportamento de um celular real.

**6. Não reiniciar o app depois de instalar o plugin.** Sintoma:

```text
MissingPluginException(No implementation found for method pickImage
on channel plugins.flutter.io/image_picker)
```

*Hot reload* não carrega código nativo. Pare com `q` e rode `flutter run` de novo.

**7. Declarar `NSMicrophoneUsageDescription` sem gravar vídeo.** Permissão sem uso chama atenção na
revisão da Apple e polui a ficha de privacidade.

---

## 🛠️ Exercício guiado

**Objetivo:** dar capa às matérias do Foco, com remoção e confirmação visual.

**Passo 1.** Adicione ao `ServicoImagens` um método que devolve o tamanho legível da imagem:

```dart
Future<String> tamanhoLegivel(XFile arquivo) async {
  final bytes = await arquivo.length();
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
```

**Passo 2.** Na tela, guarde também esse texto em um campo `_tamanho` e mostre-o abaixo da imagem.

**Passo 3.** Rode uma vez **sem** `imageQuality` e `maxWidth` e anote o tamanho. Rode de novo **com**
os dois e compare. Escreva o resultado num comentário no topo do arquivo — esse número é o seu
argumento quando alguém perguntar por que reduzir importa.

**Passo 4.** Adicione um `IconButton` de lixeira na `AppBar`, visível só quando `_caminhoCapa != null`,
que chama `_servico.removerCapa` e limpa o estado.

**Passo 5.** No `initState`, chame o `recuperarFotoPerdida()` da seção Android × iOS e, se vier
imagem, use-a como capa.

**Resultado esperado:** a tela mostra a capa e o tamanho do arquivo, a lixeira apaga o arquivo do
disco, e a redução de qualidade aparece em números (é comum cair de vários MB para algumas centenas
de KB).

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os de **Aplicação** que pedem a troca de capa e o de **Leitura de código** sobre `XFile`.

---

## 🏆 Desafio opcional

Implemente a escolha de **várias** imagens de uma vez com `pickMultiImage`, que devolve
`Future<List<XFile>>` (lista vazia = cancelou, nunca `null`).

Requisitos: limite a 5 imagens (avise o usuário se ele escolher mais), salve todas na pasta `capas`
com nomes derivados de um índice, exiba num `GridView.builder` e permita remover uma a uma. Depois
responda por escrito: por que `pickMultiImage` devolve lista vazia em vez de `null`, e por que essa
escolha de API é melhor? A resposta tem a ver com não precisar de dois testes diferentes para
"nenhuma imagem".

---

## 📌 Resumo

- O app **não** abre a câmera: ele pede ao sistema, que devolve um arquivo.
- `image_picker ^1.2.3` faz isso com `pickImage(source: ImageSource.camera | .gallery)`.
- O retorno é `XFile?`: **`null` significa cancelamento**, e cancelar é normal.
- `XFile` funciona também na web; em mobile, `File(xfile.path)` é seguro.
- `imageQuality` e `maxWidth` reduzem a imagem **no lado nativo**, antes de chegar ao Dart.
- O arquivo devolvido está no **cache** — copie para `getApplicationDocumentsDirectory()`.
- Use `p.join` do pacote `path`, nunca concatenação com barra.
- `Image.file` precisa de `errorBuilder`, porque arquivos somem.
- 🤖 No Android 13+ a galeria não exige permissão (Photo Picker) e o app pode ser morto durante a
  captura — trate com `retrieveLostData()`.
- 🍎 Declare só as chaves do `Info.plist` que você realmente usa.

---

## ☑️ Checklist de domínio

- [ ] Tiro foto e escolho da galeria com o mesmo método, trocando só o `ImageSource`.
- [ ] Trato `null` como cancelamento, com mensagem neutra.
- [ ] Explico o que é `XFile` e por que não é um `File`.
- [ ] Copio a imagem para o diretório de documentos e guardo esse caminho.
- [ ] Uso `imageQuality` e `maxWidth` e sei o efeito de cada um.
- [ ] Coloco `errorBuilder` em todo `Image.file`.
- [ ] Sei quais permissões o Android 13+ exige para câmera e para galeria.
- [ ] Escrevo os textos do `Info.plist` sem declarar permissão que não uso.
- [ ] Sei o que o emulador consegue e o que não consegue simular.
- [ ] Rodei a tela em um Android e vi o arquivo aparecer na pasta do app.

---

## 📚 Referências oficiais

- [image_picker — pub.dev](https://pub.dev/packages/image_picker)
- [XFile (cross_file) — pub.dev](https://pub.dev/packages/cross_file)
- [path_provider — pub.dev](https://pub.dev/packages/path_provider)
- [Photo picker — developer.android.com](https://developer.android.com/training/data-storage/shared/photopicker)
- [Requesting access to protected resources — developer.apple.com](https://developer.apple.com/documentation/uikit/protecting-the-user-s-privacy)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Permissões](01-permissoes.md) | [README](README.md) | [Aula 3 — Arquivos e compartilhamento](03-arquivos-e-compartilhamento.md) |
