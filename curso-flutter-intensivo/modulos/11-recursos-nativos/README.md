# Módulo 11 — Recursos Nativos e Plataformas

> **Nível:** Intermediário · **Tempo estimado total:** 405 min (≈ 6 h 45 min de conteúdo)
> **Pré-requisito direto:** [Módulo 10 — Persistência de Dados](../10-persistencia-de-dados/README.md)

Até aqui o seu app viveu dentro do Flutter. Você desenhou telas, guardou estado com Riverpod,
falou com uma API e gravou dados no SQLite. Tudo isso acontece **dentro** do processo do seu app,
e por isso funcionava igual no Chrome, no Windows e no Android.

Este módulo é sobre o momento em que o app **sai de si mesmo** e pede alguma coisa ao sistema
operacional: a câmera, a galeria de fotos, o disco, a antena de rede, a barra de notificações, o
botão voltar. É aqui que o Android e o iOS deixam de ser "detalhes" e passam a ditar regras — e é
aqui que a maioria dos aplicativos de iniciante quebra na hora de publicar.

O nome disso é **recurso nativo**: qualquer capacidade que pertence ao aparelho e ao sistema
operacional, não ao Flutter. Para chegar até ela, o Flutter usa um **plugin** (*plugin* — um pacote
que, além de código Dart, carrega código Kotlin/Java para o Android e Swift/Objective-C para o iOS,
ligados por um canal de comunicação chamado *platform channel*).

Tudo neste módulo usa **Flutter 3.47.1** e **Dart 3.13.1** no Windows 11.

---

## 🪟 Leia isto antes de começar: o que você consegue e o que não consegue no Windows

Você está no Windows e não tem Mac. Este módulo foi organizado para que isso **não** te impeça de
aprender, mas é preciso ser honesto sobre cada aula:

| Aula | Roda no Windows (`flutter run -d windows` ou `-d chrome`)? | O que você precisa para ver o comportamento real |
|---|---|---|
| 01 — Permissões | ❌ `permission_handler` não suporta Windows | Emulador ou aparelho **🤖 Android** |
| 02 — Câmera e galeria | ❌ `image_picker` no Windows só abre seletor de arquivo | Aparelho **🤖 Android** (câmera de emulador é simulada) |
| 03 — Arquivos e compartilhamento | ✅ a parte de arquivos roda (`path_provider` suporta Windows) | **🤖 Android** para o menu nativo de compartilhar |
| 04 — Notificações | ✅ a parte de cálculo de horário roda em Dart puro | **🤖 Android** para ver a notificação aparecer |
| 05 — Conectividade | ✅ `connectivity_plus` suporta Windows | nada — dá para desligar o Wi-Fi do seu PC e testar |
| 06 — Ciclo de vida do app | ✅ com ressalvas (não existe "app em segundo plano" igual ao celular) | **🤖 Android** para ver `paused` de verdade |
| 07 — Pastas `android/` e `ios/` | ✅ é leitura de arquivos, não execução | nada — os arquivos iOS **são gerados no Windows** |
| 08 — Botão voltar e gestos | ✅ no Chrome o botão voltar do navegador dispara o mesmo caminho | **🤖 Android** para o gesto de borda real |
| 09 — Material × Cupertino | ✅ totalmente | 🍎 um iPhone/simulador só para conferir o visual final |
| 10 — Avaliando pacotes | ✅ totalmente (é pesquisa no pub.dev + comandos de terminal) | nada |

> 🍎 **SÓ NO MAC.** Em nenhuma aula deste módulo você vai compilar para iPhone. O que você **pode**
> fazer no Windows: ler e editar os arquivos da pasta `ios/`, escrever os textos de permissão do
> `Info.plist`, entender o que a Apple exige e por quê. O passo de compilar está no
> [Módulo 16 — Build iOS](../16-build-ios/README.md).

