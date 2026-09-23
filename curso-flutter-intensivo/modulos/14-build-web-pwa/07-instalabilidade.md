# Aula 7 — Instalabilidade

> **Módulo:** 14 - Build e Distribuição Web (PWA) · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Listar os **critérios de instalabilidade** que o navegador confere e verificar cada um no DevTools.
- Capturar o evento **`beforeinstallprompt`** para controlar **onde e quando** o convite de
  instalação aparece, em vez de aceitar o do navegador.
- Detectar se o app já está **rodando instalado** e não oferecer instalação a quem já instalou.
- Lidar com o **iOS Safari**, que não emite o evento e exige instrução manual ao usuário.
- Ajustar o app para o modo instalado: **áreas seguras**, *notch* e ausência do botão voltar do
  navegador.
- Ligar instalação a **armazenamento persistente** ([Aula 4](04-banco-de-dados-na-web.md)) e usar
  isso como argumento honesto na interface.

## ✅ Pré-requisitos

- [Aula 6 — Service worker e offline](06-service-worker-e-offline.md) — sem service worker com
  handler de `fetch`, não há instalação.
- [Aula 5 — Manifest e ícones](05-manifest-e-icones.md) — os campos conferidos aqui vêm de lá.
- [Módulo 06, aula 11 — Responsividade](../06-widgets-e-layouts/11-responsividade.md) — `SafeArea` e
  `MediaQuery` reaparecem no fim desta aula.

---

## 📖 Conceito

### Os critérios, um a um

O navegador confere isto sozinho. Falhou um, não há convite de instalação — e nenhuma mensagem de
erro é mostrada a você.

| # | Critério | Onde conferir |
|---|---|---|
| 1 | Servido por **HTTPS** (ou `localhost`) | Barra de endereços |
| 2 | `manifest.json` acessível e válido | Application → Manifest |
| 3 | `name` **ou** `short_name` | Idem |
| 4 | `start_url` que carrega | Idem |
| 5 | `display` em `standalone`, `fullscreen` ou `minimal-ui` | Idem |
| 6 | Ícone de **192×192** e de **512×512**, PNG | Idem |
| 7 | **Service worker registrado com handler de `fetch`** | Application → Service workers |
| 8 | Não estar já instalado | — |

> 📌 **O Flutter entrega 2, 4, 5, 6 e 7 de graça**, e o GitHub Pages entrega o 1. Na prática, o que
> sobra para você é preencher o manifest ([Aula 5](05-manifest-e-icones.md)) — e é por isso que este
> curso trata instalabilidade como consequência, não como projeto à parte.

O DevTools tem um painel que responde direto: **Application → Manifest**, seção *Installability*.

```text
Installability
  ✅ Page has a manifest <link> URL
  ✅ Manifest has a name or short_name
  ✅ Manifest has a display value of standalone
  ✅ Manifest contains suitable icons
  ✅ Page is served from a secure origin
  ✅ Page has a service worker with a fetch handler
```

Uma linha vermelha ali é o diagnóstico completo. Não existe motivo para adivinhar.

### `localhost` conta como seguro

```text
http://localhost:8080     ✅ instalável — origem segura por definição
http://192.168.0.10:8080  ❌ NÃO é segura
https://…github.io/foco/  ✅
```

Testar pelo IP da rede local — o jeito natural de abrir no celular — **não** oferece instalação, e
isso confunde muita gente. Para testar no celular antes de publicar, use o encaminhamento de porta
do Chrome (`chrome://inspect`) ou publique num ambiente de teste.

### `beforeinstallprompt`: assumindo o controle

Por padrão, o Chrome mostra um ícone discreto na barra de endereços. Funciona, e quase ninguém
percebe.

O evento `beforeinstallprompt` permite **interceptar** isso:

```text
navegador decide que dá para instalar
            │
            ▼
   dispara beforeinstallprompt
            │
   você chama preventDefault()  ← "eu cuido disso"
            │
   você GUARDA o evento
            │
   ... o usuário usa o app ...
            │
   no momento certo, você mostra o SEU botão
            │
   usuário clica → você chama evento.prompt()
            │
            ▼
   diálogo nativo de instalação
```

