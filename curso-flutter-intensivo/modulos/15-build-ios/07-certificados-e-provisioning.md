# Aula 7 — Certificados e provisioning

> **Módulo:** 15 - Build e Distribuição iOS · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Entender as **cinco peças** da assinatura iOS: chave privada, CSR, certificado, App ID e
  provisioning profile — e como elas se encaixam.
- Distinguir certificado de **Development** e de **Distribution**.
- Escolher entre assinatura **automática** e **manual**, com critério.
- Registrar aparelhos pelo **UDID** e saber o custo de esquecer um.
- Diagnosticar os erros clássicos: `No profiles found`, `requires a development team`, `doesn't
  include signing certificate`.
- Fazer backup do certificado em **`.p12`** — e saber por que a chave privada é insubstituível.

## ✅ Pré-requisitos

- [Aula 6 — Conta Apple gratuita × paga](06-conta-apple-gratuita-x-paga.md) — conta escolhida e
  Team ID anotado.
- [Aula 4 — Bundle ID e o Xcode](04-bundle-id-e-xcode.md) — `br.com.estudos.foco` definido.
- [Módulo 14, aula 6 — Keystore](../14-build-android/06-keystore.md) — o equivalente Android, e o
  contraste vale muito aqui.

---

## 🍎🪟 Antes de começar: onde você está

> # 🍎 SÓ NO MAC. Você está no Windows 11.
>
> **A assinatura iOS depende do Keychain do macOS.** A chave privada é gerada e armazenada lá, e o
> Xcode é quem conversa com o portal da Apple. Não há caminho por Windows — nem o portal web resolve
> sozinho, porque o **CSR** precisa ser gerado a partir de uma chave privada local.
>
> **O que você faz agora, no Windows:**
> 1. **Entender o modelo.** Esta aula é conceitual antes de ser prática, e entender as cinco peças
>    é o que transforma os erros do Xcode de enigmas em mensagens claras.
> 2. Preparar `docs/assinatura-ios.md` com os campos a preencher no dia do Mac.
> 3. Guardar o roteiro `ferramentas/conferir-assinatura-ios.sh`.
> 4. Reunir os **UDIDs** dos aparelhos que vão testar — dá para obter sem Mac.
>
> **O que fica para o Mac:** gerar a chave, o CSR, o certificado, o profile e assinar.
>
> 💡 **Leia esta aula com atenção mesmo sem Mac.** Os erros de assinatura são a maior fonte de
> frustração do iOS — e quase todos são compreensíveis assim que você sabe qual das cinco peças está
> faltando.

---

## 📖 Conceito

### As cinco peças

```text
1. CHAVE PRIVADA          gerada no seu Mac, fica no Keychain
        │                 ⚠️ insubstituível
        ▼
2. CSR                    pedido de certificado, derivado da chave
        │                 (Certificate Signing Request)
        ▼
3. CERTIFICADO            a Apple assina o CSR e devolve
        │                 prova QUEM você é
        │
4. APP ID                 br.com.estudos.foco no portal
        │                 diz QUAL app
        │
        ▼
5. PROVISIONING PROFILE   junta certificado + App ID + aparelhos
                          diz QUEM pode instalar O QUÊ, ONDE
```

> 📌 **A frase que organiza tudo:** o **certificado** diz *quem você é*; o **App ID** diz *qual
> app*; o **provisioning profile** diz *quem pode instalar qual app em quais aparelhos*. Quase todo
> erro de assinatura é uma dessas três respostas faltando ou desatualizada.

### Por que é mais complicado que no Android

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Peças | **1** (keystore) | **5** |
| Quem emite | **Você** | **A Apple** |
| Validade | Você escolhe (27 anos) | **1 ano** |
| Aparelhos listados | ❌ Não existe | ✅ Por UDID |
| Renovação | ❌ Nunca | ✅ Anual |
| Perder | ⚠️ Fatal sem Play App Signing | ✅ Revoga e reemite |

