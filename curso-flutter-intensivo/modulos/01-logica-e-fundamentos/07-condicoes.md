# Aula 7 — Condições

> **Módulo:** 01 - Lógica e Fundamentos · **Tempo estimado:** 45 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Escrever decisões com `if`, `if/else` e cadeias `else if`.
- Escolher entre `if` e o **operador ternário** `? :`.
- Usar `switch` com vários casos, agrupamento de casos e `default`.
- Combinar condições com `&&`, `||` e `!` sem ambiguidade.
- Reconhecer e evitar os **erros de lógica** mais comuns em condicionais.
- Entender por que uma condição em Dart precisa ser `bool`.

## ✅ Pré-requisitos

- [Aula 5 — Tipos de dados](05-tipos-de-dados.md): `bool`.
- [Aula 6 — Operadores](06-operadores.md): relacionais, lógicos, curto-circuito, `??`.
- Projeto `C:\src\pratica_dart` funcionando.

---

## 📖 Conceito

Até aqui seus programas eram uma linha reta: começavam no topo do `main` e desciam até o fim,
sempre executando tudo. **Estrutura condicional** é o recurso que permite ao programa escolher
caminhos diferentes conforme os dados. É a primeira vez que o seu código deixa de ser uma receita
fixa e passa a se adaptar.

### 1. `if`

```dart
if (condicao) {
  // executa só quando condicao for true
}
```

A **condição** precisa ser uma expressão do tipo `bool`. Em Dart, `if (1)` e `if ('texto')` **não
compilam** — diferentemente de JavaScript e Python. Isso elimina bugs sutis em que um valor
"parecia" verdadeiro.

```dart
if (minutosEstudados >= metaSemanal) {
  print('Meta batida!');
}
```

### 2. `if / else`

```dart
if (minutosEstudados >= metaSemanal) {
  print('Meta batida!');
} else {
  print('Ainda falta.');
}
```

Exatamente um dos dois blocos executa. Nunca os dois, nunca nenhum.

### 3. Cadeia `else if`

Quando há mais de duas saídas possíveis:

```dart
if (percentual >= 100) {
  classificacao = 'Excelente';
} else if (percentual >= 80) {
  classificacao = 'Bom';
} else if (percentual >= 50) {
  classificacao = 'Regular';
} else {
  classificacao = 'Precisa melhorar';
}
```

Três regras que evitam a maioria dos erros:

1. O Dart testa **de cima para baixo** e para no **primeiro** `true`.
2. Por isso a ordem importa: vá **do caso mais específico para o mais geral**. Se `percentual >= 50`
   viesse primeiro, ninguém jamais seria "Excelente", porque 100 também é maior que 50.
3. O `else` final é a rede de segurança: sem ele, entradas fora do previsto não caem em lugar
   nenhum.

### 4. Chaves `{ }`: use sempre

O Dart permite omitir as chaves quando o corpo tem uma linha só:

```dart
if (bateuMeta) print('Parabéns');
```

Funciona — mas é a origem de um bug clássico:

```dart
if (bateuMeta)
  print('Parabéns');
  print('Continue assim');   // executa SEMPRE, não faz parte do if
```

A indentação engana o olho; o compilador segue a regra, não o alinhamento. **Regra do curso:
sempre use chaves**, mesmo com uma linha. É também o que o `flutter_lints ^6.0.0` recomenda
(`curly_braces_in_flow_control_structures`).

### 5. Operador ternário `? :`

O **ternário** é um `if/else` que **produz um valor** em vez de executar blocos:

```dart
condicao ? valorSeVerdadeiro : valorSeFalso
```

```dart
final String status = bateuMeta ? 'concluída' : 'em andamento';
```

Equivale a quatro linhas de `if/else`, mas cabe em uma — e, o que importa mais, pode ser usado
onde um **valor** é esperado: dentro de uma interpolação, como argumento, na inicialização de um
`final`.

Quando usar cada um:

| Use`if/else`                            | Use ternário                              |
| ----------------------------------------- | ------------------------------------------ |
| quando os ramos**executam ações** | quando os ramos**produzem um valor** |
| quando há mais de dois caminhos          | quando há exatamente dois                 |
| quando cada ramo tem várias linhas       | quando cada ramo é curto                  |

