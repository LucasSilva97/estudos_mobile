# Aula 5 — Monitoramento e feedback

> **Módulo:** 16 - Publicação e próximos passos · **Tempo estimado:** 35 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Instalar um **crash reporting** e entender o que ele responde que o log não responde.
- Enviar os **símbolos** de `--split-debug-info` e os **dSYM**, para os crashes chegarem legíveis.
- Ler as métricas que importam nas duas lojas: **taxa de falhas**, ANR, retenção, desinstalação.
- Coletar **feedback dentro do app**, e responder avaliações nas lojas.
- Aplicar a **LGPD** ao que você coleta: consentimento, minimização e o que **não** coletar.
- Montar uma **rotina semanal** de acompanhamento que caiba em quinze minutos.

## ✅ Pré-requisitos

- [Aula 4 — CI/CD introdutório](04-ci-cd-introdutorio.md) — os símbolos já arquivados
  automaticamente.
- [Módulo 13, aula 7 — Ofuscação](../13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) —
  por que o stack trace chega ilegível.
- [Módulo 13, aula 6 — Segurança mobile](../13-desempenho-e-seguranca/06-seguranca-mobile.md) — o
  que nunca registrar em log.
- App publicado, ao menos numa faixa de teste.

---

## 📖 Conceito

### Por que monitorar

Publicado o app, você perde a visibilidade que tinha:

| Em desenvolvimento | Em produção |
|---|---|
| Você vê o console | ❌ |
| Você reproduz o bug | ❌ Não sabe nem que existe |
| Um aparelho, o seu | Centenas de modelos |
| Uma versão do Android | Da 6 à 15 |
| Rede boa | 3G no ônibus |

> 📌 **A maioria dos usuários não relata o problema — desinstala.** Uma avaliação de uma estrela
> dizendo "trava" representa dezenas de pessoas que só foram embora. O monitoramento é o que
> transforma "o app deve estar bom, ninguém reclamou" em um número.

### Crash reporting

| Ferramenta | Custo | Observação |
|---|---|---|
| **Firebase Crashlytics** | Grátis | ✅ O padrão de fato |
| Sentry | Grátis até um limite | Ótimo para erros não fatais |
| Play Console / App Store Connect | Grátis, embutido | ⚠️ Menos detalhe, sem tempo real |

```yaml
dependencies:
  firebase_core: ^4.1.1
  firebase_crashlytics: ^5.0.2
```

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Erros do Flutter (build, layout, gestos).
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Erros fora do Flutter (async, isolates).
  // ⚠️ Sem esta linha, metade dos crashes não é capturada.
  PlatformDispatcher.instance.onError = (Object erro, StackTrace pilha) {
    FirebaseCrashlytics.instance.recordError(erro, pilha, fatal: true);
    return true;
  };

  runApp(const ProviderScope(child: FocoApp()));
}
```

> ⚠️ **São dois manipuladores, não um.** `FlutterError.onError` pega o que acontece dentro do
> framework; `PlatformDispatcher.instance.onError` pega o resto — `Future` sem `catch`, erro em
> isolate, callback de plugin. Configurar só o primeiro deixa passar exatamente os erros mais
> difíceis de reproduzir.

### Os símbolos

Aqui o módulo 13 volta:

```text
Sem os símbolos enviados:
  #0  a.b (package:foco/a.dart:1:1)     ← inútil

Com os símbolos:
  #0  CofreToken.salvar (package:foco/core/seguranca/cofre_token.dart:47:5)
```

| Plataforma | O que enviar |
|---|---|
| 🤖 Android | símbolos do Dart + `mapping.txt` (R8) |
| 🍎 iOS | símbolos do Dart + **dSYM** |

```bash
# Crashlytics, Android
firebase crashlytics:symbols:upload --app=<APP_ID> simbolos/1.4.2+37

