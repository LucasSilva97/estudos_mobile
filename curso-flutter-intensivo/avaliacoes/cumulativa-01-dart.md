# Avaliação — Cumulativa 01: Dart (módulos 00 a 04)

> **Tempo sugerido:** 35 min de questões + 80 min de prática. Faça sem consultar o material.

Aqui não se cobra módulo por módulo, e sim o que só aparece quando terminal, Git, coleções, classes,
contratos, assincronismo e tipos selados trabalham **no mesmo programa**. Tudo é Dart puro rodando
com `dart run` — nenhum widget, nenhum app Flutter ainda.

## 1. Questionário

Cada questão vale 1 ponto. São 12 pontos no total.

1. `Materia` é imutável e guarda `final List<Sessao> sessoes`, mas quem tem a referência consegue `materia.sessoes.add(...)` porque: A) `final` só protege tipos primitivos; B) `final` congela a **referência**, não o conteúdo — a defesa é `List.unmodifiable(...)` no construtor; C) faltou `const` na classe; D) `List` em Dart é sempre `late`.  
2. A linha é `Dart;abc;concluida`, `int.tryParse('abc')` devolveu `null` e o construtor exige `int minutos`. O correto: A) usar `int.parse` e deixar a exceção subir crua; B) declarar `late int minutos`; C) tratar o `null` **na borda** e, se a linha for inválida, descartá-la ou lançar `SessaoInvalidaException` com a linha original; D) escrever `minutos!`.  
3. Um `switch` expressão sobre `Resultado<List<Sessao>, String>`, com `sealed class Resultado<S, F>`, dispensa o caso `_` porque: A) generics desligam a exaustividade; B) a hierarquia selada é **fechada** e o compilador conhece todas as subclasses, independentemente dos parâmetros de tipo; C) `switch` expressão nunca exige exaustividade; D) `S` e `F` viram `dynamic` em execução.  
4. Você rodou `dart create -t console foco_cli` dentro do repositório. O que **nunca** entra no commit: A) `pubspec.yaml`; B) `analysis_options.yaml`; C) `bin/foco_cli.dart`; D) `.dart_tool/`, `build/` e qualquer `.env` com chave.  
5. Três buscas de 1 s cada, com `await` dentro de um `for`, levam ~3 s. Para cair para ~1 s: A) marque o `for` com `async`; B) troque `for` por `for-in`; C) `await Future.wait(materias.map(buscar).toList())`; D) aumente o `timeout` de cada chamada.  
6. `enum StatusSessao { planejada, concluida, cancelada }` resolve hoje. Você troca por `sealed class` quando: A) houver mais de cinco casos; B) cada caso precisar carregar **dados próprios** (minutos na concluída, motivo na cancelada); C) quiser usar `switch`; D) quiser `values` e `name`.  
7. Você fez `final sub = progresso.listen(print);` e esqueceu o `sub.cancel()`: A) a assinatura segue viva recebendo eventos e o `dart run` não encerra enquanto houver ouvinte ativo num controller aberto; B) o coletor de lixo cancela sozinho; C) a stream vira broadcast; D) um segundo `listen` passa a funcionar.  
8. `dart analyze` está limpo, mas ao rodar aparece `Unhandled exception: FormatException`. Isso é: A) erro de compilação que o `analyze` deveria ter apontado; B) aviso de lint; C) erro de **execução** — a análise não vê o dado que só existe rodando, e a linha culpada está no topo do stack trace; D) falha de `PATH`.

9. Seu programa passa no `dart analyze` e quebra com `Null check operator used on a null value`. Explique por que a análise estática não pega isso, como o `!` costuma chegar ali e o que entra no lugar dele.  
10. Descreva o caminho de um dado do terminal até virar objeto de domínio: `stdin.readLineSync()` → validação → construtor → coleção. Diga de quem é cada responsabilidade e o que nunca deve acontecer dentro do construtor.  
11. Você tem `abstract interface class Repositorio<T>` e uma implementação em memória. Explique o que o `<T>` acrescenta ao contrato e o que muda no código que consome quando a implementação virar uma que lê arquivo.  
12. Você introduziu um `Resultado` selado e o `switch` de três arquivos parou de compilar. Explique por que ter commitado por etapa muda o que você consegue fazer agora, e qual comando devolve a versão anterior de **um** arquivo sem jogar fora o resto do trabalho novo.

