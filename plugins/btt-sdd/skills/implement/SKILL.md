---
name: implement
description: Etapa 3 do pipeline SDD. Use depois que um TRD existe e foi aprovado, para implementar a feature em código. Aciona backend-developer e/ou frontend-developer (em paralelo quando a feature é full-stack) para gerar código e testes via TDD seguindo o TRD, com plano de implementação aprovado antes de qualquer código e em uma branch GitHub Flow.
---

# /btt-sdd:implement

Aciona a **etapa 3** do pipeline SDD descrito em `CLAUDE.md`: implementação via TDD a partir do
TRD, em uma branch GitHub Flow (`docs/GIT-WORKFLOW.md`).

## Retomando para corrigir achados de revisão (não recomeçando do zero)

Quando `/btt-sdd:implement` é acionado porque `/btt-sdd:code-review`, `/btt-sdd:qa`,
`/btt-sdd:security` ou `/btt-sdd:sre` reprovaram (ou levantaram achados sobre) uma fatia que um
agente de implementação (`backend-developer`/`frontend-developer`) **acabou de entregar nesta
mesma sessão**, este não é o fluxo normal de "nova fatia" — pule os passos 1-4 abaixo e trate
assim:

1. Se a correção pedida é pequena e objetiva (ex.: ajustar um estado/atributo faltante, corrigir
   um valor, adicionar um teste específico apontado pelo relatório — não uma decisão de design
   nova nem redesenho de arquitetura), **prefira retomar o mesmo agente** que implementou a fatia,
   via `SendMessage` (usando o `agentId`/nome dele), em vez de invocar um agente novo do zero.
   Passe os achados do relatório de revisão (`code-review.md`/`qa-report.md`/
   `security-review.md`/`sre-review.md`) diretamente na mensagem.
2. Só prefira um agente **novo** (voltando aos passos 1-4 normais) quando: (a) a correção exige
   julgamento/desenho novo, não só aplicar o que já foi apontado; (b) o agente original já não
   está mais endereçável (sessão encerrada, `ListAgents` não o lista mais e uma tentativa de
   `SendMessage` falha); ou (c) o achado está fora do escopo do que aquele agente tocou (ex.: uma
   parte do sistema que ele nunca abriu).
3. Retomar não abre mão de rigor: o agente retomado ainda segue TDD (teste antes da correção, red
   → green → refactor) e ainda roda a suíte completa com cobertura ao final, como no passo 5
   abaixo. A próxima rodada da mesma etapa de revisão que reprovou continua verificando o
   resultado de forma independente.

## Passos (implementação de uma fatia nova)

1. Identifique o TRD: se `args` é um caminho de arquivo existente, use-o diretamente; senão,
   resolva pela convenção `specs/<slug>/trd.md` (mesma lógica de `/btt-sdd:trd`: `args` como slug, ou
   única spec com `trd.md` sem implementação concluída, ou perguntar). Confirme que existe. Se
   não existir, sugira `/btt-sdd:trd` primeiro. Verifique também se `docs/LESSONS-LEARNED.md`
   existe (mesmo tratamento condicional de `docs/STACK.md`/`docs/BASELINE.md`) — se existir, é
   passado como grounding adicional ao(s) agente(s) invocado(s) nos passos seguintes.
2. Leia a tabela "Decomposição de tarefas e dependências (fatias verticais de entrega)" do TRD e
   veja quais trilhas aparecem (`backend`, `frontend`, `ambos`) e a que fatia (coluna "Fatia
   (PRD)") cada tarefa pertence.
2b. Se restar mais de uma fatia vertical por implementar, **não** monte automaticamente um plano
   cobrindo todas de uma vez — cada fatia é sua própria branch/PR (`docs/GIT-WORKFLOW.md`).
   Proponha a próxima fatia pendente, na ordem da tabela (a de menor "Depende de" ainda não
   implementada), como escopo desta rodada, e confirme explicitamente com o usuário via
   `AskUserQuestion` — oferecendo as outras fatias disponíveis como alternativa — antes de montar
   o plano combinado do passo 4. Isso vale tanto para full-stack quanto para trilha única. Só bata
   múltiplas fatias numa mesma rodada (mesma branch/PR) se o usuário pedir isso explicitamente,
   deixando claro que isso abre mão da entrega incremental fatia-a-fatia.
2c. **Antes de criar a branch desta rodada**, se a fatia não é a primeira, confirme que o PR da
   fatia anterior já foi mergeado em `main` (`docs/GIT-WORKFLOW.md`, regra 3, tem o comando). Se
   não estiver, **pare aqui** e informe o usuário — não invoque os agentes de desenvolvimento
   sobre uma `main` desatualizada. Ao confirmar o merge, atualize (se ainda não estiver) a coluna
   Status das tarefas dessa fatia anterior no TRD para `concluído (mergeado)`.
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
      plano já foi aprovado pelo orquestrador de /btt-sdd:implement — pule sua Fase 1 e execute
      direto a sua trilha: <trilha específica do agente, extraída do plano combinado>".
5. Ao terminar (uma ou duas trilhas), confirme que cada agente rodou a **suíte completa** com
   relatório de cobertura **uma única vez, ao final da sua trilha** (não a cada task/incremento —
   durante o TDD, cada task roda só os testes que ela toca) em cada pacote afetado (`src/` e/ou
   `frontend/`) como evidência de conclusão, junto com lint sem erros, e que a branch/PR **desta
   fatia** foram de fato criados (uma única branch/PR por fatia, mesmo com as duas trilhas).
6. Mostre ao usuário um resumo do que foi implementado nesta fatia (por trilha, se full-stack), o
   link/nome do PR, os comandos usados para rodar os testes, e a cobertura obtida por pacote.
   **Inclua também uma tabela resumo do Status atual de todas as tarefas da spec** (não só desta
   fatia), extraída da coluna Status da tabela "Decomposição de tarefas e dependências" do TRD
   (colunas ID | Tarefa | Fatia | Status) — visão de progresso ponta a ponta da spec, não só do
   incremento mais recente (`docs/QUALITY-GATES.md`, seção "Status de tarefas").
7. Ao final, informe que a próxima etapa é `/btt-sdd:code-review`, referenciando o PR desta
   fatia. Se houver fatias seguintes pendentes, informe também que elas só começam depois deste PR
   passar por code review, QA, segurança, SRE e ser mergeado em `main` (`docs/GIT-WORKFLOW.md`) —
   rodar `/btt-sdd:implement` de novo nesta feature depois do merge retoma a partir da próxima
   fatia.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga o mesmo processo descrito nos agentes
`backend-developer` e/ou `frontend-developer` diretamente, mantendo o mesmo rigor de TDD e o gate de
aprovação do plano antes de codar.
