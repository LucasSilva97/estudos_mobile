# Aula 1 — Qual armazenamento usar

> **Módulo:** 10 - Persistência de Dados · **Tempo estimado:** 30 min · **Nível:** Fundamental

## 🎯 Objetivos de aprendizagem

- Classificar qualquer dado do seu app em uma de quatro categorias e escolher onde guardá-lo.
- Listar o que **não** deve ser gravado no aparelho, e por quê.
- Dizer, para cada opção, **onde o arquivo fica fisicamente** em 🤖 Android e 🍎 iOS.
- Prever o que acontece com cada tipo de dado quando o usuário **desinstala** o app e quando ele
  **restaura um backup** do sistema.
- Criar o projeto `foco_dados`, que será o laboratório das oito aulas do módulo.
- Escrever uma função Dart que representa essa árvore de decisão e testá-la.

## ✅ Pré-requisitos

- [Módulo 09 — Consumo de API](../09-consumo-de-api/README.md) concluído.
- `enum` e `switch` exaustivo — [03 — Enums](../03-dart-intermediario/07-enums.md).
- Ambiente pronto: [02-configuracao-do-ambiente.md](../../02-configuracao-do-ambiente.md).

---

## 📖 Conceito

**Persistir** um dado é gravá-lo em um meio que continua existindo depois que o processo do
aplicativo termina. Enquanto o app está aberto, tudo vive na **memória RAM** (*Random Access
Memory* — a memória rápida e volátil do aparelho, apagada quando o programa fecha). Persistir é
mover o dado para o **armazenamento** (a memória permanente do aparelho, que sobrevive ao
desligamento).

O sistema operacional do celular não dá ao seu app acesso livre ao disco. Cada aplicativo roda
dentro de um **sandbox** (*caixa de areia* — uma pasta isolada onde só ele pode ler e escrever).
Nem o seu app enxerga os dados de outro, nem o contrário. Dentro desse sandbox, existem quatro
formas práticas de guardar coisas, e este curso usa todas as quatro:

| Opção | Pacote | Serve para |
|---|---|---|
| Preferência chave-valor | `shared_preferences` | configuração pequena do usuário |
| Arquivo | `path_provider` + `dart:io` | conteúdo grande ou binário, exportação, cache de arquivo |
| Banco relacional | `sqflite` | muitos registros, com consulta, filtro e ordenação |
| Cofre criptografado | `flutter_secure_storage` | segredo: token, senha, PIN |

Escolher errado não dá erro de compilação. Dá um app lento seis meses depois, ou um vazamento de
token, ou uma migração impossível. Por isso esta aula vem antes de qualquer código de gravação.

### A árvore de decisão

Faça as perguntas **nesta ordem**, e pare na primeira que responder "sim":

```text
1. O dado é um segredo? (token, senha, PIN, chave de API, resposta de segurança)
   └─ SIM  → flutter_secure_storage                            [aula 7]
   └─ NÃO  ↓

2. O dado é um conjunto de registros que eu vou precisar FILTRAR, ORDENAR,
   CONTAR ou RELACIONAR? (matérias, sessões de estudo, histórico)
   └─ SIM  → sqflite                                           [aulas 4, 5, 6]
   └─ NÃO  ↓

3. O dado é um arquivo, um texto longo, uma imagem, um PDF, um relatório
   exportado — ou algo maior que alguns kilobytes?
   └─ SIM  → arquivo em pasta do app (path_provider)           [aula 3]
   └─ NÃO  ↓

4. É uma configuração simples: um número, um texto curto, um sim/não,
   uma lista curta de textos?
   └─ SIM  → shared_preferences                                [aula 2]
   └─ NÃO  → provavelmente você não precisa persistir isso.
```

A pergunta 4 termina em "provavelmente você não precisa persistir isso" de propósito. Dado
derivado — total de minutos da semana, porcentagem da meta, ordenação atual da lista — **se
calcula**, não se guarda. Guardar dado derivado é criar duas verdades que vão divergir.

### O que NÃO guardar no aparelho

