# Código completo — Projeto 02: Bloco de Notas de Estudo

> 📌 **Este arquivo é para conferir, não para copiar.** Construa o app pelo
> [02-passo-a-passo.md](02-passo-a-passo.md), com os seus erros e os seus `flutter analyze`.
> Volte aqui quando algo não bater — comparar o seu arquivo com o final é aprendizado;
> colar 17 arquivos de uma vez não é.

São 16 arquivos em `lib/` mais o `pubspec.yaml`. Todos aparecem **inteiros**: nenhum
"resto igual", nenhuma reticência. Se um método não está escrito aqui, ele não existe no projeto.

> 🪟 Tudo roda no Windows 11: `flutter run -d chrome`, `flutter run -d windows` ou um emulador
> Android. Gerar o `.ipa` para iPhone exige macOS — máquina física ou *runner* macOS em CI — e isso
> é assunto do [módulo 16](../../modulos/16-build-ios/README.md).

---

## 📁 pubspec.yaml

> **O que este arquivo faz:** declara o nome do pacote (`bloco_notas`, que vira o prefixo de todo
> `import`), a faixa do SDK e as duas únicas dependências do projeto.

```yaml
name: bloco_notas
description: "Bloco de notas de estudo — projeto 02 do curso intensivo de Flutter."
publish_to: 'none'

# 1.0.0 = versão visível (versionName 🤖 / CFBundleShortVersionString 🍎)
# +1     = número do build (versionCode 🤖 / CFBundleVersion 🍎)
version: 1.0.0+1

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  # Ícones no estilo iOS. Vem do `flutter create` e não custa nada manter.
  cupertino_icons: ^1.0.8
  # Única dependência de verdade deste projeto: o armazenamento chave-valor.
  shared_preferences: ^2.5.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  # Regras de lint oficiais, importadas pelo analysis_options.yaml.
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

> ⚠️ Nada de `http`, `intl`, `uuid`, `sqflite`, `go_router` ou `flutter_riverpod` aqui. Cada um
> desses pacotes entra em um módulo específico, e antecipá-los esconde o que este projeto quer
> ensinar. O `analysis_options.yaml` é o que o `flutter create` gerou: uma linha
> `include: package:flutter_lints/flutter.yaml`.

---

## 🧱 O domínio

### lib/features/notas/domain/etiqueta.dart

> **O que este arquivo faz:** define as cinco etiquetas possíveis de uma nota e o caminho seguro de
> voltar do JSON para o enum.

```dart
/// Classificação de uma nota. Cinco valores fixos — não é texto livre.
enum Etiqueta {
  aula('Aula'),
  resumo('Resumo'),
  duvida('Dúvida'),
  revisao('Revisão'),
  ideia('Ideia');

  const Etiqueta(this.rotulo);

  /// O que aparece na tela. O `name` (`duvida`) é o que vai para o disco.
  final String rotulo;

  /// Converte o texto gravado de volta para o enum.
  ///
  /// Nome desconhecido — JSON de uma versão antiga, ou arquivo editado na mão —
  /// vira `resumo` em vez de lançar. Nunca devolve null.
  static Etiqueta porNome(String? nome) => Etiqueta.values.firstWhere(
        (Etiqueta etiqueta) => etiqueta.name == nome,
        orElse: () => Etiqueta.resumo,
      );
}
```

### lib/features/notas/domain/ordenacao.dart

> **O que este arquivo faz:** define as três ordens da lista, com a mesma conversão segura da
> `Etiqueta` — porque a ordem escolhida também é gravada no disco.

```dart
/// Como a lista da home é ordenada. A escolha do usuário é persistida.
enum Ordenacao {
  maisRecente('Mais recentes'),
  maisAntiga('Mais antigas'),
  tituloAZ('Título A–Z');

  const Ordenacao(this.rotulo);

  /// Texto do item no `PopupMenuButton`.
  final String rotulo;

  /// Valor gravado inválido volta como `maisRecente` — o padrão do app.
  static Ordenacao porNome(String? nome) => Ordenacao.values.firstWhere(
        (Ordenacao ordenacao) => ordenacao.name == nome,
        orElse: () => Ordenacao.maisRecente,
      );
}
```

### lib/features/notas/domain/nota.dart

> **O que este arquivo faz:** o modelo imutável da nota, com serialização nos dois sentidos,
> `copyWith` e igualdade por valor.

```dart
import 'package:bloco_notas/features/notas/domain/etiqueta.dart';

/// Uma nota de estudo. Imutável: toda mudança gera um objeto novo.
class Nota {
  const Nota({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.etiqueta,
    required this.criadaEm,
    required this.atualizadaEm,
  });

  final String id;
  final String titulo;
  final String conteudo;
  final Etiqueta etiqueta;
  final DateTime criadaEm;
  final DateTime atualizadaEm;

  /// Reconstrói a nota a partir de um item do array JSON.
  ///
  /// Devolve **null** quando falta um campo obrigatório ou o tipo é outro.
  /// Não lança de propósito: assim o repositório descarta só o item ruim e
  /// continua lendo os demais (RF21).
  static Nota? doMapa(Map<String, Object?> mapa) {
    final Object? id = mapa['id'];
    final Object? titulo = mapa['titulo'];
    final Object? conteudo = mapa['conteudo'];
    final Object? criadaBruta = mapa['criadaEm'];
    final Object? atualizadaBruta = mapa['atualizadaEm'];
    final Object? etiquetaBruta = mapa['etiqueta'];

    // `is String` em vez de `as String`: teste de tipo não derruba o app.
    if (id is! String || id.isEmpty) return null;
    if (titulo is! String || titulo.trim().isEmpty) return null;
    if (conteudo is! String) return null;
    if (criadaBruta is! String || atualizadaBruta is! String) return null;

    final DateTime? criadaEm = DateTime.tryParse(criadaBruta);
    final DateTime? atualizadaEm = DateTime.tryParse(atualizadaBruta);
    if (criadaEm == null || atualizadaEm == null) return null;

    return Nota(
      id: id,
      titulo: titulo,
      conteudo: conteudo,
      // Etiqueta ausente ou desconhecida não invalida a nota: vira `resumo`.
      etiqueta: Etiqueta.porNome(etiquetaBruta is String ? etiquetaBruta : null),
      criadaEm: criadaEm,
      atualizadaEm: atualizadaEm,
    );
  }

