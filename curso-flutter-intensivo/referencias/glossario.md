# 📖 Glossário do curso — de A a Z

> **Para que serve esta página.** Sempre que você topar com uma palavra estranha em uma aula,
> volte aqui. Cada verbete tem: o termo, a tradução ou a sigla escrita por extenso, uma
> definição curta escrita para quem está começando, um exemplo mínimo e o link da aula onde
> o assunto é ensinado de verdade.
>
> **Como usar.** Não tente decorar. Leia o verbete, entenda a ideia e vá para a aula. O
> glossário é um mapa, não o território.
>
> **Ambiente deste curso:** Flutter 3.47.1 · Dart 3.13.1 · Windows 11.
> Versões de pacotes estão em [05-decisoes-tecnicas.md](../05-decisoes-tecnicas.md).

**Páginas irmãs:** [Comandos úteis](comandos-uteis.md) · [Erros comuns](erros-comuns.md) ·
[Diferenças Android × iOS](diferencas-android-ios.md) · [Referências oficiais](referencias-oficiais.md)

---

## 🔤 Índice de letras

[A](#a) · [B](#b) · [C](#c) · [D](#d) · [E](#e) · [F](#f) · [G](#g) · [H](#h) · [I](#i) ·
[J](#j) · [K](#k) · [L](#l) · [M](#m) · [N](#n) · [O](#o) · [P](#p) · [Q](#q) · [R](#r) ·
[S](#s) · [T](#t) · [U](#u) · [V](#v) · [W](#w) · [X](#x) · [Y](#y) · [Z](#z)

**Legenda dos ícones:** 🤖 Android · 🍎 iOS · 🪟 Windows · 🖥️ macOS · 🐧 Linux

---

## A

### AAB
*Android App Bundle — "pacote de aplicativo Android".*
Formato de publicação da Google Play. Em vez de um arquivo já pronto para instalar, você envia
um **pacote com todas as variações** do app (idiomas, densidades de tela, arquiteturas), e a
própria loja monta na hora o APK enxuto para cada aparelho. É o formato **obrigatório** para
apps novos na Play.
**Exemplo:** `build/app/outputs/bundle/release/app-release.aab`
**Aula:** [15.08 — Gerando APK e AAB](../modulos/15-build-android/08-gerando-apk-e-aab.md)

### ABI
*Application Binary Interface — "interface binária de aplicação".*
O "dialeto" de instruções que o processador do celular entende. Celulares modernos usam
`arm64-v8a`; modelos antigos usam `armeabi-v7a`; emuladores costumam usar `x86_64`. Um APK
pode conter todas as ABIs (fica grande) ou uma por arquivo (fica pequeno).
**Exemplo:** `flutter build apk --split-per-abi` gera `app-arm64-v8a-release.apk`
**Aula:** [15.08 — Gerando APK e AAB](../modulos/15-build-android/08-gerando-apk-e-aab.md)

### Acessibilidade
*Do inglês* accessibility. Conjunto de práticas que permite que pessoas com deficiência usem
seu app: leitor de tela, contraste suficiente, alvos de toque grandes, fonte que aumenta sem
quebrar o layout. Não é "extra": é requisito das duas lojas e, muitas vezes, exigência legal.
**Exemplo:** `Semantics(label: 'Iniciar sessão de estudo', child: botao)`
**Aula:** [13.05 — Acessibilidade](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

### ADB
*Android Debug Bridge — "ponte de depuração do Android".*
Programa de linha de comando que conversa com o celular Android ou com o emulador. Serve para
listar aparelhos, instalar APK, ver os registros do sistema e desinstalar o app. Vem junto com
o Android SDK, na pasta `platform-tools`.
**Exemplo:** `adb devices` lista os aparelhos conectados
**Aula:** [12.09 — Depurando Android e iOS](../modulos/12-testes-e-debug/09-depurando-android-e-ios.md)

### Adaptive icon (ícone adaptativo) 🤖
Ícone do Android 8 ou superior formado por **duas camadas**: um fundo e uma frente. O sistema
recorta as duas juntas no formato que o fabricante do celular escolheu (círculo, quadrado
arredondado, gota). Por isso o desenho precisa caber nos ~66% centrais da imagem: as bordas
podem ser cortadas.
**Exemplo:** `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
**Aula:** [15.03 — Ícone](../modulos/15-build-android/03-icone.md)

### AGP
*Android Gradle Plugin — "plugin Gradle do Android".*
Extensão que ensina o Gradle a construir apps Android. É ele que define `compileSdk`,
`buildTypes`, assinatura e empacotamento. No Flutter 3.47 o `flutter create` gera **AGP 9.1.0**.
Cada versão do AGP exige uma versão mínima de Gradle e de JDK — brigas entre esses três são a
causa nº 1 de erro de build.
**Exemplo:** declarado em `android/settings.gradle.kts`
**Aula:** [15.10 — Diagnóstico de build](../modulos/15-build-android/10-diagnostico-de-build.md)

### Algoritmo
Sequência **finita** e **sem ambiguidade** de passos que resolve um problema. Programar é,
antes de tudo, escrever algoritmos; a linguagem (Dart) é só a forma de escrevê-los de um jeito
que a máquina execute.
**Exemplo:** "some os minutos de cada sessão; divida pelo número de sessões; mostre o resultado"
**Aula:** [01.03 — Algoritmos e decomposição](../modulos/01-logica-e-fundamentos/03-algoritmos-e-decomposicao.md)

### Alias (de keystore)
Nome curto que identifica **uma chave específica** dentro de um arquivo de chaves (keystore).
Um keystore é como um chaveiro: pode guardar várias chaves, e o alias é a etiqueta de cada uma.
Você precisa lembrar do alias para assinar o app.
**Exemplo:** `keyAlias=SEU_ALIAS` no arquivo `android/key.properties`
**Aula:** [15.06 — Keystore](../modulos/15-build-android/06-keystore.md)

### Análise estática
Verificação do seu código **sem executá-lo**. A ferramenta lê o texto do programa e aponta
erros de tipo, variáveis não usadas, `await` esquecido e violações de estilo. É o que roda em
`flutter analyze` e o que pinta de amarelo/vermelho no VS Code.
**Exemplo:** `flutter analyze` → `No issues found!`
**Aula:** [04.07 — Análise estática e lints](../modulos/04-dart-avancado/07-analise-estatica-e-lints.md)

### AOT
*Ahead Of Time — "antes da hora".*
Compilação feita **antes** do app rodar: o Dart vira código de máquina nativo durante o build.
É o modo usado no `release`, e por isso o app publicado abre rápido e roda liso — mas perde o
hot reload.
**Exemplo:** `flutter build apk --release` usa AOT
**Aula:** [01.02 — Dart e Flutter](../modulos/01-logica-e-fundamentos/02-dart-e-flutter.md)

### API
*Application Programming Interface — "interface de programação de aplicações".*
Conjunto de funções ou endereços que um sistema oferece para que outro sistema converse com
ele. Pode ser a API de um pacote Dart (as classes públicas dele) ou uma API web (endereços
HTTP que devolvem dados).
**Exemplo:** `https://jsonplaceholder.typicode.com/posts`
**Aula:** [09.01 — HTTP e REST](../modulos/09-consumo-de-api/01-http-e-rest.md)

### APK
*Android Package — "pacote Android".*
Arquivo único que o Android instala. É o que você manda para um amigo testar ou instala à mão
no seu celular. Serve para teste e distribuição fora da loja; para a Google Play use AAB.
**Exemplo:** `build/app/outputs/flutter-apk/app-release.apk`
**Aula:** [15.08 — Gerando APK e AAB](../modulos/15-build-android/08-gerando-apk-e-aab.md)

### App Store Connect 🍎
Painel web da Apple onde você cadastra o app, envia builds, escreve a descrição, gerencia
testadores do TestFlight e submete para revisão. É o equivalente do Google Play Console.
**Exemplo:** o build enviado por `xcrun altool --upload-app` aparece lá
**Aula:** [17.02 — App Store Connect](../modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md)

### Árvore de widgets
*Widget tree.* Estrutura em forma de árvore que o Flutter monta com os widgets: um widget pai
contém filhos, que contêm netos. `MaterialApp` → `Scaffold` → `Column` → `Text`. Entender que
é uma árvore explica quase tudo em Flutter: herança de tema, propagação de restrições e o
funcionamento do `BuildContext`.
**Exemplo:** `Scaffold(body: Column(children: [Text('a'), Text('b')]))`
**Aula:** [05.03 — main, runApp e a árvore de widgets](../modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md)

### Assinatura digital
Selo criptográfico que prova quem produziu aquele APK/AAB/IPA. Sem assinatura válida, nenhuma
loja aceita o arquivo. Se você perder a chave que assinou a primeira versão, **não consegue
mais publicar atualizações** com aquele mesmo app.
**Exemplo:** bloco `signingConfigs { create("release") { ... } }`
**Aula:** [15.07 — Assinatura no Gradle](../modulos/15-build-android/07-assinatura-no-gradle.md)

### Asset
*Do inglês: "recurso", "ativo".* Arquivo que acompanha o app e não é código: imagem, fonte,
JSON, som. Precisa ser declarado no `pubspec.yaml` para ser empacotado; se você esquecer a
declaração, o app compila e só quebra em tempo de execução.
**Exemplo:** `assets/icone/icone.png` declarado sob `flutter: assets:`
**Aula:** [06.08 — Imagens e assets](../modulos/06-widgets-e-layouts/08-imagens-e-assets.md)

### async / await
Par de palavras-chave do Dart para trabalhar com tarefas demoradas sem travar a tela. `async`
marca a função que pode esperar; `await` pausa **só aquela função** até o resultado chegar,
liberando o resto do app para continuar desenhando.
**Exemplo:** `final resposta = await http.get(uri);`
**Aula:** [04.02 — Futures e async/await](../modulos/04-dart-avancado/02-futures-e-async-await.md)

### AsyncNotifier
Classe base do Riverpod 3 para estado que **nasce de uma operação assíncrona** (uma consulta ao
banco, uma chamada de API). O método `build()` devolve um `Future` e o estado do provider é um
`AsyncValue`, já com carregando/erro/dados prontos.
**Exemplo:** `class TrilhasNotifier extends AsyncNotifier<List<Trilha>> { ... }`
**Aula:** [08.07 — AsyncNotifier e AsyncValue](../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)

### AsyncValue
Tipo do Riverpod que representa os **três estados** de um dado assíncrono ao mesmo tempo:
carregando, erro e dados. Existe para você parar de criar três variáveis soltas
(`carregando`, `erro`, `lista`) e esquecer de sincronizá-las.
⚠️ No Riverpod 3 **não existe mais** `.valueOrNull`; use `.value` (pode ser nulo) ou
`.requireValue` (lança exceção se não houver valor).
**Exemplo:** `estado.when(loading: ..., error: ..., data: ...)`
**Aula:** [08.07 — AsyncNotifier e AsyncValue](../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)

### Autenticação
Processo de provar **quem** está falando com o servidor. Normalmente: você envia usuário e
senha uma vez, recebe um token, e passa a mandar esse token em todas as requisições seguintes.
Não confundir com autorização (o que aquele usuário **pode** fazer).
**Exemplo:** cabeçalho `Authorization: Bearer SEU_TOKEN_AQUI`
**Aula:** [09.08 — Autenticação e tokens](../modulos/09-consumo-de-api/08-autenticacao-e-tokens.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## B

### Backend
*"Parte de trás".* O lado servidor de um sistema: banco de dados, regras de negócio e a API
que o app consome. Você não o vê; só conversa com ele por HTTP. O oposto é o *frontend*, que
neste curso é o app Flutter.
**Exemplo:** `https://jsonplaceholder.typicode.com` faz o papel de backend de teste
**Aula:** [09.01 — HTTP e REST](../modulos/09-consumo-de-api/01-http-e-rest.md)

### Biblioteca
*Library.* Em Dart, uma biblioteca é uma unidade de código que pode ser importada. Na prática,
cada arquivo `.dart` já é uma biblioteca. O que você escolhe expor (público) e esconder
(prefixado com `_`) define o contorno dela.
**Exemplo:** `import 'package:foco/core/rotas/rotas.dart';`
**Aula:** [03.10 — Arquivos, bibliotecas e pacotes](../modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)

### Branch
*"Ramo".* Linha paralela de desenvolvimento no Git. Você cria um branch para mexer numa
funcionalidade sem bagunçar a linha principal (`main`) e só junta de volta quando estiver
funcionando.
**Exemplo:** `git switch -c feature/cronometro`
**Aula:** [00.04 — Commits, branches e .gitignore](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

### Breakpoint
*"Ponto de parada".* Marca que você coloca numa linha de código para o programa **congelar**
ali durante a execução. Com o programa parado, você inspeciona o valor de cada variável.
Substitui com enorme vantagem o hábito de encher o código de `print`.
**Exemplo:** clicar na margem esquerda da linha, no VS Code, e rodar com F5
**Aula:** [12.02 — Logs e breakpoints](../modulos/12-testes-e-debug/02-logs-e-breakpoints.md)

### BuildContext
*"Contexto de construção".* Objeto que representa **a posição de um widget dentro da árvore**.
Com ele o Flutter descobre o tema atual, o `Navigator` mais próximo, o tamanho da tela. Regra
de ouro: o contexto só enxerga o que está **acima** dele na árvore.
**Exemplo:** `Theme.of(context).colorScheme.primary`
**Aula:** [05.07 — BuildContext](../modulos/05-introducao-ao-flutter/07-buildcontext.md)

### Bundle ID 🍎
*Bundle Identifier — "identificador do pacote".* Nome único do app no mundo Apple, no formato
de domínio invertido. É o equivalente exato do `applicationId` do Android. Depois de publicar,
**não pode ser mudado**.
**Exemplo:** `br.com.estudos.foco`
**Aula:** [16.04 — Bundle ID e Xcode](../modulos/16-build-ios/04-bundle-id-e-xcode.md)

### Bytecode
Código intermediário, entre o que você escreve e o que o processador executa. Não é texto nem
linguagem de máquina: é um formato compacto que uma máquina virtual interpreta. O Dart usa
representações intermediárias parecidas no modo JIT.
**Exemplo:** a máquina virtual do Dart (Dart VM) executa essa forma intermediária em `flutter run`
**Aula:** [01.02 — Dart e Flutter](../modulos/01-logica-e-fundamentos/02-dart-e-flutter.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## C

### Base href 🌐
*"endereço base".*
A linha `<base href="...">` do `index.html`, a partir da qual o navegador procura **todos** os
outros arquivos do app. Quando o app não está na raiz do domínio, ela precisa apontar para a
subpasta — e o build cuida disso com `--base-href`. Errada, todos os arquivos dão 404 e a
página fica **branca**, sem nenhuma mensagem de erro visível.
**Exemplo:** `flutter build web --release --base-href /foco/`
**Aula:** [14.08 — Gerando o build web](../modulos/14-build-web-pwa/08-gerando-o-build-web.md)

### Cache
*"Esconderijo", em francês.* Cópia local de um dado que custou caro para obter, guardada para
não precisar buscar de novo. Todo cache tem dois problemas: quando invalidar e o que fazer
quando ele está velho.
**Exemplo:** guardar a lista de trilhas em disco e mostrá-la antes da rede responder
**Aula:** [10.08 — Cache e offline](../modulos/10-persistencia-de-dados/08-cache-e-offline.md)

### Callback
*"Chamada de volta".* Função que você entrega para outro código chamar mais tarde, quando algo
acontecer. Em Flutter, é o que está em `onPressed`, `onChanged`, `onTap`.
**Exemplo:** `ElevatedButton(onPressed: () => salvar(), child: const Text('Salvar'))`
**Aula:** [02.07 — Funções em Dart](../modulos/02-dart-basico/07-funcoes-em-dart.md)

### Certificado 🍎
Arquivo emitido pela Apple que atesta a identidade de quem assina o app. Existem o de
desenvolvimento (rodar no seu iPhone) e o de distribuição (enviar para a App Store). Ele se
combina com o *provisioning profile* para formar a assinatura.
**Exemplo:** marcadores como `SEU_TEAM_ID` sempre substituem o valor real nos exemplos do curso
**Aula:** [16.07 — Certificados e provisioning](../modulos/16-build-ios/07-certificados-e-provisioning.md)

### CI/CD
*Continuous Integration / Continuous Delivery — "integração contínua / entrega contínua".*
Máquina na nuvem que, a cada `git push`, roda análise, testes e build automaticamente. Evita o
clássico "na minha máquina funciona".
**Exemplo:** um fluxo que executa `flutter analyze` e `flutter test` a cada push
**Aula:** [17.04 — CI/CD introdutório](../modulos/17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md)

### Classe
Molde a partir do qual objetos são criados. Define os dados (campos) e os comportamentos
(métodos) que todo objeto daquele tipo terá. Uma classe é a planta; o objeto é a casa
construída.
**Exemplo:** `class Materia { final String nome; const Materia(this.nome); }`
**Aula:** [03.01 — Classes e objetos](../modulos/03-dart-intermediario/01-classes-e-objetos.md)

### CanvasKit 🌐
O motor gráfico **Skia** — o mesmo que o Flutter usa no Android e no iOS — compilado para
WebAssembly. É ele que permite ao Flutter desenhar a interface inteira dentro de um único
`<canvas>` no navegador, em vez de traduzir widgets para HTML. Custa ~1,5 MB no primeiro
carregamento e entrega fidelidade visual idêntica nos três alvos.
**Exemplo:** `build/web/canvaskit/canvaskit.wasm`
**Aula:** [14.02 — Como o Flutter compila para web](../modulos/14-build-web-pwa/02-como-o-flutter-compila-para-web.md)

### CocoaPods 🍎
Gerenciador de dependências nativas para projetos Apple, escrito em Ruby. Até pouco tempo era
a única forma de o Flutter instalar código nativo de plugins no iOS.
⚠️ Está em modo de manutenção e o registro público fica **somente-leitura em 2 de dezembro de
2026**. Hoje o padrão do Flutter é o Swift Package Manager, mas o CocoaPods continua sendo
usado como alternativa quando algum plugin ainda não suporta SPM.
**Exemplo:** `pod install` dentro da pasta `ios/`
**Aula:** [16.02 — Xcode e CocoaPods](../modulos/16-build-ios/02-xcode-e-cocoapods.md)

### Cobertura de testes
*Code coverage.* Porcentagem das linhas do seu código que foram executadas pelos testes. É um
termômetro, não uma nota: 100% de cobertura com testes ruins não garante nada, mas 10% garante
que quase nada está protegido.
**Exemplo:** `flutter test --coverage` gera `coverage/lcov.info`
**Aula:** [12.05 — Testes unitários](../modulos/12-testes-e-debug/05-testes-unitarios.md)

### CORS 🌐
*Cross-Origin Resource Sharing — "compartilhamento de recursos entre origens".*
Regra **do navegador**: ao pedir dados de outra origem, ele faz a requisição mas **esconde a
resposta** do seu código, a menos que o servidor autorize por cabeçalho. Não existe no Android
nem no iOS — por isso o mesmo código funciona no celular e falha no Chrome. Nenhuma
configuração no lado Flutter resolve: ou o servidor manda o cabeçalho, ou você usa um proxy.
**Exemplo:** `Access-Control-Allow-Origin: *`
**Aula:** [14.03 — O que não funciona na web](../modulos/14-build-web-pwa/03-o-que-nao-funciona-na-web.md)

### Coleção
Termo guarda-chuva para estruturas que guardam vários valores: `List` (ordenada, aceita
repetidos), `Set` (sem repetidos, sem ordem garantida) e `Map` (pares chave→valor).
**Exemplo:** `final materias = <String>['Álgebra', 'Física'];`
**Aula:** [02.08 — Listas](../modulos/02-dart-basico/08-listas.md)

### Commit
Fotografia do seu projeto num instante, guardada no Git, com uma mensagem explicando o que
mudou. É a unidade de histórico: você pode voltar a qualquer commit.
**Exemplo:** `git commit -m "Adiciona cronômetro da sessão"`
**Aula:** [00.04 — Commits, branches e .gitignore](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

### compileSdk 🤖
Versão da API do Android **contra a qual seu código é compilado**. Define quais classes e
métodos do sistema você pode escrever. No Flutter 3.47 o valor gerado é **36**. Não confundir
com `minSdk` (o mais antigo que roda) nem com `targetSdk` (aquele para o qual você declara ter
testado).
**Exemplo:** `compileSdk = flutter.compileSdkVersion` em `android/app/build.gradle.kts`
**Aula:** [15.02 — Identidade do app](../modulos/15-build-android/02-identidade-do-app.md)

### Compilação
Tradução do código que você escreveu para uma forma que a máquina executa. O Dart faz isso de
dois jeitos: JIT durante o desenvolvimento (rápido de recarregar) e AOT no release (rápido de
rodar).
**Exemplo:** `flutter build apk --release` compila em AOT
**Aula:** [01.02 — Dart e Flutter](../modulos/01-logica-e-fundamentos/02-dart-e-flutter.md)

### const
Palavra-chave do Dart para valores conhecidos **em tempo de compilação** e imutáveis para
sempre. Em Flutter tem efeito prático de desempenho: um widget `const` não é reconstruído
quando o pai reconstrói.
**Exemplo:** `const Text('Foco')`
**Aula:** [02.03 — var, final e const](../modulos/02-dart-basico/03-var-final-const.md)

### Constraint
*"Restrição".* Regra de tamanho que um widget pai passa ao filho: largura mínima/máxima e
altura mínima/máxima. A frase que resume o layout do Flutter é: **restrições descem, tamanhos
sobem, o pai posiciona**.
**Exemplo:** `BoxConstraints(minWidth: 0, maxWidth: 360, minHeight: 0, maxHeight: 640)`
**Aula:** [06.06 — Constraints](../modulos/06-widgets-e-layouts/06-constraints.md)

### Construtor
Função especial que cria e inicializa um objeto. Em Dart um construtor pode ser nomeado,
fatorado (`factory`) ou constante (`const`). Modelos de valor devem ter construtor `const`
sempre que possível — isso libera `const` nos widgets que os usam.
**Exemplo:** `const Materia({required this.id, required this.nome});`
**Aula:** [03.02 — Construtores](../modulos/03-dart-intermediario/02-construtores.md)

### Contraste
Diferença de luminosidade entre o texto e o fundo. Texto cinza-claro sobre branco é bonito e
ilegível. As diretrizes de acessibilidade pedem no mínimo 4,5:1 para texto normal e 3:1 para
texto grande.
**Exemplo:** texto `#212121` sobre fundo `#FFFFFF` passa folgado
**Aula:** [13.05 — Acessibilidade](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

### CRUD
*Create, Read, Update, Delete — "criar, ler, atualizar, apagar".* As quatro operações básicas
sobre um conjunto de dados. Quase todo app é, no fundo, um CRUD com enfeites.
**Exemplo:** cadastrar, listar, editar e excluir matérias no app Foco
**Aula:** [10.05 — sqflite: CRUD](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

### Cupertino 🍎
Família de widgets do Flutter que imita o visual do iOS (a Apple fica na cidade de Cupertino).
Usar Cupertino no iOS e Material no Android é uma escolha de produto, não uma obrigação.
**Exemplo:** `CupertinoButton(onPressed: () {}, child: const Text('OK'))`
**Aula:** [05.09 — Material e Cupertino](../modulos/05-introducao-ao-flutter/09-material-e-cupertino.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## D

### DAO
*Data Access Object — "objeto de acesso a dados".* Classe cuja única responsabilidade é
conversar com o banco: inserir, consultar, atualizar, apagar. Ela não sabe nada de tela.
⚠️ Faça o DAO **receber** o `Database` pelo construtor; se ele abrir o banco sozinho, não dá
para testar.
**Exemplo:** `class MateriaDao { MateriaDao(this._db); final Database _db; }`
**Aula:** [10.05 — sqflite: CRUD](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

### Dart
Linguagem de programação criada pelo Google, usada pelo Flutter. É tipada, orientada a objetos,
compila para código nativo (AOT) e para JavaScript, e traz null safety ligado por padrão. Neste
curso a versão é **3.13.1**.
**Exemplo:** `void main() => print('Olá');`
**Aula:** [01.02 — Dart e Flutter](../modulos/01-logica-e-fundamentos/02-dart-e-flutter.md)

### Debug (modo)
Modo de build voltado ao desenvolvimento: compila rápido, aceita hot reload, mostra a faixa
"DEBUG" e inclui verificações extras. É lento de propósito — **nunca meça desempenho em
debug**.
**Exemplo:** `flutter run` usa debug por padrão
**Aula:** [15.01 — Debug, profile e release](../modulos/15-build-android/01-debug-profile-release.md)

### Densidade de tela 🤖
Quantidade de pixels por polegada de um aparelho. O Android agrupa em faixas: `mdpi`, `hdpi`,
`xhdpi`, `xxhdpi`, `xxxhdpi`. É por isso que uma única imagem de 1024×1024 vira cinco arquivos
de ícone: o sistema escolhe a pasta certa para cada celular.
**Exemplo:** `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
**Aula:** [15.03 — Ícone](../modulos/15-build-android/03-icone.md)

### Dependência
Pacote de terceiros que seu projeto usa. Declarada em `pubspec.yaml`, baixada por
`flutter pub get` e travada em `pubspec.lock`. Cada dependência é um compromisso: alguém
precisa mantê-la viva.
**Exemplo:** `http: ^1.6.0`
**Aula:** [03.10 — Arquivos, bibliotecas e pacotes](../modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)

### Deployment target 🍎
Versão **mínima** do iOS em que seu app se instala. O Flutter 3.47 exige iOS 13 ou superior.
Quanto mais baixo, mais aparelhos você alcança e mais casos antigos precisa suportar.
**Exemplo:** `IPHONEOS_DEPLOYMENT_TARGET = 13.0` no projeto do Xcode
**Aula:** [16.04 — Bundle ID e Xcode](../modulos/16-build-ios/04-bundle-id-e-xcode.md)

### DevTools
Conjunto de ferramentas web do Flutter para inspecionar o app rodando: árvore de widgets,
gráfico de desempenho, uso de memória, requisições de rede e registro de eventos. Versão do
curso: 2.60.0.
**Exemplo:** o endereço do DevTools aparece no terminal quando você roda `flutter run`
**Aula:** [12.03 — DevTools](../modulos/12-testes-e-debug/03-devtools.md)

### Depuração
*Debugging.* Processo de encontrar e corrigir um defeito. Não é adivinhar: é formular hipótese,
observar evidência e reduzir o problema até ele caber numa linha. Há um método de 5 passos no
fim de [erros-comuns.md](erros-comuns.md).
**Exemplo:** colocar um breakpoint antes da linha suspeita e inspecionar as variáveis
**Aula:** [12.02 — Logs e breakpoints](../modulos/12-testes-e-debug/02-logs-e-breakpoints.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## E

### Element
Objeto interno do Flutter que representa a **instância viva** de um widget na árvore. O widget
é a receita (descartável, imutável); o element é o que persiste entre reconstruções e guarda a
ligação com o `State`. Você quase nunca mexe nele diretamente, mas entender que ele existe
explica por que `Key` importa.
**Exemplo:** o `BuildContext` que você recebe em `build` **é** o element daquele widget
**Aula:** [05.03 — main, runApp e a árvore de widgets](../modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md)

### Emulador 🤖
Celular Android virtual rodando no seu computador. Emula o processador e o sistema inteiro, por
isso consome bastante memória. Criado pelo Android Studio e listado por `flutter emulators`.
**Exemplo:** `flutter emulators --launch Pixel_7_API_36`
**Aula:** [02 — Configuração do ambiente](../02-configuracao-do-ambiente.md)

### Encapsulamento
Princípio de esconder o funcionamento interno de uma classe e expor só o necessário. Em Dart o
`_` antes do nome torna o membro privado **à biblioteca** (ao arquivo), não à classe.
**Exemplo:** `int _minutosAcumulados = 0;`
**Aula:** [03.03 — Encapsulamento](../modulos/03-dart-intermediario/03-encapsulamento.md)

### Endpoint
*"Ponto final".* Um endereço específico de uma API, com um caminho e um método HTTP. Cada
endpoint faz uma coisa.
**Exemplo:** `GET https://jsonplaceholder.typicode.com/posts`
**Aula:** [09.01 — HTTP e REST](../modulos/09-consumo-de-api/01-http-e-rest.md)

### enum
*Enumeration — "enumeração".* Tipo com um conjunto **fechado** de valores possíveis. Evita
strings soltas ("ativo", "Ativo", "ativo ") espalhadas pelo código.
**Exemplo:** `enum StatusSessao { emAndamento, pausada, concluida }`
**Aula:** [03.07 — Enums](../modulos/03-dart-intermediario/07-enums.md)

### Exception
*"Exceção".* Objeto que representa um problema esperado durante a execução: arquivo não
encontrado, JSON inválido, rede fora. Você a captura com `try/catch` e decide o que fazer.
Diferente de `Error`, que indica bug de programação e normalmente não deve ser capturado.
**Exemplo:** `on FormatException catch (e) { ... }`
**Aula:** [04.01 — Exceptions](../modulos/04-dart-avancado/01-exceptions.md)

### Expanded
Widget que manda um filho de `Row`/`Column` ocupar **todo o espaço livre** que sobrar naquela
direção. É a resposta mais comum para o erro "RenderFlex overflowed".
**Exemplo:** `Row(children: [Expanded(child: Text(nome)), Icon(Icons.timer)])`
**Aula:** [06.04 — Row, Column e Expanded](../modulos/06-widgets-e-layouts/04-row-column-expanded.md)

### Extension
*"Extensão".* Recurso do Dart para adicionar métodos a um tipo que você não escreveu — `String`,
`int`, `DateTime` — sem herdar dele nem alterar o código original.
**Exemplo:** `extension MinutosLegiveis on int { String get emHoras => '${this ~/ 60}h'; }`
**Aula:** [03.09 — Extensions](../modulos/03-dart-intermediario/09-extensions.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## F

### Fake
Implementação **simplificada e funcional** de uma dependência, feita à mão para os testes. Um
repositório fake pode guardar os dados numa lista em memória. Diferente de um mock, ele
realmente faz alguma coisa.
**Exemplo:** `class MateriaRepositorioFake implements MateriaRepositorioContrato { ... }`
**Aula:** [12.07 — Mocks e fakes](../modulos/12-testes-e-debug/07-mocks-e-fakes.md)

### Family (Riverpod)
Forma de criar um provider **parametrizado**: em vez de um provider fixo, você tem uma família
deles, um por argumento. Útil para "carregue a trilha de id X".
**Exemplo:** `final dobroProvider = Provider.family<int, int>((ref, valor) => valor * 2);`
**Aula:** [08.08 — family, autoDispose e listen](../modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md)

### Feature-first
Organização de pastas por **funcionalidade** em vez de por tipo de arquivo. Em vez de
`models/`, `views/`, `controllers/` gigantes, você tem `features/materias/`, `features/sessoes/`,
cada uma com suas três camadas. Mexer numa funcionalidade passa a tocar uma pasta só.
**Exemplo:** `lib/features/materias/{data,domain,presentation}/`
**Aula:** [08.09 — Arquitetura feature-first](../modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md)

### FilledButton
Botão preenchido do Material 3, o de maior destaque visual. Junto com `FilledButton.tonal`,
`OutlinedButton` e `TextButton`, forma a escada de ênfase. `ElevatedButton` ainda existe, mas o
destaque atual é o `FilledButton`.
**Exemplo:** `FilledButton(onPressed: iniciar, child: const Text('Iniciar'))`
**Aula:** [06.10 — Gestos e feedback](../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md)

### Form
Widget do Flutter que agrupa campos e coordena validação, salvamento e reinício de todos de uma
vez, através de uma `GlobalKey<FormState>`.
**Exemplo:** `if (_chaveForm.currentState!.validate()) { salvar(); }`
**Aula:** [07.06 — Formulários](../modulos/07-navegacao-e-formularios/06-formularios.md)

### FormatException
Exceção do Dart lançada quando um texto não tem o formato esperado — o caso mais comum é
`jsonDecode` recebendo algo que não é JSON (por exemplo, uma página HTML de erro).
**Exemplo:** `on FormatException { throw Falha('Resposta do servidor em formato inválido'); }`
**Aula:** [09.04 — Modelando respostas e erros](../modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md)

### Framework
*"Arcabouço".* Conjunto grande de código pronto que **chama o seu código**, em vez de ser
chamado por ele. O Flutter é um framework: você escreve `build()`, e é ele quem decide quando
chamar.
**Exemplo:** você nunca chama `build()`; o Flutter chama
**Aula:** [01.02 — Dart e Flutter](../modulos/01-logica-e-fundamentos/02-dart-e-flutter.md)

### Future
*"Futuro".* Objeto Dart que representa um valor que **ainda não chegou**, mas vai chegar (ou
falhar). É o retorno natural de qualquer operação demorada.
**Exemplo:** `Future<List<Materia>> listar();`
**Aula:** [04.02 — Futures e async/await](../modulos/04-dart-avancado/02-futures-e-async-await.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## G

### Generic (genérico)
Recurso para escrever código que funciona com **vários tipos** sem perder a checagem de tipos.
O `<T>` é um espaço em branco preenchido na hora do uso.
**Exemplo:** `List<Materia>` é a lista genérica `List<T>` com `T = Materia`
**Aula:** [03.08 — Generics](../modulos/03-dart-intermediario/08-generics.md)

### Gesto
*Gesture.* Toque, toque longo, arraste, pinça. O Flutter transforma eventos de dedo em gestos
reconhecidos e entrega a você por callbacks.
**Exemplo:** `InkWell(onTap: abrirDetalhe, child: card)`
**Aula:** [06.10 — Gestos e feedback](../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md)

### Git
Sistema de controle de versão distribuído: guarda o histórico completo do projeto na sua
própria máquina e permite comparar, voltar e ramificar. Versão do ambiente do curso: 2.46.
Não confundir com GitHub, que é um site que hospeda repositórios Git.
**Exemplo:** `git log --oneline`
**Aula:** [00.03 — Git: o que é](../modulos/00-git-e-terminal/03-git-o-que-e.md)

### .gitignore
Arquivo de texto que lista o que o Git deve **ignorar**. É a sua principal defesa contra
publicar segredo por acidente: `key.properties`, `*.jks`, `*.keystore`, `*.p12`, `*.cer`,
`ios/Runner/*.mobileprovision` e `.env` nunca devem ir para o repositório.
**Exemplo:** uma linha `*.jks` no `.gitignore` da raiz
**Aula:** [00.04 — Commits, branches e .gitignore](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

### go_router
Pacote de navegação declarativa, baseado em rotas descritas por URL, mantido pelo time do
Flutter. Neste curso é conteúdo **opcional**: o padrão ensinado é `Navigator` com rotas
nomeadas, porque com ele você entende a pilha de verdade.
**Exemplo:** `go_router: ^18.0.1`
**Aula:** [07.09 — go_router (opcional)](../modulos/07-navegacao-e-formularios/09-go-router-opcional.md)

### Gradle
Ferramenta de build usada pelo Android. Lê arquivos de script, resolve dependências, compila e
empacota. No Flutter 3.47 o wrapper gerado é o **Gradle 9.3.1**, e os scripts estão em **Kotlin
DSL** (`.kts`), não mais em Groovy.
**Exemplo:** `android/app/build.gradle.kts`
**Aula:** [15.07 — Assinatura no Gradle](../modulos/15-build-android/07-assinatura-no-gradle.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## H

### HandshakeException
*Handshake = "aperto de mão".* Falha na negociação da conexão segura (TLS) antes mesmo de a
requisição sair. Costuma indicar certificado inválido, relógio do aparelho errado ou uma rede
corporativa que intercepta o tráfego.
**Exemplo:** `on HandshakeException { throw Falha('Não foi possível estabelecer conexão segura'); }`
**Aula:** [09.04 — Modelando respostas e erros](../modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md)

### Herança
Mecanismo em que uma classe **estende** outra, herdando campos e métodos. Em Flutter você usa o
tempo todo: `class Tela extends StatelessWidget`. Prefira composição a herança quando a dúvida
aparecer.
**Exemplo:** `class MeuApp extends StatelessWidget { ... }`
**Aula:** [03.04 — Herança e polimorfismo](../modulos/03-dart-intermediario/04-heranca-e-polimorfismo.md)

### Hot reload
Recurso do Flutter que injeta o código alterado no app **já em execução** e redesenha a tela,
preservando o estado atual (o que você digitou, a aba aberta). Leva menos de um segundo. Só
funciona em modo debug.
**Exemplo:** salvar o arquivo com `flutter run` ativo, ou apertar `r` no terminal
**Aula:** [05.08 — Hot reload e hot restart](../modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md)

### Hot restart
Reinicia o app do zero, mantendo a sessão de execução. Perde todo o estado, mas aplica mudanças
que o hot reload não consegue: alterações em `main()`, em variáveis globais, em campos `static`
e em `initState` já executado.
**Exemplo:** apertar `R` (maiúsculo) no terminal do `flutter run`
**Aula:** [05.08 — Hot reload e hot restart](../modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md)

### HTTP
*HyperText Transfer Protocol — "protocolo de transferência de hipertexto".* O idioma que o app
usa para falar com servidores web. Uma conversa HTTP tem método (GET, POST, PUT, PATCH,
DELETE), endereço, cabeçalhos, corpo e um código de status na resposta.
**Exemplo:** `final resposta = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));`
**Aula:** [09.01 — HTTP e REST](../modulos/09-consumo-de-api/01-http-e-rest.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## I

### IDE
*Integrated Development Environment — "ambiente integrado de desenvolvimento".* Programa que
junta editor, depurador, terminal e integração com o SDK. Neste curso: **VS Code** com as
extensões Dart e Flutter.
**Exemplo:** `%LOCALAPPDATA%\Programs\Microsoft VS Code`
**Aula:** [02 — Configuração do ambiente](../02-configuracao-do-ambiente.md)

### Imutabilidade
Propriedade de um objeto que **não muda depois de criado**. Para alterar, você cria uma cópia
com o campo novo (`copyWith`). É a base do modelo do Flutter: widgets são imutáveis, e é por
isso que comparar duas versões da árvore é barato.
**Exemplo:** `materia.copyWith(minutos: materia.minutos + 25)`
**Aula:** [02.03 — var, final e const](../modulos/02-dart-basico/03-var-final-const.md)

### Índice (banco de dados)
Estrutura auxiliar que o banco mantém para achar linhas rápido, como o índice remissivo de um
livro. Acelera consulta e ordenação; custa espaço e torna a escrita um pouco mais lenta.
**Exemplo:** `CREATE INDEX idx_materias_ordenacao ON materias(nome_ordenacao)`
**Aula:** [10.06 — Migrações](../modulos/10-persistencia-de-dados/06-migracoes.md)

### Info.plist 🍎
*Property list — "lista de propriedades".* Arquivo XML com a ficha de identidade do app iOS:
nome exibido, Bundle ID, versão, build e os textos das permissões. Fica em
`ios/Runner/Info.plist`.
**Exemplo:** `<key>NSCameraUsageDescription</key><string>...</string>`
**Aula:** [16.05 — Ícone, splash, versão e Info.plist](../modulos/16-build-ios/05-icone-splash-versao-infoplist.md)

### IndexedDB 🌐
Banco de dados chave-valor do navegador. É onde o SQLite compilado para WebAssembly grava os
blocos do arquivo do banco. O armazenamento é **por origem** (protocolo + domínio + caminho):
mudar a URL do app equivale a começar com um banco vazio.
**Exemplo:** `Application → IndexedDB → sqflite_databases`
**Aula:** [14.04 — Banco de dados na web](../modulos/14-build-web-pwa/04-banco-de-dados-na-web.md)

### InheritedWidget
Widget da própria biblioteca do Flutter que expõe dados para **todos os descendentes** sem
passar parâmetro de mão em mão. É o mecanismo por trás de `Theme.of(context)` e a base sobre a
qual pacotes de estado (inclusive o Riverpod) foram construídos.
**Exemplo:** `Theme.of(context)` busca o `InheritedWidget` de tema acima na árvore
**Aula:** [08.03 — InheritedWidget](../modulos/08-estado-e-arquitetura/03-inheritedwidget.md)

### Injeção de dependências
Prática de **entregar** a uma classe aquilo de que ela precisa, em vez de ela mesma criar. Um
DAO que recebe o `Database` no construtor pode ser testado com um banco em memória; um que abre
o banco sozinho, não.
**Exemplo:** `MateriaDao(this._db);` em vez de `MateriaDao() { _db = abrirBanco(); }`
**Aula:** [08.10 — Injeção de dependências](../modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md)

### Interface
Contrato: a lista de métodos que uma classe promete oferecer, sem dizer como. Em Dart não
existe a palavra `interface` para isso — qualquer classe pode ser implementada com
`implements`, e é comum declarar contratos como classes abstratas.
**Exemplo:** `abstract class MateriaRepositorioContrato { Future<List<Materia>> listar(); }`
**Aula:** [03.05 — Abstratas e interfaces](../modulos/03-dart-intermediario/05-abstratas-e-interfaces.md)

### IPA
*iOS App Store Package — "pacote de app da App Store iOS".* Arquivo final do app iOS, o
equivalente do APK.
> 🍎 **SÓ NO MAC.** Gerar um `.ipa` exige macOS com Xcode. No Windows você aprende todo o
> processo, mas não o executa.
**Exemplo:** `build/ios/ipa/Foco.ipa`
**Aula:** [16.08 — Build IPA e archive](../modulos/16-build-ios/08-build-ipa-e-archive.md)

### Isolate
Unidade de execução independente do Dart, com **memória própria**. Como não compartilha
variáveis, não existe disputa por dado; a conversa é por mensagens. Use para cálculo pesado que
travaria a tela.
**Exemplo:** `final resultado = await Isolate.run(() => calcularEstatisticas(dados));`
**Aula:** [04.08 — Isolates e desempenho](../modulos/04-dart-avancado/08-isolates-e-desempenho.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## J

### Jank
*"Engasgo".* Travadinha visível na animação ou na rolagem, causada por um quadro que demorou
demais para ser desenhado. A 60 quadros por segundo, cada quadro tem ~16 milissegundos.
**Exemplo:** rolar uma lista e sentir "solavancos" — normalmente é trabalho pesado no `build`
**Aula:** [13.04 — Medindo desempenho](../modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md)

### JDK
*Java Development Kit — "kit de desenvolvimento Java".* Pacote com o compilador e a máquina
virtual Java. O Gradle e o AGP rodam sobre ele. Este curso usa **JDK 17 (Temurin)**, que é o
exigido pela combinação AGP 9.1.0 / Gradle 9.3.1.
**Exemplo:** `java -version` mostra `openjdk version "17..."`
**Aula:** [02 — Configuração do ambiente](../02-configuracao-do-ambiente.md)

### JIT
*Just In Time — "bem na hora".* Compilação feita **enquanto** o programa roda. É o que permite
o hot reload: o código novo é compilado e injetado no app vivo. Usado no modo debug.
**Exemplo:** `flutter run` em debug usa JIT
**Aula:** [01.02 — Dart e Flutter](../modulos/01-logica-e-fundamentos/02-dart-e-flutter.md)

### JSON
*JavaScript Object Notation — "notação de objetos do JavaScript".* Formato de texto para
transportar dados: chaves, colchetes, pares nome/valor. É o que quase toda API devolve.
**Exemplo:** `{"userId":1,"id":1,"title":"delectus aut autem","completed":false}`
**Aula:** [09.02 — JSON](../modulos/09-consumo-de-api/02-json.md)

### JWT
*JSON Web Token — "token web em JSON".* Formato de token com três partes separadas por ponto:
cabeçalho, dados e assinatura. Qualquer um consegue **ler** o conteúdo (ele é apenas
codificado, não criptografado); só o servidor consegue verificar a assinatura.
⚠️ Nunca guarde dados sigilosos dentro do token e nunca escreva um token real no código.
**Exemplo:** `Authorization: Bearer SEU_TOKEN_AQUI`
**Aula:** [09.08 — Autenticação e tokens](../modulos/09-consumo-de-api/08-autenticacao-e-tokens.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## K

### Key (chave de widget)
Identidade que você dá a um widget para o Flutter saber, entre duas reconstruções, que "este
item é o mesmo de antes". Sem chave, ao reordenar uma lista o Flutter pode reaproveitar o
estado errado.
**Exemplo:** `ListTile(key: ValueKey(materia.id), title: Text(materia.nome))`
**Aula:** [13.01 — Rebuilds, const e keys](../modulos/13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md)

### Keystore 🤖
*"Depósito de chaves".* Arquivo criptografado que guarda a chave privada com que você assina o
app Android. Se você perdê-lo, perde a capacidade de publicar atualizações.
⚠️ Guarde-o **fora** do repositório e dentro de um backup. Nos exemplos do curso as senhas são
sempre `SUA_SENHA_AQUI`.
**Exemplo:** `upload-keystore.jks`
**Aula:** [15.06 — Keystore](../modulos/15-build-android/06-keystore.md)

### keytool
Programa de linha de comando que vem com o JDK e cria/gerencia keystores e chaves.
**Exemplo:** `keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias SEU_ALIAS`
**Aula:** [15.06 — Keystore](../modulos/15-build-android/06-keystore.md)

### Kotlin DSL (.kts) 🤖
*Domain Specific Language — "linguagem específica de domínio".* Forma de escrever scripts de
build do Gradle usando a linguagem Kotlin, com autocompletar e checagem de tipos. **No Flutter
3.47 o `flutter create` gera `.kts`**, não mais o Groovy. Tutoriais que mandam editar
`android/app/build.gradle` (sem `.kts`) estão desatualizados.
**Exemplo:** `android/app/build.gradle.kts` e `android/settings.gradle.kts`
**Aula:** [15.07 — Assinatura no Gradle](../modulos/15-build-android/07-assinatura-no-gradle.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## L

### Lazy (construção preguiçosa)
Estratégia de só criar o que aparece na tela. `ListView.builder` constrói apenas os itens
visíveis (mais uma margem), em vez dos mil da lista. É a diferença entre um app fluido e um app
que engasga.
**Exemplo:** `ListView.builder(itemCount: 1000, itemBuilder: (context, i) => ...)`
**Aula:** [13.02 — Listas grandes e imagens](../modulos/13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md)

### Lint
*"Fiapo".* Regra de estilo ou de boa prática verificada automaticamente. O conjunto oficial vem
do pacote `flutter_lints ^6.0.0`, ligado no `analysis_options.yaml`.
**Exemplo:** o lint `avoid_print` pede `debugPrint()` em vez de `print()` em código Flutter
**Aula:** [04.07 — Análise estática e lints](../modulos/04-dart-avancado/07-analise-estatica-e-lints.md)

### List
Coleção **ordenada** e indexada, que aceita valores repetidos. É a estrutura mais usada no dia
a dia.
**Exemplo:** `final nomes = <String>['Álgebra', 'Física']; nomes[0];`
**Aula:** [02.08 — Listas](../modulos/02-dart-basico/08-listas.md)

### Loop (laço)
Estrutura que repete um bloco de código. Em Dart: `for`, `for-in`, `while`, `do-while`. Todo
laço precisa de uma condição de parada — sem ela, o programa congela.
**Exemplo:** `for (final s in sessoes) { total += s.minutos; }`
**Aula:** [01.08 — Repetições](../modulos/01-logica-e-fundamentos/08-repeticoes.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## M

### Map
Coleção de pares **chave → valor**, como um dicionário: você procura pela chave e recebe o
valor. As chaves não se repetem.
**Exemplo:** `final minutosPorMateria = <String, int>{'Álgebra': 120, 'Física': 90};`
**Aula:** [02.09 — Sets e Maps](../modulos/02-dart-basico/09-sets-e-maps.md)

### Manifest (web) 🌐
O arquivo `web/manifest.json`: a identidade do app na web. Define nome, nome curto, ícones,
cores, orientação e modo de exibição quando instalado. Faz, sozinho, o papel do
`applicationId` + `android:label` + `res/mipmap-*` do Android.
**Exemplo:** `"short_name": "Foco"` — o texto que aparece embaixo do ícone
**Aula:** [14.05 — Manifest e ícones](../modulos/14-build-web-pwa/05-manifest-e-icones.md)

### Maskable (ícone) 🌐
Ícone desenhado para ser **recortado** pela máscara do sistema (círculo, *squircle*, gota) sem
perder conteúdo. O conteúdo importante precisa caber nos **80 % centrais**. Sem um ícone
`maskable`, o Android desenha uma moldura branca em volta do seu ícone.
**Exemplo:** `{ "src": "icons/Icon-maskable-512.png", "purpose": "maskable" }`
**Aula:** [14.05 — Manifest e ícones](../modulos/14-build-web-pwa/05-manifest-e-icones.md)

### Material 3
Terceira geração do sistema de design do Google, também chamada Material You. Traz paletas
derivadas de uma cor semente, cantos mais arredondados e a nova família de botões. No Flutter
3.47 já é o padrão — você não precisa escrever `useMaterial3: true`.
**Exemplo:** `ThemeData(colorSchemeSeed: Colors.indigo)`
**Aula:** [05.09 — Material e Cupertino](../modulos/05-introducao-ao-flutter/09-material-e-cupertino.md)

### Merge
*"Mesclagem".* Operação do Git que junta o trabalho de dois branches. Quando os dois mexeram na
mesma linha, o Git para e pede que você resolva o conflito à mão.
**Exemplo:** `git merge feature/cronometro`
**Aula:** [00.04 — Commits, branches e .gitignore](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

### Método
Função que pertence a uma classe e opera sobre os dados daquele objeto.
**Exemplo:** `void incrementar() => state = state + 1;`
**Aula:** [03.01 — Classes e objetos](../modulos/03-dart-intermediario/01-classes-e-objetos.md)

### Migração (de banco de dados)
Mudança controlada no formato das tabelas de uma versão do app para a seguinte, sem perder o
que o usuário já tinha salvo. No sqflite você aumenta o `version` e trata o `onUpgrade`.
**Exemplo:** `ALTER TABLE materias ADD COLUMN nome_ordenacao TEXT NOT NULL DEFAULT ''`
**Aula:** [10.06 — Migrações](../modulos/10-persistencia-de-dados/06-migracoes.md)

### minSdk 🤖
Versão **mais antiga** do Android em que seu app se instala. No Flutter 3.47 o valor gerado é
**24**, que corresponde ao Android 7.0. Esse número precisa bater com o `min_sdk_android` do
gerador de ícones.
**Exemplo:** `minSdk = flutter.minSdkVersion` em `android/app/build.gradle.kts`
**Aula:** [15.02 — Identidade do app](../modulos/15-build-android/02-identidade-do-app.md)

### mipmap 🤖
Pasta de recursos do Android reservada aos **ícones do lançador**. Existe uma por densidade de
tela. Ícones ficam em `mipmap/`; outras imagens ficam em `drawable/`.
**Exemplo:** `android:icon="@mipmap/ic_launcher"` no `AndroidManifest.xml`
**Aula:** [15.03 — Ícone](../modulos/15-build-android/03-icone.md)

### Mixin
Bloco de comportamento reutilizável que você "mistura" numa classe com `with`, sem herança.
Resolve o caso "quero esse pedaço de código em classes que não têm um ancestral comum".
**Exemplo:** `class _TelaState extends State<Tela> with SingleTickerProviderStateMixin { ... }`
**Aula:** [03.06 — Mixins](../modulos/03-dart-intermediario/06-mixins.md)

### Mock
Substituto de uma dependência, criado por biblioteca, que **registra** as chamadas recebidas e
devolve respostas programadas. Serve para testar sua classe sem rede, sem banco e sem espera.
**Exemplo:** `when(() => cliente.get(any())).thenAnswer((_) async => http.Response('[]', 200));`
**Aula:** [12.07 — Mocks e fakes](../modulos/12-testes-e-debug/07-mocks-e-fakes.md)

### mocktail
Pacote de mocks usado neste curso (`^1.0.5`). Foi escolhido porque **não exige geração de
código** (`build_runner`): você só escreve `class ClienteMock extends Mock implements
http.Client {}`.
⚠️ Para usar `any()` com tipos não primitivos é preciso registrar um valor de reserva em
`setUpAll` com `registerFallbackValue`.
**Exemplo:** `setUpAll(() => registerFallbackValue(UriFalsa()));`
**Aula:** [12.07 — Mocks e fakes](../modulos/12-testes-e-debug/07-mocks-e-fakes.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## N

### Namespace 🤖
Identificador do pacote Java/Kotlin usado internamente pelo build do Android para gerar a
classe `R` de recursos. No projeto gerado vale `com.example.<nome_do_projeto>` e normalmente
acompanha o `applicationId`.
**Exemplo:** `namespace = "br.com.estudos.foco"`
**Aula:** [15.02 — Identidade do app](../modulos/15-build-android/02-identidade-do-app.md)

### Navigator
Widget do Flutter que mantém a **pilha de telas**. `push` empilha uma tela nova em cima;
`pop` tira a de cima e volta. Entender que é uma pilha explica o botão voltar, o retorno de
valores e por que a tela anterior continua viva na memória.
**Exemplo:** `Navigator.pushNamed(context, '/sessao');`
**Aula:** [07.01 — Navigator, a pilha](../modulos/07-navegacao-e-formularios/01-navigator-a-pilha.md)

### Notifier
Classe base do Riverpod 3 para estado **síncrono** com métodos de alteração. Você escreve
`build()` devolvendo o estado inicial e métodos públicos que atribuem a `state`.
⚠️ No Riverpod 3, `FamilyNotifier` e `AutoDisposeNotifier` foram unificadas em `Notifier`.
**Exemplo:** `class ContadorNotifier extends Notifier<int> { @override int build() => 0; }`
**Aula:** [08.06 — Notifier e NotifierProvider](../modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md)

### NotifierProvider
Provider que expõe um `Notifier`. `ref.watch(p)` devolve o **estado**;
`ref.read(p.notifier)` devolve o **objeto** com os métodos.
**Exemplo:** `final contadorProvider = NotifierProvider<ContadorNotifier, int>(ContadorNotifier.new);`
**Aula:** [08.06 — Notifier e NotifierProvider](../modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md)

### Null safety
*"Segurança contra nulo".* Sistema do Dart em que um tipo **não aceita nulo** a menos que você
escreva `?`. O compilador passa a cobrar de você o tratamento do caso "não tem valor", em vez
de o app quebrar em tempo de execução.
**Exemplo:** `String nome;` nunca é nulo · `String? apelido;` pode ser
**Aula:** [02.05 — Null safety](../modulos/02-dart-basico/05-null-safety.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## O

### Objeto
Instância concreta de uma classe, com seus próprios valores nos campos. A classe é o molde; o
objeto é a peça fundida.
**Exemplo:** `final algebra = Materia(id: '1', nome: 'Álgebra');`
**Aula:** [03.01 — Classes e objetos](../modulos/03-dart-intermediario/01-classes-e-objetos.md)

### Ofuscação
Técnica que embaralha os nomes de classes e métodos no binário do release, para dificultar a
engenharia reversa. Não é criptografia e não protege segredo embutido no app — a única regra
segura continua sendo **não colocar segredo no app**.
**Exemplo:** o build de release oferece a opção de ofuscar e salvar o mapa de símbolos
**Aula:** [13.07 — Ofuscação e o que evitar](../modulos/13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md)

### Offline-first
Estratégia em que o app funciona **primeiro** com o dado local e trata a rede como um bônus.
Você lê do banco, mostra na hora, e sincroniza em segundo plano.
**Exemplo:** mostrar as trilhas já salvas e só então tentar atualizar pela API
**Aula:** [10.08 — Cache e offline](../modulos/10-persistencia-de-dados/08-cache-e-offline.md)

### onGenerateRoute
Função que você entrega ao `MaterialApp` para transformar um **nome de rota** em uma tela,
com direito a ler argumentos e tratar rota desconhecida. É o caminho escolhido neste curso
por não exigir nenhuma dependência externa.
**Exemplo:** `MaterialApp(onGenerateRoute: Rotas.gerar, initialRoute: '/')`
**Aula:** [07.02 — Rotas nomeadas](../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md)

### Operador
Símbolo que executa uma operação: `+`, `-`, `==`, `&&`, `??`, `?.`, `!`. Em Dart alguns deles
são específicos de null safety e valem estudo dedicado.
**Exemplo:** `final apelido = nome ?? 'sem nome';`
**Aula:** [01.06 — Operadores](../modulos/01-logica-e-fundamentos/06-operadores.md)

### Overflow
*"Transbordamento".* Situação em que um widget filho pede mais espaço do que o pai tem. O
Flutter desenha listras amarelas e pretas na borda e escreve no console quantos pixels
sobraram de fora.
**Exemplo:** `A RenderFlex overflowed by 42 pixels on the right.`
**Aula:** [06.04 — Row, Column e Expanded](../modulos/06-widgets-e-layouts/04-row-column-expanded.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## P

### Pacote
*Package.* Unidade distribuível de código Dart, publicada no pub.dev, com seu próprio
`pubspec.yaml`. Você o adiciona ao projeto e passa a poder importá-lo.
**Exemplo:** `flutter pub add http`
**Aula:** [03.10 — Arquivos, bibliotecas e pacotes](../modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)

### PATH
Variável de ambiente do sistema operacional com a lista de pastas onde ele procura programas
ao você digitar um nome no terminal. Se `flutter` "não é reconhecido", quase sempre é o PATH.
⚠️ No Windows, um PATH com acento ou espaço no caminho do SDK **quebra o Flutter**. Veja o
verbete **UTF-8** e a aula de ambiente.
**Exemplo:** `C:\src\flutter\bin` precisa estar no PATH
**Aula:** [02 — Configuração do ambiente](../02-configuracao-do-ambiente.md)

### Pattern (padrão)
Recurso do Dart 3 que permite **desestruturar** e comparar a forma de um valor dentro de um
`switch` ou de uma atribuição. Substitui cadeias longas de `if` com `is` e cast.
**Exemplo:** `final (nome, minutos) = ('Álgebra', 120);`
**Aula:** [04.05 — Patterns e switch](../modulos/04-dart-avancado/05-patterns-e-switch.md)

### Permissão
Autorização que o usuário concede para o app acessar câmera, galeria, localização,
notificações. 🤖 No Android é declarada no `AndroidManifest.xml` e pedida em tempo de execução;
🍎 no iOS é um **texto** no `Info.plist` explicando o motivo.
⚠️ A Apple rejeita o app se esse texto for genérico.
**Exemplo:** `<uses-permission android:name="android.permission.CAMERA"/>`
**Aula:** [11.01 — Permissões](../modulos/11-recursos-nativos/01-permissoes.md)

### Persistência
Capacidade de o dado **sobreviver** ao fechamento do app. Sem persistência, tudo o que o
usuário fez some quando o processo morre.
**Exemplo:** salvar as matérias no sqflite em vez de deixá-las numa lista em memória
**Aula:** [10.01 — Qual armazenamento usar](../modulos/10-persistencia-de-dados/01-qual-armazenamento-usar.md)

### Pilha (de navegação)
*Stack.* Estrutura "último a entrar, primeiro a sair". A tela mais recente fica no topo; o
botão voltar remove o topo. É exatamente o que o `Navigator` mantém.
**Exemplo:** `/` → `/materia/form` → voltar volta para `/`
**Aula:** [07.01 — Navigator, a pilha](../modulos/07-navegacao-e-formularios/01-navigator-a-pilha.md)

### Polimorfismo
*"Muitas formas".* Capacidade de tratar objetos de tipos diferentes pela mesma interface,
deixando cada um responder do seu jeito.
**Exemplo:** `List<Widget>` aceita `Text`, `Icon` e `Card` no mesmo lugar
**Aula:** [03.04 — Herança e polimorfismo](../modulos/03-dart-intermediario/04-heranca-e-polimorfismo.md)

### PopScope
Widget que intercepta a tentativa de sair da tela (botão voltar do Android, gesto de arrastar
do iOS) para você confirmar o descarte de um formulário, por exemplo.
⚠️ `WillPopScope` está obsoleto. Use `PopScope<T>` com `canPop:` e
`onPopInvokedWithResult: (bool didPop, T? resultado)`.
**Exemplo:** `PopScope(canPop: !temAlteracoes, onPopInvokedWithResult: (didPop, _) { ... })`
**Aula:** [11.08 — Botão voltar e gestos](../modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md)

### Profile (modo)
Modo de build intermediário: compila AOT como o release, mas mantém as ferramentas de medição
ligadas. É o **único** modo correto para medir desempenho.
**Exemplo:** usado ao investigar jank com o DevTools
**Aula:** [15.01 — Debug, profile e release](../modulos/15-build-android/01-debug-profile-release.md)

### Progressive Web App (PWA) 🌐
Um site que cumpre três requisitos — **HTTPS**, **`manifest.json` válido** e **service worker
com handler de `fetch`** — e por isso ganha do navegador o direito de ser instalado na tela
inicial, abrir sem barra de endereços e funcionar offline. Não há loja, aprovação nem selo: o
navegador confere sozinho. É o **canal principal de distribuição** deste curso.
**Exemplo:** `https://usuario.github.io/foco/` instalado na tela inicial
**Aula:** [14.01 — Por que PWA é o canal principal](../modulos/14-build-web-pwa/01-por-que-pwa.md)

### Provider (Riverpod)
Objeto que **descreve como criar** um valor e o entrega a quem pedir, mantendo cache e
descartando quando ninguém mais usa. Não confundir com o pacote `provider`, que é outra
biblioteca, do mesmo autor.
**Exemplo:** `final saudacaoProvider = Provider<String>((ref) => 'Olá, Flutter!');`
**Aula:** [08.05 — Riverpod: primeiros passos](../modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md)

### ProviderScope
Widget que guarda o **armazém** de todos os providers. Precisa envolver o app inteiro; sem ele,
qualquer `ref.watch` lança erro. Nos testes, `overrides:` troca uma dependência real por uma
falsa.
**Exemplo:** `void main() => runApp(const ProviderScope(child: MeuApp()));`
**Aula:** [08.05 — Riverpod: primeiros passos](../modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md)

### Provisioning profile 🍎
*"Perfil de provisionamento".* Arquivo que amarra três coisas: o Bundle ID do app, o
certificado do desenvolvedor e a lista de aparelhos autorizados. Sem ele, o iPhone recusa
instalar o app.
**Exemplo:** arquivos `.mobileprovision` — sempre no `.gitignore`
**Aula:** [16.07 — Certificados e provisioning](../modulos/16-build-ios/07-certificados-e-provisioning.md)

### pub / pub.dev
`pub` é o gerenciador de pacotes do Dart (você o usa por `flutter pub` / `dart pub`); pub.dev é
o site onde os pacotes são publicados, com nota de qualidade, popularidade e data da última
versão.
**Exemplo:** `flutter pub add flutter_riverpod`
**Aula:** [03.10 — Arquivos, bibliotecas e pacotes](../modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)

### pubspec.yaml
Arquivo de identidade do projeto: nome, descrição, versão, restrição de SDK, dependências e
assets. É escrito em YAML, onde **indentação é sintaxe**.
⚠️ `flutter_launcher_icons` e `flutter_native_splash` são blocos de **primeiro nível** —
alinhados com `dependencies:` e `flutter:`, nunca dentro de `flutter:`.
**Exemplo:** `version: 1.0.0+1`
**Aula:** [05.02 — Estrutura do projeto](../modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## Q

### Query (consulta)
Pedido de dados a um banco. No sqflite você pode usar a API tipada (`db.query('materias',
orderBy: ...)`) ou SQL cru (`db.rawQuery`).
⚠️ Nunca concatene valor do usuário direto no SQL: use `?` e a lista `whereArgs`.
**Exemplo:** `await db.query('materias', where: 'id = ?', whereArgs: [id]);`
**Aula:** [10.05 — sqflite: CRUD](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

### Query string
Parte do endereço HTTP depois do `?`, com pares `chave=valor` separados por `&`. Serve para
filtrar, paginar e buscar.
**Exemplo:** `https://jsonplaceholder.typicode.com/posts?userId=1`
**Aula:** [09.03 — Primeiro GET](../modulos/09-consumo-de-api/03-primeiro-get.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## R

### Rebuild
Nova chamada do método `build()` de um widget. É barato quando a árvore é pequena e o widget
tem `const`; fica caro quando você reconstrói a tela inteira para mudar um texto.
**Exemplo:** `setState(() => _segundos++)` provoca um rebuild daquele `State`
**Aula:** [13.01 — Rebuilds, const e keys](../modulos/13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md)

### Record
Tipo do Dart 3 para agrupar alguns valores **sem criar uma classe**. Leve, imutável, com
igualdade por valor. Ótimo para retornar duas coisas de uma função.
**Exemplo:** `(int total, int media) resumo() => (300, 25);`
**Aula:** [04.04 — Records](../modulos/04-dart-avancado/04-records.md)

### ref (Riverpod)
Objeto por onde você conversa com o armazém de providers: `ref.watch` (observa e reconstrói),
`ref.read` (lê uma vez, para ações), `ref.listen` (reage sem reconstruir).
⚠️ No Riverpod 3, `Ref` **não é genérico**: escreva `Ref`, nunca `Ref<int>`. E depois de um
`await` dentro de um `Notifier`, cheque `ref.mounted`.
**Exemplo:** `final total = ref.watch(totalMinutosProvider);`
**Aula:** [08.05 — Riverpod: primeiros passos](../modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md)

### Release (modo)
Modo de build final: compilação AOT, sem ferramentas de depuração, otimizado e menor. É o que
vai para as lojas — e é o único que precisa de assinatura própria.
⚠️ O `flutter create` deixa o `buildTypes.release` assinado com a **chave de debug** e um
comentário `TODO`. Enquanto esse trecho estiver lá, o arquivo **não pode** ser publicado.
**Exemplo:** `flutter build appbundle`
**Aula:** [15.01 — Debug, profile e release](../modulos/15-build-android/01-debug-profile-release.md)

### RenderObject
Objeto da camada de renderização do Flutter. É ele que efetivamente mede, posiciona e pinta.
Widget descreve, Element conecta, RenderObject desenha. Esses são os **três** troncos paralelos
do Flutter.
**Exemplo:** um `Padding` cria um `RenderPadding` que aplica a margem ao medir o filho
**Aula:** [05.03 — main, runApp e a árvore de widgets](../modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md)

### Repositório (Git)
Pasta do projeto acompanhada de todo o histórico de versões, guardado na subpasta oculta
`.git`.
**Exemplo:** `git init` transforma uma pasta comum em repositório
**Aula:** [00.03 — Git: o que é](../modulos/00-git-e-terminal/03-git-o-que-e.md)

### Repositório (padrão de projeto)
Classe que esconde **de onde** o dado vem: pode ser da API, do sqflite ou do cache. A tela pede
"me dá as trilhas" e não precisa saber o resto.
**Exemplo:** `class TrilhaRepositorio { TrilhaRepositorio(this._api); }`
**Aula:** [09.07 — Camada de dados testável](../modulos/09-consumo-de-api/07-camada-de-dados-testavel.md)

### REST
*Representational State Transfer — "transferência de estado representacional".* Estilo de API
web em que cada recurso tem um endereço e o método HTTP diz o que fazer com ele: `GET` lê,
`POST` cria, `PUT`/`PATCH` alteram, `DELETE` remove.
**Exemplo:** `DELETE /posts/1`
**Aula:** [09.01 — HTTP e REST](../modulos/09-consumo-de-api/01-http-e-rest.md)

### Responsividade
Capacidade do layout de se adaptar a larguras diferentes: celular em pé, celular deitado,
tablet, janela redimensionada. Usa `LayoutBuilder`, `MediaQuery` e listas que quebram em
colunas.
**Exemplo:** mostrar uma coluna abaixo de 600 pixels de largura e duas acima
**Aula:** [06.11 — Responsividade](../modulos/06-widgets-e-layouts/11-responsividade.md)

### Riverpod
Biblioteca de gerenciamento de estado e injeção de dependências usada neste curso, na versão
**3.4.3**, **sem geração de código**. Foi escolhida porque `AsyncValue` já modela
carregando/erro/dados, porque não precisa de `BuildContext` para ler estado e porque é
testável fora da árvore de widgets.
⚠️ `StateProvider`, `StateNotifierProvider` e `ChangeNotifierProvider` foram movidos para
`package:riverpod/legacy.dart` e **não são ensinados** aqui.
**Exemplo:** `final contadorProvider = NotifierProvider<ContadorNotifier, int>(ContadorNotifier.new);`
**Aula:** [08.04 — Por que Riverpod](../modulos/08-estado-e-arquitetura/04-por-que-riverpod.md)

### Rota nomeada
Tela identificada por um texto curto, estilo caminho de URL, em vez de pela classe. Centraliza
a navegação num lugar só e evita importar telas umas nas outras.
**Exemplo:** `'/materia/form'`
**Aula:** [07.02 — Rotas nomeadas](../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## S

### Scaffold
*"Andaime".* Widget que fornece a estrutura visual básica de uma tela Material: barra superior,
corpo, botão flutuante, barra inferior e o lugar onde as `SnackBar` aparecem.
**Exemplo:** `Scaffold(appBar: AppBar(title: const Text('Foco')), body: corpo)`
**Aula:** [06.01 — Scaffold e AppBar](../modulos/06-widgets-e-layouts/01-scaffold-e-appbar.md)

### ScaffoldMessenger
Objeto responsável por exibir `SnackBar`. Existe porque a mensagem precisa sobreviver à troca
de tela.
⚠️ Use `ScaffoldMessenger.of(context).showSnackBar(...)` — `Scaffold.of(context).showSnackBar`
está obsoleto.
**Exemplo:** `ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvo')));`
**Aula:** [06.10 — Gestos e feedback](../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md)

### SceneDelegate 🍎
Arquivo Swift gerado pelo `flutter create` do Flutter 3.47 (`ios/Runner/SceneDelegate.swift`),
acompanhado do bloco `UIApplicationSceneManifest` no `Info.plist`. Faz parte do modelo moderno
de janelas do iOS. **Não remova.**
**Exemplo:** `UISceneDelegateClassName` = `$(PRODUCT_MODULE_NAME).SceneDelegate`
**Aula:** [16.04 — Bundle ID e Xcode](../modulos/16-build-ios/04-bundle-id-e-xcode.md)

### Sealed class
*"Classe selada".* Classe cujas subclasses são **todas** conhecidas e ficam no mesmo arquivo.
Isso permite ao compilador verificar que o seu `switch` cobriu todos os casos — se você
esquecer um, ele avisa antes de rodar.
**Exemplo:** `sealed class Resultado {}` com `Sucesso` e `Erro` no mesmo arquivo
**Aula:** [04.06 — Sealed classes](../modulos/04-dart-avancado/06-sealed-classes.md)

### SDK
*Software Development Kit — "kit de desenvolvimento de software".* Pacote de ferramentas,
bibliotecas e comandos para programar numa tecnologia. Aqui há três em jogo: o Flutter SDK, o
Dart SDK (embutido) e o Android SDK.
⚠️ O caminho do Flutter SDK **não pode ter acento nem espaço** no Windows. Use `C:\src\flutter`.
**Exemplo:** `C:\src\flutter\bin\flutter`
**Aula:** [02 — Configuração do ambiente](../02-configuracao-do-ambiente.md)

### Scope (manifest) 🌐
O campo do `manifest.json` que define **até onde** o app se considera ele mesmo. Navegar para
fora do escopo faz o app instalado exibir uma **barra de navegador**. Precisa ser igual ao
`--base-href` do build — divergir não quebra o build nem o deploy, só a experiência instalada.
**Exemplo:** `"scope": "/foco/"`
**Aula:** [14.05 — Manifest e ícones](../modulos/14-build-web-pwa/05-manifest-e-icones.md)

### Service worker 🌐
Script que roda **fora da página**, sobrevive ao fechamento da aba e intercepta **toda
requisição** antes de ela ir à rede. É o que permite um app web abrir offline — e o que faz o
usuário ver a versão antiga na primeira abertura após um deploy, porque ele serve o cache e
baixa a versão nova em paralelo.
**Exemplo:** `build/web/flutter_service_worker.js`
**Aula:** [14.06 — Service worker e offline](../modulos/14-build-web-pwa/06-service-worker-e-offline.md)

### Semântica (Semantics)
Camada de informação que o Flutter oferece aos leitores de tela: o que aquele elemento é, como
se chama e o que acontece ao tocá-lo. Um ícone sem rótulo semântico é invisível para quem usa
TalkBack ou VoiceOver.
**Exemplo:** `Semantics(button: true, label: 'Pausar sessão', child: icone)`
**Aula:** [13.05 — Acessibilidade](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

### Semver
*Semantic Versioning — "versionamento semântico".* Convenção `MAIOR.MENOR.CORREÇÃO`: muda o
primeiro número quando quebra compatibilidade, o segundo quando acrescenta algo compatível, o
terceiro quando só corrige. O acento circunflexo (`^1.6.0`) significa "de 1.6.0 até antes de
2.0.0".
**Exemplo:** `http: ^1.6.0`
**Aula:** [03.10 — Arquivos, bibliotecas e pacotes](../modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)

### Serialização
Conversão de um objeto Dart em algo transportável (texto JSON, linha de tabela) e o caminho de
volta (desserialização). Na prática são dois métodos: `toMap()`/`toJson()` e `fromMap()`.
**Exemplo:** `Materia.fromMap(linha)` transforma a linha do sqflite em objeto
**Aula:** [09.02 — JSON](../modulos/09-consumo-de-api/02-json.md)

### Set
Coleção **sem repetições** e sem ordem garantida. Ótima para perguntar "esse item já está
aqui?" de forma rápida.
**Exemplo:** `final etiquetas = <String>{'prova', 'revisão'};`
**Aula:** [02.09 — Sets e Maps](../modulos/02-dart-basico/09-sets-e-maps.md)

### setState
Método do `State` que avisa o Flutter: "meus dados mudaram, redesenhe este widget". É o
mecanismo de estado mais simples que existe e o ponto de partida antes do Riverpod.
⚠️ Depois de um `await`, confira `if (!mounted) return;` antes de chamar `setState`.
**Exemplo:** `setState(() => _segundos++);`
**Aula:** [05.05 — StatefulWidget e setState](../modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md)

### shared_preferences
Pacote (`^2.5.5`) que guarda pares chave→valor simples no armazenamento do sistema. Perfeito
para preferência do usuário e configuração pequena.
⚠️ **Não é seguro** — não guarde token nem senha ali; para isso existe `flutter_secure_storage`.
**Exemplo:** `await prefs.setInt('metaSemanalMinutos', 600);`
**Aula:** [10.02 — shared_preferences](../modulos/10-persistencia-de-dados/02-shared-preferences.md)

### Simulador 🍎
iPhone virtual do macOS. Diferente do emulador Android, ele **não emula** o processador: roda
código compilado para o Mac. Por isso é rápido — e por isso alguns bugs só aparecem no
aparelho de verdade.
> 🍎 **SÓ NO MAC.** O simulador iOS não existe para Windows.
**Exemplo:** aparece em `flutter devices` quando o Xcode está instalado no Mac
**Aula:** [16.03 — Simulador e iPhone físico](../modulos/16-build-ios/03-simulador-e-iphone-fisico.md)

### Sliver
*"Lasca", "fatia".* Pedaço rolável de baixo nível. `CustomScrollView` combina slivers para
fazer coisas que uma `ListView` sozinha não faz: barra que encolhe ao rolar, cabeçalho grudento,
grade e lista no mesmo rolar.
**Exemplo:** `CustomScrollView(slivers: [SliverAppBar(...), SliverList(...)])`
**Aula:** [06.09 — Listas e rolagem](../modulos/06-widgets-e-layouts/09-listas-e-rolagem.md)

### SnackBar
Mensagem curta que sobe do rodapé da tela, some sozinha e pode ter um botão de ação
("Desfazer"). É o retorno padrão do Material para confirmar que algo aconteceu.
**Exemplo:** `const SnackBar(content: Text('Matéria salva'))`
**Aula:** [06.10 — Gestos e feedback](../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md)

### SocketException
Exceção lançada quando o app **não consegue sequer alcançar** o servidor: sem internet, DNS
falhando, endereço errado, servidor fora do ar.
**Exemplo:** `on SocketException { throw Falha('Sem conexão com a internet'); }`
**Aula:** [09.04 — Modelando respostas e erros](../modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md)

### Splash screen
Tela mostrada no instante entre tocar no ícone e o app estar pronto. 🤖 No Android vem de
`launch_background.xml` (e de `values-v31/styles.xml` no Android 12+, que mudou de mecanismo e
só mostra o ícone centralizado). 🍎 No iOS vem de `LaunchScreen.storyboard`.
**Exemplo:** `dart run flutter_native_splash:create`
**Aula:** [15.04 — Splash screen](../modulos/15-build-android/04-splash-screen.md)

### SQL
*Structured Query Language — "linguagem estruturada de consulta".* Idioma dos bancos
relacionais: `CREATE TABLE`, `INSERT`, `SELECT`, `UPDATE`, `DELETE`, `ALTER TABLE`.
**Exemplo:** `SELECT nome, minutos FROM materias ORDER BY nome_ordenacao ASC`
**Aula:** [10.04 — sqflite: criando o banco](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md)

### sqflite
Pacote (`^2.4.4`) que dá acesso ao SQLite no Android e no iOS. É a escolha do curso para dado
**estruturado** — muitas linhas, com relação e consulta.
⚠️ O SQLite compara texto byte a byte: `ORDER BY nome` devolve **Física antes de Álgebra**.
A solução ensinada é uma coluna `nome_ordenacao` sem acentos.
**Exemplo:** `await db.query('materias', orderBy: 'nome_ordenacao ASC');`
**Aula:** [10.04 — sqflite: criando o banco](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md)

### sqflite_common_ffi
Pacote de desenvolvimento (`^2.4.3`) que faz o sqflite rodar em **desktop**. Graças a ele você
testa toda a camada de banco no Windows, sem emulador e sem celular.
**Exemplo:** `sqfliteFfiInit(); databaseFactory = databaseFactoryFfi;`
**Aula:** [12.05 — Testes unitários](../modulos/12-testes-e-debug/05-testes-unitarios.md)

### Stack trace
*"Rastro de pilha".* Lista das chamadas de função que estavam abertas no momento do erro, da
mais recente para a mais antiga. É o mapa que leva você até a linha culpada — a primeira linha
que cita **um arquivo seu** costuma ser a mais importante.
**Exemplo:** `#0 MateriaDao.inserir (package:foco/features/materias/data/materia_dao.dart:42)`
**Aula:** [12.01 — Lendo stack traces](../modulos/12-testes-e-debug/01-lendo-stack-traces.md)

### Staging area
*"Área de preparação".* Zona intermediária do Git entre o que você editou e o commit. Você
escolhe com `git add` o que entra no próximo commit — isso permite commits pequenos e com
sentido.
**Exemplo:** `git add lib/features/materias/`
**Aula:** [00.04 — Commits, branches e .gitignore](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

### StatefulWidget
Widget que guarda dados que mudam ao longo do tempo. Ele é imutável; quem guarda o estado é o
objeto `State` associado, que sobrevive às reconstruções.
**Exemplo:** `class Cronometro extends StatefulWidget { const Cronometro({super.key}); }`
**Aula:** [05.05 — StatefulWidget e setState](../modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md)

### StatelessWidget
Widget sem estado interno: dados entram pelo construtor e a aparência é função só deles. É o
tipo que você deve usar por padrão; só troque para `StatefulWidget` quando precisar guardar
algo que muda.
**Exemplo:** `class MateriaTile extends StatelessWidget { const MateriaTile({super.key}); }`
**Aula:** [05.04 — StatelessWidget](../modulos/05-introducao-ao-flutter/04-statelesswidget.md)

### Status code
Número de três dígitos na resposta HTTP. `2xx` deu certo (200 OK, 201 criado), `3xx`
redirecionou, `4xx` foi erro do cliente (400 pedido inválido, 401 sem autenticação, 404 não
encontrado), `5xx` foi erro do servidor.
**Exemplo:** `if (resposta.statusCode != 200) { throw Falha('Servidor respondeu ${resposta.statusCode}'); }`
**Aula:** [09.01 — HTTP e REST](../modulos/09-consumo-de-api/01-http-e-rest.md)

### Stream
*"Fluxo", "riacho".* Sequência de valores entregues **ao longo do tempo**, um após o outro. Se
o `Future` é um pacote que chega uma vez, o `Stream` é uma esteira. Usado para cronômetro,
conectividade e eventos.
**Exemplo:** `Stream.periodic(const Duration(seconds: 1), (n) => n)`
**Aula:** [04.03 — Streams](../modulos/04-dart-avancado/03-streams.md)

### String
Tipo que representa texto. Em Dart aceita interpolação com `$` e `${}`, aspas simples ou
duplas, e três aspas para texto de várias linhas.
**Exemplo:** `'Você estudou $minutos minutos'`
**Aula:** [02.04 — Tipos, strings e conversões](../modulos/02-dart-basico/04-tipos-strings-conversoes.md)

### Swift Package Manager (SPM) 🍎
Gerenciador de dependências nativo da Apple. **É o padrão do Flutter desde a versão 3.44** — o
`flutter create` já gera `ios/Flutter/ephemeral/Packages`. Se algum plugin do projeto ainda não
o suportar, o Flutter volta automaticamente para o CocoaPods; os dois convivem.
**Exemplo:** `flutter config --enable-swift-package-manager`
**Aula:** [16.02 — Xcode e CocoaPods](../modulos/16-build-ios/02-xcode-e-cocoapods.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## T

### targetSdk 🤖
Versão do Android para a qual você declara ter testado o app. O sistema usa esse número para
decidir quais mudanças de comportamento aplicar. No Flutter 3.47 o valor gerado é **36**. A
Google Play exige um `targetSdk` recente para aceitar envios.
**Exemplo:** `targetSdk = flutter.targetSdkVersion`
**Aula:** [15.02 — Identidade do app](../modulos/15-build-android/02-identidade-do-app.md)

### Tema (ThemeData)
Conjunto de cores, tipografia e formas aplicado a toda a árvore. Definir o tema uma vez evita
espalhar cor fixa por cinquenta widgets e é o que faz o modo escuro funcionar.
**Exemplo:** `MaterialApp(theme: TemaApp.claro, darkTheme: TemaApp.escuro)`
**Aula:** [06.07 — Cores, temas e modo escuro](../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md)

### Terminal
Janela onde você digita comandos em texto. 🪟 No Windows deste curso usamos o **PowerShell**.
🖥️🐧 No macOS e no Linux, `bash` ou `zsh`. A sintaxe muda entre eles — por isso o curso rotula
os blocos.
**Exemplo:** `flutter --version`
**Aula:** [00.01 — O terminal sem medo](../modulos/00-git-e-terminal/01-o-terminal-sem-medo.md)

### Teste de integração
Teste que roda o app **inteiro**, em aparelho ou emulador, simulando o usuário de ponta a
ponta. É o mais lento e o mais realista. Usa o pacote `integration_test` do SDK.
**Exemplo:** abrir o app, criar uma matéria, iniciar uma sessão e conferir as estatísticas
**Aula:** [12.08 — Testes de integração](../modulos/12-testes-e-debug/08-testes-de-integracao.md)

### Teste de widget
Teste que monta um pedaço de interface numa árvore de mentira, sem aparelho, e verifica o que
apareceu na tela. Roda em segundos.
⚠️ Se o widget usa `Future.delayed`, finalize com `await tester.pump(const Duration(milliseconds: 50));`
ou `await tester.pumpAndSettle();`, senão o teste falha com "A Timer is still pending".
**Exemplo:** `expect(find.text('Nenhuma matéria ainda'), findsOneWidget);`
**Aula:** [12.06 — Testes de widget](../modulos/12-testes-e-debug/06-testes-de-widget.md)

### Teste unitário
Teste de uma unidade isolada de código — uma função, uma classe — sem interface e sem
dependência externa real. É o mais rápido e o que você deve ter em maior quantidade.
**Exemplo:** `test('copyWith troca só o campo informado', () { ... });`
**Aula:** [12.05 — Testes unitários](../modulos/12-testes-e-debug/05-testes-unitarios.md)

### TestFlight 🍎
Serviço da Apple para distribuir versões de teste a convidados antes da publicação na App
Store. O build enviado ao App Store Connect aparece lá.
> 🍎 **SÓ NO MAC.** Enviar um build exige um `.ipa`, que exige macOS + Xcode.
**Exemplo:** até 100 testadores internos por app
**Aula:** [16.09 — Exportando IPA e TestFlight](../modulos/16-build-ios/09-exportando-ipa-e-testflight.md)

### Timeout
*"Tempo esgotado".* Limite de espera por uma resposta. Sem ele, uma rede ruim deixa a tela
girando para sempre. Neste curso toda chamada HTTP leva `.timeout(Duration(seconds: 15))`.
**Exemplo:** `await http.get(uri).timeout(const Duration(seconds: 15));`
**Aula:** [09.06 — Timeout, retry e cancelamento](../modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md)

### TimeoutException
Exceção lançada quando o `.timeout(...)` estoura. Trate-a separadamente de `SocketException`:
a mensagem para o usuário é diferente ("o servidor demorou demais" ≠ "você está sem internet").
**Exemplo:** `on TimeoutException { throw Falha('O servidor demorou para responder'); }`
**Aula:** [09.06 — Timeout, retry e cancelamento](../modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md)

### Tipagem estática
Sistema em que o tipo de cada variável é conhecido **antes** de o programa rodar, e o
compilador recusa operações impossíveis. Dart é estaticamente tipado; Python, não.
**Exemplo:** `int minutos = 'vinte';` nem compila
**Aula:** [02.04 — Tipos, strings e conversões](../modulos/02-dart-basico/04-tipos-strings-conversoes.md)

### Token
Texto que funciona como crachá temporário de acesso a uma API. Deve ser guardado em
armazenamento seguro, nunca em `shared_preferences` e **jamais escrito no código-fonte**.
**Exemplo:** nos exemplos do curso, sempre `SEU_TOKEN_AQUI`
**Aula:** [09.08 — Autenticação e tokens](../modulos/09-consumo-de-api/08-autenticacao-e-tokens.md)

### Transação (banco de dados)
Conjunto de operações que acontece **tudo ou nada**. Se der erro no meio, o banco desfaz tudo.
No sqflite, `transaction` e `batch` fazem esse papel.
**Exemplo:** `await db.transaction((txn) async { ... });`
**Aula:** [10.05 — sqflite: CRUD](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## U

### Upsert
Junção de *update* e *insert*: grava o registro; se já existir um com a mesma chave,
substitui. No sqflite é `ConflictAlgorithm.replace`.
**Exemplo:** `await db.insert('materias', dados, conflictAlgorithm: ConflictAlgorithm.replace);`
**Aula:** [10.05 — sqflite: CRUD](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

### UTF-8
*Unicode Transformation Format, 8 bits.* Forma de representar qualquer caractere do mundo em
bytes. Letras sem acento ocupam 1 byte; `á`, `ç`, `ã` ocupam 2.
⚠️ É exatamente por isso que duas coisas quebram neste curso: (1) um caminho de SDK com acento
derruba ferramentas que não tratam UTF-8; (2) o SQLite ordena byte a byte e coloca `Física`
antes de `Álgebra`.
**Exemplo:** `F` = `0x46`; `Á` = `0xC3 0x81` — logo `'Física' < 'Álgebra'` para o SQLite
**Aula:** [00.02 — Arquivos e caminhos](../modulos/00-git-e-terminal/02-arquivos-e-caminhos.md)

### UUID
*Universally Unique Identifier — "identificador universalmente único".* Texto de 36 caracteres
gerado de forma que a chance de repetir é desprezível. Serve como chave primária criada no
próprio app, sem depender do servidor.
**Exemplo:** `final id = const Uuid().v4();`
**Aula:** [10.05 — sqflite: CRUD](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## V

### Validação (de formulário)
Checagem do que o usuário digitou **antes** de salvar. Em Flutter cada campo tem um `validator`
que devolve `null` quando está tudo certo ou uma mensagem de erro quando não está.
**Exemplo:** `validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null`
**Aula:** [07.07 — Validação, foco e teclado](../modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md)

### Variável
Nome dado a um espaço de memória que guarda um valor. Em Dart, `var` deixa o compilador
deduzir o tipo, `final` impede nova atribuição e `const` exige valor conhecido na compilação.
**Exemplo:** `final minutosEstudados = 25;`
**Aula:** [01.04 — Variáveis e constantes](../modulos/01-logica-e-fundamentos/04-variaveis-e-constantes.md)

### versionCode / versionName 🤖
`versionName` é a versão que o usuário vê (`1.0.0`); `versionCode` é o número inteiro que a
loja usa para saber o que é mais novo (`1`). Os dois vêm do **mesmo** campo do
`pubspec.yaml`: `version: 1.0.0+1`.
🍎 No iOS os equivalentes são `CFBundleShortVersionString` e `CFBundleVersion`.
**Exemplo:** `version: 1.0.0+1`
**Aula:** [15.02 — Identidade do app](../modulos/15-build-android/02-identidade-do-app.md)

### Viewport
*"Janela de visão".* A parte visível de um conteúdo rolável. A lista pode ter mil itens; o
viewport mostra sete. Compreender isso é o que explica por que `ListView` dentro de `Column`
sem altura definida dá erro.
**Exemplo:** envolver a lista em `Expanded` dá ao viewport uma altura concreta
**Aula:** [06.09 — Listas e rolagem](../modulos/06-widgets-e-layouts/09-listas-e-rolagem.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## W

### WebAssembly (WASM) 🌐
Formato binário que o navegador executa perto da velocidade nativa. No Flutter web ele aparece
em três lugares: o **CanvasKit** (o motor gráfico), o **SQLite** do banco na web, e — quando
você compila com `--wasm` — o seu próprio código Dart.
**Exemplo:** `flutter build web --release --wasm`
**Aula:** [14.02 — Como o Flutter compila para web](../modulos/14-build-web-pwa/02-como-o-flutter-compila-para-web.md)

### Widget
Peça de construção da interface no Flutter — e **tudo** é widget: texto, botão, margem, cor,
alinhamento, a tela inteira. Um widget é uma **descrição imutável e barata** do que deve
aparecer; o Flutter compara descrições e redesenha só o que mudou.
**Exemplo:** `const Text('Foco')`
**Aula:** [05.03 — main, runApp e a árvore de widgets](../modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md)

### WidgetStateProperty
Objeto que define um valor **diferente para cada estado** do componente: normal, pressionado,
com foco, desabilitado.
⚠️ Substituiu `MaterialStateProperty`, que está obsoleto. Se um tutorial usar o nome antigo,
ele está desatualizado.
**Exemplo:** `WidgetStateProperty.resolveWith((estados) => ...)`
**Aula:** [06.07 — Cores, temas e modo escuro](../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md)

### Workspace (Xcode) 🍎
Arquivo `.xcworkspace` que reúne o projeto do app e as dependências nativas.
⚠️ **Sempre abra `ios/Runner.xcworkspace`, nunca `ios/Runner.xcodeproj`** — abrir o `.xcodeproj`
faz o build falhar por não enxergar as dependências.
**Exemplo:** `open ios/Runner.xcworkspace`
**Aula:** [16.02 — Xcode e CocoaPods](../modulos/16-build-ios/02-xcode-e-cocoapods.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## X

### xcarchive (Archive) 🍎
Pacote intermediário produzido antes do IPA: contém o app compilado mais os símbolos de
depuração. É a partir dele que você exporta o `.ipa` para TestFlight ou App Store.
> 🍎 **SÓ NO MAC.**
**Exemplo:** `build/ios/archive/Runner.xcarchive`
**Aula:** [16.08 — Build IPA e archive](../modulos/16-build-ios/08-build-ipa-e-archive.md)

### Xcode 🍎
IDE oficial da Apple, disponível **apenas para macOS**. É ela que compila, assina e envia apps
iOS. Sem Mac, não há Xcode; sem Xcode, não há IPA.
> 🍎 **SÓ NO MAC.** No Windows você estuda todo o processo em
> [16.01 — Por que exige macOS](../modulos/16-build-ios/01-por-que-exige-macos.md), mas não o executa.
**Exemplo:** `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
**Aula:** [16.02 — Xcode e CocoaPods](../modulos/16-build-ios/02-xcode-e-cocoapods.md)

### XML
*eXtensible Markup Language — "linguagem de marcação extensível".* Formato de texto com marcas
entre `<` e `>`. 🤖 O Android o usa para manifesto, ícones adaptativos, cores e estilos.
**Exemplo:** `<uses-permission android:name="android.permission.INTERNET"/>`
**Aula:** [15.05 — Permissões Android](../modulos/15-build-android/05-permissoes-android.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## Y

### YAML
*YAML Ain't Markup Language.* Formato de configuração baseado em **indentação**: o recuo define
a hierarquia. Usado em `pubspec.yaml` e `analysis_options.yaml`.
⚠️ Tabulação é proibida; use espaços. Um espaço a mais ou a menos muda o significado — é o erro
número 1 ao configurar ícone e splash.
**Exemplo:** `flutter_launcher_icons:` alinhado à esquerda, no mesmo nível de `dependencies:`
**Aula:** [05.02 — Estrutura do projeto](../modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## Z

### Zona de toque (touch target)
Área mínima que um elemento tocável deve ter para ser confortável ao dedo: cerca de 48×48
pixels lógicos no Android e 44×44 pontos no iOS. Ícone pequeno demais reprova em revisão de
acessibilidade.
**Exemplo:** `IconButton` já reserva 48×48 por padrão, mesmo com um ícone de 24
**Aula:** [13.05 — Acessibilidade](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

⬆️ [Voltar ao índice](#-índice-de-letras)

---

## 🧭 Para onde ir agora

| Você quer... | Vá para |
|---|---|
| Ver o comando exato de alguma coisa | [Comandos úteis](comandos-uteis.md) |
| Entender uma mensagem de erro | [Erros comuns](erros-comuns.md) |
| Comparar Android e iOS lado a lado | [Diferenças Android × iOS](diferencas-android-ios.md) |
| Ir à documentação oficial | [Referências oficiais](referencias-oficiais.md) |
| Saber por que o curso escolheu cada tecnologia | [05-decisoes-tecnicas.md](../05-decisoes-tecnicas.md) |
| Montar ou consertar o ambiente | [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md) |
| Continuar estudando depois do curso | [Próximos passos](proximos-passos.md) |

---

⬅️ [Voltar ao índice do curso](../README.md)
