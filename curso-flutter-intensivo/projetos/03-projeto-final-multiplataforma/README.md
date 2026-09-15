# Projeto Final — Foco: Organizador de Estudos

Este é o app que o curso inteiro construiu. Desde o módulo 05, cada aula usou o mesmo domínio —
matérias, sessões de estudo, metas semanais, trilhas — em pedaços separados. Aqui eles se juntam
num app único, testado e publicável.

**Pasta:** `foco` · **Pacote:** `br.com.estudos.foco`

---

## 🎯 O que você entrega

Ao fim das oito etapas, você tem um aplicativo que:

- Roda em **Android e iOS** com o mesmo código, em Material 3
- Guarda tudo em **sqflite**, com migrações versionadas e sem perder dado em atualização
- Cronometra sessões por **diferença de `DateTime`** — voltar do segundo plano não perde tempo
- Busca trilhas de uma **API pública**, com cache de 6 h e funcionamento **completo sem rede**
- Gerencia estado com **Riverpod sem code generation**, em arquitetura feature-first
- Passa nas **quatro diretrizes de acessibilidade**, com 200% de fonte sem estourar
- Tem testes nos **três níveis** e `analyze` sem um único aviso
- Gera **AAB assinado** e **IPA**, com os símbolos arquivados para crashes legíveis

---

## ⏱️ Tempo e pré-requisitos

| | |
|---|---|
| **Tempo total** | 12 a 16 h, distribuídas em 3 dias no plano intensivo |
| **Módulos necessários** | 05 a 16 concluídos |
| **Projetos anteriores** | [Projeto 1](../01-projeto-iniciante/README.md) e [Projeto 2](../02-projeto-intermediario/README.md) — não são obrigatórios, mas quem os fez chega aqui muito mais rápido |
| **Ambiente** | Windows 11 + Android. 🍎 O iOS exige Mac ou CI com runner macOS |

> ⚠️ **Não comece pelo projeto final.** Ele assume que você já escreveu widget com estado, navegou
> entre telas e leu de um banco. Se alguma dessas coisas ainda parece nova, os projetos 1 e 2
> custam 9 horas e economizam muito mais que isso aqui.

---

## 🗺️ As oito etapas

Cada etapa deixa o app **rodando**. Você nunca fica com código quebrado entre uma e outra.

| # | Etapa | O que constrói | Tempo | Aplica |
|---|---|---|---:|---|
| 1 | [Fundação](03-etapa-1-fundacao.md) | Projeto, tema, pastas, rotas | 1 h | M05, M06, M07 |
| 2 | [Domínio e dados](04-etapa-2-dominio-e-dados.md) | Modelos, banco, DAOs, migrações | 2,5 h | M03, M04, M10 |
| 3 | [Estado com Riverpod](05-etapa-3-estado-com-riverpod.md) | Notifiers, providers, injeção | 2 h | M08 |
| 4 | [Telas e navegação](06-etapa-4-telas-e-navegacao.md) | As 5 telas, formulários, 4 estados | 3,5 h | M06, M07 |
| 5 | [API e trilhas](07-etapa-5-api-e-trilhas.md) | HTTP, DTO, cache, offline | 2 h | M09 |
| 6 | [Responsividade e acessibilidade](08-etapa-6-responsividade-e-acessibilidade.md) | Telas grandes, leitores de tela | 1,5 h | M06, M13 |
| 7 | [Testes](09-etapa-7-testes.md) | Unitário, widget, integração | 2 h | M12 |
| 8 | [Ícone, splash e versão](10-etapa-8-icone-splash-e-versao.md) | Identidade e preparo de build | 1,5 h | M14, M15 |

---

## 📂 Todos os arquivos

| Arquivo | Para quê | Quando ler |
|---|---|---|
| [01 — Especificação](01-especificacao.md) | Os 20 RF e 20 RNF, modelo de dados, esquema do banco | **Primeiro**, inteiro |
| [02 — Arquitetura](02-arquitetura.md) | Camadas, árvore de pastas, as decisões e o porquê | Logo depois |
| [03 a 10 — As oito etapas](03-etapa-1-fundacao.md) | A construção guiada | Uma por vez, na ordem |
| [11 — Critérios de aceite](11-criterios-de-aceite.md) | Como saber que está pronto, com o gesto exato | Ao fim de cada etapa e no final |
| [12 — Desafios](12-desafios.md) | 10 extensões opcionais | Depois de o app passar no aceite |
| [13 — Checklist](13-checklist.md) | Verificação por etapa, com onde revisar | Durante, sempre que travar |
| [🔑 Gabarito dos desafios](../../gabaritos/projeto-03-desafios.md) | Soluções comentadas | Só depois de tentar |

---

## 🧰 O que você vai precisar

| Item | Observação |
|---|---|
| Flutter 3.47.1 e Dart 3.13.1 | As versões do curso |
| Android Studio + um emulador ou aparelho | Suficiente para as etapas 1 a 7 |
| Conta na Play Console | Só se for publicar de verdade (US$ 25, uma vez) |
| 🍎 Mac com Xcode | Só para gerar o IPA. Alternativa: CI com runner macOS |
| 🍎 Apple Developer Program | Só para TestFlight e App Store (US$ 99/ano) |

> 💡 **Você chega ao fim da etapa 8 sem gastar nada** e com o app funcionando nas duas
> plataformas. As contas pagas só entram quando você decidir publicar.

---

## 🚦 Como saber que terminou

Dois documentos, com papéis diferentes:

- **Durante a construção** → [13-checklist.md](13-checklist.md), que acompanha etapa por etapa e
  aponta onde revisar quando algo falha.
- **Ao declarar pronto** → [11-criterios-de-aceite.md](11-criterios-de-aceite.md), que mede o
  produto contra os 40 requisitos, com o gesto exato de verificação de cada um.

> 📌 Os dois critérios que mais reprovam são o **RF10** (cronômetro somando ticks em vez de usar
> diferença de `DateTime`) e o **RF13** (sessão gravada fora de transação, deixando o total da
> matéria divergente). Vale conferir esses dois com atenção extra.

---

| 🏠 Projetos | ▶️ Começar | 📅 Plano |
|---|---|---|
| [Índice dos projetos](../README.md) | [01 — Especificação](01-especificacao.md) | [Plano intensivo](../../01-plano-intensivo.md) |
