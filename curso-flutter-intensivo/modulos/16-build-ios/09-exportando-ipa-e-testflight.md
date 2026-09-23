# Aula 9 — Exportando o IPA e TestFlight

> **Módulo:** 16 - Build e Distribuição iOS · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Criar o registro do app no **App Store Connect** e entender o que é imutável ali.
- Enviar o IPA pelo **Organizer**, pelo **Transporter** ou por **linha de comando**.
- Entender por que o **build number** precisa crescer — e o que acontece quando não cresce.
- Distinguir **teste interno** (100 pessoas, imediato) de **externo** (10 000, com revisão).
- Escrever as **notas de teste** e a **Information for Review** que evitam rejeição.
- Diagnosticar os erros de upload: `ITMS-*`, build "Processing" eterno, "Missing Compliance".

## ✅ Pré-requisitos

- [Aula 8 — Build: IPA e archive](08-build-ipa-e-archive.md) — IPA gerado e validado.
- [Aula 6 — Conta Apple gratuita × paga](06-conta-apple-gratuita-x-paga.md) — ⚠️ **TestFlight exige
  conta paga**. Este é o ponto do módulo em que ela se torna necessária.
- [Aula 5 — Ícone, splash, versão e Info.plist](05-icone-splash-versao-infoplist.md) — versão via
  `$(FLUTTER_BUILD_NUMBER)`.
- [Módulo 15, aula 9 — Instalando e validando](../15-build-android/09-instalando-e-validando.md) —
  o equivalente Android.

---

## 🍎🪟 Antes de começar: onde você está

> # ⚠️ PARCIAL. Você está no Windows 11.
>
> **O App Store Connect é um site.** Criar o app, preencher a ficha, gerenciar testadores e ler
> crashes — tudo isso se faz no navegador, de qualquer sistema operacional.
>
> **O que você faz agora, no Windows:**
> 1. **Criar o registro do app** em appstoreconnect.apple.com (se já tem conta paga).
> 2. Preencher nome, subtítulo, categoria, política de privacidade.
> 3. Montar a **lista de testadores** e escrever as **notas de teste**.
> 4. Responder ao questionário de privacidade.
> 5. Guardar o roteiro `ferramentas/enviar-ipa.sh`.
>
> **O que fica para o Mac (ou o CI):** gerar e enviar o IPA — o Transporter e o `altool` só
> existem no macOS.
>
> 💡 **O trabalho de ficha é a maior parte do tempo, e não depende de Mac.** Nome, descrição,
> capturas de tela, política de privacidade e questionário levam horas — e podem ser feitos hoje,
> enquanto o build espera.

---

## 📖 Conceito

### App Store Connect

É o painel onde o app existe para a Apple: appstoreconnect.apple.com.

```text
Meus Apps → + → Novo App
  Plataforma:   iOS
  Nome:         Foco — Organizador de Estudos
  Idioma:       Português (Brasil)
  Bundle ID:    br.com.estudos.foco       ← da lista registrada
  SKU:          foco-2026                 ← interno, você escolhe
```

| Campo | Mutável? |
|---|---|
| Nome | ✅ Entre versões |
| Subtítulo | ✅ |
| Descrição, capturas | ✅ |
| Categoria | ✅ |
| **Bundle ID** | ❌ **Nunca** |
| **SKU** | ❌ Nunca |
| Preço | ✅ |

> ⚠️ **O nome do app precisa ser único na App Store.** "Foco" sozinho provavelmente já existe — daí
> o formato "Foco — Organizador de Estudos". Se o nome estiver ocupado, o campo simplesmente recusa,
> e você descobre na hora de criar.

### Enviar o IPA — três caminhos

| Caminho | Onde | Quando |
|---|---|---|
| **Organizer** | Xcode | ✅ O padrão |
| **Transporter** | App gratuito da Mac App Store | IPA já gerado |
| `xcrun altool` / `notarytool` | Terminal | ✅ CI |

```text
Xcode → Window → Organizer → Archives
  → Validate App        ← ⭐ SEMPRE antes
  → Distribute App → App Store Connect → Upload
```

```bash
# Linha de comando — o caminho do CI.
xcrun altool --upload-app \
  -f build/ios/ipa/foco.ipa \
  -t ios \
  --apiKey "$APP_STORE_KEY_ID" \
  --apiIssuer "$APP_STORE_ISSUER_ID"
```