| Não guarde | Por quê | O que fazer |
|---|---|---|
| Senha do usuário em texto | Qualquer backup, log ou aparelho com acesso administrativo expõe | Guarde o **token** de sessão no cofre, nunca a senha |
| Chave de API secreta dentro do app | O binário pode ser aberto e lido; ofuscação não é proteção | A chave fica no **servidor**; o app fala com o seu servidor |
| Dado pessoal que você não usa | Risco jurídico (LGPD) e de vazamento sem nenhum benefício | Não colete |
| Dado derivado (somas, médias, contagens) | Fica desatualizado e vira bug silencioso | Calcule na hora, com `SELECT SUM(...)` |
| A resposta inteira da API "por garantia" | Cresce sem limite e nunca é invalidada | Cacheie o que a tela usa, com validade (aula 8) |
| Log de depuração com dado do usuário | Fica no aparelho e pode ir para ferramentas de erro | Use `debugPrint` só em desenvolvimento, sem dado pessoal |

### Tamanho e formato

Não existe um limite rígido publicado para essas APIs, mas existem **ordens de grandeza** que a
prática impõe. Use esta régua:

| Volume | Formato natural | Onde |
|---|---|---|
| Um valor (número, texto curto, sim/não) | tipo primitivo | `shared_preferences` |
| Dezenas de valores independentes | várias chaves | `shared_preferences` |
| Um objeto pequeno e único (as preferências do usuário) | JSON em uma `String` | `shared_preferences` |
| Uma lista que cresce sem limite | tabela | `sqflite` |
| Qualquer coisa com busca, filtro ou ordenação | tabela | `sqflite` |
| Texto longo, CSV, PDF, imagem, áudio | bytes ou texto | arquivo |
| Segredo de qualquer tamanho | texto | `flutter_secure_storage` |

Regra prática: **se você está pensando em guardar uma lista JSON de mais de umas poucas dezenas de
itens em `shared_preferences`, o dado já pedia um banco.** O motivo é concreto: para trocar um
item, você precisa ler a lista inteira, desserializar tudo, alterar um elemento, serializar tudo
de novo e regravar tudo. É um custo que cresce com o tamanho da lista, a cada edição.

---

## 💡 Analogia

Pense na sua mesa de estudo:

- O **post-it colado no monitor** é o `shared_preferences`: cabe uma frase, você lê num relance,
  e se molhar você perde — mas é o lugar certo para "meta da semana: 600 minutos".
- A **pasta de arquivos** é o `path_provider`: cabe o trabalho inteiro impresso, mas para achar
  uma linha específica você tem que folhear tudo.
- O **fichário com abas e índice** é o `sqflite`: você acha "todas as sessões de Cálculo em
  setembro" sem ler o fichário inteiro.
- O **cofre** é o `flutter_secure_storage`: cabe pouca coisa, dá trabalho abrir, e é o único lugar
  onde você deixaria a chave do carro.

A analogia tem um limite honesto: no aparelho, os quatro ficam dentro da **mesma sala trancada**
(o sandbox do app). O cofre protege de quem já entrou na sala; ele não é uma sala diferente.

---

## 🧪 Exemplo mínimo

O app **Foco** tem estes dados. Aplique a árvore de decisão a cada um:

| Dado | Pergunta que responde "sim" | Onde |
|---|---|---|
| Meta semanal em minutos (`600`) | 4 — configuração simples | `shared_preferences` |
| Tema escolhido (claro/escuro/sistema) | 4 — configuração simples | `shared_preferences` |
| Lista de matérias (nome, cor, minutos) | 2 — precisa ordenar e relacionar | `sqflite` |
| Sessões de estudo (data, minutos, matéria) | 2 — precisa filtrar por período e somar | `sqflite` |
| Trilhas vindas da API | 2 — lista que quero mostrar offline | `sqflite` (cache, aula 8) |
| Token de acesso, se um dia houver login | 1 — é segredo | `flutter_secure_storage` |
| Relatório mensal exportado em CSV | 3 — é arquivo | arquivo em pasta do app |
| Total de minutos da semana | nenhuma — é derivado | **não guarde**, calcule |

Note o caso das trilhas: elas vêm da rede, mas a pergunta 2 responde "sim" porque você quer
mostrar a lista quando não houver internet e quer saber **quando** ela foi baixada. Cache não é
uma quinta opção: cache é um uso do banco ou do arquivo, com um carimbo de tempo junto.

---

## 📱 Aplicando no Flutter

Antes de escrever a primeira linha, crie o laboratório do módulo. Abra o **PowerShell** na pasta
onde você guarda seus projetos e rode:

```powershell
flutter create --platforms=android,ios foco_dados
```

