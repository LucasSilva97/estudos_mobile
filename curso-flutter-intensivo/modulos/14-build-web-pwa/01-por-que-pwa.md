# Aula 1 — Por que PWA é o canal principal

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Definir **PWA** sem usar a palavra "moderno": dizer exatamente quais três peças técnicas
  transformam um site em aplicativo instalável.
- Explicar por que este curso escolheu o PWA como **canal principal** do Foco — em termos de custo,
  revisão, prazo e máquina disponível.
- Listar, com honestidade, **o que o PWA não faz** tão bem quanto um app nativo, e reconhecer os
  casos em que ele é a escolha errada.
- Comparar os três canais (PWA, APK/AAB, IPA) linha a linha e justificar uma decisão de distribuição.
- Entender o que muda para o **usuário** — não para você — entre receber um link e receber um app
  de loja.

## ✅ Pré-requisitos

- [README do módulo](README.md) lido, especialmente a tabela comparativa final.
- [Módulo 05, aula 2 — Estrutura do projeto](../05-introducao-ao-flutter/02-estrutura-do-projeto.md) —
  você já viu a pasta `web/` lá, com uma linha sobre o `manifest.json`. Esta aula abre aquela linha.
- Nenhum pré-requisito de ferramenta: esta aula é conceitual e não compila nada.

---

## 📖 Conceito

### O que é um PWA, tecnicamente

*Progressive Web App* não é uma tecnologia. É um **nome dado a um site que cumpre três requisitos
técnicos** — e que, por cumpri-los, ganha do navegador o direito de se comportar como aplicativo
instalado.

```text
Site comum  +  HTTPS
            +  manifest.json válido
            +  service worker com handler de fetch
            ────────────────────────────────────
            =  o navegador oferece "Instalar"
```

São esses três, e não outros. Não existe loja de PWA, não existe aprovação, não existe selo. O
navegador confere os três requisitos sozinho, em silêncio, e libera o recurso.

| Peça | O que ela resolve | Aula |
|---|---|---|
| **HTTPS** | Ninguém consegue injetar código no caminho; é pré-requisito do service worker | [9](09-publicando-no-github-pages.md) |
| **`manifest.json`** | Nome, ícone, cor, orientação e modo de exibição quando instalado | [5](05-manifest-e-icones.md) |
| **Service worker** | Um interceptador de rede que roda no navegador e permite funcionar offline | [6](06-service-worker-e-offline.md) |

> 📌 **O Flutter já gera os três.** `flutter create` produz um `web/manifest.json` e o
> `flutter build web` produz um service worker. O GitHub Pages serve HTTPS por padrão. Ou seja: o
> seu projeto já é *quase* um PWA instalável hoje — o que falta é o `manifest.json` estar
> **preenchido de verdade** (o gerado vem com `"name": "foco"` e ícones genéricos) e você entender o
> service worker bem o bastante para não ficar preso na versão antiga.

### O que "instalado" significa na prática

Quando a pessoa aceita instalar, **nada é baixado de uma loja**. O navegador cria um atalho na tela
inicial e registra que aquele site abre em modo **standalone**: sem barra de endereços, sem abas,
com o ícone e o nome do seu `manifest.json`, na cor que você escolheu.

```text
Antes de instalar                 Depois de instalar
┌──────────────────────┐          ┌──────────────────────┐
│ 🔒 seu-site.com/foco │  ← URL   │                      │  ← sem URL
├──────────────────────┤          ├──────────────────────┤
│                      │          │                      │
│   Foco               │          │   Foco               │
│                      │          │                      │
└──────────────────────┘          └──────────────────────┘
  aba do navegador                  janela própria, ícone
                                    próprio, aparece no
                                    alternador de apps
```

Para o usuário, é indistinguível de um app de loja na maior parte do uso. Ele não sabe — e não
precisa saber — que aquilo é um navegador sem enfeites.

### Por que este curso escolheu o PWA como principal

Quatro razões, em ordem de peso.

**1. É o único canal que você publica hoje, desta máquina.**

