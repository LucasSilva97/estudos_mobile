# Módulo 14 — Build e Distribuição Web (PWA)

> **Tempo estimado total:** 450 min (7 h 30) · **Nível:** Avançado · **Posição no plano:** Dia 28 do ritmo intensivo de 30 dias

Este é o módulo em que o seu projeto ganha **um endereço**. Não um arquivo que alguém precisa baixar,
instalar e autorizar — um link. Você manda `https://seu-usuario.github.io/foco/` para uma pessoa,
ela abre, usa. Se quiser, ela toca em "Instalar" e o Foco passa a ter ícone na tela inicial, abrir
em tela cheia, sem barra de navegador, e funcionar sem internet. Isso é um **PWA**: *Progressive Web
App*, um aplicativo web que se comporta como aplicativo instalado.

**Neste curso, o PWA é o canal principal de distribuição do Foco.** Os módulos seguintes — Android e
iOS — continuam valendo e continuam obrigatórios, mas entram como canais **adicionais**. A razão é
prática e você vai conferir na Aula 1: o PWA é o único canal que você publica **hoje, inteiro, desta
máquina Windows**, sem pagar nada, sem esperar revisão humana e sem depender de um Mac que você não
tem. O `.aab` da Google Play custa US$ 25 e uma conta verificada; o `.ipa` da App Store custa
US$ 99 por ano e um macOS. O PWA custa um repositório no GitHub.

Usamos o app final do curso, **Foco: Organizador de Estudos**, em todos os exemplos. No Android ele
é identificado por `br.com.estudos.foco`; na web, a identidade dele é a **URL** — e você vai
descobrir, na Aula 5, que isso muda mais coisas do que parece.

> 🌐 Este módulo inteiro roda **no Windows 11, do começo ao fim**, sem emulador, sem SDK nativo e
> sem cabo USB. É o único módulo de build do curso do qual isso é verdade.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- Explicar o que é um **PWA**, o que ele entrega de verdade e o que ele **não** entrega — comparando
  honestamente com APK/AAB e IPA, sem vender o canal que este curso escolheu.
- Entender como o Flutter **compila Dart para a web**: `dart2js`, WebAssembly, o renderizador
  CanvasKit, o que cada arquivo em `build/web/` faz e por que o **primeiro carregamento** é a métrica
  que substitui "tamanho do app".
- Saber **o que quebra na web** e por quê: `dart:io`, `Platform.isAndroid`, `path_provider`,
  `sqflite`, CORS — e usar `kIsWeb` e importações condicionais para escrever código que roda nos
  três alvos.
- Fazer o **banco de dados do Foco funcionar no navegador** com `sqflite_common_ffi_web`, mantendo
  os mesmos DAOs, o mesmo SQL e as mesmas migrações do Módulo 10, alterando **uma única pasta**.
- Escrever o **`web/manifest.json`** completo — `name`, `short_name`, `start_url`, `scope`,
  `display`, `theme_color`, ícones `any` e **`maskable`** — e ajustar o `web/index.html` para iOS.
- Entender o **service worker** que o Flutter gera: o que ele guarda em cache, por que o usuário
  continua vendo a versão antiga depois do deploy e como forçar a atualização.
- Cumprir os **critérios de instalabilidade** que fazem o navegador oferecer "Instalar", tratar o
  `beforeinstallprompt` e saber exatamente o que o **iOS Safari não faz**.
- Gerar o build com **`flutter build web --release`**, dominando `--base-href` (a pegadinha nº 1),
  `--wasm`, `--dart-define-from-file` e a medição do peso do primeiro carregamento.
- **Publicar no GitHub Pages** por GitHub Actions, com deploy automático a cada push na `main`,
  e conhecer as alternativas (Firebase Hosting, Netlify) e quando elas compensam.
- **Diagnosticar** os erros reais de web: tela branca, 404 em `main.dart.js`, service worker preso,
  CORS, cota de IndexedDB — com uma tabela sintoma → causa → correção.

> 📌 **Este módulo vem antes do Android e do iOS de propósito.** A ordem do curso é a ordem de
> prioridade: primeiro o canal que coloca o Foco na mão de alguém hoje, depois os canais que exigem
> conta paga, chave de assinatura e revisão de loja. Quem inverte a ordem costuma terminar o curso
> com um `.aab` no disco e nenhum usuário.

---

