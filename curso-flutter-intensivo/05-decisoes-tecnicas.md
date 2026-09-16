# 05 — Decisões Técnicas do Curso

> Todo curso faz escolhas. A maioria esconde essas escolhas do aluno, e o resultado é alguém
> que sabe **usar** uma ferramenta mas não sabe **por que** a usa — e, principalmente, não sabe
> quando trocá-la. Este arquivo registra cada decisão técnica do curso, as alternativas que
> foram descartadas, o motivo, o preço que se paga e o sinal que indica que é hora de rever.

**O que é um ADR.** ADR significa *Architecture Decision Record* — registro de decisão de
arquitetura. É um documento curto que guarda **uma decisão, seu contexto e suas consequências**,
para que meses depois ninguém precise adivinhar por que o código é do jeito que é. Aqui usamos
uma versão simplificada, em tabela.

**Data de verificação de todas as versões e URLs citadas: 2026-09-14.**
As versões de pacote foram consultadas ao vivo na API do pub.dev nessa data, e o ambiente foi
medido nesta máquina (Windows 11 Home Single Language 25H2, build 10.0.26200).
O registro completo dessa verificação está em
[06-relatorio-de-validacao.md](06-relatorio-de-validacao.md).

---

## 1. Quadro geral das decisões (ADR simplificado)

