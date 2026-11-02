# Fallback: agente assíncrono devolveu pergunta/plano em texto puro

Gatilho: **fallback, não o caminho esperado.** Com o passo 4 do núcleo seguido corretamente, o
plano já foi aprovado por você antes da invocação e nenhum agente devolve plano em texto puro.
Este arquivo existe para o desvio: `backend-developer`/`frontend-developer` rodando como subagente
assíncrono/em background (`isolation: "worktree"` ou equivalente) devolveu uma pergunta/plano em
texto puro (sinal de que `AskUserQuestion` não estava disponível para ele nesse modo — mesmo
padrão já documentado para `sre`/`/btt-sdd:sre`, `skills/sre/SKILL.md`, passo 4b).

O tratamento depende de **quando** isso aconteceu:

- **Ambiguidade pontual no meio da execução ou no resumo final** (o agente já seguiu com a
  alternativa mais conservadora e registrou a pendência): **você** — o orquestrador desta skill —
  é responsável por apresentar essa pergunta ao usuário via *sua própria* `AskUserQuestion` e
  repassar a resposta de volta ao agente (`SendMessage`, se ele ainda estiver ativo/endereçável)
  antes de considerar a trilha concluída. Nunca deixe a pergunta sem resposta só porque o agente
  já seguiu em frente registrando-a como pendência — isso é aceitável como fallback do próprio
  agente (nenhuma suposição silenciosa ainda assim vira "VALIDAR DEPOIS" no artefato), mas não
  dispensa você de tentar obter a resposta real do usuário nesta mesma rodada quando possível.
- **O plano inteiro da Fase 1 voltou em texto puro, sem nenhuma implementação ainda** (o agente
  parou de propósito, sem tocar código — `agents/backend-developer.md`/
  `agents/frontend-developer.md`, Fase 1, passo 3): **nunca trate isso como se já fosse
  conclusão da trilha.** Apresente o plano ao usuário via sua própria `AskUserQuestion` e, só
  depois de aprovação explícita, retome o agente (`SendMessage`) autorizando a Fase 2. O agente
  fica parado indefinidamente até essa retomada — diferente do caso anterior, aqui não há trabalho
  de trilha em andamento para "considerar concluído": não existe ainda. Chegar aqui significa que
  a instrução "este plano já foi aprovado pelo orquestrador" não foi passada: a parada é
  recuperável, mas o custo dela (horas de relógio) é justamente o que o passo 4 do núcleo existe
  para evitar.
