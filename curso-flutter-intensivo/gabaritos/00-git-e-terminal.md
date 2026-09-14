# Gabarito — Módulo 00: Git e terminal

> Consulte após tentar os [exercícios](../exercicios/00-git-e-terminal.md).
> Os comandos pressupõem o laboratório correspondente, nunca o repositório principal do curso.

Cada exercício vale 10 pontos, com os pesos indicados. Compare também o resultado observável.
Os nomes e hashes gerados podem variar; o comportamento deve coincidir.

<a id="m00-e01"></a>
## M00-E01 — Onde estou?

**Solução e passo a passo:** anote a origem, liste, suba um nível e retorne.

```powershell
$origemPratica = (Get-Location).Path
Get-Location
Get-ChildItem -Force
Set-Location ..
Get-Location
Set-Location -LiteralPath $origemPratica
Get-Location
```

**Raciocínio:** um caminho relativo parte do diretório atual; o absoluto identifica o destino
independentemente dele. `.` é o diretório atual e `..` é seu pai.

**Resultado esperado / verificação:** a primeira e a última localização coincidem; a intermediária
é a pasta pai. **Erro frequente:** tentar voltar com um nome relativo ao local errado.
**Alternativa válida:** usar `Push-Location` e `Pop-Location` para preservar a origem, mas ainda
demonstrar o retorno por caminho absoluto solicitado.

| Critério | Peso |
|---|---|
| Listagem com ocultos e localização inicial | 3 |
| Subida e retorno demonstrados | 4 |
| Explicação de `.` e `..` | 3 |

<a id="m00-e02"></a>
## M00-E02 — De onde vem o comando?

**Solução e passo a passo:**

```powershell
Get-Command git
$env:Path
git --version
$LASTEXITCODE
```

**Raciocínio:** PATH fornece diretórios para localizar executáveis. `$LASTEXITCODE` conserva o
código do último programa nativo ou script PowerShell que o definiu; não é um status novo de
cada cmdlet. **Resultado esperado / teste:** Git localizado e versão exibida, seguida por `0`.
**Erro frequente:** consultar depois de outro executável e atribuir o resultado ao primeiro.
**Alternativa válida:** `where.exe git` mostra os executáveis candidatos; `Get-Command` mostra a
resolução pelo PowerShell. Digitar apenas `where` pode invocar um alias diferente.

| Critério | Peso |
|---|---|
| Executável e PATH identificados | 4 |
| Código consultado imediatamente | 3 |
| Limite de `$LASTEXITCODE` explicado | 3 |

<a id="m00-e03"></a>
## M00-E03 — O que foi preparado?

**Solução:** HEAD contém A; staging contém B; disco contém C. O próximo commit incluiria B.
**Raciocínio:** `add` copia o conteúdo daquele momento para a preparação; não acompanha futuras
edições automaticamente. **Passo a passo:** salve B, prepare B, salve C e compare as duas camadas.
**Resultado esperado / testes:** `status --short` mostra `MM notas.txt`; `diff` mostra B → C;
`diff --staged` mostra A → B. Diferenças de codificação/quebra de linha podem gerar linhas extras.
**Erro frequente:** pensar que salvar C atualiza o staging. **Alternativa válida:** consultar
`git show HEAD:notas.txt` e `git show :notas.txt` para ler as versões diretamente.

| Critério | Peso |
|---|---|
| Três versões identificadas | 4 |
| Próximo commit explicado | 3 |
| Status e os dois diffs coerentes | 3 |

<a id="m00-e04"></a>
## M00-E04 — Um caminho com espaços

**Solução:** `Set-Location -LiteralPath '.\pratica com espacos'`.
**Raciocínio:** as aspas mantêm o caminho como um argumento; `-LiteralPath` evita interpretar
caracteres de curinga. **Passo a passo:** liste a pasta, confirme o nome, entre usando aspas.
**Resultado esperado / teste:** `Get-Location` termina em `pratica com espacos`.
**Erro frequente:** achar que aspas criam uma pasta inexistente. **Alternativa válida:**
`Set-Location '.\pratica com espacos'` serve para esse nome sem curingas.

| Critério | Peso |
|---|---|
| Comando correto e executado | 5 |
| Argumento único explicado | 3 |
| Diferença para pasta inexistente | 2 |

<a id="m00-e05"></a>
## M00-E05 — Histórico de estudo

**Solução e passo a passo**, partindo de sua pasta de práticas:

```powershell
New-Item -ItemType Directory lab_m00_exercicios
Set-Location lab_m00_exercicios
git init -b main
git config user.name "Aluno"
git config user.email "aluno@example.invalid"
Set-Content -Encoding UTF8 README.md "Meta: estudar 30 minutos"
git add README.md
git commit -m "docs: registre a meta inicial"
Set-Content -Encoding UTF8 plano.txt "Segunda: terminal e Git"
git add plano.txt
git commit -m "docs: planeje o primeiro dia"
Set-Content -Encoding UTF8 README.md "Meta: estudar 45 minutos"
git add README.md
git commit -m "docs: ajuste a meta para 45 minutos"
git log --oneline -3
git status --short
```

**Raciocínio:** cada commit registra uma mudança compreensível; a configuração local não altera
outros repositórios. **Resultado esperado / testes:** três commits, README com 45, plano com
segunda-feira e status sem saída. **Erro frequente:** executar dentro de um projeto existente.
**Alternativas válidas:** escrever pelo editor e escolher outras mensagens claras.

| Critério | Peso |
|---|---|
| Laboratório e identidade local | 2 |
| Três commits com responsabilidades claras | 5 |
| Conteúdo final e status limpo | 3 |

<a id="m00-e06"></a>
## M00-E06 — Revisão em uma branch

**Solução e passo a passo:**

```powershell
git switch -c revisao
Set-Content -Encoding UTF8 revisao.txt "Rever staging e working tree"
git add revisao.txt
git commit -m "docs: registre os pontos de revisao"
git switch main
Test-Path revisao.txt
git merge revisao
Test-Path revisao.txt
git status --short
```

**Raciocínio:** merge integra a branch indicada na branch atual. **Resultado esperado / testes:**
`False` antes do merge, `True` depois, status limpo; nesta sequência ocorre fast-forward.
**Erro frequente:** permanecer em `revisao` e mesclar `main`, sem atualizar `main`.
**Alternativa válida:** um merge com `--no-ff` cria um commit de integração, mantendo o conteúdo.

| Critério | Peso |
|---|---|
| Commit isolado em revisao | 3 |
| Merge feito com main como destino | 4 |
| Evidências e explicação | 3 |

<a id="m00-e07"></a>
## M00-E07 — Preparação por engano

**Solução e passo a passo:**

```powershell
Add-Content -Encoding UTF8 plano.txt "Terca: revisar comandos"
git add plano.txt
git restore --staged -- plano.txt
git diff -- plano.txt
git diff --staged -- plano.txt
git add plano.txt
git commit -m "docs: planeje a revisao de terca"
```

**Raciocínio:** o destino da restauração é somente o staging. **Resultado esperado / testes:**
antes do segundo `add`, o primeiro diff mostra a linha nova e o segundo não mostra diferenças.
**Erro frequente:** omitir `--staged`, alterando o arquivo no disco. **Alternativa válida:**
`git reset HEAD -- plano.txt` também retira do staging preservando o disco.

| Critério | Peso |
|---|---|
| Retira apenas o arquivo solicitado | 4 |
| Linha preservada e dois diffs conferidos | 4 |
| Commit final e status limpo | 2 |

<a id="m00-e08"></a>
## M00-E08 — Prevenção e resposta

**Solução:** conteúdo do `.gitignore`:

```gitignore
build/
.dart_tool/
.env
android/key.properties
*.jks
*.keystore
*.p12
```

**Passo a passo:** crie o laboratório com Git, escreva esses padrões, crie `.env` com um marcador
fictício e rode `git check-ignore -v .env`. Prepare apenas `.gitignore` e faça commit.
**Raciocínio:** ignorar impede a inclusão comum de arquivos ainda não rastreados. Uma credencial
publicada precisa primeiro ser revogada ou trocada no serviço que a emitiu.
**Resultado esperado / testes:** `check-ignore` mostra a regra; `git ls-files -- .env` não retorna
arquivo. **Erro frequente:** concluir que o `.gitignore` apagou o histórico.
**Alternativa válida:** regras ancoradas na raiz como `/.env`, se a intenção for proteger esse
arquivo apenas na raiz. A escolha deve ser explicada.

| Critério | Peso |
|---|---|
| Sete padrões presentes | 3 |
| Ignorado e não rastreado demonstrados | 3 |
| Revogação/troca e limite do histórico explicados | 4 |

<a id="m00-e09"></a>
## M00-E09 — Pausa sem perder arquivos novos

**Solução e passo a passo:** após criar as duas alterações, use:

```powershell
git stash push -u -m "rascunho do exercicio 09"
git status --short
git stash list
git stash apply 'stash@{0}'
git diff
Get-Content rascunho.txt
git stash drop 'stash@{0}'
```

**Raciocínio:** `-u` inclui novos arquivos não ignorados; `apply` preserva o stash para conferência.
**Resultado esperado / testes:** status limpo após guardar e os dois conteúdos restaurados ao
aplicar. **Erro frequente:** tirar `-u` e achar que o rascunho foi salvo. **Alternativa válida:**
`pop` aplica e remove em caso de sucesso, mas não deixa a mesma oportunidade de conferência antes
da remoção solicitada neste exercício; prefira `apply` aqui.

| Critério | Peso |
|---|---|
| Ambos os arquivos incluídos | 4 |
| Recuperação e conteúdo conferidos | 4 |
| Remoção após conferir e explicação de -u | 2 |

<a id="m00-e10"></a>
## M00-E10 — Corrigir sem apagar a história

**Solução:** serão três commits, A → B → reversão de B; `meta.txt` volta a 30.
**Raciocínio:** uma alteração inversa é acrescentada ao histórico. **Passo a passo:** crie A e B,
confirme status limpo, execute o revert e examine log e arquivo. **Resultado esperado / testes:**
`git rev-list --count HEAD` devolve 3, `git show HEAD~1:meta.txt` mostra 45 e a cópia no disco mostra 30.
**Erro frequente:** confundir revert com apagar B. **Alternativa válida:** um commit manual que
restaure 30 preserva a história, mas o exercício exige demonstrar `revert`.

| Critério | Peso |
|---|---|
| Conteúdo final previsto | 3 |
| Três commits e preservação de B explicados | 4 |
| Reprodução conferida | 3 |

<a id="m00-e11"></a>
## M00-E11 — Encontrar a versão antiga

**Solução e passo a passo:**

```powershell
git rev-parse HEAD
git branch backup
git reset --soft HEAD~1
git diff --staged
git commit -m "docs: esclareca a segunda etapa"
git reflog -8
```

Localize o hash antigo, confira com `git show HASH`, crie `git branch recuperado HASH` e consulte
`git show recuperado:ARQUIVO` com o nome do arquivo usado no laboratório.
**Raciocínio:** uma referência preserva o acesso ao commit, sem sobrescrever os arquivos atuais.
**Resultado esperado / testes:** `git rev-parse recuperado` coincide com o hash anotado; o
conteúdo é o anterior e a branch atual não mudou. **Erro frequente:** copiar sempre `HEAD@{1}`
sem examinar quais operações ocorreram. **Alternativa válida:** a branch `backup` já preserva
o commit, mas localizar no reflog continua sendo parte do exercício. Reflog é local e expira;
não protege contra perda do disco nem registra cada edição do editor.

| Critério | Peso |
|---|---|
| Reset preservando trabalho e novo commit | 3 |
| Hash localizado e branch recuperado correta | 4 |
| Conteúdo consultado e limites explicados | 3 |

<a id="m00-e12"></a>
## M00-E12 — Um segredo fictício já rastreado

**Solução e passo a passo:** após o primeiro commit fictício:

```powershell
Set-Content -Encoding UTF8 .gitignore ".env"
git rm --cached -- .env
git add .gitignore
git commit -m "chore: retire configuracao local do indice"
git ls-files -- .env
Test-Path .env
git show HEAD~1:.env
```

**Raciocínio:** `--cached` atua no índice, preservando o arquivo local; o commit novo não reescreve
os anteriores. **Resultado esperado / testes:** nenhuma saída de `ls-files`, `True` em
`Test-Path`, marcador fictício visível com `show`. **Erro frequente:** usar `git rm` sem `--cached`
ou pensar que o histórico foi limpo. **Alternativa válida:** uma regra `/.env` serve para a raiz.
Para uma credencial real publicada: revogar/trocar no emissor; remover o uso exposto e corrigir
o armazenamento; coordenar a limpeza das referências e cópias seguindo a
[orientação do GitHub](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).

| Critério | Peso |
|---|---|
| Remoção do índice com cópia local preservada | 4 |
| Presença no histórico demonstrada | 3 |
| Resposta ao incidente explicada na ordem correta | 3 |

[Voltar aos exercícios](../exercicios/00-git-e-terminal.md) · [Avaliação](../avaliacoes/modulo-00-git-e-terminal.md)
