# Aula 3 — Ícone

> **Módulo:** 14 - Build e Distribuição Android · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Listar os **requisitos da imagem de origem**: PNG quadrado, 1024×1024, sem transparência para iOS.
- Explicar o que é o **ícone adaptativo** do Android 8+, suas duas camadas e a **margem de segurança
  de ~66%**.
- Explicar o que são as **densidades** `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi` e por que um PNG
  vira várias imagens.
- Configurar o bloco `flutter_launcher_icons` no `pubspec.yaml` como bloco de **primeiro nível**, sem
  cair no erro de indentação.
- Rodar `dart run flutter_launcher_icons` e **reconhecer a saída real** do gerador.
- Nomear a **lista exata de arquivos gerados** no Android e no iOS.
- Conferir o ícone novo no aparelho e saber o que fazer quando o ícone antigo insiste em aparecer.

## ✅ Pré-requisitos

- [Aula 2 — Identidade do app](02-identidade-do-app.md) concluída, com `applicationId` definitivo.
  Gerar o ícone **antes** de fechar a identidade dá retrabalho, porque o gerador escreve dentro da
  árvore de recursos do app.
- Projeto compilando com `flutter run`.
- Um editor de imagem qualquer capaz de exportar PNG 1024×1024 (Paint 3D, GIMP, Figma, Canva —
  qualquer um serve).

---

## 📖 Conceito

### O ícone não é um arquivo — é um conjunto

Quando você instala um app, o Android precisa desenhar o ícone dele em contextos muito diferentes:
na tela inicial, na gaveta de apps, nas configurações, na notificação, na lista de apps recentes, na
Play Store. Cada contexto pede um tamanho, e cada aparelho tem uma densidade de tela diferente.

Se o sistema tivesse que redimensionar uma imagem grande toda vez, o resultado ficaria borrado e
custaria processamento. Por isso o Android exige que o app **já traga** o ícone pronto em vários
tamanhos, em pastas com nomes padronizados.

Gerar essas imagens à mão é trabalhoso e fácil de errar. O pacote **`flutter_launcher_icons`** faz
isso a partir de **um** arquivo de origem.

### Densidades de tela: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi

**Densidade** (*dpi*, *dots per inch* — pontos por polegada) é quantos pixels físicos o aparelho tem
em cada polegada de tela. Dois celulares do mesmo tamanho físico podem ter contagens de pixels muito
diferentes.

O Android agrupa os aparelhos em faixas de densidade e escolhe automaticamente a pasta de recursos
correspondente:

| Pasta | Sigla | Fator | Tamanho do ícone de launcher | Aparelhos típicos |
|---|---|---|---|---|
| `mipmap-mdpi` | **m**edium | 1× | 48×48 px | telas antigas, referência base |
| `mipmap-hdpi` | **h**igh | 1,5× | 72×72 px | aparelhos de entrada antigos |
| `mipmap-xhdpi` | e**x**tra high | 2× | 96×96 px | intermediários |
| `mipmap-xxhdpi` | 2× extra high | 3× | 144×144 px | maioria dos aparelhos atuais |
| `mipmap-xxxhdpi` | 3× extra high | 4× | 192×192 px | topo de linha |

O **`mdpi` é a referência**: todos os outros são múltiplos dele. O sistema lê a densidade do
aparelho, vai na pasta certa e usa aquele PNG sem redimensionar nada.

> Por que `mipmap` e não `drawable`? Ícones de launcher ficam em `mipmap/` porque essa pasta tem um
> tratamento especial: o Android mantém **todas** as densidades no APK instalado, mesmo as que o
> aparelho não usa. Isso existe porque alguns launchers (as telas iniciais alternativas) desenham o
> ícone maior do que a densidade nativa. Recursos comuns ficam em `drawable/`.

### Ícone adaptativo (Android 8.0+)

Antes do Android 8, cada fabricante recortava o ícone do seu jeito, e o resultado era uma tela
inicial com ícones de formatos misturados — uns redondos, uns quadrados, uns com borda branca.

O **ícone adaptativo** (*adaptive icon*) resolveu isso: em vez de uma imagem pronta, o app fornece
**duas camadas**:

```text
+-----------------------------+
|  camada de FRENTE           |  <- o desenho (logo, símbolo)
|  (foreground)               |
+-----------------------------+
|  camada de FUNDO            |  <- cor sólida ou imagem
|  (background)               |
+-----------------------------+
```

O sistema empilha as duas e **recorta o conjunto** na máscara que o fabricante definiu: círculo,
quadrado arredondado, gota, hexágono. O launcher também pode animar as camadas separadamente
(paralaxe quando você arrasta o ícone, por exemplo).

### 🔴 A margem de segurança de ~66%

Esta é a parte que todo mundo erra na primeira vez.

Cada camada do ícone adaptativo é uma imagem de **108×108 dp** (*density-independent pixels* —
unidade lógica do Android, independente da densidade). Mas a máscara de recorte só garante que os
**72×72 dp centrais** apareçam. Os 18 dp de cada lado podem ser cortados, dependendo da máscara.

```text
108 dp de largura total
|<------------------------------------------------->|
|  18 dp  |         72 dp (zona segura)     |  18 dp |
|  CORTE  |    é aqui que o desenho vai     |  CORTE |
```

72 / 108 ≈ **0,666**, ou seja **~66%**. Daí a regra:

> **Mantenha todo o desenho significativo dentro dos ~66% centrais da imagem.** Deixe ~17% de margem
> vazia de cada lado.

Se você enviar um logo que ocupa a imagem inteira, em um aparelho com máscara de círculo o logo vai
aparecer **cortado nas bordas**. E você só vai descobrir quando alguém com aquele aparelho reclamar.

### Requisitos da imagem de origem

| Requisito | Valor | Por quê |
|---|---|---|
| Formato | **PNG** | suporta transparência e é o formato que o gerador aceita |
| Tamanho | **1024×1024 px** | é o maior tamanho exigido (pela App Store); tudo o mais é reduzido a partir dele |
| Proporção | **quadrada** | imagem retangular sai distorcida |
| Transparência (iOS) | **não pode** | a Apple **rejeita** ícone com canal alfa |
| Transparência (Android) | pode, na camada de frente | o fundo vem da outra camada |
| Margem de segurança | ~17% de cada lado | por causa do recorte adaptativo |
| Texto pequeno | evite | em 48×48 px vira borrão |

**Por que 1024×1024 e não 512?** Porque reduzir preserva qualidade e ampliar não. Partindo de 1024,
o gerador produz 192, 144, 96, 72 e 48 com nitidez. Partindo de 512, o ícone de 1024 do iOS teria
que ser ampliado e ficaria borrado.

**Por que sem transparência para iOS?** A Apple exige ícone **opaco**. Um PNG com canal alfa faz o
envio para a App Store falhar. Por isso a configuração do curso usa `remove_alpha_ios: true`, que
manda o gerador achatar o alfa contra um fundo antes de escrever o arquivo do iOS.

---

## 💡 Analogia

Pense em uma logomarca impressa.

Você não manda para a gráfica um JPEG de tela; manda um **arquivo vetorial grande**, e a gráfica
gera a versão do cartão de visita, do banner e do outdoor a partir dele. O PNG de 1024×1024 é esse
arquivo-mestre, e o `flutter_launcher_icons` é a gráfica.

A **margem de segurança** é o que os designers gráficos chamam de *sangria* e *área de segurança*: a
guilhotina corta o papel com alguns milímetros de variação, então nada importante pode encostar na
borda. A máscara do launcher é a guilhotina, e ela varia de fabricante para fabricante.

---

## 🧪 Exemplo mínimo

Instalar o gerador e rodá-lo são dois comandos:

```powershell
flutter pub add dev:flutter_launcher_icons
dart run flutter_launcher_icons
```

`dev:` na frente do nome coloca o pacote em `dev_dependencies` — dependências que só o
desenvolvedor usa e que **não entram no app publicado**. Um gerador de ícone é exatamente isso: ele
roda na sua máquina e escreve arquivos; o app final não precisa dele.

Mas antes de rodar, é preciso dizer ao gerador **qual imagem usar**. Essa configuração vai no
`pubspec.yaml`, e é aí que mora o erro número 1.

---

## 📱 Aplicando no Flutter

### Passo 1 — Preparar a imagem

