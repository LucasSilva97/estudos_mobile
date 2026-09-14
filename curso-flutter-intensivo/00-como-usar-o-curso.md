# 00 — Como usar o curso

> Este é o manual de instruções do curso. Leia-o **inteiro** antes de abrir o primeiro módulo.
> São uns 20 minutos que economizam vários dias de estudo mal direcionado.

⬅️ Voltar para o [README.md](README.md) · ➡️ Próximo: [01-plano-intensivo.md](01-plano-intensivo.md)

---

## 1. O que este curso espera de você

| Espera | Não espera |
|---|---|
| Que você **leia** a aula inteira antes de copiar código | Que você já saiba mobile |
| Que você **digite** o código, não cole | Que você tenha um Mac |
| Que você rode `flutter analyze` antes de pedir ajuda | Que você acerte de primeira |
| Que você marque seu progresso | Que você decore nomes de widgets |
| 4 horas por dia, por 30 dias | Que você estude 12 horas seguidas |

Uma regra acima de todas: **entender > terminar**. Uma aula compreendida vale mais do que
três aulas atravessadas.

---

## 2. Ordem de leitura

O curso tem uma ordem única e ela não é decorativa: cada módulo usa o que o anterior ensinou.

### 2.1 Arquivos da raiz — nesta sequência

| Ordem | Arquivo | Para quê |
|---|---|---|
| 1 | [README.md](README.md) | Visão geral e índice de tudo |
| 2 | **00-como-usar-o-curso.md** (este) | Método de estudo |
| 3 | [01-plano-intensivo.md](01-plano-intensivo.md) | Escolher o ritmo e ver o cronograma |
| 4 | [02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md) | Deixar a máquina pronta |
| 5 | [03-trilha-de-progresso.md](03-trilha-de-progresso.md) | Onde você marca o que concluiu |
| 6 | [04-mapa-de-aprendizagem.md](04-mapa-de-aprendizagem.md) | Ver as dependências entre assuntos |

Os arquivos [05-decisoes-tecnicas.md](05-decisoes-tecnicas.md) e
[06-relatorio-de-validacao.md](06-relatorio-de-validacao.md) são de consulta: leia quando
quiser saber **por que** o curso escolheu uma tecnologia ou **como** um dado foi verificado.

### 2.2 Os 17 módulos — sempre em ordem numérica

`00` → `01` → `02` → … → `16`.

Dentro de cada módulo:

1. Abra o `README.md` da pasta do módulo (ele explica o que o módulo entrega).
2. Faça as aulas em ordem numérica (`01-...`, `02-...`, …).
3. Faça a lista de exercícios do módulo.
4. Confira com o gabarito.
5. Faça a avaliação do módulo.
6. Só então passe ao módulo seguinte.

### 2.3 Onde entram os projetos

Os projetos não são "extras": eles são o momento em que o conhecimento gruda.

| Projeto | Quando fazer | Onde |
|---|---|---|
| Projeto 1 — Meu Primeiro App | logo após o módulo 05 | [projetos/01-projeto-iniciante/README.md](projetos/01-projeto-iniciante/README.md) |
| Projeto 2 — Bloco de Notas | logo após o módulo 07 | [projetos/02-projeto-intermediario/README.md](projetos/02-projeto-intermediario/README.md) |
| Projeto 3 — Foco (final) | após o módulo 13 | [projetos/03-projeto-final-multiplataforma/README.md](projetos/03-projeto-final-multiplataforma/README.md) |

---

## 3. O ciclo de estudo: aula → exercício → gabarito → avaliação

Este é o mecanismo central do curso. Siga-o sempre na mesma ordem.

### 3.1 A aula

Toda aula tem exatamente as mesmas seções, sempre na mesma ordem. Saber disso deixa você
rápido:

