# Referência — Links oficiais

> **O que é este arquivo.** A lista curada de fontes **oficiais** deste curso, organizada por
> tema. Cada item traz duas informações que a maioria das listas de links esquece:
> **o que você encontra ali** e **quando faz sentido abrir**.

---

## Por que só documentação oficial

Um curso, um vídeo ou uma resposta de fórum são fotografias de um momento. A documentação
oficial é o **contrato vivo** da ferramenta: quando o time do Flutter muda uma API, quem
atualiza a página é ele mesmo.

Você vai encontrar muito conteúdo desatualizado sobre Flutter, porque a plataforma mudou bastante:

| Coisa que você vai ver por aí | Situação real no Flutter 3.47 |
|---|---|
| `android/app/build.gradle` com sintaxe Groovy | Agora é `android/app/build.gradle.kts`, em **Kotlin DSL** |
| `RaisedButton`, `FlatButton`, `OutlineButton` | Removidos. Use `FilledButton`, `TextButton`, `OutlinedButton` |
| `WillPopScope` | Obsoleto. Use `PopScope<T>` com `onPopInvokedWithResult` |
| `MaterialStateProperty` | Agora é `WidgetStateProperty` |
| `AsyncValue.valueOrNull` (Riverpod) | **Não existe mais.** Use `.value` ou `.requireValue` |
| `StateNotifierProvider`, `ChangeNotifierProvider` (Riverpod) | Foram para `package:riverpod/legacy.dart` |
| "CocoaPods é obrigatório no iOS" | **SPM é o padrão** desde o Flutter 3.44 |
| `Scaffold.of(context).showSnackBar(...)` | Use `ScaffoldMessenger.of(context).showSnackBar(...)` |

**Regra de ouro:** quando um tutorial e a documentação oficial discordarem, a documentação
oficial ganha. Sempre.

---

## 1. 🎯 Como ler documentação oficial sem se perder

Esta seção vale mais do que a lista de links. Documentação oficial é densa de propósito — ela
foi escrita para ser **consultada**, não lida do começo ao fim.

### 1.1 Identifique que tipo de página você abriu

| Tipo | Como reconhecer | Como usar |
|---|---|---|
| **Guia conceitual** | Texto corrido, com diagramas, explica *por quê* | Leia inteiro, uma vez. Ex.: "Understanding constraints" |
| **Tutorial / codelab** | Numerado, "passo 1, passo 2" | Siga digitando, não copiando |
| **Cookbook / receita** | Problema específico + solução curta | Vá direto na receita, copie, adapte |
| **Referência de API** | Lista de classes, construtores, propriedades | **Nunca leia inteira.** Use `Ctrl+F` |
| **Release notes / breaking changes** | Lista por versão | Leia ao atualizar o Flutter |

### 1.2 O roteiro de 5 passos para uma página de API

Exemplo: você abriu `api.flutter.dev` na página de `ListView`.

1. **Leia só o primeiro parágrafo.** Ele responde "para que serve".
2. **Pule para os construtores.** É ali que mora a decisão real: `ListView(...)`,
   `ListView.builder(...)`, `ListView.separated(...)`.
3. **Procure a seção de exemplo**, se houver. A doc do Flutter tem exemplos executáveis.
4. **Use `Ctrl+F`** para o nome da propriedade que você precisa. Não role a página.
5. **Olhe "See also"** no fim. É onde está o widget que você realmente queria.

### 1.3 O que fazer quando a página não responde

| Situação | O que fazer |
|---|---|
| Não sei o nome do widget | Vá ao **catálogo de widgets** e navegue por categoria |
| Sei o nome, quero os detalhes | Vá à **referência de API** |
| Quero resolver uma tarefa concreta | Vá ao **cookbook** |
| Quero entender o modelo mental | Vá aos **guias conceituais** (`docs.flutter.dev/ui`, `/data-and-backend`) |
| A API mudou e meu código quebrou | Vá a **breaking changes** e **release notes** |
| É um pacote de terceiros | Vá ao **pub.dev**, aba **Readme**, depois **Changelog** |

### 1.4 Três hábitos que economizam horas

1. **Confira a versão.** No topo das páginas de pacote do pub.dev há a versão. No Flutter, veja
   se a página fala da sua versão (3.47). Um exemplo de 2021 pode não compilar hoje.
2. **Leia o `Changelog` antes do `Readme`** quando um pacote não funcionar como esperado.
   Frequentemente a resposta é "isso mudou na versão X".
3. **Prefira a busca do próprio site** a uma busca genérica na web. `docs.flutter.dev` e
   `api.flutter.dev` têm busca própria e ela é boa.

### 1.5 Como ler uma assinatura de API do Dart

```dart
ListView.separated({
  Key? key,
  required int itemCount,
  required Widget Function(BuildContext, int) itemBuilder,
  required Widget Function(BuildContext, int) separatorBuilder,
})
```

- `{ }` = **parâmetros nomeados**. Você passa `itemCount: 10`, não só `10`.
- `required` = obrigatório. Sem ele, o código nem compila.
- `Key?` = o `?` significa **pode ser nulo** (*null safety*).
- `Widget Function(BuildContext, int)` = uma **função** que recebe um `BuildContext` e um
  `int` e devolve um `Widget`.

Com isso você consegue ler quase qualquer assinatura do Flutter sem depender de exemplo pronto.

---

