# ✅ Checklist — Projeto final "Foco: Organizador de Estudos"

> **O que é:** a lista de conclusão do app **Foco**, o projeto que fecha o curso.
> **Quando usar:** a partir da etapa 5 do projeto, e obrigatoriamente antes de considerar o app
> terminado.
> **Como usar:** marque `- [x]` só depois de rodar a verificação indicada. Um item marcado sem
> prova é uma dívida que aparece na hora do build de release.
> **Especificação completa do app:**
> [projetos/03-projeto-final-multiplataforma/01-especificacao.md](../projetos/03-projeto-final-multiplataforma/01-especificacao.md)
> **Critérios de aceite formais:**
> [projetos/03-projeto-final-multiplataforma/11-criterios-de-aceite.md](../projetos/03-projeto-final-multiplataforma/11-criterios-de-aceite.md)

---

## Dados do projeto (confira antes de começar)

| Campo | Valor obrigatório |
|---|---|
| Nome do app | **Foco** |
| Nome do projeto Flutter | `foco` |
| `applicationId` (Android) / Bundle ID (iOS) | `br.com.estudos.foco` |
| Versão inicial | `version: 1.0.0+1` |
| Gerência de estado | Riverpod 3.4.3, sem *code generation* |
| Navegação | `Navigator` 1.0 + rotas nomeadas via `onGenerateRoute` |
| Banco local | `sqflite` · chave-valor: `shared_preferences` |
| API de exemplo | `https://jsonplaceholder.typicode.com` |

> **Sobre a API:** ela é pública e de testes. As escritas (`POST`, `PUT`, `DELETE`)
> **não persistem** — o servidor devolve uma resposta realista mas não guarda nada. Se você
> recarregar a lista, o item novo não estará lá. Isso é esperado; não é bug seu.

### Termos usados nesta página, explicados

- **CRUD** — *Create, Read, Update, Delete* (criar, ler, atualizar, excluir): as quatro
  operações básicas sobre um registro.
- **Camada de domínio** (*domain*) — onde moram as regras do negócio e os modelos puros. Não
  conhece Flutter, nem banco, nem HTTP.
- **Camada de dados** (*data*) — onde mora o acesso concreto: SQL, HTTP, preferências.
- **Camada de apresentação** (*presentation*) — telas, widgets e controladores de estado.
- **DAO** (*Data Access Object*, objeto de acesso a dados) — a classe que executa o SQL.
- **Repositório** — a classe que a apresentação usa; ela esconde de onde o dado veio.
- **`AsyncValue`** — o tipo do Riverpod que representa, em um único valor, os três estados de
  uma operação assíncrona: carregando, erro e dados.
- **Migração de banco** — o código que transforma um banco na versão antiga em um banco na
  versão nova sem perder os dados do usuário.
- **Área de toque** — o retângulo sensível ao dedo de um botão. Precisa ser maior do que o
  desenho visível.

---

## 1. 🎯 Funcionalidades

### 1.1 CRUD de matérias

