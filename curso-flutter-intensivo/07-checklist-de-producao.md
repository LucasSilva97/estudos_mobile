# Checklist de produção e revisão do curso

Este checklist acompanha a **elaboração do material**. O progresso do aluno fica separado em
[03-trilha-de-progresso.md](03-trilha-de-progresso.md). Não marque uma aula como estudada só porque
o arquivo foi criado.

## Plano de continuação

- Estrutura: 17 módulos, aulas individuais, exercícios, gabaritos, avaliações, três projetos e referências.
- Ritmo principal: intensivo, inicialmente planejado para 30 dias de 4 horas; conferir a soma das
  aulas e da prática antes de publicar o cronograma final.
- Projeto final: **Foco**, organizador de matérias, sessões de estudo, meta semanal e trilhas.
- Estado: Riverpod, sem geração de código.
- Arquitetura: funcionalidades com domínio, dados e apresentação; dependências fornecidas por providers.
- Dados: HTTP, SQLite para registros, preferências para configurações e armazenamento seguro no exemplo de tokens.
- Android: construir, assinar e validar APK/AAB; execução depende de SDK e dispositivo configurados.
- iOS: preparar o código compartilhado e ensinar assinatura, archive, IPA e TestFlight; executar em macOS/Xcode.

## Etapas

- [x] Ler os arquivos existentes e preservar o exercício pessoal em `meu_app/`.
- [x] Ler o prompt original do aluno.
- [x] Acrescentar a aula 05, exercícios, gabaritos e avaliação do módulo 00.
- [ ] Revisar os materiais do módulo 00 conforme todos os critérios do prompt original.
- [ ] Completar as aulas ausentes de lógica e Dart básico.
- [ ] Completar as práticas e avaliações dos módulos 01 a 04.
- [ ] Completar Flutter, layouts, navegação e formulários (05 a 07).
- [ ] Completar estado, API e persistência (08 a 10).
- [ ] Completar recursos nativos, testes e qualidade (11 a 13).
- [ ] Completar build, assinatura e distribuição (14 a 16).
- [ ] Implementar e explicar os três projetos, mantendo desafios separados das soluções.
- [ ] Completar avaliações cumulativas e final.
- [ ] Corrigir dependências pedagógicas e conferir a carga horária dos três ritmos.
- [ ] Verificar links, âncoras, exercícios obrigatórios e código dos exemplos.
- [ ] Registrar validações executadas e limitações no relatório final.

## Evidências já obtidas nesta continuação

Em 2026-09-14, foram executados em um laboratório temporário: retirada do staging, stash,
reset soft, revert, consulta ao reflog, recuperação por branch, regras de ignore e leitura das
versões diferentes em disco/staging/HEAD. O programa `guia_recuperacao.dart` passou em nove
cenários de execução com Dart 3.13.1. A análise informou ausência de problemas no código, mas
terminou com erro de permissão na telemetria; a tentativa fora do ambiente restrito não conseguiu
acessar o laboratório temporário. A validação do processo completo ainda precisa ser refeita.

Essas evidências não validam os exemplos herdados nem os builds Android/iOS.
