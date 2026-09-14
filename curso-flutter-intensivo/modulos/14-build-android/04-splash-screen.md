# Aula 4 — Splash screen

> **Módulo:** 14 - Build e Distribuição Android · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Explicar **o que é a splash nativa** e por que ela existe — o que acontece entre o toque no ícone e
  o primeiro frame do Flutter.
- Diferenciar **splash nativa** de **tela de carregamento feita em Flutter**, e dizer quando usar
  cada uma.
- Configurar `flutter_native_splash` com `color`, `image`, `color_dark` e `image_dark`.
- Explicar por que o **Android 12+ mudou o mecanismo** e por que existe a seção `android_12:`.
- Rodar `dart run flutter_native_splash:create` e `dart run flutter_native_splash:remove`.
- Nomear a **lista exata de arquivos gerados** e dizer o que cada um controla.
- Conferir o resultado no aparelho, no tema claro e no escuro.

## ✅ Pré-requisitos

- [Aula 3 — Ícone](03-icone.md) concluída. A splash usa a mesma pasta `assets/icone/` e o mesmo
  fluxo de "configura no `pubspec.yaml`, roda um comando".
- `applicationId` já definitivo ([Aula 2](02-identidade-do-app.md)).
- Um aparelho Android ou emulador para conferir.

---

## 📖 Conceito

### O que acontece quando você toca no ícone

Entre o toque no ícone e a primeira tela do seu app existe um intervalo. Nele, o Android:

1. cria o processo do app;
2. carrega a máquina virtual Android e as bibliotecas nativas;
3. **carrega o motor do Flutter** (o *engine*, escrito em C++);
4. inicia a máquina virtual do Dart e executa o seu `main()`;
5. constrói a primeira árvore de widgets;
6. desenha o primeiro frame.

Os passos 3 a 6 levam tempo — de alguns décimos de segundo em um aparelho bom a vários segundos em
um aparelho de entrada com o app frio (*cold start* — primeira abertura, com nada em memória).

**Durante todo esse tempo, o Flutter ainda não existe na tela.** Se o app não fornecesse nada, o
usuário veria uma tela **branca ou preta** — ou, pior, a tela anterior congelada. Isso passa a
impressão de app travado.

A **splash nativa** (*splash screen*, "tela de abertura") é a imagem que o **sistema operacional**
desenha nesse intervalo. Ela é nativa porque é o Android que a desenha, lendo uma configuração de
recurso do app — **antes** de qualquer linha de Dart rodar.

```text
toque no ícone
     |
     |--- SPLASH NATIVA (desenhada pelo Android) -------|
     |                                                  |
     |   processo criado, engine carregando, main()     |
     |                                                  |
     +--------------------------------------------------+--- primeiro frame do Flutter
                                                             (aqui a splash some)
```

### 🔴 Splash nativa × tela de carregamento em Flutter

Esta distinção é a mais importante da aula, porque as duas parecem a mesma coisa e servem para
coisas diferentes.

| | Splash **nativa** | Tela de carregamento em **Flutter** |
|---|---|---|
| Quem desenha | o **Android** (ou o iOS) | o seu código Dart |
| Quando aparece | **antes** do Flutter carregar | **depois** do Flutter carregar |
| O que é, tecnicamente | um recurso XML/drawable no APK | um `Widget` na sua árvore |
| Pode ter animação complexa | não (é uma imagem estática) | sim |
| Pode mostrar progresso real | não | sim |
| Pode fazer requisição de rede | não | sim |
| Some quando | o primeiro frame do Flutter é desenhado | você troca de tela |
| Configurada em | `AndroidManifest.xml` + `styles.xml` + `drawable` | `lib/` |

**As duas se complementam.** O fluxo profissional é:

```text
1. Splash NATIVA       — cobre o carregamento do engine (você não controla a duração)
2. Tela de CARREGAMENTO em Flutter — cobre o que o SEU app precisa fazer:
                          abrir o banco sqflite, ler shared_preferences,
                          verificar sessão, buscar dados iniciais
3. Tela inicial do app
```

