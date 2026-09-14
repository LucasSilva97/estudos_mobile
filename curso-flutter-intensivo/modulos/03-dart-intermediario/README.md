# Módulo 03 — Dart Intermediário

> **Nível:** Intermediário · **Tempo estimado total:** 7 h 40 min (460 min) · **Dias 6 e 7 do plano intensivo**

Este é o módulo em que você deixa de escrever "scripts" e passa a escrever **software**.

Até aqui você guardou dados em variáveis soltas, listas e mapas. A partir de agora você vai
aprender a criar seus **próprios tipos**: uma `Materia`, uma `Sessao`, uma `Meta`. É exatamente
assim que o Flutter é construído por dentro — **todo widget do Flutter é uma classe**. Sem este
módulo, o módulo 05 (Introdução ao Flutter) vira decoreba. Com ele, vira leitura natural.

---

## 🎯 O que você vai aprender

Ao final deste módulo você será capaz de:

- Criar **classes** e **objetos** em Dart, com campos e métodos próprios.
- Escrever **construtores** de todos os tipos que o Dart oferece: padrão, nomeado, `const`,
  `factory` e redirecionado — e saber quando usar cada um.
- **Encapsular** dados: esconder o que é detalhe interno (`_`), expor o que interessa
  (`get`/`set`) e criar objetos **imutáveis** com `copyWith`.
- Comparar objetos por **valor** sobrescrevendo `==` e `hashCode` com `Object.hash`.
- Usar **herança** (`extends`), `super` e `@override` — e, mais importante, saber **quando não usar**
  herança e preferir **composição**.