## ✅ Pré-requisitos

- Ter concluído o [Módulo 13 — Desempenho e Segurança](../13-desempenho-e-seguranca/README.md).
  Em especial a aula
  [04 — Medindo desempenho](../13-desempenho-e-seguranca/04-medindo-desempenho.md): na web, medir
  antes de otimizar é ainda mais importante, porque o custo aparece no **primeiro carregamento** e
  não no uso.
- Ter concluído o [Módulo 10 — Persistência de dados](../10-persistencia-de-dados/README.md).
  A [Aula 4](04-banco-de-dados-na-web.md) mexe direto nos DAOs de `sqflite` que você escreveu lá.
- Ter o **Chrome ou o Edge** instalado. Confirme com:

  ```powershell
  flutter devices
  ```

  A saída precisa listar `Chrome (web)` ou `Edge (web)`. Se não listar nenhum navegador, volte para
  [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

- Ter o **suporte a web habilitado** no Flutter:

  ```powershell
  flutter config --list
  ```

  A linha `enable-web` precisa estar `true`. Se estiver `false`, ligue com
  `flutter config --enable-web` e rode `flutter doctor` de novo.

- Ter uma **conta no GitHub** e o Git configurado. A [Aula 9](09-publicando-no-github-pages.md)
  publica de verdade, em um repositório seu.
- Ter o projeto **Foco** funcionando em modo debug. Se ainda não terminou o projeto final, pode
  fazer o módulo inteiro com qualquer projeto Flutter seu — só a Aula 4 depende de o projeto usar
  `sqflite`.

> 💳 **Custo deste módulo: zero.** GitHub Pages é gratuito para repositórios públicos, inclui HTTPS
> e não pede cartão. Nenhuma aula deste módulo exige pagamento em nenhum momento — é a única coisa
> que os módulos 15, 16 e 17 não conseguem dizer.

---

## 🗺️ Ordem recomendada das aulas

Faça na ordem. Ela é a ordem real de um release web: entender o alvo, descobrir o que quebra,
consertar, vestir a identidade, ligar o offline, compilar, publicar, diagnosticar.

| # | Aula | Tempo | O que você sai sabendo |
|---|---|---|---|
| 1 | [Por que PWA é o canal principal](01-por-que-pwa.md) | 40 min | O que é PWA, o que entrega, o que não entrega, comparação honesta com APK/AAB/IPA |
| 2 | [Como o Flutter compila para web](02-como-o-flutter-compila-para-web.md) | 45 min | `dart2js`, WasmGC, CanvasKit, o conteúdo de `build/web/`, primeiro carregamento |
| 3 | [O que não funciona na web](03-o-que-nao-funciona-na-web.md) | 45 min | `dart:io`, `Platform`, `path_provider`, CORS, `kIsWeb`, importações condicionais |
| 4 | [Banco de dados na web](04-banco-de-dados-na-web.md) | 50 min | `sqflite_common_ffi_web`, SQLite em WASM, IndexedDB, cota e despejo |
| 5 | [Manifest e ícones](05-manifest-e-icones.md) | 45 min | `manifest.json` campo a campo, ícones `any` e `maskable`, `index.html`, iOS |
| 6 | [Service worker e offline](06-service-worker-e-offline.md) | 50 min | O SW do Flutter, estratégia de cache, versão presa, forçar atualização |
| 7 | [Instalabilidade](07-instalabilidade.md) | 40 min | Critérios do navegador, `beforeinstallprompt`, o que o iOS Safari não faz |
| 8 | [Gerando o build web](08-gerando-o-build-web.md) | 45 min | `flutter build web`, `--base-href`, `--wasm`, medir o primeiro carregamento |
| 9 | [Publicando no GitHub Pages](09-publicando-no-github-pages.md) | 50 min | Actions, `deploy-pages`, domínio próprio, alternativas e quando trocar |
| 10 | [Diagnóstico web](10-diagnostico-web.md) | 50 min | Tabela sintoma → causa → correção com os erros reais de build e deploy web |

**Total: 450 min de conteúdo.** No ritmo intensivo recomendado (4 h/dia), este módulo ocupa o
**Dia 28**, junto com a revisão da semana. O objetivo do dia é sair com **o Foco no ar, em uma URL
pública, instalável e funcionando offline**. Veja o cronograma completo em
[01-plano-intensivo.md](../../01-plano-intensivo.md).

---

## 🧪 Prática e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Exercícios do módulo | [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md) | Depois de terminar as 10 aulas |
| Gabaritos comentados | [gabaritos/14-build-web-pwa.md](../../gabaritos/14-build-web-pwa.md) | Só **depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-14-build-web-pwa.md](../../avaliacoes/modulo-14-build-web-pwa.md) | Ao final, para liberar o Módulo 15 |
| Checklist operacional | [checklists/build-web.md](../../checklists/build-web.md) | Toda vez que for publicar |

