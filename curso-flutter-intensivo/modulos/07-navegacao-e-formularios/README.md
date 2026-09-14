# Módulo 07 — Navegação e Formulários

> **Nível:** Intermediário · **Tempo estimado total:** 345 min obrigatórios (≈ 5 h 45 min)
> · +40 min da aula opcional 09 · **Pré-requisito direto:**
> [Módulo 06 — Widgets e Layouts](../06-widgets-e-layouts/README.md)

Até aqui você desenhou **uma** tela. Muito bem desenhada, responsiva, com tema claro e escuro —
mas uma só. Um aplicativo de verdade tem várias telas, e o usuário precisa ir de uma para outra,
voltar, cancelar, preencher dados e receber uma resposta.

Este módulo é sobre essas duas coisas, que na prática andam sempre juntas:

1. **Navegação** — como o Flutter empilha e desempilha telas, como nomear rotas, como passar
   dados de ida e receber dados de volta, e como o botão voltar do Android e o gesto de arrastar
   do iOS mexem exatamente na mesma pilha.
2. **Formulários** — como coletar texto, número, escolha e opção do usuário; como validar sem
   humilhar quem está digitando; como controlar foco e teclado; e como não perder o que a pessoa
   já preencheu.

Tudo aqui é construído sobre **um único aplicativo que cresce aula após aula**: o
**`foco_navegacao`**, um laboratório que monta exatamente o esqueleto de navegação do projeto
final **Foco** (as 4 abas: Hoje · Matérias · Trilhas · Ajustes) e o formulário de matéria.
Ao terminar o módulo, você terá o casco navegável do projeto final rodando no seu computador.

Versões usadas em todas as aulas: **Flutter 3.47.1** · **Dart 3.13.1** · **Material 3**.

---

## 🎯 O que você vai aprender

Ao terminar este módulo você será capaz de:

- **Explicar a pilha de navegação** (*stack* — a estrutura "último a entrar, primeiro a sair" que
  o Flutter usa para guardar as telas abertas) e prever, antes de rodar, o que o botão voltar vai
  fazer no seu app.
- **Empilhar e desempilhar telas** com `Navigator.push`, `Navigator.pop`, `pushReplacement`,
  `popUntil`, `canPop` e `maybePop`, e abrir uma tela como **diálogo em tela cheia**
  (`fullscreenDialog`).
- **Centralizar rotas** numa classe `Rotas` com constantes e resolvê-las com `onGenerateRoute`
  usando um `switch`, com **rota de erro** para nome desconhecido — em vez de espalhar
  `MaterialPageRoute` por dezenas de arquivos.
- **Passar argumentos tipados** entre telas com uma classe de argumentos, **validar o tipo
  recebido** e **receber um resultado de volta** com `await Navigator.push<T>` +
  `Navigator.pop(resultado)`, respeitando a checagem obrigatória de `context.mounted`.
- **Organizar o app em abas** com `NavigationBar` do Material 3, preservando o estado de cada aba
  com `IndexedStack`, usar `TabBar` + `TabBarView` com `DefaultTabController` e adicionar um
  `Drawer` (*gaveta* — menu lateral deslizante).
- **Respeitar as duas plataformas**: transição de página diferente em Android e iOS,
  `PageTransitionsTheme`, `CupertinoPageRoute` e o gesto de arrastar da borda, botão voltar do
  Android interceptado com `PopScope` (nunca `WillPopScope`) e `SystemNavigator.pop`.
- **Construir um formulário completo**: `Form` + `GlobalKey<FormState>`, `TextFormField`,
  `TextEditingController` com `dispose` obrigatório, `InputDecoration`, `keyboardType`,
  `inputFormatters`, `obscureText`, `DropdownButtonFormField`, `Switch` e `Checkbox`.
- **Validar bem**: `validator`, `autovalidateMode`, encadeamento de campos com `FocusNode` +
  `textInputAction` + `onFieldSubmitted`, teclado que cobre o campo, e estado de envio com botão
  desabilitado e indicador de progresso.
- **Cuidar da experiência**: mensagem de erro que ajuda em vez de culpar, momento certo de
  validar, rótulo × placeholder, confirmação de descarte, acessibilidade e rascunho salvo.
