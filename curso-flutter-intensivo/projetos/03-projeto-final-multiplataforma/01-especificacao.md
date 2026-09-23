# Especificação — Projeto Final: Foco: Organizador de Estudos

> **Leia antes de escrever a primeira linha.** Este arquivo é o contrato do projeto. As oito
> etapas seguintes implementam **exatamente** o que está aqui: os mesmos nomes de classe, os
> mesmos campos, as mesmas tabelas, as mesmas rotas. Se uma etapa discordar deste arquivo,
> este arquivo vence.

---

## 🎯 O que o app faz

O **Foco** responde a uma pergunta que você faz a si mesmo todo dia: *estudei o quanto eu
precisava esta semana?* Você cadastra **matérias**, registra **sessões de estudo** (com
cronômetro ou digitando os minutos), define uma **meta semanal** e vê em gráfico se está
cumprindo. Para os dias em que não sabe o que estudar, o app busca **trilhas sugeridas** numa
API pública.

**Para quem:** você, aluno deste curso, hoje. O domínio é vivido — não é requisito inventado.

**Por que ele existe no curso:** cada funcionalidade *puxa* uma decisão técnica das ADRs
([05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md), ADR-12). Matérias e sessões exigem
dado estruturado e consultável, o que **justifica** `sqflite` em vez de forçá-lo; a meta é um
inteiro solto, o que justifica `shared_preferences`; as trilhas vêm da rede, o que justifica
`http` + `AsyncValue`; cinco telas com estado compartilhado justificam Riverpod.

### Identidade fixa do app

| Item | Valor |
|---|---|
| Nome exibido | Foco |
| Projeto Flutter | `foco` |
| 🤖 `applicationId` | `br.com.estudos.foco` |
| 🍎 Bundle Identifier | `br.com.estudos.foco` |
| Banco local | `foco.db`, esquema **versão 3** |
| Plataformas | Android 🤖 e iOS 🍎, Material 3 nas duas |

> 🍎 **Sobre o iOS.** Todo o código do Foco é multiplataforma e os pacotes escolhidos suportam
> iOS. Mas **gerar o `.ipa` exige macOS** — Xcode não roda no Windows. Você prepara o projeto
> iOS inteiro aqui e executa o build num Mac ou num runner macOS de CI.

---

## 📋 Requisitos funcionais

Cada RF é verificável: dá para abrir o app e dizer "cumpre" ou "não cumpre".

