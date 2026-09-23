# Testes — Projeto 01: Meu Primeiro App

> **Pasta:** `meu_primeiro_app` · **Tempo:** ~25 min · **Referência:**
> [01-especificacao.md](01-especificacao.md) · **Código:** [03-codigo-completo.md](03-codigo-completo.md)

Este projeto é do **Dia 7**. Teste automatizado (`flutter test`, `WidgetTester`, `mocktail`) só chega
no [Módulo 12](../../modulos/12-testes-e-debug/README.md) — então aqui você testa do jeito que todo
desenvolvedor testa antes de aprender a automatizar: **com o app aberto e uma lista na mão**.

> ⚠️ O `flutter create` deixa um `test/widget_test.dart` que testa o app-contador de exemplo: ele
> chama `MyApp()`, que **não existe** neste projeto, e derruba o `flutter analyze` — ou seja, quebra
> o RF20. **Apague esse arquivo.** Você escreve o seu no Módulo 12.

---

## 🛠️ Antes de começar

```powershell
flutter analyze          # precisa responder: No issues found!
flutter run -d chrome    # ou: flutter run -d windows
```

> 📌 Faça o roteiro inteiro **duas vezes**: uma no tema claro, outra no escuro. Metade dos defeitos
> deste projeto é cor errada, e no tema claro eles ficam invisíveis.

---

## 🧪 Roteiro de verificação

Cada linha é um "sim ou não". Se a coluna da direita não bateu **exatamente**, o requisito falhou.

| # | O que fazer | O que deve acontecer |
|---|---|---|
| 1 | Rodar o app | Abre direto na `HomeTela`. Não há tela de carregamento nem seta de voltar na `AppBar`. · **RF01** |
| 2 | Olhar a `AppBar` | Título `Meu Primeiro App` à esquerda e **um** ícone à direita. Mais nada. · **RF02** |
| 3 | Passar o mouse (ou segurar o dedo) sobre o ícone de tema | Tooltip `Tema: automático`, ícone `brightness_auto_outlined` — é o estado inicial. · **RF03** |
| 4 | Tocar no ícone 3 vezes, olhando a cada toque | `Tema: claro` (☀), `Tema: escuro` (🌙) e volta a `Tema: automático`. O layout não se mexe, só as cores. · **RF03** |
| 5 | Comparar claro e escuro lado a lado | Mesma identidade índigo nos dois; nada sumiu, nenhum texto ficou cinza sobre cinza. · **RF04** |
| 6 | Procurar cor literal fora de `lib/tema/` (comando abaixo da tabela) | O único resultado é `tema_app.dart`, na linha de `_semente`. · **RF05** |
| 7 | Contar os cartões, rolando até o fim | Exatamente 4: **Dart**, **Flutter**, **Git e terminal**, **Testes**. · **RF06** |
| 8 | Olhar a tela recém-aberta | O cartão **Dart** está destacado e o rodapé diz `Recebendo minutos: Dart`. · **RF07** |
| 9 | Tocar no cartão **Flutter** | SnackBar `As próximas sessões contam para Flutter.`; o resumo passa a `Em foco: Flutter`; o rodapé acompanha. · **RF08** |
| 10 | Comparar o cartão selecionado com os outros três | Fundo diferente e borda mais grossa — dá para ver de relance qual é. · **RF09** |
| 11 | Olhar o `SegmentedButton` | Três opções, `15 min` · `25 min` · `50 min`, com **25 min** já marcado. · **RF10** |
| 12 | Tocar em `50 min` | A marcação muda e o painel passa a dizer `50 min por sessão em Flutter`. · **RF10** |
| 13 | Voltar para `25 min`, selecionar **Dart** e tocar `Concluir sessão` | Contador `0` → `1`; resumo `1` / `25` / `25 min`; o cartão Dart vai de `1 h 35 min` para `2 h`; SnackBar `+25 min em Dart.` · **RF11** |
| 14 | Tocar no botão `−` (tooltip `Remover uma sessão`) | Tudo volta: `0` sessões, `0` minutos, Dart de novo em `1 h 35 min`; SnackBar `−25 min em Dart.` · **RF12** |
| 15 | Com `0` sessões, olhar os botões `−` e `↺` | Apagados, sem efeito de toque, e tocar neles não faz nada. · **RF13** |
| 16 | Concluir 3 sessões e tocar `↺` (tooltip `Zerar o dia`) | Sessões e minutos zeram; os 4 cartões voltam a 95 / 40 / 20 / 0 min; SnackBar `Dia zerado. As matérias voltaram aos minutos iniciais.` · **RF14** |
| 17 | Olhar qualquer cartão de perto | Ícone redondo, nome, `<tempo> de <meta> min` e barra de progresso — nessa ordem. · **RF15** |
| 18 | Selecionar **Testes**, duração `50 min`, concluir **2** sessões | O cartão mostra `1 h 40 min de 60 min` e a barra **para cheia**, sem vazar para fora do canto arredondado. · **RF16** |
| 19 | Continuar olhando o cartão **Testes** | Apareceu um ✔ ao lado do nome. Ele some se você remover sessões até ficar abaixo de 60 min. · **RF17** |
| 20 | Conferir os quatro formatos de tempo | Testes zerado → `0 min`; Git → `20 min`; Dart → `1 h 35 min`; Dart após uma sessão de 25 → `2 h`. · **RF18** |
| 21 | Zerar o dia e olhar a `Média` no resumo | Mostra `—`. Se aparecer `NaN min`, a divisão por zero escapou. · **RF19** |
| 22 | Fechar o app e abrir de novo | Volta tudo ao inicial — **é o esperado**, este projeto não grava nada. · **RF20** |
| 23 | Rodar `flutter analyze` | `No issues found!` · **RF20** |
| 24 | Estreitar a janela até ~320 px de largura | Nenhuma faixa listrada amarela e preta (`RenderFlex overflowed`). Os textos longos terminam em `…`. · **RF20** |

