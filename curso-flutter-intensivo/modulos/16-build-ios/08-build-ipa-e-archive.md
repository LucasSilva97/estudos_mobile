# Aula 8 — Build: IPA e archive

> **Módulo:** 16 - Build e Distribuição iOS · **Tempo estimado:** 45 min · **Nível:** Avançado

## 🎯 Objetivos de aprendizagem

- Entender a diferença entre **`.app`**, **`.xcarchive`** e **`.ipa`**.
- Gerar um IPA com **`flutter build ipa`**, com ofuscação e símbolos arquivados.
- Usar o **Organizer** do Xcode e o **Validate App** antes de enviar.
- Escrever um **`ExportOptions.plist`** e conhecer os métodos de exportação.
- Guardar os **dSYM** — e saber por que eles são tão insubstituíveis quanto os símbolos do Dart.
- Diagnosticar as falhas do archive: assinatura, bitcode, arquitetura, `pod install`.

## ✅ Pré-requisitos

- [Aula 7 — Certificados e provisioning](07-certificados-e-provisioning.md) — assinatura
  funcionando.
- [Aula 5 — Ícone, splash, versão e Info.plist](05-icone-splash-versao-infoplist.md) — versão e
  permissões prontas.
- [Módulo 15, aula 8 — Gerando APK e AAB](../15-build-android/08-gerando-apk-e-aab.md) — o
  equivalente Android.
- [Módulo 13, aula 7 — Ofuscação](../13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) —
  `--obfuscate` e `--split-debug-info`.

---

## 🍎🪟 Antes de começar: onde você está

> # 🍎 SÓ NO MAC. Você está no Windows 11.
>
> **`flutter build ipa` exige o Xcode.** O comando chama `xcodebuild`, que é parte do Xcode e só
> existe no macOS. Não há alternativa — nem máquina virtual legalizada, nem porte, nem truque.
>
> **O que você faz agora, no Windows:**
> 1. **Entender o fluxo**, para não aprendê-lo sob pressão no dia do Mac.
> 2. Escrever o `ios/ExportOptions.plist` — é um arquivo de **texto**, e vai versionado.
> 3. Guardar o roteiro `ferramentas/build-ios.sh` no projeto.
> 4. Preparar a pasta `simbolos/` e a regra de `.gitignore`.
>
> **O que fica para o Mac:** o build em si.
>
> 💡 **Alternativa real:** um **CI com runner macOS** (GitHub Actions `macos-latest`) executa
> `flutter build ipa` sem você ter um Mac. É como muitos times sem Mac publicam no iOS — e é o
> assunto do Módulo 17, aula 4. O roteiro desta aula é exatamente o que vai dentro desse CI.

---

## 📖 Conceito

### Os três formatos

```text
.app         o app compilado, uma PASTA
   │         roda no simulador; não se distribui
   ▼
.xcarchive   o .app + símbolos + metadados, ASSINADO
   │         fica no Organizer; é o que você guarda
   ▼
.ipa         o pacote final, um ZIP
             é o que vai para o TestFlight e a App Store
```

| | `.app` | `.xcarchive` | `.ipa` |
|---|---|---|---|
| O que é | Pasta | Pasta | ZIP |
| Assinado | Para debug | ✅ | ✅ |
| Contém dSYM | ❌ | ✅ | ❌ |
| Instala em aparelho | ⚠️ Via Xcode | ❌ | ✅ |
| Vai para o App Store Connect | ❌ | Via Organizer | ✅ |
| Você guarda | ❌ | ✅ **Sim** | ⚠️ Opcional |

> 📌 **O `.xcarchive` é o que você guarda**, não o `.ipa`. Ele contém os **dSYM** — os símbolos do
> código nativo — e permite reexportar o IPA com outro método sem recompilar. O Xcode arquiva
> automaticamente em `~/Library/Developer/Xcode/Archives/`, por data.

### O comando

```bash
# Gera o archive E exporta o IPA, num passo.
flutter build ipa --release

# Completo — o que você vai usar de verdade:
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=simbolos/1.2.0+15 \
  --dart-define-from-file=config/prod.json \
  --export-options-plist=ios/ExportOptions.plist

# Só o archive, para exportar pelo Organizer depois:
flutter build ipa --release --no-codesign
```