| Regra | Por quê |
|---|---|
| `prompt()` só dentro de um **gesto do usuário** | O navegador ignora fora disso |
| O evento serve **uma vez** | Depois de usado, guarde outro |
| Não existe no iOS Safari | [Seção do iOS](#-o-ios-é-diferente) |
| Não dispara se já instalado | Critério 8 |

> ⚠️ **Não mostre o convite na primeira tela.** Um usuário que ainda não sabe o que é o Foco não vai
> instalar o Foco — e, recusado o convite, o navegador fica meses sem oferecer de novo. Espere um
> sinal de interesse: a segunda visita, ou a primeira sessão de estudo registrada. É o mesmo
> princípio de não pedir permissão antes da hora do
> [Módulo 11, aula 1](../11-recursos-nativos/01-permissoes.md).

### Detectando que já está instalado

```dart
// Funciona em Android, Chrome/Edge desktop
final instalado = web.window.matchMedia('(display-mode: standalone)').matches;
```

```text
aberto em aba          → display-mode: browser
aberto pelo ícone      → display-mode: standalone  ✅
```

No iOS há uma propriedade própria, `navigator.standalone` — não padronizada, e a única disponível
lá.

### 🍎 O iOS é diferente

| | Android / Chrome / Edge | iOS / Safari |
|---|---|---|
| `beforeinstallprompt` | ✅ | ❌ **Não existe** |
| Convite automático | ✅ | ❌ |
| Como se instala | Botão ou menu | **Compartilhar → Adicionar à Tela de Início** |
| Detectar instalado | `display-mode: standalone` | `navigator.standalone` |
| Ícone | `icons` do manifest | `apple-touch-icon` ([Aula 5](05-manifest-e-icones.md)) |
| Armazenamento persistente | Pedido explícito | Heurística, expira sem uso |

No iPhone, **o usuário precisa saber que isso existe** — e a maioria não sabe. A única solução é
instruir na interface:

```text
┌─────────────────────────────────────┐
│  Instale o Foco no seu iPhone       │
│                                     │
│  1. Toque em  ⬆️  (Compartilhar)    │
│  2. Role e escolha                  │
│     "Adicionar à Tela de Início"    │
│  3. Toque em "Adicionar"            │
│                                     │
│              [Entendi]              │
└─────────────────────────────────────┘
```

> ⚠️ **Só mostre isso no Safari do iPhone.** Um usuário de Chrome no Android recebendo instruções de
> menu de compartilhamento do iOS vai concluir, corretamente, que o app não sabe o que está
> fazendo. A detecção precisa ser específica.

### O que muda quando está instalado

| Mudança | Consequência |
|---|---|
| **Não há botão voltar do navegador** | Toda tela precisa de saída dentro do app |
| A área do *notch* passa a ser sua | `SafeArea` deixa de ser opcional |
| Abre em janela própria | Comportamento de janela no desktop |
| Tem ícone no alternador de apps | `theme_color` aparece na aba do sistema |
| Melhor chance de `persist()` | [Aula 4](04-banco-de-dados-na-web.md) |

> ⚠️ **A primeira linha derruba app.** Em aba, o usuário sempre pode voltar pelo navegador. Instalado,
> **não pode** — uma tela sem botão de voltar vira um beco sem saída, e a única saída é fechar o app.
> Se o Foco tem alguma tela que dependia do voltar do navegador, ela precisa ganhar um
> `leading: BackButton()`.

---

## 💡 Analogia

Pense num **cartão de fidelidade de cafeteria**.

- **Os critérios de instalabilidade** são as exigências da franquia para a loja poder emitir cartão:
  fachada padronizada, alvará, máquina de cartão funcionando. Faltou um item, a loja simplesmente
  não recebe os cartões — e ninguém liga avisando qual item faltou. Você descobre olhando a lista
  (o painel do DevTools).
- **O `beforeinstallprompt` é o momento em que a franquia libera os cartões para você.** O padrão é
  deixá-los num porta-cartões discreto no balcão, que ninguém vê. Interceptar é pegar os cartões e
  decidir **você** quando oferecer.
- **E oferecer na hora certa é tudo.** Estender o cartão para quem acabou de entrar, antes de provar
  o café, é o jeito mais rápido de ouvir não — e a franquia só deixa você perguntar de novo dali a
  meses. Depois do segundo café, a mesma pergunta funciona.
- **O iOS é o cliente estrangeiro** que não conhece o costume do cartão. Não adianta esperar que
  peça: você precisa explicar, com desenho, onde fica o balcão.
- **E estar "instalado"** é o cliente ter o cartão na carteira: ele entra direto, você reconhece,
  e o café dele fica guardado — o armário fixo do `persist()` da Aula 4.

---

## 🧪 Exemplo mínimo

Confira os critérios em 30 segundos, sem escrever código.

**1.** Sirva o app e abra no Chrome.

**2.** F12 → **Application** → **Manifest** → role até *Installability*.

**3.** Tudo verde? O ícone de instalar aparece na barra de endereços:

```text
┌──────────────────────────────────────────────┐
│ 🔒 localhost:8080/          [⊕]  ⋮           │
└──────────────────────────────────────────────┘
                              ▲
                      ícone de instalar
```

**4.** Agora quebre de propósito. Compile sem service worker:

```powershell
flutter build web --release --pwa-strategy=none
```

**5.** Recarregue e olhe o painel de novo:

```text
Installability
  ✅ Page has a manifest <link> URL
  ✅ Manifest has a name or short_name
  ✅ Manifest has a display value of standalone
  ✅ Manifest contains suitable icons
  ✅ Page is served from a secure origin
  ❌ Page does not work offline. The page will not be regarded as
     installable after Chrome 93.
```

O ícone some da barra. **Um critério derruba a instalabilidade inteira** — e é exatamente por isso
que a [Aula 6](06-service-worker-e-offline.md) desaconselha `--pwa-strategy=none`.

> 💡 **Guarde este teste.** Quando alguém disser "o botão de instalar sumiu", esse painel responde em
> um olhar. É o `flutter doctor` da web.

---

## 📱 Aplicando no Flutter

### Onde colocar o convite no Foco

| Momento | Bom? | Por quê |
|---|---|---|
| Primeira abertura | ❌ | O usuário ainda não sabe o que é |
| Depois da 1ª sessão registrada | ✅ | Demonstrou interesse |
| Na segunda visita | ✅ | Voltou por vontade própria |
| Tela de configurações, sempre disponível | ✅ | Não invade, e quem quer acha |
| Toda vez que abre | ❌ | Vira ruído; o usuário ignora |

> 💡 **A melhor combinação para o Foco:** um card discreto na tela inicial **a partir da segunda
> visita**, dispensável, mais uma entrada permanente em Configurações. Quem quer instala; quem não
> quer não é perturbado duas vezes.

---

## 💻 Código completo

> **Arquivo:** `lib/core/instalacao/instalacao.dart` (novo)
> **Como executar:** publique, abra no Chrome e no Safari do iPhone — dois caminhos, uma interface

```dart
/// Mesma estratégia das aulas 3, 4 e 6.
export 'instalacao_stub.dart'
    if (dart.library.js_interop) 'instalacao_web.dart';
```

> **Arquivo:** `lib/core/instalacao/instalacao_stub.dart` (novo)

```dart
/// 🤖🍎 Nativo: o app JÁ está instalado — veio da loja.
/// Tudo devolve o valor que faz o convite nunca aparecer.
class EstadoInstalacao {
  const EstadoInstalacao({
    this.podeInstalar = false,
    this.jaInstalado = true,
    this.precisaInstrucaoIos = false,
  });

  final bool podeInstalar;
  final bool jaInstalado;
  final bool precisaInstrucaoIos;
}

Stream<EstadoInstalacao> observarInstalacao() =>
    Stream<EstadoInstalacao>.value(const EstadoInstalacao());

Future<bool> pedirInstalacao() async => false;
```

> **Arquivo:** `lib/core/instalacao/instalacao_web.dart` (novo)

```dart
import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// `beforeinstallprompt` não é padronizado, então `package:web` não o
/// tipa. Um extension type dá tipagem sem custo em runtime.
extension type _EventoInstalacao._(JSObject _) implements JSObject {
  external JSPromise<JSObject> prompt();
}

class EstadoInstalacao {
  const EstadoInstalacao({
    required this.podeInstalar,
    required this.jaInstalado,
    required this.precisaInstrucaoIos,
  });

  /// Temos um beforeinstallprompt guardado: dá para abrir o diálogo nativo.
  final bool podeInstalar;

  /// Rodando em modo standalone — não faz sentido oferecer instalação.
  final bool jaInstalado;

  /// Safari no iPhone/iPad: não há evento; só resta instruir o usuário.
  final bool precisaInstrucaoIos;
}

_EventoInstalacao? _eventoGuardado;

/// `display-mode: standalone` cobre Android e desktop.
/// `navigator.standalone` é a propriedade não padronizada do iOS — a
/// única forma de detectar lá.
bool _estaInstalado() {
  if (web.window.matchMedia('(display-mode: standalone)').matches) return true;
  final JSAny? iosStandalone =
      (web.window.navigator as JSObject).getProperty('standalone'.toJS);
  return iosStandalone.isDefinedAndNotNull && (iosStandalone as JSBoolean).toDart;
}

/// ⚠️ Detectar navegador por user agent é frágil — mas aqui não há
/// alternativa: a ausência de `beforeinstallprompt` é indistinguível
/// de "o navegador ainda não decidiu". Restringimos ao máximo: só
/// Safari, só em iPhone/iPad, e o resultado apenas MOSTRA uma
/// instrução — nunca bloqueia funcionalidade.
bool _ehSafariNoIos() {
  final String ua = web.window.navigator.userAgent;
  final bool ehIos = ua.contains('iPhone') || ua.contains('iPad');
  final bool ehSafari = ua.contains('Safari') && !ua.contains('CriOS') && !ua.contains('FxiOS');
  return ehIos && ehSafari;
}

Stream<EstadoInstalacao> observarInstalacao() {
  final StreamController<EstadoInstalacao> controlador =
      StreamController<EstadoInstalacao>.broadcast();

  EstadoInstalacao estadoAtual() => EstadoInstalacao(
        podeInstalar: _eventoGuardado != null,
        jaInstalado: _estaInstalado(),
        precisaInstrucaoIos: !_estaInstalado() && _ehSafariNoIos(),
      );

  web.window.addEventListener(
    'beforeinstallprompt',
    ((web.Event evento) {
      // ⭐ preventDefault é o que tira o convite das mãos do navegador.
      // Sem ele, o Chrome mostra o dele E guardamos o evento — e o
      // usuário vê dois convites.
      evento.preventDefault();
      _eventoGuardado = evento as _EventoInstalacao;
      controlador.add(estadoAtual());
    }).toJS,
  );

  // Dispara quando a instalação conclui, inclusive pela barra de
  // endereços. Sem isto, o nosso card continuaria na tela depois
  // de o app já ter sido instalado.
  web.window.addEventListener(
    'appinstalled',
    ((web.Event _) {
      _eventoGuardado = null;
      controlador.add(const EstadoInstalacao(
        podeInstalar: false,
        jaInstalado: true,
        precisaInstrucaoIos: false,
      ));
    }).toJS,
  );

  // Estado inicial: no iOS e em quem já instalou, o evento nunca vem.
  scheduleMicrotask(() => controlador.add(estadoAtual()));

  return controlador.stream;
}

/// Abre o diálogo nativo. ⚠️ Só funciona dentro de um gesto do
/// usuário — chamar no initState é ignorado silenciosamente.
Future<bool> pedirInstalacao() async {
  final _EventoInstalacao? evento = _eventoGuardado;
  if (evento == null) return false;

  await evento.prompt().toDart;

  // O evento serve uma vez só. Se o usuário recusar, o navegador
  // decide sozinho quando disparar outro — pode demorar meses.
  _eventoGuardado = null;
  return true;
}
```

> **Arquivo:** `lib/core/instalacao/card_instalar.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'instalacao.dart';

/// Card dispensável, para a tela inicial. Some sozinho quando não há
/// nada a oferecer — então pode ficar fixo na árvore sem condicional.
class CardInstalar extends StatefulWidget {
  const CardInstalar({super.key});

  @override
  State<CardInstalar> createState() => _CardInstalarState();
}

class _CardInstalarState extends State<CardInstalar> {
  bool _dispensado = false;

  @override
  Widget build(BuildContext context) {
    if (_dispensado) return const SizedBox.shrink();

    return StreamBuilder<EstadoInstalacao>(
      stream: observarInstalacao(),
      builder: (BuildContext context, AsyncSnapshot<EstadoInstalacao> snapshot) {
        final EstadoInstalacao? estado = snapshot.data;
        if (estado == null || estado.jaInstalado) return const SizedBox.shrink();

        if (estado.precisaInstrucaoIos) return _CardIos(aoDispensar: _dispensar);
        if (estado.podeInstalar) return _CardPadrao(aoDispensar: _dispensar);
        return const SizedBox.shrink();
      },
    );
  }

  void _dispensar() => setState(() => _dispensado = true);
}

class _CardPadrao extends StatelessWidget {
  const _CardPadrao({required this.aoDispensar});

  final VoidCallback aoDispensar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.install_mobile),
        title: const Text('Instalar o Foco'),
        // O argumento é honesto e concreto: instalado, o navegador
        // protege os dados do app (Aula 4).
        subtitle: const Text('Abre mais rápido, funciona offline e '
            'protege seus dados de limpezas do navegador.'),
        trailing: Wrap(
          children: <Widget>[
            TextButton(onPressed: aoDispensar, child: const Text('Agora não')),
            FilledButton(
              onPressed: pedirInstalacao,
              child: const Text('Instalar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardIos extends StatelessWidget {
  const _CardIos({required this.aoDispensar});

  final VoidCallback aoDispensar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.ios_share),
        title: const Text('Instalar o Foco no iPhone'),
        subtitle: const Text(
          'Toque em Compartilhar e escolha "Adicionar à Tela de Início".',
        ),
        trailing: TextButton(onPressed: aoDispensar, child: const Text('Entendi')),
      ),
    );
  }
}
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `extension type _EventoInstalacao` | `beforeinstallprompt` não é padrão, então `package:web` não o tipa. Extension type dá tipagem com **zero custo** em runtime. |
| `evento.preventDefault()` | Tira o convite do navegador. **Sem isso o usuário vê dois convites.** |
| Guardar o evento em variável de topo | `prompt()` precisa ser chamado depois, no clique — o evento não pode ser recriado. |
| `appinstalled` | Sem ele, o card continua na tela depois de o usuário instalar pela barra de endereços. |
| `scheduleMicrotask` para o estado inicial | No iOS e em quem já instalou, `beforeinstallprompt` **nunca** dispara; sem um estado inicial o `StreamBuilder` ficaria vazio para sempre. |
| Detecção de iOS por user agent, com escopo mínimo | Frágil por natureza; aqui só **mostra instrução**, nunca bloqueia nada. O comentário registra o porquê. |
| `_eventoGuardado = null` após `prompt()` | O evento serve uma vez. Reutilizar lança. |
| Card **dispensável** | Recusa registrada em memória; insistir na mesma sessão é o caminho mais rápido para ser ignorado. |
| Subtítulo citando proteção de dados | É o argumento verdadeiro (Aula 4), não marketing. |
| `SizedBox.shrink()` nos casos vazios | O card pode ficar fixo na árvore; ele se resolve sozinho. |
| Stub com `jaInstalado: true` | No mobile o app veio da loja. Zero `kIsWeb` na UI. |

---

## 🌐🤖🍎 Web × Android × iOS

| | 🌐 Web (Chrome/Edge) | 🌐 Web (Safari iOS) | 🤖 Android nativo | 🍎 iOS nativo |
|---|---|---|---|---|
| Como instala | Botão no app ou barra | **Menu compartilhar** | Play Store | App Store |
| API para convidar | `beforeinstallprompt` | ❌ Nenhuma | — | — |
| Detectar instalado | `display-mode` | `navigator.standalone` | — | — |
| Desinstalar | Como app normal | Arrastar o ícone | Loja | Tela inicial |
| Tamanho baixado | ~0 (já em cache) | ~0 | ~17 MB | ~20 MB |
| Aparece no alternador | ✅ | ✅ | ✅ | ✅ |
| Armazenamento protegido | ✅ Melhor com `persist()` | ⚠️ Heurística | ✅ | ✅ |

> 💡 **Instalar um PWA baixa praticamente nada** — o app já está no cache do service worker desde a
> primeira visita. É a diferença mais concreta em relação à loja: instalação instantânea, sem barra
> de progresso e sem depender de rede boa naquele instante.

🪟 **No Windows**, esta aula funciona por completo — inclusive instalar o Foco como app de desktop
pelo Chrome ou Edge, com ícone no menu Iniciar.

---

## ⚠️ Erros comuns

### 1. Convidar na primeira tela

Recusa quase certa, e o navegador silencia por meses.

**Correção:** segunda visita, ou depois da primeira sessão.

### 2. Esquecer `preventDefault()`

Dois convites.

**Correção:** primeira linha do listener.

### 3. Chamar `prompt()` fora de um gesto

Ignorado sem erro.

**Correção:** só no `onPressed`.

### 4. Reutilizar o evento

Lança.

**Correção:** descarte depois de usar.

### 5. Não tratar `appinstalled`

Card oferecendo instalar um app já instalado.

**Correção:** escute o evento.

### 6. Testar pelo IP da rede local

`http://192.168…` não é origem segura.

**Correção:** `localhost`, encaminhamento de porta, ou publicado.

### 7. Mostrar instrução de iOS no Android

Passa a impressão de app quebrado.

**Correção:** detecção específica.

### 8. Não oferecer nada no iOS

A maioria dos usuários não sabe que dá para instalar.

**Correção:** o card com as três etapas.

### 9. Esquecer `SafeArea` no modo instalado

Conteúdo sob o *notch*.

**Correção:** `SafeArea` + `viewport-fit=cover`.

### 10. Tela sem botão de voltar

Instalado, não há voltar do navegador: beco sem saída.

**Correção:** `leading: BackButton()` onde faltar.

### 11. Insistir depois de "Agora não"

Vira ruído.

**Correção:** respeite a recusa na sessão.

### 12. Achar que instalar baixa o app de novo

Já está no cache.

**Correção:** é instantâneo — e vale dizer isso ao usuário.

---

## 🛠️ Exercício guiado

**Passo 1.** Sirva o Foco em `localhost` e abra o painel *Installability*. Tudo verde?

**Passo 2.** Compile com `--pwa-strategy=none`, recarregue e veja qual linha ficou vermelha.

**Passo 3.** Volte ao build normal. O ícone de instalar reapareceu na barra?

**Passo 4.** Instale o Foco no Windows pelo Chrome. Ele aparece no menu Iniciar?

**Passo 5.** Com o app instalado aberto, rode no console:
`matchMedia('(display-mode: standalone)').matches`. Qual o valor? E na aba do navegador?

**Passo 6.** Implemente `observarInstalacao()` e o `CardInstalar`. O card aparece?

**Passo 7.** Clique em Instalar. O diálogo nativo abriu?

**Passo 8.** Depois de instalado, recarregue a versão em aba. O card sumiu?

**Passo 9.** Abra o app pelo IP da máquina no celular (`http://192.168…`). O convite aparece?
Por quê?

**Passo 10.** Se tiver um iPhone à mão, abra no Safari e siga as três etapas do card. O ícone ficou
com a arte do Foco ou com um print da página? (Se ficou print, falta a
[Aula 5](05-manifest-e-icones.md).)

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md)

