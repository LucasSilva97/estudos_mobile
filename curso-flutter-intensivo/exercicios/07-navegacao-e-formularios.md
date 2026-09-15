# Exercícios — Módulo 07: Navegação e formulários

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Trabalhe no projeto `foco_navegacao` e rode `dart format .` e `flutter analyze` (até sair `No issues found!`) antes de consultar o gabarito.

<a id="m07-e01"></a>
## M07-E01 — Pilha de quatro telas · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Empilhar e desempilhar rotas | Fácil | 20 min | Sim |
Encadeie `ListaMateriasScreen` → `DetalheMateriaScreen` → `EstatisticasScreen` → `ResumoSessaoScreen` com `Navigator.push` e `MaterialPageRoute<void>`; no resumo, um `FilledButton` "Concluir" chama `popUntil((Route<dynamic> r) => r.isFirst)`. **Esperado:** o `ObservadorDePilha` imprime **três `POP` seguidos** num único toque. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e01)

<a id="m07-e02"></a>
## M07-E02 — Prever o voltar · Leitura de código
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Ler a pilha antes de rodar | Fácil | 15 min | Sim |
Para a sequência `push(A)`, `push(B)`, `pushReplacement(C)`, `push(D)`, escreva no papel a pilha final na ordem, o valor de `Navigator.canPop` em D e na raiz, e por que `pop` na primeira rota deixa a tela preta enquanto `maybePop` não. **Esperado:** sua resposta cita que `maybePop` respeita o `PopScope` e `pop` não. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e02)

<a id="m07-e03"></a>
## M07-E03 — Rotas centralizadas · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| `onGenerateRoute` com `switch` | Média | 30 min | Sim |
Crie `abstract final class Rotas` com as constantes `home`, `materiaForm`, `estatisticas` e o método `gerar(RouteSettings)`; ligue `onGenerateRoute: Rotas.gerar`, `onUnknownRoute: Rotas.desconhecida` e `initialRoute: Rotas.home`, abrindo `materiaForm` com `fullscreenDialog: true`. **Teste:** `pushNamed('/materia/formm')` cai na `RotaDesconhecidaScreen`, que volta com `pushNamedAndRemoveUntil(Rotas.home, (_) => false)`. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e03)

<a id="m07-e04"></a>
## M07-E04 — Rota sem `settings` · Correção de bugs
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Repassar `RouteSettings` | Média | 15 min | Sim |
No `case materiaForm` de `Rotas.gerar` falta `settings: configuracoes`: o observador imprime `sem nome` e `ModalRoute.of(context)?.settings.arguments` chega `null` na tela. Corrija esse `case` e confira os outros. **Teste:** o log passa a mostrar `/materia/form` e o formulário volta a enxergar os argumentos. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e04)

<a id="m07-e05"></a>
## M07-E05 — Ida tipada, volta com resultado · Aplicação
A `DetalheMateriaScreen` abre o formulário com `arguments: MateriaFormArgs.editar(materia)` e aguarda `await Navigator.of(context).pushNamed<Materia>(Rotas.materiaForm)`; o `onGenerateRoute` devolve `MaterialPageRoute<Materia>` e recusa o argumento com `if (args is! MateriaFormArgs)` antes de usar. Depois do `await`, `if (!context.mounted) return;` e `SnackBar` só quando o resultado não for `null`. **Esperado:** cancelar com o botão voltar não mostra `SnackBar` nenhum. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e05)

<a id="m07-e06"></a>
## M07-E06 — Quando o resultado é `null` · Compreensão
Liste por escrito as situações em que `await pushNamed<Materia>(...)` devolve `null` e explique, em duas frases, por que uma `MaterialPageRoute<void>` recebendo `pop(materia)` descarta o valor **sem erro e sem aviso**. **Esperado:** sua lista inclui o gesto de borda do iOS, o `pop()` sem argumento, o `popUntil` e o tipo genérico trocado. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e06)

<a id="m07-e07"></a>
## M07-E07 — Quatro abas sem perder estado · Aplicação
Monte a `HomeScreen` com `NavigationBar` de 4 destinos (Hoje · Matérias · Trilhas · Ajustes), `IndexedStack` no `body` e `NavigationRail` quando `MediaQuery.sizeOf(context).width >= 600`. **Teste:** role a lista de Matérias, vá para Ajustes, volte — a rolagem continua onde estava, e o `ObservadorDePilha` fica em silêncio (trocar de aba não empilha rota). [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e07)

