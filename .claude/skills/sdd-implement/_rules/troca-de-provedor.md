# Troca de provedor/serviço externo descoberta durante a implementação

Gatilho: durante a implementação (ou um ajuste de infra pontual conduzido por você, ver
`fatia-sem-trabalho-pendente.md`), surge a necessidade de trocar um provedor/serviço externo que
o TRD já desenhou com outra escolha (ex.: TRD desenhou storage no provedor A, na prática o
provedor B foi usado; TRD não especificou provedor de e-mail transacional e um foi escolhido
agora).

Isso **sempre** exige, no mínimo, uma ADR nova registrada pelo `architect` (`docs/adr/`, mesmo que
pequena) **antes** do `sre` ou do dev implementar a troca. Não é uma decisão que o orquestrador ou
o `sre` tomam sozinhos caso a caso "se merece" ADR — troca de provedor já desenhado no TRD sempre
merece. Acione `architect` (ou `/sdd-trd` se a mudança também precisa refletir no corpo do TRD)
antes de prosseguir.

**Acione sempre com `isolation: "worktree"`** — ele vai editar arquivos compartilhados (TRD —
`trd/architecture.md`/`trd/tasks.md` no formato novo, `trd.md` no legado —, `docs/STACK.md`,
ADRs), e essa invocação ad-hoc concorre com qualquer outra tarefa ativa no mesmo
repositório pela mesma razão que etapas de revisão já usam isolamento por padrão
(`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes") — não só
quando você já sabe de outra tarefa ativa, mas sempre, porque você (orquestrador) pode precisar
redirecionar a decisão no meio e lançar uma invocação nova antes da anterior terminar. Já
aconteceu de verdade: uma invocação do `architect` sem isolamento ainda estava editando
`trd.md`/`docs/STACK.md` quando o usuário reconsiderou a decisão em andamento, exigindo uma
terceira invocação de reversão concorrente com a segunda e um `TaskStop` no meio de uma edição
para evitar corrupção dos arquivos compartilhados.

**Se `architect` devolver um bloco `## DESPACHO NECESSÁRIO`** (sinal de que ele precisava do
parecer de outro agente do pipeline e não tinha Agent tool disponível para despachá-lo sozinho,
cenário comum quando você o aciona ad-hoc em modo assíncrono/isolado — mesmo padrão de
`.claude/skills/sdd-trd/SKILL.md`, passo 3b-bis): acione o agente indicado nesta mesma rodada,
passando o contexto fornecido, antes de considerar a ADR pronta para a troca prosseguir (issue
#542, `asengardeon/btt-sdd-pipeline`).