Comando do item 6, na raiz do projeto:

```powershell
Get-ChildItem lib -Recurse -Filter *.dart | Select-String -Pattern 'Colors\.', 'Color\(0x'
```

---

## 🔍 Casos-limite

O caminho feliz quase sempre funciona. Os defeitos moram aqui.

| Caso | Como provocar | O que deve acontecer |
|---|---|---|
| **Piso do zero** | Com `0` sessões, tentar `−` e `↺` | Nada acontece. Botão desabilitado **e** o `if` de guarda dentro do método — cinto e suspensório. |
| **Minutos negativos** | Selecionar **Dart**, duração `50`, concluir 1 sessão; trocar para **Git e terminal** e tocar `−` | Sessões voltam a `0`, minutos totais a `0`, e Git cai de `20 min` para `0 min` — **nunca** para `−30 min`. Quem perde minutos é a matéria selecionada **agora**, não a que ganhou. |
| **Trocar a duração no meio** | Concluir com `50 min`, mudar para `15 min`, tocar `−` | Sai 1 sessão e apenas **15** minutos. Não é bug: o RF12 manda usar a duração **atual**. Só confirme que nada ficou negativo. |
| **Teto dos 100 %** | Concluir sessões em **Testes** até passar de `60 min` | A barra trava cheia; o texto continua subindo (`2 h 30 min de 60 min`). Barra estourada = faltou o `clamp` no `progresso`. |
| **Toque duplo rápido** | Dois toques em `Concluir sessão` em menos de meio segundo | O contador vai a `2` e aparece **um** SnackBar, o da última ação. Se as mensagens entrarem em fila, faltou `hideCurrentSnackBar()`. |
| **Números grandes** | Cerca de 20 sessões de `50 min` (1000 minutos) | O resumo continua em três colunas de larguras iguais; se não couber, o número trunca com `…`. Overflow não é aceitável. |
| **Nome longo em tela estreita** | Selecionar **Git e terminal** com a janela em ~320 px | O nome trunca com `…` no cartão e em `Em foco:`. A barra de progresso não encolhe nem some. |
| **Tema no meio da ação** | Concluir uma sessão e trocar o tema enquanto o SnackBar ainda está na tela | O app repinta inteiro, o SnackBar junto, sem piscar e sem perder o contador. |
| **Redimensionar com o dia cheio** | Concluir 5 sessões e arrastar a borda da janela | O estado sobrevive: redimensionar não recria o `State`, e `setState` guarda em memória. |
| **Rolagem até o fim** | Rolar até o rodapé em tela baixa (celular deitado) | `Recebendo minutos: <matéria>` continua alcançável — o `ListView` rola, nada fica preso atrás da barra inferior. |

---

## 🤖🍎 Conferir nas duas plataformas

Você está no **Windows 11**: Android roda aqui (emulador ou aparelho no cabo), iOS **não** —
compilar para iPhone exige um Mac com Xcode ou um runner macOS em CI. Sem Mac, rode `-d chrome` /
`-d windows` e leia a tabela como "o que eu preciso saber quando um iPhone aparecer".

