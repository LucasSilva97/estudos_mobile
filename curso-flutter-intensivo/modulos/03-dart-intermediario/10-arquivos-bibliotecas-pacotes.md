# Aula 10 — Arquivos, bibliotecas e pacotes

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 50 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Organizar o código em **um arquivo por classe**, com nomes no padrão do Dart.
- Escolher corretamente entre `import` **relativo** e `import 'package:...'`.
- Entender o que é uma **biblioteca** em Dart e como ela define o limite do `_privado`.
- Usar `export` para criar um **arquivo-fachada** (*barrel*) e `part` para o que os geradores fazem.
- Ler e escrever um `pubspec.yaml`, campo por campo.
- Instalar dependências com `dart pub add` / `flutter pub add`.
- Interpretar o **versionamento semântico** (`^1.2.3`, e a regra especial do `^0.20.2`).
- Explicar o papel do `pubspec.lock` e quando versioná-lo.
- **Avaliar um pacote do pub.dev** antes de colocá-lo no seu app.

## ✅ Pré-requisitos

- Todas as aulas anteriores do módulo, especialmente
  [Aula 3 — Encapsulamento](03-encapsulamento.md) (o `_` privado).
- Terminal e pastas do [Módulo 00](../00-git-e-terminal/02-arquivos-e-caminhos.md).

---

## 📖 Conceito

### Um arquivo por classe

Até aqui todo o seu código cabia em um arquivo. Isso acaba hoje.

A convenção do ecossistema Dart/Flutter:

| Regra | Exemplo |
|---|---|
| Um arquivo por classe pública | `materia.dart` contém `class Materia` |
| Nome do arquivo em `snake_case` | `repositorio_materias.dart` |
| Nome do arquivo = nome da classe, "traduzido" | `MateriaRepositorio` → `materia_repositorio.dart` |
| Código de biblioteca vai em `lib/` | `lib/src/materia.dart` |
| Programas executáveis vão em `bin/` | `bin/10_bibliotecas.dart` |
| Testes vão em `test/`, terminando em `_test.dart` | `test/materia_test.dart` |

Classes pequenas e muito ligadas (por exemplo, um `enum` que só existe para uma classe) podem ficar
no mesmo arquivo. Fora isso: um arquivo, uma classe.

### Biblioteca: o conceito que explica o `_`

Em Dart, **cada arquivo `.dart` é uma biblioteca**. E "privado", como você viu na
[Aula 3](03-encapsulamento.md), significa **privado à biblioteca** — ou seja, ao arquivo.

Consequência prática, agora que o código se espalha: ao separar duas classes em dois arquivos, elas
**deixam de enxergar** os membros `_privados` uma da outra. Isso não é um problema; é o objetivo. A
separação em arquivos é o que transforma encapsulamento em algo real.

Você pode declarar o arquivo como biblioteca explicitamente, o que só é necessário quando você
escreve documentação no nível da biblioteca ou usa `part`:

```dart
/// Modelos e repositórios do organizador de estudos.
library;
```

### `import` relativo × `import 'package:...'`

```dart
import 'materia.dart';                          // relativo
import 'src/extensoes/formatacao.dart';         // relativo, em subpasta
import 'package:dart_intermediario/foco.dart';  // por pacote
import 'dart:math';                             // biblioteca do SDK
import 'package:intl/intl.dart';                // pacote de terceiro
```

A regra oficial, que evita 90% da confusão:

> **Dentro de `lib/`, use imports relativos entre os seus próprios arquivos.
> De `bin/` e de `test/` para `lib/`, use `package:`.
> Para pacotes de terceiros e bibliotecas do SDK, sempre `package:` ou `dart:`.**

O motivo de nunca usar `../lib/...` a partir de `bin/` ou `test/`: o Dart trataria o **mesmo arquivo**
como duas bibliotecas diferentes, e você veria erros absurdos como "o tipo `Materia` não é o tipo
`Materia`".

Modificadores úteis no `import`:

```dart
import 'package:intl/intl.dart' show DateFormat; // traga só isto
import 'utilidades.dart' hide Helper;            // traga tudo menos isto
import 'package:http/http.dart' as http;         // apelido: http.get(...)
```

O apelido (`as`) é o padrão do pacote `http`, e resolve conflitos de nome entre bibliotecas.

### `export`: o arquivo-fachada (*barrel*)

Sem fachada, quem usa o seu pacote precisa importar cinco arquivos. Com fachada, um só:

```dart
// lib/foco.dart
library;

export 'src/materia.dart';
export 'src/sessao.dart';
export 'src/repositorio_materias.dart';
```

Agora `import 'package:dart_intermediario/foco.dart';` traz tudo.

E repare na pasta `src/`: por convenção do ecossistema, **tudo em `lib/src/` é considerado interno
ao pacote**. Quem usa o seu pacote deve importar apenas o que está diretamente em `lib/`. Isso lhe dá
liberdade para reorganizar `src/` sem quebrar ninguém.

### `part` e `part of`

`part` faz o contrário de `import`: em vez de usar outra biblioteca, ele **funde** outro arquivo na
mesma biblioteca.

```dart
// lib/src/materia.dart
part 'materia_extras.dart';

// lib/src/materia_extras.dart
part of 'materia.dart';
```

Os dois arquivos passam a compartilhar o **mesmo** escopo privado: `materia_extras.dart` enxerga os
`_campos` de `materia.dart`.

⚠️ **Quando usar `part` no seu código? Praticamente nunca.** Ele acopla arquivos de forma rígida e
confunde quem lê. A comunidade Dart o reserva para **geradores de código**, e é por isso que você
encontra linhas assim em projetos alheios:

```dart
part 'materia.g.dart';      // gerado por json_serializable
part 'materia.freezed.dart'; // gerado por freezed
```

Este curso **não usa geração de código** (decisão registrada em
[`05-decisoes-tecnicas.md`](../../05-decisoes-tecnicas.md)) — você escreve `copyWith`, `==` e
`fromJson` à mão, porque entender vale mais do que economizar linhas nesta fase. Mas você precisa
reconhecer o `part` quando o encontrar.

### `pubspec.yaml`

É o documento de identidade do projeto. Fica na raiz e é escrito em **YAML** (formato de texto onde
a **indentação com espaços** define a estrutura — nunca use TAB).

```yaml
name: dart_intermediario
description: Exercícios do Módulo 03 do curso Flutter Intensivo.
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.13.0

dependencies:
  intl: ^0.20.2
  uuid: ^4.6.0
```

| Campo | Para que serve |
|---|---|
| `name` | Nome do pacote. `snake_case`, sem hífen. É ele que aparece em `package:nome/...` |
| `description` | Uma frase. Obrigatória para publicar no pub.dev |
| `version` | Versão **do seu** projeto, em `MAJOR.MINOR.PATCH` |
| `publish_to: none` | Impede publicação acidental no pub.dev. Use em apps e projetos de estudo |
| `environment.sdk` | Faixa de versões do Dart aceitas. Neste curso: `^3.13.0` |
| `dependencies` | O que o app precisa **para rodar** |
| `dev_dependencies` | O que só é usado no desenvolvimento (testes, lints, geradores) |

No projeto Flutter do curso, a lista oficial é esta — e ela é a **única** fonte de versões que você
deve usar:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^3.4.3
  http: ^1.6.0
  shared_preferences: ^2.5.5
  sqflite: ^2.4.4
  path: ^1.9.1
  path_provider: ^2.1.6
  intl: ^0.20.2
  uuid: ^4.6.0
  flutter_secure_storage: ^11.1.1
  connectivity_plus: ^7.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mocktail: ^1.0.5
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.8
  sqflite_common_ffi: ^2.4.3
