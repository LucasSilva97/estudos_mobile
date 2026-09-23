# Aula 2 — shared_preferences

> **Módulo:** 10 - Persistência de Dados · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Obter uma instância de `SharedPreferences` com `getInstance` e entender por que ela é assíncrona.
- Gravar e ler `int`, `String`, `bool`, `double` e `List<String>`.
- Tratar o caso "a chave nunca foi gravada" com valor padrão, sem `null` vazando pelo app.
- Remover uma chave com `remove` e limpar tudo com `clear`, sabendo a diferença.
- Guardar um objeto inteiro como JSON dentro de uma `String` — e saber quando isso é abuso.
- Explicar as três limitações reais: não é banco, não é seguro, não serve para lista grande.
- Dizer onde o dado é gravado de verdade em 🤖 Android e 🍎 iOS.
- Testar toda a camada no Windows com `SharedPreferences.setMockInitialValues`.

## ✅ Pré-requisitos

- [Aula 1 — Qual armazenamento usar](01-qual-armazenamento-usar.md), com o projeto `foco_dados`
  criado e as dependências instaladas.
- `async`/`await` — [04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md).
- JSON — [09 — JSON](../09-consumo-de-api/02-json.md).

---

## 📖 Conceito

`shared_preferences` é um pacote oficial do time Flutter que guarda pares **chave → valor** no
armazenamento nativo de preferências de cada plataforma. "Chave" é um texto que identifica o
valor (`'meta_semanal_minutos'`); "valor" é um dado simples.

Ele aceita exatamente **cinco** tipos, e só esses cinco:

| Tipo Dart | Gravar | Ler |
|---|---|---|
| `int` | `setInt(chave, valor)` | `getInt(chave)` → `int?` |
| `double` | `setDouble(chave, valor)` | `getDouble(chave)` → `double?` |
| `bool` | `setBool(chave, valor)` | `getBool(chave)` → `bool?` |
| `String` | `setString(chave, valor)` | `getString(chave)` → `String?` |
| `List<String>` | `setStringList(chave, valor)` | `getStringList(chave)` → `List<String>?` |

Repare que **todo `get` devolve um tipo anulável**. Isso não é descuido de API: é a forma de a
biblioteca dizer "essa chave nunca foi gravada". `null` aqui significa **ausência**, não "valor
zero". Confundir os dois é o erro número um do módulo — `0` minutos de meta é uma escolha do
usuário; `null` é "o usuário nunca escolheu".

### Por que `getInstance()` é assíncrono

```dart
final prefs = await SharedPreferences.getInstance();
```

Na primeira chamada, o pacote conversa com o código nativo (Kotlin no Android, Swift no iOS) por
um **canal de plataforma** (*platform channel* — o mecanismo pelo qual o código Dart pede algo ao
código nativo), lê o arquivo de preferências inteiro e o mantém em memória. Isso é entrada e saída
de disco, e no Flutter toda entrada e saída é assíncrona para não travar a interface.

Depois da primeira chamada, as leituras (`getInt`, `getString`…) são **síncronas**, porque saem da
cópia em memória. As escritas (`setInt`, `setString`…) devolvem `Future<bool>`, porque escrevem no
disco — mas a cópia em memória é atualizada na hora.

> O pacote também oferece as APIs mais recentes `SharedPreferencesAsync` e
> `SharedPreferencesWithCache`. Este curso usa `getInstance()` porque é a forma que você vai
> encontrar em 99% do código e da documentação existente, e porque ela é suficiente para tudo que
> o Foco precisa.

---

## 💡 Analogia

`shared_preferences` é o **quadro de avisos da porta da geladeira**. Cabe um ímã por recado, o
recado é curto, qualquer pessoa da casa lê num relance e ninguém guarda o extrato bancário ali.
Quando você chega em casa, olha o quadro inteiro de uma vez (`getInstance`) e depois consulta cada
recado sem esforço.

