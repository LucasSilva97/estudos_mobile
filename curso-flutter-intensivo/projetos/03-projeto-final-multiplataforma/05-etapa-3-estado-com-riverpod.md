# Etapa 3 — Estado com Riverpod — Projeto Final: Foco: Organizador de Estudos

> **Tempo estimado:** 2 h 30 · **Depende de:** [Etapa 2 — Domínio e dados](04-etapa-2-dominio-e-dados.md) · **Aulas:** [6 — Notifier](../../modulos/08-estado-e-arquitetura/06-notifier-e-notifierprovider.md) · [7 — AsyncNotifier e AsyncValue](../../modulos/08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) · [8 — Family e autoDispose](../../modulos/08-estado-e-arquitetura/08-family-autodispose-listen.md) · [9 — Feature-first](../../modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md) · [10 — Injeção de dependências](../../modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md)

---

## 🎯 O que existe ao fim desta etapa

O **cérebro** do Foco: seis providers que já respondem tudo que as telas vão perguntar na etapa 4.

| Provider | Responde a |
|---|---|
| `materiasProvider` | quais matérias existem + criar, arquivar, excluir |
| `sessoesDaMateriaProvider` | as sessões **de uma** matéria + registrar e remover |
| `cronometroProvider` | quanto tempo já se passou, por diferença de `DateTime` |
| `resumoSemanalProvider` | os 7 dias, o total, a média, a semana anterior |
| `metaSemanalProvider` | bati a meta? + ajustar o alvo |
| `modoDeTemaProvider` | claro / escuro / sistema, lido e gravado nas preferências |

E a garantia que vale mais que as seis linhas: **nenhum controller importa `sqflite`, `http` ou
`shared_preferences`**. Todos falam com o *contrato*, lido por provider — é isso que faz o teste da
etapa 7 rodar sem emulador.

---

## 📦 Dependências

**Nada entra no `pubspec.yaml` aqui.** O `flutter_riverpod: ^3.4.3` veio na etapa 1 e é tudo que
estes sete arquivos usam.

> 📌 **Zero `build_runner`, zero `.g.dart`** (ADR-01): você escreve
> `AsyncNotifierProvider<MateriasController, List<Materia>>(MateriasController.new)` à mão. São ~20
> providers no Foco — o gerador só compensa perto dos 40, e cobra um passo de build em toda edição.

Confira as assinaturas da etapa 2 **antes** de escrever; assim o erro aparece agora:

```dart
relogioProvider  // agora() -> DateTime          uuidProvider  // v4() -> String
materiaRepositorioProvider  // listar · porId · salvar · buscar(String termo) · excluir
                            // arquivar(String id, {required bool arquivada})
sessaoRepositorioProvider   // daMateria(String) · noPeriodo(DateTime, DateTime)
                            // registrar · remover(String) · minutosNoPeriodo -> Future<int>
metaRepositorioProvider     // dono do prefs: ler/salvarMinutosAlvo, ler/salvarModoDeTema
```

---

## 🧩 Os arquivos desta etapa

| Arquivo | Papel |
|---|---|
| `sessoes/domain/cronometro_estado.dart` | Estado imutável do cronômetro + a conta de tempo |
| `materias/presentation/materias_controller.dart` | Lista, nome único, arquivar, excluir |
| `sessoes/presentation/sessoes_controller.dart` | Sessões de uma matéria (`family`) |
| `sessoes/presentation/cronometro_controller.dart` | `Notifier` + `Timer`, com `onDispose` |
| `estatisticas/presentation/estatisticas_controller.dart` | Agrega a semana em SQL |
| `metas/presentation/meta_controller.dart` | Deriva a meta do resumo e grava o alvo |
| `configuracoes/presentation/tema_controller.dart` | Modo de tema, lido e persistido |

Todos sob `lib/features/`.

---

### lib/features/sessoes/domain/cronometro_estado.dart

> **Por que ele existe:** o cronômetro não guarda "segundos que passaram", guarda **desde quando**
> está contando — é isso que faz o tempo sobreviver ao segundo plano (RF10).

