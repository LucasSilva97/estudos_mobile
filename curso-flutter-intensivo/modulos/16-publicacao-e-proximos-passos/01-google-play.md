# Aula 1 — Google Play

> **Módulo:** 16 - Publicação e Próximos Passos · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- 🤖 Criar a **conta de desenvolvedor** da Google Play, entendendo a taxa única de **US$ 25** e a
  **verificação de identidade** exigida antes de qualquer publicação.
- 🤖 Navegar no **Play Console** e criar o registro do app **Foco** (`br.com.estudos.foco`).
- 🤖 Montar a **ficha da loja** completa com os tamanhos exatos de cada imagem.
- 🤖 Preencher **classificação de conteúdo**, **política de privacidade**, **Segurança dos Dados** e
  **público-alvo** de forma coerente com o que o app realmente faz.
- 🤖 Explicar as quatro **faixas de lançamento** (interno, fechado, aberto, produção) e escolher a
  certa para cada momento.
- 🤖 Explicar o **Play App Signing**: quem guarda qual chave, o que é a **chave de upload** e o que
  fazer se ela for perdida.
- 🤖 Subir o `app-release.aab` e confirmar objetivamente que o envio foi aceito.
- 🤖 Conhecer o **prazo típico de revisão** e os **motivos comuns de rejeição**.

## ✅ Pré-requisitos

- [Módulo 14 — Build Android](../14-build-android/README.md) concluído, com a **keystore de upload**
  criada em [06-keystore.md](../14-build-android/06-keystore.md) e a assinatura configurada em
  [07-assinatura-no-gradle.md](../14-build-android/07-assinatura-no-gradle.md).
- Um arquivo `build/app/outputs/bundle/release/app-release.aab` gerado conforme
  [08-gerando-apk-e-aab.md](../14-build-android/08-gerando-apk-e-aab.md).
- `applicationId = "br.com.estudos.foco"` já definido, conforme
  [02-identidade-do-app.md](../14-build-android/02-identidade-do-app.md).
- Uma conta Google, um documento de identidade válido e, se for pagar a taxa, um cartão de crédito
  internacional.

> 🪟 **Windows 11.** Esta aula inteira é executável na sua máquina agora. Publicar na Google Play
> **não exige Mac, não exige Linux e não exige Android Studio** — exige o `.aab` (que você já gerou
> no módulo 14) e um navegador.

---

## 📖 Conceito

### O que é a Google Play Console

A **Google Play Console** é o painel web onde você cadastra, configura, envia e acompanha apps na
loja Android (`https://play.google.com/console`). Ela é a contraparte do que você fez no terminal:
o `flutter build appbundle` produz o **artefato**; o Play Console recebe esse artefato, junta com
textos e imagens (a **ficha da loja**) e o distribui para os aparelhos.

### Conta de desenvolvedor: a taxa única de US$ 25

Para publicar qualquer app você precisa de uma **conta de desenvolvedor**. Ela custa
**US$ 25 (vinte e cinco dólares), taxa única** — você paga uma vez na vida, não é assinatura, e ela
vale para quantos apps você quiser publicar com aquela conta.

Existem dois tipos de conta, e a escolha é **definitiva** (não dá para trocar depois):

| Tipo | Quem usa | O que aparece na loja | Exigências extras |
|---|---|---|---|
| **Pessoal** (*personal*) | Você, pessoa física | Seu nome de desenvolvedor + um e-mail de contato público | Documento de identidade; endereço |
| **Organização** | Empresa registrada | Nome da empresa | Número **D-U-N-S** (um identificador internacional de empresas, gratuito mas demorado de obter) e site |

> 🔴 **Escolha "Pessoal" se você é uma pessoa estudando.** Trocar depois exige criar outra conta e
> pagar a taxa de novo.

### Verificação de identidade

Depois de pagar, a Google exige **verificação de identidade** antes de liberar a publicação:
**documento com foto** (RG, CNH ou passaporte) enviado pelo próprio Console, **endereço** (às vezes
com comprovante), **e-mail e telefone** confirmados e, para organizações, o **D-U-N-S**.

A verificação costuma levar de alguns minutos a alguns dias úteis. Enquanto ela não termina, você
consegue criar o app e preencher quase tudo, mas **não consegue publicar em produção**.