- **(Opcional) Avaliar o `go_router`** e saber dizer, com argumentos, quando ele vale a pena e
  por que este curso usa Navigator 1.0 no projeto final.

---

## ✅ Pré-requisitos

| Pré-requisito | Onde está | Por que é necessário |
|---|---|---|
| Módulo 06 — Widgets e Layouts | [modulos/06-widgets-e-layouts/README.md](../06-widgets-e-layouts/README.md) | `Scaffold`, `AppBar`, `ListView`, tema e `SnackBar` aparecem em **todas** as aulas daqui |
| Módulo 05 — Introdução ao Flutter | [modulos/05-introducao-ao-flutter/README.md](../05-introducao-ao-flutter/README.md) | `StatefulWidget`, `setState`, ciclo de vida do `State` e, principalmente, **`BuildContext`** |
| Módulo 04 — Futures e async/await | [04-dart-avancado/02-futures-e-async-await.md](../04-dart-avancado/02-futures-e-async-await.md) | `await Navigator.push` devolve um `Future`; sem entender `await` a aula 3 não faz sentido |
| Módulo 03 — Classes e objetos | [03-dart-intermediario/01-classes-e-objetos.md](../03-dart-intermediario/01-classes-e-objetos.md) | A classe de argumentos e o modelo `Materia` são classes comuns de Dart |
| Módulo 02 — Null safety | [02-dart-basico/05-null-safety.md](../02-dart-basico/05-null-safety.md) | `String?` e `Object?` aparecem em todo validador e em todo resultado de rota |
| Ambiente funcionando | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) | Você vai rodar `flutter run` em todas as aulas |

Checagem rápida — abra o **PowerShell** e rode:

```powershell
flutter --version
```

A saída precisa mostrar `Flutter 3.47.1` e `Dart 3.13.1`. Se não mostrar, volte para
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) antes de seguir.

---

## 🧱 O projeto que cresce ao longo do módulo

Na aula 1 você cria **uma única vez** o projeto do módulo:

```powershell
flutter create --platforms=android,ios foco_navegacao
```

Depois, cada aula acrescenta arquivos a esse mesmo projeto. Este é o estado final dele, ao
terminar a aula 8:

```text
foco_navegacao/
└── lib/
    ├── main.dart
    ├── core/
    │   ├── rotas/{rotas.dart,rota_desconhecida_screen.dart}
    │   ├── tema/tema_app.dart
    │   ├── validacao/validadores.dart
    │   ├── rascunho/rascunho_store.dart
    │   └── widgets/menu_lateral.dart
    └── features/
        ├── home/presentation/home_screen.dart
        ├── hoje/presentation/hoje_tab.dart
        ├── materias/presentation/{materias_tab.dart,detalhe_materia_screen.dart,materia_form_screen.dart}
        ├── materias/domain/materia.dart
        ├── trilhas/presentation/trilhas_tab.dart
        ├── metas/presentation/ajustes_tab.dart
        └── estatisticas/presentation/estatisticas_screen.dart
```

Repare que essa árvore é quase idêntica à do projeto final descrito em
[projetos/03-projeto-final-multiplataforma/01-especificacao.md](../../projetos/03-projeto-final-multiplataforma/01-especificacao.md).
Isso é de propósito: o que você montar aqui vira a fundação de lá.

---

## 🗺️ Ordem recomendada das aulas

Siga **nesta ordem**. Cada aula assume a anterior e mexe no mesmo projeto.