> 💡 **Use uma chave de API do App Store Connect**, não usuário e senha. A chave é um arquivo `.p8`
> gerado no painel, funciona em CI sem autenticação de dois fatores, e pode ser revogada sem mexer
> na sua conta pessoal.

### O build number

A regra que mais atrapalha quem publica pela primeira vez:

```text
CFBundleVersion (o +N do pubspec) precisa CRESCER a cada envio.
```

```text
ERROR ITMS-4238: "Redundant Binary Upload. There already exists
a binary upload with build version '15' for train '1.2.0'"
```

| | Regra |
|---|---|
| Dentro da mesma versão (`1.2.0`) | O build precisa ser maior |
| Versão nova (`1.2.1`) | O build pode recomeçar, mas é melhor continuar |
| Build descartado | ⚠️ O número **não** volta a ficar livre |
| Build rejeitado | Idem |

> ⚠️ **Nenhum número é reaproveitável, nem de um build que você mesmo descartou.** A contagem é
> monotônica e definitiva. A prática que funciona é nunca reiniciar o `+N`: `1.0.0+1`, `1.0.1+2`,
> `1.1.0+3` — o número cresce sempre, independente da versão.

### "Processing"

Depois do upload, o build aparece como **Processing**:

| Duração | Normal? |
|---|---|
| 5 a 30 min | ✅ |
| 1 a 2 h | ⚠️ Acontece |
| Mais de 4 h | ❌ Algo deu errado |

> 📌 **Se o processamento falhar, você recebe um e-mail** — e só por e-mail. O painel costuma
> apenas remover o build da lista, sem explicação. Confira a caixa de entrada do Apple ID antes de
> concluir que "sumiu".

### Missing Compliance

```text
⚠️ Missing Compliance — Manage
```

É a pergunta sobre criptografia, que aparece em **todo** build.

```xml
<!-- ios/Runner/Info.plist — aula 5 -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

> 💡 Com essa chave, a pergunta **some para sempre**. HTTPS e Keychain são isentos — é o caso do
> Foco, e da maioria dos apps.

### Teste interno × externo

| | **Interno** | **Externo** |
|---|---|---|
| Pessoas | **100** | **10 000** |
| Quem | Da sua equipe no App Store Connect | Qualquer um |
| **Revisão da Apple** | ❌ **Não** | ✅ **Sim** (1 a 2 dias) |
| Disponível | Imediato após o processamento | Após a revisão |
| Como convidar | E-mail | E-mail ou **link público** |
| Validade do build | 90 dias | 90 dias |

> 📌 **Comece sempre pelo interno.** Ele é imediato, não passa por revisão, e é onde você descobre
> que o app trava na primeira tela — antes de fazer 10 000 pessoas baixarem isso. Só promova para
> externo o build que já sobreviveu ao interno.

> ⚠️ **O teste externo passa por uma revisão da Apple** — mais leve que a da App Store, mas real.
> Textos de permissão genéricos e a falta de informações de acesso (login de teste) são os motivos
> mais comuns de reprovação aqui.

### As notas de teste

```text
O que testar nesta versão:

1. Crie uma matéria e registre uma sessão de estudo
2. Confira se o resumo semanal soma os minutos corretamente
3. Feche e reabra o app: os dados devem continuar lá

Novidades:
· Gráfico de progresso semanal
· Correção: o app travava ao excluir a última matéria

