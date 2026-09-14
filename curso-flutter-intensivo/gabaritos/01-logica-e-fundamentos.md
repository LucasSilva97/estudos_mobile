# Gabarito — Módulo 01: Lógica e fundamentos

> Compare depois de tentar os [exercícios](../exercicios/01-logica-e-fundamentos.md).
> Soluções equivalentes são válidas quando passam pelos mesmos casos e respeitam o contrato.

<a id="m01-e01"></a>
## M01-E01 — Entrada, processamento e saída

**Solução:** entrada: ler três durações; processamento: somá-las, dividir o total por 3 e comparar
total com 120; saída: total, média e situação. **Teste de mesa:** 30 + 45 + 60 = 135;
135 / 3 = 45; 135 >= 120, então a meta foi atingida. **Erros frequentes:** dividir cada parcela
ou omitir a comparação. **Alternativa:** calcular primeiro `falta = 120 - total`, desde que não
informe falta negativa quando a meta foi superada.

| Critério | Pontos |
|---|---|
| Entradas, processamento e saídas separados | 4 |
| Fórmulas e decisão completas | 3 |
| Teste de mesa correto | 3 |

<a id="m01-e02"></a>
## M01-E02 — Escolha de tipos e constantes

```dart
void main() {
  const String materia = 'Dart';
  const int meta = 120;
  var estudado = 25;
  final DateTime inicio = DateTime.now();
  estudado += 20;
  print('$materia | meta: $meta | estudado: $estudado | início: $inicio');
}
```

**Raciocínio:** matéria e meta são conhecidas e fixas no exemplo; estudado muda; o horário só é
conhecido durante a execução e não será reatribuído. **Resultado:** estudado 45; data variável.
**Erros:** usar `const DateTime.now()` ou reatribuir `final`. **Alternativa:** `int estudado = 25`
explicita o tipo; `final materia = 'Dart'` é válido se o valor vier a ser obtido em execução.

| Critério | Pontos |
|---|---|
| Declarações compilam e têm tipos adequados | 4 |
| Mutação e saída corretas | 2 |
| Quatro justificativas coerentes | 4 |

<a id="m01-e03"></a>
## M01-E03 — Precedência da média

```dart
final media = (segunda + terca + quarta) / 3;
```

**Raciocínio:** divisão tem precedência sobre soma; o código defeituoso calcula 30 + 60 + 30 = 120.
Os parênteses produzem 180 / 3 = 60.0. **Testes:** zeros → 0.0; três valores 10 → 10.0.
**Erro:** trocar `/` por `~/` e perder frações. **Alternativa:** somar numa variável `total` e
depois usar `total / 3`, frequentemente mais legível.

| Critério | Pontos |
|---|---|
| Saída defeituosa prevista e causa explicada | 4 |
| Fórmula corrigida | 3 |
| Três casos conferidos | 3 |

<a id="m01-e04"></a>
## M01-E04 — Classificação da meta

```dart
String classificarMeta(int percentual) {
  if (percentual < 0) return 'Inválido';
  if (percentual < 50) return 'Começando';
  if (percentual < 100) return 'Quase lá';
  return 'Meta atingida';
}
```

**Passo a passo:** exclua negativos; depois de cada retorno, os casos restantes já são maiores
ou iguais ao limite anterior. **Saídas:** -1 inválido; 0/49 começando; 50/99 quase lá; 100/150
atingida. **Erro:** testar `< 100` antes de `< 50`. **Alternativa:** cadeia `else if`, igualmente
clara; um `switch` expression com guardas é ensinado mais tarde.

| Critério | Pontos |
|---|---|
| Quatro faixas sem lacunas | 5 |
| Função retorna em vez de imprimir | 2 |
| Sete limites testados | 3 |

<a id="m01-e05"></a>
## M01-E05 — Teste de mesa de um laço

