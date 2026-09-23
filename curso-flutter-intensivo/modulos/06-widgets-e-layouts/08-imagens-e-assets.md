# Aula 8 — Imagens e assets

> **Módulo:** 06 - Widgets e Layouts · **Tempo estimado:** 40 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

Ao final desta aula você será capaz de:

- Declarar **assets** no `pubspec.yaml` com a indentação exata — e diagnosticar o erro que 9 em cada
  10 pessoas cometem aqui.
- Exibir imagens com `Image.asset`, `Image.network` e `Image.file`, sabendo quando cada uma serve.
- Fornecer variantes de resolução (`2.0x`, `3.0x`) e entender por que telas de celular precisam disso.
- Tratar os dois estados invisíveis de uma imagem de rede: **carregando** (`loadingBuilder`) e
  **falhou** (`errorBuilder`).
- Reduzir o consumo de memória de imagens grandes com `cacheWidth`.
- Declarar e usar uma **fonte customizada**.
- Saber por que ícone do app e splash screen **não** se resolvem aqui.

## ✅ Pré-requisitos

- [Aula 7 — Cores, temas e modo escuro](07-cores-temas-modo-escuro.md), com `TemaApp` funcionando.
- Noção de `Future` ([04 — Futures e async/await](../04-dart-avancado/02-futures-e-async-await.md)).
- Saber editar YAML sem quebrar a indentação
  ([05 — Estrutura do projeto](../05-introducao-ao-flutter/02-estrutura-do-projeto.md)).

---

## 📖 Conceito

### O que é um asset

**Asset** (literalmente "ativo") é qualquer arquivo que acompanha o aplicativo e é empacotado junto
com ele: imagens, fontes, arquivos JSON, sons. Ele vai dentro do APK/IPA e fica disponível mesmo sem
internet.

Um asset **não** é:

- uma imagem baixada da internet em tempo de execução (isso é `Image.network`);
- um arquivo que o usuário escolheu da galeria (isso é `Image.file`, assunto do
  [Módulo 11](../11-recursos-nativos/02-camera-e-galeria.md)).

### Declarando assets no `pubspec.yaml` — a parte que dá errado

O Flutter **só** empacota o que estiver declarado. E a declaração é em YAML, um formato onde a
**indentação faz parte da sintaxe**.

Estrutura correta, com o número exato de espaços:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/imagens/
    - assets/imagens/capa_estudo.png
```

Contando os espaços, da esquerda:

| Linha | Espaços à esquerda | Observação |
|---|---|---|
| `flutter:` | **0** | Chave de primeiro nível |
| `uses-material-design: true` | **2** | Dentro de `flutter:` |
| `assets:` | **2** | Dentro de `flutter:` — o mesmo nível de `uses-material-design` |
| `- assets/imagens/` | **4** | Item da lista, com hífen e um espaço depois |

Três regras que evitam quase todos os erros:

1. **Só espaços. Nunca `Tab`.** YAML rejeita tabulação. O VS Code pode estar convertendo — verifique.
2. **`assets:` fica dentro de `flutter:`**, não na raiz do arquivo. Existe um `dependencies:` na raiz
   e é fácil colar no lugar errado.
3. **Caminho terminado em `/` inclui a pasta inteira**, mas **não** as subpastas. Para incluir
   `assets/imagens/icones/`, declare essa subpasta também.

Depois de editar o `pubspec.yaml`, sempre:

```powershell
flutter pub get
```

E, se a imagem ainda não aparecer, **pare o app e rode de novo**. Alterações em assets nem sempre
sobrevivem ao *hot reload*, porque o pacote de assets é montado na compilação.

### `Image.asset`

```dart
Image.asset(
  'assets/imagens/capa_estudo.png',
  width: double.infinity,
  height: 160,
  fit: BoxFit.cover,
)
```

Os valores de `fit` (`BoxFit`), que decidem como a imagem se encaixa na caixa:

| Valor | Comportamento |
|---|---|
| `BoxFit.cover` | Preenche a caixa toda, **cortando** o que sobrar. É o mais usado em capas |
| `BoxFit.contain` | Cabe inteira dentro da caixa, **deixando espaço** nas bordas |
| `BoxFit.fill` | Estica para preencher, **distorcendo** a imagem. Evite |
| `BoxFit.fitWidth` | Ajusta pela largura |
| `BoxFit.fitHeight` | Ajusta pela altura |
| `BoxFit.none` | Tamanho original, cortado se não couber |
| `BoxFit.scaleDown` | Como `contain`, mas nunca aumenta |

### Resolução: `2.0x` e `3.0x`

Uma tela de celular moderna tem 2 ou 3 pixels físicos para cada pixel lógico. Uma imagem de 100 × 100
pixels ocupando 100 × 100 dp fica **borrada** numa tela 3x, porque o sistema precisa esticá-la.

O Flutter resolve isso com uma convenção de pastas:

```text
assets/
└── imagens/
    ├── capa_estudo.png          ← 1.0x  (ex.: 400 × 160)
    ├── 2.0x/
    │   └── capa_estudo.png      ← 2.0x  (800 × 320)
    └── 3.0x/
        └── capa_estudo.png      ← 3.0x  (1200 × 480)
