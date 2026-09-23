# Aula 4 — CI/CD introdutório

> **Módulo:** 17 - Publicação e próximos passos · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Entender o que são **CI** e **CD**, e o que cada um resolve.
- Escrever um **GitHub Actions** do zero: gatilhos, jobs, passos e cache.
- Rodar **`analyze`, `test` e build** a cada push, com o resultado visível no pull request.
- Usar um **runner macOS** para gerar o IPA **sem ter um Mac**.
- Guardar **keystore, certificado e senhas** como segredos em base64, com segurança.
- Arquivar os **símbolos** automaticamente — o passo que ninguém lembra de fazer à mão.
- Saber quanto custa, e o que **não** vale automatizar.

## ✅ Pré-requisitos

- [Aula 3 — Versionamento e releases](03-versionamento-e-releases.md) — tags `v*` disparam o
  pipeline.
- [Módulo 15, aula 7 — Assinatura no Gradle](../15-build-android/07-assinatura-no-gradle.md) — o
  bloco que lê variáveis de ambiente.
- [Módulo 16, aula 8 — Build: IPA e archive](../16-build-ios/08-build-ipa-e-archive.md) — o roteiro
  que vai dentro do CI.
- [Módulo 12, aula 5 — Testes unitários](../12-testes-e-debug/05-testes-unitarios.md) — sem testes,
  CI é só um compilador lento.

---

## 📖 Conceito

### CI e CD

| | O que é | Responde |
|---|---|---|
| **CI** — Integração Contínua | Rodar análise e testes a cada mudança | "Isto quebrou alguma coisa?" |
| **CD** — Entrega Contínua | Gerar e publicar o artefato automaticamente | "Como isso chega ao usuário?" |

```text
push → analyze → test → build → artefato → loja
       └──────── CI ────────┘   └─── CD ───┘
```

> 📌 **CI sem testes não serve para quase nada.** Um pipeline que só compila responde "compila?" —
> pergunta que o seu editor já responde. O valor aparece quando ele responde "os 200 testes ainda
> passam?", que é o que ninguém verifica antes de cada push.

### Por que vale a pena

| Sem CI | Com CI |
|---|---|
| "Na minha máquina funciona" | Roda num ambiente limpo, sempre igual |
| Testes rodados quando alguém lembra | A cada push |
| Build de release manual, com passos esquecidos | Roteiro idêntico toda vez |
| Símbolos perdidos | Arquivados automaticamente |
| Sem Mac = sem iOS | ✅ **Runner macOS** |

> 💡 **Para quem está no Windows, o CI é a porta de entrada do iOS.** `runs-on: macos-latest` dá a
> você um Mac por alguns minutos, o suficiente para gerar e enviar o IPA. É assim que muitos times
> sem Mac publicam na App Store.

### Anatomia de um workflow

```yaml
# .github/workflows/ci.yml
name: CI                      # aparece na aba Actions

on:                           # QUANDO roda
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:          # botão manual

jobs:                         # o QUE roda
  teste:
    runs-on: ubuntu-latest    # ONDE roda
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
      - run: flutter pub get
      - run: flutter test
```

| Runner | Custo relativo | Para quê |
|---|---|---|
| `ubuntu-latest` | **1×** | ✅ analyze, test |
| `windows-latest` | 2× | Raramente necessário |
| `macos-latest` | **10×** | ⚠️ Só iOS |

> ⚠️ **O runner macOS custa 10× mais minutos** que o Ubuntu. Rodar os testes nele é desperdício:
> deixe o Ubuntu fazer analyze e test, e o macOS só o build iOS. Essa separação é a diferença entre
> um plano gratuito que dura o mês e um que acaba na segunda semana.

### Cache

Sem cache, cada execução baixa tudo de novo:

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.pub-cache
    # A chave inclui o hash do pubspec.lock: mudou a dependência,
    # o cache é invalidado.
    key: pub-${{ runner.os }}-${{ hashFiles('**/pubspec.lock') }}
    restore-keys: pub-${{ runner.os }}-
