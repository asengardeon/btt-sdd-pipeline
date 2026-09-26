---
name: baseline
description: Etapa condicional do pipeline SDD. Use quando o repositório (ou a área relevante a uma spec) não tem documentação base suficiente sobre um sistema/código já existente — ex.: este template foi adotado sobre um projeto legado, ou o architect sinalizou falta de grounding para desenhar um TRD. Aciona o agente codebase-archaeologist para produzir docs/BASELINE.md.
---

# /btt-sdd:baseline

Aciona o agente **arqueólogo de código**, uma etapa **condicional** do pipeline SDD descrito em
`CLAUDE.md` — só faz sentido rodar quando falta documentação base sobre código já existente.

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/TESTING.md`,
`docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md` e `docs/POST-MERGE-VALIDATION.md` nesta skill apontam para os docs genéricos
deste pipeline — **não são copiados para dentro de cada projeto que o usa**. Resolva-os a partir
de onde esta própria skill está instalada (o "Base directory" desta invocação, dentro do plugin
`btt-sdd`): esses docs estão em `docs/` na raiz **deste plugin instalado**, atualizado
automaticamente a cada `claude plugin update` — não no projeto onde você está trabalhando agora.
Se o projeto atual também tiver um `docs/<nome>.md` próprio (`STACK.md`, `BASELINE.md`,
`LESSONS-LEARNED.md`, `adr/`), esse é conteúdo do projeto, não deste plugin — não confunda os
dois.

## Passos

1. Determine o escopo: o repositório inteiro, ou uma área específica relevante a uma spec em
   andamento (`args`, ou pergunte ao usuário se não estiver claro).
2. Invoque o agente `codebase-archaeologist` (Agent tool, `subagent_type:
   "codebase-archaeologist"`) passando o escopo, com instrução para produzir/atualizar
   `docs/BASELINE.md`.
3. O agente pode concluir "documentação já suficiente" sem criar nada — isso é um resultado válido
   e esperado, não uma falha. Comunique esse resultado ao usuário normalmente.
4. Se `docs/BASELINE.md` foi criado/atualizado, mostre um resumo ao usuário (visão geral do
   sistema, principais convenções e dívida técnica identificada) e informe que o `architect` pode
   agora usar essa base para desenhar o TRD (`/btt-sdd:trd`).

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `agents/codebase-archaeologist.md` diretamente — nunca
corrija/refatore o que encontrar, só documente.
