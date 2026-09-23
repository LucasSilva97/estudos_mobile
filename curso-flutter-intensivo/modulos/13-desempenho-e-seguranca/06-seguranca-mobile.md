# Aula 6 — Segurança mobile

> **Módulo:** 13 - Desempenho e Segurança · **Tempo estimado:** 55 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Entender a regra nº 1: **nada dentro do app é secreto** — e por quê.
- Extrair um APK e **ler as suas strings** em cinco minutos, para se convencer disso.
- Usar **`--dart-define`** e `--dart-define-from-file` sem versionar segredo.
- Guardar token no **cofre do sistema** e decidir **o que guardar onde**.
- Escrever SQL com **`whereArgs`** e entender injeção de SQL no celular.
- Configurar **HTTPS obrigatório** nas duas plataformas e saber o que é *certificate pinning*.
- Montar um **`.gitignore`** que não deixa segredo escapar — e o que fazer se já escapou.

## ✅ Pré-requisitos

- [Aula 5 — Acessibilidade](05-acessibilidade.md) — o projeto `foco_desempenho`.
- [Módulo 10, aula 7 — Dados sensíveis](../10-persistencia-de-dados/07-dados-sensiveis.md) —
  `flutter_secure_storage`, Keystore e Keychain. **Esta aula não repete aquilo**: aqui o assunto é
  a **decisão** de o que proteger e contra o quê.
- [Módulo 09, aula 8 — Autenticação e tokens](../09-consumo-de-api/08-autenticacao-e-tokens.md).
- [Módulo 10, aula 5 — sqflite CRUD](../10-persistencia-de-dados/05-sqflite-crud.md) — `whereArgs`.

---

## 📖 Conceito

### A regra nº 1: nada dentro do app é secreto

```dart
// ❌ Este segredo está PÚBLICO no momento em que você publica o app.
const String apiSecret = 'sk_live_a7f3b2c9e1d4';
```

Quando você publica um app, entrega o binário **para o usuário**. Ele está no celular dele, e ele
pode abri-lo. Não é preciso ser especialista:

```powershell
# Qualquer pessoa, em 5 minutos, com ferramentas gratuitas:
unzip app-release.apk -d extraido
# procura qualquer coisa parecida com uma chave
strings extraido/lib/arm64-v8a/libapp.so | Select-String "sk_|api|secret|key"
```

| O que as pessoas acham | A realidade |
|---|---|
| "Está compilado, ninguém lê" | `strings` lê em 5 s |
| "Está ofuscado" | Ofuscação embaralha **nomes**, não strings |
| "Está em base64" | Base64 não é criptografia; é codificação |
| "Está numa constante `private`" | `private` é do compilador, não do binário |
| "Uso `--dart-define`" | ⚠️ **Também vai para o binário** |

> ⚠️ **`--dart-define` NÃO torna nada secreto.** Ele resolve um problema diferente e importante —
> manter o valor **fora do Git** e permitir configurações por ambiente. O valor continua dentro do
> binário. Confundir as duas coisas é o erro conceitual mais comum desta aula.

**A consequência prática:**

| Pode ficar no app | **Nunca** pode |
|---|---|
| URL da API | Chave secreta de API (`sk_...`) |
| Chave **pública** | Senha de banco de dados |
| ID do cliente OAuth | Token de serviço (AWS, Stripe, Firebase Admin) |
| Chave de API **restrita por pacote e assinatura** | Chave de pagamento |
| Configuração por ambiente | Qualquer credencial que valha dinheiro |

> 📌 **Se a chave é secreta, ela mora no seu servidor.** O app fala com o seu servidor; o seu
> servidor fala com o serviço de terceiro usando a chave. Não há atalho. Qualquer desenho em que o
> app precisa de uma chave secreta está errado — não em Flutter, em **qualquer** tecnologia móvel.

### O modelo de ameaça

Antes de proteger, pergunte: **proteger contra quem?**

| Ameaça | Probabilidade | Proteção |
|---|---|---|
| Alguém pega o celular destravado | **Alta** | Logout, timeout, biometria |
| App malicioso no mesmo aparelho | Média | Cofre do sistema, sandbox |
| Rede Wi-Fi hostil | Média | HTTPS obrigatório |
| Backup do celular na nuvem | Média | Não gravar token em `SharedPreferences` |
| Celular roubado e desbloqueado | Média | Token com validade curta |
| Aparelho com root/jailbreak | Baixa | ⚠️ Praticamente indefensável |
| Engenharia reversa do binário | **Certa** | Nada. Aceite. |