Se você ainda não tem o Android SDK instalado (o `flutter doctor` mostra
`[X] Android toolchain`), instale antes de começar a aula 1 seguindo
[checklists/ambiente-android.md](../../checklists/ambiente-android.md). Sem isso, você consegue
fazer as aulas 03, 05, 06, 07, 08, 09 e 10 — mas vai só ler as aulas 01, 02 e 04.

---

## 🎯 O que você vai aprender

Ao terminar este módulo você será capaz de:

- **Explicar o modelo de permissões das duas plataformas**: por que no 🤖 Android você declara no
  `AndroidManifest.xml` **e** pede em tempo de execução, enquanto no 🍎 iOS você escreve um texto no
  `Info.plist` e o sistema pergunta **uma única vez** na vida do app.
- **Tratar os cinco estados de uma permissão** (`granted`, `denied`, `permanentlyDenied`,
  `restricted`, `limited`) sem deixar o usuário preso numa tela morta.
- **Tirar foto e escolher imagem da galeria** com `image_picker`, tratando o caso mais comum de
  todos — o usuário cancelar — e salvando a imagem no diretório do app.
- **Ler, escrever e exportar arquivos**, gerando um backup em JSON das matérias do usuário e
  entregando esse arquivo pelo menu nativo de compartilhamento.
- **Distinguir notificação local de notificação push** e saber, com honestidade, o que dá para
  fazer sem servidor e o que exige backend.
- **Detectar conectividade sem cair na armadilha clássica**: `connectivity_plus` diz que existe
  **interface de rede**, não que a **internet funciona**.
- **Reagir ao ciclo de vida do app** (`resumed`, `inactive`, `paused`, `hidden`, `detached`) para
  pausar o cronômetro de estudo e salvar rascunhos antes de o sistema matar o processo.
- **Navegar pelas pastas `android/` e `ios/`** sabendo o que é gerado, o que se edita e o que se
  versiona — com os valores reais medidos nesta máquina (AGP 9.1.0, Gradle 9.3.1, `minSdk` 24,
  Swift Package Manager ligado por padrão).
- **Tratar o botão/gesto voltar** com `PopScope`, `canPop` e `onPopInvokedWithResult`, sem cair no
  antipadrão de bloquear a saída.
- **Adaptar a interface por plataforma na medida certa**, com widgets `.adaptive` e dois
  utilitários seus, sem manter duas interfaces em paralelo.
- **Decidir se adota ou não um pacote**, com um checklist objetivo de 10 itens baseado em pub
  points, plataformas suportadas, manutenção e licença.

---

## ✅ Pré-requisitos

| Pré-requisito | Onde está | Por que é necessário |
|---|---|---|
| Módulo 10 — Persistência de Dados | [modulos/10-persistencia-de-dados/README.md](../10-persistencia-de-dados/README.md) | A aula 03 grava arquivos e a 05 depende do cache offline |
| Módulo 08 — Estado e Arquitetura | [modulos/08-estado-e-arquitetura/README.md](../08-estado-e-arquitetura/README.md) | Conectividade e permissões viram providers do Riverpod |
| Módulo 07 — Navegação e Formulários | [modulos/07-navegacao-e-formularios/README.md](../07-navegacao-e-formularios/README.md) | `PopScope` só faz sentido sabendo o que é a pilha do `Navigator` |
| Módulo 05 — Ciclo de vida do `State` | [05/06-ciclo-de-vida-do-state.md](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) | A aula 06 é o ciclo de vida do **app**, um andar acima do `State` |
| Ambiente configurado | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) | Plugins exigem o **Modo de Desenvolvedor** do Windows ligado |

Checagem obrigatória antes da aula 1 — abra o **PowerShell** e rode:

```powershell
flutter --version
flutter doctor
```

A saída precisa conter `Flutter 3.47.1` e `Dart 3.13.1`.

