---
name: code-review
description: Etapa 4 do pipeline SDD. Use depois que a implementação de uma feature está pronta (PR aberto), antes do QA, para uma revisão de código de engenheiro sênior — ports & adapters, SOLID, clean code, qualidade dos testes. Aciona o agente code-reviewer para produzir specs/<slug>/code-review.md.
---

# /btt-sdd:code-review

Aciona a **etapa 4** do pipeline SDD descrito em `CLAUDE.md`: revisão de código por um engenheiro
de software sênior, entre a implementação e o QA.

**Sempre passe por esta skill — nunca invoque o agente `code-reviewer` diretamente via Agent tool**
(diferente da etapa 3, onde invocar `backend-developer`/`frontend-developer` direto é o padrão
correto). Esta skill carrega o **roteamento da etapa seguinte** (passo 5: etapa 4b ou QA, conforme
o diff da fatia), que o agente sozinho não faz — e o hábito de pular a skill nas etapas 4-7 já
causou passos de outras skills de revisão (`/btt-sdd:sre`) serem pulados silenciosamente numa sessão
real, além de uma fatia inteira atravessar o pipeline sem a etapa 4b — ver `CLAUDE.md`, seção do
pipeline.

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que existe um PR aberto pela etapa de implementação (branch `feature/<NNNN-slug>`,
   ver `docs/GIT-WORKFLOW.md`). Se não, sugira `/btt-sdd:implement` primeiro.
