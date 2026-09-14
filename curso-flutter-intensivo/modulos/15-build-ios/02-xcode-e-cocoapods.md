# Aula 2 — Xcode e CocoaPods

> **Módulo:** 15 - Build e Distribuição iOS · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Instalar o **Xcode** pela Mac App Store sabendo de antemão quanto espaço e quanto tempo isso
  consome.
- Executar, na ordem correta, os quatro comandos de primeira configuração:
  `xcode-select --install`, `xcode-select --switch`, `xcodebuild -runFirstLaunch` e
  `xcodebuild -license accept`.
- Ler a saída do `flutter doctor` em macOS linha por linha e traduzir cada `[✓]`, `[!]` e `[✗]`
  em uma ação concreta.
- Explicar o que é o **Swift Package Manager (SPM)**, por que ele é o padrão do Flutter desde a
  versão **3.44** e como ligá-lo ou desligá-lo, globalmente e por projeto.
- Explicar o que é o **CocoaPods**, quando ele ainda é necessário, e o que significa o seu
  **modo de manutenção** e o **registro somente-leitura a partir de 2 de dezembro de 2026**.
- Usar `pod install`, `pod repo update` e `pod deintegrate` com segurança.

## ✅ Pré-requisitos

- [Aula 1 — Por que o iOS exige macOS](01-por-que-exige-macos.md) concluída.
- Projeto **Foco** versionado no Git e passando em `flutter analyze` e `flutter test`.
- Para **executar** esta aula: um Mac com macOS atualizado, pelo menos **60 GB** livres em disco
  e uma conta Apple ID (a gratuita já serve nesta etapa — a Aula 6 explica a diferença).

---

## 🍎🪟 Antes de começar: onde você está

> # 🍎 SÓ NO MAC. Você está no Windows 11.
>
> **Nenhum comando desta aula roda na sua máquina.** `xcode-select`, `xcodebuild`, `pod` e
> `open` são ferramentas de macOS. Tentar instalá-las no Windows não funciona e não faz sentido.
>
> **O que você faz agora, no Windows:**
> 1. Ler a aula inteira e entender o papel de cada ferramenta.
> 2. Copiar o roteiro da seção "Código completo" para dentro do projeto Foco, como
>    `ferramentas/configurar-mac-ios.sh`, e **commitar**. Assim, no dia em que você sentar num
>    Mac, o roteiro já está lá.
> 3. Decidir se o projeto Foco vai usar **SPM** (padrão, recomendado) ou **CocoaPods**, e deixar
>    essa decisão registrada no `pubspec.yaml` — isso é edição de texto, funciona no Windows.
>
> **O que fica para quando você tiver um Mac:** instalar o Xcode, rodar os quatro comandos de
> primeira configuração, rodar `flutter doctor` com a seção da Apple e executar `pod install`.

---

## 📖 Conceito

### O que é o Xcode

**Xcode** é o **IDE** (*Integrated Development Environment* — o programa que junta editor de
código, compilador, depurador e ferramentas de interface numa janela só) oficial da Apple. Ele
carrega junto:

- A toolchain (`clang`, `ld`, `codesign`, `actool`, `ibtool`).
- Os **SDKs** do iOS, iPadOS, macOS, watchOS, tvOS e visionOS.
- O **Simulator**, que emula iPhones e iPads.
- O **Organizer**, painel de archives e envios para a App Store.
- O **Instruments**, ferramenta de medição de desempenho.

Você vai usar o Xcode pouco no dia a dia — o Flutter chama o `xcodebuild` por baixo dos panos.
Mas há quatro momentos em que você **precisa** abrir a janela do Xcode: configurar assinatura
(Aula 7), gerar archive manualmente (Aula 8), validar e enviar (Aula 9) e ler certos erros que
só aparecem legíveis lá.

### Tamanho e tempo da instalação

Números para você planejar o dia no Mac:

| Item | Valor realista |
|---|---|
| Download do Xcode pela Mac App Store | cerca de **10 a 15 GB** |
| Espaço ocupado depois de instalado | cerca de **20 a 40 GB**, dependendo das plataformas |
| Espaço livre recomendado antes de começar | **60 GB** |
| Tempo de download em internet de 100 Mbps | 20 a 40 min |
| Tempo de instalação/descompactação depois do download | 20 a 60 min |
| Primeira abertura (instala componentes adicionais) | 5 a 20 min |
| **Total realista** | **1 a 2 horas** |

> ⚠️ Se você vai usar um **Mac emprestado**, comece o download do Xcode **antes** de se sentar
> para estudar. Perder duas horas de um Mac emprestado esperando barra de progresso é o pior uso
> possível do tempo.

### O que é o `xcode-select`

O macOS pode ter **mais de um Xcode instalado** (por exemplo, a versão estável e uma beta). O
`xcode-select` é o comando que diz ao sistema **qual** deles as ferramentas de linha de comando
devem usar. Ele guarda um caminho, o *developer directory*, que normalmente é:

```text
/Applications/Xcode.app/Contents/Developer
```

Existe também um pacote separado, as **Command Line Tools**, que traz `git`, `clang`, `make` e
afins sem o Xcode completo. Ele é útil, mas **não basta** para compilar iOS: faltam os SDKs e o
Simulator. Você instala os dois.

### O que é o Swift Package Manager

**Swift Package Manager (SPM)** é o gerenciador de dependências oficial da Apple, integrado ao
Swift e ao Xcode. **Gerenciador de dependências** é o programa que baixa e encaixa no seu projeto
as bibliotecas de terceiros que ele usa — o `pub` faz isso no Dart, o `gradle` no Android, o SPM
e o CocoaPods no iOS.

> 🔴 **Desde o Flutter 3.44, o SPM está LIGADO POR PADRÃO.** Você está no Flutter 3.47.1, então
> ele já está ligado no seu projeto.

O `flutter create` do 3.47 já gera estes dois caminhos dentro do projeto:

```text
ios/Flutter/ephemeral/Packages
ios/Flutter/ephemeral/.swift_pm.lock
```

`ephemeral` significa "efêmero": é conteúdo gerado, que o Flutter recria quando precisa, e que
**não deve** ser editado à mão nem versionado.

O ponto mais importante para não te confundir depois: **o Flutter volta automaticamente para o
CocoaPods quando algum plugin do projeto ainda não suporta SPM.** Os dois convivem no mesmo
projeto. Ver o CocoaPods rodando não significa que o SPM está quebrado — significa que pelo menos
um plugin ainda depende dele.

### O que é o CocoaPods

**CocoaPods** é o gerenciador de dependências que dominou o iOS por mais de uma década. Ele é
escrito em **Ruby** e se instala como uma *gem* (o formato de pacote do Ruby). Ele funciona assim:

1. Você (ou o Flutter) descreve as dependências num arquivo chamado `Podfile`.
2. `pod install` baixa as bibliotecas, cria a pasta `ios/Pods/` e gera o `Podfile.lock` com as
   versões exatas.
3. O CocoaPods cria um **workspace** (`Runner.xcworkspace`) que junta o seu projeto com o projeto
   `Pods`. É por isso que se abre o `.xcworkspace`, nunca o `.xcodeproj` — a Aula 4 detalha.

> 🔴 **O CocoaPods está em modo de manutenção, e o registro público dele se torna
> SOMENTE-LEITURA em 2 de dezembro de 2026.**
>
> Traduzindo: depois dessa data, nenhuma biblioteca nova pode ser **publicada** no registro do
> CocoaPods, e versões novas de bibliotecas existentes não entram lá. O que já está publicado
> continua podendo ser **baixado** — projetos antigos não param de funcionar de um dia para o
> outro. Mas a direção é clara: o ecossistema iOS está migrando para o SPM.

