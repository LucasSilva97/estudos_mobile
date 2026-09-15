# Aula 8 — Autenticação e tokens

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Diferenciar **autenticação** de **autorização** e usar os termos corretamente.
- Enviar credenciais com o cabeçalho **`Authorization: Bearer <token>`**.
- Listar os lugares onde um token **nunca** deve ser guardado — e por quê.
- Guardar o token com **`flutter_secure_storage`**, usando Keychain 🍎 e Keystore 🤖.
- Tratar **`401`** renovando o token, e **`403`** sem tentar renovar.
- Implementar **renovação automática** (*refresh*) sem disparar dez requisições ao mesmo tempo.
- Manter segredos fora do Git com **`.gitignore`** e **`--dart-define`**.
- Reconhecer o que **não** se protege no aplicativo cliente.

## ✅ Pré-requisitos

- [Aula 4 — Modelando respostas e erros](04-modelando-respostas-e-erros.md) — `ApiException` e o
  `sealed class Falha`.
- [Aula 7 — Camada de dados testável](07-camada-de-dados-testavel.md) — **essencial**: o
  interceptador de token vive no service.
- [Módulo 00, aula 5 — Desfazendo erros e segredos](../00-git-e-terminal/05-desfazendo-erros-e-segredos.md)
  — `.gitignore` e o que nunca versionar.
- [Módulo 08, aula 10 — Injeção de dependências](../08-estado-e-arquitetura/10-injecao-de-dependencias.md).

---

## 📖 Conceito

### Autenticação × autorização

Dois conceitos que as pessoas misturam — e que correspondem a **códigos HTTP diferentes**:

| | **Autenticação** | **Autorização** |
|---|---|---|
| Pergunta | "Quem é você?" | "Você pode fazer isso?" |
| Falha com | **`401 Unauthorized`** | **`403 Forbidden`** |
| Causa típica | Sem token, token inválido ou expirado | Token válido, mas sem permissão |
| O app deve | Renovar o token ou pedir login | **Não** renovar; mostrar "sem permissão" |

> ⚠️ O nome do `401` é enganoso: ele diz *Unauthorized*, mas significa **não autenticado**. Tratar
> `403` como `401` faz o app tentar renovar o token em loop — e o token está perfeitamente bom; o
> usuário é que não tem permissão.

### `Authorization: Bearer`

O padrão para enviar um token:

```dart
final http.Response r = await cliente.get(
  url,
  headers: <String, String>{
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  },
);
```

`Bearer` significa "portador": quem tiver este token **é** o usuário, para todos os efeitos. Por
isso ele precisa ser tratado como senha — e nunca aparecer em log, URL ou mensagem de erro.

Existem outros esquemas (`Basic`, `Digest`, chaves de API em cabeçalho próprio), mas `Bearer` é o
que você vai encontrar em quase toda API moderna.

> ⚠️ **Nunca coloque o token na URL:**
> `GET /trilhas?token=abc123` aparece no histórico do navegador, nos logs do servidor, nos logs do
> proxy e no cabeçalho `Referer` enviado a terceiros. Token vai em **cabeçalho**, sempre.

### Onde **não** guardar um token

| Lugar | Por quê não |
|---|---|
| Uma variável comum | Some ao fechar o app |
| **`SharedPreferences`** | Texto puro. Em Android com root ou iOS com jailbreak, é lido direto |
| Um arquivo no diretório do app | Idem |
| **No código-fonte** | Vai para o Git, e qualquer um que veja o repositório tem a chave |
| SQLite sem criptografia | Idem ao `SharedPreferences` |
| Log (`debugPrint`) | Logs vazam — e em release podem ser capturados por outras ferramentas |

> ⚠️ **`SharedPreferences` não é seguro.** Ele guarda em XML (Android) ou `.plist` (iOS), em texto
> puro. Serve perfeitamente para preferências — tema, última aba, rascunho — e **nunca** para
> token, senha ou dado pessoal sensível. O
> [Módulo 10, aula 7](../10-persistencia-de-dados/07-dados-sensiveis.md) trata disso a fundo.

### Onde guardar: `flutter_secure_storage`

```dart
final FlutterSecureStorage cofre = const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

await cofre.write(key: 'token', value: token);
final String? token = await cofre.read(key: 'token');
await cofre.delete(key: 'token');
```

O que ele usa por baixo:

| Plataforma | Mecanismo |
|---|---|
| 🤖 Android | **Keystore** — chave protegida por hardware, quando disponível |
| 🍎 iOS | **Keychain** — o mesmo cofre das senhas do sistema |
| 🖥️ Windows/Linux/Web | Menos robusto; **não** confie para dados críticos |

Duas opções que importam:

- **`encryptedSharedPreferences: true`** (Android): usa `EncryptedSharedPreferences` em vez do
  armazenamento legado. Sem isso, versões antigas do plugin usavam um esquema mais fraco.
- **`KeychainAccessibility.first_unlock`** (iOS): o token só é legível **depois** do primeiro
  desbloqueio do aparelho após ligar. O padrão (`unlocked`) impediria leitura em segundo plano.

> 📌 `first_unlock` — e não `always` — é a escolha certa. `always` mantém o dado legível mesmo com
> o aparelho bloqueado, o que enfraquece a proteção sem ganho real para um app de estudos.

### O ciclo de vida de um token

A maioria das APIs usa dois tokens:

| Token | Validade | Para quê |
|---|---|---|
| **Access token** | Curta (5 min a 1 h) | Enviado em **toda** requisição |
| **Refresh token** | Longa (dias a meses) | Só para obter um access token novo |

O fluxo:

```text
1. Login          → recebe access (1 h) + refresh (30 dias)
2. Requisições    → manda o access em cada uma
3. Access expira  → a API devolve 401
4. Renovação      → manda o refresh, recebe um access novo
5. Repete a requisição original
6. Refresh expira → pede login de novo
```

Por que dois tokens: o access viaja em **toda** requisição e tem mais chance de vazar — então ele
expira rápido. O refresh viaja **raramente** e fica guardado no cofre.

### Renovar sem disparar dez renovações

Este é o problema técnico central da aula. A tela abre e dispara cinco requisições em paralelo. O
token expirou. **As cinco** recebem `401` e **as cinco** tentam renovar:

```text
❌ sem coordenação
req A → 401 → renova → token1
req B → 401 → renova → token2   (invalida o token1!)
req C → 401 → renova → token3   (invalida o token2!)
…
```

Além do desperdício, muitas APIs **invalidam o refresh anterior** ao emitir um novo — e as
requisições que usaram os tokens intermediários falham.

A solução: **uma renovação por vez**, com as outras esperando o mesmo `Future`.

```dart
Future<String>? _renovacaoEmAndamento;

Future<String> _obterTokenValido() {
  // Já há uma renovação acontecendo? Espere A MESMA.
  final Future<String>? emAndamento = _renovacaoEmAndamento;
  if (emAndamento != null) return emAndamento;

  final Future<String> nova = _renovarDeVerdade();
  _renovacaoEmAndamento = nova;

  // Limpa quando terminar, dê certo ou não.
  nova.whenComplete(() => _renovacaoEmAndamento = null);

  return nova;
}
```

Cinco requisições chamam `_obterTokenValido()`; a primeira inicia a renovação, as outras quatro
recebem **o mesmo `Future`** e esperam. Uma renovação, cinco requisições atendidas.

### Segredos fora do Git

Três níveis, do pior para o melhor:

**1. Chave no código** — ❌ nunca.

```dart
const String chaveApi = 'sk_live_abc123';   // ❌ está no Git para sempre
```

Mesmo apagando depois, ela continua no **histórico**. A única correção é **revogar a chave**.

**2. Arquivo ignorado pelo Git** — aceitável para desenvolvimento.

```text
# .gitignore
.env
**/segredos.dart
*.keystore
*.jks
ios/Runner/GoogleService-Info.plist
android/app/google-services.json
```

**3. `--dart-define`** — a forma recomendada:

```powershell
flutter run --dart-define=URL_BASE=https://api.exemplo.com --dart-define=CHAVE_API=abc123
```

```dart
const String urlBase = String.fromEnvironment(
  'URL_BASE',
  defaultValue: 'https://jsonplaceholder.typicode.com',
);
```

`String.fromEnvironment` é resolvido **em tempo de compilação**: o valor entra no binário e nada
fica no repositório.

Para não digitar tudo toda vez, use um arquivo de definições:

```json
// dart_defines/dev.json  (este arquivo VAI para o .gitignore)
{
  "URL_BASE": "https://api-dev.exemplo.com",
  "CHAVE_API": "chave_de_desenvolvimento"
}
```

```powershell
flutter run --dart-define-from-file=dart_defines/dev.json
```

### O que você **não** consegue proteger no cliente

Este é o ponto que separa segurança real de teatro:

> **Qualquer coisa que está no aplicativo instalado pode ser extraída.**

Um APK pode ser descompilado. Um IPA pode ser inspecionado. A ofuscação
([Módulo 14](../14-build-android/README.md)) atrasa, mas não impede.

| Ideia | Funciona? |
|---|---|
| Esconder a chave da API no código ofuscado | ❌ Atrasa alguns minutos |
| Guardar a chave em `flutter_secure_storage` | ❌ Ela precisa **chegar** lá de algum jeito |
| Validar a senha no app | ❌ Basta editar o binário |
| Cobrar assinatura só com checagem local | ❌ Trivial de burlar |
| Token de curta validade + validação no servidor | ✅ |
| Chave de API que fica **só no servidor** | ✅ |

**A regra:** se um segredo não pode vazar, ele não pode estar no aplicativo. Chaves de terceiros
(pagamento, e-mail, serviços pagos) ficam no **seu backend**, e o app fala com o seu backend.

> 📌 Uma chave "pública" de API (como a do Google Maps) é diferente: ela é feita para estar no
> cliente, e a proteção é **restrição por domínio/pacote** no painel do serviço, não segredo.

---

## 💡 Analogia

Pense em um hotel.

- **Autenticação** é o balcão conferir o seu documento: **quem é você**. Falhou? `401` — você nem
  entra.
- **Autorização** é o cartão abrir a porta do seu quarto e **não** abrir a academia, porque a sua
  diária não inclui. Falhou? `403` — você está identificado, mas aquela porta não é sua. Trocar o
  cartão não adianta; é por isso que `403` **não** dispara renovação.
- **O access token** é o **cartão magnético**: expira ao fim da estadia, funciona em muitas portas,
  e você anda com ele o tempo todo — por isso ele é o que tem mais chance de ser perdido.
- **O refresh token** é o seu **documento guardado no cofre do quarto**. Você quase nunca o tira de
  lá; ele serve só para pedir um cartão novo no balcão quando o antigo para de funcionar.
