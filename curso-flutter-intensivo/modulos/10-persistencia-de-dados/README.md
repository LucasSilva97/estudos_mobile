# Módulo 10 — Persistência de Dados

> **Nível:** Intermediário → Avançado · **Tempo estimado total:** 355 min (≈ 5 h 55 min)
> · **Pré-requisito direto:** [Módulo 09 — Consumo de API](../09-consumo-de-api/README.md)

Até agora tudo que o seu app sabia morria junto com o processo. Você digitava uma matéria, o app
mostrava na tela — e ao fechar o aplicativo, sumia. Você buscava trilhas na API, e sem internet a
tela ficava vazia.

**Persistir** (do latim *persistere*, "continuar existindo") é gravar um dado em algum lugar que
sobrevive ao fechamento do aplicativo e ao desligamento do aparelho. É o que separa uma
demonstração de um aplicativo de verdade.

Este módulo responde, na ordem, às quatro perguntas que todo desenvolvedor mobile precisa saber
responder sem hesitar:

1. **Onde eu guardo isso?** — existem quatro lugares possíveis e escolher errado custa caro.
2. **Como eu guardo?** — a API de cada um, com código que roda.
3. **O que acontece quando o app muda?** — migrações de banco, o assunto que quebra aplicativos
   já publicados.
4. **E quando não há internet?** — cache, dado desatualizado e fila de operações pendentes.

Versões usadas em todas as aulas: **Flutter 3.47.1** · **Dart 3.13.1** · `shared_preferences`
**^2.5.5** · `path_provider` **^2.1.6** · `path` **^1.9.1** · `sqflite` **^2.4.4** ·
`flutter_secure_storage` **^11.1.1** · `connectivity_plus` **^7.3.1** ·
`sqflite_common_ffi` **^2.4.3** (só em testes).

---

## 🎯 O que você vai aprender

Ao terminar este módulo você será capaz de:

- **Escolher o armazenamento certo** com uma árvore de decisão objetiva: preferência simples,
  arquivo, banco relacional ou cofre para dado sensível — e justificar a escolha.
- **Dizer onde o dado fica fisicamente** em 🤖 Android e 🍎 iOS, e prever o que acontece com ele
  quando o usuário desinstala o app ou restaura um backup do sistema.
- **Usar `shared_preferences`** para configurações do usuário: `setInt`, `getInt`, `setString`,
  `setBool`, `setStringList`, `remove`, `clear`, valores padrão e objeto serializado em JSON.
- **Ler e escrever arquivos** com `path_provider` + `package:path`, sabendo a diferença entre
  documentos, suporte e temporário — e por que essa diferença muda o backup do iCloud.
- **Criar um banco SQLite** com `sqflite`: `openDatabase`, `version`, `onCreate`, `onConfigure`,
  `onUpgrade`, tipos do SQLite, `PRIMARY KEY`, `NOT NULL`, `DEFAULT`, chave estrangeira e índice.
- **Fazer CRUD completo** (*Create, Read, Update, Delete*) com `insert`, `query`, `update`,
  `delete`, `rawQuery`, `rawUpdate`, `transaction` e `batch` — sempre com `?` e `whereArgs`,
  nunca concatenando texto em SQL.
- **Corrigir um bug real de português**: o `ORDER BY` do SQLite compara **bytes**, então
  `Física` vem antes de `Álgebra`. Você vai ver a prova, entender por que `COLLATE NOCASE` não
  resolve e implementar a coluna `nome_ordenacao` normalizada.
- **Escrever migrações** que não quebram o aparelho de quem já tem o app instalado, testá-las com
  `PRAGMA table_info` e nunca mais alterar uma migração já publicada.
- **Guardar dado sensível** com `flutter_secure_storage`, entendendo 🤖 Android Keystore +
  `EncryptedSharedPreferences` e 🍎 iOS Keychain — inclusive o fato de o Keychain **sobreviver à
  desinstalação**.
- **Funcionar sem internet**: estratégia *cache-first* × *network-first*, carimbo de tempo, TTL,
  invalidação, aviso de "dado de ontem" e fila de operações pendentes.

---

## ✅ Pré-requisitos