> ⚠️ **Regra importante para contas pessoais novas.** Contas pessoais criadas recentemente precisam
> rodar um **teste fechado** com um número mínimo de testadores (**12 testadores**) por
> **14 dias seguidos** antes de poderem solicitar acesso à produção. Não é burocracia inútil: é a
> forma da Google filtrar apps descartáveis. Planeje isso: se você quer o Foco na loja pública,
> comece o teste fechado **duas semanas antes**. O texto exato da exigência aparece no próprio Play
> Console, na página do teste fechado, e é lá que você confere o contador de dias.

### O que é a ficha da loja (*store listing*)

A **ficha da loja** é a página que o usuário vê antes de instalar. Ela é composta de texto e imagem,
e é o que mais influencia a decisão de instalar. Itens obrigatórios:

| Item | Limite / formato | Observação |
|---|---|---|
| **Nome do app** | até **30 caracteres** | "Foco: Organizador de Estudos" tem 28 — cabe |
| **Descrição curta** | até **80 caracteres** | Aparece no topo, antes do "Leia mais" |
| **Descrição completa** | até **4.000 caracteres** | Aceita quebras de linha; sem HTML |
| **Ícone do app** | PNG de **512 × 512 px**, 32 bits, com canal alfa | Não é o mesmo arquivo do ícone do app instalado |
| **Gráfico de destaque** (*feature graphic*) | **1024 × 500 px**, JPEG ou PNG de 24 bits **sem** canal alfa | Obrigatório; é o banner do topo |
| **Capturas de tela de celular** | mínimo **2**, máximo **8**; JPEG ou PNG 24 bits; cada lado entre **320 px** e **3840 px**; proporção 16:9 ou 9:16 | Sem estas, não publica |
| **Capturas de tablet 7"** e **tablet 10"** | até 8 cada | Exigidas se o app é oferecido para tablets/telas grandes |

> 💡 **O ícone de 512×512 da loja é diferente do ícone do app.** O ícone do app foi gerado pelo
> `flutter_launcher_icons` nas pastas `android/app/src/main/res/mipmap-*` (veja
> [14-build-android/03-icone.md](../14-build-android/03-icone.md)). O de 512×512 é um arquivo
> separado que você envia pelo navegador. Use a **mesma arte de origem** de 1024×1024 e exporte em
> 512×512 para manter coerência visual.

### Classificação de conteúdo

A **classificação de conteúdo** (*content rating*) é a faixa etária do app. Você não escolhe a
faixa: você responde a um **questionário do IARC** (*International Age Rating Coalition* — a
entidade que unifica classificações de vários países) sobre violência, sexo, linguagem, substâncias,
apostas, interação entre usuários e compartilhamento de localização. O sistema calcula a
classificação de cada região automaticamente.

> ⚠️ **Responder errado é motivo de suspensão.** Se o seu app permite que usuários troquem
> mensagens, você **precisa** declarar isso, mesmo que pareça inofensivo.

Para o **Foco**, que não tem chat, não tem compras, não tem conteúdo gerado por terceiros visível e
não coleta localização, a classificação resultante é **Livre / 3+**.

### Política de privacidade: obrigatória

**Todo app na Google Play precisa de uma URL de política de privacidade pública e acessível.** Não
importa se o app coleta dados ou não — a URL é obrigatória e é verificada.

A política precisa estar em uma **URL pública** (sem login, acessível a qualquer um), ser
**específica do seu app** (política genérica copiada da internet costuma ser reprovada), dizer
**quais dados** você coleta, **para quê**, **com quem compartilha** e **como o usuário pede
exclusão**, e bater com o que você declarou na seção **Segurança dos Dados**. Hospedagem gratuita:
uma página no **GitHub Pages** do seu próprio repositório. O importante é a URL ser estável.

### Segurança dos Dados (*Data safety*)

É um formulário onde você declara, **por tipo de dado**, se o app **coleta**, se **compartilha**, se
é **obrigatório ou opcional**, e **para que serve**. O que você declarar vira um quadro visível na
ficha da loja.

Preenchimento do **Foco**, item por item:

| Pergunta | Resposta do Foco | Por quê |
|---|---|---|
| O app coleta ou compartilha algum dos tipos de dados exigidos? | **Não** | Matérias, sessões e metas ficam no aparelho (sqflite + shared_preferences) |
| O app usa criptografia em trânsito? | **Sim** | A busca de trilhas usa `https://jsonplaceholder.typicode.com` |
| Você fornece forma de o usuário pedir exclusão dos dados? | **Sim** — os dados são locais e somem ao desinstalar | Explique isso na política |

> 🔴 **Coerência é o que a Google checa.** Se o seu `AndroidManifest.xml` declara
> `android.permission.CAMERA` e você marcou "não coleto fotos", é contradição. Abra
> `android/app/src/main/AndroidManifest.xml` e confira suas `<uses-permission>` **antes** de
> preencher este formulário.

### Público-alvo e conteúdo

Você declara as **faixas etárias** que o app tem como alvo. Se qualquer faixa abaixo de 13 anos for
marcada, o app entra no programa **Famílias**, com regras adicionais rígidas sobre anúncios, coleta
de dados e bibliotecas de terceiros. Para o **Foco**, marque de **13 anos em diante**: é um app de
estudo para adolescentes e adultos, e não há motivo para entrar nas regras de Famílias.

### As quatro faixas de lançamento

Uma **faixa** (*track*) é um canal de distribuição. O mesmo app pode ter versões diferentes em
faixas diferentes ao mesmo tempo.

| Faixa | Quem recebe | Velocidade | Para que serve |
|---|---|---|---|
| **Teste interno** | até **100** testadores que você lista por e-mail | Disponível em **minutos**, sem revisão completa | Verificar se o `.aab` instala e abre. É a primeira faixa a usar, sempre |
| **Teste fechado** | lista de e-mails ou Grupos do Google; pode ter várias listas | Horas a dias | Beta privado. É aqui que roda a exigência dos **12 testadores por 14 dias** das contas pessoais novas |
| **Teste aberto** | **qualquer pessoa** que tenha o link; aparece na busca com aviso de "teste" | Dias | Beta público, para coletar feedback em volume antes da produção |
| **Produção** | **todos** os usuários da Play Store | Revisão mais longa | O lançamento de verdade |

> 🧭 **O caminho recomendado para o Foco:** interno → fechado → produção. Pule o aberto se você não
> precisa de volume de testadores.

### Play App Signing: a parte que mais confunde

No Android, todo APK instalado precisa estar **assinado** com uma chave criptográfica. O Android usa
essa assinatura para garantir que uma atualização vem do **mesmo autor** do app já instalado. Se a
chave mudar, a atualização é recusada pelo aparelho.

Com o **Play App Signing** (obrigatório para todo app novo), existem **duas** chaves:

| Chave | Quem guarda | Para que serve | Se você perder |
|---|---|---|---|
| **Chave de assinatura do app** (*app signing key*) | **A Google**, em infraestrutura própria | Assina o APK que chega ao aparelho do usuário | Nada acontece — você não a tem. É exatamente o ponto |
| **Chave de upload** (*upload key*) | **Você**, no seu `upload-keystore.jks` | Prova para a Google que **você** é quem está enviando | Você pede um **reset da chave de upload** no suporte da Play. O app continua vivo |

Esse é o grande ganho: **antes** do Play App Signing, perder a chave significava perder o app para
sempre — não havia como publicar atualização e os usuários tinham que desinstalar e instalar outro
app do zero. Hoje, perder a chave de upload é um contratempo administrativo.

O fluxo completo:

```text
seu computador                  Google Play                     aparelho do usuário
app-release.aab  --upload-->  valida a chave de upload
assinado com a                gera os APKs por aparelho
CHAVE DE UPLOAD               assina com a CHAVE DE    -->    instala o APK assinado
                              ASSINATURA DO APP               pela Google
```

> 🔴 **Mesmo com o Play App Signing, a chave de upload é um segredo.** `upload-keystore.jks`,
> `android/key.properties` e as senhas **nunca** vão para o Git. Confirme que o seu `.gitignore`
> tem as linhas ensinadas em
> [00-git-e-terminal/05-desfazendo-erros-e-segredos.md](../00-git-e-terminal/05-desfazendo-erros-e-segredos.md).