| # | Requisito |
|---|---|
| **RF01** | A tela `InicioScreen` (rota `/`) tem um `NavigationBar` de três abas — **Painel**, **Matérias**, **Trilhas**. A aba escolhida sobrevive a ir e voltar de outra rota. |
| **RF02** | O **Painel** mostra minutos estudados hoje, minutos da semana, o anel de progresso da meta e as **3 sessões mais recentes**. Sem nenhuma sessão, mostra estado vazio com ação "Registrar sessão". |
| **RF03** | A aba **Matérias** lista as matérias **não arquivadas** ordenadas por `nome_ordenacao ASC` — `Álgebra` vem antes de `Biologia`, e não depois. Cada item mostra nome, cor e total de minutos. |
| **RF04** | Criar matéria em `MateriaFormScreen`: nome de **2 a 60 caracteres** e cor escolhida entre **8 opções fixas**. Salva no `sqflite` com `id` gerado por `uuid` v4. |
| **RF05** | A mesma `MateriaFormScreen` edita uma matéria existente (recebida como argumento de rota) e devolve `true` por `Navigator.pop` quando salva. |
| **RF06** | Nome duplicado é rejeitado. A comparação usa o nome **normalizado** (`Texto.paraOrdenacao`): "cálculo" e "Calculo" são o mesmo nome. |
| **RF07** | Arquivar e desarquivar matéria. Arquivada some da lista e do seletor de sessão, **mas continua contando** nas estatísticas históricas. |
| **RF08** | Excluir matéria pede confirmação em `AlertDialog` e apaga as sessões dela por `ON DELETE CASCADE`. |
| **RF09** | `MateriaDetalheScreen` mostra o total de minutos da matéria, o cronômetro e as **50 sessões mais recentes** dela, da mais nova para a mais antiga. |
| **RF10** | O cronômetro tem iniciar, pausar, retomar e descartar. Ele calcula o tempo por **diferença de `DateTime`**, nunca somando ticks — voltar do segundo plano não pode perder nem inventar tempo. |
| **RF11** | Ao parar o cronômetro, abre o `FormSessaoSheet` com os minutos já preenchidos (arredondados, mínimo 1) e um campo de anotação de até **280 caracteres**. |
| **RF12** | Registro manual de sessão: data **não futura**, minutos de **1 a 480**, anotação opcional. Fora disso o formulário não envia e mostra o erro no próprio campo. |
| **RF13** | Registrar sessão grava numa **única transação**: `INSERT` em `sessoes` **e** `UPDATE materias SET minutos = minutos + ?`. Nunca uma sem a outra. |
| **RF14** | Remover sessão desconta os minutos da matéria na **mesma transação**, com confirmação e `SnackBar` de desfazer. |
| **RF15** | A meta semanal fica em `shared_preferences` (chave `meta_semanal_minutos`, padrão **300**), ajustável de **30 a 3000** minutos em passos de 30. |
| **RF16** | `EstatisticasScreen` mostra barras dos **7 dias da semana corrente** (segunda a domingo), total, média diária, matéria mais estudada e a variação em relação à semana anterior. |
| **RF17** | A aba **Trilhas** busca `GET /posts?_limit=20` e cobre os **quatro estados de tela** — carregando, vazio, erro e dados — com puxar-para-atualizar (`RefreshIndicator` + `ref.invalidate`). |
| **RF18** | Toda resposta bem-sucedida de trilhas é gravada na tabela `cache_trilhas` com carimbo de tempo. O TTL é de **6 horas**: dentro dele, o app não vai à rede. |
| **RF19** | Sem internet ou com erro de rede, as trilhas vêm do cache com o aviso **"Atualizado há X · sem conexão"** e um botão "Tentar de novo". Sem cache **e** sem rede, estado de erro com ação. |
| **RF20** | `ConfiguracoesScreen` ajusta a meta semanal, escolhe o tema (claro / escuro / sistema, persistido e aplicado **sem reiniciar** o app), limpa o cache de trilhas e mostra a versão instalada. |

---

## 🔒 Requisitos não funcionais