> ⚠️ Ternários aninhados (`a ? b : c ? d : e`) compilam e são quase sempre ilegíveis. Se você
> precisa de dois níveis, use `if/else` ou `switch`.

### 6. `switch`

`switch` compara **um mesmo valor** contra vários casos possíveis. É mais legível que uma cadeia
`else if` quando todos os testes são de igualdade sobre a mesma variável.

```dart
switch (diaDaSemana) {
  case 'sab':
    metaDoDia = 120;
    break;
  case 'dom':
    metaDoDia = 0;
    break;
  default:
    metaDoDia = 240;
}
```

Pontos obrigatórios:

- Cada `case` com corpo **precisa terminar** em `break`, `return`, `continue` ou `throw`. Em Dart,
  esquecer o `break` é **erro de compilação**, não um bug silencioso como em C.
- Um `case` **vazio** cai no seguinte. É assim que se agrupam casos:

```dart
case 'seg':
case 'ter':
case 'qua':
  metaDoDia = 240;
  break;
```

- `default` trata tudo o que não casou. Coloque-o por último.

> 🔭 **Prévia:** o Dart 3 também tem a **expressão** `switch`, que devolve um valor:
>
> ```dart
> final String sigla = switch (classificacao) {
>   'Excelente' => 'A',
>   'Bom' => 'B',
>   _ => 'C',
> };
> ```
>
> Ela vem junto com *patterns* e é estudada em
> [`04-dart-avancado/05-patterns-e-switch.md`](../04-dart-avancado/05-patterns-e-switch.md). Neste
> módulo usamos apenas o `switch` em forma de comando.

### 7. Combinando condições

```dart
if (bateuMeta && fezExercicios) { }          // os dois
if (bateuMeta || fezExercicios) { }          // pelo menos um
if (!bateuMeta) { }                          // o contrário
if (bateuMeta && (fezExercicios || fezRevisao)) { }  // parênteses mandam
```

Lembre do **curto-circuito** da [Aula 6](06-operadores.md): em `a && b`, se `a` for `false`, `b`
nem é avaliado. Isso permite proteger acessos:

```dart
if (minutos != null && minutos > 0) { }
```

Aqui a segunda parte só executa quando `minutos` não é nulo — e é justamente isso que torna a
comparação segura.

---

## 💡 Analogia

Um `if/else` é uma **bifurcação na estrada**: existe uma placa (a condição), e você vai para a
esquerda ou para a direita. Nunca para os dois lados, nunca fica parado.

A cadeia `else if` é uma **sequência de cancelas** na mesma estrada: você tenta a primeira; se ela
não abrir, tenta a segunda; e assim por diante. Assim que uma abre, você passa e **não olha mais**
as outras — por isso colocar a cancela mais larga no começo faz com que as seguintes nunca sejam
usadas.

O `switch` é o **painel do elevador**: você aperta o número do andar e o elevador vai direto
àquele andar, sem passar por cada botão. O `default` é o térreo para onde ele vai quando o botão
apertado não existe.

O ternário é a **placa de mão única com duas setas**: não é um caminho a percorrer, é uma escolha
instantânea entre dois valores.

---

## 🧪 Exemplo mínimo

Este exemplo corrige o defeito que ficou pendente na [Aula 3](03-algoritmos-e-decomposicao.md): o
programa que dizia "faltam -60 min".

> Arquivo: `C:\src\pratica_dart\bin\aula07_minimo.dart`

```dart
void main() {
  const int estudado = 810;
  const int meta = 750;

  if (estudado >= meta) {
    print('Meta batida! Você excedeu em ${estudado - meta} min.');
  } else {
    print('Faltam ${meta - estudado} min para a meta.');
  }
}
```

```powershell
dart run bin/aula07_minimo.dart
```

```text
Meta batida! Você excedeu em 60 min.
```

Troque `estudado` para `690` e execute de novo: agora sai `Faltam 60 min para a meta.` O mesmo
programa, duas mensagens corretas. É isso que a decisão acrescenta.

---

## 📱 Aplicando no Flutter

