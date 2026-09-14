# Módulo 14 — Build e Distribuição Android

> **Tempo estimado total:** 450 min (7 h 30) · **Nível:** Avançado · **Posição no plano:** Dia 28 do ritmo intensivo de 30 dias

Este é o módulo em que o seu projeto deixa de ser "um app que roda no meu computador" e vira
**um arquivo instalável que funciona no celular de qualquer pessoa, sem o computador por perto**.

Até aqui você rodou tudo com `flutter run`. Isso conecta o celular (ou emulador) ao seu computador
por um cabo e mantém uma ponte aberta entre os dois: o **hot reload** funciona, o **depurador**
funciona, os logs aparecem no terminal. É perfeito para desenvolver e **péssimo** para entregar.

O que você vai construir neste módulo é a outra ponta: o **artefato de release** — um `.apk` ou um
`.aab` compilado em modo de produção, assinado com a sua chave, com ícone, splash, nome, versão e
permissões corretos. É exatamente o arquivo que a Google Play aceita.

Usamos o app final do curso, **Foco: Organizador de Estudos**, com identificador
`br.com.estudos.foco`, em todos os exemplos. Se você ainda não terminou o projeto final, pode fazer
o módulo inteiro com qualquer projeto Flutter seu — os passos são idênticos.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- Explicar a diferença real entre os modos **debug**, **profile** e **release** — JIT × AOT,
  asserts, ferramentas de depuração, tamanho e velocidade — e escolher o modo certo para cada
  situação.
- Definir a **identidade** do app: `applicationId`, `namespace`, nome exibido e versão, entendendo
  por que o identificador **não pode mudar depois da publicação**.
- Gerar o **ícone** em todas as densidades do Android e o **ícone adaptativo** (Android 8+) a partir
  de um único PNG de 1024×1024.
- Gerar a **splash nativa**, inclusive a variação obrigatória do **Android 12+**, e entender por que
  ela é diferente de uma tela de carregamento feita em Flutter.
- Declarar **permissões** no `AndroidManifest.xml` com o princípio do mínimo privilégio, sabendo a
  diferença entre permissão normal e perigosa.
- Criar um **keystore** com `keytool`, entender o que é assinatura digital e por que perder essa
  chave significa nunca mais atualizar o app publicado.
- Configurar a **assinatura de release** no `android/app/build.gradle.kts` em **Kotlin DSL**,
  substituindo o bloco que o Flutter gera assinado com a chave de depuração.
- Gerar **APK**, **APK por ABI** e **Android App Bundle (AAB)**, com ofuscação e separação de
  símbolos de depuração, e saber quando usar cada um.
- **Instalar e validar** o artefato em um aparelho físico, com um checklist objetivo de verificação
  pós-build.
- **Diagnosticar** os erros de build Android mais comuns — inclusive os dois erros reais já
  reproduzidos nesta máquina — com uma tabela sintoma → causa → correção.

> 🤖 Este módulo inteiro é **específico do Android**. O caminho equivalente do iOS está no
> [Módulo 15 — Build e Distribuição iOS](../15-build-ios/README.md), e ele deixa claro o que exige
> um Mac. O Android você consegue fazer **inteiro, do começo ao fim, no Windows 11**.

---

## ✅ Pré-requisitos

- Ter concluído o [Módulo 13 — Desempenho e Segurança](../13-desempenho-e-seguranca/README.md).
  Em especial a aula
  [07 — Ofuscação e o que evitar](../13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md),
  porque as flags `--obfuscate` e `--split-debug-info` reaparecem aqui como parte do comando de
  build.
- Ter o **Android SDK instalado e as licenças aceitas**. Confirme com:

  ```powershell
  flutter doctor
  ```

  A linha `[√] Android toolchain - develop for Android devices` precisa estar verde. Se aparecer
  `X Unable to locate Android SDK`, volte para
  [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md) e instale o Android Studio
  + SDK antes de começar. A [Aula 10](10-diagnostico-de-build.md) também cobre esse erro.
- Ter o **Flutter SDK em um caminho sem acento e sem espaço** (o curso recomenda `C:\src\flutter`).
  Caminho com acento quebra o build — é um erro real desta máquina, explicado na
  [Aula 10](10-diagnostico-de-build.md).
- Ter o **Modo de Desenvolvedor do Windows ligado**. Sem ele, qualquer projeto com plugins falha com
  `Building with plugins requires symlink support`.
- Ter um **aparelho Android físico** com cabo USB, ou um emulador configurado. A
  [Aula 9](09-instalando-e-validando.md) usa um aparelho de verdade.
