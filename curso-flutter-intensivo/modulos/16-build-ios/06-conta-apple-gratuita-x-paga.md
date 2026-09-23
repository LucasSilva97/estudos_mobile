# Aula 6 — Conta Apple gratuita × paga

> **Módulo:** 16 - Build e Distribuição iOS · **Tempo estimado:** 25 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Comparar a **conta Apple gratuita** e o **Apple Developer Program** (US$ 99/ano), item a item.
- Entender o limite dos **7 dias** e dos **3 aparelhos** da conta gratuita — e o que isso significa
  na prática.
- Decidir entre conta **individual** e de **organização**, sabendo o que é irreversível.
- Saber o que exige conta paga: **TestFlight**, **App Store**, push, iCloud, Sign in with Apple.
- Planejar **quando** pagar, para não desperdiçar meses da assinatura.
- Conhecer o processo de cadastro e os documentos necessários no Brasil.

## ✅ Pré-requisitos

- [Aula 5 — Ícone, splash, versão e Info.plist](05-icone-splash-versao-infoplist.md) — o projeto já
  com identidade iOS pronta.
- [Aula 1 — Por que o iOS exige macOS](01-por-que-exige-macos.md) — as opções de acesso a um Mac.
- Um **Apple ID** (a conta comum da Apple; é grátis e você provavelmente já tem).

---

## 🍎🪟 Antes de começar: onde você está

> # ✅ EXECUTÁVEL. Você está no Windows 11.
>
> **Esta aula é decisão e cadastro — e as duas coisas se fazem no navegador.**
>
> **O que você faz agora, no Windows:**
> 1. **Decidir** se e quando vai pagar os US$ 99/ano, com os números desta aula.
> 2. Criar ou conferir o seu **Apple ID** em appleid.apple.com.
> 3. Se decidir pagar: fazer o cadastro inteiro em developer.apple.com, pelo navegador.
> 4. Reunir os documentos (CPF ou CNPJ, cartão internacional).
>
> **O que fica para o Mac:** usar a conta — assinar, gerar profile, enviar build.
>
> ⚠️ **A decisão "individual ou organização" é irreversível** sem abrir uma conta nova. Leia a
> seção antes de clicar. É o ponto mais importante desta aula, e leva cinco minutos de reflexão
> contra meses de dor de cabeça.

---

## 📖 Conceito

### As duas contas

| | **Gratuita** | **Developer Program** |
|---|---|---|
| Custo | US$ 0 | **US$ 99/ano** (~R$ 550) |
| Rodar no simulador | ✅ | ✅ |
| Instalar em aparelho próprio | ✅ | ✅ |
| **Validade do app instalado** | ⚠️ **7 dias** | **1 ano** |
| **Aparelhos** | ⚠️ **3** | 100 por tipo |
| App IDs | ⚠️ 10 por semana | Ilimitado |
| **TestFlight** | ❌ | ✅ |
| **Publicar na App Store** | ❌ | ✅ |
| Push notifications | ❌ | ✅ |
| iCloud, CloudKit | ❌ | ✅ |
| Sign in with Apple | ❌ | ✅ |
| HealthKit, Apple Pay | ❌ | ✅ |
| Widgets, App Clips | ❌ | ✅ |
| Distribuição Ad Hoc | ❌ | ✅ |

> 📌 **O limite dos 7 dias é o que define a experiência da conta gratuita.** O app que você instalou
> no seu iPhone **para de abrir** depois de uma semana. Não some, não avisa — simplesmente não abre
> mais, com uma mensagem genérica. Para usar de novo, é preciso reconectar o iPhone ao Mac e
> reinstalar.

Na prática, isso significa:

| Você quer | Conta |
|---|---|
| Aprender, testar no simulador | ✅ **Gratuita** |
| Testar no seu iPhone de vez em quando | ✅ Gratuita |
| **Usar o app no dia a dia** | ❌ Paga (os 7 dias atrapalham) |
| Mandar para um amigo testar | ❌ **Paga** (TestFlight) |
| Publicar na App Store | ❌ Paga |
| Push, iCloud, login com Apple | ❌ Paga |

### Individual × organização

Esta é a decisão irreversível:

| | **Individual** | **Organização** |
|---|---|---|
| Custo | US$ 99/ano | US$ 99/ano |
| Quem pode | Pessoa física | Empresa com CNPJ |
| **Nome na App Store** | **Seu nome completo** | O nome da empresa |
| Exige | CPF, cartão | CNPJ, **D-U-N-S Number** |
| Tempo de aprovação | Horas a 2 dias | **1 a 4 semanas** |
| Vários desenvolvedores | ❌ Uma pessoa | ✅ Equipe com papéis |
| Migrar depois | ⚠️ Processo longo e manual | — |

> ⚠️ **Na conta individual, o seu nome completo aparece publicamente na App Store**, como
> desenvolvedor do app. Não há como usar um nome fantasia. Se isso é um problema — e para muita
> gente é —, a conta de organização é o caminho, e ela exige CNPJ.

> 📌 **O D-U-N-S Number** é um identificador global de empresas, emitido pela Dun & Bradstreet. É
> **gratuito**, mas leva de 5 a 30 dias. Se você vai de organização, **peça o D-U-N-S primeiro** —
> ele costuma ser o gargalo do processo inteiro.

E a migração de individual para organização existe, mas é um processo manual da Apple, com
transferência de apps — não é uma configuração que se troca.

### Quando pagar

A assinatura conta a partir do dia da aprovação. Pagar cedo demais desperdiça meses.

```text
❌ Ruim:   pago agora → estudo 5 meses → publico → restam 7 meses
✅ Bom:    estudo → app pronto e testado → pago → publico → 12 meses úteis
```

**O momento certo é quando você precisa de algo que só a conta paga oferece:**

| Gatilho | Precisa pagar? |
|---|---|
| Quero rodar no simulador | ❌ |
| Quero testar no meu iPhone | ❌ |
| Meu app já funciona e quero **usá-lo** | ✅ (os 7 dias cansam) |
| Quero que **outra pessoa** teste | ✅ TestFlight |
| Quero push notifications | ✅ |
| Vou publicar em até 1 mês | ✅ |

> 💡 **Para este curso, a recomendação é clara:** faça os módulos 15 inteiros com a **conta
> gratuita**. Ela cobre tudo até a aula 8 (gerar o IPA). Pague quando chegar à aula 9 — TestFlight —
> **e** tiver o app pronto para de fato distribuir.

### Renovação

| | Detalhe |
|---|---|
| Cobrança | Anual, automática se você deixar |
| Esqueceu de renovar | ⚠️ **Os apps saem da App Store** |
| Prazo de tolerância | Curto; a Apple avisa por e-mail |
| Voltar depois | Renove e os apps retornam |

> ⚠️ **App fora do ar por assinatura vencida é constrangedor e evitável.** Os avisos chegam por
> e-mail no endereço do Apple ID — que precisa ser um que você lê. Deixe a renovação automática
> ligada, e o cartão válido.

### O cadastro, no Brasil

**Conta individual:**

1. Apple ID com **autenticação de dois fatores** ligada (obrigatório).
2. developer.apple.com → Account → Join the Apple Developer Program.
3. Dados pessoais **exatamente** como no documento.
4. CPF.
5. Cartão de crédito **internacional** (a cobrança é em dólar).
6. Aceitar os contratos.
7. Aguardar: horas a dois dias.

**Conta de organização**, acrescente:

1. **D-U-N-S Number** da empresa (peça primeiro, leva semanas).
2. CNPJ ativo.
3. Site oficial da empresa no domínio dela.
4. Comprovação de que você tem autoridade legal para assinar.
5. Uma ligação telefônica de verificação, em alguns casos.

| Custo real no Brasil | ~ |
|---|---|
| US$ 99 | ~R$ 540 |
| IOF (~4,38 %) | ~R$ 24 |
| Spread do cartão | Varia |
| **Total** | **~R$ 570–620/ano** |

> ⚠️ **Cartão de débito e cartões virtuais costumam falhar** no cadastro da Apple. Use um cartão de
> crédito internacional de verdade, com limite disponível e função internacional habilitada.

### O limite dos 3 aparelhos

Na conta gratuita, você pode registrar **3 aparelhos**, e o contador **não zera** quando você
remove um. Ele zera uma vez por ano, na renovação anual da lista.