> ⚠️ Este módulo inteiro instala plugins. Se aparecer
> `Building with plugins requires symlink support. Please enable Developer Mode`, o **Modo de
> Desenvolvedor** do Windows está desligado. Rode `start ms-settings:developers` e ligue a chave
> antes de continuar. O passo a passo completo está em
> [referencias/erros-comuns.md](../../referencias/erros-comuns.md).

---

## 🧱 O app que cresce junto com o módulo

Todas as aulas mexem em **um único projeto de laboratório**, chamado `foco_nativo`, que usa o mesmo
domínio do projeto final **Foco — Organizador de Estudos** (matérias, sessões de estudo, metas e
trilhas). Ele nasce na aula 1 e termina a aula 9 assim:

```text
foco_nativo/
├── lib/
│   ├── main.dart                                   <- aula 1 (e ajustado até a 9)
│   ├── core/
│   │   ├── plataforma/
│   │   │   ├── servico_permissoes.dart             <- aula 1
│   │   │   ├── servico_imagens.dart                <- aula 2
│   │   │   ├── servico_arquivos.dart               <- aula 3
│   │   │   ├── servico_conectividade.dart          <- aula 5
│   │   │   └── observador_de_ciclo.dart            <- aula 6
│   │   └── ui/
│   │       ├── botao_adaptativo.dart               <- aula 9
│   │       ├── confirmar_adaptativo.dart           <- aula 9
│   │       └── banner_offline.dart                 <- aula 5
│   ├── features/
│   │   ├── materias/
│   │   │   ├── domain/materia.dart                 <- aula 3
│   │   │   └── presentation/materia_form_screen.dart <- aula 8
│   │   ├── sessoes/
│   │   │   └── presentation/sessao_screen.dart     <- aula 6
│   │   └── lembretes/
│   │       └── domain/agendador_de_lembretes.dart  <- aula 4
├── test/
│   └── agendador_de_lembretes_test.dart            <- aula 4
├── android/                                        <- explorado na aula 7
├── ios/                                            <- explorado na aula 7
└── pubspec.yaml
```

Nada aqui é jogado fora: as classes `ServicoConectividade`, `ObservadorDeCiclo`,
`BotaoAdaptativo` e `confirmarAdaptativo` entram no **Projeto Final** em
[projetos/03-projeto-final-multiplataforma/README.md](../../projetos/03-projeto-final-multiplataforma/README.md).

Crie o projeto agora, uma única vez, e não apague ao terminar:

```powershell
cd C:\src\estudos
flutter create foco_nativo
cd foco_nativo
flutter run -d windows
```

---

## 🗺️ Ordem recomendada das aulas

Siga **nesta ordem**. A aula 1 é pré-requisito direto das aulas 2 e 4; a aula 7 explica os arquivos
que as aulas 1 e 2 mandam editar, então se você ficar perdido no `AndroidManifest.xml` pode dar uma
espiada na 7 antes e voltar.

