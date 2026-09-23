# Aula 1 — Por que o iOS exige macOS

> **Módulo:** 16 - Build e Distribuição iOS · **Tempo estimado:** 30 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Explicar, com precisão técnica, **três motivos independentes** pelos quais a compilação de um
  app iOS só acontece em macOS: a toolchain, os SDKs e a assinatura.
- Citar o motivo **jurídico** (contrato de licença do Xcode) e por que ele importa mesmo para um
  projeto pessoal.
- Listar exatamente **o que você consegue fazer hoje no Windows** para o app Foco e o que fica
  parado à espera de um Mac.
- Comparar as **quatro formas reais** de obter acesso a um Mac — emprestado, Mac mini próprio,
  Mac alugado na nuvem e CI com runner macOS — com prós, contras e faixa de custo.
- Escrever e executar um script de diagnóstico que mostra, na sua máquina, o que já está pronto
  para iOS e o que depende do Mac.

## ✅ Pré-requisitos

- [Módulo 15 — Build e Distribuição Android](../15-build-android/README.md) concluído. Você já
  gerou APK e AAB assinados; aqui você vai entender por que o caminho equivalente no iOS é
  fechado no Windows.
- Flutter **3.47.1** funcionando no PowerShell (`flutter --version`).
- Projeto **Foco** na sua máquina, em um caminho sem acentos — por exemplo `C:\src\cursos\foco`.
  Se você ainda tem o SDK ou o projeto em caminho com acento, resolva primeiro em
  [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

---

## 🍎🪟 Antes de começar: onde você está

> # 🍎 VOCÊ ESTÁ NO WINDOWS. NADA DE COMPILAÇÃO iOS ACONTECE AQUI.
>
> Esta aula é a única do módulo em que isso é **o assunto**, e não um aviso de rodapé.
> Ao final dela você vai saber, com números e argumentos, por que a porta está fechada, o que
> você faz enquanto ela estiver fechada, e quanto custa abri-la.
>
> **O que você executa nesta aula:** o script de diagnóstico da seção "Código completo".
> Ele roda no seu Windows 11, agora, e produz um relatório honesto do seu ambiente.
>
> **O que fica para quando você tiver um Mac:** absolutamente toda compilação, assinatura,
> execução em Simulador ou iPhone, e envio para a App Store.

---

## 📖 Conceito

### O que é uma toolchain

**Toolchain** (*cadeia de ferramentas*) é o conjunto de programas que transforma o seu código-fonte
em um binário que o aparelho consegue executar. Uma toolchain tem, no mínimo:

| Peça | O que faz | Nome da peça no mundo Apple |
|---|---|---|
| Compilador | Traduz código-fonte para código de máquina | `clang` (do projeto LLVM, na versão que vem no Xcode) |
| Linker | Junta os pedaços compilados e as bibliotecas em um executável | `ld` da Apple |
| SDK | Os cabeçalhos e bibliotecas do sistema operacional alvo | iPhoneOS SDK |
| Assinador | Carimba o binário com um certificado criptográfico | `codesign` |
| Empacotador | Monta o `.app` e o `.ipa` | `xcodebuild` / `xcrun` |

**SDK** (*Software Development Kit*) é o pacote de ferramentas, bibliotecas e cabeçalhos que
você instala para poder programar para uma plataforma.

O Flutter não substitui nada disso no iOS. O Flutter compila o seu Dart para código nativo ARM e
depois **entrega esse resultado para a toolchain da Apple**, que faz o resto. Sem a toolchain da
Apple, o Flutter para no meio do caminho.

### Motivo 1 — A toolchain da Apple só existe compilada para macOS

`clang`, `ld`, `codesign`, `xcodebuild`, `xcrun`, `actool` (o compilador de catálogos de imagens),
`ibtool` (o compilador de storyboards), `simctl` (o controlador do Simulador): todos são binários
**Mach-O** — o formato executável do macOS — distribuídos apenas dentro do Xcode, apenas para
macOS. A Apple nunca publicou versões para Windows nem para Linux.

Note que o problema não é só o compilador. Mesmo se você conseguisse compilar, ainda faltariam
`actool` para transformar o `Assets.xcassets` em `Assets.car`, `ibtool` para transformar o
`LaunchScreen.storyboard` em um `.storyboardc`, e `codesign` para assinar. Cada um desses passos é
obrigatório em um IPA válido, e cada um deles é um binário exclusivo de macOS.

### Motivo 2 — Os SDKs do iOS são distribuídos dentro do Xcode

O SDK do iPhone não é um download separado. Ele vive **dentro do pacote do Xcode**, neste caminho:

```text
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
```

Ali estão os frameworks do sistema: `UIKit`, `Foundation`, `Metal`, `CoreLocation`, `AVFoundation`
e dezenas de outros. **Framework**, no vocabulário da Apple, é uma pasta que empacota uma
biblioteca compilada junto com seus cabeçalhos e recursos.

O Flutter precisa desses frameworks porque o motor gráfico dele fala com `Metal` (a API gráfica da
Apple), o plugin de câmera fala com `AVFoundation`, o plugin de localização fala com
`CoreLocation`. Não há como compilar contra um framework que você não possui.

E o Xcode só instala em macOS: ele é distribuído pela Mac App Store e pelo portal de
desenvolvedores da Apple, em formatos (`.xip`, pacote `.app`) que só o macOS abre e executa.

### Motivo 3 — A assinatura depende do chaveiro do macOS

**Assinar** um app é anexar a ele uma prova criptográfica de que foi você quem o construiu. No iOS,
**nenhum app roda em aparelho sem assinatura válida** — nem em modo de desenvolvimento. Isso é
diferente do Android, onde você pode instalar um APK assinado com uma chave de depuração gerada
automaticamente.

A ferramenta que assina é o `codesign`, e ela busca a **chave privada** correspondente ao seu
certificado no **Keychain** (chaveiro) do macOS — o cofre de credenciais do sistema, integrado ao
Secure Enclave nos Macs modernos. O Xcode também usa o chaveiro para guardar os perfis e para
conversar com o portal da Apple.

Ou seja: mesmo com compilador e SDK mágicos, o último passo continuaria travado, porque ele
depende de um subsistema do sistema operacional da Apple.

### Motivo 4 — O contrato de licença do Xcode proíbe rodar fora de hardware Apple

O contrato de licença de software do Xcode (*Xcode and Apple SDKs Agreement*) autoriza o uso do
Xcode e dos SDKs **somente em computadores de marca Apple**. É por isso que:

- Instalar macOS em PC comum ("hackintosh") **viola o contrato**.
- Rodar macOS em máquina virtual dentro de um PC Windows **viola o contrato**.
- Provedores de nuvem que alugam Mac fazem isso com **hardware Apple real** em datacenter —
  justamente para ficarem dentro do contrato.

> ⚠️ Este curso **não** ensina hackintosh nem máquina virtual de macOS em PC. Além de contratual,
> o problema é prático: você passaria dias brigando com drivers, o Simulador não funciona bem sem
> aceleração gráfica adequada, e uma atualização do macOS quebra tudo. O tempo gasto ali custa
> mais do que alugar um Mac na nuvem por algumas horas.

### O resumo dos quatro motivos

```text
Seu código Dart
      |
      v
[ Flutter compila Dart -> código nativo ARM ]      <- isso funciona no Windows
      |
      v
[ clang / ld     ]  Motivo 1: binários só de macOS      X
[ iPhoneOS SDK   ]  Motivo 2: vem dentro do Xcode       X
[ actool/ibtool  ]  Motivo 1: binários só de macOS      X
[ codesign       ]  Motivo 3: exige o chaveiro do macOS X
[ xcodebuild     ]  Motivo 4: licença exige hardware Apple X
      |
      v
   Runner.app  ->  Runner.xcarchive  ->  Foco.ipa
```

---

## 💡 Analogia

Uma fábrica de chaves pode entregar a você a **chave em branco** (o seu código Dart compilado),
mas a **máquina que corta o segredo** e o **cofre que guarda o molde** ficam dentro da fábrica, e
o contrato diz que a máquina não sai de lá. Você pode desenhar a chave inteira em casa, medir,
conferir, testar o desenho — e vai gastar cinco minutos na fábrica quando chegar lá, porque já
chegou com tudo pronto.

É exatamente isso que as aulas 4, 5 e 6 deste módulo fazem: preparam o desenho completo no
Windows para que o tempo no Mac seja curto.

---

## 🧪 Exemplo mínimo

Abra o PowerShell na pasta do projeto Foco e rode:

```powershell
Set-Location C:\src\cursos\foco
flutter devices
```

Saída típica no seu Windows 11 (os nomes variam conforme o que estiver instalado):

```text
Found 2 connected devices:
  Windows (desktop) • windows • windows-x64    • Microsoft Windows [versão 10.0.26200]
  Chrome (web)      • chrome  • web-javascript • Google Chrome 152.x

No wireless devices were found.
```

Repare: nenhum dispositivo iOS aparece, e nenhum aparecerá — o Flutter só lista alvos iOS quando
detecta o Xcode. Agora rode:

```powershell
flutter doctor
```

Na saída, **não existe** a linha `[✓] Xcode - develop for iOS and macOS`. Ela só existe em macOS.
No Windows o `flutter doctor` lista Flutter, Windows, Android toolchain, Chrome, Visual Studio e
VS Code — e nada de Apple.

E se você insistir:

```powershell
flutter build ios --release
```

O Flutter recusa antes de compilar qualquer coisa, com uma mensagem cujo sentido é sempre este:

```text
Building for iOS is only supported on macOS.
```

Não é um erro de configuração. É o Flutter conferindo o sistema operacional e avisando que o
caminho não existe aqui. **Não há flag, variável de ambiente ou plugin que mude isso.**

---

## 📱 Aplicando no Flutter

### O que você faz HOJE, no Windows, pelo app Foco

| Etapa do app Foco | Dá no Windows? | Comando/arquivo |
|---|---|---|
| Escrever telas, providers, DAOs, repositórios | ✅ | `lib/**` |
| `flutter analyze` e `dart format .` | ✅ | terminal |
| Testes unitários e de widget | ✅ | `flutter test` |
| Testes de banco com `sqflite_common_ffi` | ✅ | `flutter test` |
| Rodar no Windows desktop e no Chrome | ✅ | `flutter run -d windows` |
| Rodar em emulador/aparelho Android | ✅ | `flutter run -d <id>` |
| Gerar APK e AAB de release assinados | ✅ | `flutter build apk` / `appbundle` |
| Definir o Bundle ID `br.com.estudos.foco` | ✅ (edita texto) | `ios/Runner.xcodeproj/project.pbxproj` |
| Gerar o ícone iOS | ✅ | `dart run flutter_launcher_icons` |
| Escrever permissões do `Info.plist` | ✅ (edita texto) | `ios/Runner/Info.plist` |
| Definir `version: 1.0.0+1` | ✅ | `pubspec.yaml` |
| Compilar para iOS | ❌ | exige macOS |
| Rodar no Simulador iOS | ❌ | exige macOS |
| Rodar em iPhone físico | ❌ | exige macOS |
| Assinar, gerar archive e IPA | ❌ | exige macOS |
| Enviar para TestFlight / App Store | ❌ | exige macOS (ou CI macOS) |

Repare que **dez das quinze linhas** são verdes. A parte iOS que você pode adiantar no Windows não
é decorativa: ela é justamente a parte que, se ficar para a última hora no Mac, causa retrabalho.

### O que muda no `flutter doctor` quando você chega ao Mac

Em um Mac com Xcode instalado, `flutter doctor` ganha duas seções novas:

```text
[✓] Xcode - develop for iOS and macOS (Xcode 26.x)
[✓] Connected device (2 available)
```

Na Aula 2 você aprende a ler cada linha dessas e a corrigir quando elas vierem com `[!]` ou `[✗]`.

---

## 💻 Código completo

Este script faz um diagnóstico honesto: mostra o que já está pronto no repositório para o dia do
Mac e o que **não** dá para fazer aqui. Ele **não** tenta compilar nada — só inspeciona.

> **Arquivo:** `foco/ferramentas/checar-ambiente-ios.ps1`
> **Como executar:** `powershell -ExecutionPolicy Bypass -File ferramentas\checar-ambiente-ios.ps1`

```powershell
# checar-ambiente-ios.ps1
# Relatorio do que esta pronto para iOS neste projeto, rodando no Windows.
# Nao compila nada: apenas inspeciona arquivos e ferramentas.

$ErrorActionPreference = 'Stop'

function Escrever-Titulo([string]$texto) {
    Write-Host ''
    Write-Host ('=' * 68)
    Write-Host $texto
    Write-Host ('=' * 68)
}

function Conferir-Arquivo([string]$caminho, [string]$descricao) {
    if (Test-Path -LiteralPath $caminho) {
        Write-Host ("  [OK]    {0,-46} {1}" -f $descricao, $caminho)
    } else {
        Write-Host ("  [FALTA] {0,-46} {1}" -f $descricao, $caminho)
    }
}

Escrever-Titulo '1. Sistema operacional'
$so = (Get-CimInstance Win32_OperatingSystem).Caption
Write-Host "  Sistema: $so"
Write-Host '  Conclusao: builds iOS exigem macOS + Xcode. Aqui, apenas preparacao.'

Escrever-Titulo '2. Flutter'
flutter --version

Escrever-Titulo '3. Arquivos iOS que JA existem no projeto'
Conferir-Arquivo 'ios\Runner.xcworkspace'                          'Workspace (abra SEMPRE este no Mac)'
Conferir-Arquivo 'ios\Runner.xcodeproj\project.pbxproj'            'Projeto Xcode (Bundle ID mora aqui)'
Conferir-Arquivo 'ios\Runner\Info.plist'                           'Info.plist (versao e permissoes)'
Conferir-Arquivo 'ios\Runner\AppDelegate.swift'                    'AppDelegate'
Conferir-Arquivo 'ios\Runner\SceneDelegate.swift'                  'SceneDelegate (Flutter 3.47)'
Conferir-Arquivo 'ios\Runner\Base.lproj\LaunchScreen.storyboard'   'Splash do iOS'
Conferir-Arquivo 'ios\Runner\Assets.xcassets\AppIcon.appiconset'   'Icone do app'
Conferir-Arquivo 'ios\Flutter\Debug.xcconfig'                      'Config de debug'
Conferir-Arquivo 'ios\Flutter\Release.xcconfig'                    'Config de release'

Escrever-Titulo '4. Bundle Identifier declarado no projeto'
$pbx = 'ios\Runner.xcodeproj\project.pbxproj'
if (Test-Path -LiteralPath $pbx) {
    $ids = Select-String -LiteralPath $pbx -Pattern 'PRODUCT_BUNDLE_IDENTIFIER = (.+);' -AllMatches
    $encontrados = $ids.Matches | ForEach-Object { $_.Groups[1].Value.Trim() } | Sort-Object -Unique
    foreach ($id in $encontrados) { Write-Host "  Encontrado: $id" }
    if ($encontrados -contains 'br.com.estudos.foco') {
        Write-Host '  [OK]    Bundle ID do curso presente: br.com.estudos.foco'
    } else {
        Write-Host '  [ACAO]  Ajuste o Bundle ID para br.com.estudos.foco (veja a Aula 4).'
    }
} else {
    Write-Host '  [FALTA] project.pbxproj nao encontrado. Rode: flutter create --platforms=ios .'
}

Escrever-Titulo '5. Versao do app (vale para iOS e Android)'
$versao = Select-String -LiteralPath 'pubspec.yaml' -Pattern '^version:\s*(.+)$'
if ($versao) {
    Write-Host ("  pubspec.yaml -> {0}" -f $versao.Matches[0].Groups[1].Value.Trim())
    Write-Host '  1.0.0 vira CFBundleShortVersionString; 1 vira CFBundleVersion.'
} else {
    Write-Host '  [ACAO] Declare version: 1.0.0+1 no pubspec.yaml (veja a Aula 5).'
}

Escrever-Titulo '6. Permissoes iOS ja escritas no Info.plist'
$plist = 'ios\Runner\Info.plist'
if (Test-Path -LiteralPath $plist) {
    $chaves = @('NSCameraUsageDescription', 'NSPhotoLibraryUsageDescription')
    foreach ($chave in $chaves) {
        if (Select-String -LiteralPath $plist -Pattern $chave -Quiet) {
            Write-Host "  [OK]    $chave declarada"
        } else {
            Write-Host "  [INFO]  $chave ausente (so declare se o app usar o recurso)"
        }
    }
}

Escrever-Titulo '7. Segredos que NUNCA podem ir para o Git'
$proibidos = @('*.p12', '*.cer', '*.mobileprovision', '*.certSigningRequest', 'key.properties', '*.jks')
$achados = @()
foreach ($padrao in $proibidos) {
    $achados += Get-ChildItem -Path . -Filter $padrao -Recurse -File -ErrorAction SilentlyContinue
}
if ($achados.Count -eq 0) {
    Write-Host '  [OK]    Nenhum arquivo de credencial encontrado no projeto.'
} else {
    Write-Host '  [ALERTA] Estes arquivos NAO podem ser versionados:'
    $achados | ForEach-Object { Write-Host ("           " + $_.FullName) }
    Write-Host '           Adicione os padroes ao .gitignore antes de commitar.'
}

Escrever-Titulo '8. Conclusao'
Write-Host '  Pronto no Windows: codigo, testes, APK/AAB, Bundle ID, icone, Info.plist, versao.'
Write-Host '  Pendente ate ter um Mac: compilar, assinar, Simulador, iPhone, archive, IPA, TestFlight.'
Write-Host ''
```

Saída esperada (resumida) em um projeto Foco já configurado:

```text
====================================================================
1. Sistema operacional
====================================================================
  Sistema: Microsoft Windows 11 Home Single Language
  Conclusao: builds iOS exigem macOS + Xcode. Aqui, apenas preparacao.

====================================================================
3. Arquivos iOS que JA existem no projeto
====================================================================
  [OK]    Workspace (abra SEMPRE este no Mac)          ios\Runner.xcworkspace
  [OK]    Projeto Xcode (Bundle ID mora aqui)          ios\Runner.xcodeproj\project.pbxproj
  [OK]    Info.plist (versao e permissoes)             ios\Runner\Info.plist
  [OK]    SceneDelegate (Flutter 3.47)                 ios\Runner\SceneDelegate.swift
  ...

====================================================================
7. Segredos que NUNCA podem ir para o Git
====================================================================
  [OK]    Nenhum arquivo de credencial encontrado no projeto.
```

**Como confirmar objetivamente que funcionou:** o script termina imprimindo a seção `8. Conclusao`
sem nenhuma exceção vermelha, e a seção 3 lista `[OK]` para `Runner.xcworkspace`,
`Info.plist` e `SceneDelegate.swift`. Se a seção 3 vier com `[FALTA]` em tudo, a pasta `ios/`
não foi gerada — rode `flutter create --platforms=ios .` dentro do projeto.

---

## 🔍 Explicando o código

- `$ErrorActionPreference = 'Stop'` faz o PowerShell **parar no primeiro erro** em vez de seguir
  adiante com resultados parciais. Sem isso, um caminho errado passaria despercebido.
- `function Escrever-Titulo` só imprime uma faixa. PowerShell usa a convenção **Verbo-Substantivo**
  para nomes de função; `Escrever-Titulo` segue essa convenção em português.
- `Test-Path -LiteralPath $caminho` pergunta se o arquivo ou pasta existe. O `-LiteralPath` trata o
  texto **literalmente**, sem interpretar `*`, `?` ou `[ ]` como curinga — importante porque
  caminhos podem conter colchetes.
- `("  [OK]    {0,-46} {1}" -f $descricao, $caminho)` é formatação de string. `{0,-46}` significa
  "argumento 0, alinhado à esquerda, ocupando 46 colunas" — é o que deixa as colunas do relatório
  alinhadas.
- `Select-String -Pattern 'PRODUCT_BUNDLE_IDENTIFIER = (.+);' -AllMatches` procura **todas** as
  ocorrências do Bundle ID dentro do `project.pbxproj`. Existem três, porque o projeto tem três
  configurações de build: `Debug`, `Release` e `Profile`. Os parênteses em `(.+)` criam um **grupo
  de captura**: `$_.Groups[1].Value` devolve só o que está dentro dos parênteses.
- `Sort-Object -Unique` remove as repetições, então se as três configurações tiverem o mesmo
  Bundle ID, você vê uma linha só. Se aparecerem duas linhas diferentes, você tem um problema real
  a corrigir — e o script acabou de te mostrar.
- `-Quiet` no `Select-String` faz ele devolver apenas `True`/`False`, sem imprimir a linha
  encontrada. É o suficiente para um "existe ou não existe".
- `Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue` varre o projeto inteiro atrás de
  arquivos de credencial. O `-ErrorAction SilentlyContinue` **local** (só nessa chamada) evita que
  uma pasta sem permissão de leitura derrube o script inteiro.
- A seção 7 existe porque o erro mais caro deste módulo não é técnico: é commitar um certificado.
  O script te avisa **antes** do commit.

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Sistema para compilar | Windows, macOS ou Linux | **Somente macOS** |
| Onde vem o SDK | Android SDK, baixado separadamente pelo SDK Manager | Dentro do Xcode |
| Compilador | `clang` do NDK + `javac`/`kotlinc` | `clang` do Xcode |
| Assinatura obrigatória para rodar no aparelho | Sim, mas o Flutter gera uma chave de **debug** sozinho | Sim, e exige certificado ligado a uma conta Apple |
| Onde mora a chave privada | Arquivo `.jks` que **você** cria e guarda | Chaveiro do macOS (Keychain) |
| Instalar sem loja | `flutter install`, `adb install`, arquivo APK direto | Só com perfil de provisionamento válido |
| Custo para publicar | US$ 25, pagamento único | US$ 99 por ano, renovável |
| Emulador roda no Windows | Sim | Não; Simulador só em macOS |

A consequência prática dessa tabela para você: **o Android é o seu laboratório diário** e o iOS é
uma etapa de entrega concentrada. Planeje as duas coisas de forma diferente.

---

## ⚠️ Erros comuns

**1. "Vou usar um site que gera IPA na nuvem a partir do meu ZIP."**
Os serviços sérios (Codemagic, Bitrise, GitHub Actions) rodam o build em **Macs reais** e exigem
que você forneça certificado e perfil — ou seja, você ainda precisa de uma conta Apple e do
processo das Aulas 6 e 7. Serviços que prometem IPA sem nada disso ou não entregam um IPA
instalável, ou pedem suas credenciais da Apple, o que é um risco sério de segurança.

**2. "Instalei macOS numa máquina virtual, está funcionando."**
Viola o contrato de licença do Xcode e falha de forma aleatória: o Simulador precisa de aceleração
gráfica, o `codesign` precisa do chaveiro íntegro, e o `xcodebuild` costuma travar na etapa de
compilação de assets. Você vai gastar mais horas depurando a VM do que o app inteiro levou para
ser escrito.

**3. Rodar `flutter build ipa` no Windows e achar que faltou instalar algo.**
Não faltou. A mensagem `Building for iOS is only supported on macOS.` é uma checagem de sistema
operacional, não um pré-requisito ausente. Instalar CocoaPods, Ruby ou qualquer outra coisa no
Windows não muda nada.

**4. Deixar a parte iOS para o último dia no Mac.**
O erro mais caro do módulo. Bundle ID, ícone, `Info.plist` e versão podem ser feitos hoje. Quem
chega no Mac sem isso pronto passa metade do tempo disponível em tarefas que não exigiam Mac.

**5. Achar que o Flutter "resolve" o iOS sozinho.**
O Flutter resolve a **camada de interface e lógica**. Assinatura, perfis, App Store Connect e
TestFlight são processos da Apple, idênticos para qualquer tecnologia. É por isso que este módulo
tem 10 aulas.

**6. Copiar o projeto para o Mac por pendrive, com a pasta `build/` junto.**
Leve por **Git**. A pasta `build/` contém artefatos do Windows que não servem no Mac e podem
confundir o Xcode. Se precisar copiar manualmente, rode `flutter clean` antes.

---

## 🛠️ Exercício guiado

**Objetivo:** produzir o seu relatório pessoal de diagnóstico e o seu plano de acesso ao Mac.

**Passo 1.** Crie a pasta de ferramentas dentro do projeto Foco.

```powershell
Set-Location C:\src\cursos\foco
New-Item -ItemType Directory -Force ferramentas
```

**Passo 2.** Crie o arquivo `ferramentas\checar-ambiente-ios.ps1` com o conteúdo da seção
"Código completo". Use o VS Code: `code ferramentas\checar-ambiente-ios.ps1`.

**Passo 3.** Execute e leia o relatório inteiro:

```powershell
powershell -ExecutionPolicy Bypass -File ferramentas\checar-ambiente-ios.ps1
```

`-ExecutionPolicy Bypass` libera a execução **apenas desta chamada** — o Windows bloqueia scripts
`.ps1` por padrão. A configuração global da máquina não é alterada.

**Passo 4.** Anote as respostas destas três perguntas, olhando a saída:

1. O seu `project.pbxproj` já declara `br.com.estudos.foco`? Se não, isso é tarefa da Aula 4.
2. O seu `pubspec.yaml` já tem `version: 1.0.0+1`? Se não, é tarefa da Aula 5.
3. A seção 7 encontrou algum arquivo de credencial? Se sim, **não commite** e leia
   [referencias/erros-comuns.md](../../referencias/erros-comuns.md).

**Passo 5.** Confirme que o script não entrou no repositório por engano com um segredo junto:

```powershell
git status
git add ferramentas/checar-ambiente-ios.ps1
git commit -m "Ferramenta de diagnostico do ambiente iOS"
```

**Passo 6.** Escreva, em um arquivo de texto seu (fora do curso), qual das quatro opções de Mac da
próxima seção você vai usar, com data alvo e custo. Um plano com data é o que separa "um dia eu
publico no iOS" de "em março eu publico no iOS".

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/16-build-ios.md](../../exercicios/16-build-ios.md)

