# Especificação — Projeto 01: Meu Primeiro App

> **Pasta:** `meu_primeiro_app` · **Tempo:** 2 h · **Dia 7** do [plano intensivo](../../01-plano-intensivo.md)
> · Cobre o [Módulo 05](../../modulos/05-introducao-ao-flutter/README.md) e as aulas 1–4 do
> [Módulo 06](../../modulos/06-widgets-e-layouts/README.md).

**O que o app faz:** contador de sessões de estudo de **uma tela só** — você escolhe a matéria,
registra sessões de 15, 25 ou 50 minutos, acompanha o progresso das metas e alterna tema claro e
escuro. É para quem acabou de aprender `setState` e precisa provar que monta uma tela inteira sem
nenhum pacote externo.

> 📌 Nada aqui é novo: é o mesmo `meu_primeiro_app` das aulas do módulo 05, escrito por você do zero
> e sem o cronômetro. Crie-o em uma **pasta nova** (ex.: `C:\src\projetos\meu_primeiro_app`),
> mantendo o nome de pacote `meu_primeiro_app`.

---

## 🎯 O que você vai praticar

| Recurso | Onde foi ensinado |
|---|---|
| `main()`, `runApp()`, `MaterialApp`, árvore de widgets | [M05 · 03](../../modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md) |
| `StatelessWidget`, `const`, `{super.key}`, `required` | [M05 · 04](../../modulos/05-introducao-ao-flutter/04-statelesswidget.md) |
| `StatefulWidget`, `setState()`, callback para o pai | [M05 · 05](../../modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md) |
| `SegmentedButton<int>` | [M05 · 06](../../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) |
| `Theme.of`, `ScaffoldMessenger` + `SnackBar` | [M05 · 07](../../modulos/05-introducao-ao-flutter/07-buildcontext.md) |
| `ColorScheme.fromSeed`, `theme`/`darkTheme`/`themeMode` | [M05 · 09](../../modulos/05-introducao-ao-flutter/09-material-e-cupertino.md) |
| `Scaffold`, `AppBar`, `Text`, `textTheme`, `Icon` | [M06 · 01](../../modulos/06-widgets-e-layouts/01-scaffold-e-appbar.md) · [02](../../modulos/06-widgets-e-layouts/02-texto-tipografia-icones.md) |
| `Container`, `Padding`, `SizedBox`, `Row`, `Column`, `Expanded` | [M06 · 03](../../modulos/06-widgets-e-layouts/03-container-padding-sizedbox.md) · [04](../../modulos/06-widgets-e-layouts/04-row-column-expanded.md) |

---

## 📋 Requisitos funcionais

Cada item é **verificável**: abra o app e responda "sim" ou "não".

