# Exercícios — Módulo 10: Persistência de dados

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Rode `flutter analyze` e `flutter test` no `foco_dados` antes de consultar o gabarito.

<a id="m10-e01"></a>
## M10-E01 — Triagem de armazenamento · Classificação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Aplicar a árvore de decisão | Fácil | 20 min | Sim |
Classifique seis dados do Foco com `escolherArmazenamento` (`core/armazenamento/politica_de_armazenamento.dart`): token de acesso, modo de tema, 3 mil sessões de estudo, CSV exportado do mês, total de minutos da semana e PIN de desbloqueio. **Esperado:** `cofre`, `preferencia`, `banco`, `arquivo`, `naoPersistir`, `cofre` — um `expect` por caso, com a justificativa citando qual campo do `PerfilDoDado` decidiu. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e01)

<a id="m10-e02"></a>
## M10-E02 — Ajustes do Foco em preferências · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| `shared_preferences` com padrões | Fácil | 25 min | Sim |
No `MetaRepositorio`, implemente `meta_semanal_minutos` (`int`, padrão 300), `notificar_meta_atingida` (`bool`, padrão `true`), `materias_fixadas` (`List<String>`) e `preferencias_de_sessao` gravada como JSON em `String`. **Teste:** com `SharedPreferences.setMockInitialValues({})` todos os padrões aparecem; com o JSON corrompido `'{{'` você recebe `const PreferenciasDeSessao()` em vez de `FormatException`. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e02)

<a id="m10-e03"></a>
## M10-E03 — Relatório mensal em CSV · Implementação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Arquivos sem `path_provider` no teste | Média | 30 min | Sim |
Implemente `ExportadorDeEstudo.exportarCsv` gravando `foco-2026-03.csv` em `documentos/relatorios`, com cabeçalho `data;materia;minutos`, caminho montado por `p.join` e pasta criada com `create(recursive: true)`. **Teste:** injete `Directory.systemTemp.createTempSync()`; `lerRelatorio(2026, 4)` de um mês que não existe devolve `null`, sem deixar `FileSystemException` vazar. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e03)

<a id="m10-e04"></a>
## M10-E04 — Esquema do `foco.db` · Implementação
Escreva `BancoFoco.criar` com `materias` (`id TEXT PRIMARY KEY`, `nome`, `nome_ordenacao`, `minutos INTEGER NOT NULL DEFAULT 0`, `criada_em INTEGER`), `sessoes` com `FOREIGN KEY (materia_id) REFERENCES materias (id) ON DELETE CASCADE`, os três índices da aula, e `PRAGMA foreign_keys = ON` em `onConfigure`. **Teste:** com `sqfliteFfiInit()` e `inMemoryDatabasePath`, excluir uma matéria apaga as sessões dela; sem o `PRAGMA`, esse teste falha. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e04)

<a id="m10-e05"></a>
## M10-E05 — CRUD do `MateriaDao` · Aplicação
Implemente `inserir`, `listar({OrdemDeMaterias ordem})`, `porId`, `atualizar`, `arquivar` e `excluir` usando sempre `?` e `whereArgs`, com `nome_ordenacao` derivado por `Texto.paraOrdenacao` dentro de `Materia.paraLinha()`. **Teste:** insira `Álgebra`, `Física` e `zoologia`; `listar()` devolve nessa ordem, e renomear `zoologia` para `Ácido` a manda para a primeira posição. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e05)

<a id="m10-e06"></a>
## M10-E06 — Busca que aceita aspas · Correção de bugs
A busca de matérias hoje é `rawQuery("SELECT * FROM materias WHERE nome LIKE '%$termo%' ORDER BY nome ASC")`. Corrija os dois defeitos: passe o termo por `where`/`whereArgs` com `?` e ordene por `nome_ordenacao`. **Teste:** o termo `' OR '1'='1` devolve zero linhas em vez da tabela inteira, e a listagem traz `Álgebra` antes de `Física`. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e06)