- Ter o projeto **Foco** funcionando em modo debug. Se ainda não terminou, use qualquer projeto seu.

---

## 🗺️ Ordem recomendada das aulas

Faça na ordem. A ordem das aulas é a **ordem real das etapas de um release**: identidade primeiro,
recursos visuais depois, assinatura em seguida, build no fim. Pular etapas gera retrabalho — por
exemplo, mudar o `applicationId` depois de gerar o ícone obriga a mexer em pastas já criadas.

| # | Aula | Tempo | O que você sai sabendo |
|---|---|---|---|
| 1 | [Debug, profile e release](01-debug-profile-release.md) | 40 min | Os três modos, JIT × AOT, o que cada um liga e desliga, onde cada artefato é gravado |
| 2 | [Identidade do app](02-identidade-do-app.md) | 45 min | `applicationId` × `namespace`, domínio invertido, nome exibido, `version: 1.0.0+1` |
| 3 | [Ícone](03-icone.md) | 40 min | PNG 1024×1024, ícone adaptativo, densidades, `flutter_launcher_icons` |
| 4 | [Splash screen](04-splash-screen.md) | 40 min | Splash nativa, `flutter_native_splash`, a mudança do Android 12+ |
| 5 | [Permissões Android](05-permissoes-android.md) | 45 min | `AndroidManifest.xml`, `<uses-permission>`, normais × perigosas, os três manifests |
| 6 | [Keystore](06-keystore.md) | 45 min | Assinatura digital, `keytool`, Play App Signing, backup e o que nunca vai para o Git |
| 7 | [Assinatura no Gradle](07-assinatura-no-gradle.md) | 50 min | `key.properties`, Kotlin DSL, `signingConfigs`, substituir a chave de debug |
| 8 | [Gerando APK e AAB](08-gerando-apk-e-aab.md) | 50 min | `apk`, `--split-per-abi`, `appbundle`, ABIs, ofuscação, `--analyze-size` |
| 9 | [Instalando e validando](09-instalando-e-validando.md) | 45 min | `flutter install`, `adb install -r`, `bundletool`, checklist pós-build |
| 10 | [Diagnóstico de build](10-diagnostico-de-build.md) | 50 min | Tabela sintoma → causa → correção com os erros reais do Android |

**Total: 450 min de conteúdo.** No ritmo intensivo recomendado (4 h/dia), este módulo ocupa o
**Dia 28**, junto com a revisão da semana. O objetivo do dia é sair com **APK e AAB gerados e
instalados**. Veja o cronograma completo em [01-plano-intensivo.md](../../01-plano-intensivo.md).

---

## 🧪 Prática e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Exercícios do módulo | [exercicios/14-build-android.md](../../exercicios/14-build-android.md) | Depois de terminar as 10 aulas |
| Gabaritos comentados | [gabaritos/14-build-android.md](../../gabaritos/14-build-android.md) | Só **depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-14-build-android.md](../../avaliacoes/modulo-14-build-android.md) | Ao final, para liberar o Módulo 15 |
| Checklist operacional | [checklists/build-android.md](../../checklists/build-android.md) | Toda vez que for gerar um release |

Referências de apoio deste módulo:

- [referencias/comandos-uteis.md](../../referencias/comandos-uteis.md) — todos os comandos de build.
- [referencias/erros-comuns.md](../../referencias/erros-comuns.md) — erros reais e correções.
- [referencias/glossario.md](../../referencias/glossario.md) — ABI, AAB, keystore, AGP, SDK e afins.
- [referencias/diferencas-android-ios.md](../../referencias/diferencas-android-ios.md) — o que muda
  no equivalente iOS de cada passo.

---

## 🧰 Preparação prática (faça uma vez, agora)

Antes da Aula 1, garanta três coisas.

**1. O projeto abre e roda.** Entre na pasta do seu projeto e rode:

```powershell
flutter doctor
flutter pub get
flutter devices
```

`flutter devices` precisa listar pelo menos um aparelho Android ou emulador. Se listar só
`Windows (desktop)` e `Chrome (web)`, você ainda não tem Android disponível.

**2. Você sabe onde o projeto está.** Todos os caminhos deste módulo são **relativos à raiz do
projeto Flutter** — a pasta onde fica o `pubspec.yaml`. Quando a aula diz
`android/app/build.gradle.kts`, leia como
`C:\src\cursos\foco\android\app\build.gradle.kts` (ajustando para onde está o seu projeto).

**3. O repositório está limpo e commitado.** Este módulo altera arquivos nativos. Ter um commit
antes de começar significa poder desfazer qualquer passo:

```powershell
git status
git add .
git commit -m "Ponto de partida antes do módulo 14 (build Android)"
```

> ⚠️ **Nenhum arquivo deste módulo contém senha, alias, caminho de keystore ou chave reais.**
> Todo lugar que precisaria de um segredo traz um marcador: `SUA_SENHA_AQUI`, `SEU_ALIAS`,
> `SEU_USUARIO`. Substitua pelos seus valores **no seu computador** e nunca em um arquivo
> versionado. A [Aula 6](06-keystore.md) e a [Aula 7](07-assinatura-no-gradle.md) tratam disso em
> detalhe.

---

## 🧭 A ordem real de um release Android

Guarde este mapa. Ele é a espinha do módulo e o roteiro que você vai repetir em todo app que
publicar:

```text
1. applicationId definido          (Aula 2)  <- IMPOSSÍVEL mudar depois de publicar
2. nome exibido e versão           (Aula 2)
3. ícone gerado                    (Aula 3)
4. splash gerada                   (Aula 4)
5. permissões declaradas           (Aula 5)
6. keystore criado e guardado      (Aula 6)  <- PERDER = nunca mais atualizar o app
7. assinatura configurada          (Aula 7)
8. flutter clean                   (Aula 8)
9. flutter build apk / appbundle   (Aula 8)
10. instalar e validar no aparelho (Aula 9)
```

O `flutter clean` do passo 8 não é superstição: os geradores de ícone e splash escrevem recursos
nativos, e o Gradle pode reaproveitar cache antigo desses recursos. Limpar antes do build final
evita um artefato com o ícone velho dentro.

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando você conseguir fazer **sem consultar a aula**:

- [ ] Explico a diferença entre debug, profile e release citando JIT, AOT e asserts, e digo por que
      medir desempenho em debug produz um número sem valor.
- [ ] Digo de cor onde o Flutter grava o APK de release, os APKs por ABI e o AAB.
- [ ] Explico a diferença entre `applicationId` e `namespace` e por que o `applicationId` é
      definitivo depois da publicação.
- [ ] Alterei o `applicationId` do meu projeto para um domínio invertido meu, renomeei a pasta do
      `MainActivity.kt` e o app continua compilando e rodando.
- [ ] Mudei o nome exibido do app em `android:label` e vi o nome novo embaixo do ícone no aparelho.
- [ ] Entendo que `version: 1.0.0+1` do `pubspec.yaml` vira `versionName`/`versionCode` no Android
      e `CFBundleShortVersionString`/`CFBundleVersion` no iOS.
- [ ] Gerei o ícone com `dart run flutter_launcher_icons` e conferi o ícone novo no aparelho.
- [ ] Gerei a splash com `dart run flutter_native_splash:create`, entendendo o que muda no
      Android 12+.
- [ ] Declarei `INTERNET` no `AndroidManifest.xml` principal e explico por que o debug funcionava
      sem ela e o release não.
- [ ] Criei um keystore com `keytool`, sei onde ele está, tenho **backup** e ele **não** está no Git.
- [ ] Criei `android/key.properties`, adicionei ao `.gitignore` **antes** de criá-lo, e configurei
      `signingConfigs` no `android/app/build.gradle.kts`.
- [ ] Removi o bloco `signingConfig = signingConfigs.getByName("debug")` do `buildTypes.release` e
      entendo por que ele existia.
- [ ] Gerei `app-release.apk`, os APKs por ABI e `app-release.aab` sem erro.
- [ ] Instalei o APK de release em um aparelho físico e o app abriu e funcionou **sem o computador
      conectado**.
- [ ] Passei pelo checklist de validação: sem internet, rotação, modo escuro, fechar e reabrir.
- [ ] Sei usar `--stacktrace`, `--verbose`, `flutter clean` e a limpeza de cache do Gradle quando um
      build falha.
- [ ] Concluí ao menos **8 exercícios obrigatórios** de
      [exercicios/14-build-android.md](../../exercicios/14-build-android.md).
- [ ] Acertei **7 ou mais** das 10 questões de
      [avaliacoes/modulo-14-build-android.md](../../avaliacoes/modulo-14-build-android.md).

Quando todos os itens estiverem marcados, siga para o
[Módulo 15 — Build e Distribuição iOS](../15-build-ios/README.md).

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 13 — Desempenho e Segurança](../13-desempenho-e-seguranca/README.md) | [README do curso](../../README.md) | [Aula 1 — Debug, profile e release](01-debug-profile-release.md) |
