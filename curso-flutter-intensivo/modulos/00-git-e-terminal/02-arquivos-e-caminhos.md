# Aula 2 — Arquivos e caminhos

> **Módulo:** 00 - Git e Terminal · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Descrever como um **sistema de arquivos** organiza pastas e arquivos em árvore.
- Diferenciar **caminho absoluto** de **caminho relativo** e escrever os dois corretamente.
- Usar `.` e `..` para navegar sem digitar o caminho inteiro.
- Explicar a diferença entre os separadores `\` (Windows) e `/` (macOS/Linux).
- Entender o que é **extensão de arquivo** e por que ela é apenas uma convenção.
- Explicar o que é **codificação de caracteres** e por que **UTF-8** é o padrão obrigatório do curso.
- Diagnosticar os **dois erros reais desta máquina** causados por acento no caminho:
  `Cannot resolve symbolic links` e `ShaderCompilerException`.
- Adotar uma convenção de pasta de projetos que evita esses erros de uma vez por todas.

## ✅ Pré-requisitos

- [Aula 1 — O terminal sem medo](01-o-terminal-sem-medo.md) concluída: você sabe navegar, listar e
  ler o código de saída.
- A pasta `lab_modulo_00` criada (veja o [README do módulo](README.md)).

---

## 📖 Conceito

### O sistema de arquivos é uma árvore

**Sistema de arquivos** (*file system*) é a forma como o sistema operacional organiza os dados no
disco. A estrutura é uma **árvore**: existe um ponto de partida, e tudo pendura a partir dele.

- 🪟 No **Windows**, cada disco tem sua própria raiz, identificada por uma letra: `C:\`, `D:\`.
- 🖥️🐧 No **macOS e Linux**, existe **uma única** raiz: `/`. Outros discos aparecem *dentro* dela.

```text
C:\                              <- raiz do disco C (Windows)
└── src\cursos\lab_modulo_00     <- a pasta do laboratório
    ├── bin\diagnostico_terminal.dart
    └── pubspec.yaml
