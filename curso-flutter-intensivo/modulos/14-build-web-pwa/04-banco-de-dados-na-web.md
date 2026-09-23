# Aula 4 — Banco de dados na web

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 50 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que o `sqflite` não funciona na web e o que o **`sqflite_common_ffi_web`** faz no
  lugar dele: SQLite compilado para WebAssembly, persistido em **IndexedDB**.
- Trocar a **factory** do banco do Foco por importação condicional, mantendo **os DAOs, o SQL e as
  migrações do Módulo 10 sem uma linha alterada**.
- Rodar o `setup` que instala `sqlite3.wasm` e `sqflite_sw.js` em `web/`, e entender por que esses
  dois arquivos precisam existir.
- Entender onde o banco fica guardado, o que **sobrevive a um F5**, o que some e o que o navegador
  pode **despejar** sozinho.
- Pedir **armazenamento persistente** ao navegador e medir a cota disponível.
- Reconhecer o limite real: um banco por **origem**, e o que acontece quando a URL muda.

## ✅ Pré-requisitos

- [Aula 3 — O que não funciona na web](03-o-que-nao-funciona-na-web.md) — o padrão de importação
  condicional desta aula é o mesmo do exportador de lá.
- [Módulo 10 — Persistência de dados](../10-persistencia-de-dados/README.md) inteiro, em especial
  [05 — CRUD com sqflite](../10-persistencia-de-dados/05-sqflite-crud.md) e
  [06 — Migrações](../10-persistencia-de-dados/06-migracoes.md).
- O Foco com `BancoFoco`, `MateriaDao` e `SessaoDao` funcionando no Android, conforme a
  [Etapa 2 do projeto final](../../projetos/03-projeto-final-multiplataforma/04-etapa-2-dominio-e-dados.md).

---

## 📖 Conceito

### Por que o `sqflite` não funciona na web

O `sqflite` é um **plugin**: código Dart de um lado, código nativo do outro, conversando por
*platform channel*. No Android, o outro lado é uma biblioteca C do SQLite que já vem no sistema.

```text
🤖 Android                          🌐 Web
┌─────────────┐                     ┌─────────────┐
│  Seu Dart   │                     │  Seu Dart   │
├─────────────┤                     ├─────────────┤
│  sqflite    │                     │  sqflite    │
├─────────────┤                     ├─────────────┤
│  Channel    │                     │  Channel    │
├─────────────┤                     ├─────────────┤
│ SQLite (C)  │  ← existe no SO     │     ???     │  ← o navegador não tem SQLite
└─────────────┘                     └─────────────┘
                                          💥 MissingPluginException
```

O navegador não tem SQLite. Não é uma omissão do Flutter — é que a plataforma não oferece.

### O que o `sqflite_common_ffi_web` faz

A solução é levar o SQLite junto. O pacote **compila o SQLite para WebAssembly** e o carrega no
navegador, exatamente como o CanvasKit carrega o Skia
([Aula 2](02-como-o-flutter-compila-para-web.md)).

```text
🌐 Web, com sqflite_common_ffi_web
┌─────────────────────────────────────┐
│  Seu Dart — DAOs e SQL INALTERADOS  │
├─────────────────────────────────────┤
│  sqflite_common (a interface)       │
├─────────────────────────────────────┤
│  sqflite_common_ffi_web             │
├─────────────────────────────────────┤
│  sqlite3.wasm   ← SQLite de verdade │
├─────────────────────────────────────┤
│  IndexedDB      ← onde os bytes     │
│                    ficam guardados  │
└─────────────────────────────────────┘
```

Duas peças importantes:

| Peça | O que é | Por que existe |
|---|---|---|
| **`sqlite3.wasm`** | O SQLite compilado para WASM | É o motor. Sem ele, não há SQL. |
| **`sqflite_sw.js`** | Um *service worker* dedicado ao banco | Roda o SQLite fora da thread da UI, para a interface não travar |
| **IndexedDB** | Banco chave-valor do navegador | É onde o **arquivo** do SQLite é gravado, em blocos |

> 📌 **Note a inversão:** no Android, o SQLite grava um arquivo `foco.db` no disco. Na web, o
> SQLite acha que está gravando um arquivo — mas cada bloco vai parar no IndexedDB. Para o seu SQL,
> nada muda. `SUM`, `GROUP BY`, `ON DELETE CASCADE` e as três migrações do Foco funcionam idênticos.

