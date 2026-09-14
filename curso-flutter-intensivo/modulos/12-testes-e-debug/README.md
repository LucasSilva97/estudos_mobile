# Módulo 12 — Testes e Depuração

> **Nível:** Intermediário · **Tempo estimado total:** 350 min (≈ 5 h 50 min de conteúdo)
> **Pré-requisito direto:** [Módulo 11 — Recursos Nativos](../11-recursos-nativos/README.md)

Até aqui você aprendeu a **fazer o app funcionar**. Este módulo é sobre uma coisa diferente e,
no dia a dia, mais valiosa: **descobrir por que ele parou de funcionar** e **provar que ele
continua funcionando** depois de cada mudança que você faz.

São duas habilidades irmãs:

- **Depuração** (*debugging* — a atividade de encontrar e remover defeitos): ler o erro,
  achar a linha culpada, olhar o valor das variáveis no momento exato da falha.
- **Testes automatizados**: escrever código que executa o seu código e reclama sozinho quando
  o resultado sai errado.

Quem só sabe depurar conserta um bug e quebra outro sem perceber. Quem só sabe testar escreve
testes que passam e não faz ideia do que fazer quando o app trava no celular. Você vai sair
daqui sabendo as duas.

Tudo neste módulo foi executado em **Flutter 3.47.1 / Dart 3.13.1** no **Windows 11**.
Os testes que você vai escrever nas aulas 5, 6 e 7 são os mesmos que rodaram de verdade na
validação deste curso: **24 testes de unidade/widget + 10 testes de banco, todos passando**.

---

## 🎯 O que você vai aprender

Ao terminar este módulo você será capaz de:

- **Ler um stack trace** (*rastro de pilha* — a lista de chamadas de função que levou até o erro)
  do Flutter e apontar, em menos de um minuto, **a linha do seu código** que causou a falha.
- Reconhecer de cabeça os erros mais comuns do Flutter pelo texto: `RenderFlex overflowed`,
  `setState() called after dispose()`, `Null check operator used on a null value`,
  `No Material widget found`, `Vertical viewport was given unbounded height`.
- **Instrumentar o código** com `debugPrint()` e `log()` de `dart:developer`, e saber quando
  um log resolve mais rápido que um breakpoint.
- **Parar o app no meio da execução** com breakpoints (inclusive condicionais) no VS Code,
  andar linha a linha e inspecionar variáveis e a pilha de chamadas.
- **Usar o DevTools**: Flutter Inspector, Layout Explorer, Performance, CPU Profiler, Memory,
  Network e Logging — a caixa de ferramentas oficial de diagnóstico.
- **Configurar análise estática e formatação**: `analysis_options.yaml` com
  `flutter_lints ^6.0.0`, `dart analyze`, `dart format`, e transformar aviso em erro.
- **Escrever testes de unidade** com `test()`, `group()`, `expect()` e os matchers, testando
  modelo, regra de negócio, exceção e código assíncrono.
- **Escrever testes de widget** com `testWidgets()` e `WidgetTester`: finders, `pump`,
  `pumpAndSettle`, toque, digitação, validação de formulário e navegação.
- **Criar dublês de teste** com `mocktail ^1.0.5`: mock, fake, stub e spy; `when`,
  `thenAnswer`, `verify`, `captureAny` e `registerFallbackValue`.
- **Testar a camada de dados sem emulador**, com `sqflite_common_ffi` e banco em memória.
- **Escrever um teste de integração** com o pacote `integration_test` do SDK, que abre o app
  de verdade e percorre um fluxo completo.
- **Depurar problemas de plataforma**: 🤖 `adb logcat`, `flutter logs`, erros de Gradle;
  🍎 Xcode, Console.app, CocoaPods e SPM — e saber com clareza **o que você consegue e o que
  não consegue fazer no Windows**.

---

## ✅ Pré-requisitos

