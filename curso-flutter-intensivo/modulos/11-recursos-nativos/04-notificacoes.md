# Aula 4 — Notificações

> **Módulo:** 11 - Recursos Nativos · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Diferenciar **notificação local** de **push** — e explicar por que push exige um backend.
- Configurar `flutter_local_notifications` nas duas plataformas, do zero.
- Pedir a permissão **`POST_NOTIFICATIONS`** (Android 13+) no momento certo.
- Agendar um lembrete de estudo com **fuso horário** correto, atravessando horário de verão.
- Entender o **Doze** do Android e o que ele faz com os seus alarmes.
- Conhecer os **limites reais do iOS** — e o que não prometer ao usuário.
- Tratar o **toque** na notificação, inclusive com o app fechado.
- Usar **canais de notificação** (Android 8+) corretamente.

## ✅ Pré-requisitos

- [Aula 1 — Permissões](01-permissoes.md) — **essencial**: `POST_NOTIFICATIONS` é permissão de
  tempo de execução.
- [Aula 7 — Pastas android/ e ios/](07-pastas-android-e-ios.md) — se você travar no
  `AndroidManifest.xml` ou no `AppDelegate`, dê uma espiada lá e volte.
- [Módulo 10, aula 2 — shared_preferences](../10-persistencia-de-dados/02-shared-preferences.md) —
  guardar a preferência de lembrete.
- [Módulo 07, aula 3 — Argumentos e resultados](../07-navegacao-e-formularios/03-argumentos-e-resultados.md)
  — abrir a tela certa ao tocar na notificação.

---

## 📖 Conceito

### Local × push

| | **Notificação local** | **Push** |
|---|---|---|
| Quem dispara | O **próprio app**, no aparelho | Um **servidor**, pela internet |
| Precisa de backend | ❌ | ✅ **Sempre** |
| Funciona offline | ✅ | ❌ |
| Precisa de Firebase/APNs | ❌ | ✅ |
| Custo | Zero | Servidor + configuração |
| Exemplo | "Hora de estudar Dart" | "Fulano comentou na sua foto" |

**Esta aula é sobre local.** Push exige Firebase Cloud Messaging (Android) e Apple Push
Notification service (iOS), certificados, um backend que guarda tokens de dispositivo — é um
assunto de curso inteiro, e o Foco não precisa dele.

> 📌 **A confusão comum:** achar que "lembrete diário" precisa de push. Não precisa. O lembrete é
> **agendado no aparelho** e dispara mesmo sem internet. Push só é necessário quando o **servidor**
> precisa avisar algo que o aparelho não tem como saber.

### A permissão do Android 13+

Até o Android 12, notificar era livre. A partir do **13 (API 33)**, `POST_NOTIFICATIONS` é uma
permissão de tempo de execução — igual à câmera.

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

E, no código, ela precisa ser **pedida**:

```dart
await Permission.notification.request();
```

> ⚠️ **O momento importa mais aqui do que em qualquer outra permissão.** Pedir na primeira abertura,
> antes de o usuário entender o que o app faz, resulta em recusa — e uma recusa no Android 13+ é
> quase definitiva: na segunda negação, o sistema nem mostra mais o diálogo.
>
> **Peça quando o usuário liga o lembrete.** Aí o pedido faz sentido para ele, e a taxa de
> aceitação é muito maior. A [aula 1](01-permissoes.md) trata disso a fundo.

### Canais (Android 8+)

Desde o Android 8, toda notificação pertence a um **canal**. O canal define som, vibração,
importância — e o **usuário controla cada canal separadamente**.

```dart
const AndroidNotificationChannel canalLembretes = AndroidNotificationChannel(
  'lembretes_estudo',            // id — nunca muda depois de publicado
  'Lembretes de estudo',         // nome visível ao usuário
  description: 'Avisa na hora de estudar',
  importance: Importance.high,
);
```

| Importância | Efeito |
|---|---|
| `max` / `high` | Aparece na tela, com som |
| `defaultImportance` | Som, sem aparecer por cima |
| `low` | Sem som |
| `min` | Sem som, sem ícone na barra |

Três regras que evitam problemas:

**1. O `id` do canal nunca muda.** Depois de publicado, mudá-lo cria um canal **novo** — e as
preferências que o usuário ajustou no antigo ficam órfãs.

**2. Configurações do canal não mudam depois de criado.** Se você publicar com `Importance.low` e
depois mudar para `high`, **nada acontece**: o Android respeita a escolha do usuário. Para mudar de
verdade, é preciso um canal novo, com id novo.

**3. Separe por propósito.** "Lembretes" e "conquistas" em canais diferentes permitem ao usuário
desligar um e manter o outro — em vez de desligar tudo.

### Fuso horário: o detalhe que quebra o agendamento

Agendar "todo dia às 19h" parece simples e tem uma armadilha:

```dart
// ❌ ignora fuso e horário de verão
await plugin.schedule(id, titulo, corpo, DateTime(2026, 3, 10, 19), detalhes);
```

O `flutter_local_notifications` exige um **`TZDateTime`**, do pacote `timezone`:

```dart
tz.initializeTimeZones();
final String nome = await FlutterTimezone.getLocalTimezone();
tz.setLocalLocation(tz.getLocation(nome));

final tz.TZDateTime quando = tz.TZDateTime(tz.local, 2026, 3, 10, 19);
```

Por que isso importa de verdade:

| Situação | Sem timezone | Com timezone |
|---|---|---|
| Usuário viaja de fuso | Toca no horário errado | Toca às 19h **locais** |
| Horário de verão começa | Pode pular ou repetir | Correto |
| Aparelho muda de fuso sozinho | Desalinha | Recalculado |

> 📌 O Brasil não tem horário de verão desde 2019 — mas o app pode ser usado em qualquer lugar, e o
> `timezone` custa três linhas. É o tipo de coisa que você não quer descobrir que esqueceu.

E, para repetir diariamente, existe um parâmetro específico:

```dart
matchDateTimeComponents: DateTimeComponents.time,  // todo dia no mesmo horário
```

| Valor | Repetição |
|---|---|
| `null` | Uma vez só |
| `DateTimeComponents.time` | Todo dia, no mesmo horário |
| `DateTimeComponents.dayOfWeekAndTime` | Toda semana, no mesmo dia e horário |
| `DateTimeComponents.dayOfMonthAndTime` | Todo mês |

### O Doze do Android

A partir do Android 6, o sistema entra em **Doze** quando o aparelho fica parado, sem tela, na
tomada ou não. No Doze, alarmes são **agrupados** e disparam em janelas — o que significa que um
lembrete das 19h pode tocar às 19h07.

O `flutter_local_notifications` oferece três modos:

```dart
androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
```

