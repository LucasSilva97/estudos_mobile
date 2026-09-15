# Aula 6 — Keystore

> **Módulo:** 14 - Build e Distribuição Android · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é **assinatura digital** de APK e por que ela existe.
- Criar um keystore com **`keytool`**, entendendo cada parâmetro.
- Distinguir a chave de **debug** da chave de **upload** e da de **assinatura do app**.
- Entender o **Play App Signing** e por que ele muda o risco de perder a chave.
- Guardar a chave e as senhas com **backup em três lugares**.
- Saber exatamente **o que nunca vai para o Git**.
- Inspecionar um keystore e um APK assinado para conferir a assinatura.

## ✅ Pré-requisitos

- [Aula 5 — Permissões Android](05-permissoes-android.md) — o projeto `foco` com o manifest pronto.
- [Aula 2 — Identidade do app](02-identidade-do-app.md) — `applicationId` `br.com.estudos.foco`.
- [Módulo 13, aula 6 — Segurança mobile](../13-desempenho-e-seguranca/06-seguranca-mobile.md) — o
  `.gitignore` de segredos.
- Um JDK instalado (vem com o Android Studio). Confira com `java -version`.

---

## ⚠️ Antes de começar

Esta aula tem **a única coisa verdadeiramente irreversível do curso**:

> **Perder a chave de assinatura significa nunca mais poder atualizar o app.**
>
> Não há suporte, não há recuperação, não há exceção. O Google não pode ajudar. A única saída é
> publicar um app **novo**, com outro `applicationId`, e pedir a todos os usuários que desinstalem o
> antigo e instalem o novo — perdendo avaliações, instalações e histórico.

O **Play App Signing** (adiante) reduz muito esse risco, e é por isso que o curso recomenda usá-lo.
Mas a chave de **upload** ainda é sua, e ainda precisa de backup.

---

## 📖 Conceito

### Por que assinar

Todo APK instalado num Android é **assinado**. A assinatura responde a uma pergunta:

> *Esta atualização vem de quem publicou a versão anterior?*

```text
App v1.0  assinado com a chave A  → instalado
App v1.1  assinado com a chave A  → ✅ atualiza
App v1.1  assinado com a chave B  → ❌ recusado pelo sistema
```

```text
INSTALL_FAILED_UPDATE_INCOMPATIBLE:
Existing package br.com.estudos.foco signatures do not match
newer version
```

> 📌 **É isso que impede alguém de publicar uma "atualização" do seu app.** Sem chave igual, o
> sistema recusa — mesmo que o `applicationId` bata. A assinatura é a identidade real do app; o
> `applicationId` é só o nome.

### As três chaves

Esta é a distinção que confunde quase todo mundo na primeira vez:

| Chave | Quem tem | Para quê |
|---|---|---|
| **Debug** | Gerada sozinha, no seu PC | `flutter run`. Nunca publique com ela. |
| **Upload** | **Você** | Assinar o que você envia à Play Console |
| **Assinatura do app** | **O Google** (com Play App Signing) | Assinar o que chega ao usuário |

```text
Sem Play App Signing:
  você → [chave de assinatura] → Play → usuário
         ⚠️ perdeu = fim do app

Com Play App Signing:
  você → [chave de UPLOAD] → Play → [chave de assinatura, do Google] → usuário
         ✅ perdeu = o Google reseta a chave de upload para você
```

> 💡 **Com Play App Signing, perder a chave de upload deixa de ser fatal.** Você abre um chamado,
> comprova a identidade, e o Google autoriza uma chave de upload nova. A chave que realmente
> importa — a de assinatura do app — fica guardada na infraestrutura do Google, com o mesmo cuidado
> das chaves deles.

| | Play App Signing | Chave só sua |
|---|---|---|
| Perder a chave | ✅ Recuperável | ❌ **Fatal** |
| Obrigatório | ✅ Para apps novos (AAB) | — |
| Confiar no Google | Necessário | Não |
| Instalação menor | ✅ (otimização por aparelho) | ❌ |

> ⚠️ **Para apps novos publicados como AAB, o Play App Signing é obrigatório.** Não é uma escolha —
> é o funcionamento padrão da Play Console desde 2021.

### A chave de debug

Ela já existe:

```text
Windows: C:\Users\<você>\.android\debug.keystore
Senha:   android      (pública, igual para todo mundo)
Alias:   androiddebugkey
```

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android
```

> ⚠️ **A chave de debug é pública e igual em todas as máquinas do mundo.** É por isso que um APK de
> debug nunca pode ser publicado: qualquer pessoa consegue assinar uma "atualização" dele. A Play
> Console recusa uploads assinados com ela.

### Criando a sua chave de upload

```powershell
keytool -genkey -v `
  -keystore "$env:USERPROFILE\chaves\foco-upload.jks" `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias foco
```

| Parâmetro | O que é | Cuidado |
|---|---|---|
| `-keystore` | O arquivo | ⚠️ **Fora** da pasta do projeto |
| `-storetype JKS` | Formato | `PKCS12` também serve |
| `-keyalg RSA` | Algoritmo | RSA é o esperado |
| `-keysize 2048` | Tamanho | 2048 é o mínimo aceito |
| `-validity 10000` | Dias (~27 anos) | ⚠️ **Expirou = não atualiza mais** |
| `-alias` | Nome da chave dentro do arquivo | Anote. É preciso depois. |

> ⚠️ **Crie o keystore FORA da pasta do projeto.** Dentro, um `git add .` distraído pode versioná-lo
> — e um keystore no histórico do Git é um keystore comprometido, ainda que o repositório seja
> privado hoje.

> ⚠️ **`-validity 10000` não é exagero.** O Google exige validade até pelo menos 2033, e um
> certificado expirado impede novas atualizações. Use 10000 (ou mais) e esqueça o assunto.

O `keytool` vai pedir:

```text
Enter keystore password:          ← senha do ARQUIVO
Re-enter new password:
What is your first and last name?     [Unknown]:  Seu Nome
What is the name of your organizational unit?     [Unknown]:  Estudos
What is the name of your organization?            [Unknown]:  Pessoal
What is the name of your City or Locality?        [Unknown]:  Sua Cidade
What is the name of your State or Province?       [Unknown]:  SP
What is the two-letter country code for this unit? [Unknown]:  BR
Is CN=Seu Nome, OU=Estudos, ... correct?  [no]:  yes
Enter key password for <foco>
        (RETURN if same as keystore password):    ← senha da CHAVE
```

> 💡 **Há duas senhas**: a do arquivo (*store*) e a da chave (*key*). Podem ser iguais — aperte
> Enter na segunda. Se forem diferentes, anote **as duas**: o Gradle precisa das duas na aula 7.

> 📌 Os dados de nome e organização vão para o certificado e **não podem ser alterados depois**.
> Ninguém os vê no dia a dia, mas preencha com informação real: eles aparecem se alguém inspecionar
> o certificado.

### O backup

| Onde | Guarde | Veredito |
|---|---|---|
| Gerenciador de senhas | Senhas + o arquivo anexado | ✅ **O melhor** |
| Pen drive guardado | O `.jks` | ✅ |
| Nuvem pessoal cifrada | O `.jks` | ✅ |
| Só no PC | — | ❌ HD queima |
| No Git do projeto | — | ❌ **Nunca** |
| E-mail para si mesmo | — | ⚠️ Melhor que nada |

> 📌 **Três lugares, dois tipos de mídia, um fora de casa.** É a regra 3-2-1 de backup, e ela existe
> porque cada um dos três falha de um jeito diferente: o HD queima, a nuvem perde o acesso, o pen
> drive some na mudança.

E anote junto, no mesmo lugar:

```text
Arquivo:      foco-upload.jks
Alias:        foco
Senha store:  ********
Senha key:    ********
Criado em:    2026-09-14
Validade:     10000 dias (até ~2053)
SHA-1:        AA:BB:CC:...
App:          br.com.estudos.foco
```

> ⚠️ **O keystore sem a senha é tão inútil quanto não ter o keystore.** Guardar o arquivo e
> esquecer a senha é o modo mais comum de perder o acesso — e é evitável.

### O que nunca vai para o Git

```gitignore
# ── Assinatura: NUNCA versionar ───────────────────────────────
*.jks
*.keystore
android/key.properties
```

> ⚠️ **`git rm --cached` não basta.** O arquivo continua no histórico e em todo clone. Se um
> keystore foi commitado: gere um **novo**, troque a chave de upload na Play Console, e só então
> limpe o histórico. Como na aula 6 do módulo 13 — **a correção é rotacionar, não apagar o commit**.

### Inspecionar

```powershell
# O que há dentro do keystore
keytool -list -v -keystore "$env:USERPROFILE\chaves\foco-upload.jks"