**O que isso muda para você, hoje:** aprenda SPM como caminho principal e CocoaPods como
conhecimento de manutenção. Você ainda vai precisar do CocoaPods quando: (a) usar um plugin que
não migrou; (b) manter um projeto Flutter antigo; (c) ler mensagens de erro — a maior parte do
material de erro iOS que você encontra na internet é sobre CocoaPods.

---

## 💡 Analogia

O `pubspec.yaml` é para o Dart o que o `Podfile` é para o iOS antigo e o que o SPM é para o iOS
atual: a lista de compras das bibliotecas. O `pubspec.lock` corresponde ao `Podfile.lock`: a nota
fiscal com as versões exatas que realmente vieram. Trocar de gerenciador é trocar o supermercado,
não a receita — o app continua o mesmo.

---

## 🧪 Exemplo mínimo

No Mac, depois do Xcode instalado, estes quatro comandos fazem a primeira configuração inteira.
Rode **nesta ordem**.

**🖥️ macOS (bash/zsh)**

```bash
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -license accept
```

O que cada um faz e o que esperar:

| Comando | O que faz | Resultado esperado |
|---|---|---|
| `xcode-select --install` | Abre a janela do macOS que instala as **Command Line Tools** | Uma caixa de diálogo aparece. Se já estiverem instaladas, o terminal responde `command line tools are already installed` |
| `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` | Aponta as ferramentas de linha de comando para o Xcode completo | Nenhuma saída. Silêncio aqui é sucesso |
| `sudo xcodebuild -runFirstLaunch` | Instala os componentes extras que o Xcode pede na primeira abertura | Barras de progresso e, ao final, o prompt de volta sem erro |
| `xcodebuild -license accept` | Aceita o contrato de licença do Xcode sem abrir a janela interativa | Nenhuma saída em caso de sucesso |

**`sudo`** (*superuser do*) executa o comando como administrador. O macOS vai pedir a **senha do
seu usuário do Mac** — que você digita sem ver nada na tela, porque o terminal não exibe nem
asteriscos. Isso é normal.

**Como confirmar objetivamente que funcionou:**

```bash
xcode-select -p
xcodebuild -version
```

Saída esperada:

```text
/Applications/Xcode.app/Contents/Developer
Xcode 26.x
Build version 26Xxxx
```

Se `xcode-select -p` responder `/Library/Developer/CommandLineTools`, o passo do `--switch` não
pegou: repita-o. Esse é, de longe, o erro nº 1 desta aula.

---

## 📱 Aplicando no Flutter

### Lendo o `flutter doctor` no macOS

Com tudo configurado, `flutter doctor` em um Mac tem esta cara:

```bash
flutter doctor
```

```text
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.47.1, on macOS 26.x darwin-arm64, locale pt-BR)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS (Xcode 26.x)
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code
[✓] Connected device (3 available)
[✓] Network resources

• No issues found!
```

Como ler cada símbolo:

| Símbolo | Significa | O que fazer |
|---|---|---|
| `[✓]` | Tudo certo nessa categoria | Nada |
| `[!]` | Funciona, mas com ressalva | Ler a ressalva. Algumas são ignoráveis (ex.: Android Studio ausente se você usa VS Code); outras não |
| `[✗]` | Bloqueia o desenvolvimento naquela plataforma | Corrigir antes de seguir |
| `[☠]` | A própria checagem quebrou | Quase sempre caminho com acento ou instalação corrompida — veja a Aula 1 do Módulo 00 e [erros-comuns.md](../../referencias/erros-comuns.md) |

As três mensagens mais comuns na linha do Xcode e o que fazer:

```text
[!] Xcode - develop for iOS and macOS (Xcode 26.x)
    ✗ Xcode installation is incomplete; a full installation is necessary for iOS development.
```
→ Rode `sudo xcodebuild -runFirstLaunch`.

```text
    ✗ CocoaPods not installed.
```
→ Rode `sudo gem install cocoapods` (detalhado adiante nesta aula).

```text
    ✗ You have not agreed to the Xcode license agreements.
```
→ Rode `xcodebuild -license accept` (ou `sudo xcodebuild -license` para ler o texto).