Crie a pasta e coloque o arquivo:

**🪟 Windows (PowerShell)**

```powershell
New-Item -ItemType Directory -Force assets\icone
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
mkdir -p assets/icone
```

Salve o seu PNG 1024×1024 como `assets/icone/icone.png`.

Sugestão para o **Foco**: um alvo com uma seta no centro, ou a letra "F" em branco sobre fundo azul
`#3F51B5`, com o desenho ocupando os 66% centrais.

Confirme o tamanho antes de continuar:

**🪟 Windows (PowerShell)**

```powershell
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("$PWD\assets\icone\icone.png")
"$($img.Width) x $($img.Height)"
$img.Dispose()
```

Saída esperada:

```text
1024 x 1024
```

### Passo 2 — Declarar as dependências

No `pubspec.yaml`, dentro de `dev_dependencies`:

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

### Passo 3 — 🔴 O bloco de configuração é de PRIMEIRO NÍVEL

Este é o erro número 1 desta aula. O bloco `flutter_launcher_icons:` **não fica dentro de
`flutter:`**. Ele fica no **primeiro nível** do arquivo, alinhado com `name:`, `dependencies:` e
`flutter:`, ou seja, **sem nenhum espaço antes do nome**.

**❌ ERRADO — dentro de `flutter:`:**

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icone/
  flutter_launcher_icons:      # <- ERRADO: está indentado dentro de flutter:
    image_path: "assets/icone/icone.png"
```

Resultado ao rodar o gerador:

```text
✗ Could not find a config file. Create a `flutter_launcher_icons.yaml` file or add a
  `flutter_launcher_icons` section to your `pubspec.yaml`.
```

A mensagem é confusa porque o bloco **está** no `pubspec.yaml` — só que no lugar errado, e o
carregador de YAML procura a chave na raiz do documento.

**✅ CERTO — no primeiro nível:**

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icone/

flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icone/icone.png"
  min_sdk_android: 24
  remove_alpha_ios: true
  adaptive_icon_background: "#3F51B5"
  adaptive_icon_foreground: "assets/icone/icone.png"
```

Repare: `flutter_launcher_icons:` começa na **coluna 1**, igual a `flutter:`. A linha em branco
antes dele não é obrigatória, mas ajuda a enxergar o nível.

### Passo 4 — Entender cada chave

| Chave | Valor | O que faz |
|---|---|---|
| `android` | `"ic_launcher"` | nome-base dos arquivos gerados no Android. `ic_launcher` é o nome que o `AndroidManifest.xml` já referencia em `android:icon="@mipmap/ic_launcher"`. |
| `ios` | `true` | gera também o conjunto de ícones do iOS. |
| `image_path` | `"assets/icone/icone.png"` | a imagem de origem. |
| `min_sdk_android` | `24` | precisa **bater com o `minSdk` do projeto** (24 no Flutter 3.47). O gerador usa isso para decidir se produz ícone adaptativo. |
| `remove_alpha_ios` | `true` | **obrigatório** para a App Store: achata a transparência no ícone do iOS. |
| `adaptive_icon_background` | `"#3F51B5"` | a camada de fundo. Aceita uma cor em hexadecimal **ou** um caminho de imagem. |
| `adaptive_icon_foreground` | `"assets/icone/icone.png"` | a camada de frente — o desenho. |

> ⚠️ `min_sdk_android` **diferente** do `minSdk` real do projeto é um erro silencioso: o ícone é
> gerado, mas sem a variante adaptativa, e você só descobre olhando o ícone quadrado no meio de
> ícones redondos.

### Passo 5 — Rodar o gerador

```powershell
flutter pub get
dart run flutter_launcher_icons
```

**Saída real do gerador** (executada com sucesso nesta máquina, `flutter_launcher_icons 0.14.4`):

```text
════════════════════════════════════════════
   FLUTTER LAUNCHER ICONS (v0.14.4)
════════════════════════════════════════════

• Creating default icons Android
• Creating adaptive icons Android
• Adding a new Android launcher icon
• No colors.xml file found in your Android project
• Creating colors.xml file and adding it to your Android project
• Creating mipmap xml file Android
• Overwriting default iOS launcher icon with new icon
No platform provided

✓ Successfully generated launcher icons
```