> ⚠️ **Erro conceitual muito comum:** usar a splash nativa para "mostrar a marca por 3 segundos". A
> splash nativa **não tem duração configurável** — ela some exatamente quando o Flutter desenha o
> primeiro frame. Se você quer controlar o tempo, isso é trabalho da tela em Flutter, não da nativa.
> E, honestamente: segurar o usuário numa tela de marca por 3 segundos é uma escolha ruim de
> experiência.

### Por que a splash nativa precisa de um pacote

Configurar a splash à mão no Android significa mexer em, no mínimo:

- `android/app/src/main/res/drawable/launch_background.xml` — o desenho em si;
- `android/app/src/main/res/drawable-v21/launch_background.xml` — variação para API 21+;
- `android/app/src/main/res/drawable-night/launch_background.xml` — variação para modo escuro;
- `android/app/src/main/res/values/styles.xml` — o tema aplicado à `MainActivity`;
- `android/app/src/main/res/values-night/styles.xml` — o tema do modo escuro;
- `android/app/src/main/res/values-v31/styles.xml` — o tema do Android 12+;
- `android/app/src/main/res/values-night-v31/styles.xml` — Android 12+ no modo escuro;
- além das imagens em cada densidade.

E no iOS, mexer no `LaunchScreen.storyboard`, no `Info.plist` e no conjunto de imagens.

O pacote **`flutter_native_splash`** gera tudo isso a partir de uma configuração no `pubspec.yaml`.

### 🔴 O Android 12 mudou o mecanismo

Do Android 5 ao 11, a splash era **o fundo da janela**: você definia um `drawable` como fundo do
tema da `MainActivity`, e o sistema desenhava aquela imagem enquanto a janela não tinha conteúdo.
Podia ser qualquer coisa — uma imagem em tela cheia, um logo grande, um gradiente.

**No Android 12 (API 31) isso mudou.** O sistema passou a ter uma splash **padronizada e
obrigatória**, com regras próprias:

| | Android 5–11 | **Android 12+** |
|---|---|---|
| O que aparece | o `drawable` que você definiu, como fundo de janela | uma **cor de fundo** + o **ícone centralizado** |
| Imagem em tela cheia | possível | **não é possível** |
| Tamanho do ícone | livre | fixo pelo sistema (com máscara circular) |
| Animação | não | o ícone pode ser animado (drawable animado) |
| Controlado por | `values/styles.xml` | `values-v31/styles.xml`, com atributos `windowSplashScreen*` |

Ou seja: **no Android 12+ você não escolhe mais o layout da splash.** Você escolhe a cor de fundo e
a imagem que vai no centro, e o sistema desenha do jeito dele, igual para todos os apps.

Por isso a configuração do `flutter_native_splash` tem uma seção separada chamada `android_12:`. Ela
alimenta o `values-v31/styles.xml`, que só os aparelhos com Android 12 ou superior leem. Os
aparelhos mais antigos continuam lendo `values/styles.xml`.

**O sufixo `-v31`** nos nomes de pasta é o mecanismo geral de qualificadores do Android: um recurso
em `values-v31/` só é usado por aparelhos com API 31 ou superior. Igual a `-night` (modo escuro) e
`-xxhdpi` (densidade), vistos na [Aula 3](03-icone.md).

**Consequência prática:** a imagem que você põe na seção `android_12:` deve ser pensada como um
**ícone**, não como uma ilustração. Um desenho largo com texto vai aparecer minúsculo e cortado pela
máscara circular. Use o mesmo critério da margem de ~66% do ícone adaptativo.

---

## 💡 Analogia

Pense em um teatro.

A **splash nativa** é a **cortina fechada** com a logomarca do teatro impressa. Ela está lá desde
antes de qualquer ator chegar ao palco, e sobe no instante em que a peça começa. Você não controla
quanto tempo ela fica fechada — depende de quanto o cenário demora a ficar pronto.

