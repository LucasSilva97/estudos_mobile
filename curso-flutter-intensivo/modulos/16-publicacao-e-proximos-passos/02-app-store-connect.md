# Aula 2 — App Store Connect

> **Módulo:** 16 - Publicação e Próximos Passos · **Tempo estimado:** 45 min · **Nível:** Intermediário

## 🎯 Objetivos de aprendizagem

- 🍎 Explicar o que é o **App Store Connect** e como ele se encaixa entre o Xcode e a App Store.
- 🍎 Criar o **registro do app** (*app record*) do Foco com o Bundle ID `br.com.estudos.foco`.
- 🍎 Preencher as **informações da versão**: descrição, palavras-chave, URL de suporte, URL da
  política de privacidade e novidades da versão.
- 🍎 Saber quais **capturas de tela** são obrigatórias, por tamanho de iPhone e de iPad.
- 🍎 Explicar de onde vem o **ícone de 1024×1024** e por que ele **não** é enviado pelo navegador.
- 🍎 Preencher a **Nutrition Label de privacidade** (*App Privacy*) e a **classificação etária**.
- 🍎 Definir **preço e disponibilidade** e enviar a versão para revisão.
- 🍎 Descrever o que a **revisão humana** avalia, os motivos comuns de rejeição, o prazo típico e o
  que fazer quando o app é reprovado.
- 🪟 Saber exatamente **o que você consegue fazer hoje no Windows** e o que fica para quando houver
  acesso a um macOS.

## ✅ Pré-requisitos

- [Módulo 15 — Build iOS](../15-build-ios/README.md) concluído, em especial
  [01-por-que-exige-macos.md](../15-build-ios/01-por-que-exige-macos.md),
  [06-conta-apple-gratuita-x-paga.md](../15-build-ios/06-conta-apple-gratuita-x-paga.md) e
  [09-exportando-ipa-e-testflight.md](../15-build-ios/09-exportando-ipa-e-testflight.md).
- [Aula 1 — Google Play](01-google-play.md), para comparar os dois processos.
- O projeto **Foco** com a pasta `ios/` presente (criada pelo `flutter create --platforms=android,ios`).
- Um **Apple ID**. Para **publicar**, o Apple Developer Program a **US$ 99 por ano**.

---