> 💡 **A burocracia da Apple compra uma rede de proteção.** Perder o keystore do Android sem Play
> App Signing acaba com o app. Perder o certificado iOS é um aborrecimento: você revoga, gera outro,
> e segue. As cinco peças existem porque a Apple controla a cadeia inteira — e é esse controle que
> permite recuperar.

### Chave privada e CSR

```text
Keychain Access → Assistente de Certificado → Solicitar Certificado
  de uma Autoridade de Certificação…
```

Isso faz **duas** coisas de uma vez:

1. Gera um **par de chaves** (privada + pública) e guarda a privada no Keychain.
2. Produz um arquivo `.certSigningRequest` com a chave **pública** e os seus dados.

Você envia o CSR à Apple; ela devolve o certificado.

> ⚠️ **A chave privada nunca sai do seu Mac** — e é a peça insubstituível. Um certificado **sem** a
> chave privada correspondente é inútil: ele aparece no Keychain sem a setinha de expandir, e o
> Xcode o ignora. É o que acontece quando alguém baixa o `.cer` do portal em outro Mac.

### Certificados: Development × Distribution

| | **Development** | **Distribution** |
|---|---|---|
| Para quê | Rodar no seu aparelho | TestFlight e App Store |
| Quantos | Vários | ⚠️ Poucos (limite por conta) |
| Quem usa | Cada desenvolvedor | A equipe compartilha |
| Necessário na conta gratuita | ✅ | ❌ (não existe) |

> ⚠️ **O limite de certificados de distribuição é baixo** (tipicamente 2 ou 3 por conta). Numa
> equipe, cada pessoa criando o seu esgota o limite rapidamente — e aí é preciso revogar um, o que
> invalida os profiles que dependiam dele. **Numa equipe, compartilhe o `.p12`; não gere um por
> pessoa.**

### App ID

É o registro do Bundle ID no portal da Apple, com as **capabilities** que o app usa:

| Capability | Quando |
|---|---|
| Push Notifications | Notificações remotas |
| Sign in with Apple | Login com Apple |
| iCloud | Sincronização |
| HealthKit, Apple Pay | Conforme o app |

```text
Explicit:  br.com.estudos.foco      ← ✅ use este
Wildcard:  br.com.estudos.*         ← ⚠️ não suporta push, iCloud etc.
```

> 📌 **Use App ID explícito.** O wildcard parece prático, mas não permite as capabilities que
> importam — e trocar depois obriga a refazer os profiles.

### Provisioning profile

É o que amarra tudo:

```text
Provisioning Profile
├── Certificado(s)      → quem pode assinar
├── App ID              → qual app
├── Aparelhos (UDIDs)   → onde pode instalar   (só Development e Ad Hoc)
└── Entitlements        → o que o app pode fazer
```

| Tipo | Instala em | Validade |
|---|---|---|
| **Development** | Aparelhos listados | 1 ano |
| **Ad Hoc** | Aparelhos listados (até 100) | 1 ano |
| **App Store** | Qualquer um, via loja | 1 ano |
| Enterprise | Qualquer um (conta especial) | 1 ano |

> ⚠️ **O aparelho precisa estar no profile no momento em que ele foi gerado.** Registrar um UDID
> novo no portal **não atualiza** os profiles existentes — é preciso **regerar** o profile e baixar
> de novo. Esse é o motivo nº 1 de "funciona no meu iPhone e não no dele".

### Assinatura automática × manual

```text
Xcode → Runner → Signing & Capabilities
  ☑ Automatically manage signing
  Team: <o seu>
```

| | **Automática** | **Manual** |
|---|---|---|
| Quem cria os profiles | O Xcode | Você, no portal |
| Esforço | ✅ Quase nenhum | ⚠️ Alto |
| Entender o que acontece | ❌ Caixa-preta | ✅ Total |
| Funciona no CI | ⚠️ Com App Store Connect API | ✅ |
| Equipe grande | ⚠️ Gera profiles demais | ✅ Controlado |
| Recomendado para | ✅ **Você, agora** | Equipes, CI |