---

## 🏆 Desafio opcional

### As quatro formas reais de conseguir um Mac

Estude a tabela, escolha uma e justifique por escrito. Os valores são **faixas aproximadas** para
orientação; confira o preço atual antes de decidir, porque preço de hardware e de plano de nuvem
muda com frequência.

| Opção | Como funciona | Prós | Contras | Custo aproximado |
|---|---|---|---|---|
| **1. Mac emprestado** | Você leva o projeto no Git e usa o Mac de alguém (amigo, faculdade, trabalho, coworking) por algumas horas | Custo zero; hardware real; serve para aprender o processo inteiro | Você depende da agenda de outra pessoa; instalar o Xcode leva horas; precisa entrar com o **seu** Apple ID e sair depois | R$ 0 |
| **2. Mac mini próprio** | Compra do modelo de entrada com chip da série M, usado ou novo | Seu, sempre disponível; o modelo de entrada compila Flutter com folga; revende bem | Investimento alto de uma vez; precisa de monitor, teclado e mouse (pode reaproveitar os do PC) | Usado: faixa de R$ 3.000 a R$ 5.000 · Novo: a partir de cerca de US$ 599 (confira o câmbio e os impostos) |
| **3. Mac alugado na nuvem** | Você acessa remotamente um Mac real em datacenter (MacStadium, Scaleway e similares), por hora ou por mês | Sem investimento inicial; hardware real e dentro do contrato da Apple; dá para usar só nos dias de build | Depende de internet boa; latência incomoda no Xcode; custo recorrente cresce se você usar todo dia | Faixa de US$ 0,10 a US$ 1,00 por hora, ou dezenas de dólares por mês, conforme o provedor e a máquina |
| **4. CI com runner macOS** | Um serviço de integração contínua compila para você a cada `git push`: **Codemagic** ou **GitHub Actions** com `runs-on: macos-latest` | Automático; ótimo para builds repetidos; não exige nenhum hardware seu; integra direto com TestFlight | Você **não** vê a tela do Xcode, então depurar erro de assinatura é mais difícil; exige subir certificado e perfil como segredo do serviço; minutos de macOS consomem cota mais rápido | Ambos têm camada gratuita com um número limitado de minutos de macOS por mês; acima disso, cobrança por minuto. Confira o plano atual de cada serviço |