No Flutter, a interface **é** uma expressão. Decidir o que mostrar é decidir qual widget construir,
e para isso o ternário é usado o tempo todo.

- O padrão mais comum de todos é escolher o widget conforme o estado:
  `carregando ? const CircularProgressIndicator() : ListaDeMaterias()`. Você vai escrever isso em
  [`06-widgets-e-layouts/12-estados-de-ui.md`](../06-widgets-e-layouts/12-estados-de-ui.md), que
  trata dos quatro estados de toda tela: carregando, vazio, erro e dados.
- Habilitar ou desabilitar um botão é uma condição:
  `onPressed: formularioValido ? _salvar : null` — passar `null` desabilita o botão. Isso está em
  [`07-navegacao-e-formularios/08-ux-de-formularios.md`](../07-navegacao-e-formularios/08-ux-de-formularios.md).
- Escolher tema claro ou escuro é uma condição sobre o brilho do sistema, em
  [`06-widgets-e-layouts/07-cores-temas-modo-escuro.md`](../06-widgets-e-layouts/07-cores-temas-modo-escuro.md).
- Adaptar um controle para 🤖 Android ou 🍎 iOS é uma condição sobre a plataforma, em
  [`11-recursos-nativos/09-material-x-cupertino.md`](../11-recursos-nativos/09-material-x-cupertino.md).
- Já o `switch` volta com força no [Módulo 08](../08-estado-e-arquitetura/README.md): o `AsyncValue`
  do Riverpod 3 modela carregando/erro/dados, e você decide o que desenhar em cada caso — veja
  [`08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md`](../08-estado-e-arquitetura/07-asyncnotifier-e-asyncvalue.md).

---

## 💻 Código completo

> **Arquivo:** `C:\src\pratica_dart\bin\aula07_condicoes.dart`
> **Como executar:** `dart run bin/aula07_condicoes.dart` (a partir de `C:\src\pratica_dart`)

```dart
// bin/aula07_condicoes.dart
// Aula 7 — Condições: if, else if, ternário, switch e combinações.

void main() {
  // ---------- Dados da semana ----------
  const int minutosEstudados = 690;
  const int metaSemanal = 750;
  const String diaDaSemana = 'qua';
  const bool fezExercicios = true;
  const bool fezRevisao = false;

  print('=== 1) IF / ELSE ===');
  if (minutosEstudados >= metaSemanal) {
    print('Meta batida! Excedeu em ${minutosEstudados - metaSemanal} min.');
  } else {
    print('Faltam ${metaSemanal - minutosEstudados} min para a meta.');
  }

  print('');
  print('=== 2) CADEIA ELSE IF ===');
  final double percentual = (minutosEstudados / metaSemanal) * 100;
  String classificacao;
  if (percentual >= 100) {
    classificacao = 'Excelente';
  } else if (percentual >= 80) {
    classificacao = 'Bom';
  } else if (percentual >= 50) {
    classificacao = 'Regular';
  } else {
    classificacao = 'Precisa melhorar';
  }
  print('Percentual: ${percentual.toStringAsFixed(1)}%');
  print('Classificação: $classificacao');

  print('');
  print('=== 3) TERNÁRIO ===');
  final bool bateuMeta = minutosEstudados >= metaSemanal;
  final String status = bateuMeta ? 'concluída' : 'em andamento';
  final String rotulo = bateuMeta ? 'Excedeu em' : 'Faltam';
  final int diferenca =
      bateuMeta ? minutosEstudados - metaSemanal : metaSemanal - minutosEstudados;
  print('Semana $status.');
  print('$rotulo $diferenca min.');

  print('');
  print('=== 4) SWITCH ===');
  int metaDoDia;
  switch (diaDaSemana) {
    case 'seg':
    case 'ter':
    case 'qua':
    case 'qui':
    case 'sex':
      metaDoDia = 240;
      break;
    case 'sab':
      metaDoDia = 120;
      break;
    case 'dom':
      metaDoDia = 0;
      break;
    default:
      metaDoDia = -1;
  }
  if (metaDoDia < 0) {
    print('Dia "$diaDaSemana" não reconhecido.');
  } else if (metaDoDia == 0) {
    print('Hoje ($diaDaSemana) é dia de descanso.');
  } else {
    print('Meta de hoje ($diaDaSemana): $metaDoDia min.');
  }

  print('');
  print('=== 5) CONDIÇÕES COMBINADAS ===');
  if (bateuMeta && fezExercicios && fezRevisao) {
    print('Semana perfeita: meta, exercícios e revisão.');
  } else if (fezExercicios && fezRevisao) {
    print('Praticou bem, mas faltou tempo de estudo.');
  } else if (fezExercicios || fezRevisao) {
    print('Você praticou em parte. Falta fechar o ciclo.');
  } else {
    print('Semana só de leitura: pratique mais.');
  }

  // Proteção com curto-circuito: o segundo teste só roda se o primeiro passar.
  final int? minutosDeOntem = int.tryParse('abc');
  if (minutosDeOntem != null && minutosDeOntem > 0) {
    print('Ontem: $minutosDeOntem min.');
  } else {
    print('Não há registro válido de ontem.');
  }
}
```