```

No código você continua escrevendo **apenas** `'assets/imagens/capa_estudo.png'`. O Flutter escolhe a
variante certa em tempo de execução, conforme a densidade da tela.

No `pubspec.yaml`, declarar a pasta (`- assets/imagens/`) já inclui as variantes automaticamente.

### `Image.network` e os dois estados invisíveis

```dart
Image.network('https://exemplo.com/capa.png')
```

Essa linha é honesta na aparência e desonesta na prática, porque ignora duas coisas que **vão**
acontecer:

1. A imagem demora para chegar (rede lenta, 3G, elevador).
2. A imagem **não chega** (404, servidor fora do ar, sem internet).

Sem tratamento, o usuário vê um buraco branco no primeiro caso e um ícone quebrado no segundo. A
versão correta:

```dart
Image.network(
  url,
  fit: BoxFit.cover,
  loadingBuilder: (BuildContext context, Widget filho, ImageChunkEvent? progresso) {
    if (progresso == null) return filho;   // terminou de carregar
    return const Center(child: CircularProgressIndicator());
  },
  errorBuilder: (BuildContext context, Object erro, StackTrace? pilha) {
    return const Center(child: Icon(Icons.broken_image_outlined));
  },
)
```

Repare no `if (progresso == null) return filho;`: quando o carregamento termina, o Flutter chama o
`loadingBuilder` uma última vez com `progresso` nulo, e aí você devolve a imagem pronta.

Se você quiser mostrar a porcentagem:

```dart
final int? total = progresso.expectedTotalBytes;
final double? valor = total == null
    ? null
    : progresso.cumulativeBytesLoaded / total;
return Center(child: CircularProgressIndicator(value: valor));
```

`value: null` no `CircularProgressIndicator` produz a animação **indeterminada** (roda sem fim) —
correta quando o servidor não informa o tamanho total.

### `Image.file`

Exibe uma imagem do sistema de arquivos do aparelho:

```dart
Image.file(File(caminhoNoAparelho))
```

Você usa isso depois de tirar uma foto ou escolher da galeria. Exige o pacote `image_picker` e
permissões de plataforma — é o [Módulo 11](../11-recursos-nativos/02-camera-e-galeria.md). Fica citado
aqui para você saber que existe.

### `cacheWidth`: o parâmetro que salva memória

Uma foto de 4000 × 3000 pixels ocupa, descomprimida na memória, cerca de **48 MB** — mesmo que você a
desenhe num quadradinho de 100 × 100. O Flutter descomprime a imagem inteira antes de reduzir.

`cacheWidth` manda decodificar já no tamanho reduzido:

```dart
Image.asset(
  'assets/imagens/capa_estudo.png',
  cacheWidth: 800,   // decodifica com 800 pixels de largura
  fit: BoxFit.cover,
)
```

Regra prática: informe `cacheWidth` sempre que a imagem de origem for **muito maior** que o espaço
onde ela aparece — especialmente em listas. Esse é um dos maiores ganhos de desempenho disponíveis, e
o [Módulo 13](../13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md) volta ao assunto com
medições.

### Fontes customizadas

Fonte também é asset, mas tem um bloco próprio no `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fontes/Inter-Regular.ttf
        - asset: assets/fontes/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fontes/Inter-Bold.ttf
          weight: 700
