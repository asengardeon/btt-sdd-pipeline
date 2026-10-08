---
name: ux-review
description: Etapa 4b (condicional) do pipeline SDD. Use depois que a revisão de código aprovou uma fatia com superfície de UI perceptível pelo usuário final, antes do QA, para uma revisão de usabilidade/navegabilidade de designer sênior — heurísticas de Nielsen aplicadas à feature. Aciona o agente ux-designer para produzir specs/<slug>/ux-review.md. Fatia 100% backend, sem tela nem fluxo visível, pula esta etapa.
---

# /btt-sdd:ux-review

Aciona a **etapa 4b (condicional)** do pipeline SDD descrito em `CLAUDE.md`: revisão de
usabilidade e navegabilidade por um designer de produto sênior, entre a revisão de código e o QA
— só quando a fatia tem superfície de UI/frontend perceptível pelo usuário final.

**Sempre passe por esta skill — nunca invoque o agente `ux-designer` diretamente via Agent tool**
(mesma regra das demais etapas de revisão 4-7, `CLAUDE.md`, seção do pipeline).

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

## Quando esta etapa se aplica

Só quando o diff desta fatia toca alguma tela/fluxo com superfície de UI perceptível pelo usuário
final (layout, navegação, visibilidade condicional de controles, estado vazio/erro, conteúdo de
mídia) — mesmo critério usado por `skills/hotfix/SKILL.md` para decidir quando acionar esta mesma
revisão numa correção pontual. Uma fatia 100% backend/infra sem nenhuma tela afetada pula esta
etapa: registre a decisão em `specs/<slug>/ux-review.md` sob um heading padronizado `## Decisão: UX
review pulado (justificado)` com a justificativa (mesmo padrão já usado para "QA pulado" em
`/btt-sdd:hotfix`), em vez de simplesmente não mencionar a etapa.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que existe um PR aberto com `code-review.md` aprovado (ou aprovado com ressalvas
   aceitas pelo usuário) para a fatia desta rodada. Se não, sugira `/btt-sdd:code-review` primeiro.
2a. **Confirme que a aprovação de code review vigente cobre o HEAD atual da branch — não só que
   ela existe.** Pegue o sha que a rodada de code review aprovou (o commit em que `code-review.md`
   foi gravado com o veredito vigente) e rode `git diff --name-only <sha>..HEAD -- <diretórios de
   produção>`. Se vier **não vazio**, esta etapa não começa: volte para `/btt-sdd:code-review` com uma
   rodada escopada ao delta (instância nova do `code-reviewer`), e só então rode a UX review
   (`docs/gates/ux.md`, item sobre frescor da aprovação). Isso é diferente do passo 2b abaixo, que
   checa `main`: aqui o que avançou foi a **própria branch da fatia** depois do carimbo.
