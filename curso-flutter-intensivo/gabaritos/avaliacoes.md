# Gabarito das avaliações

> Respostas das avaliações de módulo 00 a 16, das cumulativas e da final.
> Não leia antes de concluir a tentativa.

<a id="modulo-00"></a>
## Módulo 00 — Git e terminal

[Voltar à avaliação](../avaliacoes/modulo-00-git-e-terminal.md)

### Questionário

| Questão | Resposta | Justificativa / divisão do ponto |
|---|---|---|
| 1 | B | `..` representa a pasta pai, relativa à localização atual |
| 2 | C | PATH fornece locais de busca de executáveis |
| 3 | B | `add` preparou B; a edição C ficou só no disco |
| 4 | C | `--staged` atua no índice, mantendo o arquivo no disco |
| 5 | A | `revert` registra a alteração inversa em um novo commit |
| 6 | D | Revogar/trocar impede o uso futuro da credencial exposta |
| 7 | Disco, preparação e commits | 0,25 por cada camada correta e 0,25 por um comando coerente, como `git diff --staged` |
| 8 | `git switch main`, depois `git merge revisao` | 0,5 pela sequência e 0,5 por explicar que a branch atual recebe a integração |
| 9 | apply preserva; pop remove após aplicar com sucesso | 0,5 pela diferença; 0,25 por `-u` incluir novos não rastreados e 0,25 por excluir ignorados |
| 10 | Ignore não age sobre o já rastreado | 0,25 por esse motivo; 0,5 por `git rm --cached -- .env` seguido de commit; 0,25 por explicar que o histórico permanece |

Na questão 9, se `pop` encontra conflito, a entrada não é removida automaticamente. Nas questões
abertas, aceite palavras diferentes com significado correto. Um comando que apaga a cópia local
não satisfaz o requisito da questão 10.

### Solução prática de referência

Na pasta de práticas, crie um laboratório novo. Os nomes abaixo devem estar livres.

```powershell
New-Item -ItemType Directory lab_m00_avaliacao
Set-Location lab_m00_avaliacao
git init -b main
git config user.name "Aluno"
git config user.email "aluno@example.invalid"
Set-Content -Encoding UTF8 README.md "Meta: 30 minutos"
git add README.md
git commit -m "docs: registre a meta inicial"
git switch -c ajuste-meta
Set-Content -Encoding UTF8 README.md "Meta: 45 minutos"
git add README.md
git commit -m "docs: aumente a meta"
$commitDaMeta = git rev-parse HEAD
git switch main
git merge ajuste-meta
Add-Content -Encoding UTF8 README.md "Rever aos domingos"
git add README.md
git restore --staged -- README.md
git diff -- README.md
git diff --staged -- README.md
git stash push -m "revisao semanal em andamento"
git revert --no-edit $commitDaMeta
Set-Content -Encoding UTF8 .gitignore @('.env', '*.jks', 'android/key.properties')
Set-Content -Encoding UTF8 .env "TOKEN=VALOR_FICTICIO_SEM_ACESSO"
git add .gitignore
git commit -m "chore: ignore configuracao e assinatura locais"
git log --oneline --graph --all
git status --short
git stash list
Get-Content README.md
git check-ignore -v .env
git ls-files -- .env
```

**Raciocínio:** guardar a edição incompleta deixa o repositório pronto para a reversão; usar o
hash anotado identifica exatamente a mudança da meta. O commit de reversão permanece no log.
O ignore protege a `.env` nova da inclusão comum, mas não remove conteúdo de commits antigos.

**Conferência:**

- Na etapa dos diffs, somente `git diff` mostra `Rever aos domingos`; o diff preparado está vazio.
- O README final contém 30 minutos; a branch `ajuste-meta` ainda permite consultar a versão 45.
- Existe uma entrada de stash; nela está a edição de revisão semanal.
- O log de `main` tem quatro commits nesta solução: meta inicial, aumento, reversão e ignore.
- O status final está limpo; `check-ignore` aponta `.env` e `ls-files -- .env` não retorna arquivo.

Os commits internos do stash também podem aparecer em `log --all`; eles não são novos commits
da sequência de `main`. Avalie o resultado e a preservação dos dados, não hashes exatos.

**Alternativas:** merge com `--no-ff` acrescenta um commit de integração válido; nesse caso, reverta
o hash da alteração da meta, como solicitado, e ajuste a contagem esperada. Conteúdo escrito pelo
editor e outras mensagens claras são aceitos.

**Erros frequentes:** tentar reverter com alterações locais pendentes; usar `HEAD` depois do commit
de ignore, revertendo a mudança errada; omitir `--staged`; tratar um `.env` rastreado como ignorado.

Use os pesos e os critérios obrigatórios da [avaliação](../avaliacoes/modulo-00-git-e-terminal.md).

---

<a id="modulo-01"></a>
## Módulo 01 — Lógica e fundamentos

[Voltar à avaliação](../avaliacoes/modulo-01-logica-e-fundamentos.md)

### Questionário

| Questão | Resposta | Justificativa / divisão do ponto |
|---|---|---|
| 1 | B | Receber é entrada; calcular é processamento; mostrar é saída |
| 2 | C | `DateTime.now()` acontece em execução e `final` impede reatribuição |
| 3 | C | `7 ~/ 2` é 3 e `7 % 2` é 1 |
| 4 | C | `continue` pula somente o restante da passagem atual |
| 5 | B | O tipo `int` e `return` disponibilizam o valor à chamada |
| 6 | A | A falha acontece depois que a execução começou |
| 7 | Parâmetro é declarado; argumento é fornecido | 0,5 pela distinção e 0,5 por exemplo coerente |
| 8 | 50 → 25 → 0 | 0,5 pelo rastreamento; 0,25 pela condição falsa em zero; 0,25 por identificar laço infinito sem mudança |
| 9 | `parse` lança; `tryParse` devolve `null` | 0,5 pela diferença e 0,5 por conferir `null` antes de usar `abc` |
| 10 | Três categorias corretas | Aproximadamente 0,33 por definição e exemplo de cada categoria |

### Solução prática de referência

```dart
int? converterPositivo(String texto) {
  final valor = int.tryParse(texto.trim());
  if (valor == null || valor <= 0) return null;
  return valor;
}

void gerarRelatorio(List<String> entradas, int meta) {
  var quantidade = 0;
  var total = 0;

  for (final entrada in entradas) {
    final valor = converterPositivo(entrada);
    if (valor == null) {
      print('Rejeitada: "$entrada"');
      continue;
    }
    quantidade++;
    total += valor;
  }

  print('Válidas: $quantidade');
  print('Total: $total min');
  if (quantidade == 0) {
    print('Média: indisponível');
  } else {
    print('Média: ${(total / quantidade).toStringAsFixed(1)} min');
  }
  print(total >= meta ? 'Meta atingida' : 'Faltam ${meta - total} min');
}

void main() {
  gerarRelatorio(<String>['25', 'abc', '0', '40', '-5', ' 30 '], 120);
  print('---');
  gerarRelatorio(<String>['abc', '0', '-5'], 120);
  print('---');
  gerarRelatorio(<String>['60', '60'], 120);
}
```

No primeiro cenário, as rejeitadas são `abc`, `0` e `-5`; há três válidas, total 95, média
31.7 e falta 25. No segundo, a média fica indisponível e não há divisão por zero. No terceiro,
a meta é atingida exatamente. A função não modifica a lista recebida.

**Alternativas válidas:** retornar um pequeno objeto/record com quantidade e total separa ainda
melhor regra e apresentação, mas records serão ensinados no módulo 04. Usar duas funções para
somar e contar também é correto, embora percorra as entradas duas vezes. Não aceite uma solução
que converta entrada inválida em zero e depois conte zero como sessão válida.

**Erros frequentes:** dividir por `entradas.length`; usar `int.parse`; calcular falta negativa;
declarar acumuladores dentro do laço; arredondar 31.666… sem `toStringAsFixed(1)`.

---

<a id="modulo-02"></a>
## Módulo 02 — Dart básico

[Voltar à avaliação](../avaliacoes/modulo-02-dart-basico.md)

### Questionário

| Questão | Resposta | Justificativa / divisão do ponto |
|---|---|---|
| 1 | C | `const` exige valor de compilação; `DateTime.now()` só existe na execução. |
| 2 | B | `trim` remove espaços e `tryParse` devolve `null` para texto inválido. |
| 3 | B | `?.` evita chamar método em nulo e `??` fornece reserva. |
| 4 | B | `Set` não preserva ocorrências duplicadas. |
| 5 | B | `update` altera uma chave existente e `ifAbsent` cria a inicial. |
| 6 | C | `fold` percorre acumulando um valor. |
| 7 | `final` recebe uma vez em execução; `const` é compilação | 0,5 pela distinção e 0,5 pelo exemplo com `final agora = DateTime.now()`. |
| 8 | `String?` pode conter `null` | 0,5 por identificar o risco e 0,5 por citar teste, `?.` ou `??`. |
| 9 | `List` mantém sessões; `Set` guarda matérias únicas; `Map` soma por matéria | Aproximadamente 0,33 por uso correto. |
| 10 | EOF pode devolver `null` | 0,5 por EOF e 0,5 por encerrar com `if (linha == null || linha.trim().isEmpty) break`. |

### Solução prática de referência

```dart
import 'dart:io';

class Resumo {
  Resumo(this.quantidade, this.total, this.maior, this.materias, this.porMateria);

  final int quantidade;
  final int total;
  final int maior;
  final Set<String> materias;
  final Map<String, int> porMateria;
}

Resumo resumir(Iterable<String> linhas) {
  var quantidade = 0;
  var total = 0;
  var maior = 0;
  final materias = <String>{};
  final porMateria = <String, int>{};

  for (final linha in linhas) {
    final partes = linha.split(',');
    if (partes.length != 2) continue;
    final materia = partes.first.trim();
    final minutos = int.tryParse(partes.last.trim());
    if (materia.isEmpty || minutos == null || minutos <= 0) continue;

    quantidade++;
    total += minutos;
    if (minutos > maior) maior = minutos;
    materias.add(materia);
    porMateria.update(materia, (atual) => atual + minutos, ifAbsent: () => minutos);
  }
  return Resumo(quantidade, total, maior, materias, porMateria);
}

void imprimir(Resumo resumo, int meta) {
  final media = resumo.quantidade == 0
      ? 'indisponível'
      : (resumo.total / resumo.quantidade).toStringAsFixed(1);
  print('Sessões: ${resumo.quantidade}');
  print('Total: ${resumo.total} min');
  print('Média: $media');
  print('Maior sessão: ${resumo.maior} min');
  print('Matérias: ${resumo.materias}');
  print('Por matéria: ${resumo.porMateria}');
  print(resumo.total >= meta ? 'Meta atingida' : 'Faltam ${meta - resumo.total} min');
}

void main() {
  final linhas = <String>[];
  while (true) {
    final linha = stdin.readLineSync();
    if (linha == null || linha.trim().isEmpty) break;
    linhas.add(linha);
  }
  imprimir(resumir(linhas), 120);
}
```

No caso proposto, há três sessões, total 95, média 31.7, maior 40, Dart e Git como matérias e totais Dart 65/Git 30. Para entrada vazia, a média é `indisponível`, maior é 0 e o programa não divide por zero. Uma solução que leia e processe cada linha diretamente também é válida.

**Erros frequentes:** usar `int.parse`; incluir sessão inválida no contador; usar `linhas.length` como divisor; trocar `Set` por lista sem remover repetidas; não verificar `null` retornado por `readLineSync`.

---

<a id="modulo-03"></a>
## Módulo 03 — Dart intermediário

[Voltar à avaliação](../avaliacoes/modulo-03-dart-intermediario.md)

| Questão | Resposta | Critério |
|---|---|---|
| 1 | B | objeto criado pela classe |
| 2 | B | referência não é reatribuída |
| 3 | B | getter controla leitura |
| 4 | B | contrato pode conter membros abstratos |
| 5 | B | todos os membros devem ser implementados |
| 6 | B | tipo é preservado e reutilizado |
| 7 | `extends` herda implementação; `implements` cumpre contrato | 0,5 por cada ideia |
| 8 | cria novo objeto e preserva o anterior | 0,5 por imutabilidade e 0,5 por previsibilidade |
| 9 | `Set` para matérias; `Map` para minutos por matéria | 0,5 por escolha |
| 10 | todo estado recebe tratamento em compilação | 1 por explicar cobertura futura |

Uma solução prática válida declara campos `final`, usa `copyWith` para alterar a tarefa, faz `Repositorio<TarefaEstudo>` em memória e filtra `status == StatusTarefa.pendente`. Deve demonstrar que a referência da tarefa original mantém seu status, que buscar id ausente retorna `null` e que o `switch` tem todos os valores do enum.

---

<a id="modulo-04"></a>
## Módulo 04 — Dart avançado

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-04-dart-avancado.md).

### Questionário

1. **B** — `rethrow` preserva exceção e stack trace; `throw e` reinicia o rastro e apaga a origem real.
2. **B** — `Future.wait` dispara as três juntas e o tempo passa a ser o da mais lenta; `async` sozinho não paraleliza nada.
3. **A** — stream single-subscription aceita **um** ouvinte; para vários, use `.broadcast()` ou reorganize para um ouvinte só.
4. **B** — a contagem dos campos posicionais começa em `$1`, não em `$0`.
5. **B** — `int` é tipo aberto: sem um caso `_ =>` o `switch` expressão não é exaustivo (`case`, `break` e `default:` pertencem ao `switch` instrução).
6. **B** — `async`/`await` só evita espera ociosa por I/O; trabalho de CPU precisa sair para outro isolate.
7. O `enum` serve para rótulos fechados **sem dados variáveis** por caso; se cada estado carrega informação diferente (a lista de sessões no sucesso, a mensagem no erro), o enum obriga campos nulos espalhados por todos os valores. Com `sealed class`, `Carregando`, `Vazio`, `SucessoEstado` e `ErroEstado` carregam cada um os seus próprios dados e o `switch` continua exaustivo.
8. O `_` casa com qualquer caso futuro. Quando você acrescenta uma subclasse selada nova, o compilador deveria apontar **todos** os `switch` incompletos — com `_` presente eles continuam compilando e o caso novo cai silenciosamente no ramo genérico, virando bug em tempo de execução.
9. `ignore_for_file` desliga a regra no **arquivo inteiro**, inclusive para o código que você ainda vai escrever ali, e o problema real continua. O certo é corrigir o código; se a regra não faz sentido para o projeto, desligue-a no `analysis_options.yaml`, com justificativa. Quando não houver saída, use `// ignore:` na linha específica e escreva o motivo.
10. `Future` entrega **um** valor (ou um erro) e acaba; `Stream` entrega **vários** ao longo do tempo, mais erros e um *done*, e exige cancelar a `StreamSubscription`. No Foco: salvar uma meta semanal ou carregar as matérias do banco é `Future`; o cronômetro da sessão de estudo ou o estado da conexão é `Stream`.

### Solução prática de referência

```dart
// bin/avaliacao04_foco.dart
import 'dart:async';
import 'dart:isolate';

class SessaoInvalidaException implements Exception {
  const SessaoInvalidaException(this.materia, this.minutos);
  final String materia;
  final int minutos;

  @override
  String toString() =>
      'SessaoInvalidaException: "$materia" com $minutos min (esperado 1..480)';
}

class SessaoEstudo {
  SessaoEstudo(this.materia, this.minutos) {
    if (materia.trim().isEmpty || minutos <= 0 || minutos > 480) {
      throw SessaoInvalidaException(materia, minutos);
    }
  }
  final String materia;
  final int minutos;
}

sealed class Resultado<S, F> {
  const Resultado();
}

final class Sucesso<S, F> extends Resultado<S, F> {
  const Sucesso(this.valor);
  final S valor;
}

final class Falha<S, F> extends Resultado<S, F> {
  const Falha(this.erro);
  final F erro;
}

// SucessoEstado, e não Sucesso, porque este arquivo já tem o Sucesso do Resultado.
sealed class EstadoTela<T> {
  const EstadoTela();
}

final class Carregando<T> extends EstadoTela<T> {
  const Carregando();
}

final class Vazio<T> extends EstadoTela<T> {
  const Vazio();
}

final class SucessoEstado<T> extends EstadoTela<T> {
  const SucessoEstado(this.dados);
  final T dados;
}

final class ErroEstado<T> extends EstadoTela<T> {
  const ErroEstado(this.mensagem);
  final String mensagem;
}

Future<List<SessaoEstudo>> _buscarNoServidor(String materia) async {
  await Future<void>.delayed(Duration(seconds: materia == 'Dart' ? 3 : 1));
  if (materia == 'Redação') return [];
  return [SessaoEstudo(materia, 50), SessaoEstudo(materia, 25)];
}

Future<Resultado<List<SessaoEstudo>, String>> carregarSessoes(
  String materia,
) async {
  try {
    final sessoes =
        await _buscarNoServidor(materia).timeout(const Duration(seconds: 2));
    return Sucesso(sessoes);
  } on TimeoutException {
    return const Falha('tempo esgotado ao buscar sessões');
  } on SessaoInvalidaException catch (e) {
    return Falha(e.toString());
  }
}

EstadoTela<List<SessaoEstudo>> paraEstado(
  Resultado<List<SessaoEstudo>, String> resultado,
) =>
    switch (resultado) {
      Sucesso(valor: final lista) when lista.isEmpty => const Vazio(),
      Sucesso(valor: final lista) => SucessoEstado(lista),
      Falha(erro: final mensagem) => ErroEstado(mensagem),
    };

String render(EstadoTela<List<SessaoEstudo>> estado) => switch (estado) {
      Carregando() => 'Carregando sessões...',
      Vazio() => 'Nenhuma sessão registrada ainda.',
      SucessoEstado(dados: final lista) => '${lista.length} sessões.',
      ErroEstado(mensagem: final m) => 'Erro: $m',
    };

({int total, double media}) resumoDe(List<int> minutos) {
  if (minutos.isEmpty) return (total: 0, media: 0);
  final total = minutos.reduce((a, b) => a + b);
  return (total: total, media: total / minutos.length);
}

Future<void> main() async {
  final relogio = Stopwatch()..start();
  print(render(const Carregando()));

  for (final materia in ['Flutter', 'Redação', 'Dart']) {
    final estado = paraEstado(await carregarSessoes(materia));
    print('[$materia] ${render(estado)}');

    if (estado case SucessoEstado(dados: final lista)) {
      final minutos = [for (final s in lista) s.minutos];
      final (:total, :media) = await Isolate.run(() => resumoDe(minutos));
      print('  total: $total min | média: ${media.toStringAsFixed(1)} min');
    }
  }

  relogio.stop();
  print('Concluído em ${relogio.elapsedMilliseconds} ms.');
}
```

Saída esperada: `Flutter` cai em `SucessoEstado` com `total: 75 min | média: 37.5 min`, `Redação` cai em `Vazio` e `Dart` estoura o `.timeout` e cai em `ErroEstado`. O avaliador deve procurar três coisas: nenhum `_` nos dois `switch` expressão (é isso que faz o compilador cobrar um caso novo), o `on TimeoutException` separado do `on SessaoInvalidaException` — do mais específico para o mais genérico, sem `catch` vazio — e o resumo saindo de `Isolate.run` como record lido por destructuring (`final (:total, :media)`), não como classe nem como lista de dois elementos. `dart analyze` precisa terminar com `No issues found!`.

---

<a id="modulo-05"></a>
## Módulo 05 — Introdução ao Flutter

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-05-introducao-ao-flutter.md).

### Questionário

1. **B** — Impeller é só o renderizador dentro da engine; ele pré-compila os shaders no build e acaba com o *shader compilation jank* do Skia.
2. **C** — `key.properties` guarda as senhas da chave de assinatura. `pubspec.lock`, `.metadata` e `analysis_options.yaml` são versionados.
3. **B** — a classe `Element` implementa `BuildContext`: o contexto é a posição viva do widget na árvore, não o widget nem o `RenderObject`.
4. **B** — `setState` roda o callback de forma síncrona, marca o `Element` como sujo e agenda um `build`; ele não redesenha na hora, não descobre o que mudou e não aceita callback `async`.
5. **B** — `sizeOf` inscreve o widget só na mudança de tamanho; `MediaQuery.of(context).size` reconstrói até quando o teclado sobe, e ler no `initState` ou guardar o `context` são erros piores.
6. **B** — inicializadores de campo e `initState` só rodam quando o `State` nasce. O hot reload preserva o estado, então é preciso `R` (hot restart).

7. `initState` roda uma vez, antes do primeiro `build`: é onde você cria controllers, `Timer`, listeners e assinaturas, e deriva o estado inicial de `widget.<campo>`. Ali o `context` existe mas ainda não pode chamar `.of(context)`, e o método não pode ser `async`. `didChangeDependencies` roda logo depois do `initState` e de novo sempre que um `InheritedWidget` muda (tema, `MediaQuery`, localização): é o primeiro lugar seguro para `Theme.of` e `MediaQuery.of`. Como pode ser chamado muitas vezes, nunca crie recurso ali sem cancelar o anterior. `super.initState()` vem primeiro; `super.dispose()` vem por último.
8. O método é executado dentro do `build` do pai, então o conteúdo dele é reconstruído sempre que o pai reconstrói, mesmo que nada tenha mudado. O widget extraído ganha `Element` próprio: pode ser `const` (e aí o Flutter pula a subárvore inteira por `identical()`), pode ter `key`, aparece nomeado no Flutter Inspector e pode ser testado isolado com `pumpWidget`. O método não consegue nada disso.
9. São correções de níveis diferentes. `if (!mounted) return;` é rede de segurança: impede o `setState() called after dispose()`, mas o `Timer` continua disparando depois que a tela fechou, gastando bateria, dados e memória — o vazamento continua lá, só sem mensagem de erro. Cancelar no `dispose` é a correção estrutural: tudo que nasce no `initState` precisa morrer no `dispose`. Em código de verdade se usa as duas.
10. O curso usa Material 3 nas duas plataformas porque adaptar tela a tela dobra o trabalho de interface, de teste e de manutenção, e porque divergências aparecem com o tempo — alguém corrige um bug num ramo e esquece o outro. "Adaptação pontual" é usar os widgets `.adaptive` que o próprio Flutter fornece, onde o custo é uma palavra e a manutenção é zero: `Switch.adaptive`, `CircularProgressIndicator.adaptive`, `showAdaptiveDialog`, `Slider.adaptive`, `Icons.adaptive.*`. Todo o resto continua Material.

### Solução prática de referência

```dart
// ─── lib/main.dart ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:foco_avaliacao/app.dart';

void main() => runApp(const FocoApp());

// ─── lib/tema/tema_app.dart ───────────────────────────────────────────────
import 'package:flutter/material.dart';

/// Nunca é instanciada: serve como espaço de nomes para os dois temas.
abstract final class TemaApp {
  static const Color _semente = Color(0xFF3F51B5);

  // `final` estático: o ThemeData é montado uma vez, não a cada build.
  static final ThemeData claro = _construir(Brightness.light);
  static final ThemeData escuro = _construir(Brightness.dark);

  /// Mesma semente nos dois temas — só o brilho muda.
  static ThemeData _construir(Brightness brilho) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _semente,
          brightness: brilho,
        ),
      );
}

// ─── lib/app.dart ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:foco_avaliacao/telas/home_tela.dart';
import 'package:foco_avaliacao/tema/tema_app.dart';

class FocoApp extends StatelessWidget {
  const FocoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      theme: TemaApp.claro,
      darkTheme: TemaApp.escuro,
      themeMode: ThemeMode.system,
      home: const HomeTela(),
    );
  }
}

// ─── lib/widgets/cartao_meta.dart ─────────────────────────────────────────
import 'package:flutter/material.dart';

/// Progresso de uma matéria dentro da meta semanal.
/// StatelessWidget puro: tudo chega pelo construtor.
class CartaoMeta extends StatelessWidget {
  const CartaoMeta({
    super.key,
    required this.nome,
    required this.minutosEstudados,
    required this.metaMinutos,
  }) : assert(metaMinutos > 0, 'A meta precisa ser maior que zero.');

  final String nome;
  final int minutosEstudados;
  final int metaMinutos;

  /// Getter, não campo: nunca fica dessincronizado.
  double get progresso => (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;

    return Card(
      color: cores.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              nome,
              style: tema.textTheme.titleMedium?.copyWith(
                color: cores.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$minutosEstudados de $metaMinutos min',
              style: tema.textTheme.bodySmall?.copyWith(
                color: cores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progresso),
          ],
        ),
      ),
    );
  }
}

// ─── lib/widgets/cronometro_sessao.dart ───────────────────────────────────
import 'dart:async';

import 'package:flutter/material.dart';

class CronometroSessao extends StatefulWidget {
  const CronometroSessao({super.key, required this.metaMinutos});

  final int metaMinutos;

  @override
  State<CronometroSessao> createState() => _CronometroSessaoState();
}

class _CronometroSessaoState extends State<CronometroSessao> {
  Timer? _relogio;
  int _segundos = 0;
  bool _salvando = false;

  @override
  void initState() {
    super.initState(); // SEMPRE primeiro
    _relogio = Timer.periodic(const Duration(seconds: 1), _aoPassarSegundo);
  }

  @override
  void dispose() {
    _relogio?.cancel(); // correção estrutural do vazamento
    super.dispose(); // SEMPRE por último
  }

  void _aoPassarSegundo(Timer _) {
    setState(() => _segundos += 1);
  }

  Future<void> _encerrar() async {
    _relogio?.cancel();
    setState(() => _salvando = true);

    await Future<void>.delayed(const Duration(seconds: 2)); // grava a sessão
    if (!mounted) return; // rede de segurança obrigatória

    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sessão de ${_segundos ~/ 60} min registrada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Duration decorrido = Duration(seconds: _segundos);
    final String minutos = decorrido.inMinutes.toString().padLeft(2, '0');
    final String resto = (decorrido.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: <Widget>[
        Text(
          '$minutos:$resto',
          style: tema.textTheme.displaySmall?.copyWith(
            color: tema.colorScheme.primary,
          ),
        ),
        Text(
          'Meta da sessão: ${widget.metaMinutos} min',
          style: tema.textTheme.bodySmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _salvando ? null : _encerrar,
          child: _salvando
              ? const CircularProgressIndicator.adaptive()
              : const Text('Encerrar sessão'),
        ),
      ],
    );
  }
}

// ─── lib/telas/home_tela.dart ─────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:foco_avaliacao/widgets/cartao_meta.dart';
import 'package:foco_avaliacao/widgets/cronometro_sessao.dart';

class HomeTela extends StatelessWidget {
  const HomeTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foco')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          CartaoMeta(nome: 'Dart', minutosEstudados: 90, metaMinutos: 120),
          SizedBox(height: 12),
          CartaoMeta(nome: 'Flutter', minutosEstudados: 140, metaMinutos: 120),
          SizedBox(height: 32),
          CronometroSessao(metaMinutos: 25),
        ],
      ),
    );
  }
}
```

Procure três coisas no código do aluno: o par `Timer.periodic` no `initState` / `_relogio?.cancel()` no `dispose`, o `if (!mounted) return;` imediatamente depois do `await` e antes de qualquer `ScaffoldMessenger.of(context)`, e a ausência total de `Colors.` dentro dos widgets — toda cor deve vir de `Theme.of(context).colorScheme`, com o par `on` correspondente. Aceite variações de layout e de nomes; não aceite `ThemeData` remontado dentro do `build`, `Scaffold.of(context).showSnackBar` nem método `Widget _algumaCoisa()` no lugar do widget extraído.

---

<a id="modulo-06"></a>
## Módulo 06 — Widgets e layouts

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-06-widgets-e-layouts.md).

### Questionário

1. **C** — `SnackBar` não é slot do `Scaffold`; quem exibe é o `ScaffoldMessenger`, e `Scaffold.of(context).showSnackBar` foi removido.
2. **B** — `ellipsis` só corta o texto se alguém definir a largura, e dentro de uma `Row` quem faz isso é o `Expanded`.
3. **A** — `Expanded` é `FlexFit.tight` (ocupa obrigatoriamente o espaço livre); `Flexible` é `FlexFit.loose` (pode ocupar menos).
4. **C** — `Expanded` dá altura finita ao `ListView` sem desligar a construção preguiçosa; `shrinkWrap: true` mede todos os itens de uma vez.
5. **B** — no Material 3 atual a superfície é `surface`/`onSurface`, e o tom mais alto é `surfaceContainerHighest`.
6. **B** — a `key` precisa ser única **e estável**: o índice muda quando um item sai e `UniqueKey()` muda a cada `build`.
7. `MediaQuery` responde "qual é o tamanho da tela"; `LayoutBuilder` responde "quanto espaço **este** widget recebeu". Dentro do `MateriaTile`, que é reutilizável e pode aparecer numa coluna estreita ao lado de um painel, use `LayoutBuilder` — `MediaQuery` mediria a tela inteira e tomaria a decisão errada.
8. A onda é pintada pelo `Material` mais próximo **acima** do `InkWell`; um `Container(color:)` entre os dois pinta por cima dessa tinta e a esconde. Corrija pintando o fundo com `Ink(decoration:)` ou `Material(color:)` e deixando o `InkWell` por dentro. Com cantos arredondados, repita o `borderRadius` no `InkWell` ou use `clipBehavior: Clip.antiAlias` no pai, senão a onda vaza quadrada.
9. As três variáveis soltas permitem combinações impossíveis (carregando com erro, sucesso com lista nula) e espalham uma cadeia de `if` por toda tela. O `sealed class` guarda **um** estado por vez, mantém `dados` dentro de `Sucesso` — você não lê uma lista que ainda não chegou — e torna o `switch` exaustivo: esquecer um caso vira erro de compilação, não tela branca em produção.
10. *Constraints descem, tamanhos sobem, o pai posiciona.* O pai entrega restrições ao `Container`; sem filho e sem `width`/`height`, ele não tem nenhum motivo para ser pequeno, então adota o **maior** tamanho permitido pelas restrições recebidas — a tela inteira. Com um filho, ele passa a ter um tamanho de referência e encolhe até ele.

### Solução prática de referência

```dart
// foco_ui/lib/features/materias/presentation/metas_screen.dart
import 'package:flutter/material.dart';

import '../domain/materia.dart';

/// Os quatro estados da tela num tipo só: combinações impossíveis não compilam.
sealed class EstadoMetas {
  const EstadoMetas();
}

final class Carregando extends EstadoMetas {
  const Carregando();
}

final class Vazio extends EstadoMetas {
  const Vazio();
}

final class Sucesso extends EstadoMetas {
  const Sucesso(this.materias);
  final List<Materia> materias;
}

final class Falha extends EstadoMetas {
  const Falha(this.mensagem);
  final String mensagem;
}

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  EstadoMetas _estado = const Carregando();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _estado = const Carregando());
    try {
      final List<Materia> lista = await _buscarFalso();
      if (!mounted) return; // sempre depois de um await
      setState(() => _estado = lista.isEmpty ? const Vazio() : Sucesso(lista));
    } on Exception catch (erro) {
      debugPrint('Falha ao carregar metas: $erro'); // log para você
      if (!mounted) return;
      setState(() {
        // Texto de gente para o usuário, nunca a exceção crua.
        _estado = const Falha('Não foi possível carregar suas metas agora.');
      });
    }
  }

  Future<List<Materia>> _buscarFalso() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const <Materia>[
      Materia(id: 'm1', nome: 'Cálculo I', minutosEstudados: 90, metaMinutos: 180),
      Materia(id: 'm2', nome: 'Algoritmos', minutosEstudados: 200, metaMinutos: 200),
      Materia(id: 'm3', nome: 'Inglês técnico', minutosEstudados: 30, metaMinutos: 120),
    ];
  }

  List<Materia> get _listaAtual {
    final EstadoMetas atual = _estado;
    return atual is Sucesso ? List<Materia>.of(atual.materias) : <Materia>[];
  }

  void _adicionar() {
    final List<Materia> lista = _listaAtual
      ..add(
        Materia(
          id: 'm${DateTime.now().microsecondsSinceEpoch}',
          nome: 'Nova matéria',
          minutosEstudados: 0,
          metaMinutos: 120,
        ),
      );
    setState(() => _estado = Sucesso(lista));
  }

  void _remover(Materia materia, int indice) {
    // O Dismissible só anima: quem tira o item da fonte de dados é você.
    final List<Materia> restantes = _listaAtual..removeAt(indice);
    setState(() => _estado = restantes.isEmpty ? const Vazio() : Sucesso(restantes));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // evita empilhar SnackBars
      ..showSnackBar(
        SnackBar(
          content: Text('${materia.nome} removida'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _desfazer(materia, indice),
          ),
        ),
      );
  }

  void _desfazer(Materia materia, int indice) {
    final List<Materia> lista = _listaAtual;
    final int posicao = indice <= lista.length ? indice : lista.length;
    lista.insert(posicao, materia);
    setState(() => _estado = Sucesso(lista));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas da semana'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Recarregar', // acessibilidade, não enfeite
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // A AppBar já protegeu o topo: repetir aqui duplicaria o padding.
      body: SafeArea(
        top: false,
        child: switch (_estado) {
          Carregando() => const Center(child: CircularProgressIndicator.adaptive()),
          Falha(mensagem: final String m) => _EstadoErro(mensagem: m, onTentarDeNovo: _carregar),
          Vazio() => _EstadoVazio(onAdicionar: _adicionar),
          Sucesso(materias: final List<Materia> lista) =>
            _Conteudo(materias: lista, onRemover: _remover),
        },
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.materias, required this.onRemover});

  final List<Materia> materias;
  final void Function(Materia materia, int indice) onRemover;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${materias.length} matérias nesta semana',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Expanded dá altura FINITA à lista. É a correção do
        // "Vertical viewport was given unbounded height" sem perder o builder.
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints restricoes) {
              return restricoes.maxWidth >= 600 ? _grade(context) : _lista(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _lista(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: materias.length, // sem itemCount a lista é infinita
      separatorBuilder: (BuildContext context, int i) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int i) {
        final Materia materia = materias[i];
        return Dismissible(
          key: ValueKey<String>(materia.id), // o id, nunca o índice
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: cores.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.delete_outline, color: cores.onErrorContainer),
          ),
          onDismissed: (DismissDirection _) => onRemover(materia, i),
          child: _MateriaCartao(materia: materia),
        );
      },
    );
  }

  Widget _grade(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 104, // altura fixa evita overflow dentro da célula
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: materias.length,
      itemBuilder: (BuildContext context, int i) => _MateriaCartao(materia: materias[i]),
    );
  }
}

class _MateriaCartao extends StatelessWidget {
  const _MateriaCartao({required this.materia});

  final Materia materia;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme tipografia = Theme.of(context).textTheme;
    final BorderRadius raio = BorderRadius.circular(16);

    // Ink pinta o fundo SEM cobrir a onda; Container(color:) cobriria.
    return Ink(
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        borderRadius: raio,
        border: Border.all(color: cores.outlineVariant),
      ),
      child: InkWell(
        borderRadius: raio, // a onda respeita o mesmo raio do fundo
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abrir ${materia.nome}')),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Container(
                width: 48, // alvo de toque mínimo do Material
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cores.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book_outlined, color: cores.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      materia.nome,
                      style: tipografia.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${materia.minutosEstudados} de ${materia.metaMinutos} min',
                      style: tipografia.bodySmall?.copyWith(color: cores.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: materia.progresso),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({required this.onAdicionar});

  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme tipografia = Theme.of(context).textTheme;

    // ListView, e não Column: não estoura em tela baixa nem com fonte aumentada.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: <Widget>[
        Icon(Icons.add_circle_outline, size: 64, color: cores.outline),
        const SizedBox(height: 24),
        Text(
          'Nenhuma matéria por aqui',
          textAlign: TextAlign.center,
          style: tipografia.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Crie a sua primeira matéria para começar a semana.',
          textAlign: TextAlign.center,
          style: tipografia.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.tonal(
            onPressed: onAdicionar,
            child: const Text('Adicionar matéria'),
          ),
        ),
      ],
    );
  }
}

class _EstadoErro extends StatelessWidget {
  const _EstadoErro({required this.mensagem, required this.onTentarDeNovo});

  final String mensagem;
  final VoidCallback onTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme tipografia = Theme.of(context).textTheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: <Widget>[
        Icon(Icons.cloud_off_outlined, size: 64, color: cores.error),
        const SizedBox(height: 24),
        Text('Algo deu errado', textAlign: TextAlign.center, style: tipografia.titleLarge),
        const SizedBox(height: 8),
        Text(
          mensagem,
          textAlign: TextAlign.center,
          style: tipografia.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: onTentarDeNovo,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar de novo'),
          ),
        ),
      ],
    );
  }
}
```