```

Cada item da árvore é um **nó**: ou é uma **pasta** (*diretório* — um nó que contém outros nós), ou é
um **arquivo** (um nó que contém dados). O **caminho** (*path*) é o endereço de um nó nessa árvore.

### Caminho absoluto × caminho relativo

**Caminho absoluto** começa na raiz. Identifica o arquivo de forma única, **não importa onde você
esteja**. **Caminho relativo** começa na **pasta atual** (aquela que `Get-Location` / `pwd` mostram):
é curto, mas só faz sentido se você souber de onde está partindo.

```text
absoluto  🪟   C:\src\cursos\lab_modulo_00\bin\diagnostico_terminal.dart
absoluto  🖥️🐧 /Users/voce/src/cursos/lab_modulo_00/bin/diagnostico_terminal.dart
relativo  (a partir de lab_modulo_00)  bin\diagnostico_terminal.dart
```

Dois símbolos especiais valem em qualquer sistema: `.` é a **pasta atual** e `..` é a **pasta acima**
(pasta-mãe).

```powershell
Set-Location ..          # sobe um nível
Set-Location ..\..       # sobe dois níveis
Set-Location .\bin       # entra na subpasta bin
```

Regra prática do curso: **comandos que você digita** usam caminho relativo (é mais curto);
**configurações gravadas em arquivo** usam caminho absoluto (não dependem de onde o programa foi
iniciado).

### Separadores: `\` contra `/`

O Windows historicamente usa a barra invertida `\`; macOS e Linux usam a barra normal `/`. Duas
consequências importantes:

1. **No Windows, a barra normal também funciona** na maioria dos contextos. `C:/src/cursos` é aceito
   pelo PowerShell, pelo Dart e pelo Git. Padronizar `/` na cabeça reduz erros.
2. **Em strings de código, a barra invertida é caractere de escape.** Em Dart, `\n` é quebra de linha
   e `\t` é tabulação. Então um caminho Windows dentro de uma string precisa de cuidado:

```dart
final ruim = 'C:\src\novo';        // \s e \n viram escapes: caminho errado
final certo1 = 'C:\\src\\novo';    // barras duplicadas
final certo2 = r'C:\src\novo';     // raw string: o r desliga os escapes
final certo3 = 'C:/src/novo';      // barra normal: funciona no Windows também
```

É por isso que o arquivo `android/key.properties`, que você vai escrever no
[Módulo 14](../14-build-android/07-assinatura-no-gradle.md), usa barras duplas:

```properties
storeFile=C:\\Users\\SEU_USUARIO\\upload-keystore.jks
```

Em Dart, para montar caminhos de forma portátil existem `Platform.pathSeparator` (o separador nativo)
e o pacote oficial `path` (versão `^1.9.1` neste curso), que aparece em
[Módulo 10 — Arquivos e path_provider](../10-persistencia-de-dados/03-arquivos-e-path-provider.md).

### Extensão de arquivo: uma convenção, não uma lei

A **extensão** é o trecho depois do último ponto do nome: `.dart`, `.md`, `.yaml`. Ela **não**
determina o conteúdo — é só uma convenção que ajuda sistema, editor e ferramentas a decidirem o que
fazer. Renomear `foto.png` para `foto.txt` não transforma a imagem em texto.

| Extensão | O que costuma ser |
|---|---|
| `.dart` | código-fonte Dart |
| `.yaml` | configuração (o `pubspec.yaml` do projeto) |
| `.gradle.kts` | script de build do Android escrito em Kotlin |
| `.plist` | configuração do iOS (formato XML da Apple) |
| `.jks` / `.keystore` | **chave de assinatura do Android — segredo, nunca versionar** |
| `.apk` / `.aab` | instalador Android / pacote para a Google Play |
| `.ipa` | instalador iOS |

> 🪟 O Windows **esconde extensões conhecidas** por padrão, o que faz `chave.jks` aparecer só como
> `chave`. No Explorador de Arquivos, abra **Exibir → Mostrar → Extensões de nomes de arquivo** e
> deixe ligado pelo resto do curso.

### Codificação: por que UTF-8

Um arquivo de texto guarda **bytes**, não letras. **Codificação de caracteres** (*encoding*) é a
tabela que diz qual sequência de bytes representa qual letra.

- **ASCII** é a tabela antiga: 128 caracteres, sem `á`, `ç`, `ã`. Cada caractere ocupa 1 byte.
- **UTF-8** é o padrão moderno: representa qualquer caractere de qualquer idioma. Caracteres ASCII
  continuam ocupando 1 byte; acentuados ocupam 2; emojis, 4.

Consequência direta: em UTF-8, **número de caracteres ≠ número de bytes**. A palavra `Usuário` tem
7 caracteres e **8 bytes**, porque o `á` ocupa dois.

Quando um programa lê bytes UTF-8 achando que são de outra tabela (como a antiga `Windows-1252`),
sai lixo: `Usuário` vira `UsuÃ¡rio`, ou o caractere é substituído por um espaço, ou o programa
falha. **É exatamente isso que acontece nesta máquina.**

### ⚠️ Os dois erros REAIS desta máquina

O Flutter SDK está instalado em `C:\Users\Usuário\Documents\flutter`. O acento em **Usuário** quebra
ferramentas internas do Flutter que não tratam UTF-8. Estas são as saídas reais, já reproduzidas
aqui:

**Erro real 1 — o `flutter doctor` trava ao resolver o caminho:**

```text
[☠] Flutter (the doctor check crashed)
    ✗ FileSystemException: Cannot resolve symbolic links,
      path = 'C:\Users\Usu rio\Documents\flutter\bin\flutter'
      (OS Error: O sistema não pode encontrar o caminho especificado, errno = 3)
