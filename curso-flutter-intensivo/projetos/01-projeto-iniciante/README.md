# Projeto 01 — Meu Primeiro App

Você constrói um **contador de sessões de estudo de uma tela só**: escolhe a matéria, registra
sessões de 15, 25 ou 50 minutos, acompanha as metas e alterna tema claro e escuro. Zero pacote
externo, zero segunda tela, zero `async` — só `setState` e layout. É aqui que o Módulo 05 vira
"monto uma tela sozinho": o app é pequeno de propósito, para que a dificuldade seja **organizar o
estado**, não decorar widget novo.

---

## 🎯 O que você vai praticar

| Recurso | Aula |
|---|---|
| `StatelessWidget`, `const`, `{super.key}` | [M05 · 04](../../modulos/05-introducao-ao-flutter/04-statelesswidget.md) |
| `StatefulWidget`, `setState()`, callback para o pai | [M05 · 05](../../modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md) |
| `Theme.of`, `ScaffoldMessenger` + `SnackBar` | [M05 · 07](../../modulos/05-introducao-ao-flutter/07-buildcontext.md) |
| `ColorScheme.fromSeed`, `theme`/`darkTheme`/`themeMode` | [M05 · 09](../../modulos/05-introducao-ao-flutter/09-material-e-cupertino.md) |
| `Scaffold`, `AppBar`, `textTheme`, `Icon` | [M06 · 01](../../modulos/06-widgets-e-layouts/01-scaffold-e-appbar.md) · [02](../../modulos/06-widgets-e-layouts/02-texto-tipografia-icones.md) |
| `Container`, `SizedBox`, `Row`, `Column`, `Expanded` | [M06 · 03](../../modulos/06-widgets-e-layouts/03-container-padding-sizedbox.md) · [04](../../modulos/06-widgets-e-layouts/04-row-column-expanded.md) |

---

## ⏱️ Tempo e pré-requisitos

| Item | Valor |
|---|---|
| **Tempo** | **2 h** · +25 min de testes · desafios à parte |
| **Quando** | Dia 7 do [plano intensivo](../../01-plano-intensivo.md) |
| **Onde** | Pasta nova `meu_primeiro_app`, **fora** do repositório do curso |
| **Antes, obrigatório** | [Módulo 05](../../modulos/05-introducao-ao-flutter/README.md) **completo** (aulas 1 a 9) · [M02](../../modulos/02-dart-basico/README.md) e [M03](../../modulos/03-dart-intermediario/README.md): classes, construtores nomeados, `final`, null safety |
| **Recomendado** | [Módulo 06](../../modulos/06-widgets-e-layouts/README.md) aulas 1 a 4 — cabe em paralelo |
| **Ambiente** | [Configuração](../../02-configuracao-do-ambiente.md) feita, `flutter doctor` sem erro de SDK |

> ⚠️ Se você ainda não sabe explicar **por que** `setState` redesenha a tela, volte para a aula 05
> antes de começar. O projeto inteiro se apoia nisso.

---

## 📂 Os arquivos deste projeto

| Arquivo | Para quê | Quando ler |
|---|---|---|
| [01-especificacao.md](01-especificacao.md) | Os 20 requisitos, o modelo `Materia`, as 4 matérias, a árvore de pastas | Antes da 1ª linha de código |
| [02-passo-a-passo.md](02-passo-a-passo.md) | A construção em 8 etapas — ao fim de cada uma o app **roda** | Com o editor aberto |
| [03-codigo-completo.md](03-codigo-completo.md) | Os 8 arquivos de `lib/` e o `pubspec.yaml`, inteiros | **Só depois** de travar e tentar |
| [04-testes.md](04-testes.md) | Roteiro **manual**; `flutter test` só no [Módulo 12](../../modulos/12-testes-e-debug/README.md) | Com o app rodando |
| [05-desafios.md](05-desafios.md) | Extensões opcionais D01–D07 | Com o checklist todo marcado |
| [06-checklist.md](06-checklist.md) | A definição de "pronto": uma caixa por requisito | No fim — é ele que diz se acabou |
| [Gabarito dos desafios](../../gabaritos/projeto-01-desafios.md) | Soluções comentadas de D01–D07 | Depois de tentar, nunca antes |

---

## 🗺️ A ordem certa

```text
 1. LEIA       01-especificacao.md     20 requisitos · modelo · estrutura
                    │
 2. CONSTRUA   02-passo-a-passo.md     8 etapas; o app roda ao fim de cada
                    │
                    │  travou e já tentou? só então:
 3. CONFIRA    03-codigo-completo.md   compare o seu código com o pronto
                    │
 4. VALIDE     04-testes.md            roteiro manual, com o app aberto
                    │
 5. PRONTO?    06-checklist.md         20 caixas + "No issues found!"
                    │
                    │  tudo marcado? aí sim, opcional:
 6. VÁ ALÉM    05-desafios.md          D01–D07 · gabarito depois de tentar
```

> 📌 O **05 vem depois do 06** de propósito: desafio em cima de projeto incompleto vira dívida —
> quando algo quebra, você não sabe se foi agora ou se já estava quebrado.

---

## 🧰 O que você vai precisar

| Item | Como conferir |
|---|---|
| Flutter 3.47.1 · Dart 3.13.1 | `flutter --version` |
| Editor com plugin Flutter (VS Code ou Android Studio) | Hot reload funciona |
| Chrome ou Windows desktop como alvo | `flutter run -d chrome` ou `-d windows` |

**O que você NÃO instala:**

- **Pacote do pub.dev, nenhum.** Você até **apaga** o `cupertino_icons` do `flutter create`.
- **Emulador Android.** Chrome ou a janela do Windows cobrem o projeto e abrem em segundos.
- **Mac, Xcode ou iPhone.** 🍎 iOS exigiria Mac com Xcode ou runner macOS em CI; nada aqui depende disso.
- **Banco, servidor, conta em serviço.** O app vive na memória do processo.

---

## 🚫 O que este projeto não faz

Cada omissão é proposital: o recurso existe, você é que ainda não o viu.
| O que fica de fora | Onde aparece |
|---|---|
| Qualquer pacote externo no `pubspec.yaml` | [M06 · 08 — Assets](../../modulos/06-widgets-e-layouts/08-imagens-e-assets.md) |
| 2ª tela, `Navigator`, rotas, `TextField`, `Form` | [M07](../../modulos/07-navegacao-e-formularios/README.md) |
| Riverpod, `InheritedWidget`, elevação de estado | [M08](../../modulos/08-estado-e-arquitetura/README.md) |
| `async`/`await`, `Future`, `Timer`, cronômetro | [M05 · 06](../../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) |
| API, JSON, rede | [M09](../../modulos/09-consumo-de-api/README.md) |
| Salvar no aparelho — fechou o app, perdeu tudo | [M10](../../modulos/10-persistencia-de-dados/README.md) |
| `AlertDialog`, bottom sheet, `Dismissible`, desfazer | [M06 · 10 — Gestos](../../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md) |
| Ícone do app, splash, APK assinado | [M15](../../modulos/15-build-android/README.md) |

> ⚠️ Puxar algo desta lista não é adiantar matéria, é trocar o objetivo: provar que você monta uma
> tela inteira com o que já tem na mão.

---

| Onde ir agora | |
|---|---|
| ⬅️ [Índice dos projetos](../README.md) | Os três projetos do curso |
| 🗓️ [Plano intensivo](../../01-plano-intensivo.md) | Onde isto entra |
| ▶️ [01-especificacao.md](01-especificacao.md) | **Comece por aqui** |