> 🪟🔴 **Você está no Windows 11. Leia isto antes de continuar.**
>
> **AGORA, nesta máquina:** criar o Apple ID e navegar pelo App Store Connect; criar o registro do
> app; escrever descrição, palavras-chave e URLs; preencher a Nutrition Label; responder a
> classificação etária; definir preço e disponibilidade; escrever e conferir os textos de permissão
> do `ios/Runner/Info.plist` (é o que o [💻 Código completo](#-código-completo) faz); preparar as
> imagens das capturas.
>
> **EXIGE macOS + Xcode, fica para depois:** compilar para iOS, gerar o **archive** e o **`.ipa`**,
> **enviar o binário** (Xcode, app Transporter ou ferramenta de linha de comando do macOS) e testar
> em simulador ou iPhone físico com perfil de distribuição.
>
> 🔴 **Não existe caminho suportado para gerar um `.ipa` no Windows.** O compilador da Apple e as
> ferramentas de assinatura só rodam em macOS; qualquer tutorial que prometa o contrário está
> enganando você. O caminho legítimo de quem não tem Mac é um **runner macOS na nuvem** — é o que a
> [Aula 4 — CI/CD introdutório](04-ci-cd-introdutorio.md) ensina.
>
> **Conclusão prática:** dá para deixar **100% do App Store Connect preenchido** hoje. Quando houver
> acesso a um Mac (emprestado, alugado por hora, ou um runner de CI), falta só subir o binário.

---

## 📖 Conceito

### O que é o App Store Connect

O **App Store Connect** (`https://appstoreconnect.apple.com`) é o painel web da Apple onde você
administra tudo que **não é código**: a ficha da loja, as versões, os testes com **TestFlight**, os
contratos, os relatórios de venda e as respostas a avaliações.

Ele é o equivalente do Play Console, com uma diferença central de fluxo:

```text
🤖 Google Play                          🍎 App Store
Windows: flutter build appbundle        macOS: flutter build ipa
   ↓ upload pelo navegador                 ↓ upload pelo Xcode/Transporter (macOS)
Play Console                            App Store Connect
   ↓ revisão automatizada + humana         ↓ revisão HUMANA, sempre
Google Play                             App Store
```

**O binário não sobe pelo navegador.** Esse é o ponto que trava quem está no Windows.

### Três lugares diferentes, três funções

Muita gente confunde os três portais da Apple:

| Portal | Endereço | Para quê |
|---|---|---|
| **Apple Developer** | `developer.apple.com` | Assinar o programa (US$ 99/ano), registrar **Bundle IDs**, gerar certificados e *provisioning profiles* |
| **App Store Connect** | `appstoreconnect.apple.com` | Registro do app, ficha da loja, versões, TestFlight, revisão |
| **Xcode** (🖥️ só no Mac) | aplicativo | Compilar, arquivar e **enviar** o binário |

O Bundle ID `br.com.estudos.foco` precisa existir no **Apple Developer** antes de o App Store
Connect deixar você criar o app. Isso foi tratado em
[15-build-ios/04-bundle-id-e-xcode.md](../15-build-ios/04-bundle-id-e-xcode.md).

### Criando o registro do app

Em **Meus Apps → + → Novo app**, você preenche:

| Campo | O que é | Observação |
|---|---|---|
| **Plataformas** | iOS (e/ou macOS, tvOS) | Marque iOS |
| **Nome** | até **30 caracteres**, visível na loja | Precisa ser **único na App Store inteira** |
| **Idioma principal** | Português (Brasil) | Define o idioma da ficha padrão |
| **Bundle ID** | escolhido de uma lista | `br.com.estudos.foco` — precisa já estar registrado |
| **SKU** | um código interno **seu**, nunca exibido | Ex.: `FOCO-2026-01`. Serve para relatórios |
| **Acesso de usuário** | quem da equipe vê o app | "Acesso total" se você trabalha sozinho |

> ⚠️ **Nome único.** Se "Foco" já existir, o App Store Connect recusa. Use algo distintivo, como
> "Foco: Organizador de Estudos".

### Informações da versão

Cada versão tem sua própria ficha:

| Campo | Limite | Observação |
|---|---|---|
| **Subtítulo** | 30 caracteres | Aparece sob o nome |
| **Descrição** | 4.000 caracteres | Sem HTML |
| **Palavras-chave** (*keywords*) | **100 caracteres no total**, separadas por vírgula, **sem espaço depois da vírgula** | Cada caractere conta, inclusive as vírgulas |
| **URL de suporte** | obrigatória | Página onde o usuário fala com você |
| **URL de marketing** | opcional | Site do app |
| **URL da política de privacidade** | **obrigatória** | Mesma regra da Play: pública e específica |
| **Novidades desta versão** | 4.000 caracteres | Obrigatório a partir da segunda versão |
| **Informações para a revisão** | texto livre + **conta de teste** | Onde você entrega usuário e senha de demonstração |

> 💡 **Palavras-chave: use o espaço direito.** `estudo,foco,pomodoro,cronometro,materias,metas` tem
> 45 caracteres. Escrever `estudo, foco, pomodoro` desperdiça um caractere por vírgula. Não repita
> palavras que já estão no nome nem no subtítulo — a Apple já indexa aquilo.

### Capturas de tela: por tamanho de tela

A Apple organiza capturas por **classe de tamanho de tela**, não por modelo. Você envia um conjunto
por classe, e a Apple reaproveita o conjunto maior para as telas menores quando você não fornece
específicas.

| Classe | Tamanhos aceitos (px, retrato) | Obrigatória? |
|---|---|---|
| **iPhone 6,9"** | 1320 × 2868 **ou** 1290 × 2796 | **Sim** — é o conjunto de referência do iPhone |
| **iPhone 6,5"** | 1284 × 2778 **ou** 1242 × 2688 | Pode ser derivada do 6,9" |
| **iPad 13"** | 2064 × 2752 **ou** 2048 × 2732 | **Sim, se o app aceita iPad** |

Regras que valem para todas:

- **Mínimo 1, máximo 10** capturas por classe e por idioma.
- PNG ou JPEG, **sem canal alfa** (sem transparência).
- Retrato **ou** paisagem — mas mantenha coerência dentro do conjunto.
- Sem molduras de celular desenhadas em volta, sem texto que prometa algo que o app não faz.

> ⚠️ **A lista de tamanhos aceitos muda quando a Apple lança iPhones novos.** O próprio App Store
> Connect mostra, na tela de upload, os tamanhos exatos que ele aceita **naquele momento**. Sempre
> confira lá antes de exportar as imagens.

### O ícone: 1024×1024 e ele NÃO sobe pelo navegador

Diferente da Google Play, a Apple **não** tem campo de upload de ícone no painel. O ícone da App
Store vem **dentro do binário**, no catálogo de recursos:

```text
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
```

Esse arquivo é exatamente um dos que o `flutter_launcher_icons` gerou para você no módulo 14 (veja
[14-build-android/03-icone.md](../14-build-android/03-icone.md)). Requisitos:

- PNG **1024 × 1024**, quadrado;
- **sem canal alfa** — por isso a configuração `remove_alpha_ios: true` no `pubspec.yaml`;
- **sem cantos arredondados desenhados** — o iOS arredonda sozinho.

> 🔴 Ícone com transparência é **rejeição automática** no momento do upload do binário, antes mesmo
> da revisão humana. A mensagem é do tipo *"Invalid large app icon. The large app icon in the asset
> catalog can't be transparent or contain an alpha channel."*

### Nutrition Label de privacidade (*App Privacy*)

É o equivalente da "Segurança dos Dados" da Play, e a Apple chama informalmente de **nutrition
label** porque o resultado é um quadro parecido com a tabela nutricional de um alimento, exibido na
ficha do app.

Para cada **tipo de dado** (contato, saúde, financeiro, localização, identificadores, uso, conteúdo
do usuário, diagnósticos…) você responde três perguntas:

1. O app **coleta** esse dado?
2. Ele é **vinculado à identidade** do usuário (*linked to you*)?
3. Ele é usado para **rastreamento** (*tracking*) entre apps e sites de outras empresas?

Preenchimento do **Foco**:

| Pergunta | Resposta | Por quê |
|---|---|---|
| Coleta algum dado? | **Não** | Matérias, sessões e metas ficam no aparelho (sqflite + shared_preferences) |
| Vincula dados à identidade? | não se aplica | Não há login nem cadastro |
| Usa rastreamento? | **Não** | Nenhum SDK de anúncio ou análise de terceiros |

> ⚠️ Se um dia você adicionar uma biblioteca de análise ou de anúncios, **ela coleta dados por
> você** e a resposta muda. Declarar "não coleto" com um SDK de anúncios embutido é uma das formas
> mais rápidas de ter o app removido.

### Classificação etária

Questionário sobre violência, conteúdo sexual, linguagem imprópria, temas maduros, apostas,
interação entre usuários e uso irrestrito da web. O resultado é uma faixa (4+, 9+, 12+, 17+).
Para o **Foco**, sem qualquer um desses elementos, o resultado é **4+**.

### Preço e disponibilidade

- **Preço:** escolhido de uma tabela de faixas da Apple. "Gratuito" é uma das faixas.
- **Disponibilidade:** você marca os países/regiões. O padrão é "todos".
- **Pré-encomenda** e **lançamento agendado** são opcionais.
- Para apps **pagos**, é preciso ter os **contratos bancários e fiscais** assinados no App Store
  Connect. Para apps **gratuitos sem compras no app**, basta o contrato padrão de apps gratuitos.

### Enviar para revisão

Depois de o binário chegar (pelo Xcode, do macOS), ele aparece em **Build** na página da versão.
Você seleciona o build, confere tudo e clica em **Adicionar para revisão** → **Enviar**.

O que a **revisão humana** avalia — não é só automação:

1. **O app abre e funciona?** Um revisor instala e usa o app de verdade.
2. **O conteúdo bate com a ficha?** Capturas e descrição precisam mostrar o app real.
3. **As permissões fazem sentido?** Cada texto de permissão do `Info.plist` é lido.
4. **Há conteúdo suficiente?** Apps "de uma tela só" caem na regra de funcionalidade mínima.
5. **Dá para entrar?** Se há login obrigatório, o revisor usa a **conta de teste** que você forneceu.
6. **Compras seguem as regras?** Venda de conteúdo digital precisa usar compra no app.
7. **Privacidade** — a Nutrition Label bate com o comportamento observado?

**Prazo típico:** a Apple revisa a **maioria dos envios em menos de 24 horas**. Primeiros envios e
apps com pontos sensíveis demoram mais. Existe pedido de **revisão acelerada** (*expedited review*),
reservado para correções críticas — use com parcimônia, ou o pedido deixa de ser levado a sério.

### Se for rejeitado

A rejeição chega pelo **Resolution Center** (Central de Resoluções) do App Store Connect, citando a
**diretriz** violada (por exemplo, "Guideline 2.1 — App Completeness").

O que fazer, nesta ordem:

1. **Leia a diretriz citada**, não só o texto do revisor. As diretrizes estão publicadas.
2. **Responda no Resolution Center.** É uma conversa: você pode pedir esclarecimento, anexar
   captura de tela e explicar. Muitas rejeições se resolvem **sem** novo build.
3. **Se for problema de código ou de ficha**, corrija, suba um novo build (número maior) e reenvie.
4. **Se você discorda**, existe o **App Review Board** (recurso formal). Use quando tiver certeza de
   que houve engano — não como primeira reação.

Rejeição **não** é punição nem mancha no histórico. É parte normal do processo; praticamente todo
app é rejeitado pelo menos uma vez.

---

## 💡 Analogia

A Google Play é um **portão automático com câmera**: um sistema confere o crachá, checa a lista e
abre. Existem humanos por trás, mas eles entram em cena principalmente quando algo dispara alarme.

A App Store é uma **portaria com recepcionista**. A pessoa olha na sua cara, pergunta aonde você
vai, lê o convite e decide. Isso explica os dois fatos que mais incomodam iniciantes: a revisão é
**mais subjetiva** (um revisor pode reparar em algo que outro não reparou) e a **conversa** existe —
você fala com a recepção pelo Resolution Center em vez de apenas receber um código de erro.

---

## 🧪 Exemplo mínimo

Mesmo no Windows, o arquivo `ios/Runner/Info.plist` está no seu projeto e você pode lê-lo.

**🪟 Windows (PowerShell)**

```powershell
Set-Location C:\src\cursos\foco
Select-String -Path .\ios\Runner\Info.plist -Pattern 'CFBundle|UsageDescription'
```

Resultado esperado (as linhas de versão vêm do `pubspec.yaml`; as de permissão só aparecem se você
as adicionou no módulo 11):

```text
ios\Runner\Info.plist:8:	<key>CFBundleDisplayName</key>
ios\Runner\Info.plist:14:	<key>CFBundleIdentifier</key>
ios\Runner\Info.plist:18:	<key>CFBundleName</key>
ios\Runner\Info.plist:22:	<key>CFBundleShortVersionString</key>
ios\Runner\Info.plist:26:	<key>CFBundleVersion</key>
```

**Como confirmar objetivamente:** as chaves `CFBundleShortVersionString` e `CFBundleVersion`
aparecem. Elas valem, respectivamente, `$(FLUTTER_BUILD_NAME)` e `$(FLUTTER_BUILD_NUMBER)` — ou
seja, vêm do `version: 1.0.0+1` do `pubspec.yaml`. Isso é assunto da
[Aula 3](03-versionamento-e-releases.md).

Um texto de permissão específico, como a Apple exige, tem esta cara:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da câmera para você anexar uma foto ao seu material de estudo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos da galeria para você escolher a imagem de capa da matéria.</string>
```

Compare com o que **causa rejeição**:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos de acesso à câmera.</string>
```

A diferença é que o primeiro responde **"para quê, do ponto de vista de quem usa o app"**. O segundo
apenas repete o nome da permissão.

---

## 📱 Aplicando no Flutter

Três campos do projeto Flutter alimentam o App Store Connect:

| No projeto Flutter | Vira, no app iOS | O App Store Connect usa para |
|---|---|---|
| Bundle Identifier no Xcode (`br.com.estudos.foco`) | `CFBundleIdentifier` | Casar o binário com o registro do app |
| `version: 1.0.0+1` no `pubspec.yaml` | `CFBundleShortVersionString` = `1.0.0` e `CFBundleVersion` = `1` | Recusar reenvio do mesmo número de build |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` | Ícone da loja | Exibir o ícone na ficha |

E os textos de permissão do `ios/Runner/Info.plist` são lidos por um humano na revisão. Por isso
vale automatizar a conferência — é o que o próximo bloco faz, **rodando no Windows**.

---

## 💻 Código completo

Um verificador que lê o `Info.plist` e reprova textos de permissão genéricos **antes** de você
gastar um ciclo de revisão da Apple.

> **Arquivo:** `foco/tool/checar_info_plist.dart`
> **Como executar:** `dart run tool/checar_info_plist.dart`

```dart
// ignore_for_file: avoid_print
// Script de terminal: aqui print() é a saída desejada.
// Em código de app Flutter use debugPrint().

import 'dart:io';

/// Trechos que, sozinhos, indicam texto de permissão vago.
/// A Apple rejeita textos que não dizem PARA QUE a permissão serve.
const List<String> _sinaisDeTextoGenerico = <String>[
  'precisamos de acesso',
  'este app precisa de acesso',
  'permitir acesso',
  'acesso necessario',
  'acesso necessário',
  'para funcionar corretamente',
  'usado pelo app',
];

/// Tamanho mínimo razoável para um texto que explica um motivo real.
const int _tamanhoMinimo = 40;

void main() {
  final arquivo = File('ios/Runner/Info.plist');

  if (!arquivo.existsSync()) {
    print('ERRO: ios/Runner/Info.plist nao encontrado.');
    print('Rode este script na raiz do projeto (onde esta o pubspec.yaml).');
    exitCode = 2;
    return;
  }

  final conteudo = arquivo.readAsStringSync();

  // Casa <key>algumaCoisaUsageDescription</key> seguida de <string>...</string>.
  final padrao = RegExp(
    r'<key>([A-Za-z]+UsageDescription)</key>\s*<string>(.*?)</string>',
    dotAll: true,
  );

  final ocorrencias = padrao.allMatches(conteudo).toList();

  if (ocorrencias.isEmpty) {
    print('Nenhuma chave *UsageDescription encontrada.');
    print('Isso e esperado se o Foco ainda nao usa camera, galeria ou localizacao.');
    return;
  }

  var problemas = 0;

  for (final ocorrencia in ocorrencias) {
    final chave = ocorrencia.group(1)!;
    final texto = ocorrencia.group(2)!.trim();
    final erros = _validar(texto);

    if (erros.isEmpty) {
      print('OK   $chave');
      print('     "$texto"');
    } else {
      problemas++;
      print('FALHA $chave');
      print('      "$texto"');
      for (final erro in erros) {
        print('      -> $erro');
      }
    }
  }

  print('');
  print('Chaves analisadas: ${ocorrencias.length} | Com problema: $problemas');

  if (problemas > 0) {
    print('Reescreva os textos acima antes de enviar para a revisao da Apple.');
    exitCode = 1;
  } else {
    print('Todos os textos de permissao estao especificos. Pode seguir.');
  }
}

/// Devolve a lista de motivos pelos quais [texto] seria reprovado.
/// Lista vazia significa texto aceitavel.
List<String> _validar(String texto) {
  final erros = <String>[];
  final minusculo = texto.toLowerCase();

  if (texto.isEmpty) {
    erros.add('Texto vazio. A Apple rejeita permissao sem justificativa.');
    return erros;
  }

  if (texto.length < _tamanhoMinimo) {
    erros.add('Curto demais (${texto.length} caracteres, '
        'minimo sugerido $_tamanhoMinimo). Diga o motivo concreto.');
  }

  for (final sinal in _sinaisDeTextoGenerico) {
    if (minusculo.contains(sinal)) {
      erros.add('Contem a expressao generica "$sinal".');
    }
  }

  if (!minusculo.contains('para ') && !minusculo.contains('assim ')) {
    erros.add('Nao explica a finalidade. Use "para voce ..." e diga o beneficio.');
  }

  return erros;
}
```

**Resultado esperado** com os textos corretos do anexo:

```text
OK   NSCameraUsageDescription
     "Precisamos da câmera para você anexar uma foto ao seu material de estudo."
OK   NSPhotoLibraryUsageDescription
     "Precisamos da galeria para você escolher a imagem de capa da matéria."

Chaves analisadas: 2 | Com problema: 0
Todos os textos de permissao estao especificos. Pode seguir.
```

**Resultado esperado** com um texto genérico:

```text
FALHA NSCameraUsageDescription
      "Precisamos de acesso à câmera."
      -> Curto demais (30 caracteres, minimo sugerido 40). Diga o motivo concreto.
      -> Contem a expressao generica "precisamos de acesso".
      -> Nao explica a finalidade. Use "para voce ..." e diga o beneficio.

Chaves analisadas: 1 | Com problema: 1
Reescreva os textos acima antes de enviar para a revisao da Apple.
```

**Como confirmar objetivamente que funcionou:** rode o script e depois cheque o código de saída.

```powershell
dart run tool/checar_info_plist.dart
$LASTEXITCODE
```

Resultado esperado: `0` quando está tudo certo, `1` quando há texto reprovado, `2` quando o arquivo
não foi encontrado. Esse código é o que um sistema de CI vai olhar na
[Aula 4](04-ci-cd-introdutorio.md).

---

## 🔍 Explicando o código

- `// ignore_for_file: avoid_print` — `flutter_lints` proíbe `print()` em código de app, porque a
  saída se perde no aparelho. Num **script de terminal**, `print()` é justamente a saída desejada;
  o comentário desliga o aviso só neste arquivo e documenta a intenção.
- `File('ios/Runner/Info.plist')` — caminho **relativo** à pasta de onde o script foi executado. Por
  isso o `existsSync()` com mensagem clara: rodar da pasta errada é o erro mais comum.
- `exitCode = 2` em vez de `exit(2)` — `exitCode` define o código de saída e deixa o programa
  terminar normalmente. `exit()` encerra na hora e pode cortar saída ainda não gravada no terminal.
- `RegExp(r'...', dotAll: true)` — o `r` antes das aspas cria uma *raw string*, em que `\s` é o
  próprio `\s` e não uma tentativa de escape do Dart. `dotAll: true` faz o `.` casar também com
  quebra de linha, necessário porque `<key>` e `<string>` costumam estar em linhas diferentes.
- `(.*?)` — o `?` torna a repetição **preguiçosa**: ela para no primeiro `</string>`. Sem o `?`, a
  expressão engoliria o arquivo até o último `</string>`.
- `ocorrencia.group(1)!` — o grupo 1 é o conteúdo do primeiro par de parênteses (a chave) e o grupo 2
  é o segundo (o texto). O `!` afirma que não é nulo; é seguro aqui porque a expressão só casa
  quando os dois grupos existem.
- `_validar` devolve **lista de erros** em vez de `bool`. Assim o script diz *o que* está errado, e
  não apenas que está errado — a mesma lógica das mensagens de validação de formulário do módulo 07.
- Constantes com `_` no início (`_tamanhoMinimo`) são **privadas ao arquivo** em Dart. Como este
  script não é biblioteca, tudo que não precisa vazar fica privado.

---

## 🤖🍎 Android × iOS

| Tema | 🤖 Google Play | 🍎 App Store |
|---|---|---|
| Ícone da loja | Upload separado de **512×512** no navegador | Vem **dentro do binário**: `Icon-App-1024x1024@1x.png`, sem alfa |
| Banner | **Gráfico de destaque** 1024×500 obrigatório | Não existe |
| Capturas | Por proporção (16:9 / 9:16), mín. 2 | Por **classe de tela**: iPhone 6,9" e iPad 13" |
| Palavras-chave | Não existe campo; o algoritmo lê a descrição | Campo próprio, **100 caracteres** |
| Declaração de privacidade | **Segurança dos Dados** | **Nutrition Label** (App Privacy) |
| Classificação | Questionário **IARC** | Questionário próprio da Apple (4+ a 17+) |
| Conta de teste | Seção **Acesso ao app** | **Informações para a revisão** |
| Revisão | Automatizada + humana, horas a 7 dias | **Humana**, em geral < 24 h |
| Recurso contra rejeição | Formulário de apelação | **Resolution Center** + **App Review Board** |
| Dá para enviar do Windows? | **Sim** | **Não** — o binário exige macOS |

---

## ⚠️ Erros comuns

**1. Texto de permissão genérico (Guideline 5.1.1).**
`"Precisamos de acesso à câmera."` é reprovado. O revisor quer saber **por que**, do ponto de vista
de quem usa. Correção: rode `dart run tool/checar_info_plist.dart` e reescreva.

**2. App incompleto (Guideline 2.1 — App Completeness).**
Telas com dados falsos, botão que não faz nada, tela que trava, "em breve" visível na interface.
Correção: passe o app inteiro antes de enviar, usando o
[checklists/projeto-final.md](../../checklists/projeto-final.md).

**3. Funcionalidade mínima (Guideline 4.2).**
App que é só uma lista estática ou um site embrulhado. Correção: o Foco tem CRUD, cronômetro,
persistência e estatísticas — está bem acima do limiar. Um app de uma tela só, não.

**4. Login obrigatório sem conta de teste (Guideline 2.1).**
O revisor abre o app, vê tela de login e não tem como entrar → rejeição imediata. Correção: em
**Informações para a revisão**, preencha usuário e senha de uma conta de demonstração. Use algo como
`SEU_USUARIO_DE_TESTE` / `SUA_SENHA_AQUI` como marcadores enquanto estuda, e credenciais **de teste
descartáveis** de verdade na hora de enviar — nunca a sua conta pessoal.

**5. Metadados imprecisos (Guideline 2.3).**
Capturas de tela que mostram uma versão diferente do app, ou descrição que promete o que não existe.
Correção: refaça as capturas a cada mudança visual relevante.

**6. Ícone com canal alfa.**
Rejeitado no upload do binário. Correção: `remove_alpha_ios: true` no bloco
`flutter_launcher_icons` do `pubspec.yaml` e `dart run flutter_launcher_icons` de novo.

**7. Nutrition Label incoerente.**
Declarar "não coleto dados" com SDK de análise embutido. Correção: liste suas dependências e
verifique, uma a uma, o que cada uma envia para fora.

**8. Achar que o Windows vai gerar o `.ipa`.**
Não vai. Correção: use um runner macOS ([Aula 4](04-ci-cd-introdutorio.md)) ou acesso temporário a
um Mac. Todo o resto desta aula você já faz no Windows.

---

## 🛠️ Exercício guiado

**Passo 1 — Rodar o verificador.**

```powershell
Set-Location C:\src\cursos\foco
dart run tool/checar_info_plist.dart
```

Resultado esperado: a mensagem sobre nenhuma chave encontrada (se o Foco ainda não usa câmera) ou a
lista `OK` / `FALHA` por chave.

**Passo 2 — Provocar uma falha de propósito.** Adicione, dentro do `<dict>` principal de
`ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos de acesso à câmera.</string>
```

Rode de novo. Resultado esperado: o bloco `FALHA` com os três motivos, e `$LASTEXITCODE` igual a `1`.

**Passo 3 — Corrigir.** Troque o texto por:

```xml
<key>NSCameraUsageDescription</key>
<string>Precisamos da câmera para você anexar uma foto ao seu material de estudo.</string>
```

Resultado esperado: `OK NSCameraUsageDescription` e `$LASTEXITCODE` igual a `0`.

**Passo 4 — Escrever a ficha da App Store.** Crie `foco/tool/ficha-app-store.txt`:

```text
NOME (max 30):        Foco: Organizador de Estudos
SUBTITULO (max 30):   Estude com meta e cronômetro
SKU:                  FOCO-2026-01
BUNDLE ID:            br.com.estudos.foco
PALAVRAS-CHAVE (100): estudo,foco,cronometro,materias,metas,produtividade,rotina
URL DE SUPORTE:       https://<seu-usuario>.github.io/foco/suporte.html
URL DE PRIVACIDADE:   https://<seu-usuario>.github.io/foco/privacidade.html
CONTA DE TESTE:       nao se aplica (o Foco nao exige login)
CLASSIFICACAO:        4+
PRECO:                Gratuito
```

Confirme o limite das palavras-chave:

```powershell
'estudo,foco,cronometro,materias,metas,produtividade,rotina'.Length
```

Resultado esperado: um número **menor ou igual a 100**.

**Passo 5 — Só se você tiver o programa pago e acesso a um Mac:** crie o registro do app no App
Store Connect, preencha tudo com esse arquivo, envie o build pelo Xcode e clique em enviar para
revisão.

**Como confirmar objetivamente que o envio funcionou:** o estado da versão no App Store Connect muda
para **"Aguardando revisão"** (*Waiting for Review*) e você recebe um e-mail da Apple confirmando o
recebimento do build.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/16-publicacao-e-proximos-passos.md](../../exercicios/16-publicacao-e-proximos-passos.md)

---

## 🏆 Desafio opcional

Estenda `tool/checar_info_plist.dart` para virar um **verificador de prontidão iOS** completo, que
rode no Windows e cheque, além dos textos de permissão:

1. Que `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` **existe**.
2. Que `CFBundleShortVersionString` vale `$(FLUTTER_BUILD_NAME)` e `CFBundleVersion` vale
   `$(FLUTTER_BUILD_NUMBER)` — se alguém tiver escrito um número fixo ali, a versão do
   `pubspec.yaml` deixa de valer e o aviso precisa aparecer.
3. Que `ios/Runner/SceneDelegate.swift` existe (o Flutter 3.47 gera esse arquivo; removê-lo quebra o
   app em iOS recente).
4. Que o bloco `UIApplicationSceneManifest` está presente no `Info.plist`.

Critério de conclusão: o script imprime uma linha `OK`/`FALHA` por item e termina com código `0`
quando tudo passa.

---

## 📌 Resumo

- 🪟 No Windows você preenche **tudo** no App Store Connect; **só o binário** exige macOS + Xcode.
- São três portais: **Apple Developer** (programa, Bundle ID, certificados), **App Store Connect**
  (ficha, versões, TestFlight) e **Xcode** (compilar e enviar — só no Mac).
- O registro do app pede nome único (30), idioma, **Bundle ID** já registrado e **SKU** interno.
- Versão: descrição (4.000), **palavras-chave em 100 caracteres no total**, URL de suporte e URL de
  política de privacidade **obrigatórias**.
- Capturas por **classe de tela**: iPhone 6,9" obrigatória; iPad 13" se o app aceita iPad. Sem alfa.
- O **ícone de 1024×1024 vem dentro do binário**, em `Icon-App-1024x1024@1x.png`, **sem canal alfa**.
- **Nutrition Label**: por tipo de dado, responda coleta / vinculado à identidade / rastreamento.
- A revisão é **humana**, em geral **< 24 h**, e avalia funcionamento, conteúdo, permissões e acesso.
- Rejeições clássicas: texto de permissão genérico, app incompleto, funcionalidade mínima e login
  obrigatório **sem conta de teste**.
- Rejeitado? Leia a diretriz, responda no **Resolution Center**, corrija e reenvie. Existe recurso
  formal no **App Review Board**.

---

## ☑️ Checklist de domínio

- [ ] Digo o que dá para fazer no Windows e o que exige macOS, sem inventar atalho para gerar `.ipa`.
- [ ] Explico a diferença entre Apple Developer, App Store Connect e Xcode.
- [ ] Listo os campos do registro do app e sei o que é o SKU.
- [ ] Sei que as palavras-chave somam **100 caracteres no total**, vírgulas incluídas.
- [ ] Digo quais classes de captura de tela são obrigatórias e por que não pode haver canal alfa.
- [ ] Explico de onde vem o ícone da App Store e por que `remove_alpha_ios: true` importa.
- [ ] Preencho a Nutrition Label do Foco e justifico cada resposta.
- [ ] Listo cinco coisas que a revisão humana da Apple checa.
- [ ] Reescrevo um texto de permissão genérico e comprovo a correção rodando o script.
- [ ] Sei o que fazer, em ordem, quando o app é rejeitado.

---

## 📚 Referências oficiais

- [App Store Connect — Ajuda](https://developer.apple.com/help/app-store-connect/)
- [Diretrizes de Revisão da App Store](https://developer.apple.com/app-store/review/guidelines/)
- [Especificações de capturas de tela](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/)
- [Especificação do ícone do app](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Detalhes de privacidade do app (App Privacy)](https://developer.apple.com/app-store/app-privacy-details/)
- [Apple Developer Program](https://developer.apple.com/programs/)
- [Flutter — Build and release an iOS app](https://docs.flutter.dev/deployment/ios)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Google Play](01-google-play.md) | [README](README.md) | [Versionamento e releases](03-versionamento-e-releases.md) |