# Só as impressões digitais
keytool -list -v -keystore "$env:USERPROFILE\chaves\foco-upload.jks" -alias foco

# Com que chave este APK foi assinado?
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\35.0.0\apksigner.bat" verify --print-certs app-release.apk
```

O **SHA-1** e o **SHA-256** são a identidade da chave. Você precisa deles para:

| Para quê | Qual |
|---|---|
| Firebase | SHA-1 e SHA-256 |
| Google Sign-In | SHA-1 |
| Google Maps | SHA-1 |
| Links de app (App Links) | SHA-256 |

> ⚠️ **Com Play App Signing, o SHA-1 que o Firebase precisa é o da chave do GOOGLE**, não o da sua
> chave de upload. Ele está na Play Console → Configuração → Integridade do app. Registrar o SHA-1
> errado faz o login com Google funcionar no seu aparelho e **falhar para todos os usuários da
> loja** — um dos bugs mais frustrantes de diagnosticar, porque funciona perfeitamente em teste.

---

## 💡 Analogia

Pense no **carimbo de um cartório**.

- **A assinatura do APK** é o carimbo no documento. Qualquer um pode escrever um documento dizendo
  ser do Cartório Silva; só o Cartório Silva tem o carimbo. Quando chega um documento novo, você
  confere: **é o mesmo carimbo de antes?** Se não, é falso.
- **A chave de debug** é o carimbo de brinquedo que vem na caixa de papelaria — **todo mundo tem
  igual**. Serve para praticar em casa. Nenhum cartório aceita.
- **A chave de upload** é o seu carimbo pessoal: você usa para mandar documentos ao cartório
  central.
- **A chave de assinatura do app** é o carimbo do cartório central — o que vai no documento final
  que chega ao público. **Com Play App Signing, esse carimbo fica no cofre do cartório**, não na sua
  gaveta.
- **É por isso que a recomendação mudou.** Antigamente cada um guardava o próprio carimbo oficial em
  casa, e quem perdia num incêndio perdia a profissão. Hoje o cartório guarda o carimbo oficial, e
  se você perder o **seu** carimbo de envio, vai lá, se identifica, e recebe outro.
- **O backup em três lugares** é a razão de os cartórios existirem em duplicidade: a casa pega
  fogo, o escritório alaga, a filial continua de pé.
- **E o carimbo sem a senha** é o cofre sem a combinação. Você tem o objeto, e ele não abre.

---

## 🧪 Exemplo mínimo

O ciclo completo, do zero.

**Passo 1 — uma pasta fora do projeto:**

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\chaves" | Out-Null
```

**Passo 2 — criar a chave:**

```powershell
keytool -genkey -v `
  -keystore "$env:USERPROFILE\chaves\foco-upload.jks" `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias foco
```

**Passo 3 — conferir:**

```powershell
keytool -list -v -keystore "$env:USERPROFILE\chaves\foco-upload.jks" -alias foco
```

```text
Alias name: foco
Creation date: 14 de set. de 2026
Entry type: PrivateKeyEntry
Owner: CN=Seu Nome, OU=Estudos, O=Pessoal, L=Sua Cidade, ST=SP, C=BR
Valid from: Mon Sep 14 19:33:00 BRT 2026 until: Sat Jan 30 19:33:00 BRT 2054
Certificate fingerprints:
     SHA1:   AA:BB:CC:DD:EE:FF:...
     SHA256: 11:22:33:44:55:66:...
Signature algorithm name: SHA384withRSA
```

**Passo 4 — anote no gerenciador de senhas**: arquivo, alias, as duas senhas, o SHA-1 e o SHA-256.

**Passo 5 — copie o `.jks` para um segundo e um terceiro lugar.**

**Passo 6 — confirme que o Git o ignora:**

```powershell
# Deve devolver VAZIO. Se listar algo, o .gitignore está errado.
git status --porcelain --ignored | Select-String "jks|keystore|key.properties"
git check-ignore -v "$env:USERPROFILE\chaves\foco-upload.jks"
```

> 📌 **Faça o passo 6 agora, não depois.** Descobrir que o keystore foi commitado três meses atrás
> significa rotacionar a chave — trabalho que este comando de cinco segundos evita.

---

## 📱 Aplicando no Flutter