Referências de apoio deste módulo:

- [referencias/comandos-uteis.md](../../referencias/comandos-uteis.md) — todos os comandos de build.
- [referencias/erros-comuns.md](../../referencias/erros-comuns.md) — erros reais e correções.
- [referencias/glossario.md](../../referencias/glossario.md) — PWA, service worker, manifest,
  IndexedDB, CORS, WASM e afins.
- [referencias/referencias-oficiais.md](../../referencias/referencias-oficiais.md) — links oficiais.

---

## 🧰 Preparação prática (faça uma vez, agora)

Antes da Aula 1, garanta três coisas.

**1. O projeto roda no navegador.** Entre na pasta do projeto e rode:

```powershell
Set-Location C:\src\cursos\foco
flutter pub get
flutter run -d chrome
```

O Foco precisa abrir no Chrome. **Ele provavelmente vai abrir e quebrar** na primeira tela que
toca o banco de dados — isso é esperado, e é exatamente o que as aulas 3 e 4 resolvem. Anote a
mensagem de erro; você vai reencontrá-la na Aula 3.

**2. A pasta `web/` existe.** Projetos criados antes de você habilitar o suporte a web não têm essa
pasta. Confirme:

```powershell
Get-ChildItem .\web\
```

Você precisa ver `index.html`, `manifest.json`, `favicon.png` e a pasta `icons`. Se a pasta não
existir, crie-a sem tocar no resto do projeto:

```powershell
flutter create --platforms=web .
```

**3. O repositório está limpo e commitado.** Este módulo altera `web/`, `pubspec.yaml` e a camada
`data/`. Ter um commit antes significa poder desfazer qualquer passo:

```powershell
git status
git add .
git commit -m "Ponto de partida antes do módulo 14 (build web/PWA)"
```

> ⚠️ **Nenhum arquivo deste módulo contém token, chave de API ou segredo real.** Onde um segredo
> seria necessário, existe um marcador: `SEU_USUARIO`, `SEU_REPOSITORIO`. E há uma regra específica
> da web que vale desde já: **tudo que vai para `build/web/` é público e legível**. Não existe
> ofuscação que esconda uma chave de API num app web — a [Aula 8](08-gerando-o-build-web.md) trata
> disso em detalhe.

---

## 🧭 A ordem real de um release web

Guarde este mapa. Ele é a espinha do módulo e o roteiro que você vai repetir em todo PWA que
publicar:

```text
1. kIsWeb e importações condicionais no lugar   (Aula 3)  <- sem isso, tela branca
2. banco de dados web configurado               (Aula 4)
3. manifest.json preenchido                     (Aula 5)  <- define nome, ícone e modo instalado
4. ícones any + maskable gerados                (Aula 5)
5. service worker entendido e versionado        (Aula 6)  <- ERRAR AQUI = usuário preso na versão velha
6. instalabilidade conferida no navegador       (Aula 7)
7. flutter build web --release --base-href      (Aula 8)  <- --base-href errado = tela branca
8. peso do primeiro carregamento medido         (Aula 8)
9. deploy por GitHub Actions                    (Aula 9)
10. Lighthouse + teste offline no celular       (Aula 10)
```

Os passos 5 e 7 concentram praticamente todos os problemas reais de PWA. O service worker guarda
uma cópia do app no navegador da pessoa — e, mal versionado, ele serve essa cópia velha para
sempre. O `--base-href` diz ao `index.html` de onde carregar os arquivos — e, errado, produz uma
página em branco com quatro 404 no console e nenhuma mensagem de erro útil.

---

## 🌐 PWA × APK/AAB × IPA — o resumo que justifica a ordem

