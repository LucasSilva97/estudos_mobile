# Projeto 02 — Bloco de Notas de Estudo

Você constrói um app de notas de estudo com título, conteúdo e etiqueta: três telas de verdade,
navegação com rotas nomeadas, um `Form` validado e dados que continuam lá depois de fechar o app.
É o primeiro projeto cujo código não cabe em um arquivo só: você reparte o app em pastas, passa
dados entre telas pelo `Navigator` e sente a dor de manter o estado em um `setState` só — a dor
que dá sentido ao Riverpod no módulo 08 e ao `sqflite` no módulo 10.

---

## 🎯 O que você vai praticar

- **Rotas nomeadas** — `onGenerateRoute`, classes `*Args`, `pushNamed<T>` com resultado tipado ·
  [M07 · 2 e 3](../../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md)
- **Formulário validado** — `GlobalKey<FormState>`, `AutovalidateMode` e `PopScope` contra o
  rascunho perdido · [M07 · 6 e 7](../../modulos/07-navegacao-e-formularios/06-formularios.md)
- **Estado elevado na mão** — `setState`, `dispose`, `context.mounted` após `await` ·
  [M05 · 5](../../modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md)
- **Estados de UI** — `ListView.separated`, `Dismissible`, `SnackBar` de desfazer, carregando /
  vazio / sem resultado · [M06 · 9 e 12](../../modulos/06-widgets-e-layouts/12-estados-de-ui.md)
- **Persistência em JSON** — repositório sobre `SharedPreferences`, objeto → `Map` → `String` ·
  [M10 · 2](../../modulos/10-persistencia-de-dados/02-shared-preferences.md)
- **Primeiros testes** — unitário do modelo e do repositório, e um de widget no formulário ·
  [M12 · 5 e 6](../../modulos/12-testes-e-debug/06-testes-de-widget.md)

---

## ⏱️ Tempo e pré-requisitos

| Item | Detalhe |
|---|---|
| **Tempo** | **7 h** — 3 h no dia 15 (telas e navegação) + 4 h no dia 16 (`Form`, prefs, testes) |
| **Pasta do app** | `bloco_notas` — o `name` do `pubspec.yaml` e o prefixo de todo `import` |
| **Concluído antes** | Dart (M01 a M04) e, inteiros, M05, M06 e [M07](../../modulos/07-navegacao-e-formularios/README.md) |
| **Leitura antecipada** | Fora de ordem, de propósito: M10 · 2 e M12 · 5 e 6 |
| **Antes, no dia 15** | [Cumulativa 02](../../avaliacoes/cumulativa-02-flutter-ui.md) — módulos 05 a 07 |

> ⚠️ Não comece sem o M07 fechado: rotas nomeadas e `Form` são **o** assunto daqui, e aprendê-los
> enquanto constrói o app é o caminho mais longo.

---

## 📂 Os arquivos deste projeto

| Arquivo | Para quê | Quando ler |
|---|---|---|
| [01-especificacao.md](01-especificacao.md) | Os 23 requisitos, o modelo, as telas, as pastas | **Primeiro**, inteiro, antes do `flutter create` |
| [02-passo-a-passo.md](02-passo-a-passo.md) | Do projeto vazio ao app rodando, guiado | Ao lado do editor, o tempo todo |
| [03-codigo-completo.md](03-codigo-completo.md) | Os 16 arquivos de `lib/` e o `pubspec.yaml` | Quando algo não bater — para **comparar**, não colar |
| [04-testes.md](04-testes.md) | Os três arquivos de `test/`, comentados | Com o app rodando, na parte 2 |
| [05-desafios.md](05-desafios.md) | Extensões opcionais, além do checklist | Com o checklist fechado |
| [06-checklist.md](06-checklist.md) | O "pronto": RF01–RF23, `test` verde, `analyze` limpo | No fim do dia 16, item por item |
| [🔑 gabarito](../../gabaritos/projeto-02-desafios.md) | A solução comentada de cada desafio | **Só depois** de tentar sozinho |

---

## 🗺️ A ordem certa

```text
  01-especificacao.md    LER        o que o app faz, antes do código (~20 min)
          ▼
  02-passo-a-passo.md    CONSTRUIR  dia 15 telas e rotas · dia 16 Form e prefs
          ▼
  03-codigo-completo.md  CONFERIR   só o arquivo que está te travando
          ▼
  04-testes.md           VALIDAR    flutter test verde · flutter analyze limpo
          ▼
  06-checklist.md        FECHAR     RF01 a RF23, um por um
          ▼
  05-desafios.md         ESTENDER   opcional · 🔑 gabarito ao lado
```

> 💡 O 03 não é atalho: ele serve para quando o seu `onGenerateRoute` não compila.

---

## 🧰 O que você vai precisar

| Precisa | Detalhe |
|---|---|
| Flutter **3.47.1** / Dart **3.13.1** | `flutter --version` confere · [ambiente](../../02-configuracao-do-ambiente.md) |
| Windows 11, `flutter doctor` sem erro | Emulador Android, `-d windows` ou `-d chrome` — tanto faz |
| VS Code ou Android Studio | Extensão Flutter e formatador ligado no salvar |
| Duas dependências, e só | `shared_preferences: ^2.5.5`, `cupertino_icons: ^1.0.8`; em dev, `flutter_test` e `flutter_lints: ^6.0.0` |

**O que você NÃO precisa instalar:** banco, servidor, conta de serviço — nem nenhum pacote além
dos dois acima. Sem `http`, `intl`, `uuid`, `sqflite`, `go_router` ou `flutter_riverpod`: cada um
tem um módulo próprio, e antecipá-los esconde o que se ensina aqui.

> 🪟 **Nada aqui exige Mac.** Tudo roda no Windows 11. O `.ipa` exige macOS — máquina física ou
> *runner* em CI — e isso é o [módulo 16](../../modulos/16-build-ios/README.md).

---

## 🚫 O que este projeto não faz

| Fora de escopo | Onde isso aparece |
|---|---|
| Riverpod, `Notifier`, `ProviderScope`, `InheritedWidget` | [M08](../../modulos/08-estado-e-arquitetura/README.md) |
| API, `package:http`, nuvem | [M09](../../modulos/09-consumo-de-api/README.md) |
| `sqflite`, consultas, migrações | [M10 · 4 a 6](../../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) |
| Fotos, permissões, notificações | [M11](../../modulos/11-recursos-nativos/README.md) |
| `mocktail`, fakes, teste de integração | [M12 · 7 e 8](../../modulos/12-testes-e-debug/07-mocks-e-fakes.md) |
| `go_router` | [M07 · 9](../../modulos/07-navegacao-e-formularios/09-go-router-opcional.md) |
| Ícone, splash, assinatura, release | [M15](../../modulos/15-build-android/README.md) e M16 |

> 📌 Guardar uma **lista que cresce** em `shared_preferences` é abuso, e é de propósito: o teto de
> 200 notas faz você sentir o custo de reescrever o arquivo inteiro a cada gravação — a dor que
> justifica o `sqflite`.

---

📚 [Índice dos projetos](../README.md) · 🗓️ [Plano do curso](../../01-plano-intensivo.md) — **dias
15 e 16** · ▶️ Comece pela [especificação](01-especificacao.md)