Um script que cria, confere e faz backup, com as validações que evitam os erros desta aula.

---

## 💻 Código completo

> **Arquivo:** `tool/criar-keystore.ps1` (novo)
> **Como executar:** `powershell -ExecutionPolicy Bypass -File tool/criar-keystore.ps1`

```powershell
# Cria a chave de upload do app, com as validações que evitam
# os erros irreversíveis desta aula.
#
# ⚠️ Rode UMA vez por app. Criar uma segunda chave não substitui
# a primeira: o app publicado continua exigindo a original.

param(
    [string]$Nome  = 'foco',
    [string]$Alias = 'foco',
    [int]$Validade = 10000
)

$ErrorActionPreference = 'Stop'

# ── 1. Fora do projeto ──────────────────────────────────────────
# Dentro da pasta do projeto, um `git add .` distraído versiona
# o keystore — e keystore no histórico é keystore comprometido.
$pasta = Join-Path $env:USERPROFILE 'chaves'
$arquivo = Join-Path $pasta "$Nome-upload.jks"

New-Item -ItemType Directory -Force -Path $pasta | Out-Null

# ── 2. Nunca sobrescrever ───────────────────────────────────────
# ⭐ A verificação mais importante do script. Sobrescrever um
# keystore em uso significa perder o acesso ao app publicado,
# sem aviso e sem volta.
if (Test-Path $arquivo) {
    Write-Host "⚠️  JÁ EXISTE: $arquivo" -ForegroundColor Red
    Write-Host ''
    Write-Host 'Se este app já foi publicado, esta é A chave dele.' -ForegroundColor Red
    Write-Host 'Sobrescrever = perder o acesso ao app, para sempre.' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Para ver o que há dentro:' -ForegroundColor Yellow
    Write-Host "  keytool -list -v -keystore `"$arquivo`"" -ForegroundColor Yellow
    exit 1
}

# ── 3. O keytool existe? ────────────────────────────────────────
try {
    $null = Get-Command keytool -ErrorAction Stop
} catch {
    Write-Host 'keytool não encontrado no PATH.' -ForegroundColor Red
    Write-Host 'Ele vem com o JDK. Procure em:' -ForegroundColor Yellow
    Write-Host '  C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
    Write-Host 'Ou rode: flutter doctor -v   (mostra o JDK em uso)'
    exit 1
}

# ── 4. Criar ────────────────────────────────────────────────────
Write-Host "Criando $arquivo" -ForegroundColor Cyan
Write-Host ''
Write-Host 'Você vai digitar DUAS senhas:' -ForegroundColor Yellow
Write-Host '  1. senha do ARQUIVO (store)'
Write-Host '  2. senha da CHAVE (key) — Enter usa a mesma'
Write-Host ''
Write-Host 'ANOTE AS DUAS. Keystore sem senha é keystore perdido.' -ForegroundColor Yellow
Write-Host ''

keytool -genkey -v `
    -keystore $arquivo `
    -storetype JKS `
    -keyalg RSA `
    -keysize 2048 `
    -validity $Validade `
    -alias $Alias

if ($LASTEXITCODE -ne 0) { throw 'keytool falhou' }

# ── 5. Conferir e extrair as impressões digitais ────────────────
Write-Host "`n─── Conferindo ───" -ForegroundColor Cyan
$info = keytool -list -v -keystore $arquivo -alias $Alias 2>&1 | Out-String

$sha1   = ([regex]'SHA1:\s+([A-F0-9:]+)').Match($info).Groups[1].Value
$sha256 = ([regex]'SHA256:\s+([A-F0-9:]+)').Match($info).Groups[1].Value
$ateQuando = ([regex]'until: (.+)').Match($info).Groups[1].Value.Trim()

# ── 6. A ficha para guardar junto com o arquivo ─────────────────
# Keystore sem estes dados é quase inútil: sem o alias e as senhas,
# o Gradle não consegue usá-lo.
$ficha = @"
═══════════════════════════════════════════════════════
 CHAVE DE UPLOAD — $Nome
═══════════════════════════════════════════════════════
 Arquivo:   $arquivo
 Alias:     $Alias
 Criado:    $(Get-Date -Format 'yyyy-MM-dd HH:mm')
 Validade:  $Validade dias (até $ateQuando)

 SHA-1:     $sha1
 SHA-256:   $sha256

 Senha store: (ANOTE NO GERENCIADOR DE SENHAS)
 Senha key:   (ANOTE NO GERENCIADOR DE SENHAS)