A **tela de carregamento em Flutter** é o **ator que entra e diz "a peça começa em instantes"**. Ele
já está no palco, já é parte da peça, e você controla o texto e o tempo dele.

A mudança do Android 12 é o teatro tendo trocado a cortina livre por uma **cortina padronizada da
rede de teatros**: fundo de cor única e o logo no meio, igual em todas as salas. Você escolhe a cor
e o logo, não o desenho da cortina.

---

## 🧪 Exemplo mínimo

A configuração mais simples possível — fundo de cor sólida, sem imagem:

```yaml
flutter_native_splash:
  color: "#3F51B5"
```

E o comando:

```powershell
dart run flutter_native_splash:create
```

Isso já gera todos os arquivos das duas plataformas. Mas uma splash de cor sólida não diz nada ao
usuário. A configuração real do curso acrescenta imagem, modo escuro e a seção do Android 12.

---

## 📱 Aplicando no Flutter

### Passo 1 — Preparar a imagem da splash

A imagem da splash **não é a mesma** do ícone, embora possa ser. Recomendações:

| Requisito | Valor |
|---|---|
| Formato | PNG |
| Transparência | **sim** — o fundo vem da chave `color` |
| Tamanho | ~1152×1152 px, com o desenho nos ~66% centrais |
| Conteúdo | o símbolo do app, sem texto pequeno |

Salve em `assets/icone/splash.png`.

> Se você quiser começar com uma só, use o mesmo `assets/icone/icone.png` da Aula 3 — funciona. Mas
> repare que o ícone do app costuma ter fundo colorido, e a splash vai desenhá-lo por cima de outro
> fundo colorido. Um PNG com fundo transparente fica melhor.

### Passo 2 — Declarar a dependência

Já está em `dev_dependencies` desde a Aula 3:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.8
```

Se ainda não estiver:

```powershell
flutter pub add dev:flutter_native_splash
```

### Passo 3 — Configurar (bloco de PRIMEIRO NÍVEL, de novo)

Igual ao `flutter_launcher_icons`, o bloco `flutter_native_splash:` fica na **coluna 1**, alinhado
com `flutter:` — nunca dentro dele.

```yaml
flutter_native_splash:
  color: "#3F51B5"
  image: assets/icone/splash.png
  color_dark: "#121212"
  image_dark: assets/icone/splash.png
  android_12:
    color: "#3F51B5"
    image: assets/icone/splash.png
    icon_background_color: "#3F51B5"
    color_dark: "#121212"
    icon_background_color_dark: "#121212"
  android: true
  ios: true
  web: false
```

### Passo 4 — Entender cada chave

| Chave | O que controla |
|---|---|
| `color` | cor de fundo da splash no **tema claro**. |
| `image` | imagem centralizada no **tema claro**. |
| `color_dark` | cor de fundo no **modo escuro**. Gera os recursos em `-night`. |
| `image_dark` | imagem no modo escuro. Útil quando o logo é escuro e sumiria no fundo preto. |
| `android_12:` | seção separada, usada **só** por aparelhos com Android 12+. |
| `android_12.color` | cor de fundo da splash padronizada do Android 12+. |
| `android_12.image` | o **ícone** centralizado. Lembre: é ícone, não ilustração. |
| `android_12.icon_background_color` | cor do círculo atrás do ícone. Igualar a `color` faz o círculo desaparecer visualmente. |
| `android_12.color_dark` / `icon_background_color_dark` | os equivalentes no modo escuro. |
| `android` / `ios` / `web` | quais plataformas receber os arquivos. `web: false` porque o Foco é um app mobile. |

**Por que `color_dark: "#121212"`?** `#121212` é o cinza quase-preto que o Material Design usa como
fundo de superfície no tema escuro. Preto puro (`#000000`) em tela OLED produz um contraste duro e
faz a transição para a primeira tela do app "piscar". A recomendação de Material 3 é usar um cinza
muito escuro.

> ⚠️ **As cores precisam de aspas.** Sem aspas, o YAML lê `#` como início de comentário e a chave
> fica sem valor.

