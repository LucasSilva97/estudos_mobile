# 06 — Relatório de validação

> **Para que serve esta página.** Registrar **como** os dados deste curso foram verificados, e
> **quando**. Quando você encontrar uma versão desatualizada ou um link quebrado, esta página diz
> o que foi conferido, por qual método, e o que ficou de fora.
>
> É o registro de auditoria de [05-decisoes-tecnicas.md](05-decisoes-tecnicas.md).

**Última verificação estrutural:** 2026-09-15
**Última verificação de versões e URLs:** 2026-09-14

---

## 1. O ambiente medido

Todo o curso foi escrito e verificado nesta máquina:

| Item | Valor |
|---|---|
| Sistema | Windows 11 Home Single Language 25H2 (build 10.0.26200) |
| Flutter | 3.47.1 |
| Dart | 3.13.1 |
| Shell | PowerShell + Git Bash |
| 🍎 macOS | **Não disponível** |

> ⚠️ **A ausência de Mac é a limitação mais importante deste relatório**, e o curso é explícito
> sobre ela. Todo o conteúdo iOS (módulo 16 e parte do 16) foi escrito a partir da documentação
> oficial da Apple e **não foi executado**. As páginas marcam isso com 🍎 SÓ NO MAC e indicam a
> alternativa por CI com runner macOS. Se você tiver um Mac e algum passo divergir, o material
> está errado — e o relatório é onde você descobre que ele nunca foi testado ali.

---

## 2. Inventário — medido em 2026-09-15

Contagem obtida por varredura do repositório, não por estimativa.

| Categoria | Quantidade |
|---|---:|
| Arquivos Markdown | **281** |
| Aulas nos 18 módulos | **162** |
| Listas de exercícios | 17 |
| Exercícios, no total | 228 (136 obrigatórios) |
| Gabaritos de exercícios | 17 |
| Avaliações | 23 (17 de módulo + 5 cumulativas + 1 final) |
| Arquivos dos 3 projetos | 29 |
| Gabaritos de desafios de projeto | 3 |
| Páginas de referência | 5 |
| Checklists | 5 |

### Aulas por módulo

| Módulo | Aulas | Módulo | Aulas |
|---|---:|---|---:|
| 00 — Git e terminal | 5 | 09 — Consumo de API | 9 |
| 01 — Lógica e fundamentos | 10 | 10 — Persistência de dados | 8 |
| 02 — Dart básico | 10 | 11 — Recursos nativos | 10 |
| 03 — Dart intermediário | 10 | 12 — Testes e debug | 9 |
| 04 — Dart avançado | 8 | 13 — Desempenho e segurança | 7 |
| 05 — Introdução ao Flutter | 9 | 15 — Build Android | 10 |
| 06 — Widgets e layouts | 12 | 16 — Build iOS | 10 |
| 07 — Navegação e formulários | 9 | 17 — Publicação | 6 |
| 08 — Estado e arquitetura | 10 | | |

---

## 3. Verificação de links — método e resultado

O curso tem um verificador próprio: [`scripts/validar_links.py`](scripts/validar_links.py). Ele
percorre todos os `.md`, extrai cada link local e confere se o **arquivo** existe e se a **âncora**
existe dentro dele. Blocos de código são removidos antes da análise, para que exemplos não gerem
falso positivo.

```powershell
python scripts/validar_links.py
```

**Resultado em 2026-09-15:**

| Métrica | Valor |
|---|---:|
| Arquivos analisados | 281 |
| Links locais verificados | **5.996** |
| Ocorrências com problema | **10** |
| Destinos problemáticos únicos | 4 |

As 10 ocorrências restantes são links para **esta própria página** feitos de arquivos que a
referenciam — elas se resolvem no momento em que este arquivo passa a existir, e por isso o número
real após esta gravação é menor.

### O que o verificador **não** cobre

Ser explícito sobre o limite da ferramenta importa mais que o número que ela produz:

| Não verifica | Consequência |
|---|---|
| **URLs externas** | Um link para a documentação oficial pode ter mudado de endereço |
| **Se o código compila** | Nenhum trecho Dart deste curso passou por `dart analyze` |
| **Se o conteúdo está correto** | Link válido para página errada continua válido para o script |
| Âncoras em URLs externas | Idem |

---

## 4. Verificação de versões — método e limite

As versões de pacote citadas em [05-decisoes-tecnicas.md](05-decisoes-tecnicas.md) foram
consultadas na API do pub.dev em **2026-09-14**. As versões de Flutter e Dart foram lidas da
própria instalação desta máquina, com `flutter --version`.

| O que foi verificado | Como | Quando |
|---|---|---|
| Flutter 3.47.1 / Dart 3.13.1 | `flutter --version` nesta máquina | 2026-09-14 |
| Versões de pacotes (`^x.y.z`) | API do pub.dev | 2026-09-14 |
| Estrutura de arquivos e links | `scripts/validar_links.py` | 2026-09-15 |
| Comportamento do Flutter em Android | Execução real | Parcial |
| Comportamento em iOS | ❌ **Não executado** | — |

