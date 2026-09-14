# Aula 2 — Dart e Flutter

> **Módulo:** 01 - Lógica e Fundamentos · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Explicar o que é a **linguagem Dart** e por que o Flutter a escolheu.
- Explicar o que é o **Flutter** e por que ele não é "uma linguagem".
- Descrever a relação entre Dart, framework Flutter e **engine**.
- Explicar o que são **Skia** e **Impeller** e o que significa "o Flutter desenha a própria tela".
- Diferenciar app **nativo**, **multiplataforma compilado** e **híbrido/WebView**.
- Explicar o que são **APK**, **AAB**, **archive** e **IPA**, e quando cada um aparece.
- Situar o Flutter nesse mapa e defender essa escolha com argumentos técnicos.

## ✅ Pré-requisitos

- [Aula 1 — O que é programar](01-o-que-e-programar.md), em especial JIT, AOT e SDK.
- Projeto `C:\src\pratica_dart` criado (veja o [README do módulo](README.md)).

---

## 📖 Conceito

### 1. Dart é a linguagem

**Dart** é uma linguagem de programação criada pelo Google. Ela é:

- **Tipada estaticamente**: cada variável tem um tipo conhecido antes de o programa rodar, e o
  Dart recusa compilar se você misturar tipos incompatíveis. Isso derruba uma classe inteira de
  erros antes de o app chegar ao usuário.
- **Orientada a objetos**: tudo é objeto, inclusive números. Você estuda isso no
  [Módulo 03](../03-dart-intermediario/README.md).
- **Com *null safety* sã**: o Dart distingue "variável que pode ser nula" de "variável que nunca é
  nula". *Null* (nulo) é a ausência de valor; confundir nulo com valor real é a origem histórica de
  uma quantidade enorme de travamentos. O assunto tem aula própria em
  [`02-dart-basico/05-null-safety.md`](../02-dart-basico/05-null-safety.md).
- **Compilável para vários alvos**: código de máquina ARM/x64 (celular e desktop) via AOT, e
  JavaScript ou WebAssembly (web).

Dart existe fora do Flutter: você pode escrever um programa de terminal, um servidor HTTP ou uma
ferramenta de linha de comando só com Dart. É exatamente o que você faz nos módulos 01 a 04.

**Por que o Flutter escolheu Dart?** Porque Dart é uma das poucas linguagens que oferece, ao mesmo
tempo: (1) **JIT** para *hot reload* durante o desenvolvimento; (2) **AOT** para desempenho no app
publicado; (3) coleta de lixo (*garbage collection* — liberação automática de memória que não é
mais usada) desenhada para criar e descartar muitos objetos pequenos rapidamente, que é exatamente
o que uma interface faz a cada quadro.

### 2. Flutter é o framework (e um pouco mais)

**Framework** (arcabouço) é um conjunto de código pronto que define a estrutura do seu programa e
chama o **seu** código nos momentos certos. Você não escreve o laço que desenha a tela 60 vezes por
segundo; o framework escreve, e chama sua função `build` quando precisa saber o que desenhar.

O **Flutter** é um *kit* completo para construir interfaces. Ele tem três camadas:

| Camada | Escrita em | O que faz |
|---|---|---|
| **Framework** (o que você usa) | Dart | Widgets, layout, animação, gestos, Material 3, Cupertino |
| **Engine** (motor) | C++ | Desenha pixels, gerencia texto, rede, arquivos, executa o Dart |
| **Embedder** (incorporador) | Kotlin/Java 🤖, Swift/Objective-C 🍎, C++ 🪟 | Conversa com o sistema operacional: cria a janela, recebe toques, ciclo de vida |

**Widget** é a unidade de construção da interface no Flutter: um botão é um widget, um texto é um
widget, um espaçamento é um widget, a tela inteira é um widget feito de outros widgets. Você começa
a usá-los no [Módulo 05](../05-introducao-ao-flutter/README.md).

### 3. A engine e o renderizador: Skia e Impeller

Aqui está a decisão que define o Flutter: **ele não pede botões emprestados ao sistema
operacional**. Ele recebe um retângulo de pixels e desenha tudo dentro dele.