> 💡 **Comece com automática.** O Xcode cria e renova os profiles sozinho, e para um app individual
> isso resolve 95 % dos casos. A manual entra quando você precisa de controle — CI, equipe, ou um
> problema que a automática não resolve.

### UDID

O identificador único de cada aparelho. Para registrar um iPhone:

| Como obter | Onde |
|---|---|
| Xcode → Window → Devices | 🍎 Mac |
| Finder, com o iPhone conectado | 🍎 Mac |
| **Ajustes → Geral → Sobre**, toque em "Identificador" | 🪟 **Sem Mac** |
| iTunes no Windows | 🪟 Sem Mac |

> 💡 **Dá para coletar os UDIDs sem Mac**, pedindo a cada pessoa que vá em Ajustes → Geral → Sobre e
> copie o identificador. Faça isso **antes** do dia do Mac: é trabalho que não depende dele.

| Limite de aparelhos | Conta |
|---|---|
| 3 | Gratuita |
| 100 por tipo (iPhone, iPad…) | Paga |

> ⚠️ **Os 100 zeram uma vez por ano**, na renovação — e só nesse momento. Remover um aparelho no
> meio do ano **não libera a vaga**. Registre com critério.

### Backup: o `.p12`

O certificado **com** a chave privada, exportado num arquivo:

```text
Keychain Access → seu certificado → botão direito → Exportar…
  → formato .p12 → defina uma senha
```

| Onde guardar | Veredito |
|---|---|
| Gerenciador de senhas | ✅ Com a senha junto |
| Nuvem cifrada | ✅ |
| Só no Keychain do Mac | ❌ Mac formatado = refazer |
| No Git | ❌ **Nunca** |

> 📌 **O `.p12` é o que permite assinar em outra máquina** — outro Mac, um runner de CI, o
> computador de um colega. Sem ele, cada máquina precisa do seu próprio certificado, e você esbarra
> no limite de distribuição.

---

## 💡 Analogia

Pense em **entrar num prédio de escritórios com segurança rígida**.

- **A chave privada** é a sua digital. Ela é sua, não se copia, não se transfere — e é o que prova
  que você é você. **Perdeu o dedo, perdeu a digital**: nenhum crachá emitido para ela serve mais.
- **O CSR** é o formulário de solicitação de crachá, com a sua digital registrada.
- **O certificado** é o **crachá**: a segurança confere a digital com a do crachá. Ele diz *quem
  você é*, e vale um ano.
- **O App ID** é o **número da sala**. Existe no cadastro do prédio, independente de quem entra.
- **O provisioning profile** é a **autorização de acesso**: "o portador deste crachá pode entrar na
  sala 402, nestes dias, usando estas catracas". Junta as três informações.
- **E aqui está o detalhe que explica o erro nº 1:** a autorização é **impressa**. Cadastrar uma
  catraca nova no sistema **não reimprime** as autorizações que já estão na mão das pessoas. É
  preciso **emitir de novo** — que é exatamente regerar o profile depois de acrescentar um UDID.
- **Development × Distribution** é a diferença entre o crachá de funcionário (entra nas salas que
  o chefe listou) e o de representante da empresa (fala em nome dela lá fora). O segundo é
  controlado: existem poucos, e cada um é rastreado.
- **O `.p12`** é a sua digital registrada em cartório, num envelope lacrado. Com ele, você consegue
  emitir um crachá novo em outra filial. Sem ele, a filial não sabe quem você é.
- **E o contraste com o Android:** lá, você **fabrica o próprio crachá**, sem prédio, sem
  segurança, sem validade. Mais simples — e se o crachá queimar num incêndio, ninguém no mundo
  consegue emitir outro igual.

---

## 🧪 Exemplo mínimo

O caminho completo, com assinatura automática.

> 🍎 **Tudo nesta seção roda no Mac.**

