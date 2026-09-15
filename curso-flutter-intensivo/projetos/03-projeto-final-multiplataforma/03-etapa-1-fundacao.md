# Etapa 1 — Fundação — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 60 min · **Depende de:** [01 Especificação](01-especificacao.md) e
> [02 Arquitetura](02-arquitetura.md) · **Aulas:**
> [05.03 main e runApp](../../modulos/05-introducao-ao-flutter/03-main-runapp-arvore-de-widgets.md) ·
> [06.07 Cores, temas e modo escuro](../../modulos/06-widgets-e-layouts/07-cores-temas-modo-escuro.md) ·
> [07.02 Rotas nomeadas](../../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md) ·
> [07.03 Argumentos e resultados](../../modulos/07-navegacao-e-formularios/03-argumentos-e-resultados.md)

Esta etapa não reensina as aulas acima: aplica aquilo ao Foco. O projeto nasce, o tema nasce, as
cinco rotas nascem — e o app roda.

---

## 🎯 O que existe ao fim desta etapa

| Você terá | Verificável por |
|---|---|
| O projeto `foco` com `applicationId` **`br.com.estudos.foco`** | `android/app/build.gradle.kts` |
| `ProviderScope` na raiz da árvore | `lib/main.dart` |
| Tema Material 3 claro **e** escuro, de uma semente só | trocar o tema do sistema |
| As **5 rotas** por `onGenerateRoute`, com rede de proteção | os botões da tela provisória |
| A árvore *feature-first* inteira | `lib/` |

O que **ainda não** existe: banco, providers de dado, telas reais. As cinco rotas apontam para uma
tela provisória que a Etapa 4 substitui — mas o app já abre, navega e volta.

---

## 📦 Dependências

### Criando o projeto

Rode na pasta onde você guarda os projetos do curso. A flag `-e` (*empty*) evita o app de contador
e o `test/widget_test.dart` gerado — os testes de verdade chegam na Etapa 7.

```powershell
flutter create -e --org br.com.estudos --platforms=android,ios foco
cd foco
```

> ⚠️ **`--org` só vale na criação.** Sem a flag, `com.example.foco` fica gravado no Gradle e no
> Xcode — e ele é a identidade do app na loja. Esqueceu? Apague a pasta e refaça.

> 📌 **Por que só `android,ios`.** Você desenvolve no emulador Android 🤖. O build iOS 🍎 vem na
> Etapa 8 e **exige um Mac ou um runner macOS de CI** — Xcode não roda no Windows 11.

### O que entra no `pubspec.yaml` agora

| Pacote | Versão | Por quê, agora |
|---|---|---|
| `flutter_riverpod` | `^3.4.3` | O `ProviderScope` envolve a árvore desde o primeiro `runApp`: sem ele nenhum `ref.watch` das próximas etapas acha o contêiner. Sem codegen (ADR-01) |
| `flutter_lints` | `^6.0.0` | O RNF15 exige `flutter analyze` limpo desde a primeira linha. Lint que entra no fim vira mutirão de avisos |

O resto entra quando for usado: `sqflite`, `path`, `shared_preferences` e `uuid` na Etapa 2;
`http` e `intl` na 5; `mocktail` na 7.

---

## 🧩 Os arquivos desta etapa

Crie primeiro a árvore inteira — as próximas etapas contam com ela. Rode dentro de `foco/`:

```powershell
$pastas = @(
  'core/constantes','core/rotas','core/tema','core/banco','core/formato',
  'core/erros','core/http','core/layout','core/providers','core/widgets',
  'features/inicio/presentation',
  'features/materias/domain','features/materias/data','features/materias/presentation/widgets',
  'features/sessoes/domain','features/sessoes/data','features/sessoes/presentation/widgets',
  'features/metas/domain','features/metas/data','features/metas/presentation/widgets',
  'features/trilhas/domain','features/trilhas/data','features/trilhas/presentation/widgets',
  'features/estatisticas/domain','features/estatisticas/presentation/widgets',
  'features/configuracoes/presentation'
)
foreach ($p in $pastas) { New-Item -ItemType Directory -Force -Path "lib/$p" | Out-Null }
```

