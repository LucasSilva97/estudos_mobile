# Referência — Próximos passos: plano de 90 dias

> **O que é este arquivo.** O curso termina no dia 30. Este é o plano dos **90 dias
> seguintes** — o período em que você deixa de "ter feito um curso" e passa a "saber
> trabalhar com Flutter". Metas por semana, trilhas de aprofundamento, projetos com escopo
> fechado, portfólio, código aberto, entrevista e manutenção.

> 🪟 Você continua no **Windows**. Tudo aqui é executável no seu PC, **menos** o que envolve
> gerar e publicar um app iOS. Onde isso aparecer, o item está marcado com 🍎 e traz a
> alternativa que você pode fazer agora.

---

## 0. Onde você está no dia 31

Ao terminar o curso você sabe, comprovadamente:

| Área | O que você já domina |
|---|---|
| Dart | Tipos, null safety, classes, `sealed`, `records`, `patterns`, `Future`, `Stream` |
| Flutter UI | Widgets, layout, constraints, temas, Material 3, listas, responsividade |
| Navegação | `Navigator` 1.0, rotas nomeadas, argumentos e retorno, formulários validados |
| Estado | Riverpod 3 sem geração de código: `Notifier`, `AsyncNotifier`, `AsyncValue`, `family` |
| Dados | `http` + JSON, `sqflite`, `shared_preferences`, `flutter_secure_storage` |
| Arquitetura | Feature-first em 3 camadas, injeção de dependências, contratos de repositório |
| Qualidade | `flutter analyze`, `dart format`, testes unitários, de widget e de integração, `mocktail` |
| Plataforma | 🤖 APK e AAB assinados · 🍎 o processo iOS inteiro, entendido e preparado |

**O que ainda falta e este plano cobre:** repetição sem apoio, volume de código próprio,
leitura de código dos outros, e a capacidade de terminar um projeto sem roteiro.

---

## 1. Como usar este plano

### Regras

1. **Ritmo alvo: 8 a 10 horas por semana.** Menos que isso, estique para 120 dias em vez de 90;
   o que não pode é parar.
2. **Toda semana termina com um commit.** Se não houve commit, a semana não aconteceu.
3. **Nada de curso novo nas 4 primeiras semanas.** O risco número um de quem terminou um
   curso é começar outro. O que falta agora é **produzir**, não consumir.
4. **Um projeto de cada vez**, com escopo escrito antes da primeira linha de código.
5. **Tudo que você escrever vai para o GitHub**, mesmo o que estiver feio.

### Como marcar progresso

Copie a tabela abaixo para um arquivo seu (fora deste repositório do curso) e preencha:

```text
| Semana | Meta | Entregue? | Commit | Observação |
|--------|------|-----------|--------|------------|
| 1      |      |           |        |            |
```

---

## 2. Fase 1 — Dias 1 a 30: consolidar sem ajuda

**Objetivo da fase:** provar para você mesmo que consegue escrever o que aprendeu **sem
consultar as aulas**.

### Semana 1 — Reescrever do zero

| | |
|---|---|
| **Meta** | Refazer o **Projeto 2 — Bloco de Notas** do zero, sem abrir o passo a passo |
| **Tempo** | 8 h |
| **Por quê** | Ler um roteiro e digitar é reconhecimento. Escrever do zero é recuperação — é o que fixa |

**Tarefas**

1. `flutter create --platforms=android,ios bloco_notas_v2`
2. Escreva as telas, a navegação com rotas nomeadas e a persistência em `shared_preferences`.
3. Só abra [projetos/02-projeto-intermediario/03-codigo-completo.md](../projetos/02-projeto-intermediario/03-codigo-completo.md)
   quando travar por mais de 20 minutos no mesmo ponto.
4. Ao final, compare o seu código com o do curso e anote as 3 maiores diferenças.

**Critérios de conclusão**
- [ ] O app cria, edita, lista e apaga notas.
- [ ] Os dados sobrevivem ao fechar e reabrir o app.
- [ ] `flutter analyze` sem nenhum aviso.
- [ ] Você abriu o gabarito no máximo 3 vezes.

---

### Semana 2 — Testes de verdade

| | |
|---|---|
| **Meta** | Levar o `bloco_notas_v2` a **80% de cobertura** na camada de dados e domínio |
| **Tempo** | 8 h |
| **Por quê** | Escrever teste depois do código é a habilidade que separa "faz app" de "mantém app" |

**Tarefas**

1. Um teste unitário para cada método público do repositório, com `mocktail`.
2. Testes de widget para: lista vazia, lista com itens, erro, formulário inválido.
3. Um teste de integração que cria uma nota e verifica que ela aparece na lista.
4. Meça a cobertura:

```powershell
flutter test --coverage
```

**Critérios de conclusão**
- [ ] `flutter test` passa, sem teste marcado como pulado.
- [ ] Nenhum teste depende de rede ou de aparelho.
- [ ] Você conseguiu quebrar o app de propósito e um teste acusou.

---

### Semana 3 — Ampliar o projeto final

| | |
|---|---|
| **Meta** | Adicionar **uma funcionalidade nova** ao app **Foco**, do início ao fim |
| **Tempo** | 10 h |
| **Por quê** | Mexer em código existente é 90% do trabalho real. Criar do zero é a exceção |

**Escolha uma:**

| Funcionalidade | O que exercita |
|---|---|
| Etiquetas (tags) em matérias, com filtro | Nova tabela, migração, relação 1-N, filtro reativo |
| Histórico de sessões com busca por período | `WHERE` com datas, `intl` para formatar, estado derivado |
| Exportar estatísticas para um arquivo `.csv` | `path_provider`, escrita de arquivo, compartilhamento |
| Lembrete diário de estudo | Ciclo de vida do app, permissões, agendamento |

**Critérios de conclusão**
- [ ] A funcionalidade tem domínio, dados e apresentação separados (feature-first).
- [ ] Existe migração de banco versionada, se você mexeu no esquema.
- [ ] Existem testes da camada de dados nova.
- [ ] `flutter build apk --release` gera um APK que instala e funciona no seu celular.

