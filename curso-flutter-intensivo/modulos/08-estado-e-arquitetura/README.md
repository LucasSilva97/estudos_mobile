# Módulo 08 — Estado e Arquitetura

> **Trilha:** Flutter aplicado · **Ferramenta principal:** Riverpod 3.4.3 (sem *code generation*)
> **Tempo estimado:** ~7 h 40 min de aulas + ~2 h de exercícios e avaliação

Até aqui você aprendeu a desenhar telas (módulo 06) e a navegar entre elas (módulo 07). Cada
tela funcionava sozinha, com o seu próprio `setState`. Este módulo ataca o problema que aparece
no minuto em que **duas telas precisam do mesmo dado**: onde esse dado mora, quem pode mudá-lo,
quem é avisado quando ele muda e como testar isso sem abrir o app.

O nome disso é **gerenciamento de estado**.

> **Estado** — qualquer informação que o seu app guarda e que pode mudar enquanto ele roda: os
> minutos estudados hoje, a lista de matérias, se o modo escuro está ligado, se a requisição
> ainda está carregando. Se muda e a tela precisa refletir a mudança, é estado.

Este módulo é diferente dos anteriores em um ponto: ele **começa pelo problema**. As quatro
primeiras aulas não citam nenhuma biblioteca. Você vai sentir a dor na pele, tentar resolver com
o que o próprio Flutter oferece, descobrir onde isso quebra e só então escolher uma ferramenta —
com argumento, não por moda. Depois disso, o Riverpod entra e faz sentido imediato.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- Reconhecer, pelos **sintomas**, que um app precisa de gerenciamento de estado: *rebuild* em
  excesso, estado perdido ao navegar, regra de negócio colada na UI, impossibilidade de testar.
- Aplicar **elevação de estado** (*lifting state up*) e saber exatamente até onde ela aguenta.
- Escrever um **`InheritedWidget`** na mão, com `of(context)` e `updateShouldNotify` — e entender
  por que `Theme.of(context)` e `MediaQuery.of(context)` funcionam.
- Justificar, com uma tabela honesta, **por que este curso escolheu Riverpod** e em que situações
  você **não** deve usá-lo.
- Instalar e configurar o `flutter_riverpod ^3.4.3`, envolver o app em `ProviderScope` e consumir
  estado com `ConsumerWidget`, `WidgetRef` e `Consumer`.
- Escolher corretamente entre **`ref.watch`**, **`ref.read`** e **`ref.listen`** — o erro número
  um de quem começa com Riverpod.
- Modelar estado síncrono com **`Notifier<T>` + `NotifierProvider`**, respeitando imutabilidade.
- Modelar estado assíncrono com **`AsyncNotifier<T>` + `AsyncValue`**, cobrindo carregando, erro
  e dados com `.when`, `AsyncValue.guard` e recarga sem piscar a tela.
- Usar **`.family`**, **descarte automático**, `ref.invalidate`, `ref.refresh`, `ref.keepAlive`,
  `ref.onDispose` e `ref.mounted` sem cair nas armadilhas clássicas.
- Organizar o projeto em **arquitetura *feature-first*** de 3 camadas (`presentation`, `domain`,
  `data`) e explicar a regra de dependência.
- Aplicar **injeção de dependências** com providers e `overrides`, e testar a lógica inteira com
  `ProviderContainer` — sem emulador, sem aparelho, direto no Windows.

---

## ✅ Pré-requisitos

| Requisito | Onde resolver |
|---|---|
| Flutter 3.47.1 e Dart 3.13.1 funcionando (`flutter doctor` sem erro fatal) | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) |
| `StatefulWidget`, `setState` e ciclo de vida do `State` | [Módulo 05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md) |
| `BuildContext` e árvore de widgets | [05 — BuildContext](../05-introducao-ao-flutter/07-buildcontext.md) |
| Montar telas com `Scaffold`, `Column`, `ListView` | [Módulo 06 — Widgets e Layouts](../06-widgets-e-layouts/README.md) |
| Os quatro estados de UI (carregando, vazio, erro, dados) | [06 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) |
| `Navigator`, rotas nomeadas, argumentos e retorno | [Módulo 07 — Navegação e Formulários](../07-navegacao-e-formularios/README.md) |
| Classes, construtores nomeados, herança e interfaces em Dart | [Módulo 03 — Dart Intermediário](../03-dart-intermediario/README.md) |
| `Future`, `async`/`await` e tratamento de exceção | [04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) |

Confirme o ambiente antes de começar:

```powershell
flutter --version
```

Você deve ver **Flutter 3.47.1** e **Dart 3.13.1**. Se o comando falhar, volte para
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