Saída esperada:

```text
=== 1) IF / ELSE ===
Faltam 60 min para a meta.

=== 2) CADEIA ELSE IF ===
Percentual: 92.0%
Classificação: Bom

=== 3) TERNÁRIO ===
Semana em andamento.
Faltam 60 min.

=== 4) SWITCH ===
Meta de hoje (qua): 240 min.

=== 5) CONDIÇÕES COMBINADAS ===
Você praticou em parte. Falta fechar o ciclo.
Não há registro válido de ontem.
```

---

## 🔍 Explicando o código

### Por que `Bom` e não `Excelente`

`percentual` vale `92.0`. O Dart testa `92.0 >= 100` → `false`; depois `92.0 >= 80` → `true`, entra
e **para**. As comparações seguintes nem são avaliadas. Se a ordem estivesse invertida (`>= 50`
primeiro), qualquer valor acima de 50 cairia em "Regular" e os outros ramos seriam código morto.

### `String classificacao;` sem valor inicial

Declarar sem inicializar é permitido porque **todos** os caminhos do `if/else` atribuem um valor
antes do primeiro uso. O Dart faz essa verificação (chamada *definite assignment*, atribuição
definida) em tempo de compilação. Se você apagar o `else` final, o programa deixa de compilar:

```text
Error: Non-nullable variable 'classificacao' must be assigned before it can be used.
```

Esse erro é um presente: ele mostra que existe um caminho em que a variável ficaria sem valor.

### O ternário resolvendo "faltam −60"

```dart
final String rotulo = bateuMeta ? 'Excedeu em' : 'Faltam';
final int diferenca =
    bateuMeta ? minutosEstudados - metaSemanal : metaSemanal - minutosEstudados;
```

Duas decisões coordenadas garantem que o rótulo e o número sempre combinem. A subtração é feita na
ordem que produz número positivo nos dois casos — o defeito da Aula 3 desaparece.

### Casos agrupados no `switch`

```dart
case 'seg':
case 'ter':
case 'qua':
```

Os três primeiros `case` estão **vazios** (não têm corpo), então a execução "escorrega" até o
primeiro corpo encontrado. É o jeito idiomático de dizer "estes cinco casos fazem a mesma coisa".
Note que isso só vale para casos vazios: se `case 'seg':` tivesse uma linha de código, o Dart
exigiria um `break`.

### `default: metaDoDia = -1;`

`-1` aqui é um **valor sentinela**: um valor fora do domínio válido usado para sinalizar "não sei".
Como nenhuma meta real pode ser negativa, o `if (metaDoDia < 0)` logo abaixo identifica a situação.
É uma técnica comum, mas com limite: quando o "não sei" precisa carregar informação (por exemplo,
*por que* falhou), o certo é usar tipos próprios — assunto de
[`04-dart-avancado/06-sealed-classes.md`](../04-dart-avancado/06-sealed-classes.md).

### A proteção com `&&`

```dart
if (minutosDeOntem != null && minutosDeOntem > 0) {
```

`int.tryParse('abc')` devolve `null`. O primeiro teste falha, o curto-circuito impede que
`minutosDeOntem > 0` seja avaliado, e o programa segue pelo `else`. Sem a primeira metade, o Dart
nem compilaria a comparação — `int?` não pode ser comparado com `>` diretamente.