| # | Requisito | Como verificar |
|---|---|---|
| **RNF01** | Contraste mínimo **4.5:1** entre texto e fundo, nos temas claro e escuro. As 8 cores de matéria são fundo de `CircleAvatar`, nunca cor de texto sobre fundo claro. | DevTools → Accessibility |
| **RNF02** | Todo alvo tocável tem no mínimo **48 × 48 dp**, inclusive os `IconButton` dentro de listas. | `meetsGuideline(androidTapTargetGuideline)` |
| **RNF03** | Em **200%** de tamanho de fonte do sistema nenhuma tela corta texto nem estoura layout. Nada de `height` fixo em cartão com texto. | `MediaQuery(textScaler: TextScaler.linear(2.0))` |
| **RNF04** | Todo botão só-ícone tem `Semantics` com rótulo em português. O anel de meta anuncia "meta semanal, 180 de 300 minutos, 60 por cento". | `meetsGuideline(labeledTapTargetGuideline)` |
| **RNF05** | A ordem de foco segue a ordem visual; os `TextFormField` avançam com `textInputAction` e `FocusNode`. | TalkBack 🤖 / VoiceOver 🍎 |
| **RNF06** | Listas usam `ListView.builder` (nunca `ListView(children: [...])` para dado de banco), `const` em todo widget sem estado e `ValueKey` estável por `id`. | Leitura de código + DevTools |
| **RNF07** | Com **500 matérias** e **5.000 sessões** a rolagem se mantém fluida. Toda consulta de lista usa índice e `LIMIT`; nenhuma tela carrega a tabela inteira. | Script de carga da etapa 7 |
| **RNF08** | Imagens passam por `cacheWidth`/`cacheHeight`; nada é decodificado no tamanho original. | Etapa 6 |
| **RNF09** | Nenhum cálculo pesado dentro de `build`. O resumo semanal é agregado em **SQL** (`SUM`, `GROUP BY`), não em Dart varrendo listas. | Leitura de código |
| **RNF10** | Nenhum segredo em `shared_preferences`, em log ou no Git. Se houver token, ele vai para `flutter_secure_storage` (🤖 Keystore / 🍎 Keychain). `key.properties`, `*.jks` e `.env` no `.gitignore`. | `git log -p` e revisão do `.gitignore` |
| **RNF11** | **Todo** SQL usa `?` com `whereArgs`. Concatenar valor dentro da string SQL é proibido no projeto, sem exceção. | Revisão de cada `where:` |
| **RNF12** | Somente HTTPS. Toda requisição tem `.timeout(const Duration(seconds: 15))`. Nenhuma tela mostra `toString()` de exceção nem *stack trace*. | Etapa 5 |
| **RNF13** | O app é **100% funcional sem rede**, exceto atualizar trilhas. Nenhuma tela trava esperando a internet. | Modo avião |
| **RNF14** | Partida fria até o Painel utilizável em **menos de 2 s**. O banco e as preferências abrem em `main()`, antes do `runApp`, e entram por `overrides`. | `flutter run --profile` |
| **RNF15** | `flutter analyze` termina com `No issues found!` usando `flutter_lints ^6.0.0`. Zero aviso, não "poucos avisos". | `flutter analyze` |
| **RNF16** | Testes nos três níveis: unitário (domínio, DAO, repositórios), widget (as 5 telas) e integração (fluxo completo). `flutter test` termina com `All tests passed!`. | Etapa 7 |
| **RNF17** | O mesmo código roda em 🤖 Android e 🍎 iOS com Material 3 nas duas. Nenhuma tela usa widget exclusivo de uma plataforma. | Etapa 8 |
| **RNF18** | Layout correto de **320 dp a 1280 dp** de largura. Acima de 600 dp as listas viram duas colunas. Nenhum `RenderFlex overflowed`. | Etapa 6 |
| **RNF19** | Rotacionar a tela ou reconstruir a árvore **não perde estado** — ele mora nos providers, fora da árvore de widgets. | Rotação manual |
| **RNF20** | Interface e dados em **pt-BR**. Datas, números e durações formatados com `intl`, nunca concatenados à mão. | Leitura de código |

---

## 🧱 Modelo de dados

O `domain/` de cada feature. **Nenhuma destas classes importa `package:flutter/material.dart`,
`sqflite` ou `http`** — é a regra de dependência da ADR-03.