---

## 🗺️ Ordem recomendada das aulas

Siga **na ordem**. Este módulo é uma história contínua: cada aula resolve um problema que a aula
anterior deixou em aberto, no **mesmo aplicativo**.

| # | Aula | Tempo | O que você leva dela |
|---|---|---|---|
| 1 | [O problema do estado](01-o-problema-do-estado.md) | 35 min | *Prop drilling*, limites do `setState`, os 4 sintomas |
| 2 | [Elevação de estado](02-elevacao-de-estado.md) | 40 min | *Lifting state up*, valor desce / *callback* sobe, onde quebra |
| 3 | [InheritedWidget](03-inheritedwidget.md) | 50 min | `of(context)`, `updateShouldNotify`, `dependOnInheritedWidgetOfExactType` |
| 4 | [Por que Riverpod](04-por-que-riverpod.md) | 35 min | Comparação honesta com Provider, BLoC e `setState`; quando **não** usar |
| 5 | [Riverpod: primeiros passos](05-riverpod-primeiros-passos.md) | 50 min | `ProviderScope`, `Provider`, `ConsumerWidget`, `watch` × `read` × `listen` |
| 6 | [Notifier e NotifierProvider](06-notifier-e-notifierprovider.md) | 50 min | `Notifier<T>`, `build()`, `state`, imutabilidade, `.notifier` |
| 7 | [AsyncNotifier e AsyncValue](07-asyncnotifier-e-asyncvalue.md) | 55 min | `Future<T> build()`, `.when`, `.value`, `.requireValue`, `AsyncValue.guard` |
| 8 | [Family, autoDispose e listen](08-family-autodispose-listen.md) | 50 min | `.family`, descarte automático, `invalidate`, `refresh`, efeitos colaterais |
| 9 | [Arquitetura feature-first](09-arquitetura-feature-first.md) | 45 min | `presentation` / `domain` / `data`, regra de dependência, pastas do Foco |
| 10 | [Injeção de dependências](10-injecao-de-dependencias.md) | 50 min | `overrides`, `ProviderContainer`, testes sem emulador, comparação com `get_it` |

**Total das aulas: 460 min (≈ 7 h 40 min).**

No ritmo **Intensivo recomendado** (30 dias) este módulo ocupa os **dias 17 e 18**:

| Dia | Conteúdo |
|---|---|
| 17 | Aulas 1 a 5 |
| 18 | Aulas 6 a 10 + exercícios + avaliação |

---

## 📝 Exercícios e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Lista de exercícios do módulo | [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md) | Ao terminar cada aula, faça os exercícios que citam aquele assunto |
| Avaliação do módulo | [avaliacoes/modulo-08-estado-e-arquitetura.md](../../avaliacoes/modulo-08-estado-e-arquitetura.md) | Só depois das 10 aulas e dos exercícios obrigatórios |

Os gabaritos ficam em `gabaritos/08-estado-e-arquitetura.md` e estão linkados dentro de cada
exercício. Regra de ouro deste módulo: **tente por 20 minutos antes de abrir o gabarito.** Erro de
estado é justamente o tipo de erro que só ensina quando você o depura.

---

## 🧰 O projeto que acompanha o módulo

Você cria **um único projeto** na Aula 1 e ele evolui até a Aula 10. Nada de exemplos soltos: é o
mesmo app melhorando a cada aula, e no fim ele já tem a forma do projeto final **Foco**.

```powershell
flutter create foco_estado
```

Evolução, aula por aula:

```text
foco_estado/
├── lib/
│   ├── main.dart                     ← Aula 1 (tudo junto, com prop drilling)
│   ├── escopo_foco.dart              ← Aula 3 (InheritedWidget na mão)
│   ├── estado/
│   │   ├── providers_basicos.dart    ← Aula 5
│   │   ├── sessoes_notifier.dart     ← Aula 6
│   │   ├── materias_notifier.dart    ← Aula 6
│   │   └── trilhas_notifier.dart     ← Aula 7
│   ├── dados/
│   │   └── trilhas_fonte.dart        ← Aula 7
│   ├── telas/
│   │   └── materia_detalhe_screen.dart  ← Aula 8
│   ├── core/                         ← Aula 9 (reorganização feature-first)
│   └── features/
│       └── materias/
│           ├── data/{materia_dao.dart,materia_repositorio.dart}
│           ├── domain/{materia.dart,materia_repositorio_contrato.dart}
│           └── presentation/{materias_controller.dart,materias_tab.dart,widgets/materia_tile.dart}
├── test/
│   └── materias_controller_test.dart ← Aula 10
└── pubspec.yaml
```

