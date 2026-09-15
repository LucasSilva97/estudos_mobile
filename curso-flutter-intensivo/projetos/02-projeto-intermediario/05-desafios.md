# Desafios — Projeto 02: Bloco de Notas de Estudo

> 📌 **Opcionais**, e só com o projeto base pronto: [06-checklist.md](06-checklist.md) marcado,
> `test/` verde e `flutter analyze` limpo. D01 a D04 usam o que você já viu; **D05 a D07 exigem API
> que o curso ainda não ensinou** — pesquisar em [api.flutter.dev](https://api.flutter.dev) faz
> parte do desafio.

> ⚠️ Continua valendo: `setState`, `shared_preferences` e rotas nomeadas. **Sem Riverpod, sem `sqflite`.**

---

<a id="p02-d01"></a>
## P02-D01 — Busca por título e conteúdo · Fácil
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Filtrar em memória sem tocar em `_notas` | Fácil | 25 min |

Ponha um `TextField` acima dos chips, com `TextEditingController` criado no `_HomeScreenState` e
liberado no `dispose`. O getter `_visiveis` passa a cortar também por texto — `titulo` **ou**
`conteudo`, em `toLowerCase()` — **combinando** com `_filtro`; `_limparFiltro` zera os dois.
**Esperado:** palavra inexistente mostra `EstadoVazio.semResultado`, "Limpar filtro" traz tudo de
volta, e `_notas` nunca muda de tamanho. [🔑 Gabarito](../../gabaritos/projeto-02-desafios.md#p02-d01)

<a id="p02-d02"></a>
## P02-D02 — Duplicar a nota · Fácil
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Um terceiro valor em `AcaoDaNota` | Fácil | 30 min |

Acrescente `duplicar` ao enum e um `IconButton` na `AppBar` do detalhe. No `switch` de `_abrirNota`,
monte uma `Nota` inteira — `copyWith` não serve, ele preserva `id` e `criadaEm` — com id de
`microsecondsSinceEpoch`, título `Cópia de <titulo>` cortado em 60 caracteres e datas iguais.
**Esperado:** o `switch` sem `default` cobra o `case` novo, e duplicar com 200 notas cai no
`SnackBar` de `maxNotas`. [🔑 Gabarito](../../gabaritos/projeto-02-desafios.md#p02-d02)

<a id="p02-d03"></a>
## P02-D03 — Nota fixada no topo · Média
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Evoluir o modelo sem quebrar o JSON gravado | Média | 45 min |

Some `final bool fixada` à `Nota` (padrão `false`) e atualize `paraMapa`, `doMapa`, `copyWith`, `==`
e `hashCode`. Chave ausente em `doMapa` vale `false`: o arquivo que já está no aparelho não pode
virar lista vazia. Em `_visiveis`, fixadas primeiro; dentro de cada grupo vale a `Ordenacao`.
**Esperado:** um teste novo em `nota_test.dart` prova que mapa sem a chave `fixada` ainda vira
`Nota`, e que ela nasce `false`. [🔑 Gabarito](../../gabaritos/projeto-02-desafios.md#p02-d03)

<a id="p02-d04"></a>
## P02-D04 — Os três testes que faltam · Média
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Cobrir o que você só testou na mão | Média | 40 min |

**(1)** `lerNotas()` com array de três itens, o do meio sem `titulo`, devolve **duas** notas (RF21).
**(2)** `salvarNotas` com ids repetidos lança `ArgumentError` (`expect(..., throwsArgumentError)`).
**(3)** Widget: abra `NotaFormScreen` com `NotaFormArgs.criar()`, digite no `campo_titulo`, dispare
`await tester.binding.handlePopRoute()` e espere o `AlertDialog` "Descartar alterações?".
**Esperado:** `flutter test` verde no Windows, com `SharedPreferences.setMockInitialValues` no
`setUp` dos dois primeiros. [🔑 Gabarito](../../gabaritos/projeto-02-desafios.md#p02-d04)

<a id="p02-d05"></a>
## P02-D05 — Tema no gosto do usuário · Difícil
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Estado que mora acima do `MaterialApp` | Difícil | 50 min |

Guarde o `ThemeMode` na chave `bloco_notas.tema` (dois métodos no `NotasRepositorio`, no padrão
tolerante de `lerOrdenacao`) e ofereça claro/escuro/sistema num `PopupMenuButton` da home.
`BlocoNotasApp` vira `StatefulWidget` e o callback de troca desce até a `HomeScreen` por
`Rotas.gerar` — a dor que o [módulo 08](../../modulos/08-estado-e-arquitetura/README.md) apaga.
**Esperado:** escolher "Escuro", matar o app e reabrir — abre escuro, sem piscar claro no primeiro
quadro. [🔑 Gabarito](../../gabaritos/projeto-02-desafios.md#p02-d05)

<a id="p02-d06"></a>
## P02-D06 — Busca em tela cheia com `SearchDelegate` · Difícil
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Ler a documentação oficial e aplicar sozinho | Difícil | 1 h |

**O curso ainda não ensinou isto:** leia `showSearch` e `SearchDelegate` em api.flutter.dev antes da
primeira linha. Troque o `TextField` do D01 por uma lupa na `AppBar` que abre busca em tela própria,
com `buildSuggestions`, `buildResults`, `buildLeading` e `buildActions`. O `showSearch<Nota?>`
devolve a nota escolhida, que a home abre com `_abrirNota`.
**Esperado:** cancelar devolve `null` e a home volta com filtro, ordenação e rolagem intactos.
[🔑 Gabarito](../../gabaritos/projeto-02-desafios.md#p02-d06)

<a id="p02-d07"></a>
## P02-D07 — Backup em texto: exportar e importar · Difícil
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Serializar o app inteiro e aceitar o texto de volta | Difícil | 1 h 15 |

**Também não foi ensinado:** procure `Clipboard`, `ClipboardData` e `Clipboard.getData` em
`package:flutter/services.dart` na documentação oficial. Um menu "Backup" copia o `jsonEncode` das
notas para a área de transferência; a importação lê o texto colado, valida item a item com
`Nota.doMapa`, recusa ids repetidos e diz quantas entraram e quantas foram descartadas.

> ⚠️ Arquivo no disco é o [módulo 11](../../modulos/11-recursos-nativos/README.md); coleção que
> cresce é o [módulo 10, aula 4](../../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md).

**Esperado:** colar um texto que não é JSON não quebra nada — avisa "nenhuma nota encontrada" e
mantém a lista atual. [🔑 Gabarito](../../gabaritos/projeto-02-desafios.md#p02-d07)

---

| # | Arquivo | Conteúdo |
|---|---|---|
| — | [README.md](README.md) | Visão geral |
| 01 | [01-especificacao.md](01-especificacao.md) | Requisitos e modelo |
| 02 | [02-passo-a-passo.md](02-passo-a-passo.md) | Construção guiada |
| 03 | [03-codigo-completo.md](03-codigo-completo.md) | Arquivos de `lib/` |
| 04 | [04-testes.md](04-testes.md) | Arquivos de `test/` |
| 05 | **05-desafios.md** | 📍 Você está aqui · [🔑 gabarito](../../gabaritos/projeto-02-desafios.md) |
| 06 | [06-checklist.md](06-checklist.md) | Critérios de "pronto" |
