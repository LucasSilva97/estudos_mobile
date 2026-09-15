# Arquitetura — Projeto Final: Foco: Organizador de Estudos

> Este arquivo diz **onde cada arquivo mora e por quê**. A [especificação](01-especificacao.md)
> define o *quê*; aqui está o *como*. As oito etapas seguem esta árvore literalmente — se você
> criar um arquivo fora dela, a etapa seguinte não vai encontrá-lo.

---

## 🏛️ As camadas

Feature-first em três camadas (ADR-03). Cada funcionalidade é uma pasta; dentro dela, três
camadas com papéis fixos.

```text
┌──────────────────────────────────────────────────────────────────┐
│  presentation                                                    │
│  telas, widgets, controllers (Notifier / AsyncNotifier)          │
│  importa: domain  ·  Flutter  ·  Riverpod                        │
│  NÃO importa: sqflite, http, shared_preferences                  │
└───────────────┬──────────────────────────────────────────────────┘
                │ depende de
                ▼
┌──────────────────────────────────────────────────────────────────┐
│  domain                                                          │
│  modelos imutáveis + contratos (abstract interface class)        │
│  importa: NADA além de dart:core e @immutable                    │
│  é o centro: não conhece ninguém                                 │
└───────────────▲──────────────────────────────────────────────────┘
                │ implementa
                │
┌───────────────┴──────────────────────────────────────────────────┐
│  data                                                            │
│  DAO (sqflite), API (http), repositórios, DTOs                   │
│  importa: domain  ·  os pacotes de infraestrutura                │
│  NÃO importa: presentation                                       │
└──────────────────────────────────────────────────────────────────┘
```

**A regra de dependência: a seta aponta para dentro.** `presentation` conhece `domain`; `data`
conhece `domain`; `domain` **não conhece ninguém**.

| Consequência prática | Por que importa |
|---|---|
| `domain/` roda em Dart puro | Testa a regra de negócio em milissegundos, sem emulador |
| Trocar `sqflite` mexe em uma pasta | O contrato em `domain/` continua igual |
| `presentation` depende do **contrato**, não do DAO | O teste de widget injeta um repositório falso |

> ⚠️ **Como saber que a regra foi quebrada:** se `materias_controller.dart` importar
> `materia_dao.dart` em vez de `materia_repositorio_contrato.dart`, a camada vazou e o teste
> virou refém do banco real. Isso é erro de revisão, não questão de estilo.

---

## 🗂️ A árvore completa de `lib/`

O comentário de cada pasta diz em **qual etapa ela nasce**. Etapa 7 cria só `test/`;
etapa 8 cria só `assets/`, `android/` e `ios/` — nenhuma das duas acrescenta pasta em `lib/`.