```

E, no tema:

```dart
ThemeData(
  colorScheme: cores,
  fontFamily: 'Inter',   // o mesmo nome declarado em `family`
)
```

O nome em `family` é **escolhido por você** e precisa bater exatamente com o `fontFamily`. Cada peso
(`weight`) é um arquivo diferente; se você declarar só o regular e pedir negrito, o Flutter "engrossa"
artificialmente a fonte e o resultado fica feio.

> Onde conseguir a fonte: baixe em [fonts.google.com](https://fonts.google.com) (licença aberta),
> descompacte e copie os arquivos `.ttf` para `assets/fontes/`. Existe também o pacote
> `google_fonts`, que baixa a fonte em tempo de execução — não usado neste curso, porque adiciona uma
> dependência de rede ao primeiro uso.

### O que **não** é assunto desta aula

**Ícone do aplicativo** (aquele que aparece na tela inicial do celular) e **splash screen** (a tela
que aparece enquanto o app abre) **não** são imagens dentro do `pubspec.yaml`: são arquivos das
plataformas nativas, em `android/app/src/main/res/` e em
`ios/Runner/Assets.xcassets/AppIcon.appiconset`. Eles são gerados pelos pacotes
`flutter_launcher_icons` e `flutter_native_splash`, no
[Módulo 15 — Ícone](../15-build-android/03-icone.md) e
[Módulo 15 — Splash screen](../15-build-android/04-splash-screen.md).

---

## 💡 Analogia

Pense na **mala de viagem** do app.

O `pubspec.yaml` é a lista de bagagem. O que não está na lista **não entra na mala**, por mais que
esteja em cima da cama. É por isso que a imagem existe na sua pasta e o app diz que não a encontrou.

As pastas `2.0x` e `3.0x` são a mesma roupa em tamanhos diferentes: você leva as três, e na chegada
veste a que servir naquele corpo (naquela tela).

`Image.network` é o contrário: a roupa não está na mala, você vai comprar quando chegar. Pode demorar,
e a loja pode estar fechada — por isso você precisa de um plano B (`errorBuilder`).

---

## 🧪 Exemplo mínimo

Crie a pasta e coloque **qualquer** arquivo PNG seu com o nome `capa_estudo.png`:

```powershell
mkdir assets\imagens
```

`pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/imagens/
```

```powershell
flutter pub get
```

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ExemploImagem()));

class ExemploImagem extends StatelessWidget {
  const ExemploImagem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/imagens/capa_estudo.png',
          width: 240,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
```

Se aparecer `Unable to load asset`, volte ao `pubspec.yaml` e conte os espaços.

---

## 📱 Aplicando no Flutter

No Foco, vamos:

1. Criar as pastas `assets/imagens/` e `assets/fontes/` e declará-las no `pubspec.yaml`.
2. Dar ao `CartaoDestaque` uma **imagem de fundo local** sob o gradiente da
   [Aula 5](05-stack-e-positioned.md).
3. Trocar a faixa azul do banner de trilha por uma **imagem de rede** com `loadingBuilder` e
   `errorBuilder` de verdade.

**Sobre a imagem de exemplo:** use qualquer PNG ou JPG que você tenha (uma foto, um papel de parede),
renomeado para `capa_estudo.png`. O conteúdo não importa para a aula; o caminho, sim.

**Sobre a URL de rede:** vamos usar de propósito um endereço que **não existe** no servidor público de
testes do curso:

```text
https://jsonplaceholder.typicode.com/img/capa-trilha.png
```

O `jsonplaceholder.typicode.com` responde a requisições de JSON, mas **não serve imagens nesse
caminho** — então a requisição falha. Isso é intencional: você vai ver o `errorBuilder` funcionando,
que é o estado que ninguém testa e que acontece na vida real. Depois, troque por uma URL de imagem
HTTPS que você tenha e veja o caminho feliz.

```powershell
mkdir assets\imagens
mkdir assets\fontes
```

---

## 💻 Código completo

> **Arquivo:** `pubspec.yaml`
> **Como executar:** `flutter pub get` e depois `flutter run -d windows`

Localize a seção `flutter:` (perto do fim do arquivo) e deixe-a assim:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/imagens/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fontes/Inter-Regular.ttf
        - asset: assets/fontes/Inter-SemiBold.ttf
          weight: 600