```

Olhe com atenção: onde deveria estar `Usuário`, a mensagem mostra `Usu rio`. O `á` **virou um
espaço** porque o byte acentuado foi lido com a tabela errada. O caminho resultante não existe, e o
sistema responde `errno = 3` (*O sistema não pode encontrar o caminho especificado*).

**Erro real 2 — o compilador de shaders não acha um arquivo incluído:**

```text
ShaderCompilerException: Shader compilation of
"C:\Users\Usuário\...\ink_sparkle.frag" failed with exit code 1.
'#include' : Included file not found. for header name: flutter/runtime_effect.glsl
```

Um **shader** é um pequeno programa que roda na placa de vídeo para desenhar efeitos (aqui, a
animação de "respingo" ao tocar um botão do Material). O compilador recebe o caminho com acento, não
consegue resolvê-lo e falha ao procurar o arquivo incluído. Repare no fim da primeira linha:
`failed with exit code 1` — o **código de saída** da Aula 1, sinalizando falha. Além desses dois, o
servidor de análise (`flutter analyze`) encerra nesta máquina com **código 255**.

**Correção obrigatória:** mover o Flutter SDK para um caminho **sem acentos e sem espaços** —
recomendado `C:\src\flutter` — e atualizar o `PATH`. O passo a passo está em
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) e o resumo dos sintomas em
[referencias/erros-comuns.md](../../referencias/erros-comuns.md).

### Espaço no caminho: o outro veneno

Espaço quebra por um motivo diferente: o shell usa o espaço para **separar argumentos**. O caminho
`C:\Meus Projetos\app` vira dois argumentos (`C:\Meus` e `Projetos\app`) a menos que esteja entre
aspas. Scripts de build encadeiam dezenas de chamadas — basta **uma** esquecer as aspas para tudo
cair. Pastas clássicas com espaço no Windows: `Meus Documentos`, `Program Files`, `Área de Trabalho`
(que ainda por cima tem acento).

### Boas práticas de pasta de projetos

1. **Uma raiz curta, sem acento e sem espaço.** 🪟 `C:\src` · 🖥️🐧 `~/src`.
2. **Caminho curto.** O Windows tem um limite histórico de 260 caracteres por caminho, e projetos
   Flutter geram pastas profundas em `build/` que estouram esse limite.
3. **Só minúsculas, números e `_`.** Nome de projeto Dart/Flutter **exige** *snake_case*:
   `meu_primeiro_app` é válido; `Meu App` e `meu-app` não são.
4. **Nunca dentro de pasta sincronizada com nuvem.** OneDrive, Google Drive e Dropbox sincronizam
   durante o build e corrompem `build/` e `.dart_tool/`. 🪟 No Windows 11, a pasta `Documentos`
   costuma estar sob OneDrive **por padrão** — mais um motivo para usar `C:\src`.

---

## 💡 Analogia

Um **caminho absoluto** é o endereço postal completo: país, estado, cidade, rua, número. Funciona de
qualquer lugar do mundo. Um **caminho relativo** é "a terceira porta à direita": funciona
perfeitamente — desde que você esteja no corredor certo.

E a **codificação** é o idioma em que o endereço foi escrito. Se o carteiro lê "Usuário" com o
alfabeto errado, ele entende "Usu rio", procura uma rua que não existe e devolve a carta. Foi
literalmente o que aconteceu no erro `Cannot resolve symbolic links`.

---

## 🧪 Exemplo mínimo

**🪟 Windows (PowerShell)**

```powershell
Set-Location C:\src\cursos\lab_modulo_00
Get-Location
Set-Location .\bin
Set-Location ..
"Usuário".Length
[System.Text.Encoding]::UTF8.GetByteCount("Usuário")
```

As duas últimas linhas mostram `7` e depois `8`. Sete caracteres, oito bytes — a diferença é o `á`.

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
cd ~/src/cursos/lab_modulo_00
pwd
cd ./bin
cd ..
printf 'Usuário' | wc -c     # conta bytes: 8
```

---

## 📱 Aplicando no Flutter

Caminhos não são um detalhe do terminal: eles atravessam o Flutter inteiro.

- **Assets.** *Asset* é qualquer arquivo que acompanha o app (imagem, fonte, JSON). Você declara o
  **caminho relativo** dele no `pubspec.yaml` e o Flutter empacota o arquivo no instalador. Um
  caminho digitado errado não dá erro de compilação — dá uma imagem que simplesmente não aparece.
  Veja [Módulo 06 — Imagens e assets](../06-widgets-e-layouts/08-imagens-e-assets.md).
- **Imports.** Cada arquivo `.dart` importa outro por caminho relativo
  (`import '../domain/materia.dart';`). Com a arquitetura em camadas de
  [Módulo 08](../08-estado-e-arquitetura/09-arquitetura-feature-first.md), você escreve esses
  caminhos o tempo todo.
- **Pastas do app no celular.** Um app não grava arquivo onde quiser: o sistema dá a ele uma pasta
  privada, cujo caminho **muda** entre Android e iOS. O pacote `path_provider ^2.1.6` devolve esse
  caminho em tempo de execução —
  [Módulo 10](../10-persistencia-de-dados/03-arquivos-e-path-provider.md).