Sempre que uma linha vier com `[!]` ou `[✗]`, use a versão detalhada:

```bash
flutter doctor -v
```

Ela mostra os caminhos exatos e a versão exata de cada ferramenta — é o que permite descobrir, por
exemplo, que o `xcode-select` está apontando para o lugar errado.

### Ligando e desligando o Swift Package Manager

**Globalmente**, para todos os projetos daquela instalação do Flutter:

```bash
flutter config --enable-swift-package-manager
flutter config --no-enable-swift-package-manager
```

Para conferir o estado atual de todas as opções:

```bash
flutter config --list
```

**Por projeto**, desligando só no Foco, sem mexer na configuração global. Edite o `pubspec.yaml`:

```yaml
flutter:
  config:
    enable-swift-package-manager: false
```

> ⚠️ Esse bloco `config:` fica **dentro** de `flutter:`, com dois níveis de indentação. Não
> confunda com os blocos `flutter_launcher_icons:` e `flutter_native_splash:`, que são de
> **primeiro nível** (Aula 5). Indentação errada de YAML é o erro mais frequente do `pubspec.yaml`.

**Quando desligar o SPM em um projeto:** quando um plugin específico quebra com SPM e você precisa
entregar hoje. É uma medida temporária. O caminho correto é abrir uma issue no plugin e voltar a
ligar depois.

### Instalando e usando o CocoaPods

```bash
sudo gem install cocoapods
pod --version
```

`gem` é o gerenciador de pacotes do Ruby, que já vem no macOS. `sudo` é necessário porque a
instalação escreve em pasta do sistema.

> ⚠️ Em alguns Macs, o Ruby do sistema causa conflito de permissão. A alternativa recomendada é
> instalar o CocoaPods pelo **Homebrew** (`brew install cocoapods`), um gerenciador de pacotes de
> macOS muito usado. Use essa alternativa apenas se o `gem install` falhar, para não ter duas
> instalações concorrentes.

Os comandos do dia a dia, sempre executados **dentro da pasta `ios/`**:

```bash
cd ios
pod install
pod repo update
pod install --repo-update
cd ..
```

| Comando | Quando usar | O que faz |
|---|---|---|
| `pod install` | Depois de `flutter pub get` que adicionou ou removeu plugins | Baixa as dependências e regrava `Podfile.lock` e `Pods/` |
| `pod repo update` | Quando `pod install` reclama que não encontra uma versão | Atualiza o catálogo local de pods (é demorado: pode levar vários minutos) |
| `pod install --repo-update` | Os dois de uma vez | Atalho para o caso acima |
| `pod deintegrate` | Quando **todos** os plugins do projeto já suportam SPM | Remove o CocoaPods do projeto: apaga `Pods/`, o workspace gerado e as referências |

> ⚠️ **Não rode `pod deintegrate` por curiosidade.** Rode só depois de confirmar, plugin por
> plugin, que todos suportam SPM — e com o projeto commitado, para poder voltar atrás com
> `git checkout`.

O `Podfile` de um projeto Flutter é **gerado pelo Flutter**. Você raramente o edita à mão; a
exceção mais comum é subir a linha da plataforma quando um plugin exige uma versão mínima maior:

```ruby
platform :ios, '13.0'
```

A Aula 10 trata exatamente desse caso.

---

## 💻 Código completo

Roteiro único que faz a configuração inteira do Mac e **confere** cada passo. Crie o arquivo agora,
no Windows, e commite — no Mac você só executa.

> **Arquivo:** `foco/ferramentas/configurar-mac-ios.sh`
> **Como executar (no Mac, dentro da pasta do projeto):** `bash ferramentas/configurar-mac-ios.sh`

