# Aula 1 — Debug, profile e release

> **Módulo:** 15 - Build e Distribuição Android · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Nomear os **três modos de build** do Flutter e dizer para que serve cada um.
- Explicar a diferença entre **JIT** e **AOT** e qual modo usa cada um.
- Listar o que o modo debug **liga** (asserts, hot reload, DevTools, `debugPaintSizeEnabled`) e o
  que o release **desliga**.
- Justificar, com argumento técnico, por que **medir desempenho em debug produz um número sem
  valor**.
- Justificar por que **um APK de debug nunca pode ser distribuído**.
- Rodar `flutter run`, `flutter run --profile` e `flutter run --release` e reconhecer a diferença.
- Gerar artefatos nos três modos e dizer de cor **onde cada arquivo é gravado**.

## ✅ Pré-requisitos

- [README do módulo](README.md) lido, com o ambiente Android verde no `flutter doctor`.
- Módulo 13 concluído, em especial
  [04 — Medindo desempenho](../13-desempenho-e-seguranca/04-medindo-desempenho.md), onde o modo
  profile apareceu pela primeira vez.
- Um projeto Flutter que compila. O curso usa o **Foco** (`br.com.estudos.foco`).
- Um aparelho Android ou emulador listado em `flutter devices`.

---

## 📖 Conceito

### O que é "modo de build"

**Build** (*compilação*) é o processo de transformar o seu código Dart e os arquivos do projeto em
um aplicativo que o Android consegue executar. **Modo de build** é o conjunto de decisões que o
compilador toma durante esse processo: o que otimizar, o que manter, o que remover.

O Flutter tem exatamente **três** modos. Eles não são "níveis de qualidade" — são ferramentas
diferentes para momentos diferentes:

| Modo | Para quê | Quem usa |
|---|---|---|
| **debug** | Escrever código. Ciclo de edição rápido. | Você, o dia inteiro, enquanto desenvolve. |
| **profile** | Medir desempenho em condições próximas às reais. | Você, quando algo está lento. |
| **release** | Entregar para o usuário final. | A loja, o testador, o cliente. |

### JIT × AOT — a diferença técnica que explica tudo o resto

Este é o ponto central da aula. Quase todas as outras diferenças entre os modos são consequência
deste.

**JIT** (*Just-In-Time* — "na hora exata") é uma forma de execução em que o código é traduzido para
instruções de máquina **enquanto o programa roda**. Existe uma máquina virtual do Dart junto com o
app, lendo o seu código e compilando trechos sob demanda.

**AOT** (*Ahead-Of-Time* — "antes da hora") é o oposto: **todo** o código Dart é traduzido para
instruções de máquina ARM nativas **durante o build**, antes de o app ser instalado. O app instalado
já contém código de máquina puro.

| | JIT (debug) | AOT (profile e release) |
|---|---|---|
| Quando o código é traduzido | durante a execução | durante o build |
| Permite trocar código com o app rodando | **sim** — é isso que faz o hot reload existir | não |
| Tempo até a primeira tela aparecer | maior (a máquina virtual precisa compilar) | menor |
| Desempenho de execução | pior | melhor |
| Tempo de build | menor | maior |
| Tamanho do artefato | maior (leva o compilador junto) | menor |

**O hot reload só existe por causa do JIT.** Quando você salva um arquivo e a tela muda em menos de
um segundo sem perder o estado, é porque a máquina virtual do Dart substituiu o código antigo pelo
novo em memória. Em AOT isso é impossível: o código já virou instruções de máquina fixas dentro do
arquivo instalado. Por isso `flutter run --release` **não tem** hot reload. Não é uma limitação
arbitrária; é uma consequência direta de como o código foi compilado.

### O que o modo debug liga

**Assert** é uma instrução que verifica se uma condição é verdadeira e **interrompe o programa** com
uma mensagem clara se não for. O Flutter usa asserts em centenas de lugares internos. Exemplo real
que você provavelmente já viu:

```text
A RenderFlex overflowed by 42 pixels on the bottom.
```

Essa mensagem vem de um assert dentro do framework. Em **release, todo assert é removido do
binário** — não custa nada em tempo de execução, mas também não avisa nada.

Além dos asserts, o modo debug liga:

- **Serviço de observação (VM Service)** — a porta pela qual o **DevTools** (o conjunto de
  ferramentas de inspeção do Flutter: inspetor de widgets, gráfico de desempenho, memória) se
  conecta ao app rodando.