```text
lib/
├── main.dart                                     ← Etapa 1 · abre banco e prefs, monta ProviderScope com overrides
├── app.dart                                      ← Etapa 1 · MaterialApp, tema, onGenerateRoute
├── core/                                         ← o que é usado por MAIS DE UMA feature
│   ├── constantes/
│   │   ├── ambiente.dart                         ← Etapa 1 · FOCO_API_BASE via --dart-define
│   │   └── limites.dart                          ← Etapa 1 · tamanhos de campo, TTL, timeout
│   ├── rotas/
│   │   ├── rotas.dart                            ← Etapa 1 · nomes das 5 rotas + onGenerateRoute
│   │   └── argumentos.dart                       ← Etapa 4 · MateriaFormArgs, MateriaDetalheArgs
│   ├── tema/
│   │   ├── tema_foco.dart                        ← Etapa 1 · ColorScheme.fromSeed, claro e escuro
│   │   ├── modo_de_tema.dart                     ← Etapa 1 · enum ModoDeTema
│   │   └── cores_de_materia.dart                 ← Etapa 4 · as 8 cores fixas, como List<int>
│   ├── banco/
│   │   ├── banco_foco.dart                       ← Etapa 2 · openDatabase, onConfigure/onCreate/onUpgrade
│   │   └── texto.dart                            ← Etapa 2 · Texto.paraOrdenacao (minúsculo, sem acento)
│   ├── formato/
│   │   └── formato.dart                          ← Etapa 4 · intl: minutos -> "2 h 15 min", datas
│   ├── erros/
│   │   ├── api_exception.dart                    ← Etapa 5 · exceção técnica com statusCode
│   │   └── falhas.dart                           ← Etapa 5 · sealed class Falha + mensagens pt-BR
│   ├── http/
│   │   └── cliente_http.dart                     ← Etapa 5 · http.Client compartilhado, timeout, retry
│   ├── layout/
│   │   └── quebras.dart                          ← Etapa 6 · pontos de quebra 600 / 900 dp
│   ├── providers/
│   │   └── providers_raiz.dart                   ← Etapa 2 · banco, prefs, uuid, relógio, http
│   └── widgets/
│       ├── estado_carregando.dart                ← Etapa 4
│       ├── estado_vazio.dart                     ← Etapa 4
│       ├── estado_de_erro.dart                   ← Etapa 4
│       └── aviso_offline.dart                    ← Etapa 5 · "Atualizado há X · sem conexão"
└── features/
    ├── inicio/presentation/
    │   ├── inicio_screen.dart                    ← Etapa 4 · casca com NavigationBar (tela 1)
    │   └── painel_tab.dart                       ← Etapa 4
    ├── materias/
    │   ├── domain/
    │   │   ├── materia.dart                      ← Etapa 2
    │   │   └── materia_repositorio_contrato.dart ← Etapa 2
    │   ├── data/
    │   │   ├── materia_dao.dart                  ← Etapa 2
    │   │   └── materia_repositorio.dart          ← Etapa 2 · + materiaRepositorioProvider
    │   └── presentation/
    │       ├── materias_controller.dart          ← Etapa 3 · AsyncNotifier
    │       ├── materias_tab.dart                 ← Etapa 4
    │       ├── materia_form_screen.dart          ← Etapa 4 · tela 2
    │       ├── materia_detalhe_screen.dart       ← Etapa 4 · tela 3
    │       └── widgets/
    │           ├── materia_tile.dart             ← Etapa 4
    │           └── seletor_de_cor.dart           ← Etapa 4
    ├── sessoes/
    │   ├── domain/
    │   │   ├── sessao.dart                       ← Etapa 2
    │   │   ├── cronometro_estado.dart            ← Etapa 3
    │   │   └── sessao_repositorio_contrato.dart  ← Etapa 2
    │   ├── data/
    │   │   ├── sessao_dao.dart                   ← Etapa 2 · transações
    │   │   └── sessao_repositorio.dart           ← Etapa 2
    │   └── presentation/
    │       ├── sessoes_controller.dart           ← Etapa 3 · FamilyAsyncNotifier por materiaId
    │       ├── cronometro_controller.dart        ← Etapa 3 · Notifier + Timer
    │       └── widgets/
    │           ├── cronometro_card.dart          ← Etapa 4
    │           ├── sessao_tile.dart              ← Etapa 4
    │           └── form_sessao_sheet.dart        ← Etapa 4
    ├── metas/
    │   ├── domain/meta_semanal.dart              ← Etapa 2
    │   ├── data/meta_repositorio.dart            ← Etapa 2 · shared_preferences
    │   └── presentation/
    │       ├── meta_controller.dart              ← Etapa 3
    │       └── widgets/anel_de_meta.dart         ← Etapa 4
    ├── trilhas/
    │   ├── domain/
    │   │   ├── trilha.dart                       ← Etapa 5
    │   │   ├── trilhas_resultado.dart            ← Etapa 5
    │   │   └── trilha_repositorio_contrato.dart  ← Etapa 5
    │   ├── data/
    │   │   ├── trilha_dto.dart                   ← Etapa 5 · espelha o JSON
    │   │   ├── trilha_api.dart                   ← Etapa 5 · monta URL, confere status
    │   │   ├── trilha_cache_dao.dart             ← Etapa 5 · tabela cache_trilhas
    │   │   └── trilha_repositorio.dart           ← Etapa 5 · rede + cache + TTL
    │   └── presentation/
    │       ├── trilhas_controller.dart           ← Etapa 5 · AsyncNotifier
    │       ├── trilhas_tab.dart                  ← Etapa 5
    │       └── widgets/
    │           ├── cartao_trilha.dart            ← Etapa 5
    │           └── trilha_detalhe_sheet.dart     ← Etapa 5 · bottom sheet, não é rota
    ├── estatisticas/
    │   ├── domain/resumo_semanal.dart            ← Etapa 2
    │   └── presentation/
    │       ├── estatisticas_controller.dart      ← Etapa 3
    │       ├── estatisticas_screen.dart          ← Etapa 4 · tela 4
    │       └── widgets/barras_da_semana.dart     ← Etapa 6 · CustomPaint acessível
    └── configuracoes/presentation/
        ├── configuracoes_screen.dart             ← Etapa 4 · tela 5
        └── tema_controller.dart                  ← Etapa 3 · NotifierProvider<..., ModoDeTema>
```

