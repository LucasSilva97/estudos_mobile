# 04 — Mapa de Aprendizagem

> Este arquivo responde a três perguntas que você vai fazer o tempo todo:
> **"o que eu vou aprender aqui?"**, **"onde eu pratico isso?"** e **"onde isso é usado de verdade?"**.
>
> A tabela grande liga, linha a linha: **objetivo de aprendizagem → aula → exercícios →
> avaliação → uso no projeto**. Se você travar em qualquer ponto do curso, volte aqui e
> encontre o caminho de novo.

**Como ler as colunas**

| Coluna | O que traz |
|---|---|
| **Objetivo de aprendizagem** | O que você consegue **fazer** depois da aula (não o que você "viu") |
| **Módulo** | O número do módulo (00 a 16) |
| **Aula (link)** | O arquivo exato da aula |
| **Exercícios (link)** | O arquivo de exercícios daquele módulo |
| **Avaliação (link)** | A prova de fechamento daquele módulo |
| **Onde é usado no projeto** | Em qual projeto e, quando aplicável, em qual arquivo do app final |

**Abreviações da última coluna**

- **P1** = Projeto 1, "Meu Primeiro App" — [projetos/01-projeto-iniciante/README.md](projetos/01-projeto-iniciante/README.md)
- **P2** = Projeto 2, "Bloco de Notas de Estudo" — [projetos/02-projeto-intermediario/README.md](projetos/02-projeto-intermediario/README.md)
- **P3** = Projeto final, "Foco: Organizador de Estudos" — [projetos/03-projeto-final-multiplataforma/README.md](projetos/03-projeto-final-multiplataforma/README.md)
- **Base** = não aparece como arquivo, mas sustenta tudo o que vem depois

---

## Tabela mestra: objetivo → aula → exercício → avaliação → projeto

