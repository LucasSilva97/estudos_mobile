# Aula 10 — Diagnóstico: CocoaPods e assinatura

> **Módulo:** 15 - Build e Distribuição iOS · **Tempo estimado:** 40 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Aplicar um **método de 6 passos** para qualquer erro de build iOS.
- Achar o detalhe real do erro no **Report Navigator** — e não na mensagem da tela.
- Consultar uma **tabela sintoma → causa → correção** com os erros deste módulo.
- Resolver os cinco grupos: **CocoaPods**, **assinatura**, **Xcode**, **upload** e **cache**.
- Limpar **na ordem certa**, do mais barato ao mais caro.
- Montar um relato de erro que outra pessoa consiga responder.

## ✅ Pré-requisitos

- As aulas 1 a 9 deste módulo — esta é a aula de **referência**, e aponta para todas elas.
- [Módulo 14, aula 10 — Diagnóstico de build](../14-build-android/10-diagnostico-de-build.md) — o
  método é o mesmo; os erros é que são outros.

---

## 🍎🪟 Antes de começar: onde você está

> # ⚠️ PARCIAL. Você está no Windows 11.
>
> **Você não consegue reproduzir estes erros — mas consegue estar preparado para eles.** Esta é uma
> aula de **referência**: ela existe para ser consultada no dia em que o Xcode falhar, não para ser
> decorada agora.
>
> **O que você faz agora, no Windows:**
> 1. **Ler a tabela inteira**, uma vez. Não para memorizar — para reconhecer.
> 2. Guardar `ferramentas/diagnosticar-ios.sh` no projeto.
> 3. Criar `docs/DEBUG-IOS.md` a partir da tabela.
> 4. **Aprender onde fica o Report Navigator.** É a informação mais valiosa desta aula.
>
> **O que fica para o Mac:** tudo que envolva executar.
>
> 💡 **A leitura vale o tempo.** Quem chega ao Mac sem ter lido esta aula passa horas em erros que
> têm correção de uma linha — e, pior, tenta correções aleatórias da internet, que costumam piorar o
> estado do projeto.

---

## 📖 Conceito

### O método

1. **Ache o erro real.** A mensagem da tela do Xcode é frequentemente genérica; o detalhe está no
   **Report Navigator (⌘9)**.
2. **Em que etapa falhou?** `pod install`, compilação, assinatura, archive, export ou upload.
3. **O que mudou?** Um `pub add`, update do Xcode, `git pull`, troca de Mac, certificado vencido.
4. **Limpe na ordem**: `flutter clean` → `pod install` → DerivedData → `pod deintegrate`.
5. **Confira a assinatura** (aula 7) — é a causa mais frequente.
6. **Isole**: `flutter create teste`, acrescente só o plugin suspeito.

> 📌 **O passo 1 é o que distingue o iOS do Android.** No Gradle, a mensagem diz o que houve, ainda
> que enterrada em log. No Xcode, a tela costuma mostrar apenas "Command PhaseScriptExecution failed
> with a nonzero exit code" — e o erro de verdade está três níveis abaixo, no Report Navigator.

### O Report Navigator

```text
Xcode → painel esquerdo → ícone de balão de fala (⌘9)
  → clique na última build
  → expanda a etapa em VERMELHO
  → clique no ícone de "expandir transcrição" (à direita da linha)
```

> 💡 **O ícone de expandir transcrição é o que quase ninguém encontra.** Ele fica no canto direito
> da linha da etapa e revela o log completo daquele passo — com a mensagem real. Sem ele, você lê um
> resumo que não diz nada.

### A limpeza, na ordem

```bash
# Nível 1 — segundos. Resolve a maioria.
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Nível 2 — ~2 min. O cache de build do Xcode.
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Nível 3 — ~5 min. Reinstala os pods do zero.
cd ios
pod deintegrate
rm -rf Pods Podfile.lock
pod install
cd ..

# Nível 4 — ~15 min. Último recurso.
pod cache clean --all
pod repo update
```

> ⚠️ **`rm -rf Podfile.lock` não é rotina.** Ele descarta as versões travadas dos pods e permite que
> tudo atualize — o que resolve conflitos e, ocasionalmente, introduz outros. Use no nível 3, com
> consciência, e confira o `git diff` do `Podfile.lock` depois.

---

## 🧯 A tabela

### Grupo 1 — CocoaPods