# Crashlytics, iOS
./ios/Pods/FirebaseCrashlytics/upload-symbols \
  -gsp ios/Runner/GoogleService-Info.plist -p ios \
  build/ios/archive/Runner.xcarchive/dSYMs
```

> 📌 **Esse envio é o passo que fecha o ciclo do módulo 13.** Você ofuscou, arquivou os símbolos no
> CI (aula 4) — e é aqui que eles viram stack trace legível. Sem este passo, todo o cuidado anterior
> não produz nenhum benefício visível.

### As métricas que importam

**Na Play Console** (Qualidade do app → Android vitals):

| Métrica | Limite ruim | O que significa |
|---|---|---|
| **Taxa de falhas** | > 1,09 % | Sessões que terminaram em crash |
| **Taxa de ANR** | > 0,47 % | App travado por 5 s (módulo 13, aula 3) |
| Desinstalações | — | Compare com instalações |
| Avaliação | < 4,0 | Afeta o posicionamento na busca |

> ⚠️ **Os limites da Play Console não são conselho — são consequência.** Passar deles coloca o app
> no "limite ruim de comportamento", e o Google reduz a visibilidade dele na loja. É uma das poucas
> métricas que afeta diretamente quantas pessoas encontram o seu app.

**No App Store Connect** (Analytics):

| Métrica | Onde |
|---|---|
| Crashes | Analytics → Metrics |
| Sessões, retenção | Analytics |
| Impressões → downloads | App Store → Conversão |
| Avaliações | Ratings and Reviews |

### Retenção

```text
Dia 1:  100 pessoas instalaram
Dia 2:   40 voltaram   → retenção D1 = 40 %
Dia 7:   20 voltaram   → retenção D7 = 20 %
Dia 30:  10 voltaram   → retenção D30 = 10 %
```

| Retenção D1 | Veredito |
|---|---|
| > 40 % | ✅ Muito bom |
| 25–40 % | ✅ Normal |
| < 20 % | ⚠️ Algo trava ou confunde no primeiro uso |

> 💡 **Retenção D1 baixa quase nunca é problema de recurso.** É onboarding confuso, permissão pedida
> na abertura (módulo 14, aula 5), tela inicial vazia sem explicação, ou um crash no primeiro uso.
> Antes de construir o recurso que "vai segurar o usuário", conserte o primeiro minuto.

### Feedback dentro do app

Esperar a avaliação da loja é esperar o extremo: quem avalia está muito satisfeito ou muito
irritado. Um canal dentro do app captura o meio.

```dart
// Pedir avaliação — no momento certo, nunca na abertura.
final InAppReview review = InAppReview.instance;
if (await review.isAvailable()) {
  await review.requestReview();
}
```

> ⚠️ **As duas lojas limitam quantas vezes o pedido de avaliação aparece** (a Apple, três vezes por
> ano por usuário). Gastar isso na primeira abertura é jogar fora o pedido — e irritar alguém que
> ainda não formou opinião.

| Quando pedir | Veredito |
|---|---|
| Na primeira abertura | ❌ |
| Depois de um crash | ❌ |
| Após concluir uma meta de estudo | ✅ |
| Na 5ª sessão registrada | ✅ |

### Responder avaliações

| | 🤖 Play Console | 🍎 App Store Connect |
|---|---|---|
| Responder | ✅ | ✅ |
| Usuário é notificado | ✅ | ✅ |
| Pode mudar a nota depois | ✅ | ✅ |

> 💡 **Responder funciona.** Uma resposta educada a uma avaliação de uma estrela — reconhecendo o
> problema e dizendo em qual versão foi corrigido — frequentemente faz a pessoa voltar e mudar a
> nota. E as respostas ficam públicas: quem lê as avaliações antes de instalar vê que alguém
> responde.

### LGPD

A Lei Geral de Proteção de Dados vale para o seu app.

| Princípio | Na prática |
|---|---|
| **Minimização** | Colete o mínimo necessário |
| Finalidade | Só para o que você declarou |
| Consentimento | Peça antes de coletar |
| Transparência | Política de privacidade acessível |
| Acesso e exclusão | O usuário pode pedir os dados e a exclusão |

**Nunca colete:**

| ❌ | Por quê |
|---|---|
| Conteúdo digitado pelo usuário em log | Pode conter qualquer coisa |
| Token, senha, dado de cartão | Módulo 13, aula 6 |
| Localização sem finalidade declarada | Sensível |
| Identificador de publicidade sem consentimento | Exige diálogo |
| Dados de menores sem consentimento dos pais | Regras específicas |

```dart
// ❌ O erro pode conter dados do usuário.
FirebaseCrashlytics.instance.log('Salvando: $anotacaoDoUsuario');