- **Saídas de build.** Em [Módulo 14](../14-build-android/08-gerando-apk-e-aab.md), o instalador
  final aparece em `build/app/outputs/flutter-apk/app-release.apk`. Ler esse caminho relativo é como
  você encontra o arquivo para instalar no celular.
- **E os erros desta aula reaparecem literalmente.** O `ShaderCompilerException` acontece durante um
  `flutter run`. Sem corrigir o caminho do SDK agora, ele te encontra no
  [Módulo 05](../05-introducao-ao-flutter/README.md), no seu primeiro app.

---

## 💻 Código completo

Um inspetor de caminhos: recebe um caminho (ou usa a pasta atual), diz se é absoluto ou relativo,
compara caracteres com bytes, aponta os caracteres não-ASCII um a um e lista os riscos encontrados.

> **Arquivo:** `lab_modulo_00/bin/inspetor_de_caminhos.dart`
> **Como executar:** de dentro da pasta `lab_modulo_00`, rode
> `dart run bin/inspetor_de_caminhos.dart "C:\Users\Usuário\Documents\flutter"`

```dart
import 'dart:convert';
import 'dart:io';

/// Analisa um caminho de arquivo e aponta riscos conhecidos.
///
/// Códigos de saída:
///   0 -> nenhum risco encontrado
///   1 -> pelo menos um risco encontrado
void main(List<String> argumentos) {
  final String caminho =
      argumentos.isNotEmpty ? argumentos.first : Directory.current.path;

  stdout.writeln('=== Inspetor de caminhos ===');
  stdout.writeln('Caminho analisado  : $caminho');
  stdout.writeln('Plataforma         : ${Platform.operatingSystem}');
  stdout.writeln('Separador nativo   : "${Platform.pathSeparator}"');

  final bool absoluto = ehAbsoluto(caminho);
  stdout.writeln('Tipo de caminho    : ${absoluto ? 'ABSOLUTO' : 'RELATIVO'}');
  if (!absoluto) {
    stdout.writeln('Resolvido a partir da pasta atual:');
    stdout.writeln('  ${Directory(caminho).absolute.path}');
  }

  final List<String> partes =
      caminho.split(RegExp(r'[\\/]')).where((String p) => p.isNotEmpty).toList();
  final String nomeFinal = partes.isEmpty ? caminho : partes.last;
  final int posicaoDoPonto = nomeFinal.lastIndexOf('.');
  final String extensao =
      posicaoDoPonto > 0 ? nomeFinal.substring(posicaoDoPonto) : '(sem extensão)';

  stdout.writeln('Níveis de pasta    : ${partes.length}');
  stdout.writeln('Último nome        : $nomeFinal');
  stdout.writeln('Extensão           : $extensao');

  final List<int> bytes = utf8.encode(caminho);
  stdout.writeln('Caracteres         : ${caminho.length}');
  stdout.writeln('Bytes em UTF-8     : ${bytes.length}');

  final List<int> naoAscii =
      caminho.runes.where((int codigo) => codigo > 127).toList();
  if (naoAscii.isEmpty) {
    stdout.writeln('Todos os caracteres são ASCII.');
  } else {
    stdout.writeln('Caracteres fora do ASCII (${naoAscii.length}):');
    for (final int codigo in naoAscii) {
      final String letra = String.fromCharCode(codigo);
      final String hexUtf8 = utf8
          .encode(letra)
          .map((int b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      final String codePoint =
          codigo.toRadixString(16).toUpperCase().padLeft(4, '0');
      stdout.writeln('  "$letra" -> U+$codePoint -> bytes UTF-8: $hexUtf8');
    }
  }

  final List<String> riscos = <String>[];
  if (naoAscii.isNotEmpty) {
    riscos.add('Acento ou caractere não-ASCII: quebra o shader compiler e o doctor.');
  }
  if (caminho.contains(' ')) {
    riscos.add('Espaço no caminho: exige aspas em todo comando que o use.');
  }
  if (caminho.length > 120) {
    riscos.add('Caminho longo (${caminho.length}): risco do limite de 260 do Windows.');
  }
  if (caminho.toLowerCase().contains('onedrive')) {
    riscos.add('Pasta sincronizada com nuvem: corrompe build/ e .dart_tool/.');
  }

  if (riscos.isEmpty) {
    stdout.writeln('RESULTADO: nenhum risco encontrado. Caminho seguro.');
    exitCode = 0;
  } else {
    stderr.writeln('RESULTADO: ${riscos.length} risco(s) encontrado(s):');
    for (final String risco in riscos) {
      stderr.writeln('  ! $risco');
    }
    stderr.writeln('Sugestão: mova para C:\\src (Windows) ou ~/src (macOS/Linux).');
    exitCode = 1;
  }
}

/// Diz se o caminho começa na raiz do sistema.
bool ehAbsoluto(String caminho) {
  if (Platform.isWindows) {
    final bool temLetraDeDisco = RegExp(r'^[A-Za-z]:[\\/]').hasMatch(caminho);
    final bool ehRedeCompartilhada = caminho.startsWith(r'\\');
    return temLetraDeDisco || ehRedeCompartilhada;
  }
  return caminho.startsWith('/');
}
```

