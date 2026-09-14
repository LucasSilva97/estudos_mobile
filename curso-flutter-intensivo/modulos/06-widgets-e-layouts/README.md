# Módulo 06 — Widgets e Layouts

> **Trilha:** Flutter na prática · **Tempo estimado:** ~9 h de aulas + ~2 h de exercícios e avaliação · **Ritmo intensivo:** dias 11 e 12

No módulo anterior você descobriu o que é um *widget* (o bloco de construção visual do Flutter —
tudo que aparece na tela, e boa parte do que não aparece, é um widget), a diferença entre
`StatelessWidget` e `StatefulWidget`, e como o `setState` manda a tela ser redesenhada.

Agora vem a parte que transforma "sei a teoria" em "sei montar uma tela": **os widgets de layout**.
Ao longo de 12 aulas você vai construir, passo a passo, **uma única aplicação** chamada `foco_ui` —
o laboratório visual do projeto final **Foco** (o organizador de estudos que você entrega no fim do
curso). Nada de exemplos soltos: cada aula pega a tela da aula anterior e a faz crescer.

No fim do módulo, `foco_ui` terá: barra superior com ações, lista rolável de matérias com ícone e
minutos estudados, cartão de destaque com imagem e selo sobreposto, tema Material 3 claro e escuro
gerado a partir de uma cor semente, resposta ao toque com *ripple*, diálogo de confirmação,
`SnackBar` com "desfazer", layout que se adapta de celular a desktop, e os **quatro estados de
interface** (carregando, vazio, sucesso, erro) implementados em widgets reutilizáveis.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- Montar a **estrutura padrão de uma tela** com `Scaffold`, `AppBar`, `SafeArea`, `FloatingActionButton`,
  `Drawer` e `BottomNavigationBar`, sabendo para que serve cada espaço.
- Escrever texto legível e acessível com `Text`, `TextStyle`, o `textTheme` do **Material 3**
  (`displayLarge` até `labelSmall`), `overflow`, `maxLines`, `RichText` e `semanticsLabel`.
- Usar `Container`, `Padding`, `SizedBox`, `EdgeInsets`, `BoxDecoration`, `borderRadius` e sombra —
  e, principalmente, **decidir qual deles usar** em cada situação.
- Distribuir widgets no eixo principal e no eixo cruzado com `Row`, `Column`, `MainAxisAlignment`,
  `CrossAxisAlignment`, `Expanded`, `Flexible`, `flex` e `Spacer`.
- Corrigir, com as **quatro técnicas possíveis**, o erro mais famoso do Flutter:
  `RenderFlex overflowed by X pixels`.
- Sobrepor elementos com `Stack`, `Positioned`, `Align` e `Alignment` — selo de notificação,
  gradiente sobre imagem, botão flutuando sobre um cartão.
- Explicar a **regra de ouro do layout**: *constraints descem, tamanhos sobem, o pai posiciona* —
  e usar isso para depurar qualquer layout no Flutter Inspector.
- Gerar um tema completo com `ColorScheme.fromSeed`, entender os papéis de cor (`primary`,
  `onPrimary`, `surface`, `error`…) e ligar **modo claro e modo escuro** com `themeMode`.
- Declarar **assets** (arquivos que acompanham o app: imagens, fontes, JSON) no `pubspec.yaml` com a
  indentação correta, tratar carregamento e falha de imagem com `loadingBuilder` e `errorBuilder`.
- Construir listas eficientes com `ListView.builder`, `ListView.separated`, `GridView.builder`,
  `RefreshIndicator`, `Dismissible` e `ScrollController` — e saber por que `builder` importa.
- Responder ao toque com `InkWell`, `GestureDetector`, os botões do Material 3, `SnackBar`,
  `AlertDialog`, `showModalBottomSheet` e `Tooltip`, respeitando os **48 dp de área mínima de toque**.
- Fazer a mesma tela funcionar em celular, tablet, Windows e navegador com `MediaQuery`,
  `LayoutBuilder`, `OrientationBuilder`, `Wrap`, `FittedBox` e `AspectRatio`.
- Implementar os **quatro estados obrigatórios de qualquer tela** e nunca mais entregar um app que
  mostra tela branca quando a lista está vazia ou quando a internet cai.

---

## ✅ Pré-requisitos

| Requisito | Onde resolver |
|---|---|
| Flutter 3.47.1 instalado, `flutter doctor` sem erro bloqueante | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) |
| Saber criar projeto, rodar `flutter run`, usar *hot reload* | [Módulo 05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md) |
| Entender `StatelessWidget`, `StatefulWidget`, `setState` e `BuildContext` | [05 — StatelessWidget](../05-introducao-ao-flutter/04-statelesswidget.md) e [05 — BuildContext](../05-introducao-ao-flutter/07-buildcontext.md) |
| Classes, construtores e parâmetros nomeados em Dart | [Módulo 03 — Dart Intermediário](../03-dart-intermediario/README.md) |
| `List`, `map` e *collection-for* | [02 — Listas](../02-dart-basico/08-listas.md) |
| `Future` e `async`/`await` (usado só nas aulas 9 e 12) | [04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) |