// ✅ Contexto sem conteúdo.
FirebaseCrashlytics.instance.log('Salvando anotação (${texto.length} chars)');
FirebaseCrashlytics.instance.setCustomKey('tela', 'detalhe_materia');
```

> 📌 **O crash reporting é um canal de vazamento involuntário.** As chaves customizadas e os logs
> vão para um servidor de terceiro, e ficam lá. Registre **o que aconteceu**, nunca **o que o
> usuário escreveu**.

---

## 💡 Analogia

Pense num **restaurante depois da inauguração**.

- **Em desenvolvimento**, você cozinhava e comia. Sabia exatamente o gosto de cada prato.
- **Publicado**, os pratos saem para o salão e você fica na cozinha. Não vê ninguém comer.
- **E o cliente insatisfeito quase nunca chama o garçom.** Ele come metade, paga e não volta. Você
  conclui, do fundo da cozinha, que estava tudo ótimo — porque ninguém reclamou.
- **O crash reporting** é a câmera no salão: você vê a mesa 12 empurrar o prato. Sem os símbolos, a
  imagem sai desfocada — dá para ver que **alguém** empurrou **alguma coisa**, e nada além.
- **A taxa de falhas com limite** é a vigilância sanitária: passou do número, não é conselho — é
  o alvará em risco. O Google literalmente esconde o seu restaurante do mapa.
- **A retenção D1** é quantos voltam no dia seguinte. Baixa demais raramente é o cardápio: é a fila
  na porta, o garçom que some, a mesa suja. **Conserte a entrada antes de criar o prato novo.**
- **Pedir avaliação na primeira mordida** é o garçom perguntando "está bom?" antes de a pessoa
  engolir. E você só pode perguntar três vezes por ano.
- **Responder às avaliações** é sair da cozinha e ir à mesa. Muda a nota — e as outras mesas veem.
- **E a LGPD** é a regra sobre a câmera: ela pode mostrar que a mesa 12 empurrou o prato; **não pode
  gravar a conversa deles**.

---

## 🧪 Exemplo mínimo

Crash reporting em dez linhas.

> **Arquivo:** `lib/main.dart`

```dart
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 1. Erros DENTRO do Flutter: build, layout, gestos.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 2. Erros FORA do Flutter: Future sem catch, isolate,
  //    callback de plugin.
  // ⚠️ Sem esta segunda linha, metade dos crashes não é
  //    capturada — justamente os mais difíceis de reproduzir.
  PlatformDispatcher.instance.onError = (Object erro, StackTrace pilha) {
    FirebaseCrashlytics.instance.recordError(erro, pilha, fatal: true);
    return true;
  };

  // 3. Em debug, não polua o painel com os seus próprios testes.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  runApp(const FocoApp());
}
```

**Testar:**

```dart
// Um botão, só em debug, que força um crash.
if (kDebugMode)
  TextButton(
    onPressed: () => FirebaseCrashlytics.instance.crash(),
    child: const Text('Forçar crash (teste)'),
  ),
