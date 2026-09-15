# Especificação — Projeto 02: Bloco de Notas de Estudo

> **Pasta:** `bloco_notas` · **Tempo:** 7 h (3 h + 4 h) · **Cobre:** módulos 05, 06 e 07,
> aula 2 do 10 e aulas 5 e 6 do 12.

App Android/iOS onde você registra notas de estudo com título, conteúdo e etiqueta, filtra,
ordena e reencontra tudo na próxima abertura — mesmo depois de fechar o app.

---

## 🎯 O que você vai praticar

| Recurso | Onde foi ensinado |
|---|---|
| `setState`, `initState`/`dispose`, `context.mounted` após `await` | [M05 · 5](../../modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md) · [6](../../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) · [7](../../modulos/05-introducao-ao-flutter/07-buildcontext.md) |
| `ColorScheme.fromSeed`, tema claro e escuro | [M06 · 7](../../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) |
| `ListView.separated`, `Dismissible` com `key` estável, `SnackBar` de desfazer | [M06 · 9](../../modulos/06-widgets-e-layouts/09-listas-e-rolagem.md) · [10](../../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md) |
| Carregando / vazio inicial / vazio sem resultado | [M06 · 12](../../modulos/06-widgets-e-layouts/12-estados-de-ui.md) |
| `Rotas` + `onGenerateRoute` + `onUnknownRoute` | [M07 · 2](../../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md) |
| Classes `*Args`, `args is!`, `pushNamed<T>`, `pop(resultado)` | [M07 · 3](../../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md) |
| `PopScope` com `canPop` + `onPopInvokedWithResult` | [M07 · 5](../../modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md) |
| `Form`, `GlobalKey<FormState>`, `TextEditingController`, `Validadores`, `AutovalidateMode` | [M07 · 6](../../modulos/07-navegacao-e-formularios/06-formularios.md) · [7](../../modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md) |
| Repositório sobre `SharedPreferences`, objeto → JSON → `String` | [M10 · 2](../../modulos/10-persistencia-de-dados/02-shared-preferences.md) |
| `setMockInitialValues`; `testWidgets` e `find.byKey` | [M12 · 5](../../modulos/12-testes-e-debug/05-testes-unitarios.md) · [6](../../modulos/12-testes-e-debug/06-testes-de-widget.md) |

---

## 📋 Requisitos funcionais

**Lista (`HomeScreen`)**

- **RF01** — Mostra as notas em `ListView.separated`, um `CartaoNota` por nota, com título, primeira linha do conteúdo, etiqueta e data de atualização.
- **RF02** — Enquanto lê do disco mostra `CircularProgressIndicator`; nunca mostra "nenhuma nota" por engano.
- **RF03** — Sem nota alguma salva, mostra `EstadoVazio.inicial` com botão que abre o formulário.
- **RF04** — Com notas salvas mas nenhuma no filtro, mostra `EstadoVazio.semResultado` com botão "Limpar filtro".
- **RF05** — `FilterChip` filtra por **uma** etiqueta por vez; tocar no chip ativo zera o filtro (`_filtro` volta a `null`).
- **RF06** — `PopupMenuButton` ordena por `maisRecente`, `maisAntiga` ou `tituloAZ`; a opção sobrevive ao fechamento.
- **RF07** — Arrastar o cartão exclui (`Dismissible` com `key: ValueKey<String>(nota.id)`) e mostra `SnackBar` com **Desfazer** por 5 s, que devolve a nota à mesma posição.
- **RF08** — O `FloatingActionButton` abre o formulário em modo de criação.

**Detalhe (`NotaDetalheScreen`)**

- **RF09** — Mostra título, `ChipEtiqueta`, conteúdo completo rolável, criada em e atualizada em.
- **RF10** — A `AppBar` tem **Editar** (devolve `AcaoDaNota.editar`) e **Excluir** (confirma em `AlertDialog`, devolve `AcaoDaNota.excluir`).
- **RF11** — Voltar pelo botão do sistema ou pelo gesto de borda devolve `null` e a lista não muda.

**Formulário (`NotaFormScreen`)**

- **RF12** — Atende criação e edição: `AppBar` "Nova nota" ou "Editar nota", campos já preenchidos na edição.
- **RF13** — Título obrigatório, de 3 a 60 caracteres **depois do `trim()`**.
- **RF14** — Conteúdo obrigatório, de 1 a 2000 caracteres depois do `trim()`.
- **RF15** — Etiqueta vem de `DropdownButtonFormField<Etiqueta>` e nunca é nula; o padrão em criação é `Etiqueta.resumo`.
- **RF16** — A validação só aparece após a primeira tentativa de salvar (`AutovalidateMode.onUserInteraction`).
- **RF17** — Salvar devolve a `Nota` por `Navigator.pop(nota)`. Na criação `criadaEm == atualizadaEm`; na edição `id` e `criadaEm` são preservados e só `atualizadaEm` muda.
- **RF18** — Com alteração não salva, sair abre o `AlertDialog` "Descartar alterações?" (`PopScope` com `canPop: false`). Sem alteração, sai direto.