| Sintoma | Causa | Correção |
|---|---|---|
| `module 'X' not found` | ⚠️ **Abriu o `.xcodeproj`** | Abra o `.xcworkspace` (aula 4) |
| `module 'X' not found` (no workspace) | Faltou `pod install` | `cd ios && pod install` |
| `CocoaPods not installed` | Falta o CocoaPods | `sudo gem install cocoapods` |
| `Podfile.lock` divergente | Alguém atualizou | `pod install` |
| `Unable to find a specification for 'X'` | Índice local velho | `pod repo update` |
| `platform :ios, '12.0' too low` | Plugin exige mais | Suba no `Podfile` **e** no `pbxproj` (aula 4) |
| `CDN: trunk Repo update failed` | Rede, ou CDN fora | `pod repo update`; tente de novo |
| `The sandbox is not in sync with the Podfile.lock` | `pod install` faltando | Rode e recompile |
| `Error installing X` / `ffi` | Arquitetura do Ruby (Apple Silicon) | `arch -x86_64 pod install`, ou reinstale o CocoaPods |
| Build lento eternamente | Pods recompilando | Nível 2 de limpeza |

> 📌 **Regra geral do CocoaPods:** rode **`pod install` depois de todo `flutter pub get`**. Um plugin
> novo traz código nativo que só entra no projeto por ali, e esquecer disso produz um `module not
> found` que parece ser de outra natureza.

### Grupo 2 — Assinatura

| Sintoma | Causa | Correção |
|---|---|---|
| `Signing for "Runner" requires a development team` | Team não selecionado | Xcode → Signing & Capabilities → Team |
| `No profiles for 'br.com.estudos.foco' were found` | Profile ausente, vencido ou Bundle ID divergente | Aula 7; confira o Bundle ID |
| `doesn't include signing certificate` | Certificado revogado ou de outro Mac | `security find-identity`; importe o `.p12` |
| `No signing certificate "iOS Development" found` | Sem certificado | Xcode → Settings → Accounts → Manage Certificates |
| Certificado sem chave privada | Importou o `.cer`, não o `.p12` | Importe o `.p12` |
| `Provisioning profile doesn't include device` | UDID não estava no profile | **Regere** o profile (aula 7) |
| `The maximum number of certificates has been reached` | Limite de Distribution | Revogue um, ou compartilhe o `.p12` |
| "Desenvolvedor não confiável" no iPhone | Primeira instalação | Ajustes → Geral → VPN e Gerenciamento |
| App para de abrir após 7 dias | Conta gratuita | Reinstale, ou conta paga (aula 6) |
| `Your account does not have permission` | Papel insuficiente na equipe | Peça acesso ao admin |

### Grupo 3 — Xcode e build

| Sintoma | Causa | Correção |
|---|---|---|
| `Command PhaseScriptExecution failed` | ⚠️ **Genérico** | **Report Navigator (⌘9)** |
| `Sandbox: rsync deny file-write-create` | Sandbox do Xcode 15+ | `ENABLE_USER_SCRIPT_SANDBOXING = NO` |
| `Building for iOS, but linked framework was built for simulator` | Arquitetura errada | Limpe o nível 2; confira `EXCLUDED_ARCHS` |
| `Multiple commands produce ...` | Arquivo duplicado no projeto | Remova a duplicata no Xcode |
| `Undefined symbols for architecture arm64` | Pod mal compilado | Limpeza nível 3 |
| `Xcode requires a newer version of macOS` | macOS antigo | Atualize o macOS ou use um Xcode compatível |
| `flutter doctor` acusa a licença | Licença não aceita | `sudo xcodebuild -license accept` |
| `xcrun: error: unable to find utility` | `xcode-select` apontando errado | `sudo xcode-select -s /Applications/Xcode.app` |
| Archive não aparece no Organizer | Build "Generic iOS Device" ausente | Selecione "Any iOS Device (arm64)" |

> ⚠️ **`Command PhaseScriptExecution failed with a nonzero exit code` não é um erro** — é o Xcode
> dizendo que **algum script** falhou. Qual, e por quê, está no Report Navigator. Procurar essa
> mensagem na internet devolve centenas de causas diferentes, todas verdadeiras para alguém.

### Grupo 4 — Upload e App Store Connect

