# Aula 5 — Permissões Android

> **Módulo:** 15 - Build e Distribuição Android · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Entender o **`AndroidManifest.xml`** e por que existem **três** deles.
- Declarar permissões com **`<uses-permission>`** e saber onde declarar cada uma.
- Distinguir permissões **normais** de **perigosas** — e o que muda na prática.
- Pedir permissão em tempo de execução com **`permission_handler`**, tratando os quatro estados.
- Lidar com o **"não perguntar de novo"** e mandar o usuário para as configurações.
- **Remover** permissões que um plugin acrescentou sem você pedir.
- Preencher a **Declaração de Permissões** exigida pela Play Console.

## ✅ Pré-requisitos

- [Aula 4 — Splash screen](04-splash-screen.md) — o projeto `foco` com identidade, ícone e splash
  prontos.
- [Aula 2 — Identidade do app](02-identidade-do-app.md) — `applicationId` `br.com.estudos.foco`.
- [Módulo 11, aula 7 — Pastas android/ e ios/](../11-recursos-nativos/07-pastas-android-e-ios.md) —
  onde ficam os arquivos nativos.
- [Módulo 11, aula 4 — Notificações](../11-recursos-nativos/04-notificacoes.md) — a permissão
  `POST_NOTIFICATIONS` apareceu lá.

---

## 📖 Conceito

### Os três manifests

```text
android/app/src/
├── debug/AndroidManifest.xml      ← só em `flutter run` (debug)
├── main/AndroidManifest.xml       ← ✅ SEMPRE. É onde você mexe.
└── profile/AndroidManifest.xml    ← só em `--profile`
```

| Manifest | Vale em | O que costuma ter |
|---|---|---|
| `main/` | **Todos** os modos | Suas permissões, activity, ícone, nome |
| `debug/` | Debug | `INTERNET` (para o hot reload) |
| `profile/` | Profile | Igual ao debug |

No build, o Gradle **funde** o `main` com o do modo atual e com os dos plugins. O resultado final é
o que vai para o aparelho.

> ⚠️ **A armadilha:** você acrescenta `INTERNET` no `debug/` por engano, tudo funciona em
> `flutter run`, e o app de release **não acessa a rede**. O sintoma é confuso porque o código está
> certo — só falta a permissão no manifest que importa. **Permissão de verdade vai em `main/`.**

E onde ver o manifest final, depois da fusão:

```text
build/app/intermediates/merged_manifests/release/AndroidManifest.xml
```

> 💡 **Leia esse arquivo antes de publicar.** É a única forma de saber o que os plugins
> acrescentaram por conta própria — e eles acrescentam.

### Normais × perigosas

| | Normal | **Perigosa** |
|---|---|---|
| Exemplo | `INTERNET`, `VIBRATE` | `CAMERA`, `LOCATION`, `RECORD_AUDIO` |
| Concedida | **Automaticamente**, na instalação | Só se o usuário aceitar o diálogo |
| Código extra | Nenhum | Pedir em tempo de execução |
| Pode ser negada | ❌ | ✅ |
| Aparece na loja | Não | ✅ Sim |

```xml
<!-- Normal: declarar basta. -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Perigosa: declarar É SÓ O COMEÇO. Precisa pedir em execução. -->
<uses-permission android:name="android.permission.CAMERA" />
```

> 📌 **Declarar uma permissão perigosa não concede nada.** Sem o pedido em tempo de execução, a
> chamada falha — normalmente com uma exceção da plataforma, não com uma mensagem clara. Este é o
> erro nº 1 de quem vem de versões antigas do Android.

As mais comuns:

| Permissão | Tipo | Desde |
|---|---|---|
| `INTERNET` | Normal | — |
| `ACCESS_NETWORK_STATE` | Normal | — |
| `VIBRATE` | Normal | — |
| `POST_NOTIFICATIONS` | **Perigosa** | **API 33 (Android 13)** |
| `CAMERA` | Perigosa | — |
| `ACCESS_FINE_LOCATION` | Perigosa | — |
| `READ_MEDIA_IMAGES` | Perigosa | API 33 |
| `READ_EXTERNAL_STORAGE` | Perigosa | ⚠️ Obsoleta na API 33+ |
| `SCHEDULE_EXACT_ALARM` | **Especial** | API 31 |