---

### Semana 4 — Ler código dos outros

| | |
|---|---|
| **Meta** | Ler, rodar e **descrever** um app Flutter open source de porte médio |
| **Tempo** | 8 h |
| **Por quê** | Você aprendeu um estilo (o do curso). Precisa ver outros para saber o que é escolha e o que é regra |

**Tarefas**

1. Escolha um projeto Flutter open source com pelo menos 500 estrelas no GitHub e commits
   recentes.
2. Clone, rode (`flutter pub get`, `flutter run`).
3. Escreva um documento de 1 página respondendo:
   - Como as pastas estão organizadas? É feature-first, camada-first ou outra coisa?
   - Qual solução de estado usam? Por quê, na sua leitura?
   - Onde fica a chamada de rede? Existe camada de repositório?
   - O que você faria diferente e por quê?

**Critérios de conclusão**
- [ ] O projeto rodou na sua máquina.
- [ ] Você conseguiu achar, sozinho, onde uma tela específica é construída.
- [ ] O documento de 1 página está escrito.

---

## 3. Fase 2 — Dias 31 a 60: aprofundar

**Objetivo da fase:** sair do "sei o básico de tudo" para "sei bem duas ou três coisas".
Escolha **duas trilhas** da seção 5 e distribua nas semanas 5 a 8.

### Semana 5 — Trilha A (a que você escolheu como principal)

| | |
|---|---|
| **Meta** | Estudar a trilha principal e aplicá-la num app de laboratório pequeno |
| **Tempo** | 10 h |
| **Entregável** | Um repositório `lab-<nome-da-trilha>` com pelo menos 3 exemplos comentados |

### Semana 6 — Trilha A aplicada no Foco

| | |
|---|---|
| **Meta** | Levar a trilha para dentro do app **Foco**, não deixar em laboratório |
| **Tempo** | 10 h |
| **Critério** | A funcionalidade nova está testada e o `flutter analyze` continua limpo |

### Semana 7 — Trilha B (a secundária)

| | |
|---|---|
| **Meta** | Mesma coisa da semana 5, para a segunda trilha |
| **Tempo** | 10 h |
| **Entregável** | Repositório `lab-<trilha-b>` |

### Semana 8 — Consolidação e escrita

| | |
|---|---|
| **Meta** | Escrever um texto técnico explicando o que você aprendeu nas trilhas |
| **Tempo** | 8 h |
| **Por quê** | Explicar é o teste mais honesto de compreensão. E vira portfólio |

**Critérios de conclusão da Fase 2**
- [ ] Duas trilhas estudadas, com laboratório público.
- [ ] Pelo menos uma delas incorporada ao app Foco.
- [ ] Um texto técnico publicado (README detalhado, artigo, ou documento no repositório).

---

## 4. Fase 3 — Dias 61 a 90: projeto próprio e visibilidade

**Objetivo da fase:** um app **seu**, do zero, publicado, que você pode mostrar a um
recrutador ou cliente.

### Semana 9 — Escopo e fundação

| | |
|---|---|
| **Meta** | Escolher o projeto (seção 6), escrever a especificação e montar o esqueleto |
| **Tempo** | 10 h |

**Entregáveis**
- [ ] Documento de escopo: problema, usuário, 5 telas no máximo, o que fica **fora**.
- [ ] Repositório criado, `.gitignore` correto, `analysis_options.yaml` com `flutter_lints`.
- [ ] Estrutura de pastas feature-first pronta.
- [ ] `applicationId` / Bundle ID definidos (`br.com.<voce>.<app>`), `version: 1.0.0+1`.

### Semana 10 — Domínio e dados

| | |
|---|---|
| **Meta** | Modelos, contratos de repositório, DAO, banco, testes da camada de dados |
| **Tempo** | 10 h |
| **Critério** | A camada de dados está 100% testada **sem emulador**, com `sqflite_common_ffi` |

### Semana 11 — Estado e telas

| | |
|---|---|
| **Meta** | Providers, telas, navegação, estados de carregando/vazio/erro em todas as listas |
| **Tempo** | 12 h |
| **Critério** | Nenhuma tela mostra tela branca em erro; todas tratam os três estados |

### Semana 12 — Acabamento

| | |
|---|---|
| **Meta** | Ícone, splash, tema claro/escuro, acessibilidade, responsividade, textos revisados |
| **Tempo** | 10 h |

```powershell
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter clean
flutter build appbundle
```

**Critérios**
- [ ] Ícone adaptativo no Android e ícone sem canal alfa para iOS.
- [ ] Modo escuro funcionando.
- [ ] Alvos de toque com pelo menos 48×48 lógicos.
- [ ] Nenhum texto quebrado em tela de 320 px de largura.

### Semana 13 — Publicar e apresentar

| | |
|---|---|
| **Meta** | 🤖 Publicar na Google Play (ou distribuir o APK) e escrever o README do portfólio |
| **Tempo** | 10 h |

**Entregáveis**
- [ ] AAB assinado com **o seu** keystore (nunca a chave de debug).
- [ ] README com: prints das telas, o que o app faz, as decisões técnicas e como rodar.
- [ ] 🍎 Um documento `IOS.md` no repositório listando o que já está preparado para iOS e o
      que falta executar num Mac. Isso mostra que você entende o processo mesmo sem ter
      publicado.

> 🍎 **SÓ NO MAC.** Publicar na App Store exige macOS + Xcode + Apple Developer Program
> (US$ 99/ano). Não prometa a ninguém — nem a você — um IPA gerado no Windows: isso não
> existe. O que você consegue hoje é deixar o projeto **pronto para o dia do Mac**, e isso é
> um diferencial real. Veja
> [15-build-ios/01-por-que-exige-macos.md](../modulos/15-build-ios/01-por-que-exige-macos.md).

---

## 5. Trilhas de aprofundamento

Escolha por necessidade, não por curiosidade. A pergunta certa é: *o que o meu próximo
projeto exige?*