> 💡 Registre só os aparelhos que você realmente vai usar. Ligar o iPhone de um amigo "só para ver"
> gasta um dos três — e você fica sem, pelo resto do ano.

---

## 💡 Analogia

Pense na diferença entre **cozinhar em casa** e **abrir um restaurante**.

- **A conta gratuita** é a sua cozinha. Você cozinha o que quiser, testa receitas, come o que
  fez — e pode servir para **até três pessoas da casa**. Ninguém precisa de licença para isso.
- **Mas tem um detalhe estranho:** a comida **estraga em sete dias**, mesmo na geladeira. Para o
  jantar de teste, tudo bem. Para "quero almoçar isso toda semana", vira um incômodo constante —
  você refaz o prato do zero, sempre.
- **O Developer Program** é o alvará. Com ele, você serve para **quem quiser**, a comida dura o ano
  inteiro, e você pode abrir as portas ao público (a App Store).
- **E o alvará vem no nome de alguém.** Como pessoa física, a placa na porta traz **o seu nome
  completo** — todo cliente lê. Como empresa, traz o nome fantasia. **Trocar depois de aberto**
  significa transferir o estabelecimento: possível, burocrático, demorado.
- **Pagar cedo demais** é tirar o alvará e passar cinco meses ainda decidindo o cardápio: metade da
  licença venceu antes de você servir o primeiro prato.
- **E deixar o alvará vencer** fecha o restaurante — com os clientes na porta, sem aviso na fachada.

---

## 🧪 Exemplo mínimo

A decisão, em três perguntas.

**Pergunta 1 — você precisa que outra pessoa use o app?**

```text
Não  → conta gratuita resolve por enquanto
Sim  → precisa pagar (TestFlight ou App Store)
```

**Pergunta 2 — o app usa push, iCloud, Sign in with Apple, HealthKit ou widgets?**

```text
Não  → gratuita ainda resolve
Sim  → precisa pagar
```

**Pergunta 3 — você aguenta reinstalar o app a cada 7 dias?**

```text
Sim  → gratuita
Não  → pague quando o app estiver pronto
```

**O roteiro para este curso:**

| Aula | Conta necessária |
|---|---|
| 1 a 5 | Nenhuma |
| 6 | Esta decisão |
| 7 — Certificados | ✅ Gratuita basta |
| 8 — IPA e archive | ✅ Gratuita basta (para `.xcarchive` local) |
| **9 — TestFlight** | ❌ **Paga** |
| 10 — Diagnóstico | Qualquer uma |

> 📌 **Você chega até a aula 8 sem gastar nada.** Isso é deliberado: o módulo foi montado para que a
> decisão de pagar venha depois de você ter visto o app funcionando num iPhone.

---

## 📱 Aplicando no Flutter

Uma planilha de decisão e um controle de renovação — porque esquecer de renovar tira o app do ar.

---

## 💻 Código completo

> **Arquivo:** `docs/conta-apple.md` (novo — versionado no projeto)

```markdown
# Conta Apple — Foco

## Decisão

**Tipo escolhido:** <individual | organização>
**Motivo:** <por que este e não o outro>
**Data da decisão:** AAAA-MM-DD

> ⚠️ Individual expõe o SEU NOME COMPLETO na App Store.
> Organização exige CNPJ + D-U-N-S Number (5 a 30 dias).
> Migrar depois é processo manual da Apple.

## Dados

| Campo | Valor |
|---|---|
| Apple ID | <email> |
| Autenticação de 2 fatores | <ligada?> |
| Team ID | <10 caracteres, aparece em developer.apple.com> |
| Tipo de conta | <individual / organização> |
| Data de início | AAAA-MM-DD |
| **Data de renovação** | AAAA-MM-DD |
| Renovação automática | <ligada?> |

> ⚠️ Assinatura vencida = os apps SAEM da App Store.
> Deixe a renovação automática ligada e o cartão válido.
> Os avisos vão para o e-mail do Apple ID.

## Aparelhos registrados

| Aparelho | UDID | Registrado em |
|---|---|---|
| | | |

> Conta gratuita: limite de 3, e o contador NÃO zera ao remover.
> Conta paga: 100 por tipo, zerados uma vez por ano.

## Custo anual

| Item | Valor |
|---|---|
| Developer Program | US$ 99 |
| IOF (~4,38%) | |
| **Total em R$** | |

## Quando eu paguei, e por quê

<O gatilho concreto: "precisei do TestFlight para o beta", e não
"achei que era hora".>
```

