# Aula 5 — Desfazendo erros e protegendo segredos

> **Módulo:** 00 — Git e terminal · **Tempo estimado:** 50 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Escolher como desfazer uma operação olhando onde a mudança está.
- Usar `restore`, `reset --soft`, `revert`, `stash` e `reflog`.
- Recuperar um commit local sem descartar arquivos de trabalho.
- Explicar por que apagar uma senha do arquivo não resolve um vazamento.

## ✅ Pré-requisitos

Conclua [Commits, branches e .gitignore](04-commits-branches-gitignore.md).
Você precisa reconhecer working tree (arquivos no disco), staging/index (preparação do próximo
commit) e histórico (commits). Faça a prática em um **repositório de laboratório novo**, sem remoto
e sem dados pessoais. Os comandos abaixo modificam esse laboratório.

## 📖 Conceito

### Primeiro descubra o que aconteceu

Antes de desfazer, rode:

```powershell
git status
git diff
git diff --staged
git log --oneline -5
```

`diff` compara os arquivos com o staging; `diff --staged` compara o staging com o último commit.
`HEAD` identifica o commit atual; `HEAD~1` significa seu primeiro ancestral, normalmente o commit
anterior. Ele não existe quando o repositório tem apenas o primeiro commit.

### Escolha pelo resultado desejado

| Situação | Comando | Resultado |
|---|---|---|
| Preparei o arquivo errado com `add` | `git restore --staged -- notas.txt` | Retira do staging, mantendo a edição no disco |
| Quero descartar a edição local desse arquivo | `git restore -- notas.txt` | Copia a versão do staging para o disco; a edição local pode ser perdida |
| Quero refazer o último commit local | `git reset --soft HEAD~1` | Recua a branch, preservando disco e staging |
| Quero desfazer um commit compartilhado | `git revert HASH` | Cria outro commit com a alteração inversa |
| Preciso guardar um trabalho pela metade | `git stash push -u -m "rascunho"` | Guarda alterações rastreadas e arquivos novos não ignorados |
| Não encontro um commit que existia aqui | `git reflog` | Mostra movimentos locais das referências para procurar o hash |