**Integração contínua (CI)** é um serviço que roda a compilação em um servidor toda vez que você
envia código, em vez de na sua máquina. O Módulo 17 trata disso em
[04-ci-cd-introdutorio.md](../17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md).

**Recomendação honesta para o seu momento:** comece pela **opção 1** (Mac emprestado) para fazer
as Aulas 2 a 9 uma vez, de ponta a ponta, com o Xcode na sua frente. Depois de entender o
processo, a **opção 4** (CI) passa a fazer sentido, porque aí você sabe interpretar as mensagens
de erro que o log do CI devolve. Começar pela opção 4 sem nunca ter visto o Xcode é a receita
para ficar preso num erro de assinatura sem saber o que olhar.

**Entrega do desafio:** um texto de 10 a 15 linhas explicando sua escolha, com custo estimado,
data alvo e qual é o plano B se a opção escolhida falhar.

---

## 📌 Resumo

- A compilação iOS exige macOS por **quatro motivos independentes**: a toolchain (`clang`, `ld`,
  `codesign`, `actool`, `ibtool`, `xcodebuild`) só existe compilada para macOS; o SDK do iPhone é
  distribuído dentro do Xcode; a assinatura depende do chaveiro do macOS; e o contrato de licença
  do Xcode restringe o uso a hardware Apple.
