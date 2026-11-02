# CI verde não prova que a suíte rodou

Gatilho: antes de declarar/registrar que o CI está verde para o PR desta fatia.

**Não bloqueia aguardando o CI terminar.** Confirme o estado atual dos checks (`gh pr view <PR>
--json statusCheckRollup,headRefOid`) e reporte-o no `security-review.md`. **Um `conclusion:
success` não prova que a suíte rodou.** Num projeto que registra uma cadência condicional em
`docs/PROJECT-CONVENTIONS.md` (ex.: `ci-antes-do-merge`, em que os passos caros só rodam quando o
PR não é draft), o mesmo verde significa "a suíte passou" **ou** "a suíte foi deliberadamente
pulada" — `gh pr checks`, o ícone da UI e `statusCheckRollup` mostram exatamente a mesma coisa nos
dois casos.

Antes de afirmar que "o CI cobre este código": (a) inspecione os passos do run (`gh api
repos/<owner>/<repo>/actions/runs/<id>/jobs --jq '.jobs[].steps[]'`) e diga se os passos caros
executaram ou ficaram `skipped`; (b) se ficaram, identifique **qual** run executou a suíte de
verdade e prove que o código é o mesmo (`git diff --stat <sha-desse-run> HEAD -- src tests`), em
vez de apontar o run mais recente.

Já aconteceu de verdade: um run de **23 s** com 15 passos `skipped` reportou verde no HEAD de um
PR, e só não virou "código validado" no artefato porque o agente estranhou a duração e foi olhar
os passos. Reporte também quais commits estão cobertos por qual run, se o seu próprio push
disparou um run novo, e se o último run verde cobre o código atual — e encerre. Esperar o check
obrigatório ficar verde antes do merge é responsabilidade do **orquestrador**, que conduz o merge
(`docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge"). `gh run watch` numa etapa de
revisão consome tempo de parede sem produzir trabalho e distorce o `timing-log.md`, que a
retrospectiva de fatia lê para identificar etapas anormalmente lentas.