---

## ⚠️ Erros comuns

**1. Usar `=` em vez de `==`** — `if (minutos = 750)` não compila em Dart, porque o resultado de
uma atribuição não é `bool`. Em C e Java isso compilaria e criaria um bug silencioso.

**2. Ordem errada na cadeia `else if`** — colocar a faixa mais ampla primeiro torna as seguintes
inalcançáveis. Sintoma: todo mundo recebe a mesma classificação.

**3. Esquecer as chaves**

```dart
if (bateuMeta)
  print('Parabéns');
  print('Continue');   // sempre executa
```

Correção: sempre `{ }`.

**4. Condição impossível** — `if (minutos > 100 && minutos < 50)` nunca é verdadeira. Provavelmente
você queria `||`. O analisador não avisa: é erro de **lógica**, não de sintaxe.

**5. Encadear comparações** — `if (0 < minutos < 100)` não compila. Escreva
`if (minutos > 0 && minutos < 100)`.

**6. Comparar `double` com `==`**

```dart
if (0.1 + 0.2 == 0.3) { }   // false!
```

Por causa do arredondamento de ponto flutuante (Aula 5). Compare com tolerância —
`if ((valor - alvo).abs() < 0.0001)` — ou, melhor, trabalhe com `int`.

**7. `else` sem par correspondente** — em cadeias longas, o `else` pertence sempre ao `if` mais
próximo que ainda não tem um. Chaves bem colocadas eliminam a dúvida.

**8. Esquecer o `default`** — sem ele, valores inesperados simplesmente não fazem nada, e o
programa segue com a variável antiga. Sempre pense: "e se vier algo que eu não previ?".

**9. Testar `bool` contra `true`** — `if (bateuMeta == true)` funciona, mas é redundante. Escreva
`if (bateuMeta)` e `if (!bateuMeta)`.

---

## 🛠️ Exercício guiado

Você vai escrever um **classificador de sessão de estudo** que decide a mensagem conforme a
duração.

**Passo 1.** Crie `bin/aula07_guiado.dart` com a entrada e a primeira decisão:

```dart
void main() {
  const String digitado = '95';
  final int minutos = int.tryParse(digitado) ?? -1;

  if (minutos < 0) {
    print('Entrada inválida: "$digitado" não é um número.');
    return;   // encerra o main aqui
  }
```

`return` dentro de `main` encerra o programa naquele ponto. É a forma mais limpa de tratar entrada
inválida: valide primeiro, siga depois.

**Passo 2.** Classifique a sessão com uma cadeia `else if`:

```dart
  String tipo;
  if (minutos == 0) {
    tipo = 'nenhuma sessão';
  } else if (minutos < 25) {
    tipo = 'sessão curta';
  } else if (minutos < 60) {
    tipo = 'sessão padrão';
  } else if (minutos < 120) {
    tipo = 'sessão longa';
  } else {
    tipo = 'maratona';
  }
  print('$minutos min = $tipo');
```

Teste de mesa com `95`: falha em `== 0`, falha em `< 25`, falha em `< 60`, passa em `< 120` →
`sessão longa`.

**Passo 3.** Acrescente uma recomendação com ternário e uma condição composta:

```dart
  final bool precisaPausa = minutos >= 50;
  final String recomendacao =
      precisaPausa ? 'Faça 15 min de pausa.' : 'Pode emendar a próxima.';
  print(recomendacao);

  final bool sessaoProdutiva = minutos >= 25 && minutos <= 120;
  print('Sessão produtiva? $sessaoProdutiva');
}
```

**Passo 4.** Execute e confira:

```powershell
dart run bin/aula07_guiado.dart
```

```text
95 min = sessão longa
Faça 15 min de pausa.
Sessão produtiva? true
```

**Passo 5.** Teste os limites — é aqui que os bugs moram. Rode com `'0'`, `'24'`, `'25'`, `'60'`,
`'120'` e `'abc'`, e confira cada resultado contra a sua leitura do código. Repare que `'120'` cai
em "maratona" (porque `120 < 120` é falso) e `'abc'` é barrado logo no início.

