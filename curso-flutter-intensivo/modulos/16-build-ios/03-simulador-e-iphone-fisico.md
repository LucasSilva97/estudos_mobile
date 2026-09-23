# Aula 3 — Simulador e iPhone físico

> **Módulo:** 16 - Build e Distribuição iOS · **Tempo estimado:** 35 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- Abrir o **Simulator** do Xcode, escolher o modelo de iPhone e controlar quais simuladores
  existem na máquina.
- Usar `open -a Simulator`, `flutter devices` e `flutter run -d <id>` para rodar o app Foco.
- Listar, com precisão, as **limitações reais do Simulador** — câmera, notificações push,
  desempenho, sensores — e decidir o que **precisa** ser testado em aparelho de verdade.
- Preparar um **iPhone físico** para desenvolvimento: cabo, "Confiar neste computador" e o
  **Modo de Desenvolvedor**, obrigatório desde o **iOS 16**.
- Resolver a tela "Desenvolvedor não confiável" pelo caminho
  **Ajustes → Geral → VPN e Gerenciamento de Dispositivo**.

## ✅ Pré-requisitos

- [Aula 2 — Xcode e CocoaPods](02-xcode-e-cocoapods.md) concluída, com
  `flutter doctor` mostrando `[✓] Xcode - develop for iOS and macOS`.
- Projeto **Foco** rodando no Android ou no Windows desktop. Se ele não roda em nenhuma
  plataforma, o problema é o código, não o iOS — volte ao
  [Módulo 12](../12-testes-e-debug/README.md).
- Para o iPhone físico: cabo USB compatível e um **Apple ID** (a Aula 6 explica gratuito × pago).

---

## 🍎🪟 Antes de começar: onde você está

> # 🍎 SÓ NO MAC. Você está no Windows 11.
>
> **O Simulador do iOS não existe para Windows.** Ele faz parte do Xcode e usa frameworks do
> macOS. Não há emulador de iPhone para Windows — nem oficial, nem confiável.
>
> **Um iPhone ligado por cabo ao seu PC Windows não vira dispositivo de desenvolvimento.** O
> Windows enxerga o aparelho como uma câmera (para copiar fotos) e nada mais. `flutter devices`
> no Windows nunca vai listar um iPhone.
>
> **O que você faz agora, no Windows:**
> 1. Ler a aula e entender o fluxo, porque no dia do Mac você vai querer velocidade.
> 2. Guardar o roteiro `ferramentas/rodar-no-ios.sh` no projeto.
> 3. Montar a sua **lista de testes que exigem aparelho físico** (seção "Exercício guiado") — essa
>    lista é trabalho intelectual, não depende de Mac, e é o que evita descobrir um problema de
>    câmera no último dia.
>
> **O que fica para quando você tiver um Mac:** tudo que envolva executar o app em iOS.

---

## 📖 Conceito

### O que é o Simulador

**Simulador** (*Simulator*) é um programa do macOS que roda uma versão do iOS compilada para a
arquitetura do próprio Mac, dentro de uma janela. Ele **não** é um emulador no sentido estrito:

| | Emulador (Android) | Simulador (iOS) |
|---|---|---|
| O que faz | Emula o **hardware** inteiro: processador ARM, memória, sensores | Roda o iOS compilado para a arquitetura do **Mac** |
| Binário do app | Compilado para ARM, como no aparelho real | Compilado para a arquitetura do Mac (x86_64 ou arm64) |
| Velocidade | Mais lento; depende de aceleração por hardware | Rápido, porque é código nativo do Mac |
| Fidelidade de desempenho | Baixa, mas o gargalo é parecido | **Enganosa**: costuma ser mais rápido que um iPhone real |

A consequência prática é a mais importante desta aula: **o Simulador é mais rápido do que o seu
app será em um iPhone**. Um app que parece fluido no Simulador pode engasgar num iPhone antigo.
Nunca conclua "está rápido" a partir do Simulador.

### O que o Simulador NÃO faz

