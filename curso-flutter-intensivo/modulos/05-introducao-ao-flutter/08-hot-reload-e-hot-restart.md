# Aula 8 — Hot reload e hot restart

> **Módulo:** 05 - Introdução ao Flutter · **Tempo estimado:** 30 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar **o que** o hot reload troca dentro do app em execução e **o que ele preserva**.
- Diferenciar **hot reload** (`r`), **hot restart** (`R`) e **parar e rodar de novo** — e escolher
  o certo sem tentativa e erro.
- Listar as situações em que o hot reload **não funciona** e o Flutter avisa, e as situações em
  que ele "funciona" mas o resultado **engana**.
- Usar as teclas do terminal (`r`, `R`, `q`, `h`, `p`, `o`) e os atalhos do VS Code.
- Entender por que hot reload **só existe no modo debug** — e ligar isso ao JIT da aula 1.
- Estruturar o código de forma que o hot reload seja **útil de verdade** (estado inicial fora do
  `build`, `initState` enxuto).

## ✅ Pré-requisitos

- [Aula 1 — Como o Flutter funciona](01-como-o-flutter-funciona.md) — **JIT × AOT**. Esta aula é
  a consequência prática daquilo.
- [Aula 6 — Ciclo de vida do State](06-ciclo-de-vida-do-state.md) — `initState` e `dispose`; o
  hot reload **não** chama nenhum dos dois, e é isso que confunde todo mundo.
- O projeto `meu_primeiro_app` rodando com `flutter run -d chrome`.

---

## 📖 Conceito

### O problema que o hot reload resolve

No desenvolvimento mobile tradicional, o ciclo é:

```text
editar código → compilar → instalar no aparelho → abrir o app →
navegar até a tela → reproduzir o estado → ver a mudança
```

Em um app de tamanho médio isso leva de **40 segundos a vários minutos**. E o pior não é o tempo
de compilação: é ter que **chegar de novo até onde você estava**. Se o erro aparece na quinta tela,
depois de preencher um formulário, você refaz tudo a cada tentativa.

O hot reload muda o ciclo para:

```text
editar código → salvar → ver a mudança (menos de 1 segundo, na mesma tela, com o mesmo estado)
```

### Como o hot reload funciona

Lembre da aula 1: no modo **debug**, o Dart roda com **JIT** (*Just-In-Time* — compilação sob
demanda, enquanto o programa executa). A máquina virtual do Dart mantém, na memória, uma tabela de
todas as classes e funções do seu programa.

Quando você aperta `r`:

1. A ferramenta `flutter` compara os arquivos `.dart` com a última versão enviada e monta um
   **pacote só com o que mudou**.
2. Esse pacote é injetado na máquina virtual, que **substitui o código** das funções alteradas.
3. O framework marca toda a árvore como "precisa reconstruir" e chama `build()` de novo, do topo
   até as folhas.
4. A tela é repintada.

O ponto central está no passo 3:

> **O hot reload troca o código e chama `build()` de novo. Ele NÃO recria os objetos de estado.**

Os `State`, as variáveis de instância, os controllers, a pilha de navegação — tudo **continua
exatamente como estava**.

### Hot restart: jogar fora o estado, manter o processo

Quando você aperta `R` (maiúsculo):

1. Todo o código Dart é recarregado do zero.
2. O **estado é destruído**: todos os `State`, todas as variáveis globais, a pilha de navegação.
3. `main()` roda de novo, do começo.
4. O app volta para a primeira tela.

O que o hot restart **não** faz: reiniciar a parte nativa do app. Plugins já inicializados, canais
de plataforma e o processo do sistema operacional continuam de pé. Por isso ele é mais rápido que
parar e rodar de novo — mas também por isso ele **não resolve** problemas que vêm do lado nativo.

### A tabela que responde tudo