**Passo 6.** Salve:

```powershell
git add .
git commit -m "aula 07: classificador de sessao com if, else if e ternario"
```

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/01-logica-e-fundamentos.md](../../exercicios/01-logica-e-fundamentos.md)

Faça em especial os de **Aplicação** (escrever a cadeia de decisão de um problema novo) e os de
**Correção de bugs** (ordem errada de `else if`, chaves ausentes, condição impossível).

---

## 🏆 Desafio opcional

Escreva `bin/aula07_desafio.dart`, um **assistente de plano diário** que recebe (em constantes) o
dia da semana, os minutos já estudados hoje e se a pessoa dormiu bem, e então:

1. define a meta do dia com `switch` (dias úteis 240, sábado 120, domingo 0, `default` sinaliza
   erro);
2. classifica o progresso do dia com `else if` (0%, até 50%, até 99%, 100% ou mais);
3. usa ternário para montar a frase "Faltam X min" ou "Excedeu em X min";
4. combina condições para decidir a recomendação final: quem dormiu mal **e** já passou de 180
   minutos recebe "pare por hoje"; quem dormiu bem **e** está abaixo da meta recebe "dá para mais
   uma sessão"; os demais recebem uma mensagem neutra.

Restrições: use chaves em **todos** os blocos; trate o caso de dia inválido; e escreva o teste de
mesa de três cenários diferentes **antes** de executar.

---

## 📌 Resumo

- **Condicional** faz o programa escolher caminhos conforme os dados. A condição precisa ser
  `bool` — o Dart não aceita "valor que parece verdadeiro".
- `if` executa quando verdadeiro; `if/else` garante exatamente um dos dois caminhos.
- A cadeia `else if` testa de cima para baixo e **para no primeiro `true`**: ordene do caso mais
  específico para o mais geral e feche com `else`.
- Use **chaves sempre**, mesmo em uma linha.
- O **ternário** `condicao ? a : b` produz um **valor** e cabe onde um valor é esperado; use-o
  para dois caminhos curtos, nunca aninhado.
- `switch` compara um valor contra vários casos; todo `case` com corpo exige `break` (ou `return`,
  `continue`, `throw`), e casos **vazios** agrupam. `default` trata o resto.
- Combine condições com `&&`, `||`, `!` e parênteses; aproveite o **curto-circuito** para proteger
  acessos, como `x != null && x > 0`.
- Erros de lógica (ordem errada, condição impossível, `double` com `==`) não são apontados pelo
  compilador. Só teste de mesa e testes de limite os encontram.

---

## ☑️ Checklist de domínio

- [X] Escrevo `if/else` e sei dizer por que exatamente um dos blocos executa.
- [X] Ordeno uma cadeia `else if` corretamente e explico por que a ordem importa.
- [X] Explico o erro `Non-nullable variable ... must be assigned before it can be used`.
- [X] Converto um `if/else` curto em ternário e vice-versa.
- [X] Escrevo um `switch` com casos agrupados e `default`, sem esquecer `break`.
- [X] Uso `&&` para proteger um acesso que poderia falhar.
- [X] Reconheço uma condição impossível e uma comparação encadeada inválida.
- [X] Sei por que não se compara `double` com `==`.
- [X] Testei o programa nos **limites** (valores de fronteira), não só no caso feliz.
- [X] Executei `bin/aula07_condicoes.dart` e a saída bateu com a esperada.

---

## 📚 Referências oficiais

- [Dart — Branches (`if`, `if-case`, `switch`)](https://dart.dev/language/branches)
- [Dart — Operadores condicionais](https://dart.dev/language/operators#conditional-expressions)
- [Dart — `switch` e patterns](https://dart.dev/language/patterns)
- [Dart — Regra de lint `curly_braces_in_flow_control_structures`](https://dart.dev/tools/linter-rules/curly_braces_in_flow_control_structures)

---

| ⬅️ Anterior                           | 🏠 Módulo         | ➡️ Próxima                             |
| --------------------------------------- | ------------------ | ----------------------------------------- |
| [Aula 6 — Operadores](06-operadores.md) | [README](README.md) | [Aula 8 — Repetições](08-repeticoes.md) |
