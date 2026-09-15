# Exercícios — Módulo 13: Desempenho e segurança

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Tudo acontece no projeto `foco_desempenho`. Meça em `--profile` (nunca em debug) e rode `flutter analyze` sem avisos antes de consultar o gabarito. Resposta sem número não vale.

<a id="m13-e01"></a>
## M13-E01 — Os quatro disparadores de `build` · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Provar o que reconstrói, com contagem | Fácil | 20 min | Sim |
Ligue `debugPrintRebuildDirtyWidgets = true` no `main()` de `foco_desempenho`, toque 5 vezes em "+1 s" na `RebuildsDemoScreen` e conte as linhas nas três versões: `setState` na tela toda, `ValueListenableBuilder` sem `const`, `ValueListenableBuilder` com `const`. **Esperado:** uma tabela com os três números e uma frase por disparador (`setState`, pai reconstruiu, dependência mudou, listenable notificou) dizendo qual deles cada versão aciona. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e01)

<a id="m13-e02"></a>
## M13-E02 — A estrela troca de matéria · Correção de bugs
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Dar identidade estável ao item da lista | Média | 25 min | Sim |
Com `_usarKeys = false`, marque a estrela de "Física" no `MateriaTile` e aperte **Inverter**: a estrela fica no índice, não na matéria, porque `_favorita` vive no `Element`. Corrija com `key: ValueKey<String>(materia.id)` e explique em uma linha por que `UniqueKey()` aqui seria pior. **Teste:** inverter duas vezes mantém a estrela em "Física". [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e02)

<a id="m13-e03"></a>
## M13-E03 — Lista paginada de matérias · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Paginar 137 itens sem duplicar nem travar | Média | 45 min | Sim |
Implemente `PaginaMaterias` (com `itens`, `pagina`, `carregandoMais`, `acabou`, `erro` e `copiarCom`) e `MateriasPaginadas extends AsyncNotifier<PaginaMaterias>`, com 20 por página, busca disparada em 80 % da rolagem e erro guardado **dentro** do estado. **Teste:** role até o fim e veja "137 matérias · fim da lista"; faça `_buscar` lançar na página 3 e confirme que as páginas 1 e 2 continuam na tela. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e03)

<a id="m13-e04"></a>
## M13-E04 — 30 capas mataram o app · Diagnóstico
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Calcular memória de imagem decodificada | Média | 25 min | Sim |
A lista exibe capas de 1200 × 800 em 56 × 56 e o app morre com 30 visíveis. Calcule, em MB, quanto **uma** capa ocupa depois de decodificada (largura × altura × 4 bytes) e quanto ocupam as 30; depois calcule o valor certo de `memCacheWidth` para 56 lógicos numa tela com `devicePixelRatio` 3. **Esperado:** os três números escritos e a queda medida na aba Memory do DevTools, antes e depois de `CapaMateria`. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e04)

<a id="m13-e05"></a>
## M13-E05 — Resumo fora da thread de UI · Aplicação
Ponha `calcularResumo` (função de topo) atrás de `ImportadorHistorico.resumir`, que decide pelo tamanho: abaixo de 10 000 itens calcula direto, acima usa `Isolate.run`. Na importação, use `resposta.bodyBytes`, não `body`. **Teste:** com 500 000 itens o quadrado `_Girando` não para de girar; depois troque `Isolate.run` por `compute` passando um **método de instância** e transcreva o erro que o Dart dá. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e05)

<a id="m13-e06"></a>
## M13-E06 — Frame de 42 ms: azul ou verde? · Diagnóstico
Um quadro da `JankDemoScreen` fecha com `buildDuration` de 3,9 ms e `rasterDuration` de 38,4 ms, em modo profile num Android. Diga qual thread estourou, aponte as duas causas mais prováveis dessa thread e a correção de cada uma. **Esperado:** `MonitorDeQuadros.diagnostico` confirma a sua leitura, e você anota `p99Ui` e `p99Raster` antes e depois de remover o `Opacity`. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e06)

