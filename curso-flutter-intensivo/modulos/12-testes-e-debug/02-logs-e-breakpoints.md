# Aula 2 — Logs e breakpoints

> **Módulo:** 12 - Testes e Depuração · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar por que `debugPrint()` substitui `print()` em código Flutter e o que o lint
  `avoid_print` está protegendo.
- Usar `log()` de `dart:developer` com `name`, `level`, `error` e `stackTrace`.
- Colocar, remover e **condicionar** breakpoints no VS Code.
- Andar pelo código com *step over*, *step into* e *step out*, lendo o painel de variáveis e a
  pilha de chamadas.
- Criar expressões de **watch** para acompanhar um valor enquanto o programa anda.
- Parar o programa por código com `debugger()` de `dart:developer`.
- Decidir, em cada situação, se o caminho mais rápido é **log** ou **breakpoint**.

## ✅ Pré-requisitos

- [Aula 1 — Lendo stack traces](01-lendo-stack-traces.md).
- [Módulo 05 — Hot reload e hot restart](../05-introducao-ao-flutter/08-hot-reload-e-hot-restart.md).
- [Módulo 04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) — vamos
  depurar código assíncrono.
- O projeto `foco_lab` e o VS Code com as extensões Flutter e Dart instaladas
  ([02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md)).

---

## 📖 Conceito

### Duas ferramentas, dois momentos

| | **Log** | **Breakpoint** |
|---|---|---|
| O que faz | Escreve uma linha no terminal enquanto o programa corre | **Congela** o programa numa linha e deixa você olhar tudo |
| Custo | Precisa recompilar/recarregar para mudar a mensagem | Muda na hora, sem recarregar |
| Interfere no tempo | Quase nada | Muito: o app fica parado, timers e animações se atrasam |
| Melhor para | Ver **uma sequência** de eventos ao longo do tempo | Ver **todo o estado** num instante |

Você vai usar as duas. A escolha não é ideológica: é sobre **o que você precisa enxergar**.

### `print()` × `debugPrint()` e o lint `avoid_print`

O `print()` do Dart escreve no *stdout* (*standard output* — a saída padrão do processo).
Funciona, e nos módulos 01 a 04, com Dart de terminal, foi o que você usou.

Em Flutter, `print()` tem **três problemas concretos**:

1. **🤖 O Android descarta linhas.** O sistema de log do Android (*logcat*) tem um limite de
   vazão. Se o seu app despeja muitas linhas de uma vez, o Android simplesmente **joga fora** um
   pedaço — e você fica olhando um log com buracos, achando que o código não passou por ali.
2. **Vai para o app publicado.** Um `print()` esquecido continua rodando em release, gastando
   processamento e, pior, podendo **vazar dados** (o corpo de uma resposta, um identificador de
   usuário) para qualquer pessoa que ligue o aparelho no computador e leia o log.
3. **Não tem como filtrar.** Todos os `print()` viram um borrão único no terminal.

Por isso o pacote `flutter_lints ^6.0.0`, que o curso usa, liga a regra **`avoid_print`**. Um
`print()` em código Flutter vira um aviso do analisador:

```text
info • Don't invoke 'print' in production code • lib/main.dart:12:5 • avoid_print
```

A troca direta é **`debugPrint()`**, de `package:flutter/foundation.dart` (já vem junto com
`package:flutter/material.dart`):

```dart
debugPrint('Sessão iniciada para a matéria ${materia.nome}');
```

### Por que `debugPrint` não é truncado

`debugPrint` não imprime tudo de uma vez: ele **enfileira e libera aos poucos**, respeitando um
limite de caracteres por intervalo de tempo. O nome interno dessa implementação padrão é
*throttled* (*estrangulado*, no sentido de vazão controlada).

Na prática: quando você imprime um JSON de 8 000 caracteres, o `print()` entrega tudo de uma vez
ao logcat e o Android corta o excesso. O `debugPrint()` entrega em pedaços, e **você lê a linha
inteira**. É a diferença entre depurar um JSON completo e depurar meio JSON.