### Trilha A — Animações e movimento

| | |
|---|---|
| **Quando vale** | Seu app funciona mas parece "duro". Transições secas, listas que saltam |
| **Tempo** | 12 a 16 h |

**O que estudar, nesta ordem**

1. **Animações implícitas** — `AnimatedContainer`, `AnimatedOpacity`, `AnimatedAlign`,
   `AnimatedSwitcher`. Você muda um valor e o Flutter anima sozinho. Resolve 70% dos casos.
2. **`TweenAnimationBuilder`** — animação implícita com controle do intervalo de valores.
3. **Animações explícitas** — `AnimationController` + `TickerProviderStateMixin` +
   `AnimatedBuilder`. Aqui você controla início, fim, reversão e repetição.
4. **`Curves`** — `easeInOut`, `easeOutCubic`, `elasticOut`. O que faz o movimento parecer
   natural não é a duração, é a curva.
5. **`Hero`** — o elemento que "voa" de uma tela para outra.
6. **Transições de rota personalizadas** — `PageRouteBuilder` com `FadeTransition` ou
   `SlideTransition`.

**Armadilhas**
- Sempre `dispose()` do `AnimationController`, senão vaza memória.
- Animação acima de ~300 ms começa a parecer lenta em UI de aplicativo.
- Respeite `MediaQuery.of(context).disableAnimations` (acessibilidade: há quem sinta enjoo).

**Você sabe que aprendeu quando** consegue fazer um item de lista entrar deslizando e
desaparecer com fade, sem travar a rolagem, e o `flutter analyze` continua limpo.

---

### Trilha B — Internacionalização (i18n) com `intl` e `flutter_localizations`

| | |
|---|---|
| **Quando vale** | Você quer o app em mais de um idioma, ou quer formatar data/número corretamente |
| **Tempo** | 8 a 12 h |

**Conceitos**
- **i18n** (*internationalization*) = preparar o app para ser traduzido.
- **l10n** (*localization*) = traduzir de fato para um idioma.
- **Locale** = a combinação idioma + região (`pt_BR`, `en_US`).
- **ARB** (*Application Resource Bundle*) = o formato de arquivo JSON onde ficam as traduções.

**Passo a passo**

1. Adicione as dependências. `flutter_localizations` vem do SDK:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

flutter:
  generate: true
```

2. Crie `l10n.yaml` na raiz do projeto:

```yaml
arb-dir: lib/l10n
template-arb-file: app_pt.arb
output-localization-file: app_localizations.dart
```

3. Crie `lib/l10n/app_pt.arb`:

```json
{
  "@@locale": "pt",
  "tituloMaterias": "Matérias",
  "minutosEstudados": "{minutos} minutos estudados",
  "@minutosEstudados": {
    "placeholders": {
      "minutos": { "type": "int" }
    }
  }
}
```

4. Gere as classes:

```powershell
flutter gen-l10n
```

5. Ligue no `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const HomeScreen(),
);
```

6. Use no widget:

```dart
Text(AppLocalizations.of(context)!.tituloMaterias);
```

**Formatação com `intl` (útil mesmo com um idioma só)**

```dart
import 'package:intl/intl.dart';