### Por que AAB e não APK

O **Android App Bundle** (`.aab`) é obrigatório para apps novos. Ele não é instalável: é um pacote
com **todos** os recursos (todas as densidades de tela, arquiteturas de processador e idiomas), e a
Google gera dele um APK sob medida para cada aparelho — o usuário não baixa o ícone de xxxhdpi se o
celular dele é hdpi.

---

## 💡 Analogia

Pense na chave de upload como o **crachá de entrega** e na chave de assinatura do app como o
**carimbo oficial da editora**. Você leva o manuscrito até a portaria e o porteiro confere o seu
crachá (chave de upload): ele só quer saber se **você** tem autorização para entregar. Lá dentro, a
editora carimba o livro com o selo dela (chave de assinatura do app), e é esse selo que o leitor
reconhece na estante. Se você perder o crachá, a portaria emite outro. Se a editora perdesse o
carimbo, todos os livros da coleção ficariam órfãos — por isso o carimbo fica com quem tem cofre.

---

## 🧪 Exemplo mínimo

Antes de abrir o navegador, confirme no terminal que o artefato existe e que a versão declarada é a
que você espera.

**🪟 Windows (PowerShell)**

```powershell
Set-Location C:\src\cursos\foco
Select-String -Path .\pubspec.yaml -Pattern '^version:'
```

Resultado esperado:

```text
pubspec.yaml:19:version: 1.0.0+1
```

Agora o artefato:

```powershell
Get-Item .\build\app\outputs\bundle\release\app-release.aab | Select-Object Name, Length
```

Resultado esperado (o tamanho varia, mas deve estar na casa dos megabytes):

```text
Name              Length
----              ------
app-release.aab 24851230
```

**Como confirmar objetivamente que deu certo:** o comando devolve uma linha com `app-release.aab` e
um `Length` maior que zero. Se devolver `Cannot find path`, o build não foi feito — rode
`flutter build appbundle --release` e releia a saída.

---

## 📱 Aplicando no Flutter

O Play Console não sabe nada de Flutter: ele lê o que está **dentro** do `.aab`. Três campos do seu
projeto Flutter viram metadados que o Console valida no momento do upload:

| No projeto Flutter | Vira, no `.aab` | O Play Console usa para |
|---|---|---|
| `applicationId = "br.com.estudos.foco"` em `android/app/build.gradle.kts` | `package` do app | **Identificar o app.** Imutável depois da primeira publicação |
| `version: 1.0.0+1` no `pubspec.yaml` | `versionName` = `1.0.0` e `versionCode` = `1` | Recusar reenvio do mesmo `versionCode` |
| `signingConfigs` em `android/app/build.gradle.kts` | Assinatura do pacote | Validar a chave de upload |

> 🔴 **`applicationId` é para sempre.** Depois que `br.com.estudos.foco` for publicado, ele nunca
> mais muda. Mudar o `applicationId` cria um **app diferente** na loja, sem os usuários e sem as
> avaliações do anterior. Confira agora, antes de subir.

Confira os dois sem abrir o editor:

```powershell
Select-String -Path .\android\app\build.gradle.kts -Pattern 'applicationId|signingConfig'
```

Resultado esperado — o `applicationId` correto e a assinatura de release apontando para `"release"`:

```text
android\app\build.gradle.kts:31:        applicationId = "br.com.estudos.foco"
android\app\build.gradle.kts:45:            signingConfig = signingConfigs.getByName("release")
```

Se aparecer `signingConfigs.getByName("debug")` acompanhado do comentário
`// TODO: Add your own signing config for the release build.`, **pare**: esse é o bloco que o
`flutter create` gera por padrão no Flutter 3.47 e ele assina o release com a **chave de
depuração**. A Google Play recusa o upload com a mensagem de que o pacote foi assinado em modo de
depuração. Volte para
[14-build-android/07-assinatura-no-gradle.md](../14-build-android/07-assinatura-no-gradle.md).

---

## 💻 Código completo

Um script que roda a conferência inteira antes de você abrir o navegador. Ele falha alto e cedo,
em vez de deixar você descobrir o problema depois de 20 minutos preenchendo formulários.