───────────────────────────────────────────────────────
 ⚠️  Com Play App Signing, o SHA-1 que o Firebase e o
     Google Sign-In precisam é o do GOOGLE, não este.
     Ele está em: Play Console → Configuração →
     Integridade do app → Assinatura de apps.

     Registrar este SHA-1 por engano faz o login
     funcionar no seu aparelho e FALHAR na loja.
───────────────────────────────────────────────────────
 GUARDE EM TRÊS LUGARES:
   1. gerenciador de senhas (com o arquivo anexado)
   2. pen drive ou HD externo
   3. nuvem pessoal cifrada

 PERDER = nunca mais atualizar o app.
═══════════════════════════════════════════════════════
"@

$fichaArquivo = Join-Path $pasta "$Nome-FICHA.txt"
$ficha | Out-File $fichaArquivo -Encoding utf8

Write-Host $ficha -ForegroundColor Green
Write-Host "Ficha salva em: $fichaArquivo" -ForegroundColor Cyan

# ── 7. O Git ignora? ────────────────────────────────────────────
Write-Host "`n─── Conferindo o .gitignore ───" -ForegroundColor Cyan
$gitignore = Get-Content .gitignore -Raw -ErrorAction SilentlyContinue

foreach ($padrao in @('*.jks', '*.keystore', 'key.properties')) {
    if ($gitignore -and $gitignore.Contains($padrao)) {
        Write-Host "  ✅ $padrao" -ForegroundColor Green
    } else {
        Write-Host "  ❌ FALTA no .gitignore: $padrao" -ForegroundColor Red
    }
}

Write-Host "`nPróximo passo: Aula 7 — configurar a assinatura no Gradle." -ForegroundColor Cyan
```

E o verificador, para rodar antes de cada release:

> **Arquivo:** `tool/conferir-assinatura.ps1` (novo)

```powershell
# Confere com que chave um artefato foi assinado.
#
# Rode ANTES de enviar à Play Console: um APK assinado com a
# chave de debug é recusado, e descobrir isso depois do upload
# é perda de tempo.

param(
    [string]$Artefato = 'build/app/outputs/flutter-apk/app-release.apk'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Artefato)) {
    throw "Não achei $Artefato. Rode `flutter build apk --release` antes."
}

# apksigner vem no build-tools do SDK; a versão varia.
$sdk = "$env:LOCALAPPDATA\Android\Sdk\build-tools"
$apksigner = Get-ChildItem $sdk -Filter 'apksigner.bat' -Recurse -ErrorAction SilentlyContinue |
    Sort-Object FullName -Descending | Select-Object -First 1

if (-not $apksigner) {
    Write-Host 'apksigner não encontrado. Instale o Android SDK Build-Tools.' -ForegroundColor Red
    exit 1
}

Write-Host "Conferindo $Artefato`n" -ForegroundColor Cyan
$saida = & $apksigner.FullName verify --print-certs $Artefato 2>&1 | Out-String
Write-Host $saida

# ⭐ A verificação que importa: o certificado de debug tem
# CN=Android Debug. Um APK com ele é recusado pela Play Console.
if ($saida -match 'CN=Android Debug') {
    Write-Host '❌ ASSINADO COM A CHAVE DE DEBUG!' -ForegroundColor Red
    Write-Host '   A Play Console vai recusar este arquivo.' -ForegroundColor Red
    Write-Host '   Confira a configuração de signingConfig (Aula 7).' -ForegroundColor Yellow
    exit 1
}

if ($saida -match 'DOES NOT VERIFY') {
    Write-Host '❌ Assinatura inválida.' -ForegroundColor Red
    exit 1
}

Write-Host '✅ Assinado com uma chave de release.' -ForegroundColor Green
```

E o `.gitignore`:

> **Arquivo:** `.gitignore` (acrescentar)

```gitignore
# ── Assinatura Android: NUNCA versionar ───────────────────────
*.jks
*.keystore
*.p12
android/key.properties
android/app/upload-keystore.jks