final data = DateFormat('dd/MM/yyyy', 'pt_BR').format(DateTime.now());
final minutos = NumberFormat.decimalPattern('pt_BR').format(1250);
```

**Armadilhas**
- `initializeDateFormatting('pt_BR')` é necessário antes de usar formatos com locale fora do
  padrão do sistema.
- Nunca concatene strings traduzidas (`'Você tem ' + n + ' notas'`). Use *placeholders* no ARB,
  porque a ordem das palavras muda entre idiomas.
- Plural e gênero têm sintaxe própria no ARB (`{count, plural, =0{...} =1{...} other{...}}`).

**Você sabe que aprendeu quando** troca o idioma do celular e o app inteiro muda, incluindo
datas e números, sem nenhum texto em inglês sobrando.

---

### Trilha C — Arquitetura avançada

| | |
|---|---|
| **Quando vale** | Seu projeto passou de ~30 arquivos e você começou a ter medo de mexer |
| **Tempo** | 16 a 24 h |

**O que estudar**

1. **Clean Architecture aplicada ao Flutter** — entenda o que ela resolve (dependências
   apontando para dentro) e o que ela **cobra** (muito mais arquivos). Nem todo app precisa.
2. **Casos de uso (*use cases*)** — uma classe por ação do usuário. Vale quando a regra de
   negócio é complexa; vira burocracia quando o caso de uso só repassa a chamada.
3. **Result / Either** — devolver erro como valor em vez de exceção. No curso você já viu a
   base disso: `sealed class` + `switch` exaustivo.
4. **Modularização** — quebrar o app em pacotes locais (`packages/core`, `packages/features`)
   com `path:` no `pubspec.yaml`. Compila mais rápido e força limites reais.
5. **Feature flags e ambientes** — *flavors* do Flutter para separar desenvolvimento,
   homologação e produção.
6. **Camada de apresentação sem `BuildContext` na lógica** — o Riverpod já entrega isso.

**Critério de bom senso:** arquitetura boa é a que torna a **próxima** mudança barata. Se você
precisa tocar em 6 arquivos para adicionar um campo, a arquitetura está trabalhando contra você.

**Você sabe que aprendeu quando** consegue justificar, por escrito, **por que não** aplicou
uma camada em um projeto pequeno.

---

### Trilha D — Backend

| | |
|---|---|
| **Quando vale** | Você quer dados compartilhados entre aparelhos, login real ou sincronização |
| **Tempo** | 20 a 30 h |

**Dois caminhos, escolha um**

| Caminho | O que é | Vantagem | Custo |
|---|---|---|---|
| **BaaS** (*Backend as a Service*) | Um serviço pronto: banco, autenticação, arquivos e notificações | Você entrega em dias | Você depende do fornecedor e do modelo de preços |
| **API própria** | Você escreve o servidor (Dart, Node, Python, Java...) | Controle total, aprendizado maior | Você mantém servidor, banco, segurança e deploy |

**Se escolher API própria, o caminho mais curto para quem já sabe Dart** é escrever o servidor
**em Dart**: você reaproveita a linguagem, o `pubspec.yaml`, as classes de modelo e até o
`sealed class` de erro.

**O que estudar, independentemente do caminho**

1. **Autenticação** — o que é um token, o que é um *refresh token*, onde guardar
   (`flutter_secure_storage`, nunca em `shared_preferences`).
2. **Sincronização offline-first** — fila de operações pendentes, resolução de conflito,
   marca de "atualizado em".
3. **Paginação** — `limit`/`offset` ou cursor; carregar mais ao chegar no fim da lista.
4. **Tratamento de erro de rede** — você já viu no módulo 09: `timeout`, `SocketException`,
   `FormatException`, códigos HTTP.
5. **Segurança** — HTTPS sempre, nunca embutir segredo no app (o APK pode ser descompilado),
   validar tudo no servidor.

> 🔴 **Nunca** coloque API key, senha de banco ou segredo de servidor dentro do app. Qualquer
> pessoa consegue extrair strings de um APK. Segredo mora no servidor. Se um serviço exige uma
> chave no cliente, ela precisa ser uma chave **pública e restrita por domínio/pacote**.

**Você sabe que aprendeu quando** o seu app funciona com o modo avião ligado (mostrando dados
em cache) e sincroniza sozinho quando a conexão volta.

---

### Trilha E — Flutter web e desktop

| | |
|---|---|
| **Quando vale** | Você quer aproveitar o mesmo código para navegador, Windows, macOS ou Linux |
| **Tempo** | 10 a 16 h |

**O que muda de verdade**

| Tema | Mobile | Web | Desktop |
|---|---|---|---|
| Entrada | Toque | Mouse, teclado, toque | Mouse e teclado |
| Tela | Estreita, uma coisa por vez | Larga, redimensionável | Larga, janela redimensionável |
| Navegação | Pilha | **URL na barra de endereços** | Pilha, com atalhos de teclado |
| `dart:io` | Funciona | ❌ **Não funciona** | Funciona |
| `sqflite` | Funciona | ❌ Precisa de alternativa | Precisa de `sqflite_common_ffi` |
| Primeiro carregamento | Instantâneo | Baixa o app inteiro; cuide do tamanho | Instantâneo |

**O que estudar**

1. **Layout adaptativo** — `LayoutBuilder`, `MediaQuery`, pontos de quebra; painel mestre +
   detalhe em telas largas.
2. **Atalhos e foco** — `Shortcuts`, `Actions`, `Focus`, navegação por Tab.
3. **Rotas ligadas à URL** — no web, o usuário espera que o botão voltar do navegador
   funcione e que a URL possa ser colada. É aqui que o `go_router` (aula opcional
   [07-navegacao-e-formularios/09-go-router-opcional.md](../modulos/07-navegacao-e-formularios/09-go-router-opcional.md))
   passa a valer muito mais que o `Navigator` 1.0.
4. **Condicionais de plataforma** — `kIsWeb` do `package:flutter/foundation.dart` antes de
   qualquer coisa que toque em `dart:io`.

```powershell
flutter run -d chrome
flutter run -d windows
```

**Você sabe que aprendeu quando** o mesmo código roda no celular e no navegador, e no
navegador a URL muda ao navegar e o botão voltar funciona.

---

### Trilha F — Outras soluções de estado

| | |
|---|---|
| **Quando vale** | Você vai entrar em um time que usa outra coisa, ou quer entender o Riverpod por contraste |
| **Tempo** | 10 a 14 h |

| Solução | Ideia central | Quando você vai encontrar |
|---|---|---|
| **`provider`** | `InheritedWidget` com açúcar sintático; depende do `BuildContext` | Muito código legado. É o antecessor do Riverpod, do mesmo autor |
| **`flutter_bloc`** | Eventos entram, estados saem, tudo explícito e rastreável | Times grandes e empresas; ótimo para auditar o que aconteceu |
| **`signals`** | Valores reativos de granularidade fina, inspirados em frameworks web | Projetos novos que querem rebuilds mínimos |
| **`ValueNotifier` / `ListenableBuilder`** | Vem no SDK, zero dependência | Estado local muito simples |

**Como estudar sem se perder:** implemente **a mesma tela** (uma lista que carrega de uma API,
com estados de carregando/erro/dados) nas quatro abordagens, no mesmo repositório. Compare
linhas de código, testabilidade e clareza. A comparação inicial está em
[08-estado-e-arquitetura/04-por-que-riverpod.md](../modulos/08-estado-e-arquitetura/04-por-que-riverpod.md).

**Você sabe que aprendeu quando** consegue dizer, sem torcer o nariz, em que situação **outra**
solução seria melhor que o Riverpod.

---

## 6. Ideias de projeto com escopo definido

Todos foram desenhados para caber em 3 a 5 semanas de estudo em meio período. O escopo é
fechado de propósito: **projeto que não termina não vira portfólio**.

### Projeto 1 — Controle de gastos pessoais

| | |
|---|---|
| **Dificuldade** | Média |
| **Prazo alvo** | 3 semanas |
| **Exercita** | sqflite com duas tabelas, agregações SQL, gráficos, `intl` para moeda |

**Escopo — dentro**
- Cadastro de categorias (nome, cor, ícone).
- Lançamento de despesa: valor, data, categoria, descrição.
- Lista do mês corrente com total no topo.
- Tela de resumo: total por categoria, com barras proporcionais.
- Tema claro/escuro.

**Escopo — fora (não faça)**
- Login, nuvem, sincronização, múltiplos usuários, receitas recorrentes, importação bancária.

**Critérios de conclusão**
- [ ] `flutter analyze` sem avisos e `flutter test` verde.
- [ ] Camada de dados testada com `sqflite_common_ffi`, sem emulador.
- [ ] Ordenação de categorias correta em português (cuidado com o `ORDER BY`!).
- [ ] Valores formatados como `R$ 1.234,56`.
- [ ] APK release assinado instalado no seu celular, usado por 7 dias seguidos.

---

### Projeto 2 — Leitor de uma API pública que você gosta

| | |
|---|---|
| **Dificuldade** | Média |
| **Prazo alvo** | 3 semanas |
| **Exercita** | `http`, JSON, paginação, cache offline, busca, tratamento de erro |

**Escopo — dentro**
- Lista paginada vinda de uma API pública, com carregamento ao chegar no fim.
- Busca com *debounce* (esperar o usuário parar de digitar antes de chamar a API).
- Tela de detalhe.
- Favoritos salvos localmente em sqflite.
- Cache: se estiver offline, mostra a última lista baixada e avisa que está desatualizada.

**Escopo — fora**
- Login, comentários, envio de conteúdo, notificações.

**Critérios de conclusão**
- [ ] Funciona com o modo avião ligado (mostrando cache) e avisa o usuário.
- [ ] Todo `http` tem `.timeout(Duration(seconds: 15))` e trata `TimeoutException`,
      `SocketException` e `FormatException`.
- [ ] Os três estados (carregando, erro, vazio) têm tela própria, nunca tela branca.
- [ ] A camada de dados é testada com `mocktail`, sem chamar a rede de verdade.

---

### Projeto 3 — Checklists reutilizáveis

| | |
|---|---|
| **Dificuldade** | Fácil a média |
| **Prazo alvo** | 2 semanas |
| **Exercita** | Modelagem, reordenação por arrastar, compartilhamento, migração de banco |

**Escopo — dentro**
- Criar modelos de checklist (ex.: "mala de viagem", "revisão antes de publicar app").
- Instanciar um modelo e marcar itens; a instância não altera o modelo.
- Reordenar itens arrastando (`ReorderableListView`).
- Exportar uma checklist como texto para compartilhar.

**Escopo — fora**
- Colaboração, nuvem, anexos.

**Critérios de conclusão**
- [ ] Modelo e instância são tabelas separadas, com migração v1→v2 testada.
- [ ] A reordenação persiste depois de fechar o app.
- [ ] Teste de widget cobrindo a reordenação.

---

### Projeto 4 — Diário com fotos

| | |
|---|---|
| **Dificuldade** | Média a difícil |
| **Prazo alvo** | 4 semanas |
| **Exercita** | `image_picker`, `permission_handler`, `path_provider`, arquivos, permissões nas duas plataformas |

**Escopo — dentro**
- Entrada de diário com texto, data e até 3 fotos.
- Fotos copiadas para a pasta do app (não referenciar o caminho original da galeria).
- Linha do tempo com miniaturas.
- Bloqueio por PIN guardado em `flutter_secure_storage`.

**Escopo — fora**
- Backup na nuvem, biometria, edição de imagem.

**Critérios de conclusão**
- [ ] Permissões declaradas corretamente no `AndroidManifest.xml` **e** no `Info.plist`, com
      textos específicos e em português.
- [ ] O app não quebra se o usuário negar a permissão — mostra explicação e um caminho.
- [ ] As imagens sobrevivem a reiniciar o app; o caminho salvo é relativo à pasta do app.
- [ ] O PIN é limpo na primeira execução após reinstalar (lembre do Keychain 🍎).

---

### Projeto 5 — Reescrever o Foco do zero, do seu jeito

| | |
|---|---|
| **Dificuldade** | Média |
| **Prazo alvo** | 3 semanas |
| **Exercita** | Tudo. E a sua capacidade de decidir sem roteiro |

**Regra:** mesmas funcionalidades do projeto final do curso, **arquitetura escolhida por
você**, com um documento explicando cada decisão e por que difere da do curso.

**Critérios de conclusão**
- [ ] Documento de decisões escrito **antes** do código.
- [ ] Pelo menos uma decisão diferente da do curso, justificada.
- [ ] Testes cobrindo domínio e dados.
- [ ] Você consegue defender cada escolha em voz alta por 2 minutos.

---

## 7. Como montar portfólio

Recrutador e cliente olham pouco tempo. Três projetos bem apresentados valem mais que dez
repositórios abandonados.

### O que um repositório de portfólio precisa ter

| Item | Por quê |
|---|---|
| **README com prints** | É a primeira e às vezes única coisa que a pessoa abre |
| **Uma frase dizendo o que o app faz** | No topo, antes de qualquer coisa técnica |
| **Seção "decisões técnicas"** | Mostra que você escolheu, não copiou |
| **Como rodar** | `flutter pub get` + `flutter run`, com a versão do Flutter usada |
| **Link do APK** ou da loja | Deixa a pessoa experimentar sem compilar |
| **Badge/print do `flutter analyze` e `flutter test` limpos** | Prova de disciplina |
| **Histórico de commits com mensagens legíveis** | Mostra como você trabalha |
| **Licença** | Um projeto sem licença é "todos os direitos reservados" |

### Modelo de README

```text
# Nome do App