```

### Instalando dependências

Nunca edite o `pubspec.yaml` na mão para adicionar um pacote: deixe a ferramenta escolher a versão
compatível e escrever a linha.

**🪟 Windows (PowerShell) — projeto Dart puro**
```powershell
dart pub add intl
dart pub get
dart pub outdated
```

**🪟 Windows (PowerShell) — projeto Flutter**
```powershell
flutter pub add flutter_riverpod
flutter pub add dev:mocktail
flutter pub get
```

O prefixo `dev:` coloca o pacote em `dev_dependencies`.

> ⚠️ **Erro real desta máquina.** Ao rodar `flutter pub add` em um projeto com plugins nativos, o
> Windows pode recusar:
> ```text
> Building with plugins requires symlink support.
> Please enable Developer Mode in your system settings. Run
>   start ms-settings:developers
> to open settings.
> ```
> Correção: ative o **Modo de Desenvolvedor** (Configurações → Sistema → Para desenvolvedores).
> Esse e outros casos estão em [`referencias/erros-comuns.md`](../../referencias/erros-comuns.md).

### Versionamento semântico (semver)

Uma versão tem três números: `MAJOR.MINOR.PATCH`.

| Parte | Muda quando | Exemplo |
|---|---|---|
| **MAJOR** | há mudança que **quebra** código existente | 1.9.0 → **2**.0.0 |
| **MINOR** | há recurso novo, compatível com o anterior | 1.9.0 → 1.**10**.0 |
| **PATCH** | há correção de bug, sem mudar a API | 1.9.0 → 1.9.**1** |

O acento circunflexo (`^`) é o **intervalo de compatibilidade**:

| Escrita | Significa | Comentário |
|---|---|---|
| `^1.2.3` | `>=1.2.3 <2.0.0` | aceita correções e recursos novos, barra a quebra |
| `^0.20.2` | `>=0.20.2 <0.21.0` | ⚠️ **regra especial**: abaixo de 1.0.0, o MINOR é tratado como MAJOR |
| `1.2.3` | exatamente essa | evite: trava demais e cria conflito entre pacotes |
| `>=1.2.0 <1.5.0` | intervalo manual | use só quando houver motivo documentado |
| `any` | qualquer uma | nunca use |

A regra especial do `0.x` explica por que o curso usa `intl: ^0.20.2`: como `intl` ainda não chegou
à 1.0.0, uma subida de `0.20` para `0.21` já pode quebrar a API — e o `^` protege você disso.

### `pubspec.lock`

Enquanto o `pubspec.yaml` diz *"aceito qualquer 1.x a partir da 1.6.0"*, o **`pubspec.lock`** grava
*"hoje resolvi exatamente a 1.6.0"*, para **todas** as dependências, inclusive as indiretas.

- É **gerado** por `pub get`. Não edite à mão.
- **Versione (commit) em aplicativos.** Assim a sua máquina, a do colega e o servidor de build
  compilam com exatamente as mesmas versões.
- **Não versione em pacotes/bibliotecas** que você publica: quem usa o seu pacote precisa resolver
  as versões no contexto dele.
- `dart pub upgrade` recalcula o lock dentro dos limites do `pubspec.yaml`.

### Como avaliar um pacote do pub.dev

[pub.dev](https://pub.dev) é o repositório oficial. Antes de adicionar **qualquer** dependência,
faça esta lista de 10 perguntas:

1. **Preciso mesmo?** Dá para resolver com 20 linhas suas? Toda dependência é um compromisso de
   manutenção. O SDK do Flutter já faz muita coisa.
2. **Pub points** (nota de 0 a 160): mede documentação, análise estática, suporte a plataformas,
   dependências atualizadas. Abaixo de ~130, investigue o porquê.
3. **Likes e downloads**: adoção da comunidade. Números altos significam bugs já encontrados por
   outros.
4. **Última publicação**: um pacote parado há 2 anos em um ecossistema que lança versão a cada 3
   meses é um risco.
5. **Publisher verificado**: `flutter.dev`, `dart.dev` e `tools.dart.dev` são times oficiais. Um
   selo de verificação de empresa conhecida também conta.
6. **Plataformas suportadas**: a página mostra os selos Android, iOS, web, Windows, macOS, Linux.
   Confira que as **duas** que você precisa (Android e iOS) estão lá.
7. **Licença**: MIT, BSD e Apache-2.0 são seguras para app comercial. Licenças mais restritivas
   exigem leitura atenta.
8. **Issues abertas**: entre no repositório. O mantenedor responde? Há *pull requests* parados há
   um ano?
9. **Tamanho da árvore de dependências**: `dart pub deps` mostra tudo o que virá junto. Um pacote
   pequeno que arrasta 30 outros não é pequeno.
10. **Exemplo e documentação**: tem pasta `example/`? O README mostra código que roda?

---

## 💡 Analogia

Uma **obra de construção**.

- Cada **arquivo `.dart`** é um cômodo com porta: o que está `_privado` fica dentro do cômodo.
- O **`export`** (a fachada) é a recepção do prédio: uma entrada só, e quem chega não precisa saber
  por quais corredores passar.
- A pasta **`lib/src/`** é a área de serviço: funciona, é essencial, mas não é por ali que se recebe
  visita.
- O **`pubspec.yaml`** é a lista de materiais da obra: "preciso de cimento marca X, versão do
  fornecedor tal".
- O **`pubspec.lock`** é a **nota fiscal**: registra o lote exato que chegou, para que a reforma do
  ano que vem use o mesmo material.
- E **avaliar um pacote** é conferir o fornecedor antes de comprar: há quanto tempo está no mercado,
  quem mais comprou, se entrega nas duas cidades onde você constrói (Android e iOS).

---

## 🧪 Exemplo mínimo

Três arquivos, para você ver o `_` privado virando uma fronteira de verdade.

> **Arquivo 1:** `lib/src/contador.dart`

```dart
class Contador {
  int _valor = 0; // privado A ESTE ARQUIVO