```bash
#!/usr/bin/env bash
# configurar-mac-ios.sh
# Primeira configuracao do ambiente iOS em um Mac, para o projeto Foco.
# Rode DENTRO da pasta do projeto. Exige macOS com Xcode ja instalado pela App Store.

set -u  # aborta se alguma variavel usada nao existir

titulo() {
  echo ""
  echo "===================================================================="
  echo "$1"
  echo "===================================================================="
}

falhar() {
  echo "  [ERRO] $1"
  echo "  Corrija e rode o roteiro de novo."
  exit 1
}

titulo "0. Conferindo que estamos em um Mac"
if [ "$(uname)" != "Darwin" ]; then
  falhar "Este roteiro so roda em macOS. No Windows, leia a aula e pule esta etapa."
fi
echo "  [OK] macOS detectado: $(sw_vers -productVersion)"

titulo "1. Xcode instalado?"
if [ ! -d "/Applications/Xcode.app" ]; then
  falhar "Xcode nao encontrado em /Applications/Xcode.app. Instale pela Mac App Store."
fi
echo "  [OK] /Applications/Xcode.app existe"

titulo "2. Command Line Tools"
xcode-select --install 2>/dev/null || echo "  [INFO] Command Line Tools ja instaladas."

titulo "3. Apontando as ferramentas para o Xcode completo"
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
CAMINHO_DEV="$(xcode-select -p)"
echo "  Developer directory: ${CAMINHO_DEV}"
if [ "${CAMINHO_DEV}" != "/Applications/Xcode.app/Contents/Developer" ]; then
  falhar "xcode-select ainda aponta para ${CAMINHO_DEV}."
fi
echo "  [OK] apontando para o Xcode completo"

titulo "4. Componentes adicionais e licenca"
sudo xcodebuild -runFirstLaunch
xcodebuild -license accept
echo "  [OK] componentes instalados e licenca aceita"
xcodebuild -version

titulo "5. Estado do Swift Package Manager no Flutter"
flutter config --list | grep -i "swift-package-manager" || \
  echo "  [INFO] Sem linha explicita: o SPM esta no padrao (LIGADO desde o Flutter 3.44)."

titulo "6. CocoaPods"
if command -v pod >/dev/null 2>&1; then
  echo "  [OK] CocoaPods instalado: $(pod --version)"
else
  echo "  [INFO] CocoaPods ausente. Instalando..."
  sudo gem install cocoapods || falhar "Falha ao instalar o CocoaPods. Tente: brew install cocoapods"
  echo "  [OK] CocoaPods instalado: $(pod --version)"
fi

titulo "7. Preparando as dependencias do projeto"
flutter clean
flutter pub get
if [ -f "ios/Podfile" ]; then
  echo "  Podfile encontrado: rodando pod install"
  ( cd ios && pod install )
else
  echo "  [INFO] Sem Podfile: o projeto esta 100% em Swift Package Manager."
fi

titulo "8. Diagnostico final"
flutter doctor -v

titulo "9. Proximos passos"
echo "  Abra o workspace (NUNCA o .xcodeproj):"
echo "    open ios/Runner.xcworkspace"
echo "  Depois siga a Aula 3 para rodar no Simulador."
```

**Como confirmar objetivamente que funcionou:** o roteiro chega até a seção `9. Proximos passos`
sem nenhum `[ERRO]`, o `xcodebuild -version` da seção 4 imprime uma versão do Xcode, e o
`flutter doctor -v` da seção 8 mostra `[✓] Xcode - develop for iOS and macOS`.

---

## 🔍 Explicando o código

- `#!/usr/bin/env bash` é o **shebang**: a primeira linha que diz ao sistema com qual interpretador
  executar o arquivo. `env bash` acha o bash em qualquer caminho, o que é mais portátil que
  `/bin/bash`.
- `set -u` faz o script abortar se você usar uma variável que não existe. Não usamos `set -e`
  aqui de propósito: queremos tratar cada falha com uma mensagem em português, pela função
  `falhar`, em vez de o script morrer em silêncio.
- `uname` devolve o nome do núcleo do sistema. No macOS ele responde `Darwin` — esse é o teste
  mais direto de "estou em um Mac?".