```

| | Sem cache | Com cache |
|---|---|---|
| `pub get` | ~60 s | ~5 s |
| Gradle | ~4 min | ~1 min |
| CocoaPods | ~3 min | ~40 s |

### Segredos

Nada de senha, keystore ou certificado no repositório. Eles vão como **secrets**, em base64:

```powershell
# Transformar um arquivo binário em texto, para colar no secret
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\chaves\foco-upload.jks")) |
    Set-Clipboard
```

```text
GitHub → Settings → Secrets and variables → Actions → New repository secret
```

| Secret | O que é |
|---|---|
| `ANDROID_KEYSTORE_B64` | O `.jks` em base64 |
| `ANDROID_STORE_PASSWORD` | Senha do arquivo |
| `ANDROID_KEY_PASSWORD` | Senha da chave |
| `ANDROID_KEY_ALIAS` | Alias |
| `IOS_CERT_P12_B64` | Certificado em base64 |
| `IOS_CERT_SENHA` | Senha do `.p12` |
| `IOS_PROFILE_B64` | Provisioning profile |
| `ASC_KEY_P8_B64` | Chave da App Store Connect API |

> ⚠️ **O GitHub mascara os secrets no log automaticamente** — mas só o valor exato. Um `echo` de uma
> variável **derivada** (a senha concatenada, ou em outro formato) escapa do mascaramento e vai
> parar num log que, em repositório público, é permanente.

> 📌 **E o log do CI é mais visível do que parece.** Em repositório público, qualquer pessoa lê. Em
> privado, qualquer colaborador. Trate-o como algo que será lido.

### O que automatizar — e o que não

| Automatize | Deixe manual |
|---|---|
| `analyze` e `test` a cada push | A decisão de publicar |
| Build a cada tag | O texto de "Novidades" |
| Arquivamento dos símbolos | O rollout gradual |
| Envio ao TestFlight interno | A promoção para produção |
| Verificação de formatação | A revisão de código |

> 💡 **O padrão que funciona é "CI completo, CD até a porta da loja".** O pipeline gera o artefato,
> envia para a faixa interna, e para. A decisão de liberar para o público continua sendo de uma
> pessoa, olhando os números — e essa pessoa agradece por não precisar lembrar dos quinze passos
> anteriores.

### Quanto custa

| Plano GitHub | Minutos/mês grátis |
|---|---|
| Free (repo público) | **Ilimitado** |
| Free (repo privado) | 2 000 (Ubuntu) |
| Pro | 3 000 |

E a conversão dos minutos:

```text
1 min Ubuntu  = 1 minuto da cota
1 min Windows = 2 minutos
1 min macOS   = 10 minutos
```

```text
Exemplo de um mês:
  30 pushes × 3 min (Ubuntu, CI)       =  90 min
   4 tags   × 8 min (Ubuntu, Android)  =  32 min
   4 tags   × 12 min (macOS, iOS) × 10 = 480 min
                                 total ≈ 600 min