  /// Só tipos que o `jsonEncode` aceita: String, num, bool, List e Map.
  Map<String, Object?> paraMapa() => <String, Object?>{
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'etiqueta': etiqueta.name,
        'criadaEm': criadaEm.toIso8601String(),
        'atualizadaEm': atualizadaEm.toIso8601String(),
      };

  /// `id` e `criadaEm` ficam de fora de propósito: editar uma nota nunca muda
  /// a identidade dela nem a data em que ela nasceu (RF17).
  Nota copyWith({
    String? titulo,
    String? conteudo,
    Etiqueta? etiqueta,
    DateTime? atualizadaEm,
  }) {
    return Nota(
      id: id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      etiqueta: etiqueta ?? this.etiqueta,
      criadaEm: criadaEm,
      atualizadaEm: atualizadaEm ?? this.atualizadaEm,
    );
  }

  /// Igualdade por valor: duas notas com os mesmos campos são iguais.
  /// Sem isto, `expect(lidas.first, nota)` no teste compararia endereços de
  /// memória e falharia sempre.
  @override
  bool operator ==(Object other) =>
      other is Nota &&
      other.id == id &&
      other.titulo == titulo &&
      other.conteudo == conteudo &&
      other.etiqueta == etiqueta &&
      other.criadaEm == criadaEm &&
      other.atualizadaEm == atualizadaEm;

  @override
  int get hashCode =>
      Object.hash(id, titulo, conteudo, etiqueta, criadaEm, atualizadaEm);
}
```

---

## 💾 A persistência

### lib/features/notas/data/notas_repositorio.dart

> **O que este arquivo faz:** é a única porta do app para o disco — lê e grava a lista inteira de
> notas como um array JSON dentro de uma `String`, e guarda a ordenação escolhida.

```dart
import 'dart:convert';

import 'package:bloco_notas/features/notas/domain/nota.dart';
import 'package:bloco_notas/features/notas/domain/ordenacao.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda e devolve as notas do aparelho.
///
/// Recebe o [SharedPreferences] já pronto pelo construtor: é isso que permite
/// testar a classe inteira no Windows, sem emulador e sem plugin nativo.
class NotasRepositorio {
  const NotasRepositorio(this._prefs);

  final SharedPreferences _prefs;

  // Chaves em constantes. Digitar a string à mão em dois lugares é como o dado
  // some sem ninguém entender por quê.
  static const String chaveNotas = 'bloco_notas.notas';
  static const String chaveOrdenacao = 'bloco_notas.ordenacao';

  /// Teto proposital deste armazenamento.
  ///
  /// Cada gravação reescreve o arquivo inteiro: com 200 notas de 2000
  /// caracteres já são ~400 KB regravados a cada tecla salva. Coleção que
  /// cresce sem limite é trabalho para o `sqflite` (módulo 10, aula 4).
  static const int maxNotas = 200;

  /// Lê a lista gravada. Nunca lança: arquivo corrompido devolve lista vazia.
  List<Nota> lerNotas() {
    final String? texto = _prefs.getString(chaveNotas);
    if (texto == null || texto.isEmpty) return const <Nota>[];

    Object? decodificado;
    try {
      decodificado = jsonDecode(texto);
    } on FormatException {
      // O app morreu no meio da gravação, ou alguém editou o arquivo na mão.
      // Abrir vazio é melhor do que não abrir (RF20).
      return const <Nota>[];
    }

    // Gravamos um array. Se veio outra coisa, o dado não é nosso.
    if (decodificado is! List<Object?>) return const <Nota>[];

    final List<Nota> notas = <Nota>[];
    for (final Object? item in decodificado) {
      if (item is! Map<String, Object?>) continue;
      final Nota? nota = Nota.doMapa(item);
      // Item ruim é descartado; os outros continuam valendo (RF21).
      if (nota != null) notas.add(nota);
    }
    return notas;
  }

  /// Grava a lista inteira de uma vez (RF19).
  ///
  /// Lança [ArgumentError] com id repetido — dois ids iguais quebrariam a
  /// `key` do `Dismissible` e a edição passaria a alterar a nota errada.
  Future<void> salvarNotas(List<Nota> notas) async {
    if (notas.length > maxNotas) {
      throw ArgumentError.value(
        notas.length,
        'notas',
        'este armazenamento guarda no máximo $maxNotas notas',
      );
    }

    final Set<String> idsVistos = <String>{};
    for (final Nota nota in notas) {
      // `add` devolve false quando o id já estava no conjunto.
      if (!idsVistos.add(nota.id)) {
        throw ArgumentError.value(nota.id, 'notas', 'id repetido na lista');
      }
    }

    final List<Map<String, Object?>> bruto =
        notas.map((Nota nota) => nota.paraMapa()).toList();

    await _prefs.setString(chaveNotas, jsonEncode(bruto));
  }

  Ordenacao lerOrdenacao() =>
      Ordenacao.porNome(_prefs.getString(chaveOrdenacao));