> ⚠️ **`sqflite_sw.js` é um service worker diferente do da [Aula 6](06-service-worker-e-offline.md).**
> São dois, com papéis distintos: um cuida do banco, o outro cuida do cache do app. Confundir os
> dois ao depurar custa tempo — o DevTools lista ambos.

### A parte que não muda: os DAOs

Esta é a razão de a arquitetura do Foco ter valido a pena. A
[ADR-05](../../projetos/03-projeto-final-multiplataforma/02-arquitetura.md) dizia:

> *Trocar `sqflite` mexe em uma pasta — o contrato em `domain/` continua igual.*

Agora essa frase vai ser cobrada. O que muda:

| Arquivo | Muda? | O quê |
|---|---|---|
| `lib/core/banco/banco_foco.dart` | ✅ Sim | Usa uma factory escolhida por plataforma |
| `lib/core/banco/factory_banco*.dart` | ✅ **Novos** | Três arquivos de importação condicional |
| `lib/features/materias/data/materia_dao.dart` | ⚠️ Uma linha | Só o `import` do tipo `Database` |
| `lib/features/sessoes/data/sessao_dao.dart` | ⚠️ Uma linha | Idem |
| Todo o SQL, migrações e `PRAGMA` | ❌ **Não** | Zero alteração |
| `domain/`, `presentation/`, providers | ❌ **Não** | Zero alteração |

**Duas linhas de import e um arquivo de bootstrap.** É isso.

### Onde o banco fica e o que sobrevive

```text
Origem: https://seu-usuario.github.io
   └── IndexedDB
        └── sqflite_databases
             └── foco.db   ← os blocos do arquivo SQLite
```

| Evento | O banco sobrevive? |
|---|---|
| F5 / recarregar a página | ✅ Sim |
| Fechar e reabrir o navegador | ✅ Sim |
| Reiniciar o computador | ✅ Sim |
| Aba anônima / privada | ❌ Some ao fechar |
| Usuário limpa "dados de navegação" | ❌ Some |
| Navegador despeja por falta de espaço | ⚠️ **Pode sumir** |
| Outro navegador no mesmo aparelho | ❌ É outro banco |
| A **URL do app muda** | ❌ **É outro banco** |

> ⚠️ **A última linha é a mais séria e a mais esquecida.** O armazenamento é por **origem** —
> protocolo + domínio + porta. Se você publica em `seu-usuario.github.io/foco/` e depois migra para
> `foco.com.br`, todo mundo que já usava **começa do zero**: matérias, sessões e meta ficam na
> origem antiga, inacessíveis a partir da nova. Escolher a URL definitiva é, na web, o equivalente a
> escolher o `applicationId` no Android ([Módulo 15, aula 2](../15-build-android/02-identidade-do-app.md)):
> uma decisão que você não desfaz sem perder usuários.

### Cota e despejo

O navegador dá espaço, mas não promete guardá-lo. Sob pressão de disco, ele **despeja** dados de
sites — começando pelos menos usados.

| Modo | Comportamento |
|---|---|
| **`best-effort`** (padrão) | Pode ser despejado quando o disco encher |
| **`persistent`** | Só sai se o usuário apagar explicitamente |

Você **pede** o modo persistente:

```dart
final bool concedido = await web.window.navigator.storage.persist().toDart;
```

| Navegador | Como decide |
|---|---|
| Chrome/Edge | Concede se o PWA estiver **instalado**, ou por engajamento alto |
| Firefox | **Pergunta** ao usuário |
| Safari | Concede por heurística; expira sem uso por semanas |

> 💡 **Instalar o PWA é a melhor forma de conseguir armazenamento persistente no Chrome.** Isso liga
> a [Aula 7](07-instalabilidade.md) diretamente a esta: instalabilidade não é enfeite, é o que
> protege o banco do usuário. Vale dizer isso na interface — "instale para não perder seus dados" é
> um argumento honesto.

E dá para medir o espaço:

```dart
final estimativa = await web.window.navigator.storage.estimate().toDart;
// estimativa.usage  → bytes usados
// estimativa.quota  → bytes disponíveis (tipicamente vários GB)
```

---

## 💡 Analogia

Pense em um arquivo de aço com fichas de papel.

- **No Android**, o arquivo de aço já está na sala. O SQLite abre a gaveta, procura a ficha, escreve
  e fecha. A sala é sua, a gaveta é sua.
