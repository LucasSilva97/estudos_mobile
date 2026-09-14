# Curso Flutter Intensivo — do zero ao app publicável

> **Comece por [00-como-usar-o-curso.md](00-como-usar-o-curso.md).**
> Não pule esse arquivo. Ele explica a ordem de leitura, como usar exercícios, gabaritos e
> avaliações, e a convenção de emojis usada em todos os 17 módulos.

---

## 📌 O que é este curso

Este é um curso **intensivo, escrito e prático** de desenvolvimento mobile com **Flutter**
(*framework* — conjunto de bibliotecas e ferramentas prontas que você usa como base para
construir um programa) e **Dart** (a linguagem de programação que o Flutter usa).

O curso leva você de "nunca fiz nada de mobile" até **gerar, assinar e instalar um aplicativo
de verdade** no Android, e até **entender e executar todo o processo do iOS** quando tiver
acesso a um Mac.

Características:

| Característica | Como é neste curso |
|---|---|
| Formato | Arquivos Markdown (`.md`) lidos no VS Code ou no navegador |
| Idioma | Português do Brasil |
| Pré-requisito de programação | Dart básico de terminal (`print`, variáveis, interpolação) |
| Pré-requisito de mobile | **Nenhum** |
| Carga total | 120 horas |
| Ritmo ativo | 15 dias · 8 h/dia, com 4 h aplicadas ao trabalho e 4 h intermitentes (ver [01-plano-intensivo.md](01-plano-intensivo.md)) |
| Módulos | 17 (de `00` a `16`) |
| Aulas | 148 aulas em formato fixo |
| Projetos práticos | 3 (iniciante, intermediário, final) |
| Listas de exercícios | 17 módulos + README |
| Gabaritos | 1 por lista + 3 de desafios de projeto |
| Avaliações | 17 por módulo + 5 cumulativas + 1 final |
| Plataforma-alvo | 🤖 Android (executável aqui) e 🍎 iOS (processo completo, execução exige Mac) |

Cada termo técnico é explicado **na primeira vez que aparece**. Nada é deixado como
"você já deve saber".

---

## 👤 Para quem é este curso

Este curso foi escrito para você se:

- Você **não sabe nada de desenvolvimento mobile** e quer aprender do começo.
- Você já escreveu algum código simples (Dart no terminal, ou um pouco de Python/Java) e
  entende o que é uma variável e um `if`.
- Você usa **Windows 11** e **não tem um Mac**, mas quer aprender o caminho do iOS mesmo assim.
- Você quer **entender**, não copiar e colar. O curso explica cada linha não óbvia.
- Você tem pressa e consegue reservar 8 horas por dia durante 15 dias, aplicando 4 horas em demandas reais do trabalho e distribuindo as outras 4 horas ao longo do dia.

Este curso **não** é para você se procura um tutorial de 20 minutos, ou se quer apenas
receber código pronto sem explicação.

---

## 🏁 O que você vai conseguir fazer ao final

Ao terminar os 17 módulos e os 3 projetos, você será capaz de:

| Entrega | O que é | Onde você aprende |
|---|---|---|
| **APK instalável** | Arquivo `.apk` (*Android Package* — o instalador de um app Android) que você copia para um celular Android e instala | [modulos/14-build-android/08-gerando-apk-e-aab.md](modulos/14-build-android/08-gerando-apk-e-aab.md) |
| **AAB para a Google Play** | Arquivo `.aab` (*Android App Bundle* — formato que a Google Play exige para publicação) | [modulos/14-build-android/08-gerando-apk-e-aab.md](modulos/14-build-android/08-gerando-apk-e-aab.md) |
| **Keystore de assinatura** | Arquivo `.jks` com a chave criptográfica que prova que o app é seu | [modulos/14-build-android/06-keystore.md](modulos/14-build-android/06-keystore.md) |
| **Build iOS assinado** | Projeto iOS com *Bundle Identifier*, certificado e *provisioning profile* configurados | [modulos/15-build-ios/07-certificados-e-provisioning.md](modulos/15-build-ios/07-certificados-e-provisioning.md) |
| **IPA (quando houver Mac)** | Arquivo `.ipa` (*iOS App Store Package* — o instalador de um app iOS) | [modulos/15-build-ios/08-build-ipa-e-archive.md](modulos/15-build-ios/08-build-ipa-e-archive.md) |
| **Versão no TestFlight** | App distribuído para testadores pela Apple | [modulos/15-build-ios/09-exportando-ipa-e-testflight.md](modulos/15-build-ios/09-exportando-ipa-e-testflight.md) |
| **App completo "Foco"** | Organizador de estudos com banco local, API, estado e testes | [projetos/03-projeto-final-multiplataforma/README.md](projetos/03-projeto-final-multiplataforma/README.md) |

E, no caminho, você vai dominar: Dart moderno (*null safety*, `async`/`await`, `sealed class`,
*records*, *patterns*), widgets e layouts do Flutter, navegação, formulários, gerenciamento de
estado com Riverpod, consumo de API REST, persistência com `sqflite` e `shared_preferences`,
recursos nativos (câmera, permissões, conectividade), testes automatizados, desempenho,
acessibilidade e segurança.

---

## ⚠️ Aviso honesto sobre iOS

> 🍎 **Gerar um `.ipa` exige macOS.** Isso não é uma limitação do curso: é uma regra da Apple.
> As ferramentas de compilação do iOS (Xcode, `xcodebuild`, `codesign`) só existem para macOS.
> **Não existe forma oficial e legal de gerar um IPA no Windows.**

O que este curso faz a respeito:

| Situação | O que o curso entrega |
|---|---|
| Você está no Windows (seu caso hoje) | Você **lê, entende e prepara** todo o processo iOS: estrutura da pasta `ios/`, `Info.plist`, Bundle Identifier, ícones, certificados, *provisioning profiles*, TestFlight. Você deixa o projeto pronto. |
| Você consegue um Mac emprestado / alugado na nuvem | Você executa o módulo 15 do início ao fim em poucas horas, porque já entendeu tudo |
| Você nunca terá um Mac | Você ainda publica o app inteiro na Google Play sem nenhuma perda |

Comece por [modulos/15-build-ios/01-por-que-exige-macos.md](modulos/15-build-ios/01-por-que-exige-macos.md)
para entender o porquê técnico e as alternativas reais (Mac na nuvem, CI/CD hospedado).