  int get valor => _valor;

  void incrementar() => _valor++;
}
```

> **Arquivo 2:** `lib/contadores.dart` (a fachada)

```dart
library;

export 'src/contador.dart';
```

> **Arquivo 3:** `bin/exemplo_pacote.dart`
> **Como executar:** `dart run bin/exemplo_pacote.dart`

```dart
import 'package:dart_intermediario/contadores.dart';

void main() {
  final contador = Contador()
    ..incrementar()
    ..incrementar();

  print('Valor: ${contador.valor}');
  // contador._valor = 99; // ❌ não compila: _valor é privado a contador.dart
}
```

Saída:

```text
Valor: 2
```

Descomente a linha do `_valor` e leia o erro:

```text
Error: The setter '_valor' isn't defined for the type 'Contador'.
```

Esse erro é a prova de que a separação em arquivos criou uma fronteira real.

---

## 📱 Aplicando no Flutter

Tudo o que você viu aqui vira rotina diária no Flutter.

**1. A estrutura de pastas do app Foco** é exatamente esta ideia, levada a sério:

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/app_constants.dart
│   ├── erros/falhas.dart
│   ├── rotas/rotas.dart
│   └── tema/tema_app.dart
└── features/
    └── materias/
        ├── data/materia_repositorio.dart
        ├── domain/materia.dart
        └── presentation/materias_controller.dart
```

Cada arquivo com uma responsabilidade, importados por caminho relativo dentro de `lib/`. A
justificativa completa dessa arquitetura está em
[`08-estado-e-arquitetura/09-arquitetura-feature-first.md`](../08-estado-e-arquitetura/09-arquitetura-feature-first.md).

**2. Os imports do Flutter** que você vai escrever mil vezes:

```dart
import 'package:flutter/material.dart';            // o framework
import 'package:flutter_riverpod/flutter_riverpod.dart'; // pacote externo
import '../domain/materia.dart';                   // seu código, relativo
```

**3. O `pubspec.yaml` também carrega os *assets*** (imagens, fontes) do app — com a indentação
exatamente certa, senão a imagem "some". Isso é o
[Módulo 06](../06-widgets-e-layouts/08-imagens-e-assets.md).

**4. A avaliação de pacotes** volta com força no
[Módulo 11](../11-recursos-nativos/10-avaliando-pacotes.md), quando você precisar escolher entre
três pacotes de câmera — aí a escolha errada custa dias.

---

## 🤖🍎 Android × iOS

Esta seção existe porque **pacote não é só Dart**.

Um **plugin** é um pacote que contém código nativo: Kotlin/Java para 🤖 Android e Swift/Objective-C
para 🍎 iOS. Se o plugin não tiver implementação para uma das plataformas, o app **compila e quebra
em tempo de execução** naquela plataforma.

Por isso, na página do pacote no pub.dev, os selos de plataforma são o item que você confere
primeiro:

| Pacote do curso | 🤖 Android | 🍎 iOS | Observação de plataforma |
|---|---|---|---|
| `sqflite` | ✅ | ✅ | Banco SQLite nativo em ambos |
| `shared_preferences` | ✅ | ✅ | Usa `SharedPreferences` no Android e `NSUserDefaults` no iOS |
| `flutter_secure_storage` | ✅ | ✅ | Usa **Keystore** no Android e **Keychain** no iOS |
| `path_provider` | ✅ | ✅ | Os caminhos devolvidos são **diferentes** em cada sistema |
| `connectivity_plus` | ✅ | ✅ | Requer permissões diferentes em cada plataforma |
| `http` | ✅ | ✅ | Dart puro: não tem código nativo |

Duas consequências práticas:

- 🪟 **No Windows você consegue adicionar e compilar pacotes para Android**, mas **não** consegue
  compilar a parte iOS. O `pubspec.yaml` é o mesmo; a validação em iOS só acontece em um Mac.
  Veja [`16-build-ios/01-por-que-exige-macos.md`](../16-build-ios/01-por-que-exige-macos.md).