> **Arquivo:** `ferramentas/lembrete-renovacao.ps1` (novo)

```powershell
# Avisa quando a assinatura Apple está perto de vencer.
#
# 🪟 Roda no Windows.
#
# Assinatura vencida tira os apps da App Store — e o aviso da
# Apple chega por e-mail, que é fácil de perder.
#
# Rode no login, ou agende com o Agendador de Tarefas.

param(
    # Data de renovação, no formato AAAA-MM-DD.
    [string]$Renovacao,
    [string]$Arquivo = 'docs/conta-apple.md'
)

$ErrorActionPreference = 'Stop'

# Se a data não veio por parâmetro, lê do documento do projeto —
# assim ela mora num lugar só.
if (-not $Renovacao) {
    if (-not (Test-Path $Arquivo)) {
        Write-Host "Informe -Renovacao AAAA-MM-DD, ou crie $Arquivo" -ForegroundColor Yellow
        exit 0
    }
    $m = [regex]'\|\s*\*\*Data de renovação\*\*\s*\|\s*(\d{4}-\d{2}-\d{2})\s*\|'
    $achado = $m.Match((Get-Content $Arquivo -Raw))
    if (-not $achado.Success) {
        Write-Host "Data de renovação não preenchida em $Arquivo" -ForegroundColor Yellow
        exit 0
    }
    $Renovacao = $achado.Groups[1].Value
}

$data = [datetime]::ParseExact($Renovacao, 'yyyy-MM-dd', $null)
$dias = ($data - (Get-Date).Date).Days

Write-Host ''
Write-Host "Renovação da conta Apple: $Renovacao" -ForegroundColor Cyan

if ($dias -lt 0) {
    Write-Host "  ❌ VENCEU há $([math]::Abs($dias)) dia(s)." -ForegroundColor Red
    Write-Host '     Os apps podem ter saído da App Store.' -ForegroundColor Red
    Write-Host '     Renove em: developer.apple.com/account' -ForegroundColor Yellow
    exit 1
}
elseif ($dias -le 30) {
    # A Apple permite renovar a partir de ~30 dias antes.
    Write-Host "  ⚠️  Faltam $dias dia(s)." -ForegroundColor Yellow
    Write-Host '     Confira se a renovação automática está ligada' -ForegroundColor Yellow
    Write-Host '     e se o cartão continua válido.' -ForegroundColor Yellow
}
else {
    Write-Host "  ✅ Faltam $dias dia(s)." -ForegroundColor Green
}

# ── Custo, para planejamento ────────────────────────────────────
$dolar = 5.45   # ajuste conforme o câmbio
$total = [math]::Round(99 * $dolar * 1.0438, 2)
Write-Host ''
Write-Host "  Custo estimado da renovação: ~R$ $total (US$ 99 + IOF)" -ForegroundColor Gray
```

E o roteiro de decisão, interativo:

> **Arquivo:** `ferramentas/decidir-conta.ps1` (novo)