| Objetivo de aprendizagem | Módulo | Aula (link) | Exercícios (link) | Avaliação (link) | Onde é usado no projeto |
|---|---|---|---|---|---|
| Abrir um terminal, navegar entre pastas e ler a saída de um comando sem travar | 00 | [01 — O terminal sem medo](modulos/00-git-e-terminal/01-o-terminal-sem-medo.md) | [M00](exercicios/00-git-e-terminal.md) | [Av. M00](avaliacoes/modulo-00-git-e-terminal.md) | Base — todo comando `flutter` |
| Distinguir caminho absoluto de relativo e entender por que acento no caminho quebra o Flutter | 00 | [02 — Arquivos e caminhos](modulos/00-git-e-terminal/02-arquivos-e-caminhos.md) | [M00](exercicios/00-git-e-terminal.md) | [Av. M00](avaliacoes/modulo-00-git-e-terminal.md) | Base — instalação do SDK |
| Explicar o que é controle de versão e inicializar um repositório | 00 | [03 — Git: o que é](modulos/00-git-e-terminal/03-git-o-que-e.md) | [M00](exercicios/00-git-e-terminal.md) | [Av. M00](avaliacoes/modulo-00-git-e-terminal.md) | P1, P2, P3 |
| Criar commits, branches e um `.gitignore` correto para projeto Flutter | 00 | [04 — Commits, branches e .gitignore](modulos/00-git-e-terminal/04-commits-branches-gitignore.md) | [M00](exercicios/00-git-e-terminal.md) | [Av. M00](avaliacoes/modulo-00-git-e-terminal.md) | P3 · `.gitignore` do `foco/` |
| Desfazer erros no Git e nunca versionar segredos (`key.properties`, `*.jks`, `.env`) | 00 | [05 — Desfazendo erros e segredos](modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md) | [M00](exercicios/00-git-e-terminal.md) | [Av. M00](avaliacoes/modulo-00-git-e-terminal.md) | P3 · assinatura Android |
| Definir programa, compilador e execução em palavras suas | 01 | [01 — O que é programar](modulos/01-logica-e-fundamentos/01-o-que-e-programar.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | Base |
| Explicar a relação entre Dart (linguagem) e Flutter (framework de UI) | 01 | [02 — Dart e Flutter](modulos/01-logica-e-fundamentos/02-dart-e-flutter.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | Base |
| Quebrar um problema em passos e escrever o algoritmo antes do código | 01 | [03 — Algoritmos e decomposição](modulos/01-logica-e-fundamentos/03-algoritmos-e-decomposicao.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | P3 · cronômetro da sessão |
| Guardar e reutilizar valores com variáveis e constantes | 01 | [04 — Variáveis e constantes](modulos/01-logica-e-fundamentos/04-variaveis-e-constantes.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | P1 · contador |
| Escolher o tipo certo para cada dado (`int`, `double`, `String`, `bool`) | 01 | [05 — Tipos de dados](modulos/01-logica-e-fundamentos/05-tipos-de-dados.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | P3 · `materia.dart` |
| Combinar valores com operadores aritméticos, de comparação e lógicos | 01 | [06 — Operadores](modulos/01-logica-e-fundamentos/06-operadores.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | P3 · progresso da meta |
| Tomar decisões no código com `if`, `else if` e `else` | 01 | [07 — Condições](modulos/01-logica-e-fundamentos/07-condicoes.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | P2 · filtro por etiqueta |
| Repetir trabalho com `for`, `while` e `for-in` sem criar laço infinito | 01 | [08 — Repetições](modulos/01-logica-e-fundamentos/08-repeticoes.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | P3 · somatório de minutos |
| Isolar comportamento em funções com parâmetros e retorno | 01 | [09 — Funções](modulos/01-logica-e-fundamentos/09-funcoes.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | Base |
| Ler uma mensagem de erro de cima para baixo e localizar a linha culpada | 01 | [10 — Lendo mensagens de erro](modulos/01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md) | [M01](exercicios/01-logica-e-fundamentos.md) | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) | Base — todo o curso |
| Reconhecer cada parte de um programa Dart (`main`, imports, chaves, ponto e vírgula) | 02 | [01 — Anatomia de um programa](modulos/02-dart-basico/01-anatomia-de-um-programa.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | Base · `main.dart` |
| Escrever código dentro das convenções oficiais e comentar com propósito | 02 | [02 — Sintaxe, convenções e comentários](modulos/02-dart-basico/02-sintaxe-convencoes-comentarios.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | P3 · projeto inteiro |
| Decidir entre `var`, `final` e `const` com critério, não por hábito | 02 | [03 — var, final e const](modulos/02-dart-basico/03-var-final-const.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | P3 · `app_constants.dart` |
| Manipular texto, interpolar valores e converter tipos com segurança | 02 | [04 — Tipos, strings e conversões](modulos/02-dart-basico/04-tipos-strings-conversoes.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | P3 · formatação de minutos |
| Evitar erros de nulo usando `?`, `!`, `??` e `late` conscientemente | 02 | [05 — Null safety](modulos/02-dart-basico/05-null-safety.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | P3 · `materia.dart` |
| Controlar o fluxo com `switch`, `break`, `continue` e operador ternário | 02 | [06 — Controle de fluxo](modulos/02-dart-basico/06-controle-de-fluxo.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | P3 · estados de UI |
| Escrever funções Dart com parâmetros nomeados, opcionais e arrow | 02 | [07 — Funções em Dart](modulos/02-dart-basico/07-funcoes-em-dart.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | Base · construtores de widget |
| Guardar coleções ordenadas em `List` e transformá-las com `map`/`where` | 02 | [08 — Listas](modulos/02-dart-basico/08-listas.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | P3 · lista de matérias |
| Usar `Set` para unicidade e `Map` para pares chave-valor | 02 | [09 — Sets e Maps](modulos/02-dart-basico/09-sets-e-maps.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | P3 · `toMap()` do DAO |
| Ler dados do teclado e imprimir no terminal | 02 | [10 — Entrada e saída](modulos/02-dart-basico/10-entrada-e-saida.md) | [M02](exercicios/02-dart-basico.md) | [Av. M02](avaliacoes/modulo-02-dart-basico.md) | Base |
| Modelar coisas do mundo real como classes e objetos | 03 | [01 — Classes e objetos](modulos/03-dart-intermediario/01-classes-e-objetos.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | P3 · `materia.dart`, `sessao.dart` |
| Criar construtores nomeados, `factory` e inicialização de campos | 03 | [02 — Construtores](modulos/03-dart-intermediario/02-construtores.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | P3 · `Materia.fromMap()` |
| Proteger o estado interno com campos privados e getters | 03 | [03 — Encapsulamento](modulos/03-dart-intermediario/03-encapsulamento.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | P3 · controllers |
| Reaproveitar comportamento com herança e sobrescrita | 03 | [04 — Herança e polimorfismo](modulos/03-dart-intermediario/04-heranca-e-polimorfismo.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | Base · `extends StatelessWidget` |
| Definir contratos com classes abstratas e `implements` | 03 | [05 — Abstratas e interfaces](modulos/03-dart-intermediario/05-abstratas-e-interfaces.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | P3 · `materia_repositorio_contrato.dart` |
| Compartilhar comportamento entre classes sem herança usando `mixin` | 03 | [06 — Mixins](modulos/03-dart-intermediario/06-mixins.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | Base · `SingleTickerProviderStateMixin` |
| Representar um conjunto fechado de opções com `enum` | 03 | [07 — Enums](modulos/03-dart-intermediario/07-enums.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | P3 · status da sessão |
| Escrever tipos reutilizáveis com generics (`List<T>`, `Future<T>`) | 03 | [08 — Generics](modulos/03-dart-intermediario/08-generics.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | P3 · repositórios |
| Adicionar métodos a tipos existentes com `extension` | 03 | [09 — Extensions](modulos/03-dart-intermediario/09-extensions.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | P3 · formatação de duração |
| Organizar código em arquivos, bibliotecas e pacotes do pub.dev | 03 | [10 — Arquivos, bibliotecas e pacotes](modulos/03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md) | [M03](exercicios/03-dart-intermediario.md) | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) | P3 · estrutura `lib/` |
| Lançar, capturar e tratar exceções sem engolir erros | 04 | [01 — Exceptions](modulos/04-dart-avancado/01-exceptions.md) | [M04](exercicios/04-dart-avancado.md) | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) | P3 · `falhas.dart` |
| Trabalhar com código assíncrono usando `Future`, `async` e `await` | 04 | [02 — Futures e async/await](modulos/04-dart-avancado/02-futures-e-async-await.md) | [M04](exercicios/04-dart-avancado.md) | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) | P3 · toda camada `data/` |
| Consumir sequências de eventos ao longo do tempo com `Stream` | 04 | [03 — Streams](modulos/04-dart-avancado/03-streams.md) | [M04](exercicios/04-dart-avancado.md) | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) | P3 · cronômetro, conectividade |
| Retornar múltiplos valores de forma tipada com `record` | 04 | [04 — Records](modulos/04-dart-avancado/04-records.md) | [M04](exercicios/04-dart-avancado.md) | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) | P3 · estatísticas |
| Desestruturar dados com pattern matching e `switch` expressão | 04 | [05 — Patterns e switch](modulos/04-dart-avancado/05-patterns-e-switch.md) | [M04](exercicios/04-dart-avancado.md) | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) | P3 · tratamento de falhas |
| Modelar resultados fechados com `sealed class` e `switch` exaustivo | 04 | [06 — Sealed classes](modulos/04-dart-avancado/06-sealed-classes.md) | [M04](exercicios/04-dart-avancado.md) | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) | P3 · `falhas.dart` |
| Configurar `analysis_options.yaml` e corrigir avisos do `flutter analyze` | 04 | [07 — Análise estática e lints](modulos/04-dart-avancado/07-analise-estatica-e-lints.md) | [M04](exercicios/04-dart-avancado.md) | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) | P3 · projeto inteiro |
| Entender quando usar `Isolate` e por que o `main` não pode travar | 04 | [08 — Isolates e desempenho](modulos/04-dart-avancado/08-isolates-e-desempenho.md) | [M04](exercicios/04-dart-avancado.md) | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) | P3 · cálculo de estatísticas |
| Explicar como o Flutter desenha a tela e o que é a árvore de widgets | 05 | [01 — Como o Flutter funciona](modulos/05-introducao-ao-flutter/01-como-o-flutter-funciona.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | Base |
| Reconhecer cada pasta de um projeto criado por `flutter create` | 05 | [02 — Estrutura do projeto](modulos/05-introducao-ao-flutter/02-estrutura-do-projeto.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | P1, P2, P3 |
| Escrever `main()`, `runApp()` e montar a primeira árvore de widgets | 05 | [03 — main, runApp e árvore de widgets](modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | P3 · `main.dart`, `app.dart` |
| Criar widgets imutáveis com `StatelessWidget` e `const` | 05 | [04 — StatelessWidget](modulos/05-introducao-ao-flutter/04-statelesswidget.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | P3 · `materia_tile.dart` |
| Guardar estado local em `StatefulWidget` e atualizar com `setState` | 05 | [05 — StatefulWidget e setState](modulos/05-introducao-ao-flutter/05-statefulwidget-e-setstate.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | P1 · contador |
| Usar `initState`, `didUpdateWidget` e `dispose` na hora certa | 05 | [06 — Ciclo de vida do State](modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | P3 · `sessao_screen.dart` |
| Entender o que é `BuildContext` e por que ele às vezes "não acha" o widget | 05 | [07 — BuildContext](modulos/05-introducao-ao-flutter/07-buildcontext.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | Base · `Navigator`, `Theme` |
| Usar hot reload e hot restart e saber quando cada um não basta | 05 | [08 — Hot reload e hot restart](modulos/05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | Base — rotina diária |
| Diferenciar a família Material da família Cupertino de widgets | 05 | [09 — Material e Cupertino](modulos/05-introducao-ao-flutter/09-material-e-cupertino.md) | [M05](exercicios/05-introducao-ao-flutter.md) | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) | P3 · diálogos por plataforma |
| Montar o esqueleto de uma tela com `Scaffold` e `AppBar` | 06 | [01 — Scaffold e AppBar](modulos/06-widgets-e-layouts/01-scaffold-e-appbar.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P3 · todas as 5 telas |
| Aplicar tipografia do Material 3 e ícones no lugar certo | 06 | [02 — Texto, tipografia e ícones](modulos/06-widgets-e-layouts/02-texto-tipografia-icones.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P3 · `tema_app.dart` |
| Controlar espaçamento com `Container`, `Padding` e `SizedBox` | 06 | [03 — Container, Padding e SizedBox](modulos/06-widgets-e-layouts/03-container-padding-sizedbox.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P1, P2, P3 |
| Organizar elementos em linha e coluna e distribuir espaço com `Expanded` | 06 | [04 — Row, Column e Expanded](modulos/06-widgets-e-layouts/04-row-column-expanded.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P3 · `estatisticas_screen.dart` |
| Sobrepor elementos com `Stack` e `Positioned` | 06 | [05 — Stack e Positioned](modulos/06-widgets-e-layouts/05-stack-e-positioned.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P3 · badge de progresso |
| Ler e resolver erros de *constraints* ("unbounded height", overflow) | 06 | [06 — Constraints](modulos/06-widgets-e-layouts/06-constraints.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | Base — depuração de layout |
| Definir tema claro/escuro com `ColorScheme.fromSeed` e Material 3 | 06 | [07 — Cores, temas e modo escuro](modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P1 · tema; P3 · `tema_app.dart` |
| Declarar assets no `pubspec.yaml` e exibir imagens locais e de rede | 06 | [08 — Imagens e assets](modulos/06-widgets-e-layouts/08-imagens-e-assets.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P3 · ícone e ilustrações |
| Renderizar listas longas com `ListView.builder` sem travar | 06 | [09 — Listas e rolagem](modulos/06-widgets-e-layouts/09-listas-e-rolagem.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P2 · notas; P3 · `materias_tab.dart` |
| Responder a toques e dar retorno visual com `InkWell` e `SnackBar` | 06 | [10 — Gestos e feedback](modulos/06-widgets-e-layouts/10-gestos-e-feedback.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P1 · SnackBar; P3 · desfazer exclusão |
| Adaptar o layout a telas pequenas e grandes com `LayoutBuilder` | 06 | [11 — Responsividade](modulos/06-widgets-e-layouts/11-responsividade.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P3 · etapa 6 |
| Desenhar os quatro estados de tela: carregando, vazio, erro e dados | 06 | [12 — Estados de UI](modulos/06-widgets-e-layouts/12-estados-de-ui.md) | [M06](exercicios/06-widgets-e-layouts.md) | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) | P3 · `core/widgets/` |
| Entender a pilha de navegação e usar `push`/`pop` | 07 | [01 — Navigator: a pilha](modulos/07-navegacao-e-formularios/01-navigator-a-pilha.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | P2 · nota → detalhe |
| Centralizar rotas nomeadas com `onGenerateRoute` | 07 | [02 — Rotas nomeadas](modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | P3 · `core/rotas/rotas.dart` |
| Passar argumentos para uma tela e receber um resultado de volta | 07 | [03 — Argumentos e resultados](modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | P3 · `materia_form_screen.dart` |
| Organizar seções do app em abas com `TabBar` e `NavigationBar` | 07 | [04 — Abas e organização](modulos/07-navegacao-e-formularios/04-abas-e-organizacao.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | P3 · `home_screen.dart` |
| Ajustar a navegação às expectativas de cada plataforma | 07 | [05 — Navegação Android × iOS](modulos/07-navegacao-e-formularios/05-navegacao-android-x-ios.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | P3 · transições |
| Montar um `Form` com `TextFormField` e `GlobalKey<FormState>` | 07 | [06 — Formulários](modulos/07-navegacao-e-formularios/06-formularios.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | P2 · nova nota; P3 · matéria |
| Validar campos, controlar foco e escolher o tipo de teclado | 07 | [07 — Validação, foco e teclado](modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | P3 · `materia_form_screen.dart` |
| Aplicar boas práticas de UX em formulários (erros claros, salvar seguro) | 07 | [08 — UX de formulários](modulos/07-navegacao-e-formularios/08-ux-de-formularios.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | P3 · etapa 4 |
| ⭐ Conhecer `go_router` e decidir quando ele compensa (aula opcional) | 07 | [09 — go_router (opcional)](modulos/07-navegacao-e-formularios/09-go-router-opcional.md) | [M07](exercicios/07-navegacao-e-formularios.md) | [Av. M07](avaliacoes/modulo-07-navegacao-e-formularios.md) | Opcional — não usado no P3 |
| Reconhecer os sintomas de estado mal gerenciado | 08 | [01 — O problema do estado](modulos/08-estado-e-arquitetura/01-o-problema-do-estado.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | Base |
| Elevar o estado para o ancestral comum (*lifting state up*) | 08 | [02 — Elevação de estado](modulos/08-estado-e-arquitetura/02-elevacao-de-estado.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | P1 · tema compartilhado |
| Entender `InheritedWidget` — a base de `Theme.of(context)` e do Riverpod | 08 | [03 — InheritedWidget](modulos/08-estado-e-arquitetura/03-inheritedwidget.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | Base |
| Comparar Riverpod, Provider, BLoC e signals com critérios objetivos | 08 | [04 — Por que Riverpod](modulos/08-estado-e-arquitetura/04-por-que-riverpod.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | P3 · decisão de arquitetura |
| Instalar o Riverpod 3, envolver o app em `ProviderScope` e ler um `Provider` | 08 | [05 — Riverpod: primeiros passos](modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | P3 · `main.dart` |
| Escrever estado síncrono com `Notifier` e `NotifierProvider` | 08 | [06 — Notifier e NotifierProvider](modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | P3 · `sessao_controller.dart` |
| Modelar carregando/erro/dados com `AsyncNotifier` e `AsyncValue` | 08 | [07 — AsyncNotifier e AsyncValue](modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | P3 · `materias_controller.dart` |
| Usar `family`, descarte automático e `ref.listen` sem vazar recursos | 08 | [08 — family, autoDispose e listen](modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | P3 · `trilhas_controller.dart` |
| Organizar o código em feature-first com três camadas | 08 | [09 — Arquitetura feature-first](modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | P3 · `lib/features/` |
| Injetar dependências por provider e trocá-las em teste com `overrides` | 08 | [10 — Injeção de dependências](modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md) | [M08](exercicios/08-estado-e-arquitetura.md) | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) | P3 · etapa 7 (testes) |
| Explicar HTTP, REST, verbos e códigos de status | 09 | [01 — HTTP e REST](modulos/09-consumo-de-api/01-http-e-rest.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · trilhas |
| Ler e escrever JSON e converter para objetos Dart | 09 | [02 — JSON](modulos/09-consumo-de-api/02-json.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · `trilha.dart` |
| Fazer a primeira requisição GET com `package:http` | 09 | [03 — Primeiro GET](modulos/09-consumo-de-api/03-primeiro-get.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · `trilha_api.dart` |
| Modelar respostas e falhas com `sealed class` em vez de `dynamic` | 09 | [04 — Modelando respostas e erros](modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · `falhas.dart` |
| Enviar dados com POST, PUT, PATCH e DELETE | 09 | [05 — POST, PUT e DELETE](modulos/09-consumo-de-api/05-post-put-delete.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · etapa 5 |
| Aplicar timeout, nova tentativa e cancelamento em chamadas de rede | 09 | [06 — Timeout, retry e cancelamento](modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · `trilha_repositorio.dart` |
| Separar cliente HTTP, fonte de dados e repositório para poder testar | 09 | [07 — Camada de dados testável](modulos/09-consumo-de-api/07-camada-de-dados-testavel.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · `features/trilhas/data/` |
| Entender autenticação por token e onde guardá-lo com segurança | 09 | [08 — Autenticação e tokens](modulos/09-consumo-de-api/08-autenticacao-e-tokens.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · `flutter_secure_storage` |
| Conectar a API ao Riverpod e exibir `AsyncValue` na tela | 09 | [09 — API com Riverpod](modulos/09-consumo-de-api/09-api-com-riverpod.md) | [M09](exercicios/09-consumo-de-api.md) | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) | P3 · `trilhas_tab.dart` |
| Escolher entre chave-valor, arquivo, banco e cofre seguro | 10 | [01 — Qual armazenamento usar](modulos/10-persistencia-de-dados/01-qual-armazenamento-usar.md) | [M10](exercicios/10-persistencia-de-dados.md) | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) | P3 · etapa 2 |
| Salvar preferências simples com `shared_preferences` | 10 | [02 — shared_preferences](modulos/10-persistencia-de-dados/02-shared-preferences.md) | [M10](exercicios/10-persistencia-de-dados.md) | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) | P2 · notas; P3 · `meta_repositorio.dart` |
| Ler e gravar arquivos no diretório correto com `path_provider` | 10 | [03 — Arquivos e path_provider](modulos/10-persistencia-de-dados/03-arquivos-e-path-provider.md) | [M10](exercicios/10-persistencia-de-dados.md) | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) | P3 · exportar dados |
| Criar um banco SQLite com `sqflite` e definir o esquema | 10 | [04 — sqflite: criando o banco](modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) | [M10](exercicios/10-persistencia-de-dados.md) | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) | P3 · `materia_dao.dart` |
| Fazer inserção, consulta, atualização e exclusão com `sqflite` | 10 | [05 — sqflite: CRUD](modulos/10-persistencia-de-dados/05-sqflite-crud.md) | [M10](exercicios/10-persistencia-de-dados.md) | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) | P3 · `sessao_dao.dart` |
| Evoluir o banco sem perder dados usando `onUpgrade` | 10 | [06 — Migrações](modulos/10-persistencia-de-dados/06-migracoes.md) | [M10](exercicios/10-persistencia-de-dados.md) | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) | P3 · versão 2 do banco |
| Guardar dados sensíveis com `flutter_secure_storage` | 10 | [07 — Dados sensíveis](modulos/10-persistencia-de-dados/07-dados-sensiveis.md) | [M10](exercicios/10-persistencia-de-dados.md) | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) | P3 · token de exemplo |
| Implementar cache local e comportamento offline previsível | 10 | [08 — Cache e offline](modulos/10-persistencia-de-dados/08-cache-e-offline.md) | [M10](exercicios/10-persistencia-de-dados.md) | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) | P3 · trilhas offline |
| Pedir permissões em tempo de execução e tratar a recusa | 11 | [01 — Permissões](modulos/11-recursos-nativos/01-permissoes.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · foto da matéria |
| Capturar imagem da câmera ou escolher da galeria | 11 | [02 — Câmera e galeria](modulos/11-recursos-nativos/02-camera-e-galeria.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · desafio opcional |
| Compartilhar arquivos e conteúdo com outros apps | 11 | [03 — Arquivos e compartilhamento](modulos/11-recursos-nativos/03-arquivos-e-compartilhamento.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · exportar relatório |
| Entender notificações locais e seus limites em cada plataforma | 11 | [04 — Notificações](modulos/11-recursos-nativos/04-notificacoes.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · lembrete de estudo |
| Detectar o estado da conexão com `connectivity_plus` | 11 | [05 — Conectividade](modulos/11-recursos-nativos/05-conectividade.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · aviso de offline |
| Reagir a app em segundo plano com `AppLifecycleState` | 11 | [06 — Ciclo de vida do app](modulos/11-recursos-nativos/06-ciclo-de-vida-do-app.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · pausar cronômetro |
| Saber o que existe dentro de `android/` e `ios/` e o que se pode editar | 11 | [07 — Pastas android e ios](modulos/11-recursos-nativos/07-pastas-android-e-ios.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · etapa 8 |
| Tratar o botão Voltar do Android com `PopScope` e o gesto do iOS | 11 | [08 — Botão voltar e gestos](modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · formulário com alterações |
| Escolher entre visual Material e Cupertino por plataforma | 11 | [09 — Material × Cupertino](modulos/11-recursos-nativos/09-material-x-cupertino.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · diálogos |
| Avaliar um pacote do pub.dev antes de depender dele | 11 | [10 — Avaliando pacotes](modulos/11-recursos-nativos/10-avaliando-pacotes.md) | [M11](exercicios/11-recursos-nativos.md) | [Av. M11](avaliacoes/modulo-11-recursos-nativos.md) | P3 · `pubspec.yaml` |
| Ler um *stack trace* e achar a origem real do erro | 12 | [01 — Lendo stack traces](modulos/12-testes-e-debug/01-lendo-stack-traces.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | Base |
| Investigar com `debugPrint` e pontos de parada no VS Code | 12 | [02 — Logs e breakpoints](modulos/12-testes-e-debug/02-logs-e-breakpoints.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | Base |
| Usar o DevTools para inspecionar árvore, rede e memória | 12 | [03 — DevTools](modulos/12-testes-e-debug/03-devtools.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | P3 · etapa 6 |
| Manter o projeto limpo com `flutter analyze` e `dart format .` | 12 | [04 — Análise, lint e formatação](modulos/12-testes-e-debug/04-analise-lint-formatacao.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | P3 · critérios de aceite |
| Escrever testes unitários com `test`, `group` e `expect` | 12 | [05 — Testes unitários](modulos/12-testes-e-debug/05-testes-unitarios.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | P2 e P3 · `test/` |
| Testar widgets com `testWidgets`, `pumpWidget` e `find` | 12 | [06 — Testes de widget](modulos/12-testes-e-debug/06-testes-de-widget.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | P3 · etapa 7 |
| Substituir dependências reais por mocks com `mocktail` | 12 | [07 — Mocks e fakes](modulos/12-testes-e-debug/07-mocks-e-fakes.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | P3 · repositório falso |
| Rodar testes ponta a ponta com `integration_test` | 12 | [08 — Testes de integração](modulos/12-testes-e-debug/08-testes-de-integracao.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | P3 · `integration_test/` |
| Depurar problemas que só aparecem no aparelho 🤖 e 🍎 | 12 | [09 — Depurando Android e iOS](modulos/12-testes-e-debug/09-depurando-android-e-ios.md) | [M12](exercicios/12-testes-e-debug.md) | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) | P3 · validação em aparelho |
| Reduzir reconstruções desnecessárias com `const` e `Key` | 13 | [01 — Rebuilds, const e keys](modulos/13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md) | [M13](exercicios/13-desempenho-e-seguranca.md) | [Av. M13](avaliacoes/modulo-13-desempenho-e-seguranca.md) | P3 · `materia_tile.dart` |
| Manter listas grandes e imagens fluidas | 13 | [02 — Listas grandes e imagens](modulos/13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md) | [M13](exercicios/13-desempenho-e-seguranca.md) | [Av. M13](avaliacoes/modulo-13-desempenho-e-seguranca.md) | P3 · `trilhas_tab.dart` |
| Executar trabalho pesado sem travar a interface | 13 | [03 — Assíncrono sem travar](modulos/13-desempenho-e-seguranca/03-assincrono-sem-travar.md) | [M13](exercicios/13-desempenho-e-seguranca.md) | [Av. M13](avaliacoes/modulo-13-desempenho-e-seguranca.md) | P3 · estatísticas |
| Medir desempenho com o modo profile e o DevTools | 13 | [04 — Medindo desempenho](modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md) | [M13](exercicios/13-desempenho-e-seguranca.md) | [Av. M13](avaliacoes/modulo-13-desempenho-e-seguranca.md) | P3 · etapa 6 |
| Tornar o app utilizável por leitores de tela e com fonte ampliada | 13 | [05 — Acessibilidade](modulos/13-desempenho-e-seguranca/05-acessibilidade.md) | [M13](exercicios/13-desempenho-e-seguranca.md) | [Av. M13](avaliacoes/modulo-13-desempenho-e-seguranca.md) | P3 · etapa 6 |
| Aplicar as regras básicas de segurança em apps móveis | 13 | [06 — Segurança mobile](modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md) | [M13](exercicios/13-desempenho-e-seguranca.md) | [Av. M13](avaliacoes/modulo-13-desempenho-e-seguranca.md) | P3 · segredos fora do Git |
| Entender ofuscação, seus limites e o que nunca colocar no app | 13 | [07 — Ofuscação e o que evitar](modulos/13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) | [M13](exercicios/13-desempenho-e-seguranca.md) | [Av. M13](avaliacoes/modulo-13-desempenho-e-seguranca.md) | P3 · build release |
| Escolher o canal de distribuição por critério, e não por hábito | 14 | [01 — Por que PWA é o canal principal](modulos/14-build-web-pwa/01-por-que-pwa.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · decisão de canal |
| Explicar como o Dart vira JavaScript ou WebAssembly e o que é o CanvasKit | 14 | [02 — Como o Flutter compila para web](modulos/14-build-web-pwa/02-como-o-flutter-compila-para-web.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · peso do 1º carregamento |
| Escrever código que roda nos três alvos com `kIsWeb` e importações condicionais | 14 | [03 — O que não funciona na web](modulos/14-build-web-pwa/03-o-que-nao-funciona-na-web.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · etapa 9 |
| Fazer o banco `sqflite` funcionar no navegador sem reescrever os DAOs | 14 | [04 — Banco de dados na web](modulos/14-build-web-pwa/04-banco-de-dados-na-web.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · etapa 9 |
| Definir a identidade do app na web: manifest, `scope` e ícones maskable | 14 | [05 — Manifest e ícones](modulos/14-build-web-pwa/05-manifest-e-icones.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · etapa 9 |
| Entender o service worker, o cache e por que o usuário vê a versão antiga | 14 | [06 — Service worker e offline](modulos/14-build-web-pwa/06-service-worker-e-offline.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · offline |
| Cumprir os critérios de instalabilidade e convidar o usuário na hora certa | 14 | [07 — Instalabilidade](modulos/14-build-web-pwa/07-instalabilidade.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · marco 15 |
| Gerar o build web dominando `--base-href` e o que não é segredo na web | 14 | [08 — Gerando o build web](modulos/14-build-web-pwa/08-gerando-o-build-web.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · etapa 9 |
| Publicar por GitHub Actions, com deploy automático a cada push | 14 | [09 — Publicando no GitHub Pages](modulos/14-build-web-pwa/09-publicando-no-github-pages.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · marco 14 |
| Diagnosticar tela branca, cache preso, CORS e cota de armazenamento | 14 | [10 — Diagnóstico web](modulos/14-build-web-pwa/10-diagnostico-web.md) | [M14](exercicios/14-build-web-pwa.md) | [Av. M14](avaliacoes/modulo-14-build-web-pwa.md) | P3 · solução de problemas |
| Diferenciar os modos debug, profile e release | 15 | [01 — Debug, profile e release](modulos/15-build-android/01-debug-profile-release.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · marco "APK debug gerado" |
| Definir nome, `applicationId` e versão do app | 15 | [02 — Identidade do app](modulos/15-build-android/02-identidade-do-app.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · `br.com.estudos.foco` |
| Gerar os ícones com `flutter_launcher_icons` | 15 | [03 — Ícone](modulos/15-build-android/03-icone.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · etapa 8 |
| Configurar a tela de abertura com `flutter_native_splash` | 15 | [04 — Splash screen](modulos/15-build-android/04-splash-screen.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · etapa 8 |
| Declarar permissões no `AndroidManifest.xml` sem exagerar | 15 | [05 — Permissões Android](modulos/15-build-android/05-permissoes-android.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · `INTERNET` |
| Criar o keystore de upload com `keytool` e protegê-lo | 15 | [06 — Keystore](modulos/15-build-android/06-keystore.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · release |
| Configurar a assinatura em `build.gradle.kts` e `key.properties` | 15 | [07 — Assinatura no Gradle](modulos/15-build-android/07-assinatura-no-gradle.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · release |
| Gerar APK e AAB de release pelo terminal | 15 | [08 — Gerando APK e AAB](modulos/15-build-android/08-gerando-apk-e-aab.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · marcos 17 e 18 |
| Instalar o APK em um aparelho real e validar o funcionamento | 15 | [09 — Instalando e validando](modulos/15-build-android/09-instalando-e-validando.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · [checklist](checklists/build-android.md) |
| Diagnosticar falhas de build do Gradle e do AGP | 15 | [10 — Diagnóstico de build](modulos/15-build-android/10-diagnostico-de-build.md) | [M15](exercicios/15-build-android.md) | [Av. M15](avaliacoes/modulo-15-build-android.md) | P3 · solução de problemas |
| 🍎 Explicar tecnicamente por que iOS exige macOS | 16 | [01 — Por que exige macOS](modulos/16-build-ios/01-por-que-exige-macos.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · planejamento iOS |
| 🍎 Instalar Xcode e CocoaPods e entender o papel de cada um | 16 | [02 — Xcode e CocoaPods](modulos/16-build-ios/02-xcode-e-cocoapods.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · `ios/Podfile` |
| 🍎 Rodar o app no simulador e em um iPhone físico | 16 | [03 — Simulador e iPhone físico](modulos/16-build-ios/03-simulador-e-iphone-fisico.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · marcos 8 e 20 |
| 🍎 Configurar Bundle Identifier, time e alvo mínimo (iOS 13) | 16 | [04 — Bundle ID e Xcode](modulos/16-build-ios/04-bundle-id-e-xcode.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · `br.com.estudos.foco` |
| 🍎 Ajustar ícone, splash, versão e chaves do `Info.plist` | 16 | [05 — Ícone, splash, versão e Info.plist](modulos/16-build-ios/05-icone-splash-versao-infoplist.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · etapa 8 |
| 🍎 Decidir entre conta Apple gratuita e paga conhecendo os limites | 16 | [06 — Conta Apple gratuita × paga](modulos/16-build-ios/06-conta-apple-gratuita-x-paga.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · planejamento |
| 🍎 Entender certificados, perfis de provisionamento e assinatura | 16 | [07 — Certificados e provisioning](modulos/16-build-ios/07-certificados-e-provisioning.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · release iOS |
| 🍎 Gerar o archive e o IPA com `flutter build ipa` | 16 | [08 — Build IPA e archive](modulos/16-build-ios/08-build-ipa-e-archive.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · marcos 19, 21 e 22 |
| 🍎 Exportar o IPA e enviar uma versão para o TestFlight | 16 | [09 — Exportando IPA e TestFlight](modulos/16-build-ios/09-exportando-ipa-e-testflight.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · marco 23 |
| 🍎 Diagnosticar erros de CocoaPods e de assinatura | 16 | [10 — Diagnóstico CocoaPods e assinatura](modulos/16-build-ios/10-diagnostico-cocoapods-e-assinatura.md) | [M16](exercicios/16-build-ios.md) | [Av. M16](avaliacoes/modulo-16-build-ios.md) | P3 · solução de problemas |
| 🤖 Preparar uma ficha de app e um lançamento na Google Play | 17 | [01 — Google Play](modulos/17-publicacao-e-proximos-passos/01-google-play.md) | [M17](exercicios/17-publicacao-e-proximos-passos.md) | [Av. M17](avaliacoes/modulo-17-publicacao-e-proximos-passos.md) | P3 · AAB |
| 🍎 Entender o App Store Connect e o processo de revisão | 17 | [02 — App Store Connect](modulos/17-publicacao-e-proximos-passos/02-app-store-connect.md) | [M17](exercicios/17-publicacao-e-proximos-passos.md) | [Av. M17](avaliacoes/modulo-17-publicacao-e-proximos-passos.md) | P3 · IPA |
| Versionar releases com `build-name` e `build-number` | 17 | [03 — Versionamento e releases](modulos/17-publicacao-e-proximos-passos/03-versionamento-e-releases.md) | [M17](exercicios/17-publicacao-e-proximos-passos.md) | [Av. M17](avaliacoes/modulo-17-publicacao-e-proximos-passos.md) | P3 · `pubspec.yaml` |
| Automatizar análise, teste e build com integração contínua | 17 | [04 — CI/CD introdutório](modulos/17-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md) | [M17](exercicios/17-publicacao-e-proximos-passos.md) | [Av. M17](avaliacoes/modulo-17-publicacao-e-proximos-passos.md) | P3 · repositório |
| Monitorar erros e coletar retorno das pessoas usuárias | 17 | [05 — Monitoramento e feedback](modulos/17-publicacao-e-proximos-passos/05-monitoramento-e-feedback.md) | [M17](exercicios/17-publicacao-e-proximos-passos.md) | [Av. M17](avaliacoes/modulo-17-publicacao-e-proximos-passos.md) | P3 · pós-lançamento |
| Definir seu próximo objetivo de estudo com um plano concreto | 17 | [06 — Próximos passos](modulos/17-publicacao-e-proximos-passos/06-proximos-passos.md) | [M17](exercicios/17-publicacao-e-proximos-passos.md) | [Av. M17](avaliacoes/modulo-17-publicacao-e-proximos-passos.md) | [referencias/proximos-passos.md](referencias/proximos-passos.md) |

---

## Ordem de dependência entre módulos

O diagrama abaixo mostra o que precisa vir antes do quê. Uma seta `──▶` significa
"o módulo da esquerda é pré-requisito do módulo da direita". Colunas paralelas significam
que aqueles módulos podem ser estudados na ordem que você preferir.

```text
                         ┌──────────────────────────┐
                         │ 02-configuracao-ambiente │  (não é módulo, é pré-condição)
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │ M00 · Git e terminal     │
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │ M01 · Lógica e           │
                         │       fundamentos        │
                         └────────────┬─────────────┘
                                      ▼
                         ┌──────────────────────────┐
                         │ M02 · Dart básico        │
                         └────────────┬─────────────┘
                                      ▼
                         ┌──────────────────────────┐
                         │ M03 · Dart intermediário │
                         └────────────┬─────────────┘
                                      ▼
                         ┌──────────────────────────┐
                         │ M04 · Dart avançado      │────┐
                         └────────────┬─────────────┘    │ (async, sealed,
                                      ▼                  │  patterns)
                         ┌──────────────────────────┐    │
                         │ M05 · Intro ao Flutter   │    │
                         └────────────┬─────────────┘    │
                              │       │                  │
                              │       ▼                  │
                              │  ┌─────────────────────┐ │
                              │  │ PROJETO 1           │ │
                              │  └─────────────────────┘ │
                              ▼                          │
                         ┌──────────────────────────┐    │
                         │ M06 · Widgets e layouts  │    │
                         └────────────┬─────────────┘    │
                                      ▼                  │
                         ┌──────────────────────────┐    │
                         │ M07 · Navegação e        │    │
                         │       formulários        │    │
                         └────────────┬─────────────┘    │
                              │       │                  │
                              │       ▼                  │
                              │  ┌─────────────────────┐ │
                              │  │ PROJETO 2           │ │
                              │  └─────────────────────┘ │
                              ▼                          │
                         ┌──────────────────────────┐    │
                         │ M08 · Estado e           │◀───┘
                         │       arquitetura        │
                         └────────────┬─────────────┘
                              ┌───────┴────────┐
                              ▼                ▼
                  ┌────────────────────┐  ┌──────────────────────┐
                  │ M09 · Consumo API  │  │ M10 · Persistência   │
                  └─────────┬──────────┘  └──────────┬───────────┘
                            └────────┬───────────────┘
                                     ▼
                         ┌──────────────────────────┐
                         │ M11 · Recursos nativos   │
                         └────────────┬─────────────┘
                                      ▼
                         ┌──────────────────────────┐
                         │ M12 · Testes e debug     │
                         └────────────┬─────────────┘
                                      ▼
                         ┌──────────────────────────┐
                         │ M13 · Desempenho e       │
                         │       segurança          │
                         └────────────┬─────────────┘
                                      ▼
                         ┌──────────────────────────┐
                         │ PROJETO FINAL · "Foco"   │
                         └────────────┬─────────────┘
                                      ▼
                         ┌──────────────────────────┐
                         │ M14 · Build Web 🌐       │  ◀── CANAL PRINCIPAL
                         │       (PWA)              │      o app vai ao ar aqui
                         └────────────┬─────────────┘
                              ┌───────┴────────┐
                              ▼                ▼
                  ┌────────────────────┐  ┌──────────────────────┐
                  │ M15 · Build 🤖     │  │ M16 · Build 🍎       │
                  │       Android      │  │       iOS            │
                  └─────────┬──────────┘  └──────────┬───────────┘
                            └────────┬───────────────┘
                                     ▼
                         ┌──────────────────────────┐
                         │ M17 · Publicação e       │
                         │       próximos passos    │
                         └──────────────────────────┘
```

**Leitura do diagrama em uma frase:** Dart antes de Flutter; Flutter na tela antes de estado;
estado antes de dados; dados antes de qualidade; qualidade antes do projeto final; e só então
build e publicação — **primeiro a web**, que é o canal que coloca o app no ar hoje, e depois
Android e iOS em paralelo, porque um não depende do outro.

**Caminhos que não são obrigatórios em sequência:**

- **M09 e M10** são irmãos: você pode fazer persistência antes de API se preferir ver o app
  funcionando offline primeiro. O plano de 30 dias faz API antes porque o projeto final
  usa a API só em uma aba.
- **M15 e M16** são independentes entre si. No Windows, faça M15 na prática e M16 como
  estudo dirigido.
- **M14 vem antes dos dois de propósito.** Ele é o único canal que você publica hoje, do
  Windows, sem pagar nada e sem revisão — e por isso é o canal principal do curso. M15 e M16
  acrescentam canais; nenhum substitui M14.
- **M07 aula 09 (`go_router`)** é a única aula explicitamente opcional do curso.

---

## Se você já sabe X, pode pular Y

> ⚠️ **Regra de ouro:** "pular" aqui significa **não ler linha a linha**. Você ainda precisa
> fazer a avaliação do módulo. Se não tirar o mínimo exigido, volte e leia. Conhecimento
> presumido é a origem mais comum de travamento na metade do curso.

| Se você já sabe… | Pode acelerar… | Mas NÃO pule de jeito nenhum… | Como confirmar antes de pular |
|---|---|---|---|
| Usar terminal e Git no dia a dia | [Módulo 00](modulos/00-git-e-terminal/README.md), aulas 01 a 04 | A aula [05 — Desfazendo erros e segredos](modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md), por causa do `.gitignore` de segredos Android | [Av. M00](avaliacoes/modulo-00-git-e-terminal.md) |
| Programar em Python ou Java | [Módulo 01](modulos/01-logica-e-fundamentos/README.md) inteiro | [10 — Lendo mensagens de erro](modulos/01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md), porque as mensagens do Dart são diferentes | [Av. M01](avaliacoes/modulo-01-logica-e-fundamentos.md) |
| Dart básico de terminal (`print`, `stdin`, variáveis) | [Módulo 02](modulos/02-dart-basico/README.md), aulas 01, 02 e 10 | [05 — Null safety](modulos/02-dart-basico/05-null-safety.md) e [03 — var, final e const](modulos/02-dart-basico/03-var-final-const.md); são a base de tudo que vem depois | [Av. M02](avaliacoes/modulo-02-dart-basico.md) |
| Orientação a objetos em outra linguagem | [Módulo 03](modulos/03-dart-intermediario/README.md), aulas 01 a 04 | [06 — Mixins](modulos/03-dart-intermediario/06-mixins.md), [08 — Generics](modulos/03-dart-intermediario/08-generics.md) e [09 — Extensions](modulos/03-dart-intermediario/09-extensions.md): Dart faz diferente | [Av. M03](avaliacoes/modulo-03-dart-intermediario.md) |
| `async`/`await` em JavaScript ou C# | [02 — Futures e async/await](modulos/04-dart-avancado/02-futures-e-async-await.md) em leitura rápida | [06 — Sealed classes](modulos/04-dart-avancado/06-sealed-classes.md) e [05 — Patterns e switch](modulos/04-dart-avancado/05-patterns-e-switch.md): são recursos recentes e o curso os usa muito | [Av. M04](avaliacoes/modulo-04-dart-avancado.md) |
| React, Vue ou Angular (UI declarativa) | [01 — Como o Flutter funciona](modulos/05-introducao-ao-flutter/01-como-o-flutter-funciona.md) | [07 — BuildContext](modulos/05-introducao-ao-flutter/07-buildcontext.md) e [06 — Ciclo de vida do State](modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md): não têm equivalente exato na web | [Av. M05](avaliacoes/modulo-05-introducao-ao-flutter.md) |
| CSS Flexbox | [04 — Row, Column e Expanded](modulos/06-widgets-e-layouts/04-row-column-expanded.md) em leitura rápida | [06 — Constraints](modulos/06-widgets-e-layouts/06-constraints.md): o modelo do Flutter **não** é Flexbox e essa é a causa nº 1 de erro de layout | [Av. M06](avaliacoes/modulo-06-widgets-e-layouts.md) |
| Provider ou BLoC | [01 — O problema do estado](modulos/08-estado-e-arquitetura/01-o-problema-do-estado.md) e [02 — Elevação de estado](modulos/08-estado-e-arquitetura/02-elevacao-de-estado.md) | [07 — AsyncNotifier e AsyncValue](modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md): o Riverpod 3 mudou bastante em relação ao 2 | [Av. M08](avaliacoes/modulo-08-estado-e-arquitetura.md) |
| Consumir APIs REST em back-end | [01 — HTTP e REST](modulos/09-consumo-de-api/01-http-e-rest.md) e [02 — JSON](modulos/09-consumo-de-api/02-json.md) | [06 — Timeout, retry e cancelamento](modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md): rede móvel cai, rede de servidor quase não | [Av. M09](avaliacoes/modulo-09-consumo-de-api.md) |
| SQL e bancos relacionais | [04 — sqflite: criando o banco](modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) em leitura rápida | [06 — Migrações](modulos/10-persistencia-de-dados/06-migracoes.md): no celular você não tem acesso ao banco para consertar na mão | [Av. M10](avaliacoes/modulo-10-persistencia-de-dados.md) |
| Testes automatizados em outra stack | [05 — Testes unitários](modulos/12-testes-e-debug/05-testes-unitarios.md) | [06 — Testes de widget](modulos/12-testes-e-debug/06-testes-de-widget.md): `pump` e `pumpAndSettle` não existem fora do Flutter | [Av. M12](avaliacoes/modulo-12-testes-e-debug.md) |
| Publicar apps Android nativos | [02 — Identidade do app](modulos/15-build-android/02-identidade-do-app.md) e [05 — Permissões Android](modulos/15-build-android/05-permissoes-android.md) | [07 — Assinatura no Gradle](modulos/15-build-android/07-assinatura-no-gradle.md): o Flutter 3.47 usa Kotlin DSL (`build.gradle.kts`) | [Av. M15](avaliacoes/modulo-15-build-android.md) |

**O que ninguém pula, em nenhuma hipótese:**

- [02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md) — sua máquina tem três
  problemas reais já reproduzidos (acento no caminho do SDK, Modo de Desenvolvedor desligado,
  Android SDK ausente).
- [Módulo 08](modulos/08-estado-e-arquitetura/README.md) — é o eixo do projeto final.
- [Módulo 14](modulos/14-build-web-pwa/README.md) — sem ele o Foco não vai ao ar: são os marcos 14 e 15.
- [Módulo 15](modulos/15-build-android/README.md) — sem ele não existem os marcos de APK e AAB.

---

## Pré-requisitos de cada módulo

| Módulo | Pré-requisitos obrigatórios | Ferramenta/ambiente necessário | Entregável ao fim |
|---|---|---|---|
| [00 — Git e terminal](modulos/00-git-e-terminal/README.md) | Nenhum | Windows 11, Git 2.46+, VS Code | Repositório local com commits e `.gitignore` |
| [01 — Lógica e fundamentos](modulos/01-logica-e-fundamentos/README.md) | M00 | Dart SDK 3.13.1 (vem no Flutter 3.47.1) | Programas de terminal resolvendo problemas simples |
| [02 — Dart básico](modulos/02-dart-basico/README.md) | M01 | Dart SDK 3.13.1 | Programa com listas, mapas e entrada do usuário |
| [03 — Dart intermediário](modulos/03-dart-intermediario/README.md) | M02 | Dart SDK 3.13.1 | Modelo de domínio com classes e contratos |
| [04 — Dart avançado](modulos/04-dart-avancado/README.md) | M03 | Dart SDK 3.13.1, `flutter analyze` | Código assíncrono tratando falhas com `sealed class` |
| [05 — Introdução ao Flutter](modulos/05-introducao-ao-flutter/README.md) | M04 · ambiente validado | Flutter 3.47.1 + emulador Android **ou** `-d windows` | Primeiro app rodando (marcos 6 e 7) |
| [06 — Widgets e layouts](modulos/06-widgets-e-layouts/README.md) | M05 | Flutter 3.47.1, hot reload | Telas com layout responsivo e tema Material 3 |
| [07 — Navegação e formulários](modulos/07-navegacao-e-formularios/README.md) | M06 | Flutter 3.47.1 | App multitelas com formulário validado (marcos 9 e 10) |
| [08 — Estado e arquitetura](modulos/08-estado-e-arquitetura/README.md) | M05, M06, M07 · `async/await` do M04 | `flutter_riverpod ^3.4.3` | Feature organizada em `presentation/domain/data` |
| [09 — Consumo de API](modulos/09-consumo-de-api/README.md) | M08 · JSON e `Future` | `http ^1.6.0` · internet · JSONPlaceholder | Lista vinda da API com estados de carregamento e erro (marco 11) |
| [10 — Persistência de dados](modulos/10-persistencia-de-dados/README.md) | M08 · classes do M03 | `sqflite ^2.4.4`, `shared_preferences ^2.5.5`, `path ^1.9.1`, `path_provider ^2.1.6`, `flutter_secure_storage ^11.1.1` | CRUD persistido entre execuções (marco 12) |
| [11 — Recursos nativos](modulos/11-recursos-nativos/README.md) | M09, M10 | 🤖 emulador ou aparelho real · `image_picker ^1.2.3`, `permission_handler ^13.0.2`, `connectivity_plus ^7.3.1` | App que pede permissão e reage à conexão |
| [12 — Testes e debug](modulos/12-testes-e-debug/README.md) | M08, M09, M10 | `flutter_test`, `integration_test`, `mocktail ^1.0.5`, `sqflite_common_ffi ^2.4.3` | Suíte de testes verde (marco 13) |
| [13 — Desempenho e segurança](modulos/13-desempenho-e-seguranca/README.md) | M12 | DevTools 2.60.0 · modo profile | App medido e ajustado, sem segredos no código |
| [14 — Build Web (PWA)](modulos/14-build-web-pwa/README.md) | Projeto final funcionando · M10 | Chrome ou Edge · conta no GitHub · `sqflite_common_ffi_web ^1.0.0`, `web ^1.1.1` | **PWA no ar, instalável e offline** (marcos 14 e 15) |
| [15 — Build Android](modulos/15-build-android/README.md) | M14 · Projeto final funcionando · JDK 17 Temurin | Android SDK instalado, licenças aceitas, `keytool` | APK debug, APK release assinado e AAB (marcos 16, 17 e 18) |
| [16 — Build iOS](modulos/16-build-ios/README.md) | Projeto final funcionando | 🍎 macOS + Xcode + CocoaPods + conta Apple | Archive e IPA (marcos 8, 19, 20, 21, 22 e 23) |
| [17 — Publicação e próximos passos](modulos/17-publicacao-e-proximos-passos/README.md) | M14, M15 (e M16, quando houver Mac) | Conta de desenvolvedor na loja desejada | Plano de publicação e versionamento |

> 🍎 **SÓ NO MAC.** O módulo 16 é o único cujos pré-requisitos você ainda não consegue atender
> no Windows 11. Leia-o mesmo assim: o conteúdo foi escrito para ser compreendido sem executar,
> e o marco correspondente fica aberto na [trilha de progresso](03-trilha-de-progresso.md) até
> você conseguir um Mac. A explicação técnica está em
> [modulos/16-build-ios/01-por-que-exige-macos.md](modulos/16-build-ios/01-por-que-exige-macos.md).

---

## Onde cada projeto puxa de volta os módulos

| Projeto | Módulos exigidos | Arquivo de entrada | Checklist final |
|---|---|---|---|
| P1 — Meu Primeiro App | M05 · M06 (parcial) | [01-especificacao.md](projetos/01-projeto-iniciante/01-especificacao.md) | [06-checklist.md](projetos/01-projeto-iniciante/06-checklist.md) |
| P2 — Bloco de Notas de Estudo | M05 · M06 · M07 · M10 (aula 02) · M12 (aulas 05 e 06) | [01-especificacao.md](projetos/02-projeto-intermediario/01-especificacao.md) | [06-checklist.md](projetos/02-projeto-intermediario/06-checklist.md) |
| P3 — Foco: Organizador de Estudos | M03 a M15 (tudo) | [01-especificacao.md](projetos/03-projeto-final-multiplataforma/01-especificacao.md) | [14-checklist.md](projetos/03-projeto-final-multiplataforma/14-checklist.md) |

Os desafios extras de cada projeto têm gabarito próprio:
[projeto 1](gabaritos/projeto-01-desafios.md) ·
[projeto 2](gabaritos/projeto-02-desafios.md) ·
[projeto 3](gabaritos/projeto-03-desafios.md).

---

| ⬅️ Anterior | 🏠 Início | ➡️ Próximo |
|---|---|---|
| [03 — Trilha de progresso](03-trilha-de-progresso.md) | [README](README.md) | [05 — Decisões técnicas](05-decisoes-tecnicas.md) |
