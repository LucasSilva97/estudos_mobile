# Avaliação final — Curso intensivo de Flutter

> **Tempo sugerido:** 40 min de questões + 20 min de diagnóstico + 4 h de prática.
> As partes 1 e 2 são sem consultar nada. Na parte 3, consultar é parte do trabalho — ninguém
> entrega app de memória.

Esta avaliação não pergunta se você lembra do curso. Ela pergunta se você **entrega um app**.
São 64 pontos: 16 no questionário, 8 no diagnóstico e 40 na prática.

---

## 1. Questionário

Questões 1 a 10 valem 1 ponto cada; 11 a 16 também.

1. No Foco, modelar as falhas de rede com `sealed class Falha` e `switch` exaustivo dá uma garantia que `try/catch` com `dynamic` não dá: A) captura erros que o `catch` não captura; B) o compilador acusa toda vez que você cria uma falha nova e esquece de tratá-la em algum lugar; C) evita o timeout; D) dispensa o `await`.  
2. Dentro de um método de `AsyncNotifier` (Riverpod 3), depois de um `await` e antes de escrever em `state`, você precisa: A) chamar `setState`; B) conferir `ref.mounted`, porque usar um notifier já descartado agora lança erro; C) ler `AsyncValue.valueOrNull`; D) envolver a chamada em um novo `ProviderScope`.  
3. Abrir o formulário de matéria passando o objeto e receber o resultado de volta, com `onGenerateRoute`, se faz com: A) `await Navigator.pushNamed(context, Rotas.materiaForm, arguments: materia)` e `Navigator.pop(context, resultado)` na volta; B) uma variável global lida no `initState`; C) uma `GlobalKey` na tela de destino; D) `go_router`, que é o único com suporte a argumento.  
4. Você precisa adicionar a coluna `cor` na tabela `materia` de um app já instalado no celular de alguém: A) apagar e recriar o banco no `onCreate`; B) subir `version` e, no `onUpgrade`, rodar `ALTER TABLE materia ADD COLUMN cor TEXT`; C) migrar as matérias para `shared_preferences`; D) recriar a tabela a cada `openDatabase`.  
5. A aba Trilhas chama a API com `package:http` e o celular está em rede ruim, sem responder. Sem `timeout`: A) o `http` cancela sozinho em 30 s; B) o Flutter mostra um erro padrão; C) o `Future` fica pendente indefinidamente e a tela trava em "carregando" sem nunca virar erro; D) o `AsyncValue` vira `error` automaticamente.  
6. Um `ListView` colocado dentro de uma `Column` dentro de um `SingleChildScrollView` estoura com *unbounded height* porque: A) o pai oferece altura infinita e o `ListView` quer ocupar toda a altura disponível; B) `Column` não aceita filhos roláveis; C) falta `const` no `ListView`; D) o `Scaffold` está sem `body`.  
7. Para testar `MateriasController` sem encostar no sqflite: A) rodar `flutter test` com o emulador aberto; B) marcar o teste com `skip` até dar tempo; C) criar um `ProviderContainer` com `overrides` trocando o provider do repositório por um `Mock` do mocktail, com `thenAnswer` nos métodos que devolvem `Future`; D) usar o sqflite real, que funciona igual em teste.  
8. A aba Estatísticas engasga ao somar 50 000 sessões. Antes de sair escrevendo `Isolate.run`, o primeiro passo é: A) medir em modo profile, no aparelho, e ver se a barra alta é a de UI ou a de raster; B) espalhar `const` por todos os widgets; C) trocar `ListView.builder` por `Column`; D) medir em release, que é mais rápido.  
9. Você gera o release com `--obfuscate --split-debug-info=simbolos/1.0.0` e depois apaga a pasta `simbolos/`: A) nada muda, o Flutter guarda uma cópia no build; B) o app deixa de abrir; C) todo stack trace que chegar da loja fica ilegível e sem como desofuscar — para sempre, para aquela versão; D) o `apksigner verify` passa a falhar.  
10. No Windows 11, o máximo que você consegue fazer pelo lado iOS do Foco é: A) gerar o IPA com `flutter build ipa --no-codesign`; B) rodar no simulador do Xcode a partir do emulador Android; C) preparar Bundle ID, ícone, `version` e `Info.plist`, deixando archive, assinatura e envio para um Mac ou um runner macOS na CI; D) nada — o projeto nem compila sem Xcode.