O `restore` sem opções usa o **staging**, que pode ser diferente do último commit.
Para consultar a semântica e outras fontes possíveis, veja a [documentação de restore](https://git-scm.com/docs/git-restore).

### Os modos de reset

`--soft` preserva staging e arquivos. `--mixed` preserva os arquivos, mas redefine o staging
conforme o commit escolhido. `--hard` também sobrescreve arquivos e pode destruir trabalho;
não é necessário para esta prática. A [documentação de reset](https://git-scm.com/docs/git-reset)
detalha os três modos. Antes de recuar uma branch local, crie um ponto de referência:

```powershell
git branch backup-antes-do-reset
git reset --soft HEAD~1
git diff --staged
```

Use isso para refazer um commit **ainda não compartilhado**. Ao corrigir histórico compartilhado,
prefira `revert`: todos continuam vendo a mudança original e sua correção. Ele pode causar
conflitos; `git revert --abort` cancela uma reversão em conflito.
Consulte a [documentação de revert](https://git-scm.com/docs/git-revert).

### Stash é uma pausa local

```powershell
git stash push -u -m "pausa no resumo"
git stash list
git stash show -p 'stash@{0}'
git stash apply 'stash@{0}'
git status
```

As aspas protegem `stash@{0}` da interpretação do PowerShell. `apply` mantém a entrada no stash;
depois de conferir os arquivos, `git stash drop 'stash@{0}'` remove essa cópia. `pop` combina
aplicação e remoção quando a aplicação tem sucesso. Se houver conflito, resolva os arquivos
antes de remover a entrada. `-u` inclui arquivos novos, mas **não os ignorados**. Stash não é
backup remoto. Veja a [documentação de stash](https://git-scm.com/docs/git-stash).

### Reflog ajuda a encontrar; uma branch ajuda a preservar

```powershell
git reflog -8
```

Localize o hash pela mensagem e confirme com `git show HASH`. Depois substitua `HASH` pelo valor
encontrado e execute `git branch recuperado HASH`. Isso cria uma referência sem trocar de branch
nem sobrescrever o diretório. O reflog é local, suas entradas podem expirar e ele não registra
cada edição feita no editor. Não promete recuperar um texto nunca salvo em commit ou stash.
Veja a [documentação de reflog](https://git-scm.com/docs/git-reflog).

### Segredos: prevenir e responder

Use apenas valores fictícios nesta aula. Arquivos como `.env`, `key.properties`, `*.jks`,
`*.keystore` e `*.p12` não devem entrar no repositório do curso. O `.gitignore` não interrompe
o rastreamento de um arquivo já commitado. Nesse caso, `git rm --cached -- .env` prepara a remoção
do índice, preservando a cópia local; um novo commit registra essa remoção. Isso **não limpa os
commits anteriores**. Veja a [documentação de gitignore](https://git-scm.com/docs/gitignore).

Se uma credencial real foi publicada, a primeira ação é revogá-la ou trocá-la no serviço emissor.
Depois remova seu uso no projeto e coordene a limpeza do histórico e das cópias com os responsáveis.
Apagar o arquivo, criar um revert ou tornar o repositório privado não invalida uma credencial.
A limpeza pode exigir reescrita do histórico e não apaga automaticamente clones e forks.
Siga o [procedimento do GitHub para dados sensíveis](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).

## 💡 Analogia

O staging é uma bandeja com documentos para arquivar. Retirar um papel da bandeja não apaga o
original da mesa. Um commit é um registro no arquivo; `revert` acrescenta uma retificação.
A analogia termina aí: Git guarda versões de conteúdo, não fotografias da tela.

## 🧪 Exemplo mínimo

Em um laboratório que já tenha um commit com `notas.txt`, edite o arquivo e execute:

```powershell
git add notas.txt
git restore --staged -- notas.txt
git diff -- notas.txt
```

A edição continua aparecendo no `diff`. Você desfez a preparação, sem desfazer o texto.

## 📱 Aplicando no Flutter

Se uma mudança no tema quebrou o contraste depois de compartilhada, um `revert` permite registrar
a correção. Se você só preparou um arquivo de configuração errado, retire-o do staging.
As mesmas operações servem para Dart, Flutter e documentação.

## 💻 Código completo

Este programa é uma consulta didática: **imprime orientações, não executa Git**. No projeto Dart
do módulo, crie `bin/guia_recuperacao.dart`:

```dart
void main(List<String> args) {
  if (args.length != 1) {
    print('Uso: dart run bin/guia_recuperacao.dart <situacao>');
    print('Situacoes: staging, local, publicado, pausa, perdido, segredo');
    return;
  }

  switch (args[0]) {
    case 'staging':
      print('Retire do staging: git restore --staged -- ARQUIVO');
    case 'local':
      print('Confira status e diff antes de descartar qualquer edicao.');
    case 'publicado':
      print('Crie uma reversao: git revert HASH');
    case 'pausa':
      print('Guarde o rascunho: git stash push -u -m "pausa"');
    case 'perdido':
      print('Procure em git reflog; confira o hash com git show.');
    case 'segredo':
      print('Revogue ou troque a credencial no servico emissor primeiro.');
    default:
      print('Situacao desconhecida. Consulte a lista de opcoes.');
  }
}
```

Execute `dart run bin/guia_recuperacao.dart staging`. Saída:

```text
Retire do staging: git restore --staged -- ARQUIVO
```

## 🔍 Explicando o código

`args` contém os argumentos passados depois do caminho do programa. A verificação de tamanho
impede acessar uma posição inexistente. `return` encerra a função naquele ponto. `switch`
seleciona a mensagem pelo texto informado; no Dart moderno, cada caso não vazio termina
implicitamente, sem executar o caso seguinte. `default` cobre entradas não reconhecidas.
Você aprofundará essas estruturas nos módulos 01 e 02.

## 🤖🍎 Android × iOS

Git funciona da mesma forma para o código das duas plataformas. Os arquivos de assinatura são
diferentes: Android usa keystore; iOS pode envolver certificados e perfis de provisionamento.
Não use arquivos reais de assinatura para aprender a remover arquivos do Git.

## ⚠️ Erros comuns

| Sintoma | O que verificar |
|---|---|
| `not a git repository` | Confira `Get-Location`; entre na raiz do laboratório |
| `pathspec ... did not match` | Confira o nome e se o arquivo está rastreado |
| `HEAD~1` não existe | É preciso haver ao menos dois commits nessa sequência |
| O texto sumiu após `restore` | `restore` sem `--staged` altera o disco; veja o diff antes |
| Stash não trouxe um arquivo novo | Na criação, era necessário `-u`; ignorados continuam de fora |
| `.env` continua no histórico | `.gitignore` e remoção do índice não limpam versões antigas |

## 🛠️ Exercício guiado

Crie uma pasta **nova** `lab_recuperacao` dentro da sua pasta de práticas. Se o nome já existir,
escolha outro. Os comandos seguintes são PowerShell; não os execute no repositório de seus estudos.

```powershell
New-Item -ItemType Directory lab_recuperacao
Set-Location lab_recuperacao
git init -b main
git config user.name "Aluno do curso"
git config user.email "aluno@example.invalid"
Set-Content -Encoding UTF8 notas.txt "Meta: 30 minutos"
git add notas.txt
git commit -m "docs: registre a meta inicial"
```

1. **Retire do staging mantendo a edição.**

```powershell
Set-Content -Encoding UTF8 notas.txt "Meta: 45 minutos"
git add notas.txt
git restore --staged -- notas.txt
git status --short
Get-Content notas.txt
```

Espere ` M notas.txt` e `Meta: 45 minutos`. O espaço antes de `M` indica mudança só no disco.

2. **Guarde e retome a edição.**

```powershell
git stash push -m "meta em revisao"
Get-Content notas.txt
git stash apply 'stash@{0}'
Get-Content notas.txt
git diff
git stash drop 'stash@{0}'
git add notas.txt
git commit -m "docs: aumente a meta para 45 minutos"
```

O conteúdo passa por 30 e volta a 45. Só remova o stash depois de confirmar a recuperação.

3. **Refaça esse commit local sem perder o conteúdo.**

```powershell
git branch backup-meta
git reset --soft HEAD~1
git diff --staged
git commit -m "docs: ajuste a meta diaria para 45 minutos"
```

O diff preparado deve mostrar 30 → 45. O arquivo continua com 45.

4. **Reverta o novo commit.**

```powershell
git revert --no-edit HEAD
Get-Content notas.txt
git log --oneline -4
```

Espere 30 minutos no arquivo e um novo commit de reversão no topo do histórico.

5. **Localize a versão anterior.** Rode `git reflog -8`, encontre o commit
`docs: aumente a meta para 45 minutos`, confirme com `git show HASH` e crie
`git branch recuperado HASH`. Confira `git show recuperado:notas.txt`: deve mostrar 45 minutos.

6. **Simule um arquivo secreto não rastreado.**

```powershell
Set-Content -Encoding UTF8 .gitignore ".env"
Set-Content -Encoding UTF8 .env "TOKEN=VALOR_FICTICIO_SEM_ACESSO"
git check-ignore -v .env
git add .gitignore
git commit -m "chore: ignore configuracao local"
git status --short
```

O `check-ignore` deve apontar a regra `.env`; o status final deve estar limpo.

## 📝 Exercícios independentes

Faça [M00-E07 a M00-E12](../../exercicios/00-git-e-terminal.md#m00-e07).
Use o gabarito só depois de tentar por 20 minutos.

## 🏆 Desafio opcional

Em outro laboratório, crie um commit com um arquivo `.env` **fictício**, acrescente a regra ao
`.gitignore` e observe que ele continua rastreado. Retire-o com `git rm --cached -- .env` e faça
commit. Demonstre que o arquivo existe no disco e no commit anterior. Explique por que isso
não seria suficiente se o valor fosse uma credencial real publicada.

## 📌 Resumo

Localize a mudança antes de desfazer. `restore --staged` retira da preparação; `reset --soft`
refaz histórico local preservando trabalho; `revert` registra uma reversão. Stash pausa mudanças,
reflog ajuda a achar commits locais e uma credencial publicada precisa ser revogada ou trocada.

## ☑️ Checklist de domínio

- [ ] Distingo edição no disco, staging e commit.
- [ ] Retiro do staging mantendo o texto e demonstro com `diff`.
- [ ] Refaço um commit local e reverto um commit com nova entrada no histórico.
- [ ] Aplico um stash, confiro o resultado e só então removo a cópia.
- [ ] Crio uma branch a partir de um hash localizado no reflog.
- [ ] Explico por que `.gitignore` não resolve um segredo publicado.
- [ ] Executo o programa de consulta com cada situação e com entrada desconhecida.

## 📚 Referências oficiais

As fontes estão vinculadas junto de cada operação na seção Conceito. Consulte também o
[manual geral do Git](https://git-scm.com/docs/git).

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima etapa |
|---|---|---|
| [Commits, branches e .gitignore](04-commits-branches-gitignore.md) | [README](README.md) | [Exercícios](../../exercicios/00-git-e-terminal.md) |