> 💡 **A ameaça mais provável é a mais banal**: alguém com acesso físico ao celular destravado. Um
> botão de sair que realmente apaga o token protege mais gente que qualquer técnica sofisticada.

### O que guardar onde

| Dado | Onde | Por quê |
|---|---|---|
| Token de acesso | **`flutter_secure_storage`** | Keystore/Keychain |
| Token de renovação | **`flutter_secure_storage`** | Idem |
| Senha do usuário | **Em lugar nenhum** | Guarde só o token |
| PIN do app | `flutter_secure_storage`, como hash | Nunca em claro |
| Preferência de tema | `SharedPreferences` | Não é sensível |
| Cache de matérias | sqflite | Não é sensível |
| Dados de saúde, financeiros | sqflite **cifrado** (SQLCipher) | Sensível em repouso |

```dart
// ❌ SharedPreferences vai para o BACKUP da nuvem, em texto simples.
await prefs.setString('token', token);

// ✅ Keystore (Android) / Keychain (iOS).
await const FlutterSecureStorage().write(key: 'token', value: token);
```

### `--dart-define`: configuração, não segredo

```powershell
flutter run --dart-define=API_URL=https://api.exemplo.com --dart-define=AMBIENTE=dev
```

```dart
// Lidas em tempo de COMPILAÇÃO: precisam ser const.
const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://api.exemplo.com',
);
```

> ⚠️ **`String.fromEnvironment` só funciona em contexto `const`.** Fora dele, devolve o valor
> padrão silenciosamente — um bug difícil de perceber, porque nada falha; o app só usa a URL
> errada.

Com muitas variáveis, use um arquivo:

```json
// config/dev.json  — ⚠️ NO .gitignore
{
  "API_URL": "https://dev.api.exemplo.com",
  "AMBIENTE": "dev"
}
```

```powershell
flutter run --dart-define-from-file=config/dev.json
flutter build apk --dart-define-from-file=config/prod.json
```

E versione um **exemplo**, sem valores:

```json
// config/exemplo.json  — este VAI para o Git
{
  "API_URL": "https://api.exemplo.com",
  "AMBIENTE": "dev"
}
```

### Injeção de SQL

Sim, isso existe no celular — o banco é local, mas o **conteúdo** não é.

```dart
// ❌ O nome vem do usuário, ou de uma API, ou de um arquivo importado.
final String nome = campoBusca.text;
await db.rawQuery("SELECT * FROM materias WHERE nome = '$nome'");

// Se nome for:  '; DROP TABLE materias; --
// a query vira: SELECT * FROM materias WHERE nome = ''; DROP TABLE materias; --'
```

```dart
// ✅ whereArgs: o valor NUNCA é interpretado como SQL.
await db.query(
  'materias',
  where: 'nome = ?',
  whereArgs: <Object?>[nome],
);
```

> 📌 **`whereArgs` não é só segurança — é correção.** Um nome com apóstrofo ("D'Ávila") quebra a
> query interpolada mesmo sem má intenção. O `?` resolve os dois problemas de uma vez, e ainda
> permite ao SQLite reaproveitar o plano de execução.

| Método | Seguro? |
|---|---|
| `db.query(where: 'x = ?', whereArgs: [v])` | ✅ |
| `db.rawQuery('… WHERE x = ?', [v])` | ✅ |
| `db.rawQuery("… WHERE x = '$v'")` | ❌ |
| `db.insert('t', {'nome': v})` | ✅ (o mapa é parametrizado) |

> ⚠️ **Nomes de tabela e coluna não podem ser parâmetros.** `db.query(tabela)` com `tabela` vindo
> do usuário é injeção. Valide contra uma lista fixa de nomes permitidos.

### HTTPS obrigatório

O padrão já bloqueia HTTP nas duas plataformas — **não desfaça isso**:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="false"    <!-- ✅ o padrão desde o Android 9 -->
    …>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <!-- ❌ NUNCA em produção. A Apple pergunta o porquê na revisão. -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

> ⚠️ **O conselho de internet mais perigoso do Flutter** é "ponha `NSAllowsArbitraryLoads` como
> `true` para funcionar". Isso desliga a proteção de transporte do app inteiro para resolver um
> problema de desenvolvimento local. Se você precisa de HTTP em desenvolvimento, **libere só o host
> local**, em um arquivo de configuração de debug.