O limite da analogia: o quadro da geladeira é público para a casa; o `shared_preferences` é
privado para o seu app — mas **não é criptografado**. É como um quadro dentro do seu quarto com a
porta fechada: ninguém de fora entra, mas quem entrar lê tudo.

---

## 🧪 Exemplo mínimo

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> exemplo() async {
  final prefs = await SharedPreferences.getInstance();

  // Gravar
  await prefs.setInt('meta_semanal_minutos', 600);
  await prefs.setString('tema', 'escuro');
  await prefs.setBool('primeira_execucao_concluida', true);
  await prefs.setStringList('materias_fixadas', <String>['calculo', 'fisica']);

  // Ler com valor padrão
  final meta = prefs.getInt('meta_semanal_minutos') ?? 300;
  final tema = prefs.getString('tema') ?? 'sistema';
  final fixadas = prefs.getStringList('materias_fixadas') ?? <String>[];

  // Existe?
  final jaConfigurou = prefs.containsKey('meta_semanal_minutos');

  // Apagar uma chave / apagar tudo
  await prefs.remove('tema');
  await prefs.clear();

  print('$meta $tema $fixadas $jaConfigurou');
}
```

Três detalhes que já valem a aula:

- `?? 300` é o operador **"se for nulo, use isto"**. Ele transforma `int?` em `int` e é o jeito
  correto de dar um valor padrão.
- `containsKey` responde "essa chave existe?" sem te obrigar a comparar com `null`. Use quando a
  ausência tem significado próprio (por exemplo, "nunca mostrei o tutorial").
- `clear()` apaga **todas** as chaves do seu app — inclusive as que outro pacote gravou lá dentro.
  Use com cuidado; quase sempre o certo é `remove` das chaves que são suas.

---

## 📱 Aplicando no Flutter

O Foco guarda em preferências as **metas e ajustes** do usuário:

| Chave | Tipo | Significado |
|---|---|---|
| `meta_semanal_minutos` | `int` | quantos minutos por semana a pessoa quer estudar |
| `modo_de_tema` | `String` | `claro`, `escuro` ou `sistema` |
| `notificar_meta_atingida` | `bool` | avisar quando bater a meta |
| `materias_fixadas` | `List<String>` | ids das matérias fixadas no topo |
| `preferencias_de_sessao` | `String` (JSON) | objeto com duração padrão, pausa e som |

As quatro primeiras são diretas. A quinta merece explicação: `preferencias_de_sessao` é um
**objeto** com três campos. `shared_preferences` não sabe gravar objeto, mas sabe gravar `String`.
Então você converte o objeto em JSON (*JavaScript Object Notation* — o formato de texto que você
já usou no módulo 09), grava o texto, e na leitura faz o caminho de volta.

Isso é legítimo **para um objeto pequeno e único**. Não é legítimo para uma lista que cresce: veja
a seção de limitações.

### A regra de arquitetura desta aula

Nenhum widget do Foco vai chamar `SharedPreferences.getInstance()`. Em vez disso, existe um
**repositório** — uma classe cuja única função é traduzir entre o mundo do app (`Meta`,
`ModoDeTema`) e o mundo do armazenamento (chaves e tipos primitivos).

```text
tela  →  controller  →  MetaRepositorio  →  SharedPreferences
```

O repositório **recebe** a instância de `SharedPreferences` pelo construtor. É o mesmo princípio
de [08 — Injeção de dependências](../08-estado-e-arquitetura/10-injecao-de-dependencias.md): quem
recebe suas dependências pode ser testado; quem as cria por dentro, não.

---

## 💻 Código completo

> **Arquivo:** `foco_dados/lib/features/metas/data/meta_repositorio.dart`
> **Como executar:** `flutter test test/meta_repositorio_test.dart`

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Como o usuário quer ver o app.
enum ModoDeTema { claro, escuro, sistema }

/// Objeto pequeno e único, guardado como JSON dentro de uma String.
///
/// Cabe aqui porque é UM objeto de configuração, não uma coleção que cresce.
class PreferenciasDeSessao {
  const PreferenciasDeSessao({
    this.duracaoPadraoMinutos = 25,
    this.pausaMinutos = 5,
    this.somAoTerminar = true,
  });

  final int duracaoPadraoMinutos;
  final int pausaMinutos;
  final bool somAoTerminar;

  /// Reconstrói o objeto a partir do mapa vindo do JSON.
  ///
  /// Cada campo tem valor padrão: se a versão antiga do app gravou um JSON
  /// sem o campo novo, a leitura continua funcionando em vez de quebrar.
  factory PreferenciasDeSessao.doMapa(Map<String, Object?> mapa) {
    return PreferenciasDeSessao(
      duracaoPadraoMinutos: mapa['duracaoPadraoMinutos'] as int? ?? 25,
      pausaMinutos: mapa['pausaMinutos'] as int? ?? 5,
      somAoTerminar: mapa['somAoTerminar'] as bool? ?? true,
    );
  }

  Map<String, Object?> paraMapa() => <String, Object?>{
    'duracaoPadraoMinutos': duracaoPadraoMinutos,
    'pausaMinutos': pausaMinutos,
    'somAoTerminar': somAoTerminar,
  };

  PreferenciasDeSessao copyWith({
    int? duracaoPadraoMinutos,
    int? pausaMinutos,
    bool? somAoTerminar,
  }) {
    return PreferenciasDeSessao(
      duracaoPadraoMinutos: duracaoPadraoMinutos ?? this.duracaoPadraoMinutos,
      pausaMinutos: pausaMinutos ?? this.pausaMinutos,
      somAoTerminar: somAoTerminar ?? this.somAoTerminar,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PreferenciasDeSessao &&
      other.duracaoPadraoMinutos == duracaoPadraoMinutos &&
      other.pausaMinutos == pausaMinutos &&
      other.somAoTerminar == somAoTerminar;

  @override
  int get hashCode =>
      Object.hash(duracaoPadraoMinutos, pausaMinutos, somAoTerminar);
}

/// Única porta de entrada do app para as preferências do usuário.
///
/// Recebe o [SharedPreferences] pronto pelo construtor: isso permite testar
/// a classe inteira sem plugin nativo, sem emulador e sem aparelho.
class MetaRepositorio {
  const MetaRepositorio(this._prefs);

  final SharedPreferences _prefs;

  // As chaves ficam em constantes privadas. Digitar 'meta_semanal_minutos'
  // à mão em dois lugares é como o dado some sem ninguém entender por quê.
  static const String _kMetaSemanal = 'meta_semanal_minutos';
  static const String _kModoDeTema = 'modo_de_tema';
  static const String _kNotificar = 'notificar_meta_atingida';
  static const String _kMateriasFixadas = 'materias_fixadas';
  static const String _kPreferenciasSessao = 'preferencias_de_sessao';

  /// Valor usado quando o usuário nunca escolheu uma meta: 5 h por semana.
  static const int metaPadraoMinutos = 300;

  // ---------------------------------------------------------------- int
  int lerMetaSemanalMinutos() =>
      _prefs.getInt(_kMetaSemanal) ?? metaPadraoMinutos;

  Future<void> salvarMetaSemanalMinutos(int minutos) async {
    if (minutos < 0) {
      throw ArgumentError.value(minutos, 'minutos', 'não pode ser negativo');
    }
    await _prefs.setInt(_kMetaSemanal, minutos);
  }

  /// Diferente de "a meta é zero": responde se o usuário JÁ escolheu alguma.
  bool usuarioJaDefiniuMeta() => _prefs.containsKey(_kMetaSemanal);

  // ------------------------------------------------------------- String
  ModoDeTema lerModoDeTema() {
    final texto = _prefs.getString(_kModoDeTema);
    return switch (texto) {
      'claro' => ModoDeTema.claro,
      'escuro' => ModoDeTema.escuro,
      _ => ModoDeTema.sistema,
    };
  }

  Future<void> salvarModoDeTema(ModoDeTema modo) =>
      _prefs.setString(_kModoDeTema, modo.name);

  // --------------------------------------------------------------- bool
  bool lerNotificarMetaAtingida() => _prefs.getBool(_kNotificar) ?? true;

  Future<void> salvarNotificarMetaAtingida(bool ativo) =>
      _prefs.setBool(_kNotificar, ativo);

  // --------------------------------------------------- List<String>
  List<String> lerMateriasFixadas() =>
      _prefs.getStringList(_kMateriasFixadas) ?? const <String>[];

  Future<void> fixarMateria(String id) async {
    final atuais = lerMateriasFixadas();
    if (atuais.contains(id)) return;
    await _prefs.setStringList(_kMateriasFixadas, <String>[...atuais, id]);
  }

  Future<void> desafixarMateria(String id) async {
    final restantes = lerMateriasFixadas().where((e) => e != id).toList();
    await _prefs.setStringList(_kMateriasFixadas, restantes);
  }

  // ------------------------------------------------- objeto como JSON
  PreferenciasDeSessao lerPreferenciasDeSessao() {
    final texto = _prefs.getString(_kPreferenciasSessao);
    if (texto == null || texto.isEmpty) {
      return const PreferenciasDeSessao();
    }
    try {
      final decodificado = jsonDecode(texto);
      if (decodificado is! Map<String, Object?>) {
        return const PreferenciasDeSessao();
      }
      return PreferenciasDeSessao.doMapa(decodificado);
    } on FormatException {
      // JSON corrompido (o app morreu no meio da gravação, por exemplo).
      // Voltar ao padrão é melhor do que deixar o app travar na abertura.
      return const PreferenciasDeSessao();
    }
  }

  Future<void> salvarPreferenciasDeSessao(PreferenciasDeSessao prefs) =>
      _prefs.setString(_kPreferenciasSessao, jsonEncode(prefs.paraMapa()));

  // ------------------------------------------------------------ limpeza
  /// Apaga só o que é responsabilidade deste repositório.
  Future<void> limparAjustes() async {
    await _prefs.remove(_kMetaSemanal);
    await _prefs.remove(_kModoDeTema);
    await _prefs.remove(_kNotificar);
    await _prefs.remove(_kMateriasFixadas);
    await _prefs.remove(_kPreferenciasSessao);
  }
}
```