No código do aluno, procure primeiro pelo `switch` sobre o `sealed class`: se ele ainda usa `bool` + `String?`, os 2 pontos do estado não saem, mesmo que a tela funcione. Depois confirme os três detalhes que separam quem entendeu de quem copiou — `Expanded` em volta do `ListView` (e não `shrinkWrap: true`), `Ink`/`Material` pintando o fundo abaixo do `InkWell`, e `ValueKey` com o `id` no `Dismissible` acompanhada da remoção real da lista. Cor hexadecimal solta fora de `tema_app.dart` custa o ponto do último critério.

---

<a id="modulo-07"></a>
## Módulo 07 — Navegação e formulários

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-07-navegacao-e-formularios.md).

### Questionário

1. **B** — `maybePop` volta só se houver rota abaixo e respeita o `PopScope`; `pop` na base deixa a tela preta.
2. **B** — sem `settings:` a rota perde nome e argumentos; é um bug silencioso, nada quebra na hora.
3. **C** — o tipo genérico da rota precisa bater com o do `pushNamed`; quando não bate, o valor se perde sem aviso.
4. **B** — o `switch` destrói o widget da aba; só o `IndexedStack` mantém todas montadas e preserva o estado.
5. **B** — o *predictive back* precisa da resposta antes do fim do gesto, e uma função `async` responderia tarde demais.
6. **B** — `keyboardType` só sugere o teclado; teclado físico, colar texto ou teclado de terceiros passam letras.
7. O `arguments` chega como `Object?` e o Flutter não valida nada. O cast cego (`as`) quebra o app em produção assim que alguém chamar a rota sem argumento (`type 'Null' is not a subtype of...`). Com `is!` + `return`, o caso errado cai na tela de rota desconhecida **e** o Dart faz promoção de tipo: no resto do `case`, `args` já é do tipo certo, sem `!` e sem cast.
8. `labelText` diz **o que é** o campo, flutua para cima ao focar, nunca some e é sempre anunciado por leitores de tela. `hintText` é apenas um **exemplo** de preenchimento e desaparece na primeira tecla. Usar só `hintText` faz o usuário esquecer o que o campo pedia e pode não ser lido pelo VoiceOver — por isso todo campo precisa de `labelText`.
9. Começa em `AutovalidateMode.disabled`; na primeira falha de `validate()` muda para `onUserInteraction` com `setState`. Assim o formulário abre limpo, todos os erros aparecem juntos na primeira tentativa de envio e cada erro some sozinho enquanto o usuário corrige. Validar a cada tecla acusa erro antes de a pessoa terminar de digitar ("C" já lê "use pelo menos 2 letras"), e `always` abre a tela toda vermelha.
10. Esse `await` dura o tempo que o usuário quiser — minutos, se ele deixar o formulário aberto. Nesse intervalo o widget pode ter saído da árvore, e usar `context` (ou `setState`) depois disso lança `Looking up a deactivated widget's ancestor is unsafe`. O `flutter analyze` sinaliza com `use_build_context_synchronously`.

### Solução prática de referência

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const AppFoco());

class AppFoco extends StatelessWidget {
  const AppFoco({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Foco',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        initialRoute: Rotas.home,
        onGenerateRoute: Rotas.gerar,
        onUnknownRoute: Rotas.desconhecida,
      );
}

// ---------------- domínio ----------------

class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.metaMinutos,
  });

  final String id;
  final String nome;
  final int metaMinutos;
}

// ---------------- rotas ----------------

abstract final class Rotas {
  static const String home = '/';
  static const String materiaForm = '/materia/form';

  static Route<dynamic> gerar(RouteSettings configuracoes) {
    switch (configuracoes.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => const ListaMateriasScreen(),
        );

      case materiaForm:
        final Object? args = configuracoes.arguments;
        // Valida ANTES de usar: nada de `as MateriaFormArgs`.
        if (args is! MateriaFormArgs) return desconhecida(configuracoes);
        // O <Materia> precisa bater com o pushNamed<Materia> de quem chama.
        return MaterialPageRoute<Materia>(
          settings: configuracoes,
          fullscreenDialog: true,
          builder: (_) => MateriaFormScreen(args: args),
        );

      default:
        return desconhecida(configuracoes);
    }
  }

  static Route<dynamic> desconhecida(RouteSettings configuracoes) =>
      MaterialPageRoute<void>(
        settings: configuracoes,
        builder: (_) => RotaDesconhecidaScreen(nome: configuracoes.name),
      );
}

class RotaDesconhecidaScreen extends StatelessWidget {
  const RotaDesconhecidaScreen({required this.nome, super.key});

  final String? nome;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tela não encontrada')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('A rota "$nome" não existe.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(Rotas.home, (_) => false),
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      );
}

// ---------------- lista ----------------

class ListaMateriasScreen extends StatefulWidget {
  const ListaMateriasScreen({super.key});

  @override
  State<ListaMateriasScreen> createState() => _ListaMateriasScreenState();
}

class _ListaMateriasScreenState extends State<ListaMateriasScreen> {
  final List<Materia> _materias = <Materia>[
    const Materia(id: '1', nome: 'Dart', metaMinutos: 45),
  ];

