# Módulo 05 — Introdução ao Flutter

> **Nível:** Fundamental · **Tempo estimado total:** 365 min (≈ 6 h 05 min de conteúdo)
> **Pré-requisito direto:** [Módulo 04 — Dart Avançado](../04-dart-avancado/README.md)

Este é o módulo da virada. Até aqui você escreveu Dart em um terminal: entrava texto, saía texto.
A partir de agora o mesmo Dart passa a desenhar **telas** — e a primeira coisa que você precisa
entender é que o Flutter não "converte" o seu código em botão do Android ou em botão do iPhone.
Ele **pinta os próprios pixels**. Entender isso muda a forma como você lê qualquer erro daqui
para frente.

Tudo neste módulo roda com **Flutter 3.47.1** e **Dart 3.13.1** no Windows 11, usando o Chrome
como aparelho de teste (`flutter run -d chrome`). Você não precisa de emulador Android nem de Mac
para concluir o módulo inteiro.

---

## 🎯 O que você vai aprender

Ao terminar este módulo você será capaz de:

- **Explicar como o Flutter funciona por dentro**: o que é a *engine* (*motor* — a parte do Flutter
  escrita em C++ que conversa com o sistema operacional), a diferença entre **Impeller** e **Skia**,
  e por que o Dart é compilado de duas formas diferentes (JIT no desenvolvimento, AOT na versão
  final).
- **Comparar Flutter com React Native e com desenvolvimento nativo puro** de forma honesta —
  sabendo dizer quando cada um é a melhor escolha.
- **Ler a árvore de um projeto Flutter** pasta por pasta, arquivo por arquivo, e saber o que
  versionar no Git e o que jamais versionar.
- **Montar um app do zero**: `main()`, `runApp()`, `MaterialApp`, `Scaffold` — e entender a
  **árvore de widgets** (a estrutura de pai e filho que descreve a tela inteira).
- **Escrever `StatelessWidget`** (widget sem estado) com parâmetros obrigatórios, `const` e
  `{super.key}`, e entender por que extrair um widget é diferente de extrair um método.
- **Escrever `StatefulWidget`** (widget com estado), usar `setState()` e saber exatamente quando
  o estado justifica a complexidade extra.
- **Dominar o ciclo de vida do `State`**: `createState`, `initState`, `didChangeDependencies`,
  `build`, `didUpdateWidget`, `deactivate`, `dispose` — e por que esquecer o `dispose` de um
  `Timer` ou de um `TextEditingController` causa vazamento de memória e o erro
  `setState() called after dispose()`.
- **Entender o `BuildContext` de verdade**: ele é a *posição do widget na árvore*, não uma
  variável mágica. Com isso você vai parar de errar `Theme.of`, `Navigator.of` e
  `ScaffoldMessenger.of`.
- **Usar hot reload e hot restart com intenção**, sabendo o que cada um preserva e quando nenhum
  dos dois resolve.
- **Escolher entre Material 3 e Cupertino**, configurar `ColorScheme.fromSeed` e decidir quando
  vale adaptar a interface por plataforma e quando adaptar é desperdício.

---

## ✅ Pré-requisitos

| Pré-requisito | Onde está | Por que é necessário |
|---|---|---|
| Módulo 04 — Dart Avançado | [modulos/04-dart-avancado/README.md](../04-dart-avancado/README.md) | `Future`, `async`/`await`, `Stream` e lints aparecem já na aula 6 |
| Módulo 03 — Dart Intermediário | [modulos/03-dart-intermediario/README.md](../03-dart-intermediario/README.md) | Todo widget é uma **classe** que **estende** outra classe e sobrescreve um método |
| Módulo 02 — Dart Básico | [modulos/02-dart-basico/README.md](../02-dart-basico/README.md) | `final`, `const`, null safety e listas são usados em cada linha de código do módulo |
| Ambiente configurado | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) | Você vai rodar `flutter create` e `flutter run` de verdade |

Checagem obrigatória antes de começar — abra o **PowerShell** e rode:

```powershell
flutter --version
```

A saída precisa conter `Flutter 3.47.1` e `Dart 3.13.1`. Depois rode:

```powershell
flutter doctor
```

Para este módulo você precisa de, no mínimo, **`[✓] Flutter`** e **`[✓] Chrome`**.
As linhas `[✗] Android toolchain` e `[✗] Xcode` podem continuar com erro — nenhuma aula daqui
depende delas. Se o `flutter doctor` travar ou aparecer `FileSystemException: Cannot resolve
symbolic links`, o seu SDK está em um caminho com acento: volte para
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) e mova o SDK para
`C:\src\flutter` antes de seguir.

---