| Seção | O que fazer nela |
|---|---|
| 🎯 Objetivos de aprendizagem | Leia primeiro. É o contrato da aula |
| ✅ Pré-requisitos | Se você não tem um deles, volte e faça antes |
| 📖 Conceito | Leia com calma. Aqui está o "porquê" |
| 💡 Analogia | Ajuda a fixar. Algumas aulas não têm — nem toda ideia tem analogia honesta |
| 🧪 Exemplo mínimo | O menor código possível que mostra a ideia. **Digite e rode** |
| 📱 Aplicando no Flutter | Como a ideia aparece num app de verdade |
| 💻 Código completo | O código inteiro, com caminho do arquivo e comando para executar |
| 🔍 Explicando o código | Linha a linha. Não pule |
| 🤖🍎 Android × iOS | Diferenças reais de plataforma (algumas aulas não têm) |
| ⚠️ Erros comuns | Leia **antes** de errar. Economiza horas |
| 🛠️ Exercício guiado | Faça junto com a aula, passo a passo |
| 📝 Exercícios independentes | Aponta para a lista completa do módulo |
| 🏆 Desafio opcional | Só se sobrar tempo e vontade |
| 📌 Resumo | Releia antes de dormir e no dia seguinte |
| ☑️ Checklist de domínio | Se você não marca todas, releia a aula |
| 📚 Referências oficiais | Documentação de verdade, para aprofundar |
| Tabela de navegação | Anterior · Módulo · Próxima |

**Tempo por aula:** o cabeçalho de cada aula traz o tempo estimado em minutos. Some os tempos
do dia e compare com o seu cronograma em [01-plano-intensivo.md](01-plano-intensivo.md).

### 3.2 Os exercícios

Cada módulo tem uma lista própria em `exercicios/`, com **pelo menos 12 exercícios**
(no mínimo 8 obrigatórios), organizados em 7 tipos:

| # | Tipo | O que treina |
|---|---|---|
| 1 | Fixação | Memória do conceito recém-visto |
| 2 | Aplicação | Usar o conceito num caso novo |
| 3 | Leitura de código | Prever o que um código faz sem rodar |
| 4 | Correção de bugs | Achar e consertar defeitos plantados de propósito |
| 5 | Implementação | Escrever do zero |
| 6 | Revisão cumulativa | Amarrar com módulos anteriores |
| 7 | Desafio prático | Problema aberto, mais próximo do mundo real |

Cada exercício traz uma tabela com **Objetivo**, **Dificuldade**, **Tempo estimado**,
**Conhecimentos necessários** e **Obrigatório?**. O identificador segue o padrão
`M<NN>-E<NN>` — por exemplo `M02-E03` é o terceiro exercício do módulo 02.

**A regra do gabarito:** tente por, no mínimo, **20 minutos** antes de abrir a solução.
Travar faz parte; olhar cedo demais é o que impede o aprendizado.

Como explicado em [exercicios/README.md](exercicios/README.md), cada exercício termina com
um link 🔑 direto para a sua solução.

### 3.3 Os gabaritos

O gabarito não é só a resposta. Cada um traz:

| Bloco | Para que serve |
|---|---|
| **Solução** | O código que funciona |
| **Raciocínio** | Como se chega até ele — **esta é a parte mais valiosa** |
| **Passo a passo** | A ordem das decisões |
| **Resultado esperado** | O que aparece na tela/terminal |
| **Erros frequentes** | O que quase todo mundo erra ali |
| **Alternativas válidas** | Outras soluções corretas, com prós e contras |
| **Critérios objetivos de correção** | Tabela de critério e peso, para você se autocorrigir |
| **Testes / entradas e saídas** | Casos concretos para conferir |

Use assim: compare **o seu raciocínio** com o do gabarito, não só o código. Se o seu código
funciona e é diferente, veja em "Alternativas válidas" se ele já está previsto.

Comece por [gabaritos/README.md](gabaritos/README.md) para entender a convenção de âncoras.

### 3.4 As avaliações

Toda avaliação tem 5 seções fixas, descritas em [avaliacoes/README.md](avaliacoes/README.md):

