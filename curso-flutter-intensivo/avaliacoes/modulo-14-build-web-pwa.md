# Avaliação — Módulo 14: Build e distribuição Web (PWA)

> **Tempo sugerido:** 30 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. Os três requisitos que tornam um site um PWA instalável são: A) manifest, ícone 512×512 e domínio próprio; B) HTTPS, `manifest.json` válido e service worker com handler de `fetch`; C) HTTPS, `--wasm` e `display: fullscreen`; D) service worker, IndexedDB e `beforeinstallprompt`.
2. O Flutter web desenha a interface: A) traduzindo cada widget para elementos HTML equivalentes; B) num único `<canvas>`, com o Skia compilado para WebAssembly (CanvasKit); C) em SVG gerado a cada quadro; D) em HTML no debug e em canvas no release.
3. `Platform.isIOS` num app web: A) não compila, o build falha com erro claro; B) compila e lança `Unsupported operation: Platform._operatingSystem` em tempo de execução; C) devolve `false` silenciosamente; D) funciona normalmente, porque `dart:io` tem implementação web.
4. O Foco publicado em `usuario.github.io/foco/` abre totalmente branco, e o Console mostra `404` em `main.dart.js`. A causa é: A) o service worker guardou um build quebrado; B) faltou `--base-href /foco/` no build; C) o `manifest.json` está inválido; D) o CanvasKit não foi baixado do CDN.
5. Depois de publicar uma correção, o usuário abre o app e continua vendo a versão antiga. Isso acontece porque: A) o GitHub Pages leva horas para propagar; B) o service worker serve do cache e baixa a versão nova em paralelo, que só passa a ser servida na abertura seguinte; C) o `--base-href` mudou; D) é um bug conhecido do Flutter web.
6. Um PWA que promete funcionar offline precisa de `--no-web-resources-cdn` porque: A) o CDN é mais lento que o seu servidor; B) por padrão o CanvasKit vem de `gstatic.com`, e o service worker do Flutter não faz cache de recursos de outra origem; C) a flag ativa o modo offline do service worker; D) sem ela o `manifest.json` não é gerado.

7. Explique por que o `sqflite` não funciona na web e o que o `sqflite_common_ffi_web` faz no lugar dele. Diga onde o banco fica guardado e cite duas situações em que ele desaparece.
8. Diferencie `start_url` de `scope`, e descreva o sintoma específico que aparece quando o `scope` não corresponde ao `--base-href`.
9. Explique o que é CORS, por que ele só aparece na web e por que nenhuma configuração do lado Flutter resolve. Diga onde se confirma o diagnóstico.
10. Descreva os três tipos de tela branca e como distingui-los usando Console, Network e janela anônima.

## 2. Prática

Publique o Foco como PWA e **comprove** o resultado. Configure o banco web (`sqflite_common_ffi_web`, com os arquivos commitados), preencha o `web/manifest.json` com ícones `any` e `maskable`, e crie o workflow `.github/workflows/publicar-web.yml` com os três portões, `--base-href`, `--no-web-resources-cdn` e a cópia do `404.html`. Registre tudo em `docs/release-web-1.0.0.md`: a URL pública, o print do painel `Installability`, a saída do job do GitHub Actions, o peso medido do caminho crítico e o checklist de validação offline preenchido em um celular real.

| Critério | Pontos |
|---|---:|
| Banco web funcionando, com `git diff --stat` provando que `domain/` não mudou | 2 |
| Manifest completo, com ao menos um ícone `maskable` e `scope` = `--base-href` | 2 |
| Workflow publicando sozinho, com `flutter test --platform chrome` entre os portões | 2 |
| URL pública abrindo em outro aparelho e app instalado na tela inicial | 2 |
| Validação offline no celular: abre pelo ícone, lista matérias e grava sessão nova | 2 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem erros e `flutter test --platform chrome` passando.
- `git status` limpo, com `web/sqlite3.wasm` e `web/sqflite_sw.js` **commitados** e nenhum `.map` publicado.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| O que é PWA e por que é o canal principal | [Aula 01](../modulos/14-build-web-pwa/01-por-que-pwa.md) | E01 |
| Compilação, CanvasKit e primeiro carregamento | [Aula 02](../modulos/14-build-web-pwa/02-como-o-flutter-compila-para-web.md) | E02 |
| `dart:io`, `kIsWeb`, importação condicional e CORS | [Aula 03](../modulos/14-build-web-pwa/03-o-que-nao-funciona-na-web.md) | E03 |
| Banco na web, IndexedDB e cota | [Aula 04](../modulos/14-build-web-pwa/04-banco-de-dados-na-web.md) | E04 |
| Manifest, `scope` e ícones maskable | [Aula 05](../modulos/14-build-web-pwa/05-manifest-e-icones.md) | E05 |
| Service worker, versão presa e os três offlines | [Aula 06](../modulos/14-build-web-pwa/06-service-worker-e-offline.md) | E06 |
| Instalabilidade e o caso do iOS | [Aula 07](../modulos/14-build-web-pwa/07-instalabilidade.md) | E11 |
| `--base-href`, segredos e verificação do artefato | [Aula 08](../modulos/14-build-web-pwa/08-gerando-o-build-web.md) | E07 |
| Deploy, rotas profundas e alternativas | [Aula 09](../modulos/14-build-web-pwa/09-publicando-no-github-pages.md) | E08 |
| Diagnóstico e as três telas brancas | [Aula 10](../modulos/14-build-web-pwa/10-diagnostico-web.md) | E13 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-14)