Você está no Windows 11. Os outros dois canais impõem barreiras que não dependem do seu esforço:

| Canal | O que trava | Quando destrava |
|---|---|---|
| 🌐 **PWA** | Nada | **Hoje** |
| 🤖 Play Store | US$ 25 + verificação de identidade | Dias, se você pagar |
| 🍎 App Store | US$ 99/ano + **macOS com Xcode** | Quando você tiver um Mac |

O Módulo 16 (iOS) é honesto sobre isso em dez aulas seguidas: no Windows, você lê, entende e
**prepara** — mas não gera o `.ipa`. O PWA não tem essa assimetria.

**2. Não existe revisão.**

Você faz `git push`, o GitHub Actions compila e publica, e a versão nova está no ar em ~2 minutos.
Não há fila, não há revisor, não há rejeição por "o texto da permissão é genérico" (um caso real que
o [Módulo 17, aula 2](../17-publicacao-e-proximos-passos/02-app-store-connect.md) detalha).

**3. A atualização chega sozinha.**

Este é o ponto que quase ninguém pesa bem. Num app de loja, a sua correção só existe para quem
atualiza — e boa parte das pessoas nunca atualiza. Num PWA, o service worker busca a versão nova no
próximo acesso e a aplica no acesso seguinte. Duas aberturas e **todo mundo** está na versão atual.

```text
App de loja:  você publica → a loja aprova → o usuário atualiza → correção ativa
                  dias           horas            nunca?

PWA:          você publica → o usuário abre → o usuário abre de novo → correção ativa
                 2 min          segundos             segundos
```

> ⚠️ **Esse mesmo mecanismo é a maior armadilha do PWA.** "A versão nova chega sozinha" e "o usuário
> ficou preso na versão velha" são o **mesmo assunto**, visto de dois lados. A
> [Aula 6](06-service-worker-e-offline.md) é inteira sobre isso.

**4. O link é distribuível por qualquer canal.**

Um `.apk` você não manda por WhatsApp sem a pessoa liberar "fontes desconhecidas". Um `.ipa` você
simplesmente não manda. Uma URL cabe em qualquer lugar: mensagem, e-mail, QR Code, assinatura,
currículo. E o Google indexa.

### O que o PWA não faz — a parte honesta

Escolher um canal como principal não é fingir que ele é melhor em tudo. Estas são as perdas reais:

| Limitação | Gravidade | Detalhe |
|---|---|---|
| **Sem presença na loja** | Alta, se o seu público procura na loja | Ninguém acha o Foco procurando "organizador de estudos" na Play Store |
| **Hardware limitado** | Alta, dependendo do app | Sem Bluetooth de baixo nível, sem NFC amplo, sem acesso arbitrário ao sistema de arquivos |
| **iOS restringe mais** | Média a alta | Sem prompt automático de instalação; push exige o app já instalado; recursos chegam depois |
| **Execução em segundo plano** | Média | Nada de serviço rodando com o app fechado como no Android |
| **Primeiro carregamento** | Média | O usuário baixa alguns MB na primeira visita; um app instalado já está no aparelho |
| **Dados podem ser despejados** | Média | O navegador pode limpar o armazenamento sob pressão de espaço ([Aula 4](04-banco-de-dados-na-web.md)) |
| **Percepção** | Baixa, mas existe | Parte do público confia mais em "está na loja" |

> 📌 **Quando o PWA é a escolha errada:** app que depende de Bluetooth LE, leitura de NFC, acesso
> total a arquivos, execução contínua em segundo plano, ou cujo modelo de negócio exige a cobrança
> pela loja. Nada disso é o caso do Foco — que é um organizador de estudos com banco local, uma API
> pública e nenhuma exigência de hardware.

### O que muda para o Foco especificamente

O Foco usa: `sqflite` (banco local), `http` (API pública de trilhas), `shared_preferences` (a meta),
`connectivity_plus` (detecção de rede) e `flutter_secure_storage`. Desses cinco:

| Pacote | Na web | O que fazer |
|---|---|---|
| `sqflite` | ❌ Não funciona | Trocar a *factory* ([Aula 4](04-banco-de-dados-na-web.md)) |
| `http` | ⚠️ Funciona, mas sujeito a **CORS** | Entender o erro ([Aula 3](03-o-que-nao-funciona-na-web.md)) |
| `shared_preferences` | ✅ Funciona (usa `localStorage`) | Nada |
| `connectivity_plus` | ⚠️ Funciona parcialmente | Entender o limite ([Aula 3](03-o-que-nao-funciona-na-web.md)) |
| `flutter_secure_storage` | ⚠️ Funciona, **sem a mesma garantia** | Entender o limite ([Aula 3](03-o-que-nao-funciona-na-web.md)) |

Um pacote a trocar, três a entender, um intacto. É um custo baixo — e ele só é baixo porque a
arquitetura do Foco isolou `sqflite` atrás de uma interface em `domain/`, exatamente como a
[ADR-05](../../projetos/03-projeto-final-multiplataforma/02-arquitetura.md) previu.

---

## 💡 Analogia

Pense em três formas de abrir um restaurante.

- **A loja de aplicativos é um shopping.** Ponto garantido, fluxo de gente que já vem procurando
  comida, crachá de legitimidade. Em troca: você paga luva, assina contrato, passa por uma
  inspeção antes de abrir, e cada mudança no cardápio precisa ser aprovada. Se a administração
  reprovar a sua fachada, você não abre — e a resposta pode levar dias.
- **O PWA é uma cozinha com entrega por link.** Você abre hoje, sem inspeção, sem luva. Quem tem o
  endereço chega. Mudou o cardápio às 14h? Quem pedir às 14h05 já recebe o novo. Em troca: ninguém
  passa na frente por acaso, e você não tem a vitrine do shopping.
- **O app nativo distribuído fora da loja** é entregar marmita de porta em porta. Funciona, dá
  trabalho, e no iOS o prédio não deixa você entrar.

E a parte da analogia que mais importa: **um restaurante que existe é melhor que três que estão em
aprovação.** Este curso prioriza o canal que coloca o Foco funcionando na mão de alguém no mesmo dia
— e depois, com calma, abre a unidade do shopping nos módulos 15, 16 e 17.

---

## 🧪 Exemplo mínimo

O `manifest.json` que o `flutter create` gera para você hoje:

```json
{
    "name": "foco",
    "short_name": "foco",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "A new Flutter project.",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "icons": [ ... ]
}
```

Repare no que está errado aí para um app de verdade:

| Campo | Valor gerado | Problema |
|---|---|---|
| `name` | `"foco"` | Minúsculo; é o que aparece na tela de instalação |
| `description` | `"A new Flutter project."` | Aparece em alguns navegadores e lojas de PWA |
| `background_color` | `#0175C2` | Azul do Flutter, não a cor do Foco |
| `theme_color` | `#0175C2` | Idem — pinta a barra de status no Android |
| `scope` | **ausente** | Sem ele, o comportamento em subpasta fica ambíguo |
| `icons` | Ícones do Flutter | Nenhum `maskable`; no Android vira ícone com moldura branca |

Quatro linhas de texto e dois ícones separam "um projeto Flutter genérico" de "o Foco instalado na
tela inicial com a cara certa". É a [Aula 5](05-manifest-e-icones.md) inteira.

---

## 📱 Aplicando no Flutter

Você não precisa instalar nada nem adicionar dependência para ter um PWA. O suporte é do próprio
SDK. Confirme que ele está ligado:

```powershell
flutter config --list
```

```text
Settings:
  enable-web: true
```

E que o alvo existe:

```powershell
flutter devices
```

```text
Windows (desktop) • windows • windows-x64    • Microsoft Windows
Chrome (web)      • chrome  • web-javascript • Google Chrome 141
Edge (web)        • edge    • web-javascript • Microsoft Edge 141
```

Se `Chrome (web)` aparece, você já consegue rodar o Foco no navegador hoje:

```powershell
flutter run -d chrome
```

> 💡 **Rode agora, antes da Aula 2.** O Foco vai abrir — e provavelmente quebrar na primeira tela
> que consulta o banco. Guarde a mensagem: ela é o assunto das aulas 3 e 4, e é muito mais didática
> quando você a viu com os próprios olhos antes de ler a explicação.

---

## 💻 Código completo

Não há código de aplicação nesta aula — ela é a que decide **o quê** e **por quê**, não o *como*. O
que existe é um instrumento de decisão: uma matriz para escolher o canal de qualquer app que você
vier a fazer.

> **Arquivo:** `docs/decisao-de-canal.md` (no seu projeto, não no curso)
> **Como usar:** responda as sete perguntas antes de escrever a primeira linha de um app novo

```markdown
# Matriz de decisão de canal

Marque uma coluna por linha. A coluna com mais marcas é o canal principal.

| Pergunta | 🌐 PWA | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| O app precisa de Bluetooth LE, NFC ou sensores pouco comuns? | Não | Sim | Sim |
| O app precisa rodar com a tela apagada / em segundo plano? | Não | Sim | Sim |
| O público procura apps na loja antes de procurar no Google? | Não | Sim | Sim |
| O modelo de cobrança exige o pagamento pela loja? | Não | Sim | Sim |
| Eu preciso de usuários nesta semana? | **Sim** | Não | Não |
| Eu vou corrigir bugs com frequência no começo? | **Sim** | Não | Não |
| Meu orçamento inicial é zero? | **Sim** | Não | Não |

## Resultado para o Foco

| Pergunta | Resposta | Aponta para |
|---|---|---|
| Bluetooth/NFC/sensores? | Não — só banco local e uma API pública | 🌐 |
| Segundo plano? | Não — o cronômetro roda com o app aberto | 🌐 |
| Público busca na loja? | Não — é distribuído por link para colegas de estudo | 🌐 |
| Cobrança pela loja? | Não — é gratuito | 🌐 |
| Usuários esta semana? | Sim | 🌐 |
| Correções frequentes? | Sim, é a primeira versão | 🌐 |
| Orçamento zero? | Sim | 🌐 |

**Canal principal: PWA. Canais adicionais: Android (módulo 15) e iOS (módulo 16).**

> Revisar esta matriz quando: aparecer requisito de notificação agendada com o app fechado,
> ou quando o público mudar de "colegas com o link" para "quem procura na loja".
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| As quatro primeiras perguntas | São eliminatórias **contra** o PWA: qualquer "sim" aqui tira o PWA de canal único. |
| As três últimas perguntas | São eliminatórias **a favor** do PWA: qualquer "sim" aqui torna o PWA o caminho mais rápido. |
| "Canal principal" e não "canal único" | A decisão nunca é exclusiva — o Foco vai ter APK também, no módulo 15. |
| A seção "Revisar quando" | Uma decisão de arquitetura sem gatilho de revisão vira dogma. Registre o que faria você mudar de ideia. |
| O arquivo mora em `docs/` do **seu** projeto | Decisão de produto pertence ao repositório do produto, não à sua memória. |

> 📌 **Esse formato — decisão, alternativas, porquê, gatilho de revisão — é um ADR** (*Architecture
> Decision Record*). É o mesmo formato de
> [05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md), que registra as escolhas deste curso.

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web (PWA) | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| Artefato | Pasta `build/web/` | `.apk` / `.aab` | `.ipa` |
| Onde publica | Qualquer servidor HTTPS | Google Play | App Store |
| Identidade do app | **A URL** | `applicationId` | *Bundle Identifier* |
| Assinatura | ❌ Não existe | Keystore | Certificado + provisioning |
| Gerar no Windows | ✅ | ✅ | ❌ |
| Custo | R$ 0 | US$ 25 | US$ 99/ano |
| Instalação | Pelo navegador | Pela loja ou APK | Só pela loja/TestFlight |
| Prompt de instalação | ✅ Chrome/Edge · ❌ Safari | ✅ | ✅ |
| Tamanho que o usuário baixa | ~3–8 MB (1ª visita) | ~17 MB | ~20 MB |
| Código fonte visível | ⚠️ **Sim** (minificado) | ⚠️ Extraível com esforço | ⚠️ Extraível com esforço |

> ⚠️ **"Identidade do app = a URL" tem consequência definitiva.** No Android, o `applicationId` não
> pode mudar depois da publicação. Na web, o equivalente é o **domínio + caminho**: mudar de
> `github.io/foco/` para um domínio próprio faz o navegador tratar como **outro app**. Quem tinha
> instalado continua com o ícone antigo apontando para o endereço antigo, e o banco local — que é
> por origem — **não vai junto**. A [Aula 5](05-manifest-e-icones.md) trata do `scope` e a
> [Aula 9](09-publicando-no-github-pages.md), do domínio próprio.

🪟 **No Windows**, esta aula e todo o módulo funcionam por completo. É o único módulo de build do
curso do qual isso é verdade.

---

## ⚠️ Erros comuns

### 1. Achar que PWA é "site que parece app"

É um site que **é** um app instalável, com offline e ícone próprio. A diferença não é estética.

**Correção:** os três requisitos — HTTPS, manifest, service worker.

### 2. Achar que existe uma loja de PWA para aprovar

Não existe aprovação. O navegador confere os requisitos sozinho.

**Correção:** publicou, está no ar.

### 3. Tratar o PWA como versão inferior do app "de verdade"

Para o Foco, o PWA é o canal **principal** — os outros é que são adicionais.

**Correção:** decida por matriz, não por hábito.

### 4. Ignorar as limitações do iOS

O Safari não mostra prompt de instalação, e vários recursos chegam atrasados.

**Correção:** [Aula 7](07-instalabilidade.md) — inclusive como instruir o usuário de iPhone.

### 5. Prometer offline sem ter configurado nada

O service worker gerado guarda o **app**; os **dados** são outro assunto.

**Correção:** aulas [4](04-banco-de-dados-na-web.md) e [6](06-service-worker-e-offline.md).

### 6. Colocar chave de API no código de um app web

Tudo em `build/web/` é público. Minificado não é secreto.

**Correção:** segredo mora no servidor. [Aula 8](08-gerando-o-build-web.md).

### 7. Escolher PWA para um app que precisa de hardware

Bluetooth LE, NFC amplo e segundo plano contínuo não estão lá.

**Correção:** rode a matriz antes de decidir.

### 8. Achar que publicar na web dispensa versionamento

Versionar continua sendo obrigatório — inclusive para resolver o cache do service worker.

**Correção:** [Módulo 17, aula 3](../17-publicacao-e-proximos-passos/03-versionamento-e-releases.md).

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter devices` e confirme que `Chrome (web)` aparece.