O teste, rodando no Windows sem emulador:

> **Arquivo:** `foco_dados/test/meta_repositorio_test.dart`
> **Como executar:** `flutter test test/meta_repositorio_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_dados/features/metas/data/meta_repositorio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Necessário porque SharedPreferences fala com o código nativo por um
  // canal de plataforma, e o canal falso só existe com o binding iniciado.
  TestWidgetsFlutterBinding.ensureInitialized();

  late MetaRepositorio repositorio;

  setUp(() async {
    // Estado inicial do "disco" para ESTE teste. Sem plugin nativo.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    repositorio = MetaRepositorio(prefs);
  });

  group('meta semanal', () {
    test('sem nada gravado devolve o padrão de 300 minutos', () {
      expect(repositorio.lerMetaSemanalMinutos(), 300);
      expect(repositorio.usuarioJaDefiniuMeta(), isFalse);
    });

    test('grava e lê', () async {
      await repositorio.salvarMetaSemanalMinutos(600);
      expect(repositorio.lerMetaSemanalMinutos(), 600);
      expect(repositorio.usuarioJaDefiniuMeta(), isTrue);
    });

    test('zero é um valor válido e diferente de ausência', () async {
      await repositorio.salvarMetaSemanalMinutos(0);
      expect(repositorio.lerMetaSemanalMinutos(), 0);
      expect(repositorio.usuarioJaDefiniuMeta(), isTrue);
    });

    test('recusa valor negativo', () {
      expect(
        () => repositorio.salvarMetaSemanalMinutos(-1),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('modo de tema', () {
    test('padrão é sistema', () {
      expect(repositorio.lerModoDeTema(), ModoDeTema.sistema);
    });

    test('grava e lê escuro', () async {
      await repositorio.salvarModoDeTema(ModoDeTema.escuro);
      expect(repositorio.lerModoDeTema(), ModoDeTema.escuro);
    });

    test('texto desconhecido no disco não derruba o app', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'modo_de_tema': 'roxo_neon',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(MetaRepositorio(prefs).lerModoDeTema(), ModoDeTema.sistema);
    });
  });

  group('matérias fixadas', () {
    test('lista vazia por padrão', () {
      expect(repositorio.lerMateriasFixadas(), isEmpty);
    });

    test('fixar não duplica', () async {
      await repositorio.fixarMateria('calculo');
      await repositorio.fixarMateria('calculo');
      expect(repositorio.lerMateriasFixadas(), <String>['calculo']);
    });

    test('desafixar remove só o pedido', () async {
      await repositorio.fixarMateria('calculo');
      await repositorio.fixarMateria('fisica');
      await repositorio.desafixarMateria('calculo');
      expect(repositorio.lerMateriasFixadas(), <String>['fisica']);
    });
  });

  group('preferências de sessão em JSON', () {
    test('padrão quando nunca foi gravado', () {
      expect(
        repositorio.lerPreferenciasDeSessao(),
        const PreferenciasDeSessao(),
      );
    });

    test('grava e lê o objeto inteiro', () async {
      const novas = PreferenciasDeSessao(
        duracaoPadraoMinutos: 50,
        pausaMinutos: 10,
        somAoTerminar: false,
      );
      await repositorio.salvarPreferenciasDeSessao(novas);
      expect(repositorio.lerPreferenciasDeSessao(), novas);
    });

    test('JSON corrompido volta ao padrão em vez de quebrar', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'preferencias_de_sessao': '{isso não é json',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(
        MetaRepositorio(prefs).lerPreferenciasDeSessao(),
        const PreferenciasDeSessao(),
      );
    });
  });

  test('limparAjustes apaga só as chaves do repositório', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'meta_semanal_minutos': 600,
      'chave_de_outro_modulo': 'preservar',
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = MetaRepositorio(prefs);

    await repo.limparAjustes();

    expect(repo.lerMetaSemanalMinutos(), 300);
    expect(prefs.getString('chave_de_outro_modulo'), 'preservar');
  });
}
```