---

## 💻 Ambiente real detectado nesta máquina

Levantamento feito **nesta máquina**, em **2026-09-14**. Não é uma suposição — é o que está
instalado aqui agora.

| Item | Estado verificado em 2026-09-14 |
|---|---|
| Sistema operacional | Windows 11 Home Single Language 25H2 (build 10.0.26200) |
| Flutter | **3.47.1** stable · revision 6655482ec0 · 2026-08-19 |
| Dart | **3.13.1** (embutido no Flutter) |
| DevTools | 2.60.0 |
| Git | 2.46.0.windows.1 ✅ |
| JDK | Temurin OpenJDK 17.0.18 ✅ |
| VS Code | instalado em `%LOCALAPPDATA%\Programs\Microsoft VS Code` ✅ |
| Chrome | 152.x ✅ |
| Android Studio | ❌ **NÃO instalado** |
| Android SDK | ❌ **NÃO instalado** (`ANDROID_HOME` vazio) |
| macOS / Xcode | ❌ indisponível |
| Local do Flutter SDK | `C:\Users\Usuário\Documents\flutter` ⚠️ **PROBLEMÁTICO** |

### Três problemas reais que já acontecem nesta máquina

Estes erros foram **reproduzidos aqui**, não copiados da internet. O curso ensina a corrigir
os três em [02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md) e detalha cada um
em [referencias/erros-comuns.md](referencias/erros-comuns.md).

| # | Problema | Sintoma real | Correção ensinada |
|---|---|---|---|
| 1 | Acento no caminho do Flutter SDK | `FileSystemException: Cannot resolve symbolic links, path = 'C:\Users\Usu rio\...'` e `ShaderCompilerException` | Mover o SDK para `C:\src\flutter` (sem acento, sem espaço) e ajustar o PATH |
| 2 | Modo de Desenvolvedor do Windows desligado | `Building with plugins requires symlink support. Please enable Developer Mode` | Ativar em Configurações → Sistema → Para desenvolvedores |
| 3 | Android SDK ausente | `[X] Android toolchain — Unable to locate Android SDK.` | Instalar Android Studio, usar o SDK Manager e rodar `flutter doctor --android-licenses` |

> 🪟 Os três problemas são **específicos do Windows**. Você resolve todos no **Dia 1** do plano
> intensivo, antes de escrever a primeira linha de código Flutter.

---

## 🧰 Tecnologias e versões oficiais do curso

Estas são as versões usadas em **todo** o material. Nenhum arquivo do curso usa versão
diferente destas.

### Ferramentas

| Ferramenta | Versão do curso |
|---|---|
| Flutter SDK | 3.47.1 (canal `stable`) |
| Dart SDK | 3.13.1 |
| JDK | 17 (Temurin) — exigido pelo Gradle/AGP |
| Git | 2.46+ |

### Dependências de produção (`dependencies`)

| Pacote | Versão | Para que serve |
|---|---|---|
| `cupertino_icons` | ^1.0.8 | Conjunto de ícones no estilo iOS |
| `flutter_riverpod` | ^3.4.3 | Gerenciamento de estado (o "cérebro" compartilhado do app) |
| `http` | ^1.6.0 | Chamadas de rede (consumir APIs) |
| `shared_preferences` | ^2.5.5 | Armazenamento chave-valor simples no aparelho |
| `sqflite` | ^2.4.4 | Banco de dados SQLite local |
| `path` | ^1.9.1 | Manipulação de caminhos de arquivo |
| `path_provider` | ^2.1.6 | Descobre as pastas corretas do app em cada sistema |
| `intl` | ^0.20.2 | Formatação de datas, números e moedas |
| `uuid` | ^4.6.0 | Geração de identificadores únicos |
| `flutter_secure_storage` | ^11.1.1 | Armazenamento criptografado para dados sensíveis |
| `connectivity_plus` | ^7.3.1 | Detecção de conexão de rede |

### Dependências de desenvolvimento (`dev_dependencies`)

| Pacote | Versão | Para que serve |
|---|---|---|
| `flutter_test` | SDK | Framework de testes do Flutter |
| `integration_test` | SDK | Testes que rodam o app inteiro |
| `flutter_lints` | ^6.0.0 | Regras oficiais de qualidade de código |
| `mocktail` | ^1.0.5 | Criação de dublês de teste sem gerador de código |
| `flutter_launcher_icons` | ^0.14.4 | Geração dos ícones do app |
| `flutter_native_splash` | ^2.4.8 | Geração da tela de abertura |
| `sqflite_common_ffi` | ^2.4.3 | Permite testar `sqflite` no desktop |

### Pacotes de módulos específicos

| Pacote | Versão | Onde aparece |
|---|---|---|
| `image_picker` | ^1.2.3 | [modulos/11-recursos-nativos/02-camera-e-galeria.md](modulos/11-recursos-nativos/02-camera-e-galeria.md) |
| `permission_handler` | ^13.0.2 | [modulos/11-recursos-nativos/01-permissoes.md](modulos/11-recursos-nativos/01-permissoes.md) |
| `go_router` | ^18.0.1 | [modulos/07-navegacao-e-formularios/09-go-router-opcional.md](modulos/07-navegacao-e-formularios/09-go-router-opcional.md) (aula opcional) |

### Restrição de SDK usada em todos os `pubspec.yaml`

```yaml
environment:
  sdk: ^3.13.0
```

### Decisões técnicas em uma linha

| Tema | Decisão do curso |
|---|---|
| Estado | Riverpod 3.4.3 **sem** geração de código |
| Navegação | `Navigator` 1.0 + rotas nomeadas com `onGenerateRoute` |
| Arquitetura | Feature-first, 3 camadas (`presentation` / `domain` / `data`) |
| Rede | `package:http` |
| Banco | `sqflite` + `shared_preferences` + `flutter_secure_storage` |
| Testes | `flutter_test` + `mocktail` + `integration_test` |
| Design | Material 3 |
| API de exemplo | `https://jsonplaceholder.typicode.com` (pública, sem token) |

O porquê de cada escolha está em [05-decisoes-tecnicas.md](05-decisoes-tecnicas.md).

---

## 🗺️ Índice completo do curso

### Arquivos da raiz