| Recurso | No Simulador | Por quê |
|---|---|---|
| **Câmera** | ❌ Não há câmera real. O seletor de imagem abre, mas não há captura | O Mac não expõe a webcam como câmera do iOS |
| **Notificações push remotas** | ❌ Não recebe push de servidor da forma padrão | Push depende de registro com os servidores da Apple, ligado a hardware |
| **Sensores físicos** | ❌ Acelerômetro, giroscópio, barômetro, sensor de proximidade | Não existe hardware para simular fielmente |
| **Biometria real** | ⚠️ Simula Face ID / Touch ID por menu, sem hardware | É um "faz de conta" útil para testar o fluxo, não a segurança |
| **Bluetooth** | ❌ Não há rádio Bluetooth | — |
| **Chamadas e SMS** | ❌ | — |
| **Consumo de bateria** | ❌ Impossível medir | — |
| **Desempenho representativo** | ❌ | Roda na CPU/GPU do Mac |
| **Layout, navegação, formulários, rede HTTP, banco local** | ✅ Fiel | Isso é software puro |

Para o app **Foco**, a leitura é: matérias, sessões, cronômetro, metas, trilhas vindas da API e
estatísticas podem ser testados **inteiramente no Simulador**. Se um dia o Foco ganhar foto de capa
da matéria (via `image_picker`) ou lembrete por notificação, essa parte **exige iPhone físico**.

### O que muda no iPhone físico

Rodar em aparelho real exige três coisas que o Simulador dispensa:

1. **Assinatura de verdade.** O Simulador aceita um binário sem certificado; o iPhone não. É por
   isso que o primeiro `flutter run` num aparelho costuma falhar por assinatura, e não por código.
2. **Modo de Desenvolvedor ligado no aparelho** (obrigatório desde o **iOS 16**).
3. **Confiança explícita** no certificado do desenvolvedor, feita nos Ajustes do iPhone.

### Modo de Desenvolvedor: por que existe

Antes do iOS 16, qualquer iPhone conectado a um Mac com Xcode podia receber apps de
desenvolvimento. Isso virou vetor de golpe: criminosos convenciam vítimas a conectar o aparelho e
instalavam apps maliciosos "de desenvolvimento".

A partir do **iOS 16**, a Apple exige que o dono do aparelho ligue explicitamente o
**Modo de Desenvolvedor**, o que envolve reiniciar o aparelho e confirmar com o código de acesso.
É uma barreira de consentimento: alguém precisa fisicamente destravar aquele iPhone e concordar.

> ⚠️ O item **Modo de Desenvolvedor** só aparece nos Ajustes **depois** que o aparelho é conectado
> a um Mac com Xcode que tentou instalar algo nele. Se você procurar antes, não acha e acha que
> seu iPhone está defeituoso. Não está: o item é criado sob demanda.

---

## 💡 Analogia

O Simulador é uma maquete em escala do prédio: serve para conferir a planta, a circulação e onde
ficam as portas. O iPhone físico é o prédio construído: só nele você descobre que o elevador
demora, que o sol bate na sala à tarde e que o sinal de celular não chega ao subsolo. Aprovar a
obra só pela maquete é o erro.

---

## 🧪 Exemplo mínimo

**🖥️ macOS (bash/zsh)**

```bash
open -a Simulator
```

`open` é o comando do macOS que abre arquivos e aplicativos. `-a` diz "abra este **aplicativo**,
pelo nome". Em poucos segundos aparece a janela de um iPhone. Se nenhum simulador estiver
selecionado, o macOS abre o último usado, ou pede que você escolha um.

Agora liste o que o Flutter enxerga:

```bash
flutter devices
```

Saída esperada com um simulador aberto e um Mac:

```text
Found 3 connected devices:
  iPhone 17 Pro (mobile) • 1A2B3C4D-5E6F-7890-ABCD-EF1234567890 • ios            • com.apple.CoreSimulator.SimRuntime.iOS-26-0 (simulator)
  macOS (desktop)        • macos                                 • darwin-arm64   • macOS 26.x
  Chrome (web)           • chrome                                • web-javascript • Google Chrome 152.x
```

A segunda coluna é o **identificador do dispositivo**. Para um simulador ele é um **UDID**
(*Unique Device Identifier*), aquele código longo com hífens. É ele que você passa para o
`flutter run`:

```bash
cd ~/src/cursos/foco
flutter run -d 1A2B3C4D-5E6F-7890-ABCD-EF1234567890
```

