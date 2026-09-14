# Módulo 15 — Build e Distribuição iOS

> **Tempo estimado total:** 390 min de execução completa em um Mac · **Nível:** Avançado ·
> **Posição no plano:** Dia 29 do ritmo intensivo de 30 dias

---

## 🍎🪟 LEIA ISTO ANTES DE QUALQUER COISA

> # ⚠️ ESTE MÓDULO INTEIRO EXIGE macOS + Xcode.
>
> **Você está no Windows 11.** Não existe forma legal, oficial ou confiável de compilar,
> assinar ou publicar um aplicativo iOS a partir do Windows. Isso **não** é uma limitação do
> Flutter: é uma limitação da Apple, e vale igualmente para Swift nativo, React Native,
> Kotlin Multiplatform e qualquer outra tecnologia.
>
> **Este módulo não vai te fazer gerar um IPA no Windows. Nenhuma aula, nenhum truque,
> nenhum atalho.** Quem promete isso está vendendo algo que não funciona.
>
> O que este módulo faz é outra coisa, e é valiosa: te dar o **processo iOS inteiro**,
> passo a passo, executável de ponta a ponta, para o dia em que você **tiver acesso a um Mac**
> — emprestado, alugado na nuvem, comprado, ou por um serviço de integração contínua.

**IPA** (*iOS App Store Package*) é o arquivo instalável de um app iOS — o equivalente ao
`.apk` do Android. **Xcode** é o ambiente de desenvolvimento oficial da Apple, distribuído
somente para macOS.

### 🪟 O que fazer no Windows enquanto isso

Você não fica parado. Estas oito coisas você faz **hoje**, no seu Windows 11, sem Mac:

| # | O que fazer agora no Windows | Onde |
|---|---|---|
| 1 | Escrever **100% do código Dart/Flutter** do app Foco | Módulos 05 a 13 |
| 2 | Rodar **todos os testes** (unitários, de widget, de banco com `sqflite_common_ffi`) | [Módulo 12](../12-testes-e-debug/README.md) |
| 3 | Gerar **APK e AAB** assinados de verdade e instalar no Android | [Módulo 14](../14-build-android/README.md) |
| 4 | Definir o **Bundle Identifier** `br.com.estudos.foco` no projeto | [Aula 4](04-bundle-id-e-xcode.md) |
| 5 | Gerar o **ícone iOS** com `flutter_launcher_icons` (ele escreve em `ios/Runner/Assets.xcassets/`) | [Aula 5](05-icone-splash-versao-infoplist.md) |
| 6 | Escrever as **chaves de permissão** do `ios/Runner/Info.plist` em português | [Aula 5](05-icone-splash-versao-infoplist.md) |
| 7 | Definir `version: 1.0.0+1` no `pubspec.yaml` — vale para iOS **e** Android | [Aula 5](05-icone-splash-versao-infoplist.md) |
| 8 | **Ler e entender** as 10 aulas, para não aprender tudo isso sob pressão | este módulo |

Os itens 4 a 7 são editados em **arquivos de texto** que existem na sua pasta `ios/` mesmo no
Windows. Eles ficam versionados no Git e, no dia em que você abrir o projeto num Mac, já estarão
prontos. Só a **compilação**, a **assinatura** e o **envio** precisam do macOS.

> 🪟 Leitura no Windows: cerca de **150 min** para as 10 aulas.
> 🖥️ Execução real num Mac: cerca de **390 min**, que é o número do topo desta página.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- Explicar **tecnicamente** por que a compilação iOS exige macOS: a toolchain da Apple, os SDKs
  embutidos no Xcode, o chaveiro do macOS e o contrato de licença do Xcode.
- Comparar as opções reais de acesso a um Mac — emprestado, Mac mini, Mac na nuvem, CI com
  runner macOS — com prós, contras e faixa de custo.
- Instalar e configurar Xcode, ferramentas de linha de comando, Swift Package Manager e
  CocoaPods.
- Rodar o app Foco no **Simulador** e num **iPhone físico**, incluindo o Modo de Desenvolvedor
  do iOS 16+ e a confiança no certificado do desenvolvedor.
- Definir corretamente o **Bundle Identifier** `br.com.estudos.foco` e navegar pelo Xcode sem se
  perder (`General`, `Signing & Capabilities`, `Build Settings`).
- Gerar ícone e splash para iOS, preencher o `Info.plist` e ligar `version: 1.0.0+1` do
  `pubspec.yaml` a `CFBundleShortVersionString` e `CFBundleVersion`.
- Decidir entre **Apple ID gratuito** e **Apple Developer Program (US$ 99/ano)** sabendo
  exatamente o que cada um permite e o que cada um proíbe.