- 🤖 Alguns plugins exigem alterações em `android/app/build.gradle.kts` (versão mínima do Android) ou
  em `ios/Podfile` (versão mínima do iOS). O README do pacote avisa — **leia antes de instalar**.

Comparações detalhadas em
[`referencias/diferencas-android-ios.md`](../../referencias/diferencas-android-ios.md).

---

## 💻 Código completo

Agora você monta um pacote de verdade, com cinco arquivos. Use a pasta de prática do módulo
(`dart_intermediario`), criada no [README](README.md).

> **Arquivo 1:** `lib/src/materia.dart`

```dart
/// Modelo de uma matéria de estudo.
class Materia {
  final String id;
  final String nome;
  final int minutos;

  const Materia({required this.id, required this.nome, this.minutos = 0});

  Materia copyWith({String? nome, int? minutos}) => Materia(
        id: id,
        nome: nome ?? this.nome,
        minutos: minutos ?? this.minutos,
      );

  @override
  String toString() => 'Materia($id, $nome, $minutos min)';
}
```

> **Arquivo 2:** `lib/src/sessao.dart`

```dart
// Import RELATIVO: dentro de lib/, é o recomendado entre arquivos do pacote.
import 'materia.dart';

/// Uma sessão de estudo de uma matéria.
class Sessao {
  final String id;
  final Materia materia;
  final int minutos;

  const Sessao({
    required this.id,
    required this.materia,
    required this.minutos,
  });

  @override
  String toString() => 'Sessao($id, ${materia.nome}, $minutos min)';
}
```

> **Arquivo 3:** `lib/src/repositorio_materias.dart`

```dart
import 'materia.dart';

/// Guarda matérias em memória, indexadas pelo id.
class RepositorioMaterias {
  // Privado a ESTE arquivo: nem `Sessao` nem `bin/` enxergam este mapa.
  final Map<String, Materia> _itens = <String, Materia>{};

  void salvar(Materia materia) => _itens[materia.id] = materia;

  Materia? buscar(String id) => _itens[id];

  List<Materia> listar() => _itens.values.toList();

  int get total => _itens.length;

  int get totalDeMinutos =>
      _itens.values.fold<int>(0, (soma, materia) => soma + materia.minutos);
}
```

> **Arquivo 4:** `lib/src/extensoes/formatacao.dart`

```dart
/// Extensões de formatação (Aula 9), agora em arquivo próprio.
extension DuracaoDeEstudo on int {
  String get comoTempoDeEstudo {
    final horas = this ~/ 60;
    final minutos = this % 60;
    if (horas == 0) {
      return '${minutos}min';
    }
    if (minutos == 0) {
      return '${horas}h';
    }
    return '${horas}h${minutos.toString().padLeft(2, '0')}';
  }
}
```

> **Arquivo 5 (a fachada):** `lib/foco.dart`

```dart
/// Biblioteca pública do pacote: modelos, repositório e extensões
/// do organizador de estudos.
library;

export 'src/materia.dart';
export 'src/sessao.dart';
export 'src/repositorio_materias.dart';
export 'src/extensoes/formatacao.dart';
```

> **Arquivo 6 (o programa):** `bin/10_bibliotecas.dart`
> **Como executar:** `dart run bin/10_bibliotecas.dart`

```dart
// De bin/ para lib/, SEMPRE com package: (nunca '../lib/...').
// Um único import traz tudo, graças à fachada lib/foco.dart.
import 'package:dart_intermediario/foco.dart';

void main() {
  final repositorio = RepositorioMaterias()
    ..salvar(const Materia(id: 'm1', nome: 'Dart', minutos: 150))
    ..salvar(const Materia(id: 'm2', nome: 'Flutter', minutos: 180))
    ..salvar(const Materia(id: 'm3', nome: 'Lógica', minutos: 45));

  print('--- Pacote dart_intermediario ---');
  print('Matérias cadastradas: ${repositorio.total}');

  for (final materia in repositorio.listar()) {
    // `comoTempoDeEstudo` veio da extensão exportada pela fachada.
    print(' - $materia -> ${materia.minutos.comoTempoDeEstudo}');
  }

  final dart = repositorio.buscar('m1');
  if (dart != null) {
    final sessao = Sessao(id: 's1', materia: dart, minutos: 45);
    print('Sessão criada: $sessao');

    final atualizada = dart.copyWith(minutos: dart.minutos + sessao.minutos);
    repositorio.salvar(atualizada);
    print('Dart atualizada: $atualizada');
  }

  print('Total estudado: ${repositorio.totalDeMinutos.comoTempoDeEstudo}');
}
```