**Passo 1 — abrir o projeto:**

```bash
open ios/Runner.xcworkspace   # ⚠️ workspace, não xcodeproj (aula 4)
```

**Passo 2 — Signing & Capabilities:**

```text
Runner (target) → Signing & Capabilities
  ☑ Automatically manage signing
  Team:      <seu nome ou empresa>
  Bundle ID: br.com.estudos.foco
```

**Passo 3 — o Xcode faz sozinho:**

```text
✓ Criou o certificado de Development
✓ Registrou o App ID br.com.estudos.foco
✓ Registrou este Mac e os aparelhos conectados
✓ Criou o provisioning profile
✓ Baixou tudo
```

**Passo 4 — rodar:**

```bash
flutter run -d <id-do-iphone>
```

**Passo 5 — a primeira vez no aparelho:**

```text
Não foi possível verificar o app
Desenvolvedor não confiável
```

```text
iPhone → Ajustes → Geral → VPN e Gerenciamento de Dispositivo
  → seu Apple ID → Confiar
```

> 📌 **Isso acontece uma vez por certificado, em cada aparelho.** Não é erro — é o iOS pedindo que
> você confirme, no próprio aparelho, que confia em quem assinou.

**Passo 6 — conferir o que foi criado:**

```bash
# Os profiles baixados
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# Os certificados no Keychain
security find-identity -v -p codesigning
```

```text
1) A1B2C3... "Apple Development: Seu Nome (ABCDE12345)"
2) F6E5D4... "Apple Distribution: Sua Empresa (ABCDE12345)"
   2 valid identities found
```

> 💡 **`security find-identity` é o comando que resolve metade dos problemas de assinatura.** Se o
> certificado que você espera não aparece aí, o Xcode não vai encontrá-lo — e o erro que ele mostra
> raramente diz isso.

---

## 📱 Aplicando no Flutter

O diagnóstico de assinatura, e a documentação que evita repetir o trabalho.

---

## 💻 Código completo

> **Arquivo:** `ferramentas/conferir-assinatura-ios.sh` (novo — roda **no Mac**)