Entre na pasta e adicione as dependências do módulo inteiro de uma vez:

```powershell
cd foco_dados
flutter pub add shared_preferences path_provider path sqflite flutter_secure_storage connectivity_plus
flutter pub add dev:sqflite_common_ffi dev:mocktail
```

> 🪟 Se aparecer `Building with plugins requires symlink support. Please enable Developer Mode`,
> ligue o **Modo de Desenvolvedor** em **Configurações → Sistema → Para desenvolvedores** e rode
> o comando de novo. Esse erro é esperado no Windows e acontece porque o Flutter cria links
> simbólicos para os plugins nativos.

Depois, abra `foco_dados/pubspec.yaml` e **confira** se as versões batem com as do curso. Se
alguma estiver diferente, corrija à mão e rode `flutter pub get`:

```yaml
environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.5.5
  path_provider: ^2.1.6
  path: ^1.9.1
  sqflite: ^2.4.4
  flutter_secure_storage: ^11.1.1
  connectivity_plus: ^7.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mocktail: ^1.0.5
  sqflite_common_ffi: ^2.4.3
```

Agora a parte que interessa: a árvore de decisão não vai ficar só na sua cabeça. Você vai
escrevê-la como código Dart puro (sem nenhum `import` do Flutter), num arquivo que serve de
documentação executável do módulo — e que os testes verificam.

---

## 💻 Código completo

> **Arquivo:** `foco_dados/lib/core/armazenamento/politica_de_armazenamento.dart`
> **Como executar:** `flutter test test/politica_de_armazenamento_test.dart`

```dart
/// Árvore de decisão de armazenamento do curso, em forma executável.
///
/// Este arquivo não importa nada do Flutter de propósito: ele é Dart puro e
/// pode ser testado sem emulador, sem aparelho e sem plugin nativo.
library;

/// As quatro formas de guardar dado no aparelho ensinadas neste módulo.
enum OpcaoDeArmazenamento {
  preferencia('shared_preferences', 'Configuração pequena do usuário'),
  arquivo('path_provider + dart:io', 'Conteúdo grande, binário ou exportado'),
  banco('sqflite', 'Muitos registros, com filtro e ordenação'),
  cofre('flutter_secure_storage', 'Segredo: token, senha, PIN'),
  naoPersistir('nenhum', 'Dado derivado: calcule em vez de guardar');

  const OpcaoDeArmazenamento(this.pacote, this.resumo);

  /// Nome do pacote que implementa a opção.
  final String pacote;

  /// Frase curta que explica quando ela é a escolha certa.
  final String resumo;
}

/// Descreve um dado do app para que a política possa classificá-lo.
class PerfilDoDado {
  const PerfilDoDado({
    required this.nome,
    this.ehSegredo = false,
    this.precisaConsultar = false,
    this.ehArquivoOuBinario = false,
    this.tamanhoAproximadoEmBytes = 0,
    this.ehDerivado = false,
  });

  /// Nome legível do dado, só para mensagens de erro e testes.
  final String nome;

  /// Token, senha, PIN, chave de API, resposta de segurança.
  final bool ehSegredo;

  /// Vai precisar de filtro, ordenação, contagem ou junção entre registros.
  final bool precisaConsultar;

  /// É um arquivo de verdade: CSV, PDF, imagem, áudio.
  final bool ehArquivoOuBinario;

  /// Tamanho estimado em bytes. Acima do limite, vira arquivo.
  final int tamanhoAproximadoEmBytes;

  /// Pode ser recalculado a partir de outros dados que já estão gravados.
  final bool ehDerivado;
}

/// Limite prático a partir do qual um valor deixa de caber bem numa
/// preferência chave-valor e passa a pedir um arquivo.
///
/// Não é um limite imposto pela API: é a ordem de grandeza em que ler e
/// regravar o valor inteiro a cada alteração começa a custar caro.
const int limiteDePreferenciaEmBytes = 8 * 1024; // 8 KB

/// Aplica a árvore de decisão da aula 1 e devolve a opção recomendada.
OpcaoDeArmazenamento escolherArmazenamento(PerfilDoDado dado) {
  if (dado.ehSegredo) {
    return OpcaoDeArmazenamento.cofre;
  }
  if (dado.ehDerivado) {
    return OpcaoDeArmazenamento.naoPersistir;
  }
  if (dado.precisaConsultar) {
    return OpcaoDeArmazenamento.banco;
  }
  if (dado.ehArquivoOuBinario ||
      dado.tamanhoAproximadoEmBytes > limiteDePreferenciaEmBytes) {
    return OpcaoDeArmazenamento.arquivo;
  }
  return OpcaoDeArmazenamento.preferencia;
}

/// Explica a escolha em uma frase, para você conferir a decisão em revisão
/// de código sem precisar reabrir a aula.
String justificar(PerfilDoDado dado) {
  final opcao = escolherArmazenamento(dado);
  final motivo = switch (opcao) {
    OpcaoDeArmazenamento.cofre => 'é segredo e não pode ficar em texto claro',
    OpcaoDeArmazenamento.naoPersistir =>
      'é derivado e pode ser recalculado sem risco de divergir',
    OpcaoDeArmazenamento.banco =>
      'precisa de consulta (filtro, ordenação ou contagem)',
    OpcaoDeArmazenamento.arquivo =>
      'é arquivo ou grande demais para uma preferência',
    OpcaoDeArmazenamento.preferencia =>
      'é uma configuração pequena e independente',
  };
  return '${dado.nome}: use ${opcao.pacote} porque $motivo.';
}
```

