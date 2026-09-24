# Aula 1 — Classes e objetos

> **Módulo:** 03 - Dart Intermediário · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Explicar com suas palavras o que é uma **classe**, um **objeto** e uma **instância**.
- Declarar uma classe em Dart com **campos** (dados) e **métodos** (ações).
- Criar objetos sem a palavra `new` e entender por que ela sumiu.
- Usar a palavra-chave `this` e saber exatamente a que ela se refere.
- Justificar **por que** Orientação a Objetos organiza melhor um programa do que variáveis soltas.
- Escrever o primeiro modelo de domínio do curso: a classe `Materia`.

## ✅ Pré-requisitos

- [Módulo 02 — Dart Básico](../02-dart-basico/README.md) concluído, em especial
  [`05-null-safety.md`](../02-dart-basico/05-null-safety.md),
  [`07-funcoes-em-dart.md`](../02-dart-basico/07-funcoes-em-dart.md) e
  [`08-listas.md`](../02-dart-basico/08-listas.md).
- Pasta de prática criada (veja o [README do módulo](README.md)).
- Dart **3.13.1** funcionando no terminal.

---

## 📖 Conceito

### O problema que a Orientação a Objetos resolve

No módulo 02 você guardou informações assim:

```dart
String nomeMateria = 'Dart';
int minutosEstudados = 120;
int metaSemanal = 300;
```

Funciona para **uma** matéria. Agora tente guardar **três** matérias:

```dart
String nome1 = 'Dart';
int minutos1 = 120;
int meta1 = 300;

String nome2 = 'Flutter';
int minutos2 = 180;
int meta2 = 600;

String nome3 = 'Lógica';
int minutos3 = 45;
int meta3 = 120;
```

Repare no estrago:

1. **Nada amarra `nome2` a `minutos2`.** São três variáveis independentes que só estão juntas na
   sua cabeça. Se você passar `nome2` e `minutos3` para uma função, o Dart aceita numa boa e o
   programa fica errado silenciosamente.
2. **Não dá para crescer.** Com 40 matérias você teria 120 variáveis.
3. **O comportamento fica solto.** A regra "somar minutos estudados" vira uma função separada que
   não tem dono, e qualquer pedaço do programa pode alterar `minutos1` por engano.

A **Orientação a Objetos** (OO — estilo de programação em que dados e as ações sobre esses dados
ficam juntos numa mesma unidade) resolve os três problemas de uma vez: você cria **um tipo novo**
chamado `Materia` que já carrega nome, minutos, meta **e** as operações válidas sobre eles.

### Classe, objeto e instância

Três palavras que parecem sinônimos e não são:

| Termo | O que é | Exemplo |
|---|---|---|
| **Classe** | O **molde**. Um tipo novo que você declara com a palavra `class`. Existe uma vez no código. Não guarda dados de ninguém. | `class Materia { ... }` |
| **Objeto** | O **produto feito com o molde**. Existe em memória enquanto o programa roda. Cada objeto tem seus próprios valores. | a matéria "Dart" com 120 minutos |
| **Instância** | Sinônimo de objeto, usado quando queremos dizer *"objeto daquela classe específica"*. "Um objeto do tipo `Materia`" = "uma instância de `Materia`". | `dart` é uma instância de `Materia` |

**Instanciar** é o verbo: criar um objeto a partir de uma classe.

### Campos e métodos

Dentro de uma classe você declara duas coisas:

- **Campo** (também chamado de *atributo* ou *propriedade*): uma variável que pertence a cada
  objeto. Cada instância tem a sua cópia.
- **Método**: uma função que pertence à classe. Dentro dela, você acessa os campos **daquele**
  objeto diretamente, sem passar nada por parâmetro.

```dart
class Materia {
  String nome = '';        // campo
  int minutosEstudados = 0; // campo

  void registrarEstudo(int minutos) { // método
    minutosEstudados = minutosEstudados + minutos;
  }
}
```

