# Aula 6 — Service worker e offline

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 50 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar o que é um **service worker**, onde ele roda e por que ele é a peça que torna um site
  capaz de funcionar sem internet.
- Ler o **`flutter_service_worker.js`** gerado e entender o mapa `RESOURCES`, o `CORE` e o papel dos
  hashes.
- Descrever o **ciclo de vida** — `install` → `activate` → `fetch` — e o que o Flutter faz em cada
  etapa.
- Explicar por que o usuário vê a versão nova **só na segunda abertura**, e implementar um aviso de
  "nova versão disponível".
- Separar **offline de aplicação** (o service worker) de **offline de dados** (o IndexedDB da
  [Aula 4](04-banco-de-dados-na-web.md)) e de **offline de API**.
- Escolher entre `--pwa-strategy=offline-first` e `none`, e saber quando desligar o service worker é
  a decisão certa.
- Depurar cache preso com as ferramentas do DevTools.

## ✅ Pré-requisitos

- [Aula 5 — Manifest e ícones](05-manifest-e-icones.md).
- [Aula 4 — Banco de dados na web](04-banco-de-dados-na-web.md) — o `sqflite_sw.js` de lá é um
  service worker **diferente** deste; esta aula deixa a distinção clara.
- [Módulo 09, aula 8 — Cache e offline](../09-consumo-de-api/README.md) — o cache de trilhas do
  Foco, que é um terceiro nível de offline.

---

## 📖 Conceito

### O que é um service worker

É um **script JavaScript que o navegador roda separado da sua página**, sem acesso ao DOM, e que
continua registrado depois de a aba fechar. O superpoder dele é um só, e é enorme:

```text
Toda requisição que a sua página faz passa por ele ANTES de ir à rede.
```

```text
        sem service worker                     com service worker
  ┌──────────┐                           ┌──────────┐
  │  página  │──── GET main.dart.js ───► │  página  │───┐
  └──────────┘                           └──────────┘   │
        │                                               ▼
        ▼                                        ┌─────────────┐
     🌐 rede                                      │   service   │  "tenho no
                                                  │   worker    │   cache?"
     sem rede = ❌                                └─────────────┘
                                                    │        │
                                                 sim│        │não
                                                    ▼        ▼
                                                 cache     🌐 rede

                                              sem rede = ✅ ainda funciona
```

É por isso que ele é requisito de PWA: sem um service worker que responda a `fetch`, o navegador não
tem como garantir que o app abre offline — e não oferece instalação.

> ⚠️ **Não confunda com o `sqflite_sw.js` da [Aula 4](04-banco-de-dados-na-web.md).** São dois
> service workers com papéis distintos: aquele executa SQL fora da thread da UI; este intercepta
> rede e serve cache. Os dois aparecem no DevTools, e depurar o errado custa meia hora.

### O que o Flutter gera

O `flutter build web` produz o `flutter_service_worker.js` automaticamente. Ele tem esta cara:

```javascript
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {
  "index.html": "a3f9c1e8b2d47506...",
  "main.dart.js": "7e21b0a9f4c83d15...",
  "assets/AssetManifest.bin.json": "c04d8e7a...",
  "canvaskit/canvaskit.wasm": "9b1f3e2d...",
  ...
};

// Os arquivos sem os quais o app nem abre.
const CORE = [
  "main.dart.js",
  "index.html",
  "flutter_bootstrap.js",
  "assets/AssetManifest.bin.json",
  "assets/FontManifest.json"
];
```

| Peça | O que é |
|---|---|
| `RESOURCES` | **Todo** arquivo do build, com o **hash do conteúdo** |
| `CORE` | O subconjunto sem o qual o app não abre |
| Os hashes | Mudam quando o conteúdo muda — é assim que ele sabe o que rebaixar |

> 📌 **O hash é o mecanismo de versão.** Você não precisa incrementar nada à mão: se
> `main.dart.js` mudou um byte, o hash muda, e o service worker entende que aquele recurso está
> desatualizado. É o mesmo princípio do `versionCode` do Android
> ([Módulo 15, aula 8](../15-build-android/08-gerando-apk-e-aab.md)), só que automático e por
> arquivo.

### O ciclo de vida