```bash
#!/usr/bin/env bash
# Diagnóstico de assinatura iOS.
#
# 🍎 SÓ NO MAC.
#
# Roda ANTES de tentar compilar: quase todo erro de assinatura
# aparece aqui de forma legível, enquanto no Xcode ele chega
# como uma mensagem genérica.

set -uo pipefail
cd "$(dirname "$0")/.."

echo "═══ ASSINATURA iOS ═══"
problemas=0

# ══════════════════════════════════════════════════════════════
echo ""
echo "[1] Certificados no Keychain"

# ⭐ O comando que resolve metade dos problemas: se o certificado
# não aparece aqui, o Xcode não vai encontrá-lo.
identidades=$(security find-identity -v -p codesigning 2>/dev/null || true)

if echo "$identidades" | grep -q "0 valid identities"; then
  echo "  ❌ NENHUM certificado de assinatura."
  echo "     Xcode → Settings → Accounts → Manage Certificates → +"
  problemas=$((problemas + 1))
else
  echo "$identidades" | grep -E "Apple (Development|Distribution)" |
    sed 's/^[[:space:]]*/  /' || echo "  (nenhum da Apple)"

  if ! echo "$identidades" | grep -q "Apple Development"; then
    echo "  ⚠️  Sem certificado de Development — não roda em aparelho."
  fi
  if ! echo "$identidades" | grep -q "Apple Distribution"; then
    echo "  ℹ️  Sem certificado de Distribution — normal na conta gratuita."
  fi
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[2] Provisioning profiles"

perfis=~/Library/MobileDevice/Provisioning\ Profiles

if [ ! -d "$perfis" ] || [ -z "$(ls -A "$perfis" 2>/dev/null)" ]; then
  echo "  ❌ Nenhum profile baixado."
  echo "     Abra o Xcode e deixe a assinatura automática criar."
  problemas=$((problemas + 1))
else
  bundle_id=$(grep 'PRODUCT_BUNDLE_IDENTIFIER' ios/Runner.xcodeproj/project.pbxproj |
    grep -v RunnerTests | head -1 | sed 's/.*= //;s/;//' | tr -d ' ')
  echo "  Bundle ID do projeto: $bundle_id"
  echo ""

  encontrou=0
  hoje=$(date +%s)

  for p in "$perfis"/*.mobileprovision; do
    [ -e "$p" ] || continue

    # O .mobileprovision é um plist ASSINADO: `security cms -D`
    # extrai o XML de dentro dele.
    xml=$(security cms -D -i "$p" 2>/dev/null) || continue

    nome=$(echo "$xml" | plutil -extract Name raw - 2>/dev/null || echo "?")
    app=$(echo "$xml" | plutil -extract Entitlements.application-identifier raw - 2>/dev/null || echo "?")
    venc=$(echo "$xml" | plutil -extract ExpirationDate raw - 2>/dev/null || echo "")

    # O application-identifier vem prefixado com o Team ID.
    if [[ "$app" == *"$bundle_id"* ]]; then
      encontrou=1
      echo "  ✅ $nome"

      if [ -n "$venc" ]; then
        venc_s=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$venc" +%s 2>/dev/null || echo 0)
        if [ "$venc_s" -gt 0 ]; then
          dias=$(( (venc_s - hoje) / 86400 ))
          if [ "$dias" -lt 0 ]; then
            # ⚠️ Profile vencido é a causa de "No profiles found"
            # em projetos que funcionavam semana passada.
            echo "     ❌ VENCIDO há $(( -dias )) dia(s)"
            problemas=$((problemas + 1))
          elif [ "$dias" -lt 30 ]; then
            echo "     ⚠️  vence em $dias dia(s)"
          else
            echo "     vence em $dias dia(s)"
          fi
        fi
      fi

      # Quantos aparelhos este profile autoriza.
      n=$(echo "$xml" | plutil -extract ProvisionedDevices raw - 2>/dev/null | head -1 || echo "")
      if [ -n "$n" ]; then
        echo "     aparelhos autorizados: $n"
        echo "     ⚠️ Registrar um UDID novo NÃO atualiza este profile."
        echo "        É preciso REGERAR e baixar de novo."
      fi
    fi
  done

  if [ "$encontrou" -eq 0 ]; then
    echo "  ❌ Nenhum profile para $bundle_id"
    echo "     O Bundle ID do projeto bate com o do portal?"
    problemas=$((problemas + 1))
  fi
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[3] Configuração do projeto"

pbx=ios/Runner.xcodeproj/project.pbxproj

if grep -q 'DEVELOPMENT_TEAM = ""' "$pbx" || ! grep -q 'DEVELOPMENT_TEAM' "$pbx"; then
  # É a causa de "Signing for Runner requires a development team".
  echo "  ⚠️  DEVELOPMENT_TEAM vazio."
  echo "     Xcode → Runner → Signing & Capabilities → Team"
else
  team=$(grep 'DEVELOPMENT_TEAM' "$pbx" | head -1 | sed 's/.*= //;s/;//' | tr -d ' ')
  echo "  Team ID: $team"
fi

if grep -q 'CODE_SIGN_STYLE = Automatic' "$pbx"; then
  echo "  Assinatura: automática ✅"
elif grep -q 'CODE_SIGN_STYLE = Manual' "$pbx"; then
  echo "  Assinatura: manual"
  echo "  ⚠️ Na manual, VOCÊ mantém os profiles atualizados."
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[4] Aparelhos conectados"

# `xcrun xctrace` lista os aparelhos vistos pelo Mac.
xcrun xctrace list devices 2>/dev/null |
  grep -v "Simulator" | grep -E "^[A-Za-z].*\(" |
  sed 's/^/  /' | head -10 || echo "  (nenhum)"

# ══════════════════════════════════════════════════════════════
echo ""
echo "═══ RESULTADO ═══"
if [ "$problemas" -eq 0 ]; then
  echo "  ✅ Assinatura parece consistente."
else
  echo "  ❌ $problemas problema(s)."
  echo ""
  echo "  Os três erros mais comuns e suas causas:"
  echo "    · 'requires a development team'  → Team não selecionado"
  echo "    · 'No profiles found'            → profile ausente ou vencido"
  echo "    · 'doesn't include signing cert' → certificado revogado ou de outro Mac"
  exit 1
fi
```

