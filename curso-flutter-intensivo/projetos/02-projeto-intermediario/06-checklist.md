# Checklist — Projeto 02: Bloco de Notas de Estudo

> 📌 **"Pronto" é o que está marcado aqui, não a sua impressão.** O que não testou fica desmarcado.

---

## ✅ Requisitos funcionais

**`HomeScreen`**

- [ ] **RF01** — `ListView.separated` com `CartaoNota`: título, prévia, etiqueta, data.
- [ ] **RF02** — Lendo o disco, indicador; nunca "nenhuma nota" antes.
- [ ] **RF03** — Sem nota, `EstadoVazio.inicial` e o botão abre o formulário.
- [ ] **RF04** — Filtro sem resultado, `EstadoVazio.semResultado` e "Limpar filtro".
- [ ] **RF05** — `FilterChip` filtra **uma** etiqueta; tocar no ativo zera `_filtro`.
- [ ] **RF06** — `PopupMenuButton` ordena das três formas e a escolha persiste.
- [ ] **RF07** — Arrastar exclui (`ValueKey<String>(nota.id)`); o `SnackBar` de 5 s desfaz na posição.
- [ ] **RF08** — O FAB abre o formulário em modo de criação.

**`NotaDetalheScreen`**

- [ ] **RF09** — Título, `ChipEtiqueta`, conteúdo rolável e as duas datas.
- [ ] **RF10** — Editar devolve `AcaoDaNota.editar`; Excluir confirma no `AlertDialog`.
- [ ] **RF11** — Voltar devolve `null` e a lista não muda.

**`NotaFormScreen`**

- [ ] **RF12** — "Nova nota" ou "Editar nota"; na edição, campos cheios.
- [ ] **RF13** — Título obrigatório, 3 a 60 caracteres **após `trim()`**.
- [ ] **RF14** — Conteúdo obrigatório, 1 a 2000 caracteres após `trim()`.
- [ ] **RF15** — Etiqueta nunca nula; na criação, `Etiqueta.resumo`.
- [ ] **RF16** — O vermelho só aparece após o primeiro toque em Salvar.
- [ ] **RF17** — `pop(nota)`: criar com `criadaEm == atualizadaEm`; editar preserva `id`/`criadaEm`.
- [ ] **RF18** — Com rascunho, sair pergunta "Descartar alterações?"; sem, sai direto.

**`NotasRepositorio`**

- [ ] **RF19** — Criar, editar, excluir e desfazer gravam a lista em `bloco_notas.notas`.
- [ ] **RF20** — Texto corrompido: `lerNotas()` devolve `const <Nota>[]` e o app abre vazio.
- [ ] **RF21** — Item mal formado é descartado; os demais continuam lidos.
- [ ] **RF22** — `salvarNotas` lança `ArgumentError` com dois `id` iguais.
- [ ] **RF23** — A nota **201** é recusada com `SnackBar` explicando `maxNotas`.

---

## 🧱 Código

- [ ] `flutter analyze` diz `No issues found!` — zero **avisos**, não só zero erros.
- [ ] `dart format lib test` não reescreve nada.
- [ ] A árvore de `lib/` é a de [01-especificacao.md](01-especificacao.md): 16 arquivos, nenhum a mais.
- [ ] Todo `import` do projeto é absoluto (`package:bloco_notas/...`).
- [ ] No `pubspec`, só `shared_preferences`, `cupertino_icons`, `flutter_test` e `flutter_lints`.
- [ ] Nada de Riverpod, `sqflite`, `http`, `intl`, `uuid` ou `go_router`.
- [ ] Nenhum `as` em argumento de rota: `Rotas.gerar` usa `is!` e cai na desconhecida.
- [ ] Nenhum `context` após `await` sem `mounted`; os controllers liberados no `dispose`.

---

## 🎨 Interface

- [ ] Os três estados aparecem de verdade: force cada um.
- [ ] Nada de overflow em 320 × 640 nem com a fonte no máximo; nota de 2000 caracteres não estica o cartão.
- [ ] Tema claro **e** escuro: nenhuma cor fixa fora do `ColorScheme`.
- [ ] Alvos de toque de **48 dp**: FAB, botões, `IconButton` e chips.

---

## 🤖🍎 Plataformas

**🤖 Android** — `flutter run -d <emulador>`

- [ ] Voltar do sistema: com rascunho abre o descarte; no detalhe, não muda a lista.
- [ ] Tema escuro do sistema muda na hora; reabrir mantém notas e ordenação.

**🍎 iOS**

- [ ] O gesto de borda esquerda com rascunho também é barrado pelo `PopScope`.
- [ ] Os `IconButton` da `AppBar` seguem confortáveis com o título do iOS.

> ⚠️ Simulador e `.ipa` exigem **macOS** — física ou CI ([M16](../../modulos/16-build-ios/README.md)).
> No Windows 11 valide em Android ou `-d chrome`; marque os 🍎 com o Mac em mãos.

---

## 🧪 Verificação

- [ ] `flutter test` verde com os três arquivos de [04-testes.md](04-testes.md).
- [ ] `nota_test.dart`: JSON ida e volta, `doMapa` nulo, `copyWith` preservando `id`.
- [ ] `notas_repositorio_test.dart`: `setMockInitialValues`, corrompido, item ruim, id repetido.
- [ ] `nota_form_screen_test.dart`: `find.byKey`, erro de validação, `pop` com a `Nota`.

---

## 🚀 Se tudo passou

1. Commit: o app está completo e verde.
2. Faça o [05-desafios.md](05-desafios.md): extensões no mesmo escopo, sem pacote novo.
3. Siga para o [módulo 08](../../modulos/08-estado-e-arquitetura/README.md): passar estado pelo construtor e devolver pelo `pop` é a dor que o Riverpod resolve.

---

## 🆘 Se algo não passou

| Item que falhou | Onde revisar |
|---|---|
| RF01, RF07 — lista e `Dismissible` | [M06 · 9](../../modulos/06-widgets-e-layouts/09-listas-e-rolagem.md) |
| RF02 a RF06 e estados de UI | [M06 · 12](../../modulos/06-widgets-e-layouts/12-estados-de-ui.md) |
| Tema, toque, overflow | [M06 · 7](../../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) |
| Rotas, RF09 a RF11, RF18 | [M07 · 3](../../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md) · [5](../../modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md) |
| RF12 a RF17 — `Form` e validação | [M07 · 6](../../modulos/07-navegacao-e-formularios/06-formularios.md) · [7](../../modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md) |
| RF19 a RF23 — `SharedPreferences` | [M10 · 2](../../modulos/10-persistencia-de-dados/02-shared-preferences.md) |
| Testes, `analyze` ou `format` | [M12 · 4](../../modulos/12-testes-e-debug/04-analise-lint-formatacao.md) · [5](../../modulos/12-testes-e-debug/05-testes-unitarios.md) |

---

| # | Arquivo | Conteúdo |
|---|---|---|
| — | [README.md](README.md) | Visão geral |
| 01 | [01-especificacao.md](01-especificacao.md) | Requisitos |
| 02 | [02-passo-a-passo.md](02-passo-a-passo.md) | Construção |
| 03 | [03-codigo-completo.md](03-codigo-completo.md) | Código |
| 04 | [04-testes.md](04-testes.md) | Testes |
| 05 | [05-desafios.md](05-desafios.md) | Extensões · [🔑](../../gabaritos/projeto-02-desafios.md) |
| 06 | **06-checklist.md** | 📍 Você está aqui |