**Certificate pinning** — fixar o certificado do servidor no app:

```dart
final HttpClient cliente = HttpClient()
  ..badCertificateCallback = (X509Certificate cert, String host, int porta) {
    // Compara a impressão digital do certificado com a esperada.
    return cert.sha1.toString() == impressaoEsperada;
  };
```

| | A favor | Contra |
|---|---|---|
| Pinning | Impede interceptação mesmo com CA comprometida | **O app quebra quando o certificado é renovado** |

> 💡 **Para a maioria dos apps, pinning não compensa.** Um certificado renovado sem uma atualização
> do app deixa todos os usuários sem acesso — e a atualização leva dias para chegar a todo mundo.
> Use em app bancário, com plano de rotação e um certificado de reserva fixado junto.

### O que NÃO fazer

| Prática | Por quê é ruim |
|---|---|
| Criptografia própria | Você vai errar. Use bibliotecas auditadas. |
| Guardar senha "criptografada" | Guarde o token; a senha não precisa ficar. |
| Base64 como proteção | É codificação, não criptografia. |
| `print` de token | Vai para o logcat, visível a outros apps. |
| Detecção de root como única defesa | Contornável em minutos. |
| Chave de criptografia no código | Mesma trava, mesma chave, todos os aparelhos. |

```dart
// ❌ O token no log é legível por qualquer app com permissão de leitura de log.
print('token: $token');
debugPrint('Authorization: Bearer $token');
```

```dart
// ✅ Registre que aconteceu, não o valor.
log('Token renovado (expira em ${validade.inMinutes} min)', name: 'auth');
```

### Se um segredo vazou

Descobriu uma chave commitada? A ordem importa:

1. **Revogue a chave agora.** Antes de mexer no Git. A chave está pública desde o commit.
2. Gere uma nova, fora do repositório.
3. Só então limpe o histórico (`git filter-repo` ou BFG) — e saiba que forks e clones já têm.
4. Acrescente ao `.gitignore`.

> ⚠️ **Apagar o commit não desfaz o vazamento.** Se o repositório é público, robôs varrem o GitHub
> procurando chaves em **minutos**. Remover do histórico é higiene; **revogar é a correção**.

---

## 💡 Analogia

Pense na diferença entre **a chave do cofre** e **o endereço do banco**.

- **O app é a agência bancária**, aberta ao público. Qualquer um entra, olha os balcões, lê os
  cartazes. Guardar a chave do cofre **numa gaveta do balcão** é o que fazer `const apiSecret` no
  código significa. Não adianta a gaveta estar fechada: o prédio inteiro é público.
- **"Está compilado"** é achar que a gaveta estar em outro idioma protege alguma coisa.
- **O `--dart-define`** é **não escrever a chave no manual de procedimentos** que fica na sala dos
  funcionários. Ótima prática — o manual circula, é fotocopiado, vai para casa. Mas a chave **ainda
  está na gaveta**: você só parou de divulgá-la junto com o manual.
- **A chave secreta mora no cofre central**, no prédio blindado (o seu servidor). A agência liga
  para lá e pede a operação. É por isso que não existe atalho.
- **O `flutter_secure_storage`** é o cofre pessoal de cada cliente, com a fechadura do próprio
  prédio (Keystore/Keychain). Não protege contra o prédio inteiro ser demolido, mas protege do
  vizinho de guichê.
- **O `whereArgs`** é o formulário com campos delimitados. Sem ele, o cliente escreve na linha do
  valor: *"R$ 100 — e transfira tudo para minha conta"*, e o caixa lê a frase inteira como
  instrução.
- **O HTTPS** é o malote lacrado. `NSAllowsArbitraryLoads: true` é mandar o dinheiro em envelope
  aberto porque o lacre estava dando trabalho.
- **O pinning** é exigir que o motorista do malote seja **uma pessoa específica**. Mais seguro — e
  no dia em que essa pessoa se aposenta e você não avisou ninguém, o malote não sai.

---

## 🧪 Exemplo mínimo

Prove a regra nº 1 com as próprias mãos.

**Passo 1 — um segredo ingênuo:**

```dart
// lib/segredo_ingenuo.dart
const String chaveApi = 'sk_live_ABC123_NAO_FACA_ISSO';
const String senhaBanco = 'admin@2026';
```

**Passo 2 — compile em release:**

```powershell
flutter build apk --release
```

**Passo 3 — extraia e procure:**