- **`flutter_secure_storage`** é esse cofre. **`SharedPreferences`** é a gaveta da mesa de cabeceira
  — cabe o controle da TV, não o passaporte.
- **Cinco renovações simultâneas** é a sua família inteira indo ao balcão ao mesmo tempo pedir um
  cartão novo para o mesmo quarto. O recepcionista emite cinco, e **cada emissão cancela a
  anterior** — então quatro pessoas ficam com cartão morto. A solução é uma pessoa ir, e as outras
  esperarem.
- **Segredo no app instalado** é escrever a senha do cofre **atrás do quadro do quarto**. Você pode
  colar com fita, pintar por cima, pôr atrás de um móvel — mas o hóspede tem acesso ao quarto
  inteiro. Se algo não pode ser descoberto, ele não fica no quarto: fica no cofre da **gerência**
  (o seu servidor).

---

## 🧪 Exemplo mínimo

Login, token guardado, requisição autenticada e renovação coordenada.

> **Arquivo:** `foco_api/lib/main.dart` (temporário)
> **Instale antes:** `flutter pub add flutter_secure_storage`
> **Como executar:** `flutter run -d chrome`

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(const AppAuth());

/// Cofre de credenciais.
///
/// Android: Keystore (chave protegida por hardware quando disponível).
/// iOS: Keychain (o mesmo cofre das senhas do sistema).
///
/// NUNCA use SharedPreferences para isto: ele guarda em texto puro.
const FlutterSecureStorage _cofre = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  // first_unlock: legível só depois do primeiro desbloqueio após ligar.
  // "always" manteria legível com o aparelho bloqueado — mais fraco,
  // sem ganho real.
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

/// Simula o servidor de autenticação.
class ServidorFalso {
  int _emissoes = 0;

  /// Quantas vezes o refresh foi realmente chamado.
  /// É este número que prova se a coordenação funciona.
  int renovacoes = 0;

  Future<({String access, String refresh})> login(
    String usuario,
    String senha,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (senha != '1234') throw Exception('Credenciais inválidas');
    _emissoes++;
    return (access: 'access_$_emissoes', refresh: 'refresh_$_emissoes');
  }

  Future<String> renovar(String refresh) async {
    renovacoes++;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!refresh.startsWith('refresh_')) {
      throw Exception('Refresh inválido');
    }
    _emissoes++;
    return 'access_$_emissoes';
  }
}

class Sessao {
  Sessao(this._servidor);

  final ServidorFalso _servidor;

  /// Renovação em andamento, para coordenar chamadas simultâneas.
  Future<String>? _renovacaoEmAndamento;

  Future<void> entrar(String usuario, String senha) async {
    final ({String access, String refresh}) t =
        await _servidor.login(usuario, senha);
    await _cofre.write(key: 'access', value: t.access);
    await _cofre.write(key: 'refresh', value: t.refresh);
  }

  Future<void> sair() async {
    // deleteAll é mais seguro que apagar chave por chave:
    // não sobra nada esquecido.
    await _cofre.deleteAll();
  }

  Future<String?> get accessAtual => _cofre.read(key: 'access');

  /// Renova o access token — no máximo UMA vez por vez.
  ///
  /// Cinco requisições que recebem 401 ao mesmo tempo chamam este método.
  /// A primeira inicia a renovação; as outras quatro recebem O MESMO
  /// Future e esperam. Sem isto, seriam cinco renovações — e muitas APIs
  /// invalidam o refresh anterior a cada emissão, quebrando as outras.
  Future<String> renovar() {
    final Future<String>? emAndamento = _renovacaoEmAndamento;
    if (emAndamento != null) {
      debugPrint('  ↩️ renovação já em andamento: aguardando a mesma');
      return emAndamento;
    }

    final Future<String> nova = _renovarDeVerdade();
    _renovacaoEmAndamento = nova;

    // Limpa quando terminar, dê certo ou não. Sem isto, uma renovação
    // que falhou bloquearia todas as futuras.
    nova.whenComplete(() => _renovacaoEmAndamento = null);

    return nova;
  }

  Future<String> _renovarDeVerdade() async {
    debugPrint('  🔄 renovando de verdade…');
    final String? refresh = await _cofre.read(key: 'refresh');
    if (refresh == null) throw Exception('Sessão expirada');

    final String novoAccess = await _servidor.renovar(refresh);
    await _cofre.write(key: 'access', value: novoAccess);
    return novoAccess;
  }
}

class AppAuth extends StatelessWidget {
  const AppAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const TelaAuth(),
    );
  }
}

class TelaAuth extends StatefulWidget {
  const TelaAuth({super.key});

  @override
  State<TelaAuth> createState() => _TelaAuthState();
}

class _TelaAuthState extends State<TelaAuth> {
  final ServidorFalso _servidor = ServidorFalso();
  late final Sessao _sessao = Sessao(_servidor);

  final List<String> _log = <String>[];

  void _registrar(String linha) {
    debugPrint(linha);
    if (mounted) setState(() => _log.insert(0, linha));
  }

  Future<void> _entrar() async {
    try {
      await _sessao.entrar('aluno', '1234');
      final String? t = await _sessao.accessAtual;
      // Em log de verdade, NUNCA imprima o token inteiro.
      // Aqui é didático; em produção, use só os 4 primeiros caracteres.
      _registrar('✅ entrou · access = $t');
    } on Object catch (e) {
      _registrar('❌ $e');
    }
  }

