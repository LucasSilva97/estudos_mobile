# Gabarito das avaliações

> Disponível nesta etapa: módulo 00. As demais respostas serão acrescentadas junto das avaliações.
> Não leia antes de concluir a tentativa.

<a id="modulo-00"></a>
## Módulo 00 — Git e terminal

[Voltar à avaliação](../avaliacoes/modulo-00-git-e-terminal.md)

### Questionário

| Questão | Resposta | Justificativa / divisão do ponto |
|---|---|---|
| 1 | B | `..` representa a pasta pai, relativa à localização atual |
| 2 | C | PATH fornece locais de busca de executáveis |
| 3 | B | `add` preparou B; a edição C ficou só no disco |
| 4 | C | `--staged` atua no índice, mantendo o arquivo no disco |
| 5 | A | `revert` registra a alteração inversa em um novo commit |
| 6 | D | Revogar/trocar impede o uso futuro da credencial exposta |
| 7 | Disco, preparação e commits | 0,25 por cada camada correta e 0,25 por um comando coerente, como `git diff --staged` |
| 8 | `git switch main`, depois `git merge revisao` | 0,5 pela sequência e 0,5 por explicar que a branch atual recebe a integração |
| 9 | apply preserva; pop remove após aplicar com sucesso | 0,5 pela diferença; 0,25 por `-u` incluir novos não rastreados e 0,25 por excluir ignorados |
| 10 | Ignore não age sobre o já rastreado | 0,25 por esse motivo; 0,5 por `git rm --cached -- .env` seguido de commit; 0,25 por explicar que o histórico permanece |

Na questão 9, se `pop` encontra conflito, a entrada não é removida automaticamente. Nas questões
abertas, aceite palavras diferentes com significado correto. Um comando que apaga a cópia local
não satisfaz o requisito da questão 10.

### Solução prática de referência

Na pasta de práticas, crie um laboratório novo. Os nomes abaixo devem estar livres.

```powershell
New-Item -ItemType Directory lab_m00_avaliacao
Set-Location lab_m00_avaliacao
git init -b main
git config user.name "Aluno"
git config user.email "aluno@example.invalid"
Set-Content -Encoding UTF8 README.md "Meta: 30 minutos"
git add README.md
git commit -m "docs: registre a meta inicial"
git switch -c ajuste-meta
Set-Content -Encoding UTF8 README.md "Meta: 45 minutos"
git add README.md
git commit -m "docs: aumente a meta"
$commitDaMeta = git rev-parse HEAD
git switch main
git merge ajuste-meta
Add-Content -Encoding UTF8 README.md "Rever aos domingos"
git add README.md
git restore --staged -- README.md
git diff -- README.md
git diff --staged -- README.md
git stash push -m "revisao semanal em andamento"
git revert --no-edit $commitDaMeta
Set-Content -Encoding UTF8 .gitignore @('.env', '*.jks', 'android/key.properties')
Set-Content -Encoding UTF8 .env "TOKEN=VALOR_FICTICIO_SEM_ACESSO"
git add .gitignore
git commit -m "chore: ignore configuracao e assinatura locais"
git log --oneline --graph --all
git status --short
git stash list
Get-Content README.md
git check-ignore -v .env
git ls-files -- .env
```

**Raciocínio:** guardar a edição incompleta deixa o repositório pronto para a reversão; usar o
hash anotado identifica exatamente a mudança da meta. O commit de reversão permanece no log.
O ignore protege a `.env` nova da inclusão comum, mas não remove conteúdo de commits antigos.

**Conferência:**

- Na etapa dos diffs, somente `git diff` mostra `Rever aos domingos`; o diff preparado está vazio.
- O README final contém 30 minutos; a branch `ajuste-meta` ainda permite consultar a versão 45.
- Existe uma entrada de stash; nela está a edição de revisão semanal.
- O log de `main` tem quatro commits nesta solução: meta inicial, aumento, reversão e ignore.
- O status final está limpo; `check-ignore` aponta `.env` e `ls-files -- .env` não retorna arquivo.

