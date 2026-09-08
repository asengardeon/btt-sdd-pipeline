# Changelog do scaffold do plugin btt-sdd

Este arquivo rastreia só as mudanças em `skills/create-project/scaffold/docs/*.md` e
`skills/create-project/scaffold/CLAUDE.md` deste plugin — os arquivos que `/create-project` copia
para dentro de um projeto novo no momento em que ele é criado. Não é o changelog geral do plugin
(isso seria todo o histórico de commits/PRs); é especificamente a lista do que um projeto já
scaffolded numa versão antiga está sem, para `/sdd-sync-docs` (`docs/DOCS-SYNC.md`) comparar contra
a versão instalada e oferecer aplicar.

Cada entrada nova acontece no mesmo commit/PR que muda um desses arquivos — nunca depois
(`docs/GIT-WORKFLOW.md`, seção "Mudanças no próprio pipeline").

**Rastreamento começa nesta versão (`1.14.0`)** — mudanças de scaffold anteriores a ela não têm
entrada retroativa aqui (não há registro confiável o suficiente para reconstruir seção por seção
de todas as versões passadas). Projetos scaffolded antes de `1.14.0` que quiserem essas melhorias
mais antigas precisam comparar manualmente contra a versão atual do template uma única vez, antes
que `/sdd-sync-docs` passe a cobrir o resto a partir daqui em diante.

## 1.20.7 — 2026-09-08

- `docs/GIT-WORKFLOW.md`: a seção "Isolamento de arquivos não é isolamento de serviços com estado"
  agora deixa explícito que o `architect` decide e registra em `docs/STACK.md` o mecanismo de
  isolamento de serviço com estado (banco/fila/emulador) entre execuções concorrentes assim que a
  stack do projeto passa a depender de um, em vez de deixar essa decisão totalmente implícita
  esperando alguém perceber a lacuna só depois de uma contenção real entre agentes. (issue #107)

## 1.20.5 — 2026-09-07

- `docs/DOCS-SYNC.md`: corrige a condição que dispara a comparação estrutural completa de
  `/sdd-sync-docs` — passa a rodar também quando `docs/.sdd-plugin-version` está presente mas
  anterior a `1.15.0` (não só quando o marcador está ausente), e passa a checar também a direção
  scaffold → projeto (arquivo inteiro do scaffold ausente no projeto), não só seções dentro de
  arquivos que já existem nos dois lados. Sem essa correção, um projeto cujo marcador foi gravado
  antes da `1.15.0` existir nunca recebia essa varredura, mesmo depois de atualizar o plugin várias
  vezes — achado real num projeto com 30 seções/arquivos de scaffold ausentes, todos anteriores a
  `1.14.0`.

## 1.20.2 — 2026-09-07

- `docs/QUALITY-GATES.md`: gate novo na seção "Governança de decisão" — merge de PR nunca é ação
  de um agente, mesmo o próprio agente que implementou o ajuste sendo revisado; documenta como
  risco conhecido de agentes autônomos com escrita em sistemas compartilhados, a partir de um
  incidente real em que o agente `sre` mergeou um PR sozinho apesar de instrução explícita em
  contrário. Exceção deliberada continua sendo a skill `/repo-issues`.

## 1.20.0 — 2026-09-07

- `docs/QUALITY-GATES.md`: gate novo na seção "PRD" — se a feature tem UI e wireframes são
  oferecidos, mas `docs/DESIGN-SYSTEM.md` ainda não existir no projeto, o usuário precisa ser
  consultado sobre estabelecer um sistema de design (paleta de cores, tipografia, tom visual,
  referências) antes de gerar as opções de wireframe, com recusa explícita sempre disponível
  (`/sdd-prd` passo 2b). Uma vez estabelecido, `docs/DESIGN-SYSTEM.md` é reaproveitado pelas
  próximas features com UI sem perguntar de novo — mesmo padrão de `docs/STACK.md`.

## 1.19.2 — 2026-09-07

- `docs/QUALITY-GATES.md`: toda issue GitHub que o pipeline cria no repositório do projeto-alvo
  passa a exigir identificação estruturada da spec de origem, não só as de tarefa do TRD —
  reaproveitar o milestone da spec quando existir, ou aplicar um label `spec:<slug>` quando não
  houver milestone ainda (ex.: issue de `/sdd-hotfix` associada a uma spec sem decomposição de
  tarefas em issues).

## 1.19.0 — 2026-09-07

- `docs/QUALITY-GATES.md`: criar Issue GitHub para toda tarefa do TRD deixa de ser opcional —
  sem remote GitHub configurado/autenticado, o TRD não pode ser aprovado (só o PRD dispensa
  GitHub); `/sdd-implement`/`/sdd-hotfix` não iniciam nenhuma fatia/correção sem a issue já
  existir.

## 1.15.2 — 2026-09-04

- `docs/GIT-WORKFLOW.md`: nova subseção em "Isolamento de working tree entre agentes concorrentes"
  — isolamento de `git worktree` cobre arquivos/estado de Git, não serviços com estado
  compartilhados no host (banco de teste, emulador de nuvem local); cada agente/worktree que roda
  testes de integração contra um desses serviços precisa de instância/banco/schema isolado por
  execução.

## 1.15.1 — 2026-09-04

- `docs/GIT-WORKFLOW.md`: nova subseção em "Aguardando CI antes do merge" — timeout de job de CI
  sob alta concorrência do próprio pipeline (múltiplas fatias/PRs rodando CI em paralelo) é um
  falso-negativo conhecido; tentar `gh run rerun --failed` antes de investigar como bug de código.

## 1.15.0 — 2026-09-03

- `docs/DOCS-SYNC.md`: nova subseção "Comparação estrutural na primeira sincronização" — cobre a
  lacuna de projetos scaffolded antes do início do rastreamento deste changelog (`1.14.0`):
  `/sdd-sync-docs`, na primeira sincronização de um projeto (`docs/.sdd-plugin-version` ausente),
  agora também compara títulos de seção entre os docs do projeto e o scaffold atual, além de ler
  este changelog.

## 1.14.1 — 2026-09-03

- `docs/TESTING.md`: nova subseção "Armadilha conhecida: `testPathIgnorePatterns` do Jest com
  `<rootDir>` e path com segmento iniciado por ponto" (dentro de "Frontend (quando aplicável)") —
  documenta uma falha silenciosa do Jest no Windows quando `rootDir` contém um segmento iniciado
  por ponto (ex. `.claude/worktrees/<id>`, a convenção deste pipeline para isolamento de working
  tree), e o padrão seguro recomendado para `testPathIgnorePatterns`/`modulePathIgnorePatterns`.

## 1.14.0 — 2026-09-03

- `docs/DOCS-SYNC.md` (arquivo novo): introduz o marcador `docs/.sdd-plugin-version` e o
  mecanismo de sincronização de docs em si — este changelog é a peça de dados que o mecanismo lê.
- `CLAUDE.md`: nova linha `/sdd-sync-docs` na tabela de comandos.