## 🧱 O app que cresce junto com o módulo

Este módulo **não** tem nove exemplos desconexos. Ele tem **um app só**, chamado
`meu_primeiro_app`, que nasce vazio na aula 2 e termina a aula 9 assim:

```text
meu_primeiro_app/
├── lib/
│   ├── main.dart                        <- aula 3 (e ajustado na 9)
│   ├── app.dart                         <- aula 9
│   ├── tema/
│   │   └── tema_app.dart                <- aula 9
│   ├── telas/
│   │   └── home_tela.dart               <- aula 5 (e ajustada nas 6 e 7)
│   └── widgets/
│       ├── cartao_materia.dart          <- aula 4
│       ├── contador_sessoes.dart        <- aula 5
│       └── cronometro_sessao.dart       <- aula 6
├── test/
└── pubspec.yaml
```

Esse app é a base direta do **Projeto 1 — Meu Primeiro App**, em
[projetos/01-projeto-iniciante/README.md](../../projetos/01-projeto-iniciante/README.md).
Não apague a pasta ao terminar o módulo.

---

## 🗺️ Ordem recomendada das aulas

Siga **nesta ordem**. Cada aula assume a anterior e cada aula mexe no mesmo projeto.

| # | Aula | Tempo | O que entra na sua cabeça |
|---|---|---|---|
| 1 | [01 — Como o Flutter funciona](01-como-o-flutter-funciona.md) | 40 min | Flutter pinta os próprios pixels, engine, Impeller × Skia, JIT × AOT, por que existe hot reload, Flutter × React Native × nativo, o que é um widget |
| 2 | [02 — Estrutura do projeto](02-estrutura-do-projeto.md) | 40 min | `flutter create`, flag `-e`, `lib/`, `test/`, `android/`, `ios/`, `web/`, `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `.metadata`, o que versionar |
| 3 | [03 — main, runApp e a árvore de widgets](03-main-runapp-arvore-de-widgets.md) | 45 min | `main()`, `runApp()`, `MaterialApp`, `Scaffold`, árvore de widgets, composição × herança, Widget → Element → RenderObject |
| 4 | [04 — StatelessWidget](04-statelesswidget.md) | 40 min | `StatelessWidget`, `build`, imutabilidade, `required` no construtor, `{super.key}`, por que `const` importa, extrair widget × extrair método, `CartaoMateria` |
| 5 | [05 — StatefulWidget e setState](05-statefulwidget-e-setstate.md) | 45 min | O que é estado, `StatefulWidget` × `State`, `setState()`, por que a classe de estado é separada, quando usar Stateful, contador de sessões |
| 6 | [06 — Ciclo de vida do State](06-ciclo-de-vida-do-state.md) | 45 min | `createState`, `initState`, `didChangeDependencies`, `build`, `didUpdateWidget`, `deactivate`, `dispose`, `Timer`, `TextEditingController`, `setState() called after dispose()` |
| 7 | [07 — BuildContext](07-buildcontext.md) | 40 min | O que é o `BuildContext`, `Theme.of`, `MediaQuery.of`, `Navigator.of`, `ScaffoldMessenger.of`, `Builder`, `context.mounted` depois de `await` |
| 8 | [08 — Hot reload e hot restart](08-hot-reload-e-hot-restart.md) | 30 min | O que cada um preserva, teclas `r` / `R` / `q`, atalhos do VS Code, quando é obrigatório parar e rodar de novo, limitações reais |
| 9 | [09 — Material e Cupertino](09-material-e-cupertino.md) | 40 min | Material Design 3, Cupertino, `MaterialApp` × `CupertinoApp`, `useMaterial3`, `ColorScheme.fromSeed`, quando adaptar e quando não adaptar |

**Total: 365 min.** No [plano intensivo de 30 dias](../../01-plano-intensivo.md), as aulas 1 a 5
caem no **dia 9** (depois da avaliação cumulativa de Dart) e as aulas 6 a 9 no **dia 10**, junto
com o início do Projeto 1.

---

## 📝 Exercícios e avaliação

| Etapa | Arquivo | Quando fazer |
|---|---|---|
| Exercícios do módulo | [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md) | Ao terminar cada aula, faça os exercícios que citam aquela aula |
| Gabarito comentado | [gabaritos/05-introducao-ao-flutter.md](../../gabaritos/05-introducao-ao-flutter.md) | **Só depois** de tentar de verdade, com o app rodando |
| Avaliação do módulo | [avaliacoes/modulo-05-introducao-ao-flutter.md](../../avaliacoes/modulo-05-introducao-ao-flutter.md) | Depois da aula 9 |
| Projeto 1 | [projetos/01-projeto-iniciante/README.md](../../projetos/01-projeto-iniciante/README.md) | Dia 10, logo depois da avaliação do módulo |

---

## 🔗 Para onde isso vai

| Conceito deste módulo | Onde reaparece |
|---|---|
| Árvore de widgets e composição | [06 — Row, Column, Expanded](../06-widgets-e-layouts/04-row-column-expanded.md) |
| `Scaffold` e `AppBar` | [06 — Scaffold e AppBar](../06-widgets-e-layouts/01-scaffold-e-appbar.md) |
| `ColorScheme.fromSeed` e Material 3 | [06 — Cores, temas e modo escuro](../06-widgets-e-layouts/07-cores-temas-modo-escuro.md) |
| `BuildContext` e `Navigator.of` | [07 — Navigator: a pilha](../07-navegacao-e-formularios/01-navigator-a-pilha.md) |
| `TextEditingController` e `dispose` | [07 — Formulários](../07-navegacao-e-formularios/06-formularios.md) |
| Limites do `setState` | [08 — O problema do estado](../08-estado-e-arquitetura/01-o-problema-do-estado.md) |
| Ciclo de vida e `Timer` | [11 — Ciclo de vida do app](../11-recursos-nativos/06-ciclo-de-vida-do-app.md) |
| Material × Cupertino a fundo | [11 — Material × Cupertino](../11-recursos-nativos/09-material-x-cupertino.md) |
| `const` e rebuilds | [13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md) |

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir fazer **sem consultar a aula**:

- [ ] Explico, em uma frase, por que o Flutter desenha os próprios pixels em vez de usar os
      componentes do sistema — e cito uma vantagem e uma desvantagem disso.
- [ ] Digo o que é a engine, o que é o Impeller e por que o Skia ainda existe.
- [ ] Explico por que o hot reload só funciona no modo debug (JIT) e não no release (AOT).
- [ ] Crio um projeto com `flutter create` e sei dizer para que serve cada pasta da raiz.
- [ ] Sei apontar, olhando um `.gitignore`, o que nunca deve entrar no repositório.
- [ ] Escrevo um `main()` com `runApp()` e monto uma árvore `MaterialApp` → `Scaffold` → conteúdo.
- [ ] Explico a diferença entre Widget, Element e RenderObject em nível introdutório.
- [ ] Crio um `StatelessWidget` com parâmetros `required`, `{super.key}` e construtor `const`.
- [ ] Sei dizer por que extrair um widget é melhor que extrair um método que devolve `Widget`.
- [ ] Crio um `StatefulWidget`, mudo o estado com `setState()` e explico por que o `State` é uma
      classe separada.
- [ ] Listo os sete métodos do ciclo de vida do `State` e digo o que fazer em cada um.
- [ ] Cancelo um `Timer` e chamo `dispose()` de um `TextEditingController` sem esquecer.
- [ ] Explico o que é `BuildContext` e por que `Builder` resolve o erro de "context errado".
- [ ] Uso `ScaffoldMessenger.of(context).showSnackBar(...)` e sei por que
      `Scaffold.of(context).showSnackBar(...)` não existe mais.
- [ ] Checo `mounted` / `context.mounted` depois de todo `await`.
- [ ] Sei quando `r` resolve, quando preciso de `R` e quando preciso parar e rodar de novo.
- [ ] Configuro um tema com `ColorScheme.fromSeed` e explico a decisão do curso sobre adaptação.
- [ ] Todos os exercícios **obrigatórios** de
      [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md) estão feitos.
- [ ] Acertei ao menos 7 das 10 questões de
      [avaliacoes/modulo-05-introducao-ao-flutter.md](../../avaliacoes/modulo-05-introducao-ao-flutter.md).
- [ ] `flutter analyze` na pasta `meu_primeiro_app` termina com `No issues found!`.

Quando todos estiverem marcados, siga para o
[Módulo 06 — Widgets e Layouts](../06-widgets-e-layouts/README.md).

---

## 📚 Referências oficiais do módulo

- [Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)
- [Introduction to widgets](https://docs.flutter.dev/ui/widgets-intro)
- [Impeller rendering engine](https://docs.flutter.dev/perf/impeller)
- [Hot reload](https://docs.flutter.dev/tools/hot-reload)
- [Material 3 no Flutter](https://docs.flutter.dev/ui/design/material)
- [Cupertino (iOS-style) widgets](https://docs.flutter.dev/ui/widgets/cupertino)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 04 — Dart Avançado](../04-dart-avancado/README.md) | [README do curso](../../README.md) | [Aula 1 — Como o Flutter funciona](01-como-o-flutter-funciona.md) |
