# Aula 3 — Git: o que é

> **Módulo:** 00 - Git e Terminal · **Tempo estimado:** 55 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Explicar o que é **controle de versão** e que problema real ele resolve.
- Definir **repositório**, **working tree**, **staging area** e **commit** — e dizer em qual dos três
  lugares cada arquivo está em um dado momento.
- Criar um repositório do zero com `git init` e ler a saída de `git status`.
- Registrar mudanças com `git add` e `git commit`, consultar a história com `git log` e configurar
  `user.name` e `user.email` (sem os quais o commit é recusado).
- Explicar o que é um **repositório remoto** e qual é o papel do **GitHub**.
- Escrever um programa Dart que simula working tree, staging e commit.

## ✅ Pré-requisitos

- [Aula 1 — O terminal sem medo](01-o-terminal-sem-medo.md) e
  [Aula 2 — Arquivos e caminhos](02-arquivos-e-caminhos.md) concluídas.
- Git 2.46+ instalado (confirme com `git --version`); se não for reconhecido, volte para
  [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

---

## 📖 Conceito

### O problema que o Git resolve

Sem controle de versão, a pasta de um projeto vira isto:

```text
app.dart · app_final.dart · app_final_v2.dart · app_final_v2_AGORA_VAI.dart
```

Esse esquema falha em quatro pontos: ninguém sabe qual é o atual, ninguém sabe **o que mudou** de um
para o outro, ninguém sabe **por quê**, e não há como voltar de forma confiável.

**Controle de versão** (*version control*) é um sistema que guarda a **história completa** do
projeto: cada mudança, quem fez, quando e com qual explicação — e permite voltar a qualquer ponto
dessa história. O **Git** é o mais usado do mundo. Ele é **distribuído**: cada cópia do projeto
contém o histórico inteiro, funciona sem internet e não depende de servidor central para registrar
mudanças.

### Repositório

**Repositório** (ou *repo*) é o projeto **mais** sua história: a pasta de trabalho com uma subpasta
oculta chamada `.git` dentro dela, onde tudo fica guardado. Apagar `.git` apaga **toda** a história e
mantém os arquivos atuais; copiar a pasta do projeto inteira copia a história junto. **Não edite nada
dentro de `.git` à mão.**

### Os três lugares onde um arquivo pode estar

Este é o conceito central da aula:

| Lugar | Nome | O que é |
|---|---|---|
| 1 | **Working tree** (árvore de trabalho) | Os arquivos como estão **agora** no disco. É o que o editor mostra. |
| 2 | **Staging area** (área de preparação, ou *index*) | Uma sala de espera: o que você **selecionou** para entrar no próximo commit. |
| 3 | **Repositório** (histórico) | As fotografias já registradas — os **commits**. |

O fluxo é sempre o mesmo:

```text
working tree  --git add-->  staging area  --git commit-->  repositório
```

A staging area existe para que você possa **escolher** o que entra em cada commit: se mexeu em cinco
arquivos por dois motivos diferentes, pode fazer dois commits separados. Sem staging, todo commit
seria "tudo que estava mexido".

### Commit

**Commit** é uma fotografia imutável do projeto num instante, com autor, data e **mensagem**. Cada
commit tem um identificador único, o **hash** — 40 caracteres hexadecimais gerados a partir do
conteúdo, como `9f1c2d4a8b...`. Na prática se usam os 7 primeiros (`9f1c2d4`).

Commits são **encadeados** (cada um aponta para o anterior) e **imutáveis**: você não edita um
commit, cria outro — veja a [Aula 5](05-desfazendo-erros-e-segredos.md).

### Identidade: `user.name` e `user.email`

Todo commit registra quem o fez, e o Git recusa commitar sem essa informação. Configure **uma vez por
máquina**:

```powershell
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"
git config --global init.defaultBranch main
git config --global --list
```

`--global` grava no seu perfil e vale para **todos** os repositórios da máquina; sem ele, vale só
para o repositório atual. Já `init.defaultBranch main` faz todo repositório novo começar com a branch
chamada `main` (padrão moderno) em vez do antigo `master` — **branch** é o assunto da
[Aula 4](04-commits-branches-gitignore.md); por ora, entenda como "a linha do tempo principal".

### O ciclo diário, em cinco comandos

```powershell
git init                 # 1. cria o repositório (só na primeira vez)
git status               # 2. o que mudou?
git add <arquivo>        # 3. seleciono o que entra no próximo commit
git commit -m "mensagem" # 4. registro a fotografia
git log                  # 5. vejo a história
```

`git init` cria a pasta `.git` e deve ser rodado **dentro** da pasta do projeto. `git status` é o
comando que você mais vai usar. `git add` aceita um arquivo, vários, ou tudo (`git add .`, onde o `.`
é a pasta atual, como na Aula 2) — enquanto está aprendendo, prefira nomear os arquivos. Sem o `-m`,
`git commit` abre um editor de texto. E `git log` mostra a história, do mais recente ao mais antigo:

```powershell
git log --oneline              # uma linha por commit: hash curto + mensagem
git log --oneline --graph      # desenha o encadeamento (útil com branches)
git log --stat                 # quais arquivos mudaram e quanto
```

### Lendo o `git status`

Saída típica logo depois de criar um arquivo novo:

```text
On branch main
No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        bin/diagnostico_terminal.dart
```

Traduzindo: estamos na branch `main`, não existe nenhum commit, e há um arquivo **untracked** — o Git
o enxerga mas **nunca** foi instruído a acompanhá-lo. Depois do `git add`, ele passa para *Changes to
be committed*, ou seja, para a **staging area**. Se você editar o arquivo de novo **sem** dar
`git add`, ele aparece **nas duas listas ao mesmo tempo** — são três lugares diferentes.

| Estado | Significa | Como sair dele |
|---|---|---|
| **Untracked** | O Git nunca viu esse arquivo | `git add` |
| **Modified** | Rastreado e alterado, mas não preparado | `git add` |
| **Staged** | Preparado para o próximo commit | `git commit` |
| **Committed** | Já está na história | nada a fazer |

### Remoto e GitHub

Até aqui tudo é local. Um **repositório remoto** é uma cópia hospedada em outro lugar, e serve para
**backup**, **sincronização entre máquinas** e **colaboração**. **GitHub** é um serviço que hospeda
repositórios Git (existem outros: GitLab, Bitbucket). Não confunda: **Git** é o programa que roda na
sua máquina; **GitHub** é um site que guarda cópias — você pode usar Git a vida inteira sem GitHub.

```powershell
git remote add origin https://github.com/usuario/repositorio.git
git push -u origin main                              # envia a branch main e memoriza o destino
git pull                                             # traz o que mudou no remoto
git clone https://github.com/usuario/repositorio.git # baixa um repositório existente
```

`origin` é apenas o **apelido** padrão do remoto principal, não palavra reservada; `-u` (de
*upstream*) grava a ligação entre sua branch local e a do remoto.

> 🔐 Desde 2021 o GitHub **não aceita mais senha da conta** em operações Git. Você autentica com um
> *Personal Access Token* (um token gerado no site, usado no lugar da senha) ou com chave SSH.
> **Nunca** escreva esse token dentro de um arquivo do projeto — o porquê e o procedimento estão na
> [Aula 5](05-desfazendo-erros-e-segredos.md).

Publicar no GitHub é **opcional** no curso. O que **não** é opcional é commitar localmente: os
commits por marco são a sua rede de segurança quando um experimento der errado.

---

## 💡 Analogia

Pense em um documento colaborativo com histórico de versões — mas em que **você decide** quando
salvar uma versão e **escreve um bilhete** explicando o que fez.

- A **working tree** é o texto na tela, sendo digitado.
- A **staging area** é o trecho que você **selecionou** com o mouse: "estes parágrafos vão entrar".
- O **commit** é clicar em "salvar versão" e escrever o bilhete; o **remoto** é a cópia no servidor.

A analogia é fiel num ponto crucial: versões salvas **não somem** quando você segue digitando.

---

## 🧪 Exemplo mínimo

Rode dentro de `lab_modulo_00`:

```powershell
Set-Location C:\src\cursos\lab_modulo_00
git init
git add pubspec.yaml
git commit -m "Adiciona o pubspec do laboratório do módulo 00"
git log --oneline
```

O `git init` responde `Initialized empty Git repository in C:/src/cursos/lab_modulo_00/.git/`, e o
`git log --oneline` mostra uma linha como `a1b2c3d Adiciona o pubspec do laboratório do módulo 00`.
Esse `a1b2c3d` é o hash curto — o seu será diferente, pois depende de conteúdo, autor e horário.

---

## 📱 Aplicando no Flutter

- **Todo projeto Flutter nasce como repositório.** Ao rodar `flutter create` no
  [Módulo 05](../05-introducao-ao-flutter/02-estrutura-do-projeto.md), a ferramenta já cria um
  `.gitignore` adequado. Faça o primeiro commit **antes** da sua primeira alteração, para separar "o
  que o Flutter gerou" de "o que eu escrevi" — e, dali em diante, um commit por marco de estudo vira
  sua rede de segurança quando um experimento não compilar.
- **`git log` explica o passado.** Quando um teste que passava em
  [Módulo 12](../12-testes-e-debug/05-testes-unitarios.md) falhar, é por ele que você acha a causa.
- **O remoto vira distribuição.** Em
  [Módulo 16](../16-publicacao-e-proximos-passos/03-versionamento-e-releases.md), cada versão
  publicada corresponde a um ponto marcado no histórico. Sem Git, "qual código gerou o APK que está
  na loja?" é uma pergunta sem resposta.

---

## 💻 Código completo

Para fixar o modelo dos três lugares, vamos **construir** um mini controle de versão em Dart. Ele não
substitui o Git — existe para que working tree, staging e commit deixem de ser palavras e virem
estruturas de dados que você consegue ver.

> **Arquivo:** `lab_modulo_00/bin/mini_versionador.dart`
> **Como executar:** de dentro da pasta `lab_modulo_00`, rode `dart run bin/mini_versionador.dart`

```dart
import 'dart:io';

/// Uma fotografia imutável do projeto em um instante.
class Commit {
  Commit({required this.id, required this.mensagem, required this.autor,
      required this.quando, required this.arquivos});

  final String id;
  final String mensagem;
  final String autor;
  final DateTime quando;
  final Map<String, String> arquivos;
}

/// Repositório em memória com os três lugares do Git.
class MiniRepositorio {
  MiniRepositorio(this.autor);

  final String autor;

  /// 1. Working tree: os arquivos como estão agora no disco.
  final Map<String, String> workingTree = <String, String>{};

  /// 2. Staging area: o que foi selecionado para o próximo commit.
  final Map<String, String> staging = <String, String>{};

  /// 3. Histórico: as fotografias já registradas.
  final List<Commit> historico = <Commit>[];

  int _sequencia = 1;

  /// O conteúdo do projeto conforme o último commit.
  Map<String, String> get ultimoCommit =>
      historico.isEmpty ? <String, String>{} : historico.last.arquivos;

  void editar(String arquivo, String conteudo) {
    workingTree[arquivo] = conteudo;
    stdout.writeln('> editei $arquivo');
  }

  void adicionar(String arquivo) {
    final String? conteudo = workingTree[arquivo];
    if (conteudo == null) {
      stderr.writeln('erro: "$arquivo" não existe na working tree.');
      return;
    }
    staging[arquivo] = conteudo;
    stdout.writeln('> git add $arquivo');
  }

  void commitar(String mensagem) {
    if (staging.isEmpty) {
      stderr.writeln('nada para commitar: a staging area está vazia.');
      return;
    }
    historico.add(Commit(
      id: 'c${_sequencia.toString().padLeft(4, '0')}',
      mensagem: mensagem,
      autor: autor,
      quando: DateTime(2026, 9, 14, 9, _sequencia * 7),
      arquivos: <String, String>{...ultimoCommit, ...staging},
    ));
    _sequencia++;
    staging.clear();
    stdout.writeln('> git commit -m "$mensagem"');
  }

  void status() {
    final Map<String, String> ultimo = ultimoCommit;
    final List<String> preparados = <String>[];
    final List<String> modificados = <String>[];
    final List<String> naoRastreados = <String>[];

    for (final String nome in staging.keys) {
      if (ultimo[nome] != staging[nome]) {
        preparados.add(nome);
      }
    }
    for (final String nome in workingTree.keys) {
      final String? referencia = staging[nome] ?? ultimo[nome];
      if (referencia == null) {
        naoRastreados.add(nome);
      } else if (referencia != workingTree[nome]) {
        modificados.add(nome);
      }
    }

    stdout.writeln('--- status ---');
    imprimirGrupo('Preparados (vão no próximo commit)', preparados);
    imprimirGrupo('Modificados, ainda não preparados', modificados);
    imprimirGrupo('Não rastreados', naoRastreados);
    if (preparados.isEmpty && modificados.isEmpty && naoRastreados.isEmpty) {
      stdout.writeln('  nada a fazer: working tree limpa.');
    }
    stdout.writeln('');
  }

  void log() {
    stdout.writeln('--- log (mais recente primeiro) ---');
    for (final Commit commit in historico.reversed) {
      final String hora = '${commit.quando.hour.toString().padLeft(2, '0')}:'
          '${commit.quando.minute.toString().padLeft(2, '0')}';
      stdout.writeln('${commit.id}  $hora  ${commit.mensagem}');
      stdout.writeln('        autor: ${commit.autor} · '
          'arquivos: ${commit.arquivos.length}');
    }
  }
}

void imprimirGrupo(String titulo, List<String> nomes) {
  if (nomes.isEmpty) {
    return;
  }
  stdout.writeln('  $titulo:');
  for (final String nome in nomes) {
    stdout.writeln('    - $nome');
  }
}

void main() {
  final MiniRepositorio repo = MiniRepositorio('Estudante <voce@exemplo.com>');

  repo.editar('main.dart', 'void main() {}');
  repo.editar('README.md', '# Projeto');
  repo.status();

  repo.adicionar('main.dart');
  repo.status();

  repo.commitar('Cria o ponto de entrada do programa');
  repo.status();

  repo.editar('main.dart', 'void main() { print("Ola"); }');
  repo.adicionar('main.dart');
  repo.editar('main.dart', 'void main() { print("Ola, Git!"); }');
  repo.status(); // main.dart aparece preparado E modificado ao mesmo tempo

  repo.adicionar('main.dart');
  repo.adicionar('README.md');
  repo.commitar('Imprime uma saudacao e adiciona o README');
  repo.status();

  repo.log();
}
```

---

## 🔍 Explicando o código

- `class Commit { ... }` — uma **classe** é um molde que define quais dados um objeto guarda. Classes
  ganham o [Módulo 03 inteiro](../03-dart-intermediario/01-classes-e-objetos.md); por ora, leia como
  "um registro com campos nomeados".
- `required this.id` no construtor — `required` obriga quem cria o objeto a informar aquele valor, e
  `this.id` já atribui ao campo, sem escrever `id = id;`.
- `Map<String, String> get ultimoCommit => ...` — um **getter**: parece um campo quando lido
  (`repo.ultimoCommit`), mas é calculado na hora. `=>` é a forma curta de uma função de uma expressão.
  Se não há commit nenhum, ele devolve um mapa vazio, o que evita tratar o primeiro commit como caso
  especial no resto do código.
- `<String, String>{ ...ultimoCommit, ...staging }` — o operador `...` é o **spread**: despeja o
  conteúdo de outra coleção ali dentro. Como `staging` vem **depois**, suas chaves **sobrescrevem** as
  do commit anterior. Isso reproduz exatamente o Git: o novo commit é o anterior **mais** o que foi
  preparado.
- `final String? conteudo = workingTree[arquivo];` — buscar chave inexistente devolve `null`, então o
  tipo precisa do `?`. O `if (conteudo == null)` protege contra "adicionar arquivo que não existe",
  que no Git também é erro.
- `staging[nome] ?? ultimo[nome]` — o operador `??` devolve o da esquerda se não for nulo, senão o da
  direita. Se os dois forem nulos, o arquivo nunca foi visto: é **untracked**.
- `staging.clear()` depois do commit — a sala de espera esvazia. É por isso que, no Git, você precisa
  dar `git add` de novo a cada nova alteração. Já `historico.reversed` percorre do commit mais novo
  para o mais antigo, como o `git log`, e a data é **fixa** de propósito: com `DateTime.now()` a
  saída mudaria a cada execução. As mensagens de erro vão para `stderr`, como na Aula 1.
- O `main` no fim é o **roteiro**. Leia a saída acompanhando-o linha a linha. Preste atenção ao
  terceiro `status()`, em que `main.dart` aparece **duas vezes** — preparado com uma versão e
  modificado com outra.

---

## 🤖🍎 Android × iOS

O Git é o mesmo nas duas plataformas, mas **o que você versiona** de cada pasta muda:

| Item | 🤖 Android | 🍎 iOS |
|---|---|---|
| Pasta no projeto | `android/` | `ios/` |
| Arquivo de dependências que **vai** para o repositório | `android/app/build.gradle.kts` | `ios/Podfile` |
| Arquivo de trava de dependências | `android/gradle/wrapper/gradle-wrapper.properties` | `ios/Podfile.lock` |
| Pasta gerada que **não** vai para o repositório | `android/.gradle/`, `android/build/` | `ios/Pods/`, `ios/.symlinks/` |
| Segredo que **nunca** entra no repositório | `android/key.properties`, `*.jks` | `ios/Runner/GoogleService-Info.plist`, `*.mobileprovision` |

A regra vale para os dois: **versione o que descreve o projeto; ignore o que é gerado a partir dele.**
Quem a materializa é o `.gitignore`, tema da próxima aula; os detalhes de cada pasta nativa estão em
[Módulo 11](../11-recursos-nativos/07-pastas-android-e-ios.md).

---

## ⚠️ Erros comuns

**1. Commitar sem identidade configurada**

```text
Author identity unknown

*** Please tell me who you are.

Run
  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
```

Correção: rode os dois comandos sugeridos, com seus dados, e refaça o commit.

**2. `git init` na pasta errada**

```text
Initialized empty Git repository in C:/Users/Usuário/.git/
```

Se a saída mostra a pasta do seu usuário (ou qualquer pasta acima do projeto), você criou um
repositório no lugar errado. Correção: apague aquela pasta com
`Remove-Item -Recurse -Force C:\Users\Usuário\.git` e confira `Get-Location` antes de repetir.

**3. Achar que `git add` salvou**

`git add` **não** grava nada no histórico: só coloca na sala de espera. Sem `git commit`, não existe
ponto de retorno.

**4. `nothing to commit, working tree clean` quando você acha que mudou algo**

Ou você não salvou o arquivo no editor, ou ele está sendo ignorado pelo `.gitignore`. Investigue o
segundo caso com:

```powershell
git check-ignore -v caminho/do/arquivo
```

**5. Ficar preso no paginador ou no editor**

No `git log`, pressione **`q`**. Se rodar `git commit` **sem** `-m`, o Git abre um editor; se for o
Vim, digite `:q!` e Enter para cancelar. Para usar o VS Code no lugar:

```powershell
git config --global core.editor "code --wait"
```

**6. Commitar a pasta `build/` por engano**

O repositório incha centenas de megabytes. A prevenção é o `.gitignore` da próxima aula; a correção
está na [Aula 5](05-desfazendo-erros-e-segredos.md).

---

## 🛠️ Exercício guiado

**Passo 1 — Configure a identidade (uma vez por máquina) e inicialize o repositório**

```powershell
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"
git config --global init.defaultBranch main
git config --global --list
Set-Location C:\src\cursos\lab_modulo_00
Get-Location
git init
git status
```

Confira que a saída do `git init` cita `C:/src/cursos/lab_modulo_00/.git/`.

**Passo 2 — Primeiro commit, lendo o status entre os comandos**

```powershell
git add pubspec.yaml
git status
git commit -m "Inicia o laboratório do módulo 00"
```

Entre o `add` e o `commit`, o `pubspec.yaml` deve aparecer em *Changes to be committed*.

**Passo 3 — Segundo e terceiro commits**

Commite os dois programas; depois abra `bin/diagnostico_terminal.dart` no VS Code, acrescente uma
linha de comentário no topo, salve, e commite de novo:

```powershell
git add bin/diagnostico_terminal.dart bin/inspetor_de_caminhos.dart
git commit -m "Adiciona os programas de diagnóstico do terminal e de caminhos"
git status
git add bin/diagnostico_terminal.dart
git commit -m "Documenta o objetivo do diagnóstico de terminal"
```

**Passo 4 — Leia sua história**

```powershell
git log --oneline
git log -1 --stat
git status
```

Esperado: três linhas no `--oneline`, o detalhe do último commit no `--stat` e
`nothing to commit, working tree clean` no `status`.

**Passo 5 — Compare com o simulador**

```powershell
dart run bin/mini_versionador.dart
```

Acompanhe a saída junto com o roteiro do `main`. Depois responda para si: no terceiro `status()`, por
que `main.dart` aparece ao mesmo tempo como *preparado* e como *modificado*?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/00-git-e-terminal.md](../../exercicios/00-git-e-terminal.md)