- **Na web, não existe arquivo de aço.** Existe um **guarda-volumes com armários numerados** — o
  IndexedDB. Ele não sabe o que é ficha, nem ordem alfabética, nem consulta: guarda caixas
  numeradas e devolve a caixa N quando você pede.
- **O `sqlite3.wasm` é um arquivista que você leva junto.** Ele conhece as fichas, sabe fazer
  `GROUP BY` e `ON DELETE CASCADE` — e, como não tem arquivo de aço, aprendeu a picar o arquivo em
  caixas e guardar no guarda-volumes. Quando você pede uma consulta, ele busca as caixas certas,
  remonta e responde. **Para você, é o mesmo arquivista de sempre** — por isso o seu SQL não muda.
- **O `sqflite_sw.js` é o ajudante** que carrega as caixas enquanto o atendimento continua. Sem ele,
  o arquivista pararia a fila inteira a cada consulta pesada — na web, "parar a fila" é travar a
  animação.
- **E a cota** é a regra do guarda-volumes: enquanto há espaço, tudo bem; quando lota, o gerente
  esvazia os armários de quem não aparece há meses. **Pedir `persist()`** é assinar um contrato de
  armário fixo — e o gerente costuma assinar com quem virou cliente frequente, isto é, **instalou
  o app**.

---

## 🧪 Exemplo mínimo

**1. Adicione as dependências:**

```yaml
dependencies:
  sqflite: ^2.4.4                 # continua, para Android/iOS
  sqflite_common: ^2.5.5          # os TIPOS, comuns aos dois mundos
  sqflite_common_ffi_web: ^1.0.0  # o SQLite em WASM, para a web
```

```powershell
flutter pub get
```

**2. Instale os arquivos WASM em `web/`:**

```powershell
dart run sqflite_common_ffi_web:setup
```

```text
Downloading sqlite3.wasm...
Writing web/sqlite3.wasm
Writing web/sqflite_sw.js
Done.
```

```powershell
Get-ChildItem .\web\ -Filter "sq*"
```

```text
Name              Length
----              ------
sqflite_sw.js      12843
sqlite3.wasm     1298432
```

> ⚠️ **Esses dois arquivos vão para o Git.** Diferente de `build/`, a pasta `web/` é versionada — e
> o deploy da [Aula 9](09-publicando-no-github-pages.md) compila a partir do repositório. Se eles
> não estiverem commitados, o build do GitHub Actions gera um app que não abre o banco. É uma das
> falhas mais irritantes de diagnosticar, porque funciona perfeitamente na sua máquina.

**3. Confirme no navegador:**

Rode o app, crie uma matéria, e abra F12 → **Application** → **Storage** → **IndexedDB**:

```text
IndexedDB
└── sqflite_databases
     └── files
          └── /foco.db   ← os blocos
```

Aperte **F5**. A matéria continua lá.

---

## 📱 Aplicando no Flutter

### O `+1` do tamanho

O `sqlite3.wasm` tem ~1,3 MB. Ele entra no caminho crítico do primeiro carregamento
([Aula 2](02-como-o-flutter-compila-para-web.md))?

| Arquivo | Baixado quando |
|---|---|
| `main.dart.js` | Imediatamente |
| `canvaskit.wasm` | Imediatamente |
| **`sqlite3.wasm`** | **Na primeira abertura do banco** |

Ele é carregado sob demanda, quando `BancoFoco.abrir()` roda. Como isso acontece no `main()` do
Foco, na prática é quase imediato — mas **depois** do primeiro quadro, o que significa que a tela de
abertura já apareceu. Se o seu app pode adiar a abertura do banco, adie.

> 💡 **Para o Foco, não vale otimizar isso.** O app precisa das matérias na primeira tela. Adiar a
> abertura do banco renderia uns 200 ms e custaria um estado de carregamento a mais em toda a
> árvore. Meça antes de complicar — é a lição do
> [Módulo 13, aula 4](../13-desempenho-e-seguranca/04-medindo-desempenho.md).

---

## 💻 Código completo

Quatro arquivos: três da factory condicional, um do bootstrap alterado.

> **Arquivo:** `lib/core/banco/factory_banco.dart` (novo)
> **Como executar:** `flutter run -d chrome` e `flutter run -d <android>` — o mesmo banco, dois motores