  Future<void> _abrirFormulario({Materia? original}) async {
    final Materia? salva = await Navigator.of(context).pushNamed<Materia>(
      Rotas.materiaForm,
      arguments: original == null
          ? const MateriaFormArgs.criar()
          : MateriaFormArgs.editar(original),
    );

    // O formulário pode ter ficado aberto por minutos.
    if (!context.mounted) return;
    // null = o usuário voltou sem salvar. Não é erro; é o caso mais comum.
    if (salva == null) return;

    setState(() {
      final int i = _materias.indexWhere((Materia m) => m.id == salva.id);
      if (i == -1) {
        _materias.add(salva);
      } else {
        _materias[i] = salva;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${salva.nome}" salva')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Matérias')),
        body: ListView.separated(
          itemCount: _materias.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int i) {
            final Materia m = _materias[i];
            return ListTile(
              title: Text(m.nome),
              subtitle: Text('Meta: ${m.metaMinutos} min/dia'),
              onTap: () => _abrirFormulario(original: m),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _abrirFormulario,
          child: const Icon(Icons.add),
        ),
      );
}

// ---------------- formulário ----------------

/// Convenção do curso: a classe de argumentos mora no arquivo da tela
/// que a recebe, com o sufixo Args.
class MateriaFormArgs {
  const MateriaFormArgs.criar() : original = null;
  const MateriaFormArgs.editar(Materia materia) : original = materia;

  final Materia? original;
}

class MateriaFormScreen extends StatefulWidget {
  const MateriaFormScreen({required this.args, super.key});

  final MateriaFormArgs args;

  @override
  State<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends State<MateriaFormScreen> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();

  late final String _nomeOriginal = widget.args.original?.nome ?? '';
  late final String _metaOriginal =
      widget.args.original?.metaMinutos.toString() ?? '';

  late final TextEditingController _nome =
      TextEditingController(text: _nomeOriginal);
  late final TextEditingController _meta =
      TextEditingController(text: _metaOriginal);
  final FocusNode _focoMeta = FocusNode();

  AutovalidateMode _modo = AutovalidateMode.disabled;
  bool _enviando = false;

  // Getter, não `late final`: precisa ser recalculado a cada tecla.
  bool get _sujo => _nome.text != _nomeOriginal || _meta.text != _metaOriginal;

  @override
  void dispose() {
    _nome.dispose();
    _meta.dispose();
    _focoMeta.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();

    if (!_chave.currentState!.validate()) {
      // Na primeira falha, liga a autovalidação: o erro some enquanto corrige.
      setState(() => _modo = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _enviando = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!context.mounted) return;

    final Materia salva = Materia(
      id: widget.args.original?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      nome: _nome.text.trim(),
      metaMinutos: int.parse(_meta.text.trim()),
    );

    // Devolve o OBJETO salvo, não `true`: a lista se atualiza sem recarregar.
    Navigator.of(context).pop(salva);
  }

  Future<bool> _confirmarDescarte() async {
    final bool? descartar = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você preencheu será perdido.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return descartar ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bool editando = widget.args.original != null;

    return PopScope<Materia>(
      canPop: !_sujo && !_enviando,
      onPopInvokedWithResult: (bool saiu, Materia? resultado) async {
        if (saiu) return;
        final bool descartar = await _confirmarDescarte();
        if (descartar && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editando ? 'Editar matéria' : 'Nova matéria'),
        ),
        body: GestureDetector(
          // Tocar fora fecha o teclado — obrigatório com campo numérico no iOS.
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _chave,
            autovalidateMode: _modo,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                TextFormField(
                  controller: _nome,
                  decoration: const InputDecoration(
                    labelText: 'Nome da matéria',
                    hintText: 'Ex.: Cálculo I',
                    helperText: 'Como aparecerá na lista',
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}), // mantém `canPop` atual
                  onFieldSubmitted: (_) => _focoMeta.requestFocus(),
                  validator: (String? v) {
                    final String texto = (v ?? '').trim();
                    if (texto.isEmpty) return 'Informe o nome da matéria';
                    if (texto.length < 2) return 'Use pelo menos 2 letras';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _meta,
                  focusNode: _focoMeta,
                  decoration: const InputDecoration(
                    labelText: 'Meta diária',
                    hintText: 'Ex.: 45',
                    helperText: 'Quantos minutos por dia você quer estudar',
                    suffixText: 'min',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _salvar(),
                  validator: (String? v) {
                    final int? n = int.tryParse((v ?? '').trim());
                    if (n == null) return 'Informe a meta em minutos';
                    if (n < 5 || n > 480) {
                      return 'Informe um valor entre 5 e 480 minutos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _enviando ? null : _salvar,
                  child: _enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

O avaliador deve procurar quatro coisas antes de qualquer outra: `settings: configuracoes` presente em **todas** as rotas, `is!` no lugar de `as` na leitura dos argumentos, o `<Materia>` do `MaterialPageRoute` casando com o do `pushNamed` (sem isso o `pop(salva)` some em silêncio) e um `dispose()` para cada `TextEditingController` e cada `FocusNode`. Aceite variações no visual e no texto das mensagens, desde que a mensagem diga o que fazer ("use pelo menos 2 letras") em vez de acusar ("campo inválido"); rejeite `WillPopScope`, `onPopInvoked`, `canPop: false` sem caminho de saída e `_sujo` calculado como `late final`.

---

<a id="modulo-08"></a>
## Módulo 08 — Estado e arquitetura

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-08-estado-e-arquitetura.md).

### Questionário

1. **C** — estado de um único widget é estado local; Riverpod aqui só acrescenta cerimônia.
2. **B** — a rota empilhada é filha do `Navigator` do `MaterialApp`, não descendente da aba.
3. **D** — `true` fixo compila e notifica todo dependente a cada `build`, mesmo sem mudança real.
4. **A** — a lista muda no lugar, a referência continua a mesma e o Riverpod conclui que nada mudou.
5. **B** — `read` não cria inscrição: o valor congela no primeiro `build` e nenhum erro é lançado.
6. **C** — `requireValue` lança `Bad state` quando o `AsyncValue` ainda não tem dados.

7. `ref.watch` inscreve o widget e o reconstrói quando o valor muda; `ref.listen` não reconstrói nada, apenas executa um efeito colateral na mudança. No Foco: `ref.watch(minutosHojeProvider)` para exibir os minutos no cartão de progresso; `ref.listen(metaAtingidaProvider, ...)` para mostrar o `SnackBar` de meta batida, agindo só na transição `false → true`.
8. O Riverpod identifica a instância da family pelo parâmetro usando `==`. Sem `==` e `hashCode`, dois objetos com o mesmo conteúdo são considerados diferentes, então cada `build` cria um provider novo — e nenhum dos anteriores é liberado. Não há erro nem aviso: a memória só cresce. Use `String`, `int`, `enum`, um *record* ou implemente `==`/`hashCode`.
9. Todas as setas apontam para o centro: `presentation` depende de `domain`; `data` depende de `domain`; `domain` não depende de ninguém. `data` nunca importa `presentation`, e `presentation` não conhece os detalhes de `data` (SQL, HTTP). O teste mais rápido é abrir um arquivo de `domain/` e olhar os `import`: se houver `package:flutter/...`, `package:http/...` ou `package:sqflite/...`, a regra foi quebrada.
10. Tipar como `Provider<SessaoRepositorio>` — o contrato — é o que permite `overrideWithValue` entregar outra implementação no teste; com o tipo concreto você só poderia trocar por outra instância da mesma classe. `addTearDown(container.dispose)` descarta os providers ao fim de cada teste: sem isso, o estado de um teste sobrevive e contamina o seguinte.

### Solução prática de referência

```dart
// lib/features/sessoes/domain/sessao.dart — Dart puro, NENHUM import.
class Sessao {
  const Sessao({required this.id, required this.materia, required this.minutos});

  final String id;
  final String materia;
  final int minutos;

  /// Regra de negócio, não de tela.
  bool get valida => materia.trim().isNotEmpty && minutos > 0 && minutos < 480;

  Sessao copyWith({String? id, String? materia, int? minutos}) => Sessao(
        id: id ?? this.id,
        materia: materia ?? this.materia,
        minutos: minutos ?? this.minutos,
      );

  @override
  bool operator ==(Object outro) =>
      outro is Sessao &&
      outro.id == id &&
      outro.materia == materia &&
      outro.minutos == minutos;

  @override
  int get hashCode => Object.hash(id, materia, minutos);
}

// lib/features/sessoes/domain/sessao_repositorio.dart
import 'sessao.dart';

abstract interface class SessaoRepositorio {
  Future<List<Sessao>> listar();
  Future<void> registrar(Sessao sessao);
}

class FalhaSessao implements Exception {
  const FalhaSessao(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

// lib/features/sessoes/data/sessao_repositorio_memoria.dart
import '../domain/sessao.dart';
import '../domain/sessao_repositorio.dart';

class SessaoRepositorioMemoria implements SessaoRepositorio {
  SessaoRepositorioMemoria([List<Sessao>? iniciais])
      : _sessoes = <Sessao>[...?iniciais];

  final List<Sessao> _sessoes;

  /// Controle do teste: quando true, toda chamada falha.
  bool falharSempre = false;

  /// Registro para o teste verificar o que aconteceu.
  int chamadasDeListar = 0;

  @override
  Future<List<Sessao>> listar() async {
    chamadasDeListar++;
    if (falharSempre) throw const FalhaSessao('Falha ao ler as sessões');
    return List<Sessao>.unmodifiable(_sessoes);
  }

  @override
  Future<void> registrar(Sessao sessao) async {
    if (falharSempre) throw const FalhaSessao('Falha ao registrar a sessão');
    _sessoes.add(sessao);
  }
}

// lib/features/sessoes/presentation/sessoes_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sessao_repositorio_memoria.dart';
import '../domain/sessao.dart';
import '../domain/sessao_repositorio.dart';

// Tipado com o CONTRATO: é isso que permite o override no teste.
final Provider<SessaoRepositorio> sessaoRepositorioProvider =
    Provider<SessaoRepositorio>((Ref ref) => SessaoRepositorioMemoria());

final AsyncNotifierProvider<SessoesController, List<Sessao>> sessoesProvider =
    AsyncNotifierProvider<SessoesController, List<Sessao>>(SessoesController.new);

class SessoesController extends AsyncNotifier<List<Sessao>> {
  SessaoRepositorio get _repo => ref.read(sessaoRepositorioProvider);

  @override
  Future<List<Sessao>> build() => ref.watch(sessaoRepositorioProvider).listar();

  Future<void> registrar(Sessao nova) async {
    if (!nova.valida) return; // regra no notifier, não na tela
    state = const AsyncLoading<List<Sessao>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _repo.registrar(nova);
      return _repo.listar();
    });
  }

  Future<void> recarregar() async {
    state = const AsyncLoading<List<Sessao>>().copyWithPrevious(state);
    state = await AsyncValue.guard(_repo.listar);
  }
}

// A assincronia se propaga: o derivado devolve AsyncValue, não desembrulha.
final Provider<AsyncValue<int>> minutosTotaisProvider =
    Provider<AsyncValue<int>>((Ref ref) {
  return ref.watch(sessoesProvider).whenData(
        (List<Sessao> lista) =>
            lista.fold<int>(0, (int soma, Sessao s) => soma + s.minutos),
      );
});

// test/sessoes_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foco/features/sessoes/data/sessao_repositorio_memoria.dart';
import 'package:foco/features/sessoes/domain/sessao.dart';
import 'package:foco/features/sessoes/presentation/sessoes_controller.dart';

ProviderContainer _criarContainer(SessaoRepositorioMemoria repo) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[sessaoRepositorioProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  const Sessao dart25 = Sessao(id: 's1', materia: 'Dart', minutos: 25);

  test('carrega as sessões do repositório injetado', () async {
    final ProviderContainer container =
        _criarContainer(SessaoRepositorioMemoria(<Sessao>[dart25]));

    final List<Sessao> lista = await container.read(sessoesProvider.future);

    expect(lista, <Sessao>[dart25]);
  });

  test('registrar acrescenta e recalcula o total', () async {
    final SessaoRepositorioMemoria repo =
        SessaoRepositorioMemoria(<Sessao>[dart25]);
    final ProviderContainer container = _criarContainer(repo);
    await container.read(sessoesProvider.future);

    await container
        .read(sessoesProvider.notifier)
        .registrar(const Sessao(id: 's2', materia: 'Flutter', minutos: 50));

    expect(container.read(sessoesProvider).value, hasLength(2));
    expect(container.read(minutosTotaisProvider).value, 75);
  });

  test('sessão inválida é recusada pelo notifier', () async {
    final ProviderContainer container =
        _criarContainer(SessaoRepositorioMemoria(<Sessao>[dart25]));
    await container.read(sessoesProvider.future);

    await container
        .read(sessoesProvider.notifier)
        .registrar(const Sessao(id: 's3', materia: '  ', minutos: 0));

    expect(container.read(sessoesProvider).value, hasLength(1));
  });

  test('falha na recarga vira AsyncError sem apagar os dados', () async {
    final SessaoRepositorioMemoria repo =
        SessaoRepositorioMemoria(<Sessao>[dart25]);
    final ProviderContainer container = _criarContainer(repo);
    await container.read(sessoesProvider.future);

    repo.falharSempre = true;
    await container.read(sessoesProvider.notifier).recarregar();

    final AsyncValue<List<Sessao>> estado = container.read(sessoesProvider);
    expect(estado.hasError, isTrue);
    expect(estado.value, <Sessao>[dart25]); // dados antigos preservados
  });
}
```

O avaliador deve procurar, antes de tudo, os `import` do `domain/`: qualquer `package:flutter/...` ali derruba os 2 pontos do primeiro critério, mesmo que o resto funcione. Depois, confira se o provider do repositório está tipado com o contrato (sem isso o `overrideWithValue` do teste não compila), se toda escrita em `state` cria valor novo em vez de mutar a lista, e se a recarga usa `copyWithPrevious` — troque-o por um `AsyncLoading` puro e o último teste deve falhar; é essa a prova de que o aluno entendeu o ponto.

---

<a id="modulo-09"></a>
## Módulo 09 — Consumo de API

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-09-consumo-de-api.md).

### Questionário

1. **B** — `num` é a superclasse de `int` e `double`; a API pode mandar `4` hoje e `4.0` amanhã, e o cast direto `as double` quebra no primeiro caso.
2. **C** — `204 No Content` não tem corpo; `jsonDecode` numa string vazia lança `FormatException: Unexpected end of input`. Confira o status **antes** de decodificar.
3. **D** — `POST` não é idempotente: se a requisição chegou e só a resposta se perdeu, a repetição cria um segundo registro. `repetir` só envolve `GET`, `PUT` e `DELETE`.
4. **B** — o `default:` destrói a exaustividade que motivou o `sealed`: uma `Falha` nova passa a ser engolida em silêncio em vez de virar erro de análise.
5. **C** — `403` é falha de **autorização**: o token está perfeitamente válido, falta permissão. Renovar não resolve e vira loop. Quem pede login de novo é o `401`.
6. **B** — traduzir exceção técnica em `Falha` de domínio é a segunda responsabilidade do repositório. O service só fala HTTP e lança `ApiException`; o controller e a tela já recebem `Falha`.

7. O `TrilhaApi` (service) monta a URL, envia cabeçalhos, aplica `.timeout`, confere o `statusCode` e decodifica o JSON em DTO — e nunca conhece o modelo de domínio nem a classe `Falha`. O `TrilhaRepositorio` implementa o contrato do `domain`, converte DTO em modelo de domínio e traduz `ApiException`, `SocketException`, `TimeoutException` e `FormatException` em `Falha` — e nunca monta URL, nunca checa status, nunca chama `jsonDecode`.
8. O Flutter injeta `android.permission.INTERNET` automaticamente **só no manifesto de debug**, porque hot reload e depurador conversam pela rede. O app funciona no emulador, você gera o APK de release, instala no celular e toda requisição falha com `SocketException: Operation not permitted`. A correção é declarar `<uses-permission android:name="android.permission.INTERNET"/>` no manifesto principal, como filho direto de `<manifest>` e antes de `<application>`.
9. `ref.invalidate` **apaga** o estado: a tela volta a `AsyncLoading` sem dados, a lista some e o usuário perde a rolagem — justamente durante um gesto em que ele está olhando a lista. Um método do controller que faz `state = const AsyncLoading().copyWithPrevious(state)` recarrega mantendo os dados antigos visíveis. O `invalidate` fica reservado para o botão "Tentar de novo", onde não há dados mesmo; se for usado no `RefreshIndicator`, precisa de `await ref.read(provider.future)` depois, senão o indicador some antes de a carga terminar.
10. Nunca em `SharedPreferences` (XML/`.plist` em texto puro), nem no código-fonte (vai para o Git), nem na URL (`?token=...` aparece no histórico, nos logs do servidor e do proxy e no `Referer`), nem em log com `debugPrint`. O lugar certo é o `flutter_secure_storage`: **Keystore** no Android 🤖 e **Keychain** no iOS 🍎. A URL base vai por `--dart-define`, não escrita no código.

### Solução prática de referência

```dart
// ─────────────────────────────────────────────────────────────────────────────
// foco_api/lib/features/metas/domain/meta.dart
// ─────────────────────────────────────────────────────────────────────────────
class Meta {
  const Meta({
    required this.id,
    required this.titulo,
    required this.descricao,
  });

  final String id;
  final String titulo;
  final String descricao;
}

// ─────────────────────────────────────────────────────────────────────────────
// foco_api/lib/features/metas/domain/meta_repositorio_contrato.dart
// Nenhum import de http, de Flutter ou de data.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:foco_api/features/metas/domain/meta.dart';

/// Lança [Falha] — nunca ApiException, nunca SocketException.
abstract interface class MetaRepositorioContrato {
  Future<List<Meta>> listar();
}

// ─────────────────────────────────────────────────────────────────────────────
// foco_api/lib/features/metas/data/meta_dto.dart
// ─────────────────────────────────────────────────────────────────────────────
/// Espelha EXATAMENTE o que a API devolve. Nomes em inglês.
class MetaDto {
  const MetaDto({required this.id, required this.title, required this.body});

  factory MetaDto.fromJson(Map<String, Object?> json) {
    final Object? id = json['id'];
    final Object? title = json['title'];

    // Campo obrigatório ausente ou com tipo errado: falha explícita,
    // dizendo QUAL campo quebrou.
    if (id is! int) {
      throw FormatException('Campo "id" ausente ou não é número: $id');
    }
    if (title is! String) {
      throw FormatException('Campo "title" ausente ou não é texto: $title');
    }

    return MetaDto(
      id: id,
      // Campo opcional: valor padrão em vez de exceção.
      body: json['body'] is String ? json['body']! as String : '',
      title: title,
    );
  }

  final int id;
  final String title;
  final String body;
}

// ─────────────────────────────────────────────────────────────────────────────
// foco_api/lib/features/metas/data/meta_api.dart  — o service
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:foco_api/core/erros/api_exception.dart';
import 'package:foco_api/core/http/cliente_http.dart'; // Prazos
import 'package:foco_api/core/http/repetir.dart';
import 'package:foco_api/features/metas/data/meta_dto.dart';

class MetaApi {
  /// O cliente vem de FORA. É isso que torna a camada testável sem rede.
  MetaApi({
    required http.Client cliente,
    required String base,
    this.tentativas = 3,
  })  : _cliente = cliente,
        _base = base;

  final http.Client _cliente;
  final String _base;
  final int tentativas;

  static const Map<String, String> _semCorpo = <String, String>{
    'Accept': 'application/json',
  };

  /// GET é idempotente: pode entrar no retry com backoff.
  Future<List<MetaDto>> listar() {
    return repetir<List<MetaDto>>(
      () async {
        final Uri url = Uri.parse('$_base/posts?_limit=5');

        final http.Response r = await _cliente
            .get(url, headers: _semCorpo)
            .timeout(Prazos.leitura);

        // Faixa 2xx inteira, não `== 200`. E ANTES do jsonDecode:
        // um 404 costuma devolver HTML, e o FormatException sairia confuso.
        if (r.statusCode < 200 || r.statusCode >= 300) {
          throw ApiException(
            mensagem: 'GET /posts?_limit=5 falhou',
            statusCode: r.statusCode,
            uri: url,
            corpo: r.body,
          );
        }

        final List<Object?> bruto = jsonDecode(r.body) as List<Object?>;
        return bruto
            .map((Object? e) => MetaDto.fromJson(e! as Map<String, Object?>))
            .toList();
      },
      maximoDeTentativas: tentativas,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// foco_api/lib/features/metas/data/meta_repositorio.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart';

import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/features/metas/data/meta_api.dart';
import 'package:foco_api/features/metas/data/meta_dto.dart';
import 'package:foco_api/features/metas/domain/meta.dart';
import 'package:foco_api/features/metas/domain/meta_repositorio_contrato.dart';

/// Duas responsabilidades, e só duas:
/// 1. DTO → modelo de domínio.
/// 2. Exceção técnica → Falha de domínio.
class MetaRepositorio implements MetaRepositorioContrato {
  const MetaRepositorio(this._api);

  final MetaApi _api;

  @override
  Future<List<Meta>> listar() async {
    try {
      final List<MetaDto> dtos = await _api.listar();
      return dtos.map(_paraDominio).toList();
    } on Falha {
      rethrow;
    } catch (erro, pilha) {
      // O rastro fica no log de desenvolvimento e some no release.
      debugPrint('MetaRepositorio.listar falhou: $erro');
      debugPrintStack(stackTrace: pilha);
      throw converterParaFalha(erro);
    }
  }

  /// A conversão de tipo fica em UM lugar: int (API) → String (domínio).
  Meta _paraDominio(MetaDto dto) => Meta(
        id: '${dto.id}',
        titulo: dto.title,
        descricao: dto.body,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// foco_api/test/metas/meta_repositorio_test.dart
// Roda com `flutter test` no Windows, sem emulador e sem rede.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:foco_api/core/erros/falhas.dart';
import 'package:foco_api/features/metas/data/meta_api.dart';
import 'package:foco_api/features/metas/data/meta_repositorio.dart';
import 'package:foco_api/features/metas/domain/meta.dart';

class ClienteFalso extends Mock implements http.Client {}

void main() {
  const String base = 'https://jsonplaceholder.typicode.com';

  late ClienteFalso cliente;
  late MetaRepositorio repositorio;

  setUpAll(() => registerFallbackValue(Uri.parse(base)));

  setUp(() {
    cliente = ClienteFalso();
    // tentativas: 1 — sem isso, o teste de 500 espera o backoff de verdade.
    repositorio = MetaRepositorio(
      MetaApi(cliente: cliente, base: base, tentativas: 1),
    );
  });

  void responderCom(String corpo, int status) {
    when(() => cliente.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(corpo, status));
  }

  test('200 devolve metas já no modelo de domínio', () async {
    responderCom(
      '[{"id":1,"title":"Álgebra","body":"4h por semana"}]',
      200,
    );

    final List<Meta> metas = await repositorio.listar();

    expect(metas, hasLength(1));
    expect(metas.single.id, '1'); // int virou String no domínio
    expect(metas.single.titulo, 'Álgebra');
    expect(metas.single.descricao, '4h por semana');
  });

  test('500 sai do repositório como FalhaServidor', () async {
    responderCom('{"erro":"boom"}', 500);

    await expectLater(repositorio.listar(), throwsA(isA<FalhaServidor>()));
  });

  test('JSON inválido sai como FalhaFormato', () async {
    // O que um proxy quebrado devolve de verdade: HTML com status 200.
    responderCom('<html><body>502 Bad Gateway</body></html>', 200);

    await expectLater(repositorio.listar(), throwsA(isA<FalhaFormato>()));
  });
}
```

O avaliador deve procurar três coisas no código do aluno: o `http.Client` chegando pelo construtor (se o service faz `http.Client()` por dentro, os testes só passariam com rede de verdade — critério perdido), o `.timeout` e a checagem da faixa `2xx` **antes** do `jsonDecode`, e o `catch` do repositório devolvendo `Falha` em vez de deixar `ApiException` ou `SocketException` vazarem para cima. Se algum `expect` do teste espera `ApiException` em vez de `Falha`, a tradução de erro está no lugar errado — provavelmente no service.

---

<a id="modulo-10"></a>
## Módulo 10 — Persistência de dados

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-10-persistencia-de-dados.md).

### Questionário

1. **B** — lista que cresce, com filtro e ordenação, é trabalho de banco; a pergunta 2 da árvore de decisão para aqui.
2. **B** — `name` é estável; `index` muda no dia em que você inserir um valor no meio do `enum`.
3. **B** — conteúdo criado pelo usuário vai em documentos; temporário pode ser apagado pelo sistema sem aviso.
4. **B** — `onConfigure` roda em toda abertura; no `onCreate` o `PRAGMA` só valeria na primeira instalação, e dentro de `transaction` ele é ignorado.
5. **B** — `replace` apaga e reinsere; com `ON DELETE CASCADE`, as sessões da matéria somem sem erro nenhum.
6. **B** — migração em etapas, sem `else`: quem está na v1 precisa executar todos os blocos, em ordem.

7. O SQLite compara **códigos de caractere**: em UTF-8, `Á` (U+00C1) vem depois de todas as letras ASCII, então acentuadas caem no fim da lista. `COLLATE NOCASE` não resolve, porque ele só conhece ASCII. A correção do curso é a coluna `nome_ordenacao`, derivada dentro de `Materia.paraLinha()` com `Texto.paraOrdenacao(nome)` (minúsculo e sem acento), indexada e usada em `orderBy: 'nome_ordenacao ASC'` — e na busca com `LIKE`.
8. As preferências são **apagadas** junto com o app nas duas plataformas. O Keychain do iOS, não: itens do `flutter_secure_storage` **podem sobreviver** à desinstalação, e o usuário reinstala já logado, sem entender por quê. Por isso existe `limparSeReinstalado`, chamado **antes** de qualquer leitura do cofre: se a marca "já rodou antes" não está nas preferências (que foram apagadas), o cofre é limpo com `apagarTudo()`.
9. Porque ele informa que existe uma **interface de rede ativa**, não que há internet: Wi-Fi de hotel com portal cativo, franquia esgotada ou roteador sem link com a operadora reportam "conectado". Decidir com base nele faz o app usar cache com a rede perfeita, ou tentar a rede sem internet. Ele serve para **explicar** uma falha já ocorrida ("sem conexão" em vez de "erro desconhecido"), **disparar** a sincronização na transição offline → online e **mostrar** o indicador de estado offline. A requisição se tenta sempre.
10. `onCreate` só roda quando o arquivo do banco **não existe**. No aparelho de quem já instalou o app, ele existe — o método nunca é chamado, e a coluna nova simplesmente não aparece (`DatabaseException(no such column: ...)`). Toda mudança de esquema precisa de `onCreate` **e** `onUpgrade`, com a `version` subindo junto. E uma migração publicada nunca é editada porque quem já migrou não migra de novo: corrigi-la criaria bancos com estruturas diferentes na "mesma" versão. Para corrigir, escreve-se a migração seguinte.

### Solução prática de referência

```dart
// lib/core/banco/banco_foco.dart (trechos alterados)
class BancoFoco {
  const BancoFoco._();

  /// 1 → inicial · 2 → materias.arquivada · 3 → sessoes.anotacao/humor
  /// 4 → materias.cor
  static const int versaoAtual = 4;

  static Future<void> criar(Database db, int versao) async {
    await db.execute(
      'CREATE TABLE materias ('
      '  id             TEXT    PRIMARY KEY,'
      '  nome           TEXT    NOT NULL,'
      '  nome_ordenacao TEXT    NOT NULL,'
      '  minutos        INTEGER NOT NULL DEFAULT 0,'
      '  criada_em      INTEGER NOT NULL,'
      '  arquivada      INTEGER NOT NULL DEFAULT 0,'
      '  cor            INTEGER NOT NULL DEFAULT 0'   // novo na v4
      ')',
    );
    // … demais CREATE TABLE e CREATE INDEX, inalterados …
  }

  /// EM ETAPAS, sem `else`: quem está na v1 executa os quatro blocos.
  static Future<void> atualizar(Database db, int de, int para) async {
    if (de < 2) await _de1Para2(db);
    if (de < 3) await _de2Para3(db);
    if (de < 4) await _de3Para4(db);
  }

  /// v3 → v4: matérias ganham cor.
  ///
  /// `NOT NULL` exige `DEFAULT`: as linhas que já existem precisam de um
  /// valor, senão o SQLite recusa com
  /// "Cannot add a NOT NULL column with default value NULL".
  static Future<void> _de3Para4(Database db) async {
    await db.execute(
      'ALTER TABLE materias ADD COLUMN cor INTEGER NOT NULL DEFAULT 0',
    );
  }
}
```

```dart
// lib/features/materias/data/materia_dao.dart (acréscimo)
/// Devolve quantas linhas mudaram — 0 significa "essa matéria não existe".
Future<int> definirCor(String id, int cor) {
  return _db.update(
    tabela,
    <String, Object?>{'cor': cor},
    where: 'id = ?',            // nunca "id = '$id'"
    whereArgs: <Object?>[id],
  );
}
```

```dart
// test/migracoes_test.dart (acréscimo)
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late String caminho;

  setUp(() async {
    caminho = p.join(await databaseFactory.getDatabasesPath(),
        'migracao_v4_${DateTime.now().microsecondsSinceEpoch}.db');
  });

  tearDown(() => databaseFactory.deleteDatabase(caminho));

  test('v3 → v4 cria a coluna cor e preserva as linhas', () async {
    // 1. Banco como ele está no aparelho de quem tem a versão 3.
    final Database v3 = await openDatabase(
      caminho,
      version: 3,
      onConfigure: BancoFoco.configurar,
      onCreate: _criarV3,
    );
    await v3.insert('materias', <String, Object?>{
      'id': 'm1', 'nome': 'Álgebra', 'nome_ordenacao': 'algebra',
      'minutos': 120, 'criada_em': 10, 'arquivada': 0,
    });
    await v3.insert('materias', <String, Object?>{
      'id': 'm2', 'nome': 'Física', 'nome_ordenacao': 'fisica',
      'minutos': 30, 'criada_em': 20, 'arquivada': 0,
    });
    await v3.close();

    // 2. O usuário atualiza o app: a mesma abertura dispara o onUpgrade.
    final Database v4 = await openDatabase(
      caminho,
      version: BancoFoco.versaoAtual,
      onConfigure: BancoFoco.configurar,
      onCreate: BancoFoco.criar,
      onUpgrade: BancoFoco.atualizar,
    );

    // 3. A coluna existe, com o DEFAULT certo.
    final List<Map<String, Object?>> colunas =
        await v4.rawQuery('PRAGMA table_info(materias)');
    final Map<String, Object?> cor =
        colunas.firstWhere((Map<String, Object?> c) => c['name'] == 'cor');
    expect(cor['type'], 'INTEGER');
    expect(cor['notnull'], 1);
    expect(cor['dflt_value'], '0');

    // 4. E os dados de antes continuam lá, com a cor padrão.
    final List<Materia> materias = await MateriaDao(v4).listar();
    expect(materias.map((Materia m) => m.nome), <String>['Álgebra', 'Física']);
    expect(await v4.getVersion(), 4);

    await MateriaDao(v4).definirCor('m1', 0xFF1565C0);
    final Materia? m1 = await MateriaDao(v4).porId('m1');
    expect(m1!.cor, 0xFF1565C0);
    expect(m1.minutos, 120); // a atualização não zerou o resto

    await v4.close();
  });
}
```

O avaliador procura três coisas no código do aluno: o `if (de < 4)` **somado** aos anteriores, sem `else` (com `else if`, quem vem da v1 para na v2 e o banco mente sobre a própria versão); o `DEFAULT 0` no `ALTER TABLE`, sem o qual a migração falha em qualquer aparelho com linhas gravadas; e o teste abrindo o banco **duas vezes** — primeiro na v3, depois na v4 —, porque um teste que cria tudo já na versão 4 passa sem nunca executar a migração. Rejeite `definirCor` que monte o `where` por interpolação e qualquer teste que confirme a ordenação sem usar um nome acentuado.

---

<a id="modulo-11"></a>
## Módulo 11 — Recursos nativos

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-11-recursos-nativos.md).

### Questionário

1. **B** — desde o Android 6 declarar não basta: o `<uses-permission>` habilita e o `request()` em tempo de execução concede; a `UsageDescription` é o modelo do iOS.
2. **C** — `connectivity_plus` responde "há interface de rede?", não "há internet?": portal cativo, franquia esgotada e DNS quebrado dão `wifi` sem internet.
3. **A** — `paused` é chamado de forma confiável; `inactive` acontece dezenas de vezes por dia e `detached` pode nunca ser chamado.
4. **D** — `.adaptive` lê `Theme.of(context).platform`, e por isso a tecla `o` do terminal já troca a variante sem emulador.
5. **B** — `matchDateTimeComponents` cria **uma** notificação recorrente; agendar N estoura o limite de 64 pendentes do iOS, e `SCHEDULE_EXACT_ALARM` é restrita a despertadores e calendários.
6. **C** — o `.xcworkspace` junta o projeto aos Pods; abrir o `.xcodeproj` ignora as dependências e a build falha.
7. Cancelar devolve `null` — e cancelar é o caso normal, não erro: trate em silêncio, sem "falha ao carregar imagem". Escolhendo, vem um `XFile`, que não é um `File` porque também funciona na web. O `.path` aponta para a **pasta de cache** do app, que o sistema pode apagar a qualquer momento; copie para `getApplicationDocumentsDirectory()` com `p.join` e guarde **esse** caminho no banco.
8. `formato` identifica que o arquivo é do Foco, `versao` permite evoluir o esquema sem quebrar backups antigos e recusar arquivo de versão mais nova que o app conhece, e `exportado_em` diz o que o usuário está prestes a restaurar. A validação vem antes de gravar porque validar enquanto aplica deixa o banco pela metade: se o item 300 for inválido, os 299 anteriores já entraram. Valide estrutura, integridade referencial (sessão sem matéria) e versão; só então aplique.
9. Interceptar é consultar o usuário; impedir é prendê-lo. No formulário de matéria use `canPop: !temAlteracoes`, de modo que só há pergunta quando existe algo a perder, e `onPopInvokedWithResult` abre um diálogo com **Descartar** e **Continuar editando** — o Descartar sai de verdade. `canPop: false` sem saída é o antipadrão: no iOS, sem seta na barra, resta fechar o app. Melhor ainda é salvar rascunho e não perguntar nada.
10. Pub points medem **forma** (documentação, análise estática, null safety), não conteúdo: um pacote abandonado pode marcar 160. Pesam mais a **data da última publicação** combinada com issues respondidas — o sinal claro de abandono é uma issue "não compila com o Flutter atual" parada há meses — e o **publisher verificado** (o selo `flutter.dev` é a aposta mais segura), além da aba *Platforms*, da licença e da árvore de dependências.

### Solução prática de referência

```dart
// foco_nativo/lib/features/sessoes/presentation/sessao_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foco_nativo/core/rede/estado_de_rede.dart';
import 'package:foco_nativo/features/cronometro/domain/sessao_em_andamento.dart';

/// ⚠️ O `yield` inicial é obrigatório: `onConnectivityChanged` só emite
/// em MUDANÇAS. Sem ele, a tela abre sem saber o estado atual.
final StreamProvider<LeituraDeRede> estadoDeRedeProvider =
    StreamProvider<LeituraDeRede>((Ref ref) async* {
  final ObservadorDeRede observador = ref.watch(observadorDeRedeProvider);
  yield await observador.atual();
  yield* observador.observar(); // já vem com .distinct
});

class SessaoScreen extends ConsumerStatefulWidget {
  const SessaoScreen({required this.materiaId, super.key});

  final String materiaId;

  @override
  ConsumerState<SessaoScreen> createState() => _SessaoScreenState();
}

class _SessaoScreenState extends ConsumerState<SessaoScreen> {
  static const String _chave = 'sessao_em_andamento';

  SessaoEmAndamento? _sessao;

  /// ⚠️ Só REDESENHA. O tempo vem do relógio, nunca deste contador.
  Timer? _redesenho;

  late final AppLifecycleListener _ciclo;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(
      onPause: _salvar, // salve AQUI; `detached` pode não ser chamado
      onResume: _recarregar,
    );
    _redesenho = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    unawaited(_recarregar());
  }

  @override
  void dispose() {
    _redesenho?.cancel();
    _ciclo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SessaoEmAndamento? sessao = _sessao;
    if (sessao == null) {
      await prefs.remove(_chave);
      return;
    }
    await prefs.setString(_chave, jsonEncode(sessao.paraJson()));
  }

  Future<void> _recarregar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bruto = prefs.getString(_chave);
    if (bruto == null) return;

    final SessaoEmAndamento recuperada = SessaoEmAndamento.deJson(
      jsonDecode(bruto) as Map<String, Object?>,
    );

    // Estado implausível: ninguém estuda 12 horas seguidas. O app
    // ficou aberto a noite inteira com o cronômetro ligado.
    if (recuperada.suspeita) {
      await prefs.remove(_chave);
      if (mounted) setState(() => _sessao = null);
      return;
    }
    if (mounted) setState(() => _sessao = recuperada);
  }

  void _iniciar() {
    setState(() {
      _sessao = SessaoEmAndamento(
        materiaId: widget.materiaId,
        iniciadaEm: DateTime.now(),
      );
    });
    unawaited(_salvar());
  }

  Future<bool> _confirmarDescarte() async {
    final bool? descartar = await showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext contexto) => AlertDialog.adaptive(
        title: const Text('Descartar a sessão?'),
        content: const Text('O tempo estudado agora não será registrado.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Continuar estudando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return descartar ?? false;
  }

  String _formatar(Duration d) {
    final String mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours.toString().padLeft(2, '0')}:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final SessaoEmAndamento? sessao = _sessao;
    final AsyncValue<LeituraDeRede> rede = ref.watch(estadoDeRedeProvider);
    final bool offline = rede.valueOrNull?.online == false;

    return PopScope<Object?>(
      // Dinâmico: só intercepta quando há o que perder.
      canPop: sessao == null,
      onPopInvokedWithResult: (bool saiu, Object? resultado) async {
        if (saiu) return;
        final bool descartar = await _confirmarDescarte();
        // Interceptar sim, IMPEDIR não: o Descartar sai de verdade.
        if (!descartar || !mounted) return;
        setState(() => _sessao = null);
        await _salvar();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Sessão de estudo')),
        body: Column(
          children: <Widget>[
            // Faixa discreta, nunca diálogo modal.
            if (offline)
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.errorContainer,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Text(
                  'Sem rede. A sessão continua e sincroniza depois.',
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      // ✅ medido pelo relógio, não contado pelo Timer
                      _formatar(sessao?.decorrido ?? Duration.zero),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: sessao == null ? _iniciar : null,
                      child: const Text('Iniciar sessão'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

O avaliador deve procurar duas coisas antes de tudo: que nenhum `setState` do `Timer` some ou subtraia tempo — o valor exibido sai sempre de `DateTime.now().difference(iniciadaEm)` — e que `onPause` (não `onInactive`, nem `onDetach`) é quem grava. Depois confira que `dispose` cancela o `Timer` **e** descarta o `AppLifecycleListener`, que o `StreamProvider` tem `yield` inicial, e que todo caminho do `PopScope` termina em saída possível: `canPop: false` sem `Navigator.pop` no diálogo é nota zero no critério.

---

<a id="modulo-12"></a>
## Módulo 12 — Testes e debug

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-12-testes-e-debug.md).

### Questionário

1. **B** — `RENDERING LIBRARY` é a camada de layout; erro dentro do `build` apareceria como `WIDGETS LIBRARY`.
2. **B** — debug é 2 a 10 vezes mais lento e o emulador usa o processador do PC; em release o DevTools nem conecta.
3. **A** — `error` e `warning` derrubam o comando, `info` não — e por isso se acumulam. Use `--fatal-infos`.
4. **B** — `pumpAndSettle` espera a árvore estabilizar, e com animação infinita isso nunca acontece. Use `pump(duration)`.
5. **B** — método assíncrono pede `thenAnswer`; `thenReturn(Future.value(...))` cria o `Future` uma vez só, `C` usa a sintaxe do mockito (sem a função `() =>`) e `D` devolve `List` onde se espera `Future`.
6. **B** — fechar sem mensagem significa que a camada nativa morreu; `flutter logs` não mostra isso, `adb logcat` mostra. O `-c` antes de reproduzir evita ler o log de ontem.

7. `print()` dispara o lint `avoid_print`: é truncado em 1 KB no 🤖 Android, sobrevive ao build de release e não dá para filtrar. `debugPrint()` controla a vazão da saída, por isso não perde linhas em logs grandes. Para diagnóstico com etiqueta e nível use `developer.log(..., name:, level:)`, e envolva o que for só diagnóstico em `if (kDebugMode)`.
8. `setUpAll` roda uma única vez para o arquivo inteiro: se o teste 1 modifica o objeto, o teste 2 recebe o objeto sujo e a suíte passa a depender da **ordem** de execução — falhando em ordem aleatória. `setUp` cria um objeto novo antes de cada teste, então todos começam do mesmo estado. Para descarte, `addTearDown` junto da criação é mais seguro que um `tearDown` no topo.
9. O **fake** é uma implementação que funciona de verdade em memória e testa o **resultado**; o **mock** grava chamadas e testa o **caminho**, o que acopla o teste à implementação — refatore sem mudar comportamento e o teste quebra à toa. Prefira o fake. Use mock quando não há resultado observável: analytics, log, notificação, envio — aí `verify` com `captureAny` confere **com o quê** o método foi chamado.
10. `Future.delayed` amarra o teste ao relógio: numa máquina lenta ou no CI, 5 s não bastam e a falha volta — o teste só ficou instável com menos frequência, e passou a desperdiçar 5 s em toda execução. O certo é **esperar pela condição**: um laço que dá `pump` curto até o widget esperado aparecer (a função `esperarPor(...)` da aula 8), com um tempo máximo que faz o teste falhar de verdade quando a condição nunca ocorre.

### Solução prática de referência

```dart
// ── lib/dominio/meta_semanal.dart ────────────────────────────────
import 'sessao.dart';

class MetaSemanal {
  MetaSemanal({required this.minutosAlvo}) {
    // Guarda no construtor: um objeto inválido NUNCA existe.
    if (minutosAlvo < 0) {
      throw ArgumentError.value(
          minutosAlvo, 'minutosAlvo', 'Não pode ser negativo');
    }
  }

  final int minutosAlvo;

  int minutosFeitos(List<Sessao> sessoes) =>
      sessoes.fold(0, (int soma, Sessao s) => soma + s.minutos);

  /// Progresso entre 0 e 1.
  double progresso(List<Sessao> sessoes) {
    if (minutosAlvo <= 0) return 0; // sem a guarda, NaN vaza para a tela
    return (minutosFeitos(sessoes) / minutosAlvo).clamp(0.0, 1.0);
  }

  int faltam(List<Sessao> sessoes) {
    final int resto = minutosAlvo - minutosFeitos(sessoes);
    return resto > 0 ? resto : 0;
  }
}

// ── lib/dominio/meta_repositorio_contrato.dart ───────────────────
abstract interface class MetaRepositorioContrato {
  Future<MetaSemanal> metaDaSemana();
  Future<List<Sessao>> sessoesDaSemana();
}

// ── lib/apresentacao/painel_meta.dart ────────────────────────────
import 'package:flutter/material.dart';

class PainelMeta extends StatefulWidget {
  const PainelMeta({super.key, required this.repositorio});

  /// Injetado: o teste passa um fake, não o repositório real.
  final MetaRepositorioContrato repositorio;

  @override
  State<PainelMeta> createState() => _PainelMetaState();
}

class _PainelMetaState extends State<PainelMeta> {
  bool _carregando = true;
  String? _erro;
  double _progresso = 0;
  int _faltam = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final MetaSemanal meta = await widget.repositorio.metaDaSemana();
      final List<Sessao> sessoes =
          await widget.repositorio.sessoesDaSemana();
      if (!mounted) return; // defesa contra setState() after dispose()
      setState(() {
        _progresso = meta.progresso(sessoes);
        _faltam = meta.faltam(sessoes);
        _carregando = false;
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar a meta';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(
        key: Key('indicador'),
        child: CircularProgressIndicator(),
      );
    }
    final String? erro = _erro;
    if (erro != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(erro, key: const Key('mensagem_erro')),
          FilledButton(
            key: const Key('botao_tentar'),
            onPressed: _carregar,
            child: const Text('Tentar de novo'),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LinearProgressIndicator(
            key: const Key('barra_progresso'), value: _progresso),
        Text('Faltam $_faltam min', key: const Key('texto_faltam')),
      ],
    );
  }
}

// ── test/fakes/meta_repositorio_fake.dart ────────────────────────
class MetaRepositorioFake implements MetaRepositorioContrato {
  MetaRepositorioFake({required this.meta, this.sessoes = const <Sessao>[]});

  MetaSemanal meta;
  List<Sessao> sessoes;

  // ── Controles de teste ──
  Duration atraso = Duration.zero; // permite observar o carregamento
  Object? falha; // quando não é null, toda chamada lança
  int chamadas = 0; // spy embutido

  Future<void> _preparar() async {
    chamadas++;
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);
    final Object? f = falha;
    if (f != null) throw f; // o fake precisa falhar onde o real falha
  }

  @override
  Future<MetaSemanal> metaDaSemana() async {
    await _preparar();
    return meta;
  }

  @override
  Future<List<Sessao>> sessoesDaSemana() async {
    await _preparar();
    return List<Sessao>.unmodifiable(sessoes);
  }
}

// ── test/meta_semanal_test.dart ──────────────────────────────────
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MetaSemanal meta;

  // setUp, não setUpAll: cada teste ganha uma meta nova.
  setUp(() => meta = MetaSemanal(minutosAlvo: 300));

  Sessao sessao(int minutos) => Sessao(
        materiaId: 'dart',
        minutos: minutos,
        quando: DateTime(2026, 3, 10, 14),
      );

  group('progresso', () {
    test('sem sessões, progresso zero', () {
      expect(meta.progresso(<Sessao>[]), 0); // a lista vazia sempre
    });

    test('fronteira exata da meta: progresso 1.0', () {
      expect(meta.progresso(<Sessao>[sessao(300)]), 1.0);
    });

    test('meta ultrapassada não passa de 1.0', () {
      // Sem o clamp, a barra ficaria com 200% e lançaria assertion.
      expect(meta.progresso(<Sessao>[sessao(480), sessao(120)]), 1.0);
    });

    test('progresso parcial com precisão de ponto flutuante', () {
      // closeTo, não igualdade: 100/300 = 0.3333333333333333.
      expect(meta.progresso(<Sessao>[sessao(100)]), closeTo(0.333, 0.001));
    });

    test('alvo zero não divide por zero', () {
      expect(MetaSemanal(minutosAlvo: 0).progresso(<Sessao>[sessao(25)]), 0);
    });
  });

  group('faltam', () {
    test('lista vazia devolve o alvo inteiro', () {
      expect(meta.faltam(<Sessao>[]), 300);
    });

    test('meta ultrapassada não devolve negativo', () {
      expect(meta.faltam(<Sessao>[sessao(400)]), 0);
    });
  });

  test('alvo negativo lança ArgumentError', () {
    // FUNÇÃO ANÔNIMA: sem ela, a exceção sobe antes do expect.
    expect(() => MetaSemanal(minutosAlvo: -1), throwsA(isA<ArgumentError>()));
  });
}

// ── test/painel_meta_test.dart ───────────────────────────────────
void main() {
  late MetaRepositorioFake repo;

  setUp(() {
    repo = MetaRepositorioFake(
      meta: MetaSemanal(minutosAlvo: 300),
      sessoes: <Sessao>[
        Sessao(materiaId: 'dart', minutos: 150, quando: DateTime(2026, 3, 10)),
      ],
    );
  });

  Future<void> montar(WidgetTester t) => t.pumpWidget(
        MaterialApp(home: Scaffold(body: PainelMeta(repositorio: repo))),
      );

  testWidgets('mostra o indicador enquanto carrega', (WidgetTester t) async {
    repo.atraso = const Duration(seconds: 2);

    await montar(t);
    await t.pump(); // no teste o tempo não passa sozinho

    expect(find.byKey(const Key('indicador')), findsOneWidget);

    // Sem deixar o Future completar, o teste falharia com
    // "A Timer is still pending after the widget tree was disposed".
    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle();
  });

  testWidgets('mostra o progresso e quanto falta', (WidgetTester t) async {
    await montar(t);
    await t.pumpAndSettle();

    final LinearProgressIndicator barra = t.widget<LinearProgressIndicator>(
        find.byKey(const Key('barra_progresso')));

    expect(barra.value, closeTo(0.5, 0.001));
    expect(find.text('Faltam 150 min'), findsOneWidget);
  });

  testWidgets('mostra o erro e recarrega ao tocar em tentar de novo',
      (WidgetTester t) async {
    repo.falha = Exception('sem rede');

    await montar(t);
    await t.pumpAndSettle();

    expect(find.byKey(const Key('mensagem_erro')), findsOneWidget);

    repo.falha = null;
    await t.tap(find.byKey(const Key('botao_tentar')));
    await t.pumpAndSettle(); // pump depois de TODA interação

    expect(find.byKey(const Key('barra_progresso')), findsOneWidget);
    expect(repo.chamadas, greaterThan(2), reason: 'recarregou de verdade');
  });
}
```

O avaliador deve procurar três coisas: as guardas no domínio (`minutosAlvo <= 0` e `clamp`), sem as quais `NaN` e progresso acima de 100% chegam à tela; os casos-limite nos unitários (lista vazia, fronteira exata, `closeTo` em vez de igualdade e a função anônima no `throwsA`); e, no teste de widget, `find.byKey` em vez de `byType`, `pump` depois de cada interação e o `pump(duration)` que deixa o atraso do fake completar — sem ele, aparece "A Timer is still pending", que é o sintoma, não o defeito. Um teste que só instancia o fake e confere o que o próprio fake devolveu não vale ponto: o dublê é a dependência, nunca o sujeito do teste.

---

<a id="modulo-13"></a>
## Módulo 13 — Desempenho e segurança

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-13-desempenho-e-seguranca.md).

### Questionário

1. **B** — expressões `const` são canonizadas: a mesma instância chega ao `updateChild`, `identical` dá verdadeiro e a subárvore inteira é pulada.
2. **C** — a key vem do dado, nunca da posição: `ValueKey(indice)` deixa de identificar o item ao reordenar e `UniqueKey()` recria o widget a cada frame.
3. **C** — a memória é largura × altura × 4 bytes (RGBA) do bitmap cru; `width` muda o tamanho na tela, `cacheWidth`/`cacheHeight` mudam o tamanho na memória.
4. **B** — `async` organiza **quando** o código roda, não **onde**; CPU pura nunca devolve a thread. Só espera de I/O libera a UI.
5. **C** — barra verde é a raster thread (GPU): `Opacity`, clips, blur e sombras forçam `saveLayer`. As alternativas A, B e D são causas típicas de barra **azul** (UI).
6. **A** — `GestureDetector` em volta de `Icon` não cria rótulo semântico nem área de toque; `IconButton` com `tooltip` resolve os dois, e o alvo precisa de 48 dp (🤖) / 44 pt (🍎).

7. Debug roda com JIT, asserts e instrumentação — costuma ser 5 a 10 vezes mais lento que release; e o emulador usa a CPU e a GPU do PC, que não têm relação com o celular do usuário. Você acaba passando a tarde otimizando um problema que não existe, ou não enxergando o que existe. Medição só vale em `--profile`, em aparelho físico, com o número de antes anotado.
8. `--dart-define` tira o valor do **Git**, não do binário: é configuração por ambiente, lida em contexto `const` por `String.fromEnvironment`, e continua legível num `strings` do APK. `flutter_secure_storage` guarda dado do usuário em tempo de execução no Keystore/Keychain, fora do `SharedPreferences` e do backup. Nenhum dos dois torna uma chave secreta segura — essa mora no servidor.
9. Porque se disfarça de boa prática: você ofusca, sente o app mais seguro, e o stack trace de produção chega como `a.b (package:foco/a.dart:1:1)`. Sem o `.symbols` daquele build exato não há `flutter symbolize`, e recompilar gera um binário diferente — os crashes daquela versão ficam ilegíveis para sempre. O problema só aparece meses depois. Guarde os símbolos por versão, como artefato do CI.
10. Criar um isolate custa 50–200 ms, pagos na própria thread de UI; e os dados são **copiados**, não compartilhados — copiar uma lista grande também acontece na UI thread. Para um cálculo de 2 ms ou um `jsonDecode` de 10 KB, os dois custos superam o trabalho. Regra: abaixo de 16 ms deixe onde está, acima de 50 ms use isolate, no meio meça.

### Solução prática de referência

```dart
// foco_desempenho/lib/features/materias/domain/materia.dart
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.capa,
    required this.minutosEstudados,
  });

  // Construtor const é o que LIBERA widget const lá na frente.
  factory Materia.doMapa(Map<String, Object?> m) => Materia(
        id: m['id']! as String,
        nome: m['nome']! as String,
        capa: m['capa']! as String,
        minutosEstudados: m['minutos']! as int,
      );

  final String id;
  final String nome;
  final String capa;
  final int minutosEstudados;
}

// foco_desempenho/lib/features/materias/data/materia_dao.dart
import 'package:sqflite/sqflite.dart';

import '../domain/materia.dart';

class MateriaDao {
  MateriaDao(this._db);

  final Database _db;

  Future<List<Materia>> buscar(String termo) async {
    // O `?` garante que o termo NUNCA é interpretado como SQL —
    // e resolve o apóstrofo de "D'Ávila" de brinde.
    final List<Map<String, Object?>> linhas = await _db.query(
      'materias',
      where: 'nome_ordenacao LIKE ?',
      whereArgs: <Object?>['%${termo.toLowerCase()}%'],
      limit: 100,
    );
    return linhas.map(Materia.doMapa).toList();
  }
}

// foco_desempenho/lib/features/materias/presentation/lista_grande_screen.dart
import 'dart:isolate';

import 'package:flutter/material.dart';

import '../domain/materia.dart';

/// Função de TOPO: o corpo roda dentro do isolate.
int somarMinutos(List<Materia> materias) =>
    materias.fold<int>(0, (int t, Materia m) => t + m.minutosEstudados);

class ListaGrandeScreen extends StatefulWidget {
  const ListaGrandeScreen({required this.materias, super.key});

  final List<Materia> materias;

  @override
  State<ListaGrandeScreen> createState() => _ListaGrandeScreenState();
}

class _ListaGrandeScreenState extends State<ListaGrandeScreen> {
  late final Future<int> _totalMinutos;

  @override
  void initState() {
    super.initState();
    // Extraia ANTES: a closure não pode capturar `widget` nem `context`.
    final List<Materia> dados = widget.materias;
    // 50 000 sessões passam de 50 ms: vale o isolate. E roda UMA vez,
    // fora do build.
    _totalMinutos = Isolate.run(() => somarMinutos(dados));
  }

  @override
  Widget build(BuildContext context) {
    final int lado = (48 * MediaQuery.devicePixelRatioOf(context)).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Matérias')),
      body: Column(
        children: <Widget>[
          const _CabecalhoFoco(), // widget extraído e const: sai do rebuild
          FutureBuilder<int>(
            future: _totalMinutos,
            builder: (BuildContext context, AsyncSnapshot<int> s) => Semantics(
              liveRegion: true,
              child: Text(
                s.hasData ? '${s.data} minutos no total' : 'Somando…',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemExtent: 72, // só porque TODOS os itens têm 72 px
              itemCount: widget.materias.length,
              itemBuilder: (BuildContext context, int i) {
                final Materia m = widget.materias[i];
                return MateriaTile(
                  key: ValueKey<String>(m.id), // a key vem do DADO
                  materia: m,
                  ladoCache: lado,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CabecalhoFoco extends StatelessWidget {
  const _CabecalhoFoco();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Foco — suas matérias'),
      );
}

class MateriaTile extends StatelessWidget {
  const MateriaTile({
    required this.materia,
    required this.ladoCache,
    super.key,
  });

  final Materia materia;
  final int ladoCache;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // minHeight, nunca height: com a fonte a 200 % o texto precisa crescer.
      constraints: const BoxConstraints(minHeight: 48),
      child: MergeSemantics(
        child: Row(
          children: <Widget>[
            Image.asset(
              materia.capa,
              width: 48,
              height: 48,
              // width/height = tela; cacheWidth/cacheHeight = MEMÓRIA.
              cacheWidth: ladoCache,
              cacheHeight: ladoCache,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
            Expanded(child: Text(materia.nome)),
            IconButton(
              icon: const Icon(Icons.star_border),
              // O tooltip vira o rótulo semântico e descreve a AÇÃO.
              tooltip: 'Favoritar ${materia.nome}',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

O avaliador procura três coisas no código do aluno: a key saindo do dado (`ValueKey(materia.id)`, nunca do índice), `cacheWidth`/`cacheHeight` calculados pelo `devicePixelRatio` — e não apenas `width` — e a closure do `Isolate.run` capturando só a lista, nunca `widget` ou `context`. Exija também os dois números medidos em modo profile: "ficou mais rápido" não vale ponto; "de 38 ms para 7 ms no pior quadro" vale.

---

<a id="modulo-14"></a>
## Módulo 14 — Build e distribuição Web (PWA)

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-14-build-web-pwa.md).

### Questionário

1. **B** — HTTPS, `manifest.json` válido e service worker com handler de `fetch`. Não existe loja nem aprovação: o navegador confere os três sozinho. Domínio próprio e `--wasm` não têm relação com instalabilidade.
2. **B** — um `ElevatedButton` não vira `<button>`: o Flutter desenha tudo num único `<canvas>` com o Skia compilado para WASM (CanvasKit). É o que garante fidelidade visual idêntica nos três alvos, e o que custa ~1,5 MB de engine baixado, SEO limitado e acessibilidade via árvore semântica.
3. **B** — o `dart2js` fornece uma casca de `dart:io` em que as operações lançam. O import resolve, a análise passa, o build imprime `√ Built build\web` — e a exceção só acontece quando a linha **executa**, no navegador do usuário. É o modelo de falha de todo o módulo.
4. **B** — o `<base href>` ficou em `/` e o navegador procura tudo na raiz do domínio. A) daria Console limpo e Network servida pelo service worker; C) impediria instalação, não carregamento; D) o CanvasKit não é pré-requisito do `index.html`.
5. **B** — o service worker entrega o cache para abrir instantâneo e baixa a versão nova em paralelo, que passa a valer na abertura seguinte. Não é bug: é o preço do carregamento instantâneo, e se resolve com aviso de atualização por `controllerchange`, não desligando o service worker.
6. **B** — por padrão o CanvasKit vem de `gstatic.com`, e o service worker do Flutter só faz cache de recursos da **mesma origem**. Sem a flag, o app instalado pode não abrir em modo avião — quebrando justamente a promessa de offline.

7. O `sqflite` é um **plugin**: código Dart de um lado, SQLite nativo do outro, por platform channel. O navegador não tem SQLite, então a chamada estoura. O `sqflite_common_ffi_web` carrega o **SQLite compilado para WebAssembly** (`sqlite3.wasm`) e o executa num web worker (`sqflite_sw.js`), persistindo os blocos do arquivo em **IndexedDB**, por origem. O SQL, as migrações e o `PRAGMA foreign_keys` não mudam. O banco desaparece: em **aba anônima** ao fechar; quando o usuário **limpa dados de navegação**; quando o navegador **despeja** por falta de espaço (modo `best-effort`, mitigado por `persist()`); e — o caso mais grave e menos lembrado — quando **a URL do app muda**, porque a origem é a identidade do armazenamento.
8. `start_url` é **onde abrir** quando o usuário toca no ícone; `scope` é **até onde** o app se considera ele mesmo. Quando o `scope` não corresponde ao `--base-href`, o app instalado passa a exibir uma **barra de navegador** — porque o navegador entende que a navegação saiu do escopo do app. O sintoma é específico e traiçoeiro: não quebra o build, não quebra o deploy, não aparece em aba normal. Só quem instala vê.
9. CORS é uma regra **do navegador**: numa requisição para outra origem, ele faz a chamada mas **esconde a resposta** do seu código a menos que o servidor devolva `Access-Control-Allow-Origin`. Não existe no Android nem no iOS, por isso o mesmo código funciona no celular e falha no Chrome. Nenhuma flag do `package:http` desativa — a decisão é do navegador, por segurança, e é deliberadamente inescapável; as saídas são o servidor mandar o cabeçalho ou um proxy na mesma origem. O diagnóstico se confirma no **Console**, nunca na aba Network: lá a requisição pode aparecer como `200`, porque o servidor respondeu e foi o navegador que descartou.
10. **Caminho** (`--base-href` errado): Console e Network mostram `404` nos arquivos; quebra igual em janela anônima. **Código** (exceção antes do `runApp`): Console mostra exceção Dart, Network toda `200`; quebra igual em anônima. **Cache** (service worker com build quebrado): Console **vazio**, Network `200` com `(ServiceWorker)` na coluna Size, e **funciona em janela anônima** — que é justamente o que o separa dos outros dois. A ordem importa: limpar o cache primeiro mascara os três e ensina nada.

### Solução prática de referência

```yaml
# .github/workflows/publicar-web.yml — trecho central
permissions:
  contents: read
  pages: write
  id-token: write        # OIDC: é o que dispensa guardar qualquer segredo

env:
  BASE_HREF: /foco/      # igual ao "scope" de web/manifest.json

jobs:
  construir:
    runs-on: ubuntu-latest
    steps:
      - run: flutter analyze
      - run: flutter test
      - run: flutter test --platform chrome     # o portão que pega os erros só-web
      - run: >
          flutter build web --release
          --base-href "$BASE_HREF"
          --no-web-resources-cdn
          --source-maps
      - run: cp build/web/index.html build/web/404.html
      - run: |
          set -e
          grep -q "<base href=\"$BASE_HREF\"" build/web/index.html
          test -f build/web/sqlite3.wasm
```

```powershell
# Comprovação local antes do push
dart run sqflite_common_ffi_web:setup
git add web/sqlite3.wasm web/sqflite_sw.js
git diff --stat            # domain/ e presentation/ NÃO podem aparecer
flutter test --platform chrome
```

O avaliador procura quatro coisas no `docs/release-web-1.0.0.md`. Primeira: o `git diff --stat` da troca de banco **sem nenhum arquivo de `domain/` ou `presentation/`** — se aparecer, a camada de dados vazava para o domínio e o problema é anterior ao módulo. Segunda: o `scope` do manifest **idêntico** ao `--base-href` do workflow; divergência aqui é o defeito que só se manifesta depois de instalar. Terceira: `flutter test --platform chrome` entre os portões do CI — sem ele o pipeline dá falso verde para exatamente a classe de erro que a web introduz. Quarta, e a que não se automatiza: o relato da validação **em modo avião, no celular, com o app aberto pelo ícone**, criando uma sessão que sobrevive ao fechar e reabrir. Sem esse último item, a prática não vale os 2 pontos de offline — abrir no DevTools com "Offline" marcado não é a mesma coisa.

---

<a id="modulo-15"></a>
## Módulo 15 — Build e distribuição Android

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-15-build-android.md).

### Questionário

1. **B** — JIT compila durante a execução e é o que torna o hot reload possível; release é AOT, sem asserts nem DevTools.
2. **B** — `applicationId` é a identidade para o sistema e para a loja; `namespace` é o pacote do código compilado (`R`, `BuildConfig`).
3. **A** — `INTERNET` no `debug/` vale só em `flutter run`; permissão de verdade vai no `main/AndroidManifest.xml`.
4. **B** — em arquivos `.properties` a `\` é escape; use barras normais (`/`) no `storeFile`, mesmo no Windows.
5. **B** — o projeto novo do Flutter já vem com `signingConfigs.getByName("debug")`; o APK instala, funciona e é recusado no upload.
6. **B** — AAB é obrigatório para apps novos na loja; fora dela, o APK `arm64-v8a` cobre ~95 % dos aparelhos e o AAB não instala direto.

7. A splash nativa é desenhada pelo **sistema operacional** no intervalo entre o toque no ícone e o primeiro frame do Flutter, e **não tem duração configurável**: some quando o Flutter desenha. A tela de carregamento em Flutter é um **widget** seu, vem depois da splash e aí sim você controla quanto tempo ela fica. Usar a splash nativa para "mostrar a marca por 3 segundos" é erro conceitual.
8. A assinatura prova que a atualização vem de quem publicou a versão anterior. Sem Play App Signing, um APK assinado com outra chave é recusado na instalação com `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, e não existe recurso: o app publicado fica congelado para sempre. Com Play App Signing — **obrigatório para apps novos em AAB** —, quem assina a entrega é o Google; a sua chave é só a de **upload**, e perdê-la é recuperável: o Google revoga e aceita uma nova.
9. Instalação limpa testa o app em um aparelho sem dados; atualização testa o app **sobre** os dados da versão anterior. O segundo é o esquecido e é o que revela **migração de banco quebrada** (sqflite): no Foco, matérias e sessões já gravadas somem ou o app trava na abertura — um defeito que apagaria os dados de todos os usuários e que a instalação limpa nunca mostraria. Por isso se guarda o APK de cada versão publicada.
10. `UPDATE_INCOMPATIBLE` é **assinatura diferente** entre a versão instalada e a nova (típico de instalar o release por cima do debug); em teste, corrige-se com `adb uninstall br.com.estudos.foco` antes de instalar — em produção, ninguém conseguiria atualizar. `NO_MATCHING_ABIS` é **arquitetura incompatível**: um APK `arm64-v8a` em emulador x86_64; corrige-se instalando o APK universal, o da ABI certa ou usando aparelho físico.

### Solução prática de referência

```kotlin
// android/app/build.gradle.kts — trecho central
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "br.com.estudos.foco"

    defaultConfig {
        applicationId = "br.com.estudos.foco"  // imutável após publicar
        minSdk = 24
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // Substitui signingConfigs.getByName("debug") que vem no projeto novo.
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true   // exige isMinifyEnabled = true
        }
    }
}
```

```properties
# android/key.properties — NUNCA vai para o Git (.gitignore ajustado ANTES)
# Barras normais (/) mesmo no Windows: \ é escape em .properties
storeFile=C:/chaves/foco-upload.jks
storePassword=SUA_SENHA_AQUI
keyAlias=SEU_ALIAS
keyPassword=SUA_SENHA_AQUI
```

```powershell
# Geração e comprovação do release
flutter clean
flutter build appbundle --release --obfuscate --split-debug-info=simbolos/1.0.0
flutter build apk --release --target-platform android-arm64 `
  --obfuscate --split-debug-info=simbolos/1.0.0

adb uninstall br.com.estudos.foco
adb install build/app/outputs/flutter-apk/app-release.apk

apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

O avaliador deve procurar, no `docs/release-1.0.0.md`, a saída do `apksigner verify` mostrando o **certificado do aluno** e não o `CN=Android Debug`, a lista de permissões contendo só o que o Foco realmente usa (`INTERNET` no `main/`, sem sobras de plugin), e o `mapping.txt` mais a pasta `simbolos/1.0.0` arquivados junto com os artefatos. Confirme também que `git status` não lista `*.jks` nem `key.properties` — commitar a chave invalida a prática, porque só rotacionar a chave resolve.

---

<a id="modulo-16"></a>
## Módulo 16 — Build e distribuição iOS

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-16-build-ios.md).

### Questionário

1. **B** — o iPhoneOS SDK vem dentro do Xcode, e `codesign` e o chaveiro só existem no macOS; não é limitação do Flutter.
2. **B** — o `.xcodeproj` abre sem os pods, e o build morre em `module 'X' not found`; com Podfile, sempre o workspace.
3. **B** — `ITMS-90717` é o ícone com transparência; `remove_alpha_ios: true` no `flutter_launcher_icons` resolve.
4. **C** — com valor literal o `pubspec.yaml` deixa de alimentar o iOS e as versões divergem sem nenhum aviso.
5. **B** — a conta gratuita dá 3 aparelhos e 7 dias de validade, sem TestFlight e sem App Store.
6. **B** — a contagem do `CFBundleVersion` é monotônica: nem build descartado libera o número, e repetir dá `ITMS-4238`.
7. Interno: até 100 pessoas da equipe no App Store Connect, sem revisão da Apple, disponível assim que o processamento termina. Externo: até 10 000 pessoas, convite por e-mail ou link público, e passa por uma revisão da Apple de 1 a 2 dias. Os dois têm build válido por 90 dias. Comece sempre pelo interno e só promova o build que sobreviveu a ele.
8. Porque o provisioning profile carrega a lista de aparelhos **congelada no momento em que foi gerado**. Registrar o UDID no portal não atualiza profiles existentes: é preciso regerar o profile e baixá-lo de novo (ou deixar a assinatura automática do Xcode refazer isso). É o motivo nº 1 de "funciona no meu iPhone e não no dele".
9. O `.xcarchive` é o resultado da compilação assinada, em `build/ios/archive/Runner.xcarchive`, e contém os dSYM do código nativo; o `.ipa` é o pacote instalável exportado a partir dele, em `build/ios/ipa/foco.ipa`. Você guarda o **archive**: dele dá para reexportar o IPA com outro método sem recompilar, e é onde estão os símbolos para ler os crashes daquela versão.
10. No Android a chamada falha com exceção e o app continua de pé; no iOS o sistema **encerra o processo** no instante em que o recurso é acessado, com só uma menção à chave faltante no console. Além disso, o texto é lido pelo usuário e pelo revisor: ausente derruba o app, genérico causa rejeição.

### Solução prática de referência

```yaml
# pubspec.yaml — trechos que a prática exige
version: 1.0.0+1

dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  ios: true
  image_path: assets/icone/icone.png
  remove_alpha_ios: true      # sem isto: ITMS-90717 no upload
```

```xml
<!-- ios/Runner/Info.plist — as duas variáveis e as permissões -->
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Para salvar na sua galeria o gráfico de progresso dos estudos.</string>
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

```powershell
# Windows — sequência completa da prática
.\ferramentas\trocar-bundle-id.ps1 -Novo br.com.estudos.foco -Simular
.\ferramentas\trocar-bundle-id.ps1 -Novo br.com.estudos.foco
dart run flutter_launcher_icons
.\ferramentas\conferir-identidade.ps1
.\ferramentas\conferir-ios.ps1
git diff ios/Runner.xcodeproj/project.pbxproj
```

O avaliador deve procurar: as **três** ocorrências de `PRODUCT_BUNDLE_IDENTIFIER` com o mesmo valor (Debug, Release e Profile — valores diferentes só estouram na assinatura); o `Icon-App-1024x1024@1x.png` acusado pelo `conferir-ios.ps1` como tipo de cor sem alfa; o `Info.plist` com as duas **variáveis**, nunca os números literais; e nenhuma chave de permissão que o Foco não use (microfone, localização, contatos, rastreamento). Em `docs/release-ios.md`, o roteiro do Mac precisa separar o que é macOS puro — `pod install`, `flutter build ipa`, archive, `codesign`, Organizer e envio — do que já foi feito no Windows, e não pode conter `.p12`, `.cer`, `.mobileprovision` nem Team ID exposto.

---

<a id="modulo-17"></a>
## Módulo 17 — Publicação e próximos passos

> Confira depois de fazer a [avaliação](../avaliacoes/modulo-17-publicacao-e-proximos-passos.md).

### Questionário

1. **B** — contas pessoais novas precisam de teste fechado com 12 testadores por 14 dias seguidos; a verificação de identidade (C) é obrigatória, mas não substitui essa exigência.
2. **B** — o `+N` vira `versionCode` no Android e `CFBundleVersion` no iOS; `1.4.2` é o `versionName`/`CFBundleShortVersionString`.
3. **B** — o número de build nunca se repete nem volta a ficar livre, mesmo de um binário rejeitado; o nome continua `1.0.1` porque, para o usuário, é a mesma versão.
4. **B** — o runner `macos-latest` consome 10× a cota; analyze e test vão no Ubuntu e o macOS fica só para o build iOS.
5. **B** — `FlutterError.onError` cobre o que acontece dentro do framework; sem `PlatformDispatcher.instance.onError`, os erros assíncronos, de isolate e de plugin não são capturados.
6. **B** — reativar a versão anterior impede que mais gente receba a 1.4.2, mas não desfaz instalações; na App Store (D) não existe rollback, só publicar uma versão nova.
7. A chave de assinatura do app fica com a Google e assina o APK entregue ao aparelho; a chave de upload fica com você, no `upload-keystore.jks`, e só prova que o envio é seu. Perder a chave de upload é contornável: você pede um reset no suporte da Play e o app continua vivo. A chave de assinatura você não tem — e é exatamente esse o ganho do Play App Signing, porque antes dele perder a chave significava perder o app para sempre.
8. Os dois formulários são declarações verificáveis, e as lojas cruzam o que você declarou com o que o app faz. Uma `<uses-permission>` de câmera ou localização no `AndroidManifest.xml` contra um "não coleto nada" é contradição, e um SDK de anúncios ou de análise coleta dados por você mesmo que o seu código não colete. A consequência não é aviso: é suspensão na Play e remoção na App Store. No Foco a resposta é "não coleta", porque matérias, sessões e metas ficam no aparelho via sqflite e shared_preferences.
9. O log vai para um servidor de terceiro e fica lá, e o que o usuário digitou pode conter qualquer coisa — anotação pessoal, dado sensível, até credencial. Isso fere a minimização da LGPD e transforma o crash reporting num canal de vazamento involuntário. No lugar, registre o que aconteceu sem o conteúdo: `log('Salvando anotação (${texto.length} chars)')` e chaves de contexto como `setCustomKey('tela', 'detalhe_materia')`, sempre com identificador aleatório, nunca e-mail, CPF ou nome.
10. A tag aponta para o código exato que gerou o binário publicado; a `main` pode já ter recursos pela metade que nunca foram testados em produção. Partindo de `v1.4.2`, o hotfix é a versão publicada mais a correção, e nada além — reduzindo ao mínimo o risco de uma release que já está em campo. Depois de corrigir, sobe para `1.4.3+38`, cria a tag `v1.4.3` e o branch volta para a `main` por merge. E vale a regra: um hotfix corrige uma coisa.

### Solução prática de referência

```yaml
# pubspec.yaml — MINOR porque a tela de metas é recurso novo e compatível.
# O build vai de 7 para 8: nunca reinicia, nunca se repete.
version: 1.1.0+8
```

```markdown
<!-- CHANGELOG.md -->
# Changelog

## [1.1.0] — 2026-09-14

### Adicionado
- Tela de metas semanais, com progresso por matéria

### Corrigido
- O resumo semanal não somava sessões de domingo
```

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:

jobs:
  verificar:
    runs-on: ubuntu-latest        # 1x a cota; macos-latest custaria 10x
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: pub-${{ runner.os }}-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: pub-${{ runner.os }}-
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test
```

```powershell
# Tag ANOTADA: guarda autor, data e mensagem. A leve não guarda nada.
git commit -am "Release 1.1.0 - metas semanais"
git tag -a v1.1.0 -m "Metas semanais"
git push origin main v1.1.0
git show v1.1.0        # confere que a tag existe e tem mensagem
```

```markdown
<!-- docs/release-1.1.0.md -->
## Faixa
Interno primeiro (até 100 testadores, disponível em minutos), depois fechado, depois produção.

## Rollout gradual
5% -> 24 h -> 20% -> 24 h -> 50% -> 100%, avançando só com a taxa de falhas estável.

## Limites que disparam ação imediata
- Taxa de falhas > 1,09% -> interromper o rollout (o Google reduz a visibilidade acima disso)
- Taxa de ANR > 0,47% -> interromper o rollout
- Retenção D1 < 20% -> revisar o primeiro minuto do app
```

O avaliador deve procurar três coisas objetivas: o build em `8` (nunca reiniciado nem reaproveitado), o `runs-on: ubuntu-latest` com os três comandos de verificação, e nenhuma senha, keystore ou caminho de `.jks` escrito dentro do YAML — segredo só por `secrets.*`. A tag precisa ter sido criada com `-a`; uma tag leve não satisfaz o critério. Aceite ordem diferente dos passos e datas diferentes no CHANGELOG, desde que as categorias sejam as da aula (`Adicionado`, `Alterado`, `Corrigido`, `Removido`, `Segurança`).

---

<a id="cumulativa-01"></a>
## Cumulativa 01 — Dart

> Confira depois de fazer a [avaliação](../avaliacoes/cumulativa-01-dart.md), que cobre os módulos 00 a 04.

### Questionário

1. **B** — `final` impede reatribuir a referência, não congela o conteúdo; só `List.unmodifiable` no construtor (ou devolver cópia) fecha a porta.
2. **C** — o `null` do `tryParse` **é** a informação de que a linha é inválida: a borda decide descartar ou lançar a exceção de domínio, e o construtor recebe um `int` já garantido.
3. **B** — `sealed` fecha a hierarquia no arquivo; a exaustividade é checada sobre as subclasses, e os parâmetros `S` e `F` não têm nada a ver com isso.
4. **D** — `.dart_tool/` e `build/` são gerados e `.env` é segredo; os outros três são fonte do projeto e precisam estar versionados.
5. **C** — `map` monta a lista de futuros e `Future.wait` dispara todos juntos, então o tempo total passa a ser o do mais lento.
6. **B** — enum serve para rótulos fechados sem dados próprios; quando cada caso carrega informação diferente, o enum obriga campos nulos espalhados e a `sealed class` resolve.
7. **A** — assinatura não cancelada continua consumindo eventos e segurando o objeto; com o controller aberto, o `dart run` fica pendurado sem encerrar.
8. **C** — o analisador prova coisas sobre tipos, não sobre o dado que só existe rodando; `FormatException` nasce em execução (por exemplo, `int.parse` em texto que não é número).

9. `dart analyze` raciocina sobre tipos, não sobre valores: ele aceita `x!` porque você **afirmou** que ali não é nulo, e essa afirmação não é verificada em lugar nenhum. O `!` costuma entrar para "calar rápido" o erro de tipo depois de `tryParse`, `firstWhere`, leitura de `Map` ou `stdin`. No lugar dele vão a checagem explícita (`if (x == null) continue;`), a promoção de tipo em variável local `final`, o `??` com valor padrão, ou uma exceção de domínio com contexto.
10. `stdin.readLineSync()` só entrega `String?` cru e pode devolver `null` no EOF. A validação é a borda: `trim`, `split`, `int.tryParse`, `StatusSessao.values.asNameMap()` — é ela que traduz texto em tipos e decide entre descartar a linha ou lançar `SessaoInvalidaException` com a linha e o motivo. O construtor recebe dados já válidos e só protege a invariante com `assert`/exceção curta. Dentro do construtor nunca entram I/O, `print`, parse de texto nem regra de negócio.
11. O `<T>` deixa um contrato só servir para `Sessao`, `Materia` e `Meta` sem duplicar código, e preserva o tipo na saída: `listar()` devolve `List<T>`, não `List<dynamic>`, então o compilador continua checando quem consome. Como o código de cima depende do contrato e não da classe concreta, trocar o repositório em memória por um que lê arquivo mexe só no ponto em que o objeto é criado. É exatamente esse desacoplamento que, mais à frente, permite injetar uma implementação falsa no teste.
12. Commitar por etapa te dá um ponto conhecido em que tudo compilava: `git status` e `git diff` mostram exatamente o que a introdução do `Resultado` mudou, arquivo a arquivo, e você decide o que manter. Para voltar só um arquivo sem perder o resto: `git restore --source=HEAD -- bin/estado_tela.dart` (ou `--source=<hash>` para um commit anterior). Com um único commit gigante no fim do dia, a alternativa seria descartar tudo ou caçar o trecho na mão.

### Solução prática de referência

```dart
// bin/cumulativa01_foco.dart
import 'dart:async';

enum StatusSessao { planejada, concluida, cancelada }

class SessaoInvalidaException implements Exception {
  const SessaoInvalidaException(this.linha, this.motivo);
  final String linha;
  final String motivo;

  @override
  String toString() => 'SessaoInvalidaException: "$linha" — $motivo';
}

class Sessao {
  Sessao({required this.materia, required this.minutos, required this.status})
      : assert(minutos > 0 && minutos <= 480);

  final String materia;
  final int minutos;
  final StatusSessao status;

  Sessao copyWith({String? materia, int? minutos, StatusSessao? status}) => Sessao(
        materia: materia ?? this.materia,
        minutos: minutos ?? this.minutos,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      other is Sessao &&
      other.materia == materia &&
      other.minutos == minutos &&
      other.status == status;

  @override
  int get hashCode => Object.hash(materia, minutos, status);

  @override
  String toString() => '$materia · $minutos min · ${status.name}';
}

abstract interface class Repositorio<T> {
  void salvar(T item);
  List<T> listar();
}

class RepositorioMemoria<T> implements Repositorio<T> {
  final List<T> _itens = [];

  @override
  void salvar(T item) => _itens.add(item);

  @override
  List<T> listar() => List.unmodifiable(_itens);
}

sealed class Resultado<S, F> {
  const Resultado();
}

final class Sucesso<S, F> extends Resultado<S, F> {
  const Sucesso(this.valor);
  final S valor;
}

final class Falha<S, F> extends Resultado<S, F> {
  const Falha(this.erro);
  final F erro;
}

sealed class EstadoTela {
  const EstadoTela();
}

final class Carregando extends EstadoTela {
  const Carregando();
}

final class Vazio extends EstadoTela {
  const Vazio();
}

final class SucessoEstado extends EstadoTela {
  const SucessoEstado(this.sessoes, this.resumo);
  final List<Sessao> sessoes;
  final ({int total, double media}) resumo;
}

final class ErroEstado extends EstadoTela {
  const ErroEstado(this.mensagem);
  final String mensagem;
}

/// Borda: texto cru entra, objeto válido sai — ou exceção com contexto.
Sessao lerLinha(String linha) {
  final partes = linha.split(';');
  if (partes.length != 3) {
    throw SessaoInvalidaException(linha, 'esperado materia;minutos;status');
  }
  final materia = partes[0].trim();
  final minutos = int.tryParse(partes[1].trim());
  final status = StatusSessao.values.asNameMap()[partes[2].trim()];

  if (materia.isEmpty) throw SessaoInvalidaException(linha, 'matéria vazia');
  if (minutos == null || minutos <= 0 || minutos > 480) {
    throw SessaoInvalidaException(linha, 'minutos inválidos');
  }
  if (status == null) throw SessaoInvalidaException(linha, 'status desconhecido');

  return Sessao(materia: materia, minutos: minutos, status: status);
}

Future<Resultado<List<Sessao>, String>> carregar(List<String> linhas) async {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final validas = <Sessao>[];
  var descartadas = 0;
  for (final linha in linhas) {
    try {
      validas.add(lerLinha(linha));
    } on SessaoInvalidaException {
      descartadas++;
    }
  }
  if (validas.isEmpty) {
    return Falha('nenhuma sessão válida ($descartadas linhas descartadas)');
  }
  return Sucesso(validas);
}

({int total, double media}) resumir(List<Sessao> sessoes) {
  final concluidas =
      sessoes.where((s) => s.status == StatusSessao.concluida).toList();
  final total = concluidas.fold<int>(0, (soma, s) => soma + s.minutos);
  return (
    total: total,
    media: concluidas.isEmpty ? 0 : total / concluidas.length,
  );
}

Stream<int> progressoSemanal(List<Sessao> sessoes, int meta) async* {
  var acumulado = 0;
  for (final sessao in sessoes) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    acumulado += sessao.minutos;
    yield acumulado;
    if (acumulado >= meta) return;
  }
}

String render(EstadoTela estado) => switch (estado) {
      Carregando() => 'Carregando…',
      Vazio() => 'Nenhuma sessão concluída ainda.',
      ErroEstado(:final mensagem) => 'Falhou: $mensagem',
      SucessoEstado(:final sessoes, resumo: (:total, :media)) =>
        '${sessoes.length} sessões · $total min · média ${media.toStringAsFixed(1)} min',
    };

Future<void> main() async {
  const linhas = [
    'Dart;45;concluida',
    'Git;30;concluida',
    'Dart;abc;concluida',
    'Flutter;60;planejada',
    ';10;concluida',
  ];

  final repositorio = RepositorioMemoria<Sessao>();
  EstadoTela estado = const Carregando();
  print(render(estado));

  try {
    final resultado = await carregar(linhas).timeout(const Duration(seconds: 2));
    switch (resultado) {
      case Sucesso(:final valor):
        for (final sessao in valor) {
          repositorio.salvar(sessao);
        }
        final resumo = resumir(repositorio.listar());
        estado = resumo.total == 0
            ? const Vazio()
            : SucessoEstado(repositorio.listar(), resumo);
      case Falha(:final erro):
        estado = ErroEstado(erro);
    }
  } on TimeoutException {
    estado = const ErroEstado('tempo esgotado ao carregar as sessões');
  }
  print(render(estado));

  final assinatura = progressoSemanal(repositorio.listar(), 120)
      .listen((minutos) => print('progresso: $minutos/120 min'));
  await Future<void>.delayed(const Duration(milliseconds: 250));
  await assinatura.cancel();
  print('acompanhamento cancelado');
}
```

Saída esperada (a ordem do progresso depende do tempo, mas o cancelamento tem de encerrar o programa):

```text
Carregando…
3 sessões · 75 min · média 37.5 min
progresso: 45/120 min
progresso: 75/120 min
acompanhamento cancelado
```

O avaliador deve procurar três coisas: nenhuma linha inválida virando objeto (o `tryParse` e o
`asNameMap()` barram `abc` e a matéria vazia, e a exceção carrega a linha e o motivo), o `switch`
expressão de `render` **sem** `_` — apague uma das quatro subclasses de `EstadoTela` e o programa
tem de parar de compilar — e o `cancel()` da assinatura, sem o qual o `dart run` não encerra.
Vale conferir também que `repositorio.listar().add(...)` lança `UnsupportedError`: é a prova de
que a imutabilidade foi levada até a borda de saída, e não só declarada com `final`.

---

<a id="cumulativa-02"></a>
## Cumulativa 02 — Flutter UI

> Confira depois de fazer a [avaliação](../avaliacoes/cumulativa-02-flutter-ui.md).

### Questionário

1. **B** — o `context` do `build` que **cria** o `MaterialApp` está acima dele na árvore, então `Theme.of` não encontra o `Theme` do app e cai no padrão; `Theme.of` funciona igual em `StatelessWidget` (A), Material 3 já é o padrão do SDK (C) e a semente vale nos dois brilhos (D) — a correção é um `Builder` ou extrair um widget filho.
2. **B** — dentro de uma `Column` a altura oferecida é infinita e todo viewport rolável exige altura finita (`Expanded` resolve); A é estouro de flex com filhos de tamanho fixo, C é erro de ciclo de vida e D é nome de rota inexistente.
3. **B** — esse `await` dura o tempo que o usuário quiser e o widget pode ter saído da árvore no meio; `setState` (A) tem exatamente o mesmo problema, `dispose()` nunca é chamado na mão (C) e `pushReplacement` (D) destruiria justamente a tela que espera o resultado.
4. **A** — o `IndexedStack` mantém todos os filhos montados e só pinta o do índice, então cada `State` (rolagem, filtro, requisição feita) continua vivo; ele não grava nada em disco (B), `const` não preserva estado (C) e recriar o `State` (D) é o que o `switch` faria — o oposto do pedido.
5. **B** — o controller guarda estado fora do `build` e mantém ouvintes registrados, então nasce uma vez no `initState` e precisa ser liberado no `dispose`; `build` roda muitas vezes (A), `setState` não depende dele (C) e o `Navigator.pop` não libera objeto nenhum que seja seu (D).
6. **B** — `LayoutBuilder` entrega as restrições que **o pai** passou a este widget; `MediaQuery.sizeOf` (A) mede a tela inteira e erra dentro de um painel estreito, `Navigator.of` (C) não tem nada com layout e `OrientationBuilder` (D) só diz retrato ou paisagem.
7. **C** — busca que deu certo e voltou zero é vazio, e o vazio **por filtro** precisa oferecer o caminho de volta ("limpar filtro"); nada está carregando (A), nada falhou (B) e `TelaSucesso` com lista vazia (D) é justamente o estado ambíguo que o `sealed` existe para eliminar.
8. **B** — o `switch` concentra os nomes num lugar só e o `default` manda rota desconhecida para uma tela de erro em vez de tela preta; abas são preservadas pelo `IndexedStack` (A), validação é assunto do `Form` (C) e cada caso continua devolvendo um `MaterialPageRoute` (D).

9. `Navigator.pop(materia)` completa o `Future<Materia?>` devolvido por `pushNamed<Materia>` — e o valor só chega inteiro se o `MaterialPageRoute<Materia>` criado no `onGenerateRoute` tiver o mesmo tipo; se o genérico não bate, o resultado some em silêncio. Assim que o `await` retorna, antes de qualquer uso de `context` ou `setState`, entra o guard (`mounted` dentro do `State`, `context.mounted` fora dele) com `return` se a tela já saiu da árvore. Com a matéria em mãos você salva no repositório, refaz a busca e um `setState` troca o estado por `TelaSucesso`, o que redesenha a lista; o `SnackBar` confirma. `null` significa que o usuário voltou sem salvar: é o caminho mais comum, não um erro — apenas `return`, sem mexer no estado e sem mensagem.
   *Pontuação:* 0,25 pelo tipo da rota casando com o `pushNamed<Materia>`; 0,25 pelo guard logo depois do `await`; 0,25 por descrever o novo estado + `setState` redesenhando a lista; 0,25 por tratar `null` como desistência.
10. O método roda **dentro** do `build` do pai: não ganha `Element` próprio, não pode ser `const`, não aceita `key`, não aparece nomeado no Flutter Inspector e não dá para testar isolado com `pumpWidget`. O widget extraído tem tudo isso — e, quando é `const`, o Flutter compara por `identical()` e pula a subárvore inteira. Na `ListView.builder` com 300 matérias, os dois constroem só os ~10 itens visíveis (quem faz isso é o `builder`, não a extração); a diferença aparece a cada rebuild do pai — digitar no filtro, terminar uma recarga: com método, a subárvore de cada linha visível é reconstruída inteira; com widget, as partes `const` são reaproveitadas e cada linha tem `key` própria, o que mantém estado e animação no lugar quando a lista reordena.
    *Pontuação:* 0,5 pela diferença estrutural (`Element` próprio, `const`, `key`, teste isolado); 0,5 pelo efeito correto na lista. Desconte a metade final de quem afirmar que o método "constrói as 300 linhas de uma vez" — isso é problema de `shrinkWrap`/`children:`, não de extração.
11. O que produz os quatro estados não é a API: é a **assincronia**. A busca de matérias já é um `Future` com o repositório falso, e vira `http` no Módulo 09 e `sqflite` no Módulo 10 sem a tela mudar uma linha — quem começa com `bool carregando` + `String? erro` + lista solta reescreve a tela depois e ainda entrega tela branca no caminho. Gatilhos no Foco: `TelaCarregando` na primeira busca (`initState`, troca de filtro, "tentar de novo"); `TelaSucesso` quando volta ao menos uma matéria, com `recarregando: true` no puxar-para-atualizar para não perder lista nem rolagem; `TelaVazia(porFiltro: false)` quando o aluno ainda não cadastrou nada e `TelaVazia(porFiltro: true)` quando o filtro "Matemática" não bateu; `TelaFalha` quando a busca lança, com mensagem de gente e botão "Tentar de novo".
    *Pontuação:* 0,5 pelo motivo (assincronia já existe; trocar a fonte não deve reescrever a tela); 0,5 pelos quatro gatilhos — e só conte esse meio ponto se a resposta separar vazio inicial de vazio por filtro.
12. `Navigator.pop` tira a rota da pilha e o framework chama `dispose()` do `State`, mas ele destrói apenas o que é dele. `TextEditingController` e `FocusNode` são `ChangeNotifier` com ouvintes registrados (os próprios campos, o `FocusManager`): sem `.dispose()` eles continuam vivos enquanto alguém os referenciar, segurando listeners e memória — o vazamento acontece com a tela já fechada. Regra do curso: tudo que nasce no `initState` (ou em campo `late final`) morre no `dispose`, e `super.dispose()` vem por último. Quando algo ainda vivo — `Timer`, listener, `Future` que voltou tarde — tenta redesenhar a tela fechada, o erro é `setState() called after dispose()`; se em vez de `setState` for uso de `context`, aparece `Looking up a deactivated widget's ancestor is unsafe`.
    *Pontuação:* 0,5 pela razão (o framework libera o `State`, não os seus objetos; ouvintes vivos = vazamento); 0,25 por citar `setState() called after dispose()`; 0,25 pela disciplina `initState` ↔ `dispose`. Aceite a menção a `if (!mounted) return` como rede complementar, nunca como substituta do `dispose`.

### Solução prática de referência

```dart
// ─── lib/main.dart ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:foco_navegacao/core/rotas/rotas.dart';
import 'package:foco_navegacao/core/tema/tema_app.dart';

void main() => runApp(const AppFoco());

class AppFoco extends StatelessWidget {
  const AppFoco({super.key});

  @override
  Widget build(BuildContext context) {
    // Atenção: este `context` está ACIMA do MaterialApp. `Theme.of(context)`
    // aqui devolveria o tema padrão, não o do app.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modoDeTema,
      builder: (BuildContext context, ThemeMode modo, Widget? _) => MaterialApp(
        title: 'Foco',
        theme: TemaApp.claro,
        darkTheme: TemaApp.escuro,
        themeMode: modo,
        initialRoute: Rotas.home,
        onGenerateRoute: Rotas.gerar,
        onUnknownRoute: Rotas.desconhecida, // segunda rede de proteção
      ),
    );
  }
}

// ─── lib/core/tema/tema_app.dart ───────────────────────────────────────────
import 'package:flutter/material.dart';

/// Modo de tema escolhido pelo aluno na aba Ajustes.
///
/// Estado global provisório: no Módulo 08 ele vira um provider do Riverpod.
/// Até lá, um `ValueNotifier` resolve sem acrescentar dependência nenhuma.
final ValueNotifier<ThemeMode> modoDeTema =
    ValueNotifier<ThemeMode>(ThemeMode.system);

/// Espaço de nomes dos dois temas. Nunca é instanciada.
abstract final class TemaApp {
  static const Color _semente = Color(0xFF3F51B5);

  // `static final`: cada ThemeData é montado uma vez, não a cada build.
  static final ThemeData claro = _construir(Brightness.light);
  static final ThemeData escuro = _construir(Brightness.dark);

  /// Material 3 nas duas plataformas, a paleta inteira saindo de uma semente.
  /// Só o brilho muda entre claro e escuro.
  static ThemeData _construir(Brightness brilho) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _semente,
          brightness: brilho,
        ),
      );
}

// ─── lib/core/rotas/rotas.dart ─────────────────────────────────────────────
import 'package:flutter/material.dart';

import 'package:foco_navegacao/features/home/presentation/home_screen.dart';
import 'package:foco_navegacao/features/materias/domain/materia.dart';
import 'package:foco_navegacao/features/materias/presentation/materia_form_screen.dart';

/// Todos os nomes de rota do app em um lugar só.
///
/// `abstract` impede instanciar; `final` impede herdar. É espaço de nomes.
abstract final class Rotas {
  static const String home = '/';
  static const String materiaForm = '/materia/form';

  static Route<dynamic> gerar(RouteSettings configuracoes) {
    switch (configuracoes.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: configuracoes, // sem isto a rota perde nome e argumentos
          builder: (_) => const HomeScreen(),
        );

      case materiaForm:
        final Object? args = configuracoes.arguments;
        // Valida ANTES de usar: nada de `as MateriaFormArgs`.
        if (args is! MateriaFormArgs) return desconhecida(configuracoes);
        // O <Materia> precisa bater com o pushNamed<Materia> de quem chama,
        // senão o pop(materia) some em silêncio.
        return MaterialPageRoute<Materia>(
          settings: configuracoes,
          fullscreenDialog: true, // tarefa que começa e termina aqui
          builder: (_) => MateriaFormScreen(args: args),
        );

      default:
        return desconhecida(configuracoes);
    }
  }

  /// Usada pelo `default` acima e por `onUnknownRoute`.
  static Route<dynamic> desconhecida(RouteSettings configuracoes) =>
      MaterialPageRoute<void>(
        settings: configuracoes,
        builder: (_) => RotaDesconhecidaScreen(nome: configuracoes.name),
      );
}

class RotaDesconhecidaScreen extends StatelessWidget {
  const RotaDesconhecidaScreen({required this.nome, super.key});

  final String? nome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela não encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.wrong_location_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                'A rota "$nome" não existe.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(Rotas.home, (_) => false),
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── lib/core/estado/estado_tela.dart ──────────────────────────────────────
/// Os estados possíveis de uma tela que carrega dados.
///
/// Sendo `sealed`, o compilador EXIGE que todo `switch` trate os quatro casos.
/// Um quinto estado quebra a compilação de quem não o tratou — que é
/// exatamente o comportamento desejado.
sealed class EstadoTela<T> {
  const EstadoTela();
}

/// Buscando pela primeira vez. Não há dados para mostrar.
final class TelaCarregando<T> extends EstadoTela<T> {
  const TelaCarregando();
}

/// Deu certo e veio conteúdo.
final class TelaSucesso<T> extends EstadoTela<T> {
  const TelaSucesso(this.dados, {this.recarregando = false});

  final T dados;

  /// Recarga em andamento COM dados na tela: barra fina, não spinner.
  final bool recarregando;
}

/// Deu certo, mas não há nada. O motivo muda o texto mostrado.
final class TelaVazia<T> extends EstadoTela<T> {
  const TelaVazia({this.porFiltro = false});

  final bool porFiltro;
}

/// Falhou. A mensagem já vem traduzida para o usuário.
final class TelaFalha<T> extends EstadoTela<T> {
  const TelaFalha(this.mensagem, {this.detalheTecnico});

  final String mensagem;
  final String? detalheTecnico;
}

// ─── lib/core/widgets/estados_ui.dart ──────────────────────────────────────
import 'package:flutter/material.dart';

/// Esqueleto da lista enquanto a primeira busca não volta.
/// É rolável de propósito: o `RefreshIndicator` precisa de um filho rolável.
class EsqueletoLista extends StatelessWidget {
  const EsqueletoLista({this.linhas = 6, super.key});

  final int linhas;

  @override
  Widget build(BuildContext context) {
    final Color cor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: linhas,
      itemBuilder: (BuildContext context, int i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 14, width: 160, color: cor),
                  const SizedBox(height: 8),
                  Container(height: 8, color: cor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Moldura comum dos estados sem lista: centraliza, rola quando a tela é
/// baixa (teclado aberto, celular deitado) e nunca estoura.
class _Moldura extends StatelessWidget {
  const _Moldura({required this.filhos});

  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints restricoes) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: restricoes.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: filhos,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Vazio por falta de dados e vazio por filtro são estados DIFERENTES:
/// mesmo widget, textos e ações diferentes.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio.inicial({required VoidCallback aoCriar, super.key})
      : _icone = Icons.menu_book_outlined,
        _titulo = 'Nenhuma matéria ainda',
        _mensagem = 'Cadastre a primeira matéria para começar a marcar sessões.',
        _rotulo = 'Adicionar matéria',
        _aoAgir = aoCriar;

  const EstadoVazio.semResultado({required VoidCallback aoLimpar, super.key})
      : _icone = Icons.search_off,
        _titulo = 'Nenhuma matéria encontrada',
        _mensagem = 'O filtro atual não bateu com nenhuma matéria cadastrada.',
        _rotulo = 'Limpar filtro',
        _aoAgir = aoLimpar;

  final IconData _icone;
  final String _titulo;
  final String _mensagem;
  final String _rotulo;
  final VoidCallback _aoAgir;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return _Moldura(
      filhos: <Widget>[
        Icon(_icone, size: 56, color: tema.colorScheme.outline),
        const SizedBox(height: 16),
        Text(_titulo, style: tema.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(_mensagem, style: tema.textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        FilledButton(onPressed: _aoAgir, child: Text(_rotulo)),
      ],
    );
  }
}

/// Erro que o usuário consegue resolver: diz o que houve e oferece a saída.
class EstadoErro extends StatelessWidget {
  const EstadoErro({
    required this.mensagem,
    required this.onTentarDeNovo,
    this.detalheTecnico,
    super.key,
  });

  final String mensagem;
  final String? detalheTecnico;
  final VoidCallback onTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final String? detalhe = detalheTecnico;

    return _Moldura(
      filhos: <Widget>[
        Icon(Icons.cloud_off_outlined, size: 56, color: tema.colorScheme.error),
        const SizedBox(height: 16),
        Text('Algo deu errado', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(mensagem, style: tema.textTheme.bodyMedium, textAlign: TextAlign.center),
        if (detalhe != null) ...<Widget>[
          const SizedBox(height: 8),
          // Detalhe técnico discreto: ajuda você, não assusta o usuário.
          Text(
            detalhe,
            style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.outline),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onTentarDeNovo,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar de novo'),
        ),
      ],
    );
  }
}

// ─── lib/features/materias/domain/materia.dart ─────────────────────────────
import 'package:flutter/material.dart' show IconData, Icons;

/// Uma matéria de estudo do Foco, com meta diária e progresso.
class Materia {
  const Materia({
    required this.id,
    required this.nome,
    required this.minutosEstudados,
    required this.metaMinutos,
    this.icone = Icons.menu_book_outlined,
  }) : assert(metaMinutos > 0, 'A meta precisa ser maior que zero');

  final String id;
  final String nome;
  final int minutosEstudados;
  final int metaMinutos;
  final IconData icone;

  /// Progresso entre 0.0 e 1.0, pronto para a barra de progresso.
  double get progresso => (minutosEstudados / metaMinutos).clamp(0.0, 1.0);

  bool get concluida => minutosEstudados >= metaMinutos;

  Materia copyWith({String? nome, int? minutosEstudados, int? metaMinutos}) {
    return Materia(
      id: id,
      nome: nome ?? this.nome,
      minutosEstudados: minutosEstudados ?? this.minutosEstudados,
      metaMinutos: metaMinutos ?? this.metaMinutos,
      icone: icone,
    );
  }
}

// ─── lib/features/materias/data/materias_repositorio.dart ──────────────────
import 'package:flutter/material.dart' show Icons;

import 'package:foco_navegacao/features/materias/domain/materia.dart';

/// Fonte de dados em memória.
///
/// No Módulo 09 o corpo destes métodos vira `http`, e no Módulo 10, `sqflite`.
/// A tela não muda: ela só conhece `Future<List<Materia>>`.
class MateriasRepositorio {
  MateriasRepositorio._();

  static final MateriasRepositorio instancia = MateriasRepositorio._();

  final List<Materia> _memoria = <Materia>[
    const Materia(id: 'dart', nome: 'Dart', minutosEstudados: 95, metaMinutos: 120),
    const Materia(
      id: 'flutter',
      nome: 'Flutter',
      minutosEstudados: 40,
      metaMinutos: 120,
      icone: Icons.phone_android,
    ),
    const Materia(
      id: 'git',
      nome: 'Git e terminal',
      minutosEstudados: 95,
      metaMinutos: 90,
      icone: Icons.terminal,
    ),
  ];

  Future<List<Materia>> buscar({String filtro = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final String alvo = filtro.trim().toLowerCase();
    if (alvo.isEmpty) return List<Materia>.unmodifiable(_memoria);
    return List<Materia>.unmodifiable(
      _memoria.where((Materia m) => m.nome.toLowerCase().contains(alvo)),
    );
  }

  Future<void> salvar(Materia materia) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final int i = _memoria.indexWhere((Materia m) => m.id == materia.id);
    if (i == -1) {
      _memoria.add(materia);
    } else {
      _memoria[i] = materia;
    }
  }
}

// ─── lib/features/materias/presentation/widgets/materia_tile.dart ──────────
import 'package:flutter/material.dart';

import 'package:foco_navegacao/features/materias/domain/materia.dart';

/// Uma linha da lista de matérias.
///
/// Widget extraído (não método): tem `Element` próprio, construtor `const`,
/// aceita `key` e pode ser testado sozinho com `pumpWidget`.
class MateriaTile extends StatelessWidget {
  const MateriaTile({required this.materia, this.onTap, super.key});

  final Materia materia;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme cores = tema.colorScheme;
    final String legenda =
        '${materia.minutosEstudados}/${materia.metaMinutos} min';

    // InkWell por FORA do Padding: a onda cobre a linha inteira.
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // LayoutBuilder, não MediaQuery: o que decide é o espaço que ESTE
        // tile recebeu — ele também aparece dentro de painel estreito.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints restricoes) {
            final bool estreito = restricoes.maxWidth < 360;

            return Row(
              children: <Widget>[
                _Avatar(materia: materia),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        materia.nome,
                        style: tema.textTheme.titleMedium,
                        // Sem isso, um nome longo estoura a Row em 320 px.
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: materia.progresso,
                          minHeight: 6,
                        ),
                      ),
                      if (estreito) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(legenda, style: tema.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                // Em tela larga a legenda volta para a direita, alinhada.
                if (!estreito) ...<Widget>[
                  const SizedBox(width: 12),
                  Text(
                    legenda,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: cores.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.materia});

  final Materia materia;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final bool ok = materia.concluida;

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ok ? cores.tertiaryContainer : cores.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        ok ? Icons.check : materia.icone,
        size: 22,
        color: ok ? cores.onTertiaryContainer : cores.onPrimaryContainer,
      ),
    );
  }
}

// ─── lib/features/materias/presentation/materias_tab.dart ──────────────────
import 'package:flutter/material.dart';

import 'package:foco_navegacao/core/estado/estado_tela.dart';
import 'package:foco_navegacao/core/rotas/rotas.dart';
import 'package:foco_navegacao/core/widgets/estados_ui.dart';
import 'package:foco_navegacao/features/materias/data/materias_repositorio.dart';
import 'package:foco_navegacao/features/materias/domain/materia.dart';
import 'package:foco_navegacao/features/materias/presentation/materia_form_screen.dart';
import 'package:foco_navegacao/features/materias/presentation/widgets/materia_tile.dart';

class MateriasTab extends StatefulWidget {
  const MateriasTab({super.key});

  @override
  State<MateriasTab> createState() => _MateriasTabState();
}

class _MateriasTabState extends State<MateriasTab> {
  // UM campo guarda TODO o estado da tela. Não existe
  // `bool _carregando` + `String? _erro` + `List _dados` se contradizendo.
  EstadoTela<List<Materia>> _estado = const TelaCarregando<List<Materia>>();

  final TextEditingController _busca = TextEditingController();
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _buscar({bool recarga = false}) async {
    final EstadoTela<List<Materia>> atual = _estado;

    // Recarga preserva os dados na tela; a carga inicial não tem o que manter.
    if (recarga && atual is TelaSucesso<List<Materia>>) {
      setState(() {
        _estado = TelaSucesso<List<Materia>>(atual.dados, recarregando: true);
      });
    } else {
      setState(() => _estado = const TelaCarregando<List<Materia>>());
    }

    try {
      final List<Materia> lista =
          await MateriasRepositorio.instancia.buscar(filtro: _filtro);
      if (!mounted) return; // sempre depois de um await

      setState(() {
        _estado = lista.isEmpty
            // O MOTIVO do vazio faz parte do estado e muda o texto.
            ? TelaVazia<List<Materia>>(porFiltro: _filtro.trim().isNotEmpty)
            : TelaSucesso<List<Materia>>(lista);
      });
    } on Exception catch (erro, pilha) {
      debugPrint('Falha ao buscar matérias: $erro\n$pilha'); // log é para você
      if (!mounted) return;
      setState(() {
        _estado = TelaFalha<List<Materia>>(
          'Não conseguimos carregar suas matérias agora.',
          detalheTecnico: '$erro',
        );
      });
    }
  }

  void _filtrar(String texto) {
    setState(() => _filtro = texto);
    _buscar();
  }

  void _limparFiltro() {
    _busca.clear();
    _filtrar('');
  }

  Future<void> _abrirFormulario({Materia? original}) async {
    // Argumento TIPADO na ida; resultado tipado na volta.
    final Materia? salva = await Navigator.of(context).pushNamed<Materia>(
      Rotas.materiaForm,
      arguments: original == null
          ? const MateriaFormArgs.criar()
          : MateriaFormArgs.editar(original),
    );

    // O formulário pode ter ficado aberto por minutos: o widget pode ter saído
    // da árvore. Dentro de um State o guard é `mounted` (é o que o lint
    // `use_build_context_synchronously` cobra); fora dele, `context.mounted`.
    if (!mounted) return;

    // null = o usuário voltou sem salvar. É o caso mais comum, não um erro.
    if (salva == null) return;

    await MateriasRepositorio.instancia.salvar(salva);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('"${salva.nome}" salva')));

    await _buscar();
  }

  @override
  Widget build(BuildContext context) {
    final bool recarregando = switch (_estado) {
      TelaSucesso<List<Materia>>(recarregando: final bool r) => r,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matérias'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          // Recarga com dados na tela: barra fina, a lista não pisca.
          child: SizedBox(
            height: 4,
            child: recarregando ? const LinearProgressIndicator() : null,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        tooltip: 'Adicionar matéria',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _busca,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Filtrar matérias',
                  hintText: 'Ex.: Matemática',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _filtro.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar filtro',
                          icon: const Icon(Icons.clear),
                          onPressed: _limparFiltro,
                        ),
                ),
                onSubmitted: _filtrar,
              ),
            ),
            // Expanded dá altura FINITA à lista: é a correção do
            // "Vertical viewport was given unbounded height".
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _buscar(recarga: true),
                // O coração da tela: um switch exaustivo sobre o estado.
                // Apagar um caso é erro de compilação, não tela branca.
                child: switch (_estado) {
                  TelaCarregando<List<Materia>>() => const EsqueletoLista(),
                  TelaFalha<List<Materia>>(
                    mensagem: final String msg,
                    detalheTecnico: final String? detalhe,
                  ) =>
                    EstadoErro(
                      mensagem: msg,
                      detalheTecnico: detalhe,
                      onTentarDeNovo: _buscar,
                    ),
                  // O padrão mais específico vem ANTES do genérico.
                  TelaVazia<List<Materia>>(porFiltro: true) =>
                    EstadoVazio.semResultado(aoLimpar: _limparFiltro),
                  TelaVazia<List<Materia>>() =>
                    EstadoVazio.inicial(aoCriar: _abrirFormulario),
                  TelaSucesso<List<Materia>>(dados: final List<Materia> lista) =>
                    _ListaMaterias(materias: lista, aoTocar: _abrirFormulario),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaMaterias extends StatelessWidget {
  const _ListaMaterias({required this.materias, required this.aoTocar});

  final List<Materia> materias;
  final void Function({Materia? original}) aoTocar;

  @override
  Widget build(BuildContext context) {
    // Em 1600 px a linha não atravessa o monitor inteiro; em 320 px o
    // ConstrainedBox não faz nada. Um widget resolve as duas pontas.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: materias.length, // sem itemCount a lista é infinita
          itemBuilder: (BuildContext context, int i) {
            final Materia materia = materias[i];
            return Column(
              children: <Widget>[
                MateriaTile(
                  key: ValueKey<String>(materia.id), // o id, nunca o índice
                  materia: materia,
                  onTap: () => aoTocar(original: materia),
                ),
                if (i < materias.length - 1)
                  const Divider(height: 1, indent: 72, endIndent: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── lib/features/materias/presentation/materia_form_screen.dart ───────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:foco_navegacao/features/materias/domain/materia.dart';

/// Convenção do curso: a classe de argumentos mora no arquivo da tela que a
/// recebe, com o sufixo `Args`. Tipada — nada de `Map<String, dynamic>`.
class MateriaFormArgs {
  const MateriaFormArgs.criar() : original = null;
  const MateriaFormArgs.editar(Materia materia) : original = materia;

  final Materia? original;
}

class MateriaFormScreen extends StatefulWidget {
  const MateriaFormScreen({required this.args, super.key});

  final MateriaFormArgs args;

  @override
  State<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends State<MateriaFormScreen> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();

  late final String _nomeOriginal = widget.args.original?.nome ?? '';
  late final String _metaOriginal =
      widget.args.original?.metaMinutos.toString() ?? '';

  // Nascem aqui (campo `late final`, avaliado antes do primeiro build) e
  // morrem no dispose. Guardam estado fora do build e mantêm ouvintes vivos.
  late final TextEditingController _nome =
      TextEditingController(text: _nomeOriginal);
  late final TextEditingController _meta =
      TextEditingController(text: _metaOriginal);
  final FocusNode _focoMeta = FocusNode();

  AutovalidateMode _modo = AutovalidateMode.disabled;

  // Getter, não `late final`: precisa ser recalculado a cada tecla.
  bool get _sujo => _nome.text != _nomeOriginal || _meta.text != _metaOriginal;

  @override
  void dispose() {
    _nome.dispose();
    _meta.dispose();
    _focoMeta.dispose();
    super.dispose();
  }

  void _salvar() {
    FocusScope.of(context).unfocus();

    if (!(_chave.currentState?.validate() ?? false)) {
      // Na primeira falha liga a autovalidação: o erro some enquanto corrige.
      setState(() => _modo = AutovalidateMode.onUserInteraction);
      return;
    }

    final Materia? original = widget.args.original;
    final Materia salva = Materia(
      id: original?.id ?? 'm${DateTime.now().microsecondsSinceEpoch}',
      nome: _nome.text.trim(),
      minutosEstudados: original?.minutosEstudados ?? 0,
      metaMinutos: int.parse(_meta.text.trim()),
      icone: original?.icone ?? Icons.menu_book_outlined,
    );

    // Devolve o OBJETO salvo, não `true`: a lista não precisa adivinhar nada.
    Navigator.of(context).pop(salva);
  }

  Future<bool> _confirmarDescarte() async {
    final bool? descartar = await showDialog<bool>(
      context: context,
      builder: (BuildContext contexto) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você preencheu será perdido.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return descartar ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bool editando = widget.args.original != null;

    // O <Materia> casa com o pushNamed<Materia> e com o MaterialPageRoute.
    return PopScope<Materia>(
      canPop: !_sujo,
      onPopInvokedWithResult: (bool saiu, Materia? resultado) async {
        if (saiu) return;
        final bool descartar = await _confirmarDescarte();
        if (descartar && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editando ? 'Editar matéria' : 'Nova matéria'),
        ),
        body: SafeArea(
          child: Form(
            key: _chave,
            autovalidateMode: _modo,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                TextFormField(
                  controller: _nome,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nome da matéria',
                    hintText: 'Ex.: Cálculo I',
                    helperText: 'Como ela aparece na lista',
                  ),
                  textCapitalization: TextCapitalization.words,
                  // Foco encadeado: Enter/Próximo pula para a meta.
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}), // mantém `canPop` atual
                  onFieldSubmitted: (_) => _focoMeta.requestFocus(),
                  validator: (String? valor) {
                    final String texto = (valor ?? '').trim();
                    if (texto.isEmpty) return 'Informe o nome da matéria';
                    if (texto.length < 2) return 'Use pelo menos 2 letras';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _meta,
                  focusNode: _focoMeta,
                  decoration: const InputDecoration(
                    labelText: 'Meta diária',
                    hintText: 'Ex.: 45',
                    helperText: 'Quantos minutos por dia você quer estudar',
                    suffixText: 'min',
                  ),
                  keyboardType: TextInputType.number,
                  // keyboardType só sugere o teclado; o filtro é que garante.
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _salvar(),
                  validator: (String? valor) {
                    final int? minutos = int.tryParse((valor ?? '').trim());
                    if (minutos == null) return 'Informe a meta em minutos';
                    if (minutos < 5 || minutos > 480) {
                      return 'Informe um valor entre 5 e 480 minutos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _salvar,
                  child: Text(editando ? 'Salvar alterações' : 'Criar matéria'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── lib/features/home/presentation/home_screen.dart ───────────────────────
import 'package:flutter/material.dart';

import 'package:foco_navegacao/features/ajustes/presentation/ajustes_tab.dart';
import 'package:foco_navegacao/features/hoje/presentation/hoje_tab.dart';
import 'package:foco_navegacao/features/materias/presentation/materias_tab.dart';
import 'package:foco_navegacao/features/trilhas/presentation/trilhas_tab.dart';

/// Uma seção do app.
class _Secao {
  const _Secao({
    required this.rotulo,
    required this.icone,
    required this.iconeSelecionado,
    required this.tela,
  });

  final String rotulo;
  final IconData icone;
  final IconData iconeSelecionado;
  final Widget tela;
}

/// Casca do app: a navegação de PRIMEIRO nível.
///
/// Trocar de seção aqui não empilha rota — é mudança de contexto, não de
/// profundidade. Cada aba traz o próprio `Scaffold` (AppBar e FAB próprios).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;

  static const List<_Secao> _secoes = <_Secao>[
    _Secao(
      rotulo: 'Hoje',
      icone: Icons.today_outlined,
      iconeSelecionado: Icons.today,
      tela: HojeTab(),
    ),
    _Secao(
      rotulo: 'Matérias',
      icone: Icons.menu_book_outlined,
      iconeSelecionado: Icons.menu_book,
      tela: MateriasTab(),
    ),
    _Secao(
      rotulo: 'Trilhas',
      icone: Icons.route_outlined,
      iconeSelecionado: Icons.route,
      tela: TrilhasTab(),
    ),
    _Secao(
      rotulo: 'Ajustes',
      icone: Icons.settings_outlined,
      iconeSelecionado: Icons.settings,
      tela: AjustesTab(),
    ),
  ];

  void _selecionar(int i) => setState(() => _indice = i);

  @override
  Widget build(BuildContext context) {
    // Ponto de corte do Material 3 (Módulo 06, aula 11). `sizeOf` não
    // reconstrói quando só o teclado sobe.
    final bool telaLarga = MediaQuery.sizeOf(context).width >= 600;

    return PopScope<Object?>(
      // O gesto de voltar só sai do app quando já estamos na primeira aba.
      canPop: _indice == 0,
      onPopInvokedWithResult: (bool saiu, Object? resultado) {
        if (saiu) return;
        _selecionar(0);
      },
      child: Scaffold(
        body: Row(
          children: <Widget>[
            if (telaLarga) ...<Widget>[
              NavigationRail(
                selectedIndex: _indice,
                onDestinationSelected: _selecionar,
                labelType: NavigationRailLabelType.all,
                destinations: <NavigationRailDestination>[
                  for (final _Secao s in _secoes)
                    NavigationRailDestination(
                      icon: Icon(s.icone),
                      selectedIcon: Icon(s.iconeSelecionado),
                      label: Text(s.rotulo),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
            ],
            Expanded(
              // IndexedStack mantém TODAS as abas montadas e só PINTA a do
              // índice: rolagem, texto do filtro e busca já feita sobrevivem
              // à troca. Com `_secoes[_indice].tela` tudo isso se perderia.
              child: IndexedStack(
                index: _indice,
                children: <Widget>[
                  for (final _Secao s in _secoes) s.tela,
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: telaLarga
            ? null
            : NavigationBar(
                selectedIndex: _indice,
                onDestinationSelected: _selecionar,
                destinations: <Widget>[
                  for (final _Secao s in _secoes)
                    NavigationDestination(
                      icon: Icon(s.icone),
                      selectedIcon: Icon(s.iconeSelecionado),
                      label: s.rotulo,
                    ),
                ],
              ),
      ),
    );
  }
}

// ─── lib/features/hoje/presentation/hoje_tab.dart ──────────────────────────
import 'package:flutter/material.dart';

/// Placeholder rolável: é com ele que você prova, na banca, que o
/// `IndexedStack` preserva a rolagem ao trocar de aba e voltar.
class HojeTab extends StatelessWidget {
  const HojeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoje')),
      body: ListView.builder(
        itemCount: 40,
        itemBuilder: (BuildContext context, int i) => ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: Text('Sessão de estudo ${i + 1}'),
          subtitle: const Text('25 min · Pomodoro'),
        ),
      ),
    );
  }
}

// ─── lib/features/trilhas/presentation/trilhas_tab.dart ────────────────────
import 'package:flutter/material.dart';

class TrilhasTab extends StatelessWidget {
  const TrilhasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trilhas')),
      body: const Center(child: Text('Trilhas de estudo chegam no Módulo 08.')),
    );
  }
}

// ─── lib/features/ajustes/presentation/ajustes_tab.dart ────────────────────
import 'package:flutter/material.dart';

import 'package:foco_navegacao/core/tema/tema_app.dart';

/// Onde o `themeMode` deixa de ser enfeite: o aluno escolhe e o app inteiro
/// muda, sem reiniciar.
class AjustesTab extends StatelessWidget {
  const AjustesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Aparência', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: modoDeTema,
            builder: (BuildContext context, ThemeMode modo, Widget? _) {
              return SegmentedButton<ThemeMode>(
                segments: const <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('Sistema'),
                    icon: Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Claro'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Escuro'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: <ThemeMode>{modo},
                onSelectionChanged: (Set<ThemeMode> escolha) =>
                    modoDeTema.value = escolha.first,
              );
            },
          ),
        ],
      ),
    );
  }
}
```

O avaliador deve procurar cinco coisas antes de olhar o visual: `settings: configuracoes` em **todas** as rotas e o `<Materia>` do `MaterialPageRoute` casando com o `pushNamed<Materia>` (sem isso o `pop(salva)` some em silêncio); `is!` no lugar de `as` na leitura dos argumentos, com `default` levando à `RotaDesconhecidaScreen`; um `switch` **exaustivo** sobre `EstadoTela<List<Materia>>` com `TelaVazia(porFiltro: true)` **antes** do caso genérico e nenhum `bool _carregando`/`String? _erro` sobrando no `State`; um `dispose()` para cada `TextEditingController` e cada `FocusNode`, mais o `PopScope` de descarte com `canPop` recalculado por getter; e o guard depois de cada `await` — aceite `mounted` ou `context.mounted`, desde que `flutter analyze` termine com `No issues found!` e sem `use_build_context_synchronously`. Redimensione a janela de 320 px a 1600 px em cada um dos quatro estados: o `LayoutBuilder` do tile deve trocar a legenda de lugar sem estourar, e trocar de aba e voltar precisa devolver a rolagem e o texto do filtro exatamente onde estavam — se não devolver, o aluno usou `switch` no lugar do `IndexedStack`.

---

<a id="cumulativa-03"></a>
## Cumulativa 03 — Estado e dados

> Confira depois de fazer a [avaliação](../avaliacoes/cumulativa-03-estado-e-dados.md).

### Questionário

1. **B** — o Riverpod aceita qualquer tipo (A), `autoDispose` não exige nada disso (C) e quem mantém `package:http` fora do `domain/` é a regra de dependência, não o tipo do provider (D).
2. **B** — no controller (A) ou dentro do `AsyncValue.guard` (C) você só desiste de esperar, com o socket ainda aberto e a requisição ainda viajando; e o `Provider<http.Client>` (D) cria a conexão, não tem onde pendurar prazo de requisição.
3. **B** — A desperdiça justamente a requisição que o TTL existe para evitar, C joga fora dado ainda válido e D é a tela branca que o *stale-while-revalidate* veio eliminar.
4. **B** — A troca dados visíveis por tela de erro, C apaga o único conteúdo que restou ao usuário e D decide com `connectivity_plus`, que só sabe dizer se existe interface de rede.
5. **B** — A e C confundem trocar a implementação com mudar a API pública: a assinatura `Future<List<Trilha>> listar()` não mudou, e D trocaria o tipo do estado sem motivo, já que a operação continua assíncrona.
6. **B** — o `query` (A) lê a coluna `conteudo`, que não mudou; o `onUpgrade` (C) migra esquema, não conteúdo de JSON já gravado; e o `guard` (D) não valida mapa nenhum, só embrulha o que for lançado.
7. **B** — A e C são falsos sobre o SQLite (ele aceita `TEXT` de qualquer tamanho e indexa qualquer coluna) e D confunde transporte com armazenamento; o problema real é o `.db` ser arquivo comum, legível e copiado em backup.
8. **B** — no `build` do widget (A) o efeito repete a cada reconstrução, no `Future build()` do `AsyncNotifier` (C) não existe `BuildContext` para o `SnackBar`, e o `initState` (D) roda uma vez só, nunca na volta da conexão.

9. O `.timeout(Prazos.leitura)` fica grudado na chamada do `http.Client`, dentro do `TrilhaApi` — é o único ponto que conhece a operação de I/O que pode travar, e só ali ele de fato abandona a requisição em vez de deixá-la viajando. O `TimeoutException` sobe até o `TrilhaRepositorio`, que o traduz em `FalhaTempoEsgotado` junto com `SocketException`, `ApiException` e `FormatException`; daí para cima o app só fala `Falha`. O controller não trata prazo nenhum: o `AsyncValue.guard` apenas embrulha o que chegou em `AsyncError`, com os dados antigos preservados por `copyWithPrevious`.
   *Pontuação (1 ponto):* 0,5 por colocar o timeout na chamada HTTP do service, antes do `jsonDecode`; 0,5 por explicar a tradução em `Falha` no repositório e o papel meramente de embrulho do `guard`. Zero se puser o prazo no controller ou disser que o `guard` cancela a requisição.

10. O `TrilhaApi` monta URL e cabeçalhos, aplica `.timeout`, confere a faixa `2xx` e decodifica o JSON — e nunca toca em sqflite, nunca decide cache e nunca lança `Falha`. O `TrilhaCacheDao` grava e lê o JSON com o carimbo `buscado_em`, invalida e limpa o antigo — e nunca vai à rede, nunca traduz erro e nunca decide se o dado ainda serve: ele só informa a idade. O `TrilhaRepositorio` orquestra os dois, aplica TTL e *stale-while-revalidate* e traduz toda exceção em `Falha` — e nunca monta URL, nunca escreve SQL, nunca importa `material.dart`. O `AsyncNotifier` não importa nenhum dos três pela classe concreta: o único que ele toca é o repositório, e pelo `TrilhaRepositorioContrato`, via `trilhaRepositorioProvider`.
    *Pontuação (1 ponto):* 0,25 para cada uma das três descrições com o respectivo "nunca faz", e 0,25 pela última frase. Não vale metade se o aluno disser que o `AsyncNotifier` importa `TrilhaRepositorio` (a classe) — o ponto inteiro da cadeia é o contrato.

11. Porque o `domain/` é o centro: todas as setas apontam para ele e ele não depende de ninguém. `material.dart` amarraria a regra de negócio à tela, `package:http` a um transporte e `package:sqflite` a um banco — e trocar qualquer um deles obrigaria a reescrever a regra, que é exatamente o que a arquitetura veio impedir. No teste isso vira velocidade: `Trilha`, `TrilhaRepositorioContrato` e `sealed class Falha` rodam em `flutter test` no Windows sem emulador, sem `WidgetsFlutterBinding`, sem `sqfliteFfiInit` e sem rede. E é o contrato que permite `overrideWithValue(RepositorioFalso())` no `ProviderContainer`: com o tipo concreto no provider, o falso nem compilaria.
    *Pontuação (1 ponto):* 0,5 pela regra de dependência (o `domain` no centro, sem conhecer tela, transporte nem banco); 0,5 por citar teste rápido sem emulador **e** a substituição por `overrides`. Meio ponto se só repetir "é boa prática" sem dizer o que se ganha.

12. Porque `connectivity_plus` informa que existe **interface de rede ativa**, não que existe internet: Wi-Fi de hotel com portal cativo, franquia esgotada e roteador sem link com a operadora reportam "conectado". Decidir com base nele faz o app servir cache com a rede perfeita, ou pular a tentativa que teria funcionado. A requisição se tenta sempre; ele entra depois, dentro do `catch`: `_rede.atual()` escolhe entre `FalhaSemConexao` e `FalhaDoServidor`, e é essa `Falha` que chega ao `AsyncValue.error` — ou seja, ele **explica** a falha em vez de decidir por ela. Além disso ele dispara `sincronizar()` na transição `semInterface → comInterface` e alimenta o indicador offline da tela.
    *Pontuação (1 ponto):* 0,5 por "interface não é internet", com pelo menos um exemplo concreto; 0,5 por dizer que o papel dele é explicar a falha já ocorrida (e/ou disparar a sincronização na volta da rede). Zero se a resposta mantiver qualquer `if (offline) return cache;` antes da chamada.

### Solução prática de referência

Dependências do `foco_dados`: `flutter_riverpod: 3.4.3`, `http: ^1.6.0`, `sqflite`, `path`; em
`dev_dependencies`, `sqflite_common_ffi`, `mocktail` e `flutter_lints: ^6.0.0`.

```dart
// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/domain/trilha.dart
// Dart puro. NENHUM import — nem material, nem http, nem sqflite.
// ─────────────────────────────────────────────────────────────────────────────
class Trilha {
  const Trilha({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.nivel = 'basico',
    this.concluidos = const <String>{},
  });

  /// Reidrata tanto a resposta da API quanto o JSON guardado no cache.
  ///
  /// Todo campo que não é obrigatório tem **valor padrão**, nunca `as` direto:
  /// é isso que mantém legível o cache gravado antes de `nivel` existir.
  factory Trilha.deJson(Map<String, Object?> json) {
    final Object? id = json['id'];
    final Object? titulo = json['titulo'];

    if (id == null) {
      throw const FormatException('Campo "id" ausente na trilha');
    }
    if (titulo is! String) {
      throw FormatException('Campo "titulo" ausente ou não é texto: $titulo');
    }

    return Trilha(
      id: '$id',
      titulo: titulo,
      descricao: json['descricao'] is String ? json['descricao']! as String : '',
      nivel: json['nivel'] is String ? json['nivel']! as String : 'basico',
      concluidos: <String>{
        ...?(json['concluidos'] as List<Object?>?)?.whereType<String>(),
      },
    );
  }

  final String id;
  final String titulo;
  final String descricao;
  final String nivel;
  final Set<String> concluidos;

  Map<String, Object?> paraJson() => <String, Object?>{
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'nivel': nivel,
        'concluidos': concluidos.toList(),
      };

  Trilha copyWith({String? titulo, String? descricao, Set<String>? concluidos}) {
    return Trilha(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      nivel: nivel,
      concluidos: concluidos ?? this.concluidos,
    );
  }

  @override
  bool operator ==(Object outro) =>
      outro is Trilha &&
      outro.id == id &&
      outro.titulo == titulo &&
      outro.descricao == descricao &&
      outro.nivel == nivel &&
      outro.concluidos.length == concluidos.length &&
      outro.concluidos.containsAll(concluidos);

  @override
  int get hashCode =>
      Object.hash(id, titulo, descricao, nivel, concluidos.length);
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/domain/falhas.dart
// A língua que o app fala de dentro para fora. Dart puro.
// ─────────────────────────────────────────────────────────────────────────────
sealed class Falha implements Exception {
  const Falha({
    required this.mensagem,
    required this.comoResolver,
    required this.podeTentarDeNovo,
  });

  final String mensagem;
  final String comoResolver;
  final bool podeTentarDeNovo;

  @override
  String toString() => mensagem;
}

final class FalhaSemConexao extends Falha {
  const FalhaSemConexao()
      : super(
          mensagem: 'Você está sem conexão com a internet.',
          comoResolver: 'Ligue o Wi-Fi ou os dados móveis e tente de novo.',
          podeTentarDeNovo: true,
        );
}

final class FalhaTempoEsgotado extends Falha {
  const FalhaTempoEsgotado(this.segundos)
      : super(
          mensagem: 'O servidor demorou demais para responder.',
          comoResolver: 'Sua conexão pode estar lenta. Tente novamente.',
          podeTentarDeNovo: true,
        );

  final int segundos;
}

final class FalhaNaoEncontrado extends Falha {
  const FalhaNaoEncontrado()
      : super(
          mensagem: 'Não encontramos este conteúdo.',
          comoResolver: 'Ele pode ter sido removido. Volte à lista.',
          podeTentarDeNovo: false,
        );
}

final class FalhaServidor extends Falha {
  const FalhaServidor(this.statusCode)
      : super(
          mensagem: 'O servidor está com problemas no momento.',
          comoResolver: 'Não é culpa sua. Tente de novo em alguns minutos.',
          podeTentarDeNovo: true,
        );

  final int statusCode;
}

final class FalhaFormato extends Falha {
  const FalhaFormato()
      : super(
          mensagem: 'Recebemos uma resposta inesperada do servidor.',
          comoResolver: 'Atualize o aplicativo e tente de novo.',
          podeTentarDeNovo: true,
        );
}

final class FalhaDesconhecida extends Falha {
  const FalhaDesconhecida(this.detalheTecnico)
      : super(
          mensagem: 'Algo deu errado.',
          comoResolver: 'Tente de novo. Se continuar, fale com o suporte.',
          podeTentarDeNovo: true,
        );

  /// Só para log. NUNCA mostre isto na tela.
  final String detalheTecnico;
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/domain/trilhas_com_origem.dart
// O que a presentation recebe: os dados, de onde vieram e a idade deles.
// Fica no domain porque o CONTRATO o devolve.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:foco_dados/features/trilhas/domain/trilha.dart';

class TrilhasComOrigem {
  const TrilhasComOrigem({
    required this.trilhas,
    required this.daRede,
    this.avisoDeIdade,
  });

  final List<Trilha> trilhas;
  final bool daRede;

  /// "Atualizado há 3 dias". Null quando o dado é recente.
  final String? avisoDeIdade;
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/domain/trilha_repositorio_contrato.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:foco_dados/features/trilhas/domain/trilha.dart';
import 'package:foco_dados/features/trilhas/domain/trilhas_com_origem.dart';

/// Lança [Falha] — nunca ApiException, SocketException ou DatabaseException.
abstract interface class TrilhaRepositorioContrato {
  /// Stale-while-revalidate: emite o cache na hora e a rede depois.
  Stream<TrilhasComOrigem> observar();

  /// Uma carga só, para a recarga manual. Rede primeiro, cache se falhar.
  Future<List<Trilha>> listar();
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/core/http/prazos.dart
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Prazos {
  static const Duration busca = Duration(seconds: 5);
  static const Duration leitura = Duration(seconds: 15);
  static const Duration escrita = Duration(seconds: 30);
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/core/cache/validade.dart
// A política de frescor do app em UM lugar.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class Validade {
  /// Catálogo público: muda raramente.
  static const Duration trilhas = Duration(hours: 6);

  /// Dados do usuário: mudam com frequência.
  static const Duration perfil = Duration(minutes: 15);
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/core/erros/api_exception.dart
// Vive só dentro de data/. Nunca chega à tela.
// ─────────────────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  const ApiException({
    required this.mensagem,
    required this.statusCode,
    this.corpo,
  });

  final String mensagem;
  final int statusCode;
  final String? corpo;

  @override
  String toString() => 'ApiException($statusCode): $mensagem';
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/core/banco/banco_foco.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:foco_dados/features/trilhas/data/trilha_cache_dao.dart';

abstract final class BancoFoco {
  /// 1 → cache_trilhas · 2 → coluna etag · 3 → coluna itens + índice por data
  static const int versaoAtual = 3;

  static Future<Database> abrir() async {
    return openDatabase(
      p.join(await getDatabasesPath(), 'foco.db'),
      version: versaoAtual,
      onConfigure: configurar,
      onCreate: criar,
      onUpgrade: atualizar,
    );
  }

  /// `onConfigure` roda em TODA abertura — é onde o PRAGMA tem efeito.
  static Future<void> configurar(Database db) =>
      db.execute('PRAGMA foreign_keys = ON');

  static Future<void> criar(Database db, int versao) async {
    await db.execute(
      'CREATE TABLE ${TrilhaCacheDao.tabela} ('
      '  chave      TEXT    PRIMARY KEY,'
      '  conteudo   TEXT    NOT NULL,'   // o JSON cru da API
      '  buscado_em INTEGER NOT NULL,'   // millisecondsSinceEpoch
      '  etag       TEXT,'
      '  itens      INTEGER NOT NULL DEFAULT 0'
      ')',
    );
    await db.execute(
      'CREATE INDEX idx_cache_trilhas_buscado_em '
      'ON ${TrilhaCacheDao.tabela} (buscado_em)',
    );
  }

  /// EM ETAPAS, sem `else`: quem está na v1 executa os dois blocos, em ordem.
  static Future<void> atualizar(Database db, int de, int para) async {
    if (de < 2) await _de1Para2(db);
    if (de < 3) await _de2Para3(db);
  }

  /// Coluna que ACEITA NULL: não precisa de DEFAULT.
  static Future<void> _de1Para2(Database db) async {
    await db.execute(
      'ALTER TABLE ${TrilhaCacheDao.tabela} ADD COLUMN etag TEXT',
    );
  }

  /// `NOT NULL` EXIGE `DEFAULT`: as linhas que já existem precisam de um valor,
  /// senão o SQLite recusa com
  /// "Cannot add a NOT NULL column with default value NULL".
  static Future<void> _de2Para3(Database db) async {
    await db.execute(
      'ALTER TABLE ${TrilhaCacheDao.tabela} '
      'ADD COLUMN itens INTEGER NOT NULL DEFAULT 0',
    );
    await db.execute(
      'CREATE INDEX idx_cache_trilhas_buscado_em '
      'ON ${TrilhaCacheDao.tabela} (buscado_em)',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/data/trilha_api.dart — o service
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:foco_dados/core/erros/api_exception.dart';
import 'package:foco_dados/core/http/prazos.dart';
import 'package:foco_dados/features/trilhas/domain/trilha.dart';

/// Fala HTTP e só. Não conhece sqflite, não conhece Falha, não decide cache.
class TrilhaApi {
  const TrilhaApi({required http.Client cliente, required String base})
      : _cliente = cliente,
        _base = base;

  /// O cliente vem de FORA. É isso que torna a camada testável sem rede.
  final http.Client _cliente;
  final String _base;

  static const Map<String, String> _semCorpo = <String, String>{
    'Accept': 'application/json',
  };

  Future<List<Trilha>> listar() async {
    final Uri url = Uri.parse('$_base/trilhas');

    final http.Response r =
        await _cliente.get(url, headers: _semCorpo).timeout(Prazos.leitura);

    // Faixa 2xx inteira, e ANTES do jsonDecode: um 404 costuma devolver
    // HTML, e o FormatException sairia confuso.
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException(
        mensagem: 'GET /trilhas falhou',
        statusCode: r.statusCode,
        corpo: r.body,
      );
    }

    final List<Object?> bruto = jsonDecode(r.body) as List<Object?>;
    return bruto
        .map((Object? e) => Trilha.deJson(e! as Map<String, Object?>))
        .toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/data/trilha_cache_dao.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:foco_dados/features/trilhas/domain/trilha.dart';

/// Cache de trilhas em SQLite.
///
/// Guarda o **JSON cru**, não colunas normalizadas: o cache espelha a
/// resposta da API, e normalizá-lo obrigaria a migrar o cache toda vez que
/// a API mudasse. Para dados do PRÓPRIO usuário, a escolha é a oposta.
class TrilhaCacheDao {
  const TrilhaCacheDao(this._db);

  final DatabaseExecutor _db;

  static const String tabela = 'cache_trilhas';
  static const String _chaveListagem = 'listagem';

  /// [buscadoEm] existe para o teste envelhecer o cache sem esperar 6 horas.
  /// Em produção ninguém passa esse parâmetro.
  Future<void> gravarListagem(
    List<Trilha> trilhas, {
    DateTime? buscadoEm,
  }) async {
    await _db.insert(
      tabela,
      <String, Object?>{
        'chave': _chaveListagem,
        'conteudo': jsonEncode(trilhas.map((Trilha t) => t.paraJson()).toList()),
        'buscado_em': (buscadoEm ?? DateTime.now()).millisecondsSinceEpoch,
        'itens': trilhas.length,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lê o cache **mesmo expirado**. A decisão de usar é de quem chama:
  /// dado de 3 dias é melhor que tela vazia, desde que o usuário saiba a idade.
  Future<CacheDeTrilhas?> lerListagem() async {
    final List<Map<String, Object?>> linhas = await _db.query(
      tabela,
      where: 'chave = ?', // nunca "chave = '$x'"
      whereArgs: <Object?>[_chaveListagem],
      limit: 1,
    );
    if (linhas.isEmpty) return null;

    final DateTime buscadoEm = DateTime.fromMillisecondsSinceEpoch(
      linhas.first['buscado_em']! as int,
    );

    try {
      final List<Object?> bruto =
          jsonDecode(linhas.first['conteudo']! as String) as List<Object?>;
      return CacheDeTrilhas(
        trilhas: bruto
            .map((Object? e) => Trilha.deJson(e! as Map<String, Object?>))
            .toList(),
        buscadoEm: buscadoEm,
      );
    } on FormatException {
      // Cache corrompido ou de um formato antigo. Descarte em silêncio:
      // é cache, não dado do usuário.
      await invalidar();
      return null;
    }
  }

  Future<void> invalidar() => _db.delete(
        tabela,
        where: 'chave = ?',
        whereArgs: <Object?>[_chaveListagem],
      );

  /// Chame na abertura do app, para o banco não crescer sem limite.
  Future<int> limparAnteriorA(Duration idade) {
    final int limite = DateTime.now().subtract(idade).millisecondsSinceEpoch;
    return _db.delete(
      tabela,
      where: 'buscado_em < ?',
      whereArgs: <Object?>[limite],
    );
  }
}

/// Cache lido, com a idade junto. Vive em data/: é detalhe de armazenamento.
class CacheDeTrilhas {
  const CacheDeTrilhas({required this.trilhas, required this.buscadoEm});

  final List<Trilha> trilhas;
  final DateTime buscadoEm;

  Duration get idade => DateTime.now().difference(buscadoEm);

  bool expirouEm(Duration ttl) => idade > ttl;

  /// Aviso proporcional à idade: minutos não incomodam; dias precisam aparecer.
  String? get avisoDeIdade {
    final Duration d = idade;
    if (d.inMinutes < 5) return null;
    if (d.inMinutes < 60) return 'Atualizado há ${d.inMinutes} min';
    if (d.inHours < 24) return 'Atualizado há ${d.inHours} h';
    if (d.inDays == 1) return 'Atualizado ontem';
    return 'Atualizado há ${d.inDays} dias';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/data/tradutor_de_falha.dart
// O ÚNICO lugar do app que conhece SocketException e companhia.
// Fica em data/ de propósito: o domain não importa dart:io nem http.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:foco_dados/core/erros/api_exception.dart';
import 'package:foco_dados/features/trilhas/domain/falhas.dart';

Falha converterParaFalha(Object erro) {
  // A ordem importa: do mais específico para o mais genérico.
  if (erro is Falha) return erro;

  if (erro is ApiException) {
    return switch (erro.statusCode) {
      404 => const FalhaNaoEncontrado(),
      >= 500 => FalhaServidor(erro.statusCode),
      _ => FalhaDesconhecida('HTTP ${erro.statusCode}'),
    };
  }

  if (erro is TimeoutException) {
    return FalhaTempoEsgotado(erro.duration?.inSeconds ?? 0);
  }

  // SocketException ANTES de ClientException: o objeto lançado pelo http
  // costuma satisfazer os dois.
  if (erro is SocketException) return const FalhaSemConexao();
  if (erro is http.ClientException) return const FalhaSemConexao();

  // FormatException e TypeError: JSON quebrado ou campo com o tipo errado.
  if (erro is FormatException) return const FalhaFormato();
  if (erro is TypeError) return const FalhaFormato();

  return FalhaDesconhecida('$erro');
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/data/trilha_repositorio.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:foco_dados/core/cache/validade.dart';
import 'package:foco_dados/features/trilhas/data/tradutor_de_falha.dart';
import 'package:foco_dados/features/trilhas/data/trilha_api.dart';
import 'package:foco_dados/features/trilhas/data/trilha_cache_dao.dart';
import 'package:foco_dados/features/trilhas/domain/trilha.dart';
import 'package:foco_dados/features/trilhas/domain/trilha_repositorio_contrato.dart';
import 'package:foco_dados/features/trilhas/domain/trilhas_com_origem.dart';

/// Duas responsabilidades, e só duas:
/// 1. Decidir entre cache e rede (TTL, stale-while-revalidate).
/// 2. Traduzir TODA exceção técnica em [Falha] de domínio.
class TrilhaRepositorio implements TrilhaRepositorioContrato {
  const TrilhaRepositorio({
    required TrilhaApi api,
    required TrilhaCacheDao cache,
  })  : _api = api,
        _cache = cache;

  final TrilhaApi _api;
  final TrilhaCacheDao _cache;

  @override
  Stream<TrilhasComOrigem> observar() async* {
    final CacheDeTrilhas? cache = await _cache.lerListagem();

    // 1. Cache primeiro, sem esperar rede. A tela nunca fica em branco.
    if (cache != null) {
      yield TrilhasComOrigem(
        trilhas: cache.trilhas,
        daRede: false,
        avisoDeIdade: cache.avisoDeIdade,
      );

      // Cache DENTRO do TTL: nem vale a pena ir à rede. (questão 3)
      if (!cache.expirouEm(Validade.trilhas)) return;
    }

    // 2. Rede em seguida.
    //
    // Note que NÃO checamos conectividade antes de tentar: connectivity_plus
    // diz se há interface, não se há internet. (questão 12)
    try {
      final List<Trilha> daRede = await _api.listar();
      await _cache.gravarListagem(daRede);
      yield TrilhasComOrigem(trilhas: daRede, daRede: true);
    } catch (erro, pilha) {
      // Sem cache e sem rede: não há o que mostrar, a falha precisa subir.
      if (cache == null) {
        Error.throwWithStackTrace(converterParaFalha(erro), pilha);
      }
      // Com cache, o usuário JÁ viu os dados. Jogar um erro na cara dele
      // agora seria ruído: o aviso de idade já comunica o que importa.
      // (questão 4)
    }
  }

  @override
  Future<List<Trilha>> listar() async {
    try {
      final List<Trilha> daRede = await _api.listar();
      await _cache.gravarListagem(daRede);
      return daRede;
    } catch (erro, pilha) {
      final CacheDeTrilhas? cache = await _cache.lerListagem();
      if (cache != null) return cache.trilhas;
      Error.throwWithStackTrace(converterParaFalha(erro), pilha);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/features/trilhas/presentation/trilhas_controller.dart
// A cadeia de providers e o controller. Nenhum import de http ou sqflite
// além do que os providers precisam para MONTAR as peças.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:foco_dados/features/trilhas/data/trilha_api.dart';
import 'package:foco_dados/features/trilhas/data/trilha_cache_dao.dart';
import 'package:foco_dados/features/trilhas/data/trilha_repositorio.dart';
import 'package:foco_dados/features/trilhas/domain/trilha.dart';
import 'package:foco_dados/features/trilhas/domain/trilha_repositorio_contrato.dart';
import 'package:foco_dados/features/trilhas/domain/trilhas_com_origem.dart';

// ── 0. O banco ───────────────────────────────────────────────────────────────
// Aberto uma vez no main() e entregue por override: existe um dono claro do
// ciclo de vida, e o teste entrega um banco em memória no mesmo lugar.
final Provider<Database> bancoProvider = Provider<Database>((Ref ref) {
  throw UnimplementedError(
    'bancoProvider precisa de override no ProviderScope (veja o main).',
  );
});

// ── 1. A conexão ─────────────────────────────────────────────────────────────
final Provider<http.Client> clienteHttpProvider =
    Provider<http.Client>((Ref ref) {
  final http.Client cliente = http.Client();
  ref.onDispose(cliente.close);
  return cliente;
});

// ── 2. O service ─────────────────────────────────────────────────────────────
final Provider<TrilhaApi> trilhaApiProvider = Provider<TrilhaApi>((Ref ref) {
  return TrilhaApi(
    cliente: ref.watch(clienteHttpProvider),
    // URL base por --dart-define, nunca escrita no código de produção.
    base: const String.fromEnvironment(
      'URL_BASE',
      defaultValue: 'https://api.foco.local',
    ),
  );
});

// ── 3. O DAO do cache ────────────────────────────────────────────────────────
final Provider<TrilhaCacheDao> trilhaCacheDaoProvider =
    Provider<TrilhaCacheDao>((Ref ref) {
  return TrilhaCacheDao(ref.watch(bancoProvider));
});

// ── 4. O repositório, tipado pelo CONTRATO ───────────────────────────────────
// É isto — e só isto — que permite overrideWithValue(RepositorioFalso()).
final Provider<TrilhaRepositorioContrato> trilhaRepositorioProvider =
    Provider<TrilhaRepositorioContrato>((Ref ref) {
  return TrilhaRepositorio(
    api: ref.watch(trilhaApiProvider),
    cache: ref.watch(trilhaCacheDaoProvider),
  );
});

// ── 5. O controller: é o que a tela observa ──────────────────────────────────
final AsyncNotifierProvider<TrilhasController, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider<TrilhasController, List<Trilha>>(
        TrilhasController.new);

class TrilhasController extends AsyncNotifier<List<Trilha>> {
  /// Último pacote recebido: origem e aviso de idade.
  ///
  /// Fica fora do AsyncValue de propósito — "Atualizado há 3 dias" é
  /// metadado da carga, não o estado da lista.
  TrilhasComOrigem? ultimoPacote;

  @override
  Future<List<Trilha>> build() async {
    // watch (não read): se o repositório for substituído por um override,
    // este controller é recriado.
    final TrilhaRepositorioContrato repo = ref.watch(trilhaRepositorioProvider);

    final StreamIterator<TrilhasComOrigem> fluxo =
        StreamIterator<TrilhasComOrigem>(repo.observar());
    ref.onDispose(fluxo.cancel);

    // Stream fechou sem nada: nem cache, nem rede, nem erro.
    if (!await fluxo.moveNext()) return <Trilha>[];

    ultimoPacote = fluxo.current;

    // As emissões seguintes (a da rede) chegam depois do build.
    unawaited(_consumirRestante(fluxo));

    return fluxo.current.trilhas;
  }

  Future<void> _consumirRestante(StreamIterator<TrilhasComOrigem> fluxo) async {
    // Deixa o build terminar: escrever em `state` durante o build é
    // erro de execução no Riverpod.
    await Future<void>.delayed(Duration.zero);

    try {
      while (await fluxo.moveNext()) {
        ultimoPacote = fluxo.current;
        // Troca os dados sem passar por AsyncLoading: a tela não pisca
        // e o usuário não perde a rolagem.
        state = AsyncData<List<Trilha>>(fluxo.current.trilhas);
      }
    } catch (erro, pilha) {
      state = AsyncError<List<Trilha>>(erro, pilha).copyWithPrevious(state);
    }
  }

  /// Recarga do RefreshIndicator e do botão "Tentar de novo".
  ///
  /// Diferente de `ref.invalidate(trilhasProvider)`, que apaga o estado e
  /// volta a AsyncLoading SEM dados.
  Future<void> recarregar() async {
    final AsyncValue<List<Trilha>> anterior = state;

    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(anterior);

    final AsyncValue<List<Trilha>> resultado = await AsyncValue.guard(
      () => ref.read(trilhaRepositorioProvider).listar(),
    );

    // `guard` devolve um AsyncError CRU. Sem este copyWithPrevious a lista
    // sumiria da tela no primeiro erro de recarga.
    state = resultado.copyWithPrevious(anterior);
  }
}

/// Derivado: a assincronia se propaga com whenData, não se desembrulha.
final Provider<AsyncValue<int>> totalDeTrilhasProvider =
    Provider<AsyncValue<int>>((Ref ref) {
  return ref.watch(trilhasProvider).whenData((List<Trilha> l) => l.length);
});

// ─────────────────────────────────────────────────────────────────────────────
// lib/main.dart — onde a cadeia se fecha
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'package:foco_dados/core/banco/banco_foco.dart';
import 'package:foco_dados/features/trilhas/presentation/trilhas_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Database db = await BancoFoco.abrir();

  runApp(
    ProviderScope(
      overrides: <Override>[bancoProvider.overrideWithValue(db)],
      child: const AppFoco(),
    ),
  );
}

class AppFoco extends StatelessWidget {
  const AppFoco({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: const TelaTrilhas(),
    );
  }
}

class TelaTrilhas extends ConsumerWidget {
  const TelaTrilhas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // O efeito colateral fica no ref.listen, declarado no build mas
    // executado só no callback. (questão 8)
    ref.listen<AsyncValue<List<Trilha>>>(trilhasProvider,
        (AsyncValue<List<Trilha>>? antes, AsyncValue<List<Trilha>> agora) {
      if (agora.hasError && agora.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não conseguimos atualizar agora.')),
        );
      }
    });

    final AsyncValue<List<Trilha>> trilhas = ref.watch(trilhasProvider);
    final String? aviso =
        ref.watch(trilhasProvider.notifier).ultimoPacote?.avisoDeIdade;

    return Scaffold(
      appBar: AppBar(title: const Text('Trilhas')),
      body: RefreshIndicator.adaptive(
        onRefresh: () => ref.read(trilhasProvider.notifier).recarregar(),
        child: trilhas.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object erro, StackTrace pilha) => Center(
            child: Text(erro is Falha ? erro.mensagem : 'Algo deu errado'),
          ),
          data: (List<Trilha> lista) => ListView(
            children: <Widget>[
              if (aviso != null)
                ListTile(leading: const Icon(Icons.history), title: Text(aviso)),
              for (final Trilha t in lista)
                ListTile(title: Text(t.titulo), subtitle: Text(t.descricao)),
            ],
          ),
        ),
      ),
    );
  }
}
```

```dart
// ─────────────────────────────────────────────────────────────────────────────
// test/trilhas/cadeia_trilhas_test.dart
// Roda com `flutter test` no Windows: sem emulador, sem rede, sem Mac.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:foco_dados/core/banco/banco_foco.dart';
import 'package:foco_dados/core/cache/validade.dart';
import 'package:foco_dados/features/trilhas/data/trilha_cache_dao.dart';
import 'package:foco_dados/features/trilhas/domain/falhas.dart';
import 'package:foco_dados/features/trilhas/domain/trilha.dart';
import 'package:foco_dados/features/trilhas/presentation/trilhas_controller.dart';

const String _jsonDaApi = '''
[
  {"id":"1","titulo":"Dart do zero","descricao":"Sintaxe e tipos","nivel":"basico"},
  {"id":"2","titulo":"Flutter na prática","descricao":"Widgets","nivel":"medio"}
]
''';

const Trilha _antiga = Trilha(
  id: '9',
  titulo: 'Versão antiga',
  descricao: 'Guardada no cache',
);

void main() {
  // Padrão validado do curso para testar banco em desktop.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath, // nasce vazio a cada teste, morre no tearDown
      options: OpenDatabaseOptions(
        version: BancoFoco.versaoAtual,
        onConfigure: BancoFoco.configurar,
        onCreate: BancoFoco.criar,
        onUpgrade: BancoFoco.atualizar,
      ),
    );
  });

  tearDown(() => db.close());

  ProviderContainer containerCom(http.Client cliente) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        bancoProvider.overrideWithValue(db),
        clienteHttpProvider.overrideWithValue(cliente),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  http.Client respondendo(String corpo, {int status = 200}) {
    return MockClient(
      (http.Request _) async => http.Response(
        corpo,
        status,
        headers: const <String, String>{
          'content-type': 'application/json; charset=utf-8',
        },
      ),
    );
  }

  http.Client semRede() {
    return MockClient(
      (http.Request _) async =>
          throw const SocketException('Failed host lookup'),
    );
  }

  test('rede OK e cache vazio: a lista vem da rede e fica gravada', () async {
    final ProviderContainer container = containerCom(respondendo(_jsonDaApi));

    final List<Trilha> lista = await container.read(trilhasProvider.future);

    expect(lista, hasLength(2));
    expect(lista.first.titulo, 'Dart do zero');
    expect(container.read(trilhasProvider.notifier).ultimoPacote?.daRede, isTrue);

    // O carimbo foi gravado: o cache nasce dentro do TTL.
    final CacheDeTrilhas? cache = await TrilhaCacheDao(db).lerListagem();
    expect(cache, isNotNull);
    expect(cache!.trilhas, hasLength(2));
    expect(cache.expirouEm(Validade.trilhas), isFalse);
  });

  test('cache dentro do TTL: a rede nem chega a ser chamada', () async {
    await TrilhaCacheDao(db).gravarListagem(<Trilha>[_antiga]);

    int chamadas = 0;
    final ProviderContainer container = containerCom(
      MockClient((http.Request _) async {
        chamadas++;
        return http.Response(_jsonDaApi, 200);
      }),
    );

    await container.read(trilhasProvider.future);
    await pumpEventQueue();

    expect(chamadas, 0); // questão 3
    expect(container.read(trilhasProvider).value, hasLength(1));
  });

  test('cache expirado: emite o cache primeiro e a rede depois', () async {
    await TrilhaCacheDao(db).gravarListagem(
      <Trilha>[_antiga],
      buscadoEm: DateTime.now().subtract(const Duration(days: 2)),
    );

    final ProviderContainer container = containerCom(respondendo(_jsonDaApi));

    // 1ª emissão: o cache velho, imediato. A tela nunca fica em branco.
    final List<Trilha> primeira = await container.read(trilhasProvider.future);
    expect(primeira.single.titulo, 'Versão antiga');
    expect(
      container.read(trilhasProvider.notifier).ultimoPacote?.avisoDeIdade,
      'Atualizado há 2 dias',
    );

    // 2ª emissão: a rede, sem AsyncLoading sem dados no meio.
    await pumpEventQueue();
    expect(container.read(trilhasProvider).value, hasLength(2));
    expect(container.read(trilhasProvider.notifier).ultimoPacote?.daRede, isTrue);
  });

  test('rede falha COM cache: os dados ficam na tela, sem erro', () async {
    await TrilhaCacheDao(db).gravarListagem(
      <Trilha>[_antiga],
      buscadoEm: DateTime.now().subtract(const Duration(hours: 8)),
    );

    final ProviderContainer container = containerCom(semRede());

    final List<Trilha> lista = await container.read(trilhasProvider.future);
    expect(lista, hasLength(1));

    await pumpEventQueue(); // deixa a tentativa de rede falhar

    final AsyncValue<List<Trilha>> estado = container.read(trilhasProvider);
    expect(estado.hasError, isFalse); // questão 4
    expect(estado.value, hasLength(1));
    expect(
      container.read(trilhasProvider.notifier).ultimoPacote?.avisoDeIdade,
      'Atualizado há 8 h',
    );
  });

  test('rede falha SEM cache: sobe FalhaSemConexao, nunca SocketException',
      () async {
    final ProviderContainer container = containerCom(semRede());

    await expectLater(
      container.read(trilhasProvider.future),
      throwsA(isA<FalhaSemConexao>()),
    );
    expect(container.read(trilhasProvider).hasError, isTrue);
  });

  test('500 vira FalhaServidor e a recarga não apaga a lista', () async {
    final ProviderContainer container = containerCom(respondendo(_jsonDaApi));
    await container.read(trilhasProvider.future);

    // O cliente falha a partir daqui, mas o cache recém-gravado salva a tela.
    final List<Trilha> antes = container.read(trilhasProvider).value!;
    await container.read(trilhasProvider.notifier).recarregar();

    expect(container.read(trilhasProvider).value, antes);
  });
}
```

```dart
// ─────────────────────────────────────────────────────────────────────────────
// test/core/banco_foco_test.dart — a migração encadeada
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:foco_dados/core/banco/banco_foco.dart';

/// O esquema como ele estava na v1, reproduzido à mão. Um teste que já cria
/// tudo na versão atual passa sem NUNCA executar a migração.
Future<void> _criarV1(Database db, int versao) async {
  await db.execute(
    'CREATE TABLE cache_trilhas ('
    '  chave      TEXT    PRIMARY KEY,'
    '  conteudo   TEXT    NOT NULL,'
    '  buscado_em INTEGER NOT NULL'
    ')',
  );
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('v1 → v3 executa as DUAS etapas e preserva o cache gravado', () async {
    final String caminho = p.join(
      await databaseFactory.getDatabasesPath(),
      'foco_migracao_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    addTearDown(() => databaseFactory.deleteDatabase(caminho));

    // 1. O banco como ele está no aparelho de quem instalou a v1.
    final Database v1 = await databaseFactory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(version: 1, onCreate: _criarV1),
    );
    await v1.insert('cache_trilhas', <String, Object?>{
      'chave': 'listagem',
      'conteudo': '[]',
      'buscado_em': 1700000000000,
    });
    await v1.close();

    // 2. O usuário atualiza o app: a mesma abertura dispara o onUpgrade.
    final Database v3 = await databaseFactory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: BancoFoco.versaoAtual,
        onConfigure: BancoFoco.configurar,
        onCreate: BancoFoco.criar,
        onUpgrade: BancoFoco.atualizar,
      ),
    );

    // 3. As duas colunas existem — prova de que os dois blocos rodaram.
    final List<Map<String, Object?>> colunas =
        await v3.rawQuery('PRAGMA table_info(cache_trilhas)');
    final Set<String> nomes =
        colunas.map((Map<String, Object?> c) => c['name']! as String).toSet();
    expect(nomes, containsAll(<String>['etag', 'itens']));

    final Map<String, Object?> itens = colunas
        .firstWhere((Map<String, Object?> c) => c['name'] == 'itens');
    expect(itens['notnull'], 1);
    expect(itens['dflt_value'], '0'); // sem o DEFAULT, o ALTER TABLE falharia

    // 4. E a linha de antes continua lá.
    final List<Map<String, Object?>> linhas =
        await v3.query('cache_trilhas');
    expect(linhas, hasLength(1));
    expect(linhas.single['buscado_em'], 1700000000000);
    expect(linhas.single['itens'], 0);
    expect(await v3.getVersion(), 3);

    await v3.close();
  });
}
```

O avaliador deve procurar quatro coisas, nesta ordem. Primeiro, os `import` do `domain/`: qualquer `package:flutter/...`, `package:http/...` ou `package:sqflite/...` ali derruba a entrega inteira, e é por isso que `converterParaFalha` fica em `data/` — ele precisa conhecer `SocketException`. Segundo, o tipo do `trilhaRepositorioProvider`: se estiver `Provider<TrilhaRepositorio>`, o `overrideWithValue` do teste nem compila, e os 2 pontos da cadeia vão junto com os 2 do teste. Terceiro, o `if (!cache.expirouEm(Validade.trilhas)) return;` e a ausência de qualquer `if (offline)` antes da chamada — troque o `return` por nada e o teste "a rede nem chega a ser chamada" deve falhar; é essa a prova de que o TTL existe de verdade. Quarto, o `copyWithPrevious` na `recarregar()` e o `else` ausente no `atualizar()`: remova o primeiro e o último teste da cadeia falha; troque `if (de < 3)` por `else if` e quem vem da v1 para na v2 com o banco mentindo sobre a própria versão.

---

<a id="cumulativa-04"></a>
## Cumulativa 04 — Qualidade e plataforma

> Confira depois de fazer a [avaliação](../avaliacoes/cumulativa-04-qualidade-e-plataforma.md).

### Questionário

1. **C** — a memória é largura × altura × 4 bytes do bitmap **decodificado**: 4032 × 3024 × 4 ≈ 48 MB, e só `cacheWidth`/`cacheHeight` mudam o tamanho **na memória**. A) `width: 56` muda o tamanho **na tela** — o bitmap de 48 MB continua decodificado; B) `BoxFit` é recorte, não decodificação; D) guardar o caminho no sqflite não tem relação nenhuma com o bitmap.
2. **B** — `ThemeData(platform:)` é o que o teste consegue forçar, e `Theme.of(context).platform` lê exatamente esse valor. A) `Platform.isIOS` lê o SO da **máquina que roda o teste** e não é sobrescrevível; C) o teste de widget decide isso em 40 ms no Windows, sem Mac nenhum; D) `kIsWeb` só distingue web de nativo.
3. **D** — `flutter test` roda sem camada nativa: o canal do `connectivity_plus` não tem implementação, e a saída é injetar um fake do **contrato** por `overrides`. A) `IntegrationTestWidgetsFlutterBinding` é da pasta `integration_test/`, e resolveria rodando no aparelho — o que já não é teste de widget; B) `pumpAndSettle` não registra plugin; C) `registerFallbackValue` é do mocktail, para `any()` de tipo não primitivo.
4. **B** — teste de widget roda em debug, na CPU do PC, com relógio virtual e **sem thread de raster**: ali não existe quadro para medir, então `ListView(children:)` com 5 000 filhos passa verde. A) teste de integração também não mede desempenho; C) `pumpAndSettle` espera a árvore estabilizar, não esconde jank que não existe no ambiente; D) é verdade que o lint não reprova `ListView(children:)`, mas isso não explica por que o teste passa.
5. **A** — a fronteira **copia** dados: `BuildContext` é uma posição viva na árvore, `WidgetRef` é o acesso ao container de providers e o `Database` carrega um handle nativo — nenhum dos três é copiável. B, C e D são dados puros e atravessam sem drama.
6. **C** — a árvore de semântica **não é construída por padrão** nos testes: sem `ensureSemantics()` a diretriz passa à toa, e sem `handle.dispose()` a semântica vaza para os testes seguintes. A) `meetsGuideline` roda em `flutter test`, que é sempre debug; B) `find.bySemanticsLabel` é finder, não liga a semântica; D) o TalkBack é o teste manual, e não habilita nada dentro do `flutter test`.
7. **B** — a URL base é **configuração por ambiente** (`--dart-define`, lida em contexto `const` por `String.fromEnvironment`); o token é **dado do usuário em execução**, e vai para o Keystore/Keychain via `flutter_secure_storage`. A) token em `--dart-define` seria o mesmo token para todos os usuários, gravado no binário; C) `SharedPreferences` é texto claro e entra no backup; D) o sqflite não é criptografado — um aparelho com root lê o arquivo inteiro.
8. **D** — só o `.symbols` **daquele build exato** reverte `ce` e `a1` de volta aos nomes originais. A) e B) dependem de o usuário reproduzir de novo e não recuperam o crash que já aconteceu; C) o `logcat` traria o mesmo stack ofuscado — e você não tem o aparelho dele.

