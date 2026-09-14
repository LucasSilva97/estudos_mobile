# Módulo 00 — Git e Terminal

> **Tempo estimado total:** 240 min (4 h) · **Nível:** Fundamental · **Posição no plano:** Dia 1 do ritmo intensivo de 30 dias

Este é o módulo zero do curso. Ele não ensina Flutter ainda — ele ensina as **duas ferramentas que
você vai usar todos os dias** durante os 30 dias seguintes: o **terminal** (a janela onde você digita
comandos para o computador) e o **Git** (o programa que guarda o histórico do seu código).

Sem essas duas ferramentas, nada do resto funciona: o Flutter é operado por comandos de terminal
(`flutter run`, `flutter build apk`) e todo projeto profissional vive dentro de um repositório Git.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- Abrir e usar o terminal no Windows 11 (PowerShell) sem medo de quebrar o computador.
- Navegar pelo sistema de arquivos por comandos: descobrir onde você está, entrar em pastas, listar
  conteúdo, criar e apagar arquivos **com segurança**.
- Ler a saída de um comando e entender o **código de saída** (o número que o comando devolve dizendo
  se deu certo ou errado).
- Entender o que é a variável de ambiente `PATH` e por que ela é a causa de metade dos erros de
  "comando não reconhecido".
- Diferenciar **caminho absoluto** de **caminho relativo** e escrever os dois corretamente no Windows
  e no macOS/Linux.
- Explicar por que **acento e espaço no caminho** quebram ferramentas — incluindo os dois erros reais
  já reproduzidos nesta máquina (`Cannot resolve symbolic links` e `ShaderCompilerException`).
- Criar um repositório Git, entender **working tree**, **staging area** e **commit**, e registrar seu
  progresso com `git add`, `git commit`, `git log`.
- Escrever mensagens de commit que servem para alguma coisa, trabalhar com **branches** e fazer um
  **merge** simples.
- Escrever um `.gitignore` completo para um projeto Flutter.
- Desfazer erros com `git restore`, `git reset`, `git revert`, `git stash` e recuperar trabalho
  "perdido" com `git reflog`.
- Proteger **segredos** (chaves de assinatura, `.env`, arquivos de configuração do Firebase) para que
  eles nunca entrem no histórico do repositório.

Cada aula também traz um programa em **Dart** de verdade, rodando no terminal, para você já ir
ganhando quilometragem na linguagem enquanto aprende a ferramenta.

---

## ✅ Pré-requisitos

- Ter concluído a configuração de ambiente descrita em
  [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).
  Você precisa, no mínimo, do **Git 2.46+** e do **Flutter 3.47.1 / Dart 3.13.1** instalados e
  respondendo no terminal.
- Ter lido [00-como-usar-o-curso.md](../../00-como-usar-o-curso.md), para saber como as aulas,
  exercícios, gabaritos e avaliações se conectam.
- Um editor de texto instalado. O curso assume o **VS Code**.
- **Nenhum conhecimento prévio de terminal ou de Git.** Este módulo começa do zero absoluto.

> Se você ainda não instalou nada, pare aqui e volte para
> [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) primeiro. Tentar aprender
> Git sem Git instalado só gera frustração.

---

## 🗺️ Ordem recomendada das aulas

Faça na ordem. Cada aula assume o vocabulário da anterior.

| # | Aula | Tempo | O que você sai sabendo |
|---|---|---|---|
| 1 | [O terminal sem medo](01-o-terminal-sem-medo.md) | 45 min | Abrir o terminal, navegar, ler saídas, código de saída, `PATH` e variáveis de ambiente |
| 2 | [Arquivos e caminhos](02-arquivos-e-caminhos.md) | 40 min | Caminho absoluto × relativo, separadores, extensões, UTF-8 e por que acento no caminho quebra o Flutter |
| 3 | [Git: o que é](03-git-o-que-e.md) | 55 min | Controle de versão, `git init`, `status`, `add`, `commit`, `log`, configuração e remoto |
| 4 | [Commits, branches e .gitignore](04-commits-branches-gitignore.md) | 50 min | Mensagens de commit boas, branches, `switch`, merge simples, `.gitignore` completo de Flutter |
| 5 | [Desfazendo erros e segredos](05-desfazendo-erros-e-segredos.md) | 50 min | `restore`, `reset`, `revert`, `stash`, `reflog` e proteção de segredos |