Uma frase: o que resolve e para quem.

## Telas
(3 a 5 prints, em linha)

## Funcionalidades
- ...

## Como rodar
flutter --version   # Flutter 3.47.1
flutter pub get
flutter run

## Decisões técnicas
| Decisão | Alternativa considerada | Por que escolhi |
|---|---|---|
| Riverpod 3 sem code generation | provider, flutter_bloc | ... |

## Arquitetura
(um parágrafo + a árvore de pastas)

## Testes
flutter test   # N testes

## Status da plataforma
- Android: publicado / APK disponível
- iOS: projeto preparado (Bundle ID, Info.plist, ícones); build pendente de macOS
```

### O que **não** colocar no portfólio

- Projeto de tutorial idêntico ao do vídeo/curso, sem nada seu.
- Repositório com `TODO` no README.
- Screenshot do emulador com a barra de status de teste.
- 🔴 **Nunca** um keystore, um `key.properties`, um `.p12`, um `.mobileprovision`, um Team ID
  ou uma API key. Use sempre `SUA_SENHA_AQUI`, `SEU_ALIAS`, `SEU_TEAM_ID`, `<seu-usuario>`.

### Presença mínima

- **GitHub** com foto, bio de uma linha e os 3 projetos fixados no topo do perfil.
- **Um texto técnico** escrito por você — pode ser o próprio README longo. Serve como amostra
  de comunicação, que é metade do trabalho.

---

## 8. Como contribuir com código aberto

Contribuir é a forma mais rápida de aprender a ler código dos outros e a receber revisão de
verdade — de graça.

### Caminho progressivo (não pule etapas)

| Etapa | O que fazer | Tempo típico |
|---|---|---|
| 1 | Use um pacote e **leia o código-fonte** dele no GitHub | 1 h |
| 2 | Abra uma **issue** bem escrita quando encontrar bug (com versão, passos, código mínimo) | 30 min |
| 3 | Corrija **documentação**: um typo, um exemplo desatualizado, uma tradução | 1 h |
| 4 | Melhore um **exemplo** ou adicione um **teste** que faltava | 3 h |
| 5 | Corrija um bug pequeno marcado como `good first issue` | 1 dia |
| 6 | Proponha uma funcionalidade pequena, **depois de discutir em uma issue** | 1 semana |

### O fluxo técnico

```bash
git clone https://github.com/<dono>/<repositorio>.git
git checkout -b corrige-exemplo-do-readme
# edite
flutter analyze
flutter test
git add .
git commit -m "docs: corrige exemplo desatualizado do README"
git push origin corrige-exemplo-do-readme
```

Depois, abra o *pull request* pela interface do GitHub. O guia oficial está em
<https://docs.github.com/en/pull-requests>.

### Regras não escritas

1. **Leia o `CONTRIBUTING.md` antes de qualquer coisa.** Se existir, é lei.
2. **Um PR, um assunto.** PR que corrige bug e reformata 40 arquivos não é revisado.
3. **Rode `flutter analyze` e `flutter test` antes de enviar.** Sempre.
4. **Siga o estilo do projeto**, não o seu. Mesmo que você discorde.
5. **Responda à revisão sem defensividade.** Revisão é sobre o código, não sobre você.
6. **Aceite o "não".** Manter um projeto é dizer não a muita coisa boa.

### Onde procurar

- Os pacotes que você **já usa** neste curso: [pub.dev](https://pub.dev) traz o link do
  repositório de cada um.
- A própria documentação do Flutter aceita correções e traduções:
  <https://docs.flutter.dev>.
- Filtre issues por rótulos como `good first issue` e `help wanted`.

---

## 9. O que estudar para uma entrevista de Flutter

### Dart

| Tema | O que te perguntam |
|---|---|
| `final` × `const` | A diferença é **quando** o valor é conhecido: `const` em tempo de compilação, `final` em tempo de execução |
| Null safety | O que `?`, `!`, `late` e `??` significam; por que `!` é perigoso |
| `Future` × `Stream` | Um valor futuro × vários valores ao longo do tempo |
| `async`/`await` | O que acontece com o *event loop*; por que `await` não cria thread |
| Isolates | Paralelismo real, sem memória compartilhada; quando usar `compute` |
| `==` e `hashCode` | Por que precisam andar juntos; o que quebra em `Set` e `Map` se você só sobrescrever um |
| `sealed class` + `switch` | Como o compilador garante exaustividade |
| `records` e `patterns` | Devolver múltiplos valores e desestruturar |

### Flutter

| Tema | O que te perguntam |
|---|---|
| Widget × Element × RenderObject | Widget é a **descrição** imutável; Element é a instância na árvore; RenderObject faz layout e pintura |
| `StatelessWidget` × `StatefulWidget` | Quando o estado é do widget e quando é de fora |
| Ciclo de vida do `State` | `initState`, `didChangeDependencies`, `build`, `didUpdateWidget`, `dispose` |
| `BuildContext` | O que é (a posição na árvore), e por que usar `context` depois de um `await` é arriscado |
| `const` em widgets | Evita reconstrução; é o ganho de desempenho mais barato que existe |
| `Key` | `ValueKey`, `ObjectKey`, `GlobalKey`; por que listas reordenáveis precisam de key |
| Constraints | "Constraints go down, sizes go up, parent sets position" |
| `ListView` × `ListView.builder` | Construção preguiçosa: por que builder é obrigatório em listas grandes |
| `setState` | O que ele faz de verdade (marca o elemento como sujo) |
| Hot reload × hot restart | Reload preserva o estado; restart zera |

### Estado e arquitetura

| Tema | O que te perguntam |
|---|---|
| Por que não `setState` em tudo | Estado compartilhado, testabilidade, acoplamento à árvore |
| Riverpod | `Provider`, `FutureProvider`, `Notifier`, `AsyncNotifier`, `AsyncValue`, `family`, `autoDispose` |
| `AsyncValue` | Como ele modela carregando/erro/dados em um único tipo |
| Injeção de dependências | Por que o DAO recebe o `Database` pelo construtor (é o que o torna testável) |
| Camadas | O que é regra de negócio, o que é acesso a dado, o que é apresentação |

### Dados, testes e plataforma

| Tema | O que te perguntam |
|---|---|
| Quando usar sqflite × shared_preferences × secure storage | Estruturado × chave-valor × sensível |
| Tratamento de erro de rede | `timeout`, `SocketException`, `FormatException`, códigos HTTP |
| Tipos de teste | Unitário, de widget, de integração — e o custo/benefício de cada um |
| Mock × fake × stub | O que cada um é e quando usar `mocktail` |
| APK × AAB | Por que a Play exige AAB |
| `versionName` × `versionCode` | E que os dois saem de `version: 1.0.0+1` |
| Diferenças Android × iOS | Use a [tabela-resumo](diferencas-android-ios.md#15--tabela-resumo--uma-página) |

### Como se preparar de verdade

1. **Explique em voz alta.** Se você não consegue explicar `BuildContext` falando por 2
   minutos, você não sabe ainda.
2. **Tenha um projeto que você conhece de cor.** Metade da entrevista costuma ser sobre ele:
   "por que você escolheu isso?", "o que você faria diferente?".
3. **Prepare respostas honestas para o que você não sabe.** "Não usei em produção, mas entendo
   que serve para X" é uma resposta boa. Inventar é a única resposta ruim.
4. **Treine ler código na frente de alguém.** Muitas entrevistas dão um trecho e perguntam
   "o que está errado aqui?".
5. **Revise as avaliações cumulativas do curso**, em
   [avaliacoes/README.md](../avaliacoes/README.md) — elas foram escritas nesse formato.

---

## 10. Manutenção: mantendo você e o projeto atualizados

Flutter lança versões com frequência. Um projeto parado por 12 meses vira um projeto que não
compila. Manutenção é rotina, não emergência.

### 10.1 Rotina sugerida

| Frequência | O que fazer |
|---|---|
| **Semanal** | `flutter pub outdated` em um projeto ativo, só para olhar |
| **Mensal** | Atualizar dependências de correção e menores; rodar a suíte de testes |
| **A cada versão estável do Flutter** | Ler as release notes, atualizar em uma branch separada |
| **Trimestral** | Revisar `analysis_options.yaml`, `flutter_lints` e dívidas técnicas anotadas |
| **Antes de cada publicação** | `flutter clean`, build de release, teste em aparelho físico |

### 10.2 Acompanhar releases do Flutter

| Onde | O que tem |
|---|---|
| <https://docs.flutter.dev/release/release-notes> | O que mudou em cada versão, do mais novo para o mais antigo |
| <https://docs.flutter.dev/release/breaking-changes> | A lista do que **quebra** código, com guia de migração |
| <https://docs.flutter.dev/release/upgrade> | O procedimento oficial de atualização |

**Como ler uma release note sem gastar uma tarde:**

1. Vá direto à seção de **breaking changes**. Se não houver nenhuma que te afete, o resto é
   bônus.
2. Procure pelas palavras: `deprecated`, `removed`, `renamed`, `Android`, `iOS`, `Gradle`.
3. Anote o que afeta o seu projeto. Ignore o que é de plataforma que você não usa.
4. Só então leia as novidades — elas são o motivo de atualizar, mas não o risco.

### 10.3 Atualizar o Flutter com segurança

```powershell
# 1. Veja onde você está
flutter --version

