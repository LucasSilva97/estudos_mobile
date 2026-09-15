# Gabarito — Módulo 02: Dart básico

> Compare apenas depois de tentar os [exercícios](../exercicios/02-dart-basico.md). Há outras soluções válidas quando respeitam o contrato e passam pelos testes indicados.

<a id="m02-e01"></a>
## M02-E01 — Anatomia e estilo

```dart
const titulo = 'Foco';

void main() {
  print('$titulo | Dart básico');
}
```

`const` é apropriado porque o título é conhecido antes da execução. O arquivo deve permanecer sem alterações após `dart format bin/cartao.dart` e `dart analyze`.

<a id="m02-e02"></a>
## M02-E02 — `var`, `final`, `const` e `late`

```dart
void main() {
  const meta = 120; // fixa em tempo de compilação
  var minutos = 25; // será atualizado
  final inicio = DateTime.now(); // obtido em execução, sem reatribuição
  late String resumo; // recebe valor antes de ser lido

  minutos += 15;
  resumo = 'Estudados: $minutos de $meta min';
  print('$resumo — início: $inicio');
}
```

Erro comum: ler `resumo` antes da atribuição; `late` não torna a variável opcional.

<a id="m02-e03"></a>
## M02-E03 — Conversões seguras

```dart
int? inteiroValido(String texto) => int.tryParse(texto.trim());

void main() {
  for (final texto in [' 42 ', 'quarenta', '', '2.5']) {
    final valor = inteiroValido(texto);
    print(valor == null ? 'Rejeitado: "$texto"' : 'Aceito: $valor');
  }
}
```

`tryParse` devolve `null`, portanto entrada externa não encerra o programa. `int.parse` é adequado somente quando a validade já foi garantida.

<a id="m02-e04"></a>
## M02-E04 — Nulo sem `!`

```dart
String normalizarNome(String? nome) {
  final texto = nome?.trim();
  return texto == null || texto.isEmpty ? 'SEM NOME' : texto.toUpperCase();
}
```

Com `nome = null`, `nome?.toUpperCase()` produz `null`; `??` então escolhe `SEM NOME`. O operador `!` seria incorreto porque o contrato aceita nulo.

<a id="m02-e05"></a>
## M02-E05 — Status por `switch`

```dart
String rotulo(int percentual) => switch (percentual) {
      < 0 => 'Inválido',
      0 => 'Não iniciado',
      < 100 => 'Em andamento',
      _ => 'Concluído',
    };
```

Os casos cobrem todo `int`: negativo, zero, de 1 a 99 e 100 ou maior.

<a id="m02-e06"></a>
## M02-E06 — Função de duração

```dart
String formatarDuracao({required int minutos, bool mostrarHoras = true}) {
  if (minutos < 0) return 'Duração inválida';
  if (!mostrarHoras) return '$minutos min';
  return '${minutos ~/ 60}h ${(minutos % 60).toString().padLeft(2, '0')}min';
}
```

Exemplos: `0` → `0h 00min`; `65` → `1h 05min`; `-1` → `Duração inválida`.

<a id="m02-e07"></a>
## M02-E07 — Transformar lista

```dart
void main() {
  final minutos = [25, 0, 40, -5, 30];
  final positivos = minutos.where((valor) => valor > 0).toList();
  final horas = positivos.map((valor) => valor / 60).toList();
  final total = positivos.fold<int>(0, (soma, valor) => soma + valor);
  print('$positivos | $horas | $total');
}
```

`where` e `map` devolvem iteráveis novos; o `toList` materializa o resultado. A lista original não é alterada.

<a id="m02-e08"></a>
## M02-E08 — Agrupar e ler

```dart
import 'dart:io';

void main() {
  final materias = <String>{};
  final totais = <String, int>{};
  while (true) {
    final linha = stdin.readLineSync();
    if (linha == null || linha.trim().isEmpty) break;
    final partes = linha.split('/');
    if (partes.length != 2) continue;
    final materia = partes[0].trim();
    final minutos = int.tryParse(partes[1].trim());
    if (materia.isEmpty || minutos == null || minutos <= 0) continue;
    materias.add(materia);
    totais.update(materia, (total) => total + minutos, ifAbsent: () => minutos);
  }
  print(materias);
  print(totais);
}
```

Para `Dart/25`, `Git/30`, `Dart/40`, imprime matérias `Dart` e `Git`, com totais Dart 65 e Git 30. EOF e linha vazia encerram normalmente.

<a id="m02-e09"></a>
## M02-E09 — Frequência de palavras

```dart
Map<String, int> frequencias(List<String> palavras) {
  final resultado = <String, int>{};
  for (final palavra in palavras) {
    final chave = palavra.toLowerCase();
    resultado.update(chave, (quantidade) => quantidade + 1, ifAbsent: () => 1);
  }
  return resultado;
}
```

<a id="m02-e10"></a>
## M02-E10 — `firstWhere` seguro

```dart
final encontrada = materias.where((materia) => materia == alvo).firstOrNull ?? -1;
```

Se a versão do SDK não oferecer `firstOrNull`, use `final encontradas = materias.where((x) => x == alvo); final encontrada = encontradas.isEmpty ? -1 : encontradas.first;`. Não use `firstWhere` sem `orElse`.

<a id="m02-e11"></a>
## M02-E11 — Coleção imutável

`const [1, 2]` é uma lista constante e seus valores precisam ser constantes. `List.unmodifiable(original)` cria uma visão protegida dos elementos atuais: alterar a lista protegida lança `UnsupportedError`, e alterar `original` depois não altera a cópia protegida.

<a id="m02-e12"></a>
## M02-E12 — Calculadora de estudo

Use a estrutura de E08, mais `total / sessoes` somente quando `sessoes > 0`, `materias` como `Set<String>` e `maior` atualizado a cada duração válida. Os três casos obrigatórios são nenhuma sessão, total igual à meta e total maior que a meta.

[Voltar aos exercícios](../exercicios/02-dart-basico.md)