| Modo | Precisão | Permissão especial |
|---|---|---|
| `inexact` | Pode atrasar bastante | ❌ |
| `inexactAllowWhileIdle` | Atrasa pouco, fura o Doze | ❌ |
| `exactAllowWhileIdle` | Exato | ✅ `SCHEDULE_EXACT_ALARM` |

> ⚠️ **`SCHEDULE_EXACT_ALARM` é restrita.** No Android 13 ela era concedida automaticamente; do
> **Android 14** em diante, o app precisa pedir e o Google **exige justificativa** na publicação —
> aceita basicamente para despertadores e calendários.
>
> Um lembrete de estudo **não** justifica. Use `inexactAllowWhileIdle`: tocar às 19h05 em vez das
> 19h00 não muda nada para o usuário, e o app passa na revisão.

> 📌 **Fabricantes pioram isso.** Xiaomi, Huawei, Oppo e Samsung têm otimizações de bateria
> próprias, mais agressivas que o Doze. Em alguns aparelhos, o app precisa estar na lista de
> exceções para o lembrete tocar. Isso está **fora do seu controle** — e é por isso que a próxima
> seção importa.

### Os limites do iOS

O iOS é mais restrito e mais previsível:

| Limite | Valor |
|---|---|
| Notificações **pendentes** por app | **64** |
| Repetição mínima | 60 segundos |
| Notificação com app fechado | ✅ (é o sistema que dispara) |
| Executar código antes de mostrar | ❌ Não, em notificação local |
| Cancelar uma específica | ✅ pelo id |

> ⚠️ **O limite de 64 é real e pega quem agenda "os próximos 30 dias".** Um lembrete diário
> agendado individualmente para dois meses estoura o limite, e as notificações excedentes são
> **descartadas em silêncio**.
>
> **Correção:** use `matchDateTimeComponents` (uma notificação recorrente conta como **uma**) em vez
> de agendar N notificações individuais.

E a regra de produto mais importante desta aula:

> **Não prometa ao usuário que a notificação vai chegar exatamente no horário.** Entre Doze,
> otimizações de fabricante e limites do iOS, ela é um **lembrete**, não um alarme. Se o seu app
> precisa de precisão de alarme, ele precisa ser um despertador — e aí a conversa é outra.

### Tocar na notificação

Há dois casos, e eles têm APIs diferentes:

**1. App aberto ou em segundo plano** — `onDidReceiveNotificationResponse`:

```dart
await plugin.initialize(
  configuracao,
  onDidReceiveNotificationResponse: (NotificationResponse r) {
    final String? carga = r.payload;   // seus dados
    // Navegar para a tela certa.
  },
);
```

**2. App fechado** — `getNotificationAppLaunchDetails`:

```dart
final NotificationAppLaunchDetails? detalhes =
    await plugin.getNotificationAppLaunchDetails();

if (detalhes?.didNotificationLaunchApp ?? false) {
  final String? carga = detalhes!.notificationResponse?.payload;
  // O app foi ABERTO pela notificação.
}
```

> ⚠️ **O segundo caso é o mais esquecido.** O usuário toca na notificação com o app fechado, o app
> abre — na tela inicial, como se nada tivesse acontecido. Ele toca de novo, e nada. A experiência é
> de app quebrado.

---

## 💡 Analogia

Pense em combinar um lembrete com alguém.

- **Notificação local** é você programar o **seu próprio despertador**. Ninguém precisa te ligar: o
  aparelho já sabe a hora. Funciona no avião, no metrô, sem sinal.
- **Push** é pedir para **outra pessoa te ligar**. Ela precisa saber o seu número (o token do
  dispositivo), precisa de linha (internet), e precisa existir (o servidor). É por isso que push
  exige backend — alguém tem que fazer a ligação.
- **Os canais** são as **categorias do toque do celular**: um som para chamada, outro para
  mensagem, outro para alarme. O usuário pode silenciar as mensagens e manter as chamadas. Um app
  com canal único obriga o usuário a escolher entre tudo e nada.
- **O `id` do canal que nunca muda** é o nome da categoria. Se você renomear "Mensagens" para
  "Chats", o celular cria uma categoria nova — e o volume que o usuário ajustou fica na antiga.
- **O Doze** é o modo "não perturbe" do prédio: entre 2h e 6h, o porteiro **junta** todas as
  encomendas e entrega de uma vez, em vez de subir a cada uma. A sua encomenda chega — não
  exatamente na hora que você pediu.
- **O limite de 64 do iOS** é a caixa de recados da portaria: cabem 64 bilhetes. O 65º é jogado
  fora, **sem avisar**. Deixar um bilhete que diz "todo dia às 19h" ocupa **um** espaço; deixar 60
  bilhetes, um por dia, ocupa 60.
- **Tocar na notificação com o app fechado** é a pessoa chegar na portaria por causa do seu recado
  — e o porteiro fingir que não sabe de nada. Ela vai embora achando que o recado era engano.

---

## 🧪 Exemplo mínimo

Notificação imediata, agendada e diária, com toque tratado.

> **Arquivo:** `foco_nativo/lib/main.dart` (temporário)
> **Instale antes:** `flutter pub add flutter_local_notifications timezone flutter_timezone permission_handler`
> **Como executar:** `flutter run` em um **emulador Android** (no Windows desktop não funciona)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

/// O canal. Desde o Android 8, toda notificação pertence a um.
///
/// ⚠️ O `id` NUNCA muda depois de publicado: mudá-lo cria um canal novo
/// e as preferências que o usuário ajustou ficam órfãs.
const AndroidNotificationChannel _canal = AndroidNotificationChannel(
  'lembretes_estudo',
  'Lembretes de estudo',
  description: 'Avisa na hora de estudar',
  importance: Importance.high,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Fuso horário. Sem isto, o agendamento erra quando o usuário
  //    viaja ou quando o horário de verão muda.
  tzdata.initializeTimeZones();
  final String nomeDoFuso = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(nomeDoFuso));

  // 2. Ícone: `@mipmap/ic_launcher` sempre existe num projeto Flutter.
  //    Um ícone próprio precisa ser monocromático no Android.
  const AndroidInitializationSettings android =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // 3. No iOS, NÃO peça permissão aqui: o diálogo apareceria na
  //    primeira abertura, antes de o usuário entender o app — e uma
  //    recusa é difícil de reverter.
  const DarwinInitializationSettings ios = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  await _plugin.initialize(
    const InitializationSettings(android: android, iOS: ios),
    // App ABERTO ou em segundo plano.
    onDidReceiveNotificationResponse: (NotificationResponse r) {
      debugPrint('👆 tocou (app vivo) · payload: ${r.payload}');
    },
  );

  // 4. Cria o canal. Chamar de novo com o mesmo id não faz nada.
  await _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_canal);

  runApp(const AppNotificacoes());
}

class AppNotificacoes extends StatelessWidget {
  const AppNotificacoes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaNotificacoes(),
    );
  }
}

class TelaNotificacoes extends StatefulWidget {
  const TelaNotificacoes({super.key});

