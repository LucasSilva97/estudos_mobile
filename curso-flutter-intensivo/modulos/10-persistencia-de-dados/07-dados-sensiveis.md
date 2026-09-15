# Aula 7 — Dados sensíveis

> **Módulo:** 10 - Persistência de Dados · **Tempo estimado:** 40 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Classificar um dado como **sensível** ou não, com critério — e não por intuição.
- Usar **`flutter_secure_storage`**: `read`, `write`, `delete`, `deleteAll`, `readAll`.
- Configurar **`AndroidOptions`** e **`IOSOptions`** corretamente, e saber o que cada opção muda.
- Explicar por que o **Keychain do iOS sobrevive à desinstalação** — e como contornar.
- Reconhecer os **limites reais** do armazenamento seguro em cada plataforma.
- Excluir dados sensíveis do **backup automático** em Android e iOS.
- Saber o que **nunca** fazer: criptografia caseira, chave no código, dado em log.
- Testar código que usa cofre, sem plataforma nativa.

## ✅ Pré-requisitos

- [Aula 1 — Qual armazenamento usar](01-qual-armazenamento-usar.md) — a árvore de decisão.
- [Aula 2 — shared_preferences](02-shared-preferences.md) — **essencial**: entender que ele guarda
  em texto puro é o que motiva esta aula.
- [Módulo 09, aula 8 — Autenticação e tokens](../09-consumo-de-api/08-autenticacao-e-tokens.md) —
  o cofre apareceu lá para tokens; aqui ele é o assunto.
- [Módulo 00, aula 5 — Desfazendo erros e segredos](../00-git-e-terminal/05-desfazendo-erros-e-segredos.md).

---

## 📖 Conceito

### O que é "dado sensível"

A pergunta não é "isso é importante?" — é:

> **"Se isto vazar, o que acontece com o usuário?"**

| Consequência do vazamento | Classificação | Onde guardar |
|---|---|---|
| Alguém acessa a conta dele | **Crítico** | Cofre (`flutter_secure_storage`) |
| Alguém descobre algo íntimo sobre ele | **Sensível** | Cofre, ou banco criptografado |
| Alguém sabe a preferência de tema dele | Não sensível | `SharedPreferences` |
| Nada | Não sensível | Onde for conveniente |

Aplicado ao mundo real:

| Dado | Sensível? | Onde |
|---|---|---|
| Token de acesso / refresh | ✅ **Crítico** | Cofre |
| Senha do usuário | ✅ Crítico — **e nem deve ser guardada** | Em lugar nenhum |
| PIN / senha do app | ✅ Crítico — guarde o **hash**, não o valor | Cofre |
| Chave de criptografia do banco | ✅ Crítico | Cofre |
| CPF, RG, cartão | ✅ Sensível | Cofre, ou só no servidor |
| Dados de saúde, orientação, religião | ✅ Sensível (LGPD: dado **pessoal sensível**) | Cofre ou banco criptografado |
| E-mail, nome | ⚠️ Pessoal, não sensível | `SharedPreferences` é aceitável |
| Histórico de estudo do Foco | ❌ | SQLite |
| Tema, última aba, rascunho | ❌ | `SharedPreferences` |

> 📌 **A LGPD tem uma categoria específica.** "Dado pessoal sensível" é definido no artigo 5º, II:
> origem racial ou étnica, convicção religiosa, opinião política, filiação a sindicato,
> **dado referente à saúde ou à vida sexual**, dado genético ou biométrico. Esses exigem cuidado
> extra — e, muitas vezes, a melhor decisão é **não guardar no aparelho**.

E a regra que economiza mais trabalho que qualquer criptografia:

> **O dado mais seguro é o que você não guarda.** Antes de proteger algo, pergunte se o app
> realmente precisa daquilo no aparelho.

### Por que `SharedPreferences` não serve

```dart
await prefs.setString('token', 'eyJhbGciOiJIUzI1NiJ9...');
```

Onde isso vai parar:

| Plataforma | Arquivo | Formato |
|---|---|---|
| 🤖 Android | `/data/data/<pacote>/shared_prefs/FlutterSharedPreferences.xml` | **XML em texto puro** |
| 🍎 iOS | `Library/Preferences/<bundle>.plist` | **plist, legível** |

Em um aparelho com root (Android) ou jailbreak (iOS), abrir esse arquivo é trivial. E há um caminho
mais comum ainda: o arquivo vai para o **backup automático** — Google Backup ou iCloud — e de lá
para outro aparelho.

O `sqflite` tem o mesmo problema: um `.db` é um arquivo comum, legível por qualquer ferramenta de
SQLite.

### `flutter_secure_storage`

```dart
const FlutterSecureStorage cofre = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

await cofre.write(key: 'token', value: token);
final String? token = await cofre.read(key: 'token');
final Map<String, String> tudo = await cofre.readAll();
await cofre.delete(key: 'token');
await cofre.deleteAll();
```

O que ele usa por baixo:

| Plataforma | Mecanismo | Proteção |
|---|---|---|
| 🤖 Android | **Keystore** + `EncryptedSharedPreferences` | Chave em hardware (TEE/StrongBox) quando disponível |
| 🍎 iOS | **Keychain** | Enclave seguro; o mesmo cofre das senhas do sistema |
| 🖥️ Windows | DPAPI | Ligada à conta do Windows |
| 🐧 Linux | libsecret | Depende do ambiente instalado |
| 🌐 Web | `localStorage` "criptografado" | ⚠️ **Não é seguro**: a chave está no JavaScript |

