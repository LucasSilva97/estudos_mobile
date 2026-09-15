# Avaliação — Módulo 11: Recursos nativos

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Para usar a câmera no 🤖 Android, o app precisa: A) apenas declarar `<uses-permission>` no `AndroidManifest.xml`; B) declarar no manifesto **e** pedir em tempo de execução; C) apenas chamar `Permission.camera.request()`; D) apenas escrever `NSCameraUsageDescription`.  
2. `connectivity_plus` devolver `ConnectivityResult.wifi` prova que: A) a internet está funcionando; B) o servidor do app está no ar; C) existe uma interface de rede ativa, e nada além disso; D) o DNS respondeu dentro do prazo.  
3. O rascunho da sessão de estudo deve ser salvo em: A) `paused`, porque `detached` pode não ser chamado; B) `inactive`, que chega primeiro; C) `detached`, o último estado antes de morrer; D) `hidden`, que só existe no 🍎 iOS.  
4. `Switch.adaptive` decide a aparência olhando: A) `Platform.isIOS`; B) o sistema operacional do aparelho; C) `kIsWeb`; D) `Theme.of(context).platform`.  
5. Um lembrete diário às 19h, sem estourar o limite de 64 notificações pendentes do 🍎 iOS, se agenda: A) com 30 notificações, uma por dia; B) com uma notificação e `matchDateTimeComponents: DateTimeComponents.time`; C) com `SCHEDULE_EXACT_ALARM` para garantir o horário; D) reagendando tudo a cada abertura do app.  
6. No Xcode, um projeto Flutter se abre por: A) `ios/Runner.xcodeproj`, o projeto principal; B) `ios/Runner/Info.plist`; C) `ios/Runner.xcworkspace`, que junta o projeto com os Pods; D) `ios/Podfile`.

7. Diferencie o que `pickImage` devolve quando o usuário cancela do que ele devolve quando escolhe uma foto, e diga por que o caminho do `XFile` não serve para guardar no banco.  
8. Explique por que um backup em JSON precisa de `formato`, `versao` e `exportado_em`, e por que a validação acontece antes de gravar qualquer linha.  
9. Explique a regra "interceptar o voltar é aceitável; impedir não é" aplicada a um formulário de matéria com alterações não salvas.  
10. Explique por que 160 pub points não decidem a adoção de um pacote e cite dois sinais que pesam mais.

## 2. Prática

No projeto `foco_nativo`, monte a tela de sessão de estudo do app Foco reunindo três recursos do módulo.
O cronômetro mede pelo **carimbo de início** (`SessaoEmAndamento`), nunca por contador; um `AppLifecycleListener`
salva em `paused`, recarrega em `resumed` e descarta sessão suspeita (12 h ou mais); um `StreamProvider` sobre
`ObservadorDeRede` alimenta uma faixa discreta de offline; e um `PopScope` confirma o descarte da sessão em
andamento, sempre com caminho de saída. Rode com `flutter run -d windows`.

| Critério | Pontos |
|---|---:|
| Cronômetro mede pelo carimbo de início; `Timer` só redesenha | 2 |
| Salva em `paused` e recarrega em `resumed`, sem depender de `detached` | 2 |
| Sessão recuperada com 12 h ou mais é descartada | 1 |
| `StreamProvider` com valor inicial e faixa discreta de offline | 2 |
| `PopScope` com `canPop` dinâmico e saída garantida | 2 |
| `dispose` do listener e `cancel` do `Timer` | 1 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem erros na pasta `foco_nativo`.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Declarar × pedir permissão, `permanentlyDenied` | [Aula 01](../modulos/11-recursos-nativos/01-permissoes.md) | E01 |
| Cancelamento e arquivo temporário do `image_picker` | [Aula 02](../modulos/11-recursos-nativos/02-camera-e-galeria.md) | E02 |
| Backup em JSON e validação antes de aplicar | [Aula 03](../modulos/11-recursos-nativos/03-arquivos-e-compartilhamento.md) | E03 |
| Lembrete recorrente, `TZDateTime` e limite do iOS | [Aula 04](../modulos/11-recursos-nativos/04-notificacoes.md) | E04 |
| Interface de rede × internet | [Aula 05](../modulos/11-recursos-nativos/05-conectividade.md) | E05 |
| Cronômetro que mente e transições do app | [Aula 06](../modulos/11-recursos-nativos/06-ciclo-de-vida-do-app.md) | E06 |
| Pastas `android/` e `ios/` e o que versionar | [Aula 07](../modulos/11-recursos-nativos/07-pastas-android-e-ios.md) | E07 |
| `PopScope`, adaptação e escolha de pacotes | [Aulas 08 a 10](../modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-11)
