# Exercícios — Módulo 00: Git e terminal

> Faça após as cinco aulas. E01–E08 são obrigatórios; E09–E12 aprofundam a prática.
> Use apenas laboratórios locais e valores fictícios. Nenhum exercício pede publicação ou push.

Registre respostas e evidências fora dos arquivos que você vai modificar durante o exercício.
Os comandos desta lista usam PowerShell. Os exercícios são independentes, exceto E06 e E07,
que continuam o laboratório criado em E05.

<a id="m00-e01"></a>
## M00-E01 — Onde estou? · Fixação

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Localizar e percorrer pastas | Fácil | 5 min | Aula 01 e 02 | Sim |

Mostre a pasta atual e liste inclusive os arquivos ocultos. Entre na pasta pai usando caminho
relativo e volte usando o caminho absoluto anotado. Explique o significado de `.` e `..`.

**Entrega:** três caminhos observados e comandos utilizados.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e01)

<a id="m00-e02"></a>
## M00-E02 — De onde vem o comando? · Fixação

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Explicar PATH e código de saída | Fácil | 5 min | Aula 01 | Sim |

Localize o executável Git, mostre o PATH e rode `git --version`. Consulte imediatamente
`$LASTEXITCODE`. Explique por que esse valor deve ser lido logo após um programa externo e por
que um cmdlet PowerShell bem-sucedido não necessariamente o redefine.

**Entrega:** localização, código observado e explicação em duas frases.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e02)

<a id="m00-e03"></a>
## M00-E03 — O que foi preparado? · Leitura de código

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Distinguir disco, staging e commit | Média | 10 min | Aula 03 | Sim |

Um repositório limpo contém `notas.txt` com `A`, já commitado. Preveja o resultado:

```powershell
Set-Content notas.txt "B"
git add notas.txt
Set-Content notas.txt "C"
git status --short
git diff
git diff --staged
```

Quais valores estão no disco, staging e HEAD? Qual valor entraria no próximo commit sem outro
`add`? Só depois de responder, reproduza em um laboratório novo.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e03)

<a id="m00-e04"></a>
## M00-E04 — Um caminho com espaços · Correção de bugs

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Corrigir passagem de um caminho | Fácil | 5 min | Aula 02 | Sim |

O aluno criou `pratica com espacos` dentro da pasta atual, mas escreveu
`Set-Location .\pratica com espacos`. Explique e corrija o comando. Não renomeie a pasta:
o objetivo é aprender a passar um único argumento. Diferencie espaço no caminho de uma pasta
que não existe.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e04)

<a id="m00-e05"></a>
## M00-E05 — Histórico de estudo · Implementação

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Criar repositório e commits coerentes | Média | 15 min | Aulas 01 a 04 | Sim |

Crie uma pasta nova `lab_m00_exercicios`, inicialize Git na branch `main` e configure nome/e-mail
apenas nesse repositório; pode usar `Aluno` e `aluno@example.invalid`. Crie três commits:
um README com a meta, um `plano.txt` com o dia de estudo e uma alteração da meta no README.
Use mensagens que permitam entender cada mudança. Termine com status limpo.

**Entrega:** `git log --oneline -3`, `git status --short` e conteúdo final dos dois arquivos.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e05)

<a id="m00-e06"></a>
## M00-E06 — Revisão em uma branch · Aplicação

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Integrar uma mudança isolada | Média | 10 min | Aula 04 e E05 | Sim |

No laboratório E05, crie a branch `revisao`, acrescente `revisao.txt` e faça commit. Volte para
`main`, confirme que o arquivo ainda não está nela e faça merge de `revisao` para `main`.
Explique por que a branch em que você está antes do merge importa.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e06)

<a id="m00-e07"></a>
## M00-E07 — Preparação por engano · Correção de bugs

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Desfazer add preservando uma edição | Fácil | 5 min | Aula 05 e E05 | Sim |

Acrescente uma linha ao `plano.txt` de E05 e prepare-a com `git add`. Retire **somente esse arquivo**
do staging mantendo a linha nova. Comprove com os dois tipos de diff. Guarde a evidência e faça
commit da alteração para deixar o laboratório limpo.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e07)

<a id="m00-e08"></a>
## M00-E08 — Prevenção e resposta · Revisão cumulativa

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Proteger arquivos locais e explicar incidentes | Média | 10 min | Aulas 03 a 05 | Sim |

Em um laboratório novo, escreva um `.gitignore` com `build/`, `.dart_tool/`, `.env`,
`android/key.properties`, `*.jks`, `*.keystore` e `*.p12`. Crie somente uma `.env` fictícia e
demonstre que está ignorada. Explique: se uma chave real já estivesse publicada em um commit,
qual seria a primeira ação? Por que adicionar esse `.gitignore` não resolveria o histórico?

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e08)

<a id="m00-e09"></a>
## M00-E09 — Pausa sem perder arquivos novos · Aplicação

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Recuperar conteúdo de um stash | Média | 10 min | Aula 05 | Não |

Em um laboratório com um commit e status limpo, edite um arquivo rastreado e crie `rascunho.txt`
não ignorado. Guarde os dois num stash identificado. Confira status, aplique o stash e demonstre
que ambos voltaram. Remova a entrada apenas depois de conferir. Explique a função de `-u`.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e09)

<a id="m00-e10"></a>
## M00-E10 — Corrigir sem apagar a história · Leitura de código

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Prever o resultado de revert | Média | 10 min | Aula 05 | Não |

Há dois commits lineares e status limpo: A cria `meta.txt` com 30, B altera para 45.
O que acontecerá com arquivo e histórico depois de `git revert --no-edit HEAD`? Quantos commits
existirão? A alteração B continuará consultável? Reproduza apenas em um laboratório sem remoto.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e10)

<a id="m00-e11"></a>
## M00-E11 — Encontrar a versão antiga · Desafio prático

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Recuperar referência usando reflog | Difícil | 15 min | Aula 05 | Não |

Em laboratório com dois commits, anote o hash do segundo, crie `backup` e faça
`git reset --soft HEAD~1`. Recrie o commit com uma mensagem melhor. Localize o hash antigo no
reflog e crie uma branch `recuperado` apontando para ele. Comprove que o conteúdo antigo é
consultável sem trocar de branch. Explique por que reflog não substitui backup.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e11)

<a id="m00-e12"></a>
## M00-E12 — Um segredo fictício já rastreado · Desafio prático

| Objetivo | Dificuldade | Tempo | Conhecimentos necessários | Obrigatório? |
|---|---|---|---|---|
| Distinguir índice, disco e histórico | Difícil | 15 min | Aulas 04 e 05 | Não |

Em um novo laboratório, faça commit de `.env` contendo `TOKEN=VALOR_FICTICIO_SEM_ACESSO`.
Adicione a regra ao `.gitignore`, retire `.env` do índice sem apagar a cópia local e faça commit.
Prove que ela saiu do índice, continua no disco e permanece no commit anterior. Escreva três
ações para o caso hipotético de uma credencial real ter sido publicada. Não faça push.

[🔑 Gabarito](../gabaritos/00-git-e-terminal.md#m00-e12)

[Módulo](../modulos/00-git-e-terminal/README.md) · [Avaliação](../avaliacoes/modulo-00-git-e-terminal.md)