Além disso, `debugPrint` é uma **variável de função**: você pode substituí-la no início do app
para mandar as mensagens a outro destino, ou anulá-la em release:

```dart
import 'package:flutter/foundation.dart';

void main() {
  if (kReleaseMode) {
    debugPrint = (String? mensagem, {int? wrapWidth}) {}; // silencia em release
  }
  runApp(const ProviderScope(child: AppFoco()));
}
```

> `kReleaseMode`, `kDebugMode` e `kProfileMode` são constantes de
> `package:flutter/foundation.dart`. Como são `const`, o compilador **remove** o código morto
> dentro de um `if (kDebugMode) { ... }` no build de release.

### `log()` de `dart:developer` — o log com nome e nível

`debugPrint` é texto solto. Quando o app cresce, você quer **etiquetar** e **classificar** as
mensagens. É o papel de `log()`:

```dart
import 'dart:developer' as developer;

developer.log(
  'Resposta recebida com 100 trilhas',
  name: 'foco.trilhas',   // etiqueta: permite filtrar no DevTools
  level: 800,             // 800 = INFO
);

developer.log(
  'Falha ao carregar trilhas',
  name: 'foco.trilhas',
  level: 1000,            // 1000 = SEVERE
  error: erro,            // o objeto da exceção
  stackTrace: pilha,      // o StackTrace capturado no catch
);
```

Os níveis seguem a convenção do pacote `logging`, que o Dart adotou:

| Nível | Número | Use quando |
|---|---|---|
| `FINE` | 500 | Detalhe de implementação, útil só para você |
| `CONFIG` | 700 | Configuração aplicada na inicialização |
| `INFO` | 800 | Evento normal e esperado ("sessão salva") |
| `WARNING` | 900 | Algo estranho, mas o app seguiu ("cache vazio, buscando da rede") |
| `SEVERE` | 1000 | Falha real que o usuário percebeu |

Três vantagens sobre `debugPrint`:

1. O **DevTools** mostra essas mensagens na aba **Logging**, com o `name` numa coluna própria —
   dá para filtrar por `foco.trilhas` e ignorar o resto ([aula 3](03-devtools.md)).
2. Os campos `error` e `stackTrace` são exibidos formatados, não como texto grudado.
3. Em 🤖 Android, `log()` vai para o log do sistema com a etiqueta certa; você acha com
   `adb logcat` filtrando ([aula 9](09-depurando-android-e-ios.md)).

> Não confunda `dart:developer` com o pacote `logging` do pub.dev. `dart:developer` já vem no
> SDK e é suficiente para este curso.

### Breakpoint: congelar o programa

Um **breakpoint** (*ponto de parada*) é uma marca numa linha de código. Quando a execução chega
ali, o programa **para** e o VS Code te entrega o estado completo: valor de cada variável,
pilha de chamadas, e a possibilidade de avaliar expressões.

No VS Code:

| Ação | Como fazer |
|---|---|
| Iniciar em modo de depuração | `F5`, ou menu **Run → Start Debugging** |
| Colocar/remover breakpoint | Clique na margem esquerda, à esquerda do número da linha (surge um círculo vermelho) |
| **Breakpoint condicional** | Clique com o **botão direito** na margem → **Add Conditional Breakpoint** |
| Continuar | `F5` |
| **Step over** (passar por cima) | `F10` — executa a linha inteira, sem entrar nas funções |
| **Step into** (entrar) | `F11` — entra na função chamada naquela linha |
| **Step out** (sair) | `Shift + F11` — roda até o fim da função atual e volta a quem chamou |
| Parar a depuração | `Shift + F5` |

> ⚠️ **Breakpoints só funcionam em modo debug.** Em `--profile` ou `--release` o código é
> compilado antecipadamente (AOT) e não existe essa parada. Se os seus breakpoints "não pegam",
> a primeira pergunta é: em que modo o app está rodando?

**Breakpoint condicional** é o recurso que mais economiza tempo. Você tem 200 matérias na lista e
só a de índice 137 está errada. Em vez de apertar `F5` 137 vezes, coloque a condição:

```text
materia.nome == 'Álgebra Linear'
```

O VS Code oferece três tipos de condição:

- **Expression** — para quando a expressão Dart for verdadeira.
- **Hit count** — para só na *N*-ésima vez que a linha for executada (`> 50`, `= 3`).
- **Log message** (*logpoint*) — **não para**: escreve uma mensagem no console. É um
  `debugPrint` que você liga e desliga sem recompilar. Use chaves para interpolar:
  `minutos = {sessao.minutos}`.

### Os três painéis que você precisa saber ler

Quando o programa para, a barra lateral de depuração mostra:

1. **Variables** (*variáveis*) — tudo que existe no escopo atual, dividido em `Locals`
   (variáveis locais) e, dentro do `this`, os campos do objeto. Clique nas setinhas para abrir
   objetos aninhados. Você pode **editar** um valor ali e continuar a execução com o valor novo.
2. **Watch** (*observação*) — expressões que você escreve e o VS Code reavalia a cada parada.
   Exemplo: `sessao.minutos * 60`, ou `materias.where((m) => m.minutos > 0).length`.
   Serve para perguntas que os valores crus não respondem.
3. **Call Stack** (*pilha de chamadas*) — o mesmo conceito do stack trace da
   [aula 1](01-lendo-stack-traces.md), mas **vivo**: clique em qualquer quadro e o painel de
   variáveis passa a mostrar o escopo **daquele** quadro. É assim que você descobre quem passou
   o argumento errado.

### `debugger()` — o breakpoint escrito no código

Às vezes a condição é complicada demais para a caixinha do VS Code, ou você quer que a parada
viaje junto com o código para outra máquina. Use `debugger()` de `dart:developer`:

```dart
import 'dart:developer';

void registrarMinutos(int minutos) {
  debugger(when: minutos < 0, message: 'Minutos negativos: $minutos');
  _total += minutos;
}
```

- `when:` — só para quando for `true`. Sem isso, para sempre.
- `message:` — aparece no console de depuração ao parar.
- **Sem um depurador conectado, `debugger()` não faz nada.** Não trava o app do usuário. Ainda
  assim, remova antes de publicar: é código de diagnóstico, não de produto.

### Quando log é melhor que breakpoint

| Situação | Escolha | Por quê |
|---|---|---|
| Erro que só acontece 1 vez em 50 | **Log** | Você não fica com o dedo no `F5` esperando |
| Código com `Timer`, animação ou gesto | **Log** | Parar o programa distorce o tempo e o gesto se perde |
| Bug que só aparece no aparelho do colega | **Log** | Ele te manda o texto; breakpoint exigiria o VS Code dele |
| "Não sei nem por onde a execução passa" | **Log** | Espalhe `log()` com `name` e veja a sequência |
| Bug em produção, com `flutter logs` | **Log** | É a única opção: release não tem breakpoint |
| "Chegou aqui com o valor errado, quero ver tudo" | **Breakpoint** | Um clique mostra 30 variáveis; 30 logs seriam 30 linhas |
| Achar **quem** chamou a função | **Breakpoint** | O painel Call Stack responde na hora |
| Testar uma hipótese mudando um valor | **Breakpoint** | Dá para editar a variável e continuar |

Regra de bolso: **log para descobrir _onde_; breakpoint para descobrir _por quê_.**

---

## 💡 Analogia

Log é uma **câmera de segurança**: grava tudo, você assiste depois, não atrapalha o movimento da
loja — mas só mostra o que estava no enquadramento que você escolheu antes.

Breakpoint é **apertar o botão de pausa e entrar na cena**: você vê o que quiser, de qualquer
ângulo, abre gavetas, conta o dinheiro do caixa — mas o tempo parou, e quem estava andando parou
junto. Se o que você investiga **depende do tempo** (um cronômetro, uma animação), pausar destrói
a prova.

---

## 🧪 Exemplo mínimo