Você não precisa digitar o UDID inteiro. O Flutter aceita um prefixo do identificador **ou** um
pedaço do nome:

```bash
flutter run -d iPhone
```

**Como confirmar objetivamente que funcionou:** o terminal imprime as linhas de conexão e o app
Foco abre na janela do simulador, na tela inicial com as abas **Hoje · Matérias · Trilhas ·
Ajustes**. O terminal fica aguardando com:

```text
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

Aperte `r` e altere um texto no código: a mudança aparece em menos de um segundo. Isso é o
**hot reload** funcionando no iOS, exatamente como no Android.

---

## 📱 Aplicando no Flutter

### Escolhendo o modelo de simulador

Dentro do Simulator, o menu é **File → Open Simulator →** e então a família e o modelo. Para
gerenciar a lista, use o Xcode: **Xcode → Window → Devices and Simulators → Simulators**, onde
você adiciona (`+`) ou remove modelos.

Pela linha de comando, `simctl` é a ferramenta do Xcode que controla simuladores:

```bash
xcrun simctl list devices available
xcrun simctl boot "iPhone 17 Pro"
xcrun simctl shutdown all
xcrun simctl erase all
```

| Comando | O que faz |
|---|---|
| `list devices available` | Lista os simuladores instalados e prontos para uso |
| `boot "<nome>"` | Liga um simulador específico |
| `shutdown all` | Desliga todos |
| `erase all` | **Apaga os dados** de todos os simuladores, voltando ao estado de fábrica |

`xcrun` é o "executor de ferramentas do Xcode": ele acha o binário certo dentro do developer
directory que você configurou na Aula 2 com `xcode-select`.

> ⚠️ `xcrun simctl erase all` é útil para testar a **primeira execução** do app (banco vazio,
> nenhuma preferência salva), que é o cenário em que mais bugs se escondem no Foco: lista de
> matérias vazia, meta semanal não definida, cache de trilhas inexistente. Mas ele apaga tudo,
> em todos os simuladores. Não use por engano.

### Quais modelos escolher para o Foco

Teste em pelo menos três perfis diferentes:

| Perfil | Por quê |
|---|---|
| Um iPhone **pequeno** (tela compacta, por exemplo um modelo "mini" ou SE) | Descobre texto cortado e botões espremidos |
| Um iPhone **grande** com notch/ilha dinâmica | Verifica se o conteúdo não fica sob a barra de status; é onde o `SafeArea` prova seu valor |
| Um **iPad** | Confere se o layout não estica de forma feia. O Módulo 06, aula 11, trata de responsividade |

### Rodando em modo release no Simulador

```bash
flutter run --release -d iPhone
```

Funciona, e é útil para ver o app sem o banner de debug e sem a sobrecarga do modo de
desenvolvimento. Mas repita a advertência: **o número de quadros por segundo aqui não representa
um iPhone real.** Medição de desempenho de verdade só em aparelho — veja
[Módulo 13, aula 04](../13-desempenho-e-seguranca/04-medindo-desempenho.md).

### Preparando o iPhone físico — passo a passo

**Passo 1 — Conecte o cabo.** Use um cabo de dados (alguns cabos baratos só carregam).

**Passo 2 — Confiar neste computador.** O iPhone mostra um alerta perguntando se você confia
neste computador. Toque em **Confiar** e digite o código de acesso do aparelho. Se você tocar em
"Não confiar" por engano, desconecte, reconecte e o alerta volta.

**Passo 3 — Ligue o Modo de Desenvolvedor.** No iPhone:

```text
Ajustes → Privacidade e Segurança → Modo de Desenvolvedor → ligar
```

O aparelho avisa que vai **reiniciar**. Confirme. Depois de reiniciar, ele pergunta de novo se
você quer mesmo ativar o Modo de Desenvolvedor: toque em **Ativar** e digite o código de acesso.

> ⚠️ Se o item **Modo de Desenvolvedor** não estiver na lista, conecte o iPhone ao Mac e tente
> instalar o app uma vez pelo Xcode ou pelo `flutter run`. A tentativa faz o item aparecer.
> Depois volte aos Ajustes.

**Passo 4 — Selecione o aparelho no Xcode.** Abra o workspace e escolha o iPhone no seletor de
destino:

```bash
open ios/Runner.xcworkspace
```

Na aba **Signing & Capabilities** do alvo `Runner`, marque **Automatically manage signing** e
escolha o seu **Team**. A Aula 7 explica o que está acontecendo por trás disso.

**Passo 5 — Rode.**

```bash
flutter devices
flutter run -d "iPhone de <seu-usuario>"
```

O nome do aparelho é o que você deu a ele em **Ajustes → Geral → Sobre → Nome**.

**Passo 6 — Confie no desenvolvedor.** Na primeira instalação com uma conta Apple gratuita, o app
aparece na tela inicial mas recusa abrir, com a mensagem de que o desenvolvedor não é confiável.
No iPhone:

```text
Ajustes → Geral → VPN e Gerenciamento de Dispositivo → (seu Apple ID)
   → Confiar em "<seu Apple ID>" → Confiar
