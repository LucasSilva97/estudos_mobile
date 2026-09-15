# Avaliação — Módulo 13: Desempenho e segurança

> **Tempo sugerido:** 25 min de questões + 45 min de prática. Faça sem consultar o material.

## 1. Questionário

Cada questão vale 1 ponto.

1. O que faz `const Text('Álgebra')` cortar a subárvore no rebuild: A) o widget passa a ser imutável; B) o Dart canoniza a instância e o Flutter vê `identical` na comparação; C) o `RenderObject` fica guardado em cache; D) o widget deixa de ter `Element`.  
2. Numa lista de matérias que o usuário reordena, a key de cada item deve ser: A) `UniqueKey()`; B) `ValueKey(indice)`; C) `ValueKey(materia.id)`; D) `GlobalKey()`.  
3. Um JPEG de 4 MB, 4000 × 3000, exibido com `width: 48` e sem `cacheWidth`, ocupa na memória: A) 4 MB, o tamanho do arquivo; B) 48 × 48 × 4 bytes; C) 4000 × 3000 × 4 bytes ≈ 48 MB; D) nada além do arquivo, porque `width` já redimensiona.  
4. Um `for` de 2 s de CPU dentro de um método `async`, chamado com `await`: A) roda em outra thread e não trava; B) trava a UI por 2 s, porque `async` decide **quando**, não **onde**; C) é dividido entre os quadros pelo Flutter; D) só trava em modo debug.  
5. O quadro demorou 40 ms e a barra alta é **verde** (raster). O culpado mais provável é: A) `build` caro com muitos rebuilds; B) `jsonDecode` de 3 MB; C) `Opacity` e sombras forçando `saveLayer`; D) `setState` chamado na raiz da árvore.  
6. `GestureDetector(onTap: …, child: Icon(Icons.close, size: 24))` está errado porque: A) não tem rótulo semântico e o alvo tem 24 dp, abaixo dos 48 dp; B) `Icon` não recebe gesto; C) falta `const` no `Icon`; D) `GestureDetector` para de funcionar com o TalkBack ligado.

7. Explique por que uma conclusão de desempenho tirada em modo debug, no emulador, não vale nada.  
8. Diferencie `--dart-define` de `flutter_secure_storage`: o que cada um tira de onde.  
9. Explique por que ofuscar sem guardar os símbolos é a pior das más práticas da Aula 7.  
10. Cite dois custos que fazem `Isolate.run` **piorar** o desempenho de um trabalho pequeno.

## 2. Prática

No projeto `foco_desempenho`, a tela `ListaGrandeScreen` monta 5 000 matérias com `ListView(children:)`, decodifica a capa no tamanho original, soma os minutos de 50 000 sessões dentro do `build` e tem um botão de favoritar de 24 dp sem rótulo. Refatore a tela inteira com o que o módulo ensinou e corrija também a busca do `MateriaDao`, hoje escrita com `rawQuery` interpolado. Meça em modo profile (`flutter run --profile -d windows` ou no aparelho) e anote o pior quadro antes e depois.

| Critério | Pontos |
|---|---:|
| `ListView.builder` com `itemExtent` e `ValueKey(materia.id)` em cada item | 2 |
| Capa com `cacheWidth`/`cacheHeight` pelo `devicePixelRatio` e `errorBuilder` | 2 |
| Soma fora do `build`, em `Isolate.run`, sem capturar `context` nem `widget` | 2 |
| `tooltip`, alvo de 48 dp e `minHeight` (nunca `height`) em volta do texto | 2 |
| Busca com `where`/`whereArgs` e nenhum `print` de dado sensível | 1 |
| Medição registrada: ms do pior quadro antes e depois, em modo profile | 1 |

## 3. Critérios para avançar

- 7/10 no questionário e 8/10 na prática.
- E01–E08 concluídos e conferidos.
- `flutter analyze` sem nenhum aviso.
- Build de release gerado com `--obfuscate --split-debug-info=build/simbolos/<versão>` e símbolos guardados.

## 4. Revisão dirigida

| Dificuldade | Revisar | Refazer |
|---|---|---|
| Rebuilds, `const` e keys | [Aula 01](../modulos/13-desempenho-e-seguranca/01-rebuilds-const-e-keys.md) | E01 |
| Listas grandes e memória de imagem | [Aula 02](../modulos/13-desempenho-e-seguranca/02-listas-grandes-e-imagens.md) | E02 e E03 |
| Jank, `async` e isolates | [Aula 03](../modulos/13-desempenho-e-seguranca/03-assincrono-sem-travar.md) | E04 |
| Medir em profile, UI × raster | [Aula 04](../modulos/13-desempenho-e-seguranca/04-medindo-desempenho.md) | E05 |
| Semântica, contraste e alvo de toque | [Aula 05](../modulos/13-desempenho-e-seguranca/05-acessibilidade.md) | E06 |
| Segredos, HTTPS e `whereArgs` | [Aula 06](../modulos/13-desempenho-e-seguranca/06-seguranca-mobile.md) | E07 |
| Ofuscação e símbolos | [Aula 07](../modulos/13-desempenho-e-seguranca/07-ofuscacao-e-o-que-evitar.md) | E08 |

[Gabarito após concluir](../gabaritos/avaliacoes.md#modulo-13)