```

> 📌 **O build iOS domina o custo.** Se a cota apertar, a saída não é cortar os testes — é reduzir a
> **frequência** do build iOS: só em tags, nunca em push.

---

## 💡 Analogia

Pense numa **linha de montagem com inspeção automática**.

- **Sem CI**, cada peça é conferida pelo próprio operário, quando ele lembra, com a régua dele. A
  peça passa, chega ao cliente, e lá alguém descobre que não encaixa. "Na minha bancada encaixava."
- **O CI é a inspeção no fim da esteira**, com o mesmo gabarito, toda vez, sem exceção. Não é mais
  rigorosa que um operário atento — é **consistente**, que é outra coisa, e mais difícil de
  conseguir com gente.
- **E a inspeção só vale se houver gabarito.** Uma esteira que apenas confirma "a peça saiu" não
  inspeciona nada. É o CI sem testes.
- **O CD é o setor de expedição**: embala, etiqueta, gera a nota e leva até a doca. **Mas quem
  autoriza o caminhão a sair é uma pessoa** — porque "está pronto" e "é hora de enviar" são decisões
  diferentes.
- **O runner macOS** é uma máquina especializada que a fábrica **aluga por minuto**, e que custa dez
  vezes a hora das outras. Você não a usa para cortar papelão — usa só para a peça que exige ela.
- **Os secrets** são as chaves do cofre, guardadas com o segurança e entregues à máquina no momento
  do uso, nunca deixadas na bancada. E o **livro de registro da fábrica** — o log — é lido por
  todos: quem anota a combinação ali, anotou para sempre.
- **E o arquivamento automático dos símbolos** é a inspeção guardar a ficha técnica de cada lote.
  Ninguém lembra de fazer isso à mão. A máquina lembra sempre.

---

## 🧪 Exemplo mínimo

O CI que já rende mais que tudo: analyze e test a cada push.

> **Arquivo:** `.github/workflows/ci.yml` (novo)

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  qualidade:
    # Ubuntu: 1× a cota. Rodar isto no macOS custaria 10×
    # e não traria nenhum benefício.
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
          channel: stable
          # O cache do próprio Flutter, além do pub.
          cache: true

      - name: Dependências
        run: flutter pub get

      # --set-exit-if-changed: falha se algum arquivo NÃO estiver
      # formatado. Sem essa flag, o comando formata e passa —
      # e o CI não verifica nada.
      - name: Formatação
        run: dart format --output=none --set-exit-if-changed .

      - name: Análise
        run: flutter analyze --no-fatal-infos

      - name: Testes
        run: flutter test --coverage

      - name: Cobertura
        uses: actions/upload-artifact@v4
        with:
          name: cobertura
          path: coverage/lcov.info
```

```bash
git add .github/workflows/ci.yml
git commit -m "ci: analyze e test a cada push"
git push
```

```text
GitHub → aba Actions → CI → ✅ ou ❌
```

> 📌 **Cinco minutos de trabalho, e a partir de agora nenhum push passa sem que os testes rodem.**
> É a melhor relação esforço/benefício deste módulo — e funciona de graça em repositório público.

---

## 📱 Aplicando no Flutter

O pipeline completo: CI a cada push, CD a cada tag, nas duas plataformas.

---

## 💻 Código completo

> **Arquivo:** `.github/workflows/release.yml` (novo)