```

```text
1. Aperte o botão — o app fecha
2. Reabra o app (o relatório é enviado na PRÓXIMA abertura)
3. Firebase Console → Crashlytics → o crash aparece em ~5 min
```

> 📌 **O relatório é enviado na próxima abertura, não no momento do crash** — o app está morrendo, e
> não há como fazer rede. Por isso um crash que impede o app de abrir novamente pode nunca ser
> relatado: é o ponto cego de todo crash reporting, e a razão de o teste interno (módulo 15, aula 9)
> continuar importando.

---

## 📱 Aplicando no Flutter

Um serviço de telemetria com a LGPD embutida, e a rotina semanal.

---

## 💻 Código completo

> **Arquivo:** `lib/core/monitoramento/telemetria.dart` (novo)

```dart
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Camada única de monitoramento.
///
/// Todo o app registra por aqui. A vantagem não é técnica: é que
/// existe UM lugar onde se garante que nenhum dado do usuário
/// escapa para um servidor de terceiro.
class Telemetria {
  Telemetria._();
  static final Telemetria instancia = Telemetria._();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  bool _consentimento = false;

  /// Liga a coleta, depois do consentimento do usuário.
  ///
  /// ⚠️ LGPD: coletar antes de perguntar é irregular. O padrão
  /// deste app é NÃO coletar até o usuário permitir.
  Future<void> definirConsentimento(bool permitido) async {
    _consentimento = permitido;
    await _crashlytics.setCrashlyticsCollectionEnabled(
      permitido && !kDebugMode,
    );
  }

  /// Configura os manipuladores globais.
  static Future<void> configurar() async {
    // 1. Erros do framework.
    FlutterError.onError = (FlutterErrorDetails detalhes) {
      FlutterError.presentError(detalhes);   // mantém o log local
      FirebaseCrashlytics.instance.recordFlutterFatalError(detalhes);
    };

    // 2. Erros fora do framework. Sem isto, metade escapa.
    PlatformDispatcher.instance.onError = (Object erro, StackTrace pilha) {
      FirebaseCrashlytics.instance.recordError(erro, pilha, fatal: true);
      return true;
    };
  }

  /// Registra um erro NÃO fatal — aquele que o app tratou.
  ///
  /// São os mais valiosos: indicam algo dando errado sem o
  /// usuário perceber, e nunca apareceriam como crash.
  Future<void> erro(
    Object erro,
    StackTrace pilha, {
    String? contexto,
  }) async {
    if (!_consentimento) return;

    await _crashlytics.recordError(
      erro,
      pilha,
      reason: contexto,
      fatal: false,
    );
  }

  /// Uma "migalha" de contexto, que acompanha o próximo crash.
  ///
  /// ⚠️ NUNCA passe conteúdo digitado pelo usuário. Registre
  /// O QUE ACONTECEU, nunca O QUE ELE ESCREVEU.
  /// Módulo 13, aula 6.
  Future<void> rastro(String acao) async {
    if (!_consentimento) return;
    await _crashlytics.log(acao);
  }

  /// Em que tela o usuário estava quando quebrou.
  Future<void> telaAtual(String rota) async {
    if (!_consentimento) return;
    await _crashlytics.setCustomKey('tela', rota);
  }

  /// Estado do app no momento do crash — só NÚMEROS e
  /// categorias, nunca conteúdo.
  Future<void> contexto({
    required int quantidadeDeMaterias,
    required bool online,
    required String tema,
  }) async {
    if (!_consentimento) return;

    await Future.wait(<Future<void>>[
      _crashlytics.setCustomKey('materias', quantidadeDeMaterias),
      _crashlytics.setCustomKey('online', online),
      _crashlytics.setCustomKey('tema', tema),
    ]);
  }

  /// Identificador ANÔNIMO, para agrupar os crashes de uma
  /// mesma pessoa.
  ///
  /// ⚠️ Nunca use e-mail, CPF ou nome. Um id aleatório,
  /// gerado na instalação, resolve o mesmo problema sem
  /// identificar ninguém.
  Future<void> identificarAnonimamente(String idAleatorio) async {
    if (!_consentimento) return;
    await _crashlytics.setUserIdentifier(idAleatorio);
  }

