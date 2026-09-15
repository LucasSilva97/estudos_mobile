# Gabarito — Módulo 11: Recursos nativos

> Compare depois de resolver os [exercícios](../exercicios/11-recursos-nativos.md).

<a id="m11-e01"></a>
## M11-E01
```dart
typedef AvisoDePermissao = ({String texto, String rotuloBotao});

AvisoDePermissao avisoDe(ResultadoPermissao estado) => switch (estado) {
      ResultadoPermissao.concedida =>
        (texto: 'Permissão concedida. A câmera já está liberada.', rotuloBotao: 'Tirar foto'),
      ResultadoPermissao.parcial =>
        (texto: 'Acesso parcial: só os itens liberados aparecem.', rotuloBotao: 'Escolher mais itens'),
      ResultadoPermissao.negada =>
        (texto: 'Sem problema. Dá para liberar quando quiser.', rotuloBotao: 'Pedir de novo'),
      ResultadoPermissao.negadaParaSempre =>
        (texto: 'O sistema não vai mais perguntar. Libere nos ajustes.', rotuloBotao: 'Abrir ajustes'),
      ResultadoPermissao.bloqueadaPeloSistema =>
        (texto: 'Este aparelho bloqueia a câmera por política de segurança.', rotuloBotao: 'Entendi'),
    };

Future<void> aoTocarNoBotao(ServicoPermissoes servico, ResultadoPermissao estado) async {
  switch (estado) {
    case ResultadoPermissao.negadaParaSempre:
      await servico.abrirAjustes();
    case ResultadoPermissao.concedida:
    case ResultadoPermissao.bloqueadaPeloSistema:
      return; // não há o que pedir
    case ResultadoPermissao.negada:
    case ResultadoPermissao.parcial:
      await servico.pedir(Permission.camera);
  }
}
```
Sem `default`, o compilador aponta o caso faltante no dia em que o enum ganhar um sexto valor.

<a id="m11-e02"></a>
## M11-E02
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>

    <application
        android:label="Foco"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