9. Dentro do `paused` a regra só roda quando o sistema resolve pausar o app, e mora num `State`, cercada de `BuildContext`, `SharedPreferences` e ciclo de vida — para testá-la você teria de montar a tela, simular `AppLifecycleState.paused` e ainda controlar o relógio. No domínio, `SessaoEmAndamento.ehSuspeita(agora)` é função pura de dois valores: o carimbo de início e o instante recebido por parâmetro. O teste vira três linhas num `test()` de `flutter test`, sem `WidgetTester`, sem plugin e sem esperar quadro — e a mesma regra passa a valer em **todo** caminho que fecha sessão (restaurar, salvar, sincronizar), não só no que passa pelo `paused`.
   **Pontuação:** 1 ponto — 0,5 por "regra pura, testável sem widget, plugin ou relógio real" e 0,5 por "vale em todos os caminhos, não só no do ciclo de vida". Sem falar do efeito no teste, no máximo 0,5.
10. `flutter test` garante **comportamento**: a lista mostra as 5 000 matérias na ordem certa, o ícone de favorito muda, a busca filtra. Ele roda em debug, na CPU do PC, com relógio virtual e sem thread de raster — não há quadro para medir, então um `ListView(children:)` que constrói os 5 000 itens de uma vez passa verde. A medição em profile garante **custo**: `flutter run --profile` num aparelho físico mostra que o pior quadro da rolagem foi 41 ms, e a cor da barra diz se foi 🔵 UI (build/layout) ou 🟢 raster (pintura). Um responde "faz o que promete"; o outro, "faz dentro dos 16 ms". Nenhum substitui o outro.
   **Pontuação:** 1 ponto — 0,5 por "comportamento × custo" amarrado à lista do Foco, 0,5 por citar aparelho físico em profile **e** a distinção UI × raster. Resposta genérica ("teste testa, profile mede"), 0,5.