| i | total antes | ação | total depois |
|---|---:|---|---:|
| 1 | 0 | soma 10 | 10 |
| 2 | 10 | soma 20 | 30 |
| 3 | 30 | `continue` | 30 |
| 4 | 30 | soma 40 | 70 |

**Resultado:** 70. Com `break`, o laço termina em i = 3 e imprime 30. **Erro:** somar 30 antes
do `continue`. **Alternativa:** uma tabela com condição e expressão avaliadas também é válida.

| Critério | Pontos |
|---|---|
| Quatro passagens rastreadas | 5 |
| Resultado 70 explicado | 3 |
| Variante com break prevista | 2 |

<a id="m01-e06"></a>
## M01-E06 — Laço que não termina

```dart
var restante = 75;
while (restante > 0) {
  print(restante);
  restante -= 25;
}
```

**Raciocínio:** a subtração transforma 75 → 50 → 25 → 0, tornando a condição falsa.
**Testes:** 75 imprime três linhas; 25 uma; 0 nenhuma. **Erro:** incrementar ou declarar outro
`restante` dentro do bloco. **Alternativa:** `for (var r = restante; r > 0; r -= 25)` expressa
as três partes juntas.

| Critério | Pontos |
|---|---|
| Correção termina com as três linhas | 4 |
| Prova da condição de parada | 3 |
| Casos 25 e 0 | 3 |

<a id="m01-e07"></a>
## M01-E07 — Resumo semanal

```dart
int somarValidos(List<int> minutos) {
  var total = 0;
  for (final valor in minutos) {
    if (valor <= 0) continue;
    total += valor;
  }
  return total;
}

String situacao(int total, int meta) {
  if (total >= meta) return 'Meta atingida';
  return 'Faltam ${meta - total} min';
}

void main() {
  final minutos = <int>[25, 0, 40, -5, 30];
  final total = somarValidos(minutos);
  print('Total: $total');
  print(situacao(total, 120));
}
```

**Resultado:** total 95; faltam 25. Vazia → total 0; `[120]` e `[60, 60]` atingem; `[150]`
também atinge. **Raciocínio:** cálculo não modifica a lista e apresentação usa o retorno.
**Erro:** calcular `meta - total` antes de verificar superação, exibindo negativo.
**Alternativa:** `if (valor > 0) total += valor` evita `continue`; ambas são claras.

| Critério | Pontos |
|---|---|
| Ignora inválidos e soma 95 | 3 |
| Situação cobre meta igual/superada | 2 |
| Funções separadas e lista preservada | 2 |
| Quatro testes adicionais | 3 |

<a id="m01-e08"></a>
## M01-E08 — Diagnóstico de entrada

```dart
int? converterMinutos(String texto) {
  final valor = int.tryParse(texto.trim());
  if (valor == null || valor <= 0) return null;
  return valor;
}

void main() {
  final casos = <String>['25', ' 40 ', 'trinta', '', '0', '-1', '2.5'];
  for (final caso in casos) {
    final valor = converterMinutos(caso);
    print(valor == null ? 'Rejeitado: "$caso"' : 'Aceito: $valor');
  }
}
```

`int.parse` lança `FormatException`; `tryParse` representa a falha com `null`. **Resultado:**
dois aceitos e cinco rejeitados. **Erro:** usar `!` no resultado anulável sem conferir.
**Alternativa:** retornar zero funciona somente quando o domínio proíbe zero; `null` comunica
melhor a ausência de conversão nesta atividade.

| Critério | Pontos |
|---|---|
| Conversão segura com trim | 3 |
| Rejeita nulo, zero e negativos | 3 |
| Sete casos sem encerramento anormal | 4 |

<a id="m01-e09"></a>
## M01-E09 — FizzBuzz explicado

```dart
void main() {
  for (var numero = 1; numero <= 30; numero++) {
    if (numero % 15 == 0) {
      print('DartFlutter');
    } else if (numero % 3 == 0) {
      print('Dart');
    } else if (numero % 5 == 0) {
      print('Flutter');
    } else {
      print(numero);
    }
  }
}
```

