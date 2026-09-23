# Aula 6 — Próximos passos

> **Módulo:** 17 - Publicação e próximos passos · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Reconhecer, com precisão, **o que você sabe fazer** ao fim deste curso.
- Identificar as **lacunas reais** — o que o curso deliberadamente não cobriu.
- Escolher um **caminho de aprofundamento** com critério, e não por modismo.
- Montar um **plano de 90 dias** concreto, com entregáveis verificáveis.
- Saber **onde perguntar** quando travar, e como perguntar bem.
- Entender como o mercado brasileiro avalia quem programa em Flutter.

## ✅ Pré-requisitos

- [Aula 5 — Monitoramento e feedback](05-monitoramento-e-feedback.md).
- Idealmente: o projeto **Foco** publicado, ao menos numa faixa de teste.
- Um pouco de honestidade para o autodiagnóstico da primeira seção.

---

## 📖 Conceito

### O que você sabe fazer agora

Não é retórica de encerramento — é um inventário. Depois de 17 módulos:

| Você consegue | Módulo |
|---|---|
| Ler e escrever Dart com tipos, `null safety`, `sealed`, `records` | 01–04 |
| Construir qualquer layout com widgets, responsivo e adaptativo | 05–06 |
| Navegar, validar formulários e tratar teclado e foco | 07 |
| Gerenciar estado com Riverpod e organizar em **feature-first** | 08 |
| Consumir API com camada de dados testável, timeout e retry | 09 |
| Persistir em sqflite com migrações, e proteger dado sensível | 10 |
| Usar recursos nativos e respeitar as diferenças entre plataformas | 11 |
| Testar em três níveis e depurar nas duas plataformas | 12 |
| Medir desempenho, tornar acessível e proteger o app | 13 |
| Assinar e publicar no Android | 14 |
| Assinar e publicar no iOS — **inclusive sem um Mac** | 15 |
| Versionar, automatizar e monitorar em produção | 16 |

> 📌 **Isso é mais do que a maioria das vagas júnior exige** — e, em algumas áreas (publicação,
> assinatura, CI), mais do que muita pessoa pleno domina, porque são assuntos que se aprende só na
> hora do aperto.

Se alguma linha da tabela te deu dúvida, ela aponta o módulo a revisitar. Um curso terminado não é
um curso memorizado.

### O que este curso não cobriu

Ser explícito sobre as lacunas vale mais que fingir completude:

| Não coberto | Quando você vai precisar |
|---|---|
| **Animações avançadas** | Quando a UI precisar de personalidade |
| `CustomPainter`, shaders | Gráficos e visualizações próprias |
| **Internacionalização (i18n)** | Mais de um idioma |
| Firebase além do Crashlytics | Auth, Firestore, Functions |
| **Backend próprio** | Quando a API for sua |
| Deep links e App Links | Abrir o app por um link |
| Pagamentos no app | Monetização |
| **Testes de ouro** (golden) | Regressão visual |
| Push na web e *background sync* | Notificações sem o app aberto |
| Flutter desktop (Windows, macOS, Linux) | Outras plataformas |
| Melos, monorepo | Vários pacotes |
| Arquitetura para equipes grandes | Vários times no mesmo código |

> 💡 **Nenhum desses é pré-requisito para publicar um app bom.** Eles entram quando o problema
> aparece — e a habilidade que o curso realmente treinou é a de aprender assunto novo lendo a
> documentação oficial, não a de já saber tudo.

### Os quatro caminhos

Depois deste curso, há quatro direções razoáveis. Elas não competem — mas tentar as quatro ao mesmo
tempo é a receita para não avançar em nenhuma.

**1. Aprofundar em Flutter**

| O quê | Por quê |
|---|---|
| Animações e `CustomPainter` | É o que separa app funcional de app memorável |
| Internacionalização | Abre o mercado internacional |
| Testes de ouro | Regressão visual automática |
| Performance avançada, Impeller | Apps grandes |

**2. Ir para o backend**