E onde cada coisa aparece:

| Artefato | Caminho |
|---|---|
| Archive | `build/ios/archive/Runner.xcarchive` |
| **IPA** | `build/ios/ipa/foco.ipa` |
| dSYM | dentro do `.xcarchive`, em `dSYMs/` |
| Símbolos do Dart | onde o `--split-debug-info` apontar |

> ⚠️ **Sem `--export-options-plist`, o Flutter gera o archive e para**, dizendo para você exportar
> pelo Organizer. Não é erro — é o comportamento padrão quando ele não sabe qual método de
> exportação você quer.

### `ExportOptions.plist`

É o arquivo que responde "exportar **como**?".

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>

    <key>teamID</key>
    <string>ABCDE12345</string>

    <key>uploadSymbols</key>
    <true/>

    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

| `method` | Para quê |
|---|---|
| **`app-store-connect`** | TestFlight e App Store |
| `ad-hoc` | Aparelhos registrados por UDID |
| `development` | Teste local |
| `enterprise` | Conta Enterprise |

> ⚠️ **O valor mudou.** Nas versões recentes do Xcode, `app-store` virou **`app-store-connect`**.
> Material antigo ainda usa o nome velho, e o erro que aparece é um `exportArchive` genérico que não
> menciona a chave.

### Validate App

Antes de enviar, o Xcode consegue verificar o IPA contra as regras da App Store:

```text
Xcode → Window → Organizer → Archives → seu archive
  → Validate App
```

| Validate App pega | Antes de |
|---|---|
| Ícone com transparência (`ITMS-90717`) | O upload |
| `CFBundleVersion` repetido | O upload |
| Permissão sem texto | A revisão |
| Assinatura inválida | O upload |
| Arquitetura faltando | O upload |

> 📌 **O Validate App é gratuito e leva dois minutos.** Ele roda as mesmas verificações do upload,
> sem enviar nada — e evita descobrir um `ITMS-90717` depois de vinte minutos de transferência. Faça
> **sempre**, antes de cada envio.

### Os dSYM

São os símbolos do código **nativo** — o equivalente iOS do `mapping.txt` do R8 (módulo 15, aula 8).

```text
Runner.xcarchive/
├── Products/Applications/Runner.app
├── dSYMs/
│   ├── Runner.app.dSYM          ← o app
│   └── *.framework.dSYM         ← cada plugin
└── Info.plist
```

> ⚠️ **Você precisa guardar DOIS conjuntos de símbolos no iOS:**
>
> | Símbolos | De quê | Onde |
> |---|---|---|
> | `--split-debug-info` | Código **Dart** | Onde você apontar |
> | **dSYM** | Código **nativo** (Swift/ObjC, plugins) | Dentro do `.xcarchive` |
>
> Guardar só um deixa metade dos crashes ilegível. Como no Android, **perder os símbolos de uma
> versão publicada é irreversível**: recompilar produz um binário diferente.

```bash
# Enviar os dSYM ao Crashlytics
find build/ios/archive/Runner.xcarchive/dSYMs -name "*.dSYM" -exec \
  ./ios/Pods/FirebaseCrashlytics/upload-symbols -gsp ios/Runner/GoogleService-Info.plist -p ios {} \;
```

### App Thinning

O iOS faz, automaticamente, o que o AAB faz no Android:

| | 🤖 AAB | 🍎 App Thinning |
|---|---|---|
| Você configura | ✅ Sim (escolhe o formato) | ❌ **Nada** |
| Divide por arquitetura | ✅ | ✅ |
| Divide por densidade | ✅ | ✅ |
| Divide por idioma | ✅ | ⚠️ Parcial |

> 💡 **Não há nada a fazer para ativar o App Thinning** — a App Store entrega a cada aparelho só o
> que ele usa. O `.ipa` que você envia é maior que o download do usuário, exatamente como o `.aab`.
> Comparar o tamanho do arquivo com o do APK leva à mesma conclusão errada dos dois lados.

### Bitcode: não existe mais

```text
warning: Building with bitcode is deprecated.
```

O bitcode foi **removido** no Xcode 14. Material antigo manda ligar ou desligar; hoje, a resposta é
que a opção não existe mais.

