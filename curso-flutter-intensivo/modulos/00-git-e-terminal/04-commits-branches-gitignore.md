# Aula 4 — Commits, branches e .gitignore

> **Módulo:** 00 - Git e Terminal · **Tempo estimado:** 50 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Escrever mensagens de commit que expliquem **o quê** e **por quê**, seguindo um padrão.
- Explicar o que é uma **branch** e por que ela custa quase nada no Git.
- Criar, trocar, listar e apagar branches com `git switch` e `git branch`, fazer um **merge**
  simples e reconhecer um conflito.
- Escrever um `.gitignore` completo de projeto Flutter, explicar cada grupo de regras e definir uma
  rotina de **commits por marco** para os 30 dias do curso.
- Escrever um programa Dart que valida mensagens de commit e devolve código de saída.

## ✅ Pré-requisitos

- [Aula 3 — Git: o que é](03-git-o-que-e.md) concluída: você já cria repositório, faz `add`, `commit`
  e lê o `log`.
- Identidade configurada (`user.name` e `user.email`) e repositório iniciado em
  `C:\src\cursos\lab_modulo_00`.

---

## 📖 Conceito

### Mensagens de commit que servem para alguma coisa

Uma mensagem de commit é escrita uma vez e lida dezenas: ela responde à pergunta que você fará a si
mesmo em três semanas — *"o que eu mudei aqui, e por quê?"*. Mensagens ruins e o motivo:

| Mensagem | Problema |
|---|---|
| `ajustes` | Não diz o quê nem por quê |
| `Corrigindo o bug.` | Gerúndio, ponto final, e "o bug" não identifica nada |
| `asdasd` | Ruído puro |

O padrão adotado no curso é o **Conventional Commits**, resumido em uma linha:

```text
<tipo>: <descrição no imperativo, minúscula, sem ponto final>
```

Os tipos que você vai usar:

| Tipo | Quando usar |
|---|---|
| `feat` | Uma funcionalidade nova para quem usa o app |
| `fix` | Correção de um comportamento errado |
| `docs` | Só documentação (README, comentários) |
| `test` | Só testes |
| `refactor` | Reorganização sem mudar comportamento |
| `chore` | Tarefa de manutenção (dependências, configuração) |
| `style` | Formatação e espaços (`dart format`), sem mudar lógica |

Três regras práticas:

1. **Primeira linha com até 72 caracteres** (o que cabe em `git log --oneline`) e **sem ponto final**.
2. **Verbo no imperativo**: `adiciona`, `corrige`, `remove` — não `adicionado` nem `adicionando`. O
   truque: a mensagem completa a frase *"Este commit ___"*.
3. **Um commit, um assunto.** Se a mensagem precisa de um "e", provavelmente são dois commits.

Exemplos bons:

```text
feat: adiciona tela de cadastro de matéria
fix: corrige o cálculo de minutos quando a sessão vira o dia
chore: atualiza flutter_lints para 6.0.0
```

Quando precisar explicar o **porquê**, acrescente um corpo: rode `git commit` sem `-m` (com o editor
configurado) ou passe dois `-m` — o segundo vira o corpo, separado por uma linha em branco.

### Branch: uma linha do tempo paralela

**Branch** (*ramo*) é um **ponteiro** para um commit. Criar uma branch não copia arquivos: o Git só
grava um nome apontando para o commit atual. Por isso criar branch é instantâneo e barato.

```text
main      c1 ─── c2 ─── c3        <- ponteiro "main" está em c3
                    \
experimento          c4 ─── c5    <- ponteiro "experimento" está em c5
```

Você usa branch para **experimentar sem risco**: se der errado, apague o ramo e a `main` continua
intacta. O `HEAD` é um ponteiro especial que indica **em qual branch você está agora**.

Os comandos:

```powershell
git branch                      # lista as branches; a atual vem com *
git switch -c experimento       # cria a branch e já troca para ela
git switch main                 # volta para a main
git branch -d experimento       # apaga a branch (só se já foi mesclada; -D força)
```

> `git switch` existe desde o Git 2.23 e é o recomendado hoje. O antigo `git checkout -b experimento`
> equivale a `git switch -c experimento`, mas o `checkout` faz muitas coisas diferentes ao mesmo
> tempo. Com Git 2.46 você tem os dois: prefira `switch`.