| O quê | Por quê |
|---|---|
| Uma linguagem de servidor (Dart, Node, Go, Python) | Parar de depender de API alheia |
| Banco relacional, SQL de verdade | O que o sqflite só arranhou |
| Autenticação, JWT no servidor | Módulo 09, do outro lado |
| Deploy, Docker | Colocar no ar |

> 💡 **Quem sabe front e back mobile ocupa um espaço raro.** Você já entende o lado do cliente; o
> backend é o outro metade da mesma conversa — e a pessoa que entende os dois toma decisões
> melhores nos dois.

**3. Especializar em mobile nativo**

| O quê | Por quê |
|---|---|
| Kotlin + Jetpack Compose | Android profundo |
| Swift + SwiftUI | iOS profundo |
| Plugins Flutter próprios | A ponte entre os dois mundos |

**4. Construir um produto**

| O quê | Por quê |
|---|---|
| O seu app, com usuários de verdade | Aprende o que nenhum curso ensina |
| Descoberta, monetização, suporte | Nada disso é código |

> 📌 **O caminho 4 é o mais subestimado.** Manter um app com cem usuários reais ensina mais sobre
> engenharia de software do que três cursos — porque os problemas que aparecem são os que nenhum
> exercício consegue simular.

### Como escolher

| Se você quer | Caminho |
|---|---|
| Emprego como dev mobile, rápido | 1 + portfólio |
| Ser desenvolvedor mais completo | 2 |
| Trabalhar em app de grande escala | 3 |
| Empreender | 4 |
| Não sabe | ⚠️ **4**, por três meses |

> 💡 **Na dúvida, construa algo.** Um projeto real revela, em semanas, qual dos outros caminhos você
> quer seguir — e a resposta obtida assim é muito mais confiável do que a obtida pensando.

### O mercado brasileiro

Sem promessas, e com os números que se pode verificar:

| | Realidade |
|---|---|
| Flutter no Brasil | Adoção alta, especialmente em startups e bancos |
| Vagas júnior | ⚠️ Concorridas; pedem portfólio |
| O que diferencia | **App publicado** > certificados |
| Testes no currículo | ⚠️ Raro, e muito valorizado |
| CI/CD no currículo | Idem |
| Inglês | Amplia muito as opções |
| Remoto internacional | Exige inglês e portfólio sólido |

> 📌 **Um app publicado, com código no GitHub e testes, vale mais que qualquer certificado** — o
> curso inteiro incluído. Ele é verificável: o recrutador instala, abre, e vê. Nenhum certificado
> permite isso.

E o que mais se destaca numa entrevista técnica júnior:

| Diferencia | Por quê |
|---|---|
| Saber **por que** você escolheu Riverpod | Mostra critério, não decoreba |
| Ter testes no projeto | Quase ninguém tem |
| Saber explicar um bug que você resolveu | Mostra método |
| Ter publicado nas duas lojas | Mostra persistência |
| Saber o que **não** sabe | Mostra maturidade |

### Onde perguntar

| Onde | Para quê |
|---|---|
| **docs.flutter.dev** | ✅ A resposta certa, quase sempre |
| **api.flutter.dev** | A referência da API |
| Stack Overflow | Erros específicos |
| r/FlutterDev | Discussão e novidades |
| Flutter Brasil (Discord, Telegram) | Português, gente acessível |
| GitHub Issues do Flutter | Bugs do framework |
| Flutter Awesome, pub.dev | Descobrir pacotes |

> ⚠️ **Cuidado com material antigo.** O Flutter muda rápido: `WillPopScope` virou `PopScope`,
> `MaterialStateProperty` virou `WidgetStateProperty`, o bitcode sumiu, o Impeller substituiu o
> Skia. Um tutorial de 2021 pode ensinar coisas que **não existem mais**. A documentação oficial é a
> única fonte que acompanha.

### Como perguntar bem

```text
❌ "Meu app não funciona, alguém ajuda?"

✅ "Ao abrir a tela de detalhe, recebo
   'RangeError (index): Invalid value: Not in range 0..2: 3'.
   Acontece só quando a lista tem 3 itens ou menos.
   Flutter 3.47.1, Android 14.
   Já tentei: verificar o itemCount, imprimir o tamanho da lista.
   Código: <link para um gist mínimo que reproduz>"
```