# ⚠️ Se algum destes JÁ foi commitado, `git rm --cached` não
# resolve: o arquivo continua no histórico e em todo clone.
# A correção é gerar uma chave NOVA e trocá-la na Play Console.
```

```powershell
.\tool\criar-keystore.ps1
.\tool\conferir-assinatura.ps1
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Keystore em `$env:USERPROFILE\chaves` | **Fora do projeto**: um `git add .` distraído versionaria. |
| **Recusar sobrescrever** | A verificação mais importante: sobrescrever = perder o app publicado. |
| Checar o `keytool` no PATH | Ele vem com o JDK; o erro "não encontrado" confunde quem nunca usou. |
| `-validity 10000` | O Google exige validade até 2033+; expirou = não atualiza mais. |
| Aviso das **duas** senhas | Store e key são diferentes; esquecer uma inutiliza o arquivo. |
| Extrair SHA-1 e SHA-256 | São necessários para Firebase, Google Sign-In, Maps e App Links. |
| A **ficha** salva junto | Keystore sem alias e senha é quase inútil para o Gradle. |
| Aviso sobre o SHA-1 do Google | Registrar o errado faz o login funcionar no seu aparelho e **falhar na loja**. |
| Conferir o `.gitignore` no fim | Barato agora; caro depois de três meses de commits. |
| `conferir-assinatura.ps1` | Um APK de debug é recusado no upload; melhor descobrir antes. |
| Detectar `CN=Android Debug` | É a marca da chave de debug — pública e igual no mundo todo. |
| `exit 1` nos erros | Permite usar como portão no CI. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| O que assina | Keystore (`.jks`) | Certificado + provisioning profile |
| Quem emite | **Você** | **A Apple** |
| Onde fica | Arquivo no seu PC | Keychain do Mac |
| Validade | Você escolhe (10000 dias) | 1 ano (renovação obrigatória) |
| Perder | ⚠️ Fatal sem Play App Signing | ✅ Revoga e emite outro |
| Custo | Grátis | US$ 99/ano para publicar |
| Guardado pela plataforma | ✅ Play App Signing | ✅ No portal da Apple |

> 💡 **O iOS é mais burocrático e menos arriscado.** Cada certificado vale um ano e precisa ser
> renovado — chato —, mas perder um não é fatal: você revoga no portal da Apple e emite outro. No
> Android, sem Play App Signing, a perda é definitiva. **A burocracia da Apple é, em parte, o preço
> dessa rede de proteção.** Módulo 15 trata disso em detalhe.

🪟 **No Windows**, esta aula funciona por completo: `keytool` e `apksigner` são ferramentas Java e
do Android SDK, e rodam normalmente.

---

## ⚠️ Erros comuns

### 1. Keystore dentro da pasta do projeto

Um `git add .` versiona.

**Correção:** fora do projeto, e no `.gitignore` por garantia.

### 2. Commitar o keystore

Fica no histórico e em todo clone.

**Correção:** gere uma chave nova e troque na Play Console. Apagar o commit não resolve.

### 3. Sem backup

HD queima, app morre.

**Correção:** três lugares.

### 4. Guardar o arquivo e esquecer a senha

Tão ruim quanto não ter o arquivo.

**Correção:** gerenciador de senhas, junto.

### 5. Publicar assinado com a chave de debug

Recusado no upload.

**Correção:** `conferir-assinatura.ps1` antes.

### 6. `-validity` pequeno

Expirou, não atualiza mais.

**Correção:** 10000 dias.

### 7. Criar uma segunda chave achando que substitui

O app publicado continua exigindo a original.

**Correção:** use Play App Signing; se perdeu, abra chamado.

### 8. Registrar o SHA-1 errado no Firebase

Funciona no seu aparelho, falha para os usuários da loja.

**Correção:** com Play App Signing, use o SHA-1 **do Google**.

### 9. Esquecer o alias

O Gradle não acha a chave.

**Correção:** anote na ficha.

### 10. Senhas diferentes e anotar só uma

**Correção:** anote as duas.

### 11. Achar que `git rm --cached` limpa

**Correção:** rotacione a chave.

### 12. Não usar Play App Signing

Assume um risco fatal sem necessidade.

**Correção:** aceite na Play Console.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `keytool -list -v` na sua chave de **debug**. Qual é o `Owner`?

**Passo 2.** Compare com a de um colega, se possível. São iguais? Por quê isso importa?

**Passo 3.** Crie a pasta `chaves` fora do projeto.

**Passo 4.** Rode `tool/criar-keystore.ps1`. Anote as duas senhas **antes** de continuar.

**Passo 5.** Rode o script de novo. Ele recusa? Leia a mensagem.