| # | Requisito |
|---|---|
| **RF01** | O app abre direto na `HomeTela`. Não há 2ª tela, `Navigator.push` nem rota nomeada. |
| **RF02** | A `AppBar` tem título `Meu Primeiro App` e, como 1ª `action`, um `IconButton` de tema. |
| **RF03** | Esse botão cicla `ThemeMode.system` → `light` → `dark` → `system`; ícone e `tooltip` combinam com o modo atual. |
| **RF04** | Claro e escuro saem de `ColorScheme.fromSeed` com a **mesma** semente `Color(0xFF3F51B5)`; só muda o `brightness`. |
| **RF05** | Fora de `tema_app.dart` não há cor literal (`Colors.x`, `Color(0x…)`): toda cor vem do `colorScheme`. |
| **RF06** | A tela lista exatamente **4 matérias fixas**, definidas em código. |
| **RF07** | Há sempre **exatamente uma** matéria selecionada; começa em `'dart'`. |
| **RF08** | Tocar num cartão troca a seleção e mostra um `SnackBar` dizendo para onde vão os próximos minutos. |
| **RF09** | O cartão selecionado é visualmente distinto, com cores do `colorScheme`. |
| **RF10** | Um `SegmentedButton<int>` escolhe a duração entre **15, 25 e 50 min**; padrão 25. |
| **RF11** | "Concluir sessão" soma `+1` sessão e a duração atual aos minutos totais **e** aos da matéria selecionada. |
| **RF12** | "Remover sessão" desfaz o RF11 usando a duração **atual**. |
| **RF13** | **Nada fica negativo:** tudo passa por `clamp`; com `0` sessões, remover e zerar ficam desabilitados (`onPressed: null`). |
| **RF14** | "Zerar o dia" zera sessões e minutos totais, restaura os minutos iniciais das 4 matérias e confirma com `SnackBar`. |
| **RF15** | Cada `CartaoMateria` mostra ícone, nome, `<tempo> de <meta> min` e barra de progresso. |
| **RF16** | O progresso é `(minutosEstudados / metaMinutos).clamp(0.0, 1.0)` — **nunca passa de 100 %**. |
| **RF17** | Com `minutosEstudados >= metaMinutos`, o cartão exibe o ícone de meta atingida. |
| **RF18** | Tempo formatado: `< 60` → `45 min`; múltiplo de 60 → `2 h`; senão → `1 h 15 min`. |
| **RF19** | A `BarraResumo` mostra sessões, minutos, média e matéria em foco; com `0` sessões a média é `—` (nunca divide por zero). |
| **RF20** | Fechou o app, perdeu tudo — **intencional**. `flutter analyze` dá `No issues found!` e não há `RenderFlex overflowed` a partir de 320 px. |

---

## 🚫 Fora de escopo

| O que NÃO entra | Onde aparece |
|---|---|
| Qualquer pacote externo no `pubspec.yaml` | [M06 · 08 — Assets](../../modulos/06-widgets-e-layouts/08-imagens-e-assets.md) |
| 2ª tela, `Navigator`, rotas, `TextField`, `Form`, criar/excluir matéria | [M07](../../modulos/07-navegacao-e-formularios/README.md) |
| Riverpod, `InheritedWidget`, elevação formal de estado | [M08](../../modulos/08-estado-e-arquitetura/README.md) |
| `async`/`await`, `Future`, `Timer`, cronômetro regressivo | [M05 · 06](../../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) |
| API, JSON, rede | [M09](../../modulos/09-consumo-de-api/README.md) |
| `shared_preferences`, `sqflite`, disco (ver RF20) | [M10](../../modulos/10-persistencia-de-dados/README.md) |
| `AlertDialog`, bottom sheet, `Dismissible`, "desfazer" | [M06 · 10 — Gestos](../../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md) |
| Ícone do app, splash, APK assinado | [M15](../../modulos/15-build-android/README.md) |

> 🍎 Rode com `flutter run -d chrome` ou `-d windows`. iPhone exigiria Mac com Xcode ou runner macOS
> em CI — nenhum passo daqui depende disso.

---

## 🧱 Modelo de dados

Uma classe só, imutável, em `lib/modelos/materia.dart`. O que muda vive no `_HomeTelaState`.

```dart
import 'package:flutter/material.dart';

/// Matéria de estudo. Imutável: para alterar minutos, use [copyWith].
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.icone,
    required this.minutosEstudados,
    required this.metaMinutos,
  }) : assert(metaMinutos > 0, 'A meta precisa ser maior que zero.');

  final String id;
  final String nome;
  final IconData icone;
  final int minutosEstudados;
  final int metaMinutos;

  /// RF16 — o clamp é o que impede passar de 100 %.
  double get progresso => (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  /// RF17.
  bool get metaAtingida => minutosEstudados >= metaMinutos;

  /// RF18 — "45 min", "2 h" ou "1 h 15 min".
  String get tempoFormatado {
    final int horas = minutosEstudados ~/ 60;
    final int restante = minutosEstudados % 60;
    if (horas == 0) {
      return '$restante min';
    }
    return restante == 0 ? '$horas h' : '$horas h $restante min';
  }

  Materia copyWith({int? minutosEstudados}) {
    return Materia(
      id: id,
      nome: nome,
      icone: icone,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaMinutos: metaMinutos,
    );
  }
}

/// RF06. É `const`: o RF14 copia daqui de volta.
const List<Materia> materiasIniciais = <Materia>[ /* as 4 da tabela */ ];
```