| # | Aula | Tempo | O que entra na sua cabeça |
|---|---|---|---|
| 1 | [01 — Permissões](01-permissoes.md) | 45 min | Recurso protegido, `AndroidManifest.xml` × `Info.plist`, permissão em tempo de execução, `permission_handler ^13.0.2`, `granted`/`denied`/`permanentlyDenied`/`restricted`, `openAppSettings()`, pedir no momento certo |
| 2 | [02 — Câmera e galeria](02-camera-e-galeria.md) | 45 min | `image_picker ^1.2.3`, `pickImage`, `ImageSource.camera` × `.gallery`, `imageQuality`, `maxWidth`, `XFile`, `Image.file`, cancelamento (`null`), seletor de fotos do Android 13+, limites do emulador |
| 3 | [03 — Arquivos e compartilhamento](03-arquivos-e-compartilhamento.md) | 40 min | Ler/escrever arquivos do app, backup em JSON, seletor de arquivos do sistema, menu nativo de compartilhar, escopo de armazenamento do 🤖 Android, sandbox do 🍎 iOS, quando um pacote vale a pena |
| 4 | [04 — Notificações](04-notificacoes.md) | 40 min | Notificação local × push, `POST_NOTIFICATIONS` no Android 13+, agendar lembrete de estudo, fuso horário e horário de verão, Doze, limites do iOS, por que push exige backend |
| 5 | [05 — Conectividade](05-conectividade.md) | 40 min | `connectivity_plus ^7.3.1`, `checkConnectivity`, `onConnectivityChanged`, portal cativo, verificação real com timeout, banner de offline, `StreamProvider` do Riverpod |
| 6 | [06 — Ciclo de vida do app](06-ciclo-de-vida-do-app.md) | 40 min | `AppLifecycleState`, `WidgetsBindingObserver`, `AppLifecycleListener`, o que fazer em cada transição, morte do processo no 🤖 Android, limites de segundo plano do 🍎 iOS, cronômetro que não mente |
| 7 | [07 — Pastas android/ e ios/](07-pastas-android-e-ios.md) | 45 min | `build.gradle.kts`, `settings.gradle.kts`, `local.properties`, `res/`, `MainActivity`, `Runner.xcworkspace` × `.xcodeproj`, `Info.plist`, `AppDelegate`, `SceneDelegate`, `.xcconfig`, SPM × CocoaPods |
| 8 | [08 — Botão voltar e gestos](08-botao-voltar-e-gestos.md) | 35 min | `PopScope`, `canPop`, `onPopInvokedWithResult`, confirmar descarte, o antipadrão de bloquear o voltar, gesto de borda do 🍎 iOS, consequências de design |
| 9 | [09 — Material × Cupertino](09-material-x-cupertino.md) | 40 min | Quando adaptar e quando não, `Switch.adaptive`, `CircularProgressIndicator.adaptive`, `Platform.isIOS` com `kIsWeb`, `BotaoAdaptativo`, `confirmarAdaptativo`, `PageTransitionsTheme`, custo de duas UIs |
| 10 | [10 — Avaliando pacotes](10-avaliando-pacotes.md) | 35 min | Pub points, likes, downloads, data de publicação, aba Platforms, issues, publisher verificado, licença, árvore de dependências, plugin federado, checklist de 10 itens |

**Total: 405 min.** No [plano intensivo de 30 dias](../../01-plano-intensivo.md), este módulo
inteiro cai no **dia 22**, logo depois da avaliação cumulativa 03.

---

## 📝 Exercícios e avaliação

| Etapa | Arquivo | Quando fazer |
|---|---|---|
| Exercícios do módulo | [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md) | Ao terminar cada aula, faça os exercícios que citam aquela aula |
| Gabarito comentado | [gabaritos/11-recursos-nativos.md](../../gabaritos/11-recursos-nativos.md) | **Só depois** de tentar de verdade, com o app rodando |
| Avaliação do módulo | [avaliacoes/modulo-11-recursos-nativos.md](../../avaliacoes/modulo-11-recursos-nativos.md) | Depois da aula 10 |

---

## 🔗 Para onde isso vai

