# Aula 9 — Sets e Maps

> **Módulo:** 02 — Dart básico · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Usar `Set` quando cada valor deve aparecer uma única vez.
- Usar `Map` para relacionar uma chave única a um valor.
- Inserir, consultar, atualizar, remover e percorrer as duas coleções.
- Agrupar dados com `putIfAbsent` e `update`.

## ✅ Pré-requisitos

[Listas](08-listas.md), funções e null safety. Execute os exemplos no projeto Dart do módulo.

## 📖 Conceito

`List` guarda uma sequência e aceita repetição. `Set` representa um conjunto de valores únicos.
`Map<K, V>` relaciona chaves do tipo `K` a valores do tipo `V`; cada chave aparece uma vez.

```dart
final tags = <String>{'dart', 'flutter', 'dart'}; // dois elementos
final minutos = <String, int>{'Dart': 40, 'Git': 25};
```

As chaves e os elementos precisam ter igualdade e `hashCode` coerentes; isso será relevante ao
usar objetos próprios. A ordem de iteração do literal padrão é preservada nas implementações
usuais do SDK, mas use `List` quando posição e duplicação forem parte do significado.

Operações importantes:

| Set | Map |
|---|---|
| `add`, `addAll`, `remove`, `contains` | `map[chave]`, atribuição, `remove`, `containsKey` |
| `union`, `intersection`, `difference` | `keys`, `values`, `entries` |
| literal vazio: `<String>{}` | literal vazio: `<String, int>{}` |