| Arquivo | Papel |
|---|---|
| `pubspec.yaml` | SDK e as duas dependências desta etapa |
| `analysis_options.yaml` | O lint que faz o RNF15 valer |
| `lib/core/constantes/ambiente.dart` | Base da API por `--dart-define` |
| `lib/core/constantes/limites.dart` | Os números do contrato num lugar só |
| `lib/core/tema/modo_de_tema.dart` | `enum ModoDeTema`, em Dart puro |
| `lib/core/tema/tema_foco.dart` | `ThemeData` claro e escuro de **uma** semente |
| `lib/core/rotas/rotas.dart` | Os 5 nomes, o `onGenerateRoute` + tela provisória |
| `lib/app.dart` | O `MaterialApp`: tema, rota inicial, gerador |
| `lib/main.dart` | `runApp` com o `ProviderScope` na raiz |

---

### pubspec.yaml

> **Por que ele existe:** é o contrato de versões, e onde mora o `1.0.0+1` que a Etapa 8 cobra.

```yaml
name: foco
description: "Foco: organizador de estudos."
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ^3.13.1

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.4.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

---

### analysis_options.yaml

> **Por que ele existe:** `strict-casts` vira erro de compilação o que seria `TypeError` em tempo
> de execução quando a Etapa 2 ler `Map<String, Object?>` do banco.

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
```

---

### lib/core/constantes/ambiente.dart

> **Por que ele existe:** a base da API muda sem editar código — e sem virar segredo commitado.

```dart
/// Configuração vinda de fora do código, por `--dart-define`.
///
/// Exemplo: `flutter run --dart-define=FOCO_API_BASE=https://meu-mock.dev`
abstract final class Ambiente {
  static const String apiBasePadrao = 'https://jsonplaceholder.typicode.com';

  /// `String.fromEnvironment` resolve em tempo de COMPILAÇÃO: o valor fica
  /// congelado no binário — e por isso segredo nenhum entra aqui.
  static const String apiBase = String.fromEnvironment(
    'FOCO_API_BASE',
    defaultValue: apiBasePadrao,
  );
}
```

---

### lib/core/constantes/limites.dart

> **Por que ele existe:** cada número aparece na validação, no `helperText` e no teste. Espalhá-los
> é garantir que um dia dois deles discordem.

```dart
/// Os números do Foco. Nenhuma tela inventa um limite próprio.
abstract final class Limites {
  static const int nomeDeMateriaMinimo = 2;
  static const int nomeDeMateriaMaximo = 60;

  static const int minutosDeSessaoMinimo = 1;
  static const int minutosDeSessaoMaximo = 480; // 8 h
  static const int anotacaoMaxima = 280;

  static const int metaSemanalPadrao = 300; // 5 h
  static const int metaSemanalMinima = 30;
  static const int metaSemanalMaxima = 3000;
  static const int metaSemanalPasso = 30;

  static const Duration tempoLimiteDeRede = Duration(seconds: 15);
  static const int tentativasDeRede = 2;
  static const Duration ttlDoCacheDeTrilhas = Duration(hours: 6);
  static const int trilhasPorBusca = 20;
}
```

> 📌 A Etapa 2 repete 1 e 480 dentro de `Sessao`: `domain/` **não importa `core/`** (ADR-03).

---

### lib/core/tema/modo_de_tema.dart

> **Por que ele existe:** `ThemeMode` é tipo do Flutter; a *preferência* é dado — e dado que vai
> para o `shared_preferences` na Etapa 3 não carrega o Flutter junto.

```dart
/// Preferência de tema escolhida pelo usuário (RF20).
///
/// Dart puro de propósito: nenhum import de Flutter. Quem traduz para
/// `ThemeMode` é `TemaFoco.paraThemeMode`.
enum ModoDeTema {
  claro('claro', 'Claro'),
  escuro('escuro', 'Escuro'),
  sistema('sistema', 'Sistema');

  const ModoDeTema(this.chave, this.rotulo);

  /// Valor gravado nas preferências. Nunca grave `index`: reordenar o enum
  /// mudaria o significado do que já está no aparelho do usuário.
  final String chave;
  final String rotulo;

  static const ModoDeTema padrao = ModoDeTema.sistema;

  static ModoDeTema deChave(String? chave) => ModoDeTema.values.firstWhere(
        (ModoDeTema modo) => modo.chave == chave,
        orElse: () => padrao,
      );
}
```

---

### lib/core/tema/tema_foco.dart

> **Por que ele existe:** é o único arquivo do projeto autorizado a conter um hexadecimal de cor.
> Fora dele, toda cor sai de `Theme.of(context).colorScheme`.

```dart
import 'package:flutter/material.dart';

import 'modo_de_tema.dart';

