# Aula 4 — Modelando respostas e erros

> **Módulo:** 09 - Consumo de API · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Criar uma exceção própria, `ApiException`, com **mensagem** e **`statusCode`**.
- Traduzir um código de status HTTP em uma **mensagem útil ao usuário**, em português.
- Reconhecer e tratar `SocketException` (sem internet), `FormatException` (JSON inválido) e
  `TimeoutException` (demorou demais).
- Saber que o pacote `http` também lança `ClientException`, e onde isso importa.
- Modelar todas as falhas possíveis numa **hierarquia `sealed`**, e tratá-las com `switch`
  exaustivo.
- Explicar por que **nunca** se mostra *stack trace* nem `toString()` de exceção ao usuário
  final — e onde essa informação deve ir.
- Escrever mensagens de erro que dizem **o que aconteceu** e **o que fazer**.
- Marcar quais falhas permitem "tentar de novo" e quais não permitem.

## ✅ Pré-requisitos

- [Aula 3 — Primeiro GET](03-primeiro-get.md) com o projeto `foco_api` rodando.
- [04/01 — Exceptions](../04-dart-avancado/01-exceptions.md): `throw`, `try`, `on`, `catch`,
  `finally`, `rethrow`.
- [04/06 — Sealed classes](../04-dart-avancado/06-sealed-classes.md): `sealed`, `final class`,
  `switch` exaustivo.
- [04/05 — Patterns e switch](../04-dart-avancado/05-patterns-e-switch.md): `switch` de
  expressão e casamento por tipo.
- [06/12 — Estados de UI](../06-widgets-e-layouts/12-estados-de-ui.md).

---

## 📖 Conceito

### O problema que esta aula resolve

No exercício da aula 3 você produziu **cinco** causas de falha diferentes:

| Causa | O que realmente aconteceu |
|---|---|
| Caminho inexistente | O servidor respondeu `404` |
| Corpo em formato inesperado | Veio um objeto onde esperávamos uma lista |
| Wi-Fi desligado | A requisição nem saiu — `SocketException` |
| Servidor fora do ar | `500`, ou nem resposta |
| Demora | A requisição ficou pendurada |

E o usuário viu **uma** mensagem: "Não conseguimos carregar as tarefas."

Isso é ruim por dois motivos opostos, e é importante entender que são dois problemas distintos:

1. **Para o usuário, falta especificidade.** "Sem internet" é uma coisa que ele resolve em cinco
   segundos ligando o Wi-Fi. "O servidor está fora do ar" é uma coisa que ele não pode resolver,
   e insistir só gasta bateria. A mesma tela para os dois casos desperdiça a chance de ajudar.
2. **Para você, falta diagnóstico.** Quando um usuário reclamar, você precisa saber se foi rede,
   status ou formato. Se tudo vira uma `Exception` genérica, o log não serve para nada.

A solução tem duas peças, e é essencial não confundi-las:

| Peça | O que é | Onde vive |
|---|---|---|
| `ApiException` | Uma **exceção**, lançada pela camada de rede quando o servidor responde fora da faixa `2xx` | Camada de dados |
| `sealed class Falha` | Um **valor**, que descreve o problema de forma fechada e legível | Do domínio até a tela |

**Exceção é para sinalizar; valor é para decidir.** Você lança `ApiException` porque o fluxo
normal não pode continuar. Você converte isso em `Falha` porque a tela precisa **escolher** uma
mensagem, um ícone e um botão — e `switch` sobre um tipo fechado é a forma mais segura de
escolher.

### Uma exceção própria: `ApiException`

Em Dart, qualquer objeto pode ser lançado, mas a convenção é implementar `Exception`:

```dart
class ApiException implements Exception {
  const ApiException({required this.mensagem, required this.statusCode, this.corpo});

  final String mensagem;
  final int statusCode;
  final String? corpo;
}
```

Por que criar uma classe, em vez de `throw Exception('erro 404')`?

- **Porque o `catch` fica preciso.** `on ApiException catch (e)` pega só o que interessa. Com
  `Exception` genérica, você pegaria também erros de programação e os esconderia.
- **Porque o `statusCode` fica acessível como número.** Você consegue escrever
  `if (e.statusCode == 401) { renovarToken(); }` — assunto da aula 8. Com uma mensagem de texto,
  você teria que fazer análise de string, que é frágil.
- **Porque o log fica útil.** Você grava status, URL e corpo, sem depender de como alguém
  formatou a mensagem.

### As três exceções do Dart que você **vai** encontrar

Além da sua `ApiException`, três exceções nascem fora do seu código e chegam até você. Elas são
diferentes na causa, na biblioteca e no tratamento:

#### 1. `SocketException` — a requisição não saiu

Vem de `dart:io`. Significa que não houve conversa nenhuma com o servidor: DNS não resolveu, não
há rota, a conexão foi recusada.