```dart
/// Escolhe, em tempo de COMPILAÇÃO, como o banco é aberto.
///
/// Mesmo padrão do exportador da Aula 3. É obrigatório aqui porque
/// sqflite_common_ffi_web importa bibliotecas que só existem na web,
/// e sqflite importa plugin nativo que não existe na web. Os dois no
/// mesmo arquivo quebrariam os dois builds.
export 'factory_banco_stub.dart'
    if (dart.library.io) 'factory_banco_io.dart'
    if (dart.library.js_interop) 'factory_banco_web.dart';
```

> **Arquivo:** `lib/core/banco/factory_banco_stub.dart` (novo)

```dart
import 'package:sqflite_common/sqlite_api.dart';

/// Contrato. Nunca roda; existe para dar assinatura e falhar legível.
DatabaseFactory get fabricaDoBanco => throw UnsupportedError(
      'Sem factory de banco para esta plataforma. '
      'Veja as condições em factory_banco.dart.',
    );

Future<String> caminhoDoBanco(String nomeDoArquivo) => throw UnsupportedError(
      'Sem caminho de banco para esta plataforma.',
    );
```

> **Arquivo:** `lib/core/banco/factory_banco_io.dart` (novo)

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqlite_api.dart';

/// 🤖🍎 Android/iOS: o plugin sqflite de sempre, sem mudança nenhuma.
DatabaseFactory get fabricaDoBanco => sqflite.databaseFactory;

/// Caminho real no sistema de arquivos do aparelho.
Future<String> caminhoDoBanco(String nomeDoArquivo) async {
  final String pasta = await sqflite.getDatabasesPath();
  return p.join(pasta, nomeDoArquivo);
}
```

> **Arquivo:** `lib/core/banco/factory_banco_web.dart` (novo)

```dart
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// 🌐 Web: SQLite em WebAssembly, persistido em IndexedDB.
///
/// databaseFactoryFfiWeb usa o web worker de sqflite_sw.js, o que tira
/// o SQL da thread da UI. Existe databaseFactoryFfiWebNoWebWorker para
/// depurar — use só para isolar problema, nunca em produção: sem o
/// worker, uma consulta pesada trava a animação.
DatabaseFactory get fabricaDoBanco => databaseFactoryFfiWeb;

/// Na web não existe pasta. O "caminho" é só um nome de chave dentro
/// do IndexedDB da origem — por isso é o nome puro, sem p.join.
Future<String> caminhoDoBanco(String nomeDoArquivo) async => nomeDoArquivo;
```

E o bootstrap, que é o **único arquivo existente alterado de verdade**:

> **Arquivo:** `lib/core/banco/banco_foco.dart` (alterado)

```dart
import 'package:sqflite_common/sqlite_api.dart';

import 'factory_banco.dart';

class BancoFoco {
  const BancoFoco._();

  /// Versão do ESQUEMA — inalterada. As três migrações do Módulo 10
  /// valem igual na web: o SQLite é o mesmo, só o meio de gravação mudou.
  static const int versaoAtual = 3;
  static const String nomeDoArquivo = 'foco.db';

  static Future<Database> abrir() async {
    final String caminho = await caminhoDoBanco(nomeDoArquivo);

    // ⭐ A diferença em relação à Etapa 2: em vez do openDatabase()
    // de nível superior do sqflite (que fala com o plugin nativo e
    // não existe na web), pedimos à FACTORY para abrir. As opções
    // são exatamente as mesmas, só mudaram de lugar.
    return fabricaDoBanco.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versaoAtual,
        onConfigure: configurar,
        onCreate: criar,
        onUpgrade: atualizar,
      ),
    );
  }

  /// ⚠️ Continua obrigatório na web: o SQLite nasce com chave
  /// estrangeira desligada em QUALQUER plataforma. Sem esta linha,
  /// o ON DELETE CASCADE não acontece e sobram sessões órfãs.
  static Future<void> configurar(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // criar() e atualizar() ficam EXATAMENTE como estavam.
  // Nenhuma linha de SQL muda. Nenhuma migração muda.
}
```

E nos DAOs, só o import do tipo:

> **Arquivo:** `lib/features/materias/data/materia_dao.dart` (alterado — uma linha)

```dart
// ANTES: import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

