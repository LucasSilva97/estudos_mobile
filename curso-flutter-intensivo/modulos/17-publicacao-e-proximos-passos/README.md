# Módulo 17 — Publicação e Próximos Passos

> **Tempo estimado total:** 250 min (4 h 10) · **Nível:** Intermediário → Avançado · **Posição no plano:** Dia 30 do ritmo intensivo de 30 dias

Este é o **último módulo de conteúdo do curso**. Nos módulos 15 e 16 você aprendeu a transformar
código em **artefato**: o `.aab` do Android (o pacote que a Google Play recebe) e o `.ipa` do iOS
(o pacote que a App Store recebe). Aqui você aprende o que vem **depois do arquivo**: como entregar
esse artefato para as lojas, como versionar releases sem se perder, como automatizar o processo,
como descobrir que o app quebrou no aparelho de alguém e o que estudar quando o curso acabar.

O app usado em todos os exemplos é o projeto final **Foco**, com identificador
`br.com.estudos.foco` (`applicationId` no Android e *Bundle Identifier* no iOS).

> 🪟 **Você está no Windows 11.** Tudo que envolve **Google Play** você executa hoje, do começo ao
> fim, nesta máquina. Tudo que envolve **App Store** exige, em algum momento, um **macOS com Xcode**
> para gerar e enviar o binário. Este módulo é honesto sobre essa divisão em cada aula: o que dá
> para fazer agora, o que fica para quando você tiver acesso a um Mac, e qual é o caminho legítimo
> (runner macOS na nuvem) para não depender de comprar um.

---

## 🎯 O que você vai aprender

Ao terminar este módulo, você será capaz de:

- 🤖 Criar a conta de desenvolvedor da **Google Play**, passar pela verificação de identidade e
  registrar o app **Foco** no Play Console.
- 🤖 Montar a **ficha da loja** completa: nome, descrições, capturas de tela nos tamanhos certos,
  ícone de 512×512 e gráfico de destaque.
- 🤖 Preencher **classificação de conteúdo**, **política de privacidade**, **Segurança dos Dados**
  e **público-alvo** sem cair nas armadilhas que causam rejeição.
- 🤖 Entender as quatro **faixas de teste** (interno, fechado, aberto, produção) e escolher a certa.
- 🤖 Explicar o **Play App Signing**, a diferença entre **chave de upload** e **chave de assinatura
  do app**, e subir o `.aab`.
- 🍎 Criar o registro do app no **App Store Connect**, preencher a versão, a **Nutrition Label de
  privacidade**, palavras-chave, classificação etária, preço e disponibilidade.
- 🍎 Descrever o que a **revisão humana da Apple** avalia e por que apps são rejeitados — inclusive
  o caso clássico do texto de permissão genérico.
- Aplicar **versionamento semântico**, entender como `version: 1.0.0+1` vira `versionName`/
  `versionCode` no Android e `CFBundleShortVersionString`/`CFBundleVersion` no iOS, e marcar
  releases com **tags do Git** e um **CHANGELOG**.
- Fazer **lançamento gradual**, interromper um rollout problemático e publicar um **hotfix** —
  entendendo por que não existe "desinstalar remotamente" uma versão já baixada.
- Montar um **workflow de CI** no GitHub Actions que roda `flutter analyze` e `flutter test` a cada
  push, gera APK e guarda a keystore com segurança em **GitHub Secrets**.
- Montar a base de **monitoramento**: relatório de erro, símbolos de depuração de builds ofuscados,
  métricas, resposta a avaliações, canal de feedback no app e cuidados de **LGPD**.
- Escolher para onde ir depois do curso, com um **plano de 90 dias** com metas semanais.

---

## ✅ Pré-requisitos

- [Módulo 16 — Build iOS](../16-build-ios/README.md) concluído. Você precisa entender por que o
  build iOS exige macOS antes de discutir a App Store.
- [Módulo 15 — Build Android](../15-build-android/README.md) concluído, com um **`.aab` assinado
  pela sua chave de upload** já gerado em `build/app/outputs/bundle/release/app-release.aab`.
  Se o seu `android/app/build.gradle.kts` ainda tem o comentário
  `// TODO: Add your own signing config for the release build.`, **volte para
  [15-build-android/07-assinatura-no-gradle.md](../15-build-android/07-assinatura-no-gradle.md)**:
  esse build está assinado com a chave de depuração e a Google Play vai recusá-lo.
