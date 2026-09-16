# 03 — Trilha de Progresso

> Este é o seu **painel de controle** do curso. Marque cada caixa `- [ ]` trocando o espaço
> por um `x` (`- [x]`) quando concluir o item. O GitHub, o VS Code e a maioria dos editores
> de Markdown (*linguagem de marcação de texto simples, usada em arquivos `.md`*) desenham
> essas caixas como caixas de seleção clicáveis.

**Como usar este arquivo**

1. Abra-o no VS Code e ative a pré-visualização com `Ctrl + Shift + V`.
2. A cada fim de dia de estudo, marque o que concluiu.
3. Nunca marque um **marco** (*milestone* — um ponto de verificação importante, algo que você
   consegue demonstrar funcionando) só porque leu sobre ele. Marco só vale quando **rodou na
   sua máquina** ou no seu aparelho.
4. Se um item ficar parado por mais de dois dias, volte na aula indicada em
   [04-mapa-de-aprendizagem.md](04-mapa-de-aprendizagem.md).

**Legenda de plataforma** (a mesma usada no curso inteiro):

| Emoji | Significado                                                 |
| ----- | ----------------------------------------------------------- |
| 🤖    | Específico do Android                                      |
| 🍎    | Específico do iOS —**exige um Mac** (macOS + Xcode) |
| 🪟    | Específico do Windows                                      |
| 🖥️  | Específico do macOS                                        |
| ⭐    | Item opcional, mas muito recomendado                        |

> 🍎 **SÓ NO MAC.** Você está no Windows 11 e não tem Mac. Todos os itens marcados com 🍎
> continuam na trilha de propósito: você vai **ler, entender e saber executar** o processo
> iOS, e vai marcá-los quando conseguir acesso a um Mac (emprestado, alugado na nuvem ou
> comprado). Entenda o motivo em
> [modulos/15-build-ios/01-por-que-exige-macos.md](modulos/15-build-ios/01-por-que-exige-macos.md).

---

## Quadro geral dos 22 marcos

Estes são os 22 pontos de verificação do curso inteiro. Eles se repetem, no lugar certo,
dentro das fases mais abaixo — aqui estão juntos para você ver a jornada completa de uma vez.