> ⚠️ A linha **`No platform provided` é normal e não é erro.** Ela aparece porque o gerador aceita
> flags de plataforma na linha de comando e você não passou nenhuma — então ele usou a configuração
> do `pubspec.yaml`, que é o comportamento desejado. A linha que importa é a última:
> `✓ Successfully generated launcher icons`.

A linha `No colors.xml file found` também é normal em projeto novo: o gerador cria o arquivo.

### Passo 6 — A lista exata de arquivos gerados

**🤖 Android:**

```text
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
android/app/src/main/res/drawable-mdpi/ic_launcher_foreground.png
android/app/src/main/res/drawable-hdpi/ic_launcher_foreground.png
android/app/src/main/res/drawable-xhdpi/ic_launcher_foreground.png
android/app/src/main/res/drawable-xxhdpi/ic_launcher_foreground.png
android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png
android/app/src/main/res/values/colors.xml
```

O que cada grupo é:

- **`mipmap-*/ic_launcher.png`** — o ícone "clássico", usado no Android 7 e anterior, e como reserva.
- **`mipmap-anydpi-v26/ic_launcher.xml`** — a **declaração do ícone adaptativo**. O sufixo `-v26`
  significa "só para API 26 (Android 8.0) ou superior"; `anydpi` significa "vale para qualquer
  densidade", porque é XML, não bitmap. O conteúdo aponta para as duas camadas.
- **`drawable-*/ic_launcher_foreground.png`** — a camada de frente, em cada densidade.
- **`values/colors.xml`** — guarda a cor de fundo do ícone adaptativo (`#3F51B5`), referenciada pelo
  XML acima.

Abra o XML gerado para entender:

```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
```

- `<background>` aponta para a cor definida em `colors.xml`.
- `<foreground>` aponta para o PNG da camada de frente.
- O sistema empilha e recorta — exatamente o mecanismo descrito no Conceito.

**🍎 iOS** (gerado mesmo no Windows, porque é só escrita de arquivo):

```text
ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png   (e @2x, @3x)
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png   (e @2x, @3x)
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png   (e @2x, @3x)
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@1x.png   (e demais tamanhos)
```

**@1x, @2x, @3x** são as escalas de tela da Apple — o equivalente das densidades do Android. Um
iPhone moderno usa **@3x**. O tamanho em **pontos** (20, 29, 40...) multiplicado pela escala dá o
tamanho em pixels: `Icon-App-40x40@3x.png` tem 120×120 px.

`Contents.json` é o índice que o Xcode lê para saber qual arquivo corresponde a qual uso.

### Passo 7 — Conferir no aparelho

```powershell
flutter clean
flutter run
```

O `flutter clean` aqui **não é opcional**: o Gradle guarda recursos processados em cache, e sem
limpar você pode ver o ícone antigo mesmo com os arquivos novos no disco.

No aparelho, saia do app e olhe a tela inicial e a gaveta de apps. O ícone novo deve estar lá, com o
nome **Foco** embaixo.

**Se o ícone antigo insistir em aparecer:**

1. Desinstale o app pelo aparelho ou por `adb uninstall br.com.estudos.foco`.
2. Rode `flutter clean` e `flutter run` de novo.
3. Alguns launchers guardam cache próprio de ícones. Reiniciar o aparelho resolve.

---

## 💻 Código completo

O `pubspec.yaml` do **Foco** com o bloco de ícones no lugar certo. Repare na coluna em que cada
chave de primeiro nível começa.

> **Arquivo:** `pubspec.yaml`
> **Como executar:** `flutter pub get` e depois `dart run flutter_launcher_icons`

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

# ⬇️ BLOCO DE PRIMEIRO NÍVEL — alinhado com "flutter:", NÃO dentro dele.
flutter_launcher_icons:
  # Nome-base dos arquivos no Android. Bate com android:icon="@mipmap/ic_launcher".
  android: "ic_launcher"
  # Gera também o conjunto do iOS (funciona no Windows: é só escrita de arquivo).
  ios: true
  # Imagem de origem: PNG quadrado 1024x1024.
  image_path: "assets/icone/icone.png"
  # Precisa ser IGUAL ao minSdk do projeto (24 no Flutter 3.47).
  min_sdk_android: 24
  # Obrigatório para a App Store: a Apple rejeita ícone com transparência.
  remove_alpha_ios: true
  # Camada de FUNDO do ícone adaptativo (cor sólida ou caminho de imagem).
  adaptive_icon_background: "#3F51B5"
  # Camada de FRENTE do ícone adaptativo (o desenho, com margem de ~17% nas bordas).
  adaptive_icon_foreground: "assets/icone/icone.png"