1. **Questionário de revisão** — 10 questões (6 de múltipla escolha + 4 dissertativas curtas).
2. **Exercício prático avaliativo** — 1 tarefa com critérios verificáveis.
3. **Autoavaliação** — tabela de competências, escala 1 a 5.
4. **Critérios mínimos para avançar** — objetivos, do tipo "acertar ≥ 7 de 10".
5. **Se você teve dificuldade** — tabela sintoma → aula a revisar → exercício a refazer.

As respostas ficam todas em
[avaliacoes/gabarito-das-avaliacoes.md](gabaritos/avaliacoes.md).
**Responda tudo antes de abrir esse arquivo.**

Além das 17 avaliações de módulo, há 5 cumulativas e 1 final:

| Avaliação | Cobre |
|---|---|
| [Cumulativa 01 — Dart](avaliacoes/cumulativa-01-dart.md) | Módulos 00 a 04 |
| [Cumulativa 02 — Flutter UI](avaliacoes/cumulativa-02-flutter-ui.md) | Módulos 05 a 07 |
| [Cumulativa 03 — Estado e dados](avaliacoes/cumulativa-03-estado-e-dados.md) | Módulos 08 a 10 |
| [Cumulativa 04 — Qualidade e plataforma](avaliacoes/cumulativa-04-qualidade-e-plataforma.md) | Módulos 11 a 13 |
| [Cumulativa 05 — Build e distribuição](avaliacoes/cumulativa-05-build-e-distribuicao.md) | Módulos 14 a 16 |
| [Avaliação final](avaliacoes/avaliacao-final.md) | Curso inteiro + projeto "Foco" |

---

## 4. Quanto tempo dedicar

O curso tem **120 horas** de carga total, independentemente do ritmo escolhido. O que muda é
como essas 120 horas se distribuem.

| Ritmo | Duração | Horas/dia | Divisão diária |
|---|---|---|---|
| Muito intensivo | 15 dias | 8 h | 5 h conteúdo + 3 h prática |
| **Intensivo recomendado** ⭐ | **30 dias** | **4 h** | **3 h conteúdo + 1 h prática** |
| Moderado | 60 dias | 2 h | 1 h 30 conteúdo + 30 min prática |

Detalhes completos, com cronograma dia a dia, em [01-plano-intensivo.md](01-plano-intensivo.md).

### Como dividir as 4 horas do ritmo recomendado

| Faixa | Duração | Atividade |
|---|---|---|
| Bloco 1 | 50 min | Aulas novas (ler + digitar os exemplos) |
| Pausa | 10 min | Levante da cadeira. Sério |
| Bloco 2 | 50 min | Aulas novas |
| Pausa | 10 min | |
| Bloco 3 | 50 min | Aulas novas + exercício guiado |
| Pausa | 10 min | |
| Bloco 4 | 50 min | Exercícios independentes e correção pelo gabarito |
| Fechamento | 10 min | Reler os 📌 Resumos do dia e marcar a trilha |

**Nunca** estude dois blocos seguidos sem pausa: o custo aparece no dia seguinte, em forma de
conceito que "some".

---

## 5. Como marcar progresso na trilha

O arquivo [03-trilha-de-progresso.md](03-trilha-de-progresso.md) é a sua planilha de controle.
Ele é feito de caixas de marcação Markdown:

```text
- [ ] Aula não concluída
- [x] Aula concluída
```

Rotina de marcação:

1. Abra [03-trilha-de-progresso.md](03-trilha-de-progresso.md) no VS Code.
2. Ao terminar uma aula, troque `- [ ]` por `- [x]` na linha dela.
3. Só marque quando o **☑️ Checklist de domínio** da aula estiver inteiro marcado.
   Marcar uma aula que você não entendeu é enganar a si mesmo.
4. No fim do dia, faça um commit (uma "foto" salva do seu trabalho no Git) com a mensagem
   do dia, por exemplo:

```powershell
git add .
git commit -m "Dia 04 concluido: modulo 02 aulas 1-5"
```

O Git é ensinado no [módulo 00, aula 03](modulos/00-git-e-terminal/03-git-o-que-e.md) e
no [módulo 00, aula 04](modulos/00-git-e-terminal/04-commits-branches-gitignore.md).
Se você ainda não fez esse módulo, deixe o commit para depois e só marque as caixas.