> ⚠️ **Na web, `flutter_secure_storage` não protege nada de verdade.** A chave de criptografia
> precisa estar no código JavaScript, que o usuário pode ler. Se o seu app roda na web, dados
> críticos ficam **só no servidor**, em sessão com cookie `HttpOnly`.

### As opções que importam

**Android:**

```dart
const AndroidOptions(
  // Usa EncryptedSharedPreferences em vez do armazenamento legado.
  // Sem isto, versões antigas do plugin usavam um esquema mais fraco.
  encryptedSharedPreferences: true,
);
```

**iOS:**

```dart
const IOSOptions(
  accessibility: KeychainAccessibility.first_unlock,
  // Impede o item de ir para o backup do iCloud e para outros aparelhos.
  synchronizable: false,
);
```

Os níveis de `accessibility` do iOS, do mais frouxo ao mais restrito:

| Valor | Legível quando | Vai para backup? |
|---|---|---|
| `passcode` | Só com o aparelho desbloqueado **e** senha configurada | ❌ nunca |
| `unlocked` | Aparelho desbloqueado | ✅ |
| `unlocked_this_device` | Desbloqueado, **só neste aparelho** | ❌ |
| `first_unlock` | Depois do 1º desbloqueio após ligar | ✅ |
| `first_unlock_this_device` | Idem, só neste aparelho | ❌ |

**Qual escolher:**

- **`first_unlock`** — o padrão recomendado. O app consegue ler em segundo plano (para renovar
  token, por exemplo) depois que o usuário desbloqueou o aparelho uma vez.
- **`unlocked`** — se o dado só é usado com o app em primeiro plano. Mais restrito.
- **`first_unlock_this_device`** — quando o dado **não** deve migrar para outro aparelho via
  backup. É a escolha certa para token.

> ⚠️ **Nunca use `always`.** Ele deixa o dado legível com o aparelho **bloqueado**, o que enfraquece
> a proteção sem ganho prático. Ele está obsoleto na API da Apple.

### O Keychain sobrevive à desinstalação

Este é o comportamento que mais surpreende:

```text
🍎 iOS
1. Usuário instala o app, faz login  → token no Keychain
2. Usuário DESINSTALA o app
3. Usuário instala de novo
4. O token AINDA ESTÁ LÁ
```

No Android, desinstalar apaga tudo. No iOS, **itens do Keychain podem persistir**.

Isso às vezes é desejado (o usuário reinstala e continua logado). Mas costuma ser um problema: o
usuário achou que apagou os dados dele, e não apagou.

**A solução** usa o fato de que `SharedPreferences` **é** apagado:

```dart
Future<void> limparSePrimeiraExecucao() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Esta flag é apagada na desinstalação (é SharedPreferences).
  // O Keychain não é. Se a flag sumiu mas o cofre tem coisa,
  // é porque o app foi reinstalado.
  final bool jaRodou = prefs.getBool('ja_rodou') ?? false;

  if (!jaRodou) {
    await _cofre.deleteAll();
    await prefs.setBool('ja_rodou', true);
  }
}
```

Chame isso **antes** de qualquer leitura do cofre, no início do app.

### Os limites reais

Ser honesto aqui evita falsa segurança:

| O que protege | O que **não** protege |
|---|---|
| Outro app lendo os dados | O usuário com aparelho rooteado/jailbroken |
| Arquivo copiado do aparelho | Malware com privilégio de root |
| Backup em nuvem (com as opções certas) | Engenharia reversa do app |
| Leitura casual do sistema de arquivos | Depuração com o app rodando |

E mais uma vez a regra do
[Módulo 09, aula 8](../09-consumo-de-api/08-autenticacao-e-tokens.md):

> **Qualquer coisa dentro do app instalado pode ser extraída por alguém determinado.** O cofre eleva
> muito o custo do ataque — e não o torna impossível.

A consequência prática: o token guardado no cofre deve ser **de curta validade**, e o servidor deve
poder **revogá-lo**. A proteção real é essa, não a criptografia local.

### Excluir do backup

**Android** — o backup automático está ligado por padrão:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules">
```

```xml
<!-- android/app/src/main/res/xml/backup_rules.xml -->
<full-backup-content>
  <!-- O EncryptedSharedPreferences do cofre. -->
  <exclude domain="sharedpref" path="FlutterSecureStorage" />
  <!-- O banco, se contiver dados pessoais. -->
  <exclude domain="database" path="foco.db" />
</full-backup-content>
```

**iOS** — use `accessibility` que termine em `_this_device`:

```dart
const IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
  synchronizable: false,
);
```

Para **arquivos** (banco, documentos), o iOS exige marcar com `NSURLIsExcludedFromBackupKey` — e a
Apple **rejeita** apps que colocam dados recriáveis grandes no iCloud.

### O que nunca fazer

**1. Criptografia caseira.**

```dart
// ❌ isto não é criptografia
String cifrar(String texto) =>
    base64Encode(utf8.encode(texto.split('').reversed.join()));