> ⚠️ **Se você encontrar um tutorial mandando mexer em `ENABLE_BITCODE`, o tutorial é antigo.**
> Vale o mesmo alerta do `--cache-sksl` no módulo 13: receita antiga para problema que deixou de
> existir.

---

## 💡 Analogia

Pense em **imprimir e encadernar um livro**.

- **O `.app`** são as páginas soltas, saindo da impressora. Dá para ler na sua mesa. Não dá para
  mandar a ninguém.
- **O `.xcarchive`** é o **exemplar do arquivo da editora**: o livro encadernado **mais** as
  chapas de impressão, as fontes, as provas de cor. Ninguém compra esse exemplar — ele fica no
  arquivo porque é dele que se produz qualquer nova tiragem, em qualquer formato.
- **O `.ipa`** é o exemplar embalado para a livraria.
- **Os dSYM são as chapas.** Quando um leitor reclamar de uma página borrada na tiragem do ano
  passado, é a chapa daquela tiragem que diz o que houve — e **reimprimir não produz a mesma
  chapa**.
- **E no iOS há dois conjuntos de chapas**: as do texto (Dart) e as das ilustrações (nativo).
  Guardar só um conjunto explica metade dos defeitos.
- **O Validate App** é o revisor que confere o exemplar **antes** de o caminhão sair: a capa está
  torta? A numeração repete? Dois minutos de conferência contra um dia de frete perdido.
- **O App Thinning** é a gráfica imprimir automaticamente em formato de bolso para quem tem estante
  pequena, sem você pedir nada.
- **E o bitcode** é uma exigência de formatação que a editora abandonou há anos — e que ainda
  aparece em manuais velhos, fazendo gente perder tarde arrumando margem que ninguém confere.

---

## 🧪 Exemplo mínimo

> 🍎 **Tudo nesta seção roda no Mac.**

**Passo 1 — conferir a assinatura:**

```bash
./ferramentas/conferir-assinatura-ios.sh    # aula 7
```

**Passo 2 — limpar:**

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

> ⚠️ **`pod install` depois de todo `flutter pub get`.** Um plugin novo traz código nativo que só
> entra no projeto por ali — e esquecer disso produz um erro de "module not found" que parece de
> outra natureza.

**Passo 3 — o IPA:**

```bash
flutter build ipa --release \
  --obfuscate \
  --split-debug-info=simbolos/1.0.0+1
```

```text
Building com.estudos.foco for device (ios-release)...
Running pod install...                                        3,2s
Running Xcode build...
 └─Compiling, linking and signing...                         42,1s
Xcode archive done.                                          58,3s
Built build/ios/archive/Runner.xcarchive

Building App Store IPA...                                    18,7s
Built IPA to build/ios/ipa/foco.ipa (23.4MB)
```

**Passo 4 — validar antes de enviar:**

```text
Xcode → Window → Organizer → Archives → Validate App
```

**Passo 5 — guardar os dSYM:**

```bash
cp -R build/ios/archive/Runner.xcarchive/dSYMs simbolos/1.0.0+1/
ls simbolos/1.0.0+1/
```

```text
app.ios-arm64.symbols     ← Dart
dSYMs/                    ← nativo
```

> 📌 **Os dois conjuntos, na mesma pasta, nomeada pela versão.** É a organização que torna possível
> decifrar um crash de seis meses atrás.

---

## 📱 Aplicando no Flutter

O roteiro completo de build — o que roda no Mac, e o mesmo que vai dentro do CI.

---

## 💻 Código completo

