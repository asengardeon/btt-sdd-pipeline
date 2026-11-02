# Antes de invocar um agente de implementação: confirme que o trabalho é mesmo pendente

Gatilho: antes de invocar `backend-developer`/`frontend-developer` para a fatia escolhida — quatro
checagens independentes que podem revelar que não há trabalho real a fazer.

## Fatias sem nenhuma trilha de código

Antes de invocar qualquer agente, confira se *alguma* tarefa da fatia escolhida tem trilha
`backend`/`frontend`/`ambos` associada a mudança de código real em `src/`/`frontend/`. Fatias
inteiras podem ser só infraestrutura ou validação (ex.: "provisionar um add-on + confirmar em
produção", trilha `infra`, `ambos (ação do usuário)` ou `ambos (validação)` na tabela) — sem
nenhum arquivo de código a tocar. Se for o caso desta fatia, **pule a invocação de
`backend-developer`/`frontend-developer`** e informe ao usuário que esta rodada será conduzida
diretamente por você (o orquestrador), sem branch/PR — a menos que, no meio do caminho, uma
mudança de infraestrutura *versionada como código* seja necessária (ex.: um ajuste em `cd.yml`,
`Dockerfile`, `infra/terraform/`), caso em que essa mudança pontual vira sua própria branch/PR e
passa pelo pipeline completo (code review, QA, segurança, SRE) normalmente, em vez de ser
commitada solta.

## Já existe PR aberto e totalmente aprovado para as mesmas tarefas

Antes de invocar qualquer agente, confirme que não existe já um PR aberto e totalmente aprovado
cobrindo as mesmas tarefas — independente de a coluna "Issue GitHub" estar preenchida (gate
diferente, próxima seção). Rode `gh pr list --state open --search "<slug> Fatia N"` (ajustando o
padrão ao texto real usado nos PRs deste projeto). Se encontrar um PR aberto cujos artefatos de
revisão (`code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md`) já estão todos
aprovados para essa fatia, isso é **trabalho pronto aguardando merge, não trabalho pendente** —
pare aqui, não invoque `backend-developer`/`frontend-developer`, informe o usuário do PR
encontrado e sugira mergear em vez de reimplementar (o merge em si continua sendo decisão do
usuário, `docs/GIT-WORKFLOW.md`). Só prossiga quando essa checagem não encontrar nenhum PR aberto
já aprovado para a fatia. Já aconteceu de verdade: a tabela do TRD reportava a fatia F-1 inteira
como `pendente` porque a promoção de Status só dispara ao confirmar merge da fatia anterior antes
de iniciar a próxima — mas o PR da fatia já existia, com code review, QA, segurança e SRE todos
aprovados e CI verde, só faltando o merge; sem uma checagem manual, o trabalho teria sido
reimplementado do zero.

## Gate obrigatório: toda tarefa da fatia precisa ter Issue GitHub associada

Confira a coluna "Issue GitHub" da tabela de decomposição do TRD para cada tarefa desta fatia
(excluindo fatias sem trilha de código, seção acima, que não passam por este gate). Se alguma
estiver vazia/`não espelhada`, **antes de concluir que a fatia está pendente**, rode uma checagem
barata de que ela não foi implementada e mergeada sem que o TRD tivesse sido atualizado depois (a
coluna Status pode ter ficado desatualizada mesmo com a fatia já em produção — ex.: `git log
--oneline --all -i --grep="<slug>.*fatia N"` e/ou `gh pr list --search "<slug> Fatia N" --state
merged`, ajustando o padrão ao texto real usado nos commits/PRs deste projeto). Se essa checagem
encontrar um commit/PR já mergeado cobrindo as mesmas tarefas desta fatia, **isso é uma
discrepância de documentação, não trabalho pendente**: atualize a coluna Status dessas tarefas no
TRD para `concluído (mergeado)` citando o PR/commit real, informe o usuário, e volte para escolher
a próxima fatia realmente pendente — não crie issues nem branch/agente de implementação para esta
fatia.

Só quando a checagem não encontrar nada, trate como o gate original: **pare aqui, não crie a
branch nem invoque nenhum agente de implementação** — isso não deveria acontecer se o TRD foi
aprovado depois desta regra existir (`agents/architect/decomposicao-tarefas-detalhe.md`),
mas pode ocorrer em TRDs aprovados antes dela, ou se uma issue foi apagada/perdida depois. Informe
o usuário e ofereça, via `AskUserQuestion`, acionar `architect` para criar as issues faltantes
desta fatia (opção recomendada) antes de prosseguir — nunca inicie a fatia sem elas, mesmo que o
usuário peça para pular o gate.

## Garanta PRD/TRD commitados antes do primeiro worktree

Ao criar a branch desta rodada, garanta que o PRD/TRD desta spec estão commitados em algum ref
antes de invocar qualquer agente com `isolation: "worktree"`. Um `git worktree add` cria um
checkout limpo a partir de um ref já commitado — mudanças feitas diretamente no checkout principal
(ex.: a edição do PRD/TRD durante a aprovação, que por si só não passa por commit/PR,
`docs/GIT-WORKFLOW.md`, seção "Mapeamento no pipeline SDD": "Nenhuma — documentos em `specs/`, sem
código/branch ainda") são literalmente invisíveis para um worktree novo, mesmo que `git log --all`
seja consultado. Se `specs/<slug>/prd.md`/`trd.md` (e `timing-log.md`, se as etapas de PRD/TRD já
o criaram) ainda estiverem só como mudanças não commitadas no checkout principal, commite-os
agora, nesta branch recém-criada, como parte do primeiro commit — antes de qualquer `git worktree
add`/invocação com `isolation: "worktree"` para esta fatia.

**Nunca** contorne isso commitando PRD/TRD direto em `main` (regra 1 de `docs/GIT-WORKFLOW.md` —
ninguém commita direto nela) nem criando um PR de documentação avulso para isso — eles seguem
incluídos no mesmo PR desta fatia, revisados normalmente como o resto do conteúdo da branch. Já
aconteceu de verdade: um agente invocado com `isolation: "worktree"` falhou de cara porque o TRD da
spec só existia como arquivo não commitado no checkout principal — uma implementação inteira
precisou ser refeita (~28k tokens) até alguém perceber e commitar manualmente. Se duas specs em
paralelo estão nessa mesma situação, cada uma resolve isso na própria branch — nunca aproveite
para commitar o PRD/TRD de uma spec na branch de outra.