```
O defeito: `<uses-permission>` é filha direta de `<manifest>`; dentro de `<application>` o compilador de recursos a ignora em silêncio em vez de falhar, então o APK sai sem a permissão e o primeiro `request()` já volta `negadaParaSempre`.

<a id="m11-e03"></a>
## M11-E03
```dart
Future<void> _trocarCapa() async {
  setState(() => _ocupado = true);
  try {
    final XFile? imagem = await _servico.escolherDaGaleria();
    if (imagem == null) return; // cancelou: a capa atual continua intacta

    final String? anterior = _caminhoCapa;
    final String definitivo = await _servico.guardarComoCapa(imagem, widget.idMateria);
    // Apaga só DEPOIS de gravar, e nunca o arquivo recém-escrito: a mesma
    // matéria com a mesma extensão produz exatamente o mesmo caminho.
    if (anterior != null && anterior != definitivo) {
      await _servico.removerCapa(anterior);
    }
    if (!mounted) return;
    setState(() => _caminhoCapa = definitivo);
  } on Exception catch (erro) {
    if (!mounted) return;
    _avisar('Não foi possível trocar a capa: $erro');
  } finally {
    if (mounted) setState(() => _ocupado = false);
  }
}
```
O `return` antes de qualquer escrita é o que garante que cancelar não apague nada.

<a id="m11-e04"></a>
## M11-E04
**Por que `XFile?` e não `File?`.** `XFile` é a abstração do `cross_file`, que também funciona na web, onde `File` de `dart:io` não existe. O `?` não é decoração: `null` significa que a pessoa fechou o seletor, e cancelar é comportamento normal, não erro.

**`imageQuality: 85` e `maxWidth: 1600`.** O plugin recomprime e redimensiona a imagem no lado nativo, antes de o caminho chegar ao Dart. Uma foto de 8 MB vira algo em torno de 300 KB, e você nunca carrega os 8 MB na memória do app.

**Por que copiar para `getApplicationDocumentsDirectory()`.** O `XFile` aponta para a pasta de cache, que o sistema pode esvaziar a qualquer momento. Guardar esse `.path` no banco produz capas que somem sozinhas; o que vai para o banco é o caminho da cópia permanente.

<a id="m11-e05"></a>
## M11-E05
`documentos/backups` fica dentro da **sandbox** do app — a área privada que o sistema entrega a cada aplicativo e que só ele enxerga. Escrever ali não exige permissão nenhuma porque não há nada de terceiros a proteger: o app está escrevendo na própria casa.

A pasta Downloads é área compartilhada, e o **escopo de armazenamento** (Android 10+, obrigatório no 11) acabou com o acesso direto a ela. Para gravar lá você não pede uma permissão: abre o seletor do sistema (`saveFile`), e é o usuário quem escolhe o destino e concede acesso àquele arquivo específico.

Na desinstalação, tudo que está na sandbox vai junto — inclusive os backups. Por isso o backup só cumpre a função quando o usuário compartilha o arquivo para fora (Drive, e-mail, app Arquivos).

<a id="m11-e06"></a>
## M11-E06
| Configuração | Caminho a partir de `foco_nativo/` | Versionado? |
|---|---|---|
| `applicationId` | `android/app/build.gradle.kts` | ✅ |
| `minSdk` | `android/app/build.gradle.kts` | ✅ |
| `<uses-permission>` | `android/app/src/main/AndroidManifest.xml` | ✅ |
| `NSCameraUsageDescription` | `ios/Runner/Info.plist` | ✅ |
| Nome exibido no Android | `android/app/src/main/AndroidManifest.xml` (`android:label`) | ✅ |
| Caminho do SDK da sua máquina | `android/local.properties` | ❌ gerado |
| Caminhos e flags do build iOS | `ios/Flutter/Generated.xcconfig` | ❌ gerado |
| Versões exatas dos Pods | `ios/Podfile.lock` | ✅ |

`Podfile.lock` é versionado justamente para todo mundo compilar com as mesmas versões; `local.properties` e `Generated.xcconfig` são regenerados a cada build e carregam caminhos da sua máquina.

<a id="m11-e07"></a>
## M11-E07
```dart
final NotifierProvider<CronometroController, SessaoEmAndamento?> cronometroProvider =
    NotifierProvider<CronometroController, SessaoEmAndamento?>(CronometroController.new);

class CronometroController extends Notifier<SessaoEmAndamento?> {
  Timer? _tique;

  @override
  SessaoEmAndamento? build() {
    ref.onDispose(() => _tique?.cancel());
    return null;
  }

  void iniciar(String materiaId) {
    state = SessaoEmAndamento(materiaId: materiaId, iniciadaEm: DateTime.now());
    _iniciarTique();
  }

  /// Vem do relógio, nunca de um contador.
  int get minutos => state?.minutos ?? 0;

  void _iniciarTique() {
    _tique?.cancel();
    // O Timer só existe para a tela redesenhar. Se ele congelar em segundo
    // plano, o VALOR não muda: decorrido é DateTime.now() - iniciadaEm.
    _tique = Timer.periodic(const Duration(seconds: 1), (_) => ref.notifyListeners());
  }

  Future<void> aoPausarApp() async {
    _tique?.cancel();
    await salvar(); // `paused` é o último callback confiável; `detached` pode não vir
  }