<a id="m07-e08"></a>
## M07-E08 — Formulário de matéria · Aplicação
Em `MateriaFormScreen`, monte `Form` + `GlobalKey<FormState>` com nome (`maxLength: 40`, `TextCapitalization.words`), meta em minutos (`keyboardType: TextInputType.number`, `FilteringTextInputFormatter.digitsOnly`, `LengthLimitingTextInputFormatter(3)`), observações (`minLines: 3, maxLines: null`), `DropdownButtonFormField<CategoriaMateria>` e `SwitchListTile` de lembrete que, ligado, revela o campo "Horário do lembrete". **Teste:** todo `TextEditingController` tem `dispose`, e `flutter analyze` termina limpo. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e08)

<a id="m07-e09"></a>
## M07-E09 — Sair sem salvar · Aplicação
Envolva o `Scaffold` do formulário num `PopScope` com `canPop: !_temAlteracoes` (um **getter**, nunca um campo) e `onPopInvokedWithResult` que pergunta "Descartar alterações?" antes de chamar `Navigator.pop` — com `context.mounted` checado depois do diálogo. **Teste:** 🤖 botão voltar e 🍎 gesto de borda mostram o mesmo diálogo; um formulário intocado sai direto. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e09)

<a id="m07-e10"></a>
## M07-E10 — `canPop` congelado · Correção de bugs
O formulário declara `late final bool _sujo = _nome.text.isNotEmpty;`, avaliado quando o campo ainda estava vazio — a proteção do E09 nunca dispara. Troque por um getter e faça cada tecla disparar rebuild com `addListener` no `initState` e `removeListener` antes do `dispose`. **Esperado:** digitar uma letra passa `canPop` para `false` imediatamente. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e10)

<a id="m07-e11"></a>
## M07-E11 — Validadores compostos e foco encadeado · Aplicação
Crie `abstract final class Validadores` com `obrigatorio`, `minimo`, `maximo`, `numeroInteiro`, `entre` e `combinar`, que para no **primeiro** erro; aplique-os aos três campos e encadeie nome → meta → observações com `FocusNode`, `textInputAction: TextInputAction.next` e `onFieldSubmitted`. **Teste:** a tecla de ação pula para o campo seguinte, `minimo` ignora campo vazio, e todo `FocusNode` tem `dispose`. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e11)

<a id="m07-e12"></a>
## M07-E12 — Formulário vermelho ao abrir · Correção de bugs
O `Form` está com `autovalidateMode: AutovalidateMode.always` e recebe o usuário com todos os erros acesos antes da primeira tecla. Comece em `disabled` e passe para `onUserInteraction` dentro do `_salvar`, só depois de `validate()` falhar; e ponha `FocusScope.of(context).unfocus()` como primeira linha do `_salvar`. **Esperado:** a tela abre limpa, o teclado fecha ao enviar e os erros aparecem visíveis. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e12)

<a id="m07-e13"></a>
## M07-E13 — Mensagens que ajudam · Reescrita
Reescreva estas seis mensagens do formulário do Foco — "Campo inválido", "Erro", "Nome inválido", "Você digitou errado", "Valor fora do intervalo", "Preenchimento obrigatório" — seguindo as três regras da aula 8: diga o que fazer, seja específico com números e formatos, e nunca use "você". **Esperado:** cada mensagem cabe numa linha, contém a correção, e a da meta cita o intervalo de 5 a 480 minutos. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e13)

<a id="m07-e14"></a>
## M07-E14 — Cinco escolhas do módulo · Decisão
Responda por escrito, em 2 a 4 frases cada, com uma consequência concreta (não preferência pessoal): (a) `Drawer` ou `NavigationBar` para as 4 seções do Foco; (b) `TextEditingController` ou `onSaved` no `MateriaFormScreen`; (c) erro de "nome de matéria já existe", vindo do servidor, dentro do campo ou em `SnackBar`; (d) marcar os obrigatórios ou os opcionais nos rótulos; (e) trocar Navigator + `onGenerateRoute` por `go_router` no projeto final. **Esperado:** em (e) você cita deep link e Flutter Web como o critério de desempate. [🔑 Gabarito](../gabaritos/07-navegacao-e-formularios.md#m07-e14)

[Módulo](../modulos/07-navegacao-e-formularios/README.md)