> ⚠️ **`POST_NOTIFICATIONS` pega muita gente de surpresa.** Até o Android 12, notificar não exigia
> permissão nenhuma. A partir do 13, exige — e é **perigosa**, com diálogo. Um app que funcionava
> perfeitamente passou a ficar mudo nos aparelhos novos, sem erro nenhum no log.

### Os quatro estados

```dart
final PermissionStatus s = await Permission.camera.request();
```

| Estado | Significa | O que fazer |
|---|---|---|
| `granted` | Concedida | Siga |
| `denied` | Negada (dá para pedir de novo) | Explique e peça outra vez |
| **`permanentlyDenied`** | "Não perguntar de novo" | ⚠️ **Só nas Configurações** |
| `restricted` | Bloqueada por política/controle parental | Nada a fazer |

> ⚠️ **`permanentlyDenied` é definitivo dentro do app.** Chamar `request()` de novo **não abre
> diálogo nenhum** — ele retorna negado na hora. Um app que insiste em pedir fica num laço mudo, e o
> usuário acha que o botão está quebrado. A única saída é `openAppSettings()`, **explicando** por
> que você está mandando a pessoa para lá.

No Android, o sistema marca como permanente depois de **duas** negações — ou de uma só, em algumas
versões.

### A hora de pedir

```text
❌ Ruim:   app abre → pede câmera, local, notificação, contatos
✅ Bom:    usuário toca em "tirar foto" → pede câmera
```

| | Pedir na abertura | Pedir no uso |
|---|---|---|
| Taxa de aceitação | ⚠️ Baixa | ✅ **Bem maior** |
| O usuário entende o porquê | ❌ | ✅ |
| Risco de negação permanente | Alto | Baixo |

> 💡 **Peça no momento em que o usuário quer o recurso**, e mostre uma explicação antes do diálogo
> do sistema se o motivo não for óbvio. O diálogo do sistema é seco e não dá contexto — a tela que
> você mostra antes é o que convence.

### Permissões que aparecem sozinhas

Plugins trazem as suas próprias permissões, e elas entram na fusão **sem você declarar nada**:

```xml
<!-- Você não escreveu isto. Um plugin escreveu. -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Para remover:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
        tools:node="remove" />
```

> 📌 **Permissão a mais é problema real**, não detalhe: ela aparece na ficha da loja, assusta
> usuário, e a Play Console pode exigir justificativa. Um app de estudos pedindo localização é
> motivo legítimo de desconfiança — e de desinstalação.

### `maxSdkVersion` e as permissões obsoletas