Teste com os dois casos que interessam. O primeiro deve encerrar com `1` e apontar o acento; o
segundo, com `0`:

```powershell
dart run bin/inspetor_de_caminhos.dart "C:\Users\Usuário\Documents\flutter"
$LASTEXITCODE
dart run bin/inspetor_de_caminhos.dart "C:\src\flutter"
$LASTEXITCODE
```

---

## 🔍 Explicando o código

- `import 'dart:convert';` — biblioteca de conversão de dados. Dela vem o objeto `utf8`, capaz de
  transformar texto em bytes (`utf8.encode`) e bytes em texto (`utf8.decode`).
- `argumentos.isNotEmpty ? argumentos.first : Directory.current.path` — usa o caminho que você passou
  na linha de comando; sem argumento, analisa a pasta atual. `.first` **lança erro se a lista estiver
  vazia**, por isso o teste `isNotEmpty` vem antes.
- `caminho.split(RegExp(r'[\\/]'))` — quebra o caminho tanto em `\` quanto em `/`. Dentro da *raw
  string* `r'...'`, `\\` é uma barra invertida escapada **para a expressão regular**; os colchetes
  significam "qualquer um destes caracteres". Em seguida, `.where(...)` descarta pedaços vazios
  gerados por separadores repetidos ou no fim do caminho.
- `nomeFinal.lastIndexOf('.')` com o teste `> 0` — procura o **último** ponto. O `> 0` (e não `>= 0`)
  é intencional: arquivos como `.gitignore` começam com ponto, e esse ponto **não** é extensão.
- `utf8.encode(caminho)` — devolve a lista de bytes. Comparar `bytes.length` com `caminho.length`
  mostra, numericamente, que caractere e byte não são a mesma coisa.
- `caminho.runes` — percorre os **code points** (o número oficial Unicode de cada caractere), e não
  as unidades internas de 16 bits. É a forma correta de olhar caractere por caractere quando pode
  haver acento ou emoji.
- `b.toRadixString(16).padLeft(2, '0')` — converte o byte para hexadecimal (base 16) com dois
  dígitos. Assim `á` aparece como `c3 a1`: exatamente os dois bytes que confundiram o Flutter nesta
  máquina.
- `final List<String> riscos = <String>[];` — `final` impede reapontar a variável para outra lista,
  mas o conteúdo ainda aceita `add`. A diferença entre `final` e `const` ganha aula própria em
  [Módulo 02](../02-dart-basico/03-var-final-const.md).
- `stderr.writeln(...)` para os riscos — mensagens de problema vão para o **canal de erro**, como
  manda a convenção da Aula 1.
- `'... mova para C:\\src ...'` — repare na barra dupla: dentro de uma string comum, `\\` produz um
  único `\` na tela.
- `exitCode = 0` ou `1` — o programa vira uma **ferramenta de verificação**: um script poderia
  rodá-lo e decidir se continua, sem ler uma linha do texto.

---

## 🤖🍎 Android × iOS

| Assunto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onde ficam os arquivos nativos no projeto | `android/` | `ios/` |
| Sensibilidade a maiúsculas no nome do arquivo | O sistema do celular **diferencia** | O iPhone **diferencia**; o macOS de desenvolvimento, por padrão, **não** |
| Arquivo de configuração que nunca se versiona | `android/key.properties` | `ios/Runner/GoogleService-Info.plist` |
| Pasta privada do app em execução | `/data/data/<pacote>/files` | `.../Application/<id>/Documents` |

A linha do meio é a mais traiçoeira: você desenvolve no 🪟 Windows, onde `Logo.png` e `logo.png` são
o **mesmo** arquivo; no celular, são arquivos **diferentes**. Um asset declarado com maiúscula errada
funciona no seu computador e some no aparelho. Padronize **tudo em minúsculas com `_`**. Voltamos a
isso em [Módulo 06](../06-widgets-e-layouts/08-imagens-e-assets.md).

---

## ⚠️ Erros comuns

**1. `Cannot resolve symbolic links` com o caminho mutilado**

```text
✗ FileSystemException: Cannot resolve symbolic links,
  path = 'C:\Users\Usu rio\Documents\flutter\bin\flutter'
  (OS Error: O sistema não pode encontrar o caminho especificado, errno = 3)
