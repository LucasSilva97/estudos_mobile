# Checklist final — Projeto Foco

> Este é o último checklist do curso. O que passa aqui é um app **publicável**.
>
> Diferente dos [critérios de aceite](11-criterios-de-aceite.md), que medem o produto pronto,
> este checklist acompanha a **construção**: ele diz, etapa por etapa, o que precisa estar de pé
> antes de seguir. Se você travou, ele também diz **onde revisar**.

---

## 📐 Por etapa

### Etapa 1 — Fundação

- [ ] `flutter create` feito e o app roda no Windows e no Android
- [ ] Tema Material 3 claro e escuro, aplicados a partir do `ColorScheme.fromSeed`
- [ ] Pastas `core/` e `features/` criadas, vazias mas no lugar
- [ ] `Rotas` com `onGenerateRoute` e rota desconhecida tratada
- [ ] `flutter analyze` limpo

→ Falhou? [Etapa 1](03-etapa-1-fundacao.md) · [Módulo 07, aula 2](../../modulos/07-navegacao-e-formularios/02-rotas-nomeadas.md)

### Etapa 2 — Domínio e dados

- [ ] `Materia`, `Sessao` e `Meta` em Dart puro, **sem nenhum import de Flutter**
- [ ] Validações no construtor: objeto inválido não chega a existir
- [ ] Banco criado com o esquema da especificação e `ON DELETE CASCADE`
- [ ] `nome_ordenacao` achatado — `Álgebra` ordena antes de `Biologia`
- [ ] Todo SQL com `?` e `whereArgs` (RNF11)
- [ ] Testes do domínio e dos DAOs passando com `sqflite_common_ffi`

→ Falhou? [Etapa 2](04-etapa-2-dominio-e-dados.md) · [Módulo 10, aula 4](../../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md)

### Etapa 3 — Estado com Riverpod

- [ ] `Notifier` e `AsyncNotifier` **sem** code generation
- [ ] Nenhum `build_runner` no projeto
- [ ] O repositório entra por provider e é substituível em teste
- [ ] A UI consome `AsyncValue` e trata os quatro estados
- [ ] Teste com `ProviderContainer` e `overrides`, sem montar tela

→ Falhou? [Etapa 3](05-etapa-3-estado-com-riverpod.md) · [Módulo 08, aula 10](../../modulos/08-estado-e-arquitetura/10-injecao-de-dependencias.md)

### Etapa 4 — Telas e navegação

- [ ] As cinco telas existem e navegam entre si
- [ ] Os quatro estados de UI em toda tela que carrega dado
- [ ] Formulário com validação, foco e `textInputAction`
- [ ] Argumentos e retorno de rota funcionando (`Navigator.pop(true)`)
- [ ] `PopScope` onde há rascunho a perder

→ Falhou? [Etapa 4](06-etapa-4-telas-e-navegacao.md) · [Módulo 06, aula 12](../../modulos/06-widgets-e-layouts/12-estados-de-ui.md)

### Etapa 5 — API e trilhas

- [ ] DTO separado do modelo de domínio
- [ ] `.timeout` em toda requisição e tratamento de falha
- [ ] Cache com TTL de 6 h gravado no banco
- [ ] Falha de rede **não apaga** o cache
- [ ] Teste com `MockClient` cobrindo 200, 500 e JSON inválido

→ Falhou? [Etapa 5](07-etapa-5-api-e-trilhas.md) · [Módulo 09, aula 7](../../modulos/09-consumo-de-api/07-camada-de-dados-testavel.md)

### Etapa 6 — Responsividade e acessibilidade

- [ ] Layout correto de 320 dp a 1280 dp, sem `RenderFlex overflowed`
- [ ] `tooltip` em **todo** `IconButton`
- [ ] Cores pelo `ColorScheme`, nunca cruas
- [ ] 200% de fonte sem cortar texto
- [ ] Mudanças anunciadas com `SemanticsService`

→ Falhou? [Etapa 6](08-etapa-6-responsividade-e-acessibilidade.md) · [Módulo 13, aula 5](../../modulos/13-desempenho-e-seguranca/05-acessibilidade.md)

### Etapa 7 — Testes

- [ ] `tester.ensureSemantics()` presente nos testes de acessibilidade
- [ ] Fakes com atraso e falha configuráveis
- [ ] Nenhum `Future.delayed` usado para "estabilizar" teste
- [ ] `flutter test` → `All tests passed!`, sem `skip:`

→ Falhou? [Etapa 7](09-etapa-7-testes.md) · [Módulo 12, aula 6](../../modulos/12-testes-e-debug/06-testes-de-widget.md)

### Etapa 8 — Ícone, splash e versão