### Merge: trazer o ramo de volta

**Merge** (*mesclagem*) é juntar o trabalho de uma branch em outra. O fluxo é sempre: **vá para a
branch de destino** e mande trazer a outra.

```powershell
git switch main
git merge experimento
```

Dois resultados possíveis: **fast-forward** (se a `main` não andou desde que você criou o ramo, o Git
só empurra o ponteiro para frente, sem commit novo) e **merge commit** (se as duas andaram, nasce um
commit especial com **dois pais**). E se as duas mudaram **as mesmas linhas do mesmo arquivo**, o Git
não adivinha e para com um **conflito**:

```text
Auto-merging bin/mini_versionador.dart
CONFLICT (content): Merge conflict in bin/mini_versionador.dart
Automatic merge failed; fix conflicts and then commit the result.
```

O arquivo fica marcado assim:

```text
<<<<<<< HEAD
final String titulo = 'Painel de estudos';
=======
final String titulo = 'Meus estudos';
>>>>>>> experimento
```

Resolver é manual: **abra o arquivo**, apague os marcadores `<<<<<<<`, `=======` e `>>>>>>>` deixando
só o texto que deve ficar, e então `git add <arquivo>` seguido de `git commit`. Se quiser desistir no
meio, `git merge --abort` devolve tudo ao estado anterior.

### `.gitignore`: o que **não** entra no repositório

O `.gitignore` é um arquivo de texto, na raiz do projeto, com um padrão por linha. Arquivos que
combinam com esses padrões ficam invisíveis para o `git status` e nunca são adicionados por engano.

Três categorias devem sempre estar lá:

1. **Gerado** — recriável por um comando (`build/`, `.dart_tool/`); versionar incha o repositório em
   centenas de megabytes sem ganho nenhum.
2. **Pessoal** — configuração da sua máquina (`local.properties`, `.idea/`), que gera conflito a cada
   `merge` e não serve para mais ninguém.
3. **Secreto** — chaves, senhas, tokens. O mais grave: uma vez commitado, o segredo fica na história
   **mesmo depois de apagado** ([Aula 5](05-desfazendo-erros-e-segredos.md)).

Sintaxe dos padrões:

| Padrão | Significa |
|---|---|
| `build/` | a pasta `build` em qualquer nível |
| `/build/` | a pasta `build` **só na raiz** do repositório |
| `*.jks` | qualquer arquivo com a extensão `.jks` |
| `# comentário` | linha ignorada pelo Git |

O `.gitignore` abaixo é o gerado pelo `flutter create` **mais** as linhas de segurança e de pastas
nativas que este curso exige. Use-o em todo projeto Flutter do curso:

```text
# Editor e sistema operacional
*.iml
.idea/
.vscode/
.DS_Store
*.log
*.swp
migrate_working_dir/

# Flutter / Dart / Pub — tudo gerado
**/doc/api/
.dart_tool/
.flutter-plugins-dependencies
.pub-cache/
/build/
coverage/
app.*.symbols
app.*.map.json

# Android — gerado e específico da máquina
/android/.gradle/
/android/local.properties
/android/app/debug
/android/app/profile
/android/app/release

# iOS — gerado e específico da máquina
/ios/Pods/
/ios/.symlinks/
/ios/Flutter/ephemeral/
/ios/Flutter/.last_build_id

# SEGREDOS — nunca versionar
/android/key.properties
/android/app/google-services.json
/ios/Runner/GoogleService-Info.plist
*.jks
*.keystore
*.p12
*.cer
*.mobileprovision
.env
.env.*
```

> ⚠️ O `.gitignore` só protege arquivos que **ainda não foram rastreados**. Se um arquivo já entrou
> em um commit, acrescentar o padrão não o remove da história. O que fazer nesse caso está na
> [Aula 5](05-desfazendo-erros-e-segredos.md).

Para descobrir por que um arquivo está sendo ignorado use `git check-ignore -v <arquivo>`; para ver
o que está sendo escondido, `git status --ignored`.

### Commits por marco do curso

Adote nos 30 dias: **um commit ao fim de cada aula** e **um por marco** (exercícios entregues,
projeto rodando, build gerado). Seu `git log` vira o registro do progresso.

```text
chore: conclui a aula 01 do módulo 00 sobre terminal
feat: resolve os exercícios obrigatórios do módulo 02
chore: gera o primeiro APK de debug do projeto final
```