```dart
// lib/features/materias/domain/materia.dart
@immutable
class Materia {
  const Materia({
    required this.id,           // uuid v4
    required this.nome,         // 2 a 60 caracteres, já com trim
    required this.criadaEm,
    this.corValor = 4284960932, // 0xFF6750A4 — ARGB em int; NUNCA dart:ui aqui
    this.minutos = 0,           // total acumulado, mantido por transação
    this.arquivada = false,
  });

  factory Materia.deLinha(Map<String, Object?> linha) { /* etapa 2 */ }

  final String id;
  final String nome;
  final DateTime criadaEm;
  final int corValor;
  final int minutos;
  final bool arquivada;

  Map<String, Object?> paraLinha();  // deriva nome_ordenacao aqui, num lugar só
  Materia copyWith({String? id, String? nome, DateTime? criadaEm,
                    int? corValor, int? minutos, bool? arquivada});
  // == e hashCode por valor
}

// lib/features/sessoes/domain/sessao.dart
@immutable
class Sessao {
  const Sessao({
    required this.id,
    required this.materiaId,
    required this.inicioEm,
    required this.minutos,  // 1 a 480
    this.anotacao = '',     // até 280 caracteres
  });

  factory Sessao.deLinha(Map<String, Object?> linha);

  static const int minimoDeMinutos = 1;
  static const int maximoDeMinutos = 480;

  final String id;
  final String materiaId;
  final DateTime inicioEm;
  final int minutos;
  final String anotacao;

  bool get ehDeHoje;
  Map<String, Object?> paraLinha();
  Sessao copyWith({String? id, String? materiaId, DateTime? inicioEm,
                   int? minutos, String? anotacao});
}

// lib/features/metas/domain/meta_semanal.dart
@immutable
class MetaSemanal {
  const MetaSemanal({required this.minutosAlvo, required this.minutosFeitos});
  static const int padraoMinutos = 300;  // 5 h

  final int minutosAlvo;
  final int minutosFeitos;

  double get progresso;      // 0.0 a 1.0, com clamp
  bool get atingida;
  int get minutosRestantes;  // nunca negativo
}

// lib/features/trilhas/domain/trilha.dart
@immutable
class Trilha {
  const Trilha({required this.id, required this.titulo, required this.descricao});
  final String id;        // veio como int da API, virou String no domínio
  final String titulo;
  final String descricao;
}

// lib/features/trilhas/domain/trilhas_resultado.dart
@immutable
class TrilhasResultado {
  const TrilhasResultado({
    required this.trilhas,
    required this.buscadoEm,
    required this.deCache,  // true = a rede falhou e isto veio do cache
  });
  final List<Trilha> trilhas;
  final DateTime buscadoEm;
  final bool deCache;
}

// lib/features/estatisticas/domain/resumo_semanal.dart
@immutable
class ResumoSemanal {
  const ResumoSemanal({
    required this.inicioDaSemana,     // segunda-feira, 00:00 local
    required this.minutosPorDia,      // 7 posições; índice 0 = segunda
    required this.minutosPorMateria,  // materiaId -> minutos
    required this.metaMinutos,
    required this.minutosSemanaAnterior,
  });
  final DateTime inicioDaSemana;
  final List<int> minutosPorDia;
  final Map<String, int> minutosPorMateria;
  final int metaMinutos;
  final int minutosSemanaAnterior;

  int get totalMinutos;
  int get mediaDiariaMinutos;
  double get progressoDaMeta;
  String get materiaMaisEstudadaId;  // '' quando não há sessões
}

// lib/features/sessoes/domain/cronometro_estado.dart
@immutable
class CronometroEstado {
  const CronometroEstado({
    this.materiaId = '',
    this.inicioEm,
    this.acumulado = Duration.zero,
    this.rodando = false,
  });
  final String materiaId;
  final DateTime? inicioEm;  // instante do último "iniciar" ou "retomar"
  final Duration acumulado;  // tempo contado antes da pausa atual
  final bool rodando;

  Duration decorridoAte(DateTime agora);
  int minutosArredondados(DateTime agora);  // mínimo 1
  CronometroEstado copyWith({String? materiaId, DateTime? inicioEm,
                             Duration? acumulado, bool? rodando});
}

// lib/core/tema/modo_de_tema.dart
enum ModoDeTema { claro, escuro, sistema }
```

---

## 🗄️ Esquema do banco

Arquivo `foco.db`, **versão 3**. O `onCreate` cria a forma final da v3; o `onUpgrade` aplica as
etapas `if (anterior < 2)` e `if (anterior < 3)`, para quem instalou durante o módulo 10.