---

## 📐 As decisões e o porquê

| Decisão | Alternativa | Por quê |
|---|---|---|
| **Riverpod 3.4.3 sem codegen** (ADR-01) | `riverpod_generator`, `provider`, `flutter_bloc` | `AsyncValue` já modela carregando/erro/dados, que é exatamente o RF17. Sem gerador, você lê a declaração inteira do provider na tela: zero `build_runner`, zero `.g.dart` no Git. O preço é escrever `AsyncNotifierProvider<TrilhasController, TrilhasResultado>(TrilhasController.new)` à mão — o Foco tem ~20 providers, longe dos ~40 em que o gerador compensa |
| **Navigator 1.0 + `onGenerateRoute`** (ADR-02) | `go_router ^18.0.1`, Navigator 2.0 puro | Vem no SDK, zero dependência, e ensina a pilha de verdade. As 5 rotas do Foco são planas e duas delas devolvem resultado (`Navigator.pop(true)`) — cenário em que o Navigator 1.0 é mais direto. Deep link entraria como motivo para trocar, e não existe aqui |
| **Material 3 nas duas plataformas** (ADR-08) | Cupertino no iOS, design system próprio | `useMaterial3` já vem ligado no Flutter 3.47: escolher Material 2 seria remar contra o SDK. `ColorScheme.fromSeed` gera claro e escuro coerentes de uma cor só, o que entrega o RNF01 sem calcular contraste à mão. Manter um único conjunto de widgets também mantém um único conjunto de testes |
| **`sqflite` + `shared_preferences`** (ADR-05) | `hive`, `drift`, tudo em `shared_preferences` | Três problemas, três ferramentas. Matérias e sessões são consultáveis e relacionadas — `SUM`, `GROUP BY` e `ON DELETE CASCADE` resolvem o RF16 e o RF08 em SQL. A meta é um inteiro: criar tabela para guardar `300` seria desproporcional. E SQL é conhecimento transferível para qualquer stack |
| **Contrato em `domain`, DAO em `data`** (ADR-03) | Controller falando direto com o DAO | É o que permite o teste de widget rodar sem banco: o provider do contrato é sobrescrito por um falso |
| **Banco e prefs abertos em `main()`** | `FutureProvider` para o banco | Toda tela ficaria assíncrona por causa da infraestrutura. Abrindo antes do `runApp` e injetando por `overrides`, os providers são síncronos e o RNF14 fica fácil de cumprir |
| **`mocktail ^1.0.5`** (ADR-06) | `mockito` com `build_runner` | Mantém a promessa de não depender de geração de código: `class MateriaRepositorioFalso extends Mock implements MateriaRepositorioContrato {}` e acabou |

---

## 🔁 Como um dado atravessa o app

Um caso concreto: **você estuda 45 minutos de Cálculo e registra a sessão.**

```text
[1] FormSessaoSheet                        (presentation)
      valida 1..480, data não futura
      ref.read(sessoesDaMateriaProvider(id).notifier).registrar(...)
                    │
[2] SessoesController extends FamilyAsyncNotifier<List<Sessao>, String>
      monta Sessao(id: uuid.v4(), materiaId: ..., inicioEm: ..., minutos: 45)
      state = await AsyncValue.guard(...)
                    │
[3] SessaoRepositorioContrato.registrar(Sessao)   (domain — só o contrato)
                    │
[4] SessaoRepositorio                      (data)
      traduz exceção técnica em Falha
                    │
[5] SessaoDao.registrar(Sessao)            (data)
      db.transaction((txn) async {
        txn.insert('sessoes', sessao.paraLinha());
        txn.rawUpdate('UPDATE materias SET minutos = minutos + ? WHERE id = ?',
                      [45, materiaId]);            ← ? e whereArgs, RNF11
      });
                    │
[6] foco.db  ← as duas escritas valem como uma só
                    │  … e a volta:
[7] ref.invalidate(materiasProvider) e ref.invalidate(resumoSemanalProvider)
[8] MateriasController relê pelo contrato → MateriaDao.listar() → Materia.deLinha()
[9] MateriaTile e AnelDeMeta rebuildam com o novo total; PainelTab mostra 45 min a mais
```