| Decisão | Alternativas consideradas | Por que esta | Consequências | Quando reconsiderar |
|---|---|---|---|---|
| **ADR-01 · Riverpod 3.4.3 sem code generation** | `provider`, `flutter_bloc`, `signals`, Riverpod **com** `riverpod_generator` | `AsyncValue` já modela carregando/erro/dados, que é requisito do curso; não exige `BuildContext` para ler estado, o que elimina uma classe inteira de erro de iniciante; é testável fora da árvore de widgets; é o sucessor oficial do Provider, do mesmo autor. Sem gerador, você lê a declaração inteira do provider na tela — nada fica escondido atrás de um arquivo `.g.dart` | Mais linhas escritas à mão (`NotifierProvider<ContadorNotifier, int>(ContadorNotifier.new)` em vez de uma anotação); em compensação, zero `build_runner`, zero espera de geração, zero arquivo gerado no Git | Quando o projeto passar de ~40 providers e a repetição virar erro de digitação frequente; aí `riverpod_generator` compensa. Também se a equipe já usa BLoC por padrão |
| **ADR-02 · Navigator 1.0 com rotas nomeadas via `onGenerateRoute`; `go_router` como aula opcional** | `go_router ^18.0.1` desde o início, Navigator 2.0 puro (Router API) | Vem dentro do SDK, zero dependência a mais, e ensina a **pilha de navegação de verdade** — que é o que acontece por baixo de qualquer roteador. Quem aprende `go_router` primeiro costuma não saber explicar o que é `pop` | Deep links (*links que abrem uma tela específica do app a partir de fora*) e rotas com URL exigem trabalho manual; navegação aninhada complexa fica verbosa | Quando o app precisar de deep links, de web com URL legível, ou de navegação aninhada por abas com histórico próprio. A aula [07/09](modulos/07-navegacao-e-formularios/09-go-router-opcional.md) existe exatamente para esse momento |
| **ADR-03 · Arquitetura feature-first em 3 camadas** | Camada-first (`lib/models`, `lib/screens`, `lib/services`), MVC, Clean Architecture completa com casos de uso | `lib/features/<feature>/{presentation,domain,data}` mantém junto o que muda junto: mexer em "matérias" abre uma pasta só. As 3 camadas dão o mínimo de separação para testar sem UI, sem o custo de 5 camadas e uma classe de caso de uso por ação | Mais pastas no início do que um app de 3 telas exigiria; exige disciplina para não importar `data` dentro de `presentation` sem passar pelo contrato | Em um app de uma tela só (aí camada-first basta) ou em um sistema grande com regras de negócio densas e várias equipes (aí Clean Architecture completa se paga) |
| **ADR-04 · `package:http ^1.6.0`** | `dio`, `chopper`, `HttpClient` de `dart:io` | Mantido pelo próprio time Dart, API mínima (`get`, `post`, `Response.statusCode`, `Response.body`), e por ser mínima obriga você a escrever timeout, tratamento de erro e desserialização **na mão** — que é justamente o que o curso quer ensinar | Não traz interceptadores, repetição automática nem cancelamento prontos; você escreve isso em [09/06](modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md) | Quando precisar de interceptadores para token, upload com progresso ou cancelamento nativo em vários pontos — aí `dio` economiza código real |
| **ADR-05 · `sqflite` + `shared_preferences` + `flutter_secure_storage`** | `hive`, `isar`, `drift`, `objectbox`, só `shared_preferences` para tudo | Três ferramentas para três problemas diferentes: dado **estruturado e consultável** (matérias, sessões) vai em `sqflite ^2.4.4`; **preferência simples** (meta semanal, tema) vai em `shared_preferences ^2.5.5`; **dado sensível** vai em `flutter_secure_storage ^11.1.1`, que usa Keystore 🤖 e Keychain 🍎. Todos funcionam em Android **e** iOS, e SQL é conhecimento transferível para qualquer stack | Três dependências em vez de uma; você escreve SQL à mão e cuida das migrações | Quando quiser consultas reativas e tipadas sem SQL (`drift` gera isso a partir do schema) ou quando o perfil for de escrita massiva e leitura por chave (`hive`/`isar`) |
| **ADR-06 · `mocktail ^1.0.5` para testes duplos** | `mockito`, escrever fakes à mão sempre | `mocktail` cria dublês (*objetos falsos que substituem dependências reais no teste*) **sem `build_runner`** e sem anotação: você escreve `class MockRepo extends Mock implements Repo {}` e acabou. Mantém a promessa do curso de não depender de geração de código | Não valida em tempo de compilação se o método existe com a assinatura certa, como o `mockito` gerado faria; exige `registerFallbackValue` para tipos não primitivos em `any()` | Se a equipe já padronizou `mockito` com `build_runner` por outros motivos, ou se você quiser verificação estática mais rígida dos dublês |
| **ADR-07 · `flutter_lints ^6.0.0`** | `very_good_analysis`, `lint`, `analysis_options.yaml` escrito do zero | É o conjunto de regras **oficial** do time Flutter, o mesmo que `flutter create` já coloca. Rigor calibrado para quem está aprendendo: pega erro de verdade sem inundar a tela de avisos de estilo que desmotivam | Não força coisas úteis em projeto grande, como documentação obrigatória de API pública ou proibição de `dynamic` | Quando o time crescer e precisar de uniformidade mais dura — aí `very_good_analysis` é o próximo degrau natural |
| **ADR-08 · Material 3** | Material 2 (`useMaterial3: false`), Cupertino em tudo, design system próprio | É o padrão do Flutter 3.47 — `useMaterial3` já vem ligado, então escolher Material 2 seria **remar contra** o SDK. `ColorScheme.fromSeed` gera um tema claro e escuro coerente a partir de uma única cor, o que resolve acessibilidade de contraste sem você calcular nada | Componentes mudaram de nome e de visual em relação a tutoriais antigos (`NavigationBar` no lugar de `BottomNavigationBar`, por exemplo), então material de 2021 na internet confunde | Quando o app precisar seguir a identidade visual rígida de uma marca; aí o tema vira um design system próprio construído **sobre** o Material 3 |
| **ADR-09 · `https://jsonplaceholder.typicode.com` como API de exemplo** | API própria em Node/Dart, `reqres.in`, `dummyjson.com`, Firebase | Público, **sem token**, HTTPS, aceita GET/POST/PUT/PATCH/DELETE e respondeu HTTP 200 na verificação de 2026-09-14. Sem token significa que nenhum aluno fica travado criando conta, e nenhuma chave real precisa aparecer no material | As escritas **não persistem**: o servidor simula a resposta e devolve o objeto criado, mas um GET seguinte não o encontra. Isso precisa ser avisado toda vez que aparecer, ou o aluno acha que o código dele está errado | Quando o curso ganhar um back-end próprio, ou quando você quiser praticar autenticação real com token — cenário coberto em [09/08](modulos/09-consumo-de-api/08-autenticacao-e-tokens.md) |
| **ADR-10 · Identificadores em português** | Tudo em inglês, híbrido (domínio em português, resto em inglês) | Você é brasileiro e está aprendendo dois assuntos ao mesmo tempo: programação móvel **e** vocabulário técnico. `materiaRepositorio.buscarTodas()` custa zero tradução mental; `subjectRepository.findAll()` custa uma tradução a cada leitura. Textos de interface também em português | Difere do que se vê na maioria dos repositórios públicos; misturar-se com a API do Flutter (que é inglesa) gera frases como `Future<List<Materia>> buscarTodas()` | Ao entrar em projeto com equipe internacional ou em código aberto — aí inglês é a convenção. A troca é mecânica, não conceitual |
| **ADR-11 · Ritmo intensivo de 30 dias (4 h/dia, 120 h)** | Muito intensivo (15 dias, 8 h/dia), moderado (60 dias, 2 h/dia) | 120 horas de carga em qualquer ritmo; o que muda é a densidade. Quatro horas por dia cabem em uma rotina real e ainda deixam a noite para o conteúdo assentar — o intervalo entre sessões é parte do aprendizado, não desperdício. Revisões nos dias 7, 14, 21 e 28 combatem o esquecimento antes que ele vire buraco | Exige constância quase diária; faltar três dias seguidos desorganiza o calendário inteiro | Se ao fim de uma semana você concluiu menos de 60% do previsto, troque para o ritmo moderado. Terminar em 60 dias entendendo vale mais que terminar em 30 copiando. Detalhes em [01-plano-intensivo.md](01-plano-intensivo.md) |
| **ADR-12 · Projeto final "Foco: Organizador de Estudos"** | Lista de tarefas, clone de rede social, app de clima, app de finanças | O domínio já é vivido por você — está estudando agora, então sabe o que o app precisa fazer sem inventar requisito. Exige naturalmente persistência estruturada (matérias e sessões), o que **justifica** `sqflite` em vez de forçar; exige estado assíncrono compartilhado, o que justifica Riverpod; exige consumo de API sem token; e cabe em 5 telas, o que cabe no prazo | Não exercita autenticação real nem back-end próprio; o consumo de API fica limitado a leitura de conteúdo público | Depois do curso, ao montar portfólio: aí um projeto com login real e back-end próprio mostra outras competências. Veja [referencias/proximos-passos.md](referencias/proximos-passos.md) |