```powershell
# Ajuda a decidir: gratuita ou paga, individual ou organização.
#
# 🪟 Roda no Windows. É decisão, não build.

function Perguntar($texto) {
    do {
        $r = (Read-Host "$texto (s/n)").ToLower()
    } while ($r -notin @('s', 'n'))
    return $r -eq 's'
}

Write-Host '═══ QUAL CONTA APPLE VOCÊ PRECISA? ═══' -ForegroundColor Cyan
Write-Host ''

$precisaPagar = $false
$motivos = @()

# Cada uma destas exige o Developer Program.
if (Perguntar 'Outra pessoa (que não você) precisa testar o app?') {
    $precisaPagar = $true; $motivos += 'TestFlight exige conta paga'
}
if (Perguntar 'Você vai publicar na App Store?') {
    $precisaPagar = $true; $motivos += 'Publicar exige conta paga'
}
if (Perguntar 'O app usa push, iCloud, Sign in with Apple, HealthKit ou widgets?') {
    $precisaPagar = $true; $motivos += 'Esses recursos exigem conta paga'
}
if (Perguntar 'Você vai USAR o app no dia a dia (não só testar)?') {
    $precisaPagar = $true; $motivos += 'O limite de 7 dias da conta gratuita atrapalha o uso diário'
}

Write-Host ''
Write-Host '─────────────────────────────' -ForegroundColor Cyan

if (-not $precisaPagar) {
    Write-Host '✅ CONTA GRATUITA resolve por enquanto.' -ForegroundColor Green
    Write-Host ''
    Write-Host '   Ela cobre as aulas 1 a 8 deste módulo:'
    Write-Host '   simulador, iPhone próprio, certificados e até o .xcarchive.'
    Write-Host ''
    Write-Host '   Limites a lembrar:' -ForegroundColor Yellow
    Write-Host '     · o app instalado para de abrir em 7 dias'
    Write-Host '     · 3 aparelhos, e o contador NÃO zera ao remover'
    Write-Host ''
    Write-Host '   Pague quando chegar à aula 9 (TestFlight) COM o app pronto.'
    exit 0
}

Write-Host '💳 VOCÊ PRECISA DO DEVELOPER PROGRAM (US$ 99/ano).' -ForegroundColor Yellow
$motivos | ForEach-Object { Write-Host "   · $_" }

Write-Host ''
Write-Host '─── Individual ou organização? ───' -ForegroundColor Cyan
Write-Host ''

$temCnpj = Perguntar 'Você tem um CNPJ ativo?'

if (-not $temCnpj) {
    Write-Host ''
    Write-Host '→ INDIVIDUAL (é a única opção sem CNPJ).' -ForegroundColor Green
    Write-Host ''
    Write-Host '   ⚠️ SEU NOME COMPLETO aparecerá publicamente na' -ForegroundColor Yellow
    Write-Host '      App Store como desenvolvedor do app.' -ForegroundColor Yellow
    Write-Host '      Não há nome fantasia na conta individual.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '   Aprovação: horas a 2 dias.'
    Write-Host '   Precisa: CPF + cartão de crédito INTERNACIONAL.'
    exit 0
}

$nomeImporta = Perguntar 'Incomoda o SEU NOME aparecer publicamente na App Store?'
$equipe = Perguntar 'Mais de uma pessoa vai trabalhar na conta?'

Write-Host ''
if ($nomeImporta -or $equipe) {
    Write-Host '→ ORGANIZAÇÃO.' -ForegroundColor Green
    Write-Host ''
    Write-Host '   ⚠️ Exige D-U-N-S Number — gratuito, mas leva' -ForegroundColor Yellow
    Write-Host '      de 5 a 30 dias. PEÇA PRIMEIRO: costuma ser' -ForegroundColor Yellow
    Write-Host '      o gargalo do processo inteiro.' -ForegroundColor Yellow
    Write-Host '      → developer.apple.com/enroll/duns-lookup' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '   Também precisa: CNPJ ativo, site no domínio da empresa,'
    Write-Host '   e comprovação de autoridade legal para assinar.'
    Write-Host '   Aprovação: 1 a 4 semanas.'
} else {
    Write-Host '→ INDIVIDUAL (mais simples e mais rápida).' -ForegroundColor Green
    Write-Host ''
    Write-Host '   Você tem CNPJ, mas nenhum dos motivos para organização'
    Write-Host '   se aplica. A individual aprova em horas.'
}

Write-Host ''
Write-Host '⚠️ A escolha é IRREVERSÍVEL sem abrir conta nova.' -ForegroundColor Red
Write-Host '   Migrar depois é processo manual da Apple, com' -ForegroundColor Red
Write-Host '   transferência de apps.' -ForegroundColor Red
Write-Host ''
Write-Host 'Anote a decisão e o motivo em docs/conta-apple.md.' -ForegroundColor Cyan
```