**Passo 2.** Rode `flutter run -d chrome` no Foco. Ele abre?

**Passo 3.** Navegue até a tela de matérias. Anote **a mensagem de erro exata** que aparecer no
terminal ou no console do navegador (F12 → Console). Guarde: você vai reencontrá-la na Aula 3.

**Passo 4.** Abra `web/manifest.json` no editor. Compare, campo a campo, com a tabela do
"Exemplo mínimo". Quantos campos estão com o valor genérico do Flutter?

**Passo 5.** Abra um PWA que você já usa (por exemplo, `web.whatsapp.com` ou `x.com`) no Chrome.
Procure o ícone de instalar na barra de endereços. Ele aparece?

**Passo 6.** Nesse mesmo site, abra F12 → **Application** → **Manifest**. Leia os campos
preenchidos. Compare com o seu.

**Passo 7.** Ainda em **Application**, clique em **Service workers**. Há um registrado? Qual o
status?

**Passo 8.** Preencha a matriz de decisão de canal para o Foco. Alguma resposta sua diverge da do
curso?

**Passo 9.** Preencha a mesma matriz para um app hipotético de **controle de ponto com leitura de
crachá NFC**. Qual canal vence?

**Passo 10.** Escreva, em duas frases, o que você diria a um colega que afirmasse "PWA não é app
de verdade".

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Fixação** (os três requisitos), **Reflexão** (escolha de canal) e o de **Aplicação**
que monta a matriz de decisão para um app seu.