| Um bom pedido tem | Por quê |
|---|---|
| A mensagem de erro **exata** | É a informação principal |
| Quando acontece | Delimita o problema |
| O que você já tentou | Evita respostas repetidas |
| Código mínimo que reproduz | Permite ajudar de verdade |
| Versões | O comportamento muda entre elas |

> 💡 **Montar o exemplo mínimo resolve o problema sozinho, com frequência surpreendente.** Ao
> reduzir o caso, você isola a causa — e metade das perguntas que começamos a escrever nunca é
> enviada.

---

## 💡 Analogia

Pense em **aprender a dirigir**.

- **O curso acabou.** Você tirou a carteira: sabe embreagem, câmbio, baliza, sinalização, e já foi
  à rua com o instrutor. Tecnicamente, você dirige.
- **E todo motorista sabe o que vem depois:** você ainda não dirige de verdade. Dirigir de verdade
  começa no primeiro dia sozinho, na chuva, num cruzamento que você não conhece, com alguém buzinando
  atrás.
- **É por isso que "construa algo" é a recomendação.** Nenhuma aula simula o cruzamento
  desconhecido. Um app com usuários de verdade é a rua.
- **Os quatro caminhos** são para onde você vai dirigir: cidade (aprofundar em Flutter), estrada
  (backend), fora de estrada (nativo), ou fazer disso profissão (produto). Quem tenta os quatro no
  mesmo mês não chega a lugar nenhum.
- **O material antigo** são as placas de uma rua que mudou de sentido. Ainda estão lá, ainda
  parecem oficiais — e seguir uma delas dá na contramão. A documentação oficial é o mapa que
  atualiza.
- **E perguntar bem** é descrever o barulho do motor em vez de dizer "está estranho". O mecânico
  precisa de "um tinido metálico, só em subida, acima de 3 000 giros". E, com frequência, é ao
  descrever com esse cuidado que você percebe sozinho o que era.

---

## 🧪 Exemplo mínimo

Um autodiagnóstico honesto, em cinco minutos.

**Para cada item, responda sem consultar nada:**

```text
1. Explico a diferença entre StatelessWidget e StatefulWidget,
   e quando o `build` roda?                          [ ] sim  [ ] não

2. Sei por que este curso usa Riverpod sem codegen?  [ ] sim  [ ] não

3. Escrevo um teste de widget com pump e finders?    [ ] sim  [ ] não

4. Sei o que faz `--obfuscate` — e o que NÃO faz?    [ ] sim  [ ] não

5. Sei por que o iOS rejeita ícone com transparência?[ ] sim  [ ] não

6. Explico o que acontece se eu perder o keystore?   [ ] sim  [ ] não

7. Sei a diferença entre versionName e versionCode?  [ ] sim  [ ] não

8. Sei por que `async` não impede o app de travar?   [ ] sim  [ ] não

9. Sei o que é um provisioning profile?              [ ] sim  [ ] não

10. Sei ler o gráfico de frames e dizer se o problema
    é de UI ou de raster?                            [ ] sim  [ ] não
```

| Acertos | Leitura |
|---|---|
| 9–10 | ✅ O curso ficou. Escolha um caminho. |
| 6–8 | ✅ Bom. Revise os módulos dos "não". |
| 3–5 | ⚠️ Refaça os módulos correspondentes — o material está aí. |
| 0–2 | ⚠️ Vale recomeçar do módulo 05, praticando. |

> 📌 **Um "não" não é reprovação — é um endereço.** Cada pergunta aponta um módulo específico, e
> voltar a ele agora, com o contexto do curso inteiro na cabeça, rende muito mais do que rendeu na
> primeira leitura.

---

## 📱 Aplicando no Flutter

O plano de 90 dias — o entregável desta aula.

---

## 💻 Código completo

> **Arquivo:** `docs/plano-90-dias.md` (novo)

