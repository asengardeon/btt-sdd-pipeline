---
name: sdd-implement
description: Etapa 3 do pipeline SDD. Use depois que um TRD existe e foi aprovado, para implementar a feature em código. Aciona o agente senior-developer para gerar código e testes via TDD seguindo o TRD, com plano de implementação aprovado antes de qualquer código e em uma branch GitHub Flow.
---

# /sdd-implement

Aciona a **etapa 3** do pipeline SDD descrito em `CLAUDE.md`: implementação via TDD a partir do
TRD, em uma branch GitHub Flow (`docs/GIT-WORKFLOW.md`).

## Passos

1. Identifique o slug da feature (mesma lógica de `/sdd-trd`: `args`, ou única spec com `trd.md`
   sem implementação concluída, ou perguntar).
2. Confirme que `specs/<slug>/trd.md` existe. Se não existir, sugira `/sdd-trd` primeiro.
3. Invoque o agente `senior-developer` (Agent tool, `subagent_type: "senior-developer"`) passando
   o caminho do TRD e do PRD. O agente segue seu próprio processo em duas fases: primeiro
   apresenta um plano de implementação (incrementos + branch) e pede sua aprovação via
   `AskUserQuestion` — **não escreve código antes disso** — e só depois de aprovado cria a branch,
   implementa via TDD e abre o PR. Você não precisa orquestrar essas duas fases manualmente; o
   gate de aprovação já está dentro do agente.
4. Ao terminar, confirme que lint + suíte de testes + relatório de cobertura foram rodados como
   evidência de conclusão, e que a branch/PR foram de fato criados.
5. Mostre ao usuário um resumo do que foi implementado, o link/nome do PR, os comandos usados para
   rodar os testes, e o número de cobertura obtido.
6. Ao final, informe que a próxima etapa é `/sdd-qa`, referenciando o PR.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/senior-developer.md` diretamente,
mantendo o mesmo rigor de TDD e o gate de aprovação do plano antes de codar.