- `sw_vers -productVersion` devolve a versão do macOS, por exemplo `26.1`.
- `xcode-select --install 2>/dev/null || echo ...`: quando as ferramentas já estão instaladas, o
  comando **falha** com código diferente de zero e imprime um aviso no *stderr* (o canal de erro).
  `2>/dev/null` joga esse aviso fora e `||` executa o `echo` alternativo. É a forma idiomática de
  dizer "tente, e se já estiver feito, siga em frente".
- `CAMINHO_DEV="$(xcode-select -p)"` guarda a saída do comando numa variável. `$( )` é
  **substituição de comando**: roda o comando e devolve o texto impresso por ele.
- O `if` seguinte é o teste que pega o erro nº 1 da aula: o `--switch` aparentemente rodou, mas o
  caminho continuou apontando para `/Library/Developer/CommandLineTools`.
- `command -v pod >/dev/null 2>&1` é a forma correta de perguntar "este comando existe?" em bash.
  `which` também funciona, mas `command -v` é embutido no shell e mais confiável.
- `( cd ios && pod install )` roda dentro de um **subshell** — os parênteses criam um shell filho.
  A troca de pasta vale só ali dentro; ao sair dos parênteses, você continua na raiz do projeto.
  Sem isso, o resto do script rodaria dentro de `ios/`.
- `flutter clean` antes do `pub get` é intencional: você acabou de trocar de sistema operacional.
  Restos de build do Windows na pasta `build/` só atrapalham.
- `grep -i` procura sem diferenciar maiúsculas e minúsculas.

---

## 🤖🍎 Android × iOS

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Gerenciador de dependências nativo | Gradle, com repositórios Maven | SPM (padrão) e CocoaPods (legado) |
| Arquivo de declaração | `android/app/build.gradle.kts` | `ios/Podfile` (CocoaPods) ou pacotes SPM gerados |
| Arquivo de travamento de versões | `gradle.lockfile` (opcional) | `ios/Podfile.lock` |
| Quem escreve esse arquivo | Flutter gera o esqueleto; você edita bastante | Flutter gera; você quase não edita |
| Comando de sincronização | Automático no `flutter build` | `pod install` quando o Flutter pede |
| Versão mínima de sistema no Flutter 3.47 | `minSdk = 24` (Android 7.0) | Deployment target **iOS 13** |
| Linguagem do build | Kotlin DSL (`.kts`) | Ruby (`Podfile`) e Swift (SPM) |
| Onde ficam as dependências baixadas | Cache do Gradle, fora do projeto | `ios/Pods/` (CocoaPods) ou `ios/Flutter/ephemeral/Packages` (SPM) |

Um ponto que costuma confundir: no Android, o `build.gradle.kts` do módulo `app` é um arquivo que
você **edita bastante** (assinatura, `applicationId`, tipos de build — Módulo 14). No iOS, o
equivalente está espalhado entre o `project.pbxproj` (que você edita pela interface do Xcode) e o
`Podfile` (que você quase nunca edita). Não procure um "build.gradle do iOS": ele não existe.

---

## ⚠️ Erros comuns

**1. `xcode-select -p` continua devolvendo `/Library/Developer/CommandLineTools`.**
O `--switch` não pegou. Rode de novo com `sudo` e confira o caminho letra por letra:
`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`. Se o Xcode estiver com
outro nome (por exemplo `Xcode-beta.app`), ajuste o caminho.

**2. `flutter doctor` diz `Xcode installation is incomplete`.**
Faltou `sudo xcodebuild -runFirstLaunch`. Esse comando instala componentes que a App Store não
traz de imediato. Ele pode demorar vários minutos.

**3. `You have not agreed to the Xcode license agreements`.**
Rode `xcodebuild -license accept`. Se quiser ler o contrato antes (recomendado ao menos uma vez),
use `sudo xcodebuild -license` e role até o fim com a barra de espaço.

**4. `sudo gem install cocoapods` falha com erro de permissão.**
O Ruby do sistema é protegido em alguns Macs. A saída é instalar pelo Homebrew:
`brew install cocoapods`. **Não** instale pelos dois caminhos ao mesmo tempo: você acaba com duas
versões do `pod` no `PATH` e um comportamento imprevisível.

