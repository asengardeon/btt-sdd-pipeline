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

## 1.14.0 — 2026-09-03

- `docs/DOCS-SYNC.md` (arquivo novo): introduz o marcador `docs/.sdd-plugin-version` e o
  mecanismo de sincronização de docs em si — este changelog é a peça de dados que o mecanismo lê.
- `CLAUDE.md`: nova linha `/sdd-sync-docs` na tabela de comandos.