```

---

## 🔍 Explicando o código

- `assets: - assets/icone/` dentro de `flutter:` declara a pasta como **asset** do app. Isso é o que
  permite ao código Dart carregar a imagem em tempo de execução (`Image.asset`). Para o gerador de
  ícones, essa declaração **não é necessária** — ele lê o arquivo do disco durante o build. Mas a
  splash da [Aula 4](04-splash-screen.md) usa a mesma pasta, e manter declarada evita surpresa.
- A barra final em `assets/icone/` declara a **pasta inteira**. Sem a barra, o Flutter espera um
  arquivo com esse nome exato.
- `flutter_launcher_icons:` na **coluna 1** é o ponto crítico. YAML define hierarquia por
  indentação: uma chave indentada é filha da chave acima. Colocá-la dentro de `flutter:` a torna
  invisível para o gerador.
- `android: "ic_launcher"` poderia ser `true` (usa o nome padrão) ou um nome customizado. Usar
  `"ic_launcher"` explicitamente garante que o `AndroidManifest.xml`, que já referencia
  `@mipmap/ic_launcher`, encontre o arquivo.
- `adaptive_icon_background: "#3F51B5"` — a cor em hexadecimal precisa das **aspas**, senão o YAML
  interpreta o `#` como início de comentário e a chave fica sem valor.
- Usar a **mesma imagem** em `image_path` e `adaptive_icon_foreground` funciona e é o caminho mais
  simples. Para um resultado profissional, use duas imagens: uma completa (com fundo) em
  `image_path`, e outra só com o símbolo e fundo transparente em `adaptive_icon_foreground`.

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Unidade de variação | densidade (`mdpi` → `xxxhdpi`) | escala (`@1x`, `@2x`, `@3x`) |
| Pasta dos arquivos | `android/app/src/main/res/mipmap-*/` | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Índice | nenhum (o nome da pasta basta) | `Contents.json` |
| Camadas | duas (fundo + frente) desde o Android 8 | uma imagem única |
| Máscara aplicada | varia por fabricante | fixa: quadrado com cantos arredondados |
| Transparência | permitida | **proibida** — a Apple rejeita |
| Referenciado em | `android:icon="@mipmap/ic_launcher"` | `AppIcon` no target do Xcode |

> 🍎 **O que você consegue fazer no Windows:** o `flutter_launcher_icons` **gera os arquivos do iOS
> normalmente** no Windows — ele só escreve PNGs e um JSON, não precisa do Xcode. Commite esses
> arquivos. Quando você tiver acesso a um Mac, eles já vão estar lá.
> **O que exige Mac:** *ver* o ícone em um iPhone ou no simulador, e enviar o app para a App Store.
> Isso está em [15-build-ios/05-icone-splash-versao-infoplist.md](../15-build-ios/05-icone-splash-versao-infoplist.md).

---

## ⚠️ Erros comuns

**1. 🔴 Bloco indentado dentro de `flutter:`.**

```text
✗ Could not find a config file.
```

Correção: mover `flutter_launcher_icons:` para a coluna 1.

**2. Imagem não encontrada.**

```text
✗ The file assets/icone/icone.png was not found.
```

Causas: caminho errado, extensão diferente (`.PNG` maiúsculo em sistema sensível a caixa), ou você
rodou o comando de dentro de outra pasta. O caminho é **relativo à raiz do projeto**.

**3. Imagem retangular ou menor que 1024.**
O gerador aceita, mas o ícone sai distorcido ou borrado. Confira o tamanho antes.

**4. `min_sdk_android` diferente do `minSdk` real.**
Erro silencioso: o ícone adaptativo pode não ser gerado. Mantenha os dois em **24**.