**5. Achar que o CocoaPods "não é mais necessário" e apagar a pasta `ios/Pods`.**
Enquanto qualquer plugin do projeto não suportar SPM, o Flutter cai de volta para o CocoaPods e
precisa dessa pasta. Apagar sem rodar `pod install` de novo quebra o build.

**6. Confundir "SPM ligado" com "CocoaPods sumiu".**
Os dois convivem. Ver `pod install` rodando num projeto Flutter 3.47 é normal e esperado.

**7. Editar arquivos dentro de `ios/Flutter/ephemeral/`.**
Conteúdo gerado. O Flutter sobrescreve sem avisar. O mesmo vale para
`ios/Flutter/Generated.xcconfig`.

**8. Indentar errado o bloco `config:` no `pubspec.yaml`.**
Ele fica dentro de `flutter:`. Se você colocar no primeiro nível, o Flutter ignora — e você passa
uma hora achando que o SPM não desliga.

---

## 🛠️ Exercício guiado

**Objetivo:** deixar o projeto Foco pronto para a chegada ao Mac, sem sair do Windows.

**Passo 1.** Crie o roteiro de configuração.

```powershell
Set-Location C:\src\cursos\foco
New-Item -ItemType Directory -Force ferramentas
code ferramentas\configurar-mac-ios.sh
```

Cole o conteúdo da seção "Código completo". Salve com quebra de linha **LF**, não CRLF — no VS
Code, o indicador fica no canto inferior direito da janela; clique nele e escolha `LF`. Scripts
bash com CRLF falham no macOS com mensagens confusas do tipo `bad interpreter`.

**Passo 2.** Garanta que o Git não vai converter a quebra de linha. Crie ou edite o arquivo
`.gitattributes` na raiz do projeto:

```text
* text=auto
*.sh text eol=lf
```

`eol=lf` obriga o Git a gravar aquele arquivo com quebra de linha Unix, independentemente do
sistema de quem clonar.

**Passo 3.** Decida e registre a estratégia de dependências do Foco. Como todos os pacotes do
curso são bem mantidos, **mantenha o SPM ligado** (o padrão). Para registrar a decisão de forma
explícita no projeto, adicione um comentário no `pubspec.yaml`, logo acima do bloco `flutter:`:

```yaml
# Estrategia iOS: Swift Package Manager (padrao desde o Flutter 3.44).
# O Flutter cai automaticamente para o CocoaPods se algum plugin ainda nao suportar SPM.
flutter:
  uses-material-design: true
```

**Passo 4.** Confirme que o `pubspec.yaml` continua válido:

```powershell
flutter pub get
```

Resultado esperado: termina com `Got dependencies!` e sem nenhuma mensagem de erro de YAML.

**Passo 5.** Commite tudo:

```powershell
git add ferramentas/configurar-mac-ios.sh .gitattributes pubspec.yaml
git commit -m "Roteiro de configuracao do ambiente iOS e estrategia de dependencias"
```

**Passo 6.** Escreva, com suas palavras, as respostas: (a) por que `pod install` roda dentro de
`ios/` e não na raiz? (b) o que acontece com o CocoaPods em 2 de dezembro de 2026 e o que **não**
acontece? (c) qual é a diferença entre `flutter config --no-enable-swift-package-manager` e o
bloco `config:` no `pubspec.yaml`?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-ios.md](../../exercicios/15-build-ios.md)

---

## 🏆 Desafio opcional

Monte a **tabela de decisão de gerenciador de dependências** do seu projeto. Para cada pacote do
Foco que tem código nativo iOS — `shared_preferences`, `sqflite`, `path_provider`,
`flutter_secure_storage`, `connectivity_plus` — pesquise na página do pacote no `pub.dev` e na
página do repositório:

1. O pacote declara suporte a Swift Package Manager?
2. Ele ainda distribui um `podspec` (o arquivo de descrição do CocoaPods)?
3. Qual é o deployment target mínimo de iOS que ele exige?