O teste que prova que a política funciona:

> **Arquivo:** `foco_dados/test/politica_de_armazenamento_test.dart`
> **Como executar:** `flutter test test/politica_de_armazenamento_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:foco_dados/core/armazenamento/politica_de_armazenamento.dart';

void main() {
  group('escolherArmazenamento', () {
    test('token de acesso vai para o cofre', () {
      const dado = PerfilDoDado(nome: 'Token de acesso', ehSegredo: true);
      expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.cofre);
    });

    test('segredo vence qualquer outra característica', () {
      const dado = PerfilDoDado(
        nome: 'Token de acesso',
        ehSegredo: true,
        precisaConsultar: true,
        tamanhoAproximadoEmBytes: 500000,
      );
      expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.cofre);
    });

    test('lista de sessões de estudo vai para o banco', () {
      const dado = PerfilDoDado(nome: 'Sessões', precisaConsultar: true);
      expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.banco);
    });

    test('relatório em CSV vai para arquivo', () {
      const dado = PerfilDoDado(nome: 'Relatório', ehArquivoOuBinario: true);
      expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.arquivo);
    });

    test('texto grande demais deixa de ser preferência', () {
      const dado = PerfilDoDado(
        nome: 'Anotação longa',
        tamanhoAproximadoEmBytes: 9 * 1024,
      );
      expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.arquivo);
    });

    test('meta semanal é preferência', () {
      const dado = PerfilDoDado(
        nome: 'Meta semanal',
        tamanhoAproximadoEmBytes: 4,
      );
      expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.preferencia);
    });

    test('total de minutos da semana não deve ser persistido', () {
      const dado = PerfilDoDado(nome: 'Total da semana', ehDerivado: true);
      expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.naoPersistir);
    });
  });

  test('justificar explica a escolha em uma frase', () {
    const dado = PerfilDoDado(nome: 'Meta semanal');
    expect(
      justificar(dado),
      'Meta semanal: use shared_preferences porque é uma configuração '
      'pequena e independente.',
    );
  });
}
```

Saída esperada:

```text
00:02 +8: All tests passed!
```

---

## 🔍 Explicando o código

- **`library;`** na primeira linha declara que o arquivo é uma biblioteca e permite que o
  comentário `///` acima dele documente o arquivo inteiro. Sem isso, o analisador reclama de
  comentário de documentação "solto".
- **`enum` com campos** — `OpcaoDeArmazenamento` não é um `enum` simples: cada valor carrega
  `pacote` e `resumo`. Isso é possível desde o Dart 2.17 e serve para manter o nome do pacote
  junto da opção, em vez de espalhar `if` com texto pelo app.
- **`const PerfilDoDado({...})`** — o construtor é `const` porque o objeto é imutável. Um
  construtor `const` permite que os widgets que o usam também sejam `const`, o que é um ganho real
  de desempenho (o Flutter reaproveita a instância em vez de reconstruir).
- **Ordem dos `if`** — ela **é** a árvore de decisão. Segredo vem primeiro porque um token que
  também precisa de consulta continua sendo um token: nenhuma outra característica pode
  rebaixá-lo. O teste `'segredo vence qualquer outra característica'` trava essa regra.