| Pré-requisito | Onde está | Por que é necessário |
|---|---|---|
| Módulo 09 — Consumo de API | [modulos/09-consumo-de-api/README.md](../09-consumo-de-api/README.md) | A aula 8 cacheia exatamente a resposta que você aprendeu a buscar lá |
| Camada de dados testável | [09 — Camada de dados testável](../09-consumo-de-api/07-camada-de-dados-testavel.md) | Todo repositório deste módulo recebe suas dependências pelo construtor |
| Injeção de dependências | [08 — Injeção de dependências](../08-estado-e-arquitetura/10-injecao-de-dependencias.md) | O DAO recebe o `Database` pronto; sem isso ele não é testável |
| Futures e `async`/`await` | [04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) | **Toda** operação de disco é assíncrona |
| JSON e `Map` | [09 — JSON](../09-consumo-de-api/02-json.md) | Converter `Map` em modelo e modelo em `Map` é o trabalho de metade do módulo |
| Classes, `copyWith` e construtores | [03 — Classes e objetos](../03-dart-intermediario/01-classes-e-objetos.md) | Os modelos `Materia` e `Sessao` são classes comuns de Dart |
| Ambiente funcionando | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) | Você vai rodar `flutter pub add` e `flutter test` em todas as aulas |

Checagem rápida — abra o **PowerShell** e rode:

```powershell
flutter --version
```

A saída precisa mostrar `Flutter 3.47.1` e `Dart 3.13.1`.

> 🪟 **Windows — dois avisos antes de começar.**
> 1. Instalar pacotes com plugin nativo exige o **Modo de Desenvolvedor** ligado, porque o
>    Flutter cria links simbólicos. Sem ele, `flutter pub add shared_preferences` falha com
>    `Building with plugins requires symlink support`. Ligue em **Configurações → Sistema →
>    Para desenvolvedores**.
> 2. O SDK do Flutter não pode estar num caminho com **acento** nem **espaço**. Se o seu ainda
>    estiver em `C:\Users\Usuário\Documents\flutter`, volte para
>    [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) e mova para
>    `C:\src\flutter` antes de seguir.

---

## 🧱 O projeto que cresce ao longo do módulo

Na aula 1 você cria **uma única vez** o laboratório do módulo:

```powershell
flutter create --platforms=android,ios foco_dados
```

Depois, cada aula acrescenta arquivos a esse mesmo projeto, sempre no domínio do app final
**Foco** (matérias, sessões de estudo, metas e trilhas). Este é o estado dele ao fim da aula 8:

```text
foco_dados/
├── lib/
│   ├── core/
│   │   ├── armazenamento/politica_de_armazenamento.dart   (aula 1)
│   │   ├── arquivos/{pastas_do_app.dart,exportador_de_estudo.dart}  (aula 3)
│   │   ├── banco/{texto.dart,banco_foco.dart}             (aulas 4 a 6)
│   │   ├── rede/status_de_rede.dart                       (aula 8)
│   │   └── seguranca/cofre.dart                           (aula 7)
│   └── features/
│       ├── materias/
│       │   ├── data/{materia_dao.dart,materia_repositorio.dart}     (aulas 4 e 5)
│       │   └── domain/materia.dart                        (aula 5)
│       ├── metas/data/meta_repositorio.dart               (aula 2)
│       ├── sessoes/data/sessao_dao.dart                   (aulas 4 e 5)
│       └── trilhas/data/{trilha_cache_dao.dart,trilha_repositorio.dart}  (aula 8)
└── test/
    ├── politica_de_armazenamento_test.dart                (aula 1)
    ├── meta_repositorio_test.dart                         (aula 2)
    ├── exportador_de_estudo_test.dart                     (aula 3)
    ├── banco_foco_test.dart                               (aula 4)
    ├── materia_dao_test.dart                              (aula 5)
    ├── migracoes_test.dart                                (aula 6)
    ├── cofre_test.dart                                    (aula 7)
    └── trilha_repositorio_test.dart                       (aula 8)
```

Repare que a árvore é a mesma do projeto final descrito em
[projetos/03-projeto-final-multiplataforma/01-especificacao.md](../../projetos/03-projeto-final-multiplataforma/01-especificacao.md).
O que você montar aqui é literalmente a camada de dados de lá.

### 🪟 Por que quase tudo é validado com `flutter test`

Você está no Windows e talvez ainda nem tenha um emulador Android aberto. A boa notícia é que a
camada de dados inteira deste módulo roda em **testes automatizados no seu PC**, sem emulador e
sem aparelho:

| Tecnologia | Como testar no Windows |
|---|---|
| `shared_preferences` | `SharedPreferences.setMockInitialValues({...})` |
| Arquivos + `path_provider` | O código recebe um `Directory` injetado; o teste passa uma pasta temporária |
| `sqflite` | `sqflite_common_ffi` com `inMemoryDatabasePath` |
| `flutter_secure_storage` | Um *fake* que implementa o contrato do cofre |
| `connectivity_plus` | Um *fake* que implementa o contrato de status de rede |

Isso não é um truque de curso: é a razão pela qual este módulo insiste que toda dependência entre
pelo construtor. Código testável e código desacoplado são a mesma coisa.

---

## 🗺️ Ordem recomendada das aulas