  /// Apaga o que foi coletado — direito do usuário na LGPD.
  Future<void> esquecer() async {
    await _crashlytics.setUserIdentifier('');
    await _crashlytics.deleteUnsentReports();
    await definirConsentimento(false);
  }
}
```

E o observador de rotas, que registra a navegação sem código espalhado:

> **Arquivo:** `lib/core/monitoramento/observador_de_rotas.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'telemetria.dart';

/// Registra a navegação automaticamente.
///
/// Quando um crash acontece, o painel mostra o caminho que o
/// usuário percorreu até ali — e é essa sequência que costuma
/// explicar o bug que "não reproduz".
class ObservadorDeRotas extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> rota, Route<dynamic>? anterior) {
    super.didPush(rota, anterior);
    _registrar('abriu', rota);
  }

  @override
  void didPop(Route<dynamic> rota, Route<dynamic>? anterior) {
    super.didPop(rota, anterior);
    _registrar('voltou de', rota);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _registrar('substituiu por', newRoute);
  }

  void _registrar(String acao, Route<dynamic> rota) {
    // ⚠️ Só o NOME da rota. Os argumentos podem conter dados do
    // usuário — o nome de uma matéria, um texto de busca.
    final String nome = rota.settings.name ?? 'sem-nome';

    Telemetria.instancia.rastro('$acao $nome');
    Telemetria.instancia.telaAtual(nome);
  }
}
```

E o diálogo de consentimento:

> **Arquivo:** `lib/core/monitoramento/pedido_de_consentimento.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telemetria.dart';

/// Pede consentimento para a coleta de dados de diagnóstico.
///
/// LGPD: o padrão é NÃO coletar. Só depois de um "sim"
/// explícito a telemetria é ligada.
abstract final class PedidoDeConsentimento {
  static const String _chave = 'consentimento_diagnostico';

  /// Restaura a escolha anterior ao abrir o app.
  static Future<void> restaurar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? escolha = prefs.getBool(_chave);

    // Null = nunca perguntou. O padrão é NÃO coletar.
    await Telemetria.instancia.definirConsentimento(escolha ?? false);
  }

  static Future<bool> jaRespondeu() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_chave);
  }

  /// Mostra o diálogo, se ainda não respondeu.
  static Future<void> perguntarSePreciso(BuildContext context) async {
    if (await jaRespondeu()) return;
    if (!context.mounted) return;

    final bool? aceita = await showDialog<bool>(
      context: context,
      // Não dá para fechar tocando fora: é uma escolha,
      // não um aviso.
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog.adaptive(
        icon: const Icon(Icons.insights_outlined),
        title: const Text('Ajude a melhorar o Foco'),
        // O texto diz O QUE é coletado, O QUE NÃO é, e que dá
        // para mudar de ideia. Os três pontos importam.
        content: const Text(
          'Podemos enviar relatórios automáticos quando algo dá '
          'errado no app — a tela em que você estava e o erro '
          'técnico.\n\n'
          'Não enviamos o conteúdo das suas matérias, anotações '
          'ou qualquer dado pessoal.\n\n'
          'Você pode mudar isso a qualquer momento em Ajustes.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Não enviar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Enviar relatórios'),
          ),
        ],
      ),
    );

    final bool escolha = aceita ?? false;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, escolha);
    await Telemetria.instancia.definirConsentimento(escolha);
  }

  /// Muda a escolha — chamado pela linha em Ajustes.
  static Future<void> alterar(bool permitir) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, permitir);
    await Telemetria.instancia.definirConsentimento(permitir);

    // Se revogou, apague o que já foi coletado — é direito
    // do usuário na LGPD.
    if (!permitir) {
      await Telemetria.instancia.esquecer();
    }
  }
}
```

E a rotina semanal, escrita:

> **Arquivo:** `docs/rotina-de-monitoramento.md` (novo)

```markdown
# Rotina semanal de monitoramento — 15 minutos