| Conceito deste módulo | Onde reaparece |
|---|---|
| Permissões declaradas no `AndroidManifest.xml` | [15 — Permissões Android](../15-build-android/05-permissoes-android.md) |
| Textos do `Info.plist` | [15 — Ícone, splash, versão e Info.plist](../16-build-ios/05-icone-splash-versao-infoplist.md) |
| Pastas `android/` e `ios/` | [15 — Diagnóstico de build](../15-build-android/10-diagnostico-de-build.md) · [16 — Diagnóstico CocoaPods](../16-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |
| Ciclo de vida e cronômetro | [projeto final — etapa 3](../../projetos/03-projeto-final-multiplataforma/05-etapa-3-estado-com-riverpod.md) |
| Conectividade e cache offline | [10 — Cache e offline](../10-persistencia-de-dados/08-cache-e-offline.md) |
| Depurar plugin que falha só no aparelho | [12 — Depurando Android e iOS](../12-testes-e-debug/09-depurando-android-e-ios.md) |
| Avaliação de pacotes e tamanho do app | [13 — Segurança mobile](../13-desempenho-e-seguranca/06-seguranca-mobile.md) |
| Tabela completa de diferenças | [referencias/diferencas-android-ios.md](../../referencias/diferencas-android-ios.md) |

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir fazer **sem consultar a aula**:

- [ ] Explico a diferença entre declarar uma permissão e pedir uma permissão, e digo por que o
      🤖 Android exige as duas coisas e o 🍎 iOS exige só uma.
- [ ] Escrevo um texto de `NSCameraUsageDescription` que a Apple aceitaria, e digo por que
      "precisamos de acesso" seria rejeitado.
- [ ] Trato `permanentlyDenied` levando o usuário para os ajustes com `openAppSettings()`.
- [ ] Tiro uma foto com `image_picker`, trato o `null` do cancelamento e mostro a imagem na tela.
- [ ] Salvo a imagem escolhida dentro do diretório do app e explico por que não gravo em
      qualquer pasta do 🤖 Android.
- [ ] Exporto as matérias em JSON para um arquivo e abro o menu nativo de compartilhamento.
- [ ] Explico em uma frase a diferença entre notificação local e push, e por que este curso não
      implementa push.
- [ ] Digo por que `connectivity_plus` sozinho **não** prova que a internet funciona, e mostro o
      código que prova.
- [ ] Listo os cinco valores de `AppLifecycleState` e o que meu app faz em cada um.
- [ ] Registro e removo um `WidgetsBindingObserver` sem vazar.
- [ ] Abro o `android/app/build.gradle.kts` e aponto `namespace`, `applicationId`, `minSdk`,
      `targetSdk` e o bloco `buildTypes.release`.
- [ ] Sei dizer por que se abre `ios/Runner.xcworkspace` e nunca `ios/Runner.xcodeproj`.
- [ ] Uso `PopScope` com `canPop: false` + `onPopInvokedWithResult` para confirmar descarte de
      formulário, e explico quando **não** usar.
- [ ] Uso `Switch.adaptive` e `CircularProgressIndicator.adaptive` e explico o que muda.
- [ ] Aplico o checklist de 10 itens a um pacote real do pub.dev e chego a uma decisão justificada.
- [ ] Todos os exercícios **obrigatórios** de
      [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md) estão feitos.
- [ ] Acertei ao menos 7 das 10 questões de
      [avaliacoes/modulo-11-recursos-nativos.md](../../avaliacoes/modulo-11-recursos-nativos.md).
- [ ] `flutter analyze` na pasta `foco_nativo` termina com `No issues found!`.

Quando todos estiverem marcados, siga para o
[Módulo 12 — Testes e Debug](../12-testes-e-debug/README.md).

---

## 📚 Referências oficiais do módulo

- [Permissions — Flutter](https://docs.flutter.dev/platform-integration/platform-permissions)
- [permission_handler — pub.dev](https://pub.dev/packages/permission_handler)
- [image_picker — pub.dev](https://pub.dev/packages/image_picker)
- [connectivity_plus — pub.dev](https://pub.dev/packages/connectivity_plus)
- [AppLifecycleState — api.flutter.dev](https://api.flutter.dev/flutter/dart_ui/AppLifecycleState.html)
- [PopScope class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/PopScope-class.html)
- [Swift Package Manager for Flutter](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)
- [Using packages — Flutter](https://docs.flutter.dev/packages-and-plugins/using-packages)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 10 — Persistência de Dados](../10-persistencia-de-dados/README.md) | [README do curso](../../README.md) | [Aula 1 — Permissões](01-permissoes.md) |