  @override
  State<TelaNotificacoes> createState() => _TelaNotificacoesState();
}

class _TelaNotificacoesState extends State<TelaNotificacoes> {
  final List<String> _log = <String>[];

  @override
  void initState() {
    super.initState();
    _verificarAberturaPorNotificacao();
  }

  void _registrar(String linha) {
    debugPrint(linha);
    if (mounted) setState(() => _log.insert(0, linha));
  }

  /// App FECHADO: `onDidReceiveNotificationResponse` NÃO é chamado.
  ///
  /// Sem isto, o usuário toca na notificação, o app abre na tela
  /// inicial como se nada tivesse acontecido, e ele conclui que
  /// está quebrado.
  Future<void> _verificarAberturaPorNotificacao() async {
    final NotificationAppLaunchDetails? detalhes =
        await _plugin.getNotificationAppLaunchDetails();

    if (detalhes?.didNotificationLaunchApp ?? false) {
      final String? carga = detalhes!.notificationResponse?.payload;
      _registrar('🚀 app ABERTO por notificação · payload: $carga');
    }
  }

  // ── Permissão ────────────────────────────────────────────────────────────

  /// Pede permissão NO MOMENTO CERTO: quando o usuário liga o lembrete.
  ///
  /// Pedir na primeira abertura, antes de ele entender o app, resulta
  /// em recusa — e no Android 13+ a segunda negação nem mostra diálogo.
  Future<bool> _garantirPermissao() async {
    final PermissionStatus status = await Permission.notification.request();

    if (status.isPermanentlyDenied) {
      _registrar('🚫 negada permanentemente — só nos Ajustes');
      if (mounted) await _oferecerAjustes();
      return false;
    }

    _registrar(status.isGranted ? '✅ permissão concedida' : '❌ negada');
    return status.isGranted;
  }