Siga **nesta ordem**. Cada aula assume a anterior e mexe no mesmo projeto.

| # | Aula | Tempo | O que entra na sua cabeça |
|---|---|---|---|
| 1 | [01 — Qual armazenamento usar](01-qual-armazenamento-usar.md) | 30 min | Árvore de decisão, o que NÃO guardar, local físico em 🤖/🍎, desinstalação, backup, tabela comparativa das 4 opções |
| 2 | [02 — shared_preferences](02-shared-preferences.md) | 40 min | `getInstance`, `setInt`/`getInt`/`setString`/`setBool`/`setStringList`, `remove`, `clear`, padrões, objeto em JSON, limitações, `setMockInitialValues` |
| 3 | [03 — Arquivos e path_provider](03-arquivos-e-path-provider.md) | 40 min | `getApplicationDocumentsDirectory` × `getTemporaryDirectory` × `getApplicationSupportDirectory`, `package:path`, `writeAsString`/`readAsString`, arquivo inexistente, 🍎 iCloud |
| 4 | [04 — sqflite: criando o banco](04-sqflite-criando-o-banco.md) | 50 min | `openDatabase`, `version`, `onCreate`, `onConfigure`, `onUpgrade`, `getDatabasesPath` + `join`, tipos do SQLite, `PRIMARY KEY`, `NOT NULL`, `DEFAULT`, índices, esquema do Foco, singleton × injeção |
| 5 | [05 — sqflite: CRUD](05-sqflite-crud.md) | 60 min | `insert` com `ConflictAlgorithm.replace`, `query` com `where`/`whereArgs`/`orderBy`/`limit`, SQL injection, `update`, `delete`, `rawQuery`, `rawUpdate`, `transaction`, `batch`, `Map` → modelo, **o bug do `ORDER BY` em português** |
| 6 | [06 — Migrações](06-migracoes.md) | 45 min | Por que o app quebra sem migração, `version` + `onUpgrade`, `ALTER TABLE ADD COLUMN`, migração em etapas, recriação de tabela, `onDowngrade`, teste com `PRAGMA table_info` |
| 7 | [07 — Dados sensíveis](07-dados-sensiveis.md) | 40 min | `flutter_secure_storage`, `read`/`write`/`delete`/`deleteAll`, 🤖 Keystore + `AndroidOptions`, 🍎 Keychain e a sobrevivência à desinstalação, limites reais, o que NUNCA fazer |
| 8 | [08 — Cache e offline](08-cache-e-offline.md) | 50 min | *cache-first* × *network-first*, carimbo de tempo, TTL, invalidação, aviso de dado antigo, `connectivity_plus`, fila de operações pendentes |

**Total: 355 min.** Todas as oito aulas são obrigatórias.

No [plano intensivo de 30 dias](../../01-plano-intensivo.md), este módulo ocupa o **dia 21**,
junto com a revisão da terceira semana.

---

## 📝 Exercícios e avaliação

| Etapa | Arquivo | Quando fazer |
|---|---|---|
| Exercícios do módulo | [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md) | Ao terminar cada aula, faça os exercícios que citam aquela aula |
| Gabarito comentado | [gabaritos/10-persistencia-de-dados.md](../../gabaritos/10-persistencia-de-dados.md) | **Só depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-10-persistencia-de-dados.md](../../avaliacoes/modulo-10-persistencia-de-dados.md) | Depois da aula 8 |
| Avaliação cumulativa | [avaliacoes/cumulativa-03-estado-e-dados.md](../../avaliacoes/cumulativa-03-estado-e-dados.md) | Dia 22 do plano, cobrindo os módulos 08, 09 e 10 |

---

## 🔗 Para onde isso vai

| Conceito deste módulo | Onde reaparece |
|---|---|
| Arquivos e pastas do app | [11 — Arquivos e compartilhamento](../11-recursos-nativos/03-arquivos-e-compartilhamento.md) |
| `connectivity_plus` | [11 — Conectividade](../11-recursos-nativos/05-conectividade.md) |
| Testar banco com `sqflite_common_ffi` | [12 — Testes unitários](../12-testes-e-debug/05-testes-unitarios.md) |
| *Fakes* para cofre e rede | [12 — Mocks e fakes](../12-testes-e-debug/07-mocks-e-fakes.md) |
| Lista grande vinda do banco | [13 — Listas grandes e imagens](../13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md) |
| Dado sensível e superfície de ataque | [13 — Segurança mobile](../13-desempenho-e-seguranca/06-seguranca-mobile.md) |
| Backup do Android no manifesto | [14 — Permissões Android](../14-build-android/05-permissoes-android.md) |
| A camada de dados do Foco, completa | [Projeto final — etapa 2](../../projetos/03-projeto-final-multiplataforma/04-etapa-2-dominio-e-dados.md) |

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir fazer **sem consultar a aula**:

- [ ] Recebo um requisito ("guardar o tema escolhido", "guardar 3 mil sessões", "guardar o token")
      e digo em qual das quatro opções ele vai, com justificativa.
- [ ] Explico onde `shared_preferences`, arquivos, `sqflite` e `flutter_secure_storage` gravam
      fisicamente em 🤖 Android e em 🍎 iOS.
- [ ] Sei dizer o que sobrevive à desinstalação em cada plataforma e o que entra no backup.
- [ ] Leio e escrevo `int`, `String`, `bool` e `List<String>` com `shared_preferences`, com valor
      padrão quando a chave não existe.
- [ ] Guardo um objeto como JSON em `String` e explico por que isso **não** substitui um banco.
- [ ] Escolho entre documentos, suporte e temporário sem consultar tabela.
- [ ] Monto caminho de arquivo com `p.join` e nunca com `'/'` concatenado na mão.
- [ ] Trato o caso "o arquivo ainda não existe" sem deixar exceção vazar para a interface.
- [ ] Abro um banco com `openDatabase` declarando `version`, `onCreate`, `onConfigure` e
      `onUpgrade`, e ligo `PRAGMA foreign_keys = ON`.
- [ ] Escrevo `CREATE TABLE` com `PRIMARY KEY`, `NOT NULL`, `DEFAULT`, chave estrangeira e índice,
      e explico o que cada tipo do SQLite armazena.
- [ ] Faço `insert`, `query`, `update` e `delete` **sempre** com `?` e `whereArgs`.
- [ ] Uso `ConflictAlgorithm.replace` quando quero "insere ou substitui".
- [ ] Uso `transaction` quando duas escritas precisam valer como uma só.
- [ ] Explico por que `ORDER BY nome` coloca `Física` antes de `Álgebra` e implemento a coluna
      `nome_ordenacao`, sabendo comparar essa solução com ordenar em Dart.
- [ ] Escrevo uma migração em etapas com `if (anterior < 2)` e `if (anterior < 3)` e testo com
      `PRAGMA table_info`.
- [ ] Nunca altero uma migração já publicada — crio a próxima.
- [ ] Guardo token e senha só no `flutter_secure_storage`, nunca em `shared_preferences`, nunca
      em log, nunca no Git.
- [ ] Implemento *cache-first* com carimbo de tempo e TTL, e mostro aviso de dado antigo.
- [ ] Explico por que `connectivity_plus` informa que **existe interface de rede**, e não que a
      internet funciona.
- [ ] Todos os exercícios **obrigatórios** de
      [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md)
      estão feitos.
- [ ] Acertei ao menos 7 das 10 questões de
      [avaliacoes/modulo-10-persistencia-de-dados.md](../../avaliacoes/modulo-10-persistencia-de-dados.md).
- [ ] `flutter analyze` no `foco_dados` termina com `No issues found!` e `flutter test` termina
      com `All tests passed!`.

Quando todos estiverem marcados, siga para o
[Módulo 11 — Recursos Nativos](../11-recursos-nativos/README.md).

---

## 📚 Referências oficiais do módulo

- [Store key-value data on disk — docs.flutter.dev](https://docs.flutter.dev/cookbook/persistence/key-value)
- [Read and write files — docs.flutter.dev](https://docs.flutter.dev/cookbook/persistence/reading-writing-files)
- [Persist data with SQLite — docs.flutter.dev](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [shared_preferences — pub.dev](https://pub.dev/packages/shared_preferences)
- [path_provider — pub.dev](https://pub.dev/packages/path_provider)
- [path — pub.dev](https://pub.dev/packages/path)
- [sqflite — pub.dev](https://pub.dev/packages/sqflite)
- [sqflite_common_ffi — pub.dev](https://pub.dev/packages/sqflite_common_ffi)
- [flutter_secure_storage — pub.dev](https://pub.dev/packages/flutter_secure_storage)
- [connectivity_plus — pub.dev](https://pub.dev/packages/connectivity_plus)
- [SQLite Datatypes — sqlite.org](https://www.sqlite.org/datatype3.html)
- [SQLite ALTER TABLE — sqlite.org](https://www.sqlite.org/lang_altertable.html)
- [Back up user data with Auto Backup — developer.android.com](https://developer.android.com/guide/topics/data/autobackup)
- [File System Programming Guide — developer.apple.com](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 09 — Consumo de API](../09-consumo-de-api/README.md) | [README do curso](../../README.md) | [Aula 1 — Qual armazenamento usar](01-qual-armazenamento-usar.md) |
