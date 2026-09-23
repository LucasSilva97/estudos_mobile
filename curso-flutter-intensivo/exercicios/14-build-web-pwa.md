# Exercícios — Módulo 14: Build e distribuição Web (PWA)

> Faça E01–E08 obrigatoriamente. E09–E14 são opcionais. Comece todo exercício de build com `flutter clean` e `flutter pub get`, e confira o resultado **servindo os arquivos de uma subpasta** — nunca só com `flutter run -d chrome` — antes de consultar o gabarito.

<a id="m14-e01"></a>
## M14-E01 — Os três requisitos · Fixação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Saber o que transforma um site em PWA | Fácil | 20 min | Sim |
Liste os três requisitos técnicos de um PWA e, para cada um, diga **qual deles o Flutter já entrega sozinho** e qual depende de você. Depois abra o painel `Application → Manifest → Installability` no Foco servido em `localhost` e registre o estado de cada um dos 8 critérios. **Esperado:** você identifica que HTTPS vem da hospedagem, o service worker vem do `flutter build web`, e que o único trabalho real é preencher o `manifest.json`. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e01)

<a id="m14-e02"></a>
## M14-E02 — O que o build produz · Leitura de código
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Entender a saída de `flutter build web` | Fácil | 25 min | Sim |
Rode `flutter build web --release` no Foco e monte uma tabela com os 8 maiores arquivos de `build/web/`, o tamanho de cada um e o papel de cada um. Some separadamente o que é baixado **antes do primeiro quadro** e o que desce sob demanda. **Esperado:** `main.dart.js` e `canvaskit.wasm` concentram ~99 % do caminho crítico, e você explica em uma frase por que medir a pasta inteira infla o número e leva à conclusão errada. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e02)

<a id="m14-e03"></a>
## M14-E03 — `Platform.isIOS` na web · Correção de bugs
O `CartaoMateria` decide o ícone com `Platform.isIOS`, importado de `dart:io`. O app **compila**, publica e lança `Unsupported operation: Platform._operatingSystem` no primeiro usuário que abre no navegador. Corrija usando `Plataforma.ehApple(context)` do [Módulo 11](../modulos/11-recursos-nativos/09-material-x-cupertino.md) e explique por escrito por que o compilador não avisou nada. **Teste:** `flutter run -d chrome` abre a tela sem exceção, e `flutter test --platform chrome` passa. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e03)

<a id="m14-e04"></a>
## M14-E04 — O banco do Foco no navegador · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Rodar `sqflite` na web sem reescrever DAO | Média | 45 min | Sim |
Adicione `sqflite_common` e `sqflite_common_ffi_web`, rode `dart run sqflite_common_ffi_web:setup`, crie os três arquivos `factory_banco*.dart` por importação condicional e altere `BancoFoco.abrir()` para usar a factory. **Teste:** o Foco cria matérias e sessões no Chrome, os dados sobrevivem a um F5, `sqflite_databases` aparece em `Application → IndexedDB`, e **nenhum arquivo de `domain/` ou `presentation/` foi alterado** — confirme com `git diff --stat`. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e04)

<a id="m14-e05"></a>
## M14-E05 — Identidade de verdade · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Preencher o manifest e gerar ícones maskable | Média | 40 min | Sim |
Acrescente o bloco `web:` ao `flutter_launcher_icons`, ligue `web: true` no `flutter_native_splash`, rode os dois geradores e **depois** preencha `web/manifest.json` com `id`, `name`, `short_name`, `description`, `start_url`, `scope`, `lang` e quatro entradas de `icons` (`any` e `maskable`, 192 e 512). **Teste:** o painel `Application → Manifest` mostra os seus valores, marca ao menos um ícone como maskable, o desenho cabe na zona segura com "Show only the minimum safe area" ligado, e o diálogo de instalação exibe o nome completo em vez de `foco`. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e05)

<a id="m14-e06"></a>
## M14-E06 — O usuário preso na versão antiga · Diagnóstico
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Entender o ciclo do service worker | Média | 30 min | Sim |
Reproduza o problema de propósito: sirva o Foco, mude um texto visível, recompile, recarregue uma vez (versão antiga) e recarregue de novo (versão nova). Depois explique, em ordem, o que aconteceu em `install`, `activate` e `fetch`, e diga **por que isso não é um bug**. **Esperado:** você descreve que a página é servida do cache enquanto o service worker baixa e ativa a versão nova em paralelo, e identifica "Update on reload" como ferramenta de desenvolvimento que **mascara** o comportamento real. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e06)

<a id="m14-e07"></a>
## M14-E07 — Tela branca no deploy · Correção de bugs
O Foco funciona em `flutter run -d chrome` e, publicado em `usuario.github.io/foco/`, abre **totalmente branco**. O Console mostra `GET https://usuario.github.io/main.dart.js 404 (Not Found)`. Diagnostique, corrija e explique por que o problema não aparecia localmente. **Teste:** depois de recompilar com o caminho certo, `build/web/index.html` contém `<base href="/foco/">`, a página carrega, e você registra por que foi necessário **Ctrl+Shift+R** em vez de F5 para ver a correção. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e07)