```dart
import 'package:meta/meta.dart';

@immutable
class CronometroEstado {
  const CronometroEstado({
    this.materiaId = '',
    this.inicioEm,
    this.acumulado = Duration.zero,
    this.rodando = false,
  });

  final String materiaId;
  final DateTime? inicioEm; // instante do último iniciar/retomar
  final Duration acumulado; // tempo contado antes da pausa atual
  final bool rodando;

  /// Diferença de `DateTime`, nunca soma de ticks: 10 min em segundo plano
  /// continuam sendo 10 min na volta.
  Duration decorridoAte(DateTime agora) {
    final DateTime? desde = inicioEm;
    if (!rodando || desde == null) return acumulado;
    final Duration corrido = agora.difference(desde);
    // Relógio do sistema movido para trás não vira tempo negativo.
    return corrido.isNegative ? acumulado : acumulado + corrido;
  }

  /// Minutos para preencher o formulário de sessão. Mínimo 1 (RF11).
  int minutosArredondados(DateTime agora) {
    final int minutos = (decorridoAte(agora).inSeconds + 30) ~/ 60;
    return minutos < 1 ? 1 : minutos;
  }

  /// ⚠️ `inicioEm` é anulável: `inicioEm ?? this.inicioEm` jamais o apagaria.
  CronometroEstado copyWith({
    String? materiaId,
    DateTime? inicioEm,
    bool limparInicio = false,
    Duration? acumulado,
    bool? rodando,
  }) {
    return CronometroEstado(
      materiaId: materiaId ?? this.materiaId,
      inicioEm: limparInicio ? null : (inicioEm ?? this.inicioEm),
      acumulado: acumulado ?? this.acumulado,
      rodando: rodando ?? this.rodando,
    );
  }

  @override
  bool operator ==(Object outro) =>
      identical(this, outro) ||
      outro is CronometroEstado &&
          outro.materiaId == materiaId &&
          outro.inicioEm == inicioEm &&
          outro.acumulado == acumulado &&
          outro.rodando == rodando;

  @override
  int get hashCode => Object.hash(materiaId, inicioEm, acumulado, rodando);
}
```

---

### lib/features/materias/presentation/materias_controller.dart

> **Por que ele existe:** três telas leem a lista de matérias, e a regra do nome único precisa valer
> nas três — por isso ela mora aqui, e não no formulário.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foco/core/banco/texto.dart';
import 'package:foco/features/estatisticas/presentation/estatisticas_controller.dart';
import 'package:foco/features/materias/data/materia_repositorio.dart'
    show materiaRepositorioProvider; // só o provider: a classe concreta não entra
import 'package:foco/features/materias/domain/materia.dart';
import 'package:foco/features/materias/domain/materia_repositorio_contrato.dart';

final AsyncNotifierProvider<MateriasController, List<Materia>> materiasProvider =
    AsyncNotifierProvider<MateriasController, List<Materia>>(
        MateriasController.new);

class MateriasController extends AsyncNotifier<List<Materia>> {
  /// O tipo é o CONTRATO: este controller não sabe que existe um `sqflite`.
  MateriaRepositorioContrato get _repo => ref.read(materiaRepositorioProvider);

  /// `watch`, não `read`: sobrescreveu o repositório no teste, o controller
  /// renasce com o repositório novo.
  @override
  Future<List<Materia>> build() =>
      ref.watch(materiaRepositorioProvider).listar();