---

## 💡 Analogia

Uma **branch** é uma folha de papel vegetal colocada sobre o desenho original: você rabisca à
vontade e o desenho de baixo não muda. Se a ideia prestou, você **decalca** (merge) para o original;
se não prestou, joga o vegetal fora e nada se perdeu. O **conflito** aparece quando duas folhas
riscaram **exatamente a mesma linha**: o Git não tem como escolher qual é a certa, então para e te
entrega o arquivo com as duas versões lado a lado.

---

## 🧪 Exemplo mínimo

Dentro de `C:\src\cursos\lab_modulo_00`:

```powershell
git switch -c experimento
"linha de teste" | Out-File -Encoding utf8 teste.txt
git add teste.txt
git commit -m "chore: adiciona arquivo de teste do experimento"
git switch main
git merge experimento
git log --oneline --graph
git branch -d experimento
```

Depois do `git switch main`, `teste.txt` **desaparece** da pasta (só existe na outra branch); depois
do `git merge`, reaparece. É o ponteiro da branch mudando o que está no disco.

---

## 📱 Aplicando no Flutter

- **`flutter create` já escreve um `.gitignore`.** Ao criar seu primeiro projeto em
  [Módulo 05](../05-introducao-ao-flutter/02-estrutura-do-projeto.md), confira que `build/` e
  `.dart_tool/` estão lá — com `build/` versionado, o repositório passa de 500 MB.
- **Branch é como se experimenta layout.** Em
  [Módulo 06](../06-widgets-e-layouts/04-row-column-expanded.md) você vai testar três arranjos de
  tela: uma branch por tentativa permite comparar e descartar sem medo.
- **`.gitignore` é o que protege sua chave de assinatura.** Em
  [Módulo 14 — Keystore](../14-build-android/06-keystore.md) você gera um arquivo `.jks` e um
  `key.properties` com senhas. Se eles vazarem, outra pessoa pode publicar um app se passando pelo
  seu. As regras `*.jks` e `/android/key.properties` acima existem exatamente para isso.
- **Mensagens de commit viram o changelog da release** em
  [Módulo 16](../16-publicacao-e-proximos-passos/03-versionamento-e-releases.md).

---

## 💻 Código completo

Um validador de mensagens de commit: ele aplica as regras desta aula, imprime erros e avisos e
encerra com código de saída diferente conforme o resultado.

> **Arquivo:** `lab_modulo_00/bin/validador_de_commit.dart`
> **Como executar:** de dentro da pasta `lab_modulo_00`, rode `dart run bin/validador_de_commit.dart`
> (sem argumentos ele testa uma bateria de exemplos; com argumentos, valida a frase que você digitar)