| Arquivo | O que contém |
|---|---|
| [README.md](README.md) | Este arquivo: visão geral e índice |
| [00-como-usar-o-curso.md](00-como-usar-o-curso.md) | **Comece aqui.** Método de estudo, emojis, glossário, segurança |
| [01-plano-intensivo.md](01-plano-intensivo.md) | Seu plano ativo de 15 dias, mais as alternativas de 30 e 60 dias |
| [02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md) | Instalar e corrigir tudo nesta máquina |
| [03-trilha-de-progresso.md](03-trilha-de-progresso.md) | Checklist geral para marcar o que você concluiu |
| [04-mapa-de-aprendizagem.md](04-mapa-de-aprendizagem.md) | Dependências entre assuntos: o que vem antes do quê |
| [05-decisoes-tecnicas.md](05-decisoes-tecnicas.md) | Por que Riverpod, por que `http`, por que Navigator 1.0 |
| [06-relatorio-de-validacao.md](06-relatorio-de-validacao.md) | O que foi verificado, como e quando |

### Módulo 00 — Git e terminal

[📁 README do módulo](modulos/00-git-e-terminal/README.md) ·
[📝 Exercícios](exercicios/00-git-e-terminal.md) ·
[🔑 Gabarito](gabaritos/00-git-e-terminal.md) ·
[🧾 Avaliação](avaliacoes/modulo-00-git-e-terminal.md)

| # | Aula |
|---|---|
| 01 | [O terminal sem medo](modulos/00-git-e-terminal/01-o-terminal-sem-medo.md) |
| 02 | [Arquivos e caminhos](modulos/00-git-e-terminal/02-arquivos-e-caminhos.md) |
| 03 | [Git: o que é](modulos/00-git-e-terminal/03-git-o-que-e.md) |
| 04 | [Commits, branches e .gitignore](modulos/00-git-e-terminal/04-commits-branches-gitignore.md) |
| 05 | [Desfazendo erros e protegendo segredos](modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md) |

### Módulo 01 — Lógica e fundamentos

[📁 README do módulo](modulos/01-logica-e-fundamentos/README.md) ·
[📝 Exercícios](exercicios/01-logica-e-fundamentos.md) ·
[🔑 Gabarito](gabaritos/01-logica-e-fundamentos.md) ·
[🧾 Avaliação](avaliacoes/modulo-01-logica-e-fundamentos.md)

| # | Aula |
|---|---|
| 01 | [O que é programar](modulos/01-logica-e-fundamentos/01-o-que-e-programar.md) |
| 02 | [Dart e Flutter](modulos/01-logica-e-fundamentos/02-dart-e-flutter.md) |
| 03 | [Algoritmos e decomposição](modulos/01-logica-e-fundamentos/03-algoritmos-e-decomposicao.md) |
| 04 | [Variáveis e constantes](modulos/01-logica-e-fundamentos/04-variaveis-e-constantes.md) |
| 05 | [Tipos de dados](modulos/01-logica-e-fundamentos/05-tipos-de-dados.md) |
| 06 | [Operadores](modulos/01-logica-e-fundamentos/06-operadores.md) |
| 07 | [Condições](modulos/01-logica-e-fundamentos/07-condicoes.md) |
| 08 | [Repetições](modulos/01-logica-e-fundamentos/08-repeticoes.md) |
| 09 | [Funções](modulos/01-logica-e-fundamentos/09-funcoes.md) |
| 10 | [Lendo mensagens de erro](modulos/01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md) |

### Módulo 02 — Dart básico

[📁 README do módulo](modulos/02-dart-basico/README.md) ·
[📝 Exercícios](exercicios/02-dart-basico.md) ·
[🔑 Gabarito](gabaritos/02-dart-basico.md) ·
[🧾 Avaliação](avaliacoes/modulo-02-dart-basico.md)

| # | Aula |
|---|---|
| 01 | [Anatomia de um programa](modulos/02-dart-basico/01-anatomia-de-um-programa.md) |
| 02 | [Sintaxe, convenções e comentários](modulos/02-dart-basico/02-sintaxe-convencoes-comentarios.md) |
| 03 | [var, final e const](modulos/02-dart-basico/03-var-final-const.md) |
| 04 | [Tipos, strings e conversões](modulos/02-dart-basico/04-tipos-strings-conversoes.md) |
| 05 | [Null safety](modulos/02-dart-basico/05-null-safety.md) |
| 06 | [Controle de fluxo](modulos/02-dart-basico/06-controle-de-fluxo.md) |
| 07 | [Funções em Dart](modulos/02-dart-basico/07-funcoes-em-dart.md) |
| 08 | [Listas](modulos/02-dart-basico/08-listas.md) |
| 09 | [Sets e Maps](modulos/02-dart-basico/09-sets-e-maps.md) |
| 10 | [Entrada e saída](modulos/02-dart-basico/10-entrada-e-saida.md) |

### Módulo 03 — Dart intermediário

[📁 README do módulo](modulos/03-dart-intermediario/README.md) ·
[📝 Exercícios](exercicios/03-dart-intermediario.md) ·
[🔑 Gabarito](gabaritos/03-dart-intermediario.md) ·
[🧾 Avaliação](avaliacoes/modulo-03-dart-intermediario.md)

| # | Aula |
|---|---|
| 01 | [Classes e objetos](modulos/03-dart-intermediario/01-classes-e-objetos.md) |
| 02 | [Construtores](modulos/03-dart-intermediario/02-construtores.md) |
| 03 | [Encapsulamento](modulos/03-dart-intermediario/03-encapsulamento.md) |
| 04 | [Herança e polimorfismo](modulos/03-dart-intermediario/04-heranca-e-polimorfismo.md) |
| 05 | [Abstratas e interfaces](modulos/03-dart-intermediario/05-abstratas-e-interfaces.md) |
| 06 | [Mixins](modulos/03-dart-intermediario/06-mixins.md) |
| 07 | [Enums](modulos/03-dart-intermediario/07-enums.md) |
| 08 | [Generics](modulos/03-dart-intermediario/08-generics.md) |
| 09 | [Extensions](modulos/03-dart-intermediario/09-extensions.md) |
| 10 | [Arquivos, bibliotecas e pacotes](modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md) |

### Módulo 04 — Dart avançado

[📁 README do módulo](modulos/04-dart-avancado/README.md) ·
[📝 Exercícios](exercicios/04-dart-avancado.md) ·
[🔑 Gabarito](gabaritos/04-dart-avancado.md) ·
[🧾 Avaliação](avaliacoes/modulo-04-dart-avancado.md)