Conta de teste (se necessário):
usuário: teste@exemplo.com
senha:   Teste123
```

> ⚠️ **Se o app exige login, forneça uma conta de teste na "Information for Review".** Sem ela, o
> revisor não consegue entrar — e reprova. É a causa nº 1 de rejeição no teste externo, e é
> inteiramente evitável.

### Os 90 dias

Todo build do TestFlight **expira em 90 dias**. Depois disso, ele some da lista dos testadores, sem
aviso prévio a eles.

> 💡 Se o seu ciclo de testes é longo, envie um build novo antes de o antigo expirar. O testador que
> abre o TestFlight e não encontra o app costuma achar que foi removido do programa.

---

## 💡 Analogia

Pense em **lançar um livro**.

- **O App Store Connect** é o cadastro na editora: ISBN, título, categoria, sinopse. O **ISBN** (o
  Bundle ID) não muda nunca; a sinopse você reescreve à vontade.
- **O upload do IPA** é entregar o arquivo da gráfica.
- **O build number** é o **número da remessa**. E a editora tem uma regra rígida: **o número nunca
  se repete**, nem o de uma remessa que você mesmo cancelou. Chegar com um número já usado é voltar
  com o caminhão cheio.
- **O "Processing"** é a conferência na doca. Costuma levar minutos. Se der problema, o aviso vem
  **por carta** — não na porta. Quem só olha a doca conclui que a remessa sumiu.
- **O teste interno** são os **cem exemplares de cortesia** para a equipe e os amigos próximos.
  Saem no mesmo dia, ninguém revisa nada, e é ali que alguém nota que a página 40 saiu em branco.
- **O teste externo** são os **dez mil exemplares de pré-lançamento**. Antes de sair, um revisor da
  editora folheia — não com o rigor do lançamento, mas folheia. E se o livro exige uma senha para
  ler o miolo e você não a forneceu, ele devolve.
- **Os 90 dias** são o prazo do exemplar de cortesia: passou, ele se desfaz na estante. O leitor não
  é avisado — ele simplesmente não encontra mais o livro e acha que foi desconvidado.

---

## 🧪 Exemplo mínimo

O caminho completo do primeiro envio.

**Passo 1 — criar o app** 🪟 *(no navegador, funciona no Windows)*:

```text
appstoreconnect.apple.com → Meus Apps → + → Novo App
  Nome:      Foco — Organizador de Estudos
  Bundle ID: br.com.estudos.foco
  SKU:       foco-2026
```

**Passo 2 — o build** 🍎:

```bash
./ferramentas/build-ios.sh      # aula 8
```

**Passo 3 — validar** 🍎:

```text
Xcode → Organizer → Validate App
```

**Passo 4 — enviar** 🍎:

```text
Organizer → Distribute App → App Store Connect → Upload
```

**Passo 5 — esperar o processamento** 🪟:

```text
App Store Connect → TestFlight → Builds iOS
  1.0.0 (1)  ⏳ Processing…      → ✅ Ready to Submit
```

**Passo 6 — conferir a conformidade** 🪟:

```text
Se aparecer "Missing Compliance", clique em Manage e responda.
Com ITSAppUsesNonExemptEncryption no Info.plist, isto não aparece.
```

**Passo 7 — teste interno** 🪟:

```text
TestFlight → Testadores Internos → + → convide por e-mail
```

**Passo 8 — o testador instala** 📱:

```text
App Store → instale o app "TestFlight"
Abra o e-mail do convite → Aceitar → Instalar
```

> 📌 **Do upload ao app instalado no iPhone de outra pessoa: cerca de 40 minutos**, sendo 30 de
> processamento. É bem mais rápido do que a burocracia das aulas anteriores sugere — a dificuldade
> do iOS está em **chegar** até aqui, não em distribuir depois.

---

## 📱 Aplicando no Flutter

O roteiro de envio e a documentação do TestFlight.

---

## 💻 Código completo

> **Arquivo:** `ferramentas/enviar-ipa.sh` (novo — roda **no Mac** e no CI)

```bash
#!/usr/bin/env bash
# Envia o IPA ao App Store Connect.
#
# 🍎 Roda no Mac. Usa a API Key (.p8), não usuário e senha:
#    a chave funciona em CI sem autenticação de dois fatores e
#    pode ser revogada sem mexer na conta pessoal.
#
# Variáveis necessárias:
#   ASC_KEY_ID      ID da chave (App Store Connect → Chaves)
#   ASC_ISSUER_ID   Issuer ID (mesma tela)
#   ASC_KEY_PATH    caminho do AuthKey_XXXX.p8

set -euo pipefail
cd "$(dirname "$0")/.."

echo "═══ ENVIO AO APP STORE CONNECT ═══"

# ══════════════════════════════════════════════════════════════
echo ""
echo "[1] IPA"

ipa=$(find build/ios/ipa -name '*.ipa' 2>/dev/null | head -1 || true)
if [ -z "$ipa" ]; then
  echo "❌ Nenhum IPA. Rode ./ferramentas/build-ios.sh (aula 8)."
  exit 1
fi
echo "  $ipa ($(du -m "$ipa" | cut -f1) MB)"

# ══════════════════════════════════════════════════════════════
echo ""
echo "[2] Versão"