## 2. Prática

Crie `bin/cumulativa01_foco.dart` e monte o carregamento de sessões do Foco de ponta a ponta, em
Dart puro. Parta de linhas no formato `materia;minutos;status`, com casos válidos e inválidos:
valide na borda com `int.tryParse` e `StatusSessao.values.asNameMap()`, rejeitando linha torta com
`SessaoInvalidaException` que carregue a linha e o motivo. Guarde as válidas num
`RepositorioMemoria<T> implements Repositorio<T>` que devolve lista não modificável. A carga é
assíncrona (`Future.delayed` + `.timeout`) e devolve `Resultado<S, F>` selado; converta-o em um
`EstadoTela` selado (`Carregando` / `Vazio` / `SucessoEstado` / `ErroEstado`), com resumo em record
`({int total, double media})`, e renderize com `switch` expressão **sem** `_`. Feche acompanhando a
meta semanal por uma `Stream` que você **cancela**, com `dart analyze` e `dart format` limpos.

| Critério | Pontos |
|---|---:|
| Validação na borda com `tryParse` e `SessaoInvalidaException` com dados da linha | 2 |
| Modelo imutável (`copyWith`, `==`/`hashCode`) e repositório genérico com lista não modificável | 2 |
| Carga assíncrona com `.timeout` e `Resultado<S, F>` selado no lugar de exceção solta | 2 |
| `EstadoTela` selado com os quatro casos, record do resumo e `switch` expressão sem `_` | 2 |
| `Stream` escutada e cancelada, `dart analyze`/`dart format` limpos e commits feitos | 2 |

## 3. Critérios para avançar

- **9/12** no questionário e **8/10** na prática.
- Avaliações dos módulos 00 a 04 já aprovadas.
- `dart analyze` limpo e `dart format --output=none --set-exit-if-changed .` sem apontamentos.
- O programa roda em pasta sem acento e o repositório tem commits por etapa.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Commit por etapa e desfazer sem perder trabalho | [00 — Desfazendo erros e segredos](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md) | M00 E10 e E11 |
| Separar erro de compilação de erro de execução | [01 — Lendo mensagens de erro](../modulos/01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md) | M01 E08 |
| Nulo, `!` e conversão segura na borda | [02 — Null safety](../modulos/02-dart-basico/05-null-safety.md) | M02 E03 e E04 |
| Agrupar e resumir com `Set`, `Map` e `fold` | [02 — Sets e Maps](../modulos/02-dart-basico/09-sets-e-maps.md) | M02 E08 |
| Imutabilidade, `copyWith` e `==`/`hashCode` | [03 — Encapsulamento](../modulos/03-dart-intermediario/03-encapsulamento.md) | M03 E04 |
| Contrato e tipo genérico no repositório | [03 — Generics](../modulos/03-dart-intermediario/08-generics.md) | M03 E06 e E09 |
| Exceção de domínio e Result pattern | [04 — Exceptions](../modulos/04-dart-avancado/01-exceptions.md) | M04 E01 e E02 |
| `Future.wait` e `timeout` | [04 — Futures e async/await](../modulos/04-dart-avancado/02-futures-e-async-await.md) | M04 E04 |
| Stream escutada e cancelada | [04 — Streams](../modulos/04-dart-avancado/03-streams.md) | M04 E06 |
| Estados selados, records e exaustividade | [04 — Sealed classes](../modulos/04-dart-avancado/06-sealed-classes.md) | M04 E07 e E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#cumulativa-01)
