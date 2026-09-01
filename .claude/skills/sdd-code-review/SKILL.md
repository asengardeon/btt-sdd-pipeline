---
name: sdd-code-review
description: Etapa 4 do pipeline SDD. Use depois que a implementação de uma feature está pronta (PR aberto), antes do QA, para uma revisão de código de engenheiro sênior — ports & adapters, SOLID, clean code, qualidade dos testes. Aciona o agente code-reviewer para produzir specs/<slug>/code-review.md.
---

# /sdd-code-review

Aciona a **etapa 4** do pipeline SDD descrito em `CLAUDE.md`: revisão de código por um engenheiro
de software sênior, entre a implementação e o QA.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que existe um PR aberto pela etapa de implementação (branch `feature/<NNNN-slug>`,
   ver `docs/GIT-WORKFLOW.md`). Se não, sugira `/sdd-implement` primeiro.
3. Invoque o agente `code-reviewer` (Agent tool, `subagent_type: "code-reviewer"`) passando o
   caminho do TRD e o PR/branch da feature, e instrução para produzir
   `specs/<slug>/code-review.md` a partir de `specs/_template/code-review.template.md`,
   referenciando o PR. **Se outra tarefa desta sessão ainda pode estar ativa na mesma branch**
   (ex.: uma correção retomada via `SendMessage` que ainda não terminou), passe `isolation:
   "worktree"` nesta chamada — nunca deixe dois agentes dividirem o mesmo diretório de trabalho
   (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes").
4. Mostre ao usuário o veredito geral (aprovado/aprovado com ressalvas/reprovado) e os achados
   principais do relatório.
5. Se reprovado, informe que a feature volta para `/sdd-implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de
   `.claude/skills/sdd-implement/SKILL.md` (prefira retomar o mesmo agente que implementou a
   fatia via `SendMessage` para correções pequenas e objetivas, em vez de invocar um agente novo).
   Se aprovado (ou aprovado com ressalvas aceitas pelo usuário), informe que a próxima etapa é
   `/sdd-qa`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/code-reviewer.md` diretamente — leia
o diff do PR você mesmo antes de dar qualquer veredito.