// O resto do arquivo — todo o CRUD, os ORDER BY, os SUM — fica igual.
// `Database`, `Transaction` e `ConflictAlgorithm` vêm de sqflite_common;
// o pacote sqflite apenas os reexportava.
class MateriaDao {
  const MateriaDao(this._db);
  final Database _db;
  // …
}
```

Por fim, o pedido de persistência, que vale a pena fazer uma vez:

> **Arquivo:** `lib/core/banco/persistencia_web.dart` (novo)

```dart
/// Pede ao navegador para NÃO despejar os dados do app.
export 'persistencia_stub.dart'
    if (dart.library.js_interop) 'persistencia_web_impl.dart';
```

> **Arquivo:** `lib/core/banco/persistencia_stub.dart` (novo)

```dart
/// Em plataformas nativas o dado já é persistente: nada a pedir.
Future<bool> pedirArmazenamentoPersistente() async => true;

Future<(int usados, int cota)?> estimarArmazenamento() async => null;
```

> **Arquivo:** `lib/core/banco/persistencia_web_impl.dart` (novo)

```dart
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Pede modo `persistent`. O navegador decide — e costuma conceder
/// quando o PWA está instalado (Aula 7). Chamar isso não incomoda o
/// usuário no Chrome; no Firefox, gera um pedido visível.
Future<bool> pedirArmazenamentoPersistente() async {
  try {
    return await web.window.navigator.storage.persist().toDart;
  } catch (_) {
    // Navegador antigo sem a API: seguimos em best-effort.
    return false;
  }
}

/// Quanto o app já ocupa e quanto ainda tem. Útil para avisar o usuário
/// antes de o navegador decidir por ele.
Future<(int usados, int cota)?> estimarArmazenamento() async {
  try {
    final web.StorageEstimate e =
        await web.window.navigator.storage.estimate().toDart;
    return (e.usage, e.quota);
  } catch (_) {
    return null;
  }
}
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `sqflite_common` nos DAOs | `Database` e companhia sempre moraram lá; `sqflite` só reexportava. Trocar o import desacopla o DAO do plugin nativo. |
| `fabricaDoBanco.openDatabase(...)` | O `openDatabase()` de nível superior do `sqflite` fala com o plugin nativo. A factory é a mesma API, com o motor injetado. |
| `OpenDatabaseOptions` | As mesmas `version`, `onConfigure`, `onCreate`, `onUpgrade` — só migraram de argumentos nomeados para um objeto. |
| `caminhoDoBanco` retornar o nome puro na web | Não há pasta; o "caminho" é uma chave no IndexedDB. `p.join` produziria uma chave com barra à toa. |
| `databaseFactoryFfiWeb` (com worker) | Tira o SQL da thread da UI. A variante sem worker existe para depurar, e **trava a animação**. |
| `PRAGMA foreign_keys = ON` mantido | O SQLite desliga FK por padrão em toda plataforma. A web não é exceção. |
| Stub lançando `UnsupportedError` | Mesma lição da Aula 3: falha legível, com o nome do arquivo a criar. |
| `persist()` em `try/catch` | A API não existe em navegadores antigos; a ausência dela não pode derrubar o app. |
| `estimarArmazenamento` devolvendo *record* | `(int, int)?` evita criar uma classe para dois números — Dart 3, como no [Módulo 04](../04-dart-avancado/README.md). |
| Nenhuma mudança em `domain/` | É a prova da ADR-05. Se algum arquivo de `domain/` tivesse mudado, a arquitetura teria falhado. |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| Motor SQLite | `sqlite3.wasm` (baixado) | Do sistema | Do sistema |
| Onde grava | **IndexedDB** | Arquivo em `databases/` | Arquivo no sandbox |
| Fora da thread de UI | Web worker (`sqflite_sw.js`) | Thread nativa | Thread nativa |
| Some se o usuário limpar dados | ✅ **Sim** | Só se desinstalar | Só se desinstalar |
| Pode ser despejado pelo sistema | ⚠️ **Sim** (best-effort) | ❌ | ⚠️ Raramente |
| Escopo | **Por origem (URL)** | Por `applicationId` | Por *Bundle ID* |
| Backup automático | ❌ | ⚠️ Android Backup | ⚠️ iCloud |
| Seu SQL | ✅ Idêntico | ✅ | ✅ |