### Passo 5 — Gerar

```powershell
flutter pub get
dart run flutter_native_splash:create
```

Repare na sintaxe: `flutter_native_splash:create` — o pacote tem mais de um executável, e `:create`
seleciona qual rodar. Isso é diferente do `flutter_launcher_icons`, que tem um só.

Saída esperada, terminando com a confirmação:

```text
[Android] Creating default split screen images
[Android] Creating dark mode split screen images
[Android] Creating android 12 split screen images
[iOS] Creating images
[iOS] Updating Info.plist for status bar hidden/visible

✓ Native splash complete.
Now go finish building something awesome! 💪 You rock! 🤘🤩
```

### Passo 6 — A lista exata de arquivos gerados

**🤖 Android:**

```text
android/app/src/main/res/drawable/launch_background.xml
android/app/src/main/res/drawable-v21/launch_background.xml
android/app/src/main/res/drawable-night/launch_background.xml
android/app/src/main/res/drawable-night-v21/launch_background.xml
android/app/src/main/res/values/styles.xml
android/app/src/main/res/values-night/styles.xml
android/app/src/main/res/values-v31/styles.xml
android/app/src/main/res/values-night-v31/styles.xml
```

Mais as imagens da splash em cada densidade, dentro de `drawable-*/`.

O que cada grupo faz:

| Arquivo | Usado por | Papel |
|---|---|---|
| `drawable/launch_background.xml` | Android antigo | desenha fundo + imagem |
| `drawable-v21/launch_background.xml` | API 21+ | mesma coisa, com recursos de API 21 |
| `drawable-night*/launch_background.xml` | modo escuro | versão escura |
| `values/styles.xml` | todos | define o tema da `MainActivity`, apontando para o drawable |
| `values-night/styles.xml` | modo escuro | tema escuro |
| `values-v31/styles.xml` | **Android 12+** | usa os atributos `windowSplashScreen*` |
| `values-night-v31/styles.xml` | Android 12+ escuro | idem |

Abra o `values/styles.xml` gerado para ver o mecanismo antigo:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

- `LaunchTheme` é o tema aplicado à `MainActivity` **enquanto o Flutter carrega**. O
  `android:windowBackground` é a splash — é literalmente o fundo da janela.
- `NormalTheme` é trocado assim que o Flutter assume, e o fundo volta ao normal.
- A troca entre os dois é feita pelo próprio código de inicialização do Flutter, declarado no
  `AndroidManifest.xml`. **Não mexa nisso à mão.**

E o `values-v31/styles.xml`, com o mecanismo novo:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowSplashScreenBackground">@color/splash_background</item>
        <item name="android:windowSplashScreenAnimatedIcon">@drawable/android12splash</item>
        <item name="android:windowSplashScreenIconBackgroundColor">@color/splash_icon_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

Repare que os nomes dos atributos são completamente diferentes: `windowSplashScreenBackground`,
`windowSplashScreenAnimatedIcon`, `windowSplashScreenIconBackgroundColor`. Não existe mais
`windowBackground` livre — essa é a mudança do Android 12 em uma linha de XML.

**🍎 iOS:** o gerador também escreve as imagens de splash e **altera o `ios/Runner/Info.plist`**
(configuração da barra de status). O storyboard usado é
`ios/Runner/Base.lproj/LaunchScreen.storyboard`.

### Passo 7 — Remover a splash

Se você quiser desfazer tudo e voltar ao estado padrão do Flutter:

```powershell
dart run flutter_native_splash:remove
```

O comando restaura os arquivos nativos ao que o `flutter create` gera. Use quando quiser recomeçar
do zero, ou quando estiver testando configurações diferentes.

> Não é preciso rodar `:remove` antes de rodar `:create` de novo. O `:create` sobrescreve.

### Passo 8 — Conferir no aparelho

```powershell
flutter clean
flutter run
```

O `flutter clean` é necessário: o Gradle guarda os recursos processados em cache e pode reaproveitar
a splash antiga.