**Persistência (`NotasRepositorio`)**

- **RF19** — Criar, editar, excluir e desfazer gravam a lista inteira na chave `bloco_notas.notas`, como array JSON dentro de uma `String`.
- **RF20** — Texto corrompido ou que não seja lista faz `lerNotas()` devolver `const <Nota>[]` em vez de lançar: o app abre vazio, não quebra.
- **RF21** — Item do array com formato inesperado é **descartado**; os demais continuam sendo lidos.
- **RF22** — Nunca existem dois `id` iguais: `salvarNotas` recusa duplicatas com `ArgumentError`.
- **RF23** — O app recusa criar a nota de número **201** e explica em um `SnackBar` — teto proposital deste armazenamento.

---

## 🚫 Fora de escopo

| O que este projeto **não** faz | Onde isso aparece |
|---|---|
| Riverpod, `Notifier`, `ProviderScope`, `InheritedWidget` | [M08](../../modulos/08-estado-e-arquitetura/README.md) |
| API, `package:http`, sincronização na nuvem | [M09](../../modulos/09-consumo-de-api/README.md) |
| `sqflite`, consultas, migrações | [M10 · 4 a 6](../../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) |
| Fotos, permissões, notificações | [M11](../../modulos/11-recursos-nativos/README.md) |
| `mocktail`, fakes, testes de integração | [M12 · 7 e 8](../../modulos/12-testes-e-debug/07-mocks-e-fakes.md) |
| `go_router` | [M07 · 9](../../modulos/07-navegacao-e-formularios/09-go-router-opcional.md) |
| Ícone, splash, assinatura, build de release | [M14](../../modulos/14-build-android/README.md) e [M15](../../modulos/15-build-ios/README.md) |

> ⚠️ Guardar uma **lista que cresce** em `shared_preferences` é o abuso descrito na
> [aula 2 do M10](../../modulos/10-persistencia-de-dados/02-shared-preferences.md), e é proposital:
> você sente o custo de reescrever o arquivo inteiro a cada nota. Daí o RF23.

> 🪟 Tudo roda no Windows 11 (`flutter run -d chrome` ou emulador Android). **Nada aqui exige Mac.**
> Gerar `.ipa` exige macOS — máquina física ou *runner* macOS em CI — e isso é o módulo 15.

---

## 🧱 Modelo de dados

```dart
// lib/features/notas/domain/etiqueta.dart
enum Etiqueta {
  aula('Aula'), resumo('Resumo'), duvida('Dúvida'),
  revisao('Revisão'), ideia('Ideia');

  const Etiqueta(this.rotulo);
  final String rotulo;

  // Nome desconhecido (JSON de versão antiga) vira `resumo` — nunca null.
  static Etiqueta porNome(String? nome) => Etiqueta.values
      .firstWhere((Etiqueta e) => e.name == nome, orElse: () => Etiqueta.resumo);
}

// lib/features/notas/domain/ordenacao.dart
enum Ordenacao {
  maisRecente('Mais recentes'), maisAntiga('Mais antigas'), tituloAZ('Título A–Z');

  const Ordenacao(this.rotulo);
  final String rotulo;

  static Ordenacao porNome(String? nome) => Ordenacao.values
      .firstWhere((Ordenacao o) => o.name == nome, orElse: () => Ordenacao.maisRecente);
}

// lib/features/notas/domain/nota.dart — imutável, com == e hashCode por valor
class Nota {
  const Nota({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.etiqueta,
    required this.criadaEm,
    required this.atualizadaEm,
  });

  final String id;
  final String titulo;
  final String conteudo;
  final Etiqueta etiqueta;
  final DateTime criadaEm;
  final DateTime atualizadaEm;

  // Devolve null com campo obrigatório faltando, para o repositório descartar
  // só o item ruim e manter os outros (RF21).
  static Nota? doMapa(Map<String, Object?> mapa);
  Map<String, Object?> paraMapa();

  Nota copyWith({String? titulo, String? conteudo, Etiqueta? etiqueta, DateTime? atualizadaEm});
}
```

A chave `bloco_notas.notas` guarda o `jsonEncode` de uma lista de `paraMapa()`. `DateTime` viaja
como `toIso8601String()` e volta com `DateTime.tryParse`; `Etiqueta` viaja como `.name`. O `id` é
`DateTime.now().microsecondsSinceEpoch.toString()`, gerado na `NotaFormScreen` — sem o pacote
`uuid`, que só entra no Projeto 3. A ordenação fica na chave `bloco_notas.ordenacao`.