| Situação | `r` hot reload | `R` hot restart | Parar e `flutter run` |
|---|:---:|:---:|:---:|
| Mudei o texto de um `Text` | ✅ | ✅ | ✅ |
| Mudei cor, padding, layout dentro de um `build` | ✅ | ✅ | ✅ |
| Adicionei um widget novo na árvore | ✅ | ✅ | ✅ |
| Mudei o corpo de um método já existente | ✅ | ✅ | ✅ |
| Mudei o corpo do `initState` | ❌ *o código muda, mas não roda* | ✅ | ✅ |
| Mudei o **valor inicial** de uma variável de estado | ❌ *mesma armadilha* | ✅ | ✅ |
| Mudei uma variável `static` ou global com valor inicial | ❌ | ✅ | ✅ |
| Mudei o `main()` | ❌ | ✅ | ✅ |
| Troquei `StatelessWidget` por `StatefulWidget` (ou o contrário) | ❌ *o Flutter avisa* | ✅ | ✅ |
| Mudei a hierarquia de herança de uma classe | ❌ *o Flutter avisa* | ✅ | ✅ |
| Adicionei/removi campos de uma classe com `enum` ou `sealed` | ⚠️ às vezes | ✅ | ✅ |
| Editei o `pubspec.yaml` (dependência nova) | ❌ | ❌ | ✅ |
| Adicionei um **asset** novo ao `pubspec.yaml` | ❌ | ❌ | ✅ |
| Instalei um plugin com código nativo | ❌ | ❌ | ✅ |
| Mudei algo em `android/` ou `ios/` (manifest, Gradle, Info.plist) | ❌ | ❌ | ✅ |
| Mudei o ícone ou o nome do app | ❌ | ❌ | ✅ |
| Erro de compilação no arquivo salvo | ❌ *mostra o erro e não aplica* | ❌ | ❌ |

> ⚠️ Repare nas linhas com **"o código muda, mas não roda"**. Elas são a fonte da confusão número 1
> com hot reload — e a seção "Erros comuns" mostra isso acontecendo passo a passo.

### Por que não existe hot reload no modo release

No **release** o Dart é compilado com **AOT** (*Ahead-Of-Time* — tudo virou código de máquina antes
de instalar). Não existe máquina virtual mantendo uma tabela de funções trocáveis: existe um
binário. Trocar uma função ali significaria reescrever o executável em memória — que é exatamente
o que os sistemas operacionais móveis proíbem por segurança.

Essa é a troca consciente do Flutter:

| Modo | Compilação | Hot reload | Velocidade do app | Quando usar |
|---|---|:---:|---|---|
| `debug` | JIT | ✅ | Mais lento, com verificações extras | Desenvolvimento |
| `profile` | AOT | ❌ | Quase igual ao release, com instrumentação | Medir desempenho |
| `release` | AOT | ❌ | Máxima | Publicar |

> 📌 **Nunca julgue o desempenho do seu app no modo debug.** Uma animação que "engasga" no debug
> quase sempre roda lisa no release. O [Módulo 13](../13-desempenho-e-seguranca/README.md) trata
> disso com números.

### As teclas do terminal

Com `flutter run` ativo, o terminal aceita:

| Tecla | O que faz |
|---|---|
| `r` | **Hot reload** |
| `R` | **Hot restart** |
| `q` | Encerra o app e devolve o terminal |
| `h` | Lista todas as teclas disponíveis |
| `p` | Liga/desliga as **linhas guia de layout** (mostra as caixas de cada widget) |
| `o` | Alterna entre `TargetPlatform.android` e `TargetPlatform.iOS` (só muda a aparência) |
| `v` | Abre o **DevTools** no navegador |
| `c` | Limpa a tela do terminal |

> A tecla `p` é subestimada. Quando um layout está estranho e você não sabe por quê, aperte `p`:
> as bordas de cada widget aparecem e o problema costuma ficar óbvio.

### No VS Code

| Ação | Atalho | Observação |
|---|---|---|
| Hot reload | `Ctrl` + `F5`… na verdade: **salvar o arquivo** (`Ctrl` + `S`) | Ativado por padrão |
| Hot restart | `Ctrl` + `Shift` + `F5` | |
| Parar | `Shift` + `F5` | |
| Iniciar com debug | `F5` | |
| Iniciar sem debug | `Ctrl` + `F5` | |