11. `meetsGuideline` verifica quatro propriedades mensuráveis da árvore de semântica — alvo de 48 dp/44 pt, contraste 4,5:1, rótulo presente — e não tem opinião nenhuma sobre o que o leitor de tela **fala**. Ele aprova rótulo "botão", aprova ordem de leitura absurda e não sabe se a navegação por gestos chega ao alvo. No aparelho aparecem, por exemplo: (1) ordem de foco errada — o TalkBack lê o cronômetro antes do nome da matéria, ou pula a faixa de offline por completo; (2) mudança de estado não anunciada — pausar não fala nada porque falta `liveRegion`. Também só no aparelho: rótulo que descreve o ícone ("estrela") em vez da ação ("favoritar Cálculo I") e foco preso dentro de um diálogo, que no VoiceOver não tem como sair.
   **Pontuação:** 1 ponto — 0,5 pela distinção "propriedade mensurável × experiência falada", 0,5 pelos **dois** problemas concretos de aparelho. Citar só um, 0,5.
12. `--obfuscate` renomeia classes e métodos do código Dart compilado: dificulta engenharia reversa e cobra o preço do stack trace ilegível, que só volta com `flutter symbolize` mais o `.symbols` daquele build. `flutter_secure_storage` guarda **dado do usuário em tempo de execução** — token de acesso e de renovação — no Keystore (🤖) / Keychain (🍎), fora do `SharedPreferences` e fora do backup. Um protege código; o outro, dado do usuário no aparelho. Nenhum protege segredo embutido no binário: `--dart-define` e literal constante viajam no APK e aparecem num `strings`, e ofuscar renomeia símbolos, não criptografa literais. Chave de API mora no servidor — o app pede ao seu backend, que guarda a chave.
   **Pontuação:** 1 ponto — 0,5 pelos dois escopos corretos (código × dado do usuário em execução), 0,5 por "o binário é público, o segredo mora no servidor". Afirmar que `--dart-define` esconde o valor zera a questão.