Repare no que **não** aparece no caminho: `FormSessaoSheet` nunca viu `sqflite`, e `SessaoDao`
nunca viu um widget. Entre eles só passou `Sessao` — uma classe de `domain`, que não importa
nem Flutter nem banco.

> 📌 **Por que a transação do passo [5] é obrigatória.** Sem ela, um app morto no meio grava a
> sessão e não atualiza `materias.minutos`. O banco fica consistente em cada linha e errado no
> total — o pior tipo de bug, porque não lança exceção nenhuma.

---

## 🧪 Por que esta arquitetura é testável

| Camada | O que você testa sem a outra | Como |
|---|---|---|
| `domain` | `MetaSemanal.progresso`, `Sessao.ehDeHoje`, os limites 1–480, `ResumoSemanal.mediaDiariaMinutos` | `flutter test` em Dart puro: sem widget, sem banco, sem rede. Milissegundos |
| `data` (banco) | `MateriaDao`, `SessaoDao`, migração v1→v2→v3, o `ORDER BY` de `Álgebra` | `sqflite_common_ffi` com `inMemoryDatabasePath`, **no Windows**, sem emulador |
| `data` (rede) | `TrilhaApi` em `200`, `500` e JSON inválido; o TTL do cache | `MockClient` do próprio `http`, ou `mocktail` quando precisar verificar a chamada |
| `data` (prefs) | `MetaRepositorio` com valor padrão e valor gravado | `SharedPreferences.setMockInitialValues({...})` |
| `presentation` (controller) | `MateriasController`, `TrilhasController` e seus estados de erro | `ProviderContainer(overrides: [...])` + `addTearDown(container.dispose)` — sem árvore de widgets |
| `presentation` (tela) | As 5 telas, os 4 estados de UI, 48 dp e 200% de fonte | `ProviderScope(overrides: [repositórios falsos])` + `pumpWidget` |
| Tudo junto | Criar matéria → registrar sessão → ver a meta subir | `integration_test` num aparelho ou emulador |

**O que torna cada linha acima possível é sempre a mesma coisa:** nenhuma classe cria as suas
dependências por dentro. O DAO recebe o `Database`, o service recebe o `http.Client`, o
repositório recebe o DAO, o controller lê o **contrato** por provider. Trocar qualquer um deles
no teste é uma linha de `overrides`.

> 💡 Código testável e código desacoplado não são duas metas: são a mesma. Se um teste exige
> emulador para validar uma regra de negócio, o problema está na arquitetura, não no teste.

---

## 🧭 Navegação do projeto

[README](README.md) · [01 Especificação](01-especificacao.md) ·
**02 Arquitetura (você está aqui)** ·
[03 Etapa 1 — Fundação](03-etapa-1-fundacao.md) ·
[04 Etapa 2 — Domínio e dados](04-etapa-2-dominio-e-dados.md) ·
[05 Etapa 3 — Estado com Riverpod](05-etapa-3-estado-com-riverpod.md) ·
[06 Etapa 4 — Telas e navegação](06-etapa-4-telas-e-navegacao.md) ·
[07 Etapa 5 — API e trilhas](07-etapa-5-api-e-trilhas.md) ·
[08 Etapa 6 — Responsividade e acessibilidade](08-etapa-6-responsividade-e-acessibilidade.md) ·
[09 Etapa 7 — Testes](09-etapa-7-testes.md) ·
[10 Etapa 8 — Ícone, splash e versão](10-etapa-8-icone-splash-e-versao.md) ·
[11 Critérios de aceite](11-criterios-de-aceite.md) ·
[12 Desafios](12-desafios.md) ·
[13 Checklist](13-checklist.md)

| ⬅️ Anterior | 🏠 Início | ➡️ Próximo |
|---|---|---|
| [01 — Especificação](01-especificacao.md) | [README do curso](../../README.md) | [03 — Etapa 1: Fundação](03-etapa-1-fundacao.md) |