```text
   novo build publicado
          │
          ▼
   ┌─────────────┐
   │   install   │  baixa o CORE para um cache temporário
   └─────────────┘  o Flutter chama skipWaiting() aqui
          │
          ▼
   ┌─────────────┐
   │  activate   │  compara o manifest antigo com o novo,
   └─────────────┘  baixa o que mudou, apaga o que sumiu,
          │         e chama clients.claim()
          ▼
   ┌─────────────┐
   │    fetch    │  a partir daqui, intercepta tudo
   └─────────────┘
```

E agora **a consequência que dá mais dor de cabeça em PWA**:

```text
Você publica a v2 às 14h00.

14h05 — usuário abre o app
        │
        ├─► a página é servida do cache: ele vê a v1  ⚠️
        │
        └─► EM PARALELO, o SW baixa a v2, ativa e assume o controle

14h06 — usuário fecha o app, satisfeito, tendo usado a v1

19h30 — usuário abre de novo
        │
        └─► agora sim: v2 ✅
```

**A versão nova aparece na segunda abertura.** Isso não é bug — é o preço de abrir instantaneamente:
o service worker serve o que tem em mãos e atualiza depois. Mas significa que, se você corrigir um
bug grave, uma parte dos usuários vai encontrá-lo mais uma vez.

| Situação | Quando o usuário vê a v2 |
|---|---|
| Abriu, fechou, abriu de novo | 2ª abertura |
| Deixou a aba aberta o dia todo | Só ao recarregar |
| Primeiro acesso da vida | Imediatamente (não há cache) |
| **Com aviso de atualização** | **Na hora, se ele aceitar** ✅ |

A última linha é o que vamos implementar.

### Os três offlines

"O app funciona offline" é ambíguo. São três coisas independentes:

| Nível | O que guarda | Quem resolve | No Foco |
|---|---|---|---|
| **1. Aplicação** | HTML, JS, WASM, fontes, ícones | **Service worker** (esta aula) | ✅ Automático |
| **2. Dados locais** | Matérias, sessões, meta | **IndexedDB** ([Aula 4](04-banco-de-dados-na-web.md)) | ✅ Funciona |
| **3. Dados de API** | As trilhas do `TrilhaApi` | **Seu cache** ([Módulo 09](../09-consumo-de-api/README.md)) | ⚠️ Só o que já baixou |

```text
✈️ modo avião, app instalado:

o Foco abre                       ✅ nível 1 — service worker
lista matérias e sessões          ✅ nível 2 — IndexedDB
cria uma sessão nova              ✅ nível 2 — IndexedDB
mostra estatísticas               ✅ nível 2 — SQL local
abre a aba de trilhas             ⚠️ nível 3 — só o que está no cache_trilhas
```

> 💡 **O Foco já resolvia o nível 3 antes deste módulo.** A tabela `cache_trilhas` com TTL, do
> Módulo 09, é exatamente isso. A web não trouxe requisito novo — só tornou visível um problema que
> o app já tratava.

### `--pwa-strategy`

```powershell
flutter build web --release                          # offline-first (padrão)
flutter build web --release --pwa-strategy=none      # SEM service worker
```

| Estratégia | Gera SW? | Quando usar |
|---|---|---|
| `offline-first` | ✅ | ✅ **O padrão certo para o Foco** |
| `none` | ❌ | Quando o app **precisa** estar sempre atualizadíssimo, ou está embutido em outra página |

> ⚠️ **`none` não é "modo simples".** Sem service worker, não há offline, não há segunda visita
> instantânea e **o navegador não oferece instalação** — você deixa de ter um PWA e volta a ter um
> site. Use só com motivo.

---

## 💡 Analogia

Pense num **porteiro de prédio com um depósito de encomendas**.

- **Sem service worker**, cada vez que você quer um pacote, precisa ir até a transportadora. Se a
  rua está interditada, você não recebe nada.
- **Com service worker**, o porteiro fica na portaria com um depósito. Você pede o pacote; ele olha
  no depósito. Tem? Entrega na hora, e você nem sabe que a rua estava interditada. Não tem? Ele vai
  buscar.
- **Os hashes** são as etiquetas das caixas. O porteiro não precisa que você diga "chegou versão
  nova": ele compara a etiqueta do depósito com a da transportadora e vê que mudou.
- **E aqui está a parte que irrita:** quando você pede o pacote, o porteiro entrega **o que tem no
  depósito** — porque é rápido — e **só depois** vai buscar a versão nova e trocar. Você recebeu a
  caixa antiga. Da próxima vez que pedir, recebe a nova.