### Sem `new`: o construtor implícito

Em Java ou C# você escreveria `new Materia()`. Em Dart, a palavra `new` é **opcional desde o Dart 2
e hoje é considerada ruído** — o analisador (`dart analyze`, a ferramenta que lê seu código e
aponta problemas sem executá-lo) inclusive avisa quando você a usa. Escreva sempre:

```dart
final dart = Materia();   // ✅ jeito Dart
final dart = new Materia(); // ❌ funciona, mas é estilo antigo
```

Quando você **não escreve nenhum construtor**, o Dart cria automaticamente um **construtor padrão
sem parâmetros** com o mesmo nome da classe. É por isso que `Materia()` funciona mesmo sem você
declarar nada. Na [Aula 2](02-construtores.md) você vai escrever os seus.

### `this` — o próprio objeto

`this` é uma referência ao **objeto em que o método está rodando agora**. Dentro de
`dart.registrarEstudo(90)`, `this` é o objeto `dart`. Dentro de `flutter.registrarEstudo(60)`,
o mesmo código, `this` é o objeto `flutter`.

Você **só precisa** escrever `this` quando há ambiguidade — tipicamente quando um parâmetro tem o
mesmo nome de um campo:

```dart
class Materia {
  String nome = '';

  void renomear(String nome) {
    this.nome = nome; // this.nome = o campo; nome = o parâmetro
  }
}
```

Fora desse caso, escrever `this.` é redundante e o lint `unnecessary_this` reclama.

---

## 💡 Analogia

Pense numa **forma de bolo** e nos **bolos**.

- A **forma** (classe) define o formato: redonda, com furo no meio. Ela não é comestível e existe
  uma só na cozinha.
- Cada **bolo** (objeto) sai da mesma forma, mas tem o seu próprio recheio: um de chocolate, um de
  cenoura. Comer um bolo não afeta o outro.
- **Instanciar** é assar: usar a forma para produzir mais um bolo.

Onde a analogia **para**: a forma de bolo não sabe fazer nada sozinha. Uma classe, sim — ela carrega
os **métodos**, ou seja, as receitas de como o bolo pode ser alterado. É como se a forma viesse com
as instruções coladas no fundo.

---

## 🧪 Exemplo mínimo

> **Arquivo:** `bin/exemplo_classe.dart`
> **Como executar:** `dart run bin/exemplo_classe.dart`

```dart
class Materia {
  String nome = 'Sem nome';
  int minutosEstudados = 0;

  void registrarEstudo(int minutos) {
    minutosEstudados += minutos;
  }
}

void main() {
  final dart = Materia();
  dart.nome = 'Dart';
  dart.registrarEstudo(90);

  print('${dart.nome} tem ${dart.minutosEstudados} minutos.');
}
```

Saída:

```text
Dart tem 90 minutos.
```

Três coisas aconteceram aqui:

1. `Materia()` chamou o **construtor padrão implícito** e devolveu um objeto novo.
2. `dart.nome = 'Dart'` escreveu em um campo **daquele** objeto.
3. `dart.registrarEstudo(90)` executou um método **com `this` valendo `dart`**.

---

## 📱 Aplicando no Flutter

Esta é a aula mais importante do módulo para o seu futuro no Flutter, por um motivo direto:

> **No Flutter, absolutamente tudo que aparece na tela é um objeto de uma classe.**

Um botão é uma instância da classe `ElevatedButton`. Um texto é uma instância de `Text`. Uma tela
inteira é uma classe que **você** escreve. Quando, no
[Módulo 05 — StatelessWidget](../05-introducao-ao-flutter/04-statelesswidget.md), você encontrar
algo assim:

```dart
class TelaDeMaterias extends StatelessWidget {
  const TelaDeMaterias({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Minhas matérias');
  }
}
```