Para ver a splash de verdade, você precisa de um **cold start** — o app fechado de verdade, não
apenas em segundo plano:

```powershell
adb shell am force-stop br.com.estudos.foco
adb shell am start -n br.com.estudos.foco/.MainActivity
```

- `am force-stop` encerra o processo do app.
- `am start -n <pacote>/<atividade>` abre a atividade principal.

Observe a tela no instante da abertura. Em um aparelho rápido, a splash aparece por uma fração de
segundo — o que é **bom**: significa que o app carrega rápido.

**Para conferir o modo escuro:** ative o tema escuro do sistema (Configurações → Tela → Tema escuro)
e repita o `force-stop` + `start`. A splash deve usar `#121212`.

---

## 💻 Código completo

O `pubspec.yaml` do **Foco** com os **dois** blocos de primeiro nível — ícone (Aula 3) e splash
(esta aula) — lado a lado, como eles realmente ficam no projeto.

> **Arquivo:** `pubspec.yaml`
> **Como executar:** `flutter pub get` · `dart run flutter_launcher_icons` · `dart run flutter_native_splash:create`

```yaml
name: foco
description: "Foco — organizador de sessões de estudo."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.13.0

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

flutter:
  uses-material-design: true
  assets:
    - assets/icone/

# ⬇️ PRIMEIRO NÍVEL — ícone do app (Aula 3)
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icone/icone.png"
  min_sdk_android: 24
  remove_alpha_ios: true
  adaptive_icon_background: "#3F51B5"
  adaptive_icon_foreground: "assets/icone/icone.png"

# ⬇️ PRIMEIRO NÍVEL — splash nativa (esta aula)
flutter_native_splash:
  # Tema claro: cor de fundo e imagem centralizada.
  color: "#3F51B5"
  image: assets/icone/splash.png

  # Tema escuro: gera os recursos nas pastas -night.
  color_dark: "#121212"
  image_dark: assets/icone/splash.png

  # Android 12+ mudou o mecanismo: só cor de fundo + ícone centralizado.
  # Esta seção alimenta values-v31/styles.xml e values-night-v31/styles.xml.
  android_12:
    color: "#3F51B5"
    image: assets/icone/splash.png
    icon_background_color: "#3F51B5"
    color_dark: "#121212"
    icon_background_color_dark: "#121212"

  # Plataformas que recebem os arquivos.
  android: true
  ios: true
  web: false
```

E a tela de carregamento **em Flutter**, que é o outro lado da moeda — ela cobre o tempo de abrir o
banco e ler as preferências, **depois** que a splash nativa já saiu:

> **Arquivo:** `lib/core/widgets/carregando.dart`
> **Como executar:** `flutter run`

```dart
import 'package:flutter/material.dart';

/// Tela de carregamento do próprio app (NÃO é a splash nativa).
///
/// A splash nativa some no primeiro frame do Flutter. Este widget é o primeiro
/// frame: ele fica visível enquanto o app abre o banco, lê as preferências e
/// decide qual tela mostrar.
class Carregando extends StatelessWidget {
  const Carregando({super.key, this.mensagem = 'Preparando seus estudos...'});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      // A MESMA cor da splash nativa: a transição fica imperceptível.
      backgroundColor: esquema.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/icone/splash.png',
              width: 120,
              height: 120,
              // Se o asset faltar, o app NÃO pode quebrar na abertura.
              errorBuilder: (_, _, _) => Icon(
                Icons.center_focus_strong,
                size: 120,
                color: esquema.onPrimary,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(esquema.onPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: esquema.onPrimary),
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

Sobre o `pubspec.yaml`:

- Os dois blocos geradores ficam **fora** de `flutter:`, na coluna 1. É o mesmo erro da Aula 3, e
  vale repetir: YAML define hierarquia por indentação.
- `image_dark` aponta para o mesmo arquivo de `image` neste exemplo. Em um app com logo escuro, você
  criaria `splash_claro.png` e `splash_escuro.png`.
- Em `android_12`, `icon_background_color` igual a `color` faz o círculo atrás do ícone sumir
  visualmente. Se você quiser um contraste (ícone claro sobre círculo branco em fundo azul), use
  valores diferentes.
- `web: false` evita gerar arquivos numa plataforma que o Foco não usa. Se o projeto não tiver a
  pasta `web/`, o gerador ignora de qualquer forma — mas ser explícito documenta a intenção.

Sobre o `carregando.dart`:

- `backgroundColor: esquema.primary` usa a **mesma cor** da splash nativa (`#3F51B5`, que no tema do
  Foco é a cor primária). Resultado: quando a splash nativa some e o Flutter assume, o usuário não vê
  nenhum pulo de cor. Esse detalhe é o que separa um app com acabamento de um app "engasgado".