### Solução prática de referência

```dart
// ── lib/core/tempo/relogio_do_app.dart ───────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contrato do relógio. Sem ele, `DateTime.now()` fica espalhado pelo
/// código e nenhum teste consegue viajar no tempo.
abstract interface class RelogioDoApp {
  DateTime agora();
}

class RelogioDoSistema implements RelogioDoApp {
  const RelogioDoSistema();

  @override
  DateTime agora() => DateTime.now();
}

/// Tipado com o CONTRATO — é isso que permite o `overrideWithValue`.
final Provider<RelogioDoApp> relogioProvider =
    Provider<RelogioDoApp>((Ref ref) => const RelogioDoSistema());

// ── lib/core/rede/observador_de_rede.dart ────────────────────────────────
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EstadoDeRede {
  semInterface,
  comInterface;

  /// Só `semInterface` dá certeza. Com interface, a internet é PROVÁVEL.
  bool get certamenteOffline => this == EstadoDeRede.semInterface;
  bool get provavelmenteOnline => this != EstadoDeRede.semInterface;
}

class LeituraDeRede {
  const LeituraDeRede(this.estado);

  final EstadoDeRede estado;

  bool get online => estado.provavelmenteOnline;
}

/// ⚠️ CONTRATO, não classe concreta. O plugin fica do lado de fora —
/// é exatamente isto que impede `MissingPluginException` em `flutter test`.
abstract interface class ObservadorDeRede {
  Future<LeituraDeRede> atual();
  Stream<LeituraDeRede> observar();
}

class ObservadorDeRedeConnectivity implements ObservadorDeRede {
  ObservadorDeRedeConnectivity([Connectivity? conectividade])
      : _conectividade = conectividade ?? Connectivity();

  final Connectivity _conectividade;

  @override
  Future<LeituraDeRede> atual() async =>
      _classificar(await _conectividade.checkConnectivity());

  @override
  Stream<LeituraDeRede> observar() => _conectividade.onConnectivityChanged
      .map(_classificar)
      // Trocar de Wi-Fi, ligar VPN: emite mais do que se espera.
      .distinct((LeituraDeRede a, LeituraDeRede b) => a.estado == b.estado);

  LeituraDeRede _classificar(List<ConnectivityResult> resultado) {
    final bool nenhuma = resultado.isEmpty ||
        resultado.every((ConnectivityResult r) => r == ConnectivityResult.none);
    return LeituraDeRede(
      nenhuma ? EstadoDeRede.semInterface : EstadoDeRede.comInterface,
    );
  }
}

final Provider<ObservadorDeRede> observadorDeRedeProvider =
    Provider<ObservadorDeRede>((Ref ref) => ObservadorDeRedeConnectivity());

/// ⚠️ O `yield` inicial é obrigatório: `onConnectivityChanged` só emite
/// em MUDANÇAS. Sem ele, quem abre o app e não mexe em nada fica em
/// AsyncLoading para sempre.
final StreamProvider<LeituraDeRede> estadoDeRedeProvider =
    StreamProvider<LeituraDeRede>((Ref ref) async* {
  final ObservadorDeRede observador = ref.watch(observadorDeRedeProvider);
  yield await observador.atual();
  yield* observador.observar();
});

final Provider<bool> estaOfflineProvider = Provider<bool>((Ref ref) {
  // Enquanto carrega, assume ONLINE: assumir offline piscaria a faixa
  // a cada abertura do app.
  return ref.watch(estadoDeRedeProvider).maybeWhen(
        data: (LeituraDeRede r) => r.estado.certamenteOffline,
        orElse: () => false,
      );
});

// ── lib/features/sessoes/domain/sessao_em_andamento.dart ─────────────────
/// Sessão fechada, pronta para o banco.
class SessaoConcluida {
  const SessaoConcluida({
    required this.materiaId,
    required this.iniciadaEm,
    required this.duracao,
  });

  final String materiaId;
  final DateTime iniciadaEm;
  final Duration duracao;

  int get minutos => duracao.inMinutes;

  Map<String, Object?> paraMapa() => <String, Object?>{
        'materia_id': materiaId,
        'iniciada_em': iniciadaEm.millisecondsSinceEpoch,
        'minutos': minutos,
      };
}

/// Sessão em andamento — DOMÍNIO PURO.
///
/// Nenhum `import` de Flutter aqui: sem `BuildContext`, sem `Ref`, sem
/// `SharedPreferences`. E — a mudança em relação ao módulo 11 — nenhum
/// `DateTime.now()` escondido: o instante SEMPRE entra por parâmetro.
/// É isso que torna o descarte de 12 h testável em três linhas.
class SessaoEmAndamento {
  const SessaoEmAndamento({
    required this.materiaId,
    required this.iniciadaEm,
    this.pausadaEm,
    this.tempoPausado = Duration.zero,
  });

  factory SessaoEmAndamento.deJson(Map<String, Object?> json) {
    final int? pausada = json['pausada_em'] as int?;
    return SessaoEmAndamento(
      materiaId: json['materia_id']! as String,
      iniciadaEm:
          DateTime.fromMillisecondsSinceEpoch(json['iniciada_em']! as int),
      pausadaEm:
          pausada == null ? null : DateTime.fromMillisecondsSinceEpoch(pausada),
      tempoPausado:
          Duration(milliseconds: (json['tempo_pausado'] as int?) ?? 0),
    );
  }

  /// Ninguém estuda 12 horas seguidas: acima disso o app ficou aberto
  /// a noite inteira com o cronômetro ligado.
  static const Duration limiteSuspeito = Duration(hours: 12);

  final String materiaId;
  final DateTime iniciadaEm;

  /// Quando o usuário pausou. `null` = rodando.
  final DateTime? pausadaEm;

  /// Quanto tempo já ficou pausada, acumulado.
  final Duration tempoPausado;

  bool get rodando => pausadaEm == null;

  /// Tempo real de estudo, medido pelo CARIMBO — nunca por um contador.
  /// Verdadeiro mesmo que o app tenha ficado suspenso ou sido morto.
  Duration duracao(DateTime agora) {
    final DateTime fim = pausadaEm ?? agora;
    final Duration bruta = fim.difference(iniciadaEm) - tempoPausado;
    // Relógio do sistema pode andar para trás (fuso, NTP): nunca negativo.
    return bruta.isNegative ? Duration.zero : bruta;
  }

  int minutos(DateTime agora) => duracao(agora).inMinutes;

  bool ehSuspeita(DateTime agora) => duracao(agora) >= limiteSuspeito;

  SessaoEmAndamento pausar(DateTime agora) {
    if (!rodando) return this;
    return SessaoEmAndamento(
      materiaId: materiaId,
      iniciadaEm: iniciadaEm,
      pausadaEm: agora,
      tempoPausado: tempoPausado,
    );
  }

  SessaoEmAndamento retomar(DateTime agora) {
    final DateTime? pausa = pausadaEm;
    if (pausa == null) return this;
    return SessaoEmAndamento(
      materiaId: materiaId,
      iniciadaEm: iniciadaEm,
      // Acumula a pausa para descontar depois.
      tempoPausado: tempoPausado + agora.difference(pausa),
    );
  }

  /// Fecha a sessão. Devolve `null` quando a sessão é suspeita:
  /// o DESCARTE é decisão do domínio, não do callback de `paused`.
  SessaoConcluida? concluir(DateTime agora) {
    if (ehSuspeita(agora)) return null;
    return SessaoConcluida(
      materiaId: materiaId,
      iniciadaEm: iniciadaEm,
      duracao: duracao(agora),
    );
  }

  Map<String, Object?> paraJson() => <String, Object?>{
        'materia_id': materiaId,
        'iniciada_em': iniciadaEm.millisecondsSinceEpoch,
        'pausada_em': pausadaEm?.millisecondsSinceEpoch,
        'tempo_pausado': tempoPausado.inMilliseconds,
      };
}

// ── lib/features/sessoes/data/armazenamento.dart ─────────────────────────
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/sessao_em_andamento.dart';

/// Contratos. Os plugins (SharedPreferences, sqflite) ficam atrás deles.
abstract interface class RascunhoDeSessao {
  Future<void> salvar(SessaoEmAndamento sessao);
  Future<SessaoEmAndamento?> ler();
  Future<void> limpar();
}

abstract interface class RegistroDeSessoes {
  Future<void> registrar(SessaoConcluida sessao);
}

class RascunhoEmPreferences implements RascunhoDeSessao {
  RascunhoEmPreferences(this._prefs);

  static const String _chave = 'sessao_em_andamento';

  final SharedPreferences _prefs;

  @override
  Future<void> salvar(SessaoEmAndamento sessao) =>
      _prefs.setString(_chave, jsonEncode(sessao.paraJson()));

  @override
  Future<SessaoEmAndamento?> ler() async {
    final String? bruto = _prefs.getString(_chave);
    if (bruto == null) return null;
    return SessaoEmAndamento.deJson(jsonDecode(bruto) as Map<String, Object?>);
  }

  @override
  Future<void> limpar() => _prefs.remove(_chave).then((_) {});
}

class SessaoDao implements RegistroDeSessoes {
  SessaoDao(this._db);

  final Database _db;

  @override
  Future<void> registrar(SessaoConcluida sessao) async {
    await _db.insert('sessoes', sessao.paraMapa());
  }
}

/// O `Database` não nasce num provider: ele é aberto no bootstrap,
/// que é `async`, e entra por override.
final Provider<Database> bancoProvider = Provider<Database>(
  (Ref ref) => throw UnimplementedError('Sobrescreva bancoProvider no boot'),
);

final Provider<RascunhoDeSessao> rascunhoProvider = Provider<RascunhoDeSessao>(
  (Ref ref) => throw UnimplementedError('Sobrescreva rascunhoProvider no boot'),
);

final Provider<RegistroDeSessoes> registroDeSessoesProvider =
    Provider<RegistroDeSessoes>((Ref ref) => SessaoDao(ref.watch(bancoProvider)));

// ── lib/features/sessoes/presentation/cronometro_controller.dart ─────────
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tempo/relogio_do_app.dart';
import '../data/armazenamento.dart';
import '../domain/sessao_em_andamento.dart';

enum ResultadoDaSessao { salva, descartada, nenhuma }

final NotifierProvider<CronometroController, SessaoEmAndamento?>
    cronometroProvider =
    NotifierProvider<CronometroController, SessaoEmAndamento?>(
        CronometroController.new);

class CronometroController extends Notifier<SessaoEmAndamento?> {
  @override
  SessaoEmAndamento? build() => null;

  RelogioDoApp get _relogio => ref.read(relogioProvider);
  RascunhoDeSessao get _rascunho => ref.read(rascunhoProvider);
  RegistroDeSessoes get _registro => ref.read(registroDeSessoesProvider);

  Future<void> restaurar() async {
    final SessaoEmAndamento? recuperada = await _rascunho.ler();
    if (recuperada == null) return;

    // A REGRA vem do domínio. O controller só obedece.
    if (recuperada.ehSuspeita(_relogio.agora())) {
      await _rascunho.limpar();
      state = null;
      return;
    }
    state = recuperada;
  }

  Future<void> iniciar(String materiaId) async {
    final SessaoEmAndamento nova = SessaoEmAndamento(
      materiaId: materiaId,
      iniciadaEm: _relogio.agora(),
    );
    state = nova;
    await _rascunho.salvar(nova);
  }

  Future<void> pausar() async {
    final SessaoEmAndamento? atual = state;
    if (atual == null || !atual.rodando) return;
    final SessaoEmAndamento pausada = atual.pausar(_relogio.agora());
    state = pausada;
    await _rascunho.salvar(pausada);
  }

  Future<void> retomar() async {
    final SessaoEmAndamento? atual = state;
    if (atual == null || atual.rodando) return;
    final SessaoEmAndamento retomada = atual.retomar(_relogio.agora());
    state = retomada;
    await _rascunho.salvar(retomada);
  }

  Future<ResultadoDaSessao> salvar() async {
    final SessaoEmAndamento? atual = state;
    if (atual == null) return ResultadoDaSessao.nenhuma;

    final SessaoConcluida? concluida = atual.concluir(_relogio.agora());
    await _rascunho.limpar();
    state = null;

    if (concluida == null) return ResultadoDaSessao.descartada;
    await _registro.registrar(concluida);
    return ResultadoDaSessao.salva;
  }

  /// Chamado pelo `AppLifecycleListener` em `paused` — o único evento
  /// confiável. `inactive` acontece dezenas de vezes por dia e
  /// `detached` pode nunca ser chamado.
  Future<void> persistirRascunho() async {
    final SessaoEmAndamento? atual = state;
    if (atual == null) {
      await _rascunho.limpar();
      return;
    }
    await _rascunho.salvar(atual);
  }
}

// ── lib/core/adaptativo/botao_salvar_sessao.dart ─────────────────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BotaoSalvarSessao extends StatelessWidget {
  const BotaoSalvarSessao({required this.aoSalvar, super.key});

  final VoidCallback? aoSalvar;

  @override
  Widget build(BuildContext context) {
    // ✅ Theme.of(context).platform — NUNCA Platform.isIOS.
    // Só assim o teste força a plataforma com ThemeData(platform:),
    // e só assim a tecla `o` do terminal troca a variante sem Mac.
    final bool ehIOS = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };

    const Widget rotulo = Text('Salvar sessão');

    if (ehIOS) {
      return ConstrainedBox(
        // 44 pt é o mínimo da Apple.
        constraints: const BoxConstraints(minHeight: 44, minWidth: 88),
        child: CupertinoButton.filled(
          key: const Key('botao_salvar'),
          onPressed: aoSalvar,
          child: rotulo,
        ),
      );
    }

    return FilledButton(
      key: const Key('botao_salvar'),
      // O padrão do M3 é 40 dp de altura: a diretriz do Android pede 48.
      style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
      onPressed: aoSalvar,
      child: rotulo,
    );
  }
}

// ── lib/features/sessoes/presentation/sessao_screen.dart ─────────────────
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/adaptativo/botao_salvar_sessao.dart';
import '../../../core/rede/observador_de_rede.dart';
import '../../../core/tempo/relogio_do_app.dart';
import '../domain/sessao_em_andamento.dart';
import 'cronometro_controller.dart';

class SessaoScreen extends ConsumerStatefulWidget {
  const SessaoScreen({required this.materiaId, super.key});

  final String materiaId;

  @override
  ConsumerState<SessaoScreen> createState() => _SessaoScreenState();
}

class _SessaoScreenState extends ConsumerState<SessaoScreen> {
  /// ⚠️ Só REDESENHA. O tempo vem do relógio injetado, nunca daqui.
  Timer? _redesenho;
  late final AppLifecycleListener _ciclo;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(
      onPause: () =>
          unawaited(ref.read(cronometroProvider.notifier).persistirRascunho()),
    );
    _redesenho = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(cronometroProvider.notifier).restaurar());
    });
  }

  @override
  void dispose() {
    _redesenho?.cancel();
    _ciclo.dispose(); // sem isto, o listener vaza entre telas
    super.dispose();
  }

  Future<void> _salvar() async {
    final ResultadoDaSessao r =
        await ref.read(cronometroProvider.notifier).salvar();
    if (!mounted) return;
    final String texto = switch (r) {
      ResultadoDaSessao.salva => 'Sessão salva',
      ResultadoDaSessao.descartada => 'Sessão de 12 h ou mais: descartada',
      ResultadoDaSessao.nenhuma => 'Nenhuma sessão em andamento',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  String _formatar(Duration d) {
    final String hh = d.inHours.toString().padLeft(2, '0');
    final String mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _porExtenso(Duration d) =>
      '${d.inHours} horas e ${d.inMinutes.remainder(60)} minutos';

  @override
  Widget build(BuildContext context) {
    final SessaoEmAndamento? sessao = ref.watch(cronometroProvider);
    final bool offline = ref.watch(estaOfflineProvider);
    final ColorScheme cores = Theme.of(context).colorScheme;
    final Duration decorrido =
        sessao?.duracao(ref.watch(relogioProvider).agora()) ?? Duration.zero;

    return Scaffold(
      appBar: AppBar(title: const Text('Sessão de estudo')),
      body: Column(
        children: <Widget>[
          // Faixa discreta, nunca diálogo modal: estar offline não é erro.
          if (offline)
            Container(
              key: const Key('faixa_offline'),
              width: double.infinity,
              color: cores.errorContainer,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Sem rede. A sessão continua e sincroniza depois.',
                textAlign: TextAlign.center,
                // onErrorContainer, não a cor padrão do corpo: é aqui
                // que o textContrastGuideline costuma reprovar.
                style: TextStyle(color: cores.onErrorContainer),
              ),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Semantics(
                    // Anuncia sozinho quando muda de pausado para rodando.
                    liveRegion: true,
                    label: 'Tempo de estudo',
                    value: _porExtenso(decorrido),
                    // Sem isto, o leitor soletra "zero zero dois pontos…".
                    excludeSemantics: true,
                    child: Text(
                      _formatar(decorrido),
                      key: const Key('cronometro'),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (sessao == null)
                    FilledButton(
                      key: const Key('botao_iniciar'),
                      style:
                          FilledButton.styleFrom(minimumSize: const Size(88, 48)),
                      onPressed: () => unawaited(ref
                          .read(cronometroProvider.notifier)
                          .iniciar(widget.materiaId)),
                      child: const Text('Iniciar sessão'),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          key: const Key('botao_pausa'),
                          icon: Icon(sessao.rodando
                              ? Icons.pause
                              : Icons.play_arrow),
                          // O tooltip vira o rótulo semântico — e descreve
                          // a AÇÃO, não o desenho do ícone.
                          tooltip: sessao.rodando
                              ? 'Pausar a sessão'
                              : 'Retomar a sessão',
                          constraints: const BoxConstraints(
                              minWidth: 48, minHeight: 48),
                          onPressed: () => unawaited(sessao.rodando
                              ? ref.read(cronometroProvider.notifier).pausar()
                              : ref.read(cronometroProvider.notifier).retomar()),
                        ),
                        const SizedBox(width: 16),
                        BotaoSalvarSessao(onSalvarPressionado: _salvar),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

> ⚠️ O construtor de `BotaoSalvarSessao` acima usa `aoSalvar`; na chamada, escreva
> `BotaoSalvarSessao(aoSalvar: _salvar)`. Mantenha um nome só — o analisador pega a divergência.

```dart
// ── lib/features/materias/domain/materia.dart ────────────────────────────
class Materia {
  // Construtor const é o que LIBERA widget const lá na frente.
  const Materia({required this.id, required this.nome, required this.capa});