```

Depois disso o app abre normalmente. Você faz isso **uma vez por conta de desenvolvedor**, não uma
vez por app.

> 🍎 Com **Apple ID gratuito**, o perfil de provisionamento **expira em 7 dias** e o app para de
> abrir, pedindo reinstalação. Não é defeito: é a regra da conta gratuita. A Aula 6 detalha.

---

## 💻 Código completo

Roteiro que prepara e executa o Foco em iOS, com conferências em cada etapa.

> **Arquivo:** `foco/ferramentas/rodar-no-ios.sh`
> **Como executar (no Mac, na raiz do projeto):** `bash ferramentas/rodar-no-ios.sh simulador`
> ou `bash ferramentas/rodar-no-ios.sh aparelho`

```bash
#!/usr/bin/env bash
# rodar-no-ios.sh
# Roda o app Foco no Simulador ou em um iPhone fisico.
# Uso: bash ferramentas/rodar-no-ios.sh [simulador|aparelho]

set -u

ALVO="${1:-simulador}"

titulo() {
  echo ""
  echo "===================================================================="
  echo "$1"
  echo "===================================================================="
}

if [ "$(uname)" != "Darwin" ]; then
  echo "[ERRO] Este roteiro so roda em macOS. No Windows, leia a Aula 3 e volte aqui no Mac."
  exit 1
fi

titulo "1. Conferindo o ambiente"
flutter doctor | grep -i "xcode" || echo "  [ALERTA] Sem linha de Xcode no doctor. Refaca a Aula 2."

titulo "2. Dependencias do projeto"
flutter pub get
if [ -f "ios/Podfile" ]; then
  ( cd ios && pod install )
fi

case "${ALVO}" in
  simulador)
    titulo "3. Abrindo o Simulador"
    open -a Simulator
    echo "  Aguardando o simulador ficar pronto..."
    xcrun simctl bootstatus booted -b >/dev/null 2>&1 || true

    titulo "4. Dispositivos vistos pelo Flutter"
    flutter devices

    titulo "5. Executando o Foco no Simulador"
    echo "  Dica: no terminal, 'r' faz hot reload e 'q' encerra."
    flutter run -d iPhone
    ;;

  aparelho)
    titulo "3. Checklist do iPhone fisico"
    cat <<'LISTA'
  Antes de continuar, confirme NO IPHONE:
   [ ] Cabo de DADOS conectado (cabo so de carga nao serve)
   [ ] Alerta "Confiar neste computador" respondido com Confiar
   [ ] Ajustes > Privacidade e Seguranca > Modo de Desenvolvedor LIGADO
   [ ] Aparelho reiniciado apos ligar o Modo de Desenvolvedor
   [ ] No Xcode: Runner > Signing & Capabilities > Automatically manage signing
       com um Team selecionado
LISTA
    read -r -p "  Tudo confirmado? (s/N) " RESPOSTA
    if [ "${RESPOSTA}" != "s" ] && [ "${RESPOSTA}" != "S" ]; then
      echo "  Encerrando. Resolva os itens acima e rode de novo."
      exit 0
    fi

    titulo "4. Dispositivos vistos pelo Flutter"
    flutter devices

    titulo "5. Executando o Foco no aparelho"
    echo "  Se o app instalar mas nao abrir, va em:"
    echo "    Ajustes > Geral > VPN e Gerenciamento de Dispositivo > seu Apple ID > Confiar"
    flutter run
    ;;

  *)
    echo "[ERRO] Alvo desconhecido: ${ALVO}"
    echo "Use: bash ferramentas/rodar-no-ios.sh [simulador|aparelho]"
    exit 1
    ;;