### Sinais de que você deve desacelerar

- Você marcou 3 aulas seguidas sem conseguir explicar nenhuma em voz alta.
- Você está copiando código sem ler a seção 🔍 "Explicando o código".
- Você errou mais da metade das questões da avaliação do módulo.

Nesses casos, **refaça o módulo**. Perder um dia é barato; carregar uma base furada até o
módulo 08 é caro.

---

## 6. O que fazer quando travar — método de depuração em 5 passos

Você **vai** travar. Todo programador trava. A diferença é o método. Use sempre estes cinco
passos, nesta ordem, antes de pedir ajuda a quem quer que seja.

*Depurar* (do inglês *debug*) é o processo de encontrar e remover defeitos de um programa.

### Passo 1 — Leia a mensagem de erro inteira, até o fim

Não a primeira linha: a **mensagem inteira**. Ela quase sempre traz três informações:
o **tipo** do erro, o **arquivo e a linha** onde aconteceu e o **motivo**.

Exemplo real desta máquina:

```text
[☠] Flutter (the doctor check crashed)
    ✗ FileSystemException: Cannot resolve symbolic links,
      path = 'C:\Users\Usu rio\Documents\flutter\bin\flutter'
      (OS Error: O sistema não pode encontrar o caminho especificado, errno = 3)
```

Aqui o tipo é `FileSystemException`, o caminho aparece quebrado (`Usu rio` no lugar de
`Usuário`) e o motivo é o acento no caminho. A resposta estava escrita na mensagem.

A aula [01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md](modulos/01-logica-e-fundamentos/10-lendo-mensagens-de-erro.md)
é inteiramente sobre isso, e
[12-testes-e-debug/01-lendo-stack-traces.md](modulos/12-testes-e-debug/01-lendo-stack-traces.md)
ensina a ler a pilha de chamadas.

### Passo 2 — Reduza ao menor caso que ainda falha

Comente trechos, apague widgets, tire pacotes. Vá diminuindo até restar o **menor** código
que ainda apresenta o problema. Em geral o defeito aparece sozinho nesse processo.

### Passo 3 — Rode as ferramentas de diagnóstico

```powershell
flutter analyze
dart format .
flutter doctor -v
```

- `flutter analyze` aponta erros e avisos sem precisar rodar o app.
- `dart format .` reformata o código no padrão oficial (muitas vezes revelando um bloco
  fechado no lugar errado).
- `flutter doctor -v` diz se o problema é do seu ambiente, e não do seu código.

Se nada disso resolver, limpe os artefatos de compilação e tente de novo:

```powershell
flutter clean
flutter pub get
```

### Passo 4 — Confira o arquivo de erros comuns do curso

Abra [referencias/erros-comuns.md](referencias/erros-comuns.md) e procure pelo texto exato do
seu erro. Os erros que **já aconteceram nesta máquina** estão lá com a correção completa,
incluindo os três do ambiente Windows.

### Passo 5 — Escreva o problema em voz alta (e só então peça ajuda)

Escreva, em um parágrafo: **o que eu esperava**, **o que aconteceu**, **o que eu já tentei**.
Um número surpreendente de problemas se resolve durante essa escrita.

Se ainda assim continuar travado, aí sim peça ajuda — com o texto que você acabou de escrever.

---

## 7. Como pedir ajuda de forma eficiente

Quando for perguntar (em uma comunidade, para um colega ou para uma ferramenta de IA),
entregue **sempre** estes sete itens:

| # | Item | Exemplo |
|---|---|---|
| 1 | Versões | `Flutter 3.47.1 · Dart 3.13.1 · Windows 11 25H2` |
| 2 | O que você queria fazer | "Exibir a lista de matérias vinda do sqflite" |
| 3 | O que aconteceu | "A tela fica branca e o app não trava" |
| 4 | Mensagem de erro completa | Cole o texto inteiro, dentro de um bloco de código |
| 5 | O menor código que reproduz | O resultado do Passo 2 |
| 6 | O que você já tentou | "Rodei `flutter clean`, conferi o `pubspec.yaml`" |
| 7 | Saída de `flutter doctor -v` | Quando o problema parece de ambiente |

