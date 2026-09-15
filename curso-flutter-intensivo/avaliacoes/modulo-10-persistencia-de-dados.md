# Avaliação — Módulo 10: Persistência de dados

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. O Foco precisa guardar 3 000 sessões de estudo, com filtro por matéria e por período. Onde elas vão? A) `setStringList` no `shared_preferences`; B) tabela no `sqflite`; C) um JSON em `getTemporaryDirectory()`; D) um JSON em `getApplicationDocumentsDirectory()`.  
2. Para persistir o modo de tema, que é um `enum`, o jeito estável é: A) `setInt('modo', modo.index)`; B) `setString('modo', modo.name)`; C) `setString('modo', modo.toString())`; D) `setBool('escuro', modo == Modo.escuro)`.  
3. O relatório CSV que o usuário exporta e espera reencontrar depois vai em: A) `getTemporaryDirectory()`; B) `getApplicationDocumentsDirectory()`; C) `getApplicationSupportDirectory()`; D) `getDatabasesPath()`.  
4. `PRAGMA foreign_keys = ON` deve ficar em: A) `onCreate`, junto dos `CREATE TABLE`; B) `onConfigure`; C) `onUpgrade`, para valer nas migrações; D) dentro da `transaction` que apaga a matéria.  
5. Você chama `insert` com `ConflictAlgorithm.replace` para atualizar uma matéria existente. O que acontece? A) nada de diferente: é equivalente a `update`; B) a linha antiga é apagada e reinserida, e o `ON DELETE CASCADE` leva as sessões junto, sem erro; C) lança `DatabaseException` de chave duplicada; D) só as colunas informadas no `Map` são gravadas.  
6. Um aparelho está na versão 1 do esquema e o app já vai na 3. O `onUpgrade` correto é: A) `if (de == 1) ... else if (de == 2) ...`; B) `if (de < 2) await _de1Para2(db); if (de < 3) await _de2Para3(db);`; C) `switch (para) { case 3: await _de2Para3(db); }`; D) `await deleteDatabase(caminho)` e recriar pelo `onCreate`.

7. Explique por que `orderBy: 'nome ASC'` coloca `Física` antes de `Álgebra` e qual é a correção adotada no curso.  
8. Diferencie o que acontece com `shared_preferences` e com `flutter_secure_storage` quando o usuário desinstala o app no 🍎 iOS — e diga o que o seu código precisa fazer por causa disso.  
9. Explique por que o curso proíbe usar `connectivity_plus` para decidir se faz a requisição, e diga para que ele serve então.  
10. Explique por que alterar o `CREATE TABLE` do `onCreate` não atualiza quem já tem o app instalado, e por que uma migração já publicada nunca é editada.

## 2. Prática

No projeto `foco_dados`, leve o banco da versão 3 para a **versão 4**: a tabela `materias` ganha
`cor INTEGER NOT NULL DEFAULT 0`. Escreva `_de3Para4`, encadeie no `atualizar` sem `else`, e
acrescente a coluna também ao `onCreate`. No `MateriaDao`, exponha `definirCor(String id, int cor)`.
Prove com `sqflite_common_ffi`: um teste abre o banco na versão 3, insere `Álgebra` e `Física`,
reabre na versão 4 e confere `PRAGMA table_info` mais os dados preservados; outro confere que
`listar()` devolve `Álgebra` antes de `Física`.

| Critério | Pontos |
|---|---:|
| `_de3Para4` com `NOT NULL DEFAULT` e encadeamento `if (de < 4)` sem `else` | 2 |
| `versaoAtual = 4` e `onCreate` já criando a coluna nova | 2 |
| Teste de migração v3 → v4 com `PRAGMA table_info` e linhas antigas intactas | 2 |
| `definirCor` com `where`/`whereArgs`, sem concatenar valor no SQL | 2 |
| Ordenação por `nome_ordenacao` provada com acento e `flutter test` verde | 2 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` com `No issues found!` e `flutter test` com `All tests passed!`.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Escolher onde cada dado mora | [Aula 01](../modulos/10-persistencia-de-dados/01-qual-armazenamento-usar.md) | E01 |
| Preferências e pastas do app | [Aulas 02 e 03](../modulos/10-persistencia-de-dados/03-arquivos-e-path-provider.md) | E02 e E03 |
| Esquema, `onConfigure` e índices | [Aula 04](../modulos/10-persistencia-de-dados/04-sqflite-criando-o-banco.md) | E04 |
| CRUD, `whereArgs` e `ORDER BY` em português | [Aula 05](../modulos/10-persistencia-de-dados/05-sqflite-crud.md) | E05 e E06 |
| Migrações e versão do esquema | [Aula 06](../modulos/10-persistencia-de-dados/06-migracoes.md) | E07 |
| Cofre, cache e modo offline | [Aulas 07 e 08](../modulos/10-persistencia-de-dados/08-cache-e-offline.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-10)