| # | Aula |
|---|---|
| 01 | [Exceptions](modulos/04-dart-avancado/01-exceptions.md) |
| 02 | [Futures e async/await](modulos/04-dart-avancado/02-futures-e-async-await.md) |
| 03 | [Streams](modulos/04-dart-avancado/03-streams.md) |
| 04 | [Records](modulos/04-dart-avancado/04-records.md) |
| 05 | [Patterns e switch](modulos/04-dart-avancado/05-patterns-e-switch.md) |
| 06 | [Sealed classes](modulos/04-dart-avancado/06-sealed-classes.md) |
| 07 | [Análise estática e lints](modulos/04-dart-avancado/07-analise-estatica-e-lints.md) |
| 08 | [Isolates e desempenho](modulos/04-dart-avancado/08-isolates-e-desempenho.md) |

### Módulo 05 — Introdução ao Flutter

[📁 README do módulo](modulos/05-introducao-ao-flutter/README.md) ·
[📝 Exercícios](exercicios/05-introducao-ao-flutter.md) ·
[🔑 Gabarito](gabaritos/05-introducao-ao-flutter.md) ·
[🧾 Avaliação](avaliacoes/modulo-05-introducao-ao-flutter.md)

| # | Aula |
|---|---|
| 01 | [Como o Flutter funciona](modulos/05-introducao-ao-flutter/01-como-o-flutter-funciona.md) |
| 02 | [Estrutura do projeto](modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md) |
| 03 | [main, runApp e a árvore de widgets](modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md) |
| 04 | [StatelessWidget](modulos/05-introducao-ao-flutter/04-statelesswidget.md) |
| 05 | [StatefulWidget e setState](modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md) |
| 06 | [Ciclo de vida do State](modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) |
| 07 | [BuildContext](modulos/05-introducao-ao-flutter/07-buildcontext.md) |
| 08 | [Hot reload e hot restart](modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md) |
| 09 | [Material e Cupertino](modulos/05-introducao-ao-flutter/09-material-e-cupertino.md) |

### Módulo 06 — Widgets e layouts

[📁 README do módulo](modulos/06-widgets-e-layouts/README.md) ·
[📝 Exercícios](exercicios/06-widgets-e-layouts.md) ·
[🔑 Gabarito](gabaritos/06-widgets-e-layouts.md) ·
[🧾 Avaliação](avaliacoes/modulo-06-widgets-e-layouts.md)

| # | Aula |
|---|---|
| 01 | [Scaffold e AppBar](modulos/06-widgets-e-layouts/01-scaffold-e-appbar.md) |
| 02 | [Texto, tipografia e ícones](modulos/06-widgets-e-layouts/02-texto-tipografia-icones.md) |
| 03 | [Container, Padding e SizedBox](modulos/06-widgets-e-layouts/03-container-padding-sizedbox.md) |
| 04 | [Row, Column e Expanded](modulos/06-widgets-e-layouts/04-row-column-expanded.md) |
| 05 | [Stack e Positioned](modulos/06-widgets-e-layouts/05-stack-e-positioned.md) |
| 06 | [Constraints](modulos/06-widgets-e-layouts/06-constraints.md) |
| 07 | [Cores, temas e modo escuro](modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) |
| 08 | [Imagens e assets](modulos/06-widgets-e-layouts/08-imagens-e-assets.md) |
| 09 | [Listas e rolagem](modulos/06-widgets-e-layouts/09-listas-e-rolagem.md) |
| 10 | [Gestos e feedback](modulos/06-widgets-e-layouts/10-gestos-e-feedback.md) |
| 11 | [Responsividade](modulos/06-widgets-e-layouts/11-responsividade.md) |
| 12 | [Estados de UI](modulos/06-widgets-e-layouts/12-estados-de-ui.md) |

### Módulo 07 — Navegação e formulários

[📁 README do módulo](modulos/07-navegacao-e-formularios/README.md) ·
[📝 Exercícios](exercicios/07-navegacao-e-formularios.md) ·
[🔑 Gabarito](gabaritos/07-navegacao-e-formularios.md) ·
[🧾 Avaliação](avaliacoes/modulo-07-navegacao-e-formularios.md)

| # | Aula |
|---|---|
| 01 | [Navigator: a pilha](modulos/07-navegacao-e-formularios/01-navigator-a-pilha.md) |
| 02 | [Rotas nomeadas](modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md) |
| 03 | [Argumentos e resultados](modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md) |
| 04 | [Abas e organização](modulos/07-navegacao-e-formularios/04-abas-e-organizacao.md) |
| 05 | [Navegação Android × iOS](modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md) |
| 06 | [Formulários](modulos/07-navegacao-e-formularios/06-formularios.md) |
| 07 | [Validação, foco e teclado](modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md) |
| 08 | [UX de formulários](modulos/07-navegacao-e-formularios/08-ux-de-formularios.md) |
| 09 | [go_router (opcional)](modulos/07-navegacao-e-formularios/09-go-router-opcional.md) |

### Módulo 08 — Estado e arquitetura

[📁 README do módulo](modulos/08-estado-e-arquitetura/README.md) ·
[📝 Exercícios](exercicios/08-estado-e-arquitetura.md) ·
[🔑 Gabarito](gabaritos/08-estado-e-arquitetura.md) ·
[🧾 Avaliação](avaliacoes/modulo-08-estado-e-arquitetura.md)

| # | Aula |
|---|---|
| 01 | [O problema do estado](modulos/08-estado-e-arquitetura/01-o-problema-do-estado.md) |
| 02 | [Elevação de estado](modulos/08-estado-e-arquitetura/02-elevacao-de-estado.md) |
| 03 | [InheritedWidget](modulos/08-estado-e-arquitetura/03-inheritedwidget.md) |
| 04 | [Por que Riverpod](modulos/08-estado-e-arquitetura/04-por-que-riverpod.md) |
| 05 | [Riverpod: primeiros passos](modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md) |
| 06 | [Notifier e NotifierProvider](modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md) |
| 07 | [AsyncNotifier e AsyncValue](modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) |
| 08 | [family, autoDispose e listen](modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md) |
| 09 | [Arquitetura feature-first](modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md) |
| 10 | [Injeção de dependências](modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md) |

### Módulo 09 — Consumo de API