| Pré-requisito | Onde está | Por que é necessário |
|---|---|---|
| Módulo 11 — Recursos Nativos | [modulos/11-recursos-nativos/README.md](../11-recursos-nativos/README.md) | Permissões, ciclo de vida e pastas nativas aparecem nos erros da aula 9 |
| Módulo 10 — Persistência de Dados | [modulos/10-persistencia-de-dados/README.md](../10-persistencia-de-dados/README.md) | Você vai testar o `MateriaDao` com `sqflite_common_ffi` |
| Módulo 09 — Consumo de API | [modulos/09-consumo-de-api/README.md](../09-consumo-de-api/README.md) | A camada `TrilhaApi` é o alvo dos mocks da aula 7 |
| Módulo 08 — Estado e Arquitetura | [modulos/08-estado-e-arquitetura/README.md](../08-estado-e-arquitetura/README.md) | `ProviderContainer` e `overrides` para testar Riverpod |
| Módulo 04 — Análise estática e lints | [modulos/04-dart-avancado/07-analise-estatica-e-lints.md](../04-dart-avancado/07-analise-estatica-e-lints.md) | A aula 4 aprofunda o que começou lá |
| Ambiente funcionando | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) | `flutter test` precisa do SDK em caminho **sem acento** |

Checagem rápida — abra o **PowerShell** e rode:

```powershell
flutter --version
```

A saída precisa mostrar `Flutter 3.47.1` e `Dart 3.13.1`.

> ⚠️ **Aviso que vale ouro neste módulo.** Se o seu SDK do Flutter ainda estiver em
> `C:\Users\Usuário\Documents\flutter` (com acento no caminho), o `flutter test` pode falhar
> com `ShaderCompilerException` / `Asset 'shaders/ink_sparkle.frag' not found` **mesmo com o
> seu código perfeito**. Isso aconteceu de verdade na validação deste curso. A correção é mover
> o SDK para `C:\src\flutter` e rodar `flutter clean`. O passo a passo está em
> [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) e em
> [referencias/erros-comuns.md](../../referencias/erros-comuns.md).

### O projeto de apoio deste módulo

Todas as aulas usam um projeto chamado **`foco_lab`** — um laboratório com o mesmo domínio do
app final **Foco** (matérias, sessões de estudo, metas e trilhas). Ele existe para você errar
à vontade antes de construir o projeto final nos dias 25 a 27.

Crie o projeto **uma única vez**, agora, antes da aula 1:

```powershell
flutter create --platforms=android,ios foco_lab
cd foco_lab
flutter pub add flutter_riverpod http sqflite path
flutter pub add dev:mocktail dev:sqflite_common_ffi
```

Depois abra o `pubspec.yaml` e acrescente, dentro de `dev_dependencies`, o pacote de testes de
integração — ele vem do **SDK**, por isso não é instalado com `flutter pub add`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mocktail: ^1.0.5
  sqflite_common_ffi: ^2.4.3
