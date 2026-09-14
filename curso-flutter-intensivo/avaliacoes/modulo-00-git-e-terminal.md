# Avaliação — Módulo 00: Git e terminal

> **Tempo sugerido:** 20 min de questionário + 25 min de prática.
> Faça após as aulas e os oito exercícios obrigatórios, sem consultar o gabarito.

## 1. Questionário de revisão

Nas questões 1 a 6, escolha **uma** alternativa. Cada questão vale 1 ponto.

**1. O que `..` representa em um caminho relativo?**

- A. A raiz do disco.
- B. A pasta pai da localização atual.
- C. A pasta do executável Git.
- D. O diretório inicial do usuário, sempre.

**2. O que a variável PATH permite ao shell fazer?**

- A. Guardar todas as alterações do Git.
- B. Descobrir o último commit.
- C. Procurar executáveis em uma lista de diretórios.
- D. Criar pastas que ainda não existem.

**3. Um arquivo commitado contém A. Você escreve B, executa `git add` e escreve C. Sem novo
`add`, qual conteúdo será incluído no próximo commit?**

- A. A.
- B. B.
- C. C.
- D. B e C em dois commits automáticos.

**4. Qual comando retira `plano.txt` do staging preservando sua edição no disco?**

- A. `git restore -- plano.txt`.
- B. `git reset --hard`.
- C. `git restore --staged -- plano.txt`.
- D. `git clean -fd`.

**5. Qual operação registra um novo commit para desfazer a mudança de um commit compartilhado?**

- A. `git revert HASH`.
- B. `git status`.
- C. `git reset --soft HEAD~1`.
- D. Acrescentar `.gitignore`.

**6. Uma credencial real apareceu em um repositório público. Qual é a primeira ação?**

- A. Acrescentar uma linha vazia ao arquivo.
- B. Apagar o repositório local e considerar resolvido.
- C. Fazer um revert e manter a mesma credencial.
- D. Revogar ou trocar a credencial no serviço emissor.

Responda as próximas em duas a quatro frases; comandos podem complementar a explicação.

**7.** Explique a diferença entre working tree, staging e histórico. Dê um comando para observar
uma dessas camadas ou a diferença entre elas.

**8.** Você está em `revisao` e quer levar seu trabalho commitado para `main`. Qual sequência usa
e por que a branch atual importa?

**9.** Compare `git stash apply` e `git stash pop`. Para que serve `-u` na criação do stash?
Arquivos ignorados entram com essa opção?

**10.** Um `.env` já commitado foi incluído no `.gitignore`. Por que continua rastreado? Como
interromper o rastreamento preservando o arquivo local? Isso remove versões antigas?

## 2. Exercício prático avaliativo

Crie um **novo laboratório local**, sem remoto, chamado `lab_m00_avaliacao` ou outro nome ainda
não utilizado. Use somente dados fictícios e arquivos desse laboratório.

1. Inicialize `main` e configure uma identidade local.
2. Crie `README.md` com `Meta: 30 minutos` e registre o primeiro commit.
3. Crie a branch `ajuste-meta`, altere para `Meta: 45 minutos` e registre o segundo commit.
4. Volte para `main`, integre a branch e confira o conteúdo.
5. Edite o README novamente, prepare com `add`, retire do staging mantendo a edição e guarde os
   dois diffs como evidência. Depois use stash para guardar essa edição e deixar o status limpo.
6. Reverta o commit que alterou 30 para 45, usando seu hash. Termine com 30 no arquivo e um novo
   commit de reversão. Não é necessário reaplicar o stash nesta avaliação.
7. Crie regras para `.env`, `*.jks` e `android/key.properties`, faça commit do `.gitignore` e
   demonstre que uma `.env` fictícia nova é ignorada e não rastreada.

**Entregue:** histórico com branches, status final, os dois diffs da etapa 5, lista de stash,
conteúdo final do README, verificação do ignore e uma explicação de três linhas sobre a reversão.
Guarde as evidências fora do laboratório para não mudar o status final.

| Critério verificável | Pontos |
|---|---|
| Repositório próprio e identidade local | 1 |
| Dois commits e integração da branch demonstrados | 2 |
| Edição retirada do staging, preservada e guardada no stash | 2 |
| Reversão por novo commit com meta final 30 | 2 |
| Arquivo fictício ignorado e não rastreado | 2 |
| Status final limpo e evidências legíveis | 1 |

## 3. Autoavaliação

Escala: **1** não consigo; **2** consigo com ajuda; **3** consulto a aula; **4** faço sozinho;
**5** faço sozinho e explico a outra pessoa.

| Competência | Nota de 1 a 5 | Evidência ou dúvida |
|---|---|---|
| Navegar por caminhos e localizar executáveis | | |
| Distinguir disco, staging e histórico | | |
| Criar commits e integrar branches | | |
| Escolher uma forma de desfazer alterações | | |
| Usar stash e localizar commits no reflog | | |
| Explicar limites do ignore e resposta a segredos publicados | | |

## 4. Critérios mínimos para avançar

- Pelo menos **7/10** no questionário.
- Pelo menos **8/10** na prática.
- Demonstração obrigatória de preservação da edição na etapa 5 e de reversão na etapa 6.
- Nenhum segredo real usado; saber que credencial publicada exige revogação ou troca.
- Exercícios obrigatórios E01–E08 concluídos e conferidos com seus critérios.

Ao cumprir, marque somente seus resultados reais na [trilha de progresso](../03-trilha-de-progresso.md).

## 5. Se você teve dificuldade

| Sintoma | Aula a revisar | Exercício a refazer |
|---|---|---|
| Não sei onde executei o comando | [Arquivos e caminhos](../modulos/00-git-e-terminal/02-arquivos-e-caminhos.md) | E01 e E04 |
| Não encontro Git ou confundo códigos de saída | [Terminal](../modulos/00-git-e-terminal/01-o-terminal-sem-medo.md) | E02 |
| Commit não contém a versão que esperava | [Git: o que é](../modulos/00-git-e-terminal/03-git-o-que-e.md) | E03 e E05 |
| Merge não atualizou main | [Branches](../modulos/00-git-e-terminal/04-commits-branches-gitignore.md) | E06 |
| Perdi a edição ou confundi revert e reset | [Desfazendo erros](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md) | E07 e E10 |
| Achei que ignore apagava histórico | [Desfazendo erros e segredos](../modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md) | E08 e E12 |

[Conferir respostas após terminar](../gabaritos/avaliacoes.md#modulo-00) ·
[Exercícios](../exercicios/00-git-e-terminal.md) ·
[Próximo módulo](../modulos/01-logica-e-fundamentos/README.md)