| `id` | `nome` | `icone` | `minutosEstudados` | `metaMinutos` |
|---|---|---|---|---|
| `'dart'` | Dart | `Icons.code` | 95 | 120 |
| `'flutter'` | Flutter | `Icons.phone_android` | 40 | 120 |
| `'git'` | Git e terminal | `Icons.terminal` | 20 | 90 |
| `'testes'` | Testes | `Icons.fact_check_outlined` | 0 | 60 |

---

## 📱 Telas

**Uma tela. Só uma.** A `HomeTela`, rolável de cima a baixo.

| Região | Mostra | O usuário faz |
|---|---|---|
| `AppBar` | Título e ícone do modo de tema | Toca e cicla automático → claro → escuro |
| `BarraResumo` | Sessões, minutos, média, matéria em foco | Só lê |
| `SegmentedButton` | `15 min` · `25 min` · `50 min` | Escolhe quanto vale a próxima sessão |
| `ContadorSessoes` | Sessões em número grande e a duração | Concluir, remover (`−`), zerar (`↺`) |
| 4 × `CartaoMateria` | Ícone, nome, `X de Y min`, progresso, selo | Toca para escolher onde os minutos entram |
| Rodapé | `Recebendo minutos: <matéria>` | Só lê; confirma o RF07 |

---

<a id="estrutura-de-arquivos"></a>
## 🗂️ Estrutura de arquivos

```text
meu_primeiro_app/
├── pubspec.yaml                  <- SEM dependência além do SDK do Flutter
├── analysis_options.yaml         <- flutter_lints ^6.0.0, do flutter create
├── lib/
│   ├── main.dart                 <- só main() e runApp(const MeuPrimeiroApp())
│   ├── app.dart                  <- MeuPrimeiroApp (Stateful): o ThemeMode
│   ├── modelos/
│   │   └── materia.dart          <- Materia + const materiasIniciais
│   ├── tema/
│   │   └── tema_app.dart         <- TemaApp: temas claro e escuro
│   ├── telas/
│   │   └── home_tela.dart        <- HomeTela (Stateful): TODO o estado do dia
│   └── widgets/
│       ├── barra_resumo.dart     <- BarraResumo (Stateless)
│       ├── contador_sessoes.dart <- ContadorSessoes (Stateless)
│       └── cartao_materia.dart   <- CartaoMateria (Stateless)
└── test/
    └── widget_test.dart          <- os testes de 04-testes.md
```

> 💡 **Dois** `StatefulWidget` no app inteiro: `MeuPrimeiroApp` (tema) e `HomeTela` (dia de estudo).
> O resto só recebe dados prontos e devolve `VoidCallback`.

---

## ✅ Como saber que terminou

Os 20 requisitos viram lista de conferência, um a um, em **[06-checklist.md](06-checklist.md)**.
Pronto = todos marcados e `flutter analyze` respondendo `No issues found!`.

---

| Arquivo | Para quê |
|---|---|
| [README](README.md) | Visão geral |
| **01-especificacao.md** | 📍 Você está aqui |
| [02-passo-a-passo](02-passo-a-passo.md) | Construção guiada |
| [03-codigo-completo](03-codigo-completo.md) | Arquivos finais |
| [04-testes](04-testes.md) | Validar com `flutter test` |
| [05-desafios](05-desafios.md) | Extensões ([gabarito](../../gabaritos/projeto-01-desafios.md)) |
| [06-checklist](06-checklist.md) | Critérios de "pronto" |