> 🪟 **Windows, sem Android Studio ainda?** Enquanto o SDK do Android não estiver instalado, rode
> tudo em `flutter run -d windows` ou `flutter run -d chrome`. Nenhuma aula deste módulo depende
> de recurso exclusivo de celular — o assunto aqui é estado, e estado é igual em toda plataforma.
> Assim que o emulador Android estiver pronto, repita os mesmos exemplos nele.

Digite o código; não copie e cole. Em gerenciamento de estado, o aprendizado vem de errar a
escolha entre `watch` e `read` e ver o resultado na tela.

---

## 🔗 Como este módulo se conecta ao resto do curso

| O que você aprende aqui | De onde veio | Para onde vai |
|---|---|---|
| Imutabilidade do estado | [03 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md) | [13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md) |
| `AsyncValue` e os 4 estados de UI | [06 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md) | [09 — API com Riverpod](../09-consumo-de-api/09-api-com-riverpod.md) |
| Contrato de repositório | [03 — Abstratas e interfaces](../03-dart-intermediario/05-abstratas-e-interfaces.md) | [10 — sqflite CRUD](../10-persistencia-de-dados/05-sqflite-crud.md) |
| Injeção de dependências | [04 — Exceptions](../04-dart-avancado/01-exceptions.md) | [12 — Mocks e fakes](../12-testes-e-debug/07-mocks-e-fakes.md) |
| Arquitetura *feature-first* | [03 — Arquivos, bibliotecas e pacotes](../03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md) | [Projeto final — Arquitetura](../../projetos/03-projeto-final-multiplataforma/02-arquitetura.md) |
| `ref.listen` para navegação | [07 — Navigator: a pilha](../07-navegacao-e-formularios/01-navigator-a-pilha.md) | [11 — Botão voltar e gestos](../11-recursos-nativos/08-botao-voltar-e-gestos.md) |

O módulo seguinte, [09 — Consumo de API](../09-consumo-de-api/README.md), troca a fonte de dados
falsa da Aula 7 por requisições HTTP reais — e você vai ver que **nada** da camada de estado
precisa mudar. É exatamente esse o ganho da arquitetura que você monta aqui.

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando for verdade de fato. Este é o portão de entrada do módulo 09 e, na
prática, do projeto final.

- [ ] Li as **10 aulas** inteiras, na ordem.
- [ ] Criei o projeto `foco_estado` e digitei o **código completo** de todas as aulas.
- [ ] Consigo explicar, sem consultar, o que é *prop drilling* e citar 4 sintomas de que um app
      precisa de gerenciamento de estado.
- [ ] Sei dizer por que `setState` não resolve estado compartilhado entre rotas diferentes.
- [ ] Escrevi um `InheritedWidget` na mão, com `of(context)` e `updateShouldNotify`, e ele funcionou.
- [ ] Consigo justificar a escolha do Riverpod **e** dizer um caso em que eu não o usaria.
- [ ] Explico a diferença entre `ref.watch`, `ref.read` e `ref.listen` e dou um exemplo de cada.
- [ ] Sei por que `state.add(item)` **não** avisa a interface, e o que escrever no lugar.
- [ ] Trato carregando, erro e dados com `AsyncValue.when` sem usar `.valueOrNull`
      (que não existe mais no Riverpod 3).
- [ ] Uso `ref.listen` para `SnackBar` e navegação, e nunca disparo efeito colateral dentro do `build`.
- [ ] Desenho de cabeça a estrutura `features/<feature>/{presentation,domain,data}` e explico a
      regra de dependência.
- [ ] Meu `domain/` **não importa** `package:flutter/material.dart`.
- [ ] Escrevi um teste com `ProviderContainer` + `addTearDown(container.dispose)` que passa com
      `flutter test`, sem emulador.
- [ ] Meu projeto passa em `flutter analyze` **sem nenhum aviso**.
- [ ] Fiz **todos os exercícios obrigatórios** de
      [exercicios/08-estado-e-arquitetura.md](../../exercicios/08-estado-e-arquitetura.md).
- [ ] Acertei **7 ou mais** das 10 questões de
      [avaliacoes/modulo-08-estado-e-arquitetura.md](../../avaliacoes/modulo-08-estado-e-arquitetura.md).

Se algum item ficou desmarcado, a tabela "Se você teve dificuldade" da avaliação diz exatamente
qual aula revisar.

---

| ⬅️ Módulo anterior | 🏠 Curso | ➡️ Próximo módulo |
|---|---|---|
| [07 — Navegação e Formulários](../07-navegacao-e-formularios/README.md) | [README do curso](../../README.md) | [09 — Consumo de API](../09-consumo-de-api/README.md) |