```dart
// foco_lab/lib/laboratorio/log_minimo.dart
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

void main() {
  const int minutos = 25;

  print('isto dispara o lint avoid_print');          // ❌ evite em Flutter
  debugPrint('Sessão de $minutos minutos concluída'); // ✅ preferido
  developer.log(
    'Sessão de $minutos minutos concluída',
    name: 'foco.sessoes',
    level: 800,
  );

  if (kDebugMode) {
    debugPrint('Só aparece em debug; some do build de release');
  }
}
```

```powershell
dart run lib/laboratorio/log_minimo.dart
flutter analyze
```

O `flutter analyze` aponta exatamente uma linha:

```text
info • Don't invoke 'print' in production code • lib/laboratorio/log_minimo.dart:9:3 • avoid_print
```

---

## 📱 Aplicando no Flutter

O caso real: o cronômetro da sessão de estudo do Foco grava **menos minutos** do que deveria.
Vamos instrumentar e depurar.

### Passo 1 — instrumentar com `log`

Coloque um `log` com `name: 'foco.sessoes'` em cada transição de estado: iniciar, pausar,
retomar, finalizar. Isso responde **onde** a conta se perde.

### Passo 2 — ler a sequência

Se o log mostrar `pausar` sendo chamado duas vezes seguidas, a hipótese já apareceu: o botão
está registrando o toque duas vezes, ou o `Timer` não foi cancelado na primeira pausa.

### Passo 3 — breakpoint condicional na hipótese

Coloque um breakpoint na linha que soma os minutos, com a condição
`_segundosAcumulados % 60 != 0`, e inspecione o `this` inteiro quando parar.

---

## 💻 Código completo

> **Arquivo:** `foco_lab/lib/laboratorio/cronometro_sessao.dart`
> **Como executar:** `flutter run -d windows -t lib/laboratorio/cronometro_sessao.dart`
> (para depurar, abra o arquivo no VS Code e pressione `F5`)