/// Tema visual do Foco: claro e escuro, derivados de UMA cor semente.
abstract final class TemaFoco {
  /// 0xFF6750A4 é o mesmo valor do `corValor` padrão de `Materia`
  /// (4284960932). App e matéria nova começam na mesma cor, de propósito.
  static const Color semente = Color(0xFF6750A4);

  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData get escuro => _construir(Brightness.dark);

  static ThemeMode paraThemeMode(ModoDeTema modo) => switch (modo) {
        ModoDeTema.claro => ThemeMode.light,
        ModoDeTema.escuro => ThemeMode.dark,
        ModoDeTema.sistema => ThemeMode.system,
      };

  static ThemeData _construir(Brightness brilho) {
    // Uma semente + brightness gera a paleta inteira com os pares X/onX já
    // contrastados: é assim que o RNF01 sai sem calcular contraste à mão.
    final ColorScheme cores = ColorScheme.fromSeed(
      seedColor: semente,
      brightness: brilho,
    );

    return ThemeData(
      colorScheme: cores,

      appBarTheme: AppBarTheme(
        backgroundColor: cores.surface,
        foregroundColor: cores.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),

      // ⚠️ O parâmetro `cardTheme` espera CardThemeData, não CardTheme.
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cores.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cores.outlineVariant),
        ),
      ),

      // 48 dp de alvo de toque resolvidos no tema, não tela por tela (RNF02).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size.square(48)),
      ),
    );
  }
}
```

---

### lib/core/rotas/rotas.dart

> **Por que ele existe:** as cinco rotas viram constantes conferidas pelo compilador e a resolução
> fica em **um** `switch` — a Etapa 4 só troca os `builder`, sem mexer em quem navega.

```dart
import 'package:flutter/material.dart';

/// Central de rotas do Foco: ninguém instancia nem herda.
abstract final class Rotas {
  static const String inicio = '/';
  static const String materiaForm = '/materia/form';
  static const String materiaDetalhe = '/materia/detalhe';
  static const String estatisticas = '/estatisticas';
  static const String configuracoes = '/configuracoes';

  /// ⚠️ O parâmetro NÃO pode se chamar `configuracoes`: ele sombrearia a
  /// constante acima e o `case configuracoes:` pararia de compilar com
  /// "Case expressions must be constant".
  static Route<dynamic> gerar(RouteSettings rota) {
    switch (rota.name) {
      case inicio:
        return _pagina(rota, const _TelaProvisoria('Foco', atalhos: true));

      case materiaForm:
        // <bool> porque o formulário devolve `true` no pop quando salva (RF05).
        return MaterialPageRoute<bool>(
          settings: rota,
          fullscreenDialog: true,
          builder: (_) => const _TelaProvisoria('Matéria'),
        );

      case materiaDetalhe:
        return _pagina(rota, const _TelaProvisoria('Detalhe da matéria'));

      case estatisticas:
        return _pagina(rota, const _TelaProvisoria('Estatísticas'));

      case configuracoes:
        return _pagina(rota, const _TelaProvisoria('Configurações'));

      default:
        return desconhecida(rota);
    }
  }

  /// Usada pelo `default` acima e pelo `onUnknownRoute` do MaterialApp.
  static Route<dynamic> desconhecida(RouteSettings rota) =>
      _pagina(rota, _TelaDesconhecida(nome: rota.name));

  static Route<void> _pagina(RouteSettings rota, Widget tela) =>
      MaterialPageRoute<void>(settings: rota, builder: (_) => tela);
}

/// Andaime da Etapa 1: a Etapa 4 troca cada `builder` acima pela tela real e
/// apaga esta classe.
class _TelaProvisoria extends StatelessWidget {
  const _TelaProvisoria(this.titulo, {this.atalhos = false});

  final String titulo;
  final bool atalhos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text('Tela provisória: a rota resolveu e o tema está aplicado.'),
          if (atalhos) ...<Widget>[
            const SizedBox(height: 24),
            _ir(context, 'Matéria (formulário)', Rotas.materiaForm),
            _ir(context, 'Detalhe da matéria', Rotas.materiaDetalhe),
            _ir(context, 'Estatísticas', Rotas.estatisticas),
            _ir(context, 'Configurações', Rotas.configuracoes),
            _ir(context, 'Rota que não existe', '/nada-aqui'),
          ],
        ],
      ),
    );
  }

  Widget _ir(BuildContext context, String rotulo, String destino) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FilledButton.tonal(
          onPressed: () => Navigator.of(context).pushNamed(destino),
          child: Text(rotulo),
        ),
      );
}

