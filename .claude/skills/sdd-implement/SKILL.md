---
name: sdd-implement
description: Etapa 3 do pipeline SDD. Use depois que um TRD existe e foi aprovado, para implementar a feature em código. Aciona o agente senior-developer para gerar código e testes via TDD seguindo o TRD.
---

# /sdd-implement

Aciona a **etapa 3** do pipeline SDD descrito em `CLAUDE.md`: implementação via TDD a partir do
TRD.

## Passos

1. Identifique o slug da feature (mesma lógica de `/sdd-trd`: `args`, ou única spec com `trd.md`
   sem implementação concluída, ou perguntar).
2. Confirme que `specs/<slug>/trd.md` existe. Se não existir, sugira `/sdd-trd` primeiro.
3. Invoque o agente `senior-developer` (Agent tool, `subagent_type: "senior-developer"`) passando
   o caminho do TRD e do PRD, e lembrando explicitamente das regras não negociáveis: TDD estrito,
   ports & adapters, SOLID, clean code, cobertura ≥ 80%.
4. Ao terminar, peça ao agente (ou confirme você mesmo) que rode lint + suíte de testes +
   relatório de cobertura como evidência de conclusão.
5. Mostre ao usuário um resumo do que foi implementado, os comandos usados para rodar os testes,
   e o número de cobertura obtido.
6. Ao final, informe que a próxima etapa é `/sdd-qa`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/senior-developer.md` diretamente,
mantendo o mesmo rigor de TDD.
