# Status de tarefas (coluna "Status" da decomposição do TRD)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

Toda tarefa da tabela "Decomposição de tarefas e dependências" do TRD tem uma coluna **Status**,
fonte de verdade de onde cada atividade da spec está — nunca inferida depois por outra etapa, só
gravada por quem causa a transição.

- [ ] `architect` inicializa toda tarefa nova como `pendente`.
- [ ] **`backend-developer`/`frontend-developer` nunca editam a coluna Status.** A etapa de
  implementação tem duas transições: para `em andamento` ao despachar a fatia, e para
  `implementado` ao concluir. As duas são gravadas pelo orquestrador de `/btt-sdd:implement`, cada
  uma numa única passada (`skills/implement/SKILL.md`, passos 4e e 5). Os agentes só comentam a
  transição na Issue GitHub da própria tarefa (`agents/backend-developer.md`, passo 1b). Ela é por
  trilha, e por isso não colide. O motivo é o mesmo nos dois extremos do ciclo: duas trilhas em
  paralelo editando a mesma coluna da mesma tabela já causou um conflito mecânico real de merge.
  Vale também na retomada de uma tarefa que estava `bloqueado`. O orquestrador a devolve para `em
  andamento` antes de remandar a trilha.
- [ ] `code-reviewer`/`ux-designer`/`qa-engineer`/`security-engineer`/`sre` atualizam para
  `bloqueado` (com o motivo em uma linha) as tarefas da fatia cujo veredito desta rodada foi
  reprovado.
- [ ] `sre` atualiza para `aprovado` as tarefas da fatia ao aprová-la (ou aprovar com ressalvas) — o
  último gate antes do merge.
- [ ] `/btt-sdd:implement`, ao confirmar (pré-condição antes de iniciar a fatia seguinte) que o PR
  de uma fatia já foi mergeado em `main`, atualiza essa fatia para `concluído (mergeado)`.
- [ ] **Caso especial: a última fatia de uma spec nunca tem "fatia seguinte" para disparar a regra
  acima.** A promoção para `concluído (mergeado)` fica presa em `aprovado` para sempre se nada mais
  a confirmar — `/btt-sdd:implement`, passo 2a, cobre isso: ao ser invocado sem nenhuma fatia
  pendente, confirma o merge real da última fatia (`gh pr view <N> --json state,mergedAt`) e promove
  o Status retroativamente se ainda não tiver sido feito, antes de simplesmente informar "nada a
  fazer". Já causou um falso-positivo sistemático em 7 specs de um mesmo projeto — todas 100%
  mergeadas, reportadas como "próxima fatia pendente" indefinidamente por
  `/btt-sdd:status`/`/btt-sdd:pending`.
- [ ] Se a tarefa tem Issue GitHub associada (coluna "Issue GitHub" preenchida), a mesma transição é
  comentada na issue (`gh issue comment`) pelo mesmo agente/skill que a causou — mesma tolerância de
  falha de 3 tentativas das demais interações com `gh` no pipeline (relate o erro e siga sem
  bloquear a transição por isso).
- [ ] `/btt-sdd:implement`, ao final de cada rodada de implementação, apresenta ao usuário uma
  tabela com o Status atual de **todas** as tarefas da spec (não só as desta fatia) — visão de
  progresso ponta a ponta, não só do incremento mais recente.
