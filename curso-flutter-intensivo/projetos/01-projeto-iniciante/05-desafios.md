# Desafios — Projeto 01: Meu Primeiro App

> **Pasta:** `meu_primeiro_app` · **Base:** [01-especificacao.md](01-especificacao.md)

> ⚠️ **Opcional**, e só faz sentido com o projeto base funcionando: os 20 requisitos de
> [06-checklist.md](06-checklist.md) marcados e `flutter analyze` limpo.

> 📌 **D01–D05 respeitam o escopo do projeto**: zero pacote externo, uma tela só, estado só com
> `setState`. **D06 e D07 usam widget que você ainda não viu** — achá-los na documentação oficial
> ([api.flutter.dev](https://api.flutter.dev)) faz parte do desafio.

---

<a id="p01-d01"></a>
## P01-D01 — Sessão de 90 minutos · Fácil
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Estender o `SegmentedButton` sem estourar | Fácil | 15 min |

Acrescente um quarto `ButtonSegment<int>` de valor `90`. Com quatro rótulos `NN min` a linha estoura
por volta de 360 px: troque-os pelo número puro (`15`, `25`, `50`, `90`) e mova a unidade para o
título — `Duração da sessão (min)`.

**Esperado:** em **320 px** de largura, nenhum `RenderFlex overflowed`; com `90`, concluir uma
sessão soma 90 min aos totais **e** à matéria selecionada.

[🔑 Gabarito](../../gabaritos/projeto-01-desafios.md#p01-d01)

---

<a id="p01-d02"></a>
## P01-D02 — Percentual no cartão · Fácil
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Derivar mais um valor no modelo, não na interface | Fácil | 20 min |

Adicione a `Materia` o getter `int get percentual => (progresso * 100).round();` e mostre-o no
`CartaoMateria`, à direita de `<tempo> de <meta> min`, como `79%`. O cálculo fica no modelo; a cor
sai do `colorScheme` (RF05).

**Esperado:** Dart abre em `79%` e Testes em `0%`; nenhum cartão passa de `100%`, nem após dez
sessões de 50 min na mesma matéria.

[🔑 Gabarito](../../gabaritos/projeto-01-desafios.md#p01-d02)

---

<a id="p01-d03"></a>
## P01-D03 — Metas cumpridas no resumo · Fácil
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Passar mais um dado pronto do pai para o filho | Fácil | 20 min |

Dê à `BarraResumo` o parâmetro `required this.metasAtingidas` e exiba `N de 4 metas cumpridas` na
linha do `Em foco:`. Quem conta é a `HomeTela`, com
`_materias.where((Materia m) => m.metaAtingida).length` — a barra continua sem calcular nada.

**Esperado:** abre em `0 de 4`; uma sessão de 25 min em Dart (95 → 120) leva a `1 de 4`; "Zerar o
dia" volta a `0 de 4`.

[🔑 Gabarito](../../gabaritos/projeto-01-desafios.md#p01-d03)

---

<a id="p01-d04"></a>
## P01-D04 — Ordenar por progresso · Médio
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Guardar uma preferência de exibição no `State` | Médio | 30 min |

Adicione uma 2ª `action` na `AppBar` (`Icons.sort`) que alterna entre a ordem original e "menor
progresso primeiro", guardando um `bool _ordenadoPorProgresso` e ordenando com `sort` + `compareTo`.
⚠️ `_zerarDia()` recria `_materias` de `materiasIniciais` e desfaz a ordenação se você não
reaplicá-la.

**Esperado:** ligado, Testes (0 %) vem em 1º e Dart (79 %) em último; zerar o dia **mantém** a
ordem escolhida e o `tooltip` diz qual ordem está ativa.

[🔑 Gabarito](../../gabaritos/projeto-01-desafios.md#p01-d04)

---

<a id="p01-d05"></a>
## P01-D05 — Meta do dia · Médio
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Criar um widget novo no padrão do projeto | Médio | 30 min |

Crie `lib/widgets/meta_do_dia.dart` com `const int metaDiariaMinutos = 120;` e `MetaDoDia`
(`StatelessWidget` const, `required this.minutosTotais`): mostra `X de 120 min` e um
`LinearProgressIndicator` com `value: (minutosTotais / metaDiariaMinutos).clamp(0.0, 1.0)`. Passando
de 120, o texto vira `Meta do dia cumprida — +N min de bônus`. Encaixe-o abaixo da `BarraResumo`.

**Esperado:** 100 min deixam a barra em ~83 %; 150 min, cheia e com `+30 min de bônus`; nenhuma
cor literal no arquivo novo.

[🔑 Gabarito](../../gabaritos/projeto-01-desafios.md#p01-d05)

---

<a id="p01-d06"></a>
## P01-D06 — O número que anima · Difícil (pesquisa)
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Achar um widget que o curso não ensinou | Difícil | 40 min |

⚠️ **Animação não é assunto de nenhum módulo do curso** — a fonte é a documentação oficial.
Faça o número grande do `ContadorSessoes` **crescer** em vez de pular: procure `TweenAnimationBuilder`
em [api.flutter.dev](https://api.flutter.dev), anime de `0` até `sessoes` em 300 ms com
`Curves.easeOut` e arredonde o valor dentro do `builder`.

**Esperado:** concluir faz o número correr até o valor novo e remover faz ele voltar — sem `Timer`,
sem `AnimationController` e sem virar `StatefulWidget`. O estado segue na `HomeTela`.

[🔑 Gabarito](../../gabaritos/projeto-01-desafios.md#p01-d06)

---

<a id="p01-d07"></a>
## P01-D07 — O app para quem não vê a tela · Difícil (pesquisa)
| Objetivo | Dificuldade | Tempo |
|---|---|---:|
| Descrever a interface para o leitor de tela | Difícil | 40 min |

⚠️ Acessibilidade só volta no
[M13 · 05](../../modulos/13-desempenho-e-seguranca/05-acessibilidade.md); aqui você se vira com a
documentação. Ligue `showSemanticsDebugger: true` no `MaterialApp` e conserte o que aparecer: barra
sem rótulo, número grande sem contexto, cartão lido como três textos soltos. Pesquise `Semantics`,
`semanticsLabel`, `MergeSemantics` e `ExcludeSemantics`.

**Esperado:** cada cartão é lido como **um** item (`Dart, 95 de 120 minutos, 79 por cento`), o
contador lê `N sessões concluídas hoje` e `showSemanticsDebugger` volta a `false` no fim.

[🔑 Gabarito](../../gabaritos/projeto-01-desafios.md#p01-d07)

---

| Arquivo | Para quê |
|---|---|
| [README](README.md) | Visão geral |
| [01-especificacao](01-especificacao.md) | O que construir |
| [02-passo-a-passo](02-passo-a-passo.md) | Construção guiada |
| [03-codigo-completo](03-codigo-completo.md) | Arquivos finais |
| [04-testes](04-testes.md) | `flutter test` |
| **05-desafios.md** | 📍 Você está aqui ([gabarito](../../gabaritos/projeto-01-desafios.md)) |
| [06-checklist](06-checklist.md) | Critérios de "pronto" |