Onde perguntar (links em [referencias/referencias-oficiais.md](referencias/referencias-oficiais.md)):
documentação oficial do Flutter e do Dart, o rastreador de issues do pacote em questão, e
comunidades brasileiras de Flutter.

**Nunca** cole em uma pergunta pública: senha, token, conteúdo de `key.properties`, arquivo
`.jks` ou qualquer chave. Veja a seção 10 deste arquivo.

---

## 8. O que é obrigatório e o que é opcional

| Item | Status | Observação |
|---|---|---|
| Ler todas as aulas dos módulos 00 a 16 | **Obrigatório** | Inclusive as seções ⚠️ e 🔍 |
| Digitar e rodar o "💻 Código completo" de cada aula | **Obrigatório** | Digitar, não colar |
| 🛠️ Exercício guiado de cada aula | **Obrigatório** | É curto e faz parte da aula |
| Exercícios marcados "Obrigatório? Sim" | **Obrigatório** | Mínimo de 8 por módulo |
| Exercícios marcados "Obrigatório? Opcional" | Opcional | Faça se sobrar tempo |
| 🏆 Desafio opcional das aulas | Opcional | Ótimo se você quer ir além |
| Avaliação de cada módulo | **Obrigatório** | Critério de avanço |
| 5 avaliações cumulativas | **Obrigatório** | Marcam os pontos de verificação |
| Avaliação final | **Obrigatório** | Fecha o curso |
| Projeto 1 e Projeto 2 | **Obrigatório** | Preparam o projeto final |
| Projeto final "Foco" | **Obrigatório** | É a entrega do curso |
| Desafios dos projetos (`05-desafios.md`, `12-desafios.md`) | Opcional | Com gabarito próprio |
| [Aula de go_router](modulos/07-navegacao-e-formularios/09-go-router-opcional.md) | Opcional | O curso ensina `Navigator` 1.0 |
| Módulo 15 (iOS) executado na prática | Depende de Mac | Ler e preparar é **obrigatório**; executar exige macOS |
| Checklists em `checklists/` | **Obrigatório** nos pontos indicados | São conferência, não conteúdo novo |

No ritmo **muito intensivo** (15 dias) faça, entre os opcionais, apenas os marcados com ⭐.
No ritmo **moderado** (60 dias) pode pular todos os opcionais sem prejuízo.

---

## 9. Convenção de emojis de plataforma

Estes cinco emojis aparecem em **todo** o curso e significam sempre a mesma coisa:

| Emoji | Significa | Exemplo de uso |
|---|---|---|
| 🤖 | Específico do **Android** | `AndroidManifest.xml`, keystore, AAB |
| 🍎 | Específico do **iOS** | Xcode, CocoaPods, `Info.plist`, TestFlight |
| 🪟 | Específico do **Windows** | PowerShell, PATH, Modo de Desenvolvedor |
| 🐧 | Específico do **Linux** | comandos `bash`, permissões de arquivo |
| 🖥️ | Específico do **macOS** | `sudo xcode-select`, Terminal do Mac |

Quando um passo exige um Mac, você verá um aviso destacado como este:

> 🍎 **SÓ NO MAC.** Este passo exige macOS + Xcode. No Windows você pode ler e entender
> o processo, mas não executá-lo. Veja o que fazer enquanto isso em
> [modulos/15-build-ios/01-por-que-exige-macos.md](modulos/15-build-ios/01-por-que-exige-macos.md).

Quando um comando muda conforme o sistema, o curso mostra os dois blocos, rotulados:

**🪟 Windows (PowerShell)**
```powershell
flutter --version
```

**🖥️ macOS / 🐧 Linux (bash/zsh)**
```bash
flutter --version
```

Outros emojis que você vai ver nas aulas são apenas marcadores de seção
(🎯 objetivos, 📖 conceito, 💻 código, ⚠️ erros, 📌 resumo) e estão listados na seção 3.1.

---