- `Image.asset(...)` com `errorBuilder` — se o arquivo `splash.png` faltar, o widget cai no ícone
  padrão em vez de lançar exceção. Uma exceção na **primeira tela** é o pior lugar possível para um
  erro: o app parece quebrado antes de abrir.
- `errorBuilder: (_, _, _) => ...` usa três `_`. Com `flutter_lints ^6.0.0`, escrever `(_, __, ___)`
  dispara o lint `unnecessary_underscores`. Escreva `_` repetido.
- `CircularProgressIndicator.adaptive()` desenha o indicador no estilo nativo de cada plataforma:
  circular Material no Android, indicador do Cupertino no iOS.
- `AlwaysStoppedAnimation<Color>(esquema.onPrimary)` fixa a cor do indicador. `onPrimary` é a cor
  que o Material 3 garante ter contraste suficiente sobre `primary`.
- `const SizedBox(height: 32)` — todo widget que não depende de variável é `const`, pelo motivo
  explicado em
  [Módulo 13, aula 01](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md).

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Mecanismo (antigo) | `windowBackground` no tema da Activity | `LaunchScreen.storyboard` |
| Mecanismo (atual) | Android 12+: `windowSplashScreen*` em `values-v31/` | o mesmo storyboard |
| Modo escuro | pastas `-night` | variação no storyboard / imagens |
| Arquivo principal | `res/values/styles.xml` + `res/drawable/launch_background.xml` | `ios/Runner/Base.lproj/LaunchScreen.storyboard` |
| Chave no `Info.plist` | — | `UILaunchStoryboardName` = `LaunchScreen` |
| Gerado pelo pacote no Windows | sim | **sim** (é só escrita de arquivo) |
| Visualizável no Windows | sim | **não** |

> 🍎 **O que você consegue fazer no Windows:** o `flutter_native_splash:create` gera os arquivos do
> iOS normalmente — imagens, storyboard e a alteração no `Info.plist`. Commite tudo.
> **O que exige Mac:** ver a splash rodando em um iPhone ou no simulador, e ajustar o storyboard no
> Xcode se você quiser um layout customizado. Isso está em
> [15-build-ios/05-icone-splash-versao-infoplist.md](../15-build-ios/05-icone-splash-versao-infoplist.md).

---

## ⚠️ Erros comuns

**1. Bloco `flutter_native_splash:` indentado dentro de `flutter:`.**
O gerador não encontra a configuração e usa os valores padrão (fundo branco, sem imagem), sem avisar
com clareza. Mova para a coluna 1.

**2. Cor sem aspas.**

```yaml
color: #3F51B5      # ❌ o YAML lê como comentário; a chave fica vazia
color: "#3F51B5"    # ✅
```

**3. Esperar que a splash nativa dure X segundos.**
Ela não tem duração. Some no primeiro frame do Flutter. Para controlar tempo, use a tela em Flutter.

**4. Colocar uma ilustração larga na seção `android_12:`.**
O Android 12+ mostra só um ícone centralizado, com máscara. Uma imagem larga sai cortada ou
minúscula. Use um símbolo quadrado com margem.

**5. Não ver a splash porque o app estava em segundo plano.**
Voltar para um app que já estava carregado **não** mostra splash. Force um cold start com
`adb shell am force-stop`.

