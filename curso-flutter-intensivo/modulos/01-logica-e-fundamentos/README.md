# Módulo 01 — Lógica e Fundamentos

> **Slug do módulo:** `01-logica-e-fundamentos`
> **Tempo estimado total:** ≈ 7 h de aulas + ≈ 1 h de exercícios = **8 h**
> **Posição no plano intensivo de 30 dias:** dias **2 e 3**
> **Nível:** Fundamental
> **Linguagem usada:** Dart 3.13.1 puro, rodando no terminal (ainda **sem** Flutter)

---

## 🧭 Do que trata este módulo

Este é o módulo em que você para de "copiar código que funciona" e passa a **entender por que
funciona**. Aqui nascem as ideias que você vai usar até o último dia do curso: o que é um
programa, o que a máquina faz com o seu texto, como guardar um valor, como decidir, como repetir
e como ler o que o computador responde quando algo dá errado.

Tudo é escrito em **Dart** (a linguagem que o Flutter usa) e executado no **terminal** — a janela
preta onde você digita comandos. Nenhuma tela de celular ainda. Isso é proposital: quando
chegarmos ao Flutter (módulo 05), a parte de lógica já vai estar resolvida na sua cabeça e você
poderá gastar toda a energia aprendendo a interface.

---

## 🎯 O que você vai aprender

Ao terminar este módulo você será capaz de:

- Explicar, com suas palavras, o que acontece entre você digitar um código e o computador
  executá-lo (código-fonte → compilação → execução).
- Diferenciar **compilador** e **interpretador**, e entender por que o Dart usa **JIT** durante o
  desenvolvimento e **AOT** no aplicativo publicado — que é exatamente o motivo de o Flutter ter
  *hot reload* e mesmo assim gerar apps rápidos.
- Explicar o que são **Dart**, **Flutter**, **engine**, **Skia/Impeller**, **APK**, **AAB** e
  **IPA**, e onde cada um entra na vida de um app.
- Escrever um **algoritmo** antes de escrever código, decompondo um problema grande em passos
  pequenos, e validá-lo com **teste de mesa**.
- Declarar **variáveis** e **constantes** em Dart e escolher conscientemente entre `var`, `final`
  e `const`.
- Trabalhar com os **tipos** `int`, `double`, `num`, `String`, `bool`, `dynamic` e `Object`, e
  converter texto em número com segurança.
- Usar todos os **operadores** do dia a dia, inclusive `~/`, `%`, `&&`, `||`, `!`, `??`, `??=`
  e `?.`.
- Tomar decisões com `if` / `else if` / `else`, operador ternário e `switch`.
- Repetir trabalho com `for`, `for-in`, `while`, `do-while`, controlando o fluxo com `break` e
  `continue` — e reconhecer um **laço infinito** antes de ele travar sua máquina.
- Criar **funções** com parâmetros, argumentos e retorno, e usar funções para eliminar repetição.
- **Ler mensagens de erro do Dart** e corrigir sozinho: separar erro de compilação de erro de
  execução, e encontrar a linha culpada dentro de um *stack trace*.

---

## ✅ Pré-requisitos

| Requisito | Onde resolver |
|---|---|
| Flutter 3.47.1 e Dart 3.13.1 instalados e funcionando | [`02-configuracao-do-ambiente.md`](../../02-configuracao-do-ambiente.md) |
| Saber abrir o terminal, navegar entre pastas e criar arquivos | [Módulo 00 — Git e Terminal](../00-git-e-terminal/README.md) |
| Saber o que é um repositório Git e como salvar seu progresso | [Módulo 00 — aula 03](../00-git-e-terminal/03-git-o-que-e.md) |
| VS Code instalado | [`02-configuracao-do-ambiente.md`](../../02-configuracao-do-ambiente.md) |

> 🪟 **Windows.** Todos os comandos deste módulo são mostrados em **PowerShell**, que é o terminal
> padrão do Windows 11. Se o Módulo 00 ainda não foi feito, faça-o antes: sem terminal, este
> módulo trava na primeira aula.

