---
name: sdd-baseline
description: Etapa condicional do pipeline SDD. Use quando o repositório (ou a área relevante a uma spec) não tem documentação base suficiente sobre um sistema/código já existente — ex.: este template foi adotado sobre um projeto legado, ou o architect sinalizou falta de grounding para desenhar um TRD. Aciona o agente codebase-archaeologist para produzir docs/BASELINE.md.
---

# /btt-sdd:sdd-baseline

Aciona o agente **arqueólogo de código**, uma etapa **condicional** do pipeline SDD descrito em
`CLAUDE.md` — só faz sentido rodar quando falta documentação base sobre código já existente.

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
   agora usar essa base para desenhar o TRD (`/btt-sdd:sdd-trd`).

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga o mesmo processo descrito no agente
`codebase-archaeologist` diretamente — nunca corrija/refatore o que encontrar, só documente.