```sql
-- PRAGMA obrigatório em onConfigure, a cada abertura.
-- Sem ele o ON DELETE CASCADE simplesmente não acontece.
PRAGMA foreign_keys = ON;

CREATE TABLE materias (
  id             TEXT    PRIMARY KEY,
  nome           TEXT    NOT NULL,
  nome_ordenacao TEXT    NOT NULL,                    -- minúsculo e SEM acento
  minutos        INTEGER NOT NULL DEFAULT 0,
  criada_em      INTEGER NOT NULL,                    -- millisecondsSinceEpoch
  arquivada      INTEGER NOT NULL DEFAULT 0,          -- v2 · booleano 0/1
  cor_valor      INTEGER NOT NULL DEFAULT 4284960932  -- v3 · ARGB 0xFF6750A4
);
CREATE INDEX idx_materias_nome_ordenacao ON materias (nome_ordenacao);

CREATE TABLE sessoes (
  id         TEXT    PRIMARY KEY,
  materia_id TEXT    NOT NULL,
  inicio_em  INTEGER NOT NULL,                        -- millisecondsSinceEpoch
  minutos    INTEGER NOT NULL,
  anotacao   TEXT    NOT NULL DEFAULT '',             -- v3
  FOREIGN KEY (materia_id) REFERENCES materias (id) ON DELETE CASCADE
);
CREATE INDEX idx_sessoes_materia ON sessoes (materia_id);
CREATE INDEX idx_sessoes_inicio  ON sessoes (inicio_em);

CREATE TABLE cache_trilhas (                          -- v3
  id         TEXT    PRIMARY KEY,                     -- sempre 'trilhas'
  conteudo   TEXT    NOT NULL,                        -- o JSON cru da resposta
  buscado_em INTEGER NOT NULL
);
```

> 📌 **A coluna de ordenação achatada.** `nome_ordenacao` existe porque o `ORDER BY` do SQLite
> compara **bytes**: sem ela, `Física` vem antes de `Álgebra`, e o `COLLATE NOCASE` não resolve
> porque só conhece ASCII. A coluna guarda o nome em minúsculo e sem acento, derivada em **um
> único lugar** — `Materia.paraLinha()`, via `Texto.paraOrdenacao`. Toda consulta de lista
> ordena por ela, nunca por `nome`.

> ⚠️ **Migração já publicada não se altera.** As etapas 1→2 e 2→3 do `onUpgrade` são
> históricas. Precisou de outra coluna? Crie a versão 4.

---

## 📱 As cinco telas

| # | Classe | Rota | O que mostra e faz |
|---|---|---|---|
| 1 | `InicioScreen` | `/` | Casca com `NavigationBar` de 3 abas: `PainelTab` (resumo do dia, anel de meta, 3 sessões recentes), `MateriasTab` (lista + FAB "Nova matéria") e `TrilhasTab` (lista da API com os 4 estados). `AppBar` com atalhos para Estatísticas e Configurações. |
| 2 | `MateriaFormScreen` | `/materia/form` | `Form` validado: nome (2–60, sem duplicata normalizada) e `SeletorDeCor` com 8 cores. Cria **ou** edita — recebe `MateriaFormArgs(materia: ...)`, com `materia` nula na criação. Devolve `bool?` por `Navigator.pop`. |
| 3 | `MateriaDetalheScreen` | `/materia/detalhe` | Recebe `MateriaDetalheArgs(materiaId: ...)`. Cabeçalho com nome, cor e total; `CronometroCard` com iniciar/pausar/parar; lista das 50 sessões mais recentes com deslizar-para-remover; menu com arquivar e excluir. |
| 4 | `EstatisticasScreen` | `/estatisticas` | `BarrasDaSemana` (7 barras, segunda a domingo), total e média da semana, comparação com a semana anterior e distribuição por matéria. Tudo agregado em SQL. |
| 5 | `ConfiguracoesScreen` | `/configuracoes` | Meta semanal (`Slider` de 30 a 3000, passo 30), tema (`SegmentedButton` claro/escuro/sistema), "Limpar cache de trilhas", versão do app e o aviso 🍎 sobre o build iOS. |

O detalhe de uma trilha **não** é uma sexta tela: é o `TrilhaDetalheSheet`, um
`showModalBottomSheet` disparado pelo `CartaoTrilha`.

---

## 🌐 A API