[📁 README do módulo](modulos/09-consumo-de-api/README.md) ·
[📝 Exercícios](exercicios/09-consumo-de-api.md) ·
[🔑 Gabarito](gabaritos/09-consumo-de-api.md) ·
[🧾 Avaliação](avaliacoes/modulo-09-consumo-de-api.md)

| # | Aula |
|---|---|
| 01 | [HTTP e REST](modulos/09-consumo-de-api/01-http-e-rest.md) |
| 02 | [JSON](modulos/09-consumo-de-api/02-json.md) |
| 03 | [Primeiro GET](modulos/09-consumo-de-api/03-primeiro-get.md) |
| 04 | [Modelando respostas e erros](modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md) |
| 05 | [POST, PUT e DELETE](modulos/09-consumo-de-api/05-post-put-delete.md) |
| 06 | [Timeout, retry e cancelamento](modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md) |
| 07 | [Camada de dados testável](modulos/09-consumo-de-api/07-camada-de-dados-testavel.md) |
| 08 | [Autenticação e tokens](modulos/09-consumo-de-api/08-autenticacao-e-tokens.md) |
| 09 | [API com Riverpod](modulos/09-consumo-de-api/09-api-com-riverpod.md) |

### Módulo 10 — Persistência de dados

[📁 README do módulo](modulos/10-persistencia-de-dados/README.md) ·
[📝 Exercícios](exercicios/10-persistencia-de-dados.md) ·
[🔑 Gabarito](gabaritos/10-persistencia-de-dados.md) ·
[🧾 Avaliação](avaliacoes/modulo-10-persistencia-de-dados.md)

| # | Aula |
|---|---|
| 01 | [Qual armazenamento usar](modulos/10-persistencia-de-dados/01-qual-armazenamento-usar.md) |
| 02 | [shared_preferences](modulos/10-persistencia-de-dados/02-shared-preferences.md) |
| 03 | [Arquivos e path_provider](modulos/10-persistencia-de-dados/03-arquivos-e-path-provider.md) |
| 04 | [sqflite: criando o banco](modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) |
| 05 | [sqflite: CRUD](modulos/10-persistencia-de-dados/05-sqflite-crud.md) |
| 06 | [Migrações](modulos/10-persistencia-de-dados/06-migracoes.md) |
| 07 | [Dados sensíveis](modulos/10-persistencia-de-dados/07-dados-sensiveis.md) |
| 08 | [Cache e offline](modulos/10-persistencia-de-dados/08-cache-e-offline.md) |

### Módulo 11 — Recursos nativos

[📁 README do módulo](modulos/11-recursos-nativos/README.md) ·
[📝 Exercícios](exercicios/11-recursos-nativos.md) ·
[🔑 Gabarito](gabaritos/11-recursos-nativos.md) ·
[🧾 Avaliação](avaliacoes/modulo-11-recursos-nativos.md)

| # | Aula |
|---|---|
| 01 | [Permissões](modulos/11-recursos-nativos/01-permissoes.md) |
| 02 | [Câmera e galeria](modulos/11-recursos-nativos/02-camera-e-galeria.md) |
| 03 | [Arquivos e compartilhamento](modulos/11-recursos-nativos/03-arquivos-e-compartilhamento.md) |
| 04 | [Notificações](modulos/11-recursos-nativos/04-notificacoes.md) |
| 05 | [Conectividade](modulos/11-recursos-nativos/05-conectividade.md) |
| 06 | [Ciclo de vida do app](modulos/11-recursos-nativos/06-ciclo-de-vida-do-app.md) |
| 07 | [Pastas android/ e ios/](modulos/11-recursos-nativos/07-pastas-android-e-ios.md) |
| 08 | [Botão voltar e gestos](modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md) |
| 09 | [Material × Cupertino](modulos/11-recursos-nativos/09-material-x-cupertino.md) |
| 10 | [Avaliando pacotes](modulos/11-recursos-nativos/10-avaliando-pacotes.md) |

### Módulo 12 — Testes e debug

[📁 README do módulo](modulos/12-testes-e-debug/README.md) ·
[📝 Exercícios](exercicios/12-testes-e-debug.md) ·
[🔑 Gabarito](gabaritos/12-testes-e-debug.md) ·
[🧾 Avaliação](avaliacoes/modulo-12-testes-e-debug.md)

| # | Aula |
|---|---|
| 01 | [Lendo stack traces](modulos/12-testes-e-debug/01-lendo-stack-traces.md) |
| 02 | [Logs e breakpoints](modulos/12-testes-e-debug/02-logs-e-breakpoints.md) |
| 03 | [DevTools](modulos/12-testes-e-debug/03-devtools.md) |
| 04 | [Análise, lint e formatação](modulos/12-testes-e-debug/04-analise-lint-formatacao.md) |
| 05 | [Testes unitários](modulos/12-testes-e-debug/05-testes-unitarios.md) |
| 06 | [Testes de widget](modulos/12-testes-e-debug/06-testes-de-widget.md) |
| 07 | [Mocks e fakes](modulos/12-testes-e-debug/07-mocks-e-fakes.md) |
| 08 | [Testes de integração](modulos/12-testes-e-debug/08-testes-de-integracao.md) |
| 09 | [Depurando Android e iOS](modulos/12-testes-e-debug/09-depurando-android-e-ios.md) |

### Módulo 13 — Desempenho e segurança

[📁 README do módulo](modulos/13-desempenho-e-seguranca/README.md) ·
[📝 Exercícios](exercicios/13-desempenho-e-seguranca.md) ·
[🔑 Gabarito](gabaritos/13-desempenho-e-seguranca.md) ·
[🧾 Avaliação](avaliacoes/modulo-13-desempenho-e-seguranca.md)

| # | Aula |
|---|---|
| 01 | [Rebuilds, const e keys](modulos/13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md) |
| 02 | [Listas grandes e imagens](modulos/13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md) |
| 03 | [Assíncrono sem travar](modulos/13-desempenho-e-seguranca/03-assincrono-sem-travar.md) |
| 04 | [Medindo desempenho](modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md) |
| 05 | [Acessibilidade](modulos/13-desempenho-e-seguranca/05-acessibilidade.md) |
| 06 | [Segurança mobile](modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md) |
| 07 | [Ofuscação e o que evitar](modulos/13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) |

### Módulo 14 — Build Android 🤖