| Sintoma | Causa | Correção |
|---|---|---|
| `ITMS-90717` — ícone com alfa | Transparência no ícone | `remove_alpha_ios: true` (aula 5) |
| `ITMS-4238` — build repetido | `CFBundleVersion` já usado | Suba o `+N` (aula 9) |
| `ITMS-90683` — falta `NSxUsageDescription` | Permissão sem texto | Acrescente ao `Info.plist` (aula 5) |
| `ITMS-90022/23/96` — ícone faltando | Dimensão ausente | Regere com `flutter_launcher_icons` |
| `Invalid Bundle. Missing Info.plist value` | Chave obrigatória ausente | Confira o `Info.plist` |
| "Processing" por horas | Falhou no servidor | ⚠️ **Confira o e-mail** |
| `Missing Compliance` | Pergunta de criptografia | `ITSAppUsesNonExemptEncryption` (aula 5) |
| `App Store Connect Operation Error` genérico | Vários | Rode `--validate-app` e leia a saída |
| Teste externo reprovado | ⚠️ **Sem conta de teste** | Information for Review (aula 9) |

### Grupo 5 — Flutter e ambiente

| Sintoma | Causa | Correção |
|---|---|---|
| `flutter doctor` sem `[✓] Xcode` | Xcode ou ferramentas ausentes | Aula 2 |
| `flutter devices` não lista o iPhone | Modo de Desenvolvedor desligado | Ajustes → Privacidade → Modo de Desenvolvedor (iOS 16+) |
| `flutter run` não acha o simulador | Simulador fechado | `open -a Simulator` |
| `Generated.xcconfig` ausente | Nunca buildou | `flutter build ios --config-only` |
| Versão errada no app instalado | `Info.plist` com valor literal | Use `$(FLUTTER_BUILD_NAME)` (aula 5) |
| Mudança no Dart não aparece | Build em cache | `flutter clean` |

---

## 💡 Analogia

Pense num **médico diante de um exame com resultado "alterado"**.

- **O laudo do Xcode** costuma dizer apenas isso: "alterado". Não diz o quê, nem onde. É o
  `Command PhaseScriptExecution failed`.
- **O Report Navigator é o exame completo**, com todas as medidas. Ele sempre esteve disponível — só
  não vem impresso no resumo, e é preciso saber pedir.
- **Procurar a mensagem genérica na internet** é procurar "exame alterado" num fórum: você encontra
  centenas de relatos, todos verdadeiros para quem escreveu, nenhum necessariamente sobre você. E
  seguir o tratamento de outra pessoa costuma piorar o quadro — que é exatamente o que acontece
  quando alguém apaga o `Podfile.lock` porque leu num fórum.
- **"O que mudou?"** continua sendo a pergunta que mais resolve. O paciente estava bem na semana
  passada.
- **Limpar na ordem** é começar pelo exame mais simples. `pod deintegrate` é internação.
- **E a diferença entre iOS e Android**, aqui, é a qualidade do laudo. O Gradle escreve dez páginas
  e diz o que houve. O Xcode escreve uma linha e guarda as dez páginas noutra sala. **Saber onde
  fica a sala é metade do trabalho.**

---

## 🧪 Exemplo mínimo

Três erros reais, resolvidos pelo método.

### Caso 1 — `module 'shared_preferences' not found`

**Passo 1 — o erro real:** este já é específico, não precisa do Report Navigator.

**Passo 2 — etapa:** compilação.

**Passo 3 — o que mudou:** rodei `flutter pub add shared_preferences` hoje.

**A causa:** plugin novo traz código nativo, que só entra no projeto pelo `pod install`.

```bash
cd ios && pod install && cd ..
flutter run
```

> 📌 **Se o erro persistir**, a segunda hipótese é ter aberto o `.xcodeproj` em vez do
> `.xcworkspace` (aula 4). As duas causas produzem a **mesma mensagem**.

### Caso 2 — `Command PhaseScriptExecution failed with a nonzero exit code`

**Passo 1 — achar o erro real.** A mensagem não diz nada. Report Navigator (⌘9) → última build →
etapa vermelha → expandir transcrição:

```text
error: Sandbox: rsync(12345) deny(1) file-write-create
  /Users/voce/Library/Developer/Xcode/DerivedData/.../Runner.app/Frameworks/...
```

**Passo 2 — etapa:** um script de build, bloqueado pelo sandbox.

**Passo 3 — o que mudou:** atualizei o Xcode ontem.

**A causa:** o Xcode 15 passou a executar scripts de build em sandbox.

```text
Xcode → Runner → Build Settings → busque "User Script Sandboxing"
  ENABLE_USER_SCRIPT_SANDBOXING = NO
```