versao=$(grep '^version:' pubspec.yaml | sed 's/version:[[:space:]]*//')
nome="${versao%%+*}"
numero="${versao##*+}"
echo "  $nome (build $numero)"

# ⭐ Nenhum build number é reaproveitável — nem de um build que
# você mesmo descartou. Um registro local evita descobrir isso
# só depois de transferir o IPA inteiro.
registro="docs/builds-enviados.txt"
if [ -f "$registro" ] && grep -q "^$versao " "$registro"; then
  echo ""
  echo "  ❌ A versão $versao JÁ FOI ENVIADA:"
  grep "^$versao " "$registro" | sed 's/^/     /'
  echo ""
  echo "     O App Store Connect vai recusar (ITMS-4238)."
  echo "     Números não voltam a ficar livres, nem os descartados."
  echo "     Suba o +N no pubspec.yaml e recompile."
  exit 1
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[3] Credenciais"

: "${ASC_KEY_ID:?Defina ASC_KEY_ID}"
: "${ASC_ISSUER_ID:?Defina ASC_ISSUER_ID}"
: "${ASC_KEY_PATH:?Defina ASC_KEY_PATH}"

if [ ! -f "$ASC_KEY_PATH" ]; then
  echo "❌ Chave não encontrada: $ASC_KEY_PATH"
  exit 1
fi

# O altool procura a chave numa dessas pastas, pelo NOME.
# Copiar para lá evita um erro de "API key not found" que não
# menciona o caminho.
mkdir -p ~/private_keys
cp "$ASC_KEY_PATH" ~/private_keys/ 2>/dev/null || true
echo "  chave: $(basename "$ASC_KEY_PATH")"

# ══════════════════════════════════════════════════════════════
echo ""
echo "[4] Validando (antes de transferir)"

# ⭐ Valida sem enviar: pega ITMS-90717 (ícone com alfa) e outros
# em segundos, em vez de depois de vinte minutos de upload.
if xcrun altool --validate-app \
      -f "$ipa" -t ios \
      --apiKey "$ASC_KEY_ID" \
      --apiIssuer "$ASC_ISSUER_ID" 2>&1 | tee /tmp/validacao.txt |
      grep -q "No errors"; then
  echo "  ✅ válido"
else
  echo "  ❌ Validação falhou:"
  grep -E "ERROR|WARNING" /tmp/validacao.txt | sed 's/^/     /' || true
  exit 1
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[5] Enviando (pode levar alguns minutos)"

xcrun altool --upload-app \
  -f "$ipa" -t ios \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"

# ══════════════════════════════════════════════════════════════
echo ""
echo "[6] Registrando"

mkdir -p docs
echo "$versao $(date '+%Y-%m-%d %H:%M') $(basename "$ipa")" >> "$registro"
echo "  anotado em $registro"

# ══════════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════"
echo " $versao enviado"
echo "════════════════════════════════════════"
echo ""
echo "Agora:"
echo "  1. Processing leva 5–30 min (às vezes até 2 h)"
echo "     ⚠️ Se falhar, o aviso vem SÓ POR E-MAIL —"
echo "        o painel apenas remove o build da lista."
echo "  2. Responda 'Missing Compliance', se aparecer"
echo "  3. Teste INTERNO primeiro (imediato, sem revisão)"
echo "  4. Só promova para externo o build que sobreviveu"
echo "  5. ⏳ O build expira em 90 dias"
```

> **Arquivo:** `docs/testflight.md` (novo — preencha **no Windows**)

```markdown
# TestFlight — Foco

## App Store Connect

| Campo | Valor |
|---|---|
| Nome na loja | Foco — Organizador de Estudos |
| Bundle ID | br.com.estudos.foco |
| SKU | foco-2026 |
| Apple ID do app | <número gerado pela Apple> |

> ⚠️ Bundle ID e SKU são IMUTÁVEIS. Nome e descrição, não.

## Notas de teste (o que cada build traz)

### 1.0.0 (1)

**O que testar:**
1. Crie uma matéria e registre uma sessão de estudo
2. Confira se o resumo semanal soma os minutos corretamente
3. Feche e reabra o app: os dados devem continuar lá
4. Teste em modo avião — o app deve funcionar offline

**Novidades:**
· Primeira versão