/// O "404" do app: nome de rota que o `switch` não conhece.
class _TelaDesconhecida extends StatelessWidget {
  const _TelaDesconhecida({required this.nome});

  final String? nome; // o Flutter permite rota sem nome

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tela não encontrada')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'A rota ${nome ?? '(sem nome)'} não existe neste app.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(Rotas.inicio, (_) => false),
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      );
}
```

---

### lib/app.dart

> **Por que ele existe:** separado do `main.dart`, o `MaterialApp` inteiro cabe num teste de widget
> da Etapa 7 sem executar o `main()`.

```dart
import 'package:flutter/material.dart';

import 'core/rotas/rotas.dart';
import 'core/tema/modo_de_tema.dart';
import 'core/tema/tema_foco.dart';

class AppFoco extends StatelessWidget {
  const AppFoco({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      debugShowCheckedModeBanner: false,
      theme: TemaFoco.claro,
      darkTheme: TemaFoco.escuro,
      // Etapa 3: vira ConsumerWidget e isto passa a ser
      // TemaFoco.paraThemeMode(ref.watch(modoDeTemaProvider)).
      themeMode: TemaFoco.paraThemeMode(ModoDeTema.padrao),

      // ⚠️ `initialRoute` e `home:` são excludentes. Com os dois juntos o
      // Flutter usa o `home:` e ignora o `initialRoute`, sem avisar.
      initialRoute: Rotas.inicio,
      onGenerateRoute: Rotas.gerar,
      onUnknownRoute: Rotas.desconhecida,
    );
  }
}
```

---

### lib/main.dart

> **Por que ele existe:** é a raiz. O `ProviderScope` precisa estar **acima** do `MaterialApp`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // Etapa 2: vira `Future<void> main() async`, abre o foco.db e as
  // preferências ANTES do runApp e injeta os dois por `overrides` (RNF14).
  runApp(
    const ProviderScope(
      child: AppFoco(),
    ),
  );
}
```

---

## ▶️ Rodando

Com o emulador Android aberto:

```powershell
flutter pub get
flutter analyze
flutter run
```

O app abre em **Foco** (rota `/`) com cinco botões. Os quatro primeiros empilham a rota
correspondente — a de matéria sobe de baixo, com o ✕ de `fullscreenDialog`, porque ela é o
formulário — e o botão voltar desempilha. O quinto cai em **Tela não encontrada**, onde "Voltar ao
início" limpa a pilha. Mude o tema do Android para escuro: o Foco acompanha na hora, sem hot
restart, porque o `themeMode` está em `ModoDeTema.sistema`.

---

## ✅ Conferência

- [ ] `flutter --version` mostra **Flutter 3.47.1** e **Dart 3.13.1**.
- [ ] `android/app/build.gradle.kts` tem `applicationId = "br.com.estudos.foco"`.
- [ ] `flutter analyze` termina com **`No issues found!`** — zero aviso, não "poucos avisos".
- [ ] `flutter run` abre a tela provisória, e os quatro botões de rota empilham e desempilham.
- [ ] `/nada-aqui` cai na tela desconhecida, e não em tela vermelha de erro.
- [ ] Trocar o tema do sistema muda o app **sem** recompilar.
- [ ] `lib/` tem as 26 pastas da [arquitetura](02-arquitetura.md), mesmo vazias.

---

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| `Case expressions must be constant` em `rotas.dart` | O parâmetro de `gerar` foi chamado de `configuracoes` e sombreou `Rotas.configuracoes` | Renomeie o parâmetro para `rota` |
| `Could not find a generator for route RouteSettings("/materia/from", null)` | Nome de rota digitado à mão, com erro | Navegue sempre por `Rotas.materiaForm`; texto solto no `pushNamed` é proibido |
| `The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'` | O `ThemeData` recebe `CardThemeData` | Troque `CardTheme(` por `CardThemeData(` |
| `Undefined name 'ProviderScope'` | `flutter_riverpod` fora do `pubspec.yaml`, ou faltou `flutter pub get` | Adicione a dependência e rode `flutter pub get` |
| Modo escuro do sistema não muda nada | Faltou o `darkTheme:` — só o `theme:` está ligado | Ligue os três: `theme`, `darkTheme` e `themeMode` |

---

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [02 — Arquitetura](02-arquitetura.md) | [README do projeto](README.md) | [04 — Etapa 2: Domínio e dados](04-etapa-2-dominio-e-dados.md) |