```xml
<!-- Até o Android 12: precisa. Do 13 em diante: substituída
     por READ_MEDIA_*, e declarar sem limite é pedir demais. -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### A Declaração de Permissões da Play Console

Algumas permissões exigem um formulário justificando o uso:

| Permissão | Exige declaração |
|---|---|
| `MANAGE_EXTERNAL_STORAGE` | ✅ Análise rigorosa |
| `QUERY_ALL_PACKAGES` | ✅ |
| `ACCESS_BACKGROUND_LOCATION` | ✅ Com vídeo demonstrativo |
| `SCHEDULE_EXACT_ALARM` | ✅ Justificativa |
| `READ_SMS`, `CALL_LOG` | ✅ Muito restrito |

> ⚠️ **Declaração reprovada = app não publicado.** E a análise pode levar dias. Se o seu app pode
> funcionar sem uma dessas, **funcione sem**. `MANAGE_EXTERNAL_STORAGE`, em particular, quase nunca
> é necessário: o *Storage Access Framework* resolve a maioria dos casos sem permissão nenhuma.

---

## 💡 Analogia

Pense num **prédio com portaria**.

- **O manifest** é a lista de acessos que você entrega na portaria ao se mudar: "preciso da garagem,
  do salão de festas e da academia". Sem estar na lista, o porteiro não deixa passar — mesmo que
  você tenha a chave.
- **Os três manifests** são três listas: uma para o dia a dia, uma para o dia da mudança, uma para
  a visita do técnico. Escrever "garagem" só na lista do dia da mudança e estranhar que o carro não
  entra na segunda-feira é o erro do `debug/`.
- **Permissão normal** é o acesso ao hall: consta na lista, e pronto. **Permissão perigosa** é o
  acesso ao apartamento de outra pessoa — estar na lista não basta; **o morador precisa autorizar,
  na hora**.
- **Pedir tudo na abertura** é tocar todas as campainhas do prédio no primeiro dia pedindo acesso a
  tudo. As pessoas negam por reflexo, e com razão: ninguém explicou por quê. **Tocar a campainha
  quando você precisa entregar algo** — e dizendo o que é — funciona muito melhor.
- **`permanentlyDenied`** é o morador que colocou o seu nome na lista negra da portaria. Tocar a
  campainha de novo não adianta: **ela nem toca lá dentro**. A única saída é pedir à pessoa que vá
  até a portaria e retire o seu nome — que é o `openAppSettings()`.
- **Permissão que um plugin acrescentou** é o encanador que pediu acesso ao seu nome à cobertura e
  esqueceu de cancelar. Quando alguém olha a sua lista de acessos, a pergunta é inevitável: *por
  que este morador precisa da cobertura?*

---

## 🧪 Exemplo mínimo

O manifest do `foco`, comentado.

> **Arquivo:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- ══════════════════════════════════════════════════════════
         PERMISSÕES NORMAIS
         Concedidas na instalação. Declarar basta.
         ══════════════════════════════════════════════════════════ -->

    <!-- Sincronizar as sessões com a API. -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- Saber se há conexão, para o modo offline. Módulo 11, aula 5. -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Vibrar ao terminar o tempo de estudo. -->
    <uses-permission android:name="android.permission.VIBRATE" />

    <!-- ══════════════════════════════════════════════════════════
         PERMISSÕES PERIGOSAS
         ⚠️ Declarar NÃO concede. É preciso pedir em execução.
         ══════════════════════════════════════════════════════════ -->

    <!-- Lembretes de estudo.
         ⚠️ Virou PERIGOSA na API 33 (Android 13). Até o 12, notificar
         não exigia permissão nenhuma — um app que funcionava passou
         a ficar mudo nos aparelhos novos, sem erro no log. -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- ══════════════════════════════════════════════════════════
         REMOVENDO O QUE OS PLUGINS TROUXERAM
         Um app de estudos NÃO precisa saber onde você está.
         Sem tools:node="remove", isto apareceria na ficha da loja.
         ══════════════════════════════════════════════════════════ -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
        tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"
        tools:node="remove" />
    <uses-permission android:name="android.permission.RECORD_AUDIO"
        tools:node="remove" />

    <!-- Obsoleta na API 33+: limite ao 32 em vez de pedir sempre. -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />

    <application
        android:label="Foco"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <!-- ══════════════════════════════════════════════════════════
         QUERIES (API 30+)
         Sem isto, `canLaunchUrl` devolve false mesmo com o app
         instalado — o Android esconde os outros apps por padrão.
         ══════════════════════════════════════════════════════════ -->
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
    </queries>
</manifest>
```

**Confira o resultado da fusão:**

```powershell
flutter build apk --release
Get-Content build/app/intermediates/merged_manifests/release/AndroidManifest.xml |
    Select-String "uses-permission"
```

> 📌 Se aparecer alguma permissão que você não reconhece, **investigue antes de publicar**. Foi um
> plugin, e ela vai aparecer na ficha da loja com o seu nome.

---

## 📱 Aplicando no Flutter

Agora o pedido em tempo de execução, com os quatro estados tratados.

---

## 💻 Código completo

```yaml
# pubspec.yaml
dependencies:
  permission_handler: ^12.0.1
```