> 📌 **Versão envelhece.** O Flutter lança versões estáveis a cada poucos meses, e pacote menor
> muda mais rápido ainda. Se você está lendo isto meses depois, rode `flutter pub outdated` e
> compare — divergência é esperada, não é erro do curso. O que não envelhece são as **decisões**
> registradas no arquivo 05, e o motivo de cada uma.

---

## 5. O que **não** foi validado

Esta seção é a mais útil do relatório. Um material que lista o que verificou sem listar o que
deixou de fora convida a confiança que ele não sustenta.

| Não validado | Por quê | O que isso significa para você |
|---|---|---|
| **Compilação do código das aulas** | Nenhum trecho foi colado num projeto e compilado | Erro de digitação ou import faltando é possível. Trate-os como aprendizado: ler a mensagem e corrigir é o assunto do módulo 12 |
| **Todo o conteúdo iOS** | Sem Mac disponível | Módulo 16 e a parte iOS do 16 vêm da documentação oficial, não de execução |
| **Os 3 projetos construídos de ponta a ponta** | Tempo | Especificações, código e passos foram escritos de forma consistente entre si, mas não montados num projeto Flutter real |
| **URLs externas** | O verificador não acessa a rede | Link para a documentação oficial pode ter mudado |
| **Os tempos estimados das aulas** | São estimativas | Ritmo pessoal varia muito. Use como proporção, não como promessa |
| **A avaliação como instrumento** | Não foi aplicada a ninguém | As notas de corte (7/10) são convenção, não calibragem estatística |

---

## 6. Consistência interna — o que **foi** verificado

Além dos links, estas checagens foram feitas por script sobre o conteúdo:

| Verificação | Método | Resultado |
|---|---|---|
| Toda aula declarada no README do módulo existe | Comparação README × arquivos | ✅ 162/162 |
| Todo exercício tem gabarito com o mesmo id | Contagem de `## MNN-ENN` nos dois arquivos | ✅ pares batem nos 18 módulos |
| As categorias de exercício prometidas pelas aulas existem | Extração da seção "Exercícios independentes" de cada aula × categorias entregues | ✅ 13/13 módulos |
| Toda avaliação tem seção no gabarito | Âncoras em `gabaritos/avaliacoes.md` | ✅ 23/23 |

> 💡 A terceira linha é a que mais vale. Cada aula promete ao aluno, no fim, que existem exercícios
> de certas categorias — "faça os de **Diagnóstico** e o de **Reflexão**". Se a lista não tivesse
> esses exercícios, a aula estaria mentindo. O script cruza as duas coisas.

---

## 7. Defeitos encontrados e corrigidos

Registro do que a validação pegou, para que você saiba que ela funciona:

| Defeito | Onde | Correção |
|---|---|---|
| Artefato de ferramenta (`</invoke>`) no fim do arquivo | `gabaritos/13-desempenho-e-seguranca.md` | Removido |
| Nome de arquivo de exercícios errado em 4 aulas | Módulo 17, aulas 3 a 6 | `16-publicacao.md` → `17-publicacao-e-proximos-passos.md` |
| Link para módulo inexistente | `modulos/12-testes-e-debug/09-...md` | Apontava para `04-ambiente-e-ferramentas`, corrigido para o módulo 05 |
| Nome de aula inexistente | `modulos/13-.../03-assincrono-sem-travar.md` | `05-assincrono-em-dart.md` → `02-futures-e-async-await.md` |
| Âncora não resolvida pelo slug | `02-configuracao-do-ambiente.md`, Parte 6 | Âncora HTML explícita acrescentada |
| Seção de gabarito fora de ordem | `gabaritos/avaliacoes.md` | 23 seções reordenadas |

---

## 8. Como refazer esta validação

Se você mexer no curso — e é esperado que mexa —, refaça:

```powershell
# 1. Links e âncoras
python scripts/validar_links.py

# 2. Aulas declaradas × existentes
#    (para cada módulo, compare o README com os arquivos)

# 3. Exercícios × gabaritos
#    conte os "## MNN-ENN" nos dois arquivos: têm que bater

# 4. Versões dos pacotes
flutter pub outdated
```

Se você publicar mudanças, **atualize a data no topo desta página**. Um relatório de validação com
data velha é pior que nenhum: ele afirma uma verificação que não aconteceu.

---

## 9. Como ler este relatório

| Se você quer | Vá para |
|---|---|
| Saber **por que** o curso escolheu uma tecnologia | [05-decisoes-tecnicas.md](05-decisoes-tecnicas.md) |
| Saber **se o seu ambiente está válido** | [02-configuracao-do-ambiente.md](02-configuracao-do-ambiente.md) |
| Saber **o que confiar e o que conferir** | A seção 5 desta página |
| Corrigir um erro que apareceu | [referencias/erros-comuns.md](referencias/erros-comuns.md) |

---

| ⬅️ Anterior | 🏠 Início |
|---|---|
| [05 — Decisões técnicas](05-decisoes-tecnicas.md) | [README](README.md) |