  factory Materia.doMapa(Map<String, Object?> m) => Materia(
        id: m['id']! as String,
        nome: m['nome']! as String,
        capa: m['capa']! as String,
      );

  final String id;
  final String nome;

  /// Caminho do arquivo copiado da galeria para a pasta de documentos.
  final String capa;
}

class ResumoDeEstudo {
  const ResumoDeEstudo({
    required this.totalMinutos,
    required this.materiaCampea,
    required this.minutosDaCampea,
  });

  final int totalMinutos;
  final String materiaCampea;
  final int minutosDaCampea;
}

// ── lib/features/materias/data/materia_dao.dart ──────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../sessoes/data/armazenamento.dart';
import '../domain/materia.dart';

class MateriaDao {
  MateriaDao(this._db);

  final Database _db;

  /// ❌ ANTES: _db.rawQuery("SELECT * FROM materias WHERE nome LIKE '%$termo%'")
  /// Um nome com apóstrofo ("D'Ávila") quebra a consulta; um termo com
  /// `'; DROP TABLE materias; --` apaga a tabela.
  ///
  /// ✅ O `?` garante que o valor NUNCA é interpretado como SQL.
  Future<List<Materia>> buscar(String termo) async {
    final List<Map<String, Object?>> linhas = await _db.query(
      'materias',
      where: 'nome_ordenacao LIKE ?',
      whereArgs: <Object?>['%${termo.toLowerCase()}%'],
      orderBy: 'nome_ordenacao',
    );
    return linhas.map(Materia.doMapa).toList();
  }

  /// Sem valor vindo de fora: aqui o rawQuery é seguro e é o mais direto.
  Future<List<Map<String, Object?>>> minutosPorSessao() =>
      _db.rawQuery('SELECT materia_id, minutos FROM sessoes');
}

final Provider<MateriaDao> materiaDaoProvider =
    Provider<MateriaDao>((Ref ref) => MateriaDao(ref.watch(bancoProvider)));

final FutureProvider<List<Materia>> materiasProvider =
    FutureProvider<List<Materia>>(
        (Ref ref) => ref.watch(materiaDaoProvider).buscar(''));

// ── lib/features/materias/presentation/lista_materias_screen.dart ────────
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/materia_dao.dart';
import '../domain/materia.dart';

/// Função de TOPO: o corpo roda dentro do isolate.
/// Recebe e devolve só dados — nada de `Database`, `Ref` ou `context`.
ResumoDeEstudo resumirSessoes(List<Map<String, Object?>> linhas) {
  final Map<String, int> porMateria = <String, int>{};
  int total = 0;
  for (final Map<String, Object?> l in linhas) {
    final String id = l['materia_id']! as String;
    final int minutos = l['minutos']! as int;
    total += minutos;
    porMateria[id] = (porMateria[id] ?? 0) + minutos;
  }
  String campea = '—';
  int maior = 0;
  porMateria.forEach((String id, int m) {
    if (m > maior) {
      maior = m;
      campea = id;
    }
  });
  return ResumoDeEstudo(
    totalMinutos: total,
    materiaCampea: campea,
    minutosDaCampea: maior,
  );
}

final FutureProvider<ResumoDeEstudo> resumoProvider =
    FutureProvider<ResumoDeEstudo>((Ref ref) async {
  final List<Map<String, Object?>> linhas =
      await ref.watch(materiaDaoProvider).minutosPorSessao();

  // 50 000 sessões passam de 50 ms: vale o isolate. A closure captura
  // SÓ `linhas` — capturar `ref` ou `context` daria erro em execução.
  return Isolate.run(() => resumirSessoes(linhas));
});

class ListaMateriasScreen extends ConsumerWidget {
  const ListaMateriasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // width/height = tamanho na TELA; cacheWidth/cacheHeight = MEMÓRIA.
    final int lado = (56 * MediaQuery.devicePixelRatioOf(context)).round();
    final AsyncValue<List<Materia>> materias = ref.watch(materiasProvider);
    final AsyncValue<ResumoDeEstudo> resumo = ref.watch(resumoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matérias')),
      body: Column(
        children: <Widget>[
          Semantics(
            liveRegion: true,
            child: Text(
              resumo.when(
                data: (ResumoDeEstudo r) => '${r.totalMinutos} minutos no total',
                loading: () => 'Somando…',
                error: (Object e, StackTrace s) => 'Não foi possível somar',
              ),
            ),
          ),
          Expanded(
            child: materias.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, StackTrace s) =>
                  const Center(child: Text('Não foi possível carregar')),
              data: (List<Materia> lista) => ListView.builder(
                // Só porque TODOS os itens têm exatamente 72 px.
                itemExtent: 72,
                itemCount: lista.length,
                itemBuilder: (BuildContext context, int i) {
                  final Materia m = lista[i];
                  return _MateriaTile(
                    key: ValueKey<String>(m.id), // a key vem do DADO
                    materia: m,
                    ladoCache: lado,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MateriaTile extends StatelessWidget {
  const _MateriaTile({
    required this.materia,
    required this.ladoCache,
    super.key,
  });

  final Materia materia;
  final int ladoCache;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // minHeight, nunca height: com a fonte a 200 % o texto precisa crescer.
      constraints: const BoxConstraints(minHeight: 48),
      child: MergeSemantics(
        child: Row(
          children: <Widget>[
            Image.file(
              File(materia.capa),
              width: 56,
              height: 56,
              // A capa da galeria é 4032 × 3024 ≈ 48 MB decodificada.
              // Com cacheWidth/cacheHeight cai para ~0,1 MB.
              cacheWidth: ladoCache,
              cacheHeight: ladoCache,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(materia.nome)),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Estudar ${materia.nome}',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: () => Navigator.of(context)
                  .pushNamed('/sessao', arguments: materia.id),
            ),
          ],
        ),
      ),
    );
  }
}

// ── lib/core/config/ambiente.dart ────────────────────────────────────────
/// Configuração por ambiente. Tira o valor do GIT, não do binário —
/// e continua legível num `strings` do APK. Não é segredo.
abstract final class Ambiente {
  // ⚠️ String.fromEnvironment só funciona em contexto const.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api-dev.foco.com.br',
  );
}

// ── lib/main.dart ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'features/materias/presentation/lista_materias_screen.dart';
import 'features/sessoes/data/armazenamento.dart';
import 'features/sessoes/presentation/sessao_screen.dart';

Future<Database> abrirBanco() async {
  return openDatabase(
    p.join(await getDatabasesPath(), 'foco.db'),
    version: 1,
    onCreate: (Database db, int v) async {
      await db.execute('''
        CREATE TABLE materias(
          id TEXT PRIMARY KEY,
          nome TEXT NOT NULL,
          nome_ordenacao TEXT NOT NULL,
          capa TEXT NOT NULL
        )''');
      await db.execute('''
        CREATE TABLE sessoes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          materia_id TEXT NOT NULL,
          iniciada_em INTEGER NOT NULL,
          minutos INTEGER NOT NULL
        )''');
      await db.insert('materias', <String, Object?>{
        'id': 'dart',
        'nome': 'Dart',
        'nome_ordenacao': 'dart',
        'capa': '',
      });
    },
  );
}

/// Um único lugar monta as dependências reais — `main` e o teste de
/// integração chamam a MESMA função.
Future<List<Override>> overridesDoApp() async {
  final Database db = await abrirBanco();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return <Override>[
    bancoProvider.overrideWithValue(db),
    rascunhoProvider.overrideWithValue(RascunhoEmPreferences(prefs)),
  ];
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    overrides: await overridesDoApp(),
    child: const FocoApp(),
  ));
}

class FocoApp extends StatelessWidget {
  const FocoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foco',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings s) => switch (s.name) {
        '/' => MaterialPageRoute<void>(
            builder: (_) => const ListaMateriasScreen()),
        '/sessao' => MaterialPageRoute<void>(
            builder: (_) =>
                SessaoScreen(materiaId: s.arguments! as String)),
        _ => MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Center(child: Text('404')))),
      },
    );
  }
}
```

```dart
// ── test/apoio/fakes.dart ────────────────────────────────────────────────
import 'dart:async';

import 'package:foco_qualidade/core/rede/observador_de_rede.dart';
import 'package:foco_qualidade/core/tempo/relogio_do_app.dart';
import 'package:foco_qualidade/features/sessoes/data/armazenamento.dart';
import 'package:foco_qualidade/features/sessoes/domain/sessao_em_andamento.dart';

class RelogioControlado implements RelogioDoApp {
  RelogioControlado(this._agora);

  DateTime _agora;

  /// Viagem no tempo: é isto que torna "12 h" um teste de 2 ms.
  void avancar(Duration d) => _agora = _agora.add(d);

  @override
  DateTime agora() => _agora;
}

/// Fake do CONTRATO: nada de `connectivity_plus` aqui dentro —
/// é assim que `flutter test` deixa de dar MissingPluginException.
class ObservadorDeRedeFake implements ObservadorDeRede {
  ObservadorDeRedeFake(
      [this._atual = const LeituraDeRede(EstadoDeRede.comInterface)]);

  LeituraDeRede _atual;
  final StreamController<LeituraDeRede> _controlador =
      StreamController<LeituraDeRede>.broadcast();

  void emitir(LeituraDeRede leitura) {
    _atual = leitura;
    _controlador.add(leitura);
  }

  Future<void> fechar() => _controlador.close();

  @override
  Future<LeituraDeRede> atual() async => _atual;

  @override
  Stream<LeituraDeRede> observar() => _controlador.stream;
}

class RascunhoEmMemoria implements RascunhoDeSessao {
  SessaoEmAndamento? guardado;
  int gravacoes = 0; // spy embutido

  @override
  Future<void> salvar(SessaoEmAndamento sessao) async {
    gravacoes++;
    guardado = sessao;
  }

  @override
  Future<SessaoEmAndamento?> ler() async => guardado;

  @override
  Future<void> limpar() async => guardado = null;
}

class RegistroEmMemoria implements RegistroDeSessoes {
  final List<SessaoConcluida> registradas = <SessaoConcluida>[];

  @override
  Future<void> registrar(SessaoConcluida sessao) async =>
      registradas.add(sessao);
}

// ── test/sessao_em_andamento_test.dart ───────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_qualidade/features/sessoes/domain/sessao_em_andamento.dart';

void main() {
  final DateTime inicio = DateTime(2026, 3, 10, 14);

  late SessaoEmAndamento sessao;

  // setUp, não setUpAll: cada teste começa do mesmo estado.
  setUp(() {
    sessao = SessaoEmAndamento(materiaId: 'dart', iniciadaEm: inicio);
  });

  group('duração pelo carimbo', () {
    test('mede pela diferença, não por contador', () {
      expect(sessao.duracao(inicio.add(const Duration(minutes: 45))),
          const Duration(minutes: 45));
    });

    test('app suspenso não perde tempo', () {
      // O Timer teria parado; o carimbo não.
      expect(sessao.minutos(inicio.add(const Duration(hours: 1))), 60);
    });

    test('relógio que anda para trás não vira negativo', () {
      expect(sessao.duracao(inicio.subtract(const Duration(minutes: 5))),
          Duration.zero);
    });

    test('pausa é descontada', () {
      final SessaoEmAndamento pausada =
          sessao.pausar(inicio.add(const Duration(minutes: 20)));
      final SessaoEmAndamento retomada =
          pausada.retomar(inicio.add(const Duration(minutes: 50)));

      // 60 min de relógio, 30 min de pausa → 30 min de estudo.
      expect(retomada.minutos(inicio.add(const Duration(minutes: 60))), 30);
    });

    test('pausada congela o cronômetro', () {
      final SessaoEmAndamento pausada =
          sessao.pausar(inicio.add(const Duration(minutes: 20)));
      expect(pausada.rodando, isFalse);
      expect(pausada.duracao(inicio.add(const Duration(hours: 3))),
          const Duration(minutes: 20));
    });
  });

  group('descarte de sessão suspeita', () {
    test('11h59 ainda é válida', () {
      final DateTime agora =
          inicio.add(const Duration(hours: 11, minutes: 59));
      expect(sessao.ehSuspeita(agora), isFalse);
      expect(sessao.concluir(agora), isNotNull);
    });

    test('a fronteira exata de 12 h já é descartada', () {
      final DateTime agora = inicio.add(const Duration(hours: 12));
      expect(sessao.ehSuspeita(agora), isTrue);
      expect(sessao.concluir(agora), isNull); // null = descartada
    });

    test('concluir devolve os minutos reais', () {
      final SessaoConcluida? c =
          sessao.concluir(inicio.add(const Duration(minutes: 90)));
      expect(c!.minutos, 90);
      expect(c.materiaId, 'dart');
    });
  });

  test('ida e volta por JSON preserva pausa e carimbo', () {
    final SessaoEmAndamento pausada =
        sessao.pausar(inicio.add(const Duration(minutes: 20)));
    final SessaoEmAndamento volta =
        SessaoEmAndamento.deJson(pausada.paraJson());

    expect(volta.iniciadaEm, inicio);
    expect(volta.rodando, isFalse);
    expect(volta.duracao(inicio.add(const Duration(hours: 5))),
        const Duration(minutes: 20));
  });
}

// ── test/sessao_screen_test.dart ─────────────────────────────────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_qualidade/core/rede/observador_de_rede.dart';
import 'package:foco_qualidade/core/tempo/relogio_do_app.dart';
import 'package:foco_qualidade/features/sessoes/data/armazenamento.dart';
import 'package:foco_qualidade/features/sessoes/presentation/sessao_screen.dart';

import 'apoio/fakes.dart';

void main() {
  late RelogioControlado relogio;
  late ObservadorDeRedeFake rede;
  late RascunhoEmMemoria rascunho;
  late RegistroEmMemoria registro;

  setUp(() {
    relogio = RelogioControlado(DateTime(2026, 3, 10, 14));
    rede = ObservadorDeRedeFake();
    rascunho = RascunhoEmMemoria();
    registro = RegistroEmMemoria();
    addTearDown(rede.fechar);
  });

  Widget montar({TargetPlatform plataforma = TargetPlatform.android}) {
    return ProviderScope(
      // Nenhum plugin entra no teste: só os contratos.
      overrides: <Override>[
        relogioProvider.overrideWithValue(relogio),
        observadorDeRedeProvider.overrideWithValue(rede),
        rascunhoProvider.overrideWithValue(rascunho),
        registroDeSessoesProvider.overrideWithValue(registro),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: plataforma, colorSchemeSeed: Colors.indigo),
        home: const SessaoScreen(materiaId: 'dart'),
      ),
    );
  }

  /// ⚠️ `pump`, NUNCA `pumpAndSettle`: o `Timer.periodic` do cronômetro
  /// agenda quadro para sempre e o `pumpAndSettle` estoura o prazo.
  Future<void> assentar(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));
  }

  group('faixa de offline', () {
    testWidgets('não aparece com rede', (WidgetTester t) async {
      await t.pumpWidget(montar());
      await assentar(t);
      expect(find.byKey(const Key('faixa_offline')), findsNothing);
    });

    testWidgets('aparece quando o fake fica sem interface',
        (WidgetTester t) async {
      await t.pumpWidget(montar());
      await assentar(t);

      rede.emitir(const LeituraDeRede(EstadoDeRede.semInterface));
      await assentar(t);

      expect(find.byKey(const Key('faixa_offline')), findsOneWidget);
    });
  });

  group('adaptação por plataforma', () {
    testWidgets('no Android o salvar é FilledButton', (WidgetTester t) async {
      await t.pumpWidget(montar());
      await assentar(t);
      await t.tap(find.byKey(const Key('botao_iniciar')));
      await assentar(t);

      expect(find.byType(FilledButton), findsWidgets);
      expect(find.byType(CupertinoButton), findsNothing);
    });

    testWidgets('no iOS o salvar vira CupertinoButton',
        (WidgetTester t) async {
      // Sem Mac, sem emulador: ThemeData(platform:) basta.
      await t.pumpWidget(montar(plataforma: TargetPlatform.iOS));
      await assentar(t);
      await t.tap(find.byKey(const Key('botao_iniciar')));
      await assentar(t);

      expect(find.byType(CupertinoButton), findsOneWidget);
    });
  });

  testWidgets('cumpre as quatro diretrizes de acessibilidade',
      (WidgetTester t) async {
    // ⚠️ A árvore de semântica não é construída por padrão nos testes.
    // Sem ensureSemantics, tudo passa à toa.
    final SemanticsHandle handle = t.ensureSemantics();

    await t.pumpWidget(montar());
    await assentar(t);
    await t.tap(find.byKey(const Key('botao_iniciar')));
    await assentar(t);
    rede.emitir(const LeituraDeRede(EstadoDeRede.semInterface));
    await assentar(t);

    await expectLater(t, meetsGuideline(androidTapTargetGuideline)); // 48 dp
    await expectLater(t, meetsGuideline(iOSTapTargetGuideline)); // 44 pt
    await expectLater(t, meetsGuideline(textContrastGuideline)); // 4,5:1
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose(); // senão a semântica vaza para o próximo teste
  });

  testWidgets('sessão de 12 h restaurada é descartada',
      (WidgetTester t) async {
    rascunho.guardado = SessaoEmAndamento(
      materiaId: 'dart',
      iniciadaEm: relogio.agora().subtract(const Duration(hours: 13)),
    );

    await t.pumpWidget(montar());
    await assentar(t);

    // A tela voltou ao estado inicial: a regra do domínio agiu.
    expect(find.byKey(const Key('botao_iniciar')), findsOneWidget);
    expect(rascunho.guardado, isNull);
  });
}

// ── integration_test/apoio/ajudantes.dart ────────────────────────────────
import 'package:flutter_test/flutter_test.dart';

/// Espera pela CONDIÇÃO, não pelo relógio.
/// `Future.delayed(5s)` passa a falhar no CI e desperdiça 5 s sempre.
Future<void> esperarPor(
  WidgetTester tester,
  Finder alvo, {
  Duration limite = const Duration(seconds: 15),
  Duration intervalo = const Duration(milliseconds: 100),
}) async {
  final DateTime fim = DateTime.now().add(limite);
  while (DateTime.now().isBefore(fim)) {
    await tester.pump(intervalo);
    if (alvo.evaluate().isNotEmpty) return;
  }
  fail('Não apareceu em ${limite.inSeconds}s: ${alvo.description}');
}

// ── integration_test/fluxo_sessao_test.dart ──────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:foco_qualidade/core/tempo/relogio_do_app.dart';
import 'package:foco_qualidade/main.dart';

import '../test/apoio/fakes.dart';
import 'apoio/ajudantes.dart';

void main() {
  // Obrigatório, antes de tudo: sem isto os plugins nativos dão
  // MissingPluginException mesmo rodando no aparelho.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('iniciar → pausar → retomar → salvar', (WidgetTester t) async {
    // sqflite, SharedPreferences e navegação são REAIS. Só o relógio é
    // controlado — senão a asserção de minutos dependeria do CI.
    final RelogioControlado relogio = RelogioControlado(DateTime(2026, 3, 10, 14));

    await t.pumpWidget(ProviderScope(
      overrides: <Override>[
        ...await overridesDoApp(),
        relogioProvider.overrideWithValue(relogio),
      ],
      child: const FocoApp(),
    ));

    // 1. Abre a matéria semeada pelo onCreate.
    await esperarPor(t, find.text('Dart'));
    await t.tap(find.byTooltip('Estudar Dart'));
    await esperarPor(t, find.byKey(const Key('botao_iniciar')));

    // 2. Inicia.
    await t.tap(find.byKey(const Key('botao_iniciar')));
    await esperarPor(t, find.byKey(const Key('botao_pausa')));

    // 3. Pausa aos 40 min.
    relogio.avancar(const Duration(minutes: 40));
    await t.tap(find.byKey(const Key('botao_pausa')));
    await esperarPor(t, find.byTooltip('Retomar a sessão'));

    // 4. Fica 30 min pausada e retoma — esses 30 min NÃO contam.
    relogio.avancar(const Duration(minutes: 30));
    await t.tap(find.byKey(const Key('botao_pausa')));
    await esperarPor(t, find.byTooltip('Pausar a sessão'));

    // 5. Mais 5 min e salva: 45 min de estudo.
    relogio.avancar(const Duration(minutes: 5));
    await esperarPor(t, find.text('00:45:00'));
    await t.tap(find.byKey(const Key('botao_salvar')));

    await esperarPor(t, find.text('Sessão salva'));
    await esperarPor(t, find.byKey(const Key('botao_iniciar')));
  });
}
```

**Medição em profile** — Moto G84, `flutter run --profile -d <aparelho>`, rolagem da lista de 5 000 matérias, DevTools → Performance:

| Momento | Pior quadro 🔵 UI | Pior quadro 🟢 raster | Diagnóstico |
|---|---:|---:|---|
| Antes | **41 ms** | 6 ms | Barra **azul**: `ListView(children:)` construía as 5 000 linhas de uma vez e `Image.file` decodificava o JPEG de 4032 × 3024 |
| Depois | **7 ms** | 5 ms | `ListView.builder` + `itemExtent` + `cacheWidth`/`cacheHeight`; dentro do orçamento de 16 ms |

O resumo de 50 000 sessões levava 320 ms na UI thread (barra azul isolada, a lista congelava ao abrir); com `Isolate.run` caiu para 4 ms na UI thread — o trabalho continua existindo, só saiu de onde travava.

**Build de release e símbolos** (🪟 PowerShell, crase é a continuação de linha):

```powershell
flutter build appbundle --release `
  --dart-define=API_URL=https://api.foco.com.br `
  --obfuscate `
  --split-debug-info=build/simbolos/1.0.0

# Os símbolos são artefato do CI: sem ELES, o crash daquela versão
# fica ilegível para sempre — recompilar gera um binário diferente.
flutter symbolize -i crash.txt -d build/simbolos/1.0.0/app.android-arm64.symbols
```

O token do usuário não aparece em lugar nenhum acima: ele é gravado em `flutter_secure_storage` quando o login responde, e lido de lá a cada requisição.

O avaliador deve procurar, em ordem: (1) que `SessaoEmAndamento` não importa nada de Flutter e recebe o instante por parâmetro — se houver um `DateTime.now()` dentro do domínio, o critério de 2 pontos cai pela metade, porque o teste de "12 h" volta a ser impossível de escrever; (2) que os testes de widget sobrescrevem **contratos**, não plugins — qualquer `connectivity_plus` ou `SharedPreferences` importado dentro de `test/` é sinal de que o `MissingPluginException` só foi adiado; (3) que o teste de acessibilidade tem `ensureSemantics()` **e** `handle.dispose()` em volta das quatro diretrizes: sem o primeiro, o `expectLater` passa numa tela sem rótulo nenhum; (4) que nem o teste de widget nem o de integração usam `pumpAndSettle` ou `Future.delayed` — com `Timer.periodic` na tela, o primeiro estoura o prazo e o segundo só torna o teste instável com menos frequência. Nos números de profile, exija os dois valores e a cor: "ficou mais rápido" não vale ponto; "de 41 ms para 7 ms de UI thread, raster estável em 5 ms" vale. E confira o `rawQuery` interpolado: se sobrou um `'%$termo%'` dentro de uma string SQL, o critério de segurança é zero mesmo com tudo o mais correto.

---

<a id="cumulativa-05"></a>
## Cumulativa 05 — Build e distribuição

> Confira depois de fazer a [avaliação](../avaliacoes/cumulativa-05-build-e-distribuicao.md).

### Questionário

1. **B** — o Play App Signing separa as duas chaves: a de **assinatura do app** fica com o Google e a de **upload** é sua e resetável por chamado; só sem ele a perda seria definitiva.
2. **B** — o Android tem uma peça (keystore), emitida por você e com validade que você escolhe; o iOS tem cinco, emitidas pela Apple, com certificado de 1 ano e aparelhos listados por UDID no profile.
3. **B** — o formulário vale sobre o **manifest fundido**, não sobre o seu arquivo: permissão que você não usa sai com `tools:node="remove"`, e o que fica tem que aparecer declarado; contradição é suspensão, não aviso.
4. **B** — `versionCode` e `CFBundleVersion` são monotônicos nas duas lojas; binário rejeitado ou descartado não devolve o número, e repetir dá `ITMS-4238` na Apple e recusa de upload na Play.
5. **C** — AAB é obrigatório para app novo na loja e **não** instala direto; para o colega vai o APK `arm64-v8a`; o TestFlight só aceita `.ipa`, que exige macOS para ser gerado.
6. **B** — `flutter build ipa` só existe em macOS, e 1 min de `macos-latest` consome 10 min da cota; por isso ele fica preso a `push` de tag, nunca a cada push.
7. **D** — `flutter symbolize` precisa dos símbolos **daquele** build exato, gravados por `--split-debug-info`; símbolos de outro build não resolvem, e é por isso que a pasta é arquivada com a release.
8. **B** — o segredo entra por `secrets.*`, é decodificado para um arquivo dentro do runner e as senhas viajam por `env`; o mascaramento do GitHub cobre só o valor exato, então variável derivada nunca pode ir para o log.
9. A chave privada do iOS vive no Keychain do Mac e sem ela o certificado é inútil — mas a Apple **revoga e reemite**: novo CSR, novo certificado, novo profile, e você segue publicando. O keystore do Android, sem Play App Signing, é definitivo: o sistema só aceita atualização assinada pela mesma chave, então perdê-la significa nunca mais atualizar aquele `applicationId`. Com Play App Signing a comparação se inverte — a chave que assina o que chega ao aparelho está com o Google, a sua vira só chave de upload, e a perda passa a ser um chamado. Em resumo: a burocracia das cinco peças da Apple compra recuperação; a simplicidade da peça única do Android compra risco.
10. O Foco deixa de ser "não coleta". Na **Segurança dos Dados** da Play você passa a declarar "Informações de diagnóstico / registros de falha", com finalidade e se é opcional; na **Nutrition Label** da Apple entra "Diagnóstico", marcado como não vinculado à identidade se o identificador for aleatório. Nunca entram no log: conteúdo digitado pelo usuário (anotação da sessão), token, e-mail ou CPF — é o princípio da **minimização** da LGPD, somado a finalidade e consentimento. No lugar, contexto sem conteúdo: `log('Salvando anotação (${texto.length} chars)')` e `setCustomKey('tela', 'detalhe_materia')`.
11. No 🤖 Android a `<uses-permission>` faltando falha **em execução e em silêncio**: o recurso simplesmente não funciona no artefato de release, como no caso clássico do `INTERNET` declarado só no `debug/AndroidManifest.xml`, que passa no `flutter run` e quebra no APK. No 🍎 iOS a chave `NS…UsageDescription` ausente derruba o app no primeiro acesso ao recurso e, antes disso, é **rejeição na revisão humana** — e texto genérico reprova igual. Consequência prática: o iOS empurra a revisão dos textos para antes do envio, porque é bloqueio de loja; o Android empurra a conferência do manifest fundido e um teste do artefato de release no aparelho, porque o debug esconde o erro.
12. Automatize `analyze`, `test` e `dart format --set-exit-if-changed` a cada push (Ubuntu, 1× a cota), build Android em tag, envio ao TestFlight interno e arquivamento dos símbolos. Deixe manual a decisão de publicar, o texto de "Novidades", o rollout gradual e a promoção para produção — o padrão é "CI completo, CD até a porta da loja". O build iOS fica só em tag porque o minuto de macOS custa 10×: quatro builds de 12 min já consomem 480 min do mês. E o que ele pega não é erro de código (isso o Ubuntu já pegou), é erro de assinatura e de pods, que só importa quando se vai gerar artefato de verdade.
13.