> **Arquivo:** `lib/core/permissoes/gerenciador_permissoes.dart` (novo)

```dart
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Resultado de um pedido de permissão, em termos do APP.
///
/// O `PermissionStatus` do pacote tem oito valores e varia entre
/// plataformas. Este enum tem quatro, e cada um corresponde a uma
/// AÇÃO diferente da interface — que é o que a tela precisa saber.
enum ResultadoPermissao {
  /// Pode seguir.
  concedida,

  /// Negada, mas dá para pedir de novo.
  negada,

  /// "Não perguntar de novo": só nas Configurações.
  negadaParaSempre,

  /// Bloqueada por política ou controle parental. Nada a fazer.
  restrita,
}

/// Centraliza os pedidos de permissão.
///
/// Toda a lógica de plataforma e de versão do Android fica aqui —
/// a tela só pergunta "posso notificar?" e recebe uma das quatro
/// respostas.
class GerenciadorPermissoes {
  const GerenciadorPermissoes();

  /// Notificações.
  ///
  /// ⚠️ Só é permissão a partir do Android 13 (API 33). Em versões
  /// anteriores, o `permission_handler` devolve `granted` sem
  /// mostrar diálogo — o que é o comportamento correto.
  Future<ResultadoPermissao> pedirNotificacoes() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      // Desktop: não há permissão de notificação.
      return ResultadoPermissao.concedida;
    }
    return _pedir(Permission.notification);
  }

  /// Câmera — para a foto de capa da matéria.
  Future<ResultadoPermissao> pedirCamera() => _pedir(Permission.camera);

  /// Galeria.
  ///
  /// ⚠️ A permissão MUDOU de nome na API 33: READ_EXTERNAL_STORAGE
  /// virou READ_MEDIA_IMAGES. O `permission_handler` expõe as duas,
  /// e pedir a errada devolve negado sem explicação.
  Future<ResultadoPermissao> pedirGaleria() async {
    if (Platform.isAndroid) {
      // `photos` mapeia para READ_MEDIA_IMAGES no 13+ e para
      // READ_EXTERNAL_STORAGE abaixo disso.
      final ResultadoPermissao r = await _pedir(Permission.photos);
      if (r == ResultadoPermissao.concedida) return r;

      // Alguns aparelhos antigos ainda respondem por `storage`.
      return _pedir(Permission.storage);
    }
    return _pedir(Permission.photos);
  }

  /// Já está concedida? Consulta SEM mostrar diálogo.
  ///
  /// Use para decidir o que exibir na tela; nunca chame `request()`
  /// só para descobrir o estado — isso queima uma das negações.
  Future<bool> jaTem(Permission permissao) async {
    final PermissionStatus s = await permissao.status;
    return s.isGranted || s.isLimited;
  }

  /// Abre as Configurações do app.
  ///
  /// A ÚNICA saída quando o estado é `negadaParaSempre`.
  Future<bool> abrirConfiguracoes() => openAppSettings();

  Future<ResultadoPermissao> _pedir(Permission permissao) async {
    // 1. Consulta antes de pedir: se já está concedida, não há
    // por que mostrar diálogo nenhum.
    final PermissionStatus antes = await permissao.status;

    if (antes.isGranted || antes.isLimited) {
      return ResultadoPermissao.concedida;
    }

    // 2. Já foi negada para sempre? `request()` aqui NÃO abriria
    // diálogo — retornaria negado na hora, e o usuário acharia
    // que o botão está quebrado.
    if (antes.isPermanentlyDenied) {
      return ResultadoPermissao.negadaParaSempre;
    }

    if (antes.isRestricted) {
      return ResultadoPermissao.restrita;
    }

    // 3. Agora sim, o diálogo do sistema.
    final PermissionStatus depois = await permissao.request();

    if (depois.isGranted || depois.isLimited) {
      return ResultadoPermissao.concedida;
    }
    if (depois.isPermanentlyDenied) {
      return ResultadoPermissao.negadaParaSempre;
    }
    if (depois.isRestricted) {
      return ResultadoPermissao.restrita;
    }
    return ResultadoPermissao.negada;
  }
}
```