**5. Esquecer as aspas na cor.**

```yaml
adaptive_icon_background: #3F51B5     # ❌ o YAML lê isso como comentário
adaptive_icon_background: "#3F51B5"   # ✅
```

**6. Achar que `No platform provided` é erro.**
Não é. A linha que decide é `✓ Successfully generated launcher icons`.

**7. Ícone antigo continua aparecendo.**
Falta `flutter clean`, ou o launcher está com cache. Desinstale o app e reinstale.

**8. Colocar o pacote em `dependencies` em vez de `dev_dependencies`.**
Funciona, mas engorda o app publicado com um pacote que só o desenvolvedor usa. Use `dev:`.

**9. Editar os PNGs gerados à mão.**
Qualquer nova execução do gerador sobrescreve tudo. Edite a **imagem de origem** e rode de novo.

**10. Ícone cortado nas bordas em alguns aparelhos.**
Você não respeitou a margem de ~66%. Refaça a imagem de frente com mais espaço vazio em volta.

---

## 🛠️ Exercício guiado

Objetivo: substituir o ícone padrão do Flutter pelo ícone do **Foco** e comprovar em cada nível.

**Passo 1 — Registre o estado atual.** Antes de gerar, liste o que existe:

```powershell
Get-ChildItem -Recurse android\app\src\main\res -Filter ic_launcher* | Select-Object FullName
```

Saída esperada (o ícone padrão do Flutter, 5 arquivos):

```text
...\res\mipmap-hdpi\ic_launcher.png
...\res\mipmap-mdpi\ic_launcher.png
...\res\mipmap-xhdpi\ic_launcher.png
...\res\mipmap-xxhdpi\ic_launcher.png
...\res\mipmap-xxxhdpi\ic_launcher.png
```

Repare: **não existe** `mipmap-anydpi-v26/ic_launcher.xml` ainda. O projeto padrão do Flutter não
tem ícone adaptativo.

**Passo 2 — Crie a imagem.** PNG 1024×1024, desenho dentro dos 66% centrais, salvo em
`assets/icone/icone.png`.

**Passo 3 — Configure o `pubspec.yaml`** com o bloco de primeiro nível da seção "Código completo".

**Passo 4 — Gere.**

```powershell
flutter pub get
dart run flutter_launcher_icons
```

Confira a última linha da saída: `✓ Successfully generated launcher icons`.

**Passo 5 — Confirme os arquivos novos.**

```powershell
Get-ChildItem -Recurse android\app\src\main\res -Filter ic_launcher* | Select-Object FullName
Get-ChildItem android\app\src\main\res\values\colors.xml
Get-ChildItem -Recurse android\app\src\main\res -Filter ic_launcher_foreground* |
  Measure-Object | Select-Object Count
```

Saída esperada: agora existe `mipmap-anydpi-v26\ic_launcher.xml`, existe `colors.xml`, e a contagem
de `ic_launcher_foreground*` é **5** (uma por densidade).

**Passo 6 — Leia o XML adaptativo.**

```powershell
Get-Content android\app\src\main\res\mipmap-anydpi-v26\ic_launcher.xml
```

Identifique na saída as tags `<background>` e `<foreground>`.

**Passo 7 — Confirme a cor.**

```powershell
Get-Content android\app\src\main\res\values\colors.xml
```