```dart
// foco_lab/lib/laboratorio/cronometro_sessao.dart
// Cronômetro de sessão de estudo instrumentado com log e pontos de parada.
import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: TelaCronometro()));

/// Uma sessão de estudo de uma matéria, com os minutos já acumulados.
class SessaoEstudo {
  SessaoEstudo({required this.materia});

  final String materia;
  int segundos = 0;

  /// Minutos inteiros a gravar na matéria ao finalizar a sessão.
  int get minutos => segundos ~/ 60;

  @override
  String toString() => 'SessaoEstudo($materia, ${segundos}s, ${minutos}min)';
}

class TelaCronometro extends StatefulWidget {
  const TelaCronometro({super.key});

  @override
  State<TelaCronometro> createState() => _TelaCronometroState();
}

class _TelaCronometroState extends State<TelaCronometro> {
  final SessaoEstudo _sessao = SessaoEstudo(materia: 'Álgebra Linear');
  Timer? _timer;
  bool _rodando = false;

  void _iniciarOuPausar() {
    if (_rodando) {
      _timer?.cancel();
      developer.log(
        'Sessão pausada em ${_sessao.segundos}s',
        name: 'foco.sessoes',
        level: 800, // INFO
      );
    } else {
      // Coloque um BREAKPOINT nesta linha e use "step into" (F11) para
      // entrar no callback do Timer.
      _timer = Timer.periodic(const Duration(seconds: 1), _aoPassarUmSegundo);
      developer.log('Sessão iniciada', name: 'foco.sessoes', level: 800);
    }
    setState(() => _rodando = !_rodando);
  }

  void _aoPassarUmSegundo(Timer timer) {
    // BREAKPOINT CONDICIONAL sugerido aqui, com a condição:
    //   _sessao.segundos % 10 == 0
    // Assim você para a cada 10 segundos em vez de a cada 1.
    setState(() => _sessao.segundos++);
  }

  Future<void> _finalizar() async {
    _timer?.cancel();
    setState(() => _rodando = false);

    // debugger(when: ...) pararia aqui se um depurador estivesse conectado.
    // Descomente as duas linhas abaixo para experimentar:
    // import 'dart:developer' show debugger;  (já importado como developer)
    // developer.debugger(when: _sessao.minutos == 0, message: 'Sessão zerada');

    try {
      final int gravados = await _gravarNaMateria(_sessao);
      developer.log(
        'Gravados $gravados min em ${_sessao.materia}',
        name: 'foco.sessoes',
        level: 800,
      );
      if (!mounted) return; // obrigatório depois de um await dentro de State
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$gravados min gravados')),
      );
    } catch (erro, pilha) {
      developer.log(
        'Falha ao gravar a sessão',
        name: 'foco.sessoes',
        level: 1000, // SEVERE
        error: erro,
        stackTrace: pilha,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível gravar a sessão')),
      );
    }
  }

  /// Simula a gravação no banco (módulo 10). Falha de propósito com 0 minutos,
  /// para você ver um log de nível SEVERE com error e stackTrace.
  Future<int> _gravarNaMateria(SessaoEstudo sessao) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (sessao.minutos == 0) {
      throw StateError('Sessão de menos de 1 minuto não é gravada');
    }
    return sessao.minutos;
  }

  @override
  void dispose() {
    _timer?.cancel(); // sem isto: setState() called after dispose() (aula 1)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int m = _sessao.segundos ~/ 60;
    final int s = _sessao.segundos % 60;

    return Scaffold(
      appBar: AppBar(title: Text(_sessao.materia)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 64, fontFeatures: <FontFeature>[
                FontFeature.tabularFigures(),
              ]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _iniciarOuPausar,
                  icon: Icon(_rodando ? Icons.pause : Icons.play_arrow),
                  label: Text(_rodando ? 'Pausar' : 'Iniciar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _finalizar,
                  icon: const Icon(Icons.stop),
                  label: const Text('Finalizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

> ℹ️ `FontFeature` vem de `dart:ui`, reexportado por `package:flutter/material.dart`.
> `tabularFigures` faz todos os dígitos terem a mesma largura, para o cronômetro não "tremer"
> quando o número muda.

---

## 🔍 Explicando o código

- **`developer.log(..., name: 'foco.sessoes')`** — o `name` é o que torna o log filtrável. Use
  sempre o padrão `app.modulo`: `foco.sessoes`, `foco.trilhas`, `foco.materias`. No DevTools você
  digita `foco.sessoes` na caixa de filtro e o resto some.
- **`level: 800` × `level: 1000`** — o primeiro é um evento normal; o segundo é uma falha que o
  usuário percebeu. Quando o app crescer e você integrar um serviço de monitoramento
  ([módulo 16](../16-publicacao-e-proximos-passos/05-monitoramento-e-feedback.md)), só os
  `SEVERE` viram alerta.
- **`error: erro, stackTrace: pilha`** no `catch (erro, pilha)` — passar os dois é o que
  diferencia um log útil de um log inútil. Sem o `stackTrace`, você sabe que falhou, mas não onde.
- **`if (!mounted) return;` depois de cada `await`** — o `_gravarNaMateria` demora 300 ms. Se a
  pessoa sair da tela nesse intervalo, usar o `context` depois causaria exatamente o erro
  `setState() called after dispose()` da [aula 1](01-lendo-stack-traces.md).
- **`_timer?.cancel()` no `dispose()`** — o par obrigatório de todo `Timer.periodic`.
- **`_gravarNaMateria` lança com 0 minutos de propósito** — é o gatilho para você ver, no
  DevTools, um log `SEVERE` já com o stack trace formatado.
- **`_aoPassarUmSegundo` é um método separado**, e não uma função anônima dentro do
  `Timer.periodic`. Isso é proposital: um método nomeado aparece com nome legível na pilha de
  chamadas e aceita breakpoint com condição sobre `this`.

---

## 🤖🍎 Android × iOS

O código é o mesmo; o **destino** do log muda:

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| `debugPrint` vai para | logcat, tag `flutter` | console do dispositivo / Xcode |
| `developer.log(name: 'x')` vai para | logcat, com a etiqueta no corpo da linha | `os_log`, visível no Console.app |
| Como ler sem o VS Code | `adb logcat -s flutter` | Console.app (macOS) filtrando pelo app |
| Ferramenta que funciona nos dois | `flutter logs`, e a aba **Logging** do DevTools | idem |

> 🪟 **No Windows:** `flutter logs`, o terminal do `flutter run` e a aba **Logging** do DevTools
> funcionam normalmente para Windows desktop, Chrome e Android (emulador ou aparelho USB).
> Para um **iPhone físico** você precisaria de um Mac — veja a
> [aula 9](09-depurando-android-e-ios.md).

---

## ⚠️ Erros comuns

| O que você faz de errado | O que acontece | O certo |
|---|---|---|
| Usar `print()` em código Flutter | Aviso `avoid_print` e linhas descartadas no 🤖 Android | `debugPrint()` ou `developer.log()` |
| Imprimir um JSON grande com `print` | Log cortado no meio, você culpa a API | `debugPrint()`, que controla a vazão |
| Deixar logs de diagnóstico no release | Gasto de processamento e risco de vazar dados | Envolva em `if (kDebugMode)` ou remova |
| Logar token, senha ou corpo de login | Qualquer pessoa com o cabo USB lê | **Nunca** logue credencial. Logue o status HTTP, não o corpo |
| Esperar breakpoint funcionar em `--release` | "Meu breakpoint não pega" | Breakpoint só existe em **debug** |
| Colocar breakpoint dentro de `build()` de uma lista | Para dezenas de vezes por segundo | Use breakpoint **condicional** ou um *logpoint* |
| Depurar um gesto com breakpoint | O toque se perde enquanto o app está parado | Use log para gestos e animações |
| Esquecer um `debugger()` no código | Trava a sua depuração seguinte sem você entender | Remova antes de commitar; o `dart analyze` não avisa |

---

## 🛠️ Exercício guiado

**Objetivo:** encontrar, com log e com breakpoint, por que uma sessão de 90 segundos grava só
1 minuto.

1. Salve `cronometro_sessao.dart` em `foco_lab/lib/laboratorio/`.
2. Abra o arquivo no VS Code e pressione `F5`. Escolha o dispositivo **Windows**.
3. Clique em **Iniciar**, espere cerca de 90 segundos (ou mude
   `const Duration(seconds: 1)` para `const Duration(milliseconds: 100)` para acelerar) e clique
   em **Finalizar**.
4. Observe o painel **DEBUG CONSOLE**: você verá as linhas de `foco.sessoes`.
5. **Breakpoint simples:** clique na margem esquerda da linha
   `final int gravados = await _gravarNaMateria(_sessao);`. Rode de novo e finalize. Quando o
   programa parar:
   - no painel **Variables**, abra `this` → `_sessao` e leia `segundos` e `minutos`;
   - no painel **Watch**, adicione a expressão `_sessao.segundos / 60` e compare com
     `_sessao.minutos`. Explique a diferença por escrito.
6. **Step into:** com o programa parado, pressione `F11`. Você entra em `_gravarNaMateria`.
   Pressione `Shift + F11` (*step out*) para voltar. Repita com `F10` (*step over*) e descreva a
   diferença entre os três.
7. **Breakpoint condicional:** clique com o botão direito na margem da linha
   `setState(() => _sessao.segundos++);` → **Add Conditional Breakpoint** → digite
   `_sessao.segundos % 10 == 0`. Rode e confirme que ele para de 10 em 10.
8. **Logpoint:** apague o breakpoint condicional e, no mesmo lugar, adicione um
   **Logpoint** com a mensagem `tique {_sessao.segundos}`. Rode: o programa **não para**, mas
   escreve no console. Explique quando isso é melhor que um `debugPrint`.
9. **Call Stack:** pare de novo no breakpoint do passo 5 e clique no quadro logo abaixo do topo.
   Anote qual função chamou `_finalizar`.

**Resultado esperado:** você consegue afirmar, com evidência, que `minutos` usa divisão inteira
(`~/`) e por isso 90 segundos viram 1 minuto — e sabe apontar a linha exata onde isso acontece.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/12-testes-e-debug.md](../../exercicios/12-testes-e-debug.md)

---

## 🏆 Desafio opcional

Crie, em `foco_lab/lib/core/`, um arquivo `diagnostico.dart` com uma função única de log para o
app inteiro:

```dart
void registrar(String mensagem, {String modulo = 'foco', int nivel = 800, Object? erro, StackTrace? pilha});
```

Requisitos:

1. Em **debug**, chama `developer.log` com `name: modulo` e os campos preenchidos.
2. Em **release**, ignora tudo que for abaixo de `900` (WARNING) e nunca escreve o `erro` completo.
3. Nunca aceita imprimir uma `String` que contenha `token`, `senha` ou `password` — nesses casos,
   substitui o valor por `***`.
4. Troque todos os `developer.log` do cronômetro por `registrar(...)` e confirme que a aba
   Logging do DevTools continua mostrando `foco.sessoes`.

Depois responda: por que o item 3 é uma proteção fraca, e o que seria uma proteção forte?
(Dica: pense em quem controla o que é passado para a função.)

---

## 📌 Resumo

- Em Flutter, `print()` dispara o lint **`avoid_print`**: pode ser truncado pelo 🤖 Android,
  sobrevive ao release e não dá para filtrar. Use **`debugPrint()`**.
- `debugPrint` controla a vazão da saída, por isso **não perde linhas** em logs grandes.
- `developer.log()` de `dart:developer` acrescenta `name` (etiqueta filtrável), `level`
  (500 FINE … 1000 SEVERE), `error` e `stackTrace`.
- Envolva diagnóstico em `if (kDebugMode)` para ele sumir do build de release.
- **Breakpoint** congela o programa e entrega Variables, Watch e Call Stack. `F5` inicia,
  `F10` passa por cima, `F11` entra, `Shift+F11` sai.
- **Breakpoint condicional**, **hit count** e **logpoint** evitam parar mil vezes.
- `debugger(when:, message:)` é um breakpoint escrito no código; sem depurador conectado, não faz
  nada — mas remova antes de publicar.
- Regra: **log para descobrir _onde_; breakpoint para descobrir _por quê_.** Gestos, timers e
  animações pedem log, porque parar o programa distorce o tempo.

---

## ☑️ Checklist de domínio

- [ ] Explico as três razões pelas quais `print()` é desaconselhado em Flutter.
- [ ] Digo por que `debugPrint` não perde linhas em um log grande.
- [ ] Escrevo um `developer.log` com `name`, `level`, `error` e `stackTrace`.
- [ ] Sei os números dos níveis INFO (800), WARNING (900) e SEVERE (1000).
- [ ] Coloco um breakpoint e um breakpoint **condicional** no VS Code.
- [ ] Uso `F10`, `F11` e `Shift+F11` e explico a diferença entre os três.
- [ ] Leio os painéis Variables, Watch e Call Stack e sei para que serve cada um.
- [ ] Crio um **logpoint** e explico por que ele não para o programa.
- [ ] Uso `debugger(when:)` e sei que ele é inofensivo sem depurador conectado.
- [ ] Escolho entre log e breakpoint justificando pela natureza do bug.

---

## 📚 Referências oficiais

- [Debugging Flutter apps programmatically — docs.flutter.dev](https://docs.flutter.dev/testing/code-debugging)
- [Debugging tools — docs.flutter.dev](https://docs.flutter.dev/testing/debugging-tools)
- [debugPrint — api.flutter.dev](https://api.flutter.dev/flutter/foundation/debugPrint.html)
- [dart:developer log — api.dart.dev](https://api.dart.dev/stable/dart-developer/log.html)
- [dart:developer debugger — api.dart.dev](https://api.dart.dev/stable/dart-developer/debugger.html)
- [avoid_print — dart.dev linter rules](https://dart.dev/tools/linter-rules/avoid_print)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 1 — Lendo stack traces](01-lendo-stack-traces.md) | [README](README.md) | [Aula 3 — DevTools](03-devtools.md) |