---

## 🏆 Desafio opcional

Escreva o **ADR de canal de distribuição do Foco** como um documento de verdade, para o repositório.

Requisitos:

- Título, data, status (`aceito`) e os responsáveis pela decisão.
- O **contexto**: quem usa o Foco, em que aparelho, com que frequência.
- A **decisão** em uma frase.
- As **alternativas consideradas** — as três — cada uma com o motivo da recusa como canal
  principal. O motivo precisa ser específico: "caro" não serve; "US$ 99/ano recorrentes para um app
  gratuito de uso pessoal" serve.
- As **consequências**, divididas em positivas e negativas. Liste pelo menos **três negativas** —
  se você não consegue listar três, você não entendeu o trade-off.
- O **gatilho de revisão**: o que precisaria acontecer para reabrir a decisão.

Depois responda: das três consequências negativas que você listou, qual delas te incomoda mais? E
o que você faria hoje para reduzi-la sem trocar de canal?

---

## 📌 Resumo

- **PWA não é tecnologia, é um conjunto de três requisitos**: HTTPS + `manifest.json` +
  service worker com handler de fetch.
- O Flutter **já gera** os três; o que falta é preencher o manifest e entender o service worker.
- "Instalado" significa atalho na tela inicial e abertura em **standalone** — sem barra de
  endereços. Nada é baixado de loja alguma.
- O PWA é o canal principal deste curso porque é o único que você publica **hoje, no Windows,
  de graça e sem revisão**.
- **A atualização chega sozinha** — e esse mesmo mecanismo é a maior armadilha do PWA
  ([Aula 6](06-service-worker-e-offline.md)).
- O PWA **perde** em: presença na loja, hardware, restrições do iOS, segundo plano, primeiro
  carregamento e persistência garantida dos dados.
- Ele é a **escolha errada** para apps que dependem de BLE, NFC, arquivos ou execução contínua.
- No Foco, dos 5 pacotes de plataforma: **1 a trocar** (`sqflite`), **3 a entender**
  (`http`/CORS, `connectivity_plus`, `flutter_secure_storage`), **1 intacto**
  (`shared_preferences`).
- **A identidade do app na web é a URL.** Mudar de endereço cria um app novo aos olhos do
  navegador — e o banco local não vai junto.
- Decida canal por **matriz**, registre em **ADR**, e defina o **gatilho de revisão**.

---

## ☑️ Checklist de domínio

- [ ] Cito os três requisitos técnicos de um PWA.
- [ ] Explico o que o navegador faz quando o usuário aceita instalar.
- [ ] Justifico a escolha do PWA como canal principal com quatro argumentos.
- [ ] Listo pelo menos cinco limitações reais do PWA.
- [ ] Digo dois tipos de app para os quais PWA é a escolha errada.
- [ ] Explico por que "atualização automática" e "usuário preso na versão velha" são o mesmo tema.
- [ ] Sei quais pacotes do Foco quebram, quais mudam de comportamento e qual não muda.
- [ ] Explico por que a URL funciona como identidade do app.
- [ ] Preencho a matriz de decisão de canal para um app novo.
- [ ] Escrevo um ADR com contexto, decisão, alternativas, consequências e gatilho de revisão.

---

## 📚 Referências oficiais

- [Build a web application with Flutter — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/building)
- [Web support for Flutter — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web)
- [Progressive web apps — web.dev](https://web.dev/explore/progressive-web-apps)
- [What does it take to be installable? — web.dev](https://web.dev/articles/install-criteria)
- [Web app manifest — MDN](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Manifest)
- [Architecture decision records — adr.github.io](https://adr.github.io/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Como o Flutter compila para web](02-como-o-flutter-compila-para-web.md) |