- [Módulo 00 — Git e Terminal](../00-git-e-terminal/README.md), especialmente
  [05-desfazendo-erros-e-segredos.md](../00-git-e-terminal/05-desfazendo-erros-e-segredos.md) —
  a aula 4 deste módulo depende de você saber o que **nunca** pode entrar no repositório.
- O projeto final **Foco** rodando, com ícone, splash e `version:` definidos, conforme
  [projetos/03-projeto-final-multiplataforma/10-etapa-8-icone-splash-e-versao.md](../../projetos/03-projeto-final-multiplataforma/10-etapa-8-icone-splash-e-versao.md).
- Uma conta Google e, para a aula 4, uma conta no GitHub.

> 💳 **Custos reais deste módulo.** A conta de desenvolvedor da Google Play custa **US$ 25, taxa
> única**. O Apple Developer Program custa **US$ 99 por ano**. Você **não precisa pagar nada** para
> estudar este módulo: todas as aulas explicam o que dá para fazer sem pagar e em que ponto exato
> o pagamento se torna obrigatório.

---

## 🗺️ Ordem recomendada das aulas

Faça na ordem. As aulas 3, 4 e 5 valem para as duas lojas e assumem o vocabulário das aulas 1 e 2.

| # | Aula | Tempo | O que você sai sabendo |
|---|---|---|---|
| 1 | [Google Play](01-google-play.md) | 45 min | Conta de desenvolvedor, Play Console, ficha da loja, classificação, Segurança dos Dados, faixas de teste, Play App Signing, envio do AAB |
| 2 | [App Store Connect](02-app-store-connect.md) | 45 min | Registro do app, capturas por tamanho, Nutrition Label, revisão humana da Apple, rejeições e recurso |
| 3 | [Versionamento e releases](03-versionamento-e-releases.md) | 40 min | SemVer, `1.0.0+1` nas duas plataformas, tags Git, CHANGELOG, rollout gradual, rollback e hotfix |
| 4 | [CI/CD introdutório](04-ci-cd-introdutorio.md) | 45 min | GitHub Actions do zero, analyze + test + build no CI, runner macOS para iOS, segredos em base64 |
| 5 | [Monitoramento e feedback](05-monitoramento-e-feedback.md) | 35 min | Crash reporting, símbolos de `--split-debug-info`, métricas, avaliações, feedback no app, LGPD |
| 6 | [Próximos passos](06-proximos-passos.md) | 40 min | O que estudar depois, projetos sugeridos, comunidades e um plano de 90 dias |

**Total: 250 min.** No ritmo intensivo recomendado, este módulo fecha o **Dia 30**. O cronograma completo está em [01-plano-intensivo.md](../../01-plano-intensivo.md).

---

## 🧪 Prática e avaliação

| Recurso | Link | Quando usar |
|---|---|---|
| Exercícios do módulo | [exercicios/17-publicacao-e-proximos-passos.md](../../exercicios/17-publicacao-e-proximos-passos.md) | Depois de terminar as 6 aulas |
| Gabaritos comentados | [gabaritos/17-publicacao-e-proximos-passos.md](../../gabaritos/17-publicacao-e-proximos-passos.md) | Só **depois** de tentar de verdade |
| Avaliação do módulo | [avaliacoes/modulo-17-publicacao-e-proximos-passos.md](../../avaliacoes/modulo-17-publicacao-e-proximos-passos.md) | Ao final, para fechar o curso |

Referências de apoio deste módulo:

- [checklists/build-android.md](../../checklists/build-android.md) — conferência antes de subir o AAB.
- [checklists/build-ios.md](../../checklists/build-ios.md) — conferência antes do envio à App Store.
- [checklists/projeto-final.md](../../checklists/projeto-final.md) — o Foco está pronto para publicar?
- [referencias/proximos-passos.md](../../referencias/proximos-passos.md) — trilhas de estudo depois do curso.
- [referencias/referencias-oficiais.md](../../referencias/referencias-oficiais.md) — links oficiais.
- [referencias/glossario.md](../../referencias/glossario.md) — todo termo técnico do curso.
- [referencias/erros-comuns.md](../../referencias/erros-comuns.md) — erros reais e correções.

---