[📁 README do módulo](modulos/14-build-android/README.md) ·
[📝 Exercícios](exercicios/14-build-android.md) ·
[🔑 Gabarito](gabaritos/14-build-android.md) ·
[🧾 Avaliação](avaliacoes/modulo-14-build-android.md) ·
[☑️ Checklist](checklists/build-android.md)

| # | Aula |
|---|---|
| 01 | [Debug, profile e release](modulos/14-build-android/01-debug-profile-release.md) |
| 02 | [Identidade do app](modulos/14-build-android/02-identidade-do-app.md) |
| 03 | [Ícone](modulos/14-build-android/03-icone.md) |
| 04 | [Splash screen](modulos/14-build-android/04-splash-screen.md) |
| 05 | [Permissões no Android](modulos/14-build-android/05-permissoes-android.md) |
| 06 | [Keystore](modulos/14-build-android/06-keystore.md) |
| 07 | [Assinatura no Gradle](modulos/14-build-android/07-assinatura-no-gradle.md) |
| 08 | [Gerando APK e AAB](modulos/14-build-android/08-gerando-apk-e-aab.md) |
| 09 | [Instalando e validando](modulos/14-build-android/09-instalando-e-validando.md) |
| 10 | [Diagnóstico de build](modulos/14-build-android/10-diagnostico-de-build.md) |

### Módulo 15 — Build iOS 🍎

[📁 README do módulo](modulos/15-build-ios/README.md) ·
[📝 Exercícios](exercicios/15-build-ios.md) ·
[🔑 Gabarito](gabaritos/15-build-ios.md) ·
[🧾 Avaliação](avaliacoes/modulo-15-build-ios.md) ·
[☑️ Checklist](checklists/build-ios.md)

| # | Aula |
|---|---|
| 01 | [Por que exige macOS](modulos/15-build-ios/01-por-que-exige-macos.md) |
| 02 | [Xcode e CocoaPods](modulos/15-build-ios/02-xcode-e-cocoapods.md) |
| 03 | [Simulador e iPhone físico](modulos/15-build-ios/03-simulador-e-iphone-fisico.md) |
| 04 | [Bundle ID e Xcode](modulos/15-build-ios/04-bundle-id-e-xcode.md) |
| 05 | [Ícone, splash, versão e Info.plist](modulos/15-build-ios/05-icone-splash-versao-infoplist.md) |
| 06 | [Conta Apple gratuita × paga](modulos/15-build-ios/06-conta-apple-gratuita-x-paga.md) |
| 07 | [Certificados e provisioning](modulos/15-build-ios/07-certificados-e-provisioning.md) |
| 08 | [Build IPA e archive](modulos/15-build-ios/08-build-ipa-e-archive.md) |
| 09 | [Exportando IPA e TestFlight](modulos/15-build-ios/09-exportando-ipa-e-testflight.md) |
| 10 | [Diagnóstico de CocoaPods e assinatura](modulos/15-build-ios/10-diagnostico-cocoapods-e-assinatura.md) |

### Módulo 16 — Publicação e próximos passos

[📁 README do módulo](modulos/16-publicacao-e-proximos-passos/README.md) ·
[📝 Exercícios](exercicios/16-publicacao-e-proximos-passos.md) ·
[🔑 Gabarito](gabaritos/16-publicacao-e-proximos-passos.md) ·
[🧾 Avaliação](avaliacoes/modulo-16-publicacao-e-proximos-passos.md)

| # | Aula |
|---|---|
| 01 | [Google Play](modulos/16-publicacao-e-proximos-passos/01-google-play.md) |
| 02 | [App Store Connect](modulos/16-publicacao-e-proximos-passos/02-app-store-connect.md) |
| 03 | [Versionamento e releases](modulos/16-publicacao-e-proximos-passos/03-versionamento-e-releases.md) |
| 04 | [CI/CD introdutório](modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md) |
| 05 | [Monitoramento e feedback](modulos/16-publicacao-e-proximos-passos/05-monitoramento-e-feedback.md) |
| 06 | [Próximos passos](modulos/16-publicacao-e-proximos-passos/06-proximos-passos.md) |

---

## 🛠️ Os 3 projetos práticos

[📁 Visão geral dos projetos](projetos/README.md)

### Projeto 1 — "Meu Primeiro App" (`meu_primeiro_app`)

Contador de sessões de estudo com tema claro/escuro. Sem nenhum pacote externo.
Pratica: `StatelessWidget`, `StatefulWidget`, `setState`, `Column`, `Row`, `Container`,
botões, `SnackBar`, `ThemeData` e Material 3.

| Arquivo | Conteúdo |
|---|---|
| [README](projetos/01-projeto-iniciante/README.md) | Visão geral e objetivos |
| [01 Especificação](projetos/01-projeto-iniciante/01-especificacao.md) | O que o app deve fazer |
| [02 Passo a passo](projetos/01-projeto-iniciante/02-passo-a-passo.md) | Construção guiada |
| [03 Código completo](projetos/01-projeto-iniciante/03-codigo-completo.md) | Todos os arquivos finais |
| [04 Testes](projetos/01-projeto-iniciante/04-testes.md) | Como validar |
| [05 Desafios](projetos/01-projeto-iniciante/05-desafios.md) | Extensões opcionais |
| [06 Checklist](projetos/01-projeto-iniciante/06-checklist.md) | Critérios de "pronto" |
| [🔑 Gabarito dos desafios](gabaritos/projeto-01-desafios.md) | Soluções comentadas |

### Projeto 2 — "Bloco de Notas de Estudo" (`bloco_notas`)

Notas com título, conteúdo e etiqueta. Pratica: múltiplas telas, `Navigator` com rotas
nomeadas, argumentos e retorno, `Form` com validação, `shared_preferences` guardando JSON,
organização em pastas e primeiros testes.

| Arquivo | Conteúdo |
|---|---|
| [README](projetos/02-projeto-intermediario/README.md) | Visão geral e objetivos |
| [01 Especificação](projetos/02-projeto-intermediario/01-especificacao.md) | Requisitos |
| [02 Passo a passo](projetos/02-projeto-intermediario/02-passo-a-passo.md) | Construção guiada |
| [03 Código completo](projetos/02-projeto-intermediario/03-codigo-completo.md) | Todos os arquivos finais |
| [04 Testes](projetos/02-projeto-intermediario/04-testes.md) | Unitários e de widget |
| [05 Desafios](projetos/02-projeto-intermediario/05-desafios.md) | Extensões opcionais |
| [06 Checklist](projetos/02-projeto-intermediario/06-checklist.md) | Critérios de "pronto" |
| [🔑 Gabarito dos desafios](gabaritos/projeto-02-desafios.md) | Soluções comentadas |