> 💡 **Repare no caminho:** a mensagem da tela era inútil, e a do Report Navigator resolveu o caso
> em trinta segundos. Este é o padrão da maioria dos erros do Xcode.

### Caso 3 — `No profiles for 'br.com.estudos.foco' were found`

**Passo 3 — o que mudou:** nada; funcionava semana passada.

**Passo 5 — conferir a assinatura:**

```bash
./ferramentas/conferir-assinatura-ios.sh
```

```text
[2] Provisioning profiles
  ✅ iOS Team Provisioning Profile: br.com.estudos.foco
     ❌ VENCIDO há 3 dia(s)
```

**A causa:** o profile venceu. Eles valem **um ano** (aula 7).

**Correção:** no Xcode, com assinatura automática, desmarcar e remarcar "Automatically manage
signing" faz o Xcode gerar um novo.

> 📌 **"Funcionava semana passada" com erro de assinatura é quase sempre vencimento.** Certificados
> e profiles têm prazo — e é a única categoria de erro do desenvolvimento que aparece **sem
> ninguém ter mexido em nada**.

---

## 📱 Aplicando no Flutter

O diagnosticador que aplica o método e sugere a causa.

---

## 💻 Código completo

> **Arquivo:** `ferramentas/diagnosticar-ios.sh` (novo — roda **no Mac**)