Saída esperada:

```text
00:03 +12: All tests passed!
```

---

## 🔍 Explicando o código

- **`const MetaRepositorio(this._prefs);`** — o repositório é imutável e não tem estado próprio.
  Todo estado mora no `SharedPreferences` que ele recebeu.
- **Chaves em `static const`** — o compilador passa a te proteger de erro de digitação. Se você
  escrever `_kMetSemanal`, o código nem compila; se você tivesse escrito a string errada, o app
  compilaria e perderia o dado silenciosamente.
- **`switch` como expressão em `lerModoDeTema`** — o caso `_ =>` (curinga) cobre `null`, texto
  desconhecido e qualquer lixo que apareça no disco. **Sempre** trate o disco como fonte hostil:
  o conteúdo pode ter sido gravado por uma versão anterior do seu app.
- **`modo.name`** — todo `enum` do Dart tem a propriedade `name`, que devolve o nome do valor como
  `String` (`ModoDeTema.escuro.name` é `'escuro'`). É mais seguro do que gravar `index`, porque
  reordenar o `enum` não estraga os dados já gravados.
- **`<String>[...atuais, id]`** — o operador de espalhamento (`...`) cria uma **lista nova** com os
  itens existentes mais o novo. `shared_preferences` não observa mutações na lista que você leu:
  ele só grava o que você entregar a `setStringList`.