```powershell
# O APK é um ZIP.
Expand-Archive build/app/outputs/flutter-apk/app-release.apk -DestinationPath extraido -Force

# Procura strings legíveis no binário Dart.
# (No Windows: instale o `strings` do Sysinternals, ou use o do Git Bash.)
strings extraido/lib/arm64-v8a/libapp.so | Select-String "sk_live|admin@"
```

```text
sk_live_ABC123_NAO_FACA_ISSO
admin@2026
```

**Passo 4 — agora com ofuscação:**

```powershell
flutter build apk --release --obfuscate --split-debug-info=build/simbolos
strings extraido/lib/arm64-v8a/libapp.so | Select-String "sk_live"
```

```text
sk_live_ABC123_NAO_FACA_ISSO       ← ⚠️ CONTINUA LÁ
```

> 📌 **Faça este exercício.** Ler a própria chave saindo do próprio APK convence de um jeito que
> nenhum texto convence. A ofuscação embaralha **nomes de classes e métodos**; strings literais são
> dados, e continuam intactas. É o assunto da próxima aula.

---

## 📱 Aplicando no Flutter

Configuração por ambiente, cofre de token e DAO à prova de injeção.

---

## 💻 Código completo

> **Arquivo:** `foco_desempenho/lib/core/seguranca/config_app.dart` (novo)

```dart
/// Configuração do app, por ambiente.
///
/// ⚠️ TUDO aqui vai para o binário e é legível por quem extrair o
/// APK. Isto NÃO é um lugar para segredos — é um lugar para
/// CONFIGURAÇÃO que varia por ambiente e não deve ir para o Git.
///
/// Segredo de verdade mora no servidor. Sem exceção.
abstract final class ConfigApp {
  // ⚠️ String.fromEnvironment só funciona em contexto const.
  // Fora dele devolve o defaultValue SILENCIOSAMENTE — e o app
  // passa a usar a URL errada sem nenhum erro.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.exemplo.com',
  );

  static const String ambiente = String.fromEnvironment(
    'AMBIENTE',
    defaultValue: 'dev',
  );

  /// Chave PÚBLICA (ex.: client id do OAuth). Pode ficar no app —
  /// é pública por natureza.
  static const String clientId = String.fromEnvironment(
    'CLIENT_ID',
    defaultValue: '',
  );

  static bool get ehProducao => ambiente == 'prod';
  static bool get ehDesenvolvimento => ambiente == 'dev';

  /// Falha cedo se a configuração de produção estiver incompleta.
  ///
  /// Chame no `main`: melhor quebrar no primeiro segundo do que
  /// o app rodar apontando para o servidor de desenvolvimento.
  static void validar() {
    if (ehProducao) {
      if (!apiUrl.startsWith('https://')) {
        throw StateError('Produção exige HTTPS. Recebi: $apiUrl');
      }
      if (apiUrl.contains('localhost') || apiUrl.contains('10.0.2.2')) {
        throw StateError('URL de desenvolvimento em build de produção!');
      }
      if (clientId.isEmpty) {
        throw StateError('CLIENT_ID não foi definido no build');
      }
    }
  }

  /// Resumo seguro para log — sem nenhum valor sensível.
  static Map<String, String> get resumo => <String, String>{
        'ambiente': ambiente,
        'apiUrl': apiUrl,
        // O clientId é público, mas registrar só o tamanho já basta
        // para diagnosticar "esqueci de passar a variável".
        'clientId': clientId.isEmpty ? '(vazio)' : '(${clientId.length} chars)',
      };
}
```

> **Arquivo:** `foco_desempenho/lib/core/seguranca/cofre_token.dart` (novo)