> **Arquivo:** `ios/ExportOptions.plist` (novo — escreva **no Windows**, use no Mac)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ⚠️ Nas versões recentes do Xcode, "app-store" virou
         "app-store-connect". Material antigo usa o nome velho,
         e o erro resultante é um exportArchive genérico que
         não menciona esta chave. -->
    <key>method</key>
    <string>app-store-connect</string>

    <!-- Seu Team ID: developer.apple.com → Membership.
         Anotado em docs/conta-apple.md (aula 6). -->
    <key>teamID</key>
    <string>SEU_TEAM_ID</string>

    <!-- Envia os dSYM junto com o build.
         Sem isto, os crashes nativos chegam ilegíveis no
         App Store Connect. -->
    <key>uploadSymbols</key>
    <true/>

    <!-- automatic: o Xcode escolhe o profile.
         manual: você lista em provisioningProfiles (abaixo). -->
    <key>signingStyle</key>
    <string>automatic</string>

    <!-- Com signingStyle manual, descomente e preencha:
    <key>provisioningProfiles</key>
    <dict>
        <key>br.com.estudos.foco</key>
        <string>Nome exato do seu profile</string>
    </dict>
    -->

    <!-- Deixa a App Store gerar os pacotes por aparelho
         (App Thinning). Não há por que desligar. -->
    <key>thinning</key>
    <string>&lt;none&gt;</string>

    <!-- Envia estatísticas de build ao App Store Connect. -->
    <key>uploadBitcode</key>
    <false/>

    <!-- Confirma que o app não usa criptografia não isenta.
         Igual à chave do Info.plist (aula 5). -->
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
```

> **Arquivo:** `ferramentas/build-ios.sh` (novo — roda **no Mac**, e no CI)

```bash
#!/usr/bin/env bash
# Build iOS completo: do código ao IPA validável.
#
# 🍎 Roda no Mac — e é exatamente o que vai dentro de um CI
#    com runner macOS (Módulo 17, aula 4).
#
# Faz, na ordem, tudo o que dá para esquecer: pod install,
# portões de qualidade, ofuscação, e o arquivamento dos DOIS
# conjuntos de símbolos.

set -euo pipefail
cd "$(dirname "$0")/.."

RAPIDO=${RAPIDO:-0}   # RAPIDO=1 pula analyze e test

echo "═══ BUILD iOS ═══"

# ══════════════════════════════════════════════════════════════
echo ""
echo "[1] Versão"

