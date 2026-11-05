# Bookkeeping específico da última fatia de uma spec

Gatilho: a fatia escolhida/mergeada é a última pendente da feature — três verificações
independentes.

## Confirme a promoção retroativa de Status se nenhuma fatia estiver pendente

Se nenhuma fatia estiver pendente (todas as tarefas da tabela já implementadas/mergeadas), antes
de simplesmente informar que não há trabalho a fazer, confirme se a promoção de Status da
**última fatia** da tabela já aconteceu. O mecanismo normal de promoção para `concluído
(mergeado)` (`docs/gates/status-de-tarefas.md`) só dispara "ao confirmar, antes de iniciar a fatia
seguinte, que o PR de uma fatia já foi mergeado" — e a última fatia de uma spec nunca tem uma
fatia seguinte para disparar isso, então a tarefa fica presa no status que o `sre` deixou
(`aprovado`), mesmo depois de mergeada de verdade. Verifique o PR referenciado na coluna
Status/Issue GitHub da última fatia (`gh pr view <N> --json state,mergedAt`); se estiver mergeado
e a coluna Status ainda não disser `concluído (mergeado)`, promova-a agora (mesma transição de
sempre, só aplicada retroativamente por não haver "fatia seguinte" que a disparasse). Se essa
promoção nunca tinha acontecido antes, é sinal de que o "Teste geral obrigatório ao mergear a
última fatia de uma spec" também pode nunca ter rodado — confirme com o usuário se já rodou antes
de considerar a spec de fato encerrada.

## Sinalize a fatia final ao CI assim que o PR dela for aberto

Se a fatia escolhida é a última pendente da spec, e este projeto documenta um mecanismo explícito
de sinalização para o CI ativar a suíte e2e completa (ex.: label de PR, variável de ambiente),
aplique esse sinal assim que o PR desta fatia for aberto — antes de invocar a primeira etapa de
revisão. Não espere uma etapa no meio da cadência de revisão (QA, segurança) notar a ausência: o
orquestrador já sabe, neste ponto, que esta é a fatia final — é a informação mais antiga
disponível sobre isso, não a mais recente.

**Verifique os dois lugares possíveis antes de concluir "nenhum mecanismo documentado" —
`docs/PROJECT-CONVENTIONS.md` não é o único lugar onde esse mecanismo pode estar registrado.**
Além de ler `docs/PROJECT-CONVENTIONS.md`, rode `grep` por termos como "última fatia"/"ultima-
fatia"/"label" diretamente em `.github/workflows/ci.yml` (e `cd.yml`, se existir) — pelo menos um
projeto real documenta esse mecanismo como comentário extenso dentro do próprio workflow, decisão
registrada por issue própria do projeto, nunca copiada para `PROJECT-CONVENTIONS.md`. A decisão de
onde documentar esse tipo de mecanismo varia por projeto; checar só um dos dois lugares possíveis
faz o orquestrador concluir "não documentado" quando o mecanismo existe, e instruir o
`code-reviewer`/`qa-engineer` erradamente nesse sentido (issue #617).

**Não invente esse mecanismo se nenhum dos dois lugares o documentar** — decidir como sinalizar a
fatia final ao CI é do `architect`/`sre` deste projeto, registrado em `docs/PROJECT-CONVENTIONS.md`
ou no próprio workflow quando a cadência "e2e completo só na última fatia" for adotada
(`docs/CI-WORKFLOW.md`, seção "O que não entra por padrão"). Sinalizar tarde (durante a rodada de
QA ou depois) deixa code review e UX aprovarem sem a suíte e2e real ter rodado nenhuma vez — um
defeito presente desde a primeira fatia da spec só aparece na primeira execução real do job
(issue #473).

## Confirme que todas as issues da fatia anterior fecharam de fato

Ao confirmar o merge da fatia anterior (antes de criar a branch desta rodada), confirme também que
todas as issues daquela fatia fecharam de fato — `gh pr view <PR> --json
closingIssuesReferences` (ou `gh issue view <N> --json state` para cada issue da coluna "Issue
GitHub" daquela fatia). As que sobrarem abertas, feche à mão citando o PR (`gh issue close <N>
--comment "Fechada por #<PR>"`). Não assuma que o `Closes` funcionou: a forma com vírgulas simples
(`Closes #A, #B, #C`) fecha **só a primeira** em silêncio, e o corpo do PR *parece* correto
(`docs/GIT-WORKFLOW.md`, regras 5b e 5c). Uma issue que ficou aberta sem motivo faz esta spec
parecer ter trabalho pendente que já está em produção — e, no limite, faz um gate de "já existe PR
aprovado para esta fatia" levar uma fatia futura a **reimplementar** o que já foi mergeado
(`skills/implement/_rules/fatia-sem-trabalho-pendente.md`).