> **Arquivo:** `foco/tool/preparar_release_play.ps1`
> **Como executar:** `powershell -ExecutionPolicy Bypass -File .\tool\preparar_release_play.ps1`

```powershell
# tool/preparar_release_play.ps1
# Conferência pré-envio para a Google Play do app Foco (br.com.estudos.foco).
# Rode a partir da raiz do projeto: C:\src\cursos\foco

$ErrorActionPreference = 'Stop'   # qualquer erro interrompe o script

Write-Host '=== 1/6 Conferindo a raiz do projeto ===' -ForegroundColor Cyan
if (-not (Test-Path .\pubspec.yaml)) {
    throw 'pubspec.yaml nao encontrado. Rode este script na raiz do projeto foco.'
}

Write-Host '=== 2/6 Conferindo o applicationId ===' -ForegroundColor Cyan
$gradle = Get-Content .\android\app\build.gradle.kts -Raw
if ($gradle -notmatch 'applicationId\s*=\s*"br\.com\.estudos\.foco"') {
    throw 'applicationId nao e br.com.estudos.foco. Corrija antes de publicar.'
}
Write-Host '    OK: br.com.estudos.foco'

Write-Host '=== 3/6 Conferindo a assinatura de release ===' -ForegroundColor Cyan
if ($gradle -match 'signingConfigs\.getByName\("debug"\)') {
    throw 'O buildType release ainda usa a chave de DEPURACAO. A Play vai recusar.'
}
if ($gradle -notmatch 'signingConfigs\.getByName\("release"\)') {
    throw 'Nao encontrei signingConfig de release em android/app/build.gradle.kts.'
}
Write-Host '    OK: assinado com a chave de upload'

Write-Host '=== 4/6 Conferindo que segredos estao ignorados pelo Git ===' -ForegroundColor Cyan
$ignore = Get-Content .\.gitignore -Raw
foreach ($padrao in @('key.properties', '*.jks', '*.keystore')) {
    if ($ignore -notmatch [regex]::Escape($padrao)) {
        throw "Falta '$padrao' no .gitignore. NAO envie segredo para o repositorio."
    }
}
Write-Host '    OK: key.properties, *.jks e *.keystore ignorados'

Write-Host '=== 5/6 Qualidade do codigo ===' -ForegroundColor Cyan
flutter analyze
flutter test

Write-Host '=== 6/6 Gerando o AAB de release ===' -ForegroundColor Cyan
flutter clean
flutter pub get
flutter build appbundle --release

$aab = '.\build\app\outputs\bundle\release\app-release.aab'
if (-not (Test-Path $aab)) { throw 'O AAB nao foi gerado. Releia a saida acima.' }

$tamanhoMb = [math]::Round((Get-Item $aab).Length / 1MB, 2)
$versao = (Select-String -Path .\pubspec.yaml -Pattern '^version:').Line

Write-Host ''
Write-Host '========================================' -ForegroundColor Green
Write-Host ' PRONTO PARA ENVIAR A GOOGLE PLAY' -ForegroundColor Green
Write-Host "  Arquivo : $((Get-Item $aab).FullName)"
Write-Host "  Tamanho : $tamanhoMb MB"
Write-Host "  $versao"
Write-Host '========================================' -ForegroundColor Green
```

**Resultado esperado no fim da execução:**

```text
========================================
 PRONTO PARA ENVIAR A GOOGLE PLAY
  Arquivo : C:\src\cursos\foco\build\app\outputs\bundle\release\app-release.aab
  Tamanho : 23,71 MB
  version: 1.0.0+1
========================================
```

**Como confirmar objetivamente:** o bloco verde aparece **e** o caminho impresso existe. Qualquer
`throw` interrompe o script com uma mensagem em vermelho dizendo exatamente o que corrigir.

---

## 🔍 Explicando o código

- `$ErrorActionPreference = 'Stop'` — por padrão o PowerShell continua depois de vários tipos de
  erro. Com `Stop`, o script para no primeiro problema. Em script de release isso é obrigatório:
  você **não** quer gerar um AAB depois de um teste falhar.
- `Test-Path .\pubspec.yaml` — devolve `$true` ou `$false`. Serve de prova de que você está na raiz
  do projeto; rodar na pasta errada é o erro nº 1 em scripts de build.