Concentre-se em **Fixação** e **Implementação**: elas cobrem `init → status → add → commit → log`.

---

## 🏆 Desafio opcional

Estenda `bin/mini_versionador.dart` com dois recursos:

1. **`diff` simples.** Um método `diferenca()` que compare, para cada arquivo, o conteúdo da working
   tree com o do último commit e imprima as linhas que mudaram, marcando com `-` as removidas e `+`
   as adicionadas. Dica: use `conteudo.split('\n')`.
2. **`checkout` de commit.** Um método `restaurar(String idDoCommit)` que procure o commit pelo id e
   substitua a working tree pela fotografia dele; se o id não existir, escreva em `stderr` sem
   alterar nada. Prove que funciona: restaure o primeiro commit e chame `status()`.

---

## 📌 Resumo

- **Controle de versão** guarda a história completa do projeto: o quê, quem, quando e por quê.
- **Repositório** é o projeto **mais** a pasta oculta `.git`. Um arquivo vive em um de três lugares:
  **working tree** (disco), **staging area** (sala de espera) ou **repositório** (história). O fluxo
  é `git add` → `git commit`.
- Ciclo diário: `git init` (uma vez) → `git status` → `git add` → `git commit -m` → `git log`. Sem
  `user.name` e `user.email` configurados, o Git **recusa** commitar.