Faça os de **Fixação** (os critérios), **Diagnóstico** (o convite que não aparece) e **Aplicação**
(o card de instalação).

---

## 🏆 Desafio opcional

Implemente a **estratégia completa de instalação** do Foco, com medição.

Requisitos:

- Card na tela inicial, só a partir da **segunda visita** — persista a contagem em
  `shared_preferences`, que funciona na web ([Aula 3](03-o-que-nao-funciona-na-web.md)).
- Entrada permanente em Configurações, com o estado atual ("instalado", "disponível para instalar",
  "instale pelo menu compartilhar").
- Instrução específica de iOS com as três etapas e o ícone correto de compartilhar.
- Ao instalar, chame `pedirArmazenamentoPersistente()` da [Aula 4](04-banco-de-dados-na-web.md) e
  mostre o resultado em Configurações.
- Registre localmente quatro eventos: convite exibido, dispensado, aceito, instalação concluída.
- Uma tela de diagnóstico (só em debug) listando os critérios e o estado de cada um.
- Confira `SafeArea` em todas as telas com o app instalado, num aparelho com *notch*.

Depois responda: entre "card na segunda visita" e "entrada em Configurações", qual dos dois gerou
instalação de verdade nos seus testes? E, se o card tivesse aparecido logo na primeira abertura,
o que teria acontecido com a taxa de recusa — e quanto tempo o navegador ficaria sem oferecer de
novo?