  Future<void> recarregar() async {
    state = const AsyncLoading<List<Materia>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _repo.listar());
  }

  /// Devolve `null` em caso de sucesso, ou a mensagem para o formulário.
  Future<String?> salvar(Materia materia) async {
    final String nome = materia.nome.trim();
    if (nome.length < 2 || nome.length > 60) {
      return 'O nome precisa ter de 2 a 60 caracteres.';
    }
    if (await _nomeRepetido(materia.id, nome)) {
      return 'Já existe uma matéria com esse nome.';
    }
    return _escrever(() => _repo.salvar(materia.copyWith(nome: nome)),
        'Não foi possível salvar a matéria.');
  }

  Future<String?> arquivar(String id, {required bool arquivada}) => _escrever(
      () => _repo.arquivar(id, arquivada: arquivada),
      'Não foi possível arquivar a matéria.');

  Future<String?> excluir(String id) async {
    final String? erro = await _escrever(
        () => _repo.excluir(id), 'Não foi possível excluir a matéria.');
    // O ON DELETE CASCADE levou as sessões junto: a semana mudou.
    if (erro == null) ref.invalidate(resumoSemanalProvider);
    return erro;
  }

  /// Compara pelo nome NORMALIZADO (RF06): "cálculo" e "Calculo" são o mesmo
  /// nome. `buscar` já consulta a coluna `nome_ordenacao`.
  Future<bool> _nomeRepetido(String id, String nome) async {
    final String chave = Texto.paraOrdenacao(nome);
    final List<Materia> parecidas = await _repo.buscar(nome);
    return parecidas
        .any((Materia m) => m.id != id && Texto.paraOrdenacao(m.nome) == chave);
  }

  /// ⚠️ O `copyWithPrevious` é o que impede a lista de sumir da tela quando a
  /// escrita falha: erro **com** os dados antigos ainda visíveis.
  Future<String?> _escrever(
      Future<void> Function() acao, String mensagemDeErro) async {
    final List<Materia> anteriores = state.value ?? const <Materia>[];
    state = const AsyncLoading<List<Materia>>().copyWithPrevious(state);
    final AsyncValue<List<Materia>> resultado =
        await AsyncValue.guard(() async {
      await acao();
      return _repo.listar();
    });
    state = resultado.copyWithPrevious(AsyncData<List<Materia>>(anteriores));
    return resultado.hasError ? mensagemDeErro : null;
  }
}
```

---

### lib/features/sessoes/presentation/sessoes_controller.dart

> **Por que ele existe:** cada matéria tem a própria lista de sessões, e o estado de uma não pode
> contaminar o da outra — é o caso de livro do `.family`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foco/core/providers/providers_raiz.dart';
import 'package:foco/features/estatisticas/presentation/estatisticas_controller.dart';
import 'package:foco/features/materias/presentation/materias_controller.dart';
import 'package:foco/features/sessoes/data/sessao_repositorio.dart'
    show sessaoRepositorioProvider;
import 'package:foco/features/sessoes/domain/sessao.dart';
import 'package:foco/features/sessoes/domain/sessao_repositorio_contrato.dart';

/// ⚠️ `family` **sempre** com `autoDispose`: sem ele, cada matéria visitada
/// deixa um estado vivo para sempre.
final AutoDisposeAsyncNotifierProviderFamily<SessoesController, List<Sessao>,
        String> sessoesDaMateriaProvider =
    AsyncNotifierProvider.autoDispose
        .family<SessoesController, List<Sessao>, String>(SessoesController.new);

class SessoesController
    extends AutoDisposeFamilyAsyncNotifier<List<Sessao>, String> {
  SessaoRepositorioContrato get _repo => ref.read(sessaoRepositorioProvider);

  /// O `build` de uma family RECEBE o argumento — que segue disponível como
  /// `arg` em todos os outros métodos da classe.
  @override
  Future<List<Sessao>> build(String materiaId) =>
      ref.watch(sessaoRepositorioProvider).daMateria(materiaId);

  Future<String?> registrar({
    required DateTime inicioEm,
    required int minutos,
    String anotacao = '',
  }) async {
    if (minutos < Sessao.minimoDeMinutos || minutos > Sessao.maximoDeMinutos) {
      return 'Os minutos precisam estar entre 1 e 480.';
    }
    if (inicioEm.isAfter(ref.read(relogioProvider).agora())) {
      return 'A data da sessão não pode estar no futuro.';
    }
    final String texto = anotacao.trim();
    if (texto.length > 280) {
      return 'A anotação pode ter no máximo 280 caracteres.';
    }
    final Sessao nova = Sessao(
      id: ref.read(uuidProvider).v4(),
      materiaId: arg,
      inicioEm: inicioEm,
      minutos: minutos,
      anotacao: texto,
    );
    return _escrever(
        () => _repo.registrar(nova), 'Não foi possível registrar a sessão.');
  }

  Future<String?> remover(String sessaoId) => _escrever(
      () => _repo.remover(sessaoId), 'Não foi possível remover a sessão.');

  Future<String?> _escrever(
      Future<void> Function() acao, String mensagemDeErro) async {
    final List<Sessao> anteriores = state.value ?? const <Sessao>[];
    state = const AsyncLoading<List<Sessao>>().copyWithPrevious(state);
    final AsyncValue<List<Sessao>> resultado = await AsyncValue.guard(() async {
      await acao();
      return _repo.daMateria(arg);
    });
    state = resultado.copyWithPrevious(AsyncData<List<Sessao>>(anteriores));
    if (resultado.hasError) return mensagemDeErro;

    // A mesma transação mexeu em `materias.minutos` (RF13): quem mostra total
    // e semana precisa reler. `metaSemanalProvider` não entra na lista — ele
    // observa o resumo e vem junto.
    ref.invalidate(materiasProvider);
    ref.invalidate(resumoSemanalProvider);
    return null;
  }
}
```