## 2. Dart — a linguagem

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://dart.dev> | Porta de entrada: instalação, documentação, novidades da linguagem | Ponto de partida quando não souber por onde começar |
| <https://dart.dev/language> | **Tour da linguagem**: variáveis, tipos, funções, classes, `async`, padrões. É a referência completa da sintaxe | Módulos [01](../modulos/01-logica-e-fundamentos/README.md) a [04](../modulos/04-dart-avancado/README.md), o tempo todo |
| <https://dart.dev/language/variables> | `var`, `final`, `const`, inicialização tardia (`late`) | Aula [02-dart-basico/03-var-final-const.md](../modulos/02-dart-basico/03-var-final-const.md) |
| <https://dart.dev/language/built-in-types> | `int`, `double`, `String`, `bool`, `List`, `Set`, `Map`, `Record` | Aulas de tipos e coleções do módulo 02 |
| <https://dart.dev/language/classes> | Classes, construtores, campos, métodos, `this` | Módulo [03 — Dart intermediário](../modulos/03-dart-intermediario/README.md) |
| <https://dart.dev/language/mixins> | `mixin`, `on`, composição sem herança | Aula [03-dart-intermediario/06-mixins.md](../modulos/03-dart-intermediario/06-mixins.md) |
| <https://dart.dev/language/generics> | Tipos genéricos (`List<T>`, `Future<T>`) e por que eles existem | Aula [03-dart-intermediario/08-generics.md](../modulos/03-dart-intermediario/08-generics.md) |
| <https://dart.dev/language/extension-methods> | `extension`: adicionar métodos a tipos que você não escreveu | Aula [03-dart-intermediario/09-extensions.md](../modulos/03-dart-intermediario/09-extensions.md) |
| <https://dart.dev/language/error-handling> | `try`, `catch`, `on`, `finally`, `throw`, `rethrow` | Aula [04-dart-avancado/01-exceptions.md](../modulos/04-dart-avancado/01-exceptions.md) |
| <https://dart.dev/language/async> | `Future`, `async`/`await`, `Stream`, `await for` | Aulas [04-dart-avancado/02](../modulos/04-dart-avancado/02-futures-e-async-await.md) e [03](../modulos/04-dart-avancado/03-streams.md) |
| <https://dart.dev/language/records> | **Records**: tuplas com tipos, para devolver mais de um valor | Aula [04-dart-avancado/04-records.md](../modulos/04-dart-avancado/04-records.md) |
| <https://dart.dev/language/patterns> | **Patterns**: desestruturação e casamento de padrões | Aula [04-dart-avancado/05-patterns-e-switch.md](../modulos/04-dart-avancado/05-patterns-e-switch.md) |
| <https://dart.dev/language/class-modifiers> | `sealed`, `final`, `base`, `interface` — a base do `switch` exaustivo | Aula [04-dart-avancado/06-sealed-classes.md](../modulos/04-dart-avancado/06-sealed-classes.md) |
| <https://dart.dev/language/isolates> | Isolates: paralelismo real em Dart | Aula [04-dart-avancado/08-isolates-e-desempenho.md](../modulos/04-dart-avancado/08-isolates-e-desempenho.md) |
| <https://dart.dev/null-safety> | Por que existe `?`, `!`, `late` e o que o compilador garante | Aula [02-dart-basico/05-null-safety.md](../modulos/02-dart-basico/05-null-safety.md) |
| <https://dart.dev/codelabs/async-await> | Codelab prático de `async`/`await`, com exercícios no navegador | Depois de ler a teoria de Futures |

### Estilo e qualidade de código

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://dart.dev/effective-dart> | **Effective Dart** — o guia de estilo oficial, dividido em Style, Documentation, Usage e Design | Leia antes do primeiro projeto e revisite a cada módulo |
| <https://dart.dev/effective-dart/style> | Nomes (`lowerCamelCase`, `UpperCamelCase`, `snake_case` de arquivo), formatação, ordem de declarações | Sempre que nomear um arquivo, classe ou variável |
| <https://dart.dev/effective-dart/documentation> | Como escrever comentários `///` úteis | Ao documentar suas classes de domínio |
| <https://dart.dev/effective-dart/usage> | Como usar bem strings, coleções, funções e `async` | Quando o código "funciona mas está feio" |
| <https://dart.dev/effective-dart/design> | Como desenhar APIs: nomes de parâmetro, tipos de retorno, quando usar `extension` | Ao criar o contrato de um repositório |
| <https://dart.dev/tools/linter-rules> | A lista completa de regras de lint, cada uma com exemplo de certo e errado | Quando o `flutter analyze` acusar uma regra que você não conhece |
| <https://dart.dev/tools/dart-format> | O formatador oficial (`dart format`) e suas regras | Aula [04-dart-avancado/07-analise-estatica-e-lints.md](../modulos/04-dart-avancado/07-analise-estatica-e-lints.md) |
| <https://dart.dev/tools/analysis> | Como configurar o `analysis_options.yaml` | Ao apertar as regras do seu projeto |

---

## 3. Flutter — o framework