- Isso **não** é limitação do Flutter. Vale para qualquer tecnologia que gere app iOS.
- No Windows você faz: todo o código Dart/Flutter, todos os testes, APK e AAB de release, Bundle
  ID, ícone iOS, permissões do `Info.plist` e versionamento.
- No Windows você **não** faz: compilar, assinar, Simulador, iPhone físico, archive, IPA,
  TestFlight, App Store.
- `flutter build ios` no Windows para com `Building for iOS is only supported on macOS.` — é uma
  checagem de sistema, não um pré-requisito faltando.
- Quatro formas legítimas de conseguir um Mac: emprestado (R$ 0), Mac mini próprio (investimento
  alto, disponível sempre), Mac na nuvem (por hora, sem investimento) e CI com runner macOS
  (automático, ótimo depois que você já entende o processo).
- Hackintosh e macOS em VM: violam o contrato e falham na prática. O curso não ensina.

---

## ☑️ Checklist de domínio

- [ ] Cito, sem consultar, os quatro motivos técnicos/jurídicos pelos quais o iOS exige macOS.
- [ ] Explico o que é uma toolchain e nomeio pelo menos quatro ferramentas da toolchain da Apple.
- [ ] Digo onde mora o SDK do iPhone dentro do Xcode.
- [ ] Explico o papel do chaveiro do macOS na assinatura.
- [ ] Listo cinco tarefas do app Foco que eu consigo fazer **hoje**, no Windows, pela plataforma
      iOS.
