# Critérios de aceite — Projeto Final: Foco

> **Aceite é objetivo.** Ou o critério passa, ou não passa. "Está quase" é não passa.
> Esta página existe para você não precisar decidir, no cansaço do fim, se o app está pronto.

Cada critério traz **como verificar** — o gesto exato e o resultado esperado. Faça no aparelho,
não de memória.

---

## ✅ Funcionais

Um critério por requisito da [especificação](01-especificacao.md).

| RF | Critério | Como verificar |
|---|---|---|
| **RF01** | As três abas existem e a escolhida sobrevive à navegação | Abra **Matérias** → entre numa matéria → volte. Continua em Matérias, não voltou para Painel |
| **RF02** | O Painel soma hoje, semana, anel e 3 sessões recentes | Registre 2 sessões hoje. Os minutos batem com a soma. Apague tudo: aparece o estado vazio **com botão**, não uma tela em branco |
| **RF03** | Ordenação ignora acento | Crie `Álgebra`, `Biologia`, `Cálculo`. A ordem é Álgebra → Biologia → Cálculo. Se Álgebra aparecer **depois** de Biologia, o `nome_ordenacao` não está sendo usado |
| **RF04** | Nome de 2 a 60 e 8 cores fixas | Tente salvar com 1 caractere: bloqueia. Com 61: bloqueia. Conte as cores: são 8 |
| **RF05** | A mesma tela edita e devolve `true` | Edite uma matéria. Ao voltar, a lista já mostra o nome novo **sem** puxar para atualizar |
| **RF06** | Duplicata usa nome normalizado | Crie `Cálculo`. Tente criar `calculo`. É rejeitado |
| **RF07** | Arquivada some da lista mas conta nas estatísticas | Arquive uma matéria com 120 min. Ela some da aba Matérias e do seletor de sessão, e o total da semana **não muda** |
| **RF08** | Excluir confirma e apaga as sessões junto | Exclua uma matéria com sessões. Aparece o diálogo. Depois, o total de minutos da semana cai |
| **RF09** | Detalhe mostra total, cronômetro e 50 sessões | Entre numa matéria com mais de 50 sessões. Carrega 50, da mais nova para a mais antiga |
| **RF10** | O cronômetro usa diferença de `DateTime` | Inicie, mande o app para segundo plano por 2 min, volte. O tempo avançou **2 min**, não ficou parado nem pulou |
| **RF11** | Parar abre a folha com os minutos preenchidos | Rode 90 s e pare. O campo mostra `2` (arredondado), não vazio nem `1.5` |
| **RF12** | Validação de data e minutos | Tente data de amanhã: bloqueia. `0` minutos: bloqueia. `481`: bloqueia. O erro aparece **no campo**, não num `SnackBar` |
| **RF13** | Sessão e total na mesma transação | Registre uma sessão. O total da matéria sobe exatamente o mesmo tanto. Nunca um sem o outro |
| **RF14** | Remover desconta e oferece desfazer | Remova uma sessão de 45 min. O total cai 45. Toque em **Desfazer**: volta tudo |
| **RF15** | Meta em `shared_preferences`, 30 a 3000, passo 30 | Ajuste para 450. Feche o app pelo gerenciador. Reabra: continua 450 |
| **RF16** | Estatísticas da semana corrente, segunda a domingo | Confira que a primeira barra é **segunda**. A variação compara com a semana anterior, não com a média |
| **RF17** | Trilhas cobrem os quatro estados | Veja carregando → dados. Force erro (modo avião sem cache). Puxe para atualizar |
| **RF18** | Cache com TTL de 6 h | Carregue as trilhas. Feche e reabra em seguida: **não** vai à rede (confira no DevTools → Network) |
| **RF19** | Offline usa o cache com aviso | Carregue, ative o modo avião, reabra. Mostra as trilhas **e** o aviso "sem conexão", não uma tela de erro |
| **RF20** | Configurações ajustam meta, tema, cache e versão | Troque para tema escuro. Aplica **na hora**, sem reiniciar |

> ⚠️ **RF10 e RF13 são os dois que mais reprovam.** O cronômetro somando ticks perde tempo em
> segundo plano, e a sessão fora de transação deixa o total da matéria divergente do somatório das
> sessões — um bug que só aparece semanas depois, quando os números não fecham mais.

---

## ♿ Acessibilidade

| RNF | Critério | Como medir |
|---|---|---|
| **RNF01** | Contraste ≥ 4.5:1 nos dois temas | `flutter test` com `meetsGuideline(textContrastGuideline)` |
| **RNF02** | Alvos de 48 dp, inclusive em listas | `meetsGuideline(androidTapTargetGuideline)` e `iOSTapTargetGuideline` |
| **RNF03** | 200% de fonte sem estouro | `MediaQuery(textScaler: TextScaler.linear(2.0))` em teste de widget; `tester.takeException()` precisa ser `null` |
| **RNF04** | Todo botão só-ícone tem rótulo | `meetsGuideline(labeledTapTargetGuideline)` |
| **RNF05** | Ordem de foco segue a ordem visual | 🤖 TalkBack ligado: deslize da primeira à última parada e confira se a ordem faz sentido |