> **Arquivo:** `docs/assinatura-ios.md` (novo — preencha no Windows, complete no Mac)

```markdown
# Assinatura iOS — Foco

## Conta

| Campo | Valor |
|---|---|
| Apple ID | <email> |
| **Team ID** | <10 caracteres> |
| Tipo | <gratuita / individual / organização> |

## Identidade do app

| Campo | Valor |
|---|---|
| Bundle ID | br.com.estudos.foco |
| App ID no portal | <explicit> |
| Capabilities | <push? iCloud? Sign in with Apple?> |

## Certificados

| Tipo | Criado em | **Vence em** | Backup .p12? |
|---|---|---|---|
| Apple Development | | | |
| Apple Distribution | | | |

> ⚠️ Validade de 1 ano. Vencido = builds param de funcionar.
> ⚠️ O .p12 (certificado + chave privada) é o que permite assinar
>    em outra máquina. Sem ele, cada Mac precisa do próprio
>    certificado — e o limite de Distribution é baixo.

## Provisioning profiles

| Nome | Tipo | Vence em | Regerado em |
|---|---|---|---|
| | | | |

> ⚠️ Registrar um UDID novo NÃO atualiza os profiles existentes.
>    É preciso REGERAR e baixar. É o motivo nº 1 de
>    "funciona no meu iPhone e não no dele".

## Aparelhos registrados

| Pessoa | Aparelho | UDID | Registrado em |
|---|---|---|---|
| | | | |

> 🪟 O UDID se obtém SEM Mac:
>    Ajustes → Geral → Sobre → toque em "Identificador".
> Conta gratuita: 3 aparelhos.
> Conta paga: 100 por tipo, zerados na renovação anual.
>    Remover no meio do ano NÃO libera a vaga.

## Backup

- [ ] `.p12` do Development exportado e guardado
- [ ] `.p12` do Distribution exportado e guardado
- [ ] Senhas dos `.p12` no gerenciador de senhas
- [ ] Nenhum `.p12`, `.cer` ou `.mobileprovision` no Git
```

E o `.gitignore`:

```gitignore
# ── Assinatura iOS: NUNCA versionar ───────────────────────────
*.p12
*.cer
*.certSigningRequest
*.mobileprovision
ios/Flutter/Generated.xcconfig
```