### Projeto 3 — "Foco: Organizador de Estudos" (`foco`)

O projeto final e multiplataforma. Pacote `br.com.estudos.foco`. Cinco telas, banco `sqflite`,
metas em `shared_preferences`, trilhas vindas de uma API pública, estado com Riverpod,
testes e build assinado para Android e iOS.

| Arquivo | Conteúdo |
|---|---|
| [README](projetos/03-projeto-final-multiplataforma/README.md) | Visão geral |
| [01 Especificação](projetos/03-projeto-final-multiplataforma/01-especificacao.md) | Requisitos completos |
| [02 Arquitetura](projetos/03-projeto-final-multiplataforma/02-arquitetura.md) | Camadas e pastas |
| [03 Etapa 1 — Fundação](projetos/03-projeto-final-multiplataforma/03-etapa-1-fundacao.md) | Projeto, tema, rotas |
| [04 Etapa 2 — Domínio e dados](projetos/03-projeto-final-multiplataforma/04-etapa-2-dominio-e-dados.md) | Modelos, DAOs, repositórios |
| [05 Etapa 3 — Estado com Riverpod](projetos/03-projeto-final-multiplataforma/05-etapa-3-estado-com-riverpod.md) | Notifiers e providers |
| [06 Etapa 4 — Telas e navegação](projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md) | As 5 telas |
| [07 Etapa 5 — API e trilhas](projetos/03-projeto-final-multiplataforma/07-etapa-5-api-e-trilhas.md) | Consumo HTTP |
| [08 Etapa 6 — Responsividade e acessibilidade](projetos/03-projeto-final-multiplataforma/08-etapa-6-responsividade-e-acessibilidade.md) | Telas grandes e leitores de tela |
| [09 Etapa 7 — Testes](projetos/03-projeto-final-multiplataforma/09-etapa-7-testes.md) | Unitários, widget, integração |
| [10 Etapa 8 — Ícone, splash e versão](projetos/03-projeto-final-multiplataforma/10-etapa-8-icone-splash-e-versao.md) | Identidade visual |
| [11 Critérios de aceite](projetos/03-projeto-final-multiplataforma/11-criterios-de-aceite.md) | Como saber que está pronto |
| [12 Desafios](projetos/03-projeto-final-multiplataforma/12-desafios.md) | Extensões opcionais |
| [13 Checklist](projetos/03-projeto-final-multiplataforma/13-checklist.md) | Verificação final |
| [🔑 Gabarito dos desafios](gabaritos/projeto-03-desafios.md) | Soluções comentadas |
| [☑️ Checklist do projeto final](checklists/projeto-final.md) | Conferência geral |

---

## 📝 Exercícios e 🔑 gabaritos

Cada módulo tem uma lista com **no mínimo 12 exercícios** (pelo menos 8 obrigatórios),
divididos em 7 tipos: fixação, aplicação, leitura de código, correção de bugs,
implementação, revisão cumulativa e desafio prático.

[📝 Como os exercícios funcionam](exercicios/README.md) ·
[🔑 Como os gabaritos funcionam](gabaritos/README.md)

| Módulo | Exercícios | Gabarito |
|---|---|---|
| 00 Git e terminal | [lista](exercicios/00-git-e-terminal.md) | [gabarito](gabaritos/00-git-e-terminal.md) |
| 01 Lógica e fundamentos | [lista](exercicios/01-logica-e-fundamentos.md) | [gabarito](gabaritos/01-logica-e-fundamentos.md) |
| 02 Dart básico | [lista](exercicios/02-dart-basico.md) | [gabarito](gabaritos/02-dart-basico.md) |
| 03 Dart intermediário | [lista](exercicios/03-dart-intermediario.md) | [gabarito](gabaritos/03-dart-intermediario.md) |
| 04 Dart avançado | [lista](exercicios/04-dart-avancado.md) | [gabarito](gabaritos/04-dart-avancado.md) |
| 05 Introdução ao Flutter | [lista](exercicios/05-introducao-ao-flutter.md) | [gabarito](gabaritos/05-introducao-ao-flutter.md) |
| 06 Widgets e layouts | [lista](exercicios/06-widgets-e-layouts.md) | [gabarito](gabaritos/06-widgets-e-layouts.md) |
| 07 Navegação e formulários | [lista](exercicios/07-navegacao-e-formularios.md) | [gabarito](gabaritos/07-navegacao-e-formularios.md) |
| 08 Estado e arquitetura | [lista](exercicios/08-estado-e-arquitetura.md) | [gabarito](gabaritos/08-estado-e-arquitetura.md) |
| 09 Consumo de API | [lista](exercicios/09-consumo-de-api.md) | [gabarito](gabaritos/09-consumo-de-api.md) |
| 10 Persistência de dados | [lista](exercicios/10-persistencia-de-dados.md) | [gabarito](gabaritos/10-persistencia-de-dados.md) |
| 11 Recursos nativos | [lista](exercicios/11-recursos-nativos.md) | [gabarito](gabaritos/11-recursos-nativos.md) |
| 12 Testes e debug | [lista](exercicios/12-testes-e-debug.md) | [gabarito](gabaritos/12-testes-e-debug.md) |
| 13 Desempenho e segurança | [lista](exercicios/13-desempenho-e-seguranca.md) | [gabarito](gabaritos/13-desempenho-e-seguranca.md) |
| 14 Build Android | [lista](exercicios/14-build-android.md) | [gabarito](gabaritos/14-build-android.md) |
| 15 Build iOS | [lista](exercicios/15-build-ios.md) | [gabarito](gabaritos/15-build-ios.md) |
| 16 Publicação | [lista](exercicios/16-publicacao-e-proximos-passos.md) | [gabarito](gabaritos/16-publicacao-e-proximos-passos.md) |

---

## 🧾 Avaliações

[📁 Como as avaliações funcionam](avaliacoes/README.md) ·
[🔑 Gabarito de todas as avaliações](gabaritos/avaliacoes.md)

### Por módulo

