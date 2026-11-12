---
name: code-review
description: Etapa 4 do pipeline SDD. Use depois que a implementação de uma feature está pronta (PR aberto), antes do QA, para uma revisão de código de engenheiro sênior — ports & adapters, SOLID, clean code, qualidade dos testes. Aciona o agente code-reviewer para produzir specs/[slug]/code-review.md.
---

# /btt-sdd:code-review

Aciona a **etapa 4** do pipeline SDD descrito em `CLAUDE.md`: revisão de código por um engenheiro
de software sênior, entre a implementação e o QA.

**Sempre passe por esta skill — nunca invoque o agente `code-reviewer` diretamente via Agent tool**
(diferente da etapa 3, onde invocar `backend-developer`/`frontend-developer` direto é o padrão
correto). Esta skill carrega o **roteamento da etapa seguinte** (passo 5: etapa 4b ou QA, conforme
o diff da fatia), que o agente sozinho não faz: pular a skill nas etapas 4-7 pula também os passos que outras skills de
revisão (`/btt-sdd:sre`) carregam, inclusive deixar uma fatia inteira atravessar o pipeline sem a
etapa 4b — ver `CLAUDE.md`, seção do pipeline.

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
   estava em revisão), **sincronize com `git merge origin/main` — nunca `git rebase`**
   (`docs/GIT-WORKFLOW.md`, seção "Sincronizar a branch da fatia com `main`: `merge`, nunca
   `rebase`": a branch já está publicada, então rebase exigiria força-push, que o classificador do
   modo automático recusa e que já apagou trabalho revisado em silêncio neste pipeline),
   resolvendo eventuais conflitos nos arquivos de artefato da spec (`code-review.md`/
   `qa-report.md`/`security-review.md`/`sre-review.md`/`trd.md` no formato legado, ou os arquivos
   dentro de `reviews/<etapa>/`/`trd/` no formato novo) preservando o conteúdo de ambos os
   lados quando tocarem os mesmos arquivos (`docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de
   merge nos arquivos de artefato de revisão", tem o passo a passo de como preservar a estrutura
   Markdown desses arquivos), e envie (push) o resultado. Isso evita que esta e as etapas seguintes
   (QA, segurança, SRE) commitem "às cegas" sobre uma base que já vai gerar conflito — descoberto
   só na última etapa, exigindo uma correção retroativa. **Se essa sincronização trouxe commits
   substanciais de
   outra feature mergeada** (não só um hotfix pontual da mesma spec), informe explicitamente ao
   `code-reviewer` que vai revisar esta rodada: qualquer varredura exaustiva de propagação de
   campo/assinatura (ex.: "todo `new <Entidade>(` do repositório") que
   `backend-developer`/`frontend-developer` tenha rodado *antes* dela pode estar
   desatualizada — código novo trazido de `main` pode ter introduzido um ponto de propagação que a
   varredura original não podia ver. Não é motivo para reprovar de antemão; é sinal para o
   `code-reviewer` reconfirmar com uma varredura própria (área 9 de `agents/code-reviewer.md`) em
   vez de confiar que "já rodei isso uma vez" continua válido.
2c. **Antes de invocar `code-reviewer`, reconfirme você mesmo se esta é a última fatia pendente da
   spec — não confie só na checagem que `/btt-sdd:implement` já fez quando o PR abriu
   (`skills/implement/_rules/fatia-final-bookkeeping.md`).** Leia a tabela de decomposição de
   tarefas
   (seção 13 do TRD) agora, no estado atual: se nenhuma outra fatia estiver pendente depois desta,
   e este projeto documenta em `docs/PROJECT-CONVENTIONS.md` um mecanismo explícito de
   sinalização para o CI ativar a suíte e2e completa (ex.: label de PR), confirme que o sinal já
   está aplicado — se não estiver, aplique-o agora, **antes** de invocar `code-reviewer`. A
   checagem do `/btt-sdd:implement` roda uma vez, no momento em que o PR abre; se uma tarefa for
   acrescentada à fatia **depois** disso (ex.: um roteiro e2e retroativo que o próprio
   `code-reviewer` acabaria notando como lacuna), a condição "é a última fatia" pode não ter
   mudado, mas o sinal pode nunca ter sido verificado de novo (issue #528).
2d. **Se a fatia altera workflow de CI/CD, Dockerfile ou dependência autenticada (registry privado,
   ação de outro repositório) e o projeto usa a cadência `ci-antes-do-merge`, tire o PR do draft e
   prove o run completo antes de invocar `code-reviewer`.** Em draft os passos caros ficam
   `skipped`, e o verde não prova o que a fatia introduziu. Dispare o run com o PR fora do draft e
   com um delta de código ou infra: um push só de `specs/` também pula os passos, porque o filtro
   compara com o commit anterior do push, não com o PR inteiro. Confira os passos do job (`gh run
   view <id> --json jobs`), não só o `conclusion`: `gh pr ready` logo depois de um push pode herdar o
   payload com `draft=true`, e o run conclui verde com os passos caros `skipped`. Passe o id do run
   ao `code-reviewer` na instrução. Se o ambiente recusa `git` dentro do worktree isolado do agente,
   rode a revisão no checkout principal (sem agente concorrente) e registre o motivo.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3b para
   registrar a duração desta invocação. Invoque o agente `code-reviewer` (Agent tool,
   `subagent_type: "code-reviewer"`) passando o caminho do TRD e o PR/branch da feature, e
   instrução para produzir o artefato de revisão referenciando o PR — o próprio agente detecta
   se esta spec já usa o formato novo (`specs/<slug>/reviews/code-review/`) ou o legado
   (`specs/<slug>/code-review.md`), conforme `agents/code-reviewer.md`, passo 6 do Processo; você
   não precisa decidir isso por ele. **Sempre passe `isolation:
   "worktree"` nesta chamada** — nunca deixe dois agentes dividirem o mesmo diretório de trabalho
   (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes"). Não é
   uma condição a avaliar caso a caso ("outra tarefa pode estar ativa?", ex.: uma correção retomada
   via `SendMessage` que ainda não terminou) — é o padrão desta invocação.
   **Diga ao agente em qual ref revisar.** O worktree isolado nasce na branch principal, não na
   branch da fatia. Na instrução, informe a branch e o SHA da ponta (`git rev-parse HEAD` no
   checkout principal), mande o agente seguir `code-reviewer/worktree-checkout.md` e confirmar o SHA com
   `git rev-parse HEAD` antes de revisar. **Se o worktree isolado recusa `git`** (hook do
   ambiente), ou se o plano/`timing-log.md` da spec já registra "recusa git"
   (`implement`, passo 4d), não passe `isolation` e rode a revisão no checkout principal enquanto
   não há agente concorrente; registre o motivo no artefato.
3a. **Ao incluir na instrução um fato que outra etapa mediu, diga quem mediu e como — e marque se
   ele é carga para alguma conclusão desta etapa.** **Medição que decide aprovação contra um limiar
   (contraste, cobertura, tempo, tamanho) se repassa com o valor bruto, todas as casas, e o método,
   nunca arredondada;** valor a menos de 1% do limiar sai rotulado "reconfira" ("no limite" é sinal
   para reconferir, não para aceitar: 4,497:1 reprova um mínimo de 4,5:1). Repassar o que a etapa anterior já mediu é
   desejável (é para isso que as seções "o que a próxima etapa herda" existem), mas a repetição
   **lava a origem**: o que era "medido pela etapa X, com o método Y" chega como premissa sem
   procedência, indistinguível de um fato do desenho — e quem recebe não tem como saber que precisa
   reconferir. Rotule assim: *"medido pelo `security-engineer` lendo `pull_request.base.sha` —
   **reconfira se sua conclusão depender disso**"*. Vale também para medição **sua**, de
   orquestrador: diga o que você leu para chegar nela — uma medição errada herdada custa mais que
   uma remedição. Dois riscos concretos a rotular: ler metadado de evento de CI (ex.:
   `pull_request.base.sha`) pode não bastar — em evento `synchronize`, o `base` efetivo é
   `github.event.before`, que pode variar de run para run; e uma contagem sobre o código-fonte (ex.:
   módulos importados) pode divergir da contagem sobre o artefato construído — confira o artefato,
   não só o fonte, quando a conclusão depender do número real.
3b. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "Code review", agente
   "code-reviewer", fatia desta rodada). **Não commite este arquivo agora**: deixe a linha no working tree da branch da fatia e commite o
   `timing-log.md` acumulado **uma única vez**, junto do push único da fatia (`docs/GIT-WORKFLOW.md`,
   seção "Push único por fatia"). Commitar a cada etapa move a ponta da branch depois que o worktree
   do agente seguinte já nasceu dela, e o `merge --ff-only` do commit dele falha por divergência. **Vale também quando esta invocação é só uma reverificação pontual de um achado
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
   (`skills/implement/_rules/fallback-plano-texto-puro.md`). As que o usuário responder **deixam
   de ser pendência** e
   voltam ao relatório como decisão registrada — `SendMessage` ao agente `code-reviewer`, se ainda
   endereçável, ou edição direta da tabela de pendências de `code-review.md`. As que ele não souber
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
   seguinte repete a oferta que o campo existe para evitar.
3b. **Integre o commit do agente na branch da fatia, localmente, e não dê push aqui**
   (`docs/GIT-WORKFLOW.md`, seção "Push único por fatia: o CI roda uma vez, não uma vez por
   artefato de revisão"). O agente commitou o artefato e informou a branch e o SHA. Se ele rodou em
   working tree isolado, essa branch é a temporária do worktree: integre e confirme **antes** de
   remover o worktree. **Confirme a branch atual antes do merge — nunca assuma** (`docs/
   GIT-WORKFLOW.md`, seção "Isolamento de working tree", bloco "Confirme sempre o branch atual
   antes de qualquer `git merge`..."): um agente retomado sem isolamento devolve o workspace via
   `git checkout <branch base>`, e um `merge --ff-only` sobre a branch errada avança a ponta dela
   em silêncio em vez de falhar.

   ```bash
   git branch --show-current                              # confirme antes de qualquer merge
   git merge --ff-only <branch-informada-pelo-agente>
   # artefato alcançável na branch da fatia — formato novo são 3 arquivos, legado é 1:
   git log -1 --format=%H -- specs/<slug>/reviews/code-review/ specs/<slug>/code-review.md
   git worktree remove <caminho-do-worktree>              # se houver
   ```

   **Nunca apague a branch temporária do agente antes de confirmar** que `git log -1 -- <artefato>`
   devolve o commit dele na branch da fatia. Se o `--ff-only` falhar por divergência, integre com
   `git cherry-pick <SHA-informado-pelo-agente>` em vez de descartar o trabalho.
   Se o agente informar que integrou por **push direto** (ele não alcançava o checkout principal —
   `docs/GIT-WORKFLOW.md`, "Isolamento aninhado"), não há branch temporária para integrar: rode
   `git fetch origin` + `git merge --ff-only origin/<branch-da-fatia>` e confirme o artefato.

   Confirmar não é zelo: os itens de gate que antes exigiam push nasceram de artefato que não
   chegava à branch. A durabilidade continua obrigatória — o meio é que mudou.
4. Mostre ao usuário o veredito geral (aprovado/aprovado com ressalvas/reprovado) e os achados
   principais do relatório.
5. Se reprovado, informe que a feature volta para `/btt-sdd:implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de `skills/implement/SKILL.md` (prefira
   retomar o mesmo agente que implementou a fatia via `SendMessage` para correções pequenas e
   objetivas, em vez de invocar um agente novo).
   Se aprovado (ou aprovado com ressalvas aceitas pelo usuário), **a próxima etapa é `/btt-sdd:qa` —
   com uma exceção declarada.** A 4b (UX) roda ao final da spec, sobre o diff acumulado
   (`docs/SDD-WORKFLOW.md`, seção "Cadência: o que roda por fatia e o que roda ao final da spec"),
   então ela **não** entra aqui por padrão. Ela entra antes do QA **só** quando alguma tarefa desta
   fatia tem a coluna `Validação na fatia` da seção 13 do TRD marcando `ux` — o que o `architect` é
   obrigado a fazer quando a tarefa expõe fluxo ou tela **nova** ao usuário final. Leia a tabela
   antes de responder; nos dois casos diga qual é a próxima etapa e por quê.

   **Por que este roteamento está escrito aqui, e não só no doc de cadência.** Um gate condicional
   cujo roteamento não está escrito no caminho que o orquestrador percorre é um gate que depende de
   memória. Sob a cadência atual o risco muda de forma, não desaparece: a 4b não pode **deixar de
   existir na spec**
   — se a spec tem superfície de UI, ela roda na última fatia, e a decisão de não rodar é registrada
   em `specs/<slug>/ux-review.md` sob o heading padronizado `## Decisão: UX review pulado
   (justificado)`, nunca simplesmente omitida (`docs/gates/ux.md`).

5b. **Se esta rodada foi escopada ao delta de uma correção de achado levantado pela etapa 4b, a
   próxima etapa é `/btt-sdd:ux-review` escopado ao achado — não `/btt-sdd:qa`.** A sua aprovação
   cobre "o
   código faz o que devia"; quem fecha "isso resolve o problema de usabilidade real" é a etapa que
   levantou o achado. É a regra simétrica do passo 6b de `skills/ux-review/SKILL.md`
   (que manda a correção de UX voltar para cá quando toca produção) — e sem ela um achado
   bloqueante de usabilidade fecha só com evidência técnica (detalhe em
   `skills/ux-review/SKILL.md`, passo 6c).

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `agents/code-reviewer.md` diretamente — leia o diff do
PR você mesmo antes de dar qualquer veredito.