---

## 📌 Resumo

- São **8 critérios** de instalabilidade; o Flutter entrega quase todos, e o painel
  **Application → Manifest → Installability** diz qual falhou.
- `localhost` é origem segura; **`http://192.168…` não é** — testar pelo IP da rede não oferece
  instalação.
- **`beforeinstallprompt`** permite controlar onde e quando convidar. `preventDefault()` é
  obrigatório, senão aparecem dois convites.
- `prompt()` só funciona **dentro de um gesto do usuário**, e o evento **serve uma vez**.
- Trate **`appinstalled`**, ou o card continua oferecendo instalar o que já foi instalado.
- Detecte instalado com **`display-mode: standalone`**; no iOS, `navigator.standalone`.
- **O iOS não tem o evento.** A instalação é manual pelo menu Compartilhar, e o usuário precisa ser
  instruído — só no Safari do iPhone.
- **Não convide na primeira tela.** Recusado, o navegador silencia por meses. Segunda visita, ou
  após a primeira sessão registrada.
- Instalado, **não existe voltar do navegador** — toda tela precisa de saída própria — e a área do
  *notch* passa a ser sua (`SafeArea`).
- Instalar **melhora a chance de armazenamento persistente**: é o argumento honesto para o convite.
- Instalar um PWA **não baixa nada**: já está no cache.