Múltiplos de 15 satisfazem também os testes de 3 e 5; a condição combinada precisa vir primeiro.
**Testes:** 3 Dart; 5 Flutter; 15/30 DartFlutter; 16 número. **Alternativa:** testar
`numero % 3 == 0 && numero % 5 == 0`, mais explícito e um pouco maior.

| Critério | Pontos |
|---|---|
| Trinta saídas | 3 |
| Ordem e cinco casos corretos | 5 |
| Sobreposição explicada | 2 |

<a id="m01-e10"></a>
## M01-E10 — Primeiro valor longo

```dart
void mostrarPrimeiraLonga(List<int> minutos) {
  var encontrou = false;
  for (final valor in minutos) {
    if (valor <= 0) continue;
    if (valor >= 60) {
      print(valor);
      encontrou = true;
      break;
    }
  }
  if (!encontrou) print('Nenhuma sessão longa');
}
```

**Resultado:** original → 90; `[20, 35]` e vazia → mensagem; `[60]` → 60. **Erro:** imprimir
a mensagem dentro do laço a cada item curto. **Alternativa:** retornar `int?` separa melhor busca
e apresentação, mas null safety só será aprofundada no próximo módulo.

| Critério | Pontos |
|---|---|
| Primeira longa apenas | 4 |
| Inválidos ignorados e ausência tratada | 3 |
| Quatro casos testados | 3 |

<a id="m01-e11"></a>
## M01-E11 — Formatação de duração

```dart
String formatarDuracao(int minutos) {
  if (minutos < 0) return 'Inválido';
  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  final doisDigitos = resto < 10 ? '0$resto' : '$resto';
  return '${horas}h ${doisDigitos}min';
}
```

**Saídas:** -1 inválido; 0 → 0h 00min; 5 → 0h 05min; 59 → 0h 59min; 60 → 1h 00min;
65 → 1h 05min; 120 → 2h 00min. **Erro:** usar `/`, obtendo horas decimais.
**Alternativa:** `resto.toString().padLeft(2, '0')` é mais geral, explicado com strings no módulo 02.

| Critério | Pontos |
|---|---|
| Negativo tratado e cálculos corretos | 4 |
| Formato dos minutos | 3 |
| Sete testes | 3 |

<a id="m01-e12"></a>
## M01-E12 — Relatório sem resultado impossível

```dart
void relatorio(List<int> minutos) {
  var quantidade = 0;
  var total = 0;
  var maior = 0;
  for (final valor in minutos) {
    if (valor <= 0) continue;
    quantidade++;
    total += valor;
    if (valor > maior) maior = valor;
  }
  if (quantidade == 0) {
    print('Sem sessões');
    return;
  }
  final media = total / quantidade;
  print('Quantidade: $quantidade');
  print('Total: $total');
  print('Média: ${media.toStringAsFixed(1)}');
  print('Maior: $maior');
}
```

**Raciocínio:** a guarda anterior à divisão trata listas sem itens válidos. Como só positivos
entram, zero é um início seguro para maior. **Resultado:** 3, 95, 31.7, 40. Vazia e apenas
inválidos mostram a mensagem; `[25]` dá média 25.0; repetidos funcionam.
**Erro:** dividir pelo tamanho da lista original. **Alternativa:** uma lista filtrada seguida de
métodos de coleção é adequada após a aula de listas, mas esta solução exercita os laços do módulo.

| Critério | Pontos |
|---|---|
| Quantidade, total e maior corretos | 3 |
| Média usa quantidade válida | 2 |
| Guarda evita operação impossível | 2 |
| Cinco casos conferidos | 3 |

[Voltar aos exercícios](../exercicios/01-logica-e-fundamentos.md) ·
[Avaliação](../avaliacoes/modulo-01-logica-e-fundamentos.md)