- `Get-Content ... -Raw` — lê o arquivo inteiro como **uma** string. Sem `-Raw`, o PowerShell
  devolve um array de linhas e o `-match` se comporta de outro jeito.
- `-notmatch 'applicationId\s*=\s*"br\.com\.estudos\.foco"'` — expressão regular. `\s*` aceita
  qualquer quantidade de espaços em volta do `=`; `\.` é um ponto literal (sem a barra invertida, o
  ponto significaria "qualquer caractere").
- `throw 'mensagem'` — lança um erro e encerra com código de saída diferente de zero, o que importa
  quando este script for chamado por um sistema de integração contínua
  ([Aula 4](04-ci-cd-introdutorio.md)).
- `[regex]::Escape($padrao)` — `*.jks` tem um `*`, que em expressão regular significa "repetição".
  `Escape` transforma o texto em literal.
- `flutter clean` antes do build — os geradores de ícone e splash mexem em recursos nativos e o
  Gradle pode reaproveitar cache antigo. Limpar evita subir um AAB com o ícone errado.
- `[math]::Round((Get-Item $aab).Length / 1MB, 2)` — `Length` vem em bytes; `1MB` é uma constante do
  PowerShell (1.048.576).

---

## 🤖🍎 Android × iOS

| Tema | 🤖 Google Play | 🍎 App Store |
|---|---|---|
| Custo | **US$ 25, taxa única** | **US$ 99 por ano**, renovação anual |
| Onde se envia | Navegador, Play Console | App Store Connect, mas o binário sobe do **Xcode no macOS** ou por ferramenta de linha de comando do macOS |
| Artefato | `.aab` (Android App Bundle) | `.ipa` (iOS App Package) |
| Assinatura | **Play App Signing**: a Google guarda a chave final | Certificados e *provisioning profiles* da Apple |
| Revisão | Automatizada + humana | **Humana**, sempre |
| Prazo típico | Horas a **até 7 dias** (pode passar disso em conta nova) | Em geral **menos de 24 h** |
| Dá para fazer do Windows? | **Sim, tudo** | **Não**: o envio do binário exige macOS |

> 🍎 **SÓ NO MAC.** O processo equivalente da Apple está na
> [Aula 2 — App Store Connect](02-app-store-connect.md). Você consegue criar a conta, criar o
> registro do app e preencher a ficha do Windows — mas **gerar e enviar o `.ipa` exige macOS com
> Xcode**. A Aula 4 mostra o caminho legítimo de usar um **runner macOS na nuvem** para isso.

---

## ⚠️ Erros comuns

**1. "You uploaded an APK or Android App Bundle that was signed in debug mode."**
Causa: o `buildTypes.release` ainda está com `signingConfig = signingConfigs.getByName("debug")` —
exatamente o que o `flutter create` do Flutter 3.47 gera, com o comentário
`// TODO: Add your own signing config for the release build.`.
Correção: configure a assinatura conforme
[14-build-android/07-assinatura-no-gradle.md](../14-build-android/07-assinatura-no-gradle.md),
rode `flutter clean` e gere o AAB de novo.

**2. "Version code 1 has already been used."**
Causa: você já enviou um `.aab` com `versionCode = 1`. O Play **nunca** aceita o mesmo número duas
vezes, nem em faixas diferentes, nem depois de apagar o rascunho.
Correção: suba o número de build no `pubspec.yaml` (`version: 1.0.0+2`) e gere de novo. Detalhes na
[Aula 3](03-versionamento-e-releases.md).

**3. Ficha da loja recusada por falta do gráfico de destaque.**
Causa: o *feature graphic* de **1024 × 500** é obrigatório e muita gente acha que é opcional.
Correção: exporte a imagem no tamanho exato, em JPEG ou PNG de 24 bits **sem canal alfa**. PNG com
transparência é recusado.

**4. Política de privacidade inacessível.**
Causa: URL atrás de login, URL quebrada, ou documento em nuvem com permissão restrita.
Correção: abra a URL em uma **janela anônima do navegador**. Se pedir login, não serve.