...você já vai reconhecer o essencial: **isso é uma classe**, com um construtor e um método
chamado `build`. O `extends` vem na [Aula 4](04-heranca-e-polimorfismo.md), o `@override` também,
o `const` na [Aula 2](02-construtores.md). Nada disso é "coisa de Flutter": é Dart puro.

E a classe `Materia` que você escreve hoje é, literalmente, a mesma classe que vai virar o modelo
de domínio do app final **Foco**, em
[`lib/features/materias/domain/materia.dart`](../../projetos/03-projeto-final-multiplataforma/04-etapa-2-dominio-e-dados.md).
Você não está fazendo um exercício descartável — está escrevendo a primeira peça do projeto final.

---

## 💻 Código completo

> **Arquivo:** `bin/01_classes_e_objetos.dart`
> **Como executar:** `dart run bin/01_classes_e_objetos.dart`

```dart
// Aula 1 do Módulo 03 — Classes e objetos.
// Primeiro modelo de domínio do curso: a classe Materia.

/// Representa uma matéria de estudo do organizador "Foco".
///
/// Um comentário iniciado por três barras (///) é um "doc comment":
/// o editor mostra esse texto quando você passa o mouse sobre a classe.
class Materia {
  // ----- CAMPOS -----
  // Cada objeto Materia tem a SUA cópia destes três valores.
  // Os valores à direita do "=" são os valores iniciais: sem eles, um campo
  // não anulável ficaria sem valor e o programa nem compilaria.
  String nome = 'Sem nome';
  int minutosEstudados = 0;
  int metaSemanalEmMinutos = 60;

  // ----- CONSTRUTOR -----
  // Recebe os três valores e os copia para os campos do objeto.
  // "this.nome" é o CAMPO; "nome" sozinho é o PARÂMETRO.
  Materia(String nome, int minutosEstudados, int metaSemanalEmMinutos) {
    this.nome = nome;
    this.minutosEstudados = minutosEstudados;
    this.metaSemanalEmMinutos = metaSemanalEmMinutos;
  }

  // ----- MÉTODOS -----

  /// Soma [minutos] ao total já estudado desta matéria.
  void registrarEstudo(int minutos) {
    if (minutos <= 0) {
      print('⚠️  Ignorado: $minutos minutos não é um valor válido.');
      return;
    }
    minutosEstudados += minutos;
  }

  /// Quanto da meta semanal já foi cumprido, em porcentagem.
  double percentualDaMeta() {
    if (metaSemanalEmMinutos <= 0) {
      return 0.0;
    }
    return minutosEstudados / metaSemanalEmMinutos * 100;
  }

  /// Verdadeiro quando a meta da semana já foi atingida ou ultrapassada.
  bool metaAtingida() {
    return minutosEstudados >= metaSemanalEmMinutos;
  }

  /// Quantos minutos ainda faltam. Nunca devolve número negativo.
  int minutosRestantes() {
    final falta = metaSemanalEmMinutos - minutosEstudados;
    return falta > 0 ? falta : 0;
  }

  /// Uma linha de texto descrevendo o estado atual da matéria.
  String resumo() {
    final marca = metaAtingida() ? '✅' : '⏳';
    final percentual = percentualDaMeta().toStringAsFixed(1);
    return '$marca $nome: $minutosEstudados/$metaSemanalEmMinutos min ($percentual%)';
  }
}

void main() {
  // Criando três OBJETOS (instâncias) a partir da mesma CLASSE.
  final dart = Materia('Dart', 0, 300);
  final flutter = Materia('Flutter', 120, 600);
  final logica = Materia('Lógica', 45, 120);

  // Uma lista de objetos é uma lista como qualquer outra.
  final materias = <Materia>[dart, flutter, logica];

  // Cada chamada altera APENAS o objeto à esquerda do ponto.
  dart.registrarEstudo(90);
  dart.registrarEstudo(30);
  flutter.registrarEstudo(60);
  logica.registrarEstudo(-10); // valor inválido: será recusado

  print('=== Minhas matérias ===');
  for (final materia in materias) {
    print(materia.resumo());
  }

  // Somando um campo de todos os objetos da lista.
  var total = 0;
  for (final materia in materias) {
    total += materia.minutosEstudados;
  }
  print('');
  print('Total estudado: $total minutos');
  print('Faltam para Dart: ${dart.minutosRestantes()} minutos');

  // Dois objetos com os MESMOS valores continuam sendo objetos DIFERENTES.
  final outraDart = Materia('Dart', 120, 300);
  print('');
  print('São o mesmo objeto na memória? ${identical(dart, outraDart)}');
  print('São iguais com == ?             ${dart == outraDart}');
  print('Tipo em tempo de execução:      ${dart.runtimeType}');
}
```

