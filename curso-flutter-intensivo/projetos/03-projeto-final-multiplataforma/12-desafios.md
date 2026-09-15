# Desafios — Projeto Final: Foco

> Opcionais, e só fazem sentido com o app base passando nos
> [critérios de aceite](11-criterios-de-aceite.md). Um desafio sobre um app que ainda não fecha
> os requisitos vira dois problemas em vez de um.

Estes desafios são o que separa "terminei o curso" de "sei construir". Vários exigem **combinar
módulos diferentes** — é justamente aí que o aprendizado sedimenta, porque nenhuma aula sozinha
responde.

Os dois últimos pedem algo que o curso **não cobriu**. Isso é de propósito: a habilidade que o
curso realmente treinou é a de resolver assunto novo lendo a documentação oficial.

---

<a id="p03-d01"></a>
## P03-D01 — Exportar as sessões em CSV · Fácil

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Gerar um arquivo e compartilhá-lo | Fácil | 45 min | 10, 11 |

Acrescente em `ConfiguracoesScreen` a ação **Exportar sessões**. Ela gera um CSV com
`data;materia;minutos;anotacao` de todas as sessões, grava em diretório temporário e abre a folha
nativa de compartilhamento.

**Esperado:** o arquivo abre no Excel com acentuação correta e as datas em `dd/MM/yyyy`.
Anotação com `;` ou quebra de linha não corrompe a coluna.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d01)

---

<a id="p03-d02"></a>
## P03-D02 — Busca com filtro por período · Fácil

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Consultar por texto e intervalo, no SQL | Fácil | 50 min | 07, 10 |

Na aba **Matérias**, acrescente um campo de busca e um filtro de período (7 dias, 30 dias, tudo).
A filtragem acontece **no SQL**, com `?` e `whereArgs` — nunca carregando tudo e filtrando em Dart.

**Esperado:** buscar `calc` encontra `Cálculo`; o filtro de 7 dias muda o total exibido; e a busca
não dispara uma consulta por tecla digitada (use *debounce*).

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d02)

---

<a id="p03-d03"></a>
## P03-D03 — Modo foco com bloqueio de saída · Média

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Impedir a perda acidental de uma sessão | Média | 50 min | 07, 11 |

Com o cronômetro rodando, sair da tela ou apertar o voltar do Android deve pedir confirmação —
"Você tem uma sessão em andamento. Descartar?" — com as opções **Continuar** e **Descartar**.

**Esperado:** `PopScope` com `canPop: false` e `onPopInvokedWithResult` enquanto contar; e voltar
livre quando o cronômetro estiver parado. 🍎 No iOS, o gesto de arrastar da borda também respeita.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d03)

---

<a id="p03-d04"></a>
## P03-D04 — Lembrete diário que lê a meta do banco · Média

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Notificação agendada, com permissão e dado real | Média | 70 min | 10, 11, 14 |

Agende uma notificação diária no horário que o usuário escolher. O texto precisa ler o estado
**real**: "Faltam 40 min para a sua meta de hoje" ou, se já bateu, "Meta batida! 320 min esta
semana".

**Esperado:** pede `POST_NOTIFICATIONS` no momento em que o usuário ativa o lembrete (nunca na
abertura), trata os quatro estados de permissão, e o texto reflete os minutos do dia. Negada para
sempre, o app abre as Configurações **explicando** o caminho.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d04)

---

<a id="p03-d05"></a>
## P03-D05 — Sequência de dias estudados · Média

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Regra de negócio testável sobre datas | Média | 60 min | 04, 10, 12 |

Calcule a **sequência atual** (dias consecutivos com pelo menos uma sessão) e o **recorde**.
Exiba no Painel. A regra vive no domínio, em Dart puro, e recebe o relógio por injeção.

**Esperado:** pelo menos 8 testes unitários cobrindo — sem sessão nenhuma, um dia só, sequência
que termina ontem (conta) × anteontem (não conta), virada de mês, e ano bissexto. Nenhum teste
que quebre amanhã.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d05)

---

<a id="p03-d06"></a>
## P03-D06 — Migração v2 → v3 sem perder dados · Difícil

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Evoluir o esquema com quem já tem dados | Difícil | 70 min | 10, 12 |