> ⚠️ **"Some se o usuário limpar dados" é uma diferença de expectativa, não só técnica.** Limpar
> dados de navegação é uma ação corriqueira — muita gente faz por hábito. Desinstalar um app é
> deliberado. Um PWA que guarda algo que o usuário não pode perder precisa de **sincronização com
> servidor** ou de **exportação** (o exportador da [Aula 3](03-o-que-nao-funciona-na-web.md) é
> exatamente isso). Para o Foco, que é pessoal e local, exportar CSV é a rede de segurança
> proporcional.

🪟 **No Windows**, esta aula funciona por completo.

---

## ⚠️ Erros comuns

### 1. Esquecer `dart run sqflite_common_ffi_web:setup`

```text
Failed to load sqlite3.wasm
```

**Correção:** rode o setup; confira `web/sqlite3.wasm` e `web/sqflite_sw.js`.

### 2. Não commitar `sqlite3.wasm` e `sqflite_sw.js`

Funciona na sua máquina, quebra no deploy.

**Correção:** `git add web/sqlite3.wasm web/sqflite_sw.js`.

### 3. Manter `import 'package:sqflite/sqflite.dart'` nos DAOs

Arrasta o plugin nativo para o build web.

**Correção:** `package:sqflite_common/sqlite_api.dart`.

### 4. Usar `openDatabase()` de nível superior

Fala com o plugin; não existe na web.

**Correção:** `fabricaDoBanco.openDatabase(...)`.

### 5. Usar `getDatabasesPath()` na web

`MissingPluginException`.

**Correção:** o caminho web é só o nome do arquivo.

### 6. Usar `databaseFactoryFfiWebNoWebWorker` em produção

SQL na thread da UI; a animação trava.

**Correção:** só para depurar.

### 7. Esquecer o `PRAGMA foreign_keys = ON`

Sessões órfãs, sem erro nenhum.

**Correção:** mantenha o `onConfigure` — vale na web igual.

### 8. Testar em aba anônima e achar que o banco não persiste

Aba anônima descarta tudo ao fechar, por definição.

**Correção:** teste em janela normal.

### 9. Assumir que o dado está garantido

Modo padrão é `best-effort`.

**Correção:** `persist()` + exportação.

### 10. Mudar a URL do app depois de ter usuários

Banco novo, vazio; o antigo fica inacessível.

**Correção:** decida a URL definitiva **antes** ([Aula 9](09-publicando-no-github-pages.md)).

### 11. Confundir `sqflite_sw.js` com o service worker do app

São dois, com papéis diferentes.

**Correção:** leia o *scope* de cada um no DevTools.

### 12. Achar que precisa reescrever as migrações

O SQLite é o mesmo.

**Correção:** `onUpgrade` intacto.

---

## 🛠️ Exercício guiado

**Passo 1.** Adicione `sqflite_common` e `sqflite_common_ffi_web` ao `pubspec.yaml` e rode
`flutter pub get`.

**Passo 2.** Rode `dart run sqflite_common_ffi_web:setup`. Confirme os dois arquivos em `web/`.

**Passo 3.** Crie os três arquivos de `factory_banco*`. Compile para web: passa?

**Passo 4.** Altere `BancoFoco.abrir()` para usar a factory. Rode `flutter run -d chrome`.

**Passo 5.** Crie duas matérias e uma sessão. Aperte **F5**. Os dados continuam?

**Passo 6.** Abra F12 → Application → IndexedDB. Ache `sqflite_databases`. O que tem dentro?

**Passo 7.** Rode o app **também** no Android. As matérias do Chrome aparecem lá? Explique por quê.

**Passo 8.** Troque `databaseFactoryFfiWeb` por `databaseFactoryFfiWebNoWebWorker`, insira 5 000
sessões num laço e observe a animação. Depois volte.

**Passo 9.** Chame `estimarArmazenamento()` e imprima `usados` e `cota`. Quantos MB o Foco ocupa?

**Passo 10.** Abra o app em **janela anônima**, crie uma matéria, feche e reabra. Sumiu? Por quê?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Aplicação** (a factory condicional), **Correção de bugs** (`getDatabasesPath` na web) e
**Reflexão** (o que fazer com dado que não pode ser perdido).

---

## 🏆 Desafio opcional

Implemente **backup e restauração** do banco do Foco, funcionando nos três alvos.

Requisitos:

- Um botão "Exportar dados" que gere um JSON com matérias, sessões e a meta.
- Na web, o download pelo `Blob` da [Aula 3](03-o-que-nao-funciona-na-web.md); no Android, arquivo
  em disco. **Mesma interface**, por importação condicional.