```bash
#!/usr/bin/env bash
# Roda o build iOS, captura a saída e sugere a causa.
#
# 🍎 SÓ NO MAC.
#
# Automatiza os passos 1, 2 e 4 do método — e lembra você do
# passo 3, que é o que mais resolve.

set -uo pipefail
cd "$(dirname "$0")/.."

NIVEL=${1:-0}       # nível de limpeza antes de tentar
LOG=diagnostico-ios.txt

# ══════════════════════════════════════════════════════════════
# PASSO 3 — perguntado ANTES de tudo.
echo "═══ O QUE MUDOU? ═══"
git log --oneline -5 2>/dev/null | sed 's/^/  /' || true
alterados=$(git status --short 2>/dev/null | head -10 || true)
if [ -n "$alterados" ]; then
  echo ""
  echo "  Não commitado:"
  echo "$alterados" | sed 's/^/    /'
fi

# ⭐ Vencimento é a única categoria de erro que aparece SEM
# ninguém ter mexido em nada. Vale checar antes de investigar.
echo ""
echo "  💡 'Funcionava semana passada'? Suspeite de vencimento:"
echo "     certificados e profiles valem 1 ano (aula 7)."

# ══════════════════════════════════════════════════════════════
# PASSO 4 — limpeza, na ordem.
if [ "$NIVEL" -ge 1 ]; then
  echo ""
  echo "Limpeza nível 1…"
  flutter clean && flutter pub get
  (cd ios && pod install)
fi
if [ "$NIVEL" -ge 2 ]; then
  echo "Limpeza nível 2 (DerivedData)…"
  rm -rf ~/Library/Developer/Xcode/DerivedData/*
fi
if [ "$NIVEL" -ge 3 ]; then
  echo "Limpeza nível 3 (pods do zero)…"
  # ⚠️ Descarta as versões travadas: confira o git diff do
  # Podfile.lock depois.
  (cd ios && pod deintegrate && rm -rf Pods Podfile.lock && pod install)
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "Compilando…"
saida=$(flutter build ios --release --no-codesign 2>&1 | tee "$LOG")

if [ "${PIPESTATUS[0]}" -eq 0 ]; then
  echo "✅ Build OK."
  exit 0
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "═══ CAUSA PROVÁVEL ═══"

sugerir() {
  if echo "$saida" | grep -qE "$1"; then
    echo "  ❌ $2"
    echo "     → $3"
    echo ""
    achou=1
  fi
}
achou=0

# ── CocoaPods ──
sugerir "module '.*' not found" \
  "Módulo nativo não encontrado" \
  "1) cd ios && pod install   2) abriu o .xcworkspace, não o .xcodeproj? (aula 4)"

sugerir "sandbox is not in sync" \
  "Podfile.lock dessincronizado" \
  "cd ios && pod install"

sugerir "Unable to find a specification" \
  "Índice do CocoaPods desatualizado" \
  "cd ios && pod repo update && pod install"

sugerir "deployment target|platform :ios.*too low|higher minimum deployment" \
  "Um plugin exige iOS mais novo" \
  "Suba platform :ios no Podfile E IPHONEOS_DEPLOYMENT_TARGET no pbxproj (aula 4)"

sugerir "CocoaPods not installed|pod: command not found" \
  "CocoaPods ausente" \
  "sudo gem install cocoapods"

# ── Assinatura ──
sugerir "requires a development team" \
  "Team não selecionado" \
  "Xcode → Runner → Signing & Capabilities → Team (aula 7)"

sugerir "No profiles for" \
  "Provisioning profile ausente ou VENCIDO" \
  "./ferramentas/conferir-assinatura-ios.sh — profiles valem 1 ano"

sugerir "doesn't include signing certificate|No signing certificate" \
  "Certificado ausente ou de outro Mac" \
  "security find-identity -v -p codesigning; importe o .p12 (aula 7)"

sugerir "does not include.*device|doesn't include the currently selected device" \
  "O aparelho não está no profile" \
  "⚠️ Registrar o UDID NÃO atualiza profiles existentes: REGERE (aula 7)"

# ── Xcode ──
sugerir "Sandbox: rsync.*deny|deny\(1\) file-write" \
  "Sandbox de scripts do Xcode 15+" \
  "Build Settings → ENABLE_USER_SCRIPT_SANDBOXING = NO"

sugerir "Multiple commands produce" \
  "Arquivo duplicado no projeto" \
  "Remova a duplicata no Project Navigator"

sugerir "built for.*simulator|Building for iOS.*but" \
  "Framework compilado para a arquitetura errada" \
  "Limpeza nível 2; confira EXCLUDED_ARCHS"

sugerir "Undefined symbols for architecture" \
  "Pod mal compilado" \
  "Limpeza nível 3 (pods do zero)"

sugerir "unable to find utility|xcode-select" \
  "xcode-select apontando para o lugar errado" \
  "sudo xcode-select -s /Applications/Xcode.app"

sugerir "license|agreeing to the Xcode" \
  "Licença do Xcode não aceita" \
  "sudo xcodebuild -license accept"

# ── Genérico ──
if echo "$saida" | grep -q "PhaseScriptExecution failed"; then
  echo "  ⚠️  'Command PhaseScriptExecution failed' NÃO é o erro."
  echo "     É o Xcode dizendo que ALGUM script falhou."
  echo ""
  echo "     ⭐ O erro real está no Report Navigator:"
  echo "        Xcode → ⌘9 → última build → etapa VERMELHA"
  echo "        → ícone de expandir transcrição (canto direito)"
  echo ""
  echo "     Procurar essa mensagem na internet devolve centenas"
  echo "     de causas diferentes, todas verdadeiras para alguém."
  echo ""
  achou=1
fi

if [ "$achou" -eq 0 ]; then
  echo "  Nenhum padrão conhecido."
  echo ""
  echo "  Siga o método (aula 10):"
  echo "    1. Report Navigator (⌘9) — o erro REAL está lá"
  echo "    2. Qual etapa? pod / compilação / assinatura / archive"
  echo "    3. O que mudou? (veja os commits acima)"
  echo "    4. Limpe: $0 1 → $0 2 → $0 3"
  echo "    5. ./ferramentas/conferir-assinatura-ios.sh"
  echo "    6. flutter create teste_isolado + só o plugin suspeito"
  echo ""
  echo "  Últimas linhas de erro:"
  grep -E "error:|Error:|fatal" "$LOG" | tail -10 | sed 's/^/    /'
fi

echo "Log completo: $LOG"
exit 1
```

> **Arquivo:** `docs/DEBUG-IOS.md` (novo — crie **no Windows**)