```

Base64 é **codificação**, não criptografia — qualquer um decodifica. E até algoritmos de verdade,
implementados errado (sem IV aleatório, com modo ECB, sem autenticação), são quebráveis.

**Correção:** use o cofre da plataforma. Ele foi auditado por milhares de pessoas.

**2. Chave de criptografia no código.**

```dart
const String chave = 'minha-chave-secreta-32-caracteres!';   // ❌
```

Está no APK. Descompilar e encontrar leva minutos.

**Correção:** se precisar criptografar um banco (com `sqlcipher`), a chave é **gerada no primeiro
uso** e guardada no **cofre**.

**3. Guardar a senha do usuário.**

```dart
await cofre.write(key: 'senha', value: senha);   // ❌
```

Não existe motivo. Para "manter conectado", guarde o **token**. Para desbloqueio local, guarde o
**hash** do PIN, nunca o PIN.

**4. Dado sensível em log.**

```dart
debugPrint('token: $token');   // ❌
```

Logs vazam: ferramentas de análise capturam, `adb logcat` mostra, relatórios de erro incluem.

**5. Confiar no cofre para dados grandes.**

O Keychain e o Keystore são feitos para **chaves e credenciais** — poucos KB. Guardar um JSON de
500 KB ali é lento e pode falhar. Para volume, use um banco criptografado.

### Testar código que usa cofre

`flutter_secure_storage` precisa de plataforma nativa: ele **não roda** em `flutter test` puro.

A solução é a de sempre — um **contrato** e uma implementação em memória:

```dart
abstract interface class Cofre {
  Future<String?> ler(String chave);
  Future<void> gravar(String chave, String valor);
  Future<void> apagar(String chave);
  Future<void> apagarTudo();
}
```

E o teste usa `CofreEmMemoria`. Mesma técnica do
[Módulo 08, aula 10](../08-estado-e-arquitetura/10-injecao-de-dependencias.md).

> 💡 O plugin também oferece `FlutterSecureStorage.setMockInitialValues({...})` para testes de
> widget. Ele funciona, mas o contrato próprio é melhor: permite testar **falhas** do cofre, que
> acontecem de verdade (aparelho sem tela de bloqueio, Keystore corrompido).

---

## 💡 Analogia

Pense nos lugares onde você guarda coisas em casa.

- **`SharedPreferences`** é a **gaveta da mesa de cabeceira**. Rápida, prática, e qualquer visita
  que abra encontra o que tem dentro. Controle da TV: perfeito. Passaporte: não.
- **O banco SQLite** é o **armário**. Organizado, cabe muita coisa, e continua sendo um móvel que
  se abre.
- **O cofre (`flutter_secure_storage`)** é o **cofre embutido na parede**, com a fechadura
  fabricada pelo próprio construtor do prédio (o sistema operacional). Ele não impede uma
  demolição — impede a visita casual, o ladrão apressado e a cópia da chave.
- **A criptografia caseira** é você esconder a joia **dentro de um pote de açúcar**. Funciona contra
  quem não procura. Qualquer pessoa que já tenha procurado alguma coisa na sua casa vai ao pote.
- **A chave no código** é escrever a senha do cofre **na porta do cofre**.
- **O Keychain sobrevivendo à desinstalação** é a mudança de casa em que o cofre da parede **fica**
  — e o morador seguinte encontra o que você deixou dentro, achando que tinha levado tudo.
- **Guardar o token em vez da senha** é deixar no cofre um **cartão de hotel**, não a escritura da
  casa. O cartão expira, pode ser cancelado pela recepção, e serve para uma porta só.
- **"O dado mais seguro é o que você não guarda"** é a pergunta antes de qualquer cofre: *essa joia
  precisa mesmo estar em casa?*

---

## 🧪 Exemplo mínimo

Um cofre com contrato, implementação real e falsa — e testes que rodam sem plataforma nativa.

> **Arquivo:** `foco_dados/lib/core/seguranca/cofre.dart` (novo)
> **Instale antes:** `flutter pub add flutter_secure_storage`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contrato do armazenamento seguro.
///
/// Existe porque `flutter_secure_storage` precisa de plataforma nativa
/// e NÃO roda em `flutter test` puro. Com o contrato, o teste usa uma
/// implementação em memória — e ainda consegue simular FALHAS do cofre,
/// que acontecem de verdade.
abstract interface class Cofre {
  Future<String?> ler(String chave);
  Future<void> gravar(String chave, String valor);
  Future<void> apagar(String chave);
  Future<void> apagarTudo();
  Future<Map<String, String>> lerTudo();
}

/// Falha ao acessar o cofre.
///
/// Acontece de verdade: aparelho sem tela de bloqueio configurada,
/// Keystore corrompido após atualização do sistema, item do Keychain
/// inacessível porque o aparelho está bloqueado.
class FalhaDoCofre implements Exception {
  const FalhaDoCofre(this.mensagem, [this.causa]);

  final String mensagem;
  final Object? causa;

  @override
  String toString() => mensagem;
}

/// Implementação real: Keystore 🤖 / Keychain 🍎.
class CofreSeguro implements Cofre {
  CofreSeguro([FlutterSecureStorage? storage])
      : _storage = storage ?? _padrao;

  final FlutterSecureStorage _storage;

  static const FlutterSecureStorage _padrao = FlutterSecureStorage(
    aOptions: AndroidOptions(
      // Usa EncryptedSharedPreferences em vez do armazenamento legado,
      // que era mais fraco.
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      // first_unlock_this_device:
      //  - legível depois do 1º desbloqueio após ligar (permite renovar
      //    token em segundo plano);
      //  - "_this_device" impede o item de ir para o backup do iCloud
      //    e migrar para outro aparelho.
      //
      // NUNCA use `always`: ele mantém o dado legível com o aparelho
      // BLOQUEADO, sem ganho prático. Está obsoleto na API da Apple.
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  @override
  Future<String?> ler(String chave) async {
    try {
      return await _storage.read(key: chave);
    } on Object catch (erro) {
      // NUNCA registre o valor lido — só o tipo do erro.
      throw FalhaDoCofre('Não foi possível ler do armazenamento seguro', erro);
    }
  }

  @override
  Future<void> gravar(String chave, String valor) async {
    try {
      await _storage.write(key: chave, value: valor);
    } on Object catch (erro) {
      throw FalhaDoCofre('Não foi possível gravar no armazenamento seguro', erro);
    }
  }

  @override
  Future<void> apagar(String chave) async {
    try {
      await _storage.delete(key: chave);
    } on Object catch (erro) {
      throw FalhaDoCofre('Não foi possível apagar do armazenamento seguro', erro);
    }
  }

  @override
  Future<void> apagarTudo() async {
    try {
      // deleteAll é mais seguro que apagar chave por chave:
      // não sobra nada esquecido de uma versão anterior do app.
      await _storage.deleteAll();
    } on Object catch (erro) {
      throw FalhaDoCofre('Não foi possível limpar o armazenamento seguro', erro);
    }
  }

  @override
  Future<Map<String, String>> lerTudo() async {
    try {
      return await _storage.readAll();
    } on Object catch (erro) {
      throw FalhaDoCofre('Não foi possível ler o armazenamento seguro', erro);
    }
  }
}

/// Implementação em memória, para testes.
///
/// Comporta-se como o cofre real, e permite simular falhas.
class CofreEmMemoria implements Cofre {
  final Map<String, String> _dados = <String, String>{};

  /// Quando não é null, toda operação lança.
  FalhaDoCofre? falhaForcada;

  /// Registro, para o teste verificar.
  final List<String> gravacoes = <String>[];
  int limpezas = 0;

  void _talvezFalhar() {
    final FalhaDoCofre? f = falhaForcada;
    if (f != null) throw f;
  }

  @override
  Future<String?> ler(String chave) async {
    _talvezFalhar();
    return _dados[chave];
  }

  @override
  Future<void> gravar(String chave, String valor) async {
    _talvezFalhar();
    gravacoes.add(chave);
    _dados[chave] = valor;
  }

  @override
  Future<void> apagar(String chave) async {
    _talvezFalhar();
    _dados.remove(chave);
  }

  @override
  Future<void> apagarTudo() async {
    _talvezFalhar();
    limpezas++;
    _dados.clear();
  }

  @override
  Future<Map<String, String>> lerTudo() async {
    _talvezFalhar();
    return Map<String, String>.unmodifiable(_dados);
  }

  /// Simula o Keychain do iOS sobrevivendo à desinstalação:
  /// o app some, mas os dados ficam.
  void simularReinstalacaoIOS() {
    // Nada é apagado — é justamente esse o comportamento.
  }
}
```