  Future<void> _oferecerAjustes() async {
    final bool? abrir = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Notificações desligadas'),
        content: const Text(
          'Para receber lembretes, ative as notificações do Foco '
          'nos ajustes do aparelho.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
    if (abrir ?? false) await openAppSettings();
  }

  // ── Notificar ────────────────────────────────────────────────────────────

  NotificationDetails get _detalhes => NotificationDetails(
        android: AndroidNotificationDetails(
          _canal.id,
          _canal.name,
          channelDescription: _canal.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

  Future<void> _agora() async {
    if (!await _garantirPermissao()) return;

    await _plugin.show(
      0,
      'Hora de estudar',
      'Você tem 25 minutos de Dart pendentes',
      _detalhes,
      // O payload volta quando o usuário toca. Use-o para saber
      // qual tela abrir.
      payload: 'materia:dart',
    );
    _registrar('🔔 notificação enviada');
  }

  Future<void> _em10Segundos() async {
    if (!await _garantirPermissao()) return;

    // TZDateTime, não DateTime: é o que faz o agendamento respeitar
    // fuso e horário de verão.
    final tz.TZDateTime quando =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    await _plugin.zonedSchedule(
      1,
      'Lembrete agendado',
      'Programado 10 segundos atrás',
      quando,
      _detalhes,
      // inexactAllowWhileIdle: fura o Doze sem exigir
      // SCHEDULE_EXACT_ALARM, que o Google só aprova para
      // despertadores e calendários.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'agendada',
    );
    _registrar('⏰ agendada para ${quando.hour}:${quando.minute}:${quando.second}');
    _registrar('   (feche o app para ver a notificação chegar)');
  }

  Future<void> _todoDiaAs19() async {
    if (!await _garantirPermissao()) return;

    final tz.TZDateTime quando = _proximaOcorrencia(19, 0);

    await _plugin.zonedSchedule(
      2,
      'Hora de estudar',
      'Que tal 25 minutos hoje?',
      quando,
      _detalhes,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // UMA notificação recorrente, não 30 individuais.
      // No iOS o limite é 64 PENDENTES: agendar dia a dia estouraria,
      // e as excedentes seriam descartadas em silêncio.
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'lembrete_diario',
    );
    _registrar('📅 lembrete diário às 19h (próximo: ${quando.day}/${quando.month})');
  }

  /// Calcula a próxima ocorrência do horário.
  ///
  /// Se já passou hoje, agenda para amanhã. Sem isto, um lembrete
  /// das 19h configurado às 20h dispararia imediatamente.
  tz.TZDateTime _proximaOcorrencia(int hora, int minuto) {
    final tz.TZDateTime agora = tz.TZDateTime.now(tz.local);
    tz.TZDateTime alvo = tz.TZDateTime(
      tz.local,
      agora.year,
      agora.month,
      agora.day,
      hora,
      minuto,
    );
    if (alvo.isBefore(agora)) alvo = alvo.add(const Duration(days: 1));
    return alvo;
  }

  Future<void> _listarPendentes() async {
    final List<PendingNotificationRequest> pendentes =
        await _plugin.pendingNotificationRequests();

    if (pendentes.isEmpty) {
      _registrar('📭 nenhuma notificação pendente');
      return;
    }

    _registrar('📬 ${pendentes.length} pendente(s) — limite do iOS: 64');
    for (final PendingNotificationRequest p in pendentes) {
      _registrar('   [${p.id}] ${p.title}');
    }
  }

  Future<void> _cancelarTudo() async {
    await _plugin.cancelAll();
    _registrar('🗑️ todas canceladas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações locais')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(onPressed: _agora, child: const Text('Agora')),
                FilledButton.tonal(
                  onPressed: _em10Segundos,
                  child: const Text('Em 10 s'),
                ),
                FilledButton.tonal(
                  onPressed: _todoDiaAs19,
                  child: const Text('Todo dia 19h'),
                ),
                OutlinedButton(
                  onPressed: _listarPendentes,
                  child: const Text('Pendentes'),
                ),
                TextButton(
                  onPressed: _cancelarTudo,
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (BuildContext c, int i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Text(
                  _log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**O roteiro:**

1. **Agora** → o diálogo de permissão aparece (Android 13+), e a notificação chega.
2. **Em 10 s** → **feche o app** e espere. Ela chega com o app fechado.
3. Toque nela → o app abre e o log mostra `🚀 app ABERTO por notificação`.
4. **Todo dia 19h** → depois, **Pendentes**: aparece **uma** entrada, não 30.
5. Negue a permissão duas vezes e tente de novo: o diálogo do sistema **não aparece mais** — só o
   caminho dos ajustes.

---

## 📱 Aplicando no Flutter

O `foco_nativo` ganha lembretes de estudo:

- `ServicoDeNotificacoes` — inicialização, canais, agendamento;
- `LembretesController` — preferência do usuário, persistida;
- tela de ajustes com horário, dias da semana e teste;
- navegação ao tocar, nos dois casos (app vivo e fechado).

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Android 13+ (API 33): notificar virou permissão de tempo
         de execução. Sem ela, o app não notifica nada. -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- Permite reagendar as notificações quando o aparelho reinicia.
         SEM isto, todos os lembretes somem depois de um reboot. -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <!-- ⚠️ NÃO usamos SCHEDULE_EXACT_ALARM.
         Do Android 14 em diante, o Google exige justificativa na
         publicação, e aceita basicamente despertadores e calendários.
         Um lembrete de estudo não justifica — e tocar às 19h05 em
         vez das 19h00 não muda nada para o usuário. -->

    <application android:label="Foco" android:icon="@mipmap/ic_launcher">
        <activity android:name=".MainActivity" ...>
            ...
        </activity>

        <!-- Reagenda as notificações após reiniciar o aparelho. -->
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>

        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    </application>
</manifest>
```

> **Arquivo:** `foco_nativo/ios/Runner/AppDelegate.swift`

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Necessário para a notificação aparecer com o app EM PRIMEIRO PLANO.
    // Sem esta linha, no iOS ela é entregue silenciosamente — o usuário
    // com o app aberto simplesmente não vê nada.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

> **Arquivo:** `foco_nativo/lib/core/notificacoes/servico_de_notificacoes.dart` (novo)

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Canais do app.
///
/// Separar por PROPÓSITO permite ao usuário desligar um e manter o
/// outro. Com canal único, ele escolhe entre tudo e nada — e escolhe
/// nada.
abstract final class Canais {
  /// ⚠️ Os `id` NUNCA mudam depois de publicados. Mudar um cria um canal
  /// NOVO, e as preferências que o usuário ajustou ficam órfãs.
  static const AndroidNotificationChannel lembretes =
      AndroidNotificationChannel(
    'foco_lembretes_v1',
    'Lembretes de estudo',
    description: 'Avisa na hora que você escolheu para estudar',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel conquistas =
      AndroidNotificationChannel(
    'foco_conquistas_v1',
    'Conquistas',
    description: 'Avisa quando você bate uma meta',
    importance: Importance.defaultImportance,
  );

  static const List<AndroidNotificationChannel> todos =
      <AndroidNotificationChannel>[lembretes, conquistas];
}

/// Ids fixos das notificações.
///
/// Fixos porque `zonedSchedule` com um id já usado SUBSTITUI a anterior —
/// é assim que reagendamos sem duplicar.
abstract final class IdsDeNotificacao {
  static const int lembreteDiario = 1000;

  /// Um id por dia da semana (1 = segunda … 7 = domingo).
  static int lembreteSemanal(int diaDaSemana) => 1100 + diaDaSemana;

  static const int teste = 9999;
}

/// O que fazer quando o usuário toca.
typedef AoTocar = void Function(String? payload);

class ServicoDeNotificacoes {
  ServicoDeNotificacoes([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _iniciado = false;

  /// Payload da notificação que ABRIU o app, se foi o caso.
  String? payloadDeAbertura;

  // ── Inicialização ────────────────────────────────────────────────────────

  /// Chame no `main`, antes do `runApp`.
  Future<void> iniciar({required AoTocar aoTocar}) async {
    if (_iniciado) return;

    // 1. Fuso horário. Sem isto, o agendamento erra quando o usuário
    //    viaja ou quando o horário de verão muda.
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    } on Object catch (e) {
      // Fuso desconhecido pelo pacote (raro, acontece em ROMs
      // alternativas). UTC é melhor que quebrar na abertura.
      debugPrint('Fuso não reconhecido, usando UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ⚠️ requestXPermission: false — NÃO peça permissão aqui.
    // O diálogo apareceria na primeira abertura, antes de o usuário
    // entender o app, e uma recusa é difícil de reverter.
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      // App ABERTO ou em segundo plano.
      onDidReceiveNotificationResponse: (NotificationResponse r) =>
          aoTocar(r.payload),
    );

    // 2. Cria os canais. Chamar de novo com o mesmo id não faz nada.
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    for (final AndroidNotificationChannel canal in Canais.todos) {
      await androidPlugin?.createNotificationChannel(canal);
    }

    // 3. App FECHADO: o callback acima NÃO é chamado. Sem isto, o
    //    usuário toca na notificação, o app abre na tela inicial como
    //    se nada tivesse acontecido, e conclui que está quebrado.
    final NotificationAppLaunchDetails? abertura =
        await _plugin.getNotificationAppLaunchDetails();

    if (abertura?.didNotificationLaunchApp ?? false) {
      payloadDeAbertura = abertura!.notificationResponse?.payload;
    }

    _iniciado = true;
  }

  // ── Permissão ────────────────────────────────────────────────────────────

  Future<bool> temPermissao() async =>
      (await Permission.notification.status).isGranted;

  /// Pede permissão.
  ///
  /// Chame QUANDO O USUÁRIO LIGA O LEMBRETE — não na abertura do app.
  /// No Android 13+, a segunda negação nem mostra mais o diálogo.
  Future<ResultadoDePermissao> pedirPermissao() async {
    final PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) return ResultadoDePermissao.concedida;
    if (status.isPermanentlyDenied) {
      return ResultadoDePermissao.negadaPermanentemente;
    }
    return ResultadoDePermissao.negada;
  }

  Future<void> abrirAjustes() => openAppSettings();

  // ── Agendar ──────────────────────────────────────────────────────────────

  NotificationDetails _detalhes(AndroidNotificationChannel canal) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        canal.id,
        canal.name,
        channelDescription: canal.description,
        importance: canal.importance,
        priority: Priority.high,
        // Texto longo expandível: o usuário vê o conteúdo inteiro
        // ao puxar a notificação para baixo.
        styleInformation: const BigTextStyleInformation(''),
      ),
      iOS: const DarwinNotificationDetails(
        // Sem badge: o número no ícone do app é ruído para um
        // lembrete que não é uma "mensagem não lida".
        presentBadge: false,
      ),
    );
  }

  /// Lembrete diário no horário escolhido.
  ///
  /// UMA notificação recorrente, não 30 individuais: no iOS o limite
  /// é 64 PENDENTES, e as excedentes são descartadas EM SILÊNCIO.
  Future<void> agendarLembreteDiario({
    required int hora,
    required int minuto,
    String titulo = 'Hora de estudar',
    String corpo = 'Que tal uma sessão de 25 minutos?',
  }) async {
    await _plugin.zonedSchedule(
      // Id fixo: reagendar SUBSTITUI, em vez de duplicar.
      IdsDeNotificacao.lembreteDiario,
      titulo,
      corpo,
      _proximaOcorrencia(hora, minuto),
      _detalhes(Canais.lembretes),
      // inexactAllowWhileIdle: fura o Doze sem exigir
      // SCHEDULE_EXACT_ALARM, que o Google só aprova para
      // despertadores e calendários. Tocar às 19h05 em vez de 19h00
      // não muda nada para o usuário.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'lembrete_diario',
    );
  }

  /// Lembretes só em dias escolhidos da semana.
  ///
  /// Sete notificações recorrentes, no máximo — bem abaixo do limite
  /// de 64 do iOS.
  Future<void> agendarLembretesSemanais({
    required Set<int> diasDaSemana, // 1 = segunda … 7 = domingo
    required int hora,
    required int minuto,
  }) async {
    // Cancela os dias que saíram da seleção.
    for (int dia = 1; dia <= 7; dia++) {
      await _plugin.cancel(IdsDeNotificacao.lembreteSemanal(dia));
    }

    for (final int dia in diasDaSemana) {
      await _plugin.zonedSchedule(
        IdsDeNotificacao.lembreteSemanal(dia),
        'Hora de estudar',
        'Seu lembrete de ${_nomeDoDia(dia)}',
        _proximaOcorrenciaNoDia(dia, hora, minuto),
        _detalhes(Canais.lembretes),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'lembrete_semanal:$dia',
      );
    }
  }

  /// Comemora uma meta batida. Imediata, canal diferente.
  Future<void> comemorar(String materia, int minutos) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Meta cumprida! 🎉',
      'Você estudou $minutos minutos de $materia hoje',
      _detalhes(Canais.conquistas),
      payload: 'conquista:$materia',
    );
  }

  Future<void> testar() async {
    await _plugin.zonedSchedule(
      IdsDeNotificacao.teste,
      'Teste do Foco',
      'Se você está vendo isto, os lembretes funcionam',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _detalhes(Canais.lembretes),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'teste',
    );
  }

  // ── Cancelar e inspecionar ───────────────────────────────────────────────

  Future<void> cancelarLembretes() async {
    await _plugin.cancel(IdsDeNotificacao.lembreteDiario);
    for (int dia = 1; dia <= 7; dia++) {
      await _plugin.cancel(IdsDeNotificacao.lembreteSemanal(dia));
    }
  }

  Future<void> cancelarTudo() => _plugin.cancelAll();

  /// Pendentes. Use para diagnosticar o limite de 64 do iOS.
  Future<List<PendingNotificationRequest>> pendentes() =>
      _plugin.pendingNotificationRequests();

  // ── Cálculo de horário ───────────────────────────────────────────────────

  /// Próxima ocorrência do horário.
  ///
  /// Se já passou hoje, agenda para amanhã. Sem isto, um lembrete das
  /// 19h configurado às 20h dispararia IMEDIATAMENTE.
  tz.TZDateTime _proximaOcorrencia(int hora, int minuto) {
    final tz.TZDateTime agora = tz.TZDateTime.now(tz.local);
    tz.TZDateTime alvo = tz.TZDateTime(
      tz.local,
      agora.year,
      agora.month,
      agora.day,
      hora,
      minuto,
    );
    if (!alvo.isAfter(agora)) alvo = alvo.add(const Duration(days: 1));
    return alvo;
  }

  tz.TZDateTime _proximaOcorrenciaNoDia(int diaDaSemana, int hora, int minuto) {
    tz.TZDateTime alvo = _proximaOcorrencia(hora, minuto);
    // Avança até cair no dia certo. No máximo 7 voltas.
    while (alvo.weekday != diaDaSemana) {
      alvo = alvo.add(const Duration(days: 1));
    }
    return alvo;
  }

  static String _nomeDoDia(int dia) => const <String>[
        '', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo',
      ][dia];
}

enum ResultadoDePermissao {
  concedida,
  negada,
  negadaPermanentemente;

  bool get podeUsar => this == ResultadoDePermissao.concedida;
}
```

> **Arquivo:** `foco_nativo/lib/features/lembretes/presentation/lembretes_controller.dart` (novo)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foco_nativo/core/notificacoes/servico_de_notificacoes.dart';

/// Preferência de lembrete do usuário.
class ConfiguracaoDeLembrete {
  const ConfiguracaoDeLembrete({
    this.ligado = false,
    this.hora = 19,
    this.minuto = 0,
    this.dias = const <int>{1, 2, 3, 4, 5},
  });

  final bool ligado;
  final int hora;
  final int minuto;

  /// 1 = segunda … 7 = domingo.
  final Set<int> dias;

  bool get todosOsDias => dias.length == 7;

  String get horarioLegivel =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

  ConfiguracaoDeLembrete copyWith({
    bool? ligado,
    int? hora,
    int? minuto,
    Set<int>? dias,
  }) {
    return ConfiguracaoDeLembrete(
      ligado: ligado ?? this.ligado,
      hora: hora ?? this.hora,
      minuto: minuto ?? this.minuto,
      dias: dias ?? this.dias,
    );
  }
}

final NotifierProvider<LembretesController, ConfiguracaoDeLembrete>
    lembretesProvider =
    NotifierProvider<LembretesController, ConfiguracaoDeLembrete>(
        LembretesController.new);

class LembretesController extends Notifier<ConfiguracaoDeLembrete> {
  static const String _kLigado = 'lembrete.ligado';
  static const String _kHora = 'lembrete.hora';
  static const String _kMinuto = 'lembrete.minuto';
  static const String _kDias = 'lembrete.dias';

  ServicoDeNotificacoes get _servico => ref.read(notificacoesProvider);

  @override
  ConfiguracaoDeLembrete build() {
    Future<void>.microtask(_carregar);
    return const ConfiguracaoDeLembrete();
  }

  Future<void> _carregar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    state = ConfiguracaoDeLembrete(
      ligado: prefs.getBool(_kLigado) ?? false,
      hora: prefs.getInt(_kHora) ?? 19,
      minuto: prefs.getInt(_kMinuto) ?? 0,
      dias: (prefs.getStringList(_kDias) ?? <String>['1', '2', '3', '4', '5'])
          .map(int.parse)
          .toSet(),
    );

    // O usuário pode ter desligado as notificações nos Ajustes do
    // sistema depois de ligar o lembrete no app. A tela precisa
    // refletir a realidade, não a preferência salva.
    if (state.ligado && !await _servico.temPermissao()) {
      state = state.copyWith(ligado: false);
      await _salvar();
      await _servico.cancelarLembretes();
    }
  }

  Future<void> _salvar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLigado, state.ligado);
    await prefs.setInt(_kHora, state.hora);
    await prefs.setInt(_kMinuto, state.minuto);
    await prefs.setStringList(
      _kDias,
      state.dias.map((int d) => '$d').toList(),
    );
  }

  /// Liga ou desliga o lembrete.
  ///
  /// É AQUI que a permissão é pedida — no momento em que o usuário
  /// demonstra que quer notificações. Pedir na abertura do app
  /// resultaria em recusa.
  Future<ResultadoDePermissao> alternar(bool ligar) async {
    if (!ligar) {
      state = state.copyWith(ligado: false);
      await _salvar();
      await _servico.cancelarLembretes();
      return ResultadoDePermissao.concedida;
    }

    final ResultadoDePermissao resultado = await _servico.pedirPermissao();
    if (!resultado.podeUsar) return resultado;

    state = state.copyWith(ligado: true);
    await _salvar();
    await _reagendar();
    return resultado;
  }

  Future<void> definirHorario(int hora, int minuto) async {
    state = state.copyWith(hora: hora, minuto: minuto);
    await _salvar();
    if (state.ligado) await _reagendar();
  }

  Future<void> alternarDia(int dia) async {
    final Set<int> novos = <int>{...state.dias};
    if (!novos.remove(dia)) novos.add(dia);

    // Nenhum dia selecionado = lembrete desligado. Deixar zero dias
    // com o interruptor ligado seria mentir para o usuário.
    if (novos.isEmpty) {
      await alternar(false);
      return;
    }

    state = state.copyWith(dias: novos);
    await _salvar();
    if (state.ligado) await _reagendar();
  }

  Future<void> _reagendar() async {
    // Cancela antes de agendar: ids fixos substituem, mas dias
    // removidos da seleção precisam sair.
    await _servico.cancelarLembretes();

    if (state.todosOsDias) {
      // Um lembrete diário em vez de sete semanais: menos
      // notificações pendentes, mais simples.
      await _servico.agendarLembreteDiario(
        hora: state.hora,
        minuto: state.minuto,
      );
    } else {
      await _servico.agendarLembretesSemanais(
        diasDaSemana: state.dias,
        hora: state.hora,
        minuto: state.minuto,
      );
    }
  }

  Future<void> testar() => _servico.testar();
}

final Provider<ServicoDeNotificacoes> notificacoesProvider =
    Provider<ServicoDeNotificacoes>((Ref ref) {
  throw UnimplementedError('Sobrescreva no main() com a instância iniciada');
});
```

> **Arquivo:** `foco_nativo/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_nativo/app.dart';
import 'package:foco_nativo/core/notificacoes/servico_de_notificacoes.dart';

/// Chave global do Navigator: permite navegar a partir do callback da
/// notificação, que não tem BuildContext.
final GlobalKey<NavigatorState> chaveDoNavigator = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ServicoDeNotificacoes notificacoes = ServicoDeNotificacoes();

  await notificacoes.iniciar(
    // App ABERTO ou em segundo plano.
    aoTocar: (String? payload) => _abrirTela(payload),
  );

  // App FECHADO: o `iniciar` guardou o payload da notificação que
  // abriu o app. Navegamos DEPOIS do primeiro quadro, quando o
  // Navigator já existe.
  final String? aberturaPorNotificacao = notificacoes.payloadDeAbertura;
  if (aberturaPorNotificacao != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _abrirTela(aberturaPorNotificacao);
    });
  }

  runApp(
    ProviderScope(
      overrides: <Override>[
        notificacoesProvider.overrideWithValue(notificacoes),
      ],
      child: const FocoApp(),
    ),
  );
}

void _abrirTela(String? payload) {
  if (payload == null) return;

  final NavigatorState? navigator = chaveDoNavigator.currentState;
  if (navigator == null) return;

  // O payload diz QUAL tela abrir. Sem isto, o usuário toca na
  // notificação e cai na tela inicial, como se nada tivesse acontecido.
  if (payload.startsWith('materia:')) {
    navigator.pushNamed('/materia', arguments: payload.substring(8));
  } else if (payload.startsWith('lembrete')) {
    navigator.pushNamed('/hoje');
  } else if (payload.startsWith('conquista:')) {
    navigator.pushNamed('/estatisticas');
  }
}
```

> **Arquivo:** `foco_nativo/lib/features/lembretes/presentation/lembretes_screen.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foco_nativo/core/notificacoes/servico_de_notificacoes.dart';
import 'package:foco_nativo/features/lembretes/presentation/lembretes_controller.dart';

class LembretesScreen extends ConsumerWidget {
  const LembretesScreen({super.key});

  static const List<String> _diasCurtos =
      <String>['', 'S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ConfiguracaoDeLembrete config = ref.watch(lembretesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes')),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Lembrete de estudo'),
            subtitle: Text(
              config.ligado
                  ? 'Todo dia às ${config.horarioLegivel}'
                  : 'Desligado',
            ),
            value: config.ligado,
            onChanged: (bool ligar) => _alternar(context, ref, ligar),
          ),