---

### lib/features/sessoes/presentation/cronometro_controller.dart

> **Por que ele existe:** o cronômetro precisa continuar contando depois que você sai da tela — por
> isso ele mora num provider, e por isso **não** leva `autoDispose`.

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foco/core/providers/providers_raiz.dart';
import 'package:foco/features/sessoes/domain/cronometro_estado.dart';

/// Um cronômetro por vez no app — a matéria vai DENTRO do estado.
/// Sem `autoDispose`: sair da tela não pode zerar o tempo (RNF19).
final NotifierProvider<CronometroController, CronometroEstado>
    cronometroProvider =
    NotifierProvider<CronometroController, CronometroEstado>(
        CronometroController.new);

class CronometroController extends Notifier<CronometroEstado> {
  Timer? _tique;

  @override
  CronometroEstado build() {
    // Registrado JUNTO da criação: é o que torna difícil esquecer.
    ref.onDispose(() => _tique?.cancel());
    return const CronometroEstado();
  }

  DateTime get _agora => ref.read(relogioProvider).agora();

  void iniciar(String materiaId) {
    _ligarTique();
    state =
        CronometroEstado(materiaId: materiaId, inicioEm: _agora, rodando: true);
  }

  void pausar() {
    if (!state.rodando) return;
    _desligarTique();
    state = state.copyWith(
      acumulado: state.decorridoAte(_agora),
      limparInicio: true,
      rodando: false,
    );
  }

  void retomar() {
    if (state.rodando || state.materiaId.isEmpty) return;
    _ligarTique();
    state = state.copyWith(inicioEm: _agora, rodando: true);
  }

  /// Congela a contagem e devolve os minutos para o `FormSessaoSheet` abrir
  /// preenchido (RF11). Zerar é trabalho do `descartar`.
  int parar() {
    final int minutos = state.minutosArredondados(_agora);
    pausar();
    return minutos;
  }

  void descartar() {
    _desligarTique();
    state = const CronometroEstado();
  }

  void _ligarTique() {
    _tique?.cancel();
    _tique = Timer.periodic(const Duration(seconds: 1), (_) {
      // ⚠️ `state = state.copyWith()` sem mudar campo NÃO notifica: o `==` por
      // valor diz "igual". Cada tique reancora o marco e empurra o decorrido
      // para `acumulado` — a conta segue sendo diferença de `DateTime`.
      final DateTime agora = _agora;
      state =
          state.copyWith(acumulado: state.decorridoAte(agora), inicioEm: agora);
    });
  }