- [ ] Ícone gerado, **sem canal alfa** no iOS
- [ ] Splash clara e escura
- [ ] Versão vindo do `pubspec` por `$(FLUTTER_BUILD_NAME)`
- [ ] Textos de permissão do `Info.plist` em português e **específicos**

→ Falhou? [Etapa 8](10-etapa-8-icone-splash-e-versao.md) · [Módulo 15, aula 5](../../modulos/15-build-ios/05-icone-splash-versao-infoplist.md)

---

## 🧪 Qualidade

- [ ] `flutter analyze` → **`No issues found!`** (zero aviso, não "poucos")
- [ ] `dart format --output=none --set-exit-if-changed .` passa
- [ ] Nenhum `TODO` ou `print` esquecido
- [ ] Nenhum arquivo fora da árvore da [arquitetura](02-arquitetura.md)
- [ ] `git status` limpo e a versão com tag anotada

---

## ♿ Acessibilidade e ⚡ desempenho

Medidos nos [critérios de aceite](11-criterios-de-aceite.md), seções RNF01–RNF09 e RNF14.

- [ ] As quatro diretrizes automáticas passam em teste
- [ ] **Cinco minutos de TalkBack** feitos, com as observações anotadas
- [ ] Medição em `--profile`, num aparelho, com o número anotado antes e depois

---

## 🤖 Android

Detalhe completo em [checklists/build-android.md](../../checklists/build-android.md).

- [ ] `applicationId` = `br.com.estudos.foco`
- [ ] Keystore criado, com backup em **três** lugares e senhas anotadas
- [ ] `signingConfig` do release aponta para a **sua** chave, não a de debug
- [ ] Permissões conferidas no manifest **fundido** — nenhuma sobrando de plugin
- [ ] AAB gerado com `--obfuscate --split-debug-info`
- [ ] Símbolos e `mapping.txt` arquivados **fora** da máquina
- [ ] Instalação limpa **e** atualização a partir da versão anterior testadas

→ [Módulo 14](../../modulos/14-build-android/README.md)

---

## 🍎 iOS

Detalhe completo em [checklists/build-ios.md](../../checklists/build-ios.md).

**Faz no Windows, hoje:**

- [ ] Bundle ID `br.com.estudos.foco` nas três configurações do `project.pbxproj`
- [ ] Ícone gerado com `remove_alpha_ios: true`
- [ ] `Info.plist` com versão por variável e textos de permissão específicos
- [ ] `ExportOptions.plist` escrito, com `method: app-store-connect`
- [ ] Tudo commitado

**Exige Mac — ou CI com runner macOS:**

- [ ] `pod install` e build do `.xcworkspace`
- [ ] Certificado e provisioning profile válidos
- [ ] IPA gerado e **Validate App** aprovado
- [ ] Os **dois** conjuntos de símbolos guardados (Dart e dSYM)

> 🍎 Sem Mac, o caminho é o [desafio P03-D08](12-desafios.md#p03-d08) — o pipeline de CI que gera
> o IPA num runner macOS. Não é o mesmo que ter um Mac à mão, mas é a diferença entre publicar e
> não publicar.

---

## 📢 Publicação

- [ ] Versão e `CHANGELOG` atualizados, com tag anotada
- [ ] Ficha da loja preenchida: nome, descrição, capturas, política de privacidade
- [ ] Enviado à **faixa interna** primeiro, nunca direto para produção
- [ ] Crash reporting instalado, com os **dois** manipuladores de erro
- [ ] Símbolos enviados — os stack traces de produção chegam legíveis

→ [Módulo 16](../../modulos/16-publicacao-e-proximos-passos/README.md)

---

## 🎓 E agora

Com tudo acima marcado, você tem um app publicável e o curso concluído.

| Faça | Onde |
|---|---|
| A avaliação final | [avaliacoes/avaliacao-final.md](../../avaliacoes/avaliacao-final.md) |
| Os desafios do projeto | [12-desafios.md](12-desafios.md) |
| Escolher o que estudar depois | [Módulo 16, aula 6](../../modulos/16-publicacao-e-proximos-passos/06-proximos-passos.md) |

> 📌 **O próximo passo não é outro curso.** É o plano de 90 dias da última aula, e o primeiro
> commit de um app **seu** — diferente do Foco, resolvendo um problema que você tem. É ali que o
> que você aprendeu aqui vira habilidade.

---

| ⬅️ Anterior | 🏠 Projeto | ➡️ Curso |
|---|---|---|
| [Desafios](12-desafios.md) | [README](README.md) | [Módulo 16](../../modulos/16-publicacao-e-proximos-passos/README.md) |
