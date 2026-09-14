# Módulo 02 — Dart Básico

> **Trilha:** Dart puro, no terminal · **Sem Flutter ainda** · **Tempo estimado:** ~7 h de aulas + ~2 h de exercícios e avaliação

No módulo anterior você aprendeu a **pensar** como quem programa: variáveis, tipos, operadores,
condições, repetições e funções, explicados de forma genérica. Agora você vai aprender a
**escrever Dart de verdade** — a linguagem em que o Flutter é feito.

Este módulo inteiro roda no **terminal** (a janela de texto onde você digita comandos), sem
interface gráfica, sem celular, sem emulador. Isso é proposital: quando o Flutter chegar, no
módulo 05, a linguagem já não vai ser um obstáculo. Você vai poder gastar toda a sua atenção
aprendendo *widgets* (os blocos visuais do Flutter) em vez de brigar com ponto e vírgula.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- Criar um projeto Dart do zero com `dart create` e entender **cada pasta e cada arquivo** que ele gera.
- Ler e escrever código Dart seguindo o **guia de estilo oficial** da linguagem (nomes, chaves, comentários).
- Escolher com segurança entre `var`, `final`, `const` e `late` — e explicar **por quê** em cada caso.
- Trabalhar com texto: interpolação, aspas triplas, *raw strings*, conversão de texto para número e de volta.
- Entender **null safety** (segurança contra nulo), o recurso do Dart que evita a classe de erro mais comum
  da programação, e resolver o erro real `Null check operator used on a null value`.
- Controlar o fluxo do programa com `if`/`else`, `switch` *statement*, `switch` *expression*, `assert` e laços.
- Escrever funções com parâmetros posicionais, nomeados, obrigatórios e opcionais; usar *arrow functions*,
  funções anônimas, *closures* e `typedef`.
- Manipular coleções: `List`, `Set` e `Map`, com `map`, `where`, `fold`, `sort`, *spread*, *collection-if* e *collection-for*.
- Ler dados digitados pela pessoa usuária com `dart:io` e **validar** essa entrada sem o programa quebrar.
- Entregar, no fim, uma **calculadora de tempo de estudo** completa rodando no seu terminal.

---

## ✅ Pré-requisitos

| Requisito | Onde resolver |
|---|---|
| Flutter 3.47.1 e Dart 3.13.1 instalados e funcionando | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) |
| Saber abrir o terminal, navegar entre pastas e rodar comandos | [Módulo 00 — Git e Terminal](../00-git-e-terminal/README.md) |
| Entender variável, tipo, operador, condição, repetição e função **no conceito** | [Módulo 01 — Lógica e Fundamentos](../01-logica-e-fundamentos/README.md) |
| VS Code instalado com a extensão Dart | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) |

Confirme que o Dart responde antes de começar. No terminal:

```powershell
dart --version
```

Você deve ver a versão **3.13.1**. Se o comando não for reconhecido, volte para
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) — o problema é o PATH
(*PATH* é a lista de pastas onde o Windows procura os programas que você digita no terminal).

---

## 🗺️ Ordem recomendada das aulas

Siga **na ordem**. Cada aula usa algo da anterior.

| # | Aula | Tempo | O que você leva dela |
|---|---|---|---|
| 1 | [Anatomia de um programa Dart](01-anatomia-de-um-programa.md) | 35 min | `dart create`, estrutura do projeto, `main`, `dart run`, `dart compile` |
| 2 | [Sintaxe, convenções e comentários](02-sintaxe-convencoes-comentarios.md) | 30 min | Ponto e vírgula, chaves, padrões de nome, `///`, `dart format` |
| 3 | [`var`, `final`, `const` e `late`](03-var-final-const.md) | 40 min | Inferência de tipo, tempo de compilação × tempo de execução |
| 4 | [Tipos, strings e conversões](04-tipos-strings-conversoes.md) | 45 min | Interpolação, aspas triplas, `int.tryParse`, `num`, *runes* |
| 5 | [Null safety](05-null-safety.md) | 50 min | `T?`, `!`, `?.`, `??`, `??=`, promoção de tipo |
| 6 | [Controle de fluxo](06-controle-de-fluxo.md) | 40 min | `if`/`else`, `switch` *expression*, `assert`, laços, *labels* |
| 7 | [Funções em Dart](07-funcoes-em-dart.md) | 50 min | Parâmetros nomeados, `required`, *closures*, `typedef`, *callbacks* |
| 8 | [Listas](08-listas.md) | 50 min | `List`, *spread*, *collection-if*, `map`/`where`/`fold`, `sort` |
| 9 | [Sets e Maps](09-sets-e-maps.md) | 40 min | Unicidade, chave-valor, `putIfAbsent`, `update`, agrupamento |
| 10 | [Entrada e saída no terminal](10-entrada-e-saida.md) | 45 min | `dart:io`, `stdin.readLineSync()`, validação, programa completo |

**Total das aulas: 425 min (≈ 7 h).**

No ritmo **Intensivo recomendado** (30 dias) este módulo ocupa os **dias 4 e 5**:

| Dia | Conteúdo |
|---|---|
| 4 | Aulas 1 a 5 |
| 5 | Aulas 6 a 10 + exercícios + avaliação |

---

## 📝 Exercícios e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Lista de exercícios do módulo | [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md) | Ao terminar cada aula, faça os exercícios que citam aquele assunto |
| Avaliação do módulo | [avaliacoes/modulo-02-dart-basico.md](../../avaliacoes/modulo-02-dart-basico.md) | Só depois das 10 aulas e dos exercícios obrigatórios |

Os gabaritos ficam em `gabaritos/02-dart-basico.md` e estão linkados dentro de cada exercício.
Regra de ouro: **tente por 15 minutos antes de abrir o gabarito**. Ler solução pronta cria a
sensação de aprendizado sem o aprendizado.

---

## 🧰 O projeto que acompanha o módulo

Na Aula 1 você cria **um único projeto** chamado `dart_basico` e usa ele até o fim do módulo.
Cada aula adiciona um arquivo novo dentro da pasta `bin/` dele:

```text
dart_basico/
├── analysis_options.yaml
├── pubspec.yaml
├── bin/
│   ├── dart_basico.dart          ← gerado pelo dart create (Aula 1)
│   ├── saudacao.dart             ← Aula 1
│   ├── estilo.dart               ← Aula 2
│   ├── variaveis.dart            ← Aula 3
│   ├── textos.dart               ← Aula 4
│   ├── null_safety.dart          ← Aula 5
│   ├── fluxo.dart                ← Aula 6
│   ├── funcoes.dart              ← Aula 7
│   ├── listas.dart               ← Aula 8
│   ├── colecoes.dart             ← Aula 9
│   └── calculadora_estudo.dart   ← Aula 10
├── lib/
└── test/
```

Sempre que uma aula mostrar código completo, ela diz **o nome exato do arquivo** e **o comando
exato** para rodar. Digite o código; não copie e cole. Digitar é o que fixa a sintaxe.

---

## 🔗 Como este módulo se conecta ao resto do curso

| O que você aprende aqui | Onde reaparece |
|---|---|
| Estrutura de projeto e `main` | [05 — Estrutura do projeto Flutter](../05-introducao-ao-flutter/02-estrutura-do-projeto.md) |
| `const` | [13 — Rebuilds, const e keys](../13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md) |
| Null safety | [08 — AsyncNotifier e AsyncValue](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md) |
| Funções como valor (*callbacks*) | [06 — Gestos e feedback](../06-widgets-e-layouts/10-gestos-e-feedback.md) |
| `List` e *collection-for* | [06 — Listas e rolagem](../06-widgets-e-layouts/09-listas-e-rolagem.md) |
| `Map` | [09 — JSON](../09-consumo-de-api/02-json.md) |
| Validação de entrada | [07 — Validação, foco e teclado](../07-navegacao-e-formularios/07-validacao-foco-teclado.md) |

O módulo seguinte, [03 — Dart Intermediário](../03-dart-intermediario/README.md), pega tudo isso
e organiza em **classes e objetos**, que é como o Flutter inteiro é escrito.

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando for verdade de fato. Este é o portão de entrada do módulo 03.

- [ ] Li as **10 aulas** inteiras, na ordem.
- [ ] Criei o projeto `dart_basico` com `dart create` e sei dizer para que serve cada pasta dele.
- [ ] Digitei e rodei o **código completo** de todas as 10 aulas, e todos rodaram sem erro.
- [ ] Consigo explicar, sem consultar, a diferença entre `var`, `final`, `const` e `late`.
- [ ] Consigo explicar por que `String?` e `String` são tipos **diferentes** em Dart.
- [ ] Uso `int.tryParse` em vez de `int.parse` quando o texto vem de fora do programa.
- [ ] Escrevo uma função com parâmetro nomeado obrigatório (`required`) sem consultar material.
- [ ] Transformo uma lista com `map` e filtro com `where` sem usar laço `for`.
- [ ] Sei quando escolher `List`, `Set` ou `Map` e justifico a escolha.
- [ ] Meu código passa em `dart analyze` **sem nenhum aviso** e em `dart format .` sem mudanças.
- [ ] Fiz **todos os exercícios obrigatórios** de [exercicios/02-dart-basico.md](../../exercicios/02-dart-basico.md).
- [ ] Acertei **7 ou mais** das 10 questões de [avaliacoes/modulo-02-dart-basico.md](../../avaliacoes/modulo-02-dart-basico.md).
- [ ] A calculadora de tempo de estudo da Aula 10 roda e **não quebra** quando digito texto inválido.

Se algum item ficou desmarcado, a tabela "Se você teve dificuldade" da avaliação diz exatamente
qual aula revisar.

---

| ⬅️ Módulo anterior | 🏠 Curso | ➡️ Próximo módulo |
|---|---|---|
| [01 — Lógica e Fundamentos](../01-logica-e-fundamentos/README.md) | [README do curso](../../README.md) | [03 — Dart Intermediário](../03-dart-intermediario/README.md) |