- **O aviso de atualização** é o porteiro tocar o interfone: *"chegou uma versão nova daquele
  pacote, quer que eu suba agora?"*. Custa uma linha de código e resolve a irritação inteira.
- **E o `sqflite_sw.js`** é outro funcionário, no subsolo, cuidando do arquivo morto. Mesmo uniforme,
  outro trabalho — não adianta reclamar de encomenda com ele.

---

## 🧪 Exemplo mínimo

Reproduza o problema da versão presa, de propósito. É o exercício mais útil deste módulo.

**1.** Compile e sirva:

```powershell
flutter build web --release
dart pub global activate dhttpd      # servidor local simples, uma vez só
dart pub global run dhttpd --path build/web --port 8080
```

**2.** Abra `http://localhost:8080`, veja o app, e confirme o service worker em
F12 → Application → **Service workers**:

```text
flutter_service_worker.js
Status: ✅ #1234 activated and is running
```

**3.** Mude um texto visível no Foco (o título da tela inicial, por exemplo).

**4.** Recompile e sirva de novo:

```powershell
flutter build web --release
```

**5.** Recarregue a página no navegador.

```text
⚠️ O texto ANTIGO continua lá.
```

**6.** Recarregue **de novo**.

```text
✅ Agora o texto novo apareceu.
```

Você acabou de reproduzir, em dois minutos, a reclamação mais comum de usuários de PWA. Não é cache
do navegador, não é CDN — é o service worker fazendo exatamente o que foi projetado para fazer.

> 💡 **Enquanto desenvolve, marque "Update on reload"** em Application → Service workers. Ele força
> a atualização a cada recarga e some com esse comportamento — **só na sua máquina**. É a caixa que
> evita horas de confusão durante o desenvolvimento, e que não muda nada para o usuário.

---

## 📱 Aplicando no Flutter

### Detectando a atualização

O sinal confiável é o evento **`controllerchange`** de `navigator.serviceWorker`. Ele dispara
exatamente quando o service worker novo assume o controle — ou seja, quando existe uma versão nova
ativa enquanto a página que você está vendo ainda roda a versão antiga.

```text
página carregada (v1)
        │
        │  SW novo instala, ativa, chama clients.claim()
        ▼
  controllerchange 🔔  ← "existe v2 pronta; esta página é v1"
        │
        ▼
  mostrar SnackBar "Nova versão disponível — Recarregar"
        │
        ▼
  location.reload()  → v2
```

### Testando offline de verdade

| Onde | Como | O que testa |
|---|---|---|
| DevTools → Network → **Offline** | Só a página | Nível 1 e 2 |
| DevTools → Application → SW → **Offline** | O service worker | Nível 1 |
| **Modo avião no celular, app instalado** | Tudo | ✅ **O teste que vale** |

> ⚠️ **Teste offline no aparelho, com o app instalado.** O DevTools simula bem, mas não reproduz o
> cenário real de abrir pelo ícone, sem aba de navegador, com o sistema tendo descartado o processo.
> É o equivalente ao "instale o APK e desconecte o cabo" do
> [Módulo 15, aula 9](../15-build-android/09-instalando-e-validando.md).

---

## 💻 Código completo

Um serviço que avisa o usuário quando há versão nova, e o widget que mostra o aviso.

> **Arquivo:** `lib/core/atualizacao/atualizacao_web.dart` (novo)
> **Como executar:** publique, abra, publique de novo e recarregue — o aviso aparece

```dart
/// Importação condicional, mesmo padrão das aulas 3 e 4:
/// no mobile não há service worker, então o stub devolve um Stream vazio.
export 'atualizacao_stub.dart'
    if (dart.library.js_interop) 'atualizacao_web_impl.dart';
```

> **Arquivo:** `lib/core/atualizacao/atualizacao_stub.dart` (novo)

```dart
/// 🤖🍎 Nativo: a atualização vem da loja, não do service worker.
/// Stream vazio — o widget de aviso simplesmente nunca dispara.
Stream<void> observarAtualizacao() => const Stream<void>.empty();

Future<void> recarregarApp() async {
  // Sem equivalente no mobile. Deliberadamente sem efeito.
}
```

> **Arquivo:** `lib/core/atualizacao/atualizacao_web_impl.dart` (novo)