- [ ] **Criar matéria** com nome e (opcionalmente) cor/ícone, gravando em `sqflite`.
  - Verificar: abra o app → aba *Matérias* → botão `+` → salve → a matéria aparece na lista.
  - Aula: [modulos/10-persistencia-de-dados/05-sqflite-crud.md](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

- [ ] **Listar matérias** ordenadas corretamente em português (veja o item 6.4).
  - Verificar: cadastre `Física` e `Álgebra`; *Álgebra* precisa vir primeiro.
  - Aula: [modulos/10-persistencia-de-dados/05-sqflite-crud.md](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

- [ ] **Editar matéria** reaproveitando a mesma tela de formulário.
  - Verificar: toque numa matéria existente → o formulário abre **preenchido** → altere o nome
    → salve → a lista reflete a mudança.
  - Aula: [modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md](../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md)

- [ ] **Excluir matéria com confirmação** (diálogo antes de apagar).
  - Verificar: exclua uma matéria, confirme, reabra o app — ela continua fora.
  - Aula: [modulos/06-widgets-e-layouts/10-gestos-e-feedback.md](../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md)

- [ ] **Os dados sobrevivem ao fechamento do app.**
  - Verificar: feche o app pelo gerenciador de tarefas do telefone, reabra, os dados continuam.
  - Aula: [modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md)

### 1.2 Cronômetro de sessão

- [ ] **Tela `/sessao` com cronômetro que inicia, pausa e zera.**
  - Verificar: rode 10 segundos, pause, retome, o tempo continua de onde parou.
  - Aula: [modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md](../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md)

- [ ] **Ao finalizar a sessão, os minutos são gravados na matéria escolhida.**
  - Verificar: finalize uma sessão de 1 minuto → a estatística da matéria aumenta em 1.
  - Aula: [modulos/10-persistencia-de-dados/05-sqflite-crud.md](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

- [ ] **O cronômetro não trava a interface** (a contagem não bloqueia rolagem nem botões).
  - Verificar: com o cronômetro rodando, role a tela e toque em outros controles.
  - Aula: [modulos/13-desempenho-e-seguranca/03-assincrono-sem-travar.md](../modulos/13-desempenho-e-seguranca/03-assincrono-sem-travar.md)

- [ ] **Sair da tela sem finalizar pede confirmação** (usando `PopScope`, nunca `WillPopScope`).
  - Verificar: com o cronômetro rodando, use o botão voltar → aparece a confirmação.
  - Aula: [modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md](../modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md)

### 1.3 Meta semanal

- [ ] **Meta em minutos por semana, salva em `shared_preferences`.**
  - Verificar: defina a meta, feche e reabra o app, o valor continua lá.
  - Aula: [modulos/10-persistencia-de-dados/02-shared-preferences.md](../modulos/10-persistencia-de-dados/02-shared-preferences.md)

- [ ] **Progresso da meta visível na aba Hoje** (quanto já foi feito × quanto falta).
  - Verificar: com meta de 300 min e 60 min estudados, a barra mostra 20%.
  - Aula: [modulos/06-widgets-e-layouts/12-estados-de-ui.md](../modulos/06-widgets-e-layouts/12-estados-de-ui.md)

### 1.4 Trilhas vindas da API

- [ ] **Aba Trilhas carrega a lista de `https://jsonplaceholder.typicode.com/posts`.**
  - Verificar: a lista mostra 100 itens.
  - Aula: [modulos/09-consumo-de-api/03-primeiro-get.md](../modulos/09-consumo-de-api/03-primeiro-get.md)

- [ ] **Tela de detalhe `/trilha` recebendo a trilha por argumento de rota.**
  - Verificar: toque em um item → a tela de detalhe mostra o título e o corpo corretos.
  - Aula: [modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md](../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md)

- [ ] **A tela avisa que é uma API pública de testes e que as escritas não persistem.**
  - Verificar: o aviso aparece na interface, não só no código.
  - Aula: [modulos/09-consumo-de-api/01-http-e-rest.md](../modulos/09-consumo-de-api/01-http-e-rest.md)

### 1.5 Estatísticas

- [ ] **Tela `/estatisticas` com minutos por matéria.**
  - Verificar: os valores batem com a soma das sessões registradas.
  - Aula: [projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md](../projetos/03-projeto-final-multiplataforma/06-etapa-4-telas-e-navegacao.md)

- [ ] **Progresso da meta semanal exibido junto.**
  - Aula: [projetos/03-projeto-final-multiplataforma/11-criterios-de-aceite.md](../projetos/03-projeto-final-multiplataforma/11-criterios-de-aceite.md)

- [ ] **A tela trata o caso "nenhuma sessão registrada"** com um estado vazio explicativo, e não
  com um gráfico em branco.
  - Aula: [modulos/06-widgets-e-layouts/12-estados-de-ui.md](../modulos/06-widgets-e-layouts/12-estados-de-ui.md)

---

## 2. 🏛️ Arquitetura

- [ ] **Estrutura *feature-first* respeitada**, com `lib/core/` e `lib/features/<feature>/`.
  - Verificar (a saída deve listar `materias`, `sessoes`, `metas`, `trilhas`, `estatisticas`):
    ```powershell
    Get-ChildItem .\lib\features -Directory | Select-Object Name
    ```
  - Aula: [modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md](../modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md)

- [ ] **Cada feature tem as 3 camadas** (`presentation`, `domain`, `data`) — exceto
  `estatisticas`, que só deriva dados de outras features e por isso tem apenas `presentation`.
  - Verificar:
    ```powershell
    Get-ChildItem .\lib\features -Recurse -Directory | Select-Object FullName
    ```
  - Aula: [projetos/03-projeto-final-multiplataforma/02-arquitetura.md](../projetos/03-projeto-final-multiplataforma/02-arquitetura.md)

- [ ] 🔴 **Nenhum arquivo de `domain/` importa Flutter.**
  O domínio precisa ser testável sem árvore de widgets. Se ele importa `package:flutter`, o
  desenho está errado.
  - Verificar (**não pode devolver nada**):
    ```powershell
    Get-ChildItem .\lib\features -Recurse -Filter *.dart |
      Where-Object FullName -Match '\\domain\\' |
      Select-String -Pattern 'package:flutter'
    ```
  - Aula: [modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md](../modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md)

- [ ] **Nenhum arquivo de `domain/` importa `sqflite` ou `http`.**
  - Verificar (**não pode devolver nada**):
    ```powershell
    Get-ChildItem .\lib\features -Recurse -Filter *.dart |
      Where-Object FullName -Match '\\domain\\' |
      Select-String -Pattern 'package:(sqflite|http)'
    ```
  - Aula: [modulos/09-consumo-de-api/07-camada-de-dados-testavel.md](../modulos/09-consumo-de-api/07-camada-de-dados-testavel.md)

- [ ] **Cada repositório implementa um contrato declarado no domínio**
  (ex.: `materia_repositorio_contrato.dart`).
  - Verificar: a classe de `data/` usa `implements` do contrato de `domain/`.
  - Aula: [modulos/03-dart-intermediario/05-abstratas-e-interfaces.md](../modulos/03-dart-intermediario/05-abstratas-e-interfaces.md)

- [ ] 🔴 **O DAO recebe o `Database` pelo construtor** (injeção de dependência), em vez de abrir
  o banco sozinho em um *singleton*.
  Sem isso o DAO **não é testável** — e testar a camada de dados no Windows, sem emulador, é um
  dos ganhos concretos do curso.
  - Verificar: o construtor do DAO tem um parâmetro `Database`.
  - Aula: [modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md](../modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md)

- [ ] **`lib/core/` contém apenas o que é usado por mais de uma feature**
  (constantes, falhas, rotas, tema, widgets de estado).
  - Verificar:
    ```powershell
    Get-ChildItem .\lib\core -Recurse -Filter *.dart | Select-Object FullName
    ```
  - Aula: [modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md](../modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md)

- [ ] **Erros modelados com `sealed class` + `switch` exaustivo** em `core/erros/falhas.dart`.
  - Aula: [modulos/04-dart-avancado/06-sealed-classes.md](../modulos/04-dart-avancado/06-sealed-classes.md)

---

## 3. 🔄 Estado (Riverpod 3)

- [ ] **`ProviderScope` envolvendo o app no `main.dart`.**
  - Verificar:
    ```powershell
    Select-String -Path .\lib\main.dart -Pattern 'ProviderScope'
    ```
  - Aula: [modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md](../modulos/08-estado-e-arquitetura/05-riverpod-primeiros-passos.md)

- [ ] **Estado síncrono com `Notifier` + `NotifierProvider(MinhaClasse.new)`.**
  - Aula: [modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md](../modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md)

- [ ] **Estado assíncrono com `AsyncNotifier` + `AsyncNotifierProvider`.**
  - Aula: [modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md](../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)

- [ ] **Toda tela que carrega dados usa `AsyncValue` com `when(loading:, error:, data:)`.**
  - Verificar: cada aba com dado remoto ou de banco tem os três ramos.
  - Aula: [modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md](../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)

- [ ] 🔴 **Nenhum uso de API legada do Riverpod.**
  `StateProvider`, `StateNotifier`, `StateNotifierProvider` e `ChangeNotifierProvider` foram
  movidos para `package:riverpod/legacy.dart` no Riverpod 3 — o curso não os usa.
  - Verificar (**não pode devolver nada**):
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart |
      Select-String -Pattern 'StateNotifier|StateProvider|ChangeNotifierProvider|riverpod/legacy'
    ```
  - Aula: [modulos/08-estado-e-arquitetura/04-por-que-riverpod.md](../modulos/08-estado-e-arquitetura/04-por-que-riverpod.md)

- [ ] 🔴 **Nenhum uso de `.valueOrNull`** — esse membro **não existe** no Riverpod 3.
  Use `state.value` (é `T?`, nulo em carregando/erro) ou `state.requireValue`.
  - Verificar (**não pode devolver nada**):
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'valueOrNull'
    ```
  - Aula: [modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md](../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)

- [ ] **`Ref` escrito sem parâmetro de tipo** (`Ref`, nunca `Ref<int>`).
  - Verificar (**não pode devolver nada**):
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'Ref<'
    ```
  - Aula: [modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md](../modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md)

- [ ] 🔴 **Todo `await` dentro de um `Notifier` é seguido por uma checagem de `ref.mounted`.**
  No Riverpod 3, interagir com um `Ref` já descartado **lança erro**.
  - Aula: [modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md](../modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md)

- [ ] **Operações que podem falhar usam `AsyncValue.guard`** em vez de `try/catch` manual
  espalhado.
  - Aula: [modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md](../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md)

- [ ] **Providers que recebem parâmetro usam `family`, e são descartados quando saem de tela.**
  - Aula: [modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md](../modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md)

---

## 4. 🧭 Navegação

- [ ] **As 5 rotas nomeadas existem e batem com a especificação:**
  `/`, `/materia/form`, `/sessao`, `/trilha`, `/estatisticas`.
  - Verificar:
    ```powershell
    Select-String -Path .\lib\core\rotas\rotas.dart -Pattern "'/"
    ```
  - Aula: [modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md](../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md)

- [ ] **`onGenerateRoute` centraliza a criação das rotas** (nada de `MaterialPageRoute` solto
  espalhado pelas telas).
  - Verificar:
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'onGenerateRoute'
    ```
  - Aula: [modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md](../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md)

- [ ] **Argumentos de rota tipados e validados** (nada de `as Map` cego que estoura em tempo de
  execução).
  - Aula: [modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md](../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md)

- [ ] **O formulário devolve resultado com `Navigator.pop(context, valor)`** e a tela anterior
  reage a ele.
  - Verificar: salvar uma matéria fecha o formulário **e** atualiza a lista, sem precisar de
    "puxar para atualizar".
  - Aula: [modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md](../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md)

- [ ] **As 4 abas (Hoje · Matérias · Trilhas · Ajustes) preservam o estado ao trocar.**
  - Verificar: role a lista de trilhas, vá para Matérias, volte — a posição da rolagem
    permanece.
  - Aula: [modulos/07-navegacao-e-formularios/04-abas-e-organizacao.md](../modulos/07-navegacao-e-formularios/04-abas-e-organizacao.md)

- [ ] **Botão voltar do Android tratado com `PopScope`** (nunca `WillPopScope`, que está
  obsoleto).
  - Verificar (**não pode devolver nada**):
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'WillPopScope'
    ```
  - Aula: [modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md](../modulos/11-recursos-nativos/08-botao-voltar-e-gestos.md)

- [ ] **Depois de qualquer `await`, o `BuildContext` é revalidado** (`if (!context.mounted)
  return;` ou `if (!mounted) return;` dentro de um `State`).
  - Aula: [modulos/04-dart-avancado/02-futures-e-async-await.md](../modulos/04-dart-avancado/02-futures-e-async-await.md)

---

## 5. 📝 Formulários

- [ ] **`Form` + `GlobalKey<FormState>` + `TextFormField` com `validator`.**
  - Verificar: salvar com o nome vazio mostra mensagem de erro e **não** grava nada.
  - Aula: [modulos/07-navegacao-e-formularios/06-formularios.md](../modulos/07-navegacao-e-formularios/06-formularios.md)

- [ ] **Mensagens de validação em português, específicas e úteis**
  (ex.: "Informe o nome da matéria" — não "Campo inválido").
  - Aula: [modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md](../modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md)

- [ ] **Foco gerenciado**: o primeiro campo recebe foco ao abrir; `textInputAction` leva ao
  próximo campo; o último envia o formulário.
  - Verificar: navegue pelo formulário usando só o teclado do telefone.
  - Aula: [modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md](../modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md)

- [ ] **Teclado adequado por campo** (`keyboardType` numérico para minutos, texto para nome).
  - Aula: [modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md](../modulos/07-navegacao-e-formularios/07-validacao-foco-teclado.md)

- [ ] **O teclado não cobre o campo em foco** (a tela rola).
  - Verificar: abra o formulário em um aparelho com tela pequena e toque no último campo.
  - Aula: [modulos/07-navegacao-e-formularios/08-ux-de-formularios.md](../modulos/07-navegacao-e-formularios/08-ux-de-formularios.md)

- [ ] **Botão de salvar desabilitado (ou com indicador) enquanto a gravação está em andamento**,
  evitando gravação duplicada por toque duplo.
  - Aula: [modulos/07-navegacao-e-formularios/08-ux-de-formularios.md](../modulos/07-navegacao-e-formularios/08-ux-de-formularios.md)

- [ ] **Todo `TextEditingController` e `FocusNode` é liberado no `dispose()`.**
  - Verificar:
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'dispose\(\)'
    ```
  - Aula: [modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md](../modulos/05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md)

---

## 6. 💾 Persistência

- [ ] **Banco criado com `onCreate` e versão explícita.**
  - Aula: [modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md)

- [ ] **`onUpgrade` implementado com migração real v1 → v2** (`ALTER TABLE`), e não apagando o
  banco do usuário.
  - Verificar: o teste de migração passa, conferindo a nova coluna com `PRAGMA table_info`.
  - Aula: [modulos/10-persistencia-de-dados/06-migracoes.md](../modulos/10-persistencia-de-dados/06-migracoes.md)

- [ ] **`insert` de *upsert* usa `conflictAlgorithm: ConflictAlgorithm.replace`.**
  - Verificar:
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'ConflictAlgorithm.replace'
    ```
  - Aula: [modulos/10-persistencia-de-dados/05-sqflite-crud.md](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

- [ ] 🔴 **Ordenação alfabética correta em português.**
  O SQLite compara texto **byte a byte**. Em UTF-8, `F` é `0x46` e `Á` é `0xC3 0x81` — logo o
  banco acha que `'Física' < 'Álgebra'`. `COLLATE NOCASE` **não resolve**, porque só entende
  ASCII. A solução do curso é uma coluna `nome_ordenacao TEXT NOT NULL` com o texto
  normalizado (minúsculo e sem acento), com índice, e `orderBy: 'nome_ordenacao ASC'`.
  - Verificar: cadastre `Física` e `Álgebra`; a lista precisa mostrar **Álgebra** primeiro.
    O teste automatizado que prova isso compara a consulta crua com a normalizada.
  - Aula: [modulos/10-persistencia-de-dados/06-migracoes.md](../modulos/10-persistencia-de-dados/06-migracoes.md) ·
    [modulos/10-persistencia-de-dados/05-sqflite-crud.md](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

- [ ] **Meta semanal em `shared_preferences`** — e nada além de configuração simples ali.
  - Aula: [modulos/10-persistencia-de-dados/01-qual-armazenamento-usar.md](../modulos/10-persistencia-de-dados/01-qual-armazenamento-usar.md)

- [ ] **O banco é aberto uma única vez e reaproveitado** (nada de abrir conexão a cada consulta).
  - Aula: [modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md)

- [ ] **Escritas múltiplas relacionadas usam transação/`batch`.**
  - Aula: [modulos/10-persistencia-de-dados/05-sqflite-crud.md](../modulos/10-persistencia-de-dados/05-sqflite-crud.md)

- [ ] **Nada sensível guardado em texto puro** (se algum dia houver token, ele vai para
  `flutter_secure_storage`).
  - Aula: [modulos/10-persistencia-de-dados/07-dados-sensiveis.md](../modulos/10-persistencia-de-dados/07-dados-sensiveis.md)

---

## 7. 🌐 API

- [ ] **Toda chamada HTTP tem `.timeout(Duration(seconds: 15))`.**
  - Verificar (o número de ocorrências deve bater com o número de chamadas):
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern '\.timeout\('
    ```
  - Aula: [modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md](../modulos/09-consumo-de-api/06-timeout-retry-cancelamento.md)

- [ ] **`TimeoutException`, `SocketException` e `FormatException` tratadas separadamente**, cada
  uma virando uma falha com mensagem própria para o usuário.
  - Verificar:
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart |
      Select-String -Pattern 'TimeoutException|SocketException|FormatException'
    ```
  - Aula: [modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md](../modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md)

- [ ] **O código de status é verificado** antes de tentar interpretar o JSON.
  - Aula: [modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md](../modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md)

- [ ] **A camada de API recebe o cliente HTTP pelo construtor**, para poder ser trocada por um
  falso nos testes.
  - Aula: [modulos/09-consumo-de-api/07-camada-de-dados-testavel.md](../modulos/09-consumo-de-api/07-camada-de-dados-testavel.md)

- [ ] 🔴 **Os 4 estados de UI implementados na aba Trilhas:**
  1. **carregando** (indicador de progresso),
  2. **vazio** (mensagem explicando que não há nada, não uma tela em branco),
  3. **erro** (mensagem em português + botão *Tentar novamente*),
  4. **dados** (a lista).
  - Verificar: ligue o modo avião e abra a aba → precisa aparecer o estado de **erro** com o
    botão, não uma tela branca nem um travamento.
  - Aula: [modulos/06-widgets-e-layouts/12-estados-de-ui.md](../modulos/06-widgets-e-layouts/12-estados-de-ui.md) ·
    [modulos/09-consumo-de-api/09-api-com-riverpod.md](../modulos/09-consumo-de-api/09-api-com-riverpod.md)

- [ ] **Botão "Tentar novamente" realmente refaz a requisição.**
  - Verificar: desligue o modo avião e toque no botão → a lista carrega.
  - Aula: [modulos/09-consumo-de-api/09-api-com-riverpod.md](../modulos/09-consumo-de-api/09-api-com-riverpod.md)

- [ ] **A conversão de JSON está isolada em um `fromJson`/`toJson` do modelo**, e não espalhada
  pelas telas.
  - Aula: [modulos/09-consumo-de-api/02-json.md](../modulos/09-consumo-de-api/02-json.md)

---

## 8. 🔬 Qualidade

- [ ] **`dart analyze` sem nenhuma advertência.**
  - Verificar:
    ```powershell
    dart analyze lib test
    ```
    Esperado: `No issues found!`
  - Aula: [modulos/12-testes-e-debug/04-analise-lint-formatacao.md](../modulos/12-testes-e-debug/04-analise-lint-formatacao.md)

- [ ] **`flutter analyze` sem nenhuma advertência.**
  - Verificar:
    ```powershell
    flutter analyze
    ```
  - Aula: [modulos/04-dart-avancado/07-analise-estatica-e-lints.md](../modulos/04-dart-avancado/07-analise-estatica-e-lints.md)

- [ ] **Código formatado.**
  - Verificar (falha se algum arquivo estiver fora do padrão):
    ```powershell
    dart format --output=none --set-exit-if-changed .
    ```
  - Aula: [modulos/12-testes-e-debug/04-analise-lint-formatacao.md](../modulos/12-testes-e-debug/04-analise-lint-formatacao.md)

- [ ] **`flutter_lints ^6.0.0` ativo no `analysis_options.yaml`.**
  Atenção a duas regras que pegam todo mundo: `avoid_print` (use `debugPrint()`) e
  `unnecessary_underscores` (escreva `(_, _)`, não `(_, __)`).
  - Verificar:
    ```powershell
    Select-String -Path .\analysis_options.yaml -Pattern 'flutter_lints|include'
    ```
  - Aula: [modulos/04-dart-avancado/07-analise-estatica-e-lints.md](../modulos/04-dart-avancado/07-analise-estatica-e-lints.md)

- [ ] **Nenhum `print()` no código Flutter.**
  - Verificar (**não pode devolver nada**):
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern '(?<!debug)\bprint\('
    ```
  - Aula: [modulos/12-testes-e-debug/02-logs-e-breakpoints.md](../modulos/12-testes-e-debug/02-logs-e-breakpoints.md)

- [ ] **Testes unitários do domínio e dos repositórios passando.**
  - Verificar:
    ```powershell
    flutter test
    ```
    Esperado: `All tests passed!`
  - Aula: [modulos/12-testes-e-debug/05-testes-unitarios.md](../modulos/12-testes-e-debug/05-testes-unitarios.md)

- [ ] **Testes de banco rodando no Windows com `sqflite_common_ffi`** (banco em memória, sem
  emulador).
  - Verificar: o arquivo de teste chama `sqfliteFfiInit()` e define
    `databaseFactory = databaseFactoryFfi` antes de abrir `inMemoryDatabasePath`.
  - Aula: [modulos/12-testes-e-debug/07-mocks-e-fakes.md](../modulos/12-testes-e-debug/07-mocks-e-fakes.md)

- [ ] **Testes de widget cobrindo pelo menos: estado vazio, estado de erro e formulário com
  validação.**
  - Verificar:
    ```powershell
    flutter test test
    ```
  - Aula: [modulos/12-testes-e-debug/06-testes-de-widget.md](../modulos/12-testes-e-debug/06-testes-de-widget.md)

- [ ] **Camada HTTP testada com `mocktail`** (respostas 200, 500 e JSON inválido).
  Lembre: para usar `any()` com tipos não primitivos é preciso registrar um *fallback* em
  `setUpAll`, por exemplo com uma `class UriFalsa extends Fake implements Uri {}` e
  `registerFallbackValue(UriFalsa())`.
  - Aula: [modulos/12-testes-e-debug/07-mocks-e-fakes.md](../modulos/12-testes-e-debug/07-mocks-e-fakes.md)

- [ ] **Nenhum teste falha por Timer pendente.**
  Erro típico:
  ```text
  A Timer is still pending even after the widget tree was disposed.
  ```
  Correção: `await tester.pump(const Duration(milliseconds: 50));` (ou `pumpAndSettle()`) antes
  de terminar o teste.
  - Aula: [modulos/12-testes-e-debug/06-testes-de-widget.md](../modulos/12-testes-e-debug/06-testes-de-widget.md)

- [ ] **Pelo menos 1 teste de integração passando** (fluxo completo: criar matéria → iniciar
  sessão → ver estatística).
  - Verificar (com um dispositivo conectado; troque `<id>` pelo id do `flutter devices`):
    ```powershell
    flutter test integration_test -d <id>
    ```
  - Aula: [modulos/12-testes-e-debug/08-testes-de-integracao.md](../modulos/12-testes-e-debug/08-testes-de-integracao.md)

- [ ] **Nenhuma API depreciada em uso.**
  - Verificar (**não pode devolver nada**):
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart |
      Select-String -Pattern 'RaisedButton|FlatButton|OutlineButton|accentColor|headline6|MaterialStateProperty|WillPopScope'
    ```
  - Aula: [modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md](../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md)

---

## 9. 🎨 UX, responsividade e acessibilidade

- [ ] **Nenhum estouro de layout** (as listras amarelas e pretas de *overflow*).
  - Verificar: rode em um aparelho estreito, gire a tela para paisagem, aumente a fonte do
    sistema para o máximo.
  - Aula: [modulos/06-widgets-e-layouts/06-constraints.md](../modulos/06-widgets-e-layouts/06-constraints.md)

- [ ] **Layout responsivo**: em tela larga o conteúdo não fica esticado numa coluna única
  gigante.
  - Aula: [modulos/06-widgets-e-layouts/11-responsividade.md](../modulos/06-widgets-e-layouts/11-responsividade.md)

- [ ] **Modo escuro funcionando de verdade**, com `ThemeData` claro e escuro definidos em
  `core/tema/tema_app.dart`.
  - Verificar: mude o tema do sistema operacional e abra o app; todas as 5 telas ficam legíveis.
  - Aula: [modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md](../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md)

- [ ] **Material 3 em uso** e botões atuais (`FilledButton`, `FilledButton.tonal`,
  `OutlinedButton`, `TextButton`).
  - Aula: [modulos/05-introducao-ao-flutter/09-material-e-cupertino.md](../modulos/05-introducao-ao-flutter/09-material-e-cupertino.md)

- [ ] **Área de toque de no mínimo 48×48 pontos** em todo elemento tocável.
  - Verificar: ícones pequenos dentro de `IconButton` ou envolvidos por um alvo maior.
  - Aula: [modulos/13-desempenho-e-seguranca/05-acessibilidade.md](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

- [ ] **Contraste de texto suficiente** nos dois temas (texto claro em fundo escuro e
  vice-versa, sem cinza sobre cinza).
  - Aula: [modulos/13-desempenho-e-seguranca/05-acessibilidade.md](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

- [ ] **Ícones sem rótulo têm `Semantics` ou `tooltip`**, para o leitor de tela anunciar a ação.
  - Verificar: ative o TalkBack (Android) e navegue pela tela inicial.
  - Aula: [modulos/13-desempenho-e-seguranca/05-acessibilidade.md](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

- [ ] **Feedback visível em toda ação** (SnackBar ao salvar/excluir, usando
  `ScaffoldMessenger.of(context).showSnackBar(...)`).
  - Aula: [modulos/06-widgets-e-layouts/10-gestos-e-feedback.md](../modulos/06-widgets-e-layouts/10-gestos-e-feedback.md)

- [ ] **Listas longas usam `ListView.builder`** (construção sob demanda), não `ListView` com
  `children:` montando 100 itens de uma vez.
  - Aula: [modulos/13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md](../modulos/13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md)

- [ ] **`const` aplicado em todo widget que pode ser constante** (reduz reconstruções).
  - Aula: [modulos/13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md](../modulos/13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md)

- [ ] **Datas e números formatados com `intl`**, no padrão brasileiro.
  - Aula: [modulos/06-widgets-e-layouts/02-texto-tipografia-icones.md](../modulos/06-widgets-e-layouts/02-texto-tipografia-icones.md)

---

## 10. 🪪 Identidade do app

- [ ] **`applicationId` / Bundle ID definido como `br.com.estudos.foco`** — antes de qualquer
  build de release, porque mudar depois de publicar é impossível.
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\build.gradle.kts -Pattern 'applicationId'
    ```
  - Aula: [modulos/14-build-android/02-identidade-do-app.md](../modulos/14-build-android/02-identidade-do-app.md)

- [ ] **Nome exibido "Foco"** (`android:label` no `AndroidManifest.xml` e
  `CFBundleDisplayName` no `Info.plist`).
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\src\main\AndroidManifest.xml -Pattern 'android:label'
    ```
  - Aula: [modulos/14-build-android/02-identidade-do-app.md](../modulos/14-build-android/02-identidade-do-app.md)

- [ ] **`version: 1.0.0+1` no `pubspec.yaml`** (vale para as duas plataformas).
  - Verificar:
    ```powershell
    Select-String -Path .\pubspec.yaml -Pattern '^version:'
    ```
  - Aula: [modulos/16-publicacao-e-proximos-passos/03-versionamento-e-releases.md](../modulos/16-publicacao-e-proximos-passos/03-versionamento-e-releases.md)

- [ ] **Ícone gerado** para Android e iOS.
  - Verificar:
    ```powershell
    dart run flutter_launcher_icons
    Get-ChildItem .\android\app\src\main\res\mipmap-xxxhdpi
    ```
  - Aula: [modulos/14-build-android/03-icone.md](../modulos/14-build-android/03-icone.md)

- [ ] **Splash gerada**, inclusive no modo escuro e no formato do Android 12+.
  - Verificar:
    ```powershell
    dart run flutter_native_splash:create
    Test-Path .\android\app\src\main\res\values-v31\styles.xml
    ```
  - Aula: [modulos/14-build-android/04-splash-screen.md](../modulos/14-build-android/04-splash-screen.md)

- [ ] **Permissões declaradas conferem com o que o app realmente usa** (nada a mais).
  - Verificar:
    ```powershell
    Select-String -Path .\android\app\src\main\AndroidManifest.xml -Pattern 'uses-permission'
    ```
  - Aula: [modulos/14-build-android/05-permissoes-android.md](../modulos/14-build-android/05-permissoes-android.md)

---

## 11. 🔒 Segurança e Git

- [ ] 🔴 **Nenhum segredo no repositório.** Sem senha, sem `.jks`, sem `key.properties`, sem
  `.p12`, sem `.cer`, sem `.mobileprovision`, sem `.env`.
  - Verificar (**não pode devolver nada**):
    ```powershell
    git ls-files | Select-String -Pattern '\.(jks|keystore|p12|cer|mobileprovision|env)$|key\.properties'
    ```
  - Aula: [modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md)

- [ ] **`.gitignore` cobrindo os padrões acima.**
  - Verificar:
    ```powershell
    Select-String -Path .\.gitignore -Pattern 'key.properties|\*.jks|\*.keystore|\.env'
    ```
  - Aula: [modulos/00-git-e-terminal/04-commits-branches-gitignore.md](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

- [ ] **Nenhuma chave de API embutida no código Dart.**
  Lembre: código de app é distribuído ao usuário e pode ser lido. Segredo em app cliente não é
  segredo.
  - Verificar:
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'apiKey|api_key|secret|token ='
    ```
  - Aula: [modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md)

- [ ] **Todo acesso de rede por HTTPS.**
  - Verificar (**não pode devolver `http://` fora de comentário**):
    ```powershell
    Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'http://'
    ```
  - Aula: [modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md)

- [ ] **O projeto está versionado, com commits descritivos.**
  - Verificar:
    ```powershell
    git status
    git log --oneline -10
    ```
  - Aula: [modulos/00-git-e-terminal/04-commits-branches-gitignore.md](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md)

---

## 12. 🧪 Como provar que o projeto está pronto (sequência exata)

Rode na raiz do projeto `foco`, nesta ordem. **Qualquer falha invalida o "pronto".**

```powershell
# 1. Dependências corretas
flutter pub get

# 2. Qualidade estática
flutter analyze
dart analyze lib test
dart format --output=none --set-exit-if-changed .

# 3. Nada legado, nada inseguro (os 5 comandos abaixo NÃO podem devolver nada)
Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'StateNotifier|StateProvider|ChangeNotifierProvider'
Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'valueOrNull'
Get-ChildItem .\lib -Recurse -Filter *.dart | Select-String -Pattern 'WillPopScope|RaisedButton|accentColor'
Get-ChildItem .\lib\features -Recurse -Filter *.dart | Where-Object FullName -Match '\\domain\\' | Select-String -Pattern 'package:flutter'
git ls-files | Select-String -Pattern '\.(jks|keystore|p12|cer|mobileprovision|env)$|key\.properties'

# 4. Testes
flutter test
flutter test integration_test -d <id-do-dispositivo>

# 5. Roda de verdade
flutter devices
flutter run -d <id-do-dispositivo>

# 6. Compila em release (Android)
flutter clean
flutter build apk --release
```

### Tabela de saídas esperadas

| Comando | Prova de sucesso |
|---|---|
| `flutter pub get` | `Got dependencies!` |
| `flutter analyze` | `No issues found!` |
| `dart format --output=none --set-exit-if-changed .` | termina sem listar arquivo |
| os 5 `Select-String` do passo 3 | **nenhuma linha devolvida** |
| `flutter test` | `All tests passed!` |
| `flutter test integration_test -d <id>` | `All tests passed!` |
| `flutter build apk --release` | `✓ Built build\app\outputs\flutter-apk\app-release.apk` |

---

## 13. Autoavaliação final

Antes de marcar o projeto como concluído, responda com honestidade:

| Pergunta | Sim | Não |
|---|---|---|
| Eu conseguiria explicar, em voz alta, o que cada camada do projeto faz? | | |
| Eu conseguiria recriar a camada de dados de uma feature do zero? | | |
| Eu sei dizer por que o domínio não pode importar Flutter? | | |
| Eu sei explicar por que `'Física'` vinha antes de `'Álgebra'` no banco? | | |
| Eu sei dizer o que `AsyncValue` resolve que um `bool carregando` não resolve? | | |
| Eu saberia adicionar uma sexta tela sozinho? | | |

Qualquer "Não" indica uma aula para revisar — use o
[04-mapa-de-aprendizagem.md](../04-mapa-de-aprendizagem.md) para localizar o assunto.

---

## 14. Próximos passos depois deste checklist

1. **Gerar o release Android**: [checklists/build-android.md](build-android.md)
2. **Preparar o iOS** (a parte que dá para fazer no Windows):
   [checklists/ambiente-ios.md](ambiente-ios.md) e [checklists/build-ios.md](build-ios.md)
3. **Publicar**: [modulos/16-publicacao-e-proximos-passos/01-google-play.md](../modulos/16-publicacao-e-proximos-passos/01-google-play.md)
4. **Desafios extras do projeto**:
   [projetos/03-projeto-final-multiplataforma/12-desafios.md](../projetos/03-projeto-final-multiplataforma/12-desafios.md)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próxima |
|---|---|---|
| [Checklist — Ambiente iOS](ambiente-ios.md) | [Índice geral](../README.md) | [Checklist — Build Android](build-android.md) |