---

## 2. Detalhamento das decisões mais impactantes

As cinco decisões abaixo são as que mais moldam o código que você vai escrever. Vale entender
cada uma além da linha da tabela.

### ADR-01 · Riverpod 3 sem code generation

**O problema que ela resolve.** Estado é qualquer dado que muda enquanto o app roda e que
precisa aparecer na tela. Quando duas telas precisam do mesmo dado, `setState` deixa de bastar:
o dado precisa morar acima das duas. É esse "morar acima" que uma biblioteca de gerenciamento
de estado organiza.

**O que o curso ensina, na forma manual:**

```dart
// Estado síncrono: um contador.
class ContadorNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void incrementar() => state = state + 1;
}

final contadorProvider =
    NotifierProvider<ContadorNotifier, int>(ContadorNotifier.new);
```

```dart
// Estado assíncrono: uma lista que vem de banco ou de rede.
class TarefasNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async => <String>['Estudar Dart'];

  Future<void> recarregar() async {
    state = const AsyncValue<List<String>>.loading();
    state = await AsyncValue.guard(() async => <String>['Estudar Flutter']);
  }
}

final tarefasProvider =
    AsyncNotifierProvider<TarefasNotifier, List<String>>(TarefasNotifier.new);
```

**O que mudou no Riverpod 3** — e por que material antigo da internet vai te confundir:

| Antes (Riverpod 2 e anteriores) | Agora (Riverpod 3.4.3) |
|---|---|
| `AsyncValue.valueOrNull` | ❌ não existe mais — use `state.value` (`T?`) ou `state.requireValue` |
| `Ref<int>`, `FutureProviderRef` | ✅ `Ref` deixou de ser genérico: escreva só `Ref` |
| `FamilyNotifier`, `AutoDisposeNotifier` | ✅ unificadas em `Notifier` |
| `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` | ❌ movidos para `package:riverpod/legacy.dart` — **este curso não os ensina** |
| Usar um `Notifier` já descartado era silencioso | ✅ agora **lança erro**; use `ref.mounted` depois de um `await` |
| Exceções vazavam cruas | ✅ vêm embrulhadas em `ProviderException` |

**Consequência prática:** qualquer tutorial de Riverpod anterior a 2025 vai mostrar
`StateNotifierProvider`. Se você copiar, não compila. Este curso usa exclusivamente as formas
acima, e explica a diferença em [08/04](modulos/08-estado-e-arquitetura/04-por-que-riverpod.md)
e [08/06](modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md).

---

### ADR-03 · Feature-first em 3 camadas

```text
lib/
├── main.dart                 ← ponto de entrada; só monta o ProviderScope
├── app.dart                  ← MaterialApp, tema e rotas
├── core/                     ← o que é usado por MAIS DE UMA feature
│   ├── constants/            ← valores fixos do app
│   ├── erros/                ← tipos de falha compartilhados
│   ├── rotas/                ← onGenerateRoute central
│   ├── tema/                 ← ThemeData claro e escuro
│   └── widgets/              ← estado vazio, estado de erro, carregando
└── features/
    └── materias/
        ├── domain/           ← o QUE existe: modelo + contrato do repositório
        │                       (não importa Flutter, não importa sqflite)
        ├── data/             ← COMO se obtém: DAO do sqflite, cliente HTTP
        └── presentation/     ← o que APARECE: telas, widgets, controllers
```

**A regra que sustenta tudo:** `presentation` conhece `domain`; `data` conhece `domain`;
`domain` **não conhece ninguém**. É por isso que dá para testar a regra de negócio sem abrir
um emulador, e por isso que trocar `sqflite` por outro banco mexe em uma pasta só.

**Como saber que a regra foi quebrada:** se `materias_controller.dart` importa
`materia_dao.dart` diretamente (em vez do contrato em `domain/`), a camada vazou. O teste vira
refém do banco real.

---

### ADR-05 · Três formas de guardar dados, não uma

| Tipo de dado | Ferramenta | Exemplo no app "Foco" | Por que não outra |
|---|---|---|---|
| Estruturado, consultável, com relações | `sqflite ^2.4.4` | Matérias e sessões de estudo | Consulta por período e soma de minutos em SQL; em chave-valor viraria carregar tudo na memória |
| Preferência simples, um valor por chave | `shared_preferences ^2.5.5` | Meta semanal em minutos, tema escolhido | Criar tabela para guardar um inteiro é desproporcional |
| Sensível (token, segredo) | `flutter_secure_storage ^11.1.1` | Token de exemplo do módulo 09 | `shared_preferences` grava em texto claro; 🤖 Keystore e 🍎 Keychain cifram |
| Arquivo bruto (exportação, cache de imagem) | `path_provider ^2.1.6` + `path ^1.9.1` | Exportar relatório de estudo | Banco não é lugar para arquivo grande |

**Regra fixa do curso para upsert** (*inserir ou substituir se já existir*):

```dart
await db.insert(
  'materias',
  materia.toMap(),
  conflictAlgorithm: ConflictAlgorithm.replace,
);
```

---

### ADR-09 · JSONPlaceholder: o aviso que se repete

