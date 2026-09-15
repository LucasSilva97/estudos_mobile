# Avaliação — Módulo 15: Build e distribuição iOS

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. A compilação iOS exige macOS porque: A) o Flutter só gera binário ARM no macOS; B) o SDK do iPhone, o `codesign` e o chaveiro vivem dentro do Xcode e do macOS; C) falta o suporte a iOS no Flutter para Windows; D) o Dart não compila em AOT no Windows.  
2. Com um `Podfile` no projeto, você abre no Xcode: A) `ios/Runner.xcodeproj`, que é o projeto de verdade; B) `ios/Runner.xcworkspace`, senão o build falha com `module 'X' not found`; C) o próprio `ios/Podfile`; D) tanto faz, o Xcode resolve os pods sozinho.  
3. `ERROR ITMS-90717` no upload indica: A) build number repetido; B) ícone com canal alfa — corrija com `remove_alpha_ios: true`; C) falta a resposta de criptografia; D) Bundle ID divergente entre configurações.  
4. Se `CFBundleShortVersionString` trouxer `1.0.0` literal em vez de `$(FLUTTER_BUILD_NAME)`: A) nada muda, é o mesmo valor; B) o build falha imediatamente; C) o `pubspec.yaml` deixa de valer para o iOS e as versões divergem em silêncio; D) o Xcode reescreve o `Info.plist` a cada build.  
5. Com um Apple ID **gratuito** você: A) publica na App Store, mas sem TestFlight; B) instala em até 3 aparelhos e o app para de abrir em 7 dias; C) instala em 100 aparelhos por 1 ano; D) usa o teste interno do TestFlight, mas não o externo.  
6. Você enviou `1.0.0+1`, descartou o build e quer reenviar. O certo é: A) reusar o `+1`, que voltou a ficar livre; B) subir para `+2`, porque nenhum número é reaproveitável e repetir dá `ITMS-4238`; C) trocar para `1.0.1+1`, pois o que conta é o nome da versão; D) reenviar igual, que o App Store Connect substitui o anterior.

7. Diferencie o teste **interno** do teste **externo** do TestFlight.  
8. Explique por que registrar o UDID de um iPhone novo no portal não faz o app instalar nele.  
9. Diferencie o `.xcarchive` do `.ipa` e diga qual dos dois você guarda, e por quê.  
10. Explique por que uma chave `NS…UsageDescription` ausente é mais grave no iOS do que a permissão equivalente faltando no Android.

## 2. Prática

No **Windows**, deixe o projeto Foco pronto para o dia em que houver um Mac. Defina o Bundle ID `br.com.estudos.foco` nas três configurações (Debug, Release, Profile); gere o `AppIcon.appiconset` a partir de um PNG 1024 × 1024 com `remove_alpha_ios: true`; deixe `version: 1.0.0+1` no `pubspec.yaml` e o `Info.plist` apontando para `$(FLUTTER_BUILD_NAME)` e `$(FLUTTER_BUILD_NUMBER)`, com textos de permissão em português, específicos, e só do que o Foco realmente usa. Rode `ferramentas/conferir-identidade.ps1` e `ferramentas/conferir-ios.ps1` e registre a saída dos dois em `docs/release-ios.md`, junto de um roteiro numerado das etapas que **exigem macOS** (aulas 7 a 9), dizendo em cada uma o que especificamente não roda no Windows.

| Critério | Pontos |
|---|---:|
| `br.com.estudos.foco` idêntico nas três configurações do `project.pbxproj` | 2 |
| `AppIcon.appiconset` completo, com o 1024 × 1024 sem canal alfa | 2 |
| `version: 1.0.0+1` ligada ao `Info.plist` pelas duas variáveis | 2 |
| Permissões em português, específicas e sem chave sobrando | 2 |
| `docs/release-ios.md` com as duas saídas e o roteiro do Mac | 2 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem erros e `conferir-ios.ps1` sem problemas.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Por que não dá para compilar no Windows | [Aula 01](../modulos/15-build-ios/01-por-que-exige-macos.md) | E01 |
| Xcode, SPM e CocoaPods | [Aula 02](../modulos/15-build-ios/02-xcode-e-cocoapods.md) | E02 |
| Bundle ID, workspace e Deployment Target | [Aula 04](../modulos/15-build-ios/04-bundle-id-e-xcode.md) | E03 |
| Ícone, versão e `Info.plist` | [Aula 05](../modulos/15-build-ios/05-icone-splash-versao-infoplist.md) | E04 e E05 |
| Conta Apple e seus limites | [Aula 06](../modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md) | E06 |
| Certificados e provisioning | [Aula 07](../modulos/15-build-ios/07-certificados-e-provisioning.md) | E07 |
| Archive, IPA e TestFlight | [Aulas 08 e 09](../modulos/15-build-ios/08-build-ipa-e-archive.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-15)
