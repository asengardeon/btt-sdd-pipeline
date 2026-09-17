# Guia para o Claude Code

Este projeto usa **SDD — Spec-Driven Development**, o pipeline do agente/skill `btt-sdd`: toda
feature nasce de uma especificação de produto, passa por um desenho técnico revisável, é
implementada com TDD e só chega a produção depois de revisão de código, QA, revisão de segurança e
validação de SRE.

**Os agentes, skills e docs de governança genéricos deste pipeline (`GIT-WORKFLOW.md`,
`QUALITY-GATES.md`, `TESTING.md`, `ENGINEERING-PILLARS.md`, `ARCHITECTURE.md`,
`SDD-WORKFLOW.md`, `FILE-GUIDE.md`, `POST-MERGE-VALIDATION.md`) não vivem neste projeto** — vêm
do plugin `btt-sdd` instalado (`claude plugin install`) ou da distribuição global via junction,
e se mantêm sempre atualizados sozinhos (`claude plugin update`, ou live via junction). Não há
cópia local desses docs para sincronizar. O `docs/` deste projeto só tem conteúdo que é
genuinamente dele: `STACK.md` (decisão de stack, criada pelo `architect` no primeiro TRD),
`BASELINE.md` (condicional), `LESSONS-LEARNED.md` (condicional) e `adr/` (decisões de arquitetura
específicas deste projeto).

Comandos disponíveis: `/sdd-prd`, `/sdd-trd`, `/sdd-implement`, `/sdd-code-review`, `/sdd-qa`,
`/sdd-security`, `/sdd-sre`, `/sdd-baseline`, `/sdd-hotfix`, `/sdd-status`, `/sdd-amend`,
`/sdd-pending`, `/sdd-gap-report` (ou os equivalentes `/btt-sdd:*` se instalado via plugin). Cada
um explica seu próprio papel quando invocado — não precisa memorizar a lista aqui.

## Próximo passo

Este projeto acabou de ser criado por `/create-project` — ainda não tem stack, código, nem
infraestrutura definidos. O primeiro PRD deve estar em `specs/0001-<slug>/prd.md`; aprove-o e
rode `/sdd-trd` para o `architect` desenhar a solução técnica (é aí que a stack é decidida e
`docs/STACK.md` nasce).