### Guias principais

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://docs.flutter.dev> | Página inicial da documentação do Flutter | Ponto de partida de tudo |
| <https://docs.flutter.dev/get-started/install/windows> | 🪟 Instalação oficial no Windows, com requisitos e variáveis de ambiente | Módulo [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md) |
| <https://docs.flutter.dev/ui/widgets> | **Catálogo de widgets** — todos os widgets organizados por categoria, com imagem | Sempre que pensar "existe um widget que faz isso?" |
| <https://docs.flutter.dev/cookbook> | **Cookbook** — receitas curtas e completas: listas, formulários, rede, persistência, animação | Quando tiver uma tarefa concreta para resolver |
| <https://docs.flutter.dev/ui/layout> | Como o sistema de layout funciona: `Row`, `Column`, `Expanded`, `Flexible` | Módulo [06 — Widgets e layouts](../modulos/06-widgets-e-layouts/README.md) |
| <https://docs.flutter.dev/ui/layout/constraints> | **Understanding constraints** — a página mais importante do Flutter. "Constraints go down, sizes go up, parent sets position" | Aula [06-widgets-e-layouts/06-constraints.md](../modulos/06-widgets-e-layouts/06-constraints.md). Leia duas vezes |
| <https://docs.flutter.dev/ui/interactivity> | Widgets com estado, gestos, entrada do usuário | Módulo 05 e 06 |
| <https://docs.flutter.dev/ui/navigation> | Navegação, rotas e o `Navigator` | Módulo [07 — Navegação e formulários](../modulos/07-navegacao-e-formularios/README.md) |
| <https://docs.flutter.dev/ui/adaptive-responsive> | Como fazer um app funcionar em telas diferentes e em plataformas diferentes | Aula [06-widgets-e-layouts/11-responsividade.md](../modulos/06-widgets-e-layouts/11-responsividade.md) |
| <https://docs.flutter.dev/ui/accessibility-and-internationalization> | Acessibilidade (leitores de tela, contraste, alvos de toque) e internacionalização | Aula [13-desempenho-e-seguranca/05-acessibilidade.md](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md) |
| <https://docs.flutter.dev/data-and-backend/state-mgmt/intro> | A introdução oficial a gerenciamento de estado, com comparação das abordagens | Módulo [08 — Estado e arquitetura](../modulos/08-estado-e-arquitetura/README.md) |
| <https://docs.flutter.dev/data-and-backend/networking> | Como o Flutter fala com a rede | Módulo [09 — Consumo de API](../modulos/09-consumo-de-api/README.md) |
| <https://docs.flutter.dev/cookbook/persistence/sqlite> | Receita oficial de SQLite com `sqflite` | Módulo [10 — Persistência](../modulos/10-persistencia-de-dados/README.md) |
| <https://docs.flutter.dev/testing> | Testes de unidade, de widget e de integração | Módulo [12 — Testes e debug](../modulos/12-testes-e-debug/README.md) |
| <https://docs.flutter.dev/perf> | Desempenho: rebuilds, jank, boas práticas, como medir | Módulo [13 — Desempenho e segurança](../modulos/13-desempenho-e-seguranca/README.md) |
| <https://docs.flutter.dev/tools/devtools> | **DevTools**: inspetor de widgets, timeline, memória, network | Aula [12-testes-e-debug/03-devtools.md](../modulos/12-testes-e-debug/03-devtools.md) |
| <https://docs.flutter.dev/packages-and-plugins/using-packages> | Como adicionar, versionar e avaliar pacotes | Aula [11-recursos-nativos/10-avaliando-pacotes.md](../modulos/11-recursos-nativos/10-avaliando-pacotes.md) |

### Referência de API

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://api.flutter.dev> | A referência completa de **todas** as classes do Flutter e do Dart usadas por ele | Quando precisar do nome exato de um parâmetro |
| <https://api.flutter.dev/flutter/material/Scaffold-class.html> | `Scaffold`: `appBar`, `body`, `floatingActionButton`, `drawer`, `bottomNavigationBar` | Aula [06-widgets-e-layouts/01-scaffold-e-appbar.md](../modulos/06-widgets-e-layouts/01-scaffold-e-appbar.md) |
| <https://api.flutter.dev/flutter/widgets/ListView-class.html> | Os quatro construtores do `ListView` e quando usar cada um | Aula [06-widgets-e-layouts/09-listas-e-rolagem.md](../modulos/06-widgets-e-layouts/09-listas-e-rolagem.md) |
| <https://api.flutter.dev/flutter/widgets/PopScope-class.html> | `PopScope<T>`, `canPop`, `onPopInvokedWithResult` — o substituto do `WillPopScope` | Aula [11-recursos-nativos/08-botao-voltar-e-gestos.md](../modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md) |
| <https://api.flutter.dev/flutter/material/ThemeData-class.html> | Tudo que compõe um tema: `colorScheme`, `textTheme`, `useMaterial3` | Aula [06-widgets-e-layouts/07-cores-temas-modo-escuro.md](../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) |
| <https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html> | Como gerar uma paleta Material 3 inteira a partir de uma cor semente | Mesma aula acima |
| <https://api.flutter.dev/flutter/widgets/Navigator-class.html> | A pilha de navegação: `push`, `pop`, `pushNamed`, `pushReplacement` | Aula [07-navegacao-e-formularios/01-navigator-a-pilha.md](../modulos/07-navegacao-e-formularios/01-navigator-a-pilha.md) |
| <https://api.flutter.dev/flutter/widgets/Form-class.html> | `Form`, `GlobalKey<FormState>`, `validate()`, `save()` | Aula [07-navegacao-e-formularios/06-formularios.md](../modulos/07-navegacao-e-formularios/06-formularios.md) |
| <https://api.flutter.dev/flutter/cupertino/CupertinoApp-class.html> | O ponto de entrada do visual iOS no Flutter | Aula [11-recursos-nativos/09-material-x-cupertino.md](../modulos/11-recursos-nativos/09-material-x-cupertino.md) |
| <https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html> | `testWidgets`, `WidgetTester`, `find`, `pump`, `pumpAndSettle` | Aula [12-testes-e-debug/06-testes-de-widget.md](../modulos/12-testes-e-debug/06-testes-de-widget.md) |