---

## 📱 Telas

| Tela | Rota | Mostra | O usuário faz |
|---|---|---|---|
| `HomeScreen` | `Rotas.home` = `'/'` | Chips de etiqueta e a lista, ou um dos três estados de UI | Filtra, ordena, abre, arrasta para excluir, desfaz, cria no FAB |
| `NotaDetalheScreen` | `Rotas.notaDetalhe` = `'/nota/detalhe'` | Título, `ChipEtiqueta`, conteúdo rolável, datas | Edita, exclui (com confirmação) ou volta |
| `NotaFormScreen` | `Rotas.notaForm` = `'/nota/form'` (`fullscreenDialog: true`) | `Form` com título, conteúdo (`maxLines: 8`) e etiqueta | Preenche e salva, ou fecha no X com aviso de rascunho |
| `RotaDesconhecidaScreen` | qualquer nome não previsto | O nome pedido e a explicação | Volta ao início com `pushNamedAndRemoveUntil` |

| Rota | `arguments` | Tipo da `Route` | Resultado |
|---|---|---|---|
| `notaDetalhe` | `NotaDetalheArgs(nota: Nota)` | `MaterialPageRoute<AcaoDaNota>` | `AcaoDaNota?` — `editar`, `excluir` ou `null` |
| `notaForm` | `NotaFormArgs.criar()` ou `.editar(nota)` | `MaterialPageRoute<Nota>` | `Nota?` — `null` significa cancelou |

> 📌 Argumento de tipo errado não derruba o app: o `switch` do `onGenerateRoute` faz
> `if (args is! NotaDetalheArgs) return desconhecida(configuracoes);`. Cast cego com `as` é proibido aqui.

> 💡 O estado mora **inteiro** no `_HomeScreenState`: `List<Nota> _notas`, `Etiqueta? _filtro`,
> `Ordenacao _ordenacao`, `bool _carregando`. As outras telas recebem pelo construtor e devolvem
> pelo `pop` — elevação de estado na mão, a dor que o
> [M08](../../modulos/08-estado-e-arquitetura/README.md) resolve com Riverpod.

---

## 🗂️ Estrutura de arquivos

```text
lib/
├── main.dart                     # ensureInitialized → getInstance → runApp
├── core/
│   ├── formato/
│   │   └── formato_data.dart          # formatarDataHora, sem package:intl
│   ├── rotas/
│   │   ├── rotas.dart                 # Rotas.gerar(configuracoes, repositorio)
│   │   └── rota_desconhecida_screen.dart
│   ├── tema/
│   │   └── tema_app.dart              # TemaApp.claro / TemaApp.escuro
│   └── validadores/
│       └── validadores.dart           # obrigatorio, minimo, maximo, combinar
└── features/
    └── notas/
        ├── data/
        │   └── notas_repositorio.dart
        ├── domain/
        │   ├── etiqueta.dart
        │   ├── nota.dart
        │   └── ordenacao.dart
        └── presentation/
            ├── home_screen.dart            # dona do estado
            ├── nota_detalhe_screen.dart    # + NotaDetalheArgs, AcaoDaNota
            ├── nota_form_screen.dart       # + NotaFormArgs
            └── widgets/
                ├── cartao_nota.dart
                ├── chip_etiqueta.dart
                └── estado_vazio.dart       # .inicial e .semResultado
```

Fora de `lib/`: `pubspec.yaml` (só `shared_preferences ^2.5.5` e `cupertino_icons ^1.0.8`),
`analysis_options.yaml` com `flutter_lints ^6.0.0`, e `test/` com `nota_test.dart`,
`notas_repositorio_test.dart` e `nota_form_screen_test.dart`.

---

## ✅ Como saber que terminou

Abra o [06-checklist.md](06-checklist.md) e marque item por item: os **23 requisitos funcionais**,
os três arquivos de `test/` verdes em `flutter test`, e `flutter analyze` sem nenhum aviso.

---

| # | Arquivo | Conteúdo |
|---|---|---|
| — | [README.md](README.md) | Visão geral do projeto |
| 01 | **01-especificacao.md** | Você está aqui |
| 02 | [02-passo-a-passo.md](02-passo-a-passo.md) | Construção guiada, do `flutter create` ao app rodando |
| 03 | [03-codigo-completo.md](03-codigo-completo.md) | Todos os arquivos finais de `lib/` |
| 04 | [04-testes.md](04-testes.md) | Os três arquivos de `test/`, comentados |
| 05 | [05-desafios.md](05-desafios.md) | Extensões · [🔑 gabarito](../../gabaritos/projeto-02-desafios.md) |
| 06 | [06-checklist.md](06-checklist.md) | Critérios de "pronto" |