Confirme o ambiente antes de começar. No PowerShell:

```powershell
flutter --version
```

Você deve ver **Flutter 3.47.1** e **Dart 3.13.1**. Se aparecer versão diferente, ou se o comando não
for reconhecido, volte para [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

---

## 🗺️ Ordem recomendada das aulas

Siga **na ordem**. Cada aula continua o mesmo projeto `foco_ui` da aula anterior; pular uma quebra
a sequência de arquivos.

| # | Aula | Tempo | O que você leva dela |
|---|---|---|---|
| 1 | [Scaffold e AppBar](01-scaffold-e-appbar.md) | 40 min | Esqueleto de tela, slots do `Scaffold`, `SafeArea` |
| 2 | [Texto, tipografia e ícones](02-texto-tipografia-icones.md) | 40 min | `TextStyle`, `textTheme` M3, `overflow`, `RichText`, `Icon` |
| 3 | [Container, Padding e SizedBox](03-container-padding-sizedbox.md) | 40 min | `BoxDecoration`, `EdgeInsets`, sombra, qual usar quando |
| 4 | [Row, Column e Expanded](04-row-column-expanded.md) | 50 min | Eixos, alinhamentos, `flex`, `Spacer`, *overflow* |
| 5 | [Stack e Positioned](05-stack-e-positioned.md) | 40 min | Sobreposição, ordem de pintura, selo, gradiente |
| 6 | [Constraints](06-constraints.md) | 50 min | A regra do layout, `tight` × `loose`, altura infinita |
| 7 | [Cores, temas e modo escuro](07-cores-temas-modo-escuro.md) | 45 min | `ColorScheme.fromSeed`, papéis de cor, `themeMode` |
| 8 | [Imagens e assets](08-imagens-e-assets.md) | 40 min | `pubspec.yaml`, resolução 2x/3x, `errorBuilder`, fontes |
| 9 | [Listas e rolagem](09-listas-e-rolagem.md) | 55 min | `ListView.builder`, `separated`, `GridView`, `Dismissible` |
| 10 | [Gestos e feedback](10-gestos-e-feedback.md) | 50 min | `InkWell`, botões M3, `SnackBar`, diálogo, *bottom sheet* |
| 11 | [Responsividade](11-responsividade.md) | 45 min | `MediaQuery`, `LayoutBuilder`, `Wrap`, teclado, tablets |
| 12 | [Estados de UI](12-estados-de-ui.md) | 45 min | Carregando, vazio, sucesso, erro — widgets reutilizáveis |

**Total das aulas: 540 min (≈ 9 h).**

No ritmo **Intensivo recomendado** (30 dias) este módulo ocupa os **dias 11 e 12**:

| Dia | Conteúdo | Tempo |
|---|---|---|
| 11 | Aulas 1 a 6 | 260 min |
| 12 | Aulas 7 a 12 + exercícios + avaliação | 280 min + prática |

---

## 📝 Exercícios e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Lista de exercícios do módulo | [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md) | Ao terminar cada aula, faça os exercícios que citam aquele assunto |
| Avaliação do módulo | [avaliacoes/modulo-06-widgets-e-layouts.md](../../avaliacoes/modulo-06-widgets-e-layouts.md) | Só depois das 12 aulas e dos exercícios obrigatórios |

Os gabaritos ficam em `gabaritos/06-widgets-e-layouts.md` e estão linkados dentro de cada exercício.
Regra de ouro deste módulo: **antes de abrir o gabarito, rode o código quebrado e leia a mensagem de
erro inteira**. Layout no Flutter se aprende lendo erro de layout.

---

## 🧰 O projeto que acompanha o módulo

Na Aula 1 você cria **um único projeto**, `foco_ui`, e usa ele até o fim do módulo:

```powershell
flutter create foco_ui
```

A pasta `lib/` cresce assim, aula por aula:

```text
foco_ui/
├── pubspec.yaml                                  ← editado nas aulas 8 (assets/fontes)
├── assets/
│   ├── imagens/                                  ← Aula 8
│   └── fontes/                                   ← Aula 8
└── lib/
    ├── main.dart                                 ← Aula 1, revisitado em 7, 11 e 12
    ├── core/
    │   ├── tema/tema_app.dart                    ← Aula 7
    │   └── widgets/
    │       ├── carregando.dart                   ← Aula 12
    │       ├── estado_vazio.dart                 ← Aula 12
    │       └── estado_erro.dart                  ← Aula 12
    └── features/
        └── materias/
            ├── domain/materia.dart               ← Aula 4
            └── presentation/
                ├── home_screen.dart              ← Aula 1 → cresce até a Aula 12
                ├── materias_tab.dart             ← Aula 9
                └── widgets/
                    ├── cartao_destaque.dart      ← Aula 3 → 5 → 8
                    └── materia_tile.dart         ← Aula 4 → 9 → 10
```

Repare que essa organização é **a mesma** do projeto final descrito em
[05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md): `lib/core/` para o que é do app inteiro,
`lib/features/<assunto>/` para o que é de um assunto só. Você já começa praticando a arquitetura
final, mesmo sem ainda ter banco de dados nem estado compartilhado.

Sempre que uma aula mostrar código completo, ela diz **o caminho exato do arquivo** e o **comando
exato** para rodar. Digite o código; não copie e cole.

### 🪟 Se você ainda não tem Android SDK instalado

Este módulo é inteiramente sobre **interface**. Você consegue fazer 100 % dele sem emulador Android:

```powershell
flutter run -d windows
flutter run -d chrome
```

O `-d windows` abre seu app como um programa de Windows; o `-d chrome` abre no navegador. O *hot
reload* funciona nos dois. As aulas 1, 10 e 11 apontam onde o resultado visual muda entre desktop e
celular, para você não se confundir.

---

## 🔗 Como este módulo se conecta ao resto do curso

| O que você aprende aqui | Onde reaparece |
|---|---|
| `Scaffold` + `AppBar` + abas | [07 — Abas e organização](../07-navegacao-e-formularios/04-abas-e-organizacao.md) |
| `Theme.of(context)` e `ColorScheme` | [Projeto final — Etapa 1](../../projetos/03-projeto-final-multiplataforma/03-etapa-1-fundacao.md) |
| `ListView.builder` e `keys` | [13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md) |
| Estados carregando/vazio/erro | [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) |
| `SnackBar`, diálogo e *bottom sheet* | [07 — UX de formulários](../07-navegacao-e-formularios/08-ux-de-formularios.md) |
| `semanticsLabel` e contraste | [13 — Acessibilidade](../13-desempenho-e-seguranca/05-acessibilidade.md) |
| Imagens e `cacheWidth` | [13 — Listas grandes e imagens](../13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md) |
| Ícone do app e splash | [14 — Ícone](../14-build-android/03-icone.md) e [14 — Splash screen](../14-build-android/04-splash-screen.md) |
| Testes de widget nesta interface | [12 — Testes de widget](../12-testes-e-debug/06-testes-de-widget.md) |

O módulo seguinte, [07 — Navegação e Formulários](../07-navegacao-e-formularios/README.md), pega
estas telas e ensina a **ir de uma para a outra** e a **coletar dados** do usuário.

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando for verdade de fato. Este é o portão de entrada do módulo 07.

- [ ] Li as **12 aulas** inteiras, na ordem.
- [ ] Criei o projeto `foco_ui` e ele roda com `flutter run -d windows` (ou no emulador) sem erro.
- [ ] Digitei e rodei o **código completo** das 12 aulas; a tela final tem lista, tema, imagem e estados.
- [ ] Explico, sem consultar, para que servem `appBar`, `body`, `floatingActionButton`, `drawer` e
      `bottomNavigationBar` do `Scaffold`.
- [ ] Sei escolher entre `Padding`, `SizedBox` e `Container` e justifico a escolha.
- [ ] Provoquei de propósito um `RenderFlex overflowed by X pixels` e **corrigi de duas formas diferentes**.
- [ ] Recito a regra: *constraints descem, tamanhos sobem, o pai posiciona*, e sei aplicá-la para
      explicar por que um `Container` sem filho ocupa a tela toda.
- [ ] Meu app tem tema claro e escuro funcionando com `ColorScheme.fromSeed` e `themeMode`.
- [ ] Declarei um asset no `pubspec.yaml`, com a indentação certa, e a imagem aparece.
- [ ] Uso `ListView.builder` em vez de `ListView(children: [...])` para listas longas e explico por quê.
- [ ] Todo elemento tocável do meu app tem pelo menos **48 × 48 dp** e dá *feedback* visual.
- [ ] Minha tela sobrevive a `flutter run -d windows` maximizado **e** a um celular estreito em pé.
- [ ] Toda tela que busca dados trata os **quatro** estados: carregando, vazio, sucesso e erro.
- [ ] Rodei `flutter analyze` no `foco_ui` **sem nenhum aviso**.
- [ ] Fiz **todos os exercícios obrigatórios** de [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md).
- [ ] Acertei **7 ou mais** das 10 questões de [avaliacoes/modulo-06-widgets-e-layouts.md](../../avaliacoes/modulo-06-widgets-e-layouts.md).

Se algum item ficou desmarcado, a tabela "Se você teve dificuldade" da avaliação diz exatamente qual
aula revisar.

---

| ⬅️ Módulo anterior | 🏠 Curso | ➡️ Próximo módulo |
|---|---|---|
| [05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md) | [README do curso](../../README.md) | [07 — Navegação e Formulários](../07-navegacao-e-formularios/README.md) |