O **hot reload ao salvar** é a configuração `dart.flutterHotReloadOnSave`, que vem como
`"manual"` (recarrega quando você salva com `Ctrl` + `S`). Se quiser desligar, abra as
configurações (`Ctrl` + `,`), procure por `flutterHotReloadOnSave` e escolha `never`.

---

## 💡 Analogia

Pense em um teatro com a peça em cartaz, no meio do segundo ato.

- **Hot reload** é trocar o **texto das falas** e o **figurino** sem baixar a cortina. Os atores
  continuam onde estavam no palco, os objetos de cena continuam nas mesmas mesas, e o público nem
  percebe a troca. O que muda é o que será dito **daqui para frente**.
  → Por isso mesmo: uma fala que já foi dita no primeiro ato **não é dita de novo**. O `initState`
  é uma fala do primeiro ato.

- **Hot restart** é baixar a cortina, mandar todo mundo para a coxia, e recomeçar a peça do
  primeiro ato — **no mesmo teatro**, com a mesma equipe de luz e som já montada.

- **Parar e rodar de novo** é fechar o teatro, desmontar o palco, montar tudo outra vez e reabrir
  as portas. É o único jeito quando você trocou **a estrutura do palco** — ou seja, quando mexeu
  na parte nativa, em `pubspec.yaml` ou em assets.

---

## 🧪 Exemplo mínimo

Este programa foi feito para o hot reload te enganar. Rode e siga o roteiro.

> **Arquivo:** `meu_primeiro_app/lib/main.dart` (temporário)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

void main() => runApp(const AppDemo());

class AppDemo extends StatelessWidget {
  const AppDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ContadorDemo(),
    );
  }
}

class ContadorDemo extends StatefulWidget {
  const ContadorDemo({super.key});

  @override
  State<ContadorDemo> createState() => _ContadorDemoState();
}

class _ContadorDemoState extends State<ContadorDemo> {
  // ⬇️ EXPERIMENTO A: mude este 0 para 100 e aperte `r`.
  int _contador = 0;

  // ⬇️ EXPERIMENTO B: mude este texto e aperte `r`.
  String _titulo = 'Hot reload';

  @override
  void initState() {
    super.initState();
    // ⬇️ EXPERIMENTO C: mude este texto e aperte `r`.
    debugPrint('initState rodou. Texto: começo');
  }

