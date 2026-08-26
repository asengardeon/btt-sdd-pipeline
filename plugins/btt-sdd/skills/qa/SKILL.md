---
name: qa
description: Etapa 5 do pipeline SDD. Use depois que a revisão de código aprovou uma feature, para validar objetivamente contra o PRD/TRD e checar o gate de cobertura de 80%. Aciona o agente qa-engineer para produzir specs/<slug>/qa-report.md.
---

# /btt-sdd:qa

Aciona a **etapa 5** do pipeline SDD descrito em `CLAUDE.md`: validação de QA.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que existe `specs/<slug>/code-review.md` com veredito aprovado (ou aprovado com
   ressalvas aceitas pelo usuário). Se não existir, sugira `/btt-sdd:code-review` primeiro; se
   existir reprovado, sugira `/btt-sdd:implement` para tratar os achados antes de rodar o QA.
3. Invoque o agente `qa-engineer` (Agent tool, `subagent_type: "qa-engineer"`) passando os
   caminhos do PRD e TRD e o PR/branch da feature (`feature/<slug>`, ver `docs/GIT-WORKFLOW.md`),
   e instrução para produzir `specs/<slug>/qa-report.md` a partir de
   `specs/_template/qa-report.template.md`, referenciando o PR.
4. Mostre ao usuário o veredito geral (aprovado/reprovado) e os pontos principais do relatório.
5. Se reprovado, informe que a feature volta para `/btt-sdd:implement` com os achados listados. Se
   aprovado, informe que a próxima etapa é `/btt-sdd:security`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga o mesmo processo descrito no agente `qa-engineer`
diretamente — rode a suíte de testes e cobertura você mesmo antes de dar qualquer veredito.