- Entender a cadeia de assinatura inteira: chave privada → CSR → certificado → App ID →
  dispositivos → provisioning profile.
- Gerar **archive** e **IPA** com `flutter build ipa` e pelo Xcode Organizer, e validar antes de
  enviar.
- Publicar no **TestFlight** e entender teste interno × teste externo.
- Diagnosticar os erros clássicos de CocoaPods e de assinatura por sintoma.

---

## ✅ Pré-requisitos

- **Obrigatório:** ter concluído o
  [Módulo 14 — Build e Distribuição Android](../14-build-android/README.md).
  O módulo 14 ensina os conceitos que este módulo reaproveita: build de release, identidade do
  app, ícone, splash, versionamento e assinatura. Aqui você vai ver os **mesmos conceitos** com
  as ferramentas da Apple.
- Projeto final **Foco** funcionando, com `applicationId` / Bundle ID `br.com.estudos.foco`.
  Veja [projetos/03-projeto-final-multiplataforma/README.md](../../projetos/03-projeto-final-multiplataforma/README.md).
- Flutter **3.47.1** / Dart **3.13.1** instalados e com `flutter doctor` limpo na parte que não
  depende de Xcode. Veja [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).
- Git configurado. Você vai precisar dele para levar o projeto até o Mac
  ([Módulo 00](../00-git-e-terminal/README.md)).
- **Não** é pré-requisito ter um Mac. Oito das dez aulas são úteis mesmo sem ele; as duas que
  não são (8 e 9) você lê agora e executa depois.

---

## 🗺️ Ordem recomendada das aulas

Faça na ordem. Cada aula assume o vocabulário da anterior.

| # | Aula | Tempo | O que você sai sabendo | 🪟 Executa no Windows? |
|---|---|---|---|---|
| 1 | [Por que o iOS exige macOS](01-por-que-exige-macos.md) | 30 min | Toolchain da Apple, licença do Xcode, opções reais de Mac e custo | ✅ Sim (o roteiro de diagnóstico) |
| 2 | [Xcode e CocoaPods](02-xcode-e-cocoapods.md) | 45 min | Instalar Xcode, `xcode-select`, SPM ligado por padrão, CocoaPods e seu fim de vida | ❌ Não (só leitura) |
| 3 | [Simulador e iPhone físico](03-simulador-e-iphone-fisico.md) | 35 min | `open -a Simulator`, `flutter run -d`, Modo de Desenvolvedor do iOS 16+ | ❌ Não (só leitura) |
| 4 | [Bundle ID e o Xcode](04-bundle-id-e-xcode.md) | 35 min | Domínio invertido, `br.com.estudos.foco`, `.xcworkspace` × `.xcodeproj`, Deployment Target iOS 13 | ⚠️ Parcial (edita arquivos) |
| 5 | [Ícone, splash, versão e Info.plist](05-icone-splash-versao-infoplist.md) | 45 min | `AppIcon.appiconset`, `remove_alpha_ios`, `LaunchScreen.storyboard`, `$(FLUTTER_BUILD_NAME)` | ✅ Sim (gera os arquivos) |
| 6 | [Conta Apple gratuita × paga](06-conta-apple-gratuita-x-paga.md) | 25 min | 7 dias × 1 ano, 3 aparelhos, TestFlight, US$ 99/ano, individual × organização | ✅ Sim (decisão e cadastro) |
| 7 | [Certificados e provisioning](07-certificados-e-provisioning.md) | 45 min | CSR, certificado, App ID, lista de dispositivos, profile, assinatura automática × manual | ❌ Não (só leitura) |
| 8 | [Build: IPA e archive](08-build-ipa-e-archive.md) | 45 min | `flutter build ipa`, `.xcarchive`, Organizer, Validate App | ❌ Não (só leitura) |
| 9 | [Exportando o IPA e TestFlight](09-exportando-ipa-e-testflight.md) | 45 min | App Store Connect, Transporter, build number crescente, teste interno × externo | ❌ Não (só leitura) |
| 10 | [Diagnóstico: CocoaPods e assinatura](10-diagnostico-cocoapods-e-assinatura.md) | 40 min | Tabela sintoma → causa → correção dos erros mais comuns | ❌ Não (só leitura) |

**Total: 390 min.** No Windows, a leitura completa leva cerca de **150 min**, e as aulas 1, 5 e 6
têm prática de verdade que você faz hoje.

---

## 🧪 Prática e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Exercícios do módulo | [exercicios/15-build-ios.md](../../exercicios/15-build-ios.md) | Depois de terminar as 10 aulas |
| Gabaritos comentados | [gabaritos/15-build-ios.md](../../gabaritos/15-build-ios.md) | Só **depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-15-build-ios.md](../../avaliacoes/modulo-15-build-ios.md) | Ao final, para liberar o Módulo 16 |

