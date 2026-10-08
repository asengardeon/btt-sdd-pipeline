---
name: qa
description: Etapa 5 do pipeline SDD. Use depois que a revisão de código aprovou uma feature, para validar objetivamente contra o PRD/TRD e checar o gate de cobertura de 80%. Aciona o agente qa-engineer para produzir specs/<slug>/qa-report.md.
---

# /btt-sdd:qa

Aciona a **etapa 5** do pipeline SDD descrito em `CLAUDE.md`: validação de QA.

**Sempre passe por esta skill — nunca invoque o agente `qa-engineer` diretamente via Agent tool**
(diferente da etapa 3, onde invocar `backend-developer`/`frontend-developer` direto é o padrão
correto). Esta skill em si não carrega lógica extra além de acionar o agente, mas o hábito de
pular a skill nas etapas 4-7 já causou passos de outras skills de revisão (`/btt-sdd:sre`) serem
pulados silenciosamente numa sessão real — ver `CLAUDE.md`, seção do pipeline.

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que existe `specs/<slug>/code-review.md` com veredito aprovado (ou aprovado com
   ressalvas aceitas pelo usuário). Se não existir, sugira `/btt-sdd:code-review` primeiro; se
   existir reprovado, sugira `/btt-sdd:implement` para tratar os achados antes de rodar o QA.
2a. **Confirme que a aprovação de code review vigente cobre o HEAD atual da branch — não só que
   ela existe.** Pegue o sha que a rodada de code review aprovou (o commit em que `code-review.md`
   foi gravado com o veredito vigente) e rode `git diff --name-only <sha>..HEAD -- <diretórios de
   produção>`. Se vier **não vazio**, esta etapa não começa: volte para `/btt-sdd:code-review` com uma
   rodada escopada ao delta (instância nova do `code-reviewer`), e só então rode o QA
   (`docs/gates/qa.md`, item sobre frescor da aprovação). Isso é diferente do passo 2b abaixo, que
   checa `main`: aqui o que avançou foi a **própria branch da fatia** depois do carimbo, e é o caso
   **normal**, não o excepcional — a etapa 4b roda depois da 4 e gera código de produção.
2b. **Se a branch/PR original da fatia já foi mergeado e apagado** (comum em revisão retroativa
   pedida depois do fato — ex.: um `/btt-sdd:hotfix` que pulou QA no momento do merge, e o usuário
   pede para formalizar essa etapa depois), não tente localizar/rebasear uma branch inexistente:
   siga `docs/GIT-WORKFLOW.md`, seção "Revisão retroativa de um PR já mergeado" — crie uma branch
   nova a partir de `origin/main`, produza só o `qa-report.md` desta rodada, e abra um PR próprio
   (sem gate adicional, já que não há código novo a revisar). Caso contrário (branch/PR ainda
   ativo), **confirme que a branch está sincronizada com `main` antes de revisar.** Rode `git fetch
   origin main` e `git rev-list --count HEAD..origin/main` — se houver commits novos em `main` desde que
   esta branch nasceu (ex.: merge de um hotfix concorrente da mesma spec enquanto esta fatia ainda
   estava em revisão), rebaseie a branch da fatia sobre `origin/main` antes de prosseguir,
   resolvendo eventuais conflitos nos arquivos de artefato da spec (`code-review.md`/
   `qa-report.md`/`security-review.md`/`sre-review.md`/`trd.md`) preservando o conteúdo de ambos os
   lados quando tocarem os mesmos arquivos (`docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de
   merge nos arquivos de artefato de revisão", tem o passo a passo de como preservar a estrutura
   Markdown desses arquivos), e envie (push) o resultado. Isso evita que esta e as
   etapas seguintes (segurança, SRE) commitem "às cegas" sobre uma base que já vai gerar conflito —
   descoberto só na última etapa, exigindo uma correção retroativa.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3b para
   registrar a duração desta invocação. Invoque o agente `qa-engineer` (Agent tool,
   `subagent_type: "qa-engineer"`) passando os caminhos do PRD e TRD e o PR/branch da feature
   (`feature/<slug>`, ver `docs/GIT-WORKFLOW.md`), e instrução para produzir
   `specs/<slug>/qa-report.md` a partir de `specs/_template/qa-report.template.md`, referenciando
   o PR. **Sempre passe `isolation: "worktree"` nesta chamada** — nunca deixe dois agentes
   dividirem o mesmo diretório de trabalho (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working
   tree entre agentes concorrentes"). Não é uma condição a avaliar caso a caso ("outra tarefa pode
   estar ativa?") — é o padrão desta invocação.
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
   passo 3, o horário atual, e a diferença calculada (etapa "QA", agente "qa-engineer", fatia desta
   rodada). Commit e envie (push) essa atualização junto com o resto do que esta rodada já for
   commitar (`docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar pushes relacionados). **Vale também
   quando esta invocação é só uma reverificação pontual de um achado específico**
   (`qa-engineer.md`, seção "Escopo de uma rodada de reverificação de achado específico") — nunca
   pule este registro por ser "só uma reverificação", senão o `timing-log.md` da fatia fica
   sistematicamente incompleto. **Quando a reverificação pontual retoma o agente via
   `SendMessage` em vez de abrir uma invocação nova, o passo 3 não acontece — anote o horário
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
   `qa-report.md`, ou um item de pendência dizendo "não pude perguntar"), **você** — o orquestrador
   desta skill — apresenta essas perguntas ao usuário via *sua própria* `AskUserQuestion`, **antes**
   de informar o resultado da etapa no passo seguinte. Mesmo padrão já documentado para `sre`
   (`skills/sre/SKILL.md`, passo 4b) e para os agentes de implementação
   (`skills/implement/SKILL.md`, passo 5b). As que o usuário responder **deixam de ser pendência** e
   voltam ao relatório como decisão registrada — `SendMessage` ao agente `qa-engineer`, se ainda
   endereçável, ou edição direta da tabela de pendências de `qa-report.md`. As que ele não souber
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
4. Mostre ao usuário o veredito geral (aprovado/reprovado) e os pontos principais do relatório.
5. Se reprovado, informe que a feature volta para `/btt-sdd:implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de `skills/implement/SKILL.md` (prefira
   retomar o mesmo agente que implementou a fatia via `SendMessage` para correções pequenas e
   objetivas, em vez de invocar um agente novo). Se aprovado, informe que a próxima etapa é
   `/btt-sdd:security`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `agents/qa-engineer.md` diretamente — rode a suíte de
testes e cobertura você mesmo antes de dar qualquer veredito.
