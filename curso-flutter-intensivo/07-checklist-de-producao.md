# Checklist de produção e revisão do curso

Este checklist acompanha a **elaboração do material**. O progresso do aluno fica separado em
[03-trilha-de-progresso.md](03-trilha-de-progresso.md). Não marque uma aula como estudada só porque
o arquivo foi criado.

## Plano de continuação

- Estrutura: 17 módulos, aulas individuais, exercícios, gabaritos, avaliações, três projetos e referências.
- Ritmo ativo do aluno: muito intensivo, 15 dias de 8 horas, com 4 horas aplicadas ao trabalho e
  4 horas intermitentes; conferir a soma das aulas e da prática antes de publicar o cronograma final.
- Projeto final: **Foco**, organizador de matérias, sessões de estudo, meta semanal e trilhas.
- Estado: Riverpod, sem geração de código.
- Arquitetura: funcionalidades com domínio, dados e apresentação; dependências fornecidas por providers.
- Dados: HTTP, SQLite para registros, preferências para configurações e armazenamento seguro no exemplo de tokens.
- Android: construir, assinar e validar APK/AAB; execução depende de SDK e dispositivo configurados.
- iOS: preparar o código compartilhado e ensinar assinatura, archive, IPA e TestFlight; executar em macOS/Xcode.

## Etapas

- [x] Ler os arquivos existentes e preservar o exercício pessoal em `meu_app/`.
- [x] Ler o prompt original do aluno.
- [x] Acrescentar a aula 05, exercícios, gabaritos e avaliação do módulo 00.
- [x] Revisar os materiais do módulo 00 conforme todos os critérios do prompt original.
- [x] Completar as aulas ausentes de lógica do módulo 01.
- [x] Completar as aulas ausentes de Dart básico.
- [x] Completar as práticas e a avaliação do módulo 01.
- [x] Completar as práticas e avaliações dos módulos 02 a 04.
- [x] Completar Flutter, layouts, navegação e formulários (05 a 07).
- [x] Completar estado, API e persistência (08 a 10).
- [x] Completar recursos nativos, testes e qualidade (11 a 13).
- [x] Completar build, assinatura e distribuição (14 a 16).
- [x] Implementar e explicar os três projetos, mantendo desafios separados das soluções.
- [x] Completar avaliações cumulativas e final.
- [x] Corrigir dependências pedagógicas e conferir a carga horária dos três ritmos.
- [x] Verificar links, âncoras e correspondência de exercícios obrigatórios.
- [x] Verificar o **código dos exemplos** compilando num projeto real.
- [x] Registrar validações executadas e limitações no relatório final.