**Passo 6.** Liste o conteúdo do keystore. Anote SHA-1 e SHA-256.

**Passo 7.** Copie o `.jks` para dois outros lugares.

**Passo 8.** Rode `git check-ignore -v` no caminho do keystore.

**Passo 9.** Compile um APK de debug e rode `conferir-assinatura.ps1`. Ele acusa?

**Passo 10.** Escreva, com suas palavras, o que aconteceria se você perdesse o arquivo **com** e
**sem** Play App Signing.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-android.md](../../exercicios/14-build-android.md)

Faça os de **Aplicação** (criar e documentar a chave) e o de **Reflexão** (plano de recuperação de
desastre do seu app).

---

## 🏆 Desafio opcional

Escreva o **plano de continuidade** do seu app — o documento que outra pessoa leria se você não
estivesse disponível.

Requisitos:

- Onde está a chave, em cada um dos três lugares (sem as senhas no documento).
- Quem tem acesso às senhas, e como.
- O procedimento para gerar uma chave de upload nova via Play Console.
- O que fazer se a chave **for comprometida** (vazou) — que é diferente de perdida.
- Como validar que o build está assinado corretamente.
- Um teste do plano: peça a alguém para seguir o documento e gerar um build assinado.

Depois responda: por que "chave perdida" e "chave vazada" pedem respostas **opostas** — uma exige
recuperar o acesso, a outra exige invalidá-lo? E qual das duas é mais urgente?

---

## 📌 Resumo

- Todo APK é **assinado**; a assinatura prova que a atualização vem de quem publicou a anterior.
- Chave diferente = **`INSTALL_FAILED_UPDATE_INCOMPATIBLE`**.
- **Três chaves**: debug (pública, nunca publique), **upload** (sua), **assinatura do app** (do
  Google).
- **Play App Signing é obrigatório para apps novos em AAB** — e torna a perda da chave de upload
  recuperável.
- Sem Play App Signing, **perder a chave = nunca mais atualizar o app**. Sem exceção.
- Crie o keystore **fora da pasta do projeto**, com `-validity 10000`.
- São **duas senhas**: do arquivo e da chave. Anote as duas.
- Backup em **três lugares**, com alias e senhas junto.
- **`*.jks`, `*.keystore` e `key.properties` nunca vão para o Git.**
- Commitou? **Rotacione a chave** — apagar o commit não desfaz nada.
- **SHA-1 e SHA-256** são necessários para Firebase, Google Sign-In, Maps e App Links.
- ⚠️ Com Play App Signing, o SHA-1 desses serviços é o **do Google**, não o seu.
- **Confira a assinatura antes de enviar**: um APK de debug é recusado.
- 🍎 O iOS é mais burocrático e menos arriscado: perder um certificado não é fatal.

---

## ☑️ Checklist de domínio

- [ ] Explico por que APKs são assinados.
- [ ] Distingo chave de debug, de upload e de assinatura do app.
- [ ] Entendo o que o Play App Signing muda no risco.
- [ ] Criei meu keystore fora da pasta do projeto.
- [ ] Usei `-validity 10000`.
- [ ] Anotei alias e as duas senhas no gerenciador de senhas.
- [ ] Tenho backup em três lugares.
- [ ] Meu `.gitignore` cobre `*.jks` e `key.properties`.
- [ ] Sei extrair SHA-1 e SHA-256.
- [ ] Sei qual SHA-1 registrar no Firebase com Play App Signing.
- [ ] Confiro a assinatura antes de enviar à loja.
- [ ] Sei o que fazer se a chave for perdida — e se for vazada.

---

## 📚 Referências oficiais

- [Sign your app — developer.android.com](https://developer.android.com/studio/publish/app-signing)
- [Use Play App Signing — Play Console Help](https://support.google.com/googleplay/android-developer/answer/9842756)
- [Build and release an Android app — docs.flutter.dev](https://docs.flutter.dev/deployment/android)
- [keytool — docs.oracle.com](https://docs.oracle.com/en/java/javase/17/docs/specs/man/keytool.html)
- [apksigner — developer.android.com](https://developer.android.com/tools/apksigner)
- [Authenticating your client — Firebase](https://developers.google.com/android/guides/client-auth)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Permissões Android](05-permissoes-android.md) | [README](README.md) | [Assinatura no Gradle](07-assinatura-no-gradle.md) |