| | 🌐 **PWA** | 🤖 APK/AAB | 🍎 IPA |
|---|---|---|---|
| Custo para publicar | **R$ 0** | US$ 25 (uma vez) | US$ 99/ano |
| Dá para fazer no Windows | ✅ **Inteiro** | ✅ Inteiro | ❌ Exige macOS |
| Revisão humana | ❌ Nenhuma | ⚠️ Automatizada + amostragem | ⚠️ **Humana, dias** |
| Tempo até o primeiro usuário | **Minutos** | Horas a dias | Dias |
| Atualização chega ao usuário | **No próximo acesso** | Quando ele atualizar | Quando ele atualizar |
| Instalável na tela inicial | ✅ | ✅ | ✅ |
| Funciona offline | ✅ (Aula 6) | ✅ | ✅ |
| Presença na loja | ❌ | ✅ | ✅ |
| Notificações push | ⚠️ Sim, com ressalvas no iOS | ✅ | ✅ |
| Acesso a hardware nativo | ⚠️ Limitado | ✅ | ✅ |
| Descoberta por busca | ✅ **Google indexa** | ⚠️ Só na loja | ⚠️ Só na loja |

A linha que decide a ordem deste curso é a terceira e a quarta: **nenhuma revisão e minutos até o
primeiro usuário**. A linha que impede o PWA de ser o único canal é a penúltima: acesso a hardware.
A [Aula 1](01-por-que-pwa.md) abre cada uma dessas linhas em detalhe, inclusive as que são
desfavoráveis ao PWA.

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando você conseguir fazer **sem consultar a aula**:

- [ ] Explico o que é um PWA e cito três coisas que ele **não** faz tão bem quanto um app nativo.
- [ ] Explico por que o PWA é o canal principal deste curso, citando custo, revisão e o Windows.
- [ ] Descrevo o que acontece entre `flutter build web` e um `.js` rodando no navegador.
- [ ] Listo o que tem dentro de `build/web/` e digo para que serve cada arquivo.
- [ ] Explico por que `Platform.isAndroid` lança exceção na web e o que uso no lugar.
- [ ] Uso `kIsWeb` e sei quando ele **não** basta (importações condicionais).
- [ ] O Foco abre no Chrome, cria matérias e sessões, e os dados **sobrevivem a um F5**.
- [ ] Explico onde o `sqflite_common_ffi_web` guarda o banco e o que acontece se a cota estourar.
- [ ] Meu `web/manifest.json` tem `name`, `short_name`, `start_url`, `scope`, `display`,
      `theme_color`, `background_color` e ícones de 192 e 512 px.
- [ ] Tenho pelo menos um ícone `maskable` e sei a diferença dele para o `any`.
- [ ] Explico o que o service worker do Flutter guarda em cache e em que momento ele atualiza.
- [ ] Sei reproduzir e resolver o problema do "usuário preso na versão antiga".
- [ ] Listo os critérios que fazem o Chrome oferecer "Instalar" e sei conferir cada um no DevTools.
- [ ] Explico o que muda no iOS Safari e por que lá não existe prompt automático de instalação.
- [ ] Gerei `build/web/` com `--release` e sei exatamente quando preciso de `--base-href`.
- [ ] Medi o peso do primeiro carregamento e sei qual arquivo é o maior e por quê.
- [ ] O Foco está **publicado em uma URL pública**, acessível de outro aparelho.
- [ ] Instalei o Foco na tela inicial de um celular a partir do navegador e ele abriu sem a barra
      de endereços.
- [ ] Coloquei o celular em modo avião, abri o Foco instalado e ele funcionou.
- [ ] Tenho um workflow do GitHub Actions que publica sozinho a cada push na `main`.
- [ ] Rodei o Lighthouse e sei ler a seção PWA do relatório.
- [ ] Concluí ao menos **8 exercícios obrigatórios** de
      [exercicios/14-build-web-pwa.md](../../exercicios/14-build-web-pwa.md).
- [ ] Acertei **7 ou mais** das 10 questões de
      [avaliacoes/modulo-14-build-web-pwa.md](../../avaliacoes/modulo-14-build-web-pwa.md).

Quando todos os itens estiverem marcados, siga para o
[Módulo 15 — Build e Distribuição Android](../15-build-android/README.md).

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 13 — Desempenho e Segurança](../13-desempenho-e-seguranca/README.md) | [README do curso](../../README.md) | [Aula 1 — Por que PWA é o canal principal](01-por-que-pwa.md) |