```dart
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda os tokens no cofre do sistema.
///
/// Keystore (Android) e Keychain (iOS). Módulo 10, aula 7 explica
/// o mecanismo; aqui o foco são as DECISÕES em volta dele.
class CofreToken {
  CofreToken({FlutterSecureStorage? armazenamento})
      : _cofre = armazenamento ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                // Usa o EncryptedSharedPreferences, respaldado
                // pelo Keystore do aparelho.
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                // ⚠️ first_unlock_this_device: o token NÃO vai
                // para o backup do iCloud nem para outro aparelho.
                //
                // Sem isto, o padrão do Keychain SOBREVIVE à
                // desinstalação e vai junto no backup — o usuário
                // reinstala e continua logado, o que surpreende.
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _cofre;

  static const String _chaveAcesso = 'token_acesso';
  static const String _chaveRenovacao = 'token_renovacao';
  static const String _chaveExpira = 'token_expira_em';

  Future<void> salvar({
    required String acesso,
    required String renovacao,
    required DateTime expiraEm,
  }) async {
    // ⚠️ NUNCA registre o valor do token. O logcat é legível por
    // outros apps; um token em log é um token vazado.
    dev.log(
      'Tokens salvos (expiram em ${expiraEm.toIso8601String()})',
      name: 'auth',
    );

    await Future.wait(<Future<void>>[
      _cofre.write(key: _chaveAcesso, value: acesso),
      _cofre.write(key: _chaveRenovacao, value: renovacao),
      _cofre.write(
        key: _chaveExpira,
        value: expiraEm.toIso8601String(),
      ),
    ]);
  }

  Future<String?> lerAcesso() => _cofre.read(key: _chaveAcesso);
  Future<String?> lerRenovacao() => _cofre.read(key: _chaveRenovacao);

  Future<DateTime?> lerExpiracao() async {
    final String? bruto = await _cofre.read(key: _chaveExpira);
    if (bruto == null) return null;
    return DateTime.tryParse(bruto);
  }

  /// O token está válido — com folga de 1 minuto.
  ///
  /// A folga evita a corrida em que o token expira entre a
  /// verificação e a chegada da requisição ao servidor.
  Future<bool> get valido async {
    final DateTime? expira = await lerExpiracao();
    if (expira == null) return false;
    return DateTime.now().isBefore(
      expira.subtract(const Duration(minutes: 1)),
    );
  }

  /// Apaga tudo — o botão "Sair".
  ///
  /// ⭐ Esta é a proteção que cobre a ameaça MAIS PROVÁVEL:
  /// alguém pegando o celular destravado. Vale mais que
  /// qualquer técnica sofisticada.
  Future<void> limpar() async {
    await _cofre.deleteAll();
    dev.log('Sessão encerrada, cofre limpo', name: 'auth');
  }

  /// Lê a data de expiração de DENTRO do JWT, sem validar a
  /// assinatura.
  ///
  /// ⚠️ Serve só para decidir QUANDO renovar. A validação de
  /// verdade é do servidor — confiar no conteúdo de um JWT
  /// não verificado para autorizar algo é uma falha grave.
  static DateTime? expiracaoDoJwt(String jwt) {
    try {
      final List<String> partes = jwt.split('.');
      if (partes.length != 3) return null;

      // base64Url sem padding: normalize antes de decodificar.
      final String corpo = utf8.decode(
        base64Url.decode(base64Url.normalize(partes[1])),
      );
      final Object? dados = jsonDecode(corpo);
      if (dados is! Map<String, Object?>) return null;

      final Object? exp = dados['exp'];
      if (exp is! int) return null;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (_) {
      // Token malformado: trate como inválido, nunca como válido.
      return null;
    }
  }
}
```

> **Arquivo:** `foco_desempenho/lib/features/materias/data/materia_dao.dart` (novo)