- **`on FormatException`** em `lerPreferenciasDeSessao` — `jsonDecode` lança `FormatException`
  quando o texto não é JSON válido. Sem esse `catch`, um arquivo corrompido impediria o app de
  abrir. Voltar ao padrão é degradação graciosa.
- **`if (decodificado is! Map<String, Object?>)`** — `jsonDecode` devolve `Object?`. Se alguém
  gravou `"[1,2,3]"` naquela chave, o resultado é uma `List`, e o `as Map` daria erro em tempo de
  execução. A checagem de tipo evita isso.
- **`setMockInitialValues`** no teste substitui o plugin nativo por um mapa em memória. É por isso
  que 12 testes de persistência rodam no seu Windows, sem emulador.
- **`TestWidgetsFlutterBinding.ensureInitialized()`** inicia o ambiente de teste do Flutter. Sem
  ele, o canal de plataforma falso não existe e o teste falha ao chamar `getInstance`.

---

## 🤖🍎 Android × iOS

Há diferença real no local e no formato do arquivo, e ela importa quando você precisa depurar
"por que o valor não gravou".

### 🤖 Android

O valor vai para um arquivo XML dentro do sandbox do app:

```text
/data/data/<applicationId>/shared_prefs/FlutterSharedPreferences.xml
```

O conteúdo tem esta cara (as chaves recebem o prefixo `flutter.`):