Toda segunda-feira. Quinze minutos, sempre na mesma ordem.

## 1. Crashes (5 min)

**Firebase Crashlytics**

- [ ] Taxa de usuários sem falhas — subiu ou caiu desde a semana passada?
- [ ] Algum crash NOVO no topo da lista?
- [ ] Os stack traces estão LEGÍVEIS?
      → Se não: os símbolos daquela versão não foram enviados.
        Módulo 13, aula 7.
- [ ] Algum crash afetando mais de 1% dos usuários?

| Data | Sem falhas % | Crash novo? | Ação |
|---|---|---|---|
| | | | |

## 2. Android vitals (3 min)

**Play Console → Qualidade do app**

- [ ] Taxa de falhas < 1,09%   ⚠️ acima disso, o Google REDUZ
      a visibilidade do app na loja
- [ ] Taxa de ANR < 0,47%
- [ ] Alguma métrica em vermelho?

## 3. App Store Connect (2 min)

- [ ] Crashes em Analytics → Metrics
- [ ] Alguma versão com pico?

## 4. Avaliações (5 min)

- [ ] Ler TODAS as novas, nas duas lojas
- [ ] Responder as de 1 e 2 estrelas — educadamente, dizendo
      em qual versão foi corrigido
- [ ] Anotar os pedidos recorrentes

| Data | Loja | Nota | O quê | Respondi? |
|---|---|---|---|---|
| | | | | |

## 5. Decisão

- [ ] Algo aqui exige um **hotfix** (aula 3)?
- [ ] Algo entra no próximo release?
- [ ] Algo vira issue no repositório?

---

## Limites que disparam ação imediata

| Se | Então |
|---|---|
| Taxa de falhas > 1% | Hotfix hoje |
| Um crash em > 5% dos usuários | Hotfix hoje |
| ANR > 0,47% | Investigar esta semana |
| 3 avaliações com o mesmo problema | Entra no próximo release |
| Retenção D1 < 20% | Revisar o primeiro minuto do app |
```

```powershell
flutter pub add firebase_core firebase_crashlytics
# Android: android/app/google-services.json
# iOS:     ios/Runner/GoogleService-Info.plist
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| **Dois** manipuladores de erro | `FlutterError.onError` pega o framework; `PlatformDispatcher` pega o resto. |
| `FlutterError.presentError` antes de reportar | Mantém o erro visível no console local. |
| `setCrashlyticsCollectionEnabled(!kDebugMode)` | Seus testes não poluem o painel. |
| Classe `Telemetria` única | **Um lugar** onde se garante que nenhum dado do usuário escapa. |
| `if (!_consentimento) return;` em todo método | LGPD: o padrão é não coletar. |
| `recordError(fatal: false)` | Erros tratados nunca virariam crash — e são os mais valiosos. |
| `rastro` só com a **ação** | Registre o que aconteceu, nunca o que o usuário escreveu. |
| `contexto` só com números e categorias | Quantidade de matérias diagnostica; o nome delas vaza. |
| `identificarAnonimamente` com id aleatório | Agrupa crashes sem identificar ninguém. |
| `esquecer()` | Direito de exclusão da LGPD. |
| `ObservadorDeRotas` | Mostra o **caminho** até o crash — o que explica o bug que "não reproduz". |
| Registrar só o **nome** da rota | Os argumentos podem conter dados do usuário. |
| `barrierDismissible: false` | É uma escolha, não um aviso. |
| Texto do diálogo em três partes | O que é coletado, o que **não** é, e que dá para mudar. |
| Padrão `escolha ?? false` | Nunca perguntou = não coletar. |
| `esquecer()` ao revogar | Revogar consentimento apaga o já coletado. |
| Rotina com **limites que disparam ação** | Sem eles, monitorar vira olhar números sem decidir nada. |