### Preparação única (faça antes da Aula 1)

Todas as aulas gravam arquivos `.dart` dentro de **um único projeto de prática**. Crie-o uma vez:

```powershell
mkdir C:\src
cd C:\src
dart create -t console pratica_dart
cd C:\src\pratica_dart
dart run
```

- `mkdir C:\src` cria a pasta `src` na raiz do disco C. Se ela já existir, o PowerShell avisa e
  você pode seguir em frente.
- `dart create -t console pratica_dart` cria um projeto Dart de terminal (`-t console` = *template
  console*, ou seja, modelo de aplicação de linha de comando).
- `dart run` executa o programa inicial que o modelo gerou, só para confirmar que o Dart funciona.

> ⚠️ **Por que `C:\src` e não `Documentos`?** O nome do seu usuário no Windows tem acento
> (`Usuário`). Várias ferramentas do ecossistema Flutter quebram com acentos no caminho — este
> curso documenta os erros reais em [`referencias/erros-comuns.md`](../../referencias/erros-comuns.md).
> Manter o código em `C:\src` evita a classe inteira de problemas.

---

## 📚 Ordem recomendada das aulas

Siga exatamente esta ordem. Cada aula supõe a anterior.

| # | Aula | Tempo | O que você sai sabendo |
|---|---|---|---|
| 1 | [O que é programar](01-o-que-e-programar.md) | 35 min | Código-fonte, compilador × interpretador, AOT, JIT, bytecode, SDK, IDE, terminal, emulador, simulador |
| 2 | [Dart e Flutter](02-dart-e-flutter.md) | 40 min | Dart, Flutter, engine, Skia/Impeller, nativo × multiplataforma × WebView, APK, AAB, IPA |
| 3 | [Algoritmos e decomposição](03-algoritmos-e-decomposicao.md) | 40 min | Algoritmo, entrada/processamento/saída, pseudocódigo, decomposição, teste de mesa |
| 4 | [Variáveis e constantes](04-variaveis-e-constantes.md) | 35 min | Memória, variável, atribuição, nomes, `var`, `final`, `const` |
| 5 | [Tipos de dados](05-tipos-de-dados.md) | 45 min | `int`, `double`, `num`, `String`, `bool`, `dynamic`, `Object`, conversão e *parsing* |
| 6 | [Operadores](06-operadores.md) | 45 min | Aritméticos (`~/`, `%`), relacionais, lógicos, atribuição composta, precedência, `??`, `??=`, `?.`, `++` |
| 7 | [Condições](07-condicoes.md) | 45 min | `if` / `else if` / `else`, ternário, `switch`, combinação de condições |
| 8 | [Repetições](08-repeticoes.md) | 50 min | `for`, `for-in`, `while`, `do-while`, `break`, `continue`, contadores, acumuladores |
| 9 | [Funções](09-funcoes.md) | 45 min | Função, parâmetro, argumento, retorno, `void`, escopo, decomposição |
| 10 | [Lendo mensagens de erro](10-lendo-mensagens-de-erro.md) | 40 min | Anatomia do erro, compilação × execução, *stack trace*, método de depuração |

**Total das aulas:** 420 min = **7 horas**.

### Sugestão de divisão em 2 dias (ritmo intensivo, 4 h/dia)

| Dia do plano | Bloco | Conteúdo |
|---|---|---|
| **Dia 2** | 3 h de conteúdo | Aulas 1 a 5 |
| **Dia 2** | 1 h de prática | Exercícios de fixação e aplicação das aulas 1–5 |
| **Dia 3** | 3 h de conteúdo | Aulas 6 a 10 |
| **Dia 3** | 1 h de prática | Restante dos exercícios + avaliação do módulo |

O plano completo dos 30 dias está em [`01-plano-intensivo.md`](../../01-plano-intensivo.md).

---