> **Arquivo:** `foco_dados/test/cofre_test.dart` (novo)
> **Como executar:** `flutter test test/cofre_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:foco_dados/core/seguranca/cofre.dart';
import 'package:foco_dados/core/seguranca/sessao_local.dart';

void main() {
  late CofreEmMemoria cofre;
  late SessaoLocal sessao;

  setUp(() {
    cofre = CofreEmMemoria();
    sessao = SessaoLocal(cofre);
  });

  group('operações básicas', () {
    test('grava e lê', () async {
      await cofre.gravar('token', 'abc123');
      expect(await cofre.ler('token'), 'abc123');
    });

    test('chave inexistente devolve null', () async {
      expect(await cofre.ler('fantasma'), isNull);
    });

    test('apagarTudo limpa tudo', () async {
      await cofre.gravar('a', '1');
      await cofre.gravar('b', '2');

      await cofre.apagarTudo();

      expect(await cofre.lerTudo(), isEmpty);
    });
  });

  group('falhas do cofre', () {
    test('leitura que falha vira FalhaDoCofre', () async {
      cofre.falhaForcada = const FalhaDoCofre('Keystore indisponível');

      await expectLater(cofre.ler('token'), throwsA(isA<FalhaDoCofre>()));
    });

    test('o app trata a falha sem quebrar', () async {
      cofre.falhaForcada = const FalhaDoCofre('Keystore indisponível');

      // Um aparelho sem tela de bloqueio pode não ter Keystore.
      // O app precisa continuar funcionando — sem sessão salva.
      expect(await sessao.estaAutenticado(), isFalse);
    });
  });

  group('logout', () {
    test('apaga TUDO, não só o token', () async {
      await sessao.salvar(access: 'a', refresh: 'r', usuarioId: 'u1');

      await sessao.sair();

      // apagarTudo, não delete chave por chave: nada fica esquecido.
      expect(await cofre.lerTudo(), isEmpty);
      expect(cofre.limpezas, 1);
    });
  });

  group('reinstalação no iOS', () {
    test('sem a limpeza, os dados sobrevivem', () async {
      await sessao.salvar(access: 'a', refresh: 'r', usuarioId: 'u1');

      // No iOS, desinstalar NÃO apaga o Keychain.
      cofre.simularReinstalacaoIOS();

      expect(await sessao.estaAutenticado(), isTrue,
          reason: 'o Keychain sobreviveu — este é o comportamento real');
    });

    test('a limpeza na primeira execução resolve', () async {
      await sessao.salvar(access: 'a', refresh: 'r', usuarioId: 'u1');
      cofre.simularReinstalacaoIOS();

      // A flag de "já rodou" é SharedPreferences, que É apagado
      // na desinstalação. Se ela sumiu e o cofre tem coisa,
      // é reinstalação.
      await sessao.limparSeReinstalado(jaRodouAntes: false);

      expect(await sessao.estaAutenticado(), isFalse);
      expect(cofre.limpezas, 1);
    });

    test('execução normal NÃO limpa', () async {
      await sessao.salvar(access: 'a', refresh: 'r', usuarioId: 'u1');

      await sessao.limparSeReinstalado(jaRodouAntes: true);

      expect(await sessao.estaAutenticado(), isTrue);
      expect(cofre.limpezas, 0);
    });
  });

  group('o que NÃO se guarda', () {
    test('o PIN é guardado como hash, nunca em claro', () async {
      await sessao.definirPin('1234');

      final Map<String, String> tudo = await cofre.lerTudo();

      // Se alguém abrir o cofre, não encontra o PIN.
      expect(tudo.values.any((String v) => v.contains('1234')), isFalse);
      // E a verificação continua funcionando.
      expect(await sessao.pinCorreto('1234'), isTrue);
      expect(await sessao.pinCorreto('9999'), isFalse);
    });
  });
}
```