```dart
import 'package:sqflite/sqflite.dart';

import '../domain/materia.dart';

/// Acesso ao banco, à prova de injeção de SQL.
///
/// Todo valor que vem de fora passa por `?` + whereArgs.
/// Nenhuma interpolação de string numa query, em lugar nenhum.
class MateriaDao {
  MateriaDao(this._db);

  final Database _db;

  /// Colunas permitidas para ordenação.
  ///
  /// ⚠️ Nome de coluna NÃO pode ser parâmetro no SQL — `?` só
  /// vale para VALORES. Por isso a única defesa possível é uma
  /// lista fixa de nomes permitidos.
  static const Set<String> _colunasOrdenaveis = <String>{
    'nome_ordenacao',
    'minutos',
    'criada_em',
  };

  /// Busca por nome — o caso clássico de injeção.
  Future<List<Materia>> buscar(String termo) async {
    // ✅ O `?` garante que o termo NUNCA é interpretado como SQL.
    // Mesmo que ele seja: '; DROP TABLE materias; --
    final List<Map<String, Object?>> linhas = await _db.query(
      'materias',
      where: 'nome_ordenacao LIKE ?',
      // O % faz parte do VALOR, não da query — por isso vai aqui.
      whereArgs: <Object?>['%${_paraOrdenacao(termo)}%'],
      orderBy: 'nome_ordenacao ASC',
      limit: 100,
    );

    return linhas.map(Materia.doMapa).toList();
  }

  /// Lista com ordenação escolhida pelo usuário.
  Future<List<Materia>> listar({
    String ordenarPor = 'nome_ordenacao',
    bool crescente = true,
  }) async {
    // ⭐ A validação contra a lista fixa é a ÚNICA proteção aqui.
    // Sem ela, `ordenarPor` iria direto para o SQL.
    if (!_colunasOrdenaveis.contains(ordenarPor)) {
      throw ArgumentError.value(
        ordenarPor,
        'ordenarPor',
        'Coluna não permitida. Use uma de: $_colunasOrdenaveis',
      );
    }

    final List<Map<String, Object?>> linhas = await _db.query(
      'materias',
      orderBy: '$ordenarPor ${crescente ? 'ASC' : 'DESC'}',
    );

    return linhas.map(Materia.doMapa).toList();
  }

  /// Insere — o mapa é parametrizado pelo sqflite, é seguro.
  Future<int> inserir(Materia m) async {
    return _db.insert(
      'materias',
      <String, Object?>{
        'id': m.id,
        'nome': m.nome,
        'nome_ordenacao': _paraOrdenacao(m.nome),
        'minutos': m.minutosEstudados,
        'criada_em': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> excluir(String id) async {
    return _db.delete(
      'materias',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  /// Vários ids de uma vez.
  ///
  /// ⚠️ `IN (?)` com uma lista NÃO funciona: é preciso gerar um
  /// `?` por item. Os PLACEHOLDERS são gerados pelo código (seguro);
  /// os VALORES vão em whereArgs (seguro).
  Future<int> excluirVarios(List<String> ids) async {
    if (ids.isEmpty) return 0;

    final String marcadores = List<String>.filled(ids.length, '?').join(',');

    return _db.delete(
      'materias',
      where: 'id IN ($marcadores)',
      whereArgs: ids,
    );
  }

  /// Achata acentos e caixa, para ORDER BY e LIKE funcionarem
  /// em português. Módulo 10, aula 4.
  static String _paraOrdenacao(String s) {
    const String comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const String semAcento = 'aaaaaeeeeiiiiooooouuuucn';

    String r = s.toLowerCase();
    for (int i = 0; i < comAcento.length; i++) {
      r = r.replaceAll(comAcento[i], semAcento[i]);
    }
    return r;
  }
}
```

E o `.gitignore`:

> **Arquivo:** `foco_desempenho/.gitignore` (acrescentar)

```gitignore
# ── Segredos: NUNCA versionar ─────────────────────────────────
config/dev.json
config/prod.json
config/*.json
!config/exemplo.json          # o exemplo SEM valores vai para o Git

*.env
.env*
!.env.example

# ── Assinatura Android (Módulo 15) ────────────────────────────
android/key.properties
*.jks
*.keystore

# ── Assinatura iOS (Módulo 16) ────────────────────────────────
ios/Runner/GoogleService-Info.plist
*.mobileprovision
*.p12
*.cer

# ── Símbolos de ofuscação (aula 7) ────────────────────────────
# ⚠️ Não vão para o Git, mas PRECISAM ser guardados em outro
# lugar seguro — sem eles, nenhum crash de produção é legível.
build/simbolos/
```

