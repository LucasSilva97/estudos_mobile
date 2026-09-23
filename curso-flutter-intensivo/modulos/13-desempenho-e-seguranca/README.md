# Módulo 13 — Desempenho, Acessibilidade e Segurança

> **Trilha:** Qualidade e plataforma · **Tempo estimado:** ~6 h de aulas + ~2 h de exercícios e avaliação · **Ritmo intensivo:** dia 24

No módulo anterior você aprendeu a **provar** que o app funciona: leu *stack traces* (a pilha de
chamadas que o Dart imprime quando algo explode), usou pontos de parada, escreveu testes de unidade,
de widget e de integração, e abriu o **DevTools** (o conjunto de ferramentas de inspeção que vem com
o Flutter) pela primeira vez.

Agora vem a pergunta seguinte, e ela é diferente: **o app funciona — mas funciona bem?**

Três coisas separam um app de estudante de um app publicável, e nenhuma delas aparece num teste que
passa:

1. **Desempenho.** A tela responde ao dedo em menos de 16 milissegundos ou trava e "engasga"?
2. **Acessibilidade.** Uma pessoa cega, ou alguém que aumentou a fonte do sistema para 200 %,
   consegue usar o seu app — ou ele simplesmente não existe para ela?
3. **Segurança.** O app roda no aparelho de um estranho. O que você colocou lá dentro está exposto?

Este módulo responde às três, sempre no domínio do projeto final **Foco — Organizador de Estudos**
(matérias, sessões de estudo, metas semanais e trilhas). Você vai criar **um único projeto de
laboratório**, `foco_desempenho`, na Aula 1, e fazer ele crescer até a Aula 7 — quando ele vira o
gabarito de qualidade que você aplica no Foco de verdade antes de publicar.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- Explicar **exatamente o que dispara um `build()`** no Flutter, por que ele roda dezenas de vezes
  por segundo e por que isso obriga o método `build` a ser barato.
- Usar `const`, **extração de widget** (em vez de método que devolve widget), `Consumer`,
  `ValueListenableBuilder` e `RepaintBoundary` para reduzir o escopo de cada reconstrução — e medir
  o ganho no DevTools em vez de adivinhar.
- Entender as quatro **Keys** (`ValueKey`, `ObjectKey`, `UniqueKey`, `GlobalKey`), reproduzir o bug
  clássico da lista reordenada sem key e corrigi-lo.
- Construir listas grandes com `ListView.builder`, `itemExtent`, `prototypeItem`, `cacheExtent`,
  **paginação** e rolagem infinita, sem travar e sem estourar memória.
- Carregar imagens do tamanho certo com `cacheWidth`/`cacheHeight`, `errorBuilder`, `loadingBuilder`
  e `precacheImage` — e calcular, em MB, quanta memória uma imagem consome depois de decodificada.
- Explicar por que a interface do Flutter roda em **uma única thread**, o que é **jank**, e por que
  `async`/`await` **não** cria thread nenhuma.
- Jogar trabalho pesado de CPU para outro isolate com `compute()` e `Isolate.run()` — e reconhecer
  quando isso **piora** o desempenho por causa do custo de copiar dados.
- Medir antes de otimizar: rodar em **modo profile**, ler o gráfico de frames do DevTools, separar
  **UI thread** de **raster thread**, achar o frame lento, marcar trechos com `Timeline`, analisar o
  tamanho do app com `--analyze-size` e o tempo de inicialização com `--trace-startup`.
- Tornar o app utilizável por leitor de tela (🤖 TalkBack, 🍎 VoiceOver) com `Semantics`,
  `semanticsLabel`, `MergeSemantics`, `ExcludeSemantics` e ordem de foco — respeitando contraste
  mínimo de **4.5:1**, área de toque de **48 dp** (🤖) / **44 pt** (🍎) e a escala de fonte do sistema.
- Aceitar a regra dura da segurança mobile: **nada dentro do app é secreto**. Saber onde ficam os
  segredos de verdade, como guardar o *token* do usuário com `flutter_secure_storage`, por que
  HTTPS é obrigatório, como evitar **SQL injection** com `whereArgs` e o que **nunca** versionar.
- Gerar um build ofuscado com `--obfuscate --split-debug-info`, guardar os símbolos para conseguir
  ler um *stack trace* de produção — e saber com precisão o que a ofuscação **não** protege.
- Rodar um **checklist final de qualidade** antes de publicar, com as más práticas que reprovam um
  app na revisão de código e na revisão das lojas.

---

## ✅ Pré-requisitos