E a tela que usa isso, com a explicação **antes** do diálogo do sistema:

> **Arquivo:** `lib/core/permissoes/pedido_de_permissao.dart` (novo)

```dart
import 'package:flutter/material.dart';

import 'gerenciador_permissoes.dart';

/// Fluxo completo de pedido de permissão, com explicação.
///
/// O diálogo do sistema é seco e não dá contexto. A tela que você
/// mostra ANTES é o que convence — e é a diferença entre 30 % e
/// 80 % de aceitação.
abstract final class PedidoDePermissao {
  /// Pede notificações, explicando antes e tratando os 4 estados.
  ///
  /// Devolve `true` se o app pode notificar.
  static Future<bool> notificacoes(BuildContext context) async {
    const GerenciadorPermissoes g = GerenciadorPermissoes();

    // ── 1. A explicação, ANTES do diálogo do sistema ────────────
    final bool? quer = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog.adaptive(
        icon: const Icon(Icons.notifications_outlined),
        title: const Text('Lembretes de estudo'),
        content: const Text(
          'O Foco pode avisar você no horário que combinar, para '
          'ajudar a manter a sequência de dias estudados.\n\n'
          'Você pode desligar quando quiser nas configurações.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ativar lembretes'),
          ),
        ],
      ),
    );

    // ⭐ Se o usuário disse "agora não" AQUI, nem chegamos a pedir
    // ao sistema — e a permissão continua disponível para o futuro.
    // Pedir assim mesmo queimaria uma das negações à toa.
    if (quer != true) return false;

    // ── 2. O diálogo do sistema ─────────────────────────────────
    final ResultadoPermissao r = await g.pedirNotificacoes();

    if (!context.mounted) return false;

    // ── 3. Cada estado, uma ação diferente ──────────────────────
    switch (r) {
      case ResultadoPermissao.concedida:
        return true;

      case ResultadoPermissao.negada:
        // Dá para pedir de novo depois. Não insista agora.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sem problema. Você pode ativar os lembretes depois, '
              'em Ajustes.',
            ),
          ),
        );
        return false;

      case ResultadoPermissao.negadaParaSempre:
        // ⚠️ Pedir de novo NÃO abriria diálogo nenhum.
        // A única saída são as Configurações.
        await _mandarParaConfiguracoes(context, g);
        return false;

      case ResultadoPermissao.restrita:
        // Controle parental ou política corporativa: o usuário
        // não consegue conceder nem indo nas Configurações.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'As notificações estão bloqueadas por uma configuração '
              'do aparelho.',
            ),
          ),
        );
        return false;
    }
  }

  static Future<void> _mandarParaConfiguracoes(
    BuildContext context,
    GerenciadorPermissoes g,
  ) async {
    final bool? ir = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog.adaptive(
        title: const Text('Permissão desativada'),
        // Explique O QUE fazer lá dentro: mandar o usuário para
        // uma tela de configurações sem instrução é abandoná-lo.
        content: const Text(
          'Para receber lembretes, ative as notificações do Foco '
          'nas configurações do aparelho:\n\n'
          'Notificações → Permitir notificações',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Depois'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Abrir configurações'),
          ),
        ],
      ),
    );

    if (ir == true) {
      await g.abrirConfiguracoes();
    }
  }
}
```

E o widget que mostra o estado atual, revalidando ao voltar:

> **Arquivo:** `lib/features/ajustes/presentation/linha_notificacoes.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/permissoes/gerenciador_permissoes.dart';
import '../../../core/permissoes/pedido_de_permissao.dart';

/// Linha de ajuste das notificações.
///
/// O detalhe que importa: revalidar quando o app volta do
/// segundo plano. O usuário pode ter mudado a permissão nas
/// Configurações, e o app precisa perceber.
class LinhaNotificacoes extends StatefulWidget {
  const LinhaNotificacoes({super.key});

  @override
  State<LinhaNotificacoes> createState() => _LinhaNotificacoesState();
}

class _LinhaNotificacoesState extends State<LinhaNotificacoes>
    with WidgetsBindingObserver {
  bool _ativas = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _conferir();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // ⭐ O usuário foi às Configurações, ativou a permissão e
    // voltou. Sem esta revalidação, a tela continuaria mostrando
    // "desativado" até ele reabrir o app. Módulo 11, aula 6.
    if (estado == AppLifecycleState.resumed) {
      _conferir();
    }
  }

  Future<void> _conferir() async {
    const GerenciadorPermissoes g = GerenciadorPermissoes();
    final bool tem = await g.jaTem(Permission.notification);

    if (!mounted) return;
    setState(() {
      _ativas = tem;
      _carregando = false;
    });
  }

  Future<void> _alternar(bool ligar) async {
    if (!ligar) {
      // Não dá para REVOGAR permissão pelo código — só o usuário
      // pode, nas Configurações.
      const GerenciadorPermissoes().abrirConfiguracoes();
      return;
    }

    final bool ok = await PedidoDePermissao.notificacoes(context);
    if (!mounted) return;
    setState(() => _ativas = ok);
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const ListTile(
        leading: Icon(Icons.notifications_outlined),
        title: Text('Lembretes de estudo'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return SwitchListTile.adaptive(
      secondary: Icon(
        _ativas
            ? Icons.notifications_active_outlined
            : Icons.notifications_off_outlined,
      ),
      title: const Text('Lembretes de estudo'),
      subtitle: Text(
        _ativas
            ? 'Você recebe lembretes no horário combinado'
            : 'Toque para ativar',
      ),
      value: _ativas,
      onChanged: _alternar,
    );
  }
}
```

```powershell
flutter pub add permission_handler
flutter run
# e, para conferir o manifest final:
flutter build apk --release
Get-Content build/app/intermediates/merged_manifests/release/AndroidManifest.xml |
    Select-String "uses-permission"
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Permissões em `main/`, não em `debug/` | `debug/` vale só em `flutter run`; o release ficaria sem. |
| Comentário em cada `<uses-permission>` | Daqui a seis meses, ninguém lembra por que `VIBRATE` está lá. |
| `tools:node="remove"` na localização | Um app de estudos pedindo local assusta — e aparece na ficha da loja. |
| `maxSdkVersion="32"` | A permissão é obsoleta na API 33; sem o limite, você pede demais. |
| `<queries>` | Sem isso, `canLaunchUrl` devolve `false` mesmo com o app instalado (API 30+). |
| `enum ResultadoPermissao` com 4 valores | O `PermissionStatus` tem oito e varia por plataforma; a tela precisa de **ações**, não de estados. |
| Consultar `.status` **antes** de `request()` | Se já está concedida, não há por que abrir diálogo. |
| Checar `isPermanentlyDenied` antes | `request()` aí **não abre diálogo** — retorna negado na hora. |
| `Permission.photos` no Android | Mapeia para `READ_MEDIA_IMAGES` no 13+ e `READ_EXTERNAL_STORAGE` abaixo. |
| Diálogo de explicação **antes** do sistema | O diálogo do sistema é seco; a explicação é o que convence. |
| `if (quer != true) return false;` | "Agora não" **não queima** uma negação — a permissão fica disponível. |
| `switch` sobre os quatro estados | Cada um exige uma ação diferente; tratar só `granted` é o erro comum. |
| Instrução do caminho nas Configurações | Mandar o usuário para lá sem dizer o que fazer é abandoná-lo. |
| `didChangeAppLifecycleState` → `resumed` | O usuário mudou a permissão fora do app; sem revalidar, a tela mente. |
| `_alternar(false)` abrindo configurações | **Não dá para revogar permissão pelo código** — só o usuário pode. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Onde declarar | `AndroidManifest.xml` | `Info.plist` |
| Formato | `<uses-permission>` | `NS*UsageDescription` |
| Texto do motivo | ❌ Não existe | ✅ **Obrigatório** |
| Sem o texto | — | **O app é rejeitado** |
| Pedir de novo | Até virar permanente | ⚠️ **Uma vez só** |
| Notificações | Permissão desde a API 33 | Sempre foi |
| Ver as concedidas | Config → Apps → Permissões | Config → o app |

```xml
<!-- ios/Runner/Info.plist -->
<!-- ⚠️ O texto aparece NO DIÁLOGO e é lido pelo revisor da Apple.
     Genérico demais ("o app precisa da câmera") é motivo de
     rejeição. Diga PARA QUÊ. -->