```powershell
flutter run --dart-define-from-file=config/dev.json
flutter build apk --release --dart-define-from-file=config/prod.json
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| Comentário "TUDO aqui vai para o binário" | Deixa explícito que `--dart-define` é **configuração**, não segredo. |
| `String.fromEnvironment` em `const` | Fora de `const`, devolve o padrão **silenciosamente** — bug sem erro. |
| `ConfigApp.validar()` | Falha no primeiro segundo em vez de rodar apontando para o servidor errado. |
| `resumo` sem valores sensíveis | Diagnóstico sem vazar nada no log. |
| `encryptedSharedPreferences: true` | Respaldo do Keystore no Android. |
| `first_unlock_this_device` | **Impede o token de ir para o backup do iCloud** e para outro aparelho. |
| `dev.log` sem o valor do token | O logcat é legível por outros apps; token em log é token vazado. |
| Folga de 1 minuto em `valido` | Evita a corrida em que o token expira entre a checagem e a chegada ao servidor. |
| `limpar()` | Cobre a ameaça **mais provável**: celular destravado nas mãos erradas. |
| `expiracaoDoJwt` com aviso | Serve para decidir **quando renovar**; autorizar com JWT não verificado é falha grave. |
| `catch (_) => null` no JWT | Token malformado é tratado como inválido, nunca como válido. |
| `whereArgs` em toda query | O valor nunca é interpretado como SQL — e resolve apóstrofo de brinde. |
| `'%${...}%'` dentro do `whereArgs` | O `%` faz parte do **valor**, não da query. |
| `_colunasOrdenaveis` | Nome de coluna **não pode** ser `?`; lista fixa é a única defesa. |
| `List.filled(n, '?').join(',')` | `IN (?)` com lista não funciona; um `?` por item. |
| `!config/exemplo.json` no `.gitignore` | Versiona a **forma**, nunca os valores. |
| `build/simbolos/` ignorado **com aviso** | Fora do Git, mas guardado — sem eles, nenhum crash é legível (aula 7). |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Cofre | Keystore | Keychain |
| Sobrevive à desinstalação | ❌ Não | ⚠️ **Sim**, por padrão |
| Vai para o backup | Depende | ⚠️ iCloud, por padrão |
| HTTP bloqueado | Desde o Android 9 | Desde o iOS 9 (ATS) |
| Liberar HTTP | `usesCleartextTraffic` | `NSAppTransportSecurity` |
| Extrair o app | ✅ Trivial (APK = ZIP) | ⚠️ Exige aparelho com jailbreak |
| Backup local | `android:allowBackup` | — |

```xml
<!-- Impede o backup automático de levar dados do app. -->
<application
    android:allowBackup="false"
    android:usesCleartextTraffic="false"
    …>
```

> ⚠️ **O Keychain sobrevive à desinstalação.** O usuário apaga o app, reinstala, e continua logado —
> comportamento que surpreende e, em aparelho compartilhado, é falha de segurança. Por isso o
> `first_unlock_this_device` no código acima; e vale apagar o cofre na primeira execução após uma
> instalação limpa, detectada por uma flag em `SharedPreferences` (que **não** sobrevive).

---

## ⚠️ Erros comuns

### 1. Chave secreta no código

```dart
const String apiSecret = 'sk_live_...';   // ❌ público
```

**Correção:** a chave mora no servidor.

### 2. Achar que `--dart-define` esconde

**Correção:** ele tira do Git, não do binário.

### 3. Achar que ofuscação protege strings

**Correção:** embaralha **nomes**; strings continuam legíveis.

### 4. Token em `SharedPreferences`

Vai para o backup, em texto simples.

**Correção:** `flutter_secure_storage`.

### 5. `print` de token

Visível no logcat para outros apps.

**Correção:** registre o evento, não o valor.

### 6. `rawQuery` com interpolação

Injeção de SQL — e quebra com apóstrofo.

**Correção:** `whereArgs`.

### 7. Nome de coluna vindo do usuário

`?` não vale para identificadores.

**Correção:** lista fixa de permitidos.

### 8. `NSAllowsArbitraryLoads: true`

Desliga a proteção do app inteiro.

**Correção:** libere só o host local, só em debug.

### 9. Guardar a senha do usuário

**Correção:** guarde o token; a senha não precisa ficar.

### 10. Criptografia própria

**Correção:** bibliotecas auditadas.

### 11. Apagar o commit e achar que resolveu

**Correção:** **revogue primeiro**; limpar o histórico é higiene.

### 12. Pinning sem plano de rotação

O app quebra quando o certificado é renovado.

**Correção:** só com reserva fixada e plano.

### 13. `String.fromEnvironment` fora de `const`

Devolve o padrão sem erro nenhum.

**Correção:** sempre em contexto `const`.

---

## 🛠️ Exercício guiado

**Passo 1.** Ponha `const String chave = 'sk_live_TESTE';` no app e rode
`flutter build apk --release`.

**Passo 2.** Extraia o APK e ache a string. Quanto tempo levou?

**Passo 3.** Rebuild com `--obfuscate`. A string continua lá?

**Passo 4.** Crie `config/dev.json` e `config/exemplo.json`. Ponha o primeiro no `.gitignore`.

**Passo 5.** Rode com `--dart-define-from-file` e confirme que a URL mudou.

**Passo 6.** Chame `String.fromEnvironment` **fora** de um `const`. Que valor sai?

**Passo 7.** Escreva uma busca com `rawQuery` interpolado e passe `'; DROP TABLE materias; --`.

**Passo 8.** Troque por `whereArgs` e repita. O que muda?

**Passo 9.** Busque por `D'Ávila` nas duas versões. A interpolada sobrevive?