## 🧰 Preparação prática (faça uma vez, agora)

Antes da Aula 1, garanta que o artefato existe e está assinado com a **sua** chave.

**🪟 Windows (PowerShell)**

```powershell
Set-Location C:\src\cursos\foco
flutter clean
flutter pub get
flutter build appbundle --release
```

Resultado esperado — a última linha impressa:

```text
✓ Built build\app\outputs\bundle\release\app-release.aab (XX.XMB).
```

Confirme objetivamente que o arquivo existe e tem tamanho plausível (alguns megabytes):

```powershell
Get-Item .\build\app\outputs\bundle\release\app-release.aab | Select-Object FullName, Length
```

Se o comando responder `Cannot find path`, o build não terminou — releia a saída completa e o
diagnóstico em [15-build-android/10-diagnostico-de-build.md](../15-build-android/10-diagnostico-de-build.md).

---

## ☑️ Critérios para considerar o módulo concluído

Marque cada item só quando conseguir fazer (ou explicar em voz alta) **sem consultar a aula**:

- [ ] Explico o que é a taxa de US$ 25 da Google Play, que ela é **única**, e o que é a verificação
      de identidade exigida na criação da conta.
- [ ] Listo os itens obrigatórios da ficha da loja da Google Play, com o tamanho exato do ícone
      (512×512) e do gráfico de destaque (1024×500).
- [ ] Explico a diferença entre as faixas **interno**, **fechado**, **aberto** e **produção**, e digo
      qual eu usaria para um primeiro envio.
- [ ] Explico o **Play App Signing**: quem guarda a chave de assinatura do app, para que serve a
      chave de upload e o que acontece se eu perder cada uma delas.
- [ ] Preencho a seção **Segurança dos Dados** de forma coerente com as permissões declaradas no
      `AndroidManifest.xml` do Foco.
- [ ] 🍎 Descrevo, passo a passo, o que se preenche em um registro de app no App Store Connect e o
      que a revisão humana da Apple avalia.
- [ ] 🍎 Reescrevo um texto de permissão genérico ("precisamos de acesso") para um texto específico
      que passa na revisão.
- [ ] Digo, olhando `version: 1.2.3+45`, quais são o `versionName`, o `versionCode`, o
      `CFBundleShortVersionString` e o `CFBundleVersion` gerados.
- [ ] Explico por que o número de build **sempre sobe** e o que acontece se eu reenviar o mesmo.
- [ ] Crio uma tag anotada de release no Git e escrevo a entrada correspondente no `CHANGELOG.md`.
- [ ] Explico o que é lançamento gradual, como interromper um rollout e por que **não existe**
      "despublicar" uma versão que já foi baixada.
- [ ] Tenho, no repositório do Foco, um `.github/workflows/ci.yml` que roda `flutter analyze` e
      `flutter test` a cada push, com a execução aparecendo verde na aba **Actions** do GitHub.
- [ ] Explico como guardar uma keystore em GitHub Secrets via base64 e por que **nunca** se escreve
      um segredo dentro do YAML.
- [ ] Explico para que serve `--obfuscate --split-debug-info=<pasta>` e por que a pasta de símbolos
      precisa ser guardada junto com a release.
- [ ] Listo três cuidados de LGPD ao coletar dados de uso do app.
- [ ] Escrevi meu **plano de 90 dias** com metas semanais, a partir da Aula 6.
- [ ] Concluí ao menos **8 exercícios obrigatórios** de
      [exercicios/17-publicacao-e-proximos-passos.md](../../exercicios/17-publicacao-e-proximos-passos.md).
- [ ] Acertei **7 ou mais** das 10 questões de
      [avaliacoes/modulo-17-publicacao-e-proximos-passos.md](../../avaliacoes/modulo-17-publicacao-e-proximos-passos.md).

Quando todos os itens estiverem marcados, feche o curso com a
[Avaliação cumulativa 05 — Build e distribuição](../../avaliacoes/cumulativa-05-build-e-distribuicao.md)
e a [Avaliação final](../../avaliacoes/avaliacao-final.md).

---

| ⬅️ Anterior | 🏠 Curso | ➡️ Próximo |
|---|---|---|
| [Módulo 16 — Build iOS](../16-build-ios/README.md) | [README do curso](../../README.md) | [Aula 1 — Google Play](01-google-play.md) |