<key>NSCameraUsageDescription</key>
<string>Para você tirar uma foto da capa da matéria.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Para escolher uma imagem de capa para a matéria.</string>
```

> ⚠️ **No iOS, o diálogo aparece UMA vez.** Negou, acabou: qualquer novo pedido é ignorado
> silenciosamente, e a única saída são as Configurações. Isso torna a explicação prévia ainda mais
> importante lá do que no Android — você tem uma única chance.

🪟 **No Windows**, você configura os dois lados (o `Info.plist` é texto), mas só testa o fluxo
Android. O diálogo do iOS só aparece rodando em aparelho ou simulador iOS.

---

## ⚠️ Erros comuns

### 1. Permissão no `debug/AndroidManifest.xml`

Funciona em `flutter run`, falha em release.

**Correção:** `main/`.

### 2. Declarar perigosa e não pedir em execução

A chamada falha com exceção de plataforma.

**Correção:** `request()` antes de usar.

### 3. Não tratar `permanentlyDenied`

O app pede num laço mudo; o usuário acha que quebrou.

**Correção:** `openAppSettings()` com explicação.

### 4. Pedir tudo na abertura

Taxa de negação alta.

**Correção:** peça no momento do uso.

### 5. Esquecer `POST_NOTIFICATIONS`

O app fica mudo no Android 13+, sem erro no log.

**Correção:** declare e peça.

### 6. `READ_EXTERNAL_STORAGE` sem `maxSdkVersion`

Pede permissão obsoleta.

**Correção:** limite ao 32 e use `READ_MEDIA_*`.

### 7. Não conferir o manifest fundido

Plugins acrescentam permissões que aparecem na loja.

**Correção:** leia o `merged_manifests` antes de publicar.

### 8. `Info.plist` com texto genérico

Rejeição na App Store.

**Correção:** diga para quê, em uma frase.

### 9. Chamar `request()` só para consultar

Queima uma negação.

**Correção:** `.status` para consultar.

### 10. Não revalidar ao voltar do segundo plano

A tela mente sobre o estado.

**Correção:** `didChangeAppLifecycleState`.

### 11. Tentar revogar pelo código

Não existe.

**Correção:** abra as Configurações.

### 12. Pedir `MANAGE_EXTERNAL_STORAGE` sem necessidade

Declaração reprovada, app não publicado.

**Correção:** Storage Access Framework.

---

## 🛠️ Exercício guiado

**Passo 1.** Abra `android/app/src/main/AndroidManifest.xml` e liste as permissões atuais.

**Passo 2.** Rode `flutter build apk --release` e leia o manifest fundido. Apareceu algo novo?

**Passo 3.** Instale um plugin de câmera, refaça o build e compare. O que ele trouxe?

**Passo 4.** Remova uma delas com `tools:node="remove"` e confirme na fusão.

**Passo 5.** Declare `POST_NOTIFICATIONS` e crie o `GerenciadorPermissoes`.

**Passo 6.** Peça a permissão num Android 13+. Negue. O que o `request()` devolve?

**Passo 7.** Negue de novo. O estado virou `permanentlyDenied`?

**Passo 8.** Chame `request()` nesse estado. Algum diálogo aparece?

**Passo 9.** Vá às Configurações, ative, e volte ao app **sem** reabri-lo. A linha atualizou?

**Passo 10.** Remova o `didChangeAppLifecycleState` e repita o passo 9.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-android.md](../../exercicios/15-build-android.md)

Faça os de **Aplicação** (fluxo completo de permissão), **Correção de bugs** (permissão no manifest
errado) e **Diagnóstico** (app mudo no Android 13).

---

## 🏆 Desafio opcional

Monte uma **tela de diagnóstico de permissões** dentro do app.

Requisitos:

- Lista todas as permissões que o app declara, com o estado atual de cada uma.
- Botão para pedir, e para abrir as Configurações quando for permanente.
- Mostra a versão do Android e indica quais permissões **não se aplicam** àquela versão.
- Revalida automaticamente ao voltar do segundo plano.
- Um botão que copia o diagnóstico para a área de transferência — para o usuário colar num pedido
  de suporte.
- Visível só em builds de debug (`kDebugMode`).

Depois responda: por que uma tela dessas ajuda mais o **suporte** que o usuário? E que informação
você **não** deve incluir nela, mesmo sendo útil para diagnosticar? (Dica: releia a aula 6 do
módulo 13.)

---

## 📌 Resumo

- São **três manifests**; suas permissões vão no **`main/`** — o `debug/` não vale em release.
- Leia o **manifest fundido** (`build/app/intermediates/merged_manifests/`) antes de publicar.
- **Normais** são concedidas na instalação; **perigosas** exigem pedido em tempo de execução.
- **Declarar uma perigosa não concede nada.**
- **`POST_NOTIFICATIONS` é perigosa desde o Android 13** — apps antigos ficaram mudos por causa
  disso.
- Quatro estados: `granted`, `denied`, **`permanentlyDenied`**, `restricted`.
- Em `permanentlyDenied`, **`request()` não abre diálogo**: só `openAppSettings()`.
- **Peça no momento do uso**, com uma explicação antes do diálogo do sistema.
- "Agora não" na sua tela **não queima** uma negação do sistema.
- Consulte com **`.status`**; nunca use `request()` só para descobrir o estado.
- **Plugins acrescentam permissões**: remova com `tools:node="remove"`.
- `READ_EXTERNAL_STORAGE` com **`maxSdkVersion="32"`**; use `READ_MEDIA_*` no 13+.
- **Revalide ao voltar do segundo plano** — o usuário pode ter mudado tudo nas Configurações.
- **Não dá para revogar permissão pelo código.**
- 🍎 No iOS, o texto do motivo é **obrigatório**, e o diálogo aparece **uma vez só**.
- `MANAGE_EXTERNAL_STORAGE` e afins exigem **declaração na Play Console** — evite.

---

## ☑️ Checklist de domínio

- [ ] Sei em qual dos três manifests declarar cada coisa.
- [ ] Leio o manifest fundido antes de publicar.
- [ ] Distingo permissão normal de perigosa.
- [ ] Peço permissões perigosas em tempo de execução.
- [ ] Trato os quatro estados, não só `granted`.
- [ ] Sei o que fazer com `permanentlyDenied`.
- [ ] Explico o motivo antes do diálogo do sistema.
- [ ] Peço no momento do uso, não na abertura.
- [ ] Removo permissões que plugins trouxeram.
- [ ] Uso `maxSdkVersion` em permissões obsoletas.
- [ ] Revalido ao voltar do segundo plano.
- [ ] 🍎 Escrevi textos específicos no `Info.plist`.

---

## 📚 Referências oficiais

- [App manifest overview — developer.android.com](https://developer.android.com/guide/topics/manifest/manifest-intro)
- [Permissions on Android — developer.android.com](https://developer.android.com/guide/topics/permissions/overview)
- [Request runtime permissions — developer.android.com](https://developer.android.com/training/permissions/requesting)
- [Notification runtime permission — developer.android.com](https://developer.android.com/develop/ui/views/notifications/notification-permission)
- [Merge multiple manifest files — developer.android.com](https://developer.android.com/build/manage-manifests)
- [Declare permissions — Play Console Help](https://support.google.com/googleplay/android-developer/answer/9214102)
- [permission_handler — pub.dev](https://pub.dev/packages/permission_handler)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Splash screen](04-splash-screen.md) | [README](README.md) | [Keystore](06-keystore.md) |