Materiais de apoio que você vai abrir várias vezes neste módulo:

- [checklists/ambiente-ios.md](../../checklists/ambiente-ios.md) — conferência do ambiente Mac.
- [checklists/build-ios.md](../../checklists/build-ios.md) — conferência antes de cada envio.
- [referencias/erros-comuns.md](../../referencias/erros-comuns.md) — erros reais e correção.
- [referencias/diferencas-android-ios.md](../../referencias/diferencas-android-ios.md) — tabela
  comparativa das duas plataformas.
- [referencias/glossario.md](../../referencias/glossario.md) — todo termo técnico do curso.
- [referencias/comandos-uteis.md](../../referencias/comandos-uteis.md) — cola de comandos.

---

## 🧰 Preparação (faça agora, no Windows)

Antes da Aula 1, garanta que o projeto Foco está limpo e versionado. É por meio do Git que ele
vai chegar ao Mac — copiar a pasta inteira por pendrive só leva lixo de build junto.

**🪟 Windows (PowerShell)**

```powershell
Set-Location C:\src\cursos\foco
flutter --version
flutter clean
flutter pub get
flutter analyze
flutter test
git status
```

O que esperar: `flutter --version` mostrando `Flutter 3.47.1 • Dart 3.13.1`; `flutter analyze`
terminando com `No issues found!`; `flutter test` terminando com `All tests passed!`; e
`git status` sem nada pendente.

> ⚠️ Se `flutter analyze` ou `flutter test` falharem, **pare aqui**. Levar um projeto quebrado
> para o Mac transforma um erro de Dart num erro de Xcode, que é muito mais difícil de ler.

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir explicar/fazer **sem consultar a aula**:

- [ ] Explico, em três frases técnicas, por que não dá para compilar iOS no Windows — citando
      toolchain, SDK dentro do Xcode e chaveiro do macOS.
- [ ] Listo as quatro formas reais de conseguir um Mac e digo prós, contras e faixa de custo de
      cada uma.
- [ ] Digo de cor a sequência de comandos de primeira configuração do Xcode
      (`xcode-select --install`, `--switch`, `-runFirstLaunch`, `-license accept`).
- [ ] Explico o que é o Swift Package Manager, por que ele é o padrão desde o Flutter 3.44 e em
      que situação o CocoaPods ainda entra.
- [ ] Sei ligar e desligar o SPM globalmente e por projeto.
- [ ] Descrevo o passo a passo para rodar o app num iPhone físico, incluindo o Modo de
      Desenvolvedor do iOS 16+ e a tela "VPN e Gerenciamento de Dispositivo".
- [ ] Escrevo o Bundle ID `br.com.estudos.foco` no formato correto e explico por que ele não
      pode mudar depois da publicação.
- [ ] Digo por que sempre se abre `ios/Runner.xcworkspace` e nunca `ios/Runner.xcodeproj`.
- [ ] Explico a ligação entre `version: 1.0.0+1` do `pubspec.yaml`,
      `CFBundleShortVersionString` e `CFBundleVersion`.
- [ ] Escrevo um texto de `NSCameraUsageDescription` que a Apple aceitaria, e explico por que um
      texto genérico é rejeitado.
- [ ] Comparo Apple ID gratuito e Apple Developer Program em pelo menos seis critérios.
- [ ] Desenho de memória a cadeia: chave privada → CSR → certificado → App ID → dispositivos →
      provisioning profile.
- [ ] Listo os arquivos de assinatura (`.cer`, `.p12`, `.mobileprovision`) e afirmo que
      **nenhum** pode ir para o Git.
- [ ] Digo o caminho exato do archive e do IPA gerados pelo Flutter.
- [ ] Explico a regra do build number crescente e o que acontece se você repetir um número.
- [ ] Diferencio teste interno e teste externo do TestFlight em limite, prazo e revisão.
- [ ] Resolvo, olhando só o sintoma, pelo menos seis dos erros da tabela da Aula 10.
- [ ] Concluí ao menos **8 exercícios obrigatórios** de
      [exercicios/15-build-ios.md](../../exercicios/15-build-ios.md).
- [ ] Acertei **7 ou mais** das 10 questões de
      [avaliacoes/modulo-15-build-ios.md](../../avaliacoes/modulo-15-build-ios.md).

Quando todos os itens estiverem marcados, siga para o
[Módulo 16 — Publicação e Próximos Passos](../16-publicacao-e-proximos-passos/README.md).

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 14 — Build e Distribuição Android](../14-build-android/README.md) | [README do curso](../../README.md) | [Aula 1 — Por que o iOS exige macOS](01-por-que-exige-macos.md) |