```dart
import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// 🌐 Emite um evento quando o service worker NOVO assume o controle.
///
/// Por que `controllerchange` e não `updatefound`:
///   - `updatefound` dispara quando o SW novo COMEÇA a instalar. Avisar
///     aí é cedo demais: recarregar nesse instante ainda serve a versão
///     antiga, e o usuário recarrega duas vezes sem entender por quê.
///   - `controllerchange` dispara quando ele TERMINOU e assumiu. Só a
///     partir daí um reload entrega conteúdo novo.
///
/// O service worker do Flutter chama skipWaiting() no install e
/// clients.claim() no activate — é por isso que este evento chega
/// sozinho, sem precisarmos mandar mensagem nenhuma para ele.
Stream<void> observarAtualizacao() {
  final StreamController<void> controlador = StreamController<void>.broadcast();

  // Em navegador sem suporte a service worker, nada acontece — e o app
  // continua funcionando normalmente, só sem o aviso.
  final web.ServiceWorkerContainer? container = web.window.navigator.serviceWorker;
  if (container == null) return controlador.stream;

  // ⚠️ Na PRIMEIRA visita o controller ainda é null, e o primeiro
  // controllerchange é a instalação inicial — não uma atualização.
  // Sem esta guarda, todo usuário novo recebe "nova versão disponível"
  // segundos depois de abrir o app pela primeira vez.
  final bool jaTinhaControlador = container.controller != null;

  container.addEventListener(
    'controllerchange',
    ((web.Event _) {
      if (jaTinhaControlador) controlador.add(null);
    }).toJS,
  );

  return controlador.stream;
}

/// Recarrega a página. Como o SW novo já assumiu, isto entrega a versão nova.
Future<void> recarregarApp() async {
  web.window.location.reload();
}
```

> **Arquivo:** `lib/core/atualizacao/aviso_de_atualizacao.dart` (novo)

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'atualizacao_web.dart';

/// Envolve a árvore do app e mostra um SnackBar persistente quando
/// existe versão nova esperando.
///
/// Fica acima do Navigator para sobreviver a trocas de tela, e usa
/// ScaffoldMessenger para não competir com diálogos.
class AvisoDeAtualizacao extends StatefulWidget {
  const AvisoDeAtualizacao({required this.child, super.key});

  final Widget child;

  @override
  State<AvisoDeAtualizacao> createState() => _AvisoDeAtualizacaoState();
}

class _AvisoDeAtualizacaoState extends State<AvisoDeAtualizacao> {
  StreamSubscription<void>? _inscricao;

  @override
  void initState() {
    super.initState();
    _inscricao = observarAtualizacao().listen((_) => _mostrarAviso());
  }

  @override
  void dispose() {
    // Módulo 05, aula 6: toda inscrição criada no initState morre aqui.
    _inscricao?.cancel();
    super.dispose();
  }