A API de exemplo do curso é `https://jsonplaceholder.typicode.com`, verificada online em
**2026-09-14** com resposta HTTP 200.

> ⚠️ **Aviso obrigatório, repetido em toda aula que a usa:** o JSONPlaceholder é uma API
> pública **de testes**. Ele aceita `POST`, `PUT`, `PATCH` e `DELETE` e devolve uma resposta
> convincente, mas **não grava nada de verdade**. Se você criar um recurso e depois buscá-lo,
> ele não estará lá. O servidor **simula** a operação. Seu código não está errado.

Toda chamada de rede do curso segue este contrato mínimo:

```dart
final resposta = await http
    .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
    .timeout(const Duration(seconds: 15));
```

com tratamento explícito de `TimeoutException`, `SocketException` (sem internet) e
`FormatException` (JSON inválido). Detalhado em
[09/06](modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md).

---

### ADR-12 · Por que "Foco" e não uma lista de tarefas

Uma lista de tarefas é o projeto padrão de todo curso, e tem um defeito: ela **não exige**
nada. Cabe em `shared_preferences`, não precisa de estado assíncrono compartilhado e não
justifica arquitetura. O aluno acaba usando `sqflite` e Riverpod porque o professor mandou,
não porque o problema pediu.

O "Foco" foi escolhido porque cada funcionalidade **puxa** uma decisão técnica do curso:

| Funcionalidade | O que ela obriga a usar | Módulo correspondente |
|---|---|---|
| Matérias com CRUD completo | `sqflite`, DAO, contrato de repositório | [10](modulos/10-persistencia-de-dados/README.md), [08](modulos/08-estado-e-arquitetura/README.md) |
| Sessões com cronômetro | `Stream`, ciclo de vida do `State`, `Notifier` | [04](modulos/04-dart-avancado/README.md), [05](modulos/05-introducao-ao-flutter/README.md) |
| Meta semanal | `shared_preferences` | [10](modulos/10-persistencia-de-dados/README.md) |
| Trilhas vindas da API | `http`, `AsyncValue`, estados de carregando/erro/vazio | [09](modulos/09-consumo-de-api/README.md), [06](modulos/06-widgets-e-layouts/README.md) |
| Estatísticas | Cálculo sem travar a interface, acessibilidade | [13](modulos/13-desempenho-e-seguranca/README.md) |
| 5 telas com formulário validado | `Navigator` + `onGenerateRoute`, `Form` | [07](modulos/07-navegacao-e-formularios/README.md) |

**Identidade do app** (fixa, usada em Android e iOS):

| Item | Valor |
|---|---|
| Nome do app | Foco |
| Nome do projeto Flutter | `foco` |
| 🤖 `applicationId` | `br.com.estudos.foco` |
| 🍎 Bundle Identifier | `br.com.estudos.foco` |

---

## 3. Tabela completa de versões oficiais do curso

**Nenhum arquivo do curso pode citar versão diferente destas.**
Todas foram verificadas ao vivo na API do pub.dev em **2026-09-14**.

### 3.1 Ferramentas

| Ferramenta | Versão do curso | Observação |
|---|---|---|
| Flutter SDK | **3.47.1** (canal `stable`) | revision 6655482ec0 · 2026-08-19 |
| Dart SDK | **3.13.1** | vem embutido no Flutter |
| DevTools | 2.60.0 | vem com o Flutter |
| JDK | 17 (Temurin) | exigido pelo Gradle/AGP |
| Git | 2.46+ | medido: 2.46.0.windows.1 |

### 3.2 `dependencies`

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
```

### 3.3 `dev_dependencies`

```yaml
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

### 3.4 Pacotes usados só em módulos específicos

| Pacote | Versão | Onde é usado |
|---|---|---|
| `image_picker` | ^1.2.3 | [Módulo 11](modulos/11-recursos-nativos/README.md) |
| `permission_handler` | ^13.0.2 | [Módulo 11](modulos/11-recursos-nativos/README.md) |
| `go_router` | ^18.0.1 | [Módulo 07, aula opcional](modulos/07-navegacao-e-formularios/09-go-router-opcional.md) |

