# Aula 10 — Avaliando pacotes

> **Módulo:** 11 - Recursos Nativos · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Ler a página de um pacote no **pub.dev** e interpretar cada número que aparece lá.
- Distinguir sinais que **importam** de sinais que **enganam**.
- Verificar **licença**, **manutenção**, **issues** e **árvore de dependências** antes de adotar.
- Entender o que é um **plugin federado** e por que isso afeta a sua escolha.
- Aplicar um **checklist de 10 itens** antes de cada `flutter pub add`.
- Decidir quando **não usar pacote nenhum**.
- Reduzir o risco de um pacote abandonado.

## ✅ Pré-requisitos

- [Módulo 03, aula 10 — Arquivos, bibliotecas e pacotes](../03-dart-intermediario/10-arquivos-bibliotecas-pacotes.md)
  — `pubspec.yaml`, versionamento semântico, `pub get`.
- [Aula 3 — Arquivos e compartilhamento](03-arquivos-e-compartilhamento.md) — a pergunta
  "quando um pacote vale a pena" apareceu lá; aqui ela é respondida por inteiro.
- [Aula 7 — Pastas android/ e ios/](07-pastas-android-e-ios.md) — o que um plugin faz nessas
  pastas.

---

## 📖 Conceito

### Por que isso importa mais do que parece

Cada pacote que você adiciona é uma decisão de **longo prazo**:

- ele entra na sua build e pode **quebrá-la** a cada atualização do Flutter;
- ele pode ser **abandonado**, e você fica com código que não compila mais;
- ele traz **dependências próprias**, que você não escolheu;
- ele adiciona **tamanho** ao APK e **tempo** à compilação;
- se ele tem código nativo, ele pode **impedir** você de subir o `targetSdk`.

> 📌 **A pergunta que abre a avaliação:** *"se este pacote for abandonado amanhã, o que acontece com
> o meu app?"* Se a resposta for "eu removo em uma hora", o risco é baixo. Se for "eu reescrevo
> metade do app", pense duas vezes.

### Os números do pub.dev, e o que cada um vale

A página de um pacote mostra três números grandes:

| Número | O que é | Quanto vale |
|---|---|---|
| **Likes** | Quantas pessoas curtiram | ⚠️ Pouco — mede popularidade, não qualidade |
| **Pub points** | Nota automática de 0 a 160 | ⚠️ Médio — mede **forma**, não conteúdo |
| **Downloads** | Downloads nos últimos 30 dias | ✅ Bom sinal de adoção real |

**Pub points** merece explicação porque é o mais mal interpretado. Ele avalia:

- tem documentação? (`README`, `CHANGELOG`, exemplo)
- passa no `dart analyze` sem erro?
- suporta null safety?
- declara as plataformas?
- as dependências estão atualizadas?

Repare no que ele **não** avalia: se o pacote funciona, se tem bugs, se é seguro, se é mantido. Um
pacote abandonado há dois anos pode ter 160/160.

> ⚠️ **160 pontos não significa "bom pacote".** Significa "bem embalado". Um pacote com 130 pontos e
> commits semanais é melhor que um com 160 e nenhum commit desde 2023.

### Os sinais que realmente importam

| Sinal | Onde ver | O que procurar |
|---|---|---|
| **Data da última publicação** | Topo da página | Menos de 6 meses (ou razão clara) |
| **Publisher verificado** | Ao lado do nome | `flutter.dev`, `dart.dev`, `google.dev` ou um domínio real |
| **Issues abertas × fechadas** | Link do GitHub | Proporção e **tempo de resposta** |
| **Aba Platforms** | Abaixo do nome | As plataformas que você precisa |
| **Licença** | Aba *License* | MIT, BSD, Apache — cuidado com GPL |
| **Dependências** | Aba *Dependencies* | Quantas, e de quem |
| **Último commit** | GitHub | Mais confiável que a data de publicação |

**Publisher verificado** é o sinal isolado mais forte:

| Publisher | O que significa |
|---|---|
| `flutter.dev` / `dart.dev` | **Mantido pelo time do Flutter/Dart** |
| `google.dev` | Mantido pelo Google (mas nem sempre pelo time do Flutter) |
| Domínio de empresa (ex.: `baseflow.com`) | Empresa real por trás |
| Sem publisher | Uma pessoa. Pode ser ótimo — ou sumir amanhã |

> 💡 Os pacotes com o selo `flutter.dev` — `http`, `shared_preferences`, `path_provider`,
> `url_launcher`, `camera`, `video_player`, `google_maps_flutter` — são a aposta mais segura do
> ecossistema. Quando existe um deles para o que você precisa, a decisão está tomada.

### A data que engana

Um pacote publicado há 2 anos **não é necessariamente abandonado**. Pode ser:

- **estável e completo** — faz uma coisa, faz bem, não precisa mudar;
- **abandonado** — o autor sumiu.

Como distinguir:

| Verificação | Abandonado | Estável |
|---|---|---|
| Issues recentes sem resposta | ✅ muitas | ❌ poucas, respondidas |
| Issues do tipo "não compila no Flutter X" | ✅ abertas há meses | ❌ corrigidas |
| Último commit | Mais antigo que a publicação | Recente, mesmo sem publicar |
| Forks ativos com correções | ✅ sinal ruim | ❌ |

> ⚠️ **O sinal mais confiável de abandono:** uma issue dizendo "não compila com a versão atual do
> Flutter", aberta há meses, com muitos 👍 e nenhuma resposta do autor. Isso significa que **você**
> vai ficar preso à versão antiga do Flutter, ou vai precisar do fork de alguém.

### Licenças

| Licença | Pode usar em app comercial? | Obrigação |
|---|---|---|
| **MIT** | ✅ | Manter o aviso de copyright |
| **BSD** (2 ou 3 cláusulas) | ✅ | Idem |
| **Apache 2.0** | ✅ | Idem + aviso de mudanças |
| **LGPL** | ⚠️ | Complicado em app móvel |
| **GPL / AGPL** | ❌ **Não** | Obriga a abrir o código do **seu** app |
| Sem licença | ❌ | Sem licença, **não há permissão de uso** |

> ⚠️ **Sem licença significa "todos os direitos reservados".** Um repositório público sem arquivo de
> licença **não** autoriza o uso — mesmo estando no pub.dev. Na prática o risco é baixo para um app
> pessoal; em app comercial, é um problema jurídico real.

E há a obrigação que quase todo mundo esquece:

> 📌 **Você precisa exibir as licenças dos pacotes no seu app.** O Flutter facilita: o widget
> `AboutDialog` e a função `showLicensePage()` montam essa tela automaticamente, listando todos os
> pacotes. Uma linha de código resolve uma obrigação legal.

### A árvore de dependências

Um pacote traz as dependências dele — e as dependências delas:

```powershell
flutter pub deps --style=tree
```

O que procurar:

| Sinal | Significado |
|---|---|
| Poucas dependências diretas | ✅ menos risco |
| Depende de pacote sem publisher | ⚠️ risco transitivo |
| Depende de versão **antiga** de algo | ⚠️ pode travar as suas atualizações |
| Duas versões do mesmo pacote | ⚠️ conflito iminente |

O problema mais comum na prática é o **conflito de versões**:

```text
Because foco depends on pacote_a >=2.0.0 which depends on
http ^0.13.0, and pacote_b depends on http ^1.0.0, version
solving failed.
```

Você precisa dos dois pacotes, eles exigem versões incompatíveis do mesmo terceiro, e não há saída
limpa. Quanto **menos** dependências cada pacote traz, menos provável isso é.

### Plugins federados

Um **plugin** é um pacote com código nativo. Os bons são **federados**: divididos em partes.

```text
url_launcher                      ← a interface que você usa
├── url_launcher_platform_interface   ← o contrato
├── url_launcher_android              ← a implementação Android
├── url_launcher_ios                  ← a implementação iOS
├── url_launcher_web
├── url_launcher_windows
├── url_launcher_linux
└── url_launcher_macos
```

Por que isso importa para você:

| Vantagem | Consequência prática |
|---|---|
| Uma plataforma pode ser corrigida sozinha | Correção do Android não espera a do iOS |
| Terceiros podem implementar uma plataforma | Suporte a Windows aparece sem o autor original |
| Você vê **quais plataformas** existem de verdade | A aba *Platforms* não mente |

> ⚠️ **A aba *Platforms* pode enganar em plugins não federados.** Um pacote pode declarar suporte a
> iOS e ter uma implementação que nunca foi testada. Em plugins federados, cada plataforma é um
> pacote com issues próprias — e dá para ver se aquela está viva.

### Quando **não** usar pacote

| Precisa de… | Use pacote? |
|---|---|
| Formatar data | ❌ `intl` já vem, ou `DateTime` puro |
| Gerar UUID | ❌ `DateTime.now().microsecondsSinceEpoch` + aleatório resolve |
| Validar e-mail | ❌ uma `RegExp` de 3 linhas |
| Ler/escrever arquivo | ❌ `dart:io` |
| Converter JSON | ❌ `dart:convert` |
| Animação simples | ❌ o Flutter tem tudo |
| Ícones bonitos | ❌ `Icons` tem 2 000+ |
| **API nativa** (câmera, notificação) | ✅ |
| **Tela do sistema** (seletor de arquivo) | ✅ |
| **Protocolo complexo** (Bluetooth, WebRTC) | ✅ |

> 💡 **A regra:** um pacote que você conseguiria escrever em **menos de 200 linhas** provavelmente
> não vale a dependência. Copiar 30 linhas para o seu `core/` é mais seguro que depender de alguém.

### O checklist de 10 itens

Antes de todo `flutter pub add`:

1. **Existe um pacote `flutter.dev` que faz isso?** Se sim, acabou.
2. **Eu consigo escrever isso em menos de 200 linhas?** Se sim, escreva.
3. **Publisher verificado?**
4. **Última publicação há menos de 6 meses** — ou há razão clara para não?
5. **Alguma issue de "não compila na versão atual" aberta há meses?**
6. **A aba *Platforms* cobre as plataformas que eu preciso?**
7. **A licença é permissiva** (MIT, BSD, Apache)?
8. **Quantas dependências ele traz?** Rode `flutter pub deps`.
9. **O exemplo (`example/`) roda?** Se o autor não mantém o exemplo, ele não mantém o pacote.
10. **Se ele for abandonado amanhã, quanto trabalho me custa?**