```text
SocketException: Failed host lookup: 'jsonplaceholder.typicode.com'
(OS Error: No address associated with hostname, errno = 7)
```

Causas reais: modo avião, Wi-Fi sem internet, emulador sem rede, 🤖 permissão `INTERNET` faltando
no release, DNS quebrado.

> **Detalhe importante do pacote `http`:** quando o `http` encontra um `SocketException` no
> Android/iOS/desktop, ele o repassa num objeto que é, ao mesmo tempo, um `SocketException` **e**
> um `ClientException`. Por isso a mensagem costuma aparecer como
> `ClientException with SocketException: Failed host lookup: ...`. Na prática: capture
> `SocketException` primeiro e `ClientException` depois, e você cobre tudo.

> ⚠️ `SocketException` mora em `dart:io`, que **não existe na web**. Se um dia você compilar este
> app para web, esse `import` quebra o build. Como o curso mira Android e iOS, seguimos com
> `dart:io`, mas fica o registro.

#### 2. `FormatException` — veio algo que não é o JSON esperado

Vem de `dart:core`. É lançada pelo `jsonDecode` quando o texto não é JSON válido, e pelo seu
próprio `fromJson` quando o contrato foi quebrado.

```text
FormatException: Unexpected character (at character 1)
<!DOCTYPE html><html><head><title>502 Bad Gateway</title>
^
```

Essa saída acima é o caso clássico: um servidor intermediário caiu e devolveu **HTML** com
status `200`. O seu `jsonDecode` tentou ler `<` como início de JSON.

#### 3. `TimeoutException` — demorou além do limite

Vem de `dart:async`. Só acontece se **você** colocou um limite com `.timeout(...)` — e é
exatamente por isso que a [aula 6](06-timeout-retry-cancelamento.md) insiste que você sempre
coloque.

```text
TimeoutException after 0:00:15.000000: Future not completed
```

### A hierarquia `sealed` de falhas

`sealed class` é uma classe que **só pode ser estendida dentro do mesmo arquivo**. Isso dá ao
compilador uma garantia poderosa: ele sabe a lista completa de subtipos. Consequência prática:

> Um `switch` sobre uma `sealed class` que esquecer um caso **não compila**. Se você acrescentar
> uma falha nova daqui a três meses, o `flutter analyze` aponta todos os lugares que precisam ser
> atualizados.

Compare com a alternativa comum, que é usar `enum` mais um campo de mensagem: o `enum` não
carrega dados diferentes por caso. Uma `FalhaServidor` precisa guardar o `statusCode`; uma
`FalhaSemConexao` não tem status nenhum. A `sealed class` permite que cada caso tenha os campos
que fazem sentido para ele.

O desenho que o curso adota, e que vai para o projeto final em `lib/core/erros/falhas.dart`:

```text
sealed class Falha
├── FalhaSemConexao       (nenhum campo extra)
├── FalhaTempoEsgotado    (segundos)
├── FalhaPedidoInvalido   (statusCode: 400, 422)
├── FalhaNaoAutenticado   (statusCode: 401)
├── FalhaSemPermissao     (statusCode: 403)
├── FalhaNaoEncontrado    (statusCode: 404)
├── FalhaMuitasTentativas (statusCode: 429, segundosParaTentar)
├── FalhaServidor         (statusCode: 5xx)
├── FalhaFormato          (detalhe técnico)
└── FalhaDesconhecida     (detalhe técnico)
```

Cada falha carrega três coisas que a tela precisa:

| Campo | Para que serve |
|---|---|
| `mensagem` | O título do erro, em português, dizendo **o que aconteceu** |
| `comoResolver` | A linha de baixo, dizendo **o que a pessoa pode fazer** |
| `podeTentarDeNovo` | Se o botão "Tentar de novo" deve aparecer |

### Nunca mostre *stack trace* ao usuário final

**Stack trace** (*rastro de pilha*) é a lista de chamadas de função que levou até o erro. É a
informação mais valiosa que existe **para você** e a mais inútil que existe **para o usuário**.

```text
#0      _TarefasScreenState._buscarTarefas (package:foco_api/features/tarefas/...)
#1      <asynchronous suspension>
#2      _FutureBuilderState._subscribe.<anonymous closure> (package:flutter/src/widgets/...)
```

Três razões para nunca colocar isso numa tela de produção:

1. **Não ajuda.** A pessoa não tem o que fazer com nomes de arquivo.
2. **Assusta.** Uma parede de texto técnico faz o app parecer quebrado, mesmo quando o problema é
   só o Wi-Fi.
3. **Vaza informação.** O rastro revela a estrutura interna do seu app, nomes de arquivos,
   às vezes trechos de URL com parâmetros. Isso é material de reconhecimento para quem quer
   atacar o sistema. O assunto volta em
   [13/06 — Segurança mobile](../13-desempenho-e-seguranca/06-seguranca-mobile.md).