          if (config.ligado) ...<Widget>[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horário'),
              trailing: Text(config.horarioLegivel),
              onTap: () => _escolherHorario(context, ref, config),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Dias'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: <Widget>[
                      for (int dia = 1; dia <= 7; dia++)
                        FilterChip(
                          label: Text(_diasCurtos[dia]),
                          selected: config.dias.contains(dia),
                          onSelected: (_) => ref
                              .read(lembretesProvider.notifier)
                              .alternarDia(dia),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Testar agora'),
              subtitle: const Text('Chega em 5 segundos'),
              onTap: () async {
                await ref.read(lembretesProvider.notifier).testar();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feche o app para ver a notificação'),
                  ),
                );
              },
            ),
          ],

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              // HONESTIDADE. Entre Doze, otimizações de fabricante e
              // limites do iOS, a notificação é um LEMBRETE, não um
              // alarme. Prometer precisão é prometer o que o sistema
              // operacional não entrega.
              'O lembrete pode chegar alguns minutos depois do horário, '
              'dependendo das configurações de economia de bateria do '
              'seu aparelho.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _alternar(
    BuildContext context,
    WidgetRef ref,
    bool ligar,
  ) async {
    final ResultadoDePermissao resultado =
        await ref.read(lembretesProvider.notifier).alternar(ligar);

    if (!context.mounted || resultado.podeUsar) return;

    if (resultado == ResultadoDePermissao.negadaPermanentemente) {
      // Segunda negação no Android 13+: o sistema não mostra mais
      // o diálogo. O único caminho são os Ajustes.
      final bool? abrir = await showDialog<bool>(
        context: context,
        builder: (BuildContext c) => AlertDialog(
          title: const Text('Notificações desligadas'),
          content: const Text(
            'Para receber lembretes, ative as notificações do Foco '
            'nos ajustes do aparelho.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Agora não'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Abrir ajustes'),
            ),
          ],
        ),
      );

      if ((abrir ?? false) && context.mounted) {
        await ref.read(notificacoesProvider).abrirAjustes();
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sem permissão, não é possível enviar lembretes'),
      ),
    );
  }

  Future<void> _escolherHorario(
    BuildContext context,
    WidgetRef ref,
    ConfiguracaoDeLembrete config,
  ) async {
    final TimeOfDay? escolhido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: config.hora, minute: config.minuto),
    );

    if (escolhido == null || !context.mounted) return;

    await ref
        .read(lembretesProvider.notifier)
        .definirHorario(escolhido.hour, escolhido.minute);
  }
}
```

Rode em um **emulador Android** (notificação não funciona em `-d windows`):

```powershell
flutter pub add flutter_local_notifications timezone flutter_timezone permission_handler shared_preferences
flutter analyze
flutter run
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `tzdata.initializeTimeZones()` + `setLocalLocation` | Sem isto, o agendamento erra quando o usuário viaja ou o horário de verão muda. |
| `catch` no fuso, caindo para UTC | Fuso desconhecido acontece em ROMs alternativas. UTC é melhor que quebrar na abertura. |
| `requestAlertPermission: false` no iOS | O diálogo apareceria na **primeira abertura**, antes de o usuário entender o app. Recusa difícil de reverter. |
| `Canais` com `_v1` no id | O id **nunca muda**. Se um dia as configurações do canal precisarem mudar, cria-se o `_v2`. |
| Dois canais (lembretes e conquistas) | O usuário desliga um e mantém o outro. Com canal único, ele escolhe entre tudo e nada — e escolhe nada. |
| `IdsDeNotificacao` fixos | `zonedSchedule` com id já usado **substitui**. É assim que reagendamos sem duplicar. |
| `getNotificationAppLaunchDetails` no `iniciar` | App **fechado**: o callback não é chamado. Sem isto, tocar na notificação abre a tela inicial e parece bug. |
| `addPostFrameCallback` para navegar | No `main`, o `Navigator` ainda não existe. |
| `GlobalKey<NavigatorState>` | O callback da notificação não tem `BuildContext`. |
| `matchDateTimeComponents: DateTimeComponents.time` | **Uma** notificação recorrente. Agendar dia a dia estouraria o limite de **64 pendentes** do iOS, e as excedentes sumiriam em silêncio. |
| `AndroidScheduleMode.inexactAllowWhileIdle` | Fura o Doze **sem** exigir `SCHEDULE_EXACT_ALARM`, que o Google só aprova para despertadores e calendários. |
| `_proximaOcorrencia` com `if (!alvo.isAfter(agora))` | Sem isso, um lembrete das 19h configurado às 20h dispararia **imediatamente**. |
| `pedirPermissao()` chamado em `alternar(true)` | Pedido **no momento em que o usuário demonstra querer**. Muito mais aceito que na abertura. |
| Checagem de permissão no `_carregar` | O usuário pode ter desligado nos Ajustes depois de ligar no app. A tela precisa refletir a realidade. |
| `if (novos.isEmpty) alternar(false)` | Zero dias com o interruptor ligado seria mentir. |
| `todosOsDias` → um diário em vez de sete semanais | Menos pendentes, mais simples. |
| `RECEIVE_BOOT_COMPLETED` + `BootReceiver` | Sem eles, **todos** os lembretes somem depois de o aparelho reiniciar. |
| `UNUserNotificationCenter.current().delegate` no `AppDelegate` | Sem isso, no iOS a notificação é entregue **silenciosamente** com o app em primeiro plano. |
| O aviso final na tela | Honestidade: entre Doze e fabricantes, é um **lembrete**, não um alarme. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Permissão | `POST_NOTIFICATIONS` (13+) | Sempre pedida |
| Segunda negação | Não mostra mais o diálogo | Não mostra mais |
| Canais | ✅ obrigatórios (8+) | ❌ não existem |
| Limite de pendentes | Sem limite rígido | **64** |
| Precisão | Doze + fabricantes atrasam | Previsível |
| Alarme exato | `SCHEDULE_EXACT_ALARM`, restrita | Não aplicável |
| Sobrevive ao reboot | Só com `BOOT_COMPLETED` | ✅ automático |
| Com app em primeiro plano | Aparece | **Silenciosa**, sem o delegate |
| Ícone | Monocromático, transparente | O ícone do app |