  void _desligarTique() {
    _tique?.cancel();
    _tique = null;
  }
}
```

---

### lib/features/estatisticas/presentation/estatisticas_controller.dart

> **Por que ele existe:** a semana é a mesma pergunta feita por duas telas (Painel e Estatísticas) —
> calcular duas vezes seria errar duas vezes.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foco/core/providers/providers_raiz.dart';
import 'package:foco/features/estatisticas/domain/resumo_semanal.dart';
import 'package:foco/features/metas/data/meta_repositorio.dart'
    show metaRepositorioProvider;
import 'package:foco/features/sessoes/data/sessao_repositorio.dart'
    show sessaoRepositorioProvider;
import 'package:foco/features/sessoes/domain/sessao.dart';
import 'package:foco/features/sessoes/domain/sessao_repositorio_contrato.dart';

final AsyncNotifierProvider<EstatisticasController, ResumoSemanal>
    resumoSemanalProvider =
    AsyncNotifierProvider<EstatisticasController, ResumoSemanal>(
        EstatisticasController.new);

/// Segunda-feira, 00:00 local, da semana de [dia] — `weekday` vai de 1
/// (segunda) a 7. `DateTime(ano, mes, dia - n)` normaliza a virada de mês;
/// `subtract(Duration(days: n))` erraria em fuso com horário de verão.
DateTime inicioDaSemanaDe(DateTime dia) =>
    DateTime(dia.year, dia.month, dia.day - (dia.weekday - 1));

DateTime _dia(DateTime base, int deslocamento) =>
    DateTime(base.year, base.month, base.day + deslocamento);

class EstatisticasController extends AsyncNotifier<ResumoSemanal> {
  @override
  Future<ResumoSemanal> build() async {
    final SessaoRepositorioContrato repo = ref.watch(sessaoRepositorioProvider);
    final DateTime inicio = inicioDaSemanaDe(ref.watch(relogioProvider).agora());

    // Sete SUM no SQLite custam menos que trazer a semana toda para somar em
    // Dart (RNF09). `Future.wait` preserva a ordem: índice 0 = segunda.
    final List<int> porDia = await Future.wait<int>(<Future<int>>[
      for (int i = 0; i < 7; i++)
        repo.minutosNoPeriodo(_dia(inicio, i), _dia(inicio, i + 1)),
    ]);
    final int anterior = await repo.minutosNoPeriodo(_dia(inicio, -7), inicio);

    // Único ponto em que a semana vem como lista: a distribuição precisa das
    // linhas, não de um total. Matéria arquivada continua contando (regra 9).
    final List<Sessao> daSemana = await repo.noPeriodo(inicio, _dia(inicio, 7));
    final Map<String, int> porMateria = <String, int>{};
    for (final Sessao s in daSemana) {
      porMateria[s.materiaId] = (porMateria[s.materiaId] ?? 0) + s.minutos;
    }

    return ResumoSemanal(
      inicioDaSemana: inicio,
      minutosPorDia: porDia,
      minutosPorMateria: porMateria,
      metaMinutos: ref.watch(metaRepositorioProvider).lerMinutosAlvo(),
      minutosSemanaAnterior: anterior,
    );
  }
}
```

---

### lib/features/metas/presentation/meta_controller.dart

> **Por que ele existe:** a meta é o resumo visto de outro ângulo — alvo contra feito. Derivar em
> vez de recalcular é o que impede o anel do Painel de discordar das barras das Estatísticas.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foco/features/estatisticas/domain/resumo_semanal.dart';
import 'package:foco/features/estatisticas/presentation/estatisticas_controller.dart';
import 'package:foco/features/metas/data/meta_repositorio.dart'
    show metaRepositorioProvider;
import 'package:foco/features/metas/domain/meta_semanal.dart';

final AsyncNotifierProvider<MetaController, MetaSemanal> metaSemanalProvider =
    AsyncNotifierProvider<MetaController, MetaSemanal>(MetaController.new);

class MetaController extends AsyncNotifier<MetaSemanal> {
  /// `.future` espera o outro provider assíncrono terminar. Como é `watch`,
  /// invalidar o resumo recalcula a meta sozinho.
  @override
  Future<MetaSemanal> build() async {
    final ResumoSemanal resumo = await ref.watch(resumoSemanalProvider.future);
    return MetaSemanal(
        minutosAlvo: resumo.metaMinutos, minutosFeitos: resumo.totalMinutos);
  }

  /// De 30 a 3000, em passos de 30 (RF15). O `Slider` da etapa 4 respeita, mas
  /// a regra é daqui — quem chama por código não escapa dela.
  Future<void> definirAlvo(int minutos) async {
    final int passo = (minutos / 30).round() * 30;
    final int ajustado = passo < 30 ? 30 : (passo > 3000 ? 3000 : passo);
    await ref.read(metaRepositorioProvider).salvarMinutosAlvo(ajustado);
    // O alvo mora dentro do ResumoSemanal: invalidar o resumo atualiza os dois.
    ref.invalidate(resumoSemanalProvider);
  }
}
```

---

### lib/features/configuracoes/presentation/tema_controller.dart

> **Por que ele existe:** trocar o tema não pode reiniciar o app (RF20) — e o `MaterialApp` só
> reage se o modo vier de um provider.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foco/core/tema/modo_de_tema.dart';
import 'package:foco/features/metas/data/meta_repositorio.dart'
    show metaRepositorioProvider;

final NotifierProvider<TemaController, ModoDeTema> modoDeTemaProvider =
    NotifierProvider<TemaController, ModoDeTema>(TemaController.new);

class TemaController extends Notifier<ModoDeTema> {
  /// Síncrono porque as preferências abriram em `main()` (RNF14).
  @override
  ModoDeTema build() => ref.watch(metaRepositorioProvider).lerModoDeTema();

  Future<void> definir(ModoDeTema modo) async {
    if (modo == state) return;
    state = modo; // a interface troca AGORA; o disco vem depois
    await ref.read(metaRepositorioProvider).salvarModoDeTema(modo);
  }
}
```