> **Arquivo 7:** `pubspec.yaml` (confira que o `name` é exatamente este)

```yaml
name: dart_intermediario
description: Exercícios do Módulo 03 do curso Flutter Intensivo.
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.13.0
```

**Saída esperada:**

```text
--- Pacote dart_intermediario ---
Matérias cadastradas: 3
 - Materia(m1, Dart, 150 min) -> 2h30
 - Materia(m2, Flutter, 180 min) -> 3h
 - Materia(m3, Lógica, 45 min) -> 45min
Sessão criada: Sessao(s1, Dart, 45 min)
Dart atualizada: Materia(m1, Dart, 195 min)
Total estudado: 7h
```

---

## 🔍 Explicando o código

**`import 'materia.dart';` em `sessao.dart`**
Import **relativo**, entre arquivos da mesma pasta dentro de `lib/`. É o recomendado pelo
*Effective Dart* e o que o `dart fix` sugere.

**`import 'package:dart_intermediario/foco.dart';` em `bin/`**
Import **por pacote**. O nome `dart_intermediario` é exatamente o campo `name` do `pubspec.yaml` — se
eles não baterem, o import não resolve. Este é o erro número um de quem renomeia a pasta do projeto
e esquece do `pubspec.yaml`.

**`library;` em `lib/foco.dart`**
Declara o arquivo como biblioteca, sem lhe dar nome (a forma moderna; a antiga,
`library nome_da_lib;`, ainda funciona mas não é mais recomendada). Aqui ele serve para sustentar o
comentário de documentação `///` acima.

**Os quatro `export`**
Cada `export` republica os membros públicos do arquivo apontado. Quem importa `foco.dart` recebe
`Materia`, `Sessao`, `RepositorioMaterias` **e** a extensão `DuracaoDeEstudo` — inclusive a
extensão, que só funciona quando está no escopo ([Aula 9](09-extensions.md)).

**A pasta `lib/src/`**
Marca convencional de "interno". Se amanhã você renomear `src/repositorio_materias.dart`, ninguém de
fora quebra, porque todos importam a fachada.

**`final Map<String, Materia> _itens` em outro arquivo**
Agora o `_itens` está **realmente** protegido: `bin/10_bibliotecas.dart` não consegue tocá-lo nem por
acidente. É o encapsulamento da Aula 3 com dentes.

**`RepositorioMaterias()..salvar(...)..salvar(...)`**
Operador cascata (Aula 6): três chamadas seguidas no mesmo objeto, e o resultado da expressão é o
**repositório**, não o retorno de `salvar`.

**`final dart = repositorio.buscar('m1'); if (dart != null) { ... }`**
`buscar` devolve `Materia?`. Depois do `if (dart != null)`, a promoção de tipo (Aula 4) permite usar
`dart.minutos` sem `!`. Preferir isso ao `!` é o hábito seguro de *null safety*.

**`dart.copyWith(minutos: dart.minutos + sessao.minutos)` → 150 + 45 = 195**
Imutabilidade (Aula 3): a matéria não foi alterada, uma nova foi criada e regravada no repositório
com o mesmo id.

**`repositorio.totalDeMinutos.comoTempoDeEstudo` → `7h`**
195 + 180 + 45 = 420 minutos = 7 horas exatas, e o `comoTempoDeEstudo` devolve `'7h'` quando o resto
é zero. Repare na cadeia: um getter do repositório devolve `int`, e a extensão entra em cima dele.

---

## ⚠️ Erros comuns

**1. `package:` com nome errado**

```dart
import 'package:dartIntermediario/foco.dart'; // ❌
```
```text
Error: Couldn't resolve the package 'dartIntermediario'.
```
✅ Use exatamente o `name` do `pubspec.yaml`, em `snake_case`.

**2. Import relativo de `bin/` para `lib/`**

```dart
import '../lib/foco.dart'; // ❌
```
Compila às vezes, e gera erros surreais de tipo ("`Materia` não é `Materia`").
✅ `import 'package:dart_intermediario/foco.dart';`

**3. Import circular de verdade**

`a.dart` importa `b.dart`, que importa `a.dart`. O Dart tolera, mas é sinal de que as duas classes
deveriam estar no mesmo arquivo ou que falta uma terceira peça.
✅ Repense a separação.

**4. TAB no `pubspec.yaml`**