- **Hot reload** e **hot restart**.
- **Flags visuais de depuração**: `debugPaintSizeEnabled` (desenha as caixas de layout),
  `debugRepaintRainbowEnabled` (pisca cores a cada repintura), `showPerformanceOverlay`.
- **A faixa "DEBUG"** no canto superior direito da tela. Ela existe exatamente para você nunca
  confundir uma captura de tela de debug com o app real.
- **Verificações extras de tipo e de estado** em todo o framework.
- **Mensagens de erro completas**, com a árvore de widgets e o trecho de código.

### O que o modo release faz

- Compila em **AOT**.
- **Remove** todos os asserts.
- **Desliga** o serviço de observação: DevTools **não conecta**.
- **Desliga** hot reload, hot restart e todas as flags de depuração.
- Remove a faixa "DEBUG".
- Aplica **tree shaking** — literalmente "sacudir a árvore": o compilador percorre o código a partir
  do `main()` e descarta tudo o que não é alcançável. Inclusive os glifos de fontes de ícones que
  você não usa.
- Gera o artefato para publicação.

### O que o modo profile faz (e por que ele existe)

Profile é **release com uma exceção**: o serviço de observação continua ligado, para que o DevTools
consiga se conectar e medir.

- Compilação **AOT**, como o release.
- Asserts **removidos**, como o release.
- Serviço de observação **ligado**, como o debug — mas só o suficiente para medir.
- Hot reload **desligado**.
- Não tem a faixa "DEBUG".

Ou seja: profile serve para responder à pergunta *"quantos milissegundos esse frame está levando de
verdade?"*. É o modo que o [Módulo 13](../13-desempenho-e-seguranca/README.md) manda usar.

> ⚠️ O modo profile **não roda no emulador** com resultado confiável — e em algumas versões do
> Android nem inicia no emulador. Desempenho se mede em **aparelho físico**. O emulador usa o
> processador do seu PC, que não tem nada a ver com o processador do celular.

### Por que NUNCA medir desempenho em debug

Porque o número que você lê não descreve o seu app. Ele descreve o **seu app mais o compilador JIT
mais todas as verificações de depuração**. Concretamente:

1. Cada método Dart pode ser compilado **no momento em que é chamado pela primeira vez**. Isso
   produz picos de lentidão que **não existem** no app publicado.
2. Todos os asserts do framework estão **ativos**. Cada `build()` de widget carrega verificações
   extras.
3. As camadas de inspeção do DevTools estão instrumentando a árvore de widgets.
4. Não houve tree shaking nem otimização de código.

O resultado prático: uma rolagem que parece "travada" em debug pode estar perfeitamente fluida em
release. Se você "otimizar" o app com base no número de debug, vai gastar horas resolvendo um
problema que não existe — e talvez piorar o código legível por nada.

**Regra:** se alguém (inclusive você) disser "esse app está lento", a primeira pergunta é
*"em qual modo?"*. Se a resposta for "debug", a medição não vale.

### Por que NUNCA publicar um APK de debug

Cinco motivos, todos graves:

1. **Está assinado com a chave de depuração.** Essa chave é gerada automaticamente pelo Android SDK,
   é a mesma em milhões de máquinas e **a Google Play recusa** o upload. Mais importante: qualquer
   pessoa consegue gerar uma atualização falsa do seu app assinada com ela.
2. **Está muito mais lento**, pelos motivos da seção anterior.
3. **É muito maior** — leva o compilador JIT e o código não otimizado junto.
4. **Expõe o serviço de observação.** Um app de debug instalado aceita conexão de ferramentas de
   inspeção, o que significa acesso ao estado interno do app.
5. **Mostra a faixa "DEBUG"** e mensagens de erro internas do framework na tela do usuário.

> 🔴 Um APK de debug **funciona** se você instalar no celular. É justamente por isso que essa
> armadilha pega gente: o app abre, a pessoa acha que terminou, e distribui. Funcionar não é o
> critério. O critério é **modo release, assinado com a sua chave**.

---

## 💡 Analogia

Pense em três versões de um mesmo prédio.

- **Debug** é o prédio **em obra, com andaimes e placas**: você entra em qualquer andar, mexe na
  parede, troca um cano com a água ligada. Tem escada de serviço em todo canto (o hot reload), tem
  gente medindo tudo (os asserts), tem plaquinha "cuidado, piso molhado" (as mensagens de erro).
  Cronometrar o tempo de subir até o quinto andar **nesse prédio** não diz nada sobre o prédio
  pronto — você vai subir tropeçando em andaime.