---

## 💡 Analogia

Pense em contratar um fornecedor para a sua empresa.

- **Os likes** são o número de pessoas que **curtiram a página** do fornecedor. Diz que ele é
  conhecido; não diz que entrega no prazo.
- **Os pub points** são o **certificado ISO**: ele prova que a empresa tem processo documentado,
  organograma e manual de qualidade. **Não** prova que o produto funciona. Uma empresa falida pode
  ter o certificado na parede.
- **Os downloads** são quantas empresas **compram de fato**, todo mês. É o sinal mais próximo da
  realidade — mas mede volume, não satisfação.
- **O publisher verificado** é a diferença entre um fornecedor com CNPJ, endereço e histórico, e um
  contato de WhatsApp. O segundo pode ser excelente; ele também pode parar de responder.
- **As issues sem resposta** são as reclamações no Reclame Aqui sem retorno. Uma reclamação
  respondida diz que há alguém lá; cinquenta sem resposta dizem que a empresa fechou e ninguém
  desligou o site.
- **A licença** é o contrato. Pegar o produto "porque estava disponível" não substitui um contrato —
  e sem licença, é isso que você está fazendo.
- **A árvore de dependências** são os **subcontratados**. O seu fornecedor entrega, mas depende de
  três outros que você nunca avaliou. Se um deles parar, a sua entrega para.
- **O plugin federado** é o fornecedor com **filial em cada estado**. Se a filial de São Paulo tem
  problema, as outras continuam — e dá para ver qual filial está funcionando.

---

## 🧪 Exemplo mínimo

Uma ferramenta que audita as dependências do seu projeto e aponta o que precisa de atenção.

> **Arquivo:** `foco_nativo/tool/auditar_pacotes.dart` (novo)
> **Como executar:** `dart run tool/auditar_pacotes.dart`