```

E rode:

```powershell
flutter pub get
```

---

## 🗺️ Ordem recomendada das aulas

Siga **nesta ordem**. As aulas 1 a 4 formam o bloco de *depuração*; as aulas 5 a 8, o bloco de
*testes*; a aula 9 fecha com a plataforma nativa.

| # | Aula | Tempo | O que entra na sua cabeça |
|---|---|---|---|
| 1 | [01 — Lendo stack traces](01-lendo-stack-traces.md) | 30 min | Caixa vermelha × tela cinza, quadro `EXCEPTION CAUGHT BY`, achar a primeira linha do seu código, erros de build × layout × estado, método de 5 passos |
| 2 | [02 — Logs e breakpoints](02-logs-e-breakpoints.md) | 35 min | `debugPrint` × `print`, lint `avoid_print`, `log()` de `dart:developer`, breakpoint simples e condicional, step over/into/out, watch, `debugger()` |
| 3 | [03 — DevTools](03-devtools.md) | 40 min | Abrir o DevTools, Flutter Inspector, árvore de widgets, Layout Explorer, Performance, CPU Profiler, Memory, Network, Logging, `debugPaintSizeEnabled` |
| 4 | [04 — Análise, lint e formatação](04-analise-lint-formatacao.md) | 30 min | `dart analyze`, `analysis_options.yaml`, `flutter_lints ^6.0.0`, error × warning × info, `ignore_for_file`, `dart format`, checagem antes do commit |
| 5 | [05 — Testes unitários](05-testes-unitarios.md) | 45 min | Pirâmide de testes, `test`/`group`, matchers, `setUp`/`tearDown`, testar modelo e regra de negócio, `throwsA`, assíncrono, `flutter test --plain-name` |
| 6 | [06 — Testes de widget](06-testes-de-widget.md) | 50 min | `testWidgets`, `WidgetTester`, `pumpWidget`, `pump` × `pumpAndSettle`, finders, `tap`/`enterText`, formulário, navegação, **o erro do Timer pendente** |
| 7 | [07 — Mocks e fakes](07-mocks-e-fakes.md) | 50 min | Dublês de teste, `mocktail ^1.0.5`, `when`/`thenAnswer`/`thenThrow`, `verify`, `captureAny`, `registerFallbackValue`, Riverpod com `ProviderContainer`, banco com `sqflite_common_ffi` |
| 8 | [08 — Testes de integração](08-testes-de-integracao.md) | 35 min | Pacote `integration_test`, `IntegrationTestWidgetsFlutterBinding`, fluxo completo, rodar em emulador e aparelho, quantos ter |
| 9 | [09 — Depurando Android e iOS](09-depurando-android-e-ios.md) | 35 min | 🤖 `adb logcat`, `flutter logs`, stack trace do Gradle, `--stacktrace`, cache do Gradle, JDK; 🍎 Xcode, Console.app, assinatura, CocoaPods/SPM; 🪟 o que dá e o que não dá no Windows |

**Total: 350 min.** No [plano intensivo de 30 dias](../../01-plano-intensivo.md), este módulo
inteiro cai no **dia 23**. Se as 4 h não forem suficientes, faça as aulas 1 a 5 no dia 23 e as
aulas 6 a 9 na primeira hora do dia 24, antes do módulo 13.

---

## 📝 Exercícios e avaliação

| Etapa | Arquivo | Quando fazer |
|---|---|---|
| Exercícios do módulo | [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md) | Ao terminar cada aula, faça os exercícios que citam aquela aula |
| Gabarito comentado | [gabaritos/12-testes-e-debug.md](../../gabaritos/12-testes-e-debug.md) | **Só depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-12-testes-e-debug.md](../../avaliacoes/modulo-12-testes-e-debug.md) | Depois da aula 9 |
| Avaliação cumulativa | [avaliacoes/cumulativa-04-qualidade-e-plataforma.md](../../avaliacoes/cumulativa-04-qualidade-e-plataforma.md) | Dia 24 do plano, cobrindo os módulos 11 a 13 |

---

## 🔗 Para onde isso vai

Nada aqui é teoria solta. Este é o mapa de reaproveitamento:

| Conceito deste módulo | Onde reaparece |
|---|---|
| Ler stack trace e erros de layout | [06 — Constraints](../06-widgets-e-layouts/06-constraints.md) e [referencias/erros-comuns.md](../../referencias/erros-comuns.md) |
| DevTools e Performance | [13 — Medindo desempenho](../13-desempenho-e-seguranca/04-medindo-desempenho.md) |
| `analysis_options.yaml` e lints | [16 — CI/CD introdutório](../16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md) |
| Testes de unidade e de widget | [projetos/03 — Etapa 7: testes](../../projetos/03-projeto-final-multiplataforma/09-etapa-7-testes.md) |
| Mocks da camada HTTP | [09 — Camada de dados testável](../09-consumo-de-api/07-camada-de-dados-testavel.md) |
| Testes de banco com FFI | [10 — Migrações](../10-persistencia-de-dados/06-migracoes.md) |
| Diagnóstico de Gradle | [14 — Diagnóstico de build](../14-build-android/10-diagnostico-de-build.md) |
| Diagnóstico de CocoaPods/assinatura | [15 — Diagnóstico de CocoaPods e assinatura](../15-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir fazer **sem consultar a aula**:

- [ ] Leio um quadro `EXCEPTION CAUGHT BY ...` e aponto a primeira linha do **meu** código.
- [ ] Explico a diferença entre a caixa vermelha (debug) e a tela cinza (release).
- [ ] Classifico um erro como de **build**, de **layout** ou de **estado** só pelo texto.
- [ ] Digo de cabeça a causa de `RenderFlex overflowed`, `setState() called after dispose()`,
      `Null check operator used on a null value`, `No Material widget found` e
      `Vertical viewport was given unbounded height`.
- [ ] Aplico o método de 5 passos para depurar um erro que nunca vi antes.
- [ ] Uso `debugPrint()` em vez de `print()` e explico por que o lint `avoid_print` existe.
- [ ] Coloco um breakpoint condicional no VS Code e inspeciono variáveis e a pilha de chamadas.
- [ ] Abro o DevTools, seleciono um widget na tela e leio as constraints resolvidas dele.
- [ ] Uso o Layout Explorer para consertar um `Row` que estoura.
- [ ] Leio a aba Network do DevTools e vejo a requisição que a `TrilhaApi` fez.
- [ ] Rodo `dart analyze` e `dart format .` sem nenhum apontamento pendente.
- [ ] Ativo uma regra extra no `analysis_options.yaml` e transformo um aviso em erro.
- [ ] Escrevo um teste de unidade com `group`, `setUp`, `expect` e `throwsA(isA<X>())`.
- [ ] Escrevo um teste de widget que preenche um formulário, toca no botão e verifica a mensagem.
- [ ] Explico o erro `A Timer is still pending even after the widget tree was disposed` e o corrijo.
- [ ] Crio um mock de `http.Client` com `mocktail`, uso `when`/`thenAnswer` e `verify`.
- [ ] Registro um `Fake` com `registerFallbackValue` e sei por que isso é obrigatório.
- [ ] Testo o `MateriaDao` com `sqflite_common_ffi` e `inMemoryDatabasePath`, sem emulador.
- [ ] Escrevo e rodo um teste de integração que cadastra uma matéria e a vê na lista.
- [ ] 🤖 Leio o log de um aparelho com `flutter logs` e filtro `adb logcat` por tag.
- [ ] 🪟 Explico, sem hesitar, o que eu consigo e o que eu não consigo depurar no Windows.
- [ ] Todos os exercícios **obrigatórios** de [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md) estão feitos.
- [ ] Acertei ao menos 7 das 10 questões de [avaliacoes/modulo-12-testes-e-debug.md](../../avaliacoes/modulo-12-testes-e-debug.md).

Quando todos estiverem marcados, siga para o
[Módulo 13 — Desempenho e Segurança](../13-desempenho-e-seguranca/README.md).

---

## 📚 Referências oficiais do módulo

- [Testing Flutter apps — docs.flutter.dev](https://docs.flutter.dev/testing/overview)
- [Debugging Flutter apps — docs.flutter.dev](https://docs.flutter.dev/testing/debugging)
- [Flutter DevTools — docs.flutter.dev](https://docs.flutter.dev/tools/devtools/overview)
- [Common Flutter errors — docs.flutter.dev](https://docs.flutter.dev/testing/common-errors)
- [package:test — pub.dev](https://pub.dev/packages/test)
- [mocktail — pub.dev](https://pub.dev/packages/mocktail)
- [sqflite_common_ffi — pub.dev](https://pub.dev/packages/sqflite_common_ffi)
- [Customizing static analysis — dart.dev](https://dart.dev/tools/analysis)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 11 — Recursos Nativos](../11-recursos-nativos/README.md) | [README do curso](../../README.md) | [Aula 1 — Lendo stack traces](01-lendo-stack-traces.md) |