| | 🌐 Web (PWA) | 🤖 Android | 🍎 iOS |
|---|---|---|---|
| Identidade | **A URL** (origem: protocolo + domínio + caminho) | `applicationId` | *Bundle ID* |
| Se a identidade mudar | O navegador trata como **outro app**: quem instalou fica com o atalho antigo e **o banco IndexedDB não vai junto** — todos começam do zero | Vira outro app na loja; não há atualização a partir do antigo | Idem |
| Correção alcança todo mundo em | **~2 abertura(s)**, ou seja, ~48 h | Dias a **nunca** | Dias a **nunca** |

O pior caso de "usuário preso em versão antiga" é o das **lojas**, não o da web — e isso costuma surpreender. Na web o service worker baixa a versão nova sozinho e a serve na abertura seguinte: o atraso é de **uma abertura**, e o aviso por `controllerchange` reduz até isso. Nas lojas, a atualização depende de o usuário aceitar; meses depois de um hotfix ainda chega stack trace da versão com o bug, e o número de versões simultâneas em campo é indefinido. A web tem **duas** versões em campo, no máximo. O que a web tem de pior é outra coisa: a identidade é mais fácil de mudar por acidente — renomear um repositório ou migrar para domínio próprio parece inofensivo e apaga o banco de todos.

14. O pipeline web não tem segredo porque **não há assinatura**: qualquer pessoa pode servir aqueles arquivos, e a confiança vem do **HTTPS do domínio**, não de uma chave que prova autoria. O `deploy-pages` ainda usa OIDC — um token de curta duração emitido para aquela execução —, então nem o token de deploy fica guardado. O da Play precisa da keystore porque o Android exige que toda atualização seja assinada **pela mesma chave** da versão anterior.

Em risco operacional: o pipeline web **não tem o que vazar**. O da Play guarda um segredo de valor máximo e irreversível — vazada a keystore, um terceiro pode assinar artefatos como você; perdida, você nunca mais atualiza aquele `applicationId`. Um `echo` numa variável derivada, um log de debug, um fork mal configurado, e o dano não tem desfazer.

E isso não torna a web mais segura, porque o risco migra de lugar. No Android o **artefato** é opaco: extrair um `--dart-define` do `libapp.so` exige desempacotar e vasculhar um binário. Na web o artefato é **texto**: o `main.dart.js` abre no DevTools e um Ctrl+F acha qualquer string. Não existe `--obfuscate`, só minificação, que não é segurança. Por isso "segredo mora no servidor" deixa de ser recomendação e vira restrição: no mobile é uma boa prática com custo de ataque alto; na web o custo de ataque é **uma tecla**. Chave no cliente só se for pública e restrita por domínio — e aí o que protege é a restrição, não o sigilo.

### Solução prática de referência

```properties
# android/key.properties — NUNCA versionado. Entre no .gitignore ANTES de criar.
# Barras normais mesmo no Windows: em .properties a "\" é escape.
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=SEU_ALIAS
storeFile=C:/Users/SEU_USUARIO/chaves/foco-upload.jks
```

```kotlin
// android/app/build.gradle.kts
import java.io.FileInputStream
import java.util.Properties

val chaves = Properties()
val arquivoChaves = rootProject.file("key.properties")
if (arquivoChaves.exists()) chaves.load(FileInputStream(arquivoChaves))

android {
    signingConfigs {
        create("release") {
            keyAlias = chaves["keyAlias"] as String
            keyPassword = chaves["keyPassword"] as String
            storeFile = (chaves["storeFile"] as String?)?.let { file(it) }
            storePassword = chaves["storePassword"] as String
        }
    }
    buildTypes {
        release {
            // Substitui signingConfigs.getByName("debug") que o Flutter gera.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

```yaml
# pubspec.yaml — MINOR porque há recurso novo compatível; build 11 -> 12, nunca reaproveitado.
version: 1.2.0+12
```

```powershell
# Windows — release local e prova da assinatura
flutter clean
flutter pub get
flutter build appbundle --release --obfuscate --split-debug-info=simbolos/1.2.0+12
flutter build apk --release --target-platform android-arm64 `
  --obfuscate --split-debug-info=simbolos/1.2.0+12

# Prova que NÃO é a chave de depuração (procure por CN=, não por "Android Debug")
apksigner verify --print-certs .\build\app\outputs\flutter-apk\app-release.apk

git commit -am "Release 1.2.0 - metas semanais"
git tag -a v1.2.0 -m "Metas semanais"
git show v1.2.0
```

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:

jobs:
  verificar:                     # a cada push — 1x a cota
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test

  android:                       # só em tag
    needs: verificar
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
      - name: Restaurar keystore e key.properties
        env:
          KEYSTORE_B64: ${{ secrets.ANDROID_KEYSTORE_B64 }}
          STORE_PASSWORD: ${{ secrets.ANDROID_STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
        run: |
          echo "$KEYSTORE_B64" | base64 -d > android/app/upload-keystore.jks
          printf 'storePassword=%s\nkeyPassword=%s\nkeyAlias=%s\nstoreFile=upload-keystore.jks\n' \
            "$STORE_PASSWORD" "$KEY_PASSWORD" "$KEY_ALIAS" > android/key.properties
      - run: flutter pub get
      - run: flutter build appbundle --release --obfuscate --split-debug-info=simbolos/1.2.0+12
      - uses: actions/upload-artifact@v4
        with:
          name: simbolos-1.2.0+12
          path: simbolos/

  ios:                           # só em tag — 10x a cota
    needs: verificar
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
      - name: Importar certificado e provisioning profile
        env:
          P12: ${{ secrets.IOS_CERT_P12_B64 }}
          P12_SENHA: ${{ secrets.IOS_CERT_SENHA }}
          PROFILE: ${{ secrets.IOS_PROFILE_B64 }}
        run: |
          echo "$P12" | base64 -d > cert.p12
          echo "$PROFILE" | base64 -d > perfil.mobileprovision
          security create-keychain -p acao build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p acao build.keychain
          security import cert.p12 -k build.keychain -P "$P12_SENHA" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k acao build.keychain
          mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
          cp perfil.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/"
      - run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

```markdown
<!-- docs/release-1.2.0.md -->
## Segurança dos Dados × manifest fundido
`INTERNET` (normal) e `POST_NOTIFICATIONS` (perigosa) — conferidas no manifest fundido em
`build/app/intermediates/merged_manifests/release/AndroidManifest.xml`. Nenhuma permissão de
localização, câmera ou contatos. Declaração: "não coleta dados" — o Foco guarda tudo no sqflite.

## Faixa e rollout
Interno -> fechado -> produção com 5% -> 24 h -> 20% -> 24 h -> 50% -> 100%.

## Limites que disparam ação imediata
- Taxa de falhas > 1,09% -> interromper o rollout
- Taxa de ANR > 0,47% -> interromper o rollout
- Símbolos de `simbolos/1.2.0+12` arquivados no artefato do CI, junto do `mapping.txt`

## O que EXIGE macOS (o resto foi feito no Windows)
1. `pod install` / resolução de dependências nativas — precisa do Xcode.
2. `flutter build ipa` (archive `.xcarchive`) — usa o iPhoneOS SDK, que vive dentro do Xcode.
3. Assinatura com `codesign` — lê a chave privada do Keychain do macOS.
4. Validação e envio (Organizer, Transporter ou `altool`) ao App Store Connect.

Alternativa sem comprar Mac: o job `ios` em `macos-latest`, disparado só em tag.
Custo: ~12 min × 10 = 120 min da cota por release.
```

O avaliador deve procurar três provas objetivas: a saída de `apksigner verify --print-certs` mostrando um `CN=` seu, e **não** `CN=Android Debug`; o `release.yml` com `analyze`/`test` em `ubuntu-latest` a cada push e o job iOS preso a `if: startsWith(github.ref, 'refs/tags/v')` em `macos-latest`; e nenhuma senha, caminho de `.jks`, `.p12` ou `.mobileprovision` dentro do YAML ou do `git status` — tudo por `secrets.*`. Aceite datas e textos diferentes no CHANGELOG e outra ordem dos passos, mas não aceite build reiniciado (`+1`) nem tag leve: a tag precisa ter sido criada com `-a`.

---

<a id="avaliacao-final"></a>
## Avaliação final

> Confira depois de fazer a [avaliação](../avaliacoes/avaliacao-final.md).

### Questionário

1. **B** — o `sealed` fecha a hierarquia e torna o `switch` exaustivo: acrescentar `FalhaManutencao` e esquecer um `switch` vira erro de análise. A) o `catch` com `dynamic` captura tudo, inclusive o que você não sabe tratar; C) timeout é `.timeout`, não modelagem; D) o `await` continua exatamente onde estava.
2. **B** — no Riverpod 3 escrever em `state` de um notifier já descartado **lança**; `if (!ref.mounted) return;` depois do `await` é obrigatório. A) `setState` é de `State`, não de notifier; C) `valueOrNull` lê, não protege a escrita; D) `ProviderScope` é da árvore de widgets, não do método.
3. **A** — `pushNamed<Materia>` leva o argumento e devolve o resultado do `pop`. B) variável global some do teste e do `onGenerateRoute`; C) `GlobalKey` não transporta argumento entre rotas; D) `Navigator` faz isso desde sempre, e o curso não usa `go_router`.
4. **B** — `version` maior dispara `onUpgrade`, e o `ALTER TABLE` acrescenta a coluna preservando as linhas. A) apagar o banco destrói matérias e sessões de quem já usa; C) preferences não é lugar de tabela com consulta; D) recriar a cada `openDatabase` é o mesmo apagão, todo dia.
5. **C** — sem `.timeout`, o `Future` nunca completa: não há erro, há espera eterna, e o `AsyncValue` fica em `AsyncLoading` para sempre. A) o `http` não cancela sozinho; B) não existe erro padrão para `Future` pendente; D) sem exceção não há `AsyncError`.
6. **A** — o `SingleChildScrollView` oferece altura infinita à `Column`, e o `ListView` quer ocupar toda a altura disponível: infinito com infinito estoura. B) `Column` aceita rolável **com** altura definida (`SizedBox`, `Expanded`); C) `const` é desempenho, não restrição de layout; D) o `Scaffold` não tem nada com isso.
7. **C** — `ProviderContainer(overrides: [...])` troca o contrato do `domain` por um `Mock`, e `thenAnswer` é o que devolve `Future`. A) `flutter test` não usa emulador; B) `skip` é reprovação automática nos critérios; D) o sqflite real depende de plugin e estoura `MissingPluginException` no teste de unidade.
8. **A** — medir primeiro, em profile e no aparelho, e só então decidir; UI alta e raster baixa levam a caminhos opostos. B) e C) são correção às cegas — e `Column` no lugar de `ListView.builder` piora; D) release não tem DevTools nem instrumentação: não dá para medir.
9. **C** — sem o `.symbols` daquele build exato não existe `flutter symbolize`, e recompilar gera outro binário com outros nomes. A) o Flutter não guarda cópia, e `flutter clean` leva o `build/` junto; B) o app abre normalmente, o binário está intacto; D) a assinatura não tem relação com símbolos.
10. **C** — no Windows você prepara Bundle ID nas três configurações, ícone sem alfa, `version` e `Info.plist` por `$(FLUTTER_BUILD_NAME)`; archive, assinatura e envio pedem macOS (Mac ou runner na CI). A) `flutter build ipa` chama o `xcodebuild`, que só existe no Xcode; B) o simulador do Xcode não roda no Windows; D) o projeto compila e você mexe nele à vontade — o que não roda é a assinatura.

11. Não use quando o trabalho é **espera de I/O** (o `await` já libera a thread de UI), quando ele custa menos que um quadro — criar o isolate custa 50–200 ms, pagos na própria UI thread — e quando o dado é grande ou não atravessa a fronteira: a cópia também acontece na UI, e `BuildContext`, `WidgetRef` e `Database` aberto não passam. No Foco, somar as sessões da semana, decodificar 10 KB de trilhas e formatar datas ficam onde estão; o resumo de 50 000 sessões é o único que paga a conta. Regra: abaixo de 16 ms deixe, acima de 50 ms isole, no meio meça.
*Pontuação:* 0,5 por citar ao menos duas situações (I/O, trabalho curto, custo de cópia ou objeto não copiável); 0,5 por explicar que criação e cópia são pagas na thread de UI. Responder só "porque é rápido" não vale.
12. Na Play você reativa a versão anterior; na App Store existe uma única versão corrente e cada uma passa por revisão humana — "remover da venda" tira o app da loja e não devolve a 1.4.1, e quem já atualizou fica na versão quebrada nas duas lojas. A única saída é publicar a 1.4.3 e esperar a revisão, de horas a dias (ou pedir revisão expedita). No processo isso vira: TestFlight interno obrigatório antes de qualquer envio, phased release ligado (7 dias, ritmo fixo, só dá para pausar), branch de hotfix saindo da **tag** da versão publicada e nada de enviar na sexta.
*Pontuação:* 0,5 por explicar o modelo (versão única + revisão, sem reativar a anterior); 0,5 por ao menos duas mudanças concretas de processo.
13. O critério é a **forma de acesso**, não o tamanho: vai para o sqflite o que é registro em quantidade, consultado, filtrado, ordenado, atualizado em parte e relacionado — matérias e sessões pedem `WHERE materia_id = ?`, soma por semana e `ON DELETE CASCADE`. Fica no `shared_preferences` o punhado de valores escalares lidos e gravados inteiros, sem consulta: a meta semanal é um `int` de minutos lido na abertura. Guardar sessões em preferences obrigaria a reescrever o arquivo inteiro a cada gravação; guardar a meta no banco seria uma tabela de uma linha.
*Pontuação:* 0,5 pelo critério (consulta/relação/volume × escalar lido por inteiro); 0,5 por aplicá-lo às três entidades do Foco.
14. Primeiro a **aba Trilhas**: é defeito visível para quem usa e critério de aprovação — sem `timeout` e sem `AsyncError` desenhado, a tela fica em "carregando" para sempre e não existe caminho de volta. Depois o **teste instável**: nenhum `skip` é aceito, e um teste que oscila deixa de avisar qualquer regressão — inclusive a que você acabou de introduzir nas Trilhas, por isso ele vem antes do polimento. Por último os **12 `info`**: são mecânicos, `dart fix --apply` e `dart format` resolvem a maioria, e o `flutter analyze --fatal-infos` você roda de novo no fim de qualquer jeito.
*Pontuação:* 0,5 pela ordem (erro da Trilhas → teste → analyze); 0,5 pelas justificativas por risco. Outra ordem vale se for justificada por risco; "começo pelo analyze porque é rápido" não vale.
15. A troca se justifica quando aparecerem deep link e Universal Link, versão web com URL de verdade, redirecionamento por autenticação valendo para todas as rotas ou `ShellRoute` com barra inferior persistente e rotas aninhadas — o que `onGenerateRoute` até faz, mas na mão e mal. Hoje o Foco tem cinco telas, nenhum link externo, nenhum login, e a navegação já está centralizada em `Rotas.gerar`, com argumento validado e resultado tipado. Trocar agora significa reescrever toda a navegação e os testes de widget por zero ganho para o usuário, e ainda somar uma dependência a manter.
*Pontuação:* 0,5 por ao menos dois gatilhos concretos; 0,5 por argumentar custo × benefício no estado atual do app.
16. Ofuscação renomeia classes, métodos e campos do Dart: encarece a engenharia reversa e enxuga um pouco o binário — nada além disso. Ela não criptografa: strings, assets e constantes continuam legíveis num `strings` do APK, e o preço é o stack trace ilegível, que só `flutter symbolize` reverte com os símbolos daquele build. Chave que não pode aparecer no app não entra no app: ela fica no **seu servidor**, que chama o terceiro; o app conversa só com o seu backend e guarda o token do usuário no `flutter_secure_storage` (Keystore 🤖 / Keychain 🍎). Chave que já saiu numa release publicada é chave rotacionada.
*Pontuação:* 0,5 por separar "encarece a leitura do código" de "não protege segredo"; 0,5 pela chave no servidor. Responder `--dart-define` ou secure storage como solução para a chave secreta não vale ponto.

### Diagnóstico

**D1 — O trace que não diz nada.**
*Causa:* a 1.0.0 foi gerada com `--obfuscate --split-debug-info`, então `ab.dart:1:4923` não é arquivo nenhum — é o nome ofuscado, e toda a pilha cabe numa linha só. O defeito por baixo é um `first`, `firstWhere` ou `single` sobre coleção vazia (`Bad state: No element`).
*Primeiro comando:*

```powershell
flutter symbolize -i crash.txt -d simbolos/1.0.0/app.android-arm64.symbols
```

Porque o crash aconteceu no aparelho de um desconhecido, dias atrás: não há `flutter logs`, DevTools nem `adb logcat` para rodar. O que você tem é texto, e o `symbolize` trabalha sobre texto — com os símbolos **daquele** build, porque recompilar produz outro binário e outros nomes. Se a pasta `simbolos/1.0.0` já tiver sido perdida, a resposta certa é assumir que a 1.0.0 é ilegível para sempre e passar a arquivar símbolos por versão.

**D2 — A assinatura que não existe.**
*Causa:* o runner não tem a credencial. O keychain temporário ficou sem o certificado (secret `IOS_CERT_P12_B64` vazio, senha errada ou `.p12` vencido) e/ou o `.mobileprovision` não chegou em `~/Library/MobileDevice/Provisioning Profiles`. O texto entrega o segundo suspeito: ele procura profile de **iOS App Development**, ou seja, caiu na assinatura automática de desenvolvimento em vez da manual de distribuição com `ios/ExportOptions.plist`. O terceiro é Bundle ID divergente entre Debug, Release e Profile.
*Primeiro comando* (no próprio job, logo depois do passo de import):

```bash
security find-identity -v -p codesigning "$RUNNER_TEMP/build.keychain"
```

Porque ele separa em um segundo "a credencial não chegou" de "o profile não casa": sem nenhuma identidade listada, regerar profile no portal é tempo perdido — quem falhou foi o `security import`. Só depois de ver o certificado ali é que se olha Bundle ID e `ExportOptions.plist`.

**D3 — O engasgo.**
*Causa:* o trabalho é seu, em Dart, na thread de UI. Barra de UI alta com raster baixa significa Dart caro dentro do `build` — a agregação das 50 000 sessões sendo refeita a cada quadro, não pintura.
*Primeiro comando:*

```powershell
flutter run --profile -d <aparelho>
```

e gravar o **CPU Profiler** do DevTools enquanto abre a aba Estatísticas. Porque o que falta é o nome da função e o número de antes, não um palpite: `Isolate.run` custa 50–200 ms de criação mais a cópia, tudo pago na própria UI thread, e espalhar `const` ou mexer em sombras conserta **raster**, que aqui está baixo. `--trace-skia` é ferramenta de raster, e em release não há como medir.

**D4 — Só quebra em release.**
*Causa:* o processo morreu na camada nativa — sem caixa vermelha e sem Dart vivo, não é erro de framework. "Funciona em debug e quebra em release" tem o **R8** como primeiro suspeito: `isMinifyEnabled = true` sem regra `-keep` para a classe que o plugin da aba Trilhas acessa por reflexão (`ClassNotFoundException` / `NoSuchMethodError` só em release). O segundo suspeito é `INTERNET` declarada só no manifesto de `debug/`.
*Primeiro comando:*

```powershell
adb logcat -c      # limpa; reproduza o fechamento; depois: adb logcat -d > erro.txt
```

Porque `flutter logs` não mostra nada quando não há mais Dart rodando — só o `logcat` tem o `FATAL EXCEPTION` e a primeira linha que menciona `br.com.estudos.foco`. E sem o `-c` antes você lê o log de ontem e não acha nada.

### Prática — o que o avaliador procura

- **Domínio puro (5 pt).** Atendido quando nenhum arquivo de `features/*/domain/` importa `package:flutter`, `package:http` ou `package:sqflite` — confira com um `Select-String`, não de olho — e quando os três testes existem: lista vazia somando zero, fronteira exata (`299` não bate, `300` bate) e `throwsArgumentError` no construtor. Regra de negócio dentro de widget ou de DAO derruba o critério inteiro.
- **Riverpod 3 sem code generation (5 pt).** Atendido quando os providers são declarados à mão (`AsyncNotifierProvider<X, T>(X.new)`), sem `@riverpod` e sem `.g.dart`, e quando **cada** aba que carrega dado desenha os quatro estados — carregando, vazio, erro com botão de tentar de novo, e dados. Vazio tratado como `data` sem mensagem, ou `requireValue` na tela, não atende. Escrita em `state` depois de `await` sem `if (!ref.mounted) return;` custa metade do critério.
- **Persistência com migração provada (5 pt).** Atendido quando existe `onCreate` **e** `onUpgrade`, a `version` subiu para 2 e há um teste que abre o banco na v1, grava matérias e sessões, reabre na v2 e prova que as linhas continuam lá com a coluna nova preenchida pelo `DEFAULT`. Só o `ALTER TABLE` no código, sem evidência de sobrevivência dos dados, vale metade.
- **API de trilhas (5 pt).** Atendido quando existe `.timeout(...)` na chamada, `sealed class Falha` com `FalhaSemConexao`, `FalhaTempoEsgotado`, `FalhaServidor` e `FalhaFormato`, tradução acontecendo no repositório (a tela nunca vê `SocketException`) e comportamento offline definido: cache local ou mensagem com ação. Tela branca, `catch` vazio ou `default:` no `switch` de `Falha` zeram o critério.
- **Navegação (4 pt).** Atendido quando `onGenerateRoute` valida os argumentos com `is!` antes de usar (nada de `as`), o `MaterialPageRoute<Materia>` casa com o `pushNamed<Materia>` de quem chama, há `settings: configuracoes` em todas as rotas, o formulário valida com mensagem que diz o que fazer, e o `PopScope` com `onPopInvokedWithResult` sempre termina em saída possível. `WillPopScope` ou `canPop: false` sem caminho de volta não atende.
- **Acessibilidade (4 pt).** Atendido quando todo ícone clicável tem rótulo (`IconButton` com `tooltip`, ou `Semantics`), os alvos têm `minWidth`/`minHeight` de 48, o tema sai de `ColorScheme.fromSeed` com contraste conferido, e existe teste com `tester.ensureSemantics()` + `meetsGuideline(androidTapTargetGuideline)` e outro com `TextScaler.linear(2.0)` sem overflow. Altura fixa (`height:`) onde deveria ser `minHeight` reprova o item da fonte a 200 %.
- **Testes (4 pt).** Atendido quando há as três camadas — unitário do domínio, de widget com `ProviderScope(overrides: ...)` e um de integração do fluxo completo —, os mocks são `mocktail` com `thenAnswer` nos métodos assíncronos, cada `ProviderContainer` tem `addTearDown(container.dispose)`, e `flutter analyze --fatal-infos` mais `dart format --output=none --set-exit-if-changed .` saem limpos. Qualquer `skip` no meio da suíte zera o critério.
- **Feature-first (3 pt).** Atendido quando nenhum arquivo de `presentation/` importa algo de `data/`: a tela conhece o contrato em `domain/` e recebe a implementação por provider. Um único `import '../data/...'` numa tela derruba o critério, mesmo que tudo funcione.
- **Release Android assinado (3 pt).** Atendido quando `git status` não lista `key.properties`, `*.jks`, `*.keystore` nem `.env`, existem AAB e APK `arm64-v8a`, e o `apksigner verify --print-certs` colado no relatório mostra o certificado do aluno — se aparecer `CN=Android Debug`, o critério é zero. Chave commitada invalida a prática: só rotacionar resolve.
- **Ofuscação (2 pt).** Atendido quando os dois builds usam `--obfuscate --split-debug-info=simbolos/1.0.0`, a pasta `simbolos/1.0.0` está arquivada **fora** de `build/` (que o `flutter clean` apaga) e fora do Git, e o `docs/release-1.0.0.md` registra qual versão corresponde a quais símbolos. Ofuscar sem guardar os símbolos vale zero — é pior que não ofuscar.

### Solução prática de referência

```dart
// lib/features/sessoes/domain/sessao.dart — Dart puro, nenhum import.
class Sessao {
  const Sessao({
    required this.id,
    required this.materiaId,
    required this.minutos,
  });

  final String id;
  final String materiaId;
  final int minutos;
}

// lib/features/metas/domain/meta_semanal.dart
// Só importa o próprio domínio: nada de flutter, http ou sqflite aqui.
import '../../sessoes/domain/sessao.dart';

class MetaSemanal {
  MetaSemanal({required this.minutosAlvo, required this.minutosFeitos}) {
    // A exceção mora no construtor: objeto inválido não chega a existir.
    if (minutosAlvo <= 0) {
      throw ArgumentError.value(
        minutosAlvo,
        'minutosAlvo',
        'A meta semanal precisa ser maior que zero',
      );
    }
    if (minutosFeitos < 0) {
      throw ArgumentError.value(
        minutosFeitos,
        'minutosFeitos',
        'Minutos estudados não podem ser negativos',
      );
    }
  }

  /// Lista vazia soma zero — sem `first`, sem `reduce`, sem `Bad state`.
  factory MetaSemanal.daSemana(
    List<Sessao> sessoes, {
    required int minutosAlvo,
  }) =>
      MetaSemanal(
        minutosAlvo: minutosAlvo,
        minutosFeitos:
            sessoes.fold<int>(0, (int total, Sessao s) => total + s.minutos),
      );

  final int minutosAlvo;
  final int minutosFeitos;

  /// Fronteira exata: 300 de 300 já está batida.
  bool get atingida => minutosFeitos >= minutosAlvo;
}
```

```dart
// test/features/metas/meta_semanal_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco/features/metas/domain/meta_semanal.dart';
import 'package:foco/features/sessoes/domain/sessao.dart';

void main() {
  test('semana sem sessões soma zero e não atinge a meta', () {
    final MetaSemanal meta =
        MetaSemanal.daSemana(const <Sessao>[], minutosAlvo: 300);

    expect(meta.minutosFeitos, 0);
    expect(meta.atingida, isFalse);
  });

  test('fronteira exata: 299 não bate, 300 bate', () {
    expect(MetaSemanal(minutosAlvo: 300, minutosFeitos: 299).atingida, isFalse);
    expect(MetaSemanal(minutosAlvo: 300, minutosFeitos: 300).atingida, isTrue);
  });

  test('meta zerada é erro de construção', () {
    expect(
      () => MetaSemanal(minutosAlvo: 0, minutosFeitos: 10),
      throwsArgumentError,
    );
  });
}
```

```dart
// lib/features/trilhas/domain/falha.dart
// `sealed` fecha a hierarquia: switch sem `default` vira exaustivo.
sealed class Falha implements Exception {
  const Falha();

  String get mensagem;
}

final class FalhaSemConexao extends Falha {
  const FalhaSemConexao();

  @override
  String get mensagem => 'Sem internet. Mostrando as trilhas salvas.';
}

final class FalhaTempoEsgotado extends Falha {
  const FalhaTempoEsgotado();

  @override
  String get mensagem => 'A resposta demorou demais. Tente de novo.';
}

final class FalhaServidor extends Falha {
  const FalhaServidor(this.status);

  final int status;

  @override
  String get mensagem => 'O servidor respondeu $status. Tente mais tarde.';
}

final class FalhaFormato extends Falha {
  const FalhaFormato();

  @override
  String get mensagem => 'A resposta veio em formato inesperado.';
}
```

```dart
// lib/features/trilhas/data/trilha_repositorio_http.dart
// Traduzir exceção técnica em Falha é responsabilidade DAQUI.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/falha.dart';
import '../domain/trilha.dart';
import '../domain/trilha_repositorio.dart';
import 'trilha_dto.dart';

class TrilhaRepositorioHttp implements TrilhaRepositorio {
  TrilhaRepositorioHttp({required http.Client cliente, required Uri base})
      : _cliente = cliente,
        _base = base;

  final http.Client _cliente;
  final Uri _base;

  @override
  Future<List<Trilha>> listar() async {
    try {
      // Sem o timeout, a rede ruim deixa a tela em "carregando" para sempre.
      final http.Response resposta = await _cliente
          .get(_base.resolve('trilhas'))
          .timeout(const Duration(seconds: 10));

      if (resposta.statusCode != 200) {
        throw FalhaServidor(resposta.statusCode);
      }

      final List<Object?> bruto =
          jsonDecode(resposta.body) as List<Object?>;
      return bruto
          .map((Object? j) =>
              TrilhaDto.doJson(j! as Map<String, Object?>).paraDominio())
          .toList();
    } on SocketException {
      throw const FalhaSemConexao();
    } on TimeoutException {
      throw const FalhaTempoEsgotado();
    } on FormatException {
      throw const FalhaFormato();
    }
  }
}
```

```dart
// lib/features/trilhas/presentation/trilhas_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/trilha.dart';
import 'providers.dart'; // trilhaRepositorioProvider: Provider<TrilhaRepositorio>

final AsyncNotifierProvider<TrilhasController, List<Trilha>> trilhasProvider =
    AsyncNotifierProvider<TrilhasController, List<Trilha>>(
  TrilhasController.new,
);

class TrilhasController extends AsyncNotifier<List<Trilha>> {
  @override
  Future<List<Trilha>> build() =>
      ref.read(trilhaRepositorioProvider).listar();

  /// Pull-to-refresh: recarrega SEM apagar o que já está na tela.
  Future<void> recarregar() async {
    state = const AsyncLoading<List<Trilha>>().copyWithPrevious(state);

    final AsyncValue<List<Trilha>> novo = await AsyncValue.guard(
      () => ref.read(trilhaRepositorioProvider).listar(),
    );

    // Riverpod 3: escrever em `state` de um notifier descartado LANÇA.
    if (!ref.mounted) return;
    state = novo;
  }
}
```

```dart
// lib/features/trilhas/presentation/trilhas_tab.dart — os quatro estados.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/falha.dart';
import '../domain/trilha.dart';
import 'trilhas_controller.dart';

class TrilhasTab extends ConsumerWidget {
  const TrilhasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trilha>> trilhas = ref.watch(trilhasProvider);

    return trilhas.when(
      skipLoadingOnRefresh: true,
      loading: () =>
          const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object erro, StackTrace pilha) => EstadoErro(
        // A tela fala a língua do domínio: nunca "SocketException".
        mensagem: erro is Falha
            ? erro.mensagem
            : 'Não foi possível carregar as trilhas.',
        onTentarDeNovo: () => ref.invalidate(trilhasProvider),
      ),
      data: (List<Trilha> lista) => lista.isEmpty
          ? const EstadoVazio(
              titulo: 'Nenhuma trilha ainda',
              descricao: 'As trilhas aparecem aqui assim que você entrar em uma.',
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(trilhasProvider.notifier).recarregar(),
              child: ListView.builder(
                itemCount: lista.length,
                itemBuilder: (BuildContext context, int i) => TrilhaTile(
                  key: ValueKey<String>(lista[i].id), // key vem do DADO
                  trilha: lista[i],
                ),
              ),
            ),
    );
  }
}
```

```dart
// lib/core/banco/banco_foco.dart — v1 → v2 sem perder dado de ninguém.
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

abstract final class BancoFoco {
  /// 1 → inicial · 2 → materia.cor
  static const int versaoAtual = 2;

  static Future<Database> abrir({String nome = 'foco.db'}) async =>
      openDatabase(
        p.join(await getDatabasesPath(), nome),
        version: versaoAtual,
        onConfigure: (Database db) =>
            db.execute('PRAGMA foreign_keys = ON'),
        onCreate: criar,
        onUpgrade: atualizar,
      );

  static Future<void> criar(Database db, int versao) async {
    await db.execute(
      'CREATE TABLE materia ('
      ' id TEXT PRIMARY KEY,'
      ' nome TEXT NOT NULL,'
      ' cor INTEGER NOT NULL DEFAULT 0)', // quem instala agora já nasce na v2
    );
    await db.execute(
      'CREATE TABLE sessao ('
      ' id TEXT PRIMARY KEY,'
      ' materia_id TEXT NOT NULL,'
      ' minutos INTEGER NOT NULL,'
      ' iniciada_em INTEGER NOT NULL,'
      ' FOREIGN KEY (materia_id) REFERENCES materia (id) ON DELETE CASCADE)',
    );
  }

  /// Em etapas, sem `else`: quem está na v1 executa o bloco da v2.
  static Future<void> atualizar(Database db, int de, int para) async {
    if (de < 2) {
      // NOT NULL exige DEFAULT: as linhas já existentes precisam de valor.
      await db.execute(
        'ALTER TABLE materia ADD COLUMN cor INTEGER NOT NULL DEFAULT 0',
      );
    }
  }
}
```

```dart
// lib/core/rotas.dart — argumento validado e resultado tipado.
import 'package:flutter/material.dart';

import '../features/materias/domain/materia.dart';
import '../features/materias/presentation/materia_form_screen.dart';
import '../features/materias/presentation/materias_screen.dart';

abstract final class Rotas {
  static const String home = '/';
  static const String materiaForm = '/materia/form';

  static Route<dynamic> gerar(RouteSettings configuracoes) {
    switch (configuracoes.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: configuracoes,
          builder: (_) => const MateriasScreen(),
        );

      case materiaForm:
        final Object? args = configuracoes.arguments;
        // Valida ANTES de usar: `as` aqui é crash em produção.
        if (args != null && args is! Materia) return desconhecida(configuracoes);
        // O <Materia> precisa casar com o pushNamed<Materia> de quem chama.
        return MaterialPageRoute<Materia>(
          settings: configuracoes,
          builder: (_) => MateriaFormScreen(original: args as Materia?),
        );

      default:
        return desconhecida(configuracoes);
    }
  }

  static Route<dynamic> desconhecida(RouteSettings configuracoes) =>
      MaterialPageRoute<void>(
        settings: configuracoes,
        builder: (_) => const Scaffold(
          body: Center(child: Text('Tela não encontrada')),
        ),
      );
}
```

```dart
// Chamada com argumento e resultado, e a saída protegida do formulário.
final Materia? salva = await Navigator.of(context).pushNamed<Materia>(
  Rotas.materiaForm,
  arguments: materia, // null = nova matéria
);
if (!context.mounted || salva == null) return;
await ref.read(materiasProvider.notifier).salvar(salva);

// dentro do MateriaFormScreen:
return PopScope<Materia>(
  canPop: !_sujo && !_enviando,
  onPopInvokedWithResult: (bool saiu, Materia? resultado) async {
    if (saiu) return;
    final bool descartar = await _confirmarDescarte();
    if (descartar && context.mounted) Navigator.of(context).pop();
  },
  child: /* Form com validator por campo */ const SizedBox.shrink(),
);
```

```dart
// test/features/trilhas/trilhas_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foco/features/trilhas/domain/falha.dart';
import 'package:foco/features/trilhas/domain/trilha.dart';
import 'package:foco/features/trilhas/domain/trilha_repositorio.dart';
import 'package:foco/features/trilhas/presentation/providers.dart';
import 'package:foco/features/trilhas/presentation/trilhas_controller.dart';
import 'package:mocktail/mocktail.dart';

class _TrilhaRepositorioMock extends Mock implements TrilhaRepositorio {}

void main() {
  test('timeout do repositório chega à tela como FalhaTempoEsgotado', () async {
    final _TrilhaRepositorioMock repo = _TrilhaRepositorioMock();
    // Método assíncrono: thenAnswer, nunca thenReturn.
    when(() => repo.listar()).thenAnswer(
      (_) => Future<List<Trilha>>.error(const FalhaTempoEsgotado()),
    );

    final ProviderContainer container = ProviderContainer(
      // O provider é tipado pelo CONTRATO — por isso dá para trocar aqui.
      overrides: <Override>[
        trilhaRepositorioProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(trilhasProvider.future),
      throwsA(isA<FalhaTempoEsgotado>()),
    );
    expect(container.read(trilhasProvider).hasError, isTrue);
    verify(() => repo.listar()).called(1);
  });
}
```

```powershell
# Fechamento da entrega — cada linha vira uma evidência em docs/release-1.0.0.md
flutter analyze --fatal-infos
dart format --output=none --set-exit-if-changed .
flutter test

flutter clean
flutter build appbundle --release --obfuscate --split-debug-info=simbolos/1.0.0
flutter build apk --release --target-platform android-arm64 `
  --obfuscate --split-debug-info=simbolos/1.0.0

apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
git status --short          # sem key.properties, *.jks, *.keystore, .env

# As duas checagens de arquitetura que o avaliador roda antes de ler o código:
Get-ChildItem -Recurse lib/features/*/domain -Filter *.dart |
  Select-String -Pattern 'package:(flutter|http|sqflite)'   # precisa ser vazio
Get-ChildItem -Recurse lib/features/*/presentation -Filter *.dart |
  Select-String -Pattern "import '.*/data/"                 # precisa ser vazio
```

Use os pesos da tabela da [avaliação](../avaliacoes/avaliacao-final.md) e os quatro critérios de
aprovação: sem `analyze --fatal-infos` limpo, `flutter test` verde sem `skip`, AAB assinado com
chave própria e `git status` sem segredo, a nota não importa — não há aprovação.
