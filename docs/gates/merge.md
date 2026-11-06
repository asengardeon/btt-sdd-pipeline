# Merge para `main` (por fatia)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] PR desta fatia aberto, **revisão de código aprovada e QA aprovado** (ou aprovados com
  ressalvas não-bloqueantes explicitamente aceitas pelo usuário) — escopados a esta fatia, não à
  feature inteira. Mais as validações que esta fatia antecipou: para cada tarefa dela com a coluna
  `Validação na fatia` preenchida (seção 13 do TRD), o artefato correspondente
  (`ux-review.md`/`security-review.md`/`sre-review.md`) aprovado para esta fatia.
- [ ] **Se esta é a última fatia pendente da spec**, as três etapas de fim de spec também estão
  aprovadas sobre o **diff acumulado**: UX (ou "não aplicável" justificado quando a spec não tem
  superfície de UI), segurança e SRE. Uma fatia intermediária mergeia sem elas — é a cadência
  deliberada de `docs/SDD-WORKFLOW.md`, seção "Cadência: o que roda por fatia e o que roda ao final
  da spec", que aceita explicitamente o risco de um defeito dessas três classes alcançar `main` e
  ficar lá até o fim da spec, limitado pelo piso objetivo de antecipação e pela revisão final do
  acumulado. O que a revisão final achar já mergeado vira `/sdd-hotfix`, não um merge revertido.
- [ ] **CI verde verificado em três partes, pelo orquestrador que conduz o merge** — não é "CI
  verde" sem qualificação, e não é tarefa de nenhuma etapa de revisão. Um agente de revisão
  **reporta** o estado dos checks no próprio artefato e encerra (`docs/GIT-WORKFLOW.md`, seção
  "Aguardando CI antes do merge"); quem espera e decide é quem mergeia. As três partes:
  1. **A suíte de fato executou.** `conclusion: success` no nível do run é ambíguo num projeto com
     cadência condicional de CI (`docs/PROJECT-CONVENTIONS.md`, ex.: `ci-antes-do-merge`): pode
     significar "passou" ou "foi deliberadamente pulada". Inspecione os passos
     (`gh api repos/<owner>/<repo>/actions/runs/<id>/jobs --jq '.jobs[].steps[]'`) e confirme que os
     passos caros rodaram, em vez de aparecerem `skipped`.
  2. **O run verde cobre o código que vai ser mergeado.** Compare o `headSha` do run com o
     `headRefOid` atual do PR; se diferirem, prove por `git diff --stat <headSha>..<headRefOid>` que
     nada relevante ao workflow mudou entre os dois (`src/`, `frontend/`, manifestos de dependência,
     os próprios workflows). Caso contrário, dispare um run novo antes de mergear.
  3. **O relatório de merge cita o run que executou de verdade, não só o último.** O
     `statusCheckRollup` do PR mostra o run mais recente, e depois do push único da fatia (só
     `specs/` e relatórios) ele pode ser o do caminho pulado: todo `skipped`, mas
     `conclusion: success`. Quem lê o verde final acha que a suíte da fatia rodou. Registre no
     relatório o `id` e o `headSha` do run que executou os passos caros, com a confirmação de 0
     passos caros `skipped` (parte 1), e a saída de `git diff --stat <headSha>..<headRefOid>` até o
     HEAD atual (parte 2). Se nenhum run da fatia executou os passos caros, dispare um run novo. Um
     job "só documentação" que decide pelo delta do último push (`github.event.before`..`sha`) em
     vez de pelo último run verde da branch pula tudo no push único mesmo quando o PR traz código —
     nesse projeto, trate o verde do último run como não provado e cite o run anterior
     (`docs/CI-WORKFLOW.md`, item 3).
  Delegar essa verificação adiante, etapa após etapa, sem que ninguém de fato a execute pode deixar
  passar um *required check* vermelho sem inspeção até o HEAD — e um run em draft reportando verde
  em segundos, com todos os passos caros `skipped`, não significa nada.
- [ ] **Depois do merge, todas as issues da fatia foram confirmadas fechadas** (`gh pr view <PR>
  --json closingIssuesReferences`), e as que não fecharam sozinhas foram fechadas à mão citando o
  PR. Não basta o corpo do PR *parecer* correto: `Closes #A, #B, #C` fecha só a primeira em
  silêncio — a forma válida repete a palavra-chave (`docs/GIT-WORKFLOW.md`, regras 5b e 5c).
- [ ] Se houver fatia seguinte pendente na feature, ela só começa depois deste merge
  (`docs/GIT-WORKFLOW.md`).
- [ ] Nenhum item "VALIDAR DEPOIS" bloqueante (marcado como tal pelo usuário) segue em aberto.
- [ ] **Retrospectiva da fatia conduzida — em toda fatia aprovada, não só a última.** Quem conduz é
  a **última etapa que rodou naquela fatia**: `/sdd-sre` na última fatia da spec
  (`.claude/skills/sdd-sre/SKILL.md`, passo 5c), `/sdd-qa` nas intermediárias, com o mesmo
  procedimento. Ela avalia a execução da rodada e abre issues de
  melhoria/aprendizado em `asengardeon/btt-sdd-pipeline` **antes** de informar o resultado ao
  usuário — nunca depois, e nunca pulado só porque a fatia já foi aprovada. "Nenhuma
  sugestão/aprendizado concreto desta fatia" é uma conclusão válida do passo; "não avaliei" não é.
- [ ] Se esta é a **última fatia pendente** da feature (spec finalizada): `tech-writer` foi
  acionado para atualizar a documentação (`/sdd-sre`, passo 5b) **e** o teste geral obrigatório de
  fim de spec contra produção real foi conduzido depois do merge
  (`docs/POST-MERGE-VALIDATION.md`, seção "Teste geral obrigatório ao finalizar uma spec") — a
  spec só é considerada de fato concluída com os dois.