```yaml
# Pipeline de release: dispara ao criar uma tag v*.
#
# Gera Android e iOS, arquiva os símbolos e envia para as
# faixas internas. A promoção para produção continua sendo
# uma decisão humana.

name: Release

on:
  push:
    tags: ['v*']
  workflow_dispatch:   # permite disparar à mão

env:
  FLUTTER_VERSION: '3.47.1'

jobs:
  # ══════════════════════════════════════════════════════════
  # 1. Portões — barato, e barra tudo o mais se falhar.
  # ══════════════════════════════════════════════════════════
  qualidade:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --no-fatal-infos
      - run: flutter test

  # ══════════════════════════════════════════════════════════
  # 2. Android
  # ══════════════════════════════════════════════════════════
  android:
    needs: qualidade          # só roda se os portões passarem
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'     # o AGP atual exige 17
          cache: gradle

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - run: flutter pub get

      # ── Keystore, a partir do secret em base64 ──
      - name: Restaurar o keystore
        env:
          KEYSTORE_B64: ${{ secrets.ANDROID_KEYSTORE_B64 }}
        run: |
          # $RUNNER_TEMP é destruído com o runner.
          echo "$KEYSTORE_B64" | base64 -d > "$RUNNER_TEMP/upload.jks"
          # Confere que não veio vazio ou corrompido.
          if [ ! -s "$RUNNER_TEMP/upload.jks" ]; then
            echo "❌ Keystore vazio — o secret está correto?"
            exit 1
          fi

      # ── Build ──
      # As variáveis de ambiente são lidas pelo signingConfigs
      # do build.gradle.kts (módulo 15, aula 7).
      - name: Build AAB
        env:
          ANDROID_KEYSTORE_PATH: ${{ runner.temp }}/upload.jks
          ANDROID_STORE_PASSWORD: ${{ secrets.ANDROID_STORE_PASSWORD }}
          ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
          ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
        run: |
          flutter build appbundle --release \
            --obfuscate \
            --split-debug-info=simbolos/${{ github.ref_name }}

      # ⭐ O passo que ninguém lembra de fazer à mão.
      # Sem estes arquivos, os crashes desta versão são
      # ILEGÍVEIS PARA SEMPRE (módulo 13, aula 7).
      - name: Arquivar símbolos
        uses: actions/upload-artifact@v4
        with:
          name: simbolos-android-${{ github.ref_name }}
          path: |
            simbolos/
            build/app/outputs/mapping/release/mapping.txt
          # Maior que o tempo em que a versão fica na loja.
          retention-days: 90

      - name: Publicar o AAB
        uses: actions/upload-artifact@v4
        with:
          name: aab-${{ github.ref_name }}
          path: build/app/outputs/bundle/release/app-release.aab

      # ── Faixa INTERNA, nunca produção direto ──
      - name: Enviar à faixa interna
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          packageName: br.com.estudos.foco
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          # ⚠️ 'internal', não 'production'. A promoção é
          # decisão humana, olhando os números.
          track: internal
          status: completed

  # ══════════════════════════════════════════════════════════
  # 3. iOS — ⚠️ macOS custa 10× a cota
  # ══════════════════════════════════════════════════════════
  ios:
    needs: qualidade
    runs-on: macos-latest      # xcodebuild só existe aqui

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - run: flutter pub get

      # ── Assinatura ──
      - name: Restaurar certificado e profile
        env:
          CERT_B64: ${{ secrets.IOS_CERT_P12_B64 }}
          CERT_SENHA: ${{ secrets.IOS_CERT_SENHA }}
          PROFILE_B64: ${{ secrets.IOS_PROFILE_B64 }}
        run: |
          # Keychain temporário: some com o runner. Nunca
          # instale certificado no login.keychain de um runner
          # — mesmo sendo efêmero, é má prática que vira hábito.
          KEYCHAIN="$RUNNER_TEMP/build.keychain"
          SENHA_KEYCHAIN=$(uuidgen)

          security create-keychain -p "$SENHA_KEYCHAIN" "$KEYCHAIN"
          security set-keychain-settings -lut 21600 "$KEYCHAIN"
          security unlock-keychain -p "$SENHA_KEYCHAIN" "$KEYCHAIN"

          echo "$CERT_B64" | base64 -d > "$RUNNER_TEMP/cert.p12"
          security import "$RUNNER_TEMP/cert.p12" \
            -k "$KEYCHAIN" -P "$CERT_SENHA" \
            -T /usr/bin/codesign -T /usr/bin/security

          # Sem esta linha, o codesign pede senha interativamente
          # e o job trava até o timeout.
          security set-key-partition-list -S apple-tool:,apple:,codesign: \
            -s -k "$SENHA_KEYCHAIN" "$KEYCHAIN"

          security list-keychains -d user -s "$KEYCHAIN" login.keychain

          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "$PROFILE_B64" | base64 -d > \
            ~/Library/MobileDevice/Provisioning\ Profiles/perfil.mobileprovision

          # ⚠️ Nunca ecoe as senhas: o mascaramento do GitHub
          # cobre o valor exato do secret, não derivados.
          echo "Certificados instalados:"
          security find-identity -v -p codesigning "$KEYCHAIN" | head -5

      - name: Build IPA
        run: |
          flutter build ipa --release \
            --obfuscate \
            --split-debug-info=simbolos/${{ github.ref_name }} \
            --export-options-plist=ios/ExportOptions.plist

      # ⭐ O iOS precisa dos DOIS conjuntos de símbolos:
      # os do Dart e os dSYM do código nativo.
      # Módulo 16, aula 8.
      - name: Arquivar símbolos
        uses: actions/upload-artifact@v4
        with:
          name: simbolos-ios-${{ github.ref_name }}
          path: |
            simbolos/
            build/ios/archive/Runner.xcarchive/dSYMs/
          retention-days: 90

      - name: Enviar ao TestFlight
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          ASC_KEY_B64: ${{ secrets.ASC_KEY_P8_B64 }}
        run: |
          # O altool procura a chave nesta pasta, PELO NOME.
          mkdir -p ~/private_keys
          echo "$ASC_KEY_B64" | base64 -d > \
            ~/private_keys/AuthKey_${ASC_KEY_ID}.p8

          # Valida antes de transferir: pega ITMS-90717 em
          # segundos, em vez de depois do upload inteiro.
          xcrun altool --validate-app \
            -f build/ios/ipa/*.ipa -t ios \
            --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

          xcrun altool --upload-app \
            -f build/ios/ipa/*.ipa -t ios \
            --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

  # ══════════════════════════════════════════════════════════
  # 4. Resumo
  # ══════════════════════════════════════════════════════════
  resumo:
    needs: [android, ios]
    # if: always() — roda mesmo se um dos dois falhar, para
    # você saber o que aconteceu com cada plataforma.
    if: always()
    runs-on: ubuntu-latest

    steps:
      - name: Resultado
        run: |
          echo "## Release ${{ github.ref_name }}" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "| Plataforma | Situação |" >> $GITHUB_STEP_SUMMARY
          echo "|---|---|" >> $GITHUB_STEP_SUMMARY
          echo "| 🤖 Android | ${{ needs.android.result }} |" >> $GITHUB_STEP_SUMMARY
          echo "| 🍎 iOS | ${{ needs.ios.result }} |" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "### Agora, à mão:" >> $GITHUB_STEP_SUMMARY
          echo "- [ ] Baixar e guardar os símbolos fora do GitHub" >> $GITHUB_STEP_SUMMARY
          echo "- [ ] Testar a build interna num aparelho real" >> $GITHUB_STEP_SUMMARY
          echo "- [ ] 🤖 Promover para produção com rollout de 5%" >> $GITHUB_STEP_SUMMARY
          echo "- [ ] 🍎 Enviar para revisão da App Store" >> $GITHUB_STEP_SUMMARY
```