| # | Aula | Tempo | O que entra na sua cabeça |
|---|---|---|---|
| 1 | [01 — Navigator: a pilha](01-navigator-a-pilha.md) | 40 min | Pilha (stack), `push`, `MaterialPageRoute`, `pop`, `pushReplacement`, `popUntil`, `canPop`, `maybePop`, `fullscreenDialog` |
| 2 | [02 — Rotas nomeadas](02-rotas-nomeadas.md) | 40 min | Classe `Rotas` com constantes, `onGenerateRoute` com `switch`, `initialRoute`, rota de erro, `routes:` × `onGenerateRoute` |
| 3 | [03 — Argumentos e resultados](03-argumentos-e-resultados.md) | 45 min | Classe de argumentos tipada, `args is! DetalheArgs`, `await Navigator.push<T>`, `Navigator.pop(resultado)`, `context.mounted`, `SnackBar` de retorno |
| 4 | [04 — Abas e organização](04-abas-e-organizacao.md) | 45 min | `NavigationBar` do Material 3, `IndexedStack`, `TabBar` + `TabBarView`, `DefaultTabController`, `Drawer`, pastas por feature |
| 5 | [05 — Navegação Android × iOS](05-navegacao-android-x-ios.md) | 40 min | Transição por plataforma, `PageTransitionsTheme`, `CupertinoPageRoute`, gesto de borda, `PopScope`, `SystemNavigator.pop` |
| 6 | [06 — Formulários](06-formularios.md) | 50 min | `Form`, `GlobalKey<FormState>`, `TextFormField`, `TextEditingController` + `dispose`, `InputDecoration`, `keyboardType`, `inputFormatters`, `DropdownButtonFormField`, `Switch`/`Checkbox` |
| 7 | [07 — Validação, foco e teclado](07-validacao-foco-teclado.md) | 50 min | `validator`, `validate()`, `autovalidateMode`, `FocusNode`, `textInputAction`, `onFieldSubmitted`, `unfocus()`, estado de envio |
| 8 | [08 — UX de formulários](08-ux-de-formularios.md) | 35 min | Mensagem que ajuda × que culpa, quando validar, rótulo × placeholder, campos obrigatórios, confirmar descarte, acessibilidade, rascunho |
| 9 | [09 — go_router (OPCIONAL)](09-go-router-opcional.md) | 40 min | `go_router ^18.0.1`, `GoRoute`, `MaterialApp.router`, `context.go` × `context.push`, parâmetros de rota, `redirect` |

**Total obrigatório: 345 min.** A aula 9 é **opcional** e **não é pré-requisito de nada** — nem
de outra aula, nem dos exercícios obrigatórios, nem do projeto final.

No [plano intensivo de 30 dias](../../01-plano-intensivo.md), este módulo ocupa:

| Dia | O que fazer |
|---|---|
| **13** | Aulas 1 a 5 + os exercícios que citam essas aulas |
| **14** | Revisão da semana + aulas 6 a 9 + avaliação do módulo |

---

## 📝 Exercícios e avaliação

| Etapa | Arquivo | Quando fazer |
|---|---|---|
| Exercícios do módulo | [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md) | Ao terminar cada aula, faça os exercícios que citam aquela aula |
| Gabarito comentado | [gabaritos/07-navegacao-e-formularios.md](../../gabaritos/07-navegacao-e-formularios.md) | **Só depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-07-navegacao-e-formularios.md](../../avaliacoes/modulo-07-navegacao-e-formularios.md) | Depois da aula 8 (a aula 9 não cai na avaliação) |
| Avaliação cumulativa de UI | [avaliacoes/cumulativa-02-flutter-ui.md](../../avaliacoes/cumulativa-02-flutter-ui.md) | Dia 15 do plano, cobrindo os módulos 05, 06 e 07 |
| Projeto 2 — Bloco de Notas | [projetos/02-projeto-intermediario/README.md](../../projetos/02-projeto-intermediario/README.md) | Dias 15 e 16: é a aplicação direta deste módulo |

---

## 🔗 Para onde isso vai

| Conceito deste módulo | Onde reaparece |
|---|---|
| Pastas por feature | [08 — Arquitetura feature-first](../08-estado-e-arquitetura/09-arquitetura-feature-first.md) |
| Formulário + estado compartilhado | [08 — Notifier e NotifierProvider](../08-estado-e-arquitetura/06-notifier-e-notifierprovider.md) |
| Tela de detalhe com dados remotos | [09 — API com Riverpod](../09-consumo-de-api/09-api-com-riverpod.md) |
| Salvar o rascunho de verdade | [10 — shared_preferences](../10-persistencia-de-dados/02-shared-preferences.md) |
| Botão voltar e gestos no nível do sistema | [11 — Botão voltar e gestos](../11-recursos-nativos/08-botao-voltar-e-gestos.md) |
| Testar navegação e formulário | [12 — Testes de widget](../12-testes-e-debug/06-testes-de-widget.md) |
| Acessibilidade de formulário | [13 — Acessibilidade](../13-desempenho-e-seguranca/05-acessibilidade.md) |
| As 4 abas e as 5 telas do Foco | [Projeto final — etapa 4](../../projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md) |

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir fazer **sem consultar a aula**:

- [ ] Desenho num papel a pilha de rotas do meu app e acerto o que o botão voltar faz em cada tela.
- [ ] Uso `Navigator.push` e `Navigator.pop` e explico a diferença para `pushReplacement`.
- [ ] Sei quando usar `popUntil`, `canPop` e `maybePop`, e não confundo `pop` com `maybePop`.
- [ ] Abro uma tela com `fullscreenDialog: true` e explico quando isso é o certo.
- [ ] Centralizo todas as rotas numa classe `Rotas` e resolvo com `onGenerateRoute` + `switch`.
- [ ] Tenho uma rota de erro que não deixa o app quebrar com um nome de rota digitado errado.
- [ ] Passo argumentos com uma classe tipada e **valido** o tipo recebido antes de usar.
- [ ] Recebo o resultado de uma tela com `await Navigator.push<T>` e trato `null` (cancelamento).
- [ ] Coloco `if (!context.mounted) return;` depois de todo `await` que usa `context`.
- [ ] Monto 4 abas com `NavigationBar` + `IndexedStack` e explico por que `IndexedStack` preserva
      o estado e o `switch` de widgets não.
- [ ] Uso `TabBar` + `TabBarView` com `DefaultTabController` sem criar controller na mão.
- [ ] Configuro `PageTransitionsTheme` e sei descrever a transição de cada plataforma.
- [ ] Uso `PopScope` com `onPopInvokedWithResult` para confirmar a saída com dados não salvos —
      e nunca `WillPopScope`.
- [ ] Monto um `Form` com `GlobalKey<FormState>`, `TextFormField` e `dispose` de todos os
      controllers e focus nodes.
- [ ] Escrevo `validator` para texto obrigatório, e-mail e número, com mensagens que ajudam.
- [ ] Encadeio campos com `FocusNode`, `textInputAction: TextInputAction.next` e `onFieldSubmitted`.
- [ ] Desabilito o botão e mostro progresso enquanto o envio está acontecendo.
- [ ] Todos os exercícios **obrigatórios** de
      [exercicios/07-navegacao-e-formularios.md](../../exercicios/07-navegacao-e-formularios.md)
      estão feitos.
- [ ] Acertei ao menos 7 das 10 questões de
      [avaliacoes/modulo-07-navegacao-e-formularios.md](../../avaliacoes/modulo-07-navegacao-e-formularios.md).
- [ ] `flutter analyze` no `foco_navegacao` termina com `No issues found!`.

Quando todos estiverem marcados, siga para o
[Módulo 08 — Estado e Arquitetura](../08-estado-e-arquitetura/README.md).

---

## 📚 Referências oficiais do módulo

- [Navigation and routing — docs.flutter.dev](https://docs.flutter.dev/ui/navigation)
- [Navigator class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Navigator-class.html)
- [MaterialPageRoute class — api.flutter.dev](https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html)
- [Build a form with validation — docs.flutter.dev](https://docs.flutter.dev/cookbook/forms/validation)
- [Form class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/Form-class.html)
- [TextFormField class — api.flutter.dev](https://api.flutter.dev/flutter/material/TextFormField-class.html)
- [NavigationBar class — api.flutter.dev](https://api.flutter.dev/flutter/material/NavigationBar-class.html)
- [PopScope class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/PopScope-class.html)
- [go_router package — pub.dev](https://pub.dev/packages/go_router)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 06 — Widgets e Layouts](../06-widgets-e-layouts/README.md) | [README do curso](../../README.md) | [Aula 1 — Navigator: a pilha](01-navigator-a-pilha.md) |