```dart
import 'dart:io';

/// Tipos aceitos no começo da mensagem, no estilo "tipo: descrição".
const Set<String> tiposValidos = <String>{
  'feat', 'fix', 'docs', 'test', 'refactor', 'chore', 'style',
};

/// Palavras que não explicam nada.
const Set<String> palavrasVagas = <String>{
  'ajustes', 'ajuste', 'mudancas', 'update', 'teste', 'wip', 'coisas', 'varias',
};

/// Terminações de gerúndio e particípio em português.
const List<String> terminacoesProibidas = <String>['ando', 'endo', 'indo', 'ado', 'ido'];

class Problema {
  const Problema(this.gravidade, this.texto);
  final String gravidade; // 'ERRO' ou 'AVISO'
  final String texto;
}

List<Problema> validar(String mensagem) {
  final List<Problema> problemas = <Problema>[];
  final String primeiraLinha = mensagem.split('\n').first.trim();

  if (primeiraLinha.isEmpty) {
    return <Problema>[const Problema('ERRO', 'A mensagem está vazia.')];
  }
  if (primeiraLinha.length > 72) {
    problemas.add(Problema('ERRO',
        'A primeira linha tem ${primeiraLinha.length} caracteres (máximo 72).'));
  }
  if (primeiraLinha.endsWith('.')) {
    problemas.add(const Problema('AVISO', 'Não termine a primeira linha com ponto.'));
  }

  String descricao = primeiraLinha;
  final int separador = primeiraLinha.indexOf(': ');
  if (separador > 0) {
    final String tipo = primeiraLinha.substring(0, separador).toLowerCase();
    if (!tiposValidos.contains(tipo)) {
      problemas.add(Problema(
          'AVISO', 'Tipo "$tipo" fora da lista: ${tiposValidos.join(', ')}.'));
    }
    descricao = primeiraLinha.substring(separador + 2).trim();
  } else {
    problemas.add(const Problema('AVISO', 'Sem prefixo de tipo. Use "feat: ...", "fix: ...".'));
  }

  if (descricao.isEmpty) {
    problemas.add(const Problema('ERRO', 'Depois do tipo não há descrição alguma.'));
    return problemas;
  }

  final List<String> palavras = descricao.split(' ');
  final String verbo = palavras.first.toLowerCase();

  if (palavrasVagas.contains(verbo)) {
    problemas.add(Problema('ERRO', 'A descrição começa com a palavra vaga "$verbo".'));
  }
  for (final String terminacao in terminacoesProibidas) {
    if (verbo.length > 4 && verbo.endsWith(terminacao)) {
      problemas.add(Problema('AVISO',
          'O verbo "$verbo" não está no imperativo. Prefira "adiciona" ou "corrige".'));
      break;
    }
  }
  if (palavras.length < 3) {
    problemas.add(const Problema('AVISO', 'Descrição com menos de três palavras: explique o quê.'));
  }

  return problemas;
}

void main(List<String> argumentos) {
  final List<String> mensagens = argumentos.isNotEmpty
      ? <String>[argumentos.join(' ')]
      : const <String>[
          'feat: adiciona tela de cadastro de matéria',
          'ajustes',
          'Corrigindo o bug do cronômetro.',
          'fix: corrige o cálculo de minutos acumulados por matéria quando a sessão passa da meia-noite',
          'docs: explica',
        ];

  int comErro = 0;
  for (final String mensagem in mensagens) {
    stdout.writeln('mensagem: "$mensagem"');
    final List<Problema> problemas = validar(mensagem);
    if (problemas.isEmpty) {
      stdout.writeln('  OK: mensagem aprovada.');
    } else {
      for (final Problema problema in problemas) {
        final IOSink saida = problema.gravidade == 'ERRO' ? stderr : stdout;
        saida.writeln('  ${problema.gravidade}: ${problema.texto}');
      }
      if (problemas.any((Problema p) => p.gravidade == 'ERRO')) {
        comErro++;
      }
    }
    stdout.writeln('');
  }

  stdout.writeln('Mensagens com erro: $comErro de ${mensagens.length}.');
  exitCode = comErro == 0 ? 0 : 1;
}
```

---

## 🔍 Explicando o código

- `const Set<String> tiposValidos = <String>{...}` — um **Set** (*conjunto*) é uma coleção sem
  repetição e com busca rápida: `contains` nele é bem mais eficiente do que em uma `List` longa
  ([Módulo 02](../02-dart-basico/09-sets-e-maps.md)).
- `const` (e não `final`) porque as três coleções são conhecidas **em tempo de compilação**: o Dart
  as cria uma única vez. Já `class Problema` faz o validador devolver objetos com **gravidade** e
  **texto**, em vez de textos soltos que precisariam ser reinterpretados depois.
- `mensagem.split('\n').first.trim()` pega só a **primeira linha** (a mensagem pode ter corpo) e
  remove espaços das pontas; na mensagem vazia há uma **saída antecipada**. E
  `primeiraLinha.indexOf(': ')` devolve a posição do separador ou `-1`: o teste `> 0` cobre de uma
  vez a ausência e a mensagem começando com `: `.
- `verbo.length > 4 && verbo.endsWith(terminacao)` — exigir mais de quatro letras evita acusar
  palavras curtas terminadas por acaso em `ado` ou `ido`. Nenhuma heurística de linguagem natural é
  perfeita: por isso esse caso é **AVISO**, não **ERRO**, e o `break` impede avisos repetidos.
- `final IOSink saida = ... ? stderr : stdout;` — `IOSink` é o tipo comum de `stdout` e `stderr`, o
  que permite guardar um dos dois em uma variável. Erros vão para o canal de erro, como na Aula 1.
- `exitCode = comErro == 0 ? 0 : 1;` — é assim que uma verificação automática reprova um commit. O
  Git chama isso de *hook*: rodar um programa e olhar o código de saída.