| #  | Marco                                                    | Exige Mac? | Onde acontece                                                                                                         |
| -- | -------------------------------------------------------- | ---------- | --------------------------------------------------------------------------------------------------------------------- |
| 01 | ambiente Flutter configurado                             | Não       | [02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md)                                                       |
| 02 | flutter doctor validado                                  | Não       | [02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md)                                                       |
| 03 | emulador Android funcionando                             | Não       | [checklists/ambiente-android.md](checklists/ambiente-android.md)                                                       |
| 04 | simulador iOS funcionando (quando houver acesso a macOS) | 🍎 Sim     | [checklists/ambiente-ios.md](checklists/ambiente-ios.md)                                                               |
| 05 | fundamentos de Dart dominados                            | Não       | [avaliacoes/cumulativa-01-dart.md](avaliacoes/cumulativa-01-dart.md)                                                   |
| 06 | primeiro aplicativo executado                            | Não       | [modulos/05-introducao-ao-flutter/README.md](modulos/05-introducao-ao-flutter/README.md)                               |
| 07 | aplicativo executado em Android                          | Não       | [modulos/05-introducao-ao-flutter/README.md](modulos/05-introducao-ao-flutter/README.md)                               |
| 08 | aplicativo executado em iOS                              | 🍎 Sim     | [modulos/15-build-ios/03-simulador-e-iphone-fisico.md](modulos/15-build-ios/03-simulador-e-iphone-fisico.md)           |
| 09 | navegação implementada                                 | Não       | [modulos/07-navegacao-e-formularios/README.md](modulos/07-navegacao-e-formularios/README.md)                           |
| 10 | formulário validado                                     | Não       | [modulos/07-navegacao-e-formularios/06-formularios.md](modulos/07-navegacao-e-formularios/06-formularios.md)           |
| 11 | API consumida                                            | Não       | [modulos/09-consumo-de-api/README.md](modulos/09-consumo-de-api/README.md)                                             |
| 12 | dados persistidos                                        | Não       | [modulos/10-persistencia-de-dados/README.md](modulos/10-persistencia-de-dados/README.md)                               |
| 13 | testes criados                                           | Não       | [modulos/12-testes-e-debug/README.md](modulos/12-testes-e-debug/README.md)                                             |
| 14 | APK debug gerado                                         | Não       | [modulos/14-build-android/01-debug-profile-release.md](modulos/14-build-android/01-debug-profile-release.md)           |
| 15 | APK release assinado e instalado                         | Não       | [modulos/14-build-android/08-gerando-apk-e-aab.md](modulos/14-build-android/08-gerando-apk-e-aab.md)                   |
| 16 | AAB gerado                                               | Não       | [modulos/14-build-android/08-gerando-apk-e-aab.md](modulos/14-build-android/08-gerando-apk-e-aab.md)                   |
| 17 | build iOS release gerado                                 | 🍎 Sim     | [modulos/15-build-ios/08-build-ipa-e-archive.md](modulos/15-build-ios/08-build-ipa-e-archive.md)                       |
| 18 | aplicativo executado em iPhone físico                   | 🍎 Sim     | [modulos/15-build-ios/03-simulador-e-iphone-fisico.md](modulos/15-build-ios/03-simulador-e-iphone-fisico.md)           |
| 19 | archive do iOS criado                                    | 🍎 Sim     | [modulos/15-build-ios/08-build-ipa-e-archive.md](modulos/15-build-ios/08-build-ipa-e-archive.md)                       |
| 20 | IPA exportado (quando aplicável)                        | 🍎 Sim     | [modulos/15-build-ios/09-exportando-ipa-e-testflight.md](modulos/15-build-ios/09-exportando-ipa-e-testflight.md)       |
| 21 | versão preparada para TestFlight                        | 🍎 Sim     | [modulos/15-build-ios/09-exportando-ipa-e-testflight.md](modulos/15-build-ios/09-exportando-ipa-e-testflight.md)       |
| 22 | projeto final concluído                                 | Não       | [projetos/03-projeto-final-multiplataforma/13-checklist.md](projetos/03-projeto-final-multiplataforma/13-checklist.md) |

Glossário rápido dos nomes que aparecem acima (todos explicados em detalhe em
[referencias/glossario.md](referencias/glossario.md)):

- **APK** (*Android Package*) — o arquivo que instala um app em um aparelho Android.
- **AAB** (*Android App Bundle*) — o formato que a Google Play exige para publicação; a loja
  gera os APKs finais a partir dele.
- **IPA** (*iOS App Store Package*) — o equivalente ao APK no mundo Apple.
- **Archive** — o pacote intermediário que o Xcode produz antes de exportar um IPA.
- **TestFlight** — serviço da Apple para distribuir versões de teste a pessoas convidadas.
- **Emulador** — um Android "de mentira" que roda dentro do seu PC.
- **Simulador** — o equivalente da Apple, que só roda em macOS.

---

## Fase 0 — Preparação da máquina (Dia 1)

Objetivo da fase: sair de "tenho o Flutter meio instalado" para "consigo rodar comandos e
versionar código sem medo".