**5. Segurança dos Dados em contradição com as permissões.**
Causa: o `AndroidManifest.xml` declara uma permissão sensível (câmera, localização, contatos) e o
formulário diz que nada é coletado.
Correção: abra `android/app/src/main/AndroidManifest.xml`, liste as `<uses-permission>` e explique
cada uma. Remova as que o app não usa de fato — permissão sobrando é passivo, não é vantagem.

**6. `applicationId` ainda é `com.example.foco`.**
Causa: o `flutter create` gera `com.example.<nome_do_projeto>` e o passo de identidade foi pulado.
Correção: a Google **recusa** qualquer pacote começando com `com.example`. Ajuste conforme
[14-build-android/02-identidade-do-app.md](../14-build-android/02-identidade-do-app.md).

**7. Conta pessoal nova tentando publicar direto em produção.**
Causa: a exigência de **12 testadores por 14 dias** em teste fechado não foi cumprida.
Correção: crie o teste fechado, convide os testadores por e-mail e acompanhe o contador na própria
página do teste. Não há atalho. `targetSdk` desatualizado causa recusa parecida — o Flutter 3.47 já
usa `targetSdk = 36` via `flutter.targetSdkVersion`, então confirme com
`Select-String -Path .\android\app\build.gradle.kts -Pattern 'targetSdk'`.

---

## 🛠️ Exercício guiado

Objetivo: deixar tudo pronto para o envio, **sem pagar nada**, e depois decidir se quer pagar.

**Passo 1 — Rodar a conferência.**

```powershell
Set-Location C:\src\cursos\foco
powershell -ExecutionPolicy Bypass -File .\tool\preparar_release_play.ps1
```

Resultado esperado: o bloco verde `PRONTO PARA ENVIAR A GOOGLE PLAY` com o caminho do `.aab`.

**Passo 2 — Escrever a ficha da loja em um arquivo, antes do navegador.**

Crie `foco/tool/ficha-da-loja.txt` com este conteúdo (adapte os textos ao seu app):

```text
NOME (max 30):        Foco: Organizador de Estudos
DESCRICAO CURTA (80): Organize matérias, cronometre sessões e acompanhe sua meta semanal.
DESCRICAO COMPLETA (max 4000):
O Foco ajuda você a transformar tempo de estudo em progresso visível.
- Cadastre suas matérias e mantenha tudo organizado em um só lugar.
- Cronometre cada sessão e veja os minutos somarem na matéria certa.
- Defina uma meta semanal em minutos e acompanhe o quanto já cumpriu.
- Explore trilhas de estudo sugeridas e veja estatísticas por matéria.
Seus dados ficam no seu aparelho. O Foco não pede cadastro e não exige login.

POLITICA DE PRIVACIDADE: https://<seu-usuario>.github.io/foco/privacidade.html
IMAGENS: icone-512x512.png · destaque-1024x500.png · captura-celular-1..4.png
```

Confirme os limites de caracteres:

```powershell
$curta = 'Organize matérias, cronometre sessões de estudo e acompanhe sua meta semanal.'
$curta.Length
```

Resultado esperado: um número **menor ou igual a 80**.

**Passo 3 — Tirar as capturas de tela.** Use o emulador Android criado no módulo 14 (`flutter run`
com o emulador aberto) e capture a tela. Resultado esperado: imagens na proporção 16:9 ou 9:16 —
a Google valida a proporção no upload e recusa fora dela. Rodar `flutter run -d windows` serve
apenas para **ensaiar o enquadramento**; a loja Android não aceita captura de janela de desktop.

**Passo 4 — Preencher a folha de decisão.** Responda por escrito, em `tool/ficha-da-loja.txt`:
(1) conta pessoal ou organização, e por quê; (2) qual faixa no primeiro envio; (3) a URL da política
abre em janela anônima? (teste e escreva sim/não); (4) quais `<uses-permission>` existem no seu
`AndroidManifest.xml` e se cada uma se justifica.

**Passo 5 — Só se você decidir pagar os US$ 25:** acesse `https://play.google.com/console`, crie a
conta, faça a verificação de identidade, clique em **Criar app**, preencha a ficha com o texto que
você já escreveu, vá em **Teste → Teste interno → Criar nova versão** e envie o `.aab`.