  Future<void> salvarOrdenacao(Ordenacao ordenacao) =>
      _prefs.setString(chaveOrdenacao, ordenacao.name);
}
```

---

## 🧰 O núcleo (`core/`)

### lib/core/formato/formato_data.dart

> **O que este arquivo faz:** transforma um `DateTime` em `14/09/2026 às 22:43`, sem o pacote
> `intl` — que entra só no Projeto 3.

```dart
/// Data e hora no formato brasileiro: `14/09/2026 às 22:43`.
///
/// Uma função de nível superior, não uma classe: ela não guarda estado nenhum.
/// Formatação com idioma, fuso e plural é assunto do `package:intl`, no
/// Projeto 3.
String formatarDataHora(DateTime quando) {
  final String dia = _doisDigitos(quando.day);
  final String mes = _doisDigitos(quando.month);
  final String hora = _doisDigitos(quando.hour);
  final String minuto = _doisDigitos(quando.minute);
  return '$dia/$mes/${quando.year} às $hora:$minuto';
}

/// `7` vira `07`. Sem isso a hora sai como `9:5`.
String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');
```

### lib/core/validadores/validadores.dart

> **O que este arquivo faz:** concentra as regras de validação do formulário, para que a mesma
> mensagem apareça igual em qualquer campo.

```dart
/// Assinatura de todo validador do Flutter: recebe o valor (anulável) e
/// devolve null quando está válido.
typedef Validador = String? Function(String?);

/// Validadores reutilizáveis do app.
///
/// `abstract final class` (Dart 3): não dá para instanciar nem herdar. É só um
/// agrupador de membros estáticos.
abstract final class Validadores {
  /// Executa os validadores em ordem e para no PRIMEIRO erro.
  ///
  /// Mostrar três mensagens ao mesmo tempo é ruído: o usuário corrige uma
  /// coisa por vez.
  static Validador combinar(List<Validador> validadores) {
    return (String? valor) {
      for (final Validador validar in validadores) {
        final String? erro = validar(valor);
        if (erro != null) return erro;
      }
      return null;
    };
  }

  static Validador obrigatorio([String mensagem = 'Campo obrigatório']) {
    // trim: três espaços não contam como preenchido.
    return (String? valor) =>
        (valor ?? '').trim().isEmpty ? mensagem : null;
  }

  static Validador minimo(int caracteres, [String? mensagem]) {
    return (String? valor) {
      final String texto = (valor ?? '').trim();
      if (texto.isEmpty) return null; // "vazio" é assunto de `obrigatorio`
      return texto.length < caracteres
          ? (mensagem ?? 'Use pelo menos $caracteres caracteres')
          : null;
    };
  }

  static Validador maximo(int caracteres, [String? mensagem]) {
    return (String? valor) {
      final String texto = (valor ?? '').trim();
      return texto.length > caracteres
          ? (mensagem ?? 'Use no máximo $caracteres caracteres')
          : null;
    };
  }
}
```

### lib/core/tema/tema_app.dart

> **O que este arquivo faz:** gera o tema claro e o escuro a partir de **uma** cor semente, com as
> duas versões passando pela mesma função privada.

```dart
import 'package:flutter/material.dart';

/// Tema do app, claro e escuro, derivados da mesma semente.
abstract final class TemaApp {
  /// Cor semente: o algoritmo do Material 3 deriva a paleta inteira dela.
  static const Color semente = Color(0xFF4F46E5);

  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData get escuro => _construir(Brightness.dark);

  /// Os dois temas saem daqui. Assim é impossível o escuro ficar com o botão
  /// de forma diferente do claro.
  static ThemeData _construir(Brightness brilho) {
    final ColorScheme cores = ColorScheme.fromSeed(
      seedColor: semente,
      brightness: brilho,
    );

    return ThemeData(
      colorScheme: cores,
      scaffoldBackgroundColor: cores.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: cores.surface,
        foregroundColor: cores.onSurface,
        elevation: 0,
        // Sombra sutil quando a lista rola POR BAIXO da barra.
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: cores.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cores.outlineVariant),
        ),
      ),

      // 48 dp de altura mínima: a área de toque recomendada para dedos.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cores.inverseSurface,
        contentTextStyle: TextStyle(color: cores.onInverseSurface),
      ),

      dividerTheme: DividerThemeData(
        color: cores.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
```

### lib/core/rotas/rotas.dart

> **O que este arquivo faz:** é a recepção do app — traduz um nome de rota na `Route` certa, com o
> tipo de resultado certo, validando os argumentos antes de construir a tela.

```dart
import 'package:flutter/material.dart';

import 'package:bloco_notas/core/rotas/rota_desconhecida_screen.dart';
import 'package:bloco_notas/features/notas/data/notas_repositorio.dart';
import 'package:bloco_notas/features/notas/domain/nota.dart';
import 'package:bloco_notas/features/notas/presentation/home_screen.dart';
import 'package:bloco_notas/features/notas/presentation/nota_detalhe_screen.dart';
import 'package:bloco_notas/features/notas/presentation/nota_form_screen.dart';

/// Central de rotas do app.
abstract final class Rotas {
  static const String home = '/';
  static const String notaDetalhe = '/nota/detalhe';
  static const String notaForm = '/nota/form';

  /// Chamada pelo `MaterialApp` a cada `pushNamed`.
  ///
  /// Recebe o [repositorio] por parâmetro porque a `HomeScreen` precisa dele e
  /// este app não tem injeção de dependência — isso é o `ProviderScope` do
  /// módulo 08.
  static Route<dynamic> gerar(
    RouteSettings configuracoes,
    NotasRepositorio repositorio,
  ) {
    final Object? argumentos = configuracoes.arguments;

    switch (configuracoes.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => HomeScreen(repositorio: repositorio),
        );

      case notaDetalhe:
        // `is!` em vez de `as`: argumento errado vira tela de erro, não crash.
        if (argumentos is! NotaDetalheArgs) return desconhecida(configuracoes);
        return MaterialPageRoute<AcaoDaNota>(
          settings: configuracoes,
          builder: (_) => NotaDetalheScreen(args: argumentos),
        );

      case notaForm:
        if (argumentos is! NotaFormArgs) return desconhecida(configuracoes);
        return MaterialPageRoute<Nota>(
          settings: configuracoes,
          // Sobe de baixo e ganha o X de fechar: é um formulário modal.
          fullscreenDialog: true,
          builder: (_) => NotaFormScreen(args: argumentos),
        );

      default:
        return desconhecida(configuracoes);
    }
  }

  /// Usada pelo `default` acima e pelo `onUnknownRoute` do `MaterialApp`.
  static Route<dynamic> desconhecida(RouteSettings configuracoes) {
    return MaterialPageRoute<void>(
      settings: configuracoes,
      builder: (_) => RotaDesconhecidaScreen(nome: configuracoes.name),
    );
  }
}
```

### lib/core/rotas/rota_desconhecida_screen.dart

> **O que este arquivo faz:** o "404" do app — mostra o nome que foi pedido e oferece o caminho de
> volta ao início.

```dart
import 'package:flutter/material.dart';

