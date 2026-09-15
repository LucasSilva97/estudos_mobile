# Exercícios — Módulo 05: Introdução ao Flutter

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Rode `flutter analyze` (esperando `No issues found!`) e teste com `flutter run -d chrome` antes de abrir o gabarito.

<a id="m05-e01"></a>
## M05-E01 — Vocabulário do motor · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Nomear as peças do Flutter | Fácil | 15 min | Sim |
Escreva, com suas palavras e em no máximo duas linhas cada, o que são: *engine*, *embedder*, Impeller, Skia, JIT, AOT e widget. **Esperado:** suas frases de JIT e AOT explicam sozinhas por que o hot reload só existe no modo debug. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e01)

<a id="m05-e02"></a>
## M05-E02 — O que entra no Git · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Ler a árvore do projeto | Fácil | 20 min | Sim |
Rode `flutter create -e --platforms=android,ios,web --org br.com.estudos foco` e classifique em "versionar" ou "nunca versionar", com um motivo cada: `lib/`, `build/`, `.dart_tool/`, `pubspec.lock`, `.metadata`, `android/local.properties` e `android/key.properties`. **Teste:** `git status` no projeto recém-criado não lista nenhum item da sua coluna "nunca versionar". [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e02)

<a id="m05-e03"></a>
## M05-E03 — Auditoria do pubspec · Leitura de código
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Interpretar dependências e lints | Fácil | 20 min | Sim |
No `pubspec.yaml` do `foco`, explique o papel de `version: 1.0.0+1`, `environment: sdk: ^3.13.0`, `cupertino_icons`, `flutter_lints: ^6.0.0` e `uses-material-design: true`. Depois diga qual dessas alterações o hot reload **não** consegue aplicar. **Esperado:** você conclui que qualquer edição no `pubspec.yaml` exige parar o app e rodar `flutter run` de novo. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e03)

<a id="m05-e04"></a>
## M05-E04 — Tela de metas da semana · Aplicação
Crie `lib/telas/metas_tela.dart` com `MetasTela` (`StatelessWidget` const): `Scaffold` com `AppBar` de título `Metas da semana`, `Column` com três `Text` de matéria (Dart, Flutter, Git e terminal) e um `FilledButton` "Registrar sessão". **Esperado:** `main()` continua com `runApp(const MeuPrimeiroApp())` e você desenha, em texto, a árvore completa de `MaterialApp` até o `Text` de dentro do botão. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e04)

<a id="m05-e05"></a>
## M05-E05 — Etiqueta de nível · Implementação
Crie `lib/widgets/etiqueta_nivel.dart` com `EtiquetaNivel`: construtor `const`, `{super.key}`, `required this.minutos` e `this.compacta = false`. Ela calcula o nível sozinha (até 60 min "Iniciante", até 180 "Praticando", até 600 "Consistente", acima "Veterano"), tira a cor do `ColorScheme` do tema e, com `compacta: true`, mostra só a primeira letra. **Teste:** use a etiqueta dentro do `CartaoMateria`, ao lado do nome, e `flutter analyze` termina com `No issues found!`. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e05)

<a id="m05-e06"></a>
## M05-E06 — Cartão que se reescreve · Correção de bugs
Um `CartaoMeta extends StatelessWidget` declara `int minutos;` sem `final` e tem um método `registrar()` que faz `minutos += 25;`. O analisador acusa `must_be_immutable` e, mesmo ignorando o aviso, o número na tela nunca muda. Corrija os dois problemas: os campos do widget voltam a ser `final` e o total passa a viver no `State`, dentro de `setState`. **Teste:** tocar em "Registrar" soma 25 minutos na tela e o `flutter analyze` fica limpo. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e06)

<a id="m05-e07"></a>
## M05-E07 — Contador com limite diário · Implementação
Faça `ContadorSessoes` aceitar `this.sessoesIniciais = 0` e `this.limiteDiario = 12`. Inicialize `_sessoes` a partir de `widget.sessoesIniciais` no lugar certo — **não** como inicializador de campo, porque `widget` ainda não existe lá —, desabilite "Concluir sessão" ao atingir o limite e mostre uma `SnackBar` explicando. **Teste:** com `sessoesIniciais: 11`, um toque chega ao limite, o botão fica desabilitado e a mensagem aparece. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e07)

