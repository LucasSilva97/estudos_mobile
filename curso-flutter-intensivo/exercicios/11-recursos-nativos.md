# Exercícios — Módulo 11: Recursos nativos

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Rode `flutter analyze` na pasta `foco_nativo` antes de consultar o gabarito. E01–E04 precisam de aparelho ou emulador 🤖 Android para o comportamento real; os demais rodam no Windows.

<a id="m11-e01"></a>
## M11-E01 — Cinco estados de permissão · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Tratar todo estado sem tela morta | Fácil | 15 min | Sim |
Escreva um `switch` exaustivo sobre `ResultadoPermissao` (`concedida`, `negada`, `negadaParaSempre`, `bloqueadaPeloSistema`, `parcial`) devolvendo o texto e o rótulo do botão que a tela mostra em cada caso. **Esperado:** nenhum `default`, e só `negadaParaSempre` leva a `abrirAjustes()`. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e01)

<a id="m11-e02"></a>
## M11-E02 — Manifesto fora do lugar · Correção de bugs
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Declarar permissão no nível certo | Fácil | 15 min | Sim |
No `android/app/src/main/AndroidManifest.xml` do `foco_nativo`, a tag `<uses-permission android:name="android.permission.CAMERA"/>` está dentro de `<application>`. Mova para onde ela pertence e explique por que o build passa mesmo assim. **Teste:** `Permission.camera.request()` passa a mostrar a caixa do sistema em vez de devolver `negadaParaSempre` na primeira chamada. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e02)

<a id="m11-e03"></a>
## M11-E03 — Trocar a capa da matéria · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Tratar cancelamento e arquivo antigo | Média | 25 min | Sim |
Em `CapaMateriaScreen`, use `ServicoImagens.escolherDaGaleria()` e `guardarComoCapa(origem, idMateria)` para substituir a capa: se vier `null`, não altere nada; se vier um `XFile`, salve o novo e apague o anterior com `removerCapa`. **Esperado:** cancelar o seletor não apaga a capa que já existia. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e03)

<a id="m11-e04"></a>
## M11-E04 — O que `XFile` entrega · Leitura de código
Leia `tirarFoto()` em `ServicoImagens` e responda por escrito: por que o retorno é `XFile?` e não `File?`; o que `imageQuality: 85` e `maxWidth: 1600` fazem antes de o arquivo chegar ao Dart; por que copiar para `getApplicationDocumentsDirectory()` é obrigatório. **Esperado:** três parágrafos curtos, um por pergunta. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e04)

<a id="m11-e05"></a>
## M11-E05 — Onde o backup pode morar · Compreensão
Explique por escrito por que `ServicoDeBackup.gerar()` grava em `documentos/backups` sem pedir permissão nenhuma, por que gravar direto na pasta Downloads do 🤖 Android seria outra conversa com o sistema, e o que acontece com esses arquivos na desinstalação. **Esperado:** meia página usando "sandbox" e "escopo de armazenamento" corretamente. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e05)

<a id="m11-e06"></a>
## M11-E06 — Mapa das pastas nativas · Localização
Aponte o caminho completo, a partir da raiz do `foco_nativo`, de onde se configura: `applicationId`, `minSdk`, `<uses-permission>`, `NSCameraUsageDescription` e o nome exibido do app no Android. Marque cada arquivo como versionado ou não. **Esperado:** `android/local.properties` e `ios/Flutter/Generated.xcconfig` saem como **não** versionados; `ios/Podfile.lock` sai como versionado. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e06)

<a id="m11-e07"></a>
## M11-E07 — Cronômetro que mente · Correção de bugs
Um `CronometroController` soma 1 a cada disparo de `Timer.periodic`. Quando o app vai para `paused`, o timer congela e quem estudou 30 min vê 3. Reescreva sobre `SessaoEmAndamento`, calculando `decorrido` a partir de `iniciadaEm` e do relógio, e salve em `paused` pelo `ObservadorDeCiclo`. **Teste:** altere `iniciadaEm` para 40 min atrás e confira que `minutos` devolve 40. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e07)

<a id="m11-e08"></a>
## M11-E08 — Lembrete local ou push · Decisão
O Foco precisa avisar (a) "você não estudou hoje" às 21h e (b) "um colega convidou você para um grupo de estudo". Decida local ou push para cada um e justifique em 3–5 frases, dizendo quem dispara o evento e o que exige backend. **Esperado:** resposta escrita, sem código, concluindo local em (a) e push em (b). [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e08)

<a id="m11-e09"></a>
## M11-E09 — Banner de rede · Aplicação
Ligue `ObservadorDeRede.observar()` a um `StreamProvider<LeituraDeRede>` e mostre `BannerDeRede` no topo do `Scaffold` só quando `estado == EstadoDeRede.semInterface`, com o texto vindo de `TipoDeConexao.rotulo`. **Teste:** com o app em `flutter run -d windows`, desligue o Wi-Fi do PC — o banner aparece sem recarregar a tela. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e09)

<a id="m11-e10"></a>
## M11-E10 — Portal cativo · Compreensão
Explique por escrito por que `EstadoDeRede.comInterface` não autoriza o app a afirmar "você está online", descreva o Wi-Fi de hotel que exige login no navegador, e diga quando vale pagar o custo de `verificarDeVerdade()`. **Esperado:** você conclui que só `certamenteOffline` é base segura para decisão. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e10)

<a id="m11-e11"></a>
## M11-E11 — Usuário preso no formulário · Correção de bugs
`MateriaFormScreen` usa `PopScope(canPop: false)` sem `onPopInvokedWithResult`: o voltar não faz nada e só matar o app sai da tela. Corrija com `canPop` derivado de "há alterações não salvas?" e um diálogo com **Descartar** e **Continuar editando**. **Esperado:** formulário sem alterações sai no primeiro toque, sem diálogo. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e11)

<a id="m11-e12"></a>
## M11-E12 — Adotar ou escrever · Avaliação
Aplique o checklist de 10 itens da aula 10 a `share_plus` e a um pacote de "formatação de duração" do pub.dev. Entregue uma tabela com os 10 itens, o veredicto de cada um e a decisão final. **Esperado:** o pacote de duração reprova no item 2 e você escreve a `extension` no `core/` em vez de depender dele. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e12)

<a id="m11-e13"></a>
## M11-E13 — `Platform.isIOS` na web · Correção de bugs
`MateriaCard` escolhe o ícone com `Platform.isIOS` importado de `dart:io`. O app compila, publica e lança `Unsupported operation: Platform._operatingSystem` no primeiro usuário que abrir no navegador. Troque por `Plataforma.ehApple(context)` e explique por que o erro só aparece em execução. **Teste:** `flutter run -d chrome` abre a tela sem exceção. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e13)

<a id="m11-e14"></a>
## M11-E14 — Saída segura nas duas plataformas · Desafio
Integre `CamadasDeVoltar`, `confirmarAdaptativo` e `BotaoAdaptativo` em `MateriaFormScreen`: o voltar fecha primeiro a folha de opções aberta, depois pergunta o descarte com o diálogo que cada plataforma espera, e salvar usa `EnfaseDoBotao.primaria`. **Esperado:** nenhum caminho deixa o usuário sem saída, nada usa `dart:io`, e `flutter analyze` termina com `No issues found!`. [🔑 Gabarito](../gabaritos/11-recursos-nativos.md#m11-e14)

[Módulo](../modulos/11-recursos-nativos/README.md)