---

## 🤖🍎 Android × iOS

| | 🤖 Play Console | 🍎 App Store Connect |
|---|---|---|
| Crashes embutidos | Android vitals | Analytics → Metrics |
| Tempo real | ⚠️ Horas | ⚠️ Até 24 h |
| **Limite com consequência** | ✅ 1,09 % e 0,47 % | ❌ Não há |
| ANR | ✅ Métrica própria | ❌ Não existe |
| Responder avaliação | ✅ | ✅ |
| Símbolos | `mapping.txt` + Dart | **dSYM** + Dart |
| Consentimento obrigatório | ⚠️ Depende dos dados | ✅ **App Privacy** obrigatório |

> ⚠️ **O Google pune numericamente; a Apple filtra antes.** A Play Console tem limites que reduzem a
> visibilidade do app se ultrapassados; a App Store não tem esse mecanismo, mas a revisão humana
> barra antes o que o Android deixaria passar e mediria depois. **São duas filosofias, e nenhuma
> substitui monitorar.**

> 💡 **O Crashlytics resolve os dois lados de uma vez**, com tempo real e detalhe que nenhuma das
> lojas oferece. Se for instalar uma ferramenta só, instale essa.

---

## ⚠️ Erros comuns

### 1. Só `FlutterError.onError`

Metade dos crashes escapa.

**Correção:** `PlatformDispatcher.instance.onError` também.

### 2. Não enviar os símbolos

Stack traces ilegíveis.

**Correção:** envie os dois conjuntos, por versão.

### 3. Registrar conteúdo do usuário

Vazamento involuntário para terceiro.

**Correção:** o que aconteceu, não o que ele escreveu.

### 4. Coletar sem consentimento

Irregular sob a LGPD.

**Correção:** padrão não coletar; peça antes.

### 5. Usar e-mail como identificador

Dado pessoal num servidor de terceiro.

**Correção:** id aleatório.

### 6. Coletar em debug

Polui o painel com os seus testes.

**Correção:** `!kDebugMode`.

### 7. Ignorar os limites da Play Console

O Google reduz a visibilidade do app.

**Correção:** trate como prazo, não conselho.

### 8. Pedir avaliação na abertura

Queima um dos poucos pedidos permitidos.

**Correção:** após um momento de sucesso.

### 9. Não responder avaliações

Perde a chance de mudar a nota — e de mostrar a outros que você responde.

**Correção:** responda as de 1 e 2 estrelas.

### 10. Olhar só crashes

Erro tratado nunca vira crash, e indica muita coisa.

**Correção:** registre não fatais.

### 11. Monitorar sem limites de ação

Vira olhar números sem decidir nada.

**Correção:** defina o que dispara hotfix.

### 12. Não revisar a retenção D1

Você constrói recursos para quem já foi embora.

**Correção:** conserte o primeiro minuto primeiro.

---

## 🛠️ Exercício guiado

**Passo 1.** Instale o Crashlytics e configure **os dois** manipuladores.

**Passo 2.** Force um crash e confirme que ele aparece no painel. Quanto tempo levou?

**Passo 3.** O stack trace está legível? Se não, envie os símbolos e force outro.

**Passo 4.** Remova o `PlatformDispatcher.onError` e provoque um erro em `Future` sem `catch`. Ele
aparece?

**Passo 5.** Crie a classe `Telemetria` e ligue o `ObservadorDeRotas`.

**Passo 6.** Navegue por três telas e force um crash. O caminho aparece no painel?

**Passo 7.** Implemente o diálogo de consentimento. Responda "não" e force um crash. Foi enviado?

**Passo 8.** Abra os Android vitals. Qual a sua taxa de falhas? E a de ANR?

**Passo 9.** Leia todas as suas avaliações e responda uma. A pessoa foi notificada?