E o roteiro que prepara os segredos:

> **Arquivo:** `tool/preparar-segredos.ps1` (novo)

```powershell
# Converte os arquivos de assinatura em base64, para colar
# nos secrets do GitHub.
#
# ⚠️ Este script IMPRIME segredos na tela. Rode numa janela
# que você vai fechar, e nunca com a tela compartilhada.

param(
    [string]$Keystore = "$env:USERPROFILE\chaves\foco-upload.jks"
)

$ErrorActionPreference = 'Stop'

function Base64($caminho) {
    if (-not (Test-Path $caminho)) {
        Write-Host "  ⚠️  não encontrado: $caminho" -ForegroundColor Yellow
        return $null
    }
    return [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path $caminho)))
}

Write-Host '═══ SEGREDOS PARA O GITHUB ACTIONS ═══' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Settings → Secrets and variables → Actions → New secret' -ForegroundColor Gray
Write-Host ''

# ── Android ──
Write-Host '🤖 ANDROID' -ForegroundColor Green
$b64 = Base64 $Keystore
if ($b64) {
    $b64 | Set-Clipboard
    Write-Host "  ANDROID_KEYSTORE_B64   ($($b64.Length) caracteres)"
    Write-Host '  ✅ copiado para a área de transferência' -ForegroundColor Green
    Write-Host '     Cole no GitHub e volte aqui.' -ForegroundColor Gray
    Read-Host '     Aperte ENTER quando tiver colado'
}

Write-Host ''
Write-Host '  Estes você digita, de docs/ ou do gerenciador de senhas:'
Write-Host '    ANDROID_STORE_PASSWORD'
Write-Host '    ANDROID_KEY_PASSWORD'
Write-Host '    ANDROID_KEY_ALIAS'
Write-Host '    PLAY_SERVICE_ACCOUNT   (o JSON inteiro, da Google Cloud)'

# ── iOS ──
Write-Host ''
Write-Host '🍎 iOS' -ForegroundColor Green
Write-Host '  Estes saem do Mac (módulo 16, aula 7):'
Write-Host '    IOS_CERT_P12_B64   → base64 do .p12 exportado do Keychain'
Write-Host '    IOS_CERT_SENHA'
Write-Host '    IOS_PROFILE_B64    → base64 do .mobileprovision'
Write-Host '    ASC_KEY_ID'
Write-Host '    ASC_ISSUER_ID'
Write-Host '    ASC_KEY_P8_B64     → base64 do AuthKey_XXXX.p8'
Write-Host ''
Write-Host '  No Mac, para gerar o base64:' -ForegroundColor Gray
Write-Host '    base64 -i certificado.p12 | pbcopy' -ForegroundColor Gray

# ── Verificação ──
Write-Host ''
Write-Host '═══ CONFERÊNCIA ═══' -ForegroundColor Cyan
Write-Host ''
Write-Host '  ⚠️ Nenhum destes arquivos pode estar no Git:' -ForegroundColor Yellow

$proibidos = @('*.jks', '*.keystore', '*.p12', '*.mobileprovision', '*.p8', 'key.properties')
$erros = 0
foreach ($p in $proibidos) {
    $rastreados = git ls-files $p 2>$null
    if ($rastreados) {
        Write-Host "     ❌ $p está VERSIONADO:" -ForegroundColor Red
        $rastreados | ForEach-Object { Write-Host "        $_" -ForegroundColor Red }
        $erros++
    } else {
        Write-Host "     ✅ $p" -ForegroundColor Green
    }
}

if ($erros -gt 0) {
    Write-Host ''
    Write-Host '  ⚠️ Arquivo de assinatura no Git = assinatura comprometida.' -ForegroundColor Red
    Write-Host '     Rotacione a chave; apagar o commit não desfaz.' -ForegroundColor Red
    Write-Host '     Módulo 15, aula 6.' -ForegroundColor Gray
}

Write-Host ''
Write-Host 'Feche esta janela quando terminar.' -ForegroundColor Yellow
```