- **Profile** é o prédio **pronto, mas com um cronômetro instalado em cada elevador**: nada de
  andaime, tudo funcionando de verdade, mas ainda dá para medir.
- **Release** é o prédio **entregue**: sem andaime, sem cronômetro, sem placa. É o que o morador
  recebe.

A analogia para de valer em um ponto importante: um prédio em obra não pode ser habitado, mas um APK
de debug **pode** ser instalado. A proibição aqui é sua decisão, não do sistema.

---

## 🧪 Exemplo mínimo

O Flutter expõe três constantes que dizem em qual modo o app foi compilado. Elas vêm de
`package:flutter/foundation.dart`:

```dart
import 'package:flutter/foundation.dart';

// Exatamente uma das três é verdadeira.
kDebugMode;    // true só em debug
kProfileMode;  // true só em profile
kReleaseMode;  // true só em release
```

O detalhe que faz isso ser útil: as três são `const`. O compilador **sabe o valor durante o build**,
então um `if (kDebugMode) { ... }` tem o corpo inteiro **removido** do binário de release. Você
consegue deixar código de diagnóstico no projeto sem pagar por ele em produção:

```dart
if (kDebugMode) {
  debugPrint('Sessão criada com 25 minutos');
}
```

Em release, esse trecho simplesmente não existe no arquivo instalado.

> Use `debugPrint()` e não `print()`. O lint `avoid_print` do `flutter_lints ^6.0.0` reclama de
> `print()` em código Flutter, e o `debugPrint` tem um controle de fluxo que evita perder linhas
> quando o log é muito grande.

---

## 📱 Aplicando no Flutter

### Rodando nos três modos

**🪟 Windows (PowerShell)** — e igual no **🖥️ macOS / 🐧 Linux**:

```powershell
flutter run
flutter run --profile
flutter run --release
```

`flutter run` sem flag é `--debug`. Você pode escrever `flutter run --debug` para deixar explícito.

O que você observa na prática, na ordem:

| Comando | Faixa "DEBUG"? | Hot reload (`r`)? | Tempo até abrir |
|---|---|---|---|
| `flutter run` | sim | sim | rápido para compilar, app mais lento |
| `flutter run --profile` | não | não | demora mais para compilar |
| `flutter run --release` | não | não | demora mais para compilar, app mais rápido |

Em `--release`, se você apertar `r` no terminal, o Flutter responde que hot reload não está
disponível. Isso **não é um bug**: é o AOT.

### Gerando artefatos nos três modos

Rodar não é a mesma coisa que **gerar um arquivo**. `flutter run` compila e instala direto. Para
produzir o arquivo que você pode copiar para outro lugar, use `flutter build`:

```powershell
flutter build apk --debug
flutter build apk --profile
flutter build apk --release
```

`flutter build apk` sem flag já é `--release` — mas escreva `--release` mesmo assim. Comando
explícito não engana ninguém seis meses depois.

### Onde cada artefato é gravado

Todos os caminhos são **relativos à raiz do projeto** (a pasta com o `pubspec.yaml`):

```text
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-profile.apk
build/app/outputs/flutter-apk/app-release.apk

build/app/outputs/bundle/debug/app-debug.aab
build/app/outputs/bundle/profile/app-profile.aab
build/app/outputs/bundle/release/app-release.aab
```

E, quando você divide por arquitetura (assunto da [Aula 8](08-gerando-apk-e-aab.md)):

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

Confirme que o arquivo existe antes de acreditar que o build funcionou:

**🪟 Windows (PowerShell)**

```powershell
Get-ChildItem build\app\outputs\flutter-apk\ | Select-Object Name, Length, LastWriteTime
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
ls -lh build/app/outputs/flutter-apk/
```

A coluna `Length` (Windows) ou o tamanho do `ls -lh` é a sua primeira métrica objetiva: um APK de
release de um app simples fica na casa de dezenas de megabytes; o de debug é visivelmente maior.

---

## 💻 Código completo

Uma tela que mostra na interface em qual modo o app foi compilado. Coloque no projeto **Foco** e
rode nos três modos para ver a diferença com os próprios olhos.

> **Arquivo:** `lib/features/estatisticas/presentation/estatisticas_screen.dart`
> **Como executar:** `flutter run` · depois `flutter run --profile` · depois `flutter run --release`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Nomes possíveis do modo de compilação.
enum ModoDeBuild { debug, profile, release }