```bash
chmod +x ferramentas/conferir-assinatura-ios.sh
./ferramentas/conferir-assinatura-ios.sh
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `security find-identity -v -p codesigning` | **Resolve metade dos problemas**: se o certificado não está aí, o Xcode não o acha. |
| Distinguir Development de Distribution | Faltar o primeiro impede rodar; faltar o segundo é normal na conta gratuita. |
| `security cms -D -i` no `.mobileprovision` | O arquivo é um plist **assinado**; este comando extrai o XML de dentro. |
| Comparar `application-identifier` com o Bundle ID | Profile de outro app não serve, e o erro do Xcode não diz isso. |
| Calcular dias até vencer | **Profile vencido** causa "No profiles found" em projeto que funcionava. |
| Aviso sobre regerar após novo UDID | O motivo nº 1 de "funciona no meu e não no dele". |
| Checar `DEVELOPMENT_TEAM` vazio | É a causa de "requires a development team". |
| Detectar `CODE_SIGN_STYLE` | Na manual, você é responsável por manter os profiles. |
| Os três erros no fim | Traduz as mensagens genéricas do Xcode em causas. |
| `docs/assinatura-ios.md` | As validades de 1 ano exigem um lugar para anotar. |
| Colunas de vencimento | Certificado e profile vencem; sem registro, você descobre no dia. |
| Instrução de UDID sem Mac | 🪟 É trabalho que dá para adiantar no Windows. |
| `.gitignore` com `*.p12` e `*.cer` | Certificado versionado é certificado comprometido. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Peças | 1 keystore | 5 |
| Emissor | Você | A Apple |
| Validade | 27 anos | **1 ano** |
| Lista de aparelhos | ❌ | ✅ UDID |
| Testar em aparelho de outra pessoa | ✅ Manda o APK | ⚠️ UDID registrado, ou TestFlight |
| Perder a chave | ⚠️ Fatal sem Play App Signing | ✅ Revoga e reemite |
| Configurar no Windows | ✅ | ❌ |

> 💡 **O contraste é instrutivo.** O Android é simples e sem rede de proteção: uma chave, você
> mesmo, para sempre — e se sumir, o app morre. O iOS é burocrático e recuperável: cinco peças, a
> Apple no meio, renovação anual — e nada é perdido de forma definitiva. **Nenhum dos dois modelos é
> melhor; eles trocam simplicidade por segurança em direções opostas**, e conhecer os dois é o que
> permite não se surpreender com nenhum.

---

## ⚠️ Erros comuns

### 1. `Signing for "Runner" requires a development team`

Team não selecionado.

**Correção:** Xcode → Signing & Capabilities → Team.

### 2. `No profiles for 'br.com.estudos.foco' were found`

Profile ausente, vencido, ou Bundle ID divergente.

**Correção:** rode o diagnóstico; confira o Bundle ID (aula 4).

### 3. `doesn't include signing certificate`

Certificado revogado, ou de outro Mac.

**Correção:** `security find-identity`; recrie ou importe o `.p12`.

### 4. Certificado sem a chave privada

Aparece no Keychain sem a setinha de expandir.

**Correção:** importe o `.p12`, não o `.cer`.

### 5. Aparelho novo não instala

O profile foi gerado antes do UDID existir.

**Correção:** **regere** o profile e baixe.

### 6. "Desenvolvedor não confiável"

Primeira instalação daquele certificado.

**Correção:** Ajustes → Geral → VPN e Gerenciamento de Dispositivo.

### 7. Certificado vencido

Builds param de funcionar de um dia para o outro.

**Correção:** renove; anote a data.

### 8. Limite de certificados de distribuição

Cada pessoa da equipe criou o seu.

**Correção:** compartilhe o `.p12`.

### 9. App ID wildcard com push

Não funciona.

**Correção:** App ID explícito.

### 10. Sem backup do `.p12`

Mac formatado = refazer tudo.

**Correção:** exporte e guarde.

### 11. Versionar `.p12` ou `.mobileprovision`

Certificado comprometido.

**Correção:** `.gitignore`.

### 12. Gastar as vagas de aparelho à toa

Não zeram até a renovação anual.

**Correção:** registre com critério.

---

## 🛠️ Exercício guiado

> 🪟 **Os passos 1 a 4 rodam no Windows.** Os 5 a 10 são para o dia do Mac.

**Passo 1.** Desenhe, de memória, as cinco peças e o que cada uma responde.

**Passo 2.** Peça a duas pessoas o UDID do iPhone delas (Ajustes → Geral → Sobre).

**Passo 3.** Crie `docs/assinatura-ios.md` e preencha o que já sabe.

**Passo 4.** Acrescente `*.p12`, `*.cer` e `*.mobileprovision` ao `.gitignore`.

**Passo 5.** 🍎 Abra o Xcode e ligue a assinatura automática. O que ele criou?

**Passo 6.** 🍎 Rode `security find-identity -v -p codesigning`. Quantas identidades?

**Passo 7.** 🍎 Liste `~/Library/MobileDevice/Provisioning Profiles/`. Quantos arquivos?

