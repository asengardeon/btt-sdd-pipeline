# CI verde não prova que a suíte rodou — e não espere o CI terminar

Gatilho: antes de declarar/registrar no `sre-review.md` que "o CI cobre este código" ou que um
check está verde para o PR desta fatia.

**Não bloqueie aguardando o CI terminar.** Confirme o **estado atual** dos checks (`gh pr view
<PR> --json statusCheckRollup,headRefOid`) e reporte-o. Esperar o check obrigatório ficar verde
antes do merge é responsabilidade do **orquestrador**, que conduz o merge (`docs/GIT-WORKFLOW.md`,
seção "Aguardando CI antes do merge"). `gh run watch` nesta etapa consome tempo de parede sem
produzir trabalho e distorce o `timing-log.md`. Já aconteceu de verdade: uma invocação sua levou
**6h52m**, quase 8× a segunda etapa mais longa da fatia, fazendo a mesma auditoria que a fatia
anterior tinha levado **17m13s** — a diferença inteira foi espera de CI, inclusive dos runs que os
seus próprios commits de documentação dispararam. O log passou a dizer "SRE é a etapa mais cara
desta spec" quando o trabalho de SRE foi um dos mais baratos.

**Um `conclusion: success` não prova que a suíte rodou.** Num projeto que registra uma cadência
condicional em `docs/PROJECT-CONVENTIONS.md` (ex.: `ci-antes-do-merge`, em que os passos caros só
rodam quando o PR não é draft), o mesmo verde significa "a suíte passou" **ou** "a suíte foi
deliberadamente pulada" — `gh pr checks`, o ícone da UI e `statusCheckRollup` mostram exatamente a
mesma coisa nos dois casos. Antes de afirmar que "o CI cobre este código":

1. Inspecione os passos do run (`gh api repos/<owner>/<repo>/actions/runs/<id>/jobs --jq
   '.jobs[].steps[]'`) e diga se os passos caros executaram ou ficaram `skipped`.
2. Se ficaram, identifique **qual** run executou a suíte de verdade e prove que o código é o
   mesmo (`git diff --stat <sha-desse-run> HEAD -- src tests`), em vez de apontar o run mais
   recente.

Já aconteceu de verdade: um run de **23 s** com 15 passos `skipped` reportou verde no HEAD de um
PR, e só não virou "código validado" no artefato porque o agente estranhou a duração e foi olhar
os passos. Reporte também quais commits estão cobertos por qual run, se o seu próprio push de
artefatos disparou um run novo, e se o último run verde cobre o código atual.

**Confirme que o `headSha` do run é igual ao `headRefOid` atual do PR** (`gh pr view <PR> --json
headRefOid`) — não presuma que o run mais recente listado corresponde ao HEAD atual. Um commit
"docs-only" que uma etapa de revisão grava em `specs/**/*.md` depois que o código já passou no CI
não gera um novo run visível **se** o `ci.yml` deste projeto já tem o filtro de `paths` do
short-circuit docs-only (ver `sre/ci-cadencia-e-custo.md`) — confirme que o filtro existe antes de
assumir isso; sem ele, cada commit "docs-only" ainda dispara run próprio, e esse run é evidência
válida. Se os SHAs forem diferentes, confirme via `git diff --stat <headSha-do-run>..<headRefOid-
atual>` que nada relevante ao workflow (`src/`, `frontend/`, manifestos de dependência, os próprios
workflows) mudou entre os dois — só então o run antigo continua sendo evidência válida. Caso
contrário, dispare um novo run (um push/atualização de branch normalmente resolve) antes de
aprovar.