- Estados de arquivo: *untracked*, *modified*, *staged*, *committed*.
- **Remoto** é uma cópia hospedada fora da sua máquina; **GitHub** é um dos serviços que hospedam.
  Git funciona perfeitamente sem GitHub.

---

## ☑️ Checklist de domínio

- [ ] Digo o que a pasta `.git` guarda, e nomeio os três lugares e o comando que move um arquivo
      de um para o outro.
- [ ] Crio um repositório com `git init` e classifico cada arquivo do `git status` em untracked,
      modified ou staged.
- [ ] Faço um commit pelo `-m`, saio do paginador com `q` e explico a diferença entre Git e GitHub.
- [ ] Configuro `user.name` e `user.email` e confiro com `git config --global --list`.
- [ ] Rodo `bin/mini_versionador.dart` e aponto, na saída, onde está cada um dos três lugares.

---

## 📚 Referências oficiais

- [Git — documentação oficial](https://git-scm.com/doc)
- [Pro Git (livro oficial, em português)](https://git-scm.com/book/pt-br/v2)
- [Git — `git status`](https://git-scm.com/docs/git-status)
- [Git — `git commit`](https://git-scm.com/docs/git-commit)
- [Git — `git log`](https://git-scm.com/docs/git-log)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Arquivos e caminhos](02-arquivos-e-caminhos.md) | [README](README.md) | [Commits, branches e .gitignore](04-commits-branches-gitignore.md) |