Então para onde vai o *stack trace*? Para o **log**:

```dart
} catch (erro, pilha) {
  debugPrint('Falha ao buscar tarefas: $erro');
  debugPrintStack(stackTrace: pilha);
  throw converterParaFalha(erro);
}
```

`debugPrint` e `debugPrintStack` são **removidos automaticamente** do build de release pelo
Flutter — o que é exatamente o comportamento desejado. Num app de verdade, você trocaria isso por
uma ferramenta de monitoramento, assunto de
[16/05 — Monitoramento e feedback](../16-publicacao-e-proximos-passos/05-monitoramento-e-feedback.md).

### Como escrever uma boa mensagem de erro

Uma mensagem de erro útil responde a **três** perguntas, nesta ordem:

1. **O que aconteceu?** — em linguagem de gente, não de máquina.
2. **De quem é a bola?** — do usuário, da rede, ou do sistema.
3. **O que fazer agora?** — uma ação concreta.

Compare:

| ❌ Ruim | Por quê | ✅ Boa |
|---|---|---|
| `Exception: 404` | Código, não frase | "Não encontramos esta trilha. Ela pode ter sido removida." |
| "Erro ao processar requisição" | Não diz nada | "O servidor está com problemas no momento. Tente novamente em alguns minutos." |
| "Erro de rede. Verifique sua internet." quando o erro foi `500` | **Mente**, e culpa o usuário | "O servidor não respondeu. O problema é do nosso lado." |
| "FormatException: Unexpected character" | Técnico e assustador | "Recebemos uma resposta inesperada do servidor. Já registramos o problema." |
| "Falha" | Inútil | Qualquer coisa acima |

Regra de ouro: **nunca culpe o usuário por um problema que não é dele.** Dizer "verifique sua
internet" quando o servidor devolveu `503` faz a pessoa reiniciar o roteador à toa.

---

## 💡 Analogia

Pense num **atendimento de suporte de uma loja**.

O cliente liga e diz "não chegou". O atendente **não** repete para ele o log interno do sistema
de entregas ("exceção na thread 4 do serviço de roteamento"). Ele traduz:

- "Seu endereço está incompleto, pode confirmar o número?" → isso é `400`/`422`: **a bola é do
  cliente**, e ele pode resolver.
- "Você precisa se identificar com o CPF do pedido." → isso é `401`.
- "Este pedido é de outra conta, não posso te dar acesso." → isso é `403`.
- "Esse número de pedido não existe." → isso é `404`.
- "Nosso sistema está fora do ar, me dá dez minutos?" → isso é `5xx`: **a bola é da loja**, e o
  cliente não tem o que fazer além de esperar.
- "A ligação está ruim, não escutei." → isso é `SocketException`: a conversa nem aconteceu.

O `sealed class Falha` é o **roteiro de atendimento** do seu app: uma lista fechada de situações,
cada uma com a fala certa. E o compilador é o supervisor que não deixa você publicar um roteiro
com um caso sem resposta.

---

## 🧪 Exemplo mínimo

A menor versão útil das duas peças:

```dart
// A exceção lançada pela camada de rede.
class ApiException implements Exception {
  const ApiException(this.mensagem, this.statusCode);
  final String mensagem;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $mensagem';
}

// O valor entregue à tela.
sealed class Falha {
  const Falha(this.mensagem);
  final String mensagem;
}

final class FalhaSemConexao extends Falha {
  const FalhaSemConexao() : super('Você está sem conexão.');
}

final class FalhaServidor extends Falha {
  const FalhaServidor(this.statusCode) : super('O servidor está com problemas.');
  final int statusCode;
}

// A tela escolhe com um switch EXAUSTIVO.
String icone(Falha falha) => switch (falha) {
      FalhaSemConexao() => '📶',
      FalhaServidor() => '🛠️',
    };
```

Se você acrescentar `final class FalhaFormato extends Falha { ... }` e não atualizar o `switch`,
o analisador acusa:

```text
error • The type 'Falha' is not exhaustively matched by the switch cases since it
        doesn't match 'FalhaFormato()' • non_exhaustive_switch_expression
```

Esse erro é **o principal benefício** de usar `sealed`. Ele transforma um esquecimento silencioso
em um erro de compilação.

---

## 📱 Aplicando no Flutter

Os arquivos desta aula entram na pasta `core/`, porque tratamento de erro não pertence a uma
funcionalidade específica — todas usam:

```text
foco_api/lib/
├── core/
│   └── erros/
│       ├── api_exception.dart        <- a exceção da camada de rede
│       └── falhas.dart               <- a sealed class + o tradutor
└── features/
    └── tarefas/
        └── presentation/
            └── tarefas_screen.dart   <- atualizada nesta aula
```

O fluxo completo fica assim:

```text
http.get lança SocketException ────────┐
jsonDecode lança FormatException ──────┤
.timeout lança TimeoutException ───────┼──► converterParaFalha(erro) ──► Falha
status 4xx/5xx lança ApiException ─────┘                                   │
                                                                           ▼
                                                      switch exaustivo na tela
                                                      (mensagem + ícone + botão)
```

---

## 💻 Código completo

### 1. A exceção da camada de rede

> **Arquivo:** `foco_api/lib/core/erros/api_exception.dart`

```dart
/// Exceção lançada quando o servidor respondeu, mas com um status fora
/// da faixa de sucesso (2xx).
///
/// Ela guarda o [statusCode] como número para que camadas de cima possam
/// decidir o que fazer — por exemplo, renovar o token quando for 401.
class ApiException implements Exception {
  const ApiException({
    required this.mensagem,
    required this.statusCode,
    this.uri,
    this.corpo,
  });

  /// Descrição técnica, para log. NÃO é a mensagem mostrada ao usuário.
  final String mensagem;

  /// O código HTTP devolvido pelo servidor.
  final int statusCode;

  /// Qual endereço foi chamado. Ajuda muito na hora de depurar.
  final Uri? uri;

  /// O corpo da resposta de erro, se houver. Pode conter detalhes da API.
  final String? corpo;

  bool get ehErroDoCliente => statusCode >= 400 && statusCode < 500;
  bool get ehErroDoServidor => statusCode >= 500;

  @override
  String toString() =>
      'ApiException($statusCode) em ${uri ?? "(sem uri)"}: $mensagem';
}
```

### 2. A hierarquia de falhas

> **Arquivo:** `foco_api/lib/core/erros/falhas.dart`

```dart
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Descreve, de forma fechada, tudo o que pode dar errado ao falar com a API.
///
/// É uma `sealed class`: só pode ser estendida NESTE arquivo. Com isso, todo
/// `switch` sobre uma [Falha] é verificado pelo compilador — esquecer um caso
/// vira erro de análise, não um bug silencioso em produção.
sealed class Falha {
  const Falha({
    required this.mensagem,
    required this.comoResolver,
    required this.podeTentarDeNovo,
  });

  /// O que aconteceu, em português, para o usuário final.
  final String mensagem;

  /// O que a pessoa pode fazer agora.
  final String comoResolver;

  /// Se vale a pena mostrar o botão "Tentar de novo".
  final bool podeTentarDeNovo;
}

/// A requisição nem saiu do aparelho: sem rede, DNS falhou, modo avião.
final class FalhaSemConexao extends Falha {
  const FalhaSemConexao()
      : super(
          mensagem: 'Você está sem conexão com a internet.',
          comoResolver: 'Ligue o Wi-Fi ou os dados móveis e tente de novo.',
          podeTentarDeNovo: true,
        );
}

/// O servidor demorou mais que o limite que definimos.
final class FalhaTempoEsgotado extends Falha {
  const FalhaTempoEsgotado(this.segundos)
      : super(
          mensagem: 'O servidor demorou demais para responder.',
          comoResolver: 'Sua conexão pode estar lenta. Tente novamente.',
          podeTentarDeNovo: true,
        );

  final int segundos;
}

/// 400 e 422: o pedido chegou, mas está errado.
final class FalhaPedidoInvalido extends Falha {
  const FalhaPedidoInvalido(this.statusCode)
      : super(
          mensagem: 'Não foi possível enviar estes dados.',
          comoResolver: 'Revise as informações preenchidas e tente de novo.',
          podeTentarDeNovo: false,
        );

  final int statusCode;
}

/// 401: você não se identificou, ou a sessão expirou.
final class FalhaNaoAutenticado extends Falha {
  const FalhaNaoAutenticado()
      : super(
          mensagem: 'Sua sessão expirou.',
          comoResolver: 'Entre novamente para continuar.',
          podeTentarDeNovo: false,
        );
}

/// 403: você se identificou, mas não tem permissão.
final class FalhaSemPermissao extends Falha {
  const FalhaSemPermissao()
      : super(
          mensagem: 'Você não tem permissão para acessar este conteúdo.',
          comoResolver: 'Se acha que isso é um engano, fale com o suporte.',
          podeTentarDeNovo: false,
        );
}

/// 404: o recurso não existe.
final class FalhaNaoEncontrado extends Falha {
  const FalhaNaoEncontrado()
      : super(
          mensagem: 'Não encontramos este conteúdo.',
          comoResolver: 'Ele pode ter sido removido. Volte e escolha outro.',
          podeTentarDeNovo: false,
        );
}

/// 429: requisições demais em pouco tempo.
final class FalhaMuitasTentativas extends Falha {
  const FalhaMuitasTentativas({this.segundosParaTentar})
      : super(
          mensagem: 'Muitas tentativas em pouco tempo.',
          comoResolver: 'Aguarde alguns instantes antes de tentar de novo.',
          podeTentarDeNovo: true,
        );

  final int? segundosParaTentar;
}

/// 5xx: o problema é do servidor, não do usuário.
final class FalhaServidor extends Falha {
  const FalhaServidor(this.statusCode)
      : super(
          mensagem: 'O servidor está com problemas no momento.',
          comoResolver: 'Não é nada do seu lado. Tente de novo em alguns minutos.',
          podeTentarDeNovo: true,
        );

  final int statusCode;
}

/// O corpo não era o JSON esperado: texto inválido, HTML de erro,
/// campo obrigatório ausente.
final class FalhaFormato extends Falha {
  const FalhaFormato(this.detalheTecnico)
      : super(
          mensagem: 'Recebemos uma resposta inesperada do servidor.',
          comoResolver: 'Já registramos o problema. Tente novamente mais tarde.',
          podeTentarDeNovo: true,
        );

  /// Só para log. NUNCA mostre isto na tela.
  final String detalheTecnico;
}

/// Qualquer coisa que não soubemos classificar.
final class FalhaDesconhecida extends Falha {
  const FalhaDesconhecida(this.detalheTecnico)
      : super(
          mensagem: 'Algo inesperado aconteceu.',
          comoResolver: 'Tente novamente. Se continuar, reinicie o aplicativo.',
          podeTentarDeNovo: true,
        );

  /// Só para log. NUNCA mostre isto na tela.
  final String detalheTecnico;
}

/// Converte qualquer erro capturado na [Falha] correspondente.
///
/// Este é o ÚNICO lugar do aplicativo que conhece `SocketException`,
/// `TimeoutException` e companhia. Depois daqui, o app inteiro fala
/// apenas a língua do [Falha].
Falha converterParaFalha(Object erro) {
  // A ordem importa: do mais específico para o mais genérico.
  if (erro is ApiException) {
    return switch (erro.statusCode) {
      400 || 422 => FalhaPedidoInvalido(erro.statusCode),
      401 => const FalhaNaoAutenticado(),
      403 => const FalhaSemPermissao(),
      404 => const FalhaNaoEncontrado(),
      429 => const FalhaMuitasTentativas(),
      >= 500 => FalhaServidor(erro.statusCode),
      _ => FalhaDesconhecida(erro.toString()),
    };
  }

  if (erro is TimeoutException) {
    return FalhaTempoEsgotado(erro.duration?.inSeconds ?? 0);
  }

  // SocketException cobre "sem internet" no Android, iOS e desktop.
  if (erro is SocketException) {
    return const FalhaSemConexao();
  }

  // O pacote http embrulha problemas de conexão em ClientException.
  if (erro is http.ClientException) {
    return const FalhaSemConexao();
  }

  if (erro is FormatException) {
    return FalhaFormato(erro.message);
  }

  return FalhaDesconhecida(erro.toString());
}
```