| Item | Valor |
|---|---|
| Base | `https://jsonplaceholder.typicode.com` (ADR-09 — pública, HTTPS, **sem token**) |
| Endpoint | `GET /posts?_limit=20` |
| Configurável por | `--dart-define=FOCO_API_BASE=...`, lido em `core/constantes/ambiente.dart` |
| Timeout | 15 s em toda requisição |
| Retry | 2 tentativas com backoff exponencial (1 s, 2 s), só para `5xx` e falha de conexão |

```json
[
  { "userId": 1, "id": 1, "title": "delectus aut autem", "body": "quia et suscipit..." }
]
```

Mapeamento `TrilhaDto` → `Trilha`: `id.toString()` → `id`; `title` → `titulo`;
`body` → `descricao`. `userId` **não** entra no domínio — não é conceito do Foco.

**Quando a API falha**, nesta ordem:

1. Cache dentro do TTL de 6 h → devolve o cache, **sem** ir à rede.
2. Rede falhou e existe cache (mesmo vencido) → devolve o cache com `deCache: true`, e a tela
   mostra "Atualizado há X · sem conexão" com botão "Tentar de novo".
3. Rede falhou e não há cache → `EstadoDeErro` com mensagem em português vinda da
   `sealed class Falha` e botão de repetir.
4. Resposta `200` com JSON inválido → `FalhaFormato`; o cache antigo é **preservado**.

> ⚠️ A JSONPlaceholder **simula** escrita: responde `201` mas não guarda nada. O Foco só **lê**
> dela — e é por isso que "marcar trilha como concluída" está fora de escopo.

---

## 🚫 Fora de escopo

| Não faz parte do projeto | Por quê |
|---|---|
| Login, cadastro e sincronização em nuvem | Exigiria back-end próprio; a ADR-12 deixa isso para o pós-curso |
| Escrita na API (criar ou editar trilha) | A API do curso não persiste (ADR-09) |
| Notificações agendadas e widget de tela inicial | Exploração do módulo 11, não entregável do projeto |
| Vários perfis de usuário no mesmo aparelho | Multiplicaria o esquema sem ensinar nada novo |
| Exportar PDF, compartilhar relatório, backup em arquivo | Vira desafio em [13-desafios.md](13-desafios.md) |
| Pomodoro com ciclos automáticos | Desafio opcional; o cronômetro simples já cobre o aprendizado |
| Tradução para outros idiomas | O curso é pt-BR (ADR-10) |
| `go_router`, `drift`, `dio`, geração de código | Contrariam as ADR-01, ADR-02, ADR-04 e ADR-05 |

---

## 🧭 Navegação do projeto

[README](README.md) · **01 Especificação (você está aqui)** ·
[02 Arquitetura](02-arquitetura.md) ·
[03 Etapa 1 — Fundação](03-etapa-1-fundacao.md) ·
[04 Etapa 2 — Domínio e dados](04-etapa-2-dominio-e-dados.md) ·
[05 Etapa 3 — Estado com Riverpod](05-etapa-3-estado-com-riverpod.md) ·
[06 Etapa 4 — Telas e navegação](06-etapa-4-telas-e-navegacao.md) ·
[07 Etapa 5 — API e trilhas](07-etapa-5-api-e-trilhas.md) ·
[08 Etapa 6 — Responsividade e acessibilidade](08-etapa-6-responsividade-e-acessibilidade.md) ·
[09 Etapa 7 — Testes](09-etapa-7-testes.md) ·
[10 Etapa 8 — Ícone, splash e versão](10-etapa-8-icone-splash-e-versao.md) ·
[11 Critérios de aceite](12-criterios-de-aceite.md) ·
[12 Desafios](13-desafios.md) ·
[13 Checklist](14-checklist.md)

| ⬅️ Anterior | 🏠 Início | ➡️ Próximo |
|---|---|---|
| [README do projeto](README.md) | [README do curso](../../README.md) | [02 — Arquitetura](02-arquitetura.md) |