Os commits internos do stash também podem aparecer em `log --all`; eles não são novos commits
da sequência de `main`. Avalie o resultado e a preservação dos dados, não hashes exatos.

**Alternativas:** merge com `--no-ff` acrescenta um commit de integração válido; nesse caso, reverta
o hash da alteração da meta, como solicitado, e ajuste a contagem esperada. Conteúdo escrito pelo
editor e outras mensagens claras são aceitos.

**Erros frequentes:** tentar reverter com alterações locais pendentes; usar `HEAD` depois do commit
de ignore, revertendo a mudança errada; omitir `--staged`; tratar um `.env` rastreado como ignorado.

Use os pesos e os critérios obrigatórios da [avaliação](../avaliacoes/modulo-00-git-e-terminal.md).

<a id="modulo-01"></a>
## Módulo 01 — Lógica e fundamentos

[Voltar à avaliação](../avaliacoes/modulo-01-logica-e-fundamentos.md)

### Questionário

| Questão | Resposta | Justificativa / divisão do ponto |
|---|---|---|
| 1 | B | Receber é entrada; calcular é processamento; mostrar é saída |
| 2 | C | `DateTime.now()` acontece em execução e `final` impede reatribuição |
| 3 | C | `7 ~/ 2` é 3 e `7 % 2` é 1 |
| 4 | C | `continue` pula somente o restante da passagem atual |
| 5 | B | O tipo `int` e `return` disponibilizam o valor à chamada |
| 6 | A | A falha acontece depois que a execução começou |
| 7 | Parâmetro é declarado; argumento é fornecido | 0,5 pela distinção e 0,5 por exemplo coerente |
| 8 | 50 → 25 → 0 | 0,5 pelo rastreamento; 0,25 pela condição falsa em zero; 0,25 por identificar laço infinito sem mudança |
| 9 | `parse` lança; `tryParse` devolve `null` | 0,5 pela diferença e 0,5 por conferir `null` antes de usar `abc` |
| 10 | Três categorias corretas | Aproximadamente 0,33 por definição e exemplo de cada categoria |

### Solução prática de referência

```dart
int? converterPositivo(String texto) {
  final valor = int.tryParse(texto.trim());
  if (valor == null || valor <= 0) return null;
  return valor;
}

void gerarRelatorio(List<String> entradas, int meta) {
  var quantidade = 0;
  var total = 0;

  for (final entrada in entradas) {
    final valor = converterPositivo(entrada);
    if (valor == null) {
      print('Rejeitada: "$entrada"');
      continue;
    }
    quantidade++;
    total += valor;
  }

  print('Válidas: $quantidade');
  print('Total: $total min');
  if (quantidade == 0) {
    print('Média: indisponível');
  } else {
    print('Média: ${(total / quantidade).toStringAsFixed(1)} min');
  }
  print(total >= meta ? 'Meta atingida' : 'Faltam ${meta - total} min');
}

void main() {
  gerarRelatorio(<String>['25', 'abc', '0', '40', '-5', ' 30 '], 120);
  print('---');
  gerarRelatorio(<String>['abc', '0', '-5'], 120);
  print('---');
  gerarRelatorio(<String>['60', '60'], 120);
}
```

No primeiro cenário, as rejeitadas são `abc`, `0` e `-5`; há três válidas, total 95, média
31.7 e falta 25. No segundo, a média fica indisponível e não há divisão por zero. No terceiro,
a meta é atingida exatamente. A função não modifica a lista recebida.

**Alternativas válidas:** retornar um pequeno objeto/record com quantidade e total separa ainda
melhor regra e apresentação, mas records serão ensinados no módulo 04. Usar duas funções para
somar e contar também é correto, embora percorra as entradas duas vezes. Não aceite uma solução
que converta entrada inválida em zero e depois conte zero como sessão válida.

**Erros frequentes:** dividir por `entradas.length`; usar `int.parse`; calcular falta negativa;
declarar acumuladores dentro do laço; arredondar 31.666… sem `toStringAsFixed(1)`.