### 3. A tela, agora com erro tratado de verdade

> **Arquivo:** `foco_api/lib/features/tarefas/presentation/tarefas_screen.dart`
> **Como executar:** `flutter run` (de dentro de `foco_api`)

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/erros/api_exception.dart';
import '../../../core/erros/falhas.dart';
import '../domain/tarefa.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  late Future<List<Tarefa>> _futuroTarefas;

  @override
  void initState() {
    super.initState();
    _futuroTarefas = _buscarTarefas();
  }

  Future<List<Tarefa>> _buscarTarefas() async {
    final uri = Uri.https(
      'jsonplaceholder.typicode.com',
      '/todos',
      <String, String>{'_limit': '20'},
    );

    try {
      final resposta = await http
          .get(uri, headers: const <String, String>{'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        throw ApiException(
          mensagem: 'Status inesperado ao listar tarefas.',
          statusCode: resposta.statusCode,
          uri: uri,
          corpo: resposta.body,
        );
      }

      final decodificado = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (decodificado is! List) {
        throw const FormatException('Esperava uma lista de tarefas.');
      }

      return decodificado
          .map((item) => Tarefa.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (erro, pilha) {
      // O detalhe técnico vai para o LOG — nunca para a tela.
      // debugPrint some sozinho no build de release.
      debugPrint('[TarefasScreen] falha ao buscar $uri: $erro');
      debugPrintStack(stackTrace: pilha);

      // E a tela recebe uma Falha, que é um valor, não um acidente.
      throw converterParaFalha(erro);
    }
  }

  void _recarregar() {
    setState(() {
      _futuroTarefas = _buscarTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas de estudo'),
        actions: <Widget>[
          IconButton(
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: FutureBuilder<List<Tarefa>>(
        future: _futuroTarefas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            final erro = snapshot.error;
            // Se, por descuido, chegar algo que não é Falha, não quebramos.
            final falha = erro is Falha ? erro : FalhaDesconhecida('$erro');
            return EstadoDeFalha(falha: falha, aoTentarDeNovo: _recarregar);
          }

          final tarefas = snapshot.data ?? const <Tarefa>[];
          if (tarefas.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa encontrada.'));
          }

          return ListView.separated(
            itemCount: tarefas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, indice) {
              final tarefa = tarefas[indice];
              return ListTile(
                leading: Icon(
                  tarefa.concluida
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
                title: Text(tarefa.titulo),
                subtitle: Text('Tarefa #${tarefa.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget reutilizável que apresenta uma [Falha] ao usuário final.
///
/// Repare que ele não recebe `Exception` nem `StackTrace`: só o valor
/// [Falha], que já foi traduzido para linguagem de gente.
class EstadoDeFalha extends StatelessWidget {
  const EstadoDeFalha({
    super.key,
    required this.falha,
    required this.aoTentarDeNovo,
  });

  final Falha falha;
  final VoidCallback aoTentarDeNovo;

  /// O `switch` é EXAUSTIVO: se uma Falha nova for criada em falhas.dart
  /// e não for tratada aqui, o `flutter analyze` aponta este ponto.
  IconData get _icone => switch (falha) {
        FalhaSemConexao() => Icons.wifi_off,
        FalhaTempoEsgotado() => Icons.hourglass_disabled,
        FalhaPedidoInvalido() => Icons.edit_note,
        FalhaNaoAutenticado() => Icons.lock_outline,
        FalhaSemPermissao() => Icons.block,
        FalhaNaoEncontrado() => Icons.search_off,
        FalhaMuitasTentativas() => Icons.timer,
        FalhaServidor() => Icons.cloud_off,
        FalhaFormato() => Icons.rule_folder_outlined,
        FalhaDesconhecida() => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(_icone, size: 56, color: tema.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              falha.mensagem,
              style: tema.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              falha.comoResolver,
              style: tema.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (falha.podeTentarDeNovo) ...<Widget>[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: aoTentarDeNovo,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar de novo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

Rode e confirme:

```powershell
flutter analyze
flutter run
```

---

## 🔍 Explicando o código

| Trecho | Por que está assim |
|---|---|
| `class ApiException implements Exception` | `implements`, não `extends`: `Exception` é uma interface marcadora sem implementação útil. É o padrão do Dart |
| `final int statusCode;` | Guardado como **número**, não como texto. Isso permite `if (e.statusCode == 401)` na aula 8 |
| `final Uri? uri;` | Sem a URL, um log de erro é quase inútil quando o app chama cinco endereços diferentes |
| `sealed class Falha` | Só pode ser estendida neste arquivo. É o que dá exaustividade ao `switch` |
| `final class FalhaSemConexao extends Falha` | `final class` impede que alguém estenda `FalhaSemConexao` de fora. Junto com `sealed`, fecha a hierarquia por completo |
| `const FalhaSemConexao() : super(mensagem: ..., ...)` | Construtor `const` com os textos fixos na lista de inicialização. Permite `const` nos widgets que usam a falha |
| `podeTentarDeNovo` em cada falha | Um `404` não melhora se você apertar "tentar de novo" cinco vezes. Mostrar o botão nesse caso é enganar o usuário |
| `switch (erro.statusCode) { 400 \|\| 422 => ..., >= 500 => ... }` | `switch` de expressão com **padrão lógico** (`\|\|`) e **padrão relacional** (`>= 500`). Sintaxe de Dart 3, muito mais legível que uma cadeia de `if` |
| `_ => FalhaDesconhecida(...)` | O caso padrão. Sem ele o `switch` sobre `int` não seria exaustivo |
| `erro.duration?.inSeconds ?? 0` | `TimeoutException.duration` é `Duration?`. O `?.` evita `Null check operator used on a null value` |
| Ordem dos `if` em `converterParaFalha` | **Do mais específico para o mais genérico.** Se `FormatException` viesse antes de `ApiException`, nada mudaria (são tipos diferentes), mas `ClientException` precisa vir depois de `SocketException`, porque o objeto lançado pelo `http` satisfaz os dois |
| `debugPrint` + `debugPrintStack` no `catch` | O rastro fica no log de desenvolvimento e **some no release**, que é o comportamento certo |
| `throw converterParaFalha(erro);` dentro do `catch` | Convertemos o acidente em valor e relançamos. A tela nunca vê `SocketException` |
| `erro is Falha ? erro : FalhaDesconhecida('$erro')` | Cinto de segurança. Se algum caminho esquecer de converter, o app mostra um erro decente em vez de quebrar |
| `IconData get _icone => switch (falha) {...}` | Um `switch` de expressão sobre a `sealed class`. **Sem `default`, de propósito**: é o `default` que destruiria a exaustividade |
| `FalhaSemConexao()` (com parênteses) no `case` | É um **padrão de objeto**: casa com qualquer instância desse tipo. Sem os parênteses, o Dart entenderia como nome de variável |
| `if (falha.podeTentarDeNovo) ...<Widget>[...]` | O **operador spread condicional**: insere dois widgets na lista só quando a condição é verdadeira |

> ⚠️ **Não coloque `default:` num `switch` sobre `sealed class`.** Ele faz o `switch` compilar
> para sempre e você perde exatamente a proteção pela qual escolheu `sealed`. Se um dia uma falha
> nova aparecer, o `default` a engole em silêncio.

---

## ⚠️ Erros comuns

| # | Erro | Sintoma | Correção |
|---|---|---|---|
| 1 | `catch (e) { }` vazio | O erro some e o app fica num estado impossível de diagnosticar | Sempre registre, mesmo que só com `debugPrint` |
| 2 | Mostrar `erro.toString()` na tela | Usuário lê `SocketException: Failed host lookup` | Traduza para `Falha` e mostre `falha.mensagem` |
| 3 | `default:` num `switch` sobre `sealed class` | A exaustividade morre e a falha nova é engolida | Trate todos os casos explicitamente |
| 4 | `on Exception catch (e)` esperando pegar tudo | `Error` (ex.: `TypeError`, `RangeError`) **não** é `Exception` e escapa | Use `catch (erro, pilha)` sem `on` no ponto de tradução |
| 5 | Verificar `ClientException` antes de `SocketException` | Todo erro de rede vira o caso genérico | `SocketException` primeiro |
| 6 | Dizer "verifique sua internet" para um `500` | Culpa o usuário por um problema do servidor | Cada status tem a sua mensagem |
| 7 | Mostrar botão "Tentar de novo" num `404` | A pessoa aperta cinco vezes e nada muda | Use `podeTentarDeNovo` |
| 8 | Esquecer `.timeout(...)` | `TimeoutException` nunca acontece; o app fica girando para sempre | Toda requisição com `.timeout` (aula 6) |
| 9 | Importar `dart:io` num app que também vai para web | O build de web falha | O curso mira Android/iOS; se for para web, use só `ClientException` |
| 10 | `ApiException extends Exception` | Compila, mas é contra a convenção do Dart | `implements Exception` |
| 11 | Uma `Falha` sem `comoResolver` | A tela mostra o problema e deixa a pessoa sem saída | Todo caso tem uma ação sugerida |

---

## 🛠️ Exercício guiado

**Objetivo:** provocar cada uma das falhas e confirmar que a tela reage de forma diferente a cada
uma.

**Passo 1 — `404`.** Troque o caminho de `/todos` para `/coisas-inexistentes`.
Esperado na tela: ícone de lupa cortada, "Não encontramos este conteúdo.", **sem** botão
"Tentar de novo".

**Passo 2 — `500`.** A JSONPlaceholder não devolve `500` sob demanda. Simule lançando na mão,
logo depois do `await`:

```dart
throw ApiException(mensagem: 'simulação', statusCode: 503, uri: uri);
```

Esperado: ícone de nuvem cortada, "O servidor está com problemas no momento.", **com** botão.

**Passo 3 — sem internet.** Ative o modo avião no emulador (ou desligue o Wi-Fi da máquina) e
toque em "Tentar de novo".
Esperado: ícone de Wi-Fi cortado, "Você está sem conexão com a internet."
Confirme no terminal do `flutter run` que apareceu o `debugPrint` com o `SocketException`
completo — **essa informação existe, só não está na tela**.

**Passo 4 — formato inválido.** Troque `/todos` por `/todos/1` (que devolve um objeto, não uma
lista).
Esperado: "Recebemos uma resposta inesperada do servidor."

**Passo 5 — tempo esgotado.** Troque o timeout para um valor impossível:

```dart
.timeout(const Duration(milliseconds: 1))
```

Esperado: "O servidor demorou demais para responder."

**Passo 6 — prove a exaustividade.** Acrescente ao fim de `falhas.dart`:

```dart
final class FalhaManutencao extends Falha {
  const FalhaManutencao()
      : super(
          mensagem: 'O sistema está em manutenção programada.',
          comoResolver: 'Voltamos em instantes. Tente de novo mais tarde.',
          podeTentarDeNovo: true,
        );
}
```

Rode `flutter analyze` **sem** tocar no widget `EstadoDeFalha`. Você deve ver:

```text
error • The type 'Falha' is not exhaustively matched by the switch cases
        since it doesn't match 'FalhaManutencao()'
```

Agora trate o caso novo (`FalhaManutencao() => Icons.construction,`) e rode de novo:
`No issues found!`

**Esse passo 6 é o coração da aula.** Guarde a sensação: o compilador acabou de impedir um bug
que só apareceria na tela de um usuário, meses depois.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/09-consumo-de-api.md](../../exercicios/09-consumo-de-api.md)

Desta aula saem exercícios de **implementação** (criar uma falha nova e tratá-la em todos os
lugares), de **correção de bugs** (um `catch` que mostra `toString()` na tela) e de **revisão
cumulativa** (ligar `sealed class` do módulo 04 com estado de UI do módulo 06).

---

## 🏆 Desafio opcional

Acrescente à `Falha` um campo `String get codigoParaSuporte`, gerado a partir do tipo e do
momento — por exemplo `SRV-503-1409T1345`.

Requisitos:

- O código aparece na tela, **pequeno e discreto**, abaixo do `comoResolver`.
- Um toque longo sobre ele copia o código para a área de transferência
  (`Clipboard.setData(ClipboardData(text: codigo))`) e mostra um `SnackBar` de confirmação com
  `ScaffoldMessenger.of(context).showSnackBar(...)`.
- O código **não** pode conter URL, nome de arquivo, nem trecho de *stack trace*.

Justifique por escrito, em cinco linhas, por que esse código ajuda o suporte sem violar a regra
de "nunca mostre detalhe técnico ao usuário". Dica: a diferença está entre **identificar uma
ocorrência** e **descrever a implementação**.

---

## 📌 Resumo

- **Exceção sinaliza, valor decide.** `ApiException` é lançada pela camada de rede; `Falha` é o
  valor que a tela consome.
- `ApiException` guarda `mensagem`, `statusCode`, `uri` e `corpo` — tudo o que o log precisa.
- As três exceções que chegam de fora: `SocketException` (sem rede, `dart:io`),
  `FormatException` (JSON inválido, `dart:core`) e `TimeoutException` (`dart:async`, só existe se
  você usar `.timeout`).
- O pacote `http` também lança `ClientException`; capture `SocketException` **antes** dele.
- `sealed class Falha` torna o `switch` **exaustivo**: esquecer um caso vira erro de compilação.
- **Nunca** use `default:` num `switch` sobre `sealed class` — isso destrói a exaustividade.
- Cada falha carrega `mensagem` (o que houve), `comoResolver` (o que fazer) e
  `podeTentarDeNovo` (se o botão aparece).
- **Nunca mostre *stack trace* nem `toString()` de exceção ao usuário.** Isso vai para
  `debugPrint`/`debugPrintStack`, que somem no release.
- Nunca culpe o usuário por um erro `5xx`.

---

## ☑️ Checklist de domínio

- [ ] Escrevo uma classe `ApiException implements Exception` com `statusCode`.
- [ ] Explico a diferença entre `implements Exception` e `extends Exception`.
- [ ] Digo de onde vêm `SocketException`, `FormatException` e `TimeoutException`.
- [ ] Sei que `TimeoutException` só acontece se eu tiver usado `.timeout(...)`.
- [ ] Sei que o `http` lança `ClientException` e por que a ordem dos `if` importa.
- [ ] Escrevo uma `sealed class` de falhas com `final class` para cada caso.
- [ ] Faço `switch` exaustivo sobre ela, sem `default`.
- [ ] Provo a exaustividade acrescentando um caso novo e vendo o `flutter analyze` acusar.
- [ ] Traduzo `400`, `401`, `403`, `404`, `429` e `5xx` em mensagens diferentes.
- [ ] Sei dizer quais falhas merecem botão "Tentar de novo" e quais não.
- [ ] Mando `stack trace` para o log e **nunca** para a tela.
- [ ] Escrevo mensagem que responde: o que houve, de quem é a bola, o que fazer.

---

## 📚 Referências oficiais

- [Error handling in Dart — dart.dev](https://dart.dev/language/error-handling)
- [Exception class — api.dart.dev](https://api.dart.dev/stable/dart-core/Exception-class.html)
- [FormatException class — api.dart.dev](https://api.dart.dev/stable/dart-core/FormatException-class.html)
- [SocketException class — api.dart.dev](https://api.dart.dev/stable/dart-io/SocketException-class.html)
- [TimeoutException class — api.dart.dev](https://api.dart.dev/stable/dart-async/TimeoutException-class.html)
- [ClientException class — pub.dev](https://pub.dev/documentation/http/latest/http/ClientException-class.html)
- [Class modifiers: sealed — dart.dev](https://dart.dev/language/class-modifiers#sealed)
- [Patterns and exhaustiveness — dart.dev](https://dart.dev/language/branches#exhaustiveness-checking)
- [debugPrint — api.flutter.dev](https://api.flutter.dev/flutter/foundation/debugPrint.html)
- [Handle errors — docs.flutter.dev](https://docs.flutter.dev/testing/errors)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 3 — Primeiro GET](03-primeiro-get.md) | [README](README.md) | [Aula 5 — POST, PUT e DELETE](05-post-put-delete.md) |