import 'package:bloco_notas/core/rotas/rotas.dart';

/// Mostrada quando alguém pede uma rota que não existe — ou passa o argumento
/// errado para uma que existe.
class RotaDesconhecidaScreen extends StatelessWidget {
  const RotaDesconhecidaScreen({required this.nome, super.key});

  /// Pode ser nulo: o Flutter permite uma rota sem nome.
  final String? nome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela não encontrada')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.explore_off_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Não encontramos a tela "${nome ?? 'sem nome'}".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Isso acontece quando o nome da rota está errado ou quando os '
              'argumentos enviados não são os esperados. Suas notas continuam '
              'salvas.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              // Limpa a pilha inteira: não faz sentido "voltar" para o erro.
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(Rotas.home, (_) => false),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### lib/main.dart

> **O que este arquivo faz:** abre o `SharedPreferences` **antes** de desenhar qualquer coisa,
> monta o repositório e liga as rotas e os temas ao `MaterialApp`.

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloco_notas/core/rotas/rotas.dart';
import 'package:bloco_notas/core/tema/tema_app.dart';
import 'package:bloco_notas/features/notas/data/notas_repositorio.dart';

Future<void> main() async {
  // `getInstance` conversa com o código nativo por um canal de plataforma.
  // Sem o binding iniciado, esse canal ainda não existe e a chamada falha.
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(BlocoNotasApp(repositorio: NotasRepositorio(prefs)));
}

class BlocoNotasApp extends StatelessWidget {
  const BlocoNotasApp({required this.repositorio, super.key});

  final NotasRepositorio repositorio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloco de Notas',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.escuro,
      // Segue a configuração do aparelho — o comportamento que o usuário espera.
      themeMode: ThemeMode.system,
      initialRoute: Rotas.home,
      // A closure existe só para entregar o repositório ao gerador de rotas.
      onGenerateRoute: (RouteSettings configuracoes) =>
          Rotas.gerar(configuracoes, repositorio),
      onUnknownRoute: Rotas.desconhecida,
    );
  }
}
```

---

## 🧩 Os widgets auxiliares

### lib/features/notas/presentation/widgets/chip_etiqueta.dart

> **O que este arquivo faz:** desenha a etiqueta como uma pílula colorida, usando papéis do
> `ColorScheme` — nunca cores fixas — para funcionar nos dois temas.

```dart
import 'package:flutter/material.dart';

import 'package:bloco_notas/features/notas/domain/etiqueta.dart';

/// A etiqueta da nota, em formato de pílula. Só exibe: não é clicável.
class ChipEtiqueta extends StatelessWidget {
  const ChipEtiqueta({required this.etiqueta, super.key});

  final Etiqueta etiqueta;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;

    // Cada etiqueta usa um PAPEL do esquema de cores, não um valor fixo. Por
    // isso o contraste continua correto quando o tema escuro entra.
    final (Color fundo, Color frente) = switch (etiqueta) {
      Etiqueta.aula => (cores.primaryContainer, cores.onPrimaryContainer),
      Etiqueta.resumo => (cores.secondaryContainer, cores.onSecondaryContainer),
      Etiqueta.duvida => (cores.errorContainer, cores.onErrorContainer),
      Etiqueta.revisao => (cores.tertiaryContainer, cores.onTertiaryContainer),
      Etiqueta.ideia => (cores.surfaceContainerHighest, cores.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        etiqueta.rotulo,
        style: tema.textTheme.labelSmall?.copyWith(color: frente),
      ),
    );
  }
}
```

### lib/features/notas/presentation/widgets/cartao_nota.dart

> **O que este arquivo faz:** o item da lista — título, primeira linha do conteúdo, etiqueta e data
> de atualização, com altura previsível mesmo para uma nota de 2000 caracteres.

```dart
import 'package:flutter/material.dart';

import 'package:bloco_notas/core/formato/formato_data.dart';
import 'package:bloco_notas/features/notas/domain/nota.dart';
import 'package:bloco_notas/features/notas/presentation/widgets/chip_etiqueta.dart';

/// Um item da lista da home.
///
/// Não sabe nada sobre navegação nem sobre o repositório: recebe a nota pronta
/// e devolve o toque pelo callback. Quem decide o que fazer é a `HomeScreen`.
class CartaoNota extends StatelessWidget {
  const CartaoNota({required this.nota, required this.aoTocar, super.key});

  final Nota nota;
  final VoidCallback aoTocar;