  void aoVoltarApp(Duration tempoFora) {
    if (state?.rodando ?? false) _iniciarTique();
  }
}
```
```dart
ObservadorDeCiclo(
  aoPausar: () => ref.read(cronometroProvider.notifier).aoPausarApp(),
  aoVoltar: (Duration tempoFora) async =>
      ref.read(cronometroProvider.notifier).aoVoltarApp(tempoFora),
)..iniciar();
```
O defeito era somar disparos de `Timer`: isso mede o tempo em que o Dart esteve acordado, não o tempo real de estudo — com `iniciadaEm` 40 min atrás, `minutos` devolve 40 mesmo que o timer nunca tenha disparado.

<a id="m11-e08"></a>
## M11-E08
**(a) "você não estudou hoje", 21h: local.** Quem dispara é o próprio app, e o dado que decide se vale avisar já está no sqflite do aparelho. O agendamento fica no sistema, dispara sem internet e não custa backend nenhum.

**(b) "um colega convidou você": push.** O evento nasce em outro aparelho e só o servidor sabe que aconteceu; o Foco instalado no seu celular não tem como adivinhar. Isso exige FCM/APNs, certificados e um backend que guarda tokens de dispositivo e trata token expirado.

O critério é sempre esse: se a informação já está no aparelho, é local; se ela nasce fora dele, é push.

<a id="m11-e09"></a>
## M11-E09
```dart
final Provider<ObservadorDeRede> observadorDeRedeProvider =
    Provider<ObservadorDeRede>((Ref ref) => ObservadorDeRede());

final StreamProvider<LeituraDeRede> estadoDeRedeProvider =
    StreamProvider<LeituraDeRede>((Ref ref) async* {
  final ObservadorDeRede observador = ref.watch(observadorDeRedeProvider);
  // Obrigatório: onConnectivityChanged só emite em MUDANÇAS. Sem este yield,
  // quem abre o app e não mexe em nada fica em AsyncLoading para sempre.
  yield await observador.atual();
  yield* observador.observar();
});
```
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final LeituraDeRede? rede = ref.watch(estadoDeRedeProvider).value;
  final bool caiu = rede?.estado == EstadoDeRede.semInterface;

  return Scaffold(
    appBar: AppBar(title: const Text('Hoje')),
    body: Column(
      children: <Widget>[
        if (caiu) BannerDeRede(texto: 'Sem ${rede!.tipo.rotulo} · mostrando dados salvos'),
        const Expanded(child: ListaDeSessoes()),
      ],
    ),
  );
}
```
Enquanto o provider carrega, `value` é `null` e o banner não aparece — assumir offline faria a faixa piscar a cada abertura do app.

<a id="m11-e10"></a>
## M11-E10
`comInterface` só afirma que existe uma interface de rede ativa. O Wi-Fi de hotel é o exemplo exato: o aparelho associa, ganha IP, o `connectivity_plus` reporta Wi-Fi, e todo o tráfego é sequestrado para uma página de login no navegador. O app está "conectado" e nenhuma requisição chega ao servidor.

Por isso só `certamenteOffline` (`semInterface`) é base segura para decisão: a ausência de interface é certeza, a presença é probabilidade. `verificarDeVerdade()` custa uma requisição a mais e só compensa em tela de diagnóstico ou antes de uma operação cara e irreversível — nunca antes de cada chamada, porque a resposta já pode estar velha na linha seguinte.

<a id="m11-e11"></a>
## M11-E11
```dart
@override
void initState() {
  super.initState();
  // Sem este listener o canPop congela no valor do primeiro build — e o
  // Android 14+ lê canPop ANTES do gesto, para animar a espiada.
  _nome.addListener(() => setState(() {}));
}

bool get _temAlteracoes => _nome.text.trim() != widget.materia.nome;

@override
Widget build(BuildContext context) {
  return PopScope(
    canPop: !_temAlteracoes, // sem alterações: sai no primeiro toque, sem diálogo
    onPopInvokedWithResult: (bool saiu, Object? resultado) async {
      if (saiu) return;
      final bool descartar = await confirmarAdaptativo(
        context,
        titulo: 'Descartar alterações?',
        mensagem: 'As alterações desta matéria não foram salvas.',
        rotuloConfirmar: 'Descartar',
        rotuloCancelar: 'Continuar editando',
        destrutivo: true,
      );
      if (descartar && mounted) Navigator.of(context).pop();
    },
    child: Scaffold(appBar: AppBar(title: const Text('Matéria')), body: _formulario()),
  );
}
```
O defeito era `canPop: false` com um callback que nunca chamava `Navigator.pop()`: interceptar o voltar é aceitável, impedir não é.