<a id="m14-e08"></a>
## M14-E08 — O Foco no ar · Aplicação
| Objetivo | Dificuldade | Tempo | Obrigatório? |
|---|---|---:|---|
| Publicar com deploy automatizado | Difícil | 60 min | Sim |
Crie o repositório público, configure `Settings → Pages → Source = GitHub Actions` e escreva o workflow `publicar-web.yml` com os três portões (`analyze`, `test`, `test --platform chrome`), o build com `--base-href` e `--no-web-resources-cdn`, a cópia do `404.html` e as conferências do artefato. **Teste:** a aba Actions mostra a execução verde, a URL pública abre o Foco em outro aparelho, e um `git push` com uma mudança de texto aparece publicado em menos de 3 minutos. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e08)

<a id="m14-e09"></a>
## M14-E09 — Exportar sessões nos três alvos · Aplicação
Implemente o exportador de CSV com importação condicional: `exportador.dart` (as condições), `exportador_stub.dart` (que **lança** com mensagem útil), `exportador_io.dart` (grava em disco com `path_provider`) e `exportador_web.dart` (dispara download com `Blob` + `createObjectURL` + `revokeObjectURL`). **Teste:** o mesmo botão funciona no Chrome e no Android, o widget de UI **não tem nenhum `kIsWeb`**, e remover a condição `if (dart.library.io)` produz o erro do stub — não um no-op silencioso. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e09)

<a id="m14-e10"></a>
## M14-E10 — Avisar que há versão nova · Aplicação
Implemente `observarAtualizacao()` usando `controllerchange` e o widget `AvisoDeAtualizacao` com SnackBar persistente e ação "Recarregar". **Teste:** publique duas versões seguidas e confirme que o aviso aparece na segunda; abra em **janela anônima** e confirme que ele **não** aparece na primeira visita. Explique em uma frase por que `updatefound` seria o evento errado e por que a guarda de primeira visita é obrigatória. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e10)

<a id="m14-e11"></a>
## M14-E11 — O botão de instalar sumiu · Diagnóstico
Três situações, cada uma com o convite de instalação ausente: (a) o app foi aberto pelo IP da rede local, `http://192.168.0.10:8080`; (b) o build usou `--pwa-strategy=none`; (c) tudo está verde no painel e ainda assim nada aparece. Para cada uma, diga o critério violado, o comando ou a tela que confirma a hipótese, e a correção. **Esperado:** você fecha os três diagnósticos sem alterar código no escuro, e identifica que (c) é o app já estar instalado. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e11)

<a id="m14-e12"></a>
## M14-E12 — O que é segredo na web · Reflexão
Escreva três respostas curtas, cada uma com justificativa: (a) por que `--dart-define-from-file` **não** protege nada num app web, e o que muda em relação ao Android; (b) quais destes podem ir num `--dart-define` web — URL base de API pública, token de escrita, chave de mapa restrita por domínio, senha de banco — e por quê, um a um; (c) o que você faria se um serviço que o Foco precisa exigisse uma chave secreta no cliente. **Esperado:** decisões defendidas em texto, não listas de comandos, e a conclusão de que a restrição por domínio é o que protege, não o sigilo. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e12)

<a id="m14-e13"></a>
## M14-E13 — Três telas brancas · Diagnóstico
Provoque, uma a uma, as três telas brancas da Aula 10 — caminho (`--base-href` ausente), código (`Platform.operatingSystem` no `main`) e cache (service worker servindo build quebrado). Para cada uma, registre o que aparece no **Console**, o que aparece na **Network** e o que acontece em **janela anônima**. **Esperado:** uma tabela de decisão que distingue as três em segundos, e a explicação de por que limpar o cache primeiro é o reflexo errado. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e13)

<a id="m14-e14"></a>
## M14-E14 — PWA completo do Foco · Desafio prático
Execute a ordem inteira do módulo — `kIsWeb` e importações condicionais, banco web, manifest, ícones, service worker entendido, instalabilidade, build com `--base-href` e `--no-web-resources-cdn`, deploy por Actions — e valide com os itens do [checklist de build web](../checklists/build-web.md). **Teste:** o Foco está numa URL pública; você o instalou na tela inicial de um celular a partir do navegador; ele abre **sem barra de endereços**; em **modo avião** ele abre, lista as matérias e permite criar uma sessão nova que sobrevive ao fechar e reabrir; e `.\scripts\verificar-deploy.ps1` passa em todas as verificações. [🔑 Gabarito](../gabaritos/14-build-web-pwa.md#m14-e14)

[Módulo](../modulos/14-build-web-pwa/README.md)