> ⚠️ **As três linhas que mais geram bug:**
>
> **Limite de 64 (iOS)** — agendar "os próximos 60 dias" descarta metade, **sem erro**.
>
> **Reboot (Android)** — sem `RECEIVE_BOOT_COMPLETED` e o receiver no manifest, o usuário reinicia
> o celular e os lembretes somem para sempre.
>
> **Primeiro plano (iOS)** — sem a linha do delegate no `AppDelegate.swift`, quem está com o app
> aberto simplesmente não vê a notificação.

> 📌 **Fabricantes.** Xiaomi, Huawei, Oppo e Samsung têm otimizações de bateria além do Doze. Em
> alguns aparelhos, o usuário precisa colocar o app numa lista de exceções. Isso está **fora do seu
> controle** — o que você pode fazer é ser honesto no texto da tela, como faz o aviso final.

---

## ⚠️ Erros comuns

### 1. Pedir permissão na abertura do app

```dart
await Permission.notification.request();   // ❌ no main
```

O usuário não entende o pedido e recusa. No Android 13+, a segunda negação **encerra** a
possibilidade.

**Correção:** peça quando ele liga o lembrete.

### 2. Usar `DateTime` em vez de `TZDateTime`

```text
Invalid argument: Instance of 'DateTime'
```