---

## 📱 Aplicando no Flutter

O `foco_dados` ganha uma `SessaoLocal` completa:

- guarda tokens e id do usuário no cofre;
- guarda o **hash** do PIN de desbloqueio, nunca o PIN;
- limpa tudo na reinstalação (o caso do iOS);
- trata falha do cofre sem quebrar o app;
- exclui os dados do backup nas duas plataformas.

---

## 💻 Código completo

> **Arquivo:** `foco_dados/lib/core/seguranca/sessao_local.dart` (novo)
> **Como executar:** `flutter test`

```dart
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';

import 'package:foco_dados/core/seguranca/cofre.dart';

/// Dados de sessão guardados no aparelho.
///
/// Tudo aqui é CRÍTICO: se vazar, alguém acessa a conta do usuário.
/// Por isso nada disto passa perto de SharedPreferences.
class SessaoLocal {
  const SessaoLocal(this._cofre);

  final Cofre _cofre;

  // Chaves com prefixo do app: `readAll` num cofre compartilhado
  // por vários módulos fica legível.
  static const String _kAccess = 'foco.access_token';
  static const String _kRefresh = 'foco.refresh_token';
  static const String _kUsuario = 'foco.usuario_id';
  static const String _kPinHash = 'foco.pin_hash';
  static const String _kPinSal = 'foco.pin_sal';

  // ── Sessão ────────────────────────────────────────────────────────────────

  Future<void> salvar({
    required String access,
    required String refresh,
    required String usuarioId,
  }) async {
    await _cofre.gravar(_kAccess, access);
    await _cofre.gravar(_kRefresh, refresh);
    await _cofre.gravar(_kUsuario, usuarioId);
  }

  Future<String?> get accessToken => _lerTolerante(_kAccess);
  Future<String?> get refreshToken => _lerTolerante(_kRefresh);
  Future<String?> get usuarioId => _lerTolerante(_kUsuario);

  Future<bool> estaAutenticado() async =>
      (await _lerTolerante(_kAccess)) != null;

  /// Sai da sessão.
  ///
  /// `apagarTudo`, não `apagar` chave por chave: numa versão futura do
  /// app alguém acrescenta uma chave e esquece de incluí-la no logout.
  /// O dado esquecido fica no aparelho para sempre.
  Future<void> sair() => _cofre.apagarTudo();

  // ── PIN de desbloqueio ────────────────────────────────────────────────────

  /// Define o PIN local.
  ///
  /// Guarda o HASH, nunca o PIN. Se o cofre for comprometido, o atacante
  /// encontra um hash — e, com o sal, nem uma tabela pronta ajuda.
  Future<void> definirPin(String pin) async {
    final String sal = _gerarSal();
    final String hash = _hashDe(pin, sal);

    await _cofre.gravar(_kPinSal, sal);
    await _cofre.gravar(_kPinHash, hash);
  }

  Future<bool> pinCorreto(String pin) async {
    final String? sal = await _lerTolerante(_kPinSal);
    final String? hash = await _lerTolerante(_kPinHash);
    if (sal == null || hash == null) return false;

    // Comparação em tempo constante evita ataque de temporização:
    // com `==`, o tempo de resposta revela quantos caracteres batem.
    return _iguaisEmTempoConstante(_hashDe(pin, sal), hash);
  }

  Future<bool> get temPin async => (await _lerTolerante(_kPinHash)) != null;

  Future<void> removerPin() async {
    await _cofre.apagar(_kPinHash);
    await _cofre.apagar(_kPinSal);
  }

  // ── Reinstalação (o caso do iOS) ──────────────────────────────────────────

  /// Limpa o cofre quando o app foi reinstalado.
  ///
  /// No iOS, itens do Keychain PODEM sobreviver à desinstalação: o
  /// usuário reinstala e continua logado com um token que ele achava
  /// apagado.
  ///
  /// A detecção usa o fato de que SharedPreferences É apagado na
  /// desinstalação: se a flag sumiu mas o cofre tem conteúdo, houve
  /// reinstalação.
  ///
  /// Chame ANTES de qualquer leitura do cofre, no início do app.
  Future<void> limparSeReinstalado({required bool jaRodouAntes}) async {
    if (jaRodouAntes) return;
    await _cofre.apagarTudo();
  }

  // ── Auxiliares ────────────────────────────────────────────────────────────

  /// Lê tolerando falha do cofre.
  ///
  /// O Keystore pode estar indisponível: aparelho sem tela de bloqueio,
  /// corrupção após atualização do sistema, item inacessível com o
  /// aparelho bloqueado. Nesses casos o app deve continuar funcionando
  /// — sem sessão — em vez de quebrar na abertura.
  Future<String?> _lerTolerante(String chave) async {
    try {
      return await _cofre.ler(chave);
    } on FalhaDoCofre {
      // Sem `debugPrint` do valor. Nem do erro completo: mensagens de
      // erro de Keystore às vezes incluem o alias da chave.
      return null;
    }
  }

  static String _gerarSal() {
    // Random.secure usa a fonte de aleatoriedade do sistema.
    // Random() comum é previsível e NÃO serve para segurança.
    final math.Random aleatorio = math.Random.secure();
    final List<int> bytes =
        List<int>.generate(16, (_) => aleatorio.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _hashDe(String pin, String sal) {
    // SHA-256 com sal. Para SENHAS de verdade, o certo é um algoritmo
    // lento (Argon2, bcrypt, PBKDF2) — e a validação é no SERVIDOR.
    // Aqui protegemos um PIN local de 4 dígitos, cujo espaço de busca
    // é pequeno de qualquer forma: o valor real vem de o cofre limitar
    // o acesso, não do hash.
    return sha256.convert(utf8.encode('$sal:$pin')).toString();
  }

  /// Compara sem vazar informação pelo tempo de execução.
  static bool _iguaisEmTempoConstante(String a, String b) {
    if (a.length != b.length) return false;
    int diferenca = 0;
    for (int i = 0; i < a.length; i++) {
      // XOR acumulado: percorre a string INTEIRA, sempre.
      diferenca |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diferenca == 0;
  }
}
```