```markdown
# Plano de 90 dias — depois do curso

**Início:** AAAA-MM-DD
**Caminho escolhido:** <1 Flutter | 2 Backend | 3 Nativo | 4 Produto>
**Por quê:** <uma frase; ela te lembra da decisão quando bater dúvida>

---

## Mês 1 — Consolidar

**Objetivo:** transformar o que foi lido em algo que funciona.

### Entregável
Um app **seu**, publicado numa faixa de teste, diferente do Foco.

### Semana 1–2
- [ ] Escolher a ideia. Regra: **resolve um problema seu**.
      Um app que você mesmo usa toda semana gera as melhores
      decisões de produto, porque você é o usuário.
- [ ] Modelar o domínio em Dart puro, com testes (módulo 12)
- [ ] Definir a arquitetura feature-first (módulo 08)

### Semana 3–4
- [ ] Telas principais, com os 4 estados de UI (módulo 06)
- [ ] Persistência local (módulo 10)
- [ ] Publicar na faixa interna do Android (módulo 15)

### Verificação — não vale "quase"
- [ ] O app instala num aparelho que não é o seu
- [ ] Tem pelo menos 20 testes passando
- [ ] `flutter analyze` sem avisos
- [ ] Alguém além de você usou

---

## Mês 2 — Aprofundar

**Objetivo:** ir fundo no caminho escolhido.

### Se caminho 1 — Flutter
- [ ] Animações: implícitas, explícitas, `Hero`
- [ ] `CustomPainter`: um gráfico feito do zero
- [ ] Internacionalização com `flutter_localizations`
- [ ] Testes de ouro para as telas principais

### Se caminho 2 — Backend
- [ ] Uma API REST com autenticação, na linguagem escolhida
- [ ] Banco relacional com migrações de verdade
- [ ] Deploy num servidor acessível pela internet
- [ ] O seu app do mês 1 consumindo **a sua** API

### Se caminho 3 — Nativo
- [ ] Kotlin básico + um app em Jetpack Compose
- [ ] Um plugin Flutter próprio, com código nativo
- [ ] Platform channels nos dois sentidos

### Se caminho 4 — Produto
- [ ] Publicar em produção, nas duas lojas
- [ ] Os 10 primeiros usuários que não são seus conhecidos
- [ ] Monitoramento completo (módulo 17, aula 5)
- [ ] Um ciclo de feedback → release → medição

### Verificação
- [ ] Algo funcionando, não só estudado
- [ ] No GitHub, público
- [ ] Um README que explica **as decisões**, não só os comandos

---

## Mês 3 — Consolidar e mostrar

**Objetivo:** tornar verificável o que você sabe.

### Portfólio
- [ ] 2 ou 3 projetos no GitHub, com README de verdade
- [ ] Pelo menos um publicado numa loja
- [ ] Testes visíveis em todos
- [ ] CI configurado (módulo 17, aula 4)

### Currículo
- [ ] Links para os apps publicados **no topo**
- [ ] "Publiquei X na Play Store e na App Store" — verificável
- [ ] Mencionar testes e CI: quase ninguém menciona

### Prática de entrevista
- [ ] Explicar em voz alta a arquitetura do seu app (5 min)
- [ ] Explicar **por que** Riverpod, e não outra coisa
- [ ] Contar um bug difícil que você resolveu, e **como**
- [ ] Dizer o que você não sabe, sem desconforto

### Verificação final
- [ ] Um estranho instala o seu app e entende o que ele faz
- [ ] Outro desenvolvedor clona o repo e roda em 5 minutos
- [ ] Você explica qualquer decisão do código

---

## Rotina semanal

| Dia | O quê | Tempo |
|---|---|---|
| Seg–Sex | Código no projeto | 1 h |
| Sáb | Estudo do caminho escolhido | 2 h |
| Dom | Revisão: o que travou? o que aprendi? | 30 min |

> **8 horas por semana.** Menos que isso, os 90 dias não rendem
> o que este plano promete. Mais que isso sem descanso não se
> sustenta por três meses — e o plano é de três meses.

---

## Revisão mensal

| Mês | Entreguei? | O que travou | Ajuste |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |

---

## Regra de honestidade

Se ao fim de um mês o entregável não existe, **o problema não é
falta de tempo** — é escopo grande demais ou objetivo vago.
Corte o escopo pela metade e siga. Um app pequeno publicado vale
mais que um app ambicioso pela metade.
```