### 3.5 `environment`

```yaml
environment:
  sdk: ^3.13.0
```

> **O que significa `^`.** O acento circunflexo antes da versão indica "esta versão ou qualquer
> versão compatível mais nova". `^1.6.0` aceita 1.6.1 e 1.7.0, mas **não** aceita 2.0.0 — porque
> mudança de número maior significa quebra de compatibilidade. O arquivo `pubspec.lock`, gerado
> por `flutter pub get`, guarda a versão exata que você realmente baixou.

---

## 4. Regras inegociáveis de segurança no conteúdo

Estas não são "decisões" no sentido de escolha — são limites fixos do material.

| Regra | Como aparece no curso |
|---|---|
| Nunca escrever senha, token, chave privada, `.jks`, `.p12` ou API key reais | Sempre marcadores: `SUA_SENHA_AQUI`, `<sua-senha>`, `COLOQUE_SEU_ALIAS` |
| Segredos nunca vão para o Git | `.gitignore` sempre com `key.properties`, `*.jks`, `*.keystore`, `ios/Runner/*.mobileprovision`, `*.p12`, `*.cer`, `.env` |
| Nenhuma API do curso exige credencial | JSONPlaceholder é público e sem token (ADR-09) |
| Nada de prometer o impossível | O curso **nunca** afirma que você vai gerar IPA no Windows |

Exemplo do arquivo `android/key.properties`, que **nunca** é versionado:

```properties
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=upload
storeFile=C:\\Users\\SEU_USUARIO\\upload-keystore.jks
```

---

## 5. APIs que o curso não usa (e o que usar no lugar)

Decisão transversal: **nenhum exemplo do curso usa API depreciada**. Se você encontrar algo da
coluna da esquerda em um tutorial, ele é antigo.

| ❌ Não use | ✅ Use | Motivo |
|---|---|---|
| `RaisedButton`, `FlatButton`, `OutlineButton` | `ElevatedButton`, `TextButton`, `OutlinedButton` | Removidos do SDK |
| `accentColor` | `ColorScheme` (via `ColorScheme.fromSeed`) | Substituído pelo esquema de cores do Material 3 |
| `textTheme.headline6` | `textTheme.titleLarge` | Nomenclatura do Material 3 |
| `MaterialStateProperty` | `WidgetStateProperty` | Renomeado |
| `StateNotifier`, `ChangeNotifierProvider` (Riverpod) | `Notifier` / `AsyncNotifier` | Movidos para `legacy` no Riverpod 3 |
| `AsyncValue.valueOrNull` | `state.value` ou `state.requireValue` | Removido no Riverpod 3 |
| `WillPopScope` | `PopScope` | Substituído no Flutter 3.12+ |
| `Scaffold.of(context).showSnackBar` | `ScaffoldMessenger.of(context).showSnackBar` | Substituído |
| `print()` em código Flutter | `debugPrint()` | `print()` dispara o lint `avoid_print`. Em Dart puro de terminal (módulos 01 a 04) `print()` é aceitável |

---

## 6. Limitações conhecidas

Estas limitações são reais, foram medidas nesta máquina e **não são disfarçadas em nenhum
momento do curso**. Saber o que você não consegue fazer hoje é parte do plano.

### 6.1 🍎 Sem Mac — impacto e contorno

**O que isso impede.** Compilar para iOS exige Xcode, e Xcode só roda em macOS. Não existe
contorno legal e estável no Windows: máquina virtual com macOS viola os termos de licença da
Apple, e emulação de Xcode não existe.

**Marcos bloqueados hoje** (todos ficam abertos na [trilha de progresso](03-trilha-de-progresso.md)):

- simulador iOS funcionando (quando houver acesso a macOS)
- aplicativo executado em iOS
- build iOS release gerado
- aplicativo executado em iPhone físico
- archive do iOS criado
- IPA exportado (quando aplicável)
- versão preparada para TestFlight