**Como confirmar objetivamente que o envio funcionou:** na página da versão, o arquivo aparece
listado com **nome do pacote `br.com.estudos.foco`**, **código da versão `1`** e o aviso de que a
release está **em análise** ou **disponível para testadores internos**. O link de participação do
teste interno passa a existir e abre a página de aceite.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/16-publicacao-e-proximos-passos.md](../../exercicios/16-publicacao-e-proximos-passos.md)

---

## 🏆 Desafio opcional

Escreva a **política de privacidade do Foco** do zero, em português, em um arquivo
`privacidade.html`, e publique-a no GitHub Pages do seu próprio repositório.

Requisitos: diga que matérias, sessões e metas ficam **no aparelho** (SQLite local e preferências
locais); diga que o app faz requisições HTTPS a `https://jsonplaceholder.typicode.com` apenas para
buscar trilhas públicas e que **nenhum dado pessoal é enviado** nelas; explique como o usuário apaga
os dados (desinstalar ou limpar dados do app nas configurações do Android); informe um **e-mail de
contato**; date a política.

Critério de conclusão: a URL abre em janela anônima, sem login, e o texto descreve o que o **seu**
app faz — não um texto genérico.

---

## 📌 Resumo

- A conta custa **US$ 25, taxa única**, e exige **verificação de identidade** antes de publicar.
  Contas **pessoais novas** precisam de **12 testadores por 14 dias** em teste fechado antes de
  pedir acesso à produção.
- A **ficha da loja** exige nome (30), descrição curta (80), descrição completa (4.000), ícone
  **512×512**, gráfico de destaque **1024×500** e no mínimo **2 capturas** de celular.
- **Classificação de conteúdo** vem de um questionário do IARC; responder errado suspende o app.
  **Política de privacidade é obrigatória para todo app**, em URL pública, e precisa ser coerente
  com a seção **Segurança dos Dados**.
- Faixas: **interno** (100 testadores, minutos) → **fechado** (beta privado) → **aberto** (beta
  público) → **produção**.
- **Play App Signing**: a Google guarda a *chave de assinatura do app*; você guarda a *chave de
  upload*. Perder a de upload é recuperável; por isso ela existe.
- O artefato é o `.aab` em `build/app/outputs/bundle/release/app-release.aab`, assinado com a sua
  chave de upload — **nunca** com a de depuração. Revisão: de horas a **até 7 dias**.

---

## ☑️ Checklist de domínio

- [ ] Explico a taxa de US$ 25 (única, não anual) e a diferença entre conta pessoal e de
      organização, incluindo por que a escolha é definitiva.
- [ ] Listo de cor os seis itens obrigatórios da ficha da loja com seus tamanhos.
- [ ] Explico o que é o questionário do IARC e por que responder errado é grave.
- [ ] Testo minha URL de política de privacidade em janela anônima antes de enviar.
- [ ] Preencho Segurança dos Dados olhando para as `<uses-permission>` do meu manifesto.
- [ ] Descrevo as quatro faixas e escolho a certa para um primeiro envio.
- [ ] Explico as duas chaves do Play App Signing e o que acontece ao perder cada uma.
- [ ] Rodo `tool/preparar_release_play.ps1` e entendo cada uma das seis etapas.
- [ ] Reconheço a mensagem "signed in debug mode" e sei exatamente qual arquivo corrigir.
- [ ] Sei por que o `applicationId` `br.com.estudos.foco` é imutável depois de publicado.

---

## 📚 Referências oficiais

- [Registrar-se como desenvolvedor do Google Play](https://support.google.com/googleplay/android-developer/answer/6112435)
- [Criar e configurar o app no Play Console](https://support.google.com/googleplay/android-developer/answer/9859152)
- [Recursos gráficos da ficha da loja](https://support.google.com/googleplay/android-developer/answer/9866151)
- [Classificação de conteúdo (IARC)](https://support.google.com/googleplay/android-developer/answer/9859655)
- [Seção Segurança dos Dados](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Usar o Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
- [Preparar e lançar uma versão](https://support.google.com/googleplay/android-developer/answer/9859348)
- [Flutter — Build and release an Android app](https://docs.flutter.dev/deployment/android)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [App Store Connect](02-app-store-connect.md) |