Saída esperada, contendo a cor que você configurou:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#3F51B5</color>
</resources>
```

**Passo 8 — Veja no aparelho.**

```powershell
flutter clean
flutter run
```

**Como confirmar que funcionou:** o ícone na tela inicial é o seu, com o nome **Foco** embaixo, e
ele respeita o formato dos outros ícones do aparelho (redondo, se o seu launcher usa redondo).

**Passo 9 — Confirme o iOS também.**

```powershell
Get-ChildItem ios\Runner\Assets.xcassets\AppIcon.appiconset | Measure-Object | Select-Object Count
```

A contagem é bem maior que 5 — são os tamanhos do iOS, gerados mesmo no Windows.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-android.md](../../exercicios/14-build-android.md)

Faça os exercícios de fixação sobre densidades e o de correção de bugs com o bloco YAML indentado
errado.

---

## 🏆 Desafio opcional

Faça um ícone adaptativo **de verdade**, com duas imagens diferentes, e comprove a margem de
segurança.

1. Crie `assets/icone/icone.png` — a versão completa, com fundo azul e o símbolo no meio (para o
   iOS e para o ícone clássico).
2. Crie `assets/icone/icone_frente.png` — **só o símbolo**, fundo **transparente**, ocupando no
   máximo 66% da largura, centralizado.
3. Ajuste o `pubspec.yaml`:

   ```yaml
   flutter_launcher_icons:
     android: "ic_launcher"
     ios: true
     image_path: "assets/icone/icone.png"
     min_sdk_android: 24
     remove_alpha_ios: true
     adaptive_icon_background: "#3F51B5"
     adaptive_icon_foreground: "assets/icone/icone_frente.png"
   ```

4. Gere, instale e compare com a versão anterior.
5. Como prova da margem: gere uma vez com o símbolo ocupando 95% da imagem e outra com 66%.
   Compare os dois no aparelho. Em um launcher com máscara circular, a diferença é visível.

Critério de sucesso: na versão de 66%, nenhuma parte do símbolo encosta na borda do recorte.

---

## 📌 Resumo

- O ícone do Android é **um conjunto de arquivos**, um por densidade, não um arquivo só.
- **Densidades**: `mdpi` (1×, 48 px), `hdpi` (1,5×, 72), `xhdpi` (2×, 96), `xxhdpi` (3×, 144),
  `xxxhdpi` (4×, 192). Ficam em `mipmap-*` porque o Android mantém todas no APK instalado.
- **Ícone adaptativo** (Android 8+) tem **duas camadas** — fundo e frente — e o sistema recorta o
  conjunto na máscara do fabricante.
- 🔴 **Margem de segurança de ~66%**: só os 72 dp centrais de 108 dp são garantidos. Deixe ~17% de
  margem vazia de cada lado.
- Imagem de origem: **PNG quadrado 1024×1024**, sem transparência para o iOS.
- O bloco `flutter_launcher_icons:` é de **primeiro nível** no `pubspec.yaml`, nunca dentro de
  `flutter:`.
- `min_sdk_android: 24` precisa bater com o `minSdk` do projeto. `remove_alpha_ios: true` é
  obrigatório para a App Store.
- Comando: `dart run flutter_launcher_icons`. A linha `No platform provided` é **normal**; o que
  importa é `✓ Successfully generated launcher icons`.
- Os arquivos gerados incluem `mipmap-anydpi-v26/ic_launcher.xml` (a declaração adaptativa),
  `drawable-*/ic_launcher_foreground.png` e `values/colors.xml`.
- Sempre `flutter clean` antes de conferir no aparelho.

---

## ☑️ Checklist de domínio

- [ ] Digo os requisitos da imagem de origem sem consultar.
- [ ] Explico o que são `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi` e por que existem.
- [ ] Explico as duas camadas do ícone adaptativo e o que o sistema faz com elas.
- [ ] Calculo a margem de segurança (72 de 108 dp ≈ 66%) e aplico no meu desenho.
- [ ] Escrevo o bloco `flutter_launcher_icons:` na coluna certa, de memória.
- [ ] Sei por que `remove_alpha_ios: true` é obrigatório.
- [ ] Rodo `dart run flutter_launcher_icons` e leio a saída sem me assustar com
      `No platform provided`.
- [ ] Listo os arquivos gerados no Android e digo para que serve cada grupo.
- [ ] Abro `ic_launcher.xml` e aponto as tags de fundo e de frente.
- [ ] Vi o ícone novo no meu aparelho, depois de `flutter clean`.

---

## 📚 Referências oficiais

- [Android Developers — Adaptive icons](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)
- [Android Developers — Support different pixel densities](https://developer.android.com/training/multiscreen/screendensities)
- [Android Developers — App resources overview](https://developer.android.com/guide/topics/resources/providing-resources)
- [pub.dev — flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
- [Flutter — Adding assets and images](https://docs.flutter.dev/ui/assets/assets-and-images)
- [Apple — Human Interface Guidelines: App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Identidade do app](02-identidade-do-app.md) | [README](README.md) | [Splash screen](04-splash-screen.md) |