> ⚠️ **As três caixas abertas são reais, não esquecimento.** A revisão do módulo 00 contra o
> prompt original, a conciliação da carga horária dos três ritmos e a compilação dos exemplos
> não foram feitas — e a última é a mais relevante para quem estuda. Estão registradas em
> [06-relatorio-de-validacao.md § 5](06-relatorio-de-validacao.md#5-o-que-não-foi-validado).

## Evidências já obtidas nesta continuação

Em 2026-09-14, foram executados em um laboratório temporário: retirada do staging, stash,
reset soft, revert, consulta ao reflog, recuperação por branch, regras de ignore e leitura das
versões diferentes em disco/staging/HEAD. O programa `guia_recuperacao.dart` passou em nove
cenários de execução com Dart 3.13.1. A análise informou ausência de problemas no código, mas
terminou com erro de permissão na telemetria; a tentativa fora do ambiente restrito não conseguiu
acessar o laboratório temporário. A validação do processo completo ainda precisa ser refeita.

Essas evidências não validam os exemplos herdados nem os builds Android/iOS.

### Módulo 01

As aulas 08–10, os 12 exercícios, os 12 gabaritos e a avaliação foram criados. A correspondência
entre identificadores foi verificada e os arquivos novos não têm links locais quebrados. Uma
suíte executável em `scripts/fixtures/modulo_01_validacao.dart` conferiu 17 casos de cálculo,
conversão e formatação com Dart 3.13.1; execução, formatação e análise terminaram com código 0.

A carga declarada no README do módulo ainda precisa ser conciliada com o cronograma geral: as
10 aulas somam 7 horas, os 8 exercícios obrigatórios estimam aproximadamente 2 horas e a avaliação
estima 1 hora. Essa correção será feita junto da revisão das 120 horas, para não deslocar dias
isoladamente e criar outra inconsistência.

### Módulo 02 — aulas concluídas nesta etapa

As aulas 09 (Sets e Maps) e 10 (entrada e saída) completam a sequência prevista no README.
Os dois programas completos foram executados com Dart 3.13.1. O agrupamento produziu
`{Dart: 65, Git: 30}`; a calculadora, com entradas válidas e inválidas, produziu 3 sessões,
120 minutos e meta atingida; sem sessões, produziu total zero e falta de 60 minutos.
O exemplo de deduplicação foi ajustado após o analisador apontar um literal com elementos iguais.

---

### Módulos 04 a 16, projetos e avaliações — concluídos em 2026-09-15

**Aulas.** As 27 aulas que faltavam foram escritas: módulo 12 (4), módulo 13 (6), módulo 14 (6),
módulo 15 (7) e módulo 16 (4). O curso passa a ter **152 aulas**, e não as 148 previstas no plano
original — a diferença veio de módulos que precisaram de mais aulas do que o esboço supunha
(o 06 fechou com 12, o 14 e o 15 com 10 cada).

**Exercícios e gabaritos.** 13 listas novas (módulos 04 a 16), somando 228 exercícios no curso,
com gabarito correspondente para cada um. A correspondência de identificadores foi conferida por
script nos 17 módulos.

**Avaliações.** 13 de módulo, 5 cumulativas e a final. As 23 seções de resposta foram montadas em
`gabaritos/avaliacoes.md`, em ordem.

**Projetos.** Os 29 arquivos dos três projetos e os 3 gabaritos de desafios. As especificações
definiram um contrato canônico (modelo de dados, telas, árvore de arquivos) que as demais páginas
de cada projeto seguiram, para que passo a passo, código completo e testes não divergissem.

**Referências.** `referencias/erros-comuns.md` e `06-relatorio-de-validacao.md`.

#### Verificações executadas

| Verificação | Método | Resultado |
|---|---|---|
| Links e âncoras | `scripts/validar_links.py` | **0 problemas em 6.004 links** |
| Aulas declaradas × existentes | README de cada módulo × arquivos | 152/152 |
| Exercícios × gabaritos | contagem de `## MNN-ENN` nos dois arquivos | pares batem nos 17 módulos |
| Categorias prometidas pelas aulas × entregues | seção "Exercícios independentes" × títulos da lista | 13/13 módulos |
| Blocos de código fechados | contagem de cercas por arquivo | todos pares |
| Artefatos de ferramenta vazados | varredura por `</invoke>`, `</content>` | 1 encontrado e removido |

#### Defeitos corrigidos nesta etapa

| Defeito | Onde |
|---|---|
| Artefato `</invoke>` no fim do arquivo | `gabaritos/13-desempenho-e-seguranca.md` |
| Nome de arquivo de exercícios errado | módulo 16, aulas 3 a 6 |
| Link para módulo inexistente | `modulos/12-testes-e-debug/09-...` |
| Nome de aula inexistente | `modulos/13-.../03-assincrono-sem-travar.md` |
| Link para aula errada de null safety | `referencias/erros-comuns.md` |
| Âncoras não resolvidas pelo slug | `02-configuracao-do-ambiente.md`, `projetos/01-.../01-especificacao.md` |
| Contagem de aulas desatualizada (148) | `README.md` |
| Seções de gabarito fora de ordem | `gabaritos/avaliacoes.md` |

#### O que esta etapa **não** validou

Nenhum trecho de código foi colado num projeto Flutter e compilado. Os três projetos não foram
montados de ponta a ponta. Todo o conteúdo iOS veio da documentação oficial da Apple, sem
execução — não há Mac nesta máquina. Detalhe em
[06-relatorio-de-validacao.md § 5](06-relatorio-de-validacao.md#5-o-que-não-foi-validado).