  /// Só a primeira linha do conteúdo: é o que mantém todos os cartões com a
  /// mesma altura, independente do tamanho da nota.
  String get _previa {
    final String primeira = nota.conteudo.trim().split('\n').first.trim();
    return primeira.isEmpty ? 'Sem conteúdo' : primeira;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final TextTheme tipografia = tema.textTheme;
    final ColorScheme cores = tema.colorScheme;

    return Card(
      // Sem o recorte, a onda do InkWell vaza pelos cantos arredondados.
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                nota.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tipografia.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _previa,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tipografia.bodyMedium
                    ?.copyWith(color: cores.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  ChipEtiqueta(etiqueta: nota.etiqueta),
                  const SizedBox(width: 12),
                  // Expanded para a data encostar na direita sem estourar a Row
                  // quando o texto for grande ou a fonte do sistema aumentar.
                  Expanded(
                    child: Text(
                      formatarDataHora(nota.atualizadaEm),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: tipografia.labelSmall
                          ?.copyWith(color: cores.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### lib/features/notas/presentation/widgets/estado_vazio.dart

> **O que este arquivo faz:** os dois vazios do app — "você ainda não criou nada" e "o filtro
> escondeu tudo" — que têm texto e ação diferentes de propósito.

```dart
import 'package:flutter/material.dart';

/// Tela de "não há nada aqui", com ícone, explicação e um botão que resolve.
///
/// Só existe pelos construtores nomeados: os dois vazios do app são casos
/// diferentes e precisam dizer coisas diferentes.
class EstadoVazio extends StatelessWidget {
  /// Vazio porque o usuário ainda não criou nenhuma nota (RF03).
  const EstadoVazio.inicial({required VoidCallback aoCriar, super.key})
      : titulo = 'Nenhuma nota ainda',
        mensagem = 'Anote uma aula, um resumo ou aquela dúvida que ficou. '
            'Tudo fica salvo no aparelho.',
        icone = Icons.note_add_outlined,
        rotuloAcao = 'Criar nota',
        onAcao = aoCriar;

  /// Vazio porque o FILTRO escondeu tudo (RF04). Há notas salvas — só não
  /// dessa etiqueta.
  const EstadoVazio.semResultado({required VoidCallback aoLimpar, super.key})
      : titulo = 'Nenhuma nota com essa etiqueta',
        mensagem = 'Você tem notas salvas, mas nenhuma delas usa a etiqueta '
            'escolhida.',
        icone = Icons.search_off_outlined,
        rotuloAcao = 'Limpar filtro',
        onAcao = aoLimpar;

  final String titulo;
  final String mensagem;
  final IconData icone;
  final String rotuloAcao;
  final VoidCallback onAcao;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;
    final TextTheme tipografia = tema.textTheme;

    // ListView e não Column: em tela baixa, ou com a fonte do sistema
    // aumentada, uma Column estoura em overflow amarelo.
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: <Widget>[
        Icon(icone, size: 64, color: cores.outline),
        const SizedBox(height: 24),
        Text(titulo, textAlign: TextAlign.center, style: tipografia.titleLarge),
        const SizedBox(height: 8),
        Text(
          mensagem,
          textAlign: TextAlign.center,
          style: tipografia.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.tonal(
            onPressed: onAcao,
            child: Text(rotuloAcao),
          ),
        ),
      ],
    );
  }
}
```

---

## 📱 As telas

### lib/features/notas/presentation/nota_detalhe_screen.dart

> **O que este arquivo faz:** mostra a nota inteira e devolve à home **a intenção** do usuário
> (`editar`, `excluir` ou nada) — sem tocar na lista.

```dart
import 'package:flutter/material.dart';

import 'package:bloco_notas/core/formato/formato_data.dart';
import 'package:bloco_notas/features/notas/domain/nota.dart';
import 'package:bloco_notas/features/notas/presentation/widgets/chip_etiqueta.dart';

/// O que o detalhe devolve para a home. `null` (voltar) significa "nada a
/// fazer" e é o resultado mais comum (RF11).
enum AcaoDaNota { editar, excluir }

/// Argumentos da rota de detalhe.
///
/// Convenção do curso: a classe de argumentos mora no arquivo da tela que a
/// recebe, com o sufixo Args.
class NotaDetalheArgs {
  const NotaDetalheArgs({required this.nota});

  final Nota nota;
}

class NotaDetalheScreen extends StatelessWidget {
  const NotaDetalheScreen({required this.args, super.key});

  final NotaDetalheArgs args;

  /// Exclusão é destrutiva: pergunta antes, e só então devolve a intenção.
  /// Quem apaga de verdade é a `HomeScreen`, dona da lista.
  Future<void> _confirmarExclusao(BuildContext context) async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext contextoDoDialogo) {
        return AlertDialog(
          title: const Text('Excluir nota?'),
          content: Text('"${args.nota.titulo}" sai da sua lista.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(contextoDoDialogo).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(contextoDoDialogo).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) return;

    // O diálogo é assíncrono: a tela pode ter saído da árvore nesse meio-tempo.
    if (!context.mounted) return;

    Navigator.of(context).pop(AcaoDaNota.excluir);
  }

  @override
  Widget build(BuildContext context) {
    final Nota nota = args.nota;
    final ThemeData tema = Theme.of(context);
    final TextTheme tipografia = tema.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).pop(AcaoDaNota.editar),
          ),
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      // ListView: o conteúdo pode ter 2000 caracteres e precisa rolar (RF09).
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: <Widget>[
          Text(nota.titulo, style: tipografia.headlineSmall),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ChipEtiqueta(etiqueta: nota.etiqueta),
          ),
          const SizedBox(height: 24),
          Text(nota.conteudo, style: tipografia.bodyLarge),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          _LinhaDeData(rotulo: 'Criada em', quando: nota.criadaEm),
          const SizedBox(height: 4),
          _LinhaDeData(rotulo: 'Atualizada em', quando: nota.atualizadaEm),
        ],
      ),
    );
  }
}

/// Privada: só o detalhe usa. Duas datas, um formato só.
class _LinhaDeData extends StatelessWidget {
  const _LinhaDeData({required this.rotulo, required this.quando});

  final String rotulo;
  final DateTime quando;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Text(
      '$rotulo ${formatarDataHora(quando)}',
      style: tema.textTheme.bodySmall
          ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
    );
  }
}
```

### lib/features/notas/presentation/nota_form_screen.dart

> **O que este arquivo faz:** o formulário que atende criação e edição, valida os campos, protege o
> rascunho na saída e devolve a `Nota` pronta pelo `pop`.

```dart
import 'package:flutter/material.dart';

import 'package:bloco_notas/core/validadores/validadores.dart';
import 'package:bloco_notas/features/notas/domain/etiqueta.dart';
import 'package:bloco_notas/features/notas/domain/nota.dart';

/// Argumentos do formulário.
///
/// Dois construtores nomeados deixam a INTENÇÃO explícita em quem chama:
/// `NotaFormArgs.criar()` ou `NotaFormArgs.editar(nota)`.
class NotaFormArgs {
  const NotaFormArgs.criar() : original = null;

  const NotaFormArgs.editar(Nota nota) : original = nota;

  /// null = criando; preenchido = editando.
  final Nota? original;

  bool get ehEdicao => original != null;
}

class NotaFormScreen extends StatefulWidget {
  const NotaFormScreen({required this.args, super.key});

  final NotaFormArgs args;

  @override
  State<NotaFormScreen> createState() => _NotaFormScreenState();
}

class _NotaFormScreenState extends State<NotaFormScreen> {
  final GlobalKey<FormState> _chaveDoFormulario = GlobalKey<FormState>();

  late final Nota? _original = widget.args.original;

  late final TextEditingController _titulo =
      TextEditingController(text: _original?.titulo ?? '');
  late final TextEditingController _conteudo =
      TextEditingController(text: _original?.conteudo ?? '');

  /// Nunca é null — é um campo do State, não uma seleção pendente (RF15).
  late Etiqueta _etiqueta = _original?.etiqueta ?? Etiqueta.resumo;

  /// Desligada até a primeira tentativa de salvar: o formulário abre limpo,
  /// sem vermelho (RF16).
  AutovalidateMode _autovalidar = AutovalidateMode.disabled;

  /// O que decide se a saída pede confirmação (RF18).
  bool get _temAlteracoes {
    final Nota? original = _original;
    if (original == null) {
      return _titulo.text.trim().isNotEmpty ||
          _conteudo.text.trim().isNotEmpty ||
          _etiqueta != Etiqueta.resumo;
    }
    return _titulo.text.trim() != original.titulo ||
        _conteudo.text.trim() != original.conteudo ||
        _etiqueta != original.etiqueta;
  }

  @override
  void initState() {
    super.initState();
    _titulo.addListener(_aoDigitar);
    _conteudo.addListener(_aoDigitar);
  }

  @override
  void dispose() {
    // Controller não liberado é vazamento de memória garantido.
    _titulo
      ..removeListener(_aoDigitar)
      ..dispose();
    _conteudo
      ..removeListener(_aoDigitar)
      ..dispose();
    super.dispose();
  }

  /// Redesenha para o `PopScope` reavaliar `canPop` a cada tecla digitada.
  void _aoDigitar() => setState(() {});

  void _salvar() {
    // O teclado cobriria as mensagens de erro.
    FocusScope.of(context).unfocus();

    if (!_chaveDoFormulario.currentState!.validate()) {
      // A partir de agora o erro acompanha a digitação, sem esperar outro toque.
      setState(() => _autovalidar = AutovalidateMode.onUserInteraction);
      return;
    }

    final DateTime agora = DateTime.now();
    final Nota? original = _original;

    final Nota nota = original == null
        ? Nota(
            // Sem o pacote uuid (Projeto 3): o relógio em microssegundos não
            // repete dentro de um mesmo aparelho.
            id: agora.microsecondsSinceEpoch.toString(),
            titulo: _titulo.text.trim(),
            conteudo: _conteudo.text.trim(),
            etiqueta: _etiqueta,
            criadaEm: agora,
            atualizadaEm: agora,
          )
        // copyWith preserva id e criadaEm: só a atualização muda (RF17).
        : original.copyWith(
            titulo: _titulo.text.trim(),
            conteudo: _conteudo.text.trim(),
            etiqueta: _etiqueta,
            atualizadaEm: agora,
          );

    Navigator.of(context).pop(nota);
  }

  Future<void> _perguntarSeDescarta() async {
    // Guardado ANTES do await: depois dele, usar o context é o erro que o lint
    // use_build_context_synchronously aponta.
    final NavigatorState navegador = Navigator.of(context);

    final bool? descartar = await showDialog<bool>(
      context: context,
      builder: (BuildContext contextoDoDialogo) {
        return AlertDialog(
          title: const Text('Descartar alterações?'),
          content: const Text('O que você escreveu nesta tela será perdido.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(contextoDoDialogo).pop(false),
              child: const Text('Continuar editando'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(contextoDoDialogo).pop(true),
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );

    if (descartar != true) return;
    if (!mounted) return;

    // pop() sem argumento devolve null para a home: "cancelou".
    navegador.pop();
  }

  @override
  Widget build(BuildContext context) {
    // PopScope<Nota>: o tipo do resultado desta rota, declarado em Rotas.gerar.
    return PopScope<Nota>(
      canPop: !_temAlteracoes,
      onPopInvokedWithResult: (bool saiu, Nota? resultado) {
        if (saiu) return; // o pop aconteceu; nada a fazer
        // Chegamos aqui porque canPop era false: o pop foi BLOQUEADO.
        _perguntarSeDescarta();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_original == null ? 'Nova nota' : 'Editar nota'),
        ),
        body: Form(
          key: _chaveDoFormulario,
          autovalidateMode: _autovalidar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: <Widget>[
              TextFormField(
                key: const Key('campo_titulo'),
                controller: _titulo,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ex.: Ciclo de vida do State',
                ),
                validator: Validadores.combinar(<Validador>[
                  Validadores.obrigatorio('Informe um título'),
                  Validadores.minimo(3),
                  Validadores.maximo(60),
                ]),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('campo_conteudo'),
                controller: _conteudo,
                maxLines: 8,
                maxLength: 2000,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  alignLabelWithHint: true,
                ),
                validator: Validadores.combinar(<Validador>[
                  Validadores.obrigatorio('Escreva alguma coisa'),
                  Validadores.maximo(2000),
                ]),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Etiqueta>(
                key: const Key('campo_etiqueta'),
                initialValue: _etiqueta,
                decoration: const InputDecoration(labelText: 'Etiqueta'),
                items: <DropdownMenuItem<Etiqueta>>[
                  for (final Etiqueta etiqueta in Etiqueta.values)
                    DropdownMenuItem<Etiqueta>(
                      value: etiqueta,
                      child: Text(etiqueta.rotulo),
                    ),
                ],
                // O Dropdown só chama onChanged com um item da lista; o null do
                // parâmetro é da assinatura, não um estado possível aqui.
                onChanged: (Etiqueta? nova) {
                  if (nova == null) return;
                  setState(() => _etiqueta = nova);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('botao_salvar'),
                onPressed: _salvar,
                icon: const Icon(Icons.check),
                label: Text(
                  _original == null ? 'Salvar nota' : 'Salvar alterações',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### lib/features/notas/presentation/home_screen.dart

> **O que este arquivo faz:** é a dona do estado — guarda a lista, o filtro, a ordenação e o
> carregamento, e é o único lugar que chama o repositório para gravar.

```dart
import 'package:flutter/material.dart';

import 'package:bloco_notas/core/rotas/rotas.dart';
import 'package:bloco_notas/features/notas/data/notas_repositorio.dart';
import 'package:bloco_notas/features/notas/domain/etiqueta.dart';
import 'package:bloco_notas/features/notas/domain/nota.dart';
import 'package:bloco_notas/features/notas/domain/ordenacao.dart';
import 'package:bloco_notas/features/notas/presentation/nota_detalhe_screen.dart';
import 'package:bloco_notas/features/notas/presentation/nota_form_screen.dart';
import 'package:bloco_notas/features/notas/presentation/widgets/cartao_nota.dart';
import 'package:bloco_notas/features/notas/presentation/widgets/estado_vazio.dart';

/// A lista de notas — e a dona de TODO o estado do app.
///
/// As outras telas recebem dados pelo construtor e devolvem resultado pelo
/// `pop`. Isso é elevação de estado na mão: a dor que o módulo 08 resolve.
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.repositorio, super.key});

  final NotasRepositorio repositorio;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// A fonte da verdade. A lista visível é derivada dela a cada build.
  List<Nota> _notas = const <Nota>[];

  /// null = sem filtro. Só uma etiqueta por vez (RF05).
  Etiqueta? _filtro;

  Ordenacao _ordenacao = Ordenacao.maisRecente;

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  /// Lê o disco uma vez, na abertura.
  ///
  /// A leitura do SharedPreferences é síncrona, mas a espera de um ciclo do
  /// laço de eventos garante que o primeiro quadro mostre o indicador em vez
  /// de "nenhuma nota" (RF02) — e no dia em que isto virar banco, nada aqui muda.
  Future<void> _carregar() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    setState(() {
      _notas = widget.repositorio.lerNotas();
      _ordenacao = widget.repositorio.lerOrdenacao();
      _carregando = false;
    });
  }

  /// Filtra e ordena SEM tocar em `_notas`.
  List<Nota> get _visiveis {
    final Etiqueta? filtro = _filtro;
    final List<Nota> lista = filtro == null
        ? List<Nota>.of(_notas)
        : _notas.where((Nota nota) => nota.etiqueta == filtro).toList();

    lista.sort((Nota a, Nota b) => switch (_ordenacao) {
          Ordenacao.maisRecente => b.atualizadaEm.compareTo(a.atualizadaEm),
          Ordenacao.maisAntiga => a.atualizadaEm.compareTo(b.atualizadaEm),
          Ordenacao.tituloAZ =>
            a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()),
        });

    return lista;
  }

  /// Toda mudança na lista passa por aqui: atualiza a tela e grava o arquivo
  /// inteiro (RF19).
  Future<void> _aplicar(List<Nota> novas) async {
    setState(() => _notas = novas);
    await widget.repositorio.salvarNotas(novas);
  }

  Future<void> _mudarOrdenacao(Ordenacao nova) async {
    setState(() => _ordenacao = nova);
    // Persistida na hora: a escolha sobrevive ao fechamento do app (RF06).
    await widget.repositorio.salvarOrdenacao(nova);
  }

  Future<void> _abrirNovaNota() async {
    if (_notas.length >= NotasRepositorio.maxNotas) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Limite de 200 notas: este projeto guarda tudo em um único '
              'arquivo de preferências. Exclua uma nota para criar outra.',
            ),
          ),
        );
      return;
    }

    final Nota? nova = await Navigator.of(context).pushNamed<Nota>(
      Rotas.notaForm,
      arguments: const NotaFormArgs.criar(),
    );

    // null = fechou sem salvar. Não é erro; é o caso mais comum.
    if (nova == null) return;
    if (!mounted) return;

    await _aplicar(<Nota>[nova, ..._notas]);
  }

  /// Abre o detalhe e executa a intenção que ele devolver.
  Future<void> _abrirNota(Nota nota) async {
    final AcaoDaNota? acao = await Navigator.of(context).pushNamed<AcaoDaNota>(
      Rotas.notaDetalhe,
      arguments: NotaDetalheArgs(nota: nota),
    );
    if (!mounted) return;

    switch (acao) {
      case null:
        return; // voltou sem fazer nada (RF11)
      case AcaoDaNota.editar:
        await _editar(nota);
      case AcaoDaNota.excluir:
        await _excluir(nota);
    }
  }

  Future<void> _editar(Nota nota) async {
    final Nota? salva = await Navigator.of(context).pushNamed<Nota>(
      Rotas.notaForm,
      arguments: NotaFormArgs.editar(nota),
    );
    if (salva == null) return;
    if (!mounted) return;

    await _aplicar(<Nota>[
      for (final Nota atual in _notas)
        if (atual.id == salva.id) salva else atual,
    ]);
  }

  Future<void> _excluir(Nota nota) async {
    // Guardada ANTES da remoção: é o que o Desfazer usa para devolver a nota
    // exatamente onde ela estava (RF07).
    final int posicao = _notas.indexWhere((Nota atual) => atual.id == nota.id);

    await _aplicar(
      _notas.where((Nota atual) => atual.id != nota.id).toList(),
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      // Evita fila de mensagens quando o usuário exclui várias seguidas.
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text('"${nota.titulo}" excluída'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _restaurar(nota, posicao),
          ),
        ),
      );
  }

  Future<void> _restaurar(Nota nota, int posicao) async {
    // O SnackBar vive no ScaffoldMessenger, acima desta tela: ele pode ser
    // tocado depois que a tela sair da árvore.
    if (!mounted) return;

    final List<Nota> novas = List<Nota>.of(_notas);
    // clamp protege contra a lista ter encolhido enquanto o aviso estava aberto.
    novas.insert(posicao.clamp(0, novas.length), nota);

    await _aplicar(novas);
  }

  void _limparFiltro() => setState(() => _filtro = null);

  Widget _filtros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          for (final Etiqueta etiqueta in Etiqueta.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(etiqueta.rotulo),
                selected: _filtro == etiqueta,
                onSelected: (bool _) => setState(() {
                  // Tocar no chip que já está ativo zera o filtro (RF05).
                  _filtro = _filtro == etiqueta ? null : etiqueta;
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notas.isEmpty) {
      return EstadoVazio.inicial(aoCriar: _abrirNovaNota);
    }

    final List<Nota> visiveis = _visiveis;
    if (visiveis.isEmpty) {
      return EstadoVazio.semResultado(aoLimpar: _limparFiltro);
    }

    return ListView.separated(
      // 96 embaixo: o FAB não pode cobrir o último cartão.
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: visiveis.length,
      separatorBuilder: (BuildContext context, int indice) =>
          const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int indice) {
        final Nota nota = visiveis[indice];

        return Dismissible(
          // A key precisa ser única e ESTÁVEL. O índice não serve: ele muda
          // quando um item sai.
          key: ValueKey<String>(nota.id),
          direction: DismissDirection.endToStart,
          background: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          // Sem diálogo de confirmação: quem protege o usuário aqui é o
          // Desfazer do SnackBar.
          onDismissed: (DismissDirection direcao) => _excluir(nota),
          child: CartaoNota(nota: nota, aoTocar: () => _abrirNota(nota)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloco de Notas'),
        actions: <Widget>[
          PopupMenuButton<Ordenacao>(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            initialValue: _ordenacao,
            onSelected: _mudarOrdenacao,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Ordenacao>>[
              for (final Ordenacao ordenacao in Ordenacao.values)
                PopupMenuItem<Ordenacao>(
                  value: ordenacao,
                  child: Text(ordenacao.rotulo),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovaNota,
        icon: const Icon(Icons.add),
        label: const Text('Nova nota'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Os chips só aparecem quando existe o que filtrar.
            if (!_carregando && _notas.isNotEmpty) _filtros(),
            Expanded(child: _corpo()),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔍 As decisões que valem explicar

| Decisão | Por quê |
|---|---|
| `Nota.doMapa` devolve `Nota?` em vez de lançar | Um item estragado no array não pode derrubar as outras 40 notas. O repositório testa `!= null` e segue (RF21). |
| `lerNotas()` captura `FormatException` e devolve `const <Nota>[]` | O app **abre** com o arquivo corrompido. Abrir vazio é recuperável; tela vermelha na inicialização não é (RF20). |
| `salvarNotas` lança `ArgumentError` em id repetido | Dois ids iguais quebram a `key` do `Dismissible` e fazem a edição alterar a nota errada. Falhar alto aqui é melhor do que dado silenciosamente trocado (RF22). |
| `_notas` guarda tudo; `_visiveis` é um getter derivado | Filtrar e ordenar nunca podem apagar nada. A lista salva é a verdade; o que a tela mostra é uma projeção recalculada a cada build. |
| `copyWith` não aceita `id` nem `criadaEm` | Editar uma nota não pode mudar a identidade nem a data de nascimento dela. O que o compilador não permite, o bug não acontece (RF17). |
| `is! NotaDetalheArgs` no `onGenerateRoute`, nunca `as` | Um `as` com argumento errado quebra o app em produção. O teste de tipo desvia para a `RotaDesconhecidaScreen`, que explica o problema e oferece saída. |
| `PopScope` com `canPop: !_temAlteracoes` | Um `bool` síncrono, reavaliado a cada tecla — por isso os controllers têm listener que chama `setState`. Sem ele, o gesto de borda do iOS apagaria o rascunho sem aviso (RF18). |
| `maxNotas = 200` com `SnackBar` explicando | O teto é proposital: cada gravação reescreve o arquivo inteiro. Sentir o limite é o que justifica o `sqflite` do módulo 10 (RF23). |

---

| # | Arquivo | Conteúdo |
|---|---|---|
| — | [README.md](README.md) | Visão geral do projeto |
| 01 | [01-especificacao.md](01-especificacao.md) | Requisitos e modelo de dados |
| 02 | [02-passo-a-passo.md](02-passo-a-passo.md) | Construção guiada, do `flutter create` ao app rodando |
| 03 | **03-codigo-completo.md** | 📍 Você está aqui |
| 04 | [04-testes.md](04-testes.md) | Os três arquivos de `test/`, comentados |
| 05 | [05-desafios.md](05-desafios.md) | Extensões · [🔑 gabarito](../../gabaritos/projeto-02-desafios.md) |
| 06 | [06-checklist.md](06-checklist.md) | Critérios de "pronto" |