| Requisito | Onde resolver |
|---|---|
| Flutter 3.47.1 instalado, `flutter doctor` sem erro bloqueante | [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) |
| Saber ler *stack trace*, usar breakpoints e abrir o DevTools | [Módulo 12 — Testes e Debug](../12-testes-e-debug/README.md) |
| Ter rodado testes de widget com `flutter test` | [12 — Testes de widget](../12-testes-e-debug/06-testes-de-widget.md) |
| `StatelessWidget`, `StatefulWidget`, `setState`, árvore de widgets | [Módulo 05 — Introdução ao Flutter](../05-introducao-ao-flutter/README.md) |
| `ListView.builder`, imagens e assets | [06 — Listas e rolagem](../06-widgets-e-layouts/09-listas-e-rolagem.md) e [06 — Imagens e assets](../06-widgets-e-layouts/08-imagens-e-assets.md) |
| `Future`, `async`/`await` e o *event loop* | [04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md) |
| Noção de isolate | [04 — Isolates e desempenho](../04-dart-avancado/08-isolates-e-desempenho.md) |
| Riverpod 3: `Notifier`, `AsyncNotifier`, `Consumer` | [Módulo 08 — Estado e Arquitetura](../08-estado-e-arquitetura/README.md) |
| `sqflite` com `where`/`whereArgs` | [10 — sqflite CRUD](../10-persistencia-de-dados/05-sqflite-crud.md) |

Confirme o ambiente antes de começar. No PowerShell:

```powershell
flutter --version
```