**Passo 10.** Crie `docs/rotina-de-monitoramento.md` e execute-a uma vez, cronometrando.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/16-publicacao-e-proximos-passos.md](../../exercicios/16-publicacao-e-proximos-passos.md)

Faça os de **Aplicação** (instalar e configurar) e o de **Reflexão** (o que você coleta, e se
precisa mesmo).

---

## 🏆 Desafio opcional

Monte um **painel de saúde** do seu app, atualizado semanalmente.

Requisitos:

- Uma planilha ou documento com: taxa de falhas, ANR, retenção D1/D7, avaliação média, instalações e
  desinstalações.
- Uma linha por semana, por pelo menos oito semanas.
- Um gráfico do que mudou depois de cada release — marque as datas.
- Uma seção de **hipóteses**: "a retenção caiu na semana 4; o que mudou?".
- Os limites que disparam ação, escritos antes de precisar deles.
- Uma **política de privacidade** de verdade, listando cada dado coletado e por quê.

Depois responda: qual métrica mais mudou o que você decidiu fazer? E qual você coletava sem nunca
olhar — e por que continuava coletando?

---

## 📌 Resumo

- **A maioria dos usuários não relata — desinstala.** Monitorar é o que torna isso visível.
- Configure **dois** manipuladores: `FlutterError.onError` e `PlatformDispatcher.instance.onError`.
- **Envie os símbolos**: Dart + `mapping.txt` no Android; Dart + **dSYM** no iOS.
- O relatório é enviado **na próxima abertura**, não no momento do crash.
- 🤖 **Taxa de falhas > 1,09 % ou ANR > 0,47 %** reduz a visibilidade do app na loja.
- **Retenção D1 baixa quase nunca é falta de recurso** — é o primeiro minuto do app.
- Registre **erros não fatais**: eles indicam problemas que nunca virariam crash.
- **O crash reporting é um canal de vazamento involuntário**: registre o que aconteceu, nunca o que
  o usuário escreveu.
- **LGPD**: padrão não coletar, consentimento explícito, id anônimo, direito de exclusão.
- Peça avaliação **após um momento de sucesso** — o número de pedidos é limitado.
- **Responda as avaliações de 1 e 2 estrelas**: muda notas, e é público.
- Uma **rotina semanal de 15 minutos** com **limites que disparam ação** vale mais que dez
  ferramentas.

---

## ☑️ Checklist de domínio

- [ ] Configurei os dois manipuladores de erro.
- [ ] Envio os símbolos de cada versão.
- [ ] Meus stack traces de produção estão legíveis.
- [ ] Registro erros não fatais.
- [ ] Nunca registro conteúdo do usuário.
- [ ] Peço consentimento antes de coletar.
- [ ] Uso identificador anônimo.
- [ ] Permito revogar e apagar.
- [ ] Acompanho taxa de falhas e ANR.
- [ ] Sei os limites que afetam a visibilidade na loja.
- [ ] Peço avaliação no momento certo.
- [ ] Respondo avaliações negativas.
- [ ] Tenho uma rotina semanal com limites de ação.

---

## 📚 Referências oficiais

- [Firebase Crashlytics — Flutter](https://firebase.google.com/docs/crashlytics/get-started?platform=flutter)
- [Get deobfuscated reports — Firebase](https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports)
- [Android vitals — Play Console Help](https://support.google.com/googleplay/android-developer/answer/9844486)
- [App Analytics — App Store Connect Help](https://developer.apple.com/help/app-store-connect/view-app-analytics/app-analytics-overview)
- [Ratings and reviews — Play Console](https://support.google.com/googleplay/android-developer/answer/138230)
- [Requesting App Store reviews — developer.apple.com](https://developer.apple.com/documentation/storekit/requesting_app_store_reviews)
- [LGPD — Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)
- [in_app_review — pub.dev](https://pub.dev/packages/in_app_review)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [CI/CD introdutório](04-ci-cd-introdutorio.md) | [README](README.md) | [Próximos passos](06-proximos-passos.md) |