**Total: 240 min de conteúdo.** No ritmo intensivo recomendado (4 h/dia), este módulo ocupa o
**Dia 1** junto com a configuração de ambiente. Veja o cronograma completo em
[01-plano-intensivo.md](../../01-plano-intensivo.md).

---

## 🧪 Prática e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Exercícios do módulo | [exercicios/00-git-e-terminal.md](../../exercicios/00-git-e-terminal.md) | Depois de terminar as 5 aulas |
| Gabaritos comentados | [gabaritos/00-git-e-terminal.md](../../gabaritos/00-git-e-terminal.md) | Só **depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-00-git-e-terminal.md](../../avaliacoes/modulo-00-git-e-terminal.md) | Ao final, para liberar o Módulo 01 |

Referências de apoio que você vai consultar o curso inteiro:

- [referencias/comandos-uteis.md](../../referencias/comandos-uteis.md) — cola de comandos.
- [referencias/glossario.md](../../referencias/glossario.md) — todo termo técnico do curso.
- [referencias/erros-comuns.md](../../referencias/erros-comuns.md) — erros reais e como corrigir.

---

## 🧰 Preparação prática (faça uma vez, agora)

Todas as aulas deste módulo usam a mesma pasta de laboratório. Crie-a antes de começar, em um
caminho **sem acentos e sem espaços** — a Aula 2 explica em detalhe por quê.

**🪟 Windows (PowerShell)**

```powershell
New-Item -ItemType Directory -Force C:\src\cursos
Set-Location C:\src\cursos
dart create -t console lab_modulo_00
Set-Location C:\src\cursos\lab_modulo_00
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**

```bash
mkdir -p ~/src/cursos
cd ~/src/cursos
dart create -t console lab_modulo_00
cd ~/src/cursos/lab_modulo_00
```

`dart create -t console <nome>` cria um projeto Dart de linha de comando já pronto, com a pasta
`bin/` (onde ficam os programas executáveis) e o arquivo `pubspec.yaml` (o arquivo que descreve o
projeto e suas dependências). Os programas de cada aula vão dentro de `bin/`.

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando você conseguir fazer **sem consultar a aula**:

- [ ] Abro o PowerShell, descubro em que pasta estou e entro em outra pasta usando caminho absoluto
      e caminho relativo.
- [ ] Listo o conteúdo de uma pasta, incluindo arquivos ocultos, e leio a saída sem me perder.
- [ ] Explico o que é código de saída e verifico o código do último comando executado.
- [ ] Mostro o conteúdo da variável `PATH` e explico para que ela serve.
- [ ] Explico, com as mensagens de erro reais, por que um caminho com acento quebra o Flutter nesta
      máquina e qual é a correção.
- [ ] Crio um repositório Git do zero, configuro `user.name` e `user.email`, e faço pelo menos três
      commits com mensagens claras.
- [ ] Leio `git status` e digo, olhando a saída, o que está na working tree, o que está no staging
      e o que já foi commitado.
- [ ] Crio uma branch, faço um commit nela, volto para a `main` e faço o merge.
- [ ] Escrevo do zero um `.gitignore` de projeto Flutter cobrindo `build/`, `.dart_tool/`,
      `key.properties`, `*.jks` e `.env`.
- [ ] Desfaço uma alteração não commitada, desfaço um commit sem perder o trabalho e recupero um
      commit "perdido" usando `git reflog`.
- [ ] Listo de cor pelo menos cinco tipos de arquivo que **nunca** podem ser versionados.
- [ ] Rodo os cinco programas Dart do módulo com `dart run bin/<arquivo>.dart` e entendo cada linha.
- [ ] Concluí ao menos **8 exercícios obrigatórios** de
      [exercicios/00-git-e-terminal.md](../../exercicios/00-git-e-terminal.md).
- [ ] Acertei **7 ou mais** das 10 questões de
      [avaliacoes/modulo-00-git-e-terminal.md](../../avaliacoes/modulo-00-git-e-terminal.md).

Quando todos os itens estiverem marcados, siga para o
[Módulo 01 — Lógica e Fundamentos](../01-logica-e-fundamentos/README.md).

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Configuração do ambiente](../../02-configuracao-do-ambiente.md) | [README do curso](../../README.md) | [Aula 1 — O terminal sem medo](01-o-terminal-sem-medo.md) |