11. Diga **quando não usar** `Isolate.run` no Foco, mesmo o trabalho parecendo pesado, e por quê.  
12. Explique por que a App Store não tem rollback de versão como a Google Play tem, e o que isso muda de concreto no seu processo de release.  
13. O Foco poderia guardar tudo em `shared_preferences`. Dê o critério técnico que manda matérias e sessões para o `sqflite` e mantém a meta semanal fora dele.  
14. Faltam duas horas para entregar. Você tem um teste de widget instável, `flutter analyze` com 12 apontamentos `info` e a aba Trilhas sem nenhum tratamento de erro. Diga a ordem em que você ataca e justifique cada posição.  
15. Argumente em que momento trocar `Navigator` + `onGenerateRoute` por `go_router` no Foco — e por que essa troca não se justifica agora.  
16. Ofuscação não é segurança. Explique o que ela de fato entrega e o que você faria com uma chave de API que não pode aparecer dentro do app.

---

## 2. Diagnóstico

Quatro situações reais. Para cada uma, responda **duas coisas**: qual a causa mais provável e
qual o **primeiro comando** que você roda. Cada cenário vale 2 pontos (1 para a causa, 1 para o
comando). Chutar a ferramenta certa pelo motivo errado não vale ponto.

**D1 — O trace que não diz nada.** O painel de qualidade da Play Console mostra, no Foco 1.0.0:

```text
Unhandled Exception: Bad state: No element
#0   pk (package:foco/ab.dart:1:4923)
#1   qz.<anonymous closure> (package:foco/ab.dart:1:5210)
```

**D2 — A assinatura que não existe.** O build de release do iOS, rodando num runner macOS da CI:

```text
error: No profiles for 'br.com.estudos.foco' were found: Xcode couldn't find any
iOS App Development provisioning profiles matching 'br.com.estudos.foco'.
```

**D3 — O engasgo.** No aparelho, em modo profile, abrir a aba Estatísticas congela a tela por
cerca de 600 ms. No DevTools, a barra de **UI** está alta e a de **raster** está baixa.

**D4 — Só quebra em release.** `flutter run` no aparelho funciona. O APK de release instala,
abre, e fecha sozinho ao entrar na aba Trilhas — sem caixa vermelha e sem nada em `flutter logs`.

---

## 3. Prática — entregar o Foco

Entregue o app **Foco** (`br.com.estudos.foco`, `version: 1.0.0+1`) como se fosse para a loja
amanhã: matérias e sessões em `sqflite`, meta semanal em `shared_preferences`, trilhas vindas da
API, cinco telas navegadas por `onGenerateRoute` e estado em Riverpod 3 sem *code generation*.
Feche com a suíte de testes verde, o release Android assinado e um `docs/release-1.0.0.md`
com os comandos usados e as saídas que comprovam cada item da tabela.

> 🍎 **O que exige Mac.** Archive, assinatura e IPA do iOS **não rodam no Windows**. Entregue a
> preparação (Bundle ID nas três configurações, ícone sem canal alfa, `Info.plist` ligado a
> `$(FLUTTER_BUILD_NAME)`) e descreva o roteiro do Mac. A alternativa aceita, e a única que
> automatiza isso sem comprar hardware, é um **runner macOS na CI** —
> [Aula 16/04](../modulos/16-publicacao-e-proximos-passos/04-ci-cd-introdutorio.md).