## 10. Higiene de segredos — regras inegociáveis

Um *segredo* é qualquer dado que dá a alguém o poder de agir como você: senha, token de API,
chave privada, arquivo de assinatura. A partir do módulo 14 você vai **criar segredos de
verdade** (sua keystore Android). Estas regras valem desde hoje.

### 10.1 O que nunca entra em um repositório

| Arquivo / dado | Por quê |
|---|---|
| `*.jks`, `*.keystore` | É a chave que assina seu app. Quem a tem pode publicar "no seu nome" |
| `android/key.properties` | Contém as senhas da keystore |
| `*.p12`, `*.cer` | 🍎 Certificados de assinatura da Apple |
| `ios/Runner/*.mobileprovision` | 🍎 Perfil de provisionamento |
| `.env` | Variáveis de ambiente, geralmente com tokens |
| Qualquer token, senha ou chave de API | Vale para código, comentário e mensagem de commit |

### 10.2 O `.gitignore` mínimo que você deve ter

*`.gitignore`* é um arquivo que lista o que o Git deve ignorar, ou seja, nunca versionar.

```text
# Segredos de assinatura
*.jks
*.keystore
android/key.properties

# Segredos iOS
*.p12
*.cer
ios/Runner/*.mobileprovision

# Variáveis de ambiente
.env
.env.*
```

O passo a passo completo está em
[modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md](modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md)
e a aplicação prática em
[modulos/14-build-android/06-keystore.md](modulos/14-build-android/06-keystore.md).

### 10.3 Como o próprio curso escreve segredos

Nenhum arquivo deste curso contém uma senha ou chave real. Onde um valor secreto apareceria,
você encontra um **marcador**:

```properties
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=upload
storeFile=C:\\Users\\SEU_USUARIO\\upload-keystore.jks
```

Marcadores usados: `SUA_SENHA_AQUI`, `<sua-senha>`, `COLOQUE_SEU_ALIAS`, `SEU_USUARIO`,
`SUA_API_KEY`, `SEU_ISSUER_ID`. Sempre que ver um deles, **substitua pelo seu valor** e
nunca versione o arquivo resultante.

### 10.4 Se um segredo vazou

1. Considere o segredo **comprometido**, mesmo que você apague o commit.
2. Troque o segredo na origem (gere nova chave, revogue o token).
3. Só então limpe o histórico. Apagar do histórico sem trocar a chave não resolve nada.

O procedimento está em
[modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md](modulos/00-git-e-terminal/05-desfazendo-erros-e-segredos.md)
e o contexto de segurança mobile em
[modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md](modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md).

> ⚠️ **Perder a keystore Android é irreversível.** Se você publicar um app na Google Play e
> perder o arquivo `.jks`, você não consegue mais atualizar esse app. Faça cópia de segurança
> em local privado — nunca no repositório.

---

## 11. Glossário mínimo do curso

Estes são os termos que este curso usa para falar de si mesmo. O glossário técnico completo,
com os termos de Dart e Flutter, está em [referencias/glossario.md](referencias/glossario.md).

| Termo | Significado neste curso |
|---|---|
| **Aula** | Um arquivo `.md` dentro de `modulos/<módulo>/`, com as 17 seções fixas |
| **Módulo** | Uma pasta em `modulos/` com um `README.md` e suas aulas |
| **Lista de exercícios** | Um arquivo em `exercicios/`, com 12 ou mais exercícios do módulo |
| **Gabarito** | Um arquivo em `gabaritos/` com a solução comentada de cada exercício |
| **Avaliação** | Um arquivo em `avaliacoes/`, com as 5 seções fixas |
| **Cumulativa** | Avaliação que cobre vários módulos de uma vez |
| **Trilha de progresso** | [03-trilha-de-progresso.md](03-trilha-de-progresso.md): suas caixas de marcação |
| **Checklist** | Arquivo em `checklists/` usado como conferência antes de avançar |
| **Exercício guiado** | Exercício resolvido junto com a aula, dentro da própria aula |
| **Desafio opcional** | Tarefa aberta no fim da aula, sem obrigatoriedade |
| **ID de exercício** | Código no formato `M<NN>-E<NN>`, por exemplo `M09-E07` |
| **SÓ NO MAC** | Bloco 🍎 indicando passo que exige macOS |
| **Marcador de segredo** | Texto como `SUA_SENHA_AQUI` que você substitui pelo seu valor |
| **Projeto final** | O app "Foco", pacote `br.com.estudos.foco` |