E o modelo de README que faz diferença no portfólio:

> **Arquivo:** `README.md` (modelo)

```markdown
# Foco — Organizador de Estudos

App para registrar sessões de estudo e acompanhar metas semanais.

[Google Play](link) · [App Store](link)

<img src="docs/capturas/lista.png" width="200">
<img src="docs/capturas/resumo.png" width="200">

## Por que existe

<Uma frase sobre o problema que ele resolve. Um README que começa
com "app feito em Flutter" não diz nada a ninguém.>

## Decisões técnicas

> ⭐ Esta seção é a que separa um portfólio de uma pasta de código.
> Qualquer pessoa cola widgets; poucas explicam POR QUE.

| Decisão | Alternativa considerada | Por quê |
|---|---|---|
| Riverpod sem codegen | Provider, Bloc | Sem `build_runner`; testável com `ProviderContainer` |
| Navigator + `onGenerateRoute` | go_router | App com poucas rotas; menos dependência |
| sqflite | Hive, Isar | SQL de verdade, migrações explícitas |
| Material 3 nas duas plataformas | Cupertino no iOS | Identidade única; `.adaptive` onde importa |

## Arquitetura

\`\`\`
lib/
├── core/                    # o que é compartilhado
└── features/<x>/
    ├── domain/              # regras — Dart puro, sem Flutter
    ├── data/                # repositórios e fontes
    └── presentation/        # telas e widgets
\`\`\`

A regra de dependência aponta para dentro: `presentation` conhece
`domain`; `domain` não conhece ninguém.

## Como rodar

\`\`\`bash
flutter pub get
flutter run
\`\`\`

## Testes

\`\`\`bash
flutter test               # 87 testes
flutter test --coverage
\`\`\`

| Nível | Quantidade |
|---|---|
| Unitário | 62 |
| Widget | 21 |
| Integração | 4 |

## O que eu aprendi

<Seção honesta: o que foi difícil, o que você faria diferente.
Recrutador lê isto. E ela mostra algo que nenhuma outra seção
mostra: capacidade de avaliar o próprio trabalho.>
```