```markdown
# Diagnóstico iOS — Foco

## Antes de qualquer coisa

1. **Report Navigator (⌘9)** — o erro real está lá, não na tela.
   Expanda a etapa vermelha e clique no ícone de transcrição.
2. **O que mudou?** `git log --oneline -5`
3. **"Funcionava semana passada"?** Suspeite de vencimento:
   certificados e profiles valem 1 ano.

## Limpeza, na ordem

| Nível | Comando | Tempo |
|---|---|---|
| 1 | `flutter clean && flutter pub get && cd ios && pod install` | segundos |
| 2 | `rm -rf ~/Library/Developer/Xcode/DerivedData/*` | ~2 min |
| 3 | `pod deintegrate && rm -rf Pods Podfile.lock && pod install` | ~5 min |
| 4 | `pod cache clean --all && pod repo update` | ~15 min |

## Erros que EU já enfrentei

| Data | Sintoma | Causa | Correção | Tempo perdido |
|---|---|---|---|---|
| | | | | |

> Preencha conforme acontecer. Em três meses, o mesmo erro volta —
> e esta tabela vale mais que qualquer busca na internet.

## O que eu já tentei e NÃO funcionou

| Sintoma | Tentativa | Por que não era isso |
|---|---|---|
| | | |

## Ambiente que funciona

| Item | Versão |
|---|---|
| macOS | |
| Xcode | |
| CocoaPods | |
| Flutter | |
| Ruby | |

## Quando parar de tentar sozinho

- 30 minutos sem progresso
- Já limpei até o nível 3
- Já isolei num projeto novo
→ Rode `ferramentas/relatar-erro-ios.sh` e peça ajuda.
```

> **Arquivo:** `ferramentas/relatar-erro-ios.sh` (novo)

```bash
#!/usr/bin/env bash
# Gera um relato de erro que outra pessoa consiga responder.
#
# Um pedido de ajuda sem estas informações recebe, sempre,
# as mesmas três perguntas de volta — e você perde um dia.

set -uo pipefail
cd "$(dirname "$0")/.."
saida=relato-erro-ios.md

bloco() {
  { echo ""; echo "## $1"; echo ""; echo '```'; } >> "$saida"
  eval "$2" >> "$saida" 2>&1 || echo "(falhou)" >> "$saida"
  echo '```' >> "$saida"
}

cat > "$saida" <<'EOF'
# Relato de erro — build iOS

**Data:** (preencha)

## O que eu estava fazendo

<!-- Ex.: `flutter build ipa --release` pela primeira vez -->

## O erro REAL (do Report Navigator, não da tela)

<!-- ⭐ Xcode → ⌘9 → última build → etapa vermelha →
     expandir transcrição. Cole aqui. -->

## O que mudou desde a última vez que funcionou

<!-- pub add? update do Xcode? git pull? Mac novo?
     Certificado vencido? -->

## O que eu já tentei

- [ ] Nível 1: flutter clean + pub get + pod install
- [ ] Nível 2: apagar DerivedData
- [ ] Nível 3: pod deintegrate + reinstalar
- [ ] conferir-assinatura-ios.sh
- [ ] Projeto novo com o mesmo plugin
EOF

bloco "flutter doctor -v" "flutter doctor -v"
bloco "Versões" "sw_vers; xcodebuild -version; pod --version; ruby --version"
bloco "xcode-select" "xcode-select -p"
bloco "Certificados" "security find-identity -v -p codesigning"
bloco "Profiles" "ls -la ~/Library/MobileDevice/Provisioning\\ Profiles/ 2>/dev/null | head -20"
bloco "Podfile" "cat ios/Podfile"
bloco "Bundle ID e Deployment Target" \
  "grep -E 'PRODUCT_BUNDLE_IDENTIFIER|IPHONEOS_DEPLOYMENT_TARGET' ios/Runner.xcodeproj/project.pbxproj | sort -u"
bloco "Últimos commits" "git log --oneline -10"
bloco "Alterados" "git status --short"

echo "Relato em $saida"
echo "⚠️ Preencha as seções com <!-- --> antes de enviar."
echo "⚠️ Confira se não há Team ID, e-mail ou caminho pessoal que você não queira expor."
```

```bash
chmod +x ferramentas/diagnosticar-ios.sh ferramentas/relatar-erro-ios.sh
./ferramentas/diagnosticar-ios.sh 1
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| **`git log` antes do build** | Automatiza o passo 3 — o que mais resolve. |
| Lembrete de vencimento | É a **única** categoria de erro que aparece sem ninguém mexer em nada. |
| Níveis 1 a 3 de limpeza | Impõe a ordem: barato → caro. |
| Aviso sobre `Podfile.lock` | Apagá-lo descarta as versões travadas; confira o diff depois. |
| Tabela de regras em código | A tabela da aula, executável. |
| Cada regra com causa **e** correção | "Erro X" sem "faça Y" não ajuda. |
| Referência à aula em cada sugestão | Leva ao contexto, não só ao remendo. |
| **Tratamento especial do `PhaseScriptExecution`** | Não é erro: é o Xcode dizendo que **algum** script falhou. |
| Caminho detalhado até o Report Navigator | **O ícone de transcrição é o que quase ninguém encontra.** |
| Fallback com o método escrito | Quando nenhum padrão bate, o método continua valendo. |
| `DEBUG-IOS.md` com "o que NÃO funcionou" | Evita repetir a tentativa errada em três meses. |
| `relatar-erro-ios.sh` | Responde de antemão as perguntas que quem ajuda vai fazer. |
| Campo "o erro REAL" em destaque no relato | Quem cola a mensagem genérica não recebe ajuda útil. |
| Aviso sobre dados pessoais no relato | Team ID e caminhos vazam com facilidade. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Qualidade da mensagem | ✅ Diz o quê, sob log | ⚠️ Genérica na tela |
| Onde está o detalhe | `--stacktrace`, `--info` | **Report Navigator (⌘9)** |
| Gerenciador de dependências | Gradle | **CocoaPods** |
| Cache | `~/.gradle/caches` | `DerivedData` + cache dos pods |
| Erros de assinatura | Poucos e claros | ⚠️ **Muitos, e vencem sozinhos** |
| Diagnosticar no Windows | ✅ | ❌ |

> 💡 **A diferença que resume os dois módulos:** o Gradle **conta** o que deu errado, e o trabalho é
> achar a linha certa em dez páginas. O Xcode **esconde**, e o trabalho é saber onde procurar. Nos
> dois casos, o método é o mesmo — o que muda é o primeiro passo.

> 📌 **E os erros de assinatura são uma categoria que o Android não tem.** No Android, a chave vale
> 27 anos e não há lista de aparelhos. No iOS, certificados e profiles vencem em um ano, e um
> aparelho novo exige regerar o profile. **Uma parte dos erros deste módulo aparece sozinha, com o
> tempo** — e nenhum `git log` vai explicá-los.

---

## ⚠️ Erros comuns

### 1. Ler só a mensagem da tela

Ela é genérica.

**Correção:** Report Navigator (⌘9).

### 2. Buscar `PhaseScriptExecution failed` na internet

Centenas de causas diferentes.

**Correção:** ache o erro real primeiro.

### 3. Apagar `Podfile.lock` por reflexo

Descarta as versões travadas.

**Correção:** nível 3, conscientemente.

### 4. Começar pelo nível 4

Quinze minutos para um problema de cinco segundos.

**Correção:** na ordem.

### 5. Não perguntar "o que mudou?"

**Correção:** passo 3, sempre.

### 6. Esquecer que profiles vencem

"Funcionava semana passada."

**Correção:** rode o diagnóstico de assinatura.

### 7. Copiar solução da internet sem entender

Resolve hoje, quebra amanhã.

**Correção:** a tabela aponta a aula.

### 8. Abrir o `.xcodeproj`

`module not found`.

**Correção:** `.xcworkspace`.

### 9. Esquecer `pod install` após `pub get`

Mesma mensagem da anterior.

**Correção:** rode sempre.

### 10. Pedir ajuda com a mensagem genérica

Ninguém consegue responder.

**Correção:** `relatar-erro-ios.sh`.

### 11. Não anotar a solução

O mesmo erro volta em três meses.

**Correção:** `DEBUG-IOS.md`.

### 12. Insistir sozinho por horas

**Correção:** 30 minutos sem progresso = peça ajuda.

---

## 🛠️ Exercício guiado

> 🪟 **Os passos 1 a 4 rodam no Windows.** Os 5 a 10 são para o dia do Mac.

**Passo 1.** Leia a tabela inteira. Quantos erros você reconheceria pela mensagem?

**Passo 2.** Crie `docs/DEBUG-IOS.md` com a estrutura desta aula.

**Passo 3.** Guarde `diagnosticar-ios.sh` e `relatar-erro-ios.sh` no projeto.

**Passo 4.** Escreva, de memória, o caminho até o Report Navigator.

**Passo 5.** 🍎 Provoque o caso 1: `flutter pub add` de um plugin e compile **sem** `pod install`.

**Passo 6.** 🍎 Rode `diagnosticar-ios.sh`. Ele identificou?

**Passo 7.** 🍎 Abra o `.xcodeproj` e compile. A mensagem é a mesma do passo 5?

**Passo 8.** 🍎 Provoque um erro de script e ache o detalhe no Report Navigator. Quanto tempo levou?

**Passo 9.** 🍎 Rode `conferir-assinatura-ios.sh`. Quanto falta para seus profiles vencerem?

**Passo 10.** 🍎 Rode `relatar-erro-ios.sh` e leia o resultado. Falta alguma informação?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/15-build-ios.md](../../exercicios/15-build-ios.md)

Faça todos os de **Diagnóstico** — esta aula existe para eles.

---

## 🏆 Desafio opcional

Monte o **playbook iOS** do seu projeto — um `DEBUG-IOS.md` vivo, que cresce com a experiência.

Requisitos:

- A tabela sintoma → causa → correção, com **os erros que você realmente enfrentou**.
- Para cada um: a mensagem exata (a do Report Navigator, não a da tela), a causa, a correção e
  **quanto tempo levou**.
- Uma seção de **vencimentos**: quando cada certificado e profile expira, com lembrete configurado.
- Uma seção "ambiente que funciona": macOS, Xcode, CocoaPods, Flutter e Ruby, com as versões exatas.
- Uma seção "o que tentei e não funcionou".
- Um procedimento de escalonamento.

Depois responda: comparando com o `DEBUG-ANDROID.md` do módulo 14, qual plataforma consumiu mais
tempo de diagnóstico — e **por quê**? Foi a complexidade real dos problemas, ou a qualidade das
mensagens de erro?

---

## 📌 Resumo

- **Método de 6 passos**: erro real → etapa → **o que mudou?** → limpar → assinatura → isolar.
- **O erro real está no Report Navigator (⌘9)**, não na mensagem da tela.
- O **ícone de expandir transcrição**, no canto direito da etapa, é o que revela o log completo.
- **`Command PhaseScriptExecution failed` não é um erro** — é o Xcode dizendo que algum script
  falhou.
- **Limpe na ordem**: `pod install` → DerivedData → `pod deintegrate` → cache global.
- **`pod install` depois de todo `flutter pub get`.**
- **`module not found`** tem duas causas idênticas na mensagem: falta de `pod install`, ou ter
  aberto o `.xcodeproj`.
- **"Funcionava semana passada" = vencimento.** Certificados e profiles valem **1 ano**.
- Registrar um UDID **não atualiza** os profiles existentes — regere.
- Os erros `ITMS-*` do upload têm correções diretas: consulte a tabela.
- **Teste externo reprovado** costuma ser falta de conta de teste.
- Peça ajuda com **relato completo**, incluindo o erro do Report Navigator.
- **Anote a solução**: o mesmo erro volta em três meses.
- 🤖 O Gradle **conta** o que houve; 🍎 o Xcode **esconde**. O método é o mesmo; muda o primeiro
  passo.

---

## ☑️ Checklist de domínio

- [ ] Sei achar o erro real no Report Navigator.
- [ ] Reconheço que `PhaseScriptExecution` é genérico.
- [ ] Sigo o método de 6 passos.
- [ ] Pergunto "o que mudou?" antes de investigar.
- [ ] Limpo na ordem, do barato para o caro.
- [ ] Rodo `pod install` depois de todo `pub get`.
- [ ] Sei as duas causas de `module not found`.
- [ ] Suspeito de vencimento quando "funcionava semana passada".
- [ ] Sei traduzir os erros `ITMS-*`.
- [ ] Isolo num projeto novo quando o erro não cede.
- [ ] Sei montar um relato de erro completo.
- [ ] Anoto as soluções no `DEBUG-IOS.md`.

---

## 📚 Referências oficiais

- [Build and release an iOS app — docs.flutter.dev](https://docs.flutter.dev/deployment/ios)
- [CocoaPods — Troubleshooting](https://guides.cocoapods.org/using/troubleshooting.html)
- [Xcode — Build reports](https://developer.apple.com/documentation/xcode/analyzing-your-app-s-build-process)
- [Code signing — developer.apple.com](https://developer.apple.com/documentation/xcode/signing-your-app)
- [App Store Connect — Resolving errors](https://developer.apple.com/help/app-store-connect/reference/app-store-connect-error-messages)
- [Flutter — Common errors](https://docs.flutter.dev/testing/common-errors)
- [Technical Q&A — Apple Developer](https://developer.apple.com/library/archive/qa/)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próximo módulo |
|---|---|---|
| [Aula 9 — Exportando o IPA e TestFlight](09-exportando-ipa-e-testflight.md) | [README](README.md) | [Módulo 16 — Publicação e próximos passos](../16-publicacao-e-proximos-passos/README.md) |