```xml
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <int name="flutter.meta_semanal_minutos" value="600" />
    <string name="flutter.modo_de_tema">escuro</string>
    <boolean name="flutter.notificar_meta_atingida" value="true" />
</map>
```

Duas consequências práticas:

1. O prefixo `flutter.` é adicionado pelo pacote. Se um módulo nativo Kotlin do seu app precisar
   ler a mesma chave, ele tem que procurar por `flutter.modo_de_tema`, não por `modo_de_tema`.
2. **É texto legível.** Em um aparelho com acesso administrativo (*root*), qualquer um lê. Nunca
   guarde segredo aqui.

Com o Android SDK instalado e um aparelho em modo de depuração, você confere assim:

```powershell
adb shell run-as br.com.estudos.foco cat shared_prefs/FlutterSharedPreferences.xml
```

### 🍎 iOS

O valor vai para o `NSUserDefaults`, o sistema de preferências da Apple, que grava um arquivo de
lista de propriedades:

```text
<sandbox do app>/Library/Preferences/<bundle-id>.plist
```

O formato é binário, mas o Xcode e o comando `plutil` mostram em texto. Como está em
`Library/Preferences`, **entra no backup do iCloud** — mais um motivo para não guardar segredo ali.

> 🍎 **SÓ NO MAC.** Abrir o `.plist` de um iPhone exige macOS + Xcode (Devices and Simulators →
> selecionar o app → *Download Container*). No Windows você pode ler e entender o processo, mas
> não executá-lo. Entenda o contexto completo em
> [16-build-ios/01-por-que-exige-macos.md](../16-build-ios/01-por-que-exige-macos.md).

### O que é igual nas duas

- Desinstalar o app **apaga** as preferências nas duas plataformas.
- A API Dart é idêntica; você não escreve um `if` de plataforma para usar o pacote.
- O tempo entre `setInt` completar e o dado estar fisicamente no disco é responsabilidade do
  sistema, não sua. Em ambas, `await` do `set` é suficiente.

---

## ⚠️ Erros comuns

1. **Esquecer o `await` do `getInstance`.**
   ```dart
   final prefs = SharedPreferences.getInstance(); // ERRADO: é um Future
   prefs.getInt('meta');                          // não compila
   ```
   O erro do analisador é claro: `The method 'getInt' isn't defined for the type 'Future<SharedPreferences>'`.