**O que você faz mesmo assim:** o [módulo 15](modulos/15-build-ios/README.md) foi escrito para
ser **compreendido sem executar**. Você aprende a diferença entre certificado e perfil de
provisionamento, o que é um archive, o que o TestFlight faz, e sai sabendo executar o processo
no dia em que tiver o equipamento. As alternativas de acesso a um Mac (emprestado, Mac na nuvem,
compra) são discutidas em [15/01](modulos/15-build-ios/01-por-que-exige-macos.md), com prós e
contras — o curso não recomenda gastar dinheiro antes de você ter concluído o módulo 14.

**Consequência de projeto:** todo o código do app "Foco" é escrito para funcionar nas duas
plataformas (os pacotes escolhidos no ADR-05 suportam Android e iOS), e as diferenças de
comportamento estão catalogadas em
[referencias/diferencas-android-ios.md](referencias/diferencas-android-ios.md).

### 6.2 🤖 Android SDK ainda não instalado

**Estado medido em 2026-09-14:**

```text
[X] Android toolchain - develop for Android devices
    X Unable to locate Android SDK.
```

Android Studio não está instalado e `ANDROID_HOME` está vazio.

**Impacto:** até resolver isso, você não roda o app em emulador nem em aparelho Android, e
nenhum comando `flutter build apk` funciona. Dá para estudar os módulos 01 a 04 (Dart puro) e
até rodar Flutter em `-d windows` para ver a interface, mas os marcos "emulador Android
funcionando", "aplicativo executado em Android" e todos os do módulo 14 dependem disso.

**Quando resolver:** no **Dia 1**, junto com
[02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md). O passo a passo termina com
`flutter doctor -v` mostrando `All Android licenses accepted.` e o checklist de verificação está
em [checklists/ambiente-android.md](checklists/ambiente-android.md).

### 6.3 🪟 Acento no caminho do Flutter SDK

O SDK está hoje em `C:\Users\Usuário\Documents\flutter`. O acento em "Usuário" quebra
ferramentas que não tratam UTF-8. Dois erros **já reproduzidos nesta máquina**:

```text
[☠] Flutter (the doctor check crashed)
    ✗ FileSystemException: Cannot resolve symbolic links,
      path = 'C:\Users\Usu rio\Documents\flutter\bin\flutter'
      (OS Error: O sistema não pode encontrar o caminho especificado, errno = 3)
```

```text
ShaderCompilerException: Shader compilation of
"C:\Users\Usuário\...\ink_sparkle.frag" failed with exit code 1.
'#include' : Included file not found. for header name: flutter/runtime_effect.glsl
```

Além disso, o servidor de análise (`flutter analyze`) encerra com código 255.

**Decisão:** o curso ensina a **mover o SDK** para um caminho sem acento e sem espaço —
recomendado `C:\src\flutter` — e a atualizar o `PATH`. Não há configuração que contorne isso
de forma confiável. Passo a passo em
[02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md) e sintomas catalogados em
[referencias/erros-comuns.md](referencias/erros-comuns.md).

### 6.4 🪟 Modo de Desenvolvedor do Windows desligado

Erro real reproduzido ao rodar `flutter pub add` em um projeto com plugins:

```text
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings. Run
  start ms-settings:developers
to open settings.
```

**Decisão:** ativar o Modo de Desenvolvedor (Configurações → Sistema → Para desenvolvedores)
é passo obrigatório do Dia 1. Sem ele, qualquer projeto com plugin — ou seja, praticamente
todo projeto a partir do módulo 09 — falha ao resolver dependências.

### 6.5 🍎 Conta Apple

Para os marcos de iOS existe um custo e uma decisão que **não** são técnicos:

| Tipo de conta | Custo | O que permite | O que **não** permite |
|---|---|---|---|
| Apple ID gratuito | Sem custo | Rodar no simulador e instalar em iPhone físico seu, com perfil que **expira em 7 dias** | Publicar na App Store, usar TestFlight, notificações push |
| Apple Developer Program | Anuidade paga (consulte o valor vigente no site oficial da Apple) | Archive para distribuição, TestFlight, App Store | — |

O curso **não cita valor de anuidade**, porque preço muda e material com preço desatualizado
engana. A comparação completa está em
[15/06](modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md).

**Recomendação do curso:** não pague nada antes de concluir o módulo 14 e ter um APK release
assinado funcionando. A anuidade só se justifica quando existe um app pronto para distribuir.

### 6.6 Hardware para emulador

O emulador Android é uma máquina virtual completa rodando dentro do seu PC — por isso ele é
pesado. Pontos de atenção medidos em máquinas típicas:

| Fator | O que observar | Se der problema |
|---|---|---|
| Memória RAM | O emulador reserva vários GB; com o VS Code e o Chrome abertos, a máquina pode engasgar | Feche o Chrome durante o desenvolvimento; reduza a RAM da imagem no AVD Manager |
| Virtualização | Precisa estar ligada na BIOS/UEFI; no Windows 11 costuma envolver Hyper-V ou WHPX | Verifique a virtualização na aba Desempenho do Gerenciador de Tarefas |
| Imagem do sistema | Imagens `x86_64` rodam muito mais rápido que `arm64` em PC | Escolha a imagem `x86_64` no AVD Manager |
| Espaço em disco | Android SDK + imagens + builds ocupam dezenas de GB | Instale o SDK em disco com folga; `flutter clean` libera espaço de build |

**Plano B enquanto o emulador não funciona bem:** use um aparelho Android físico via cabo USB,
com Depuração USB ativada. Costuma ser **mais rápido** que o emulador e testa o comportamento
real. Como segunda alternativa, `flutter run -d windows` permite ver a interface e praticar
layout, lembrando que recursos nativos ([módulo 11](modulos/11-recursos-nativos/README.md)) não
se comportam igual no desktop.

---

## 7. Como propor uma mudança nestas decisões

Se ao longo do curso você concluir que uma decisão não serve para o **seu** contexto, faça o
exercício completo antes de trocar — é exatamente esse raciocínio que separa quem escolhe
ferramenta de quem apenas segue tutorial:

1. **Nomeie o problema concreto.** "Riverpod é verboso" não é problema; "declarar 40 providers
   à mão já gerou 3 erros de digitação nesta semana" é.
2. **Liste ao menos duas alternativas** e o que cada uma custa — não só o que ela dá.
3. **Escreva as consequências**, inclusive as ruins. Toda troca tem preço.
4. **Defina o sinal de reversão**: o que precisaria acontecer para você voltar atrás.
5. **Registre** na tabela da seção 1, com um número de ADR novo.

---

## 8. Para onde ir a partir daqui

| Você quer… | Vá para |
|---|---|
| Ver a jornada completa e marcar progresso | [03-trilha-de-progresso.md](03-trilha-de-progresso.md) |
| Descobrir qual aula cobre determinado assunto | [04-mapa-de-aprendizagem.md](04-mapa-de-aprendizagem.md) |
| Conferir como o ambiente foi medido | [06-relatorio-de-validacao.md](06-relatorio-de-validacao.md) |
| Consertar sua máquina agora | [02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md) |
| Entender um termo que apareceu aqui | [referencias/glossario.md](referencias/glossario.md) |
| Ir direto à fonte oficial | [referencias/referencias-oficiais.md](referencias/referencias-oficiais.md) |
| Ver os erros reais desta máquina, com solução | [referencias/erros-comuns.md](referencias/erros-comuns.md) |

---

| ⬅️ Anterior | 🏠 Início | ➡️ Próximo |
|---|---|---|
| [04 — Mapa de aprendizagem](04-mapa-de-aprendizagem.md) | [README](README.md) | [06 — Relatório de validação](06-relatorio-de-validacao.md) |