Acrescente à tabela `sessoes` a coluna `humor` (1 a 5, opcional) e à `materias` a coluna
`meta_semanal_minutos`. Escreva a migração da v2 para a v3 preservando **todos** os dados.

**Esperado:** um teste que abre o banco na v2, insere dados, fecha, reabre na v3 e prova que nada
se perdeu. E um teste do caminho de instalação limpa direto na v3.

> ⚠️ Este é o desafio que mais ensina: migração quebrada apaga os dados de **todos** os usuários
> existentes, de uma vez, com o app já publicado.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d06)

---

<a id="p03-d07"></a>
## P03-D07 — Sincronização offline-first com fila · Difícil

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Escrever offline e conciliar depois | Difícil | 90 min | 09, 10, 11 |

Crie uma fila de operações pendentes em tabela própria. Toda sessão registrada entra na fila;
quando houver conexão, ela é enviada em ordem e removida. Falha de rede mantém na fila; falha de
validação (4xx) remove e registra o motivo.

**Esperado:** registrar 3 sessões em modo avião, religar a rede e ver as 3 subirem **em ordem**.
Reabrir o app com a fila cheia não duplica envio. A distinção entre erro de rede (tentar de novo)
e erro de validação (desistir) está explícita no código.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d07)

---

<a id="p03-d08"></a>
## P03-D08 — Pipeline que publica nas duas faixas internas · Difícil

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Automatizar o release inteiro | Difícil | 90 min | 14, 15, 16 |

Monte um GitHub Actions que, ao criar uma tag `v*`, roda os portões, gera o AAB assinado e o IPA,
**arquiva os três conjuntos de símbolos** (Dart, `mapping.txt` e dSYM) e envia para a faixa interna
do Android e para o TestFlight.

**Esperado:** uma tag dispara tudo; os segredos vêm de *secrets* em base64; nenhuma senha aparece
no log; e o job falha se algum símbolo não for gerado.

> 💡 Este desafio é a única forma de gerar o IPA **sem ter um Mac**.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d08)

---

<a id="p03-d09"></a>
## P03-D09 — Gráfico próprio com `CustomPainter` · Difícil · ⚠️ fora do curso

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Desenhar o que nenhum widget entrega | Difícil | 90 min | 06, 13 + pesquisa |

Troque as barras da `EstatisticasScreen` por um gráfico desenhado com `CustomPainter`: linha de
minutos por dia, área preenchida com gradiente e um ponto destacado no dia de hoje.

**O curso não ensinou `CustomPainter`.** Comece pela documentação oficial de
[`CustomPainter`](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html) e de
[`Canvas`](https://api.flutter.dev/flutter/dart-ui/Canvas-class.html).

**Esperado:** `shouldRepaint` devolve `false` quando os dados não mudaram; o gráfico se adapta à
largura disponível; e ele continua acessível — um `Semantics` descreve os valores para quem não vê.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d09)

---

<a id="p03-d10"></a>
## P03-D10 — Internacionalização pt-BR e en · Difícil · ⚠️ fora do curso

| Objetivo | Dificuldade | Tempo | Módulos envolvidos |
|---|---|---:|---|
| Tirar todo texto do código | Difícil | 90 min | todos + pesquisa |

Extraia **todas** as strings para arquivos `.arb` e ofereça português e inglês, seguindo o idioma
do sistema com opção de trocar nas Configurações.

**O curso não ensinou i18n.** Comece por
[Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization).

**Esperado:** nenhuma string literal visível sobrando no código; plurais corretos ("1 minuto" ×
"2 minutos"); datas e números pelo `intl` no idioma ativo; e um teste que monta uma tela em cada
locale.

> 📌 Repare no tamanho do trabalho. É por isso que i18n se decide **no começo** de um projeto,
> não no fim — e sentir esse custo na prática vale mais que ler o aviso.

[🔑 Gabarito](../../gabaritos/projeto-03-desafios.md#p03-d10)

---

| ⬅️ Anterior | 🏠 Projeto | ➡️ Próximo |
|---|---|---|
| [Critérios de aceite](11-criterios-de-aceite.md) | [README](README.md) | [Checklist final](13-checklist.md) |