- **`switch` como expressão** em `justificar` — a forma `final motivo = switch (opcao) { ... };`
  é uma **expressão** `switch` (Dart 3), não um comando. Ela devolve um valor, precisa cobrir
  todos os casos do `enum` e o analisador avisa se você esquecer um. Se amanhã alguém acrescentar
  uma quinta opção, este arquivo **para de compilar** — que é exatamente o que você quer.
- **`8 * 1024`** em vez de `8192` — a multiplicação explícita comunica "8 KB" a quem lê. O
  compilador resolve isso em tempo de compilação, então não há custo.

---

## 🤖🍎 Android × iOS

Aqui há diferença real, e ela muda decisões de projeto. Estes são os locais físicos:

### Onde cada opção grava

| Opção | 🤖 Android | 🍎 iOS |
|---|---|---|
| `shared_preferences` | `/data/data/<applicationId>/shared_prefs/FlutterSharedPreferences.xml` — um arquivo XML; as chaves aparecem com o prefixo `flutter.` | `NSUserDefaults`, gravado em `Library/Preferences/<bundle-id>.plist` |
| Documentos (`getApplicationDocumentsDirectory`) | `/data/user/0/<applicationId>/app_flutter` | `<sandbox>/Documents` |
| Suporte (`getApplicationSupportDirectory`) | `/data/user/0/<applicationId>/files` | `<sandbox>/Library/Application Support` |
| Temporário (`getTemporaryDirectory`) | `/data/user/0/<applicationId>/cache` | `<sandbox>/tmp` |
| `sqflite` | `/data/data/<applicationId>/databases/<arquivo>.db` | uma pasta dentro do sandbox do app; o caminho vem de `getDatabasesPath()` e **nunca** deve ser escrito à mão |
| `flutter_secure_storage` | valores criptografados em um arquivo de preferências; a chave que os protege fica no **Android Keystore**, um armazenamento de chaves do sistema | **Keychain** do iOS — um serviço do sistema, **fora** do sandbox do app |

`<applicationId>` é o identificador do app no Android (`br.com.estudos.foco` no projeto final).
`<sandbox>` é a pasta isolada do app no iOS, com um identificador aleatório que muda a cada
instalação — por isso você **nunca** guarda um caminho absoluto: guarde o nome do arquivo e
pergunte a pasta ao `path_provider` a cada execução.

### O que acontece ao desinstalar

| Opção | 🤖 Android | 🍎 iOS |
|---|---|---|
| `shared_preferences` | apagado | apagado |
| Arquivos (documentos, suporte, temporário) | apagado | apagado |
| `sqflite` | apagado | apagado |
| `flutter_secure_storage` | apagado junto com os dados do app | ⚠️ **pode sobreviver**: itens do Keychain não são removidos quando o app é excluído |

Essa linha final é a diferença que mais pega gente desprevenida. No iOS, o usuário desinstala o
app para "limpar tudo", reinstala — e continua logado, porque o token ficou no Keychain. A
solução está na [aula 7](07-dados-sensiveis.md): na primeira execução após a instalação, apagar o
cofre. Você detecta "primeira execução" com uma chave no `shared_preferences`, que **é** apagado
na desinstalação nas duas plataformas.

### O que entra no backup do sistema

| Opção | 🤖 Android (Auto Backup) | 🍎 iOS (backup do iCloud/iTunes) |
|---|---|---|
| `shared_preferences` | entra | entra |
| Documentos | entra | entra |
| Suporte | entra | entra |
| Temporário / cache | **não entra** | **não entra** (`tmp` e `Library/Caches` são excluídos) |
| `sqflite` | entra | entra |
| `flutter_secure_storage` | depende da configuração de backup | entra criptografado; por padrão só é restaurado no mesmo aparelho |

🤖 No Android, o **Auto Backup for Apps** copia os dados do app para o Google Drive do usuário.
Ele é controlado por atributos do `<application>` no `AndroidManifest.xml`
(`android:allowBackup`, `android:dataExtractionRules` no Android 12+ e
`android:fullBackupContent` nas versões anteriores). Se o seu app guarda algo que não deve sair do
aparelho, é ali que você exclui. O módulo 15 detalha o manifesto em
[15 — Permissões Android](../15-build-android/05-permissoes-android.md).