### Termos técnicos que aparecem já no primeiro dia

| Termo | Explicação curta |
|---|---|
| **SDK** | *Software Development Kit* — o pacote de ferramentas que você instala para poder programar em uma tecnologia |
| **Framework** | Conjunto de bibliotecas e regras que serve de estrutura pronta para o seu programa. Flutter é um framework |
| **Terminal** | Janela onde você digita comandos em vez de clicar. No Windows, o PowerShell |
| **PATH** | Lista de pastas onde o sistema procura os programas que você chama pelo nome |
| **Repositório** | Pasta controlada pelo Git, com todo o histórico do seu código |
| **Commit** | Uma "foto" salva do seu projeto num momento, com uma mensagem descritiva |
| **Build** | O processo de transformar seu código em um app instalável, e também o arquivo gerado |
| **APK** | *Android Package* — arquivo instalável de Android |
| **AAB** | *Android App Bundle* — formato exigido pela Google Play para publicação |
| **IPA** | *iOS App Store Package* — arquivo instalável de iOS 🍎 |
| **Lint** | Verificador automático de qualidade e estilo do código |
| **API** | *Application Programming Interface* — o "balcão de atendimento" de um serviço, por onde seu app pede e envia dados |

---

## 12. Ferramentas que você vai usar todo dia

| Ferramenta | Para quê | Versão nesta máquina |
|---|---|---|
| VS Code | Escrever código e ler o curso | instalado ✅ |
| PowerShell | Rodar os comandos `flutter` e `dart` | nativo do Windows 11 |
| Flutter SDK | Compilar e rodar o app | 3.47.1 |
| Dart SDK | A linguagem, já vem no Flutter | 3.13.1 |
| Git | Guardar o histórico do seu trabalho | 2.46.0.windows.1 ✅ |
| Chrome | Rodar o app na web durante os estudos | 152.x ✅ |
| Android Studio | Emulador e Android SDK | ❌ instalar no Dia 1 |

A instalação e a correção dos três problemas desta máquina estão em
[02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md).
A lista completa de comandos, com explicação de cada um, está em
[referencias/comandos-uteis.md](referencias/comandos-uteis.md).

---

## 13. Três hábitos que multiplicam seu resultado

1. **Digite o código, não cole.** A memória motora participa do aprendizado. Colar entrega
   um app funcionando e nenhum conhecimento.
2. **Explique em voz alta.** No fim de cada dia, explique o conceito principal como se
   houvesse alguém ouvindo. O ponto em que você trava é o ponto que você não entendeu.
3. **Rode `flutter analyze` sempre.** Antes de qualquer `flutter run`, antes de qualquer
   pedido de ajuda, antes de qualquer commit.

---

## 14. Antes de seguir adiante

- [ ] Li este arquivo inteiro.
- [ ] Sei quais são as 17 seções de uma aula e para que serve cada uma.
- [ ] Sei que devo tentar 20 minutos antes de abrir o gabarito.
- [ ] Sei o que significam 🤖 🍎 🪟 🐧 🖥️.
- [ ] Conheço os 5 passos do método de depuração.
- [ ] Sei o que nunca pode entrar em um repositório.
- [ ] Sei que gerar IPA exige macOS, e por quê.
- [ ] Sei onde marcar meu progresso.

Marcou todas? Então vá para **[01-plano-intensivo.md](01-plano-intensivo.md)** e escolha
seu ritmo.

---

| ⬅️ Anterior | 🏠 Início | ➡️ Próximo |
|---|---|---|
| [README.md](README.md) | [README.md](README.md) | [01-plano-intensivo.md](01-plano-intensivo.md) |