`map[chave]` devolve `V?`, pois a chave pode não existir. `putIfAbsent` cria um valor somente
quando a chave está ausente. `update` altera um valor existente e pode receber `ifAbsent`.
Veja a [documentação de coleções](https://dart.dev/language/collections).

## 💡 Analogia

Um Set parece uma lista de presença: repetir o mesmo nome não cria outra pessoa. Um Map parece
um armário de chaves: cada etiqueta identifica um compartimento, e trocar o conteúdo da mesma
etiqueta não cria uma segunda etiqueta.

## 🧪 Exemplo mínimo

```dart
void main() {
  final dias = <String>{'seg', 'ter', 'seg'};
  final metas = <String, int>{'Dart': 120};
  metas['Flutter'] = 90;
  print(dias); // {seg, ter}
  print(metas['Dart']); // 120
  print(metas['Git']); // null
}
```

## 📱 Aplicando no Flutter

Um Set pode guardar os identificadores selecionados em uma lista de filtros. Um Map pode agrupar
sessões por matéria antes de criar cartões. Não use o nome visível como chave quando ele puder
mudar ou se repetir; no projeto final, use um identificador estável.

## 💻 Código completo

Crie `bin/sets_e_maps.dart`:

```dart
void main() {
final materiasUnicas = <String>['Dart', 'Git', 'Dart', 'Flutter'].toSet();
  print('Únicas: $materiasUnicas');
  print('Adicionou SQL? ${materiasUnicas.add('SQL')}');
  print('Adicionou Dart? ${materiasUnicas.add('Dart')}');

  const basicas = <String>{'Dart', 'Git', 'Flutter'};
  const concluidas = <String>{'Git', 'Terminal'};
  print('União: ${basicas.union(concluidas)}');
  print('Interseção: ${basicas.intersection(concluidas)}');
  print('Pendentes: ${basicas.difference(concluidas)}');

  final minutosPorMateria = <String, int>{'Dart': 40, 'Git': 25};
  minutosPorMateria['Flutter'] = 30;
  minutosPorMateria.update('Dart', (atual) => atual + 20);
  minutosPorMateria.update('SQL', (atual) => atual + 15,
      ifAbsent: () => 15);
  print('Dart: ${minutosPorMateria['Dart']} min');
  print('Inexistente: ${minutosPorMateria['Kotlin']}');

  for (final entrada in minutosPorMateria.entries) {
    print('${entrada.key}: ${entrada.value} min');
  }

  final sessoes = <(String, int)>[
    ('Dart', 25),
    ('Git', 30),
    ('Dart', 40),
  ];
  final totais = <String, int>{};
  for (final (materia, minutos) in sessoes) {
    totais.update(materia, (atual) => atual + minutos,
        ifAbsent: () => minutos);
  }
  print('Totais: $totais');

  final copiaProtegida = Map<String, int>.unmodifiable(totais);
  print('Protegido: $copiaProtegida');
}
```

Saída principal esperada:

```text
Únicas: {Dart, Git, Flutter}
Adicionou SQL? true
Adicionou Dart? false
União: {Dart, Git, Flutter, Terminal}
Interseção: {Git}
Pendentes: {Dart, Flutter}
Dart: 60 min
Inexistente: null
Dart: 60 min
Git: 25 min
Flutter: 30 min
SQL: 15 min
Totais: {Dart: 65, Git: 30}
Protegido: {Dart: 65, Git: 30}
```

## 🔍 Explicando o código

`Set.add` informa com `bool` se o conjunto mudou. As três operações entre conjuntos devolvem
novos Sets. A atribuição `map[chave] = valor` insere ou substitui. `update` permite somar usando
o valor atual; `ifAbsent` define o primeiro valor. `entries` fornece pares com `key` e `value`.

A lista de records `(String, int)` representa matéria e duração. O padrão
`final (materia, minutos)` separa os dois campos. A aula de records explica esse recurso em
profundidade; aqui ele torna o agrupamento legível. `Map.unmodifiable` cria uma cópia que rejeita
alterações.

## 🤖🍎 Android × iOS

Essas coleções pertencem ao Dart e se comportam igual. Dados vindos de preferências, banco ou
API podem ter ordem e tipos próprios; faça a conversão explicitamente antes de exibi-los.

## ⚠️ Erros comuns

- `{}` sem tipo é inferido como Map vazio; para Set vazio, use `<String>{}`.
- `map['ausente']!` pode lançar erro; confira o nulo ou forneça valor padrão.
- Alterar chaves enquanto percorre `entries` pode causar `ConcurrentModificationError`.
- Usar objeto mutável como chave pode tornar a busca incoerente após a mutação.
- Esperar que atribuir à mesma chave preserve o valor anterior; a atribuição substitui.

## 🛠️ Exercício guiado

1. Digite o exemplo e confira cada linha.
2. Remova SQL do Set e confira o `bool` de duas remoções consecutivas.
3. Use `minutosPorMateria['Kotlin'] ?? 0` para imprimir zero sem inserir a chave.
4. Acrescente `('Git', 20)` às sessões: espere Git 50.
5. Tente alterar `copiaProtegida`, capture `UnsupportedError` e explique a causa.
6. Rode `dart format .` e `dart analyze`.

## 📝 Exercícios independentes

Faça os exercícios de Set, Map e agrupamento na
[lista do módulo 02](../../exercicios/02-dart-basico.md).

## 🏆 Desafio opcional

A partir de uma lista fixa de palavras, produza frequências sem diferenciar maiúsculas de
minúsculas. Para `['Dart', 'dart', 'Flutter']`, espere `{dart: 2, flutter: 1}`. Ordene apenas na
apresentação, sem depender da ordem do Map para definir a regra.

## 📌 Resumo

Set elimina repetições e oferece álgebra de conjuntos. Map relaciona chaves a valores e exige
tratamento de chave ausente. `update` com `ifAbsent` resolve contagens e somas agrupadas.

## ☑️ Checklist de domínio

- [ ] Escolho List, Set ou Map pela regra dos dados.
- [ ] Crio Set e Map vazios sem ambiguidade.
- [ ] Trato o retorno anulável de uma consulta ao Map.
- [ ] Agrupo durações com `update` e `ifAbsent`.
- [ ] Percorro `entries` sem modificar o Map durante a iteração.

## 📚 Referências oficiais

- [Dart — Collections](https://dart.dev/language/collections)
- [Set](https://api.dart.dev/dart-core/Set-class.html)
- [Map](https://api.dart.dev/dart-core/Map-class.html)

| Anterior | Módulo | Próxima |
|---|---|---|
| [Listas](08-listas.md) | [README](README.md) | [Entrada e saída](10-entrada-e-saida.md) |