2b. **Confirme que a branch está sincronizada com `main` antes de revisar.** Rode `git fetch origin
   main` e `git rev-list --count HEAD..origin/main` — se houver commits novos em `main` desde que
   esta branch nasceu (ex.: merge de um hotfix concorrente da mesma spec enquanto esta fatia ainda
   estava em revisão), rebaseie a branch da fatia sobre `origin/main` antes de prosseguir,
   resolvendo eventuais conflitos nos arquivos de artefato da spec (`code-review.md`/
   `qa-report.md`/`security-review.md`/`sre-review.md`/`trd.md`) preservando o conteúdo de ambos os
   lados quando tocarem os mesmos arquivos (`docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de
   merge nos arquivos de artefato de revisão", tem o passo a passo de como preservar a estrutura
   Markdown desses arquivos), e envie (push) o resultado. Isso evita que esta e as etapas seguintes
   (QA, segurança, SRE) commitem "às cegas" sobre uma base que já vai gerar conflito — descoberto só
   na última etapa, exigindo uma correção retroativa. **Se o rebase trouxe commits substanciais de
   outra feature mergeada** (não só um hotfix pontual da mesma spec), informe explicitamente ao
   `code-reviewer` que vai revisar esta rodada: qualquer varredura exaustiva de propagação de
   campo/assinatura (ex.: "todo `new <Entidade>(` do repositório") que
   `backend-developer`/`frontend-developer` tenha rodado *antes* deste rebase pode estar
   desatualizada — código novo trazido pelo rebase pode ter introduzido um ponto de propagação que a
   varredura original não podia ver. Não é motivo para reprovar de antemão; é sinal para o
   `code-reviewer` reconfirmar com uma varredura própria (área 9 de `agents/code-reviewer.md`) em
   vez de confiar que "já rodei isso uma vez" continua válido.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3b para
   registrar a duração desta invocação. Invoque o agente `code-reviewer` (Agent tool,
   `subagent_type: "code-reviewer"`) passando o caminho do TRD e o PR/branch da feature, e
   instrução para produzir `specs/<slug>/code-review.md` a partir de
   `specs/_template/code-review.template.md`, referenciando o PR. **Sempre passe `isolation:
   "worktree"` nesta chamada** — nunca deixe dois agentes dividirem o mesmo diretório de trabalho
   (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes"). Não é
   uma condição a avaliar caso a caso ("outra tarefa pode estar ativa?", ex.: uma correção retomada
   via `SendMessage` que ainda não terminou) — é o padrão desta invocação.
3a. **Ao incluir na instrução um fato que outra etapa mediu, diga quem mediu e como — e marque se
   ele é carga para alguma conclusão desta etapa.** Repassar o que a etapa anterior já mediu é
   desejável (é para isso que as seções "o que a próxima etapa herda" existem), mas a repetição
   **lava a origem**: o que era "medido pela etapa X, com o método Y" chega como premissa sem
   procedência, indistinguível de um fato do desenho — e quem recebe não tem como saber que precisa
   reconferir. Rotule assim: *"medido pelo `security-engineer` lendo `pull_request.base.sha` —
   **reconfira se sua conclusão depender disso**"*. Vale também para medição **sua**, de
   orquestrador: diga o que você leu para chegar nela. Já aconteceu de verdade, duas vezes na mesma
   fatia: (a) um achado de segurança afirmava que o pulo de um job de CI vinha "inteiramente" de uma
   condição, com base em ler `pull_request.base.sha`; repassado como fato medido, o `sre` reconferiu
   por iniciativa própria e descobriu que em evento `synchronize` o `base` efetivo é
   `github.event.before` — a causa variava de run para run, e **o defeito era pior do que o
   descrito**; (b) o orquestrador afirmou "1 módulo do Workbox importado", verdade no fonte e errado
   sobre o artefato construído (que tinha marcadores de 4), e o `security-engineer` corrigiu. Nos
   dois casos o resultado foi bom **por iniciativa do agente que recebeu**, não por instrução — e
   uma medição errada herdada custa mais que uma remedição.
3b. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "Code review", agente
   "code-reviewer", fatia desta rodada). Commit e envie (push) essa atualização junto com o resto
   do que esta rodada já for commitar (`docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar pushes
   relacionados). **Vale também quando esta invocação é só uma reverificação pontual de um achado
   específico** (`code-reviewer.md`, seção "Escopo de uma rodada de reverificação de achado
   específico") — nunca pule este registro por ser "só uma reverificação", senão o `timing-log.md`
   da fatia fica sistematicamente incompleto. **Quando a reverificação pontual retoma o agente
   via `SendMessage` em vez de abrir uma invocação nova, o passo 3 não acontece — anote o horário
   antes do `SendMessage` do mesmo jeito.** **Uma linha por etapa, sempre, e
   nenhuma linha nomeando duas etapas**: se o trabalho de orquestrador nesta etapa foi zero,
   registre `0m` com justificativa em vez de omitir a linha; se esta etapa rodou em paralelo com
   outra, são duas linhas com o mesmo horário de início, nunca uma linha "X + Y"
   (`specs/_template/timing-log.template.md`, seção "Uma linha por etapa, sempre"). **E se esta
   invocação retomou o agente em vez de criá-lo**, registre a **diferença** contra a notificação
   anterior do mesmo agente, não o contador bruto — crescimento monotônico entre rodadas é a
   assinatura de contador cumulativo desde a criação (mesmo template, seção "O que a coluna
   'Duração' mede").
3c. **Se o agente registrou perguntas como "VALIDAR DEPOIS" por não ter `AskUserQuestion` disponível
   nesta invocação** (subagente isolado/assíncrono — sinal típico: uma nota de processo no topo de
   `code-review.md`, ou um item de pendência dizendo "não pude perguntar"), **você** — o
   orquestrador desta skill — apresenta essas perguntas ao usuário via *sua própria*
   `AskUserQuestion`, **antes** de informar o resultado da etapa no passo seguinte. Mesmo padrão já
   documentado para `sre` (`skills/sre/SKILL.md`, passo 4b) e para os agentes de implementação
   (`skills/implement/SKILL.md`, passo 5b). As que o usuário responder **deixam de ser pendência** e
   voltam ao relatório como decisão registrada — `SendMessage` ao agente `code-reviewer`, se ainda
   endereçável, ou edição direta da tabela de pendências de `code-review.md`. As que ele não souber
   responder agora continuam como VALIDAR DEPOIS, agora legitimamente. Registrar em vez de perguntar
   é o fallback correto **do agente**, que não tinha a ferramenta; não é o seu, que tem — e o
   usuário está disponível justamente no turno em que a etapa roda. Perguntas binárias de política
   ou de comportamento, que o usuário responderia em segundos, já viraram dívida em
   `/btt-sdd:pending` exatamente por este passo não existir.
4. Mostre ao usuário o veredito geral (aprovado/aprovado com ressalvas/reprovado) e os achados
   principais do relatório.
5. Se reprovado, informe que a feature volta para `/btt-sdd:implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de `skills/implement/SKILL.md` (prefira
   retomar o mesmo agente que implementou a fatia via `SendMessage` para correções pequenas e
   objetivas, em vez de invocar um agente novo).
   Se aprovado (ou aprovado com ressalvas aceitas pelo usuário), **a próxima etapa depende do diff
   desta fatia — não é sempre `/btt-sdd:qa`.** Aplique o critério objetivo de `docs/gates/ux.md` sobre o
   diff que você acabou de revisar:
   - **O diff toca superfície de UI perceptível pelo usuário final** (layout, navegação,
     visibilidade condicional de controles, estado vazio/erro, conteúdo de mídia) → a próxima etapa
     é **`/btt-sdd:ux-review`** (etapa 4b), não `/btt-sdd:qa`.
   - **Não toca** → a próxima etapa é `/btt-sdd:qa`, e a decisão de pular a 4b fica registrada em
     `specs/<slug>/ux-review.md` sob o heading padronizado que `docs/gates/ux.md` já define (`##
     Decisão: UX review pulado (justificado)`), nunca simplesmente omitida.

   **Por que esta bifurcação está escrita aqui.** A etapa 4b tem gate próprio, critério objetivo e
   skill própria — mas nada no caminho que o orquestrador percorre a mencionava, e um gate
   condicional cujo roteamento não está escrito é um gate que depende de memória. Já aconteceu de
   verdade: uma fatia com superfície de UI (a marca do app virou link, +31/-4 num componente de
   topbar) **pulou a 4b inteira** e foi mergeada em `main` sem nenhuma revisão de usabilidade,
   numa spec onde a etapa já existia havia semanas — descoberto só na fatia seguinte, pelo próprio
   `ux-designer`. E quando a 4b finalmente rodou, achou um defeito da classe que **só** ela encontra
   (um desfecho de instalação descartado, deixando o card idêntico depois de uma instalação
   bem-sucedida e respondendo "não foi possível" a quem acabou de instalar). Este é o único ponto do
   pipeline em que uma etapa pode desaparecer silenciosamente de uma fatia inteira.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `agents/code-reviewer.md` diretamente — leia o diff do
PR você mesmo antes de dar qualquer veredito.
