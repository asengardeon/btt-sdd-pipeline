---
name: sdd-ux-review
description: Etapa 4b (condicional) do pipeline SDD. Use depois que a revisão de código aprovou uma fatia com superfície de UI perceptível pelo usuário final, antes do QA, para uma revisão de usabilidade/navegabilidade de designer sênior — heurísticas de Nielsen aplicadas à feature. Aciona o agente ux-designer para produzir specs/<slug>/ux-review.md. Fatia 100% backend, sem tela nem fluxo visível, pula esta etapa.
---

# /sdd-ux-review

Aciona a **etapa 4b (condicional)** do pipeline SDD descrito em `CLAUDE.md`: revisão de
usabilidade e navegabilidade por um designer de produto sênior, entre a revisão de código e o QA
— só quando a fatia tem superfície de UI/frontend perceptível pelo usuário final.

**Sempre passe por esta skill — nunca invoque o agente `ux-designer` diretamente via Agent tool**
(mesma regra das demais etapas de revisão 4-7, `CLAUDE.md`, seção do pipeline).

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/SDD-WORKFLOW.md` e
`docs/FILE-GUIDE.md` nesta skill apontam para os docs genéricos deste pipeline — **não são
copiados para dentro de cada projeto que o usa**. Resolva-os a partir de onde esta própria skill
está instalada (o "Base directory" desta invocação): se for `.claude/skills/<esta-skill>/`
apontando para este repositório via junction global (`CLAUDE.md`, seção "Distribuição global"),
esses docs estão em `docs/` na raiz **deste mesmo repositório** — não necessariamente no projeto
onde você está trabalhando agora.

## Quando esta etapa se aplica

Só quando o diff desta fatia toca alguma tela/fluxo com superfície de UI perceptível pelo usuário
final (layout, navegação, visibilidade condicional de controles, estado vazio/erro, conteúdo de
mídia) — mesmo critério usado por `.claude/skills/sdd-hotfix/SKILL.md` para decidir quando acionar
esta mesma revisão numa correção pontual. Uma fatia 100% backend/infra sem nenhuma tela afetada
pula esta etapa: registre a decisão em `specs/<slug>/ux-review.md` sob um heading padronizado `##
Decisão: UX review pulado (justificado)` com a justificativa (mesmo padrão já usado para "QA
pulado" em `/sdd-hotfix`), em vez de simplesmente não mencionar a etapa.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que existe um PR aberto com `code-review.md` aprovado (ou aprovado com ressalvas
   aceitas pelo usuário) para a fatia desta rodada. Se não, sugira `/sdd-code-review` primeiro.
2b. **Confirme que a branch está sincronizada com `main` antes de revisar** — mesmo passo 2b de
   `.claude/skills/sdd-code-review/SKILL.md`: `git fetch origin main` + `git rev-list --count
   HEAD..origin/main`; rebaseie se houver commits novos, resolvendo conflitos em arquivos de
   artefato de spec conforme `docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de merge nos
   arquivos de artefato de revisão".
3. **Se a fatia não tem superfície de UI perceptível** (ver "Quando esta etapa se aplica" acima),
   registre a decisão de pular diretamente em `specs/<slug>/ux-review.md` (crie a partir de
   `specs/_template/ux-review.template.md` só com o heading de decisão + justificativa, sem rodar
   o agente), commite e envie (push), e siga para o passo 6 informando que a próxima etapa é
   `/sdd-qa`.
4. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 4b para
   registrar a duração desta invocação. Invoque o agente `ux-designer` (Agent tool,
   `subagent_type: "ux-designer"`) passando o caminho do PRD/TRD e o PR/branch da feature, e
   instrução para produzir `specs/<slug>/ux-review.md` a partir de
   `specs/_template/ux-review.template.md`, referenciando o PR. **Sempre passe `isolation:
   "worktree"` nesta chamada** (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre
   agentes concorrentes").
4b. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 4, o horário atual, e a diferença calculada (etapa "UX review", agente "ux-designer",
   fatia desta rodada). Commit e envie (push) essa atualização junto com o resto do que esta
   rodada já for commitar.
4c. **Se o agente registrou perguntas como "VALIDAR DEPOIS" por não ter `AskUserQuestion`
   disponível nesta invocação** (subagente isolado/assíncrono — sinal típico: uma nota de processo no
   topo de `ux-review.md`, ou um item de pendência dizendo "não pude perguntar"), **você** — o
   orquestrador desta skill — apresenta essas perguntas ao usuário via *sua própria*
   `AskUserQuestion`, **antes** de informar o resultado da etapa no passo seguinte. Mesmo padrão já
   documentado para `sre` (`.claude/skills/sdd-sre/SKILL.md`, passo 4b) e para os agentes de
   implementação (`.claude/skills/sdd-implement/SKILL.md`, passo 5b). As que o usuário responder
   **deixam de ser pendência** e voltam ao relatório como decisão registrada — `SendMessage` ao
   agente `ux-designer`, se ainda endereçável, ou edição direta da tabela de pendências de
   `ux-review.md`. As que ele não souber responder agora continuam como VALIDAR DEPOIS, agora
   legitimamente. Registrar em vez de perguntar é o fallback correto **do agente**, que não tinha a
   ferramenta; não é o seu, que tem — e o usuário está disponível justamente no turno em que a etapa
   roda. Perguntas binárias de política ou de comportamento, que o usuário responderia em segundos,
   já viraram dívida em `/sdd-pending` exatamente por este passo não existir.
5. Mostre ao usuário o veredito geral (aprovado/aprovado com ressalvas/reprovado) e os achados
   principais do relatório.
6. Se reprovado, informe que a feature volta para `/sdd-implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de
   `.claude/skills/sdd-implement/SKILL.md`. Se aprovado (ou aprovado com ressalvas aceitas pelo
   usuário), ou se a etapa foi pulada por não aplicável, informe que a próxima etapa é `/sdd-qa`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/ux-designer.md` diretamente — leia o
diff do PR e, se possível, navegue os fluxos tocados você mesmo antes de dar qualquer veredito.