versao=$(grep '^version:' pubspec.yaml | sed 's/version:[[:space:]]*//')
if [[ ! "$versao" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
  echo "❌ Versão malformada: '$versao'. Use x.y.z+N."
  exit 1
fi
nome="${versao%%+*}"
numero="${versao##*+}"
echo "  $nome (build $numero)"

# ⚠️ O CFBundleVersion precisa CRESCER a cada envio ao App Store
# Connect. Repetido: ERROR ITMS-4238, depois do upload inteiro.
simbolos="simbolos/$versao"
if [ -d "$simbolos" ]; then
  echo ""
  echo "  ⚠️  Já existe $simbolos"
  echo "     Esta versão já foi compilada. Se ela já foi ENVIADA,"
  echo "     o App Store Connect vai recusar (ITMS-4238)."
  echo "     Suba o +N no pubspec.yaml."
  read -r -p "     Continuar assim mesmo? (s/N) " r
  [ "$r" = "s" ] || exit 1
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[2] Assinatura"
if [ -x ferramentas/conferir-assinatura-ios.sh ]; then
  ./ferramentas/conferir-assinatura-ios.sh || {
    echo "❌ Problemas de assinatura. Aula 7."
    exit 1
  }
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[3] Limpando"
flutter clean
flutter pub get

# ⚠️ pod install depois de TODO pub get: plugin novo traz código
# nativo que só entra no projeto por aqui.
(cd ios && pod install)

# ══════════════════════════════════════════════════════════════
if [ "$RAPIDO" != "1" ]; then
  echo ""
  echo "[4] Portões de qualidade"
  # Antes do build: descobrir um teste quebrado DEPOIS de enviar
  # significa esperar a revisão da Apple para corrigir.
  flutter analyze
  flutter test
else
  echo ""
  echo "[4] ⚠️  PULANDO analyze e test (RAPIDO=1)"
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[5] Compilando"

mkdir -p "$simbolos"

args=(--release --obfuscate "--split-debug-info=$simbolos")

if [ -f config/prod.json ]; then
  args+=("--dart-define-from-file=config/prod.json")
  echo "  configuração: config/prod.json"
fi

# Sem --export-options-plist, o Flutter gera o archive e PARA,
# pedindo que você exporte pelo Organizer.
if [ -f ios/ExportOptions.plist ]; then
  if grep -q 'SEU_TEAM_ID' ios/ExportOptions.plist; then
    echo "  ⚠️  ExportOptions.plist ainda tem SEU_TEAM_ID."
    echo "     Preencha o Team ID (docs/conta-apple.md)."
    exit 1
  fi
  args+=(--export-options-plist=ios/ExportOptions.plist)
  echo "  exportando com ios/ExportOptions.plist"
else
  echo "  ⚠️  Sem ExportOptions.plist: só o archive será gerado."
fi

flutter build ipa "${args[@]}"

# ══════════════════════════════════════════════════════════════
echo ""
echo "[6] Símbolos"

archive=build/ios/archive/Runner.xcarchive

# ── Símbolos do Dart ──
n_dart=$(find "$simbolos" -maxdepth 1 -name '*.symbols' | wc -l | tr -d ' ')
if [ "$n_dart" -eq 0 ]; then
  echo "  ❌ Nenhum símbolo do Dart gerado!"
  echo "     Os crashes desta versão seriam ilegíveis PARA SEMPRE."
  exit 1
fi
echo "  ✅ Dart: $n_dart arquivo(s)"

# ── dSYM (código nativo) ──
# ⭐ O iOS precisa dos DOIS conjuntos. Guardar só um deixa
# metade dos crashes ilegível.
if [ -d "$archive/dSYMs" ]; then
  cp -R "$archive/dSYMs" "$simbolos/"
  n_dsym=$(find "$simbolos/dSYMs" -name '*.dSYM' -maxdepth 1 | wc -l | tr -d ' ')
  echo "  ✅ dSYM: $n_dsym pacote(s)"
else
  echo "  ⚠️  dSYMs não encontrados no archive."
fi

# Guarda o archive inteiro: dele dá para reexportar o IPA com
# outro método, sem recompilar.
if [ -d "$archive" ]; then
  tamanho=$(du -sh "$archive" | cut -f1)
  echo "  archive: $archive ($tamanho)"
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "[7] IPA"

ipa=$(find build/ios/ipa -name '*.ipa' 2>/dev/null | head -1 || true)

if [ -n "$ipa" ]; then
  mb=$(du -m "$ipa" | cut -f1)
  echo "  $ipa (${mb} MB)"
  if [ "$mb" -gt 50 ]; then
    echo "  ⚠️  Acima de 50 MB. Revise assets/ (Módulo 13, aula 2)."
  fi
  echo ""
  echo "  💡 O usuário baixa MENOS que isto: o App Thinning entrega"
  echo "     só a arquitetura e a densidade do aparelho dele."
else
  echo "  Nenhum IPA (só o archive). Exporte pelo Organizer."
fi

# ══════════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════"
echo " $versao pronto"
echo "════════════════════════════════════════"
echo ""
echo "Antes de enviar:"
echo "  1. Xcode → Window → Organizer → Validate App"
echo "     (2 minutos, e pega ITMS-90717 e ITMS-4238"
echo "      ANTES do upload)"
echo "  2. Copie $simbolos para fora desta máquina"
echo "     — os DOIS conjuntos, Dart e dSYM"
echo "  3. Aula 9: TestFlight"
```

E o `.gitignore`:

```gitignore
# ── Build iOS ─────────────────────────────────────────────────
build/
ios/Pods/
ios/.symlinks/
ios/Flutter/Generated.xcconfig
ios/Flutter/flutter_export_environment.sh

# ⚠️ Os símbolos NÃO vão para o Git (são grandes), mas PRECISAM
# ser guardados em outro lugar. Sem eles, nenhum crash de
# produção é legível — e não há como regerá-los.
simbolos/
```

```bash
chmod +x ferramentas/build-ios.sh
./ferramentas/build-ios.sh
```

---

## 🔍 Explicando o código

| Trecho | O que faz e por quê |
|---|---|
| `method: app-store-connect` | O valor mudou; o nome antigo gera um erro genérico de `exportArchive`. |
| `uploadSymbols: true` | Sem isso, os crashes nativos chegam ilegíveis no App Store Connect. |
| Recusar `SEU_TEAM_ID` não preenchido | Falha em um segundo, em vez de no fim do build. |
| **Avisar se a pasta de símbolos já existe** | Indica versão já compilada — e possivelmente já enviada (`ITMS-4238`). |
| Rodar o diagnóstico de assinatura primeiro | Quase todo erro de build iOS é de assinatura. |
| `pod install` depois de `pub get` | Plugin novo traz código nativo que só entra por ali. |
| `analyze` + `test` antes | No iOS, corrigir depois do envio significa esperar a revisão. |
| **Falhar se não houver símbolos do Dart** | Crashes ilegíveis para sempre, sem como regerar. |
| **Copiar os dSYM para a mesma pasta** | O iOS precisa dos **dois** conjuntos; um só cobre metade. |
| Guardar o `.xcarchive` | Dele se reexporta o IPA com outro método, sem recompilar. |
| Nota sobre App Thinning no tamanho | Evita a conclusão errada de comparar IPA com APK. |
| Lembrete do **Validate App** em destaque | Dois minutos que evitam vinte de upload perdido. |
| `simbolos/` no `.gitignore` **com aviso** | Fora do Git, mas guardados — a mesma regra do módulo 13. |

---

## 🤖🍎 Android × iOS

| | 🤖 Android | 🍎 iOS |
|---|---|---|
| Para a loja | `.aab` | `.ipa` |
| Comando | `flutter build appbundle` | `flutter build ipa` |
| Divisão por aparelho | AAB (você escolhe) | **App Thinning** (automático) |
| Símbolos Dart | `--split-debug-info` | `--split-debug-info` |
| Símbolos nativos | `mapping.txt` (R8) | **dSYM** |
| Validar antes de enviar | ⚠️ Não há equivalente | ✅ **Validate App** |
| Arquivo para guardar | `mapping.txt` + símbolos | `.xcarchive` (contém tudo) |
| Gerar no Windows | ✅ | ❌ |

> 💡 **O `Validate App` é uma vantagem clara do iOS.** No Android, você envia o AAB e descobre os
> problemas depois do upload; no iOS, dá para rodar as mesmas verificações localmente, de graça,
> antes de transferir um byte. Use sempre — é o tipo de ferramenta que só parece supérflua até a
> primeira vez em que ela pega um `ITMS-90717`.

---

## ⚠️ Erros comuns

### 1. Esquecer `pod install`

```text
module 'shared_preferences' not found
```

**Correção:** `cd ios && pod install` após todo `pub get`.

### 2. `method: app-store` (nome antigo)

Erro genérico de `exportArchive`.

**Correção:** `app-store-connect`.

### 3. Team ID não preenchido

**Correção:** `docs/conta-apple.md`.

### 4. Ofuscar sem `--split-debug-info`

Crashes ilegíveis.

**Correção:** os dois juntos.

### 5. Guardar só os símbolos do Dart

Metade dos crashes ilegível.

**Correção:** guarde também os dSYM.

### 6. Não rodar Validate App

Descobre o problema depois do upload.

**Correção:** dois minutos no Organizer.

### 7. `CFBundleVersion` repetido

```text
ERROR ITMS-4238
```

**Correção:** suba o `+N`.

### 8. Comparar o tamanho do IPA com o do APK

Conclusão errada.

**Correção:** o App Thinning reduz o download.

### 9. Mexer em `ENABLE_BITCODE`

Removido no Xcode 14.

**Correção:** ignore tutoriais antigos.

### 10. Não guardar o `.xcarchive`

Sem ele, reexportar exige recompilar.

**Correção:** o Xcode arquiva sozinho; não apague.

### 11. Assinatura quebrada descoberta no build

**Correção:** rode o diagnóstico antes (aula 7).

### 12. Não testar o IPA antes de enviar

**Correção:** instale via TestFlight interno (aula 9).

---

## 🛠️ Exercício guiado

> 🪟 **Os passos 1 a 3 rodam no Windows.** Os 4 a 10 são para o Mac.

**Passo 1.** Crie `ios/ExportOptions.plist` com o Team ID.

**Passo 2.** Crie `ferramentas/build-ios.sh` e leia-o inteiro. Entende cada etapa?

**Passo 3.** Acrescente `simbolos/` ao `.gitignore`, com o comentário de aviso.

**Passo 4.** 🍎 Rode `flutter build ipa --release`. Quanto tempo?

**Passo 5.** 🍎 Ache o `.xcarchive` e o `.ipa`. Quais os tamanhos?

**Passo 6.** 🍎 Abra o Organizer. O archive está lá?

**Passo 7.** 🍎 Rode **Validate App**. Passou? Se não, qual erro?

**Passo 8.** 🍎 Liste os dSYM dentro do archive. Quantos?

**Passo 9.** 🍎 Rode `build-ios.sh` e confirme que os dois conjuntos de símbolos foram guardados.

**Passo 10.** 🍎 Rode de novo **sem** subir o `+N`. O script avisa?

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/16-build-ios.md](../../exercicios/16-build-ios.md)

Faça os de **Aplicação** (o roteiro de build) e o de **Diagnóstico** (falhas de archive).

---

## 🏆 Desafio opcional

Configure um **GitHub Actions com runner macOS** que gera o IPA sem você ter um Mac.

Requisitos:

- Dispara ao criar uma tag `v*`.
- Restaura o certificado `.p12` e o profile a partir de **secrets** em base64.
- Cria um keychain temporário, importa o certificado e o destrói ao fim.
- Roda `analyze`, `test` e `flutter build ipa` com ofuscação.
- **Arquiva os dois conjuntos de símbolos** como artefato, com retenção longa.
- Publica o IPA como artefato (ou envia ao TestFlight com a App Store Connect API).

Depois responda: quanto custa esse job em minutos de CI, comparado com um Mac mini usado em dois
anos? E qual das duas opções você escolheria — considerando não só o custo, mas o que você **perde**
sem um Mac à mão? (Dica: pense em depurar um problema que só acontece no iOS.)

---

## 📌 Resumo

- **`.app`** roda no simulador; **`.xcarchive`** é o que você **guarda**; **`.ipa`** é o que você
  envia.
- `flutter build ipa --release` gera o archive **e** o IPA, se houver `ExportOptions.plist`.
- Sem o `ExportOptions.plist`, o Flutter gera só o archive e pede que você exporte pelo Organizer.
- **`method: app-store-connect`** — o nome antigo (`app-store`) gera erro genérico.
- **Rode `pod install` depois de todo `pub get`.**
- **Validate App** no Organizer pega `ITMS-90717` e `ITMS-4238` **antes** do upload, de graça.
- **O iOS precisa de DOIS conjuntos de símbolos**: `--split-debug-info` (Dart) e **dSYM** (nativo).
- Guardar só um deixa **metade dos crashes ilegível**; perder qualquer um é irreversível.
- Guarde o `.xcarchive`: dele se reexporta o IPA sem recompilar.
- **App Thinning é automático** — o usuário baixa menos que o tamanho do IPA.
- **Bitcode não existe mais** desde o Xcode 14; ignore tutoriais que o mencionam.
- `CFBundleVersion` precisa **crescer** a cada envio.
- 🪟 O `ExportOptions.plist` e o roteiro se escrevem no Windows; o build exige Mac ou **CI com
  runner macOS**.

---

## ☑️ Checklist de domínio

- [ ] Distingo `.app`, `.xcarchive` e `.ipa`.
- [ ] Escrevi o `ExportOptions.plist` com o método certo.
- [ ] Sei que `pod install` vem depois de `pub get`.
- [ ] Gero o IPA com ofuscação e símbolos.
- [ ] Guardo os **dois** conjuntos de símbolos, por versão.
- [ ] Guardo o `.xcarchive`.
- [ ] Rodo Validate App antes de enviar.
- [ ] Incremento o `CFBundleVersion` a cada envio.
- [ ] Sei que o App Thinning é automático.
- [ ] Sei que bitcode não existe mais.
- [ ] Tenho um roteiro que faz tudo na ordem.

---

## 📚 Referências oficiais

- [Build and release an iOS app — docs.flutter.dev](https://docs.flutter.dev/deployment/ios)
- [Distributing your app — developer.apple.com](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [Validating an app — developer.apple.com](https://developer.apple.com/documentation/xcode/validating-your-app)
- [App thinning — developer.apple.com](https://developer.apple.com/documentation/xcode/reducing-your-app-s-size)
- [Symbolicating crash reports — developer.apple.com](https://developer.apple.com/documentation/xcode/adding-identifiable-symbol-names-to-a-crash-report)
- [Obfuscating Dart code — docs.flutter.dev](https://docs.flutter.dev/deployment/obfuscate)
- [xcodebuild — Export options](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — Certificados e provisioning](07-certificados-e-provisioning.md) | [README](README.md) | [Aula 9 — Exportando o IPA e TestFlight](09-exportando-ipa-e-testflight.md) |