2. **Tratar `null` como zero.**
   `prefs.getInt('meta') ?? 0` faz "nunca configurou" virar "meta zero". Se essas duas situações
   têm significados diferentes na sua tela, use `containsKey` para distinguir.

3. **Chamar `clear()` achando que apaga só as suas chaves.**
   `clear()` apaga **tudo** do app, inclusive chaves de outros pacotes. Prefira `remove` chave a
   chave, como faz `limparAjustes`.

4. **Guardar uma lista que cresce.**
   ```dart
   // ERRADO: cada sessão de estudo nova reescreve TODAS as anteriores
   await prefs.setStringList('sessoes', sessoes.map(jsonEncode).toList());
   ```
   Com 30 sessões parece rápido. Com 3 000 você lê e regrava 3 000 registros a cada cronômetro
   encerrado. Isso é trabalho de banco — [aula 4](04-sqflite-criando-o-banco.md).

5. **Guardar token de acesso aqui.**
   O arquivo é texto claro e entra no backup. Token vai para o cofre —
   [aula 7](07-dados-sensiveis.md).

6. **Gravar o `index` de um `enum` em vez do `name`.**
   ```dart
   await prefs.setInt('modo', modo.index); // frágil
   ```
   No dia em que você inserir um valor no meio do `enum`, todos os aparelhos já instalados passam
   a ler o modo errado. `name` é estável.

7. **Ler direto do `SharedPreferences` dentro do `build` de um widget.**
   `build` é síncrono e pode rodar muitas vezes por segundo. Leia uma vez, guarde no estado (o
   módulo 08 mostra como) e escreva quando o usuário mudar algo.

8. **🪟 `flutter pub add shared_preferences` falhando com `requires symlink support`.**
   É o Modo de Desenvolvedor do Windows desligado. Ligue em **Configurações → Sistema → Para
   desenvolvedores** e repita o comando.

---

## 🛠️ Exercício guiado

Vamos acrescentar ao `MetaRepositorio` um contador de sessões concluídas **e** descobrir, na
prática, por que ele não deveria virar uma lista.

**Passo 1.** Adicione a chave e os métodos:

```dart
static const String _kSessoesConcluidas = 'sessoes_concluidas';

int lerSessoesConcluidas() => _prefs.getInt(_kSessoesConcluidas) ?? 0;

Future<void> registrarSessaoConcluida() async {
  await _prefs.setInt(_kSessoesConcluidas, lerSessoesConcluidas() + 1);
}
```

**Passo 2.** Escreva o teste:

```dart
test('contador de sessões começa em zero e incrementa', () async {
  expect(repositorio.lerSessoesConcluidas(), 0);
  await repositorio.registrarSessaoConcluida();
  await repositorio.registrarSessaoConcluida();
  expect(repositorio.lerSessoesConcluidas(), 2);
});
```

**Passo 3.** Rode:

```powershell
flutter test test/meta_repositorio_test.dart
```

**Passo 4 — a pergunta que importa.** Agora imagine que o produto pede: *"mostre as 10 últimas
sessões, com data, matéria e duração, e permita filtrar por matéria"*. Tente resolver com
`setStringList` e uma lista de JSONs. Escreva no papel o que você precisaria fazer para:

- inserir uma sessão nova;
- filtrar por matéria;
- pegar só as 10 mais recentes;
- corrigir a duração de uma sessão específica.

Você vai descobrir que, em todos os casos, precisa **ler tudo, desserializar tudo, processar em
Dart e regravar tudo**. Essa é a resposta empírica de por que a [aula 4](04-sqflite-criando-o-banco.md)
existe. Guarde essa anotação: ela é a justificativa da sua próxima decisão de arquitetura.

**Passo 5.** Rode a análise estática:

```powershell
flutter analyze
```

Saída esperada: `No issues found!`

---

## 📝 Exercícios independentes
→ Exercícios completos em [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md)

---

## 🏆 Desafio opcional