# 2. Garanta que o projeto está limpo e commitado
git status

# 3. Crie uma branch só para a atualização
git checkout -b atualiza-flutter

# 4. Atualize o SDK
flutter upgrade

# 5. Limpe o cache de build (obrigatório após trocar de versão)
flutter clean
flutter pub get

# 6. Verifique
flutter analyze
flutter test
flutter build apk --debug
```

> ⚠️ **Nunca atualize o Flutter com trabalho não commitado.** Se a atualização quebrar algo,
> você precisa poder voltar com `git checkout`.
>
> 🪟 E lembre: o SDK do Flutter **não pode** ficar em um caminho com acento ou espaço. Se o seu
> ainda estiver em `C:\Users\Usuário\Documents\flutter`, mova para `C:\src\flutter` **antes**
> de atualizar. O motivo e o passo a passo estão em
> [02-configuracao-do-ambiente.md](../02-configuracao-do-ambiente.md) e em
> [erros-comuns.md](erros-comuns.md).

### 10.4 Atualizar dependências

**Passo 1 — ver o que está desatualizado:**

```powershell
flutter pub outdated
```

A saída tem quatro colunas. Entenda cada uma:

| Coluna | Significa |
|---|---|
| **Current** | A versão que o `pubspec.lock` está usando agora |
| **Upgradable** | A versão mais alta que **cabe** no intervalo do seu `pubspec.yaml` (`^2.5.5` aceita até antes de `3.0.0`) |
| **Resolvable** | A versão mais alta possível se você **afrouxar** os limites |
| **Latest** | A última publicada no pub.dev |

**Passo 2 — atualizações seguras (dentro do `^`):**

```powershell
flutter pub upgrade
```

Isso move `Current` até `Upgradable`. Pelo versionamento semântico, essas versões **não
deveriam** quebrar nada. Mesmo assim, rode `flutter test`.

**Passo 3 — atualizações de versão maior (podem quebrar):**

```powershell
flutter pub upgrade --major-versions
```

Este comando **reescreve o seu `pubspec.yaml`**, subindo os limites para as versões
`Resolvable`. É o caminho para sair de `^2.x` para `^3.x`.

> ⚠️ Faça isso **em uma branch separada**, um pacote grande de cada vez quando possível, e
> leia o **`Changelog`** de cada pacote que subiu de versão maior. É lá que está escrito o que
> mudou de nome e o que foi removido.

**Passo 4 — deixar o Dart corrigir o que der:**

```powershell
dart fix --dry-run
dart fix --apply
```

`dart fix` aplica automaticamente as correções que os lints e as APIs depreciadas sabem
sugerir (por exemplo, trocar um construtor renomeado). Ele não resolve tudo, mas resolve o
volume chato.

**Passo 5 — verificar:**

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

### 10.5 Roteiro de migração quando algo quebra

1. **Leia a mensagem de erro inteira.** O compilador do Dart costuma dizer exatamente qual
   símbolo sumiu.
2. **Procure o nome do símbolo no `Changelog`** do pacote, no pub.dev.
3. **Procure em breaking changes** se for algo do próprio Flutter.
4. **Corrija um erro por vez** e rode `flutter analyze` de novo. Corrigir em lote esconde a
   causa.
5. **Se travar, reverta.** `git checkout .` e volte no dia seguinte com a cabeça fresca. Uma
   atualização adiada é barata; um projeto corrompido, não.

### 10.6 Sinais de que o seu projeto está envelhecendo mal

| Sinal | O que fazer |
|---|---|
| `flutter pub outdated` mostra dezenas de pacotes atrás | Atualize em blocos pequenos, não tudo de uma vez |
| Você tem medo de rodar `flutter upgrade` | Falta suíte de testes. Escreva testes antes de atualizar |
| Há `// ignore:` espalhado pelo código | Cada `ignore` é uma dívida. Anote e pague |
| O `pubspec.yaml` tem versões fixas sem `^` | Você travou o projeto no passado. Reveja caso a caso |
| Ninguém consegue rodar o projeto sem você explicar | O README está incompleto |