🍎 No iOS, tudo dentro de `Documents` e `Library/Application Support` entra no backup do iCloud.
Isso tem um efeito prático: se você jogar um cache de 300 MB em `Documents`, você está consumindo
o iCloud do usuário com lixo — e a Apple considera isso motivo de rejeição. Cache vai em
`Library/Caches` ou em `tmp`. A [aula 3](03-arquivos-e-path-provider.md) mostra a chamada certa
para cada caso.

> 🍎 **SÓ NO MAC.** Inspecionar o sandbox de um iPhone (ver o `.plist` do `NSUserDefaults`, abrir
> o banco com um visualizador de SQLite) exige macOS + Xcode. No Windows você pode ler e entender
> o processo, mas não executá-lo. O caminho para 🤖 Android, esse sim, está ao seu alcance: com o
> Android SDK instalado, `adb shell run-as <applicationId> ls -l` lista o sandbox do seu próprio
> app em um aparelho de depuração. Veja o contexto completo em
> [16-build-ios/01-por-que-exige-macos.md](../16-build-ios/01-por-que-exige-macos.md).

---

## ⚠️ Erros comuns

1. **Guardar uma lista grande em `shared_preferences` "só por enquanto".**
   O "por enquanto" vira permanente e, com 500 sessões de estudo, cada edição relê e regrava as
   500. Aplique a pergunta 2 da árvore desde o primeiro dia.

2. **Guardar o caminho absoluto de um arquivo.**
   🍎 No iOS o identificador do sandbox muda a cada instalação e pode mudar em atualizações; 🤖 no
   Android o caminho muda se o app for movido para outro perfil de usuário. Guarde o **nome** do
   arquivo e reconstrua o caminho com `path_provider` a cada execução.

3. **Achar que `shared_preferences` é seguro por ficar dentro do sandbox.**
   Não é. Em um aparelho com acesso administrativo, o XML é um arquivo de texto legível. Além
   disso, ele entra no backup. Segredo vai no cofre — [aula 7](07-dados-sensiveis.md).

4. **Confundir "cache" com uma quinta opção de armazenamento.**
   Cache é um **uso**, não um lugar. Ele mora no banco ou em arquivo, sempre com um carimbo de
   tempo ao lado — [aula 8](08-cache-e-offline.md).

5. **Persistir dado derivado.**
   Gravar `totalDeMinutos` junto com as sessões cria duas fontes da verdade. Uma hora elas
   divergem e você passa a tarde procurando o bug. Use `SELECT SUM(minutos) FROM sessoes`.

6. **Escrever o `.db` dentro de `getTemporaryDirectory()`.**
   O sistema pode apagar essa pasta quando o armazenamento ficar apertado, sem avisar o app.
   Banco não é arquivo temporário: use `getDatabasesPath()` — [aula 4](04-sqflite-criando-o-banco.md).

---

## 🛠️ Exercício guiado

Vamos classificar quatro dados novos do Foco, um a um.

**Passo 1.** Crie o projeto e os dois arquivos desta aula, exatamente como estão acima.

**Passo 2.** Rode os testes e confirme `All tests passed!`:

```powershell
flutter test test/politica_de_armazenamento_test.dart
```

**Passo 3.** Acrescente ao arquivo de teste um `group` novo com estes quatro casos. Antes de
rodar, **escreva no papel** qual opção você espera para cada um:

```dart
group('novos dados do Foco', () {
  test('idioma da interface', () {
    const dado = PerfilDoDado(
      nome: 'Idioma da interface',
      tamanhoAproximadoEmBytes: 5,
    );
    expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.preferencia);
  });

  test('histórico de trilhas abertas, com data', () {
    const dado = PerfilDoDado(
      nome: 'Histórico de trilhas',
      precisaConsultar: true,
    );
    expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.banco);
  });

  test('foto de capa da matéria', () {
    const dado = PerfilDoDado(
      nome: 'Foto de capa',
      ehArquivoOuBinario: true,
      tamanhoAproximadoEmBytes: 400 * 1024,
    );
    expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.arquivo);
  });

  test('média diária de minutos', () {
    const dado = PerfilDoDado(nome: 'Média diária', ehDerivado: true);
    expect(escolherArmazenamento(dado), OpcaoDeArmazenamento.naoPersistir);
  });
});
```

**Passo 4.** Rode de novo. Se algum resultado te surpreendeu, releia a árvore de decisão até
entender **por que** aquele `if` veio antes do outro.