---

## 🤖🍎 Android × iOS

O `.gitignore` é o mesmo arquivo para as duas plataformas, mas cada uma contribui com o seu grupo de
linhas — e por motivos diferentes:

| Grupo | 🤖 Android | 🍎 iOS |
|---|---|---|
| Gerado pelo build | `/android/.gradle/`, `/android/app/debug` | `/ios/Pods/`, `/ios/Flutter/ephemeral/` |
| Específico da sua máquina | `/android/local.properties` (caminho do SDK) | `/ios/.symlinks/` |
| Segredo de assinatura | `*.jks`, `*.keystore`, `/android/key.properties` | `*.mobileprovision`, `*.p12`, `*.cer` |

🤖 O `local.properties` guarda o caminho do Android SDK **na sua máquina**; versioná-lo quebra o build
de outra pessoa. 🍎 A pasta `Pods/` é baixada pelo CocoaPods a partir do `Podfile` — versione o
`Podfile` e o `Podfile.lock`, nunca as dependências baixadas.

> 🍎 **SÓ NO MAC.** Você não gera `*.mobileprovision` nem `*.p12` no Windows: eles vêm da conta de
> desenvolvedor da Apple e do Xcode. Deixe as regras no `.gitignore` desde já — o custo é zero. Veja
> [15-build-ios/07-certificados-e-provisioning.md](../15-build-ios/07-certificados-e-provisioning.md).

---

## ⚠️ Erros comuns

**1. `.gitignore` criado depois do commit, ou segredo commitado "só por enquanto"**

O padrão só vale para arquivos **ainda não rastreados**: se `build/`, `.env` ou `key.properties` já
estão na história, acrescentar a linha não resolve, e o segredo deve ser tratado como vazado. O
procedimento está na [Aula 5](05-desfazendo-erros-e-segredos.md).

**2. Trocar de branch com trabalho não commitado**

```text
error: Your local changes to the following files would be overwritten by checkout
Please commit your changes or stash them before you switch branches.
```

O Git está protegendo seu trabalho: ou commite, ou guarde com `git stash` (Aula 5).

**3. Fazer merge estando na branch errada**

`git merge experimento` traz `experimento` **para dentro da branch atual**. Antes de todo merge,
confirme com `git branch` que o `*` está no destino.

**4. Apagar uma branch não mesclada**

```text
error: The branch 'experimento' is not fully merged.
If you are sure you want to delete it, run 'git branch -D experimento'.
```

Isso é um aviso, não um bug: o `-d` minúsculo recusa apagar trabalho que não foi para lugar nenhum.
Só use `-D` se você realmente quer descartar aqueles commits.

**5. Deixar os marcadores de conflito no arquivo**

Se você commitar sem apagar `<<<<<<<`, `=======` e `>>>>>>>`, o código não compila
(`Error: Expected a declaration, but got '<<'.`). Sempre rode `dart analyze` — ou `flutter analyze`,
em projeto Flutter — depois de resolver um conflito.

---

## 🛠️ Exercício guiado

**Passo 1 — Crie o `.gitignore` do laboratório**

No VS Code, crie o arquivo `.gitignore` na raiz de `C:\src\cursos\lab_modulo_00` com o conteúdo da
seção "`.gitignore`" desta aula, salve em UTF-8 e então:

```powershell
Set-Location C:\src\cursos\lab_modulo_00
git add .gitignore
git commit -m "chore: adiciona gitignore de projeto flutter"
```

**Passo 2 — Prove que o `.gitignore` funciona**

```powershell
New-Item -ItemType Directory -Force build
"lixo gerado" | Out-File -Encoding utf8 build\saida.txt
"senha=SUA_SENHA_AQUI" | Out-File -Encoding utf8 android_key.properties
git status; git check-ignore -v build/saida.txt
```

O `git status` **não** deve listar `build/saida.txt`, e o `check-ignore` mostra qual linha o pegou.
Repare que `android_key.properties` **aparece**: o padrão do curso é `/android/key.properties`, com
caminho exato — nomes parecidos não são cobertos.

**Passo 3 — Crie uma branch, trabalhe nela e veja o disco mudar**