Monte uma tabela com essas três colunas e responda: **o projeto Foco poderia rodar
`pod deintegrate` hoje?** Justifique com base nos dados que você levantou, não em suposição.

Guarde a tabela: ela é exatamente o tipo de levantamento que a Aula 10 usa para diagnosticar o
erro de `platform :ios` menor do que um plugin exige.

---

## 📌 Resumo

- O Xcode traz a toolchain, os SDKs, o Simulator, o Organizer e o Instruments. Reserve de **1 a 2
  horas** e **60 GB** livres para instalar.
- A primeira configuração são quatro comandos, nesta ordem: `xcode-select --install`,
  `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`,
  `sudo xcodebuild -runFirstLaunch`, `xcodebuild -license accept`.
- Confirme com `xcode-select -p` (deve devolver o caminho dentro de `Xcode.app`) e
  `xcodebuild -version`.
- `flutter doctor` em macOS ganha a linha `[✓] Xcode - develop for iOS and macOS`. Use
  `flutter doctor -v` para ver caminhos e versões quando algo vier com `[!]` ou `[✗]`.
- **SPM está ligado por padrão desde o Flutter 3.44.** O 3.47.1 já usa SPM. Ligue/desligue com
  `flutter config --enable-swift-package-manager` / `--no-enable-swift-package-manager`, ou por
  projeto com o bloco `config:` dentro de `flutter:` no `pubspec.yaml`.
- O Flutter volta automaticamente ao **CocoaPods** quando algum plugin não suporta SPM. Os dois
  convivem.
- CocoaPods: `sudo gem install cocoapods`, `pod install` dentro de `ios/`, `pod repo update`
  quando faltar versão, `pod deintegrate` só quando **todos** os plugins suportarem SPM.
- O CocoaPods está em modo de manutenção e seu registro fica **somente-leitura em 2 de dezembro de
  2026**: nada novo é publicado, o que já existe continua baixável.

---

## ☑️ Checklist de domínio

- [ ] Digo de cor os quatro comandos de primeira configuração, na ordem correta.
- [ ] Explico a diferença entre Command Line Tools e Xcode completo, e por que só as primeiras não
      bastam.
- [ ] Sei verificar para onde o `xcode-select` está apontando e corrigir se estiver errado.
- [ ] Traduzo `[✓]`, `[!]`, `[✗]` e `[☠]` do `flutter doctor` em ações.
- [ ] Reconheço as três mensagens clássicas da linha do Xcode e sei a correção de cada uma.
- [ ] Explico o que é o Swift Package Manager e desde qual versão do Flutter ele é o padrão.
- [ ] Ligo e desligo o SPM globalmente e por projeto, com a indentação correta no `pubspec.yaml`.
- [ ] Explico por que o CocoaPods ainda aparece em projetos Flutter 3.47.
- [ ] Digo o que muda e o que **não** muda no CocoaPods em 2 de dezembro de 2026.
- [ ] Sei quando usar `pod install`, `pod repo update` e `pod deintegrate`.
- [ ] Criei `ferramentas/configurar-mac-ios.sh` com quebra de linha LF e commitei.

---

## 📚 Referências oficiais

- [Flutter — Install on macOS](https://docs.flutter.dev/get-started/install/macos)
- [Flutter — Swift Package Manager for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)
- [Flutter — Swift Package Manager for plugin authors](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)
- [Flutter — Build and release an iOS app](https://docs.flutter.dev/deployment/ios)
- [Apple — Xcode](https://developer.apple.com/xcode/)
- [Apple — Swift Package Manager](https://www.swift.org/documentation/package-manager/)
- [CocoaPods — Guides](https://guides.cocoapods.org/)
- [CocoaPods — Blog oficial](https://blog.cocoapods.org/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Por que o iOS exige macOS](01-por-que-exige-macos.md) | [README](README.md) | [Aula 3 — Simulador e iPhone físico](03-simulador-e-iphone-fisico.md) |