  /// Cinco requisições que recebem 401 ao mesmo tempo.
  Future<void> _cincoSimultaneas() async {
    _registrar('— 5 requisições simultâneas com token expirado —');
    final int antes = _servidor.renovacoes;

    await Future.wait<void>(<Future<void>>[
      for (int i = 1; i <= 5; i++) _requisicaoComRenovacao(i),
    ]);

    final int feitas = _servidor.renovacoes - antes;
    _registrar(feitas == 1
        ? '✅ apenas 1 renovação para as 5 requisições'
        : '⚠️ $feitas renovações — coordenação falhou');
  }

  Future<void> _requisicaoComRenovacao(int n) async {
    _registrar('req $n → 401 (token expirado)');
    try {
      final String novo = await _sessao.renovar();
      _registrar('req $n → refeita com $novo');
    } on Object catch (e) {
      _registrar('req $n → falhou: $e');
    }
  }

  Future<void> _sair() async {
    await _sessao.sair();
    _registrar('🚪 saiu · cofre limpo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Token e renovação')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(onPressed: _entrar, child: const Text('Entrar')),
                FilledButton.tonal(
                  onPressed: _cincoSimultaneas,
                  child: const Text('5 requisições + 401'),
                ),
                OutlinedButton(onPressed: _sair, child: const Text('Sair')),
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

1. **Entrar** → o access e o refresh vão para o cofre.
2. **5 requisições + 401** → observe o log: quatro linhas dizem "renovação já em andamento", e o
   resultado é **1 renovação para 5 requisições**.
3. Comente a coordenação (`if (emAndamento != null) return emAndamento;`) e repita: agora são
   **5 renovações**, e numa API real quatro delas invalidariam as outras.
4. **Sair** → `deleteAll()` limpa tudo.

---

## 📱 Aplicando no Flutter

O `foco_api` ganha:

- `core/seguranca/cofre_token.dart` — o cofre, com o contrato para testes;
- `core/config/ambiente.dart` — configuração via `--dart-define`;
- `core/seguranca/sessao_controller.dart` — estado da sessão com renovação coordenada;
- um **interceptador** de token no service, que acrescenta o cabeçalho e trata `401`.

> 📌 A JSONPlaceholder não exige autenticação. O código abaixo é escrito para uma API real e roda
> contra ela sem quebrar — os cabeçalhos são simplesmente ignorados. Quando você trocar a URL base
> por uma API autenticada, funciona.

---

## 💻 Código completo

> **Arquivo:** `foco_api/lib/core/config/ambiente.dart` (novo)
> **Como executar:** `flutter run --dart-define-from-file=dart_defines/dev.json`

```dart
/// Configuração vinda de fora do código.
///
/// String.fromEnvironment é resolvido em TEMPO DE COMPILAÇÃO: o valor
/// entra no binário e nada fica no repositório.
///
/// Rode com:
///   flutter run --dart-define=URL_BASE=https://api.exemplo.com
/// ou, melhor:
///   flutter run --dart-define-from-file=dart_defines/dev.json
abstract final class Ambiente {
  static const String urlBase = String.fromEnvironment(
    'URL_BASE',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  static const String urlAuth = String.fromEnvironment(
    'URL_AUTH',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  /// ⚠️ Mesmo vindo de --dart-define, uma chave EMBUTIDA NO APP pode ser
  /// extraída de um APK ou IPA. Chaves que não podem vazar (pagamento,
  /// e-mail, serviços pagos) ficam no SEU BACKEND — o app fala com ele.
  ///
  /// Isto aqui serve só para chaves "públicas", cuja proteção é
  /// restrição por domínio/pacote no painel do serviço.
  static const String chavePublica = String.fromEnvironment('CHAVE_PUBLICA');

  static const bool ehProducao =
      bool.fromEnvironment('PRODUCAO', defaultValue: false);

  /// Falha cedo e com mensagem clara se faltar configuração obrigatória.
  static void validar() {
    if (ehProducao && urlBase.contains('jsonplaceholder')) {
      throw StateError(
        'URL_BASE não foi definida para produção. '
        'Use --dart-define-from-file=dart_defines/prod.json',
      );
    }
  }
}
```

> **Arquivo:** `foco_api/.gitignore` (acrescente)

```text
# ── Segredos ─────────────────────────────────────────────────────────────
# Arquivos de configuração com chaves reais.
dart_defines/*.json
!dart_defines/exemplo.json

.env
.env.*

# Assinatura Android (Módulo 14)
*.jks
*.keystore
android/key.properties

# Configuração de serviços
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# Perfis de provisionamento iOS (Módulo 15)
*.mobileprovision
*.p12
```

> **Arquivo:** `foco_api/dart_defines/exemplo.json` (este **vai** para o Git)

```json
{
  "URL_BASE": "https://api-dev.exemplo.com",
  "URL_AUTH": "https://auth-dev.exemplo.com",
  "CHAVE_PUBLICA": "COLOQUE_A_SUA_AQUI",
  "PRODUCAO": false
}
```

> **Arquivo:** `foco_api/lib/core/seguranca/cofre_token.dart` (novo)
> **Instale antes:** `flutter pub add flutter_secure_storage`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contrato do cofre.
///
/// Existe para os testes poderem usar uma implementação em memória —
/// o `flutter_secure_storage` precisa de plataforma nativa e não roda
/// em `flutter test` puro.
abstract interface class CofreToken {
  Future<String?> lerAccess();
  Future<String?> lerRefresh();
  Future<void> salvar({required String access, required String refresh});
  Future<void> salvarAccess(String access);
  Future<void> limpar();
}

/// Implementação real: Keychain 🍎 / Keystore 🤖.
class CofreTokenSeguro implements CofreToken {
  const CofreTokenSeguro(this._storage);

  final FlutterSecureStorage _storage;

  static const String _chaveAccess = 'foco_access_token';
  static const String _chaveRefresh = 'foco_refresh_token';

  @override
  Future<String?> lerAccess() => _storage.read(key: _chaveAccess);

  @override
  Future<String?> lerRefresh() => _storage.read(key: _chaveRefresh);

  @override
  Future<void> salvar({required String access, required String refresh}) async {
    await _storage.write(key: _chaveAccess, value: access);
    await _storage.write(key: _chaveRefresh, value: refresh);
  }

  @override
  Future<void> salvarAccess(String access) =>
      _storage.write(key: _chaveAccess, value: access);

  @override
  Future<void> limpar() async {
    // deleteAll em vez de apagar chave por chave: não sobra nada
    // esquecido de uma versão anterior do app.
    await _storage.deleteAll();
  }
}

final Provider<CofreToken> cofreTokenProvider = Provider<CofreToken>((Ref ref) {
  return const CofreTokenSeguro(
    FlutterSecureStorage(
      // encryptedSharedPreferences: usa EncryptedSharedPreferences
      // em vez do armazenamento legado, mais fraco.
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      // first_unlock: legível só depois do primeiro desbloqueio
      // após o aparelho ligar. "always" seria mais fraco sem ganho.
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );
});
```

> **Arquivo:** `foco_api/lib/core/seguranca/sessao_controller.dart` (novo)

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:foco_api/core/config/ambiente.dart';
import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/core/http/cliente_http.dart';
import 'package:foco_api/core/seguranca/cofre_token.dart';

/// Estado da sessão.
sealed class EstadoSessao {
  const EstadoSessao();
}

final class Verificando extends EstadoSessao {
  const Verificando();
}

final class Autenticado extends EstadoSessao {
  const Autenticado(this.usuario);
  final String usuario;
}

final class NaoAutenticado extends EstadoSessao {
  const NaoAutenticado({this.motivo});

  /// Preenchido quando a sessão caiu sozinha (refresh expirado).
  final String? motivo;
}

final NotifierProvider<SessaoController, EstadoSessao> sessaoProvider =
    NotifierProvider<SessaoController, EstadoSessao>(SessaoController.new);

class SessaoController extends Notifier<EstadoSessao> {
  /// Renovação em andamento.
  ///
  /// Cinco requisições que recebem 401 ao mesmo tempo esperam ESTE
  /// Future, em vez de dispararem cinco renovações. Muitas APIs
  /// invalidam o refresh anterior a cada emissão: sem coordenação,
  /// quatro das cinco falhariam.
  Future<String>? _renovacaoEmAndamento;

  CofreToken get _cofre => ref.read(cofreTokenProvider);
  http.Client get _cliente => ref.read(clienteHttpProvider);

  @override
  EstadoSessao build() {
    // Verifica o cofre logo ao iniciar, sem bloquear o build.
    Future<void>.microtask(_verificarSessaoSalva);
    return const Verificando();
  }

  Future<void> _verificarSessaoSalva() async {
    final String? access = await _cofre.lerAccess();
    state = access == null
        ? const NaoAutenticado()
        : const Autenticado('aluno');
  }

  // ── Entrar e sair ─────────────────────────────────────────────────────────

  Future<String?> entrar(String usuario, String senha) async {
    try {
      final http.Response r = await _cliente
          .post(
            Uri.parse('${Ambiente.urlAuth}/login'),
            headers: const <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
            },
            // A senha vai no CORPO, nunca na URL: URLs entram em log
            // de servidor, de proxy e no histórico.
            body: jsonEncode(<String, String>{
              'usuario': usuario,
              'senha': senha,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (r.statusCode == 401) {
        return 'Usuário ou senha incorretos';
      }
      if (r.statusCode != 200 && r.statusCode != 201) {
        return 'Não conseguimos entrar agora. Tente de novo.';
      }

      final Map<String, Object?> corpo =
          jsonDecode(r.body) as Map<String, Object?>;

      await _cofre.salvar(
        access: corpo['access_token']! as String,
        refresh: corpo['refresh_token']! as String,
      );

      state = Autenticado(usuario);
      return null;
    } on Object catch (erro) {
      // NUNCA registre a senha nem o token no log.
      debugPrint('Falha no login: ${erro.runtimeType}');
      return 'Não conseguimos entrar agora. Verifique sua conexão.';
    }
  }

  Future<void> sair({String? motivo}) async {
    await _cofre.limpar();
    _renovacaoEmAndamento = null;
    state = NaoAutenticado(motivo: motivo);
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  Future<String?> tokenAtual() => _cofre.lerAccess();

  /// Renova o access token. **No máximo uma renovação por vez.**
  Future<String> renovar() {
    final Future<String>? emAndamento = _renovacaoEmAndamento;
    if (emAndamento != null) return emAndamento;

    final Future<String> nova = _renovarDeVerdade();
    _renovacaoEmAndamento = nova;

    // whenComplete roda mesmo se falhar. Sem isto, uma renovação
    // que deu erro bloquearia todas as futuras.
    nova.whenComplete(() => _renovacaoEmAndamento = null);

    return nova;
  }

  Future<String> _renovarDeVerdade() async {
    final String? refresh = await _cofre.lerRefresh();
    if (refresh == null) {
      await sair(motivo: 'Sua sessão expirou. Entre de novo.');
      throw const FalhaDeAutenticacao();
    }

    try {
      final http.Response r = await _cliente
          .post(
            Uri.parse('${Ambiente.urlAuth}/refresh'),
            headers: const <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(<String, String>{'refresh_token': refresh}),
          )
          .timeout(const Duration(seconds: 20));

      if (r.statusCode != 200) {
        // O refresh também expirou: não há como continuar sem login.
        await sair(motivo: 'Sua sessão expirou. Entre de novo.');
        throw const FalhaDeAutenticacao();
      }

      final Map<String, Object?> corpo =
          jsonDecode(r.body) as Map<String, Object?>;
      final String novoAccess = corpo['access_token']! as String;
      await _cofre.salvarAccess(novoAccess);
      return novoAccess;
    } on FalhaDeAutenticacao {
      rethrow;
    } on Object catch (erro, pilha) {
      debugPrint('Falha ao renovar: ${erro.runtimeType}');
      Error.throwWithStackTrace(const FalhaDeConexao(), pilha);
    }
  }
}
```

> **Arquivo:** `foco_api/lib/core/http/cliente_autenticado.dart` (novo)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:foco_api/core/erros/api_exception.dart';
import 'package:foco_api/core/http/cliente_http.dart';
import 'package:foco_api/core/seguranca/sessao_controller.dart';

/// Cliente que acrescenta o token e trata 401 automaticamente.
///
/// Estende BaseClient e sobrescreve send(): TODAS as requisições
/// (get, post, put, delete) passam por aqui. Não há como esquecer
/// o cabeçalho em um método.
class ClienteAutenticado extends http.BaseClient {
  ClienteAutenticado({
    required http.Client interno,
    required Future<String?> Function() obterToken,
    required Future<String> Function() renovar,
    required Future<void> Function() aoExpirar,
  })  : _interno = interno,
        _obterToken = obterToken,
        _renovar = renovar,
        _aoExpirar = aoExpirar;

  final http.Client _interno;
  final Future<String?> Function() _obterToken;
  final Future<String> Function() _renovar;
  final Future<void> Function() _aoExpirar;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest requisicao) async {
    final String? token = await _obterToken();

    http.StreamedResponse resposta =
        await _interno.send(_comToken(requisicao, token));

    // 401 = NÃO AUTENTICADO: o token expirou ou é inválido.
    // Vale renovar e tentar de novo.
    if (resposta.statusCode == 401) {
      try {
        final String novoToken = await _renovar();
        // A requisição original já foi consumida: é preciso copiá-la.
        resposta = await _interno.send(_comToken(_copiar(requisicao), novoToken));
      } on Object {
        await _aoExpirar();
        rethrow;
      }
    }

    // 403 = NÃO AUTORIZADO: o token está bom, mas falta permissão.
    // Renovar NÃO resolveria — só gastaria uma requisição e poderia
    // entrar em loop.
    if (resposta.statusCode == 403) {
      throw const ApiException(403, 'Sem permissão para esta ação');
    }

    return resposta;
  }

  http.BaseRequest _comToken(http.BaseRequest r, String? token) {
    if (token == null) return r;
    // Bearer: quem porta o token É o usuário. Trate-o como senha.
    r.headers['Authorization'] = 'Bearer $token';
    return r;
  }

  /// Uma BaseRequest só pode ser enviada uma vez: o corpo é um stream
  /// já consumido. Para repetir, é preciso recriar.
  http.BaseRequest _copiar(http.BaseRequest original) {
    if (original is http.Request) {
      return http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..bodyBytes = original.bodyBytes
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;
    }
    // Uploads (MultipartRequest) não são repetidos automaticamente:
    // o stream do arquivo já foi lido.
    throw StateError(
      'Não é possível repetir automaticamente ${original.runtimeType}. '
      'Trate o 401 na camada que iniciou o upload.',
    );
  }

  @override
  void close() => _interno.close();
}

/// O cliente que as features usam.
///
/// Note que ele NÃO fecha o cliente interno: quem o criou (o
/// clienteHttpProvider) é quem o fecha.
final Provider<http.Client> clienteAutenticadoProvider =
    Provider<http.Client>((Ref ref) {
  final SessaoController sessao = ref.watch(sessaoProvider.notifier);

  return ClienteAutenticado(
    interno: ref.watch(clienteHttpProvider),
    obterToken: sessao.tokenAtual,
    renovar: sessao.renovar,
    aoExpirar: () => sessao.sair(motivo: 'Sua sessão expirou.'),
  );
});
```

E a feature passa a usar o cliente autenticado:

```dart
// features/trilhas/data/trilha_repositorio.dart
final Provider<TrilhaRepositorioContrato> trilhaRepositorioProvider =
    Provider<TrilhaRepositorioContrato>((Ref ref) {
  return TrilhaRepositorio(
    // Trocou clienteHttpProvider por clienteAutenticadoProvider.
    // Nenhuma outra linha da feature muda.
    TrilhaApi(cliente: ref.watch(clienteAutenticadoProvider)),
  );
});
```

Rode:

```powershell
flutter pub add flutter_secure_storage
flutter analyze
flutter run --dart-define-from-file=dart_defines/dev.json
```

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Armazenamento seguro | Keystore + `EncryptedSharedPreferences` | Keychain |
| Sobrevive a desinstalar o app | ❌ Apagado | ⚠️ **Pode sobreviver** |
| Backup automático | Pode ir para o Google Backup | Pode ir para o backup do iCloud |
| `minSdkVersion` exigido | 23 (Android 6) | iOS 12+ |
| Chave em hardware | Quando o aparelho tem TEE/StrongBox | Secure Enclave |
| Biometria como trava | `BiometricPrompt` | Face ID / Touch ID |

> ⚠️ **O item mais surpreendente é o segundo.** No iOS, itens do Keychain **podem persistir** depois
> de o app ser desinstalado e reinstalado — o usuário reinstala e continua logado com um token que
> ele achava apagado. Se isso não for desejado, marque a primeira execução (em
> `SharedPreferences`, que **é** apagado) e limpe o Keychain quando ela não existir.

Para excluir os tokens do backup no Android:

```xml
<!-- android/app/src/main/res/xml/backup_rules.xml -->
<full-backup-content>
  <exclude domain="sharedpref" path="FlutterSecureStorage" />
</full-backup-content>
```

---

## ⚠️ Erros comuns

### 1. Token em `SharedPreferences`

```dart
await prefs.setString('token', token);   // ❌ texto puro
```

**Correção:** `flutter_secure_storage`.

### 2. Token na URL

```dart
Uri.parse('$base/trilhas?token=$token')   // ❌
```

Aparece no histórico, nos logs do servidor, do proxy, e no `Referer`.

**Correção:** cabeçalho `Authorization`.

### 3. Token no log

```dart
debugPrint('token: $token');   // ❌
```

**Correção:** não registre. Se precisar depurar, use os 4 primeiros caracteres:
`token.substring(0, 4)`.

### 4. Tratar `403` como `401`

```dart
if (r.statusCode == 401 || r.statusCode == 403) await renovar();   // ❌
```

O token está bom; falta **permissão**. Renovar não resolve e pode virar loop.

**Correção:** `401` renova; `403` mostra "sem permissão".

### 5. Renovações simultâneas

```dart
if (r.statusCode == 401) {
  final String novo = await _renovarDeVerdade();   // ❌ sem coordenação
}
```

Cinco requisições, cinco renovações. Numa API que invalida o refresh anterior, quatro falham.

**Correção:** guarde o `Future` da renovação em andamento.

### 6. Não limpar o `_renovacaoEmAndamento` no erro

```dart
_renovacaoEmAndamento = nova;
nova.then((_) => _renovacaoEmAndamento = null);   // ⚠️ só no sucesso
```

Uma renovação que falhou **bloqueia todas as futuras** para sempre.

**Correção:** `whenComplete`, que roda nos dois casos.

### 7. Chave de API no código

```dart
const String chave = 'sk_live_abc123';   // ❌
```

Está no Git **para sempre**, mesmo depois de apagada.

**Correção:** `--dart-define`. E se já foi commitada: **revogue a chave**. Apagar do histórico não
basta — assuma que ela vazou.

### 8. Achar que `--dart-define` protege a chave

```dart
static const String chaveSecreta = String.fromEnvironment('SECRETA');   // ⚠️
```

Ela **está no binário**. Um APK descompilado a entrega.

**Correção:** segredo que não pode vazar fica no **backend**.

### 9. Repetir uma `BaseRequest` já enviada

```text
StateError: Can't finalize a finalized Request.
```

O corpo é um stream já consumido.

**Correção:** recrie a requisição, como faz o `_copiar`.

### 10. Não tratar o refresh expirado

O app fica tentando renovar em loop, com o usuário preso numa tela travada.

**Correção:** refresh falhou → limpe o cofre e vá para a tela de login com mensagem clara.

### 11. Validar senha no cliente

```dart
if (senha == senhaGuardadaLocalmente) entrar();   // ❌
```

Trivial de burlar editando o binário.

**Correção:** validação **sempre** no servidor.

### 12. Esquecer de limpar no logout

```dart
await cofre.delete(key: 'access');   // ⚠️ e o refresh?
```

**Correção:** `deleteAll()`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode o exemplo mínimo e execute o roteiro de quatro passos. Confirme **1 renovação
para 5 requisições**.

**Passo 2.** Comente a linha `if (emAndamento != null) return emAndamento;`. Repita o teste e conte
as renovações. Explique por escrito o que aconteceria numa API que invalida o refresh anterior.

**Passo 3.** Troque `whenComplete` por `then`. Faça a renovação falhar (mude o refresh salvo para
um valor inválido) e tente renovar de novo. O que acontece?

**Passo 4.** No `ClienteAutenticado`, remova o tratamento do `403`. Simule um `403` e observe o
comportamento.

**Passo 5.** Crie `dart_defines/dev.json` com uma `URL_BASE` diferente. Rode com
`--dart-define-from-file` e confirme que o app usa a URL nova.

**Passo 6.** Confirme que `dart_defines/*.json` está no `.gitignore`. Rode `git status` e verifique
que o arquivo **não** aparece.

**Passo 7.** Acrescente `debugPrint('token: $token')` ao `ClienteAutenticado`. Rode e olhe o
console. Depois remova — e explique por escrito por que essa linha nunca pode ir para produção.

**Passo 8.** Escreva um `CofreTokenFalso` (em memória) e um teste que confirme: `sair()` limpa
access **e** refresh.

**Passo 9.** Escreva um teste que confirme que cinco chamadas simultâneas a `renovar()` resultam em
**uma** chamada ao servidor. Use um contador no falso.

**Passo 10.** Responda por escrito: você está integrando um serviço de e-mail que cobra por envio,
com uma chave secreta. Onde ela deve ficar? Por quê?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Faça os exercícios de **Aplicação** com `flutter_secure_storage`, o de **Correção de bugs** com
renovação simultânea, e o de **Decisão** sobre onde guardar cada tipo de segredo.

---

## 🏆 Desafio opcional

Implemente **renovação preventiva**: em vez de esperar o `401`, renove o token **antes** de ele
expirar.

Requisitos:

- O token é um JWT; decodifique o campo `exp` (sem verificar assinatura — isso é papel do servidor)
  para saber quando expira.
- Se faltarem menos de 60 segundos, renove **antes** de enviar a requisição.
- A coordenação de renovação única continua valendo.
- O tratamento de `401` permanece, como rede de segurança (o relógio do aparelho pode estar errado).
- Um provider `tempoRestanteDoTokenProvider` mostra os segundos restantes numa tela de diagnóstico.

Dica: um JWT é `header.payload.signature` em Base64URL. `payload` decodificado é um JSON com `exp`
em segundos desde 1970. Use `base64Url.normalize()` antes de decodificar — o padding costuma estar
ausente.

Depois responda: por que **não** basta a renovação preventiva, e o tratamento de `401` precisa
continuar existindo? (Dica: pense no relógio do aparelho e em um token revogado pelo servidor.)

---

## 📌 Resumo

- **Autenticação** = "quem é você" → `401`. **Autorização** = "você pode?" → `403`. Renove no
  `401`; **nunca** no `403`.
- Token vai em **`Authorization: Bearer <token>`**, nunca na URL, nunca em log.
- **`SharedPreferences` não é seguro**: texto puro. Use **`flutter_secure_storage`** (Keystore 🤖 /
  Keychain 🍎).
- Configure `encryptedSharedPreferences: true` (Android) e
  `KeychainAccessibility.first_unlock` (iOS).
- **No iOS, itens do Keychain podem sobreviver à desinstalação.** Marque a primeira execução e limpe
  se necessário.
- **Access token** é curto e viaja sempre; **refresh token** é longo e viaja raramente.
- **Uma renovação por vez:** guarde o `Future` em andamento e faça as outras requisições esperarem
  o mesmo. Limpe com **`whenComplete`**, não `then`.
- Refresh expirado → limpe o cofre e peça login, com mensagem clara. Nunca entre em loop.
- Estenda **`http.BaseClient`** e sobrescreva `send()`: todos os métodos passam por lá, e não há
  como esquecer o cabeçalho.
- Uma `BaseRequest` já enviada **não pode ser repetida** — recrie antes de reenviar.
- Segredos fora do Git: **`.gitignore`** + **`--dart-define-from-file`**. Chave já commitada deve
  ser **revogada**.
- **Qualquer coisa dentro do app instalado pode ser extraída.** Segredo que não pode vazar fica no
  **backend**.
- Validação de senha e de permissão é **sempre** no servidor.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre `401` e `403` e ajo diferente em cada um.
- [ ] Envio o token em `Authorization: Bearer`, nunca na URL.
- [ ] Nunca registro token ou senha em log.
- [ ] Guardo tokens em `flutter_secure_storage` com as opções corretas.
- [ ] Sei por que `SharedPreferences` não serve para token.
- [ ] Sei que o Keychain pode sobreviver à desinstalação no iOS.
- [ ] Coordeno a renovação para acontecer **uma vez** por vez.
- [ ] Uso `whenComplete` para limpar a renovação em andamento.
- [ ] Trato refresh expirado com logout e mensagem clara.
- [ ] Uso `BaseClient.send()` para o token valer em todos os métodos.
- [ ] Sei recriar uma requisição para repeti-la.
- [ ] Mantenho segredos fora do Git com `.gitignore` e `--dart-define`.
- [ ] Sei o que **não** dá para proteger no cliente.
- [ ] `flutter analyze` termina com `No issues found!`.

---

## 📚 Referências oficiais

- [flutter_secure_storage — pub.dev](https://pub.dev/packages/flutter_secure_storage)
- [Authorization header — MDN](https://developer.mozilla.org/docs/Web/HTTP/Headers/Authorization)
- [401 Unauthorized — MDN](https://developer.mozilla.org/docs/Web/HTTP/Status/401)
- [403 Forbidden — MDN](https://developer.mozilla.org/docs/Web/HTTP/Status/403)
- [Build modes and dart-define — docs.flutter.dev](https://docs.flutter.dev/deployment/flavors)
- [Android Keystore — developer.android.com](https://developer.android.com/privacy-and-security/keystore)
- [Keychain Services — developer.apple.com](https://developer.apple.com/documentation/security/keychain_services)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — Camada de dados testável](07-camada-de-dados-testavel.md) | [README](README.md) | [Aula 9 — API com Riverpod](09-api-com-riverpod.md) |