- Um botão "Importar dados" que leia o JSON e recrie tudo — **dentro de uma transação**, para não
  deixar o banco pela metade se falhar no meio.
- O JSON precisa carregar a **versão do esquema**. Importar um backup de versão diferente da atual
  deve ser recusado com mensagem clara, não com `DatabaseException`.
- Chame `pedirArmazenamentoPersistente()` na primeira execução e registre o resultado.
- Se `persist()` devolver `false`, mostre um aviso discreto sugerindo instalar o app.
- Mostre o espaço ocupado numa tela de configurações.

Depois responda: o seu "importar" é **idempotente** — importar o mesmo arquivo duas vezes gera
duplicatas? Se gera, o que você usaria para resolver: `INSERT OR REPLACE`, uma tabela de
`id_externo`, ou limpar antes de importar? Justifique pelo que acontece se o usuário importar um
backup **antigo** por engano.

---

## 📌 Resumo

- `sqflite` é um **plugin nativo**; o navegador não tem SQLite, então ele não funciona na web.
- **`sqflite_common_ffi_web`** carrega o **SQLite compilado para WebAssembly** e o persiste em
  **IndexedDB**.
- São duas peças em `web/`: **`sqlite3.wasm`** (o motor) e **`sqflite_sw.js`** (o worker que tira o
  SQL da thread da UI). Rode `dart run sqflite_common_ffi_web:setup` e **commite os dois**.
- O seu **SQL, migrações e `PRAGMA` não mudam**. O que muda: o bootstrap usa uma **factory** e os
  DAOs importam `sqflite_common` em vez de `sqflite`.
- Isso é a ADR-05 sendo cobrada — e paga: `domain/` e `presentation/` não mudaram nada.
- `fabricaDoBanco.openDatabase(caminho, options: OpenDatabaseOptions(...))` substitui o
  `openDatabase()` de nível superior.
- Na web **não há pasta**: o "caminho" é só o nome do arquivo.
- O banco **sobrevive** a F5, fechar o navegador e reiniciar a máquina. **Some** em aba anônima, ao
  limpar dados de navegação, e **pode ser despejado** no modo padrão `best-effort`.
- **Peça `persist()`** — e instalar o PWA é o que mais ajuda a consegui-lo no Chrome.
- O armazenamento é **por origem**. Mudar a URL do app = banco novo e vazio, como trocar o
  `applicationId` no Android.
- Dado que não pode ser perdido precisa de **servidor ou exportação**. Para o Foco, exportar é
  proporcional.

---

## ☑️ Checklist de domínio

- [ ] Explico por que o `sqflite` não funciona na web.
- [ ] Digo o que `sqlite3.wasm` e `sqflite_sw.js` fazem, cada um.
- [ ] Sei que os dois arquivos precisam ser commitados e por quê.
- [ ] Escrevo a factory condicional com stub, `_io` e `_web`.
- [ ] Explico por que os DAOs passam a importar `sqflite_common`.
- [ ] Abro o banco por `fabricaDoBanco.openDatabase` com `OpenDatabaseOptions`.
- [ ] Meu SQL e minhas migrações não mudaram, e sei explicar por quê.
- [ ] Encontro o banco no DevTools → Application → IndexedDB.
- [ ] Listo o que faz o banco sobreviver e o que o apaga.
- [ ] Explico a diferença entre `best-effort` e `persistent`, e como pedir.
- [ ] Relaciono instalar o PWA com proteger os dados.
- [ ] Explico por que mudar a URL do app apaga os dados dos usuários.

---

## 📚 Referências oficiais

- [sqflite_common_ffi_web — pub.dev](https://pub.dev/packages/sqflite_common_ffi_web)
- [sqflite — pub.dev](https://pub.dev/packages/sqflite)
- [sqlite3 WebAssembly — sqlite.org](https://sqlite.org/wasm/doc/trunk/index.md)
- [IndexedDB API — MDN](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
- [Storage quotas and eviction criteria — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria)
- [Persistent storage — web.dev](https://web.dev/articles/persistent-storage)
- [StorageManager.persist() — MDN](https://developer.mozilla.org/en-US/docs/Web/API/StorageManager/persist)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [O que não funciona na web](03-o-que-nao-funciona-na-web.md) | [README](README.md) | [Manifest e ícones](05-manifest-e-icones.md) |