/// Descobre o modo de build atual usando as constantes do framework.
///
/// As três constantes são `const`, então o compilador resolve este `switch`
/// durante o build e o binário de release só carrega o ramo vencedor.
ModoDeBuild modoAtual() {
  if (kDebugMode) return ModoDeBuild.debug;
  if (kProfileMode) return ModoDeBuild.profile;
  return ModoDeBuild.release;
}

class CartaoDoModo extends StatelessWidget {
  const CartaoDoModo({super.key});

  @override
  Widget build(BuildContext context) {
    final modo = modoAtual();

    final (String titulo, String explicacao, Color cor) = switch (modo) {
      ModoDeBuild.debug => (
          'DEBUG (JIT)',
          'Hot reload ligado, asserts ativos, DevTools conectado. '
              'NÃO meça desempenho aqui e NUNCA distribua este arquivo.',
          Colors.orange,
        ),
      ModoDeBuild.profile => (
          'PROFILE (AOT)',
          'Compilado como release, mas com o serviço de observação ligado. '
              'É aqui que você mede desempenho, em aparelho físico.',
          Colors.blue,
        ),
      ModoDeBuild.release => (
          'RELEASE (AOT)',
          'Asserts removidos, DevTools desligado, tree shaking aplicado. '
              'É este o arquivo que vai para a Google Play.',
          Colors.green,
        ),
    };

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.build_circle_outlined, color: cor),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(explicacao, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class EstatisticasScreen extends StatelessWidget {
  const EstatisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Este bloco inteiro some do binário de release.
    if (kDebugMode) {
      debugPrint('Foco: tela de estatísticas construída em modo debug.');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CartaoDoModo(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Rode este app nos três modos e compare: faixa DEBUG, '
              'tempo de abertura e resposta da rolagem.',
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔍 Explicando o código

- `import 'package:flutter/foundation.dart';` — é de onde vêm `kDebugMode`, `kProfileMode`,
  `kReleaseMode` e `debugPrint`. `foundation` é a camada do Flutter que não depende de widgets.
- `enum ModoDeBuild { debug, profile, release }` — modelar o modo como enum em vez de `String`
  garante que o `switch` seja **exaustivo**: se alguém acrescentar um valor, o compilador avisa.
- `modoAtual()` testa `kDebugMode` e `kProfileMode` e assume release no `else`. Escrevi nessa ordem
  porque exatamente uma das três é verdadeira — não existe combinação.
- `final (String titulo, String explicacao, Color cor) = switch (modo) { ... };` usa um **record**
  (a tupla de valores do Dart 3) com **switch de expressão**. Em uma atribuição só, saem três
  valores relacionados. Sem record, seriam três `switch` ou três variáveis `late`.
- `Theme.of(context).textTheme.titleMedium` pega o estilo de texto do tema Material 3 em vez de
  fixar tamanho de fonte na mão. Assim o cartão respeita o tema claro/escuro do app.
- `const` aparece em todo widget que não depende de variável (`SizedBox`, `Icon`... ). Widget `const`
  é construído uma vez e reaproveitado — o ganho está explicado em
  [Módulo 13, aula 01](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md).
- `if (kDebugMode) { debugPrint(...); }` é o padrão recomendado para log de diagnóstico: some
  inteiro do release, sem `#ifdef` nem gambiarra.

### Tabela comparativa completa

Esta é a tabela que você deve saber responder na avaliação:

| Característica | 🐞 debug | 📊 profile | 🚀 release |
|---|---|---|---|
| Compilação do Dart | JIT | AOT | AOT |
| Hot reload / hot restart | **sim** | não | não |
| Asserts ativos | **sim** | não | não |
| DevTools consegue conectar | **sim** | **sim** | não |
| Serviço de observação (VM Service) | ligado | ligado | desligado |
| `debugPaintSizeEnabled` e similares | funcionam | não | não |
| Faixa "DEBUG" na tela | **sim** | não | não |
| Tree shaking (remoção de código morto) | não | sim | sim |
| Tree shaking de ícones de fonte | não | sim | sim |
| Tamanho do artefato | maior | intermediário | **menor** |
| Velocidade de execução | menor | alta | **alta** |
| Tempo de compilação | **menor** | maior | maior |
| Assinado com | chave de **debug** | chave de **debug** (padrão) | **sua** chave (Aula 7) |
| Serve para medir desempenho | **NÃO** | **SIM** | não (sem instrumentação) |
| Serve para publicar | **NÃO** | **NÃO** | **SIM** |
| Roda em emulador de forma confiável | sim | **não** | sim |
| Arquivo gerado (APK) | `app-debug.apk` | `app-profile.apk` | `app-release.apk` |

---

## 🤖🍎 Android × iOS

Os **três modos são os mesmos** nas duas plataformas — o conceito é do Flutter, não do sistema. O
que muda é o artefato e onde ele nasce:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Artefato distribuível | `.apk` / `.aab` | `.ipa` |
| Comando de build | `flutter build apk` / `flutter build appbundle` | `flutter build ipa` |
| Saída do release | `build/app/outputs/flutter-apk/app-release.apk` | `build/ios/ipa/<nome>.ipa` |
| Assinatura | keystore que **você** cria ([Aula 6](06-keystore.md)) | certificado + perfil de provisionamento da Apple |
| Onde se constrói | Windows, macOS ou Linux | **somente macOS com Xcode** |

> 🍎 **SÓ NO MAC.** Gerar o `.ipa` exige macOS + Xcode. No Windows você vai aprender o processo
> inteiro no [Módulo 16](../16-build-ios/README.md) e executar quando tiver acesso a um Mac. Este
> módulo 15, ao contrário, você executa **inteiro** no Windows 11.

---

## ⚠️ Erros comuns

**1. Medir desempenho em debug e "otimizar" com base nisso.**
Sintoma: "a lista trava quando rolo". Causa provável: você está em debug. Correção: refaça a medição
com `flutter run --profile` em aparelho físico antes de mexer em qualquer linha.

**2. Achar que `flutter build apk` gera debug.**
Sem flag, `flutter build apk` gera **release**. Confira o nome do arquivo: `app-release.apk`. Se
você vê `app-debug.apk`, você passou `--debug` em algum lugar.

**3. Distribuir `app-debug.apk` "só para o amigo testar".**
Esse APK está assinado com a chave de depuração. Quando você depois mandar o APK de release, o
Android vai recusar a instalação por cima, com a mensagem:

```text
INSTALL_FAILED_UPDATE_INCOMPATIBLE: Package br.com.estudos.foco signatures do not match
previously installed version
```

Correção: desinstalar o app antigo no aparelho e instalar o de release. A
[Aula 9](09-instalando-e-validando.md) trata disso.

**4. Tentar abrir o DevTools em release.**
Não conecta. O serviço de observação está desligado por decisão de projeto — é o que impede que
qualquer ferramenta inspecione o app publicado. Use `--profile`.

**5. Rodar profile no emulador e tirar conclusões.**
O emulador executa no processador do seu PC. O número não representa o celular de ninguém.

**6. Esperar que `--release` compile tão rápido quanto debug.**
O primeiro build AOT de um projeto pode levar vários minutos. Isso é normal: o compilador está
traduzindo todo o código Dart para instruções ARM. Os builds seguintes são mais rápidos por causa do
cache do Gradle.

**7. Confundir `flutter run --release` com `flutter build apk`.**
`run` compila **e instala** no aparelho conectado, sem deixar um arquivo distribuível pronto para
você copiar. `build` produz o arquivo em `build/app/outputs/`. Para mandar o app para alguém, você
precisa de `build`.

---

## 🛠️ Exercício guiado

Vamos comprovar as diferenças na prática, com números que você mesmo vai medir.

**Passo 1 — Prepare o terreno.**

```powershell
flutter clean
flutter pub get
flutter devices
```

`flutter clean` apaga a pasta `build/`, garantindo que os tamanhos que você vai comparar sejam todos
do mesmo momento.

**Passo 2 — Gere os três APKs.** Um de cada vez; anote o tempo que cada um levou (o próprio Flutter
imprime o tempo no final):

```powershell
flutter build apk --debug
flutter build apk --profile
flutter build apk --release
```

Saída esperada do último, aproximadamente:

```text
√ Built build\app\outputs\flutter-apk\app-release.apk (21.4MB)
```

**Passo 3 — Compare os tamanhos.**

**🪟 Windows (PowerShell)**

```powershell
Get-ChildItem build\app\outputs\flutter-apk\*.apk |
  Select-Object Name, @{Name='MB';Expression={[math]::Round($_.Length/1MB,1)}}
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
ls -lh build/app/outputs/flutter-apk/*.apk
```

Preencha a tabela com os **seus** números:

| Arquivo | Tamanho (MB) | Tempo de build |
|---|---|---|
| `app-debug.apk` | | |
| `app-profile.apk` | | |
| `app-release.apk` | | |

**Passo 4 — Veja a diferença na tela.** Com o aparelho conectado:

```powershell
flutter run
```

Observe: faixa "DEBUG" no canto, e o `r` do terminal recarrega a tela. Encerre com `q` e rode:

```powershell
flutter run --release
```

Observe: sem faixa, o app abre mais rápido, e apertar `r` não recarrega nada.

**Como confirmar que funcionou:** você consegue responder, sem consultar a aula, a estas três
perguntas:

1. Por que o APK de debug é o maior dos três?
2. Por que o hot reload não existe em release?
3. Se o seu chefe pedir "me diz quantos ms leva cada frame da lista de matérias", qual comando você
   roda?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-android.md](../../exercicios/15-build-android.md)

Comece pelos de fixação sobre os três modos e pelo de leitura de código com `kDebugMode`.

---

## 🏆 Desafio opcional

Crie no app **Foco** uma "tela secreta de diagnóstico" que só existe em debug e profile, e que
desaparece completamente do binário de release.

Requisitos:

1. Um botão em Ajustes que só aparece quando `!kReleaseMode`.
2. A tela mostra: modo de build, versão do app, e quantos segundos se passaram desde a abertura.
3. O `import` da tela e todo o código dela devem sumir do release — para isso, o botão precisa estar
   dentro de um `if (!kReleaseMode)` avaliado em tempo de compilação, e a tela só pode ser
   referenciada ali dentro.
4. Comprove: gere `flutter build apk --release --analyze-size` antes e depois e compare o tamanho.
   A flag `--analyze-size` aparece em detalhe na [Aula 8](08-gerando-apk-e-aab.md).

Critério de sucesso: em release, o botão não aparece e o tamanho do APK **não** cresceu de forma
perceptível com a nova tela.

---

## 📌 Resumo

- O Flutter tem **três modos**: **debug** (desenvolver), **profile** (medir), **release**
  (entregar).
- **JIT** compila durante a execução e é o que torna o **hot reload** possível — só existe em debug.
  **AOT** compila tudo antes, e é usado em profile e release.
- Debug liga asserts, DevTools, flags visuais e a faixa "DEBUG"; release remove tudo isso e aplica
  **tree shaking**.
- **Profile = release + serviço de observação ligado.** É o único modo válido para medir desempenho,
  e só em **aparelho físico**.
- **Nunca** meça desempenho em debug: o número inclui o compilador JIT e as verificações do
  framework.
- **Nunca** distribua um APK de debug: está assinado com a chave de depuração, é maior, mais lento e
  expõe o serviço de observação.
- Saídas: `build/app/outputs/flutter-apk/app-<modo>.apk` e
  `build/app/outputs/bundle/<modo>/app-<modo>.aab`.
- `flutter run` instala e conecta; `flutter build` produz o arquivo distribuível.

---

## ☑️ Checklist de domínio

- [ ] Digo os três modos e para que serve cada um, sem olhar.
- [ ] Explico JIT e AOT e ligo o hot reload ao JIT.
- [ ] Listo pelo menos quatro coisas que o debug liga e o release desliga.
- [ ] Explico, com argumento técnico, por que não se mede desempenho em debug.
- [ ] Listo três motivos para nunca publicar um APK de debug.
- [ ] Rodo `flutter run --profile` e sei que precisa ser em aparelho físico.
- [ ] Escrevo de cor o caminho do APK de release e o do AAB de release.
- [ ] Uso `kDebugMode` para deixar código de diagnóstico que some do release.
- [ ] Sei a diferença entre `flutter run --release` e `flutter build apk --release`.
- [ ] Gerei os três APKs e comparei os tamanhos no meu projeto.

---

## 📚 Referências oficiais

- [Flutter — Build modes](https://docs.flutter.dev/testing/build-modes)
- [Flutter — Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Flutter — Flutter performance profiling](https://docs.flutter.dev/perf/ui-performance)
- [Flutter — Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Flutter — `flutter build` (CLI reference)](https://docs.flutter.dev/reference/flutter-cli)
- [Dart — `dart:core` e o compilador AOT](https://dart.dev/overview#platform)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Identidade do app](02-identidade-do-app.md) |