```

Causa: acento no caminho lido com codificação errada. Correção: mover o SDK para `C:\src\flutter` e
atualizar o `PATH`, conforme
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

**2. `ShaderCompilerException ... Included file not found`**

Mesma causa, ferramenta diferente, mesma correção. Reinstalar o Flutter no **mesmo** lugar não
resolve — o que resolve é **mudar de lugar**.

**3. Caminho relativo executado da pasta errada**

```text
Error: Error when reading 'bin/inspetor_de_caminhos.dart': O sistema não pode
encontrar o arquivo especificado.
```

Causa: você está fora de `lab_modulo_00`. Correção: `Get-Location`, depois `Set-Location` para a
pasta certa. Caminho relativo sempre depende de onde você está.

**4. Barra invertida engolida pela string em Dart**

`'C:\temp\novo'` não é o caminho que você quer: `\t` virou tabulação e `\n`, quebra de linha. Use
`r'C:\temp\novo'`, `'C:\\temp\\novo'` ou `'C:/temp/novo'`.

**5. Projeto dentro do OneDrive**

Builds ficam lentos, arquivos reaparecem depois de apagados e `flutter clean` não limpa de verdade.
Mova para `C:\src` e refaça o build.

**6. Nome de projeto inválido, ou arquivo gravado fora do UTF-8**

```text
"Meu App" is not a valid Dart package name.
```

Nome de pacote Dart precisa ser *snake_case*: use `meu_app`. E se acentos aparecem como `Ã§` ao
reabrir um arquivo, o editor gravou fora do UTF-8: no VS Code, o canto inferior direito mostra a
codificação; clique nele e escolha **Save with Encoding → UTF-8**.

---

## 🛠️ Exercício guiado

**Passo 1 — Vá para o laboratório e crie duas pastas de teste: uma boa e uma ruim**

```powershell
Set-Location C:\src\cursos\lab_modulo_00
New-Item -ItemType Directory -Force "caminho_bom"
New-Item -ItemType Directory -Force "caminho ruim com acento é"
Get-ChildItem
```

**Passo 2 — Entre em cada uma e observe a diferença ao digitar**

```powershell
Set-Location caminho_bom
Get-Location
Set-Location ..
Set-Location "caminho ruim com acento é"
Get-Location
Set-Location ..
```

A segunda **exige aspas**. Sem elas, o PowerShell entende cinco argumentos e falha.

**Passo 3 — Rode o inspetor nas duas**

```powershell
dart run bin/inspetor_de_caminhos.dart "C:\src\cursos\lab_modulo_00\caminho_bom"
$LASTEXITCODE
dart run bin/inspetor_de_caminhos.dart "C:\src\cursos\lab_modulo_00\caminho ruim com acento é"
$LASTEXITCODE
```

Esperado: `0` na primeira e `1` na segunda, com os dois riscos listados (acento e espaço) e os bytes
`c3 a9` para o `é`.

**Passo 4 — Rode o inspetor no caminho real do seu Flutter SDK**

```powershell
dart run bin/inspetor_de_caminhos.dart "C:\Users\Usuário\Documents\flutter"
```

Leia com calma o que ele aponta: é o diagnóstico exato dos dois erros reais desta aula.

**Passo 5 — Limpe, listando antes de apagar**

```powershell
Get-ChildItem caminho_bom, "caminho ruim com acento é"
Remove-Item -Recurse -Force caminho_bom
Remove-Item -Recurse -Force "caminho ruim com acento é"
Test-Path caminho_bom
```

`Test-Path` deve responder `False`.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/00-git-e-terminal.md](../../exercicios/00-git-e-terminal.md)

Priorize as seções **Leitura de código** e **Correção de bugs**: elas usam justamente caminhos e
codificação.

---

## 🏆 Desafio opcional

Transforme `bin/inspetor_de_caminhos.dart` em um **auditor de pasta**:

1. Receba um caminho de pasta como argumento.
2. Use `Directory(caminho).listSync(recursive: true)` para percorrer tudo dentro dela.
3. Aplique a cada item as mesmas regras de risco (não-ASCII, espaço, caminho longo).
4. Imprima um relatório: total de itens examinados, total com risco e os **dez piores** (os caminhos
   mais longos entre os que têm risco).
5. Encerre com código `0` se não houver risco algum e `1` caso contrário.

Cuidado: `listSync(recursive: true)` pode lançar exceção em pastas sem permissão de leitura. Trate
com `try`/`catch`, técnica estudada em
[Módulo 04 — Exceptions](../04-dart-avancado/01-exceptions.md).

---

## 📌 Resumo

- O sistema de arquivos é uma **árvore**: raiz única `/` no macOS/Linux, uma raiz por disco (`C:\`)
  no Windows.
- **Caminho absoluto** parte da raiz e funciona de qualquer lugar; **caminho relativo** parte da
  pasta atual. `.` é a pasta atual e `..` é a pasta acima.
- Windows usa `\`, macOS/Linux usam `/` — e o Windows também aceita `/`. Em strings Dart, use
  *raw string* (`r'...'`), barra dupla ou barra normal.
- **Extensão é convenção**, não conteúdo; ligue a exibição de extensões no Windows. Em **UTF-8**
  (obrigatório), caractere e byte **não** são a mesma coisa: `Usuário` = 7 caracteres e 8 bytes.
- Acento no caminho do SDK produz, nesta máquina, `Cannot resolve symbolic links` (com `Usuário`
  virando `Usu rio`) e `ShaderCompilerException`. A correção é **mover o SDK** para `C:\src\flutter`.
- Espaço no caminho quebra por outro motivo: o shell separa argumentos por espaço.
- Boas práticas: raiz curta (`C:\src`), *snake_case*, caminho curto, **fora** de OneDrive.

---

## ☑️ Checklist de domínio

- [ ] Explico o que é o sistema de arquivos e desenho a árvore até um arquivo meu.
- [ ] Escrevo o caminho absoluto e o relativo do mesmo arquivo, sem errar.
- [ ] Sei por que `'C:\temp'` está errado em Dart e conheço as três formas certas.
- [ ] Explico o que é codificação e por que UTF-8 é obrigatório.
- [ ] Digo quantos bytes tem a palavra `Usuário` em UTF-8 e por quê.
- [ ] Reconheço `Cannot resolve symbolic links` e `ShaderCompilerException`, sei a causa e a correção.
- [ ] Aponto, em uma mensagem de erro, o sinal de que o acento foi lido errado.
- [ ] Minha pasta de projetos é curta, sem acento, sem espaço e fora da nuvem.
- [ ] Rodo `bin/inspetor_de_caminhos.dart` e interpreto a saída e o código de saída.

---

## 📚 Referências oficiais

- [Flutter — instalação no Windows](https://docs.flutter.dev/get-started/install/windows)
- [Dart — pacote `path`](https://pub.dev/packages/path)
- [Dart — `Directory`](https://api.dart.dev/stable/dart-io/Directory-class.html)
- [Dart — biblioteca `dart:convert`](https://api.dart.dev/stable/dart-convert/dart-convert-library.html)
- [Microsoft — limite de tamanho de caminho no Windows](https://learn.microsoft.com/pt-br/windows/win32/fileio/maximum-file-path-limitation)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [O terminal sem medo](01-o-terminal-sem-medo.md) | [README](README.md) | [Git: o que é](03-git-o-que-e.md) |