esac
```

**Como confirmar objetivamente que funcionou:**

- No modo `simulador`: a janela do iPhone abre, o app Foco aparece com as quatro abas e o terminal
  fica esperando comandos de `flutter run`. Apertar `r` recarrega em menos de 1 segundo.
- No modo `aparelho`: o ícone do Foco aparece na tela inicial do iPhone e o app abre depois da
  confiança no desenvolvedor. O terminal mostra o nome do seu aparelho na linha de conexão.

---

## 🔍 Explicando o código

- `ALVO="${1:-simulador}"` lê o primeiro argumento da linha de comando. A sintaxe `${1:-padrão}`
  significa "use `$1`, mas se ele não existir, use `simulador`". Com `set -u` ativo, ler `$1`
  direto sem argumento abortaria o script — o valor padrão evita isso.
- `flutter doctor | grep -i "xcode"` filtra a saída inteira e mostra só a linha que interessa.
  O `||` depois garante uma mensagem útil se o `grep` não encontrar nada.
- `xcrun simctl bootstatus booted -b` espera o simulador **terminar de iniciar**. Sem isso, o
  `flutter run` pode tentar instalar num simulador que ainda está subindo e falhar com um erro
  confuso. O `-b` faz o comando iniciar o dispositivo se ele ainda não estiver ligado.
- `>/dev/null 2>&1 || true` silencia a saída e impede que uma falha dessa espera derrube o script:
  ela é uma conveniência, não um requisito.
- `case "${ALVO}" in ... esac` é o `switch` do bash. Cada ramo termina com `;;`. O ramo `*)` é o
  padrão, usado quando o argumento não bate com nenhum dos anteriores.
- `cat <<'LISTA' ... LISTA` é um **here-document**: imprime tudo entre as marcas, literalmente. As
  aspas simples em `'LISTA'` impedem que o bash interprete `$` ou crase dentro do texto.
- `read -r -p "  Tudo confirmado? (s/N) " RESPOSTA` pausa e lê do teclado. `-p` mostra a pergunta;
  `-r` impede que a barra invertida seja interpretada como escape. Essa confirmação existe porque
  rodar em aparelho sem os passos do checklist gera erros de assinatura que parecem, para quem
  está começando, erros de código.
- `flutter run` sem `-d` no ramo `aparelho`: quando há um único dispositivo físico conectado, o
  Flutter o escolhe sozinho. Se houver mais de um, ele pergunta.

---

## 🤖🍎 Android × iOS

| Tema | 🤖 Android | 🍎 iOS |
|---|---|---|
| Ambiente virtual | Emulador (AVD), roda em Windows, macOS e Linux | Simulador, **só macOS** |
| Fidelidade | Emula ARM: mais lento que o aparelho | Roda nativo no Mac: **mais rápido** que o aparelho |
| Câmera no ambiente virtual | Usa a webcam do computador; funciona razoavelmente | Não há câmera |
| Push no ambiente virtual | Funciona com Google Play Services na imagem | Não funciona no fluxo padrão |
| Liberar o aparelho para dev | **Opções do desenvolvedor** + **Depuração USB** | **Modo de Desenvolvedor** (iOS 16+) + reinício |
| Confiança | Alerta de chave RSA do computador, na primeira conexão | "Confiar neste computador" + confiar no desenvolvedor nos Ajustes |
| Instalar fora da loja | `adb install`, `flutter install`, APK direto | Só com perfil de provisionamento válido |
| Validade da instalação de dev | Indefinida | **7 dias** com Apple ID gratuito; **1 ano** com conta paga |
| Listar dispositivos | `flutter devices`, `adb devices` | `flutter devices`, `xcrun simctl list` |

A diferença que mais impacta o seu fluxo de trabalho é a última: no Android, você instala o APK e
ele fica lá. No iOS com conta gratuita, o app **para de funcionar em 7 dias**. Planeje suas
demonstrações contando com isso.

---

## ⚠️ Erros comuns

**1. `flutter devices` não lista nenhum iPhone, nem simulador.**
O Simulator não está aberto, ou o `xcode-select` aponta para as Command Line Tools em vez do Xcode
completo. Rode `xcode-select -p` e confira (Aula 2).

**2. O app instala no aparelho mas não abre, com aviso de desenvolvedor não confiável.**
É o comportamento esperado na primeira instalação com conta gratuita. Vá em
**Ajustes → Geral → VPN e Gerenciamento de Dispositivo**, toque no seu Apple ID e confirme
**Confiar**.

**3. O item "Modo de Desenvolvedor" não existe nos Ajustes.**
Ele só aparece depois que o aparelho recebe uma tentativa de instalação de app de desenvolvimento.
Conecte ao Mac, rode `flutter run` uma vez (mesmo que falhe) e volte aos Ajustes.

**4. O app parou de abrir depois de uma semana.**
Perfil de provisionamento de conta gratuita expira em **7 dias**. Reinstale com `flutter run`, ou
migre para o Apple Developer Program (Aula 6).

**5. "O app está muito rápido no Simulador, então está otimizado."**
Conclusão inválida. O Simulador usa a CPU e a GPU do Mac. Meça desempenho em aparelho físico, em
modo `--profile`.

**6. Testar `image_picker` no Simulador e achar que o plugin está quebrado.**
Não há câmera no Simulador. Teste a galeria (que existe, com fotos de exemplo) no Simulador e a
câmera no aparelho.

**7. Cabo que só carrega.**
Alguns cabos não têm as vias de dados. Se o iPhone carrega mas o alerta "Confiar neste computador"
nunca aparece, troque o cabo antes de procurar problema no software.

**8. Vários simuladores abertos ao mesmo tempo.**
`flutter run -d iPhone` fica ambíguo quando dois simuladores com "iPhone" no nome estão ligados.
Use o UDID completo, ou `xcrun simctl shutdown all` antes.

---

## 🛠️ Exercício guiado

**Objetivo:** montar a matriz de testes iOS do Foco e deixar o roteiro pronto — tudo isso no
Windows, hoje.

**Passo 1.** Crie `ferramentas/rodar-no-ios.sh` com o conteúdo da seção "Código completo". Salve
com quebra de linha **LF** (veja o Passo 1 do exercício da Aula 2).

**Passo 2.** Monte, num arquivo `docs/testes-ios.md` do **seu** projeto, a matriz abaixo,
preenchendo a coluna "Onde testar" para cada funcionalidade do Foco:

| Funcionalidade do Foco | Simulador basta? | Precisa de iPhone físico? | Por quê |
|---|---|---|---|
| CRUD de matérias (sqflite) | | | |
| Cronômetro da sessão de estudo | | | |
| Meta semanal (`shared_preferences`) | | | |
| Trilhas vindas da API JSONPlaceholder | | | |
| Tela de estatísticas | | | |
| Comportamento em modo escuro | | | |
| Navegação com gesto de voltar (deslizar da borda) | | | |
| Desempenho da lista de matérias com 500 itens | | | |
| Comportamento sem internet | | | |
| App em segundo plano e retorno | | | |

Gabarito de raciocínio para conferir depois: as quatro primeiras e as estatísticas são software
puro e o Simulador basta. Modo escuro também. **Gesto de voltar** e **app em segundo plano** são
melhores no aparelho, porque o gesto no Simulador se faz com o mouse e o ciclo de vida real
difere. **Desempenho** exige aparelho, sempre. **Sem internet** dá para simular nos dois, mas o
comportamento de rede do aparelho é mais realista.

**Passo 3.** Escreva, ao lado da matriz, quantos **minutos de Mac** você estima gastar executando
tudo. Some. Esse número é o que você precisa reservar quando conseguir o Mac emprestado.

**Passo 4.** Commite:

```powershell
git add ferramentas/rodar-no-ios.sh docs/testes-ios.md
git commit -m "Roteiro de execucao iOS e matriz de testes por ambiente"
```

**Passo 5.** Responda por escrito: por que a Apple passou a exigir o Modo de Desenvolvedor a
partir do iOS 16? Qual problema de segurança isso resolve? (A resposta está na seção "Conceito".)

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/16-build-ios.md](../../exercicios/16-build-ios.md)

---

## 🏆 Desafio opcional

Escreva um segundo roteiro, `ferramentas/primeira-execucao-ios.sh`, que teste o cenário de
**primeira execução** do Foco — aquele em que o banco está vazio, não há meta semanal definida e
o cache de trilhas não existe. Ele deve:

1. Conferir que está em macOS.
2. Pedir confirmação explícita, porque vai apagar dados de simulador.
3. Rodar `xcrun simctl shutdown all` e `xcrun simctl erase all`.
4. Abrir o Simulador e rodar `flutter run --release`.
5. Imprimir uma lista de verificação do que observar: a tela de estado vazio das matérias, a
   mensagem de meta não definida, o carregamento das trilhas e o estado de erro quando a rede cai.

Esse cenário é justamente onde moram os bugs de `null` e de lista vazia que o
[Módulo 06, aula 12](../06-widgets-e-layouts/12-estados-de-ui.md) ensinou a tratar. Rodar o app
sempre com o banco já populado esconde esses defeitos.

---

## 📌 Resumo

- `open -a Simulator` abre o Simulador; `flutter devices` lista o que o Flutter enxerga;
  `flutter run -d <id|nome>` executa. O identificador do simulador é um UDID, e um prefixo ou
  pedaço do nome basta.
- `xcrun simctl` controla simuladores pela linha de comando: `list devices available`, `boot`,
  `shutdown all`, `erase all`.
- O Simulador **não tem** câmera, push remoto no fluxo padrão, sensores, Bluetooth nem consumo de
  bateria — e o desempenho dele é **mais rápido** que o de um iPhone real. Nunca avalie desempenho
  ali.
- Layout, navegação, formulários, HTTP e banco local são fiéis no Simulador. Para o Foco, isso
  cobre quase tudo.
- iPhone físico exige: cabo de dados, **Confiar neste computador**, e
  **Ajustes → Privacidade e Segurança → Modo de Desenvolvedor** (obrigatório desde o **iOS 16**),
  com reinício do aparelho.
- Na primeira instalação com conta gratuita, o app não abre até você confiar no desenvolvedor em
  **Ajustes → Geral → VPN e Gerenciamento de Dispositivo**.
- Com Apple ID gratuito o perfil **expira em 7 dias** e o app para de abrir. Com o Apple Developer
  Program, o perfil vale 1 ano.

---

## ☑️ Checklist de domínio

- [ ] Abro o Simulador por comando e escolho o modelo pela interface do Xcode.
- [ ] Listo dispositivos e rodo o app passando UDID, prefixo ou nome.
- [ ] Explico por que o Simulador é mais rápido que um iPhone real e o que isso invalida.
- [ ] Cito cinco coisas que o Simulador não faz.
- [ ] Digo quais funcionalidades do Foco podem ser testadas só no Simulador e quais exigem
      aparelho.
- [ ] Descrevo os seis passos para rodar o app num iPhone físico, na ordem.
- [ ] Sei o caminho exato, nos Ajustes, do Modo de Desenvolvedor e da tela de confiar no
      desenvolvedor.
- [ ] Explico por que o Modo de Desenvolvedor passou a existir no iOS 16.
- [ ] Sei o que fazer quando o item "Modo de Desenvolvedor" não aparece nos Ajustes.
- [ ] Explico por que o app instalado com conta gratuita para de abrir depois de 7 dias.
- [ ] Criei `ferramentas/rodar-no-ios.sh` e a matriz de testes por ambiente.

---

## 📚 Referências oficiais

- [Flutter — Build and release an iOS app](https://docs.flutter.dev/deployment/ios)
- [Flutter — Test drive](https://docs.flutter.dev/get-started/test-drive)
- [Flutter — Install on macOS](https://docs.flutter.dev/get-started/install/macos)
- [Apple — Running your app in Simulator or on a device](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- [Apple — Simulator Overview](https://developer.apple.com/documentation/xcode/simulator)
- [Apple — Enabling Developer Mode on a device](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
- [Apple — Distributing your app to registered devices](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 2 — Xcode e CocoaPods](02-xcode-e-cocoapods.md) | [README](README.md) | [Aula 4 — Bundle ID e o Xcode](04-bundle-id-e-xcode.md) |