- [X] Li [00-como-usar-o-curso.md](00-como-usar-o-curso.md) inteiro
- [X] Escolhi o [Ritmo A — Muito intensivo](01-plano-intensivo.md#2-ritmo-a--muito-intensivo-15-dias--8-hdia) (15 dias, 8 h/dia)
- [ ] Registrei 4 h aplicadas ao trabalho e 4 h intermitentes de estudo no meu primeiro dia
- [ ] 🪟 Movi o Flutter SDK para um caminho **sem acentos e sem espaços** (`C:\src\flutter`)
- [ ] 🪟 Atualizei a variável de ambiente `PATH` e abri um terminal novo
- [ ] 🪟 Ativei o **Modo de Desenvolvedor** do Windows (`start ms-settings:developers`)
- [ ] **ambiente Flutter configurado**
- [ ] **flutter doctor validado**
- [ ] Módulo 00 — [Git e terminal](modulos/00-git-e-terminal/README.md)
- [ ] Exercícios do módulo 00 — [exercicios/00-git-e-terminal.md](exercicios/00-git-e-terminal.md)
- [ ] Avaliação do módulo 00 — [avaliacoes/modulo-00-git-e-terminal.md](avaliacoes/modulo-00-git-e-terminal.md)
- [ ] Instalei o Android Studio e o **Android SDK** (*Software Development Kit* — o pacote de
  ferramentas necessário para compilar apps de uma plataforma)
- [ ] Aceitei as licenças com `flutter doctor --android-licenses`
- [ ] **emulador Android funcionando**
- [ ] Checklist completo — [checklists/ambiente-android.md](checklists/ambiente-android.md)
- [ ] 🍎 **simulador iOS funcionando (quando houver acesso a macOS)**
- [ ] 🍎 Checklist completo — [checklists/ambiente-ios.md](checklists/ambiente-ios.md)

---

## Fase 1 — Lógica e Dart (Dias 2 a 8)

Objetivo da fase: escrever Dart com confiança no terminal, antes de qualquer tela.

- [ ] Módulo 01 — [Lógica e fundamentos](modulos/01-logica-e-fundamentos/README.md)
- [ ] Exercícios do módulo 01 — [exercicios/01-logica-e-fundamentos.md](exercicios/01-logica-e-fundamentos.md)
- [ ] Avaliação do módulo 01 — [avaliacoes/modulo-01-logica-e-fundamentos.md](avaliacoes/modulo-01-logica-e-fundamentos.md)
- [ ] Módulo 02 — [Dart básico](modulos/02-dart-basico/README.md)
- [ ] Exercícios do módulo 02 — [exercicios/02-dart-basico.md](exercicios/02-dart-basico.md)
- [ ] Avaliação do módulo 02 — [avaliacoes/modulo-02-dart-basico.md](avaliacoes/modulo-02-dart-basico.md)
- [ ] Módulo 03 — [Dart intermediário](modulos/03-dart-intermediario/README.md)
- [ ] Exercícios do módulo 03 — [exercicios/03-dart-intermediario.md](exercicios/03-dart-intermediario.md)
- [ ] Avaliação do módulo 03 — [avaliacoes/modulo-03-dart-intermediario.md](avaliacoes/modulo-03-dart-intermediario.md)
- [ ] Módulo 04 — [Dart avançado](modulos/04-dart-avancado/README.md)
- [ ] Exercícios do módulo 04 — [exercicios/04-dart-avancado.md](exercicios/04-dart-avancado.md)
- [ ] Avaliação do módulo 04 — [avaliacoes/modulo-04-dart-avancado.md](avaliacoes/modulo-04-dart-avancado.md)
- [ ] Avaliação cumulativa 01 — [avaliacoes/cumulativa-01-dart.md](avaliacoes/cumulativa-01-dart.md)
- [ ] **fundamentos de Dart dominados**

---

## Fase 2 — Flutter na tela (Dias 9 a 16)

Objetivo da fase: transformar código em interface que você vê, toca e navega.

- [ ] Módulo 05 — [Introdução ao Flutter](modulos/05-introducao-ao-flutter/README.md)
- [ ] Exercícios do módulo 05 — [exercicios/05-introducao-ao-flutter.md](exercicios/05-introducao-ao-flutter.md)
- [ ] Avaliação do módulo 05 — [avaliacoes/modulo-05-introducao-ao-flutter.md](avaliacoes/modulo-05-introducao-ao-flutter.md)
- [ ] **primeiro aplicativo executado**
- [ ] **aplicativo executado em Android**
- [ ] Projeto 1 — [Meu Primeiro App](projetos/01-projeto-iniciante/README.md)
- [ ] Checklist do projeto 1 — [projetos/01-projeto-iniciante/06-checklist.md](projetos/01-projeto-iniciante/06-checklist.md)
- [ ] Módulo 06 — [Widgets e layouts](modulos/06-widgets-e-layouts/README.md)
- [ ] Exercícios do módulo 06 — [exercicios/06-widgets-e-layouts.md](exercicios/06-widgets-e-layouts.md)
- [ ] Avaliação do módulo 06 — [avaliacoes/modulo-06-widgets-e-layouts.md](avaliacoes/modulo-06-widgets-e-layouts.md)
- [ ] Módulo 07 — [Navegação e formulários](modulos/07-navegacao-e-formularios/README.md)
- [ ] Exercícios do módulo 07 — [exercicios/07-navegacao-e-formularios.md](exercicios/07-navegacao-e-formularios.md)
- [ ] Avaliação do módulo 07 — [avaliacoes/modulo-07-navegacao-e-formularios.md](avaliacoes/modulo-07-navegacao-e-formularios.md)
- [ ] **navegação implementada**
- [ ] **formulário validado**
- [ ] Avaliação cumulativa 02 — [avaliacoes/cumulativa-02-flutter-ui.md](avaliacoes/cumulativa-02-flutter-ui.md)
- [ ] Projeto 2 — [Bloco de Notas de Estudo](projetos/02-projeto-intermediario/README.md)
- [ ] Checklist do projeto 2 — [projetos/02-projeto-intermediario/06-checklist.md](projetos/02-projeto-intermediario/06-checklist.md)

---

## Fase 3 — Estado, dados e plataforma (Dias 17 a 22)

Objetivo da fase: o app passa a ter memória, conversa com a internet e usa recursos do aparelho.

- [ ] Módulo 08 — [Estado e arquitetura](modulos/08-estado-e-arquitetura/README.md)
- [ ] Exercícios do módulo 08 — [exercicios/08-estado-e-arquitetura.md](exercicios/08-estado-e-arquitetura.md)
- [ ] Avaliação do módulo 08 — [avaliacoes/modulo-08-estado-e-arquitetura.md](avaliacoes/modulo-08-estado-e-arquitetura.md)
- [ ] Módulo 09 — [Consumo de API](modulos/09-consumo-de-api/README.md)
- [ ] Exercícios do módulo 09 — [exercicios/09-consumo-de-api.md](exercicios/09-consumo-de-api.md)
- [ ] Avaliação do módulo 09 — [avaliacoes/modulo-09-consumo-de-api.md](avaliacoes/modulo-09-consumo-de-api.md)
- [ ] **API consumida**
- [ ] Módulo 10 — [Persistência de dados](modulos/10-persistencia-de-dados/README.md)
- [ ] Exercícios do módulo 10 — [exercicios/10-persistencia-de-dados.md](exercicios/10-persistencia-de-dados.md)
- [ ] Avaliação do módulo 10 — [avaliacoes/modulo-10-persistencia-de-dados.md](avaliacoes/modulo-10-persistencia-de-dados.md)
- [ ] **dados persistidos**
- [ ] Avaliação cumulativa 03 — [avaliacoes/cumulativa-03-estado-e-dados.md](avaliacoes/cumulativa-03-estado-e-dados.md)
- [ ] Módulo 11 — [Recursos nativos](modulos/11-recursos-nativos/README.md)
- [ ] Exercícios do módulo 11 — [exercicios/11-recursos-nativos.md](exercicios/11-recursos-nativos.md)
- [ ] Avaliação do módulo 11 — [avaliacoes/modulo-11-recursos-nativos.md](avaliacoes/modulo-11-recursos-nativos.md)

---

## Fase 4 — Qualidade (Dias 23 e 24)

Objetivo da fase: provar que o app funciona, e que continua funcionando depois de mudanças.

- [ ] Módulo 12 — [Testes e debug](modulos/12-testes-e-debug/README.md)
- [ ] Exercícios do módulo 12 — [exercicios/12-testes-e-debug.md](exercicios/12-testes-e-debug.md)
- [ ] Avaliação do módulo 12 — [avaliacoes/modulo-12-testes-e-debug.md](avaliacoes/modulo-12-testes-e-debug.md)
- [ ] **testes criados**
- [ ] Módulo 13 — [Desempenho e segurança](modulos/13-desempenho-e-seguranca/README.md)
- [ ] Exercícios do módulo 13 — [exercicios/13-desempenho-e-seguranca.md](exercicios/13-desempenho-e-seguranca.md)
- [ ] Avaliação do módulo 13 — [avaliacoes/modulo-13-desempenho-e-seguranca.md](avaliacoes/modulo-13-desempenho-e-seguranca.md)
- [ ] Avaliação cumulativa 04 — [avaliacoes/cumulativa-04-qualidade-e-plataforma.md](avaliacoes/cumulativa-04-qualidade-e-plataforma.md)

---

## Fase 5 — Projeto final "Foco" (Dias 25 a 27)

Objetivo da fase: juntar tudo em um app real, com 5 telas, banco local e API.

- [ ] Li a especificação — [projetos/03-projeto-final-multiplataforma/01-especificacao.md](projetos/03-projeto-final-multiplataforma/01-especificacao.md)
- [ ] Etapa 1 — Fundação
- [ ] Etapa 2 — Domínio e dados
- [ ] Etapa 3 — Estado com Riverpod
- [ ] Etapa 4 — Telas e navegação
- [ ] Etapa 5 — API e trilhas
- [ ] Etapa 6 — Responsividade e acessibilidade
- [ ] Etapa 7 — Testes
- [ ] Etapa 8 — Ícone, splash e versão
- [ ] Critérios de aceite conferidos — [projetos/03-projeto-final-multiplataforma/11-criterios-de-aceite.md](projetos/03-projeto-final-multiplataforma/11-criterios-de-aceite.md)
- [ ] Projeto 3 — [Projeto final multiplataforma](projetos/03-projeto-final-multiplataforma/README.md)
- [ ] **projeto final concluído**
- [ ] ⭐ Desafios extras — [projetos/03-projeto-final-multiplataforma/12-desafios.md](projetos/03-projeto-final-multiplataforma/12-desafios.md)

---

## Fase 6 — Build e distribuição (Dia 15)

Objetivo da fase: transformar código em arquivo instalável, primeiro no Android, depois no iOS.

### 🤖 Android

- [ ] Módulo 14 — [Build Android](modulos/14-build-android/README.md)
- [ ] Exercícios do módulo 14 — [exercicios/14-build-android.md](exercicios/14-build-android.md)
- [ ] Avaliação do módulo 14 — [avaliacoes/modulo-14-build-android.md](avaliacoes/modulo-14-build-android.md)
- [ ] **APK debug gerado**
- [ ] Criei o **keystore** (*arquivo com a chave criptográfica que assina o app*) de upload
- [ ] Configurei `key.properties` e coloquei no `.gitignore`
- [ ] **APK release assinado e instalado**
- [ ] **AAB gerado**
- [ ] Checklist completo — [checklists/build-android.md](checklists/build-android.md)

### 🍎 iOS

- [ ] Módulo 15 — [Build iOS](modulos/15-build-ios/README.md) (leitura possível no Windows)
- [ ] Exercícios do módulo 15 — [exercicios/15-build-ios.md](exercicios/15-build-ios.md)
- [ ] Avaliação do módulo 15 — [avaliacoes/modulo-15-build-ios.md](avaliacoes/modulo-15-build-ios.md)
- [ ] 🍎 **aplicativo executado em iOS**
- [ ] 🍎 **aplicativo executado em iPhone físico**
- [ ] 🍎 **build iOS release gerado**
- [ ] 🍎 **archive do iOS criado**
- [ ] 🍎 **IPA exportado (quando aplicável)**
- [ ] 🍎 **versão preparada para TestFlight**
- [ ] 🍎 Checklist completo — [checklists/build-ios.md](checklists/build-ios.md)

---

## Fase 7 — Publicação e fechamento (Dia 15)

- [ ] Módulo 16 — [Publicação e próximos passos](modulos/16-publicacao-e-proximos-passos/README.md)
- [ ] Exercícios do módulo 16 — [exercicios/16-publicacao-e-proximos-passos.md](exercicios/16-publicacao-e-proximos-passos.md)
- [ ] Avaliação do módulo 16 — [avaliacoes/modulo-16-publicacao-e-proximos-passos.md](avaliacoes/modulo-16-publicacao-e-proximos-passos.md)
- [ ] Avaliação cumulativa 05 — [avaliacoes/cumulativa-05-build-e-distribuicao.md](avaliacoes/cumulativa-05-build-e-distribuicao.md)
- [ ] Avaliação final — [avaliacoes/avaliacao-final.md](avaliacoes/avaliacao-final.md)
- [ ] Checklist do projeto final — [checklists/projeto-final.md](checklists/projeto-final.md)
- [ ] Li [referencias/proximos-passos.md](referencias/proximos-passos.md) e escolhi o próximo objetivo

---

## Checkboxes por módulo (visão compacta 00 → 16)

Use esta lista quando quiser ver, em uma tela só, quanto do conteúdo já foi coberto.

- [ ] Módulo 00 — [Git e terminal](modulos/00-git-e-terminal/README.md)
- [ ] Módulo 01 — [Lógica e fundamentos](modulos/01-logica-e-fundamentos/README.md)
- [ ] Módulo 02 — [Dart básico](modulos/02-dart-basico/README.md)
- [ ] Módulo 03 — [Dart intermediário](modulos/03-dart-intermediario/README.md)
- [ ] Módulo 04 — [Dart avançado](modulos/04-dart-avancado/README.md)
- [ ] Módulo 05 — [Introdução ao Flutter](modulos/05-introducao-ao-flutter/README.md)
- [ ] Módulo 06 — [Widgets e layouts](modulos/06-widgets-e-layouts/README.md)
- [ ] Módulo 07 — [Navegação e formulários](modulos/07-navegacao-e-formularios/README.md)
- [ ] Módulo 08 — [Estado e arquitetura](modulos/08-estado-e-arquitetura/README.md)
- [ ] Módulo 09 — [Consumo de API](modulos/09-consumo-de-api/README.md)
- [ ] Módulo 10 — [Persistência de dados](modulos/10-persistencia-de-dados/README.md)
- [ ] Módulo 11 — [Recursos nativos](modulos/11-recursos-nativos/README.md)
- [ ] Módulo 12 — [Testes e debug](modulos/12-testes-e-debug/README.md)
- [ ] Módulo 13 — [Desempenho e segurança](modulos/13-desempenho-e-seguranca/README.md)
- [ ] Módulo 14 — 🤖 [Build Android](modulos/14-build-android/README.md)
- [ ] Módulo 15 — 🍎 [Build iOS](modulos/15-build-ios/README.md)
- [ ] Módulo 16 — [Publicação e próximos passos](modulos/16-publicacao-e-proximos-passos/README.md)

## Checkboxes por projeto

- [ ] Projeto 1 — [Meu Primeiro App](projetos/01-projeto-iniciante/README.md)
- [ ] Projeto 2 — [Bloco de Notas de Estudo](projetos/02-projeto-intermediario/README.md)
- [ ] Projeto 3 — [Foco: Organizador de Estudos](projetos/03-projeto-final-multiplataforma/README.md)

## Checkboxes por avaliação

- [ ] [Módulo 00 — Git e terminal](avaliacoes/modulo-00-git-e-terminal.md)
- [ ] [Módulo 01 — Lógica e fundamentos](avaliacoes/modulo-01-logica-e-fundamentos.md)
- [ ] [Módulo 02 — Dart básico](avaliacoes/modulo-02-dart-basico.md)
- [ ] [Módulo 03 — Dart intermediário](avaliacoes/modulo-03-dart-intermediario.md)
- [ ] [Módulo 04 — Dart avançado](avaliacoes/modulo-04-dart-avancado.md)
- [ ] [Módulo 05 — Introdução ao Flutter](avaliacoes/modulo-05-introducao-ao-flutter.md)
- [ ] [Módulo 06 — Widgets e layouts](avaliacoes/modulo-06-widgets-e-layouts.md)
- [ ] [Módulo 07 — Navegação e formulários](avaliacoes/modulo-07-navegacao-e-formularios.md)
- [ ] [Módulo 08 — Estado e arquitetura](avaliacoes/modulo-08-estado-e-arquitetura.md)
- [ ] [Módulo 09 — Consumo de API](avaliacoes/modulo-09-consumo-de-api.md)
- [ ] [Módulo 10 — Persistência de dados](avaliacoes/modulo-10-persistencia-de-dados.md)
- [ ] [Módulo 11 — Recursos nativos](avaliacoes/modulo-11-recursos-nativos.md)
- [ ] [Módulo 12 — Testes e debug](avaliacoes/modulo-12-testes-e-debug.md)
- [ ] [Módulo 13 — Desempenho e segurança](avaliacoes/modulo-13-desempenho-e-seguranca.md)
- [ ] [Módulo 14 — Build Android](avaliacoes/modulo-14-build-android.md)
- [ ] [Módulo 15 — Build iOS](avaliacoes/modulo-15-build-ios.md)
- [ ] [Módulo 16 — Publicação e próximos passos](avaliacoes/modulo-16-publicacao-e-proximos-passos.md)
- [ ] [Cumulativa 01 — Dart](avaliacoes/cumulativa-01-dart.md)
- [ ] [Cumulativa 02 — Flutter UI](avaliacoes/cumulativa-02-flutter-ui.md)
- [ ] [Cumulativa 03 — Estado e dados](avaliacoes/cumulativa-03-estado-e-dados.md)
- [ ] [Cumulativa 04 — Qualidade e plataforma](avaliacoes/cumulativa-04-qualidade-e-plataforma.md)
- [ ] [Cumulativa 05 — Build e distribuição](avaliacoes/cumulativa-05-build-e-distribuicao.md)
- [ ] [Avaliação final](avaliacoes/avaliacao-final.md)

> As respostas de todas as avaliações ficam em
> [avaliacoes/gabarito-das-avaliacoes.md](gabaritos/avaliacoes.md).
> Só abra depois de responder — o valor está em errar antes de conferir.

---

## Calendário: data prevista × data concluída (Ritmo A, 15 dias)

**Como preencher.** Escolha a data do seu Dia 1 e escreva-a na primeira linha. Some um dia
por linha. Os dias 5, 10 e 15 já incluem revisão; não precisam de folga extra.
Se um dia atrasar, **não apague a data prevista**: escreva a data real em "Data concluída".
A diferença entre as duas colunas é o seu termômetro de ritmo.

Na coluna "Status" use: `🟢` no prazo · `🟡` atrasou 1 dia · `🔴` atrasou 2 dias ou mais.

| Dia | Conteúdo previsto                                                     | Data prevista         | Data concluída       | Status |
| --- | ---------------------------------------------------------------------- | --------------------- | --------------------- | ------ |
| 1   | Ambiente + M00 completo + M01 aulas 1–5                               | ____/____ | ____/____ |        |
| 2   | M01 aulas 6–10 + exercícios + avaliação                            | ____/____ | ____/____ |        |
| 3   | M02 completo + exercícios + avaliação                               | ____/____ | ____/____ |        |
| 4   | M03 completo + exercícios + avaliação                               | ____/____ | ____/____ |        |
| 5   | **Revisão** + M04 + cumulativa 01                               | ____/____ | ____/____ |        |
| 6   | M05 completo + exercícios + avaliação                               | ____/____ | ____/____ |        |
| 7   | Projeto 1 + M06 aulas 1–6                                             | ____/____ | ____/____ |        |
| 8   | M06 aulas 7–12 + exercícios + avaliação                            | ____/____ | ____/____ |        |
| 9   | M07 + cumulativa 02                                                    | ____/____ | ____/____ |        |
| 10  | **Revisão** + Projeto 2                                         | ____/____ | ____/____ |        |
| 11  | M08 + avaliação                                                      | ____/____ | ____/____ |        |
| 12  | M09 + M10 + cumulativa 03                                              | ____/____ | ____/____ |        |
| 13  | M11 + M12 + M13 + cumulativa 04                                        | ____/____ | ____/____ |        |
| 14  | Projeto final, etapas 1–8                                             | ____/____ | ____/____ |        |
| 15  | **Revisão** + M14, M15, M16 + cumulativa 05 + avaliação final | ____/____ | ____/____ |        |

### Dias de revisão

O Ritmo A prevê revisão nos dias **5, 10 e 15**. Revisão aqui não é reler tudo:
é refazer, sem consultar, dois exercícios que você errou e reexecutar um projeto do zero.

- [ ] Revisão do dia 5 feita
- [ ] Revisão do dia 10 feita
- [ ] Revisão do dia 15 feita

---

## Termômetro semanal

Preencha ao fim de cada semana. É o sinal mais honesto de que o ritmo está sustentável.

| Semana | Dias   | Marcos concluídos | Horas reais estudadas | Como me senti (1–5) | O que travou |
| ------ | ------ | ------------------ | --------------------- | -------------------- | ------------ |
| 1      | 1–5   | ___ / 22           | ___ h                 | ___                  |              |
| 2      | 6–10  | ___ / 22           | ___ h                 | ___                  |              |
| 3      | 11–15 | ___ / 22           | ___ h                 | ___                  |              |

**Regra de segurança do ritmo:** se ao fim de um bloco de cinco dias você concluiu menos de 60%
do previsto, recalcule as datas antes de avançar. Preserve a sequência e os critérios de avanço;
o curso pode levar mais de 15 dias se a prática no trabalho exigir investigação adicional.

---

## Quando algo der errado

| Sintoma                                             | Onde procurar                                                                 |
| --------------------------------------------------- | ----------------------------------------------------------------------------- |
| Um comando falhou com uma mensagem estranha         | [referencias/erros-comuns.md](referencias/erros-comuns.md)                     |
| Esqueci a sintaxe de um comando                     | [referencias/comandos-uteis.md](referencias/comandos-uteis.md)                 |
| Não lembro o que uma palavra significa             | [referencias/glossario.md](referencias/glossario.md)                           |
| "Isso funciona diferente no iPhone?"                | [referencias/diferencas-android-ios.md](referencias/diferencas-android-ios.md) |
| Quero a fonte oficial                               | [referencias/referencias-oficiais.md](referencias/referencias-oficiais.md)     |
| Não sei qual aula cobre determinado assunto        | [04-mapa-de-aprendizagem.md](04-mapa-de-aprendizagem.md)                       |
| Quero saber por que o curso escolheu tal ferramenta | [05-decisoes-tecnicas.md](05-decisoes-tecnicas.md)                             |
| Quero conferir se o ambiente está mesmo válido    | [06-relatorio-de-validacao.md](06-relatorio-de-validacao.md)                   |

---

| ⬅️ Anterior                                                     | 🏠 Início         | ➡️ Próximo                                           |
| ----------------------------------------------------------------- | ------------------ | ------------------------------------------------------- |
| [02 — Configuração do ambiente](02-configuracao-do-ambiente.md) | [README](README.md) | [04 — Mapa de aprendizagem](04-mapa-de-aprendizagem.md) |