<a id="m11-e12"></a>
## M11-E12
| # | Item | `share_plus` | Pacote de duração |
|---|---|---|---|
| 1 | Existe equivalente `flutter.dev`? | Não | Não |
| 2 | Escrevo em menos de 200 linhas? | Não: Intent + `UIActivityViewController` | **Sim — reprova aqui** |
| 3 | Publisher verificado | `fluttercommunity.dev` ✅ | Conta pessoal ❌ |
| 4 | Publicado há menos de 6 meses | ✅ | ❌ |
| 5 | Issue de "não compila" aberta | Não | Sim, meses sem resposta |
| 6 | Plataformas cobertas | Android, iOS, web, desktop ✅ | Dart puro ✅ |
| 7 | Licença permissiva | BSD-3 ✅ | MIT ✅ |
| 8 | Dependências que traz | Poucas e conhecidas ✅ | Puxa `intl` sem necessidade ⚠️ |
| 9 | O `example/` roda | ✅ | Não tem `example/` ❌ |
| 10 | Custo se for abandonado | Alto: código nativo nas duas plataformas | Baixo: 15 linhas |

**Decisão:** adoto `share_plus` e escrevo a formatação de duração como `extension` em `core/`. O item 2 encerra a conversa sozinho — depender de terceiro para 15 linhas de Dart puro é trocar código por risco.

<a id="m11-e13"></a>
## M11-E13
```dart
import 'package:flutter/material.dart';

import 'package:foco_nativo/core/adaptativo/plataforma.dart';

class MateriaCard extends StatelessWidget {
  const MateriaCard({super.key, required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) {
    final IconData icone =
        Plataforma.ehApple(context) ? Icons.chevron_right : Icons.arrow_forward;
    return ListTile(title: Text(nome), trailing: Icon(icone));
  }
}
```
O erro só aparece em execução porque na web o `dart:io` compila contra stubs que lançam quando alguém os chama — o `flutter build` não tem como saber que a linha será executada.

<a id="m11-e14"></a>
## M11-E14
```dart
@override
Widget build(BuildContext context) {
  return CamadasDeVoltar(
    // ORDEM = ordem de fechamento: a mais interna primeiro.
    camadas: <CamadaDeVoltar>[
      CamadaDeVoltar(
        nome: 'folha de opções',
        ativa: () => _folhaAberta,
        fechar: () async {
          setState(() => _folhaAberta = false);
          return true;
        },
      ),
      CamadaDeVoltar(
        nome: 'formulário sujo',
        ativa: () => _temAlteracoes && !_salvando,
        fechar: () async {
          final bool descartar = await confirmarAdaptativo(
            context,
            titulo: 'Descartar alterações?',
            mensagem: 'As alterações desta matéria não foram salvas.',
            rotuloConfirmar: 'Descartar',
            rotuloCancelar: 'Continuar editando',
            destrutivo: true,
          );
          if (descartar && mounted) Navigator.of(context).pop();
          return descartar; // false = "continuar editando": o voltar é cancelado
        },
      ),
    ],
    child: Scaffold(
      appBar: AppBar(title: const Text('Matéria')),
      body: _formulario(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: BotaoAdaptativo(
          rotulo: 'Salvar',
          enfase: EnfaseDoBotao.primaria,
          carregando: _salvando,
          larguraTotal: true,
          aoTocar: _temAlteracoes && !_salvando ? _salvar : null,
        ),
      ),
    ),
  );
}
```
Nenhum caminho usa `dart:io`: `confirmarAdaptativo` e `BotaoAdaptativo` decidem por `Theme.of(context).platform`, e toda camada tem saída — no máximo com uma pergunta no meio.

[Exercícios](../exercicios/11-recursos-nativos.md) · [Módulo](../modulos/11-recursos-nativos/README.md)