<a id="m05-e08"></a>
## M05-E08 — Cronômetro que vaza · Correção de bugs
Nesta versão do `CronometroSessao` há três defeitos: o `TextEditingController` é criado dentro do `build`, o `Timer.periodic` nunca é cancelado no `dispose` e o `didUpdateWidget` reinicia a contagem sem comparar `widget.duracaoMinutos` com `widgetAntigo.duracaoMinutos`. Corrija os três. **Teste:** inicie o cronômetro, saia da tela e confira o console — nenhum `setState() called after dispose()`; a anotação digitada sobrevive a um rebuild do pai. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e08)

<a id="m05-e09"></a>
## M05-E09 — Ordem do ciclo de vida · Leitura de código
Coloque um `debugPrint` nos sete métodos de `_CronometroSessaoState` e anote a ordem real em três momentos: primeira montagem, redimensionamento da janela do Chrome e saída da tela. **Esperado:** você explica por que `didChangeDependencies` roda depois do `initState` e por que `Theme.of(context)` dentro do `initState` estoura. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e09)

<a id="m05-e10"></a>
## M05-E10 — A busca para cima · Compreensão
Responda por escrito, em até 10 linhas: o que `Theme.of(context)` faz a partir do `context` recebido, por que dois widgets declarados no mesmo arquivo têm `context` diferentes, e o que muda quando você envolve um trecho em `Builder`. **Esperado:** a palavra "ancestral" aparece na sua resposta e você cita `No MediaQuery ancestor could be found` como prova. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e10)

<a id="m05-e11"></a>
## M05-E11 — Três bugs na HomeTela · Correção de bugs
Corrija: (1) `Scaffold.of(context).openDrawer()` chamado no mesmo `build` que cria o `Scaffold`, produzindo `Scaffold.of() called with a context that does not contain a Scaffold`; (2) `ScaffoldMessenger.of(context).showSnackBar(...)` usado depois de um `await` sem checar `mounted`; (3) `Container(color: Colors.white)` que vira um retângulo branco gritante no modo escuro. **Esperado:** `Builder` (ou widget extraído), mensageiro capturado antes do `await` mais `if (!mounted) return;`, e `cores.surfaceContainerHighest` no lugar da cor fixa. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e11)

<a id="m05-e12"></a>
## M05-E12 — Painel da semana adaptável · Aplicação
Crie `lib/tema/tema_app.dart` com `abstract final class TemaApp` expondo `claro` e `escuro` a partir de uma única semente em `ColorScheme.fromSeed`, ligue `theme`, `darkTheme` e `themeMode` no `MaterialApp` e escreva `PainelSemana`, que usa `MediaQuery.sizeOf(context).width` para empilhar as métricas abaixo de 600 px e mostrá-las lado a lado acima disso. **Teste:** alterne claro e escuro, estreite a janela do Chrome e confirme que nenhum `Colors.` fixo sobrou nos dois arquivos. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e12)

<a id="m05-e13"></a>
## M05-E13 — `r`, `R` ou parar? · Compreensão
Para cada mudança — texto de um `Text`, corpo do `initState`, valor inicial de `int _sessoes = 0`, troca de `StatelessWidget` por `StatefulWidget`, dependência nova no `pubspec.yaml` — diga qual tecla resolve e por quê. Depois reproduza o caso do valor inicial: troque `0` por `5`, aperte `r` e explique por que a tela ignora a mudança. **Esperado:** você separa o que o `r` preserva (o estado já criado) do que só o `R` recria, e aponta o `pubspec.yaml` como o único caso de parar e rodar `flutter run` de novo. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e13)

<a id="m05-e14"></a>
## M05-E14 — Material ou Cupertino no Foco · Decisão
Escreva de 10 a 15 linhas decidindo a linguagem de design do app **Foco** (`br.com.estudos.foco`), que roda em Android e iOS e é mantido por uma pessoa só. Cite um elemento que você **não** vai adaptar por plataforma e um widget `.adaptive` que vale o esforço. **Esperado:** a justificativa fala em custo de manutenção e explica por que `Platform.isIOS` não serve (quebra no Flutter Web), preferindo `Theme.of(context).platform`. [🔑 Gabarito](../gabaritos/05-introducao-ao-flutter.md#m05-e14)

[Módulo](../modulos/05-introducao-ao-flutter/README.md)