**Renderizar** é transformar a descrição da tela ("um retângulo azul com cantos de 8 pixels e o
texto 'Salvar' centralizado") em pixels de verdade na tela.

- **Skia** é uma biblioteca gráfica 2D em C++, mantida pelo Google, usada há muitos anos em
  produtos como o Chrome. Foi o renderizador original do Flutter.
- **Impeller** é o renderizador mais novo do Flutter, criado especificamente para resolver um
  problema do Skia em aplicativos: a compilação de *shaders* (pequenos programas que rodam na placa
  de vídeo) acontecia durante a execução e causava travadinhas na primeira vez que uma animação
  aparecia. O Impeller pré-compila esses *shaders* na hora do build, deixando a animação estável
  desde o primeiro quadro.

Nas versões atuais do Flutter — incluindo a **3.47.1** deste curso — o Impeller é o renderizador
padrão em 🍎 iOS e 🤖 Android. O Skia continua presente em outros alvos, como a web. Você não
precisa escolher nem configurar nada para começar: o padrão já é o recomendado.

> 💡 **Consequência prática que você vai sentir:** como o Flutter desenha tudo, um botão Material
> desenhado pelo Flutter é **idêntico** no Android e no iOS. Isso é ótimo para consistência da
> marca e ruim quando o usuário de iPhone espera um controle com cara de iPhone. O curso trata
> desse equilíbrio em
> [`11-recursos-nativos/09-material-x-cupertino.md`](../11-recursos-nativos/09-material-x-cupertino.md).

### 4. Nativo × multiplataforma compilado × híbrido (WebView)

Existem três famílias de aplicativos móveis. Saber a diferença evita discussões vazias e ajuda a
justificar a sua escolha tecnológica em uma entrevista.

**App nativo**
Escrito na linguagem e com as ferramentas oficiais de **uma** plataforma: Kotlin/Java + Android
Studio para 🤖 Android; Swift/Objective-C + Xcode para 🍎 iOS.

- ✅ Acesso imediato a qualquer recurso novo do sistema.
- ✅ Aparência 100% do sistema, de graça.
- ❌ Duas bases de código, duas equipes, duas manutenções.

**App multiplataforma compilado** (é aqui que o Flutter está)
Uma base de código que é **compilada para código de máquina** de cada plataforma.

- ✅ Uma base de código, dois apps de verdade.
- ✅ Desempenho próximo do nativo, porque o código final é nativo (AOT).
- ❌ Recursos muito novos do sistema podem exigir um *plugin* (pacote que faz a ponte com o código
  nativo) ou código nativo escrito por você.

**App híbrido / WebView**
Uma página web (HTML, CSS, JavaScript) empacotada dentro de um app. **WebView** é o componente do
sistema que exibe uma página web dentro de uma tela do aplicativo — um navegador sem barra de
endereço.

- ✅ Reaproveita quem já sabe web.
- ❌ A interface é uma página web: rolagem, animação e teclado costumam "denunciar" isso.
- ❌ Desempenho limitado pelo motor web e pela ponte com o sistema.

| Critério | 🧱 Nativo | 🎯 Flutter (compilado) | 🌐 Híbrido/WebView |
|---|---|---|---|
| Bases de código | 2 | 1 | 1 |
| Linguagem | Kotlin / Swift | Dart | JS/TS |
| Como desenha a tela | componentes do sistema | desenha os próprios pixels (Impeller/Skia) | motor web |
| Desempenho de interface | máximo | alto | variável |
| Acesso a recurso novo do SO | imediato | via plugin ou código nativo | via plugin, mais indireto |
| Aparência nativa | automática | precisa ser escolhida (Material/Cupertino) | difícil |

### 5. Os artefatos: o que sai no fim

**Artefato** é o arquivo final produzido pelo build, aquele que você instala ou envia para a loja.

#### 🤖 APK — *Android Package*

Arquivo `.apk`: um pacote com tudo que o Android precisa para instalar seu app (código compilado,
imagens, o manifesto de permissões). É o formato **instalável**: você pode mandar um `.apk` para
um amigo instalar no celular dele.

Comandos e saídas do curso:

```powershell
flutter build apk --release
```

Saída: `build/app/outputs/flutter-apk/app-release.apk`

```powershell
flutter build apk --split-per-abi
```

Gera um APK por arquitetura de processador (**ABI** = *Application Binary Interface*, o "formato de
instrução" do processador): `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`,
`app-x86_64-release.apk`. Cada um é bem menor que o APK único.

#### 🤖 AAB — *Android App Bundle*

Arquivo `.aab`: o formato que a **Google Play exige** para publicação desde 2021. Ele **não é
instalável** diretamente no celular. Você envia o `.aab` para a Play, e é a própria loja que gera e
assina os APKs sob medida para cada aparelho (só a arquitetura certa, só as densidades de tela
certas, só os idiomas certos). Resultado: download menor para o usuário.

```powershell
flutter build appbundle
```

Saída: `build/app/outputs/bundle/release/app-release.aab`

| | APK | AAB |
|---|---|---|
| Instala direto no celular | ✅ sim | ❌ não |
| Aceito na Google Play | ❌ não (para apps novos) | ✅ obrigatório |
| Bom para testar com amigos | ✅ | ❌ |
| Tamanho para o usuário | maior | menor (a loja otimiza) |

#### 🍎 Archive e IPA

No mundo Apple o caminho tem duas etapas:

1. **Archive** (`.xcarchive`): um pacote intermediário com o app compilado mais os símbolos de
   depuração. É o que aparece no Organizer do Xcode. Caminho gerado pelo Flutter:
   `build/ios/archive/Runner.xcarchive`.
2. **IPA** (*iOS App Store Package*, arquivo `.ipa`): o pacote final, **assinado**, exportado a
   partir do archive. É o que sobe para o App Store Connect / TestFlight. Caminho:
   `build/ios/ipa/<nome>.ipa`.

```bash
flutter build ipa
flutter build ipa --export-method app-store-connect
```

**Assinatura** aqui não é figura de linguagem: a Apple exige um certificado digital e um
*provisioning profile* (perfil que diz quais aparelhos e quais recursos aquele app pode usar).
Sem isso, o iPhone recusa instalar.

> 🍎 **SÓ NO MAC.** `flutter build ipa` exige macOS + Xcode. No Windows 11 você pode ler e entender
> todo o processo, mas não executá-lo. Nada de ilusão: **não existe** caminho suportado para gerar
> um IPA no Windows. O que fazer enquanto isso está em
> [`15-build-ios/01-por-que-exige-macos.md`](../15-build-ios/01-por-que-exige-macos.md).

### 6. Onde o Flutter se encaixa

Juntando tudo:

```text
Você escreve  →  Dart (linguagem)
                  ↓  usa
              Framework Flutter (widgets, layout, Material 3)
                  ↓  roda sobre
              Engine (C++) + Impeller/Skia  →  desenha os pixels
                  ↓  hospedada por
              Embedder (Android / iOS / Windows)
                  ↓  compilado em AOT para
              APK · AAB  (🤖)      IPA  (🍎)
```

Uma base de código Dart, dois artefatos nativos no fim. É essa a proposta, e é ela que o curso
inteiro vai cumprir até o módulo 16.

---

## 💡 Analogia

Pense em uma peça de teatro que precisa ser encenada em dois teatros diferentes.

- O **app nativo** contrata dois elencos, com dois roteiros, um por teatro. Perfeito em cada casa,
  caro em dobro.
- O **app híbrido/WebView** projeta um vídeo da peça na parede dos dois teatros. É a mesma
  gravação em qualquer lugar, mas ninguém confunde com teatro ao vivo.
- O **Flutter** leva **o mesmo elenco e o mesmo cenário** para os dois teatros, e monta o cenário do
  zero em cada palco. É ao vivo nos dois lugares, e idêntico nos dois — e é justamente por montar o
  próprio cenário que ele não usa as cortinas da casa.

O **Dart** é o roteiro. O **framework** é a direção. A **engine** é a equipe técnica que faz luz e
som. O **APK/AAB/IPA** é o ingresso que chega na mão do público.

---

## 🧪 Exemplo mínimo

Um programa Dart de terminal que mostra a ficha do ambiente. Rode-o para reforçar que **Dart roda
sem Flutter**.

> Arquivo: `C:\src\pratica_dart\bin\aula02_minimo.dart`

```dart
void main() {
  const String linguagem = 'Dart';
  const String versaoDart = '3.13.1';
  const String framework = 'Flutter';
  const String versaoFlutter = '3.47.1';

  print('$linguagem $versaoDart é a linguagem.');
  print('$framework $versaoFlutter é o framework que usa essa linguagem.');
  print('Este programa está rodando SEM Flutter nenhum.');
}
```

```powershell
dart run bin/aula02_minimo.dart
```

```text
Dart 3.13.1 é a linguagem.
Flutter 3.47.1 é o framework que usa essa linguagem.
Este programa está rodando SEM Flutter nenhum.
```

---

## 📱 Aplicando no Flutter

- A separação **framework / engine / embedder** é detalhada em
  [`05-introducao-ao-flutter/01-como-o-flutter-funciona.md`](../05-introducao-ao-flutter/01-como-o-flutter-funciona.md).
  Entender que o Flutter desenha os próprios pixels explica por que um `Container` vermelho é
  vermelho igual nos dois sistemas.
- A escolha entre **Material** (visual Android/Google) e **Cupertino** (visual iOS) aparece em
  [`05-introducao-ao-flutter/09-material-e-cupertino.md`](../05-introducao-ao-flutter/09-material-e-cupertino.md)
  e volta com força em
  [`11-recursos-nativos/09-material-x-cupertino.md`](../11-recursos-nativos/09-material-x-cupertino.md).
- **APK e AAB** deixam de ser sigla e viram tarefa em
  [`14-build-android/08-gerando-apk-e-aab.md`](../14-build-android/08-gerando-apk-e-aab.md);
  a assinatura que os torna publicáveis está em
  [`14-build-android/06-keystore.md`](../14-build-android/06-keystore.md).
- **Archive e IPA** viram tarefa (no Mac) em
  [`15-build-ios/08-build-ipa-e-archive.md`](../15-build-ios/08-build-ipa-e-archive.md).
- A decisão "um plugin resolve ou preciso de código nativo?" é ensinada em
  [`11-recursos-nativos/10-avaliando-pacotes.md`](../11-recursos-nativos/10-avaliando-pacotes.md).

---

## 💻 Código completo

> **Arquivo:** `C:\src\pratica_dart\bin\aula02_ecossistema.dart`
> **Como executar:** `dart run bin/aula02_ecossistema.dart` (a partir de `C:\src\pratica_dart`)

```dart
// bin/aula02_ecossistema.dart
// Aula 2 — Dart e Flutter.
// Um mapa do ecossistema impresso no terminal, feito só com Dart puro.

void main() {
  // --- Identidade das ferramentas do curso ---
  const String versaoFlutter = '3.47.1';
  const String versaoDart = '3.13.1';
  const String canal = 'stable';

  // --- Identidade do app que você vai construir no final do curso ---
  const String nomeApp = 'Foco';
  const String idPacote = 'br.com.estudos.foco';

  // --- Artefatos de saída, exatamente como o Flutter os grava ---
  const String saidaApk = 'build/app/outputs/flutter-apk/app-release.apk';
  const String saidaAab = 'build/app/outputs/bundle/release/app-release.aab';
  const String saidaArchive = 'build/ios/archive/Runner.xcarchive';
  const String saidaIpa = 'build/ios/ipa/<nome>.ipa';

  // Uma string de várias linhas usa três aspas simples.
  const String camadas = '''
Você escreve  ->  Dart (linguagem)
                  usa
              Framework Flutter (widgets, layout, Material 3)
                  roda sobre
              Engine C++ + Impeller/Skia (desenha os pixels)
                  hospedada por
              Embedder (Android / iOS / Windows)''';

  print('=== ECOSSISTEMA DO CURSO ===');
  print('Flutter $versaoFlutter (canal $canal) traz o Dart $versaoDart dentro.');
  print('');
  print(camadas);
  print('');

  print('=== APP FINAL ===');
  print('Nome: $nomeApp');
  print('Identificador: $idPacote');
  print('  - no Android esse valor é o applicationId');
  print('  - no iOS esse mesmo valor é o Bundle Identifier');
  print('');

  print('=== ARTEFATOS ===');
  print('[Android] APK instalavel : $saidaApk');
  print('[Android] AAB para a Play: $saidaAab');
  print('[iOS]     Archive        : $saidaArchive');
  print('[iOS]     IPA assinado   : $saidaIpa');
  print('');

  // Um booleano guarda verdadeiro ou falso.
  const bool estouNoWindows = true;
  const bool tenhoMac = false;

  print('=== O QUE EU CONSIGO FAZER HOJE ===');
  print('Windows 11: $estouNoWindows  ->  APK e AAB: sim.');
  print('Tenho Mac : $tenhoMac  ->  IPA: nao, exige macOS + Xcode.');
  print('Ler e entender o processo iOS: sempre possivel.');
}
```

Saída esperada:

```text
=== ECOSSISTEMA DO CURSO ===
Flutter 3.47.1 (canal stable) traz o Dart 3.13.1 dentro.

Você escreve  ->  Dart (linguagem)
                  usa
              Framework Flutter (widgets, layout, Material 3)
                  roda sobre
              Engine C++ + Impeller/Skia (desenha os pixels)
                  hospedada por
              Embedder (Android / iOS / Windows)

=== APP FINAL ===
Nome: Foco
Identificador: br.com.estudos.foco
  - no Android esse valor é o applicationId
  - no iOS esse mesmo valor é o Bundle Identifier

=== ARTEFATOS ===
[Android] APK instalavel : build/app/outputs/flutter-apk/app-release.apk
[Android] AAB para a Play: build/app/outputs/bundle/release/app-release.aab
[iOS]     Archive        : build/ios/archive/Runner.xcarchive
[iOS]     IPA assinado   : build/ios/ipa/<nome>.ipa

=== O QUE EU CONSIGO FAZER HOJE ===
Windows 11: true  ->  APK e AAB: sim.
Tenho Mac : false  ->  IPA: nao, exige macOS + Xcode.
Ler e entender o processo iOS: sempre possivel.
```

---

## 🔍 Explicando o código

| Trecho | O que é |
|---|---|
| `const String versaoFlutter = '3.47.1';` | Constante de texto. `const` porque o valor já é conhecido quando o programa é compilado. |
| `const String camadas = '''...''';` | **String de várias linhas**: três aspas simples abrem e fecham. Tudo entre elas, inclusive as quebras de linha, faz parte do texto. |
| `print('');` | Imprime uma linha vazia. Serve para dar respiro visual na saída. |
| `const bool estouNoWindows = true;` | **`bool`** é o tipo lógico: só aceita `true` ou `false`. É a base de toda decisão (Aula 7). |
| `print('Windows 11: $estouNoWindows ...')` | A interpolação converte o `bool` em texto automaticamente: aparece `true`. |
| `'build/ios/ipa/<nome>.ipa'` | `<nome>` é um marcador de posição **no texto**, porque o nome real depende do seu app. O curso nunca inventa um caminho fixo aqui. |

### Por que usar `const` e não `var` aqui?

Nada nesse programa muda depois de definido. Marcar como `const` comunica isso a quem lê **e** ao
compilador, que pode embutir o valor direto no código gerado. A regra prática do curso (detalhada
na [Aula 4](04-variaveis-e-constantes.md)) é: comece por `const`; se não der, `final`; só use `var`
quando o valor realmente precisar mudar.

### Por que a saída sem acentos em alguns pontos?

Note que escrevi `instalavel` e `nao` sem acento em algumas linhas. Não é descuido: em terminais
Windows mal configurados, acentos podem sair trocados. Você vai ajustar isso no
[Módulo 02, aula 10](../02-dart-basico/10-entrada-e-saida.md). Nas strings onde o acento importa
para a leitura, mantive o acento.

---

## 🤖🍎 Android × iOS

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Identificador do app | `applicationId` em `android/app/build.gradle.kts` | *Bundle Identifier* no Xcode |
| Valor no projeto final | `br.com.estudos.foco` | `br.com.estudos.foco` (o mesmo) |
| Artefato de teste | `.apk` | app rodando no simulador/dispositivo |
| Artefato de loja | `.aab` | `.ipa` |
| Loja | Google Play | App Store |
| Assinatura | *keystore* `.jks` que **você** cria e guarda | certificado + *provisioning profile* emitidos pela Apple |
| Custo para publicar | taxa única de registro de desenvolvedor | assinatura anual do Apple Developer Program |
| Dá para fazer no Windows 11 | ✅ tudo | ❌ o build final, não |
| Linguagem do *embedder* | Kotlin/Java | Swift/Objective-C |

> 🍎 **SÓ NO MAC.** Assinar e exportar o IPA exige macOS + Xcode. Alternativas honestas (Mac
> emprestado, serviço de build na nuvem, adiar o iOS) estão discutidas em
> [`15-build-ios/01-por-que-exige-macos.md`](../15-build-ios/01-por-que-exige-macos.md).

---

## ⚠️ Erros comuns

**1. "Vou aprender a linguagem Flutter."**
Flutter não é linguagem. A linguagem é **Dart**. Falar "código Flutter" é aceitável no dia a dia,
mas em entrevista essa confusão pega mal.

**2. "Flutter é WebView / é HTML por baixo."**
Não. O Flutter compila Dart para código de máquina (AOT) e desenha a interface com Impeller/Skia.
Não há navegador embutido, não há HTML, não há JavaScript no app móvel.

**3. Tentar enviar um APK para a Google Play.**
Para apps novos a Play exige `.aab`. O erro aparece no envio, não no build — por isso muita gente
descobre tarde. Rode `flutter build appbundle` quando o destino for a loja.

**4. Tentar instalar um `.aab` no celular.**
Não instala; não é esse o papel dele. Para instalar direto, gere APK.

**5. Achar que o `.ipa` é só um `.apk` com outro nome.**
São formatos diferentes, exigências de assinatura diferentes e processos diferentes. O IPA precisa
de certificado e *provisioning profile* da Apple.

**6. Esperar que a interface fique automaticamente com "cara de iPhone".**
Como o Flutter desenha tudo, ele usa **Material 3** por padrão nos dois sistemas. Adaptar-se ao
visual do iOS é uma decisão sua, com widgets Cupertino.

**7. Escrever `Skia` como se fosse obrigatório configurar.**
Você não precisa ativar nem escolher renderizador para começar. O padrão do Flutter 3.47.1 já é o
recomendado para 🤖 e 🍎.

---

## 🛠️ Exercício guiado

**Passo 1.** Confirme que o Dart que você tem é o do curso:

```powershell
cd C:\src\pratica_dart
dart --version
```

Deve aparecer `3.13.1`. Se aparecer outra versão, volte para
[`02-configuracao-do-ambiente.md`](../../02-configuracao-do-ambiente.md).

**Passo 2.** Crie `bin/aula02_ecossistema.dart` com o código completo desta aula e execute:

```powershell
dart run bin/aula02_ecossistema.dart
```

**Passo 3.** Altere `tenhoMac` para `true` e execute de novo. Perceba que o texto que aparece **não
muda de sentido**, porque o programa só interpola o valor. Isso incomoda? Ótimo: é exatamente o
problema que o `if` resolve na [Aula 7](07-condicoes.md). Devolva o valor para `false`.

**Passo 4.** Acrescente duas constantes e dois `print` para registrar:

```dart
const String rendererPadrao = 'Impeller';
const String rendererAnterior = 'Skia';
print('Renderizador padrão em Android e iOS: $rendererPadrao');
print('Renderizador histórico, ainda usado em outros alvos: $rendererAnterior');
```

**Passo 5.** Escreva, com suas palavras, **dentro do arquivo**, um comentário de três linhas
respondendo: "se eu tivesse que explicar a um colega por que este curso usa Flutter e não WebView,
o que eu diria?". Escrever a justificativa fixa o conteúdo melhor do que reler.

**Passo 6.** Salve seu progresso no Git:

```powershell
git add .
git commit -m "aula 02: mapa do ecossistema Dart/Flutter"
```

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/01-logica-e-fundamentos.md](../../exercicios/01-logica-e-fundamentos.md)

Priorize os exercícios de **Fixação** ligados a vocabulário de plataforma (APK, AAB, IPA, engine,
renderizador) e o de **Leitura de código** que usa interpolação de strings.

---

## 🏆 Desafio opcional

Monte, em `bin/aula02_desafio.dart`, um "comparador de abordagens" que imprima uma tabela em texto
com as três famílias (nativo, Flutter, híbrido) e quatro critérios: número de bases de código,
como desenha a tela, desempenho de interface e facilidade de acessar recurso novo do sistema.

Regras:

- Use apenas constantes e `print` (você ainda não viu listas nem laços).
- Alinhe as colunas usando espaços dentro das strings.
- Ao final, imprima **a sua** conclusão sobre qual abordagem faz sentido para o app `Foco` e por quê.

Quando chegar ao [Módulo 02, aula 08](../02-dart-basico/08-listas.md), volte a este arquivo e
reescreva a mesma tabela usando uma lista e um laço. A diferença de tamanho do código vai ser a
melhor propaganda possível de estruturas de dados.

---

## 📌 Resumo

- **Dart** é a linguagem: tipada estaticamente, orientada a objetos, com *null safety*, compilável
  para ARM/x64 e para a web.
- **Flutter** é o kit de interface: framework em Dart + engine em C++ + embedder por plataforma.
- A engine desenha a tela com **Impeller** (padrão em Android e iOS no Flutter 3.47.1) ou **Skia**.
  O Flutter não pede componentes emprestados ao sistema.
- **Nativo**: uma base por plataforma. **Multiplataforma compilado** (Flutter): uma base, binários
  nativos. **Híbrido/WebView**: uma base, interface web dentro de um app.
- 🤖 **APK** instala direto; 🤖 **AAB** é o formato exigido pela Google Play e não instala sozinho.
- 🍎 **Archive** (`.xcarchive`) é a etapa intermediária; **IPA** é o pacote final assinado que sobe
  para o App Store Connect — e exige macOS + Xcode.
- No seu Windows 11 você faz o ciclo Android inteiro e estuda o ciclo iOS por completo, sem gerar
  o IPA.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre a linguagem Dart e o framework Flutter.
- [ ] Cito as três camadas do Flutter e o que cada uma faz.
- [ ] Explico o que é renderizar e o que Impeller e Skia fazem.
- [ ] Dou um argumento técnico para o Flutter não ser um app WebView.
- [ ] Digo o que é APK, quando usá-lo e onde o arquivo é gerado.
- [ ] Digo o que é AAB, por que a Play o exige e por que ele não instala no celular.
- [ ] Explico a diferença entre archive e IPA.
- [ ] Digo com honestidade o que consigo e o que não consigo fazer no Windows 11.
- [ ] Executei `bin/aula02_ecossistema.dart` e entendi cada linha da saída.

---

## 📚 Referências oficiais

- [Flutter — Visão geral da arquitetura](https://docs.flutter.dev/resources/architectural-overview)
- [Flutter — Impeller](https://docs.flutter.dev/perf/impeller)
- [Flutter — Build e lançamento para Android](https://docs.flutter.dev/deployment/android)
- [Flutter — Build e lançamento para iOS](https://docs.flutter.dev/deployment/ios)
- [Dart — Por que o Flutter usa Dart](https://dart.dev/overview)
- [Android Developers — Sobre o Android App Bundle](https://developer.android.com/guide/app-bundle)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — O que é programar](01-o-que-e-programar.md) | [README](README.md) | [Aula 3 — Algoritmos e decomposição](03-algoritmos-e-decomposicao.md) |