- [ ] Listo cinco tarefas que dependem obrigatoriamente do Mac.
- [ ] Reconheço a mensagem `Building for iOS is only supported on macOS.` e sei que ela não indica
      instalação incompleta.
- [ ] Comparo as quatro formas de acesso a um Mac citando pelo menos um pró e um contra de cada.
- [ ] Executei `ferramentas\checar-ambiente-ios.ps1` e li as oito seções do relatório.
- [ ] Sei dizer, olhando o relatório, se o meu Bundle ID e a minha `version` já estão corretos.
- [ ] Tenho um plano escrito, com data e custo, de como vou conseguir acesso a um Mac.

---

## 📚 Referências oficiais

- [Flutter — Build and release an iOS app](https://docs.flutter.dev/deployment/ios)
- [Flutter — Install on macOS](https://docs.flutter.dev/get-started/install/macos)
- [Flutter — Supported deployment platforms](https://docs.flutter.dev/reference/supported-platforms)
- [Apple — Xcode](https://developer.apple.com/xcode/)
- [Apple — Software License Agreements](https://www.apple.com/legal/sla/)
- [Apple — Code Signing](https://developer.apple.com/support/code-signing/)
- [Codemagic — CI/CD para Flutter](https://docs.codemagic.io/flutter/flutter-projects/)
- [GitHub Actions — runners hospedados](https://docs.github.com/actions/using-github-hosted-runners/about-github-hosted-runners)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — Xcode e CocoaPods](02-xcode-e-cocoapods.md) |