**Correção:** `tz.TZDateTime(tz.local, ...)`.

### 3. Esquecer de inicializar o timezone

```text
LocationNotFoundException: No location with the name "America/Sao_Paulo"
```

**Correção:** `tzdata.initializeTimeZones()` antes de qualquer agendamento.

### 4. Agendar N notificações em vez de uma recorrente

```dart
for (int dia = 0; dia < 60; dia++) {
  await plugin.zonedSchedule(dia, ...);   // ⚠️ estoura o limite do iOS
}
```

**Correção:** `matchDateTimeComponents`.

### 5. Horário que já passou

```dart
tz.TZDateTime(tz.local, agora.year, agora.month, agora.day, 19, 0)
```

Configurado às 20h, dispara **na hora**.

**Correção:** `if (!alvo.isAfter(agora)) alvo = alvo.add(Duration(days: 1));`

### 6. Não tratar o app aberto pela notificação

O usuário toca, o app abre na tela inicial. Ele acha que está quebrado.

**Correção:** `getNotificationAppLaunchDetails` na inicialização.

### 7. Mudar o id do canal

```dart
'lembretes_v2'   // ⚠️ canal novo; as preferências do usuário ficam órfãs
```

**Correção:** o id nunca muda. Crie um canal novo só quando as **configurações** precisarem mudar
de verdade.

### 8. Esperar que mudar o canal tenha efeito

```dart
importance: Importance.max,   // ⚠️ o canal já existe com low
```

O Android **respeita a escolha do usuário**. Nada acontece.

**Correção:** canal novo, com id novo — e só se for realmente necessário.

### 9. Esquecer o `BOOT_COMPLETED`

Os lembretes somem depois de reiniciar o aparelho.

**Correção:** permissão **e** receiver no manifest.

### 10. Esquecer o delegate no `AppDelegate.swift`

No iOS, com o app aberto, a notificação é silenciosa.

**Correção:** `UNUserNotificationCenter.current().delegate = self`.