**Passo 10.** Salve um token com `CofreToken` e rode `adb backup`. Ele aparece no backup?

---

## 📝 Exercícios independentes

→ Exercícios completos em
[exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md)

Faça os de **Aplicação** (configuração por ambiente), **Correção de bugs** (injeção de SQL) e
**Reflexão** (modelo de ameaça do seu app).

---

## 🏆 Desafio opcional

Faça uma **auditoria de segurança** do seu app e escreva o relatório.

Requisitos:

- Extraia o APK release e procure por: chaves, URLs internas, e-mails, tokens de teste.
- Liste todo dado que o app guarda, onde guarda, e classifique: sensível ou não.
- Verifique se algum token aparece no `adb logcat` durante um login.
- Confirme que todas as queries usam `whereArgs` (busque por `rawQuery` no projeto).
- Confirme que HTTPS está obrigatório nas duas plataformas.
- Escreva um **modelo de ameaça**: quem ataca, o que quer, o que você faz a respeito — e o que
  você **decide não** proteger, com justificativa.
- Um `SEGURANCA.md` versionado com tudo isso.

Depois responda: qual ameaça do seu modelo você **não** consegue mitigar? Por que aceitar
conscientemente um risco é melhor que fingir que ele não existe?

---

## 📌 Resumo

- **Nada dentro do app é secreto.** Extrair um APK e ler as strings leva cinco minutos.
- **`--dart-define` não esconde nada**: ele tira o valor do **Git**, não do binário.
- Ofuscação embaralha **nomes**, não strings literais.
- **Se a chave é secreta, ela mora no servidor.** Não há atalho em nenhuma tecnologia móvel.
- Pode ficar no app: URL, chave **pública**, client id, chave **restrita**. Nunca: `sk_...`, senha
  de banco, token de serviço.
- **Modele a ameaça antes de proteger.** A mais provável é a mais banal: celular destravado.
- Token e dado sensível no **cofre do sistema**; preferência e cache em `SharedPreferences`/sqflite.
- 🍎 **O Keychain sobrevive à desinstalação** e vai para o iCloud — use `first_unlock_this_device`.
- **Nunca registre token em log**: o logcat é legível por outros apps.
- **`whereArgs` em toda query.** É segurança **e** correção — resolve o apóstrofo de brinde.
- Nome de tabela e coluna **não pode ser parâmetro**: valide contra lista fixa.
- **HTTPS obrigatório**; nunca `NSAllowsArbitraryLoads: true` para "funcionar".
- **Pinning** só com plano de rotação — certificado renovado derruba todo mundo.
- Vazou? **Revogue primeiro.** Apagar o commit não desfaz nada.
- Nunca escreva criptografia própria; nunca guarde a senha do usuário.

---

## ☑️ Checklist de domínio

- [ ] Sei extrair um APK e ler suas strings.
- [ ] Entendo que `--dart-define` não é segredo.
- [ ] Nenhuma chave secreta está no meu código.
- [ ] Sei o que pode e o que não pode ficar no app.
- [ ] Fiz o modelo de ameaça do meu app.
- [ ] Guardo token no cofre do sistema.
- [ ] Configurei o comportamento do Keychain no iOS.
- [ ] Nunca registro token em log.
- [ ] Todas as minhas queries usam `whereArgs`.
- [ ] Valido nome de coluna contra lista fixa.
- [ ] HTTPS obrigatório nas duas plataformas.
- [ ] Meu `.gitignore` cobre config, keystore e certificados.
- [ ] Sei o que fazer se um segredo vazar — e em que ordem.

---

## 📚 Referências oficiais

- [Security false positives — docs.flutter.dev](https://docs.flutter.dev/security)
- [Obfuscating Dart code — docs.flutter.dev](https://docs.flutter.dev/deployment/obfuscate)
- [flutter_secure_storage — pub.dev](https://pub.dev/packages/flutter_secure_storage)
- [Network security configuration — developer.android.com](https://developer.android.com/privacy-and-security/security-config)
- [App Transport Security — developer.apple.com](https://developer.apple.com/documentation/security/preventing-insecure-network-connections)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [OWASP MASVS](https://mas.owasp.org/MASVS/)
- [sqflite — pub.dev](https://pub.dev/packages/sqflite)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 5 — Acessibilidade](05-acessibilidade.md) | [README](README.md) | [Aula 7 — Ofuscação e o que evitar](07-ofuscacao-e-o-que-evitar.md) |