**Saída esperada:**

```text
⚠️  Ignorado: -10 minutos não é um valor válido.
=== Minhas matérias ===
⏳ Dart: 120/300 min (40.0%)
⏳ Flutter: 180/600 min (30.0%)
⏳ Lógica: 45/120 min (37.5%)

Total estudado: 345 minutos
Faltam para Dart: 180 minutos

São o mesmo objeto na memória? false
São iguais com == ?             false
Tipo em tempo de execução:      Materia
```

---

## 🔍 Explicando o código

**`class Materia { ... }`**
Declara um **tipo novo**. A partir daqui, `Materia` é um tipo tão legítimo quanto `int` ou `String`:
você pode escrever `Materia m`, `List<Materia>`, `Map<String, Materia>`.

**`String nome = 'Sem nome';`**
Um campo com **valor inicial**. Esse valor inicial não é decoração: em Dart, com *null safety*
(o sistema que impede que uma variável seja nula sem você autorizar), um campo do tipo `String`
(não anulável) **precisa** ter um valor antes de o corpo do construtor começar a rodar. Sem o
`= 'Sem nome'`, o compilador para com:

```text
Non-nullable instance field 'nome' must be initialized.
```

Na [Aula 2](02-construtores.md) você aprende a forma curta que elimina essa redundância.

**`Materia(String nome, int minutosEstudados, int metaSemanalEmMinutos) { ... }`**
Um método especial: tem o **mesmo nome da classe** e **não declara tipo de retorno**. É o
**construtor**. Ao declarar um construtor seu, o construtor padrão implícito deixa de existir — por
isso `Materia()` sem argumentos agora dá erro.

**`this.nome = nome;`**
Aqui `this` é obrigatório. Sem ele, `nome = nome` atribuiria o parâmetro a ele mesmo e o campo
continuaria valendo `'Sem nome'` — um bug silencioso. O analisador ajuda: ele emite o aviso
`assignment_to_local_variable` ... mas não conte com isso, entenda a regra.

**`minutosEstudados += minutos;`**
Dentro do método, `minutosEstudados` sem `this.` é o campo do objeto atual. É o mesmo que
`this.minutosEstudados += minutos`, só que sem ruído.

**`double percentualDaMeta()`**
Repare no `return 0.0;` e não `return 0;`. Como o método promete devolver `double`, devolver o
literal inteiro `0` funcionaria por conversão implícita de `int` para `double` em Dart, mas escrever
`0.0` deixa a intenção explícita e evita confusão em expressões condicionais.

**`return falta > 0 ? falta : 0;`**
O **operador ternário**: `condição ? valorSeVerdadeiro : valorSeFalso`. Lê-se "se falta é maior que
zero, devolva falta; senão, devolva zero".

**`final materias = <Materia>[dart, flutter, logica];`**
Uma `List<Materia>`. Os colchetes angulares `<Materia>` dizem ao Dart o tipo dos elementos —
isso é *generics*, assunto da [Aula 8](08-generics.md).

**`for (final materia in materias)`**
A cada volta, `materia` aponta para **um dos objetos da lista** — não para uma cópia. Chamar
`materia.registrarEstudo(10)` aqui alteraria o objeto original.

