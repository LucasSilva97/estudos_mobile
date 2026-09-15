# Checklist — Projeto 01: Meu Primeiro App

> **Pasta:** `meu_primeiro_app` · **Base:** [01-especificacao.md](01-especificacao.md)

> 📌 **"Pronto" é o que está aqui, não a sua impressão.** Abra o app ao lado desta lista e toque
> em cada botão. Achar que funciona não marca caixa.

---

## ✅ Requisitos funcionais

- [ ] **RF01** — abre direto na `HomeTela`; nenhuma 2ª tela, `Navigator.push` ou rota nomeada.
- [ ] **RF02** — `AppBar` com título `Meu Primeiro App` e o botão de tema como 1ª `action`.
- [ ] **RF03** — o botão cicla `system` → `light` → `dark` → `system`; ícone e `tooltip` seguem.
- [ ] **RF04** — os dois temas saem da semente `Color(0xFF3F51B5)`; muda só o `brightness`.
- [ ] **RF05** — busque `Colors.` e `Color(0x`: só `lib/tema/tema_app.dart` responde.
- [ ] **RF06** — a tela lista exatamente 4 matérias, vindas de `materiasIniciais`.
- [ ] **RF07** — sempre uma única matéria selecionada; abre em `'dart'`.
- [ ] **RF08** — tocar num cartão troca a seleção e avisa para onde vão os minutos.
- [ ] **RF09** — o cartão selecionado usa `secondaryContainer` e borda `secondary` de 2 px.
- [ ] **RF10** — `SegmentedButton<int>` com 15, 25 e 50 min, começando em 25.
- [ ] **RF11** — "Concluir sessão" soma +1 e a duração aos totais **e** à matéria em foco.
- [ ] **RF12** — "Remover sessão" desfaz o RF11 com a duração **atual**.
- [ ] **RF13** — com 0 sessões, `−` e `↺` ficam apagados (`onPressed: null`); nada fica negativo.
- [ ] **RF14** — "Zerar o dia" volta tudo a 0, restaura 95/40/20/0 e avisa no `SnackBar`.
- [ ] **RF15** — cada cartão traz ícone, nome, `<tempo> de <meta> min` e a barra.
- [ ] **RF16** — passe da meta: a barra trava em 100 %.
- [ ] **RF17** — ao cruzar a meta surge o `Icons.check_circle`; Dart chega lá com 25 min.
- [ ] **RF18** — o tempo sai como `45 min`, `2 h` ou `1 h 15 min`.
- [ ] **RF19** — a `BarraResumo` traz sessões, minutos, média e foco; com 0 a média é `—`.
- [ ] **RF20** — reabrir perde tudo — é intencional; nada é gravado em disco.

---

## 🧱 Código

- [ ] `flutter analyze` responde **`No issues found!`** — zero aviso, nem "só uns infos" (RF20).
- [ ] `dart format lib test` rodou sem deixar pendência.
- [ ] Árvore igual à [especificação](01-especificacao.md#estrutura-de-arquivos): 8 arquivos em `lib/`.
- [ ] `pubspec.yaml` sem dependência além do SDK: `cupertino_icons` removido.
- [ ] Exatamente **dois** `StatefulWidget`: `MeuPrimeiroApp` e `HomeTela`.
- [ ] Nenhum `async`, `Future`, `Timer`, `Navigator`, `TextField` ou pacote externo.
- [ ] `materiasIniciais` segue `const` e o State usa `List<Materia>.of(...)`.
- [ ] Os widgets de `lib/widgets/` só recebem dados e devolvem `VoidCallback`.

---

## 🎨 Interface

- [ ] **Vazio:** 0 sessões — média `—`, `−` e `↺` apagados, Testes com a barra zerada.
- [ ] **Cheio:** 10 sessões seguidas — números sobem, a barra de Dart satura, o selo surge.
- [ ] **Pós-reset:** "Zerar o dia" devolve a tela ao desenho do vazio; role até o rodapé.
- [ ] Em **320 px** de largura, nenhum `RenderFlex overflowed`.
- [ ] **Claro e escuro** legíveis: cartão selecionado, trilha da barra, rótulos do resumo.
- [ ] "Git e terminal" corta com `…`, sem empurrar o layout.
- [ ] Alvos de **48 dp**: `FilledButton` pelo `minimumSize` do tema, `IconButton` pelo padrão.
- [ ] Todo `IconButton` tem `tooltip`.

---

## 🤖🍎 Plataformas

| Onde | O que conferir |
|---|---|
| **Chrome** (`-d chrome`) | Estreite até 320 px: sem overflow. Troque o tema do Windows: `system` segue. |
| **Windows** (`-d windows`) | Redimensione nos dois sentidos: a `ListView` rola e não corta. |
| **Android** (opcional) | `SnackBar` acima da barra de navegação, `SafeArea` respeitada. |
| **iOS** | ⚠️ Exige Mac com Xcode ou runner macOS em CI. No Windows 11 não dá para conferir — e nada aqui depende disso. |

---

## 🧪 Verificação

- [ ] `flutter test` passa inteiro, com os testes de **[04-testes.md](04-testes.md)**.
- [ ] Você rodou os testes **depois** da última alteração, não antes.

> 💡 O teste prova que o código faz o que você mandou; a lista acima, que é o que a
> especificação pediu.

---

## 🚀 Se tudo passou

1. Commite: `git commit -am "feat: projeto 01 - meu primeiro app"`.
2. Encare os **[05-desafios.md](05-desafios.md)** ([gabarito](../../gabaritos/projeto-01-desafios.md)).
3. Siga para o **[Módulo 07](../../modulos/07-navegacao-e-formularios/README.md)**: a 2ª tela, o `TextField` e o `Form` saem da lista de proibidos.
4. Marque o dia no [plano intensivo](../../01-plano-intensivo.md).

---

## 🆘 Se algo não passou

| Item que falhou | Onde revisar |
|---|---|
| RF01, RF02 — tela e `AppBar` | [M06 · 01 — Scaffold](../../modulos/06-widgets-e-layouts/01-scaffold-e-appbar.md) |
| RF03–RF05, RF09 — tema e cores | [M05 · 09](../../modulos/05-introducao-ao-flutter/09-material-e-cupertino.md) · [M06 · 07](../../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) |
| RF06, RF07, RF15, RF17 — lista e cartão | [M05 · 04 — Stateless](../../modulos/05-introducao-ao-flutter/04-statelesswidget.md) |
| RF08, RF14 — `SnackBar` não aparece | [M05 · 07 — BuildContext](../../modulos/05-introducao-ao-flutter/07-buildcontext.md) |
| RF10 — `SegmentedButton` não troca | [M05 · 06 — Ciclo de vida](../../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) |
| RF11–RF13 — não atualiza ou vai a negativo | [M05 · 05 — setState](../../modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md) |
| RF16, RF18, RF19 — conta errada nos getters | [M03 · 01 — Classes](../../modulos/03-dart-intermediario/01-classes-e-objetos.md) |
| `RenderFlex overflowed` em 320 px | [M06 · 04 — Row e Expanded](../../modulos/06-widgets-e-layouts/04-row-column-expanded.md) |

---

| Arquivo | Para quê |
|---|---|
| [README](README.md) | Visão geral |
| [01-especificacao](01-especificacao.md) | O que construir |
| [02-passo-a-passo](02-passo-a-passo.md) | Construção guiada |
| [03-codigo-completo](03-codigo-completo.md) | Arquivos finais |
| [04-testes](04-testes.md) | Validar com `flutter test` |
| [05-desafios](05-desafios.md) | Extensões |
| **06-checklist.md** | 📍 Você está aqui |