```dart
import 'dart:convert';
import 'dart:io';

/// Audita as dependências do projeto.
///
/// Não substitui olhar a página de cada pacote — mas mostra, de uma vez,
/// o que merece atenção.
Future<void> main() async {
  print('═══ AUDITORIA DE PACOTES ═══\n');

  final List<String> diretas = _dependenciasDiretas();
  if (diretas.isEmpty) {
    print('Nenhuma dependência direta encontrada.');
    return;
  }

  print('📦 ${diretas.length} dependências diretas\n');

  int comAviso = 0;
  for (final String nome in diretas) {
    final bool ok = await _auditar(nome);
    if (!ok) comAviso++;
  }

  print('\n═══ RESUMO ═══');
  print('${diretas.length - comAviso} sem avisos · $comAviso com avisos');

  _verificarDesatualizados();
  _verificarLicencasNoApp();
}

/// Lê as dependências diretas do pubspec.yaml.
///
/// Só as DIRETAS: as transitivas importam, mas quem você escolheu
/// são estas.
List<String> _dependenciasDiretas() {
  final File pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print('⚠️ pubspec.yaml não encontrado — rode na raiz do projeto');
    return <String>[];
  }

  final List<String> linhas = pubspec.readAsLinesSync();
  final List<String> nomes = <String>[];
  bool dentroDeDependencies = false;

  for (final String linha in linhas) {
    if (linha.startsWith('dependencies:')) {
      dentroDeDependencies = true;
      continue;
    }
    // Qualquer seção nova (sem indentação) encerra o bloco.
    if (dentroDeDependencies &&
        linha.isNotEmpty &&
        !linha.startsWith(' ') &&
        !linha.startsWith('#')) {
      break;
    }
    if (!dentroDeDependencies) continue;

    final RegExpMatch? m = RegExp(r'^  ([a-z_0-9]+):').firstMatch(linha);
    if (m == null) continue;

    final String nome = m.group(1)!;
    // `flutter` e `flutter_localizations` vêm do SDK, não do pub.
    if (nome == 'flutter' || nome == 'flutter_localizations') continue;
    nomes.add(nome);
  }

  return nomes;
}

/// Consulta o pub.dev e reporta os sinais que importam.
Future<bool> _auditar(String nome) async {
  final HttpClient cliente = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);

  try {
    final HttpClientRequest req =
        await cliente.getUrl(Uri.parse('https://pub.dev/api/packages/$nome'));
    final HttpClientResponse resposta = await req.close();

    if (resposta.statusCode != 200) {
      print('❓ $nome — não encontrado no pub.dev '
          '(pacote local ou do Git?)');
      return true;
    }

    final Map<String, Object?> dados = jsonDecode(
      await resposta.transform(utf8.decoder).join(),
    ) as Map<String, Object?>;

    final Map<String, Object?> ultima =
        dados['latest']! as Map<String, Object?>;
    final String versao = ultima['version']! as String;
    final DateTime publicado = DateTime.parse(ultima['published']! as String);
    final int mesesAtras =
        DateTime.now().difference(publicado).inDays ~/ 30;

    final Map<String, Object?> pubspec =
        ultima['pubspec']! as Map<String, Object?>;
    final Object? repositorio = pubspec['repository'] ?? pubspec['homepage'];

    final List<String> avisos = <String>[];

    // ── Sinal 1: última publicação ──
    //
    // 12+ meses NÃO significa abandonado: pode ser estável e completo.
    // Mas merece uma olhada nas issues.
    if (mesesAtras >= 18) {
      avisos.add('última publicação há $mesesAtras meses — confira as issues');
    } else if (mesesAtras >= 12) {
      avisos.add('última publicação há $mesesAtras meses');
    }

    // ── Sinal 2: repositório declarado ──
    //
    // Sem repositório, você não consegue ver issues, commits nem forks.
    // É o pior sinal desta lista.
    if (repositorio == null) {
      avisos.add('SEM repositório declarado — impossível auditar');
    }

    // ── Sinal 3: dependências ──
    final Map<String, Object?>? deps =
        pubspec['dependencies'] as Map<String, Object?>?;
    final int quantasDeps = (deps?.keys.where(
              (String k) => k != 'flutter',
            ).length) ??
        0;
    if (quantasDeps > 8) {
      avisos.add('$quantasDeps dependências — árvore grande');
    }

    // ── Sinal 4: versão pré-1.0 ──
    //
    // Em versionamento semântico, 0.x permite QUEBRAR a API em
    // qualquer atualização menor. Não é proibitivo — é um aviso.
    if (versao.startsWith('0.')) {
      avisos.add('versão $versao (pré-1.0): a API pode quebrar');
    }

    final String selo = avisos.isEmpty ? '✅' : '⚠️';
    print('$selo $nome $versao — publicado há $mesesAtras meses');
    for (final String aviso in avisos) {
      print('     └─ $aviso');
    }
    if (repositorio != null) {
      print('     └─ $repositorio');
    }

    return avisos.isEmpty;
  } on Object catch (e) {
    print('❓ $nome — falha ao consultar: ${e.runtimeType}');
    return true;
  } finally {
    cliente.close();
  }
}

/// Roda `flutter pub outdated` e resume.
void _verificarDesatualizados() {
  print('\n═══ DESATUALIZADOS ═══\n');

  final ProcessResult r = Process.runSync(
    'flutter',
    <String>['pub', 'outdated', '--no-dev-dependencies'],
    runInShell: true,
  );

  final String saida = '${r.stdout}';
  if (saida.contains('are up-to-date') || saida.trim().isEmpty) {
    print('✅ tudo atualizado');
    return;
  }
  print(saida);
}

/// Verifica se o app EXIBE as licenças dos pacotes.
///
/// Não é opcional: quase toda licença permissiva (MIT, BSD, Apache)
/// exige manter o aviso de copyright. O Flutter monta essa tela
/// automaticamente — é uma linha de código.
void _verificarLicencasNoApp() {
  print('\n═══ LICENÇAS NO APP ═══\n');

  final Directory lib = Directory('lib');
  if (!lib.existsSync()) return;

  bool encontrou = false;
  for (final FileSystemEntity e in lib.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;

    final String conteudo = e.readAsStringSync();
    if (conteudo.contains('showLicensePage') ||
        conteudo.contains('showAboutDialog') ||
        conteudo.contains('LicensePage')) {
      encontrou = true;
      print('✅ licenças exibidas em ${e.path}');
      break;
    }
  }

  if (!encontrou) {
    print('⚠️ O app NÃO exibe as licenças dos pacotes.');
    print('   Quase toda licença permissiva exige manter o aviso de');
    print('   copyright. O Flutter monta a tela sozinho:');
    print('');
    print('   showLicensePage(');
    print("     context: context,");
    print("     applicationName: 'Foco',");
    print("     applicationVersion: '1.0.0',");
    print('   );');
  }
}
```

```powershell
dart run tool/auditar_pacotes.dart
```

**O que observar na saída:**

1. Pacotes `flutter.dev` (`http`, `shared_preferences`, `path_provider`) quase sempre saem limpos.
2. Pacotes de terceiros costumam ter **pelo menos um** aviso — o que não é motivo para remover, e é
   motivo para **olhar a página**.
3. A verificação de licenças provavelmente vai falhar na primeira vez. É uma linha de código para
   resolver.

---

## 📱 Aplicando no Flutter

Agora você avalia, de verdade, os pacotes que o `foco_nativo` usa — e implementa a tela de
licenças que o app deve ter.

---

## 💻 Código completo

> **Arquivo:** `foco_nativo/docs/decisoes-de-pacotes.md` (novo)
>
> Um registro das decisões. Parece burocracia até o dia em que alguém (você, em seis meses)
> pergunta "por que usamos este e não aquele?".

