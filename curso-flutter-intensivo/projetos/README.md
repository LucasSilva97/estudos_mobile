# Projetos práticos

O curso tem três projetos, e não um só, por uma razão simples: cada um consolida uma faixa de
módulos **no momento em que ela acaba de ser aprendida**. Um projeto grande no fim seria uma prova
de resistência; três projetos no meio do caminho são três oportunidades de descobrir o que você
achava que tinha entendido.

A dificuldade cresce junto com o que você já sabe. O Projeto 1 proíbe até `Navigator` — não por
simplicidade, mas porque estado com `setState` numa tela só é exatamente o que o módulo 05 ensinou,
e é isso que precisa estar firme antes de acrescentar qualquer coisa.

---

## 🗺️ Os três

| Projeto | O que é | Quando fazer | Tempo | Consolida |
|---|---|---|---:|---|
| [**1 — Meu Primeiro App**](01-projeto-iniciante/README.md) | Contador de sessões de estudo com tema claro/escuro. Sem nenhum pacote externo | Após o módulo 05 | 2 h | M05, parte do M06 |
| [**2 — Bloco de Notas de Estudo**](02-projeto-intermediario/README.md) | Notas com título, conteúdo e etiqueta. Várias telas, formulário validado, dados que sobrevivem ao fechamento | Após o módulo 07 | 7 h | M05, M06, M07, M10 (aula 2), M12 (aulas 5 e 6) |
| [**3 — Foco: Organizador de Estudos**](03-projeto-final-multiplataforma/README.md) | O app final: 5 telas, sqflite, API, Riverpod, testes e build assinado | Após o módulo 16 | 12–16 h | M05 a M16 |

---

## 📈 A progressão

```text
P1 ── uma tela, setState, layout, tema
 │    sem pacote, sem navegação, sem persistência, sem async
 │
 ▼
P2 ── + várias telas e rotas nomeadas
 │    + formulário com validação
 │    + shared_preferences guardando JSON
 │    + os primeiros testes
 │    ainda sem Riverpod, ainda sem banco
 │
 ▼
P3 ── + arquitetura feature-first
      + sqflite com migrações
      + Riverpod sem codegen
      + API com cache e modo offline
      + acessibilidade e desempenho medidos
      + testes nos três níveis
      + build assinado nas duas lojas
```

Repare no que **não** aparece cedo. Riverpod só entra no Projeto 3 porque o módulo 08 vem depois
do Projeto 2 — e usar a ferramenta antes de entender o problema que ela resolve é a forma mais
rápida de aprender a decorar em vez de decidir.

---

## 📂 Como cada projeto é organizado

Os projetos 1 e 2 seguem o mesmo padrão de seis arquivos numerados:

| Arquivo | Papel | Quando usar |
|---|---|---|
| `01-especificacao.md` | O que o app deve fazer, com requisitos numerados | **Leia primeiro, inteiro** |
| `02-passo-a-passo.md` | A construção guiada, etapa por etapa | **Construa com ele aberto** |
| `03-codigo-completo.md` | Todos os arquivos finais | **Confira depois**, nunca antes |
| `04-testes.md` | Como validar o que você fez | Ao terminar |
| `05-desafios.md` | Extensões opcionais | Depois de passar no checklist |
| `06-checklist.md` | Os critérios de "pronto" | Antes de declarar terminado |

O Projeto 3 é maior e troca o passo a passo único por **oito etapas** (arquivos 03 a 10), mais
uma página de arquitetura, critérios de aceite e checklist separados.

**A ordem certa:**

```text
01 especificação  →  02 passo a passo  →  04 testes  →  06 checklist  →  05 desafios
                            ↑                                               ↓
                     03 código completo                          gabarito dos desafios
                     (só para conferir)                          (só depois de tentar)
```

---

## ⚠️ O erro que estraga um projeto

**Abrir o `03-codigo-completo.md` antes de construir com o `02-passo-a-passo.md`.**

O código pronto à vista transforma o projeto em transcrição. Você termina com um app que funciona
e com a sensação de ter aprendido — mas sem ter passado por nenhum erro, que é onde o aprendizado
realmente acontece. Uma semana depois, refazendo do zero, nada sai.

O `03` existe para responder "por que o meu não funciona?" depois de você ter tentado, e para
mostrar decisões de organização que o passo a passo não teria como destacar. Use nessa ordem.

O mesmo vale para os gabaritos dos desafios: eles comparam, não substituem a tentativa.

---

## 🔑 Gabaritos dos desafios

| Projeto | Gabarito |
|---|---|
| 1 — Meu Primeiro App | [projeto-01-desafios.md](../gabaritos/projeto-01-desafios.md) |
| 2 — Bloco de Notas de Estudo | [projeto-02-desafios.md](../gabaritos/projeto-02-desafios.md) |
| 3 — Foco | [projeto-03-desafios.md](../gabaritos/projeto-03-desafios.md) |

---

## 🪟 Sobre o ambiente

Os três projetos rodam por completo no **Windows 11**, em emulador ou aparelho Android. A única
parte que exige um Mac é gerar o `.ipa` do Projeto 3 — e mesmo essa tem alternativa por CI com
runner macOS, tratada no [módulo 16, aula 4](../modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md).

---

[Curso](../README.md) · [Plano intensivo](../01-plano-intensivo.md) · [Trilha de progresso](../03-trilha-de-progresso.md)