2b. **Confirme que a branch está sincronizada com `main` antes de revisar** — mesmo passo 2b de
   `skills/code-review/SKILL.md`: `git fetch origin main` + `git rev-list --count
   HEAD..origin/main`; rebaseie se houver commits novos, resolvendo conflitos em arquivos de
   artefato de spec conforme `docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de merge nos
   arquivos de artefato de revisão".
3. **Se a fatia não tem superfície de UI perceptível** (ver "Quando esta etapa se aplica" acima),
   registre a decisão de pular diretamente em `specs/<slug>/ux-review.md` (crie a partir de
   `specs/_template/ux-review.template.md` só com o heading de decisão + justificativa, sem rodar
   o agente), commite e envie (push), e siga para o passo 6 informando que a próxima etapa é
   `/btt-sdd:qa`.
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
   rodada já for commitar. **Uma linha por etapa, sempre, e
   nenhuma linha nomeando duas etapas**: se o trabalho de orquestrador nesta etapa foi zero,
   registre `0m` com justificativa em vez de omitir a linha; se esta etapa rodou em paralelo com
   outra, são duas linhas com o mesmo horário de início, nunca uma linha "X + Y"
   (`specs/_template/timing-log.template.md`, seção "Uma linha por etapa, sempre"). **E se esta
   invocação retomou o agente em vez de criá-lo**, registre a **diferença** contra a notificação
   anterior do mesmo agente, não o contador bruto — crescimento monotônico entre rodadas é a
   assinatura de contador cumulativo desde a criação (mesmo template, seção "O que a coluna
   'Duração' mede").
4c. **Se o agente registrou perguntas como "VALIDAR DEPOIS" por não ter `AskUserQuestion` disponível
   nesta invocação** (subagente isolado/assíncrono — sinal típico: uma nota de processo no topo de
   `ux-review.md`, ou um item de pendência dizendo "não pude perguntar"), **você** — o orquestrador
   desta skill — apresenta essas perguntas ao usuário via *sua própria* `AskUserQuestion`, **antes**
   de informar o resultado da etapa no passo seguinte. Mesmo padrão já documentado para `sre`
   (`skills/sre/SKILL.md`, passo 4b) e para os agentes de implementação
   (`skills/implement/SKILL.md`, passo 5b). As que o usuário responder **deixam de ser pendência** e
   voltam ao relatório como decisão registrada — `SendMessage` ao agente `ux-designer`, se ainda
   endereçável, ou edição direta da tabela de pendências de `ux-review.md`. As que ele não souber
   responder agora continuam como VALIDAR DEPOIS, agora legitimamente. Registrar em vez de perguntar
   é o fallback correto **do agente**, que não tinha a ferramenta; não é o seu, que tem — e o
   usuário está disponível justamente no turno em que a etapa roda. Perguntas binárias de política
   ou de comportamento, que o usuário responderia em segundos, já viraram dívida em
   `/btt-sdd:pending` exatamente por este passo não existir. **E se a pergunta que você
   intermediou era uma oferta de escalonamento de uma entrada de `docs/LESSONS-LEARNED.md`**
   (`docs/gates/licoes.md`, bullets sobre entrada que atinge 3 ocorrências), **escreva a resposta do
   usuário no campo `Escalonamento` da entrada correspondente neste mesmo turno** — não só no
   artefato da rodada. O gate instrui a *ler* o campo antes de ofertar de novo, mas sem dono para o
   preenchimento ele acumula `sem resposta` em entradas cuja resposta já foi dada, e a rodada
   seguinte repete a oferta que o campo existe para evitar. Já aconteceu de uma entrada ter
   `Escalonamento: sem resposta` com a decisão do usuário registrada em prosa no corpo do artefato
   da rodada — terceira vez na mesma spec que uma decisão existia em prosa e não no campo
   estruturado que a consome.
5. Mostre ao usuário o veredito geral (aprovado/aprovado com ressalvas/reprovado) e os achados
   principais do relatório.
6. Se reprovado, informe que a feature volta para `/btt-sdd:implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de `skills/implement/SKILL.md`. Se
   aprovado (ou aprovado com ressalvas aceitas pelo usuário), ou se a etapa foi pulada por não
   aplicável, informe que a próxima etapa é `/btt-sdd:qa`.
6b. **Quando as correções de achados desta etapa tocam código de produção, o retorno é para
   `/btt-sdd:code-review` escopado ao delta — não direto para `/btt-sdd:qa`.** Vale tanto para um veredito
   reprovado quanto para ressalvas de comportamento que o usuário aceitou e mandou corrigir: esta
   etapa roda **depois** da 4, então todo código que ela faz nascer é código que nenhuma rodada de
   revisão viu. Depois da correção, o carimbo de `code-review.md` cobre um HEAD que já não existe —
   e as etapas 5/6/7 têm, cada uma, um item de gate que **bloqueia** nesse estado
   (`docs/gates/ux.md`/`qa.md`/`seguranca.md`, item sobre frescor da aprovação). A rodada de volta é
   escopada ao delta (só o que mudou desde o sha aprovado), numa instância nova do `code-reviewer`,
   não uma revisão completa da fatia do zero.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `agents/ux-designer.md` diretamente — leia o diff do PR
e, se possível, navegue os fluxos tocados você mesmo antes de dar qualquer veredito.