Implemente **versionamento das preferências**. Acrescente a chave `versao_das_preferencias`
(`int`) e um método `Future<void> migrar()` no `MetaRepositorio` que:

1. lê a versão atual (ausência = versão 0);
2. se for menor que 1, converte a chave antiga `meta_semanal_horas` (que uma versão imaginária do
   app gravava em horas) para `meta_semanal_minutos`, multiplicando por 60, e remove a antiga;
3. grava `versao_das_preferencias = 1`.

Escreva dois testes: um partindo de `setMockInitialValues({'meta_semanal_horas': 10})`, que deve
resultar em 600 minutos; e outro partindo de um estado já migrado, que não pode alterar nada.

Isso é exatamente a mesma ideia que a [aula 6](06-migracoes.md) aplica ao banco — e ver o conceito
duas vezes, em dois lugares diferentes, é o que faz ele grudar.

---

## 📌 Resumo

- `shared_preferences` guarda pares chave-valor de **cinco tipos**: `int`, `double`, `bool`,
  `String` e `List<String>`.
- `getInstance()` é assíncrono porque lê o disco; depois dele, os `get` são síncronos.
- Todo `get` devolve tipo **anulável**; `null` significa "nunca gravado", não "zero". Use `??`
  para o padrão e `containsKey` quando a ausência tiver significado próprio.
- `remove` apaga uma chave; `clear` apaga **todas** — prefira `remove`.
- Um objeto pequeno pode ir como JSON dentro de uma `String`, sempre com tratamento de
  `FormatException` na leitura.
- Três limitações reais: **não é banco** (sem consulta, filtro ou ordenação), **não é seguro**
  (texto claro, entra no backup) e **não serve para lista grande** (ler e regravar tudo a cada
  alteração).
- 🤖 Android grava em `shared_prefs/FlutterSharedPreferences.xml`, com prefixo `flutter.` nas
  chaves; 🍎 iOS grava no `NSUserDefaults`, em `Library/Preferences/<bundle-id>.plist`.
- `SharedPreferences.setMockInitialValues` permite testar toda a camada no Windows, sem emulador.

---

## ☑️ Checklist de domínio

- [ ] Escrevo `final prefs = await SharedPreferences.getInstance();` sem consultar.
- [ ] Listo os cinco tipos aceitos e digo por que não existe `setMap`.
- [ ] Explico por que os `get` devolvem tipo anulável e dou um exemplo em que `null` e `0`
      significam coisas diferentes.
- [ ] Uso `?? valorPadrao` em toda leitura.
- [ ] Sei a diferença entre `remove` e `clear` e escolho a certa.
- [ ] Gravo um `enum` usando `name`, e explico por que `index` é frágil.
- [ ] Guardo um objeto pequeno como JSON e trato `FormatException` na leitura.
- [ ] Recito as três limitações do `shared_preferences`.
- [ ] Digo onde o dado é gravado em 🤖 Android e em 🍎 iOS.
- [ ] Escrevo um teste com `setMockInitialValues` e ele passa no meu Windows.
- [ ] Meu repositório **recebe** o `SharedPreferences` pelo construtor.

---

## 📚 Referências oficiais

- [shared_preferences — pub.dev](https://pub.dev/packages/shared_preferences)
- [Store key-value data on disk — docs.flutter.dev](https://docs.flutter.dev/cookbook/persistence/key-value)
- [dart:convert — jsonEncode / jsonDecode](https://api.dart.dev/stable/dart-convert/dart-convert-library.html)
- [Enums — dart.dev](https://dart.dev/language/enums)
- [SharedPreferences — developer.android.com](https://developer.android.com/reference/android/content/SharedPreferences)
- [UserDefaults — developer.apple.com](https://developer.apple.com/documentation/foundation/userdefaults)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Qual armazenamento usar](01-qual-armazenamento-usar.md) | [README](README.md) | [Aula 3 — Arquivos e path_provider](03-arquivos-e-path-provider.md) |