| Avaliação | Avaliação |
|---|---|
| [Módulo 00](avaliacoes/modulo-00-git-e-terminal.md) | [Módulo 09](avaliacoes/modulo-09-consumo-de-api.md) |
| [Módulo 01](avaliacoes/modulo-01-logica-e-fundamentos.md) | [Módulo 10](avaliacoes/modulo-10-persistencia-de-dados.md) |
| [Módulo 02](avaliacoes/modulo-02-dart-basico.md) | [Módulo 11](avaliacoes/modulo-11-recursos-nativos.md) |
| [Módulo 03](avaliacoes/modulo-03-dart-intermediario.md) | [Módulo 12](avaliacoes/modulo-12-testes-e-debug.md) |
| [Módulo 04](avaliacoes/modulo-04-dart-avancado.md) | [Módulo 13](avaliacoes/modulo-13-desempenho-e-seguranca.md) |
| [Módulo 05](avaliacoes/modulo-05-introducao-ao-flutter.md) | [Módulo 14](avaliacoes/modulo-14-build-android.md) |
| [Módulo 06](avaliacoes/modulo-06-widgets-e-layouts.md) | [Módulo 15](avaliacoes/modulo-15-build-ios.md) |
| [Módulo 07](avaliacoes/modulo-07-navegacao-e-formularios.md) | [Módulo 16](avaliacoes/modulo-16-publicacao-e-proximos-passos.md) |
| [Módulo 08](avaliacoes/modulo-08-estado-e-arquitetura.md) | |

### Cumulativas e final

| Avaliação | Quando | Cobre |
|---|---|---|
| [Cumulativa 01 — Dart](avaliacoes/cumulativa-01-dart.md) | Dia 5 | Módulos 00 a 04 |
| [Cumulativa 02 — Flutter UI](avaliacoes/cumulativa-02-flutter-ui.md) | Dia 9 | Módulos 05 a 07 |
| [Cumulativa 03 — Estado e dados](avaliacoes/cumulativa-03-estado-e-dados.md) | Dia 12 | Módulos 08 a 10 |
| [Cumulativa 04 — Qualidade e plataforma](avaliacoes/cumulativa-04-qualidade-e-plataforma.md) | Dia 13 | Módulos 11 a 13 |
| [Cumulativa 05 — Build e distribuição](avaliacoes/cumulativa-05-build-e-distribuicao.md) | Dia 15 | Módulos 14 a 16 |
| [Avaliação final](avaliacoes/avaliacao-final.md) | Dia 15 | Curso inteiro + projeto final |

---

## 📚 Referências

| Arquivo | Conteúdo |
|---|---|
| [referencias/glossario.md](referencias/glossario.md) | Todos os termos técnicos do curso, em ordem alfabética |
| [referencias/comandos-uteis.md](referencias/comandos-uteis.md) | Todos os comandos usados, com explicação |
| [referencias/erros-comuns.md](referencias/erros-comuns.md) | Erros reais, texto exato e correção |
| [referencias/diferencas-android-ios.md](referencias/diferencas-android-ios.md) | Tabela comparativa 🤖 × 🍎 |
| [referencias/referencias-oficiais.md](referencias/referencias-oficiais.md) | Links da documentação oficial |
| [referencias/proximos-passos.md](referencias/proximos-passos.md) | O que estudar depois deste curso |

---

## ☑️ Checklists

Use como conferência antes de considerar uma etapa concluída.

| Checklist | Quando usar |
|---|---|
| [checklists/ambiente-android.md](checklists/ambiente-android.md) | Antes do primeiro `flutter run` em um Android |
| [checklists/ambiente-ios.md](checklists/ambiente-ios.md) | 🍎 Antes do primeiro build em um Mac |
| [checklists/projeto-final.md](checklists/projeto-final.md) | Antes de dar o projeto "Foco" por concluído |
| [checklists/build-android.md](checklists/build-android.md) | Antes de gerar APK/AAB de release |
| [checklists/build-ios.md](checklists/build-ios.md) | 🍎 Antes de gerar IPA / subir ao TestFlight |

---

## 🚦 Por onde começar, na ordem

1. **[00-como-usar-o-curso.md](00-como-usar-o-curso.md)** — leia inteiro. É o manual do curso.
2. **[01-plano-intensivo.md](01-plano-intensivo.md)** — siga seu Ritmo A ativo: 15 dias de 8 horas.
3. **[02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md)** — conserte os três
   problemas desta máquina e deixe o `flutter doctor` limpo.
4. **[03-trilha-de-progresso.md](03-trilha-de-progresso.md)** — abra e deixe aberto; é onde
   você marca o que já concluiu.
5. **[modulos/00-git-e-terminal/README.md](modulos/00-git-e-terminal/README.md)** — a primeira aula de verdade.

> **Começou pelo meio?** Volte. O curso tem dependências reais entre os módulos, mapeadas em
> [04-mapa-de-aprendizagem.md](04-mapa-de-aprendizagem.md).

---

## 🔐 Segurança do seu repositório

Este curso trata de assinatura de apps, ou seja, de **chaves criptográficas reais suas**.

- Nenhum arquivo do curso contém senha, token ou chave real. Onde precisaria, você vê
  marcadores como `SUA_SENHA_AQUI`, `<sua-senha>` ou `COLOQUE_SEU_ALIAS`.
- Você aprende a colocar `key.properties`, `*.jks`, `*.keystore`, `*.p12`, `*.cer`,
  `ios/Runner/*.mobileprovision` e `.env` no `.gitignore` já no
  [módulo 00, aula 05](modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md).
- As regras completas estão em [00-como-usar-o-curso.md](00-como-usar-o-curso.md),
  seção "Higiene de segredos".

---

## 🔎 Como este curso foi validado

Versões de pacotes conferidas na API do pub.dev, comandos conferidos na documentação oficial
e o código Riverpod/Flutter compilado nesta máquina em Flutter 3.47.1 / Dart 3.13.1.
O que foi verificado, como e quando está registrado em
[06-relatorio-de-validacao.md](06-relatorio-de-validacao.md).

O curso **não** afirma que algo foi testado quando não foi. Sempre que um passo depende de
hardware que você não tem (um Mac, um iPhone), isso vem marcado com 🍎 e dito abertamente.

---

**Próximo arquivo: [00-como-usar-o-curso.md](00-como-usar-o-curso.md)** ➡️
