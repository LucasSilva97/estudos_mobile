# Aula 1 — Como o Flutter funciona

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar que o Flutter **pinta os próprios pixels** e não usa os componentes visuais do sistema
  operacional — e listar uma vantagem e uma desvantagem concretas disso.
- Descrever as três camadas do Flutter (framework, engine, embedder) e o que cada uma faz.
- Diferenciar **Impeller** de **Skia** e dizer qual está em uso em cada plataforma no Flutter 3.47.1.
- Explicar por que o Dart é compilado em **JIT** no modo debug e em **AOT** no modo release, e por
  que é exatamente isso que torna o **hot reload** possível.
- Comparar Flutter com **React Native** e com **nativo puro** sem propaganda: o que se ganha e o
  que se perde em cada caminho.
- Definir o que é um **widget** e por que ele é descartável e barato.

## ✅ Pré-requisitos

- [Módulo 01 — Aula 02: Dart e Flutter](../01-logica-e-fundamentos/02-dart-e-flutter.md) — você já
  sabe que o Dart é a linguagem e o Flutter é o kit de interface.
- [Módulo 03 — Aula 01: Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md) —
  um widget é uma classe.
- Flutter 3.47.1 instalado e `flutter doctor` com `[✓] Flutter` e `[✓] Chrome`, conforme
  [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

---

## 📖 Conceito

### O que o Flutter realmente faz

Quando você escreve um app para Android com Kotlin, você pede ao sistema: *"me dê um botão"*.
O Android devolve um `Button` — um componente desenhado pelo próprio sistema, com a aparência da
versão do Android que estiver naquele aparelho. No iPhone, com Swift, você pede um `UIButton`, e a
Apple desenha.

O Flutter **não pede nada disso**. O Flutter pede ao sistema operacional uma única coisa:

> "Me dê uma **superfície de desenho** (uma área retangular de pixels) e me avise quando o dedo
> tocar nela."

Tudo o que aparece dentro dessa área — botão, texto, sombra, animação, barra de rolagem — é
desenhado pelo Flutter, linha por linha, a partir do zero. O botão do Flutter **não é** um `Button`
do Android. É uma imagem de um botão, pintada 60 ou 120 vezes por segundo, que reage ao toque
porque o Flutter calculou que o toque caiu dentro do retângulo dele.

Essa é a decisão fundadora do Flutter, e dela derivam praticamente todas as suas vantagens e todos
os seus defeitos.

**O que você ganha:**

1. **Aparência idêntica em todo lugar.** O mesmo código produz o mesmo pixel no Android 7 e no
   Android 16, no iPhone e no Chrome. Você não descobre em produção que o botão ficou torto em uma
   versão específica do sistema.
2. **Controle total.** Se o designer pedir um botão com cantos arredondados só de um lado e uma
   sombra roxa, você faz. Não existe "o sistema não deixa".
3. **Um código, muitas plataformas.** Android, iOS, web, Windows, macOS, Linux.
4. **Atualizações do sistema não quebram a sua tela**, porque a sua tela não depende dos
   componentes do sistema.

**O que você perde:**

1. **O app não herda de graça a aparência nativa.** Se o iOS 27 mudar o estilo dos botões, o seu app
   Flutter continua igual até você atualizar o Flutter e o seu código.
2. **Tamanho do app.** O motor gráfico vai junto no pacote. Um app Flutter "Olá mundo" ocupa alguns
   megabytes a mais que o equivalente nativo.
3. **Acessibilidade e texto exigem ponte.** Como os widgets não são componentes do sistema, o
   Flutter precisa descrever a árvore para o leitor de tela (TalkBack no Android, VoiceOver no iOS)
   através de uma camada chamada *semantics*. Funciona, mas é você quem precisa preencher rótulos.
4. **Recurso muito específico de plataforma** (pagamento nativo, sensor incomum) exige um *plugin*
   — código Kotlin/Swift embrulhado em uma interface Dart.

### As três camadas

O Flutter é dividido em três camadas empilhadas. Saber isso ajuda a ler mensagens de erro: o texto
do erro quase sempre denuncia a camada de onde ele veio.

```text
┌─────────────────────────────────────────────────────────┐
│  SEU CÓDIGO (Dart)                                      │
│  main.dart, widgets, telas                              │
├─────────────────────────────────────────────────────────┤
│  FRAMEWORK (Dart) — é o que você importa                │
│  material.dart, cupertino.dart, widgets.dart,           │
│  rendering, painting, animation, gestures, foundation   │
├─────────────────────────────────────────────────────────┤
│  ENGINE (C++ / Rust) — o motor                          │
│  Impeller ou Skia (desenho), Dart VM, texto, imagens    │
├─────────────────────────────────────────────────────────┤
│  EMBEDDER (Kotlin / Swift / C++) — o encaixe            │
│  pede a janela ao SO, entrega toques, ciclo de vida     │
├─────────────────────────────────────────────────────────┤
│  SISTEMA OPERACIONAL  🤖 Android · 🍎 iOS · 🪟 Windows   │
└─────────────────────────────────────────────────────────┘
```

- **Framework** — escrito em Dart, é a parte que você lê e usa: `Text`, `Column`, `Scaffold`,
  `Navigator`. É *open source* e você pode abrir o código-fonte dele no seu computador (está dentro
  de `C:\src\flutter\packages\flutter\lib\src`).
- **Engine** (*motor*) — escrita em C++ (com partes em Rust), é a que transforma "desenhe um
  retângulo vermelho com canto arredondado" em pixels de verdade. Também é ela que hospeda a
  **Dart VM** (*Virtual Machine* — máquina virtual: o programa que executa código Dart).
- **Embedder** (*encaixe*) — a casca específica de cada plataforma. 🤖 No Android é código Kotlin
  que cria uma `Activity`. 🍎 No iOS é Swift que cria um `UIViewController`. 🪟 No Windows é C++ que
  cria uma janela Win32. É o embedder que você vê quando abre a pasta `android/` ou `ios/` do seu
  projeto (aula 2).

### Impeller × Skia — quem desenha

Dentro da engine existe um **renderizador** (*renderer* — o componente que converte instruções de
desenho em pixels). O Flutter teve dois:

| | **Skia** | **Impeller** |
|---|---|---|
| Idade | Biblioteca antiga do Google, usada também no Chrome | Escrito especificamente para o Flutter |
| Como prepara os efeitos | Compila *shaders* (*sombreadores* — pequenos programas que rodam na placa de vídeo) **durante a execução**, na hora em que a tela precisa deles | Compila **todos os shaders antes**, na hora do build |
| Sintoma para o usuário | Engasgos na **primeira** vez que uma animação aparece (*jank* de primeiro frame) | Animação suave desde o primeiro frame |
| API gráfica | OpenGL / Metal / Vulkan | Vulkan (🤖 Android), Metal (🍎 iOS), OpenGL como alternativa |

O problema que o Impeller resolve é real e tinha nome: **shader compilation jank**. Com o Skia, a
primeira vez que uma transição de tela acontecia, a placa de vídeo precisava compilar o shader
naquele instante — e o app travava por algumas dezenas de milissegundos. Como isso só acontecia na
primeira execução, era difícil de reproduzir e muito fácil de culpar o aparelho do usuário.

**No Flutter 3.47.1:**

- 🍎 **iOS** — Impeller (com Metal). É o padrão desde o Flutter 3.10.
- 🤖 **Android** — Impeller (com Vulkan) é o padrão. Aparelhos sem suporte adequado a Vulkan caem
  automaticamente para o caminho antigo com Skia. Você não precisa configurar nada.
- 🪟 **Windows desktop** e **web** — o Skia ainda é o renderizador padrão nesta versão. Na web ele
  aparece com o nome **CanvasKit**, que é o Skia compilado para WebAssembly.

Se precisar testar a diferença, existe uma flag de linha de comando:

```powershell
flutter run --no-enable-impeller
```

Você provavelmente nunca vai usar isso no dia a dia — mas vai encontrar essa flag em relatos de bug
na internet, e agora sabe o que ela significa.

> 📌 **Guarde:** *engine* é o motor inteiro; *Impeller* e *Skia* são apenas o pedaço do motor que
> pinta. Confundir os dois é o erro de vocabulário mais comum de quem está começando.

### JIT × AOT — por que existe hot reload

O Dart é uma linguagem com duas formas de virar programa executável. Isso é raro e é a base de
tudo que torna o Flutter agradável de desenvolver.

**JIT** (*Just-In-Time* — "bem na hora"): o código é traduzido para instruções de máquina
**enquanto o programa roda**. É o que acontece no **modo debug**.

**AOT** (*Ahead-Of-Time* — "antes da hora"): o código é traduzido para instruções de máquina
**antes**, durante o build, e o app já sai pronto. É o que acontece no **modo release**.

| | Debug (JIT) | Release (AOT) |
|---|---|---|
| Comando | `flutter run` | `flutter run --release` / `flutter build apk --release` |
| Compilação | na hora, dentro da Dart VM | antes, no seu computador |
| Hot reload | ✅ funciona | ❌ impossível |
| Velocidade de execução | mais lenta | rápida |
| Tamanho do app | maior | menor |
| `assert()` e checagens extras | ligados | desligados |
| Serve para medir desempenho? | **Não** | Sim |

O hot reload funciona assim: você salva o arquivo, a ferramenta calcula **só o que mudou**, compila
esses trechos e **injeta as novas versões das classes dentro da Dart VM que já está rodando**.
Depois pede ao Flutter para reconstruir a árvore de widgets. O app não reinicia; o estado que estava
na memória continua lá.

Isso só é possível porque, no modo debug, a VM está interpretando/compilando código **enquanto
roda** — ou seja, ela sabe trocar uma função por outra. No release, o código virou instruções de
máquina fixas dentro do binário: não há como trocar nada sem reconstruir o app inteiro.

> ⚠️ Consequência prática que muita gente descobre tarde: **nunca julgue o desempenho do seu app no
> modo debug.** Uma lista que "engasga" no debug costuma rolar de forma perfeitamente suave no
> release. Isso é tratado em
> [13 — Medindo desempenho](../13-desempenho-e-seguranca/04-medindo-desempenho.md).

### Flutter × React Native × nativo puro — comparação honesta

| Critério | **Flutter** | **React Native** | **Nativo puro** (Kotlin + Swift) |
|---|---|---|---|
| Linguagem | Dart | JavaScript / TypeScript | Kotlin (🤖) e Swift (🍎) |
| O que desenha | pixels próprios | componentes **reais** do sistema | componentes do sistema |
| Aparência nativa automática | não | sim | sim |
| Consistência entre plataformas | altíssima | média (cada plataforma renderiza do seu jeito) | nenhuma (você escreve duas vezes) |
| Bases de código | 1 | 1 | 2 |
| Acesso a recurso novo do SO | precisa de plugin | precisa de módulo nativo | imediato |
| Tamanho do app | maior | maior | menor |
| Curva de entrada | média (linguagem nova) | baixa para quem já sabe JS | alta (duas plataformas) |
| Animações complexas | ponto forte | historicamente ponto fraco | ponto forte |
| Maturidade do ecossistema de pacotes | boa | muito boa | máxima |

**Quando o Flutter é a escolha certa:** app com identidade visual própria e forte, equipe pequena,
prazo curto, necessidade de Android + iOS com comportamento idêntico, muita animação e transição.
É o caso do projeto final deste curso.

**Quando o React Native é a escolha certa:** a empresa já é toda JavaScript/TypeScript, o app
precisa parecer nativo por padrão, e a equipe web pode virar equipe mobile sem aprender linguagem
nova.

**Quando nativo puro é a escolha certa:** o app é o produto principal da empresa, precisa do recurso
do sistema no dia em que ele sai, exige desempenho extremo (câmera profissional, jogo, edição de
vídeo), ou é tão pequeno de um lado só que não compensa a camada extra.

Não existe vencedor universal. O que existe é escolha consciente. A decisão deste curso está em
[05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md).

### O que é um widget

Um **widget** é uma **descrição imutável de um pedaço da interface**. Não é o pedaço da interface —
é a receita dele.

Três características que definem tudo:

1. **É imutável.** Depois de criado, nenhum campo muda. Para mudar a tela, você cria widgets novos.
2. **É barato.** Criar milhares de widgets por segundo é normal e esperado. Eles são objetos Dart
   pequenos; não são views do sistema.
3. **É composto.** Um `Scaffold` não é um objeto gigante com cem propriedades: é um widget que
   contém um `AppBar`, que contém um `Text`, que contém um estilo. Você monta interface **encaixando
   widgets dentro de widgets**, como blocos de montar.

No Flutter, **tudo** é widget: o texto é `Text`, o espaçamento é `Padding`, o alinhamento é
`Center`, a cor de fundo é `Container` ou `ColoredBox`, e até a tela inteira é `MaterialApp`.

---

## 💡 Analogia

Pense em duas formas de colocar uma vitrine na rua.

**Nativo e React Native** alugam as prateleiras da loja. As prateleiras já vêm prontas, com a
aparência daquele shopping. Se o shopping trocar as prateleiras, a sua vitrine muda sozinha — para
melhor ou para pior, e você não decide.

**Flutter** aluga apenas **a parede vazia** e pinta a vitrine inteira nela. Você desenha cada
prateleira. Ela fica idêntica em qualquer shopping do mundo. Em troca, você carrega os pincéis
(o motor gráfico, que pesa alguns megabytes) e, quando o shopping moderniza as prateleiras, a sua
pintura continua a mesma até você repintar.

A analogia cobre também o JIT × AOT: no **debug**, você está com o pincel na mão e repinta um
detalhe em segundos (hot reload). No **release**, a vitrine já foi impressa em placa acrílica —
fica muito mais bonita e resistente, mas para mudar uma vírgula é preciso imprimir tudo de novo.

---

## 🧪 Exemplo mínimo

Este é o menor app Flutter possível que ainda faz sentido. Ele não usa Material, não usa Scaffold:
é só o framework desenhando uma frase.

```dart
import 'package:flutter/widgets.dart';

void main() {
  runApp(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Text('Este texto foi pintado pelo Flutter, não pelo sistema.'),
      ),
    ),
  );
}
```

Três coisas para reparar:

- `runApp` recebe **um único widget** e o coloca na raiz da árvore.
- `Directionality` é obrigatório porque `Text` precisa saber se o idioma escreve da esquerda para a
  direita (`ltr`, *left-to-right*) ou da direita para a esquerda (`rtl`). Quando você usa
  `MaterialApp` (aula 3), ele fornece isso automaticamente e você nunca mais escreve essa linha.
- Não há nenhuma chamada tipo `criarBotaoDoAndroid()`. Você descreve; a engine pinta.

---

## 📱 Aplicando no Flutter

Agora você vai ver esse comportamento com os próprios olhos. Crie o projeto que vai acompanhar o
módulo inteiro e rode-o no Chrome.

Escolha uma pasta **sem acentos e sem espaços** para os seus projetos. Se ainda não tiver uma:

```powershell
New-Item -ItemType Directory -Force C:\src\projetos
Set-Location C:\src\projetos
```

> 🪟 **Windows.** Use `C:\src\projetos`, não a Área de Trabalho nem `C:\Users\Usuário\...`.
> O acento em "Usuário" já quebrou o `flutter doctor` nesta máquina, com o erro
> `FileSystemException: Cannot resolve symbolic links`. O mesmo problema derruba o compilador de
> shaders. Detalhes em [referencias/erros-comuns.md](../../referencias/erros-comuns.md).

Crie o projeto:

```powershell
flutter create meu_primeiro_app
Set-Location meu_primeiro_app
```

O comando demora alguns segundos e termina com uma mensagem parecida com esta:

```text
All done!
You can find general documentation for Flutter at: https://docs.flutter.dev/
...
In order to run your application, type:

  $ cd meu_primeiro_app
  $ flutter run
```

A pasta inteira é explicada na [aula 2](02-estrutura-do-projeto.md). Por enquanto, só abra o arquivo
`lib\main.dart` e substitua **todo** o conteúdo pelo código da próxima seção.

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/lib/main.dart`
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const ProvaDePixels());
}

/// Tela única cujo objetivo é provar um ponto: nada aqui é um componente do
/// sistema operacional. Tudo é desenhado pelo motor gráfico do Flutter.
class ProvaDePixels extends StatelessWidget {
  const ProvaDePixels({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prova de pixels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: const _TelaProva(),
    );
  }
}

class _TelaProva extends StatelessWidget {
  const _TelaProva();

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) lê o tema que o MaterialApp acima instalou na árvore.
    // A aula 7 explica em detalhe o que é esse "context".
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Como o Flutter funciona'),
        backgroundColor: cores.primaryContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Um "botão" que é apenas um retângulo pintado pelo Flutter.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: cores.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: cores.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'Isto NÃO é um botão do Android',
                  style: TextStyle(
                    color: cores.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cada pixel acima foi desenhado pelo motor gráfico do Flutter '
                '(Impeller no celular, Skia no navegador). O sistema '
                'operacional só emprestou a área da tela.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Este sim é um botão de verdade do Material 3 — mas continua
              // sendo pintado pelo Flutter, não pelo sistema.
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Toque detectado pelo próprio Flutter.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.touch_app),
                label: const Text('Tocar aqui'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Rode:

```powershell
flutter run -d chrome
```

Na primeira execução o Flutter baixa dependências e compila; pode levar um ou dois minutos. Depois
disso, o Chrome abre com o app.

---

## 🔍 Explicando o código

| Trecho | O que faz |
|---|---|
| `import 'package:flutter/material.dart';` | Traz todo o conjunto de widgets do Material Design 3. É o único import necessário na maioria dos arquivos de tela. |
| `void main()` | Ponto de entrada do programa, igual ao que você já usava no Dart de terminal ([módulo 02, aula 1](../02-dart-basico/01-anatomia-de-um-programa.md)). A diferença é o que está dentro dele. |
| `runApp(const ProvaDePixels())` | Entrega o widget raiz ao Flutter. A partir daqui o framework assume o controle e passa a desenhar quadro a quadro. |
| `extends StatelessWidget` | Declara um widget **sem estado**: ele descreve a tela a partir apenas dos seus parâmetros. Detalhado na [aula 4](04-statelesswidget.md). |
| `const ProvaDePixels({super.key})` | Construtor `const` (o objeto pode ser criado em tempo de compilação e reaproveitado) que repassa o parâmetro `key` para a superclasse. `super.key` é a forma moderna, e é obrigatória no padrão deste curso. |
| `@override Widget build(BuildContext context)` | O método que o Flutter chama para perguntar *"como você quer aparecer agora?"*. Ele devolve uma árvore de widgets. |
| `MaterialApp` | Widget raiz que instala tema, navegação, direção do texto e localização. Sem ele, `Scaffold`, `AppBar` e `SnackBar` não funcionam. |
| `debugShowCheckedModeBanner: false` | Remove a faixa vermelha "DEBUG" do canto superior direito. Só afeta o modo debug. |
| `ColorScheme.fromSeed(seedColor: ...)` | Gera uma paleta inteira do Material 3 a partir de **uma** cor semente. Aprofundado na [aula 9](09-material-e-cupertino.md). |
| `Theme.of(context).colorScheme` | Sobe a árvore a partir da posição deste widget procurando o tema mais próximo. Esse "subir a árvore" é o assunto da [aula 7](07-buildcontext.md). |
| `Scaffold` | Esqueleto de uma tela Material: barra superior, corpo, botão flutuante, gaveta. |
| `Container` com `BoxDecoration` | O "falso botão": um retângulo com cor, cantos arredondados e sombra. Ele prova o ponto da aula — é só pintura. |
| `withValues(alpha: 0.35)` | Cria a mesma cor com 35 % de opacidade. Substitui o antigo `withOpacity`, que foi descontinuado por perder precisão de cor. |
| `FilledButton.icon` | Botão de destaque do **Material 3**. É o botão padrão deste curso. `RaisedButton` e `FlatButton` **não existem mais** há várias versões. |
| `ScaffoldMessenger.of(context).showSnackBar(...)` | Forma correta de mostrar uma mensagem temporária. `Scaffold.of(context).showSnackBar(...)` foi removido do Flutter — [aula 7](07-buildcontext.md) explica o motivo. |
| `const` antes dos widgets | Diz ao Flutter que aquele widget nunca muda, então ele pode ser reutilizado sem ser reconstruído. Ganho real de desempenho, detalhado na [aula 4](04-statelesswidget.md). |

**Teste que fecha a aula.** Com o app rodando, mude no `Container` a linha
`borderRadius: BorderRadius.circular(30)` para `BorderRadius.circular(4)` e salve o arquivo
(`Ctrl` + `S`). Em menos de um segundo a forma do retângulo muda na tela **sem o app reiniciar**.
Isso é o hot reload, e ele só é possível por causa do JIT. Você vai dominá-lo na
[aula 8](08-hot-reload-e-hot-restart.md).

---

## 🤖🍎 Android × iOS

Esta aula tem uma diferença de plataforma que vale registrar desde já:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Renderizador no Flutter 3.47.1 | Impeller com **Vulkan**; aparelhos antigos sem Vulkan adequado caem para Skia | Impeller com **Metal**, desde o Flutter 3.10 |
| Embedder | `FlutterActivity` (Kotlin), em `android/app/src/main/kotlin/.../MainActivity.kt` | `FlutterViewController` (Swift), em `ios/Runner/AppDelegate.swift` |
| Arquivo que o `flutter create` gera para o ciclo de vida da janela | `MainActivity.kt` | `AppDelegate.swift` **e** `SceneDelegate.swift` |
| Versão mínima suportada | `minSdk` 24 (Android 7.0) | iOS 13 |

> 🍎 **SÓ NO MAC.** Executar o app em um simulador de iPhone ou em um iPhone físico exige macOS com
> Xcode. 🪟 No Windows você **pode**: escrever 100 % do código, testar no Chrome, testar em Android
> (depois de instalar o Android Studio) e entender todo o processo iOS. Você **não pode**: compilar,
> rodar ou publicar o app iOS. O caminho completo e as alternativas estão em
> [16-build-ios/01-por-que-exige-macos.md](../16-build-ios/01-por-que-exige-macos.md).

Uma consequência prática para o seu dia a dia neste curso: como o app é desenhado pelo Flutter,
**o layout que você vê no Chrome é o mesmo que vai aparecer no iPhone**. O que muda entre
plataformas não é o desenho — é o comportamento (transição de tela, gesto de voltar, densidade de
toque). Isso é o tema da [aula 9](09-material-e-cupertino.md).

---

## ⚠️ Erros comuns

**1. Achar que `Container` vira uma `View` do Android.**
Não vira. Nenhum widget do Flutter vira componente nativo. Se você procurar o seu botão com uma
ferramenta de inspeção de layout do Android, vai encontrar **uma única view** — a superfície do
Flutter. Para inspecionar a árvore, use o **Flutter Inspector** do DevTools
([12 — DevTools](../12-testes-e-debug/03-devtools.md)).

**2. Medir desempenho no modo debug.**
```text
"A rolagem da minha lista está travando!"
```
Rode `flutter run --release` antes de concluir qualquer coisa. No debug o Dart é interpretado pela
VM e todas as checagens de `assert` estão ligadas.

**3. Confundir engine com Impeller.**
A engine é o motor inteiro (VM do Dart, texto, imagens, rede, plugins). O Impeller é apenas o
pedaço que pinta. Dizer "o Impeller travou o app" quase sempre é impreciso.

**4. Esperar que o app Flutter tenha aparência nativa sem esforço.**
Por padrão, um app Flutter parece **Material** em toda plataforma, inclusive no iPhone. Se você
quiser aparência de iOS, precisa pedir — e a [aula 9](09-material-e-cupertino.md) discute quando
isso vale a pena.

**5. Rodar `flutter create` dentro de uma pasta com acento ou espaço.**
Erro real reproduzido nesta máquina:
```text
ShaderCompilerException: Shader compilation of ".../ink_sparkle.frag" failed with exit code 1.
'#include' : Included file not found. for header name: flutter/runtime_effect.glsl
```
Mova o projeto para `C:\src\projetos\...` e rode `flutter clean` antes de tentar de novo.

**6. Usar `print()` em código Flutter.**
Dispara o lint `avoid_print` do `flutter_lints ^6.0.0`. Em Flutter use `debugPrint()`, que além de
passar no lint não perde linhas quando o log fica muito grande.

---

## 🛠️ Exercício guiado

**Objetivo:** provar para você mesmo, com uma medição, que debug e release são mundos diferentes.

**Passo 1.** Com o projeto `meu_primeiro_app` criado e o `lib/main.dart` substituído, rode:

```powershell
flutter run -d chrome
```

Observe o tempo até o app aparecer e anote.

**Passo 2.** Feche com `q` no terminal. Agora rode em modo release:

```powershell
flutter run -d chrome --release
```

Anote de novo. O build demora **mais** (compilação AOT), mas o app roda mais rápido.

**Passo 3.** Com o app rodando em release, altere qualquer texto no `lib/main.dart` e salve.
Confirme que **nada acontece na tela**: o hot reload não existe em release. No terminal você verá
que as teclas `r` e `R` não são oferecidas.

**Passo 4.** Volte para debug (`flutter run -d chrome`), altere o mesmo texto, salve e veja a
mudança aparecer. Escreva, com as suas palavras, em um arquivo `anotacoes.md` dentro do projeto:

> Por que o passo 3 não funcionou e o passo 4 funcionou?

**Resposta esperada (confira só depois de escrever a sua):** no passo 3 o código já estava
compilado AOT para instruções de máquina fixas dentro do pacote; não há VM capaz de substituir uma
classe em execução. No passo 4 a Dart VM estava interpretando/compilando em JIT, então a ferramenta
conseguiu injetar as classes novas e pedir um novo `build`.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Comece pelos de **Fixação**, que cobrem exatamente o vocabulário desta aula: engine, embedder,
Impeller, Skia, JIT, AOT e widget.

---

## 🏆 Desafio opcional

Escreva um texto de **no máximo 15 linhas** respondendo a esta pergunta como se fosse para um
gerente de produto que não programa:

> "Nosso app precisa rodar em Android e iPhone, tem muita animação, a equipe tem 2 pessoas e o prazo
> é de 3 meses. Por que Flutter e não React Native ou nativo?"

Regras: cite **pelo menos uma desvantagem** do Flutter (senão vira propaganda), e não use nenhuma
palavra técnica sem explicar entre parênteses. Guarde o texto — ele volta em
[17 — Próximos passos](../17-publicacao-e-proximos-passos/06-proximos-passos.md).

---

## 📌 Resumo

- O Flutter **pinta os próprios pixels** em uma superfície emprestada pelo sistema operacional.
  Nenhum widget vira componente nativo.
- Isso dá consistência visual total e controle total, ao custo de tamanho de app maior e de não
  herdar automaticamente a aparência nova do sistema.
- O Flutter tem três camadas: **framework** (Dart, o que você escreve), **engine** (C++, pinta e
  executa o Dart) e **embedder** (Kotlin/Swift/C++, pede a janela ao sistema).
- **Impeller** é o renderizador atual (🍎 iOS desde o 3.10, 🤖 Android por padrão no 3.47) e elimina
  os engasgos de compilação de shader do **Skia**. Skia continua no 🪟 Windows e na web (CanvasKit).
- Dart compila em **JIT no debug** (por isso existe hot reload) e em **AOT no release** (por isso o
  app final é rápido e por isso o hot reload é impossível lá).
- Nunca avalie desempenho em modo debug.
- **React Native** usa componentes reais do sistema; **nativo puro** exige duas bases de código.
  Flutter troca "parecer nativo de graça" por "ser idêntico em todo lugar".
- Um **widget** é uma descrição imutável e barata de um pedaço de interface. Interface no Flutter se
  monta **compondo** widgets dentro de widgets.

---

## ☑️ Checklist de domínio

- [ ] Explico em uma frase o que o Flutter pede ao sistema operacional.
- [ ] Cito uma vantagem e uma desvantagem de pintar os próprios pixels.
- [ ] Nomeio as três camadas do Flutter e o que cada uma faz.
- [ ] Digo a diferença entre engine, Impeller e Skia sem hesitar.
- [ ] Explico o que é *shader compilation jank* e por que o Impeller foi criado.
- [ ] Digo qual renderizador está em uso em 🤖 Android, 🍎 iOS, 🪟 Windows e web no Flutter 3.47.1.
- [ ] Explico JIT e AOT e ligo cada um ao seu modo de build.
- [ ] Explico, em duas frases, por que o hot reload não existe em release.
- [ ] Comparo Flutter, React Native e nativo puro citando prós e contras de cada um.
- [ ] Defino widget em uma frase, incluindo as palavras "imutável" e "descrição".
- [ ] Criei `meu_primeiro_app`, substituí o `lib/main.dart` e vi o app rodando no Chrome.

---

## 📚 Referências oficiais

- [Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)
- [Impeller rendering engine](https://docs.flutter.dev/perf/impeller)
- [Introduction to widgets](https://docs.flutter.dev/ui/widgets-intro)
- [Flutter build modes](https://docs.flutter.dev/testing/build-modes)
- [Dart overview — JIT e AOT](https://dart.dev/overview)
- [FAQ — Why did Flutter choose Dart?](https://docs.flutter.dev/resources/faq)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — Estrutura do projeto](02-estrutura-do-projeto.md) |