```powershell
# Comece hoje:
mkdir docs
# copie o plano-90-dias.md, preencha a primeira seção
git add docs/plano-90-dias.md
git commit -m "docs: plano de 90 dias"
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| "Por quê" do caminho escolhido | Uma frase que te lembra da decisão quando bater dúvida no mês 2. |
| "Resolve um problema seu" | Você é o usuário: as decisões de produto ficam muito melhores. |
| Entregável por mês, não "estudar X" | "Estudar animações" não tem fim; "publicar um app" tem. |
| Verificações objetivas | "Instala num aparelho que não é o seu" não admite "quase". |
| Caminhos separados no mês 2 | Tentar os quatro é não avançar em nenhum. |
| "No GitHub, público" | O que não é verificável não conta no portfólio. |
| Prática de entrevista em voz alta | Explicar é uma habilidade separada de saber. |
| "Dizer o que não sabe sem desconforto" | Diferencia mais que decorar respostas. |
| 8 h/semana explicitadas | Sem número, o plano vira intenção. |
| **Regra de honestidade** | Escopo grande é a causa real de plano abandonado. |
| Seção "Decisões técnicas" no README | **O que separa portfólio de pasta de código.** |
| Coluna "alternativa considerada" | Mostra critério, não decoreba. |
| Seção "o que eu aprendi" | Mostra capacidade de avaliar o próprio trabalho. |
| Links das lojas no topo | É o que o recrutador clica primeiro. |

---

## 🤖🍎 Android × iOS

Um último resumo das diferenças que o curso inteiro mostrou — porque elas explicam a maior parte das
decisões que você vai tomar:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Custo de publicar | US$ 25, uma vez | **US$ 99/ano** |
| Desenvolver no Windows | ✅ | ❌ (ou CI) |
| Distribuir fora da loja | ✅ APK | ❌ |
| Revisão da loja | Automática, horas | **Humana, dias** |
| Rollback | ✅ | ❌ |
| Assinatura | 1 keystore, 27 anos | 5 peças, 1 ano |
| Perder a chave | ⚠️ Fatal sem Play App Signing | ✅ Recuperável |
| Texto de permissão | ❌ Não existe | ✅ Obrigatório |
| Divisão por aparelho | AAB (você escolhe) | Automática |
| Mensagem de erro no build | Longa, mas **diz o quê** | Curta e genérica |

> 📌 **Se houvesse uma só lição para levar deste curso, seria esta:** as duas plataformas resolvem
> os mesmos problemas com filosofias opostas — o Android prioriza liberdade e simplicidade, o iOS
> prioriza controle e rede de proteção. **Nenhuma das duas está errada.** Saber disso evita
> frustração: você para de esperar que o iOS funcione como o Android, e começa a trabalhar com o que
> cada um é.

---

## ⚠️ Erros comuns

### 1. Parar de programar ao acabar o curso

Conhecimento sem prática se perde em semanas.

**Correção:** um projeto começando **esta semana**.

### 2. Escolher os quatro caminhos

Nenhum avança.

**Correção:** um, por 90 dias.

### 3. Projeto ambicioso demais

Nunca fica pronto, e desanima.

**Correção:** corte o escopo pela metade.

### 4. Estudar sem entregar

"Estudei animações" não é verificável.

**Correção:** entregável por mês.

### 5. Portfólio sem README

O recrutador não entende o que é.

**Correção:** decisões técnicas explicadas.

### 6. Projeto sem testes

Quase ninguém tem — e é justamente por isso que diferencia.

**Correção:** teste desde o primeiro dia.

### 7. Seguir tutorial antigo

`WillPopScope`, `MaterialStateProperty`, bitcode — nada disso existe mais.

**Correção:** documentação oficial.

### 8. Perguntar mal

"Não funciona" não recebe resposta.

**Correção:** erro exato, contexto, código mínimo.

### 9. Não publicar "porque não está bom"

Nunca vai estar.

**Correção:** publique na faixa de teste.

### 10. Esconder o que não sabe

Numa entrevista, isso aparece.

**Correção:** dizer com naturalidade diferencia.

### 11. Colecionar certificados

Um app publicado vale mais.

**Correção:** construa.

### 12. Comparar-se com quem começou antes

Compara o seu mês 3 com o ano 5 de alguém.

**Correção:** compare com o seu mês 1.

---

## 🛠️ Exercício guiado

**Passo 1.** Responda o autodiagnóstico das dez perguntas, **sem consultar**. Qual foi o resultado?

**Passo 2.** Para cada "não", anote o módulo correspondente. Revise um deles esta semana.

**Passo 3.** Leia a lista do que o curso não cobriu. O que você quer aprender primeiro?

**Passo 4.** Escolha **um** dos quatro caminhos. Escreva a frase do "por quê".

**Passo 5.** Crie `docs/plano-90-dias.md` e preencha o mês 1 inteiro.

**Passo 6.** Defina a ideia do seu app. Ela resolve um problema **seu**?

**Passo 7.** Corte o escopo dela pela metade. Ainda faz sentido?

**Passo 8.** Escreva o README do projeto **antes** de começar o código — inclusive as decisões
técnicas.

**Passo 9.** Marque as três revisões mensais no seu calendário, agora.

**Passo 10.** Escreva o primeiro commit do projeto novo. Hoje.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/17-publicacao-e-proximos-passos.md](../../exercicios/17-publicacao-e-proximos-passos.md)

Faça os de **Reflexão** — nesta aula, eles são o conteúdo.

---

## 🏆 Desafio opcional

**Publique um app seu, diferente do Foco, nos próximos 90 dias.**

Requisitos:

- Resolve um problema que **você** tem.
- Feito com o que este curso ensinou: feature-first, Riverpod, testes, persistência.
- Pelo menos 30 testes, nos três níveis.
- CI configurado, rodando a cada push.
- Publicado, ao menos numa faixa de teste, numa das lojas.
- README com as decisões técnicas explicadas.
- Monitoramento configurado, com os símbolos enviados.
- **Dez pessoas usando** — que não sejam da sua família.

Depois responda: o que foi mais difícil — o código, a publicação, ou conseguir as dez pessoas? A
resposta dessa pergunta costuma ser a mais reveladora sobre o que você deve estudar em seguida.

---

## 📌 Resumo

- Você sabe **construir, testar, publicar e monitorar** um app nas duas plataformas.
- Isso é **mais do que a maioria das vagas júnior exige** — e, em publicação e CI, mais do que muita
  pessoa pleno domina.
- O curso **não cobriu**: animações avançadas, i18n, backend, deep links, pagamentos, desktop.
  Nenhum deles é pré-requisito para publicar um app bom. **A web, sim, foi coberta** — é o canal
  principal, no [Módulo 14](../14-build-web-pwa/README.md).
- Quatro caminhos: **aprofundar em Flutter**, **backend**, **nativo**, **produto**. Escolha **um**.
- **Na dúvida, construa algo.** Três meses de projeto real respondem melhor que três meses pensando.
- **Um app publicado vale mais que qualquer certificado** — porque é verificável.
- **Testes e CI no portfólio diferenciam**: quase ninguém tem.
- ⚠️ **Material antigo ensina coisas que não existem mais.** A documentação oficial é a fonte.
- **Perguntar bem** é metade da resposta — e montar o exemplo mínimo resolve o problema com
  frequência surpreendente.
- **Plano de 90 dias com entregável por mês**, verificações objetivas e 8 h por semana.
- **Se o entregável não existe ao fim do mês, o escopo era grande demais.** Corte pela metade.
- As duas plataformas resolvem os mesmos problemas com filosofias opostas. **Nenhuma está errada.**
- **Escreva o primeiro commit do próximo projeto hoje.**

---

## ☑️ Checklist de domínio

- [ ] Fiz o autodiagnóstico honestamente.
- [ ] Sei quais módulos preciso revisar.
- [ ] Sei o que o curso não cobriu.
- [ ] Escolhi **um** caminho, e sei por quê.
- [ ] Escrevi o plano de 90 dias.
- [ ] Defini o próximo projeto, com escopo cortado.
- [ ] Escrevi o README antes do código.
- [ ] Marquei as revisões mensais no calendário.
- [ ] Sei onde perguntar, e como.
- [ ] Sei desconfiar de material antigo.
- [ ] Fiz o primeiro commit do projeto novo.

---

## 📚 Referências oficiais

- [docs.flutter.dev](https://docs.flutter.dev/) — a fonte
- [api.flutter.dev](https://api.flutter.dev/) — a referência
- [dart.dev](https://dart.dev/) — a linguagem
- [Flutter Roadmap](https://github.com/flutter/flutter/wiki/Roadmap) — para onde vai
- [Flutter release notes](https://docs.flutter.dev/release/release-notes) — o que mudou
- [pub.dev](https://pub.dev/) — pacotes
- [Flutter Community — Medium](https://medium.com/flutter-community)
- [r/FlutterDev](https://www.reddit.com/r/FlutterDev/)

---

## 🎓 Encerramento

Você começou este curso sem saber o que era um widget. Termina sabendo assinar um binário, arquivar
símbolos de ofuscação e configurar um pipeline que publica em duas lojas.

O caminho entre uma coisa e outra teve dezessete módulos e cento e quarenta e oito aulas. Mas a
parte que importa não está em nenhuma delas: está no que você vai construir agora, quando não há
mais aula seguinte e o erro que aparecer não vem com uma seção de "erros comuns".

Foi para isso que existiu cada tabela de diagnóstico, cada "por quê" ao lado de um "como", e cada
aviso sobre o que a documentação oficial diz. **Não para você saber tudo — para você saber
procurar.**

Boa sorte. E publique.

---

| ⬅️ Anterior | 🏠 Módulo | 🏠 Curso |
|---|---|---|
| [Monitoramento e feedback](05-monitoramento-e-feedback.md) | [README](README.md) | [Início do curso](../../README.md) |