**Passo 5.** Rode a análise estática e confirme que está limpo:

```powershell
flutter analyze
```

Saída esperada: `No issues found!`

---

## 📝 Exercícios independentes
→ Exercícios completos em [exercicios/10-persistencia-de-dados.md](../../exercicios/10-persistencia-de-dados.md)

---

## 🏆 Desafio opcional

Acrescente ao `PerfilDoDado` o campo `bool podeSerApagadoPeloSistema` e faça a política
distinguir **arquivo permanente** de **arquivo temporário**: crie o valor
`OpcaoDeArmazenamento.arquivoTemporario` e faça `escolherArmazenamento` devolvê-lo quando o dado
for arquivo **e** puder ser recriado (um cache de imagem baixada, por exemplo).

Dois detalhes que valem o desafio:

1. Ao acrescentar o valor no `enum`, o `switch` de `justificar` **para de compilar**. Isso é o
   comportamento desejado — conserte e entenda por que o analisador te protegeu.
2. Escreva um teste que garanta que um cache de imagem vai para `arquivoTemporario` e que a foto
   de capa escolhida pelo usuário vai para `arquivo`. A diferença entre os dois é exatamente a
   diferença entre `getTemporaryDirectory()` e `getApplicationDocumentsDirectory()`, que você vai
   usar na [aula 3](03-arquivos-e-path-provider.md).

---

## 📌 Resumo

- Persistir é gravar fora da RAM; cada app grava dentro do seu **sandbox**, isolado dos demais.
- A escolha se faz por quatro perguntas, nesta ordem: **é segredo? precisa consultar? é arquivo
  ou grande? é configuração simples?** Quem não responde a nenhuma provavelmente é **dado
  derivado** e não deve ser persistido.
- Quatro opções, quatro papéis: `flutter_secure_storage` (segredo), `sqflite` (registros),
  arquivo via `path_provider` (conteúdo grande), `shared_preferences` (configuração).
- Nunca guarde senha em texto, chave de API secreta dentro do app, dado que você não usa ou
  resultado que pode ser calculado.
- Cada opção tem um **lugar físico** diferente em 🤖 Android e 🍎 iOS — e nunca se guarda caminho
  absoluto, porque ele muda entre instalações.
- Desinstalar apaga tudo nas duas plataformas, **com uma exceção**: 🍎 o Keychain do iOS pode
  sobreviver. Trate isso explicitamente.
- Backup: documentos e preferências entram; cache e temporário não entram. Isso é um argumento
  técnico para escolher a pasta certa.

---

## ☑️ Checklist de domínio

- [ ] Recito as quatro perguntas da árvore de decisão, na ordem certa, e explico por que "é
      segredo?" vem primeiro.
- [ ] Classifico os oito dados do Foco sem consultar a tabela.
- [ ] Listo três coisas que não se deve guardar no aparelho e digo o que fazer no lugar.
- [ ] Explico a diferença entre dado bruto e dado derivado, com um exemplo do Foco.
- [ ] Digo onde `shared_preferences` grava em 🤖 Android e em 🍎 iOS.
- [ ] Digo o que acontece com o cofre quando o usuário desinstala o app em cada plataforma.
- [ ] Explico por que cache não deve ficar na pasta de documentos do 🍎 iOS.
- [ ] Criei o projeto `foco_dados`, com as versões de pacote do curso, e
      `flutter test` termina com `All tests passed!`.

---

## 📚 Referências oficiais

- [Persistence — cookbook do Flutter](https://docs.flutter.dev/cookbook/persistence)
- [Store key-value data on disk](https://docs.flutter.dev/cookbook/persistence/key-value)
- [Read and write files](https://docs.flutter.dev/cookbook/persistence/reading-writing-files)
- [Persist data with SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [path_provider — pub.dev](https://pub.dev/packages/path_provider)
- [Back up user data with Auto Backup — Android](https://developer.android.com/guide/topics/data/autobackup)
- [File System Programming Guide — Apple](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)
- [Keychain Services — Apple](https://developer.apple.com/documentation/security/keychain-services)
- [Enhanced enums — dart.dev](https://dart.dev/language/enums)

---

| ⬅️ Anterior | 🏠 Módulo | ➡️ Próxima |
|---|---|---|
| [README do módulo](README.md) | [README](README.md) | [Aula 2 — shared_preferences](02-shared-preferences.md) |