### 11. Pedir `SCHEDULE_EXACT_ALARM` sem precisar

Funciona no seu aparelho e é **rejeitada** na publicação.

**Correção:** `inexactAllowWhileIdle`.

### 12. Prometer horário exato

"Você será avisado às 19h em ponto" — e não será.

**Correção:** seja honesto no texto.

### 13. Não reagir à permissão revogada

O interruptor fica ligado, o usuário desligou nos Ajustes, e nada chega.

**Correção:** verifique a permissão ao carregar a tela.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo em um emulador Android 13+. Confirme o diálogo de permissão ao
tocar em **Agora**.

**Passo 2.** Agende **Em 10 s**, **feche o app** e espere. A notificação chegou? Toque nela e leia o
log.

**Passo 3.** Remova `getNotificationAppLaunchDetails` do `_verificarAberturaPorNotificacao`. Repita
o passo 2 e descreva o que muda para o usuário.

**Passo 4.** Configure o lembrete para um horário que **já passou hoje**. Ele dispara na hora?
Depois olhe `_proximaOcorrencia` e explique.

**Passo 5.** Agende o lembrete diário e toque em **Pendentes**. Quantas entradas? Depois troque
`matchDateTimeComponents` por um laço de 30 dias e repita a contagem.

**Passo 6.** Negue a permissão duas vezes. Tente ligar o lembrete de novo. O diálogo do sistema
aparece? Qual caminho o app oferece?

**Passo 7.** Ligue o lembrete no app, depois desligue as notificações nos **Ajustes do sistema**.
Volte ao app e observe o interruptor. Depois remova a checagem do `_carregar` e repita.

**Passo 8.** Mude o id do canal de `foco_lembretes_v1` para `_v2`. Vá aos Ajustes do sistema e
observe: quantos canais o app tem agora?

**Passo 9.** Remova o receiver do `AndroidManifest.xml`, agende um lembrete, reinicie o emulador
(`adb reboot`) e espere. O lembrete chegou?

**Passo 10.** Responda por escrito: o Foco precisa de push? Justifique com base na distinção da
primeira seção.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os exercícios de **Aplicação** com lembrete agendado, o de **Correção de bugs** com horário que
já passou, e o de **Decisão** sobre local × push.

---

## 🏆 Desafio opcional

Implemente **lembretes inteligentes**: em vez de horário fixo, o app aprende quando o usuário
costuma estudar.

Requisitos:

- O app registra o horário de início de cada sessão (já existe no banco — Módulo 10).
- Depois de 10 sessões, calcula a **faixa de horário** mais frequente.
- Sugere ao usuário: "Você costuma estudar por volta das 20h. Quer o lembrete nesse horário?"
- Se o usuário não estudou hoje até o horário habitual **+ 1 h**, envia o lembrete.
- Se já estudou hoje, **não** envia — nada irrita mais que ser lembrado do que já foi feito.
- Um ajuste permite voltar ao horário fixo.

Dica: o cancelamento condicional é o desafio real. Uma notificação agendada **não sabe** o que
aconteceu no app. Duas abordagens: (a) reagendar diariamente na abertura do app, checando se já
estudou; (b) agendar sempre e cancelar quando o usuário registra uma sessão.

Depois responda: qual das duas abordagens funciona se o usuário **não abrir o app** por três dias?
E o que isso diz sobre os limites de um app que só roda quando está aberto?

---

## 📌 Resumo

- **Local** = o app agenda no aparelho, funciona offline, sem backend. **Push** = servidor avisa,
  exige Firebase/APNs e backend.
- **`POST_NOTIFICATIONS`** é permissão de tempo de execução no **Android 13+**. Peça **quando o
  usuário liga o lembrete** — a segunda negação encerra a possibilidade.
- **Canais** (Android 8+): o `id` **nunca muda**, as configurações **não mudam** depois de criado, e
  separe por **propósito**.
- Use **`TZDateTime`** do pacote `timezone`, e inicialize com `initializeTimeZones()`.
- **`matchDateTimeComponents`** cria notificação **recorrente** — uma, não N. É o que evita estourar
  o limite de **64 pendentes** do iOS.
- Sempre calcule a **próxima ocorrência**: horário que já passou dispara na hora.
- **`inexactAllowWhileIdle`** fura o Doze sem exigir `SCHEDULE_EXACT_ALARM`, que o Google só aprova
  para despertadores e calendários.
- Trate o toque nos **dois casos**: `onDidReceiveNotificationResponse` (app vivo) e
  `getNotificationAppLaunchDetails` (app fechado).
- **Android:** sem `RECEIVE_BOOT_COMPLETED` + receiver, os lembretes somem no reboot.
- **iOS:** sem o delegate no `AppDelegate.swift`, a notificação é silenciosa com o app aberto.
- Verifique a permissão ao carregar a tela: o usuário pode tê-la revogado nos Ajustes.
- **Seja honesto:** entre Doze e otimizações de fabricante, é um **lembrete**, não um alarme.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre local e push, e por que push exige backend.
- [ ] Peço `POST_NOTIFICATIONS` no momento certo.
- [ ] Crio canais com id estável e separados por propósito.
- [ ] Inicializo o timezone e uso `TZDateTime`.
- [ ] Uso `matchDateTimeComponents` em vez de agendar N notificações.
- [ ] Conheço o limite de 64 pendentes do iOS.
- [ ] Calculo a próxima ocorrência para não disparar imediatamente.
- [ ] Uso `inexactAllowWhileIdle` e sei por que não peço alarme exato.
- [ ] Trato o toque com o app vivo **e** com o app fechado.
- [ ] Configurei o `BOOT_COMPLETED` no Android.
- [ ] Configurei o delegate no `AppDelegate.swift`.
- [ ] Verifico a permissão ao carregar a tela de ajustes.
- [ ] Não prometo horário exato ao usuário.

---

## 📚 Referências oficiais

- [flutter_local_notifications — pub.dev](https://pub.dev/packages/flutter_local_notifications)
- [timezone — pub.dev](https://pub.dev/packages/timezone)
- [flutter_timezone — pub.dev](https://pub.dev/packages/flutter_timezone)
- [Notification runtime permission — developer.android.com](https://developer.android.com/develop/ui/views/notifications/notification-permission)
- [Create a notification channel — developer.android.com](https://developer.android.com/develop/ui/views/notifications/channels)
- [Optimize for Doze — developer.android.com](https://developer.android.com/training/monitoring-device-state/doze-standby)
- [Schedule exact alarms — developer.android.com](https://developer.android.com/develop/background-work/services/alarms/schedule-alarms)
- [UserNotifications — developer.apple.com](https://developer.apple.com/documentation/usernotifications)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Arquivos e compartilhamento](03-arquivos-e-compartilhamento.md) | [README](README.md) | [Aula 5 — Conectividade](05-conectividade.md) |