**6. Esquecer o `flutter clean`.**
Recursos nativos em cache fazem você ver a splash antiga e achar que o comando não funcionou.

**7. Editar `launch_background.xml` ou `styles.xml` à mão.**
Qualquer nova execução de `:create` sobrescreve. Mude a **configuração** e gere de novo.

**8. Confundir `:create` com o nome do pacote.**

```powershell
dart run flutter_native_splash          # ❌ não existe executável com esse nome
dart run flutter_native_splash:create   # ✅
```

**9. Splash escura não aparece.**
Verifique se o **sistema** está em modo escuro, não só o app. As pastas `-night` são escolhidas pelo
tema do **sistema operacional**.

---

## 🛠️ Exercício guiado

Objetivo: dar ao **Foco** uma splash nativa com modo escuro, conferir os arquivos e ver o resultado
nos dois temas.

**Passo 1 — Estado inicial.** Liste o que existe hoje:

```powershell
Get-ChildItem -Recurse android\app\src\main\res -Filter "launch_background.xml" |
  Select-Object FullName
Get-ChildItem -Recurse android\app\src\main\res -Filter "styles.xml" | Select-Object FullName
```

Saída esperada no projeto padrão do Flutter (4 arquivos, **sem** as variantes `-night` e `-v31`):

```text
...\res\drawable\launch_background.xml
...\res\drawable-v21\launch_background.xml
...\res\values\styles.xml
...\res\values-night\styles.xml
```

**Passo 2 — Crie `assets/icone/splash.png`**, PNG com fundo transparente e o símbolo do Foco nos 66%
centrais.

**Passo 3 — Adicione o bloco `flutter_native_splash:`** ao `pubspec.yaml`, na coluna 1, com a
configuração completa da seção "Código completo".

**Passo 4 — Gere.**

```powershell
flutter pub get
dart run flutter_native_splash:create
```

Confira a última linha: `✓ Native splash complete.`

**Passo 5 — Confirme os arquivos novos.**

```powershell
Get-ChildItem -Recurse android\app\src\main\res -Filter "styles.xml" | Select-Object FullName
```

Saída esperada: agora são **4** arquivos `styles.xml`, incluindo os dois de Android 12+:

```text
...\res\values\styles.xml
...\res\values-night\styles.xml
...\res\values-v31\styles.xml
...\res\values-night-v31\styles.xml
```

**Passo 6 — Leia o XML do Android 12.**

```powershell
Get-Content android\app\src\main\res\values-v31\styles.xml
```

Aponte na saída os três atributos que começam com `windowSplashScreen`. Compare com o
`values/styles.xml`, que usa `windowBackground`. **Essa é a mudança do Android 12, no concreto.**

**Passo 7 — Instale e force um cold start.**

```powershell
flutter clean
flutter run
```

Encerre o `flutter run` com `q` e, com o aparelho ainda conectado:

```powershell
adb shell am force-stop br.com.estudos.foco
adb shell am start -n br.com.estudos.foco/.MainActivity
```

**Como confirmar que funcionou:** no instante da abertura você vê o fundo azul `#3F51B5` com o
símbolo no meio, e logo em seguida a tela do app — **sem piscar branco**.

**Passo 8 — Teste o modo escuro.** Ative o tema escuro do sistema no aparelho e repita o Passo 7. O
fundo deve ser `#121212`.

**Passo 9 — Teste o `:remove`.**

```powershell
dart run flutter_native_splash:remove
Get-ChildItem -Recurse android\app\src\main\res -Filter "styles.xml" | Select-Object FullName
```

Os arquivos `-v31` somem. Depois rode `:create` de novo para deixar o projeto no estado final.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-android.md](../../exercicios/14-build-android.md)

Faça os exercícios sobre a diferença entre splash nativa e tela de carregamento, e o de aplicação
com modo escuro.

---

## 🏆 Desafio opcional

Encadeie corretamente a splash nativa com uma tela de carregamento em Flutter, de forma que o
usuário não perceba a costura entre as duas.