<a id="m13-e07"></a>
## M13-E07 — `SessaoScreen` acessível · Aplicação
Transforme `_CardRuim` em acessível: `IconButton` com `tooltip` e `constraints: BoxConstraints(minWidth: 48, minHeight: 48)`, `MergeSemantics` para "Cálculo I, 45 minutos" virar uma parada só, `Semantics(liveRegion: true)` no contador de minutos e `ExcludeSemantics` na ilustração. **Teste:** `test/acessibilidade_test.dart` com `tester.ensureSemantics()` passa nas quatro diretrizes (`androidTapTargetGuideline`, `iOSTapTargetGuideline`, `textContrastGuideline`, `labeledTapTargetGuideline`) e sobrevive a `TextScaler.linear(2.0)` sem overflow. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e07)

<a id="m13-e08"></a>
## M13-E08 — Busca por nome à prova de injeção · Correção de bugs
`MateriaDao.buscar` hoje monta `rawQuery` interpolando o termo direto na string SQL. Reescreva com `_db.query` + `where: 'nome_ordenacao LIKE ?'` + `whereArgs`, e faça `listar` validar `ordenarPor` contra o conjunto fixo `_colunasOrdenaveis`. **Teste:** buscar `'; DROP TABLE materias; --` não apaga nada, e buscar `D'Ávila` devolve resultado — coisa que a versão interpolada não faz nem sem má intenção. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e08)

<a id="m13-e09"></a>
## M13-E09 — O `const` que sumiu · Leitura de código
Remova `const` de `CabecalhoDaSemana()` e tire o `child:` do `ValueListenableBuilder`. Antes de rodar, escreva quais widgets passam a reconstruir a cada segundo; depois confirme com a contagem de rebuilds. **Esperado:** sua previsão bate com o terminal, ou você registra onde errou e por quê. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e09)

<a id="m13-e10"></a>
## M13-E10 — Página 2 chega quatro vezes · Correção de bugs
Apague a linha `if (atual == null || atual.carregandoMais || atual.acabou) return;` de `carregarMais()`, role rápido e conte os itens duplicados e as chamadas a `_buscar` feitas depois do item 137. Restaure a trava e explique qual das três condições resolve cada um dos dois bugs. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e10)

<a id="m13-e11"></a>
## M13-E11 — Isolate que piora · Reflexão
Escreva de 8 a 12 linhas sobre três casos do Foco em que criar isolate **piora** o resultado: baixar o histórico da API, resumir 800 sessões e copiar uma lista de 200 mil itens para dentro do isolate. Cite o custo de criação (50–200 ms) e o orçamento de 16,67 ms, e justifique cada veredito com um número medido no seu aparelho. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e11)

<a id="m13-e12"></a>
## M13-E12 — Contraste 2,3:1 e alvo de 24 dp · Correção de bugs
No card de sessão há um `Text` com `color: Color(0xFFAAAAAA)` sobre `surface`, um `GestureDetector` em volta de um `Icon(size: 24)` e um `SizedBox(height: 48)` em volta do nome da matéria. Corrija os três (papel do `ColorScheme`, `IconButton` com alvo de 48 dp, `ConstrainedBox(minHeight: 48)`) e prove com `Contraste.descrever`. **Esperado:** razão ≥ 4.5:1 e `meetsGuideline` verde; feche com duas linhas sobre o que esse teste automático **não** pega. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e12)

<a id="m13-e13"></a>
## M13-E13 — Modelo de ameaça do Foco · Reflexão
Liste os dados que o Foco guarda (token, sessões, matérias), diga onde cada um mora e classifique sensível ou não. Depois ordene por probabilidade quatro ameaças — celular destravado na mão de outra pessoa, APK extraído e lido, token no `adb logcat`, banco copiado do backup — e aponte qual defesa do módulo cobre cada uma. **Esperado:** `CofreToken.limpar()` aparece como defesa da ameaça mais provável, e nenhum segredo real está em `ConfigApp`. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e13)

<a id="m13-e14"></a>
## M13-E14 — Release ofuscado e crash decifrado · Desafio prático
Escreva `tool/build-release.ps1` que roda `flutter analyze` e `flutter test` como portões, compila com `--obfuscate --split-debug-info=simbolos/<versao>` e **falha** se nenhum arquivo `.symbols` for gerado. Provoque um `RangeError` no APK, colete com `adb logcat -d > crash.txt` e decifre com `flutter symbolize`. **Teste:** o stack trace volta legível com o símbolo da versão certa e continua ilegível com o de outra versão; anote também o tamanho do APK e a maior fatia do `--analyze-size`. [🔑 Gabarito](../gabaritos/13-desempenho-e-seguranca.md#m13-e14)

[Módulo](../modulos/13-desempenho-e-seguranca/README.md)