```markdown
# Decisões de pacotes — Foco

Registro de cada dependência: por que ela existe, o que foi avaliado, e
qual é o plano se ela for abandonada.

Atualizado em: 2026-03-10

---

## Critérios usados

Todo pacote passou pelo checklist de 10 itens da
[aula 10 do Módulo 11](../../curso-flutter-intensivo/modulos/11-recursos-nativos/10-avaliando-pacotes.md).

---

## `http` ^1.6.0

| Item | Avaliação |
|---|---|
| Publisher | ✅ `dart.dev` — mantido pelo time do Dart |
| Última publicação | ✅ recente |
| Alternativa considerada | `dio` |
| Por que este | Vem do time do Dart; `dio` tem mais recursos e mais superfície |
| Dependências | 3, todas do time do Dart |
| Se for abandonado | Praticamente impossível. E `dio` é substituto direto |
| Risco | **Baixo** |

**Por que não `dio`:** ele tem interceptadores, cancelamento e retry prontos —
o que o curso ensina a escrever à mão (Módulo 09, aula 6). Para um app deste
tamanho, o `http` basta, e a superfície menor significa menos coisa para
quebrar.

---

## `shared_preferences` ^2.5.5

| Item | Avaliação |
|---|---|
| Publisher | ✅ `flutter.dev` |
| Federado | ✅ 6 plataformas, cada uma com pacote próprio |
| Alternativa | `hive`, `get_storage` |
| Por que este | Time do Flutter; API mínima; sem migração para manter |
| Se for abandonado | Improvável. Substituível em ~50 linhas |
| Risco | **Baixo** |

---

## `sqflite` ^2.4.4

| Item | Avaliação |
|---|---|
| Publisher | ⚠️ `tekartik.com` — pessoa física com domínio |
| Última publicação | ✅ recente |
| Issues | ✅ respondidas em dias |
| Alternativa | `drift`, `isar`, `objectbox` |
| Por que este | SQL direto, sem geração de código; o mais usado do ecossistema |
| Se for abandonado | **Médio impacto**: o SQL continua válido; trocar a camada de acesso é trabalho de dias, não de semanas |
| Risco | **Médio** |

**Mitigação:** todo acesso ao banco passa pelos DAOs em
`features/*/data/`. Nenhuma tela importa `sqflite`. Trocar o pacote
significa reescrever os DAOs, não o app.

---

## `flutter_secure_storage` ^11.1.1

| Item | Avaliação |
|---|---|
| Publisher | ⚠️ sem publisher verificado |
| Última publicação | ✅ recente |
| Issues | ⚠️ algumas abertas sobre Keystore no Android |
| Alternativa | Escrever o canal de plataforma à mão |
| Por que este | Escrever Keychain + Keystore à mão é código Swift **e** Kotlin |
| Se for abandonado | **Alto impacto**: é código nativo |
| Risco | **Médio-alto** |

**Mitigação:** o acesso passa por `core/seguranca/cofre.dart`, com um
contrato próprio (Módulo 10, aula 7). O app depende do **contrato**,
não do pacote.

---

## `connectivity_plus` ^7.3.1

| Item | Avaliação |
|---|---|
| Publisher | ✅ `fluttercommunity.dev` |
| Federado | ✅ |
| Por que este | O padrão do ecossistema para isso |
| Se for abandonado | Baixo impacto: uso é pequeno e isolado |
| Risco | **Baixo** |

---

## Recusados

### `intl_phone_field`

Precisávamos de um campo de telefone formatado. **Recusado**: última
publicação há 2 anos, issue "não compila no Flutter 3.2x" aberta há
14 meses sem resposta.

**Decisão:** `TextFormField` + `inputFormatters` próprio, 40 linhas em
`core/formato/telefone.dart`.

### `uuid`

Precisávamos de identificadores únicos. **Recusado** pelo item 2 do
checklist: `'m_${DateTime.now().microsecondsSinceEpoch}'` resolve, e
`Random.secure()` cobre o caso em que a unicidade precisa ser forte.

**Decisão:** `core/ids.dart`, 12 linhas.

### `flutter_datetime_picker`

Precisávamos de um seletor de data no estilo iOS. **Recusado**:
abandonado, e o `CupertinoDatePicker` já vem no Flutter.

**Decisão:** `core/adaptativo/dialogos_adaptativos.dart` (Módulo 11,
aula 9).
```

> **Arquivo:** `foco_nativo/lib/features/ajustes/presentation/sobre_screen.dart` (novo)

```dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Tela "Sobre", com a página de licenças.
///
/// ⚠️ Exibir as licenças NÃO é opcional: MIT, BSD e Apache — as
/// licenças de praticamente todo pacote que você usa — exigem manter
/// o aviso de copyright.
///
/// O Flutter monta a tela sozinho, listando cada pacote e cada
/// licença. É uma linha de código para cumprir uma obrigação legal.
class SobreScreen extends StatefulWidget {
  const SobreScreen({super.key});

  @override
  State<SobreScreen> createState() => _SobreScreenState();
}

class _SobreScreenState extends State<SobreScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    // Lê do próprio binário: versão, build e identificador.
    // Escrever a versão à mão em duas telas garante que uma
    // fique desatualizada.
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _info = info);
  }

  @override
  Widget build(BuildContext context) {
    final PackageInfo? info = _info;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 24),
          const Center(child: Icon(Icons.school_outlined, size: 64)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              info?.appName ?? 'Foco',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              info == null
                  ? '—'
                  : 'Versão ${info.version} (${info.buildNumber})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Licenças de código aberto'),
            subtitle: const Text('Pacotes usados neste app'),
            trailing: const Icon(Icons.chevron_right),
            // showLicensePage monta a tela INTEIRA sozinho: lista cada
            // pacote, cada licença, e o texto completo de cada uma.
            onTap: () => showLicensePage(
              context: context,
              applicationName: info?.appName ?? 'Foco',
              applicationVersion: info?.version ?? '',
              applicationIcon: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.school_outlined, size: 48),
              ),
              applicationLegalese: '© 2026 Curso Flutter Intensivo',
            ),
          ),

          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Identificador do app'),
            subtitle: Text(info?.packageName ?? '—'),
          ),
        ],
      ),
    );
  }
}
```

> **Arquivo:** `foco_nativo/lib/core/ids.dart` (o pacote que **não** usamos)

```dart
import 'dart:math' as math;

/// Identificadores únicos.
///
/// Existe para NÃO depender do pacote `uuid`.
///
/// Item 2 do checklist da aula: "eu consigo escrever isso em menos de
/// 200 linhas?". Aqui foram 12 — e uma dependência a menos é uma coisa
/// a menos que pode quebrar na próxima atualização do Flutter.
abstract final class Ids {
  static final math.Random _aleatorio = math.Random.secure();

  /// Id único para uso local.
  ///
  /// microsecondsSinceEpoch dá ordenação cronológica; os 4 dígitos
  /// aleatórios evitam colisão quando dois ids são gerados no mesmo
  /// microssegundo.
  static String gerar([String prefixo = '']) {
    final int agora = DateTime.now().microsecondsSinceEpoch;
    final int sal = _aleatorio.nextInt(9999);
    final String id = '${agora.toRadixString(36)}${sal.toRadixString(36)}';
    return prefixo.isEmpty ? id : '${prefixo}_$id';
  }

  /// Quando a unicidade precisa resistir a adivinhação — um token de
  /// convite, por exemplo. Aí sim vale a aleatoriedade forte.
  static String seguro([int bytes = 16]) {
    final List<int> valores =
        List<int>.generate(bytes, (_) => _aleatorio.nextInt(256));
    return valores
        .map((int b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
```

Rode a auditoria e confira o app:

```powershell
dart run tool/auditar_pacotes.dart
flutter pub outdated
flutter analyze
flutter run
```

Abra **Ajustes → Sobre → Licenças** e veja a tela que o Flutter montou sozinho.

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `docs/decisoes-de-pacotes.md` | Parece burocracia até alguém perguntar "por que este e não aquele?" — inclusive você, em seis meses. |
| A coluna "Se for abandonado" | A pergunta que abre a avaliação. Um pacote de risco alto precisa de **mitigação**. |
| A seção "Recusados" | Registrar o que você **não** usou evita reavaliar a mesma coisa duas vezes. |
| Mitigação do `flutter_secure_storage` | O app depende do **contrato** (`Cofre`), não do pacote. Trocar significa escrever uma classe. |
| `PackageInfo.fromPlatform()` | Lê a versão do **binário**. Escrever à mão em duas telas garante que uma desatualize. |
| `showLicensePage(...)` | Monta a tela inteira sozinho. **Uma linha** para cumprir uma obrigação legal. |
| `Ids` com 12 linhas | Item 2 do checklist: se cabe em 200 linhas, escreva. Uma dependência a menos. |
| `microsecondsSinceEpoch` + `toRadixString(36)` | Ordenação cronológica e id curto. Base 36 usa dígitos e letras. |
| `Random.secure()` no `Ids.seguro` | `Random()` comum é previsível — inaceitável para token. |
| `_dependenciasDiretas` ignorando `flutter` | Vem do SDK, não do pub. |
| Aviso de `versão 0.x` | Em versionamento semântico, `0.x` permite **quebrar a API** em qualquer atualização menor. |
| Aviso de "sem repositório" | Sem ele você não vê issues, commits nem forks — o pior sinal da lista. |
| `_verificarLicencasNoApp` | A obrigação mais esquecida. O script pega antes da loja. |

---

## 🤖🍎 Android × iOS

O que um **plugin** (pacote com código nativo) traz para as pastas nativas:

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Como entra | Dependência Gradle | Pod (CocoaPods) |
| Pode exigir `minSdk` maior | ✅ | ✅ (`platform :ios`) |
| Pode exigir permissão no manifest | ✅ | ✅ (`Info.plist`) |
| Aumenta o tamanho do app | ✅ | ✅ |
| Pode quebrar com atualização do SO | ✅ | ✅ |
| Suporte a plataforma declarado | Aba *Platforms* | Aba *Platforms* |

> ⚠️ **O risco mais concreto de um plugin abandonado:** ele trava o seu `minSdk` ou `targetSdk`. Se
> o Google passa a exigir `targetSdk 35` e o plugin não compila com ele, você **não consegue
> publicar a atualização** — até alguém corrigir o plugin, ou você removê-lo.
>
> Isso já aconteceu com vários plugins populares. É por isso que "publisher verificado" e "issues
> respondidas" pesam mais em plugins do que em pacotes Dart puros.

> 📌 **Um pacote Dart puro** (sem código nativo) é sempre mais seguro: se ele for abandonado, o
> código continua compilando. O risco é de segurança e de recursos novos, não de build quebrada.
> A aba *Platforms* mostra "Dart" quando é o caso.

---

## ⚠️ Erros comuns

### 1. Escolher pelos likes

O pacote mais curtido pode ser de 2021.

**Correção:** data, publisher e issues.

### 2. Confiar em 160 pub points

Mede **forma**, não conteúdo. Um pacote abandonado pode ter nota máxima.

**Correção:** combine com os sinais de manutenção.

### 3. Não olhar as issues

O `README` nunca diz "não compila com a versão atual". A issue com 40 👍 diz.

**Correção:** abra o GitHub, ordene por reações.

### 4. Adicionar pacote para 20 linhas de código

```powershell
flutter pub add uuid   # ⚠️ para gerar um id
```

**Correção:** item 2 do checklist.

### 5. Não verificar a licença

GPL num app comercial obriga você a **abrir o código do app**.

**Correção:** aba *License*.

### 6. Não exibir as licenças no app

Quase toda licença permissiva **exige** o aviso de copyright.

**Correção:** `showLicensePage` — uma linha.

### 7. Ignorar a árvore de dependências

Você adiciona um pacote e ganha doze.

**Correção:** `flutter pub deps --style=tree`.

### 8. Usar `any` ou fixar versão exata

```yaml
http: any        # ❌ qualquer versão, inclusive uma que quebra
http: 1.6.0      # ⚠️ nenhuma correção de segurança chega
```

**Correção:** `^1.6.0` — aceita correções e minor, recusa breaking.

### 9. Depender de pacote direto do Git sem `ref`

```yaml
pacote:
  git: https://github.com/alguem/pacote.git   # ⚠️ segue o branch principal
```

Um commit do autor quebra a sua build, sem aviso.

**Correção:** fixe um `ref:` (tag ou commit).

### 10. Não registrar a decisão

Seis meses depois, ninguém lembra por que aquele pacote foi escolhido — e alguém troca por outro
pior.

**Correção:** `docs/decisoes-de-pacotes.md`.

### 11. Adotar plugin nativo sem plano B

Ele trava o seu `targetSdk` e você não consegue publicar.

**Correção:** isole atrás de um contrato próprio, como o `Cofre` do Módulo 10.

### 12. Nunca rodar `flutter pub outdated`

Você descobre que está 8 versões atrás no dia em que precisa de uma correção de segurança.

**Correção:** rode uma vez por mês.

---

## 🛠️ Exercício guiado

**Passo 1.** Rode `dart run tool/auditar_pacotes.dart`. Anote quais pacotes receberam avisos.

**Passo 2.** Para cada aviso, abra a página no pub.dev e verifique: é abandono ou estabilidade?

**Passo 3.** Abra o GitHub de um pacote de terceiros que você usa. Ordene as issues por 👍. A
primeira tem resposta do autor?

**Passo 4.** Rode `flutter pub deps --style=tree`. Qual pacote traz mais dependências? Você sabia?

**Passo 5.** Rode `flutter pub outdated`. Quantos estão desatualizados? Algum com **major** nova?

**Passo 6.** Verifique a licença de cada dependência (aba *License*). Alguma é GPL?

**Passo 7.** Abra **Sobre → Licenças** no app. Quantos pacotes aparecem? Compare com as
dependências diretas — a diferença são as transitivas.

**Passo 8.** Escolha um pacote popular que o Foco **não** usa e aplique os 10 itens. Você adotaria?

**Passo 9.** Procure um pacote que faça algo que você escreveria em menos de 200 linhas. Escreva a
sua versão e compare.

**Passo 10.** Preencha `docs/decisoes-de-pacotes.md` para uma dependência que ainda não está lá,
incluindo o plano se ela for abandonada.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md)

Faça os exercícios de **Avaliação** com o checklist, o de **Decisão** sobre pacote × código próprio,
e o de **Correção de bugs** com versão fixada errada.

---

## 🏆 Desafio opcional

Transforme a auditoria em uma **verificação de CI** que falha o build.

Requisitos:

- Falha se alguma dependência direta tiver licença **não permissiva** (GPL, AGPL, sem licença).
- Falha se alguma tiver última publicação há mais de **24 meses**.
- Falha se o app **não** exibir `showLicensePage`.
- Avisa (sem falhar) sobre versões `0.x` e sobre pacotes sem publisher verificado.
- Gera um relatório em Markdown, para anexar ao PR.
- Aceita uma lista de **exceções aprovadas** em `tool/pacotes_aprovados.yaml`, com justificativa e
  data de revisão.

Dica: a API do pub.dev tem `https://pub.dev/api/packages/<nome>` (metadados) e
`https://pub.dev/api/packages/<nome>/score` (pub points, likes, downloads). O `LicenseRegistry` do
Flutter lista as licenças em tempo de execução.

Depois responda: por que a lista de exceções precisa de **data de revisão**? O que acontece com uma
exceção sem prazo, depois de dois anos?

---

## 📌 Resumo

- Cada pacote é uma decisão de **longo prazo**. A pergunta que abre a avaliação: *"se for
  abandonado amanhã, o que acontece com o meu app?"*
- **Likes** medem popularidade; **pub points** medem **forma**, não conteúdo; **downloads** são o
  melhor dos três.
- **160 pub points não significa bom pacote.** Significa bem embalado.
- Os sinais que importam: **data da última publicação**, **publisher verificado**, **issues
  respondidas**, **aba Platforms**, **licença**, **dependências**.
- O selo **`flutter.dev`** é a aposta mais segura do ecossistema.
- Publicação antiga **não** é abandono automático. O sinal claro é uma issue "não compila com o
  Flutter atual", aberta há meses, sem resposta.
- **GPL/AGPL não servem** para app comercial. **Sem licença** significa "todos os direitos
  reservados".
- **Exibir as licenças no app é obrigação legal** — e `showLicensePage` resolve em uma linha.
- **Plugins federados** permitem corrigir uma plataforma sozinha, e mostram o suporte real.
- Um pacote que você escreveria em **menos de 200 linhas** provavelmente não vale a dependência.
- **Plugins nativos podem travar o seu `targetSdk`** — e impedir a publicação. Isole-os atrás de um
  contrato próprio.
- Use **`^versao`**, nunca `any` nem versão exata. Pacote do Git precisa de `ref:`.
- **Registre as decisões** em `docs/decisoes-de-pacotes.md`, inclusive as recusas.

---

## ☑️ Checklist de domínio

- [ ] Sei o que likes, pub points e downloads medem — e o que não medem.
- [ ] Verifico publisher, data, issues e aba Platforms antes de adotar.
- [ ] Distingo pacote estável de pacote abandonado.
- [ ] Verifico a licença e sei quais são proibitivas.
- [ ] Meu app exibe as licenças com `showLicensePage`.
- [ ] Rodo `flutter pub deps` antes de adotar.
- [ ] Sei o que é plugin federado e por que importa.
- [ ] Aplico o item "menos de 200 linhas" antes de adicionar.
- [ ] Isolo plugins nativos atrás de um contrato próprio.
- [ ] Uso `^versao` e fixo `ref:` em dependências de Git.
- [ ] Rodo `flutter pub outdated` regularmente.
- [ ] Registro as decisões — inclusive as recusas.

---

## 📚 Referências oficiais

- [pub.dev](https://pub.dev/)
- [Package scoring — pub.dev](https://pub.dev/help/scoring)
- [Publishing packages — dart.dev](https://dart.dev/tools/pub/publishing)
- [Package dependencies — dart.dev](https://dart.dev/tools/pub/dependencies)
- [Federated plugins — docs.flutter.dev](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins)
- [Using packages — docs.flutter.dev](https://docs.flutter.dev/packages-and-plugins/using-packages)
- [showLicensePage — api.flutter.dev](https://api.flutter.dev/flutter/material/showLicensePage.html)
- [Choose a license — choosealicense.com](https://choosealicense.com/)

---

## 🎓 Fim do Módulo 11

Você começou o módulo com um app que só existia dentro da própria tela. Termina com:

- **permissões** pedidas no momento certo, com todos os estados tratados (aula 1);
- **câmera e galeria** funcionando, com cancelamento e limites entendidos (aula 2);
- **arquivos e compartilhamento** com backup validado e escopo de armazenamento respeitado (aula 3);
- **notificações** agendadas com fuso correto, sobrevivendo ao reboot (aula 4);
- **conectividade** usada para explicar, nunca para decidir (aula 5);
- **ciclo de vida** tratado, com um cronômetro que não mente (aula 6);
- as **pastas nativas** deixando de ser assustadoras (aula 7);
- **navegação** que respeita o dedo do usuário nas duas plataformas (aulas 8 e 9);
- e critério para **escolher dependências** sem se arrepender (aula 10).

Antes de seguir:

1. Faça os exercícios em
   [exercicios/11-recursos-nativos.md](../../exercicios/11-recursos-nativos.md).
2. Faça a avaliação em
   [avaliacoes/modulo-11-recursos-nativos.md](../../avaliacoes/modulo-11-recursos-nativos.md).
3. Confirme que `flutter analyze` e `flutter test` no `foco_nativo` passam limpos.

No [Módulo 12](../12-testes-e-debug/README.md) você para de descobrir bugs por acidente: DevTools,
testes de unidade, de widget e de integração passam a encontrá-los antes do usuário.

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo |
|---|---|---|
| [Aula 9 — Material × Cupertino](09-material-x-cupertino.md) | [README](README.md) | [Módulo 12 — Testes e Debug](../12-testes-e-debug/README.md) |