```powershell
git switch -c aula-04
"# Anotações da aula 4" | Out-File -Encoding utf8 anotacoes-aula-04.md
git add anotacoes-aula-04.md
git commit -m "docs: registra as anotações da aula 04"
git switch main
Get-ChildItem anotacoes-aula-04.md
git switch aula-04
Get-ChildItem anotacoes-aula-04.md
```

Na `main` o arquivo não existe; na `aula-04` ele volta. É o ponteiro em ação.

**Passo 4 — Faça o merge e apague a branch**

```powershell
git switch main
git merge aula-04
git log --oneline --graph
git branch -d aula-04
git branch
```

**Passo 5 — Rode o validador de mensagens**

```powershell
dart run bin/validador_de_commit.dart
$LASTEXITCODE
dart run bin/validador_de_commit.dart "feat: adiciona validador de mensagens de commit"
$LASTEXITCODE
```

A primeira execução deve encerrar com `1` (a bateria de exemplos tem mensagens ruins de propósito) e
a segunda com `0`. Para terminar, limpe o que você criou:

```powershell
Get-ChildItem build
Remove-Item -Recurse -Force build
Remove-Item android_key.properties
```

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/00-git-e-terminal.md](../../exercicios/00-git-e-terminal.md)

Priorize as seções **Aplicação** e **Correção de bugs**: elas usam branches, merge e `.gitignore`.

---

## 🏆 Desafio opcional

Estenda `bin/validador_de_commit.dart` para virar um **verificador de projeto**:

1. Leia o `.gitignore` da pasta atual com `File('.gitignore').readAsLinesSync()` e descarte
   comentários (linhas iniciadas por `#`) e linhas vazias.
2. Verifique se **todos** estes padrões estão presentes: `/build/`, `.dart_tool/`, `*.jks`,
   `*.keystore`, `*.p12`, `*.cer`, `*.mobileprovision`, `/android/key.properties`,
   `/ios/Runner/GoogleService-Info.plist`, `.env`.
3. Liste os que faltam e encerre com código `2` se faltar algum, `0` se estiver completo, e `3` se o
   próprio `.gitignore` não existir. Dica: `File(...).existsSync()` evita a exceção de arquivo
   inexistente, tema de [Módulo 04](../04-dart-avancado/01-exceptions.md).

---

## 📌 Resumo

- Mensagem boa segue `tipo: descrição no imperativo`, com até 72 caracteres, sem ponto final e com
  **um assunto por commit**. Tipos: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `style`.
- **Branch** é um ponteiro para um commit, e criar custa quase nada: `git switch -c <nome>` cria e
  troca, `git switch main` volta, `git branch -d <nome>` apaga.
- **Merge** traz a outra branch **para dentro da atual**: vá primeiro para o destino. Pode terminar
  em *fast-forward*, em *merge commit* ou em **conflito** — este resolvido à mão (apague os
  marcadores, `git add`, `git commit`); `git merge --abort` cancela.
- O **`.gitignore`** cobre gerado, pessoal e **secreto**, e só vale para arquivos ainda **não
  rastreados**.
- Use `git check-ignore -v <arquivo>` para descobrir qual regra pegou um arquivo, e adote **commits
  por marco** durante os 30 dias: seu `git log` vira o diário do curso.

---

## ☑️ Checklist de domínio

- [ ] Escrevo uma mensagem no padrão `tipo: descrição` sem consultar a tabela, e explico por que
      gerúndio e ponto final são desaconselhados na primeira linha.
- [ ] Digo o que é uma branch em uma frase que inclua a palavra "ponteiro".
- [ ] Crio, listo, troco e apago branches, e faço merge estando na branch de destino certa.
- [ ] Reconheço os marcadores de conflito e sei resolvê-los, e escrevo do zero um `.gitignore` de
      Flutter com os grupos gerado, pessoal e secreto.
- [ ] Explico a diferença entre `build/` e `/build/`, e uso `git check-ignore -v` para descobrir por
      que um arquivo sumiu do `git status`.
- [ ] Rodo `bin/validador_de_commit.dart` e interpreto erros, avisos e código de saída.

---

## 📚 Referências oficiais

- [Git — `git switch`](https://git-scm.com/docs/git-switch)
- [Git — `gitignore`](https://git-scm.com/docs/gitignore)
- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/pt-br/v1.0.0/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Git: o que é](03-git-o-que-e.md) | [README](README.md) | [Desfazendo erros e segredos](05-desfazendo-erros-e-segredos.md) |