```text
Error on line 7, column 1: Mapping values are not allowed here.
```
✅ YAML aceita **apenas espaços**. Configure o editor para converter TAB em espaços.

**5. Editar `pubspec.yaml` à mão e esquecer o `pub get`**

```text
Error: Couldn't resolve the package 'intl'.
```
✅ Rode `dart pub get` (ou `flutter pub get`). Melhor ainda: use `dart pub add intl`.

**6. Travar a versão exata**

```yaml
dependencies:
  http: 1.6.0 # ❌
```
Isso bloqueia correções de segurança e cria conflito com outros pacotes.
✅ `http: ^1.6.0`.

**7. Achar que `^0.20.2` aceita a `0.21.0`**

Não aceita. Abaixo de 1.0.0, o MINOR funciona como MAJOR.
✅ Leia o CHANGELOG antes de subir de `0.20` para `0.21`.

**8. Não versionar o `pubspec.lock` de um aplicativo**

Cada máquina resolve versões diferentes e o bug "só acontece no computador dele" aparece.
✅ Faça commit do `pubspec.lock` em apps. Não faça em pacotes publicados.

**9. Adicionar dependência sem avaliar**

Um pacote parado há dois anos, sem suporte a iOS, pode custar o projeto inteiro no dia do build.
✅ Rode a lista de 10 perguntas desta aula, sempre.

---

## 🛠️ Exercício guiado

Vamos acrescentar uma dependência real ao pacote e reorganizá-lo.

**Passo 1.** Na pasta do projeto, adicione o pacote de identificadores únicos:

```powershell
dart pub add uuid
```

O `pubspec.yaml` ganha a linha `uuid: ^4.6.0` (a versão oficial deste curso) e o `pubspec.lock`
é criado/atualizado. Abra os dois e compare: um traz o **intervalo**, o outro a **versão exata**.

**Passo 2.** Crie `lib/src/gerador_de_ids.dart`:

```dart
import 'package:uuid/uuid.dart';

/// Gera identificadores únicos para matérias e sessões.
class GeradorDeIds {
  // `const Uuid()` cria o gerador; `v4()` produz um id aleatório.
  static const _uuid = Uuid();

  static String novo() => _uuid.v4();

  /// Versão determinística, útil em teste (não usa aleatoriedade).
  static String previsivel(String prefixo, int numero) =>
      '$prefixo-${numero.toString().padLeft(3, '0')}';
}
```

**Passo 3.** Exporte na fachada `lib/foco.dart`:

```dart
export 'src/gerador_de_ids.dart';
```

**Passo 4.** Crie `bin/guiado_10_pacote.dart`:

```dart
import 'package:dart_intermediario/foco.dart';

void main() {
  // Ids previsíveis: a saída é reproduzível.
  final repositorio = RepositorioMaterias();
  const nomes = <String>['Dart', 'Flutter', 'Lógica'];
  const minutos = <int>[150, 180, 45];

  for (var i = 0; i < nomes.length; i++) {
    repositorio.salvar(
      Materia(
        id: GeradorDeIds.previsivel('mat', i + 1),
        nome: nomes[i],
        minutos: minutos[i],
      ),
    );
  }

  for (final materia in repositorio.listar()) {
    print('${materia.id} · ${materia.nome} · '
        '${materia.minutos.comoTempoDeEstudo}');
  }
  print('Total: ${repositorio.totalDeMinutos.comoTempoDeEstudo}');

  // Id aleatório de verdade: só o formato é previsível.
  final aleatorio = GeradorDeIds.novo();
  print('Id aleatório tem ${aleatorio.length} caracteres e '
      '${aleatorio.split('-').length} blocos.');
}
```

**Passo 5.** Execute:

```powershell
dart run bin/guiado_10_pacote.dart
```

**Saída esperada:**

```text
mat-001 · Dart · 2h30
mat-002 · Flutter · 3h
mat-003 · Lógica · 45min
Total: 6h15
Id aleatório tem 36 caracteres e 5 blocos.
```

(O id aleatório muda a cada execução; o que não muda é o **formato**: 36 caracteres divididos em 5
blocos por hífens — é o padrão UUID v4.)

**Passo 6.** Feche com as ferramentas de qualidade:

```powershell
dart analyze
dart format .
dart pub deps
```

O `dart pub deps` mostra a árvore completa: repare que `uuid` trouxe outros pacotes junto. Esse é o
custo real de uma dependência — a pergunta 9 da lista de avaliação.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Reorganize **todo** o código do módulo 03 em um pacote bem estruturado:

```text
lib/
├── foco.dart                       (fachada: só exports)
└── src/
    ├── modelos/{materia.dart,sessao.dart,meta.dart}
    ├── enums/{status_da_sessao.dart,nivel_de_energia.dart}
    ├── repositorios/{repositorio.dart,repositorio_materias.dart}
    ├── mixins/{logavel.dart,validavel.dart}
    └── extensoes/{formatacao.dart,datas.dart}
```

Requisitos:

1. Nenhum arquivo com mais de uma classe pública.
2. Todos os imports internos **relativos**; o `bin/` usa só `package:`.
3. A fachada exporta **apenas** o que faz sentido para quem usa o pacote — deixe de fora o que for
   detalhe interno e explique em comentário o critério que você usou.
4. Rode `dart analyze` e resolva **todos** os avisos.
5. Escolha um pacote qualquer no [pub.dev](https://pub.dev) e escreva, em um arquivo
   `AVALIACAO_DE_PACOTE.md` no seu projeto, a resposta às 10 perguntas desta aula. Termine com uma
   recomendação: usar, não usar, ou usar com ressalvas — e o motivo.

---

## 📌 Resumo

- **Um arquivo por classe**, nome em `snake_case`; `lib/` para biblioteca, `bin/` para executáveis,
  `test/` para testes.
- Em Dart, **cada arquivo é uma biblioteca**, e é isso que define o alcance do `_privado`.
- **Relativo dentro de `lib/`; `package:` de `bin/` e `test/`** e para pacotes de terceiros.
- `export` cria a **fachada**; `lib/src/` marca o que é interno.
- `part`/`part of` fundem arquivos numa biblioteca só — na prática, território de geradores de
  código.
- `pubspec.yaml`: `name`, `description`, `version`, `environment.sdk`, `dependencies`,
  `dev_dependencies`. YAML **só com espaços**.
- Instale com `dart pub add` / `flutter pub add` (`dev:` para dev_dependencies), nunca editando à mão.
- `^1.2.3` = `>=1.2.3 <2.0.0`. **`^0.20.2` = `>=0.20.2 <0.21.0`** — abaixo de 1.0.0 o MINOR quebra.
- `pubspec.lock` grava as versões exatas: **versione em apps**, não em pacotes publicados.
- Avalie todo pacote pelas 10 perguntas, e confira os selos de plataforma 🤖 e 🍎 antes de tudo.

---

## ☑️ Checklist de domínio

- [ ] Sei dizer onde ficam `lib/`, `lib/src/`, `bin/` e `test/` e o que vai em cada uma.
- [ ] Explico por que `_privado` é por arquivo, e o que muda ao separar classes.
- [ ] Escolho entre import relativo e `package:` sem hesitar.
- [ ] Escrevo uma fachada com `export` e explico o papel de `lib/src/`.
- [ ] Sei o que `part`/`part of` fazem e por que raramente devo escrevê-los.
- [ ] Leio um `pubspec.yaml` inteiro e explico cada campo.
- [ ] Traduzo `^1.2.3` e `^0.20.2` para intervalos, sem errar a regra do `0.x`.
- [ ] Explico o `pubspec.lock` e digo quando versioná-lo.
- [ ] Rodo `dart pub add`, `dart pub get`, `dart pub outdated` e `dart pub deps` sabendo o que fazem.
- [ ] Avalio um pacote do pub.dev com as 10 perguntas, incluindo suporte a Android **e** iOS.
- [ ] Montei o pacote de 6 arquivos e obtive exatamente a saída esperada.

---

## 📚 Referências oficiais

- [Dart — Libraries e imports](https://dart.dev/language/libraries)
- [Dart — Criando pacotes](https://dart.dev/tools/pub/create-packages)
- [Dart — O arquivo pubspec](https://dart.dev/tools/pub/pubspec)
- [Dart — Versionamento de dependências](https://dart.dev/tools/pub/dependencies)
- [Dart — Versioning e semver](https://dart.dev/tools/pub/versioning)
- [Dart — `dart pub add` e outros comandos](https://dart.dev/tools/pub/cmd)
- [Effective Dart — Style: nomes de arquivos e imports](https://dart.dev/effective-dart/style#libraries)
- [pub.dev — Como a pontuação é calculada](https://pub.dev/help/scoring)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 9 — Extensions](09-extensions.md) | [README](README.md) | [Avaliação do Módulo 03](../../avaliacoes/modulo-03-dart-intermediario.md) |