---

## ▶️ Rodando

```bash
flutter analyze   # precisa terminar com: No issues found!
flutter run
```

A tela é a mesma da etapa 1 — **controller sem tela não desenha nada**, e o app continua abrindo
normalmente. Esta etapa se prova no `analyze` e no `ProviderContainer` da etapa 7, não em pixel
novo: num `ConsumerWidget` temporário, `ref.watch(metaSemanalProvider)` já devolve os minutos da
semana lidos do banco.

---

## ✅ Conferência

- [ ] `flutter analyze` termina com **No issues found!**
- [ ] Os sete arquivos estão **exatamente** nos caminhos da tabela — a etapa 4 importa por eles.
- [ ] `grep -r "sqflite\|shared_preferences\|package:http" lib/features/*/presentation` não devolve
      nada.
- [ ] `sessoesDaMateriaProvider` é `.autoDispose.family` com `AutoDisposeFamilyAsyncNotifier`;
      `cronometroProvider` **não** tem `autoDispose`.
- [ ] Toda escrita devolve `String?`: `null` é sucesso, texto é a mensagem em pt-BR para a tela.
- [ ] Nenhum `try/catch` manual virando `AsyncError`, nenhum `.requireValue`, e todo `AsyncLoading`
      de recarga com `.copyWithPrevious(state)`.

> 📌 O `modoDeTemaProvider` ainda **não** está ligado ao `MaterialApp`: a ponte para `themeMode` é
> trabalho da etapa 4, junto com a `ConfiguracoesScreen`.

---

## ⚠️ Se der errado

| Sintoma | Causa | Correção |
|---|---|---|
| `The argument type 'SessoesController Function()' can't be assigned…` | Classe errada para family | A superclasse vira `AutoDisposeFamilyAsyncNotifier` e o `build()` recebe o argumento |
| `Undefined name 'arg'` | `arg` num notifier sem family | Sem family, receba o id por parâmetro |
| O cronômetro anda 1 s e congela | `copyWith()` não mudou campo nenhum: o `==` por valor diz "igual" | Reancore `inicioEm` e mova o decorrido para `acumulado` a cada tique |
| A lista pisca em branco ao salvar | `AsyncLoading()` puro | `const AsyncLoading<T>().copyWithPrevious(state)` |
| `Bad state: Tried to call requireValue…` | `.requireValue` no carregamento ou após erro | `state.value ?? const []` no controller, `.when` na tela |
| O total da matéria não muda após a sessão | Faltou invalidar quem lê o total | `ref.invalidate(materiasProvider)` e `ref.invalidate(resumoSemanalProvider)` |
| `Providers are not allowed to modify other providers during init` | `ref.invalidate` dentro de um `build()` | Invalide só dentro dos métodos |
| `UnimplementedError: Sobrescreva no main()` num teste | O `ProviderContainer` não recebeu os overrides | Sobrescreva o provider do **contrato** |
| O tema volta ao padrão ao reabrir o app | `definir` esqueceu o `salvarModoDeTema` | Grave logo depois de mudar o estado |
| A semana começa no domingo | `weekday` tratado como 0-indexado | `DateTime.weekday` vai de 1 (segunda) a 7 |

---

| ⬅️ Etapa anterior | 🏠 Projeto | ➡️ Próxima etapa |
|---|---|---|
| [04 — Etapa 2: Domínio e dados](04-etapa-2-dominio-e-dados.md) | [README do projeto](README.md) | [06 — Etapa 4: Telas e navegação](06-etapa-4-telas-e-navegacao.md) |