```bash
git tag -a v1.0.0 -m "Primeira versão"
git push origin v1.0.0
# GitHub → Actions → acompanhe
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `qualidade` em `ubuntu-latest` | 1× a cota; rodar no macOS custaria 10× sem benefício. |
| `needs: qualidade` nos dois builds | Portão barato antes do build caro. |
| `--set-exit-if-changed` no `dart format` | Sem a flag, o comando **formata e passa** — e o CI não verifica nada. |
| `cache: true` no flutter-action | `pub get` de 60 s para 5 s. |
| `java-version: '17'` | O AGP atual exige; a divergência é a causa nº 1 de falha no CI Android. |
| Conferir se o keystore não veio vazio | Secret errado produz um arquivo de 0 byte e um erro obscuro adiante. |
| `$RUNNER_TEMP` | Destruído com o runner. |
| Variáveis lidas pelo `signingConfigs` | O mesmo `build.gradle.kts` serve local e CI (módulo 15, aula 7). |
| **Arquivar os símbolos** | O passo que ninguém lembra à mão — e sem ele os crashes são ilegíveis. |
| `retention-days: 90` | Maior que o tempo em que a versão fica na loja. |
| `simbolos/` **e** `dSYMs/` no iOS | O iOS precisa dos **dois** conjuntos. |
| `track: internal` | **Nunca produção direto**: a promoção é decisão humana. |
| Keychain temporário com senha `uuidgen` | Nunca instale certificado no `login.keychain` de um runner. |
| `set-key-partition-list` | Sem ela, o `codesign` pede senha e o job **trava até o timeout**. |
| `--validate-app` antes do upload | Pega `ITMS-90717` em segundos. |
| `if: always()` no resumo | Você precisa saber o que aconteceu com **cada** plataforma. |
| Checklist no `GITHUB_STEP_SUMMARY` | O que ficou para a pessoa fazer, visível no próprio resultado. |
| `git ls-files` nos arquivos proibidos | Pega o dia em que alguém commitou o keystore. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Runner | `ubuntu-latest` | **`macos-latest`** (10× a cota) |
| Tempo típico | 5–10 min | 10–20 min |
| Segredos | Keystore + 3 senhas | Certificado + profile + API key |
| Publicar pelo CI | ✅ `upload-google-play` | ✅ `altool` |
| Faixa de destino | `internal` | TestFlight |
| Sem o CI, dá para fazer no Windows | ✅ | ❌ |

> 💡 **O CI é a única forma prática de publicar no iOS sem um Mac** — e essa possibilidade muda a
> resposta para quem está começando no Windows. Não é tão bom quanto ter um Mac (depurar um problema
> que só acontece no iOS continua sendo inviável), mas é a diferença entre publicar e não publicar.

> ⚠️ **E o custo do runner macOS é o que dita a frequência.** Build iOS a cada push consome a cota
> de um mês em dias. A regra é: **CI em todo push, build iOS só em tag.**

---

## ⚠️ Erros comuns

### 1. CI sem testes

Responde "compila?", que o editor já responde.

**Correção:** `flutter test` no pipeline.

### 2. `dart format` sem `--set-exit-if-changed`

Formata e passa; não verifica nada.

**Correção:** a flag.

### 3. Rodar tudo no macOS

10× a cota, sem benefício.

**Correção:** Ubuntu para CI, macOS só para iOS.

### 4. Build iOS a cada push

A cota acaba na segunda semana.

**Correção:** só em tags.

### 5. Segredo no repositório

**Correção:** secrets em base64; e se já commitou, **rotacione**.

### 6. `echo` de variável derivada de secret

Escapa do mascaramento e fica no log.

**Correção:** nunca imprima.

### 7. Sem `set-key-partition-list`

O `codesign` pede senha e o job trava até o timeout.

**Correção:** a linha está no exemplo.

### 8. JDK errado no CI Android

Causa nº 1 de falha.

**Correção:** `java-version: '17'`.

### 9. Publicar direto em produção

Ninguém olhou o artefato.

**Correção:** `track: internal`.

### 10. Não arquivar os símbolos

Crashes ilegíveis para sempre.

**Correção:** `upload-artifact` com retenção longa.

### 11. Sem cache

Cada execução baixa tudo.

**Correção:** `actions/cache`.

### 12. Automatizar a decisão de publicar

"Está pronto" e "é hora" são coisas diferentes.

**Correção:** CD até a porta da loja.

---

## 🛠️ Exercício guiado

**Passo 1.** Crie `.github/workflows/ci.yml` com analyze e test. Faça push.

**Passo 2.** Veja o resultado na aba Actions. Quanto tempo levou?

**Passo 3.** Quebre um teste de propósito e faça push. O CI acusa? Aparece no pull request?

**Passo 4.** Desformate um arquivo e faça push. O `dart format` pega?

**Passo 5.** Remova `--set-exit-if-changed` e repita. Ainda pega?

**Passo 6.** Acrescente o cache e compare os tempos de duas execuções.

**Passo 7.** Rode `preparar-segredos.ps1`. Algum arquivo proibido está versionado?

**Passo 8.** Configure os secrets do Android e crie uma tag. O build rodou?

**Passo 9.** Baixe o artefato de símbolos. Os dois conjuntos estão lá?

**Passo 10.** Some os minutos usados no mês. Quanto sobraria da cota gratuita?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/17-publicacao-e-proximos-passos.md](../../exercicios/17-publicacao-e-proximos-passos.md)

Faça os de **Aplicação** (montar o pipeline) e o de **Reflexão** (o que automatizar e o que não).

---

## 🏆 Desafio opcional

Monte o **pipeline completo** do seu projeto, com qualidade de produção.

Requisitos:

- CI em todo push e pull request: format, analyze, test com cobertura.
- Um job que **comenta no pull request** a variação de cobertura.
- Release em tags: Android e iOS, com símbolos arquivados.
- Envio automático às faixas internas das duas lojas.
- Um job semanal que roda `flutter pub outdated` e abre uma issue com o resultado.
- Proteção de branch: `main` só aceita merge com o CI verde.
- Um `README` com um badge de situação do CI.

Depois responda: quanto tempo o pipeline economiza por release, e quanto tempo você gastou
montando-o? Em quantos releases ele se paga — e o que **além do tempo** ele te deu? (Dica: pense no
release que você não fez porque estava cansado demais para os quinze passos manuais.)

---

## 📌 Resumo

- **CI** responde "isto quebrou algo?"; **CD** responde "como isso chega ao usuário?".
- **CI sem testes não serve para quase nada.**
- Estrutura: `on` (quando), `jobs` (o quê), `runs-on` (onde), `steps`.
- **`ubuntu-latest` = 1×; `macos-latest` = 10× a cota.** Separe os jobs por isso.
- **CI em todo push; build iOS só em tags.**
- **`--set-exit-if-changed`** no `dart format` — sem ela, o CI não verifica nada.
- Cache reduz `pub get` de 60 s para 5 s.
- Segredos como **secrets em base64**; o mascaramento cobre o valor exato, **não derivados**.
- **O log do CI é lido por mais gente do que parece.**
- 🍎 `set-key-partition-list` evita que o `codesign` trave o job pedindo senha.
- **Arquive os símbolos automaticamente** — é o passo que ninguém lembra à mão.
- Envie para a **faixa interna**, nunca para produção: "CD até a porta da loja".
- **O runner macOS é a única forma prática de publicar no iOS sem um Mac.**
- **Não automatize a decisão de publicar** — "está pronto" e "é hora" são coisas diferentes.

---

## ☑️ Checklist de domínio

- [ ] Explico a diferença entre CI e CD.
- [ ] Escrevi um workflow do zero.
- [ ] Rodo format, analyze e test a cada push.
- [ ] Uso `--set-exit-if-changed`.
- [ ] Separo os jobs por custo de runner.
- [ ] Uso cache.
- [ ] Guardo segredos como secrets em base64.
- [ ] Nunca imprimo variáveis derivadas de secret.
- [ ] Arquivo os símbolos automaticamente, com retenção longa.
- [ ] Publico na faixa interna, não em produção.
- [ ] Sei gerar o IPA com runner macOS.
- [ ] Sei quanto a minha cota aguenta.

---

## 📚 Referências oficiais

- [GitHub Actions — documentação](https://docs.github.com/pt/actions)
- [Workflow syntax — GitHub](https://docs.github.com/pt/actions/using-workflows/workflow-syntax-for-github-actions)
- [Encrypted secrets — GitHub](https://docs.github.com/pt/actions/security-guides/encrypted-secrets)
- [Billing for GitHub Actions](https://docs.github.com/pt/billing/managing-billing-for-github-actions)
- [flutter-action — GitHub](https://github.com/subosito/flutter-action)
- [upload-google-play — GitHub](https://github.com/r0adkll/upload-google-play)
- [Continuous delivery with Flutter — docs.flutter.dev](https://docs.flutter.dev/deployment/cd)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Versionamento e releases](03-versionamento-e-releases.md) | [README](README.md) | [Monitoramento e feedback](05-monitoramento-e-feedback.md) |