Você deve ver **Flutter 3.47.1** e **Dart 3.13.1**. Versão diferente, ou comando não reconhecido:
volte para [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

---

## 🗺️ Ordem recomendada das aulas

Siga **na ordem**. As aulas 1 a 4 formam um bloco (desempenho) que termina com a medição; a aula 5 é
acessibilidade; as aulas 6 e 7 fecham com segurança e o checklist de publicação.

| # | Aula | Tempo | O que você leva dela |
|---|---|---|---|
| 1 | [Rebuilds, const e keys](01-rebuilds-const-e-keys.md) | 55 min | O que dispara `build`, `const`, extrair widget, `RepaintBoundary`, as 4 Keys |
| 2 | [Listas grandes e imagens](02-listas-grandes-e-imagens.md) | 50 min | `ListView.builder`, `itemExtent`, paginação, `cacheWidth`, memória de imagem |
| 3 | [Assíncrono sem travar](03-assincrono-sem-travar.md) | 50 min | Thread única, jank, 16 ms, `compute()`, `Isolate.run`, quando **não** usar |
| 4 | [Medindo desempenho](04-medindo-desempenho.md) | 50 min | Modo profile, gráfico de frames, UI × raster, `Timeline`, `--analyze-size` |
| 5 | [Acessibilidade](05-acessibilidade.md) | 55 min | TalkBack/VoiceOver, `Semantics`, contraste 4.5:1, 48 dp/44 pt, escala de fonte |
| 6 | [Segurança mobile](06-seguranca-mobile.md) | 55 min | Nada é secreto no app, `--dart-define`, cofre de token, HTTPS, `whereArgs` |
| 7 | [Ofuscação e o que evitar](07-ofuscacao-e-o-que-evitar.md) | 45 min | `--obfuscate`, `flutter symbolize`, R8, más práticas, checklist final |

**Total das aulas: 360 min (= 6 h).**

No ritmo **Intensivo recomendado** (30 dias) este módulo ocupa o **dia 24**, junto com a avaliação
cumulativa 04:

| Bloco do dia 24 | Conteúdo | Tempo |
|---|---|---|
| Manhã | Aulas 1 a 4 (desempenho, do rebuild à medição) | 205 min |
| Tarde | Aulas 5 a 7 (acessibilidade e segurança) | 155 min |
| Prática | Exercícios obrigatórios + avaliação do módulo | ~2 h |

Se o dia ficar apertado, o corte honesto é este: leia as 7 aulas inteiras e adie **metade** dos
exercícios opcionais. Nunca pule a Aula 4 (medir) nem a Aula 6 (segurança) — são as duas que evitam
erro irreversível depois da publicação.

---

## 📝 Exercícios e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Lista de exercícios do módulo | [exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md) | Ao terminar cada aula, faça os exercícios que citam aquele assunto |
| Avaliação do módulo | [avaliacoes/modulo-13-desempenho-e-seguranca.md](../../avaliacoes/modulo-13-desempenho-e-seguranca.md) | Só depois das 7 aulas e dos exercícios obrigatórios |

Os gabaritos ficam em `gabaritos/13-desempenho-e-seguranca.md` e estão linkados dentro de cada
exercício. A regra deste módulo é diferente da dos outros: **quase todo exercício pede um número**.
"Ficou mais rápido" não vale; "caiu de 11,2 ms para 3,4 ms na UI thread, medido em modo profile no
aparelho X" vale. Desempenho sem medida é superstição.

---

## 🧰 O projeto que acompanha o módulo

Na Aula 1 você cria **um único projeto de laboratório** e usa ele até o fim:

```powershell
flutter create foco_desempenho
```

Depois, dentro da pasta criada:

```powershell
flutter pub add flutter_riverpod
flutter pub add flutter_secure_storage
flutter pub add sqflite path
```

A pasta `lib/` cresce assim, aula por aula — e repare que a organização é **a mesma** do projeto
final descrito em [05-decisoes-tecnicas.md](../../05-decisoes-tecnicas.md):

```text
foco_desempenho/
├── pubspec.yaml                                        ← editado nas aulas 1, 2 e 6
├── assets/
│   └── imagens/                                        ← Aula 2
├── .gitignore                                          ← Aula 6 (o que NUNCA versionar)
└── lib/
    ├── main.dart                                       ← Aula 1 → cresce até a Aula 7
    ├── core/
    │   ├── perf/marcadores.dart                        ← Aula 4
    │   └── seguranca/
    │       ├── config_app.dart                         ← Aula 6 (--dart-define)
    │       └── cofre_token.dart                        ← Aula 6 (flutter_secure_storage)
    └── features/
        ├── materias/
        │   ├── data/materia_dao.dart                   ← Aula 6 (whereArgs)
        │   ├── domain/materia.dart                     ← Aula 1
        │   └── presentation/
        │       ├── rebuilds_demo_screen.dart           ← Aula 1
        │       ├── lista_grande_screen.dart            ← Aula 2
        │       └── widgets/
        │           ├── materia_tile.dart               ← Aula 1 → 5
        │           └── capa_materia.dart               ← Aula 2
        ├── estatisticas/
        │   ├── domain/calculo_pesado.dart              ← Aula 3
        │   └── presentation/relatorio_screen.dart      ← Aula 3 → 4
        └── sessoes/
            └── presentation/sessao_screen.dart         ← Aula 5 (acessibilidade)
```

Sempre que uma aula mostrar código completo, ela diz **o caminho exato do arquivo** e o **comando
exato** para rodar. Digite o código; não copie e cole — este módulo inteiro se aprende observando o
que muda quando você mexe em uma linha.

### 🪟 Você está no Windows e não tem Mac — o que dá e o que não dá

Este módulo é o mais honesto do curso sobre isso, porque desempenho depende de hardware real.

| Aula | 🪟 No Windows você consegue | ❌ Precisa de outra coisa |
|---|---|---|
| 1 — Rebuilds | Tudo: `flutter run -d windows` e DevTools funcionam | — |
| 2 — Listas e imagens | Tudo, inclusive medir memória de imagem | Memória **real** de celular só num aparelho |
| 3 — Assíncrono | Tudo: isolates funcionam igual no desktop | — |
| 4 — Medindo | Modo profile **no Android** (aparelho ou via cabo) | 🍎 Profile no iPhone exige Mac |
| 5 — Acessibilidade | `SemanticsDebugger`, testes automáticos de contraste e toque | 🤖 TalkBack exige Android; 🍎 VoiceOver exige iPhone |
| 6 — Segurança | Tudo que é código; inspecionar o APK | 🍎 Keychain só se vê rodando no iOS |
| 7 — Ofuscação | `flutter build apk --obfuscate` e `flutter symbolize` | 🍎 `flutter build ipa` só no Mac |

> 🍎 **SÓ NO MAC.** Testar VoiceOver, gerar `.ipa` ofuscado e medir desempenho em iPhone exigem
> macOS + Xcode. No Windows você lê, entende e prepara tudo; a execução fica para quando houver um
> Mac. O porquê disso está em
> [16-build-ios/01-por-que-exige-macos.md](../16-build-ios/01-por-que-exige-macos.md).

Se você ainda **não instalou o Android SDK**, as aulas 1, 2, 3, 5 (parte automática), 6 (código) e a
teoria da 7 rodam inteiras com:

```powershell
flutter run -d windows
```

A instalação do Android SDK está em
[02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) e é pré-requisito do
[Módulo 15 — Build Android](../15-build-android/README.md).

---

## 🔗 Como este módulo se conecta ao resto do curso

| O que você aprende aqui | Onde reaparece |
|---|---|
| `const` e extração de widget | [Projeto final — Etapa 6](../../projetos/03-projeto-final-multiplataforma/08-etapa-6-responsividade-e-acessibilidade.md) |
| `ListView.builder` e paginação | [09 — API com Riverpod](../09-consumo-de-api/09-api-com-riverpod.md) |
| `compute()` e isolates | [04 — Isolates e desempenho](../04-dart-avancado/08-isolates-e-desempenho.md) |
| Modo profile e release | [15 — Debug, profile e release](../15-build-android/01-debug-profile-release.md) |
| `Semantics` e contraste | [06 — Texto, tipografia e ícones](../06-widgets-e-layouts/02-texto-tipografia-icones.md) |
| Área de toque de 48 dp | [06 — Gestos e feedback](../06-widgets-e-layouts/10-gestos-e-feedback.md) |
| `flutter_secure_storage` | [10 — Dados sensíveis](../10-persistencia-de-dados/07-dados-sensiveis.md) |
| Token e cabeçalho `Authorization` | [09 — Autenticação e tokens](../09-consumo-de-api/08-autenticacao-e-tokens.md) |
| O que não versionar | [00 — Desfazendo erros e segredos](../00-git-e-terminal/05-desfazendo-erros-e-segredos.md) |
| `--obfuscate` no build final | [15 — Gerando APK e AAB](../15-build-android/08-gerando-apk-e-aab.md) |
| Medir antes de otimizar | [14 — Como o Flutter compila para web](../14-build-web-pwa/02-como-o-flutter-compila-para-web.md) |
| "Segredo mora no servidor" | [14 — Gerando o build web](../14-build-web-pwa/08-gerando-o-build-web.md) — na web vira restrição absoluta |
| `Semantics` na web | [14 — Como o Flutter compila para web](../14-build-web-pwa/02-como-o-flutter-compila-para-web.md) |
| Checklist antes de publicar | [checklists/build-web.md](../../checklists/build-web.md), [checklists/build-android.md](../../checklists/build-android.md) e [checklists/projeto-final.md](../../checklists/projeto-final.md) |

O módulo seguinte, [14 — Build Web (PWA)](../14-build-web-pwa/README.md), pega o app já rápido,
acessível e seguro e o coloca **no ar, numa URL pública, instalável e funcionando offline** — o
canal principal de distribuição deste curso. Depois dele vêm os canais nativos:
[15 — Build Android](../15-build-android/README.md), com o **APK e o AAB assinados**, e
[16 — Build iOS](../16-build-ios/README.md).

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando for verdade de fato. Este é o portão de entrada do módulo 15.

- [ ] Li as **7 aulas** inteiras, na ordem.
- [ ] Criei o projeto `foco_desempenho` e ele roda sem erro (`flutter run -d windows` ou no Android).
- [ ] Digitei e rodei o **código completo** das 7 aulas.
- [ ] Explico, sem consultar, as quatro coisas que disparam um `build()`.
- [ ] Coloquei `const` onde era possível e **vi no DevTools** a contagem de rebuilds cair.
- [ ] Reproduzi o bug da **lista reordenada sem key** e corrigi com `ValueKey`.
- [ ] Sei dizer quanta memória uma imagem de 4000 × 3000 ocupa depois de decodificada, e por que
      `cacheWidth` resolve isso.
- [ ] Provoquei **jank de propósito** com um laço pesado no `build` e depois corrigi com `compute()`.
- [ ] Rodei o app em **modo profile** e li o gráfico de frames, separando UI thread de raster thread.
- [ ] Rodei `flutter build apk --analyze-size` e sei qual é a maior parte do meu app.
- [ ] Liguei um leitor de tela (ou o `SemanticsDebugger`) e navegei pelo app inteiro **sem olhar**.
- [ ] Todo botão só de ícone do meu app tem rótulo acessível e pelo menos 48 × 48 dp.
- [ ] Meu app continua legível com a fonte do sistema no máximo.
- [ ] Não existe **nenhuma** senha, token ou chave no meu código, e meu `.gitignore` cobre
      `key.properties`, `*.jks`, `*.p12`, `*.mobileprovision` e `.env`.
- [ ] Toda consulta ao sqflite usa `whereArgs`, nunca interpolação de string.
- [ ] Gerei um build com `--obfuscate --split-debug-info=build/symbols` e **guardei os símbolos**.
- [ ] Passei o app inteiro pelo checklist final da Aula 7 e não sobrou item vermelho.
- [ ] Rodei `flutter analyze` **sem nenhum aviso**.
- [ ] Fiz **todos os exercícios obrigatórios** de [exercicios/13-desempenho-e-seguranca.md](../../exercicios/13-desempenho-e-seguranca.md).
- [ ] Acertei **7 ou mais** das 10 questões de [avaliacoes/modulo-13-desempenho-e-seguranca.md](../../avaliacoes/modulo-13-desempenho-e-seguranca.md).

Se algum item ficou desmarcado, a tabela "Se você teve dificuldade" da avaliação diz exatamente qual
aula revisar.

---

| ⬅️ Módulo anterior | 🏠 Curso | ➡️ Próximo módulo |
|---|---|---|
| [12 — Testes e Debug](../12-testes-e-debug/README.md) | [README do curso](../../README.md) | [14 — Build Web (PWA)](../14-build-web-pwa/README.md) |