| O que muda | Android 🤖 | iOS 🍎 |
|---|---|---|
| **Fonte do sistema** | Roboto | San Francisco, mais estreita: o texto que coube no Pixel pode truncar antes — ou sobrar espaço. Confira os `…` dos cartões. |
| **Título da `AppBar`** | À esquerda | O Flutter centralizaria por padrão, mas `centerTitle: false` no `TemaApp` fixa à esquerda nos dois. É intencional: mesmo app, mesma leitura. |
| **Área segura de baixo** | Barra de navegação ou 3 botões | Barra de gestos do iPhone. O `SafeArea(top: false)` é o que impede o rodapé e o SnackBar de ficarem embaixo dela — confira nos dois. |
| **Rolagem do `ListView`** | Brilho/esticada na ponta | Efeito elástico (*bounce*). Comportamento nativo, não é defeito. |
| **Gesto de voltar** | Botão/gesto fecha o app | Não existe voltar na raiz. Tela única, sem `Navigator`: nos dois casos não há para onde voltar. |
| **Tooltip dos ícones** | Toque longo | Toque longo também, mas ninguém tem esse hábito no iOS — por isso `−`, `+` e `↺` precisam se explicar pelo próprio ícone. |
| **Tema do sistema** | Configurações › Tela › Tema escuro | Ajustes › Tela e Brilho. Com o app em `Tema: automático`, mudar lá fora tem que repintar o app **sem reiniciar**. |

```powershell
flutter devices                    # veja o que está disponível
flutter run -d chrome              # o mais rápido para iterar
flutter run -d windows             # janela nativa: boa para testar os 320 px
flutter run -d emulator-5554       # emulador Android
```

> 🍎 Nenhum requisito do Projeto 01 depende de iOS. Se você não tem Mac, marque as linhas 🍎 do
> registro como "não verificado" e siga em frente — isso volta no [Módulo 16](../../modulos/16-build-ios/README.md).

---

## 📋 Registro

Marque `✅` só quando o item passou **do começo ao fim**. Meio caminho é `❌`.

| Bloco | Itens do roteiro | Claro | Escuro | Observação |
|---|---|---|---|---|
| Abertura e `AppBar` | 1–2 | ☐ | ☐ | |
| Ciclo de tema | 3–5 | ☐ | ☐ | |
| Cores só do `colorScheme` | 6 | ☐ | ☐ | |
| Matérias e seleção | 7–10 | ☐ | ☐ | |
| Duração da sessão | 11–12 | ☐ | ☐ | |
| Concluir e remover | 13–14 | ☐ | ☐ | |
| Botões desabilitados | 15 | ☐ | ☐ | |
| Zerar o dia | 16 | ☐ | ☐ | |
| Cartão, progresso e selo | 17–19 | ☐ | ☐ | |
| Tempo formatado e média | 20–21 | ☐ | ☐ | |
| `analyze` e 320 px | 22–24 | ☐ | ☐ | |
| Casos-limite | todos | ☐ | ☐ | |
| Android 🤖 | tabela de plataformas | ☐ | ☐ | |
| iOS 🍎 (só com Mac ou CI) | tabela de plataformas | ☐ | ☐ | |

> 📌 Alguma linha vermelha? Não siga para os [desafios](05-desafios.md). Abra o
> [03-codigo-completo.md](03-codigo-completo.md) **no arquivo daquele requisito** e compare só ele:
> reler os 8 arquivos não acha bug, comparar o arquivo certo acha.

---

## 🤖 No Módulo 12 você automatiza isto

Cada linha do roteiro vira um `testWidgets` de 5 a 10 linhas, e o computador passa a rodar as 24 em
2 segundos toda vez que você salvar. O item 13, por exemplo, fica mais ou menos assim —
**não escreva agora**, é só para ver onde essa lista vai parar:

```dart
// Prévia do Módulo 12 — NÃO faz parte do Projeto 01.
testWidgets('concluir sessão soma na matéria selecionada', (WidgetTester tester) async {
  await tester.pumpWidget(const MeuPrimeiroApp());
  await tester.tap(find.text('Concluir sessão'));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
});
```

> 💡 Não é coincidência que isso caiba em 5 linhas: `ContadorSessoes` e `CartaoMateria` são
> `StatelessWidget` que só recebem dados e devolvem `VoidCallback`. Widget sem estado próprio é
> widget que o teste monta sozinho. Você já escreveu código testável — só ainda não escreveu o teste.

---

| Arquivo | Para quê |
|---|---|
| [README](README.md) | Visão geral |
| [01-especificacao](01-especificacao.md) | O que construir |
| [02-passo-a-passo](02-passo-a-passo.md) | Construção guiada |
| [03-codigo-completo](03-codigo-completo.md) | Arquivos finais |
| **04-testes.md** | 📍 Você está aqui |
| [05-desafios](05-desafios.md) | Extensões ([gabarito](../../gabaritos/projeto-01-desafios.md)) |
| [06-checklist](06-checklist.md) | Critérios de "pronto" |