```

> Se você ainda não baixou a fonte, **apague o bloco `fonts:` inteiro** por enquanto. Declarar uma
> fonte cujo arquivo não existe faz o `flutter run` falhar com
> `Error: unable to locate asset entry`.

> **Arquivo:** `lib/features/materias/presentation/widgets/cartao_destaque.dart`
> **Como executar:** `flutter run -d windows`

No `Stack` do `build`, substitua a camada do ícone decorativo (aquele `Positioned` com
`Icons.timer_outlined`) por estas **duas** camadas:

```dart
          // Camada 1 (fundo): a imagem local, cobrindo o cartão inteiro.
          Positioned.fill(
            child: Image.asset(
              'assets/imagens/capa_estudo.png',
              fit: BoxFit.cover,
              cacheWidth: 1000,
              errorBuilder: (BuildContext context, Object erro, StackTrace? pilha) {
                // Se o asset não existir, o cartão continua utilizável.
                return ColoredBox(color: cores.primaryContainer);
              },
            ),
          ),

          // Camada 2: véu escuro para o texto ficar legível sobre qualquer foto.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.70),
                    ],
                  ),
                ),
              ),
            ),
          ),
```

E troque, nos textos do cartão, `cores.onPrimaryContainer` por `Colors.white` — agora o fundo é uma
foto escurecida, não mais o `primaryContainer`.

> **Arquivo:** `lib/features/materias/presentation/home_screen.dart`
> **Como executar:** `flutter run -d windows`

No banner da trilha (criado no exercício guiado da [Aula 5](05-stack-e-positioned.md)), troque a
camada 1 — `Container(height: 160, color: Colors.indigo)` — por:

```dart
                    // Camada 1: imagem vinda da rede, com os dois estados tratados.
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: Image.network(
                        'https://jsonplaceholder.typicode.com/img/capa-trilha.png',
                        fit: BoxFit.cover,
                        loadingBuilder: (
                          BuildContext context,
                          Widget filho,
                          ImageChunkEvent? progresso,
                        ) {
                          if (progresso == null) {
                            return filho;
                          }
                          final int? total = progresso.expectedTotalBytes;
                          return ColoredBox(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: total == null
                                    ? null
                                    : progresso.cumulativeBytesLoaded / total,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (
                          BuildContext context,
                          Object erro,
                          StackTrace? pilha,
                        ) {
                          final ColorScheme cores = Theme.of(context).colorScheme;
                          return ColoredBox(
                            color: cores.surfaceContainerHighest,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: cores.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Capa indisponível',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
```

Rode:

```powershell
flutter pub get
flutter run -d windows
```

Você deve ver: o cartão de destaque com a sua imagem de fundo escurecida e texto branco legível; e o
banner da trilha mostrando "Capa indisponível" com ícone — o `errorBuilder` em ação.

---

## 🔍 Explicando o código

**`Positioned.fill(child: Image.asset(...))`** — a imagem preenche o `Stack` inteiro. Como o cartão já
tem `clipBehavior: Clip.antiAlias`, ela respeita os cantos arredondados.

**`cacheWidth: 1000`** — se a sua imagem original tiver 4000 pixels de largura, o Flutter decodifica
em 1000 e economiza cerca de 90 % da memória daquela imagem. O valor deve ser próximo da maior
largura em que a imagem vai aparecer.

**`errorBuilder` no `Image.asset`** — sim, asset também pode falhar: nome errado, arquivo corrompido,
declaração ausente no `pubspec.yaml`. Devolver uma cor sólida mantém o cartão utilizável em vez de
derrubar a tela. Isso é o que diferencia um app resistente de um app frágil.

**Gradiente de `0.25` a `0.70` de preto** — dois véus em vez de um. O topo fica levemente escurecido
(para o texto pequeno) e a base bem escurecida (para o número grande). Com um véu uniforme, ou a foto
some ou o texto some.

**`if (progresso == null) return filho;`** — o contrato do `loadingBuilder`. O `filho` é a própria
imagem já pronta; devolver outra coisa nesse momento faria a imagem nunca aparecer.

**`progresso.cumulativeBytesLoaded / total`** — a fração baixada, entre 0 e 1, que o
`CircularProgressIndicator` usa para desenhar o arco. Quando o servidor não envia
`Content-Length`, `expectedTotalBytes` vem nulo e passamos `null`, que aciona a animação infinita.

**`errorBuilder` com ícone **e** texto** — repare que não confiamos só no ícone. Uma pessoa usando
leitor de tela, ou que não reconheça aquele símbolo, precisa da frase "Capa indisponível". Esse é o
mesmo princípio de "cor nunca é a única informação" da [Aula 7](07-cores-temas-modo-escuro.md).

**`SizedBox(height: 160, width: double.infinity)` em volta do `Image.network`** — a imagem ainda não
chegou, então ela **não tem tamanho**. Sem uma caixa definida, o banner ficaria com altura zero, e
depois pularia para 160 quando a imagem carregasse. Definir a altura antes evita o "salto" de layout.

---

## ⚠️ Erros comuns

**1. `Unable to load asset: "assets/imagens/capa_estudo.png"`**

```text
══╡ EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE ╞══════════════════════
Unable to load asset: "assets/imagens/capa_estudo.png".
The asset does not exist or has empty data.
```

Percorra esta lista, nesta ordem:

1. O caminho no código bate **exatamente** com o caminho real? Windows não diferencia maiúsculas, mas
   Android e iOS **diferenciam**. `Capa_Estudo.PNG` ≠ `capa_estudo.png`.
2. A pasta está declarada em `assets:` no `pubspec.yaml`?
3. A indentação está com **espaços**, 2 para `assets:` e 4 para os itens?
4. Você rodou `flutter pub get` depois de editar?
5. Você **parou e rodou o app de novo**? *Hot reload* não reconstrói o pacote de assets.

**2. Indentação errada no `pubspec.yaml`**

```text
Error detected in pubspec.yaml:
Expected a key while parsing a block mapping.
```

ou, pior, nenhum erro — e o asset simplesmente não entra. Compare com o exemplo desta aula, contando
os espaços.

**3. `Tab` no YAML**

```text
Error on line 62, column 3: The pubspec.yaml file is not a valid YAML map.
```

No VS Code, com o arquivo aberto, clique em "Espaços: 2" na barra inferior → **Converter indentação em
espaços**.

**4. `Error: unable to locate asset entry in pubspec.yaml: "assets/fontes/Inter-Regular.ttf"`**

Você declarou a fonte mas não copiou o arquivo. Ou copie, ou remova a declaração.

**5. Imagem de rede sem `errorBuilder`**

Em modo de depuração aparece uma exceção vermelha; em release, um espaço vazio. Nos dois casos o
usuário não entende o que houve. Toda `Image.network` deste curso tem `errorBuilder`.

**6. Imagem gigante em lista**

Sintoma: a rolagem trava e o consumo de memória dispara. Causa: imagens de câmera (12 MP) sendo
decodificadas inteiras em miniaturas. Solução: `cacheWidth`.

**7. Esquecer que asset pesa no tamanho do app**

Cada imagem entra no APK/AAB. Um app de estudo com 30 MB de fotos decorativas é um app que ninguém
instala no 4G. Prefira imagens comprimidas e, quando fizer sentido, busque da rede com cache.

---

## 🛠️ Exercício guiado

Vamos provar, com os olhos, que a variante de resolução funciona.

**Passo 1.** Crie as pastas de variante:

```powershell
mkdir assets\imagens\2.0x
mkdir assets\imagens\3.0x
```

**Passo 2.** Coloque **três versões visivelmente diferentes** da imagem, com o **mesmo nome**:

- `assets/imagens/capa_estudo.png` — uma imagem qualquer, por exemplo predominantemente **azul**;
- `assets/imagens/2.0x/capa_estudo.png` — outra, predominantemente **verde**;
- `assets/imagens/3.0x/capa_estudo.png` — outra, predominantemente **vermelha**.

(Em produção as três seriam a mesma arte em tamanhos diferentes. Aqui usamos cores diferentes só para
enxergar qual foi escolhida.)

**Passo 3.** Rode `flutter pub get`, pare o app e inicie de novo:

```powershell
flutter pub get
flutter run -d windows
```

**Passo 4.** Observe qual cor apareceu. No Windows, com escala de exibição em 100 %, você deve ver a
**azul** (1.0x). Mude a escala do Windows para 200 % (Configurações → Sistema → Tela → Escala), feche
e rode o app de novo: aparece a **verde** (2.0x).

**Passo 5.** Se tiver um emulador Android de tela densa, rode nele e veja a **vermelha** (3.0x).

**O que observar:** o caminho no código **nunca mudou**. Foi sempre
`'assets/imagens/capa_estudo.png'`. A escolha da variante é responsabilidade do Flutter, com base na
densidade real da tela — e é isso que evita imagens borradas sem você escrever nenhum `if`.

**Resultado esperado:** você consegue explicar, para outra pessoa, por que existe uma pasta `2.0x` e
por que ela não aparece em lugar nenhum do código Dart.

---

## 📝 Exercícios independentes

→ Exercícios completos em [exercicios/06-widgets-e-layouts.md](../../exercicios/06-widgets-e-layouts.md)

Faça o exercício de **Correção de bugs** do `pubspec.yaml` com indentação errada — é o erro que mais
custa tempo na vida real.

---

## 🏆 Desafio opcional

Crie um widget `ImagemDeCapa` reutilizável que resolva os três casos de uma vez:

1. Recebe `urlRemota` (`String?`) e `assetReserva` (`String`).
2. Se `urlRemota` for nula ou vazia, mostra direto o asset.
3. Se houver URL, usa `Image.network` com `loadingBuilder` (esqueleto cinza animado, não um
   *spinner*) e `errorBuilder` que **cai para o asset de reserva**.
4. Aceita `altura` e aplica `cacheWidth` calculado a partir da largura da tela vezes a densidade
   (`MediaQuery.devicePixelRatioOf(context)`).
5. Tem construtor `const` sempre que possível e `{super.key}`.
6. Use-o no `CartaoDestaque` e no banner de trilha, eliminando a duplicação de código.

Critério de sucesso: derrubar a internet (modo avião) e o app continuar mostrando capas, sem nenhuma
exceção no console.

---

## 📌 Resumo

- Asset é arquivo empacotado com o app. **Só entra o que está declarado no `pubspec.yaml`.**
- A indentação é sintaxe: `flutter:` na coluna 0, `assets:` com 2 espaços, itens com 4 e hífen.
  Espaços, nunca `Tab`. Rode `flutter pub get` e reinicie o app.
- `Image.asset` (empacotada), `Image.network` (rede), `Image.file` (arquivo do aparelho).
- `fit: BoxFit.cover` preenche cortando; `contain` cabe inteira; `fill` distorce.
- Variantes `2.0x/` e `3.0x/` com o mesmo nome de arquivo; o caminho no código não muda.
- Toda imagem de rede precisa de `loadingBuilder` **e** `errorBuilder`. Reserve a altura antes para
  não haver salto de layout.
- `cacheWidth` decodifica a imagem já reduzida e economiza memória — essencial em listas.
- Fontes vão no bloco `fonts:` com um arquivo por peso, e o `family` deve bater com o `fontFamily` do
  tema.
- Ícone do app e splash screen **não** são assets: são configuração nativa, no Módulo 15.

---

## ☑️ Checklist de domínio

- [ ] Escrevo o bloco `assets:` do `pubspec.yaml` de memória, com a indentação certa.
- [ ] Sei os cinco passos de diagnóstico do erro `Unable to load asset`.
- [ ] Explico a diferença entre `BoxFit.cover` e `BoxFit.contain` com um exemplo.
- [ ] Sei por que existem as pastas `2.0x` e `3.0x` e por que o código não as menciona.
- [ ] Toda `Image.network` do meu app tem `loadingBuilder` e `errorBuilder`.
- [ ] Reservo altura antes de a imagem chegar, para evitar salto de layout.
- [ ] Uso `cacheWidth` quando a imagem original é muito maior que o espaço de exibição.
- [ ] Declarei uma fonte customizada e ela aparece (ou removi o bloco corretamente).
- [ ] Sei que ícone e splash ficam para o Módulo 15 e por quê.
- [ ] `flutter analyze` passa sem avisos.

---

## 📚 Referências oficiais

- [Flutter — Assets e imagens](https://docs.flutter.dev/ui/assets/assets-and-images)
- [API — `Image`](https://api.flutter.dev/flutter/widgets/Image-class.html)
- [API — `Image.network`](https://api.flutter.dev/flutter/widgets/Image/Image.network.html)
- [API — `BoxFit`](https://api.flutter.dev/flutter/painting/BoxFit.html)
- [API — `ImageChunkEvent`](https://api.flutter.dev/flutter/painting/ImageChunkEvent-class.html)
- [Flutter — Fontes customizadas](https://docs.flutter.dev/cookbook/design/fonts)
- [Flutter — `pubspec.yaml`](https://docs.flutter.dev/tools/pubspec)
- [Google Fonts](https://fonts.google.com)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [Aula 7 — Cores, temas e modo escuro](07-cores-temas-modo-escuro.md) | [README](README.md) | [Aula 9 — Listas e rolagem](09-listas-e-rolagem.md) |