**Passo 8.** 🍎 Rode `conferir-assinatura-ios.sh`. Algum problema?

**Passo 9.** 🍎 Instale no iPhone. Apareceu "Desenvolvedor não confiável"? Resolva.

**Passo 10.** 🍎 Exporte o `.p12` e guarde no gerenciador de senhas.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-ios.md](../../exercicios/15-build-ios.md)

Faça os de **Diagnóstico** (traduzir os erros de assinatura) e o de **Reflexão** (comparar os
modelos Android e iOS).

---

## 🏆 Desafio opcional

Monte a **documentação de assinatura** do seu projeto, completa o bastante para outra pessoa assumir.

Requisitos:

- As cinco peças, explicadas com as suas palavras.
- Onde está cada artefato, e quem tem acesso.
- As datas de vencimento de tudo, com lembrete configurado.
- O procedimento para: registrar um aparelho novo, renovar um certificado vencido, e configurar um
  Mac novo do zero.
- O que fazer se um `.p12` **vazar** — que é diferente de perder.
- Um teste: peça a alguém para seguir o documento e assinar um build.

Depois responda: quantos passos do seu procedimento dependem de **você especificamente** — a sua
senha, o seu Apple ID, o seu Mac? Cada um deles é um ponto único de falha no projeto.

---

## 📌 Resumo

- **Cinco peças**: chave privada → CSR → certificado → App ID → provisioning profile.
- **Certificado** = quem você é. **App ID** = qual app. **Profile** = quem instala o quê, onde.
- **A chave privada é insubstituível** e nunca sai do Mac; certificado sem ela é inútil.
- **Development** roda em aparelho; **Distribution** vai para TestFlight e App Store.
- O **limite de certificados de distribuição é baixo** — compartilhe o `.p12`, não crie um por
  pessoa.
- Use **App ID explícito**: wildcard não suporta push, iCloud nem Sign in with Apple.
- ⚠️ **Registrar um UDID novo não atualiza os profiles existentes** — regere e baixe.
- **Assinatura automática** para começar; manual para CI e equipes.
- Tudo vence em **1 ano**. Anote as datas.
- **`security find-identity -v -p codesigning`** resolve metade dos problemas.
- "Desenvolvedor não confiável" é normal na primeira instalação: confie nos Ajustes.
- **Exporte o `.p12`** — é o que permite assinar em outra máquina.
- **Nunca versione** `.p12`, `.cer` ou `.mobileprovision`.
- 🪟 Os **UDIDs se coletam sem Mac**: Ajustes → Geral → Sobre → Identificador.

---

## ☑️ Checklist de domínio

- [ ] Explico as cinco peças e o que cada uma responde.
- [ ] Sei a diferença entre Development e Distribution.
- [ ] Sei por que a chave privada é insubstituível.
- [ ] Uso App ID explícito.
- [ ] Sei que acrescentar um UDID exige regerar o profile.
- [ ] Sei quando usar assinatura automática e quando usar manual.
- [ ] Sei obter o UDID de um aparelho, com e sem Mac.
- [ ] Anotei as datas de vencimento.
- [ ] Sei traduzir os três erros mais comuns.
- [ ] Tenho backup do `.p12` com a senha.
- [ ] Nenhum artefato de assinatura está no Git.

---

## 📚 Referências oficiais

- [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/)
- [Code Signing — developer.apple.com](https://developer.apple.com/documentation/xcode/signing-your-app)
- [Distribute your app — developer.apple.com](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [Provisioning profiles — developer.apple.com](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles)
- [Register a device — developer.apple.com](https://developer.apple.com/help/account/register-devices/register-a-single-device)
- [Build and release an iOS app — docs.flutter.dev](https://docs.flutter.dev/deployment/ios)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 6 — Conta Apple gratuita × paga](06-conta-apple-gratuita-x-paga.md) | [README](README.md) | [Aula 8 — Build: IPA e archive](08-build-ipa-e-archive.md) |