**`identical(dart, outraDart)` → `false`**
`identical` pergunta: "são o **mesmo endereço** de memória?". Como `outraDart` foi criada com outro
`Materia(...)`, é outro objeto. Mesmos valores, objetos diferentes.

**`dart == outraDart` → `false`**
Por padrão, `==` em Dart compara **identidade**, não conteúdo. Fazer `==` comparar valores é
trabalho seu, e é exatamente o que a [Aula 3](03-encapsulamento.md) ensina com `Object.hash`.

**`dart.runtimeType` → `Materia`**
Todo objeto em Dart sabe dizer sua própria classe em tempo de execução. Útil para depurar.

---

## ⚠️ Erros comuns

**1. Esquecer os parênteses ao instanciar**

```dart
final dart = Materia; // ❌
```
Isso não cria objeto nenhum: guarda a **própria classe** como valor (um `Type`). O erro aparece
depois, estranho:
```text
The getter 'nome' isn't defined for the type 'Type'.
```
✅ Correto: `final dart = Materia('Dart', 0, 300);`

**2. Campo não anulável sem valor inicial**

```dart
class Materia {
  String nome; // ❌
}
```
```text
Error: Field 'nome' should be initialized because its type 'String' doesn't allow null.
```
✅ Dê um valor inicial, ou use o açúcar do construtor da [Aula 2](02-construtores.md).

**3. `nome = nome` dentro do construtor**

```dart
Materia(String nome) {
  nome = nome; // ❌ atribui o parâmetro a ele mesmo
}
```
Compila, roda, e o campo nunca muda. ✅ Use `this.nome = nome;`.

**4. Achar que objetos são copiados ao passar para uma função**

```dart
void zerar(Materia m) {
  m.minutosEstudados = 0;
}

zerar(dart);
print(dart.minutosEstudados); // 0 — o objeto original FOI alterado
```
Em Dart, a variável guarda uma **referência** ao objeto. Passar para a função passa a referência,
não uma cópia. Esse é um dos motivos pelos quais a [Aula 3](03-encapsulamento.md) defende objetos
**imutáveis**.

**5. Usar `new`**

```dart
final dart = new Materia('Dart', 0, 300); // ❌ estilo antigo
```
Funciona, mas o lint `unnecessary_new` reclama. ✅ Remova o `new`.

**6. Nome de classe em `snake_case`**

```dart
class materia_de_estudo {} // ❌
```
Convenção do Dart: classes em `UpperCamelCase` (`MateriaDeEstudo`), campos e métodos em
`lowerCamelCase`, arquivos em `snake_case.dart`. O lint `camel_case_types` avisa.

---

## 🛠️ Exercício guiado

Vamos criar uma segunda classe do domínio do app **Foco**: a `SessaoDeEstudo`.

**Passo 1.** Crie o arquivo `bin/guiado_01_sessao.dart`.

**Passo 2.** Declare a classe com três campos: `materia` (`String`), `minutos` (`int`) e
`concluida` (`bool`), todos com valor inicial.

```dart
class SessaoDeEstudo {
  String materia = 'Sem matéria';
  int minutos = 0;
  bool concluida = false;
}
```

**Passo 3.** Escreva o construtor recebendo `materia` e `minutos` (a sessão nasce não concluída).
Use `this.` para desfazer a ambiguidade.

```dart
  SessaoDeEstudo(String materia, int minutos) {
    this.materia = materia;
    this.minutos = minutos;
  }
```

**Passo 4.** Adicione três métodos:

- `void concluir()` → marca `concluida = true`.
- `String duracaoFormatada()` → devolve `'1h 30min'` para 90 minutos, `'45min'` para 45.
- `String resumo()` → junta tudo numa linha.