---

## 11. Erros de rota comuns depois do curso

| Erro | Por que acontece | O que fazer em vez disso |
|---|---|---|
| Começar outro curso na semana 1 | Consumir é confortável; produzir é desconfortável | Faça a semana 1 do plano. Curso novo só depois do dia 30 |
| Escolher um projeto ambicioso demais | Entusiasmo | Escopo de 5 telas, com a lista do que fica **fora** escrita |
| Aprender 4 soluções de estado ao mesmo tempo | Medo de escolher errado | Domine Riverpod. Conheça as outras por comparação, uma por vez |
| Nunca publicar nada | Perfeccionismo | Publique a versão 1.0.0 com menos funcionalidades. Atualize depois |
| Adiar testes "para o final" | Parecem lentos | Teste a camada de dados desde o primeiro dia; ela é a mais barata de testar |
| Esperar o Mac para fazer qualquer coisa de iOS | Tudo ou nada | Prepare o projeto agora (seção 4, semana 13). Falta só executar |
| Ficar 6 meses sem atualizar dependências | "Está funcionando" | Rotina mensal da seção 10.1 |

---

## 12. Calendário-resumo dos 90 dias

| Semana | Fase | Foco | Entregável |
|---|---|---|---|
| 1 | Consolidar | Reescrever o Bloco de Notas do zero | App funcionando, `analyze` limpo |
| 2 | Consolidar | Testes | Cobertura na camada de dados e domínio |
| 3 | Consolidar | Nova funcionalidade no Foco | Funcionalidade testada + APK release |
| 4 | Consolidar | Ler código open source | Documento de 1 página |
| 5 | Aprofundar | Trilha principal (laboratório) | Repositório `lab-<trilha>` |
| 6 | Aprofundar | Trilha principal (aplicada) | Funcionalidade no Foco |
| 7 | Aprofundar | Trilha secundária | Repositório `lab-<trilha-b>` |
| 8 | Aprofundar | Escrever sobre o que aprendeu | Texto técnico publicado |
| 9 | Projeto | Escopo + fundação | Documento de escopo + esqueleto |
| 10 | Projeto | Domínio e dados | Camada de dados 100% testada |
| 11 | Projeto | Estado e telas | Todas as telas com 3 estados tratados |
| 12 | Projeto | Acabamento | Ícone, splash, tema, acessibilidade |
| 13 | Projeto | Publicar e apresentar | 🤖 AAB assinado + README de portfólio + 🍎 `IOS.md` |