| Critério | Pontos |
|---|---:|
| Domínio puro (`Materia`, `Sessao`, `MetaSemanal`) sem um único import de Flutter, com testes cobrindo lista vazia, fronteira exata da meta e a exceção do construtor | 5 |
| Estado em Riverpod 3 sem *code generation*: `AsyncNotifier` + `AsyncValue` desenhando os quatro estados (carregando, vazio, erro, dados) em todas as abas que carregam dado | 5 |
| Persistência com migração provada: banco v1 → v2 por `onUpgrade`, com evidência de que os dados anteriores sobreviveram | 5 |
| API de trilhas com `timeout`, falha modelada em `sealed class` e comportamento offline previsível (cache ou mensagem, nunca tela branca) | 5 |
| Navegação por `onGenerateRoute` com argumento e resultado, formulário validado e `PopScope` avisando ao sair com alterações não salvas | 4 |
| Acessibilidade: rótulo semântico nos ícones, alvo de toque de 48 dp, contraste do tema e fonte a 200% sem overflow | 4 |
| Testes: unitários, de widget e um de integração, com mocktail e `overrides`; `flutter analyze --fatal-infos` e `dart format` sem apontamentos | 4 |
| Feature-first respeitado: `presentation` nunca importa `data` direto, sempre pelo contrato em `domain` | 3 |
| Release Android assinado: `key.properties` fora do Git, AAB e APK `arm64-v8a` gerados, `apksigner verify --print-certs` colado no relatório | 3 |
| Ofuscação com `--split-debug-info=simbolos/1.0.0` e os símbolos arquivados por versão, fora do build | 2 |

---

## 4. Critérios de aprovação

Não há aprovação sem estes quatro, independentemente da nota:

- `flutter analyze --fatal-infos` limpo e `flutter test` verde, sem nenhum `skip`.
- `flutter build appbundle --release` concluindo com assinatura própria.
- `git status` sem `key.properties`, `*.jks`, `*.keystore` ou `.env`.
- [Checklist do projeto final](../checklists/projeto-final.md) preenchido com evidência, não de memória.

### O que fazer conforme a faixa

| Faixa | O que isso significa | O que fazer antes de tentar de novo |
|---|---|---|
| **55–64** | Você entrega. O que falta é repetição, não conteúdo. | Siga para [16/06 — Próximos passos](../modulos/16-publicacao-e-proximos-passos/06-proximos-passos.md) e comece o segundo app do zero, sem consultar o Foco. |
| **45–54** | Aprovado com dívida. Costuma ser teste ou build frágil. | Refaça os exercícios de [M12](../exercicios/12-testes-e-debug.md) (E05–E08) e [M14](../exercicios/14-build-android.md) (E06–E08); repita só as partes 2 e 3. |
| **32–44** | O app existe, mas a arquitetura não se sustenta: estado espalhado, `data` importada na tela, falha engolida. | Releia [08/09 — Feature-first](../modulos/08-estado-e-arquitetura/09-arquitetura-feature-first.md) e [09/04 — Modelando respostas e erros](../modulos/09-consumo-de-api/04-modelando-respostas-e-erros.md); refaça [M08](../exercicios/08-estado-e-arquitetura.md) E06–E10 e reescreva **uma** feature inteira antes de voltar. |
| **0–31** | A base assíncrona e de dados não fechou. Continuar daqui só acumula retrabalho. | Volte a [04/02](../modulos/04-dart-avancado/02-futures-e-async-await.md), [04/06](../modulos/04-dart-avancado/06-sealed-classes.md) e [10/06 — Migrações](../modulos/10-persistencia-de-dados/06-migracoes.md); refaça [M04](../exercicios/04-dart-avancado.md) e [M10](../exercicios/10-persistencia-de-dados.md) inteiros e repita a avaliação completa. |

**Se você errou o diagnóstico mas passou no resto:** o problema é rotina de investigação, não
conhecimento. Releia [12/01 — Lendo stack traces](../modulos/12-testes-e-debug/01-lendo-stack-traces.md),
[12/09 — Depurando Android e iOS](../modulos/12-testes-e-debug/09-depurando-android-e-ios.md) e
[13/04 — Medindo desempenho](../modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md), e
refaça a parte 2 daqui a uma semana, sem reler as respostas.

[Gabarito após concluir](../gabaritos/avaliacoes.md#avaliacao-final)