Requisitos:

1. A splash nativa usa `#3F51B5` no claro e `#121212` no escuro.
2. A primeira tela em Flutter (`Carregando`) usa **exatamente** as mesmas cores, escolhendo pelo
   `Theme.of(context).brightness`.
3. Enquanto `Carregando` está na tela, o app realmente faz trabalho: abre o banco `sqflite` e lê a
   meta semanal de `shared_preferences`.
4. Quando terminar, navegue para a `home` **substituindo** a rota
   (`Navigator.pushReplacementNamed`), para que o botão Voltar não traga a tela de carregamento de
   volta.
5. Se o carregamento falhar, mostre uma tela de erro com botão "Tentar de novo" — use o widget
   `EstadoErro` de `lib/core/widgets/estado_erro.dart`.

Critério de sucesso: gravando a tela do aparelho e assistindo quadro a quadro, não existe nenhum
frame branco entre o toque no ícone e a tela inicial.

---

## 📌 Resumo

- A **splash nativa** é desenhada pelo **sistema operacional** no intervalo entre o toque no ícone e
  o primeiro frame do Flutter. Sem ela, o usuário vê tela branca.
- Ela **não tem duração configurável**: some quando o Flutter desenha. Controlar tempo é trabalho da
  **tela de carregamento em Flutter**, que é um widget e vem depois.
- 🔴 O **Android 12+ mudou o mecanismo**: em vez de um fundo de janela livre, o sistema desenha uma
  **cor de fundo + o ícone centralizado**, padronizado. Por isso existe a seção `android_12:`, que
  alimenta `values-v31/styles.xml`.
- O sufixo `-v31` nas pastas significa "só para API 31 ou superior"; `-night` significa modo escuro.
- Configuração: bloco `flutter_native_splash:` de **primeiro nível**, com `color`, `image`,
  `color_dark`, `image_dark`, `android_12:` e as plataformas.
- Comandos: `dart run flutter_native_splash:create` e `dart run flutter_native_splash:remove`.
- Arquivos gerados: `drawable*/launch_background.xml` (4 variações) e `values*/styles.xml`
  (4 variações), mais as imagens por densidade. No iOS, imagens e uma alteração no `Info.plist`.
- Sempre `flutter clean` antes de conferir, e force um **cold start** para ver a splash.

---

## ☑️ Checklist de domínio

- [ ] Explico o que acontece entre o toque no ícone e o primeiro frame do Flutter.
- [ ] Digo três diferenças entre splash nativa e tela de carregamento em Flutter.
- [ ] Explico por que a splash nativa não pode durar "3 segundos".
- [ ] Explico o que mudou no Android 12 e por que existe a seção `android_12:`.
- [ ] Digo o que significam os sufixos `-v31` e `-night` nos nomes de pasta.
- [ ] Escrevo o bloco `flutter_native_splash:` completo, na coluna certa.
- [ ] Rodo `:create` e `:remove` e sei a diferença.
- [ ] Listo os arquivos gerados no Android e digo qual deles o Android 12 usa.
- [ ] Forço um cold start com `adb shell am force-stop` + `am start`.
- [ ] Vi a splash nos dois temas, claro e escuro, no meu aparelho.

---

## 📚 Referências oficiais

- [Android Developers — Splash screens](https://developer.android.com/develop/ui/views/launch/splash-screen)
- [Android Developers — Migrate your splash screen implementation](https://developer.android.com/develop/ui/views/launch/splash-screen/migrate)
- [Android Developers — App resources: alternative resources](https://developer.android.com/guide/topics/resources/providing-resources#AlternativeResources)
- [pub.dev — flutter_native_splash](https://pub.dev/packages/flutter_native_splash)
- [Flutter — Adding a splash screen to your Android app](https://docs.flutter.dev/platform-integration/android/splash-screen)
- [Material Design 3 — Color roles](https://m3.material.io/styles/color/roles)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Ícone](03-icone.md) | [README](README.md) | [Permissões Android](05-permissoes-android.md) |