  @override
  Widget build(BuildContext context) {
    // ⬇️ EXPERIMENTO D: mude este texto e aperte `r`.
    const String rotulo = 'Toques:';

    return Scaffold(
      appBar: AppBar(title: Text(_titulo)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(rotulo, style: Theme.of(context).textTheme.titleMedium),
            Text('$_contador', style: Theme.of(context).textTheme.displayLarge),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _contador++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Roteiro — faça na ordem e anote o que acontece:**

1. Rode. Aperte o botão **5 vezes**. O contador mostra `5`.
2. **Experimento D:** troque `'Toques:'` por `'Cliques:'` e aperte `r`.
   → O rótulo muda **e o contador continua em 5**. Esse é o hot reload funcionando.
3. **Experimento B:** troque `_titulo = 'Hot reload'` por `'Hot reload testado'` e aperte `r`.
   → 🤔 O título **não muda**. O valor inicial do campo só é atribuído quando o `State` é
   **criado** — e ele não foi recriado.
4. **Experimento A:** troque `int _contador = 0;` por `int _contador = 100;` e aperte `r`.
   → O contador continua em 5. Mesmo motivo.
5. **Experimento C:** mude o texto do `debugPrint` no `initState` e aperte `r`.
   → Nada é impresso. O `initState` já rodou; ele não roda de novo.
6. Agora aperte **`R`** (hot restart).
   → O contador volta para **100**, o título vira **"Hot reload testado"** e o `debugPrint` novo
   aparece no console. Tudo o que estava "preso" foi aplicado de uma vez.

Esse roteiro de 2 minutos ensina mais sobre hot reload do que qualquer explicação. **Faça.**

---

## 📱 Aplicando no Flutter

Agora, no `meu_primeiro_app`, um exercício de leitura do próprio hot reload. Você vai instrumentar
os widgets para **ver** o que acontece a cada `r` e a cada `R`.

A ideia: imprimir no console em quatro momentos — `initState`, `build`, `dispose` e a criação do
objeto de estado — e observar quais linhas aparecem em cada tecla.

---

## 💻 Código completo

> **Arquivo:** `meu_primeiro_app/lib/widgets/sonda_ciclo.dart` (novo — ferramenta de estudo)
> **Como executar:** `flutter run -d chrome`

```dart
import 'package:flutter/material.dart';

/// Widget-sonda: existe apenas para mostrar, no console, o que o hot reload
/// e o hot restart fazem com o ciclo de vida.
///
/// Envolva qualquer parte da sua tela com ele e observe o terminal.
class SondaCiclo extends StatefulWidget {
  const SondaCiclo({
    super.key,
    required this.nome,
    required this.child,
  });

  /// Aparece no começo de cada linha do log, para você saber quem falou.
  final String nome;

  final Widget child;

  @override
  State<SondaCiclo> createState() => _SondaCicloState();
}

class _SondaCicloState extends State<SondaCiclo> {
  /// Contador de builds. Como é um campo de instância, ele SOBREVIVE ao hot
  /// reload e é ZERADO pelo hot restart. É exatamente esse o experimento.
  int _builds = 0;

  /// Marca o instante em que este State foi criado. Se o horário não mudar
  /// depois de um `r`, é porque o State é o mesmo de antes.
  final DateTime _nascimento = DateTime.now();

  @override
  void initState() {
    super.initState();
    // ⬇️ Mude este texto e aperte `r`: nada acontece.
    //    Aperte `R`: o texto novo aparece.
    debugPrint('[${widget.nome}] initState — estado criado às '
        '${_formatar(_nascimento)}');
  }

  @override
  void dispose() {
    debugPrint('[${widget.nome}] dispose — estado destruído');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _builds++;
    debugPrint('[${widget.nome}] build #$_builds '
        '(State nasceu às ${_formatar(_nascimento)})');

    return Stack(
      children: <Widget>[
        widget.child,
        // Etiqueta no canto, para ver o número sem sair do app.
        Positioned(
          right: 0,
          top: 0,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.black54,
              child: Text(
                '${widget.nome} · build $_builds',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatar(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')}';
}
```

Agora use a sonda na `HomeTela`. Envolva a `BarraResumo` e o `CronometroSessao`:

> **Arquivo:** `meu_primeiro_app/lib/telas/home_tela.dart` (só os dois trechos abaixo mudam)

```dart
import 'package:meu_primeiro_app/widgets/sonda_ciclo.dart';

// … dentro do ListView do body:

SondaCiclo(
  nome: 'resumo',
  child: BarraResumo(
    sessoesConcluidas: _sessoesConcluidas,
    minutosTotais: _minutosTotais,
  ),
),
const SizedBox(height: 16),

// … e mais abaixo:

SondaCiclo(
  nome: 'cronometro',
  child: CronometroSessao(
    duracaoMinutos: _duracaoMinutos,
    onConcluir: _aoConcluirSessao,
  ),
),
```

**O experimento, passo a passo:**

```powershell
flutter run -d chrome
```

1. Assim que abrir, o console mostra:

```text
[resumo] initState — estado criado às 14:02:11
[resumo] build #1 (State nasceu às 14:02:11)
[cronometro] initState — estado criado às 14:02:11
[cronometro] build #1 (State nasceu às 14:02:11)
```

2. Aperte `r` (hot reload). O console mostra:

```text
[resumo] build #2 (State nasceu às 14:02:11)
[cronometro] build #2 (State nasceu às 14:02:11)
```

→ **Nenhum `initState`. Nenhum `dispose`. O horário de nascimento é o mesmo.** O `State` sobreviveu.

3. Aperte `R` (hot restart). O console mostra:

```text
[resumo] initState — estado criado às 14:03:40
[resumo] build #1 (State nasceu às 14:03:40)
[cronometro] initState — estado criado às 14:03:40
[cronometro] build #1 (State nasceu às 14:03:40)
```

→ `initState` de novo, contador de builds zerado, horário novo. **Estado destruído e recriado.**

Repare que o `dispose` **não aparece** no hot restart: a máquina virtual descarta o estado sem
avisar os `State`. Essa é mais uma razão para nunca depender do `dispose` para gravar dados
importantes — assunto do [Módulo 11](../11-recursos-nativos/06-ciclo-de-vida-do-app.md).

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `int _builds = 0;` | Campo de instância do `State`. **Sobrevive** ao hot reload; **zera** no hot restart. É o medidor do experimento. |
| `final DateTime _nascimento = DateTime.now();` | Inicializador de campo — roda **uma vez**, quando o `State` é construído. Se o horário não mudar, o `State` é o mesmo. |
| `debugPrint` em vez de `print` | `debugPrint` limita a velocidade da saída para o Android não descartar linhas, e é removido automaticamente em release. **Use sempre ele.** |
| `Stack` + `Positioned` + `IgnorePointer` | A etiqueta flutua sobre o filho sem roubar os toques dele. Sem o `IgnorePointer`, a etiqueta bloquearia cliques naquele canto. |
| `widget.nome` dentro do `State` | O `State` acessa os parâmetros do widget pela propriedade `widget`. Relembrado da [aula 5](05-statefulwidget-e-setstate.md). |
| `_formatar` com `padLeft(2, '0')` | Deixa `14:2:5` virar `14:02:05`. Detalhe pequeno que faz o log ficar legível. |
| `SondaCiclo` como wrapper com `child` | Padrão de composição: um widget que **envolve** outro sem saber o que ele é. O mesmo padrão de `Padding`, `Center` e `Expanded`. |

---

## 🤖🍎 Android × iOS

| Aspecto | 🤖 Android | 🍎 iOS |
|---|---|---|
| Hot reload | ✅ Funciona igual | ✅ Funciona igual |
| Hot restart | ✅ Funciona igual | ✅ Funciona igual |
| Mudou `AndroidManifest.xml` / `Info.plist` | Precisa parar e rodar | Precisa parar e rodar |
| Plugin novo com código nativo | Precisa parar e rodar (`gradle` recompila) | Precisa parar e rodar (`pod install` roda de novo) |
| Tempo do "parar e rodar de novo" | 30 s a 2 min (Gradle) | 40 s a 3 min (Xcode + CocoaPods) |
| Hot reload com o app em segundo plano | Funciona; a tela atualiza quando você volta | Pode falhar — o iOS suspende o processo mais agressivamente |

> 📌 No iOS físico, se o app ficar minutos em segundo plano, o sistema pode **matar o processo** e
> a conexão do `flutter run` cai (`Lost connection to device`). Não é bug: é o iOS gerenciando
> memória. Rode de novo.

---

## ⚠️ Erros comuns

### 1. "Mudei o código e nada aconteceu" — o caso do valor inicial

```dart
class _MeuState extends State<Meu> {
  int _valor = 0;   // troquei para 42, apertei `r`, continua 0 😤
```

**Por quê:** esse `= 0` é um **inicializador de campo**. Ele só roda quando o objeto `State` é
construído. O hot reload não constrói `State` nenhum.

**Correção:** aperte `R` (hot restart). E guarde a regra:

> Mudou **valor inicial**, `initState`, `main()` ou variável global? → `R`.
> Mudou o que está **dentro de um `build`** ou de um método já existente? → `r`.

### 2. "Mudei o `initState` e o app não mudou"

Mesmo motivo do anterior. O `initState` do widget que já está na tela **já rodou**. O hot reload
substitui o código do método, mas não o chama de novo.

> Exceção útil: se você navegar para outra tela e voltar, um `State` **novo** é criado — e aí sim
> o `initState` novo roda. Esse é um truque legítimo para testar mudanças no `initState` sem
> perder o estado do resto do app.

### 3. `Hot reload was rejected` — mudanças estruturais

```text
Reloading... (completed in 512ms)
Hot reload was rejected:
Class 'CartaoMateria' has changed its superclass.
```

**Causas típicas:**

- Trocou `StatelessWidget` por `StatefulWidget` (ou o contrário).
- Mudou de qual classe a sua classe estende.
- Adicionou ou removeu um `mixin`.
- Mudou a assinatura genérica de uma classe (`class Caixa<T>` → `class Caixa<T, U>`).

**Correção:** `R`. Não há alternativa — e o Flutter já te disse isso na mensagem.

### 4. Mexeu no `pubspec.yaml` e ficou apertando `r`

```yaml
dependencies:
  http: ^1.2.0   # acabei de adicionar
```

Nem `r` nem `R` resolvem. Dependência nova precisa ser **baixada e ligada ao projeto**:

```powershell
flutter pub get
```

e depois **parar e rodar de novo**. A mesma coisa vale para **assets**:

```yaml
flutter:
  assets:
    - assets/imagens/logo.png   # novo
```

Assets entram no **bundle** do app, que é montado na compilação. Nenhum hot reload monta bundle.

> ⚠️ Pegadinha: **editar o conteúdo** de um asset que já está declarado geralmente funciona com
> `R`. **Declarar um asset novo** nunca funciona sem parar e rodar. O
> [Módulo 06, aula 8](../06-widgets-e-layouts/08-imagens-e-assets.md) trata dos assets a fundo.

### 5. O hot reload "funcionou", mas a tela ficou num estado impossível

Este é o caso mais traiçoeiro. Exemplo: você tem uma lista com 3 itens na tela e edita o código
para que a lista **comece** com 5 itens. O hot reload aplica o novo `build`, mas a lista continua
com os 3 itens antigos — e agora o seu código e o que você vê **não combinam**.

Você começa a depurar um bug que não existe.

> **Regra prática:** sempre que o comportamento não fizer sentido, aperte `R` **antes** de começar
> a investigar. Cinco segundos de hot restart economizam meia hora de caça a fantasmas.

### 6. Erro de compilação durante o hot reload

```text
lib/telas/home_tela.dart:42:7: Error: Expected ';' after this.
```

O hot reload **não aplica nada** — o app continua rodando a versão anterior, que funciona. Isso é
bom: você não perde o estado por causa de um ponto e vírgula. Corrija o erro e salve de novo.

### 7. Achar que o app está lento porque o hot reload está lento

O primeiro hot reload depois de `flutter run` costuma demorar mais (2 a 4 segundos): a ferramenta
ainda está montando o índice dos arquivos. Os seguintes ficam abaixo de 1 segundo. Isso **não diz
nada** sobre a velocidade do app — e o app em debug também não diz. Meça no release.

---

## 🛠️ Exercício guiado

**Passo 1.** Com o `meu_primeiro_app` rodando, aperte o botão do cronômetro e deixe-o contando.
Conclua **duas** sessões, para o contador da `AppBar` mostrar `2`.

**Passo 2.** Mude a cor do `Card` da `BarraResumo` de `surfaceContainerHighest` para
`primaryContainer` e salve (`Ctrl` + `S`). Anote: a cor mudou? O contador continuou em 2? O
cronômetro parou?

**Passo 3.** Mude o valor inicial de `_duracaoMinutos` de `25` para `50` e salve. Anote: o
`SegmentedButton` mudou de seleção?

**Passo 4.** Aperte `R`. Anote o que aconteceu com: a cor, o contador de sessões, o cronômetro e a
seleção de duração.

**Passo 5.** Transforme a `BarraResumo` de `StatelessWidget` em `StatefulWidget` (só a estrutura;
o `build` vai para a classe de estado). Salve. Leia a mensagem que aparece no terminal e
**copie-a** para o seu caderno.

**Passo 6.** Aperte `R` e confirme que o app volta a funcionar. Depois desfaça a mudança do
passo 5.

**Passo 7.** Abra o `pubspec.yaml`, adicione uma linha em branco qualquer e salve. Aperte `r` e
depois `R`. Anote: alguma coisa indica que o `pubspec` foi lido? Por que não?

**Passo 8.** Responda por escrito, em três frases: quando você usa `r`, quando usa `R` e quando
precisa parar e rodar de novo.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/05-introducao-ao-flutter.md](../../exercicios/05-introducao-ao-flutter.md)

Faça os exercícios de **Compreensão** sobre o que cada tecla preserva e o de **Correção de bugs**
com o valor inicial que "não muda".

---

## 🏆 Desafio opcional

Escreva o arquivo `docs/hot-reload.md` dentro do seu `meu_primeiro_app` com uma **tabela de
decisão pessoal**: uma coluna com "o que eu mudei" e outra com "o que eu aperto". Preencha com
**pelo menos 12 linhas**, todas tiradas de mudanças que você fez de verdade neste módulo.

Depois, teste cada linha da sua tabela. Se alguma estiver errada, corrija — e anote por que você
tinha errado. Essa tabela vale mais que qualquer resumo pronto, porque é feita das suas próprias
dúvidas.

---

## 📌 Resumo

- **Hot reload (`r`)** injeta o código novo, chama `build()` de novo e **preserva todo o estado**:
  variáveis de instância, controllers, pilha de navegação.
- **Hot reload não chama `initState`, não chama `dispose` e não reexecuta inicializadores de
  campo.** Essa é a origem de quase toda confusão.
- **Hot restart (`R`)** recarrega tudo, **destrói o estado**, roda `main()` de novo e volta à
  primeira tela — mas mantém o processo nativo de pé.
- **Parar e rodar de novo** é obrigatório para: `pubspec.yaml`, assets novos, plugins nativos,
  `AndroidManifest.xml`, `Info.plist`, ícone, nome do app.
- Mudanças **estruturais** (trocar `Stateless`↔`Stateful`, mudar superclasse, mexer em `mixin`)
  fazem o Flutter **rejeitar** o hot reload com uma mensagem clara. Aperte `R`.
- Hot reload **só existe no modo debug**, porque só o debug usa **JIT**. Release e profile usam
  **AOT**.
- Nunca avalie desempenho no modo debug.
- Quando o comportamento não fizer sentido, **aperte `R` antes de investigar**.
- Teclas úteis do terminal: `r`, `R`, `q`, `h`, `p` (linhas guia de layout), `v` (DevTools).

---

## ☑️ Checklist de domínio

- [ ] Explico, sem olhar, o que o hot reload preserva e o que ele troca.
- [ ] Digo por que uma mudança no `initState` não aparece com `r`.
- [ ] Digo por que mudar `int _x = 0;` para `int _x = 42;` não aparece com `r`.
- [ ] Sei três situações em que nem `r` nem `R` resolvem.
- [ ] Reconheço a mensagem `Hot reload was rejected` e sei o que fazer.
- [ ] Ligo a existência do hot reload ao JIT, e a ausência dele no release ao AOT.
- [ ] Uso `p` no terminal para diagnosticar um layout estranho.
- [ ] Tenho o hábito de apertar `R` antes de investigar comportamento sem sentido.
- [ ] Sei que não se mede desempenho no modo debug.
- [ ] Rodei o roteiro de 6 passos do "Exemplo mínimo" e vi cada comportamento com meus olhos.

---

## 📚 Referências oficiais

- [Hot reload — docs.flutter.dev](https://docs.flutter.dev/tools/hot-reload)
- [Flutter's build modes — docs.flutter.dev](https://docs.flutter.dev/testing/build-modes)
- [Using the Flutter extension for VS Code — docs.flutter.dev](https://docs.flutter.dev/tools/vs-code)
- [Flutter architectural overview — docs.flutter.dev](https://docs.flutter.dev/resources/architectural-overview)
- [debugPrint — api.flutter.dev](https://api.flutter.dev/flutter/foundation/debugPrint.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — BuildContext](07-buildcontext.md) | [README](README.md) | [Aula 9 — Material e Cupertino](09-material-e-cupertino.md) |