## 🛠️ Prática e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Exercícios do módulo | [`exercicios/01-logica-e-fundamentos.md`](../../exercicios/01-logica-e-fundamentos.md) | Ao fim de cada bloco de aulas |
| Gabarito dos exercícios | [`gabaritos/01-logica-e-fundamentos.md`](../../gabaritos/01-logica-e-fundamentos.md) | **Só depois** de tentar de verdade |
| Avaliação do módulo | [`avaliacoes/modulo-01-logica-e-fundamentos.md`](../../avaliacoes/modulo-01-logica-e-fundamentos.md) | Depois da Aula 10 |
| Glossário | [`referencias/glossario.md`](../../referencias/glossario.md) | Sempre que um termo escapar |
| Erros comuns | [`referencias/erros-comuns.md`](../../referencias/erros-comuns.md) | Quando o terminal reclamar |
| Comandos úteis | [`referencias/comandos-uteis.md`](../../referencias/comandos-uteis.md) | Quando esquecer um comando |

> ⚠️ Consultar o gabarito antes de tentar é a forma mais rápida de sentir que aprendeu sem ter
> aprendido. Erre primeiro. O erro é o conteúdo.

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando for verdade **sem consultar o material**:

- [ ] Consigo explicar em voz alta a diferença entre **compilar** e **interpretar**, e dizer por
      que o Dart usa JIT no desenvolvimento e AOT no app publicado.
- [ ] Consigo explicar o que são **APK**, **AAB** e **IPA** e para que serve cada um.
- [ ] Consigo escrever o algoritmo de um problema **antes** de escrever o código, em português,
      separando entrada, processamento e saída.
- [ ] Faço **teste de mesa** de um trecho de código com papel e caneta e acerto o resultado antes
      de executar.
- [ ] Escolho corretamente entre `var`, `final` e `const` e sei justificar a escolha.
- [ ] Converto texto em número usando `int.tryParse` e trato o caso de falha.
- [ ] Sei a diferença entre `/` e `~/`, e uso `%` para testar se um número é par.
- [ ] Escrevo uma condição composta com `&&` e `||` sem precisar tentar por tentativa e erro.
- [ ] Escrevo um `for`, um `while` e um `do-while` corretos, e sei quando cada um cabe melhor.
- [ ] Escrevo uma função com parâmetro e retorno e explico a diferença entre **parâmetro** e
      **argumento**.
- [ ] Diante de uma mensagem de erro do Dart, identifico arquivo, linha, coluna e se é erro de
      compilação ou de execução — e corrijo sem pedir ajuda.
- [ ] Resolvi **todos** os exercícios obrigatórios de
      [`exercicios/01-logica-e-fundamentos.md`](../../exercicios/01-logica-e-fundamentos.md).
- [ ] Acertei pelo menos **7 das 10** questões de
      [`avaliacoes/modulo-01-logica-e-fundamentos.md`](../../avaliacoes/modulo-01-logica-e-fundamentos.md)
      e entreguei o exercício prático rodando.
- [ ] Meus arquivos `.dart` do módulo estão salvos e commitados no Git.

Se algum item ficou desmarcado, volte à aula correspondente pela tabela acima. Avançar com
buraco na base custa muito mais caro nos módulos 08 (estado) e 09 (API).

---

## ➡️ Depois deste módulo

O próximo passo é o [Módulo 02 — Dart Básico](../02-dart-basico/README.md), onde tudo o que você
viu aqui de forma introdutória vira uso profissional da linguagem: anatomia completa de um
programa, convenções de escrita, `var`/`final`/`const` a fundo, *null safety*, listas, sets, maps
e entrada de dados pelo teclado.

---

| 🏠 Curso | 📋 Plano | ⬅️ Módulo anterior | ➡️ Próximo módulo |
|---|---|---|---|
| [README do curso](../../README.md) | [Plano intensivo](../../01-plano-intensivo.md) | [00 — Git e Terminal](../00-git-e-terminal/README.md) | [02 — Dart Básico](../02-dart-basico/README.md) |