### Versões, mudanças e ferramentas

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://docs.flutter.dev/release/release-notes> | Notas de cada versão do Flutter, do mais novo para o mais antigo | Antes e depois de rodar `flutter upgrade` |
| <https://docs.flutter.dev/release/breaking-changes> | Lista das mudanças que **quebram** código, com guia de migração | Quando o app parar de compilar depois de atualizar |
| <https://docs.flutter.dev/release/upgrade> | Como atualizar o Flutter e as dependências com segurança | Seção de manutenção de [proximos-passos.md](proximos-passos.md) |
| <https://docs.flutter.dev/reference/flutter-cli> | Referência da linha de comando `flutter` | Complemento de [comandos-uteis.md](comandos-uteis.md) |

### Build e publicação

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://docs.flutter.dev/deployment/android> | 🤖 **Deployment Android**: `applicationId`, ícone, assinatura com keystore, APK × AAB, `flutter build appbundle` | Módulo [14 — Build Android](../modulos/14-build-android/README.md), do começo ao fim |
| <https://docs.flutter.dev/deployment/ios> | 🍎 **Deployment iOS**: Bundle ID, registro no App Store Connect, `flutter build ipa`, arquivamento no Xcode | Módulo [15 — Build iOS](../modulos/15-build-ios/README.md) |
| <https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers> | 🍎 **Swift Package Manager for app developers**: como ligar/desligar o SPM, como o Flutter volta ao CocoaPods, `pod deintegrate` | Aula [15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| <https://docs.flutter.dev/deployment/flavors> | Como criar variantes do app (desenvolvimento, homologação, produção) | Depois do curso, quando precisar de ambientes separados |
| <https://docs.flutter.dev/deployment/obfuscate> | Ofuscação do código Dart no release e o que ela protege (e o que não) | Aula [13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md](../modulos/13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) |

> 🍎 **SÓ NO MAC.** As páginas de deployment iOS descrevem passos que exigem macOS + Xcode.
> No Windows você lê para entender o processo e preparar o projeto; a execução fica para quando
> você tiver acesso a um Mac. Veja
> [15-build-ios/01-por-que-exige-macos.md](../modulos/15-build-ios/01-por-que-exige-macos.md).

---

## 4. Riverpod — gerenciamento de estado do curso

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://riverpod.dev> | Site oficial do Riverpod. No menu superior você chega a *Getting started*, *Essentials*, *Case studies* e *Migration* | Módulo [08 — Estado e arquitetura](../modulos/08-estado-e-arquitetura/README.md) |
| <https://pub.dev/packages/flutter_riverpod> | A página do pacote: versão atual, `Readme`, **`Changelog`** e exemplos | Ao adicionar o pacote e ao investigar uma mudança de API |

**Como navegar o site do Riverpod sem se perder:**

1. *Getting started* → instalação e o primeiro provider.
2. *Essentials* → `Provider`, `FutureProvider`, `Notifier`, `AsyncNotifier`, `family`,
   `autoDispose`, `ref.listen`. É o coração.
3. *Case studies* → exemplos aplicados (cancelamento, paginação, *pull to refresh*).
4. *Migration* → o que mudou da versão 2 para a 3. **Leia isto** se encontrar um tutorial
   antigo.

> ⚠️ **O que o curso usa (Riverpod 3.4.3, sem geração de código):**
>
> ```dart
> class ContadorNotifier extends Notifier<int> {
>   @override
>   int build() => 0;
>   void incrementar() => state = state + 1;
> }
> final contadorProvider =
>     NotifierProvider<ContadorNotifier, int>(ContadorNotifier.new);
> ```
>
> - `Ref` **não é genérico**: escreva `Ref`, nunca `Ref<int>`.
> - `AsyncValue.valueOrNull` **não existe**: use `.value` (é `T?`) ou `.requireValue`.
> - `StateProvider`, `StateNotifierProvider` e `ChangeNotifierProvider` foram para
>   `package:riverpod/legacy.dart` e **não são ensinados** aqui.
> - Depois de um `await` dentro de um `Notifier`, cheque `ref.mounted`.

---

## 5. pub.dev — os pacotes deste curso

O **pub.dev** é o repositório oficial de pacotes Dart e Flutter. Toda página de pacote tem as
mesmas abas: **Readme**, **Changelog**, **Example**, **Installing**, **Versions**, **Scores**.

**Como avaliar um pacote em 60 segundos:**

| Sinal | Onde olhar | O que procura |
|---|---|---|
| Está vivo? | Data da última versão | Atualizado nos últimos meses |
| É popular? | *Likes* e *Downloads* | Muitos usuários = bugs já encontrados |
| Tem qualidade? | *Pub Points* | Perto da nota máxima |
| Suporta o que preciso? | Selos de plataforma | Android, iOS, Web, Windows... |
| Quem mantém? | *Publisher* | `flutter.dev`, `dart.dev` e `tools.flutter.dev` são do próprio time |
| Vai quebrar meu código? | Aba **Changelog** | Procure por "BREAKING" |

### Dependências do projeto final

| Pacote | Versão do curso | Para que serve | Módulo |
|---|---|---|---|
| <https://pub.dev/packages/cupertino_icons> | `^1.0.8` | Os ícones no estilo iOS | [11](../modulos/11-recursos-nativos/09-material-x-cupertino.md) |
| <https://pub.dev/packages/flutter_riverpod> | `^3.4.3` | Gerenciamento de estado | [08](../modulos/08-estado-e-arquitetura/README.md) |
| <https://pub.dev/packages/http> | `^1.6.0` | Cliente HTTP oficial do time Dart | [09](../modulos/09-consumo-de-api/README.md) |
| <https://pub.dev/packages/shared_preferences> | `^2.5.5` | Armazenamento chave-valor simples | [10](../modulos/10-persistencia-de-dados/02-shared-preferences.md) |
| <https://pub.dev/packages/sqflite> | `^2.4.4` | Banco de dados SQLite local | [10](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) |
| <https://pub.dev/packages/path> | `^1.9.1` | Montar caminhos de arquivo de forma portátil (`p.join`) | [10](../modulos/10-persistencia-de-dados/03-arquivos-e-path-provider.md) |
| <https://pub.dev/packages/path_provider> | `^2.1.6` | Descobrir as pastas do app em cada plataforma | [10](../modulos/10-persistencia-de-dados/03-arquivos-e-path-provider.md) |
| <https://pub.dev/packages/intl> | `^0.20.2` | Formatar datas, números e moeda em pt-BR | [09](../modulos/09-consumo-de-api/README.md) e [10](../modulos/10-persistencia-de-dados/README.md) |
| <https://pub.dev/packages/uuid> | `^4.6.0` | Gerar identificadores únicos para as entidades | [10](../modulos/10-persistencia-de-dados/05-sqflite-crud.md) |
| <https://pub.dev/packages/flutter_secure_storage> | `^11.1.1` | Guardar dado sensível no Keystore (🤖) / Keychain (🍎) | [10](../modulos/10-persistencia-de-dados/07-dados-sensiveis.md) |
| <https://pub.dev/packages/connectivity_plus> | `^7.3.1` | Saber se há conexão de rede | [11](../modulos/11-recursos-nativos/05-conectividade.md) |

### Dependências de desenvolvimento

| Pacote | Versão do curso | Para que serve | Módulo |
|---|---|---|---|
| <https://pub.dev/packages/flutter_lints> | `^6.0.0` | O conjunto oficial de regras de lint | [04](../modulos/04-dart-avancado/07-analise-estatica-e-lints.md) |
| <https://pub.dev/packages/mocktail> | `^1.0.5` | Criar dublês de teste **sem** geração de código | [12](../modulos/12-testes-e-debug/07-mocks-e-fakes.md) |
| <https://pub.dev/packages/sqflite_common_ffi> | `^2.4.3` | 🪟 Rodar SQLite no desktop para testar o banco **sem emulador** | [12](../modulos/12-testes-e-debug/05-testes-unitarios.md) |
| <https://pub.dev/packages/flutter_launcher_icons> | `^0.14.4` | Gerar o ícone do app para Android e iOS a partir de um PNG | [14](../modulos/14-build-android/03-icone.md) |
| <https://pub.dev/packages/flutter_native_splash> | `^2.4.8` | Gerar a splash screen nativa das duas plataformas | [14](../modulos/14-build-android/04-splash-screen.md) |

### Pacotes citados em módulos específicos

| Pacote | Versão do curso | Para que serve | Módulo |
|---|---|---|---|
| <https://pub.dev/packages/image_picker> | `^1.2.3` | Escolher foto da câmera ou da galeria | [11](../modulos/11-recursos-nativos/02-camera-e-galeria.md) |
| <https://pub.dev/packages/permission_handler> | `^13.0.2` | Pedir e verificar permissões em tempo de execução | [11](../modulos/11-recursos-nativos/01-permissoes.md) |
| <https://pub.dev/packages/go_router> | `^18.0.1` | Roteamento declarativo (aula **opcional**) | [07](../modulos/07-navegacao-e-formularios/09-go-router-opcional.md) |

### Alternativas citadas para comparação (não ensinadas a fundo)

| Pacote | Por que está aqui |
|---|---|
| <https://pub.dev/packages/provider> | O antecessor do Riverpod, do mesmo autor. Você vai encontrar muito código com ele |
| <https://pub.dev/packages/flutter_bloc> | A abordagem BLoC, muito usada em empresas grandes |
| <https://pub.dev/packages/signals> | Abordagem mais recente, baseada em sinais reativos |
| <https://pub.dev/packages/dio> | Cliente HTTP com interceptadores, cancelamento e mais recursos que o `http` |

A comparação está em
[08-estado-e-arquitetura/04-por-que-riverpod.md](../modulos/08-estado-e-arquitetura/04-por-que-riverpod.md)
e as razões de cada escolha em [05-decisoes-tecnicas.md](../05-decisoes-tecnicas.md).

---

## 6. 🤖 Android — documentação oficial

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://developer.android.com> | Porta de entrada da documentação Android | Qualquer dúvida de plataforma |
| <https://developer.android.com/studio> | Download do Android Studio, requisitos de sistema, notas de versão | Aula [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md) — você **precisa** dele para ter o Android SDK |
| <https://developer.android.com/studio/run/emulator> | Como criar, configurar e acelerar o emulador | Quando o emulador estiver lento ou não abrir |
| <https://developer.android.com/tools/adb> | `adb`: listar aparelhos, instalar APK, ver logs (`adb logcat`) | Aula [12-testes-e-debug/09-depurando-android-e-ios.md](../modulos/12-testes-e-debug/09-depurando-android-e-ios.md) |
| <https://developer.android.com/guide/topics/manifest/manifest-intro> | Tudo sobre o `AndroidManifest.xml`: `<application>`, `<activity>`, `<uses-permission>`, `<queries>` | Aula [14-build-android/05-permissoes-android.md](../modulos/14-build-android/05-permissoes-android.md) |
| <https://developer.android.com/guide/topics/permissions/overview> | O modelo de permissões: normais × perigosas, pedido em tempo de execução, "não perguntar novamente" | Aula [11-recursos-nativos/01-permissoes.md](../modulos/11-recursos-nativos/01-permissoes.md) |
| <https://developer.android.com/build> | Como o Gradle constrói um app Android: `build.gradle.kts`, `buildTypes`, `defaultConfig`, `compileSdk` | Aulas [14-build-android/01](../modulos/14-build-android/01-debug-profile-release.md) e [02](../modulos/14-build-android/02-identidade-do-app.md) |
| <https://developer.android.com/studio/publish/app-signing> | Assinatura de app: keystore, alias, Play App Signing, o que acontece se você perder a chave | Aulas [14-build-android/06](../modulos/14-build-android/06-keystore.md) e [07](../modulos/14-build-android/07-assinatura-no-gradle.md) |
| <https://developer.android.com/guide/app-bundle> | O que é um AAB e por que a Google Play exige esse formato | Aula [14-build-android/08-gerando-apk-e-aab.md](../modulos/14-build-android/08-gerando-apk-e-aab.md) |
| <https://developer.android.com/guide/components/activities/activity-lifecycle> | O ciclo de vida de uma `Activity` — o que está por trás do `AppLifecycleState` do Flutter | Aula [11-recursos-nativos/06-ciclo-de-vida-do-app.md](../modulos/11-recursos-nativos/06-ciclo-de-vida-do-app.md) |
| <https://developer.android.com/guide/topics/data/autobackup> | Auto Backup: o que é salvo na nuvem por padrão e como excluir arquivos sensíveis | Aula [10-persistencia-de-dados/07-dados-sensiveis.md](../modulos/10-persistencia-de-dados/07-dados-sensiveis.md) |
| <https://developer.android.com/about/versions> | O que muda em cada versão do Android, por nível de API | Ao decidir `minSdk` e ao tratar comportamento novo |
| <https://developer.android.com/distribute> | Distribuição na Google Play: preparar, publicar, faixas de teste | Aula [16-publicacao-e-proximos-passos/01-google-play.md](../modulos/16-publicacao-e-proximos-passos/01-google-play.md) |

> 🤖 Referência do curso, medida nesta máquina: Flutter 3.47 gera **AGP 9.1.0**,
> **Kotlin 2.4.0**, **Gradle 9.3.1**, `compileSdk`/`targetSdk` **36**, `minSdk` **24**,
> `ndkVersion` **28.2.13676358** e **Java 17**. Quando a documentação do Android falar de uma
> versão diferente, é porque ela descreve o ecossistema inteiro, não o que o Flutter gerou.

---

## 7. 🍎 Apple / iOS — documentação oficial

> 🍎 **SÓ NO MAC.** Praticamente tudo desta seção descreve tarefas que exigem macOS + Xcode.
> Leia agora para **entender e preparar**; execute quando tiver um Mac.

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://developer.apple.com> | Porta de entrada da documentação e das ferramentas da Apple | Qualquer dúvida de plataforma |
| <https://developer.apple.com/design/human-interface-guidelines> | **Human Interface Guidelines (HIG)** — as diretrizes de design da Apple: navegação, tipografia, ícones, gestos, modo escuro | Aula [11-recursos-nativos/09-material-x-cupertino.md](../modulos/11-recursos-nativos/09-material-x-cupertino.md) |
| <https://developer.apple.com/xcode/> | O que é o Xcode, requisitos e como obter | Aula [15-build-ios/02-xcode-e-cocoapods.md](../modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| <https://developer.apple.com/documentation/xcode> | Documentação do Xcode: alvos, esquemas, arquivamento, assinatura automática | Aula [15-build-ios/08-build-ipa-e-archive.md](../modulos/15-build-ios/08-build-ipa-e-archive.md) |
| <https://developer.apple.com/documentation> | A referência completa das APIs da Apple (UIKit, Foundation, Security/Keychain) | Quando um erro nativo citar uma classe que você não conhece |
| <https://developer.apple.com/account> | Onde ficam **Certificates, Identifiers & Profiles** — certificados, App IDs e provisioning profiles | Aula [15-build-ios/07-certificados-e-provisioning.md](../modulos/15-build-ios/07-certificados-e-provisioning.md) |
| <https://developer.apple.com/programs/> | O **Apple Developer Program**: o que inclui, quem pode assinar, custo anual | Aula [15-build-ios/06-conta-apple-gratuita-x-paga.md](../modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md) |
| <https://developer.apple.com/app-store-connect/> | O painel onde você cria o app, envia builds e gerencia versões | Aula [16-publicacao-e-proximos-passos/02-app-store-connect.md](../modulos/16-publicacao-e-proximos-passos/02-app-store-connect.md) |
| <https://developer.apple.com/testflight/> | **TestFlight**: distribuir builds para testadores internos e externos | Aula [15-build-ios/09-exportando-ipa-e-testflight.md](../modulos/15-build-ios/09-exportando-ipa-e-testflight.md) |
| <https://developer.apple.com/app-store/review/guidelines/> | As **App Review Guidelines** — os critérios pelos quais um app é aprovado ou recusado | Antes de qualquer envio. Leia as seções de privacidade e de funcionalidade mínima |
| <https://developer.apple.com/documentation/swift> | A linguagem Swift — útil para entender `AppDelegate.swift` e `SceneDelegate.swift` | Quando precisar tocar no código nativo |

> 🍎 **Lembretes do curso, validados:** o `flutter create` do 3.47 gera
> `ios/Runner/SceneDelegate.swift` e o bloco `UIApplicationSceneManifest` no `Info.plist`
> (**não remova**); o **Swift Package Manager está ligado por padrão desde o Flutter 3.44**,
> com CocoaPods como alternativa automática; e **o registro do CocoaPods fica somente-leitura
> em 2 de dezembro de 2026**. Abra sempre `ios/Runner.xcworkspace`, nunca o `.xcodeproj`.

---

## 8. Material 3 — o sistema de design

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://m3.material.io> | O site do **Material 3**: fundamentos, estilos e componentes, com exemplos visuais | Módulo [06 — Widgets e layouts](../modulos/06-widgets-e-layouts/README.md) |
| <https://m3.material.io/foundations> | Fundamentos: acessibilidade, layout adaptativo, alvos de toque, movimento | Aulas de responsividade e acessibilidade |
| <https://m3.material.io/styles> | Estilos: cor (papéis como `primary`, `surface`, `onSurface`), tipografia, forma, elevação | Aula [06-widgets-e-layouts/07-cores-temas-modo-escuro.md](../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) |
| <https://m3.material.io/components> | Cada componente (botões, cards, campos de texto, barras) com anatomia e regras de uso | Sempre que for montar uma tela nova |

> 💡 Ligação com o Flutter: os "papéis de cor" que o Material 3 descreve (`primary`,
> `secondary`, `surface`, `error`, `onPrimary`…) são exatamente os campos de `ColorScheme`.
> Quando você escreve `ColorScheme.fromSeed(seedColor: Colors.indigo)`, o Flutter gera todos
> esses papéis seguindo o algoritmo do Material 3. No Flutter 3.47, `useMaterial3` já é o
> padrão — você não precisa ligar nada.

---

## 9. Git e GitHub

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://git-scm.com> | Site oficial do Git: downloads e documentação | Módulo [00 — Git e terminal](../modulos/00-git-e-terminal/README.md) |
| <https://git-scm.com/downloads> | Instalador do Git para Windows, macOS e Linux | Aula [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md) |
| <https://git-scm.com/doc> | Manual de referência de **todos** os comandos, mais o livro Pro Git | Quando a opção de um comando não estiver clara |
| <https://git-scm.com/book/pt-br/v2> | **Pro Git em português do Brasil**, o livro oficial, gratuito e completo | Leitura de fundo do módulo 00 |
| <https://git-scm.com/docs/gitignore> | A sintaxe exata do `.gitignore`: padrões, negação com `!`, pastas | Aula [00-git-e-terminal/04-commits-branches-gitignore.md](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md) |
| <https://docs.github.com> | Documentação do GitHub | Ao publicar seu portfólio |
| <https://docs.github.com/pt> | A mesma documentação, **em português** | Preferencial para você |
| <https://docs.github.com/en/get-started> | Criar conta, criar repositório, primeiro push | Aula [00-git-e-terminal/03-git-o-que-e.md](../modulos/00-git-e-terminal/03-git-o-que-e.md) |
| <https://docs.github.com/en/authentication> | Autenticação: token de acesso pessoal, chave SSH | Quando o `git push` pedir senha e recusar a sua |
| <https://docs.github.com/en/pull-requests> | *Pull requests*, revisão de código, resolução de conflitos | Quando for contribuir com código aberto |
| <https://docs.github.com/en/actions> | **GitHub Actions**: automatizar `flutter analyze`, `flutter test` e builds | Aula [16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md](../modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md) |

> 🔴 Antes do primeiro `git push`, confira que `android/key.properties`, `*.jks`, `*.keystore`,
> `ios/Runner/*.mobileprovision`, `*.p12`, `*.cer` e `.env` estão no `.gitignore`. Um segredo
> que entra no histórico do Git **continua lá** mesmo depois de você apagar o arquivo. A aula
> [00-git-e-terminal/05-desfazendo-erros-e-segredos.md](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md)
> trata exatamente disso.

---

## 10. SQLite — o banco local

O `sqflite` é um invólucro Dart em volta do **SQLite**, que é o banco de dados de verdade. Toda
dúvida de SQL vai para o site do SQLite, não para o do pacote.

| Link | O que você encontra | Quando consultar |
|---|---|---|
| <https://sqlite.org> | Site oficial do SQLite | Qualquer dúvida de SQL ou de comportamento do banco |
| <https://sqlite.org/whentouse.html> | *Appropriate Uses For SQLite* — quando SQLite é a escolha certa e quando não é | Aula [10-persistencia-de-dados/01-qual-armazenamento-usar.md](../modulos/10-persistencia-de-dados/01-qual-armazenamento-usar.md) |
| <https://sqlite.org/lang.html> | A sintaxe completa de SQL aceita: `CREATE TABLE`, `SELECT`, `INSERT`, `ALTER TABLE` | Aulas [10-persistencia-de-dados/04](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) e [05](../modulos/10-persistencia-de-dados/05-sqflite-crud.md) |
| <https://sqlite.org/datatype3.html> | O sistema de tipos do SQLite — por que existe `TEXT`, `INTEGER`, `REAL` e por que **não existe** um tipo booleano nem de data | Ao modelar a tabela de matérias e sessões |
| <https://sqlite.org/lang_select.html> | `SELECT` em detalhe: `WHERE`, `ORDER BY`, `GROUP BY`, `LIMIT` | Aula de CRUD e a de estatísticas |
| <https://sqlite.org/pragma.html> | Comandos `PRAGMA`, incluindo `PRAGMA table_info` e `PRAGMA user_version` | Aula [10-persistencia-de-dados/06-migracoes.md](../modulos/10-persistencia-de-dados/06-migracoes.md) |
| <https://sqlite.org/lang_transaction.html> | Transações: `BEGIN`, `COMMIT`, `ROLLBACK` — a base do `batch` do sqflite | Aula de CRUD |
| <https://sqlite.org/datatype3.html#collating_sequences> | **Collation** (sequência de comparação de texto): `BINARY`, `NOCASE`, `RTRIM` | 🔴 Leia junto com o aviso abaixo |

> 🔴 **O bug de português que o curso comprova com teste.** O SQLite compara texto **byte a
> byte**. Em UTF-8, `F` = `0x46` e `Á` = `0xC3 0x81`. Logo, para o SQLite,
> `'Física' < 'Álgebra'`, e um `ORDER BY nome ASC` devolve **Física antes de Álgebra**.
> O `COLLATE NOCASE` **não resolve**, porque ele só entende ASCII. A solução ensinada é uma
> coluna `nome_ordenacao` com o texto normalizado (sem acento, minúsculo) e um índice sobre
> ela. Está em
> [10-persistencia-de-dados/05-sqflite-crud.md](../modulos/10-persistencia-de-dados/05-sqflite-crud.md).

---

## 11. API pública usada no curso

| Link | O que é | Como o curso usa |
|---|---|---|
| <https://jsonplaceholder.typicode.com> | Uma API REST pública, gratuita, sem token, em HTTPS, que devolve dados de exemplo (`/posts`, `/todos`, `/users`) | É a fonte das "trilhas de estudo compartilhadas" do app **Foco** |

Requisições confirmadas em 2026-09-14:

| Requisição | Resposta real |
|---|---|
| `GET https://jsonplaceholder.typicode.com/todos/1` | `200` · `{"userId":1,"id":1,"title":"delectus aut autem","completed":false}` |
| `GET https://jsonplaceholder.typicode.com/posts` | `200` · 100 itens |
| `POST https://jsonplaceholder.typicode.com/todos` | `201` · devolve o objeto com `"id": 201` |

> ⚠️ **As escritas não persistem.** O servidor **finge** que salvou e devolve uma resposta
> realista. Isso é ótimo para você exercitar o ciclo HTTP completo (`POST`, `PUT`, `PATCH`,
> `DELETE`) sem precisar de servidor próprio nem de token — mas se você recarregar a lista, o
> item novo não estará lá. **Isso não é bug no seu código.**

---

## 12. Mapa rápido: "eu tenho esta dúvida, abro qual link?"

| Sua dúvida | Abra |
|---|---|
| "Como escreve isso em Dart?" | <https://dart.dev/language> |
| "Este nome de variável está no padrão?" | <https://dart.dev/effective-dart/style> |
| "O que essa regra de lint quer dizer?" | <https://dart.dev/tools/linter-rules> |
| "Qual widget faz X?" | <https://docs.flutter.dev/ui/widgets> |
| "Quais parâmetros esse widget aceita?" | <https://api.flutter.dev> |
| "Como faço essa tarefa específica?" | <https://docs.flutter.dev/cookbook> |
| "Por que meu layout estourou?" | <https://docs.flutter.dev/ui/layout/constraints> |
| "Meu app está travando/lento" | <https://docs.flutter.dev/perf> e <https://docs.flutter.dev/tools/devtools> |
| "Como usar esse provider do Riverpod?" | <https://riverpod.dev> |
| "Esse pacote é confiável?" | <https://pub.dev> (Pub Points, Likes, Publisher, Changelog) |
| "Como assino o APK?" | <https://docs.flutter.dev/deployment/android> |
| "Onde declaro essa permissão Android?" | <https://developer.android.com/guide/topics/permissions/overview> |
| "Como publico na App Store?" | <https://docs.flutter.dev/deployment/ios> |
| "Meu app iOS foi rejeitado, por quê?" | <https://developer.apple.com/app-store/review/guidelines/> |
| "Como é o padrão visual do iOS?" | <https://developer.apple.com/design/human-interface-guidelines> |
| "Qual cor uso para esse elemento?" | <https://m3.material.io/styles> |
| "Como desfaço esse commit?" | <https://git-scm.com/doc> |
| "Como escrevo esse SELECT?" | <https://sqlite.org/lang_select.html> |
| "Atualizei o Flutter e quebrou" | <https://docs.flutter.dev/release/breaking-changes> |

---

## 13. O que NÃO usar como fonte primária

Nada disto está proibido — todos ajudam. Mas nenhum substitui a documentação oficial, e todos
envelhecem mais rápido que ela.

| Fonte | Bom para | Cuidado |
|---|---|---|
| Vídeos de YouTube | Ver alguém construindo do zero | Verifique a data. Um vídeo de 3 anos usa APIs removidas |
| Respostas de fórum | Erros específicos com mensagem literal | A resposta mais votada costuma ser a mais **antiga**, não a mais correta |
| Blogs e artigos | Arquitetura, opinião, comparações | Confirme cada API citada na doc oficial antes de adotar |
| Assistentes de IA | Explicar um conceito, revisar um trecho | Podem inventar nomes de API e versões. **Sempre** confirme no `api.flutter.dev` |
| Código de repositórios | Ver decisões reais em projeto grande | Veja a data do último commit e o `pubspec.yaml` |

**Teste de sanidade, sempre disponível:** se você tem dúvida se uma API existe, abra
<https://api.flutter.dev> e busque o nome. Se não aparecer, ela não existe (ou foi removida).
E `flutter analyze` na sua máquina responde em segundos.

---

## ☑️ Checklist de domínio

- [ ] Sei a diferença entre guia conceitual, cookbook e referência de API — e sei qual abrir.
- [ ] Leio uma assinatura de API do Dart e identifico parâmetros nomeados, obrigatórios e anuláveis.
- [ ] Sei avaliar um pacote no pub.dev olhando Pub Points, Likes, Publisher e Changelog.
- [ ] Sei onde fica a documentação de deployment de cada plataforma.
- [ ] Sei que o SPM é o padrão do Flutter desde a 3.44 e onde ler sobre isso.
- [ ] Antes de atualizar o Flutter, abro release notes e breaking changes.
- [ ] Quando um tutorial contradiz a documentação oficial, sigo a documentação oficial.

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [Diferenças Android × iOS](diferencas-android-ios.md) | [README do curso](../README.md) | [Próximos passos](proximos-passos.md) |