---

## ☑️ Checklist dos 90 dias

**Fase 1 — consolidar**
- [ ] Reescrevi um projeto do curso do zero, quase sem consultar.
- [ ] Escrevi testes para código que eu já tinha escrito.
- [ ] Adicionei uma funcionalidade completa ao app Foco.
- [ ] Li, rodei e descrevi um projeto open source.

**Fase 2 — aprofundar**
- [ ] Escolhi duas trilhas por necessidade, não por curiosidade.
- [ ] Cada trilha virou um laboratório público no GitHub.
- [ ] Pelo menos uma trilha foi aplicada em um app real.
- [ ] Escrevi um texto técnico explicando o que aprendi.

**Fase 3 — projeto e visibilidade**
- [ ] Escrevi o escopo antes do código, com a lista do que fica de fora.
- [ ] O projeto tem camada de dados testada sem emulador.
- [ ] Ícone, splash, tema claro/escuro e acessibilidade conferidos.
- [ ] 🤖 AAB assinado com **o meu** keystore (nunca com a chave de debug).
- [ ] README de portfólio com prints, decisões técnicas e como rodar.
- [ ] 🍎 `IOS.md` listando o que já está pronto e o que falta executar num Mac.

**Manutenção**
- [ ] Sei ler `flutter pub outdated` e as quatro colunas.
- [ ] Sei a diferença entre `flutter pub upgrade` e `flutter pub upgrade --major-versions`.
- [ ] Atualizo o Flutter sempre em uma branch, com `flutter clean` depois.
- [ ] Leio breaking changes antes de atualizar.

**Segurança — vale para sempre**
- [ ] Nenhum keystore, `key.properties`, `.p12`, `.cer`, `.mobileprovision`, Team ID, API key
      ou senha real entrou em um repositório meu.
- [ ] Meu `.gitignore` cobre todos esses arquivos desde o primeiro commit.

---

## 13. Para onde ir agora

| Quero | Vá para |
|---|---|
| Revisar um conceito específico | [referencias/glossario.md](glossario.md) |
| Lembrar um comando | [referencias/comandos-uteis.md](comandos-uteis.md) |
| Resolver um erro | [referencias/erros-comuns.md](erros-comuns.md) |
| Comparar as plataformas | [referencias/diferencas-android-ios.md](diferencas-android-ios.md) |
| Encontrar a documentação oficial | [referencias/referencias-oficiais.md](referencias-oficiais.md) |
| Revisar a versão curta deste plano | [16-publicacao-e-proximos-passos/06-proximos-passos.md](../modulos/16-publicacao-e-proximos-passos/06-proximos-passos.md) |
| Testar o que eu realmente sei | [avaliacoes/avaliacao-final.md](../avaliacoes/avaliacao-final.md) |
| Refazer o projeto final | [projetos/03-projeto-final-multiplataforma/README.md](../projetos/03-projeto-final-multiplataforma/README.md) |

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [Referências oficiais](referencias-oficiais.md) | [README do curso](../README.md) | [Módulo 16 — Próximos passos](../modulos/16-publicacao-e-proximos-passos/06-proximos-passos.md) |