---

## ☑️ Checklist de domínio

- [ ] Listo os 8 critérios e confiro cada um no DevTools.
- [ ] Sei por que `localhost` funciona e o IP da rede não.
- [ ] Capturo `beforeinstallprompt` com `preventDefault()` e guardo o evento.
- [ ] Chamo `prompt()` só dentro de um gesto, uma vez.
- [ ] Trato `appinstalled` e escondo o convite.
- [ ] Detecto o modo instalado nos dois mundos.
- [ ] Mostro instrução de iOS **só** no Safari do iPhone.
- [ ] Escolho o momento do convite por sinal de interesse, não por abertura.
- [ ] Respeito a recusa do usuário na sessão.
- [ ] Revisei as telas quanto à ausência do voltar do navegador.
- [ ] Apliquei `SafeArea` onde o *notch* alcança.
- [ ] Ligo instalação a `persist()` e explico isso ao usuário.

---

## 📚 Referências oficiais

- [What does it take to be installable? — web.dev](https://web.dev/articles/install-criteria)
- [Patterns for promoting PWA installation — web.dev](https://web.dev/articles/promote-install)
- [BeforeInstallPromptEvent — MDN](https://developer.mozilla.org/en-US/docs/Web/API/BeforeInstallPromptEvent)
- [Window: appinstalled event — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Window/appinstalled_event)
- [display-mode — MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/display-mode)
- [Extension types — dart.dev](https://dart.dev/language/extension-types)
- [SafeArea class — api.flutter.dev](https://api.flutter.dev/flutter/widgets/SafeArea-class.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Service worker e offline](06-service-worker-e-offline.md) | [README](README.md) | [Gerando o build web](08-gerando-o-build-web.md) |