```powershell
.\ferramentas\decidir-conta.ps1
.\ferramentas\lembrete-renovacao.ps1 -Renovacao 2027-09-14
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `docs/conta-apple.md` versionado | A data de renovação e o Team ID moram num lugar só, no repositório. |
| Campo "quando eu paguei, e por quê" | Registra o **gatilho concreto**, não a impressão. |
| `lembrete-renovacao.ps1` lendo do documento | A data não se duplica entre script e doc. |
| Aviso a 30 dias | É a partir daí que a Apple permite renovar. |
| `exit 1` quando vencido | Permite usar como portão ou alerta no login. |
| Custo com IOF | O valor real no Brasil não é US$ 99 × câmbio. |
| `decidir-conta.ps1` com quatro perguntas | Cada uma corresponde a um recurso que **só** a conta paga oferece. |
| Perguntar CNPJ **primeiro** | Sem CNPJ, organização nem é opção. |
| Aviso do **D-U-N-S em destaque** | É o gargalo do processo, e pouca gente sabe disso antes. |
| Alerta do nome público | O detalhe que mais surpreende quem escolhe individual. |
| Aviso de irreversibilidade no fim | É a última coisa que a pessoa lê antes de decidir. |

---

## 🤖🍎 Android × iOS

| | 🤖 Google Play | 🍎 Apple |
|---|---|---|
| Custo | **US$ 25, uma vez** | **US$ 99, por ano** |
| Testar em aparelho próprio | ✅ Grátis, sempre | ⚠️ 7 dias na conta gratuita |
| Distribuir fora da loja | ✅ APK livremente | ❌ TestFlight ou provisioning |
| Teste com outras pessoas | Faixa de teste (exige conta) | TestFlight (exige conta) |
| Nome do desenvolvedor | Você escolhe | ⚠️ Nome real, na conta individual |
| Aprovação da conta | Horas | Horas a semanas |
| Renovação | ❌ Não existe | ✅ Anual, ou os apps saem |

> 💡 **A diferença de modelo é grande.** No Android, você paga US$ 25 **uma vez**, e antes disso já
> pode distribuir APK para quem quiser, livremente. No iOS, distribuir para **qualquer pessoa**
> exige a assinatura anual — e parar de pagar tira os apps do ar.

> 📌 **Some os cinco anos:** Google Play, US$ 25. Apple, US$ 495. Não é argumento para não publicar
> no iOS — é informação para planejar. Um app iOS que não gera nada precisa, ao menos, de alguém
> disposto a bancar US$ 99 por ano indefinidamente.

---

## ⚠️ Erros comuns

### 1. Pagar antes de precisar

Meses da assinatura desperdiçados.

**Correção:** pague no gatilho concreto.

### 2. Escolher individual sem saber do nome público

Seu nome completo na App Store.

**Correção:** decida com a informação.

### 3. Escolher organização sem o D-U-N-S

O cadastro para e espera semanas.

**Correção:** peça o D-U-N-S **primeiro**.

### 4. Achar que a conta gratuita publica

Ela não publica, e não faz TestFlight.

**Correção:** entenda os limites antes.

### 5. Estranhar o app parar de abrir

São os 7 dias.

**Correção:** reinstale, ou pague.

### 6. Gastar os 3 aparelhos à toa

O contador não zera ao remover.

**Correção:** registre só o necessário.

### 7. Cartão de débito ou virtual

O cadastro falha.

**Correção:** crédito internacional.

### 8. Dados diferentes do documento

Cadastro recusado.

**Correção:** exatamente como no documento.

### 9. Sem autenticação de dois fatores

Obrigatória.

**Correção:** ligue antes.

### 10. Esquecer de renovar

**Os apps saem da App Store.**

**Correção:** renovação automática + lembrete.

### 11. Achar que migrar é simples

É processo manual da Apple.

**Correção:** decida certo na primeira vez.

### 12. Não registrar o Team ID

Ele é pedido nas aulas 7, 8 e 9.

**Correção:** anote em `docs/conta-apple.md`.

---

## 🛠️ Exercício guiado

> 🪟 **Todos os passos rodam no Windows.**

**Passo 1.** Rode `decidir-conta.ps1`. Qual foi o resultado?

**Passo 2.** Você precisa pagar **agora**, ou só na aula 9?

**Passo 3.** Se for individual: você se incomoda com o seu nome público na App Store?

**Passo 4.** Se for organização: já pediu o D-U-N-S? Quanto tempo estimam?

**Passo 5.** Confira em appleid.apple.com se a autenticação de dois fatores está ligada.

**Passo 6.** Calcule o custo real em reais, com IOF e spread do seu cartão.

**Passo 7.** Calcule o custo de **cinco anos**, e compare com os US$ 25 do Google Play.

**Passo 8.** Crie `docs/conta-apple.md` e preencha o que já sabe.

**Passo 9.** Se já tem conta: ache o **Team ID** em developer.apple.com e anote.

**Passo 10.** Configure o `lembrete-renovacao.ps1` e teste com uma data próxima.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/16-build-ios.md](../../exercicios/16-build-ios.md)

Faça os de **Reflexão** — esta aula é sobre decisão, e a decisão é o exercício.

---

## 🏆 Desafio opcional

Monte o **plano financeiro** de publicar e manter o seu app nas duas lojas, por cinco anos.

Requisitos:

- Custo de entrada: Google Play (US$ 25) + Apple (US$ 99).
- Custo anual recorrente da Apple, com IOF e uma projeção de câmbio.
- Custo de acesso a um Mac: Mac mini usado, Mac na nuvem por hora, ou CI com runner macOS — compare
  os três em cinco anos (aula 1).
- Custo de servidor, se o app tiver backend.
- Total em cinco anos, e o **custo por mês**.
- O ponto de equilíbrio: quantos usuários pagantes, ou quanto de anúncio, cobriria isso.

Depois responda: o custo muda a sua decisão de publicar no iOS? E se você publicar só no Android
primeiro — o que você **perde**, além do alcance? (Dica: pense em quem são os usuários de cada
plataforma no seu nicho, e no que você aprende sobre o app publicando nas duas.)

---

## 📌 Resumo

- **Conta gratuita**: simulador, iPhone próprio, **7 dias** de validade, **3 aparelhos**.
- **Developer Program**: US$ 99/ano, TestFlight, App Store, push, iCloud, Sign in with Apple.
- **O limite dos 7 dias** é o que define a conta gratuita: o app **para de abrir**.
- **Individual expõe o seu nome completo** publicamente na App Store.
- **Organização exige CNPJ + D-U-N-S Number** — gratuito, mas leva de 5 a 30 dias. **Peça primeiro.**
- **A escolha é irreversível** sem abrir conta nova; migrar é processo manual da Apple.
- **Pague no gatilho concreto**, não por antecipação: a assinatura começa a correr na aprovação.
- Neste curso, a **conta gratuita cobre até a aula 8**; a paga só é necessária na 9.
- **Assinatura vencida tira os apps da App Store.** Renovação automática + cartão válido.
- Autenticação de dois fatores é **obrigatória**; cartão precisa ser **crédito internacional**.
- Custo real no Brasil: **~R$ 570–620/ano** com IOF.
- Comparação: Google Play são **US$ 25 uma vez**; Apple, **US$ 99 por ano**, indefinidamente.
- **Anote o Team ID** — ele é pedido nas aulas 7, 8 e 9.

---

## ☑️ Checklist de domínio

- [ ] Sei o que a conta gratuita permite e o que não permite.
- [ ] Entendo o limite dos 7 dias e dos 3 aparelhos.
- [ ] Decidi entre individual e organização, sabendo o que é irreversível.
- [ ] Sei que o nome individual é público na App Store.
- [ ] Sei que organização exige D-U-N-S, e que ele leva semanas.
- [ ] Decidi **quando** pagar, com um gatilho concreto.
- [ ] Minha autenticação de dois fatores está ligada.
- [ ] Tenho um cartão de crédito internacional válido.
- [ ] Calculei o custo real em reais.
- [ ] Anotei Team ID e data de renovação em `docs/conta-apple.md`.
- [ ] Configurei um lembrete de renovação.

---

## 📚 Referências oficiais

- [Apple Developer Program](https://developer.apple.com/programs/)
- [Enrollment — developer.apple.com](https://developer.apple.com/programs/enroll/)
- [D-U-N-S Number lookup](https://developer.apple.com/enroll/duns-lookup/)
- [Membership details — developer.apple.com](https://developer.apple.com/support/membership/)
- [Free provisioning — docs.flutter.dev](https://docs.flutter.dev/deployment/ios)
- [Apple ID e autenticação de dois fatores](https://support.apple.com/pt-br/HT204915)
- [Google Play Console — taxa de registro](https://support.google.com/googleplay/android-developer/answer/6112435)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Ícone, splash, versão e Info.plist](05-icone-splash-versao-infoplist.md) | [README](README.md) | [Aula 7 — Certificados e provisioning](07-certificados-e-provisioning.md) |