<a id="m10-e07"></a>
## M10-E07 — `transaction` × `batch` · Compreensão
Escreva até oito linhas explicando a diferença entre `transaction` e `batch`, e por que usar `db` em vez de `txn` dentro de um `transaction` trava o app. **Esperado:** o texto cita atomicidade, número de idas ao SQLite, `noResult: true`, e diz qual dos dois você usaria para importar 1 000 matérias vindas do servidor — com o motivo. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e07)

<a id="m10-e08"></a>
## M10-E08 — Migração v3 → v4 · Aplicação
Suba `BancoFoco.versaoAtual` para 4, crie `_de3Para4` com `ALTER TABLE materias ADD COLUMN cor INTEGER NOT NULL DEFAULT 0` e acrescente `if (de < 4)` em `atualizar`, sem tocar em `_de1Para2` nem `_de2Para3`. **Teste:** abra um banco na versão 1 com uma matéria gravada, reabra na 4 e confirme por `PRAGMA table_info(materias)` que `arquivada` e `cor` existem e que a linha antiga continua lá. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e08)

<a id="m10-e09"></a>
## M10-E09 — Migração que pula etapas · Correção de bugs
Alguém trocou os `if` independentes de `atualizar` por `if / else if`. Explique em duas frases o que acontece com o aparelho que está na versão 1 e restaure a forma correta. **Teste:** abra na v1, migre até a v4 e verifique que `sessoes` tem `anotacao` e `humor`; com `else if`, esse mesmo teste quebra. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e09)

<a id="m10-e10"></a>
## M10-E10 — Recriar tabela ou `ALTER TABLE` · Decisão
A coluna `minutos` de `sessoes` precisa virar `REAL` e a coluna `anotacao` precisa deixar de existir. Escreva de 10 a 15 linhas justificando se você usa `ALTER TABLE` ou `recriarTabelaModelo`, citando o que o SQLite não sabe alterar, por que `PRAGMA foreign_keys = OFF` fica fora da transação e qual é o risco para quem já tem o app instalado. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e10)

<a id="m10-e11"></a>
## M10-E11 — Token no lugar errado · Correção de bugs
Uma tela faz `prefs.setString('token', t)` e depois `debugPrint('token: $t')`. Migre para `SessaoLocal` sobre `CofreSeguro`, com `AndroidOptions(encryptedSharedPreferences: true)` e `IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device)`, apague o log e remova a chave antiga de `SharedPreferences` na primeira execução. **Esperado:** nenhum segredo em `shared_preferences` e nenhum segredo em log. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e11)

<a id="m10-e12"></a>
## M10-E12 — PIN de desbloqueio · Aplicação
Implemente `definirPin` e `pinCorreto` em `SessaoLocal` guardando apenas sal (`Random.secure()`) e hash — nunca o PIN — e comparando em tempo constante. **Teste:** com `CofreEmMemoria`, `definirPin('1234')` faz `pinCorreto('1234')` ser `true` e `pinCorreto('4321')` ser `false`, e nenhum valor de `lerTudo()` contém `1234`. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e12)

<a id="m10-e13"></a>
## M10-E13 — Três estratégias de cache · Decisão
Para três telas do Foco — lista de trilhas (muda pouco), saldo de minutos da semana (precisa estar certo agora) e detalhe de trilha aberto no metrô — escolha entre *cache-first*, *network-first* e *stale-while-revalidate*, com um TTL sugerido para cada uma. Escreva um parágrafo por tela, citando `Validade.trilhas` e o que o usuário vê enquanto a rede não responde. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e13)

<a id="m10-e14"></a>
## M10-E14 — Trilhas offline de ponta a ponta · Desafio prático
Una `TrilhaCacheDao`, `FilaDePendencias`, `ObservadorDeRede` e `TrilhaRepositorio.observar()`: a tela recebe o cache na hora, depois o dado da rede, e `alternarTema` funciona sem internet. **Teste:** com a API falhando e `StatusDeRede.semInterface`, `observar()` ainda emite o cache com `avisoDeIdade`, a operação entra na fila, a requisição é **tentada mesmo assim** (conectividade só explica a falha) e `sincronizar()` esvazia a fila quando a API volta. [🔑 Gabarito](../gabaritos/10-persistencia-de-dados.md#m10-e14)

[Módulo](../modulos/10-persistencia-de-dados/README.md)