> **Arquivo:** `foco_dados/lib/core/seguranca/inicializacao_segura.dart` (novo)

```dart
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foco_dados/core/seguranca/sessao_local.dart';

/// Preparação de segurança que roda no início do app.
///
/// Chame ANTES de qualquer leitura do cofre.
abstract final class InicializacaoSegura {
  static const String _kJaRodou = 'foco.ja_rodou';

  static Future<void> executar(SessaoLocal sessao) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Esta flag mora em SharedPreferences DE PROPÓSITO: ela é apagada
    // na desinstalação. O Keychain do iOS não é. A diferença entre os
    // dois é o que permite detectar a reinstalação.
    final bool jaRodou = prefs.getBool(_kJaRodou) ?? false;

    await sessao.limparSeReinstalado(jaRodouAntes: jaRodou);

    if (!jaRodou) {
      await prefs.setBool(_kJaRodou, true);
    }
  }
}
```

E no `main`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SessaoLocal sessao = SessaoLocal(CofreSeguro());

  // ANTES de qualquer leitura do cofre.
  await InicializacaoSegura.executar(sessao);

  runApp(const ProviderScope(child: FocoApp()));
}
```

> **Arquivo:** `foco_dados/android/app/src/main/res/xml/backup_rules.xml` (novo)

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
  O backup automático do Android está LIGADO por padrão. Sem estas
  exclusões, o cofre e o banco vão para o Google Backup — e de lá
  para outro aparelho.
-->
<full-backup-content>
  <!-- O EncryptedSharedPreferences usado pelo flutter_secure_storage. -->
  <exclude domain="sharedpref" path="FlutterSecureStorage" />

  <!-- O banco, que contém o histórico de estudo do usuário. -->
  <exclude domain="database" path="foco.db" />
</full-backup-content>
```

> **Arquivo:** `foco_dados/android/app/src/main/res/xml/data_extraction_rules.xml` (novo)
>
> Exigido a partir do Android 12 (API 31); o `backup_rules.xml` vale para versões anteriores.

```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
  <cloud-backup>
    <exclude domain="sharedpref" path="FlutterSecureStorage" />
    <exclude domain="database" path="foco.db" />
  </cloud-backup>
  <!-- Transferência direta para um aparelho novo. -->
  <device-transfer>
    <exclude domain="sharedpref" path="FlutterSecureStorage" />
  </device-transfer>
</data-extraction-rules>
```

> **Arquivo:** `foco_dados/android/app/src/main/AndroidManifest.xml` (acrescente)

```xml
<application
    android:label="foco_dados"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules">
```

E o `pubspec.yaml`:

```yaml
dependencies:
  flutter_secure_storage: ^11.1.1
  shared_preferences: ^2.5.5
  # Para o hash do PIN.
  crypto: ^3.0.6
```

Rode:

```powershell
flutter pub add flutter_secure_storage crypto
flutter analyze
flutter test
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `abstract interface class Cofre` | Permite testar sem plataforma nativa — e simular **falhas** do cofre, que acontecem de verdade. |
| `encryptedSharedPreferences: true` | Usa `EncryptedSharedPreferences` em vez do armazenamento legado do plugin, mais fraco. |
| `KeychainAccessibility.first_unlock_this_device` | Legível em segundo plano após o 1º desbloqueio, **e** não migra para outro aparelho via backup. |
| `synchronizable: false` | Impede o item de ir para o Keychain do iCloud. |
| `FalhaDoCofre` em vez de deixar a exceção nativa subir | A tela recebe um erro que ela entende, sem conhecer `PlatformException`. |
| `throw FalhaDoCofre(..., erro)` **sem** registrar o valor | Mensagens de erro de Keystore às vezes incluem o alias da chave. |
| `_lerTolerante` devolvendo `null` na falha | Aparelho sem tela de bloqueio pode não ter Keystore. O app continua funcionando, sem sessão — em vez de quebrar na abertura. |
| `sair()` usando `apagarTudo()` | Apagar chave por chave garante que, um dia, alguém acrescente uma chave e esqueça de incluí-la no logout. |
| Prefixo `foco.` nas chaves | `readAll` num cofre compartilhado fica legível. |
| `definirPin` gravando **hash + sal** | Se o cofre for comprometido, o atacante encontra um hash. O sal impede tabela pronta. |
| `math.Random.secure()` | `Random()` comum é **previsível** e não serve para segurança. |
| `_iguaisEmTempoConstante` | Com `==`, o tempo de resposta revela quantos caracteres batem — ataque de temporização. |
| Comentário admitindo que SHA-256 não é ideal para senha | Honestidade: para senha real, use Argon2/bcrypt **no servidor**. O PIN de 4 dígitos tem espaço pequeno de qualquer forma. |
| `limparSeReinstalado(jaRodouAntes:)` | A flag em `SharedPreferences` (apagada na desinstalação) contra o cofre (que não é) detecta a reinstalação. |
| `InicializacaoSegura.executar` **antes** do `runApp` | Se rodar depois de alguma leitura do cofre, o app já teria usado um token que deveria ter sido apagado. |
| `backup_rules.xml` **e** `data_extraction_rules.xml` | O primeiro vale até o Android 11; o segundo é exigido do 12 em diante. Precisa dos dois. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Mecanismo | Keystore + `EncryptedSharedPreferences` | Keychain |
| Chave em hardware | TEE / StrongBox, quando o aparelho tem | Secure Enclave |
| Sobrevive à desinstalação | ❌ Apagado | ⚠️ **Pode sobreviver** |
| Backup por padrão | ✅ Google Backup — **exclua** | ✅ iCloud — use `_this_device` |
| Versão mínima | API 23 (Android 6) | iOS 12 |
| Sem tela de bloqueio | Keystore pode falhar | Keychain funciona, com menos proteção |
| Após atualização do sistema | Keystore pode se **invalidar**; leitura falha | Mais estável |
| Limpar dados do app | Apaga o cofre | N/A (não existe a opção) |

> ⚠️ **As duas linhas mais importantes são a terceira e a sétima.**
>
> **Terceira:** no iOS, o usuário desinstala achando que apagou tudo, reinstala e continua logado.
> É a razão de existir o `limparSeReinstalado`.
>
> **Sétima:** no Android, uma atualização do sistema ou uma mudança na tela de bloqueio pode
> **invalidar** as chaves do Keystore. A leitura passa a falhar, e o app precisa tratar isso —
> pedindo login de novo, não quebrando.

---

## ⚠️ Erros comuns

### 1. Token em `SharedPreferences`

```dart
await prefs.setString('token', token);   // ❌ XML em texto puro
```

**Correção:** cofre.

### 2. Criptografia caseira

```dart
final String cifrado = base64Encode(utf8.encode(senha));   // ❌
```

Base64 é **codificação**. Qualquer um decodifica em um site.

**Correção:** o cofre da plataforma.

### 3. Chave de criptografia no código

```dart
const String chave = 'chave-de-32-caracteres-aqui!!!';   // ❌
```

Está no APK.

**Correção:** gere no primeiro uso e guarde no cofre.

### 4. Guardar a senha do usuário

```dart
await cofre.gravar('senha', senha);   // ❌
```

Não há motivo. Para manter conectado, guarde o **token**.

**Correção:** token (revogável, expirável) ou hash, nunca a senha.

### 5. `Random()` em vez de `Random.secure()`

```dart
final math.Random r = math.Random();   // ❌ previsível
```

**Correção:** `math.Random.secure()`.

### 6. Comparar hash com `==`

```dart
return _hashDe(pin, sal) == hashGuardado;   // ⚠️ ataque de temporização
```

**Correção:** comparação em tempo constante.

### 7. Ignorar a sobrevivência do Keychain

O usuário desinstala, reinstala, e continua logado — sem entender por quê.

**Correção:** `limparSeReinstalado`, chamado **antes** de qualquer leitura.

### 8. Não excluir do backup

O cofre e o banco vão para a nuvem e de lá para outro aparelho.

**Correção:** `backup_rules.xml` + `data_extraction_rules.xml` no Android; `_this_device` no iOS.

### 9. Deixar a exceção do cofre quebrar o app

```dart
final String? t = await storage.read(key: 'token');   // ❌ pode lançar
```

Aparelho sem tela de bloqueio, Keystore invalidado após atualização — o app não abre.

**Correção:** `try/catch`, devolvendo `null` e pedindo login.

### 10. Logout apagando chave por chave

```dart
await cofre.apagar('access');   // ⚠️ e o refresh? e o id? e a chave nova?
```

**Correção:** `apagarTudo()`.

### 11. Guardar muita coisa no cofre

```dart
await cofre.gravar('cache', jsonDe500KB);   // ⚠️
```

Keychain e Keystore são para **credenciais**, poucos KB. Volume grande é lento e pode falhar.

**Correção:** banco criptografado (`sqlcipher`), com a chave no cofre.

### 12. Dado sensível em log

```dart
debugPrint('sessão: $token');   // ❌
```

**Correção:** não registre. Se precisar depurar, use `token.substring(0, 4)`.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `flutter test test/cofre_test.dart` e confirme todos passando.

**Passo 2.** No teste `o PIN é guardado como hash`, mude `definirPin` para gravar o PIN em claro.
Rode e veja o teste falhar. Depois desfaça.

**Passo 3.** Remova o sal (`_hashDe(pin, '')`). Calcule o SHA-256 de `:1234` em um site e compare
com o valor no cofre. Explique por que o sal importa.

**Passo 4.** Troque `math.Random.secure()` por `math.Random(42)`. Rode duas vezes e compare os sais
gerados. O que isso significaria num app real?

**Passo 5.** No `_lerTolerante`, remova o `try/catch`. Force uma falha no cofre e observe o que
acontece com `estaAutenticado()`.

**Passo 6.** Troque `sair()` para apagar só o `_kAccess`. Rode o teste de logout. Qual chave ficou?

**Passo 7.** Simule a reinstalação no iOS: rode `limparSeReinstalado(jaRodouAntes: false)` com
dados no cofre. Confirme a limpeza. Depois com `true`.

**Passo 8.** Num emulador Android, grave um token, rode
`adb shell run-as <pacote> cat shared_prefs/FlutterSecureStorage.xml` e veja o conteúdo. Depois
faça o mesmo com `FlutterSharedPreferences.xml` e compare.

**Passo 9.** Liste todos os dados que o Foco guarda. Para cada um, responda: "se vazar, o que
acontece com o usuário?" e decida onde ele deve ficar.

**Passo 10.** Responda por escrito: o app precisa mostrar o nome do usuário na tela inicial, mesmo
offline. Onde você guarda esse nome? Justifique.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md)

Faça os exercícios de **Classificação** de dados, o de **Correção de bugs** com token em
`SharedPreferences`, e o de **Aplicação** com PIN de desbloqueio.

---

## 🏆 Desafio opcional

Implemente **desbloqueio por biometria** para o PIN do Foco.

Requisitos:

- `local_auth` para Face ID / Touch ID / impressão digital.
- O PIN continua existindo como alternativa — biometria **falha** (dedo molhado, máscara,
  sensor sujo) e o usuário não pode ficar trancado fora do app.
- Após 3 falhas de biometria, cai para o PIN automaticamente.
- Se o aparelho não tiver biometria cadastrada, o app usa PIN sem mostrar erro.
- Um ajuste permite desligar a biometria.
- Os testes cobrem: biometria disponível, indisponível, falha e cancelamento pelo usuário.

Dica: `local_auth` expõe `canCheckBiometrics`, `getAvailableBiometrics()` e `authenticate()`.
Envolva tudo num contrato (`Autenticador`) para poder testar sem aparelho.

Depois responda: por que a biometria **não** deve substituir o PIN, e sim complementá-lo? Pense em
quem não tem digital cadastrada, em quem usa luva no inverno e em quem teve o rosto rejeitado três
vezes seguidas numa fila.

---

## 📌 Resumo

- A pergunta que classifica: **"se isto vazar, o que acontece com o usuário?"**
- **O dado mais seguro é o que você não guarda.** Pergunte se o app precisa mesmo daquilo no
  aparelho.
- `SharedPreferences` (XML/plist) e `sqflite` (arquivo `.db`) são **texto legível** — nunca para
  dado crítico.
- **`flutter_secure_storage`** usa Keystore 🤖 e Keychain 🍎. Na **web ele não protege nada**.
- Configure `encryptedSharedPreferences: true` e
  `KeychainAccessibility.first_unlock_this_device` + `synchronizable: false`.
- **Nunca use `accessibility: always`** — deixa o dado legível com o aparelho bloqueado.
- **No iOS, o Keychain sobrevive à desinstalação.** Detecte com uma flag em `SharedPreferences` e
  limpe na primeira execução.
- **O Keystore pode falhar** (sem tela de bloqueio, após atualização do sistema). Trate a exceção:
  o app continua, sem sessão.
- **Logout usa `deleteAll()`**, nunca chave por chave.
- Guarde **hash + sal** de PIN, nunca o valor. `Random.secure()`, e comparação em **tempo
  constante**.
- **Nunca** invente criptografia; **nunca** ponha chave no código; **nunca** guarde senha;
  **nunca** registre dado sensível em log.
- Exclua do backup: `backup_rules.xml` **e** `data_extraction_rules.xml` no Android;
  `_this_device` no iOS.
- O cofre é para **credenciais** (poucos KB). Volume grande pede banco criptografado.
- **O cofre eleva o custo do ataque, não o torna impossível.** A proteção real é o token curto e
  revogável pelo servidor.
- Teste com um **contrato** e implementação em memória — e teste também as **falhas** do cofre.

---

## ☑️ Checklist de domínio

- [ ] Classifico dados pela pergunta "se vazar, o que acontece com o usuário?".
- [ ] Sei que `SharedPreferences` e `sqflite` guardam em texto legível.
- [ ] Configuro `AndroidOptions` e `IOSOptions` corretamente, e sei o que cada opção muda.
- [ ] Nunca uso `accessibility: always`.
- [ ] Trato a sobrevivência do Keychain no iOS.
- [ ] Trato falha do cofre sem quebrar o app.
- [ ] Faço logout com `deleteAll()`.
- [ ] Guardo hash + sal de PIN, com `Random.secure()` e comparação em tempo constante.
- [ ] Nunca invento criptografia nem ponho chave no código.
- [ ] Nunca registro dado sensível em log.
- [ ] Excluí o cofre e o banco do backup nas duas plataformas.
- [ ] Sei os limites reais do armazenamento seguro.
- [ ] Testo com contrato e implementação em memória, incluindo falhas.

---

## 📚 Referências oficiais

- [flutter_secure_storage — pub.dev](https://pub.dev/packages/flutter_secure_storage)
- [Android Keystore — developer.android.com](https://developer.android.com/privacy-and-security/keystore)
- [EncryptedSharedPreferences — developer.android.com](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences)
- [Back up user data — developer.android.com](https://developer.android.com/guide/topics/data/autobackup)
- [Keychain Services — developer.apple.com](https://developer.apple.com/documentation/security/keychain_services)
- [Keychain item accessibility — developer.apple.com](https://developer.apple.com/documentation/security/ksecattraccessible)
- [Data security — docs.flutter.dev](https://docs.flutter.dev/security)
- [OWASP Mobile Top 10 — M9: Insecure Data Storage](https://owasp.org/www-project-mobile-top-10/)
- [LGPD — Lei 13.709/2018, art. 5º, II](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Migrações](06-migracoes.md) | [README](README.md) | [Aula 8 — Cache e offline](08-cache-e-offline.md) |
