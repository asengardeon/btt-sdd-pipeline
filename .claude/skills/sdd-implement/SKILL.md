---
name: sdd-implement
description: Etapa 3 do pipeline SDD. Use depois que um TRD existe e foi aprovado, para implementar a feature em código. Aciona backend-developer e/ou frontend-developer (em paralelo quando a feature é full-stack) para gerar código e testes via TDD seguindo o TRD, com plano de implementação aprovado antes de qualquer código e em uma branch GitHub Flow.
---

# /sdd-implement

Aciona a **etapa 3** do pipeline SDD descrito em `CLAUDE.md`: implementação via TDD a partir do
TRD, em uma branch GitHub Flow (`docs/GIT-WORKFLOW.md`).

## Passos

1. Identifique o TRD: se `args` é um caminho de arquivo existente, use-o diretamente; senão,
   resolva pela convenção `specs/<slug>/trd.md` (mesma lógica de `/sdd-trd`: `args` como slug, ou
   única spec com `trd.md` sem implementação concluída, ou perguntar). Confirme que existe. Se
   não existir, sugira `/sdd-trd` primeiro.
2. Leia a tabela "Decomposição de tarefas e dependências" do TRD e veja quais trilhas aparecem
   (`backend`, `frontend`, `ambos`).
2b. Se restar mais de uma "fatia de valor" independente por implementar (histórias de usuário sem
   dependência direta entre si, segundo a seção "Ordem de valor / dependências entre histórias" do
   PRD), **não** monte automaticamente um plano cobrindo todas de uma vez. Proponha a próxima fatia
   por ordem de valor (a história de menor "Depende de" ainda não implementada) como escopo desta
   rodada, e confirme explicitamente com o usuário via `AskUserQuestion` — oferecendo as outras
   fatias disponíveis como alternativa — antes de montar o plano combinado do passo 4. Isso vale
   tanto para full-stack quanto para trilha única. Só bata múltiplas fatias numa mesma rodada se o
   usuário pedir isso explicitamente.
3. **Se só uma trilha aparece** (só backend ou só frontend): invoque o agente correspondente
   (`backend-developer` ou `frontend-developer`, Agent tool) passando os caminhos do TRD e do
   PRD. O agente segue seu próprio processo em duas fases (plano aprovado via `AskUserQuestion`
   antes de codar) — você não precisa orquestrar isso manualmente.
4. **Se as duas trilhas aparecem** (feature full-stack): você orquestra o plano combinado antes
   de invocar os agentes:
   a. Leia o TRD (contrato "Frontend↔Backend" e a decomposição de tarefas) e o PRD.
   b. Monte um plano combinado: incrementos de backend + incrementos de frontend, e como cada um
      se encaixa no contrato (ex.: "backend implementa o endpoint X no incremento 2; frontend
      constrói o client contra esse mesmo contrato, em paralelo, desde o incremento 1, usando um
      dublê até o endpoint existir de verdade").
   c. Apresente esse plano combinado ao usuário via `AskUserQuestion` e só prossiga com aprovação
      explícita (mesmo limite de 3 repetições dos outros agentes — na 3ª rodada sem convergência,
      registre como VALIDAR DEPOIS no TRD e pare).
   d. Só depois de aprovado, invoque `backend-developer` e `frontend-developer` **em paralelo**
      (uma única mensagem, duas chamadas de Agent tool), cada um com a instrução explícita: "este
      plano já foi aprovado pelo orquestrador de /sdd-implement — pule sua Fase 1 e execute
      direto a sua trilha: <trilha específica do agente, extraída do plano combinado>".
5. Ao terminar (uma ou duas trilhas), confirme que cada agente rodou a **suíte completa** com
   relatório de cobertura **uma única vez, ao final da sua trilha** (não a cada task/incremento —
   durante o TDD, cada task roda só os testes que ela toca) em cada pacote afetado (`src/` e/ou
   `frontend/`) como evidência de conclusão, junto com lint sem erros, e que a branch/PR foram de
   fato criados (uma única branch/PR mesmo com as duas trilhas).
6. Mostre ao usuário um resumo do que foi implementado (por trilha, se full-stack), o link/nome
   do PR, os comandos usados para rodar os testes, e a cobertura obtida por pacote.
7. Ao final, informe que a próxima etapa é `/sdd-code-review`, referenciando o PR.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/backend-developer.md` e/ou
`.claude/agents/frontend-developer.md` diretamente, mantendo o mesmo rigor de TDD e o gate de
aprovação do plano antes de codar.