**Conta de teste:**
<Se o app exige login, forneça uma conta aqui E na
"Information for Review" do App Store Connect.
Sem ela, o revisor não entra — e reprova.
É a causa nº 1 de rejeição no teste externo.>

## Testadores

### Internos (limite 100, imediato, sem revisão)

| Nome | E-mail | Convidado em |
|---|---|---|
| | | |

### Externos (limite 10 000, exige revisão de 1–2 dias)

| Grupo | Pessoas | Link público? |
|---|---|---|
| | | |

## Builds enviados

| Versão | Enviado em | Expira em | Situação |
|---|---|---|---|
| | | | |

> ⏳ Todo build expira em 90 dias e some da lista dos testadores,
>    SEM aviso a eles. Envie um novo antes disso.

## Feedback recebido

| Data | Quem | O quê | Resolvido? |
|---|---|---|---|
| | | | |
```

E o GitHub Actions, para quem não tem Mac:

> **Arquivo:** `.github/workflows/testflight.yml` (novo)

```yaml
# Gera e envia o IPA sem você ter um Mac.
#
# 🪟 É assim que times sem Mac publicam no iOS.
# Módulo 17, aula 4, detalha CI/CD.

name: TestFlight

on:
  push:
    tags: ['v*']

jobs:
  ios:
    # ⚠️ Precisa ser macOS: xcodebuild só existe lá.
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.1'
          channel: stable

      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

      # ── Certificado e profile, a partir de secrets ──
      - name: Restaurar assinatura
        env:
          CERT_P12: ${{ secrets.IOS_CERT_P12 }}
          CERT_SENHA: ${{ secrets.IOS_CERT_SENHA }}
          PROFILE: ${{ secrets.IOS_PROFILE }}
        run: |
          # Keychain temporário: destruído com o runner ao fim.
          KEYCHAIN="$RUNNER_TEMP/build.keychain"
          security create-keychain -p "" "$KEYCHAIN"
          security set-keychain-settings "$KEYCHAIN"
          security unlock-keychain -p "" "$KEYCHAIN"

          echo "$CERT_P12" | base64 -d > "$RUNNER_TEMP/cert.p12"
          security import "$RUNNER_TEMP/cert.p12" \
            -k "$KEYCHAIN" -P "$CERT_SENHA" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: \
            -k "" "$KEYCHAIN"
          security list-keychains -d user -s "$KEYCHAIN" login.keychain

          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "$PROFILE" | base64 -d > \
            ~/Library/MobileDevice/Provisioning\ Profiles/perfil.mobileprovision

      - name: Build IPA
        run: |
          flutter build ipa --release \
            --obfuscate \
            --split-debug-info=simbolos/${{ github.ref_name }} \
            --export-options-plist=ios/ExportOptions.plist

      # ⭐ Os DOIS conjuntos de símbolos. Sem eles, os crashes
      # desta versão são ilegíveis para sempre (aula 8).
      - name: Arquivar símbolos
        uses: actions/upload-artifact@v4
        with:
          name: simbolos-${{ github.ref_name }}
          path: |
            simbolos/
            build/ios/archive/Runner.xcarchive/dSYMs/
          retention-days: 90

      - name: Enviar ao TestFlight
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          ASC_KEY_B64: ${{ secrets.ASC_KEY_P8 }}
        run: |
          mkdir -p ~/private_keys
          echo "$ASC_KEY_B64" | base64 -d > \
            ~/private_keys/AuthKey_${ASC_KEY_ID}.p8

          xcrun altool --upload-app \
            -f build/ios/ipa/*.ipa -t ios \
            --apiKey "$ASC_KEY_ID" \
            --apiIssuer "$ASC_ISSUER_ID"
```

```bash
chmod +x ferramentas/enviar-ipa.sh
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export ASC_KEY_PATH=~/chaves/AuthKey_XXXXXXXXXX.p8
./ferramentas/enviar-ipa.sh
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| API Key `.p8` em vez de senha | Funciona em CI sem 2FA e pode ser revogada sem afetar a conta. |
| **Registro local de builds enviados** | Nenhum número é reaproveitável; evita descobrir o `ITMS-4238` após o upload. |
| `cp` da chave para `~/private_keys` | O `altool` a procura ali **pelo nome**; o erro não menciona o caminho. |
| **`--validate-app` antes de `--upload-app`** | Pega o `ITMS-90717` em segundos, não depois de vinte minutos. |
| Aviso "o aviso vem só por e-mail" | O painel apenas remove o build, sem explicar. |
| Ordem interno → externo | O interno é imediato e sem revisão: é onde os problemas aparecem primeiro. |
| Aviso dos 90 dias | O testador que não encontra o app acha que foi desconvidado. |
| Campo de conta de teste no `testflight.md` | **Causa nº 1 de rejeição** no teste externo. |
| Keychain temporário no CI | Destruído com o runner; não deixa credencial em máquina compartilhada. |
| `retention-days: 90` nos símbolos | Menor que isso e você perde a capacidade de decifrar crashes. |
| Arquivar `simbolos/` **e** `dSYMs/` | O iOS precisa dos dois conjuntos (aula 8). |
| `runs-on: macos-latest` | `xcodebuild` só existe no macOS. |

---

## 🤖🍎 Android × iOS

| | 🤖 Play Console | 🍎 App Store Connect |
|---|---|---|
| Teste interno | Faixa interna (100) | TestFlight interno (100) |
| Revisão do teste interno | ❌ | ❌ |
| Teste aberto | Ilimitado | TestFlight externo (10 000) |
| Revisão do teste aberto | ❌ | ✅ **Sim** |
| Validade do build de teste | ❌ Não expira | ⏳ **90 dias** |
| App do testador | Play Store normal | **TestFlight** |
| Distribuir fora da loja | ✅ APK | ❌ |
| Feedback embutido | ⚠️ Limitado | ✅ Captura + comentário |

> 💡 **O TestFlight é melhor que o equivalente Android em quase tudo**: o testador manda captura de
> tela com comentário direto do app, os crashes chegam organizados, e o convite é um link. O preço é
> a revisão do teste externo e os 90 dias de validade.

> 📌 **E a diferença cultural aparece de novo:** no Android, você pode simplesmente mandar o APK por
> mensagem. No iOS, **não existe** esse caminho — TestFlight ou nada. Isso torna o fluxo mais
> trabalhoso e, ao mesmo tempo, mais rastreável: você sabe exatamente quem tem qual build.

---

## ⚠️ Erros comuns

### 1. `ITMS-4238` — build repetido

Números não voltam a ficar livres.

**Correção:** suba o `+N`, sempre.

### 2. Reiniciar o `+N` em versão nova

Colide com um número já usado.

**Correção:** nunca reinicie.

### 3. Não rodar Validate App

Descobre o erro depois do upload.

**Correção:** valide antes.

### 4. "Processing" eterno

Falhou, e o aviso foi por e-mail.

**Correção:** confira a caixa de entrada.

### 5. Missing Compliance a cada build

**Correção:** `ITSAppUsesNonExemptEncryption` no `Info.plist`.

### 6. Não fornecer conta de teste

**Causa nº 1 de rejeição** no teste externo.

**Correção:** Information for Review.

### 7. Ir direto para o teste externo

Espera a revisão para descobrir que trava na primeira tela.

**Correção:** interno primeiro.

### 8. Build expirado

Some para os testadores, sem aviso a eles.

**Correção:** envie um novo antes dos 90 dias.

### 9. Notas de teste vazias

O testador não sabe o que testar e não testa nada.

**Correção:** liste passos concretos.

### 10. Nome de app já existente

**Correção:** nome com complemento.

### 11. Usuário e senha no CI

Quebra com 2FA.

**Correção:** API Key.

### 12. Não arquivar os símbolos

Crashes ilegíveis.

**Correção:** os dois conjuntos, como artefato.

---

## 🛠️ Exercício guiado

> 🪟 **Os passos 1 a 5 rodam no Windows.** Os 6 a 10 exigem Mac ou CI.

**Passo 1.** Crie o app no App Store Connect. O nome que você queria estava livre?

**Passo 2.** Preencha categoria, subtítulo e política de privacidade.

**Passo 3.** Crie `docs/testflight.md` e escreva as notas de teste da sua primeira versão.

**Passo 4.** Monte a lista de testadores internos com nome e e-mail.

**Passo 5.** Gere uma API Key em App Store Connect → Usuários e Acesso → Chaves.

**Passo 6.** 🍎 Rode `build-ios.sh` e depois `enviar-ipa.sh`.

**Passo 7.** 🍎 Rode `enviar-ipa.sh` de novo, sem subir o `+N`. Ele recusa antes de enviar?

**Passo 8.** 🪟 Acompanhe o "Processing". Quanto tempo levou?

**Passo 9.** 🪟 Convide um testador interno e peça que instale. Quanto tempo do upload à instalação?

**Passo 10.** 📱 Peça ao testador que envie um feedback pelo TestFlight. Ele chegou no painel?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/16-build-ios.md](../../exercicios/16-build-ios.md)

Faça os de **Aplicação** (fluxo completo do TestFlight) e o de **Reflexão** (planejar o beta do seu
app).

---

## 🏆 Desafio opcional

Monte um **programa de beta** completo para o seu app.

Requisitos:

- Um grupo interno (equipe) e um externo (usuários convidados).
- Notas de teste que dizem **o que testar**, em passos concretos — não "teste o app".
- Uma conta de teste documentada, com dados suficientes para o revisor.
- Um calendário: build novo a cada X dias, sempre antes dos 90.
- Um processo para o feedback recebido: onde vira issue, quem prioriza, como o testador é avisado
  de que foi resolvido.
- Os mesmos testadores na faixa interna do Android (módulo 15), para comparar.

Depois responda: o feedback que chegou pelo TestFlight foi diferente, em qualidade, do que chegou
pelo Android? O que na ferramenta explica a diferença — e o que dá para compensar do lado Android
com processo?

---

## 📌 Resumo

- O **App Store Connect** é um site: a ficha do app se preenche **de qualquer sistema operacional**.
- **Bundle ID e SKU são imutáveis**; nome e descrição, não.
- Três caminhos de envio: **Organizer**, Transporter e `xcrun altool` (CI).
- Use **API Key `.p8`**, não usuário e senha: funciona com 2FA e é revogável.
- **O build number precisa crescer sempre** — nenhum número é reaproveitável, nem de build
  descartado.
- **Nunca reinicie o `+N`** ao mudar de versão.
- **Valide antes de enviar**: segundos contra vinte minutos de upload perdido.
- "Processing" leva 5–30 min; se falhar, **o aviso vem só por e-mail**.
- **Missing Compliance** some com `ITSAppUsesNonExemptEncryption` no `Info.plist`.
- **Interno**: 100 pessoas, imediato, sem revisão. **Externo**: 10 000, com revisão de 1–2 dias.
- **Comece sempre pelo interno.**
- **Forneça conta de teste** na Information for Review — é a causa nº 1 de rejeição.
- **Todo build expira em 90 dias** e some para os testadores, sem aviso a eles.
- Do upload ao app instalado no iPhone de outra pessoa: **cerca de 40 minutos**.
- 🪟 Toda a ficha e a gestão de testadores se fazem no Windows; só o build exige Mac ou CI.

---

## ☑️ Checklist de domínio

- [ ] Criei o app no App Store Connect.
- [ ] Sei o que é imutável ali.
- [ ] Sei enviar pelos três caminhos.
- [ ] Uso API Key em vez de senha.
- [ ] Incremento o build number a cada envio, sem reiniciar.
- [ ] Valido antes de enviar.
- [ ] Sei que a falha de processamento chega por e-mail.
- [ ] Respondi à conformidade no `Info.plist`.
- [ ] Distingo teste interno de externo.
- [ ] Começo sempre pelo interno.
- [ ] Escrevo notas de teste com passos concretos.
- [ ] Forneço conta de teste quando o app exige login.
- [ ] Controlo os 90 dias de validade.

---

## 📚 Referências oficiais

- [App Store Connect](https://appstoreconnect.apple.com/)
- [TestFlight — developer.apple.com](https://developer.apple.com/testflight/)
- [Uploading builds — App Store Connect Help](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds)
- [App Store Connect API Keys](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)
- [altool — developer.apple.com](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool)
- [Beta testing — App Store Connect Help](https://developer.apple.com/help/app-store-connect/test-a-beta-version/overview-of-testflight)
- [Build and release an iOS app — docs.flutter.dev](https://docs.flutter.dev/deployment/ios)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 8 — Build: IPA e archive](08-build-ipa-e-archive.md) | [README](README.md) | [Aula 10 — Diagnóstico: CocoaPods e assinatura](10-diagnostico-cocoapods-e-assinatura.md) |