> 📌 **Os quatro primeiros são automáticos; o quinto não é.** Nenhum teste percebe que a ordem de
> leitura está embaralhada ou que um rótulo diz "botão 3". Reserve **cinco minutos com o TalkBack
> ligado** — é a única verificação desta seção que exige uma pessoa.

---

## ⚡ Desempenho

| RNF | Critério | Como medir |
|---|---|---|
| **RNF06** | `ListView.builder`, `const` e `ValueKey` | Leitura de código; procure por `ListView(children:` com dado de banco |
| **RNF07** | 500 matérias e 5.000 sessões rolam liso | Rode o script de carga da etapa 7, depois `flutter run --profile` |
| **RNF08** | Imagens com `cacheWidth` | Procure por `Image.` sem `cacheWidth` |
| **RNF09** | Agregação em SQL, não em Dart | O resumo semanal usa `SUM` e `GROUP BY`; nenhum `fold` sobre a lista inteira |
| **RNF14** | Partida fria < 2 s até o Painel | `flutter run --profile`, cronômetro na mão |
| **RNF19** | Rotacionar não perde estado | Inicie o cronômetro e gire o aparelho. Continua contando |

> ⚠️ **Meça em `--profile`, num aparelho, nunca em debug.** O modo debug é várias vezes mais lento;
> qualquer número tirado dali é sobre o debug, não sobre o seu app.

---

## 🔒 Segurança

| RNF | Critério | Como verificar |
|---|---|---|
| **RNF10** | Nenhum segredo no código, no log ou no Git | `git log -p` procurando chave; `.gitignore` cobre `key.properties`, `*.jks`, `.env` |
| **RNF11** | **Todo** SQL com `?` e `whereArgs` | Procure por `rawQuery` e por `$` dentro de string SQL. Zero ocorrências |
| **RNF12** | HTTPS e `timeout` em toda requisição | Nenhuma tela mostra `toString()` de exceção |

> 📌 **RNF11 não admite exceção.** Uma única query interpolada derruba o critério — e o motivo não é
> só segurança: um nome com apóstrofo ("D'Ávila") quebra a query interpolada sem nenhuma má intenção.

---

## 🧪 Testes

| Nível | Mínimo | O que precisa estar coberto |
|---|---:|---|
| Unitário | 25 testes | Domínio (validações, cálculo de duração), DAOs com `sqflite_common_ffi`, repositórios com falha simulada |
| Widget | 10 testes | As 5 telas, os 4 estados da aba Trilhas, o formulário validando e o `meetsGuideline` |
| Integração | 2 fluxos | Criar matéria → registrar sessão → conferir o Painel; e fechar/reabrir preservando os dados |

`flutter test` precisa terminar com **`All tests passed!`**. Teste pulado (`skip:`) conta como
não escrito.

---

## 📦 Build

| Critério | Como verificar |
|---|---|
| `flutter analyze` com **`No issues found!`** | Zero aviso. "Poucos avisos" é reprovado (RNF15) |
| `dart format` aplicado | `dart format --output=none --set-exit-if-changed .` passa |
| 🤖 AAB assinado com a sua chave | `apksigner verify --print-certs` **não** mostra `CN=Android Debug` |
| 🤖 Símbolos arquivados | `simbolos/<versão>/` com os `.symbols` e o `mapping.txt` |
| 🍎 IPA gerado e validado | Xcode → Organizer → **Validate App** passa |
| 🍎 Os **dois** conjuntos de símbolos guardados | `--split-debug-info` (Dart) **e** os dSYM (nativo) |

> 🍎 **O que exige Mac:** gerar e validar o IPA. Tudo o mais — Bundle ID, ícone, splash, `Info.plist`,
> versão — você faz no Windows e leva versionado. Se não tiver Mac, a alternativa é **CI com runner
> macOS** (módulo 16, aula 4); nesse caso o critério vira "o job de iOS passou no CI".

---

## 🏁 Aprovado quando

Todos, sem negociação:

1. Os **20 RF** passam no aparelho.
2. Os **20 RNF** passam nas verificações acima.
3. `flutter analyze` → `No issues found!`
4. `flutter test` → `All tests passed!`, com os mínimos por nível.
5. O app instala em **aparelho limpo** e **atualiza** de uma versão anterior sem perder dados.
6. Cinco minutos de TalkBack sem encontrar parada sem rótulo ou ordem sem sentido.
7. Os símbolos da versão publicada estão guardados **fora** da sua máquina.

Faltou um? O app não está pronto. Volte ao [checklist](13-checklist.md), que diz **onde** revisar.

---

| ⬅️ Anterior | 🏠 Projeto | ➡️ Próximo |
|---|---|---|
| [Etapa 8 — Ícone, splash e versão](10-etapa-8-icone-splash-e-versao.md) | [README](README.md) | [Desafios](12-desafios.md) |