- Definir **contratos** com `abstract class` e `implements`, o alicerce de todo código testável.
- Reaproveitar comportamento com **mixins** (`mixin`, `with`, `on`).
- Modelar conjuntos fechados de opções com **enums**, inclusive enums avançados com campos e métodos.
- Escrever código que funciona com **qualquer tipo** usando **generics** (`<T>`).
- Adicionar métodos a tipos que não são seus com **extension methods**.
- Organizar o código em **arquivos, bibliotecas e pacotes**, entender `pubspec.yaml`,
  versionamento semântico (`^1.2.3`), `pubspec.lock` e como avaliar um pacote do
  [pub.dev](https://pub.dev) antes de instalá-lo.

---

## ✅ Pré-requisitos

Antes de começar, você precisa ter concluído:

- [Módulo 02 — Dart Básico](../02-dart-basico/README.md) — especialmente
  [`05-null-safety.md`](../02-dart-basico/05-null-safety.md),
  [`07-funcoes-em-dart.md`](../02-dart-basico/07-funcoes-em-dart.md),
  [`08-listas.md`](../02-dart-basico/08-listas.md) e
  [`09-sets-e-maps.md`](../02-dart-basico/09-sets-e-maps.md).
- [Módulo 01 — Lógica e Fundamentos](../01-logica-e-fundamentos/README.md), para leitura de erros.

E ter o ambiente funcionando (Dart **3.13.1**, embutido no Flutter **3.47.1**):

**🪟 Windows (PowerShell)**
```powershell
dart --version
```

A saída precisa mostrar a versão **3.13.1**. Se der erro, volte para
[`02-configuracao-do-ambiente.md`](../../02-configuracao-do-ambiente.md).

### Projeto de prática deste módulo

Todas as aulas deste módulo são **Dart puro de terminal** — nada de Flutter ainda. Crie **uma vez**
a pasta de prática e use-a até o fim do módulo:

**🪟 Windows (PowerShell)**
```powershell
cd C:\src
dart create -t console dart_intermediario
cd dart_intermediario
```

> ⚠️ Use uma pasta **sem acentos e sem espaços** no caminho (por exemplo `C:\src`). O caminho
> `C:\Users\Usuário\...` tem acento e já causou falhas reais de ferramentas nesta máquina —
> veja [`referencias/erros-comuns.md`](../../referencias/erros-comuns.md).

Cada aula indica o arquivo exato a criar dentro de `bin/` e o comando exato para executar,
por exemplo `dart run bin/01_classes_e_objetos.dart`.

---

## 🗺️ Ordem recomendada das aulas

Siga **nesta ordem**. Cada aula assume a anterior.

| # | Aula | Tempo | O que entra na sua cabeça |
|---|---|---|---|
| 1 | [Classes e objetos](01-classes-e-objetos.md) | 45 min | `class`, objeto, instância, campo, método, `this` |
| 2 | [Construtores](02-construtores.md) | 50 min | construtor padrão, `this.x`, nomeado, initializer list, `const`, `factory`, `assert` |
| 3 | [Encapsulamento](03-encapsulamento.md) | 50 min | `_privado`, `get`/`set`, imutabilidade, `copyWith`, `==`/`hashCode`, `toString` |
| 4 | [Herança e polimorfismo](04-heranca-e-polimorfismo.md) | 50 min | `extends`, `super`, `@override`, polimorfismo, composição > herança |
| 5 | [Classes abstratas e interfaces](05-abstratas-e-interfaces.md) | 45 min | `abstract`, método abstrato, `implements`, contrato de repositório |
| 6 | [Mixins](06-mixins.md) | 40 min | `mixin`, `with`, `on`, linearização |
| 7 | [Enums](07-enums.md) | 40 min | `enum`, `values`, `index`, `name`, `switch` exaustivo, enum avançado |
| 8 | [Generics](08-generics.md) | 50 min | `<T>`, classe genérica, método genérico, limite `extends`, `Repositorio<T>` |
| 9 | [Extensions](09-extensions.md) | 40 min | `extension`, quando usar, limitações |
| 10 | [Arquivos, bibliotecas e pacotes](10-arquivos-bibliotecas-pacotes.md) | 50 min | `import`, `export`, `part`, `pubspec.yaml`, semver, pub.dev |

**Divisão sugerida no plano intensivo de 30 dias:**

| Dia | Aulas |
|---|---|
| 6 | Aulas 1 a 5 (4 h de conteúdo) |
| 7 | Revisão + aulas 6 a 10 + exercícios |

---

## 🧭 Como estudar cada aula

1. Leia a seção **📖 Conceito** sem pressa. Não pule para o código.
2. Digite o **💻 Código completo** você mesmo. **Não copie e cole.** Digitar é o que fixa a sintaxe.
3. Execute. Compare com o bloco de saída esperada.
4. **Quebre o código de propósito**: apague um `@override`, troque `final` por `var`, remova um
   campo do `hashCode`. Leia o erro. Erro lido é erro aprendido.
5. Faça o **🛠️ Exercício guiado** antes de ir para a próxima aula.
6. Ao final do módulo, faça todos os exercícios obrigatórios e a avaliação.

---

## 📝 Exercícios e avaliação

- **Exercícios do módulo:** [`exercicios/03-dart-intermediario.md`](../../exercicios/03-dart-intermediario.md)
  (mínimo de 12 exercícios; faça **todos os obrigatórios**)
- **Gabarito comentado:** [`gabaritos/03-dart-intermediario.md`](../../gabaritos/03-dart-intermediario.md)
- **Avaliação do módulo:** [`avaliacoes/modulo-03-dart-intermediario.md`](../../avaliacoes/modulo-03-dart-intermediario.md)
- **Avaliação cumulativa de Dart (após o módulo 04):**
  [`avaliacoes/cumulativa-01-dart.md`](../../avaliacoes/cumulativa-01-dart.md)

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item **só depois de conseguir fazer sem olhar a aula**:

- [ ] Você consegue explicar, com suas palavras, a diferença entre **classe** e **objeto**.
- [ ] Você escreve uma classe com construtor nomeado e `assert` de validação sem consultar exemplo.
- [ ] Você sabe dizer por que `const Materia('Dart')` pode ser mais rápido que `Materia('Dart')`.
- [ ] Você cria uma classe **imutável** com `final`, `copyWith`, `==`, `hashCode` e `toString`.
- [ ] Você explica por que `Object.hash` precisa usar **os mesmos campos** que o `==`.
- [ ] Você escolhe corretamente entre **herança** e **composição** diante de um problema novo.
- [ ] Você explica a diferença entre `extends` e `implements` em uma frase.
- [ ] Você escreve um `mixin` com cláusula `on` e sabe dizer a ordem de aplicação.
- [ ] Você usa um `enum` avançado (com campos e métodos) e um `switch` exaustivo sem `default`.
- [ ] Você escreve uma classe genérica `Repositorio<T extends Entidade>` e explica o limite.
- [ ] Você cria uma `extension` e cita pelo menos duas limitações dela.
- [ ] Você lê um `pubspec.yaml`, explica `^1.2.3` e diz o que `pubspec.lock` faz.
- [ ] `dart analyze` roda **sem nenhum aviso** nos seus arquivos do módulo.
- [ ] Você acertou **≥ 7 das 10 questões** da [avaliação do módulo](../../avaliacoes/modulo-03-dart-intermediario.md).
- [ ] Você concluiu **todos** os exercícios obrigatórios de
      [`03-dart-intermediario.md`](../../exercicios/03-dart-intermediario.md).

Verificação final do módulo:

**🪟 Windows (PowerShell)**
```powershell
dart analyze
dart format .
```

---

## 🔗 Navegação

| ⬅️ Módulo anterior | 🏠 Curso | ➡️ Próximo módulo |
|---|---|---|
| [02 — Dart Básico](../02-dart-basico/README.md) | [Início do curso](../../README.md) | [04 — Dart Avançado](../04-dart-avancado/README.md) |

📖 Termos novos? Consulte o [glossário](../../referencias/glossario.md).
🧭 Acompanhe seu avanço na [trilha de progresso](../../03-trilha-de-progresso.md).