```dart
  void concluir() {
    concluida = true;
  }

  String duracaoFormatada() {
    final horas = minutos ~/ 60;   // ~/ é divisão inteira
    final restante = minutos % 60; // % é o resto da divisão
    if (horas == 0) {
      return '${restante}min';
    }
    if (restante == 0) {
      return '${horas}h';
    }
    return '${horas}h ${restante}min';
  }

  String resumo() {
    final estado = concluida ? 'concluída' : 'em andamento';
    return '$materia — ${duracaoFormatada()} ($estado)';
  }
```

**Passo 5.** No `main`, crie duas sessões, conclua uma e imprima as duas.

```dart
void main() {
  final manha = SessaoDeEstudo('Dart', 90);
  final noite = SessaoDeEstudo('Flutter', 45);

  manha.concluir();

  print(manha.resumo());
  print(noite.resumo());
}
```

**Passo 6.** Execute:

```powershell
dart run bin/guiado_01_sessao.dart
```

**Saída esperada:**

```text
Dart — 1h 30min (concluída)
Flutter — 45min (em andamento)
```

**Passo 7.** Confirme que não há avisos:

```powershell
dart analyze
```

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/03-dart-intermediario.md](../../exercicios/03-dart-intermediario.md)

---

## 🏆 Desafio opcional

Crie a classe `Semana`, que guarda uma `List<Materia>` e oferece:

- `void adicionar(Materia m)`
- `int totalDeMinutos()`
- `Materia? materiaMaisEstudada()` — devolve `null` se a lista estiver vazia (repare no `?`:
  é *null safety* do módulo 02 sendo usado em um tipo que **você** criou)
- `List<Materia> atrasadas()` — as que ainda não atingiram a meta
- `String relatorio()` — um texto com todas as linhas

Regra do desafio: **nenhum método pode receber a lista por parâmetro**. A lista é campo da classe.
Se você sentir vontade de escrever `totalDeMinutos(List<Materia> lista)`, é sinal de que ainda está
pensando em funções soltas em vez de objetos.

---

## 📌 Resumo

- **Classe** é o molde; **objeto**/**instância** é o que se cria a partir dele.
- **Campo** guarda dado; **método** guarda comportamento. Juntos, numa unidade só: isso é OO.
- Em Dart, `new` é desnecessário: escreva `Materia(...)`.
- Se você **não** escrever construtor, o Dart cria um padrão sem parâmetros.
- `this` é o objeto atual. Só escreva `this.` quando houver ambiguidade de nome.
- Campos não anuláveis precisam de valor antes do corpo do construtor rodar.
- Variáveis guardam **referências**: passar um objeto para uma função não o copia.
- `==` compara identidade por padrão; comparar por valor é assunto da [Aula 3](03-encapsulamento.md).
- Convenções: `UpperCamelCase` para classes, `lowerCamelCase` para membros,
  `snake_case.dart` para arquivos.

---

## ☑️ Checklist de domínio

- [x] Explico a diferença entre classe, objeto e instância sem consultar a aula.
- [x] Declaro uma classe com campos e métodos de memória.
- [x] Sei dizer por que `Materia()` funciona quando não há construtor declarado.
- [x] Sei quando `this` é obrigatório e quando é ruído.
- [x] Reconheço o erro "Non-nullable instance field must be initialized" e sei corrigi-lo.
- [x] Entendo por que alterar um objeto dentro de uma função altera o original.
- [x] Rodei `bin/01_classes_e_objetos.dart` e obtive exatamente a saída esperada.
- [x] Fiz o exercício guiado e `dart analyze` não apontou nada.

---

## 📚 Referências oficiais

- [Dart — Classes](https://dart.dev/language/classes)
- [Dart — Methods](https://dart.dev/language/methods)
- [Effective Dart — Design](https://dart.dev/effective-dart/design)
- [Effective Dart — Style (nomes e arquivos)](https://dart.dev/effective-dart/style)
- [API — `identical`](https://api.dart.dev/stable/dart-core/identical.html)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — Construtores](02-construtores.md) |