  void _mostrarAviso() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nova versão disponível.'),
        // Sem duração automática: o usuário decide quando recarregar.
        // Recarregar sozinho descartaria um formulário pela metade.
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: 'Recarregar',
          onPressed: recarregarApp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

E o encaixe no `main()`:

> **Arquivo:** `lib/main.dart` (alterado)

```dart
runApp(
  ProviderScope(
    overrides: <Override>[
      bancoProvider.overrideWithValue(banco),
      preferenciasProvider.overrideWithValue(prefs),
    ],
    // ⬇️ Dentro do MaterialApp seria tarde: precisa de um
    // ScaffoldMessenger acima. AppFoco já o fornece.
    child: const AvisoDeAtualizacao(child: AppFoco()),
  ),
);
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `controllerchange` em vez de `updatefound` | `updatefound` avisa cedo demais: recarregar ali ainda serve a versão antiga. |
| A guarda `jaTinhaControlador` | Sem ela, **todo usuário novo** recebe "nova versão" logo após a primeira abertura — o SW inicial dispara o mesmo evento. |
| `container == null` tratado | Navegador sem service worker (ou contexto não seguro) não pode derrubar o app. |
| `StreamController.broadcast()` | Permite mais de um ouvinte sem exceção — útil se você também quiser logar. |
| Stub devolvendo `Stream.empty()` | No mobile o widget existe e nunca dispara; zero `kIsWeb` na UI. |
| `duration: Duration(days: 1)` | Aviso persistente. Um SnackBar de 4 s some antes de o usuário ler. |
| **Não** recarregar sozinho | Recarga automática descarta formulário pela metade. A decisão é do usuário. |
| `_inscricao?.cancel()` no `dispose` | [Módulo 05, aula 6](../05-introducao-ao-flutter/06-ciclo-de-vida-do-state.md): toda inscrição criada no `initState` morre no `dispose`. |
| `if (!mounted) return` | O evento é assíncrono e pode chegar depois de a tela sair. |
| `AvisoDeAtualizacao` **acima** do `MaterialApp` do `AppFoco` | Sobrevive a trocas de rota; dentro de uma tela, morreria na navegação. |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| Como a atualização chega | **Service worker, sozinho** | Play Store, se o usuário deixar | App Store, se o usuário deixar |
| Prazo até chegar | 2ª abertura | Dias a nunca | Dias a nunca |
| Rollback | Republicar (2 min) | Interromper rollout | Nova submissão |
| Offline da aplicação | Service worker | Nativo | Nativo |
| Usuário preso em versão velha | ⚠️ Por 1 abertura | ⚠️ **Para sempre**, se não atualizar | ⚠️ Idem |
| Forçar atualização | ✅ Fácil (aviso + reload) | ⚠️ *In-app updates* | ⚠️ Difícil |
| Versões simultâneas em campo | 2 | **Muitas** | Muitas |

> 📌 **Esta é a maior vantagem operacional do PWA, e ela é subestimada.** No Android, meses depois de
> uma correção, ainda há gente na versão com o bug — e o seu relatório de erros continua recebendo
> o stack trace antigo. Na web, 48 horas depois de publicar, praticamente todo mundo está na versão
> atual. Isso muda como você trata hotfix, telemetria e dívida de compatibilidade.

🪟 **No Windows**, esta aula funciona por completo.

---

## ⚠️ Erros comuns

### 1. Achar que o cache preso é bug do navegador

É o service worker funcionando como projetado.

**Correção:** entenda o ciclo; implemente o aviso.

### 2. Testar atualização sem "Update on reload"

Você recarrega, não vê a mudança e muda código à toa.

**Correção:** marque a caixa durante o desenvolvimento.

### 3. Deixar "Update on reload" marcado e concluir que está tudo bem

Só a sua máquina se comporta assim.

**Correção:** desmarque antes de validar o comportamento real.

### 4. Avisar no `updatefound`

Cedo demais; o reload ainda serve a versão antiga.

**Correção:** `controllerchange`.

### 5. Esquecer a guarda da primeira visita

Todo usuário novo recebe "nova versão disponível".

**Correção:** guardar `controller != null` **antes** de assinar.

### 6. Recarregar automaticamente

Descarta formulário em preenchimento.

**Correção:** aviso com ação; o usuário decide.

### 7. SnackBar com duração curta

Some antes de ser lido.

**Correção:** duração longa e ação explícita.

### 8. Usar `--pwa-strategy=none` para "resolver" cache

Perde offline, velocidade e **instalabilidade**.

**Correção:** resolva com o aviso.

### 9. Confundir os dois service workers

`sqflite_sw.js` é banco, `flutter_service_worker.js` é cache.

**Correção:** leia o nome e o *scope* no DevTools.

### 10. Prometer offline sem testar no aparelho

O DevTools simula; o celular decide.

**Correção:** modo avião, app instalado.

### 11. Esperar que a API funcione offline

O service worker do Flutter cacheia o **app**, não as suas chamadas.

**Correção:** cache de dados é seu — o `cache_trilhas` do Módulo 09.

### 12. Editar `flutter_service_worker.js` em `build/`

Sobrescrito no próximo build.

**Correção:** não edite; ajuste a estratégia ou o `index.html`.

---

## 🛠️ Exercício guiado

**Passo 1.** Compile e sirva o Foco localmente. Confirme o service worker ativo no DevTools.

**Passo 2.** Abra `build/web/flutter_service_worker.js`. Quantas entradas tem o `RESOURCES`?

**Passo 3.** Ache `main.dart.js` no `RESOURCES` e anote o hash.

**Passo 4.** Mude um texto do app, recompile e compare o hash. Mudou?

**Passo 5.** Reproduza o problema: recarregue uma vez (versão antiga), recarregue de novo (nova).

**Passo 6.** Marque "Update on reload" e repita. Quantas recargas agora?

**Passo 7.** Desmarque, implemente o `AvisoDeAtualizacao` e repita. O SnackBar apareceu?

**Passo 8.** Abra em janela anônima e confirme que o aviso **não** aparece na primeira visita.

**Passo 9.** Em Network, marque **Offline** e recarregue. O app abre? As matérias aparecem?

**Passo 10.** Ainda offline, abra a aba de trilhas. O que acontece, e qual dos três níveis de
offline explica isso?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Diagnóstico** (versão presa), **Aplicação** (aviso de atualização) e **Reflexão**
(os três offlines).

---

## 🏆 Desafio opcional

Construa uma **experiência offline completa e honesta** para o Foco.

Requisitos:

- O `AvisoDeAtualizacao` funcionando, com a guarda de primeira visita.
- Um indicador visual de **offline** no `AppBar`, ligado ao `connectivity_plus` — lembrando da
  [Aula 3](03-o-que-nao-funciona-na-web.md): `online` não garante que o servidor responde.
- A aba de trilhas, offline, mostrando os dados do `cache_trilhas` **com a data da última
  atualização**, em vez de um erro. Se não houver cache, um estado vazio explicativo.
- Uma tela de "Sobre" que mostre a **versão do app** lida do `version.json` e a **data do build**.
- Um teste de integração que rode em Chrome, desligue a rede e verifique que a lista de matérias
  ainda aparece.
- Documente, em `docs/offline.md`, qual dos três níveis cobre cada tela do Foco.

Depois responda: existe alguma tela do Foco que **parece** funcionar offline mas mostra dado
silenciosamente desatualizado? Essa é a pior categoria de problema offline — e a mais comum. O que
você mudaria na interface para tornar isso visível sem poluir a tela?

---

## 📌 Resumo

- Service worker é um script que roda **fora da página** e intercepta **toda requisição** antes da
  rede. É o que permite abrir offline — e o que torna o app instalável.
- O Flutter gera `flutter_service_worker.js` com `RESOURCES` (todo arquivo + **hash do conteúdo**) e
  `CORE` (o mínimo para abrir).
- **O hash é a versão.** Mudou um byte, mudou o hash, o service worker sabe.
- Ciclo: `install` (baixa o CORE, `skipWaiting`) → `activate` (compara manifests, `clients.claim`)
  → `fetch` (intercepta).
- **A versão nova aparece na 2ª abertura.** Não é bug: é o preço de abrir instantâneo.
- O sinal certo para avisar é **`controllerchange`**, não `updatefound` — e com **guarda de primeira
  visita**, senão todo usuário novo recebe o aviso.
- **Nunca recarregue sozinho:** descarta formulário. Avise e deixe o usuário decidir.
- São **três offlines** independentes: aplicação (service worker), dados locais (IndexedDB) e dados
  de API (seu cache). O Foco já resolvia o terceiro desde o Módulo 09.
- `--pwa-strategy=none` remove o service worker — e com ele o offline, a velocidade e a
  **instalabilidade**.
- "Update on reload" é ferramenta de **desenvolvimento**; desmarque antes de validar.
- Teste offline **no aparelho, com o app instalado** — o DevTools só simula.
- Operacionalmente, o PWA mantém **2 versões** em campo; as lojas mantêm **muitas**.

---

## ☑️ Checklist de domínio

- [ ] Explico o que é um service worker e por que ele permite offline.
- [ ] Sei distinguir `flutter_service_worker.js` de `sqflite_sw.js`.
- [ ] Leio o `RESOURCES` e explico o papel dos hashes.
- [ ] Descrevo `install`, `activate` e `fetch` e o que o Flutter faz em cada um.
- [ ] Explico por que a versão nova só aparece na segunda abertura.
- [ ] Reproduzo o problema de propósito, em dois minutos.
- [ ] Implemento o aviso com `controllerchange` e a guarda de primeira visita.
- [ ] Sei por que não se recarrega automaticamente.
- [ ] Separo os três níveis de offline e digo qual cobre cada tela.
- [ ] Sei o que `--pwa-strategy=none` custa.
- [ ] Uso "Update on reload" no desenvolvimento e desmarco para validar.
- [ ] Testei offline com o app instalado, em modo avião.

---

## 📚 Referências oficiais

- [Service Worker API — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [The service worker lifecycle — web.dev](https://web.dev/articles/service-worker-lifecycle)
- [Building a web application with Flutter — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/building)
- [Web app initialization — docs.flutter.dev](https://docs.flutter.dev/platform-integration/web/initialization)
- [Offline cookbook — web.dev](https://web.dev/articles/offline-cookbook)
- [ServiceWorkerContainer: controllerchange event — MDN](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/controllerchange_event)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Manifest e ícones](05-manifest-e-icones.md) | [README](README.md) | [Instalabilidade](07-instalabilidade.md) |
